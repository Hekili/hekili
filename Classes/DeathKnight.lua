-- Druid.lua
-- May 2017

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addTalent = ns.addTalent
local addTrait = ns.addTrait
local addResource = ns.addResource
local addStance = ns.addStance

local addSetting = ns.addSetting
local addToggle = ns.addToggle

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEATHKNIGHT') then

    ns.initializeClassModule = function ()

        setClass( "DEATHKNIGHT" )
        -- setSpecialization( "unholy" )

        -- Resources
        addResource( "runic_power", nil, true )
        addResource( "runes", nil, true )

        registerCustomVariable( 'runes', 
            setmetatable( {
                start = { 0, 0, 0, 0, 0, 0 },
                regen = 10,
                max = 6
            }, { __index = function( t, k )
                if k == 'count' or k == 'actual' or k == 'current' then
                    local ct = 0
                    for i = 1, 6 do
                        if t.start[i] == 0 or t.start[i] + t.regen < state.query_time then
                            ct = ct + 1
                        else
                            break
                        end
                    end
                    return ct

                elseif k == 'time_to_next' then
                    local time = state.query_time
                    local rune = 3600

                    for i = 1, 6 do
                        local ttr = t.start[i] + t.regen - state.query_time

                        if ttr > 0 then
                            return ttr
                        end
                    end
                    return 0

                end

                local ttr = k:match( "time_to_(%d)" )
                if ttr then
                    ttr = min( t.max, ttr )
                    local val = max( 0, t.start[ ttr ] + t.regen - state.query_time )
                    return val
                end

            end } ) )

        local function runeSpender( amount, resource )
            if resource == 'runes' then
                local r = state.runes

                r.actual = nil

                local change = min( r.count, amount )
                local spent = 0

                while( true ) do
                    for i = 1, 6 do
                        if r.start[i] == 0 or r.start[i] + r.regen < state.query_time then
                            r.start[i] = state.query_time
                            spent = spent + 1
                        end
                        if spent >= change then break end
                    end
                    if spent >= change then break end
                end
                table.sort( r.start )
                state.gain( amount * 10, 'runic_power' )

                if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                    state.applyBuff( "remorseless_winter", state.buff.remorseless_winter.remains + 0.5 )
                end
            end
        end

        local function runeGainer( amount, resource )
            if resource == 'runes' then
                local r = state.runes
                
                r.actual = nil

                local change = min( r.max - state.rune, amount )
                local gained = 0

                while( true ) do
                    for i = 6, 1, -1 do
                        if r.start[i] + r.regen > state.query_time then
                            r.start[i] = 0
                            gained = gained + 1
                        end
                        if gained >= change then break end
                    end
                    if gained >= change then break end
                end
                table.sort( r.start )
            end
        end

        addHook( 'spend', runeSpender )
        addHook( 'spendResources', runeSpender )
        addHook( 'gain', runeGainer )

        addHook( 'timeToReady', function( wait, action )
            local ability = action and class.abilities[ action ]

            if ability and ability.spend_type == "runes" and ability.spend > 0 then
                wait = max( wait, state.runes[ "time_to_" .. ability.spend ] )
            end

            return wait
        end )


        addMetaFunction( 'state', 'rune', function () return runes.count end )

        addHook( 'reset_precast', function ()
            state.runes.start[1], state.runes.regen = GetRuneCooldown(1)
            for i = 2, 6 do
                state.runes.start[i] = GetRuneCooldown(i)
            end
            table.sort( state.runes.start )
            state.runes.actual = nil
            state.runic_power.regen = 0

            -- A decent start, but assumes our first ability is always aggressive. Not necessarily true...
            if state.spec.frost then
                state.nextMH = ( state.combat ~= 0 and state.swings.mh_projected > state.now ) and state.swings.mh_projected or state.now + 0.01
                state.nextOH = ( state.combat ~= 0 and state.swings.oh_projected > state.now ) and state.swings.oh_projected or state.now + ( state.swings.oh_speed / 2 )
                -- state.nextFoA = state.buff.fury_of_air.up and tonumber( format( "%.0f", state.now ) ) + ( state.buff.fury_of_air.applied % 1 ) or 0
                
                local next_bos_tick = ( state.buff.breath_of_sindragosa.applied % 1 ) - ( state.now % 1 )
                if next_bos_tick < 0 then next_bos_tick = next_bos_tick + 1 end

                state.nextBoS = state.buff.breath_of_sindragosa.up and ( state.now + next_bos_tick ) or 0
                while state.nextBoS > 0 and state.nextBoS < state.now do state.nextBoS = state.nextBoS + 1 end
            end

        end )


        addHook( 'advance_resource_regen', function( override, resource, time )

            if resource ~= 'runic_power' or not state.spec.frost then return false end
            
            if state.spec.frost and resource == 'runic_power' then


                local MH, OH = UnitAttackSpeed( 'player' )
                local in_melee = state.target.within8

                local nextMH = ( in_melee and state.settings.forecast_swings and MH and state.nextMH > 0 ) and state.nextMH or 0
                local nextOH = ( in_melee and state.settings.forecast_swings and OH and state.nextOH > 0 ) and state.nextOH or 0
                local nextBoS = ( state.buff.breath_of_sindragosa.up and state.settings.forecast_breath and state.nextBoS and state.nextBoS > 0 ) and state.nextBoS or 0

                local iter = 0

                local offset = state.offset
                local rp = state.runic_power

                while( iter < 10 and ( ( nextMH > 0 and nextMH < state.query_time ) or
                    ( nextOH > 0 and nextOH < state.query_time ) or
                    ( nextBoS > 0 and nextBoS < state.query_time ) ) ) do

                    if nextMH > 0 and nextMH < nextOH and ( nextMH < nextBoS or nextBoS == 0 ) then
                        state.offset = nextMH - state.now
                        local gain = state.talent.runic_attenuation.enabled and 1 or 0
                        state.offset = offset

                        rp.actual = min( rp.max, rp.actual + gain )
                        state.nextMH = state.nextMH + MH
                        nextMH = nextMH + MH

                    elseif nextOH > 0 and nextOH < nextMH and ( nextOH < nextBoS or nextBoS == 0 ) then
                        state.offset = nextOH - state.now
                        local gain = state.talent.runic_attenuation.enabled and 1 or 0
                        state.offset = offset

                        rp.actual = min( rp.max, rp.actual + gain )
                        state.nextOH = state.nextOH + OH
                        nextOH = nextOH + OH

                    elseif nextBoS > 0 and nextBoS < nextMH and nextBoS < nextOH then                       
                        if rp.actual < 15 then
                            state.offset = nextBoS - state.now
                            state.removeBuff( 'breath_of_sindragosa' )
                            state.offset = offset

                            state.nextBoS = 0
                            nextBoS = 0
                        else
                            rp.actual = max( 0, rp.actual - 15 )
                            state.nextBoS = state.nextBoS + 1
                            nextBoS = nextBoS + 1
                        end

                    else
                        break

                    end

                    iter = iter + 1
                end

                return true

            end

            return false

        end )

        addHook( 'advance_end', function( time )
            local remaining = state.buff.hungering_rune_weapon.expires - ( state.query_time - time )

            if remaining > 0 then
                local ticks_before = floor( remaining / 1.5 )
                local ticks_after = floor( ( remaining - time ) /  1.5 )

                local ticks = ticks_before - ticks_after

                state.gain( ticks * 5, "runic_power" )
                state.gain( ticks, "runes" )
            end
        end )

        setPotion( "old_war" )
        setRole( "attack" )


        -- Talents: Unholy
        --[[ All Will Serve: Your Raise Dead spell summons an additional skeletal minion, and its cooldown is removed. ]]
        addTalent( "all_will_serve", 194916 ) -- 22024

        --[[ Asphyxiate: Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec. ]]
        addTalent( "asphyxiate", 108194 ) -- 22524

        --[[ Blighted Rune Weapon: Your next 5 auto attacks infect your target with 2 Festering Wounds. ]]
        addTalent( "blighted_rune_weapon", 194918 ) -- 22029

        --[[ Bursting Sores: Festering Wounds deal 50% more damage when burst, and all enemies within 8 yds of a burst Festering Wound suffer 4,728 Shadow damage. ]]
        addTalent( "bursting_sores", 207264 ) -- 22025

        --[[ Castigator: Each Festering Strike critical strike applies 2 additional Festering Wounds.  Each Scourge Strike critical strike bursts 1 additional Festering Wound. ]]
        addTalent( "castigator", 207305 ) -- 22518

        --[[ Clawing Shadows: Deals 10371.3 to 11461.9 Shadow damage and causes 1 Festering Wound to burst. ]]
        addTalent( "clawing_shadows", 207311 ) -- 22520

        --[[ Corpse Shield: For the next 10 sec, 90% of all damage you take is transferred to your ghoul.  If your ghoul is slain while this spell is active, it cannot be resummoned for 30 seconds. ]]
        addTalent( "corpse_shield", 207319 ) -- 22530

        --[[ Dark Arbiter: Summon a Val'kyr to attack the target for 15 sec. The Val'kyr will gain 1% increased damage for every 1 Runic Power you spend. ]]
        addTalent( "dark_arbiter", 207349 ) -- 22030

        --[[ Debilitating Infestation: Outbreak reduces the movement speed of all affected enemies by 50% for 3 sec. ]]
        addTalent( "debilitating_infestation", 207316 ) -- 22526

        --[[ Defile: Defile the targeted ground, dealing 29,414 Shadowfrost damage to all enemies over 10 sec.  Every 1 sec, if any enemies are standing in the Defile, it grows in size and increases your Mastery by 46, stacking up to 10 times.  While you remain within your Defile, your Scourge Strike will hit all enemies near the target. ]]
        addTalent( "defile", 152280 ) -- 22110

        --[[ Ebon Fever: Virulent Plague deals 20% more damage over time in half the duration. ]]
        addTalent( "ebon_fever", 207269 ) -- 22026

        --[[ Epidemic: Causes each of your Virulent Plagues within 100 yds to flare up, dealing 8,352 Shadow damage to the infected enemy, and an additional 1,531 Shadow damage to all other enemies near them. ]]
        addTalent( "epidemic", 207317 ) -- 22027

        --[[ Infected Claws: Your ghoul's Claw attack has a 35% chance to cause a Festering Wound on the target. ]]
        addTalent( "infected_claws", 207272 ) -- 22536

        --[[ Lingering Apparition: You move 30% faster during Wraith Walk, and its cooldown is reduced by 15 sec. ]]
        addTalent( "lingering_apparition", 212763 ) -- 22022

        --[[ Necrosis: Dealing damage with Death Coil causes your next Scourge Strike to deal 40% increased damage. ]]
        addTalent( "necrosis", 207346 ) -- 22534

        --[[ Pestilent Pustules: Every 8 Festering Wounds you burst, you gain 1 Rune. ]]
        addTalent( "pestilent_pustules", 194917 ) -- 22028

        --[[ Shadow Infusion: While your ghoul is not transformed, Death Coil will also reduce the remaining cooldown of Dark Transformation by 5 sec. ]]
        addTalent( "shadow_infusion", 198943 ) -- 22532

        --[[ Sludge Belcher: Raise Dead now summons an abomination instead of a ghoul, with improved innate abilities. ]]
        addTalent( "sludge_belcher", 207313 ) -- 22522

        --[[ Soul Reaper: Strike an enemy's soul for 24934.1 to 27381.1 Shadow damage, afflicting them with Soul Reaper for 5 sec.  Bursting a Festering Wound on an enemy afflicted by Soul Reaper grants 7% Haste for 15 sec, stacking up to 3 times. ]]
        addTalent( "soul_reaper", 130736 ) -- 22538

        --[[ Spell Eater: Your Anti-Magic Shell is 20% larger and lasts 5 sec longer. ]]
        addTalent( "spell_eater", 207321 ) -- 22528

        --[[ Unholy Frenzy: When a Festering Wound bursts, you gain 100% increased attack speed for 2.5 sec. ]]
        addTalent( "unholy_frenzy", 207289 ) -- 22516


        -- Talents: Frost
        --[[ Abomination's Might: Obliterate critical strikes have a 20% chance to drive lesser enemies to the ground, stunning them for 2 sec. Players are Dazed for 5 sec instead. ]]
        addTalent( "abominations_might", 207161 ) -- 22521

        --[[ Avalanche: While Pillar of Frost is active, your melee critical strikes cause jagged icicles to fall on your nearby enemies, dealing 2,347 Frost damage. ]]
        addTalent( "avalanche", 207142 ) -- 22519

        --[[ Blinding Sleet: Targets in a cone in front of you are blinded, causing them to wander disoriented for 4 sec. Damage may cancel the effect. ]]
        addTalent( "blinding_sleet", 207167 ) -- 22523

        --[[ Breath of Sindragosa: Continuously deal 13,494 Shadowfrost damage every 1 sec to enemies in a cone in front of you. Deals reduced damage to secondary targets. You will continue breathing until your Runic Power is exhausted or you cancel the effect.   ]]
        addTalent( "breath_of_sindragosa", 152279 ) -- 22109

        --[[ Freezing Fog: Howling Blast and Frost Fever deal 30% increased damage. ]]
        addTalent( "freezing_fog", 207060 ) -- 22019

        --[[ Frostscythe: A sweeping attack that strikes all enemies in front of you for 5130.8 to 5805.7 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal 4 times normal damage. ]]
        addTalent( "frostscythe", 207230 ) -- 22531

        --[[ Frozen Pulse: While you have fewer than 2 full Runes, your auto attacks radiate intense cold, inflicting 3,099 Frost damage on all nearby enemies. ]]
        addTalent( "frozen_pulse", 194909 ) -- 22020

        --[[ Gathering Storm: Each Rune spent during Remorseless Winter increases its damage by 15%, and extends its duration by 0.5 sec. ]]
        addTalent( "gathering_storm", 194912 ) -- 22535

        --[[ Glacial Advance: Summon glacial spikes from the ground that advance forward, each dealing 17,599 Frost damage to enemies near their eruption point. ]]
        addTalent( "glacial_advance", 194913 ) -- 22537

        --[[ Horn of Winter: Blow the Horn of Winter, gaining 2 runes and generating 20 Runic Power. ]]
        addTalent( "horn_of_winter", 57330 ) -- 22021

        --[[ Hungering Rune Weapon: Empower your rune weapon, gaining 1 Rune and 5 Runic Power instantly and every 1.5 sec for 15 sec. ]]
        addTalent( "hungering_rune_weapon", 207127 ) -- 22517

        --[[ Icecap: Your Frost Strike and Obliterate critical strikes reduce the remaining cooldown of Pillar of Frost by 1.0 sec. ]]
        addTalent( "icecap", 207126 ) -- 22515

        --[[ Icy Talons: Frost Strike also increases your melee attack speed by 10% for 6 sec, stacking up to 3 times. ]]
        addTalent( "icy_talons", 194878 ) -- 22017

        --[[ Murderous Efficiency: Consuming the Killing Machine effect has a 65% chance to cause you to gain 1 Rune. ]]
        addTalent( "murderous_efficiency", 207061 ) -- 22018

        --[[ Obliteration: For the next 8 sec, every Frost Strike hit triggers Killing Machine, and Obliterate costs 1 less Rune. ]]
        addTalent( "obliteration", 207256 ) -- 22023

        --[[ Permafrost: When you deal damage with auto attacks, gain an absorb shield equal to 30% of the damage dealt. ]]
        addTalent( "permafrost", 207200 ) -- 22529

        --[[ Runic Attenuation: Auto attacks generate 1 Runic Power. ]]
        addTalent( "runic_attenuation", 207104 ) -- 22533

        --[[ Shattering Strikes: If there are 5 stacks of Razorice on the target, Frost Strike will consume them and deal 40% additional damage. ]]
        addTalent( "shattering_strikes", 207057 ) -- 22016

        --[[ Volatile Shielding: Your Anti-Magic Shell turns your enemies' magic against them, absorbing 35% more damage, but generating no Runic Power.    When it expires, 25% of all damage absorbed is dealt as Shadow damage divided among nearby enemies. ]]
        addTalent( "volatile_shielding", 207188 ) -- 22527

        --[[ White Walker: You take 30% reduced damage while Wraith Walk is active. When you enter or leave Wraith Walk, all nearby enemies are slowed by 70% for 3 sec. ]]
        addTalent( "white_walker", 212765 ) -- 22031

        --[[ Winter is Coming: Enemies struck 5 times by Remorseless Winter while your Pillar of Frost is active are stunned for 4 sec. ]]
        addTalent( "winter_is_coming", 207170 ) -- 22525


        -- Traits
        addTrait( "ambidexterity", 189092 )
        addTrait( "bad_to_the_bone", 189147 )
        addTrait( "blades_of_frost", 218931 )
        addTrait( "blast_radius", 189086 )
        addTrait( "chill_of_the_grave", 205209 )
        addTrait( "cold_as_ice", 189080 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "crystalline_swords", 189186 )
        addTrait( "dead_of_winter", 189164 )
        addTrait( "ferocity_of_the_ebon_blade", 241047 )
        addTrait( "frozen_core", 189179 )
        addTrait( "frozen_skin", 204875 )
        addTrait( "frozen_soul", 189184 )
        addTrait( "hypothermia", 189185 )
        addTrait( "ice_in_your_veins", 189154 )
        addTrait( "mirror_ball", 189180 )
        addTrait( "nothing_but_the_boots", 189144 )
        addTrait( "overpowered", 189097 )
        addTrait( "runefrost", 238043 )
        addTrait( "runic_chills", 238079 )
        addTrait( "sindragosas_fury", 190778 )
        addTrait( "soulbiter", 214904 )
        addTrait( "thronebreaker", 238115 )


        -- Auras
        addAura( "aggramars_stride", 207438, "duration", 3600 )
        addAura( "antimagic_shell", 48707, "duration", 5 )
            modifyAura( "antimagic_shell", "duration", function( x ) return x + ( talent.spell_eater.enabled and 5 or 0 ) end )
        addAura( "army_of_the_dead", 42650, "duration", 40 )
        addAura( "blinding_sleet", 207167, "duration", 4 )
        addAura( "breath_of_sindragosa", 152279, "duration", 3600, "friendly", true )
        addAura( "dark_command", 56222, "duration", 3 )
        addAura( "dark_succor", 178819 )
        addAura( "dark_transformation", 63560, "duration", 20 )
        addAura( "death_and_decay", 188290, "duration", 10 )
        addAura( "defile", 156004, "duration", 10 )
        addAura( "defile_buff", 218100, "duration", 5, "max_stack", 10 )
        addAura( "festering_wound", 194310, "duration", 24, "max_stack", 8 )
        addAura( "frost_fever", 55095, "duration", 24 )
        addAura( "hungering_rune_weapon", 207127, "duration", 15 )
        addAura( "icebound_fortitude", 48792, "duration", 8 )
        addAura( "icy_talons", 194879, "duration", 6, "max_stack", 3 )
        addAura( "killing_machine", 51128, "duration", 10 )
        addAura( "mastery_dreadblade", 77515 )
        addAura( "mastery_frozen_heart", 77514 )
        addAura( "necrosis", 207346, "duration", 30 )
        addAura( "on_a_pale_horse", 51986 )
        addAura( "obliteration", 207256, "duration", 8 )
        addAura( "outbreak", 196782, "duration", 6 )
        addAura( "path_of_frost", 3714, "duration", 600 )
        addAura( "perseverance_of_the_ebon_martyr", 216059 )
        addAura( "pillar_of_frost", 51271, "duration", 20 )
        addAura( "razorice", 50401, "duration", 15, "max_stack", 5 )
        addAura( "remorseless_winter", 196770, "duration", 8, "friendly", true )
        addAura( "rime", 59057 )
        addAura( "runic_corruption", 51462 )
        addAura( "runic_empowerment", 81229 )
        addAura( "soul_reaper", 130736, "duration", 5 )
        addAura( "sudden_doom", 49530 )
        addAura( "temptation", 234143, "duration", 30 )
        addAura( "unholy_strength", 53365, "duration", 15 )
        addAura( "virulent_plague", 191587, "duration", 21 )
        addAura( "wraith_walk", 212552, "duration", 3 )


        addGearSet( "blades_of_the_fallen_prince", 128292 )
        setArtifact( "blades_of_the_fallen_prince" )

        addGearSet( "tier19", 138355, 138361, 138364, 138349, 138352, 138358 )
        addGearSet( "tier20", 147124, 147126, 147122, 147121, 147123, 147125 )

        addGearSet( "acherus_drapes", 132376 )
        addGearSet( "aggramars_stride", 132443 )
        addGearSet( "consorts_cold_core", 144293 )
        addGearSet( "kiljaedens_burning_wish", 144259 )
        addGearSet( "koltiras_newfound_will", 132366 )
        addGearSet( "perseverance_of_the_ebon_martyr", 132459 )
        addGearSet( "prydaz_xavarics_magnum_opus", 132444 )
        addGearSet( "rethus_incessant_courage", 146667 )
        addGearSet( "seal_of_necrofantasia", 137223 )
        addGearSet( "sephuzs_secret", 132452 )
        addGearSet( "toravons_whiteout_bindings", 132458 )


        addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and your Artifact Ability will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } )

        ns.addSetting( 'forecast_breath', true, {
            name = 'Frost: Predict Breath of Sindragosa RP',
            type = 'toggle',
            desc = "If checked, the addon will predict Runic Power expenditure (15 per second) from Breath of Sindragosa and factor this in to future recommendations.  This is generally reliable and conservative, as " ..
                "Breath of Sindragosa ticks are rather consistent.  However, if Breath of Sindragosa does not tick when predicted, the addon may give recommendations assuming you have less Runic Power than you actually do.  " ..
                "The default value is |cFFFFD100true|r.",
            width = 'full'
        } )

        ns.addSetting( 'forecast_swings', true, {
            name = 'Frost: Predict Melee RP',
            type = 'toggle',
            desc = "If checked, the addon will predict when your next melee swings will land, generating 1 Runic Power if Runic Attenuation is talented.  This is generally reliable and conservative, but " ..
                "can result in occasional recommendations that are overly optimistic about your Runic Power income.  This can also be inaccurate if you are frequently outside of melee range of your " ..
                "target.  The default value is |cFFFFD100true|r.",
            width = "full"
        } )

        -- Abilities

        -- Anti-Magic Shell
        --[[ Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 65,171 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power. ]]

        addAbility( "antimagic_shell", {
            id = 48707,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "antimagic_shell", function ()
            applyBuff( 'antimagic_shell', 5 + ( talent.spell_eater.enabled and 5 or 0 ) + ( equipped.acherus_drapes and 5 or 0 ) )
        end )


        -- Apocalypse

        addAbility( "apocalypse", {
            id = 220143,
            spend = 0,
            cast = 0,
            gcdType = "melee",
            cooldown = 90,
            -- min_range = 0,
            -- max_range = 0,
            known  = function () return equipped.apocalypse and toggle.artifact_ability end,
        } )

        addHandler( "apocalypse", function ()
            if debuff.festering_wound.stack > 6 then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 6 )
            else
                removeDebuff( "target", "festering_wound" )
            end
        end )
        

        -- Army of the Dead
        --[[ Summons a legion of Ghouls over 4 sec who will fight for you for 40 sec, swarming the area, fighting anything they can. ]]

        addAbility( "army_of_the_dead", {
            id = 42650,
            spend = 3,
            min_cost = 3,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 600,
            -- min_range = 0,
            -- max_range = 0,
            passive = true,
            toggle = 'cooldowns',
        } )

        addHandler( "army_of_the_dead", function ()
            -- not sure if we need to summon ghouls as pets, watch these mechanics.
        end )


        -- Blighted Rune Weapon

        addAbility( "blighted_rune_weapon", {
            id = 194918,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            usable = function () return talent.blighted_rune_weapon.enabled end,
        } )

        addHandler( "blighted_rune_weapon", function ()
            applyBuff( "blighted_rune_weapon", 30, 5 )
        end )
        

        -- Blinding Sleet
        --[[ Targets in a cone in front of you are blinded, causing them to wander disoriented for 4 sec. Damage may cancel the effect. ]]

        addAbility( "blinding_sleet", {
            id = 207167,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "blinding_sleet",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "blinding_sleet", function ()
            applyDebuff( "target", "blinding_sleet", 4 )
            active_dot.blinding_sleet = max( active_dot.blinding_sleet, active_enemies )
        end )


        -- Breath of Sindragosa
        --[[ Continuously deal 13,494 Shadowfrost damage every 1 sec to enemies in a cone in front of you. Deals reduced damage to secondary targets. You will continue breathing until your Runic Power is exhausted or you cancel the effect.   ]]

        addAbility( "breath_of_sindragosa", {
            id = 152279,
            spend = 0,
            min_cost = 0,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            talent = "breath_of_sindragosa",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
            toggle = "cooldowns",
        } )

        addHandler( "breath_of_sindragosa", function ()
            applyBuff( "breath_of_sindragosa", 3600 )
        end )


        -- Chains of Ice
        --[[ Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec. ]]

        addAbility( "chains_of_ice", {
            id = 45524,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            max_range = 30,
        } )

        addHandler( "chains_of_ice", function ()
            applyDebuff( "target", "chains_of_ice", 8 )
        end )


        -- Clawing Shadows

        addAbility( "clawing_shadows", {
            id = 207311,
            spend = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "melee",
            cooldown = 0,
            max_range = 30,
            usable = function () return talent.clawing_shadows.enabled end,
        } )

        addHandler( "clawing_shadows", function ()
            if debuff.festering_wound.up then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                gain( 3, "runic_power" )
            end
            removeBuff( 'necrosis' )
        end )


        -- Control Undead
        --[[ Dominates the target undead creature up to level 101, forcing it to do your bidding for 5 min. ]]

        addAbility( "control_undead", {
            id = 111673,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 1.357,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            max_range = 30,
            usable = function () return target.is_undead and target.level <= level + 1 end
        } )

        addHandler( "control_undead", function ()
            summonPet( "controlled_undead", 300 )
        end )


        -- Dark Arbiter
        --[[ Summon a Val'kyr to attack the target for 15 sec. The Val'kyr will gain 1% increased damage for every 1 Runic Power you spend. ]]

        addAbility( "dark_arbiter", {
            id = 207349,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "dark_arbiter",
            cooldown = 120,
            -- min_range = 0,
            max_range = 30,
            usable = function () return talent.dark_arbiter.enabled end,
            toggle = 'cooldowns'
        } )

        addHandler( "dark_arbiter", function ()
            summonPet( "valkyr_battlemaiden", 15 )
        end )


        -- Dark Command
        --[[ Command the target to attack you, increasing threat you generate against that target for 3 sec. ]]

        addAbility( "dark_command", {
            id = 56222,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 8,
            -- min_range = 0,
            max_range = 30,
        } )

        addHandler( "dark_command", function ()
            applyDebuff( "target", "dark_command", 3 )
        end )


        -- Dark Transformation
        --[[ Transform your ghoul into a powerful undead monstrosity for 20 sec. The ghoul's abilities are empowered and take on new functions while the transformation is active. ]]

        addAbility( "dark_transformation", {
            id = 63560,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            -- min_range = 0,
            max_range = 100,
        } )

        addHandler( "dark_transformation", function ()
            applyBuff( "dark_transformation", 20 )
        end )


        -- Death and Decay
        --[[ Corrupts the targeted ground, causing 16,533 Shadow damage over 10 sec to targets within the area. While you remain within the area, your Scourge Strike will hit all enemies near the target. ]]

        addAbility( "death_and_decay", {
            id = 43265,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            -- min_range = 0,
            max_range = 30,
            known = function () return not talent.defile.enabled end,
        } )

        addHandler( "death_and_decay", function ()
            applyBuff( "death_and_decay", 10 )
        end )


        -- Death Coil
        --[[ Fires a blast of unholy energy at the target, causing 8,352 Shadow damage to an enemy and restoring 10 Energy to your ghoul. ]]

        addAbility( "death_coil", {
            id = 47541,
            spend = 35,
            min_cost = 35,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            max_range = 30,
        } )

        modifyAbility( "death_coil", "spend", function( x )
            if buff.sudden_doom.up then return 0 end
            return x
        end )

        addHandler( "death_coil", function ()
            if talent.necrosis.enabled then applyBuff( "necrosis" ) end
            removeBuff( "sudden_doom" )
        end )


        -- Death Grip
        --[[ Harnesses the energy that surrounds and binds all matter, drawing the target toward you. ]]

        addAbility( "death_grip", {
            id = 49576,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 25,
            charges = 1,
            recharge = 25,
            -- min_range = 0,
            max_range = 30,
        } )

        addHandler( "death_grip", function ()
            target.minR = 5
            target.maxR = 5
        end )


        -- Death Strike
        --[[ Focuses dark power into a strike that deals 12453.2 to 13762.2 Physical damage and heals you for 20% of all damage taken in the last 5 sec, minimum 10% of maximum health. ]]

        addAbility( "death_strike", {
            id = 49998,
            spend = 45,
            min_cost = 45,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "death_strike", function ()
            removeBuff( "dark_succor" )
        end )


        -- Defile

        addAbility( "defile", {
            id = 152280,
            spend = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            usable = function () return talent.defile.enabled end,
        } )

        addHandler( "defile", function ()
            applyBuff( "defile_buff", 10, 1 )
            applyDebuff( "target", "defile", 10 )
        end )


        -- Empower Rune Weapon
        --[[ Empower your rune weapon, immediately activating all your runes and generating 25 Runic Power. ]]

        addAbility( "empower_rune_weapon", {
            id = 47568,
            spend = -25,
            min_cost = -25,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            charges = 1,
            recharge = 180,
            toggle = "cooldowns",
            -- min_range = 0,
            -- max_range = 0,
            known = function () return not talent.hungering_rune_weapon.enabled end,
        } )
        
        modifyAbility( "empower_rune_weapon", "charges", function( x ) return x + ( equipped.seal_of_necrofantasia and 1 or 0 ) end )
        modifyAbility( "empower_rune_weapon", "recharge", function( x ) return x / ( equipped.seal_of_necrofantasia and 1.10 or 1 ) end)

        addHandler( "empower_rune_weapon", function ()
            gain( 6, "runes" )
        end )


        -- Epidemic
        --[[ Causes each of your Virulent Plagues within 100 yds to flare up, dealing 8,288 Shadow damage to the infected enemy, and an additional 1,520 Shadow damage to all other enemies near them. ]]

        addAbility( "epidemic", {
            id = 207317,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            talent = "epidemic",
            cooldown = 10,
            charges = 3,
            recharge = 10,
            -- min_range = 0,
            -- max_range = 0,
            usable = function () return talent.epidemic.enabled end,
        } )

        modifyAbility( "epidemic", "cooldown", function( x ) return x * haste end )
        modifyAbility( "epidemic", "recharge", function( x ) return x * haste end )

        addHandler( "epidemic", function ()
            -- proto
        end )


        -- Festering Strike
        --[[ Deals 22912.1 to 25322.1 Physical damage and infects the target with 2 to 4 Festering Wounds.   Festering Wound  A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 5,568 Shadow damage and generating 3 Runic Power. ]]

        addAbility( "festering_strike", {
            id = 85948,
            spend = 2,
            min_cost = 2,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "festering_strike", function ()
            applyDebuff( "target", "festering_wound", 24, debuff.festering_wound.stack + 2 )
        end )


        -- Frost Strike
        --[[ Chill your weapons with icy power, and quickly strike the enemy with both weapons, dealing a total of 15,991 to 18,091 Frost damage. ]]

        addAbility( "frost_strike", {
            id = 49143,
            spend = 25,
            min_cost = 25,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "frost_strike", function ()
            if talent.shattering_strikes.enabled and debuff.razorice.stack >= 5 then
                applyDebuff( "target", "razorice", debuff.razorice.remains, debuff.razorice.stack - 5 )
            elseif talent.icy_talons.enabled then
                applyBuff( "icy_talons", 6, min( 3, buff.icy_talons.stack + 1 ) )
            end

            if buff.obliteration.up then
                applyBuff( "killing_machine" )
            end
        end )


        -- Frostscythe
        --[[ A sweeping attack that strikes all enemies in front of you for 5130.8 to 5805.7 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal 4 times normal damage. ]]

        addAbility( "frostscythe", {
            id = 207230,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            talent = "frostscythe",
            cooldown = 0,
            -- min_range = 0,
            max_range = 8,
        } )

        addHandler( "frostscythe", function ()
            removeBuff( "killing_machine" )
        end )


        -- Glacial Advance
        --[[ Summon glacial spikes from the ground that advance forward, each dealing 17,599 Frost damage to enemies near their eruption point. ]]

        addAbility( "glacial_advance", {
            id = 194913,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            talent = "glacial_advance",
            cooldown = 15,
            min_range = 0,
            max_range = 100,
        } )

        addHandler( "glacial_advance", function ()
            -- proto
        end )


        -- Horn of Winter
        --[[ Blow the Horn of Winter, gaining 2 runes and generating 20 Runic Power. ]]

        addAbility( "horn_of_winter", {
            id = 57330,
            spend = -20,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            talent = "horn_of_winter",
            cooldown = 30,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "horn_of_winter", function ()
            gain( 2, "runes" )
        end )


        -- Howling Blast
        --[[ Blast the target with a frigid wind, dealing 3,872 Frost damage to that foe, and 3,097 Frost damage to all other enemies within 10 yards, infecting all targets with Frost Fever.     Frost Fever  A disease that deals 20,648 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage. ]]

        addAbility( "howling_blast", {
            id = 49184,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            max_range = 30,
        } )

        modifyAbility( "howling_blast", "spend", function( x ) return buff.rime.up and 0 or x end )
        modifyAbility( "howling_blast", "min_cost", function( x ) return buff.rime.up and 0 or x end )

        addHandler( "howling_blast", function ()
            applyDebuff( "target", "frost_fever", 24 )
            active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )
            if set_bonus.tier19_4pc and buff.rime.up then
                gain( 8, "runic_power" )
            end
            removeBuff( "rime" )
        end )


        -- Hungering Rune Weapon
        --[[ Empower your rune weapon, gaining 1 Rune and 5 Runic Power instantly and every 1.5 sec for 15 sec. ]]

        addAbility( "hungering_rune_weapon", {
            id = 207127,
            spend = -5,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "off",
            talent = "hungering_rune_weapon",
            cooldown = 180,
            charges = 1,
            recharge = 180,
            toggle = "cooldowns",
            known = function () return talent.hungering_rune_weapon.enabled end,
            -- min_range = 0,
            -- max_range = 0,
        } )

        modifyAbility( "hungering_rune_weapon", "charges", function( x ) return x + ( equipped.seal_of_necrofantasia and 1 or 0 ) end )
        modifyAbility( "hungering_rune_weapon", "recharge", function( x ) return x / ( equipped.seal_of_necrofantasia and 1.10 or 1 ) end)

        addHandler( "hungering_rune_weapon", function ()
            gain( 1, "runes" )
            applyBuff( "hungering_rune_weapon", 15 )
        end )


        -- Icebound Fortitude
        --[[ Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 20% for 8 sec. ]]

        addAbility( "icebound_fortitude", {
            id = 48792,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "icebound_fortitude", function ()
            applyBuff( "icebound_fortitude", 8 )
        end )


        -- Mind Freeze
        --[[ Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec. ]]

        addAbility( "mind_freeze", {
            id = 47528,
            spend = 0,
            min_cost = 0,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "off",
            cooldown = 15,
            -- min_range = 0,
            max_range = 15,
            toggle = "interrupts",
            usable = function () return target.casting end,
        } )

        addHandler( "mind_freeze", function ()
            interrupt()
        end )


        -- Obliterate
        --[[ A brutal attack with both weapons that deals a total of 20,846 to 23,582 Physical damage. ]]

        addAbility( "obliterate", {
            id = 49020,
            spend = 2,
            min_cost = 2,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
        } )

        modifyAbility( "obliterate", "spend", function( x ) return x - ( buff.obliteration.up and 1 or 0 ) end )
        modifyAbility( "obliterate", "min_cost", function( x ) return x - ( buff.obliteration.up and 1 or 0 ) end )

        addHandler( "obliterate", function ()
            -- talent.murderous_efficiency is a 65% chance, too inconsistent to predict RP gain.
            removeBuff( "killing_machine" )
        end )


        -- Obliteration
        --[[ For the next 8 sec, every Frost Strike hit triggers Killing Machine, and Obliterate costs 1 less Rune. ]]

        addAbility( "obliteration", {
            id = 207256,
            spend = 0,
            cast = 0,
            gcdType = "off",
            talent = "obliteration",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
            toggle = "cooldowns"
        } )

        addHandler( "obliteration", function ()
            applyBuff( "obliteration", 8 )
        end )


        -- Outbreak
        --[[ Deals 1,996 Shadow damage and surrounds the target in a miasma lasting for 6 sec that causes the target and all nearby enemies to be infected with Virulent Plague.     Virulent Plague  A disease that deals 32,739 Shadow damage over 10.5 sec. It erupts when the infected target dies, dealing 5,253 Shadow damage divided among nearby enemies, and has a 30% chance to erupt each time it deals damage.   ]]

        addAbility( "outbreak", {
            id = 77575,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            max_range = 30,
        } )

        addHandler( "outbreak", function ()
            applyDebuff( "target", "outbreak", 6 )
            applyDebuff( "target", "virulent_plague", 21 * ( talent.ebon_fever.enabled and 0.5 or 1 ) )
        end )


        -- Path of Frost
        --[[ Activates a freezing aura for 10 min that creates ice beneath your feet, allowing party or raid members within 50 yards to walk on water. Usable while mounted, but being attacked or damaged will cancel the effect. ]]

        addAbility( "path_of_frost", {
            id = 3714,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "path_of_frost", function ()
            applyBuff( "path_of_frost", 600 )
        end )


        -- Pillar of Frost
        --[[ The power of Frost increases your Strength by 20%, and grants immunity to external movement effects such as knockbacks.  Lasts 20 sec. ]]

        addAbility( "pillar_of_frost", {
            id = 51271,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 60,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "pillar_of_frost", function ()
            applyBuff( "pillar_of_frost" )
        end )


        -- Raise Dead
        --[[ Raises a ghoul to fight by your side.  You can have a maximum of one ghoul at a time. ]]

        addAbility( "raise_dead", {
            id = 46584,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            -- min_range = 0,
            max_range = 30,
            passive = true,
            usable = function () return not pet.exists end,
        } )

        addHandler( "raise_dead", function ()
            summonPet( talent.sludge_belcher.enabled and "sludge_belcher" or "ghoul", 3600 )
            if talent.all_will_serve.enabled then summonPet( "skeleton", 3600 ) end
        end )


        -- Remorseless Winter
        --[[ Drain the warmth of life from all nearby enemies, dealing 15,210 Frost damage over 8 sec and reducing their movement speed by 50%. ]]

        addAbility( "remorseless_winter", {
            id = 196770,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 20,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "remorseless_winter", function ()
            applyBuff( "remorseless_winter", 8 )
            -- active_dot.remorseless_winter = max( active_dot.remorseless_winter, 8 )
        end )


        -- Scourge Strike
        --[[ An unholy strike that deals 6030.8 to 6665.1 Physical damage and 4321.4 to 4775.8 Shadow damage, and causes 1 Festering Wound to burst. ]]

        addAbility( "scourge_strike", {
            id = 55090,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            -- min_range = 0,
            -- max_range = 0,
            known = function () return not talent.clawing_shadows.enabled end,
        } )

        addHandler( "scourge_strike", function ()
            if debuff.festering_wound.up then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                gain( 3, "runic_power" )
            end
            removeBuff( 'necrosis' )
        end )


        -- Sindragosa's Fury (Artifact Ability)
        --[[ Summons Sindragosa, who breathes frost on all enemies within 40 yd in front of you, dealing X Frost damage and slowing movement speed by 50% for 10 sec. ]]

        addAbility( "sindragosas_fury", {
            id = 190778,
            spend = 0,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "spell",
            cooldown = 300,
            known = function () return equipped.blades_of_the_fallen_prince and artifact.sindragosas_fury.enabled and ( toggle.artifact_ability or ( toggle.artifact_cooldown and toggle.cooldowns ) ) end,
            toggle = "cooldowns",
        } )

        modifyAbility( "sindragosas_fury", "cooldown", function( x ) return x * ( equipped.consorts_cold_core and 0.5 or 1 ) end )


        -- Soul Reaper

        addAbility( "soul_reaper", {
            id = 130736,
            spend = 1,
            min_cost = 1,
            spend_type = "runes",
            cast = 0,
            gcdType = "spell",
            talent = "soul_reaper",
            cooldown = 45,
            -- min_range = 0,
            -- max_range = 0,
            usable = function () return talent.soul_reaper.enabled end,
        } )

        addHandler( "soul_reaper", function ()
            applyDebuff( "target", "soul_reaper", 5 )
        end )


        -- Summon Gargoyle
        --[[ A Gargoyle flies into the area and bombards the target for 40 sec. ]]

        addAbility( "summon_gargoyle", {
            id = 49206,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            -- min_range = 0,
            max_range = 30,
            usable = function () return not talent.dark_arbiter.enabled end,
            toggle = 'cooldowns'
        } )

        addHandler( "summon_gargoyle", function ()
            summonPet( "gargoyle", 40 )
        end )



        -- Wraith Walk
        --[[ Sidestep into the Shadowlands, removing all root effects and increasing your movement speed by 100%. While active, your movement speed cannot be reduced below 170%. Lasts 3 sec. Any action will cancel the effect. ]]

        addAbility( "wraith_walk", {
            id = 212552,
            spend = 0,
            cast = 3,
            channeled = true,
            gcdType = "spell",
            cooldown = 45,
            -- min_range = 0,
            -- max_range = 0,
        } )

        addHandler( "wraith_walk", function ()
            applyBuff( "wraith_walk", 3 )
        end )

    end


    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170507.220005, [[d8dYtaqAeRNsu2eK0UivBdcK9HuupgKdlA2umFuHUPaNNs13GuoeQGDcQ9QA3kTFkPFsjiddjghLG65cDzPbtPmCbDqiXPGqhJKoheWcHuTuiYIv0Yr5HOIEkXYqvToiq1FjXurknzatNQlIu18OeYZqkY1bQnsjYwrvAZaz7KsFecu(kLatdPqFhPYiPeQxJknAK0NjfNevXTv4AifCpiOFd1XPevJcI6REAVq)Mttb(8cCo6fHm40QnlXWrhb3QnnDlJaDbPAAg7H5trfnk0afeKU6fjSqK0qSS0j49W8Pb1lOa5e8gpThw90EH(nNMcC0ViqmsOFHdEA666rQP7LrwnkrNr42OE3CAkaQipbdcKobYUINg8g1zDKKnArQ60aQEA666ei7kEAWBuVBonfaXlOmjgIB)cigo6krNr42lCsTqCdWA7OR)5LamaVjdoh9Yf4C0lwIHJUvBIZiC7fKQPzShMpfv0uPCHNfGaLoMDzXBVeGbGZrVC)W8pTxOFZPPah9lceJe6x80011Jut3lJSAuIoJWTr9U50uaub6emiq6S0YWmcu1JEcXfH0WfuMedXTFbedhDLOZiC7foPwiUbyTD01)8sagG3KbNJE5cCo6flXWr3QnXzeU1QnKvr8cs10m2dZNIkAQuUWZcqGshZUS4TxcWaW5OxUFyA60EH(nNMcC0ViqmsOFHdayxhedhDfqvBz6obIlz1CbLjXqC7xOIPZqwnkttg9l8SaeO0XSllE7LamaVjdoh9Yf4C0lwmModz1y1g6Mm6xqHPjEXtMM6keqiKdayxhedhDfqvBz6obIlz1CbPAAg7H5trfnvkx4KAH4gG12rx)Zlbya4C0l3pmnEAVq)Mttbo6xeigj0VG8emiq6mYO6GdrTwoysyyb0dllwTLLluvWGuCQvPt8QmsMBNHkhqEcgeiD80q8YsNGxDWHOMqorBv62bPrlIpIiYro6PPRRRjDQLrwnkrhZg6DZPPaxqzsme3(fwhywSMgJk0rwVSlCsTqCdWA7OR)5LamaVjdoh9Yf4C0li1bMfRPXOvBwaz9YUGunnJ9W8POIMkLl8SaeO0XSllE7LamaCo6L7hMgoTxOFZPPah9lceJe6xMGbbsNrgvhCiQCa5jyqG0XtdXllDcE1bhIAc5eTvPBhKgTi(iIkhqUwoysyyb0dllwTLLluvWGuCQvPt8QmsMBNHQNMUUUM0Pwgz1OeDmBO3nNMcG4fuMedXTFHkModz1Omnz0VWj1cXnaRTJU(NxcWa8Mm4C0lxGZrVyXy6mKvJvBOBYOB1gYQiEbPAAg7H5trfnvkx4zbiqPJzxw82lbya4C0l3pmc60EH(nNMcC0ViqmsOFzcgeiDgzuDWHOYbKNGbbshpneVS0j4vhCiQjKt0wLUDqA0I4JiQ1YbtcdlGEyzXQTSCHQcgKItTkDIxLrYC7mu900111Ko1YiRgLOJzd9U50uaurgOtWGaPhwwSAllxOQGbP4uRsN4vzKm3othCih5iegBaW0T6SoWSynngvOJSEz6SosYgPzAcXlOmjgIB)cvmDgYQrzAYOFHtQfIBawBhD9pVeGb4nzW5OxUaNJEXIX0ziRgR2q3Kr3QnK5J4fKQPzShMpfv0uPCHNfGaLoMDzXBVeGbGZrVC)WODAVq)Mttbo6xeigj0VWHjyqG0XtdXllDcE1bhIkY1YbtcdlGoxSXjSmQSLoqyWlGcDeJbvpnDDDqmSL1vjeSjw9U50uaurowxzIxWrDNuMkcOWpecHQCKJX6kt8coQ7KYurafAmecHQiI4fuMedXTFbpneVS07foPwiUbyTD01)8sagG3KbNJE5cCo6fl00q8YsVxqQMMXEy(uurtLYfEwacu6y2LfV9sagaoh9Y9dBHpTxOFZPPah9lceJe6xyGxcKsiMUY0bkiceXTieQs5cktIH42VaIHJUs0zeU9cNule3aS2o66FEjadWBYGZrVCboh9ILy4OB1M4mc3A1gY8r8cs10m2dZNIkAQuUWZcqGshZUS4TxcWaW5OxUFye40EH(nNMcC0ViqmsOFzcgeiD80q8YsNGxDWHOYHjyqG05smgYQrzKqujB1bhEbLjXqC7xaXWrxj6mc3EHtQfIBawBhD9pVeGb4nzW5OxUaNJEXsmC0TAtCgHBTAdzAcXlivtZypmFkQOPs5cplabkDm7YI3EjadaNJE5(HvPCAVq)Mttbo6xeigj0VKqorBv62bPrAgH8rLdi7PPRRdIHJEeYUtT6DZPPaOobdcKoxIXqwnkJeIkzRo4qutiNOTkD7G0inJq(iEbLjXqC7xyDGzXAAmQqhz9YUWj1cXnaRTJU(NxcWa8Mm4C0lxGZrVGuhywSMgJwTzbK1lZQnKvr8cs10m2dZNIkAQuUWZcqGshZUS4TxcWaW5OxUFyv1t7f63CAkWr)IaXiH(fKNGbbsNlXyiRgLrcrLSvhCiQjKt0wLUDqAKMriFeVGYKyiU9lGy4OhHS7u7foPwiUbyTD01)8sagG3KbNJE5cCo6flXWrpcz3P2livtZypmFkQOPs5cplabkDm7YI3EjadaNJE5(Hv5FAVq)Mttbo6xeigj0VKqorBv62bPrAgH8VGYKyiU9lAmjejnkjG2CH6foPwiUbyTD01)8sagG3KbNJE5cCo6femtcrsJvBOaOnxOEbPAAg7H5trfnvkx4zbiqPJzxw82lbya4C0l3pSknDAVq)Mttbo6xeigj0VKqorBv62bPrAgH00fuMedXTFbedh9iKDNAVWj1cXnaRTJU(NxcWa8Mm4C0lxGZrVyjgo6ri7o1A1gYQiEbPAAg7H5trfnvkx4zbiqPJzxw82lbya4C0l3pSknEAVq)Mttbo6xeigj0VmbdcKoxIXqwnkJeIkzRo4WlOmjgIB)cEAiEzP3lCsTqCdWA7OR)5LamaVjdoh9Yf4C0lwOPH4LLETAdzveVGunnJ9W8POIMkLl8SaeO0XSllE7LamaCo6L7hwLgoTxOFZPPah9lceJe6x800111Ko1YiRgLOJzd9U50uau90011hGzaLHbhvkiqeisxi76DZPPaOICSUYeVGJ6oPmveqHFiecv5ihJ1vM4fCu3jLPIak0yiecvr8cktIH42VaIHJUs0zeU9cNule3aS2o66FEjadWBYGZrVCboh9ILy4OB1M4mc3A1gY0iIxqQMMXEy(uurtLYfEwacu6y2LfV9sagaoh9Y9dRIGoTxOFZPPah9lceJe6xq2ttxxNkMTkyqk0rwVm9U50uaoYrpnDDDQGxnLrwnkmWBvORziE17MttbqevKJ1vM4fCu3jLPIak8dHqOkh5ySUYeVGJ6oPmveqHgdHqOkIxqzsme3(fqmC0vIoJWTx4KAH4gG12rx)ZlbyaEtgCo6LlW5OxSedhDR2eNr4wR2qMgq8cs10m2dZNIkAQuUWZcqGshZUS4TxcWaW5OxUFyv0oTxOFZPPah9lbyaEtgCo6LlW5OxSqtdXll9A1gY8r8cs10m2dZNIkAQuUGYKyiU9l4PH4LLEVWZcqGshZUS4Tx4KAH4gG12rx)Zlbya4C0l3pSQf(0EH(nNMcC0VeGb4nzW5OxUaNJEbbZKqK0y1gkaAZfQwTHSkIxqQMMXEy(uurtLYfuMedXTFrJjHiPrjb0MluVWZcqGshZUS4Tx4KAH4gG12rx)Zlbya4C0l3pSkcCAVq)Mttbo6xeigj0VWHjyqG0PcE1ugz1OWaVvHUMH4vhC4fuMedXTFHkMTkyqk0rwVSlCsTqCdWA7OR)5LamaVjdoh9Yf4C0lwmMTwTHbz1MfqwVSlivtZypmFkQOPs5cplabkDm7YI3EjadaNJE5(H5t50EH(nNMcC0VeGb4nzW5OxUaNJEXsmC0TAtCgHBTAdzeeIxqQMMXEy(uurtLYfuMedXTFbedhDLOZiC7fEwacu6y2LfV9cNule3aS2o66FEjadaNJE5(H5REAVq)Mttbo6xeigj0V4PPRRdIHTSUkHGnXQ3nNMcCbLjXqC7xyDGzXAAmQqhz9YUWj1cXnaRTJU(NxcWa8Mm4C0lxGZrVGuhywSMgJwTzbK1lZQnK5J4fKQPzShMpfv0uPCHNfGaLoMDzXBVeGbGZrVC)W85FAVq)Mttbo6xeigj0V4ynAmvhcJnay624fuMedXTFPJqmDLPWaVvHUMH49cNule3aS2o66FEjadWBYGZrVCboh9c9JqmDLz1gsG3A1Mf0meVxqQMMXEy(uurtLYfEwacu6y2LfV9sagaoh9Y9dZNMoTxOFZPPah9lceJe6xCSgnMQdHXgamDBevK5Wemiq6ubVAkJSAuyG3QqxZq8QdoeXlOmjgIB)cvWRMYiRgfg4Tk01meVx4KAH4gG12rx)ZlbyaEtgCo6LlW5OxSyWRMYiRgR2qc8wR2SGMH49cs10m2dZNIkAQuUWZcqGshZUS4TxcWaW5OxUF)IaXiH(L7)]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170507.220005, [[dau5paqiPuwevcBIk6tevjJsvYPuLAxizyi4yQILjL8mesMgrv01qiSnPuX3iknoIQuNJOkyDiunpQeDpPu1(qi1bLIwirLhkfUivOnsLQtsLYmjQQUPQYorQFsufAOsPslLk4PKMkryRujTxO)IObRQ6WIwSs9yPAYu1LrTzk6Zuy0ePtd61kjZMWTbA3k(TWWvIJtuvwUkpNstxY1b02jk(or05vsTEeIMpcL9dW4dkbQoo5wWECJkDcYOQqWga(D)cBrCa)E2mbkkuDGfCAzKUfHhzjqeeAhQhu1fUdtbKiZcgds3IiEqTzVGXyrjq6hucuDCYTG9OCOQ9dUuO2glFaHllSNQhJm8zWtNjdtsZSylXiwBvk4PO2hNLuYWK0ch)LgHnP4j3c2JAZnuaR1OUafI8idtsZlSfQnKY9vFHmmipfUr9l8UMhDcYOIkDcYO2UqHipa)HjGF3VWwO6al40YiDlcpY(qav3gpSNvCOoXWO(fE6eKrflKUfkbQoo5wWEuou1(bxkuz5diCzH9u9yKHpdE6mzysAMfBDwPGNIAFCwsjdtslC8xAe2KINClyVZxVoGdStUesYhvh4D8ueD7jcco7ri8HKdLuGJbFWXG8aomPKCUed1XGjCSU8HWBIrSx9ie(qYHAFCwsjdtslC8xAe2K6yWeowIUfH3VrT5gkG1AuxGcrEKHjP5f2c1gs5(QVqggKNc3O(fExZJobzurLobzuBxOqKhG)WeWV7xyla)VEEJQdSGtlJ0Ti8i7dbuDB8WEwXH6edJ6x4PtqgvSqAIcLavhNClypkhQA)GlfQvyyiyk4u8DaxklQn3qbSwJkiC8KMhZejJAdPCF1xiddYtHBu)cVR5rNGmQOsNGmQFWXd439JzIKr1bwWPLr6weEK9HaQUnEypR4qDIHr9l80jiJkwiT8eLavhNClypkhQA)GlfQvyyiyQEecFi5yD(6aoWo5sijFuE2e2Hfr3IGZ2QuWtrTpolPKHjPfo(lncBsXtUfS)nQn3qbSwJAE9CyYkUJNc1gs5(QVqggKNc3O(fExZJobzurLobzuBE9Cya)se3XtHQdSGtlJ0Ti8i7dbuDB8WEwXH6edJ6x4PtqgvSqAIaLavhNClypkhQA)GlfQvyyiyQEecFi5yD(Qsbpf1(4SKsgMKw44V0iSjfp5wWEN(OO2hNLuYWK0ch)LgHnPkyFfCmCEahyNCjKKpQoW74PCjrrW5bCyx26nQn3qbSwJAE9CyYkUJNc1gs5(QVqggKNc3O(fExZJobzurLobzuBE9Cya)se3Xtb4)1ZBuDGfCAzKUfHhzFiGQBJh2ZkouNyyu)cpDcYOIfs3oOeO64KBb7r5qv7hCPqTcddbt1Jq4djhRZxBGMMulqHipYWK08cBrbC5nQn3qbSwJ6weHN0e4Tg1gs5(QVqggKNc3O(fExZJobzurLobzuLteHhWV7aV1O6al40YiDlcpY(qav3gpSNvCOoXWO(fE6eKrflKwwucuDCYTG9OCOQ9dUuOwHHHGP6ri8HKJ15RnqttQfOqKhzysAEHTOaU8g1MBOawRrDZNLVvWXa1gs5(QVqggKNc3O(fExZJobzurLobzuLJplFRGJbQoWcoTms3IWJSpeq1TXd7zfhQtmmQFHNobzuXcPL3OeO64KBb7r5qv7hCPqTcddbtTefmgRZxBGMMulqHipYWK08cBrbCX5R2QuWtrTpolPKHjPfo(lncBsXtUfSNyeRTEecFi5qTpolPKHjPfo(lncBsDmychlrt49BuBUHcyTg1LOGXGAdPCF1xiddYtHBu)cVR5rNGmQOsNGmQTBuWyq1bwWPLr6weEK9HaQUnEypR4qDIHr9l80jiJkwiT8akbQoo5wWEuou1(bxkuRWWqWu9ie(qYX68vBS8beUSWEQEm24klzpeEYECSZnqttQfOqKhzysAEHTOaU481gOPjfWrAiwtARJhJskfWfIrSxBGMMulqHipYWK08cBrDmychRljkNvEgCrvqqMScspKDz7q49BNEEd00K6sImoyNPSv2x1EIWzBBGMMuXwal(YcgdfWL3O2CdfWAnQw44V0iSPL0e4Tg1gs5(QVqggKNc3O(fExZJobzurLobzuv44V0iSP8Yc43DG3AuDGfCAzKUfHhzFiGQBJh2ZkouNyyu)cpDcYOIfs)qaLavhNClypkhQA)GlfQvyyiyQEecFi5yD(ILpGWLf2t1JXgxzj7HWt2JJDUbAAsbCKgI1K264XOKsbCXzpcHpKCOwGcrEKHjP5f2I6yWeowIUfH3O2CdfWAnQw44V0iSPL0e4Tg1gs5(QVqggKNc3O(fExZJobzurLobzuv44V0iSP8Yc43DG3Aa)VEEJQdSGtlJ0Ti8i7dbuDB8WEwXH6edJ6x4PtqgvSq6NhucuDCYTG9OCOQ9dUuOwHHHGP6ri8HKJ15RxTvPGNIY8cIKhYfGcltXtUfSNye71bCyx2Y5bCGDYLqs(O6aVJNYLTK3VF7STkf8uugzjLp4yqAR4aP4j3c2)g1MBOawRrn2cyXxwWyqTHuUV6lKHb5PWnQFH318OtqgvuPtqgv5XTaw8LfmguDGfCAzKUfHhzFiGQBJh2ZkouNyyu)cpDcYOIfs)0cLavhNClypkhQA)GlfQTvPGNIAFCwsjdtslC8xAe2KINClyVZ2EvPGNIYilP8bhdsBfhifp5wWENBGMMuhdgNLfS1skjCk(OaU8g1MBOawRrTNcbz2lymKcOTq1TXd7zfhQtmmQFH318OtqgvuPtqg1gPqa4VzVGXa4x(H2c1MNHf1jb527cfc2aWV7xylId43Gh(GDxGQdSGtlJ0Ti8i7dbuBiL7R(czyqEkCJ6x4Ptqgvfc2aWV7xylId43Gh(GDSq6hIcLavhNClypkhQA)GlfQvk4PO2hNLuYWK0ch)LgHnP4j3c27SnFuu7JZskzysAHJ)sJWMufSVcogO2CdfWAnQ9uiiZEbJHuaTfQUnEypR4qDIHr9l8UMhDcYOIkDcYO2ifca)n7fmga)Yp0wa(F98g1MNHf1jb527cfc2aWV7xylId4FhwxGQdSGtlJ0Ti8i7dbuBiL7R(czyqEkCJ6x4Ptqgvfc2aWV7xylId4FhwSq6h5jkbQoo5wWEuou1(bxkuRuWtrTpolPKHjPfo(lncBsXtUfS3PpkQ9XzjLmmjTWXFPrytQc2xbhduBUHcyTg1EkeKzVGXqkG2cv3gpSNvCOoXWO(fExZJobzurLobzuBKcbG)M9cgdGF5hAla)VA9g1MNHf1jb527cfc2aWV7xylId4Fhwa)fSVcogUavhybNwgPBr4r2hcO2qk3x9fYWG8u4g1VWtNGmQkeSbGF3VWwehW)oSa(lyFfCmWcPFicucuDCYTG9OCOQ9dUuOwPGNIYilP8bhdsBfhifp5wWENBGMMuhdgNLfS1skjCk(OaU4STkf8uu7JZskzysAHJ)sJWMu8KBb7rT5gkG1Au7PqqM9cgdPaAluDB8WEwXH6edJ6x4Dnp6eKrfv6eKrTrkea(B2lyma(LFOTa8)IOEJAZZWI6KGC7DHcbBa439lSfXb8Byb8xW(k4y4cuDGfCAzKUfHhzFiGAdPCF1xiddYtHBu)cpDcYOQqWga(D)cBrCa)gwa)fSVcogyHfQA)GlfQyHi]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170507.220005, [[b4vmErLxtvKBHjgBLrMxI51uofwBL51utLwBd5hygj3BZrNo(bgCYv2yV1MyHrNxtjvzSvwyZvMxojdmXCdm1aJnUeJxtnfCLnwAHXwA6fgDP9MBE5Km1eJxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51udHwzJTwtVzxzTvMB05LyEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51usvgBLf2CL5LtYatm3edmEnvsUrwAJfgDVjNxt52BUvMxt10BK5uyTvMxt5fDErNxtn1yYLgC051uErNxEb]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170507.220005, [[d0t4jaGEbPSjrj7suTnbjTpbPADcs0Sjz(IsDtbEnr8nfYPrzNISxQDl1(jf)KaPHPGXruHdrG6YqdMuA4kLdcIofrvhJuDoIkQfcclvOSyLSCu9qqYtrwgr55e6WsMQc1KbmDvDrLQMhrLEgbIRlKnkk0wbP2mOA7cvFKOI8vrbttqcFxqnsrrEmqJMi9xq5KeWNjORjkQZRuzucIFRYTv0w3JnTVRLcb8YuQMOjInHsJ2mYpXpuQrRqrnAFgOewl0umuHLi6KSb9rdzEiuZ1nrBiiRuSqRE21ojlZ6MGe8zxl6XoP7XM231sHagcteiNT9MwrWHNZa3b7l11I5CCwSwuU65zoRVuy)5mWDW(sDTyo21sHaMGCXuSFNj48t8Hj(CMe0eusrqjbxCCI97LPGda6INQjAYuQMOPmYpXxJw65mjOPyOclr0jzd6J0hmjqdWaR)4M6RrtbhqQMOj)ojZJnTVRLcbmeMcoaOlEQMOjtPAIMIHZJlIkuuuJ2mW6h5MIHkSerNKnOpsFWeKlMI97mXX5XfrfkkclmRFKBsGgGbw)Xn1xJMGskckj4IJtSFVmfCaPAIM87KG4XM231sHagcteiNT9MemW95W5N4ddogh55pducRfAcYftX(DMKEHvSwiSLQeFtqjfbLeCXXj2VxMcoaOlEQMOjtPAIMY0fwXAHA0cHQeFtXqfwIOtYg0hPpysGgGbw)Xn1xJMcoGunrt(Dku4XM231sHagcteiNT9MwrWHNZztmpAllbhYkco88BPypYRNDDE0wwf4ZIJWWgNmuuUYK3eKlMI97mj9cRyTqylvj(MGskckj4IJtSFVmfCaqx8unrtMs1enLPlSI1c1Ofcvj(A0gIU8MIHkSerNKnOpsFWKanadS(JBQVgnfCaPAIM87uM9yt77APqadHjcKZ2Et)juOcZbVtbCHBXScjeb)Lc7pho)cnSHTfPeXCSRLcbYo7q4rnkxzzXJAgiSTlmYZbJ4CSF5ktoKxE5nb5IPy)ot3sXEKxp7AtqjfbLeCXXj2VxMcoaOlEQMOjtPAIMe0LI9iVE21MIHkSerNKnOpsFWKanadS(JBQVgnfCaPAIM87uO6XM231sHagcteiNT9M4rng6cs2zVIGdpxctPyTqyZcukRX8OTSZEfbhE(TuSh51ZUopAZeKlMI97mDlf7rE9OjOKIGscU44e73ltbha0fpvt0KPunrtc6sXEKxpAkgQWseDs2G(i9btc0amW6pUP(A0uWbKQjAYVtJ8yt77APqadHjcKZ2Et8OMbcB7cJ8CWioh7p0LJHSZoKveC453sXEKxp768OTSe8kco8CjmLI1cHnlqPSgZJ2K3eKlMI97mbNFIpmXNZKGMGskckj4IJtSFVmfCaqx8unrtMs1enLr(j(A0spNjb1OneD5nfdvyjIojBqFK(GjbAagy9h3uFnAk4as1en53j5WJnTVRLcbmeMcoaOlEQMOjtPAIMe0LI9iVEuJ2q0L3umuHLi6KSb9r6dMGCXuSFNPBPypYRhnjqdWaR)4M6RrtqjfbLeCXXj2VxMcoGunrt(Dso7XM231sHagcteiNT9M4rnde22fg55GrCo2VChnKLGxrWHNlnQfICwlegpQryHXA768OntqUyk2VZK0J3Wo4WcZ6h5MGskckj4IJtSFVmfCaqx8unrtMs1enLPJ3A0EW1OndS(rUPyOclr0jzd6J0hmjqdWaR)4M6RrtbhqQMOj)oPp4XM231sHagctbha0fpvt0KPunrtYjvbYkLgTqceVAq0umuHLi6KSb9r6dMGCXuSFNjHQcKvkyfq8Qbrtc0amW6pUP(A0eusrqjbxCCI97LPGdivt0KFN019yt77APqadHPGda6INQjAYuQMOPmYpXxJw65mjOgTHitEtXqfwIOtYg0hPpycYftX(DMGZpXhM4Zzsqtc0amW6pUP(A0eusrqjbxCCI97LPGdivt0KFN0L5XM231sHagcteiNT9M(tOqfMdENc4c3IzfIGxrWHNlnQfICwlegpQryHXA768On5nb5IPy)otsJAHiN1cHXJAewyS2U2eusrqjbxCCI97LPGda6INQjAYuQMOPmf1croRfQrBSOg1OndyTDTPyOclr0jzd6J0hmjqdWaR)4M6RrtbhqQMOj)oPliESP9DTuiGHWebYzBVP)ekuH5G3PaUWTOjixmf73zcNBxyKdJh1iSWyTDTjOKIGscU44e73ltbha0fpvt0KPunrt7NBxyKRrBSOg1OndyTDTPyOclr0jzd6J0hmjqdWaR)4M6RrtbhqQMOj)(nrGC22BYVn]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170507.220005, [[d4JVmaGEQuQ2eezxOY2qvu7dLQtJ03qGztP5JcDti8yiDBQ68OGDIO9c2TI9tL8tufXWuQghQI0RPcpNObtfnCu0brv6uqHJrrNJkLSquklfbTyOA5cpKq6PKwMsX6OsPCzvtLqmzLmDjxKc8xcEgvQCDc1grvWwPG2muA7qrFgH(kQcnnQu18Oq1iPqPVJQA0OKdl1jPqoKsjxtPu3Jkf)w0XPqXOGOgmbra1GPXTFb4Gs2(dQs9I6YjpePSCBUCINsqj823YdKB2njyF7DEMZeuL5rPTL627IMdqUzBtq5fTO5ibrastqeqnyAC7xaBGQObLzbA12pfhfLbHQT5i5(042VqcxmwSCuugeQ2MJKlUVPJ04MCBJeAM2vYF4WJ3flHeRGKoROjMYMlUVPJKDEguEXPwAXaOyJuwcYkOooOIY6OoqKyE)NcWbfrUmSdY2FqbLS9huEisz5YPwb1XbLWBFlpqUz3KaZDqnAwu0UYa0jNdkICr2(dkua5gqeqnyAC7xaBGQObLzbA12pfhXUy9GoefKvgEUpnU9lq5fNAPfdGg3NH82lLc8Pt9aurzDuhismV)tb4GIixg2bz7pOGs2(dkH3NH82lLUCYJ0PEakH3(wEGCZUjbM7GA0SOODLbOtohue5IS9huOas3bIaQbtJB)cydufnOmlq3ALfh2iLLa2J5dUII6GoebLxCQLwmakRKVLoefWTTSa1Ozrr7kdqNCoOiYLHDq2(dkOKT)GASjFlDi6YjB2wwGYBqucA1bXxcuSUzRvwCyJuwcypMp4kkQd6qeucV9T8a5MDtcm3bvuwh1bIeZ7)uaoOiYfz7pOqbKUhebudMg3(fWgOkAqzwGwjrI2ZHMPDL8hjsihIhkQaZK)douXr8Py3nBVJeYBDJrmLjZV4qZbZhe)GEHeRa2UUKrgrZ0Us(dhlXdXh0HOqiEUa)3mZHlUVPJ04M7yGbO8ItT0IbqXJ3flHeRGKoROjMYgurzDuhismV)tb4GIixg2bz7pOGs2(dkBX7ILlNjwxov6SIMykBqj823YdKB2njWChuJMffTRmaDY5GIixKT)GcfqUnicOgmnU9lGnqv0GYSanepuubMj)hCOIJ4tXUBCRDKKVeWZrSKROpmDlb3ZeL9Dq5fNAPfdGInszjiRG64GkkRJ6arI59Fkahue5YWoiB)bfuY2Fq5HiLLlNAfuh3LtKnXaucV9T8a5MDtcm3b1Ozrr7kdqNCoOiYfz7pOqbK8micOgmnU9lGnqv0GYSafxmwSCb1FoXmr6gJyktMFXX8H8y(Oh0lKyfkwx445i47OyiaLxCQLwmaACFgYBVukWNo1dqfL1rDGiX8(pfGdkICzyhKT)Gckz7pOeEFgYBVu6YjpsN6HlNiBIbOeE7B5bYn7MeyUdQrZII2vgGo5CqrKlY2FqHcijaebudMg3(fWgOkAqzwGIlglwUG6pNyMiH8klU4(mK3EPuGpDQhCff1bDiYiJOzAxj)HlUpd5Txkf4tN6bxCFthj7MCBZiJiV1ngXuMm)IJ5d5X8rpOxiXkuSUWXZrW3rXqG0wvB)uCe7I1d6quqwz45(042VWadq5fNAPfdGYk5BPdrbCBllqfL1rDGiX8(pfGdkICzyhKT)Gckz7pOgBY3shIUCYMTLLlNiBIbOeE7B5bYn7MeyUdQrZII2vgGo5CqrKlY2FqHci5PGiGAW042Va2avrdkZc0TWfJflxq9NtmtK2c5QTFkoIDX6bDikiRm8CFAC7xiTfYOzAxj)HlUpd5Txkf4tN6bxCFthj7ByKXq8C2DpgyGuiEo7UduEXPwAXaOjULwp66GkkRJ6arI59Fkahue5YWoiB)bfuY2Fq5j4wA9ORdkH3(wEGCZUjbM7GA0SOODLbOtohue5IS9huOas3cebudMg3(fWgOkAqzwGgIhkQaZK)douXr8Py3neSZiJiJC12pfhXUy9GoefKvgEUpnU9lKqZ0Us(dxCFgYBVukWNo1dU4(MosJ7oKqZ0Us(dhE8UyjKyfK0zfnXu2CX9nDKSBUJbsH45gFBmyKrKXfJflhXUy9GoefKvgEoz1OoCJ5osOzAxj)HdpExSesScs6SIMykBU4(Mos2n3gdq5fNAPfdGInszjiRG64GkkRJ6arI59Fkahue5YWoiB)bfuY2Fq5HiLLlNAfuh3LtK3GbOeE7B5bYn7MeyUdQrZII2vgGo5CqrKlY2FqHcin3bra1GPXTFbSbQIguMfOBHlglwUG6pNyMiH8wvB)uCe7I1d6quqwz45(042VyKrKrZ0Us(dxCFgYBVukWNo1dU4(Mos23WiJH45S7EmWauEXPwAXaOjULwp66GkkRJ6arI59Fkahue5YWoiB)bfuY2Fq5j4wA9OR7YjYMyakH3(wEGCZUjbM7GA0SOODLbOtohue5IS9huOasttqeqnyAC7xaBGQObLzbkAM2vYF4WJ3flHeRGKoROjMYMlUVPJKDZTrkepuubMj)hCOIJ4tzC3qWosH45g39GYlo1slgaLvgJqIvGpDQhGkkRJ6arI59Fkahue5YWoiB)bfuY2Fqn2mgxotSUCYJ0PEakH3(wEGCZUjbM7GA0SOODLbOtohue5IS9huOasZnGiGAW042Va2avrdkZcu0mTRK)WHhVlwcjwbjDwrtmLnxCFthj7MBdkV4ulTyauSrklbzfuhhurzDuhismV)tb4GIixg2bz7pOGs2(dkpePSC5uRG64UCIS7WaucV9T8a5MDtcm3b1Ozrr7kdqNCoOiYfz7pOqbKMUdebudMg3(fWgOkAqzwGIMPDL8ho84DXsiXkiPZkAIPS5I7B6iz3ChuEXPwAXaOX9ziV9sPaF6upavuwh1bIeZ7)uaoOiYLHDq2(dkOKT)Gs49ziV9sPlN8iDQhUCI8gmaLWBFlpqUz3KaZDqnAwu0UYa0jNdkICr2(dkuqbQIguMfOqbaa]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170507.220005, [[d4JHnaGEfrvBIuAxO02ueW(uezDkc0RrcZwuZxPQBcItJQVbsDEsIDII9cTBQ2pP4NkIkdtPmofrXTbCyedMKA4e6GePoLiCmf15ueQfseTufPftWYfEijPNszzKQEoO(lsnvsOjd00v1fjbhsPINPuPRRKnQikTvsL2mjA7irFxK(kiPPPiK5regjrIhRWOrsFMOojPIllDnqI7rK0Vv54kcAuIOXzur0uWjc5cIcOXqakAghqvnQNSXb)tqnQfoynQF(GcUlJ20MlbUiJ(TzO3GY2eGDgntSdojZN8KNFoYOhkZOj945NdJkImZOIOPGteYfeLenBeCXhTDaVNvzCWpTYszd2NpOG7YOjTapZFvqJ6LM5UmTqMa)OPJdYhK)c08ZlAqoqDjbdbOOHgdbOOjLlnZDznQLmtGF0KoKHr7jHCFAUsPUd49SkJd(PvwkBW(8bfCxgTPnxcCrg9BZqpVHMQu7GcihLfO(JcOb5aziafn8rg9OIOPGteYfeLenBeCXhTy58bT4L2GDSIO(pjPU7M2KjfwkvYgCGYUe12jCXffliRyd4szdIpk9PK(Pw6kConajEvIe73N8j56pRm5P2G7Y0W)faS1jc5cQnj49SrbUaU5cdtNY9VbBuac3HLqQYdW973b8E2Oaxa3CHHPt5(3G95dk4UCIejqtAbEM)QGwuGlGBUWW0PC)BGMQu7GcihLfO(JcOb5a1LemeGIgAmeGI20cCbCZfgwJAOY9VbAtBUe4Im63MHEEdnDCq(G8xGMFErdYbYqakA4Jm7IkIMcorixqus0SrWfF0sMmwoFqlEPnyhRiQ)tsQ630c3Nw48fm7ZBmpX0tK4ysBj2VpwoFqlEPnyhRiQ)tsQ7ULqRWsPs2Gdu2LiAslWZ8xf0OEPzUltlKjWpAQsTdkGCuwG6pkGgKduxsWqakAOXqakAs5sZCxwJAjZe4xJ6KZjqBAZLaxKr)2m0ZBOPJdYhK)c08ZlAqoqgcqrdFKzIqfrtbNiKlikjA2i4IpAXY5dAXlTb7yfr9xcPcnu2VpwEN0UOjTapZFvq7eY8Vb5lAQsTdkGCuwG6pkGgKduxsWqakAOXqakAtoHm)Bq(I20MlbUiJ(TzON3qthhKpi)fO5Nx0GCGmeGIg(iduqfrtbNiKlikjA2i4IpAjfwkvYgCGYUe12jCXffliRyd4szdIpk9PK(Pw6kConajEvIe73N8j56pRm5P2G7Y0W)faS1jc5cQnj49SrbUaU5cdtNY9VbBuac3HLqQYdW973b8E2Oaxa3CHHPt5(3G95dk4UCIeOjTapZFvqlkWfWnxyy6uU)nqtvQDqbKJYcu)rb0GCG6scgcqrdngcqrBAbUaU5cdRrnu5(3qJ6KZjqBAZLaxKr)2m0ZBOPJdYhK)c08ZlAqoqgcqrdFKzcGkIMcorixqus0SrWfF0ewkvYgCGYUertAbEM)QGg1lnZDzAHmb(rtvQDqbKJYcu)rb0GCG6scgcqrdngcqrtkxAM7YAulzMa)AuNuFc0M2CjWfz0Vnd98gA64G8b5Van)8IgKdKHau0WhzGgvenfCIqUGOKOzJGl(OflNpOfV0gSJve1FjGEt7oclLkzPUC5gCxMowEPtlr8C2LO2y5vcOGM0c8m)vbnQx40Ns6uU)nqtvQDqbKJYcu)rb0GCG6scgcqrdngcqrtkx4AuFk1OgQC)BG20MlbUiJ(TzON3qthhKpi)fO5Nx0GCGmeGIg(iZKbvenfCIqUGOKOzJGl(O9NSCUSJ7YGxQdRnzNWfxuSGSJZPSHC9rPpL0kjFH1MmwoFqlEPnyhRiQ)sS72(9jJLZh0IxAd2XkI6VeqVP9j56pRm5P2G7Y0W)faS1jc5cMy)(Kpjx)zPEHtFkPt5(3GTorixqTpjx)zLjp1gCxMg(VaGTorixqTXY5dAXlTb7yfr9xcOaLej0UJWsPswQlxUb3LPJLx60sepNDjQnwELqFc0KwGN5VkOrD5Yn4UmDS8sNwI45OPk1oOaYrzbQ)OaAqoqDjbdbOOHgdbOOjLLl3G7YAupD5vJAOwI45OnT5sGlYOFBg65n00Xb5dYFbA(5fnihidbOOHpYmXOIOPGteYfeLenBeCXhT)KLZLDCxg8sDyTjFsU(ZglNpOj)xFrE(5S1jc5cQnwoFqlEPnyhRiQ)sS7M2DewkvYsD5Yn4UmDS8sNwI45SlrTXYRe6tGM0c8m)vbnQlxUb3LPJLx60sephnvP2bfqoklq9hfqdYbQljyiafn0yiafnPSC5gCxwJ6PlVAud1sepxJ6KZjqBAZLaxKr)2m0ZBOPJdYhK)c08ZlAqoqgcqrdFKzEdvenfCIqUGOKOzJGl(O9NSCUSJ7YGxQdRnzSC(Gw8sBWowru)LyxOODhHLsLSuxUCdUlthlV0PLiEo7suBS8kXCc0KwGN5VkOrD5Yn4UmDS8sNwI45OPk1oOaYrzbQ)OaAqoqDjbdbOOHgdbOOjLLl3G7YAupD5vJAOwI45AuNuFc0M2CjWfz0Vnd98gA64G8b5Van)8IgKdKHau0WhzMNrfrtbNiKlikjA2i4IpA)jlNl74Um4L6WAtglNpOfV0gSJve1Fj0dfT7iSuQKL6YLBWDz6y5LoTeXZzxIAJLxj0NanPf4z(RcAuxUCdUlthlV0PLiEoAQsTdkGCuwG6pkGgKduxsWqakAOXqakAsz5Yn4USg1txE1OgQLiEUg1j3nbAtBUe4Im63MHEEdnDCq(G8xGMFErdYbYqakA4JmZ6rfrtbNiKlikjA2i4IpA)jlNl74Um4L6WAtglNpOfV0gSJve1Fj0VLanPf4z(RcAfq8sBqhlV0PLiEoAQsTdkGCuwG6pkGgKduxsWqakAOXqakAkaiEPn0OE6YRg1qTeXZrBAZLaxKr)2m0ZBOPJdYhK)c08ZlAqoqgcqrdFKzExur0uWjc5cIsIMncU4J2tY1FwzYtTb3LPH)layRteYfC)(DG7tlC(cM95nMNy6jsCmPT97JLZh0IxAd2XkI6Ve7UHM0c8m)vbTOaxa3CHHPt5(3anvP2bfqoklq9hfqdYbQljyiafn0yiafTPf4c4MlmSg1qL7FdnQtQpbAtBUe4Im63MHEEdnDCq(G8xGMFErdYbYqakA4JpA2i4IpA4Jia]] )


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170507.220005, [[deeVqaqijuweLkTjKIrPk4uQcTlQYWaLJrfltcEgOQMMeQCnqvABGQ4BiPghLk05OubRJevZtvu3Jsv7tcPdsPSqIkpKKAIQI0frs2iLkYhLqKtsImtjeUjv1ovv)Ksf1srk9uutLO4QKOSvIQ2RYFLObRkDyHftKhlQjtQldTzK4ZKWObXPr8AKQztXTL0Ub(TudNkDCvrSCcpxKPRY1PKTtu67GkJxcvDEsY6Lqu7hKEotMXubcjdQN04FuXXmPQg6RYaqAJkLd9vbcqbjpMw0Grc3VamhQHbVWGVNZyoliU34X2YhPbPjZ(otMXubcjdQNCJ5SG4EJVwHcd6L72OB4ajAEOy4tSiUUO27c6heuqobP4tLjiTLrJc3qNOrybi5s3gou4PrkKm5Eg(WECSnjIHCQgRdb9Yqiroumwnemt3VLfRi4M0y)wlFi(rfhp(hvC8tdbDOV2esKdfJPfnyKW9laZHAhyJvcOj54AXyqdWX(T(hvC8U9lmzgtfiKmOEYnMZcI7n(AfkmOxUBJUHdKO5b8jwexxu7Db9dckiNGu8PYeK2YOrHBOt0iSaKCPBdhk80ifsMCpdFy0K72OB4aE6qqV8ebirPf14inWtG1Gaspx4XX2KigYPASoe0ldHe5qXy1qWmD)wwSIGBsJ9BT8H4hvC84FuXXpne0H(Atiroua99bNhhtlAWiH7xaMd1oWgReqtYX1IXGgGJ9B9pQ44D7d)jZyQaHKb1tUXCwqCVXxRqHb9YDB0nCGenpiSa4Z2d)hhBtIyiNQXjRATbLkcHIwLbhRgcMP73YIveCtASFRLpe)OIJh)JkoMTQ1ga9TifcfTkdoMw0Grc3VamhQDGnwjGMKJRfJbnah736FuXX72V4MmJPcesgup5gZzbX9gFTcfg0l3Tr3Wbs08a(elIRlQ9UG(bbfKtqk(uzcsBz0OWn0jAYDB0nCapDiOxEIaKO0IACKg4jWAqaPNDGrJWcGpBp8FCSnjIHCQgNSQ1guQiekAvgCSAiyMUFllwrWnPX(Tw(q8JkoE8pQ4y2QwBa03Iuiu0Qmi03hCECmTObJeUFbyou7aBSsanjhxlgdAao2V1)OIJ3Tp8ozgtfiKmOEYnMZcI7nwJswuO4rbthkiafLW1waTx6Im9IAp8qtUBJUHd4fUDomQCtONaRbbKEU4gBtIyiNQXP2YukWWffJvdbZ09BzXkcUjn2V1YhIFuXXJ)rfhZTLb6lTy4IIX0Igms4(fG5qTdSXkb0KCCTymOb4y)w)JkoE3(WZKzmvGqYG6j3yoliU3ynkzrHIhfmDOGauucxBb0EPlY0lQ9WZyBsed5unoC7Cyu5MWXQHGz6(TSyfb3Kg73A5dXpQ44X)OIJT525WOYnHJPfnyKW9laZHAhyJvcOj54AXyqdWX(T(hvC8U9PEYmMkqizq9KBmNfe3BSWcqYLUnCOWtJuizY9SdSX2KigYPASgJdszUjMXQHGz6(TSyfb3Kg73A5dXpQ44X)OIJFkgheOVQBIzmTObJeUFbyou7aBSsanjhxlgdAao2V1)OIJ3TVDCYmMkqizq9KBmNfe3BCXUWGGZthc6LHqICOWdbHKb10izrHIxYsRrqPU7QNLlnftYIcfpaMfDIK8SCPrybWNTh(JTjrmKt1ynghKYCtmJvdbZ09BzXkcUjn2V1YhIFuXXJ)rfh)umoiqFv3ed03hCECmTObJeUFbyou7aBSsanjhxlgdAao2V1)OIJ3TVDyYmMkqizq9KBmNfe3B8fgeCE6qqVmesKdfEiiKmOMgjlku8swAnck1Dx9SCPj3Tr3Wb80HGEziKihk8eyniGurHxAewa8z7H)yBsed5unwJXbPm3eZy1qWmD)wwSIGBsJ9BT8H4hvC84FuXXpfJdc0x1nXa99HcpoMw0Grc3VamhQDGnwjGMKJRfJbnah736FuXX723b2KzmvGqYG6j3yoliU3ynkzrHIhfmDOGauucxBb0EPlY0FgEOj3Tr3Wb8c3ohgvUj0tG1GaspBp8m2MeXqovJPGPdfeGIY0ji0XXQHGz6(TSyfb3Kg73A5dXpQ44X)OIJTty6qbbOa6lFccDCmTObJeUFbyou7aBSsanjhxlgdAao2V1)OIJ3TVJZKzmvGqYG6j3yoliU3ynkzrHIhfmDOGauucxBb0EPlY0lQ9WFSnjIHCQgNAltPadxumwnemt3VLfRi4M0y)wlFi(rfhp(hvCm3wgOV0IHlkG((GZJJPfnyKW9laZHAhyJvcOj54AXyqdWX(T(hvC8U9DkmzgtfiKmOEYnMZcI7nwJswuO4LAltPadxu4z5stX0OKffkEuW0HccqrjCTfq7z5o2MeXqovJPGPdfeGIY0ji0XXQHGz6(TSyfb3Kg73A5dXpQ44X)OIJTty6qbbOa6lFccDe67dopoMw0Grc3VamhQDGnwjGMKJRfJbnah736FuXX723b(tMXubcjdQNCJ5SG4EJ1OKffkEP2YukWWffEwU0Orjlku8OGPdfeGIs4AlG2lDrMErT3zSnjIHCQgNYTLqbwMobHoownemt3VLfRi4M0y)wlFi(rfhp(hvCmNBlHce6lFccDCmTObJeUFbyou7aBSsanjhxlgdAao2V1)OIJ3TVtXnzgtfiKmOEYnMZcI7nwJswuO4LAltPadxu4z5sJgLSOqXJcMouqakkHRTaAV0fz6f1ENX2KigYPAC2eWrakktqcDdxASAiyMUFllwrWnPX(Tw(q8JkoE8pQ4y1Maocqb0xgsOB4sJPfnyKW9laZHAhyJvcOj54AXyqdWX(T(hvC8U9DG3jZyQaHKb1tUX(Tw(q8JkoE8pQ44NIuigCSsanjhxlgdAao2MeXqovJ1ifIbhRgcMP73YIveCtAmTObJeUFbyou7aBSFR)rfhVBFh4zYmMkqizq9KBmNfe3BCKpISyjcWkbtf1(cJTjrmKt14CymLr(inO0qs3yLaAsoUwmg0aCSFRLpe)OIJh)JkowDymqFTLpsdG(weK0n2MqrAmiQO92Ljv1qFvgasBuPCOV2SZuz3X0Igms4(fG5qTdSXQHGz6(TSyfb3Kg736FuXXmPQg6RYaqAJkLd91MDMQD77q9KzmvGqYG6j3yoliU3y8jwexxu7DqWsciDcR81IujL2sCqknyk1GX2KigYPAComMYiFKguAiPBSsanjhxlgdAao2V1YhIFuXXJ)rfhRomgOV2YhPbqFlcs6G((GZJJTjuKgdIkAVDzsvn0xLbG0gvkh6lbKoHv(ArYUJPfnyKW9laZHAhyJvdbZ09BzXkcUjn2V1)OIJzsvn0xLbG0gvkh6lbKoHv(ArA3(o2XjZyQaHKb1tUXCwqCVXf7cdcoVCKoII4AHhccjdQPPy4tSiUUO27GGLeq6ew5RfPskTL4GuAWuQbJTjrmKt14CymLr(inO0qs3yLaAsoUwmg0aCSFRLpe)OIJh)JkowDymqFTLpsdG(weK0b99Hcpo2MqrAmiQO92Ljv1qFvgasBuPCOVPla6qOT7yArdgjC)cWCO2b2y1qWmD)wwSIGBsJ9B9pQ4yMuvd9vzaiTrLYH(MUaOdHE3(o2HjZyQaHKb1tUXCwqCVXxyqW5LJ0ruexl8qqizqnnfdFIfX1f1EheSKasNWkFTivsPTehKsdMsnySnjIHCQgNdJPmYhPbLgs6gReqtYX1IXGgGJ9BT8H4hvC84FuXXQdJb6RT8rAa03IGKoOVpa)hhBtOingev0E7YKQAOVkdaPnQuo03CKoII4AHDhtlAWiH7xaMd1oWgRgcMP73YIveCtASFR)rfhZKQAOVkdaPnQuo03CKoII4AXUDJzxmtcdPihhPb7xaElSBda]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170507.220005, [[dmeaqaqiOuSisrAtKkgfb4ueq3IueTlfAyqXXuWYaKNrkQPbufxdOY2aQQVbPmoOu5CavjRdkvnpsL4EqP0(ivQdkuTqivpeqnrcQUibAJee1jjbZKueUPq2je)KGinucIyPqjpf1ujvDvccBLe6RavP2RQ)cWGjjhMYIj0JHQjt0Lr2Sq5ZKuJgiNg0Rfy2u52u1UL63IgUGoobLLR0Zv00LCDiz7aLVtkmEcsNNuA9KkP9tI(dx)zbBt0rYlEgX80zg6bwPkHObLoTyVsvskMHYvNXICKnPJaeMb0WaomAEC4mJVWW68544fm751FKHR)SGTj6i5r)mJVWW6CLQv7Oryx0UOcR554IqhS0E2dBjGylr6kDgyqeEqucg5PUU45OuQOTiMNoFgX805iylvQsiVePR0zSihzt6iaHzaTbmNvOLqCRY9CNnDokLiMNo)6iaD9NfSnrhjp6Nz8fgwNRuTAhnINPtMA0tDeWIQH4actnODusXG4Ws3aHrGNJlcDWs7zBXTMau5UuxNbgeHheLGrEQRlEokLkAlI5PZNrmpDo(IBnPuL(CxQRZyroYM0racZaAdyoRqlH4wL75oB6CukrmpD(1r081FwW2eDK8OFMXxyyDUs1QD0iEMozQrpphxe6GL2ZIUmLaIHA1EgyqeEqucg5PUU45OuQOTiMNoFgX80z0DzkvQsiJA1EglYr2KocqygqBaZzfAje3QCp3ztNJsjI5PZVoc456plyBIosE0pZ4lmSoxPA1oAeptNm1ONNJlcDWs7zrAN0gaB1NbgeHheLGrEQRlEokLkAlI5PZNrmpDgDAN0gaB1NXICKnPJaeMb0gWCwHwcXTk3ZD205OuIyE68RJaUR)SGTj6i5r)mJVWW6CLQv7OXWSGzp1raIOIfBevdkDAbmRLA1fOruHc8CCrOdwAphMfm7ZadIWdIsWip11fphLsfTfX805ZiMNolKKfm7ZyroYM0racZaAdyoRqlH4wL75oB6CukrmpD(1ra)R)SGTj6i5r)mJVWW6m2iZAem4IYrDbi0zQrrJfepa2Qphxe6GL2ZjQsCjl4ScTeIBvUN7SPZrPurBrmpD(mI5PZcPOkXLSGZXx1ZZLTQPcamg2InYSgbdUOCuxacDMAu0ybXdGT6ZyroYM0racZaAdyodmicpikbJ8uxx8CukrmpD(1rq76plyBIosE0pZ4lmSotcdfmmKKJLfuGOfwluOtatqjkNK2qto1bptNm1OhL2gaWwryr74sEd2tDpa(G7CCrOdwAplTnaqTwpJLR3ky2NbgeHheLGrEQRlEokLkAlI5PZNrmpDw42gOuL(16zSC9wbZ(mwKJSjDeGWmG2aMZk0siUv5EUZMohLseZtNFDeS76plyBIosE0pZ4lmSotcdfmmKKJLfuGOfwluOtatqjkNK2qto1bBkZrDnobzYudaWogQjm7rQnrhj1bptNm1OhL2gaWwryr74sEd2tDdoWDoUi0blTNL2gaOwRNXY1Bfm7ZadIWdIsWip11fphLsfTfX805ZiMNolCBduQs)A9mwUERGzRuLage4zSihzt6iaHzaTbmNvOLqCRY9CNnDokLiMNo)6iGxx)zbBt0rYJ(zgFHH1zsyOGHHKCSSGceTWAHcDcyckr5K0gAYPoL5OUgNGmzQbayhd1eM9i1MOJK6GNPtMA0JsBdayRiSODCjVb7PU1m4ohxe6GL2ZsBdauR1Zy56TcM9zGbr4brjyKN66INJsPI2IyE68zeZtNfUTbkvPFTEglxVvWSvQsaajWZyroYM0racZaAdyoRqlH4wL75oB6CukrmpD(1rgWC9NfSnrhjp6Nz8fgwNjHHcggsYXYckq0cRfk0jGjOeLtsBOjN6u2QMQXc6javcqcjDbptNm1OhL2gaWwryr74sEd2tnj2DoUi0blTNL2gaOwRNXY1Bfm7ZadIWdIsWip11fphLsfTfX805ZiMNolCBduQs)A9mwUERGzRuLa0SapJf5iBshbimdOnG5ScTeIBvUN7SPZrPeX805xhzy46plyBIosE0pZ4lmSotcdfmmKKJLfuGOfwluOtatqjkNK2qto1bptNm1OhNO8(SbO2w1PwhnUK3G9u3dGpMZXfHoyP9S02aa1A9mwUERGzFgyqeEqucg5PUU45OuQOTiMNoFgX80zHBBGsv6xRNXY1BfmBLQea4rGNXICKnPJaeMb0gWCwHwcXTk3ZD205OuIyE68RJma01FwW2eDK8OFMXxyyDMegkyyijhllOarlSwOqNaMGsuojTHMCQd2uMJ6ACcYKPgaGDmuty2JuBIosQdEMozQrpor59zdqTTQtToACjVb7PUbh4ohxe6GL2ZsBdauR1Zy56TcM9zGbr4brjyKN66INJsPI2IyE68zeZtNfUTbkvPFTEglxVvWSvQsaGtGNXICKnPJaeMb0gWCwHwcXTk3ZD205OuIyE68RJmO5R)SGTj6i5r)mJVWW6mjmuWWqsowwqbIwyTqHobmbLOCsAdn5uNYCuxJtqMm1aaSJHAcZEKAt0rsDWZ0jtn6XjkVpBaQTvDQ1rJl5nyp1TMb354IqhS0EwABaGATEglxVvWSpdmicpikbJ8uxx8Cukv0weZtNpJyE6SWTnqPk9R1Zy56TcMTsvca8f4zSihzt6iaHzaTbmNvOLqCRY9CNnDokLiMNo)6idGNR)SGTj6i5r)mJVWW6mjmuWWqsowwqbIwyTqHobmbLOCsAdn5uNYw1unwqpbOsasiPl4z6KPg94eL3Nna12Qo16OXL8gSNAsS7CCrOdwAplTnaqTwpJLR3ky2NbgeHheLGrEQRlEokLkAlI5PZNrmpDw42gOuL(16zSC9wbZwPkbGMapJf5iBshbimdOnG5ScTeIBvUN7SPZrPeX805xhzaCx)zbBt0rYJ(zgFHH1zSHegkyyijhllOarlSwOqNaMGsuojTHMCQZIQjDbB1854IqhS0EwABaGATEglxVvWSpdmicpikbJ8uxx8Cukv0weZtNpJyE6SWTnqPk9R1Zy56TcMTsvca7e4zSihzt6iaHzaTbmNvOLqCRY9CNnDokLiMNo)6idG)1FwW2eDK8OFMXxyyDEr1KUGTA(CCrOdwApl6GQbvKeWIQjaAqwy2NbgeHheLGrEQRlEokLkAlI5PZNrmpDgDhunOIKkvHfQMuQc8MSWSpJf5iBshbimdOnG5ScTeIBvUN7SPZrPeX805xhzaTR)SGTj6i5r)mJVWW6CzoQRrPTbaSvew0osTj6iPoHuncM5c0UaeTQCK3GsQhn8ccgDoUi0blTNxunadVGzdWbN1zfAje3QCp3ztNJsPI2IyE68zeZtNXcvRuvC8cMTsvAc4SohFvpp3MNWwnLHEGvQsiAqPtl2RufyMlq7QPNXICKnPJaeMb0gWCgyqeEqucg5PUU45OuIyE6md9aRuLq0GsNwSxPkWmxG291rgWUR)SGTj6i5r)CCrOdwApJBohadVGzdWbN1zfAje3QCp3ztNJsPI2IyE68zeZtNb2CoLQIJxWSvQstaN154R65528e2QPm0dSsvcrdkDAXELQutnTqCn9mwKJSjDeGWmG2aMZadIWdIsWip11fphLseZtNzOhyLQeIgu60I9kvPMAAH4VEDMdjCO5G6QvWSpcqGdOx)a]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170507.220005, [[d8spcaGEkkTliPxdrnBPCtk52IStQSxYUrSFuyyuQFlzOuumyi1WLkheL6yuyHqILIswmuTCv1dfvEQYJvL1HIYePQ0uPitgvtxLlkkDvuuDzWwrr2mey7qOplQ67qqpNQCyHrdLwMu1jHiNgPRrr15HIVjkEgvf)LQQLHmPLLe4nGlCnxKaTrt5yGM5eSvddZyGU7dVkHhNglObHhixVTrgBZT9bvdT9(0UttJ97OfXtMKZqM0Ysc8gWfkA79PDN2v5Z3au7QJwepn240g9WO1vhTiA5WcpKTkeHeqoHRzvCMIVlsGMMlsGMzQJwenwqdcpqUEBJmg2Air40xC1xJueqZQ4UibA6KRxM0Ysc8gWfkAwfNP47IeOP5IeOXkOEad0(cbxdjcN(IR(AKIaASXPn6Hr7hupWphcUwoSWdzRcribKt4ASGgeEGC92gzmS1SkUlsGMo58rM0Ysc8gWfkA79PDN2v5Z3auFv14fcjEASXPn6Hrl(jm(le4)Wc(5qW1YHfEiBvicjGCcxZQ4mfFxKannxKan2)eggOleWa9HfyG2xi4ASGgeEGC92gzmS1qIWPV4QVgPiGMvXDrc00PtBDWJgnQzJJwe56nVxNe]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170507.220005, [[dWtGfaGELcAtsjYUiuBtkPAFefAMsjXSf6MKYZLQBROdlzNISxQDdA)OQ(PsrnmL43i9nf48OKbJkgUs1bjKtjLOoMuCAelefzPOGftWYfSiLI8uvlJOADeLmrPKYuLsnzsMoWfjvUQucxg66OsBKOGTIcTzL02vqJtPqFNu10ukW8ik6XI6zeLA0Ok)LiDsuuFgL6AkLCpLs9qI41k0OKss7g32xhSeIOYc(PAI(NmLWNtlG8OrwYIpNHvCKvWNbmIvhDs(sZGLTwKT4g)NdKDGVVOmGqHD32Pg32xhSeIOYm5RrvmwHunrF)unr)wdlap(CKqjrFMHksUa0GpKcrFrcKibWYxHfGN0mLe9LWdZJA0H4eHal4ZagXQJojFPzqZIVgvLQj6BGtYDBFDWsiIkZK)ZbYoWxHcCxxfVIDagiq2s1t5cvI7GkpU9g9fjqIeal)ANMRiR9o6lHhMh1OdXjcbwWxJQyScPAI((PAI(I2P5kYAVJ(mGrS6OtYxAg0S4ZmurYfGg8Hui6RrvPAI(g4KSDBFDWsiIkZK)ZbYoWxHcCxxfVIDagiq2s1t5cvI7GkpkZn2szknQO6HIRDAUIS27O4aolcSlZT8fjqIeal)vSdWabYwAheiJOVeEyEuJoeNieybFnQIXkKQj67NQj6ldyhGbcKnFoheiJOpdyeRo6K8LMbnl(mdvKCbObFifI(AuvQMOVboTbUTVoyjerLzY)5azh4xzazikfH4KGDzCB5(IeircGLFUIrPvgqOqPrsh4ZmurYfGg8Hui6RrvmwHunrF)unrFjvmYNJOmGqH850kKoWxuGD3hwtC7nDYucFoTaYJgzjl(CeTzDBYNbmIvhDs(sZGMfFj8W8OgDioriWc(AuvQMO)jtj850cipAKLS4Zr0M1zGtB52(6GLqevMj)NdKDGVcf4UUkEf7amqGSLQNYfQe3bvEuMBlBFrcKibWYFf7amqGSL2bbYi6lHhMh1OdXjcbwWxJQyScPAI((PAI(Ya2byGazZNZbbYiYNtR20Y(mGrS6OtYxAg0S4ZmurYfGg8Hui6RrvPAI(g4uR72(6GLqevMj)NdKDGVcf4UUkEf7amqGSLQNYfQeZD3xKajsaS87zk3aBuAheiJOVeEyEuJoeNieybFnQIXkKQj67NQj6)mLBGnYNZbbYi6ZagXQJojFPzqZIpZqfjxaAWhsHOVgvLQj6BGtdCBFDWsiIkZK)ZbYoWxHcCxxfVIDagiq2s1t5cvI5U7lsGejaw(5yPNazlTZRuu9DFj8W8OgDioriWc(AufJvivt03pvt0xsS0tGS5Z58kfvF3NbmIvhDs(sZGMfFMHksUa0GpKcrFnQkvt03ad8)oMjvKSHfGqHojFl5gyd]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170507.220005, [[dCtdeaGEIKAtePSlI41iX(qsMnKMpjv3uKUnP2Pu2l1UHA)IQ(jrcdtQ63egSuPHdrhueDkvsDmrzHiLwQkLftulhfpuu5PGLPcRJirtKKutvQyYiMUQUik1vjsYLvUorQEoj2ksQnts02rQoSW3uP6ZIW3jPCEuYPLmAi8xv0jrkEmQUMkH7PsY0ijzuQe9msc7m3XaBCiJoILn0c9maLox(UsfgHaLLuMVBsPGTHBdDHYC7Op7E)f9QqsMbGZuiFdgsY)sGvCh3YChdSXHm6iMwdaNPq(gc(x035WtxtHQRomKuUqRNLbYIhXzGjNKXdwgYHyCkPc6tp8BzdPcc1btl0ZGHwONbvV4rKVBGj57Q6XdwgUn0fkZTJ(S7z9gObtkE8cgdybEgsfKwONb)UD4ogyJdz0rmTgaotH8ne8VOVZHNUMcvQYqs5cTEwggYImDXnKdX4usf0NE43YgsfeQdMwONbdTqpdSrwKPlUHBdDHYC7Op7EwVbAWKIhVGXawGNHubPf6zWVBQWDmWghYOJyAnaCMc5Bi4FrFNdpDnfQU6qAxseVeYIhXzGjNKXdws(ItPWjuxDI4LqMkl0j5loLcN4AdjLl06zzqHlKotIDQ8mfLzihIXPKkOp9WVLnKkiuhmTqpdgAHEgaUq6mjw(UWZuuMHBdDHYC7Op7EwVbAWKIhVGXawGNHubPf6zWVBQYDmWghYOJyAnaCMc5Bi4FrFNdpDnfQU6qAxseVeYIhXzGjNKXdws(ItPWjuxDI4LqMkl0j5loLcN4AdjLl06zzGJgQv4eNkicIqnfd5qmoLub9Ph(TSHubH6GPf6zWql0Zqo0qTcNiFxarqeQPy42qxOm3o6ZUN1BGgmP4XlymGf4zivqAHEg872fUJb24qgDetRbGZuiFdb)l67C4PRPq1HHKYfA9SmmKfz6IBihIXPKkOp9WVLnKkiuhmTqpdgAHEgyJSitx88DVm7Ad3g6cL52rF29SEd0GjfpEbJbSapdPcsl0ZGF)gaKJxbAj1XxcSBhxC43g]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170507.220005, [[dStelaGEeu0MOu2fs2gckSpPuZwKBkkNwvFdvYTrQDc0Ev2Tk7NsAusj9xQyCuPQ8yQ68iWGPunCuXbjvCkeKJHQohcQAHKkTuePfdy5O8qQKNsSmkX6OsvAIuKAQiIjtY0LCruPUkvQQUm01jLnsLQyRueBMcBNuvddrDyHPHGkFhHoefjZdbLgTO6zuPYjjv5ZuuxtkX9Os55s1RLIFd6XpsMW9fajunGjIN9CQjteoO)J0tyg1dVbAPfltifty0XbAHmpxKBHClu8tifdfbK804eM2HDQ6PrNc6yzIo(6HxFKmq(rYeUVaiHQP7eXZEo1efcOzyqzG9cz)z2Hiu7uu9k8new3CNnM29EhoqIiJsHgV)R28UBIoaF6lcMyG9cz)z2PxSVbN4kh9nzq9rA8QbmjdQmjyGbnozcyqJtCpyVq2FMTAxk23Gtifty0XbAHmpx8KNO3PEFuq2KdE4KmOcmOXjRgOLrYeUVaiHQP7eXZEo1etbOzyqDONb7FNsJJTks4vuh6zW(3PWlasOYgt7qcRBUBIoaF6lcMOWOYD8WpnXvo6BYG6J04vdysguzsWadACYeWGgNyAmQCR2Db)0esXegDCGwiZZfp5j6DQ3hfKn5GhojdQadACYQb6UrYeUVaiHQP7eXZEo1eanddQd9my)7uACSPqanddkdSxi7pZoeHANIQxHVPTB82yA37D4ajImkfA8(VAZ3YeDa(0xemP7HAmZOtVyFdoXvo6BYG6J04vdysguzsWadACYeWGgNiEOgZmA1UuSVbNqkMWOJd0czEU4jprVt9(OGSjh8WjzqfyqJtwnqc3izc3xaKq10DI4zpNAcGMHb1HEgS)Dkno2uiGMHbLb2lK9NzhIqTtr1RW302nEBmT79oCGergLcnE)xT55NOdWN(IGj(uq8pZo98qbj2N4kh9nzq9rA8QbmjdQmjyGbnozcyqJtCLcI)z2QDjpuqI9jKIjm64aTqMNlEYt07uVpkiBYbpCsgubg04KvdSLrYeUVaiHQP7eXZEo1eanddkTlhMiWPxm8mx5uACSPqanddkdSxi7pZoeHANIQxHVPTB82yA37D4ajImkfA8(VAZ3YeDa(0xemP7HAmZOtVyFdoXvo6BYG6J04vdysguzsWadACYeWGgNiEOgZmA1UuSVbTAVvEcnHumHrhhOfY8CXtEIEN69rbzto4HtYGkWGgNSAGegJKjCFbqcvt3jIN9CQjaAgguAxomrGtVy4zUYP04ytHaAggugyVq2FMDic1ofvVcFtB34TX0U37Wbsezuk049F1MNFIoaF6lcM4tbX)m70ZdfKyFIRC03Kb1hPXRgWKmOYKGbg04KjGbnoXvki(NzR2L8qbj2TAVvEcnHumHrhhOfY8CXtEIEN69rbzto4HtYGkWGgNSAGCnsMW9fajunDNiE2ZPMW0oSTBwSPqanddkdSxi7pZoeHANIQxHVPTB82yA37D4ajImkfA8(VAZ3YeDa(0xemP7HAmZOtVyFdoXvo6BYG6J04vdysguzsWadACYeWGgNiEOgZmA1UuSVbTAVvleAcPycJooqlK55IN8e9o17JcYMCWdNKbvGbnoz1aDFJKjCFbqcvt3jIN9CQjmTdB7MfBkeqZWGYa7fY(ZSdrO2PO6v4BA7gVnM29EhoqIiJsHgV)R288t0b4tFrWeFki(NzNEEOGe7tCLJ(MmO(inE1aMKbvMemWGgNmbmOXjUsbX)mB1UKhkiXUv7TAHqtifty0XbAHmpx8KNO3PEFuq2KdE4KmOcmOXjRgiHFKmH7lasOA6or8SNtnPIeEfvppuqIo)zO1F4rHxaKqLTks4vuQG14emGVqgfEbqcv2mfGMHbLkynoflUUbKrh1dpkno28qysbjEuQG14emGVqgfdPJ)6T5BzIoaF6lcMOWOYD8WpnXvo6BYG6J04vdysguzsWadACYeWGgNyAmQCR2Db)Kv7TYtOjKIjm64aTqMNlEYt07uVpkiBYbpCsgubg04KvdKN8izc3xaKq10DI4zpNAsfj8kQEEOGeD(ZqR)WJcVaiHkBMQIeEfLkynobd4lKrHxaKqLntbOzyqPcwJtXIRBaz0r9WJsJZeDa(0xemrHrL74HFAIRC03Kb1hPXRgWKmOYKGbg04KjGbnoX0yu5wT7c(jR2B1cHMqkMWOJd0czEU4jprVt9(OGSjh8WjzqfyqJtwnqE(rYeUVaiHQP7eXZEo1Kks4vuQG14emGVqgfEbqcv28qysbjEuQG14emGVqgfdPJ)6T5BzIoaF6lcMOWOYD8WpnXvo6BYG6J04vdysguzsWadACYeWGgNyAmQCR2Db)Kv7T6ocnHumHrhhOfY8CXtEIEN69rbzto4HtYGkWGgNSAG8wgjt4(cGeQMUtep75utmvfj8kQEEOGeD(ZqR)WJcVaiHkBMQIeEfLkynobd4lKrHxaKq1eDa(0xemrHrL74HFAIRC03Kb1hPXRgWKmOYKGbg04KjGbnoX0yu5wT7c(jR2BLWrOjKIjm64aTqMNlEYt07uVpkiBYbpCsgubg04KvRMag04e5PDz1U7)YHjcCVwT3R4ubtTAd]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170507.220005, [[dStsiaGEjkQnrj2fsTnjkY(qfnBb3usEoKUnkomv7eI9QSBv2pPYOKOAyOKXHsrwgQY5rsnysvdhv1brL6usL6ysQZHsrTqsjlfvYILYYr8qkPNs8yHwNeLAIOuAQijtMKPl6IOuDvjk4YGRtHnkrH2kPuBMI2oPOtRQVHennuk8DPINHk8xk1OLQMNeLCssHplrUgsW9qcDiPsETe(nuV6r1e2pVfa1AtqCgyI8mw1PVmC94a1LTo9rhn)sEIjt4ccGJcdHhRAkzrbwuGUEIWhIVh(YSNp(gcpkWBc3X8Xh6OAi1JQjSFElaQP1ejsE(5ef0mmnPnb0ei)vYUd24u0OPhlklkYgwig3hT5J7aeAfy(Xp5Khht4U9HpPEIjGMa5Vs2Oj5lGjw7HyrfwtGbUCTjvyL2obXzGjtqCgyszeqtG8xjD6LK8fWeUGa4OWq4XQMYAwt04uF0tmzYHpysfwH4mWKLdH3OAc7N3cGAAnrIKNFoPRMHPj9brcg9rPn4Bj9aCj9brcg9rPHZBbqzHyCqzrroMWD7dFs9ef4zVDe)Hjw7HyrfwtGbUCTjvyL2obXzGjtqCgycBbp71P3k(dt4ccGJcdHhRAkRznrJt9rpXKjh(GjvyfIZatwoeogvty)8wautRjsK88Zjndtt6dIem6JsBW3IcAgMM0MaAcK)kz3bBCkA00JfCsroSqmUpAZh3bi0kW8JFYjpoMWD7dFs9e0i2GucSrtYxatS2dXIkSMadC5AtQWkTDcIZatMG4mWejIniLaD6LK8fWeUGa4OWq4XQMYAwt04uF0tmzYHpysfwH4mWKLdHngvty)8wautRjsK88ZjndttAJRhhO2gnjWvk7Pn4BrbndttAtanbYFLS7GnofnA6XcoPihwig3hT5J7aeAfy(Xp5Khht4U9HpPEcAeBqkb2Oj5lGjw7HyrfwtGbUCTjvyL2obXzGjtqCgyIeXgKsGo9ss(cqN(YR7EcxqaCuyi8yvtznRjACQp6jMm5WhmPcRqCgyYYHqHr1e2pVfa10AIejp)CcX4aoPiplkOzyAsBcOjq(RKDhSXPOrtpwWjf5WcX4(OnFChGqRaZp(jN84yc3Tp8j1tqJydsjWgnjFbmXApelQWAcmWLRnPcR02jiodmzcIZatKi2Guc0PxsYxa60xoVUNWfeahfgcpw1uwZAIgN6JEIjto8btQWkeNbMSCiLPr1e2pVfa10AIejp)Cs6b4sA0ExH7y)NPb6JpA48wauwspaxsRCsHTtAFceA48wauw6QzyAsRCsHDs8d1ety88XhTbFlrmoOWDoALtkSDs7tGqtag)puoRPWeUBF4tQNOap7TJ4pmXApelQWAcmWLRnPcR02jiodmzcIZatyl4zVo9wXFqN(YR7EcxqaCuyi8yvtznRjACQp6jMm5WhmPcRqCgyYYHq5OAc7N3cGAAnrIKNFoj9aCjnAVRWDS)Z0a9XhnCElaklDLEaUKw5KcBN0(ei0W5TaOS0vZW0Kw5Kc7K4hQjMW45JpAd(t4U9HpPEIc8S3oI)WeR9qSOcRjWaxU2KkSsBNG4mWKjiodmHTGN960Bf)bD6lNx3t4ccGJcdHhRAkRznrJt9rpXKjh(GjvyfIZatwoe20OAc7N3cGAAnrIKNFoj9aCjTYjf2oP9jqOHZBbqzjIXbfUZrRCsHTtAFceAcW4)HYznfMWD7dFs9ef4zVDe)Hjw7HyrfwtGbUCTjvyL2obXzGjtqCgycBbp71P3k(d60xohDpHliaokmeESQPSM1eno1h9etMC4dMuHviodmz5qyZJQjSFElaQP1ejsE(5KUspaxsJ27kCh7)mnqF8rdN3cGYsxPhGlPvoPW2jTpbcnCElaQjC3(WNuprbE2BhXFyI1EiwuH1eyGlxBsfwPTtqCgyYeeNbMWwWZED6TI)Go9LZgDpHliaokmeESQPSM1eno1h9etMC4dMuHviodmz5YjsK88Zjl3a]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170507.220005, [[dSd(kaGEPKOnrj2fs2MusyFsPMTi3uu9CP62OYHf2PQAVk7wL9tjnkeWWquJtkrAzOQopcAWuudhPCierNcr4yuQZjLulKuXsrQAXQYYr5HurpL4Xu16KsuMOuctfPYKjz6sUiQIRkLO6YqxNu2OuIyRKQAZuy7KQCAGVHinnQG(oc9meO)sLgTOmpPK0jjv6ZuKRrf4EuHETu8BqhevPN9OBcpx8sOAVj)GdNiaoNwn3YVmyIWwMvZGRxmnFbz9j0Jjm64(8jBtkzhq2bu2teAOhejqRmka82NVd4pHxFbGxF0TV9OBcpx8sOA6mr8maTAIcFAggugyVqg4m5seQDkQEf(Mw1rcAHPDaVlnirKrPqdGhuTTj4eEFGeOiCIb2lKbotU9IbAWjoZqFtoupKdVAVj5qL(b7hC4Kj)GdN0sWEHmWzYQzPyGgCc9ycJoUpFY2KAtEIUNc4JcYMCWdNKdv)GdNSAF(JUj8CXlHQPZeXZa0QjK8PzyqDONb7GoLgnlvKWROo0ZGDqNcV4LqLfM2HTQJeCcVpqcueorHrL56HG0eNzOVjhQhYHxT3KCOs)G9doCYKFWHtAbgvMvZoHG0e6XegDCF(KTj1M8eDpfWhfKn5GhojhQ(bhoz1(eC0nHNlEjunDMiEgGwn5PzyqDONb7GoLgnlk8PzyqzG9czGZKlrO2PO6v4BA7OdTW0oG3LgKiYOuObWdQ28B9eEFGeOiCs3d1yMq3EXan4eNzOVjhQhYHxT3KCOs)G9doCYKFWHtepuJzcTAwkgObNqpMWOJ7ZNSnP2KNO7Pa(OGSjh8Wj5q1p4WjR23HJUj8CXlHQPZeXZa0QjpnddQd9myh0P0OzrHpnddkdSxidCMCjc1ofvVcFtBhjOfM2b8U0GergLcnaEq122EcVpqcueoXNcIGZKBpluqI9joZqFtoupKdVAVj5qL(b7hC4Kj)GdN4mfebNjRMLSqbj2NqpMWOJ7ZNSnP2KNO7Pa(OGSjh8Wj5q1p4WjR23bJUj8CXlHQPZeXZa0QjpnddkTldMi0Txm8mvzuA0SOWNMHbLb2lKbotUeHANIQxHVPTJo0ct7aExAqIiJsHgapOAZV1t49bsGIWjDpuJzcD7fd0GtCMH(MCOEihE1EtYHk9d2p4Wjt(bhor8qnMj0QzPyGg0QzcytIj0Jjm64(8jBtQn5j6EkGpkiBYbpCsou9doCYQ9BfJUj8CXlHQPZeXZa0QjpnddkTldMi0Txm8mvzuA0SOWNMHbLb2lKbotUeHANIQxHVPTJe0ct7aExAqIiJsHgapOABBpH3hibkcN4tbrWzYTNfkiX(eNzOVjhQhYHxT3KCOs)G9doCYKFWHtCMcIGZKvZswOGe7wntaBsmHEmHrh3NpzBsTjpr3tb8rbzto4HtYHQFWHtwTpPJUj8CXlHQPZeXZa0QjmTdB7iFlk8PzyqzG9czGZKlrO2PO6v4BA7OdTW0oG3LgKiYOuObWdQ28B9eEFGeOiCs3d1yMq3EXan4eNzOVjhQhYHxT3KCOs)G9doCYKFWHtepuJzcTAwkgObTAMa8jXe6XegDCF(KTj1M8eDpfWhfKn5GhojhQ(bhoz1(T0r3eEU4Lq10zI4zaA1eM2HTDKVff(0mmOmWEHmWzYLiu7uu9k8nTDKGwyAhW7sdsezuk0a4bvBB7j8(ajqr4eFkicotU9Sqbj2N4md9n5q9qo8Q9MKdv6hSFWHtM8doCIZuqeCMSAwYcfKy3QzcWNetOhty0X95t2MuBYt09uaFuq2KdE4KCO6hC4Kv736r3eEU4Lq10zI4zaA1Kks4vu9Sqbj6codToaEu4fVeQSurcVIsfSg3G9afYOWlEjuzHKpnddkvWAClwCDdiJlka8O0OzXdHjfK4rPcwJBWEGczumKlaxVTTdMW7dKafHtuyuzUEiinXzg6BYH6HC4v7njhQ0py)GdNm5hC4KwGrLz1Stiiz1mbSjXe6XegDCF(KTj1M8eDpfWhfKn5GhojhQ(bhoz1(2KhDt45IxcvtNjINbOvtQiHxr1ZcfKOl4m06a4rHx8sOYcjRiHxrPcwJBWEGczu4fVeQSqYNMHbLkynUflUUbKXffaEuA0MW7dKafHtuyuzUEiinXzg6BYH6HC4v7njhQ0py)GdNm5hC4KwGrLz1Stiiz1mb4tIj0Jjm64(8jBtQn5j6EkGpkiBYbpCsou9doCYQ9TThDt45IxcvtNjINbOvtQiHxrPcwJBWEGczu4fVeQS4HWKcs8OubRXnypqHmkgYfGR322bt49bsGIWjkmQmxpeKM4md9n5q9qo8Q9MKdv6hSFWHtM8doCslWOYSA2jeKSAMaeKetOhty0X95t2MuBYt09uaFuq2KdE4KCO6hC4Kv7BZF0nHNlEjunDMiEgGwnHKvKWRO6zHcs0fCgADa8OWlEjuzHKvKWROubRXnypqHmk8Ixcvt49bsGIWjkmQmxpeKM4md9n5q9qo8Q9MKdv6hSFWHtM8doCslWOYSA2jeKSAMaoKetOhty0X95t2MuBYt09uaFuq2KdE4KCO6hC4KvRMiEgGwnz1ga]] )


    storeDefault( [[Frost Primary]], 'displays', 20170507.220005, [[dStYgaGEPsVejPDbrKTbrkZuQWSv4MiOoSKVbruVMQu7Kk7vSBc7hv6NkQHbHFRYZGiXqrQbtcdhQoOu8zO0XKshhj1cPQwkjQftslNIhsv8uWJrP1HGyIqeMkKMmQy6kDrPQRsI4YQ66iAJqXwHiPnJQ2os8rQsonPMgjsFNsnsKeldbgnkgpe1jrOBHG01Kk68uYZjATqKQBRiN2GgGTWx9jWCIfwRXhywjODq01hyld2FPPqh1aMsG99W8SEh)aut(KFZqJvm9InaBaRzEE5VEk8vFczCicG8mpV8xpf(QpHmoebWn6PYyrK9eGU7hNsreyslA6JdPeGAYN854PWx9jKXpG1mpV8x0YG9xzCicizoBWwVSmn9XpGK5SBi3l(bKmNnyRxwMgY9IFGTmy)TrWYCMa(ZOOZewzIErf0awXrOe0zNbqooebKmNnAzW(Rm(b8wTrWYCMaOZ0kt0lQGgql4OzR9mncwMZeqzIErf0aSf(QprJGL5mb8NrrNjCaa)z11q3Tw9jIJGoBdizoBan(bOM8jFKqBE2vFIakt0lQGgqqorK9eY4uAaj(pgygLKXZnotqduX1gqnU2ayJRnGjU2SbKmNTNcF1Nqg1aipZZl)TH0uXHiqrAkul8pGkjpFGPc5gY9Idra1HUBxVgNDZye1a1aNPaMZMMsFCTbQbot55MuRLMsFCTbqINVihBudud7YsstHo(bOOLAv9qVwOw4Fa1aSf(QprZqJveWtVdTx5aC0s8rzHAH)b4eWucSpQf(hOu1d9AfOinfH1Ip(b8wfZjwq39JRLGa1aNPqld2FPPqhxBaZpc4P3H2RCaj(pgygLKjQbQbotHwgS)stPpU2aut(KphIcoA2ApJm(b8C4wCvGEbWyo5YvrZCFGjTOHCV4qeyld2FXCIfwRXhywjODq01hGZZxKJTHUJaGEYdxfymNCjeUk488f5ydqn5t(CiYEcq39JtPicynZZl)LQ(Y4i02a1aNPAg2LLKMcDCTb0SNaPF3uCTDga3ONkJfMtSGU7hxlbbWnp7nPwBdDhba9KhUkWyo5siCvGBE2BsT2a8NydqJYvbucjxfUYyo7atfYn9XHiGM9eaEXQfyJRZaBzW(lnL(OgqDO721RXzh)asMZMMcD8dG8mpV8xIcoA2ApJmoebSM55L)suWrZw7zKXHiWwgS)I5eBaAuUkGsi5QWvgZzha5zEE5VOLb7VY4qeqYC2nKMIOG)IAajZztuWrZw7zKXpG1mpV83gstfhIa1WUSK0u6JFajZzttPp(bKmNDtF8dWEtQ1stHoQbkstb4)yqejIdrGI0uncwMZeWFgfDMWD0JbnqrAkIc(d1c)dOsYZhysla04qeyld2FXCIf0D)4Ajia1KAwVrQAjSwJpqfGTWx9jWCInankxfqjKCv4kJ5SdudCMYZnPwlnf64Ad0lk1XZj(bK6j8X3m3hhbb8wfZj2a0OCvaLqYvHRmMZoqnWzQMHDzjPP0hxBa2BsTwAk9rnaBHV6tG5elO7(X1sqajZzt13svl4OfyLXpGY)4l5hGaeTizeDIaPHKAdG8mpV8xQ6lJRnWuHmGgxBGAGZuaZzttHoU2aut(KphmNybD3pUwcc4TkMtSWAn(aZkbTdIU(aut(KphQ6lJFaxn9bWyo5YvbTrpvgRafPPuIqVbWhL1BYMa]] )

    storeDefault( [[Frost AOE]], 'displays', 20170507.220005, [[dStXgaGEPIxsOyxsLkBdfqZukQzRWnrHCyj3wr9nuGANuzVIDt0(rv9tPQHPk(TkpdfGHIkdMqgouDqk1NHIJrvDCuulurwkHQfJulNIhkfEk4XizDOGAIeknvv1KrvMUsxukDvuKUmKRJOncL2kkq2mbBhbFuQKttQPjvkFNQmsuOwMQuJgLgVQKtIq3cfKRHI48uYZjzTsLQETuKJF(bOk8vFsSNCH1AGc0Z0FZeDTb2YGbTCe4cDatjXGAWIOAktbOh6oD6ACEzkGvVGGcTnk8vFsvCpbE1liOqBJcF1Nuf3taMjrKiEePojO7GIRBpbM1s724yabyMerI41OWx9jvzkGvVGGcT)YGbTQ4EcOyppWtVuS2THoGI98Sj3l0buSNh4PxkwBY9YuGTmyqRTKI9mbM6))EgjoXUy8pGvCm0B)Naw9cck0kMjvCmKFaf759ldg0QYuGMOTLuSNjWVNtCIDX4FaTKNMQ2ZylPyptaXj2fJ)bOk8vFsBjf7zcm1))9mkaGJO01q3Pw9jJ7nt8dOypp4NPamtIirIvBquR(KbeNyxm(hqsotK6KQ46wafoAmWokfBJBCM8duX5hWeNFamX5hGoo)SbuSNxJcF1Nuf6aV6feuO1M0uX9eOin13chfGMuqiWC9YMCV4Ecqp0D60148ShJqhOg4SfWEECeAJZpqnWzRg3mDTCeAJZpGyrcf5ydDGA4vwkocCzkabTstRh616BHJcqhGQWx9jThAmYanAD)wXdWtRWhL13chfGkGPKyqFlCuGIwp0RvGI0umslrzkqt0yp5c6oO48FhOg4S1VmyqlhbU48dyqJanAD)wXdOWrJb2rPydDGAGZw)YGbTCeAJZpaZKisepIsEAQApJktbAC4w8f9VaynNA5lYUVnGRMrbWAo1YxKDFBGTmyql2tUWAnqb6z6VzIU2a8qcf5yT5AoaONBWxewZPwgMViEiHICSbAIg7jxyTgOa9m93mrxBan1jb8IslXehtcudC2YE4vwkocCX5hOg4SfWEECe4IZpaUrpxglSNCbDhuC(VdGBqu3mDT2Cnha0Zn4lcR5uldZxeUbrDZ01gyUEb)48dmxVSBJ7jWREbbfAfZKko)aBzWGwocTHoG4ObQuOaVF8zWpm5Hb2D(buSNhhbUmfqXEEIbzrRL80smQmfGQWx9jXEYf0DqX5)oa1ntxlhH2qhOg4SL9WRSuCeAJZpqt0yp5gG7ZxeusfFrUYyoVak2ZJOKNMQ2ZOYuaREbbfATjnvCpbQHxzP4i0MPak2ZZUn0buSNhhH2mfG6MPRLJaxOdudC2QXntxlhbU48duKMYwsXEMat9)FpJAUf7paZKAQMyqAfSwdua6aZAj8J7jWwgmOf7jxq3bfN)7afPPikfUVfokanPGqaQcF1Ne7j3aCF(IGsQ4lYvgZ5fOinfGJgdIInUNaTYIEG4LPak9m(az33g37ak2ZZM0ueLcxOd8QxqqH2FzWGwvCpb2YGbTyp5gG7ZxeusfFrUYyoVaw9cck0suYttv7zuX9e4vVGGcTeL80u1EgvCpbyMerIShAmYzKCdqfa3ONlJfrQtc6oO462taHtUb4(8fbLuXxKRmMZlGM6KD)DZX5ZKamtIir8WEYf0DqX5)oWR4EcWmjIeXtmtQmfywlTj3lUNafPPyQuVbWhLfYKnba]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170507.220005, [[dWZ3gaGEf0lrQ0UukLETuuZubmBP6WsUjIupgLUTI6zKu1oPYEf7MW(jQ(PsmmL0Vv15qK0qrXGjkdhHdkLonPogv54ivTqfAPOQAXKy5u6HsHNcwMsX6qKyIKuzQqzYOktxLlQixfvLld56izJKKTQuQSzISDKYhvG(Ss10uk57uvJePIXPukgnunEeXjru3skIRrs58OYZPyTkLQ(MuKoEblaBrC6xO6fhCCDuGf(WgGSBkWv2D0XqJjkbSLyh1ahX2CgdqpfIc1217IzK4cWgGBrsYGUgfXPFHjU1aKSijzqxJI40VWe3AacREUSCKzFbOhIIBR1aZAr7uCQpa9uikeVgfXPFHjJb4wKKmOdRS7OZe3Aad(7d(6JfVDkJbm4VFl19zmGb)9bF9XI3sDFgdCLDhDTcw83gyCbdBH08tEq6GfGlQAY2qQnDZQNAB5rQQTr9RnDnsnzl1cqsCRbm4Vpwz3rNjJbAwPvWI)2aylm8tEq6Gfql4PzR7TTcw83gGFYdshSaSfXPFrRGf)TbgxWWwiDaGaXQRUEyD6xe3g12eWG)(awgdqpfIcPoTfXE6xeGFYdshSacQzYSVWe3wbmeOExvVm4n((BdwGkoVakX5fypoVa248YfWG)(nkIt)ctucqYIKKbDTu2kU1afLTW4iqbuOKKcmxK0sDFCRbu66HdhS)(T9EucuDc8cWFFgAtX5fO6e4vJFwPogAtX5fqDiPIQFrjq19loddnMmgGM2Ov0D9XHXrGcOeGTio9lA76DrGgtoSj(dWtBi6fhghbkaVa2sSJW4iqbkfDxFCbkkBrATaLXanRO6fhOhIIZBtGQtGxyLDhDm0yIZlGf1d0yYHnXFadbQ3v1ldEucuDc8cRS7OJH2uCEbONcrH4rwWtZw3BnzmqJNGtUmSpaFc8VZjxw7YuGzTOL6(4wdCLDhDQEXbhxhfyHpSbi7McWdjvu9RLzGaGEUHCz8jW)ohPixgpKur1Va0tHOq8iZ(cqpef3wRb4wKKmOJUJM4AIxGQtGxTD)IZWqJjoVaA2xS9)phNNAbiS65YYP6fhOhIIZBtaclI9NvQRLzGaGEUHCz8jW)ohPixgHfX(Zk1fq6fxagm5YGsyKlZvw77hyUiPDkU1aA2xaefRwShNAbUYUJogAtrjGsxpC4G93pkb4h1rLbf3MvVMUQ2Q63wVaKSijzqhzbpnBDV1e3AaUfjjd6il4PzR7TM4wdCLDhDQEXfGbtUmOeg5YCL1((bizrsYGoSYUJotCRbm4VFlLTilK(OeWG)(Kf80S19wtgdWTijzqxlLTIBnq19loddTPmgWG)(m0MYyad(73oLXaS)SsDm0yIsGIYwabQ3jRU4wduu2QvWI)2aJlyylKEGjvybkkBrwi9yCeOakussbM1calU1axz3rNQxCGEikoVnbONsZ282PnWX1rbQaSfXPFHQxCbyWKldkHrUmxzTVFGQtGxn(zL6yOXeNxGjrP0r8YyaJEMOJAxMIBtGMvu9IladMCzqjmYL5kR99duDc8QT7xCggAtX5fG9NvQJH2uucWweN(fQEXb6HO482eWG)(0fXPOf80IDtgdyWFFgAmzmajlssg0r3rtCEbMlsaS48cuDc8cWFFgAmX5fGEkefINQxCGEikoVnbAwr1lo446Oal8Hnaz3ua6PquiE0D0KXaUAgfGpb(35KlJXQNllxGIYw8j0xaIEXHS5saa]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170507.220005, [[dOtYgaGEjQxIsyxQsPETePzsQ0SL0nHQQBROoSu7Ks7vSBuTFI4Nk0Wuf)wP1bvLgkbdMumCeoiv8mvPQJjHJJsAHkYsjvSyKSCQ6HKQEk4XO45umrvPyQQQjtKMUkxubxfLYLHCDKAJKsBvvQyZe12ruFuIyzQsMgkv9DQ0irPYPjz0qz8qvojIClOQ4AOeDEc9zOYAvLs(MQuPtr(byAItTCTl)GtSIcmY2xxs2Hax7XHobYcHkGV54q6XqmLMPauvv5YLux3qfqCuw2Go9nXPwUj2Na4nklBqN(M4ul3e7tawPr0iPKywoOkJIL9pbMvCNHyFFawPr0iP6BItTCtMcioklBq3V94qNj2NagS1fCvhdMZqOcyWwxh6Bdvad26cUQJbZH(2mf4Apo05WzWwFGPX)Fe)6qQe29digl(8Q4jG4OSSbDSyYel(ueWGTU)2JdDMmfOukhod26d8hf0HujS7hqXLQy6B9oCgS1hqhsLWUFaMM4ul3HZGT(atJ))i(daeigvxvL7tT8yFXYxbmyRl8ZuawPr0O3O8iMtT8a6qQe29dWPNjXSCtSSpGHavRARTbt)wxF(b6ylc4JTiaUylcqfBrUagS1vFtCQLBcva8gLLnOZH23X(eOP99xKafGIwwoWCJNd9TX(eGQQkxUK666uRHkqxjWAaBDfipeBrGUsG163zQ(eipeBrG3GKB66fQaD1TfncKfYuaYkJIsvvN4xKafGkattCQL7uv44b0py)d6eqQYquBXVibkataFZXH(IeOanLQQoXanTVXVIJYuGsP0U8duLrXw8kqxjW6F7XHobYcXweWJQb0py)d6eWqGQvT12GfQaDLaR)Thh6eipeBrawPr0iPK4svm9TEtMcOFjeLO5VbyJJTvrjACghcy7zua24yBvuIgNXHax7XHoTl)GtSIcmY2xxs2HasrYnD9Ce0naOM1lrdBCSTkIVs0ifj301lqPuAx(bNyffyKTVUKSdbumlhiAgfhxSSmqxjWANQBlAeileBrGUsG1a26kqwi2IaeE1C7f1U8duLrXw8kaHhXSZu95iOBaqnRxIg24yBveFLOHWJy2zQ(cm34b)ylcm345me7ta8gLLnOJftMylcCThh6eipeQagS1vGSqMcOdQIAdk2xpfV7dlFE)BxeWGTUSajsP4svCCMmfGPjo1Y1U8duLrXw8kaZot1Na5HqfOReyTt1TfncKhITiqPuAx(fq4lrd0CJen227x3agS1LexQIPV1BYuaXrzzd6CO9DSpb6QBlAeipKPagS11ziubmyRRa5HmfGzNP6tGSqOc0vcSw)ot1NazHylc00(2HZGT(atJ))i(1Dq7paR0kMsFhLboXkkavGzfh(X(e4Apo0PD5hOkJIT4vGM23K4Y7xKafGIwwoattCQLRD5xaHVenqZns0yBVFDd00(giq1kP3e7tGbEtvrsZuaJAMOICghI9vad266q7BsC5nubWBuw2GUF7XHotSpbU2JdDAx(fq4lrd0CJen227x3aIJYYg0rIlvX036nX(eaVrzzd6iXLQy6B9MyFcWknIg5uv44Zi(fGjaHxn3ErsmlhuLrXY(NaYl)ci8LObAUrIgB79RBafZYFRDNJTGLbyLgrJKQD5hOkJIT4va8I9jaR0iAKuwmzYuGzf3H(2yFc00(MnU6cquBrKpxca]] )


end

