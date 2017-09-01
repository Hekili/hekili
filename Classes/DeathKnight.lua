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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170829.000820, [[deK7AaqisvzreQqBsfmksvofPs7Iuggs6yIQLjqptfQPrOsxJuvTnjr9nvsJtuqDorHADIcY8iu19uHSprrhKqzHur9qvIjkjYfjvSrrb8rcvuNKkLzsOcCtvQDIu)KqfzPuHNszQujxvuG2kvQ2RYFLudgLdl1Ir4XImzQ6YGnlOplGrtiNMKxJeZwIBtWUH63qgUk64Icz5e9CHMUQUoI2ovKVlkDEjP1tOcA(sc7hvV85AMLKQZF2m6waMzkHlCwgelcvQMH4SaagKQ0mhqb6im6GuZVsndhmJ1OsLAWJZNzNqs1fL4W(vi8OdQ)GZel9keooxJoFUMPdUjkGFopZss15p7rbcuaTecv8OS4iNDGZ0JZ0hNbzeP68e8A5hFL6v9Zzh4mjjwLQprzbPMhcvj1ZzINZoMkNP7mXiuf1xDMVLuQBjH6b5m3WEvQFKCggHHz3iV7TKUfGzZOBbywLAjfotmjH6b5mhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2p6GZ1mDWnrb8Z5zwsQo)zqgrQopbVw(XxPEv)C2boZdeKHHAHq8bPchOolIe71IFNOWzzEeNvzo7aN9DbWVMVLuQBjH6bPgGBIc4NjgHQO(QZ6tuQlvpJWm3WEvQFKCggHHz3iV7TKUfGzZOBbyMyNOuxQEgHzoGc0ry0bPMFnN6mhqerktqCU2p7Iiir5g5eia4FeZUrE6waMTF0hpxZ0b3efWpNNzjP68N9OabkGwcHkEuwCKZoWz6XzqgrQopbVw(XxPEv)C2botsIvP6tuwqQ5Hqvs9CM45SJPYzh4Secv8OSynFlPu)YghdrsH(viSMeeAfoYzINZcYz6otmcvr9vN5BjL6wsOEqoZnSxL6hjNHryy2nY7ElPBby2m6waMvPwsHZetsOEqYz6LR7mhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2pAXDUMPdUjkGFopZss15p7rbcuaTecv8OS4iNDGZ0JZKKyGZe)rC2XCMUZeJqvuF1zrsbbeUoqldGQwGzUH9Qu)i5mmcdZUrE3BjDlaZMr3cWmJuqaH5mX5wgavTaZCafOJWOdsn)Ao1zoGiIuMG4CTF2frqIYnYjqaW)iMDJ80TamB)O1)CnthCtua)CEMLKQZFgbzyOgjweQuTo(sah4fPrEYzh4mcYWqTeQ4RfbT81IFNOWzzYz5z8mXiuf1xDwsuRWXAuyTkbZCd7vP(rYzyegMDJ8U3s6waMnJUfGzxe1kCKZqHCMBjyMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hDLNRz6GBIc4NZZSKuD(ZEuGafqlHqfpkloYzh4m94miJivNNGxl)4RuVQFo7aNLqOIhLfR5BjL6x24yisk0VcH1KGqRWrot8Cwovo7aNjjXaNj(J4SJ5mDNjgHQO(QZIKcciCDGwgavTaZCd7vP(rYzyegMDJ8U3s6waMnJUfGzgPGacZzIZTmaQAb4m9Y1DMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7h915AMo4MOa(58mljvN)mpqqggQfcXhKkCG6SisSxl(DIcNL5rCwL5SdCwcHkEuwSwFIsDP6ze0KGqRWrot8CM4otmcvr9vNfrKLAj0NGCMByVk1psodJWWSBK39ws3cWSz0TamZqKfoZb0NGCMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hDgEUMPdUjkGFopZss15pZdeKHHAHq8bPchOolIe71IFNOWzzEeNv5zIrOkQV6S(eL6s1ZimZnSxL6hjNHryy2nY7ElPBby2m6waMj2jk1LQNrGZ0lx3zoGc0ry0bPMFnN6mhqerktqCU2p7Iiir5g5eia4FeZUrE6waMTF0z8CnthCtua)CEMLKQZFMKeRs1NOSGuZdHQK65mXZz5uNjgHQO(QZ8q)IQtivzMByVk1psodJWWSBK39ws3cWSz0TamRsq)I4SlivzMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hDo15AMo4MOa(58mljvN)m9XzFxa8R5BjL6wsOEqQb4MOaEo7aNrqggQfj9Eax7ribnYto7aNPpoJGmmuddjjkQIAKNC2botsIbot8hXzhptmcvr9vN5H(fvNqQYm3WEvQFKCggHHz3iV7TKUfGzZOBbywLG(fXzxqQcNPxUUZCafOJWOdsn)Ao1zoGiIuMG4CTF2frqIYnYjqaW)iMDJ80TamB)OZZNRz6GBIc4NZZSKuD(Z(Ua4xZ3sk1TKq9GudWnrb8C2boJGmmuls69aU2JqcAKNC2bolHqfpklwZ3sk1TKq9GutccTch5Sm5m9Zzh4mjjg4mXFeND8mXiuf1xDMh6xuDcPkZCd7vP(rYzyegMDJ8U3s6waMnJUfGzvc6xeNDbPkCMEb1DMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hDEW5AMo4MOa(58mljvN)mpqqggQfcXhKkCG6SisSxl(DIcNjEoRYC2bolHqfpklwRprPUu9mcAsqOv4iNj(J4Skptmcvr9vNfcXhKkCG64lvuGzUH9Qu)i5mmcdZUrE3BjDlaZMr3cWSmaeFqQWb4m7LkkWmhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2p68JNRz6GBIc4NZZSKuD(Z8abzyOwieFqQWbQZIiXET43jkCwMhXzhptmcvr9vNfrKLAj0NGCMByVk1psodJWWSBK39ws3cWSz0TamZqKfoZb0NGKZ0lx3zoGc0ry0bPMFnN6mhqerktqCU2p7Iiir5g5eia4FeZUrE6waMTF05I7CnthCtua)CEMLKQZFMhiidd1IiYsTe6tqQrEYzh4m9XzEGGmmuleIpiv4a1zrKyVg55mXiuf1xDwieFqQWbQJVurbM5g2Rs9JKZWimm7g5DVL0TamBgDlaZYaq8bPchGZSxQOaCME56oZbuGocJoi18R5uN5aIiszcIZ1(zxebjk3iNaba)Jy2nYt3cWS9Jox)Z1mDWnrb8Z5zwsQo)zEGGmmulIil1sOpbPg5jNDGZ8abzyOwieFqQWbQZIiXET43jkCwMhXz5ZeJqvuF1zXeIugaQJVurbM5g2Rs9JKZWimm7g5DVL0TamBgDlaZSeIuga4m7LkkWmhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2p68kpxZ0b3efWpNNzjP68N5bcYWqTiISulH(eKAKNC2boZdeKHHAHq8bPchOolIe71IFNOWzzEeNLptmcvr9vNLkDwfoqDuu7rzJZCd7vP(rYzyegMDJ8U3s6waMnJUfGzxkDwfoaNzIApkBCMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hD(15AMo4MOa(58mXiuf1xDMhcvfyMByVk1psodJWWSBK39ws3cWSz0TamRsqOQaZCafOJWOdsn)Ao1zoGiIuMG4CTF2frqIYnYjqaW)iMDJ80TamB)OZZWZ1mDWnrb8Z5zwsQo)zD6vob1ageuqKZY8iol4mXiuf1xDwQlL6o9keUUOI)m3WEvQFKCggHHz3iV7TKUfGzZOBby2LUu4mXsVcH5mXbQ4ptmzG4mClahjoAkHlCwgelcvQMH4mXeN0rCCMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGzMs4cNLbXIqLQziotmXjD2p68mEUMPdUjkGFopZss15pZdeKHHAHq8bPchOolIe71IFNOWzI)ioliNDGZ0JZ8abzyOwieFqQWbQZIiXET43jkCM4pIZexoRIk4m94mcYWqnIIkGOh81ssmuNf6tewJ8KZQOco77cGFTuhFvG(rsna3efWZz6Yz6Yzh4mjjwLQprzbPMhcvj1ZzzYz6NZoWz6XzssSkvFIYcsnpeQsQNZYKZcEmNvrfCM(4SVla(1sD8vb6hj1aCtuapNP7mXiuf1xDwieFqQWbQJVurbM5g2Rs9JKZWimm7g5DVL0TamBgDlaZYaq8bPchGZSxQOaCMEb1DMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz7hDqQZ1mDWnrb8Z5zwsQo)z6JZiidd1WqsIIQOg5jNDGZ(Ua4xddjjkQIAaUjkGNZoWzssme1ELau)OAXLZYKZcK8ZeJqvuF1zEOFr1jKQmZnSxL6hjNHryy2nY7ElPBby2m6waMvjOFrC2fKQWz6DSUZCafOJWOdsn)Ao1zoGiIuMG4CTF2frqIYnYjqaW)iMDJ80TamB)OdMpxZ0b3efWpNNzjP68NPhNrqggQHHKefvrnYtoRIk4mcYWqnsSiuPAD8LaoWlsJ8KZQOcotsIbolZJ4SGCMUC2boZdeKHHAHq8bPchOolIe71IFNOWzzEeNLZzh4m94mpqqggQfcXhKkCG6SisSxl(DIcNL5rC2XCwfvWz6JZ0JZ(Ua4xl1XxfOFKudWnrb8CwfvWzqgrQopbV2lcQv44ljtpsgRdrKYxuDbIreMZ0LZ0LZoWzssSkvFIYcsnpeQsQNZYKZYyo7aNPhNjjXQu9jkli18qOkPEoltol4XCwfvWz6JZ(Ua4xl1XxfOFKudWnrb8CMUZeJqvuF1zXeIugaQJVurbM5g2Rs9JKZWimm7g5DVL0TamBgDlaZSeIuga4m7LkkaNPxUUZCafOJWOdsn)Ao1zoGiIuMG4CTF2frqIYnYjqaW)iMDJ80TamB)OdgCUMPdUjkGFopZss15ptpoJGmmuddjjkQIAKNCwfvWzeKHHAKyrOs164lbCGxKg5jNvrfCMKedCwMhXzb5mD5SdCMhiidd1cH4dsfoqDwej2Rf)orHZY8iolNZoWz6XzEGGmmuleIpiv4a1zrKyVw87efolZJ4SJ5SkQGZ0hNbzeP68e8AViOwHJVKm9izSoerkFr1figryotxo7aNjjXQu9jkli18qOkPEoltolJNjgHQO(QZsLoRchOokQ9OSXzUH9Qu)i5mmcdZUrE3BjDlaZMr3cWSlLoRchGZmrThLnYz6LR7mhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2p6GhpxZ0b3efWpNNzjP68N9DbWVwuu7rzRv4qYOcH1aCtuapNDGZ(Ua4xZ3sk1TKq9GudWnrb8C2botFCgbzyOMVLuQFzJJHiPq)kewJ8KZoWzjeQ4rzXA(wsPULeQhKAsqOv4iNLjNLR)zIrOkQV6mp0VO6esvM5g2Rs9JKZWimm7g5DVL0TamBgDlaZQe0Vio7csv4m9exDN5akqhHrhKA(1CQZCarePmbX5A)SlIGeLBKtGaG)rm7g5PBby2(rhuCNRz6GBIc4NZZSKuD(Z(Ua4xlkQ9OS1kCizuHWAaUjkGNZoWz6JZ(Ua4xZ3sk1TKq9GudWnrb8C2botFCgbzyOMVLuQFzJJHiPq)kewJ8CMyeQI6RoZd9lQoHuLzUH9Qu)i5mmcdZUrE3BjDlaZMr3cWSkb9lIZUGufotp9R7mhqb6im6GuZVMtDMdiIiLjiox7NDreKOCJCcea8pIz3ipDlaZ2p6G6FUMPdUjkGFopZss15p77cGFnFlPu3sc1dsna3efWZzh4Secv8OSynFlPu3sc1dsnji0kCKZYKZY1)mXiuf1xDMh6xuDcPkZCd7vP(rYzyegMDJ8U3s6waMnJUfGzvc6xeNDbPkCMEvw3zoGc0ry0bPMFnN6mhqerktqCU2p7Iiir5g5eia4FeZUrE6waMTF0bR8CnthCtua)CEMLKQZFM(4SVla(1IIApkBTchsgviSgGBIc45SdCM(4SVla(18TKsDljupi1aCtua)mXiuf1xDMh6xuDcPkZCd7vP(rYzyegMDJ8U3s6waMnJUfGzvc6xeNDbPkCMEx1DMdOaDegDqQ5xZPoZberKYeeNR9ZUicsuUrobca(hXSBKNUfGz73pRsqytw(58(na]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170829.000820, [[dmK6saqiuj0IekvBsOyuOk5uOk6vcLu3cvcSlLyykvhtiltP4zcvMMqPCnsITHQu9nsyCOsY5qLiRdvPmpHQCpsvAFcv1bHclevQhcfnrufUijPnkuIojjYmfkj3ujTtO6NOsqdvOeAPOQEkXuHsxfvsTvsuFvOeSxP)cWGb5WuTys5XanzkUmYMfOptsnAbCAuEnGMTOUnL2TQ(TIHJkooPkwoKNlY0v56cA7kL(oPQopPY6rLO2pOUrfBfbeX4CvQG7wQIWSycdX1FGjRJ3GHmuqpmFv4tzYtuX3ShPyNR2WLw2333exufHdbY8mJl7hB(IVrLnvWa8yZNk2IhvSvu9DTmzk3veqeJZv5g1QZ0c7pcHc5CPkyOXYStxfl7nacIiIltvu6nmq)guLFEQY6yu2r4ULQub3TuLv2BGHILiI4Yuf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6v8nfBfvFxltMYDfbeX4CvqHpdeaNrFcTyOGmq2bdfFyOn7vWqJLzNUkoc0FcWnie9xfLEdd0Vbv5NNQSogLDeUBPkvWDlvbdeO)eme2bHO)QWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhxXwr131YKPCxrarmoxLBuRotlGZKnJ(FQcgASm70vrlpJbqWqKUkk9ggOFdQYppvzDmk7iC3svQG7wQc35zmWqXYqKUk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4XwXwr131YKPCxrarmoxLBuRotlGZKnJ(FQcgASm70vrJqjcbK9QRO0ByG(nOk)8uL1XOSJWDlvPcUBPkCtOeHaYE1v4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvPxXvPyRO67AzYuURGHglZoDvctea2r2ufLEdd0Vbv5NNQSogLDeUBPkvWDlvHRtemKshztv4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvPxX59ITIQVRLjt5UIaIyCUk3OwDMw4mhB(emumWq8cgslmyWLWpWK1biDi6vFbwc5adXZkyOXYStxfoZXMVIsVHb63GQ8ZtvwhJYoc3TuLk4ULQelohB(k8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4kk2kQ(UwMmL7kciIX5QWlyiZClBzOWm9haozxDiTCmqGaoMLaGiRZ(emuSgg6yGabCmlbdfp9cdzMBzldfMP)aWj7QdPfezD2NGH4jmumWqM5w2YqHz6paCYU6qAbrwN9jyO4Pxyi1GMkyOXYStxLj80qKdSIsVHb63GQ8ZtvwhJYoc3TuLk4ULQWfgEAiYbwbdK6uLZrQPdalOE5LzULTmuyM(daNSRoKwogiqahZsaqK1zFkwFmqGaoMLINEnZTSLHcZ0Fa4KD1H0cISo7t8mgZClBzOWm9haozxDiTGiRZ(u80RAqtf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6vCUQyRO67AzYuURiGigNRYnQvNPfWzYMr)pvbdnwMD6Q4iRoatqaxacGHCtfLEdd0Vbv5NNQSogLDeUBPkvWDlvbdKvhm0eeg6cqWq8GCtf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6vCUuXwr131YKPCxrarmoxfspHmoCiZsuCk2vOcmumWqGZKnJ()IXrab4in2rOfezD2NGHIpmueVRsfm0yz2PRIXrabCi)tbhK1p28vu6nmq)guLFEQY6yu2r4ULQub3TufE4iGWqyr(NcoiRFS5RWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhTxSvu9DTmzk3veqeJZvH0tiJdhYSefNIDfQadfdmexeg68m93skGBg9bW(GHj28l07AzYadfdme4mzZO)VyCeqaosJDeAbrwN9jyO4ddPIkvWqJLzNUkghbeWH8pfCqw)yZxrP3Wa9Bqv(5PkRJrzhH7wQsfC3sv4HJacdHf5Fk4GS(XMhgIxr8ScFktEIk(M9ifr7v4tPjebsPITxfmdqGaxNTKL(RAvwhdUBPk9kEuuXwr131YKPCxrarmoxfspHmoCiZsuCk2vOcmumWqNNP)wsbCZOpa2hmmXMFHExltgyOyGHaNjBg9)fJJacWrASJqliY6SpbdfFyO4uPcgASm70vX4iGaoK)PGdY6hB(kk9ggOFdQYppvzDmk7iC3svQG7wQcpCeqyiSi)tbhK1p28Wq8AdpRWNYKNOIVzpsr0Ef(uAcrGuQy7vbZaeiW1zlzP)QwL1XG7wQsVIhTPyRO67AzYuURiGigNRcPNqghoKzjkof7kubgkgyOZrQPB5ywcWnammcgkEWqGZKnJ()IXrab4in2rOfezD2NGH4cGH4QkyOXYStxfJJac4q(NcoiRFS5RO0ByG(nOk)8uL1XOSJWDlvPcUBPk8WraHHWI8pfCqw)yZddXR44zf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6v8O4k2kQ(UwMmL7kciIX5Qq6jKXHdzwIItXUcvGHIbgcCMSz0)xsHw78au7i1JUmTGiRZ(emu8HHI499kyOXYStxfJJac4q(NcoiRFS5RO0ByG(nOk)8uL1XOSJWDlvPcUBPk8WraHHWI8pfCqw)yZddXRyJNv4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvPxXJITITIQVRLjt5UIaIyCUkKEczC4qMLO4uSRqfyOyGH4IWqNNP)wsbCZOpa2hmmXMFHExltgyOyGHaNjBg9)LuO1opa1os9OltliY6SpbdfFyivuPcgASm70vX4iGaoK)PGdY6hB(kk9ggOFdQYppvzDmk7iC3svQG7wQcpCeqyiSi)tbhK1p28Wq8sfEwHpLjprfFZEKIO9k8P0eIaPuX2RcMbiqGRZwYs)vTkRJb3TuLEfpsLITIQVRLjt5UIaIyCUkKEczC4qMLO4uSRqfyOyGHopt)TKc4MrFaSpyyIn)c9UwMmWqXadbot2m6)lPqRDEaQDK6rxMwqK1zFcgk(WqXPsfm0yz2PRIXrabCi)tbhK1p28vu6nmq)guLFEQY6yu2r4ULQub3TufE4iGWqyr(NcoiRFS5HH4fVZZk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4r8EXwr131YKPCxrarmoxfspHmoCiZsuCk2vOcmumWqNJut3YXSeGBayyemu8GHaNjBg9)LuO1opa1os9OltliY6SpbdXfadXvvWqJLzNUkghbeWH8pfCqw)yZxrP3Wa9Bqv(5PkRJrzhH7wQsfC3sv4HJacdHf5Fk4GS(XMhgIxk4zf(uM8ev8n7rkI2RWNsticKsfBVkygGabUoBjl9x1QSogC3sv6v8iffBfvFxltMYDfbeX4Cv4IWqKEczC4qMLO4uSRqfyOyGHqHpbdfp9cdfxfm0yz2PRIXrabCi)tbhK1p28vu6nmq)guLFEQY6yu2r4ULQub3TufE4iGWqyr(NcoiRFS5HH4fxXZk8Pm5jQ4B2JueTxHpLMqeiLk2EvWmabcCD2sw6VQvzDm4ULQ0R4rCvXwr131YKPCxrarmoxfdPfgm4sqkDeI9QbO)e(ML05GaHHINEHHITkyOXYStxfTmtDGJmaqHpbqFY5mFfLEdd0Vbv5NNQSogLDeUBPkvWDlvH7mtDGJmWq8dFcgkwGCoZxHpLjprfFZEKIO9k8P0eIaPuX2RcMbiqGRZwYs)vTkRJb3TuLEfpIlvSvu9DTmzk3veqeJZv58m93IXrab4in2rOf6DTmzGHIbgIdDlB9mqDiaA(DzY6md9lo4X2svWqJLzNUkOWhGdES5bKzPRIsVHb63GQ8ZtvwhJYoc3TuLk4ULQWp8HHWa8yZddfRyPRcgi1PkVBj9g7cZIjmex)bMSoEdgARNbQdf7v4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvrywmHH46pWK1XBWqB9mqDOEfFZEXwr131YKPCxbdnwMD6Qa65mah8yZdiZsxfLEdd0Vbv5NNQSogLDeUBPkvWDlvbtpNHHWa8yZddfRyPRcgi1PkVBj9g7cZIjmex)bMSoEdgsn9eIbg7v4tzYtuX3ShPiAVcFknHiqkvS9QGzace46SLS0FvRY6yWDlvrywmHH46pWK1XBWqQPNqmWE9QWdkOhMVYDVw]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170829.000820, [[dqtgdaGEOsAxueVgbMTuDtQ0TLYofSxYUrA)iYWOWVLmuevnyeA4qQdsrDmQY5Gk0cPclvilgLwUIEOq1tbltbRdQitKI0uvOjtPPR0frqxfQOUSQRJcphkBfQYMPQY2ruEmeFfQGPbvIVdvQdl6ziQmAi50O6Kqv9nHY1OQkNhfnoQQQptv5VurlpnkaqMC0RabHSDbaVfNerCMIQ6mXjserpps1yZvq07pXUcdgEXm8)aoAIHHXa58eaOpcp7CCnxErvyWFdcmJS8IIPrf80OacPjB)w5qaGm5OxbB5Zx)MGUwErXeyML35ltbORLxub4tTCKCRPaArVa3YIxodz7ceeY2fq(A5fvq07pXUcdgEX8meeDSIXe5yAuRG4OocbUfzVD6kwbULnKTlqRcdAuaH0KTFRCiWmlVZxMcMjh7oTpTcWNA5i5wtb0IEbULfVCgY2fiiKTlik5yNertFAfe9(tSRWGHxmpdbrhRymroMg1kioQJqGBr2BNUIvGBzdz7c0Qa50OacPjB)w5qaGm5OxbB5Zx)MGuv3w4MIjWmlVZxMcYzJPZYpNlQ70(0kaFQLJKBnfql6f4ww8YziBxGGq2UaZZgtsel)irCrDsen9Pvq07pXUcdgEX8meeDSIXe5yAuRG4OocbUfzVD6kwbULnKTlqRc4Igfqinz73khcmZY78LPa2o3hQ9wNtg07e3prxub4tTCKCRPaArVa3YIxodz7ceeY2f4OZ9HAVLeXig0tIio8eDrfe9(tSRWGHxmpdbrhRymroMg1kioQJqGBr2BNUIvGBzdz7c0QvGP3VKrFLdTsa]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170829.000820, [[d0dcgaGEqKAtOkQDrK2MOG9bIQzkkQMTKEoPUPO6XICBGoSIDkv7LA3iTFsmkqKmmP43iopbonkdMKgoQ4GeXPar4ysPZbIOfckTuuPflWYfArOkYtHwgbTorrMiiktfunzjMUsxeaxLqvxw11f0gbfARekBgqBhe(ga9DrPPbkY8iu5zIcnorrz0eYFjkNevPpJQ6AGI6EOk8qIQxds)euWU1WnIPiJZA0yFaVrKbkxrv8urKQGmPOcXuHkiAK7RF03DHnTa2KzcHKsBAAeMXwJiNNytLbPNLrOUleMfAusAzeQ2WDV1WncaDcQVyynkjGvzRaJLpRizjcRAKxAHLMLensj0BmNueBI9b8gn2hWBeY(SIuuLtyvJCF9J(UlSPfW2gJCVMegtxB4Enkx0tqZjqCWtxhymNu6d4n61DHgUraOtq9fdRrmfzCwJLheceOuGxVpYO8LLLesls17KGQOc58qrndgLeWQSvGXHdjnvbC03iV0clnljAKsO3yoPi2e7d4nASpG3OeoK0ufWrFJCF9J(UlSPfW2gJCVMegtxB4Enkx0tqZjqCWtxhymNu6d4n619mA4gbGob1xmSgXuKXznwEqiqGsbE9(iJYxwwsiTivVtcQIQ4uuZGIkpROMiKAHKLkD4qstvah9Lgp4WOAfvXPOMrJscyv2kWiWR3hzu(Y0BKb9g5LwyPzjrJuc9gZjfXMyFaVrJ9b8gHXR3hzu(kQ4gzqVrUV(rF3f20cyBJrUxtcJPRnCVgLl6jO5eio4PRdmMtk9b8g96omz4gbGob1xmSgXuKXznoPLbXLD6bzxROc58qrvOrjbSkBfymn1QSjTmcvwLPxJ8slS0SKOrkHEJ5KIytSpG3OX(aEJYNAvrvsAzeQIAMZ0Rrjr(AJ0b88GNqgOCfvXtfrQcYKIQeyaaEYi3x)OV7cBAbSTXi3RjHX01gUxJYf9e0Cceh801bgZjL(aEJiduUIQ4PIivbzsrvcmaGx3Hzd3ia0jO(IH1iMImoRXYdcbcukWR3hzu(YYscPfP6DsqvufhpuuHjJscyv2kWiWR3hzu(Y0BKb9g5LwyPzjrJuc9gZjfXMyFaVrJ9b8gHXR3hzu(kQ4gzqVIkKQfsyK7RF03DHnTa22yK71KWy6Ad3Rr5IEcAobIdE66aJ5KsFaVrVUNbd3ia0jO(IH1iMImoRXYdcbcukWR3hzu(YYscPfPHCmkjGvzRaJ6ejmY)Y0BKb9g5LwyPzjrJuc9gZjfXMyFaVrJ9b8gXejmY)kQ4gzqVrUV(rF3f20cyBJrUxtcJPRnCVgLl6jO5eio4PRdmMtk9b8g96oGgUraOtq9fdRrmfzCwJLheceOuGxVpYO8LLLeslsd5yusaRYwbgt1jlJYxMw0uiz1g5LwyPzjrJuc9gZjfXMyFaVrJ9b8gLxNSmkFfvu0uiz1g5(6h9DxytlGTng5EnjmMU2W9AuUONGMtG4GNUoWyoP0hWB0RxJq2boH11W61ga]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170829.000820, [[dKtEeaGEss1MiPYUiu9AcSpcLzJuZxaDtj1TfANk1EP2nk7xQ(jHidts(nPEoGbRKHJKoOuYPieoMuCossAHislLGwSeTCeEOuQNc9yuTossmrGstfjMmrth0ffuxLquxw11fKdlARKeBgOQTtIwMeopj8zb67cWPv8neXOrupJKsNKq6Va5AKu19akMgjfJJKugfqLDJPye5edvOrJ7mEJ4eB3xImJSMwHQ0xTePWgfE6Na37IQgsQuTcvv8QQQc12yePE(K0JQNWrZ8Uq9fgBXHJMbykE3ykgdZYs6lnPgroXqfAm5Wr5bD2JZb6lXatFvySv5qpqfgLpHKbLmji55PcJIYKdpHAcJmn7gR1svsIDgVrJ7mEJG9jKCFLmzFb2ZtfgfE6Na37IQgsAQmk8a6qe8dykgASn5ZfuRv(4zqxASwl3z8gn07ctXyywwsFPj1iYjgQqJjhokpOZECoqFjwFPgJTkh6bQW4PoYhhUrrzYHNqnHrMMDJ1APkjXoJ3OXDgVXWuh5Jd3OWt)e4Exu1qstLrHhqhIGFatXqJTjFUGATYhpd6sJ1A5oJ3OHERwtXyywwsFPj1iYjgQqJjhokpOZECoqFjgy6RI(sD9f46l5tizqjtcsEEQqC4WfmSG9vGb2xYd(H(IdhUGHfSVeHXwLd9avyeGRdre8GaGeJGBuuMC4jutyKPz3yTwQssSZ4nACNXBe56qebFFHqIrWnk80pbU3fvnK0uzu4b0Hi4hWum0yBYNlOwR8XZGU0yTwUZ4nAO3QXumgMLL0xAsnICIHk0yYHJYd6ShNd0xIbM(QOVuxFbU(s(esguYKGKNNkehoCbdlyFfyG9L8GFOV4WHlyyb7lrySv5qpqfg50zadliiaYPuhaGrrzYHNqnHrMMDJ1APkjXoJ3OXDgVX20zadlyFHKtPoaaJcp9tG7DrvdjnvgfEaDic(bmfdn2M85cQ1kF8mOlnwRL7mEJg6T6nfJHzzj9LMuJiNyOcnMC4O8Go7X5a9Ly9vHXwLd9avy8uh5Jd3OOm5WtOMWitZUXATuLKyNXB04oJ3yyQJ8XH3xGRregfE6Na37IQgsAQmk8a6qe8dykgASn5ZfuRv(4zqxASwl3z8gn0qJG9GpdrdnPgAd]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170829.000820, [[dSZCmaGErvQ2KGAxKyBIQu2NQIzlv3uvSmkvFJsYPrStuAVk7gY(j1OuvXWqk)gQdl58QQAWumCkXHevXPuvPJjkNtvPwivjlLQyXiz5O6HIkpL4XcTorvIjsvQMkLYKPY0v5IcWvfvjDzW1rXgPkfTvb0MPQ2Ua5ZcYZfzAQkrZtvj8xPyCuLcJwk9mvL0jfO(os11OkLUNOQETQ0TjPdsj1lB2M4DWVy638AIybIKQtY71rWOXA3BTpHTuHjcrnN2KxrT4()8I2KUc5kUBIhOdvcgRDAzwrZBy)BfA0Oz)Rzt8aL7VnIkmHZGGKYruHMd3yFI1XJGrPzBSzZ2KaqfvhCZRjsKtSCtCafJVVIpKoGtqHAOJzqoL0vXxT5lYxBSRnH1godIeBSGPdCfh4tIKtB(OnE7eRPiDY9FIpKoGtqHAshN8ctcg5iX6W8jimcM8GDbwC2sfMmHTuHjEtiDaNGcPnYXjVWepqhQemw70YSkJ2epqcZWJqA22njxleFFWbbQa6g1KhSJTuHj7gR9zBsaOIQdU51ejYjwUj5rBOy89vqqKJtKKcJfTjS2CvhqNccICCIKuaur1bN2ewB4miqB(I81MVoXAksNC)N4G6ABIysFsWihjwhMpbHrWKhSlWIZwQWKjSLkmX7qDTAtomPpXd0HkbJ1oTmRYOnXdKWm8iKMTDtY1cX3hCqGkGUrn5b7ylvyYUX(1zBsaOIQdU51ejYjwUjum((kiiYXjssHXI2ewBCafJVVIpKoGtqHAOJzqoL0vXxT5t(AtM2ewB4misSXcMoWvCGpjsoT5J289eRPiDY9FskIz4HGM0XjVWKGrosSomFccJGjpyxGfNTuHjtylvyIeXm8qG2ihN8ct8aDOsWyTtlZQmAt8ajmdpcPzB3KCTq89bheOcOButEWo2sfMSBSF5Snjaur1b38AIe5el3ekgFFfee54ejPWyrBcRnoGIX3xXhshWjOqn0XmiNs6Q4R28jFTjtBcRnCgej2ybth4koWNejN28rB(EI1uKo5(pj2l6euOMuB5W0ttcg5iX6W8jimcM8GDbwC2sfMmHTuHj56fDckK2iTLdtpnXd0HkbJ1oTmRYOnXdKWm8iKMTDtY1cX3hCqGkGUrn5b7ylvyYUX6TZ2KaqfvhCZRjsKtSCtOy89vyqT4()M0XbuORvHXI2ewBCafJVVIpKoGtqHAOJzqoL0vXxT5t(AtM2ewB4misSXcMoWvCGpjsoT5J289eRPiDY9FskIz4HGM0XjVWKGrosSomFccJGjpyxGfNTuHjtylvyIeXm8qG2ihN8cAZpz)oXd0HkbJ1oTmRYOnXdKWm8iKMTDtY1cX3hCqGkGUrn5b7ylvyYUXM3MTjbGkQo4MxtKiNy5MqX47RWGAX9)nPJdOqxRcJfTjS24akgFFfFiDaNGc1qhZGCkPRIVAZN81MmTjS2WzqKyJfmDGR4aFsKCAZhT57jwtr6K7)KyVOtqHAsTLdtpnjyKJeRdZNGWiyYd2fyXzlvyYe2sfMKRx0jOqAJ0wom9K28t2Vt8aDOsWyTtlZQmAt8ajmdpcPzB3KCTq89bheOcOButEWo2sfMSBSwnBtcavuDWnVMiroXYnHZGaT5t(AJDTjS24akgFFfFiDaNGc1qhZGCkPRIVAZN81MmTjS2WzqKyJfmDGR4aFsKCAZhT57jwtr6K7)KueZWdbnPJtEHjbJCKyDy(eegbtEWUaloBPctMWwQWejIz4HaTroo5f0MFS)7epqhQemw70YSkJ2epqcZWJqA22njxleFFWbbQa6g1KhSJTuHj7gR3y2MeaQO6GBEnrICILBcNbbAZN81g7AtyTXbum((k(q6aobfQHoMb5usxfF1Mp5RnzAtyTHZGiXgly6axXb(Ki50MpAZ3tSMI0j3)jXErNGc1KAlhMEAsWihjwhMpbHrWKhSlWIZwQWKjSLkmjxVOtqH0gPTCy6jT5h7)oXd0HkbJ1oTmRYOnXdKWm8iKMTDtY1cX3hCqGkGUrn5b7ylvyYUX(9Snjaur1b38AIe5el3KR6a6usTLdtVHG8zsemsbqfvhCAtyT5QoGofxXFBkof5aUcGkQo40MWAtE0gkgFFfxXFBoEHs(yUADemsHXI2ewBIyC3HPJuCf)TP4uKd4kCqTiOK28rBYOnXAksNC)N4G6ABIysFsWihjwhMpbHrWKhSlWIZwQWKjSLkmX7qDTAtomPRn)K97epqhQemw70YSkJ2epqcZWJqA22njxleFFWbbQa6g1KhSJTuHj7gBgTzBsaOIQdU51ejYjwUjx1b0PKAlhMEdb5ZKiyKcGkQo40MWAtE0MR6a6uCf)TP4uKd4kaQO6GtBcRn5rBOy89vCf)T54fk5J5Q1rWifgltSMI0j3)joOU2MiM0NemYrI1H5tqyem5b7cS4SLkmzcBPct8ouxR2Kdt6AZp2)DIhOdvcgRDAzwLrBIhiHz4rinB7MKRfIVp4GavaDJAYd2XwQWKDJnlB2MeaQO6GBEnrICILBYvDaDkUI)2uCkYbCfavuDWPnH1Mig3Dy6ifxXFBkof5aUchulckPnF0MmAtSMI0j3)joOU2MiM0NemYrI1H5tqyem5b7cS4SLkmzcBPct8ouxR2Kdt6AZpF93jEGoujyS2PLzvgTjEGeMHhH0STBsUwi((Gdcub0nQjpyhBPct2n2m7Z2KaqfvhCZRjsKtSCtYJ2CvhqNsQTCy6neKptIGrkaQO6GtBcRn5rBUQdOtXv83MItroGRaOIQdUjwtr6K7)ehuxBtet6tcg5iX6W8jimcM8GDbwC2sfMmHTuHjEhQRvBYHjDT5NV83jEGoujyS2PLzvgTjEGeMHhH0STBsUwi((Gdcub0nQjpyhBPct2TBIe5el3KDB]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170829.000820, [[dStujaGEskvBsOSlsSnskX(ivA2I6MQupxKVHI60iTtuAVk7gQ9tXOiPyyOIFRQhl48OsgmLgoPQdHI0PqrCmiCovcSqsQwkv0IH0Yr8qHQNsSmsY6ujsteIYuPctMQMUuxKkvxLKs6YGRJQ2ijLYwPszZcz7uj9zvshwY0ujQ5Psq)vfgNkrmAu4zOsDsQeFhICnvcDpiQETk6GKkUnP8qmhte9qGwzQAVA6JhRQlQAcBPbteQwCJvTIz8zUUuJnuPMET6NmXjKHkbJvfhemZ5suDbkC4Wrf3iMibcvFpzIoHM(40CmweZXe3XfAg8t9jsGq13t8akFuKseKAGqXxpq65XELuxHtJ9crUXEzJnMXs4X0WH(hjGO4HiAG2gRUgRkUNOdkntBUMebPgiu81JutONWexWEAO6Nmb)yyY97DRiSLgmzcBPbtuBqQbcfF1yLMqpHjoHmujySQ4GGzeCM4esppjaP5y9K4mGW597kOb4EOtUFpBPbtwpwvZXe3XfAg8t9jsGq13tyQXIYhfPGHa5t0KcVEJnMX2vgWTcgcKprtkaUqZG3yJzSeEmySxiYnwUNOdkntBUM4HQzCeEAEIlypnu9tMGFmm5(9Uve2sdMmHT0GjidQMHXg)P5joHmujySQ4GGzeCM4esppjaP5y9K4mGW597kOb4EOtUFpBPbtwpwUNJjUJl0m4N6tKaHQVNGYhfPGHa5t0KcVEJnMX6bu(OiLii1aHIVEG0ZJ9kPUcNgRUi3y52yJzSeEmnCO)rcikEiIgOTXQRXQI7j6GsZ0MRjPWZtUchPMqpHjUG90q1pzc(XWK737wrylnyYe2sdMiHNNCfmwPj0tyItidvcgRkoiygbNjoH0ZtcqAowpjodiCE)UcAaUh6K73ZwAWK1J9YZXe3XfAg8t9jsGq13tq5JIu4Xm(mxhPMa4RndfE9gBmJ1dO8rrkrqQbcfF9aPNh7vsDfonwDrUXYTXgZyj8yA4q)Jequ8qenqBJvxJvf3t0bLMPnxtsHNNCfosnHEctCb7PHQFYe8JHj3V3TIWwAWKjSLgmrcpp5kySstONGXQgemzItidvcgRkoiygbNjoH0ZtcqAowpjodiCE)UcAaUh6K73ZwAWK1J9IZXe3XfAg8t9jsGq13ti8yWy1f5gRkJnMX6bu(OiLii1aHIVEG0ZJ9kPUcNgRUi3y52yJzSeEmnCO)rcikEiIgOTXQRXQI7j6GsZ0MRjPWZtUchPMqpHjUG90q1pzc(XWK737wrylnyYe2sdMiHNNCfmwPj0tWyvJkMmXjKHkbJvfhemJGZeNq65jbinhRNeNbeoVFxbna3dDY97zlnyY6XQwMJjUJl0m4N6tKaHQVN0vgWTsIr5FKoO4i(e9XkaUqZG3yJzSDLbCR4lY5rrqPnquaCHMbVXgZyzQXIYhfP4lY5rtkCk6jAvtFScVEJnMXg(p7FKWk(ICEueuAdefcOvuCYy11yrCXj6GsZ0MRjEOAghHNMN4c2tdv)Kj4hdtUFVBfHT0GjtylnycYGQzySXFA2yvdcMmXjKHkbJvfhemJGZeNq65jbinhRNeNbeoVFxbna3dDY97zlnyY6XY8CmXDCHMb)uFIeiu99KUYaUvsmk)J0bfhXNOpwbWfAg8gBmJLPgBxza3k(ICEueuAdefaxOzWBSXmwMASO8rrk(ICE0KcNIEIw10hRWRFIoO0mT5AIhQMXr4P5jUG90q1pzc(XWK737wrylnyYe2sdMGmOAggB8NMnw1OIjtCczOsWyvXbbZi4mXjKEEsasZX6jXzaHZ73vqdW9qNC)E2sdMSESxYCmXDCHMb)uFIeiu99KUYaUv8f58OiO0gikaUqZG3yJzSH)Z(hjSIViNhfbL2arHaAffNmwDnwexCIoO0mT5AIhQMXr4P5jUG90q1pzc(XWK737wrylnyYe2sdMGmOAggB8NMnw1WntM4eYqLGXQIdcMrWzIti98KaKMJ1tIZacN3VRGgG7Ho5(9SLgmz9yVG5yI74cnd(P(ejqO67jm1y7kd4wjXO8pshuCeFI(yfaxOzWBSXmwMASDLbCR4lY5rrqPnquaCHMb)eDqPzAZ1epunJJWtZtCb7PHQFYe8JHj3V3TIWwAWKjSLgmbzq1mm24pnBSQ5YmzItidvcgRkoiygbNjoH0ZtcqAowpjodiCE)UcAaUh6K73ZwAWK1RNGmiQ4Z9uF9ga]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170829.000820, [[dSJwmaGEvjP2KOyxK02uLKSpvPMTkUPQ45ICBk50i2jk2RYUbTFkgfkrdtv1VbESqNhL0Gj1WjrhKsXPiboMk5COewiLslLQ0IrYYr1dfLEkXYOkwNQKWefatLs1KPY0L6IcORQkj6YqxhP2ijiTvbYMPQ2Ua1NfKdlzAQskZtvs1FfvJJeeJwL6zQsCsbLVJsDnsqDpbvhsa61QkFJe6Dn7teLyKuhYRUAcaogpkSNjmLforiwzn6xj8gCy9vy0eyQ50XgWtt8IhSs4y88FP4VcXdlu)))98Y1ejYjk7jtSj2eamn7J5A2NeiSOoOB2orICIYEIdPO99v9XuJCcmuoBan0PM6k(z0VE4gThJoJrZPHKyUsaBKR6qFsK0g9BJwHNydf5qAwN4JPg5eyO8uZjF4KWGosSAaFceaXjpaxqfNPSWjtyklCIcftnYjWqgT0CYhoXlEWkHJXZ)LIx)t8IjanpIPzF9KS3y87bemAHWEutEaoMYcNSEmEM9jbclQd6MTtKiNOSNeqJMI23xfIroirsQ0kn6mgDxhe2QqmYbjssfHf1bDgDgJMtdrJ(1d3OFzInuKdPzDIdR(opciNjHbDKy1a(eiaItEaUGkotzHtMWuw4KaGvFB0zbKZeV4bReogp)xkE9pXlMa08iMM91tYEJXVhqWOfc7rn5b4yklCY6X8YSpjqyrDq3SDIe5eL9ekAFFvig5GejPsR0OZy0oKI23x1htnYjWq5Sb0qNAQR4Nr)oCJ(fJoJrZPHKyUsaBKR6qFsK0g9BJMftSHICinRtsranpeMNAo5dNeg0rIvd4tGaio5b4cQ4mLfozctzHtKiGMhcnAP5KpCIx8GvchJN)lfV(N4ftaAEetZ(6jzVX43diy0cH9OM8aCmLfoz9yETzFsGWI6GUz7ejYjk7ju0((QqmYbjssLwPrNXODifTVVQpMAKtGHYzdOHo1uxXpJ(D4g9lgDgJMtdjXCLa2ix1H(KiPn63gnlMydf5qAwNepfBcmuE6UCa2PjHbDKy1a(eiaItEaUGkotzHtMWuw4KSNInbgYOL7YbyNM4fpyLWX45)sXR)jEXeGMhX0SVEs2Bm(9acgTqypQjpahtzHtwpgfE2NeiSOoOB2orICIYEcfTVVkn8gCynp1CegQVvPvA0zmAhsr77R6JPg5eyOC2aAOtn1v8ZOFhUr)IrNXO50qsmxjGnYvDOpjsAJ(TrZIj2qroKM1jPiGMhcZtnN8Htcd6iXQb8jqaeN8aCbvCMYcNmHPSWjseqZdHgT0CYhA0S8sbt8IhSs4y88FP41)eVycqZJyA2xpj7ng)EabJwiSh1KhGJPSWjRhZRA2NeiSOoOB2orICIYEcfTVVkn8gCynp1CegQVvPvA0zmAhsr77R6JPg5eyOC2aAOtn1v8ZOFhUr)IrNXO50qsmxjGnYvDOpjsAJ(TrZIj2qroKM1jXtXMadLNUlhGDAsyqhjwnGpbcG4KhGlOIZuw4KjmLfoj7PytGHmA5UCa2jJMLxkyIx8GvchJN)lfV(N4ftaAEetZ(6jzVX43diy0cH9OM8aCmLfoz9yuC2NeiSOoOB2orICIYEcNgIg97WnApgDgJ2Hu0((Q(yQrobgkNnGg6utDf)m63HB0Vy0zmAonKeZvcyJCvh6tIK2OFB0SyInuKdPzDskcO5HW8uZjF4KWGosSAaFceaXjpaxqfNPSWjtyklCIeb08qOrlnN8Hgnl9OGjEXdwjCmE(Vu86FIxmbO5rmn7RNK9gJFpGGrle2JAYdWXuw4K1JrHm7tcewuh0nBNirorzpHtdrJ(D4gThJoJr7qkAFFvFm1iNadLZgqdDQPUIFg97Wn6xm6mgnNgsI5kbSrUQd9jrsB0VnAwmXgkYH0SojEk2eyO80D5aSttcd6iXQb8jqaeN8aCbvCMYcNmHPSWjzpfBcmKrl3LdWoz0S0JcM4fpyLWX45)sXR)jEXeGMhX0SVEs2Bm(9acgTqypQjpahtzHtwpgwm7tcewuh0nBNirorzpPRdcB10D5aSZjqF6ebavryrDqNrNXO76GWw1v8V8ItrAKRIWI6GoJoJrhqJMI23x1v8V8MxWKpGBvnbavPvA0zm6iaCCa2qvxX)YlofPrUkhTkcmz0Vn6R)j2qroKM1joS678iGCMeg0rIvd4tGaio5b4cQ4mLfozctzHtcaw9TrNfqognlVuWeV4bReogp)xkE9pXlMa08iMM91tYEJXVhqWOfc7rn5b4yklCY6XC9p7tcewuh0nBNirorzpPRdcB10D5aSZjqF6ebavryrDqNrNXOdOr31bHTQR4F5fNI0ixfHf1bDgDgJoGgnfTVVQR4F5nVGjFa3QAcaQsRCInuKdPzDIdR(opciNjHbDKy1a(eiaItEaUGkotzHtMWuw4KaGvFB0zbKJrZspkyIx8GvchJN)lfV(N4ftaAEetZ(6jzVX43diy0cH9OM8aCmLfoz9yUUM9jbclQd6MTtKiNOSN01bHTQR4F5fNI0ixfHf1bDgDgJocahhGnu1v8V8ItrAKRYrRIatg9BJ(6FInuKdPzDIdR(opciNjHbDKy1a(eiaItEaUGkotzHtMWuw4KaGvFB0zbKJrZYxuWeV4bReogp)xkE9pXlMa08iMM91tYEJXVhqWOfc7rn5b4yklCY6XC5z2NeiSOoOB2orICIYEsan6UoiSvt3LdWoNa9PteaufHf1bDgDgJoGgDxhe2QUI)LxCksJCvewuh0nXgkYH0SoXHvFNhbKZKWGosSAaFceaXjpaxqfNPSWjtyklCsaWQVn6SaYXOz5RPGjEXdwjCmE(Vu86FIxmbO5rmn7RNK9gJFpGGrle2JAYdWXuw4K1RNea0VOp9SD9ga]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170829.000820, [[deeIxaqievTjPsFIQKkJcr6uiIDrfddv5yIyzKQEgIsnnQs01quyBuLu(gjQXjvuDoPISoQsQAEik6EiQSpQs4GKilKe6HKknreLuxKuXgPQkFerjzKsfLtsvQBkvTtu5NikXsjfpLYujL2kvv(kvvL9Q8xQ0Gj6WalgHhlQjdYLvTzP0NPQmAuvNgLxtvmBHUnO2nu)gYWLIJtvswospxW0LCDsA7IuFNeCErY6PQQA(sf2pHxY0oZYuwtnBgha(ZmgSUcP)OOq51lK(o(uwEgz9BbQXAkotZJhe(40ZlrzEDU(o5WJhp9KDYmnhaLsld(ZiFbIhxoTuuOc5uf)7CmGiEiHeGHesEcjIkKeQTToEyXid7ZfgK5ZW3HEyadhMPuUyiCyAhxY0othmGiEOP4mltzn1Sc5Zx8ozekcHuaheYUcjPcjPcj5fYcepUCAPi))y3g1y4ohdiIhsi7OdHKuHKQIVqsMcPEHSRqsvXSSBdsHtDYQu6XLqsMcP(oxijrijri7kKKxilq84YXhO4Fkd7ZnuikSZXaI4HessMPeblYQuZqerwDkOyi8mVXqSmOq0zye(Z6rq(bOCa4pBgha(ZilerwDkOyi8mnpEq4JtpVeLt4ntZdivA(HPD1mD5)SNEu6dFCnIz9iioa8NTAC6N2z6GbeXdnfNzzkRPMrO226WYPClqeHdo0ddy4GqsMczIdziKDfYcepUCy5uUfiIWbNJbeXdntjcwKvPM1srHYnuuMNpZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHsiTIY88zAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14i7PDMoyar8qtXzwMYAQzfiEC5e4dQ6ug2NBOOmpp4CmGiEiHSRqcDc12whkW)ruw(oHcK9iKKtijJzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKKMqYmnpEq4JtpVeLt4ntZdivA(HPD1mD5)SNEu6dFCnIz9iioa8NTACE50othmGiEOP4mltzn1msfsc12whkd(oQnczxH8ELkRP5qonNgE6tb48DrTUf)7Ece2fgqRuuHSRqsEHKuHKqTT1brez1PGIHWoQnczxHeKlw67E8HzpiKKPqQxijrijri7OdHSaXJlhFGI)PmSp3qHOWohdiIhAMseSiRsnJEyen84dbxfy460zEJHyzqHOZWi8N1JG8dq5aWF2moa8NP5WiA4XhccP)XW1PZ084bHpo98suoH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXrgt7mDWaI4HMIZSmL1uZiuBBDOm47O2iKDfsYlKKkKeQTToiIiRofume2rTri7kKGCXsF3Jpm7bHKmfs9cjjczxHK8cjPc59kvwtZHCAon80NcW57IADl(39eiSlmGwPOczxHSaXJlhFGI)PmSp3qHOWohdiIhsijzMseSiRsnJpsHid7ZLicc1mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z6mKcrg2NqQyeeQzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB148At7mDWaI4HMIZSmL1uZiuBBDOm47O2iKDfsYlKKkKeQTToiIiRofume2rTri7kKGCXsF3Jpm7bHKmfs9cjjczxH8ELkRP5qonNgE6tb48DrTUf)7Ece2fgqRuuHSRqwG4XLJpqX)ug2NBOquyNJbeXdjKDfssfsOtO2260CA4PpfGZ3f16w8V7jqyxyaTsrDuBeYo6qiZiuecPa2HEyen84dbxfy46uh6HbmCqi9cHKSfssMPeblYQuZ4JuiYW(CjIGqnZBmeldkeDggH)SEeKFakha(ZMXbG)SodPqKH9jKkgbHsijnHKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14uEANPdgqep0uCMLPSMAg5fsc12wherKvNckgc7O2iKDfssfY7vQSMMd54bflgfeCXxHwKkgYvbwmkKDfYcepUCAPi))y3g1y4ohdiIhsi7kKKkKHxUeiSAWPyNM0jx9nzHKCczIq2rhcz4LlbcRgCk2PjDY1lBYcj5eYeHKeHKeHSJoesQk(bNIbF3c5sgcjzkK(YqZuIGfzvQziIiRofuFM3yiwgui6mmc)z9ii)auoa8NnJda)zKfIiRofuFMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUoFANPdgqep0uCMLPSMAwH85lENmcfHqkGdczxHKuHKuH8ELkRP5qozeoGOvWnJIqUze9czhDiKeQTTonSyeqDrTUTuuOCuBesseYUcjHABRJkMpkMYnu0J9v8DuBeYUcj0juBBDOa)hrz57ekq2JqsoHKmeYUcj5fsc12wherKvNckgc7O2iKKmtjcwKvPMfyyikWhkacUTQ0uZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZyyikWhka86ccP)uPPMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJRtt7mDWaI4HMIZSmL1uZOQyw2TbPWPoqVLLzLqsMKtit4ntjcwKvPM1srHYnuuMNpZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHsiTIY8CHKu9KmtZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgxcVPDMoyar8qtXzwMYAQzeQTToiIiRofume2rTri7kKKxijuBBD8WIrg2NlmiZNHVJAZmLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZfssjBsMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJljzANPdgqep0uCMLPSMAgixS0394dZEqi9cYjK6fYUcj5fssfYcepUCAPOqfYPk(35yar8qczxHKqTT1XdlgzyFUWGmFg(oQnczxHeKlw67E8HzpiKEb5es9cjjZuIGfzvQz0dJOHhFi4QadxNoZBmeldkeDggH)SEeKFakha(ZMXbG)mnhgrdp(qqi9pgUovijnHKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s0pTZ0bdiIhAkoZYuwtnJqTT1XdlgzyFUWGmFg(oQnczxHKuHK8c59kvwtZHC8GIfJccU4Rqlsfd5QalgfYo6qib5IL(UhFy2dcPxqoHuVqsYmLiyrwLAwlffQqovX)Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOc5uf)ptZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgxczpTZ0bdiIhAkoZYuwtndKlw67E8HzpiKEb5es9ZuIGfzvQz(IGmdeDbqPb48N5ngILbfIodJWFwpcYpaLda)zZ4aWFgzveKzGOqQeuAao)zAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s8YPDMoyar8qtXzwMYAQzGCXsF3Jpm7bH0liNqs2ZuIGfzvQzTuuOc5uf)pZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHkKtv8VqsAcjZ084bHpo98suoH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXLqgt7mDWaI4HMIZSmL1uZiuBBD8WIrg2NlmiZNHVJAZmLiyrwLAgIiYQtb1N5ngILbfIodJWFwpcYpaLda)zZ4aWFgzHiYQtb1fsstizMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUeV20othmGiEOP4mltzn1ScepUC8bk(NYW(CdfIc7CmGiEiHSRqwG4XLdSkf6uKAW9TTSm74CkNJbeXdjKDfssfYWlxcewn4uStt6KR(MSqsoHmri7OdHm8YLaHvdof70Ko56LnzHKCczIqsYmLiyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZfss9ssMP5XdcFC65LOCcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlr5PDMoyar8qtXzwMYAQzKkKfiEC5WhrXUOwxfy46uNJbeXdjKD0HqwG4XLdFvSVtzyFUuv8Dv4Gge25yar8qcjjczxHKuHm8YLaHvdof70Ko5QVjlKKtiteYo6qidVCjqy1GtXonPtUEztwijNqMiKKmtjcwKvPM1srHYnuuMNpZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHsiTIY8CHKuYGKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s68PDMoyar8qtXzkrWISk1merKvNcQpZBmeldkeDggH)SEeKFakha(ZMXbG)mYcrKvNcQlKKQNKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s600othmGiEOP4mLiyrwLAMViiZarxauAao)zEJHyzqHOZWi8N1JG8dq5aWF2moa8NrwfbzgikKkbLgGZxijnHKzAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB140ZBANPdgqep0uCMLPSMAg5fsc12wh(QyFNYW(CPQ47QWbniSJAZmLiyrwLAgFef7IADvGHRtN5ngILbfIodJWFwpcYpaLda)zZ4aWFwNHOyHe1kK(hdxNotZJhe(40Zlr5eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgN(KPDMoyar8qtXzkrWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK61izMMhpi8XPNxIYj8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(Zwno96N2z6GbeXdnfNzzkRPMviF(I3jJqriKc4WmLiyrwLA2HBqkCQlvfFxfoObHN5ngILbfIodJWFwpcYpaLda)zZ4aWFMoWnifovi1OIVq6Fh0GWZ084bHpo98suoH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXPNSN2z6GbeXdnfNzzkRPMviF(I3jJqriKc4Gq2vijvijVqsO226Wxf77ug2NlvfFxfoObHDuBessMPeblYQuZ4RI9Dkd7ZLQIVRch0GWZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pRZuX(oLH9jKAuXxi9VdAq4zAE8GWhNEEjkNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB1QzwZZmqK5)GIHWJtpzKSAd]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170829.000820, [[dWZ1gaGEbuBsazxOsBdeL2hiQAMGiZMu3euEok3wQonWoHQ9QSBi7NkJcvuddu9Bv9ykDEkObtvdxk5GqXPqf5yG0XrfWcfGLsrwmQA5K8qP4PiltGwNuQjkeAQuOjRIPl6IcLweiCzIRtrTrHQTkuSzvsBxi13OaFwLAAOc13rfONje8xbnAO04arXjfIoSKRHkO7jK8AvIdHkKZbIkpOZ4iYQaTYrJWRUmIa9gNpU6zzBN)ixlZ6Ce1sSGsdcCLGhn8GCi0rMeTumz4bHd1a4qMGqoUWHdpyeGoYKuhdnc6YiLzeWg265GII71sRzH5hg0GrySj4rSzC4qNXrXIkETCwaJiRc0khL)9Tw4cqPOuMBLSry4bAqA4OoaDcVQejWYOirhGTYxnc9izeS)etPWRUmAeE1LrWaOJZhxjsGLrMeTumz4bHd1aOWhzsyVzLvyZ4Yrnyf7fyF0sxq54hb7p4vxgTC4bNXrXIkETCwaJWWd0G0Wr2sRdlBcEuOgWYrrIoaBLVAe6rYiy)jMsHxDz0i8QlJAkT25XytWJCEiby5imQB2iu1LOGGa9gNpU6zzBNVjImigzs0sXKHheoudGcFKjH9MvwHnJlh1GvSxG9rlDbLJFeS)GxDzeb6noFC1ZY2oFtezlhEeMXrXIkETCwaJiRc0khjCaZGwTKdx7RpHyLsLoFGCEEZxVY1(6tiwPujxww2lopKpkNhk8ry4bAqA4iBP1HLnbpkudy5OgSI9cSpAPlOC8JG9NykfE1LrJWRUmQP0ANhJnbpY5HeGLopNHYPryu3SrOQlrbbb6noFC1ZY2oV91hNhRuQeIrMeTumz4bHd1aOWhzsyVzLvyZ4YrrIoaBLVAe6rYiy)bV6Yic0BC(4QNLTDE7RpopwPu5YHZXZ4OyrfVwolGrKvbALJ4iNplTGsU8kPsSH)1qgaDu19ZkUcQ41YzegEGgKgoYwADyztWJc1awoQbRyVa7Jw6ckh)iy)jMsHxDz0i8QlJAkT25XytWJCEibyPZZ5GCAeg1nBeQ6suqqGEJZhx9SSTZ3llwasUnJGyKjrlftgEq4qnak8rMe2Bwzf2mUCuKOdWw5RgHEKmc2FWRUmIa9gNpU6zzBNVxwSaKCBgTC4C4mokwuXRLZcyezvGw5OS0ck5YRKkXg(xdza0rv3pR4kOIxlhNpqoph58Np5YRKkXg(xdza0rv3pR4Ma7fa6EegEGgKgoYwADyztWJc1awoQbRyVa7Jw6ckh)iy)jMsHxDz0i8QlJAkT25XytWJCEibyPZZ5iWPryu3SrOQlrbbb6noFC1ZY2op)ZC(BbjkGfIrMeTumz4bHd1aOWhzsyVzLvyZ4YrrIoaBLVAe6rYiy)bV6Yic0BC(4QNLTDE(N583csua7YHdzNXrXIkETCwaJiRc0khLLwqjxELuj2W)AidGoQ6(zfxbv8A548bY5pFYLxjvIn8VgYaOJQUFwXnb2la09im8aninCKT06WYMGhfQbSCudwXEb2hT0fuo(rW(tmLcV6YOr4vxg1uATZJXMGh58qcWsNNZCmNgHrDZgHQUefeeO348XvplB788pZ5tG9caDdXitIwkMm8GWHAau4JmjS3SYkSzC5OirhGTYxnc9izeS)GxDzeb6noFC1ZY2op)ZC(eyVaq3lxokIY1YSoxal3a]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170829.000820, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEnLuLXwzHnxzE5KmWeZnWGJm54cmWaJmZeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnLx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170829.000820, [[deubnaqisvztur(KsfYOOs5uuPAxsYWqIJjLwgvYZqsLPPujDnKuSnLkHVHKmoKu6CkvkRJuvP5Pur3JuvX(uQGdIk1crL8qsHjQuj6IKI2ivu9rLkuJKuv1jjL6Msv7eu)KkkTuuXtjMkQQTsQYxrsv7v8xLYGP4WQAXi6XkzYGCzOnlfFgvz0KkNMKxtfMnvDBe2nWVvmCPYXvQuTCuEUetxLRJuBxPQVlP68skRNkkMpPK9tPtB4hrwmv3fjc8tGrefHgwJZzt50VwdVI1CQLdfGxKDj280(lCfHd6XVGb2fLwQOqTU2TkkuO4I6AJWbFOA8veyes6MMkD0aEitb4TXOb4wD87gqfdjEfOeH71Pgqj8dCB4hrtWt6rOWvezXuDxes6MMk1Q229(buQyiXRafRzNwtBf1ynozn37rWvPw12U3pGsfcEspcfHBsLxD1I0WMYTvoMYbgrBaKA93WIagagPFG07zWpbgjc8tGrCoBkN1iht5aJWb94xWa7IslvTuIWbldnBHLWpxen0Hlh9ZEKabxiJ0pqWpbgjxGDf(r0e8KEekCfHBsLxD1IWqIHvqpwkB1vGdzr0gaPw)nSiGbGr6hi9Eg8tGrIa)eyeoiXWkOhlfRH6vGdzr4GE8lyGDrPLQwkr4GLHMTWs4NlIg6WLJ(zpsGGlKr6hi4NaJKlWux4hrtWt6rOWvezXuDxes6MMkMIaRO7SgNSg9znUznK0nnvdPxDi7p1aQO7SgNSMFDQ94gcqcfwSMDAnUSg3JWnPYRUAr0n19kaVns)xUiAdGuR)gweWaWi9dKEpd(jWirGFcmI(p19kapRHl)xUiCqp(fmWUO0svlLiCWYqZwyj8ZfrdD4Yr)ShjqWfYi9de8tGrYf4Dn8JOj4j9iu4kISyQUlYn845XQ1mEOPoOynoznUznUzn6ZAU3JGRQHnodc26O9fScbpPhHSgT0YACZAy0a0A2P14YACYAy0a1ARBQJSQfnJHGZA2P14IATg3Tg3Tg3JWnPYRUArgsV6q2FQberBaKA93WIagagPFG07zWpbgjc8tGrCwsV6q2FQbeHd6XVGb2fLwQAPeHdwgA2clHFUiAOdxo6N9ibcUqgPFGGFcmsUatnHFenbpPhHcxrKft1Dry0a0A2bRH6SgT0YAiPBAQCO8EfG3gXV0PayfDN1OLwwdjDtt1q6vhY(tnGk6UiCtQ8QRwKH0RoK9hgrBaKA93WIagagPFG07zWpbgjc8tGrCwsV6q2FyeoOh)cgyxuAPQLseoyzOzlSe(5IOHoC5OF2Jei4czK(bc(jWi5c8Ui8JOj4j9iu4kISyQUlYn845XQ1mEOPoOynoznUznUzn4UtR66qOQ1akd7kBRXdTTggAnAPL1qs30u1P8(NTnnBnSPCv0DwJ7wJtwdjDttfnq34RTvogc4D6QO7SgNSgiKKUPPI9oZWulSQC)YH1OFSgQXACYA0N1qs30unKE1HS)udOIUZACpc3KkV6QfPOaqSN3u(YwdnRweTbqQ1FdlcyayK(bsVNb)eyKiWpbgruai2ZBk)oQynoNMvlch0JFbdSlkTu1sjchSm0Sfwc)Cr0qhUC0p7rceCHms)ab)eyKCbMQWpIMGN0JqHRiYIP6UiK0nnvouEVcWBJ4x6uaSIUZACYACZA0N1G7oTQRdHQCm(tX(YgaR3m0aOT6kV3A0slR5EpcUkE)PdzkaVTYnmIke8KEeYA0slR5xNApUHaKqHfRzh0pwJlRX9iCtQ8QRwKg2uUYQ2PdJOnasT(ByradaJ0pq69m4NaJeb(jWioNnLRSQD6WiCqp(fmWUO0svlLiCWYqZwyj8ZfrdD4Yr)ShjqWfYi9de8tGrYfyQn8JOj4j9iu4kISyQUlcJgOwBDtDKvTOzmeCwZoynulfRrlTSg3Sgs6MMQH0RoK9NAav0DwJtwJ(Sgs6MMkhkVxb4Tr8lDkawr3znUhHBsLxD1I0WMYTvoMYbgrBaKA93WIagagPFG07zWpbgjc8tGrCoBkN1iht5aTg3ADpch0JFbdSlkTu1sjchSm0Sfwc)Cr0qhUC0p7rceCHms)ab)eyKCbE3c)iAcEspcfUIWnPYRUArgsV6q2FyeTbqQ1FdlcyayK(bsVNb)eyKiWpbgXzj9Qdz)HwJBTUhHd6XVGb2fLwQAPeHdwgA2clHFUiAOdxo6N9ibcUqgPFGGFcmsUa3sj8JOj4j9iu4kISyQUlcJgOwBDtDKvTOzmeCwZoTgQOynozn6ZAiPBAQ0rd4HmfG3gJgGB1XVBav0Dr4Mu5vxTi6ggyBA2QRahYIOnasT(ByradaJ0pq69m4NaJeb(jWi6)WawZ0ynuVcCilch0JFbdSlkTu1sjchSm0Sfwc)Cr0qhUC0p7rceCHms)ab)eyKCbUTn8JOj4j9iu4kc3KkV6QfHN)xQ3V9q7FWcJOnasT(ByradaJ0pq69m4NaJeb(jWi7y)VuV3A4gA)dwyeoOh)cgyxuAPQLseoyzOzlSe(5IOHoC5OF2Jei4czK(bc(jWi5cCRRWpIMGN0JqHRiCtQ8QRwKg2uUTYXuoWiAdGuR)gweWaWi9dKEpd(jWirGFcmIZzt5Sg5ykhO14Ml3JWb94xWa7IslvTuIWbldnBHLWpxen0Hlh9ZEKabxiJ0pqWpbgjxGBPUWpIMGN0JqHRiYIP6Ui3WJNhRwZ4HM6GI14K14M1OpRHKUPPshnGhYuaEBmAaUvh)Ubur3znUhHBsLxD1IOJgWdzkaVngna3QJF3aIOnasT(ByradaJ0pq69m4NaJeb(jWi6pnGhYuaEwdhAaAnup(Ddich0JFbdSlkTu1sjchSm0Sfwc)Cr0qhUC0p7rceCHms)ab)eyKCbUDxd)iAcEspcfUIilMQ7ICdpEESAnJhAQdkr4Mu5vxTiir3uhzBmAaUvh)UberBaKA93WIagagPFG07zWpbgjc8tGr0KOBQJmRHdnaTgQh)UbeHd6XVGb2fLwQAPeHdwgA2clHFUiAOdxo6N9ibcUqgPFGGFcmsUCrKoCPEVYz(tnGa7IAAZLaa]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170829.000820, [[deuDsaqisfTjOkFIGuAuqLofuXQiiPDrfddvCmOyzsONjizAKkCnjs2gbj(guvJJGuDobrTocsX8Ki19iiSpQkoivPwiPspKQKjsqKUivv2OGuJKGOojvvDtO0oj0pfeAPuPEkLPsvSvQk9vbb7v1FjLbJYHHSyu1JL0Kv0LbBgv6ZujJMu1Pj61cQzl0Tvy3i(TudNahxqKLR0Zjz6IUUaBNG67sW5LOwpbrmFjI9J0hZ9CZQRuqE7MiAa3m5Wlkl0BRsHgkJVv3esbUOGyEDV5gIasbxSihm4ZrOxmKD4WHtXqH5MBanl7roGBBarw1e0fG1HlkgvAzRHpNBExtztu3ZfXCp38JG4JW86EZQRuqElrrGKoYAzTefBIYbii(imPm8Om(aUCDK1YAjk2eLZcdKKOOSstzUQtkdpkR2DC2fio8lGs9AnxnLKmxKRwHCwyGKefL5dLTbeq5KYbOLTMoU5nVmkZY34UTk1u5kdd38NmLvu27nstGBy7PVOvenGB3erd4wO3wLuMLRmmCZnebKcUyroyWhdNBUbvhSvqDppV5LEOggBlmmasE(By7PiAa3EEXI3Zn)ii(imVU3S6kfK3sueiPJluQhwjXLMk7D4aeeFeM38MxgLz5Blm6vbrqP0kijjS38NmLvu27nstGBy7PVOvenGB3erd4MBy0RcIGsrzHGKKWEZnebKcUyroyWhdNBUbvhSvqDppV5LEOggBlmmasE(By7PiAa3EEXqDp38JG4JW86EZQRuqEJpGlxNvoaNabugEu2gqaLtkhGw2A6GYknLHlL5QoPmHkLvKYW5M38YOmlFtFxikjU04JivEZFYuwrzV3inbUHTN(Iwr0aUDtenGBc5UqusCrz6grQ8MBicifCXICWGpgo3CdQoyRG6EEEZl9qnm2wyyaK883W2tr0aU98I64EU5hbXhH519MvxPG82gqaLtkhGw2AcfkR0uMR6KYWJY0jLLOiqshxOupSsIlnv27Wbii(imV5nVmkZY3A(OmHfLWn)jtzfL9EJ0e4g2E6lAfrd42nr0aUfI8rzclkHBUHiGuWflYbd(y4CZnO6GTcQ755nV0d1WyBHHbqYZFdBpfrd42ZlwQ75MFeeFeMx3BwDLcYBBabuoPCaAzRPdkR0uMR6KYWJYWLYQDhNDbId)cOuVwZvtjjZf5QviNfgijrrz(qzCOSskHY2aISQjOlaRtnyxGKuwPPm85qz4CZBEzuMLV18rzclkHB(tMYkk79gPjWnS90x0kIgWTBIObCle5JYewucugUyW5MBicifCXICWGpgo3CdQoyRG6EEEZl9qnm2wyyaK883W2tr0aU98IcL75MFeeFeMx3BwDLcYBBarw1e0fG1PgSlqskZhHGYc5srz4rzki14BsGYjLWIjK10HGkL5dLXHYWJYQDhNDbId)cOuVwZvtjjZf5QviNfgijrrz(qzCU5nVmkZY34UTk1u5kdd38NmLvu27nstGBy7PVOvenGB3erd4wO3wLuMLRmmqz4IbNBUHiGuWflYbd(y4CZnO6GTcQ755nV0d1WyBHHbqYZFdBpfrd42ZlI)9CZpcIpcZR7nRUsb5n(aUCDw5aCceqz4rzqififiaMocGvbcdlIubTMRwQh0a(MOnqBwEV5nVmkZY3wy0RcIGsPvqssyV5pzkROS3BKMa3W2tFrRiAa3UjIgWn3WOxfebLIYcbjjHLYWfdo3CdraPGlwKdg8XW5MBq1bBfu3ZZBEPhQHX2cddGKN)g2EkIgWTNxuOFp38JG4JW86EZQRuqEJpGlxNvoaNabugEugUu2StNfg9QGiOuAfKKewNuwdljUOSskHYQDhNDbIZcJEvqeukTcsscRZcdKKOOmFOmx1jLvsjugUuMoPmiKcKceathbWQaHHfrQGwZvl1dAaFt0gOnlVugEuMoPSefbs64cL6HvsCPPYEhoabXhHjLHdLHZnV5Lrzw(M(UqusCPXhrQ8M)KPSIYEVrAcCdBp9fTIObC7MiAa3eYDHOK4IY0nIujLHlgCU5gIasbxSihm4JHZn3GQd2kOUNN38spudJTfggajp)nS9uenGBpVyiFp38JG4JW86EZQRuqEtNugFaxUoRCaobcOm8OmDsz4szjkcK0Xfk1dRK4stL9oCacIpctkdpktNugUuwT74SlqCwy0RcIGsPvqssyDwyGKefL5dLHlL5QoPmHkLvKYWHYkPekBdiaL5dLPdkdhkdhkdpkBdiaL5dLfQBEZlJYS8TMpktyrjCZFYuwrzV3inbUHTN(Iwr0aUDtenGBHiFuMWIsGYWTio3CdraPGlwKdg8XW5MBq1bBfu3ZZBEPhQHX2cddGKN)g2EkIgWTNxedN75MFeeFeMx3BwDLcYBz7YveCQDhNDbIIYWJYWLYWLYGqkqkqamDQnr1BQ0QDCQv7fOSskHY4d4Y1rGmgrRwZvJ72Q0jqaLHdLHhLXhWLRtarFhlRPYfiUs9obcOm8OSjWhWLRZIes6vwbhvIQHPmHGYkfLHhLPtkJpGlxNMpktyrPSjobcOm8OSnGiRAc6cW6ud2fijL5dLfQsrz4CZBEzuMLVPKK5IC1kKsJBWw(M)KPSIYEVrAcCdBp9fTIObC7MiAa3mjzUixTcj0QOSqhSLV5gIasbxSihm4JHZn3GQd2kOUNN38spudJTfggajp)nS9uenGBpVigm3Zn)ii(imVU3S6kfK34d4Y1jSmgLexAduvVKaobcOm8OmCPmDszqififiaMoH7ykxKsJaf42bKPwbzmszLucLHQPuyqdiWqckkZhHGYksz4CZBEzuMLVXDBvQQLt9Wn)jtzfL9EJ0e4g2E6lAfrd42nr0aUf6TvPQwo1d3CdraPGlwKdg8XW5MBq1bBfu3ZZBEPhQHX2cddGKN)g2EkIgWTNxetX75MFeeFeMx3BwDLcYBBarw1e0fG1PgSlqskZhHGYWNZnV5Lrzw(g3TvPMkxzy4M)KPSIYEVrAcCdBp9fTIObC7MiAa3c92QKYSCLHbkd3I4CZnebKcUyroyWhdNBUbvhSvqDppV5LEOggBlmmasE(By7PiAa3EErmH6EU5hbXhH519MvxPG8gQMsHbnGadjOOmFeckR4nV5Lrzw(2cJEvqeukTcssc7n)jtzfL9EJ0e4g2E6lAfrd42nr0aU5gg9QGiOuuwiijjSugUfX5MBicifCXICWGpgo3CdQoyRG6EEEZl9qnm2wyyaK883W2tr0aU98Iy0X9CZpcIpcZR7nRUsb5nCPSA3XzxG4SWOxfebLsRGKKW6SWajjkkR0ugUuMR6KYeQuwrkdhkRKsOm(aUCDCHs9WkjU0uzVdhvIQHPmHGYWWHYWHYWJYQDhNDbId)cOuVwZvtjjZf5QviNfgijrrz(qzBabuoPCaAzRPdkdpklrrGKoUqPEyLexAQS3Hdqq8ryEZBEzuMLVXDBvQPYvggU5pzkROS3BKMa3W2tFrRiAa3UjIgWTqVTkPmlxzyGYWnu4CZnebKcUyroyWhdNBUbvhSvqDppV5LEOggBlmmasE(By7PiAa3EErmL6EU5hbXhH519MvxPG8MoPm(aUCDw5aCceqz4rz4sz6KYsueiPJluQhwjXLMk7D4aeeFeMuwjLqz1UJZUaXzHrVkickLwbjjH1zHbssuuMpugUuMR6KYWHYW5M38YOmlFR5JYewuc38NmLvu27nstGBy7PVOvenGB3erd4wiYhLjSOeOmCdfo3CdraPGlwKdg8XW5MBq1bBfu3ZZBEPhQHX2cddGKN)g2EkIgWTNxeJq5EU5hbXhH519MvxPG8wT74SlqC4xaL61AUAkjzUixTc5SWajjkkZhkdtPOm8OSnGiRAc6cW6ud2fijLvAHGYWNdLHhLTbeq5KYbOLTwOOmFOmx15nV5Lrzw(M(EjAnxTcssc7n)jtzfL9EJ0e4g2E6lAfrd42nr0aUjK7LqznxkleKKe2BUHiGuWflYbd(y4CZnO6GTcQ755nV0d1WyBHHbqYZFdBpfrd42ZlIb)75MFeeFeMx3BwDLcYB1UJZUaXHFbuQxR5QPKK5IC1kKZcdKKOOmFOSnGakNuoaTS10XnV5Lrzw(g3TvPMkxzy4M)KPSIYEVrAcCdBp9fTIObC7MiAa3c92QKYSCLHbkdxDGZn3qeqk4If5GbFmCU5guDWwb1988Mx6HAySTWWai55VHTNIObC75ZBMaOkrrPqckLn5IflfMN)a]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170829.000820, [[da0traqiQeTjkvFcIuAuerNIeSlIAykQJHkwgLYZeLmnsu11irzBqKQ(gjY4evuNturwhePY8GiUNOs7JIQdkkAHuj9qrHjcrkUOOuBKkHgjejNuuv3evANuYpjrflLI8uHPsLARIQ8vrf2lYFHYGv6Wewmj9yfMmQ6YGnRiFMkgnr60K61KqZgs3gQ2TKFRQHtHJtLGLl1Zfz6OCDQA7uu(oeopry9KOsZhIA)QmXHCtHLahOi04zCRl2FIH0DR6NULPhkQlhkcdyOfOALRGP)ISSPmouG0atcpkJCLctakisazzBMJsZ5STCsEEE2wwCOWei4LWTghOq1pnjl1xoqRlhS2xagcqy8LCd4cDLOiZbt)vICtwCi3uKDjurbEYvkIrRnyui5TTV0dmJhb0YdF3qXU18CVnR5Brg5Bv9ttYs9Ld06YbR9fGHaegFj7nUvHBTFRK3k5TQ(Pj5wJdYEJBTFl4cETHbWlBaDcmdArnaSFcJjfWa1VWWfntI(wfUfzKVvYBzcuOyYocMuO1LdwI9nUmucvuG)w73k5TQ(Pj5gW)obOqkHHqxmOLBaxOR0Tij3BDg83ImY36YBv9ttYnG)DcqHucdHUyql7nUvHBv4wfOitvnQMjbfnG)DcqHucdHUyqtr(fVEiyFtr9fqb3NpprBjWbkOWsGduycW)obOqkDBo0fdAkmbOGibKLTzokXzMctq699asKBIrrgsHHICFZaCOyKkfCFElboqbXilBKBkYUeQOap5kfXO1gmkK8wjVT9LEGz8iGwE47gk2TMN7T2MV1(TjGHP(LpjZ0qZjNWuEJXTMF78TkClYiFB7l9aZ4raT8W3nuSBnp3BZA(wKr(wv)0KSuF5aTUCWAFbyiaHXxYEJBv4w73Q6NMKBnoi7nOitvnQMjbfsFeO6YbtfvKyuKFXRhc23uuFbuW95Zt0wcCGckSe4afi1Javxo36kQiXOWeGcIeqw2M5OeNzkmbP33dirUjgfzifgkY9ndWHIrQuW95Te4afeJSYICtr2Lqff4jxPigT2GrrcyyQF5tYmn02MXSzmU18BNV1(TTV0dmJhb0YdF3qXU18BZzLDR9BBFb3IKCVnRBTFRQFAs2qJIkASFcBQ)et2BqrMQAuntckM6pXWsSwRiqr(fVEiyFtr9fqb3NpprBjWbkOWsGdu4I9Ny3gSwRiqHjafejGSSnZrjoZuycsVVhqICtmkYqkmuK7BgGdfJuPG7ZBjWbkigzP8KBkYUeQOap5kfXO1gmkAFPhygpcOLh(UHIDlsY9wLxz3ImY32(csYmnoGXEmLDlsU1zWFlYiFRQFAswQVCGwxoyTVameGW4l5gWf6kDR55ERnkYuvJQzsqXRIQzqlyaf5x86HG9nf1xafCF(8eTLahOGclboqHYrfvZGwWakmbOGibKLTzokXzMctq699asKBIrrgsHHICFZaCOyKkfCFElboqbXilLrUPi7sOIc8KRueJwBWOG9ooOG84Fu(hrLU1(TsEB7l9aZ4raT8W3nuSBrYTknFR9BD5TQ(PjzP(YbAD5G1(cWqacJVK9g3A)22xWTi5wB3A)2X)O8pIswTbbtk2pHL0fFlC(KqUbCHUs3A(TzPSBTFl4cETHbWlp(YmODGAay)e2KGbPBvGImv1OAMeui1xoqRlhS2xagcqy8ff5x86HG9nf1xafCF(8eTLahOGclboqbs5lhO1LZTM8fCBoaHXxuycqbrcilBZCuIZmfMG077bKi3eJImKcdf5(Mb4qXivk4(8wcCGcIrwi9KBkYUeQOap5kfXO1gmkyVJdkip(hL)ruPBTFRK32(spWmEeqlp8Ddf7wKCRYMV1(TU8wv)0KSuF5aTUCWAFbyiaHXxYEJBTFB7lijZ04ag7XSDR55EBw3A)2X)O8pIswTbbtk2pHL0fFlC(KqUbCHUs3A(TznFRcuKPQgvZKGcP(YbAD5G1(cWqacJVOi)IxpeSVPO(cOG7ZNNOTe4afuyjWbkqkF5aTUCU1KVGBZbim(6wj5OafMauqKaYY2mhL4mtHji9(EajYnXOidPWqrUVzaoumsLcUpVLahOGyKLsKBkYUeQOap5kfXO1gmkyVJdkip(hL)ruPBTFRK32(spWmEeqlp8Ddf7wKCBwk7w736YBv9ttYs9Ld06YbR9fGHaegFj7nU1(TTVGKmtJdyShZ2TMN7T2U1(TJ)r5FeLSAdcMuSFclPl(w48jHCd4cDLU18BZA(wfOitvnQMjbfs9Ld06YbR9fGHaegFrr(fVEiyFtr9fqb3NpprBjWbkOWsGduGu(YbAD5CRjFb3Mdqy81TsAtbkmbOGibKLTzokXzMctq699asKBIrrgsHHICFZaCOyKkfCFElboqbXiRCMCtr2Lqff4jxPigT2Grb7DCqb5X)O8pIkDR9BL822x6bMXJaA5HVBOy3IKBTnFR9BD5TQ(PjzP(YbAD5G1(cWqacJVK9g3A)22xqsMPXbm2Jz7wZZ9wo3A)2X)O8pIswTbbtk2pHL0fFlC(KqUbCHUs3A(TznFRcuKPQgvZKGcP(YbAD5G1(cWqacJVOi)IxpeSVPO(cOG7ZNNOTe4afuyjWbkqkF5aTUCU1KVGBZbim(6wjZsbkmbOGibKLTzokXzMctq699asKBIrrgsHHICFZaCOyKkfCFElboqbXiRCICtr2Lqff4jxPigT2Grb7DCqb5X)O8pIkDR9BL8wjVfCbV2Wa4LhFL(MLWgpkp24B4wKr(wv)0KSHgfv0y)e2u)jMS34wfU1(TQ(PjzFj9rLalXAOCysL9g3A)wEq1pnj3cL736biNyIHI3M7Tk7w736YBv9ttYVkQMbTGP)s2BCRcuKPQgvZKGIKU4BHZNejSjFlbf5x86HG9nf1xafCF(8eTLahOGclboqrOl(w48jbsB6wx03sqHjafejGSSnZrjoZuycsVVhqICtmkYqkmuK7BgGdfJuPG7ZBjWbkigzXzMCtr2Lqff4jxPigT2GrHQFAswrnkQUCWWfdP6cK9g3A)wjV1L3cUGxBya8Yk(OmDlsyfGy69fpgcnk6TiJ8Tmbkumzhbtk06YblX(gxgkHkkWFlYiFRyW0Mbyqb4AiDR55ERTBvGImv1OAMeum1FILgsWKcuKFXRhc23uuFbuW95Zt0wcCGckSe4afUy)jwAibtkqHjafejGSSnZrjoZuycsVVhqICtmkYqkmuK7BgGdfJuPG7ZBjWbkigzXHd5MISlHkkWtUsrmATbJcXGPndWGcW1q6wZZ9wBuKPQgvZKGIgW)obOqkHHqxmOPi)IxpeSVPO(cOG7ZNNOTe4afuyjWbkmb4FNauiLUnh6Ib9TsYrbkmbOGibKLTzokXzMctq699asKBIrrgsHHICFZaCOyKkfCFElboqbXilo2i3uKDjurbEYvkIrRnyu0(spWmEeqlp8Ddf7wKK7TkPSBrg5BBFb3A(TzrrMQAuntckEvundAbdOi)IxpeSVPO(cOG7ZNNOTe4afuyjWbkuoQOAg0cgCRKCuGctakisazzBMJsCMPWeKEFpGe5MyuKHuyOi33mahkgPsb3N3sGduqmYItwKBkYUeQOap5kfXO1gmkAFPhygpcOLh(UHIDlsUvP5BTFRlVv1pnjl1xoqRlhS2xagcqy8LS34w732(csYmnoGXESSU18BDg8uKPQgvZKGcPFxy)egcDXGMI8lE9qW(MI6lGcUpFEI2sGduqHLahOaP(UU9NUnh6IbnfMauqKaYY2mhL4mtHji9(EajYnXOidPWqrUVzaoumsLcUpVLahOGyKfhLNCtr2Lqff4jxPigT2Grb7DCqb5X)O8pIkDR9BL822x6bMXJaA5HVBOy3IKBTnFRcuKPQgvZKGca34ranw7ladbim(II8lE9qW(MI6lGcUpFEI2sGduqHLahOiBCJhb03AYxWT5aegFrHjafejGSSnZrjoZuycsVVhqICtmkYqkmuK7BgGdfJuPG7ZBjWbkigXOigT2GrbXic]] )

    storeDefault( [[SimC Frost: bos generic]], 'actionLists', 20170829.000820, [[daKmsaqiQe2euvFIkrYOGkofuPvrLi2fPAyeYXKsltk6zekAAekDncf2guO6BqvghvIQZjiQ1rLi18Gc5EqbTpQQCqQkwivspKQWfPkAJqbgjuOCsQkDtO0oj4NccwkvQNszQuL2kvv9vbH2RQ)sfdgLddzXi5XsmzP6YGnJu(mP0OjfNMOxlOMTq3ws7gXVvmCKQJliYYv65KmDrxxGTtO67sHZdfTEQeL5liTFu9BV3BEsqurOFQBcOkCZKvp4mmyhv6sZzuJIZ0ceyLLBUHiGuWfAkQfprU8MHSE7nJouKOO0LHs5qUqtXO9MpLuoe19EH279MNeeve631BwzL0ZBjkcKuxwW0jrXHO0bcIkcDodFoJkGgnDzbtNefhIsFHkssuCggXzAlDodFoRmtSpni6ulGsnodnhLK0xK2rH0xOIKefN5hNTbeqPNYk4KJJyV5dLmktmVrBhv6OYvggU5lPllOC2BKHa3WoD)rRaQc3UjGQWnmyhvYzwUYWWn3qeqk4cnf1IxROBUb1eSfqDVpV5HgOeg7ioubsEQByNUaQc3EEHM37npjiQi0VR3SYkPN3sueiPUwuQbwjrRJkNTQdeeve638HsgLjM3wOoRcIGs50qssyV5lPllOC2BKHa3WoD)rRaQc3UjGQWn3qDwfebLIZcrjjH9MBicifCHMIAXRv0n3GAc2cOU3N38qducJDehQajp1nStxavHBpVGyEV38KGOIq)UEZkRKEEJkGgn9vwb9a6Cg(C2gqaLEkRGtooILZWiodhotBPZzUeoRjNH7nFOKrzI5nntJOKO1HkIu5nFjDzbLZEJme4g2P7pAfqv42nbufUHXMgrjrlN5AePYBUHiGuWfAkQfVwr3CdQjylG6EFEZdnqjm2rCOcK8u3WoDbufU98cI9EV5jbrfH(D9Mvwj982gqaLEkRGtooyCodJ4mTLoNHpN5colrrGK6ArPgyLeToQC2QoqqurOFZhkzuMyEBOIYewuc38L0Lfuo7nYqGByNU)OvavHB3eqv4wiqfLjSOeU5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42Zlig37npjiQi0VR3SYkPN32acO0tzfCYXrSCggXzAlDodFodhoRmtSpni6ulGsnodnhLK0xK2rH0xOIKefN5hNjIZcnuoBdiYId9PbS6LGDbsYzyeNHNiod3B(qjJYeZBdvuMWIs4MVKUSGYzVrgcCd709hTcOkC7MaQc3cbQOmHfLaNHtlU3CdraPGl0uulETIU5gutWwa19(8MhAGsySJ4qfi5PUHD6cOkC75fW437npjiQi0VR3SYkPN32aIS4qFAaREjyxGKCMFyiNfYIbNHpNPG0HAibk9ucBBi7iw6foZpoteNHpNvMj2NgeDQfqPgNHMJss6ls7Oq6lursIIZ8JZeDZhkzuMyEJ2oQ0rLRmmCZxsxwq5S3idbUHD6(JwbufUDtavHByWoQKZSCLHbodNwCV5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42ZlG39EZtcIkc976nRSs65nQaA00xzf0dOZz4ZzqifiPth660HvbIdlIuaNHMtQbCaQH4urBI5EZhkzuMyEBH6SkickLtdjjH9MVKUSGYzVrgcCd709hTcOkC7MaQc3Cd1zvqeukoleLKewodNwCV5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42Zl4YV3BEsqurOFxVzLvspVrfqJM(kRGEaDodFodhoJkGgn9fQZQGiOuonKKew9a6CwOHYzLzI9PbrFH6SkickLtdjjHvFHkssuCMFCM2sNZcnuodhoZfCgesbs60HUoDyvG4WIifWzO5KAahGAiov0MyUCg(CMl4SefbsQRfLAGvs06OYzR6abrfHoNHlNH7nFOKrzI5nntJOKO1HkIu5nFjDzbLZEJme4g2P7pAfqv42nbufUHXMgrjrlN5AePsodNwCV5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42ZleY37npjiQi0VR3SYkPN3CbNrfqJM(kRGEaDodFoZfCgoCwIIaj11IsnWkjADu5SvDGGOIqNZWNZCbNHdNvMj2Nge9fQZQGiOuonKKew9fQijrXz(Xz4WzAlDoZLWzn5mC5SqdLZ2acWz(XzILZWLZWLZWNZ2acWz(XzI5nFOKrzI5THkktyrjCZxsxwq5S3idbUHD6(JwbufUDtavHBHavuMWIsGZWPjU3CdraPGl0uulETIU5gutWwa19(8MhAGsySJ4qfi5PUHD6cOkC75fAfDV38KGOIq)UEZkRKEElhTAJGEzMyFAquCg(CgoCgoCgesbs60HUEziQztLtzIDNYSaNfAOCgvanA60LXiADgAo02rL6b05mC5m85mQaA00diAMiMoQCbI2uJEaDodFoRdub0OPVix2SYcORsujmNHHCMyWz4ZzUGZOcOrtFOIYewukhIEaDod3B(qjJYeZBkjPViTJcPCOfSyEZxsxwq5S3idbUHD6(JwbufUDtavHBMK0xK2rHCPuCggeSyEZnebKcUqtrT41k6MBqnbBbu37ZBEObkHXoIdvGKN6g2PlGQWTNxOT9EV5jbrfH(D9Mvwj98gvanA6HLXOKO1PIkAKeqpGoNHpNHdN5codcPajD6qxp8et5IuoeObTjG0DAiJrol0q5mujLIdoabQsqXz(HHCwtod3B(qjJYeZB02rLQcMPg4MVKUSGYzVrgcCd709hTcOkC7MaQc3WGDuPQGzQbU5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42Zl028EV5jbrfH(D9Mvwj982gqKfh6tdy1lb7cKKZ8dd5m8eDZhkzuMyEJ2oQ0rLRmmCZxsxwq5S3idbUHD6(JwbufUDtavHByWoQKZSCLHbodNM4EZnebKcUqtrT41k6MBqnbBbu37ZBEObkHXoIdvGKN6g2PlGQWTNxOvmV3BEsqurOFxVzLvspVHkPuCWbiqvckoZpmKZAEZhkzuMyEBH6SkickLtdjjH9MVKUSGYzVrgcCd709hTcOkC7MaQc3Cd1zvqeukoleLKewodNM4EZnebKcUqtrT41k6MBqnbBbu37ZBEObkHXoIdvGKN6g2PlGQWTNxOvS37npjiQi0VR3SYkPN3WHZkZe7tdI(c1zvqeukNgsscR(cvKKO4mmIZWHZ0w6CMlHZAYz4YzHgkNrfqJMUwuQbwjrRJkNTQRsujmNHHCwRiodxodFoRmtSpni6ulGsnodnhLK0xK2rH0xOIKefN5hNTbeqPNYk4KJJy5m85SefbsQRfLAGvs06OYzR6abrfH(nFOKrzI5nA7OshvUYWWnFjDzbLZEJme4g2P7pAfqv42nbufUHb7OsoZYvgg4mCetCV5gIasbxOPOw8AfDZnOMGTaQ795np0aLWyhXHkqYtDd70fqv42Zl0kg37npjiQi0VR3SYkPN3CbNrfqJM(kRGEaDodFodhoZfCwIIaj11IsnWkjADu5SvDGGOIqNZcnuoRmtSpni6luNvbrqPCAijjS6lursIIZ8JZWHZ0w6CgUCgU38HsgLjM3gQOmHfLWnFjDzbLZEJme4g2P7pAfqv42nbufUfcurzclkbodhXe3BUHiGuWfAkQfVwr3CdQjylG6EFEZdnqjm2rCOcK8u3WoDbufU98cTy879MNeeve631BwzL0ZBLzI9PbrNAbuQXzO5OKK(I0okK(cvKKO4m)4SwXGZWNZ2aIS4qFAaREjyxGKCggHHCgEI4m85SnGak9uwbNCCetoZpotBPFZhkzuMyEtZSeNHMtdjjH9MVKUSGYzVrgcCd709hTcOkC7MaQc3WyZs4SHgNfIssc7n3qeqk4cnf1IxROBUb1eSfqDVpV5HgOeg7ioubsEQByNUaQc3EEHw8U3BEsqurOFxVzLvspVvMj2NgeDQfqPgNHMJss6ls7Oq6lursIIZ8JZ2acO0tzfCYXrS38HsgLjM3OTJkDu5kdd38L0Lfuo7nYqGByNU)OvavHB3eqv4ggSJk5mlxzyGZWrS4EZnebKcUqtrT41k6MBqnbBbu37ZBEObkHXoIdvGKN6g2PlGQWTNpVzLvspV98ha]] )

    storeDefault( [[SimC Frost: machinegun]], 'actionLists', 20170829.000820, [[deKxyaqiesBsu6tKaQrjv6usfRsuuXUiPHrkDmrSmsLNrc00ifvxdHW2efv9nsOXjkkNdHO1jkQ08efCpsq7JuehKuyHubpKQWfPcTrrr(ijGmssaojvLUjc2jr(POqwkPQNszQuL2kvfFvuO2RQ)sLgmkhgyXq5XszYq1Lv2Su1NPIgnj60eEnvvZwOBJODd63qgUiDCsrz5O65cMUKRtuBxu57iuNxu16jfP5tv0(r6NCV3CecWId)y3KaK7Mji9GYYehfQmxkJe0ukGZPm8M(fhiSlPtBIIAZmDePAYnlDnbik0uqjqWlPJisUPrReiy4EVuY9EZrialo87WnRXfP1Tc50zCQnekIJiggOSSuwxkRlLrukRaXbl1Eosth0nvogM6GaS4WPmp9KY6szCz4OSmqz6OSSugxgkAUPiIhxTjZ5dwuwgOmDzgL1HY6qzzPmIszfioyP6eukhxaD6gkeNuDqawC4uwNBAGjIIk)newuuJdkbcEZxiUObke)geb3nciCFaCja5UDtcqUBzewuuJdkbcEt)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96s6U3BocbyXHFhUznUiTUHj33RkA5DlqebdQ8rceWaLLbklrLiOSSuwbIdwQIwE3cerWG6GaS4WVPbMikQ8365Oq5gkUW)U5lex0afIFdIG7gbeUpaUeGC3Ujbi3TmXrHIYSIl8VB6xCGWUKoTjkMO9M(fqY82c37RBEOCn)eq5g5G1XUraHlbi3TxxsbV3BocbyXHFhUznUiTUvG4GLAqjOQXfqNUHIl8VG6GaS4WPSSug(WK77v5anfXfTPgkqZpLPqkJiUPbMikQ8365Oq5gkUW)U5lex0afIFdIG7gbeUpaUeGC3Ujbi3TmXrHIYSIl8pkRBsNB6xCGWUKoTjkMO9M(fqY82c37RBEOCn)eq5g5G1XUraHlbi3TxxsZV3BocbyXHFhUznUiTU1LY6szyY99QCb5uLtPSSu20mzrA6WvthpSCJdGT5I6DlLZDyiOljGx55uwhkZtpPScehSuDckLJlGoDdfItQoialoCkRdLLLYikL1LYWK77vryrrnoOeiOQCkLLLYaTsKBUdosXcuwgOmDuwNBAGjIIk)n(ir8WIleCjwaRXV5lex0afIFdIG7gbeUpaUeGC3Ujbi3n9JeXdlUqGYYybSg)M(fhiSlPtBIIjAVPFbKmVTW9(6MhkxZpbuUroyDSBeq4saYD71LiI79MJqawC43HBwJlsRByY99QCb5uLtPSSugrPSUugMCFVkclkQXbLabvLtPSSugOvICZDWrkwGYYaLPJY6qzzPmIszDPSPzYI00HRMoEy5ghaBZf17wkN7WqqxsaVYZPSSuwbIdwQobLYXfqNUHcXjvheGfhoL15MgyIOOYFtjI4Oa60flcc1nFH4IgOq8BqeC3iGW9bWLaK72nja5UPaqehfqNuMdrqOUPFXbc7s60MOyI2B6xajZBlCVVU5HY18taLBKdwh7gbeUeGC3EDPm)9EZrialo87WnRXfP1nm5(EvUGCQYPuwwkJOuwxkdtUVxfHff14GsGGQYPuwwkd0krU5o4iflqzzGY0rzDOSSu20mzrA6WvthpSCJdGT5I6DlLZDyiOljGx55uwwkRaXblvNGs54cOt3qH4KQdcWIdNYYszDPm8Hj33RMoEy5ghaBZf17wkN7WqqxsaVYZvLtPmp9KYAiuehrmuLpsepS4cbxIfWACv(ibcyGY0ektbPSo30atefv(BkrehfqNUyrqOU5lex0afIFdIG7gbeUpaUeGC3Ujbi3nfaI4Oa6KYCiccfL1nPZn9loqyxsN2eft0Et)cizEBH791npuUMFcOCJCW6y3iGWLaK72RlP49EZrialo87WnRXfP1nIszyY99QiSOOghuceuvoLYYszDPSPzYI00HR6hflbheCHJ4EKme3LyrmszzPScehSu75inDq3u5yyQdcWIdNYYszDPSWkxmeuoOwIXtisxDPnktHuwcL5PNuwyLlgckhulX4jePRMN2OmfszjuwhkRdL5PNugxgUGAjiNBHCjcklduMZg(nnWerrL)gclkQXb1U5lex0afIFdIG7gbeUpaUeGC3Ujbi3TmclkQXb1UPFXbc7s60MOyI2B6xajZBlCVVU5HY18taLBKdwh7gbeUeGC3EDPm7EV5ieGfh(D4M14I06wHC6mo1gcfXredduwwkRlL1LYikLvG4GLAphPPd6MkhdtDqawC4uMNEszDPmUmCuwgOmDuwwkJldfn3ueXJR2K58blklduMUmJY6qzDOSSuwbIdwQobLYXfqNUHcXjvheGfhoLLLYWK77v5JeXdlUqWLybSgxvoLY6Ctdmruu5VHWIIACqjqWB(cXfnqH43Gi4UraH7dGlbi3TBsaYDlJWIIACqjqqkRBsNB6xCGWUKoTjkMO9M(fqY82c37RBEOCn)eq5g5G1XUraHlbi3TxxIiV3BocbyXHFhUznUiTUviNoJtTHqrCeXWaLLLY6szDPSPzYI00HR2qWaIxb3gkI72q8rzE6jLHj33RMkIra3f172ZrHsvoLY6qzzPmm5(EvzOsumVBO4d6SuQkNszzPm8Hj33RYbAkIlAtnuGMFktHugrqzzPmIszyY99QiSOOghuceuvoLY6Ctdmruu5VfeqCoWjkacU9Y8838fIlAGcXVbrWDJac3haxcqUB3KaK7MjG4CGtuaOahOSmjZZFt)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96sjAV3BocbyXHFhUznUiTU1LYikLHj33RIWIIACqjqqv5ukllLXLHIMBkI4XvXxVOjkkldkKYs0szDOmp9KY6szyY99QiSOOghuceuvoLYYszeLYWK77v9lIrb0PljOPuaNQCkL15MgyIOOYFRNJcLBO4c)7MVqCrdui(nicUBeq4(a4saYD7MeGC3YehfkkZkUW)OSU66Ct)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96sjj37nhHaS4WVd3SgxKw3aTsKBUdosXcuMMOqkthLLLYikL1LYkqCWsTNJcvOLVuo1bbyXHtzzPmm5(Ev)IyuaD6scAkfWPkNszzPmqRe5M7GJuSaLPjkKY0rzDUPbMikQ834JeXdlUqWLybSg)MVqCrdui(nicUBeq4(a4saYD7MeGC30psepS4cbklJfWACkRBsNB6xCGWUKoTjkMO9M(fqY82c37RBEOCn)eq5g5G1XUraHlbi3Txxkr39EZrialo87WnRXfP1nm5(Ev)IyuaD6scAkfWPkNszzPSUugrPSPzYI00HR6hflbheCHJ4EKme3LyrmszE6jLbALi3ChCKIfOmnrHuMokRZnnWerrL)wphfQqlFPC38fIlAGcXVbrWDJac3haxcqUB3KaK7wM4OqfA5lL7M(fhiSlPtBIIjAVPFbKmVTW9(6MhkxZpbuUroyDSBeq4saYD71LsuW79MJqawC43HBwJlsRBGwjYn3bhPybkttuiLP7MgyIOOYFZze0eGOlapha22nFH4IgOq8BqeC3iGW9bWLaK72nja5UPafbnbiszAGNdaB7M(fhiSlPtBIIjAVPFbKmVTW9(6MhkxZpbuUroyDSBeq4saYD71Ls0879MJqawC43HBwJlsRBGwjYn3bhPybkttuiLPG30atefv(B9CuOcT8LYDZxiUObke)geb3nciCFaCja5UDtcqUBzIJcvOLVuokRBsNB6xCGWUKoTjkMO9M(fqY82c37RBEOCn)eq5g5G1XUraHlbi3TxxkHiU3BocbyXHFhUznUiTUHj33R6xeJcOtxsqtPaov50BAGjIIk)newuuJdQDZxiUObke)geb3nciCFaCja5UDtcqUBzewuuJdQrzDt6Ct)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96sjz(79MJqawC43HBwJlsRBfioyP6eukhxaD6gkeNuDqawC4uwwkRaXblvszo(4i5G767fnXGT8QdcWIdNYYszDPSWkxmeuoOwIXtisxDPnktHuwcL5PNuwyLlgckhulX4jePRMN2OmfszjuwNBAGjIIk)TEokuUHIl8VB(cXfnqH43Gi4UraH7dGlbi3TBsaYDltCuOOmR4c)JY6QGDUPFXbc7s60MOyI2B6xajZBlCVVU5HY18taLBKdwh7gbeUeGC3EDPefV3BocbyXHFhUznUiTU1LYkqCWsvjIdDr9UelG14QdcWIdNY80tkRaXblvLYqNJlGoD5YW5s8aPiO6GaS4WPSouwwkRlLfw5IHGYb1smEcr6QlTrzkKYsOmp9KYcRCXqq5GAjgpHiD180gLPqklHY6Ctdmruu5V1ZrHYnuCH)DZxiUObke)geb3nciCFaCja5UDtcqUBzIJcfLzfx4FuwxnVZn9loqyxsN2eft0Et)cizEBH791npuUMFcOCJCW6y3iGWLaK72RlLKz37nhHaS4WVd3SgxKw3kKtNXP2qOioIyyGYYszDPmIszyY99QkLHohxaD6YLHZL4bsrqv5ukllLXLHlOwcY5wixfKY0ekZzdNYYCOmDuwwkJldfn3ueXJR2K58blklduMoIGY6Ctdmruu5VPug6CCb0PlxgoxIhifbV5lex0afIFdIG7gbeUpaUeGC3Ujbi3nfGm054cOtktVmCuwgpqkcEt)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96sje59EZrialo87WnnWerrL)gclkQXb1U5lex0afIFdIG7gbeUpaUeGC3Ujbi3TmclkQXb1OSU66Ct)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96s60EV3CecWId)oCtdmruu5V5mcAcq0fGNdaB7MVqCrdui(nicUBeq4(a4saYD7MeGC3uGIGMaePmnWZbGTrzDt6Ct)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96s6sU3BocbyXHFhUznUiTUrukdtUVxvPm054cOtxUmCUepqkcQkNEtdmruu5VPeXHUOExIfWA8B(cXfnqH43Gi4UraH7dGlbi3TBsaYDtbG4qkd1tzzSawJFt)Ide2L0PnrXeT30VasM3w4EFDZdLR5Nak3ihSo2nciCja5U96s60DV3CecWId)oCtdmruu5V1ZrHYnuCH)DZxiUObke)geb3nciCFaCja5UDtcqUBzIJcfLzfx4FuwxIOZn9loqyxsN2eft0Et)cizEBH791npuUMFcOCJCW6y3iGWLaK72RlPtbV3BocbyXHFhUznUiTUviNoJtTHqrCeXWWnnWerrL)2itrepUlxgoxIhifbV5lex0afIFdIG7gbeUpaUeGC3Ujbi3nhjtrepoLPxgoklJhifbVPFXbc7s60MOyI2B6xajZBlCVVU5HY18taLBKdwh7gbeUeGC3E96M14I062RFa]] )

    storeDefault( [[SimC Frost: CDs]], 'actionLists', 20170829.000820, [[deuenaqiuj2KcAusLCkPI2fvAyk0XKQwMc8mujnnPsX1avABIi4BKcJduvDoqvP1bvzEGkCpreTpqvoiuvlevQhskzIGQIlsQQnkI0iLkL6KKQCtqzNO0qLkvlveEkLPsQCvreARIOERuPK7cQiTxv)fkdMOdlzXO4XkAYs5YiBMk(minAOYPj51OIMTOUnQA3q(TWWbXXbvulxPNtvth46I02jf9DuHZtk16bveZxQW(j87VUB6JkMm1oZn2INUzkETeYKUHhGNqQf8XFlbLPYtNDWyVgJW)a4RB)ndcnvvwbNuavGo7a42Fd)jqfi)1D2(R7M(OIjtTZ9nBUkiGBBksnXGeCqRBJCutfqiHNqoyuihkKCribvMqaxMLkaoSWbZRqTTGg(YLqftMA3WNrLvaTVv7Sqegi2LqGB6HAQzbI9gkq0nyrl5AzlE62n2INUH)olejK6IDje4wcktLNo7GXEn6hVLG8r6oj)1DWnTWrtoHfAs8ecCMBWIgBXt3o4SdUUB6JkMm1o33S5QGaUbQmHaUmlvaCyHdMxHABbn8LlHkMm1eYHczlaUmlvaCyHdMxHABbn8Llqn5uHGkKdfYnfPMyqcoO1DMUlHacjCiKCDuihkKBkIes4qihCdFgvwb0(wTZcryGyxcbUPhQPMfi2BOar3GfTKRLT4PB3ylE6g(7SqKqQl2LqaHSR(oVLGYu5PZoySxJ(XBjiFKUtYFDhCtlC0KtyHMepHaN5gSOXw80TdolxVUB6JkMm1o33S5QGaUbcOqZK7mICl4a5fYHczxcjtQJJlevoxlw4G5SHh4Mcri78g(mQScO9nMCenmN0v7B6HAQzbI9gkq0nyrl5AzlE62n2INUXDoIMqM00v7BjOmvE6Sdg71OF8wcYhP7K8x3b30chn5ewOjXtiWzUblASfpD7GZ2nx3n9rftMAN7B2Cvqa3abuOzYDgrUfCG8c5qHSlHKj1XXfIkNRflCWC2WdCtHiKDEdFgvwb0(gdTEA5uHGEtputnlqS3qbIUblAjxlBXt3UXw80nUP1tlNke0BjOmvE6Sdg71OF8wcYhP7K8x3b30chn5ewOjXtiWzUblASfpD7GZc3R7M(OIjtTZ9n8zuzfq7BPEctbiE)n9qn1SaXEdfi6gSOLCTSfpD7gBXt3sIEsi1dq8(BjOmvE6Sdg71OF8wcYhP7K8x3b30chn5ewOjXtiWzUblASfpD7GZMeUUB6JkMm1o33S5QGaUTPiY7cu8egiWGRqchcjxfYHczxcjxeYwaCzwQa4WchmVc12cA4lxGAYPcbvi7OdHCtrQjgKGdADNP7siGqcpHmjmkKDEdFgvwb0(wBRuO4ayHdMpsZ(BAHJMCcl0K4je4m3GfTKRLT4PB3ylE6whthNIRCfUe1r3wbiE867Mr4Fe(Xdp8Wdp8WdV((r8ga3E8Wdp8WdVoW1TGpBLcfhqidhH0I0ShoTdCDS3WFH6VHkEkjBBLcfhalCW8rA2FlbLPYtNDWyVg9J3sq(iDNK)6o4MEOMAwGyVHceDdw0ylE62bNvJR7M(OIjtTZ9nBUkiGBGak0m5cjaQa5fYHczxcjtQJJlevoxlw4G5SHh4McrihkKDjKCribvMqaxMLkaoSWbZRqTTGg(YLqftMAczhDiKCriNrKBbhixMLkaoSWbZRqTTGg(YDj(sH8cj8eYrHStHSZB4ZOYkG23GeavGUPhQPMfi2BOar3GfTKRLT4PB3ylE6w3dGkq3sqzQ80zhm2Rr)4TeKps3j5VUdUPfoAYjSqtINqGZCdw0ylE62bNf(VUB6JkMm1o33S5QGaUXfHeuzcbCzwQa4WchmVc12cA4lxcvmzQDdFgvwb0(gevoxlw4G5SHhCtputnlqS3qbIUblAjxlBXt3UXw80TURY5AfYWrit6gEWTeuMkpD2bJ9A0pElb5J0Ds(R7GBAHJMCcl0K4je4m3Gfn2INUDWzHVx3n9rftMAN7B2Cvqa3avMqaxMLkaoSWbZRqTTGg(YLqftMAc5qHCgrUfCGCzwQa4WchmVc12cA4l3L4lfYlKWti7MXB4ZOYkG23GOY5AXchmNn8GB6HAQzbI9gkq0nyrl5AzlE62n2INU1DvoxRqgoczs3WdeYU678wcktLNo7GXEn6hVLG8r6oj)1DWnTWrtoHfAs8ecCMBWIgBXt3o4S9Jx3n9rftMAN7B2Cvqa3avMqaxMLkaoSWbZRqTTGg(YLqftMAc5qHKlc5mICl4a5YSubWHfoyEfQTf0WxUlXxkKxiHNqokKdfYnfPMyqcoO1DMUlHacj8ssHeUJc5qHKGZPkiqOM7mqAslucnjSWbZPaKxihkKZiYTGdKlUueuAviOyBkIW4GkibYDj(sH8cjCiK9J3WNrLvaTVbrLZ1IfoyoB4b30d1uZce7nuGOBWIwY1Yw80TBSfpDR7QCUwHmCeYKUHhiKDnOZBjOmvE6Sdg71OF8wcYhP7K8x3b30chn5ewOjXtiWzUblASfpD7GZ23FD30hvmzQDUVzZvbbCduzcbCzwQa4WchmVc12cA4lxcvmzQjKdfsUiKZiYTGdKlZsfahw4G5vO2wqdF5UeFPqEHeEc5Oqoui3uKAIbj4Gw3z6UeciKWljfs4okKdfsUiKeCovbbc1CNbstAHsOjHfoyofG8c5qHSlHCgrUfCGCXLIGsRcbfBtreghubjqUlXxkKxiHdHShUczhDiKGAHsaxGINWabwtrcj8eYEUcxHSZB4ZOYkG23GOY5AXchmNn8GB6HAQzbI9gkq0nyrl5AzlE62n2INU1DvoxRqgoczs3WdeYU4AN3sqzQ80zhm2Rr)4TeKps3j5VUdUPfoAYjSqtINqGZCdw0ylE62bNTFW1DtFuXKP25(MnxfeWnqafAMCNrKBbhiVqoui7sizsDCCHOY5AXchmNn8a3uiczN3WNrLvaTVXSubWHfoyEfQTf0Wx30d1uZce7nuGOBWIwY1Yw80TBSfpDJ7LkaoHmCestHABbn81TeuMkpD2bJ9A0pElb5J0Ds(R7GBAHJMCcl0K4je4m3Gfn2INUDWb3S5QGaUDWp]] )

    storeDefault( [[SimC Frost: cold heart]], 'actionLists', 20170829.000820, [[dKdeeaGEksAtuk7sv9AjX(ufnBjMpfPUjs1Trv7Kc7fA3e2VuJIIQHbKFR0JrzWkgUK6GucNIsYXeY5OiQfkjzPcLfJOLtQhku9urldPSoksCyvMkLQjJW0bDrkrFJsQNbuQRJkBKIGTcuSzbBxvW9KK60ennkImpkk9CsghqjJgj)fWjvL8DkkUgfHoVQuFgOABQcDzQgJq7yAP4ilobsIPXX7yMs(49yc6vbnLEyBHOhk)0qmJ5f)uoAqduK1GalAM8pcZS2zYRin1dkxbAqZeJW0cguUcfAhnIq7yAP4ilobwfMjtlRHysYfcF2wiaO8td)k4XQ0t19qdup26HKle(CcQT8gqb1UaCi1NRUhB9W2TqSMr8RLLYPb2aqqVk4x78NuO65zppIPfKYIe(gtg1jfkGnaizoMVees2bxnMIv4ysFjaZPnoEhtmnoEhZ4uNuO6zd98I5ygZl(PC0GgOiRJaHzmxTCAMRq7ieZ4uoRc99bN3fqKet6lHXX7yIq0GgAhtlfhzXjWQWmzAznetsUq4xllLtdSbGGEvWpxDp26HKle(1Ys50aBaiOxf8RD(tku9y2EaNr0JTEmVhsUq4Z2cbaLFA4xbpwLEEwDprr9yAt3J59qYfcF2wiaO8td)k4XQ0ZZQ7jcup26r5qaYvWP(qPRPbcWKQz98Shq9yvpwHPfKYIe(gtg1jfkGnaizoMVees2bxnMIv4ysFjaZPnoEhtmnoEhZ4uNuO6zd98I59yEKvygZl(PC0GgOiRJaHzmxTCAMRq7ieZ4uoRc99bN3fqKet6lHXX7yIq0aSr7yAP4ilobwfMjtlRHysYfcFob1wEdOGAxaoK6Zv3JTEi5cHpNGAlVbuqTlahs91o)jfQEmBpGZi6XwpKCHWNTfcak)0WVcESk98SNOh7XwpSDleRze)AzPCAGnae0Rc(1o)jfQEE2ZJyAbPSiHVXKrDsHcydasMJ5lbHKDWvJPyfoM0xcWCAJJ3XetJJ3Xmo1jfQE2qpVyEpMtZkmJ5f)uoAqduK1rGWmMRwonZvODeIzCkNvH((GZ7cisIj9LW44DmricXmzAzneteIi]] )
    
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

