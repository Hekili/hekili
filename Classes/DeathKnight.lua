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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20171006.165328, [[deu7AaqisvzreQqBsfmksvofPs7IuggICmr1YeONPsPPrQQCnvkSnvk6BQunocvY5ef06ivvzEeQ6EsI2NOOdsOSqQOEOk0eff6IKk2iPQQ(iHkQtsLYmjubUPkzNi1pjurwkv4PuMkvYvjuP2kvQ2RYFLudgLdl1Ir4XImzQ6YGnlOplGrtiNMKxJOMTe3MGDd1VHmCv0Xffy5e9CHMUQUos2ovKVlkDEjP1tOcA(sc7hvV85AMLKQZF2m6waMzkHJCM4glcvQQ)4SaagKQ0mhqb6im6GKYVtsCfmd1irIK4k4m7esQUOeh2VcHhDWBeCMyPxHWX5A05Z1mDWnrb8Z5zwsQo)zpkqGcOLqOIhLfh5SdCMECM(4midOuNNGxl)27KUFdo7aNjPWQu9jkli18qOkPEot8C2TK4mDNjgHQO(QZ8TKCDljupiN5g2Rs9JKZWimm7c5DVL0TamBgDlaZYyljZzIjjupiN5akqhHrhKu(9CsZCareLmbX5A)SJIGe5lKtGaG)rm7c5PBby2(rhCUMPdUjkGFopZss15pdYak15j41YV9oP73GZoWzEGGkmuleIpiv4a1zruyVw87ezolZk5SBYzh4SVla(18TKCDljupi1aCtua)mXiuf1xDwFIsDP6zeM5g2Rs9JKZWimm7c5DVL0TamBgDlaZe7eL6s1ZimZbuGocJoiP875KM5aIikzcIZ1(zhfbjYxiNaba)Jy2fYt3cWS9J(25AMo4MOa(58mljvN)Shfiqb0siuXJYIJC2botpodYak15j41YV9oP73GZoWzskSkvFIYcsnpeQsQNZepNDljo7aNLqOIhLfR5Bj56x24yisk0VcH1KGqRWrot8Cwqot3zIrOkQV6mFljx3sc1dYzUH9Qu)i5mmcdZUqE3BjDlaZMr3cWSm2sYCMysc1dsotVCDN5akqhHrhKu(9CsZCareLmbX5A)SJIGe5lKtGaG)rm7c5PBby2(rRFZ1mDWnrb8Z5zwsQo)zpkqGcOLqOIhLfh5SdCMECMKcdCM4RKZULZ0DMyeQI6RolsjiGW1bAzau1cmZnSxL6hjNHryy2fY7ElPBby2m6waMzuccimNjo3YaOQfyMdOaDegDqs53ZjnZberuYeeNR9ZokcsKVqobca(hXSlKNUfGz7h9nMRz6GBIc4NZZSKuD(ZiOcd1OWIqLQ1Xxc4aVinQto7aNrqfgQLqfFTiOLVw87ezoltolpdNjgHQO(QZsIAfowJcRvjyMByVk1psodJWWSlK39ws3cWSz0Tam7OOwHJCgkKZClbZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OV5CnthCtua)CEMLKQZF2JceOaAjeQ4rzXro7aNPhNbzaL68e8A53EN09BWzh4Secv8OSynFljx)YghdrsH(viSMeeAfoYzINZYjXzh4mjfg4mXxjNDlNP7mXiuf1xDwKsqaHRd0YaOQfyMByVk1psodJWWSlK39ws3cWSz0TamZOeeqyotCULbqvlaNPxUUZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OVpxZ0b3efWpNNzjP68N5bcQWqTqi(GuHduNfrH9AXVtK5SmRKZUjNDGZsiuXJYI16tuQlvpJGMeeAfoYzINZ0VzIrOkQV6SiIQulH(eKZCd7vP(rYzyegMDH8U3s6waMnJUfGzgIQWzoG(eKZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OfxZ1mDWnrb8Z5zwsQo)zEGGkmuleIpiv4a1zruyVw87ezolZk5SBotmcvr9vN1NOuxQEgHzUH9Qu)i5mmcdZUqE3BjDlaZMr3cWmXorPUu9mcCME56oZbuGocJoiP875KM5aIikzcIZ1(zhfbjYxiNaba)Jy2fYt3cWS9JodNRz6GBIc4NZZSKuD(ZKuyvQ(eLfKAEiuLupNjEolN0mXiuf1xDMh6xuDcPkZCd7vP(rYzyegMDH8U3s6waMnJUfGzze6xeNDePkZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OZjnxZ0b3efWpNNzjP68NPpo77cGFnFljx3sc1dsna3efWZzh4mcQWqTiL3d4ApcjOrDYzh4m9XzeuHHAyijrrvuJ6KZoWzskmWzIVso72zIrOkQV6mp0VO6esvM5g2Rs9JKZWimm7c5DVL0TamBgDlaZYi0Vio7isv4m9Y1DMdOaDegDqs53ZjnZberuYeeNR9ZokcsKVqobca(hXSlKNUfGz7hDE(CnthCtua)CEMLKQZF23fa)A(wsUULeQhKAaUjkGNZoWzeuHHArkVhW1EesqJ6KZoWzjeQ4rzXA(wsUULeQhKAsqOv4iNLjNDdo7aNjPWaNj(k5SBNjgHQO(QZ8q)IQtivzMByVk1psodJWWSlK39ws3cWSz0TamlJq)I4SJivHZ0lOUZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OZdoxZ0b3efWpNNzjP68N5bcQWqTqi(GuHduNfrH9AXVtK5mXZz3KZoWzjeQ4rzXA9jk1LQNrqtccTch5mXxjNDZzIrOkQV6Sqi(GuHduhFPImmZnSxL6hjNHryy2fY7ElPBby2m6waMP)H4dsfoaNzVurgM5akqhHrhKu(9CsZCareLmbX5A)SJIGe5lKtGaG)rm7c5PBby2(rNF7CnthCtua)CEMLKQZFMhiOcd1cH4dsfoqDwef2Rf)orMZYSso72zIrOkQV6SiIQulH(eKZCd7vP(rYzyegMDH8U3s6waMnJUfGzgIQWzoG(eKCME56oZbuGocJoiP875KM5aIikzcIZ1(zhfbjYxiNaba)Jy2fYt3cWS9Jox)MRz6GBIc4NZZSKuD(Z8abvyOwervQLqFcsnQto7aNPpoZdeuHHAHq8bPchOolIc71OoNjgHQO(QZcH4dsfoqD8LkYWm3WEvQFKCggHHzxiV7TKUfGzZOBbyM(hIpiv4aCM9sfzGZ0lx3zoGc0ry0bjLFpN0mhqerjtqCU2p7Oiir(c5eia4FeZUqE6waMTF053yUMPdUjkGFopZss15pZdeuHHArevPwc9ji1Oo5SdCMhiOcd1cH4dsfoqDwef2Rf)orMZYSsolFMyeQI6RolMquYaqD8LkYWm3WEvQFKCggHHzxiV7TKUfGzZOBbyMLquYaaNzVurgM5akqhHrhKu(9CsZCareLmbX5A)SJIGe5lKtGaG)rm7c5PBby2(rNFZ5AMo4MOa(58mljvN)mpqqfgQfruLAj0NGuJ6KZoWzEGGkmuleIpiv4a1zruyVw87ezolZk5S8zIrOkQV6SuPZQWbQJIApkBCMByVk1psodJWWSlK39ws3cWSz0Tam7yPZQWb4mtu7rzJZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OZVpxZ0b3efWpNNjgHQO(QZ8qOQaZCd7vP(rYzyegMDH8U3s6waMnJUfGzzecvfyMdOaDegDqs53ZjnZberuYeeNR9ZokcsKVqobca(hXSlKNUfGz7hDU4AUMPdUjkGFopZss15pRtVYjOgWGGcICwMvYzbNjgHQO(QZsDPu3PxHW1fv8NDueKiFHCcea8pIzxiV7TKUfGzZOBby2XUu4mXsVcH5mXbQ4ptmzG4mClavkoAkHJCM4glcvQQ)4mXeN0rCCMdOaDegDqs53ZjnZberuYeeNR9ZCd7vP(rYzyegMDH80TamZuch5mXnweQuv)XzIjoPZ(rNNHZ1mDWnrb8Z5zwsQo)zEGGkmuleIpiv4a1zruyVw87ezot8vYzb5SdCMECMhiOcd1cH4dsfoqDwef2Rf)orMZeFLCM(XzvubNPhNrqfgQruube9GVwsHH6SqFIWAuNCwfvWzFxa8RL64Rc0psQb4MOaEotxotxo7aNjPWQu9jkli18qOkPEolto7gC2botpotsHvP6tuwqQ5Hqvs9CwMCwWB5SkQGZ0hN9DbWVwQJVkq)iPgGBIc45mDNjgHQO(QZcH4dsfoqD8LkYWm3WEvQFKCggHHzxiV7TKUfGzZOBbyM(hIpiv4aCM9sfzGZ0lOUZCafOJWOdsk)EoPzoGiIsMG4CTF2rrqI8fYjqaW)iMDH80TamB)OdsAUMPdUjkGFopZss15ptFCgbvyOggssuuf1Oo5SdC23fa)AyijrrvudWnrb8C2botsHHO2ReG6hvRFCwMCwGKFMyeQI6RoZd9lQoHuLzUH9Qu)i5mmcdZUqE3BjDlaZMr3cWSmc9lIZoIufotVB1DMdOaDegDqs53ZjnZberuYeeNR9ZokcsKVqobca(hXSlKNUfGz7hDW85AMo4MOa(58mljvN)m94mcQWqnmKKOOkQrDYzvubNrqfgQrHfHkvRJVeWbErAuNCwfvWzskmWzzwjNfKZ0LZoWzEGGkmuleIpiv4a1zruyVw87ezolZk5SCo7aNPhN5bcQWqTqi(GuHduNfrH9AXVtK5SmRKZULZQOcotFCMEC23fa)APo(Qa9JKAaUjkGNZQOcodYak15j41ErqTchFjv6rYyDiIs(IQlqmIWCMUCMUC2botsHvP6tuwqQ5Hqvs9CwMCwgYzh4m94mjfwLQprzbPMhcvj1ZzzYzbVLZQOcotFC23fa)APo(Qa9JKAaUjkGNZ0DMyeQI6RolMquYaqD8LkYWm3WEvQFKCggHHzxiV7TKUfGzZOBbyMLquYaaNzVurg4m9Y1DMdOaDegDqs53ZjnZberuYeeNR9ZokcsKVqobca(hXSlKNUfGz7hDWGZ1mDWnrb8Z5zwsQo)z6XzeuHHAyijrrvuJ6KZQOcoJGkmuJclcvQwhFjGd8I0Oo5SkQGZKuyGZYSsoliNPlNDGZ8abvyOwieFqQWbQZIOWET43jYCwMvYz5C2botpoZdeuHHAHq8bPchOolIc71IFNiZzzwjNDlNvrfCM(4midOuNNGx7fb1kC8LuPhjJ1Hik5lQUaXicZz6Yzh4mjfwLQprzbPMhcvj1ZzzYzz4mXiuf1xDwQ0zv4a1rrThLnoZnSxL6hjNHryy2fY7ElPBby2m6waMDS0zv4aCMjQ9OSrotVCDN5akqhHrhKu(9CsZCareLmbX5A)SJIGe5lKtGaG)rm7c5PBby2(rh825AMo4MOa(58mljvN)SVla(1IIApkBTchsfviSgGBIc45SdC23fa)A(wsUULeQhKAaUjkGNZoWz6JZiOcd18TKC9lBCmejf6xHWAuNC2bolHqfpklwZ3sY1TKq9GutccTch5Sm5SCsZeJqvuF1zEOFr1jKQmZnSxL6hjNHryy2fY7ElPBby2m6waMLrOFrC2rKQWz6PF6oZbuGocJoiP875KM5aIikzcIZ1(zhfbjYxiNaba)Jy2fYt3cWS9JoO(nxZ0b3efWpNNzjP68N9DbWVwuu7rzRv4qQOcH1aCtuapNDGZ0hN9DbWVMVLKRBjH6bPgGBIc45SdCM(4mcQWqnFljx)YghdrsH(viSg15mXiuf1xDMh6xuDcPkZCd7vP(rYzyegMDH8U3s6waMnJUfGzze6xeNDePkCME3q3zoGc0ry0bjLFpN0mhqerjtqCU2p7Oiir(c5eia4FeZUqE6waMTF0bVXCnthCtua)CEMLKQZF23fa)A(wsUULeQhKAaUjkGNZoWzjeQ4rzXA(wsUULeQhKAsqOv4iNLjNLtAMyeQI6RoZd9lQoHuLzUH9Qu)i5mmcdZUqE3BjDlaZMr3cWSmc9lIZoIufotVBQ7mhqb6im6GKYVNtAMdiIOKjiox7NDueKiFHCcea8pIzxipDlaZ2p6G3CUMPdUjkGFopZss15ptFC23fa)ArrThLTwHdPIkewdWnrb8C2botFC23fa)A(wsUULeQhKAaUjkGFMyeQI6RoZd9lQoHuLzUH9Qu)i5mmcdZUqE3BjDlaZMr3cWSmc9lIZoIufotV76oZbuGocJoiP875KM5aIikzcIZ1(zhfbjYxiNaba)Jy2fYt3cWS97NLriSPk)CE)g]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20171006.165328, [[dmu6saqiujQfjuQ2KqXOqvYPqv0RekPUfQeXUuIHPuDmHSmLINju10ekLRrsSnuLQVrcJtOsNdvsSouLY8eQ4EKQ0(qLWbHclevQhcfnrufUijPnkuIojjYmfkj3ujTtO6NOsKgQqj0srv9uIPcLUkQKARKO(QqjyVs)fGbdYHPAXKYJbAYuCzKnlqFMKA0c40O8AanBrDBkTBv9BfdhvCCsvSCipxKPRY1f02vk9DsvDEsL1JkjTFqDJk2kciIX5Qub3TufHzXegIR)atwhVbdzOGEy(QWNYKNOIVzpsXEC3Wvw233J7MkchcK5zgx1p28fFJkBQGb4XMpvSfpQyRO67AzYuURiGigNRYnQvNPf2FecfY5svWqJLzNUkw2BaeerexLQO0ByG(nOk)8uL1XOSJWDlvPcUBPkRS3adflreXvPk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4Bk2kQ(UwMmL7kciIX5QGcFgiaoJ(eAXqbzGSdgIlGH2SxbdnwMD6Q4iq)ja3Gq0Fvu6nmq)guLFEQY6yu2r4ULQub3TufmqG(tWqyheI(RcFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPk9kE8fBfvFxltMYDfbeX4CvUrT6mTaot2m6)PkyOXYStxfT8mgabdr6QO0ByG(nOk)8uL1XOSJWDlvPcUBPkCNNXadfldr6QWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhBfBfvFxltMYDfbeX4CvUrT6mTaot2m6)PkyOXYStxfncLieq2RUIsVHb63GQ8ZtvwhJYoc3TuLk4ULQWnHseci7vxHpLjprfFZEKIO9k8P0eIaPuX2RcMbiqGRZwYs)vTkRJb3TuLEfxLITIQVRLjt5UcgASm70vjmrayhztvu6nmq)guLFEQY6yu2r4ULQub3TufUorWqkDKnvHpLjprfFZEKIO9k8P0eIaPuX2RcMbiqGRZwYs)vTkRJb3TuLEfN3l2kQ(UwMmL7kciIX5QCJA1zAHZCS5tWqXadXlyiTWGbxc)atwhG0HOx9fyjKdmepRGHglZoDv4mhB(kk9ggOFdQYppvzDmk7iC3svQG7wQsS4CS5RWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIROyRO67AzYuURiGigNRcVGHmZTSLHcZ0Fa4KD1H0YXabc4ywcaISo7tWqXAyOJbceWXSemuC0lmKzULTmuyM(daNSRoKwqK1zFcgINWqXadzMBzldfMP)aWj7QdPfezD2NGHIJEHHudAQGHglZoDvMWtdroWkygGabUoBjl9x1QSogLDeUBPkvWDlvHln80qKdScgi1PkNJuthawq9YlZClBzOWm9haozxDiTCmqGaoMLaGiRZ(uS(yGabCmlfh9AMBzldfMP)aWj7QdPfezD2N4zmM5w2YqHz6paCYU6qAbrwN9P4Ox1GMk8Pm5jQ4B2JueTxHpLMqeiLk2Evu6nmq)guLFEQY6yWDlvPxXJBXwr131YKPCxrarmoxLBuRotlGZKnJ(FQcgASm70vXrwDaMGaUaead5Mkk9ggOFdQYppvzDmk7iC3svQG7wQcgiRoyOjim0fGGH4b5Mk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4CLITIQVRLjt5UIaIyCUkKEczC4qMLO4vSRqfyOyGHaNjBg9)fJJacWrASJqliY6SpbdXfWqr8UkvWqJLzNUkghbeWH8pfCqw)yZxrP3Wa9Bqv(5PkRJrzhH7wQsfC3sv4HJacdHf5Fk4GS(XMVcFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPk9kE0EXwr131YKPCxrarmoxfspHmoCiZsu8k2vOcmumWqCzyOZZ0FlPaUz0ha7dgMyZVqVRLjdmumWqGZKnJ()IXrab4in2rOfezD2NGH4cyivuPcgASm70vX4iGaoK)PGdY6hB(kk9ggOFdQYppvzDmk7iC3svQG7wQcpCeqyiSi)tbhK1p28Wq8kINv4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvPxXJIk2kQ(UwMmL7kciIX5Qq6jKXHdzwIIxXUcvGHIbg68m93skGBg9bW(GHj28l07AzYadfdme4mzZO)VyCeqaosJDeAbrwN9jyiUagkEvQGHglZoDvmociGd5Fk4GS(XMVIsVHb63GQ8ZtvwhJYoc3TuLk4ULQWdhbegclY)uWbz9JnpmeV2WZk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4rBk2kQ(UwMmL7kciIX5Qq6jKXHdzwIIxXUcvGHIbg6CKA6woMLaCdadJGHIdme4mzZO)VyCeqaosJDeAbrwN9jyiUeyO4wbdnwMD6QyCeqahY)uWbz9JnFfLEdd0Vbv5NNQSogLDeUBPkvWDlvHhocimewK)PGdY6hBEyiEfppRWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhfFXwr131YKPCxrarmoxfspHmoCiZsu8k2vOcmumWqGZKnJ()sk0ANhGAhPE0LPfezD2NGH4cyOiEFVcgASm70vX4iGaoK)PGdY6hB(kk9ggOFdQYppvzDmk7iC3svQG7wQcpCeqyiSi)tbhK1p28Wq8k24zf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6v8OyRyRO67AzYuURiGigNRcPNqghoKzjkEf7kubgkgyiUmm05z6VLua3m6dG9bdtS5xO31YKbgkgyiWzYMr)FjfATZdqTJup6Y0cISo7tWqCbmKkQubdnwMD6QyCeqahY)uWbz9JnFfLEdd0Vbv5NNQSogLDeUBPkvWDlvHhocimewK)PGdY6hBEyiEPcpRWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhPsXwr131YKPCxrarmoxfspHmoCiZsu8k2vOcmumWqNNP)wsbCZOpa2hmmXMFHExltgyOyGHaNjBg9)LuO1opa1os9OltliY6SpbdXfWqXRsfm0yz2PRIXrabCi)tbhK1p28vu6nmq)guLFEQY6yu2r4ULQub3TufE4iGWqyr(NcoiRFS5HH4fVZZk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4r8EXwr131YKPCxrarmoxfspHmoCiZsu8k2vOcmumWqNJut3YXSeGBayyemuCGHaNjBg9)LuO1opa1os9OltliY6SpbdXLadf3kyOXYStxfJJac4q(NcoiRFS5RO0ByG(nOk)8uL1XOSJWDlvPcUBPk8WraHHWI8pfCqw)yZddXlf8ScFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPk9kEKIITIQVRLjt5UIaIyCUkCzyispHmoCiZsu8k2vOcmumWqOWNGHIJEHHIVcgASm70vX4iGaoK)PGdY6hB(kk9ggOFdQYppvzDmk7iC3svQG7wQcpCeqyiSi)tbhK1p28Wq8kU8ScFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPk9kEuCl2kQ(UwMmL7kciIX5QyiTWGbxcsPJqSxna9NW3SKoheimuC0lmuSvbdnwMD6QOLzQdCKbak8ja6toN5RO0ByG(nOk)8uL1XOSJWDlvPcUBPkCNzQdCKbgIF4tWqXcKZz(k8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4rCLITIQVRLjt5UIaIyCUkNNP)wmociahPXocTqVRLjdmumWqCOBzRNbQdbqZVltwNzOFXbp2wQcgASm70vbf(aCWJnpGmlDvWmabcCD2sw6VQvzDmk7iC3svQG7wQc)WhgcdWJnpmuSILUkyGuNQ8UL0BSlmlMWqC9hyY64nyOTEgOouSxHpLjprfFZEKIO9k8P0eIaPuX2RIsVHb63GQ8ZtvwhdUBPkcZIjmex)bMSoEdgARNbQd1R4B2l2kQ(UwMmL7kyOXYStxfqpNb4GhBEazw6QO0ByG(nOk)8uL1XOSJWDlvPcUBPky65mmegGhBEyOyflDvWaPov5DlP3yxywmHH46pWK1XBWqQPNqmWyVcFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPkcZIjmex)bMSoEdgsn9eIb2RxfEqb9W8vU71c]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20171006.165328, [[dqdgdaGEOsAxueVgrz2s5MuPBlv7KQ2lz3iTFezyu43sgQavdgHgoKCqQWXeY5Gk0cfWsf0IrPLROhku9uWYuO1bvKjsrAQkyYuA6kDre0vHkQlR66OWZHYwHQSzbY2rGhdXxru10Gk47qL6WIghIkJgsDAuDsOQ(Mq5Acuopk6VurFMI6zqLyfPbbaYKJAfiWN9la494KiIZu0vJjorIiQ5rQoBUccF7j2LF0ikMb5gXrtmmmi3Oaa1r4zJJR5YlQ8JbBuGdKLxumniFKgeqinzB3QacaKjh1kylZMB3eu1YlkMahS8gFzkavT8IkaFQLJKBnfql6f4ww8YPp7xGaF2VGGxlVOccF7j2LF0ikwKHGWJvmMihtdAfeh9riZTi49txXkWTS(SFbALFudciKMSTBvaboy5n(YuWm5y3P9Pva(ulhj3AkGw0lWTS4LtF2Vab(SFbHjh7KiA6tRGW3EID5hnIIfzii8yfJjYX0GwbXrFeYClcE)0vScClRp7xGw5XfniGqAY2UvbeaitoQvWwMn3Ujiv1SfUPycCWYB8LPGC2z6ScY5I(oTpTcWNA5i5wtb0IEbULfVC6Z(fiWN9lWXSZKeXkisex0NertFAfe(2tSl)OruSidbHhRymroMg0kio6JqMBrW7NUIvGBz9z)c0kpoObbest22TkGahS8gFzkGTXnJEV15Kb9oX9tufva(ulhj3AkGw0lWTS4LtF2Vab(SFbbACZO3BjrmKb9Kis(NOkQGW3EID5hnIIfzii8yfJjYX0GwbXrFeYClcE)0vScClRp7xGwTcm9bLmARcOvc]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20171006.165328, [[d0ZbgaGEqeTjjsSlI0RbP9bIYmLiPzlPNtQBkHhlYTb6Wk2Pu2l1UrA)cmkjs1WKk)gX5rvDAugmjgoO6GeLtbIWXa05KiLfIkzPOklMKwUqlcePNcTmcSojcteuKPIkMSOMUsxuQYvLi6zGI66cAJGcTvuP2maBhe(MuvFxIAAGsAEeQABeQ8xIy0e04ar1jju(mHCnqjUhOuxw1djQ(jOGnqZXiMIm4RrJTb8grgO8aLssfsQ8lrGcetfk)OrEV(rF3e0bSFhKlO0K211b5cmIWFInvgKCwgH6MayrGrzPLrOAZXnGMJXE0rT(S5YOmvwLT8nM)ScLKiSQrXOzwAws0iLqVXcsM7j2gWB0yBaVry6ZkmqroHvnY71p67MGoG9b2zK31KWy6AZXRr5cFcAbbIdE6AvJfKCBaVrVUjWCm2JoQ1NnxgXuKbFnMVAiaasbC9(iJksszsinlvVtcAGcKb7afXzuMkRYw(gh4K0u5dxFJIrZS0SKOrkHEJfKm3tSnG3OX2aEJYGtstLpC9nY71p67MGoG9b2zK31KWy6AZXRr5cFcAbbIdE6AvJfKCBaVrVUbZMJXE0rT(S5YiMIm4RX8vdbaqkGR3hzursktcPzP6DsqdueFGI4cukLaLeHuZKYuPdCsAQ8HRV04bhgvhOi(afy2OmvwLT8nc469rgvKe9gzqVrXOzwAws0iLqVXcsM7j2gWB0yBaVry869rgvuGcUrg0BK3RF03nbDa7dSZiVRjHX01MJxJYf(e0cceh801Qgli52aEJEDdwnhJ9OJA9zZLrmfzWxJtAzqCjNEq21bkqgSdueyuMkRYw(gttTkzslJqLuz61OCHpbTGaXbpDTQXcsM7j2gWB0yBaVr5tTgOilTmcnqPuz61OSOiTr6aEydPiduEGsjPcjv(Liqrgm0dsnY71p67MGoG9b2zK31KWy6AZXRrXOzwAws0iLqVXcsUnG3iYaLhOusQqsLFjcuKbd986gSyog7rh16ZMlJykYGVgZxneaaPaUEFKrfjPmjKMLQ3jbnqr8WoqbwnktLvzlFJaUEFKrfjrVrg0BumAMLMLensj0BSGK5EITb8gn2gWBegVEFKrffOGBKb9bkLoqiHrEV(rF3e0bSpWoJ8UMegtxBoEnkx4tqliqCWtxRASGKBd4n61nXzog7rh16ZMlJykYGVgZxneaaPaUEFKrfjPmjKMLgc3OmvwLT8nQtKWOOlrVrg0BumAMLMLensj0BSGK5EITb8gn2gWBetKWOOhOGBKb9g596h9DtqhW(a7mY7AsymDT541OCHpbTGaXbpDTQXcsUnG3Ox36Bog7rh16ZMlJykYGVgZxneaaPaUEFKrfjPmjKMLgc3OmvwLT8nMQtzgvKeTWjtkRnkgnZsZsIgPe6nwqYCpX2aEJgBd4nkVoLzurbkOWjtkRnY71p67MGoG9b2zK31KWy6AZXRr5cFcAbbIdE6AvJfKCBaVrVEncthWewxZLxBa]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20171006.165328, [[dKdEeaGEss1MiP0UiKEnsAFeQMnsnFb4MsQBl0ovQ9sTBu2Vu(jHidtsghjv9CadwQgobDqLOtbuCmL05ijPfIiwkbwSeTCeEOs4PqpgvRJKetKqyQiXKjA6GUOaDvcrDzvxxqDyrBLKyZaL2ojAzs48KWNfKVlGoTIVHinAe10iP4Kek)fixJKk3dOQNrskJcOYVj1E1umICIri0OXDgVrCIlADrMrwtRqvA9LIuqJco9tG7Dr1kPvQVqvfTQQs9fgrHNpj9O6jC0mVluxHXLC4OzaMI3RMIXGSSK(stIrKtmcHgtoCuEqN94CGwxCW36fgxwo0duHr5tizqjtcsEEQWOym5WtOMWitZUXATuLKyNXB04oJ3OiEcj36jt26I48uHrbN(jW9UOAL01kJcoGomb)aMIHgxq(CQ1ALpEg0LgR1YDgVrd9UWumgKLL0xAsmICIri0yYHJYd6ShNd06I36QX4YYHEGkmEHJ8XHBumMC4jutyKPz3yTwQssSZ4nACNXBmOWr(4Wnk40pbU3fvRKUwzuWb0Hj4hWum04cYNtTwR8XZGU0yTwUZ4nAO3QMPymillPV0Kye5eJqOXKdhLh0zpohO1fh8TErRR2whCTU8jKmOKjbjppvikC4uhwOwpGaAD5b7qFrHdN6Wc16GX4YYHEGkmcW1HjcDqaqIH6nkgto8eQjmY0SBSwlvjj2z8gnUZ4nICDyIqV1riXq9gfC6Na37IQvsxRmk4a6We8dykgACb5ZPwRv(4zqxASwl3z8gn0B1ykgdYYs6lnjgroXieAm5Wr5bD2JZbADXbFRx06QT1bxRlFcjdkzsqYZtfIcho1HfQ1diGwxEWo0xu4WPoSqToymUSCOhOcJC6mWHfcea5uQdeWOym5WtOMWitZUXATuLKyNXB04oJ34c6mWHfQ1rYPuhiGrbN(jW9UOAL01kJcoGomb)aMIHgxq(CQ1ALpEg0LgR1YDgVrd9wDMIXGSSK(stIrKtmcHgtoCuEqN94CGwx8wVW4YYHEGkmEHJ8XHBumMC4jutyKPz3yTwQssSZ4nACNXBmOWr(4WBDWTcgJco9tG7Dr1kPRvgfCaDyc(bmfdnUG85uR1kF8mOlnwRL7mEJgAOrrCWMHPHMedTba]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20171006.165328, [[dSJCmaGEusrBsqTlsSnusH9PQy2s1nLslJs1TjPtJyNOyVk7gY(j1OqjzyQQ(nuhwY5rjgmfdNsCqkPoLQsDmr15uvYcPkzPuflgjlhvpuu6PepwO1jkuMOOGPsPmzQmDvUOaCvrHQNjkKRJuBeLu1wfqBMQA7cKVrj55ImnusPVJsnpusLXrvknAvXFLItkq9zb5AuLI7jk6YGdrvQETQ0lF2MKbWVO738AIybIKQtynRJGrJXU3yFctPcteIAwTjJJEWDwYyAt6kKR4UjEGoujym2)ZT63BT)LY))V3AFIhOCSyJOct40iiPCevO5Wn2NyD8iyuA2gt(Snjaur1b38AIe5el3ehqr77R4dPd4euOg2yAKtjDv8vByDzQn21MWAdNgrInwWSbUId8jrYPnF0gVzI1uKo5yzIpKoGtqHAshN8ctcg5iX6W8jimcM0IDbwCMsfMmHPuHjSEiDaNGcPnYXjVWepqhQemg7)5wL)pXdKW08iKMTDtY(aX3wCqGkGUrnPf7ykvyYUXyF2MeaQO6GBEnrICILBI31gkAFFfee54ejPqBrBcRnx1b0PGGihNijfavuDWPnH1gonc0gwxMAtgnXAksNCSmXb190eXK(KGrosSomFccJGjTyxGfNPuHjtykvysgG6E0MSysFIhOdvcgJ9)CRY)N4bsyAEesZ2UjzFG4Bloiqfq3OM0IDmLkmz3yYOzBsaOIQdU51ejYjwUju0((kiiYXjssH2I2ewBCafTVVIpKoGtqHAyJProL0vXxT5tMAtU2ewB40isSXcMnWvCGpjsoT5J281eRPiDYXYKuetZdbnPJtEHjbJCKyDy(eegbtAXUalotPctMWuQWejIP5HaTroo5fM4b6qLGXy)p3Q8)jEGeMMhH0STBs2hi(2Idcub0nQjTyhtPct2ngw7Snjaur1b38AIe5el3ekAFFfee54ejPqBrBcRnoGI23xXhshWjOqnSX0iNs6Q4R28jtTjxBcRnCAej2ybZg4koWNejN28rB(AI1uKo5yzsSxSjOqnPNYHzNMemYrI1H5tqyemPf7cS4mLkmzctPctY2l2euiTrEkhMDAIhOdvcgJ9)CRY)N4bsyAEesZ2UjzFG4Bloiqfq3OM0IDmLkmz3y8MzBsaOIQdU51ejYjwUju0((k0OhCNLM0XbuO7rH2I2ewBCafTVVIpKoGtqHAyJProL0vXxT5tMAtU2ewB40isSXcMnWvCGpjsoT5J281eRPiDYXYKuetZdbnPJtEHjbJCKyDy(eegbtAXUalotPctMWuQWejIP5HaTroo5f0gwL)9epqhQemg7)5wL)pXdKW08iKMTDtY(aX3wCqGkGUrnPf7ykvyYUXWAmBtcavuDWnVMiroXYnHI23xHg9G7S0KooGcDpk0w0MWAJdOO99v8H0bCckudBmnYPKUk(QnFYuBY1MWAdNgrInwWSbUId8jrYPnF0MVMynfPtowMe7fBckut6PCy2PjbJCKyDy(eegbtAXUalotPctMWuQWKS9InbfsBKNYHzN0gwL)9epqhQemg7)5wL)pXdKW08iKMTDtY(aX3wCqGkGUrnPf7ykvyYUXy1Snjaur1b38AIe5el3eonc0MpzQn21MWAJdOO99v8H0bCckudBmnYPKUk(QnFYuBY1MWAdNgrInwWSbUId8jrYPnF0MVMynfPtowMKIyAEiOjDCYlmjyKJeRdZNGWiysl2fyXzkvyYeMsfMirmnpeOnYXjVG2Wk7FpXd0HkbJX(FUv5)t8ajmnpcPzB3KSpq8TfheOcOButAXoMsfMSBmE7Snjaur1b38AIe5el3eonc0MpzQn21MWAJdOO99v8H0bCckudBmnYPKUk(QnFYuBY1MWAdNgrInwWSbUId8jrYPnF0MVMynfPtowMe7fBckut6PCy2PjbJCKyDy(eegbtAXUalotPctMWuQWKS9InbfsBKNYHzN0gwz)7jEGoujym2)ZTk)FIhiHP5rinB7MK9bIVT4GavaDJAsl2XuQWKDJ5RzBsaOIQdU51ejYjwUjx1b0PKEkhMDdb5tNiyKcGkQo40MWAZvDaDkUI)2uCkYbCfavuDWPnH1gVRnu0((kUI)2C8cL8XC16iyKcTfTjS2eX4UdZgP4k(BtXPihWv4GArqjT5J2K)pXAksNCSmXb190eXK(KGrosSomFccJGjTyxGfNPuHjtykvysgG6E0MSysxByv(3t8aDOsWyS)NBv()epqctZJqA22nj7deFBXbbQa6g1KwSJPuHj7gt()Snjaur1b38AIe5el3KR6a6uspLdZUHG8PtemsbqfvhCAtyTX7AZvDaDkUI)2uCkYbCfavuDWPnH1gVRnu0((kUI)2C8cL8XC16iyKcTLjwtr6KJLjoOUNMiM0NemYrI1H5tqyemPf7cS4mLkmzctPctYau3J2Kft6AdRS)9epqhQemg7)5wL)pXdKW08iKMTDtY(aX3wCqGkGUrnPf7ykvyYUXKNpBtcavuDWnVMiroXYn5QoGofxXFBkof5aUcGkQo40MWAteJ7omBKIR4VnfNICaxHdQfbL0MpAt()eRPiDYXYehu3ttet6tcg5iX6W8jimcM0IDbwCMsfMmHPuHjzaQ7rBYIjDTHvz03t8aDOsWyS)NBv()epqctZJqA22nj7deFBXbbQa6g1KwSJPuHj7gtU9zBsaOIQdU51ejYjwUjExBUQdOtj9uom7gcYNorWifavuDWPnH1gVRnx1b0P4k(BtXPihWvaur1b3eRPiDYXYehu3ttet6tcg5iX6W8jimcM0IDbwCMsfMmHPuHjzaQ7rBYIjDTHvS2VN4b6qLGXy)p3Q8)jEGeMMhH0STBs2hi(2Idcub0nQjTyhtPct2TBIe5el3KDBa]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20171006.165328, [[dSdujaGEvc0Mek7IeBdfvzFKkMTOUPk1Zf52KYPrANO0Ev2nu7NIrHIYWqf)wvpwW5rLAWuA4KQoeksNcfXXGOZPsqlKKYsPIwmKwoIhku9uILrswNkrAIqOMkvyYu10L6IuP6QOOQEgPsxhvTrvcyRuPSzHSDQKUm4WsMMkr9DiyEQeX4qrLrJc)vfDsQeFwL01uj09GqETkCqsQ(gQKhY5yIOhc0ktVGvtF8yvDrvtylnyIq1IBSmFmJpZ9LASHk10Rv)KjoHmujySQ4GKlomNQluHdhomNQjsGq13tMOEOPponhJf5CmXDCHMb)uBIeiu99epGYhfPebPgiu81teEESxj1v4WyVeezSx2yJzSeEmnCQ)raikEiIgOTXQJXQs3jQJsZ0M7jrqQbcfF9m1e6bmXfSNgQ(jtWpgMC)E3kcBPbtMWwAWKlaKAGqXxnwPj0dyItidvcgRkoi5cjNjoH0ZtcqAowpjodiCC)UcAaUh6K73ZwAWK1Jv1CmXDCHMb)uBIeiu99eMASO8rrkyiq(enPWR3yJzSDLbCRGHa5t0KcGl0m4n2yglHhdg7LGiJv3jQJsZ0M7jEOAgNHNMN4c2tdv)Kj4hdtUFVBfHT0GjtylnycIHQzySXFAEItidvcgRkoi5cjNjoH0ZtcqAowpjodiCC)UcAaUh6K73ZwAWK1Jv35yI74cnd(P2ejqO67jO8rrkyiq(enPWR3yJzSEaLpksjcsnqO4RNi88yVsQRWHXQdImwDn2yglHhtdN6FeaIIhIObABS6ySQ0DI6O0mT5Esk88KRWzQj0dyIlypnu9tMGFmm5(9Uve2sdMmHT0Gjs45jxbJvAc9aM4eYqLGXQIdsUqYzIti98KaKMJ1tIZach3VRGgG7Ho5(9SLgmz9yV8CmXDCHMb)uBIeiu99eu(OifEmJpZ9zQja(AZqHxVXgZy9akFuKseKAGqXxpr45XELuxHdJvhezS6ASXmwcpMgo1)iaefperd02y1XyvP7e1rPzAZ9Ku45jxHZutOhWexWEAO6Nmb)yyY97DRiSLgmzcBPbtKWZtUcgR0e6bySmdjtM4eYqLGXQIdsUqYzIti98KaKMJ1tIZach3VRGgG7Ho5(9SLgmz9yV4CmXDCHMb)uBIeiu99ecpgmwDqKXQYyJzSEaLpksjcsnqO4RNi88yVsQRWHXQdImwDn2yglHhtdN6FeaIIhIObABS6ySQ0DI6O0mT5Esk88KRWzQj0dyIlypnu9tMGFmm5(9Uve2sdMmHT0Gjs45jxbJvAc9amwMPIjtCczOsWyvXbjxi5mXjKEEsasZX6jXzaHJ73vqdW9qNC)E2sdMSESmV5yI74cnd(P2ejqO67jDLbCRKyu(hHtkoIprFScGl0m4n2ygBxza3k(ICCweuAdefaxOzWBSXmwMASO8rrk(ICC2KcNIEIw10hRWR3yJzSH)Z(hbSIVihNfbL2arHaAffNmwDmwKxCI6O0mT5EIhQMXz4P5jUG90q1pzc(XWK737wrylnyYe2sdMGyOAggB8NMnwMHKjtCczOsWyvXbjxi5mXjKEEsasZX6jXzaHJ73vqdW9qNC)E2sdMSESCnhtChxOzWp1MibcvFpPRmGBLeJY)iCsXr8j6JvaCHMbVXgZyzQX2vgWTIVihNfbL2arbWfAg8gBmJLPglkFuKIVihNnPWPONOvn9Xk86NOokntBUN4HQzCgEAEIlypnu9tMGFmm5(9Uve2sdMmHT0GjigQMHXg)PzJLzQyYeNqgQemwvCqYfsotCcPNNeG0CSEsCgq44(Df0aCp0j3VNT0GjRhlZnhtChxOzWp1MibcvFpPRmGBfFroolckTbIcGl0m4n2ygB4)S)raR4lYXzrqPnquiGwrXjJvhJf5fNOokntBUN4HQzCgEAEIlypnu9tMGFmm5(9Uve2sdMmHT0GjigQMHXg)PzJLz6YKjoHmujySQ4GKlKCM4esppjaP5y9K4mGWX97kOb4EOtUFpBPbtwp2lCoM4oUqZGFQnrceQ(Ectn2UYaUvsmk)JWjfhXNOpwbWfAg8gBmJLPgBxza3k(ICCweuAdefaxOzWprDuAM2CpXdvZ4m808exWEAO6Nmb)yyY97DRiSLgmzcBPbtqmundJn(tZglZUmtM4eYqLGXQIdsUqYzIti98KaKMJ1tIZach3VRGgG7Ho5(9SLgmz96jigIk(Cp1wVb]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20171006.165328, [[dStwmaGEvjsBsuSlsABQse7tvQzRIBQs9CrUnLCAe7ef7vz3G2pfJcLOHPQ63apwOZJsAWKA4KOdjaDksGJPkohkHfsP0sPkTyKSCu9qrPNsSmQI1PkHmrbWuPunzQmDPUOa6QQsOEMQKUosTrsqARcKntvTDbQVrcDyjttvI67OuZJeeJJeuJwL8xr1jfu(SGCnvj4EcQUm0RvvoiLI3ZSpruIrsDiV0Qja4y88cEMWuw4eHyL1OFXWlWH1xKrtGPMthBapnXlEWkHJXZ)JI)kShwO())RWEMirorzpzInXMaGPzFmpZ(KaHf1bDZ2jsKtu2tCifTVVQpMAKtGHYzdOHo1uxXpJwHeUr7XOZy0CAijMReWg5Qo0NejTr)2OFHj2qroKM1j(yQrobgkp1CYhojmOJeRgWNabqCYnWfuXzklCYeMYcNOqXuJCcmKrlnN8Ht8IhSs4y88)O4Z)eVycqZJyA2xpj7fg)UbbJwiSh1KBGJPSWjRhJNzFsGWI6GUz7ejYjk7jb0OPO99vHyKdsKKkTsJoJr31bHTkeJCqIKuryrDqNrNXO50q0OviHB0VoXgkYH0SoXHvFLhbKZKWGosSAaFceaXj3axqfNPSWjtyklCsaWQVm6SaYzIx8GvchJN)hfF(N4ftaAEetZ(6jzVW43niy0cH9OMCdCmLfoz9yED2NeiSOoOB2orICIYEcfTVVkeJCqIKuPvA0zmAhsr77R6JPg5eyOC2aAOtn1v8ZOFhUr)QrNXO50qsmxjGnYvDOpjsAJ(TrZIj2qroKM1jPiGMhcZtnN8Htcd6iXQb8jqaeNCdCbvCMYcNmHPSWjseqZdHgT0CYhoXlEWkHJXZ)JIp)t8IjanpIPzF9KSxy87gemAHWEutUboMYcNSEmV8SpjqyrDq3SDIe5eL9ekAFFvig5GejPsR0OZy0oKI23x1htnYjWq5Sb0qNAQR4Nr)oCJ(vJoJrZPHKyUsaBKR6qFsK0g9BJMftSHICinRtINInbgkpDvoa70KWGosSAaFceaXj3axqfNPSWjtyklCs2tXMadz0Yv5aStt8IhSs4y88)O4Z)eVycqZJyA2xpj7fg)UbbJwiSh1KBGJPSWjRhZlm7tcewuh0nBNirorzpHI23xLgEboSMNAocd1xQ0kn6mgTdPO99v9XuJCcmuoBan0PM6k(z0Vd3OF1OZy0CAijMReWg5Qo0NejTr)2OzXeBOihsZ6KueqZdH5PMt(WjHbDKy1a(eiaItUbUGkotzHtMWuw4ejcO5HqJwAo5dnAw(OGjEXdwjCmE(Fu85FIxmbO5rmn7RNK9cJF3GGrle2JAYnWXuw4K1J5Lm7tcewuh0nBNirorzpHI23xLgEboSMNAocd1xQ0kn6mgTdPO99v9XuJCcmuoBan0PM6k(z0Vd3OF1OZy0CAijMReWg5Qo0NejTr)2OzXeBOihsZ6K4PytGHYtxLdWonjmOJeRgWNabqCYnWfuXzklCYeMYcNK9uSjWqgTCvoa7KrZYhfmXlEWkHJXZ)JIp)t8IjanpIPzF9KSxy87gemAHWEutUboMYcNSEmko7tcewuh0nBNirorzpHtdrJ(D4gThJoJr7qkAFFvFm1iNadLZgqdDQPUIFg97Wn6xn6mgnNgsI5kbSrUQd9jrsB0VnAwmXgkYH0Sojfb08qyEQ5KpCsyqhjwnGpbcG4KBGlOIZuw4KjmLforIaAEi0OLMt(qJMLEuWeV4bReogp)pk(8pXlMa08iMM91tYEHXVBqWOfc7rn5g4yklCY6XOWZ(KaHf1bDZ2jsKtu2t40q0OFhUr7XOZy0oKI23x1htnYjWq5Sb0qNAQR4Nr)oCJ(vJoJrZPHKyUsaBKR6qFsK0g9BJMftSHICinRtINInbgkpDvoa70KWGosSAaFceaXj3axqfNPSWjtyklCs2tXMadz0Yv5aStgnl9OGjEXdwjCmE(Fu85FIxmbO5rmn7RNK9cJF3GGrle2JAYnWXuw4K1JHfZ(KaHf1bDZ2jsKtu2t66GWwnDvoa7Cc0Noraqvewuh0z0zm6UoiSvDf)lV4uKg5QiSOoOZOZy0b0OPO99vDf)lV5fm5d4wvtaqvALgDgJocahhGnu1v8V8ItrAKRYrRIatg9BJ(5FInuKdPzDIdR(kpciNjHbDKy1a(eiaItUbUGkotzHtMWuw4KaGvFz0zbKJrZYhfmXlEWkHJXZ)JIp)t8IjanpIPzF9KSxy87gemAHWEutUboMYcNSEmp)Z(KaHf1bDZ2jsKtu2t66GWwnDvoa7Cc0Noraqvewuh0z0zm6aA0DDqyR6k(xEXPinYvryrDqNrNXOdOrtr77R6k(xEZlyYhWTQMaGQ0kNydf5qAwN4WQVYJaYzsyqhjwnGpbcG4KBGlOIZuw4KjmLfojay1xgDwa5y0S0JcM4fpyLWX45)rXN)jEXeGMhX0SVEs2lm(DdcgTqypQj3ahtzHtwpMNNzFsGWI6GUz7ejYjk7jDDqyR6k(xEXPinYvryrDqNrNXOJaWXbydvDf)lV4uKg5QC0QiWKr)2OF(Nydf5qAwN4WQVYJaYzsyqhjwnGpbcG4KBGlOIZuw4KjmLfojay1xgDwa5y0S8vfmXlEWkHJXZ)JIp)t8IjanpIPzF9KSxy87gemAHWEutUboMYcNSEmpEM9jbclQd6MTtKiNOSNeqJURdcB10v5aSZjqF6ebavryrDqNrNXOdOr31bHTQR4F5fNI0ixfHf1bDtSHICinRtCy1x5ra5mjmOJeRgWNabqCYnWfuXzklCYeMYcNeaS6lJolGCmAw(YkyIx8GvchJN)hfF(N4ftaAEetZ(6jzVW43niy0cH9OMCdCmLfoz96jba9l6tpBxVba]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20171006.165328, [[de0Hxaqiev2KuPprvsLrHiDkeXUOIHHQCmrSmsvpJQennQs4AikSnQskFJe14KkIZjvuRJQKQMhIIUhIs7JQKCqsKfsc9qsLMiIQuxKuXgPQkFervYiLksNKQu3uQANOYpruflLu8uktLuARuv5Ruvv2RYFPsdMOddSyeESOMmixw1MLsFMQYOrvDAuEnvXSf62GA3q9BidxkooIQA5i9CbtxY1jPTls9DsW5fjRNQQQ5lvy)eEjt7mltzn1SzCa4pZyW6kK(JIcLxVq674tz5zK3VfOgRP4mnpEq4JtpVeL51j67SdpE86e9Z0CaukTm4pJCfiEC50srHkKtv8VZXaI4Hesagsi5jKiQqsO2264HfJmSpxyqMpdFh6HbmCyMs5IHWHPDCjt7mDWaI4HMIZSmL1uZkKpFX7KrOiesbCqi7kKKkKKkKKtilq84YPLI8)JDBuJH7CmGiEiHSJoessfsQk(cjzkK6fYUcjvfZYUnifo1jRsPhxcjzkK67eHKeHKeHSRqsoHSaXJlhFGI)PmSp3qHOWohdiIhsijzMseSiRsndrez1PGIHWZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pJ8qez1PGIHWZ084bHpo98suoH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXPFANPdgqep0uCMLPSMAgHABRdlNYTareo4qpmGHdcjzkKjoKHq2vilq84YHLt5wGichCogqep0mLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZNP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJZlN2z6GbeXdnfNzzkRPMvG4XLtGpOQtzyFUHIY88GZXaI4HeYUcj0juBBDOa)hrz57ekq2JqswHKmMPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqsAcjZ084bHpo98suoH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QX5ft7mDWaI4HMIZSmL1uZivijuBBDOm47O2iKDfYt(QSMMd50CA4PpfGZ3f16w8V7jqyxyaTsrfYUcj5essfsc12wherKvNckgc7O2iKDfsqUyPV7XhM9GqsMcPEHKeHKeHSJoeYcepUC8bk(NYW(CdfIc7CmGiEOzkrWISk1m6Hr0WJpeCvGHRtN5ngILbfIodJWFwpcYpaLda)zZ4aWFMMdJOHhFiiK(hdxNotZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRghzmTZ0bdiIhAkoZYuwtnJqTT1HYGVJAJq2vijNqsQqsO226GiIS6uqXqyh1gHSRqcYfl9Dp(WShesYui1lKKiKDfsYjKKkKN8vznnhYP50WtFkaNVlQ1T4F3tGWUWaALIkKDfYcepUC8bk(NYW(CdfIc7CmGiEiHKKzkrWISk1m(ifImSpxIiiuZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pRtrkezyFcPIrqOMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJZRnTZ0bdiIhAkoZYuwtnJqTT1HYGVJAJq2vijNqsQqsO226GiIS6uqXqyh1gHSRqcYfl9Dp(WShesYui1lKKiKDfYt(QSMMd50CA4PpfGZ3f16w8V7jqyxyaTsrfYUczbIhxo(af)tzyFUHcrHDogqepKq2vijviHoHABRtZPHN(uaoFxuRBX)UNaHDHb0kf1rTri7OdHmJqriKcyh6Hr0WJpeCvGHRtDOhgWWbH0ResVuijzMseSiRsnJpsHid7ZLicc1mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z6uKcrg2NqQyeekHK0esMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJt5PDMoyar8qtXzwMYAQzKtijuBBDqerwDkOyiSJAJq2vijvip5RYAAoKJhuSyuqWfFfArQyixfyXOq2vilq84YPLI8)JDBuJH7CmGiEiHSRqsQqgE5sGWQbNIDAsND13KfsYkKjczhDiKHxUeiSAWPyNM0zxVOjlKKvitessesseYo6qiPQ4hCkg8DlKlziKKPq6ldntjcwKvPMHiIS6uq9zEJHyzqHOZWi8N1JG8dq5aWF2moa8NrEiIS6uq9zAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB146KPDMoyar8qtXzwMYAQzfYNV4DYiuecPaoiKDfssfssfYt(QSMMd5Kr4aIwb3mkc5Mr0lKD0HqsO2260WIra1f162srHYrTrijri7kKeQTToQy(Oyk3qrp2xX3rTri7kKqNqTT1Hc8FeLLVtOazpcjzfsYqi7kKKtijuBBDqerwDkOyiSJAJqsYmLiyrwLAwGHHOaFOai42QstnZBmeldkeDggH)SEeKFakha(ZMXbG)mJHHOaFOaWRliK(tLMAMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUopTZ0bdiIhAkoZYuwtnJQIzz3gKcN6a9wwMvcjzswHmH3mLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZfss1tYmnpEq4JtpVeLt4ntZdivA(HPD1mD5)SNEu6dFCnIz9iioa8NTACj8M2z6GbeXdnfNzzkRPMrO226GiIS6uqXqyh1gHSRqsoHKqTT1XdlgzyFUWGmFg(oQnZuIGfzvQzTuuOCdfL55Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOesROmpxij1ljzMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUKKPDMoyar8qtXzwMYAQzGCXsF3Jpm7bH0RiRqQxi7kKKtijvilq84YPLIcviNQ4FNJbeXdjKDfsc12whpSyKH95cdY8z47O2iKDfsqUyPV7XhM9Gq6vKvi1lKKmtjcwKvPMrpmIgE8HGRcmCD6mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z0Cyen84dbH0)y46uHK0esMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlr)0othmGiEOP4mltzn1mc12whpSyKH95cdY8z47O2iKDfssfsYjKN8vznnhYXdkwmki4IVcTivmKRcSyui7OdHeKlw67E8HzpiKEfzfs9cjjZuIGfzvQzTuuOc5uf)pZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHkKtv8)mnpEq4JtpVeLt4ntZdivA(HPD1mD5)SNEu6dFCnIz9iioa8NTACjE50othmGiEOP4mltzn1mqUyPV7XhM9Gq6vKvi1ptjcwKvPM5lcYmq0faLgGZFM3yiwgui6mmc)z9ii)auoa8NnJda)zKxrqMbIcPsqPb48NP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlXlM2z6GbeXdnfNzzkRPMbYfl9Dp(WShesVIScPxotjcwKvPM1srHkKtv8)mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffQqovX)cjPjKmtZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgxczmTZ0bdiIhAkoZYuwtnJqTT1XdlgzyFUWGmFg(oQnZuIGfzvQziIiRofuFM3yiwgui6mmc)z9ii)auoa8NnJda)zKhIiRofuxijnHKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s8At7mDWaI4HMIZSmL1uZkq84YXhO4Fkd7ZnuikSZXaI4HeYUczbIhxoWQuOtrQb332YYSJZPCogqepKq2vijvidVCjqy1GtXonPZU6BYcjzfYeHSJoeYWlxcewn4uStt6SRx0KfsYkKjcjjZuIGfzvQzTuuOCdfL55Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOesROmpxij1lizMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUeLN2z6GbeXdnfNzzkRPMrQqwG4XLdFef7IADvGHRtDogqepKq2rhczbIhxo8vX(oLH95svX3vHdAqyNJbeXdjKKiKDfssfYWlxcewn4uStt6SR(MSqswHmri7OdHm8YLaHvdof70Ko76fnzHKSczIqsYmLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZfssjdsMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlPtM2z6GbeXdnfNPeblYQuZqerwDkO(mVXqSmOq0zye(Z6rq(bOCa4pBgha(ZiperwDkOUqsQEsMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlPZt7mDWaI4HMIZuIGfzvQz(IGmdeDbqPb48N5ngILbfIodJWFwpcYpaLda)zZ4aWFg5veKzGOqQeuAaoFHK0esMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJtpVPDMoyar8qtXzwMYAQzKtijuBBD4RI9Dkd7ZLQIVRch0GWoQnZuIGfzvQz8ruSlQ1vbgUoDM3yiwgui6mmc)z9ii)auoa8NnJda)zDkIIfsuRq6FmCD6mnpEq4JtpVeLt4ntZdivA(HPD1mD5)SNEu6dFCnIz9iioa8NTAC6tM2z6GbeXdnfNPeblYQuZAPOq5gkkZZN5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqjKwrzEUqsQxJKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB140RFANPdgqep0uCMLPSMAwH85lENmcfHqkGdZuIGfzvQzhUbPWPUuv8Dv4GgeEM3yiwgui6mmc)z9ii)auoa8NnJda)z6a3Gu4uHuJk(cP)DqdcptZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgNEVCANPdgqep0uCMLPSMAwH85lENmcfHqkGdczxHKuHKCcjHABRdFvSVtzyFUuv8Dv4Gge2rTrijzMseSiRsnJVk23PmSpxQk(UkCqdcpZBmeldkeDggH)SEeKFakha(ZMXbG)Sovf77ug2NqQrfFH0)oObHNP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvRMznpZarM)dkgcpo9KrYQna]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20171006.165328, [[dOtwgaGEIu2evs1UOsTnijAMQenBQ6Ma62c9Cu2juTxPDdA)cgfrQggK63koTQESkgSidxu6GqPtrLKJbW5GKulev0sHIfJQwoHhkQEkYYikRtumrIkMkrmzGMoLlsL48ejpdssUoeTrQOTsfSziX2jQ6ZOsFdvyAujL5bjH)QsDyLgneACqs1jPc9DiPCnIkDpvclsL0Lj9Ai4cOskrhXN1kvcFJAj6J5HKtXWSmHeOIYI0BLOS65x)lT1(bwCzYfqjmQxxMwCzObWbAuxgQ2nA0OrDzLWOlOus(OwsGe(N7SdQPc3OSEp72MBzCuc7X(bYQKIdOsk5cC59ky5SeDeFwRKnC56v3p0uHazwJvcl)7FtQsXhcEJIqvPPLCec(N1grj4a1sahqhwb(g1sLW3Owc4dbdjNcvLMwcJ61LPfxgAaCaaDjmkBqkokRsQvkhr9GaWrEnQqR8LaoG4BulvR4YQKsUaxEVcwolHL)9VjvPZ6937X(bE7FMvYri4FwBeLGdulbCaDyf4BulvcFJAP817djSh7hyiD5ZSsyfCzLGBuV4k9X8qYPyywMqkxoSRLWOEDzAXLHgahaqxcJYgKIJYQKALYrupiaCKxJk0kFjGdi(g1s0hZdjNIHzzcPC5WQvCuvLuYf4Y7vWYzj6i(SwjB9k0CZl01q8Eq5M9qqXYDyRBfU8EfmKC9q6mJhCqnOBEHUgI3dk3ShckwUdBDl04(qwiHkcjaYTew(3)MuLeiH37X(bE7FMvkhr9GaWrEnQqR8LaoGoSc8nQLkHVrTegKWqc7X(bgsx(mRewbxwj4g1lUsFmpKCkgMLjK4hwiLDg)d5ETeg1RltlUm0a4aa6syu2GuCuwLuRKJqW)S2ikbhOwc4aIVrTe9X8qYPyywMqIFyHu2z8pKBTI7AvsjxGlVxblNLOJ4ZALahZnVqxdX7bLB2dbfl3HTUT)GWd5wcl)7FtQscKW79y)aV9pZkLJOEqa4iVgvOv(sahqhwb(g1sLW3OwcdsyiH9y)adPlFMfsshGRkHvWLvcUr9IR0hZdjNIHzzcj(Hfs2Fq4HCVwcJ61LPfxgAaCaaDjmkBqkokRsQvYri4FwBeLGdulbCaX3OwI(yEi5ummltiXpSqY(dcpKBTIl3kPKlWL3RGLZs0r8zTs8irbf3dV)nvS2pq3iZwcl)7FtQscKW79y)aV9pZkLJOEqa4iVgvOv(sahqhwb(g1sLW3OwcdsyiH9y)adPlFMfssxMRkHvWLvcUr9IR0hZdjNIHzzcPH3)Mkw7h41syuVUmT4YqdGdaOlHrzdsXrzvsTsocb)ZAJOeCGAjGdi(g1s0hZdjNIHzzcPH3)Mkw7hyTIJkRKsUaxEVcwolHL)9VjvPZ6937X(bE7FMvYri4FwBeLGdulbCaDyf4BulvcFJAP817djSh7hyiD5ZSqs6aCvjScUSsWnQxCL(yEi5ummltiXSfcUcWRLWOEDzAXLHgahaqxcJYgKIJYQKALYrupiaCKxJk0kFjGdi(g1s0hZdjNIHzzcjMTqWvawRwj5OOSi9w5Swl]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20171006.165328, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEnLuLXwzHnxzE5KmWeZnWGJm54cmWadoY41utnMCPbhDEnLxtf0y0L2BUnNxu5LtX4fvEnvrUfMySvgzEjKxtn1yYLgC051u092zNXwzUa3B0L2BUnNxtfKyPXwA0LNxtb3B0L2BU51uj5gzPnwy09MCEnLBV5wzEnvtVrMvHjNtH1wzEnLxt5uyTvMxtb1B0L2BU51usvgBLf2CL5LtYatm3edmEnLuLn3B1j3yLnNxu5fDEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxt5fDErNxtruzMfwDSrNxc5fDE5f]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20171006.165328, [[deebnaqisvztur(KsfYOOs5uuPAxsYWqIJPKwgvYZuQGPPuP6AOsPTPuP4BijJtPsohQuyDOsvnpLk6EOsv2hvu6GOswisQhskmrLkLUiPOnsfvFuPc1ijvvDssPUPuANG6NKQklfv8uIPIQARKQ8vuPYEf)vPmykoSQwmIESunzqUm0MLIpJQmAsLttYRPcZMQUnc7g43kgUsCCuPOLJYZLy6QCDKA7kv9DjvNxsz9urX8jLSFkDwd)isNPwUirGFcmIOi0WACoBkh33A4vSMt1DOa8ISBXMN2FH6iCqp(fmWUOSsfLD5IBurHcLD5kch8HQXxrGriPBAQ0rd4HmfG3gJgGB1XFzavmK4vGseU6NAaLWpWRHFenbpPhHc1rKotTCriPBAQu9AB37hqPIHeVcuSMDAnRvCR14K1CVhbxLQxB7E)akvi4j9iueUivE1vlsdBk3w5ykhyeTbqQ(FdlcyayK2bsVNb)eyKiWpbgX5SPCwJCmLdmch0JFbdSlkRuTsjchSm0Sowc)Cr0qh2D0o7rceCHms7ab)eyKCb2v4hrtWt6rOqDeUivE1vlcdjgwb9yPSvxboKfrBaKQ)3WIagagPDG07zWpbgjc8tGr4GedRGESuSgUtboKfHd6XVGb2fLvQwPeHdwgAwhlHFUiAOd7oAN9ibcUqgPDGGFcmsUaVdHFenbpPhHc1rKotTCriPBAQykcSIEXACYA0N14M1qs30unKE1HS)udOIEXACYA((P2JBiajuyXA2P14YACpcxKkV6Qfr3u3Ra82i9F5IOnas1)ByradaJ0oq69m4NaJeb(jWi6)u3Ra8SgQ9F5IWb94xWa7IYkvRuIWbldnRJLWpxen0HDhTZEKabxiJ0oqWpbgjxG39WpIMGN0JqH6isNPwUi3WJNhR6Z4HM6GI14K14M14M1OpR5EpcUQg24miyBH2xWke8KEeYA0slRXnRHrdqRzNwJlRXjRHrdu9TLPoYQ60mgcoRzNwJRDznUBnUBnUhHlsLxD1ImKE1HS)udiI2aiv)VHfbmams7aP3ZGFcmse4NaJOFKE1HS)udich0JFbdSlkRuTsjchSm0Sowc)Cr0qh2D0o7rceCHms7ab)eyKCbMBd)iAcEspcfQJiDMA5IWObO14SwZoynAPL1qs30u5q59kaVnIVRtbWk6fRrlTSgs6MMQH0RoK9NAav0lr4Iu5vxTidPxDi7pmI2aiv)VHfbmams7aP3ZGFcmse4NaJOFKE1HS)WiCqp(fmWUOSs1kLiCWYqZ6yj8ZfrdDy3r7ShjqWfYiTde8tGrYf4Dt4hrtWt6rOqDePZulxKB4XZJv9z8qtDqXACYACZACZAqUjTAzbHQ6dOmSRS1hp0wFyO1OLwwdjDtt1IY7F220S1WMYvrVynUBnoznK0nnv0aDJV2w5yiG3PRIEXACYAGqs6MMk27mdt1XQY9Dhwd3ZA4wRXjRrFwdjDtt1q6vhY(tnGk6fRX9iCrQ8QRwKIcaXEEt5lBn0SAr0gaP6)nSiGbGrAhi9Eg8tGrIa)eyerbGypVP87OI14CAwTiCqp(fmWUOSs1kLiCWYqZ6yj8ZfrdDy3r7ShjqWfYiTde8tGrYfyQc)iAcEspcfQJiDMA5Iqs30u5q59kaVnIVRtbWk6fRXjRXnRrFwdYnPvlliuLJXFk2x2ay9MHgaTvx59wJwAzn37rWvX7pDitb4TvUHruHGN0JqwJwAznF)u7XneGekSynol3ZACznUhHlsLxD1I0WMYv61oDyeTbqQ(FdlcyayK2bsVNb)eyKiWpbgX5SPCLETthgHd6XVGb2fLvQwPeHdwgAwhlHFUiAOd7oAN9ibcUqgPDGGFcmsUaVRWpIMGN0JqH6isNPwUimAGQVTm1rwvNMXqWznoR1SlkwJwAznUznK0nnvdPxDi7p1aQOxSgNSg9znK0nnvouEVcWBJ476uaSIEXACpcxKkV6QfPHnLBRCmLdmI2aiv)VHfbmams7aP3ZGFcmse4NaJ4C2uoRroMYbAnUT6EeoOh)cgyxuwPALseoyzOzDSe(5IOHoS7OD2Jei4czK2bc(jWi5cm3i8JOj4j9iuOocxKkV6Qfzi9Qdz)Hr0gaP6)nSiGbGrAhi9Eg8tGrIa)eye9J0RoK9hAnUT6EeoOh)cgyxuwPALseoyzOzDSe(5IOHoS7OD2Jei4czK2bc(jWi5c8kLWpIMGN0JqH6isNPwUimAGQVTm1rwvNMXqWzn70AOII14K1OpRHKUPPshnGhYuaEBmAaUvh)LburVeHlsLxD1IOByGTPzRUcCilI2aiv)VHfbmams7aP3ZGFcmse4NaJO)ddyntJ1WDkWHSiCqp(fmWUOSs1kLiCWYqZ6yj8ZfrdDy3r7ShjqWfYiTde8tGrYf411WpIMGN0JqH6iCrQ8QRweE(VRE)2dT)bDmI2aiv)VHfbmams7aP3ZGFcmse4NaJSJ9Fx9ERHlO9pOJr4GE8lyGDrzLQvkr4GLHM1Xs4NlIg6WUJ2zpsGGlKrAhi4NaJKlWRUc)iAcEspcfQJWfPYRUArAyt52kht5aJOnas1)ByradaJ0oq69m4NaJeb(jWioNnLZAKJPCGwJBUCpch0JFbdSlkRuTsjchSm0Sowc)Cr0qh2D0o7rceCHms7ab)eyKCbEDhc)iAcEspcfQJiDMA5ICdpEESQpJhAQdkwJtwJBwJ(Sgs6MMkD0aEitb4TXOb4wD8xgqf9I14EeUivE1vlIoAapKPa82y0aCRo(ldiI2aiv)VHfbmams7aP3ZGFcmse4NaJO)0aEitb4znCObO1WD4VmGiCqp(fmWUOSs1kLiCWYqZ6yj8ZfrdDy3r7ShjqWfYiTde8tGrYf41Dp8JOj4j9iuOoI0zQLlYn845XQ(mEOPoOeHlsLxD1IGeltDKTXOb4wD8xgqeTbqQ(FdlcyayK2bsVNb)eyKiWpbgrtILPoYSgo0a0A4o8xgqeoOh)cgyxuwPALseoyzOzDSe(5IOHoS7OD2Jei4czK2bc(jWi5YfrwWU69kN5p1acSlUDnxc]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20171006.165328, [[deeDsaqisfTjOQ(eurvJcQYPGkTkOI0UOIHHkoguSmj0ZKiAAKkCnjs2gur8nuvghur5CcIADqfvMNePUhub7JQIdsvQfsQ0dPkzIqfsxKQkBuIWiHkuNKQQUjuANe6NccTuQupLYuPk2kvL(QGG9Q6VKYGr5WqwmbpwstwrxgSzuPptLmAsvNMOxlOMTq3wHDJ43snCuLJliYYv65KmDrxxGTJQQVlbNxIA9qfI5liTFK(yUNBwDL8YB3erd4MjhErzLyBvIZrzcT6gokWffeZR7n3qeqk4If5GHpo4SIHSdhoCWzfV5gqZYEKd42gqKvnEDbyD4IIrLw2A8X5M31u2e19Crm3Zn)iiHimVU3S6k5L3sueiPJSwwlrXMOCacsictkdFktiGlxhzTSwIInr5SWajjkkR0uMR6KYWNYQDhNDbIJWcOuVwZvtjjZf5QviNfgijrrz(qzBabuoPCaAzRPJBEliJYS8nUBRsnvUYWWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUvITvjLz5kdd3CdraPGlwKdg(WW5MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxS49CZpcsicZR7nRUsE5Tefbs64cL6HvsCPPYEhoabjeH5nVfKrzw(2cJEvqeukTcssc7n)jtzfL9EJ0e4g2E6lAfrd42nr0aU5gg9QGiOuuwiijjS3CdraPGlwKdg(WW5MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxSK3Zn)iiHimVU3S6k5L3ec4Y1zLdWjGhLHpLTbeq5KYbOLTMoOSstz4rzUQtkdNszfPmCV5TGmkZY303fIsIlnHisL38NmLvu27nstGBy7PVOvenGB3erd4goUleLexuMUrKkV5gIasbxSihm8HHZn3GQd2kOUNN38spudJT5hgajVWnS9uenGBpVOoUNB(rqcryEDVz1vYlVTbeq5KYbOLTgoHYknL5QoPm8PmDszjkcK0Xfk1dRK4stL9oCacsicZBEliJYS8TwiktyrjCZFYuwrzV3inbUHTN(Iwr0aUDtenGBHOquMWIs4MBicifCXICWWhgo3CdQoyRG6EEEZl9qnm2MFyaK8c3W2tr0aU98IL6EU5hbjeH519MvxjV82gqaLtkhGw2A6GYknL5QoPm8Pm8OSA3XzxG4iSak1R1C1usYCrUAfYzHbssuuMpughkl0qPSnGiRA86cW6ud2fijLvAkJpougU38wqgLz5BTquMWIs4M)KPSIYEVrAcCdBp9fTIObC7MiAa3crHOmHfLaLHhgCV5gIasbxSihm8HHZn3GQd2kOUNN38spudJT5hgajVWnS9uenGBpVio5EU5hbjeH519MvxjV82gqKvnEDbyDQb7cKKY8bhOSqUuug(uMcsnHMeOCsjSycznDWRsz(qzCOm8PSA3XzxG4iSak1R1C1usYCrUAfYzHbssuuMpugNBEliJYS8nUBRsnvUYWWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUvITvjLz5kddugEyW9MBicifCXICWWhgo3CdQoyRG6EEEZl9qnm2MFyaK8c3W2tr0aU98I8Dp38JGeIW86EZQRKxEtiGlxNvoaNaEug(ugesbsE8GPdpyva)WIivqR5QL6bnqOjAd0ML3BEliJYS8Tfg9QGiOuAfKKe2B(tMYkk79gPjWnS90x0kIgWTBIObCZnm6vbrqPOSqqssyPm8WG7n3qeqk4If5GHpmCU5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXz3Zn)iiHimVU3S6k5L3ec4Y1zLdWjGhLHpLHhLn70zHrVkickLwbjjH1jL1WsIlkl0qPSA3XzxG4SWOxfebLsRGKKW6SWajjkkZhkZvDszHgkLHhLPtkdcPajpEW0HhSkGFyrKkO1C1s9Ggi0eTbAZYlLHpLPtklrrGKoUqPEyLexAQS3Hdqqcrysz4sz4EZBbzuMLVPVleLexAcrKkV5pzkROS3BKMa3W2tFrRiAa3UjIgWnCCxikjUOmDJivsz4Hb3BUHiGuWflYbdFy4CZnO6GTcQ755nV0d1WyB(HbqYlCdBpfrd42ZlgY3Zn)iiHimVU3S6k5L30jLjeWLRZkhGtapkdFktNugEuwIIajDCHs9WkjU0uzVdhGGeIWKYWNY0jLHhLv7oo7ceNfg9QGiOuAfKKewNfgijrrz(qz4rzUQtkdNszfPmCPSqdLY2acqz(qz6GYWLYWLYWNY2acqz(qzL8M3cYOmlFRfIYewuc38NmLvu27nstGBy7PVOvenGB3erd4wikeLjSOeOm8kI7n3qeqk4If5GHpmCU5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXW5EU5hbjeH519MvxjV8w2UCfbNA3XzxGOOm8Pm8Om8OmiKcK84btNAtu9MkTAhNA1Ebkl0qPmHaUCD4jJr0Q1C14UTkDc4rz4sz4tzcbC56eq03XYAQCbIRuVtapkdFkBccbC56SiCKELvWrLOAykdhOSsrz4tz6KYec4Y1PfIYewukBItapkdFkBdiYQgVUaSo1GDbssz(qzLSuugU38wqgLz5BkjzUixTcP04gSLV5pzkROS3BKMa3W2tFrRiAa3UjIgWntsMlYvRq48kkRebB5BUHiGuWflYbdFy4CZnO6GTcQ755nV0d1WyB(HbqYlCdBpfrd42ZlIbZ9CZpcsicZR7nRUsE5nHaUCDclJrjXL2av1ljGtapkdFkdpktNugesbsE8GPt4oMYfP0iqbUDazQvqgJuwOHszOAk5h0acmKGIY8bhOSIugU38wqgLz5BC3wLQA5upCZFYuwrzV3inbUHTN(Iwr0aUDtenGBLyBvQQLt9Wn3qeqk4If5GHpmCU5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXu8EU5hbjeH519MvxjV82gqKvnEDbyDQb7cKKY8bhOm(4CZBbzuMLVXDBvQPYvggU5pzkROS3BKMa3W2tFrRiAa3UjIgWTsSTkPmlxzyGYWRiU3CdraPGlwKdg(WW5MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxetjVNB(rqcryEDVz1vYlVHQPKFqdiWqckkZhCGYkEZBbzuMLVTWOxfebLsRGKKWEZFYuwrzV3inbUHTN(Iwr0aUDtenGBUHrVkickfLfcssclLHxrCV5gIasbxSihm8HHZn3GQd2kOUNN38spudJT5hgajVWnS9uenGBpVigDCp38JGeIW86EZQRKxEdpkR2DC2fiolm6vbrqP0kijjSolmqsIIYknLHhL5QoPmCkLvKYWLYcnuktiGlxhxOupSsIlnv27WrLOAykdhOmmCOmCPm8PSA3XzxG4iSak1R1C1usYCrUAfYzHbssuuMpu2gqaLtkhGw2A6GYWNYsueiPJluQhwjXLMk7D4aeKqeM38wqgLz5BC3wLAQCLHHB(tMYkk79gPjWnS90x0kIgWTBIObCReBRskZYvggOm8kjU3CdraPGlwKdg(WW5MBq1bBfu3ZZBEPhQHX28ddGKx4g2EkIgWTNxetPUNB(rqcryEDVz1vYlVPtktiGlxNvoaNaEug(ugEuMoPSefbs64cL6HvsCPPYEhoabjeHjLfAOuwT74SlqCwy0RcIGsPvqssyDwyGKefL5dLHhL5QoPmCPmCV5TGmkZY3AHOmHfLWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUfIcrzclkbkdVsI7n3qeqk4If5GHpmCU5guDWwb1988Mx6HAySn)Wai5fUHTNIObC75fXGtUNB(rqcryEDVz1vYlVv7oo7cehHfqPETMRMssMlYvRqolmqsIIY8HYWukkdFkBdiYQgVUaSo1GDbsszLghOm(4qz4tzBabuoPCaAzRvskZhkZvDEZBbzuMLVPVxIwZvRGKKWEZFYuwrzV3inbUHTN(Iwr0aUDtenGB44EjuwZLYcbjjH9MBicifCXICWWhgo3CdQoyRG6EEEZl9qnm2MFyaK8c3W2tr0aU98Iy47EU5hbjeH519MvxjV8wT74SlqCewaL61AUAkjzUixTc5SWajjkkZhkBdiGYjLdqlBnDCZBbzuMLVXDBvQPYvggU5pzkROS3BKMa3W2tFrRiAa3UjIgWTsSTkPmlxzyGYWth4EZnebKcUyroy4ddNBUbvhSvqDppV5LEOggBZpmasEHBy7PiAa3E(8MXdQsuuIJGsztUyXsH55p]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20171006.165328, [[deKPnaqiuvytIsFsqfnksvDksP2ffgMO6yOILrr9muvAAkQQRrkX2uuf9nsvgNGkDofvyDkQiZJus3tqSpuvDqkslKI4Hcsturv4IckBurL(OIkQrQOkDsrWnrv2jj(PGkSusLNs1ufWwfH(kQkAVG)sudgXHrzXK0JfAYq6YQ2SI8zr0OfOtt41IIzRWTHy3i9BLgUiDCbv1YL65uA6sUor2oQuFNuCEfL1lOkZhvY(HAGdeaCfgYb3fiHIjZTxBnNWe11IjLiMrqtcUN(OGneHhRelfumRfoGpp(etAuGjGR7JZShumNZrV8W18CyKNNhUMbx3zOZciqo4QsttgbLOjFlOjLBj6L1Cw6sn6JWeul4MglXsTqaqHdea8WOm1Xrbta3JTiTaVyJtldBqwvVf0KY2QfzU14uM64OyswmPLOIOC6Q5TruQ7tlmrRyY8ZXKSyslrV1OeixUwzZyc)yIzmjlMe3DGUAOghjD18wULOxwZzPl1OpctqTyc)ysoMKftqVQ00KrZcVTfXBylwmdMecMOfmjlMOpMe3DGUAOgb3MkVtYAe06TrFeMGAXe(XKCmHlUWe(atk240Yi42u5DswJGwVnoLPookMOn4MQkgIAg4t9AlzB1Imh8eOOIiR2gC6sp48w0ezTcd5GdUcd5Gp3ETfM4vlYCW19Xz2dkMZ5OhNCW1D7k1XBHaqbEObFmdVL7JCAbQGZBrvyihCOafZqaWdJYuhhfmbCp2I0c8wIkIYPRM3grPUpTWe(dbt4BoMKft0ht0htuLMMmAbYnKsXKSyYdFjrA6rnsFBp3Vz04L3j5k4LV6sLryDnRXeTXeU4ct0htk240YijRc(wqtkBRTrmoLPookMKft0htuLMMm6JST9JBTYAe06TrFeMGAXeTgcMKmIIjCXfMWhyIQ00KrFKTTFCRvwJGwVnKsXeTXeTXeTb3uvXquZaVpY22pU1kRrqR3GNafvez12Gtx6bN3IMiRvyihCWvyihCDhzB7h3AXe(uqR3GR7JZShumNZrpo5GR72vQJ3cbGc8qd(ygEl3h50cubN3IQWqo4qbk8fcaEyuM64OGjG7XwKwGRpMOpM0suruoD182ik19PfMWFiyI5CmjlMyFjRUujRrjEZzoKNFAet4htYXeTXeU4ctAjQikNUAEBeL6(0ct4pemHV5yI2yswmrvAAYOfi3qkfCtvfdrnd8GRMHGMuwDWSf4jqrfrwTn40LEW5TOjYAfgYbhCfgYbFExndbnjMyYGzlW19Xz2dkMZ5OhNCW1D7k1XBHaqbEObFmdVL7JCAbQGZBrvyihCOaL5dbapmktDCuWeW9ylslWTVKvxQK1OeVnNlBonIj8Jj5yswmPLOIOC6Q5Tb6NerrHjAnemHJwWKSyslrpMO1qWe(IjzXevPPjJuXyWA5DsEQxBziLIjzXe(atk240YWgKv1BbnPSTArMBnoLPook4MQkgIAg4t9AlzB1Imh8eOOIiR2gC6sp48w0ezTcd5GdUcd5Gp3ETfM4vlYCmrFoAdUUpoZEqXCoh94KdUUBxPoEleakWdn4Jz4TCFKtlqfCElQcd5GdfOOfia4HrzQJJcMaUhBrAbElrfr50vZBJOu3NwyIwdbtMVwWeU4ctAj6TgLa5Y1kRfmrRysYik4MQkgIAg4R6quVz1bpbkQiYQTbNU0doVfnrwRWqo4GRWqo4Hd1HOEZQdUUpoZEqXCoh94KdUUBxPoEleakWdn4Jz4TCFKtlqfCElQcd5GdfOmpHaGhgLPookyc4ESfPf41Mm54gXDhORgQftYIj6Jj6Jjp8LePPh1iUu72LvoUdu542ht4IlmrvAAYivmgSwENKN61wgsPyI2yswmrvAAYqIgChZKTvFAYkOHukMKftqVQ00KrZcVTfXBylwmdMecMOfmrBWnvvme1mWTckAZsUwMvEsQNbEcuurKvBdoDPhCElAISwHHCWbxHHCWDbfTzjxllCAXK5k1Zax3hNzpOyoNJECYbx3TRuhVfcaf4Hg8Xm8wUpYPfOcoVfvHHCWHcu0dcaEyuM64OGjG7XwKwG3suruoD182a9tIOOWe(dbt4BoMKftAj6TgLa5Y1kZxmHFmjzefCtvfdrnd8GBtL3jzncA9g8eOOIiR2gC6sp48w0ezTcd5GdUcd5GpVBtXKDct4tbTEdUUpoZEqXCoh94KdUUBxPoEleakWdn4Jz4TCFKtlqfCElQcd5GdfOeUqaWdJYuhhfmbCp2I0cCvPPjJmIXqqtkJWIbf0BiLIjzXe9Xe(atE4ljstpQrMDuIMzLPxZ0krrL1igdmHlUWKInoTmsYQGVf0KY2ABeJtzQJJIjCXfMWILG7lF6re3Ij8hcMygt0gCtvfdrnd8PETLnoRcEWtGIkISABWPl9GZBrtK1kmKdo4kmKd(C71w24Sk4bx3hNzpOyoNJECYbx3TRuhVfcaf4Hg8Xm8wUpYPfOcoVfvHHCWHcuMdia4HrzQJJcMaUhBrAbolwcUV8PhrClMWFiyIzWnvvme1mWtoyrbBiZq5MrJh8eOOIiR2gC6sp48w0ezTcd5GdUcd5GpNhSOGnWetr5MrJhCDFCM9GI5Co6XjhCD3UsD8wiauGhAWhZWB5(iNwGk48wufgYbhkqHtoea8WOm1Xrbta3JTiTaNflb3x(0JiUft4pemXm4MQkgIAg49r22(XTwzncA9g8eOOIiR2gC6sp48w0ezTcd5GdUcd5GR7iBB)4wlMWNcA9gt0NJ2GR7JZShumNZrpo5GR72vQJ3cbGc8qd(ygEl3h50cubN3IQWqo4qbkC4abapmktDCuWeW9ylslWBjQikNUAEBG(jruuyc)yIzTGjCXfM0s0Jj8Jj8fCtvfdrnd8vDiQ3S6GNafvez12Gtx6bN3IMiRvyihCWvyih8WH6quVz1Xe95On46(4m7bfZ5C0Jto46UDL64TqaOap0GpMH3Y9roTavW5TOkmKdouGchZqaWdJYuhhfmbCp2I0c8AtMCCJ4Ud0vd1IjzXe9XKwIkIYPRM3grPUpTWeTIj8nhtYIjTe9wJsGC5ALnJj8JjjJOyI2GBQQyiQzGFK0vZB5wIEznNLUuWtGIkISABWPl9GZBrtK1kmKdo4kmKdEyiPRM3yIoj6Xe(8S0LcUUpoZEqXCoh94KdUUBxPoEleakWdn4Jz4TCFKtlqfCElQcd5GdfuG7XwKwGdfaa]] )

    storeDefault( [[SimC Frost: bos generic]], 'actionLists', 20171006.165328, [[deKnsaqisbBcj1NuiLgfuPtbvSkKeAxuXWqIJbfltbEgssMgPqxdjrBdjP8ncY4qsW5ee16qsQmpfIUNcj7JQIdsv0cjf9qQctejPQlsvLnQqyKkKQtsvv3ekTtc9tbblLu1tPmvQsBLQsFvqO9Q6VuPbJQddzXi1JLyYk6YGndv9zsLrtkDAIETGA2cDBjTBe)wQHtGJliYYv65KmDrxxGTtq9Df05vOwVcPy(cs7hLpM79MiQc3mz1dgFeBRsQogNUvmUoGaRSCZeafjkkhnOu2KloGkXCtpebKcU4akyeIcvyqi7qHcfQWGBwzLcYB38SKYMOU3lI5EV5hbrhH518MvwPG8wIIajDKLXUjk2eLdqq0ryY4uZ40b4X7ilJDtuSjkNfQijrX4JKX1vMmo1mEP74ShsCOxaLADB8UkjzUiDTc5Sqfjjkg3hgFdiGYjLvWnBxnEZtAzuMJVHFBv6QYvggU5pzklOS3BKMa3W2tFrRiQc3UjIQWTrSTkzClxzy4MEicifCXbuWiegk30dQoylG6EFEZdTqjm2wyOcK803W2trufU98IdU3B(rq0ryEnVzLvkiVLOiqshDOulSsIoxv2B1bii6imV5jTmkZX3wO2RcIGs5oussyV5pzklOS3BKMa3W2tFrRiQc3UjIQWn9qTxfebLIXdrjjH9MEicifCXbuWiegk30dQoylG6EFEZdTqjm2wyOcK803W2trufU98Iu19EZpcIocZR5nRSsb5n6a84DwzfCceW4uZ4BabuoPScUz7QrgFKmoUmUUYKXPIm(aghNBEslJYC8nT9WOKOZLoIu5n)jtzbL9EJ0e4g2E6lAfrv42nrufUn69WOKOJX1mIu5n9qeqk4IdOGrimuUPhuDWwa19(8MhAHsySTWqfi5PVHTNIOkC75f149EZpcIocZR5nRSsb5TnGakNuwb3SDPAm(izCDLjJtnJRbgprrGKo6qPwyLeDUQS3Qdqq0ryEZtAzuMJV10rzclkHB(tMYck79gPjWnS90x0kIQWTBIOkCleOJYewuc30draPGloGcgHWq5MEq1bBbu37ZBEOfkHX2cdvGKN(g2EkIQWTNxKkV3B(rq0ryEnVzLvkiVTbeq5KYk4MTRgz8rY46ktgNAghxgV0DC2djo0lGsTUnExLKmxKUwHCwOIKefJ7dJtHXdnugFdiYIRGEiSoLGDbsY4JKXfIcJJZnpPLrzo(wthLjSOeU5pzklOS3BKMa3W2tFrRiQc3UjIQWTqGoktyrjW44IbNB6HiGuWfhqbJqyOCtpO6GTaQ795np0cLWyBHHkqYtFdBpfrv42Zls1U3B(rq0ryEnVzLvkiVTbezXvqpewNsWUajzCFgfJhYujJtnJRG0LUjbkNuclMq2vJckmUpmofgNAgV0DC2djo0lGsTUnExLKmxKUwHCwOIKefJ7dJt5MN0YOmhFd)2Q0vLRmmCZFYuwqzV3inbUHTN(IwrufUDtevHBJyBvY4wUYWaJJlgCUPhIasbxCafmcHHYn9GQd2cOU3N38qlucJTfgQajp9nS9uevHBpVOq37n)ii6imVM3SYkfK3OdWJ3zLvWjqaJtnJdHuGuGay6iawfimSisbCB8UPwWfOBIBfT549MN0YOmhFBHAVkickL7qjjH9M)KPSGYEVrAcCdBp9fTIOkC7MiQc30d1EvqeukgpeLKewghxm4CtpebKcU4akyecdLB6bvhSfqDVpV5HwOegBlmubsE6By7PiQc3EErQW9EZpcIocZR5nRSsb5n6a84DwzfCceW4uZ44Y40b4X7SqTxfebLYDOKKW6eiGXdnugV0DC2djolu7vbrqPChkjjSolursIIX9HX1vMmEOHY44Y4AGXHqkqkqamDeaRcegwePaUnE3ul4c0nXTI2C8Y4uZ4AGXtueiPJouQfwjrNRk7T6aeeDeMmoomoo38KwgL54BA7HrjrNlDePYB(tMYck79gPjWnS90x0kIQWTBIOkCB07HrjrhJRzePsghxm4CtpebKcU4akyecdLB6bvhSfqDVpV5HwOegBlmubsE6By7PiQc3EEXq(EV5hbrhH518MvwPG8MgyC6a84DwzfCceW4uZ4AGXXLXtueiPJouQfwjrNRk7T6aeeDeMmo1mUgyCCz8s3XzpK4SqTxfebLYDOKKW6Sqfjjkg3hghxgxxzY4urgFaJJdJhAOm(gqag3hgxJmoomoomo1m(gqag3hgNQU5jTmkZX3A6OmHfLWn)jtzbL9EJ0e4g2E6lAfrv42nrufUfc0rzclkbgh3b4CtpebKcU4akyecdLB6bvhSfqDVpV5HwOegBlmubsE6By7PiQc3EErmuU3B(rq0ryEnVzLvkiVLToDrWP0DC2djkgNAghxghxghcPaPabW0P0evVPYT0XPBPxGXdnugNoapEhbYyeTUnEx8BRsNabmoomo1moDaE8obeTDCSRkxGOl16eiGXPMXNaDaE8olA00RSaoQevcZ4JIXPsgNAgxdmoDaE8onDuMWIsztCceW44CZtAzuMJVPKK5I01kKYfFWo(M)KPSGYEVrAcCdBp9fTIOkC7MiQc3mjzUiDTcnAvm(ic2X30draPGloGcgHWq5MEq1bBbu37ZBEOfkHX2cdvGKN(g2EkIQWTNxedM79MFeeDeMxZBwzLcYB0b4X7ewgJsIo3kQOvsaNabmo1moUmUgyCiKcKceatNWDmLls5sGH47aY0DOmgz8qdLXrLukm4ceOkbfJ7ZOy8bmoo38KwgL54B43wLQY4ulCZFYuwqzV3inbUHTN(IwrufUDtevHBJyBvQkJtTWn9qeqk4IdOGrimuUPhuDWwa19(8MhAHsySTWqfi5PVHTNIOkC75fXm4EV5hbrhH518MvwPG82gqKfxb9qyDkb7cKKX9zumUquU5jTmkZX3WVTkDv5kdd38NmLfu27nstGBy7PVOvevHB3erv42i2wLmULRmmW44oaNB6HiGuWfhqbJqyOCtpO6GTaQ795np0cLWyBHHkqYtFdBpfrv42ZlIHQU3B(rq0ryEnVzLvkiVHkPuyWfiqvckg3NrX4dU5jTmkZX3wO2RcIGs5oussyV5pzklOS3BKMa3W2tFrRiQc3UjIQWn9qTxfebLIXdrjjHLXXDao30draPGloGcgHWq5MEq1bBbu37ZBEOfkHX2cdvGKN(g2EkIQWTNxeJgV3B(rq0ryEnVzLvkiVHlJx6oo7HeNfQ9QGiOuUdLKewNfQijrX4JKXXLX1vMmovKXhW44W4HgkJthGhVJouQfwjrNRk7T6OsujmJpkghdfghhgNAgV0DC2djo0lGsTUnExLKmxKUwHCwOIKefJ7dJVbeq5KYk4MTRgzCQz8efbs6OdLAHvs05QYERoabrhH5npPLrzo(g(TvPRkxzy4M)KPSGYEVrAcCdBp9fTIOkC7MiQc3gX2QKXTCLHbghxQcNB6HiGuWfhqbJqyOCtpO6GTaQ795np0cLWyBHHkqYtFdBpfrv42ZlIHkV3B(rq0ryEnVzLvkiVPbgNoapENvwbNabmo1moUmUgy8efbs6OdLAHvs05QYERoabrhHjJhAOmEP74ShsCwO2RcIGs5oussyDwOIKefJ7dJJlJRRmzCCyCCU5jTmkZX3A6OmHfLWn)jtzbL9EJ0e4g2E6lAfrv42nrufUfc0rzclkbghxQcNB6HiGuWfhqbJqyOCtpO6GTaQ795np0cLWyBHHkqYtFdBpfrv42ZlIHQDV38JGOJW8AEZkRuqER0DC2djo0lGsTUnExLKmxKUwHCwOIKefJ7dJJHkzCQz8nGilUc6HW6uc2fijJpYrX4crHXPMX3acOCszfCZ2LQyCFyCDL5npPLrzo(M2EjUnE3Hssc7n)jtzbL9EJ0e4g2E6lAfrv42nrufUn69sy8gpJhIssc7n9qeqk4IdOGrimuUPhuDWwa19(8MhAHsySTWqfi5PVHTNIOkC75fXi09EZpcIocZR5nRSsb5Ts3XzpK4qVak1624DvsYCr6AfYzHkssumUpm(gqaLtkRGB2UA8MN0YOmhFd)2Q0vLRmmCZFYuwqzV3inbUHTN(IwrufUDtevHBJyBvY4wUYWaJJRgX5MEicifCXbuWiegk30dQoylG6EFEZdTqjm2wyOcK803W2trufU985nQEapkiMxZN)a]] )

    storeDefault( [[SimC Frost: machinegun]], 'actionLists', 20171006.165328, [[diKyyaqisGnjs9jrsLgLuPtjvSkrsv2fPAyKOJjILrkEgcPMgvICnecBdHe(gjvJtKGZHq06ejv18ej6EKG2hvcoijLfsc9qQKMOiPIlsv0gfj5JiKOrIqsNKQs3eb7Ki)uKqlLu6PuMkvPTsvXxfjL9Q6VuXGr6WalgkpwktgQUSYMLQ(mvQrtsonHxtv1Sf62iA3q(nOHlkhNkHwoQEUGPl56e12fv(oc15fvTEQe18PkSFu(j37nja5Uzcsxz0uXHHk1Nrjbnvc0ClJUzzRjarHldkbeDjnerYnTloqyxsJYe1vMcAisDLkvMcAUznUiRUDtTwjGOW9EPK79MNiawC4xXBwJlYQBf0T740BqyehsmkWOPz0UmAxgvbmAbIdv69COlpKtMCmm9HayXHZOE4bJ2Lr5YOXOPKr1WOPzuUms0CYGepUEtMZhQy0uYOAsbgTdJ2HrtZOkGrlqCOs3nOunUa52juqoP(qaS4Wz0o3udtefv(BqSOOghuci6MViCrduq(neeTBeG4(a4saYD7MeGC3srSOOghuci6M2fhiSlPrzI6jkVPDbOmVTW9(6MRQwZpbyUrouDSBeG4saYD71L0CV38ebWId)kEZACrwDdtUVxx0Y7uGief05JeiqbgnLmAIorWOPz0cehQ0fT8oficrb9HayXHFtnmruu5V1ZHHYjuCH)DZxeUObki)gcI2ncqCFaCja5UDtcqUBPIddfJAfx4F30U4aHDjnktupr5nTlaL5TfU3x3Cv1A(jaZnYHQJDJaexcqUBVUerFV38ebWId)kEZACrwDRaXHk9GkqvJlqUDcfx4Fb9HayXHZOPzu8Hj33RZbUmKlAtpuGMFgvHmkrCtnmruu5V1ZHHYjuCH)DZxeUObki)gcI2ncqCFaCja5UDtcqUBPIddfJAfx4FmA3Ko30U4aHDjnktupr5nTlaL5TfU3x3Cv1A(jaZnYHQJDJaexcqUBVUKlDV38ebWId)kEZACrwDRlJ2LrXK7715cYPlNXOPz05IYISSHRNnEy5ghGAZb27uQMZWGihsaVYZz0omQhEWOfiouP7guQgxGC7ekiNuFiawC4mAhgnnJQagTlJIj33RdXIIACqjGiD5mgnnJcALi3CgAKIfy0uYOAy0o3udtefv(B8rc5Hfxi4qSavJFZxeUObki)gcI2ncqCFaCja5UDtcqUBAhjKhwCHaJMAcun(nTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72Rlre37npraS4WVI3SgxKv3WK7715cYPlNXOPzufWODzum5(EDiwuuJdkbePlNXOPzuqRe5MZqJuSaJMsgvdJ2HrtZOkGr7YOZfLfzzdxpB8WYnoa1MdS3PunNHbroKaELNZOPz0cehQ0DdkvJlqUDcfKtQpealoCgTZn1WerrL)MkiXrbYTdweeQB(IWfnqb53qq0UraI7dGlbi3TBsaYDJOcjokqUzufJGqDt7Ide2L0Omr9eL30UauM3w4EFDZvvR5Nam3ihQo2ncqCja5U96sef37npraS4WVI3SgxKv3WK7715cYPlNXOPzufWODzum5(EDiwuuJdkbePlNXOPzuqRe5MZqJuSaJMsgvdJ2HrtZOZfLfzzdxpB8WYnoa1MdS3PunNHbroKaELNZOPz0cehQ0DdkvJlqUDcfKtQpealoCgnnJ2LrXhMCFVE24HLBCaQnhyVtPAoddICib8kpxxoJr9WdgTbHrCiXiD(iH8WIleCiwGQX15Jeiqbg1fyuIMr7Ctnmruu5VPcsCuGC7GfbH6MViCrduq(neeTBeG4(a4saYD7MeGC3iQqIJcKBgvXiiumA3Ko30U4aHDjnktupr5nTlaL5TfU3x3Cv1A(jaZnYHQJDJaexcqUBVUK637npraS4WVI3SgxKv3uaJIj33RdXIIACqjGiD5mgnnJ2LrNlklYYgUUFySeCqWbnI7HYiChIfXiJMMrlqCOsVNdD5HCYKJHPpealoCgnnJ2LrdRCWGi5GEjgpHiD0K1yufYOjmQhEWOHvoyqKCqVeJNqKoUuwJrviJMWODy0omQhEWOCz0c6LGCof0Hiy0uYOUB43udtefv(BqSOOghu7MViCrduq(neeTBeG4(a4saYD7MeGC3srSOOghu7M2fhiSlPrzI6jkVPDbOmVTW9(6MRQwZpbyUrouDSBeG4saYD71LsH79MNiawC4xXBwJlYQBf0T740BqyehsmkWOPz0UmAxgvbmAbIdv69COlpKtMCmm9HayXHZOE4bJ2Lr5YOXOPKr1WOPzuUms0CYGepUEtMZhQy0uYOAsbgTdJ2HrtZOfiouP7guQgxGC7ekiNuFiawC4mAAgftUVxNpsipS4cbhIfOACD5mgTZn1WerrL)gelkQXbLaIU5lcx0afKFdbr7gbiUpaUeGC3Ujbi3TuelkQXbLaIy0UjDUPDXbc7sAuMOEIYBAxakZBlCVVU5QQ18taMBKdvh7gbiUeGC3EDjI8EV5jcGfh(v8M14IS6wbD7oo9gegXHeJcmAAgTlJ2LrNlklYYgUEdIcqEfCAWiUtdYhJ6HhmkMCFVEMigbChyVtphgkD5mgTdJMMrXK771LrQGX8oHIpK7sLUCgJMMrXhMCFVoh4YqUOn9qbA(zufYOebJMMrvaJIj33RdXIIACqjGiD5mgTZn1WerrL)wqGW5a3Wai40lZZFZxeUObki)gcI2ncqCFaCja5UDtcqUBMaHZbUHbqQBGrtLmp)nTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72RlLO8EV5jcGfh(v8M14IS6wxgvbmkMCFVoelkQXbLaI0LZy00mkxgjAozqIhxhF9IMOy0uQqgnrjJ2Hr9WdgTlJIj33RdXIIACqjGiD5mgnnJQagftUVx3Vigfi3oKGMkbA6YzmANBQHjIIk)TEomuoHIl8VB(IWfnqb53qq0UraI7dGlbi3TBsaYDlvCyOyuR4c)Jr7QPZnTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72RlLKCV38ebWId)kEZACrwDd0krU5m0iflWOUGczunmAAgvbmAxgTaXHk9EomuHw(s10hcGfhoJMMrXK7719lIrbYTdjOPsGMUCgJMMrbTsKBodnsXcmQlOqgvdJ25MAyIOOYFJpsipS4cbhIfOA8B(IWfnqb53qq0UraI7dGlbi3TBsaYDt7iH8WIley0utGQXz0UjDUPDXbc7sAuMOEIYBAxakZBlCVVU5QQ18taMBKdvh7gbiUeGC3EDPen37npraS4WVI3SgxKv3WK7719lIrbYTdjOPsGMUCgJMMr7YOkGrNlklYYgUUFySeCqWbnI7HYiChIfXiJ6HhmkOvICZzOrkwGrDbfYOAy0o3udtefv(B9CyOcT8LQDZxeUObki)gcI2ncqCFaCja5UDtcqUBPIddvOLVuTBAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxkHOV3BEIayXHFfVznUiRUbALi3CgAKIfyuxqHmQMBQHjIIk)n3rqtaIoa8CauB38fHlAGcYVHGODJae3haxcqUB3KaK7grze0eGiJQgEoaQTBAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxkXLU3BEIayXHFfVznUiRUbALi3CgAKIfyuxqHmkrFtnmruu5V1ZHHk0YxQ2nFr4IgOG8BiiA3iaX9bWLaK72nja5ULkomuHw(s1y0UjDUPDXbc7sAuMOEIYBAxakZBlCVVU5QQ18taMBKdvh7gbiUeGC3EDPeI4EV5jcGfh(v8M14IS6gMCFVUFrmkqUDibnvc00LZUPgMikQ83GyrrnoO2nFr4IgOG8BiiA3iaX9bWLaK72nja5ULIyrrnoOgJ2nPZnTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72RlLquCV38ebWId)kEZACrwDRaXHkD3Gs14cKBNqb5K6dbWIdNrtZOfiouPtkZXhhkhCwFVOjgQLxFiawC4mAAgTlJgw5GbrYb9smEcr6OjRXOkKrtyup8GrdRCWGi5GEjgpHiDCPSgJQqgnHr7Ctnmruu5V1ZHHYjuCH)DZxeUObki)gcI2ncqCFaCja5UDtcqUBPIddfJAfx4FmAxIUZnTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72RlLO(9EZtealo8R4nRXfz1TUmAbIdv6QGCKdS3HybQgxFiawC4mQhEWOfiouPRsg5ECbYTdxgnhIhidI0hcGfhoJ2HrtZODz0WkhmisoOxIXtishnzngvHmAcJ6HhmAyLdgejh0lX4jePJlL1yufYOjmANBQHjIIk)TEomuoHIl8VB(IWfnqb53qq0UraI7dGlbi3TBsaYDlvCyOyuR4c)Jr76sDUPDXbc7sAuMOEIYBAxakZBlCVVU5QQ18taMBKdvh7gbiUeGC3EDPKu4EV5jcGfh(v8M14IS6wbD7oo9gegXHeJcmAAgTlJQagftUVxxLmY94cKBhUmAoepqgePlNXOPzuUmAb9sqoNc6q0mQlWOUB4mAQhJQHrtZOCzKO5KbjEC9MmNpuXOPKr1qemANBQHjIIk)nvYi3JlqUD4YO5q8azq0nFr4IgOG8BiiA3iaX9bWLaK72nja5UruLrUhxGCZOALrJrtTbYGOBAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxkHiV3BEIayXHFfVPgMikQ83GyrrnoO2nFr4IgOG8BiiA3iaX9bWLaK72nja5ULIyrrnoOgJ2vtNBAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxsJY79MNiawC4xXBQHjIIk)n3rqtaIoa8CauB38fHlAGcYVHGODJae3haxcqUB3KaK7grze0eGiJQgEoaQngTBsNBAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxstY9EZtealo8R4nRXfz1nfWOyY996QKrUhxGC7WLrZH4bYGiD5SBQHjIIk)nvqoYb27qSavJFZxeUObki)gcI2ncqCFaCja5UDtcqUBevihXOWEgn1eOA8BAxCGWUKgLjQNO8M2fGY82c37RBUQAn)eG5g5q1XUraIlbi3TxxsJM79MNiawC4xXBQHjIIk)TEomuoHIl8VB(IWfnqb53qq0UraI7dGlbi3TBsaYDlvCyOyuR4c)Jr7seDUPDXbc7sAuMOEIYBAxakZBlCVVU5QQ18taMBKdvh7gbiUeGC3EDjne99EZtealo8R4nRXfz1Tc62DC6nimIdjgfUPgMikQ83gzgK4XD4YO5q8azq0nFr4IgOG8BiiA3iaX9bWLaK72nja5U5jzgK4XzuTYOXOP2azq0nTloqyxsJYe1tuEt7cqzEBH791nxvTMFcWCJCO6y3iaXLaK72Rx3sDwpqowxXx)a]] )

    storeDefault( [[SimC Frost: CDs]], 'actionLists', 20171006.165328, [[duuSqaqiIkTijKytQknkIQoffXUiLHPkoMs1YKGNPQqtdjLUMa02ea5BuKghskoNeszDeO5PQG7ruX(qs1brclKO4HeWevvexuI0gLqmsbqDsb0mfaYnvvTtI8tbagQQIAPc0tPAQuuxvaqBvI4RQksERQIu3vcPAVG)sQgmuhwQfJupwjtwsxg1Mf0NvLgnbDAsEnsYSP0Tj0UH8BrdxPCCbGA5Q8CHMUIRtHTlH67irNNO06LqsZxIA)ig2bZGl1Im4UsuacUixghbjyb(Ki4(gVuTvvu7rLiqQqa3bpiB5oYGuHNDtFOMcfnTNNhQPa4(6uBd4GtXAujkcMbPDWm4LIAAlxbza3xNABa)mqQL(wsjFAvouTudbtD5qWfEi4VeSCj4PTmA0OpUhH6zOEuHQx)MXwJrnTLRGtbTYQgzbVVvJy9jVJrd4bIQQvp5bokrm4)zTK(KArgCWLArgCkUvJyc2CEhJgWdYwUJmiv4z309hWdYX04wCemdd4ciKxu9NfZImAaAW)ZQulYGddivamdEPOM2YvqgW91P2gWR5OrFCpc1Zq9OcvV(nJT2OwuPqVe8xc(mqQL(wsjFAvouTudbtD5qWb8HG)sWNbIj4pqWfaNcALvnYcEFRgX6tEhJgWdevvREYdCuIyW)ZAj9j1Im4Gl1Im4uCRgXeS58ogneS87MaEq2YDKbPcp7MU)aEqoMg3IJGzyaxaH8IQ)SywKrdqd(FwLArgCyaPpcMbVuutB5kid4(6uBd4t((AzTvM2AsjksWFjy5jyAJWqTnL12NEgQhEzC0m2iytaNcALvnYcoTnZQEOXjl4bIQQvp5bokrm4)zTK(KArgCWLArgCzSzwj4IyCYcEq2YDKbPcp7MU)aEqoMg3IJGzyaxaH8IQ)SywKrdqd(FwLArgCyajQfmdEPOM2YvqgW91P2gWN891YARmT1KsuKG)sWYtW0gHHABkRTp9mup8Y4OzSrWMaof0kRAKfCA(I8rLc9cEGOQA1tEGJsed(FwlPpPwKbhCPwKbxg(I8rLc9cEq2YDKbPcp7MU)aEqoMg3IJGzyaxaH8IQ)SywKrdqd(FwLArgCyaPacMbVuutB5kid4uqRSQrwWnISUAyXi4bIQQvp5bokrm4)zTK(KArgCWLArg8aWitWboSye8GSL7idsfE2nD)b8GCmnUfhbZWaUac5fv)zXSiJgGg8)Sk1Im4WasbiWm4LIAAlxbza3xNABa)mqCuBuIS(K6bKG)ab)rc(lblpblxcUMJg9X9iupd1Jku963m2AJArLc9sWLltWNbsT03sk5tBzChJgcM6eCa6HGnbCkOvw1il41RnEfo6zOEmnSrWfqiVO6plMfz0a0G)N1s6tQfzWbxQfzWlVcd7p(XaYC5aSAyrb3P2hQ5HAeuqbfuqbfuW99hbleWcckOGckOGLf(P)KRnEfoeCgsWEAyJf9YclFGtX9gbh1ISCQxB8kC0Zq9yAyJGhKTChzqQWZUP7pGhKJPXT4iyggWdevvREYdCuIyW)ZQulYGddizkyg8srnTLRGmG7RtTnGp57RL12YrLOib)LGLNGPncd12uwBF6zOE4LXrZyJG)sWYtW1C0OpUhH6zOEuHQx)MXwBulQuOxcUCzcM2imulPTQHVEujsZyJGlxMGN2YOrtOb6Lpf6v)mqSoLCVLing10wUsWMqWMaof0kRAKf8TCujc8arv1QN8ahLig8)SwsFsTido4sTid(NZrLiWdYwUJmiv4z309hWdYX04wCemdd4ciKxu9NfZImAaAW)ZQulYGddirnGzWlf10wUcYaUVo12a(0wgnAjTvn81JkrAmQPTCLG)sWYtWRmT1KsKwsBvdF9OsK2XITcfjyQtWfEi4YLj4vM2AsjslPTQHVEujs7yXwHIe8hi49hcUCzcwUe80wgnAQfV6nng10wUsWMaof0kRAKf8nL12NEgQhEzCapquvT6jpWrjIb)pRL0NulYGdUulYG)zL12hbNHeCrUmoGhKTChzqQWZUP7pGhKJPXT4iyggWfqiVO6plMfz0a0G)NvPwKbhgqQObMbVuutB5kid4(6uBd4tBz0OrFCpc1Zq9OcvV(nJTgJAAlxj4Ve8ktBnPePrFCpc1Zq9OcvV(nJT2XDvwc(lbFgi1sFlPKpTLXDmAiyQtWb8bCkOvw1il4BkRTp9mup8Y4aEGOQA1tEGJsed(FwlPpPwKbhCPwKb)ZkRTpcodj4ICzCiy53nb8GSL7idsfE2nD)b8GCmnUfhbZWaUac5fv)zXSiJgGg8)Sk1Im4Was7pGzWlf10wUcYaUVo12a(0wgnA0h3Jq9mupQq1RFZyRXOM2Yvc(lbVY0wtkrA0h3Jq9mupQq1RFZyRDSyRqrcM6em1(aof0kRAKf8nL12NEgQhEzCapquvT6jpWrjIb)pRL0NulYGdUulYG)zL12hbNHeCrUmoeS8fmb8GSL7idsfE2nD)b8GCmnUfhbZWaUac5fv)zXSiJgGg8)Sk1Im4Was77GzWlf10wUcYaUVo12a(0wgnAcnqV8PqV6NbI1PK7TePXOM2YvWPGwzvJSGVPS2(0Zq9WlJd4bIQQvp5bokrm4)zTK(KArgCWLArg8pRS2(i4mKGlYLXHGL)JMaEq2YDKbPcp7MU)aEqoMg3IJGzyaxaH8IQ)SywKrdqd(FwLArgCyaP9cGzWlf10wUcYaUVo12a(KVVwwBLPTMuIIe8xcwEcM2imuBtzT9PNH6HxghnJnc2eWPGwzvJSGtFCpc1Zq9OcvV(nJn4bIQQvp5bokrm4)zTK(KArgCWLArgCzoUhHeCgsWUcvV(nJn4bzl3rgKk8SB6(d4b5yAClocMHbCbeYlQ(ZIzrgnan4)zvQfzWHbK2)iyg8srnTLRGmG7RtTnGZbWgQTnUQTsBvxi33qWFjy5jy5jyAJWqTvAR6c5(gT40lQiyQlhcE)HG)sWYLGPncd1sARA4RhvI0m2iyti4YLj4PVxE0gLiRpPEvXe8hKdb)UQeSjGtbTYQgzbF1wREVgvI0TQ4aUac5fv)zXSiJgGg8)SwsFsTido4sTidUaT1sWuSgvIi4aivCaNI7ncoQfz5uuCLOaeCrUmocsWR0wjyHCFtrb8GSL7idsfE2nD)b8GCmnUfhbZWaEGOQA1tEGJsed(FwLArgCxjkabxKlJJGe8kTvcwi33adiTtTGzWlf10wUcYaUVo12a(KVVwwBLPTMuIIe8xcwEc(mqmbtD5qW7e8xc(mqQL(wsjFAlJ7y0qWuxoeCHhc(lblpblxcEAlJgTWllQmsFZWgzng10wUsWLltWNbIj4pqWfi4YLjyAJWqTnL12NEgQhEzC0owSvOib)b5qW7fiyti4VeS8eSCj4PTmA0E7riFk0RECYtuJrnTLReC5YeSCj4vM2Asjs7yX8ISLJrDkvOHpTJ7QSeSje8xcwEcM2imuBtzT9PNH6HxghnJncUCzcwUe80wgnAQfV6nng10wUsWMqWMaof0kRAKf8K2Qg(6rLiWdevvREYdCuIyW)ZAj9j1Im4Gl1Im4ba0w1WxpQebEq2YDKbPcp7MU)aEqoMg3IJGzyaxaH8IQ)SywKrdqd(FwLArgCyaP9acMbVuutB5kid4(6uBd4t((AzTvM2AsjksWFjy5jy5sW0gHHAcnqV8PqV6NbI1PK7TePzSrWFj4ZaXrTrjY6tQxGGPob)UQe8xc(mqQL(wsjFAlJ7y0qWFGGP2hc2eWPGwzvJSGl0a9YNc9QFgiwNsU3se4bIQQvp5bokrm4)zTK(KArgCWLArg8aSb6Lpf6LGdAGyc(tX9wIapiB5oYGuHNDt3FapihtJBXrWmmGlGqEr1FwmlYObOb)pRsTidomWa(NWHTHDazGbaa]] )

    storeDefault( [[SimC Frost: cold heart]], 'actionLists', 20171006.165328, [[dOZ(eaGErvQnjQSleETOyFQsnBjnFvbDte52OYorv7fA3KSFvgfvHHjHFR06ikLttyWkgUQQdsu1POk1XKOZruQwivjlLQQfJslNupuu6Pcldr9CQmrrvYuPQmzqMoWfvf6Xi9mvbUor2OOkARQISzr2UQOUhvrFxuvMgrH5ru03iQCyPgnk(lOoPQKpRQ01evHZRQyBeLmorv1LPmwI(WGV5mmcbx2BYt96aY2n0TcDdJ1AagXVrfDvK3nqSkKNCEuIHFRATZqEYfLYvKFYYorrrr(jJrq1IFagyipfiwLd9H8LOpmEu1Svdc9cJGQf)amyLsjc6wHGzSwdiCGMM5gpVHCXn5UHvkLiKumB9dSdOn1xadH0)n5UHUBfAZNI4xuRTgEtWj96aeAJRfk3nVVrwyipROkaFWGY0cLdEtWcQHXlfKG2GvJHAvggKwONAnFZzyGbFZzyKLPfk3nB6Mxudd)w1ANH8KlkLRSad)MBL0uZH(qagzzmAgs7ZgNPailgKwi(MZWabipz0hgpQA2QbHEHrq1IFagSsPeXVOwBn8MGt61biK(Vj3nSsPeXVOwBn8MGt61bi0gxluUBK5nFPq3K7gpUHvkLiOBfcMXAnGWbAAMBE75nLL38WhEJh3WkLse0TcbZyTgq4annZnV98MYIBYDJZaWSRsYraeMMCbSm(P38(MIB8(gVXqEwrva(GbLPfkh8MGfudJxkibTbRgd1QmmiTqp1A(MZWad(MZWiltluUB20nVO2nEu6ng(TQ1od5jxukxzbg(n3kPPMd9HamYYy0mK2NnotbqwmiTq8nNHbcq(hG(W4rvZwni0lmcQw8dWGvkLiKumB9dSdOn1xadH0)n5UHvkLiKumB9dSdOn1xadH24AHYDJmV5lf6MC3WkLse0TcbZyTgq4annZnVVPuw3K7g6UvOnFkIFrT2A4nbN0RdqOnUwOC38(gzHH8SIQa8bdktluo4nblOggVuqcAdwngQvzyqAHEQ18nNHbg8nNHrwMwOC3SPBErTB8GS3y43Qw7mKNCrPCLfy43CRKMAo0hcWilJrZqAF24mfazXG0cX3Cggia5Lb6dJhvnB1GqVWiOAXpadwPuIGUviygR1achOPzU5TN3iJBYDdO1FnabqWzWGfgsy3itpV5lfcd5zfvb4dguMwOCWBcwqnmEPGe0gSAmuRYWG0c9uR5Boddm4BodJSmTq5Uzt38IA34Xd8gd)w1ANH8KlkLRSad)MBL0uZH(qagzzmAgs7ZgNPailgKwi(MZWabiaJ8YsTufGEHaeb]] )

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

