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
local addResourceMetaFunction = ns.addResourceMetaFunction
local addPet = ns.addPet
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
local setRegenModel = ns.setRegenModel
local setTalentLegendary = ns.setTalentLegendary


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEATHKNIGHT') then

    ns.initializeClassModule = function ()

        Hekili.UseNewEngine = true

        setClass( "DEATHKNIGHT" )

        -- Resources
        addResource( "runic_power", SPELL_POWER_RUNIC_POWER, true )
        addResource( "runes", SPELL_POWER_RUNES, true )


        setRegenModel( {
            frost_mh = {
                resource = 'runic_power',

                spec = 'frost',
                talent = 'runic_attenuation',
                setting = 'forecast_swings',

                last = function ()
                    local t = state.query_time - state.swings.mainhand
                    t = floor( t / state.swings.mainhand_speed )

                    return state.swings.mainhand + ( t * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',
                value = 1
            },

            frost_oh = {
                resource = 'runic_power',

                spec = 'frost',
                talent = 'runic_attenuation',
                setting = 'forecast_swings',

                last = function ()
                    local t = state.query_time - state.swings.offhand
                    t = ceil( t / state.swings.offhand_speed )

                    return state.swings.offhand + ( t * state.swings.offhand_speed )
                end,
                interval = 'offhand_speed',
                value = 1
            },

            breath = {
                resource = 'runic_power',

                spec = 'frost',
                aura = 'breath_of_sindragosa',
                setting = 'forecast_breath',

                last = function ()
                    return state.buff.breath_of_sindragosa.applied + floor( state.query_time - state.buff.breath_of_sindragosa.applied )
                end,

                stop = function ( x ) return x < 15 end,

                interval = 1,
                value = -15
            },

            hungering_rp = {
                resource = 'runic_power',

                spec = 'frost',
                talent = 'hungering_rune_weapon',
                aura = 'hungering_rune_weapon',

                last = function ()
                    return state.buff.hungering_rune_weapon.applied + floor( state.query_time - state.buff.hungering_rune_weapon.applied )
                end,

                interval = 1,
                value = 5
            },

            hungering_rune = {
                resource = 'runes',

                spec = 'frost',
                talent = 'hungering_rune_weapon',
                aura = 'hungering_rune_weapon',

                last = function ()
                    return state.buff.hungering_rune_weapon.applied + floor( state.query_time - state.buff.hungering_rune_weapon.applied )
                end,

                fire = function ( time, val )
                    local r = state.runes

                    r.expiry[6] = 0
                    table.sort( r.expiry )
                end,

                stop = function ( x )
                    local r = state.runes

                    return r.actual == 6
                end,

                interval = 1,
                value = 1
            },

            rune_regen = {
                resource = 'runes',

                last = function ()
                    return state.query_time
                end,
    
                interval = function( time, val )
                    local r = state.runes

                    if val == 6 then return -1 end

                    return r.expiry[ val + 1 ] - time
                end,

                fire = function( time, val )
                    local r = state.runes 
                    local v = r.actual

                    if v == 6 then return end

                    r.expiry[ v + 1 ] = 0
                    table.sort( r.expiry )
                end,
    
                stop = function( x )
                    local r = state.runes

                    return r.actual == 6
                end,

                value = 1,    
            }
        } )


        registerCustomVariable( 'runes', setmetatable(
            {
                expiry = { 0, 0, 0, 0, 0, 0 },
                cooldown = 10,
                regen = 0,
                max = 6,
                forecast = {},
                fcount = 0,
                times = {},
                values = {},

                reset = function()
                    local t = state.runes

                    for i = 1, 6 do
                        local start, duration, ready = GetRuneCooldown( i )
                        t.expiry[ i ] = ready and 0 or start + duration
                        t.cooldown = duration
                    end

                    table.sort( t.expiry )

                    t.actual = nil
                end,

                gain = function( amount )
                    local t = state.runes

                    for i = 1, amount do
                        t.expiry[ 6 ] = 0
                        table.sort( t.expiry )
                    end

                    t.actual = nil
                end,

                spend = function( amount )
                    local t = state.runes

                    for i = 1, amount do
                        t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
                        table.sort( t.expiry )
                    end

                    t.actual = nil
                end,
            },
            {
                __index = function( t, k, v )
                    if k == 'actual' then
                        local amount = 0

                        for i = 1, 6 do
                            amount = amount + ( t.expiry[i] <= state.query_time and 1 or 0 )
                        end

                        return amount

                    elseif k == 'current' then
                        if t.forecast and t.fcount > 0 then
                            local q = state.query_time
                            local index, slice

                            if t.values[ q ] then
                                return t.values[ q ]
                            end

                            for i = 1, t.fcount do
                                local v = t.forecast[ i ]
                                if v.t <= q then
                                    index = i
                                    slice = v
                                else
                                    break
                                end
                            end

                            -- We have a slice.
                            if index and slice then
                                t.values[ q ] = slice.v
                                return t.values[ q ]
                            end
                        end
                        return t.actual

                    elseif k == 'time_to_next' then
                        return t[ 'time_to_' .. t.current + 1 ]

                    elseif k == 'time_to_max' then
                        return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

                    else
                        local amount = k:match( "time_to_(%d+)" )
                        amount = amount and tonumber( amount )

                        if amount then
                            if amount > 6 then return 3600
                            elseif amount <= t.current then return 0 end

                            if t.forecast and t.fcount > 0 then
                                local q = state.query_time
                                local index, slice

                                if t.times[ amount ] then return max( 0, t.times[ amount ] - q ) end

                                if t.regen == 0 then
                                    for i = 1, t.fcount do
                                        local v = t.forecast[ i ]
                                        if v.v >= amount then
                                            t.times[ amount ] = v.t
                                            return max( 0, t.times[ amount ] - q )
                                        end
                                    end
                                    t.times[ amount ] = q + 3600
                                    return max( 0, t.times[ amount ] - q )
                                end

                                for i = 1, t.fcount do
                                    local slice = t.forecast[ i ]
                                    local after = t.forecast[ i + 1 ]
                                    
                                    if slice.v >= amount then
                                        t.times[ amount ] = slice.t
                                        return max( 0, t.times[ amount ] - q )

                                    elseif after and after.v >= amount then
                                        -- Our next slice will have enough resources.  Check to see if we'd regen enough in-between.
                                        local time_diff = after.t - slice.t
                                        local deficit = amount - slice.v
                                        local regen_time = deficit / t.regen

                                        if regen_time < time_diff then
                                            t.times[ amount ] = ( slice.t + regen_time )
                                        else
                                            t.times[ amount ] = after.t
                                        end                        
                                        return max( 0, t.times[ amount ] - q )
                                    end
                                end
                                t.times[ amount ] = q + 3600
                                return max( 0, t.times[ amount ] - q )
                            end

                            return max( 0, t.expiry[ amount ] - state.query_time )
                        end
                    end
                end
            } ) )


        local rp_spent_since_pof = 0
        local virtual_rp_spent_since_pof = 0

        local function runeSpender( amount, resource )
            if resource == 'runes' then
                local r = state.runes

                r.actual = nil

                r.spend( amount )

                state.gain( amount * 10, 'runic_power' )

                if state.spec.frost and state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                    state.applyBuff( "remorseless_winter", state.buff.remorseless_winter.remains + ( 0.5 * amount ) )
                end

                if state.spec.unholy and state.set_bonus.tier20_4pc == 1 then
                    state.setCooldown( 'army_of_the_dead', state.cooldown.army_of_the_dead.remains - ( 6 * amount ) )
                end

            elseif resource == 'runic_power' then
                if state.set_bonus.tier20_2pc == 1 and state.buff.pillar_of_frost.up then
                    virtual_rp_spent_since_pof = virtual_rp_spent_since_pof + amount

                    while( virtual_rp_spent_since_pof > 40 ) do
                        state.applyBuff( 'pillar_of_frost', state.buff.pillar_of_frost.remains + 1 )
                        virtual_rp_spent_since_pof = virtual_rp_spent_since_pof - 40
                    end
                end
            end
        end


        local function runeGainer( amount, resource )
            if resource == 'runes' then
                local r = state.runes
                
                r.actual = nil

                r.gain( amount )
            end
        end


        addHook( 'spend', runeSpender )
        addHook( 'spendResources', runeSpender )
        addHook( 'gain', runeGainer )


        addMetaFunction( 'state', 'rune', function () return runes.current end )


        addPet( 'ghoul' )
        addPet( 'abomination' )

        addPet( 'army_of_the_dead' )

        addPet( 'gargoyle' )
        addPet( 'valkyr_battlemaiden' )

        registerCustomVariable( "last_army", 0 )
        registerCustomVariable( "last_valkyr", 0 )
        registerCustomVariable( "last_gargoyle", 0 )
        registerCustomVariable( "last_transform", 0 )


        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, _, spellID )

            if unit ~= 'player' then return end

            if spellID == class.abilities.army_of_the_dead.id then
                state.last_army = GetTime()
            
            elseif spellID == class.abilities.dark_arbiter.id then
                state.last_valkyr = GetTime()

            elseif spellID == class.abilities.dark_transformation.id then
                state.last_transform = GetTime()

            elseif spellID == class.abilities.summon_gargoyle.id then
                state.last_gargoyle = GetTime()

            elseif spellID == class.abilities.pillar_of_frost.id then
                rp_spent_since_pof = 0
                virtual_rp_spent_since_pof = 0
            end

        end )


        addHook( 'reset_precast', function ()
            state.runes.reset()

            state.runic_power.regen = 0

            state.pet.valkyr_battlemaiden.expires = state.last_valkyr > 0 and state.last_valkyr + 15 or 0
            state.pet.army_of_the_dead.expires = state.last_army > 0 and state.last_army + 40 or 0

            virtual_rp_spent_since_pof = rp_spent_since_pof

            if state.talent.sludge_belcher.enabled then
                if UnitExists( 'pet' ) then state.pet.abomination.expires = state.query_time + 3600
                else state.pet.abomination.expires = 0 end
                state.pet.ghoul.expires = 0
            else
                if UnitExists( 'pet' ) then state.pet.ghoul.expires = state.query_time + 3600
                else state.pet.ghoul.expires = 0 end
                state.pet.abomination.expires = 0
            end

        end )


        setPotion( "old_war" )
        setRole( state.spec.blood and 'tank' or 'attack' )

        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( state.spec.blood and 'tank' or 'attack' )
        end )


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


        -- Traits (Frost)
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


        -- Traits (Unholy)
        addTrait( "apocalypse", 220143 )
        addTrait( "armies_of_the_damned", 191731 )
        addTrait( "black_claws", 238116 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "cunning_of_the_ebon_blade", 241050 )
        addTrait( "deadliest_coil", 191419 )
        addTrait( "deadly_durability", 191565 )
        addTrait( "deaths_harbinger", 238080 )
        addTrait( "double_doom", 191741 )
        addTrait( "eternal_agony", 208598 )
        addTrait( "feast_of_souls", 218280 )
        addTrait( "fleshsearer", 214906 )
        addTrait( "gravitational_pull", 191721 )
        addTrait( "lash_of_shadows", 238044 )
        addTrait( "plaguebearer", 191485 )
        addTrait( "portal_to_the_underworld", 191637 )
        addTrait( "rotten_touch", 191442 )
        addTrait( "runic_tattoos", 191592 )
        addTrait( "scourge_of_worlds", 191747 )
        addTrait( "scourge_the_unbeliever", 191494 )
        addTrait( "the_darkest_crusade", 191488 )
        addTrait( "the_shambler", 191760 )
        addTrait( "unholy_endurance", 191584 )


        -- Auras
        addAura( "aggramars_stride", 207438, "duration", 3600 )
        addAura( "antimagic_shell", 48707, "duration", 5 )
            modifyAura( "antimagic_shell", "duration", function( x ) return x + ( talent.spell_eater.enabled and 5 or 0 ) end )
        addAura( "army_of_the_dead", 42650, "duration", 4 )
        addAura( "blinding_sleet", 207167, "duration", 4 )
        addAura( "breath_of_sindragosa", 152279, "duration", 3600, "friendly", true )
        addAura( "chilled_heart", 235592, "duration", 3600, "max_stack", 20 )
        addAura( "dark_command", 56222, "duration", 3 )
        addAura( "dark_succor", 178819 )
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
        addAura( "sudden_doom", 81340, "duration", 10, "max_stack", 1 )
            modifyAura( "sudden_doom", "max_stack", function( x ) return x + ( artifact.sudden_doom.enabled and 1 or 0 ) end )
        addAura( "temptation", 234143, "duration", 30 )
        addAura( "unholy_strength", 53365, "duration", 15 )
        addAura( "virulent_plague", 191587, "duration", 21 )
        addAura( "wraith_walk", 212552, "duration", 3 )


        addAura( "dark_transformation", 63560, "duration", 20, "feign", function ()
            local duration = 20 + ( artifact.eternal_agony.rank * 2 )
            local up = ( pet.ghoul.up or pet.abomination.up ) and last_transform + duration > state.query_time
            buff.dark_transformation.name = class.abilities.dark_transformation.name
            buff.dark_transformation.count = up and 1 or 0
            buff.dark_transformation.expires = up and last_transform + duration or 0
            buff.dark_transformation.applied = up and last_transform or 0
            buff.dark_transformation.caster = 'player'
        end )


        addGearSet( "blades_of_the_fallen_prince", 128292 )
        setArtifact( "blades_of_the_fallen_prince" )

        addGearSet( "apocalypse", 128403 )
        setArtifact( "apocalypse" )

        addGearSet( "tier19", 138355, 138361, 138364, 138349, 138352, 138358 )
        addGearSet( "tier20", 147124, 147126, 147122, 147121, 147123, 147125 )

        addGearSet( "acherus_drapes", 132376 )
        addGearSet( "aggramars_stride", 132443 )
        addGearSet( "cold_heart", 151796 ) -- chilled_heart stacks NYI
        addGearSet( "consorts_cold_core", 144293 )
        addGearSet( "death_march", 144280 )
        -- addGearSet( "death_screamers", 151797 )
        addGearSet( "draugr_girdle_of_the_everlasting_king", 132441 )
        addGearSet( "kiljaedens_burning_wish", 144259 )
        addGearSet( "koltiras_newfound_will", 132366 )
        addGearSet( "lanathels_lament", 133974 )
        addGearSet( "perseverance_of_the_ebon_martyr", 132459 )
        addGearSet( "prydaz_xavarics_magnum_opus", 132444 )
        addGearSet( "rethus_incessant_courage", 146667 )
        addGearSet( "seal_of_necrofantasia", 137223 )
        addGearSet( "sephuzs_secret", 132452 )
        addGearSet( "shackles_of_bryndaor", 132365 ) -- NYI
        addGearSet( "soul_of_the_deathlord", 151740 )
        addGearSet( "soulflayers_corruption", 151795 )
        addGearSet( "the_instructors_fourth_lesson", 132448 )
        addGearSet( "toravons_whiteout_bindings", 132458 )
        addGearSet( "uvanimor_the_unbeautiful", 137037 )


        setTalentLegendary( 'soul_of_the_deathlord', 'blood',  'foul_bulwark' )
        setTalentLegendary( 'soul_of_the_deathlord', 'frost',  'gathering_storm' )
        setTalentLegendary( 'soul_of_the_deathlord', 'unholy', 'bursting_sores' )


        addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and your Artifact Ability will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } )

        ns.addSetting( 'bos_frost_strike_rp', 25, {
            name = "Frost: Breath of Sindragosa, Frost Strike Minimum RP",
            type = "range",
            desc = "If the Breath of Sindragosa talent is enabled and Breath of Sindragosa is ticking, the addon will not recommend Frost Strike unless you have at least this much Runic Power.  " ..
                "It can be helpful to increase this to 40 Runic Power (or higher), so that Frost Strike cannot cause you to fall below 15 Runic Power, causing Breath of Sindragosa to fall off.",
            min = 25,
            max = 100,
            step = 1,
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
            if artifact.deaths_harbinger.enabled then gain( 2, 'runes' ) end
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
            applyBuff( "army_of_the_dead", 4 )
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
            spend = 15,
            ready = 50,
            min_cost = 0,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "off",
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
            if equipped.cold_heart then removeBuff( "chilled_heart" ) end
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
            talent = "clawing_shadows"
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
            toggle = 'cooldowns'
        } )

        addHandler( "dark_arbiter", function ()
            summonPet( "valkyr_battlemaiden", 20 )
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
            usable = function () return pet.alive end,
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
            spend = 45,
            min_cost = 45,
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
            if talent.shadow_infusion.enabled and buff.dark_transformation.down then setCooldown( 'dark_transformation', cooldown.dark_transformation.remains - 7 ) end
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
            if spec.unholy and equipped.death_march then
                local a = talent.defile.enabled and "defile" or "death_and_decay"
                setCooldown( a, cooldown[ a ].remains - 2 )
            end
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
            notalent = 'hungering_rune_weapon',
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
            ready = function ()
                if buff.breath_of_sindragosa.up then return runic_power[ 'time_to_' .. settings.bos_frost_strike_rp ] end
                return runic_power.time_to_25
            end,
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
            if buff.rime.up then
                if set_bonus.tier19_4pc == 1 then
                    gain( 6, "runic_power" )
                end
                removeBuff( "rime" )
            end
        end )


        -- Hungering Rune Weapon
        --[[ Empower your rune weapon, gaining 1 Rune and 5 Runic Power instantly and every 1.5 sec for 15 sec. ]]

        addAbility( "hungering_rune_weapon", {
            id = 207127,
            spend = -5,
            spend_type = "runic_power",
            cast = 0,
            gcdType = "off",
            cooldown = 180,
            charges = 1,
            recharge = 180,
            toggle = "cooldowns",
            talent = 'hungering_rune_weapon',
            usable = function () return not buff.hungering_rune_weapon.up end,
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
            virtual_rp_spent_since_pof = 0
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
            notalent = "clawing_shadows"
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
            notalent = "dark_arbiter",
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170624.232908, [[da0qtaqiaslsb0MqknkKqNcjyxk0WaPJjkltu1ZuqMgaHRPazBau(gagNcaNdjQSokuMhsK7PGAFkqDqrLfIu1dPiteGQlIuzJae5Jka6KKsntfGUPIStq9tKOQLskEkQPsQ6QuOARui7v6VaAWu1HvAXK0JfzYcUm0MbXNPGrJKonrVMuz2cDBG2nIFRYWvuhhjklNWZPY0v11jX2jL8DKIZtrTEaIA)u6Mv9L5Kqo)Lld4iKvj(L(YAWiUoSW5HMbaualpGym)qzdk)qL5zmj3OeqEF5rkC(bLVCU0lpIR6lCw1xMoYQgXqPVmNeY5V8FgmeXX0DXWrdXz90A9u06buRhPmf58mggZgcaOamiRNwRxOqKjGZhnOymGqKj5B9uY6hcQ1tHY5uLr5BUCyf6aUcv5JIYAtcY0(NOm5iy5Ply0kGxqSCz4feld4RqN1NtOkFuuwdgX1Hfop0maYGwwd6ofrcDvF)YMOIjDtNwiis(QwE6cWliwUFHZx9LPJSQrmu6lZjHC(l)NbdrCmDxmC0qCwpTwpfTEKYuKZZyymBiaGcWGSEATEHcrMaoF0GIXacrMKV1tjRFiOwpTwF6Uy4OHmgwHoGVyjoiNaCF5rgfi4kjoRNswFERNcLZPkJY3C5Wk0bCfQYhfL1MeKP9przYrWYtxWOvaVGy5YWliwgWxHoRpNqv(OW6PygfkRbJ46WcNhAgazqlRbDNIiHUQVFztuXKUPtleejFvlpDb4fel3VWdv9LPJSQrmu6lZjHC(l)NbdrCmDxmC0qCwpTwpfTEHcbTEknS1pK1tHY5uLr5BUStbe8ianScdN5iwwBsqM2)eLjhblpDbJwb8cILldVGyzwbe8iw)aCfgoZrSSgmIRdlCEOzaKbTSg0DkIe6Q((Lnrft6MoTqqK8vT80fGxqSC)cdiQ(Y0rw1igk9L5Kqo)LvvGazuHq9IMb6Ebsm8uhvMTEATEvfiqgtxmaKkUIF09BsN1pyRpJYvoNQmkFZLtuxjXb8GauMWYAtcY0(NOm5iy5Ply0kGxqSCz4felBI6kjoR)Gy9ANWYAWiUoSW5HMbqg0YAq3PisOR67x2evmPB60cbrYx1YtxaEbXY9l8GQ(Y0rw1igk9L5Kqo)L)ZGHioMUlgoAioRNwRNIwpszkY5zmmMneaqbyqwpTwF6Uy4OHmgwHoGVyjoiNaCF5rgfi4kjoRNswFguRNwRxOqqRNsdB9dz9uOCovzu(Ml7uabpcqdRWWzoIL1MeKP9przYrWYtxWOvaVGy5YWliwMvabpI1paxHHZCeTEkMrHYAWiUoSW5HMbqg0YAq3PisOR67x2evmPB60cbrYx1YtxaEbXY9lmGv9LPJSQrmu6lZjHC(lhqvfiqgHGUhfsIbG0CkKWO73KoRFWdB9aM1tR1NUlgoAiJ78L2O5zhokqWvsCwpLSEar5CQYO8nx2DkrGcCNrrzTjbzA)tuMCeS80fmAfWliwUm8cIL5tjA9AWDgfL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cIL7xyaQ(Y0rw1igk9L5Kqo)LdOQceiJqq3JcjXaqAofsy09BsN1p4HTEaRCovzu(MlVZxAJMNDyzTjbzA)tuMCeS80fmAfWliwUm8cILZnFPnAE2HL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cIL7x4bq1xMoYQgXqPVmNeY5VSqHitaNpAqXyaHitY36PK1NbTCovzu(MlhW9PcmDYyzTjbzA)tuMCeS80fmAfWliwUm8cILbCCFQwVPtglRbJ46WcNhAgazqlRbDNIiHUQVFztuXKUPtleejFvlpDb4fel3VWuUQVmDKvnIHsFzojKZFza16)nIKFmScDaxHQ8rXisw1igSEATEvfiqgDkHasagUdCuz26P16buRxvbcKrcMeNt6gvMTEATEHcbTEknS1pu5CQYO8nxoG7tfy6KXYAtcY0(NOm5iy5Ply0kGxqSCz4feld44(uTEtNmA9umJcL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cIL7x4mOvFz6iRAedL(YCsiN)Y)grYpgwHoGRqv(OyejRAedwpTwVQceiJoLqajad3boQmB90A9P7IHJgYyyf6aUcv5JIrbcUsIZ6hS1piRNwRxOqqRNsdB9dvoNQmkFZLd4(ubMozSS2KGmT)jktocwE6cgTc4felxgEbXYaoUpvR30jJwpfZtHYAWiUoSW5HMbqg0YAq3PisOR67x2evmPB60cbrYx1YtxaEbXY9lCww1xMoYQgXqPVmNeY5VCavvGazec6EuijgasZPqcJUFt6SEkz9aM1tR1NUlgoAiJ78L2O5zhokqWvsCwpLg26bSY5uLr5BUme09Oqsma09cPoSS2KGmT)jktocwE6cgTc4felxgEbXYasO7rHKyW65xi1HL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cIL7x4S8vFz6iRAedL(YCsiN)YbuvbcKriO7rHKyainNcjm6(nPZ6h8Ww)qLZPkJY3Cz3PebkWDgfL1MeKP9przYrWYtxWOvaVGy5YWliwMpLO1Rb3zuy9umJcL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cIL7x4SHQ(Y0rw1igk9L5Kqo)LdOQceiJUtjcuG7mkgvMTEATEa16dOQceiJqq3JcjXaqAofsyuzUCovzu(MldbDpkKedaDVqQdlRnjit7FIYKJGLNUGrRaEbXYLHxqSmGe6EuijgSE(fsDO1tXmkuwdgX1Hfop0maYGwwd6ofrcDvF)YMOIjDtNwiis(QwE6cWliwUFHZaevFz6iRAedL(YCsiN)YbuvbcKr3PebkWDgfJkZwpTwFavvGazec6EuijgasZPqcJUFt6S(bpS1NvoNQmkFZLDPtryab6EHuhwwBsqM2)eLjhblpDbJwb8cILldVGyzoDkcdO1ZVqQdlRbJ46WcNhAgazqlRbDNIiHUQVFztuXKUPtleejFvlpDb4fel3VWzdQ6lthzvJyO0xMtc58xoGQkqGm6oLiqbUZOyuz26P16dOQceiJqq3JcjXaqAofsy09BsN1p4HT(SY5uLr5BUCkU0ijga6OUHJgxzTjbzA)tuMCeS80fmAfWliwUm8cILnfxAKedwptDdhnUYAWiUoSW5HMbqg0YAq3PisOR67x2evmPB60cbrYx1YtxaEbXY9lCgGv9LPJSQrmu6lNtvgLV5YbeImIL1MeKP9przYrWYtxWOvaVGy5YWliwgWriYiwwdgX1Hfop0maYGwwd6ofrcDvF)YMOIjDtNwiis(QwE6cWliwUFHZaO6lthzvJyO0xMtc58xEtVuleisqqj6S(bpS1NVCovzu(MlN2ye4ME5ragLUVS2KGmT)jktocwE6cgTc4felxgEbXYM2y06ZLE5rS(bu6(Y5egCLjlio8azjOjR34eQx0SXS(CuE6gyznyexhw48qZaidAznO7uej0v99lBIkM0nDAHGi5RA5PlaVGyzwcAY6noH6fnBmRphLNU(foBau9LPJSQrmu6lZjHC(lJuMICEgdJpveOK4EHs6pHdiKtr8ubgrN7iLZPkJY3C50gJa30lpcWO09L1MeKP9przYrWYtxWOvaVGy5YWliw20gJwFU0lpI1pGs3B9umJcLZjm4ktwqC4bYsqtwVXjuVOzJz9sI7fkP)eUbwwdgX1Hfop0maYGwwd6ofrcDvF)YMOIjDtNwiis(QwE6cWliwMLGMSEJtOErZgZ6Le3lus)jC9lCgLR6lthzvJyO0xMtc58xgqT(FJi5htR7Lg2)eJizvJyW6P16buRhPmf58mggFQiqjX9cL0FchqiNI4PcmIo3rkNtvgLV5YPngbUPxEeGrP7lRnjit7FIYKJGLNUGrRaEbXYLHxqSSPngT(CPxEeRFaLU36PyEkuoNWGRmzbXHhilbnz9gNq9IMnM17(LewryGL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cILzjOjR34eQx0SXSE3VKWkc9lCEOvFz6iRAedL(YCsiN)Y)grYpMw3lnS)jgrYQgXG1tR1dOwpszkY5zmm(urGsI7fkP)eoGqofXtfyeDUJuoNQmkFZLtBmcCtV8iaJs3xwBsqM2)eLjhblpDbJwb8cILldVGyztBmA95sV8iw)akDV1tXHOq5CcdUYKfehEGSe0K1BCc1lA2ywFADV0W(NyGL1GrCDyHZdndGmOL1GUtrKqx13VSjQys30PfcIKVQLNUa8cILzjOjR34eQx0SXS(06EPH9pr)(LHxqSmlbnz9gNq9IMnM1BajOqM63c]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170624.232908, [[diKHraqicuwePs1MusmksrDksrULssyxkLHPuDmk1YespJuX0OKsxJeSnLK6BeY4iq15ivkTosiMhLuCpsiTpkP6GkPwib8qGQjsGCrsKnscvDssHzsQuCtHANq1pjHkgkjuPLsOEkQPcfxLekBLe1xvsI2R0FjObdQdt1IjPhdyYuCzKnleFMu1OPeNMOxdKzRWTfSBv(TOHdLooPswoKNROPRQRReBhO8DkjNNuA9kjP9dY1UykZaij2VCzbrr8LXxbklMgKpPIhD3w0(QJATBr1XwHO6uMXsasFixv)L5v8OkeT8AGxM3SykUDXuwPZvhKPcuMbqsSF5p1RFqBY7jeAb7plVwvoKV2Yb5zegbr0QsL14msa)tu5lpQCCAu2r4EGkxg3du5y5zGGv8iIwvQSyAq(KkE0DBr27LftZCbbqZIPFzWTqaGItWOaDFvlhNgCpqL7x8OftzLoxDqMkqzgajX(LrlNeqi20kcTzOisa5dbBDi4O7LxRkhYxBzhb4hj8teIUVSgNrc4FIkF5rLJtJYoc3du5Y4EGkVgb4hbbJjri6(YIPb5tQ4r3TfzVxwmnZfeanlM(Lb3cbakobJc09vTCCAW9avUFX1PykR05QdYubkZaij2V8N61pOnGmhM0QBwETQCiFTLvhzAegzbPTSgNrc4FIkF5rLJtJYoc3du5Y4EGklWitdeSIFbPTSyAq(KkE0DBr27LftZCbbqZIPFzWTqaGItWOaDFvlhNgCpqL7xCRTykR05QdYubkZaij2V8N61pOnGmhM0QBwETQCiFTLvj0KqGKN(YACgjG)jQ8Lhvoonk7iCpqLlJ7bQSaeAsiqYtFzX0G8jv8O72IS3llMM5ccGMft)YGBHaafNGrb6(Qwoon4EGk3V4kumLv6C1bzQaLzaKe7x(t96h0g28L5nHGxbcwZqWQlrISTCwYHwHZhrN(3Y2cwiynvETQCiFTLXMVmVYACgjG)jQ8Lhvoonk7iCpqLlJ7bQSIB(Y8klMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(fF1ftzLoxDqMkqzgajX(Lfmiyt(BGjrld6EHyhU(fA7LaGKN(YRvLd5RTCU8QiYbvwJZib8prLV8OYXPrzhH7bQCzCpqLvCwEve5GkVgPFw(DKE6fkJOOcMj)nWKOLbDVqSdx)cT9saqYtFzX0G8jv8O72IS3llMM5ccGMft)YGBHaafNGrb6(Qwoon4EGk3V4IkMYkDU6GmvGYmasI9l)PE9dAdiZHjT6MLxRkhYxBzhf0kmJi8TqcnKBkRXzKa(NOYxEu540OSJW9avUmUhOYRrbTqWzei43cbbliYnLftdYNuXJUBlYEVSyAMliaAwm9ldUfcauCcgfO7RA540G7bQC)Il4ftzLoxDqMkqzgajX(LjDTiXILmB26iAxKcqWRabdK5WKwDBghbsOJuLpH2quWL3ec26qW2RwHYRvLd5RTSXrGe(i)MrsuWFzEL14msa)tu5lpQCCAu2r4EGkxg3duzb5iqqWyq(nJKOG)Y8klMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(fx3wmLv6C1bzQaLzaKe7xM01IelwYSzRJODrkabVceSGbb)(GUFBAXnPvcLxKLPmVn6C1bzGGxbcgiZHjT62mocKqhPkFcTHOGlVjeS1HGvqHYRvLd5RTSXrGe(i)MrsuWFzEL14msa)tu5lpQCCAu2r4EGkxg3duzb5iqqWyq(nJKOG)Y8GG1STMklMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(f3EVykR05QdYubkZaij2VmPRfjwSKzZwhr7IuacEfi43h09BtlUjTsO8ISmL5TrNRoide8kqWazomPv3MXrGe6iv5tOnefC5nHGToeSokuETQCiFTLnocKWh53msIc(lZRSgNrc4FIkF5rLJtJYoc3du5Y4EGklihbccgdYVzKef8xMheSMJQPYIPb5tQ4r3TfzVxwmnZfeanlM(Lb3cbakobJc09vTCCAW9avUFXTTlMYkDU6GmvGYmasI9lt6ArIflz2S1r0UifGGxbc(DKE63EzGe(PqJKGGTgiyGmhM0QBZ4iqcDKQ8j0gIcU8MqWRciybV8Av5q(AlBCeiHpYVzKef8xMxznoJeW)ev(YJkhNgLDeUhOYLX9avwqoceemgKFZijk4VmpiynRJMklMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(f3oAXuwPZvhKPcuMbqsSFzsxlsSyjZMToI2fPae8kqWazomPv32CjeYtOEhPp1oOnefC5nHGToeS9Q3lVwvoKV2Yghbs4J8Bgjrb)L5vwJZib8prLV8OYXPrzhH7bQCzCpqLfKJabbJb53msIc(lZdcwZwRMklMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(f3wNIPSsNRoitfOmdGKy)YKUwKyXsMnBDeTlsbi4vGGfmi43h09BtlUjTsO8ISmL5TrNRoide8kqWazomPv32CjeYtOEhPp1oOnefC5nHGToeSckuETQCiFTLnocKWh53msIc(lZRSgNrc4FIkF5rLJtJYoc3du5Y4EGklihbccgdYVzKef8xMheSMvqtLftdYNuXJUBlYEVSyAMliaAwm9ldUfcauCcgfO7RA540G7bQC)IBBTftzLoxDqMkqzgajX(LjDTiXILmB26iAxKcqWRab)(GUFBAXnPvcLxKLPmVn6C1bzGGxbcgiZHjT62MlHqEc17i9P2bTHOGlVjeS1HG1rHYRvLd5RTSXrGe(i)MrsuWFzEL14msa)tu5lpQCCAu2r4EGkxg3duzb5iqqWyq(nJKOG)Y8GG18Q1uzX0G8jv8O72IS3llMM5ccGMft)YGBHaafNGrb6(Qwoon4EGk3V42kumLv6C1bzQaLzaKe7xM01IelwYSzRJODrkabVce87i90V9Yaj8tHgjbbBnqWazomPv32CjeYtOEhPp1oOnefC5nHGxfqWcE51QYH81w24iqcFKFZijk4VmVYACgjG)jQ8Lhvoonk7iCpqLlJ7bQSGCeiiymi)MrsuWFzEqWAwKMklMgKpPIhD3wK9EzX0mxqa0Sy6xgCleaO4emkq3x1YXPb3du5(f3E1ftzLoxDqMkqzgajX(LfmiysxlsSyjZMToI2fPae8kqWOLJGGTgffcwNYRvLd5RTSXrGe(i)MrsuWFzEL14msa)tu5lpQCCAu2r4EGkxg3duzb5iqqWyq(nJKOG)Y8GG1SGRPYIPb5tQ4r3TfzVxwmnZfeanlM(Lb3cbakobJc09vTCCAW9avUFXTfvmLv6C1bzQaLzaKe7xgTCeeS1OOqW6uETQCiFTLvhs9wEYieTCKqRihBEL14msa)tu5lpQCCAu2r4EGkxg3duzbgs9wEYablE5ii4vj5yZRSyAq(KkE0DBr27LftZCbbqZIPFzWTqaGItWOaDFvlhNgCpqL7xCBbVykR05QdYubkZaij2V87d6(nJJaj0rQYNqB05QdYabVcemw63aZhG0IeQ6)pOGln0T5aVemQ8Av5q(AlJwoHoWlZt4qo)YACgjG)jQ8Lhvoonk7iCpqLlJ7bQS4LdcEnWlZdcw3iNF51i9ZYNhifv3zzaCiyf7SKdTkcemy(aKwKUxwmniFsfp6UTi79YIPzUGaOzX0Vm4wiaqXjyuGUVQLJtdUhOYSmaoeSIDwYHwfbcgmFaslQFXT1TftzLoxDqMkq51QYH81wgWhdHoWlZt4qo)YACgjG)jQ8Lhvoonk7iCpqLlJ7bQm4(yabVg4L5bbRBKZV8AK(z5ZdKIQ7SmaoeSIDwYHwfbcwpDescO7LftdYNuXJUBlYEVSyAMliaAwm9ldUfcauCcgfO7RA540G7bQmldGdbRyNLCOvrGG1thHKa97xg3duzwgahcwXol5qRIabBOi(Y473c]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170624.232908, [[diZBcaGEjrTlqX2arnBfDtk13Kc7KQ2lz3OSFe1WKQ(TWqLemyKy4G0brQogLSqjPLkvwmfwUsEii8uvlJIEUsnrqPPkLMmvMoWfbvUQKqpdP46sQ2kcAZGQ2ocCAuDzOPjjY3rk1Jv42smAe5WIojc1NLuUgiY5rsVgH8xPO1HuYYsT6FS4qb66WIWN1NavvVdNyUr5n7TA0dzZkbJjnwqYKg9dfh8CYRCc4btEtizQtFa4bBRw5TuRoCS0yIovv)Jfhkqhe1QnryGgaEW260n4toGQo0aWdMoXmhFKGyPZcgQBhocZLplOUUplOEfcapy6D4eZnkVzVvdRE9oCh1xdCRwb0HGeoiYoialididD7W5ZcQlG8MQvhowAmrNQQt3Gp5aQ6RKVXMomD6eZC8rcILolyOUD4imx(SG66(SG6DjFJKPalMo9oCI5gL3S3QHvVEhUJ6RbUvRa6qqchezheGfKbKHUD48zb1fqEAuRoCS0yIovv)Jfhkqhe1QnrygrmDbTzBD6g8jhqvpxfQnd4BciHnDy60jM54JeelDwWqD7WryU8zb119zb1PVkujtjGNmfajKmfyX0P3Htm3O8M9wnS617WDuFnWTAfqhcs4Gi7GaSGmGm0TdNplOUacO7ZcQFEbcYuQiJumPslYuGUWrumsGasa]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170624.232908, [[dWZbgaGEafTjjsSlI02auzFsK0mbuy2s6Ms40O6BsvDzv7uk7LA3iTFb(jcrddr9BqpwKZtidMedhfoirCkjs1XKkpNulefzPOKftslxOfHq4PqldLADOOAIaknvezYIA6kDra5Qse9muuUUG2iGQ2kbSza2UuLdR47suFMqnpjc)LO62anAc61i4KeOPHqQRHq5Eiu9qIY4qizusKYUZKmIPiNXA0iWEatyDntgz96h9DJn5U(Kbo2eTu2mRJySzMrKXt8PYbMZYHu3ytm2gLKwoKQnj36mjJarh16ZMjJsu5v(kYy(ZkuEcYRgfKM5PzHrJui9glGzbMyBaVrJTb8gb2pRWafzqE1iRx)OVBSj31VJSrwxddJPRnjVgLj8jcfWEh801QglG52aEJEDJTjzei6OwF2mzetroJ1y(QHaaifW17JCQy5LHH0Su9ojcbkepqHOmkrLx5RiJddyAQIyOVrbPzEAwy0ifsVXcywGj2gWB0yBaVrjmGPPkIH(gz96h9DJn5U(DKnY6AyymDTj51OmHprOa27GNUw1ybm3gWB0RBmZKmceDuRpBMmIPiNXAmF1qaaKc469rovS8YWqAwQENeHaLseOqubkLsGsccRzyzQ0Hbmnvrm0xA8GdNQdukrGcXmkrLx5RiJaUEFKtflxVroHBuqAMNMfgnsH0BSaMfyITb8gn2gWBe4VEFKtfhOGBKt4gz96h9DJn5U(DKnY6AyymDTj51OmHprOa27GNUw1ybm3gWB0RBeTjzei6OwF2mzetroJ14KwEVl)0dYVoqPujEGcBJsu5v(kYyAQv5tA5qQ8kxVgfKM5PzHrJui9glGzbMyBaVrJTb8gLn1AGIK0YH0afGbxVgLefRnshWtCIa5GYcukjviSkI5bksisGicJSE9J(UXMCx)oYgzDnmmMU2K8AuMWNiua7DWtxRASaMBd4nICqzbkLKkewfX8afjejqEDJyMKrGOJA9zZKrmf5mwJ5RgcaGuaxVpYPILxggsZs17KieOucIhOWmJsu5v(kYiGR3h5uXY1BKt4gfKM5PzHrJui9glGzbMyBaVrJTb8gb(R3h5uXbk4g5eEGsP1v6gz96h9DJn5U(DKnY6AyymDTj51OmHprOa27GNUw1ybm3gWB0RBaNjzei6OwF2mzetroJ1y(QHaaifW17JCQy5LHH0S0qggLOYR8vKrDcggfF56nYjCJcsZ80SWOrkKEJfWSatSnG3OX2aEJycggf)afCJCc3iRx)OVBSj31VJSrwxddJPRnjVgLj8jcfWEh801QglG52aEJEDRVjzei6OwF2mzetroJ1y(QHaaifW17JCQy5LHH0S0qggLOYR8vKXuDkZPILRfozyzTrbPzEAwy0ifsVXcywGj2gWB0yBaVrz1PmNkoqbfozyzTrwV(rF3ytURFhzJSUgggtxBsEnkt4tekG9o4PRvnwaZTb8g961yBaVrKdklqPKuHWQiMhO0BQeef9Ad]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170624.232908, [[dGtIeaGEbO2Ksr2fPQTjaSpuOzJuZxaDtr5Bis7uj7LA3e2VugfOIHHK(njdwQgok5GkLoLsvDmr1PvSquWsrPwSqTCeEOsLNcTmH8CqMiIWurIjt00bUOGCvbqpduPRlqxw1wjfTzqv2oPYJr19qe9zb13vkCBr(lOmAe1HLCssHPbQQRPuLZtk9Au06ukQFkazNBkgroXWcy0ijo8QG0aZGr2N(f09kIAoPudGi4RpcU57fbxJiRZNIEc4cmkHxr7fzClhmkbKP4vUPymKOIPV0mye5edlGXIdgDh2fpnhQ1zKKTEKXTXd9a0Au(cqgwjKWKNxAnQHqo8cOimkuIBmtj1Siwv6gnUQ0nsIxaYTEjKTojoV0AK9PFbDVIOMtAovJSpKkib)qMIbg3r(CMzkDpDbWXgZuYvLUrd8kYumgsuX0xAgmICIHfWyXbJUd7INMd16m26W3424HEaAnEwJ8PHBudHC4fqryuOe3yMsQzrSQ0nACvPBmeRr(0WnY(0VGUxruZjnNQr2hsfKGFitXaJ7iFoZmLUNUa4yJzk5Qs3ObEbxtXyirftFPzWiYjgwaJfhm6oSlEAouRZijB9OwFtToCADPcOx(cqgwjKWKNxA1dgoZreU1dmWwxQa6LhEd91dgoZreU133424HEaAncXvbjcFyqaIH5nQHqo8cOimkuIBmtj1Siwv6gnUQ0nICvqIWV1raXW8gzF6xq3RiQ5KMt1i7dPcsWpKPyGXDKpNzMs3txaCSXmLCvPB0aVGVPymKOIPV0mye5edlGXIdgDh2fpnhQ1zKKTEuRVPwhoTUub0lFbidResyYZlT6bdN5ic36bgyRlva9YdVH(6bdN5ic367BCB8qpaTg501gJimmiYLuTbKrneYHxafHrHsCJzkPMfXQs3OXvLUXD01gJiCRJKlPAdiJSp9lO7ve1CsZPAK9Hubj4hYumW4oYNZmtP7Plao2yMsUQ0nAGx7zkgdjQy6lndgroXWcyS4Gr3HDXtZHADgB9iJBJh6bO14znYNgUrneYHxafHrHsCJzkPMfXQs3OXvLUXqSg5tdV1Ht((gzF6xq3RiQ5KMt1i7dPcsWpKPyGXDKpNzMs3txaCSXmLCvPB0admUQ0nItAxRhGcYkATBU13gqHmWga]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170624.232908, [[dSZCmaGEvfsBsqTlsSnvfQ9PQ0SLQBkLEUi3MKoSKDIu7vz3q2pPgLQIggk14evuTmkLZRQYGPy4uIdrjvNsvvoMOCokPSqQclLQ0IrYYr1dfv9uIhl06uvv1efvyQuQMmvMUkxuaUQQcXZuvW1rXgfvu2QaAZuvBxG60i(gLKPjQiZtvvLpliVwvA0QI)kfNuG8DuY1uvvUNOsxg8BOoivrVSzFIe5el3Kj5a8lM(npMqxQWeHOMxB(iOhC)3)RnPRqUI7M4f6qLGrBJDMvS)yB5KITpK9pBFyIxOC)StuHjCgeKuoIk0C4gBt8mEemkn7JoB2NeaQO6GBEmrICILBIdOy89v8H0bCckudlmdYPKUk(Qn)xUAJnTjS2WzqKyJfmlGR4aFsKCAZxT5Ft8KI0j3Vj(q6aobfQjDCYlmjiKJeRdZNGWiysl2fyXPlvyYe6sfMKZG0bCckK2ihN8ct8cDOsWOTXoZQm2t8cjmdpcPzF3K8pq8TfhmOcOButAXo6sfMSB02M9jbGkQo4MhtKiNy5MyDTHIX3xbbroorskmw0MWAZvDaDkiiYXjssbqfvhCAtyTHZGaT5)YvB(WepPiDY9BIdQ7PjIj9jbHCKyDy(eegbtAXUaloDPctMqxQWKCa19On5XK(eVqhQemABSZSkJ9eVqcZWJqA23nj)deFBXbdQa6g1KwSJUuHj7g9hM9jbGkQo4MhtKiNy5MqX47RGGihNijfglAtyTXbum((k(q6aobfQHfMb5usxfF1MV5QnzAtyTHZGiXglywaxXb(Ki50MVAJ1M4jfPtUFtsrmdpe0Koo5fMeeYrI1H5tqyemPf7cS40LkmzcDPctKiMHhc0g54KxyIxOdvcgTn2zwLXEIxiHz4rin77MK)bIVT4GbvaDJAsl2rxQWKDJoNM9jbGkQo4MhtKiNy5MqX47RGGihNijfglAtyTXbum((k(q6aobfQHfMb5usxfF1MV5QnzAtyTHZGiXglywaxXb(Ki50MVAJ1M4jfPtUFtI9IfbfQj9uomR0KGqosSomFccJGjTyxGfNUuHjtOlvys(EXIGcPnYt5WSst8cDOsWOTXoZQm2t8cjmdpcPzF3K8pq8TfhmOcOButAXo6sfMSB0)B2NeaQO6GBEmrICILBcfJVVcd6b3)1KooGcDpkmw0MWAJdOy89v8H0bCckudlmdYPKUk(QnFZvBY0MWAdNbrInwWSaUId8jrYPnF1gRnXtksNC)MKIygEiOjDCYlmjiKJeRdZNGWiysl2fyXPlvyYe6sfMirmdpeOnYXjVG28z2Ft8cDOsWOTXoZQm2t8cjmdpcPzF3K8pq8TfhmOcOButAXo6sfMSB0F8Spjaur1b38yIe5el3ekgFFfg0dU)RjDCaf6EuySOnH1ghqX47R4dPd4euOgwygKtjDv8vB(MR2KPnH1godIeBSGzbCfh4tIKtB(QnwBINuKo5(nj2lweuOM0t5WSstcc5iX6W8jimcM0IDbwC6sfMmHUuHj57flckK2ipLdZkPnFM93eVqhQemABSZSkJ9eVqcZWJqA23nj)deFBXbdQa6g1KwSJUuHj7gTvZ(KaqfvhCZJjsKtSCt4miqB(MR2ytBcRnoGIX3xXhshWjOqnSWmiNs6Q4R28nxTjtBcRnCgej2ybZc4koWNejN28vBS2epPiDY9BskIz4HGM0XjVWKGqosSomFccJGjTyxGfNUuHjtOlvyIeXm8qG2ihN8cAZN2(BIxOdvcgTn2zwLXEIxiHz4rin77MK)bIVT4GbvaDJAsl2rxQWKDJoNp7tcavuDWnpMiroXYnHZGaT5BUAJnTjS24akgFFfFiDaNGc1WcZGCkPRIVAZ3C1MmTjS2WzqKyJfmlGR4aFsKCAZxTXAt8KI0j3VjXEXIGc1KEkhMvAsqihjwhMpbHrWKwSlWItxQWKj0LkmjFVyrqH0g5PCywjT5tB)nXl0HkbJ2g7mRYypXlKWm8iKM9DtY)aX3wCWGkGUrnPf7OlvyYUrBTzFsaOIQdU5XejYjwUjx1b0PKEkhMvdb5ZKiyKcGkQo40MWAZvDaDkUI)2uCkYbCfavuDWPnH1gRRnum((kUI)2C8cL8XC16iyKcJfTjS2eX4UdZcP4k(BtXPihWv4GArqjT5R2KXEINuKo5(nXb190eXK(KGqosSomFccJGjTyxGfNUuHjtOlvysoG6E0M8ysxB(m7VjEHoujy02yNzvg7jEHeMHhH0SVBs(hi(2Idgub0nQjTyhDPct2n6m2Z(KaqfvhCZJjsKtSCtUQdOtj9uomRgcYNjrWifavuDWPnH1gRRnx1b0P4k(BtXPihWvaur1bN2ewBSU2qX47R4k(BZXluYhZvRJGrkmwM4jfPtUFtCqDpnrmPpjiKJeRdZNGWiysl2fyXPlvyYe6sfMKdOUhTjpM01MpT93eVqhQemABSZSkJ9eVqcZWJqA23nj)deFBXbdQa6g1KwSJUuHj7gDw2Spjaur1b38yIe5el3KR6a6uCf)TP4uKd4kaQO6GtBcRnrmU7WSqkUI)2uCkYbCfoOweusB(QnzSN4jfPtUFtCqDpnrmPpjiKJeRdZNGWiysl2fyXPlvyYe6sfMKdOUhTjpM01Mp)WFt8cDOsWOTXoZQm2t8cjmdpcPzF3K8pq8TfhmOcOButAXo6sfMSB0z2M9jbGkQo4MhtKiNy5MyDT5QoGoL0t5WSAiiFMebJuaur1bN2ewBSU2CvhqNIR4VnfNICaxbqfvhCt8KI0j3VjoOUNMiM0NeeYrI1H5tqyemPf7cS40LkmzcDPctYbu3J2Kht6AZN50Ft8cDOsWOTXoZQm2t8cjmdpcPzF3K8pq8TfhmOcOButAXo6sfMSB3eXcejvN8rRJGrJ22)STBda]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170624.232908, [[dStujaGEvcQnju2fj2MkHAFKIMTOUPk1Pr8nuPUmyNO0Ev2nu7NsJcfPHrfgNkr1JfCpikdMIHtQCqsjNcvIJbHZPsuwiPulLkAXqA5i9qHQNsSmuX6ujiteIQPsQAYu10L6IuP6QQeWZqrDDu1gvjqBLkXMfY2Ps6VQWNvjnnvImpvc52K0RvrJgfoSKtsLY3HixdvsNNu45ICiue)wvpet)erheivMCHRM84XYHRCMGCiQ4Z90EItidvcglhhi42XfZ5skCygbx5W8ejqj66jt0k0KhNM(XIy6N4oUqZGFAprcuIUEIhq5JIuIGuduc(6bspp2RK6kCAnxeYSMlznXSgkpMeo09ibufpercK2A00A4W8eTqjzsRXKii1aLGVEKAk5eM4g2tcv)0j4hdtUFVlfLTuHjtylvyYfesnqj4RwJ0uYjmXjKHkbJLJdeCJWXeNq65Pbin9RNeNbeoVFxbva3dDY97zlvyY6XYz6N4oUqZGFAprcuIUEctSgu(OifmeOFIKu41znXSMUYaUvWqG(jssbWfAg8wtmRHYJbR5IqM1W8eTqjzsRXepunJJWtYtCd7jHQF6e8JHj3V3LIYwQWKjSLkmb5q1mSM4pjpXjKHkbJLJdeCJWXeNq65Pbin9RNeNbeoVFxbva3dDY97zlvyY6XY80pXDCHMb)0EIeOeD9eu(OifmeOFIKu41znXSgpGYhfPebPgOe81dKEESxj1v40A0ezwdZwtmRHYJjHdDpsavXdrKaPTgnTgomprlusM0AmjfEE6v4i1uYjmXnSNeQ(PtWpgMC)ExkkBPctMWwQWej880RG1inLCctCczOsWy54ab3iCmXjKEEAast)6jXzaHZ73vqfW9qNC)E2sfMSESxA6N4oUqZGFAprcuIUEckFuKcpMXN14i1uaFTzOWRZAIznEaLpksjcsnqj4Rhi98yVsQRWP1OjYSgMTMywdLhtch6EKaQIhIibsBnAAnCyEIwOKmP1ysk880RWrQPKtyIBypju9tNGFmm5(9Uuu2sfMmHTuHjs45PxbRrAk5eSgMIGltCczOsWy54ab3iCmXjKEEAast)6jXzaHZ73vqfW9qNC)E2sfMSESCD6N4oUqZGFAprcuIUEcLhdwJMiZA4ynXSgpGYhfPebPgOe81dKEESxj1v40A0ezwdZwtmRHYJjHdDpsavXdrKaPTgnTgomprlusM0AmjfEE6v4i1uYjmXnSNeQ(PtWpgMC)ExkkBPctMWwQWej880RG1inLCcwdt5WLjoHmujySCCGGBeoM4esppnaPPF9K4mGW597kOc4EOtUFpBPctwp2lE6N4oUqZGFAprcuIUEsxza3kjgL)r6GGJ4tKhRa4cndERjM10vgWTIVONhffL0avbWfAg8wtmRHjwdkFuKIVONhnTWPONQwn5Xk86SMywt4)S)rcR4l65rrrjnqvOGArWjRrtRbbxNOfkjtAnM4HQzCeEsEIBypju9tNGFmm5(9Uuu2sfMmHTuHjihQMH1e)jzRHPi4YeNqgQemwooqWnchtCcPNNgG00VEsCgq48(DfubCp0j3VNTuHjRhl3t)e3XfAg8t7jsGs01t6kd4wjXO8psheCeFI8yfaxOzWBnXSgMynDLbCR4l65rrrjnqvaCHMbV1eZAyI1GYhfP4l65rtlCk6PQvtEScVUjAHsYKwJjEOAghHNKN4g2tcv)0j4hdtUFVlfLTuHjtylvycYHQzynXFs2AykhUmXjKHkbJLJdeCJWXeNq65Pbin9RNeNbeoVFxbva3dDY97zlvyY6XE5t)e3XfAg8t7jsGs01t6kd4wXx0ZJIIsAGQa4cndERjM1e(p7FKWk(IEEuuusdufkOweCYA00AqW1jAHsYKwJjEOAghHNKN4g2tcv)0j4hdtUFVlfLTuHjtylvycYHQzynXFs2AykZCzItidvcglhhi4gHJjoH0ZtdqA6xpjodiCE)UcQaUh6K73ZwQWK1J9YM(jUJl0m4N2tKaLORNWeRPRmGBLeJY)iDqWr8jYJvaCHMbV1eZAyI10vgWTIVONhffL0avbWfAg8t0cLKjTgt8q1mocpjpXnSNeQ(PtWpgMC)ExkkBPctMWwQWeKdvZWAI)KS1W0lXLjoHmujySCCGGBeoM4esppnaPPF9K4mGW597kOc4EOtUFpBPctwVEcBPcteIACR5cGz8znUqwtOsn5A1pD9ga]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170624.232908, [[dSJwmaGEvkL2KOyxK02uPuTpvQMTkUPQ0Pr8nsOldTtuSxLDdA)umkvvAyOu)g4XcDpvkgmPgoj6qcqNsvfhtLCosqlKsXsPkTyKSCu9qrPNsSmQI1PsPyIcGPsPAYuz6sDrb0vvPK8mbPRJuBuLsQTkq2mv12fe)vu9zb10uPeZJei3MsETQYOvfhwYjfO(ok5AKaoVQQEUiJJeOoiLsVRzFIOeJK6qUTvtaWX4rb8mjaOFrF6zZeV4bReogpSVuK9T75wu9e6Lc4j0jsKtu2tMyBSjayA2hZ1SpjqyrDq3SzIe5eL9ehsr77R6JPg5ey4CwaAOtn1v8ZOvq3y0Em6mgnNgsI5kbSqUQd9jrsB03nAfyITuKdP)pXhtnYjWW5PMt(WjbdDKy1a(eiaItEbUGkotzHtMWuw4KBnMAKtGHnAP5KpCIx8GvchJh2xkEXEIxmbO5rmn7RNK9bJFVGqqle2JAYlWXuw4K1JXZSpjqyrDq3SzIe5eL9KaA0u0((QqmYbjssLwPrNXO76GWwfIroirsQiSOoOZOZy0CAiA0kOBm6qNylf5q6)tCy1p5ra5mjyOJeRgWNabqCYlWfuXzklCYeMYcNeaS6hJolGCM4fpyLWX4H9LIxSN4ftaAEetZ(6jzFW43lie0cH9OM8cCmLfoz9ycD2NeiSOoOB2mrICIYEcfTVVkeJCqIKuPvA0zmAhsr77R6JPg5ey4CwaAOtn1v8ZOVFJrhQrNXO50qsmxjGfYvDOpjsAJ(UrRWj2sroK()KueqZdJ5PMt(WjbdDKy1a(eiaItEbUGkotzHtMWuw4ejcO5HrJwAo5dN4fpyLWX4H9LIxSN4ftaAEetZ(6jzFW43lie0cH9OM8cCmLfoz9yULzFsGWI6GUzZejYjk7ju0((QqmYbjssLwPrNXODifTVVQpMAKtGHZzbOHo1uxXpJ((ngDOgDgJMtdjXCLawix1H(KiPn67gTcNylf5q6)tINIfbgop9uoaR0KGHosSAaFceaXjVaxqfNPSWjtyklCs2tXIadB0Yt5aSst8IhSs4y8W(sXl2t8IjanpIPzF9KSpy87fecAHWEutEboMYcNSEmkWSpjqyrDq3SzIe5eL9ekAFFvA4d48pp1CegUFuPvA0zmAhsr77R6JPg5ey4CwaAOtn1v8ZOVFJrhQrNXO50qsmxjGfYvDOpjsAJ(UrRWj2sroK()KueqZdJ5PMt(WjbdDKy1a(eiaItEbUGkotzHtMWuw4ejcO5HrJwAo5dn6FV(zIx8GvchJh2xkEXEIxmbO5rmn7RNK9bJFVGqqle2JAYlWXuw4K1J52N9jbclQd6MntKiNOSNqr77RsdFaN)5PMJWW9JkTsJoJr7qkAFFvFm1iNadNZcqdDQPUIFg99Bm6qn6mgnNgsI5kbSqUQd9jrsB03nAfoXwkYH0)NepflcmCE6PCawPjbdDKy1a(eiaItEbUGkotzHtMWuw4KSNIfbg2OLNYbyLm6FV(zIx8GvchJh2xkEXEIxmbO5rmn7RNK9bJFVGqqle2JAYlWXuw4K1JrXzFsGWI6GUzZejYjk7jCAiA03VXO9y0zmAhsr77R6JPg5ey4CwaAOtn1v8ZOVFJrhQrNXO50qsmxjGfYvDOpjsAJ(UrRWj2sroK()KueqZdJ5PMt(WjbdDKy1a(eiaItEbUGkotzHtMWuw4ejcO5HrJwAo5dn6F98ZeV4bReogpSVu8I9eVycqZJyA2xpj7dg)EbHGwiSh1KxGJPSWjRhJcE2NeiSOoOB2mrICIYEcNgIg99BmApgDgJ2Hu0((Q(yQrobgoNfGg6utDf)m673y0HA0zmAonKeZvcyHCvh6tIK2OVB0kCITuKdP)pjEkwey480t5aSstcg6iXQb8jqaeN8cCbvCMYcNmHPSWjzpflcmSrlpLdWkz0)65NjEXdwjCmEyFP4f7jEXeGMhX0SVEs2hm(9ccbTqypQjVahtzHtwpgfo7tcewuh0nBMirorzpPRdcB10t5aSYjqF6ebavryrDqNrNXO76GWw1v8V8ItrAKRIWI6GoJoJrhqJMI23x1v8V8MxWKpGBvnbavPvA0zm6iaCCawqvxX)YlofPrUkhTkcmz03n6l2tSLICi9)joS6N8iGCMem0rIvd4tGaio5f4cQ4mLfozctzHtcaw9JrNfqog9Vx)mXlEWkHJXd7lfVypXlMa08iMM91tY(GXVxqiOfc7rn5f4yklCY6XCXE2NeiSOoOB2mrICIYEsxhe2QPNYbyLtG(0jcaQIWI6GoJoJrhqJURdcBvxX)YlofPrUkclQd6m6mgDanAkAFFvxX)YBEbt(aUv1eauLw5eBPihs)FIdR(jpciNjbdDKy1a(eiaItEbUGkotzHtMWuw4KaGv)y0zbKJr)RNFM4fpyLWX4H9LIxSN4ftaAEetZ(6jzFW43lie0cH9OM8cCmLfoz9yUUM9jbclQd6MntKiNOSN01bHTQR4F5fNI0ixfHf1bDgDgJocahhGfu1v8V8ItrAKRYrRIatg9DJ(I9eBPihs)FIdR(jpciNjbdDKy1a(eiaItEbUGkotzHtMWuw4KaGv)y0zbKJr)BO)mXlEWkHJXd7lfVypXlMa08iMM91tY(GXVxqiOfc7rn5f4yklCY6XC5z2NeiSOoOB2mrICIYEsan6UoiSvtpLdWkNa9PteaufHf1bDgDgJoGgDxhe2QUI)LxCksJCvewuh0nXwkYH0)N4WQFYJaYzsWqhjwnGpbcG4KxGlOIZuw4KjmLfojay1pgDwa5y0)El)mXlEWkHJXd7lfVypXlMa08iMM91tY(GXVxqiOfc7rn5f4yklCY61tyklCIqSYA03k4d48)2y0eyQ50XgWtR3a]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170624.232908, [[deeIxaqievTjPsFcru1OquofI0UOIHrIoMiwgP0ZqeAAKQW1KkY2qeLVrcnosvkNdrK1rQsvZdrW9quzFKQKdscwiQQEivIjsQsLlsQQnsvv(iIOYiLkkNKkPBkvTtu5NsfvlLu8uktLuzRuv5RuvvTxL)svgmrhgyXi8yrnzqUSQnlL(mvLrJQCAuEnvQzl0Tb1UH63qgUuCCsv0Yr65cMUKRtsBxK67OQCErY6PQQmFPc7NWlz6MznpZarM)bkgcpoTDkzMLPSMA2m9U3cuJ14FMMhpi8XPvzIIkjzA1dhTKysN0sIZ0CaukDm4pJ8fiEC50srHkKtv8UZXaI4HesagsivkKiQqsO2264MfJmSppyqMhdFh6HbmCyMc5IHWHPBCjt3m9XaI4Hg)ZSmL1uZkKpFX7KrOieIpCqi7kKKjKKjKKxilq84YPLI8VJ9AuJH7CmGiEiHSJoesYesQk(cjjiKAfYUcjvfZYEni(o1jRsPhxcjjiKA1BcjPcjPczxHK8czbIhxo(afVtzyFEHcrHDogqepKqs6mfiyrwLAgIiYQtbfdHN5kgILbfIodJWFwpcYpaLda)zZ4aWFwNtez1PGIHWZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXPD6MPpgqep04FMLPSMAgHABRdlNYRareo4qpmGHdcjjiKjoDsi7kKfiEC5WYP8kqeHdohdiIhAMceSiRsnRLIcLxOOm3FMRyiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL5(Z084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXrIt3m9XaI4Hg)ZSmL1uZkq84YjWdu1PmSpVqrzUFW5yar8qczxHe6eQTTouG)HOS8Dcfi7wijNq2PzkqWISk1SwkkuEHIYC)zUIHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuM7lKKLq6mnpEq4JtRYeftuotZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTAC6X0ntFmGiEOX)mltzn1mYesc12whkd(oQnczxH86PkRP5qonNgE6tb489qTEfV7Dce2dgqRuuHSRqsEHKmHKqTT1brez1PGIHWoQnczxHeKlw67D8HzpiKKGqQvijvijvi7OdHSaXJlhFGI3PmSpVqHOWohdiIhAMceSiRsnJEyen84dbp(y460zUIHyzqHOZWi8N1JG8dq5aWF2moa8NP5WiA4XhccP)ZW1PZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QX1PPBM(yar8qJ)zwMYAQzeQTToug8DuBeYUcj5fsYesc12wherKvNckgc7O2iKDfsqUyPV3XhM9GqsccPwHKuHSRqsEHKmH86PkRP5qonNgE6tb489qTEfV7Dce2dgqRuuHSRqwG4XLJpqX7ug2NxOquyNJbeXdjKKotbcwKvPMXdXxKH95rebHAMRyiwgui6mmc)z9ii)auoa8NnJda)zDgIVid7ti5pcc1mnpEq4JtRYeftuotZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACKSPBM(yar8qJ)zwMYAQzeQTToug8DuBeYUcj5fsYesc12wherKvNckgc7O2iKDfsqUyPV3XhM9GqsccPwHKuHSRqE9uL10CiNMtdp9PaC(EOwVI39obc7bdOvkQq2vilq84YXhO4Dkd7ZluikSZXaI4HeYUcjzcj0juBBDAon80NcW57HA9kE37eiShmGwPOoQnczhDiKzekcH4d7qpmIgE8HGhFmCDQd9WagoiK6LqsIcjPZuGGfzvQz8q8fzyFEerqOM5kgILbfIodJWFwpcYpaLda)zZ4aWFwNH4lYW(es(JGqjKKLq6mnpEq4JtRYeftuotZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACkoDZ0hdiIhA8pZYuwtnJ8cjHABRdIiYQtbfdHDuBeYUcjzc51tvwtZHCCJIfJccE4Zxlsfd5XhlgfYUczbIhxoTuK)DSxJAmCNJbeXdjKDfsYeYWlpcewn4uSttijpTnzHKCczIq2rhcz4LhbcRgCk2PjKKNE0KfsYjKjcjPcjPczhDiKuv8dofd(EfYRtcjjiK(YqZuGGfzvQziIiRofuFMRyiwgui6mmc)z9ii)auoa8NnJda)zDorKvNcQptZJhe(40QmrXeLZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgNEB6MPpgqep04FMLPSMAwH85lENmcfHq8HdczxHKmHKmH86PkRP5qozeoGOvWlJIqEze9czhDiKeQTTonSyeq9qTETuuOCuBessfYUcjHABRJkMhkMYlu0J9v8CuBeYUcj0juBBDOa)drz57ekq2TqsoHStczxHK8cjHABRdIiYQtbfdHDuBessNPablYQuZcmmef4dfabVwvAQzUIHyzqHOZWi8N1JG8dq5aWF2moa8Nzmmef4dfaK8bH0FQ0uZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXrst3m9XaI4Hg)ZSmL1uZOQyw2RbX3PoqVLLzLqscKtituotbcwKvPM1srHYluuM7pZvmeldkeDggH)SEeKFakha(ZMXbG)m)rrHsiTIYCFHKmTKotZJhe(40QmrXeLZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgxIYPBM(yar8qJ)zwMYAQzeQTToiIiRofume2rTri7kKKxijuBBDCZIrg2NhmiZJHVJAZmfiyrwLAwlffkVqrzU)mxXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZ9fsYirsNP5XdcFCAvMOyIYzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJljz6MPpgqep04FMLPSMAgixS0374dZEqi1lYjKAfYUcj5fsYeYcepUCAPOqfYPkE35yar8qczxHKqTT1XnlgzyFEWGmpg(oQnczxHeKlw67D8HzpiK6f5esTcjPZuGGfzvQz0dJOHhFi4XhdxNoZvmeldkeDggH)SEeKFakha(ZMXbG)mnhgrdp(qqi9FgUovijlH0zAE8GWhNwLjkMOCMMhqQ08dt3QzUW7z39O0h(4AeZ6rqCa4pB14s0oDZ0hdiIhA8pZYuwtnJqTT1XnlgzyFEWGmpg(oQnczxHKmHK8c51tvwtZHCCJIfJccE4Zxlsfd5XhlgfYo6qib5IL(EhFy2dcPEroHuRqs6mfiyrwLAwlffQqovX7ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOc5ufVptZJhe(40QmrXeLZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgxcjoDZ0hdiIhA8pZYuwtndKlw67D8HzpiK6f5esTZuGGfzvQz(IGmde9aqPb48N5kgILbfIodJWFwpcYpaLda)zZ4aWFgjxeKzGOqQauAao)zAE8GWhNwLjkMOCMMhqQ08dt3QzUW7z39O0h(4AeZ6rqCa4pB14s0JPBM(yar8qJ)zwMYAQzGCXsFVJpm7bHuViNqsIZuGGfzvQzTuuOc5ufVpZvmeldkeDggH)SEeKFakha(ZMXbG)m)rrHkKtv8UqswcPZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXL0PPBM(yar8qJ)zwMYAQzeQTToUzXid7ZdgK5XW3rTzMceSiRsndrez1PG6ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pRZjIS6uqDHKSesNP5XdcFCAvMOyIYzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJlHKnDZ0hdiIhA8pZYuwtnRaXJlhFGI3PmSpVqHOWohdiIhsi7kKfiEC5aRsHofPg8EBllZooNY5yar8qczxHKmHm8YJaHvdof70esYtBtwijNqMiKD0HqgE5rGWQbNIDAcj5PhnzHKCczIqs6mfiyrwLAwlffkVqrzU)mxXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZ9fsY0dsNP5XdcFCAvMOyIYzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJlrXPBM(yar8qJ)zwMYAQzKjKfiEC5WdrXEOwp(y46uNJbeXdjKD0HqwG4XLdpvSVtzyFEuv8947Gge25yar8qcjPczxHKmHm8YJaHvdof70esYtBtwijNqMiKD0HqgE5rGWQbNIDAcj5PhnzHKCczIqs6mfiyrwLAwlffkVqrzU)mxXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZ9fsY6ePZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXLO3MUz6JbeXdn(NPablYQuZqerwDkO(mxXqSmOq0zye(Z6rq(bOCa4pBgha(Z6CIiRofuxijtlPZ084bHpoTktumr5mnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXLqst3m9XaI4Hg)ZuGGfzvQz(IGmde9aqPb48N5kgILbfIodJWFwpcYpaLda)zZ4aWFgjxeKzGOqQauAaoFHKSesNP5XdcFCAvMOyIYzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJtRYPBM(yar8qJ)zwMYAQzKxijuBBD4PI9Dkd7ZJQIVhFh0GWoQnZuGGfzvQz8quShQ1JpgUoDMRyiwgui6mmc)z9ii)auoa8NnJda)zDgIIfsuRq6)mCD6mnpEq4JtRYeftuotZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACAtMUz6JbeXdn(NPablYQuZAPOq5fkkZ9N5kgILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzUVqsgjJ0zAE8GWhNwLjkMOCMMhqQ08dt3QzUW7z39O0h(4AeZ6rqCa4pB140QD6MPpgqep04FMLPSMAwH85lENmcfHq8HdZuGGfzvQzhUbX3PEuv8947GgeEMRyiwgui6mmc)z9ii)auoa8NnJda)z6d3G47uHuJk(cP)FqdcptZJhe(40QmrXeLZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgNwsC6MPpgqep04FMLPSMAwH85lENmcfHq8HdczxHKmHK8cjHABRdpvSVtzyFEuv8947Gge2rTrijDMceSiRsnJNk23PmSppQk(E8DqdcpZvmeldkeDggH)SEeKFakha(ZMXbG)Sotf77ug2NqQrfFH0)pObHNP5XdcFCAvMOyIYzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvRMXbG)mJb7Iq6pkku69cPVJpLLxTba]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170624.232908, [[d8tXtaGmHQ1tfbBcISls12esL9brzMcPQtJQztvZNks3ekDzIVrf68urTtszVGDRQ9JYOeunme8BjpNKHkqYGrA4qXbvQ6uckhdchxGuwivWsfIfdvlxLfPujpLYJLY6eKAIcKQPkGjlvtxXffkoSONjKY1vsBuPITkuAZuPTlq9ALs)fstJkIMNsL6ZkXTr0OrOVlioPqYHGO6AcsUNaXdvkghveQZrfHmGacawqxCZv)aoaM1ooMbmWmmsJNEUtihE9Gw8qHaSiIxsLaAXjGWrcrxCNupE0qeQ4rdSis2DoaNua7wFEdftfIC6UP3RqNcnUJGTVn86vqaqdbeaSy(e3lDWbWS2XXmGn1YIx05)i3TIzuGThN75JZGrY)oQ7jItqalQVZB5uhyF9cyyRES5PLKcyGPLKcyy5FNr35eXjiGfr8sQeqlobeoIGayrevTEnrbbGbSneL2wSvWcP8dGdg2QRLKcyWaAXHaGfZN4EPdoaM1ooMbSB95numviYP3fxEJpmkYy04eyuKyuKZOt6LF0XpjhIOLlQI)9lxkvQlFI7Loy7X5E(4my51YxqN6o5hWI678wo1b2xVag2QhBEAjPagyAjPa2(RLVWObQ7KFalI4LujGwCciCebbWIiQA9AIccadyBikTTyRGfs5hahmSvxljfWGb0IgeaSy(e3lDWbWS2XXmGnPx(rh)KCiIwUOk(3VCPuPU8jUx6mksmAVgD8tYHiA5IQ4F)YLsL6dVTL)lmksm6T(8gkMke50BR3j)WO7MrJgbgfjg9wFHr3nJghS94CpFCgS8A5lOtDN8dyr9DElN6a7RxadB1JnpTKuadmTKuaB)1Yxy0a1DYpmA4icdSiIxsLaAXjGWreealIOQ1RjkiamGTHO02ITcwiLFaCWWwDTKuadgqZjHaGfZN4EPdoaM1ooMbSPww8IERkFVc5vmksmA4mk(QRRogU3NhA5I6ELA0xXWOHb2ECUNpodgUVQoQ765myr9DElN6a7RxadB1JnpTKuadmTKuaZbFvDgDN1ZzWIiEjvcOfNachrqaSiIQwVMOGaWa2gIsBl2kyHu(bWbdB11ssbmyaTqbbalMpX9shCamRDCmdytTS4f9wv(EfYRyuKy0Wzu8vxxDmCVpp0Yf19k1OVIHrddS94CpFCgmC5uYTL)lGf135TCQdSVEbmSvp280ssbmW0ssbmhKtj3w(VaweXlPsaT4eq4iccGfru161efeagW2quABXwblKYpaoyyRUwskGbdOfDqaWI5tCV0bhaZAhhZa2T(IsF4Kc6uOHIr3nJgngfjgnCgf5mAVgD8tYHiA5IQ4F)YLsL6dVTL)lmQtDkJERpVHIPcro926DYpmkYy0OJaJggy7X5E(4my9lxxioOLlQQw9kWI678wo1b2xVag2QhBEAjPagyAjPawq)Y1fIdJwUmQvREfy7VffyFskbPF56cXbTCrv1QxbweXlPsaT4eq4iccGfru161efeagW2quABXwblKYpaoyyRUwskGbdO5ieaSy(e3lDWbWS2XXmGn1YIx0XudVEfJIeJgoJIV66QJH795HwUOUxPg9vmmksmA4mkYz0j9Yp64NKdr0YfvX)(LlLk1LpX9sNrDQtzuKZOTQ89kKxh)KCiIwUOk(3VCPuP(jKj)vmkYyucmAymAyGThN75JZGHPgE9Gf135TCQdSVEbmSvp280ssbmW0ssbSGQgE9Gfr8sQeqlobeoIGayrevTEnrbbGbSneL2wSvWcP8dGdg2QRLKcyWaAoXqaWI5tCV0bhaZAhhZagYz0j9Yp64NKdr0YfvX)(LlLk1LpX9shS94CpFCgmmCVpp0Yf19k1awuFN3YPoW(6fWWw9yZtljfWatljfWckU3NhJwUm6oxPgWIiEjvcOfNachrqaSiIQwVMOGaWa2gIsBl2kyHu(bWbdB11ssbmyanNiiayX8jUx6GdGzTJJzaBsV8Jo(j5qeTCrv8VF5sPsD5tCV0zuKy0wv(EfYRJFsoerlxuf)7xUuQu)eYK)kgfzmQtsaS94CpFCgmmCVpp0Yf19k1awuFN3YPoW(6fWWw9yZtljfWatljfWckU3NhJwUm6oxPggnCeHbweXlPsaT4eq4iccGfru161efeagW2quABXwblKYpaoyyRUwskGbdOHGaeaSy(e3lDWbWS2XXmGnPx(rh)KCiIwUOk(3VCPuPU8jUx6mksmkYz0wv(EfYRJFsoerlxuf)7xUuQu)eYK)kgfzmkbgfjg9wFEdftfIC6T17KFyuKfegnueyuKyujOTYXGr66T6dwUf5BcA5I6MJOyuKy0wv(EfYRtC9xKJ)lO36lOHijM61pHm5VIr3nJIGay7X5E(4myy4EFEOLlQ7vQbSO(oVLtDG91lGHT6XMNwskGbMwskGfuCVppgTCz0DUsnmA4XddSiIxsLaAXjGWreealIOQ1RjkiamGTHO02ITcwiLFaCWWwDTKuadgqdbciayX8jUx6GdGzTJJzaBsV8Jo(j5qeTCrv8VF5sPsD5tCV0zuKyuKZOTQ89kKxh)KCiIwUOk(3VCPuP(jKj)vmkYyucmksm6T(8gkMke50BR3j)WOilimAOiWOiXOiNrLG2khdgPR3Qpy5wKVjOLlQBoIIrrIrdNrBv57viVoX1Fro(VGERVGgIKyQx)eYK)kgD3mkIqXOo1Pm6K3Im6dNuqNcTZfgfzmkIOfkgnmW2JZ98XzWWW9(8qlxu3Rudyr9DElN6a7RxadB1JnpTKuadmTKualO4EFEmA5YO7CLAy0WJwyGfr8sQeqlobeoIGayrevTEnrbbGbSneL2wSvWcP8dGdg2QRLKcyWaAiIdbalMpX9shCamRDCmdytTS4f9wv(EfYRyuKy0Wzu8vxxDmCVpp0Yf19k1OVIHrddS94CpFCgm8tYHiA5IQ4F)YLsLGf135TCQdSVEbmSvp280ssbmW0ssbmhojhImA5YOg)7xUuQeSiIxsLaAXjGWreealIOQ1RjkiamGTHO02ITcwiLFaCWWwDTKuadgqdr0GaGfZN4EPdoaM1ooMbm8vxx9w57OeL8gD1KTTmAqy04eyuN6ugnCgfF11vhd37ZdTCrDVsn6NqM8xXO7MrxADgfjgfF11vhd37ZdTCrDVsn6RyyuKy0Wzu8vxx9w57OeL8gD1KTTmkYccJIabJ6uNYOHZO4RUU6TY3rjk5n6QjBBzuKfegfbbgfjgvjdkE9Rk9HlxCcOojMgJImgLaJggJggJggy7X5E(4mynIj)vOLlkVjGf135TCQdSVEbmSvp280ssbmW0ssbSnet(Ry0YLrJQjGfr8sQeqlobeoIGayrevTEnrbbGbSneL2wSvWcP8dGdg2QRLKcyWaAiCsiayX8jUx6GdGzTJJzad5m6KE5hD8tYHiA5IQ4F)YLsL6YN4EPZOiXOiNrdNrN0l)OVKdr54)cQAQJux(e3lDgfjgfF11v)eY6uIxuk0q4)iN(kggnmW2JZ98XzWAP3JMTHxpQNRgWI678wo1b2xVag2QhBEAjPagyAjPa2M07z09THxpJg9C1a2(Brb2NKsq2LXj3WO7CLAcnJUiVC82UalI4LujGwCciCebbWIiQA9AIccadyBikTTyRGfs5hahmSvxljfWmo5ggDNRutOz0f5LJ3Gb0qekiayX8jUx6GdGzTJJzaBsV8Jo(j5qeTCrv8VF5sPsD5tCV0zuKyuKZO9A0XpjhIOLlQI)9lxkvQp82w(Va2ECUNpodwl9E0Sn86r9C1awuFN3YPoW(6fWWw9yZtljfWatljfW2KEpJUVn86z0ONRggnCeHb2(Brb2NKsq2LXj3WO7CLAcnJIxQDbweXlPsaT4eq4iccGfru161efeagW2quABXwblKYpaoyyRUwskGzCYnm6oxPMqZO4Lcgqdr0bbalMpX9shCamRDCmdyt6LF0XpjhIOLlQI)9lxkvQlFI7LoJIeJ2Rrh)KCiIwUOk(3VCPuP(WBB5)cy7X5E(4myT07rZ2WRh1Zvdyr9DElN6a7RxadB1JnpTKuadmTKuaBt69m6(2WRNrJEUAy0WJhgy7VffyFskbzxgNCdJUZvQj0mkEPy0H32Y)LDbweXlPsaT4eq4iccGfru161efeagW2quABXwblKYpaoyyRUwskGzCYnm6oxPMqZO4LIrhEBl)xGb0q4ieaSy(e3lDWbWS2XXmGnPx(rFjhIYX)fu1uhPU8jUx6mksmk(QRR(jK1PeVOuOHW)ro9vmmksmkYz0j9Yp64NKdr0YfvX)(LlLk1LpX9shS94CpFCgSw69OzB41J65QbSO(oVLtDG91lGHT6XMNwskGbMwskGTj9EgDFB41ZOrpxnmA4rlmW2FlkW(KucYUmo5ggDNRutOz0ffJo82w(VSlWIiEjvcOfNachrqaSiIQwVMOGaWa2gIsBl2kyHu(bWbdB11ssbmJtUHr35k1eAgDrXOdVTL)lWadyAjPaMXj3WO7CLAcnJ2f3C1pWaaa]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170624.232908, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxtruzMfwDSrNxc51usvgBLf2CL5LtYatm3aJnYqJlYmtm1iZmEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnfDVD2zSvMlW9gDP9MBZ51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnLuLXwzHnxzE5KmWeZnXaJxtjvzZ9wDYnwzZ5fvErNxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uErNx051uofwBL51utLwBd5hygj3BZrNo(bgCYv2yV1MyHrNx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170624.232908, [[deubnaqisvztuj(eQuWOOs5uuPAxcmmKQJjslJk6zcQmnQKY1eu12qLs(gsX4OsQohQuK1Hkv18eu6EOsv2hvs6GOswisPhskmruPOUiPOnkO4JOsHgjPQQtsk1nfv7eu)KuvzPOINsmvuvBLuLVIkv2R0FvudMIdRQfJOhRWKb5YqBweFgvz0KkNMKxtfMnvDBe2nWVvA4IYXrLsTCuEUqtxLRJKTRi9DfX5fK1tLeZNuY(P0nT8Riz4q9ELR8NAbf2z4tRidMk7QuHBgtEk)vARWb94hXc7KEkn05woDTaNHln8odxfo4dfIVIaRqsLKeOJcWdzkaVzgfaNNGF2ccyiXRaXkCno1cILFHtl)kAcEspcvARidMk7QqsLKeOgHMV3VGyadjEfiAnH1AsdcV14I1CVhbxGAeA(E)cIbi4j9iufUivE1fQscBJ3C8ykhyfTbqQXFlRcybyL8fsVNb)eyLkWpbwjmSnEwJCmLdSch0JFelSt6P0KsVchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEf2z5xrtWt6rOsBfUivE1fQcdjwwe9ymoprboKvrBaKA83YQawawjFH07zWpbwPc8tGv4GellIEmgTgUtboKvHd6XpIf2j9uAsPxHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVchUYVIMGN0JqL2kYGPYUkKujjbmfbgqLznUyn6ZACZAiPsscwsV6q2FQfeqLznUyn)4utXzeGekmAnH1ACAnUxHlsLxDHQOBN4vaEZK(pEv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyf9FN4vaEwdT(pEv4GE8JyHDspLMu6v4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RWUw5xrtWt6rOsBfzWuzxLB5XZJbJD9q7eq0ACXACZACZA0N1CVhbxqcBDfemNr5JyacEspcznAPL14M1WOaO1ewRXP14I1WOaQXC2obzbdkgdbN1ewRXPRBnUBnUBnUxHlsLxDHQSKE1HS)ulOI2ai14VLvbSaSs(cP3ZGFcSsf4NaROFKE1HS)ulOch0JFelSt6P0KsVchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfo8LFfnbpPhHkTvKbtLDvyua0ACvRjCwJwAznKujjbouEVcWBM4h6uamGkZA0slRHKkjjyj9Qdz)PwqavwfUivE1fQYs6vhY(dROnasn(BzvalaRKVq69m4NaRub(jWk6hPxDi7pSch0JFelSt6P0KsVchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfMBv(v0e8KEeQ0wrgmv2v5wE88yWyxp0obeTgxSg3Sg3SgKBtPYYqOGXcIl7IZJ1dnpwgAnAPL1qsLKeKP8(NnVjZjSnEbuzwJ7wJlwdjvssafq36dnhpgc4D6cOYSgxSgiKKkjjG9UYYudmiE)WH1W9SMWBnUyn6ZAiPsscwsV6q2FQfeqLznUxHlsLxDHQevai2ZBJFCoHIfQI2ai14VLvbSaSs(cP3ZGFcSsf4NaRikae75TXNBiAnHHIfQch0JFelSt6P0KsVchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfMMYVIMGN0JqL2kYGPYUkKujjbouEVcWBM4h6uamGkZACXACZA0N1GCBkvwgcf4y9NI9XzaojzPaqZtuEV1OLwwZ9EeCb8(thYuaEZXBzebi4j9iK1OLwwZpo1uCgbiHcJwJRY9SgNwJ7v4Iu5vxOkjSnEXrOthwrBaKA83YQawawjFH07zWpbwPc8tGvcdBJxCe60Hv4GE8JyHDspLMu6v4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RWUE5xrtWt6rOsBfzWuzxfgfqnMZ2jilyqXyi4Sgx1ACD6wJwAznUznKujjblPxDi7p1ccOYSgxSg9znKujjbouEVcWBM4h6uamGkZACVcxKkV6cvjHTXBoEmLdSI2ai14VLvbSaSs(cP3ZGFcSsf4NaReg2gpRroMYbAnUL6EfoOh)iwyN0tPjLEfoyCPydmw(9QOHoC4iFNIei4kzL8fc(jWk9km3u5xrtWt6rOsBfUivE1fQYs6vhY(dROnasn(BzvalaRKVq69m4NaRub(jWk6hPxDi7p0ACl19kCqp(rSWoPNstk9kCW4sXgyS87vrdD4Wr(ofjqWvYk5le8tGv6v4u6LFfnbpPhHkTvKbtLDvyua1yoBNGSGbfJHGZAcR1qdDRXfRrFwdjvssGokapKPa8MzuaCEc(zliGkRcxKkV6cvr3YaZBY8ef4qwfTbqQXFlRcybyL8fsVNb)eyLkWpbwr)xgWA2eRH7uGdzv4GE8JyHDspLMu6v4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RWPPLFfnbpPhHkTv4Iu5vxOk88)q9(5hA6dgyfTbqQXFlRcybyL8fsVNb)eyLkWpbwHB0)d17TgUGM(GbwHd6XpIf2j9uAsPxHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVcN6S8ROj4j9iuPTcxKkV6cvjHTXBoEmLdSI2ai14VLvbSaSs(cP3ZGFcSsf4NaReg2gpRroMYbAnU509kCqp(rSWoPNstk9kCW4sXgyS87vrdD4Wr(ofjqWvYk5le8tGv6v40Wv(v0e8KEeQ0wrgmv2v5wE88yWyxp0obeTgxSg3Sg9znKujjb6Oa8qMcWBMrbW5j4NTGaQmRX9kCrQ8QlufDuaEitb4nZOa48e8ZwqfTbqQXFlRcybyL8fsVNb)eyLkWpbwr)Pa8qMcWZA4qbqRH7WpBbv4GE8JyHDspLMu6v4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RWPUw5xrtWt6rOsBfzWuzxLB5XZJbJD9q7eqScxKkV6cvbjY2jiBMrbW5j4NTGkAdGuJ)wwfWcWk5lKEpd(jWkvGFcSIMez7eKznCOaO1WD4NTGkCqp(rSWoPNstk9kCW4sXgyS87vrdD4Wr(ofjqWvYk5le8tGv61Rc8tGvefHgwtyyB84(wdVO1CQHdfGxVwa]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170624.232908, [[deKvsaqiQKSjcYNOsk1OGQCkOsRcQqTlQyyOshdkwMe8mbjtdQORjrY2ee8nOQghvsfNJkPyDujLmpjsDpOc2hvfhKQulKkXdPkzIujv6IuvzJcsnsOc5Kuv1nHs7Kq)uqOLsL6PuMkvXwPQ0xfe1Ev9xs1Gr5WqwmQ6XsAYs1LbBgv8zsPrtkonrVwqnBHUTu2nIFRy4e44cISCLEojtx01fy7euFxcDEjQ1tLu18Li2psFm3ZntauLOO01Js5qUyHsH5MvxPG82nxxGdkiM3LBUHiGuWflWfd(CdHc40PqOWuQcH6MBa1l7r2GBBarw1fmfH1Hdkgv65OJp3BExt5qu3ZfXCp38JG4Jq)UCZQRuqElrrGKoYAz9efhIYbii(i0PmHOm(aoCCK1Y6jkoeLZcnKKOOSstzARDktikRotSpfjo8lGsn6dhDLK0xK2rHCwOHKefL5dLTbeq5KYgONJooV5nVmkZY34SJk1v5kdd38N0Lvuo7nYqGByNUVOve1GB3ern4wO3rLuMLRmmCZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EEXc3Zn)ii(i0Vl3S6kfK3sueiPJwuQbwjrRUkNT5aeeFe638MxgLz5Bl0MvbrqP0lkjjS38N0Lvuo7nYqGByNUVOve1GB3ern4MBOnRcIGsrzHSKKWEZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EEXqDp38JG4Jq)UCZQRuqEJpGdhNv2aNabuMqu2gqaLtkBGEo64KYknLHhLPT2PmCmLvGYW9M38YOmlFtZumkjA15JivEZFsxwr5S3idbUHD6(IwrudUDte1GB4OPyus0szUerQ8MBicifCXcCXGpgU3CdQjyRG6EEEZlnqnm2ryObK883WoDrudU98I48EU5hbXhH(D5MvxPG82gqaLtkBGEo6HaLvAktBTtzcrzUIYsueiPJwuQbwjrRUkNT5aeeFe638MxgLz5BdFuMWIs4M)KUSIYzVrgcCd709fTIOgC7MiQb3cr(OmHfLWn3qeqk4If4IbFmCV5gutWwb1988MxAGAySJWqdi55VHD6IOgC75fl19CZpcIpc97YnRUsb5TnGakNu2a9C0XjLvAktBTtzcrz4rz1zI9PiXHFbuQrF4ORKK(I0okKZcnKKOOmFOmUuwjLqzBarw1fmfH1PgSlqskR0ug(CPmCV5nVmkZY3g(OmHfLWn)jDzfLZEJme4g2P7lAfrn42nrudUfI8rzclkbkdpm4EZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EEXq4EU5hbXhH(D5MvxPG82gqKvDbtryDQb7cKKY8bhOmxtPOmHOmfK68djq5KsyX4A0XPGkL5dLXLYeIYQZe7trId)cOuJ(Wrxjj9fPDuiNfAijrrz(qzCV5nVmkZY34SJk1v5kdd38N0Lvuo7nYqGByNUVOve1GB3ern4wO3rLuMLRmmqz4Hb3BUHiGuWflWfd(y4EZnOMGTcQ755nV0a1WyhHHgqYZFd70frn42ZlI)9CZpcIpc97YnRUsb5n(aoCCwzdCceqzcrzqififia6ocGvbcdlIub9HJEQb0b(HO3qBwEV5nVmkZY3wOnRcIGsPxussyV5pPlROC2BKHa3WoDFrRiQb3UjIAWn3qBwfebLIYczjjHLYWddU3CdraPGlwGlg8XW9MBqnbBfu3ZZBEPbQHXocdnGKN)g2PlIAWTNx015EU5hbXhH(D5MvxPG8gFahooRSbobcOmHOm8OS(Kol0MvbrqP0lkjjSoPSgws0szLucLvNj2NIeNfAZQGiOu6fLKewNfAijrrz(qzARDkRKsOm8Omxrzqififia6ocGvbcdlIub9HJEQb0b(HO3qBwEPmHOmxrzjkcK0rlk1aRKOvxLZ2CacIpcDkdxkd3BEZlJYS8nntXOKOvNpIu5n)jDzfLZEJme4g2P7lAfrn42nrudUHJMIrjrlL5sePskdpm4EZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EErxZ9CZpcIpc97YnRUsb5nxrz8bC44SYg4eiGYeIYCfLHhLLOiqshTOudSsIwDvoBZbii(i0PmHOmxrz4rz1zI9PiXzH2SkickLErjjH1zHgssuuMpugEuM2ANYWXuwbkdxkRKsOSnGauMpugoPmCPmCPmHOSnGauMpuwOU5nVmkZY3g(OmHfLWn)jDzfLZEJme4g2P7lAfrn42nrudUfI8rzclkbkdVc4EZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EErmCVNB(rq8rOFxUz1vkiVLJwTrWPotSpfjkktikdpkdpkdcPaPabq3Poe1SPsVoXUEDwGYkPekJpGdhhbYyeT6dhDo7OsNabugUuMqugFahoobentSSUkxGOn14eiGYeIY6aFahoolY1pRScoQevdtz4aLvkktikZvugFahoodFuMWIs5qCceqz4EZBEzuMLVPKK(I0okKsNtWw(M)KUSIYzVrgcCd709fTIOgC7MiQb3mjPViTJc5AROSqhSLV5gIasbxSaxm4JH7n3GAc2kOUNN38sdudJDegAajp)nStxe1GBpVigm3Zn)ii(i0Vl3S6kfK34d4WXjSmgLeT6nuvJKaobcOmHOm8Omxrzqififia6oHNykxKsNaf5mbKUErzmszLucLHQPuyqhiqtckkZhCGYkqz4EZBEzuMLVXzhvQQLtnWn)jDzfLZEJme4g2P7lAfrn42nrudUf6DuPQwo1a3CdraPGlwGlg8XW9MBqnbBfu3ZZBEPbQHXocdnGKN)g2PlIAWTNxetH75MFeeFe63LBwDLcYBBarw1fmfH1PgSlqskZhCGYWN7nV5Lrzw(gNDuPUkxzy4M)KUSIYzVrgcCd709fTIOgC7MiQb3c9oQKYSCLHbkdVc4EZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EErmH6EU5hbXhH(D5MvxPG8gQMsHbDGanjOOmFWbkRWnV5Lrzw(2cTzvqeuk9Issc7n)jDzfLZEJme4g2P7lAfrn42nrudU5gAZQGiOuuwiljjSugEfW9MBicifCXcCXGpgU3CdQjyRG6EEEZlnqnm2ryObK883WoDrudU98IyW59CZpcIpc97YnRUsb5n8OS6mX(uK4SqBwfebLsVOKKW6SqdjjkkR0ugEuM2ANYWXuwbkdxkRKsOm(aoCC0IsnWkjA1v5SnhvIQHPmCGYWWLYWLYeIYQZe7trId)cOuJ(Wrxjj9fPDuiNfAijrrz(qzBabuoPSb65OJtktiklrrGKoArPgyLeT6QC2Mdqq8rOFZBEzuMLVXzhvQRYvggU5pPlROC2BKHa3WoDFrRiQb3UjIAWTqVJkPmlxzyGYWlu4EZnebKcUybUyWhd3BUb1eSvqDppV5LgOgg7im0asE(ByNUiQb3EErmL6EU5hbXhH(D5MvxPG8MROm(aoCCwzdCceqzcrz4rzUIYsueiPJwuQbwjrRUkNT5aeeFe6uwjLqz1zI9PiXzH2SkickLErjjH1zHgssuuMpugEuM2ANYWLYW9M38YOmlFB4JYewuc38N0Lvuo7nYqGByNUVOve1GB3ern4wiYhLjSOeOm8cfU3CdraPGlwGlg8XW9MBqnbBfu3ZZBEPbQHXocdnGKN)g2PlIAWTNxetiCp38JG4Jq)UCZQRuqERotSpfjo8lGsn6dhDLK0xK2rHCwOHKefL5dLHPuuMqu2gqKvDbtryDQb7cKKYknoqz4ZLYeIY2acOCszd0ZrpuuMpuM2A)M38YOmlFtZSe9HJErjjH9M)KUSIYzVrgcCd709fTIOgC7MiQb3WrZsOSHdLfYssc7n3qeqk4If4IbFmCV5gutWwb1988MxAGAySJWqdi55VHD6IOgC75fXG)9CZpcIpc97YnRUsb5T6mX(uK4WVak1OpC0vssFrAhfYzHgssuuMpu2gqaLtkBGEo648M38YOmlFJZoQuxLRmmCZFsxwr5S3idbUHD6(IwrudUDte1GBHEhvszwUYWaLHhoX9MBicifCXcCXGpgU3CdQjyRG6EEEZlnqnm2ryObK883WoDrudU985nrudUzYMxuwO3rLUwug)OE(d]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170624.232908, [[deeBraqiQeTjkvFIejAuKGtrcnlsKWUiQHHIogQYYOuEgvstdfuxJeX2irkFJe14OsqNJkv16irsnpuG7jQQ9rr5GIsTqQuEOOKjsIKCrrfBKkHgjkiNuuLBse7Ks(jjs1sPipvyQIITkQ0xPsL9I8xigSkhMWIPWJvYKrPld2Ss5ZuXOjsNMuVgvvZgs3gv2TKFRy4K0XPsvwUupxKPd11PQTtr13vQopQkRNkbMpk0(v1epkdfHkS0cuTlqG1trw2ucpkIvRvXuqHsfSj8OyYnkmbOGibKLnM8uMPsZgdlBZvEkXMRuyceS8LrZbu0(sVquNDOL3eOOje8GyZ9vk(ZWVTjl1xoqRlhK2xaYoiuNsUboHUsuK9cRNkrzilEugkYPegOal5gfXQ1Qyku4V2x6fI6SdT8Y3nu4)ml))CL5FmY4Fg(TnzP(YbAD5G0(cq2bH6uYE1)u8p7)PWFk8NHFBtU1CGSx9p7)bUNxRQcSYQqNaZHwulaz2qWsbeWykeorJ5R)tX)yKX)u4pSafkSSJalfAD5GKWtZjdLWafy)Z(Fk8h7GLBGB6eGcPeYUUWql3aNqxP)yq()5Sy)Jrg)ZL)Xoy5g4MobOqkHSRlm0Yy9IFD58NI)P4Fksr2gAunMpkAGB6eGcPeYUUWqtrEfREjWttrnfqHKHnxrBj4akOWsWbuyc4MobOqk9N70fgAkmbOGibKLnM8uMhtkmbPX3lirzimfzjfw8lzmh4GctguizyTeCafeMSSrzOiNsyGcSKBueRwRIPqH)u4V2x6fI6SdT8Y3nu4)ml))SX8p7)LamIXu(Kmwdnp3hHHvx)z2Fm)tX)yKX)AFPxiQZo0YlF3qH)ZS8)ZvM)XiJ)z432KL6lhO1Lds7lazheQtj7v)tX)S)NHFBtU1CGSxLISn0OAmFuiD2r1LdIbQiHPiVIvVe4PPOMcOqYWMROTeCafuyj4akyOzhvxo)5gQiHPWeGcIeqw2yYtzEmPWeKgFVGeLHWuKLuyXVKXCGdkmzqHKH1sWbuqyYYvkdf5ucduGLCJIy1AvmfjaJymLpjJ1qBJjIn11FM9hZ)S)x7l9crD2HwE57gk8FM9Nluj)z)V2xWFmi))C9p7)z432Kv1OOIgz2q26jHL9QuKTHgvJ5JITEsyKeU18duKxXQxc80uutbuizyZv0wcoGckSeCafUypj8FbU18duycqbrcilBm5PmpMuycsJVxqIYqykYskS4xYyoWbfMmOqYWAj4akimzXWugkYPegOal5gfXQ1QykAFPxiQZo0YlF3qH)Jb5)hdRK)yKX)AFbjzSMdqWdIs(Jb)5Sy)Jrg)ZWVTjl1xoqRlhK2xaYoiuNsUboHUs)zw()zJISn0OAmFumgOAm0cmqrEfREjWttrnfqHKHnxrBj4akOWsWbuO0nq1yOfyGctakisazzJjpL5XKctqA89csugctrwsHf)sgZboOWKbfsgwlbhqbHjlLqzOiNsyGcSKBueRwRIPapooOG8Agu2zVs)z)pf(R9LEHOo7qlV8Ddf(pg8NYm)Z(FU8pd)2MSuF5aTUCqAFbi7GqDkzV6F2)R9f8hd(Z2F2)Bndk7SxYgniWsrMnKKUyBHZKeYnWj0v6pZ(ZvL8N9)a3ZRvvbw51uMdTdulaz2q2eyi9NIuKTHgvJ5JcP(YbAD5G0(cq2bH6uuKxXQxc80uutbuizyZv0wcoGckSeCafmKVCGwxo)zYxWFUdeQtrHjafejGSSXKNY8ysHjin(EbjkdHPilPWIFjJ5ahuyYGcjdRLGdOGWKLsJYqroLWafyj3OiwTwftbECCqb51mOSZEL(Z(Fk8x7l9crD2HwE57gk8Fm4pLW8p7)5Y)m8BBYs9Ld06YbP9fGSdc1PK9Q)z)V2xqsgR5ae8Gy7pZY)px)Z(FRzqzN9s2ObbwkYSHK0fBlCMKqUboHUs)z2FUY8pfPiBdnQgZhfs9Ld06YbP9fGSdc1POiVIvVe4PPOMcOqYWMROTeCafuyj4akyiF5aTUC(ZKVG)ChiuN6pf4PifMauqKaYYgtEkZJjfMG047fKOmeMISKcl(LmMdCqHjdkKmSwcoGcctwktzOiNsyGcSKBueRwRIPapooOG8Agu2zVs)z)pf(R9LEHOo7qlV8Ddf(pg8NRk5p7)5Y)m8BBYs9Ld06YbP9fGSdc1PK9Q)z)V2xqsgR5ae8Gy7pZY)pB)z)V1mOSZEjB0Galfz2qs6ITfotsi3aNqxP)m7pxz(NIuKTHgvJ5JcP(YbAD5G0(cq2bH6uuKxXQxc80uutbuizyZv0wcoGckSeCafmKVCGwxo)zYxWFUdeQt9Nc2uKctakisazzJjpL5XKctqA89csugctrwsHf)sgZboOWKbfsgwlbhqbHjlxiLHICkHbkWsUrrSATkMc844GcYRzqzN9k9N9)u4V2x6fI6SdT8Y3nu4)yWF2y(N9)C5Fg(TnzP(YbAD5G0(cq2bH6uYE1)S)x7lijJ1CacEqS9Nz5)hV)S)3Agu2zVKnAqGLImBijDX2cNjjKBGtOR0FM9NRm)trkY2qJQX8rHuF5aTUCqAFbi7GqDkkYRy1lbEAkQPakKmS5kAlbhqbfwcoGcgYxoqRlN)m5l4p3bc1P(tbxvKctakisazzJjpL5XKctqA89csugctrwsHf)sgZboOWKbfsgwlbhqbHjl3NYqroLWafyj3OiwTwftbECCqb51mOSZEL(Z(Fk8Nc)bUNxRQcSYRPstJtiRbLfznn8hJm(NHFBtwvJIkAKzdzRNew2R(NI)z)pd)2MSVKoO8HKWnuoyPYE1)S)hly432KBHlyA9cKtyXI))Y)pL8N9)C5Fg(Tn5XavJHwG1tj7v)trkY2qJQX8rrsxSTWzsIeYMV5JI8kw9sGNMIAkGcjdBUI2sWbuqHLGdOi0fBlCMKqPm9Nl6B(OWeGcIeqw2yYtzEmPWeKgFVGeLHWuKLuyXVKXCGdkmzqHKH1sWbuqyYIhtkdf5ucduGLCJIy1Avmfg(Tnz(1OO6YbHtSKQlq2R(N9)u4px(h4EETQkWkZ)GI1TiHuW(24lwKDnk6FmY4Fybkuyzhbwk06YbjHNMtgkHbkW(hJm(NyH1MdiqbCAi9Nz5)NT)uKISn0OAmFuS1tcNw8HLcuKxXQxc80uutbuizyZv0wcoGckSeCafUypjCAXhwkqHjafejGSSXKNY8ysHjin(EbjkdHPilPWIFjJ5ahuyYGcjdRLGdOGWKfpEugkYPegOal5gfXQ1QykelS2CabkGtdP)ml))Srr2gAunMpkAGB6eGcPeYUUWqtrEfREjWttrnfqHKHnxrBj4akOWsWbuyc4MobOqk9N70fg6)uGNIuycqbrcilBm5PmpMuycsJVxqIYqykYskS4xYyoWbfMmOqYWAj4akimzXZgLHICkHbkWsUrrSATkMI2x6fI6SdT8Y3nu4)yq()PSs(Jrg)R9f8Nz)5kfzBOr1y(Oymq1yOfyGI8kw9sGNMIAkGcjdBUI2sWbuqHLGdOqPBGQXqlWWFkWtrkmbOGibKLnM8uMhtkmbPX3lirzimfzjfw8lzmh4GctguizyTeCafeMS45kLHICkHbkWsUrrSATkMI2x6fI6SdT8Y3nu4)yWFkZ8p7)5Y)m8BBYs9Ld06YbP9fGSdc1PK9Q)z)V2xqsgR5ae8G46FM9NZILISn0OAmFuiD6cz2q21fgAkYRy1lbEAkQPakKmS5kAlbhqbfwcoGcgA66Vz7p3Plm0uycqbrcilBm5PmpMuycsJVxqIYqykYskS4xYyoWbfMmOqYWAj4akimzXJHPmuKtjmqbwYnkIvRvXuGhhhuqEndk7SxP)S)Nc)1(sVquNDOLx(UHc)hd(ZgZ)uKISn0OAmFuaCQZo0iTVaKDqOoff5vS6Lapnf1uafsg2CfTLGdOGclbhqroCQZo0)zYxWFUdeQtrHjafejGSSXKNY8ysHjin(EbjkdHPilPWIFjJ5ahuyYGcjdRLGdOGWeMclbhqrO5Y6pxSNewP(pJj9hwV4xxoeMi]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170624.232908, [[dCdCdaGEejTjIIDrKTPcL9HiMnsnFc0nrs52u0oj0EH2nW(LYOqs1WOKFR0GLQHRIoibCkKKoMOAHGyPiXIPulxY6OQ4PKwgv55uzIQq1uPGjdQPlCrQQ6XQ0LrDDe2ivL2QkKnJOoSIZlknlKeFMO67uOtRQNrvLrdsFJGoPk4VICnePUNOyAis8AIsoerPgZrdOQ36pdur94m5HGoqiOkoMmQhoQ19Twx06qw1NwhMjpe0bQuyAECmk6zLl06yEKIKNF5K2ZpuPWdCwdVjJAra(B6CnYLu8MCk2KqlQ06fbGDsXBYPytEOkWn(f4qdOyoAav)bJnndJqqvCmzuHu8eqB9LCRRpaUg5RBqvV1FgOweG)MoxJCjDjQIbrRtsMwxOvRltRxeaU1jjtR7HkfMMhhJIEw5cZTq1iugqHh4SO6U1FgOEaa)3j2cvWcyuPWdCwdVjJAra(B6CnYLu8MCk2KqlQ06fbGDsXBYPytEOkG9t)rwuTlEcOPLCY9a4AKVUbdu0dnGQ)GXMMHriOkoMmQuiaToKINakQ6T(Zav4nKSlEcOPLCY9a4AKVUrk(RSEGCbfK63DPHxJaj7INaAAjNCpaUg5RBKk2CEGlJLmfb4VPZ1ixsxIQyqqsgHwYq9IaWKKXtqbTjitwQyZTCmn7CjJpi4sI4uMIaWKKjNQufvkmnpogf9SYfMBH6ba8FNylublGrva7N(JSOweG0CJFbj63fOsTfwCmzupCuR7BTUO1HSQpTUDXtafdu0p0aQ(dgBAggHGQ4yYOsHa06IBRdP4jGIQER)mqv2WBizx8eqtl5K7bW1iFDJu8xz9a5OsHP5XXOONvUWClupaG)7eBHkybmQcy)0FKf1IaKMB8lir)UavQTWIJjJ6HJADFR1fToKv9P1bBRBx8eqXadu1t((d9tQt8laf9iDogic]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170624.232908, [[duZMeaGEkP0MeH2LszBus1(aLA2uCBvv7eI9kTBQ2VQYpPKOHrk)gQHsjjdwPA4e5GkjhJuTqIYsvflMelx4Wapf1Jf1ZH0ePKIPsunzsA6QCrLuRJssDzKRdYgfbTvkjSzLyzQsNNs8vqjFMGMhOOrckCAfJwK8mrQtkI(gbUgOY9av9Dk10eb(lHU6vEzohJ0vUS1qlaiZvzLra)u5KwX3Ecdm69TldZw93UsqGlv5hYqauQiVA6c0S(Bc2EtRd3B6Ypeq1I85Nkhq(KfLW2uSTamguXdlMwR8Q8nyhTYlIELxETdumKALvMZXiDLl)qgcGsf5vtxGUw5KU6Kbhok7yNkJa(PYp0poqjdHI(TdRXpkkVszmZzPCq)4aLmekQO94hf9kYBLxETdumKALvMZXiDLl)qgcGsf5vtxGUw5KU6Kbhok7yNkJa(PYw1ymG4BhV8TNWaJELxPmM5SuwAmgqiIxexcm61RiPR8YRDGIHuRSYiGFQSSGaxQVD8Y3opUAaeIrbLFidbqPI8QPlqxRCsxDYGdhLDStL5Cmsx5aYjydVEIbKpzrjSnfBzOii)Gn8c06vKeu5Lx7afdPwzL5CmsxzfOLLTy(PniPevGww2sb5cPyCHIbKtI2eqc7BQyBpXaYNSOe2MITmueKFWg(0Wv(HmeaLkYRMUaDTYjD1jdoCu2Xovgb8tLHb22mUWVDzga6vELYyMZs5uyBZ4cfvma0RxrGRYlV2bkgsTYkZ5yKUYbKpzrjSnfBzOii)Gj8cGR8dziakvKxnDb6ALt6QtgC4OSJDQmc4NkBLkM5OaCu5vkJzolLXkM5OaCuVIy9kV8AhOyi1kRmNJr6khq(KfLW2uSLHIG8dMWlaUevGww2sb5cPyCHIbKtI2eqc7BQyBV8dziakvKxnDb6ALt6QtgC4OSJDQmc4NkddC4F74LVDyn(rr5vkJzolLtHdxeViAp(rrVIiOYlV2bkgsTYkZ5yKUYbKpzrjSnfBzOii)Gj8P1kJa(PYWaYfsX4c)2FGC6Bhweqc7LxPmM5SuofKlKIXfkgqojAtajSx2of5peq1sz0Cmsx5KU6Kbhok7yNk)qavlYNFQCa5twucBtX2cWyqfpSyATYpKHaOurE10fOR1RxzwIYdWmwl4gSxKx4071ca]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170624.232908, [[dCddeaGEcQAxiLTjczFijMnr3wuTtLAVu7wX(vIrjcAyK0VbwNivDnrkdwknCq6GIKtjsLJbQhJWcbXsrQwmIwUkNxk8uOLjvEoPMibLMkjmzcnDHlkkDiKK6YOUosQnkfzReuzZiX2jO4Be4RIq9zrX3jrJujXHv1Ovs9mPOoPiAAIaNwY9us6VsvVMG8tKKSHTcJ7pNnMu4wAB6a6yPfcat)s7awAjp(J1grOmr9Ys4)OaJ3DPbBKol5xZE3PclqnrDjGwxZWP11SrK4kOHrJPiIcmARWByRWy25jLSOHyejUcAy0iDwYVM9UtfwaSQXKJyr8b4moGHnU)C2iDohCAwYA9sBIRj4ZykYswrdJhNdonlzTUxznbFo8UZkmMDEsjlAigrIRGggPArqqJYb0rpfwy4JwuecvtgJ0zj)A27ovybWQgtoIfXhGZ4ag24(ZzJRaukRjZsle5RdJPilzfnmUgOuwtMEs5RdhE3Svym78Ksw0qmIexbnmEupfrpuGs(Orq9D8euzvbQgPZs(1S3DQWcGvnMCelIpaNXbmSX9NZgB6a6yPfJReInMISKv0WiLdOJEDCLqSdVtGvym78Ksw0qmIexbnmssnfk0UkNPrnuJ0zj)A27ovybWQgtoIfXhGZ4ag24(ZzJRaukRjZsle5RJL2esVY50zmfzjROHX1aLYAY0tkFD4W70ScJzNNuYIgIrK4kOHrJ0zj)A27ovybWQgtoIfXhGZ4ag24(ZzJufPSc((GnMISKv0WiGuwbFFWo8orwHXSZtkzrdXisCf0WibaifbkhAKh)X6EaLEDnI3NbOFAhN)1OPYQWPzKol5xZE3Pclaw1yYrSi(aCghWWg3FoBSPdOJLwmUsiEPnHWPZykYswrdJuoGo61XvcXo8wGvym78Ksw0qmIexbnmsaasrGYHg5XFSUhqPxxJ49za6N2X5FnAQSkSQr6SKFn7DNkSayvJjhXI4dWzCadBC)5SXva3S0cOS0M4Ac(mMISKv0W4AWn9ak9kRj4ZHdJclt5PwggIdBa]] )


    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Frost Primary]], 'displays', 20170624.232908, [[d0d4gaGEvKxcvLDrPO2MkkzMsQ8yumBfDCur3eQQMMKQUTk8nkv1oPQ9k2nr7Ne(PcnmvY4urfNMudfPgmQ0Wr4GsYZjCmQ4CQOQfkrlLsPftslNIhsL6PGLrLSokfzIQOyQqzYKOPR0fvWvPu4YqUos2Ok1wvrL2mQA7iQpkP4zOc9zOY3LWirfCyPgnknEOkNerUfLQCnkvopL8BvTwvuQxlP0XjybyAIv)Y7xUWAnrbgTbwDK8dbyAIv)Y7xUG(ekEhxbmTehYnlIP2ugqDQpDQM5xKYawJ88c06Ujw9lfXFfaVrEEbAD3eR(LI4VcWjfIcPKeZlb9ju81Ff4qlRgINJb4KcrHu6Ujw9lfPmG1ipVaTyTbhAfXFfqW(fqHEzyRgszab7xurTFkdOzEjq0mAjU4TlW2gCOTsYW(MaLJyyJ43ws1WbSaw52ENZ5TVRlh7Q35825IJx2)k82RE7cynYZlql(kfXBpNac2VaRn4qRiLbQvTsYW(MayJ02sQgoGfqlvQz69nvsg23eWws1WbSamnXQFzLKH9nbkhXWgXFaGaXO7P(uV6xgVl7Cciy)calLb4KcrHoJ2Gyw9ldylPA4awaj1bjMxkIV(acc0CEpBbR7F(MGfOJ3jGjENa4I3jGA8ozdiy)c3nXQFPiQbWBKNxG2kkth)vGMY0yweOaQu88boA8QO2p(RaQt9Pt1m)IQ5mQb6jbBdSFbn5H4Dc0tc229FO2ln5H4DcCgeFtn3ugONfTLGMmDkdqwl0Q6PETWSiqbudW0eR(Lvtnoza3dESbBdOuliMTfMfbkqhW0sCimlcuGwvp1RvGMY04xlrPmqTQ3VCb9ju8oUc0tc2gRn4qlnz64DcyqZaUh8yd2gqqGMZ7zlyJAGEsW2yTbhAPjpeVtaoPquiLKKk1m9(grkd4(jSuWf7dCBEXQGB14qGdTSIA)4VcSTbhAVF5cR1efy0gy1rYpeqjIVPMBfDDba9HBfCVnVyTjfCvI4BQ5gaV4Vciy)cOqVmSvu7NYa9KGTRMfTLGMmD8ob0mV8S))iEh7cqy0hTX6(LlOpHI3XvacdI5pu7TIUUaG(WTcU3MxS2KcUegeZFO2Ba(xUbOXuWfAPqbxFBmFrGJgVQH4Vcqy0hTXIeZlb9ju81FfyBdo0stEiQb4KcrHQMACYdKCdWeqW(f0KPtza8g55fOLKuPMP33iI)kG1ipVaTKKk1m9(gr8xb22GdT3VCdqJPGl0sHcU(2y(Ia4nYZlqlwBWHwr8xbeSFrfLPjj5)OgqW(fKKk1m9(grkdynYZlqBfLPJ)kqplAlbn5HugqW(f0Khszab7xunKYam)HAV0KPJAGMY0abAojDM4Vc0uMUsYW(MaLJyyJ4VUHBSanLPjj5FmlcuavkE(ahAjGf)vGTn4q79lxqFcfVJRaCsPzQ9C1cyTMOaDaMMy1V8(LBaAmfCHwkuW13gZxeONeST7)qTxAY0X7eyq2QtKYugqOpiMOQXH4DfOw17xUbOXuWfAPqbxFBmFrGEsW2vZI2sqtEiENam)HAV0KhIAGTn4qlnz6OgqW(f4dzPQLk1sCIugWw0e1cu8UUCS)1z5QEB2fhDSZfhdC04byX7eaVrEEbAXxPiENa9KGTb2VGMmD8ob4KcrHuE)Yf0NqX74kqTQ3VCH1AIcmAdS6i5hcWjfIcPeFLIugW3hOa3MxSk4sB0hTXkqtzABi1BaIzBHmzta]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )

    storeDefault( [[Frost AOE]], 'displays', 20170624.232908, [[dSJYgaGEPuVejXUuufVwkPzkLy2kCteupgPUTQyBkQu7Ks7vSBI2pb(Pu1WuL(TktdbzOOYGjOHdvhKk9Csogv1XrvSqfzPOkTyuA5u8qPWtbltrzDkQQjkfPPQQMmQQPR0fLkxfjLld56iAJqPTQOs2mH2os8rPOonP(mu8DQYirs6zkQy0Oy8iWjrOBjfHRHKQZtfhwYALIOVPOkD8ZpaDHV6tI9KlSoduGEQ9BHOTlaDHV6tI9KlOBJI1FwatjXGAWGOBntb4HerIChAmYhKCdqhWPxuuH2gf(QpPk23ae0lkQqBJcF1Nuf7BaCJ(PmoePpjOBJILqVbE0s3UyNtaEirKi(nk8vFsvMc40lkQq7VmyqRk23akMZd80lnJBxydOyopxY9cBafZ5bE6LMXLCVmfyldg06kPzotGP()VNW8sSzQ(d4eBtmZ)nabX(gqXCE)YGbTQmfOvwxjnZzc8754LyZu9hql5RPR9mUsAMZeGxInt1Fa6cF1N0vsZCMat9)FpHda4iADn0TRvFYyNrD)akMZd(zkapKisut1ge9QpzaEj2mv)bKKpePpPkwcfqHJgdSJsX04gNj)avS(byJ1paMy9dyI1pBafZ51OWx9jvHnab9IIk06sAQyFduKM67GJcWskkg4PiWLCVyFdWo0TB3848ChJWgOg4mfWCECu6I1pqnWzQg3dBTCu6I1pqtrIf5yZuGA4vokokCzkafTsZQh6157GJcWgGUWx9jDhAmYan6S)oEdWxRWhLZ3bhfGoGPKyqFhCuGIvp0RtGI0uewlrzkqRSyp5c62Oy9NfOg4m1VmyqlhfUy9dyqJan6S)oEdOWrJb2rPycBGAGZu)YGbTCu6I1papKiseFIs(A6ApJktbAC4oce(VaynNAfi0TVlGTEqbWAo1kqOBFxGTmyql2tUW6mqb6P2VfI2Ua8rIf5yD5AjaOFAiqiwZP25lqiFKyro2aTYI9KlSoduGEQ9BHOTlGM(KaErRLyIL6bQbot5o8khfhfUy9dudCMcyopokCX6ha3OFkJd2tUGUnkw)zbWni67HTwxUwca6NgceI1CQD(ceIBq03dBTbiOxuuHwQmPI1pWtrGBxSVbEkcGFS(b2YGbTCu6cBaErduPqXo71FEFN7zeAEMnhFQpBobumNhhfUmfqXCEub5WQL81smQmfyldg0YrHlSbOVh2A5O0f2a1aNPChELJIJsxS(bALf7j3aCFbcHsQei0wgZ5fqXCEeL8101EgvMc40lkQqRlPPI9nqn8khfhLUmfqXCEUDHnGI584O0LPa03dBTCu4cBGAGZunUh2A5OWfRFGI0uUsAMZeyQ))7jClDy)b4Hut36CPvW6mqbyd8OLWp23aBzWGwSNCbDBuS(ZcuKMIOu8(o4OaSKIIbOl8vFsSNCdW9fiekPsGqBzmNxGI0uaoAmi20yFd0jl2bIFMcO0p4dKBFxSZcOyopxstrukEHnab9IIk0(ldg0QI9nWwgmOf7j3aCFbcHsQei0wgZ5fWPxuuHwIs(A6ApJk23ae0lkQqlrjFnDTNrf7Ba2HUD7MhNxMcWdjIeXNi9jbDBuSe6nG4j3aCFbcHsQei0wgZ5fqtFYM8UNy9PEaEirKi(yp5c62Oy9NfWPxuuHwQmPITj8dWdjIeXNktQmf4rlDj3l23afPPOMuVbWhLdYKnba]] )


end

