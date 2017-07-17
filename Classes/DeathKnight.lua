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
            state.wait_for_gcd = state.spec.frost
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
        addAura( "blighted_rune_weapon", 194918, "duration", 30, "max_stack", 5 )
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170717.002219, [[da0qtaqiLu1IusYMqknkKqNcjyxkXWaPJjkltu1ZaOMMsICnaITbq6BayCir05usO1rHY8qI6EkPSpLK6GIklKuQhsrnrLu5Iiv2ise8rLe4KivntLe1nvk7eu)ujbTusXtrnvsvxLcvBLczVs)fqdMQoSIftspwKjl4YqBgeFMcgns60e9AsLzl0TbA3i(TkdxP64irA5eEovMUQUoj2oPKVJuCEkY6rIq7Ns3SQVmNeY9VCz4belZsqZwVXjuVOjJz9gqckKPYAWiooSW5HMbauan)kTKhW5xrOuYY8oMKtusjoV8ifopGKVCU0lpIR6lCw1xMoYOgXq1UmNeY9V8FgmeXL0DXWrdXz90A9u06xV1JuQICFhdlzagaOaaiwpTwVqHita3pAqXsaHitY36PS1dyOwpfkNtvgLVPYHrOd4iuLpkktpjitZFIYKJGL3UGrJaEaXYLHhqS86gHoRpNqv(OOSgmIJdlCEOzaKbTSg0DkIe6Q((Lntft62oTqqK8vT82fGhqSC)cNV6lthzuJyOAxMtc5(x(pdgI4s6Uy4OH4SEATEkA9iLQi33XWsgGbakaaI1tR1luiYeW9JguSeqiYK8TEkB9agQ1tR1NUlgoAilHrOd4lgIdYjaNxEKfbcosIZ6PS1N36Pq5CQYO8nvomcDahHQ8rrz6jbzA(tuMCeS82fmAeWdiwUm8aILx3i0z95eQYhfwpfZOqznyehhw48qZaidAznO7uej0v99lBMkM0TDAHGi5RA5TlapGy5(fgWvFz6iJAedv7YCsi3)Y)zWqexs3fdhneN1tR1trRxOqqRNYRz9a26Pq5CQYO8nv2PacEeGggHHZueltpjitZFIYKJGL3UGrJaEaXYLHhqSmRacEeRFfmcdNPiwwdgXXHfop0maYGwwd6ofrcDvF)YMPIjDBNwiis(QwE7cWdiwUFHxPQVmDKrnIHQDzojK7FzvfiqwuiuVOjGUxGedp1fLDRNwRxvbcKL0fdaPIJ4xC)K0z9R26ZwXY5uLr5BQCI6ijoGheGYewMEsqMM)eLjhblVDbJgb8aILldpGyzZuhjXz9heRN(ewwdgXXHfop0maYGwwd6ofrcDvF)YMPIjDBNwiis(QwE7cWdiwUFHbKQVmDKrnIHQDzojK7F5)myiIlP7IHJgIZ6P16PO1JuQICFhdlzagaOaaiwpTwF6Uy4OHSegHoGVyioiNaCE5rwei4ijoRNYwFguRNwRxOqqRNYRz9a26Pq5CQYO8nv2PacEeGggHHZueltpjitZFIYKJGL3UGrJaEaXYLHhqSmRacEeRFfmcdNPiA9umJcL1GrCCyHZdndGmOL1GUtrKqx13VSzQys32PfcIKVQL3Ua8aIL7xyaT6lthzuJyOAxMtc5(xoGQkqGSabDpkKedaP5uiHf3pjDw)QxZ6buRNwRpDxmC0qwM9lnrt7oCrGGJK4SEkB9Ru5CQYO8nv2DkrGcC2rrz6jbzA(tuMCeS82fmAeWdiwUm8aIL5tjA9AWzhfL1GrCCyHZdndGmOL1GUtrKqx13VSzQys32PfcIKVQL3Ua8aIL7xyaQ(Y0rg1igQ2L5KqU)LdOQceilqq3JcjXaqAofsyX9tsN1V61SEaTCovzu(Mkp7xAIM2Dyz6jbzA(tuMCeS82fmAeWdiwUm8aILZTFPjAA3HL1GrCCyHZdndGmOL1GUtrKqx13VSzQys32PfcIKVQL3Ua8aIL7xykz1xMoYOgXq1UmNeY9VSqHita3pAqXsaHitY36PS1NbTCovzu(MkhW5PcmDYyz6jbzA(tuMCeS82fmAeWdiwUm8aILxhopvR38jJL1GrCCyHZdndGmOL1GUtrKqx13VSzQys32PfcIKVQL3Ua8aIL7x4vS6lthzuJyOAxMtc5(xE9w)prK8lHrOd4iuLpkwqYOgXG1tR1RQabYItjeqcWWDGlk7wpTw)6TEvfiqwiysCoPBrz36P16fke06P8AwpGlNtvgLVPYbCEQatNmwMEsqMM)eLjhblVDbJgb8aILldpGy51HZt16nFYO1tXmkuwdgXXHfop0maYGwwd6ofrcDvF)YMPIjDBNwiis(QwE7cWdiwUFHZGw9LPJmQrmuTlZjHC)l)tej)sye6aocv5JIfKmQrmy90A9QkqGS4ucbKamCh4IYU1tR1NUlgoAilHrOd4iuLpkwei4ijoRF1wpGy90A9cfcA9uEnRhWLZPkJY3u5aopvGPtgltpjitZFIYKJGL3UGrJaEaXYLHhqS86W5PA9Mpz06PyEkuwdgXXHfop0maYGwwd6ofrcDvF)YMPIjDBNwiis(QwE7cWdiwUFHZYQ(Y0rg1igQ2L5KqU)LdOQceilqq3JcjXaqAofsyX9tsN1tzRhqTEAT(0DXWrdzz2V0enT7WfbcosIZ6P8AwpGwoNQmkFtLHGUhfsIbGUxi1HLPNeKP5przYrWYBxWOrapGy5YWdiwMsaDpkKedwp)cPoSSgmIJdlCEOzaKbTSg0DkIe6Q((Lntft62oTqqK8vT82fGhqSC)cNLV6lthzuJyOAxMtc5(xoGQkqGSabDpkKedaP5uiHf3pjDw)QxZ6bC5CQYO8nv2DkrGcC2rrz6jbzA(tuMCeS82fmAeWdiwUm8aIL5tjA9AWzhfwpfZOqznyehhw48qZaidAznO7uej0v99lBMkM0TDAHGi5RA5TlapGy5(fodWvFz6iJAedv7YCsi3)YbuvbcKf3PebkWzhflk7wpTw)6T(aQQabYce09OqsmaKMtHewu2lNtvgLVPYqq3JcjXaq3lK6WY0tcY08NOm5iy5Tly0iGhqSCz4beltjGUhfsIbRNFHuhA9umJcL1GrCCyHZdndGmOL1GUtrKqx13VSzQys32PfcIKVQL3Ua8aIL7x4SvQ6lthzuJyOAxMtc5(xoGQkqGS4oLiqbo7Oyrz36P16dOQceilqq3JcjXaqAofsyX9tsN1V61S(SY5uLr5BQSlDkcdiq3lK6WY0tcY08NOm5iy5Tly0iGhqSCz4belZPtryaTE(fsDyznyehhw48qZaidAznO7uej0v99lBMkM0TDAHGi5RA5TlapGy5(fodqQ(Y0rg1igQ2L5KqU)LdOQceilUtjcuGZokwu2TEAT(aQQabYce09OqsmaKMtHewC)K0z9REnRpRCovzu(MkNIdnsIbGoQt4OXvMEsqMM)eLjhblVDbJgb8aILldpGyzZXHgjXG1ZuNWrJRSgmIJdlCEOzaKbTSg0DkIe6Q((Lntft62oTqqK8vT82fGhqSC)cNbOvFz6iJAedv7Y5uLr5BQCaHiJyz6jbzA(tuMCeS82fmAeWdiwUm8aILxhcrgXYAWiooSW5HMbqg0YAq3PisOR67x2mvmPB70cbrYx1YBxaEaXY9lCgavFz6iJAedv7YCsi3)Yt6LAHarcckrN1V61S(8LZPkJY3u50eJaN0lpcWO09Lntft62oTqqK8vT82fmAeWdiwUm8aILnpXO1Nl9YJy9RS09LZjm4ktgqCTvXsqZwVXjuVOjJz95wH0TQYAWiooSW5HMbqg0YAq3PisOR67xMEsqMM)eLjhblVDb4belZsqZwVXjuVOjJz95wH01VWzuYQVmDKrnIHQDzojK7FzKsvK77yy5PIaLe3lus)jCaHCkINkWi6ChPCovzu(MkNMye4KE5ragLUVSzQys32PfcIKVQL3UGrJaEaXYLHhqSS5jgT(CPxEeRFLLU36PygfkNtyWvMmG4ARILGMTEJtOErtgZ6Le3lus)jCRQSgmIJdlCEOzaKbTSg0DkIe6Q((LPNeKP5przYrWYBxaEaXYSe0S1BCc1lAYywVK4EHs6pHRFHZwXQVmDKrnIHQDzojK7F51B9)erYVKg3lnm)jwqYOgXG1tR1VERhPuf5(ogwEQiqjX9cL0FchqiNI4PcmIo3rkNtvgLVPYPjgboPxEeGrP7lBMkM0TDAHGi5RA5Tly0iGhqSCz4belBEIrRpx6LhX6xzP7TEkMNcLZjm4ktgqCTvXsqZwVXjuVOjJz9UFiHrewvznyehhw48qZaidAznO7uej0v99ltpjitZFIYKJGL3Ua8aILzjOzR34eQx0KXSE3pKWic9lCEOvFz6iJAedv7YCsi3)Y)erYVKg3lnm)jwqYOgXG1tR1VERhPuf5(ogwEQiqjX9cL0FchqiNI4PcmIo3rkNtvgLVPYPjgboPxEeGrP7lBMkM0TDAHGi5RA5Tly0iGhqSCz4belBEIrRpx6LhX6xzP7TEkcykuoNWGRmzaX1wflbnB9gNq9IMmM1Ng3lnm)jwvznyehhw48qZaidAznO7uej0v99ltpjitZFIYKJGL3Ua8aILzjOzR34eQx0KXS(04EPH5pr)(LxhczuIF1UFl]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170717.002219, [[diKgsaqisiTikHAtkLmksrDkkb3Isi2fqgMs6yuQLjj9mkjtJskUgjQTPuQ(gHACeioNsP06iHQ5rjLUhju2hLuDqLIfsapuPQjsG6IKiBuPu4KKGzsjKUPKANG8tLsrdLeISuc5POMkKCvcK2kPWxjHO2R4Ve0Gb1HPAXK0JbmzkUmYMLeFMuz0KQonrVgOMTIUTe7wLFl1WHuhNuKLd1Zvy6Q66kX2vQ8DkrNNuA9Kqy)qCSdQWmawI(dhgYluyww2JalON(EQvXrGnufFz(HfrtYhuGQUAlED7vTgqvTQ62UkiHz0eG0NsfH)Y(cuvLRgEdWl7BeubYoOcR05QtYebcZayj6p8360njqY7jmEb9pcVrvoLV2Wf5zewbtKIGcRWzKa(34WxFu462OHJH8cfomKxOW1YZGaVnWePiOWIOj5dkqvxTfBVgwen6fmancQ8H3RNaax37OcDFudx3giVqHZhOQbvyLoxDsMiqygalr)HXlNeqi62scdYqvKaYhb26iWvxdVrvoLV2WogWps43ymDFyfoJeW)gh(6Jcx3gnCmKxOWHH8cfEdgWpcbgvJX09HfrtYhuGQUAl2EnSiA0lyaAeu5dVxpbaUU3rf6(OgUUnqEHcNpqwfuHv6C1jzIaHzaSe9h(BD6MeiGUNM2YBeEJQCkFTHvNDBewzbRnScNrc4FJdF9rHRBJgogYlu4WqEHclWSBdc82ybRnSiAs(Gcu1vBX2RHfrJEbdqJGkF496jaW19oQq3h1W1TbYlu48bYAcQWkDU6KmrGWmawI(d)ToDtceq3ttB5ncVrvoLV2WQeEqyWYtxyfoJeW)gh(6Jcx3gnCmKxOWHH8cfwacpimy5PlSiAs(Gcu1vBX2RHfrJEbdqJGkF496jaW19oQq3h1W1TbYlu48bs5GkSsNRojtei8gv5u(AdVmiHYNkJWkCgjG)no81hfUUnA4yiVqHdd5fkSGoieyfEQmclIMKpOavD1wS9Ayr0OxWa0iOYhEVEcaCDVJk09rnCDBG8cfoFG2EqfwPZvNKjceMbWs0F4V1PBsGq3VSVbc8wiWAgbwDPsfqlN(EQv44X0P71dAbncSfcVrvoLV2WO7x2xyfoJeW)gh(6Jcx3gnCmKxOWHH8cfwrQFzFHfrtYhuGQUAl2EnSiA0lyaAeu5dVxpbaUU3rf6(OgUUnqEHcNpqIdQWkDU6KmrGWmawI(dROiWM(bTtIxM09crpDDleOxcawE6cVrvoLV2W9YRIjhC496jaW19oQq3h1W1Trdhd5fkCyiVqH3MlVkMCWH3G1nc)owh9cLvumf10pODs8YKUxi6PRBHa9saWYtxyr0K8bfOQR2ITxdlIg9cgGgbv(WkCgjG)no81hfUUnqEHcNpqcsqfwPZvNKjceMbWs0F4V1PBsGa6EAAlVr4nQYP81g2XfTc7kcF9Kqd5MWkCgjG)no81hfUUnA4yiVqHdd5fk8gCrlcCxbb(1tiWcMCtyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5d02guHv6C1jzIaHzaSe9hM00IenAYaY2kXRIvgbEleyGUNM2YdKXXGf6yv5tyqyQ4YBGaBDey7TRC4nQYP81g24yWcFSFJknU4VSVWkCgjG)no81hfUUnA4yiVqHdd5fkSGDmyeyuy)gvACXFzFHfrtYhuGQUAl2EnSiA0lyaAeu5dVxpbaUU3rf6(OgUUnqEHcNpq2RbvyLoxDsMiqygalr)HjnTirJMmGSTs8QyLrG3cbwrrGFFs3dAO3nTLcLxLLHSpq05QtYGaVfcmq3ttB5bY4yWcDSQ8jmimvC5nqGTocSYkhEJQCkFTHnogSWh73OsJl(l7lScNrc4FJdF9rHRBJgogYlu4WqEHclyhdgbgf2VrLgx8x2hcSMTTqyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5dKTDqfwPZvNKjceMbWs0Fystls0OjdiBReVkwze4TqGFFs3dAO3nTLcLxLLHSpq05QtYGaVfcmq3ttB5bY4yWcDSQ8jmimvC5nqGTocSvkhEJQCkFTHnogSWh73OsJl(l7lScNrc4FJdF9rHRBJgogYlu4WqEHclyhdgbgf2VrLgx8x2hcSMRAHWIOj5dkqvxTfBVgwen6fmancQ8H3RNaax37OcDFudx3giVqHZhi7QbvyLoxDsMiqygalr)HjnTirJMmGSTs8QyLrG3cb(DSo6b9Ycj8BHgjHaBTiWaDpnTLhiJJbl0XQYNWGWuXL3ab2IGaliH3OkNYxByJJbl8X(nQ04I)Y(cRWzKa(34WxFu462OHJH8cfomKxOWc2XGrGrH9BuPXf)L9HaRzRSqyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5dKTvbvyLoxDsMiqygalr)HjnTirJMmGSTs8QyLrG3cbgO7PPT8anwkL(eQZX6ATtceMkU8giWwhb2E7RH3OkNYxByJJbl8X(nQ04I)Y(cRWzKa(34WxFu462OHJH8cfomKxOWc2XGrGrH9BuPXf)L9HaRzRXcHfrtYhuGQUAl2EnSiA0lyaAeu5dVxpbaUU3rf6(OgUUnqEHcNpq2wtqfwPZvNKjceMbWs0Fystls0OjdiBReVkwze4TqGvue43N09Gg6DtBPq5vzzi7deDU6KmiWBHad0900wEGglLsFc15yDT2jbctfxEdeyRJaRSYH3OkNYxByJJbl8X(nQ04I)Y(cRWzKa(34WxFu462OHJH8cfomKxOWc2XGrGrH9BuPXf)L9HaRzLTqyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5dKTYbvyLoxDsMiqygalr)HjnTirJMmGSTs8QyLrG3cb(9jDpOHE30wkuEvwgY(arNRojdc8wiWaDpnTLhOXsP0NqDowxRDsGWuXL3ab26iWwPC4nQYP81g24yWcFSFJknU4VSVWkCgjG)no81hfUUnA4yiVqHdd5fkSGDmyeyuy)gvACXFzFiWAE7wiSiAs(Gcu1vBX2RHfrJEbdqJGkF496jaW19oQq3h1W1TbYlu48bYE7bvyLoxDsMiqygalr)HjnTirJMmGSTs8QyLrG3cb(DSo6b9Ycj8BHgjHaBTiWaDpnTLhOXsP0NqDowxRDsGWuXL3ab2IGaliH3OkNYxByJJbl8X(nQ04I)Y(cRWzKa(34WxFu462OHJH8cfomKxOWc2XGrGrH9BuPXf)L9HaRzXwiSiAs(Gcu1vBX2RHfrJEbdqJGkF496jaW19oQq3h1W1TbYlu48bYwCqfwPZvNKjceMbWs0FyffbM00IenAYaY2kXRIvgbEley8YriWwRIHaBv4nQYP81g24yWcFSFJknU4VSVWkCgjG)no81hfUUnA4yiVqHdd5fkSGDmyeyuy)gvACXFzFiWAwqSqyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5dKTGeuHv6C1jzIaHzaSe9hgVCecS1QyiWwfEJQCkFTHvNsD6FYieVCKqljhDFHv4msa)BC4RpkCDB0WXqEHchgYluybMsD6FYGalA5ieyfzYr3xyr0K8bfOQR2ITxdlIg9cgGgbv(W71taGR7DuHUpQHRBdKxOW5dK92guHv6C1jzIaHzaSe9h(9jDpiJJbl0XQYNWGOZvNKbbEley00dANpbRflu1)FsfxAOdKd8YDu4nQYP81ggVCcDGx2NWPC8H3RNaax37OcDFudx3gnCmKxOWHH8cfw0YHaVb4L9HaBrLJp8gSUr4ZlKIzXSSShbwqp99uRIJaVZNG1IT4WIOj5dkqvxTfBVgwen6fmancQ8Hv4msa)BC4RpkCDBG8cfMLL9iWc6PVNAvCe4D(eSwC(avDnOcR05QtYebcVrvoLV2Wa(Ck0bEzFcNYXhwHZib8VXHV(OW1Trdhd5fkCyiVqH37Zjc8gGx2hcSfvo(WBW6gHpVqkMfZYYEeyb903tTkocSo6iSeWIdlIMKpOavD1wS9Ayr0OxWa0iOYhEVEcaCDVJk09rnCDBG8cfMLL9iWc6PVNAvCeyD0ryjq(8HfmvXxMFeiFc]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170717.002219, [[dqZBcaGErkTlqX2OOYSv0nfX3Kk2jvTxYUrz)iXWOIFlmursgmIA4kvhKICmQ05OOQfkvAPsvlMclxHhkfEQQLHuRtKIjcknvLYKP00bUic5QIeDzORlL8Cq2kOQnJaBhu5Xk5WsMMiP(UiHplfDAunAK0Tf1jrOghfLUgffNhrEnc6VsPEMivlxTP)1GVd019vg1pp3Gc5uYOgtsPHc59bUISrb07XjwqO80oUDCmhDQHHoDAZ7yw9VJlEn5PTa8GjpTzO1nTa8GbPn5D1MorSYyIw1v)RbFhOdIMnNim7bGhmiDtg8jhqsFpa8GPtmZYxfig6SGH6jHf(A4RmQR7RmQNQaWdMEpoXccLN2XTJRJEpcfTglesBcO3GkUimjGdZidid9KW6RmQlG80AtNiwzmrR6QBYGp5as6JIdHTTyz1jMz5RcedDwWq9KWcFn8vg119vg17loesHmSyz17XjwqO80oUDCD07rOO1yHqAta9guXfHjbCygzazONewFLrDbKpDTPteRmMOvD1)AW3b6GOzZjcZkIPnsbds3KbFYbK0RrMu7GG2aQyBlwwDIzw(QaXqNfmupjSWxdFLrDDFLrDtJmjkKdcOqgqfPqgwSS694eliuEAh3oUo69iu0ASqiTjGEdQ4IWKaomJmGm0tcRVYOUacOdlsq1AcuxbKa]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170717.002219, [[d0ZbgaGEavAtOQu7IOABGcTpafntavmBj9CsDtr1RbX3uKESi7uH9sTBK2VaJcqH)sK(nIZtGtJYGjXWbvhKiofGsoMI6Cak1cbLwkQYIjPLl0Iaf1tHwgQ06eeMiQkzQOIjlX0v6IaYvfKCzvxxu2iOiBfvvBgGTRioSuFxq9zcAEeQ6zcsnobrJMqUnqNKqzAaQ6AeQCpuv8qIYWaPFckypBogXuKbFnAC0G3iYaLfOekQisvqicuM0vicIg596B99Gl05PqHrUaVCUHMlWgAinIWFI1vgWTxgH6bxXX1OK0YiuT54XS5yeiARwFXWAuIkRYwbglVxrstew1Oy0cl1ljAKsO3yoPWFhhn4nAC0G3iF9EffOiJWQg596B99Gl05PZqnY7AswmDT541OmrpbjNm5GNUw1yoPmAWB0RhCnhJarB16lgwJykYGVglxndaa5aUEFKrfknmjJwKR3objqHpbkH0OevwLTcm2WjPUkaU(gfJwyPEjrJuc9gZjf(74ObVrJJg8gLaNK6Qa46BK3RV13dUqNNod1iVRjzX01MJxJYe9eKCYKdE6AvJ5KYObVrVEeAZXiq0wT(IH1iMIm4RXYvZaaqoGR3hzuHsdtYOf56TtqcueFGsidu47aLeHulKWu5nCsQRcGRV84bBgvhOi(afXzuIkRYwbgbC9(iJkuQEJmi3Oy0cl1ljAKsO3yoPWFhhn4nAC0G3imD9(iJkmqb3idYnY71367bxOZtNHAK31KSy6AZXRrzIEcsozYbpDTQXCsz0G3OxpaEZXiq0wT(IH1iMIm4RXoTSjx6PhKDDGcWKpbkCnkrLvzRaJPUwL2PLrOsRm9AuMONGKtMCWtxRAmNu4VJJg8gnoAWBuwxRbksslJqduaom9AusuO2iTbpFGzKbklqjuurKQGqeOibgacMnY71367bxOZtNHAK31KSy6AZXRrXOfwQxs0iLqVXCsz0G3iYaLfOekQisvqicuKada51dXzogbI2Q1xmSgXuKbFnwUAgaaYbC9(iJkuAysgTixVDcsGI45tGsOnkrLvzRaJaUEFKrfkvVrgKBumAHL6Lensj0BmNu4VJJg8gnoAWBeMUEFKrfgOGBKb5bkaJzGLrEV(wFp4cDE6muJ8UMKftxBoEnkt0tqYjto4PRvnMtkJg8g96bmAogbI2Q1xmSgXuKbFnwUAgaaYbC9(iJkuAysgTipdUrjQSkBfyuNizrHxQEJmi3Oy0cl1ljAKsO3yoPWFhhn4nAC0G3iMizrHpqb3idYnY71367bxOZtNHAK31KSy6AZXRrzIEcsozYbpDTQXCsz0G3OxpMAogbI2Q1xmSgXuKbFnwUAgaaYbC9(iJkuAysgTipdUrjQSkBfymv7WmQqPArDHewBumAHL6Lensj0BmNu4VJJg8gnoAWBuwTdZOcduqrDHewBK3RV13dUqNNod1iVRjzX01MJxJYe9eKCYKdE6AvJ5KYObVrVEnYxhqNvxdRxBa]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170717.002219, [[dOtIeaGEbO2KaQDrQABkvP9rkA2i18fOUPOCBr2Ps2l1Ur1(LYpfaggO8BsEoihwYGLQHJIoOsLtPuvhtPCobilerzPOWIfvlhHhku9uOhtyDOuQjIiAQiXKjA6axuqUkkLCzvxxqTmHSvsHnJiz7KkNNu60k(Sq57cKVHOAAOumAK04eaDsuQ(lO6AkvX9qeEMaYRrjJcrQ9MPyefedtGrJRkDJ4KI36SfNQIwlB367cGqgzC6xq3RiyBKdBVrSrFuGIciybOrK5ftrpbCbgf3RO9ezCNamkoKP41MPymeVYPV0KzefedtGXsagDh(5pnhQ11KeTEKXD5d9a0Au(cqfEXLWLxuAnYoxoIcOimYv8Bmtj1Oiwv6gnUQ0nsYxaQTEXLTojVO0AKXPFbDVIGTr(gmJmoKkmH4qMIbgJt9cwzkDpDoW5gZuYvLUrd8kYumgIx50xAYmIcIHjWyjaJUd)8NMd16A26SX4U8HEaAnEMJ8PryKDUCefqryKR43yMsQrrSQ0nACvPBmeZr(0imY40VGUxrW2iFdMrghsfMqCitXaJXPEbRmLUNoh4CJzk5Qs3ObEfitXyiELtFPjZikigMaJLam6o8ZFAouRRjjA9OwpWToPBDPcOx(cqfEXLWLxuA1dgbRHhR1do4wxQa6LNud91dgbRHhR1334U8HEaAncjuHjID4qaIH1nYoxoIcOimYv8Bmtj1Oiwv6gnUQ0nIcvyIyV1raXW6gzC6xq3RiyBKVbZiJdPctioKPyGX4uVGvMs3tNdCUXmLCvPB0aVyJPymeVYPV0KzefedtGXsagDh(5pnhQ11KeTEuRh4wN0TUub0lFbOcV4s4YlkT6bJG1WJ16bhCRlva9YtQH(6bJG1WJ167BCx(qpaTgf0vqdpgCiQLufeKr25YruafHrUIFJzkPgfXQs3OXvLUX40vqdpwRJulPkiiJmo9lO7veSnY3GzKXHuHjehYumWyCQxWktP7PZbo3yMsUQ0nAGx7XumgIx50xAYmIcIHjWyjaJUd)8NMd16A26rg3Lp0dqRXZCKpncJSZLJOakcJCf)gZusnkIvLUrJRkDJHyoYNgrRt6T9nY40VGUxrW2iFdMrghsfMqCitXaJXPEbRmLUNoh4CJzk5Qs3ObgyKKNuvyAGjZaBa]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170717.002219, [[dSZCmaGEvLqBsqTlsSnvLK9PQy2s1nLsNgX3OK8Cr2jsTxLDdz)KAuQQ0WqP(nupwOZRQQbtXWPehIsQoLQkoMO6CQk1cPkSuQslgjlhvpuu6PelJszDIcvtuuWuPunzQmDvUOaCvvLGldUok2OOqzRcOntvTDbQPjkKdl5ZcY8uvs9xP4zusXOvfJtvj6KcKVJsUgLu6EIIETQ0TjPdsv0lF2NiwGiP6KVyDemA02SwBtKiNy5MmHUuHjcrnR28fqp4()mU2KUc5kUBIxOdvcgTn25wX(RSLrk2SgBFZ(lN4fk3F7evycNbbjLJOcnhUX2epJhbJsZ(OZN9jbGkQo4MhtKiNy5M4akgFFfFiDaNGc1WcZGCkPRIVAZxNP2ytBcRnCgej2ybZc4koWNejN28rBS2jEsr6K7)eFiDaNGc1Koo5fMeeYrI1H5tqyemPf7cS40LkmzcDPctYyq6aobfsBKJtEHjEHoujy02yNBvo7jEHeMHhH0SVBs2hi(2Idgub0nQjTyhDPct2nABZ(KaqfvhCZJjsKtSCtSU2qX47RGGihNijfglAtyT5QoGofee54ejPaOIQdoTjS2WzqG281zQnwZepPiDY9FIdQ7PjIj9jbHCKyDy(eegbtAXUaloDPctMqxQWKma19OnzXK(eVqhQemABSZTkN9eVqcZWJqA23nj7deFBXbdQa6g1KwSJUuHj7gT1m7tcavuDWnpMiroXYnHIX3xbbroorskmw0MWAJdOy89v8H0bCckudlmdYPKUk(QnFYuBY1MWAdNbrInwWSaUId8jrYPnF0MVN4jfPtU)tsrmdpe0Koo5fMeeYrI1H5tqyemPf7cS40LkmzcDPctKiMHhc0g54KxyIxOdvcgTn25wLZEIxiHz4rin77MK9bIVT4GbvaDJAsl2rxQWKDJoJM9jbGkQo4MhtKiNy5MqX47RGGihNijfglAtyTXbum((k(q6aobfQHfMb5usxfF1MpzQn5AtyTHZGiXglywaxXb(Ki50MpAZ3t8KI0j3)jXEXIGc1KEkhMvAsqihjwhMpbHrWKwSlWItxQWKj0LkmjBVyrqH0g5PCywPjEHoujy02yNBvo7jEHeMHhH0SVBs2hi(2Idgub0nQjTyhDPct2nARD2NeaQO6GBEmrICILBcfJVVcd6b3)3KooGcDpkmw0MWAJdOy89v8H0bCckudlmdYPKUk(QnFYuBY1MWAdNbrInwWSaUId8jrYPnF0MVN4jfPtU)tsrmdpe0Koo5fMeeYrI1H5tqyemPf7cS40LkmzcDPctKiMHhc0g54KxqB(n)NjEHoujy02yNBvo7jEHeMHhH0SVBs2hi(2Idgub0nQjTyhDPct2n6VA2NeaQO6GBEmrICILBcfJVVcd6b3)3KooGcDpkmw0MWAJdOy89v8H0bCckudlmdYPKUk(QnFYuBY1MWAdNbrInwWSaUId8jrYPnF0MVN4jfPtU)tI9IfbfQj9uomR0KGqosSomFccJGjTyxGfNUuHjtOlvys2EXIGcPnYt5WSsAZV5)mXl0HkbJ2g7CRYzpXlKWm8iKM9DtY(aX3wCWGkGUrnPf7OlvyYUrB1Spjaur1b38yIe5el3eodc0MpzQn20MWAJdOy89v8H0bCckudlmdYPKUk(QnFYuBY1MWAdNbrInwWSaUId8jrYPnF0MVN4jfPtU)tsrmdpe0Koo5fMeeYrI1H5tqyemPf7cS40LkmzcDPctKiMHhc0g54KxqB(12pt8cDOsWOTXo3QC2t8cjmdpcPzF3KSpq8TfhmOcOButAXo6sfMSB0F5Spjaur1b38yIe5el3eodc0MpzQn20MWAJdOy89v8H0bCckudlmdYPKUk(QnFYuBY1MWAdNbrInwWSaUId8jrYPnF0MVN4jfPtU)tI9IfbfQj9uomR0KGqosSomFccJGjTyxGfNUuHjtOlvys2EXIGcPnYt5WSsAZV2(zIxOdvcgTn25wLZEIxiHz4rin77MK9bIVT4GbvaDJAsl2rxQWKDJ(7zFsaOIQdU5XejYjwUjx1b0PKEkhMvdb5ZKiyKcGkQo40MWAZvDaDkUI)2uCkYbCfavuDWPnH1gRRnum((kUI)2C8cL8XC16iyKcJfTjS2eX4UdZcP4k(BtXPihWv4GArqjT5J2KZEINuKo5(pXb190eXK(KGqosSomFccJGjTyxGfNUuHjtOlvysgG6E0MSysxB(n)NjEHoujy02yNBvo7jEHeMHhH0SVBs2hi(2Idgub0nQjTyhDPct2n6C2Z(KaqfvhCZJjsKtSCtUQdOtj9uomRgcYNjrWifavuDWPnH1gRRnx1b0P4k(BtXPihWvaur1bN2ewBSU2qX47R4k(BZXluYhZvRJGrkmwM4jfPtU)tCqDpnrmPpjiKJeRdZNGWiysl2fyXPlvyYe6sfMKbOUhTjlM01MFT9ZeVqhQemABSZTkN9eVqcZWJqA23nj7deFBXbdQa6g1KwSJUuHj7gDE(Spjaur1b38yIe5el3KR6a6uCf)TP4uKd4kaQO6GtBcRnrmU7WSqkUI)2uCkYbCfoOweusB(On5SN4jfPtU)tCqDpnrmPpjiKJeRdZNGWiysl2fyXPlvyYe6sfMKbOUhTjlM01MFTMFM4f6qLGrBJDUv5SN4fsygEesZ(UjzFG4Bloyqfq3OM0ID0Lkmz3OZTn7tcavuDWnpMiroXYnX6AZvDaDkPNYHz1qq(mjcgPaOIQdoTjS2yDT5QoGofxXFBkof5aUcGkQo4M4jfPtU)tCqDpnrmPpjiKJeRdZNGWiysl2fyXPlvyYe6sfMKbOUhTjlM01MFZOFM4f6qLGrBJDUv5SN4fsygEesZ(UjzFG4Bloyqfq3OM0ID0Lkmz3Ujza8lM(np2Tb]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170717.002219, [[dStujaGEsjvBsOAxKyBcfSpsLMTOUPk1Zf5BOsDAK2jkTxLDd1(P0OqrAyKIFRQhl48OOgmfdNu1HiL4uOiogeDoHcTqsPwkv0IH0Yr8qvWtjwgQyDKsIjcHmvQWKPQPl1fPs1vjLuUm46OQnskjTvQK2Sq2ovk)vfDyjFwfAEcfzCcf10ekz0OWZqLCsQeFhcUMqPUheQxRsUnjDqsfpKZXerpeOvMQ1RM(4XYj2CMWwQWeHQEWA0AygFMzTI1eQutpw9tM4eYqLGXYrdsU1edCILchU4eJAI5jsGq13tMOtOPponhJf5CmXDCHMb)0EIeiu99epGYhfPebPgiu8XteEESxj1v4YAIjeBnXYAIBneEmnCQ)raikEiIgOT1OR1WHRj6GsZ0M5jrqQbcfF8m1e6fmXfSNgQ(jtWpgMC)ExlcBPctMWwQWeTkKAGqXhTgPj0lyItidvcglhni5gPMjoH0ZtcqAowp5adiCD)UbQaUh6K73ZwQWK1JLZCmXDCHMb)0EIeiu99eTynO8rrkyiq(enPWR3AIBnDLbCRGHa5t0KcGl0m4TM4wdHhdwtmHyRHRj6GsZ0M5jEOAgNHNMN4c2tdv)Kj4hdtUFVRfHTuHjtylvycIGQzynhEAEItidvcglhni5gPMjoH0ZtcqAowp5adiCD)UbQaUh6K73ZwQWK1JLR5yI74cnd(P9ejqO67jO8rrkyiq(enPWR3AIBnEaLpksjcsnqO4JNi88yVsQRWL1OlITgUSM4wdHhtdN6FeaIIhIObABn6AnC4AIoO0mTzEsk88KJWzQj0lyIlypnu9tMGFmm5(9Uwe2sfMmHTuHjs45jhbRrAc9cM4eYqLGXYrdsUrQzIti98KaKMJ1toWacx3VBGkG7Ho5(9SLkmz9yJ1CmXDCHMb)0EIeiu99eu(OifEmJpZ8zQja(yZqHxV1e3A8akFuKseKAGqXhpr45XELuxHlRrxeBnCznXTgcpMgo1)iaefperd02A01A4W1eDqPzAZ8Ku45jhHZutOxWexWEAO6Nmb)yyY97DTiSLkmzcBPctKWZtocwJ0e6fynmfjtM4eYqLGXYrdsUrQzIti98KaKMJ1toWacx3VBGkG7Ho5(9SLkmz9yJ9CmXDCHMb)0EIeiu99ecpgSgDrS1WXAIBnEaLpksjcsnqO4JNi88yVsQRWL1OlITgUSM4wdHhtdN6FeaIIhIObABn6AnC4AIoO0mTzEsk88KJWzQj0lyIlypnu9tMGFmm5(9Uwe2sfMmHTuHjs45jhbRrAc9cSgMYHjtCczOsWy5Obj3i1mXjKEEsasZX6jhyaHR73nqfW9qNC)E2sfMSESXWCmXDCHMb)0EIeiu99KUYaUvsmk)JWjfhXNOpwbWfAg8wtCRPRmGBfFrUolckTbIcGl0m4TM4wJwSgu(OifFrUoBsHtrprTA6Jv41BnXTMW)z)JawXxKRZIGsBGOqa1IItwJUwdYyprhuAM2mpXdvZ4m808exWEAO6Nmb)yyY97DTiSLkmzcBPctqeundR5WtZwdtrYKjoHmujySC0GKBKAM4esppjaP5y9KdmGW197gOc4EOtUFpBPctwpwUNJjUJl0m4N2tKaHQVN0vgWTsIr5FeoP4i(e9XkaUqZG3AIBnAXA6kd4wXxKRZIGsBGOa4cndERjU1OfRbLpksXxKRZMu4u0tuRM(yfE9t0bLMPnZt8q1modpnpXfSNgQ(jtWpgMC)ExlcBPctMWwQWeebvZWAo80S1WuomzItidvcglhni5gPMjoH0ZtcqAowp5adiCD)UbQaUh6K73ZwQWK1JnMNJjUJl0m4N2tKaHQVN0vgWTIVixNfbL2arbWfAg8wtCRj8F2)iGv8f56SiO0gikeqTO4K1OR1Gm2t0bLMPnZt8q1modpnpXfSNgQ(jtWpgMC)ExlcBPctMWwQWeebvZWAo80S1WuUyYeNqgQemwoAqYnsntCcPNNeG0CSEYbgq46(DdubCp0j3VNTuHjRhBmohtChxOzWpTNibcvFprlwtxza3kjgL)r4KIJ4t0hRa4cndERjU1OfRPRmGBfFrUolckTbIcGl0m4NOdkntBMN4HQzCgEAEIlypnu9tMGFmm5(9Uwe2sfMmHTuHjicQMH1C4PzRHPXIjtCczOsWy5Obj3i1mXjKEEsasZX6jhyaHR73nqfW9qNC)E2sfMSE9eebrfFUN2R3aa]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170717.002219, [[dSJwmaGEvIsBsuSlsABQQk2NkPzRIBQs9Cr(gj0PrStKAVk7g0(PyuQQYWqP(nWJf68KGbtQHtIoKa0PuvPJPkoNQkwiLILsvAXiz5O6HIspLyzufRtLi1efatLs1KPY0L6IcKRQsuCzORJInQsKSvb0MPQ2UGYFfvhwY0uvvnpvvL(SG8mvcJwvACQevNuG67OKRPse3tq1RvvUnLCqkLEpZ(erjgj1HCzRMaGJ2ZL4zcDzHteIvwJ(YaFbhfU0gnbMAotSb80eV4bReoApSFuK9)45)QEUWZpSV8jsKtu2tMyBSjayA2h9ZSpjiyrDq3SzIe5eL9ehsX47R6JPg5eyOCwagOtn1v8ZO)3WnApgDgJMZajXCLawix1H(KiPn6Rg9LmXwkYH0kmXhtnYjWq5PMt(WjbdDKy1a(eiaItUbUaloDzHtMqxw4KlfMAKtGHmAP5KpCIx8GvchTh2pk(WEIxmby4rmn7RNK9fJF3GWqle2JAYnWrxw4K1J2ZSpjiyrDq3SzIe5eL9KaA0um((QqmYbjssLrPrNXO76GWwfIroirsQiSOoOZOZy0CgiA0)B4g9ftSLICiTctCy1V5ra5mjyOJeRgWNabqCYnWfyXPllCYe6YcNeaS6xJolGCM4fpyLWr7H9JIpSN4ftagEetZ(6jzFX43nim0cH9OMCdC0Lfoz9OVy2NeeSOoOB2mrICIYEcfJVVkeJCqIKuzuA0zmAhsX47R6JPg5eyOCwagOtn1v8ZOVgUrFHrNXO5mqsmxjGfYvDOpjsAJ(Qr)ZeBPihsRWKueWWdH5PMt(WjbdDKy1a(eiaItUbUaloDzHtMqxw4ejcy4HqJwAo5dN4fpyLWr7H9JIpSN4ftagEetZ(6jzFX43nim0cH9OMCdC0Lfoz9O))SpjiyrDq3SzIe5eL9ekgFFvig5GejPYO0OZy0oKIX3x1htnYjWq5SamqNAQR4NrFnCJ(cJoJrZzGKyUsalKR6qFsK0g9vJ(Nj2sroKwHjXtXIadLNElhGvAsWqhjwnGpbcG4KBGlWItxw4Kj0Lfoj7PyrGHmA5TCawPjEXdwjC0Ey)O4d7jEXeGHhX0SVEs2xm(DdcdTqypQj3ahDzHtwp6lz2NeeSOoOB2mrICIYEcfJVVkd8fCuip1CegQFvzuA0zmAhsX47R6JPg5eyOCwagOtn1v8ZOVgUrFHrNXO5mqsmxjGfYvDOpjsAJ(Qr)ZeBPihsRWKueWWdH5PMt(WjbdDKy1a(eiaItUbUaloDzHtMqxw4ejcy4HqJwAo5dn6)E(DIx8GvchTh2pk(WEIxmby4rmn7RNK9fJF3GWqle2JAYnWrxw4K1J(FM9jbblQd6MntKiNOSNqX47RYaFbhfYtnhHH6xvgLgDgJ2Hum((Q(yQrobgkNfGb6utDf)m6RHB0xy0zmAodKeZvcyHCvh6tIK2OVA0)mXwkYH0kmjEkweyO80B5aSstcg6iXQb8jqaeNCdCbwC6YcNmHUSWjzpflcmKrlVLdWkz0)987eV4bReoApSFu8H9eVycWWJyA2xpj7lg)UbHHwiSh1KBGJUSWjRhTIZ(KGGf1bDZMjsKtu2t4mq0OVgUr7XOZy0oKIX3x1htnYjWq5SamqNAQR4NrFnCJ(cJoJrZzGKyUsalKR6qFsK0g9vJ(Nj2sroKwHjPiGHhcZtnN8Htcg6iXQb8jqaeNCdCbwC6YcNmHUSWjseWWdHgT0CYhA0)553jEXdwjC0Ey)O4d7jEXeGHhX0SVEs2xm(DdcdTqypQj3ahDzHtwp6lF2NeeSOoOB2mrICIYEcNbIg91WnApgDgJ2Hum((Q(yQrobgkNfGb6utDf)m6RHB0xy0zmAodKeZvcyHCvh6tIK2OVA0)mXwkYH0kmjEkweyO80B5aSstcg6iXQb8jqaeNCdCbwC6YcNmHUSWjzpflcmKrlVLdWkz0)553jEXdwjC0Ey)O4d7jEXeGHhX0SVEs2xm(DdcdTqypQj3ahDzHtwp6FM9jbblQd6MntKiNOSN01bHTA6TCaw5eOptIaGQiSOoOZOZy0DDqyR6k(xEXPinYvryrDqNrNXOdOrtX47R6k(xEZlyYhWTQMaGQmkn6mgDeaooalOQR4F5fNI0ixLJwfbMm6Rg9d7j2sroKwHjoS638iGCMem0rIvd4tGaio5g4cS40LfozcDzHtcaw9RrNfqog9Fp)oXlEWkHJ2d7hfFypXlMam8iMM91tY(IXVBqyOfc7rn5g4OllCY6r)WE2NeeSOoOB2mrICIYEsxhe2QP3YbyLtG(mjcaQIWI6GoJoJrhqJURdcBvxX)YlofPrUkclQd6m6mgDanAkgFFvxX)YBEbt(aUv1eauLr5eBPihsRWehw9BEeqotcg6iXQb8jqaeNCdCbwC6YcNmHUSWjbaR(1OZcihJ(pp)oXlEWkHJ2d7hfFypXlMam8iMM91tY(IXVBqyOfc7rn5g4OllCY6r)8m7tccwuh0nBMirorzpPRdcBvxX)YlofPrUkclQd6m6mgDeaooalOQR4F5fNI0ixLJwfbMm6Rg9d7j2sroKwHjoS638iGCMem0rIvd4tGaio5g4cS40LfozcDzHtcaw9RrNfqog9Fx87eV4bReoApSFu8H9eVycWWJyA2xpj7lg)UbHHwiSh1KBGJUSWjRh9JNzFsqWI6GUzZejYjk7jb0O76GWwn9woaRCc0Njraqvewuh0z0zm6aA0DDqyR6k(xEXPinYvryrDq3eBPihsRWehw9BEeqotcg6iXQb8jqaeNCdCbwC6YcNmHUSWjbaR(1OZcihJ(V))7eV4bReoApSFu8H9eVycWWJyA2xpj7lg)UbHHwiSh1KBGJUSWjRxpjaOFXC6zZ6na]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170717.002219, [[deeIxaqievTjPsFIuLsJcr5uis7IkggjCmrSmsPNrQctdruxdrOTjvu(gjQXHiW5KkY6ivPQ5HiY9quzFKQKdsISquv9qQetKuLkxKuvBKQQ8rsvkgjIGojvs3uQANOYpLkQwkP4PuMkPYwPQYxPQQSxL)svgmrhgyXi8yrnzqUSQnlL(mvLrJQCAuEnvQzl0Tb1UH63qgUuCCsv0Yr65cMUKRtsBxK67OQCErY6PQQA(sf2pHxY0nJda)zgd2fH0FuuO07fsFhFklpZAEMbIm)humeECAjXKz6DVfOgRX)mnpEq4JtRIeLv0zAjzhT6H2oPGemtZbqP0XG)mYxG4XLtlffQqovX7ohdiIhsibyiHuHqIOcjHABRJBwmYW(8GbzEm8DOhgWWHzkLlgchMUXLmDZ0hdiIhA8pZYuwtnRq(8fVtgHIqi(WbHSRqsMqsMqsEHSaXJlNwkY)p2RrngUZXaI4HeYo6qijtiPQ4lKKKqQvi7kKuvml71G47uNSkLECjKKKqQLeiKKkKKkKDfsYlKfiEC54du8oLH95fkef25yar8qcjPZuIGfzvQziIiRofumeEMRyiwgui6mmc)z9ii)auoa8NnJda)zDorKvNckgcptZJhe(40Qir5efZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgN2PBM(yar8qJ)zwMYAQzeQTToSCkVcer4Gd9WagoiKKKqM4qIczxHSaXJlhwoLxbIiCW5yar8qZuIGfzvQzTuuO8cfL5(ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOesROm3FMMhpi8XPvrIYjkMP5bKkn)W0TAMl8E2Dpk9HpUgXSEeeha(Zwno9y6MPpgqep04FMLPSMAwbIhxobEGQoLH95fkkZ9dohdiIhsi7kKqNqTT1Hc8FeLLVtOaz3cj5essCMseSiRsnRLIcLxOOm3FMRyiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL5(cjzjKotZJhe(40Qir5efZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRghjpDZ0hdiIhA8pZYuwtnJmHKqTT1HYGVJAJq2viVEQYAAoKtZPHN(uaoFpuRxX7ENaH9Gb0kfvi7kKKxijtijuBBDqerwDkOyiSJAJq2vib5IL(EhFy2dcjjjKAfssfssfYo6qilq84YXhO4Dkd7ZluikSZXaI4HMPeblYQuZOhgrdp(qWJpgUoDMRyiwgui6mmc)z9ii)auoa8NnJda)zAomIgE8HGq6FmCD6mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACK40ntFmGiEOX)mltzn1mc12whkd(oQnczxHK8cjzcjHABRdIiYQtbfdHDuBeYUcjixS0374dZEqijjHuRqsQq2vijVqsMqE9uL10CiNMtdp9PaC(EOwVI39obc7bdOvkQq2vilq84YXhO4Dkd7ZluikSZXaI4HessNPeblYQuZ4H4lYW(8iIGqnZvmeldkeDggH)SEeKFakha(ZMXbG)msiIVid7ti5pcc1mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACD20ntFmGiEOX)mltzn1mc12whkd(oQnczxHK8cjzcjHABRdIiYQtbfdHDuBeYUcjixS0374dZEqijjHuRqsQq2viVEQYAAoKtZPHN(uaoFpuRxX7ENaH9Gb0kfvi7kKfiEC54du8oLH95fkef25yar8qczxHKmHe6eQTTonNgE6tb489qTEfV7Dce2dgqRuuh1gHSJoeYmcfHq8HDOhgrdp(qWJpgUo1HEyadhes9si1dHK0zkrWISk1mEi(ImSppIiiuZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pJeI4lYW(es(JGqjKKLq6mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACkpDZ0hdiIhA8pZYuwtnJ8cjHABRdIiYQtbfdHDuBeYUcjzc51tvwtZHCCJIfJccE4Zxlsfd5XhlgfYUczbIhxoTuK)FSxJAmCNJbeXdjKDfsYeYWlpcewn4uStt6KN2MSqsoHmri7OdHm8YJaHvdof70Ko5rYnzHKCczIqsQqsQq2rhcjvf)GtXGVxH8irHKKesFzOzkrWISk1merKvNcQpZvmeldkeDggH)SEeKFakha(ZMXbG)SoNiYQtb1NP5XdcFCAvKOCIIzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJJemDZ0hdiIhA8pZYuwtnRq(8fVtgHIqi(WbHSRqsMqsMqE9uL10CiNmchq0k4LrriVmIEHSJoesc12wNgwmcOEOwVwkkuoQncjPczxHKqTT1rfZdft5fk6X(kEoQnczxHe6eQTTouG)JOS8Dcfi7wijNqsIczxHK8cjHABRdIiYQtbfdHDuBessNPeblYQuZcmmef4dfabVwvAQzUIHyzqHOZWi8N1JG8dq5aWF2moa8Nzmmef4dfa6TbH0FQ0uZ084bHpoTksuorXmnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QX1PPBM(yar8qJ)zwMYAQzuvml71G47uhO3YYSsijjYjKjkMPeblYQuZAPOq5fkkZ9N5kgILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzUVqsMwsNP5XdcFCAvKOCIIzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJlrX0ntFmGiEOX)mltzn1mc12wherKvNckgc7O2iKDfsYlKeQTToUzXid7ZdgK5XW3rTzMseSiRsnRLIcLxOOm3FMRyiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL5(cjz6bPZ084bHpoTksuorXmnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXLKmDZ0hdiIhA8pZYuwtndKlw67D8HzpiK6f5esTczxHK8cjzczbIhxoTuuOc5ufV7CmGiEiHSRqsO2264MfJmSppyqMhdFh1gHSRqcYfl99o(WShes9ICcPwHK0zkrWISk1m6Hr0WJpe84JHRtN5kgILbfIodJWFwpcYpaLda)zZ4aWFMMdJOHhFiiK(hdxNkKKLq6mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACjANUz6JbeXdn(NzzkRPMrO2264MfJmSppyqMhdFh1gHSRqsMqsEH86PkRP5qoUrXIrbbp85RfPIH84JfJczhDiKGCXsFVJpm7bHuViNqQvijDMseSiRsnRLIcviNQ49zUIHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkuHCQI3NP5XdcFCAvKOCIIzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJlrpMUz6JbeXdn(NzzkRPMbYfl99o(WShes9ICcP2zkrWISk1mFrqMbIEaO0aC(ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4ptVjcYmquivcknaN)mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACjK80ntFmGiEOX)mltzn1mqUyPV3XhM9GqQxKti1JzkrWISk1SwkkuHCQI3N5kgILbfIodJWFwpcYpaLda)zZ4aWFM)OOqfYPkExijlH0zAE8GWhNwfjkNOyMMhqQ08dt3QzUW7z39O0h(4AeZ6rqCa4pB14siXPBM(yar8qJ)zwMYAQzeQTToUzXid7ZdgK5XW3rTzMseSiRsndrez1PG6ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pRZjIS6uqDHKSesNP5XdcFCAvKOCIIzAEaPsZpmDRM5cVND3JsF4JRrmRhbXbG)SvJlPZMUz6JbeXdn(NzzkRPMvG4XLJpqX7ug2NxOquyNJbeXdjKDfYcepUCGvPqNIudEVTLLzhNt5CmGiEiHSRqsMqgE5rGWQbNIDAsN802KfsYjKjczhDiKHxEeiSAWPyNM0jpsUjlKKtitessNPeblYQuZAPOq5fkkZ9N5kgILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzUVqsgjt6mnpEq4JtRIeLtumtZdivA(HPB1mx49S7Eu6dFCnIz9iioa8NTACjkpDZ0hdiIhA8pZYuwtnJmHSaXJlhEik2d16XhdxN6CmGiEiHSJoeYcepUC4PI9Dkd7ZJQIVhFh0GWohdiIhsijvi7kKKjKHxEeiSAWPyNM0jpTnzHKCczIq2rhcz4LhbcRgCk2PjDYJKBYcj5eYeHK0zkrWISk1SwkkuEHIYC)zUIHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuM7lKKrIKotZJhe(40Qir5efZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgxcjy6MPpgqep04FMseSiRsndrez1PG6ZCfdXYGcrNHr4pRhb5hGYbG)SzCa4pRZjIS6uqDHKmTKotZJhe(40Qir5efZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgxsNMUz6JbeXdn(NPeblYQuZ8fbzgi6bGsdW5pZvmeldkeDggH)SEeKFakha(ZMXbG)m9MiiZarHujO0aC(cjzjKotZJhe(40Qir5efZ08asLMFy6wnZfEp7UhL(WhxJywpcIda)zRgNwft3m9XaI4Hg)ZSmL1uZiVqsO226Wtf77ug2NhvfFp(oObHDuBMPeblYQuZ4HOypuRhFmCD6mxXqSmOq0zye(Z6rq(bOCa4pBgha(ZiHikwirTcP)XW1PZ084bHpoTksuorXmnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXPnz6MPpgqep04FMseSiRsnRLIcLxOOm3FMRyiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL5(cjzDgPZ084bHpoTksuorXmnpGuP5hMUvZCH3ZU7rPp8X1iM1JG4aWF2QXPv70ntFmGiEOX)mltzn1Sc5Zx8ozekcH4dhMPeblYQuZoCdIVt9OQ47X3bni8mxXqSmOq0zye(Z6rq(bOCa4pBgha(Z0hUbX3PcPgv8fs)7GgeEMMhpi8XPvrIYjkMP5bKkn)W0TAMl8E2Dpk9HpUgXSEeeha(ZwnoT6X0ntFmGiEOX)mltzn1Sc5Zx8ozekcH4dheYUcjzcj5fsc12whEQyFNYW(8OQ47X3bniSJAJqs6mLiyrwLAgpvSVtzyFEuv8947GgeEMRyiwgui6mmc)z9ii)auoa8NnJda)zKqvSVtzyFcPgv8fs)7GgeEMMhpi8XPvrIYjkMP5bKkn)W0TAMl8E2Dpk9HpUgXSEeeha(ZwTAMLPSMA2Qna]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170717.002219, [[dauwuaqiOuTiLqTjOKrjeDkHKDrfddkogewMs0ZuQW0ivKRPeY2uQiFJuLXbLIoNsqSoLaZdkLUhvjTpsfoOsvlKuPhQumrLG0ffsTrLkDsQsntLG6Mq0ojLHsQOwkvvpLYuPkUQsfvBviSxv)fsdMWHfTyO6XszYs1LrTzQ0NvsJgrDAKETsPzl42iSBq)wYWrKJRurz5apNKPR46c12PQ47uv68KQA9qPW8PkX(j6J4EUPLe8nJsSrk2fuQzbsrNDZ4WCBHYUzCyUU3msCJMbk2ihAbV2YfH4MFoWPIV2smi0dZoTuNCwUJLlemyZB(5SRVhkbFdedPnusLVmWXndbf6uOl172(2qlO6EUgI75w0WepW9R7nRbOKMBtTUgyhkCyaiM0OUThNgOJ(3iOWoQlGzSbFZByN2YPa3GfKVHS6rKaTKGVDtlj4BiPWUuSlGzSbFZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3(CTL3ZTOHjEG7x3Bwdqjn3aXqAdLu5ldC6SlTrhPqhsXsmsbwsb2LIjdmCCWbCoKrlxuff2b5APshgM4bUFBponqh9VLGwcz0Paago38g2PTCkWnyb5BiREejqlj4B30sc(2EqlHSu4Paago38Zbov81wIbHEiWCZpRQyqJv3ZNBBiZTTilFycgoh)gYQRLe8TpxBh3ZTOHjEG7x3Bwdqjn3MmWWXbhW5qgTCrvuyhKRLkDyyIh4UuGLu0RXbhW5qgTCrvuyhKRLkDgABlfUkfyjfGyiTHsQ8LboTyaGHJuGTsXoWifyjfGyilfyRuS82ECAGo6FlbTeYOtbamCU5nStB5uGBWcY3qw9isGwsW3UPLe8T9GwczPWtbamCKIire1n)CGtfFTLyqOhcm38ZQkg0y19852gYCBlYYhMGHZXVHS6AjbF7Z10P75w0WepW9R7nRbOKMBtTUgyNwvHE5lujfyjfrkf4XUUoKOHqcqlxuxqPgNyssru32Jtd0r)B4HQ6OUXa9V5nStB5uGBWcY3qw9isGwsW3UPLe8nDdv1LIDJb6FZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3(CTfDp3IgM4bUFDVznaL0CBQ11a70Qk0lFHkPalPisPap211HenesaA5I6ck14etskI62ECAGo6FdNbkgSLcxV5nStB5uGBWcY3qw9isGwsW3UPLe8nDzGIbBPW1B(5aNk(AlXGqpeyU5NvvmOXQ75ZTnK52wKLpmbdNJFdz11sc(2NRTt3ZTOHjEG7x3B7XPb6O)TyfJshMqDZByN2YPa3GfKVHS6rKaTKGVDtlj4B7CflfEpmH6MFoWPIV2smi0dbMB(zvfdAS6E(CBdzUTfz5dtWW543qwDTKGV95A6Dp3IgM4bUFDVznaL0CdedzLZqjy0PqxKuGTsXoKcSKIiLcSlf9ACWbCoKrlxuff2b5APsNH22sHRsHx8IuaIH0gkPYxg40IbagosHoKIDcJue1T940aD0)whKXRKh0YfvvXb1nVHDAlNcCdwq(gYQhrc0sc(2nTKGVTqbz8k5rkkxPWQ4G62EWQ6gmjyV2bz8k5bTCrvvCqDZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3(CnS59ClAyIh4(19M1ausZTPwxdSdPAOfujfyjfrkf4XUUoKOHqcqlxuxqPgNyssbwsrKsb2LIjdmCCWbCoKrlxuff2b5APshgM4bUlfEXlsb2LIwvHE5l0bhW5qgTCrvuyhKRLkDamrsHkPqhsbgPikPiQB7XPb6O)ns1ql4nVHDAlNcCdwq(gYQhrc0sc(2nTKGVPZ1ql4n)CGtfFTLyqOhcm38ZQkg0y19852gYCBlYYhMGHZXVHS6AjbF7Z1wi3ZTOHjEG7x3Bwdqjn3WUumzGHJdoGZHmA5IQOWoixlv6WWepW9B7XPb6O)ns0qibOLlQlOuZnVHDAlNcCdwq(gYQhrc0sc(2nTKGVPZ0qibsr5kf7ck1CZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3(CneyUNBrdt8a3VU3SgGsAUnzGHJdoGZHmA5IQOWoixlv6WWepWDPalPOvvOx(cDWbCoKrlxuff2b5APshatKuOsk0HuOtyUThNgOJ(3irdHeGwUOUGsn38g2PTCkWnyb5BiREejqlj4B30sc(MotdHeifLRuSlOuJuejIOU5NdCQ4RTedc9qG5MFwvXGgRUNp32qMBBrw(WemCo(nKvxlj4BFUgce3ZTOHjEG7x3Bwdqjn3MmWWXbhW5qgTCrvuyhKRLkDyyIh4UuGLuGDPOvvOx(cDWbCoKrlxuff2b5APshatKuOsk0HuGrkWskaXqAdLu5ldCAXaadhPqhEvkwegPalPG3zXusK4UtRG(WGvg2y0Yf1nhwjfyjfTQc9YxOd5y4kdOWvuqmKr9Ltsf0bWejfQKcSvkqG52ECAGo6FJenesaA5I6ck1CZByN2YPa3GfKVHS6rKaTKGVDtlj4B6mnesGuuUsXUGsnsrKlJ6MFoWPIV2smi0dbMB(zvfdAS6E(CBdzUTfz5dtWW543qwDTKGV95AiwEp3IgM4bUFDVznaL0CBYadhhCaNdz0YfvrHDqUwQ0HHjEG7sbwsb2LIwvHE5l0bhW5qgTCrvuyhKRLkDamrsHkPqhsbgPalPaedPnusLVmWPfdamCKcD4vPyryKcSKcSlf8olMsIe3DAf0hgSYWgJwUOU5WkPalPisPOvvOx(cDihdxzafUIcIHmQVCsQGoaMiPqLuGTsbIfjfEXlsXKGvECgkbJofANYsHoKce7yrsru32Jtd0r)BKOHqcqlxuxqPMBEd70wof4gSG8nKvpIeOLe8TBAjbFtNPHqcKIYvk2fuQrkIChrDZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3(Cne74EUfnmXdC)6EZAakP52uRRb2PvvOx(cvsbwsrKsbESRRdjAiKa0Yf1fuQXjMKue1T940aD0)goGZHmA5IQOWoixlvEZByN2YPa3GfKVHS6rKaTKGVDtlj4B6c4CilfLRuyuyhKRLkV5NdCQ4RTedc9qG5MFwvXGgRUNp32qMBBrw(WemCo(nKvxlj4BFUgcD6EUfnmXdC)6EZAakP5gESRRtRcDuYCcgh1KTTsHxLILyKcV4fPisPap211HenesaA5I6ck14ayIKcvsb2kfRTUuGLuGh766qIgcjaTCrDbLACIjjfyjfrkf4XUUoTk0rjZjyCut22kf6WRsbcesHx8IuePuGh7660QqhLmNGXrnzBRuOdVkfiWifyjfkEqXlySYzOmyjguDIutk0HuGrkIskIskI62ECAGo6FRroPqfA5IsB8nVHDAlNcCdwq(gYQhrc0sc(2nTKGVTHCsHkPOCLcVB8n)CGtfFTLyqOhcm38ZQkg0y19852gYCBlYYhMGHZXVHS6AjbF7Z1qSO75w0WepW9R7nRbOKMByxkMmWWXbhW5qgTCrvuyhKRLkDyyIh4UuGLuGDPisPyYadhN1CiZakCfvnfGWHHjEG7sbwsbESRRdGjkGIdSsH6lfomWjMKue1T940aD0)wldb0Sn0cIgOQ5M3WoTLtbUbliFdz1JibAjbF7MwsW32KHGuSVn0ckflmvn32dwv3Gjb71fBuInsXUGsnlqkwzidOTfFZph4uXxBjge6HaZn)SQIbnwDpFUTHm32IS8Hjy4C8BiRUwsW3mkXgPyxqPMfifRmKb02NRHyNUNBrdt8a3VU3SgGsAUnzGHJdoGZHmA5IQOWoixlv6WWepWDPalPa7srVghCaNdz0YfvrHDqUwQ0zOTTu46T940aD0)wldb0Sn0cIgOQ5M3WoTLtbUbliFdz1JibAjbF7MwsW32KHGuSVn0ckflmvnsrKiI62EWQ6gmjyVUyJsSrk2fuQzbsbEPw8n)CGtfFTLyqOhcm38ZQkg0y19852gYCBlYYhMGHZXVHS6AjbFZOeBKIDbLAwGuGxQpxdHE3ZTOHjEG7x3Bwdqjn3MmWWXbhW5qgTCrvuyhKRLkDyyIh4UuGLu0RXbhW5qgTCrvuyhKRLkDgABlfUEBponqh9V1YqanBdTGObQAU5nStB5uGBWcY3qw9isGwsW3UPLe8Tnziif7BdTGsXctvJue5YOUThSQUbtc2Rl2OeBKIDbLAwGuGxkPyOTTu46IV5NdCQ4RTedc9qG5MFwvXGgRUNp32qMBBrw(WemCo(nKvxlj4BgLyJuSlOuZcKc8sjfdTTLcx)CneyZ75w0WepW9R7nRbOKMBtgy44SMdzgqHROQPaeommXdCxkWskWJDDDamrbuCGvkuFPWHboXKKcSKcSlftgy44Gd4CiJwUOkkSdY1sLommXdC)2ECAGo6FRLHaA2gAbrdu1CZByN2YPa3GfKVHS6rKaTKGVDtlj4BBYqqk23gAbLIfMQgPiYDe1T9Gv1nysWEDXgLyJuSlOuZcKIvLum02wkCDX38Zbov81wIbHEiWCZpRQyqJv3ZNBBiZTTilFycgoh)gYQRLe8nJsSrk2fuQzbsXQskgABlfU(5ZnRbOKMBF(b]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170717.002219, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEnLuLXwzHnxzE5KmWeZnWyJm04ImZitoWGJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnLx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170717.002219, [[deubnaqisjTjQeFsPs0OOs5uuPAxsYWqkhtjTmQONHuvnnQKQRHuL2gsv03qQmoKQY5uQuwNsLW8uQO7Huf2hvs5GOsTqujpKuyIkvsDrsrBuPcFuPsYijLOtsQ4MsPDcQFsLKwkQ4Petfv1wjv6RKsyVI)QugmfhwvlgrpwQMmixgAZsXNrvgnPQttYRPcZMQUnc7g43kgUsCCLkvlhLNlX0v56iz7kv9DjvNxsz9ujX8jLA)u6Sg(rGFcmIOi0WA2bBk3UWA4vSMt1DOa8Iilyx9ELR8NAab2j9UgzxJnpL)cxr4GE8lyGDsBLoA0tNUELt635UrJ(IWbFOA8veyesQMMk9uaEitb4TXOa4wD8xgqfdjEfOeH7(Pgqj8d8A4hrtWt6rOWvePZulxesQMMkvV229(buQyiXRafRzNwZAf9AnUyn37rWvP612U3pGsfcEspcfHBsLxD1I0WMYTvoMYbgrhaKQ)3WIagagPDG09zWpbgjc8tGr2bBkN1iht5aJWb94xWa7K2kDR0IWbldfRJLWpxen0JDhTZEKabxiJ0oqWpbgjxGDg(r0e8KEekCfHBsLxD1IWqIHvqpwkB1vGdzr0baP6)nSiGbGrAhiDFg8tGrIa)eyeoiXWkOhlfRrluGdzr4GE8lyGDsBLUvAr4GLHI1Xs4NlIg6XUJ2zpsGGlKrAhi4NaJKlW0F4hrtWt6rOWvePZulxesQMMkMIaROwSgxSgTAnUznKunnvdPxDi7p1aQOwSgxSMVFQ94gcqcfwSMDAnoTg3JWnPYRUAr0p19kaVns)xUi6aGu9)gweWaWiTdKUpd(jWirGFcmIwo19kapRHl)xUiCqp(fmWoPTs3kTiCWYqX6yj8Zfrd9y3r7ShjqWfYiTde8tGrYfyxp8JOj4j9iu4kI0zQLlYn845XQ(mEOPoOynUynUznUznA1AU3JGRQHnUcc2wO8fScbpPhHSgT12ACZAyua0A2P140ACXAyuavFBzQJSQofJHGZA2P14K(Sg3Tg3Tg3JWnPYRUArgsV6q2FQberhaKQ)3WIagagPDG09zWpbgjc8tGrCvsV6q2FQbeHd6XVGb2jTv6wPfHdwgkwhlHFUiAOh7oAN9ibcUqgPDGGFcmsUatVHFenbpPhHcxrKotTCryua0ACnRH(TgT12AiPAAQCO8EfG3gX31Rayf1I1OT2wdjvtt1q6vhY(tnGkQLiCtQ8QRwKH0RoK9hgrhaKQ)3WIagagPDG09zWpbgjc8tGrCvsV6q2FyeoOh)cgyN0wPBLweoyzOyDSe(5IOHES7OD2Jei4czK2bc(jWi5cm9m8JOj4j9iu4kI0zQLlYn845XQ(mEOPoOynUynUznUzn4UtPwwqOQ(akd7kB9XdT1hgAnART1qs10uTO8(NTnnBnSPCvulwJ7wJlwdjvttffq)4RTvogc4D6ROwSgxSgiKKQPPI9UYWuDSQCF3H1qpSg61ACXA0Q1qs10unKE1HS)udOIAXACpc3KkV6QfPOaqSN3u(YwdfRweDaqQ(FdlcyayK2bs3Nb)eyKiWpbgruai2ZBk)USyn7GIvlch0JFbdStAR0TslchSmuSowc)Cr0qp2D0o7rceCHms7ab)eyKCbMUWpIMGN0JqHRisNPwUiKunnvouEVcWBJ476vaSIAXACXACZA0Q1G7oLAzbHQCm(tX(YgaR3muaOT6kV3A0wBR5EpcUkE)PhzkaVTYnmIke8KEeYA0wBR57NApUHaKqHfRX1OhwJtRX9iCtQ8QRwKg2uUsV2PhJOdas1)ByradaJ0oq6(m4NaJeb(jWi7GnLR0RD6XiCqp(fmWoPTs3kTiCWYqX6yj8Zfrd9y3r7ShjqWfYiTde8tGrYfy6l8JOj4j9iu4kI0zQLlcJcO6BltDKv1PymeCwJRzn0hnRrBTTg3SgsQMMQH0RoK9NAavulwJlwJwTgsQMMkhkVxb4Tr8D9kawrTynUhHBsLxD1I0WMYTvoMYbgrhaKQ)3WIagagPDG09zWpbgjc8tGr2bBkN1iht5aTg3wDpch0JFbdStAR0TslchSmuSowc)Cr0qp2D0o7rceCHms7ab)eyKCbE3c)iAcEspcfUIWnPYRUArgsV6q2FyeDaqQ(FdlcyayK2bs3Nb)eyKiWpbgXvj9Qdz)HwJBRUhHd6XVGb2jTv6wPfHdwgkwhlHFUiAOh7oAN9ibcUqgPDGGFcmsUaVsl8JOj4j9iu4kI0zQLlcJcO6BltDKv1PymeCwZoTg6OznUynA1AiPAAQ0tb4HmfG3gJcGB1XFzavulr4Mu5vxTi6hgyBA2QRahYIOdas1)ByradaJ0oq6(m4NaJeb(jWiA5WawZ0ynAHcCilch0JFbdStAR0TslchSmuSowc)Cr0qp2D0o7rceCHms7ab)eyKCbEDn8JOj4j9iu4kc3KkV6QfHN)7Q3V9q7FqhJOdas1)ByradaJ0oq6(m4NaJeb(jWi7k)3vV3A4gA)d6yeoOh)cgyN0wPBLweoyzOyDSe(5IOHES7OD2Jei4czK2bc(jWi5c8QZWpIMGN0JqHRiCtQ8QRwKg2uUTYXuoWi6aGu9)gweWaWiTdKUpd(jWirGFcmYoyt5Sg5ykhO14Mt3JWb94xWa7K2kDR0IWbldfRJLWpxen0JDhTZEKabxiJ0oqWpbgjxGxP)WpIMGN0JqHRisNPwUi3WJNhR6Z4HM6GI14I14M1OvRHKQPPspfGhYuaEBmkaUvh)LburTynUhHBsLxD1IONcWdzkaVngfa3QJ)YaIOdas1)ByradaJ0oq6(m4NaJeb(jWiAjfGhYuaEwdhkaAnAb(ldich0JFbdStAR0TslchSmuSowc)Cr0qp2D0o7rceCHms7ab)eyKCbE11d)iAcEspcfUIiDMA5ICdpEESQpJhAQdkr4Mu5vxTiiXYuhzBmkaUvh)LberhaKQ)3WIagagPDG09zWpbgjc8tGr0KyzQJmRHdfaTgTa)LbeHd6XVGb2jTv6wPfHdwgkwhlHFUiAOh7oAN9ibcUqgPDGGFcmsUCrKotTCrYLa]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170717.002219, [[deKvsaqisH2eb5tsevJcQQtbvzvqfYUOsddjDmOyzcQNjrY0Gk6AKcSnbr(guPXrkOoNerwhPGyEsK6EqfSpQkoivjlKu0dPk1ejfKUivL2OeHrcvOojvvUjuANe6Nccwkv0tPmvQITsvvFvqu7v1FjvdgvhgYIrQhlPjlvxgSzK4ZuHrtkDAIETemBHUTu2nIFRy4e44ccTCLEojtx01fy7euFxcDEjQ1lruMVG0(r5J5EUjIAWnt28MXlXoQudHXPh1ntauLOOSKHs5qUyynaZnnuGckiMxZBoHiGuWfdtfdUudPW40nCPcxsu1W3CcOEzpYgCBdiYQUGPiSUuqXOsphDCPEZRAkhI6EUiM75MVeeDe6xZBwDLcYBjkcK0vwlRNO4quUabrhHoJleJthqHIRSwwprXHOCxOHKefJxAg3rTZ4cX41zI9PiXLEbuQvFOORKK(ICmkK7cnKKOyCFy8nGak3u2a9C0X5nVOLrzw(gLDuPUkxzb4MFKUSIYzVrgcCd709hTIOgC7MiQb3kXoQKXTCLfGBoHiGuWfdtfdUyOEZjOMGTcQ755nV1c1cyhHHgqYtFd70frn42Zlg(EU5lbrhH(18MvxPG8wIIajDDGsTWkjo0v5SnxGGOJq)Mx0YOmlFBH2SkickLErjjH9MFKUSIYzVrgcCd709hTIOgC7MiQb3CcTzvqeukgpKLKe2BoHiGuWfdtfdUyOEZjOMGTcQ755nV1c1cyhHHgqYtFd70frn42ZlwQ75MVeeDe6xZBwDLcYB0buO4UYg4giGXfIX3acOCtzd0ZrhNmEPzC8zCh1oJJJy8WmoE38IwgLz5BANIrjXHoDePYB(r6YkkN9gziWnSt3F0kIAWTBIOgCdhpfJsIdgxZisL3CcraPGlgMkgCXq9MtqnbBfu3ZZBERfQfWocdnGKN(g2PlIAWTNxeN3ZnFji6i0VM3S6kfK32acOCtzd0ZrpKy8sZ4oQDgxigxJmEIIajDDGsTWkjo0v5SnxGGOJq)Mx0YOmlFBOJYewuc38J0Lvuo7nYqGByNU)Ove1GB3ern4wiqhLjSOeU5eIasbxmmvm4IH6nNGAc2kOUNN38wlulGDegAajp9nStxe1GBpVOgCp38LGOJq)AEZQRuqEBdiGYnLnqphDCY4LMXDu7mUqmo(mEDMyFksCPxaLA1hk6kjPVihJc5Uqdjjkg3hgNkJhAOm(gqKvDbtryDRb7cKKXlnJJlvghVBErlJYS8THoktyrjCZpsxwr5S3idbUHD6(JwrudUDte1GBHaDuMWIsGXXhdE3CcraPGlgMkgCXq9MtqnbBfu3ZZBERfQfWocdnGKN(g2PlIAWTNxmKUNB(sq0rOFnVz1vkiVTbezvxWuew3AWUajzCFWbgVK0agxigxbPo9qcuUPewmLKoofuzCFyCQmUqmEDMyFksCPxaLA1hk6kjPVihJc5Uqdjjkg3hgN6nVOLrzw(gLDuPUkxzb4MFKUSIYzVrgcCd709hTIOgC7MiQb3kXoQKXTCLfaghFm4DZjebKcUyyQyWfd1Bob1eSvqDppV5TwOwa7im0asE6ByNUiQb3EErCVNB(sq0rOFnVz1vkiVrhqHI7kBGBGagxighcXaPabq3vaSkqyyrKkOpu0tTGoqpe9gAZY7nVOLrzw(2cTzvqeuk9Issc7n)iDzfLZEJme4g2P7pAfrn42nrudU5eAZQGiOumEiljjSmo(yW7MticifCXWuXGlgQ3CcQjyRG6EEEZBTqTa2ryObK803WoDrudU98IA475MVeeDe6xZBwDLcYB0buO4UYg4giGXfIXXNX7t6UqBwfebLsVOKKW6MYAbjXbJhAOmEDMyFksCxOnRcIGsPxussyDxOHKefJ7dJ7O2z8qdLXXNX1iJdHyGuGaO7kawfimSisf0hk6PwqhOhIEdTz5LXfIX1iJNOiqsxhOulSsIdDvoBZfii6i0zC8yC8U5fTmkZY30ofJsIdD6isL38J0Lvuo7nYqGByNU)Ove1GB3ern4goEkgLehmUMrKkzC8XG3nNqeqk4IHPIbxmuV5eutWwb1988M3AHAbSJWqdi5PVHD6IOgC75flP75MVeeDe6xZBwDLcYBAKXPdOqXDLnWnqaJleJRrghFgprrGKUoqPwyLeh6QC2Mlqq0rOZ4cX4AKXXNXRZe7trI7cTzvqeuk9IsscR7cnKKOyCFyC8zCh1oJJJy8WmoEmEOHY4BabyCFyCCY44X44X4cX4BabyCFy8sDZlAzuMLVn0rzclkHB(r6YkkN9gziWnSt3F0kIAWTBIOgCleOJYewucmo(HX7MticifCXWuXGlgQ3CcQjyRG6EEEZBTqTa2ryObK803WoDrudU98IyOEp38LGOJq)AEZQRuqElhhoIGBDMyFksumUqmo(mo(moeIbsbcGUBDiQztLEDID96SaJhAOmoDafkUcKXiA1hk6u2rLUbcyC8yCHyC6akuCdiANyzDvUaXrQ1nqaJleJ3b6akuCxujBwzfCvjQwGXXbgxdyCHyCnY40buO4o0rzclkLdXnqaJJ3nVOLrzw(Mss6lYXOqkDkbB5B(r6YkkN9gziWnSt3F0kIAWTBIOgCZKK(ICmkujxX4LiylFZjebKcUyyQyWfd1Bob1eSvqDppV5TwOwa7im0asE6ByNUiQb3EErmyUNB(sq0rOFnVz1vkiVrhqHIBbzmkjo0BOQwjbCdeW4cX44Z4AKXHqmqkqa0DlmXuUiLobkszciD9IYyKXdnughvtPWGoqGMeumUp4aJhMXX7Mx0YOmlFJYoQuvlNAHB(r6YkkN9gziWnSt3F0kIAWTBIOgCRe7OsvTCQfU5eIasbxmmvm4IH6nNGAc2kOUNN38wlulGDegAajp9nStxe1GBpViMW3ZnFji6i0VM3S6kfK32aISQlykcRBnyxGKmUp4aJJl1BErlJYS8nk7OsDvUYcWn)iDzfLZEJme4g2P7pAfrn42nrudUvIDujJB5klamo(HX7MticifCXWuXGlgQ3CcQjyRG6EEEZBTqTa2ryObK803WoDrudU98Iyk19CZxcIoc9R5nRUsb5nunLcd6abAsqX4(GdmE4BErlJYS8TfAZQGiOu6fLKe2B(r6YkkN9gziWnSt3F0kIAWTBIOgCZj0MvbrqPy8qwssyzC8dJ3nNqeqk4IHPIbxmuV5eutWwb1988M3AHAbSJWqdi5PVHD6IOgC75fXGZ75MVeeDe6xZBwDLcYB4Z41zI9PiXDH2SkickLErjjH1DHgssumEPzC8zCh1oJJJy8WmoEmEOHY40buO46aLAHvsCORYzBUQevlW44aJJHkJJhJleJxNj2NIex6fqPw9HIUss6lYXOqUl0qsIIX9HX3acOCtzd0ZrhNmUqmEIIajDDGsTWkjo0v5SnxGGOJq)Mx0YOmlFJYoQuxLRSaCZpsxwr5S3idbUHD6(JwrudUDte1GBLyhvY4wUYcaJJFPW7MticifCXWuXGlgQ3CcQjyRG6EEEZBTqTa2ryObK803WoDrudU98Iy0G75MVeeDe6xZBwDLcYBAKXPdOqXDLnWnqaJleJJpJRrgprrGKUoqPwyLeh6QC2Mlqq0rOZ4HgkJxNj2NIe3fAZQGiOu6fLKew3fAijrX4(W44Z4oQDghpghVBErlJYS8THoktyrjCZpsxwr5S3idbUHD6(JwrudUDte1GBHaDuMWIsGXXVu4DZjebKcUyyQyWfd1Bob1eSvqDppV5TwOwa7im0asE6ByNUiQb3EErmH09CZxcIoc9R5nRUsb5T6mX(uK4sVak1Qpu0vssFrogfYDHgssumUpmognGXfIX3aISQlykcRBnyxGKmEPXbghxQmUqm(gqaLBkBGEo6LIX9HXDu738IwgLz5BANLOpu0lkjjS38J0Lvuo7nYqGByNU)Ove1GB3ern4goEwcJpuy8qwssyV5eIasbxmmvm4IH6nNGAc2kOUNN38wlulGDegAajp9nStxe1GBpVigCVNB(sq0rOFnVz1vkiVvNj2NIex6fqPw9HIUss6lYXOqUl0qsIIX9HX3acOCtzd0ZrhN38IwgLz5Bu2rL6QCLfGB(r6YkkN9gziWnSt3F0kIAWTBIOgCRe7Osg3YvwayC8XjE3CcraPGlgMkgCXq9MtqnbBfu3ZZBERfQfWocdnGKN(g2PlIAWTNpVz1vkiV98h]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170717.002219, [[deeBraqiQKSjkvFIePyuKGtrcnluKk7IOggkCmuLLrP8mrPMgjsUgjITrIu9nsuJdfPCoQe16irknpue3tuv7JIYbfLSqQuEivQMiksvxuuXgPsOrIIKtkQYnjIDsj)Kkbwkf5PctvuSvrL(kvsTxK)cXGv5WewmfESsMmkDzWMvkFMkgnr60K61OQA2q62OYUL8BfdNKoovISCPEUithQRtvBNIQVRuDEuvwpvcA(OO2VQM4rzOiuHLwGQDHcSEkYYMs4rrSATkMcky6HnHhftUrHjafejGSSXGNYmu62ukzBzBZLzW0OWeiy5lJMdOO9LEHOo7qlVjqrti4bXMlZ09NHFBtwQVCGwxoiTVaKDqOoLCdCcDLOiRfwpvIYqw8OmuKtjmqbwYnkIvRvXuOWFTV0le1zhA5LVBOW)zw()LnJ)yM5)m8BBYs9Ld06YbP9fGSdc1PK9Q)P4F2)tH)u4pd)2MCR5azV6F2)dCjVwvfyLvHobMdTOwaYSHGLciGXuiCIgZx)NI)XmZ)PWFybkuyzhbwk06YbjHNMtgkHbkW(N9)u4p2bl3a30jafsjKDDHHwUboHUs)XK8)ZzX(hZm)NR(JDWYnWnDcqHuczxxyOLX6f)6Y5pf)tX)uKISm0OAmFu0a30jafsjKDDHHMI8kw9sGNMIAkGcjdBUI2sWbuqHLGdOWeWnDcqHu6pxRlm0uycqbrcilBm4PmpguycsJVxqIYqykCxkS4xYyoWbfMmOqYWAj4akimzzJYqroLWafyj3OiwTwftHc)PWFTV0le1zhA5LVBOW)zw()zJXF2)lbyeJP8jzSgAEUmIsPU(ZS)y8NI)XmZ)1(sVquNDOLx(UHc)Nz5)x2m(JzM)ZWVTjl1xoqRlhK2xaYoiuNs2R(NI)z)pd)2MCR5azVkfzzOr1y(Oq6SJQlhedurctrEfREjWttrnfqHKHnxrBj4akOWsWbuWuZoQUC(ZnurctHjafejGSSXGNY8yqHjin(EbjkdHPWDPWIFjJ5ahuyYGcjdRLGdOGWKv2ugkYPegOal5gfXQ1QyksagXykFsgRH2gdeBQR)m7pg)z)V2x6fI6SdT8Y3nu4)m7pMMs(Z(FTVG)ys()L9F2)ZWVTjRQrrfnYSHS1tcl7vPildnQgZhfB9KWijCR5hOiVIvVe4PPOMcOqYWMROTeCafuyj4akCXEs4)cCR5hOWeGcIeqw2yWtzEmOWeKgFVGeLHWu4UuyXVKXCGdkmzqHKH1sWbuqyYsPOmuKtjmqbwYnkIvRvXu0(sVquNDOLx(UHc)htY)pLsj)XmZ)1(csYynhGGheL8ht(ZzX(hZm)NHFBtwQVCGwxoiTVaKDqOoLCdCcDL(ZS8)ZgfzzOr1y(Oymq1yOfyGI8kw9sGNMIAkGcjdBUI2sWbuqHLGdOWfyGQXqlWafMauqKaYYgdEkZJbfMG047fKOmeMc3Lcl(LmMdCqHjdkKmSwcoGcctwkHYqroLWafyj3OiwTwftbECCqb51mOSZEL(Z(Fk8x7l9crD2HwE57gk8Fm5pLz8N9)C1Fg(TnzP(YbAD5G0(cq2bH6uYE1)S)x7l4pM8NT)S)3Agu2zVKnAqGLImBijDX2cNjjKBGtOR0FM9x2k5p7)bUKxRQcSYRPmhAhOwaYSHSjWq6pfPildnQgZhfs9Ld06YbP9fGSdc1POiVIvVe4PPOMcOqYWMROTeCafuyj4akykF5aTUC(ZKVG)CniuNIctakisazzJbpL5XGctqA89csugctH7sHf)sgZboOWKbfsgwlbhqbHjlLoLHICkHbkWsUrrSATkMc844GcYRzqzN9k9N9)u4V2x6fI6SdT8Y3nu4)yYFkHXF2)Zv)z432KL6lhO1Lds7lazheQtj7v)Z(FTVGKmwZbi4bX2FML)Fz)N9)wZGYo7LSrdcSuKzdjPl2w4mjHCdCcDL(ZS)YMXFksrwgAunMpkK6lhO1Lds7lazheQtrrEfREjWttrnfqHKHnxrBj4akOWsWbuWu(YbAD58NjFb)5AqOo1FkWtrkmbOGibKLng8uMhdkmbPX3lirzimfUlfw8lzmh4GctguizyTeCafeMSuMYqroLWafyj3OiwTwftbECCqb51mOSZEL(Z(Fk8x7l9crD2HwE57gk8Fm5VSvYF2)Zv)z432KL6lhO1Lds7lazheQtj7v)Z(FTVGKmwZbi4bX2FML)F2(Z(FRzqzN9s2ObbwkYSHK0fBlCMKqUboHUs)z2FzZ4pfPildnQgZhfs9Ld06YbP9fGSdc1POiVIvVe4PPOMcOqYWMROTeCafuyj4akykF5aTUC(ZKVG)CniuN6pfSPifMauqKaYYgdEkZJbfMG047fKOmeMc3Lcl(LmMdCqHjdkKmSwcoGcctwmnkdf5ucduGLCJIy1Avmf4XXbfKxZGYo7v6p7)PWFTV0le1zhA5LVBOW)XK)SX4p7)5Q)m8BBYs9Ld06YbP9fGSdc1PK9Q)z)V2xqsgR5ae8Gy7pZY)pE)z)V1mOSZEjB0Galfz2qs6ITfotsi3aNqxP)m7VSz8NIuKLHgvJ5JcP(YbAD5G0(cq2bH6uuKxXQxc80uutbuizyZv0wcoGckSeCafmLVCGwxo)zYxWFUgeQt9NczRifMauqKaYYgdEkZJbfMG047fKOmeMc3Lcl(LmMdCqHjdkKmSwcoGcctwUmLHICkHbkWsUrrSATkMc844GcYRzqzN9k9N9)u4pf(dCjVwvfyLxtLMgNqwdklYAA4pMz(pd)2MSQgfv0iZgYwpjSSx9pf)Z(Fg(TnzFjDq5djHBOCWsL9Q)z)pwWWVTj3cx406fiNWIf))L)Fk5p7)5Q)m8BBYJbQgdTaRNs2R(NIuKLHgvJ5JIKUyBHZKejKnFZhf5vS6Lapnf1uafsg2CfTLGdOGclbhqrOl2w4mjHst6px038rHjafejGSSXGNY8yqHjin(EbjkdHPWDPWIFjJ5ahuyYGcjdRLGdOGWKfpgugkYPegOal5gfXQ1Qykm8BBY8Rrr1LdcNyjvxGSx9p7)PWFU6pWL8AvvGvM)bfRBrcPG9TXxSi7Au0)yM5)WcuOWYocSuO1LdscpnNmucduG9pMz(pXcRnhqGc40q6pZY)pB)PifzzOr1y(OyRNeoT4dlfOiVIvVe4PPOMcOqYWMROTeCafuyj4akCXEs40IpSuGctakisazzJbpL5XGctqA89csugctH7sHf)sgZboOWKbfsgwlbhqbHjlE8OmuKtjmqbwYnkIvRvXuiwyT5acuaNgs)zw()zJISm0OAmFu0a30jafsjKDDHHMI8kw9sGNMIAkGcjdBUI2sWbuqHLGdOWeWnDcqHu6pxRlm0)PapfPWeGcIeqw2yWtzEmOWeKgFVGeLHWu4UuyXVKXCGdkmzqHKH1sWbuqyYINnkdf5ucduGLCJIy1AvmfTV0le1zhA5LVBOW)XK8)tzL8hZm)x7l4pZ(lBkYYqJQX8rXyGQXqlWaf5vS6Lapnf1uafsg2CfTLGdOGclbhqHlWavJHwGH)uGNIuycqbrcilBm4PmpguycsJVxqIYqykCxkS4xYyoWbfMmOqYWAj4akimzXlBkdf5ucduGLCJIy1AvmfTV0le1zhA5LVBOW)XK)uMXF2)Zv)z432KL6lhO1Lds7lazheQtj7v)Z(FTVGKmwZbi4bj7)m7pNflfzzOr1y(Oq60fYSHSRlm0uKxXQxc80uutbuizyZv0wcoGckSeCafm101FZ2FUwxyOPWeGcIeqw2yWtzEmOWeKgFVGeLHWu4UuyXVKXCGdkmzqHKH1sWbuqyYINsrzOiNsyGcSKBueRwRIPapooOG8Agu2zVs)z)pf(R9LEHOo7qlV8Ddf(pM8Nng)PifzzOr1y(Oa4uNDOrAFbi7GqDkkYRy1lbEAkQPakKmS5kAlbhqbfwcoGIC4uNDO)ZKVG)CniuNIctakisazzJbpL5XGctqA89csugctH7sHf)sgZboOWKbfsgwlbhqbHjmfwcoGIqZ5(FUypjSs7Fgt6pSEXVUCimra]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170717.002219, [[dKdCdaGEKs1Miq7IiBdPG9jQA2iz(eu3ePk3Ms2jrTxODRQ9lLrranmk63kDAGblvdxfDqcYPqQ4yQW5qk0cbPLIilMsTCjpwLEkPLrvEovMisjMkfAYGA6cxKQshwXLrDDe2ivv2kvvTze15fLMgsrMfsL(mf8Dc13iK1rvXObXZiaNuu5VICnKs6EIIXHuuhcPuEnsvnEGgrvp5lyOa0(eG9rzpA9av9wGZavuLhlg1C(36(vRlADOR6tRdZKhcQavsmfpogL9mpezsdE0KKNa8OrtAgvs8aN1iWIrTiEWnDUI5skawCk2Kit626fXZoPayXPytEOk0na77qJO8bAevF)XMIHrOOkKnGcezr1U4jGKwYjh4HRXW6gu1BbodulIhCtNRyUKUevXF065Z06ImBDbB9I45wpFMw3d1Cpm4oXwO(7ZOsIP4XXOSN5HOdtujXdCwJalg1I4b305kMlPayXPytImPBRxep7KcGfNIn5HQyi8tIh4SO6Uf4mqvESyuHw8eqA9LCRRGhUgdRBWaL9qJO67p2ummcfv5XIrLeX36qlEciOQ3cCgOcVHKDXtajTKtoWdxJH1nsb4sFWBqyHf4Dxk4v8lzx8eqsl5Kd8W1yyDJuXwd4DzmfSiEWnDUI5s6suf)r(mImfuGfXZ5Z4jSW2eKjlvS1woMIDUKyWhCjrCkyr8C(mh0HoOsIP4XXOSN5HOdtuZ9WG7eBH6VpJQq2akqKf1I4tZna7NOaUav6TWYJfJAo)BD)Q1fTo0v9P1TlEciyGYcanIQV)ytXWiuuLhlgvseFRlVTo0INacQ6TaNbQ0g8gs2fpbK0so5apCngw3ifGl9bVbujXu84yu2Z8q0HjQ5EyWDITq93NrviBafiYIAr8P5gG9tuaxGk9wy5XIrnN)TUF16Iwh6Q(06)262fpbemWavAHjpeubcfdeba]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170717.002219, [[dCZMeaGErG2KiLDPu2MiO9js1SP42Qs7eI9kTBQ2Vs1pPevdJe)gQHkcyWQkdNGdQK60kogP6CuI0cjQwQQyXK0YfESOEkQLPQ65qAIerzQeLjtktxLlQKCyGlJCDq2OiKTsjInReNNs67uQVck6ZeP5bkmsIiFdunArYZaLoPiACer11OeUhryAIq9xcTokr5QxzLzbkpaZKGGBWEr(TqVmNJr4kxgb8sLtAj7FjkWO3(NCmBz7FQbbUuLFidbqPI8ROdxjH)jE7h2FlvrYl)qanRYMxQCa5twuaBtX2cWyqfpSiSkLxNVb7Ovwr0RSYRCGQH0Q8YCogHRC5hYqauQi)k6W1vkN01Mm4Wrzh7u51QJzoRLd6fhOKHqrfTh)OOmc4Lk)qV4aLmek6(hmh)OOxr(RSYRCGQH0Q8YCogHRC5hYqauQi)k6W1vkN01Mm4Wrzh7u51QJzoRLfgJbeI4fXLaJELraVu5eymgqS)Hx2)suGrVEfb2kR8khOAiTkVmc4LklpiWLA)dVS)XJRfaPyuq5hYqauQi)k6W1vkN01Mm4Wrzh7uzohJWvoGCkDj0tlG8jlkGTPyldfb5x6saxPxrsCLvELdunKwLxMZXiCLvHww2I5L2GestfAzzlfKlLIXLkgqojAtabSVPHT90ciFYIcyBk2Yqrq(LUeWAr5hYqauQi)k6W1vkN01Mm4Wrzh7u51QJzoRLtHTnJlvu1aqVYiGxQSKW2MXLU)j3aqVEfXIkR8khOAiTkVmNJr4khq(KffW2uSLHIG8dgsa3IYpKHaOur(v0HRRuoPRnzWHJYo2PYRvhZCwlJvnZrb4OYiGxQSLRAMJcWr9kscRSYRCGQH0Q8YCogHRCa5twuaBtXwgkcYpyibClstfAzzlfKlLIXLkgqojAtabSVPHT9YpKHaOur(v0HRRuoPRnzWHJYo2PYRvhZCwlNchUiEr0E8JIYiGxQSKWHV)Hx2)G54hf9kc8kR8khOAiTkV8dziakvKFfD46kLraVuzjb5sPyCP7FpqoT)btciG9YjDTjdoCu2XovET6yMZA5uqUukgxQya5KOnbeWE5hcOzv28sLdiFYIcyBk2wagdQ4HfHvPSDkYFiGM1YO5yeUYCogHRCa5twuaBtXwgkcYpyibSk96vwYOfaK5Q8ETa]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170717.002219, [[dKddeaGErG2fs12ePyFkjMnrhwv3wu9ncStLAVu7wX(Lk)uKQggH(nWZj15LcdwjgoioOi6uIGogsohIswiiTuKYIb1Yv50sEk0YKQwhbLMibvMkj1KjX0fUOO4XiCzuxhr1gLISveLAZiY2jOQPjc5RIu6ZIsFNKmsefJteWOvs9mrOoPi5qeuCnPOUNssVMG8xP0OePYMYQnU)C2ykYUBPPdOJUfOauy7wgq3c8XFS2OWXKEYLHHAKgl5xZE3lsjqmn9jIEFI7jlXeWisCfKWOXKerbgTv7nLvBmZ8WswXqnIexbjmAKgl5xZE3lsjGs0yQrPi(aCghWWgtcxYkAy84CWPzjR1TQQj4Z4(ZzJ04CWPzjR1DlPTMGphE3B1gZmpSKvmuJiXvqcJcJciOt6a6OLel88rpkcHQjRrASKFn7DViLakrJPgLI4dWzCadBmjCjROHX1avYAY2clFDyC)5SrYaujRjB3cu5RdhENyR2yM5HLSIHAejUcsy8iFkIwiav8rNG874jwzvbIgPXs(1S39IucOenMAukIpaNXbmSXKWLSIggjDaD0QJReInU)C2ythqhDlyCLqSdVtKvBmZ8WswXqnIexbjmctojs0VkNPtoeJ0yj)A27ErkbuIgtnkfXhGZ4ag2ys4swrdJRbQK1KTfw(6W4(ZzJKbOswt2UfOYxhDlPJwLZj0H3nB1gZmpSKvmuJiXvqcJgPXs(1S39IucOenMAukIpaNXbmSXKWLSIggbWYk47d24(ZzJPhwwbFFWo8onwTXmZdlzfd1isCfKWibaivaQg6Wh)X6waPwDnk3NfOF6hN)1OxzvQMnsJL8RzV7fPeqjAm1OueFaoJdyyJjHlzfnms6a6OvhxjeBC)5SXMoGo6wW4kH4UL0rLqhElWQnMzEyjRyOgrIRGegjaaPcq1qh(4pw3ci1QRr5(Sa9t)48Vg9kRsjAKgl5xZE3lsjGs0yQrPi(aCghWWgtcxYkAyCn4MwaPwv1e8zC)5SrYaUPBbqQBjT1e85WHrectuVSsWpkW4DFZuoSb]] )


    storeDefault( [[Frost Primary]], 'displays', 20170624.232908, [[d0d4gaGEvKxcvLDrPO2MkkzMsQ8yumBfDCur3eQQMMKQUTk8nkv1oPQ9k2nr7Ne(PcnmvY4urfNMudfPgmQ0Wr4GsYZjCmQ4CQOQfkrlLsPftslNIhsL6PGLrLSokfzIQOyQqzYKOPR0fvWvPu4YqUos2Ok1wvrL2mQA7iQpkP4zOc9zOY3LWirfCyPgnknEOkNerUfLQCnkvopL8BvTwvuQxlP0XjybyAIv)Y7xUWAnrbgTbwDK8dbyAIv)Y7xUG(ekEhxbmTehYnlIP2ugqDQpDQM5xKYawJ88c06Ujw9lfXFfaVrEEbAD3eR(LI4VcWjfIcPKeZlb9ju81Ff4qlRgINJb4KcrHu6Ujw9lfPmG1ipVaTyTbhAfXFfqW(fqHEzyRgszab7xurTFkdOzEjq0mAjU4TlW2gCOTsYW(MaLJyyJ43ws1WbSaw52ENZ5TVRlh7Q35825IJx2)k82RE7cynYZlql(kfXBpNac2VaRn4qRiLbQvTsYW(MayJ02sQgoGfqlvQz69nvsg23eWws1WbSamnXQFzLKH9nbkhXWgXFaGaXO7P(uV6xgVl7Cciy)calLb4KcrHoJ2Gyw9ldylPA4awaj1bjMxkIV(acc0CEpBbR7F(MGfOJ3jGjENa4I3jGA8ozdiy)c3nXQFPiQbWBKNxG2kkth)vGMY0yweOaQu88boA8QO2p(RaQt9Pt1m)IQ5mQb6jbBdSFbn5H4Dc0tc229FO2ln5H4DcCgeFtn3ugONfTLGMmDkdqwl0Q6PETWSiqbudW0eR(Lvtnoza3dESbBdOuliMTfMfbkqhW0sCimlcuGwvp1RvGMY04xlrPmqTQ3VCb9ju8oUc0tc2gRn4qlnz64DcyqZaUh8yd2gqqGMZ7zlyJAGEsW2yTbhAPjpeVtaoPquiLKKk1m9(grkd4(jSuWf7dCBEXQGB14qGdTSIA)4VcSTbhAVF5cR1efy0gy1rYpeqjIVPMBfDDba9HBfCVnVyTjfCvI4BQ5gaV4Vciy)cOqVmSvu7NYa9KGTRMfTLGMmD8ob0mV8S))iEh7cqy0hTX6(LlOpHI3XvacdI5pu7TIUUaG(WTcU3MxS2KcUegeZFO2Ba(xUbOXuWfAPqbxFBmFrGJgVQH4Vcqy0hTXIeZlb9ju81FfyBdo0stEiQb4KcrHQMACYdKCdWeqW(f0KPtza8g55fOLKuPMP33iI)kG1ipVaTKKk1m9(gr8xb22GdT3VCdqJPGl0sHcU(2y(Ia4nYZlqlwBWHwr8xbeSFrfLPjj5)OgqW(fKKk1m9(grkdynYZlqBfLPJ)kqplAlbn5HugqW(f0Khszab7xunKYam)HAV0KPJAGMY0abAojDM4Vc0uMUsYW(MaLJyyJ4VUHBSanLPjj5FmlcuavkE(ahAjGf)vGTn4q79lxqFcfVJRaCsPzQ9C1cyTMOaDaMMy1V8(LBaAmfCHwkuW13gZxeONeST7)qTxAY0X7eyq2QtKYugqOpiMOQXH4DfOw17xUbOXuWfAPqbxFBmFrGEsW2vZI2sqtEiENam)HAV0KhIAGTn4qlnz6OgqW(f4dzPQLk1sCIugWw0e1cu8UUCS)1z5QEB2fhDSZfhdC04byX7eaVrEEbAXxPiENa9KGTb2VGMmD8ob4KcrHuE)Yf0NqX74kqTQ3VCH1AIcmAdS6i5hcWjfIcPeFLIugW3hOa3MxSk4sB0hTXkqtzABi1BaIzBHmzta]] )

    storeDefault( [[Frost AOE]], 'displays', 20170624.232908, [[dSJYgaGEPuVejXUuufVwkPzkLy2kCteupgPUTQyBkQu7Ks7vSBI2pb(Pu1WuL(TktdbzOOYGjOHdvhKk9Csogv1XrvSqfzPOkTyuA5u8qPWtbltrzDkQQjkfPPQQMmQQPR0fLkxfjLld56iAJqPTQOs2mH2os8rPOonP(mu8DQYirs6zkQy0Oy8iWjrOBjfHRHKQZtfhwYALIOVPOkD8ZpaDHV6tI9KlSoduGEQ9BHOTlaDHV6tI9KlOBJI1FwatjXGAWGOBntb4HerIChAmYhKCdqhWPxuuH2gf(QpPk23ae0lkQqBJcF1Nuf7BaCJ(PmoePpjOBJILqVbE0s3UyNtaEirKi(nk8vFsvMc40lkQq7VmyqRk23akMZd80lnJBxydOyopxY9cBafZ5bE6LMXLCVmfyldg06kPzotGP()VNW8sSzQ(d4eBtmZ)nabX(gqXCE)YGbTQmfOvwxjnZzc8754LyZu9hql5RPR9mUsAMZeGxInt1Fa6cF1N0vsZCMat9)FpHda4iADn0TRvFYyNrD)akMZd(zkapKisut1ge9QpzaEj2mv)bKKpePpPkwcfqHJgdSJsX04gNj)avS(byJ1paMy9dyI1pBafZ51OWx9jvHnab9IIk06sAQyFduKM67GJcWskkg4PiWLCVyFdWo0TB3848ChJWgOg4mfWCECu6I1pqnWzQg3dBTCu6I1pqtrIf5yZuGA4vokokCzkafTsZQh6157GJcWgGUWx9jDhAmYan6S)oEdWxRWhLZ3bhfGoGPKyqFhCuGIvp0RtGI0uewlrzkqRSyp5c62Oy9NfOg4m1VmyqlhfUy9dyqJan6S)oEdOWrJb2rPycBGAGZu)YGbTCu6I1papKiseFIs(A6ApJktbAC4oce(VaynNAfi0TVlGTEqbWAo1kqOBFxGTmyql2tUW6mqb6P2VfI2Ua8rIf5yD5AjaOFAiqiwZP25lqiFKyro2aTYI9KlSoduGEQ9BHOTlGM(KaErRLyIL6bQbot5o8khfhfUy9dudCMcyopokCX6ha3OFkJd2tUGUnkw)zbWni67HTwxUwca6NgceI1CQD(ceIBq03dBTbiOxuuHwQmPI1pWtrGBxSVbEkcGFS(b2YGbTCu6cBaErduPqXo71FEFN7zeAEMnhFQpBobumNhhfUmfqXCEub5WQL81smQmfyldg0YrHlSbOVh2A5O0f2a1aNPChELJIJsxS(bALf7j3aCFbcHsQei0wgZ5fqXCEeL8101EgvMc40lkQqRlPPI9nqn8khfhLUmfqXCEUDHnGI584O0LPa03dBTCu4cBGAGZunUh2A5OWfRFGI0uUsAMZeyQ))7jClDy)b4Hut36CPvW6mqbyd8OLWp23aBzWGwSNCbDBuS(ZcuKMIOu8(o4OaSKIIbOl8vFsSNCdW9fiekPsGqBzmNxGI0uaoAmi20yFd0jl2bIFMcO0p4dKBFxSZcOyopxstrukEHnab9IIk0(ldg0QI9nWwgmOf7j3aCFbcHsQei0wgZ5fWPxuuHwIs(A6ApJk23ae0lkQqlrjFnDTNrf7Ba2HUD7MhNxMcWdjIeXNi9jbDBuSe6nG4j3aCFbcHsQei0wgZ5fqtFYM8UNy9PEaEirKi(yp5c62Oy9NfWPxuuHwQmPITj8dWdjIeXNktQmf4rlDj3l23afPPOMuVbWhLdYKnba]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )



end

