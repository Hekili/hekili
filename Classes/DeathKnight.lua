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

local setRechecks = ns.setRechecks

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault

local PTR = ns.PTR or false


local tinsert, tsort, twipe = table.insert, table.sort, table.wipe


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEATHKNIGHT') then

    ns.initializeClassModule = function ()

        setClass( "DEATHKNIGHT" )

        -- Resources
        addResource( "runic_power", SPELL_POWER_RUNIC_POWER, true )
        addResource( "runes", SPELL_POWER_RUNES, true )

        setRegenModel( {
            frost_mh = {
                resource    = 'runic_power',
                spec        = 'frost',
                talent      = 'runic_attenuation',
                setting     = 'forecast_swings',

                last = function ()
                    local t = state.query_time - state.swings.mainhand
                    t = floor( t / state.swings.mainhand_speed )

                    return state.swings.mainhand + ( t * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',
                value = 1
            },

            frost_oh = {
                resource    = 'runic_power',
                spec        = 'frost',
                talent      = 'runic_attenuation',
                setting     = 'forecast_swings',

                last = function ()
                    local t = state.query_time - state.swings.offhand
                    t = ceil( t / state.swings.offhand_speed )

                    return state.swings.offhand + ( t * state.swings.offhand_speed )
                end,
                interval = 'offhand_speed',
                value = 1
            },

            breath = {
                resource    = 'runic_power',
                spec        = 'frost',
                aura        = 'breath_of_sindragosa',
                setting     = 'forecast_breath',

                last = function ()
                    return state.buff.breath_of_sindragosa.applied + floor( state.query_time - state.buff.breath_of_sindragosa.applied )
                end,

                stop = function ( x ) return x < 15 end,

                interval = 1,
                value = -15
            },

            hungering_rp = {
                resource    = 'runic_power',
                spec        = 'frost',
                talent      = 'hungering_rune_weapon',
                aura        = 'hungering_rune_weapon',

                last = function ()
                    return state.buff.hungering_rune_weapon.applied + floor( state.query_time - state.buff.hungering_rune_weapon.applied )
                end,

                interval = 1.5,
                value = 5
            },

            hungering_rune = {
                resource    = 'runes',
                spec        = 'frost',
                talent      = 'hungering_rune_weapon',
                aura        = 'hungering_rune_weapon',

                last = function ()
                    return state.buff.hungering_rune_weapon.applied + floor( state.query_time - state.buff.hungering_rune_weapon.applied )
                end,

                fire = function ( time, val )
                    local r = state.runes

                    r.expiry[6] = 0
                    table.sort( r.expiry )
                end,

                stop = function ( x )
                    return x == 6
                end,

                interval = 1.5,
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
                    return x == 6
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
                        t.expiry[ 7 - i ] = 0
                    end
                    table.sort( t.expiry )

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
                        -- If this is a modeled resource, use our lookup system.
                        if t.forecast and t.fcount > 0 then
                            local q = state.query_time
                            local index, slice

                            if t.values[ q ] then return t.values[ q ] end

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
                                t.values[ q ] = max( 0, min( t.max, slice.v ) )
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

                local spendMod = state.spec.unholy and ( 1 + ( state.artifact.runic_tattoos.rank * 0.0333 ) ) or 1

                state.gain( amount * 10 * spendMod, 'runic_power' )

                if state.spec.frost and state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                    state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
                    if state.buff.gathering_storm.down then
                        state.applyBuff( "gathering_storm", state.buff.remorseless_winter.remains, amount )
                    else
                        state.buff.gathering_storm.expires = state.buff.remorseless_winter.expires
                        state.buff.gathering_storm.count = state.buff.gathering_storm.count + amount
                    end
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

            state.pet.valkyr_battlemaiden.expires = state.last_valkyr > 0 and state.last_valkyr + 20 or 0
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
            if state.spec.frost then
                -- class.NoGCD = true
            else
                class.NoGCD = nil
            end
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

        addTalent( "inexorable_assault", 253593 ) 
        addAura( "inexorable_assault", 253595, "duration", 10, "max_stack", 10 )

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
        addAura( "dark_succor", 101568, "duration", 20 )
        addAura( "death_and_decay", 188290, "duration", 10 )
        addAura( "defile", 156004, "duration", 10 )
        addAura( "defile_buff", 218100, "duration", 5, "max_stack", 10 )
        addAura( "festering_wound", 194310, "duration", 24, "max_stack", 8 )
        addAura( "frost_fever", 55095, "duration", 24 )
        addAura( "gathering_storm", 211805, "duration", 8, "max_stack", 20 )
        addAura( "hungering_rune_weapon", 207127, "duration", 12 )
        addAura( "icebound_fortitude", 48792, "duration", 8 )
        addAura( "icy_talons", 194879, "duration", 6, "max_stack", 3 )
        addAura( "killing_machine", 51124, "duration", 10 )
        addAura( "master_of_ghouls", 246995, "duration", 3 )
        addAura( "mastery_dreadblade", 77515 )
        addAura( "mastery_frozen_heart", 77514 )
        addAura( "necrosis", 207346, "duration", 30 )
        addAura( "on_a_pale_horse", 51986 )
        addAura( "obliteration", 207256, "duration", 10 )
        addAura( "outbreak", 196782, "duration", 6, "tick_time", 1.5 )
        addAura( "path_of_frost", 3714, "duration", 600 )
        addAura( "perseverance_of_the_ebon_martyr", 216059 )
        addAura( "pillar_of_frost", 51271, "duration", 20 )
        addAura( "razorice", 51714, "duration", 15, "max_stack", 5 )
        addAura( "remorseless_winter", 196770, "duration", 8, "friendly", true )
        addAura( "rime", 59052, "duration", 15 )
        addAura( "runic_corruption", 51462 )
        addAura( "runic_empowerment", 81229 )
        addAura( "soul_reaper", 130736, "duration", 5 )
        addAura( "sudden_doom", 81340, "duration", 10, "max_stack", 1 )
            modifyAura( "sudden_doom", "max_stack", function( x ) return x + ( artifact.sudden_doom.enabled and 1 or 0 ) end )
        addAura( "temptation", 234143, "duration", 30 )
        addAura( "unholy_frenzy", 207290, "duration", 2.5 )
        addAura( "unholy_strength", 53365, "duration", 15 )
        addAura( "virulent_plague", 191587, "duration", 21, "tick_time", 3 )
            modifyAura( "virulent_plague", "duration", function( x )
                if talent.ebon_fever.enabled then return x / 2 end
                return x
            end )
            modifyAura( "virulent_plague", "tick_time", function( x )
                if talent.ebon_fever.enabled then return x / 2 end
                return x 
            end )
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
        addGearSet( "tier21", 152115, 152117, 152113, 152112, 152114, 152116 )

        addGearSet( "acherus_drapes", 132376 )
        addGearSet( "aggramars_stride", 132443 )
        addGearSet( "cold_heart", 151796 ) -- chilled_heart stacks NYI
            addAura( "cold_heart", 235599, "duration", 3600, "max_stack", 20 )

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


        --[[ addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and your Artifact Ability will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } ) ]]

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


        ns.addSetting( 'unholy_use_rocf', true, {
            name = 'Unholy: Use Ring of Collapsing Futures',
            type = 'toggle',
            desc = "If checked, the addon will consider Ring of "
            })

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
            known  = function () return equipped.apocalypse end,
            toggle = 'artifact'
        } )

        addHandler( "apocalypse", function ()
            if debuff.festering_wound.stack > 6 then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 6 )
            else
                removeDebuff( "target", "festering_wound" )
            end
            gain( 18, "runic_power" ) 
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
            recheck = function ()
                return buff.pillar_of_frost.remains - gcd, buff.pillar_of_frost.remains, buff.unholy_strength.remains - gcd, buff.unholy_strength.remains, buff.master_of_ghouls.remains - gcd, buff.master_of_ghouls.remains
            end,
        } )

        addHandler( "chains_of_ice", function ()
            applyDebuff( "target", "chains_of_ice", 8 )
            if equipped.cold_heart then removeBuff( "cold_heart" ) end
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
            recheck = function () return gcd * 0.1, gcd * 0.2, gcd * 0.3, gcd * 0.4, gcd * 0.5, gcd * 0.6, gcd * 0.7, gcd * 0.8, gcd * 0.9, gcd end,
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
            recheck = function () return buff.icy_talons.remains - gcd, buff.icy_talons.remains end
        } )

        addHandler( "frost_strike", function ()
            if talent.shattering_strikes.enabled and debuff.razorice.stack >= 5 then
                applyDebuff( "target", "razorice", 20, 1 )

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
            cooldown = 45,
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

            if buff.obliteration.up then
                applyBuff( "killing_machine" )
            end

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
            applyBuff( "hungering_rune_weapon", 12 )
            stat.spell_haste = ( ( 1 + stat.spell_haste ) * 1.2 ) - 1
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
            toggle = "cooldowns",
            recheck = function () return buff.pillar_of_frost.remains - 12, buff.pillar_of_frost.remains end,
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
            recheck = function () return dot.virulent_plague.remains - gcd, dot.virulent_plague.remains end,
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
            recheck = function ()
                return buff.remorseless_winter.remains - gcd, buff.remorseless_winter.remains
            end,
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
            known = function () return equipped.blades_of_the_fallen_prince and artifact.sindragosas_fury.enabled end,
            toggle = "artifact",
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20171128.094747, [[diuKoaqiQsAreK0Muv1OKOoLQOvrqIxrqQ2fqdteDmvLLrv1ZKi10OkX1iLQTjHW3Ok14iiLZrkfTojenpcI7rkzFuvCqcQfks6HQctucPlsvPnskfoPeQzkrsUjQYoPWpjLswQe8uHPksDvjsSvjI9I8xs1GL6WQSyu5XIAYu6YqBMI(mPy0QsNMKxJQA2s62eA3O8BqdNahNuk1Yj65uz6kDDaBxK47IW5vvz9sKuZNQy)kM(O0uezPsWsbfffnpG6sPsrbSINdjd)j)8(7ZVqdmP20VxOieGz1vvL6Bvqgz4x7(Pq48QGmhLMm(O0u4l74QOLsLIilvcwkSihGPjOdcu1L4jaLGacM()0wKdW0e0eDlkvmn6jGamliGakeMtvv7pkCziGudQ7wPIpsrXmRkFlusbdYqk4bTLCsJtePGcJtePiYqaPgC6yLk(iffWkEoKm8N8Z7VKuuaDqazgDuAAP4XlM5ZdMckISL4OGh0ACIif0sg(P0u4l74QOLsLIilvcwkSihGPjOdcu1L4jaLGacM()0wKdW0e0eDlkvmn6jGamliGakeMtvv7pkY1lHIPr39EwychffZSQ8TqjfmidPGh0wYjnorKckmorKIh1lHIPz649SWeokkGv8Ciz4p5N3FjPOa6GaYm6O00sXJxmZNhmfuezlXrbpO14erkOLmknLMcFzhxfTuQuezPsWsHeGPY6cGjqjOfnvz1oTqM2V)P)pD5P3RISf09EwycDfZeWPGmqKDCv0oThptxEAVo9EvKTG2tYx)KCQfLGi74QODApEModHvlmbd0Es(6NKtTOeuIINI5M2NP1(0pN(jfcZPQQ9hfw82x9muvPOyMvLVfkPGbzif8G2soPXjIuqHXjIuuu823PFavvkkGv8Ciz4p5N3FjPOa6GaYm6O00sXJxmZNhmfuezlXrbpO14erkOLm8cLMcFzhxfTuQuezPsWsHxNMdW0eKHzj0PCGacM()0CaMMGoaRfz6wiueeqW0)NU80LN2RtVxfzlO9K81pjNArjiYoUkAN()0sagoTq0A6sp9ZP94z6mewTWemq7j5RFso1IsqjkEkMBAFMw7t)KcH5uv1(JclE7REgQQuumZQY3cLuWGmKcEqBjN04erkOW4erkkkE770pGQ60L)EsrbSINdjd)j)8(ljffqheqMrhLMwkE8Iz(8GPGIiBjok4bTgNisbTKH2P0u4l74QOLsLIilvcwkSihGPjOj6wuQyA0tabywq3Ez(tlKPlIP)pDgcRwycg4jaMV6pboeuIINI5MwiAnDrqHWCQQA)rHj6wuQyA0DRuXhPOyMvLVfkPGbzif8G2soPXjIuqHXjIuOnq3IsftZ0Xkv8rkkGv8Ciz4p5N3FjPOa6GaYm6O00sXJxmZNhmfuezlXrbpO14erkOLmkcknf(YoUkAPuPqyovvT)OWIMQksrXmRkFlusbdYqk4bTLCsJtePGcJtePOOOPQIuuaR45qYWFYpV)ssrb0bbKz0rPPLIhVyMppykOiYwIJcEqRXjIuqlz4nLMcFzhxfTuQuezPsWsXLxvkOoYqrf6M2hTM2pfcZPQQ9hf5Rw1V8QGm9QYTuumZQY3cLuWGmKcEqBjN04erkOW4erkEC160cNxfKnDPs5wkewQXrb7erTeQHs8X0Lc7fw)vKtlS2YxHkffWkEoKm8N8Z7VKuuaDqazgDuAAP4XlM5ZdMckISL4OGh0ACIifHs8X0Lc7fw)vKtlS2YxAjdHgLMcFzhxfTuQuezPsWsr5P5amnb5QknVlA1LamupbEcGmq3Ez(tluM2)0c9PTihGPjOj6wuQyA0tabywq3Ez(t)CAHO10(N2JNPlpD5P5amnb5QknVlA1LamupbEcGmq3Ez(tluM2)0c9PTihGPjOj6wuQyA0tabywq3Ez(t)CAHO10Ez6)tVxfzly(CRsZTqjiYoUkAN(50)NU80ziSAHjyGNu8No0uFFrDlEwqjkEkMBAFMw7t7XZ0sag6axLiQVqDVmTq0AAnz70pPqyovvT)OWeDlkvmn6UvQ4JuumZQY3cLuWGmKcEqBjN04erkOW4erk0gOBrPIPz6yLk(40L)EsrbSINdjd)j)8(ljffqheqMrhLMwkE8Iz(8GPGIiBjok4bTgNisbTKH2KstHVSJRIwkvkISujyPWRtZbyAcYWSe6uoqabt)F69QiBbzywcDkhiYoUkAN()0sag6axLiQVqDVmTpAnTMSLcH5uv1(JclE7REgQQuumZQY3cLuWGmKcEqBjN04erkOW4erkkkE770pGQ60L9)KIcyfphsg(t(59xskkGoiGmJoknTu84fZ85btbfr2sCuWdAnorKcAjJVKuAk8LDCv0sPsrKLkblfLNMdW0eKHzj0PCGacM2JNP5amnbbyVW6pD3krMM9feqW0E8mTeGHt7Jwt7F6Nt)FAlYbyAcAIUfLkMg9eqaMf0TxM)0(O10Ft)F6YtBroattqt0TOuX0ONacWSGU9Y8N2hTMU0t7XZ0ED6YtVxfzly(CRsZTqjiYoUkAN2JNPrTnGsGa0cUVOUI5wjqEHsNUjeqUV6v05GSPFo9ZP)pD5PZqy1ctWapP4pDOP((I6w8SGsu8um30(mT2N2JNPLam0bUkruFH6EzAHO10AY2PFsHWCQQA)rHldbKAqD3kv8rkkMzv5BHskyqgsbpOTKtACIifuyCIifrgci1GthRuXhNU83tkkGv8Ciz4p5N3FjPOa6GaYm6O00sXJxmZNhmfuezlXrbpO14erkOLm((O0u4l74QOLsLIilvcwkkpnhGPjidZsOt5abemThptZbyAccWEH1F6UvImn7liGGP94zAjadN2hTM2)0pN()0wKdW0e0eDlkvmn6jGamlOBVm)P9rRP)M()0LN2ICaMMGMOBrPIPrpbeGzbD7L5pTpAnDPN2JNP960O2gqjqaAb3xuxXCReiVqPt3eci3x9k6Cq20pN()0LNodHvlmbd8KI)0HM67lQBXZckrXtXCt7Z0AFApEMwcWqh4Qer9fQ7LPfIwtRjBN(jfcZPQQ9hf56LqX0O7EplmHJIIzwv(wOKcgKHuWdAl5KgNisbfgNisXJ6LqX0mD8Ewyc30L)EsrbSINdjd)j)8(ljffqheqMrhLMwkE8Iz(8GPGIiBjok4bTgNisbTKXNFknf(YoUkAPuPiYsLGLIYtVxfzlO9K81pjNArjiYoUkAN()0ziSAHjyG2tYx)KCQfLGsu8um30(m9xYPFoThpt71P3RISf0Es(6NKtTOeezhxfTuimNQQ2FuyXBF1ZqvLIIzwv(wOKcgKHuWdAl5KgNisbfgNisrrXBFN(buvNUCPFsrbSINdjd)j)8(ljffqheqMrhLMwkE8Iz(8GPGIiBjok4bTgNisbT0sHXjIuekXhtxkSxy9xroTgKHsvMwIaa]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20171128.094747, [[dmu5maqiiv1IOK0Muf0OufQtPkkVcsfULQOIDPeddroMQ0YeQEgKkzAuq5AqQITrbvFJcmoiv05GuLwhfK5rjX9OKAFqQuhuiwiKYdfstuvGCrkrBKeKtscntsqDtL0or4NQIQgQQOslLe9uIPssDvsGTsj8vvbQ9k9xkAWqCyQwmk9yfnzbxgSzHYNruJMcDAOEnKmBsDBf2Tk)gPHJclhvpxPMUORtP2ok67Qc58KK1RkG5RkY(vv33QUIm5ygzLkpiiMBRZIwfLGg8nuI4KEn49no6CHe6nUHvryatSRXpGNy6vI4ON4vImtm92vDjER6kwEoRgcfTkryXACQQYaFbZyCaEaOIIxap9KYRC0dQSsdw4CcFavQq4dOYk(cFefIdWdavucAW3qjIt61GxsvucBQnFc7QUzLOgHjQvktyaxw2kR0aHpGknlr8QUILNZQHqrRIm5ygzfU9HNMmOpc4lbigEIZpc6(JeN0h5HFKh)rya5ctxJsf3K1ZuddhhGBXNjMj8rE6Ppc6)rsxdxUeCoktNZItGVaNZQHWh5zvIWI14uvfNp9dmtkNdxwrXlGNEs5vo6bvwPblCoHpGkvi8bujcF6h8rut5C4Ykkbn4BOeXj9AWlPkkHn1MpHDv3SsuJWe1kLjmGllBLvAGWhqLMLaDv1vS8CwnekAvKjhZiRWaYfMUgLkUjRNPggooa3Iptmt4J80tFe0)JKUgUCj4CuMoNfNaFboNvdHkryXACQQcRMsdMXS5QQO4fWtpP8kh9GkR0GfoNWhqLke(aQGMMsdFefYMRQIsqd(gkrCsVg8sQIsytT5tyx1nRe1imrTszcd4YYwzLgi8buPzjmSQUILNZQHqrRIm5ygzfgqUW01OuXnz9m1WWXb4w8zIzcFKNE6JG(FK01WLlbNJY05S4e4lW5SAiujclwJtvvyb(g4OWh5kkEb80tkVYrpOYknyHZj8buPcHpGkOb8nWrHpYvucAW3qjIt61GxsvucBQnFc7QUzLOgHjQvktyaxw2kR0aHpGknlb6PQRy55SAiu0QitoMrwHbKlmDnkvCtwptnmCCaUfFMyMWh5PN(iO)hjDnC5sW5OmDolob(cCoRgcvIWI14uvLyGMI1qWeFXa(5AZHpnIpOIIxap9KYRC0dQSsdw4CcFavQq4dOIcb6NZZJ1q4JO4fd4NR)iR(0i(Gkr4K3voFawhd0uSgcM4lgWpxBo8Pr8bvucAW3qjIt61GxsvucBQnFc7QUzLOgHjQvktyaxw2kR0aHpGknlHHx1vS8CwnekAvKjhZiR84pcRDSyljmyKEIP3Yo9jQpI1FesFKh(rsNtgYLepaZKAgWWhbD)rmCsFKN9rE6Pps6CYqUK4byMuZag(iw5Jy4KQeHfRXPQkC8r2KgZCs1ANXgFKnJzN2CyxrXlGNEs5vo6bvwPblCoHpGkvi8burj(i)rOX(irPATZyJpYFefYoT5WUseo5DLZhG1C8r2KgZCs1ANXgFKnJzN2CyxrjObFdLioPxdEjvrjSP28jSR6MvIAeMOwPmHbCzzRSsde(aQ0Segu1vS8CwnekAvIWI14uvf7nyItySRO4fWtpP8kh9GkR0GfoNWhqLke(aQOGn8rumHXUIsqd(gkrCsVg8sQIsytT5tyx1nRe1imrTszcd4YYwzLgi8buPzjqNvDflpNvdHIwfzYXmYkS2XITyFgPAvM7Kdh504InJkryXACQQcdAIPxffVaE6jLx5OhuzLgSW5e(aQuHWhqLNlnX0RIsqd(gkrCsVg8sQIsytT5tyx1nRe1imrTszcd4YYwzLgi8buPzjqVvDflpNvdHIwfzYXmYkbG1owSLyWobo(iB(iQ9fw2Ppr9rSI1FedRsewSgNQQWQXKnMqWKBFG5JaNb9QO4fWtpP8kh9GkR0GfoNWhqLke(aQGMgt2ycHpIs7d(ipyWzqVkkbn4BOeXj9AWlPkkHn1MpHDv3SsuJWe1kLjmGllBLvAGWhqLML4LuvxXYZz1qOOvrMCmJSYJ)ibAUWeZT1WLMm0ozByjXtuMjEaMCy44B)rqhFKeprzM4b8rSI1FKanxyI52A4stgANSnSWHHJV9h5zFKh(rc0CHjMBRHlnzODY2Wchgo(2FeRy9hH8mujclwJtvvO2jlhCuvu8c4PNuELJEqLvAWcNt4dOsfcFavEE7KLdoQkr4K3vsNtgstCmRFCGMlmXCBnCPjdTt2gws8eLzIhGjhgo(2OJeprzM4byfRd0CHjMBRHlnzODY2Wchgo(2p7HbAUWeZT1WLMm0ozByHddhFBRyn5zOIsqd(gkrCsVg8sQIsytT5tyx1nRe1imrTszcd4YYwzLgi8buPzjEFR6kwEoRgcfTkryXACQQY01AtFMy6zQX7SIIxap9KYRC0dQSsdw4CcFavQq4dOsuxR)irMjMEFefgVZkr4K3voFawBvbpI(ruWzKQvzOpYKs1b6JUTvROe0GVHseN0RbVKQOe2uB(e2vDZkrnctuRuMWaUSSvwPbcFave8i6hrbNrQwLH(itkvhOp62nlXB8QUILNZQHqrRIm5ygzfgqUW01OuXnz9m1WWXb4w8zIzcFKh(rsxdxUeCoktNZItGVaNZQHqLiSynovvHBFM(mX0ZuJ3zffVaE6jLx5OhuzLgSW5e(aQuHWhqfL23hjYmX07JOW4DwjcN8UY5dWARk4r0pIcoJuTkd9ry6AuQ4wTIsqd(gkrCsVg8sQIsytT5tyx1nRe1imrTszcd4YYwzLgi8burWJOFefCgPAvg6JW01OuXBwIx0vvxXYZz1qOOvjclwJtvvMUwB6ZetptnENvu8c4PNuELJEqLvAWcNt4dOsfcFavI6A9hjYmX07JOW4D(rE87ZQeHtEx58byTvf8i6hrbNrQwLH(iKHd44PvROe0GVHseN0RbVKQOe2uB(e2vDZkrnctuRuMWaUSSvwPbcFave8i6hrbNrQwLH(iKHd44zZMvi8burWJOFefCgPAvg6JeGyUToB2c]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20171128.094747, [[dqt5caGEiK2LKuEnKy2s1nPIVrLANu1Ej7gP9dPgMinoiidfc0GrWWrvoiQ0XqPZHq1crvTurSyuSCP8qjXtbltcphQMiQWuLOjtPPRQlIqUkeuxw56iYVvzRqKnJkA7quNMIVcb8ziuFxsQEmu(lvYOLu3wuNes6WcxtssNhr9mjjMgcL1bHyXQsbawZW7fiGJXzqQ)IVGK1xGp5lszDZYwGqvlL4fetaWByMOBq04nhv(IQwiGl2BokUkLNvLciIgm9zfFbCzmDZtwaV7nhvaQuRbl(RjGE0jW5SifnFKNab(ipbi49MJkiz9f4t(Iuw3SPcsg(rQHnCvQxqL6HHIZH8YJ(IrGZz9rEc0lFHkfqeny6Zk(c4Yy6MNSGwyWNl7cRauPwdw8xta9OtGZzrkA(ipbc8rEcscd(qtGJfwbjRVaFYxKY6MnvqYWpsnSHRs9cQupmuCoKxE0xmcCoRpYtGE5RIkfqeny6Zk(c4Yy6MNSGOLj76401xpx2fwbOsTgS4VMa6rNaNZIu08rEce4J8eWTLjJMWXjAcF9qtGJfwbjRVaFYxKY6MnvqYWpsnSHRs9cQupmuCoKxE0xmcCoRpYtGE5jMkfqeny6Zk(c4Yy6MNSaMUbX1)SUAKOZv1xW7OcqLAnyXFnb0JoboNfPO5J8eiWh5jGF3G46Fw0esirhAciWcEhvqY6lWN8fPSUztfKm8JudB4QuVGk1ddfNd5Lh9fJaNZ6J8eOxVaFKNaWKRGMactRVozebnbETHDzM41lb]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20171128.094747, [[d0trfaGEPeAtIc1UiPEnG2NOqMPOinBj9Be3ukonsFdK8yr2PuTxQDJY(jQFkLKHbQgNucopj5YQgmrgojCqs0PefvhtuDorrSqqQLIkwSqwUGfjLINcTmuP1ranrPuzQGYKLy6kDra6QeiptkvDDHAJsj1wjO2mi2oaoSIVlknncuZJa8xc52anAuvFgv5KeKTjLORjLs3tuWZj1djuJsuu25gMrmfOkwJgB3HmX11qBKZRF03DUWZHkpNBlOgEMWvWgrfprNkTfNLsyUZTTCnQmTuctByUNBygbKnr1xm0gvgrR0vLXYNLVOeHwnkeRqtZscgze2n2qkcpH(aEJg7d4n2UplFzjXeA1iNx)OV7CHNdvoCJCUMehsxByEnkM)taBiaCWZwhzSHu6d4n61DUgMraztu9fdTrmfOkwJLhfdbIAixVpqz8eLLeZkQ17KakljazPwklLXYsjcPwizzQhfK0uvPqF1HdouMwwsaYsT3OYiALUQmc569bkJNi9gOaVrHyfAAwsWiJWUXgsr4j0hWB0yFaVXwF9(aLXtwc3af4nY51p67ox45qLd3iNRjXH01gMxJI5)eWgcah8S1rgBiL(aEJEDV9gMraztu9fdTrmfOkwJtAPaCrNDq61YszugKL4AuzeTsxvgttTkAslLWevP61OqScnnljyKry3ydPi8e6d4nASpG3O4PwLLuMwkHjlLPu9AuzGN2iBaFgAdsbflljigFsvLaLLu2kaBJroV(rF35cphQC4g5CnjoKU2W8Aum)Na2qa4GNToYydP0hWBePGILLeeJpPQsGYskBfGEDxWgMraztu9fdTrmfOkwJLhfdbIAixVpqz8eLLeZkQ17KakljGmiljyJkJOv6QYiKR3hOmEI0BGc8gfIvOPzjbJmc7gBifHNqFaVrJ9b8gB917dugpzjCduGxwkZYZCJCE9J(UZfEou5WnY5AsCiDTH51Oy(pbSHaWbpBDKXgsPpG3Ox3BRHzeq2evFXqBetbQI1y5rXqGOgY17dugprzjXSI6yfgvgrR0vLrDIeh4Dr6nqbEJcXk00SKGrgHDJnKIWtOpG3OX(aEJyIeh4DzjCduG3iNx)OV7CHNdvoCJCUMehsxByEnkM)taBiaCWZwhzSHu6d4n619wAygbKnr1xm0gXuGQynwEumeiQHC9(aLXtuwsmROowHrLr0kDvzmvNSugprA(tHKvBuiwHMMLemYiSBSHueEc9b8gn2hWBuCDYsz8KLq(tHKvBKZRF03DUWZHkhUroxtIdPRnmVgfZ)jGneao4zRJm2qk9b8g961yFaVrKckwwsqm(KQkbklbWubQk41ga]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20171128.094747, [[dKZDeaGEskAtKuAxKeVgLSpuQMnsnFsQUPe9neQDQK9sTBuTFPmkesddjghjP8BsnyPA4OOdQu6uiGJjOZrsIfIKSuuyXsQLd0dvkEk0YKKNdyIietfrMmrth0ffWvjjvxw11LGtRyROu2mcY2jrpMW9qq9zb67si3wO)QunAe1HfDsKutdb6AsOCEs4zKK06iPWpLq1o0KmIcWHj0OrICcLfOHMkJmo9tG7vfLqIddRunvOOkve0iY8IjPh1mHJM7vvXQmUvahnhWK8k0KmgGN10xAQmIcWHj0ykGJYVF(JZbAD2jCRxzCB9qpqfgLpHK3tUCxErQWi1C5isOg0ixZVXsTKTeCLXB04kJ3irEcj36jx26e5IuHrgN(jW9QIsiXHumY4a6cGIdysgACd5lyvQv(45qxBSulxz8gn0RktYyaEwtFPPYikahMqJPaok)(5pohO1zV1jOXT1d9avy8mh5JJWi1C5isOg0ixZVXsTKTeCLXB04kJ3yaMJ8XryKXPFcCVQOesCifJmoGUaO4aMKHg3q(cwLALpEo01gl1YvgVrd9svnjJb4zn9LMkJOaCycnMc4O87N)4CGwNDc36vTUABDI26YNqY7jxUlVivOcCeSgEWwxD1BD5j0qFvGJG1Wd26eW426HEGkmci0fad(Dai4W6gPMlhrc1Gg5A(nwQLSLGRmEJgxz8grHUayW36ieCyDJmo9tG7vfLqIdPyKXb0fafhWKm04gYxWQuR8XZHU2yPwUY4nAOxe0KmgGN10xAQmIcWHj0ykGJYVF(JZbAD2jCRx16QT1jARlFcjVNC5U8IuHkWrWA4bBD1vV1LNqd9vbocwdpyRtaJBRh6bQWOGolA4b3biNsDragPMlhrc1Gg5A(nwQLSLGRmEJgxz8g3qNfn8GTosoL6IamY40pbUxvucjoKIrghqxauCatYqJBiFbRsTYhph6AJLA5kJ3OHEvmtYyaEwtFPPYikahMqJPaok)(5pohO1zV1RmUTEOhOcJN5iFCegPMlhrc1Gg5A(nwQLSLGRmEJgxz8gdWCKpoIwNOHeWiJt)e4EvrjK4qkgzCaDbqXbmjdnUH8fSk1kF8CORnwQLRmEJgAOXvgVrCIBADvNtwtRqnA9TfpGH2]] )

    storeDefault( [[SimC Unholy: cooldowns]], 'actionLists', 20171128.094747, [[d4JJhaGEGqTjHKDjQ2MiQ2NqQzskupxIzly(ssUjapMQUTsoSu7ej7v1UrSFOgfPGHbOFR48kvNMIbdz4I0bPIofqQJjPooqWcfrwkPQftLwojlIuKNsSmHQ1bKmrHqMkPYKP00bDrsPUkq0LrDDr5BsITkuAZiLTlu8rGq(oq10ifY8ec(Rs5qIOmAKQXjeQtke9zGY1if19iL8mjPEOi8AQWV(6UOnPDdS9UxO6fFrmReyeij0NWoOWi)mb7aoPCrph4UWNkoW6k11XJ486lIxzsHxU40dndPCDNQ(6UOnPDdS9jDr8ktk8cdczM0u2M7NGDJo3kigffg5MrJwUFc2n6CRG5fy7DGrrJr1aXOOWOKHrw2nJgT8YKf2uCNYQ8S0loDnbdC)IVdHT2dndzlykWlrsSgFdh1fYq4lagBSTIQx8Llu9IVKOdbmYPhAgcgPXMc8ItfyLlKEXAPjXSsGrGKqFc7GcJ8tWIr05wb10f9CG7cFQ4aRRud8IEUmzkpxUUdVKGo7DayIHxmbE3laglvV4lIzLaJajH(e2bfg5NGfJOZTcE4PIFDx0M0Ub2(KU401emW9lTATVn02G05nl32lrsSgFdh1fYq4lagBSTIQx8Llu9IV4uT2XOHggbPZyueXT9IEoWDHpvCG1vQbErpxMmLNlx3HxsqN9oamXWlMaV7faJLQx8Ldpv1x3fTjTBGTpPlIxzsHxSSBgnA504cKvgcyBGpzeBEb2Ehyu0AHrj)ItxtWa3V0PJVd7Pf(sKeRX3WrDHme(cGXgBRO6fF5cvV4lothFh2tl8f9CG7cFQ4aRRud8IEUmzkpxUUdVKGo7DayIHxmbE3laglvV4lhEkn66UOnPDdS9jDr8ktk8IgWOKHrmiKzstzBED1vawrZyuvvHr(zc2bCsUTvo2GQMuOnQvdndjxXR2qkyueWO4yeOXOOWivgX43shWzvULPz8gigfbmQAGxC6Acg4(fBRCS1kxdKvxIKyn(goQlKHWxam2yBfvV4lxO6fFjIALdmYPY1az1f9CG7cFQ4aRRud8IEUmzkpxUUdVKGo7DayIHxmbE3laglvV4lhEknFDx0M0Ub2(KUiELjfErdyuYWigeYmPPSnVU6kaROzmQQQWi)mb7aoj32khBqvtk0g1QHMHKR4vBifmkcyunqmc0yuuyKkJWLCOzXBWztJWOO1cJaZBV401emW9lLS1AiBG1kWM9aFjsI14B4OUqgcFbWyJTvu9IVCHQx8fjBTgcgbIAfyZEGVONdCx4tfhyDLAGx0ZLjt55Y1D4Le0zVdatm8IjW7EbWyP6fF5WtL8R7I2K2nW2N0fXRmPWlAaJSSBgnA504cKvgcyBGpzeBEb2Ehyu0AHrjhJIcJ8ZeSd4K8oD8DypTW5kE1gsbJIGwyeyElgbAmQQQWinGrw2nJgTCACbYkdbSnWNmInVaBVdmkATWOQXOOWivgHXOO1cJQgJIcJ8ZeSd4K8oD8DypTW5kE1gsbJIgJIdeJa9fNUMGbUFPmzHnf3PS6sKeRX3WrDHme(cGXgBRO6fF5cvV4lYKfWi9CNYQl65a3f(uXbwxPg4f9CzYuEUCDhEjbD27aWedVyc8UxamwQEXxo8uvUUlAtA3aBFsxeVYKcV4NjyhWj52w5ydQAsH2Own0mKCf329loDnbdC)IVdHT2dndzlykWlrsSgFdh1fYq4lagBSTIQx8Llu9IVKOdbmYPhAgcgPXMceJ0qnOV4ubw5cPxSwAsmReyeij0NWoOWilutx0ZbUl8PIdSUsnWl65YKP8C56o8sc6S3bGjgEXe4DVaySu9IViMvcmcKe6tyhuyKfE4HxKu2B6Gbe3qZqovCnh)WF]] )

    storeDefault( [[SimC Unholy: dt]], 'actionLists', 20171128.094747, [[d0dJhaGEsuQnPG2fQ8AfAFus9CPmBGMVuLUjj8yu1Tf1HPANK0EH2Tk7h0OqsnmPY4aOops0PrzWigUI6GusofsYXOuhNczHkGLksTykA5k9qrWQOqPLjswhjkmrPQAQiLjtQPRQlkcDvsu0LjUoGoejQARsvSzkX2vGMga5zuWNjrMhjQ8xfzBuOA0iHVdGtkvLBrHIRjIUhjk5Bivpv43sgTrAyK45MGIgnXq1ZcgblNaKOmpkkqkvgqI(XiTakEtq1uD20TTtbyoBmc(Ln)yGHv8pRUgsdvTrAyK45MGIghaJGFzZpgIrazZZIMZ2a9o6jHKHqY7GY9CAFhN81K9YYjNBckAiziKqnK8oOCpxJcxxamXolaBS64KZnbfnK0BVqcFvG6cGJt774KVMSxwUvYo7AqI1qsYuqcvqYqiHVkqDbWXP9DCYxt2ll3kzNDniXAiXqhKmesuEirmciBEw0C2aQdWDghdRmzGSNsm0(oo9RFnl1M9Nvhg9DAgV)1IXvNGHIs3JVQEwWadvply0VVJqcT1VMLAZ(ZQdJ0cO4nbvt1zt3UdJ0sRaU8sdPHpgjqHWpQOguYY9OjgkkTQNfmWhvtH0WiXZnbfnoagb)YMFmeJaYMNfnNTb6D0tcjdHeQHK3bL75Au46cGj2zbyJvhNCUjOOHKE7fs4RcuxaCCAFhN81K9YYTs2zxdsSgsOgssMcsmwiXMZGbdqcvqcvqYqirmciBEw0C2aQdWDghsgcj8vbQlaooTVJt(AYEz5wj7SRbjwdjudjg6GeJfsS5myWaKqfgwzYazpLyO9DC6x)AwQn7pRom670mE)RfJRobdfLUhFv9SGbgQEwWOFFhHeARFnl1M9NvhKqTnvyKwafVjOAQoB62DyKwAfWLxAin8Xibke(rf1GswUhnXqrPv9SGb(OQbKggjEUjOOXbWi4x28JHyeq28SO5SnqVJEsiziK8(QK8CplltFnPzcKOCqcFvG6cGJt774KVMSxwUvYo7AqIXajagdRmzGSNsm0(oo9RFnl1M9Nvhg9DAgV)1IXvNGHIs3JVQEwWadvply0VVJqcT1VMLAZ(ZQdsOofvyKwafVjOAQoB62DyKwAfWLxAin8Xibke(rf1GswUhnXqrPv9SGb(OkGqAyK45MGIghaJGFzZpgIrazZZIMZ2a9o6jHKHqc1qY7GY9CnkCDbWe7SaSXQJto3eu0qsV9cj8vbQlaoUgWCUUjL8vPIsqHBLSZUgKynKKmjKqfKmes4RcuxaCCnG5CDtk5RsfLGc3kzNDniXAiXqsmSYKbYEkXq7740V(1SuB2FwDy03Pz8(xlgxDcgkkDp(Q6zbdmu9SGr)(ocj0w)AwQn7pRoiHAduHrAbu8MGQP6SPB3HrAPvaxEPH0WhJeOq4hvudkz5E0edfLw1Zcg4JQjrAyK45MGIghaJGFzZpgIrazZZIMZ2a9o6jHKHqY7RsYZ9SSm91KMjqIYbj8vbQlaoUgWCUUjL8vPIsqHBLSZUgKymqcGXWktgi7PedTVJt)6xZsTz)z1HrFNMX7FTyC1jyOO094RQNfmWq1Zcg977iKqB9RzP2S)S6GeQbevyKwafVjOAQoB62DyKwAfWLxAin8Xibke(rf1GswUhnXqrPv9SGb(OQXrAyK45MGIghaJGFzZpgkpKigbKnplAoBd07ONesgcjlWtACplltFnbiiXALfKOeVgdRmzGSNsm0(oo9RFnl1M9Nvhg9DAgV)1IXvNGHIs3JVQEwWadvply0VVJqcT1VMLAZ(ZQdsOojvyKwafVjOAQoB62DyKwAfWLxAin8Xibke(rf1GswUhnXqrPv9SGb(4Jrml8mhKPS9NvhQMkzk8re]] )

    storeDefault( [[SimC Unholy: cold heart]], 'actionLists', 20171128.094747, [[duJBdaGEuqTjiyxq1RfQ2hkIzRWnHOBdPDcL9kTBe7NOrHczyOu)gyWegok5GOOofkshJkwOqXsfIfRklxKhsL8usltfTouqMkQYKvvth0frv5QqO6YuUUk9CQAROQAZIA7cLEmshwPptLAEOqDEH0PfmAf9nvOtQc(lQCniuUhkGTbH04qb6zqiUoLxv(i7By)(QITOwvnG6skqCYemIYqsbfm(sX02eSAeByR3k2jBNJooNmiUtvLMcSGvRYmfgaeF5vmNYRkFK9nSFJPQstbwWQVBoJFjtWikNhMmIB4epzOBG4LcglfUPFPabP4DZz8lzcgr58WKrCdN4xwsbcsX7MZ4uW4ZnTnbX9WLgxkyIu4GOvz(fgby0Q05giEoqMlqTQhi)aDHGuvcGyvrc(8VjSf1QwfBrTQUMBG4LcqwkoqTQrSHTERyNSDo6WUAeZdUjQ5lVcR6AA04ibXAOgb2xvKGp2IAvlSyNLxv(i7By)gtvLMcSGvF3CghD9qlXbYCUNG7WJNm0nq8sbJLc30VuGGu8U5mo66HwIdK5Cpb3Hh)YskqqkE3CgNcgFUPTjiUhU04sbtKcNJvz(fgby0Q05giEoqMlqTQhi)aDHGuvcGyvrc(8VjSf1QwfBrTQUMBG4LcqwkoqnPGromTAeByR3k2jBNJoSRgX8GBIA(YRWQUMgnosqSgQrG9vfj4JTOw1clgIuEv5JSVH9BmvvAkWcw9DZzCky85M2MG4E4sJlfmGuCYwkqqkE3Cg)sMGruopmze3Wj(LvvMFHragTkDUbINdK5cuR6bYpqxiivLaiwvKGp)BcBrTQvXwuRQR5giEPaKLIdutky0jtRgXg26TIDY25Od7Qrmp4MOMV8kSQRPrJJeeRHAeyFvrc(ylQvTWcRQSmAyhbgEHbaPyNi2zHTa]] )

    storeDefault( [[SimC Frost: standard]], 'actionLists', 20180108.222353, [[diKQtaqisj2KGQpbQqnksLofPIvjOi2fv1WqLoMewMG8mbfMgOsUMGsBtqr9nurJJejohPiTosKK5rI4EKIAFGk1brvSquLEiPWejrsDrsuBKusFuqrAKGkKtsk1nLk7eP(jjsTuuvpLyQKKTsQYxbvWEv(RadMkhgyXi5XsAYs5YQ2mO8zjYOjPonkVMeMTq3gKDJ43qgUu1XjfXYH65umDrxNQSDqvFhv48suRhurZNuv7NsVIPAcna6tegKgwNwXitQuzDMeqAaCBIuXS(CYe(pEG5Joe3colkcPu85QPWfNWfNtK(xzGidobjdrgDOWwmHNAYqeZun6IPAIYeav8TX7ePIz95Keepj9z1YbjiIig)tauX3SUWTokpyW8z1YbjiIigF8HamIX6uIMTUs12eEOyrwwEcmmYKbMeZu8jAtASkir4jee5t6qn9ayAa0NmHga9jAfJmP1jjMP4t4)4bMp6qCl4SG7e(3G8W1BMQLt0q9Rk6qWFOtYrnPd1ObqFYYrhAQMOmbqfFB8orQywFojbXtsFJAqMhZiLcmjMP4g)tauX3SUWTU2P8GbZhdGteMvVVjbvfwNMTUWADHBDuEWG5xcKQpMrkfysegY3KGQcRtjwxiRlCRtlwhLhmy(yg0996NWdflYYYtGHrMmWKyMIprBsJvbjcpHGiFshQPhatdG(Kj0aOprRyKjTojXmf360TqNj8F8aZhDiUfCwWDc)BqE46nt1YjAO(vfDi4p0j5OM0HA0aOpz5OdJPAIYeav8TX7ePIz95eDTokpyW8XmO771BDHBDxt8y99V53FS5WFmGuFacwqQ(bNcrcGa4Sm260X60xFRlbXts)sGu9XmsPatIWq(NaOIVnHhkwKLLNGpecBE8gtahmsE8eTjnwfKi8ecI8jDOMEamna6tMqdG(e(hcHnpEJX6GdmsE8e(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0W1unrzcGk(24DIuXS(CIUw31epwF)B(kqXKHbMaY5agYJ0c4GfJwx4wxcINK(WWi48KGEVO5(NaOIVzDHBDMNbuiINXpzhxOPbH6RwNMTUcRthRtF9ToSh5g)Kb9GefaxwNsSUs1M1fU1r5bdMVApsPJzKsbypYd44GEeX3RFcpuSillpbrfz5XG8t0M0yvqIWtiiYN0HA6bW0aOpzcna6tuAQilpgKFc)hpW8rhIBbNfCNW)gKhUEZuTCIgQFvrhc(dDsoQjDOgna6two6WovtuMaOIVnENivmRpNOR1PfRlbXtsFJAqMhZiLcmjMP4g)tauX3So9136ANYdgmFmaoryw9(MeuvyDkX6cR1PJ1fU1H9iSAqpIJJ9BhgRYsRtjwxb3j8qXISS8eyyKjdmjMP4t0M0yvqIWtiiYN0HA6bW0aOpzcna6t0kgzsRtsmtXToDdPZe(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0H5PAIYeav8TX7ePIz95ekpyW8XmO771pHhkwKLLNOgXrKrkfqfbMCI2KgRcseEcbr(KoutpaMga9jtObqFcCeIJiJuY64ncm5e(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0CovtuMaOIVnENivmRpNOR1DnXJ13)MVcumzyGjGCoGH8iTaoyXO1fU1LG4jPpmmcopjO3lAU)jaQ4Bwx4wN5zafI4z8t2XfAAqO(Q1PzRRW60X60xFRd7rUXpzqpirbH16uI1vQ2MWdflYYYtqurwEmi)eTjnwfKi8ecI8jDOMEamna6tMqdG(eLMkYYJb5ToDl0zc)hpW8rhIBbNfCNW)gKhUEZuTCIgQFvrhc(dDsoQjDOgna6twoALYunrzcGk(24DIuXS(CIUw31epwF)B(veXGWPjOIITGkcFRtF9TokpyW87zXiahGGfadJmPVxV1PJ1fU1r5bdMVhrnkwoWK4tkLQ996TUWTU2P8GbZhdGteMvVVjbvfwNMTUWoHhkwKLLNyyKgguczaMayE4Yt0M0yvqIWtiiYN0HA6bW0aOpzcna6tegPHbLqgaCSX60QhU8e(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0A6unrzcGk(24DIuXS(Cc2JWQb9ioo2VDySklToLyDfCTUWToTyDuEWG5R2Ju6ygPua2J8aooOhr896NWdflYYYtGHrMmWKyMIprBsJvbjcpHGiFshQPhatdG(Kj0aOprRyKjTojXmf360nm0zc)hpW8rhIBbNfCNW)gKhUEZuTCIgQFvrhc(dDsoQjDOgna6two6cUt1eLjaQ4BJ3jsfZ6ZjuEWG5RGfJmsPaiqvnJCFVERlCRtxRtlw31epwF)B(kqXKHbMaY5agYJ0c4GfJwN(6BDGAYG)bNCi2nwhCRzRlK1PZeEOyrwwEcmmYKMA5u9NOnPXQGeHNqqKpPd10dGPbqFYeAa0NOvmYKMA5u9NW)XdmF0H4wWzb3j8Vb5HR3mvlNOH6xv0HG)qNKJAshQrdG(KLJUOyQMOmbqfFB8orQywFoHYdgmFfSyKrkfabQQzK771pHhkwKLLNGOIS8yq(jAtASkir4jee5t6qn9ayAa0NmHga9jknvKLhdYBD6gsNj8F8aZhDiUfCwWDc)BqE46nt1YjAO(vfDi4p0j5OM0HA0aOpz5OlcnvtuMaOIVnENivmRpNG9iSAqpIJJ9BhgRYsRtjwxiUt4HIfzz5jWWitgysmtXNOnPXQGeHNqqKpPd10dGPbqFYeAa0NOvmYKwNKyMIBD6cx6mH)Jhy(OdXTGZcUt4FdYdxVzQword1VQOdb)Hojh1KouJga9jlhDrymvtuMaOIVnENivmRpNaQjd(hCYHy3yDWTMTUqt4HIfzz5j4dHWMhVXeWbJKhprBsJvbjcpHGiFshQPhatdG(Kj0aOpH)HqyZJ3ySo4aJKhBD6wOZe(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0fW1unrzcGk(24DIuXS(CcOMm4FWjhIDJ1b3A26cnHhkwKLLNukcQmqma0GhqQFI2KgRcseEcbr(KoutpaMga9jtObqFsyAeuzGO1XtdEaP(j8F8aZhDiUfCwWDc)BqE46nt1YjAO(vfDi4p0j5OM0HA0aOpz5Olc7unrzcGk(24DIuXS(CcOMm4FWjhIDJ1b3A26cJj8qXISS8eyyKjn1YP6prBsJvbjcpHGiFshQPhatdG(Kj0aOprRyKjn1YP6BD6wOZe(pEG5Joe3col4oH)nipC9MPA5enu)QIoe8h6KCut6qnAa0NSC0fH5PAIYeav8TX7ePIz95eTyDjiEs6xcKQpMrkfysegY)eav8nRtF9TUkcfBioi(4dHWMhVXeWbJKh7JpeGrmwhCBD6ADLQnRlmX6czD6mHhkwKLLNGOIS8yq(jAtASkir4jee5t6qn9ayAa0NmHga9jknvKLhdYBD6gg6mH)Jhy(OdXTGZcUt4FdYdxVzQword1VQOdb)Hojh1KouJga9jlhDbNt1eLjaQ4BJ3jsfZ6ZjAX6O8GbZxThP0XmsPaSh5bCCqpI471BDHBD6ADypYn(jd6bjkiK1b3wxPAZ60xFRtlwxcINK(WWi48KGEVO5(NaOIVzD6mHhkwKLLNOgHjbiybCWi5Xt0M0yvqIWtiiYN0HA6bW0aOpzcna6tGJqyI1HGzDWbgjpEc)hpW8rhIBbNfCNW)gKhUEZuTCIgQFvrhc(dDsoQjDOgna6two6cLYunrzcGk(24DIuXS(CIwSoDToShHvd6rCCSF1dJpjToLyDHLR1fU1LG4jPpIkYYJbjdr8pbqfFZ6c36QiuSH4G4JOIS8yqYqeF8HamIX6uIMTUs1M1PZeEOyrwwEcmmYKbMeZu8jAtASkir4jee5t6qn9ayAa0NmHga9jAfJmP1jjMP4wNUHvNj8F8aZhDiUfCwWDc)BqE46nt1YjAO(vfDi4p0j5OM0HA0aOpz5Ol00PAIYeav8TX7ePIz95eTyDjiEs6xcKQpMrkfysegY)eav8nRtF9TUeepj9z1YbjiIig)tauX3MWdflYYYtqurwEmi)eTjnwfKi8ecI8jDOMEamna6tMqdG(eLMkYYJb5ToDHlDMW)XdmF0H4wWzb3j8Vb5HR3mvlNOH6xv0HG)qNKJAshQrdG(KLJoe3PAIYeav8TX7ePIz95eTyDjiEs6tHpivhGGfyyKggucza(NaOIVzD6RV1LaCPN(jd6bjkOXU1PeRRIqXgIdIpf(GuDacwGHrAyqjKb4JpeGrmt4HIfzz5jhQhXXXbypYd44GEezI2KgRcseEcbr(KoutpaMga9jtObqFIYq9ioo2647rU1bhoOhrMW)XdmF0H4wWzb3j8Vb5HR3mvlNOH6xv0HG)qNKJAshQrdG(KLlNOuFyaVyoExUb]] )

    storeDefault( [[SimC Frost: obliteration]], 'actionLists', 20180108.222353, [[d4t9haGEkLYMOuSlkzBqPs7dkL1rPe9nOKztL5lIUPkmoQQIBlQZJq2juTxPDJ0(PyuuvzyOIFJYPHCyvnysnCO4qkv4uufDmbohuQQfQu1srvwSkTCsEiQupL4Xk55cnrOuLPIQAYiA6kUiLQwMi8mLk66cAJkvQTsPYMvkBNQYNvrFfkvmnQQQ5rPegPsL8xrA0i47iuNKQWLbxJQQ09Ous)KsP61uLoiQKBq5xb)ZqfbL52O3TIfhBPrZUo0aQFqmAfzPqyMkv4bo4JqXtWjaRGGe(JfhSV)XY)yvrWal07q22pigT4j83GkCTgeJgl)Ihu(vSN(xhq29vKLcHzQmVdOJ15peafIEMghMkBb0)6aYkCDro0quffKzQi4GymLyeDavfpOKO1pmvfkJcvoyK29k8pdvQG)zOcpiZurWbXOrJDq0buv4bo4JqXtWjaRaov4brwOAbXYVtfUjalVhmFqgOtVvoyK4FgQ0P4jk)k2t)Rdi7(kYsHWmv8ZOVHBBwErohIEMM)fbefScXy02y0(z03WTnlViNdrptZ)IaIcwHym6KjnAmkWx65I0kWAtXItACuiVGrNmPrJrb(spxKwbweye7q0Z0R7JJr7Pr7PrBJr)Rb5dsbkKrq0OXMrhuHRlYHgIQSPyXjUiAiav8GsIw)WuvOmku5GrA3RW)muPc(NHk7wXItCr0qaQWdCWhHINGtawbCQWdISq1cILFNkCtawEpy(GmqNERCWiX)muPtX3z5xXE6FDaz3xrwkeMPIFg9nCBZYlY5q0Z08ViGOGvigJ2gJ2pJ(gUTz5f5Ci6zA(xequWkeJrNmPrJrb(spxKwbwBkwCsJJc5fm6KjnAmkWx65I0kWIaJyhIEMEDFCmApnApn6KjnA)m6FniFqkqHmcIgn2SvJENgTng9om6B42MLcLbRqmgTNv46ICOHOkSRdnG6hOIhus06hMQcLrHkhms7Ef(NHkvW)muX2Vo0aQFGk8ah8rO4j4eGvaNk8GiluTGy53Pc3eGL3dMpid0P3khms8pdv6uC)x(vSN(xhq29vKLcHzQCd32SuOmyfIXOTXO)1G8bPafYiiA0yZOdQW1f5qdrviWi2HONPx3hNkEqjrRFyQkugfQCWiT7v4FgQub)ZqLDXi2HONg9E3hNk8ah8rO4j4eGvaNk8GiluTGy53Pc3eGL3dMpid0P3khms8pdv6uC)T8Ryp9VoGS7RilfcZuzhg9nCBZsHYGvigJ2gJ(xdYhKcuiJGOrJnJoHrBJrRcPGrJnJENgTng98oGowBkaSne9mDJDAb0)6asJ2gJEEhqhRZFiake9mnomv2cO)1bKv46ICOHOkeye7q0Z0R7JtfpOKO1pmvfkJcvoyK29k8pdvQG)zOYUye7q0tJEV7JJr7xGNv4bo4JqXtWjaRaov4brwOAbXYVtfUjalVhmFqgOtVvoyK4FgQ0P4y3YVI90)6aYUVISuimtLDy03WTnlfkdwHym6KjnAvifIwdkdPdlnWOXMTA0NlsJozsJwfsrRummIbLfjSHwOXOTfgDcov46ICOHOkBkwCsJJc5fQ4bLeT(HPQqzuOYbJ0UxH)zOsf8pdv2TIfhJwgfYluHh4GpcfpbNaSc4uHhezHQfel)ov4MaS8EW8bzGo9w5GrI)zOsNIJv5xXE6FDaz3xrwkeMPYnCBZsHYGviMkCDro0qufcmIDi6z619XPIhus06hMQcLrHkhms7Ef(NHkvW)muzxmIDi6PrV39XXO9lHNv4bo4JqXtWjaRaov4brwOAbXYVtfUjalVhmFqgOtVvoyK4FgQ0P4(t5xXE6FDaz3xHRlYHgIQWUo0aQFGkEqjrRFyQkugfQCWiT7v4FgQub)ZqfB)6qdO(bmA)c8ScpWbFekEcobyfWPcpiYcvliw(DQWnby59G5dYaD6TYbJe)ZqLoDQG9GTp0nDFNwa]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20180108.222353, [[d0tBgaGEsfTjef8wvjTneL0mfPSor0SPQ5Rk1nbL7ks1TLQFlSte2RYUHSFPmksLmmQ04quIVbfopPQgSOgou0bHkNIufhtvCoeLAHiQwku1IjYYj8qq6POwMi55inref1ujftwvnDjxKkYPbEgIcDDezJIWwPIAZe12PcoSkFNuL(mP08quKhtYLPmAq0FHsNKk00iv4AKk19uLyrGWRbvTlqL3Z0mM462yg0H2YjebTs2YFt(i5RXSsaWSgpgV5TJAJiL7dgppPilW5s26adDGXygttbopqNxbc0isP7NX4ufiq0PzeptZyNqNK3(J8X4KaEqP)4oa9XklmtN2yhrFG6QqmgfiBmS478jiUUnEmX1TXWaOFlNqyMoTX4nVDuBePCFW4XDmEJgKekJonRgdfstbpSWbRBOAsJHfFIRBJxnIutZyNqNK3(J8X4KaEqP)y159ypvbcewpGwJDe9bQRcXyuGSXWIVZNG4624Xex3g)wjl76QuYYVc98(wgNQabQLtdqR0FlgJtOLogDD7fiyqhAlNqe0kzlRIW)d9IOqmgV5TJAJiL7dgpUJXB0GKqz0Pz1yOqAk4HfoyDdvtAmS4tCDBmd6qB5eIGwjBzve(FOxeD1iiJtZyNqNK3(J8XSsaWSgxN3qfCsc7kiXgYyPa0xCAd6bNHojV9BzYqlRIW)d9IGtsyxbj2qglfG(ItBqp4ew)aiAltMA5hDpgNeWdk9hliHWEQceiSEaTgdfstbpSWbRBOAsJHfFNpbX1TXJjUUn(Tsw21vPKLFfpjulJtvGa1YPbOv6VfJXj0shJUU9cemOdTLticALSLLcAlJzeEasleJXBE7O2is5(GXJ7y8gnijugDAwn2r0hOUkeJrbYgdl(ex3gZGo0woHiOvYwwkOTmMr4biTRgHoMMXoHojV9h5JzLaGzn(hfCsc7kiXgYyPa0xCAd6bxbuWdqAhJtc4bL(JfKqypvbcewpGwJHcPPGhw4G1nunPXWIVZNG4624Xex3g)wjl76QuYYVINeQLXPkqGA50a0k93Iwwxp6zmoHw6y01TxGGbDOTCcrqRKTSuqB5cOGhG0cXy8M3oQnIuUpy84ogVrdscLrNMvJDe9bQRcXyuGSXWIpX1TXmOdTLticALSLLcAlxaf8aK2vJq3tZyNqNK3(J8XSsaWSglrswgUqYdktCfiqWrcZX4KaEqP)ybje2tvGaH1dO1yOqAk4HfoyDdvtAmS478jiUUnEmX1TXVvYYUUkLS8R4jHAzCQceOwonaTs)TOL1vk9mgNqlDm662lqWGo0woHiOvYwoK8GYexbceeJXBE7O2is5(GXJ7y8gnijugDAwn2r0hOUkeJrbYgdl(ex3gZGo0woHiOvYwoK8GYexbc0QrqwNMXoHojV9h5JXjb8Gs)XQZ7XEQceiSEaTg7i6duxfIXOazJHfFNpbX1TXJjUUn(Tsw21vPKLFf659TmovbculNgGwP)w0Y66rpJXj0shJUU9cemOdTLticALSLP1H(N4dXy8M3oQnIuUpy84ogVrdscLrNMvJHcPPGhw4G1nunPXWIpX1TXmOdTLticALSLP1H(N4VA1yYSjFK81iF1ga]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20180108.222353, [[b4vmErLxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEn1uJjxAWrNxt51usvgBLf2CL5LtYatm3etmYGJlWKdn3qZnEn1uWv2yPfgBPPxy0L2BU5LtYutmEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfFJzMzWaZyJzMzBb1B0L2BU1fFY51usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt5fDErNxtruzMfwDSrNxc5fDE5f]] )

    storeDefault( [[SimC Frost: cooldowns]], 'actionLists', 20180108.222353, [[dy0DuaqiivTibvQnjigfe0PGqULGkXUOsdtjDmLYYuIEgeqtdsPUgeQ2MarFdvX4GqPZbPKwhKsmpiq3dsX(Gu5GqIfsk5HOknrbvXffK2OaPrkOQCsQGzkOs6Mq0orPFkOknubvSub8uktLk6QcQQ2Qa1xfiK3cHI7cbyVQ(lQmyIoSOfdLhlLjlvxgzZO4ZOQgnP40eEnK0SPQBdv7g0VLmCLQJlqOwoWZfA6kUoPA7uH(UGY5jLA9cemFLW(j5VDN3ytC6MjW5vjdkOIdArjBv57vyW4nRbe7ZTBbipLr6Slx34zBBjI1DfTI28G28CZ2PMi9IGqoIcE2Li(2nuAJOGX78SB35TqHjMN6xRBwdi2NBaDOOXTxHra3oXiAIrjrhAuYLRkzikj6vYj9eCCXauoA4kgUOa2bj)kMUemX8u)gkycVy0(wcAjK4Mcai4CZbyx0YPa3GfKUHS6bNa2eNUDJnXPBOaAjKusNfaqW5waYtzKo7Y1nE2wVfGILoOrX78ZnE1qnurwos4eCo2nKvNnXPBFo7Y78wOWeZt9R1nRbe7ZTEnUyakhnCfdxua7GKFft3r0qva5RKHOKaDOOXTxHra3oXiAIrjrhAuseFvjdrjb6qsjrqLC5nuWeEXO9Te0siXnfaqW5MdWUOLtbUbliDdz1dobSjoD7gBIt3qb0siPKolaGGJsIWneDla5PmsND56gpBR3cqXsh0O4D(5gVAOgQilhjCcoh7gYQZM40TpNfbEN3cfMyEQFTUznGyFUHPZW4Ul8(eWvmCmGkoU673qbt4fJ23W8v15y0bAFZbyx0YPa3GfKUHS6bNa2eNUDJnXPBA5RQRKbvhO9TaKNYiD2LRB8STElaflDqJI35NB8QHAOISCKWj4CSBiRoBIt3(Cw0(oVfkmX8u)ADZAaX(CdtNHXDx49jGRy4yavCC13VHcMWlgTVHrGibqva5FZbyx0YPa3GfKUHS6bNa2eNUDJnXPBArGibqva5Fla5PmsND56gpBR3cqXsh0O4D(5gVAOgQilhjCcoh7gYQZM40TpNfXVZBHctmp1Vw3qbt4fJ230JeNyi84nhGDrlNcCdwq6gYQhCcytC62n2eNUTOXWSU2AmmiMWFKushgcpIawaUfG8ugPZUCDJNT1BbOyPdAu8o)CJxnudvKLJeobNJDdz1ztC62NZgK35TqHjMN6xRBwdi2NBiujX0zyChcFFYruq34Knuvs0OKRkzik5Ka(04ocCIBkUUGus0PKb5QsIiLCXcLCsaFAChboXnfxxqkjcQKb56nuWeEXO9nGaYNRy4AL3N7rbKphJ(OdO4nE1qnurwos4eCo2nKvp4eWM40TBSjoDlGaYxjlgLK3Y7Z9OaYxjdQ(OdO4nua8J3GjoHgGaYNRy4AL3N7rbKphJ(OdO4TaKNYiD2LRB8STElaflDqJI35NBoa7Iwof4gSG0nKvNnXPBFolp35TqHjMN6xRBwdi2NBy6mmU7cVpbCfdhdOIJR(UsgIsIqLe9k5KEcoUyakhnCfdxua7GKFftxcMyEQRKlwOKOxjBv57vyqxmaLJgUIHlkGDqYVIPlGWtbmQKOtjxvseDdfmHxmAFttbGCfdNJPVa34vd1qfz5iHtW5y3qw9GtaBIt3UXM40TWxbGkzXOKbN(cCdfa)4nyItOrtbGCfdNJPVa3cqEkJ0zxUUXZ26TauS0bnkENFU5aSlA5uGBWcs3qwD2eNU95Si278wOWeZt9R1nRbe7ZnGoKIUJaN4MIdXvseujrGkzikjcvs0RK9ACXauoA4kgUOa2bj)kMUJOHQaYxjxSqjb6qrJBVcJaUnDaGGJsIoLmixvseDdfmHxmAFRdsD(AgUIHlw6(4nE1qnurwos4eCo2nKvp4eWM40TBSjoDl8asD(AgLSyusR09XBOa4hVbtCcnDqQZxZWvmCXs3hVfG8ugPZUCDJNT1BbOyPdAu8o)CZbyx0YPa3GfKUHS6SjoD7ZzrR35TqHjMN6xRBwdi2NBOxjN0tWXTW8IHa5ikOlbtmp1vYflusmDgg3cZlgcKJOGU673qbt4fJ23yiFj8uNtaziam9C4ztJas34vd1qfz5iHtW5y3qw9GtaBIt3UXM40TGs(WLWRWtDL0bidbGPxjrMnnciDdfa)4nyItOHH8LWtDobKHaW0ZHNnnciDla5PmsND56gpBR3cqXsh0O4D(5MdWUOLtbUbliDdz1ztC62NZUTEN3cfMyEQFTUHcMWlgTVPhjoXq4XBoa7Iwof4gSG0nKvp4eWM40TBSjoDBrJHzDT1yyqmH)iPKomeEebSaOKiCdr3cqEkJ0zxUUXZ26TauS0bnkENFUXRgQHkYYrcNGZXUHS6SjoD7Zz32UZBHctmp1Vw3SgqSp3W0zyC3fEFc4kgogqfhx9DLmeLeHkzVgxmaLJgUIHlkGDqYVIP7iAOkG8vYflusmDgg3cZlgcKJOGU67k5Ifk5KEcoUA0H8jGaYNdOdjUWOCVGUemX8uxjr0nuWeEXO9T9Aef8MdWUOLtbUbliDdz1dobSjoD7gBIt3w0yywxBngget4uJOGiGfGBbipLr6Slx34zB9wakw6GgfVZp34vd1qfz5iHtW5y3qwD2eNU95SBlVZBHctmp1Vw3SgqSp3M0tWXTW8IHa5ikOlbtmp1vYquseQKTQ89kmOBH5fdbYruqxaHNcyujrNsUCvjxSqjBv57vyq3cZlgcKJOGUacpfWOsIGk52QsUyHsIELCspbhxrJA5Ulbtmp1vseDdfmHxmAFBx49jGRy4yavCU5aSlA5uGBWcs3qw9GtaBIt3UXM40TWr49jqjlgLmOGko3cqEkJ0zxUUXZ26TauS0bnkENFUXRgQHkYYrcNGZXUHS6SjoD7Zz3qG35TqHjMN6xRBwdi2NBt6j44IbOC0WvmCrbSds(vmDjyI5PUsgIs2QY3RWGUyakhnCfdxua7GKFftxaLDTvYqusGou042RWiGBthai4OKOtjr81BOGj8Ir7B7cVpbCfdhdOIZnhGDrlNcCdwq6gYQhCcytC62n2eNUfocVpbkzXOKbfuXrjr4gIUfG8ugPZUCDJNT1BbOyPdAu8o)CJxnudvKLJeobNJDdz1ztC62NZUH235TqHjMN6xRBwdi2NBt6j44IbOC0WvmCrbSds(vmDjyI5PUsgIs2QY3RWGUyakhnCfdxua7GKFftxaHNcyujrNsI2R3qbt4fJ232fEFc4kgogqfNBoa7Iwof4gSG0nKvp4eWM40TBSjoDlCeEFcuYIrjdkOIJsIWLi6waYtzKo7Y1nE2wVfGILoOrX78ZnE1qnurwos4eCo2nKvNnXPBFo7gIFN3cfMyEQFTUznGyFUnPNGJRgDiFciG85a6qIlmk3lOlbtmp1VHcMWlgTVTl8(eWvmCmGko3Ca2fTCkWnybPBiREWjGnXPB3ytC6w4i8(eOKfJsguqfhLeHiqeDla5PmsND56gpBR3cqXsh0O4D(5gVAOgQilhjCcoh7gYQZM40TpNDliVZBHctmp1Vw3SgqSp3W0zyC3fEFc4kgogqfhx99BOGj8Ir7ByakhnCfdxua7GKFfZBoa7Iwof4gSG0nKvp4eWM40TBSjoDtlaLJgLSyusta7GKFfZBbipLr6Slx34zB9wakw6GgfVZp34vd1qfz5iHtW5y3qwD2eNU95SB8CN3cfMyEQFTUznGyFUrbX6I9DQ72kFNtdLGrjdrjrOsIqLetNHXTv(oNgkbJBCYgQkj6qJsUTQKHOKOxjX0zyClmVyiqoIc6QVRKHOKDctNHXfKbHciAKBCYgQkjAusexjrKsUyHsojGpnUJaN4MIRliLebrJsYV1vseDdfmHxmAFRLEpx2grb58I4CJxnudvKLJeobNJDdz1dobSjoD7gBIt3w0yywxBnggedVP3RKO0grbvYWvrCqala3qbWpEdM4eAc3MaNxLmOGkoOfLSv(UsQHsWeUVfG8ugPZUCDJNT1BbOyPdAu8o)CZbyx0YPa3GfKUHS6SjoDZe48QKbfuXbTOKTY3vsnucMpNDdXEN3cfMyEQFTUznGyFUb0HKsIo0OKBkzikjqhkAC7vyeWTPdaeCus0HgLC5QsgIsIqLe9k5KEcoUmGkiqqUDDFKCjyI5PUsUyHsc0HKsIGk5sLCXcLetNHXDx49jGRy4yavCCbeEkGrLebrJsUTujrKsgIsIqLe9k5KEcoU8Zrdbeq(CXPa4UemX8uxjxSqjrVs2QY3RWGUacVarYtXixyc4qaxaLDTvsePKHOKiujX0zyC3fEFc4kgogqfhx9DLCXcLe9k5KEcoUIg1YDxcMyEQRKi6gkycVy0(wH5fdbYruWBoa7Iwof4gSG0nKvp4eWM40TBSjoDl8I5fdbYruWBbipLr6Slx34zB9wakw6GgfVZp34vd1qfz5iHtW5y3qwD2eNU95SBO178wOWeZt9R1nRbe7Zn0RKy6mmUA0H8jGaYNdOdjUWOCVGU67kzikjqhsr3rGtCtXTujrNsYV1vYqusGou042RWiGBthai4OKiOsI2R3qbt4fJ230Od5tabKphqhsCHr5EbV5aSlA5uGBWcs3qw9GtaBIt3UXM40TWNoKpbeq(kzaDiPKbruUxWBbipLr6Slx34zB9wakw6GgfVZp34vd1qfz5iHtW5y3qwD2eNU95ZTWdXK6(5A95ha]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20180108.222353, [[deKqnaqiukAtaQpbirJse6uIGDrLggqDmawgPQNHsPPbiCnsr2gGe(gkvJdqkNtqQwhGKmpsrDpbX(ifoiPulKuYdPImrbj6IurTrarFeqsnsbjCsbLBIs2jr9taPAPKkpLYufWwfu9vukSxv)LedgQdJQftspwOjdQlRSzG8zuOrlqNMWRfrZwu3gKDJ0VHmCr64csz5s9CQA6sUor2ok47uHZJIA9csA(Oi7hXhWdCtMdTBMaYjcgiBKVaQiyvKNGlrmPGY4nl2I062nDlpUFxwpyaSdaGEGMl4qhiyhiy)MLUOGNfHkVei6L1Rja30owce1)axgWdCZzkxnp4R1nl2I06wXZJwU(G8QwlOmQ4RwKCE3r5Q5btWatWTevevsrow7gL6E0IG1mbdeGjyGj4wIoVBjGMsHu0tWAqW6jyGj4icLHroOUdkf5yTslrNIJXtru3EqCb1tWAqWGjyGjy4PkbcKBZdvulIZ1x8yscoecwtemWeCIeCeHYWihu3GOMQGaP4qqR1U9G4cQNG1GGbtWmXebZMeCXZJwUbrnvbbsXHGwRDhLRMhmbNWnTvfzrX8nqnYxk(Qfj3TWOWIiVq9nkIUBSqWHZBzo0UDtMdTBazJ8fbBvlsUB6wEC)USEWayha4B6Mhj1X5FGx3Ck4IjzHyyqJwx9gleSmhA3EDz9pWnNPC18GVw3SylsRBTevevsrow7gL6E0IG1iecMTGjyGj4ej4ejyvjqGCBb0CLsjyGj4fAsI00b7MU2pgwZPXPGaPubNYurufiExm3eCcemtmrWjsWfppA5YiVcUwqzuXxOgYDuUAEWemWeCIeSQeiqU9GqTF559koe0ATBpiUG6jynhcbZyeMGzIjcMnjyvjqGC7bHA)YZ7vCiO1AxPucobcobcoHBARkYII5B9GqTF559koe0A9TWOWIiVq9nkIUBSqWHZBzo0UDtMdTB6geQ9lpVNGzdbTwFt3YJ73L1dga7aaFt38iPoo)d86MtbxmjleddA06Q3yHGL5q72RlZ2h4MZuUAEWxRBwSfP1Tej4ej4wIkIkPihRDJsDpArWAecbRhmbdmb7xPOIOsE3sSgqORaePrcwdcgmbNabZeteClrfrLuKJ1UrPUhTiyncHGzlycobcgycwvcei3wanxP0BARkYII5BbroYckJkQzUVUfgfwe5fQVrr0DJfcoCElZH2TBYCODluGCKfugjyTYCFDt3YJ73L1dga7aaFt38iPoo)d86MtbxmjleddA06Q3yHGL5q72RldepWnNPC18GVw3SylsRB(vkQiQK3TeR1dwrFAKG1GGbtWatWTevevsrow7cpqIOOiynhcbdqtemWeClrhbR5qiy2sWatWQsGa5MkYzERGaPaQr(YvkLGbMGztcU45rlxFqEvRfugv8vlsoV7OC18GVPTQilkMVbQr(sXxTi5Ufgfwe5fQVrr0DJfcoCElZH2TBYCODdiBKViyRArYrWjciHB6wEC)USEWayha4B6Mhj1X5FGx3Ck4IjzHyyqJwx9gleSmhA3EDzn9a3CMYvZd(ADZITiTU1surujf5yTBuQ7rlcwZHqWaHMiyMyIGBj68ULaAkfsrteSMjygJW30wvKffZ3qQzrTMx7wyuyrKxO(gfr3nwi4W5TmhA3UjZH2nGUAwuR51UPB5X97Y6bdGDaGVPBEKuhN)bEDZPGlMKfIHbnAD1BSqWYCOD71LbkEGBot5Q5bFTUzXwKw3sKGxOjjsthSBer9OU8krugwjI6rWmXebRkbcKBQiN5TccKcOg5lxPucobcgycwvceixjAquMzfF1JYyf0vkLGbMGHNQeiqUnpurTioxFXJjj4qiynDtBvrwumFZlOWnNrKN7vaj1mFlmkSiYluFJIO7gleC48wMdTB3K5q7MjOWnNrKNdu6jyGuQz(MULh3VlRhma2ba(MU5rsDC(h41nNcUyswigg0O1vVXcblZH2TxxM9h4MZuUAEWxRBwSfP1TwIkIkPihRDHhiruueSgHqWSfmbdmb3s05Dlb0ukKcBjyniygJW30wvKffZ3cIAQccKIdbTwFlmkSiYluFJIO7gleC48wMdTB3K5q7wOa1ucgbIGzdbTwFt3YJ73L1dga7aaFt38iPoo)d86MtbxmjleddA06Q3yHGL5q72Rld0EGBot5Q5bFTUzXwKw3uLabYnPiNfugvG4XGc6CLsjyGj4ejy2KGxOjjsthSBsuUen3RqNdqijkSIdrotWmXebx88OLlJ8k4AbLrfFHAi3r5Q5btWmXebZJLGHPm6GeZtWAecbRNGt4M2QISOy(gOg5lFK5k4Ufgfwe5fQVrr0DJfcoCElZH2TBYCODdiBKV8rMRG7MULh3VlRhma2ba(MU5rsDC(h41nNcUyswigg0O1vVXcblZH2Txxo0FGBot5Q5bFTUzXwKw34XsWWugDqI5jyncHG1FtBvrwumFJXmpk4zfomdCAC3cJclI8c13Oi6UXcbhoVL5q72nzo0UbuN5rbptWAdZaNg3nDlpUFxwpyaSda8nDZJK648pWRBofCXKSqmmOrRREJfcwMdTBVUmaWpWnNPC18GVw3SylsRB8yjyykJoiX8eSgHqW6VPTQilkMV1dc1(LN3R4qqR13cJclI8c13Oi6UXcbhoVL5q72nzo0UPBqO2V88EcMne0AnbNiGeUPB5X97Y6bdGDaGVPBEKuhN)bEDZPGlMKfIHbnAD1BSqWYCOD71Lba4bU5mLRMh816MfBrADRLOIOskYXAx4bseffbRbbRxtemtmrWTeDeSgemBVPTQilkMVHuZIAnV2TWOWIiVq9nkIUBSqWHZBzo0UDtMdTBaD1SOwZRrWjciHB6wEC)USEWayha4B6Mhj1X5FGx3Ck4IjzHyyqJwx9gleSmhA3EDza6FGBot5Q5bFTUzXwKw3AjQiQKICS2nk19OfbRzcMTGjyGj4wIoVBjGMsHu0tWAqWmgHVPTQilkMVnOuKJ1kTeDkogpfrVfgfwe5fQVrr0DJfcoCElZH2TBYCODZzOuKJ1eSoj6iy2y8ue9MULh3VlRhma2ba(MU5rsDC(h41nNcUyswigg0O1vVXcblZH2TxVUfkhiUuUUwV(b]] )

    storeDefault( [[SimC Frost: bos pooling]], 'actionLists', 20180108.222353, [[di0ttaqiqrBIuPprHOmkqLtbkTkqbTlsAyKQogiwMuYZeKmnuuDnbKTrHW3ivmobu6COOW6OqeZJcP7bk0(OeoiLOfsH6HcWePqKUOa1gfK6JuiQgPakoPG4MOWojLFkGQLsj9uQMkLQTkq(kkkAVq)LIgmIdRyXO0JLyYs6YQ2mi9zky0KWPj8AkLzl0TLQDJQFR0WjrhhuGLd8CIMUORlfBhf57sPopOQ1JIsZxqTFKgHG2rxB6hDx0dGscnyLPrcLWUskr5Urb3a6EbiuMOJU1h)ipQ1speDGaPvGvvpZG56WCDq3v(IyIcMDsXYrTwbcc6wwsXYLODudcAh9G5dB8v0y09cqOmrpN45PQHjvCGGBWuMlORE(WgFfDlzfrrcp6G3xG8XlLMTf88a0dHxfLjxa68LF0zS1GgG20p6ORn9JU13xG8XlLucZuWZdq36JFKh1APhIoq0JU1l3gq5s0oMOhGIxSXyz69ZtKfDgBvB6hDmrTwOD0dMpSXxrJr3laHYeD2gOqvbI(vBusj6sjGg(LQPOFZCnzoLyukbokXqPsjWqkPfLal6wYkIIeE0vSTJcUbt24it0dHxfLjxa68LF0zS1GgG20p6ORn9JEGzBhfCduIXXrMOB9XpYJAT0drhi6r36LBdOCjAht0dqXl2ySm9(5jYIoJTQn9JoMOwOq7OhmFyJVIgJUxacLj6Gg(LQPOFZCnnckXOuIHsLs0LsGjLKt88u1WKkoqWnykZf0vpFyJVIULSIOiHh9LnkYdM8OhcVkktUa05l)OZyRbnaTPF0rxB6h9aNnkYdM8OB9XpYJAT0drhi6r36LBdOCjAht0dqXl2ySm9(5jYIoJTQn9JoMOgZr7OhmFyJVIgJUxacLj6Gg(LQPOFZCnzoLyukXqPsj6sjWrjLDJ1TnxLf8jvyUqnLcEfmgw5OcEFeCjLybLONschMsanCrXu52(a16HkkIKsSagPKqPNsGfDlzfrrcp6lBuKhm5rpeEvuMCbOZx(rNXwdAaAt)OJU20p6boBuKhm5Pe4Gal6wF8J8Owl9q0bIE0TE52akxI2Xe9au8IngltVFEISOZyRAt)OJjQfi0o6bZh24ROXO7fGqzIoOHlkMk32hOwpurrKuIrPKarj6sjYNMSlVrQMIdGWmmzUYcLybLONs0Lsk7gRBBUkl4tQWCHAkf8kymSYrf8(i4skXckrpLOlLahLatkjN45PQuXK5bcUbtzce2Uu98Hn(kLeomLupBduOQGHzxGOCvzofBuIrPKarjHdtjLDJ1TnxLf8jvyUqnLcEfmgw5OcEFeCjLybLyeucSOBjRiks4rhkyLPPmbcBh9q4vrzYfGoF5hDgBnObOn9Jo6At)OhAWktkXtGW2r36JFKh1APhIoq0JU1l3gq5s0oMOhGIxSXyz69ZtKfDgBvB6hDmrnJaTJEW8Hn(kAm6EbiuMOZ2afQkq0VAJskrxk5WGgHsLVQQ8a5z6GHxU5c1mvCZZUCZ(as4bOBjRiks4rh8(cKpEP0STGNhGEi8QOm5cqNV8JoJTg0a0M(rhDTPF0T((cKpEPKsyMcEEaLaheyr36JFKh1APhIoq0JU1l3gq5s0oMOhGIxSXyz69ZtKfDgBvB6hDmrnDq7OhmFyJVIgJUxacLj6SnqHQce9R2OKs0LsGJsyBGcvf8(cKpEP0STGNhO2OKschMsk7gRBBUk49fiF8sPzBbppqf8(i4skXckXqPsjHdtjWrjWKsomOrOu5RQkpqEMoy4LBUqntf38Sl3SpGeEaLOlLatkjN45PQHjvCGGBWuMlORE(WgFLsGLsGfDlzfrrcp6k22rb3GjBCKj6HWRIYKlaD(Yp6m2AqdqB6hD01M(rpWSTJcUbkX44itkboiWIU1h)ipQ1speDGOhDRxUnGYLODmrpafVyJXY07NNil6m2Q20p6yIAbw0o6bZh24ROXO7fGqzIomPe2gOqvbI(vBusj6sjWKsGJsYjEEQAysfhi4gmL5c6QNpSXxPeDPeysjWrjLDJ1Tnxf8(cKpEP0STGNhOcEFeCjLybLahLyOuPeyiL0IsGLschMsan8tjwqjmNsGLsGLs0Lsan8tjwqjHcDlzfrrcp6lBuKhm5rpeEvuMCbOZx(rNXwdAaAt)OJU20p6boBuKhm5Pe4Abl6wF8J8Owl9q0bIE0TE52akxI2Xe9au8IngltVFEISOZyRAt)OJjQXmq7OhmFyJVIgJUxacLj6Wrjhg0iuQ8v1YYLliLMLnwnll4us4WucBduOQkfX4amxOMqbRmvBusjWsj6sjSnqHQ2WvSr4nLj4CdPc1gLuIUus9SnqHQcgMDbIYvL5uSrjWiLei0TKvefj8Olf8kymSYrAcTbap6HWRIYKlaD(Yp6m2AqdqB6hD01M(r3f8kymSYXitsjHUbap6wF8J8Owl9q0bIE0TE52akxI2Xe9au8IngltVFEISOZyRAt)OJjQbrpAh9G5dB8v0y09cqOmrh0WfftLB7duRhQOiskXOusO0tj6sjWrjWKsYjEEQkvmzEGGBWuMaHTlvpFyJVsjHdtj1Z2afQkyy2fikxvMtXgLyukjqus4Wusz3yDBZvzbFsfMlutPGxbJHvoQG3hbxsjwqjGg(LQPOFZCnzoLal6wYkIIeE0HcwzAktGW2rpeEvuMCbOZx(rNXwdAaAt)OJU20p6HgSYKs8eiSDkboiWIU1h)ipQ1speDGOhDRxUnGYLODmrpafVyJXY07NNil6m2Q20p6yIAqGG2rpy(WgFfngDVaekt0zBGcv1MigfCdM9POqWVAJskrxkbokbMuYHbncLkFv12gtbyKM83g62WRMTfXiLeomLmLuW0np)DXLuIfWiL0IsGfDlzfrrcp6qbRmLf4tfh9q4vrzYfGoF5hDgBnObOn9Jo6At)OhAWktzb(uXr36JFKh1APhIoq0JU1l3gq5s0oMOhGIxSXyz69ZtKfDgBvB6hDmrniTq7OhmFyJVIgJUxacLj6tjfmDZZFxCjLybmsjTq3swruKWJUH4uet0CQmn8YrpeEvuMCbOZx(rNXwdAaAt)OJU20p6g5XPiMiLyzLPHxo6wF8J8Owl9q0bIE0TE52akxI2Xe9au8IngltVFEISOZyRAt)OJjQbjuOD0dMpSXxrJr3laHYe9PKcMU55VlUKsSagPKwOBjRiks4rh8(cKpEP0STGNhGEi8QOm5cqNV8JoJTg0a0M(rhDTPF0T((cKpEPKsyMcEEaLaxlyr36JFKh1APhIoq0JU1l3gq5s0oMOhGIxSXyz69ZtKfDgBvB6hDmrnimhTJEW8Hn(kAm6EbiuMOpLuW0np)DXLuIfWiLek0TKvefj8OdfSYuwGpvC0dHxfLjxa68LF0zS1GgG20p6ORn9JEObRmLf4tfNsGdcSOB9XpYJAT0drhi6r36LBdOCjAht0dqXl2ySm9(5jYIoJTQn9JoMOgKaH2rpy(WgFfngDVaekt0HJsk7gRBBUk49fiF8sPzBbppqf8(i4skXOucCuIHsLsGHuslkbwkjCykHTbkuvdtQ4ab3GPmxqxvMtXgLaJuce9ucSuIUusz3yDBZvzbFsfMlutPGxbJHvoQG3hbxsjwqjGg(LQPOFZCnzoLOlLKt88u1WKkoqWnykZf0vpFyJVsj6sjWrjWKsYjEEQkvmzEGGBWuMaHTlvpFyJVsjHdtj1Z2afQkyy2fikxvMtXgLyukjqus4Wusz3yDBZvzbFsfMlutPGxbJHvoQG3hbxsjwqjgbLal6wYkIIeE0HcwzAktGW2rpeEvuMCbOZx(rNXwdAaAt)OJU20p6HgSYKs8eiSDkbUwWIU1h)ipQ1speDGOhDRxUnGYLODmrpafVyJXY07NNil6m2Q20p6yIAqmc0o6bZh24ROXO7fGqzIomPe2gOqvbI(vBusj6sjWrjWKsYjEEQAysfhi4gmL5c6QNpSXxPKWHPKYUX62MRcEFbYhVuA2wWZdubVpcUKsSGsmuQucSOBjRiks4rFzJI8Gjp6HWRIYKlaD(Yp6m2AqdqB6hD01M(rpWzJI8GjpLaxOGfDRp(rEuRLEi6arp6wVCBaLlr7yIEakEXgJLP3pprw0zSvTPF0Xe1GOdAh9G5dB8v0y09cqOmrVSBSUT5QSGpPcZfQPuWRGXWkhvW7JGlPelOeqd)s1u0VzUMmNs0LsGJsGjLKt88uvQyY8ab3GPmbcBxQE(WgFLschMsQNTbkuvWWSlquUQmNInkXOusGOKWHPKYUX62MRYc(KkmxOMsbVcgdRCubVpcUKsSGsmckbw0TKvefj8OdfSY0uMaHTJEi8QOm5cqNV8JoJTg0a0M(rhDTPF0dnyLjL4jqy7ucCHcw0T(4h5rTw6HOde9OB9YTbuUeTJj6bO4fBmwME)8ezrNXw1M(rhtmr3i9qNMyIgJjIa]] )

    storeDefault( [[SimC Frost: cold heart]], 'actionLists', 20180108.222353, [[dOtmhaGEKu0MOk2Lk9AQs7djz2ImFKu6Mi0TPWojYEb7gL9RQrrummKyCqrP1bff)wXGHmCeCqQQCkIkhtsohskSqIQwQOyXiA5u6HIspvyzIkpNktekQAQuvMSkMUsxekY3GsEgvv11POncfv2QOQ2SeBxsX9ikDAcFgk18evXHL6XOA0i1FHQtkP67IQ01OQkNhkmnjL2gsQUmPHkWhesTHcrimY(imNDClM5r8jDEeT22fIGBfewiGiJM02PGuokvyvvLdZEPqnQfRAXcIGGYfDsqn7vmmqkN)QGWp(kgMd8bsvGpiWeRjt6bKhIGBfewiinlLlFshCATT71Tn37JK9r5O8ippI0SuUMm6jHbUBTkd7L(As4rEEeFM0zYl7sqKsTfFk4f742RvnAbZ9iQEe1HWpsrsSyabNUfmh(uWfCfI6SJG37yHGnmfcIZj)2k1gkeqi1gkezPBbZ9OP8O6CfImAsBNcs5OuHvffiYOUX0Yvh4dwiYsRCVeNAudLTajeeNJuBOqaliLd8bbMynzspG8qeCRGWcbPzPC5t6GtRTDVUT5EFevY(OkQ)ippsMhXNjDM8YUdzsSQTxXWUwTpy8ippA7KY27qMeRA7vmSRYAYKEEKCpYZJinlLlbrk1w8PGxSJBVMeGWpsrsSyabNUfmh(uWfCfI6SJG37yHGnmfcIZj)2k1gkeqi1gkezPBbZ9OP8O6C9rYujhez0K2ofKYrPcRkkqKrDJPLRoWhSqKLw5Ejo1OgkBbsiiohP2qHawqY)GpiWeRjt6bKhIGBfewiinlLlbrk1w8PGxSJBVMeEKNhrAwkxcIuQT4tbVyh3ETQrlyUhLNhHn)8ippsMhrAwkx(Ko40AB3RBBU3hrLSpQQ6rul1(izEePzPC5t6GtRTDVUT5EFevY(OkkpYZJC6Itomt3DfQnhf8AjWFevpIYJK7rYbHFKIKyXacoDlyo8PGl4ke1zhbV3XcbBykeeNt(TvQnuiGqQnuiYs3cM7rt5r156JKjNCqKrtA7uqkhLkSQOarg1nMwU6aFWcrwAL7L4uJAOSfiHG4CKAdfcybPAbFqGjwtM0dipeb3kiSqqAwkx(Ko40AB3RBBU3hrLSpQcRh55rKMLY1KrpjmWDRvzyV0xtcpYZJinlLRjJEsyG7wRYWEPVw1Ofm3JYZJWMFEKNhXNjDM8YUeePuBXNcEXoU9AvJwWCpIQhrDi8JuKelgqWPBbZHpfCbxHOo7i49owiydtHG4CYVTsTHcbesTHcrw6wWCpAkpQoxFKm(xoiYOjTDkiLJsfwvuGiJ6gtlxDGpyHilTY9sCQrnu2cKqqCosTHcbSGK)aFqGjwtM0dipeb3kiSqqAwkx(Ko40AB3RBBU3hrLSpQY)pYZJinlLRjJEsyG7wRYWEPVMeEKNhTDsz71r37QwbdBC3AfEv3vznzspq4hPijwmGGt3cMdFk4cUcrD2rW7DSqWgMcbX5KFBLAdfciKAdfIS0TG5E0uEuDU(izQvoiYOjTDkiLJsfwvuGiJ6gtlxDGpyHilTY9sCQrnu2cKqqCosTHcbSGe1bFqGjwtM0dipeb3kiSqqAwkx(Ko40AB3RBBU3hrLSpQ2h55rBBXw37kmu8DWpc9r5r2hHn)aHFKIKyXacoDlyo8PGl4ke1zhbV3XcbBykeeNt(TvQnuiGqQnuiYs3cM7rt5r156JKXFYbrgnPTtbPCuQWQIcezu3yA5Qd8blezPvUxItnQHYwGecIZrQnuiGfwiW8APntlipSaa]] )


    storeDefault( [[Frost Primary]], 'displays', 20171128.094747, [[dWd4gaGEPkVevWUKkOxlvQzQsy2k6WsUjsQEmsDBv0ZqsyNu1Ef7MO9tq)ufgMc(TQoNubgkknycmCeoOu60K6ye64OswivAPOsTyk1YP4HuspfSmPQwNkrnrPImvOmzkX0v6Ik0vrf6YqUoI2Ok1wvjInJQ2ou1hLk5ZqLPHK03LIrIKY4qs0OrX4vjDsK4wsf6AOIopv8CswRkr6Bsf1rmybOlIv)Y7xUW6mrbo4i2fu8Jb2YGdTS4zJDatjXHSYGO7oUb4IerIANACYtKCdqhW5GNxHwRfXQFPk(Haxp45vO1ArS6xQIFiaHrFwghk0Ve09qXZ5qGtTSDmEQiaxKisKfRfXQFPkUbCo45vOfRm4qRk(HakMVbA0lnt7yCdOy(MwY9JBan9lbIIwlXfpNb2YGdTTsAM3eW9ad7G6CtPlQHfWj3DKk7Go3FqKtQk2bC2Nkg68q47iv5mW14hcOy(gSYGdTQ4gOB7wjnZBcGDWYnLUOgwaT0IMU230kPzEtaUP0f1WcqxeR(LTsAM3eW9ad7G6baceTUM6E1QFz895umGI5BaS4gGlsejQtAdIE1Vma3u6IAybKKNuOFPkEQgqrGMZ7zPyS(Z3eSav8IbmXlgax8IbSJxmBafZ3yTiw9lvXoW1dEEfABjnv8dbkstH5qGcytYZh4SU2sUF8dbSN6E96A(nTZzSdutcMcy(gw8JXlgOMemL1)0Uww8JXlgOti(ICUXnqnBkhflE24gaVwPT1t96G5qGcyhGUiw9lBNACYawh9yJChWIwrmlhmhcuGkGPK4qyoeOaLTEQxNafPPOUwIIBGUTVF5c6EO4f7hOMemfwzWHww8SXlgWGMbSo6Xg5oGIanN3ZsXe7a1KGPWkdo0YIFmEXaCrIirwOiTOPR9nQ4gW6t4iua2h428QvOG2JXaNAzl5(Xpeyldo0E)YfwNjkWbhXUGIFmGfeFro3w2lca6tRcfCBE1EzHcSG4lY5gW5GNxHwo4QIVJIbumFd0OxAMwY9JBGAsWuTZMYrXINnEXaA6xEP)FgViNbim6ZY4C)Yf09qXl2paHbr)N212YEraqFAvOGBZR2lluaHbr)N21gG)LBawmHcGsQekWxgZ3e4SU2og)qaUirKiluOFjO7HINZHaBzWHww8JXoG9u3RxxZVjUbumFdlE24g46bpVcTuKw001(gv8dbCo45vOLI0IMU23OIFiWwgCO9(LBawmHcGsQekWxgZ3e46bpVcTyLbhAvXpeqX8nTKMIIK)JDafZ3qrArtx7BuXnGZbpVcTTKMk(Ha1SPCuS4hJBafZ3WIFmUbumFt7yCdq)N21YINn2bkstbeO5KsNIFiqrAQwjnZBc4EGHDq9lgVXcuKMIIK)XCiqbSj55dCQLaw8db2YGdT3VCbDpu8I9dWfPMU7lrRG1zIcubOlIv)Y7xUbyXekakPsOaFzmFtGAsWuw)t7AzXZgVyGrzzprwIBaL(KyIApgJVFGUTVF5gGftOaOKkHc8LX8nbQjbt1oBkhfl(X4fdq)N21YIFm2bOlIv)Y7xUGUhkEX(bumFdhqo2APfTeNkUb4gnrLcfF)bXolk2Nk7WHbrQoig46bpVcTCWvfVyGZ6kGfVyGAsWuaZ3WINnEXaCrIirwUF5c6EO4f7hOB77xUW6mrbo4i2fu8Jb4IerISWbxvCd4RtuGBZRwHcyn6ZY4eOinfhL6naXSCqMSja]] )

    storeDefault( [[Frost AOE]], 'displays', 20171128.094747, [[dSJYgaGEPIxIuXUqkWRLImtPsMTIUjHIdl52QIVHuK2jv2Ry3eTFuLFkvnmfACif0ZqkKHIkdMqgouDqQYNHIJrHJJu1cvWsjuTyuA5u6HsHNcEmswhsrnrcLMQQAYOQMUsxukDvKsDzixhrBekTvKc1Mjy7i4JsrDAsnnKs8DQQrIuPLPkz0Oy8QsDse6wiL01Kk15PONtYArkIFRYXi)auf(Qpj2tUWAorb6P9VlIU2aBzXGwocCHnGTKyqnyqunLHaStDNonpp)meWSxqqH2gf(QpPkUXaV7feuOTrHV6tQIBma9KiseFIuNe0DqX19yGhT0RnoAua6jrKi(nk8vFsvgcy2liOq7VSyqRkUXakMZh81lfJxBydOyoFpY9cBafZ5d(6LIXJCVmeyllg06jPyoBGH()VxmItSz6(dyghT(ACmGzVGGcT0zqfhTAeqXC()YIbTQmeOjwpjfZzd875eNyZ09hql5RPQ9SEskMZgqCInt3FaQcF1N0tsXC2ad9)FVyca4ikDn1DQvFY4E1TrafZ5d)meGEsejsSAlIA1NmG4eBMU)asYhIuNufhTeqHJMtSZsX04MNn)avCgbyJZiaM4mcyJZiBafZ53OWx9jvHnW7EbbfA9iTvCJbksB9nXrbyjfec8uV9i3lUXaStDNonppFV5mSbQjotbmNphH24mcutCMQX9WwlhH24mciwKqro3meOM(LPIJaxgcqqR0S6PEn)M4OaSbOk8vFsVPgJmqJw3Vv8a81k8zz(nXrbOcyljg03ehfOy1t9AgOiTLy0sugc0el2tUGUdkoJxbQjot9llg0YrGloJaw0mqJw3Vv8akC0CIDwkMWgOM4m1VSyqlhH24mcqpjIeXNOKVMQ2ZQYqGghUjpr)law7PwEI86Bd4QhuaS2tT8e513gyllg0I9KlSMtuGEA)7IORnaFKqroxpUUca6Ng8eH1EQLM5jIpsOiNBGMyXEYfwZjkqpT)Dr01gqtDsaVO0smX1DGAIZuEt)YuXrGloJa1eNPaMZNJaxCgbWT6NYAI9KlO7GIZ4vaClI6EyR1JRRaG(PbpryTNAPzEIWTiQ7HT2ap1B4hNrGN6TxBCJbE3liOqlDguXzeyllg0YrOnSbehnrLcf3RrdAQHXlAinyC0GwgncOyoFocCziGI58PdYKvl5RLyuziavHV6tI9KlO7GIZ4vaQ7HTwocTHnqnXzkVPFzQ4i0gNrGMyXEYna3NNiOKkEICL1E(bumNprjFnvTNvLHaM9cck06rAR4gdut)YuXrOndbumNVxBydOyoFocTzia19WwlhbUWgOM4mvJ7HTwocCXzeOiTLNKI5Sbg6))EX0vl2Fa6j1unrJ1kynNOaSbE0s4h3yGTSyql2tUGUdkoJxbksBrukCFtCuawsbHauf(Qpj2tUb4(8ebLuXtKRS2ZpqrAlahnNefBCJbALf7eXpdbu6h8jYRVnUxbumNVhPTikfUWg4DVGGcT)YIbTQ4gdSLfdAXEYna3NNiOKkEICL1E(bm7feuOLOKVMQ2ZQIBmW7EbbfAjk5RPQ9SQ4gdqpjIe5n1yKpi5gGkaUv)uwtIuNe0DqX19yaHtUb4(8ebLuXtKRS2ZpGM6K0K7EIZO7a0tIir8XEYf0DqXz8kW74gdqpjIeXNodQme4rl9i3lUXafPTOTuVbWNLjYMnb]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )


end

