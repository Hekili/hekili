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
        addAura( "killing_machine", 51128, "duration", 10 )
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
        addAura( "rime", 59057 )
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


    storeDefault( [[Usable Items]], 'actionLists', 20171010.212625, [[de0ahaqirv2KuYNquLrjQQtjQyxIYWuOJrqltv4ziQ00quIRraSnef13iqJdrjnpPG7jv2NOshKqAHQIEibKjsa1fLcTrrszKik4KIeRuk1lrur3erH2PQ0sfPEQstLqDvcqBfrf(kIs1Er9xfmyjhgyXsvpgHjlIldTzcXNjYOfj50KwnIQ61ikYSv0TbTBv(nsgoI0YrQNlmDQUUQA7eLVJOugpr15reRxKunFPO9tzwilMxbgfb8No)K3xae5vadq)eTkfhHbVIs4k1fSy(vilM3gpq)et4N8Ue0kPoV5zvGURNuKLObOFIjw1YkRnGWvz4aEiuXWQC7Skq31tkYG6PWp0QwwzTZ3QaDxpPidcKRWp0QUoRgTQztRaeUkdhWdHkgw1qNvb6UEsrgeixHFOv5WBkxIsaCkAEpQd5v0EDQoj8kc4pDsgiO(NJ0qeeFAK30yq9PjWGfZoVPXjccKFFmkuqHJ8(cGiVPg4pDsSsGO(NJ0qeeFAKD(9blM3gpq)et4N8Ue0kPoV5zvGURNuKLObOFIjw1YkRnGWvz4aEiuXWQC7Skq31tkYG6PWp0QwwzTZ3QaDxpPidcKRWp0QUoRgTQztRaeUkdhWdHkgw1qNvb6UEsrgeixHFOv5WBkxIsaCkAEpQd5v0EDQoj8(H90G5aKI6KMavgg8MgdQpnbgSy25nnorqG87JrHckCK3xae5vaH90GPvKrkQtAcuzyWo)sUSyEB8a9tmHFY7laI8kW0GVuQCROeXQL6pdEtJb1NMadwm78MgNiiq(9XOqbfoYBkxIsaCkAEpQd5v0EDQoj8Mqd(sPYhOeziO(ZG3LGwj15npRc0D9KISena9tmXQwwzTbeUkdhWdHkgwLBNvb6UEsrgupf(Hw1YkRD(wfO76jfzqGCf(Hw11z1OvnBAfGWvz4aEiuXWQg6Skq31tkYGa5k8dTkh25xYclM3gpq)et4N8Ue0kPoV5zvGURNuKLObOFIjw1YkRnGWvz4aEiuXWQC7Skq31tkYG6PWp0QwwzTZ3QaDxpPidcKRWp0QUoRgTQztRaeUkdhWdHkgw1qNvb6UEsrgeixHFOv5WBkxIsaCkAEpQd5v0EDQoj8sM0j5dWe8IH(p9PN0aztJuXBAmO(0eyWIzN304ebbYVpgfkOWrEFbqKxYPojpYhGj4rEHvp)0NEswr21ivSZVcalM3gpq)et4N8Ue0kPoV5zvGURNuKLObOFIjw1YkRnGWvz4aEiuXWQC7Skq31tkYG6PWp0QwwzTZ3QaDxpPidcKRWp0QUoRgTQztRaeUkdhWdHkgw1qNvb6UEsrgeixHFOv5WBkxIsaCkAEpQd5v0EDQoj8ktbZbkrgiqqGtmIbNsUEbVPXG6ttGblMDEtJteei)(yuOGch59farEjhkyAfLiwjqiiWjgHvIPKRxWo)sMzX824b6Nyc)K3LGwj15npRc0D9KISena9tmXQwwzTbeUkdhWdHkgwLBNvb6UEsrgupf(Hw1YkRD(wfO76jfzqGCf(Hw11z1OvnBAfGWvz4aEiuXWQg6Skq31tkYGa5k8dTkhEt5sucGtrZ7rDiVI2Rt1jH3GuKWr6bkrg6rNgqcyYBAmO(0eyWIzN304ebbYVpgfkOWrEFbqK3LuKWrAROeXQNOtdibmzNDEtJteei)(yuOGJc(ymtiz9b5kap4DjOvsDE5LmOjj4Xp5DjfjuWutDGRuh)oYoZ]] )

    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20171010.212625, [[deKdBaqibWIiuH2KKYOiv6uKQSlszyeYXevltGEMkrtJqLUMOqBtsOVPsACcq15Ke06eGY8iu19ujSprrhKqzHKkEOK0effCrsvTrbi(iHkQtsvQzsOcCtvQDIu)KqfzPufpLYuPQCvbiTvb0Ev(RkmyuoSulgHhlYKPYLbBwqFMQQrJOonjVgrMTe3MGDd1VHmCv0XLey5e9CHMUQUos2ovjFxu68sQwpHkO5ljA)O6LpFZSKuD(ZMLbiSPk)0zMhOaDegDqr5xZfjQIA5vmJxgmGpZoHKQlkXH9Rq4rhmJbNjw6viCC(gD(8ntFCtua30zMLKQZF2J87VaAjeQ4qzXroRgNPlNfaodQak15j40YV8QORzKZQXzskSkDCIYcsnheQsQNZepNDPiotVzIrOkQV(mxljD0sc1dYzEJDQu)i5mmcdZUrUaBjDlaZMr3cWSm0ssCMysc1dYzEGc0ry0bfLFnx0mpqerjtqC(2pRkzir6g5fia4FeZUro6waMTF0bNVz6JBIc4MoZSKuD(ZGkGsDEcoT8lVk6Ag5SACMdiOcd1cH4dsf2)rwef2Pf)orIZY8coRICwno77cGFnxljD0sc1dsna3efWntmcvr91N1NOuxQFgHzEJDQu)i5mmcdZUrUaBjDlaZMr3cWmXorPUu)mcZ8afOJWOdkk)AUOzEGiIsMG48TFwvYqI0nYlqaW)iMDJC0TamB)OVC(MPpUjkGB6mZss15p7r(9xaTecvCOS4iNvJZ0LZGkGsDEcoT8lVk6Ag5SACMKcRshNOSGuZbHQK65mXZzxkIZQXzjeQ4qzXAUws64LnogIKc9Rqynji0kCKZepNfKZ0BMyeQI6RpZ1sshTKq9GCM3yNk1psodJWWSBKlWws3cWSz0TamldTKeNjMKq9GKZ0nxVzEGc0ry0bfLFnx0mpqerjtqC(2pRkzir6g5fia4FeZUro6waMTF0I78ntFCtua30zMLKQZF2J87VaAjeQ4qzXroRgNPlNjPWaNj(l4Sl5m9MjgHQO(6ZIucci8H)w6hvVaZ8g7uP(rYzyegMDJCb2s6waMnJUfGzgLGacZzIZT0pQEbM5bkqhHrhuu(1CrZ8areLmbX5B)SQKHePBKxGaG)rm7g5OBby2(rNX5BM(4MOaUPZmljvN)mcQWqnkmzuP(r8La2)twJ6KZQXzeuHHAjuXDqgA5Rf)orIZYKZYRWzIrOkQV(Se5wHJhOWdvcM5n2Ps9JKZWimm7g5cSL0TamBgDlaZQsUv4iNHc5mVtWmpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p6koFZ0h3efWnDMzjP68N9i)(lGwcHkouwCKZQXz6YzqfqPopbNw(LxfDnJCwnolHqfhklwZ1sshVSXXqKuOFfcRjbHwHJCM45SCrCwnotsHbot8xWzxYz6ntmcvr91NfPeeq4d)T0pQEbM5n2Ps9JKZWimm7g5cSL0TamBgDlaZmkbbeMZeNBPFu9cWz6MR3mpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p6RZ3m9XnrbCtNzwsQo)zoGGkmuleIpivy)hzruyNw87ejolZl4SkYz14SecvCOSyT(eL6s9ZiOjbHwHJCM45mXDMyeQI6RplIOkhsOpb5mVXovQFKCggHHz3ixGTKUfGzZOBbyMHOkCMhOpb5mpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p6a(8ntFCtua30zMLKQZFMdiOcd1cH4dsf2)rwef2Pf)orIZY8coRIZeJqvuF9z9jk1L6NryM3yNk1psodJWWSBKlWws3cWSz0TamtStuQl1pJaNPBUEZ8afOJWOdkk)AUOzEGiIsMG48TFwvYqI0nYlqaW)iMDJC0TamB)ORW5BM(4MOaUPZmljvN)mjfwLoorzbPMdcvj1ZzINZYfntmcvr91N5G(jFKqQYmVXovQFKCggHHz3ixGTKUfGzZOBbywgG(jZzvrQYmpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p6CrZ3m9XnrbCtNzwsQo)zbGZ(Ua4xZ1sshTKq9GudWnrbCCwnoJGkmuls5Ca(WHqcAuNCwnolaCgbvyOggssuuf1Oo5SACMKcdCM4VGZUCMyeQI6RpZb9t(iHuLzEJDQu)i5mmcdZUrUaBjDlaZMr3cWSma9tMZQIufot3C9M5bkqhHrhuu(1CrZ8areLmbX5B)SQKHePBKxGaG)rm7g5OBby2(rNNpFZ0h3efWnDMzjP68N9DbWVMRLKoAjH6bPgGBIc44SACgbvyOwKY5a8HdHe0Oo5SACwcHkouwSMRLKoAjH6bPMeeAfoYzzYzzKZQXzskmWzI)co7YzIrOkQV(mh0p5JesvM5n2Ps9JKZWimm7g5cSL0TamBgDlaZYa0pzoRksv4mDdQ3mpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p68GZ3m9XnrbCtNzwsQo)zoGGkmuleIpivy)hzruyNw87ejot8Cwf5SACwcHkouwSwFIsDP(ze0KGqRWrot8xWzvCMyeQI6RpleIpivy)hXxQibZ8g7uP(rYzyegMDJCb2s6waMnJUfGzbei(GuH9Zz2lvKGzEGc0ry0bfLFnx0mpqerjtqC(2pRkzir6g5fia4FeZUro6waMTF05xoFZ0h3efWnDMzjP68N5acQWqTqi(GuH9FKfrHDAXVtK4SmVGZUCMyeQI6RplIOkhsOpb5mVXovQFKCggHHz3ixGTKUfGzZOBbyMHOkCMhOpbjNPBUEZ8afOJWOdkk)AUOzEGiIsMG48TFwvYqI0nYlqaW)iMDJC0TamB)OZf35BM(4MOaUPZmljvN)mhqqfgQfruLdj0NGuJ6KZQXzbGZCabvyOwieFqQW(pYIOWonQZzIrOkQV(Sqi(GuH9FeFPIemZBStL6hjNHryy2nYfylPBby2m6waMfqG4dsf2pNzVurc4mDZ1BMhOaDegDqr5xZfnZderuYeeNV9ZQsgsKUrEbca(hXSBKJUfGz7hDEgNVz6JBIc4MoZSKuD(ZCabvyOwervoKqFcsnQtoRgN5acQWqTqi(GuH9FKfrHDAXVtK4SmVGZYNjgHQO(6ZIjeL0pCeFPIemZBStL6hjNHryy2nYfylPBby2m6waMzjeL0pWz2lvKGzEGc0ry0bfLFnx0mpqerjtqC(2pRkzir6g5fia4FeZUro6waMTF05vC(MPpUjkGB6mZss15pZbeuHHArev5qc9ji1Oo5SACMdiOcd1cH4dsf2)rwef2Pf)orIZY8colFMyeQI6Rplv6SkS)Ji52HYgN5n2Ps9JKZWimm7g5cSL0TamBgDlaZQw6SkSFoZi3ou24mpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p68RZ3m9XnrbCtNzIrOkQV(mheQkWmVXovQFKCggHHz3ixGTKUfGzZOBbywgGqvbM5bkqhHrhuu(1CrZ8areLmbX5B)SQKHePBKxGaG)rm7g5OBby2(rNhWNVz6JBIc4MoZSKuD(Z60R8coamiOGiNL5fCwWzIrOkQV(SuxkhD6vi8rrf)zvjdjs3iVaba)JyM9sv6RsgsKMoZUrUaBjDlaZM5bIikzcIZ3(z0TamRAxkCMyPxHWCM4av8NjM0FCgUfGlehnLqvolGIjJk1dyCMyIt6looZduGocJoOO8R5IMzKrzVrovOcKXPZmVXovQFKCggHHz3ihDlaZmLqvolGIjJk1dyCMyIt6VF05v48ntFCtua30zMLKQZFMdiOcd1cH4dsf2)rwef2Pf)orIZe)fCwqoRgNPlN5acQWqTqi(GuH9FKfrHDAXVtK4mXFbNjUCwLvYz6YzeuHHAefLFYp4oKuy4il0NiSg1jNvzLC23fa)APo(k)9JKAaUjkGJZ0JZ0JZQXzskSkDCIYcsnheQsQNZYKZYiNvJZ0LZKuyv64eLfKAoiuLupNLjNf8soRYk5SaWzFxa8RL64R83psQb4MOaootVzIrOkQV(Sqi(GuH9FeFPIemZBStL6hjNHryy2nYfylPBby2m6waMfqG4dsf2pNzVurc4mDdQ3mpqb6im6GIYVMlAMhiIOKjioF7NvLmKiDJ8cea8pIz3ihDlaZ2p6GIMVz6JBIc4MoZSKuD(ZcaNrqfgQHHKefvrnQtoRgN9DbWVggssuuf1aCtuahNvJZKuyiQ9kb44rhIlNLjN5p5MjgHQO(6ZCq)KpsivzM3yNk1psodJWWSBKlWws3cWSz0Tamldq)K5SQivHZ09s9M5bkqhHrhuu(1CrZ8areLmbX5B)SQKHePBKxGaG)rm7g5OBby2(rhmF(MPpUjkGB6mZss15ptxoJGkmuddjjkQIAuNCwLvYzeuHHAuyYOs9J4lbS)NSg1jNvzLCMKcdCwMxWzb5m94SACMdiOcd1cH4dsf2)rwef2Pf)orIZY8colNZQXz6YzoGGkmuleIpivy)hzruyNw87ejolZl4Sl5SkRKZcaNPlN9DbWVwQJVYF)iPgGBIc44SkRKZGkGsDEcoTNmCOWXxsLEKmEeIOKp5JceJimNPhNPhNvJZKuyv64eLfKAoiuLupNLjNvHCwnotxotsHvPJtuwqQ5Gqvs9CwMCwWl5SkRKZcaN9DbWVwQJVYF)iPgGBIc44m9MjgHQO(6ZIjeL0pCeFPIemZBStL6hjNHryy2nYfylPBby2m6waMzjeL0pWz2lvKaot3C9M5bkqhHrhuu(1CrZ8areLmbX5B)SQKHePBKxGaG)rm7g5OBby2(rhm48ntFCtua30zMLKQZFMUCgbvyOggssuuf1Oo5SkRKZiOcd1OWKrL6hXxcy)pznQtoRYk5mjfg4SmVGZcYz6Xz14mhqqfgQfcXhKkS)JSikStl(DIeNL5fCwoNvJZ0LZCabvyOwieFqQW(pYIOWoT43jsCwMxWzxYzvwjNfaodQak15j40EYWHchFjv6rY4riIs(KpkqmIWCMECwnotsHvPJtuwqQ5Gqvs9CwMCwfotmcvr91NLkDwf2)rKC7qzJZ8g7uP(rYzyegMDJCb2s6waMnJUfGzvlDwf2pNzKBhkBKZ0nxVzEGc0ry0bfLFnx0mpqerjtqC(2pRkzir6g5fia4FeZUro6waMTF0bVC(MPpUjkGB6mZss15p77cGFTi52HYEOWHurfcRb4MOaooRgN9DbWVMRLKoAjH6bPgGBIc44SACwa4mcQWqnxljD8YghdrsH(viSg1jNvJZsiuXHYI1CTK0rljupi1KGqRWroltolx0mXiuf1xFMd6N8rcPkZ8g7uP(rYzyegMDJCb2s6waMnJUfGzza6NmNvfPkCMUIREZ8afOJWOdkk)AUOzEGiIsMG48TFwvYqI0nYlqaW)iMDJC0TamB)OdkUZ3m9XnrbCtNzwsQo)zFxa8Rfj3ou2dfoKkQqyna3efWXz14SaWzFxa8R5AjPJwsOEqQb4MOaooRgNfaoJGkmuZ1sshVSXXqKuOFfcRrDotmcvr91N5G(jFKqQYmVXovQFKCggHHz3ixGTKUfGzZOBbywgG(jZzvrQcNPBg1BMhOaDegDqr5xZfnZderuYeeNV9ZQsgsKUrEbca(hXSBKJUfGz7hDWmoFZ0h3efWnDMzjP68N9DbWVMRLKoAjH6bPgGBIc44SACwcHkouwSMRLKoAjH6bPMeeAfoYzzYz5IMjgHQO(6ZCq)KpsivzM3yNk1psodJWWSBKlWws3cWSz0Tamldq)K5SQivHZ0TI6nZduGocJoOO8R5IM5bIikzcIZ3(zvjdjs3iVaba)Jy2nYr3cWS9JoyfNVz6JBIc4MoZSKuD(ZcaN9DbWVwKC7qzpu4qQOcH1aCtuahNvJZcaN9DbWVMRLKoAjH6bPgGBIc4MjgHQO(6ZCq)KpsivzM3yNk1psodJWWSBKlWws3cWSz0Tamldq)K5SQivHZ09QEZ8afOJWOdkk)AUOzEGiIsMG48TFwvYqI0nYlqaW)iMDJC0TamB)(z0TamZucv5SakMmQupGXz(bmivP9B]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20171010.212625, [[dmKktaqiOuQfjuQ2KqXOqv4uOk5vcLu3ckLyxkPHbuhtiltP0ZeQmnHs5AKGTjuvFJenoOu5CcLO1HQunpHQCpsv1(GsXbHswiq8qG0erv0fjjTrHs4KKqZuOKCtLyNOYpHsjnuuLsTuuvpLyQqLRcLQ2kPkFfvPK9k9xOyWGCyQwmP8yatMIlJSzkXNjPgnPYPr51kvZwu3wWUv1VvmCOQJtQklhYZfz6QCDk12vk(ojX5PKwpQsX(b1nQ4Qiaig(RsfEswC78vqQWNYKNOYTfCKYiWGJ)Au8viUTyxfbpbW8mJ34hB(YTvHTvWc4yZNkUYfvCvu9DTmzkiveaed)v5g1QZ0k7pcHSXFPkyPXYSZALa7nySGiI3qvu8nma)guLFEQYYy0ZrCEGQuHZduLf2BGHIfiI4nuf(uM8evUTGJugbUcFkn2iakvC9QaQocyFz2qb6VQvzzmCEGQ0RCBlUkQ(UwMmfKkcaIH)QGSFgag8JkeA1qwyaSdgcBGH2cUcwASm7SwXra(tyUbHO)QO4Bya(nOk)8uLLXONJ48avPcNhOkyHa8NGHWnie9xf(uM8evUTGJugbUcFkn2iakvC9QaQocyFz2qb6VQvzzmCEGQ0RCXvCvu9DTmzkiveaed)v5g1QZ0kWmzZOYNQGLglZoRv0YZyWyXgzTIIVHb43GQ8ZtvwgJEoIZduLkCEGQasEgdmuSWgzTcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6vUyR4QO67AzYuqQiaig(RYnQvNPvGzYMrLpvblnwMDwROrOeH2zV6kk(ggGFdQYppvzzm65iopqvQW5bQciekrOD2RUcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6vofkUkQ(UwMmfKkyPXYSZAf7eHHDuivrX3Wa8Bqv(5PklJrphX5bQsfopqvW(ebdP4rHuf(uM8evUTGJugbUcFkn2iakvC9QaQocyFz2qb6VQvzzmCEGQ0RCXV4QO67AzYuqQiaig(RYnQvNPv8ZXMpbdfdmepGH0STyz1(1nzRyshIE1NUvB8Wq8QcwASm7Swb)CS5RO4Bya(nOk)8uLLXONJ48avPcNhOk82ZXMVcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6voLfxfvFxltMcsfbaXWFv4bmKzU1nmKDM(dd(SR2MwpgWoMJfimik4SpbdfRHHogWoMJfiyO4PFyiZCRByi7m9hg8zxTnTIOGZ(emeVGHIbgYm36ggYot)HbF2vBtRik4Spbdfp9ddPgWublnwMDwRm2NgI89kGQJa2xMnuG(RAvwgJEoIZduLkCEGQGTAFAiY3RGfsDQY5i10HHzr)8Wm36ggYot)HbF2vBtRhdyhZXcegefC2NI1hdyhZXcu80VzU1nmKDM(dd(SR2MwruWzFIxXyMBDddzNP)WGp7QTPvefC2NIN(vdyQWNYKNOYTfCKYiWv4tPXgbqPIRxffFddWVbv5NNQSmgopqv6voSR4QO67AzYuqQiaig(RYnQvNPvGzYMrLpvblnwMDwR4OGvmJfmNocJHCtffFddWVbv5NNQSmg9CeNhOkv48avbluWkm0ybg60rWq8KCtf(uM8evUTGJugbUcFkn2iakvC9QaQocyFz2qb6VQvzzmCEGQ0RCXYIRIQVRLjtbPIaGy4VkK(Sz4XtM1O4ucwPcWqXadbmt2mQ8RghTJXrASJqRik4SpbdHnWqrXxHkyPXYSZAfJJ2XCi)twguWp28vu8nma)guLFEQYYy0ZrCEGQuHZdufE6ODyiCi)twguWp28v4tzYtu52cosze4k8P0yJaOuX1RcO6iG9LzdfO)QwLLXW5bQsVYfbU4QO67AzYuqQiaig(RcPpBgE8KznkoLGvQamumWqyByOZZ0FRjDUzubd7TyNyZVsVRLjdmumWqaZKnJk)QXr7yCKg7i0kIco7tWqydmKckublnwMDwRyC0oMd5FYYGc(XMVIIVHb43GQ8ZtvwgJEoIZduLkCEGQWthTddHd5FYYGc(XMhgIhr8QcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6vUOOIRIQVRLjtbPIaGy4VkK(Sz4XtM1O4ucwPcWqXadDEM(BnPZnJkyyVf7eB(v6DTmzGHIbgcyMSzu5xnoAhJJ0yhHwruWzFcgcBGHItHkyPXYSZAfJJ2XCi)twguWp28vu8nma)guLFEQYYy0ZrCEGQuHZdufE6ODyiCi)twguWp28Wq8ylVQWNYKNOYTfCKYiWv4tPXgbqPIRxfq1ra7lZgkq)vTklJHZduLELlABXvr131YKPGuraqm8xfsF2m84jZAuCkbRubyOyGHohPMU1Jfim3GXWiyO4bdbmt2mQ8RghTJXrASJqRik4SpbdHTadHDvWsJLzN1kghTJ5q(NSmOGFS5RO4Bya(nOk)8uLLXONJ48avPcNhOk80r7Wq4q(NSmOGFS5HH4rC8QcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6vUO4kUkQ(UwMmfKkcaIH)Qq6ZMHhpzwJItjyLkadfdmeWmzZOYVMSdH5XO2rQhRzAfrbN9jyiSbgkk(GRGLglZoRvmoAhZH8pzzqb)yZxrX3Wa8Bqv(5PklJrphX5bQsfopqv4PJ2HHWH8pzzqb)yZddXJyJxv4tzYtu52cosze4k8P0yJaOuX1RcO6iG9LzdfO)QwLLXW5bQsVYffBfxfvFxltMcsfbaXWFvi9zZWJNmRrXPeSsfGHIbgcBddDEM(BnPZnJkyyVf7eB(v6DTmzGHIbgcyMSzu5xt2HW8yu7i1J1mTIOGZ(eme2adPGcvWsJLzN1kghTJ5q(NSmOGFS5RO4Bya(nOk)8uLLXONJ48avPcNhOk80r7Wq4q(NSmOGFS5HH4Hc8QcFktEIk3wWrkJaxHpLgBeaLkUEvavhbSVmBOa9x1QSmgopqv6vUifkUkQ(UwMmfKkcaIH)Qq6ZMHhpzwJItjyLkadfdm05z6V1Ko3mQGH9wStS5xP31YKbgkgyiGzYMrLFnzhcZJrTJupwZ0kIco7tWqydmuCkublnwMDwRyC0oMd5FYYGc(XMVIIVHb43GQ8ZtvwgJEoIZduLkCEGQWthTddHd5FYYGc(XMhgIhXNxv4tzYtu52cosze4k8P0yJaOuX1RcO6iG9LzdfO)QwLLXW5bQsVYff)IRIQVRLjtbPIaGy4VkK(Sz4XtM1O4ucwPcWqXadDosnDRhlqyUbJHrWqXdgcyMSzu5xt2HW8yu7i1J1mTIOGZ(eme2cme2vblnwMDwRyC0oMd5FYYGc(XMVIIVHb43GQ8ZtvwgJEoIZduLkCEGQWthTddHd5FYYGc(XMhgIhk5vf(uM8evUTGJugbUcFkn2iakvC9QaQocyFz2qb6VQvzzmCEGQ0RCrklUkQ(UwMmfKkcaIH)QGTHHi9zZWJNmRrXPeSsfGHIbgcz)emu80pmuCvWsJLzN1kghTJ5q(NSmOGFS5RO4Bya(nOk)8uLLXONJ48avPcNhOk80r7Wq4q(NSmOGFS5HH4b2XRk8Pm5jQCBbhPmcCf(uASrauQ46vbuDeW(YSHc0FvRYYy48avPx5IWUIRIQVRLjtbPIaGy4VkgsZ2ILvlu6ie7vJrLX(nRPZb2HHIN(HHITkyPXYSZAfTmtTUJmyq2pHrfYXpFffFddWVbv5NNQSmg9CeNhOkv48avbKmtTUJmWq8TFcgI3IC8ZxHpLjprLBl4iLrGRWNsJncGsfxVkGQJa2xMnuG(RAvwgdNhOk9kxuSS4QO67AzYuqQiaig(RY5z6VvJJ2X4in2rOv6DTmzGHIbgcpDRB88Uvegn)UmfCMH(vh4yBOkyPXYSZAfK9JXbo28yYS0vbuDeW(YSHc0FvRICigWbQocyVGuzzm65iopqvQWNsJncGsfxVkCEGQW3(HHWc4yZddfRyPRcwi1PkVhi9h7clakme2)6MSvEhgAJN3TII9k8Pm5jQCBbhPmcCfr3OYYyywyekvqQO4Bya(nOk)8uLLXW5bQIWcGcdH9VUjBL3HH245DROELBl4IRIQVRLjtbPcwASm7SwbWZzmoWXMhtMLUkk(ggGFdQYppvroed4avhbSxqQSmg9CeNhOkv4tPXgbqPIRxfopqva1ZzyiSao28WqXkw6QGfsDQY7bs)XUWcGcdH9VUjBL3HHutpHyaXEf(uM8evUTGJugbUIOBuzzmmlmcLkivavhbSVmBOa9x1QSmgopqvewauyiS)1nzR8omKA6jedOxVkCEGQiSaOWqy)RBYw5DyidzXTZxVwa]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20171010.212625, [[dqtgdaGEOsAxuK2gufZwQUjv5BcLDkyVKDJ0(rudtiJJIOHcvIbJidhsDqQKJrHFlzHuPwkv1IrPLRWdfQEkyzkQNdLjsrzQkYKP00v6IqvDvOI6zqL66OOtJQTIqTzkQ2oc5YQ(kuHMgubFhQsVgbDBPmAi5WIojc8yiUgfHZJcFMk8xQO1bvKLHMeaido6vGaZU5jZ(k3c8F)j2vyoYiMrueEm1apMa3ZMuaG(i8SZX1C5fvHztmlWfYYlkMMuWqtcWNMS9BLBbaYGJEfSLdh9Bk6A5fftGlwENVmeGUwErfqa1YrYTgcOf9c8klX5iKTlqqiBxaUulVOc8F)j2vyoYiMrKa)JvmhihttAfeh1ri0Ri6TtxXkWRSHSDbAvywtcWNMS9BLBbUy5D(YqWi5y3P9Pvabulhj3AiGw0lWRSeNJq2UabHSDb(jh7Kjz2tRa)3FIDfMJmIzejW)yfZbYX0KwbXrDec9kIE70vSc8kBiBxGwfWTMeGpnz73k3caKbh9kylho63uKQ62cVumbUy5D(YqqoAmCwM7CrDN2NwbeqTCKCRHaArVaVYsCocz7ceeY2f4A0yqMuzozslQtMKzpTc8F)j2vyoYiMrKa)JvmhihttAfeh1ri0Ri6TtxXkWRSHSDbAvah0Ka8PjB)w5wGlwENVmeW25oqT36CWKEN49j6IkGaQLJKBneql6f4vwIZriBxGGq2Ua3DUdu7TKj5ZKEYKWXNOlQa)3FIDfMJmIzejW)yfZbYX0KwbXrDec9kIE70vSc8kBiBxGwTccz7caElozs4mfv1zGtKjHECKQXMRwja]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20171010.212625, [[dWdkgaGEPuvBsOu2frSnPu2hqfZukvA2s6MIYVr8na50iTtPAVu7gv7NKgLqPAyGY4KsvUSQZtidwidhuDqIYPKsfhtkEnqwOuYsrPwmjwUGfbuPNcTmI06ekzIav1urrtwIPR0fbkxLqLNju46IQnIsOTIsAZaSDa1Hv8DHQPHsW8ek6VevpwKrJc3gKtsO8zc6AeQ6EOe9Cs9qc8tGQSBmtJykqHVgnc(hWKxx3Yi7x)OV7sH1audmyTjPPnXhdPTNre(t0PsB)zPeU7sfVuJYslLW1MP7nMPrW4Js9f3YOmfALUImw(SmKNi0QrX4fAAwsWiNWVXmsH1j0hOB0yFGUrW)ZYqnsaHwnY(1p67Uuyna1aZi7Rj5H01MPxJcy8eOmcWh681kgZiL(aDJEDxQzAem(OuFXTmIPaf(ASCLCaaKa469bkxO84KCErIENei1iWHLQrTzuMcTsxrgh4K0ufbxFJIXl00SKGroHFJzKcRtOpq3OX(aDJYGtstveC9nY(1p67Uuyna1aZi7Rj5H01MPxJcy8eOmcWh681kgZiL(aDJEDpgMPrW4Js9f3YiMcu4RXYvYbaqcGR3hOCHYJtY5fj6DsGuJIPAuBQrXMAuIqQfsCUKbojnvrW1xs4qdLRvJIPAummktHwPRiJaUEFGYfkxVbkOBumEHMMLemYj8BmJuyDc9b6gn2hOBKfVEFGYfQgHBGc6gz)6h9DxkSgGAGzK91K8q6AZ0RrbmEcugb4dD(AfJzKsFGUrVUZcMPrW4Js9f3YiMcu4RXjTuGV8Zpe9A1iWHLQrsnktHwPRiJPPwLpPLs4YRu9AuaJNaLra(qNVwXiUbAAfW4jqULXmsH1j0hOB0i7Rj5H01MPxJ9b6gfm1QAKS0sjC1O2LQxJYcc1g5d0zj4IuibQrIJZGuffl1izGhyGRr2V(rF3LcRbOgygrgK4zKcfa9bTBzumEHMMLemYj8BmJu6d0nIuibQrIJZGuffl1izGhyEDx8MPrW4Js9f3YiMcu4RXYvYbaqcGR3hOCHYJtY5fj6DsGuJIjlvJybJYuOv6kYiGR3hOCHY1BGc6gfJxOPzjbJCc)gZifwNqFGUrJ9b6gzXR3hOCHQr4gOGUAuS30ogz)6h9DxkSgGAGzK91K8q6AZ0RrbmEcugb4dD(AfJzKsFGUrVU3MzAem(OuFXTmIPaf(ASCLCaaKa469bkxO84KCErsoCJYuOv6kYOorYdcVC9gOGUrX4fAAwsWiNWVXmsH1j0hOB0yFGUrmrYdcVAeUbkOBK9RF03DPWAaQbMr2xtYdPRntVgfW4jqzeGp05RvmMrk9b6g96oqMPrW4Js9f3YiMcu4RXYvYbaqcGR3hOCHYJtY5fj5WnktHwPRiJP6eNYfkxZykK4AJIXl00SKGroHFJzKcRtOpq3OX(aDJcQtCkxOAeYykK4AJSF9J(UlfwdqnWmY(AsEiDTz61OagpbkJa8HoFTIXmsPpq3OxVg7d0nIuibQrIJZGuffl1iGNkirbV2a]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20171010.212625, [[dKtEeaGEIkAtevzxOu2grL2hr0SrQ5lGUPK8nePDQK9sTBc7xQ(jsQmmGmoKu1Vj1GLYWrHdkPCkGshtiNwXcrswkkAXc1Yr4HsQEk0YukphWerszQiQjtY0bDrb6Qev4zafUUGCzvBfLQnduz7eL7bu10iQQplO(UaCyrVgLmAK42sCsIWJr11qeopr6VkvRdOOrHiAhzYgroXWaA0i1o4Yq0qtLrMN(jW9AduePrGajx2IKljaJnQ3iY48jPh5mHJw41gj2mwJdhTaWK9kYKnguKX0xzQmICIHb0yYHJSVFXlZb6njbFVTzSw8qpqPgvpHu2tHAxDEk1Oec1WtOMWOqlUXkTI9KyLLB04kl3i1EcP0BPq1Bu78uQrMN(jW9AduePrGmY8a6qe8dyYgASoLZzvPL9YfqhBSsRwz5gn0Rnt2yqrgtFLPYiYjggqJjhoY((fVmhO3KS3KVXAXd9aLA8mg1ld3Oec1WtOMWOqlUXkTI9KyLLB04kl3yqgJ6LHBK5PFcCV2afrAeiJmpGoeb)aMSHgRt5CwvAzVCb0XgR0QvwUrd9cmmzJbfzm9vMkJiNyyanMC4i77x8YCGEtsW3BB9M86ns2BQNqk7PqTRopLYgC4Sgr4ElWa7n1b3qF2GdN1ic3BG1yT4HEGsncW1Hic)DaiXW6gLqOgEc1egfAXnwPvSNeRSCJgxz5grUoer43BiKyyDJmp9tG71gOisJazK5b0Hi4hWKn0yDkNZQsl7LlGo2yLwTYYnAOxY3KnguKX0xzQmICIHb0yYHJSVFXlZb6njbFVT1BYR3izVPEcPSNc1U68ukBWHZAeH7TadS3uhCd9zdoCwJiCVbwJ1Ih6bk1iNodyeH3bOKkDaagLqOgEc1egfAXnwPvSNeRSCJgxz5gRtNbmIW9gsjv6aamY80pbUxBGIincKrMhqhIGFat2qJ1PCoRkTSxUa6yJvA1kl3OHErct2yqrgtFLPYiYjggqJjhoY((fVmhO3KS32mwlEOhOuJNXOEz4gLqOgEc1egfAXnwPvSNeRSCJgxz5gdYyuVm8EJKrG1iZt)e4ETbkI0iqgzEaDic(bmzdnwNY5SQ0YE5cOJnwPvRSCJgAOXvwUrCk17n5qqrtlfm7TAuxqdTb]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20171010.212625, [[deeIxaqievTjPsFIQKsJcr5uis7IkggjCmrSmsvpdrutJQeUMurTnQQkFJe14KksNdrO1rvsvZdrK7HOY(OkjhKezHOQ6HKknrQsQCrsfBKQQ8rQskgjIGojvPUPu1orLFIiWsjfpLYujL2kvv(QurSxL)sLgmrhgyXi8yrnzqUSQnlL(mvLrJQCAuEnvXSf62GA3q9BidxkoovjA5i9CbtxY1jPTls9DuvoViz9uvvnFPc7NWlzANzzkRPMnJda)zgdwxH0FuuO86fsFhFklpZR7Ta1yn(NP5XdcFC6vKOCIcf(NtI)1zswFNotZbqP0YG)mYxG4XLtlffQqovX7ohdiIhsibyiHuHqIOcjHABRJhwmYW(CHbzEm8DOhgWWHzkLlgchM2XLmTZ0bdiIhA8pZYuwtnRq(8fVtgHIqi(WbHSRqsMqsMqsEHSaXJlNwkY)p2TrngUZXaI4HeYo6qijtiPQ4lKKKqQxi7kKuvml72G47uNSkLECjKKKqQVtfssfssfYUcj5fYcepUC8bkENYW(CdfIc7CmGiEiHK0zkrWISk1merKvNckgcpZBmeldkeDggH)SEeKFakha(ZMXbG)msarKvNckgcptZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgN(PDMoyar8qJ)zwMYAQzeQTToSCk3cer4Gd9WagoiKKKqM40zHSRqwG4XLdlNYTareo4CmGiEOzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNptZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRghjpTZ0bdiIhA8pZYuwtnRaXJlNapqvNYW(CdfL55bNJbeXdjKDfsOtO226qb(pIYY3juGShHKCczNNPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqswcPZ084bHpo9ksuorXmnpGuP5hM2vZ0L3ZE6rPp8X1iM1JG4aWF2QX5ft7mDWaI4Hg)ZSmL1uZitijuBBDOm47O2iKDfY7LQSMMd50CA4PpfGZ3f16w8U7jqyxyaTsrfYUcj5fsYesc12wherKvNckgc7O2iKDfsqUyPV7XhM9GqsscPEHKuHKuHSJoeYcepUC8bkENYW(CdfIc7CmGiEOzkrWISk1m6Hr0WJpeC5JHRtN5ngILbfIodJWFwpcYpaLda)zZ4aWFMMdJOHhFiiKDcdxNotZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgxNN2z6GbeXdn(NzzkRPMrO226qzW3rTri7kKKxijtijuBBDqerwDkOyiSJAJq2vib5IL(UhFy2dcjjjK6fssfYUcj5fsYeY7LQSMMd50CA4PpfGZ3f16w8U7jqyxyaTsrfYUczbIhxo(afVtzyFUHcrHDogqepKqs6mLiyrwLAgpeFrg2NlreeQzEJHyzqHOZWi8N1JG8dq5aWF2moa8Nrcr8fzyFcj)rqOMP5XdcFC6vKOCIIzAEaPsZpmTRMPlVN90JsF4JRrmRhbXbG)SvJZ)M2z6GbeXdn(NzzkRPMrO226qzW3rTri7kKKxijtijuBBDqerwDkOyiSJAJq2vib5IL(UhFy2dcjjjK6fssfYUc59svwtZHCAon80NcW57IADlE39eiSlmGwPOczxHSaXJlhFGI3PmSp3qHOWohdiIhsi7kKKjKqNqTT1P50WtFkaNVlQ1T4D3tGWUWaALI6O2iKD0HqMrOieIpSd9WiA4XhcU8XW1Po0ddy4Gq6vcjjlKKotjcwKvPMXdXxKH95sebHAM3yiwgui6mmc)z9ii)auoa8NnJda)zKqeFrg2NqYFeekHKSesNP5XdcFC6vKOCIIzAEaPsZpmTRMPlVN90JsF4JRrmRhbXbG)SvJt5PDMoyar8qJ)zwMYAQzKxijuBBDqerwDkOyiSJAJq2vijtiVxQYAAoKJhuSyuqWfF(ArQyix(yXOq2vilq84YPLI8)JDBuJH7CmGiEiHSRqsMqgE5sGWQbNIDAcj6QVjlKKtiteYo6qidVCjqy1GtXonHeD9IMSqsoHmrijvijvi7OdHKQIFWPyW3TqUDwijjH0xgAMseSiRsndrez1PG6Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pJeqez1PG6Z084bHpo9ksuorXmnpGuP5hM2vZ0L3ZE6rPp8X1iM1JG4aWF2QX1Pt7mDWaI4Hg)ZSmL1uZkKpFX7KrOieIpCqi7kKKjKKjK3lvznnhYjJWbeTcUzueYnJOxi7OdHKqTT1PHfJaQlQ1TLIcLJAJqsQq2vijuBBDuX8qXuUHIESVINJAJq2viHoHABRdf4)iklFNqbYEesYjKDwi7kKKxijuBBDqerwDkOyiSJAJqs6mLiyrwLAwGHHOaFOai42QstnZBmeldkeDggH)SEeKFakha(ZMXbG)mJHHOaFOaWRniK(tLMAMMhpi8XPxrIYjkMP5bKkn)W0UAMU8E2tpk9HpUgXSEeeha(ZwnosCANPdgqep04FMLPSMAgvfZYUni(o1b6TSmRessICczIIzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKKPN0zAE8GWhNEfjkNOyMMhqQ08dt7Qz6Y7zp9O0h(4AeZ6rqCa4pB14sumTZ0bdiIhA8pZYuwtnJqTT1brez1PGIHWoQnczxHK8cjHABRJhwmYW(CHbzEm8DuBMPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqsgjt6mnpEq4JtVIeLtumtZdivA(HPD1mD59SNEu6dFCnIz9iioa8NTACjjt7mDWaI4Hg)ZSmL1uZa5IL(UhFy2dcPxroHuVq2vijVqsMqwG4XLtlffQqovX7ohdiIhsi7kKeQTToEyXid7ZfgK5XW3rTri7kKGCXsF3Jpm7bH0RiNqQxijDMseSiRsnJEyen84dbx(y460zEJHyzqHOZWi8N1JG8dq5aWF2moa8NP5WiA4XhcczNWW1PcjzjKotZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgxI(PDMoyar8qJ)zwMYAQzeQTToEyXid7ZfgK5XW3rTri7kKKjKKxiVxQYAAoKJhuSyuqWfF(ArQyix(yXOq2rhcjixS0394dZEqi9kYjK6fssNPeblYQuZAPOqfYPkEFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcviNQ49zAE8GWhNEfjkNOyMMhqQ08dt7Qz6Y7zp9O0h(4AeZ6rqCa4pB14si5PDMoyar8qJ)zwMYAQzGCXsF3Jpm7bH0RiNqQFMseSiRsnZxeKzGOlaknaN)mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8AIGmdefsLGsdW5ptZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgxIxmTZ0bdiIhA8pZYuwtndKlw67E8HzpiKEf5essEMseSiRsnRLIcviNQ49zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkuHCQI3fsYsiDMMhpi8XPxrIYjkMP5bKkn)W0UAMU8E2tpk9HpUgXSEeeha(ZwnUKopTZ0bdiIhA8pZYuwtnJqTT1XdlgzyFUWGmpg(oQnZuIGfzvQziIiRofuFM3yiwgui6mmc)z9ii)auoa8NnJda)zKaIiRofuxijlH0zAE8GWhNEfjkNOyMMhqQ08dt7Qz6Y7zp9O0h(4AeZ6rqCa4pB14s8VPDMoyar8qJ)zwMYAQzfiEC54du8oLH95gkef25yar8qczxHSaXJlhyvk0Pi1G7BBzz2X5uohdiIhsi7kKKjKHxUeiSAWPyNMqIU6BYcj5eYeHSJoeYWlxcewn4uSttirxVOjlKKtitessNPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqsMxq6mnpEq4JtVIeLtumtZdivA(HPD1mD59SNEu6dFCnIz9iioa8NTACjkpTZ0bdiIhA8pZYuwtnJmHSaXJlhEik2f16YhdxN6CmGiEiHSJoeYcepUC4PI9Dkd7ZLQIVlFh0GWohdiIhsijvi7kKKjKHxUeiSAWPyNMqIU6BYcj5eYeHSJoeYWlxcewn4uSttirxVOjlKKtitessNPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqswNjDMMhpi8XPxrIYjkMP5bKkn)W0UAMU8E2tpk9HpUgXSEeeha(ZwnUKoDANPdgqep04FMseSiRsndrez1PG6Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pJeqez1PG6cjz6jDMMhpi8XPxrIYjkMP5bKkn)W0UAMU8E2tpk9HpUgXSEeeha(ZwnUesCANPdgqep04FMseSiRsnZxeKzGOlaknaN)mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8AIGmdefsLGsdW5lKKLq6mnpEq4JtVIeLtumtZdivA(HPD1mD59SNEu6dFCnIz9iioa8NTAC6vmTZ0bdiIhA8pZYuwtnJ8cjHABRdpvSVtzyFUuv8D57Gge2rTzMseSiRsnJhIIDrTU8XW1PZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pJeIOyHe1kKDcdxNotZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgN(KPDMoyar8qJ)zkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK5FKotZJhe(40Rir5efZ08asLMFyAxntxEp7PhL(WhxJywpcIda)zRgNE9t7mDWaI4Hg)ZSmL1uZkKpFX7KrOieIpCyMseSiRsn7Wni(o1LQIVlFh0GWZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pth4geFNkKAuXxi7KdAq4zAE8GWhNEfjkNOyMMhqQ08dt7Qz6Y7zp9O0h(4AeZ6rqCa4pB140tYt7mDWaI4Hg)ZSmL1uZkKpFX7KrOieIpCqi7kKKjKKxijuBBD4PI9Dkd7ZLQIVlFh0GWoQncjPZuIGfzvQz8uX(oLH95svX3LVdAq4zEJHyzqHOZWi8N1JG8dq5aWF2moa8NrcvX(oLH9jKAuXxi7KdAq4zAE8GWhNEfjkNOyMMhqQ08dt7Qz6Y7zp9O0h(4AeZ6rqCa4pB1QzwZZmqK5)GIHWJtFNtwTba]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20171010.212625, [[dKJMgaGEIkTjGq2LczBevmtGOztv3eq3wj7eQ2R0UHSFfnkIQmmc1Vf9CuoTkdwPgUq5GqXPiQQJbWJfSqf0sHslMilhvpuipfzzuPwNq1ebcMkbnzqMoLlsf68eOlt66GYgPs2kvuBwHA7ubFMq(gbmnqL08avINbQuJdiuJMO8xG6Kur(oOkxduv3duXHv1RvGfbKUaQWsuGFXSsLW)LwIUv0C7INml(CdPJFyEReftd37p5(2LOI7g(akHv96Z0I7wmabaiwSCgbqoWhUDdIlHvFibfElTehg6cGJLWt5Jg)EpdSLGDlqjmb7seRcloGkSKJOxYRqDyjkWVywjlfjYRJoKPCoSygRegPZFMGLwhcc8yUQYvl5ec6cVL8sOePLaMqo)C8FPLkH)lTeWdbn3U4QkxTew1RptlUBXaeaG4syvwcJhuwfwRuKmnmay6GUuKvPsati8FPLQvC3vyjhrVKxH6WsyKo)zcwk8Ep4pyxIa7pMvYje0fEl5LqjslbmHW)LwIUv0C7INml(ChbcSsatiNFo(V0sLIKPHbath0LISkvc)xAPO37NBmb7s0CdYJzLWWfXkH(LchqPBfn3U4jZIp3rGad0syvV(mT4UfdqaaIlrYs4bmHUXNYzDyjSklHXdkRcRvIm(fSizAyqhwR4WDfwYr0l5vOoSef4xmRK9EfzJK46BYaNJbZoee)fLSFKIEjVcn3GO5oKPhkHhAKexFtg4Cmy2HG4VOK9J466peBUHlZna4xcJ05ptWsCyiWFWUeb2FmRuKmnmay6GUuKvPsatiNFo(V0sLW)Lwclm0CJjyxIMBqEmRegUiwj0Vu4akDRO52fpzw85wkzZDSm9hseOLWQE9zAXDlgGaaexcRYsy8GYQWALCcbDH3sEjuI0sati8FPLOBfn3U4jZIp3sjBUJLP)qIQvC4AfwYr0l5vOoSef4xmReuAJK46BYaNJbZoee)fLSFKDHbhsujmsN)mblXHHa)b7sey)XSsrY0WaGPd6srwLkbmHC(54)slvc)xAjSWqZnMGDjAUb5XS5wEaKFjmCrSsOFPWbu6wrZTlEYS4ZTuYMB7cdoKiqlHv96Z0I7wmabaiUewLLW4bLvH1k5ec6cVL8sOePLaMq4)slr3kAUDXtMfFULs2CBxyWHevR4WVcl5i6L8kuhwIc8lMvsc24XJsj)zk)TlrJGfRegPZFMGL4WqG)GDjcS)ywPizAyaW0bDPiRsLaMqo)C8FPLkH)lTewyO5gtWUen3G8y2Clp3YVegUiwj0Vu4akDRO52fpzw85oL8NP83UebAjSQxFMwC3IbiaaXLWQSegpOSkSwjNqqx4TKxcLiTeWec)xAj6wrZTlEYS4ZDk5pt5VDjQwXLtfwYr0l5vOoSegPZFMGLcV3d(d2LiW(JzLCcbDH3sEjuI0sati8FPLOBfn3U4jZIp3m7rqphQeWeY5NJ)lTuPizAyaW0bDPiRsLW)Lwk69(5gtWUen3G8y2ClpaYVegUiwj0Vu4akDRO52fpzw85Mzpc65qGwcR61NPf3TyacaqCjswcpGj0n(uoRdlHvzjmEqzvyTsKXVGfjtdd6WA1kbc64hM36WAT]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20171010.212625, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxtruzMfwDSrNxc51usvgBLf2CL5LtYatm3edmWyJlXytnZidoEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnfDVD2zSvMlW9gDP9MBZ51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnLuLXwzHnxzE5KmWeZnXaJxtjvzZ9wDYnwzZ5fvErNxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uErNx051uofwBL51utLwBd5hygj3BZrNo(bgCYv2yV1MyHrNx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20171010.212625, [[deubnaqisvztur(KiQyuujofvs7sGHHuoMGwgvQNHuvMgsv4AIOSnQOQVHuzCivPZjIQSosvLMNis3JuvX(OIkhevQfIk5HKctuev1fjfTrreFuevAKKQQojPu3uuTtq9tQO0srfpLyQOQ2kPkFfPQAVs)vrnykoSQwmIESctgKldTzr5ZOkJMu50K8AQWSPQBJWUb(TsdxKoosv0Yr55cnDvUos2UI03veNxewpvumFsj7Ns3WYVImyQ0Rsf4NaRikcnSMKW24PFTgErR5udhkaVkjFm7P8x5Qch0JFelSBAH0fsJMZhe68jJ(CtVv4Gpuc(kcScjvwwGokapKPa8MzuaCEc(PliGHeVceRW94uliw(foS8ROj4j9iu5QImyQ0RcjvwwGAKy(E)cIbmK4vGO1KuRjmizwJtwZ9EeCbQrI579ligGGN0Jqv4Mu5vxIkzSnEZXJPCGv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyLKW24znYXuoWkCqp(rSWUPfsxiTkCW4sXgyS87vrdD4Wr(ofjqWvYk5le8tGv6vy3LFfnbpPhHkxv4Mu5vxIkmKyzr0JX48ef4qwfTbqQXFlRcybyL8fsVNb)eyLkWpbwHdsSSi6Xy0AOFf4qwfoOh)iwy30cPlKwfoyCPydmw(9QOHoC4iFNIei4kzL8fc(jWk9km9v(v0e8KEeQCvrgmv6vHKkllGPiWaQuRXjRrFwJlwdjvwwWs6vhY(tTGaQuRXjR5hNAkoJaKqHrRjPwJBRX1kCtQ8QlrfD7eVcWBM0)XRI2ai14VLvbSaSs(cP3ZGFcSsf4NaRO)7eVcWZA4Y)XRch0JFelSBAH0fsRchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfMEu(v0e8KEeQCvrgmv6v5wE88yWyxp0obeTgNSgxSgxSg9zn37rWfKXwNbbZPu(igGGN0JqwJwAznUynmkaAnj1ACBnoznmkGAmNUtqwWGIXqWznj1ACtVwJRwJRwJRv4Mu5vxIklPxDi7p1cQOnasn(BzvalaRKVq69m4NaRub(jWkolPxDi7p1cQWb94hXc7MwiDH0QWbJlfBGXYVxfn0Hdh57uKabxjRKVqWpbwPxHtw5xrtWt6rOYvfzWuPxfgfaTgNZAOpRrlTSgsQSSahkVxb4nt8dDkagqLAnAPL1qsLLfSKE1HS)uliGkTc3KkV6suzj9Qdz)Hv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyfNL0RoK9hwHd6XpIf2nTq6cPvHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVc78LFfnbpPhHkxvKbtLEvULhppgm21dTtarRXjRXfRXfRbPNuQ0uekySG4YU48y9qZJLHwJwAznKuzzbPkV)zZB2CgBJxavQ14Q14K1qsLLfqb0T(eZXJHaENUaQuRXjRbcjPYYcyVZSm1adI3pCyn6hRjzwJtwJ(SgsQSSGL0RoK9NAbbuPwJRv4Mu5vxIkrfaI9824hNZOyjQOnasn(BzvalaRKVq69m4NaRub(jWkIcaXEEB8torRjjuSev4GE8JyHDtlKUqAv4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RW0v(v0e8KEeQCvrgmv6vHKkllWHY7vaEZe)qNcGbuPwJtwJlwJ(SgKEsPstrOahR)uSpodWjzlfaAEIY7TgT0YAU3JGlG3F6qMcWBoElJiabpPhHSgT0YA(XPMIZiajuy0ACo9J142ACTc3KkV6sujJTXlosC6WkAdGuJ)wwfWcWk5lKEpd(jWkvGFcSssyB8IJeNoSch0JFelSBAH0fsRchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfMEl)kAcEspcvUQidMk9QWOaQXC6obzbdkgdbN14Cwd9sZA0slRXfRHKkllyj9Qdz)PwqavQ14K1OpRHKkllWHY7vaEZe)qNcGbuPwJRv4Mu5vxIkzSnEZXJPCGv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyLKW24znYXuoqRXLqxRWb94hXc7MwiDH0QWbJlfBGXYVxfn0Hdh57uKabxjRKVqWpbwPxHtELFfnbpPhHkxv4Mu5vxIklPxDi7pSI2ai14VLvbSaSs(cP3ZGFcSsf4NaR4SKE1HS)qRXLqxRWb94hXc7MwiDH0QWbJlfBGXYVxfn0Hdh57uKabxjRKVqWpbwPxHdPv(v0e8KEeQCvrgmv6vHrbuJ50DcYcgumgcoRjPwdD0SgNSg9znKuzzb6Oa8qMcWBMrbW5j4NUGaQ0kCtQ8QlrfDldmVzZtuGdzv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyf9FzaRzZSg6xboKvHd6XpIf2nTq6cPvHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVchgw(v0e8KEeQCvHBsLxDjQWZ)d17NFOPpyGv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyLKR)hQ3BnCdn9bdSch0JFelSBAH0fsRchmUuSbgl)Ev0qhoCKVtrceCLSs(cb)eyLEfo0D5xrtWt6rOYvfUjvE1LOsgBJ3C8ykhyfTbqQXFlRcybyL8fsVNb)eyLkWpbwjjSnEwJCmLd0ACXTRv4GE8JyHDtlKUqAv4GXLInWy53RIg6WHJ8DksGGRKvYxi4NaR0RWH0x5xrtWt6rOYvfzWuPxLB5XZJbJD9q7eq0ACYACXA0N1qsLLfOJcWdzkaVzgfaNNGF6ccOsTgxRWnPYRUev0rb4HmfG3mJcGZtWpDbv0gaPg)TSkGfGvYxi9Eg8tGvQa)eyf9NcWdzkapRHdfaTg6h)0fuHd6XpIf2nTq6cPvHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVchspk)kAcEspcvUQidMk9QClpEEmySRhANaIv4Mu5vxIkir6obzZmkaopb)0furBaKA83YQawawjFH07zWpbwPc8tGv0KiDNGmRHdfaTg6h)0fuHd6XpIf2nTq6cPvHdgxk2aJLFVkAOdhoY3PibcUswjFHGFcSsVEvKuCOEVYz(tTGc7ozH9Ab]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20171010.212625, [[deuDsaqisfTjOQ(KGagfuLtbvAvqfQDrfddv6yqXYKiptqY0iv4AsOSnOI6BOQmoOcX5GksRdQqAEsO6EqfSpQkoivPwiPspKQKjkiqxKQkBuqQrcveNKQQUjuANe6NccTuQupLYuPk2kvL(QGO2RQ)skdgLddzXe8yjnzfDzWMrfFMkz0KQonrVwqnBHUTc7gXVLA4OkhxqKLR0Zjz6IUUaBhvvFxcoVe16fe08Lq2psFm3ZnRUsE5TBIObCZKdVOSqVTkXrPmHwDlee4GcI519MBicifCXsCXWhgUCXzhm4CXcvjCKBUb0SSh5aUTbezvJxxawhoOyuPLTgFCV5DnLnrDpxeZ9CZpcsicZR7nRUsE5Tefbs6iRL1suSjkhGGeIWKYWNYec4WXrwlRLOytuolmqsIIYkoL5QoPm8PSA3XzxG4iSak1R1C0usYCrUAfYzHbssuuMpu2gqaLtkhGw2A64M3cYOmlFJZ2QutLRmmCZFYuwrzV3inbUHTN(Iwr0aUDtenGBHEBvszwUYWWn3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75flDp38JGeIW86EZQRKxElrrGKoUqPEyLexAQS3HdqqcryEZBbzuMLVTWOxfebLsRGKKWEZFYuwrzV3inbUHTN(Iwr0aUDtenGBUHrVkickfLfYssc7n3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fd19CZpcsicZR7nRUsE5nHaoCCw5aCc4rz4tzBabuoPCaAzRPdkR4ugEuMR6KYWXuwjkd3BEliJYS8n9DHOK4stiIu5n)jtzfL9EJ0e4g2E6lAfrd42nr0aUHt6crjXfLPBePYBUHiGuWflXfdFy4EZnO6GTcQ755nV0d1WyB(HbqYlCdBpfrd42ZlQJ75MFeKqeMx3BwDL8YBBabuoPCaAzRHZuwXPmx1jLHpLPtklrrGKoUqPEyLexAQS3HdqqcryEZBbzuMLV1crzclkHB(tMYkk79gPjWnS90x0kIgWTBIObClefIYewuc3CdraPGlwIlg(WW9MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxSy3Zn)iiHimVU3S6k5L32acOCs5a0YwthuwXPmx1jLHpLHhLv7oo7cehHfqPETMJMssMlYvRqolmqsIIY8HY4szfveLTbezvJxxawNAWUajPSItz8XLYW9M3cYOmlFRfIYewuc38NmLvu27nstGBy7PVOvenGB3erd4wikeLjSOeOm8WG7n3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fX575MFeKqeMx3BwDL8YBBarw141fG1PgSlqskZhCGYWPfJYWNYuqQj0KaLtkHfdovth8QuMpugxkdFkR2DC2fioclGs9AnhnLKmxKRwHCwyGKefL5dLX9M3cYOmlFJZ2QutLRmmCZFYuwrzV3inbUHTN(Iwr0aUDtenGBHEBvszwUYWaLHhgCV5gIasbxSexm8HH7n3GQd2kOUNN38spudJT5hgajVWnS9uenGBpViF3Zn)iiHimVU3S6k5L3ec4WXzLdWjGhLHpLbHuGKhpy6WdwfWpSisf0AoAPEqdeAI2aTz59M3cYOmlFBHrVkickLwbjjH9M)KPSIYEVrAcCdBp9fTIObC7MiAa3CdJEvqeukklKLKewkdpm4EZnebKcUyjUy4dd3BUbvhSvqDppV5LEOggBZpmasEHBy7PiAa3EErCK75MFeKqeMx3BwDL8YBcbC44SYb4eWJYWNYWJYMD6SWOxfebLsRGKKW6KYAyjXfLvuruwT74SlqCwy0RcIGsPvqssyDwyGKefL5dL5QoPSIkIYWJY0jLbHuGKhpy6WdwfWpSisf0AoAPEqdeAI2aTz5LYWNY0jLLOiqshxOupSsIlnv27WbiiHimPmCPmCV5TGmkZY303fIsIlnHisL38NmLvu27nstGBy7PVOvenGB3erd4goPleLexuMUrKkPm8WG7n3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXP3Zn)iiHimVU3S6k5L30jLjeWHJZkhGtapkdFktNugEuwIIajDCHs9WkjU0uzVdhGGeIWKYWNY0jLHhLv7oo7ceNfg9QGiOuAfKKewNfgijrrz(qz4rzUQtkdhtzLOmCPSIkIY2acqz(qz6GYWLYWLYWNY2acqz(qzH6M3cYOmlFRfIYewuc38NmLvu27nstGBy7PVOvenGB3erd4wikeLjSOeOm8kH7n3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXW9EU5hbjeH519MvxjV8w2UCfbNA3XzxGOOm8Pm8Om8OmiKcK84btNAtu9MkTAhNA1EbkROIOmHaoCC4jJr0Q1C04STkDc4rz4sz4tzcbC44eq03XYAQCbIRuVtapkdFkBccbC44SOqyVYk4OsunmLHduwXOm8PmDszcbC440crzclkLnXjGhLHpLTbezvJxxawNAWUajPmFOSqvmkd3BEliJYS8nLKmxKRwHuACc2Y38NmLvu27nstGBy7PVOvenGB3erd4MjjZf5QvOqafLf6GT8n3qeqk4IL4IHpmCV5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXG5EU5hbjeH519MvxjV8MqahooHLXOK4sBGQ6LeWjGhLHpLHhLPtkdcPajpEW0jCht5IuAeOaNoGm1kiJrkROIOmunL8dAabgsqrz(Gduwjkd3BEliJYS8noBRsvTCQhU5pzkROS3BKMa3W2tFrRiAa3UjIgWTqVTkv1YPE4MBicifCXsCXWhgU3CdQoyRG6EEEZl9qnm2MFyaK8c3W2tr0aU98IykDp38JGeIW86EZQRKxEBdiYQgVUaSo1GDbssz(GdugFCV5TGmkZY34STk1u5kdd38NmLvu27nstGBy7PVOvenGB3erd4wO3wLuMLRmmqz4vc3BUHiGuWflXfdFy4EZnO6GTcQ755nV0d1WyB(HbqYlCdBpfrd42ZlIju3Zn)iiHimVU3S6k5L3q1uYpObeyibfL5doqzLU5TGmkZY3wy0RcIGsPvqssyV5pzkROS3BKMa3W2tFrRiAa3UjIgWn3WOxfebLIYczjjHLYWReU3CdraPGlwIlg(WW9MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxeJoUNB(rqcryEDVz1vYlVHhLv7oo7ceNfg9QGiOuAfKKewNfgijrrzfNYWJYCvNugoMYkrz4szfveLjeWHJJluQhwjXLMk7D4OsunmLHduggUugUug(uwT74SlqCewaL61AoAkjzUixTc5SWajjkkZhkBdiGYjLdqlBnDqz4tzjkcK0Xfk1dRK4stL9oCacsicZBEliJYS8noBRsnvUYWWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUf6TvjLz5kddugEHc3BUHiGuWflXfdFy4EZnO6GTcQ755nV0d1WyB(HbqYlCdBpfrd42ZlIPy3Zn)iiHimVU3S6k5L30jLjeWHJZkhGtapkdFkdpktNuwIIajDCHs9WkjU0uzVdhGGeIWKYkQikR2DC2fiolm6vbrqP0kijjSolmqsIIY8HYWJYCvNugUugU38wqgLz5BTquMWIs4M)KPSIYEVrAcCdBp9fTIObC7MiAa3crHOmHfLaLHxOW9MBicifCXsCXWhgU3CdQoyRG6EEEZl9qnm2MFyaK8c3W2tr0aU98IyW575MFeKqeMx3BwDL8YB1UJZUaXrybuQxR5OPKK5IC1kKZcdKKOOmFOmmfJYWNY2aISQXRlaRtnyxGKuwXXbkJpUug(u2gqaLtkhGw2AHIY8HYCvN38wqgLz5B67LO1C0kijjS38NmLvu27nstGBy7PVOvenGB3erd4goPxcL1COSqwssyV5gIasbxSexm8HH7n3GQd2kOUNN38spudJT5hgajVWnS9uenGBpVig(UNB(rqcryEDVz1vYlVv7oo7cehHfqPETMJMssMlYvRqolmqsIIY8HY2acOCs5a0Ywth38wqgLz5BC2wLAQCLHHB(tMYkk79gPjWnS90x0kIgWTBIObCl0BRskZYvggOm80bU3CdraPGlwIlg(WW9MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNpVz8GQefLHqukBYflvmmp)ba]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20171010.212625, [[de0PnaqisjAtIsFcfsAuKQ6uKsTlkmmf5ykQLjGNHc10iLW1qPyBcI6BKQmoukPZHsPADOqQMNGW9eK2hkvhKI0cPiEOGYerHexuq1grH4JOqkJeLsCsrWnrj7Ke)eLszPKkpLQPsrTvrOVskj7f8xIAWiomQwmj9yHMmKUSQnlQ(SiA0c0Pj8ArXSv42qSBK(TsdxKoUGilxQNtPPl56ez7OO(oP48OG1tkPMpkY(HAygmdUch5G7cKWWegPxBXOJjQRftkrmJGMeCp9rbFi0AEjwkOeGnZGZO8CU0Oatax3hNBpOeyAwV5PPq2yoKzdJdWwbx35OmywGCWvLYZnckrt(wqtk3s0lR580LA0hHlOwWnnwILAbZGYmyg8WPC1Xrbta3JTiTaV4JtldBqEvVf0KY2QfzU14uU64OyswmPLOIOC6Q5TruQ7tlmjeyIwmHjzXKwIERrjqUCTYbWe2XKayswmjU7aD1qnos6Q5TClrVSMZtxQrFeUGAXe2XKjmjlMGEvP8CJMR1BlI3Ww8ygmjumHnyswmrFmjU7aD1qncUnvEZL1iO1BJ(iCb1IjSJjtyctmHjAjMu8XPLrWTPYBUSgbTEBCkxDCumrBWnvvmefdGN3RTKTvlYCWtGIkI8ABWPl9GZArtK3kCKdo4kCKdoJ0RTWeVArMdUUpo3EqjW0SEZtGR72vQJ3cMHc8Wc(ygwlZh50cubN1IQWro4qbkbaZGhoLRookyc4ESfPf4TeveLtxnVnIsDFAHjShkMW4jmjlMOpMOpMOkLNB0cKBiLIjzXKhssI00JAK(2EMFZPXlV5YvWlF1LkJW7IHgt0gtyIjmrFmP4JtlJK8k4BbnPST2gX4uU64OyswmrFmrvkp3OpY22pU1kRrqR3g9r4cQftcrOysYikMWetyIwIjQs55g9r22(XTwzncA92qkft0gt0gt0gCtvfdrXa49r22(XTwzncA9g8eOOIiV2gC6sp4Sw0e5Tch5GdUch5GR7iBB)4wlMOvcA9gCDFCU9GsGPz9MNax3TRuhVfmdf4Hf8XmSwMpYPfOcoRfvHJCWHcuymyg8WPC1Xrbta3JTiTaxFmrFmPLOIOC6Q5TruQ7tlmH9qXKatyswmX(swDPswJs8EMTlRfPrmHDmzct0gtyIjmPLOIOC6Q5TruQ7tlmH9qXegpHjAJjzXevP8CJwGCdPuWnvvmefdGhC1me0KYQdUTapbkQiYRTbNU0doRfnrERWro4GRWro4SLvZqqtIjMm42cCDFCU9GsGPz9MNax3TRuhVfmdf4Hf8XmSwMpYPfOcoRfvHJCWHcu0cWm4Ht5QJJcMaUhBrAbU9LS6sLSgL4DGj5aPrmHDmzctYIjTeveLtxnVnqFUikkmjeHIjZSbtYIjTe9ysicftymMKftuLYZnsfJbVL3C58ETLHukMKft0smP4JtldBqEvVf0KY2QfzU14uU64OGBQQyikgapVxBjBRwK5GNafve512Gtx6bN1IMiVv4ihCWv4ihCgPxBHjE1Imht0FwBW19X52dkbMM1BEcCD3UsD8wWmuGhwWhZWAz(iNwGk4SwufoYbhkqHnGzWdNYvhhfmbCp2I0c8wIkIYPRM3grPUpTWKqekMOfSbtyIjmPLO3AucKlxRmBWKqGjjJOGBQQyikgaFvhI6nVo4jqrfrETn40LEWzTOjYBfoYbhCfoYbNTPoe1BEDW19X52dkbMM1BEcCD3UsD8wWmuGhwWhZWAz(iNwGk4SwufoYbhkqjKbZGhoLRookyc4ESfPf41Mm54gXDhORgQftYIj6Jj6JjpKKePPh1iUu72LvoUdu542htyIjmrvkp3ivmg8wEZLZ71wgsPyI2yswmrvkp3qIgChmiBR(0KvqdPumjlMGEvP8CJMR1BlI3Ww8ygmjumHnyI2GBQQyikga3kOOnp5A5w5CPMbWtGIkI8ABWPl9GZArtK3kCKdo4kCKdUlOOnp5A5mQwmHrKAgax3hNBpOeyAwV5jW1D7k1XBbZqbEybFmdRL5JCAbQGZArv4ihCOaf9aZGhoLRookyc4ESfPf4TeveLtxnVnqFUikkmH9qXegpHjzXKwIERrjqUCTYmgtyhtsgrb3uvXqumaEWTPYBUSgbTEdEcuurKxBdoDPhCwlAI8wHJCWbxHJCWzlBtXKnht0kbTEdUUpo3EqjW0SEZtGR72vQJ3cMHc8Wc(ygwlZh50cubN1IQWro4qbkSvWm4Ht5QJJcMaUhBrAbUQuEUrgXyiOjLr4XGc6nKsXKSyI(yIwIjpKKePPh1iZokrZTY0RjFLOOYAeJbMWetysXhNwgj5vW3cAszBTnIXPC1XrXeMyct4XsW8Lp9iIBXe2dftcGjAdUPQIHOya88ETLnYqf8GNafve512Gtx6bN1IMiVv4ihCWv4ihCgPxBzJmubp46(4C7bLatZ6npbUUBxPoElygkWdl4JzyTmFKtlqfCwlQch5GdfOW2bZGhoLRookyc4ESfPf48yjy(YNEeXTyc7HIjba3uvXqumaEYbpk4dzokZCA8GNafve512Gtx6bN1IMiVv4ihCWv4ihCgTbpk4dmXuuM504bx3hNBpOeyAwV5jW1D7k1XBbZqbEybFmdRL5JCAbQGZArv4ihCOaL5jWm4Ht5QJJcMaUhBrAbopwcMV8PhrClMWEOysaWnvvmefdG3hzB7h3AL1iO1BWtGIkI8ABWPl9GZArtK3kCKdo4kCKdUUJST9JBTyIwjO1Bmr)zTbx3hNBpOeyAwV5jW1D7k1XBbZqbEybFmdRL5JCAbQGZArv4ihCOaL5zWm4Ht5QJJcMaUhBrAbElrfr50vZBd0NlIIctyhtcWgmHjMWKwIEmHDmHXGBQQyikgaFvhI6nVo4jqrfrETn40LEWzTOjYBfoYbhCfoYbNTPoe1BEDmr)zTbx3hNBpOeyAwV5jW1D7k1XBbZqbEybFmdRL5JCAbQGZArv4ihCOaL5aGzWdNYvhhfmbCp2I0c8AtMCCJ4Ud0vd1IjzXe9XKwIkIYPRM3grPUpTWKqGjmEctYIjTe9wJsGC5ALdGjSJjjJOyI2GBQQyikga)iPRM3YTe9YAopDPGNafve512Gtx6bN1IMiVv4ihCWv4ih8WrsxnVXeDs0JjA15PlfCDFCU9GsGPz9MNax3TRuhVfmdf4Hf8XmSwMpYPfOcoRfvHJCWHckW9ylslWHcaa]] )

    storeDefault( [[SimC Frost: bos generic]], 'actionLists', 20171010.212625, [[de0nsaqisH2euvFsqaJcQYPGkTkOc1UOIHHKoMeTmj0ZGcAAKcUguiBdQO(gbzCqfIZbvKwhuH08Gc19GkyFuvCqQIwiPOhsvyIcc0fPQYgHcmsOI4Kuv1nHs7Kq)uqOLsQ6PuMkvPTsvPVkiQ9Q6VuPbJQddzXi1JL0KLQld2ms8zsLrtkDAIETGA2cDBPSBe)wXWjWXfez5k9CsMUORlW2jO(UeCEOO1liO5liTFu(L37nrudUzYMhmogSJkXrzC6rX46acSY6TqqGckiMxZB6HiGuWflsTuOsQuXzNsCgJWWI4i3S6kfK3U5znLdrDVxS8EV5hbrhH(18MvxPG8wIIajDKvmDtuCikhGGOJqNXXNXPdOqXrwX0nrXHOCwOHKefJJXmUUANXXNXRZe7tbId9cOuR7qXvjj9fPBuiNfAijrX4(W4BabuoPSbU54QHBEslJYeZBu2rLUQCLHHB(t6YkkN9gziWnSt3x0kIAWTBIOgCdd2rLmULRmmCtpebKcUyrQLcvs9MEqnbBfu37ZBEOfQHXocdnGKN(g2PlIAWTNxS49EZpcIoc9R5nRUsb5Tefbs6OdLAHvs05QYzBoabrhH(npPLrzI5TfAZQGiOuUfKKe2B(t6YkkN9gziWnSt3x0kIAWTBIOgCtp0MvbrqPy8qwssyVPhIasbxSi1sHkPEtpOMGTcQ795np0c1WyhHHgqYtFd70frn42ZlIH37n)ii6i0VM3S6kfK3OdOqXzLnWjqaJJpJVbeq5KYg4MJRgyCmMXXJX1v7mooMXlY44EZtAzuMyEt7uikj6CPJivEZFsxwr5S3idbUHD6(IwrudUDte1GB4KPqus0X4AgrQ8MEicifCXIulfQK6n9GAc2kOU3N38qludJDegAajp9nStxe1GBpVOgU3B(rq0rOFnVz1vkiVTbeq5KYg4MJloZ4ymJRR2zC8zCnY4jkcK0rhk1cRKOZvLZ2CacIoc9BEslJYeZBdDuMWIs4M)KUSIYzVrgcCd709fTIOgC7MiQb3cr6OmHfLWn9qeqk4IfPwkuj1B6b1eSvqDVpV5HwOgg7im0asE6ByNUiQb3EErm6EV5hbrhH(18MvxPG82gqaLtkBGBoUAGXXygxxTZ44Z44X41zI9PaXHEbuQ1DO4QKK(I0nkKZcnKKOyCFyCQmEOHY4BarwDfmfG1PgSlqsghJzCHOY44EZtAzuMyEBOJYewuc38N0Lvuo7nYqGByNUVOve1GB3ern4wishLjSOeyC8kX9MEicifCXIulfQK6n9GAc2kOU3N38qludJDegAajp9nStxe1GBpVioFV38JGOJq)AEZQRuqEBdiYQRGPaSo1GDbsY4(GdmoofJyC8zCfKU0djq5KsylXPUAqqLX9HXPY44Z41zI9PaXHEbuQ1DO4QKK(I0nkKZcnKKOyCFyCQ38KwgLjM3OSJkDv5kdd38N0Lvuo7nYqGByNUVOve1GB3ern4ggSJkzClxzyGXXRe3B6HiGuWflsTuOsQ30dQjyRG6EFEZdTqnm2ryObK803WoDrudU98IcDV38JGOJq)AEZQRuqEJoGcfNv2aNabmo(moesbsbcGUJayvGWWIivWDO4MAbxGEiUn0MyU38KwgLjM3wOnRcIGs5wqssyV5pPlROC2BKHa3WoDFrRiQb3UjIAWn9qBwfebLIXdzjjHLXXRe3B6HiGuWflsTuOsQ30dQjyRG6EFEZdTqnm2ryObK803WoDrudU98I4i37n)ii6i0VM3S6kfK3OdOqXzLnWjqaJJpJJhJthqHIZcTzvqeuk3csscRtGagp0qz86mX(uG4SqBwfebLYTGKKW6Sqdjjkg3hgxxTZ4HgkJJhJRrghcPaPabq3raSkqyyrKk4ouCtTGlqpe3gAtmxghFgxJmEIIajD0HsTWkj6Cv5SnhGGOJqNXXLXX9MN0YOmX8M2Pqus05shrQ8M)KUSIYzVrgcCd709fTIOgC7MiQb3WjtHOKOJX1mIujJJxjU30draPGlwKAPqLuVPhutWwb19(8MhAHAySJWqdi5PVHD6IOgC75fXP37n)ii6i0VM3S6kfK30iJthqHIZkBGtGaghFgxJmoEmEIIajD0HsTWkj6Cv5SnhGGOJqNXXNX1iJJhJxNj2NceNfAZQGiOuUfKKewNfAijrX4(W44X46QDghhZ4fzCCz8qdLX3acW4(W4AGXXLXXLXXNX3acW4(W4y4npPLrzI5THoktyrjCZFsxwr5S3idbUHD6(IwrudUDte1GBHiDuMWIsGXXRiU30draPGlwKAPqLuVPhutWwb19(8MhAHAySJWqdi5PVHD6IOgC75flPEV38JGOJq)AEZQRuqElhD6IGtDMyFkqumo(moEmoEmoesbsbcGUtDiQztLBDID36SaJhAOmoDafkocKXiADhkUu2rLobcyCCzC8zC6akuCciANiMUQCbIUuRtGaghFgVd0buO4SOq4SYk4OsunmJJdmogX44Z4AKXPdOqXzOJYewukhItGagh3BEslJYeZBkjPViDJcPCPeSyEZFsxwr5S3idbUHD6(IwrudUDte1GBMK0xKUrHcbumogeSyEtpebKcUyrQLcvs9MEqnbBfu37ZBEOfQHXocdnGKN(g2PlIAWTNxSS8EV5hbrhH(18MvxPG8gDafkoHLXOKOZTHQALeWjqaJJpJJhJRrghcPaPabq3j8et5IuUeOaLjG0DliJrgp0qzCunLcdUabAsqX4(GdmErgh3BEslJYeZBu2rLQkMPw4M)KUSIYzVrgcCd709fTIOgC7MiQb3WGDuPQIzQfUPhIasbxSi1sHkPEtpOMGTcQ795np0c1WyhHHgqYtFd70frn42Zlww8EV5hbrhH(18MvxPG82gqKvxbtbyDQb7cKKX9bhyCHOEZtAzuMyEJYoQ0vLRmmCZFsxwr5S3idbUHD6(IwrudUDte1GByWoQKXTCLHbghVI4EtpebKcUyrQLcvs9MEqnbBfu37ZBEOfQHXocdnGKN(g2PlIAWTNxSedV3B(rq0rOFnVz1vkiVHQPuyWfiqtckg3hCGXlEZtAzuMyEBH2SkickLBbjjH9M)KUSIYzVrgcCd709fTIOgC7MiQb30dTzvqeukgpKLKewghVI4EtpebKcUyrQLcvs9MEqnbBfu37ZBEOfQHXocdnGKN(g2PlIAWTNxSud37n)ii6i0VM3S6kfK3WJXRZe7tbIZcTzvqeuk3csscRZcnKKOyCmMXXJX1v7mooMXlY44Y4HgkJthqHIJouQfwjrNRkNT5OsunmJJdmEjvghxghFgVotSpfio0lGsTUdfxLK0xKUrHCwOHKefJ7dJVbeq5KYg4MJRgyC8z8efbs6OdLAHvs05QYzBoabrhH(npPLrzI5nk7OsxvUYWWn)jDzfLZEJme4g2P7lAfrn42nrudUHb7Osg3YvggyC8WqCVPhIasbxSi1sHkPEtpOMGTcQ795np0c1WyhHHgqYtFd70frn42ZlwIr37n)ii6i0VM3S6kfK30iJthqHIZkBGtGaghFghpgxJmEIIajD0HsTWkj6Cv5SnhGGOJqNXdnugVotSpfiol0MvbrqPClijjSol0qsIIX9HXXJX1v7moUmoU38KwgLjM3g6OmHfLWn)jDzfLZEJme4g2P7lAfrn42nrudUfI0rzclkbghpme3B6HiGuWflsTuOsQ30dQjyRG6EFEZdTqnm2ryObK803WoDrudU98IL489EZpcIoc9R5nRUsb5T6mX(uG4qVak16ouCvssFr6gfYzHgssumUpmEjgX44Z4BarwDfmfG1PgSlqsghJXbgxiQmo(m(gqaLtkBGBoUyiJ7dJRR2V5jTmktmVPDwI7qXTGKKWEZFsxwr5S3idbUHD6(IwrudUDte1GB4Kzjm(qHXdzjjH9MEicifCXIulfQK6n9GAc2kOU3N38qludJDegAajp9nStxe1GBpVyPq37n)ii6i0VM3S6kfK3QZe7tbId9cOuR7qXvjj9fPBuiNfAijrX4(W4BabuoPSbU54QHBEslJYeZBu2rLUQCLHHB(t6YkkN9gziWnSt3x0kIAWTBIOgCdd2rLmULRmmW44PbCVPhIasbxSi1sHkPEtpOMGTcQ795np0c1WyhHHgqYtFd70frn42ZN3mbqvIIYqikLd5IfXOYN)]] )

    storeDefault( [[SimC Frost: machinegun]], 'actionLists', 20171010.212625, [[di0yyaqisGnjs9jeIWOKkDkPIvrLq1UiLHrsDmrSmsLNHqY0OsuxdHW2OsiFJK04ejPZHqQ1HqenprIUhjO9rLGdssSqsOhsL0ePsOCrQI2OiP(icrAKie1jPQ0nrWojYpfj0sjv9uktLQ0wPQ4RIKyVQ(lvmyKomWIHYJLYKHQlRSzPQptLA0KOtt41uvnBHUnI2nKFdA4IYXPsKLJQNly6sUorTDrLVJqDErvRxKG5tvy)O8tU3BsaYDZeKUYOPMddfrsgLe0ukqZTm6Ml26bYX6kEt)Ide2L0Por1e1QDrAjUiIGO0LQ3SgxKv3UPsRequ4EVuY9EZtealo8R4nRXfz1Tc62DCAnimIdjgfy00mAxgTlJQagTaXHkTEomfgYjtogM2qaS4Wzup8Gr7YOCz0y0uYO6y00mkxgjAozqIhxRjZ5dvmAkzuDPkJ2Hr7WOPzufWOfiouP5gukhxGC7ekiNuBiawC4mANBQGjIIk)niwuuJdkbeDZxeUObki)gcI2ncqCFaCja5UDtcqUBPiwuuJdkbeDt)Ide2L0Por1e130VauM3w4EFDZvLR5Nam3ihQo2ncqCja5U96s6U3BEIayXHFfVznUiRUHj33RjA5DkqeIcA8rceOaJMsgnrJiy00mAbIdvAIwENceHOG2qaS4WVPcMikQ8365Wq5ekUW)U5lcx0afKFdbr7gbiUpaUeGC3Ujbi3TuZHHIrTIl8VB6xCGWUKo1jQMO(M(fGY82c37RBUQCn)eG5g5q1XUraIlbi3TxxIOU3BEIayXHFfVznUiRUvG4qLwqjOQXfi3oHIl8VG2qaS4Wz00mk(WK7714GuaYfTPfkqZpJQqgLiUPcMikQ8365Wq5ekUW)U5lcx0afKFdbr7gbiUpaUeGC3Ujbi3TuZHHIrTIl8pgTBsNB6xCGWUKo1jQMO(M(fGY82c37RBUQCn)eG5g5q1XUraIlbi3TxxYLV3BEIayXHFfVznUiRU1Lr7YOyY99ACb50KZy00m6Cjzrw2W1YgpSCJdqT5a7DkLZzyqKdjGx55mAhg1dpy0cehQ0CdkLJlqUDcfKtQnealoCgTdJMMrvaJ2LrXK771GyrrnoOeqKMCgJMMrbTsKBodnsXcmAkzuDmANBQGjIIk)n(iH8WIleCiwGQXV5lcx0afKFdbr7gbiUpaUeGC3Ujbi3n9JeYdlUqGrtfbQg)M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71LiI79MNiawC4xXBwJlYQByY99ACb50KZy00mQcy0UmkMCFVgelkQXbLaI0KZy00mkOvICZzOrkwGrtjJQJr7WOPzufWODz05sYISSHRLnEy5ghGAZb27ukNZWGihsaVYZz00mAbIdvAUbLYXfi3oHcYj1gcGfhoJ25MkyIOOYFtjK4Oa52blcc1nFr4IgOG8BiiA3iaX9bWLaK72nja5UrKHehfi3mQIrqOUPFXbc7s6uNOAI6B6xakZBlCVVU5QY18taMBKdvh7gbiUeGC3EDjx09EZtealo8R4nRXfz1nm5(EnUGCAYzmAAgvbmAxgftUVxdIff14GsarAYzmAAgf0krU5m0iflWOPKr1XODy00m6Cjzrw2W1YgpSCJdqT5a7DkLZzyqKdjGx55mAAgTaXHkn3Gs54cKBNqb5KAdbWIdNrtZODzu8Hj33RLnEy5ghGAZb27ukNZWGihsaVYZ1KZyup8GrBqyehsmsJpsipS4cbhIfOACn(ibcuGrDbgLOy0o3ubtefv(BkHehfi3oyrqOU5lcx0afKFdbr7gbiUpaUeGC3Ujbi3nImK4Oa5MrvmccfJ2nPZn9loqyxsN6evtuFt)cqzEBH791nxvUMFcWCJCO6y3iaXLaK72RlP69EZtealo8R4nRXfz1nfWOyY99AqSOOghucistoJrtZODz05sYISSHR5hglbheCqJ4EOmc3HyrmYOPz0cehQ065WuyiNm5yyAdbWIdNrtZODz0WkhmisoOvIXtiAhDzngvHmAcJ6HhmAyLdgejh0kX4jeTJlN1yufYOjmAhgTdJ6HhmkxgTGwjiNtbDicgnLmQ7g(nvWerrL)gelkQXb1U5lcx0afKFdbr7gbiUpaUeGC3Ujbi3TuelkQXb1UPFXbc7s6uNOAI6B6xakZBlCVVU5QY18taMBKdvh7gbiUeGC3EDPu9EV5jcGfh(v8M14IS6wbD7ooTgegXHeJcmAAgTlJ2LrvaJwG4qLwphMcd5KjhdtBiawC4mQhEWODzuUmAmAkzuDmAAgLlJenNmiXJR1K58HkgnLmQUuLr7WODy00mAbIdvAUbLYXfi3oHcYj1gcGfhoJMMrXK7714JeYdlUqWHybQgxtoJr7Ctfmruu5VbXIIACqjGOB(IWfnqb53qq0UraI7dGlbi3TBsaYDlfXIIACqjGigTBsNB6xCGWUKo1jQMO(M(fGY82c37RBUQCn)eG5g5q1XUraIlbi3TxxIOV3BEIayXHFfVznUiRUvq3UJtRbHrCiXOaJMMr7YODz05sYISSHR1GOaKxbNgmI70G8XOE4bJIj33RLjIra3b270ZHHstoJr7WOPzum5(EnzKsymVtO4d5UuQjNXOPzu8Hj33RXbPaKlAtluGMFgvHmkrWOPzufWOyY99AqSOOghucistoJr7Ctfmruu5VfeiCoWnmaco9Y8838fHlAGcYVHGODJae3haxcqUB3KaK7Mjq4CGByaqKiWOPwMN)M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71LsuFV38ebWId)kEZACrwDRlJQagftUVxdIff14GsarAYzmAAgLlJenNmiXJRHVErtumAkviJMOMr7WOE4bJ2LrXK771GyrrnoOeqKMCgJMMrvaJIj33R5xeJcKBhsqtPann5mgTZnvWerrL)wphgkNqXf(3nFr4IgOG8BiiA3iaX9bWLaK72nja5ULAomumQvCH)XOD115M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71LssU3BEIayXHFfVznUiRUbALi3CgAKIfyuxqHmQognnJQagTlJwG4qLwphgQqlFPCAdbWIdNrtZOyY99A(fXOa52He0ukqttoJrtZOGwjYnNHgPybg1fuiJQJr7Ctfmruu5VXhjKhwCHGdXcun(nFr4IgOG8BiiA3iaX9bWLaK72nja5UPFKqEyXfcmAQiq14mA3Ko30V4aHDjDQtunr9n9laL5TfU3x3Cv5A(jaZnYHQJDJaexcqUBVUuIU79MNiawC4xXBwJlYQByY99A(fXOa52He0ukqttoJrtZODzufWOZLKfzzdxZpmwcoi4GgX9qzeUdXIyKr9Wdgf0krU5m0iflWOUGczuDmANBQGjIIk)TEomuHw(s5U5lcx0afKFdbr7gbiUpaUeGC3Ujbi3TuZHHk0Yxk3n9loqyxsN6evtuFt)cqzEBH791nxvUMFcWCJCO6y3iaXLaK72RlLqu37npraS4WVI3SgxKv3aTsKBodnsXcmQlOqgv3nvWerrL)M7iOjarhaEoaQTB(IWfnqb53qq0UraI7dGlbi3TBsaYDJincAcqKrvbpha12n9loqyxsN6evtuFt)cqzEBH791nxvUMFcWCJCO6y3iaXLaK72RlL4Y37npraS4WVI3SgxKv3aTsKBodnsXcmQlOqgLOUPcMikQ8365WqfA5lL7MViCrduq(neeTBeG4(a4saYD7MeGC3snhgQqlFPCmA3Ko30V4aHDjDQtunr9n9laL5TfU3x3Cv5A(jaZnYHQJDJaexcqUBVUucrCV38ebWId)kEZACrwDdtUVxZVigfi3oKGMsbAAYz3ubtefv(BqSOOghu7MViCrduq(neeTBeG4(a4saYD7MeGC3srSOOghuJr7M05M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71LsCr37npraS4WVI3SgxKv3kqCOsZnOuoUa52juqoP2qaS4Wz00mAbIdvAKYC8XHYbN13lAIHA51gcGfhoJMMr7YOHvoyqKCqReJNq0o6YAmQcz0eg1dpy0WkhmisoOvIXtiAhxoRXOkKrty0o3ubtefv(B9CyOCcfx4F38fHlAGcYVHGODJae3haxcqUB3KaK7wQ5WqXOwXf(hJ2LO6Ct)Ide2L0Por1e130VauM3w4EFDZvLR5Nam3ihQo2ncqCja5U96sjQEV38ebWId)kEZACrwDRlJwG4qLMsih5a7DiwGQX1gcGfhoJ6HhmAbIdvAkLrUhxGC7WLrZH4bYGiTHayXHZODy00mAxgnSYbdIKdALy8eI2rxwJrviJMWOE4bJgw5GbrYbTsmEcr74YzngvHmAcJ25MkyIOOYFRNddLtO4c)7MViCrduq(neeTBeG4(a4saYD7MeGC3snhgkg1kUW)y0UUCNB6xCGWUKo1jQMO(M(fGY82c37RBUQCn)eG5g5q1XUraIlbi3TxxkjvV3BEIayXHFfVznUiRUvq3UJtRbHrCiXOaJMMr7YOkGrXK771ukJCpUa52HlJMdXdKbrAYzmAAgLlJwqReKZPGoefJ6cmQ7goJ6IZO6y00mkxgjAozqIhxRjZ5dvmAkzuDebJ25MkyIOOYFtPmY94cKBhUmAoepqgeDZxeUObki)gcI2ncqCFaCja5UDtcqUBezzK7Xfi3mQEz0y0uzGmi6M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71Lsi679MNiawC4xXBQGjIIk)niwuuJdQDZxeUObki)gcI2ncqCFaCja5UDtcqUBPiwuuJdQXOD115M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71L0P(EV5jcGfh(v8MkyIOOYFZDe0eGOdapha12nFr4IgOG8BiiA3iaX9bWLaK72nja5UrKgbnbiYOQGNdGAJr7M05M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71L0LCV38ebWId)kEZACrwDtbmkMCFVMszK7Xfi3oCz0CiEGmisto7MkyIOOYFtjKJCG9oelq1438fHlAGcYVHGODJae3haxcqUB3KaK7grgYrmkSNrtfbQg)M(fhiSlPtDIQjQVPFbOmVTW9(6MRkxZpbyUrouDSBeG4saYD71L0P7EV5jcGfh(v8MkyIOOYFRNddLtO4c)7MViCrduq(neeTBeG4(a4saYD7MeGC3snhgkg1kUW)y0UerNB6xCGWUKo1jQMO(M(fGY82c37RBUQCn)eG5g5q1XUraIlbi3TxxshrDV38ebWId)kEZACrwDRGUDhNwdcJ4qIrHBQGjIIk)TrMbjEChUmAoepqgeDZxeUObki)gcI2ncqCFaCja5UDtcqUBEsMbjECgvVmAmAQmqgeDt)Ide2L0Por1e130VauM3w4EFDZvLR5Nam3ihQo2ncqCja5U961nlBnbiksbqjGOlPJisE9d]] )

    storeDefault( [[SimC Frost: CDs]], 'actionLists', 20171010.212625, [[duKSqaqikswefP0MarJII4uevTlszyG0XuKLjrEgiOPrKKRruPTjG03eGXjG4CejvToII5bcCpIk2hrIdIewirQhIKAIGqCrjKnkGAKuKQoPeyMGqYnbv7Kq)KiPYqbHAPc0tPAQuuxLIuyRsqFLiP4TejLUliKAVQ(lPAWqDyPwms9yfMSKUmQnlOpdkJMionjVgjz2u62eSBi)w0WvuhNIu0YbEUqtxPRtHTlH67irNNO06PivMVe1(r8NU57ITaF3vcutWbgKXvgcMAis8oeHdBd7EPVhKTCh5lwc6uatqHgOAtbQCHWsbYDFauZ797umwvII38fNU57fHAAlxV039bqnV3bgi1qFoPKbAvounulblf5qWLGsWqsWMIG32YOvJgW9krpd1Jkuf0WYyRXOM2Y17uqRSQv27ny0iwFtaGr79cqv1O3eChLi(o8SwydeBb((DXwGVtby0iMGnNaaJ27bzl3r(ILGofWe07b5yAagC8M)ENAj8Gk4zXSaJ2tFhEwfBb((3lw6MVxeQPTC9sF3ha18EVMRgnG7vIEgQhvOkOHLXwBvdQuiyemKemWaPg6ZjLmqRYHQHAjyPihcwUqjyijyGbIjyiGGlDNcALvTYEVbJgX6BcamAVxaQQg9MG7OeX3HN1cBGylW3Vl2c8DkaJgXeS5eay0sWMmj)9GSL7iFXsqNcyc69GCmnadoEZFVtTeEqf8SywGr7PVdpRITaF)7fHWB(ErOM2Y1l9DFauZ79nHbZYAJmT1KsuKGHKGnHGPncd1MvwBd0Zq9qqgxnJzcw(7uqRSQv2702mR6HgazVxaQQg9MG7OeX3HN1cBGylW3Vl2c8DPTzwj4aBaK9Eq2YDKVyjOtbmb9EqoMgGbhV5V3PwcpOcEwmlWO903HNvXwGV)9Is1nFViutB56L(UpaQ59(MWGzzTrM2AsjksWqsWMqW0gHHAZkRTb6zOEiiJRMXmbl)DkOvw1k7DAgezavkeS7fGQQrVj4okr8D4zTWgi2c897ITaFxAgezavkeS7bzl3r(ILGofWe07b5yAagC8M)ENAj8Gk4zXSaJ2tFhEwfBb((3lk3B(ErOM2Y1l9DkOvw1k7DJiRRwwiEVauvn6nb3rjIVdpRf2aXwGVFxSf47MgrMGlyzH49GSL7iFXsqNcyc69GCmnadoEZFVtTeEqf8SywGr7PVdpRITaF)7fd0B(ErOM2Y1l9DFauZ7DGbIJARsG13uxUemeqWqibdjbBcbBkcUMRgnG7vIEgQhvOkOHLXwBvdQuiyeC5YemWaPg6ZjLmqByaamAjyPqWbkucw(7uqRSQv27vqBatYQNH6X0WgVtTeEqf8SywGr7PVdpRf2aXwGVFxSf47LhHHnecHYL5YME1YcYmjvqdeObImYiJmYiJmYmnbvMsYTKmYiJmYitzjsTqeqBatYsWzib7PHncrxwszWDkaWI3rTalNkOnGjz1Zq9yAyJ3dYwUJ8flbDkGjO3dYX0am44n)9EbOQA0BcUJseFhEwfBb((3lgWnFViutB56L(UpaQ59(MWGzzT5CvjksWqsWMqW0gHHAZkRTb6zOEiiJRMXmbdjbBcbxZvJgW9krpd1Jkuf0WYyRTQbvkemcUCzcM2imulPTQLb9QsKMXmbxUmbVTLrRMedemgOqW0bgiwNsUNtKgJAAlxjy5jy5VtbTYQwzVpNRkr3lavvJEtWDuI47WZAHnqSf473fBb(oeNRkr3dYwUJ8flbDkGjO3dYX0am44n)9o1s4bvWZIzbgTN(o8Sk2c89VxmqU57fHAAlxV039bqnV332YOvlPTQLb9QsKgJAAlxjyijyti4rM2AsjslPTQLb9QsKgGfAfksWsHGlbLGlxMGhzARjLiTK2Qwg0RkrAawOvOibdbe8eucUCzc2ue82wgTAQbp6zng10wUsWYFNcALvTYEFwzTnqpd1dbzCVxaQQg9MG7OeX3HN1cBGylW3Vl2c8DiwzTnGGZqcoWGmU3dYwUJ8flbDkGjO3dYX0am44n)9o1s4bvWZIzbgTN(o8Sk2c89VxuQ)MVxeQPTC9sF3ha18EFBlJwnAa3Re9mupQqvqdlJTgJAAlxjyij4rM2AsjsJgW9krpd1Jkuf0WYyRb4UklbdjbdmqQH(Csjd0ggaaJwcwkeSCHENcALvTYEFwzTnqpd1dbzCVxaQQg9MG7OeX3HN1cBGylW3Vl2c8DiwzTnGGZqcoWGmUeSjtYFpiB5oYxSe0PaMGEpihtdWGJ3837ulHhubplMfy0E67WZQylW3)EXjO389IqnTLRx67(aOM37BBz0Qrd4ELONH6rfQcAyzS1yutB5kbdjbpY0wtkrA0aUxj6zOEuHQGgwgBnal0kuKGLcblvqVtbTYQwzVpRS2gONH6HGmU3lavvJEtWDuI47WZAHnqSf473fBb(oeRS2gqWzibhyqgxc2KsYFpiB5oYxSe0PaMGEpihtdWGJ3837ulHhubplMfy0E67WZQylW3)EXPPB(ErOM2Y1l9DFauZ79TTmA1KyGGXafcMoWaX6uY9CI0yutB56DkOvw1k79zL12a9mupeKX9EbOQA0BcUJseFhEwlSbITaF)UylW3HyL12acodj4adY4sWMaHYFpiB5oYxSe0PaMGEpihtdWGJ3837ulHhubplMfy0E67WZQylW3)EXPs389IqnTLRx67(aOM37BcdML1gzARjLOibdjbBcbtBegQnRS2gONH6HGmUAgZeS83PGwzvRS3PbCVs0Zq9OcvbnSm23lavvJEtWDuI47WZAHnqSf473fBb(U0aUxjeCgsWUcvbnSm23dYwUJ8flbDkGjO3dYX0am44n)9o1s4bvWZIzbgTN(o8Sk2c89VxCccV57fHAAlxV039bqnV3zttd18mx1gPTQlHBWsWqsWMqWMqW0gHHAJ0w1LWny1IBpOIGLICi4jOemKeSPiyAJWqTK2Qwg0RkrAgZeS8eC5Ye82ay8QTkbwFt9QIjyiqoemSrLGL)of0kRAL9(OTw9ESQePBvX9o1s4bvWZIzbgTN(o8SwydeBb((DXwGVtDBTemfJvLicgIsf37uaGfVJAbwoMwxjqnbhyqgxzi4rAReSeUbRP9Eq2YDKVyjOtbmb9EqoMgGbhV5V3lavvJEtWDuI47WZQylW3DLa1eCGbzCLHGhPTsWs4gSFV4KuDZ3lc10wUEPV7dGAEVVjmywwBKPTMuIIemKeSjemWaXeSuKdbprWqsWadKAOpNuYaTHbaWOLGLICi4sqjyijytiytrWBBz0QfcsthJ0NnSrwJrnTLReC5YemWaXemeqWLi4YLjyAJWqTzL12a9mupeKXvdWcTcfjyiqoe8ujcwEcgsc2ec2ue82wgTAW6vcduiy6XnbcAmQPTCLGlxMGnfbpY0wtkrAawibr2YXOoLk0Yana3vzjy5jyijytiyAJWqTzL12a9mupeKXvZyMGlxMGnfbVTLrRMAWJEwJrnTLReS8eS83PGwzvRS3tARAzqVQeDVauvn6nb3rjIVdpRf2aXwGVFxSf47sD0w1YGEvj6Eq2YDKVyjOtbmb9EqoMgGbhV5V3PwcpOcEwmlWO903HNvXwGV)9ItY9MVxeQPTC9sF3ha18EFtyWSS2itBnPefjyijytiytrW0gHHAsmqWyGcbthyGyDk5EorAgZemKemWaXrTvjW6BQxIGLcbdBujyijyGbsn0NtkzG2Waay0sWqablvqjy5VtbTYQwzVlXabJbkemDGbI1PK75eDVauvn6nb3rjIVdpRf2aXwGVFxSf47MEdemgOqWi4GgiMGLA4Eor3dYwUJ8flbDkGjO3dYX0am44n)9o1s4bvWZIzbgTN(o8Sk2c89VFV7Z8q1wLPRxvIUyj5o99h]] )

    storeDefault( [[SimC Frost: cold heart]], 'actionLists', 20171010.212625, [[dKd)eaGEQQQ2Ki1UqyBevTpvLMTKMVer3erDBu1orL9cTBs2VkJIQWWuL(TIhJ0GvA4QQoivjNIQuhtehwQfsvLLkblgLwoPEOe6PclJOSoQQIjsvvAQuvMmOMoWfLO8nIkpdrQRtKnsvvzRsuTzrTDjs3JQOttyAisMhIOVlr4VGmAumoeHoPQWRfjxdrW5vv8zvrpNkxMYyc6ddUM3Wie8fV1)0Jd4p3sNk8TmwRby4VwULQa0pmkyvRDgYj7nrUK3x5jsKNeiTmseJGQf)amWWlkqmkh6d5sqFyuMQzRgm6hgbvl(byWkLZe0PcdXyTgq4ann1TEERS3BtFlRuotiPyM6hihqBQNagcP)BtFlDMk8ucfXVOwBn0KHY6Xbi0gFluUB)ER8y4fROkaFWGY0cLdAYqcQHXdfSG2GrJHAuggKh4YBnxZByGbxZByuKPfk3Tt(2hudJcw1ANHCYEtKl5fJcMBK0uZH(qagfzmAkYtPgVPailgKhyUM3WabiNm0hgLPA2QbJ(Hrq1IFagSs5mXVOwBn0KHY6XbiK(Vn9TSs5mXVOwBn0KHY6Xbi0gFluUBj5TpPW3M(wpULvkNjOtfgIXAnGWbAAQB)65Tjj3wYsERh3YkLZe0PcdXyTgq4ann1TF982K3BtFRZaqSJsYraeMw2leP(P3(923B9(wVXWlwrva(GbLPfkh0KHeudJhkybTbJgd1OmmipWL3AUM3WadUM3WOitluUBN8TpO2TEK4ngfSQ1od5K9MixYlgfm3iPPMd9HamkYy0uKNsnEtbqwmipWCnVHbcqosJ(WOmvZwny0pmcQw8dWGvkNjKumt9dKdOn1tadH0)TPVLvkNjKumt9dKdOn1tadH24BHYDljV9jf(203YkLZe0PcdXyTgq4ann1TFVnr(BtFlDMk8ucfXVOwBn0KHY6Xbi0gFluUB)ER8y4fROkaFWGY0cLdAYqcQHXdfSG2GrJHAuggKh4YBnxZByGbxZByuKPfk3Tt(2hu7wpK5ngfSQ1od5K9MixYlgfm3iPPMd9HamkYy0uKNsnEtbqwmipWCnVHbcqosH(WOmvZwny0pmcQw8dWGvkNjOtfgIXAnGWbAAQB)65TK6203cA9tdqae8geyGGf2TK0ZBFsHXWlwrva(GbLPfkh0KHeudJhkybTbJgd1OmmipWL3AUM3WadUM3WOitluUBN8TpO2TEqAVXOGvT2ziNS3e5sEXOG5gjn1COpeGrrgJMI8uQXBkaYIb5bMR5nmqacWi(nQORc)VbIrHCYiHeeGia]] )

    storeDefault( [[SimC Frost: obliteration]], 'actionLists', 20171010.212625, [[d0JohaGEIc2ePODPO2gHKSpfWPHmBkMVc0nvKhRKVPk5WQStv1Ef7gv7xsJIOudtv8BuoVQuxgmyjgorCqOKtruYXiv)LqTqfYsjWIvQLtYdHs9uKLrjwhHumrcjAQe0KHQPl1fjeFMu6zus66uQnsjXwjQSzOy7kuJJOiFLqctJqsnpcP0iPKYTPQrtK(oPWjjQ6qus11ik09ikQNtLFsivVwbD0JWqIWVTbWZoeTuijDOqIsaZzB6mkKaWaNdY3YJ(l9h9Nzl6pVEKPqKeyHodsgUgX45Brg1dH1QrmUlcZxpcdjc)2gapJcrlfsshQpdW7zTxlfuiUwXUMP8Za)2gapewBKb1VdPapt5ad4CI1aXBqfsEooADntfIZ4qOjgUCN6FEiuO)5Hqcapt5ad4C1IOaXBqfsayGZb5B5r)L(tibGJzRwGlcthcBPWA4eBm4bENDOjg()8qO05Bjcdjc)2gapJcrlfsshABJbZ8qKXG4Af7VLuehMTLulAwl3QrJbXah8iWvldul6HWAJmO(DimkMRDR3TuiK8CC06AMkeNXHqtmC5o1)8qOq)ZdHSII5A36DlfcjamW5G8T8O)s)jKaWXSvlWfHPdHTuynCIng8aVZo0ed)FEiu68TAegse(TnaEgfIwkKKo02gdM5HiJbX1k2FlPiomBlPwgCWAr21YTA0yqmWbpcC1YaYCTy1ArZAX61Y2gdMzfYdZ2sQfzfcRnYG63HyBdQb11qi554O11mvioJdHMy4YDQ)5HqH(Nhcj6BdQb11qibGbohKVLh9x6pHeaoMTAbUimDiSLcRHtSXGh4D2HMy4)ZdHsNVOocdjc)2gapJcrlfsshABJbZSc5HzBj1IM1YTA0yqmWbpcC1Ya1IEiS2idQFhsktddIRv82CUoK8CC06AMkeNXHqtmC5o1)8qOq)ZdHSgtddIRTwgzoxhsayGZb5B5r)L(tibGJzRwGlcthcBPWA4eBm4bENDOjg()8qO05lJryir432a4zuiAPqs6qwVw22yWmRqEy2wsTOzTCRgngedCWJaxTmqTyPw0Swu2COwgOwSATOzT0Nb49mgfaYaIRvmgM2zGFBdGxlAwl9zaEpR9APGcX1k21mLFg432a4HWAJmO(DiPmnmiUwXBZ56qYZXrRRzQqCghcnXWL7u)ZdHc9ppeYAmnmiU2AzK5CDTiBDzfsayGZb5B5r)L(tibGJzRwGlcthcBPWA4eBm4bENDOjg()8qO05lQIWqIWVTbWZOq0sHK0HSETSTXGzwH8WSTKAzWbRfLnhCZnYdIBMy9AzazUw0UWRLbhSwu2C0sSeMgGAghWGwOUweT1ILNqyTrgu)oegfZ1IDTcnecjphhTUMPcXzCi0edxUt9ppek0)8qiROyUUwOwHgcHeag4Cq(wE0FP)esa4y2Qf4IW0HWwkSgoXgdEG3zhAIH)ppekD(VIWqIWVTbWZOq0sHK0H22yWmRqEy2wsiS2idQFhsktddIRv82CUoK8CC06AMkeNXHqtmC5o1)8qOq)ZdHSgtddIRTwgzoxxlY2IScjamW5G8T8O)s)jKaWXSvlWfHPdHTuynCIng8aVZo0ed)FEiu68LPimKi8BBa8mkewBKb1VdX2gudQRHqYZXrRRzQqCghcnXWL7u)ZdHc9ppes03gudQRHAr26YkKaWaNdY3YJ(l9NqcahZwTaxeMoe2sH1Wj2yWd8o7qtm8)5HqPth6FEieH8yxlwrXCTOPwyBdQb11igpDca]] )

    storeDefault( [[SimC Frost: standard]], 'actionLists', 20171010.212625, [[di06taqikf2eLQ(eQKQgfQItHQ0QeKc7IQmmuXXKOLjbpJevnnkP4Acs2gQeY3qLACOskNdvcwhQeQ5rIY9OKQ9HkjhevLfIQQhsjzIOsQCrsKnsPOpkifnsbP0jPu6Msv7eP(jjQSus4PetLsSvbXxfKQ9Q8xbgmPomWIrYJL0KLYLvTzi5ZcQrtsDAuEnjz2cDBi2nIFdA4sLJtjLwoupNktx01PQ2oKY3HuDEj06rLO5tPY(P4voltuIaOIVnQjsfZ6Yjt46okGFmh)tu84bUp6cCk5UKtjhVcLC4MdxBI09kdezCjizqYOleQYj8vtgK4MLrxoltuIaOIVn(NivmRlNKG4jPhRwmibriX5DcGk(MrBVrt5JcLhRwmibriX5HpcGrCgTYSUrhU2MWhflYYItqHHUmWLyMQpXwsJvbjepHajFspSfcatdq(Kj0aKpXMyOlnAjXmvFIIhpW9rxGtj3LCMO4oOpUE3SSCIvQFvvpeTJCsoQj9Wgna5two6cZYeLiaQ4BJ)jsfZ6YjjiEs65udY8ygjCGlXmv35DcGk(MrBVr3oLpkuEyaxcXS69CjOQYOTUrhkJ2EJMYhfkVWGu9Xms4axcXiEUeuvz0kZOly02B02WOP8rHYdZqUNF3e(OyrwwCckm0LbUeZu9j2sASkiH4jei5t6HTqayAaYNmHgG8j2edDPrljMP6gnpL8orXJh4(OlWPK7sotuCh0hxVBwwoXk1VQQhI2rojh1KEyJgG8jlhTYpltuIaOIVn(NivmRlNWJrt5JcLhMHCp)oJ2EJ(wRpRR7nVUJDhTJbK6dGOcs1p4uqsacaNfXgnVgTD2z0jiEs6fgKQpMrch4sigX7eav8Tj8rXISS4e8rGy3J35cqNrYJNylPXQGeINqGKpPh2cbGPbiFYeAaYNO4iqS7X7CgDOZi5Xtu84bUp6cCk5UKZef3b9X17MLLtSs9RQ6HODKtYrnPh2ObiFYYrBnZYeLiaQ4BJ)jsfZ6Yj8y03A9zDDV5Pcgtgg4cihDuqFslaDwmA02B0jiEs6Hcd5Ytc68JU7DcGk(MrBVr7Egqbj(oVKDCjxiOqx1OTUrxA08A02zNrJ9j35LmKhKWaRXOvMrhU2mA7nAkFuO8u7tcFmJeoa7tEa6h0bjE(Dt4JIfzzXjqQilpgKFITKgRcsiEcbs(KEyleaMgG8jtObiFIYrfz5XG8tu84bUp6cCk5UKZef3b9X17MLLtSs9RQ6HODKtYrnPh2ObiFYYrhQzzIseav8TX)ePIzD5eEmABy0jiEs65udY8ygjCGlXmv35DcGk(MrBNDgD7u(Oq5HbCjeZQ3ZLGQkJwzgDOmAEnA7nASpHvd6GOFSx7OyvwA0kZOl5mHpkwKLfNGcdDzGlXmvFITKgRcsiEcbs(KEyleaMgG8jtObiFInXqxA0sIzQUrZtbENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJMlAwMOebqfFB8prQywxoHYhfkpmd5E(Dt4JIfzzXjQHOhzKWburGlNylPXQGeINqGKpPh2cbGPbiFYeAaYNeAHOhzKWgn)rGlNO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJM7zzIseav8TX)ePIzD5eEm6BT(SUU38ubJjddCbKJokOpPfGolgnA7n6eepj9qHHC5jbD(r39obqfFZOT3ODpdOGeFNxYoUKleuORA0w3OlnAEnA7SZOX(K78sgYdsyqOmALz0HRTj8rXISS4eivKLhdYpXwsJvbjepHajFspSfcatdq(Kj0aKpr5OIS8yqEJMNsENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJMRnltuIaOIVn(NivmRlNKWWHJ3RcHXgeDIZOT3O5XO5XOV16Z66EZRcjoioDbvySfuH4B02zNrt5JcLxhlgb4aiQauyOl987mAEnA7nAkFuO88jQHXIbUeFs4uTNFNrBVr3oLpkuEyaxcXS69CjOQYOTUrhkJM3j8rXISS4ehJ0WGWqhWfGYhxCITKgRcsiEcbs(KEyleaMgG8jtObiFIWinmim0b46DgTn9XfNO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJMlmltuIaOIVn(NivmRlNG9jSAqhe9J9AhfRYsJwzgDjhJ2EJ2ggnLpkuEQ9jHpMrchG9jpa9d6Gep)Uj8rXISS4euyOldCjMP6tSL0yvqcXtiqYN0dBHaW0aKpzcna5tSjg6sJwsmt1nAEuEENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJUKZSmrjcGk(24FIuXSUCcLpkuEQyXiJeoabuvZi3ZVZOT3O5XOTHrFR1N119MNkymzyGlGC0rb9jTa0zXOrBNDgnOMm0EWjhHDNrZvw3Oly08oHpkwKLfNGcdDPRwmv)j2sASkiH4jei5t6HTqayAaYNmHgG8j2edDPRwmv)jkE8a3hDboLCxYzII7G(46DZYYjwP(vv9q0oYj5OM0dB0aKpz5OllNLjkrauX3g)tKkM1LtO8rHYtflgzKWbiGQAg5E(Dt4JIfzzXjqQilpgKFITKgRcsiEcbs(KEyleaMgG8jtObiFIYrfz5XG8gnpf4DIIhpW9rxGtj3LCMO4oOpUE3SSCIvQFvvpeTJCsoQj9Wgna5two6YcZYeLiaQ4BJ)jsfZ6YjyFcRg0br)yV2rXQS0OvMrxGZe(OyrwwCckm0LbUeZu9j2sASkiH4jei5t6HTqayAaYNmHgG8j2edDPrljMP6gnpwdVtu84bUp6cCk5UKZef3b9X17MLLtSs9RQ6HODKtYrnPh2ObiFYYrxQ8ZYeLiaQ4BJ)jsfZ6YjGAYq7bNCe2DgnxzDJUWe(OyrwwCc(iqS7X7CbOZi5XtSL0yvqcXtiqYN0dBHaW0aKpzcna5tuCei294DoJo0zK8yJMNsENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJU0AMLjkrauX3g)tKkM1Lta1KH2do5iS7mAUY6gDHj8rXISS4KWrqLbIbGgAas9tSL0yvqcXtiqYN0dBHaW0aKpzcna5tcnJGkdenA(AObi1prXJh4(OlWPK7sotuCh0hxVBwwoXk1VQQhI2rojh1KEyJgG8jlhDzOMLjkrauX3g)tKkM1Lta1KH2do5iS7mAUY6gTYpHpkwKLfNGcdDPRwmv)j2sASkiH4jei5t6HTqayAaYNmHgG8j2edDPRwmvFJMNsENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJUKlAwMOebqfFB8prQywxoXggDcINKEHbP6JzKWbUeIr8obqfFZOTZoJUcHXgeDIh(iqS7X7CbOZi5XE4JayeNrZvgnpgD4AZOdnm6cgnVt4JIfzzXjqQilpgKFITKgRcsiEcbs(KEyleaMgG8jtObiFIYrfz5XG8gnpkpVtu84bUp6cCk5UKZef3b9X17MLLtSs9RQ6HODKtYrnPh2ObiFYYrxY9SmrjcGk(24FIuXSUCInmAkFuO8u7tcFmJeoa7tEa6h0bjE(DgT9gnpgn2NCNxYqEqcdky0CLrhU2mA7SZOTHrNG4jPhkmKlpjOZp6U3jaQ4BgnVt4JIfzzXjQHysaeva6msE8eBjnwfKq8ecK8j9Wwiamna5tMqdq(KqletmAikJo0zK84jkE8a3hDboLCxYzII7G(46DZYYjwP(vv9q0oYj5OM0dB0aKpz5Ol5AZYeLiaQ4BJ)jsfZ6Yj2WO5XOX(ewnOdI(XEvFm(K0OvMrhkogT9gDcINKEqQilpgKmiX7eav8nJ2EJUcHXgeDIhKkYYJbjds8WhbWioJwzw3OdxBgnVt4JIfzzXjOWqxg4smt1NylPXQGeINqGKpPh2cbGPbiFYeAaYNytm0LgTKyMQB08ekENO4XdCF0f4uYDjNjkUd6JR3nllNyL6xv1dr7iNKJAspSrdq(KLJUKlmltuIaOIVn(NivmRlNydJobXtsVWGu9Xms4axcXiENaOIVz02zNrNG4jPhRwmibriX5DcGk(2e(OyrwwCcKkYYJb5NylPXQGeINqGKpPh2cbGPbiFYeAaYNOCurwEmiVrZJ1W7efpEG7JUaNsUl5mrXDqFC9Uzz5eRu)QQEiAh5KCut6HnAaYNSC0f4mltuIaOIVn(NivmRlNKWWHJ3RcHXgeDIZOT3O5XOTHrNG4jPhf(GuDaevGJrAyqyOd4DcGk(MrBNDgDcWHF6LmKhKWGg7gTYm6kegBq0jEu4ds1bqubogPHbHHoGh(iagXz08oHpkwKLfNCKoi6hhG9jpa9d6GKj2sASkiH4jei5t6HTqayAaYNmHgG8jkH0br)yJwHp5gDOFqhKmrXJh4(OlWPK7sotuCh0hxVBwwoXk1VQQhI2rojh1KEyJgG8jlxoHgG8jcdXkJ2MyOl5InAxcinaUTCda]] )

    storeDefault( [[SimC Frost: bos pooling]], 'actionLists', 20171010.212625, [[diuDtaqiqsBIc8jkPeJcu5uGuRcKq7IKggj6yGyzsjptqY0eiUgLuTnuvPVrbnobs6CusPwhLusZdvvDpqI2hfQdsjzHuipKsLjsjf1fPu1gfK6JusrgPajoPG4MOk7Ku9tbsTukXtPAQcyRcuFLskSxK)srdgYHvSyu5XsmzjDzvBgu(mPy0KWPj61ukZwOBlv7gLFR0WjLooiblh45eMUORlfBhvLVlL68GQwpQQy(cQ9d1eeka52ZgU4Reh5Ebi1MKtU18HnnXKmIClp(rCsVLsigcrjeLQTGO0qLbvYDTViNOKFMuUmsVL1HqUvLuUmbfG0Hqbi3E2WfFLmICVaKAtYZjEwQQzsfhizAmf5c6QNnCXxj3kozuMWto49fiE8cHzBjlpG8qyvzzYfqoBzNCEBn4bOp9to56t)KB59fiE8cbgznKS8aYT84hXj9wkHyieLKB5ITbuUGcqj52P4fB8w(E)SK4iN3w1N(jNssVffGC7zdx8vYiY9cqQnjNRbgmvGSF1gTyKbyeOHDHAk73mxZGGr8hJGdJ0uQyeueJAHrqtUvCYOmHNCfB7OKPXKloIK8qyvzzYfqoBzNCEBn4bOp9to56t)Khu22rjtdgzuCej5wE8J4KElLqmeIsYTCX2akxqbOKC7u8InElFVFwsCKZBR6t)KtjPhkka52ZgU4RKrK7fGuBsoOHDHAk73mxt(fJ4pgPPuXidWiOIr5eplv1mPIdKmnMICbD1ZgU4RKBfNmkt4jF5IY8Gjp5HWQYYKlGC2Yo582AWdqF6NCY1N(jpO5IY8Gjp5wE8J4KElLqmeIsYTCX2akxqbOKC7u8InElFVFwsCKZBR6t)KtjPheka52ZgU4RKrK7fGuBsoOHDHAk73mxZGGr8hJ0uQyKbyeCyuz3yDBZu5aFsfMlmtHKvbJMvmQG3hjtGrgJrkXOWHXiqdtwm1UTpqTEyYImXiJHsmkukXiOj3kozuMWt(YfL5btEYdHvLLjxa5SLDY5T1GhG(0p5KRp9tEqZfL5btEmcoiqtULh)ioP3sjedHOKClxSnGYfuakj3ofVyJ3Y37NLeh582Q(0p5us6wNcqU9SHl(kze5Ebi1MKdAyYIP2T9bQ1dtwKjgXFmY6yKbyK4Pj3YAeQP8aiwBZGOTGrgJrkXidWOYUX62MPYb(KkmxyMcjRcgnRyubVpsMaJmgJuIrgGrWHrqfJYjEwQkumzEGKPXuKaPTlupB4IVIrHdJr1Z1adMky4NfilxvKtXggXFmY6yu4Wyuz3yDBZu5aFsfMlmtHKvbJMvmQG3hjtGrgJr8lgbn5wXjJYeEYHbwrAksG02jpewvwMCbKZw2jN3wdEa6t)KtU(0p5HgSIeJ8eiTDYT84hXj9wkHyieLKB5ITbuUGcqj52P4fB8w(E)SK4iN3w1N(jNssNFPaKBpB4IVsgrUxasTj5CnWGPcK9R2OfJmaJouOrQv7RQApqC(oyyLBUWmtf38ClZSpGeEa5wXjJYeEYbVVaXJximBlz5bKhcRkltUaYzl7KZBRbpa9PFYjxF6NClVVaXJxiWiRHKLhGrWbbAYT84hXj9wkHyieLKB5ITbuUGcqj52P4fB8w(E)SK4iN3w1N(jNss3qka52ZgU4RKrK7fGuBsoxdmyQaz)QnAXidWi4WiUgyWubVVaXJximBlz5bQnAXOWHXOYUX62MPcEFbIhVqy2wYYdubVpsMaJmgJ0uQyu4WyeCyeuXOdfAKA1(QQ2deNVdgw5MlmZuXnp3Ym7diHhGrgGrqfJYjEwQQzsfhizAmf5c6QNnCXxXiOXiOj3kozuMWtUITDuY0yYfhrsEiSQSm5ciNTStoVTg8a0N(jNC9PFYdkB7OKPbJmkoIeJGdc0KB5XpIt6TucXqikj3YfBdOCbfGsYTtXl24T89(zjXroVTQp9toLKEqLcqU9SHl(kze5Ebi1MKdvmIRbgmvGSF1gTyKbyeuXi4WOCINLQAMuXbsMgtrUGU6zdx8vmYamcQyeCyuz3yDBZubVVaXJximBlz5bQG3hjtGrgJrWHrAkvmckIrTWiOXOWHXiqd7yKXyuqWiOXiOXidWiqd7yKXyuOi3kozuMWt(YfL5btEYdHvLLjxa5SLDY5T1GhG(0p5KRp9tEqZfL5btEmcUwqtULh)ioP3sjedHOKClxSnGYfuakj3ofVyJ3Y37NLeh582Q(0p5us6wBka52ZgU4RKrK7fGuBsEUA0eVAz3yDBZeyKbyeCyeCy0HcnsTAFvTSmXcsHzzJvZYcogfomgX1adMQwzmoaZfMjmWks1gTye0yKbyexdmyQnmfBeEtrcottQqTrlgzagvpxdmyQGHFwGSCvrofByeuIrwhJGMCR4Krzcp5cjRcgnRyeMWAaWtEiSQSm5ciNTStoVTg8a0N(jNC9PFYDjRcgnRySweyuOBaWtULh)ioP3sjedHOKClxSnGYfuakj3ofVyJ3Y37NLeh582Q(0p5us6qusbi3E2WfFLmICVaKAtYbnmzXu72(a16HjlYeJ4pgfkLyKbyeCyeuXOCINLQcftMhizAmfjqA7c1ZgU4Ryu4Wyu9CnWGPcg(zbYYvf5uSHr8hJSogfomgv2nw32mvoWNuH5cZuizvWOzfJk49rYeyKXyeOHDHAk73mxZGGrqtUvCYOmHNCyGvKMIeiTDYdHvLLjxa5SLDY5T1GhG(0p5KRp9tEObRiXipbsBhJGdc0KB5XpIt6TucXqikj3YfBdOCbfGsYTtXl24T89(zjXroVTQp9toLKoeiuaYTNnCXxjJi3laP2KCUgyWuTjJrjtJzFkkKSR2OfJmaJGdJGkgDOqJuR2xvTTXucgHj7THTnSQzBzmIrHdJrtjL8DZZExEbgzmuIrTWiOj3kozuMWtomWksrb(uXjpewvwMCbKZw2jN3wdEa6t)KtU(0p5HgSIuuGpvCYT84hXj9wkHyieLKB5ITbuUGcqj52P4fB8w(E)SK4iN3w1N(jNsshslka52ZgU4RKrK7fGuBs(usjF38S3LxGrgdLyulYTItgLj8KRjof5enNkFdRCYdHvLLjxa5SLDY5T1GhG(0p5KRp9tU1uCkYjIrwv5ByLtULh)ioP3sjedHOKClxSnGYfuakj3ofVyJ3Y37NLeh582Q(0p5us6qcffGC7zdx8vYiY9cqQnjFkPKVBE27YlWiJHsmQf5wXjJYeEYbVVaXJximBlz5bKhcRkltUaYzl7KZBRbpa9PFYjxF6NClVVaXJxiWiRHKLhGrW1cAYT84hXj9wkHyieLKB5ITbuUGcqj52P4fB8w(E)SK4iN3w1N(jNsshsqOaKBpB4IVsgrUxasTj5tjL8DZZExEbgzmuIrHICR4Krzcp5WaRiff4tfN8qyvzzYfqoBzNCEBn4bOp9to56t)KhAWksrb(uXXi4Gan5wE8J4KElLqmeIsYTCX2akxqbOKC7u8InElFVFwsCKZBR6t)KtjPdX6uaYTNnCXxjJi3laP2KC4WOYUX62MPcEFbIhVqy2wYYdubVpsMaJ4pgbhgPPuXiOig1cJGgJchgJ4AGbtvZKkoqY0ykYf0vf5uSHrqjgbrjgbngzagv2nw32mvoWNuH5cZuizvWOzfJk49rYeyKXyeOHDHAk73mxZGGrgGr5eplv1mPIdKmnMICbD1ZgU4RyKbyeCyeuXOCINLQcftMhizAmfjqA7c1ZgU4Ryu4Wyu9CnWGPcg(zbYYvf5uSHr8hJSogfomgv2nw32mvoWNuH5cZuizvWOzfJk49rYeyKXye)IrqtUvCYOmHNCyGvKMIeiTDYdHvLLjxa5SLDY5T1GhG(0p5KRp9tEObRiXipbsBhJGRf0KB5XpIt6TucXqikj3YfBdOCbfGsYTtXl24T89(zjXroVTQp9toLKoe(LcqU9SHl(kze5Ebi1MKdvmIRbgmvGSF1gTyKbyeCyeuXOCINLQAMuXbsMgtrUGU6zdx8vmkCymQSBSUTzQG3xG4XleMTLS8avW7JKjWiJXinLkgbn5wXjJYeEYxUOmpyYtEiSQSm5ciNTStoVTg8a0N(jNC9PFYdAUOmpyYJrWfkOj3YJFeN0BPeIHqusULl2gq5ckaLKBNIxSXB579ZsIJCEBvF6NCkjDigsbi3E2WfFLmICVaKAtYl7gRBBMkh4tQWCHzkKSky0SIrf8(izcmYymc0WUqnL9BMRzqWidWi4WiOIr5eplvfkMmpqY0yksG02fQNnCXxXOWHXO65AGbtfm8ZcKLRkYPydJ4pgzDmkCymQSBSUTzQCGpPcZfMPqYQGrZkgvW7JKjWiJXi(fJGMCR4Krzcp5WaRinfjqA7KhcRkltUaYzl7KZBRbpa9PFYjxF6N8qdwrIrEcK2ogbxOGMClp(rCsVLsigcrj5wUyBaLlOausUDkEXgVLV3pljoY5Tv9PFYPKsY1N(j3LD7WOqdwrATIrCRaJ0UBuY0qjra]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170829.000820, [[dCdCdaGEKIAtOGDHQEnsj7dqnBKmFkWnrk1TPKDIk7fA3QA)s1OqQ0WqPFR0GLYWb4GOqNcPQoMOCoKISqqSuezXuQLl5PKEmqpNkteqQPsrnzqnDHlkcwMO6YexhHnci2Qi0MruNwLdRywiv8zkY3PqNxKSokOrdsFdfDsrQXHuORbi5EIO)svpdPkhcPGXm0mQaTqEiOcecQkab8gQJMN42h5YbQmu5glb10j2BaPwx0Bqw1WEdwipeubQKekzCcYLZMXKLgZPjEww2C6LHkjzGtz(SeulI)a9awJsXhNL4J1ZKLo9wr8IJpolXhRphvgbJBFhAg5YqZOMWp2ucmcbvJqLNKmWPq1bwhGavfSoabQfXFGEaRrP4bjQs(O3aozVXKT3yO3kIx6nGt2B5OM(HpWj2c1FFbvgTpQlsHQDjta1VK9U7HRX06gujjdCkZNLGAr8hOhWAuk(4SeFSEMS0P3kIxC8Xzj(y95OssOKXjixoBgZmwu5glbviLmb0EBj3B69W1yADdgixoAg1e(XMsGriOYnwcQKi(EdsjtafvfSoabQWBWBxYeq9lzV7E4AmTUHpoqADVjdmGUG7sbVgFE7sMaQFj7D3dxJP1n8Lyn37sYYqr8hOhWAukEqIQKpaojtwgOBr8cWjZnWaBcYK5lXAlNqjoN349Hu8eayOiEb4Kz0N(OssOKXjixoBgZmwut)Wh4eBH6VVGkJ2h1fPqTiE)ag3(EQZfOs7fMBSeutNyVbKADrVbzvd7n7sMakgih9qZOMWp2ucmcbvUXsqLeX3BCBVbPKjGIQcwhGavAaEdE7sMaQFj7D3dxJP1n8XbsR7nHkjHsgNGC5SzmZyrn9dFGtSfQ)(cQmAFuxKc1I49dyC77PoxGkTxyUXsqnDI9gqQ1f9gKvnS3(T3SlzcOyGbQkyDacuXar]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170829.000820, [[dCZMeaGErG2Ki0UurBJsc7dKy2uCBvPDcXEL2nv7xL6NusLHrOFd1qPKQgmigobhuKAzGYXiPZrjLwijAPQIftQwUWPv8uupwuphstKsIMkjmzsz6kDrvIddCzKRRQ2OiOTkcyZQW5PeFNs9vqstJssnpvsnsvs(gOA0IKXrjjNue9mIIRru6EGuFMO6VezDusXvTkkBL0b4B2QSmlq5byMeeSd2lcmzvlJaEPYjtGBijmWO7neLy2AUHOheytv(HmeaLkcmrv4IwfmR9uuueMmQLFiGMffZlvo((KLeW2uCEamguPfljJy505DWoAvue1QO8fhOBiTQSmNJrylx(HmeaLkcmrv4QILt6AtgS4OSJDQCA9XmRLYb9IduYqOOs2JVuugb8sLFOxCGsgcf9gcuhFPOBrGvfLV4aDdPvLL5CmcB5YpKHaOurGjQcxvSCsxBYGfhLDStLtRpMzTuwymgqiHpKocm6wgb8sLT(XyaXne8XnKegy0TBrKPkkFXb6gsRklJaEPYkdcSPUHGpUHWJRfa5yuq5hYqauQiWevHRkwoPRnzWIJYo2PYCogHTC8DckqRMy89jljGTP4m)JG8fkqdxSBrS6QO8fhOBiTQSmNJrylR)pooJ5Lo)cjQ)poot9D5umUCP47KKnbeW(Pg22tm((KLeW2uCM)rq(cfOLr2YpKHaOurGjQcxvSCsxBYGfhLDStLtRpMzTuof22mUCjDdaDlJaEPYxHTnJl)gIsdaD7wezRIYxCGUH0QYYCogHTC89jljGTP4m)JG89AOHlB5hYqauQiWevHRkwoPRnzWIJYo2PYP1hZSwkJ1nZsbyPYiGxQS1PBMLcWsDlIvufLV4aDdPvLL5CmcB547twsaBtXz(hb571qdx2e1)hhNP(UCkgxUu8DsYMacy)udB7LFidbqPIatufUQy5KU2Kblok7yNkNwFmZAPCkC4s4dj7XxkkJaEPYxHd)gc(4gcuhFPOBrGxfLV4aDdPvLLTtr(db0SugnhJWwgb8sLV67YPyC53qE(oDdbQeqa7Lt6AtgS4OSJDQ8dziakveyIQWvfl)qanlkMxQC89jljGTP48aymOslwsgXYP1hZSwkN67YPyC5sX3jjBciG9YCogHTC89jljGTP4m)JG89AOLrSB3YCogHTC3wa]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170829.000820, [[dKddeaGErG2fkzBKuyFQGMnQwhjfDBr1Hv1ovP9sTBf7xk(PufnmK63aFdfDErXGLkdhKoOi5uIqogOohjvzHiXsrHfJWYv60sEk0YurpNutKKQAQOutMetx4IIspgrxM46ijBuQsBveWMbX2jPsFwK6RIqnnsk57KKrQc8mPkmAvOXrsfNueDisk11KQY9KQQ)kLEnsQrjcAdB2gVFUymzc0017c0rthfaQMnDdOPJyLpoAu9fipv8WumYq4YRfFpPHzsRoNQhlAA6ZEaBej3cAy0ykYOaJ2S9f2SnMDEcUOykgrYTGggnYq4YRfFpPHzctBm5OuKFawJdyeJPikEfzmUsoy1cx06wv1eYA8(5Irgsoy1cx06MUextiRdFpnBJzNNGlkMIrKClOHr1wbeSGSaD0cruxzzffj11K2idHlVw89KgMjmTXKJsr(bynoGrmMIO4vKX4rGkEnPBj4VomE)CX4bav8As30rH)6WHV9WSnMDEcUOykgrYTGggxQMISfkqLSSiPAxzId7NjTrgcxET47jnmtyAJjhLI8dWACaJymfrXRiJrilqhT6ylQfJ3pxm27c0rthgBrT4Wx1YSnMDEcUOykgrYTGggjOccewBLlSOcQrgcxET47jnmtyAJjhLI8dWACaJymfrXRiJXJav8As3sWFDy8(5IXdaQ41KUPJc)1rtxczu5sIC4BFMTXSZtWfftXisUf0WOrgcxET47jnmtyAJjhLI8dWACaJymfrXRiJrabVcz)qmE)CXypj4vi7hIdFvdZ2y25j4IIPyej3cAyKea4kavdlIv(4ylasRUgL9td0pRvY)A0h2pCFgziC51IVN0WmHPnMCukYpaRXbmIXuefVImgHSaD0QJTOwmE)CXyVlqhnDySf1stxcHtKdFzA2gZopbxumfJi5wqdJKaaxbOAyrSYhhBbqA11OSFAG(zTs(xJ(W(HPnYq4YRfFpPHzctBm5OuKFawJdyeJPikEfzmEeStlasRQAcznE)CX4bGDA6aqA6sCnHSoCyeHkK1ZRe8Jcm(E2hSdB]] )

    storeDefault( [[Wowhead Frost: default]], 'actionLists', 20170829.000820, [[dmuYjaqiHKSjLu9jHqAukPCkHQ2Lsmmk1XiLLrcptOuttirxtiQ2MqcFJsACOO4CcHY6esQ5HIs3tiyFcvoOsLfsf9qHiAIcrYfrr2ikQgPqQCsLQwPqumtHi1nfcv7KK(PqQAOcrPLQQ8uIPIcxvicFvOWEL(lPAWcoSklgvESQmzu6YiBMk9zkXOPcNgQxluYSP42QQ2nOFdmCLYXfsPLR45qMUORJQ2Uqk(oj68kjRxieZxOO9tvxTYOctWJZqSLRsKICpEtwNvKn6HpdoICjgaRQIixRYhzOdrvvHTMvBRAmZIcTyhLAwRiVbVLvQS7LyaevgvvRmQWe84meBDwrEdElRWX76UWn0Lo0bU6imKDola0TWVvr9(PkrYZy8HDVedG(qKgJsFynNdDPJ4R8ria)8iuz0SYooSbNRQ8oJr)Ejga1nyuwzpKf)UemvGaiv5Jm0HOQQWwZQMDLioGv9(PkXaO0bDS(aZhakJAFGBOlD0SQkkJkmbpodXwNvK3G3Ykv(ieGFEeQmAwzhh2GZvv4rKooPFuL9qw87sWubcGuLpYqhIQQcBnRA2vuVFQsKar(W(K(rnRASlJkmbpodXwNvK3G3YkrLpWX76USHnMB0bU6UdaLl8B(W6(WA(WA(afT84TnID5bGrdnwi4J0bU6UxsiFyDFGIwE82gXUGOZOdC1H0BaUhmpe(8H49HygtF4bagwGs4c3qx6qh4QJWq25Saq3Yq)hgI8H48HOW2hIVYhHa8ZJqLrZk74WgCUQYg2yUrh4Q7oauwzpKf)UemvGaiv5Jm0HOQQWwZQMDf17NQezXgZn(aW1hy(aqzZQgLLrfMGhNHyRZkYBWBzLHhIF6BaL0S84NHGPpeNpy12hw3hgEi5dXfbFqHpSUpSMpev(qEgcMlo4HwObdTOp8qsxjDBa4cbpodX6dXmM(WdamSaLWfh8ql0GHw0hEiPRKUnaCzO)ddr(aZ6dA2(q8v(ieGFEeQmAwzhh2GZvv4g6sh6axDegYoNfa6QShYIFxcMkqaKQ8rg6quvvyRzvZUI69tvCo0Lo8bGRpiyi7CwaORzvJ8YOctWJZqS1zf5n4TSchVR7cp0bWSshLdbTKow43Q8ria)8iuz0SYooSbNRQGWq25Saqhs3LFwvzpKf)UemvGaiv5Jm0HOQQWwZQMDf17NQiyi7CwaOlII8bMZpRAw1OOmQWe84meBDwrEdElRWsC8UUlUdaL6Uu0qZYqUdHCCCgYhzQ8ria)8iuz0SYooSbNRQ4aO0GHw05mhkRShYIFxcMkqaKQ8rg6quvvyRzvZUI69tvIoGsdgAXhCAou2SQwlJkmbpodXwNvK3G3YkpaWWcucx4g6sh6axDegYoNfa6wg6)WqKpeNpOW2hw3hgEi5dXfbFi2v(ieGFEeQmAwzhh2GZvvg6hmiYqiKUsmmPPYEil(DjyQabqQYhzOdrvvHTMvn7kQ3pv5J(bdImec5dXadtAAwvMPmQWe84meBDwrEdElRWX76Um4FAHFRYhHa8ZJqLrZk74WgCUQIdGsdgArNZCOSYEil(DjyQabqQYhzOdrvvHTMvn7kQ3pvj6aknyOfFWP5qPpSMw8nRAeRmQWe84meBDwrEdElRWX76Um0pyqKHqiDLyysZc)wLpcb4NhHkJMv2XHn4CvfaNbN0CjvzpKf)UemvGaiv5Jm0HOQQWwZQMDf17NQe9CgCsZLuZQQzxgvycECgIToRiVbVLvgEi(PVbusZYJFgcM(qC(GvBFyDF4bagwGs4c3qx6qh4QJWq25Saq3Yq)hgI8H48bf2v(ieGFEeQmAwzhh2GZvvChak1r5GJfvzpKf)UemvGaiv5Jm0HOQQWwZQMDf17NQW8bGsFqYbhlQzv10kJkmbpodXwNvK3G3Ykv(ieGFEeQmAwzhh2GZvvaCgCsZLuL9qw87sWubcGuLpYqhIQQcBnRA2vuVFQs0ZzWjnxs(WAAX3SQAkkJkmbpodXwNvK3G3Ykdpe)03akPz5XpdbtFiUi4dmJTpSUp8aadlqjCHBOlDOdC1ryi7CwaOBzO)ddr(aZgbFqHDLpcb4NhHkJMv2XHn4Cvf3bGsDuo4yrv2dzXVlbtfiasv(idDiQQkS1SQzxr9(PkmFaO0hKCWXI8H10IVzv1IDzuHj4Xzi26SI8g8ww5bagwGs4c3qx6qh4QJWq25Saq3Yq)hgI8bMnc(Gc7kFecWppcvgnRSJdBW5Qkd9dgeziesxjgM0uzpKf)UemvGaiv5Jm0HOQQWwZQMDf17NQ8r)GbrgcH8HyGHjn(WAAX3Szf17NQedGsh0X6dmFaOmQ9bwY94nzZwa]] )

    storeDefault( [[Wowhead Frost: breath]], 'actionLists', 20170829.000820, [[dSdBfaGELs0Maq7sO2MsqTpaQzly(aIpPeIVrsonODIQ2R0Uvz)umkefggj(nshgLHQekdMsdhHdcOoLsP6yuX4aGwOs0svslgvwUOZtL6PelJKADkH0evkHPcKjRGPRQlQu8yfDzORtvBujWZaiBwHMgIQ)kKVci9zQK5HO0ivkLdPeKrJi9DLQtIiUnqDnaW9ukPNtQFQeQEnIIUofuLnhJlGdLRYwGJmF47YkcboHSaClzpKELxna4uzfditJLxTIJkfvoaySAharUJQkYmHeFLkapFi90fu5DkOkBogxah6YkYmHeFLfYy58JJXeWqGLr0XOXKQ)yprLvut95e1fu)kaZbdW3DfcyiWYi6y0ys1FfsUb4K90SYrpSYkgqMglVAfhvokv4zGXklgmeyPXshn2fKu93V8QlOkBogxah6YkYmHeFL0FWzebDhZ4Ppt8EJfWgl5kglanwo)4yS)iLgChP)epxpPXEIkROM6ZjQlO(vaMdgGV7kA4nKmxunthn6t3vi5gGt2tZkh9WkRyazAS8QvCu5OuHNbgRiWBizUOA2IOn2f4t39lpGkOkBogxah6YkYmHeFfYWyt)bNre0DmJN(mX7nwaBSKRySa0yt)HglG3QXciJD7glqaIXY5hhJtemn1ya16OD49ygRF2Kmn2TASokvwrn1Ntuxq9RamhmaF3vsemn1ya16OD49ywHKBaozpnRC0dRSIbKPXYRwXrLJsfEgySYkcMMAmGATXcu49y2V8Kxqv2CmUao0LvKzcj(kC(XX4ecgJ9eglan20FWzebDhZ4Ppt8EJfWgl5kvwrn1Ntuxq9RamhmaF3viLUhGNRiUat)vi5gGt2tZkh9WkRyazAS8QvCu5OuHNbgRSn6EaEUm2LbM(7xEaOGQS5yCbCOlRiZes8vidJn9hCgrq3XmE6ZeV3yjRXcGkglqaIXY5hhJj1FUWeEUIs)Hr7iJGEXEcJD7glanwo)4yCcbJXd09RYkQP(CI6cQFfG5Gb47UcLlaFmzpwHKBaozpnRC0dRSIbKPXYRwXrLJsfEgySYIZfGpMSh7x(fUGQS5yCbCOlRiZes8vs)bNre0DmJN(mX7nwYASKRuzf1uForDb1VcWCWa8DxHu)5ct45kk9hgTJmc6vHKBaozpnRC0dRSIbKPXYRwXrLJsfEgySY28NlmHNlJD1FOXcuKrqV(LxvbvzZX4c4qxwrMjK4RK(doJiO7ygp9zI3BSK1ybKsLvut95e1fu)kaZbdW3DfembDhZO0Fy0oYiOxfsUb4K90SYrpSYkgqMglVAfhvokv4zGXkBatq3X0yx9hASafze0RF)k8mWyfGs3jfzdg7csQ(xuJLlr2tA)wa]] )    


    storeDefault( [[Frost Primary]], 'displays', 20170624.232908, [[d0d4gaGEvKxcvLDrPO2MkkzMsQ8yumBfDCur3eQQMMKQUTk8nkv1oPQ9k2nr7Ne(PcnmvY4urfNMudfPgmQ0Wr4GsYZjCmQ4CQOQfkrlLsPftslNIhsL6PGLrLSokfzIQOyQqzYKOPR0fvWvPu4YqUos2Ok1wvrL2mQA7iQpkP4zOc9zOY3LWirfCyPgnknEOkNerUfLQCnkvopL8BvTwvuQxlP0XjybyAIv)Y7xUWAnrbgTbwDK8dbyAIv)Y7xUG(ekEhxbmTehYnlIP2ugqDQpDQM5xKYawJ88c06Ujw9lfXFfaVrEEbAD3eR(LI4VcWjfIcPKeZlb9ju81Ff4qlRgINJb4KcrHu6Ujw9lfPmG1ipVaTyTbhAfXFfqW(fqHEzyRgszab7xurTFkdOzEjq0mAjU4TlW2gCOTsYW(MaLJyyJ43ws1WbSaw52ENZ5TVRlh7Q35825IJx2)k82RE7cynYZlql(kfXBpNac2VaRn4qRiLbQvTsYW(MayJ02sQgoGfqlvQz69nvsg23eWws1WbSamnXQFzLKH9nbkhXWgXFaGaXO7P(uV6xgVl7Cciy)calLb4KcrHoJ2Gyw9ldylPA4awaj1bjMxkIV(acc0CEpBbR7F(MGfOJ3jGjENa4I3jGA8ozdiy)c3nXQFPiQbWBKNxG2kkth)vGMY0yweOaQu88boA8QO2p(RaQt9Pt1m)IQ5mQb6jbBdSFbn5H4Dc0tc229FO2ln5H4DcCgeFtn3ugONfTLGMmDkdqwl0Q6PETWSiqbudW0eR(Lvtnoza3dESbBdOuliMTfMfbkqhW0sCimlcuGwvp1RvGMY04xlrPmqTQ3VCb9ju8oUc0tc2gRn4qlnz64DcyqZaUh8yd2gqqGMZ7zlyJAGEsW2yTbhAPjpeVtaoPquiLKKk1m9(grkd4(jSuWf7dCBEXQGB14qGdTSIA)4VcSTbhAVF5cR1efy0gy1rYpeqjIVPMBfDDba9HBfCVnVyTjfCvI4BQ5gaV4Vciy)cOqVmSvu7NYa9KGTRMfTLGMmD8ob0mV8S))iEh7cqy0hTX6(LlOpHI3XvacdI5pu7TIUUaG(WTcU3MxS2KcUegeZFO2Ba(xUbOXuWfAPqbxFBmFrGJgVQH4Vcqy0hTXIeZlb9ju81FfyBdo0stEiQb4KcrHQMACYdKCdWeqW(f0KPtza8g55fOLKuPMP33iI)kG1ipVaTKKk1m9(gr8xb22GdT3VCdqJPGl0sHcU(2y(Ia4nYZlqlwBWHwr8xbeSFrfLPjj5)OgqW(fKKk1m9(grkdynYZlqBfLPJ)kqplAlbn5HugqW(f0Khszab7xunKYam)HAV0KPJAGMY0abAojDM4Vc0uMUsYW(MaLJyyJ4VUHBSanLPjj5FmlcuavkE(ahAjGf)vGTn4q79lxqFcfVJRaCsPzQ9C1cyTMOaDaMMy1V8(LBaAmfCHwkuW13gZxeONeST7)qTxAY0X7eyq2QtKYugqOpiMOQXH4DfOw17xUbOXuWfAPqbxFBmFrGEsW2vZI2sqtEiENam)HAV0KhIAGTn4qlnz6OgqW(f4dzPQLk1sCIugWw0e1cu8UUCS)1z5QEB2fhDSZfhdC04byX7eaVrEEbAXxPiENa9KGTb2VGMmD8ob4KcrHuE)Yf0NqX74kqTQ3VCH1AIcmAdS6i5hcWjfIcPeFLIugW3hOa3MxSk4sB0hTXkqtzABi1BaIzBHmzta]] )

    storeDefault( [[Frost AOE]], 'displays', 20170624.232908, [[dSJYgaGEPuVejXUuufVwkPzkLy2kCteupgPUTQyBkQu7Ks7vSBI2pb(Pu1WuL(TktdbzOOYGjOHdvhKk9Csogv1XrvSqfzPOkTyuA5u8qPWtbltrzDkQQjkfPPQQMmQQPR0fLkxfjLld56iAJqPTQOs2mH2os8rPOonP(mu8DQYirs6zkQy0Oy8iWjrOBjfHRHKQZtfhwYALIOVPOkD8ZpaDHV6tI9KlSoduGEQ9BHOTlaDHV6tI9KlOBJI1FwatjXGAWGOBntb4HerIChAmYhKCdqhWPxuuH2gf(QpPk23ae0lkQqBJcF1Nuf7BaCJ(PmoePpjOBJILqVbE0s3UyNtaEirKi(nk8vFsvMc40lkQq7VmyqRk23akMZd80lnJBxydOyopxY9cBafZ5bE6LMXLCVmfyldg06kPzotGP()VNW8sSzQ(d4eBtmZ)nabX(gqXCE)YGbTQmfOvwxjnZzc8754LyZu9hql5RPR9mUsAMZeGxInt1Fa6cF1N0vsZCMat9)FpHda4iADn0TRvFYyNrD)akMZd(zkapKisut1ge9QpzaEj2mv)bKKpePpPkwcfqHJgdSJsX04gNj)avS(byJ1paMy9dyI1pBafZ51OWx9jvHnab9IIk06sAQyFduKM67GJcWskkg4PiWLCVyFdWo0TB3848ChJWgOg4mfWCECu6I1pqnWzQg3dBTCu6I1pqtrIf5yZuGA4vokokCzkafTsZQh6157GJcWgGUWx9jDhAmYan6S)oEdWxRWhLZ3bhfGoGPKyqFhCuGIvp0RtGI0uewlrzkqRSyp5c62Oy9NfOg4m1VmyqlhfUy9dyqJan6S)oEdOWrJb2rPycBGAGZu)YGbTCu6I1papKiseFIs(A6ApJktbAC4oce(VaynNAfi0TVlGTEqbWAo1kqOBFxGTmyql2tUW6mqb6P2VfI2Ua8rIf5yD5AjaOFAiqiwZP25lqiFKyro2aTYI9KlSoduGEQ9BHOTlGM(KaErRLyIL6bQbot5o8khfhfUy9dudCMcyopokCX6ha3OFkJd2tUGUnkw)zbWni67HTwxUwca6NgceI1CQD(ceIBq03dBTbiOxuuHwQmPI1pWtrGBxSVbEkcGFS(b2YGbTCu6cBaErduPqXo71FEFN7zeAEMnhFQpBobumNhhfUmfqXCEub5WQL81smQmfyldg0YrHlSbOVh2A5O0f2a1aNPChELJIJsxS(bALf7j3aCFbcHsQei0wgZ5fqXCEeL8101EgvMc40lkQqRlPPI9nqn8khfhLUmfqXCEUDHnGI584O0LPa03dBTCu4cBGAGZunUh2A5OWfRFGI0uUsAMZeyQ))7jClDy)b4Hut36CPvW6mqbyd8OLWp23aBzWGwSNCbDBuS(ZcuKMIOu8(o4OaSKIIbOl8vFsSNCdW9fiekPsGqBzmNxGI0uaoAmi20yFd0jl2bIFMcO0p4dKBFxSZcOyopxstrukEHnab9IIk0(ldg0QI9nWwgmOf7j3aCFbcHsQei0wgZ5fWPxuuHwIs(A6ApJk23ae0lkQqlrjFnDTNrf7Ba2HUD7MhNxMcWdjIeXNi9jbDBuSe6nG4j3aCFbcHsQei0wgZ5fqtFYM8UNy9PEaEirKi(yp5c62Oy9NfWPxuuHwQmPITj8dWdjIeXNktQmf4rlDj3l23afPPOMuVbWhLdYKnba]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )


end

