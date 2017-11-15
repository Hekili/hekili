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

            state.pet.valkyr_battlemaiden.expires = state.last_valkyr > 0 and state.last_valkyr + 23 or 0
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
        addAura( "dark_succor", 178819 )
        addAura( "death_and_decay", 188290, "duration", 10 )
        addAura( "defile", 156004, "duration", 10 )
        addAura( "defile_buff", 218100, "duration", 5, "max_stack", 10 )
        addAura( "festering_wound", 194310, "duration", 24, "max_stack", 8 )
        addAura( "frost_fever", 55095, "duration", 24 )
        addAura( "hungering_rune_weapon", 207127, "duration", 12 )
        addAura( "icebound_fortitude", 48792, "duration", 8 )
        addAura( "icy_talons", 194879, "duration", 6, "max_stack", 3 )
        addAura( "killing_machine", 51124, "duration", 10 )
        addAura( "mastery_dreadblade", 77515 )
        addAura( "mastery_frozen_heart", 77514 )
        addAura( "necrosis", 207346, "duration", 30 )
        addAura( "on_a_pale_horse", 51986 )
        addAura( "obliteration", 207256, "duration", 10 )
        addAura( "outbreak", 196782, "duration", 6, "tick_time", 1.5 )
        addAura( "path_of_frost", 3714, "duration", 600 )
        addAura( "perseverance_of_the_ebon_martyr", 216059 )
        addAura( "pillar_of_frost", 51271, "duration", 20 )
        addAura( "razorice", 50401, "duration", 15, "max_stack", 5 )
        addAura( "remorseless_winter", 196770, "duration", 8, "friendly", true )
        addAura( "rime", 59052, "duration", 15 )
        addAura( "runic_corruption", 51462 )
        addAura( "runic_empowerment", 81229 )
        addAura( "soul_reaper", 130736, "duration", 5 )
        addAura( "sudden_doom", 81340, "duration", 10, "max_stack", 1 )
            modifyAura( "sudden_doom", "max_stack", function( x ) return x + ( artifact.sudden_doom.enabled and 1 or 0 ) end )
        addAura( "temptation", 234143, "duration", 30 )
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
            -- aura = 'virulent_plague'
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20171115.094707, [[deKdBaqibWIiuH2KKYOiv6uKQSlszyeYXevltGEMkLMgHkDnrH2Mkf9nvQghHk4CQuO1PsbMhHQUNKO9jk6GeklKuXdLKMOOGlsQQnkaXhjurDsQsntvki3uLStK6NeQilLQ4PuMkvLRkaPTkG2RYFvHbJYHLAXi8yrMmvUmyZc6ZuvnAe1Pj51iYSL42eSBO(nKHRIoUaulNONl00v11rY2Pk57IsNxs16vPGA(sc7hvV85BMLKQZF2m6waMzkHQCwaftgvQFd4m)agKQ0mpqb6im6GIYVNlkxKwW8G3mygNzNqs1f1nC)keE0bZyWzILEfchNVrNpFZ0h3efWnDMzjP68N9i)(lGwcHkouwCKZQXz6YzbGZGaMsDEcoT8BVl6Eg5SACMKcRshNOSGuZbHQK65mXZz3kIZ0BMyeQI6RpZ1sshTKq9GCM3yNk1psodJWWSlKlWws3cWSz0TamldTKeNjMKq9GCMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hDW5BM(4MOaUPZmljvN)miGPuNNGtl)27IUNroRgN5acQWqTqi(GuH9FKfrHDAXVtK4SmRKZUjNvJZ(Ua4xZ1sshTKq9GudWnrbCZeJqvuF9z9jk1L6NryM3yNk1psodJWWSlKlWws3cWSz0TamtStuQl1pJWmpqb6im6GIYVNlAMhiIOKjioF7NvLmKiDH8cea8pIzxihDlaZ2p6BNVz6JBIc4MoZSKuD(ZEKF)fqlHqfhkloYz14mD5miGPuNNGtl)27IUNroRgNjPWQ0Xjkli1CqOkPEot8C2TI4SACwcHkouwSMRLKoEzJJHiPq)kewtccTch5mXZzb5m9MjgHQO(6ZCTK0rljupiN5n2Ps9JKZWimm7c5cSL0TamBgDlaZYqljXzIjjupi5mDZ1BMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hT4oFZ0h3efWnDMzjP68N9i)(lGwcHkouwCKZQXz6YzskmWzIVso7wotVzIrOkQV(SiLGacF4VL(r1lWmVXovQFKCggHHzxixGTKUfGzZOBbyMrjiGWCM4Cl9JQxGzEGc0ry0bfLFpx0mpqerjtqC(2pRkzir6c5fia4FeZUqo6waMTF0zC(MPpUjkGB6mZss15pJGkmuJctgvQFeFjG9)K1Oo5SACgbvyOwcvChKHw(AXVtK4Sm5S8BCMyeQI6RplrUv44bk8qLGzEJDQu)i5mmcdZUqUaBjDlaZMr3cWSQKBfoYzOqoZ7emZduGocJoOO875IM5bIikzcIZ3(zvjdjsxiVaba)Jy2fYr3cWS9J(MZ3m9XnrbCtNzwsQo)zpYV)cOLqOIdLfh5SACMUCgeWuQZtWPLF7Dr3ZiNvJZsiuXHYI1CTK0XlBCmejf6xHWAsqOv4iNjEolxeNvJZKuyGZeFLC2TCMEZeJqvuF9zrkbbe(WFl9JQxGzEJDQu)i5mmcdZUqUaBjDlaZMr3cWmJsqaH5mX5w6hvVaCMU56nZduGocJoOO875IM5bIikzcIZ3(zvjdjsxiVaba)Jy2fYr3cWS9J((8ntFCtua30zMLKQZFMdiOcd1cH4dsf2)rwef2Pf)orIZYSso7MCwnolHqfhklwRprPUu)mcAsqOv4iNjEotCNjgHQO(6ZIiQYHe6tqoZBStL6hjNHryy2fYfylPBby2m6waMziQcN5b6tqoZduGocJoOO875IM5bIikzcIZ3(zvjdjsxiVaba)Jy2fYr3cWS9JwCy(MPpUjkGB6mZss15pZbeuHHAHq8bPc7)ilIc70IFNiXzzwjNDZzIrOkQV(S(eL6s9ZimZBStL6hjNHryy2fYfylPBby2m6waMj2jk1L6NrGZ0nxVzEGc0ry0bfLFpx0mpqerjtqC(2pRkzir6c5fia4FeZUqo6waMTF0348ntFCtua30zMLKQZFMKcRshNOSGuZbHQK65mXZz5IMjgHQO(6ZCq)KpsivzM3yNk1psodJWWSlKlWws3cWSz0Tamldq)K5SQivzMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hDUO5BM(4MOaUPZmljvN)SaWzFxa8R5AjPJwsOEqQb4MOaooRgNrqfgQfPCoaF4qibnQtoRgNfaoJGkmuddjjkQIAuNCwnotsHbot8vYz3otmcvr91N5G(jFKqQYmVXovQFKCggHHzxixGTKUfGzZOBbywgG(jZzvrQcNPBUEZ8afOJWOdkk)EUOzEGiIsMG48TFwvYqI0fYlqaW)iMDHC0TamB)OZZNVz6JBIc4MoZSKuD(Z(Ua4xZ1sshTKq9GudWnrbCCwnoJGkmuls5Ca(WHqcAuNCwnolHqfhklwZ1sshTKq9GutccTch5Sm5SmYz14mjfg4mXxjND7mXiuf1xFMd6N8rcPkZ8g7uP(rYzyegMDHCb2s6waMnJUfGzza6NmNvfPkCMUb1BMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hDEW5BM(4MOaUPZmljvN)mhqqfgQfcXhKkS)JSikStl(DIeNjEo7MCwnolHqfhklwRprPUu)mcAsqOv4iNj(k5SBotmcvr91NfcXhKkS)J4lvKGzEJDQu)i5mmcdZUqUaBjDlaZMr3cWSaceFqQW(5m7LksWmpqb6im6GIYVNlAMhiIOKjioF7NvLmKiDH8cea8pIzxihDlaZ2p68BNVz6JBIc4MoZSKuD(ZCabvyOwieFqQW(pYIOWoT43jsCwMvYz3otmcvr91NfruLdj0NGCM3yNk1psodJWWSlKlWws3cWSz0TamZqufoZd0NGKZ0nxVzEGc0ry0bfLFpx0mpqerjtqC(2pRkzir6c5fia4FeZUqo6waMTF05I78ntFCtua30zMLKQZFMdiOcd1IiQYHe6tqQrDYz14SaWzoGGkmuleIpivy)hzruyNg15mXiuf1xFwieFqQW(pIVurcM5n2Ps9JKZWimm7c5cSL0TamBgDlaZciq8bPc7NZSxQibCMU56nZduGocJoOO875IM5bIikzcIZ3(zvjdjsxiVaba)Jy2fYr3cWS9JopJZ3m9XnrbCtNzwsQo)zoGGkmulIOkhsOpbPg1jNvJZCabvyOwieFqQW(pYIOWoT43jsCwMvYz5ZeJqvuF9zXeIs6hoIVurcM5n2Ps9JKZWimm7c5cSL0TamBgDlaZSeIs6h4m7LksWmpqb6im6GIYVNlAMhiIOKjioF7NvLmKiDH8cea8pIzxihDlaZ2p68BoFZ0h3efWnDMzjP68N5acQWqTiIQCiH(eKAuNCwnoZbeuHHAHq8bPc7)ilIc70IFNiXzzwjNLptmcvr91NLkDwf2)rKC7qzJZ8g7uP(rYzyegMDHCb2s6waMnJUfGzvlDwf2pNzKBhkBCMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hD(95BM(4MOaUPZmXiuf1xFMdcvfyM3yNk1psodJWWSlKlWws3cWSz0TamldqOQaZ8afOJWOdkk)EUOzEGiIsMG48TFwvYqI0fYlqaW)iMDHC0TamB)OZfhMVz6JBIc4MoZSKuD(Z60R8coamiOGiNLzLCwWzIrOkQV(SuxkhD6vi8rrf)zvjdjsxiVaba)Jy2fYr3cWmtjuLZcOyYOs9BaNjM4K(ZUqUaBjDlaZM5n2Ps9JKZWimmJUfGzv7sHZel9keMZUHuXFMys)Xz4waQuC0ucv5SakMmQu)gWzIjoPV44mpqb6im6GIYVNlAMhiIOKjioF7NzKrzVqovOcKXPZm7LQ0xLmKinD2p68BC(MPpUjkGB6mZss15pZbeuHHAHq8bPc7)ilIc70IFNiXzIVsoliNvJZ0LZCabvyOwieFqQW(pYIOWoT43jsCM4RKZexoRIk4mD5mcQWqnIIYp5hChskmCKf6tewJ6KZQOco77cGFTuhFL)(rsna3efWXz6Xz6Xz14mjfwLoorzbPMdcvj1ZzzYzzKZQXz6YzskSkDCIYcsnheQsQNZYKZcElNvrfCwa4SVla(1sD8v(7hj1aCtuahNP3mXiuf1xFwieFqQW(pIVurcM5n2Ps9JKZWimm7c5cSL0TamBgDlaZciq8bPc7NZSxQibCMUb1BMhOaDegDqr53ZfnZderuYeeNV9ZQsgsKUqEbca(hXSlKJUfGz7hDqrZ3m9XnrbCtNzwsQo)zbGZiOcd1WqsIIQOg1jNvJZ(Ua4xddjjkQIAaUjkGJZQXzskme1ELaC8OdXLZYKZ8NCZeJqvuF9zoOFYhjKQmZBStL6hjNHryy2fYfylPBby2m6waMLbOFYCwvKQWz6EREZ8afOJWOdkk)EUOzEGiIsMG48TFwvYqI0fYlqaW)iMDHC0TamB)OdMpFZ0h3efWnDMzjP68NPlNrqfgQHHKefvrnQtoRIk4mcQWqnkmzuP(r8La2)twJ6KZQOcotsHbolZk5SGCMECwnoZbeuHHAHq8bPc7)ilIc70IFNiXzzwjNLZz14mD5mhqqfgQfcXhKkS)JSikStl(DIeNLzLC2TCwfvWzbGZ0LZ(Ua4xl1Xx5VFKudWnrbCCwfvWzqatPopbN2tgou44lPspsgpcruYN8rbIreMZ0JZ0JZQXzskSkDCIYcsnheQsQNZYKZUroRgNPlNjPWQ0Xjkli1CqOkPEoltol4TCwfvWzbGZ(Ua4xl1Xx5VFKudWnrbCCMEZeJqvuF9zXeIs6hoIVurcM5n2Ps9JKZWimm7c5cSL0TamBgDlaZSeIs6h4m7LksaNPBUEZ8afOJWOdkk)EUOzEGiIsMG48TFwvYqI0fYlqaW)iMDHC0TamB)OdgC(MPpUjkGB6mZss15ptxoJGkmuddjjkQIAuNCwfvWzeuHHAuyYOs9J4lbS)NSg1jNvrfCMKcdCwMvYzb5m94SACMdiOcd1cH4dsf2)rwef2Pf)orIZYSsolNZQXz6YzoGGkmuleIpivy)hzruyNw87ejolZk5SB5SkQGZcaNbbmL68eCApz4qHJVKk9iz8ierjFYhfigryotpoRgNjPWQ0Xjkli1CqOkPEolto7gNjgHQO(6ZsLoRc7)isUDOSXzEJDQu)i5mmcdZUqUaBjDlaZMr3cWSQLoRc7NZmYTdLnYz6MR3mpqb6im6GIYVNlAMhiIOKjioF7NvLmKiDH8cea8pIzxihDlaZ2p6G3oFZ0h3efWnDMzjP68N9DbWVwKC7qzpu4qQOcH1aCtuahNvJZ(Ua4xZ1sshTKq9GudWnrbCCwnolaCgbvyOMRLKoEzJJHiPq)kewJ6KZQXzjeQ4qzXAUws6OLeQhKAsqOv4iNLjNLlAMyeQI6RpZb9t(iHuLzEJDQu)i5mmcdZUqUaBjDlaZMr3cWSma9tMZQIufotxXvVzEGc0ry0bfLFpx0mpqerjtqC(2pRkzir6c5fia4FeZUqo6waMTF0bf35BM(4MOaUPZmljvN)SVla(1IKBhk7HchsfviSgGBIc44SACwa4SVla(1CTK0rljupi1aCtuahNvJZcaNrqfgQ5AjPJx24yisk0VcH1OoNjgHQO(6ZCq)KpsivzM3yNk1psodJWWSlKlWws3cWSz0Tamldq)K5SQivHZ0nJ6nZduGocJoOO875IM5bIikzcIZ3(zvjdjsxiVaba)Jy2fYr3cWS9JoygNVz6JBIc4MoZSKuD(Z(Ua4xZ1sshTKq9GudWnrbCCwnolHqfhklwZ1sshTKq9GutccTch5Sm5SCrZeJqvuF9zoOFYhjKQmZBStL6hjNHryy2fYfylPBby2m6waMLbOFYCwvKQWz6Et9M5bkqhHrhuu(9CrZ8areLmbX5B)SQKHePlKxGaG)rm7c5OBby2(rh8MZ3m9XnrbCtNzwsQo)zbGZ(Ua4xlsUDOShkCivuHWAaUjkGJZQXzbGZ(Ua4xZ1sshTKq9GudWnrbCZeJqvuF9zoOFYhjKQmZBStL6hjNHryy2fYfylPBby2m6waMLbOFYCwvKQWz6ExVzEGc0ry0bfLFpx0mpqerjtqC(2pRkzir6c5fia4FeZUqo6waMTF)SmaHnv5No73aa]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20171115.094708, [[dmKktaqiOQOfjuQ2KqXOqvYPqv0RekPUfuvWUusddkogLAzcvptPOPjukxJeSnOQ03irJdvP6CcLO1HQuMNsb3JuvTpLcDqG0cHQ8qGyIOkCrssBuOeojj0mfkj3uj2jQ8tOQqdfQQQwkQQNsmvO0vHQkBLuLVcvvL9k9xGAWGCyQwmP8yatMIlJSzkXNjPgnPYPr51kvZwu3wWUv1VvmCOYXjvLLd55ImDvUUq2UsPVtsCEkP1dvvz)G6AxSveaed3vPcNhOkclacme(96MSvEdgYqw8O8vHpLjprLlogBL2ySXSg3oo(gxHkcocG5zg(Zp28LlUcXRakWXMpvSLZUyRO67AzYu8QiaigURYnQvNPv2FecfH7svavJLzN1kb2BaBbre(JQO4Bya(nOk)8uLLXONJ48avPcNhOklS3adflqeH)Ok8Pm5jQCXXyR0gtf(uAIqauQy7vbeDeW(YSLc0FvRYYy48avPx5IxSvu9DTmzkEveaed3vbf9maW4gvi0QHSWayhm0gHHIJPcOASm7SwXra(tGVbHO)QO4Bya(nOk)8uLLXONJ48avPcNhOkGIa8NGHWoie9xf(uM8evU4ySvAJPcFknriakvS9QaIocyFz2sb6VQvzzmCEGQ0RCBwSvu9DTmzkEveaed3v5g1QZ0kWmzZOYNQaQglZoRv0YZyaBjczTIIVHb43GQ8ZtvwgJEoIZduLkCEGQGxEgdmuSiczTcFktEIkxCm2kTXuHpLMieaLk2EvarhbSVmBPa9x1QSmgopqv6vUyRyRO67AzYu8QiaigURYnQvNPvGzYMrLpvbunwMDwROrOeH2zV6kk(ggGFdQYppvzzm65iopqvQW5bQcEekrOD2RUcFktEIkxCm2kTXuHpLMieaLk2EvarhbSVmBPa9x1QSmgopqv6vofk2kQ(UwMmfVkGQXYSZALOebMDuivrX3Wa8Bqv(5PklJrphX5bQsfopqvWVebdP4rHuf(uM8evU4ySvAJPcFknriakvS9QaIocyFz2sb6VQvzzmCEGQ0RC4BXwr131YKP4vraqmCxLBuRotR4MJnFcgkgyiEbdPfzXYA0RBYwbNoe9QpDRr4GH4zfq1yz2zTcU5yZxrX3Wa8Bqv(5PklJrphX5bQsfopqvW)NJnFf(uM8evU4ySvAJPcFknriakvS9QaIocyFz2sb6VQvzzmCEGQ0RCkl2kQ(UwMmfVkcaIH7QWlyiZCRBzOOm9hyCzxDeTEmGDWhlqGruWzFcgkwddDmGDWhlqWqBq)WqM5w3Yqrz6pW4YU6iAfrbN9jyiEcdfdmKzU1TmuuM(dmUSRoIwruWzFcgAd6hgsnGPcOASm7SwzIone57varhbSVmBPa9x1QSmg9CeNhOkv48avbFm60qKVxbuK6uLZrQPdmZI(5LzU1TmuuM(dmUSRoIwpgWo4JfiWik4SpfRpgWo4JfOnOFZCRBzOOm9hyCzxDeTIOGZ(epJXm36wgkkt)bgx2vhrRik4SpTb9RgWuHpLjprLlogBL2yQWNstecGsfBVkk(ggGFdQYppvzzmCEGQ0RC8EXwr131YKP4vraqmCxLBuRotRaZKnJkFQcOASm7SwXrbRGhlGpDeyd5Mkk(ggGFdQYppvzzm65iopqvQW5bQcOOGvyOXcm0PJGH4b5Mk8Pm5jQCXXyR0gtf(uAIqauQy7vbeDeW(YSLc0FvRYYy48avPx5ILfBfvFxltMIxfbaXWDvi9fXWHJmR2BQeJsfGHIbgcyMSzu5xnoAhSJ0yhHwruWzFcgAJWq24RcvavJLzN1kghTd(q(NSmOGFS5RO4Bya(nOk)8uLLXONJ48avPcNhOk8Wr7Wqyr(NSmOGFS5RWNYKNOYfhJTsBmv4tPjcbqPITxfq0ra7lZwkq)vTklJHZduLELZgtXwr131YKP4vraqmCxfsFrmC4iZQ9MkXOubyOyGHWNWqNNP)wt6CZOcy2BjkXMFLExltgyOyGHaMjBgv(vJJ2b7in2rOvefC2NGH2imKckubunwMDwRyC0o4d5FYYGc(XMVIIVHb43GQ8ZtvwgJEoIZduLkCEGQWdhTddHf5FYYGc(XMhgIx28ScFktEIkxCm2kTXuHpLMieaLk2EvarhbSVmBPa9x1QSmgopqv6voB7ITIQVRLjtXRIaGy4UkK(Iy4WrMv7nvIrPcWqXadDEM(BnPZnJkGzVLOeB(v6DTmzGHIbgcyMSzu5xnoAhSJ0yhHwruWzFcgAJWqBQqfq1yz2zTIXr7GpK)jldk4hB(kk(ggGFdQYppvzzm65iopqvQW5bQcpC0omewK)jldk4hBEyiEfNNv4tzYtu5IJXwPnMk8P0eHaOuX2Rci6iG9LzlfO)QwLLXW5bQsVYzhVyRO67AzYu8QiaigURcPVigoCKz1EtLyuQamumWqNJut36Xce4BaByem0gGHaMjBgv(vJJ2b7in2rOvefC2NGHWhGH49kGQXYSZAfJJ2bFi)twguWp28vu8nma)guLFEQYYy0ZrCEGQuHZdufE4ODyiSi)twguWp28Wq8AtEwHpLjprLlogBL2yQWNstecGsfBVkGOJa2xMTuG(RAvwgdNhOk9kN9MfBfvFxltMIxfbaXWDvi9fXWHJmR2BQeJsfGHIbgcyMSzu5xtrHW8Gv7i1J1mTIOGZ(em0gHHSXxmvavJLzN1kghTd(q(NSmOGFS5RO4Bya(nOk)8uLLXONJ48avPcNhOk8Wr7Wqyr(NSmOGFS5HH4vSXZk8Pm5jQCXXyR0gtf(uAIqauQy7vbeDeW(YSLc0FvRYYy48avPx5SJTITIQVRLjtXRIaGy4UkK(Iy4WrMv7nvIrPcWqXadHpHHopt)TM05MrfWS3suIn)k9UwMmWqXadbmt2mQ8RPOqyEWQDK6XAMwruWzFcgAJWqkOqfq1yz2zTIXr7GpK)jldk4hB(kk(ggGFdQYppvzzm65iopqvQW5bQcpC0omewK)jldk4hBEyiEPapRWNYKNOYfhJTsBmv4tPjcbqPITxfq0ra7lZwkq)vTklJHZduLELZwHITIQVRLjtXRIaGy4UkK(Iy4WrMv7nvIrPcWqXadDEM(BnPZnJkGzVLOeB(v6DTmzGHIbgcyMSzu5xtrHW8Gv7i1J1mTIOGZ(em0gHH2uHkGQXYSZAfJJ2bFi)twguWp28vu8nma)guLFEQYYy0ZrCEGQuHZdufE4ODyiSi)twguWp28Wq8cF5zf(uM8evU4ySvAJPcFknriakvS9QaIocyFz2sb6VQvzzmCEGQ0RC24BXwr131YKP4vraqmCxfsFrmC4iZQ9MkXOubyOyGHohPMU1JfiW3a2WiyOnadbmt2mQ8RPOqyEWQDK6XAMwruWzFcgcFagI3RaQglZoRvmoAh8H8pzzqb)yZxrX3Wa8Bqv(5PklJrphX5bQsfopqv4HJ2HHWI8pzzqb)yZddXlL8ScFktEIkxCm2kTXuHpLMieaLk2EvarhbSVmBPa9x1QSmgopqv6voBLfBfvFxltMIxfbaXWDvWNWqK(Iy4WrMv7nvIrPcWqXadHIEcgAd6hgAZkGQXYSZAfJJ2bFi)twguWp28vu8nma)guLFEQYYy0ZrCEGQuHZdufE4ODyiSi)twguWp28Wq8I35zf(uM8evU4ySvAJPcFknriakvS9QaIocyFz2sb6VQvzzmCEGQ0RC28EXwr131YKP4vraqmCxfdPfzXYQfkDeI9QbRYe9M105a7WqBq)WqXwfq1yz2zTIwMPw3rgWOONaRc54MVIIVHb43GQ8ZtvwgJEoIZduLkCEGQGxMPw3rgyi(rpbdH)roU5RWNYKNOYfhJTsBmv4tPjcbqPITxfq0ra7lZwkq)vTklJHZduLELZowwSvu9DTmzkEveaed3v58m93QXr7GDKg7i0k9UwMmWqXadHJU1TEE3kcSMFxMcoZq)QdCSTufq1yz2zTck6b7ahBEWzw6QaIocyFz2sb6VQvzzmCEGQiSaiWq43RBYw5nyOTEE3kQYYy0ZrCEGQurX3Wa8Bqv(5PkCEGQWp6HHaf4yZddfRyPRcOi1PkVhi9h7clacme(96MSvEdgARN3TII9k8Pm5jQCXXyR0gtf(uAIqauQy7vr0nQSmgMfgHsfVkYHyahi6iG9IxVYfhtXwr131YKP4vbunwMDwRa45myh4yZdoZsxffFddWVbv5NNQSmgopqvewaeyi871nzR8gmKA6jedOYYy0ZrCEGQubeDeW(YSLc0FvRcNhOkG45mmeOahBEyOyflDvafPov59aP)yxybqGHWVx3KTYBWqQPNqmGyVcFktEIkxCm2kTXuHpLMieaLk2EveDJklJHzHrOuXRICigWbIocyV41RxfEqw8O8v861ca]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20171115.094708, [[dmtgdaGEOIAxiQ2MIkMTuUjv62s1oPQ9s2ns7hrgMq9BjdvrLgmcnCi5GuuhJclualvilgLwUcpur5PGLjO1bvKjsrmvfzYuA6kDre0vHk4YQUok8COSvOkBMI02rGhdXxvuvttrv(ouPoSOxJOmAi1Pr1jHQ6Bc01Gk58OO)sf9zQWZGk0YqtcaKbh1kqGp7xaW7ZirehOORgtCIeruJJuD2Cfe92tSlFySrqJyJyYdncNtiUeaOocpBCCoxErLpexHcmJS8IIPj5n0KacPjB7wfqaGm4OwbB5Wr7KJQwErXeyML34ltbOQLxub4tTCKCRHaArVa3YIxo8z)ce4Z(fm3A5fvq0BpXU8HXgbnIfeDSIXa5yAsRGzOpczUfbVF6kwbUL1N9lqR8HAsaH0KTDRciWmlVXxMcgjh7oTpTcWNA5i5wdb0IEbULfVC4Z(fiWN9lik5yNertEAfe92tSlFySrqJybrhRymqoMM0kyg6JqMBrW7NUIvGBz9z)c0kpoQjbest22TkGaazWrTc2YHJ2jhPQMTWnftGzwEJVmfKJotNLPox03P9Pva(ulhj3AiGw0lWTS4LdF2Vab(SFbMhDMKiwMsI4I(KiAYtRGO3EID5dJncAeli6yfJbYX0KwbZqFeYClcE)0vScClRp7xGw5NNMeqinzB3QacmZYB8LPa2g3b69wNdg07e3prvub4tTCKCRHaArVa3YIxo8z)ce4Z(feOXDGEVLeXig0tI48FIQOcIE7j2Lpm2iOrSGOJvmgihttAfmd9riZTi49txXkWTS(SFbA1kWKBAYOTkGwj]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20171115.094708, [[dSdkgaGErvvBIaQDrK2gIu7drWmfvfZws3uuUncpNu7uQ2l1Ur1(jXOevLggq9BqVgipwKbtsdhfDqIYPevvoMuCEc1cLswkkzXcz5cweIKEk0YqPwhruterutffMSetxPlcOUkrKlR66c1grKyReHndW2bKtJ0HvmnerMNOk9nPuFMqgnI6VevNKa9DrLRjQI7raEgbKhsq)erODJzyetbkZ1OX(qCJiLqOIQK4KHvXswrfOPcsCWiRx)OV7Sb30UbCdyPSBytA25XiY8j6uP5)Sui3D25HTrzPLc5AZW9gZWiW8jQ(IBzuweTsxXglFwYYtqA1OG8cnnlmyKd53ygSiXe6dXnASpe3ij)zjROkesRgz96h9DNn4M2nGnY6AyCiDTz41OqYpbkdc0joFDKXmyPpe3Ox3zBggbMpr1xClJykqzUglpkgaaPaUEFGYfjphmMxKQ3jbsrLeeGIkPnklIwPRyJdtyAQIzQVrb5fAAwyWihYVXmyrIj0hIB0yFiUrzmHPPkMP(gz96h9DNn4M2nGnY6AyCiDTz41OqYpbkdc0joFDKXmyPpe3Ox3fiZWiW8jQ(IBzetbkZ1y5rXaaifW17duUi55GX8Iu9ojqkQ5vrL0kQcSIAccRfyoU0HjmnvXm1xA4edLRvuZRIQazuweTsxXgbC9(aLlsUEduq3OG8cnnlmyKd53ygSiXe6dXnASpe3iPC9(aLlsrf3af0nY61p67oBWnTBaBK11W4q6AZWRrHKFcugeOtC(6iJzWsFiUrVUtsMHrG5tu9f3YiMcuMRXjTuGU8Zpb9AfvsqakQSnklIwPRyJPPwLpPLc5YRu9Aui5NaLbb6eNVoYygS0hIBePecvuLeNmSkwYkQYirGnMblsmH(qCJgfKxOPzHbJCi)g7dXnkCQvfvzPLc5kQ5dvVgLfePnYhIlasfPecvuLeNmSkwYkQYirGjvJSE9J(UZgCt7gWgzDnmoKU2m8AejdZLblua0h0ULrCd00kK8tGClVUNhZWiW8jQ(IBzetbkZ1y5rXaaifW17duUi55GX8Iu9ojqkQ5vakQKKrzr0kDfBeW17duUi56nqbDJcYl00SWGroKFJzWIetOpe3OX(qCJKY17duUifvCduqxrnFBYpJSE9J(UZgCt7gWgzDnmoKU2m8Aui5NaLbb6eNVoYygS0hIB0R7K2mmcmFIQV4wgXuGYCnwEumaasbC9(aLlsEoymVinMPrzr0kDfBuNGXbrxUEduq3OG8cnnlmyKd53ygSiXe6dXnASpe3iMGXbrxrf3af0nY61p67oBWnTBaBK11W4q6AZWRrHKFcugeOtC(6iJzWsFiUrVU32mmcmFIQV4wgXuGYCnwEumaasbC9(aLlsEoymVinMPrzr0kDfBmvNCuUi5AYtbMtBuqEHMMfgmYH8BmdwKyc9H4gn2hIBuyDYr5IuurYtbMtBK1RF03D2GBA3a2iRRHXH01MHxJcj)eOmiqN481rgZGL(qCJE9AKKpGjUUULxBa]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20171115.094708, [[dGtEeaGEss1MiP0UiuTncr2hHYSrQ5ts1nfv3wKDQK9sTBuTFP8tcrnmG8BsnyPA4e4GkLofqvhtGNdyHislfjTyrz5i8qLINc9yuwhjjnrGIPIetMOPd6IcLRssIlR66cYHLSvsInduA7KOLjKZtcFwq9DHkNwX3qeJgr9xLQtsinnskUgqL7ri8msszucv9AcAhykgrgXiaA04Qs3ioPnTUQWjRPvOQT(wroMrQN(fW9kcuajbGcajEuqKifboJOGZMIEu9coAUxrGlY4wgC0CatXRatXymELrFPj1iYigbqJfdok)(5pnhO1fteTEKXTzd9avyu(csEV4YD5zLcJIYLdRGAcJCn)gZ1svkIvLUrJRkDJG5fKCRxCzRdMZkfgPE6xa3RiqbKeaYi1dOdrWoGPyOXnKptyUw5tNdDMXCTCvPB0qVImfJX4vg9LMuJiJyeanwm4O87N)0CGwxSwxng3Mn0duHXlyKpnmJIYLdRGAcJCn)gZ1svkIvLUrJRkDJXemYNgMrQN(fW9kcuajbGms9a6qeSdykgACd5ZeMRv(05qNzmxlxv6gn0lvZumgJxz0xAsnImIra0yXGJYVF(tZbADXerRh16QT1JV1LVGK3lUCxEwPqC4Weo8WTU6Q36Yd2H(IdhMWHhU1bVXTzd9avyeGPdre(7aqIr4nkkxoScQjmY18BmxlvPiwv6gnUQ0nImDiIWV1riXi8gPE6xa3RiqbKeaYi1dOdrWoGPyOXnKptyUw5tNdDMXCTCvPB0qVuJPymgVYOV0KAezeJaOXIbhLF)8NMd06IjIwpQ1vBRhFRlFbjVxC5U8SsH4WHjC4HBD1vV1LhSd9fhomHdpCRdEJBZg6bQWiJUIB4H3bixsDCagfLlhwb1eg5A(nMRLQueRkDJgxv6g3qxXn8WTosUK64ams90VaUxrGcijaKrQhqhIGDatXqJBiFMWCTYNoh6mJ5A5Qs3OHEbotXymELrFPj1iYigbqJfdok)(5pnhO1fR1JmUnBOhOcJxWiFAygfLlhwb1eg5A(nMRLQueRkDJgxv6gJjyKpnSwp(aWBK6PFbCVIafqsaiJupGoeb7aMIHg3q(mH5ALpDo0zgZ1YvLUrdn0iyoyRq0qtQH2a]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20171115.094708, [[deeIxaqiev2KuPprvsLrHiDkeXUOIHrchtelJu6zuLOPrvcxtQiBtQO8nsuJJQKY5qu06OkPQ5HOW9quAFuLKdsISquv9qsvnrevPUiPkBKQQ8revjJuQO6KuL6Msv7ev(jIQyPKINszQKkBLQkFLQQYEv(lvAWeDyGfJWJf1Kb5YQ2Su6ZuvgnQYPr51ufZwOBdQDd1VHmCP44iQQLJ0ZfmDjxNK2Ui13rv58IK1tvv18LkSFcVKPBMLPSMA2moa8Nzmy9fs)rrHYRxi9D8PS8mY73cuJ14FMMhpi8XPvrIYjksu4OnrBNPTtZ0CaukDm4pJCfiEC50srHkKtv8UZXaI4HesagsiviKiQqsO2264HfJmSpxyqMhdFh6HbmCyMs5IHWHPBCjt3m9WaI4Hg)ZSmL1uZkKpFX7KrOieIpCqi7kKKkKKkKKtilq84YPLI8)JDBuJH7CmGiEiHSJoessfsQk(cjziKAfYUcjvfZYUni(o1jRsPhxcjziKA9AcjjcjjczxHKCczbIhxo(afVtzyFUHcrHDogqepKqsYmLiyrwLAgIiYQtbfdHN5ngILbfIodJWFwpcYpaLda)zZ4aWFg5HiYQtbfdHNP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJt70ntpmGiEOX)mltzn1mc12whwoLBbIiCWHEyadhesYqitC6Kq2vilq84YHLt5wGichCogqep0mLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZNP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJZlNUz6HbeXdn(NzzkRPMvG4XLtGhOQtzyFUHIY88GZXaI4HeYUcj0juBBDOa)hrz57ekq2JqswHStZuIGfzvQzTuuOCdfL55Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOesROmpxijnHKzAE8GWhNwfjkNOyMMhqQ08dt3Qz6Z7zp9O0h(4AeZ6rqCa4pB148IPBMEyar8qJ)zwMYAQzKkKeQTToug8DuBeYUc5jFvwtZHCAon80NcW57IADlE39eiSlmGwPOczxHKCcjPcjHABRdIiYQtbfdHDuBeYUcjixS0394dZEqijdHuRqsIqsIq2rhczbIhxo(afVtzyFUHcrHDogqep0mLiyrwLAg9WiA4XhcU8XW1PZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4ptZHr0WJpees)JHRtNP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJRtt3m9WaI4Hg)ZSmL1uZiuBBDOm47O2iKDfsYjKKkKeQTToiIiRofume2rTri7kKGCXsF3Jpm7bHKmesTcjjczxHKCcjPc5jFvwtZHCAon80NcW57IADlE39eiSlmGwPOczxHSaXJlhFGI3PmSp3qHOWohdiIhsijzMseSiRsnJhIVid7ZLicc1mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z6CeFrg2NqYFeeQzAE8GWhNwfjkNOyMMhqQ08dt3Qz6Z7zp9O0h(4AeZ6rqCa4pB146SPBMEyar8qJ)zwMYAQzeQTToug8DuBeYUcj5essfsc12wherKvNckgc7O2iKDfsqUyPV7XhM9GqsgcPwHKeHSRqEYxL10CiNMtdp9PaC(UOw3I3Dpbc7cdOvkQq2vilq84YXhO4Dkd7ZnuikSZXaI4HeYUcjPcj0juBBDAon80NcW57IADlE39eiSlmGwPOoQnczhDiKzekcH4d7qpmIgE8HGlFmCDQd9WagoiKELq6LcjjZuIGfzvQz8q8fzyFUerqOM5ngILbfIodJWFwpcYpaLda)zZ4aWFwNJ4lYW(es(JGqjKKMqYmnpEq4JtRIeLtumtZdivA(HPB1m959SNEu6dFCnIz9iioa8NTACkpDZ0ddiIhA8pZYuwtnJCcjHABRdIiYQtbfdHDuBeYUcjPc5jFvwtZHC8GIfJccU4Zxlsfd5YhlgfYUczbIhxoTuK)FSBJAmCNJbeXdjKDfssfYWlxcewn4uSttitxTnzHKSczIq2rhcz4LlbcRgCk2PjKPRx0KfsYkKjcjjcjjczhDiKuv8dofd(UfYTtcjziK(YqZuIGfzvQziIiRofuFM3yiwgui6mmc)z9ii)auoa8NnJda)zKhIiRofuFMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnoV20ntpmGiEOX)mltzn1Sc5Zx8ozekcH4dheYUcjPcjPc5jFvwtZHCYiCarRGBgfHCZi6fYo6qijuBBDAyXiG6IADBPOq5O2iKKiKDfsc12whvmpumLBOOh7R45O2iKDfsOtO226qb(pIYY3juGShHKSczNeYUcj5esc12wherKvNckgc7O2iKKmtjcwKvPMfyyikWhkacUTQ0uZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZyyikWhka86ccP)uPPMP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJJmNUz6HbeXdn(NzzkRPMrvXSSBdIVtDGEllZkHKmiRqMOyMseSiRsnRLIcLBOOmpFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL55cjPAjzMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnUeft3m9WaI4Hg)ZSmL1uZiuBBDqerwDkOyiSJAJq2vijNqsO2264HfJmSpxyqMhdFh1MzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK6LKmtZJhe(40Qir5efZ08asLMFy6wntFEp7PhL(WhxJywpcIda)zRgxsY0ntpmGiEOX)mltzn1mqUyPV7XhM9Gq6vKvi1kKDfsYjKKkKfiEC50srHkKtv8UZXaI4HeYUcjHABRJhwmYW(CHbzEm8DuBeYUcjixS0394dZEqi9kYkKAfssMPeblYQuZOhgrdp(qWLpgUoDM3yiwgui6mmc)z9ii)auoa8NnJda)zAomIgE8HGq6FmCDQqsAcjZ084bHpoTksuorXmnpGuP5hMUvZ0N3ZE6rPp8X1iM1JG4aWF2QXLOD6MPhgqep04FMLPSMAgHABRJhwmYW(CHbzEm8DuBeYUcjPcj5eYt(QSMMd54bflgfeCXNVwKkgYLpwmkKD0HqcYfl9Dp(WShesVIScPwHKKzkrWISk1SwkkuHCQI3N5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqfYPkEFMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnUeVC6MPhgqep04FMLPSMAgixS0394dZEqi9kYkKANPeblYQuZ8fbzgi6cGsdW5pZBmeldkeDggH)SEeKFakha(ZMXbG)mYRiiZarHujO0aC(Z084bHpoTksuorXmnpGuP5hMUvZ0N3ZE6rPp8X1iM1JG4aWF2QXL4ft3m9WaI4Hg)ZSmL1uZa5IL(UhFy2dcPxrwH0lNPeblYQuZAPOqfYPkEFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcviNQ4DHK0esMP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJlPtt3m9WaI4Hg)ZSmL1uZiuBBD8WIrg2NlmiZJHVJAZmLiyrwLAgIiYQtb1N5ngILbfIodJWFwpcYpaLda)zZ4aWFg5HiYQtb1fsstizMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnUKoB6MPhgqep04FMLPSMAwbIhxo(afVtzyFUHcrHDogqepKq2vilq84YbwLcDksn4(2wwMDCoLZXaI4HeYUcjPcz4LlbcRgCk2PjKPR2MSqswHmri7OdHm8YLaHvdof70eY01lAYcjzfYeHKKzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK6fKmtZJhe(40Qir5efZ08asLMFy6wntFEp7PhL(WhxJywpcIda)zRgxIYt3m9WaI4Hg)ZSmL1uZivilq84YHhIIDrTU8XW1PohdiIhsi7OdHSaXJlhEQyFNYW(CPQ47Y3bniSZXaI4HesseYUcjPcz4LlbcRgCk2PjKPR2MSqswHmri7OdHm8YLaHvdof70eY01lAYcjzfYeHKKzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK2jsMP5XdcFCAvKOCIIzAEaPsZpmDRMPpVN90JsF4JRrmRhbXbG)SvJlXRnDZ0ddiIhA8ptjcwKvPMHiIS6uq9zEJHyzqHOZWi8N1JG8dq5aWF2moa8NrEiIS6uqDHKuTKmtZJhe(40Qir5efZ08asLMFy6wntFEp7PhL(WhxJywpcIda)zRgxczoDZ0ddiIhA8ptjcwKvPM5lcYmq0faLgGZFM3yiwgui6mmc)z9ii)auoa8NnJda)zKxrqMbIcPsqPb48fsstizMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnoTkMUz6HbeXdn(NzzkRPMroHKqTT1HNk23PmSpxQk(U8Dqdc7O2mtjcwKvPMXdrXUOwx(y460zEJHyzqHOZWi8N1JG8dq5aWF2moa8N15ikwirTcP)XW1PZ084bHpoTksuorXmnpGuP5hMUvZ0N3ZE6rPp8X1iM1JG4aWF2QXPnz6MPhgqep04FMseSiRsnRLIcLBOOmpFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL55cjPDgjZ084bHpoTksuorXmnpGuP5hMUvZ0N3ZE6rPp8X1iM1JG4aWF2QXPv70ntpmGiEOX)mltzn1Sc5Zx8ozekcH4dhMPeblYQuZoCdIVtDPQ47Y3bni8mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z0dUbX3PcPgv8fs)7GgeEMMhpi8XPvrIYjkMP5bKkn)W0TAM(8E2tpk9HpUgXSEeeha(ZwnoTE50ntpmGiEOX)mltzn1Sc5Zx8ozekcH4dheYUcjPcj5esc12whEQyFNYW(CPQ47Y3bniSJAJqsYmLiyrwLAgpvSVtzyFUuv8D57GgeEM3yiwgui6mmc)z9ii)auoa8NnJda)zDUk23PmSpHuJk(cP)DqdcptZJhe(40Qir5efZ08asLMFy6wntFEp7PhL(WhxJywpcIda)zRwnZAEMbIm)humeECA7uYQn]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20171115.094708, [[dGJMgaGEQG2evQQDPq2guIMPQcZMQUPQ0TvYoHQ9kTBi7xPgfrsdJi(TONJYGv0WvGdcQofvGJPkoTkluHAPqXIj0Yr1dfYtrwgrzDkOjsLktLGMmitNYfPs5XcEgucUoOSrQKTsf1MfQ2ovKZtK67qjnnOeAEuPkFdk1Hbgnr1FvvDsQqVwOCnIe3tvrFMalsvPlt6(uHLOa)gyLkHdwAj6wr7PlEYSH7jKghaZBLObA4a(ZHa7suXLjLNsyuVcyAXLj5b7hjpsgj7rgwktkLWOaiPfElTehg6c)dsSQ8rXbEp73YFzyxcEWUeXQWI)uHLCdbe9kuhxIc8BGvYsbc86OdzkNdBGXkbx88NjDP1HG(JZv1HAjhrqxayjVekrAP3eYzahhS0sLWblT07HG2txCvDOwcJ6vatlUmjpy)iPegLLW4bLvH1kfjxdXEtN0LISkw6nHWblTuTIlRcl5gci6vOoUeCXZFM0LcaV)heSlr)(JzLCebDbGL8sOePLiJFblsUgI1XLEtiNbCCWslvcJYsy8GYQWALWblTueW73t4b7s0E(XXSsW5cyLqGL(5x6wr7PlEYSH7zK7yFlHr9kGPfxMKhSFKuIKNy9nHU4NYzDCPi5Ai2B6KUuKvXsVjeoyPLOBfTNU4jZgUNrUJvR4yHkSKBiGOxH64suGFdSsgWRiBKixbM8)m(p7qqCGGKbgPiGOxH2t3Fpdz6HsSIgjYvGj)pJ)ZoeehiizGrCDboeBpDV98rkLGlE(ZKUehg6heSlr)(JzLIKRHyVPt6srwfl9Mqod44GLwQeoyPLWadTNWd2LO98JJzLGZfWkHal9ZV0TI2tx8Kzd3tXKTNdY0FibFlHr9kGPfxMKhSFKucJYsy8GYQWALCebDbGL8sOePLEtiCWslr3kApDXtMnCpft2Eoit)HeuR4yXkSKBiGOxH64suGFdSsqPnsKRat(Fg)NDiioqqYaJSle7qckbx88NjDjom0piyxI(9hZkfjxdXEtN0LISkw6nHCgWXblTujCWslHbgApHhSlr75hhZ2tP(4GsW5cyLqGL(5x6wr7PlEYSH7PyY2t7cXoKGVLWOEfW0IltYd2pskHrzjmEqzvyTsoIGUaWsEjuI0sVjeoyPLOBfTNU4jZgUNIjBpTle7qcQvCPuHLCdbe9kuhxIc8BGvsew84Jsr)zkhyxIgbBqj4IN)mPlXHH(bb7s0V)ywPi5Ai2B6KUuKvXsVjKZaooyPLkHdwAjmWq7j8GDjAp)4y2EkvzoOeCUawjeyPF(LUv0E6INmB4EMI(ZuoWUe9Teg1RaMwCzsEW(rsjmklHXdkRcRvYre0fawYlHsKw6nHWblTeDRO90fpz2W9mf9NPCGDjQwXXYkSKBiGOxH64sWfp)zsxka8(FqWUe97pMvYre0fawYlHsKwIm(fSi5Aiwhx6nHCgWXblTujmklHXdkRcRvchS0sraVFpHhSlr75hhZ2tP(4GsW5cyLqGL(5x6wr7PlEYSH7jZaiiah6BjmQxbmT4YK8G9JKsK8eRVj0f)uoRJlfjxdXEtN0LISkw6nHWblTeDRO90fpz2W9KzaeeGdvRwj3PXbW8whxRfa]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20171115.094708, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEnLuLXwzHnxzE5KmWeZnXatmW4ImXiJnYuJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnLx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20171115.094708, [[deubnaqiuPAtKQ6tkviJIkLtrLQDjWWqkhtqlJk6zujPPPuP6Akv02qLcFdPY4uQGZPuPyDujO5Puj3Jkb2hvsCqujlePQhskmrLkLUiPOnsLuFuPc1iPsKtsk1nfv7eu)KkrTuuXtjMkQQTsQYxrLs7v6VkLbtXHv1Ir0JvYKb5YqBwu(mQYOjvonjVMkmBQ62iSBGFRy4I0XrLIwokpxOPRY1rY2vQ67IOZlcRNkHMpPK9tPBy5xrwmv6vPc8tGvefHgwJRzt8CHwdVO1CQLdfGxLDlM9u(R0xHd6XpIf2jTq6cPfslWzOtUHZDwHd(qj4RiWkKuzzb6Oa8qMcWBJrbWTK4NoGags8kqScxRtnGy5x4WYVIMGN0JqL(kYIPsVkKuzzbQvIT79digWqIxbIwZUSMWGDAn6Bn37rWfOwj2U3pGyacEspcvHlsLxDjQKXM4TfpMYbwrBaKA93WQagawjFG07zWpbwPc8tGvCnBIN1iht5aRWb94hXc7KwiDH0QWbJdfBHXYVxfn0Hlh5ZEKabxjRKpqWpbwPxHDw(v0e8KEeQ0xHlsLxDjQWqIHfrpgJBjvGdzv0gaPw)nSkGbGvYhi9Eg8tGvQa)eyfoiXWIOhJrRHBvGdzv4GE8JyHDslKUqAv4GXHITWy53RIg6WLJ8zpsGGRKvYhi4NaR0RWUA5xrtWt6rOsFfzXuPxfsQSSaMIadOsTg9TgUBnUznKuzzbdPxDi7p1acOsTg9TMFDQ94gcqcfgTMDznoTg3RWfPYRUev0nj9kaVns)hVkAdGuR)gwfWaWk5dKEpd(jWkvGFcSIlnj9kapRHE)hVkCqp(rSWoPfsxiTkCW4qXwyS87vrdD4Yr(ShjqWvYk5de8tGv6v4DV8ROj4j9iuPVISyQ0RYn845XG1mEOjjiAn6BnUznUznC3AU3JGliJnUic2sP8rmabpPhHSgT0YACZAyua0A2L140A03Ayua1AlDsISGffJHGZA2L14ChSg3Tg3Tg3RWfPYRUevgsV6q2FQburBaKA93WQagawjFG07zWpbwPc8tGvCzsV6q2FQbuHd6XpIf2jTq6cPvHdghk2cJLFVkAOdxoYN9ibcUswjFGGFcSsVcVZYVIMGN0JqL(kYIPsVkmkaAnUI14QwJwAznKuzzbouEVcWBJ4x6uamGk1A0slRHKkllyi9Qdz)PgqavAfUivE1LOYq6vhY(dROnasT(ByvadaRKpq69m4NaRub(jWkUmPxDi7pSch0JFelStAH0fsRchmouSfgl)Ev0qhUCKp7rceCLSs(ab)eyLEfMBu(v0e8KEeQ0xrwmv6v5gE88yWAgp0KeeTg9Tg3Sg3SgKBsPstrOG1aId7IBRXdTTggAnAPL1qsLLfKQ8(NTnzBzSjEbuPwJ7wJ(wdjvwwafq34tSfpgc4D6cOsTg9TgiKKkllG9U4WulmiE)YH14cSMDAn6BnC3AiPYYcgsV6q2FQbeqLAnUxHlsLxDjQevai2ZBIFClJILOI2ai16VHvbmaSs(aP3ZGFcSsf4NaRikae75nXFhfTgxtXsuHd6XpIf2jTq6cPvHdghk2cJLFVkAOdxoYN9ibcUswjFGGFcSsVctx5xrtWt6rOsFfzXuPxfsQSSahkVxb4Tr8lDkagqLAn6BnUznC3AqUjLknfHcCm(tX(4gatMnuaOTKkV3A0slR5EpcUaE)PdzkaVT4nmIae8KEeYA0slR5xNApUHaKqHrRXvCbwJtRX9kCrQ8QlrLm2eV4kXPdROnasT(ByvadaRKpq69m4NaRub(jWkUMnXlUsC6WkCqp(rSWoPfsxiTkCW4qXwyS87vrdD4Yr(ShjqWvYk5de8tGv6v4DO8ROj4j9iuPVISyQ0RcJcOwBPtsKfSOymeCwJRyn7anRrlTSg3SgsQSSGH0RoK9NAabuPwJ(wd3TgsQSSahkVxb4Tr8lDkagqLAnUxHlsLxDjQKXM4TfpMYbwrBaKA93WQagawjFG07zWpbwPc8tGvCnBIN1iht5aTg3cDVch0JFelStAH0fsRchmouSfgl)Ev0qhUCKp7rceCLSs(ab)eyLEfE3u(v0e8KEeQ0xHlsLxDjQmKE1HS)WkAdGuR)gwfWaWk5dKEpd(jWkvGFcSIlt6vhY(dTg3cDVch0JFelStAH0fsRchmouSfgl)Ev0qhUCKp7rceCLSs(ab)eyLEfoKw5xrtWt6rOsFfzXuPxfgfqT2sNKilyrXyi4SMDzn0rZA03A4U1qsLLfOJcWdzkaVngfa3sIF6acOsRWfPYRUev0nmW2KTLuboKvrBaKA93WQagawjFG07zWpbwPc8tGvCPHbSMjZA4wf4qwfoOh)iwyN0cPlKwfoyCOylmw(9QOHoC5iF2Jei4kzL8bc(jWk9kCyy5xrtWt6rOsFfUivE1LOcp)VuVF7H2)GfwrBaKA93WQagawjFG07zWpbwPc8tGv2X(FPEV1Wf0(hSWkCqp(rSWoPfsxiTkCW4qXwyS87vrdD4Yr(ShjqWvYk5de8tGv6v4qNLFfnbpPhHk9v4Iu5vxIkzSjEBXJPCGv0gaPw)nSkGbGvYhi9Eg8tGvQa)eyfxZM4znYXuoqRXnNUxHd6XpIf2jTq6cPvHdghk2cJLFVkAOdxoYN9ibcUswjFGGFcSsVch6QLFfnbpPhHk9vKftLEvUHhppgSMXdnjbrRrFRXnRH7wdjvwwGokapKPa82yuaClj(PdiGk1ACVcxKkV6surhfGhYuaEBmkaULe)0burBaKA93WQagawjFG07zWpbwPc8tGvCjkapKPa8Sgoua0A4w8thqfoOh)iwyN0cPlKwfoyCOylmw(9QOHoC5iF2Jei4kzL8bc(jWk9kC4Ux(v0e8KEeQ0xrwmv6v5gE88yWAgp0KeeRWfPYRUevqI0jjY2yuaClj(PdOI2ai16VHvbmaSs(aP3ZGFcSsf4NaROjr6KezwdhkaAnCl(PdOch0JFelStAH0fsRchmouSfgl)Ev0qhUCKp7rceCLSs(ab)eyLE9QiP4s9ELl(NAaf25od71c]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20171115.094708, [[deuDsaqiQKSjOkFIkPuJcQ4uqLwfbrTlQyyOshdkwMq8mHsMgbPRjizBcc(guvJJkPIZrLuSoQKsMNqPUhbH9rvXbPk1cPs8qQsMivsLUivv2OGuJKGiNKQQUjuANe6NccTuQupLYuPk2kvL(QGO2RQ)skdgLddzXOQhlPjROld2mQ4ZKQgnPYPj61cPzlXTvy3i(TudNahxqKLR0Zjz6IUUaBNG67cQZluTEQKQMVqX(r6J5EUz1vkiVDtenGBMC4fLf6TvPRfLX3QBUUahuqjVl3CdfaPGlgHlg8XWfdxNiyIecrc1n3aAg3JCa32aISQjOddRdhuPO0YwdFU38UMYMOUNlI5EU5hbXxG5D5MvxPG8wIkajDK14AjQ0eLdqq8fysz4rz8bC44iRX1suPjkNfgijrrzXMY0xNugEuwT7YSdtC4xaL60AoAkjzUi9Tc5SWajjkkZhkBdiGYjLdqlBnHEZBEzrMXVXzBvQPYvgfU5pzkROS3BKMa3W2tFrRiAa3UjIgWTqVTkPmlxzu4MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98IrUNB(rq8fyExUz1vkiVLOcqsh9OuhSsIEnv27Wbii(cmV5nVSiZ43wy0RckGsPfwssyV5pzkROS3BKMa3W2tFrRiAa3UjIgWn3WOxfuaLIYczjjH9MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98IX6EU5hbXxG5D5MvxPG8gFahooRCaobcOm8OSnGakNuoaTS1ekLfBkdhktFDszczklcLH7nV5Lfzg)MUoCrs0RXxqQ8M)KPSIYEVrAcCdBp9fTIObC7MiAa3esD4IKONYCPGu5n3qbqk4Ir4IbFmCV5guDWwb1988Mx6GAuSTWWai55VHTNIObC75ff69CZpcIVaZ7YnRUsb5TnGakNuoaTS1cbkl2uM(6KYWJYCfLLOcqsh9OuhSsIEnv27Wbii(cmV5nVSiZ43A(ImHfLWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUfI8fzclkHBUHcGuWfJWfd(y4EZnO6GTcQ755nV0b1OyBHHbqYZFdBpfrd42ZlgQ75MFeeFbM3LBwDLcYBBabuoPCaAzRjukl2uM(6KYWJYWHYQDxMDyId)cOuNwZrtjjZfPVviNfgijrrz(qzCPSyIHY2aISQjOddRtnyxGKuwSPm85sz4EZBEzrMXV18fzclkHB(tMYkk79gPjWnS90x0kIgWTBIObCle5lYewucugoyW9MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98IHW9CZpcIVaZ7YnRUsb5TnGiRAc6WW6ud2fijL5JqqzUMqrz4rzki14BsGYjLWIX1OjubvkZhkJlLHhLv7Um7Weh(fqPoTMJMssMlsFRqolmqsIIY8HY4EZBEzrMXVXzBvQPYvgfU5pzkROS3BKMa3W2tFrRiAa3UjIgWTqVTkPmlxzuGYWbdU3CdfaPGlgHlg8XW9MBq1bBfu3ZZBEPdQrX2cddGKN)g2EkIgWTNxe)75MFeeFbM3LBwDLcYB8bC44SYb4eiGYWJYGqkqkqamDeaRcegwePcAnhTuhOb8nrBG2m(EZBEzrMXVTWOxfuaLslSKKWEZFYuwrzV3inbUHTN(Iwr0aUDtenGBUHrVkOakfLfYssclLHdgCV5gkasbxmcxm4JH7n3GQd2kOUNN38shuJITfggajp)nS9uenGBpVORZ9CZpcIVaZ7YnRUsb5n(aoCCw5aCceqz4rz4qzZoDwy0RckGsPfwssyDsznQKONYIjgkR2Dz2Hjolm6vbfqP0cljjSolmqsIIY8HY0xNuwmXqz4qzUIYGqkqkqamDeaRcegwePcAnhTuhOb8nrBG2m(sz4rzUIYsubiPJEuQdwjrVMk7D4aeeFbMugUugU38MxwKz8B66WfjrVgFbPYB(tMYkk79gPjWnS90x0kIgWTBIObCti1HlsIEkZLcsLugoyW9MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98IUM75MFeeFbM3LBwDLcYBUIY4d4WXzLdWjqaLHhL5kkdhklrfGKo6rPoyLe9AQS3Hdqq8fysz4rzUIYWHYQDxMDyIZcJEvqbukTWsscRZcdKKOOmFOmCOm91jLjKPSiugUuwmXqzBabOmFOmHsz4sz4sz4rzBabOmFOSyDZBEzrMXV18fzclkHB(tMYkk79gPjWnS90x0kIgWTBIObCle5lYewucugorW9MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98Iy4Ep38JG4lW8UCZQRuqElB96lGtT7YSdtuugEugougougesbsbcGPtTjQEtLwTltTAVaLftmugFahoocKLcA1AoAC2wLobcOmCPm8Om(aoCCci66sCnvUarFQZjqaLHhLnb(aoCCwKRVxzfCujQgLYeckluugEuMROm(aoCCA(ImHfLYM4eiGYWJY2aISQjOddRtnyxGKuMpuwScfLH7nV5Lfzg)MssMlsFRqknobB8B(tMYkk79gPjWnS90x0kIgWTBIObCZKK5I03kKRTIYcDWg)MBOaifCXiCXGpgU3CdQoyRG6EEEZlDqnk2wyyaK883W2tr0aU98IyWCp38JG4lW8UCZQRuqEJpGdhNOYsrs0RnqvDsc4eiGYWJYWHYCfLbHuGuGay6eTlPCrknceMthqMAHLLcLftmugQMsHbnGadjOOmFecklcLH7nV5Lfzg)gNTvPQgp1b38NmLvu27nstGBy7PVOvenGB3erd4wO3wLQA8uhCZnuaKcUyeUyWhd3BUbvhSvqDppV5LoOgfBlmmasE(By7PiAa3EErmrUNB(rq8fyExUz1vkiVTbezvtqhgwNAWUajPmFeckdFU38MxwKz8BC2wLAQCLrHB(tMYkk79gPjWnS90x0kIgWTBIObCl0BRskZYvgfOmCIG7n3qbqk4Ir4IbFmCV5guDWwb1988Mx6GAuSTWWai55VHTNIObC75fXeR75MFeeFbM3LBwDLcYBOAkfg0acmKGIY8riOSi38MxwKz8Blm6vbfqP0cljjS38NmLvu27nstGBy7PVOvenGB3erd4MBy0RckGsrzHSKKWsz4eb3BUHcGuWfJWfd(y4EZnO6GTcQ755nV0b1OyBHHbqYZFdBpfrd42ZlIrO3Zn)ii(cmVl3S6kfK3WHYQDxMDyIZcJEvqbukTWsscRZcdKKOOSytz4qz6RtktitzrOmCPSyIHY4d4WXrpk1bRKOxtL9oCujQgLYeckddxkdxkdpkR2Dz2Hjo8lGsDAnhnLKmxK(wHCwyGKefL5dLTbeq5KYbOLTMqPm8OSevas6OhL6Gvs0RPYEhoabXxG5nV5Lfzg)gNTvPMkxzu4M)KPSIYEVrAcCdBp9fTIObC7MiAa3c92QKYSCLrbkdNyH7n3qbqk4Ir4IbFmCV5guDWwb1988Mx6GAuSTWWai55VHTNIObC75fXeQ75MFeeFbM3LBwDLcYBUIY4d4WXzLdWjqaLHhLHdL5kklrfGKo6rPoyLe9AQS3Hdqq8fyszXedLv7Um7WeNfg9QGcOuAHLKewNfgijrrz(qz4qz6Rtkdxkd3BEZllYm(TMVityrjCZFYuwrzV3inbUHTN(Iwr0aUDtenGBHiFrMWIsGYWjw4EZnuaKcUyeUyWhd3BUbvhSvqDppV5LoOgfBlmmasE(By7PiAa3EErmHW9CZpcIVaZ7YnRUsb5TA3LzhM4WVak1P1C0usYCr6BfYzHbssuuMpugMqrz4rzBarw1e0HH1PgSlqskl2cbLHpxkdpkBdiGYjLdqlBTyrz(qz6RZBEZllYm(nD9s0AoAHLKe2B(tMYkk79gPjWnS90x0kIgWTBIObCti1lHYAouwiljjS3CdfaPGlgHlg8XW9MBq1bBfu3ZZBEPdQrX2cddGKN)g2EkIgWTNxed(3Zn)ii(cmVl3S6kfK3QDxMDyId)cOuNwZrtjjZfPVviNfgijrrz(qzBabuoPCaAzRj0BEZllYm(noBRsnvUYOWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUf6TvjLz5kJcugocf3BUHcGuWfJWfd(y4EZnO6GTcQ755nV0b1OyBHHbqYZFdBpfrd42ZN3mbqvIksxpkLn5IrcfMN)]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20171115.094708, [[de0PnaqiuvQnjk9jrQQgffLtrrSlkmmf1XevlJu5zKsmnuv01qf12ePcFJIQXHksCourQ1jsfnpsjDpbL9HQQdsk1cPi9qbPjksv5IcInIkIpIksAKOQGtkO6MOk7Ke)evfAPKQEkvtvG2QiLVIQs2l4Ve1GrCyuwmj9yHMmKUSQnRiFwKmAbCAcVwumBfUne7gPFR0WfXXfPslxQNtPPl56ez7Os9DsX5rfwVivz(Os2pud5qqWvyihCxGekMWj9AR0jMOUwmPeXmcAkW9KhfSHi9yLyPGIooNdE67tmPrbMcU(poZEqr3CU55Z5Zg6Y1Lo0XzW1FgkhbfihCvPPjJas0uVf0uYTe9YAolzPg9rycQfCTJLyPwiiOKdbbpektDCuWuW9ylskWl240YWgGv1BbnLSTArMBnoLPookMKftAjQikNSAEBeL6(0ct0kMWNZyswmPLO3AucKlxRSomHFmrhMKftI7oqxnuJJKSAEl3s0lR5SKLA0hHjOwmHFmzgtYIjOxvAAYOzP32I4nSflMbtcdt4mMKftmdtI7oqxnuJaBtL3jzncA92OpctqTyc)yYmMWfxycFJjfBCAzeyBQ8ojRrqR3gNYuhhftmbCTvfdrXb4t9AlzB1Imh8WPOIiR2gC6sp48w00yTcd5GdUcd5GZj9AlmXRwK5GR)JZShu0nNBE(m46VDL64TqqOap0apMH3Y9roTavW5TOkmKdouGIoii4HqzQJJcMcUhBrsbElrfr5KvZBJOu3Nwyc)HHjAzgtYIjMHjMHjQsttgTa5gsjyswm5PRKij5OgjVTN73mA8Y7KCf4YxDPYiSU4OXetWeU4ctmdtk240YifRc8wqtjBRTrmoLPookMKftmdtuLMMm6JST9JBTYAe06TrFeMGAXeTggMKkIIjCXfMW3yIQ00KrFKTTFCRvwJGwVnKsWetWetWetaxBvXquCaEFKTTFCRvwJGwVbpCkQiYQTbNU0doVfnnwRWqo4GRWqo46pY22pU1Ij8LGwVbx)hNzpOOBo388zW1F7k1XBHGqbEObEmdVL7JCAbQGZBrvyihCOafTabbpektDCuWuW9ylskWndtmdtAjQikNSAEBeL6(0ct4pmmr3mMKftSVKvxQK1OeVZ50Y8zset4htMXetWeU4ctAjQikNSAEBeL6(0ct4pmmrlZyIjyswmrvAAYOfi3qkbCTvfdrXb4bwndbnLS6GzlWdNIkISABWPl9GZBrtJ1kmKdo4kmKdoFy1me0uyIPdMTax)hNzpOOBo388zW1F7k1XBHGqbEObEmdVL7JCAbQGZBrvyihCOaf(eccEiuM64OGPG7XwKuGBFjRUujRrjERBwwxset4htMXKSyslrfr5KvZBd0pjIIct0AyysoNXKSyslrpMO1WWeTGjzXevPPjJeXyWA5DsEQxBziLGjzXe(gtk240YWgGv1BbnLSTArMBnoLPook4ARkgIIdWN61wY2Qfzo4HtrfrwTn40LEW5TOPXAfgYbhCfgYbNt61wyIxTiZXeZYnbC9FCM9GIU5CZZNbx)TRuhVfccf4Hg4Xm8wUpYPfOcoVfvHHCWHcu4mee8qOm1Xrbtb3JTiPaVLOIOCYQ5TruQ7tlmrRHHj8jNXeU4ctAj6TgLa5Y1kZzmrRysQik4ARkgIIdWx1HOEZQdE4uurKvBdoDPhCElAASwHHCWbxHHCW5JQdr9MvhC9FCM9GIU5CZZNbx)TRuhVfccf4Hg4Xm8wUpYPfOcoVfvHHCWHcushqqWdHYuhhfmfCp2IKc8AtLACJ4Ud0vd1IjzXeZWeZWKNUsIKKJAexQD7Ykh3bQCC7JjCXfMOknnzKigdwlVtYt9AldPemXemjlMOknnzirdSdoKTvFAQkGHucMKftqVQ00KrZsVTfXBylwmdMegMWzmXeW1wvmefhGBfu0MLATmR8KuZb4HtrfrwTn40LEW5TOPXAfgYbhCfgYb3fu0MLATS0Vft4ePMdW1)Xz2dk6MZnpFgC93UsD8wiiuGhAGhZWB5(iNwGk48wufgYbhkqXCii4HqzQJJcMcUhBrsbElrfr5KvZBd0pjIIct4pmmrlZyswmPLO3AucKlxRSwWe(XKuruW1wvmefhGhyBQ8ojRrqR3Ghofvez12Gtx6bN3IMgRvyihCWvyihC(W2umzNWe(sqR3GR)JZShu0nNBE(m46VDL64TqqOap0apMH3Y9roTavW5TOkmKdouGcNcee8qOm1Xrbtb3JTiPaxvAAYiJyme0uYiSyab9gsjyswmXmmHVXKNUsIKKJAKzhLOzwz61mTsuuznIXat4IlmPyJtlJuSkWBbnLST2gX4uM64OycxCHjSyj4(YNEeXTyc)HHj6WetaxBvXquCa(uV2Yg5OcCWdNIkISABWPl9GZBrtJ1kmKdo4kmKdoN0RTSroQahC9FCM9GIU5CZZNbx)TRuhVfccf4Hg4Xm8wUpYPfOcoVfvHHCWHcu40qqWdHYuhhfmfCp2IKcCwSeCF5tpI4wmH)WWeDGRTQyikoap1GffSHmdLBgnEWdNIkISABWPl9GZBrtJ1kmKdo4kmKdoN6GffSbMOnk3mA8GR)JZShu0nNBE(m46VDL64TqqOap0apMH3Y9roTavW5TOkmKdouGs(mee8qOm1Xrbtb3JTiPaNflb3x(0JiUft4pmmrh4ARkgIIdW7JST9JBTYAe06n4HtrfrwTn40LEW5TOPXAfgYbhCfgYbx)r22(XTwmHVe06nMywUjGR)JZShu0nNBE(m46VDL64TqqOap0apMH3Y9roTavW5TOkmKdouGsEoee8qOm1Xrbtb3JTiPaVLOIOCYQ5Tb6NerrHj8Jj64mMWfxyslrpMWpMOfW1wvmefhGVQdr9Mvh8WPOIiR2gC6sp48w00yTcd5GdUcd5GZhvhI6nRoMywUjGR)JZShu0nNBE(m46VDL64TqqOap0apMH3Y9roTavW5TOkmKdouGsUoii4HqzQJJcMcUhBrsbETPsnUrC3b6QHAXKSyIzyslrfr5KvZBJOu3NwyIwXeTmJjzXKwIERrjqUCTY6We(XKurumXeW1wvmefhGFKKvZB5wIEznNLSuWdNIkISABWPl9GZBrtJ1kmKdo4kmKdEiijRM3yIEj6Xe(6SKLcU(poZEqr3CU55ZGR)2vQJ3cbHc8qd8ygEl3h50cubN3IQWqo4qbf4ESfjf4qba]] )

    storeDefault( [[SimC Frost: bos generic]], 'actionLists', 20171115.094708, [[de0nsaqiQq2eQIprfk1OGkDkOIvrqODrQggQQJjrltq9mcIMgbPRbf02ee8nuLghvOIZrfkwhvOK5bfY9Gc1(OQ4GufwivWdPkAIuHkDrQkTrOaJKGGtsvv3ekTtc9tbHwkv0tPmvQsBLQkFvqu7v1FPsdgLddzXOYJL0KLQld2mu1NjLgnP40e9Ajy2cDBPSBe)wXWjWXfez5k9CsMUORlW2jO(Ue68qrRNku18fK2ps)Y79MiQb3mzZtkdd2rLowug3OOmTabwz9MjaQsuu64rPCixmmgwEZjebKcUyy(L8wYVKVE4YWHqym8MvxPG82npQPCiQ79IL37nFjiUi0Vd3S6kfK3sueiPUSIPBIIdrPdeexe6ugpugxaE86YkMUjkoeL(cnKKOOmmIY0w7ugpuwDMyFks05waLACh8UkjPViTJcPVqdjjkkZhkBdiGspLnWnhxHEZdozuMyEd)oQ0vLRSaCZFsxwr5S3idbUHD6(HwrudUDte1GByWoQKYSCLfGBoHiGuWfdZVK3s(3CcQjyRG6EFEZtnqTa2ryObK8C3WoDrudU98IHV3B(sqCrOFhUz1vkiVLOiqsDTOudSsIwxvoBthiiUi0V5bNmktmVTqBwfebLYTOKKWEZFsxwr5S3idbUHD6(HwrudUDte1GBoH2SkickfLfYssc7nNqeqk4IH5xYBj)Bob1eSvqDVpV5PgOwa7im0asEUByNUiQb3EErH8EV5lbXfH(D4MvxPG8gxaE86RSb6bcOmEOSnGak9u2a3CCfkLHrugUuM2ANYeIuwykdNBEWjJYeZBAMIrjrRlxePYB(t6YkkN9gziWnSt3p0kIAWTBIOgCtimfJsIwkZHisL3CcraPGlgMFjVL8V5eutWwb19(8MNAGAbSJWqdi55UHD6IOgC75ff69EZxcIlc97WnRUsb5TnGak9u2a3CCdbkdJOmT1oLXdL5iklrrGK6ArPgyLeTUQC2MoqqCrOFZdozuMyEB4IYewuc38N0Lvuo7nYqGByNUFOve1GB3ern4wiYfLjSOeU5eIasbxmm)sEl5FZjOMGTcQ795np1a1cyhHHgqYZDd70frn42ZlIH37nFjiUi0Vd3S6kfK32acO0tzdCZXvOuggrzARDkJhkdxkRotSpfj6ClGsnUdExLK0xK2rH0xOHKefL5dLXNYcnukBdiYQRGPiS61GDbsszyeLXlFkdNBEWjJYeZBdxuMWIs4M)KUSIYzVrgcCd709dTIOgC7MiQb3crUOmHfLaLHBjo3CcraPGlgMFjVL8V5eutWwb19(8MNAGAbSJWqdi55UHD6IOgC75fdH79MVeexe63HBwDLcYBBarwDfmfHvVgSlqskZhmMYCmyiLXdLPG0LBibk9ucBPJXvOcQuMpugFkJhkRotSpfj6ClGsnUdExLK0xK2rH0xOHKefL5dLX)MhCYOmX8g(DuPRkxzb4M)KUSIYzVrgcCd709dTIOgC7MiQb3WGDujLz5klaugUL4CZjebKcUyy(L8wY)MtqnbBfu37ZBEQbQfWocdnGKN7g2PlIAWTNxK379MVeexe63HBwDLcYBCb4XRVYgOhiGY4HYGqkqkqa01faRcegwePcUdE3ud4cCdXTH2eZ9MhCYOmX82cTzvqeuk3Issc7n)jDzfLZEJme4g2P7hAfrn42nrudU5eAZQGiOuuwiljjSugUL4CZjebKcUyy(L8wY)MtqnbBfu37ZBEQbQfWocdnGKN7g2PlIAWTNx0X5EV5lbXfH(D4MvxPG8gxaE86RSb6bcOmEOmCPmUa841xOnRcIGs5wussy1deqzHgkLvNj2NIe9fAZQGiOuUfLKew9fAijrrz(qzARDkl0qPmCPmhrzqififia66cGvbcdlIub3bVBQbCbUH42qBI5sz8qzoIYsueiPUwuQbwjrRRkNTPdeexe6ugougo38GtgLjM30mfJsIwxUisL38N0Lvuo7nYqGByNUFOve1GB3ern4MqykgLeTuMdrKkPmClX5MticifCXW8l5TK)nNGAc2kOU3N38udulGDegAajp3nStxe1GBpVOJ5EV5lbXfH(D4MvxPG8MJOmUa841xzd0deqz8qzoIYWLYsueiPUwuQbwjrRRkNTPdeexe6ugpuMJOmCPS6mX(uKOVqBwfebLYTOKKWQVqdjjkkZhkdxktBTtzcrklmLHdLfAOu2gqakZhktOugougougpu2gqakZhktiV5bNmktmVnCrzclkHB(t6YkkN9gziWnSt3p0kIAWTBIOgCle5IYewucugUHX5MticifCXW8l5TK)nNGAc2kOU3N38udulGDegAajp3nStxe1GBpVyj)79MVeexe63HBwDLcYB5OvBe0RZe7trIIY4HYWLYWLYGqkqkqa01RdrnBQCRtS7wNfOSqdLY4cWJxxGmgrR7G3f)oQupqaLHdLXdLXfGhVEarZeX0vLlq0MA0deqz8qzDGlapE9f54NvwbDvIQfOmmMYWqkJhkZrugxaE86dxuMWIs5q0deqz4CZdozuMyEtjj9fPDuiLl(GfZB(t6YkkN9gziWnSt3p0kIAWTBIOgCZKK(I0okKJTIYWGGfZBoHiGuWfdZVK3s(3CcQjyRG6EFEZtnqTa2ryObK8C3WoDrudU98ILL37nFjiUi0Vd3S6kfK34cWJxVGmgLeTUnuvJKa6bcOmEOmCPmhrzqififia66fMykxKYLafXpbKUBrzmszHgkLHQPuyWfiqtckkZhmMYctz4CZdozuMyEd)oQuvXm1a38N0Lvuo7nYqGByNUFOve1GB3ern4ggSJkvvmtnWnNqeqk4IH5xYBj)Bob1eSvqDVpV5PgOwa7im0asEUByNUiQb3EEXYW37nFjiUi0Vd3S6kfK32aIS6kykcREnyxGKuMpymLXl)BEWjJYeZB43rLUQCLfGB(t6YkkN9gziWnSt3p0kIAWTBIOgCdd2rLuMLRSaqz4ggNBoHiGuWfdZVK3s(3CcQjyRG6EFEZtnqTa2ryObK8C3WoDrudU98ILc59EZxcIlc97WnRUsb5nunLcdUabAsqrz(GXuw4BEWjJYeZBl0MvbrqPClkjjS38N0Lvuo7nYqGByNUFOve1GB3ern4MtOnRcIGsrzHSKKWsz4ggNBoHiGuWfdZVK3s(3CcQjyRG6EFEZtnqTa2ryObK8C3WoDrudU98ILc9EV5lbXfH(D4MvxPG8gUuwDMyFks0xOnRcIGs5wussy1xOHKefLHrugUuM2ANYeIuwykdhkl0qPmUa8411IsnWkjADv5SnDvIQfOmmMYk5tz4qz8qz1zI9PirNBbuQXDW7QKK(I0okK(cnKKOOmFOSnGak9u2a3CCfkLXdLLOiqsDTOudSsIwxvoBthiiUi0V5bNmktmVHFhv6QYvwaU5pPlROC2BKHa3WoD)qRiQb3UjIAWnmyhvszwUYcaLHRqIZnNqeqk4IH5xYBj)Bob1eSvqDVpV5PgOwa7im0asEUByNUiQb3EEXsm8EV5lbXfH(D4MvxPG8MJOmUa841xzd0deqz8qz4szoIYsueiPUwuQbwjrRRkNTPdeexe6uwOHsz1zI9PirFH2SkickLBrjjHvFHgssuuMpugUuM2ANYWHYW5MhCYOmX82WfLjSOeU5pPlROC2BKHa3WoD)qRiQb3UjIAWTqKlktyrjqz4kK4CZjebKcUyy(L8wY)MtqnbBfu37ZBEQbQfWocdnGKN7g2PlIAWTNxSmeU3B(sqCrOFhUz1vkiVvNj2NIeDUfqPg3bVRss6ls7Oq6l0qsIIY8HYkXqkJhkBdiYQRGPiS61GDbsszyegtz8YNY4HY2acO0tzdCZXviPmFOmT1(np4KrzI5nnZsCh8UfLKe2B(t6YkkN9gziWnSt3p0kIAWTBIOgCtimlHYg8uwiljjS3CcraPGlgMFjVL8V5eutWwb19(8MNAGAbSJWqdi55UHD6IOgC75fl59EV5lbXfH(D4MvxPG8wDMyFks05waLACh8UkjPViTJcPVqdjjkkZhkBdiGspLnWnhxHEZdozuMyEd)oQ0vLRSaCZFsxwr5S3idbUHD6(HwrudUDte1GByWoQKYSCLfakdxHIZnNqeqk4IH5xYBj)Bob1eSvqDVpV5PgOwa7im0asEUByNUiQb3E(8MJlGhfeZ7WZF]] )

    storeDefault( [[SimC Frost: machinegun]], 'actionLists', 20171115.094708, [[di0yyaqisGnjs9jefIrjv6usfRsKi1UivdJuCmrSmsYZOsW0OsKRjsQTjseFJKQXHOiNdrjRdrH08ejCpsq7drPoijLfsc9qQKMOirYfPkAJIK8refQrIOOojvLUjIStI8trIAPKspLYuPkTvQk(kIc2RQ)sfdgPddSyO8yPmzO6YkBwQ6ZuPgnj60eEnvvZwOBJWUH8BqdxuoovcTCu9CbtxY1jQTlQ8DevNxu16PsuZNQW(r5NCV3Kae7MjiCLrtfhgkYOmkbOPuGMBz0nlBnbikCzqjGOlPk1j30U4aHDjvAsuprtIgDvjQsjQs9nRXfz1TBQ1kbefU3lLCV38ebWId)kEZACrwDRGUDhNEdcJ4qYrbgnnJ2Lr7YOkGrlqCOsVNdD5HCYKJHPpealoCg1dpy0UmkxgngnfmQkgnnJYLrIMtgK8X1BYC(qfJMcgvfzIr7WODy00mQcy0cehQ0DdkLJlqUDcfKtOpealoCgTZn1WerrL)gelkQXbLaIU5lcx0afKFdbr7gjiUpaUeGy3Ujbi2TuglkQXbLaIUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDjv37npraS4WVI3SgxKv3WK771fT8oficrbD(iacuGrtbJMONAgnnJwG4qLUOL3ParikOpealo8BQHjIIk)TEomuoHIl8VB(IWfnqb53qq0UrcI7dGlbi2TBsaIDlvCyOyuR4c)7M2fhiSlPstI6jAUPDbOmVTW9(6MRkxZpjyUrmuDSBKG4saID71LCH79MNiawC4xXBwJlYQBfiouPhucQACbYTtO4c)lOpealoCgnnJIpm5(EDoWLHCrB6Hc08ZOkKrt9n1WerrL)wphgkNqXf(3nFr4IgOG8BiiA3ibX9bWLae72njaXULkomumQvCH)XODt6Ct7Ide2LuPjr9en30UauM3w4EFDZvLR5Nem3igQo2nsqCjaXU96sU09EZtealo8R4nRXfz1TUmAxgftUVxNliMUCgJMMrNlklYYgUE24HLBCaQnhyVtPCoddICia8kpNr7WOE4bJwG4qLUBqPCCbYTtOGCc9HayXHZODy00mQcy0UmkMCFVoelkQXbLaI0LZy00mkOvICZzOriwGrtbJQIr7Ctnmruu5VXhbKhwCHGd5cun(nFr4IgOG8BiiA3ibX9bWLae72njaXUPDeqEyXfcmkzqGQXVPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDPuFV38ebWId)kEZACrwDdtUVxNliMUCgJMMrvaJ2LrXK771HyrrnoOeqKUCgJMMrbTsKBodncXcmAkyuvmAhgnnJQagTlJoxuwKLnC9SXdl34auBoWENs5Cgge5qa4vEoJMMrlqCOs3nOuoUa52juqoH(qaS4Wz0o3udtefv(BkHKhfi3oyrqOU5lcx0afKFdbr7gjiUpaUeGy3Ujbi2nYmK8Oa5Mrvmcc1nTloqyxsLMe1t0Ct7cqzEBH791nxvUMFsWCJyO6y3ibXLae72RlLsU3BEIayXHFfVznUiRUHj33RZfetxoJrtZOkGr7YOyY996qSOOghucisxoJrtZOGwjYnNHgHybgnfmQkgTdJMMrNlklYYgUE24HLBCaQnhyVtPCoddICia8kpNrtZOfiouP7gukhxGC7ekiNqFiawC4mAAgTlJIpm5(E9SXdl34auBoWENs5Cgge5qa4vEUUCgJ6HhmAdcJ4qYr68ra5Hfxi4qUavJRZhbqGcmkzZOUaJ25MAyIOOYFtjK8Oa52blcc1nFr4IgOG8BiiA3ibX9bWLae72njaXUrMHKhfi3mQIrqOy0UjDUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDj1V3BEIayXHFfVznUiRUPagftUVxhIff14Gsar6YzmAAgTlJoxuwKLnCD)Wyj4GGdAK3dLr4oKlIrgnnJwG4qLEph6Yd5KjhdtFiawC4mAAgTlJgw5GbrYb9smEcz5OkRXOkKrtyup8GrdRCWGi5GEjgpHSCCPSgJQqgnHr7WODyup8Gr5YOf0lbXCkOtQz0uWOUB43udtefv(BqSOOghu7MViCrduq(neeTBKG4(a4saID7MeGy3szSOOghu7M2fhiSlPstI6jAUPDbOmVTW9(6MRkxZpjyUrmuDSBKG4saID71Lit37npraS4WVI3SgxKv3kOB3XP3GWioKCuGrtZODz0UmQcy0cehQ075qxEiNm5yy6dbWIdNr9WdgTlJYLrJrtbJQIrtZOCzKO5KbjFC9MmNpuXOPGrvrMy0omAhgnnJwG4qLUBqPCCbYTtOGCc9HayXHZOPzum5(ED(iG8WIleCixGQX1LZy0o3udtefv(BqSOOghuci6MViCrduq(neeTBKG4(a4saID7MeGy3szSOOghuciIr7M05M2fhiSlPstI6jAUPDbOmVTW9(6MRkxZpjyUrmuDSBKG4saID71LiR79MNiawC4xXBwJlYQBf0T740BqyehsokWOPz0UmAxgDUOSilB46nika5vWPbJ4oniFmQhEWOyY996zIyeWDG9o9CyO0LZy0omAAgftUVxxgPegZ7ek(qUlL6YzmAAgfFyY996CGld5I20dfO5NrviJMAgnnJQagftUVxhIff14Gsar6YzmANBQHjIIk)TGaHZbUHbqWPxMN)MViCrduq(neeTBKG4(a4saID7MeGy3mbcNdCddaYibgnvY8830U4aHDjvAsuprZnTlaL5TfU3x3Cv5A(jbZnIHQJDJeexcqSBVUuIM79MNiawC4xXBwJlYQBDzufWOyY996qSOOghucisxoJrtZOCzKO5KbjFCD81lAIIrtHcz0enmAhg1dpy0UmkMCFVoelkQXbLaI0LZy00mQcyum5(ED)IyuGC7qaAkfOPlNXODUPgMikQ8365Wq5ekUW)U5lcx0afKFdbr7gjiUpaUeGy3Ujbi2TuXHHIrTIl8pgTRQo30U4aHDjvAsuprZnTlaL5TfU3x3Cv5A(jbZnIHQJDJeexcqSBVUusY9EZtealo8R4nRXfz1nqRe5MZqJqSaJs2kKrvXOPzufWODz0cehQ075WqfA5lLtFiawC4mAAgftUVx3Vigfi3oeGMsbA6YzmAAgf0krU5m0ielWOKTczuvmANBQHjIIk)n(iG8WIleCixGQXV5lcx0afKFdbr7gjiUpaUeGy3Ujbi2nTJaYdlUqGrjdcunoJ2nPZnTloqyxsLMe1t0Ct7cqzEBH791nxvUMFsWCJyO6y3ibXLae72RlLO6EV5jcGfh(v8M14IS6gMCFVUFrmkqUDianLc00LZy00mAxgvbm6Crzrw2W19dJLGdcoOrEpugH7qUigzup8GrbTsKBodncXcmkzRqgvfJ25MAyIOOYFRNddvOLVuUB(IWfnqb53qq0UrcI7dGlbi2TBsaIDlvCyOcT8LYDt7Ide2LuPjr9en30UauM3w4EFDZvLR5Nem3igQo2nsqCjaXU96sjUW9EZtealo8R4nRXfz1nqRe5MZqJqSaJs2kKrvDtnmruu5V5ocAcq0bGNdGA7MViCrduq(neeTBKG4(a4saID7MeGy3iJJGMaezu1WZbqTDt7Ide2LuPjr9en30UauM3w4EFDZvLR5Nem3igQo2nsqCjaXU96sjU09EZtealo8R4nRXfz1nqRe5MZqJqSaJs2kKrDHBQHjIIk)TEomuHw(s5U5lcx0afKFdbr7gjiUpaUeGy3Ujbi2TuXHHk0YxkhJ2nPZnTloqyxsLMe1t0Ct7cqzEBH791nxvUMFsWCJyO6y3ibXLae72RlLK679MNiawC4xXBwJlYQByY996(fXOa52Ha0ukqtxo7MAyIOOYFdIff14GA38fHlAGcYVHGODJee3haxcqSB3Kae7wkJff14GAmA3Ko30U4aHDjvAsuprZnTlaL5TfU3x3Cv5A(jbZnIHQJDJeexcqSBVUusk5EV5jcGfh(v8M14IS6wbIdv6UbLYXfi3oHcYj0hcGfhoJMMrlqCOsNqMJpouo4S(ErtmulV(qaS4Wz00mAxgnSYbdIKd6Ly8eYYrvwJrviJMWOE4bJgw5GbrYb9smEcz54szngvHmAcJ25MAyIOOYFRNddLtO4c)7MViCrduq(neeTBKG4(a4saID7MeGy3sfhgkg1kUW)y0UUqNBAxCGWUKknjQNO5M2fGY82c37RBUQCn)KG5gXq1XUrcIlbi2Txxkr979MNiawC4xXBwJlYQBDz0cehQ0vc5ihyVd5cunU(qaS4Wzup8GrlqCOsxPmY94cKBhUmAoKpqgePpealoCgTdJMMr7YOHvoyqKCqVeJNqwoQYAmQcz0eg1dpy0WkhmisoOxIXtilhxkRXOkKrty0o3udtefv(B9CyOCcfx4F38fHlAGcYVHGODJee3haxcqSB3Kae7wQ4WqXOwXf(hJ21L6Ct7Ide2LuPjr9en30UauM3w4EFDZvLR5Nem3igQo2nsqCjaXU96sjKP79MNiawC4xXBwJlYQBf0T740BqyehsokWOPz0UmQcyum5(EDLYi3JlqUD4YO5q(azqKUCgJMMr5YOf0lbXCkOJlWOKnJ6UHZOP0mQkgnnJYLrIMtgK8X1BYC(qfJMcgvvQz0o3udtefv(BkLrUhxGC7WLrZH8bYGOB(IWfnqb53qq0UrcI7dGlbi2TBsaIDJmlJCpUa5Mr1kJgJsggidIUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDPeY6EV5jcGfh(v8MAyIOOYFdIff14GA38fHlAGcYVHGODJee3haxcqSB3Kae7wkJff14GAmAxvDUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDjvAU3BEIayXHFfVPgMikQ83Chbnbi6aWZbqTDZxeUObki)gcI2nsqCFaCjaXUDtcqSBKXrqtaImQA45aO2y0UjDUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3EDjvj37npraS4WVI3SgxKv3uaJIj33RRug5ECbYTdxgnhYhidI0LZUPgMikQ83uc5ihyVd5cun(nFr4IgOG8BiiA3ibX9bWLae72njaXUrMHCeJc7zuYGavJFt7Ide2LuPjr9en30UauM3w4EFDZvLR5Nem3igQo2nsqCjaXU96sQuDV38ebWId)kEtnmruu5V1ZHHYjuCH)DZxeUObki)gcI2nsqCFaCjaXUDtcqSBPIddfJAfx4FmA3u35M2fhiSlPstI6jAUPDbOmVTW9(6MRkxZpjyUrmuDSBKG4saID71Lu5c37npraS4WVI3SgxKv3kOB3XP3GWioKCu4MAyIOOYFBezqYh3HlJMd5dKbr38fHlAGcYVHGODJee3haxcqSB3Kae7MNezqYhNr1kJgJsggidIUPDXbc7sQ0KOEIMBAxakZBlCVVU5QY18tcMBedvh7gjiUeGy3E96wk16bYX6k(6h]] )

    storeDefault( [[SimC Frost: CDs]], 'actionLists', 20171115.094708, [[duKSqaqikswefPQnbjgffXPiQAxKYWGWXuKLjqpdsstJijxJOsBdsI(MamoiP4CejvToII5jK09iQyFejoisyHePEisQjcjHlkuSrHeJKIu6KcOzsrkCti1oj0pjsQmuiPAPcXtPAQuuxLiPyRcP(krsP3cjLCxiPu7v1FjvdgQdl1IrQhRWKL0LrTzb9ziA0eXPj51ijZMs3MGDd63IgUI64uKIwoWZLy6kDDkSDHsFhj68eLwpfPY8fQ2pI)0nFxSf47UsGAcokGSSYqWuJkk39zEOARY01RkHxmOCNUhHTCx4lgeXuatiMqOfCkiQmOCV7dGAEVFNIXQsy5MV40nFpgytB56L(UpaQ59oWaQg6ZjLmqRYHQHAjyPihcoiccgfc2ue82wgUA0aUxj6zOErbRGgzwAng20wUENcALvTYEVbJgY6BcamCVhiSQg9MG7WeY3rN1OBGylW3Vl2c8DkaJgYeS5eay4EpcB5UWxmiIPaMqCpcxsdWGl3837ulHhuHoJLfy4E67OZQylW3)EXG389yGnTLRx67(aOM371C1ObCVs0Zq9IcwbnYS0ARAqLcIKGrHGbgq1qFoPKbAvounulblf5qWYfbbJcbdmGmbhvco4DkOvw1k79gmAiRVjaWW9EGWQA0BcUdtiFhDwJUbITaF)UylW3PamAitWMtaGHlbBYK83JWwUl8fdIykGje3JWL0am4Yn)9o1s4bvOZyzbgUN(o6Sk2c89VxevV57XaBAlxV039bqnV33ejslRnY0wtkHfcgfc2ecM2imuBwzTnqpd1dbzz1mMjy5VtbTYQwzVtBZSQhAaK9EGWQA0BcUdtiFhDwJUbITaF)UylW3L2MzLGJIbq27ryl3f(IbrmfWeI7r4sAagC5M)ENAj8Gk0zSSad3tFhDwfBb((3lkv389yGnTLRx67(aOM37BIePL1gzARjLWcbJcbBcbtBegQnRS2gONH6HGSSAgZeS83PGwzvRS3PzqHbuPGiVhiSQg9MG7WeY3rN1OBGylW3Vl2c8DPzqHbuPGiVhHTCx4lgeXuatiUhHlPbyWLB(7DQLWdQqNXYcmCp9D0zvSf47FVOCV57XaBAlxV03PGwzvRS3nkSUAzHY9aHv1O3eChMq(o6SgDdeBb((DXwGVl1uycoWLfk3JWwUl8fdIykGje3JWL0am4Yn)9o1s4bvOZyzbgUN(o6Sk2c89VxevEZ3Jb20wUEPV7dGAEVdmGCrBvcS(M6YLGJkbJQemkeSjeSPi4AUA0aUxj6zOErbRGgzwATvnOsbrsWXJtWadOAOpNuYaTHbaWWLGLcbJkrqWYFNcALvTYEVcAdKsw9muVKg2YDQLWdQqNXYcmCp9D0zn6gi2c897ITaFp(imSrvuvUmh30QwwqMjPcbQbbQrgzKrgzKrgzMMqitq5gugzKrgzKjUeulubOnqkzj4mKG90WwqTJljo4ofaKL7WwGLtf0giLS6zOEjnSL7ryl3f(IbrmfWeI7r4sAagC5M)Epqyvn6nb3HjKVJoRITaF)7fd4MVhdSPTC9sF3ha18EFtKiTS2CUQewiyuiytiyAJWqTzL12a9mupeKLvZyMGrHGnHGR5Qrd4ELONH6ffScAKzP1w1GkfejbhpobtBegQL0w1YGEvjuZyMGJhNG32YWvtIbejduqK6adiRtj3ZjuJHnTLReS8eS83PGwzvRS3NZvLW7bcRQrVj4omH8D0zn6gi2c897ITaFh1ZvLW7ryl3f(IbrmfWeI7r4sAagC5M)ENAj8Gk0zSSad3tFhDwfBb((3lIAU57XaBAlxV039bqnV332YWvlPTQLb9QsOgdBAlxjyuiyti4rM2AsjulPTQLb9QsOgGfAfSqWsHGdIGGJhNGhzARjLqTK2Qwg0RkHAawOvWcbhvcEcbbhpobBkcEBldxn1Gh9SgdBAlxjy5VtbTYQwzVpRS2gONH6HGSS3dewvJEtWDyc57OZA0nqSf473fBb(oQRS2gqWzibhfqw27ryl3f(IbrmfWeI7r4sAagC5M)ENAj8Gk0zSSad3tFhDwfBb((3lk1FZ3Jb20wUEPV7dGAEVVTLHRgnG7vIEgQxuWkOrMLwJHnTLRemke8itBnPeQrd4ELONH6ffScAKzP1aCxLLGrHGbgq1qFoPKbAddaGHlblfcwUiUtbTYQwzVpRS2gONH6HGSS3dewvJEtWDyc57OZA0nqSf473fBb(oQRS2gqWzibhfqwwc2Kj5VhHTCx4lgeXuatiUhHlPbyWLB(7DQLWdQqNXYcmCp9D0zvSf47FV4eIB(EmWM2Y1l9DFauZ79TTmC1ObCVs0Zq9IcwbnYS0AmSPTCLGrHGhzARjLqnAa3Re9muVOGvqJmlTgGfAfSqWsHGLke3PGwzvRS3NvwBd0Zq9qqw27bcRQrVj4omH8D0zn6gi2c897ITaFh1vwBdi4mKGJcillbBsq5VhHTCx4lgeXuatiUhHlPbyWLB(7DQLWdQqNXYcmCp9D0zvSf47FV400nFpgytB56L(UpaQ59(2wgUAsmGizGcIuhyazDk5EoHAmSPTC9of0kRAL9(SYABGEgQhcYYEpqyvn6nb3HjKVJoRr3aXwGVFxSf47OUYABabNHeCuazzjytqv5VhHTCx4lgeXuatiUhHlPbyWLB(7DQLWdQqNXYcmCp9D0zvSf47FV4uWB(EmWM2Y1l9DFauZ79nrI0YAJmT1KsyHGrHGnHGPncd1MvwBd0Zq9qqwwnJzcw(7uqRSQv270aUxj6zOErbRGgzw67bcRQrVj4omH8D0zn6gi2c897ITaFxAa3RecodjyxbRGgzw67ryl3f(IbrmfWeI7r4sAagC5M)ENAj8Gk0zSSad3tFhDwfBb((3loHQ389yGnTLRx67(aOM37SPPHAEMRAJ0w1LWnyjyuiytiytiyAJWqTrAR6s4gSALThurWsroe8eccgfc2uemTryOwsBvld6vLqnJzcwEcoECcEBasE1wLaRVPEvXeCuLdbJCujy5VtbTYQwzVpARvVhRkH6wvzVtTeEqf6mwwGH7PVJoRr3aXwGVFxSf47u3wlbtXyvjKGnnuL9ofaKL7WwGLJP3vcutWrbKLvgcEK2kblHBWA6VhHTCx4lgeXuatiUhHlPbyWLB(79aHv1O3eChMq(o6Sk2c8Dxjqnbhfqwwzi4rAReSeUb73lojv389yGnTLRx67(aOM37BIePL1gzARjLWcbJcbBcbdmGmblf5qWtemkemWaQg6ZjLmqByaamCjyPihcoiccgfc2ec2ue82wgUAHG00Xq9zdBH1yytB5kbhpobdmGmbhvcoibhpobtBegQnRS2gONH6HGSSAawOvWcbhv5qWtbjy5jyuiytiytrWBBz4QHSxjmqbrQx2eiOXWM2YvcoECc2ue8itBnPeQbyHeuylxk6uQGld0aCxLLGLNGrHGnHGPncd1MvwBd0Zq9qqwwnJzcoECc2ue82wgUAQbp6zng20wUsWYtWYFNcALvTYEpPTQLb9Qs49aHv1O3eChMq(o6SgDdeBb((DXwGVl1rBvld6vLW7ryl3f(IbrmfWeI7r4sAagC5M)ENAj8Gk0zSSad3tFhDwfBb((3loj3B(EmWM2Y1l9DFauZ79nrI0YAJmT1KsyHGrHGnHGnfbtBegQjXaIKbkisDGbK1PK75eQzmtWOqWadix0wLaRVPEqcwkemYrLGrHGbgq1qFoPKbAddaGHlbhvcwQqqWYFNcALvTYExIbejduqK6adiRtj3Zj8EGWQA0BcUdtiFhDwJUbITaF)UylW3nTgqKmqbrsWrmGmbl1Y9CcVhHTCx4lgeXuatiUhHlPbyWLB(7DQLWdQqNXYcmCp9D0zvSf47F)EhvWHTHDV0F)ba]] )

    storeDefault( [[SimC Frost: cold heart]], 'actionLists', 20171115.094708, [[dGd)eaGErr1MeL2fcBtsv7tvPzlX8LKYnru3gv2jQAVq7MK9RyuIcdtv63knyvgUQQdsv0PikDmQQttyHufwQKyXO0Yj1dfvEQWYqK1jkIjkkstLQ0Kbz6axusXJr6zss11jYgffLTkPYMfz7skDyPUhrvtJOO5ru47ss65uz0O41IQoPQW3iQCnjjoVQIpRk6VG6Yug9rVyW3CggHGl3CzMEDGmzo6wGMJXAnaJ43OIUiY8giwfYtQk(yuXkw7mKN0RVC(V(VeK8jvpPQGrq1IFagy4jfiwLd9I8(OxmQr1Sfdc9aJGQf)amyLsjc6wGGzSwdiCGMMFo5NJ07CzNJvkLiKumB5dSdOn1tadH0)CzNJUBbARQI4xukTgEtWj96aeAJRfk3CFNREm8KvueGpyqzAHYbVjyb1W4HcsqBWQXqTkddYluDTMV5mmWGV5mmYX0cLBUnn3dQHrfRyTZqEsV(Y5)IrfZTsAQ5qViaJCmgnp5TwJZuaKfdYleFZzyGaKNe6fJAunBXGqpWiOAXpadwPuI4xukTgEtWj96aes)ZLDowPuI4xukTgEtWj96aeAJRfk3CYyUNuO5YoxgZXkLse0TabZyTgq4ann)CFLFoF)5Qw1MlJ5yLsjc6wGGzSwdiCGMMFUVYpN)7CzNZzay2vj5iactt6fwM)05(o37CYoNSy4jROiaFWGY0cLdEtWcQHXdfKG2GvJHAvggKxO6AnFZzyGbFZzyKJPfk3CBAUhuBUm8LfJkwXANH8KE9LZ)fJkMBL0uZHErag5ymAEYBTgNPailgKxi(MZWabiF1rVyuJQzlge6bgbvl(byWkLseskMT8b2b0M6jGHq6FUSZXkLseskMT8b2b0M6jGHqBCTq5MtgZ9Kcnx25yLsjc6wGGzSwdiCGMMFUVZ5x)CzNJUBbARQI4xukTgEtWj96aeAJRfk3CFNREm8KvueGpyqzAHYbVjyb1W4HcsqBWQXqTkddYluDTMV5mmWGV5mmYX0cLBUnn3dQnxgKKfJkwXANH8KE9LZ)fJkMBL0uZHErag5ymAEYBTgNPailgKxi(MZWabiVmrVyuJQzlge6bgbvl(byWkLse0TabZyTgq4ann)CFLFozox25aT(PbiacodgSWqcBozi)CpPqy4jROiaFWGY0cLdEtWcQHXdfKG2GvJHAvggKxO6AnFZzyGbFZzyKJPfk3CBAUhuBUmQUSyuXkw7mKN0RVC(VyuXCRKMAo0lcWihJrZtER14mfazXG8cX3CggiabyKPwQLka0deGi]] )

    storeDefault( [[SimC Frost: obliteration]], 'actionLists', 20171115.094708, [[d0JohaGEIkAtKsTlf12iQW(uGwhus1SPy(kGBQiNgY3aLESs2ji7vSBuTFj(jrLmmOyCqjQZdkgfrvgSKgor6qus6uev1Xiv3MQwOcAPe0IvQLtYdjqpfzzeLNtLjcLetLqMmunDPUiuQptjUSQRtP2iLu2kPKndQ2Uc1Hb(kuImnOKY8GssJKsQ(lrmAc13jfojPONbLW1OK4EevQxRq(nkhKao6ruiS5GT54zhIwkK0ouiiG)HiKxWs1AkMRX6LkBBq9vGgX4HeEZbUhizy0HvhJoMzz6YKdzwjej9leWGKtqJy8ajZk6Hey1ig3frbspIcHnhSnhpddrlfsAhQbMZ7zlGw8viUfjUMP8ZNd2MJhsGnYGAycPUNPC3CNtIgiEFvin54OfOzQqCg)HMy4Abuqa)dfcc4FiH3ZuUBUZvQyjeVVkKWBoW9ajdJoS6ycj8oMTADxeLoKGI)A0eB89N3zhAIHdb8pu6ajlIcHnhSnhpddrlfsAhABdh(8iKXG4wK4blXi(NTLwQAxQGvJgFjNFp6UsDWsvpKaBKb1WecUI5A3cMw8dPjhhTantfIZ4p0edxlGcc4FOqqa)dznfZ1UfmT4hs4nh4EGKHrhwDmHeEhZwTUlIshsqXFnAIn((Z7SdnXWHa(hkDGWIike2CW2C8mmeTuiPDOTnC4ZJqgdIBrIhSeJ4F2wAPoWaLQ8kvWQrJVKZVhDxPoOCxQyrPQDPA1sDBdh(Sc5)ST0sv(HeyJmOgMqSTb1xb6hstooAbAMkeNXFOjgUwafeW)qHGa(hsU2guFfOFiH3CG7bsggDy1Xes4DmB16UikDibf)1Oj247pVZo0edhc4FO0bcRfrHWMd2MJNHHOLcjTdTTHdFwH8F2wAPQDPcwnA8LC(9O7k1blv9qcSrgudtiXmnmiUfjBdW1H0KJJwGMPcXz8hAIHRfqbb8puiiG)HSotddIBPuhAaUoKWBoW9ajdJoS6ycj8oMTADxeLoKGI)A0eB89N3zhAIHdb8pu6azLike2CW2C8mmeTuiPDiRwQBB4WNvi)NTLwQAxQGvJgFjNFp6UsDWsvwPQDPQS5VuhSuXIsv7sTbMZ7z4QF5eXTiboZY85GT54LQ2LAdmN3ZwaT4RqClsCnt5NphSnhpKaBKb1WesmtddIBrY2aCDin54OfOzQqCg)HMy4Abuqa)dfcc4FiRZ0WG4wk1HgGRlv5Pl)qcV5a3dKmm6WQJjKW7y2Q1Dru6qck(RrtSX3FENDOjgoeW)qPdKCerHWMd2MJNHHOLcjTdz1sDBdh(Sc5)ST0sDGbkvLn)U5g5VKMjrVuhuUlvll8sDGbkvLnhTKiLPXvZ4hoAH6sfRwQYWesGnYGAycbxXCTexRqJEin54OfOzQqCg)HMy4Abuqa)dfcc4FiRPyUUuPwHg9qcV5a3dKmm6WQJjKW7y2Q1Dru6qck(RrtSX3FENDOjgoeW)qPdeSruiS5GT54zyiAPqs7qBB4WNvi)NTLgsGnYGAycjMPHbXTizBaUoKMCC0c0mvioJ)qtmCTakiG)Hcbb8pK1zAyqClL6qdW1LQ8Kj)qcV5a3dKmm6WQJjKW7y2Q1Dru6qck(RrtSX3FENDOjgoeW)qPdewoIcHnhSnhpddjWgzqnmHyBdQVc0pKMCC0c0mvioJ)qtmCTakiG)Hcbb8pKCTnO(kq)svE6YpKWBoW9ajdJoS6ycj8oMTADxeLoKGI)A0eB89N3zhAIHdb8pu60HWkhoW20zy6ea]] )

    storeDefault( [[SimC Frost: standard]], 'actionLists', 20171115.094708, [[di06taqikfTjkv(eQeQrHQQtrISkujvTlQYWqfhtIwMaEgjQAAusX1OKQTHkP8nuPgNav6COsW6eOIMhjk3JsH9HkjhevPfIQYdPKmrbQWfrvSrbkFevsLrIkHCskvDtPQDIu)Kevwkj8uIPsj2kLsFvGQ2RYFf0Gj1HbwmsESKMSuUSQndjFwcgnj1Pr51KKzl0THy3i(nOHlvooLuA5q9CQmDrxNQA7qQ(oKY5LqRhvIMVaz)u8kNLj8qauX3g1ePIzD5Kj0aKpryiwz0bddDzWPr7saPbWTjkE8a3hDaoLCxYPKJxGYaCTawFI09kdezCjizqYOdy9Yj8wtgK4MLrxolt4HaOIVn(MivmRlNKG4jPhRwmmbriX5DcGk(MrBNrt5JcLhRwmmbriX5HpcGrCgTYSHrxO2MWlflYYItqHHUm0LyMQpXEsJvbjepHajFspSzlatdq(Kj0aKpjyyOlnAjXmvFIIhpW9rhGtj3LCMO4oOpUE3SSCIvQFvvpe9JCsoQj9Wgna5two6aZYeEiaQ4BJVjsfZ6YjjiEs65udY8ygPqOlXmv35DcGk(MrBNr3oLpkuEyaxcXS69CjOQYOTHrBDJ2oJMYhfkVcGu9XmsHqxcXiEUeuvz0kZOdy02z020OP8rHYdZqUNF3eEPyrwwCckm0LHUeZu9j2tASkiH4jei5t6HnBbyAaYNmHgG8jbddDPrljMP6gn)LknrXJh4(OdWPK7sotuCh0hxVBwwoXk1VQQhI(rojh1KEyJgG8jlhTYplt4HaOIVn(MivmRlNWVrt5JcLhMHCp)oJ2oJ(wRpRR7nVUJDh9JbK6dHOct1p8uqsicaNfXgTsgDqbz0jiEs6vaKQpMrke6sigX7eav8Tj8sXISS4e8rGy3J35crJrYJNypPXQGeINqGKpPh2SfGPbiFYeAaYNO4iqS7X7CgDWZi5Xtu84bUp6aCk5UKZef3b9X17MLLtSs9RQ6HOFKtYrnPh2ObiFYYrBnZYeEiaQ4BJVjsfZ6Yj8B03A9zDDV5Pcgtgg4cjhnuqFslenwmA02z0jiEs6Hcd5Ytc78JU7DcGk(MrBNr7Egsbj(oVKDCjximqx1OTHrxA0kz0bfKrJ9j35LmKhMWqRXOvMrxO2mA7mAkFuO8u7tkCmJuie7tEiAh0bjE(Dt4LIfzzXjqQilpgKFI9KgRcsiEcbs(KEyZwaMgG8jtObiFIYrfz5XG8tu84bUp6aCk5UKZef3b9X17MLLtSs9RQ6HOFKtYrnPh2ObiFYYrB9zzcpeav8TX3ePIzD5e(nABA0jiEs65udY8ygPqOlXmv35DcGk(MrhuqgD7u(Oq5HbCjeZQ3ZLGQkJwzgT1nALmA7mASpHvd7GODSx7OyvwA0kZOl5mHxkwKLfNGcdDzOlXmvFI9KgRcsiEcbs(KEyZwaMgG8jtObiFsWWqxA0sIzQUrZFaLMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJMRnlt4HaOIVn(MivmRlNq5JcLhMHCp)Uj8sXISS4e1q0ImsHqQiWLtSN0yvqcXtiqYN0dB2cW0aKpzcna5t4IGOfzKcgnFrGlNO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJM7zzcpeav8TX3ePIzD5e(n6BT(SUU38ubJjddCHKJgkOpPfIglgnA7m6eepj9qHHC5jHD(r39obqfFZOTZODpdPGeFNxYoUKlegORA02WOlnALm6GcYOX(K78sgYdtyO1nALz0fQTj8sXISS4eivKLhdYpXEsJvbjepHajFspSzlatdq(Kj0aKpr5OIS8yqEJM)sLMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJo4olt4HaOIVn(MivmRlNKWcfI3RcHXgenIZOTZO53O53OV16Z66EZRcjoioDHvySfwH4B0bfKrt5JcLxhlgb4qiQquyOl987mALmA7mAkFuO88jQHXIHUeFsHuTNFNrBNr3oLpkuEyaxcXS69CjOQYOTHrBDJwPj8sXISS4ehJ0WGcqhWfIYhxCI9KgRcsiEcbs(KEyZwaMgG8jtObiFIWinmOa0b4IDgDW8XfNO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJMlmlt4HaOIVn(MivmRlNG9jSAyheTJ9AhfRYsJwzgDjhJ2oJ2MgnLpkuEQ9jfoMrkeI9jpeTd6Gep)Uj8sXISS4euyOldDjMP6tSN0yvqcXtiqYN0dB2cW0aKpzcna5tcgg6sJwsmt1nA(vELMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJUKZSmHhcGk(24BIuXSUCcLpkuEQyXiJuiebuvZi3ZVZOTZO53OTPrFR1N119MNkymzyGlKC0qb9jTq0yXOrhuqgnOMm0F4jhHDNrZv2WOdy0knHxkwKLfNGcdDPRwmv)j2tASkiH4jei5t6HnBbyAaYNmHgG8jbddDPRwmv)jkE8a3hDaoLCxYzII7G(46DZYYjwP(vv9q0pYj5OM0dB0aKpz5OllNLj8qauX3gFtKkM1LtO8rHYtflgzKcHiGQAg5E(Dt4LIfzzXjqQilpgKFI9KgRcsiEcbs(KEyZwaMgG8jtObiFIYrfz5XG8gn)buAIIhpW9rhGtj3LCMO4oOpUE3SSCIvQFvvpe9JCsoQj9Wgna5two6YaZYeEiaQ4BJVjsfZ6YjyFcRg2br7yV2rXQS0OvMrhGZeEPyrwwCckm0LHUeZu9j2tASkiH4jei5t6HnBbyAaYNmHgG8jbddDPrljMP6gn)wJstu84bUp6aCk5UKZef3b9X17MLLtSs9RQ6HOFKtYrnPh2ObiFYYrxQ8ZYeEiaQ4BJVjsfZ6YjGAYq)HNCe2DgnxzdJoWeEPyrwwCc(iqS7X7CHOXi5XtSN0yvqcXtiqYN0dB2cW0aKpzcna5tuCei294DoJo4zK8yJM)sLMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJU0AMLj8qauX3gFtKkM1Lta1KH(dp5iS7mAUYggDGj8sXISS4KcrqLbIHGg6as9tSN0yvqcXtiqYN0dB2cW0aKpzcna5t46IGkdenAEBOdi1prXJh4(OdWPK7sotuCh0hxVBwwoXk1VQQhI(rojh1KEyJgG8jlhDP1NLj8qauX3gFtKkM1Lta1KH(dp5iS7mAUYggTYpHxkwKLfNGcdDPRwmv)j2tASkiH4jei5t6HnBbyAaYNmHgG8jbddDPRwmvFJM)sLMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJUKRnlt4HaOIVn(MivmRlNytJobXtsVcGu9XmsHqxcXiENaOIVz0bfKrxHWydIgXdFei294DUq0yK8yp8ramIZO5kJMFJUqTz0C9gDaJwPj8sXISS4eivKLhdYpXEsJvbjepHajFspSzlatdq(Kj0aKpr5OIS8yqEJMFLxPjkE8a3hDaoLCxYzII7G(46DZYYjwP(vv9q0pYj5OM0dB0aKpz5Ol5EwMWdbqfFB8nrQywxoXMgnLpkuEQ9jfoMrkeI9jpeTd6Gep)oJ2oJMFJg7tUZlzipmHHbmAUYOluBgDqbz020Otq8K0dfgYLNe25hD37eav8nJwPj8sXISS4e1qmjeIkengjpEI9KgRcsiEcbs(KEyZwaMgG8jtObiFcxeetmAikJo4zK84jkE8a3hDaoLCxYzII7G(46DZYYjwP(vv9q0pYj5OM0dB0aKpz5OldUZYeEiaQ4BJVjsfZ6Yj20O53OX(ewnSdI2XEvFm(K0OvMrBDogTDgDcINKEqQilpgKmiX7eav8nJ2oJUcHXgenIhKkYYJbjds8WhbWioJwz2WOluBgTst4LIfzzXjOWqxg6smt1NypPXQGeINqGKpPh2SfGPbiFYeAaYNemm0LgTKyMQB08BDLMO4XdCF0b4uYDjNjkUd6JR3nllNyL6xv1dr)iNKJAspSrdq(KLJUKlmlt4HaOIVn(MivmRlNytJobXtsVcGu9XmsHqxcXiENaOIVz0bfKrNG4jPhRwmmbriX5DcGk(2eEPyrwwCcKkYYJb5NypPXQGeINqGKpPh2SfGPbiFYeAaYNOCurwEmiVrZV1O0efpEG7JoaNsUl5mrXDqFC9Uzz5eRu)QQEi6h5KCut6HnAaYNSC0b4mlt4HaOIVn(MivmRlNKWcfI3RcHXgenIZOTZO53OTPrNG4jPhf(GuDievOJrAyqbOd4DcGk(MrhuqgDcWfE6LmKhMWWg7gTYm6kegBq0iEu4ds1HquHogPHbfGoGh(iagXz0knHxkwKLfNCKoiAhhI9jpeTd6GKj2tASkiH4jei5t6HnBbyAaYNmHgG8j8G0br7yJwHp5gDWFqhKmrXJh4(OdWPK7sotuCh0hxVBwwoXk1VQQhI(rojh1KEyJgG8jlxoj44Oa(XC8TCda]] )

    storeDefault( [[SimC Frost: bos pooling]], 'actionLists', 20171115.094708, [[diuDtaqiqsBIc8jkuPgfOYPaPwfQQODrsdJuCmqSmb1ZeKAAcexdvvTnqI(gfY4OqvCokuvRdvvO5rHY9ajSpkrhKsyHuqpKsLjsHk5IuQAJcs(ifQsJevvWjfe3evzNKQFkqYsPKEkvtvaBvG6RuOI9I8xkAWqoSIfJkpwIjlPlRAZGYNjrJMeonrVMsz2cDBPA3O8BLgoP0Xfi1YbEoHPl66sPTJQY3LIopOQ1JQknFPW(HAccfGC7zdx8vIJCVaKAtYjxF6NCx2TdJcfyfj)igXTcms7Urjtj5wF8J4KEynqmcIgiAuddjmugM)K7AFrorj)oPCzKEy(dHClkPCzckaPdHcqU9SHl(kzi5Ebi1MKNt8Suv5KkoqYuAkYf0vpB4IVsUfCYOmHNCW7lq84fcZMswEa5HWQYYKlGC2Yo582AWdqF6NCY1N(j367lq84fcmY4iz5bKB9XpIt6H1aXiiAi36fBlOCbfGsYTtXl24T89(zjXroVTQp9toLKEyka52ZgU4RKHK7fGuBsoxlmyQaz)QTAXidWiql7c1u2VzUMbbJmggbhgPSuXi(jgfgJGMCl4Krzcp5k2MrjtPjxCej5HWQYYKlGC2Yo582AWdqF6NCY1N(jNFyBgLmLyKHXrKKB9XpIt6H1aXiiAi36fBlOCbfGsYTtXl24T89(zjXroVTQp9toLKEOPaKBpB4IVsgsUxasTj5Gw2fQPSFZCnHsmYyyKYsfJmaJGkgLt8Suv5KkoqYuAkYf0vpB4IVsUfCYOmHN8LlkZdM8KhcRkltUaYzl7KZBRbpa9PFYjxF6N8GIlkZdM8KB9XpIt6H1aXiiAi36fBlOCbfGsYTtXl24T89(zjXroVTQp9toLKEqOaKBpB4IVsgsUxasTj5Gw2fQPSFZCndcgzmmszPIrgGrWHrLDJ1TjtLd8jvyUWmfswfmkxXOcEFKmbgzjgPbJA0aJaTmzXu728a16HjlYeJSekWOqRbJGMCl4Krzcp5lxuMhm5jpewvwMCbKZw2jN3wdEa6t)KtU(0p5bfxuMhm5Xi4Gan5wF8J4KEynqmcIgYTEX2ckxqbOKC7u8InElFVFwsCKZBR6t)KtjPZFka52ZgU4RKHK7fGuBsoOLjlMA3MhOwpmzrMyKXWi(JrgGrINMClRvOMYdGy8ndI2cgzjgPbJmaJk7gRBtMkh4tQWCHzkKSkyuUIrf8(izcmYsmsdgzagbhgbvmkN4zPQqXK5bsMstrcK2Uq9SHl(kg1ObgvpxlmyQGHFxGSCvrofByKXWi(JrnAGrLDJ1TjtLd8jvyUWmfswfmkxXOcEFKmbgzjgbLye0KBbNmkt4jhgyfPPibsBN8qyvzzYfqoBzNCEBn4bOp9to56t)KhkWksmYtG02j36JFeN0dRbIrq0qU1l2wq5ckaLKBNIxSXB579ZsIJCEBvF6NCkjDOKcqU9SHl(kzi5Ebi1MKZ1cdMkq2VARwmYam6bDRuR2xv1EG48DWWk3CHzMkU55wMzFaj8aYTGtgLj8KdEFbIhVqy2uYYdipewvwMCbKZw2jN3wdEa6t)KtU(0p5wFFbIhVqGrghjlpaJGdc0KB9XpIt6H1aXiiAi36fBlOCbfGsYTtXl24T89(zjXroVTQp9toLKUruaYTNnCXxjdj3laP2KCUwyWubY(vB1IrgGrWHrCTWGPcEFbIhVqy2uYYduB1IrnAGrLDJ1Tjtf8(cepEHWSPKLhOcEFKmbgzjgPSuXOgnWi4WiOIrpOBLA1(QQ2deNVdgw5MlmZuXnp3Ym7diHhGrgGrqfJYjEwQQCsfhizknf5c6QNnCXxXiOXiOj3cozuMWtUITzuYuAYfhrsEiSQSm5ciNTStoVTg8a0N(jNC9PFY5h2MrjtjgzyCejgbheOj36JFeN0dRbIrq0qU1l2wq5ckaLKBNIxSXB579ZsIJCEBvF6NCkjDJhka52ZgU4RKHK7fGuBsouXiUwyWubY(vB1IrgGrqfJGdJYjEwQQCsfhizknf5c6QNnCXxXidWiOIrWHrLDJ1Tjtf8(cepEHWSPKLhOcEFKmbgzjgbhgPSuXi(jgfgJGgJA0aJaTSJrwIrbbJGgJGgJmaJaTSJrwIrHMCl4Krzcp5lxuMhm5jpewvwMCbKZw2jN3wdEa6t)KtU(0p5bfxuMhm5Xi4cdn5wF8J4KEynqmcIgYTEX2ckxqbOKC7u8InElFVFwsCKZBR6t)KtjPB8PaKBpB4IVsgsUxasTj55Quz8QLDJ1TjtGrgGrWHrWHrpOBLA1(QAzzIfKcZYgRMLfCmQrdmIRfgmvTYyCaMlmtyGvKQTAXiOXidWiUwyWuBzk2i8MIeCMYuHARwmYamQEUwyWubd)Uaz5QICk2WiOaJ4pgbn5wWjJYeEYfswfmkxXimH1cGN8qyvzzYfqoBzNCEBn4bOp9to56t)K7swfmkxXyClWOq1cGNCRp(rCspSgigbrd5wVyBbLlOausUDkEXgVLV3pljoY5Tv9PFYPK0HOHcqU9SHl(kzi5Ebi1MKdAzYIP2T5bQ1dtwKjgzmmk0AWidWi4WiOIr5eplvfkMmpqYuAksG02fQNnCXxXOgnWO65AHbtfm87cKLRkYPydJmggXFmQrdmQSBSUnzQCGpPcZfMPqYQGr5kgvW7JKjWilXiql7c1u2VzUMbbJGMCl4Krzcp5WaRinfjqA7KhcRkltUaYzl7KZBRbpa9PFYjxF6N8qbwrIrEcK2ogbheOj36JFeN0dRbIrq0qU1l2wq5ckaLKBNIxSXB579ZsIJCEBvF6NCkjDiqOaKBpB4IVsgsUxasTj5CTWGPAtgJsMsZ(uuizxTvlgzagbhgbvm6bDRuR2xvTTXucgHj7nHTTSQztzmIrnAGrtjL8DZZExEbgzjuGrHXiOj3cozuMWtomWksrb(uXjpewvwMCbKZw2jN3wdEa6t)KtU(0p5HcSIuuGpvCYT(4hXj9WAGyeenKB9ITfuUGcqj52P4fB8w(E)SK4iN3w1N(jNsshsyka52ZgU4RKHK7fGuBs(usjF38S3LxGrwcfyuyYTGtgLj8KRmof5enNkFdRCYdHvLLjxa5SLDY5T1GhG(0p5KRp9tUXBCkYjIrwu5ByLtU1h)ioPhwdeJGOHCRxSTGYfuakj3ofVyJ3Y37NLeh582Q(0p5us6qcnfGC7zdx8vYqY9cqQnjFkPKVBE27YlWilHcmkm5wWjJYeEYbVVaXJximBkz5bKhcRkltUaYzl7KZBRbpa9PFYjxF6NCRVVaXJxiWiJJKLhGrWfgAYT(4hXj9WAGyeenKB9ITfuUGcqj52P4fB8w(E)SK4iN3w1N(jNsshsqOaKBpB4IVsgsUxasTj5tjL8DZZExEbgzjuGrHMCl4Krzcp5WaRiff4tfN8qyvzzYfqoBzNCEBn4bOp9to56t)KhkWksrb(uXXi4Gan5wF8J4KEynqmcIgYTEX2ckxqbOKC7u8InElFVFwsCKZBR6t)KtjPdH)uaYTNnCXxjdj3laP2KC4WOYUX62KPcEFbIhVqy2uYYdubVpsMaJmggbhgPSuXi(jgfgJGgJA0aJ4AHbtv5KkoqYuAkYf0vf5uSHrqbgbrdgbngzagv2nw3MmvoWNuH5cZuizvWOCfJk49rYeyKLyeOLDHAk73mxZGGrgGr5eplvvoPIdKmLMICbD1ZgU4RyKbyeCyeuXOCINLQcftMhizknfjqA7c1ZgU4RyuJgyu9CTWGPcg(DbYYvf5uSHrgdJ4pg1Obgv2nw3MmvoWNuH5cZuizvWOCfJk49rYeyKLyeuIrqtUfCYOmHNCyGvKMIeiTDYdHvLLjxa5SLDY5T1GhG(0p5KRp9tEOaRiXipbsBhJGlm0KB9XpIt6H1aXiiAi36fBlOCbfGsYTtXl24T89(zjXroVTQp9toLKoeOKcqU9SHl(kzi5Ebi1MKdvmIRfgmvGSF1wTyKbyeCyeuXOCINLQkNuXbsMstrUGU6zdx8vmQrdmQSBSUnzQG3xG4XleMnLS8avW7JKjWilXiLLkgbn5wWjJYeEYxUOmpyYtEiSQSm5ciNTStoVTg8a0N(jNC9PFYdkUOmpyYJrWfAOj36JFeN0dRbIrq0qU1l2wq5ckaLKBNIxSXB579ZsIJCEBvF6NCkjDigrbi3E2WfFLmKCVaKAtYl7gRBtMkh4tQWCHzkKSkyuUIrf8(izcmYsmc0YUqnL9BMRzqWidWi4WiOIr5eplvfkMmpqYuAksG02fQNnCXxXOgnWO65AHbtfm87cKLRkYPydJmggXFmQrdmQSBSUnzQCGpPcZfMPqYQGr5kgvW7JKjWilXiOeJGMCl4Krzcp5WaRinfjqA7KhcRkltUaYzl7KZBRbpa9PFYjxF6N8qbwrIrEcK2ogbxOHMCRp(rCspSgigbrd5wVyBbLlOausUDkEXgVLV3pljoY5Tv9PFYPKsYnUoSPnMKHusea]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20171115.094708, [[dCZBdaGEKIAtOGDHQEnsP2hGA2iz(uGBIuYTPKDIk7fA3QA)s1OqQYWqPFR0GLYWb4GOqNcPQoMK6CifzHG0srulMsTCrpL0YKKNtLjci1uPOMmOMUWfPGoTkxM46iSrjOTci2mI8yGoSIzHuXNPiFNcDEj0FPQrdIVHIoPezCiv6AasUNe16KapdPGdHuOXA0mQkab8gQJMN42h5QaQAuvW8aeOIk3yjOwci9wH56IEd6Qf0BWcPHGkqLSqjJtqUk2AMS0TIM4zzzPBfQKLbUO5Zsqnj(d0dynkjFCwIpwptw60BjXlo(4SeFS(kuzemU9DOzKRgnJQH)ytjWiuuvW8aeOMe)b6bSgLKhKit5JEd4Y9gt2EJHEljEP3aUCVvHk3yjOcnLjG0BlPEtVhohtRBqLr7J6IIOANYeq8ljV7E4CmTUbvYcLmob5QyRzwZIkzzGlA(SeutI)a9awJsYhNL4J1ZKLo9ws8IJpolXhRVc1sp8boXMO(7lOAeI8KLbUiQoW8aeyGCvOzun8hBkbgHIk3yjOsM47nOPmbeuvW8aeOcVbVDktaXVK8U7HZX06g(4aP99MmWa6bUlf8A85Ttzci(LK3DpCoMw3WNI1CVRmldjXFGEaRrj5bjYu(a4YmzzGEjXlaxUYadSjirIpfRnDcL4CEJ3hsYtaGHK4fGlxtF6JkzHsgNGCvS1mRzrT0dFGtSjQ)(cQmAFuxue1K49dyC77PoxGkTwyUXsqTeq6TcZ1f9g0vlO3StzciyGC0aAgvd)XMsGrOOYnwcQKj(EJB7nOPmbeuvW8aeOsJWBWBNYeq8ljV7E4CmTUHpoqAFVjujluY4eKRITMznlQLE4dCInr93xqLr7J6IIOMeVFaJBFp15cuP1cZnwcQLasVvyUUO3GUAb92V9MDktabdmqfOfsdbvGqXara]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20171115.094708, [[dCJMeaGErG2Ki0UurBtLK2NkPMnf3wvANqSxPDt1(vP(jLO6Ve8BOgQiGbdIHtKdksDAfhJuDokrSqsyPQIftslx4XI6POwgO8CinrsKmvIYKjLPR0fvjomWLrUUQAJQKyRuIYMvHZtj9Dk1xjrmnkrAEGKgjiX3avJwenorqNuKSosK6AKOUhi1NjQEgLWWi0vVYkZsuEaMjbb7G9Iatz9YCogPTCzeWlvoLLDd5kbgDVHOaZk9ne1GaBYYpKHaOurGjQdxmHWSKtrrXecR8db0SkBEPYX3NSGe2MIZdGXGkSyblelNoVd2rRSIOxzLV4avdPvfL5CmsB5YpKHaOurGjQdxxSCkxBYGfhLDStLraVu5h6fhOKHqrVHOKXxkkNwDmZATCqV4aLmekQG94lfDlcSkR8fhOAiTQOmNJrAlx(HmeaLkcmrD46ILt5AtgS4OSJDQmc4LkNaJXaIBi4JBixjWOB50QJzwRLLgJbec4dHJaJUDlIfvw5loq1qAvrzeWlvwrqGn5ne8XneECTaihJck)qgcGsfbMOoCDXYPCTjdwCu2XovMZXiTLJVtxdTEIX3NSGe2MIZ8pcY3RHgUy3IyPvw5loq1qAvrzohJ0ww9FCCgZlD(Lsu9FCCM87YPyC5cX3jbBciH9tnSTNy89jliHTP4m)JG89AOTq5YpKHaOurGjQdxxSCkxBYGfhLDStLraVuzOGTnJl)gIcdaDlNwDmZATCsSTzC5cQga62TikxzLV4avdPvfL5CmsB547twqcBtXz(hb5luHgUYLFidbqPIatuhUUy5uU2Kblok7yNkJaEPYwUQzwkalvoT6yM1AzSQzwkal1TixTYkFXbQgsRkkZ5yK2YX3NSGe2MIZ8pcYxOcnCLtu9FCCM87YPyC5cX3jbBciH9tnSTx(HmeaLkcmrD46ILt5AtgS4OSJDQmc4LkdfC43qWh3quY4lfLtRoMzTwojoCb8HG94lfDlc8kR8fhOAiTQOmc4LkdLVlNIXLFd5570neLqajSxMZXiTLJVpzbjSnfN5FeKVqfAlel)qgcGsfbMOoCDXYPvhZSwlN87YPyC5cX3jbBciH9YpeqZQS5LkhFFYcsyBkopagdQWIfSqSCkxBYGfhLDStLTts(db0SwgnhJ02TBzLIoaFZwfDBb]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20171115.094708, [[dKZceaGErG2fkzBsv0(KQYSr16iPWTfvxtQQ2PkTxQDRy)sPrjc1WqYVbEmOoVO0GLIHdIdksoLiKJHuNJKQAHG0srrlgHLR0LjEk0YurpNutueWurPMmjMUWfffFdfEgjv66iQ2OkWwjPuBgr2ojv8zrQVkvHPrsv(ojzKsvACIGgTk0Hv1jfrhIKsoTK7Pc6VsLxJO8tskAtB2gVFUymPA32CWc0rBduaQgTndOTHyLpoAeHiW1ZRe8Jcm(E2pTrMcxET47jfndQeEQ(SOOOs4PreEliHrJPGJcmAZ2xAZ2yM5j4IIHAeH3csy0itHlVw89KIMbnLXKJsb)bynoGrmE)CXitjhSAHlADBtpQjK1ykIIxrwJRKdwTWfTUtvnHSo890SnMzEcUOyOgr4TGegvlfqWI0c0rhjrDKLvuWKvtAJmfU8AX3tkAg0ugtokf8hG14agX49ZfJ9cuXRjDBdu(RdJPikEfznEeOIxt6oc(Rdh(QUMTXmZtWffd1icVfKW4s(uWDqaQKLfm57kt03HmOmYu4YRfFpPOzqtzm5OuWFawJdyeJ3pxmEWc0rBdgBrMymfrXRiRrslqhD6ylYeh(QEMTXmZtWffd1icVfKWib5KiXARCHf5qmYu4YRfFpPOzqtzm5OuWFawJdyeJ3pxm2lqfVM0Tnq5VoABsmZkxsKXuefVISgpcuXRjDhb)1HdF73SnMzEcUOyOgr4TGegnYu4YRfFpPOzqtzm5OuWFawJdyeJ3pxmQMe8kK9dXykIIxrwJacEfY(H4W3EA2gZmpbxumuJi8wqcJWaaxbOAyrSYhh7aK601OSFAG(zTs(xJUVdP73itHlVw89KIMbnLXKJsb)bynoGrmE)CX4blqhTnySfzsBtIPtKXuefVISgjTaD0PJTitC4ldZ2yM5j4IIHAeH3csyega4kavdlIv(4yhGuNUgL9td0pRvY)A09DinLrMcxET47jfndAkJjhLc(dWACaJy8(5IXEb702ai120JAcznMIO4vK14rWoDasDQQjK1HdJjGq6jNhgQdBa]] )

    storeDefault( [[Wowhead Frost: default]], 'actionLists', 20171115.094708, [[dmeYjaqiHeTjLu9jQuIrPKYPeQSlLyyKQJrjldv5zOOyAuPkUgvQQTjKW3eIXjuQZjKK1jKQMhkkDpQuSpHQoOsLfsL8qQurtKkvYfvQAJOOAKcP0jrrwjvQuZKkv4MuPuTts6NcPYqPsvAPQQEkXurHRsLs6RcLSxP)skdwWHvzXOYJvLjJsxgzZuXNPugnLQtd1RfkmBkUTQYUb9BGHRuoUqkwUINdz6IUoj2Uqs9DuvNxjz9uPuMVqr7NQUwLrL9WJZqSLRI7ICoftwxvuVpQsSa8TthRpW8bGYO3hyjNtXKv(jdDiQQ80TIOhBEr1IUUES5vrEdElRuz3lXaiQmQQvzuzp84meBDvr9(OkUZZy8HDVedG(G7aJsFynxdDP94QiVbVLv4uCCw4g6s7AahnegYoNna6wu2QSJdBW5QkVZy0UxIbqndgLv(jdDiQQ80TIyPxHjil(DjyQabqQYpHakZJqLrZkUDaR69rvIfGVD6y9bMpaug9(a3qxAVzv5vgv2dpodXwxvK3G3YkvuVpQIBfr(atj9HQSJdBW5QkkisdN0hQctqw87sWubcGuLFYqhIQkpDRiw6v(jeqzEeQmA2SQmtzuzp84meBDvrEdElReL(aNIJZYg2yUrd4O5mauUOS5dR7dR5dR5du0OG32i2Lhag10yJGpsd4O5CjH8H19bkAuWBBe7cIoJgWrdsVb4CW8q4ZhIZhIzm9Hhayyb8HlCdDPDnGJgcdzNZgaDld9DyiYhI3hIcDFiUkQ3hvX9InMB8bGJpW8bGYk74WgCUQYg2yUrd4O5mauwHjil(DjyQabqQYpzOdrvLNUvel9k)ecOmpcvgnBwv3tzuzp84meBDvrEdElRmkq8tBdWNMLNYmem9H49Hi6(W6(WOajFiE34d88H19H18HO0hYZqWCXUc0gnyOnTrbsA8PBdaxi4XziwFiMX0hEaGHfWhUyxbAJgm0M2Oajn(0TbGld9DyiYhywFWs3hIRI69rvCn0L29bGJpiyi7C2aORYooSbNRQWn0L21aoAimKDoBa0vHjil(DjyQabqQYpzOdrvLNUvel9k)ecOmpcvgnBwv3VmQShECgITUQiVbVLv4uCCwuG2bMvAOCiOT0(IYwf17JQiyi7C2aOZTG8bMRmRQSJdBW5QkimKDoBa0H0CuMvvycYIFxcMkqaKQ8tg6quv5PBfXsVYpHakZJqLrZMvnkkJk7HhNHyRRkYBWBzfwItXXzXzaOuZHIAAwgYziK9JZqE3Df17JQeTa(gm0Mp4YCOSYooSbNRQyhW3GH204mhkRWeKf)UemvGaiv5Nm0HOQYt3kILELFcbuMhHkJMnRAKYOYE4Xzi26QI8g8ww5bagwaF4c3qxAxd4OHWq25Sbq3YqFhgI8H49bE6(W6(WOajFiE34dmtf17JQ8tFGbrgcH8HyHHjnv2XHn4CvLH(adImecPXhdtAQWeKf)UemvGaiv5Nm0HOQYt3kILELFcbuMhHkJMnRASlJk7HhNHyRRkYBWBzfofhNLb)rlkBvuVpQs0c4BWqB(GlZHsFynR4QSJdBW5Qk2b8nyOnnoZHYkmbzXVlbtfiasv(jdDiQQ80TIyPx5NqaL5rOYOzZQgvLrL9WJZqS1vf5n4TScNIJZYqFGbrgcH04JHjnlkBvuVpQs0XzWjnxsv2XHn4CvfaNbN0CjvHjil(DjyQabqQYpzOdrvLNUvel9k)ecOmpcvgnBwvl9YOYE4Xzi26QI8g8wwzuG4N2gGpnlpLziy6dX7dr09H19Hhayyb8HlCdDPDnGJgcdzNZgaDld9DyiYhI3h4Pxr9(OkmFaO0hKCWXGQSJdBW5QkodaLAOCWXGQWeKf)UemvGaiv5Nm0HOQYt3kILELFcbuMhHkJMnRQLvzuzp84meBDvrEdElRur9(OkrhNbN0Cj5dRzfxLDCydoxvbWzWjnxsvycYIFxcMkqaKQ8tg6quv5PBfXsVYpHakZJqLrZMv1Ixzuzp84meBDvrEdElRmkq8tBdWNMLNYmem9H4DJpeBDFyDF4bagwaF4c3qxAxd4OHWq25Sbq3YqFhgI8bM1n(ap9kQ3hvH5daL(GKdogKpSMvCv2XHn4CvfNbGsnuo4yqvycYIFxcMkqaKQ8tg6quv5PBfXsVYpHakZJqLrZMv1IzkJk7HhNHyRRkYBWBzLhayyb8HlCdDPDnGJgcdzNZgaDld9DyiYhyw34d80ROEFuLF6dmiYqiKpelmmPXhwZkUk74WgCUQYqFGbrgcH04JHjnvycYIFxcMkqaKQ8tg6quv5PBfXsVYpHakZJqLrZMnRiB0dFgSB7smawvEUVvZwa]] )

    storeDefault( [[Wowhead Frost: breath]], 'actionLists', 20171115.094708, [[dWZAfaGELsPnbiTlr12ukj7dGmBQA(aIpjsvwNiv62a1HrzNKyVs7wL9tPFQusnmu1Vr6BkfdvPumykgocheqDkaKJPGZPuIwOs0svslgvwUW5fjpLyzKKNtQjksvnvGmzrz6Q6IkHtd6YqxNkBerXJv0MvOPjs5VI4RauFMKAEiQmsLs14quA0iIVRuDsePNHOQRbG6EaGdPucJca61IuXDOGQS4yCEmRCvsFCK58FxwrHbgRay6ojilZAitq1F6AnCbYEsQSIEKPXQOIFydpzvTL5888KvvfzgqIVsfGNpKE6cQkdfuLfhJZJzDzfzgqIVYwynCUXXCcO3ZIe6yYyq1FUJOIcdmwzBGEplSg6O1qMGQ)kaZb9WpvfcO3ZIe6yYyq1FfsVm4K90OYrpSYk6rMgRIk(Hnd8vwrn1ftuxq97xfvfuLfhJZJzDzfzgqIVs4o4mHGUJr(0fbEV1aiRjnERbOwdNBCm3DKq9Ps0FGN6NKChrffgySIaVSGPMQzPN2AiJlsvbyoOh(PQOHxwWut1mDYOlsvH0ldozpnQC0dRSIEKPXQOIFyZaFLvutDXe1fu)(vH8fuLfhJZJzDzfzgqIVcaAnH7GZec6og5txe49wdGSM04TgGAnH7qRbqaG1qERbGSgGaeRHZnoMhiyAOrpQ1j7W7Xix)Sz6ynaG1mWxrHbgRSIGPHg9OwBnagEpgvaMd6HFQkbcMgA0JADYo8EmQq6LbNSNgvo6HvwrpY0yvuXpSzGVYkQPUyI6cQF)QKwbvzXX48ywxwrMbK4RW5ghZdiym3ryna1Ac3bNje0DmYNUiW7TgaznPXxrHbgRSD6UhEQTMLEM(Ramh0d)uviHU7HN6eopt)vi9YGt2tJkh9WkROhzASkQ4h2mWxzf1uxmrDb1VFva4cQYIJX5XSUSImdiXxbaTMWDWzcbDhJ8Plc8ERHCwdz5TgGaeRHZnoMtI7uJb8uNeUdt2rgb9YDewdazna1A4CJJ5bemMNr3VkkmWyLTMZdFmypwbyoOh(PQq58Whd2Jvi9YGt2tJkh9WkROhzASkQ4h2mWxzf1uxmrDb1VFv2QcQYIJX5XSUSImdiXxjChCMqq3XiF6IaV3AiN1KgFffgySY2DNAmGNARz1DO1ayKrqVkaZb9WpvfsCNAmGN6KWDyYoYiOxfsVm4K90OYrpSYk6rMgRIk(Hnd8vwrn1ftuxq97xLnfuLfhJZJzDzfzgqIVs4o4mHGUJr(0fbEV1qoRH88vuyGXklatq3XWAwDhAnagze0RcWCqp8tvbbtq3XijChMSJmc6vH0ldozpnQC0dRSIEKPXQOIFyZaFLvutDXe1fu)(9Rie4eY8WTL9q6vfva8q)wa]] )


    storeDefault( [[Frost Primary]], 'displays', 20171115.094708, [[d0d4gaGEfYlHQQDPqL2McvzMsv1JrXSv0XrfDtubttHYTvsFtkf7Kk7vSBI2pQ0pvIHPughuvCAsnuKAWKOHJWbLkpNWXKIZjLklKQSukLwmLSCkEOuYtblJs16GQstKsrtfktMeMUkxubxLsHld56izJkvBvHQAZOQTJO(OuvEMuQ6ZqLVtvnsuHoSKrJsJhQYjrKBjLsxtQsNNK(TQwRcv8APkonblatrC6xU)Ydo1jkWInW6NKBiatrC6xU)Yd0JqX1ypGPK4qTyrm9eVawt9Or9nF)4fqDHNxGUwfXPFPiUTa4TWZlqxRI40Vue3waoPquifKyEjOhHIBSTaRAz3qCTpaNuikKIwfXPFPiEbux45fOdRm4qNiUTac23h81hdB3q8ciyF)oQ7JxanZlbIIrlXfxVbUYGdDDsg23eWBbdBHd2sQpoIfqn7TfFAxBSV107ynTRx7TFRnBHVTJ1Ba1fEEb6WVNiU22eqW((yLbh6eXlqpwDsg23eaBH2ws9XrSaAPcntDVPtYW(Ma2sQpoIfGPio9l7KmSVjG3cg2chcaeigDn1JQt)Y4S3Btab77dyXlaNuikKn1geZPFzaBj1hhXciPwjX8srCJfqqGMZ9zjyB9Z3eSavCnbSIRjaU4AcyIRjxab773Qio9lfXkaEl88c01rzQ42cuuMctLafWIINpWAHxh19XTfWAQhnQV573nNXkqnjylG99PjpextGAsWwT(vR6OjpextaBI4lQ5fVa10Vuf0KPJxaYAH2sp1NkMkbkGvaMI40VSBQXjd0AWHnyBafAbXSuXujqbQaMsIdHPsGcuw6P(uduuMIdAjkEb6XA)LhOhHIRXEGAsWwyLbh6OjthxtadAgO1GdBW2acc0CUplbBScutc2cRm4qhn5H4AcWjfIcPGKuHMPU3iIxGwpHkxLyFGDZloUk7wgc4QvuGDZloUkPn61YOg4kdo0T)Ydo1jkWInW6NKBiGceFrnVo6(da61wCvUBEXHVCvQaXxuZlqpw7V8GtDIcSydS(j5gciyFFWxFmSDu3hVa1KGT6M(LQGMmDCnbQjbBbSVpnz64Acqy0RLrD)LhOhHIRXEacdI5xTQRJU)aGETfxL7MxC4lxLegeZVAvxa8w45fOd)EI4AcSw41ne3wG1cpalUMaxzWHoAYdXkGG99PjthVa2IMOsGIZ(wtB2gp7JnU2BV92THpbeSVp(rQwAPcTeNiEbUYGdD0KPJvaMF1QoAYdXkqnjyRUPFPkOjpextGES2F5fGgJRsOKcUkDLX8(beSVpjPcntDVreVaQl88c01rzQ42cut)svqtEiEbeSVF3q8ciyFFAYdXlaZVAvhnz6yfOMeSvRF1QoAY0X1eOOmvNKH9nb8wWWw4q)d7yb4KsZ0Z4RfWPorbQaRAjGf3wGRm4q3(lpqpcfxJ9afLPij5FmvcualkE(amfXPF5(lVa0yCvcLuWvPRmM3pqrzkGanNKSzCBbgKL1ePiEbe6vIjQBzio7beSVFhLPij5)yfaVfEEb6Wkdo0jIBlWvgCOB)LxaAmUkHsk4Q0vgZ7hqDHNxGossfAM6EJiUTa4TWZlqhjPcntDVre3waoPquOUPgNCfjVambim61YOsI5LGEekUX2cW)YlangxLqjfCv6kJ59dOzE548)ACn9gGtkefsX(lpqpcfxJ9a4f3waoPquif43teVaRAzh19XTfOOmLnK6laXSurMCja]] )

    storeDefault( [[Frost AOE]], 'displays', 20171115.094708, [[d0JYgaGEPuVejv7srLSnfvQzsvvpgPMTchhvXnrqnnKeFtrv1Tvf7Ks7vSBI2pb9tPQHPknofvLttQHIkdgv1WHQdsLEojhtkoNIQyHkYsrvAXO0YP4HuvEkyzkkRJQkmrQQ0uvvtMatxPlkvUkssxgY1r0gHITQOkTzcTDK4JsjoSKpdL(ovzKiP8meeJgfJhbojcDleKUMIkopv8Bvwlvv0RLs60KFa6cF1NeZjxyDgOa9u97prBxa6cF1NeZjxq3gfBZSaMsIf5Jbr3AMcWdjIe5o0yLpi5gGoGtVOOcT(k8vFsvSVbiOxuuHwFf(QpPk23a4g9tzCisFsq3gflvEd8OLUDXsib4HerIe4RWx9jvzkGtVOOcT)YGfTQyFdOyopWtV0mUDHnGI58Cj3lSbumNh4PxAgxY9YuGTmyrRRKM5mbM6))EcZlXwO2pGtSe6SM3aee7BafZ59ldw0QYuGwzDL0mNjWVNJxITqTFaTuGMU2Z4kPzotaEj2c1(bOl8vFsxjnZzcm1))9eoaGJO11q3Uw9jJD2CAcOyop4NPa8qIir(vBq0R(Kb4Lylu7hqs(qK(KQyPsafoAmWmkfJVBCM8duX2eWeBtaSX2eGn2MSbumNNVcF1Nuf2ae0lkQqRlPPI9nqrAQVdokalPOyGNIaxY9I9na7q3UDlJZZDmcBGAGZuaZ5XrPl2Ma1aNP8DpS1YrPl2Ma(fjwKJntbQHx5O4OWLPau0knREOxNVdokaBa6cF1N0DOXkd4RZ(74nGaTcFuoFhCua6aMsIf9DWrbkw9qVobkstryTeLPaTYI5KlOBJITzwGAGZu)YGfTCu4ITjGbnc4RZ(74nGchngygLIjSbQbot9ldw0YrPl2Ma8qIircikfOPR9mQmfW3H7iK))cGXCQviF3(UapAPl5EX(gyldw0I5KlSoduGEQ(9NOTlGaKyrowxo)da6hFc5JXCQ1peYxasSihBaNErrfAP(KkwcTjGM(KaErRLyJDobQbot5o8khfhfUyBcOPpPFE3tSnZjaUr)ughmNCbDBuSnZcGBq03dBTUC(ha0p(eYhJ5uRFiKpUbrFpS1gq8KBaUVq(qjvc5BlJ58c8ue42f7BaEirKibePpjOBJILkVb2YGfTCu6cBa2HUD7wgNxMcOyopokCzkab9IIk0sukqtx7zuX(gWPxuuHwIsbA6ApJk23aBzWIwmNCdW9fYhkPsiFBzmNxac6ffvO9xgSOvf7BafZ55sAkIsXlSbumNhrPanDTNrLPao9IIk06sAQyFdudVYrXrPltbumNhhLUmfqXCEUDHna99WwlhfUWgOinfGJgdI(n23afPPCL0mNjWu))3ty)7W8duKMIOu8(o4OaSKIIbE0s4h7BGTmyrlMtUGUnk2Mzb4Hut368QvW6mqbydqx4R(Kyo5gG7lKpusLq(2YyoVa1aNP8DpS1YrHl2MaDYIDGeKPak9d(a523f7SaTYI5KBaUVq(qjvc5BlJ58cudCMYD4vokokDX2eG(EyRLJsxydSLblA5OWf2akMZJ6ihwTuGwIvLPa8IgOsHID2BZ8)o3ZOYCnJqMnpVZxGNIa4hBtac6ffvOL6tQyBcudCMcyopokCX2eGhsejsaMtUGUnk2MzbALfZjxyDgOa9u97prBxaEirKibuFsLPa26bfaJ5uRq(U9DbkstrvPEdGpkhKjBca]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )


end

