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

                local spendMod = state.spec.unholy and ( 1 + state.artifact.runic_tattoos.rank * 0.0333 ) or 1

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

        if not PTR then
            --[[ White Walker: You take 30% reduced damage while Wraith Walk is active. When you enter or leave Wraith Walk, all nearby enemies are slowed by 70% for 3 sec. ]]
            addTalent( "white_walker", 212765 ) -- 22031
        else
            addTalent( "inexorable_assault", 253593 ) 
            addAura( "inexorable_assault", 253595, "duration", 10, "max_stack", 10 )
        end

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
        addAura( "hungering_rune_weapon", 207127, "duration", PTR and 12 or 15 )
        addAura( "icebound_fortitude", 48792, "duration", 8 )
        addAura( "icy_talons", 194879, "duration", 6, "max_stack", 3 )
        addAura( "killing_machine", 51128, "duration", 10 )
        addAura( "mastery_dreadblade", 77515 )
        addAura( "mastery_frozen_heart", 77514 )
        addAura( "necrosis", 207346, "duration", 30 )
        addAura( "on_a_pale_horse", 51986 )
        addAura( "obliteration", 207256, "duration", PTR and 10 or 8 )
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
            cooldown = PTR and 45 or 30,
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

            if PTR and buff.obliteration.up then
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
            applyBuff( "hungering_rune_weapon", PTR and 12 or 15 )
            if PTR then stat.spell_haste = ( ( 1 + stat.spell_haste ) * 1.2 ) - 1 end
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170718.213417, [[da0qtaqiGelsuv2esPrbK6uib7sHggiDmrzzkONHeAAIQORjQsBdjIVPaJdiPohqswhfkZdjQ7be2NOQ6GIklKuQhsrnrGOUisLncejFuuf6KivntGiUPIStq9trvWsjfpf1ujvDvkuTvkK9k9xGAWu1HvAXK0JfzYcUm0MbXNPGrJKonrVMuz2cDBa7gXVvz4kQJJePLt45uz6Q66Ky7Ks(osX5PiRhisTFkDZQ(YCsiN)YLbzeYQe)QDznyexhw4HqZgaDq2GXSbdZZ8cQlZZysUrji9(YJu4H5Dy5CPxEex1x4SQVmDKvnIHQDzojKZF5)myiIJP7IHJgIZ6P16bT1dkwpsPkY5zmmMrXbqhKxRNwRxOqKjWZhnOymGqKj5B9u26PiuRNcLZPkJY3u5Wk0bEfQYhfLPNeKP9przYrWYtxWOvaVay5YWlawgKxHoRpNqv(OOSgmIRdl8qOzdYGwwd6ofrcDvF)YMPIjDtNwias(QwE6cWlawUFHhw9LPJSQrmuTlZjHC(l)NbdrCmDxmC0qCwpTwpOTEKsvKZZyymJIdGoiVwpTwVqHitGNpAqXyaHitY36PS1trOwpTwF6Uy4OHmgwHoWVyjoiNayF5rgfiWkjoRNYw)qRNcLZPkJY3u5Wk0bEfQYhfLPNeKP9przYrWYtxWOvaVay5YWlawgKxHoRpNqv(OW6bDgfkRbJ46WcpeA2GmOL1GUtrKqx13VSzQys30PfcGKVQLNUa8cGL7xykw9LPJSQrmuTlZjHC(l)NbdrCmDxmC0qCwpTwpOTEHcbTEkdcRNIwpfkNtvgLVPYofaGJa2WkmCMIyz6jbzA)tuMCeS80fmAfWlawUm8cGLzfaGJy95Xvy4mfXYAWiUoSWdHMnidAznO7uej0v99lBMkM0nDAHai5RA5PlaVay5(fopR(Y0rw1igQ2L5Kqo)LvvGazuHq9IMa7Ebsm8uhvMTEATEvfiqgtxmaMkUIF09BsN1NFRpduvoNQmkFtLtuxjXb(GawMWY0tcY0(NOm5iy5Ply0kGxaSCz4falBM6kjoR)Gy90NWYAWiUoSWdHMnidAznO7uej0v99lBMkM0nDAHai5RA5PlaVay5(foVvFz6iRAedv7YCsiN)Y)zWqeht3fdhneN1tR1dARhPuf58mggZO4aOdYR1tR1NUlgoAiJHvOd8lwIdYja2xEKrbcSsIZ6PS1Nb16P16fke06PmiSEkA9uOCovzu(Mk7uaaocydRWWzkILPNeKP9przYrWYtxWOvaVay5YWlawMvaaoI1NhxHHZueTEqNrHYAWiUoSWdHMnidAznO7uej0v99lBMkM0nDAHai5RA5PlaVay5(fMsQ(Y0rw1igQ2L5Kqo)LdOQceiJqq3JcjXayAofsy09BsN1NFqy9uI1tR1NUlgoAiJ78L2OPzhokqGvsCwpLT(8SCovzu(Mk7oLiybUZOOm9KGmT)jktocwE6cgTc4falxgEbWY8PeTEn4oJIYAWiUoSWdHMnidAznO7uej0v99lBMkM0nDAHai5RA5PlaVay5(fEq1xMoYQgXq1UmNeY5VCavvGazec6EuijgatZPqcJUFt6S(8dcRNskNtvgLVPY78L2OPzhwMEsqM2)eLjhblpDbJwb8cGLldVay5CZxAJMMDyznyexhw4HqZgKbTSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cdQR(Y0rw1igQ2L5Kqo)Lfkezc88rdkgdiezs(wpLT(mOLZPkJY3u5aUpvWPtgltpjit7FIYKJGLNUGrRaEbWYLHxaSmiJ7t16nFYyznyexhw4HqZgKbTSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cdQQ(Y0rw1igQ2L5Kqo)LbfR)3is(XWk0bEfQYhfJizvJyW6P16vvGaz0PecibC4oGrLzRNwRhuSEvfiqgjysCoPBuz26P16fke06PmiSEkwoNQmkFtLd4(ubNozSm9KGmT)jktocwE6cgTc4falxgEbWYGmUpvR38jJwpOZOqznyexhw4HqZgKbTSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cNbT6lthzvJyOAxMtc58x(3is(XWk0bEfQYhfJizvJyW6P16vvGaz0PecibC4oGrLzRNwRpDxmC0qgdRqh4vOkFumkqGvsCwF(T(8A90A9cfcA9ugewpflNtvgLVPYbCFQGtNmwMEsqM2)eLjhblpDbJwb8cGLldVayzqg3NQ1B(KrRh0dPqznyexhw4HqZgKbTSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cNLv9LPJSQrmuTlZjHC(lhqvfiqgHGUhfsIbW0CkKWO73KoRNYwpLy90A9P7IHJgY4oFPnAA2HJceyLeN1tzqy9us5CQYO8nvgc6Euijga7EHuhwMEsqM2)eLjhblpDbJwb8cGLldVayzqk09Oqsmy98lK6WYAWiUoSWdHMnidAznO7uej0v99lBMkM0nDAHai5RA5PlaVay5(foBy1xMoYQgXq1UmNeY5VCavvGazec6EuijgatZPqcJUFt6S(8dcRNILZPkJY3uz3PeblWDgfLPNeKP9przYrWYtxWOvaVay5YWlawMpLO1Rb3zuy9GoJcL1GrCDyHhcnBqg0YAq3PisOR67x2mvmPB60cbqYx1YtxaEbWY9lCgfR(Y0rw1igQ2L5Kqo)LdOQceiJUtjcwG7mkgvMTEATEqX6dOQceiJqq3JcjXayAofsyuzUCovzu(MkdbDpkKedGDVqQdltpjit7FIYKJGLNUGrRaEbWYLHxaSmif6EuijgSE(fsDO1d6mkuwdgX1HfEi0SbzqlRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWz5z1xMoYQgXq1UmNeY5VCavvGaz0DkrWcCNrXOYS1tR1hqvfiqgHGUhfsIbW0CkKWO73KoRp)GW6ZkNtvgLVPYU0PimGGDVqQdltpjit7FIYKJGLNUGrRaEbWYLHxaSmNofHb065xi1HL1GrCDyHhcnBqg0YAq3PisOR67x2mvmPB60cbqYx1YtxaEbWY9lCwER(Y0rw1igQ2L5Kqo)LdOQceiJUtjcwG7mkgvMTEAT(aQQabYie09OqsmaMMtHegD)M0z95hewFw5CQYO8nvofxAKedGDu3WrJRm9KGmT)jktocwE6cgTc4falxgEbWYMJlnsIbRNPUHJgxznyexhw4HqZgKbTSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cNrjvFz6iRAedv7Y5uLr5BQCaHiJyz6jbzA)tuMCeS80fmAfWlawUm8cGLbzeImIL1GrCDyHhcnBqg0YAq3PisOR67x2mvmPB60cbqYx1YtxaEbWY9lC2GQVmDKvnIHQDzojKZF5n9sTqWibbKOZ6ZpiS(HLZPkJY3u50gJG30lpc4O09Lntft6MoTqaK8vT80fmAfWlawUm8cGLnVXO1Nl9YJy9GeP7lNtyWvMSaiiYhlbmB9gNq9IMmM1Nlpqx(kRbJ46WcpeA2GmOL1GUtrKqx13Vm9KGmT)jktocwE6cWlawMLaMTEJtOErtgZ6ZLhORFHZa1vFz6iRAedv7YCsiN)YiLQiNNXW4tfbljUxOK(t4ad5uepvWr05os5CQYO8nvoTXi4n9YJaokDFzZuXKUPtleajFvlpDbJwb8cGLldVayzZBmA95sV8iwpir6ERh0zuOCoHbxzYcGGiFSeWS1BCc1lAYywVK4EHs6pHlFL1GrCDyHhcnBqg0YAq3PisOR67xMEsqM2)eLjhblpDb4falZsaZwVXjuVOjJz9sI7fkP)eU(foduv9LPJSQrmuTlZjHC(ldkw)VrK8JP19sd7FIrKSQrmy90A9GI1JuQICEgdJpveSK4EHs6pHdmKtr8ubhrN7iLZPkJY3u50gJG30lpc4O09Lntft6MoTqaK8vT80fmAfWlawUm8cGLnVXO1Nl9YJy9GeP7TEqpKcLZjm4ktwaee5JLaMTEJtOErtgZ6D)scRiKVYAWiUoSWdHMnidAznO7uej0v99ltpjit7FIYKJGLNUa8cGLzjGzR34eQx0KXSE3VKWkc9l8qOvFz6iRAedv7YCsiN)Y)grYpMw3lnS)jgrYQgXG1tR1dkwpsPkY5zmm(urWsI7fkP)eoWqofXtfCeDUJuoNQmkFtLtBmcEtV8iGJs3x2mvmPB60cbqYx1YtxWOvaVay5YWlaw28gJwFU0lpI1dsKU36bnfPq5CcdUYKfabr(yjGzR34eQx0KXS(06EPH9pr(kRbJ46WcpeA2GmOL1GUtrKqx13Vm9KGmT)jktocwE6cWlawMLaMTEJtOErtgZ6tR7Lg2)e97xgEbWYSeWS1BCc1lAYywVbKGczQFla]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170718.213417, [[diKgsaqicKweLIAtkPmksrDkkfUfLIyxqYWukhJswMKQNjPyAskPRrc2gPaFJqghbIZrPiTosbnpjL4EKczFsk1bvswib8qLQMibQlsIAJkPcNKeAMKcv3us2ji)KuO0qvsfTuc1trnvGCvLu1wjr(kPqXEf)LGgmOomvlMKEmGjtXLr2mLQptQmAsvNMOxduZwr3wIDRYVLA4qQJtkYYH65kmDvDDLy7kv(oLsNNuA9kPs7hIJvafMbWs0F4WcMS7lZpcewmnjFqbQ(MLOnrwIqzjQETQGGeMrtasFkxx)L9fO6kup8kGx23iGcKvafw5ZvNKjceMbWs0F4V1PBsOK3ty8c6FeELQCkFTHlYZi0oMO1LcR4zKa(34WxFu4Q2OKJH8cfomKxOWvYZGaVoWeTUuyX0K8bfO6BwIS2clMg9cgGgbu(W71taGR6DuHUpQHRAdKxOW5du9akSYNRojteimdGLO)W4LtcieDBlHrzi7sa5JaxBe46BHxPkNYxByhd4hj8BmMUpSINrc4FJdF9rHRAJsogYlu4WqEHcVcd4hHadQXy6(WIPj5dkq13SezTfwmn6fmancO8H3RNaax17OcDFudx1giVqHZhOAcOWkFU6KmrGWmawI(d)ToDtcfq3ttB7ncVsvoLV2WQZUncTVG1gwXZib8VXHV(OWvTrjhd5fkCyiVqHfy2TbbEDSG1gwmnjFqbQ(MLiRTWIPrVGbOraLp8E9ea4QEhvO7JA4Q2a5fkC(avRbuyLpxDsMiqygalr)H)wNUjHcO7PPT9gHxPkNYxByvcpimy5PlSINrc4FJdF9rHRAJsogYlu4WqEHclaHhegS80fwmnjFqbQ(MLiRTWIPrVGbOraLp8E9ea4QEhvO7JA4Q2a5fkC(aPqafw5ZvNKjceELQCkFTHxgKq5tLryfpJeW)gh(6Jcx1gLCmKxOWHH8cfE9dcbwXNkJWIPj5dkq13SezTfwmn6fmancO8H3RNaax17OcDFudx1giVqHZhiniGcR85QtYebcZayj6p8360njuO7x23abEneynJaRUy3oQLtFp1kC8y6096rTGgb2gHxPkNYxBy09l7lSINrc4FJdF9rHRAJsogYlu4WqEHcVo7x2xyX0K8bfO6BwIS2clMg9cgGgbu(W71taGR6DuHUpQHRAdKxOW5dKOakSYNRojteimdGLO)WckcSPFu7K4LjDVq0tx3cH6LaGLNUWRuLt5RnCV8QyYbhEVEcaCvVJk09rnCvBuYXqEHchgYluyn2Lxfto4WRW6gHFhRJEHs7AKGA6h1ojEzs3le901TqOEjay5PlSyAs(Gcu9nlrwBHftJEbdqJakFyfpJeW)gh(6Jcx1giVqHZhibjGcR85QtYebcZayj6p8360njuaDpnTT3i8kv5u(Ad74IwHTDHVEsOHCtyfpJeW)gh(6Jcx1gLCmKxOWHH8cfEfUOfbUTJa)6jeybtUjSyAs(Gcu9nlrwBHftJEbdqJakF496jaWv9oQq3h1WvTbYlu48bYMgqHv(C1jzIaHzaSe9hM00IenAYGYQgrBIuabEneyGUNM22dLXXGf6yv5tyuyQ4YBGaxBeylnqHWRuLt5RnSXXGf(y)g2BCXFzFHv8msa)BC4RpkCvBuYXqEHchgYluyb7yWiWGW(nS34I)Y(clMMKpOavFZsK1wyX0OxWa0iGYhEVEcaCvVJk09rnCvBG8cfoFGS2cOWkFU6KmrGWmawI(dtAArIgnzqzvJOnrkGaVgcSGIa)(KUh1qVBABfkp7ldzFOOZvNKbbEneyGUNM22dLXXGf6yv5tyuyQ4YBGaxBeyfui8kv5u(AdBCmyHp2VH9gx8x2xyfpJeW)gh(6Jcx1gLCmKxOWHH8cfwWogmcmiSFd7nU4VSpeynBzJWIPj5dkq13SezTfwmn6fmancO8H3RNaax17OcDFudx1giVqHZhilRakSYNRojteimdGLO)WKMwKOrtguw1iAtKciWRHa)(KUh1qVBABfkp7ldzFOOZvNKbbEneyGUNM22dLXXGf6yv5tyuyQ4YBGaxBe4Aui8kv5u(AdBCmyHp2VH9gx8x2xyfpJeW)gh(6Jcx1gLCmKxOWHH8cfwWogmcmiSFd7nU4VSpeynx3gHfttYhuGQVzjYAlSyA0lyaAeq5dVxpbaUQ3rf6(OgUQnqEHcNpqw1dOWkFU6KmrGWmawI(dtAArIgnzqzvJOnrkGaVgc87yD0J6Lfs43cnscbUwqGb6EAABpughdwOJvLpHrHPIlVbcSnbbwqcVsvoLV2Wghdw4J9ByVXf)L9fwXZib8VXHV(OWvTrjhd5fkCyiVqHfSJbJadc73WEJl(l7dbwZ1yJWIPj5dkq13SezTfwmn6fmancO8H3RNaax17OcDFudx1giVqHZhiRAcOWkFU6KmrGWmawI(dtAArIgnzqzvJOnrkGaVgcmq3ttB7HASuk9juNJ11ANekmvC5nqGRncSLgSfELQCkFTHnogSWh73WEJl(l7lSINrc4FJdF9rHRAJsogYlu4WqEHclyhdgbge2VH9gx8x2hcSMRvBewmnjFqbQ(MLiRTWIPrVGbOraLp8E9ea4QEhvO7JA4Q2a5fkC(azvRbuyLpxDsMiqygalr)HjnTirJMmOSQr0MifqGxdbwqrGFFs3JAO3nTTcLN9LHSpu05QtYGaVgcmq3ttB7HASuk9juNJ11ANekmvC5nqGRncSckeELQCkFTHnogSWh73WEJl(l7lSINrc4FJdF9rHRAJsogYlu4WqEHclyhdgbge2VH9gx8x2hcSMvWgHfttYhuGQVzjYAlSyA0lyaAeq5dVxpbaUQ3rf6(OgUQnqEHcNpqwkeqHv(C1jzIaHzaSe9hM00IenAYGYQgrBIuabEne43N09Og6DtBRq5zFzi7dfDU6KmiWRHad09002EOglLsFc15yDT2jHctfxEde4AJaxJcHxPkNYxByJJbl8X(nS34I)Y(cR4zKa(34WxFu4Q2OKJH8cfomKxOWc2XGrGbH9ByVXf)L9HaRznWgHfttYhuGQVzjYAlSyA0lyaAeq5dVxpbaUQ3rf6(OgUQnqEHcNpqwAqafw5ZvNKjceMbWs0Fystls0OjdkRAeTjsbe41qGFhRJEuVSqc)wOrsiW1ccmq3ttB7HASuk9juNJ11ANekmvC5nqGTjiWcs4vQYP81g24yWcFSFd7nU4VSVWkEgjG)no81hfUQnk5yiVqHdd5fkSGDmyeyqy)g2BCXFzFiWAwKnclMMKpOavFZsK1wyX0OxWa0iGYhEVEcaCvVJk09rnCvBG8cfoFGSefqHv(C1jzIaHzaSe9hwqrGjnTirJMmOSQr0MifqGxdbgVCecCTOriW1eELQCkFTHnogSWh73WEJl(l7lSINrc4FJdF9rHRAJsogYlu4WqEHclyhdgbge2VH9gx8x2hcSMfeBewmnjFqbQ(MLiRTWIPrVGbOraLp8E9ea4QEhvO7JA4Q2a5fkC(azjibuyLpxDsMiqygalr)HXlhHaxlAecCnHxPkNYxBy1PuN(NmcXlhj0wYr3xyfpJeW)gh(6Jcx1gLCmKxOWHH8cfwGPuN(NmiWIxocbwJHC09fwmnjFqbQ(MLiRTWIPrVGbOraLp8E9ea4QEhvO7JA4Q2a5fkC(azztdOWkFU6KmrGWmawI(d)(KUhLXXGf6yv5tyu05QtYGaVgcmA6rTZNG1IfQ6)pPIln0HYbE5ok8kv5u(AdJxoHoWl7t4uo(W71taGR6DuHUpQHRAJsogYlu4WqEHclE5qGxb8Y(qG14YXhEfw3i85fsJSzww2JaV(tFp1QHiW78jyTyBoSyAs(Gcu9nlrwBHftJEbdqJakFyfpJeW)gh(6Jcx1giVqHzzzpc86p99uRgIaVZNG1IZhO6BbuyLpxDsMiq4vQYP81ggWNtHoWl7t4uo(WkEgjG)no81hfUQnk5yiVqHdd5fk8EForGxb8Y(qG14YXhEfw3i85fsJSzww2JaV(tFp1QHiW6OJWsaBoSyAs(Gcu9nlrwBHftJEbdqJakF496jaWv9oQq3h1WvTbYluyww2JaV(tFp1QHiW6OJWsG85dd5fkmll7rGx)PVNA1qeydz3xMF(ea]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170718.213417, [[diZBcaGEQQ0Uav9AeQzRKBsv(gOStQSxYUr1(rudtk(TWqPGAWiPHdshKcDmK6CuqwOK0sLklMIwUIEOKQNQAzsvpxPMiczQsPjtPPdCre0vPQOldDDjLTcQSzq02rGtJY0OQKVtvfpwHdlA0iXTL4KuGpljUgvvDEe5VGWZOQuRJQclA1Q)XKbfORteczwBbuv9oCH5gLRVHgwdmAyWtdR3x(Bi9dfhSCX8BcybxUE)71noaSGVvRC0QvNqEAUqRQQ)XKbfOdIkvwi8qdal4BDJMSfdqshAaybx3aULnsqm15bh19clC50Lfux3Lfu3WbGfC9oCH5gLRVHggDJEhUJAZbUvRa61PGdI9ccWcYbYu3lSUSG6cixVA1jKNMl0QQ6gnzlgGK(mzBeclMwDd4w2ibXuNhCu3lSWLtxwqDDxwq9UKTrYujctREhUWCJY13qdJUrVd3rT5a3Qva96uWbXEbbyb5azQ7fwxwqDbKZ3QvNqEAUqRQQ)XKbfOdIkvwi8Jiw2Wp8TUrt2IbiPNZcjiciHaqbHWIPv3aULnsqm15bh19clC50Lfux3Lfu34SqIm1asYubuqYujctREhUWCJY13qdJUrVd3rT5a3Qva96uWbXEbbyb5azQ7fwxwqDbeq3Lfu)SsDYu9jNsSi5dYuHoXrumtGasa]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170718.213417, [[d0ZbgaGEafTjPezxeLTjLuTpPK0mbuy2s60OCtr1Jf5BcYHvStPAVu7gP9lWOKskddv8BqNNapdqPbtsdhroir1PKsIJjfNtkrTqujlfvzXKy5cTiesEk0YiuRJqYeri1urutwIPR0fLsDvPeUSQRlkBeHOTsi2maBhq(lr67cQPbOY8iK62a9zcA0OQEoPojQuJdqvxdHY9qO6HeXpri8AeSBmzJykYiTgns0hWKvxZLrEV(rF3fZPjeNqnHK1esmWrSw2is6j2uzaZzzqQ7IjMyJYtlds1MS7nMSX20rP(I5YOCfwLTcmw(S8LMGSQrUPfwAwy0ifsVXCyrKj2hWB0yFaVrI(ZYpqvcKvnY71p67UyonHA4yK31WSy6At2Rrj8FIqoeOdE6AfJ5WsFaVrVUl2Kn2Mok1xmxgXuKrAnwUsgaaYaC9(iJkuAyygTitVtIqGkXdubEJYvyv2kW4qcMMQas6BKBAHLMfgnsH0BmhwezI9b8gn2hWBuojyAQciPVrEV(rF3fZPjudhJ8UgMftxBYEnkH)teYHaDWtxRymhw6d4n61DG1Kn2Mok1xmxgXuKrAnwUsgaaYaC9(iJkuAyygTitVtIqGQOdub(a1wkqnbH1cmmv2qcMMQas6llEWHr1bQIoqLygLRWQSvGraxVpYOcLQ3iJWnYnTWsZcJgPq6nMdlImX(aEJg7d4nsKxVpYOcduXnYiCJ8E9J(UlMttOgog5DnmlMU2K9Auc)NiKdb6GNUwXyoS0hWB0R7aNjBSnDuQVyUmIPiJ0ACsldOl90dYUoqTvjEGQyJYvyv2kWyAQvPtAzqQ0ktVgLW)jc5qGo4PRvmMdlImX(aEJg7d4nkzQ1av5PLbPbQadMEnkpkuBKoGN4efYaLeO2ckFyvGOcuLteTjkJ8E9J(UlMttOgog5DnmlMU2K9AKBAHLMfgnsH0Bmhw6d4nImqjbQTGYhwfiQav5erBVUtmt2yB6OuFXCzetrgP1y5kzaaidW17JmQqPHHz0Im9ojcbQIM4bQaRr5kSkBfyeW17JmQqP6nYiCJCtlS0SWOrkKEJ5WIitSpG3OX(aEJe517JmQWavCJmcpqT1AAfJ8E9J(UlMttOgog5DnmlMU2K9Auc)NiKdb6GNUwXyoS0hWB0R7TUjBSnDuQVyUmIPiJ0ASCLmaaKb469rgvO0WWmArwgjJYvyv2kWOobZIcVu9gzeUrUPfwAwy0ifsVXCyrKj2hWB0yFaVrmbZIcFGkUrgHBK3RF03DXCAc1WXiVRHzX01MSxJs4)eHCiqh801kgZHL(aEJEDpKjBSnDuQVyUmIPiJ0ASCLmaaKb469rgvO0WWmArwgjJYvyv2kWyQoHzuHs18NcmS2i30clnlmAKcP3yoSiYe7d4nASpG3OK6eMrfgOI8NcmS2iVx)OV7I50eQHJrExdZIPRnzVgLW)jc5qGo4PRvmMdl9b8g961yFaVrKbkjqTfu(WQarfOc0ujii61ga]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170718.213417, [[dGtIeaGEbI2KaPDjGxJI2hkLzJuZxG6MIY3ivTtLAVu7MW(LQrbQYWqIFtYGLYWrjhujCkqvDmHCobclerAPOWIfvlhHhQe9uOLPKEoituOQPIOMmrth4IcQRsQexw11fkNwXwjvSzqL2oP0Jr1HL8zb57cvUhIO)ckJgjDBrojkvpJujDnqfNNumneH1rQu9tsLYoYKnICIHfWOX4pCRy0atQrgN(f09ELsKEk6J0his)kjGtqyezD(u0tqwGrj8EfoRgxWbJsazYEhzYgdlQC6lnPgroXWcyS4Gr7HDXtZH6n2izVTACr(qpangLVauHvcjm55LgJSlKdVakcJcL4gZusDkIDLUrJ7kDJX)cqT3kHS3I)8sJrgN(f09ELsK(ikgzCivmc(HmzdmUK65mZuAF6cGZnMPK7kDJg49QjBmSOYPV0KAe5edlGXIdgTh2fpnhQ3yR3iHXf5d9a0y8Sg5td3i7c5WlGIWOqjUXmLuNIyxPB04Us3yywJ8PHBKXPFbDVxPePpIIrghsfJGFit2aJlPEoZmL2NUa4CJzk5Us3ObERRMSXWIkN(stQrKtmSagloy0Eyx80COEJns2BR9wq7n41BsfiG8fGkSsiHjpV0eamCMJiuVfCW9MubcipCh6hamCMJiuVbFJlYh6bOXiexfJi0HbbigM3i7c5WlGIWOqjUXmLuNIyxPB04Us3iYvXic9EdbedZBKXPFbDVxPePpIIrghsfJGFit2aJlPEoZmL2NUa4CJzk5Us3ObEtct2yyrLtFPj1iYjgwaJfhmApSlEAouVXgj7T1ElO9g86nPceq(cqfwjKWKNxAcagoZreQ3co4EtQabKhUd9dagoZreQ3GVXf5d9a0yKtxXnIqWGOwsvCqgzxihEbuegfkXnMPK6ue7kDJg3v6gxsxXnIq9gsTKQ4GmY40VGU3RuI0hrXiJdPIrWpKjBGXLupNzMs7txaCUXmLCxPB0aVHJjBmSOYPV0KAe5edlGXIdgTh2fpnhQ3yR3wnUiFOhGgJN1iFA4gzxihEbuegfkXnMPK6ue7kDJg3v6gdZAKpn8EdErW3iJt)c6EVsjsFefJmoKkgb)qMSbgxs9CMzkTpDbW5gZuYDLUrdmW4Us3ioPL9MUiOQO1O792cDlSb2a]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170718.213417, [[dSZCmaGEvvqBsqTlsABQQa7tvXSLQBQkEUi3MsoSKDIu7vz3q2pPgLQQmmsyCIQuwgvPZJszWumCs0HOkQtPQQoMOCovvAHOuTukvlgjlhvpuu5PepwO1jQsmrrvmvkLjtLPRYffGRkQs1ZOkIRJInkQsARcOntvTDbQtJ4BQknnQI03rjZtvf6VsXOLsFwqoPa5YGRPQIUNOQETQ0VH6GufEzZ2ejYjkVjtYd4xm9BSpHUSGjcXkN2K3rT4oB5fTjDfYvC3e7qhQemAVkY(Q4B2x1SVE90F(7e7q5yZgXcMWzqqs9iwqZHB8oXJ4rWO0Sn6SzBsaOIQdUX(ejYjkVjoGIX3x1hshWjOqnSWmiNA6Q4R28J5RnE1MWAdNbrInkXSaUQd8jrYPnF0MFoXdksNCSnXhshWjOqnPJtEHjbHCKyDy(eegbtEWUaloDzbtMqxwWK8kKoGtqH0g54KxyIDOdvcgTxfzFZumXoKWm8iKMTDtY1cX3hCWGfGUrn5b7OllyYUr7D2MeaQO6GBSprICIYBIN1gkgFFvee54ejPYOuBcRnx1b0PIGihNijvavuDWPnH1godc0MFmFTXtM4bfPto2M4G6ABIysFsqihjwhMpbHrWKhSlWItxwWKj0LfmjpqDTAtomPpXo0HkbJ2RISVzkMyhsygEesZ2Uj5AH47doyWcq3OM8GD0Lfmz3O9KzBsaOIQdUX(ejYjkVjum((QiiYXjssLrP2ewBCafJVVQpKoGtqHAyHzqo10vXxT5t(AtM2ewB4misSrjMfWvDGpjsoT5J287epOiDYX2KueZWdbnPJtEHjbHCKyDy(eegbtEWUaloDzbtMqxwWejIz4HaTroo5fMyh6qLGr7vr23mftSdjmdpcPzB3KCTq89bhmybOButEWo6YcMSB0E6Snjaur1b3yFIe5eL3ekgFFvee54ejPYOuBcRnoGIX3x1hshWjOqnSWmiNA6Q4R28jFTjtBcRnCgej2OeZc4QoWNejN28rB(DIhuKo5yBsSxSiOqnP2YHzLMeeYrI1H5tqyem5b7cS40LfmzcDzbtY1lweuiTrAlhMvAIDOdvcgTxfzFZumXoKWm8iKMTDtY1cX3hCWGfGUrn5b7OllyYUr)ZzBsaOIQdUX(ejYjkVjum((QmOwCNTM0XbuORvLrP2ewBCafJVVQpKoGtqHAyHzqo10vXxT5t(AtM2ewB4misSrjMfWvDGpjsoT5J287epOiDYX2KueZWdbnPJtEHjbHCKyDy(eegbtEWUaloDzbtMqxwWejIz4HaTroo5f0M)Y(FIDOdvcgTxfzFZumXoKWm8iKMTDtY1cX3hCWGfGUrn5b7OllyYUr)dMTjbGkQo4g7tKiNO8MqX47RYGAXD2AshhqHUwvgLAtyTXbum((Q(q6aobfQHfMb5utxfF1Mp5RnzAtyTHZGiXgLywax1b(Ki50MpAZVt8GI0jhBtI9IfbfQj1womR0KGqosSomFccJGjpyxGfNUSGjtOllysUEXIGcPnsB5WSsAZFz)pXo0HkbJ2RISVzkMyhsygEesZ2Uj5AH47doyWcq3OM8GD0Lfmz3O)oBtcavuDWn2Niror5nHZGaT5t(AJxTjS24akgFFvFiDaNGc1WcZGCQPRIVAZN81MmTjS2WzqKyJsmlGR6aFsKCAZhT53jEqr6KJTjPiMHhcAshN8ctcc5iX6W8jimcM8GDbwC6YcMmHUSGjseZWdbAJCCYlOn)59)j2Houjy0EvK9ntXe7qcZWJqA22njxleFFWbdwa6g1KhSJUSGj7gDEB2MeaQO6GBSprICIYBcNbbAZN81gVAtyTXbum((Q(q6aobfQHfMb5utxfF1Mp5RnzAtyTHZGiXgLywax1b(Ki50MpAZVt8GI0jhBtI9IfbfQj1womR0KGqosSomFccJGjpyxGfNUSGjtOllysUEXIGcPnsB5WSsAZFE)FIDOdvcgTxfzFZumXoKWm8iKMTDtY1cX3hCWGfGUrn5b7OllyYUr)7Snjaur1b3yFIe5eL3KR6a6utTLdZQHG8zsemsfqfvhCAtyT5QoGovxXFBkof5aUkGkQo40MWAJN1gkgFFvxXFBoEHs(yUvDemsLrP2ewBIyC3HzHuDf)TP4uKd4QCWQiOK28rBYumXdksNCSnXb112eXK(KGqosSomFccJGjpyxGfNUSGjtOllysEG6A1MCysxB(l7)j2Houjy0EvK9ntXe7qcZWJqA22njxleFFWbdwa6g1KhSJUSGj7gDMIzBsaOIQdUX(ejYjkVjx1b0PMAlhMvdb5ZKiyKkGkQo40MWAJN1MR6a6uDf)TP4uKd4QaQO6GtBcRnEwBOy89vDf)T54fk5J5w1rWivgLt8GI0jhBtCqDTnrmPpjiKJeRdZNGWiyYd2fyXPllyYe6YcMKhOUwTjhM01M)8()e7qhQemAVkY(MPyIDiHz4rinB7MKRfIVp4GblaDJAYd2rxwWKDJolB2MeaQO6GBSprICIYBYvDaDQUI)2uCkYbCvavuDWPnH1Mig3DywivxXFBkof5aUkhSkckPnF0Mmft8GI0jhBtCqDTnrmPpjiKJeRdZNGWiyYd2fyXPllyYe6YcMKhOUwTjhM01M)8K)Nyh6qLGr7vr23mftSdjmdpcPzB3KCTq89bhmybOButEWo6YcMSB0zENTjbGkQo4g7tKiNO8M4zT5QoGo1uB5WSAiiFMebJubur1bN2ewB8S2CvhqNQR4VnfNICaxfqfvhCt8GI0jhBtCqDTnrmPpjiKJeRdZNGWiyYd2fyXPllyYe6YcMKhOUwTjhM01M)80)Nyh6qLGr7vr23mftSdjmdpcPzB3KCTq89bhmybOButEWo6YcMSB3erjejvN8dRJGrJ27p9UBd]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170718.213417, [[dStujaGEvcQnju2fj2MkbzFKcZwu3uv60i(MkLhlyNO0Ev2nu7NIrHQWWiv9BihwY9qrmyknCQWbjLCkuuDmvX5ujulKuQLsfTyv1Yr6HcvpLyzOQwNkbAIOOmvsLjtvtxQlsL4QQevxgCDuzJQeLTsLQnlKTtL0Zif9xvyAQe57Qunpvc5ZQKgnk8Crojvk3MKUgQIopQshcfPXPsaVwf9EMUjIdiqQm5cxnbHhlFEYFcZGOIl3t7joHmujyS81)Ct)TNBkp34FjEEXtKaL4ONmrRqtq400n2NPBIl46Nb)0EIeOeh9ep85IIuIGuduc(6XDeh2RK6kCASxetm2lzSXmwkhMeoCGUdufpercK2y1Wy5R5eT(KmP5DseKAGsWxpsnLCctCd7jHQr0jyegM8I8Uxu2sfMmHTuHjxgKAGsWxnwPPKtyItidvcglF9p3E0pXjKqC0aKMU1tIZacNVixbva37p5f5zlvyY6XYF6M4cU(zWpTNibkXrpHPg7NlksbdbkkrskCom2ygBxza3kyiqrjssbW1pdEJnMXs5WGXErmXy1CIwFsM08oXdvZ4iGi5jUH9Kq1i6emcdtErE3lkBPctMWwQWeMbvZWyJJi5joHmujyS81)C7r)eNqcXrdqA6wpjodiC(ICfubCV)KxKNTuHjRhRMt3exW1pd(P9ejqjo6jFUOifmeOOejPW5WyJzSE4ZffPebPgOe81J7ioSxj1v40y1GjgRMgBmJLYHjHdhO7avXdrKaPnwnmw(AorRpjtAENKcio6v4i1uYjmXnSNeQgrNGryyYlY7ErzlvyYe2sfMibeh9kySstjNWeNqgQemw(6FU9OFItiH4ObinDRNeNbeoFrUcQaU3FYlYZwQWK1J9st3exW1pd(P9ejqjo6jFUOifomduM3Jutb81MHcNdJnMX6HpxuKseKAGsWxpUJ4WELuxHtJvdMySAASXmwkhMeoCGUdufpercK2y1Wy5R5eT(KmP5DskG4OxHJutjNWe3WEsOAeDcgHHjViV7fLTuHjtylvyIeqC0RGXknLCcglpEy(eNqgQemw(6FU9OFItiH4ObinDRNeNbeoFrUcQaU3FYlYZwQWK1JLNt3exW1pd(P9ejqjo6juomySAWeJLVXgZy9WNlksjcsnqj4Rh3rCyVsQRWPXQbtmwnn2yglLdtchoq3bQIhIibsBSAyS81CIwFsM08ojfqC0RWrQPKtyIBypjunIobJWWKxK39IYwQWKjSLkmrcio6vWyLMsobJLh8z(eNqgQemw(6FU9OFItiH4ObinDRNeNbeoFrUcQaU3FYlYZwQWK1J9cnDtCbx)m4N2tKaL4ON0vgWTsIr5r3pi4iUebHvaC9ZG3yJzSDLbCR4l65rr)KgOkaU(zWBSXmwMASFUOifFrppAAHtriQA1eewHZHXgZydiu2JUJv8f98OOFsdufkOweCYy1WyF45eT(KmP5DIhQMXrarYtCd7jHQr0jyegM8I8Uxu2sfMmHTuHjmdQMHXghrYglpEy(eNqgQemw(6FU9OFItiH4ObinDRNeNbeoFrUcQaU3FYlYZwQWK1J920nXfC9ZGFAprcuIJEsxza3kjgLhD)GGJ4seewbW1pdEJnMXYuJTRmGBfFrppk6N0avbW1pdEJnMXYuJ9ZffP4l65rtlCkcrvRMGWkCoMO1NKjnVt8q1mocisEIBypjunIobJWWKxK39IYwQWKjSLkmHzq1mm24is2y5bFMpXjKHkbJLV(NBp6N4esioAast36jXzaHZxKRGkG79N8I8SLkmz9yVat3exW1pd(P9ejqjo6jDLbCR4l65rr)KgOkaU(zWBSXm2acL9O7yfFrppk6N0avHcQfbNmwnm2hEorRpjtAEN4HQzCeqK8e3WEsOAeDcgHHjViV7fLTuHjtylvycZGQzySXrKSXYdnz(eNqgQemw(6FU9OFItiH4ObinDRNeNbeoFrUcQaU3FYlYZwQWK1J9INUjUGRFg8t7jsGsC0tyQX2vgWTsIr5r3pi4iUebHvaC9ZG3yJzSm1y7kd4wXx0ZJI(jnqvaC9ZGFIwFsM08oXdvZ4iGi5jUH9Kq1i6emcdtErE3lkBPctMWwQWeMbvZWyJJizJLhxI5tCczOsWy5R)52J(joHeIJgG00TEsCgq48f5kOc4E)jVipBPctwVEcBPcteIACJ9YXmqzEVGgBOsn5A1i66na]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170718.213417, [[dSJwmaGEvfL2KOyxK02uvuSpvvMTkUPk1Pr8nvLESq7eP2RYUbTFkgLQQAyKWVboSK7jOAWKA4KOdsP4uOuCmvY5uvLfsP0sPkwmswoQEOO0tjwMaTovfHjsvstLs1KPY0L6IuL6QQks9mvfUok2OQIOTkaBMQA7cOdrvI)kQMgkL67OKBtjFwqgTQyEQkQoPGYLHUgkLCEuQEUiJtvrYRvLExZ(erjgj1H8zRMaGJoiBfCIxr)I50Z2jEWdwjC0bvC9vX3RVQxFdY2S1FtKiNOSNmXMytaW0Sp6RzFI3WI6GUz7ejYjk7joKIX3x1htnYjWq5SamqNAQR4Rr)5HB0bn6mgnNbsI5kbSqUQd9jrsB0)mA2AInuKdPzFIpMAKtGHYtnN8Itcd6iXQb8jqaeNCdCbuC6YcNmHUSWjFsm1iNadz0sZjV4ep4bReo6GkU(EPyIhmby4rmn7RNK9bJV3Garle2JAYnWrxw4K1Jo4SpXByrDq3SDIe5eL9eVy0um((QqmYbjssLrPrNXO76GWwfIroirsQiSOoOZOZy0CgiA0FE4g9htSHICin7tCy1p5ra5mjmOJeRgWNabqCYnWfqXPllCYe6YcN4vS6hJolGCM4bpyLWrhuX13lft8GjadpIPzF9KSpy89geiAHWEutUbo6YcNSE0Fm7t8gwuh0nBNirorzpHIX3xfIroirsQmkn6mgTdPy89v9XuJCcmuolad0PM6k(A0)c3O)WOZy0CgijMReWc5Qo0NejTr)ZO)BInuKdPzFskcy4HW8uZjV4KWGosSAaFceaXj3axafNUSWjtOllCIebm8qOrlnN8It8GhSs4OdQ467LIjEWeGHhX0SVEs2hm(EdceTqypQj3ahDzHtwpA2E2N4nSOoOB2orICIYEcfJVVkeJCqIKuzuA0zmAhsX47R6JPg5eyOCwagOtn1v81O)fUr)HrNXO5mqsmxjGfYvDOpjsAJ(Nr)3eBOihsZ(K4PyrGHYtpLdWknjmOJeRgWNabqCYnWfqXPllCYe6YcNK9uSiWqgT8uoaR0ep4bReo6GkU(EPyIhmby4rmn7RNK9bJV3Garle2JAYnWrxw4K1JMTM9jEdlQd6MTtKiNOSNqX47RYaFah2ZtnhHH6hvgLgDgJ2Hum((Q(yQrobgkNfGb6utDfFn6FHB0Fy0zmAodKeZvcyHCvh6tIK2O)z0)nXgkYH0Spjfbm8qyEQ5KxCsyqhjwnGpbcG4KBGlGItxw4Kj0LforIagEi0OLMtErJ()l2mXdEWkHJoOIRVxkM4btagEetZ(6jzFW47niq0cH9OMCdC0Lfoz9O)mZ(eVHf1bDZ2jsKtu2tOy89vzGpGd75PMJWq9JkJsJoJr7qkgFFvFm1iNadLZcWaDQPUIVg9VWn6pm6mgnNbsI5kbSqUQd9jrsB0)m6)Mydf5qA2NepflcmuE6PCawPjHbDKy1a(eiaItUbUakoDzHtMqxw4KSNIfbgYOLNYbyLm6)VyZep4bReo6GkU(EPyIhmby4rmn7RNK9bJV3Garle2JAYnWrxw4K1J(7SpXByrDq3SDIe5eL9eoden6FHB0bn6mgTdPy89v9XuJCcmuolad0PM6k(A0)c3O)WOZy0CgijMReWc5Qo0NejTr)ZO)BInuKdPzFskcy4HW8uZjV4KWGosSAaFceaXj3axafNUSWjtOllCIebm8qOrlnN8Ig9)bzZep4bReo6GkU(EPyIhmby4rmn7RNK9bJV3Garle2JAYnWrxw4K1J(tn7t8gwuh0nBNirorzpHZarJ(x4gDqJoJr7qkgFFvFm1iNadLZcWaDQPUIVg9VWn6pm6mgnNbsI5kbSqUQd9jrsB0)m6)Mydf5qA2NepflcmuE6PCawPjHbDKy1a(eiaItUbUakoDzHtMqxw4KSNIfbgYOLNYbyLm6)dYMjEWdwjC0bvC99sXepycWWJyA2xpj7dgFVbbIwiSh1KBGJUSWjRh9FZ(eVHf1bDZ2jsKtu2t66GWwn9uoaRCc0Njraqvewuh0z0zm6UoiSvDf)nV4uKg5QiSOoOZOZy0EXOPy89vDf)nV5fm5d4wvtaqvgLgDgJocahhGfu1v838ItrAKRYrRIatg9pJ(sXeBOihsZ(ehw9tEeqotcd6iXQb8jqaeNCdCbuC6YcNmHUSWjEfR(XOZcihJ()l2mXdEWkHJoOIRVxkM4btagEetZ(6jzFW47niq0cH9OMCdC0Lfoz9OVum7t8gwuh0nBNirorzpPRdcB10t5aSYjqFMebavryrDqNrNXO9Ir31bHTQR4V5fNI0ixfHf1bDgDgJ2lgnfJVVQR4V5nVGjFa3QAcaQYOCInuKdPzFIdR(jpciNjHbDKy1a(eiaItUbUakoDzHtMqxw4eVIv)y0zbKJr)Fq2mXdEWkHJoOIRVxkM4btagEetZ(6jzFW47niq0cH9OMCdC0Lfoz9OVUM9jEdlQd6MTtKiNOSN01bHTQR4V5fNI0ixfHf1bDgDgJocahhGfu1v838ItrAKRYrRIatg9pJ(sXeBOihsZ(ehw9tEeqotcd6iXQb8jqaeNCdCbuC6YcNmHUSWjEfR(XOZcihJ()pyZep4bReo6GkU(EPyIhmby4rmn7RNK9bJV3Garle2JAYnWrxw4K1J(k4SpXByrDq3SDIe5eL9eVy0DDqyRMEkhGvob6ZKiaOkclQd6m6mgTxm6UoiSvDf)nV4uKg5QiSOoOBInuKdPzFIdR(jpciNjHbDKy1a(eiaItUbUakoDzHtMqxw4eVIv)y0zbKJr)pBZMjEWdwjC0bvC99sXepycWWJyA2xpj7dgFVbbIwiSh1KBGJUSWjRxpHUSWjcXkRr)PHpGd7FcJMatnNj2aEA9ga]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170718.213417, [[deeIxaqiuf2KuPprvsLrHiofI0UOIHrHoMiwgLQNrvIMgQICnPIABuLu(gIQXHQO6CsfzDuLu18qu09quAFuLKdsbTqkWdPuAIOkkDrkfBKQQ8ruffJerHojvPUPu1orLFIOGLsjEkPPsjTvQQ8vQQk7v5VuPbt0HbwmcpwutgKlRAZsPptvz0OQonkVMQy2cDBqTBO(nKHlfhNQewospxW0LCDkA7IuFhvPZlswpvvvZxQW(j8sM1PAZZmqK5)GIHWJZENtMQzkRPMoLN9TaZyndMA5XdcFC2nMqUrYti3jHC78uN70ulhaLYkd(t5rbIhxoTuuOc5uf)7CmGiEiHeGHesJcjIkKeMTToEyXid7ZfgK5ZW3HEyadhMAyUyiCywhxYSo1gmGiEOzWuntzn10c5Zx8ozekcH4fheYUcjjcjjcjpeYcepUCAPi))y3gZy4ohdiIhsi7OdHKeHKAIVqsMcPDHSRqsnXSSBdI3tDYMu6XLqsMcPDEUqsQqsQq2vi5HqwG4XLJpqX)ug2NBOquyNJbeXdjKKo1qcwKvPMIiIS6uqXq4PEJHyzqHOtXi8N2JG8dq5aWF6uoa8NsgiIS6uqXq4PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD14SpRtTbdiIhAgmvZuwtnLWST1HLt5wGichCOhgWWbHKmfYeNolKDfYcepUCy5uUfiIWbNJbeXdn1qcwKvPM2srHYnuuMNp1BmeldkeDkgH)0EeKFakha(tNYbG)u)rrHsi1IY88PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD148YzDQnyar8qZGPAMYAQPfiEC5e4dQ6ug2NBOOmpp4CmGiEiHSRqcDcZ2whkW)ruw(oHcK9iKKvi78udjyrwLAAlffk3qrzE(uVXqSmOq0Pye(t7rq(bOCa4pDkha(t9hffkHulkZZfsssiDQLhpi8Xz3yc5jgNA5bKjn)WSUAQT8F2tpk9HpUgX0Eeeha(txnoEAwNAdgqep0myQMPSMAkjcjHzBRdLbFhZgHSRqEVWK10CiNMtdp9PaC(UOw3I)Dpbc7cdOvkQq2vi5HqsIqsy226GiIS6uqXqyhZgHSRqcYfl9Dp(WShesYuiTlKKkKKkKD0HqwG4XLJpqX)ug2NBOquyNJbeXdn1qcwKvPMspmIgE8HGlVmCD6uVXqSmOq0Pye(t7rq(bOCa4pDkha(tTCyen84dbH0)y460PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD1468So1gmGiEOzWuntzn1ucZ2whkd(oMnczxHKhcjjcjHzBRdIiYQtbfdHDmBeYUcjixS0394dZEqijtH0UqsQq2vi5HqsIqEVWK10CiNMtdp9PaC(UOw3I)Dpbc7cdOvkQq2vilq84YXhO4Fkd7ZnuikSZXaI4HessNAiblYQut5J4nYW(CjIGqn1BmeldkeDkgH)0EeKFakha(tNYbG)uYiI3id7tinicc1ulpEq4JZUXeYtmo1YditA(HzD1uB5)SNEu6dFCnIP9iioa8NUACETzDQnyar8qZGPAMYAQPeMTToug8DmBeYUcjpessescZ2wherKvNckgc7y2iKDfsqUyPV7XhM9GqsMcPDHKuHSRqEVWK10CiNMtdp9PaC(UOw3I)Dpbc7cdOvkQq2vilq84YXhO4Fkd7ZnuikSZXaI4HeYUcjjcj0jmBBDAon80NcW57IADl(39eiSlmGwPOoMnczhDiKzekcH4f7qpmIgE8HGlVmCDQd9WagoiKELq6LcjPtnKGfzvQP8r8gzyFUerqOM6ngILbfIofJWFApcYpaLda)Pt5aWFkzeXBKH9jKgebHsijjH0PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD14iFwNAdgqep0myQMPSMAkpescZ2wherKvNckgc7y2iKDfsseY7fMSMMd54bflgfeCXN3wKjgYLxwmkKDfYcepUCAPi))y3gZy4ohdiIhsi7kKKiKHxUeiSzWPyNM0jx7nzHKSczIq2rhcz4LlbcBgCk2PjDYLNAYcjzfYeHKuHKuHSJoesQj(bNIbF3c52zHKmfsFzOPgsWISk1uerKvNcQp1BmeldkeDkgH)0EeKFakha(tNYbG)uYarKvNcQp1YJhe(4SBmH8eJtT8aYKMFywxn1w(p7PhL(WhxJyApcIda)PRghpFwNAdgqep0myQMPSMAAH85lENmcfHq8IdczxHKeHKeH8EHjRP5qozeoGOvWnJIqUze9czhDiKeMTTonSyeqDrTUTuuOCmBessfYUcjHzBRJjMpkMYnu0J9v8DmBeYUcj0jmBBDOa)hrz57ekq2JqswHSZczxHKhcjHzBRdIiYQtbfdHDmBessNAiblYQutdmmef4dfab3wtAQPEJHyzqHOtXi8N2JG8dq5aWF6uoa8NQmmef4dfaEDbH0FM0utT84bHpo7gtipX4ulpGmP5hM1vtTL)ZE6rPp8X1iM2JG4aWF6QX1PzDQnyar8qZGPAMYAQPutml72G49uhO3YYSsijtYkKjgNAiblYQutBPOq5gkkZZN6ngILbfIofJWFApcYpaLda)Pt5aWFQ)OOqjKArzEUqsIDsNA5XdcFC2nMqEIXPwEazsZpmRRMAl)N90JsF4JRrmThbXbG)0vJlX4So1gmGiEOzWuntzn1ucZ2wherKvNckgc7y2iKDfsEiKeMTToEyXid7ZfgK5ZW3XSzQHeSiRsnTLIcLBOOmpFQ3yiwgui6umc)P9ii)auoa8NoLda)P(JIcLqQfL55cjjEjPtT84bHpo7gtipX4ulpGmP5hM1vtTL)ZE6rPp8X1iM2JG4aWF6QXLKmRtTbdiIhAgmvZuwtnfKlw67E8HzpiKEfzfs7czxHKhcjjczbIhxoTuuOc5uf)7CmGiEiHSRqsy2264HfJmSpxyqMpdFhZgHSRqcYfl9Dp(WShesVIScPDHK0PgsWISk1u6Hr0WJpeC5LHRtN6ngILbfIofJWFApcYpaLda)Pt5aWFQLdJOHhFiiK(hdxNkKKKq6ulpEq4JZUXeYtmo1YditA(HzD1uB5)SNEu6dFCnIP9iioa8NUACj2N1P2GbeXdndMQzkRPMsy2264HfJmSpxyqMpdFhZgHSRqsIqYdH8EHjRP5qoEqXIrbbx85TfzIHC5LfJczhDiKGCXsF3Jpm7bH0RiRqAxijDQHeSiRsnTLIcviNQ4)PEJHyzqHOtXi8N2JG8dq5aWF6uoa8N6pkkuHCQI)NA5XdcFC2nMqEIXPwEazsZpmRRMAl)N90JsF4JRrmThbXbG)0vJlXlN1P2GbeXdndMQzkRPMcYfl9Dp(WShesVIScP9PgsWISk1uFrqMbIUaO0aC(t9gdXYGcrNIr4pThb5hGYbG)0PCa4pLNjcYmquineknaN)ulpEq4JZUXeYtmo1YditA(HzD1uB5)SNEu6dFCnIP9iioa8NUACj80So1gmGiEOzWuntzn1uqUyPV7XhM9Gq6vKvi9YPgsWISk10wkkuHCQI)N6ngILbfIofJWFApcYpaLda)Pt5aWFQ)OOqfYPk(xijjH0PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD14s68So1gmGiEOzWuntzn1ucZ2whpSyKH95cdY8z47y2m1qcwKvPMIiIS6uq9PEJHyzqHOtXi8N2JG8dq5aWF6uoa8NsgiIS6uqDHKKesNA5XdcFC2nMqEIXPwEazsZpmRRMAl)N90JsF4JRrmThbXbG)0vJlXRnRtTbdiIhAgmvZuwtnTaXJlhFGI)PmSp3qHOWohdiIhsi7kKfiEC5aBsHofzgCFBllZooNY5yar8qczxHKeHm8YLaHndof70Ko5AVjlKKviteYo6qidVCjqyZGtXonPtU8utwijRqMiKKo1qcwKvPM2srHYnuuMNp1BmeldkeDkgH)0EeKFakha(tNYbG)u)rrHsi1IY8CHKeEI0PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD14siFwNAdgqep0myQMPSMAkjczbIhxo8ruSlQ1LxgUo15yar8qczhDiKfiEC5W3e77ug2Nl1eFxEpObHDogqepKqsQq2vijridVCjqyZGtXonPtU2BYcjzfYeHSJoeYWlxce2m4uStt6Klp1KfsYkKjcjPtnKGfzvQPTuuOCdfL55t9gdXYGcrNIr4pThb5hGYbG)0PCa4p1FuuOesTOmpxijPZKo1YJhe(4SBmH8eJtT8aYKMFywxn1w(p7PhL(WhxJyApcIda)PRgxcpFwNAdgqep0myQHeSiRsnfrez1PG6t9gdXYGcrNIr4pThb5hGYbG)0PCa4pLmqez1PG6cjj2jDQLhpi8Xz3yc5jgNA5bKjn)WSUAQT8F2tpk9HpUgX0Eeeha(txnUKonRtTbdiIhAgm1qcwKvPM6lcYmq0faLgGZFQ3yiwgui6umc)P9ii)auoa8NoLda)P8mrqMbIcPHqPb48fsssiDQLhpi8Xz3yc5jgNA5bKjn)WSUAQT8F2tpk9HpUgX0Eeeha(txno7gN1P2GbeXdndMQzkRPMYdHKWST1HVj23PmSpxQj(U8Eqdc7y2m1qcwKvPMYhrXUOwxEz460PEJHyzqHOtXi8N2JG8dq5aWF6uoa8NsgruSqIAfs)JHRtNA5XdcFC2nMqEIXPwEazsZpmRRMAl)N90JsF4JRrmThbXbG)0vJZEYSo1gmGiEOzWudjyrwLAAlffk3qrzE(uVXqSmOq0Pye(t7rq(bOCa4pDkha(t9hffkHulkZZfss8AKo1YJhe(4SBmH8eJtT8aYKMFywxn1w(p7PhL(WhxJyApcIda)PRgND7Z6uBWaI4HMbt1mL1utlKpFX7KrOieIxCyQHeSiRsn9WniEp1LAIVlVh0GWt9gdXYGcrNIr4pThb5hGYbG)0PCa4p1g4geVNkKwmXxi9VdAq4PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD14S7LZ6uBWaI4HMbt1mL1utlKpFX7KrOieIxCqi7kKKiK8qijmBBD4BI9Dkd7ZLAIVlVh0GWoMncjPtnKGfzvQP8nX(oLH95snX3L3dAq4PEJHyzqHOtXi8N2JG8dq5aWF6uoa8NsgnX(oLH9jKwmXxi9VdAq4PwE8GWhNDJjKNyCQLhqM08dZ6QP2Y)zp9O0h(4Aet7rqCa4pD1QPCa4pvzW2kK(JIcLxVq674tz5vB]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170718.213417, [[dauEuaqisswKsO2eeAucjNsjyxuXWqWXuQwge8mOqMguuDnHGTbfQ(gjX4ucHZPeIwNqO5bfL7rsQ9bf5GkLwijLhQenrQsOlkeTrOGtsvXmvcPBcr7KedLQeTuQQEkLPsvCvOqPTkKAVG)cPbJ0HfTyO6XszYs1LrTzQ0NvsJgHonrVwPy2cUnI2TQ(TKHdLoouOy5Q8CsnDfxxO2ovP(ovLopjvRNQemFQsA)eg2bpG5fz3momGAGzTtIDadmdl3Kzq6fYrwpOGqe2bZph4uZGcce2vHGk7Q4SRccyEewKG5NZU6EKKmyx8lBOylF5ZXndbn6uOiOcyBBJSEn4bu2bpGf5N4bUdQbM1oj2bSPwxdSJ8h(UySJgST4YGCuhms53rDpM9cmy(8DzlN6a7RNbdz1JopLKKbdmLKKbdP87ckgoM9cmy(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbdgqbbWdyr(jEG7GAGzTtIDa7IFzdfB5lFoD2v2KJGIjbfbcckIcQQe0jd8po4hNdr0Yfvl)(LRLoD4pXdChST4YGCuhS8A5ZOtDh)dy(8DzlN6a7RNbdz1JopLKKbdmLKKbB71YNfup1D8pG5NdCQzqbbc7QStam)SUIVgRbpWa2sICBdYYBMK)bWbdz1vssgmyafmc8awKFIh4oOgyw7KyhWMmW)4GFCoerlxuT87xUw60H)epWDbfrbTxJd(X5qeTCr1YVF5APtNr22i)vbfrb9IFzdfB5lFoT474FeumtqXicckIc6f)SGIzckcGTfxgKJ6GLxlFgDQ74FaZNVlB5uhyF9myiRE05PKKmyGPKKmyBVw(SG6PUJ)rqJAFbW8Zbo1mOGaHDv2jaMFwxXxJ1GhyaBjrUTbz5ntY)a4GHS6kjjdgmGcMdEalYpXdChudmRDsSdytTUgyNwvHE57Rfuef0Oeu8yxxhSYqip0Yf19k94eJvqxaST4YGCuhm8qvDu34tDW857Ywo1b2xpdgYQhDEkjjdgykjjdMAHQ6ckgIp1bZph4uZGcce2vzNay(zDfFnwdEGbSLe52gKL3mj)dGdgYQRKKmyWakra8awKFIh4oOgyw7KyhWMADnWoTQc9Y3xlOikOrjO4XUUoyLHqEOLlQ7v6XjgRGUayBXLb5Ooy48P5BJ8xbZNVlB5uhyF9myiRE05PKKmyGPKKmyQXNMVnYFfm)CGtndkiqyxLDcG5N1v81yn4bgWwsKBBqwEZK8paoyiRUssYGbdOGXbpGf5N4bUdQb2wCzqoQdwSMrLdtQbZNVlB5uhyF9myiRE05PKKmyGPKKmyySAwq9zysny(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbdgqrfWdyr(jEG7GAGzTtIDa7IFw7mssgDk0iiOyMGIrckIcAucQQe0Eno4hNdr0Yfvl)(LRLoDgzBJ8xfuV6vb9IFzdfB5lFoT474FeumjOyCcc6cGTfxgKJ6G1VmEL4GwUO6koObZNVlB5uhyF9myiRE05PKKmyGPKKmyEXlJxjocA5kOwfh0GT9w1G9jjR6(LXReh0YfvxXbny(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbdgqzraEalYpXdChudmRDsSdytTUgyhS1iRxlOikOrjO4XUUoyLHqEOLlQ7v6XjgRGIOGgLGQkbDYa)Jd(X5qeTCr1YVF5APth(t8a3fuV6vbvvcARQqV89DWpohIOLlQw(9lxlD6CmzkFTGIjbLGGUGGUayBXLb5OoyyRrwpy(8DzlN6a7RNbdz1JopLKKbdmLKKbZlRrwpy(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbdgqzrcEalYpXdChudmRDsSdyQsqNmW)4GFCoerlxuT87xUw60H)epWDW2IldYrDWWkdH8qlxu3R0dy(8DzlN6a7RNbdz1JopLKKbdmLKKbZlLHqEcA5kOy4k9aMFoWPMbfeiSRYobW8Z6k(ASg8adyljYTnilVzs(hahmKvxjjzWGbu2jaEalYpXdChudmRDsSdytg4FCWpohIOLlQw(9lxlD6WFIh4UGIOG2Qk0lFFh8JZHiA5IQLF)Y1sNohtMYxlOysqXCcGTfxgKJ6GHvgc5HwUOUxPhW857Ywo1b2xpdgYQhDEkjjdgykjjdMxkdH8e0YvqXWv6rqJAFbW8Zbo1mOGaHDv2jaMFwxXxJ1GhyaBjrUTbz5ntY)a4GHS6kjjdgmGY(o4bSi)epWDqnWS2jXoGnzG)Xb)4CiIwUOA53VCT0Pd)jEG7ckIcQQe0wvHE577GFCoerlxuT87xUw605yYu(Abftckbbfrb9IFzdfB5lFoT474FeumPAbnceeuefugJjwIfl3DA17nFR83y0Yf1nhwlOikOTQc9Y33Hy8VYN8xrV4Nr9LtS17CmzkFTGIzc6obW2IldYrDWWkdH8qlxu3R0dy(8DzlN6a7RNbdz1JopLKKbdmLKKbZlLHqEcA5kOy4k9iOrHWcG5NdCQzqbbc7QStam)SUIVgRbpWa2sICBdYYBMK)bWbdz1vssgmyaLDeapGf5N4bUdQbM1oj2bSjd8po4hNdr0Yfvl)(LRLoD4pXdCxqruqvLG2Qk0lFFh8JZHiA5IQLF)Y1sNohtMYxlOysqjiOikOx8lBOylF5ZPfFh)JGIjvlOrGGGIOGQkbLXyILyXYDNw9EZ3k)ngTCrDZH1ckIcAucARQqV89Dig)R8j)v0l(zuF5eB9ohtMYxlOyMGUhbb1REvqN8w5XzKKm6uODjlOysq3XOiiOla2wCzqoQdgwziKhA5I6ELEaZNVlB5uhyF9myiRE05PKKmyGPKKmyEPmeYtqlxbfdxPhbnkmAbW8Zbo1mOGaHDv2jaMFwxXxJ1GhyaBjrUTbz5ntY)a4GHS6kjjdgmGYogbEalYpXdChudmRDsSdytTUgyNwvHE57Rfuef0Oeu8yxxhSYqip0Yf19k94eJvqxqqruqV4x2qXw(YNtl(o(hbftQwqX8ia2wCzqoQdg(X5qeTCr1YVF5APtW857Ywo1b2xpdgYQhDEkjjdgykjjdMAhNdrbTCfut(9lxlDcMFoWPMbfeiSRYobW8Z6k(ASg8adyljYTnilVzs(hahmKvxjjzWGbu2XCWdyr(jEG7GAGzTtIDadp211PvHokroVXrpzBJGQAbfbccQx9QGgLGIh766Gvgc5HwUOUxPhNJjt5RfumtqxBDbfrbfp211bRmeYdTCrDVspoXyfuef0Oeu8yxxNwf6Oe58gh9KTnckMuTGUVlOE1RcAuckESRRtRcDuICEJJEY2gbftQwq3jiOikOAEqXRpw7ms(qGakMJTjOysqjiOliOliOla2wCzqoQdwJykFnA5IkBmy(8DzlN6a7RNbdz1JopLKKbdmLKKbBjXu(AbTCfuFAmy(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbdgqzpcGhWI8t8a3b1aZANe7aMQe0jd8po4hNdr0Yfvl)(LRLoD4pXdCxqruqvLGgLGozG)XznhI8j)vu9uhPd)jEG7ckIckESRRZXK1P5aR1O(k)HpNySc6cGTfxgKJ6G1YqanBJSE0GupG5Z3LTCQdSVEgmKvp68ussgmWussgSLziiOBBJSEbDrL6bST3QgSpjzvVytsUuqXWv6jIc6k)8jBlgm)CGtndkiqyxLDcG5N1v81yn4bgWwsKBBqwEZK8paoyiRUssYGzsYLckgUspruqx5NpzdgqzhJdEalYpXdChudmRDsSdytg4FCWpohIOLlQw(9lxlD6WFIh4UGIOGQkbTxJd(X5qeTCr1YVF5APtNr22i)vW2IldYrDWAziGMTrwpAqQhW857Ywo1b2xpdgYQhDEkjjdgykjjd2Ymee0TTrwVGUOs9iOrTVayBVvnyFsYQEXMKCPGIHR0tefu8sVyW8Zbo1mOGaHDv2jaMFwxXxJ1GhyaBjrUTbz5ntY)a4GHS6kjjdMjjxkOy4k9erbfV0Wak7QaEalYpXdChudmRDsSdytg4FCWpohIOLlQw(9lxlD6WFIh4UGIOG2RXb)4CiIwUOA53VCT0PZiBBK)kyBXLb5OoyTmeqZ2iRhni1dy(8DzlN6a7RNbdz1JopLKKbdmLKKbBzgcc622iRxqxuPEe0OqybW2ERAW(KKv9Inj5sbfdxPNikO4LwqhzBJ8xxmy(5aNAguqGWUk7eaZpRR4RXAWdmGTKi32GS8Mj5FaCWqwDLKKbZKKlfumCLEIOGIxAbDKTnYFfgqzFraEalYpXdChudmRDsSdytg4FCwZHiFYFfvp1r6WFIh4UGIOGIh766CmzDAoWAnQVYF4ZjgRGIOGQkbDYa)Jd(X5qeTCr1YVF5APth(t8a3bBlUmih1bRLHaA2gz9ObPEaZNVlB5uhyF9myiRE05PKKmyGPKKmylZqqq32gz9c6Ik1JGgfgTayBVvnyFsYQEXMKCPGIHR0tef0vTGoY2g5VUyW8Zbo1mOGaHDv2jaMFwxXxJ1GhyaBjrUTbz5ntY)a4GHS6kjjdMjjxkOy4k9erbDvlOJSTr(RWadykjjdMjjxkOy4k9erbTZUzCyGbaa]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170718.213417, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxtruzMfwDSrNxc51usvgBLf2CL5LtYatm3aZnXCJlXCJm0utoEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnfDVD2zSvMlW9gDP9MBZ51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnLuLXwzHnxzE5KmWeZnXaJxtjvzZ9wDYnwzZ5fvErNxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uErNx051uofwBL51utLwBd5hygj3BZrNo(bgCYv2yV1MyHrNx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170718.213417, [[deubnaqiuPAtKQ6tIOIrrL4uujTlbggs1Xe0YOs9mQO00OIkxtePTjIk9nfPXrfvDouPW6OIqZteL7rfb7JkkoisPfIk5HKctuev1fjfTrreFuevzKurYjjL6MIQDcQFsfPwkQ4Petfv1wjL8vuP0EL(RIAWuCyvTye9yfMmixgAZIYNrvgnPYPj51uHztv3gHDd8BLgUiDCuPOLJYZfA6QCDKSDKIVRioViSEQiA(KQSFkDdl)kskouVx5K)PwqHDN0WkYGPsVkvs(y2t5VYvfoOh)iwy30dNsFA40GWPUDUKYnQWbFOe8veyfsQSSaDuaEitb4nZOa48e8txqadjEfiwH2XPwqS8lCy5xrtWt6rOYvfzWuPxfsQSSa1iX89(fedyiXRarRjzwtyqsTg9TM79i4cuJeZ37xqmabpPhHQqlPYRUevYyB8MJht5aROnasn(BzvalaRKVqA9m4NaRub(jWkjHTXZAKJPCGv4GE8JyHDtpCAi9kCW4sXgyS87vrdD4Wr(sdsGGRKvYxi4NaR0RWUl)kAcEspcvUQqlPYRUevyiXYIOhJX5jkWHSkAdGuJ)wwfWcWk5lKwpd(jWkvGFcSchKyzr0JXO1WTkWHSkCqp(rSWUPhonKEfoyCPydmw(9QOHoC4iFPbjqWvYk5le8tGv6vyNT8ROj4j9iu5QImyQ0RcjvwwatrGbuPwJ(wd3TgxSgsQSSGL0RoK9NAbbuPwJ(wZpofn4mcqcfgTMKznUTgxRqlPYRUev0Tt8kaVzs)hVkAdGuJ)wwfWcWk5lKwpd(jWkvGFcSItTt8kapRHl)hVkCqp(rSWUPhonKEfoyCPydmw(9QOHoC4iFPbjqWvYk5le8tGv6vyNR8ROj4j9iu5QImyQ0RYT845XGXUEODciAn6BnUynUynC3AU3JGliJTojcMtP8rmabpPhHSg90ZACXAyua0AsM142A03Ayua1yoDNGSGbfJHGZAsM1425TgxTgxTgxRqlPYRUevwsV6q2FQfurBaKA83YQawawjFH06zWpbwPc8tGvCAsV6q2FQfuHd6XpIf2n9WPH0RWbJlfBGXYVxfn0Hdh5lnibcUswjFHGFcSsVcN0YVIMGN0JqLRkYGPsVkmkaAnoJ14SwJE6znKuzzbouEVcWBM4h6uamGk1A0tpRHKkllyj9Qdz)PwqavAfAjvE1LOYs6vhY(dROnasn(BzvalaRKVqA9m4NaRub(jWkonPxDi7pSch0JFelSB6HtdPxHdgxk2aJLFVkAOdhoYxAqceCLSs(cb)eyLEfo5w(v0e8KEeQCvrgmv6v5wE88yWyxp0obeTg9TgxSgxSgKBsPstrOGXcIl7IZJ1dnpwgAn6PN1qsLLfKQ8(NnVzZzSnEbuPwJRwJ(wdjvwwafq36tmhpgc4D6cOsTg9TgiKKkllG9o5YudmiE)WH14eSMKAn6BnC3AiPYYcwsV6q2FQfeqLAnUwHwsLxDjQevai2ZBJFCoJILOI2ai14VLvbSaSs(cP1ZGFcSsf4NaRikae75TXp5eTMKqXsuHd6XpIf2n9WPH0RWbJlfBGXYVxfn0Hdh5lnibcUswjFHGFcSsVcpT8ROj4j9iu5QImyQ0RcjvwwGdL3Ra8Mj(HofadOsTg9TgxSgUBni3KsLMIqbow)PyFCgGtYwka08eL3Bn6PN1CVhbxaV)0HmfG3C8wgracEspczn6PN18JtrdoJaKqHrRXzCcwJBRX1k0sQ8QlrLm2gV4iXPdROnasn(BzvalaRKVqA9m4NaRub(jWkjHTXlosC6WkCqp(rSWUPhonKEfoyCPydmw(9QOHoC4iFPbjqWvYk5le8tGv6vyNV8ROj4j9iu5QImyQ0RcJcOgZP7eKfmOymeCwJZynopDRrp9SgxSgsQSSGL0RoK9NAbbuPwJ(wd3TgsQSSahkVxb4nt8dDkagqLAnUwHwsLxDjQKX24nhpMYbwrBaKA83YQawawjFH06zWpbwPc8tGvscBJN1iht5aTgxcDTch0JFelSB6HtdPxHdgxk2aJLFVkAOdhoYxAqceCLSs(cb)eyLEfMBu(v0e8KEeQCvHwsLxDjQSKE1HS)WkAdGuJ)wwfWcWk5lKwpd(jWkvGFcSItt6vhY(dTgxcDTch0JFelSB6HtdPxHdgxk2aJLFVkAOdhoYxAqceCLSs(cb)eyLEfoKE5xrtWt6rOYvfzWuPxfgfqnMt3jilyqXyi4SMKzntPBn6BnC3AiPYYc0rb4HmfG3mJcGZtWpDbbuPvOLu5vxIk6wgyEZMNOahYQOnasn(BzvalaRKVqA9m4NaRub(jWko1YawZMznCRcCiRch0JFelSB6HtdPxHdgxk2aJLFVkAOdhoYxAqceCLSs(cb)eyLEfomS8ROj4j9iu5QcTKkV6suHN)hQ3p)q08GbwrBaKA83YQawawjFH06zWpbwPc8tGvsE(FOEV1qlenpyGv4GE8JyHDtpCAi9kCW4sXgyS87vrdD4Wr(sdsGGRKvYxi4NaR0RWHUl)kAcEspcvUQqlPYRUevYyB8MJht5aROnasn(BzvalaRKVqA9m4NaRub(jWkjHTXZAKJPCGwJlUDTch0JFelSB6HtdPxHdgxk2aJLFVkAOdhoYxAqceCLSs(cb)eyLEfo0zl)kAcEspcvUQidMk9QClpEEmySRhANaIwJ(wJlwd3TgsQSSaDuaEitb4nZOa48e8txqavQ14AfAjvE1LOIokapKPa8MzuaCEc(PlOI2ai14VLvbSaSs(cP1ZGFcSsf4NaR4uuaEitb4znCOaO1WT4NUGkCqp(rSWUPhonKEfoyCPydmw(9QOHoC4iFPbjqWvYk5le8tGv6v4qNR8ROj4j9iu5QImyQ0RYT845XGXUEODciwHwsLxDjQGeP7eKnZOa48e8txqfTbqQXFlRcybyL8fsRNb)eyLkWpbwrtI0DcYSgoua0A4w8txqfoOh)iwy30dNgsVchmUuSbgl)Ev0qhoCKV0Gei4kzL8fc(jWk96vb(jWkIIqdRjjSnEorRHx0Ao1WHcWRxl]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170718.213417, [[deuDsaqiQKSjOQ(evsLgfuLtraRIkPyxuXWiOJbfltI8mjuMguQUMGKTbLs9njQXrLuX5ee16Osk18Kq19GsX(OQ4GuLAHujEivjtKkPKlsvLnki1iHsjNKQQUjuzNe6NccTuQupLYuPk2kvL(QGG9Q6VKYGr5WqwmQ6XsAYk6YGnJk(mPQrtQCAIETGA2cDBf2nIFl1WrLoUGilxPNtY0fDDb2ob67sW5HswpvsvZxcz)i9XCp3mUqvIIsxpkLn5ILcfMBwDLCZB3CTaoOGyExU5gIasbxSKqmLfwgtzhmLlH9qfY3CdOjwEKd42gqKvnUDbyD4GIrLw2ALfEZ7AkBI6EUiM75MFeeFeM3LBwDLCZBjkcK0rwXslrXMOCacIpctkdFkJpGdhhzflTefBIYzHbssuuwXPm91jLHpLv7oo7ceh(fqPoTMJMssMlsFRqolmqsIIY8HY2acOCs5a0Ywd738MxgLjw34STk1u5kdd38NmLvu27nstGB46PVOvenGB3erd4wO3wLuMLRmmCZnebKcUyjHykJr4n3GQd2kOUNN38shudJRfegajp)nC9uenGBpVyP75MFeeFeM3LBwDLCZBjkcK0rpk1bRKOxtL9oCacIpcZBEZlJYeRBlm6vbrqP0kijjS38NmLvu27nstGB46PVOvenGB3erd4MBy0RcIGsrzHGKKWEZnebKcUyjHykJr4n3GQd2kOUNN38shudJRfegajp)nC9uenGBpVyXUNB(rq8ryExUz1vYnVXhWHJZkhGtaxkdFkBdiGYjLdqlBnStzfNYWJY0xNuMRHYkrzcCZBEzuMyDtxxikj614JivEZFYuwrzV3inbUHRN(Iwr0aUDtenGByRUqus0tzUerQ8MBicifCXscXugJWBUbvhSvqDppV5LoOggxlimasE(B46PiAa3EErSFp38JG4JW8UCZQRKBEBdiGYjLdqlBnSnLvCktFDsz4tzUIYsueiPJEuQdwjrVMk7D4aeeFeM38MxgLjw3A(OmHfLWn)jtzfL9EJ0e4gUE6lAfrd42nr0aUfI8rzclkHBUHiGuWfljetzmcV5guDWwb1988Mx6GAyCTGWai55VHRNIObC75fd19CZpcIpcZ7YnRUsU5TnGakNuoaTS1WoLvCktFDsz4tz4rz1UJZUaXHFbuQtR5OPKK5I03kKZcdKKOOmFOmHuwrfrzBarw142fG1PgSlqskR4uwzHuMa38MxgLjw3A(OmHfLWn)jtzfL9EJ0e4gUE6lAfrd42nr0aUfI8rzclkbkdpmcCZnebKcUyjHykJr4n3GQd2kOUNN38shudJRfegajp)nC9uenGBpVi2(EU5hbXhH5D5Mvxj382gqKvnUDbyDQb7cKKY8bBOSqouug(uMcsn(MeOCsjSycznSZTsz(qzcPm8PSA3XzxG4WVak1P1C0usYCr6BfYzHbssuuMpuMWBEZlJYeRBC2wLAQCLHHB(tMYkk79gPjWnC90x0kIgWTBIObCl0BRskZYvggOm8WiWn3qeqk4ILeIPmgH3CdQoyRG6EEEZlDqnmUwqyaK883W1tr0aU98ILVNB(rq8ryExUz1vYnVXhWHJZkhGtaxkdFkdcPajxUW0HlSkqqyrKkO1C0sDGgW3eTbAtS2BEZlJYeRBlm6vbrqP0kijjS38NmLvu27nstGB46PVOvenGB3erd4MBy0RcIGsrzHGKKWsz4HrGBUHiGuWfljetzmcV5guDWwb1988Mx6GAyCTGWai55VHRNIObC75fDDUNB(rq8ryExUz1vYnVXhWHJZkhGtaxkdFkdpkB2PZcJEvqeukTcsscRtkRHLe9uwrfrz1UJZUaXzHrVkickLwbjjH1zHbssuuMpuM(6KYkQikdpkZvugesbsUCHPdxyvGGWIivqR5OL6anGVjAd0MyTug(uMROSefbs6OhL6Gvs0RPYEhoabXhHjLjaLjWnV5LrzI1nDDHOKOxJpIu5n)jtzfL9EJ0e4gUE6lAfrd42nr0aUHT6crjrpL5sePskdpmcCZnebKcUyjHykJr4n3GQd2kOUNN38shudJRfegajp)nC9uenGBpVyiFp38JG4JW8UCZQRKBEZvugFahooRCaobCPm8Pmxrz4rzjkcK0rpk1bRKOxtL9oCacIpctkdFkZvugEuwT74SlqCwy0RcIGsPvqssyDwyGKefL5dLHhLPVoPmxdLvIYeGYkQikBdiaL5dLHDktaktakdFkBdiaL5dLvSBEZlJYeRBnFuMWIs4M)KPSIYEVrAcCdxp9fTIObC7MiAa3cr(OmHfLaLHxjbU5gIasbxSKqmLXi8MBq1bBfu3ZZBEPdQHX1ccdGKN)gUEkIgWTNxeJW75MFeeFeM3LBwDLCZBzRxFeCQDhNDbIIYWNYWJYWJYGqkqYLlmDQnr1BQ0QDCQv7fOSIkIY4d4WXHRmgrRwZrJZ2Q0jGlLjaLHpLXhWHJtarxhXstLlq0N6Cc4sz4tztGpGdhNf567vwbhvIQHPmSHYcfLHpL5kkJpGdhNMpktyrPSjobCPm8PSnGiRAC7cW6ud2fijL5dLvSqrzcCZBEzuMyDtjjZfPVviLgNGfRB(tMYkk79gPjWnC90x0kIgWTBIObCZKK5I03kKRRIYcDWI1n3qeqk4ILeIPmgH3CdQoyRG6EEEZlDqnmUwqyaK883W1tr0aU98IyWCp38JG4JW8UCZQRKBEJpGdhNWYyus0RnqvDsc4eWLYWNYWJYCfLbHuGKlxy6eUJPCrkncuGthqMAfKXiLvurugQMsbbnGadjOOmFWgkReLjWnV5LrzI1noBRsvfRuhCZFYuwrzV3inbUHRN(Iwr0aUDtenGBHEBvQQyL6GBUHiGuWfljetzmcV5guDWwb1988Mx6GAyCTGWai55VHRNIObC75fXu6EU5hbXhH5D5Mvxj382gqKvnUDbyDQb7cKKY8bBOSYcV5nVmktSUXzBvQPYvggU5pzkROS3BKMa3W1tFrRiAa3UjIgWTqVTkPmlxzyGYWRKa3CdraPGlwsiMYyeEZnO6GTcQ755nV0b1W4AbHbqYZFdxpfrd42ZlIPy3Zn)ii(imVl3S6k5M3q1ukiObeyibfL5d2qzLU5nVmktSUTWOxfebLsRGKKWEZFYuwrzV3inbUHRN(Iwr0aUDtenGBUHrVkickfLfcssclLHxjbU5gIasbxSKqmLXi8MBq1bBfu3ZZBEPdQHX1ccdGKN)gUEkIgWTNxed2VNB(rq8ryExUz1vYnVHhLv7oo7ceNfg9QGiOuAfKKewNfgijrrzfNYWJY0xNuMRHYkrzcqzfveLXhWHJJEuQdwjrVMk7D4OsunmLHnuggHuMaug(uwT74SlqC4xaL60AoAkjzUi9Tc5SWajjkkZhkBdiGYjLdqlBnStz4tzjkcK0rpk1bRKOxtL9oCacIpcZBEZlJYeRBC2wLAQCLHHB(tMYkk79gPjWnC90x0kIgWTBIObCl0BRskZYvggOm8kMa3CdraPGlwsiMYyeEZnO6GTcQ755nV0b1W4AbHbqYZFdxpfrd42ZlIju3Zn)ii(imVl3S6k5M3CfLXhWHJZkhGtaxkdFkdpkZvuwIIajD0JsDWkj61uzVdhGG4JWKYkQikR2DC2fiolm6vbrqP0kijjSolmqsIIY8HYWJY0xNuMauMa38MxgLjw3A(OmHfLWn)jtzfL9EJ0e4gUE6lAfrd42nr0aUfI8rzclkbkdVIjWn3qeqk4ILeIPmgH3CdQoyRG6EEEZlDqnmUwqyaK883W1tr0aU98IyW23Zn)ii(imVl3S6k5M3QDhNDbId)cOuNwZrtjjZfPVviNfgijrrz(qzycfLHpLTbezvJBxawNAWUajPSIJnuwzHug(u2gqaLtkhGw2AfJY8HY0xN38MxgLjw301lrR5OvqssyV5pzkROS3BKMa3W1tFrRiAa3UjIgWnSvVekR5qzHGKKWEZnebKcUyjHykJr4n3GQd2kOUNN38shudJRfegajp)nC9uenGBpViMY3Zn)ii(imVl3S6k5M3QDhNDbId)cOuNwZrtjjZfPVviNfgijrrz(qzBabuoPCaAzRH9BEZlJYeRBC2wLAQCLHHB(tMYkk79gPjWnC90x0kIgWTBIObCl0BRskZYvggOm8WUa3CdraPGlwsiMYyeEZnO6GTcQ755nV0b1W4AbHbqYZFdxpfrd42ZN3erd4MjhErzHEBv6Atz8T65pa]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170718.213417, [[da0rtaqifiBIQYNOePAuuqNIsyxe1WGkhJiwgvPNPiAAuI4AqO2gvvqFJizCuvrDokrY6OePmpiO7PGSpkjhKQQwieYdveMivvGlQa2ivvQrQa1jvqDtk0oPu)KQkYsHQEQWuPk2ke4RuIAVi)fsdwLdJYIjvpwstgkxgSzf6Zu0OHOttYRPaZgvDBuz3I(TsdNuoovvYYL65smDcxNkBNsQVROoVI06PQcnFIu7xvtsipue1wPjOGcBghqrO4M4p)U3IWs7p9T8NqvnqLMu4haJmhVGqef4bEGvaY2lojsHtkjsjlrkVwcITuuGhyyt9O4ak0DJJYiDPj0Q0eTDjGodmTnLBGJPYcf(xfQnlKhYwc5HIbsMopGriIIO2knbfg(x7svfvBNHwU66gsXFwn0FtI7pPL(pD34OmsxAcTknrBxcOZatBtzN2Fw8NV)m8pd)t3nok3koq2P9NV)a)YP00amznOlG1qZYkGUJOcKakOVjkhRft7)S4pPL(pd)tW4HuiBYeiHwLMOfX2CYqY05bS)89NH)HTc5g42Ua8qPGoRsb0YnWXuz5peo0FMvS)Kw6)g0FyRqUbUTlapukOZQuaTSqvnqLM)zXFw8Nfu4VUIxjMsrdCBxaEOuqNvPaAkgoXuvMyBkYnbkmUyiG12moGckSzCaf4bUTlapuk)zzvkGMc8apWkaz7fNePKGJc8qzDDfkKhsqXeiHQbgxRboifKofgxmBghqbjiBVKhkgiz68agHikIAR0euy4Fg(x7svfvBNHwU66gsXFwn0FEX9NV)kGavFtxrwOGwILc1s0Q)z1F4(ZI)Kw6)AxQQOA7m0Yvx3qk(ZQH(BsC)jT0)P7ghLr6stOvPjA7saDgyABk70(ZI)89NUBCuUvCGStJc)1v8kXukqUZ8Q0evNNveumCIPQmX2uKBcuyCXqaRTzCafuyZ4akg8oZRsZ)qepRiOapWdScq2EXjrkj4OapuwxxHc5HeumbsOAGX1AGdsbPtHXfZMXbuqcYEsYdfdKmDEaJqefrTvAckkGavFtxrwOG2louVA1)S6pC)57V2LQkQ2odTC11nKI)S6p)mI)Z3FTlH)q4q)n5F((t3nokRP45zn6oIo2Bri70OWFDfVsmLIXElc0IOvgaumCIPQmX2uKBcuyCXqaRTzCafuyZ4ak87ElI)crRmaOapWdScq2EXjrkj4OapuwxxHc5HeumbsOAGX1AGdsbPtHXfZMXbuqcY2sipumqY05bmcrue1wPjOODPQIQTZqlxDDdP4peo0FwcI)tAP)RDjuKfkoavSOi(pe(Nzf7pPL(pD34OmsxAcTknrBxcOZatBt5g4yQS8Nvd9Nxk8xxXRetPy15vcOzcGIHtmvLj2MICtGcJlgcyTnJdOGcBghqHFsNxjGMjakWd8aRaKTxCsKscokWdL11vOqEibftGeQgyCTg4Guq6uyCXSzCafKGSrm5HIbsMopGr6ue1wPjOqSMM8GCDxESDol)57pd)RDPQIQTZqlxDDdP4pe(Nu4(Z3Fd6pD34OmsxAcTknrBxcOZatBtzN2F((RDj8hc)Z7F((RUlp2oNY6nWeir3r0IkXAM5wyYnWXuz5pR(Bse)NV)a)YP00am56MwdTjKvaDhrhzcO8Nfu4VUIxjMsbsxAcTknrBxcOZatBtkgoXuvMyBkYnbkmUyiG12moGckMrcjEGHnLIsTvAckSzCafd2LMqRsZ)W7s4pldmTnPapuwxxHc5HeuGh4bwbiBV4KiLeCuGhyyt9O4ak0DJJYiDPj0Q0eTDjGodmTnLBGJPYcftGeQgyCTg4Guq6uyCXSzCafKGS9djpumqY05bmsNIO2knbfI10KhKR7YJTZz5pF)z4FTlvvuTDgA5QRBif)HW)qmU)893G(t3nokJ0LMqRst02La6mW02u2P9NV)AxcfzHIdqflQ3)SAO)M8pF)v3LhBNtz9gycKO7iArLynZClm5g4yQS8Nv)njU)SGc)1v8kXukq6stOvPjA7saDgyABsXWjMQYeBtrUjqHXfdbS2MXbuqXmsiXdmSPuuQTstqHnJdOyWU0eAvA(hExc)zzGPT5FgkXckWdL11vOqEibf4bEGvaY2lojsjbhf4bg2upkoGcD34OmsxAcTknrBxcOZatBt5g4yQSqXeiHQbgxRboifKofgxmBghqbjiBPipumqY05bmsNIO2knbfI10KhKR7YJTZz5pF)z4FTlvvuTDgA5QRBif)HW)MeX)57Vb9NUBCugPlnHwLMOTlb0zGPTPSt7pF)1UekYcfhGkwuV)z1q)59pF)v3LhBNtz9gycKO7iArLynZClm5g4yQS8Nv)njU)SGc)1v8kXukq6stOvPjA7saDgyABsXWjMQYeBtrUjqHXfdbS2MXbuqXmsiXdmSPuuQTstqHnJdOyWU0eAvA(hExc)zzGPT5Fg61ckWdL11vOqEibf4bEGvaY2lojsjbhf4bg2upkoGcD34OmsxAcTknrBxcOZatBt5g4yQSqXeiHQbgxRboifKofgxmBghqbjiB)m5HIbsMopGr6ue1wPjOqSMM8GCDxESDol)57pd)RDPQIQTZqlxDDdP4pe(NxC)57Vb9NUBCugPlnHwLMOTlb0zGPTPSt7pF)1UekYcfhGkwuV)z1q)j5pF)v3LhBNtz9gycKO7iArLynZClm5g4yQS8Nv)njU)SGc)1v8kXukq6stOvPjA7saDgyABsXWjMQYeBtrUjqHXfdbS2MXbuqXmsiXdmSPuuQTstqHnJdOyWU0eAvA(hExc)zzGPT5FgoPfuGhkRRRqH8qckWd8aRaKTxCsKscokWdmSPEuCaf6UXrzKU0eAvAI2UeqNbM2MYnWXuzHIjqcvdmUwdCqkiDkmUy2moGcsq2wkYdfdKmDEaJqefrTvAckeRPjpix3LhBNZYF((ZW)m8pWVCknnatUUzzBrbTU8yO1TH)Kw6)0DJJYAkEEwJUJOJ9weYoT)S4pF)P7ghLDjYLFkAr0qAkqk70(Z3FyGUBCuUz(XTvvqUiyvd(BO)q8F((Bq)P7ghLxDELaAMqTPSt7plOWFDfVsmLIIkXAM5wyf0rxpLIHtmvLj2MICtGcJlgcyTnJdOGcBghqrOsSMzUfMLE5p)21tPapWdScq2EXjrkj4OapuwxxHc5HeumbsOAGX1AGdsbPtHXfZMXbuqcYwcoYdfdKmDEaJqefrTvAck0DJJYgO45vPjkhRIuLGSt7pF)z4Fd6pWVCknnat2GLxOAwbnH5X1LyOZkE()Kw6)emEifYMmbsOvPjArSnNmKmDEa7pPL(pwvOSgqHe4uq5pRg6pV)zbf(RR4vIPum2BruQtfibkgoXuvMyBkYnbkmUyiG12moGckSzCaf(DVfrPovGeOapWdScq2EXjrkj4OapuwxxHc5HeumbsOAGX1AGdsbPtHXfZMXbuqcYwIeYdfdKmDEaJqefrTvAckyvHYAafsGtbL)SAO)8sH)6kELykfnWTDb4HsbDwLcOPy4etvzITPi3eOW4IHawBZ4akOWMXbuGh42Ua8qP8NLvPa6)muIfuGh4bwbiBV4KiLeCuGhkRRRqH8qckMajunW4AnWbPG0PW4IzZ4akibzlXl5HIbsMopGriIIO2knbfTlvvuTDgA5QRBif)HWH(tke)N0s)x7s4pR(Bsk8xxXRetPy15vcOzcGIHtmvLj2MICtGcJlgcyTnJdOGcBghqHFsNxjGMjG)muIfuGh4bwbiBV4KiLeCuGhkRRRqH8qckMajunW4AnWbPG0PW4IzZ4akibzlzsYdfdKmDEaJqefrTvAckAxQQOA7m0Yvx3qk(dH)jfU)893G(t3nokJ0LMqRst02La6mW02u2P9NV)AxcfzHIdqfl6K)z1FMvmk8xxXRetPa52j6oIoRsb0umCIPQmX2uKBcuyCXqaRTzCafuyZ4akg825F74FwwLcOPapWdScq2EXjrkj4OapuwxxHc5HeumbsOAGX1AGdsbPtHXfZMXbuqcYwILqEOyGKPZdyeIOWMXbumyxAcTkn)dVlH)SmW028pdTelOy4etvzITPi3eOWFDfVsmLcKU0eAvAI2UeqNbM2MuGhkRRRqH8qckWd8aRaKTxCsKscokIAR0eu0Uuvr12zOLRUUHu8hch6pPW9NV)Axc)HW)8(NV)Q7YJTZPSEdmbs0DeTOsSMzUfMCdCmvw(ZQ)MehjiBjiM8qXajtNhWierruBLMGcXAAYdY1D5X25S8NV)m8V2LQkQ2odTC11nKI)q4FEX9Nfu4VUIxjMsbWPTZqJ2UeqNbM2MumCIPQmX2uKBcuyCXqaRTzCafuyZ4akgGtBNH(p8Ue(ZYatBtkWd8aRaKTxCsKscokWdL11vOqEibftGeQgyCTg4Guq6uyCXSzCafKGeueAqvX4v(rMqTjz7fXsibra]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170718.213417, [[dCdCdaGEKKAteu7IiVgjv7denBKA(eKBsGCBkANeAVq7gy)szueOggL8BLgSunCv4GefNIa6yuLZbc1cbPLIqlMsTCjpL0YevpNktejHPsbtgutx4IGG1ru6YOUoI2ivfBLQsBgjESkDyfZcjLptH(or15PQ60QA0i4VICsrX3urxJaCprPPbc5zij6qijz0dnGQER)iqfvQGPmK0bcfvXXKrnJVTUp16Iwh6QY26WmLHKoqLitZJJrXClVtRtVtjVZCisaqmQe5b2VH3KrTib)nDSY5skEtofB60IATErcyNu8MCk2uoQYCJFbo0ak6HgqfcGXMMHrOOQ36pculsWFthRCUKUKvXGO1HmBRFA16c36fjGBDiZ265OkoMmQqlEccT(sP11haxJX1nOsKP5XXOyUL3PNfQYjWaI8a7hv3T(Ja1ma4)oXwOcwaJkrEG9B4nzulsWFthRCUKI3KtXMoTOwRxKa2jfVjNInLJQm2p9h(r1U4jiKwkj3dGRX46gmqXC0aQqam20mmcfvXXKrLijO1Hw8eeqvV1FeOcVHKDXtqiTusUhaxJX1nsXFP(dmkKqc(Uln8khizx8eeslLK7bW1yCDJuXMZdCzTeUib)nDSY5s6swfdciZEAjSGlsadz2CHeYMKcfPIn3YX0SZLK)GGljYdHlsadzwpbkqujY084yum3Y70Zc1ma4)oXwOcwaJQm2p9h(rTibP5g)cs0VlqvqlS4yYOMX3w3NADrRdDvzBD7INGagOivIgqfcGXMMHrOOkoMmQejbTU426qlEccOQ36pcuPk4nKSlEccPLsY9a4AmUUrk(l1FGrujY084yum3Y70Zc1ma4)oXwOcwaJQm2p9h(rTibP5g)cs0VlqvqlS4yYOMX3w3NADrRdDvzBDW262fpbbmWav9GV)q)u9e)cqXCb4HbI]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170718.213417, [[dyZMeaGEkPQnjcTlfzBusyFkQA2uCBvLDcQ9kTBQ2VQ0pPKKHrk)gXqPKudwv1Wj0bfPogjohLuSqIYsvflMuTCHdd8uupwHNJKjsjvMkr1KjPPRYfvuwhLu6zivDDq2OiWwPKOnlQwgrCEkXxrk8zI08uuzKifDALgTi6VeCsrY3eLRHu6Eiv(oLAAIGUm0vPYlZJyfVYLTomhazUkRmm4dlNYkF)tqqOU3Fze2AF)1deCjl)GgeqHfwIMsMwMs2KsMKesR1u(bbQwKVFy5aY3HGiXgJPCGXqjCeb61kNEClXPQ8cRu5LN5aDdQwzL5rSIx5YpObbuyHLOPKPOvoLRUdWrIYoXXYWGpS8d(rck0GuuV)0y9dJYP1xZEwkh4hjOqdsrjyV(HrVclPYlpZb6guTYkZJyfVYLFqdcOWclrtjtrRCkxDhGJeLDIJLHbFyzREngq8(tYF)tqqOUYP1xZEwklUgdiei5c5bH66vy6R8YZCGUbvRSYWGpSSSabxY3Fs(7pVUAaKsOaLFqdcOWclrtjtrRCkxDhGJeLDIJL5rSIx5aYX5PtjXaY3HGiXgJPbueOFZtxMwVcNWkV8mhOBq1kRmpIv8kRdLNpf7hobjMOouE(usixkgRlviGCuWgbIeFsLy7jgq(oeej2ymnGIa9BE6ON2YpObbuyHLOPKPOvoLRUdWrIYoXXYWGpSmnj2M1L((lZaOUYP1xZEwkNKyBwxQGUbqD9kmTvE5zoq3GQvwzEeR4voG8DiisSXyAafb63C0LrB5h0GakSWs0uYu0kNYv3b4irzN4yzyWhw2Q0n7Hb4WYP1xZEwkt0n7Hb4WEf2kQ8YZCGUbvRSY8iwXRCa57qqKyJX0akc0V5OlJ2e1HYZNsc5sXyDPcbKJc2iqK4tQeBV8dAqafwyjAkzkALt5Q7aCKOStCSmm4dltts4V)K83FAS(Hr506RzplLtscxGKlyV(HrVcNv5LN5aDdQwzLHbFyzAc5sXyDPV)pqo((tdeis8Y8iwXRCa57qqKyJX0akc0V5OJETYP1xZEwkNeYLIX6sfcihfSrGiXlBNe9heOAPm1iwXRCkxDhGJeLDIJLFqGQf57hwoG8DiisSXykhymuchrGETYpObbuyHLOPKPO1RxzwehlWSwp4wIxyj0Q0Rfa]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170718.213417, [[dGddeaGEsQQDrGTrsH9js1Sj62IQ1PIQ2PkTxQDRy)sv)KKkggj(nW1eP8yenyvy4GQdkIoLiOJbY5iPsleblfPAXiz5kDErPNcTme65KAIKuLPsqtMqtx4IIIlJ6zKuQRJuSrPO2kjfTzqz7KuY3KkFveQplf(ojzKQO8xP0OvroSQoPizAIqoTK7jf5qQOYRrknkrGnKfA8(5SXuQz)rZlqh9hea457pgq)b1YFCYicNjRxwQ)hfy8LyAqgPZs(1SVevG6u6G6ea1rmrPPUgrYTGhgnMKmkWOTqFHSqJzMNsYIMGrKCl4HrJ0zj)A2xIkqDqkgtnIf5hG14ag249ZzJ05CWQzjR19hjUMGxJjPkzfznUCoy1SK16wv1e86WxIwOXmZtjzrtWisUf8W45ebHaylqhTWy1IxbrrsBnnmsNL8RzFjQa1bPym1iwKFawJdyyJ3pNnEgqLSMg9heKVomMKQKvK14jGkznnAPKVoC4RABHgZmpLKfnbJi5wWdJlntr2chOIxbK0Slpr6n1PyKol5xZ(subQdsXyQrSi)aSghWWgVFoBS5fOJ(dm2Iw2ysQswrwJWwGoA1Xw0Yo8nrwOXmZtjzrtWisUf8WifnWGjyRCwanWnsNL8RzFjQa1bPym1iwKFawJdyyJ3pNnEgqLSMg9heKVo6psa9kNtOXKuLSISgpbujRPrlL81HdFtZcnMzEkjlAcgrYTGhgnsNL8RzFjQa1bPym1iwKFawJdyyJ3pNnQouYk49d2ysQswrwJakzf8(b7Wx1WcnMzEkjlAcgrYTGhgjbaPiq1iGA5po1cG1QRrC)ga9ly58VgD6nbLMr6SKFn7lrfOoifJPgXI8dWACadB8(5SXMxGo6pWylA5(JeaLqJjPkzfzncBb6OvhBrl7W3ol0yM5PKSOjyej3cEyKeaKIavJaQL)4ulawRUgX9Ba0VGLZ)A0P3eKIr6SKFn7lrfOoifJPgXI8dWACadB8(5SXZa70FaG1FK4AcEnMKQKvK14jWoTayTQQj41HdJQhd7PrgMGdBa]] )

    storeDefault( [[Wowhead Frost: default]], 'actionLists', 20170718.213417, [[diuUjaqiHeTjueFcfvzucLoLqLDPedJsDmszzKKNHIKPrvL01OQQABcj8nQkJdfPohvvPwNqknpuu5EuvX(eQ6GkPwOq8qQQIUOQkBefLrkKItQQQvsvLQzsvL4MOOQ2jQ6NuvvgkvvjlvP6PetffUkvvHVkKQ9k9xs1GfCyvwmQ8yvzYO0Lr2mv5ZKuJMs60q9AHIMnf3wvz3G(nWWvkhxijlxXZHmDrxNeBxiP(oL48kjRNQkL5luy)u5Qvgv(bpodXwUk83hvj6alwPJ1fy2aqz06cSK3PyYk7KHoevEv2A(S9PX0lAvKn6Hpd2VDjgalVk)xRY6xIbquzuETYOYp4Xzi2gPI8g8wwHtXZBHBOlTQd80ryi7CQbOBrzRc)9rv8NNX4cRFjgaDb)cgLUqSrg6sRXv5pKf)UemvGaivzNm0HOYRYwZNMDLDcbuMhHkJMvwZHn4CvL3zm63lXaOUbJYkmFal)9rvIoWIv6yDbMnaugTUa3qxATz5vvgv(bpodX2iv4VpQI)arUW)K(qv(dzXVlbtfiasvwZHn4CvffePJt6dvzNqaL5rOYOzLDYqhIkVkBnFA2vK3G3Yknlptvgv(bpodX2iv4VpQI)cBm34capxGzdaLv(dzXVlbtfiasvwZHn4CvLnSXCJoWt3BaOSYoHakZJqLrZk7KHoevEv2A(0SRiVbVLvIsxGtXZBzdBm3Od809gakxu2CbM4cX6cX6cuuPG32i2Lhag10OMGpsh4P7DjHCbM4cuuPG32i2feDgDGNoKEdW7G5HWNleNleJy4cpaWWcSax4g6sR6apDegYoNAa6wg67WqKleVlef2UqCnlVFTmQ8dECgITrQWFFuLidDPvxa45ccgYoNAa6Q8hYIFxcMkqaKQSMdBW5QkCdDPvDGNocdzNtnaDv2jeqzEeQmAwzNm0HOYRYwZNMDf5n4TSYOaXp9nGfAwEkZqW0fI3f8z7cmXfgfi5cX7hxqLlWexiwxikDH8memxSQavtdgQwFuGKUf62aWfcECgI1fIrmCHhayybwGlwvGQPbdvRpkqs3cDBa4YqFhgICbMZf0SDH4AwE)VmQ8dECgITrQWFFufbdzNtnaDmpKlWmLzvL)qw87sWubcGuL1CydoxvbHHSZPgGoKUNYSQYoHakZJqLrZk7KHoevEv2A(0SRiVbVLv4u88wuGwbMv6OCiO606IYwZYhfLrLFWJZqSnsf(7JQenalgmuTleXCOSYFil(DjyQabqQYAoSbNRQyfyXGHQ15mhkRStiGY8iuz0SYozOdrLxLTMpn7kYBWBzfwItXZBXBaOu3JIAAwgYBiK1JZqo)EZY7RmQ8dECgITrQWFFuLD6dmiYqiKleDmmPPYFil(DjyQabqQYAoSbNRQm0hyqKHqiDlyystLDcbuMhHkJMv2jdDiQ8QS18PzxrEdElR8aadlWcCHBOlTQd80ryi7CQbOBzOVddrUq8UGkBxGjUWOajxiE)4cmvZYZ0LrLFWJZqSnsf(7JQenalgmuTleXCO0fIvlUk)HS43LGPceaPkR5WgCUQIvGfdgQwNZCOSYoHakZJqLrZk7KHoevEv2A(0SRiVbVLv4u88wg8hTOS1S8(7YOYp4Xzi2gPc)9rv8podoP5sQYFil(DjyQabqQYAoSbNRQa4m4KMlPk7ecOmpcvgnRStg6qu5vzR5tZUI8g8wwHtXZBzOpWGidHq6wWWKMfLTMLxZUmQ8dECgITrQWFFufMnau6cso4ysv(dzXVlbtfiasvwZHn4CvfVbGsDuo4ysv2jeqzEeQmAwzNm0HOYRYwZNMDf5n4TSYOaXp9nGfAwEkZqW0fI3f8z7cmXfEaGHfybUWn0Lw1bE6imKDo1a0Tm03HHixiExqLDZYRPvgv(bpodX2iv4VpQI)XzWjnxsUqSAXv5pKf)UemvGaivznh2GZvvaCgCsZLuLDcbuMhHkJMv2jdDiQ8QS18PzxrEdElR0S8AQkJk)GhNHyBKk83hvHzdaLUGKdoMKleRwCv(dzXVlbtfiasvwZHn4CvfVbGsDuo4ysv2jeqzEeQmAwzNm0HOYRYwZNMDf5n4TSYOaXp9nGfAwEkZqW0fI3pUatB7cmXfEaGHfybUWn0Lw1bE6imKDo1a0Tm03HHixG58JlOYUz51yQYOYp4Xzi2gPc)9rv2PpWGidHqUq0XWKgxiwT4Q8hYIFxcMkqaKQSMdBW5Qkd9bgezies3cgM0uzNqaL5rOYOzLDYqhIkVkBnFA2vK3G3YkpaWWcSax4g6sR6apDegYoNAa6wg67WqKlWC(Xfuz3Szf5n4TSsZw]] )

    storeDefault( [[Wowhead Frost: breath]], 'actionLists', 20170718.213417, [[dOdxfaGEvuvBsLQ2LOABQOI9bGMTiZhi5tQOkFJu1orv7vz3sTFkgLkLAyKYVr6XsAOQOsdMsdhHdcqNsLIogvCyuwiqSuvyXiA5cpNKNsSmrP1PIsDErXub0KLW0v1fvronOldDDQAJOsACQuyZs0NjvEgqQVcatdvQ5HkXivPs3gOgnQW3vjNev0HurrxtLsUNkv8xQ0pvrjVwffEod4KtnJmHfJCcpdmoba0loqwHXY1GQ(Z2yjdK9Cm5atitHJpRMJEn9o3i3zIqGvilbpF2dP94ZElNjawFiTvd44DgWjNAgzclgit4zGXjNlmLyHXslnwUgu1pHZUawzpnM00gNaijmb)mtiGPelCPLULbv9toqf1hvunG7NCGjKPWXNvZrVJ2ePgqIFYzASK(YYCcykXcxAPBzqvFUNy)4ZoGto1mYewmqMWZaJteyxemDuf78uglx9rMjC2fWk7PXKM24eajHj4NzIc2fbthvXuUL(iZKdur9rfvd4(jhyczkC8z1C07OnrQbK4Ne(gwDjOxyKx9rG9BSa0y5wZyV3yj9LL5(MdAkJR6dS19CK7j2pEqpGto1mYewmqMWZaJtoqW0qHjuPmwaa7hJjC2fWk7PXKM24eajHj4NzsGGPHctOs5Eb7hJjhOI6JkQgW9toWeYu44ZQ5O3rBIudiXp52gB4By1LGEHrE1hb2VXcqJLBnJ9EJn8nASa8oglOn2BASGcuglPVSmpqW0qHjuPCVG9JrU6z1ZWyVJX6OTF8CpGto1mYewmqMWZaJtUl9kbBDglijM6NWzxaRSNgtAAJtaKeMGFMjCqVsWwNlzIP(jhOI6JkQgW9toWeYu44ZQ5O3rBIudiXpH0xwMhqWyUNWyV3ydFdRUe0lmYR(iW(nwaASCRTF83AaNCQzKjSyGmHNbgNCwKj4Jb7XjC2fWk7PXKM24eajHj4NzcLmbFmypo5avuFur1aUFYbMqMchFwnh9oAtKAaj(j32ydFdRUe0lmYR(iW(nwUyS3qZybfOmwsFzzoh(whgWwNB4B09cze0o3tyS30yV3yj9LL5bemMxqV69J)CgWjNAgzclgit4zGXj3136Wa26m2dFJglaqgbTNWzxaRSNgtAAJtaKeMGFMjC4BDyaBDUHVr3lKrq7jhOI6JkQgW9toWeYu44ZQ5O3rBIudiXpj8nS6sqVWiV6Ja73y5IXYT2(XRFaNCQzKjSyGmHNbgNCcmb9cdJ9W3OXcaKrq7jC2fWk7PXKM24eajHj4NzccMGEHHB4B09cze0EYbQO(OIQbC)KdmHmfo(SAo6D0Mi1as8tcFdRUe0lmYR(iW(nwUySGwB)(jsnGe)K9Ba]] )
    

    storeDefault( [[Frost Primary]], 'displays', 20170624.232908, [[d0d4gaGEvKxcvLDrPO2MkkzMsQ8yumBfDCur3eQQMMKQUTk8nkv1oPQ9k2nr7Ne(PcnmvY4urfNMudfPgmQ0Wr4GsYZjCmQ4CQOQfkrlLsPftslNIhsL6PGLrLSokfzIQOyQqzYKOPR0fvWvPu4YqUos2Ok1wvrL2mQA7iQpkP4zOc9zOY3LWirfCyPgnknEOkNerUfLQCnkvopL8BvTwvuQxlP0XjybyAIv)Y7xUWAnrbgTbwDK8dbyAIv)Y7xUG(ekEhxbmTehYnlIP2ugqDQpDQM5xKYawJ88c06Ujw9lfXFfaVrEEbAD3eR(LI4VcWjfIcPKeZlb9ju81Ff4qlRgINJb4KcrHu6Ujw9lfPmG1ipVaTyTbhAfXFfqW(fqHEzyRgszab7xurTFkdOzEjq0mAjU4TlW2gCOTsYW(MaLJyyJ43ws1WbSaw52ENZ5TVRlh7Q35825IJx2)k82RE7cynYZlql(kfXBpNac2VaRn4qRiLbQvTsYW(MayJ02sQgoGfqlvQz69nvsg23eWws1WbSamnXQFzLKH9nbkhXWgXFaGaXO7P(uV6xgVl7Cciy)calLb4KcrHoJ2Gyw9ldylPA4awaj1bjMxkIV(acc0CEpBbR7F(MGfOJ3jGjENa4I3jGA8ozdiy)c3nXQFPiQbWBKNxG2kkth)vGMY0yweOaQu88boA8QO2p(RaQt9Pt1m)IQ5mQb6jbBdSFbn5H4Dc0tc229FO2ln5H4DcCgeFtn3ugONfTLGMmDkdqwl0Q6PETWSiqbudW0eR(Lvtnoza3dESbBdOuliMTfMfbkqhW0sCimlcuGwvp1RvGMY04xlrPmqTQ3VCb9ju8oUc0tc2gRn4qlnz64DcyqZaUh8yd2gqqGMZ7zlyJAGEsW2yTbhAPjpeVtaoPquiLKKk1m9(grkd4(jSuWf7dCBEXQGB14qGdTSIA)4VcSTbhAVF5cR1efy0gy1rYpeqjIVPMBfDDba9HBfCVnVyTjfCvI4BQ5gaV4Vciy)cOqVmSvu7NYa9KGTRMfTLGMmD8ob0mV8S))iEh7cqy0hTX6(LlOpHI3XvacdI5pu7TIUUaG(WTcU3MxS2KcUegeZFO2Ba(xUbOXuWfAPqbxFBmFrGJgVQH4Vcqy0hTXIeZlb9ju81FfyBdo0stEiQb4KcrHQMACYdKCdWeqW(f0KPtza8g55fOLKuPMP33iI)kG1ipVaTKKk1m9(gr8xb22GdT3VCdqJPGl0sHcU(2y(Ia4nYZlqlwBWHwr8xbeSFrfLPjj5)OgqW(fKKk1m9(grkdynYZlqBfLPJ)kqplAlbn5HugqW(f0Khszab7xunKYam)HAV0KPJAGMY0abAojDM4Vc0uMUsYW(MaLJyyJ4VUHBSanLPjj5FmlcuavkE(ahAjGf)vGTn4q79lxqFcfVJRaCsPzQ9C1cyTMOaDaMMy1V8(LBaAmfCHwkuW13gZxeONeST7)qTxAY0X7eyq2QtKYugqOpiMOQXH4DfOw17xUbOXuWfAPqbxFBmFrGEsW2vZI2sqtEiENam)HAV0KhIAGTn4qlnz6OgqW(f4dzPQLk1sCIugWw0e1cu8UUCS)1z5QEB2fhDSZfhdC04byX7eaVrEEbAXxPiENa9KGTb2VGMmD8ob4KcrHuE)Yf0NqX74kqTQ3VCH1AIcmAdS6i5hcWjfIcPeFLIugW3hOa3MxSk4sB0hTXkqtzABi1BaIzBHmzta]] )

    storeDefault( [[Frost AOE]], 'displays', 20170624.232908, [[dSJYgaGEPuVejXUuufVwkPzkLy2kCteupgPUTQyBkQu7Ks7vSBI2pb(Pu1WuL(TktdbzOOYGjOHdvhKk9Csogv1XrvSqfzPOkTyuA5u8qPWtbltrzDkQQjkfPPQQMmQQPR0fLkxfjLld56iAJqPTQOs2mH2os8rPOonP(mu8DQYirs6zkQy0Oy8iWjrOBjfHRHKQZtfhwYALIOVPOkD8ZpaDHV6tI9KlSoduGEQ9BHOTlaDHV6tI9KlOBJI1FwatjXGAWGOBntb4HerIChAmYhKCdqhWPxuuH2gf(QpPk23ae0lkQqBJcF1Nuf7BaCJ(PmoePpjOBJILqVbE0s3UyNtaEirKi(nk8vFsvMc40lkQq7VmyqRk23akMZd80lnJBxydOyopxY9cBafZ5bE6LMXLCVmfyldg06kPzotGP()VNW8sSzQ(d4eBtmZ)nabX(gqXCE)YGbTQmfOvwxjnZzc8754LyZu9hql5RPR9mUsAMZeGxInt1Fa6cF1N0vsZCMat9)FpHda4iADn0TRvFYyNrD)akMZd(zkapKisut1ge9QpzaEj2mv)bKKpePpPkwcfqHJgdSJsX04gNj)avS(byJ1paMy9dyI1pBafZ51OWx9jvHnab9IIk06sAQyFduKM67GJcWskkg4PiWLCVyFdWo0TB3848ChJWgOg4mfWCECu6I1pqnWzQg3dBTCu6I1pqtrIf5yZuGA4vokokCzkafTsZQh6157GJcWgGUWx9jDhAmYan6S)oEdWxRWhLZ3bhfGoGPKyqFhCuGIvp0RtGI0uewlrzkqRSyp5c62Oy9NfOg4m1VmyqlhfUy9dyqJan6S)oEdOWrJb2rPycBGAGZu)YGbTCu6I1papKiseFIs(A6ApJktbAC4oce(VaynNAfi0TVlGTEqbWAo1kqOBFxGTmyql2tUW6mqb6P2VfI2Ua8rIf5yD5AjaOFAiqiwZP25lqiFKyro2aTYI9KlSoduGEQ9BHOTlGM(KaErRLyIL6bQbot5o8khfhfUy9dudCMcyopokCX6ha3OFkJd2tUGUnkw)zbWni67HTwxUwca6NgceI1CQD(ceIBq03dBTbiOxuuHwQmPI1pWtrGBxSVbEkcGFS(b2YGbTCu6cBaErduPqXo71FEFN7zeAEMnhFQpBobumNhhfUmfqXCEub5WQL81smQmfyldg0YrHlSbOVh2A5O0f2a1aNPChELJIJsxS(bALf7j3aCFbcHsQei0wgZ5fqXCEeL8101EgvMc40lkQqRlPPI9nqn8khfhLUmfqXCEUDHnGI584O0LPa03dBTCu4cBGAGZunUh2A5OWfRFGI0uUsAMZeyQ))7jClDy)b4Hut36CPvW6mqbyd8OLWp23aBzWGwSNCbDBuS(ZcuKMIOu8(o4OaSKIIbOl8vFsSNCdW9fiekPsGqBzmNxGI0uaoAmi20yFd0jl2bIFMcO0p4dKBFxSZcOyopxstrukEHnab9IIk0(ldg0QI9nWwgmOf7j3aCFbcHsQei0wgZ5fWPxuuHwIs(A6ApJk23ae0lkQqlrjFnDTNrf7Ba2HUD7MhNxMcWdjIeXNi9jbDBuSe6nG4j3aCFbcHsQei0wgZ5fqtFYM8UNy9PEaEirKi(yp5c62Oy9NfWPxuuHwQmPITj8dWdjIeXNktQmf4rlDj3l23afPPOMuVbWhLdYKnba]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )



end

