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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170717.172458, [[da0qtaqiGOwKcOnHuAuiHofsWUuOHbIJjkltu1ZasnnKOY1asSnKO8nf04uGkNtbkRJcL5He5EaH9Pa5GIklKuQhsrnrGixePYgrIQ(OcaNePQzQa0nvKDcQFQaOLskEkQPsQ6QuOARui7v6Va1GPQdR0IjPhlYKfCzOndsFMcgns60e9AsLzl0TbSBe)wLHROooqslNWZPY0v11jX2jL8DKIZtrwVcu1(P0nR6lZjHC(lxgEbWYSeWS1BCc1lAYywVbKGczQSgmIRdlCEizdHmmB4iei5ZNnyL5zmj3OCWVV8ifopOKVCU0lpIR6lCw1xMoYQgXq1UmNeY5V8FgmeXX0DXWrdXz90A9u06bzRhbvf58mggZa9qidbfRNwRxOqKjWZhnOymGqLj5B9uY6bneRNcLZPkJY3u5Wk0bEfQYhfLPNeKP9przYrWYtxWOvaVay5YWlawgKwHoRpNqv(OOSgmIRdlCEizdZGuwd6ofrcDvF)YMPIjDtNwias(QwE6cWlawUFHZx9LPJSQrmuTlZjHC(l)NbdrCmDxmC0qCwpTwpfTEeuvKZZyymd0dHmeuSEATEHcrMapF0GIXacvMKV1tjRh0qSEAT(0DXWrdzmScDGFXsCqpbW(YJmkqGvsCwpLS(8wpfkNtvgLVPYHvOd8kuLpkktpjit7FIYKJGLNUGrRaEbWYLHxaSmiTcDwFoHQ8rH1tXmkuwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWGU6lthzvJyOAxMtc58x(pdgI4y6Uy4OH4SEATEkA9cfcA9ucewpOTEkuoNQmkFtLDkaahbSHvy4mfXY0tcY0(NOm5iy5Ply0kGxaSCz4falZkaahX6haRWWzkIL1GrCDyHZdjBygKYAq3PisOR67x2mvmPB60cbqYx1YtxaEbWY9lmLR6lthzvJyOAxMtc58xwvbk0rfc1lAcS7fiXWtDuz26P16vvGcDmDXayQ4k(r3VjDw)GS(SbRCovzu(MkNOUsId8bfSmHLPNeKP9przYrWYtxWOvaVay5YWlaw2m1vsCw)b16PpHL1GrCDyHZdjBygKYAq3PisOR67x2mvmPB60cbqYx1YtxaEbWY9lmOu9LPJSQrmuTlZjHC(l)NbdrCmDxmC0qCwpTwpfTEeuvKZZyymd0dHmeuSEAT(0DXWrdzmScDGFXsCqpbW(YJmkqGvsCwpLS(miwpTwVqHGwpLaH1dARNcLZPkJY3uzNcaWraByfgotrSm9KGmT)jktocwE6cgTc4falxgEbWYScaWrS(bWkmCMIO1tXmkuwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWuw1xMoYQgXq1UmNeY5VCavvGcDek6EuijgatZPqcJUFt6S(bbcRNYSEAT(0DXWrdzCNV0gnn7WrbcSsIZ6PK1t5kNtvgLVPYUtjcwG7mkktpjit7FIYKJGLNUGrRaEbWYLHxaSmFkrRxdUZOOSgmIRdlCEizdZGuwd6ofrcDvF)YMPIjDtNwias(QwE6cWlawUFHhw9LPJSQrmuTlZjHC(lhqvfOqhHIUhfsIbW0CkKWO73KoRFqGW6PSY5uLr5BQ8oFPnAA2HLPNeKP9przYrWYtxWOvaVay5YWlawo38L2OPzhwwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWdUQVmDKvnIHQDzojKZFzHcrMapF0GIXacvMKV1tjRpds5CQYO8nvoG7tfC6KXY0tcY0(NOm5iy5Ply0kGxaSCz4falds4(uTEZNmwwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWdw1xMoYQgXq1UmNeY5VmiB9)grYpgwHoWRqv(OyejRAedwpTwVQcuOJoLqajGd3bmQmB90A9GS1RQaf6ibtIZjDJkZwpTwVqHGwpLaH1d6Y5uLr5BQCa3Nk40jJLPNeKP9przYrWYtxWOvaVay5YWlawgKW9PA9Mpz06PygfkRbJ46WcNhs2WmiL1GUtrKqx13VSzQys30PfcGKVQLNUa8cGL7x4mivFz6iRAedv7YCsiN)Y)grYpgwHoWRqv(OyejRAedwpTwVQcuOJoLqajGd3bmQmB90A9P7IHJgYyyf6aVcv5JIrbcSsIZ6hK1dkwpTwVqHGwpLaH1d6Y5uLr5BQCa3Nk40jJLPNeKP9przYrWYtxWOvaVay5YWlawgKW9PA9Mpz06PyEkuwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWzzvFz6iRAedv7YCsiN)Ybuvbk0rOO7rHKyamnNcjm6(nPZ6PK1tzwpTwF6Uy4OHmUZxAJMMD4OabwjXz9ucewpLvoNQmkFtLHIUhfsIbWUxi1HLPNeKP9przYrWYtxWOvaVay5YWlawMYJUhfsIbRNFHuhwwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWz5R(Y0rw1igQ2L5Kqo)LdOQcuOJqr3JcjXayAofsy09BsN1piqy9GUCovzu(Mk7oLiybUZOOm9KGmT)jktocwE6cgTc4falxgEbWY8PeTEn4oJcRNIzuOSgmIRdlCEizdZGuwd6ofrcDvF)YMPIjDtNwias(QwE6cWlawUFHZaD1xMoYQgXq1UmNeY5VCavvGcD0DkrWcCNrXOYS1tR1dYwFavvGcDek6EuijgatZPqcJkZLZPkJY3uzOO7rHKyaS7fsDyz6jbzA)tuMCeS80fmAfWlawUm8cGLP8O7rHKyW65xi1HwpfZOqznyexhw48qYgMbPSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cNr5Q(Y0rw1igQ2L5Kqo)LdOQcuOJUtjcwG7mkgvMTEAT(aQQaf6iu09OqsmaMMtHegD)M0z9dcewFw5CQYO8nv2LofHbeS7fsDyz6jbzA)tuMCeS80fmAfWlawUm8cGL50PimGwp)cPoSSgmIRdlCEizdZGuwd6ofrcDvF)YMPIjDtNwias(QwE6cWlawUFHZaLQVmDKvnIHQDzojKZF5aQQaf6O7uIGf4oJIrLzRNwRpGQkqHocfDpkKedGP5uiHr3VjDw)GaH1NvoNQmkFtLtXLgjXayh1nC04ktpjit7FIYKJGLNUGrRaEbWYLHxaSS54sJKyW6zQB4OXvwdgX1HfopKSHzqkRbDNIiHUQVFzZuXKUPtleajFvlpDb4fal3VWzuw1xMoYQgXq1UCovzu(MkhqOYiwMEsqM2)eLjhblpDbJwb8cGLldVayzqcHkJyznyexhw48qYgMbPSg0DkIe6Q((Lntft6MoTqaK8vT80fGxaSC)cNnS6lthzvJyOAxMtc58xEtVulemsqaj6S(bbcRpF5CQYO8nvoTXi4n9YJaokDFzZuXKUPtleajFvlpDbJwb8cGLldVayzZBmA95sV8iw)akDF5CcdUYKfabXazjGzR34eQx0KXS(Cdq6gyznyexhw48qYgMbPSg0DkIe6Q((LPNeKP9przYrWYtxaEbWYSeWS1BCc1lAYywFUbiD9lC2GR6lthzvJyOAxMtc58xgbvf58mggFQiyjX9cL0FchyONI4PcoIo3rkNtvgLVPYPngbVPxEeWrP7lBMkM0nDAHai5RA5Ply0kGxaSCz4falBEJrRpx6LhX6hqP7TEkMrHY5egCLjlacIbYsaZwVXjuVOjJz9sI7fkP)eUbwwdgX1HfopKSHzqkRbDNIiHUQVFz6jbzA)tuMCeS80fGxaSmlbmB9gNq9IMmM1ljUxOK(t46x4SbR6lthzvJyOAxMtc58xgKT(FJi5htR7Lg2)eJizvJyW6P16bzRhbvf58mggFQiyjX9cL0FchyONI4PcoIo3rkNtvgLVPYPngbVPxEeWrP7lBMkM0nDAHai5RA5Ply0kGxaSCz4falBEJrRpx6LhX6hqP7TEkMNcLZjm4ktwaeedKLaMTEJtOErtgZ6D)scRimWYAWiUoSW5HKnmdsznO7uej0v99ltpjit7FIYKJGLNUa8cGLzjGzR34eQx0KXSE3VKWkc9lCEivFz6iRAedv7YCsiN)Y)grYpMw3lnS)jgrYQgXG1tR1dYwpcQkY5zmm(urWsI7fkP)eoWqpfXtfCeDUJuoNQmkFtLtBmcEtV8iGJs3x2mvmPB60cbqYx1YtxWOvaVay5YWlaw28gJwFU0lpI1pGs3B9ue0uOCoHbxzYcGGyGSeWS1BCc1lAYywFADV0W(NyGL1GrCDyHZdjBygKYAq3PisOR67xMEsqM2)eLjhblpDb4falZsaZwVXjuVOjJz9P19sd7FI(9ldsi0vj(v7(Ta]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170717.172458, [[diKgsaqisiweLIAtsIgfPOofLc3IsrSlizykPJrjlts6zscttPu6AKiBJavFJqghjKohbkwhjuMNsjCpsOAFkL0bvkwib8qLQMibYfjf2OsjYjjbZKsr6MsQDcYpjqPgQsjQLsOEkQPcKRQuQ2kjQVsGs2R4Ve0Gb1HPAXK0JbmzkUmYMPu9zsLrtQ60e9AGA2k62sSBv(TudhsDCsrwoupxHPRQRReBxPY3Pu68KsRxPuSFiowbuygalr)Hdd5fkmll7rG3(PVNAvmeydz3xMFyX0K8bfOQRwIwfzjc16A1QwcMWmAcq6t524VSVavvPQH3a8Y(gbuGScOWACU6KmrGWmawI(d)ToDtcL8EcJxq)JWBuLt5RnCrEgH2XeTnuyfoJeW)gh(6Jcx3gLDmKxOWHH8cfUwEge4TeMOTHclMMKpOavD1sK1AyX0OxWa0iGYhEVEcaCDVJk09rnCDBG8cfoFGQgqH14C1jzIaHzaSe9hgVCsaHOBBjmkdzxciFe4TIaxDn8gv5u(Ad7ya)iHFJX09Hv4msa)BC4RpkCDBu2XqEHchgYlu4nya)ieyqngt3hwmnjFqbQ6QLiR1WIPrVGbOraLp8E9ea46EhvO7JA462a5fkC(avrafwJZvNKjceMbWs0F4V1PBsOa6EAABVr4nQYP81gwD2TrO9fS2WkCgjG)no81hfUUnk7yiVqHdd5fkSaZUniWBPfS2WIPj5dkqvxTezTgwmn6fmancO8H3RNaax37OcDFudx3giVqHZhOTnGcRX5QtYebcZayj6p8360njuaDpnTT3i8gv5u(AdRs4bHblpDHv4msa)BC4RpkCDBu2XqEHchgYluybi8GWGLNUWIPj5dkqvxTezTgwmn6fmancO8H3RNaax37OcDFudx3giVqHZhiLcOWACU6KmrGWBuLt5Rn8YGekFQmcRWzKa(34WxFu462OSJH8cfomKxOWBFqiWk8uzewmnjFqbQ6QLiR1WIPrVGbOraLp8E9ea46EhvO7JA462a5fkC(aj4buynoxDsMiqygalr)H)wNUjHcD)Y(giWvIaRzey1f72rTC67PwHJhtNUxpQf0iW2i8gv5u(AdJUFzFHv4msa)BC4RpkCDBu2XqEHchgYlu4TC)Y(clMMKpOavD1sK1AyX0OxWa0iGYhEVEcaCDVJk09rnCDBG8cfoFGefqH14C1jzIaHzaSe9hwrqGn9JANeVmP7fIE66wiuVeaS80fEJQCkFTH7Lxfto4W71taGR7DuHUpQHRBJYogYlu4WqEHclyV8QyYbhEdw3i87yD0luAxXvet)O2jXlt6EHONUUfc1lbalpDHfttYhuGQUAjYAnSyA0lyaAeq5dRWzKa(34WxFu462a5fkC(aPObuynoxDsMiqygalr)H)wNUjHcO7PPT9gH3OkNYxByhx0kSTl81tcnKBcRWzKa(34WxFu462OSJH8cfomKxOWBWfTiWTDe4xpHaliYnHfttYhuGQUAjYAnSyA0lyaAeq5dVxpbaUU3rf6(OgUUnqEHcNpqcMakSgNRojteimdGLO)WKMwKOrtguwviAvKsiWvIad09002EOmogSqhRkFcJctfxEde4TIaBj4kfEJQCkFTHnogSWh73WEJl(l7lScNrc4FJdF9rHRBJYogYlu4WqEHclihdgbge2VH9gx8x2xyX0K8bfOQRwISwdlMg9cgGgbu(W71taGR7DuHUpQHRBdKxOW5dK1AafwJZvNKjceMbWs0Fystls0OjdkRkeTksje4krGvee43N09Og6DtBRq5zFzi7dfDU6KmiWvIad09002EOmogSqhRkFcJctfxEde4TIaRKsH3OkNYxByJJbl8X(nS34I)Y(cRWzKa(34WxFu462OSJH8cfomKxOWcYXGrGbH9ByVXf)L9HaRzlBewmnjFqbQ6QLiR1WIPrVGbOraLp8E9ea46EhvO7JA462a5fkC(azzfqH14C1jzIaHzaSe9hM00IenAYGYQcrRIucbUse43N09Og6DtBRq5zFzi7dfDU6KmiWvIad09002EOmogSqhRkFcJctfxEde4TIaxHsH3OkNYxByJJbl8X(nS34I)Y(cRWzKa(34WxFu462OSJH8cfomKxOWcYXGrGbH9ByVXf)L9HaR5Q2iSyAs(Gcu1vlrwRHftJEbdqJakF496jaW19oQq3h1W1TbYlu48bYQAafwJZvNKjceMbWs0Fystls0OjdkRkeTksje4krGFhRJEuVSqc)wOrsiWBbcmq3ttB7HY4yWcDSQ8jmkmvC5nqGTjiWkA4nQYP81g24yWcFSFd7nU4VSVWkCgjG)no81hfUUnk7yiVqHdd5fkSGCmyeyqy)g2BCXFzFiWAUcBewmnjFqbQ6QLiR1WIPrVGbOraLp8E9ea46EhvO7JA462a5fkC(azvrafwJZvNKjceMbWs0Fystls0OjdkRkeTksje4krGb6EAABpuJLsPpH6CSUw7KqHPIlVbc8wrGTe81WBuLt5RnSXXGf(y)g2BCXFzFHv4msa)BC4RpkCDBu2XqEHchgYluyb5yWiWGW(nS34I)Y(qG182AJWIPj5dkqvxTezTgwmn6fmancO8H3RNaax37OcDFudx3giVqHZhiRTnGcRX5QtYebcZayj6pmPPfjA0KbLvfIwfPecCLiWkcc87t6Eud9UPTvO8SVmK9HIoxDsge4krGb6EAABpuJLsPpH6CSUw7KqHPIlVbc8wrGvsPWBuLt5RnSXXGf(y)g2BCXFzFHv4msa)BC4RpkCDBu2XqEHchgYluyb5yWiWGW(nS34I)Y(qG1Ss2iSyAs(Gcu1vlrwRHftJEbdqJakF496jaW19oQq3h1W1TbYlu48bYsPakSgNRojteimdGLO)WKMwKOrtguwviAvKsiWvIa)(KUh1qVBABfkp7ldzFOOZvNKbbUseyGUNM22d1yPu6tOohRR1ojuyQ4YBGaVve4kuk8gv5u(AdBCmyHp2VH9gx8x2xyfoJeW)gh(6Jcx3gLDmKxOWHH8cfwqogmcmiSFd7nU4VSpeynl42iSyAs(Gcu1vlrwRHftJEbdqJakF496jaW19oQq3h1W1TbYlu48bYsWdOWACU6KmrGWmawI(dtAArIgnzqzvHOvrkHaxjc87yD0J6Lfs43cnscbElqGb6EAABpuJLsPpH6CSUw7KqHPIlVbcSnbbwrdVrvoLV2Wghdw4J9ByVXf)L9fwHZib8VXHV(OW1Trzhd5fkCyiVqHfKJbJadc73WEJl(l7dbwZISryX0K8bfOQRwISwdlMg9cgGgbu(W71taGR7DuHUpQHRBdKxOW5dKLOakSgNRojteimdGLO)WkccmPPfjA0KbLvfIwfPecCLiW4LJqG3cfhbUIWBuLt5RnSXXGf(y)g2BCXFzFHv4msa)BC4RpkCDBu2XqEHchgYluyb5yWiWGW(nS34I)Y(qG1SIAJWIPj5dkqvxTezTgwmn6fmancO8H3RNaax37OcDFudx3giVqHZhilfnGcRX5QtYebcZayj6pmE5ie4TqXrGRi8gv5u(AdRoL60)KriE5iH2so6(cRWzKa(34WxFu462OSJH8cfomKxOWcmL60)Kbbw8YriWcwKJUVWIPj5dkqvxTezTgwmn6fmancO8H3RNaax37OcDFudx3giVqHZhilbtafwJZvNKjceMbWs0F43N09OmogSqhRkFcJIoxDsge4krGrtpQD(eSwSqv))jvCPHouoWl3rH3OkNYxBy8Yj0bEzFcNYXhEVEcaCDVJk09rnCDBu2XqEHchgYluyXlhc8gGx2hcSnvo(WBW6gHpVqkUnZYYEe4TF67PwfdbENpbRfBZHfttYhuGQUAjYAnSyA0lyaAeq5dRWzKa(34WxFu462a5fkmll7rG3(PVNAvme4D(eSwC(avDnGcRX5QtYebcVrvoLV2Wa(Ck0bEzFcNYXhwHZib8VXHV(OW1Trzhd5fkCyiVqH37Zjc8gGx2hcSnvo(WBW6gHpVqkUnZYYEe4TF67PwfdbwhDewcyZHfttYhuGQUAjYAnSyA0lyaAeq5dVxpbaUU3rf6(OgUUnqEHcZYYEe4TF67PwfdbwhDewcKpFybr29L5hbYNa]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170717.172459, [[deZBcaGErsTlqXRbPMTIUjv62IANu1Ej7gv7hrggf9BHHsfvdgjnCqCqQWXqQZjsYcLswQuzXuy5k5HsPEQQLjI1rfXebvnvPQjtPPdCrqPRks4YqxxkARiOnJaBhu5ZsHVtfPNRupwHrJqhwYjbjNgLRjs05rIVHO(Ri1ZOIYIw96FSyqa66(kJ6NLBtIAk4eJjfNqIkKfoISrb07WjwBu(etAYMKPjdJPzscDQ0peCWQjl1fGfC5tszIUJbGf8T6LNw96WYlJjAvl9pwmiaDq0OXeHbsaybFR7WGnzak6qcal46qXTSrbILop4OUByjSw(kJ66(kJ6opaSGR3HtS2O8jM0KPn17WD0CnWT6fqVnrCaTBahMroqg6UH1xzuxa5tuVoS8YyIw1s3HbBYau0xfBJPTyz1HIBzJcelDEWrD3WsyT8vg119vg17k2gjrfESS6D4eRnkFIjnzAt9oChnxdCREb0Btehq7gWHzKdKHUBy9vg1fqENPEDy5LXeTQL(hlgeGoiA0yIWmIyAdNY36omytgGIETYusheKgqetBXYQdf3Ygfiw68GJ6UHLWA5RmQR7RmQ7yLPqIAqajQaIijQWJLvVdNyTr5tmPjtBQ3H7O5AGB1lGEBI4aA3aomJCGm0DdRVYOUacOdpsq1CculbKaa]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170717.172459, [[d0ZbgaGEqeTjPezxcX2Ksk7tkjntPKy2s65K6MIQhlYTb6Wk2PuTxQDJ0(jPrjLOgga)gX5jOtJYGjQHdQoiH6ucj6ysX5KsQwiO0srLwmjwUGfbk4Pqldv16eszIcjmvuXKLy6kDrq4QsjCzvxxO2iikBfvPndOTlL6BIIVlknnqeMNqs)LighisJMapdevNevXNjKRjKQ7bk6HePFck0RbPDJ5yetbg81OX(aEJiduQQClOcivHrtvU9uHkmyK7RF03D(aAYaittMiaaWNFtRBeH)eBQmi5Smc1D(rNVrXPLrOAZX9gZXie0rP(IH1OyfwLTcnw(ScKKiSQrEOfwAwsWiLqVXCsH3j0hWB0yFaVXO4ZkqvwkHvnY91p67oFanzAayK71K4q6AZXRrPcEcAoP9bpDTIXCsPpG3Ox35BogHGok1xmSgXuGbFnwUsmqGraE9(aJksswsmTerVtcQQmmvLHuJIvyv2k04aNKMQq46BKhAHLMLemsj0BmNu4Dc9b8gn2hWBumCsAQcHRVrUV(rF35dOjtdaJCVMehsxBoEnkvWtqZjTp4PRvmMtk9b8g96oKBogHGok1xmSgXuGbFnwUsmqGraE9(aJksswsmTerVtcQQCuvLHuv5wsvori1cjlnYaNKMQq46hjCWHr1QYrvvo6gfRWQSvOrGxVpWOIKO3ad6nYdTWsZscgPe6nMtk8oH(aEJg7d4nczxVpWOIuLXnWGEJCF9J(UZhqtMgag5EnjoKU2C8AuQGNGMtAFWtxRymNu6d4n61DiH5yec6OuFXWAetbg814Kww7l50dYUwvUvHPQmFJIvyv2k0yAQvjtAzeQKktVgLk4jO5K2h801kgZjfENqFaVrJ9b8gLo1QQS40Yiuv5wHPxJIdI0gPd4HjmGmqPQYTGkGufgnvzXWieWGrUV(rF35dOjtdaJCVMehsxBoEnYdTWsZscgPe6nMtk9b8grgOuv5wqfqQcJMQSyyecVUhDZXie0rP(IH1iMcm4RXYvIbcmcWR3hyursYsIPLi6DsqvLJkmvLHCJIvyv2k0iWR3hyurs0BGb9g5HwyPzjbJuc9gZjfENqFaVrJ9b8gHSR3hyurQY4gyqVQCl3eLg5(6h9DNpGMmnamY9AsCiDT541OubpbnN0(GNUwXyoP0hWB0R7TM5yec6OuFXWAetbg81y5kXabgb417dmQijzjX0sKy4gfRWQSvOrDIeheDj6nWGEJ8qlS0SKGrkHEJ5KcVtOpG3OX(aEJyIeheDvzCdmO3i3x)OV78b0KPbGrUxtIdPRnhVgLk4jO5K2h801kgZjL(aEJEDpJ5yec6OuFXWAetbg81y5kXabgb417dmQijzjX0sKy4gfRWQSvOXuDYYOIKOfmfswTrEOfwAwsWiLqVXCsH3j0hWB0yFaVrP1jlJksvgfmfswTrUV(rF35dOjtdaJCVMehsxBoEnkvWtqZjTp4PRvmMtk9b8g961yuCGtCDnSETba]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170717.172459, [[dGtIeaGEsvPnrQQ2fPYRrj7dLQzJuZxaDtP42IStLAVu7MW(LQFsQcdde)MKbRKHJIoOuYPqeDmHCosvQfIKSuuyXIQLJWdLs9uOhJQ1rQsMiIutfjMmrth4IcLRsQkUSQRlOEoO2ksQnlu12jLoSKLjkFwq(UqLZtkoTIrJO(MaDsuk)fKUMa09qKmnbWOqeEgPkAhzkgroXWey04Us3ioP29L(iiRO1Ox9vl9iMrgN(f89odsuqibJcQdcKSSi92iY88POh9TaJs4DwaZm2IdgLa2u8oYumgtu50xAQmICIHjWyXbJ2d9INMd3xStQ(kZyR8HEaAmkFbidTesOYZlngztihEbuegfkXn2OKuxe7kDJg3v6gj9la5(QeY(I0NxAmY40VGV3zqIcgbXiJdRctWpSPyGX2KpNvJs7txaCUXgLCxPB0aVZmfJXevo9LMkJiNyycmwCWO9qV4P5W9f79vam2kFOhGgJN5iFA4gztihEbuegfkXn2OKuxe7kDJg3v6gJXCKpnCJmo9l47DgKOGrqmY4WQWe8dBkgySn5Zz1O0(0faNBSrj3v6gnWB90umgtu50xAQmICIHjWyXbJ2d9INMd3xStQ(kRV0FFrI(sQa6KVaKHwcju55LgDGHZAeH6RadSVKkGo5JFOVoWWznIq9fjn2kFOhGgJWCvyIqhkmGyyDJSjKdVakcJcL4gBusQlIDLUrJ7kDJixfMi07leqmSUrgN(f89odsuWiigzCyvyc(Hnfdm2M85SAuAF6cGZn2OK7kDJg4DamfJXevo9LMkJiNyycmwCWO9qV4P5W9f7KQVY6l93xKOVKkGo5lazOLqcvEEPrhy4SgrO(kWa7lPcOt(4h6RdmCwJiuFrsJTYh6bOXiNUIBeHGctUKQ4GnYMqo8cOimkuIBSrjPUi2v6gnUR0n2MUIBeH6lKCjvXbBKXPFbFVZGefmcIrghwfMGFytXaJTjFoRgL2NUa4CJnk5Us3ObEhqtXymrLtFPPYiYjgMaJfhmAp0lEAoCFXEFLzSv(qpangpZr(0WnYMqo8cOimkuIBSrjPUi2v6gnUR0ngJ5iFA49fjIiPrgN(f89odsuWiigzCyvyc(Hnfdm2M85SAuAF6cGZn2OK7kDJgyGrs)4RW0atLb2a]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170717.172459, [[dSZCmaGEPOQ2KGAxKyBsrv2NQIzlv3uvCAe3MsEUi7ef7vz3q2pfJsvPggkzCsrfpwOZRQQbtQHtsDqssNIKWXeLZPQKfsvYsPuTyKSCu9qPWtjwgvX6KIsMivPmvkLjtLPRYffGRkfv6zsrX1rQnkfLARcOntvTDbY3uv5WsMgjr8DuQdrvQ(ROA0sP5rsKoPa1NfKRrsu3tkYLbVwv63q9YMTjIAisQoP5xhbJgJhv2ZejYjQVjtyklyIqSAy0nxulU)Vzz0PRqUI7Myh6qLGX4Hv2pw)Y(PWILhpzFnXouU)2iwWeoncskhXcYpCUNjQgpcgLMTXKnBtcavuDWnVMiror9nXbu0((k(q6aobfkNnMg5usxfFnAvAtgThJoSrZPrKyUAmBGR4aFsKCg9hJwLNOkfPtU)t8H0bCckuE64KxysWihjwhMpbHrWKhSlWIZuwWKjmLfmPzdPd4euiJwoo5fMyh6qLGX4Hv2VmwtSdjmnpcPzB3KgTq89bheybOButEWoMYcMSBmEMTjbGkQo4MxtKiNO(M4DJMI23xbbroorsk0Qn6Wg9vDaDkiiYXjssbqfvhCgDyJMtJaJwL2Kr3mtuLI0j3)joOU28iM0NemYrI1H5tqyem5b7cS4mLfmzctzbt8guxRr3at6tSdDOsWy8Wk7xgRj2HeMMhH0STBsJwi((GdcSa0nQjpyhtzbt2nMMz2MeaQO6GBEnrICI6BcfTVVccICCIKuOvB0HnAhqr77R4dPd4euOC2yAKtjDv81O)0KrNz0HnAonIeZvJzdCfh4tIKZO)y0FnrvksNC)NKIyAEiipDCYlmjyKJeRdZNGWiyYd2fyXzklyYeMYcMirmnpey0YXjVWe7qhQemgpSY(LXAIDiHP5rinB7M0OfIVp4GalaDJAYd2XuwWKDJrLmBtcavuDWnVMiror9nHI23xbbroorsk0Qn6WgTdOO99v8H0bCckuoBmnYPKUk(A0FAYOZm6WgnNgrI5QXSbUId8jrYz0Fm6VMOkfPtU)tI9Inbfkp1wom70KGrosSomFccJGjpyxGfNPSGjtyklysJEXMGcz0sB5WSttSdDOsWy8Wk7xgRj2HeMMhH0STBsJwi((GdcSa0nQjpyhtzbt2ngvE2MeaQO6GBEnrICI6BcfTVVcnQf3)NNooGcDTk0Qn6WgTdOO99v8H0bCckuoBmnYPKUk(A0FAYOZm6WgnNgrI5QXSbUId8jrYz0Fm6VMOkfPtU)tsrmnpeKNoo5fMemYrI1H5tqyem5b7cS4mLfmzctzbtKiMMhcmA54KxWO)otftSdDOsWy8Wk7xgRj2HeMMhH0STBsJwi((GdcSa0nQjpyhtzbt2nMM3Snjaur1b38AIe5e13ekAFFfAulU)ppDCaf6AvOvB0HnAhqr77R4dPd4euOC2yAKtjDv81O)0KrNz0HnAonIeZvJzdCfh4tIKZO)y0FnrvksNC)Ne7fBckuEQTCy2PjbJCKyDy(eegbtEWUalotzbtMWuwWKg9InbfYOL2YHzNm6VZuXe7qhQemgpSY(LXAIDiHP5rinB7M0OfIVp4GalaDJAYd2XuwWKDJ53Snjaur1b38AIe5e13eoncm6pnz0Em6WgTdOO99v8H0bCckuoBmnYPKUk(A0FAYOZm6WgnNgrI5QXSbUId8jrYz0Fm6VMOkfPtU)tsrmnpeKNoo5fMemYrI1H5tqyem5b7cS4mLfmzctzbtKiMMhcmA54KxWO)2JkMyh6qLGX4Hv2VmwtSdjmnpcPzB3KgTq89bheybOButEWoMYcMSBmnNzBsaOIQdU51ejYjQVjCAey0FAYO9y0HnAhqr77R4dPd4euOC2yAKtjDv81O)0KrNz0HnAonIeZvJzdCfh4tIKZO)y0FnrvksNC)Ne7fBckuEQTCy2PjbJCKyDy(eegbtEWUalotzbtMWuwWKg9InbfYOL2YHzNm6V9OIj2HoujymEyL9lJ1e7qctZJqA22nPrleFFWbbwa6g1KhSJPSGj7gZxZ2KaqfvhCZRjsKtuFtUQdOtj1wom7CcYNorWifavuDWz0Hn6R6a6uCf)nV4uKd4kaQO6GZOdB0E3OPO99vCf)n)4fk5J5w1rWifA1gDyJoIXDhMnsXv838ItroGRWbRIGsg9hJoJ1evPiDY9FIdQRnpIj9jbJCKyDy(eegbtEWUalotzbtMWuwWeVb11A0nWKUr)DMkMyh6qLGX4Hv2VmwtSdjmnpcPzB3KgTq89bheybOButEWoMYcMSBmzSMTjbGkQo4MxtKiNO(MCvhqNsQTCy25eKpDIGrkaQO6GZOdB0E3OVQdOtXv838ItroGRaOIQdoJoSr7DJMI23xXv838JxOKpMBvhbJuOvprvksNC)N4G6AZJysFsWihjwhMpbHrWKhSlWIZuwWKjmLfmXBqDTgDdmPB0F7rftSdDOsWy8Wk7xgRj2HeMMhH0STBsJwi((GdcSa0nQjpyhtzbt2nMSSzBsaOIQdU51ejYjQVjx1b0P4k(BEXPihWvaur1bNrh2OJyC3HzJuCf)nV4uKd4kCWQiOKr)XOZynrvksNC)N4G6AZJysFsWihjwhMpbHrWKhSlWIZuwWKjmLfmXBqDTgDdmPB0F3mQyIDOdvcgJhwz)YynXoKW08iKMTDtA0cX3hCqGfGUrn5b7yklyYUXK5z2MeaQO6GBEnrICI6BI3n6R6a6usTLdZoNG8PtemsbqfvhCgDyJ27g9vDaDkUI)MxCkYbCfavuDWnrvksNC)N4G6AZJysFsWihjwhMpbHrWKhSlWIZuwWKjmLfmXBqDTgDdmPB0FRsuXe7qhQemgpSY(LXAIDiHP5rinB7M0OfIVp4GalaDJAYd2XuwWKD7M4nWVO738A3ga]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170717.172459, [[dStujaGEQqvBsOSlsSnQqL9rfmBrDtvXZf5BQsDAK2jkTxLDd1(PyuOiggQ04OcPESGZtkmyknCsvhcfvNcfLJPsDovcSqsrlLkAXQQLJ4HcvpLyzOI1rfsMikstLuzYu10L6IujDvQqXLbxhvTrQqPTsLQnlKTtL4zKsoSKPrfIVRk51QO)QcJgfMNkbDsQu(SkPRPsO7Ps0VHCqsPUnj9UNUjIEiqRm1XxnfHhlNlYzcBPcteQACJ1XGzGYA4Om2qLA61QrKjoHmujySC4E)M7773kC5YHZ9fmrceQ(EYeTdnfHtt3yVNUjUIRFg8tZjsGq13t8WNpksjcsnqO4RhVq8yVsQRWPXEHxASoIXgZyj8yA4qp6fqu8qenqBJ1bJLJwt0(tZ0wJjrqQbcfF9i1e6jmXnSNgQgrMGryyYdY7ErylvyYe2sfM4yHudek(QXknHEctCczOsWy5W9(9n3joHeINeG00TEsCgq48b5cOc4E)jpipBPctwpwot3exX1pd(P5ejqO67jm3y)8rrkyiqqjAsHxVXgZy7kd4wbdbckrtkaU(zWBSXmwcpgm2l8sJvRjA)PzARXepunJJaIMN4g2tdvJitWimm5b5DViSLkmzcBPctykundJnoIMN4eYqLGXYH797BUtCcjepjaPPB9K4mGW5dYfqfW9(tEqE2sfMSESAnDtCfx)m4NMtKaHQVN85JIuWqGGs0KcVEJnMX6HpFuKseKAGqXxpEH4XELuxHtJ1HlnwTm2yglHhtdh6rVaIIhIObABSoySC0AI2FAM2Amjfq8KRWrQj0tyIBypnunImbJWWKhK39IWwQWKjSLkmrciEYvWyLMqpHjoHmujySC4E)(M7eNqcXtcqA6wpjodiC(GCbubCV)KhKNTuHjRhRJmDtCfx)m4NMtKaHQVN85JIu4XmqznosnbWxBgk86n2ygRh(8rrkrqQbcfF94fIh7vsDfonwhU0y1YyJzSeEmnCOh9cikEiIgOTX6GXYrRjA)PzARXKuaXtUchPMqpHjUH90q1iYemcdtEqE3lcBPctMWwQWejG4jxbJvAc9emwMCZSjoHmujySC4E)(M7eNqcXtcqA6wpjodiC(GCbubCV)KhKNTuHjRh7fNUjUIRFg8tZjsGq13ti8yWyD4sJLJXgZy9WNpksjcsnqO4RhVq8yVsQRWPX6WLgRwgBmJLWJPHd9OxarXdr0aTnwhmwoAnr7pntBnMKciEYv4i1e6jmXnSNgQgrMGryyYdY7ErylvyYe2sfMibep5kySstONGXYeomBItidvcglhU3VV5oXjKq8KaKMU1tIZacNpixava37p5b5zlvyY6X64MUjUIRFg8tZjsGq13t6kd4wjXO8OxhuCeFIIWkaU(zWBSXm2UYaUv8f58OiFAdefax)m4n2yglZn2pFuKIViNhnPWPierTAkcRWR3yJzSbek7rVWk(ICEuKpTbIcbulkozSoyS3xCI2FAM2AmXdvZ4iGO5jUH90q1iYemcdtEqE3lcBPctMWwQWeMcvZWyJJOzJLj3mBItidvcglhU3VV5oXjKq8KaKMU1tIZacNpixava37p5b5zlvyY6X(E6M4kU(zWpnNibcvFpPRmGBLeJYJEDqXr8jkcRa46NbVXgZyzUX2vgWTIViNhf5tBGOa46NbVXgZyzUX(5JIu8f58OjfofHiQvtryfE9t0(tZ0wJjEOAghbenpXnSNgQgrMGryyYdY7ErylvyYe2sfMWuOAggBCenBSmHdZM4eYqLGXYH797BUtCcjepjaPPB9K4mGW5dYfqfW9(tEqE2sfMSESo6PBIR46Nb)0CIeiu99KUYaUv8f58OiFAdefax)m4n2ygBaHYE0lSIViNhf5tBGOqa1IItgRdg79fNO9NMPTgt8q1mociAEIBypnunImbJWWKhK39IWwQWKjSLkmHPq1mm24iA2yzIwmBItidvcglhU3VV5oXjKq8KaKMU1tIZacNpixava37p5b5zlvyY6XEbt3exX1pd(P5ejqO67jm3y7kd4wjXO8OxhuCeFIIWkaU(zWBSXmwMBSDLbCR4lY5rr(0gikaU(zWpr7pntBnM4HQzCeq08e3WEAOAezcgHHjpiV7fHTuHjtylvyctHQzySXr0SXYehHztCczOsWy5W9(9n3joHeINeG00TEsCgq48b5cOc4E)jpipBPctwVEctHOIp3tZ1Ba]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170717.172459, [[dSJwmaGEvfP2KGAxK02uveTpvLMTkUPQ45ICBk50i2jk2RYUbTFkgLQknmuY4uveESqNNemysnCs0bPuCksihtLCovvSqkLwkvPfJKLJQhkk9uILrvSorHYejHAQuQMmvMUuxuaUQQIKNPQW1rQnkkuTvb0MPQ2Ua5BQQ6WsMMQIY3rPoKOG)kQgTk18uvuDsbQplixtui3tu0LHETQ0VbExZ(erjgj1H8PRMaGJXtg5zctzHteIvwJ(tbVbhfYygnbMAoDSb80eV4bReogpSU(Z6)1FvwS8456NjsKtu2tMytSjayA2hZ1SpjayrDq3SDIe5eL9ehsr77R6JPg5eyOC2aAOtn1v81O)8mnApgDyJMtdjXCLa2ix1H(KiPn6VgDgnXgkYH0kmXhtnYjWq5PMtEXjbdDKy1a(eiaItEaUalotzHtMWuw4KmoMAKtGHmAP5KxCIx8GvchJhwx)VynXlMa08iMM91tYEJX3hqqOfc7rn5b4yklCY6X4z2NeaSOoOB2orICIYEsgmAkAFFvig5GejPsR0OdB0DDqyRcXihKijvewuh0z0HnAonen6pptJ(Jj2qroKwHjoS678iGCMem0rIvd4tGaio5b4cS4mLfozctzHtumw9TrNfqot8IhSs4y8W66)fRjEXeGMhX0SVEs2Bm((accTqypQjpahtzHtwpMpM9jbalQd6MTtKiNOSNqr77RcXihKijvALgDyJ2Hu0((Q(yQrobgkNnGg6utDfFn6VzA0Fy0HnAonKeZvcyJCvh6tIK2O)A0)mXgkYH0kmjfb08qyEQ5KxCsWqhjwnGpbcG4KhGlWIZuw4KjmLforIaAEi0OLMtEXjEXdwjCmEyD9)I1eVycqZJyA2xpj7ngFFabHwiSh1KhGJPSWjRhZNn7tcawuh0nBNirorzpHI23xfIroirsQ0kn6WgTdPO99v9XuJCcmuoBan0PM6k(A0FZ0O)WOdB0CAijMReWg5Qo0NejTr)1O)zInuKdPvys8uSjWq5P7YbyNMem0rIvd4tGaio5b4cS4mLfozctzHtYEk2eyiJwUlhGDAIx8GvchJhwx)VynXlMa08iMM91tYEJX3hqqOfc7rn5b4yklCY6XKrZ(KaGf1bDZ2jsKtu2tOO99vPH3GJc5PMJWq9TkTsJoSr7qkAFFvFm1iNadLZgqdDQPUIVg93mn6pm6WgnNgsI5kbSrUQd9jrsB0Fn6FMydf5qAfMKIaAEimp1CYlojyOJeRgWNabqCYdWfyXzklCYeMYcNiranpeA0sZjVOr)7LIM4fpyLWX4H11)lwt8IjanpIPzF9KS3y89beeAHWEutEaoMYcNSEmFYzFsaWI6GUz7ejYjk7ju0((Q0WBWrH8uZryO(wLwPrh2ODifTVVQpMAKtGHYzdOHo1uxXxJ(BMg9hgDyJMtdjXCLa2ix1H(KiPn6Vg9ptSHICiTctINInbgkpDxoa70KGHosSAaFceaXjpaxGfNPSWjtyklCs2tXMadz0YD5aStg9VxkAIx8GvchJhwx)VynXlMa08iMM91tYEJX3hqqOfc7rn5b4yklCY6X8F2NeaSOoOB2orICIYEcNgIg93mnApgDyJ2Hu0((Q(yQrobgkNnGg6utDfFn6VzA0Fy0HnAonKeZvcyJCvh6tIK2O)A0)mXgkYH0kmjfb08qyEQ5KxCsWqhjwnGpbcG4KhGlWIZuw4KjmLforIaAEi0OLMtErJ(xpkAIx8GvchJhwx)VynXlMa08iMM91tYEJX3hqqOfc7rn5b4yklCY6X8jM9jbalQd6MTtKiNOSNWPHOr)ntJ2Jrh2ODifTVVQpMAKtGHYzdOHo1uxXxJ(BMg9hgDyJMtdjXCLa2ix1H(KiPn6Vg9ptSHICiTctINInbgkpDxoa70KGHosSAaFceaXjpaxGfNPSWjtyklCs2tXMadz0YD5aStg9VEu0eV4bReogpSU(FXAIxmbO5rmn7RNK9gJVpGGqle2JAYdWXuw4K1J5NzFsaWI6GUz7ejYjk7jDDqyRMUlhGDob6tNiaOkclQd6m6WgDxhe2QUI)MxCksJCvewuh0z0Hn6my0u0((QUI)M38cM8bCRQjaOkTsJoSrhbGJdWgQ6k(BEXPinYv5OvrGjJ(RrFXAInuKdPvyIdR(opciNjbdDKy1a(eiaItEaUalotzHtMWuw4efJvFB0zbKJr)7LIM4fpyLWX4H11)lwt8IjanpIPzF9KS3y89beeAHWEutEaoMYcNSEmxSM9jbalQd6MTtKiNOSN01bHTA6UCa25eOpDIaGQiSOoOZOdB0zWO76GWw1v838ItrAKRIWI6GoJoSrNbJMI23x1v838MxWKpGBvnbavPvoXgkYH0kmXHvFNhbKZKGHosSAaFceaXjpaxGfNPSWjtyklCIIXQVn6SaYXO)1JIM4fpyLWX4H11)lwt8IjanpIPzF9KS3y89beeAHWEutEaoMYcNSEmxxZ(KaGf1bDZ2jsKtu2t66GWw1v838ItrAKRIWI6GoJoSrhbGJdWgQ6k(BEXPinYv5OvrGjJ(RrFXAInuKdPvyIdR(opciNjbdDKy1a(eiaItEaUalotzHtMWuw4efJvFB0zbKJr)7hkAIx8GvchJhwx)VynXlMa08iMM91tYEJX3hqqOfc7rn5b4yklCY6XC5z2NeaSOoOB2orICIYEsgm6UoiSvt3LdWoNa9PteaufHf1bDgDyJodgDxhe2QUI)MxCksJCvewuh0nXgkYH0kmXHvFNhbKZKGHosSAaFceaXjpaxGfNPSWjtyklCIIXQVn6SaYXO)9Zu0eV4bReogpSU(FXAIxmbO5rmn7RNK9gJVpGGqle2JAYdWXuw4K1RNOy0VOp9SD9g]] )

    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170717.172459, [[deeIxaqisiBsQ0NOkPYOqeNcrAxuXWqvoMiwgPQNrvIMgvjCnef2gvjLVHOACKqPZjvK1rvsvZdrr3drP9rvsoijQfsI8qsLMiju0fjvSrQQYhjHcJuQO6KuL6Msv7ev(PurzPKINszQKsBLQkFLQQYEv(lvAWeDyGfJWJf1Kb5YQ2Su6ZuvgnQQtJYRPkMTq3gu7gQFdz4sXXjHQLJ0ZfmDjxNK2Ui13jbNxKSEQQQMVuH9t4LmTZ4aWFMXG1vi9hffkVEH03XNYYZSMNzGiZ)bfdHhNEYizMI5BbQXAkntZJhe(40ZlHCEKNqUdpE61N0PzAoakLwg8NPOcepUCAPOqfYPk(35yar8qcjadjK8esevijuBBD8WIrg2NlmiZNHVd9Wagomt5CXq4W0oUKPDMoyar8qtPzwMYAQzfYNV4DYiuecPaoiKDfssessesfjKfiEC50sr()XUnQXWDogqepKq2rhcjjcjvfFHKmfs9czxHKQIzz3gKcN6KvP0JlHKmfs9kwHKuHKuHSRqQiHSaXJlhFGI)PmSp3qHOWohdiIhsijDMYeSiRsndrez1PGIHWZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pRZiIS6uqXq4zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB140pTZ0bdiIhAknZYuwtnJqTT1HLt5wGichCOhgWWbHKmfYehYqi7kKfiEC5WYPClqeHdohdiIhAMYeSiRsnRLIcLBOOmpFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL55Z084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QX5Lt7mDWaI4HMsZSmL1uZkq84YjWhu1PmSp3qrzEEW5yar8qczxHe6eQTTouG)JOS8Dcfi7rijRqsgZuMGfzvQzTuuOCdfL55Z8gdXYGcrNHr4pRhb5hGYbG)SzCa4pZFuuOesROmpxijjH0zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB148IPDMoyar8qtPzwMYAQzKiKeQTToug8DuBeYUc5vCvwtZHCAon80NcW57IADl(39eiSlmGwPOczxHurcjjcjHABRdIiYQtbfdHDuBeYUcjixS0394dZEqijtHuVqsQqsQq2rhczbIhxo(af)tzyFUHcrHDogqep0mLjyrwLAg9WiA4XhcUkWW1PZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4ptZHr0WJpees)JHRtNP5XdcFC65LqEcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJJmM2z6GbeXdnLMzzkRPMrO226qzW3rTri7kKksijrijuBBDqerwDkOyiSJAJq2vib5IL(UhFy2dcjzkK6fssfYUcPIesseYR4QSMMd50CA4PpfGZ3f16w8V7jqyxyaTsrfYUczbIhxo(af)tzyFUHcrHDogqepKqs6mLjyrwLAgFKcrg2NlreeQzEJHyzqHOZWi8N1JG8dq5aWF2moa8N15ifImSpHuPiiuZ084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QX51M2z6GbeXdnLMzzkRPMrO226qzW3rTri7kKksijrijuBBDqerwDkOyiSJAJq2vib5IL(UhFy2dcjzkK6fssfYUc5vCvwtZHCAon80NcW57IADl(39eiSlmGwPOczxHSaXJlhFGI)PmSp3qHOWohdiIhsi7kKKiKqNqTT1P50WtFkaNVlQ1T4F3tGWUWaALI6O2iKD0HqMrOiesbSd9WiA4XhcUkWW1Po0ddy4Gq6vcPxkKKotzcwKvPMXhPqKH95sebHAM3yiwgui6mmc)z9ii)auoa8NnJda)zDosHid7tivkccLqsscPZ084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXr(0othmGiEOP0mltzn1mfjKeQTToiIiRofume2rTri7kKKiKxXvznnhYXdkwmki4IVcTivmKRcSyui7kKfiEC50sr()XUnQXWDogqepKq2vijridVCjqy1GtXonPtU6BYcjzfYeHSJoeYWlxcewn4uStt6KRx0KfsYkKjcjPcjPczhDiKuv8dofd(UfYLmesYui9LHMPmblYQuZqerwDkO(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z6mIiRofuFMMhpi8XPNxc5j8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(Zwnof70othmGiEOP0mltzn1Sc5Zx8ozekcHuaheYUcjjcjjc5vCvwtZHCYiCarRGBgfHCZi6fYo6qijuBBDAyXiG6IADBPOq5O2iKKkKDfsc12whvmFumLBOOh7R47O2iKDfsOtO226qb(pIYY3juGShHKScjziKDfsfjKeQTToiIiRofume2rTrijDMYeSiRsnlWWquGpuaeCBvPPM5ngILbfIodJWFwpcYpaLda)zZ4aWFMXWquGpua41fes)PstntZJhe(40ZlH8eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgxNM2z6GbeXdnLMzzkRPMrvXSSBdsHtDGEllZkHKmjRqMWBMYeSiRsnRLIcLBOOmpFM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcLqAfL55cjj6jDMMhpi8XPNxc5j8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUeEt7mDWaI4HMsZSmL1uZiuBBDqerwDkOyiSJAJq2vivKqsO2264HfJmSpxyqMpdFh1MzktWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK4LKotZJhe(40ZlH8eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgxsY0othmGiEOP0mltzn1mqUyPV7XhM9Gq6vKvi1lKDfsfjKKiKfiEC50srHkKtv8VZXaI4HeYUcjHABRJhwmYW(CHbz(m8DuBeYUcjixS0394dZEqi9kYkK6fssNPmblYQuZOhgrdp(qWvbgUoDM3yiwgui6mmc)z9ii)auoa8NnJda)zAomIgE8HGq6FmCDQqsscPZ084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXLOFANPdgqep0uAMLPSMAgHABRJhwmYW(CHbz(m8DuBeYUcjjcPIeYR4QSMMd54bflgfeCXxHwKkgYvbwmkKD0HqcYfl9Dp(WShesVIScPEHK0zktWISk1SwkkuHCQI)N5ngILbfIodJWFwpcYpaLda)zZ4aWFM)OOqfYPk(FMMhpi8XPNxc5j8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUeVCANPdgqep0uAMLPSMAgixS0394dZEqi9kYkK6NPmblYQuZ8fbzgi6cGsdW5pZBmeldkeDggH)SEeKFakha(ZMXbG)mfJiiZarHuzO0aC(Z084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXL4ft7mDWaI4HMsZSmL1uZa5IL(UhFy2dcPxrwH0lNPmblYQuZAPOqfYPk(FM3yiwgui6mmc)z9ii)auoa8NnJda)z(JIcviNQ4FHKKesNP5XdcFC65LqEcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlHmM2z6GbeXdnLMzzkRPMrO2264HfJmSpxyqMpdFh1MzktWISk1merKvNcQpZBmeldkeDggH)SEeKFakha(ZMXbG)SoJiYQtb1fsssiDMMhpi8XPNxc5j8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(ZwnUeV20othmGiEOP0mltzn1ScepUC8bk(NYW(CdfIc7CmGiEiHSRqwG4XLdSkf6uKAW9TTSm74CkNJbeXdjKDfsseYWlxcewn4uStt6KR(MSqswHmri7OdHm8YLaHvdof70Ko56fnzHKSczIqs6mLjyrwLAwlffk3qrzE(mVXqSmOq0zye(Z6rq(bOCa4pBgha(Z8hffkH0kkZZfss8csNP5XdcFC65LqEcVzAEaPsZpmTRMPl)N90JsF4JRrmRhbXbG)SvJlH8PDMoyar8qtPzwMYAQzKiKfiEC5WhrXUOwxfy46uNJbeXdjKD0HqwG4XLdFvSVtzyFUuv8Dv4Gge25yar8qcjPczxHKeHm8YLaHvdof70Ko5QVjlKKviteYo6qidVCjqy1GtXonPtUErtwijRqMiKKotzcwKvPM1srHYnuuMNpZBmeldkeDggH)SEeKFakha(ZMXbG)m)rrHsiTIY8CHKeYG0zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14suSt7mDWaI4HMsZuMGfzvQziIiRofuFM3yiwgui6mmc)z9ii)auoa8NnJda)zDgrKvNcQlKKON0zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB14s600othmGiEOP0mLjyrwLAMViiZarxauAao)zEJHyzqHOZWi8N1JG8dq5aWF2moa8NPyebzgikKkdLgGZxijjH0zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB140ZBANPdgqep0uAMLPSMAMIesc12wh(QyFNYW(CPQ47QWbniSJAZmLjyrwLAgFef7IADvGHRtN5ngILbfIodJWFwpcYpaLda)zZ4aWFwNJOyHe1kK(hdxNotZJhe(40ZlH8eEZ08asLMFyAxntx(p7PhL(WhxJywpcIda)zRgN(KPDMoyar8qtPzktWISk1SwkkuUHIY88zEJHyzqHOZWi8N1JG8dq5aWF2moa8N5pkkucPvuMNlKK41iDMMhpi8XPNxc5j8MP5bKkn)W0UAMU8F2tpk9HpUgXSEeeha(Zwno96N2z6GbeXdnLMzzkRPMviF(I3jJqriKc4WmLjyrwLA2HBqkCQlvfFxfoObHN5ngILbfIodJWFwpcYpaLda)zZ4aWFMoWnifovi1OIVq6Fh0GWZ084bHpo98sipH3mnpGuP5hM2vZ0L)ZE6rPp8X1iM1JG4aWF2QXP3lN2z6GbeXdnLMzzkRPMviF(I3jJqriKc4Gq2vijrivKqsO226Wxf77ug2NlvfFxfoObHDuBessNPmblYQuZ4RI9Dkd7ZLQIVRch0GWZ8gdXYGcrNHr4pRhb5hGYbG)SzCa4pRZvX(oLH9jKAuXxi9VdAq4zAE8GWhNEEjKNWBMMhqQ08dt7Qz6Y)zp9O0h(4AeZ6rqCa4pB1QzwMYAQzR2a]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170717.172459, [[dauwuaqiOuwKsO2euYOeIoLqYUOIHbfhtPAzkLEgekttjixtjKTbHQ(gjX4eevNJKIADkbMhjfUNGW(Gs1bHGfss6HkrtuquUOqQncHCsbYmvcQBcr7KedvqKLkOEkLPkGRcHkTvHWEv9xinychw0IHQhlLjlvxg1MPsFwjnAe1Pr61kfZMQUnc7g0VLmCe54qOILd8CsnDfxxO2Ua13fKopjvRNKImFskTFI(7pWnLKGVzuILsbIaLEwGu0z3m2p3czSBg7NR6nJe3OPNQMYHwWRSDr73cZEo18v2IzxfmQSRIdgmB3URMVfMZU6bOe8nqmK2qjvHYah3071OtHUvLBi0gAb1pWv2FGBrdtCp3VQ3SgGsAUn16QNDOWHbGysJ(gc4upDu)gbf2rDbmRM4Bbb70wof4gSG8nKvpIeOKe8TBkjbFdjf2LcebywnX3cZEo18v2IzxLDm3cZ6kg0y9d852sYCBdYkyMGHZXVHS6kjbF7Zv2(a3IgM4EUFvVznaL0CdedPnusvOmWPZU0gDKcSlfBXifyjfytkM0ZWXbhW5qgTCr1uyhKRLoDyyI75(neWPE6O(Te0siJofaWW5wqWoTLtbUbliFdz1JibkjbF7MssW3qa0silfbkaGHZTWSNtnFLTy2vzhZTWSUIbnw)aFUTKm32GScMjy4C8BiRUssW3(Cfe7bUfnmX9C)QEZAakP52KEgoo4aohYOLlQMc7GCT0PddtCp3LcSKIEno4aohYOLlQMc7GCT0PZqBBOWvPalPaedPnusvOmWPfdamCKc1qkqmmsbwsbigYsHAifBVHao1th1VLGwcz0Paago3cc2PTCkWnyb5BiREejqjj4B3usc(gcGwczPiqbamCKIi3J6wy2ZPMVYwm7QSJ5wywxXGgRFGp3wsMBBqwbZemCo(nKvxjj4BFUYc9a3IgM4EUFvVznaL0CBQ1vp70QY3RqHAPalPisPap211He17taA5I6ck94etskI6gc4upDu)gUVQoQBmq9Bbb70wof4gSG8nKvpIeOKe8TBkjbFtvFvDParXa1VfM9CQ5RSfZUk7yUfM1vmOX6h4ZTLK52gKvWmbdNJFdz1vsc(2NRSOh4w0We3Z9R6nRbOKMBtTU6zNwv(Efkulfyjfrkf4XUUoKOEFcqlxuxqPhNyssru3qaN6PJ63WzGMbBOW1Bbb70wof4gSG8nKvpIeOKe8TBkjbFtvgOzWgkC9wy2ZPMVYwm7QSJ5wywxXGgRFGp3wsMBBqwbZemCo(nKvxjj4BFUcI)bUfnmX9C)QEdbCQNoQFlwZO0Hj03cc2PTCkWnyb5BiREejqjj4B3usc(gIRMLIGgMqFlm75uZxzlMDv2XClmRRyqJ1pWNBljZTniRGzcgoh)gYQRKe8TpxrLh4w0We3Z9R6nRbOKMBGyiRDgkbJof6IKc1qkqmPalPisPaBsrVghCaNdz0YfvtHDqUw60zOTnu4QuOw1kfGyiTHsQcLboTyaGHJuGDPaXJrkI6gc4upDu)whKXRKh0YfvxXE9TGGDAlNcCdwq(gYQhrcusc(2nLKGVfYaz8k5rkkxPWQyV(gcGv9nysWHOdY4vYdA5IQRyV(wy2ZPMVYwm7QSJ5wywxXGgRFGp3wsMBBqwbZemCo(nKvxjj4BFUsi)bUfnmX9C)QEZAakP52uRRE2Hun0cQLcSKIiLc8yxxhsuVpbOLlQlO0JtmjPalPisPaBsXKEgoo4aohYOLlQMc7GCT0PddtCp3Lc1QwPaBsrRkFVcf6Gd4CiJwUOAkSdY1sNoaMiPqTuGDPaJueLue1neWPE6O(ns1ql4TGGDAlNcCdwq(gYQhrcusc(2nLKGVfs1ql4TWSNtnFLTy2vzhZTWSUIbnw)aFUTKm32GScMjy4C8BiRUssW3(Cf18dClAyI75(v9M1ausZnSjft6z44Gd4CiJwUOAkSdY1sNommX9C)gc4upDu)gjQ3Na0Yf1fu65wqWoTLtbUbliFdz1JibkjbF7MssW3cjQ3NaPOCLcebk9Clm75uZxzlMDv2XClmRRyqJ1pWNBljZTniRGzcgoh)gYQRKe8TpxzhZdClAyI75(v9M1ausZTj9mCCWbCoKrlxunf2b5APthgM4EUlfyjfTQ89kuOdoGZHmA5IQPWoixlD6ayIKc1sb2LIfcZneWPE6O(nsuVpbOLlQlO0ZTGGDAlNcCdwq(gYQhrcusc(2nLKGVfsuVpbsr5kficu6rkICpQBHzpNA(kBXSRYoMBHzDfdAS(b(CBjzUTbzfmtWW543qwDLKGV95k77pWTOHjUN7x1Bwdqjn3M0ZWXbhW5qgTCr1uyhKRLoDyyI75UuGLuGnPOvLVxHcDWbCoKrlxunf2b5APthatKuOwkWUuGrkWskaXqAdLufkdCAXaadhPa7HqkwegPalPGrCIPKiXDNwbdMbRmSXOLlQBoSwkWskAv57vOqhYXWvgqHROGyiJgkNKkOdGjskulfQHuSJ5gc4upDu)gjQ3Na0Yf1fu65wqWoTLtbUbliFdz1JibkjbF7MssW3cjQ3NaPOCLcebk9ifrUnQBHzpNA(kBXSRYoMBHzDfdAS(b(CBjzUTbzfmtWW543qwDLKGV95k7BFGBrdtCp3VQ3SgGsAUnPNHJdoGZHmA5IQPWoixlD6WWe3ZDPalPaBsrRkFVcf6Gd4CiJwUOAkSdY1sNoaMiPqTuGDPaJuGLuaIH0gkPkug40Ibagosb2dHuSimsbwsb2KcgXjMsIe3DAfmygSYWgJwUOU5WAPalPisPOvLVxHcDihdxzafUIcIHmAOCsQGoaMiPqTuOgsX(IKc1QwPysWkpodLGrNcTtzPa7sXoITiPiQBiGt90r9BKOEFcqlxuxqPNBbb70wof4gSG8nKvpIeOKe8TBkjbFlKOEFcKIYvkqeO0JuejIf1TWSNtnFLTy2vzhZTWSUIbnw)aFUTKm32GScMjy4C8BiRUssW3(CLDe7bUfnmX9C)QEZAakP52uRRE2PvLVxHc1sbwsrKsbESRRdjQ3Na0Yf1fu6XjMKue1neWPE6O(nCaNdz0YfvtHDqUw68wqWoTLtbUbliFdz1JibkjbF7MssW3ufW5qwkkxPWOWoixlDElm75uZxzlMDv2XClmRRyqJ1pWNBljZTniRGzcgoh)gYQRKe8TpxzFHEGBrdtCp3VQ3SgGsAUHh7660kFhLmNGXrpzBJuecPylgPqTQvkIukWJDDDir9(eGwUOUGspoaMiPqTuOgsXARlfyjf4XUUoKOEFcqlxuxqPhNyssbwsrKsbESRRtR8DuYCcgh9KTnsb2dHuSVlfQvTsrKsbESRRtR8DuYCcgh9KTnsb2dHuSJrkWsk08GIxWyTZqzWwmOlePMuGDPaJueLueLue1neWPE6O(Tg5Kc1OLlkTX3cc2PTCkWnyb5BiREejqjj4B3usc(2sYjfQLIYvkcQX3cZEo18v2IzxLDm3cZ6kg0y9d852sYCBdYkyMGHZXVHS6kjbF7Zv2x0dClAyI75(v9M1ausZnSjft6z44Gd4CiJwUOAkSdY1sNommX9CxkWskWMuePumPNHJZAoKzafUIQNcq4WWe3ZDPalPap211bWefqZEwRrdLchg4etskI6gc4upDu)wl9E0Sn0cI6P65wqWoTLtbUbliFdz1JibkjbF7MssW3wMEVuGqBOfukwyQEUHayvFdMeCiwSrjwkficu6zbsXkdzaTT4BHzpNA(kBXSRYoMBHzDfdAS(b(CBjzUTbzfmtWW543qwDLKGVzuILsbIaLEwGuSYqgqBFUYoI)bUfnmX9C)QEZAakP52KEgoo4aohYOLlQMc7GCT0PddtCp3LcSKcSjf9ACWbCoKrlxunf2b5APtNH22qHR3qaN6PJ63AP3JMTHwqupvp3cc2PTCkWnyb5BiREejqjj4B3usc(2Y07LceAdTGsXct1Jue5Eu3qaSQVbtcoel2OelLcebk9SaPaV0l(wy2ZPMVYwm7QSJ5wywxXGgRFGp3wsMBBqwbZemCo(nKvxjj4BgLyPuGiqPNfif4L(Zv2v5bUfnmX9C)QEZAakP52KEgoo4aohYOLlQMc7GCT0PddtCp3LcSKIEno4aohYOLlQMc7GCT0PZqBBOW1BiGt90r9BT07rZ2qliQNQNBbb70wof4gSG8nKvpIeOKe8TBkjbFBz69sbcTHwqPyHP6rkICBu3qaSQVbtcoel2OelLcebk9SaPaV0sXqBBOW1fFlm75uZxzlMDv2XClmRRyqJ1pWNBljZTniRGzcgoh)gYQRKe8nJsSukqeO0ZcKc8slfdTTHcx)CL9q(dClAyI75(v9M1ausZTj9mCCwZHmdOWvu9uachgM4EUlfyjf4XUUoaMOaA2ZAnAOu4WaNyssbwsb2KIj9mCCWbCoKrlxunf2b5APthgM4EUFdbCQNoQFRLEpA2gAbr9u9CliyN2YPa3GfKVHS6rKaLKGVDtjj4BltVxkqOn0ckflmvpsrKiwu3qaSQVbtcoel2OelLcebk9SaPyvlfdTTHcxx8TWSNtnFLTy2vzhZTWSUIbnw)aFUTKm32GScMjy4C8BiRUssW3mkXsParGsplqkw1sXqBBOW1pFUznaL0C7Zp]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170717.172459, [[b4vmErLxtnfCLnwAHXwA6fgDP9MBE5Km1eJxt5uyTvMxtnvATnKFGzKCVnhD64hyWjxzJ9wBIfgDEnLuLXwzHnxzE5KmWeZnWCtm34cmWiJmXKJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnLx05fDEnfrLzwy1XgDEjKx05Lx]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170717.172459, [[deubnaqiuPAtKQ6tkvrgfvkNIkv7sGHHehtqlJk6zujPPPuv6AOsPTPuf13uQmoLQW5uQQSoQe08uQs3Jkb2hvsCqKulevYdjfMOsvrxKu0gPsQpQuvyKujYjjL6MIQDcQFsLOwkQ4Petfv1wjL8vuPyVs)vPmykoSQwmIESsMmixgAZIYNrvgnPYPj51uHztv3gHDd8BfdxKoUsvvlhLNl00v56i12rs(Ui68IW6PsO5tQY(P0nS8Ra)eyfrrOH14A2epxO1WlAnNA5qb4vrsXL69kx8p1akStUnSY(eZEA)vUQWb94hXc7Ks4ok7c3fqHItNH7xfo4dLGVIaRqsNLfOJgWdzkaVngna3sIF6acyiXRaXkuVo1aILFHdl)kAcEspcvUQilMk9QqsNLfOwj2U3pGyadjEfiAn71Acd4wRrFR5EpcUa1kX29(bedqWt6rOkutQ8QlrLm2eVT4XuoWkAdGuR)gwfWaWk5dKwpd(jWkvGFcSIRzt8Sg5ykhyfoOh)iwyNuc3fsPchmo0Sfgl)Ev0qhUCKpuHei4kzL8bc(jWk9kSZYVIMGN0JqLRkutQ8QlrfgsmSi6XyClPcCiRI2ai16VHvbmaSs(aP1ZGFcSsf4NaRWbjgwe9ymAnCJcCiRch0JFelStkH7cPuHdghA2cJLFVkAOdxoYhQqceCLSs(ab)eyLEf2vl)kAcEspcvUQilMk9QqsNLfWueyaDQ1OV1WDRXnRHKollyi9Qdz)PgqaDQ1OV18RtrfUHaKqHrRzVwJtRX9kutQ8QlrfDtsVcWBJ0)XRI2ai16VHvbmaSs(aP1ZGFcSsf4NaR4stsVcWZA4Y)XRch0JFelStkH7cPuHdghA2cJLFVkAOdxoYhQqceCLSs(ab)eyLEfEFl)kAcEspcvUQilMk9QCdpEEmynJhAscIwJ(wJBwJBwd3TM79i4cYyJlIGTuAFedqWt6riRrp9Sg3SggnaTM9AnoTg9TggnqT2sNKilyrZyi4SM9Ano3dRXDRXDRX9kutQ8QlrLH0RoK9NAav0gaPw)nSkGbGvYhiTEg8tGvQa)eyfxM0RoK9NAav4GE8JyHDsjCxiLkCW4qZwyS87vrdD4Yr(qfsGGRKvYhi4NaR0RWCB5xrtWt6rOYvfzXuPxfgnaTgxXACvRrp9Sgs6SSahkVxb4Tr8lDkagqNAn6PN1qsNLfmKE1HS)udiGoTc1KkV6suzi9Qdz)Hv0gaPw)nSkGbGvYhiTEg8tGvQa)eyfxM0RoK9hwHd6XpIf2jLWDHuQWbJdnBHXYVxfn0Hlh5dvibcUswjFGGFcSsVcVNl)kAcEspcvUQilMk9QCdpEEmynJhAscIwJ(wJBwJBwdU)0Q0uekynG4WU42A8qBRHHwJE6znK0zzbPkV)zBt2wgBIxaDQ14U1OV1qsNLfqd0n(eBXJHaENUa6uRrFRbcjPZYcyVlom1cdI3VCynUaRHBTg9TgUBnK0zzbdPxDi7p1acOtTg3RqnPYRUevIkae75nXpULrZsurBaKA93WQagawjFG06zWpbwPc8tGvefaI98M4VNIwJRPzjQWb94hXc7Ks4Uqkv4GXHMTWy53RIg6WLJ8HkKabxjRKpqWpbwPxH3v(v0e8KEeQCvrwmv6vHKollWHY7vaEBe)sNcGb0PwJ(wJBwd3TgC)PvPPiuGJXFk2h3ayYSHgaTLu59wJE6zn37rWfW7pDitb4TfVHreGGN0JqwJE6zn)6uuHBiajuy0ACfxG140ACVc1KkV6sujJnXlUsC6WkAdGuR)gwfWaWk5dKwpd(jWkvGFcSIRzt8IReNoSch0JFelStkH7cPuHdghA2cJLFVkAOdxoYhQqceCLSs(ab)eyLEfEpk)kAcEspcvUQilMk9QWObQ1w6KezblAgdbN14kwZEqXA0tpRXnRHKollyi9Qdz)PgqaDQ1OV1WDRHKollWHY7vaEBe)sNcGb0PwJ7vOMu5vxIkzSjEBXJPCGv0gaPw)nSkGbGvYhiTEg8tGvQa)eyfxZM4znYXuoqRXTq3RWb94hXc7Ks4Uqkv4GXHMTWy53RIg6WLJ8HkKabxjRKpqWpbwPxH3VYVIMGN0JqLRkutQ8QlrLH0RoK9hwrBaKA93WQagawjFG06zWpbwPc8tGvCzsV6q2FO14wO7v4GE8JyHDsjCxiLkCW4qZwyS87vrdD4Yr(qfsGGRKvYhi4NaR0RWHuk)kAcEspcvUQilMk9QWObQ1w6KezblAgdbN1SxRzhfRrFRH7wdjDwwGoAapKPa82y0aClj(PdiGoTc1KkV6sur3WaBt2wsf4qwfTbqQ1FdRcyayL8bsRNb)eyLkWpbwXLggWAMmRHBuGdzv4GE8JyHDsjCxiLkCW4qZwyS87vrdD4Yr(qfsGGRKvYhi4NaR0RWHHLFfnbpPhHkxvOMu5vxIk88)s9(ThIQhSWkAdGuR)gwfWaWk5dKwpd(jWkvGFcSY(W)l17TgQHO6blSch0JFelStkH7cPuHdghA2cJLFVkAOdxoYhQqceCLSs(ab)eyLEfo0z5xrtWt6rOYvfQjvE1LOsgBI3w8ykhyfTbqQ1FdRcyayL8bsRNb)eyLkWpbwX1SjEwJCmLd0ACZP7v4GE8JyHDsjCxiLkCW4qZwyS87vrdD4Yr(qfsGGRKvYhi4NaR0RWHUA5xrtWt6rOYvfzXuPxLB4XZJbRz8qtsq0A03ACZA4U1qsNLfOJgWdzkaVngna3sIF6acOtTg3RqnPYRUev0rd4HmfG3gJgGBjXpDav0gaPw)nSkGbGvYhiTEg8tGvQa)eyfxIgWdzkapRHdnaTgUb)0buHd6XpIf2jLWDHuQWbJdnBHXYVxfn0Hlh5dvibcUswjFGGFcSsVchUVLFfnbpPhHkxvKftLEvUHhppgSMXdnjbXkutQ8QlrfKiDsISngna3sIF6aQOnasT(ByvadaRKpqA9m4NaRub(jWkAsKojrM1WHgGwd3GF6aQWb94hXc7Ks4Uqkv4GXHMTWy53RIg6WLJ8HkKabxjRKpqWpbwPxVkYIPsVk9Ab]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170717.172459, [[deKvsaqicsBcQQprLuQrbv6uqvwfuOSlQyyiXXKOLjHEgbrtJkjxJGW2Osk(guX4OsQ05ee16OsQyEqbDpOq2hvfhKQulKkXdPkzIujLCrQQSrOaJekuDsQQ6MqPDsOFki0sPs9uktLQyRuv6Rcc2RQ)sQgmQomKfJupwstwQUmyZiPptknAsXPj61cQzl0TLYUr8BfdNahxqKLR0Zjz6IUUaBNG67sW5HIwpvsvZxqA)O8lVNBIOgCZKnVyCmyhv66W40J6MjaQsuu66rPCixSOquEZ1cOIcI5D5MBicifCXIukXHcoL44qHsXILH8n3aQJPhzdUTbezvxWuawhQOyuPNJoouU5DnLdrDpxS8EU5hbrhH(D5MvxPG8wIIajDKvm1tuCikhGGOJqNXXNXPdOs1rwXuprXHOCwOHKefJJHmU2ANXXNXRZe7tbId9cOuJ(qvxjj9fPDuiNfAijrX4(W4BabuoPSb65O7QBEtlJYeZBu3rL6QCLHHB(t6YkkN9gziWnSt3x0kIAWTBIOgCdd2rLmULRmmCZnebKcUyrkL4us5MBqnbBfu3ZZBEPbQHXocdnGKN(g2PlIAWTNxS49CZpcIoc97YnRUsb5Tefbs6OfLAGvs0QRYzBoabrhH(nVPLrzI5TfAZQGiOu6fKKe2B(t6YkkN9gziWnSt3x0kIAWTBIOgCZn0MvbrqPy8qqssyV5gIasbxSiLsCkPCZnOMGTcQ755nV0a1WyhHHgqYtFd70frn42ZlkK3Zn)ii6i0Vl3S6kfK3OdOs1zLnWjqaJJpJVbeq5KYgONJURyCmKXXLX1w7mogJXlY44DZBAzuMyEtZuikjA1PJivEZFsxwr5S3idbUHD6(IwrudUDte1GBy8Pqus0Y4UerQ8MBicifCXIukXPKYn3GAc2kOUNN38sdudJDegAajp9nStxe1GBpVORUNB(rq0rOFxUz1vkiVTbeq5KYgONJURHXXqgxBTZ44Z4cLXtueiPJwuQbwjrRUkNT5aeeDe638MwgLjM3g6OmHfLWn)jDzfLZEJme4g2P7lAfrn42nrudUfI0rzclkHBUHiGuWflsPeNsk3CdQjyRG6EEEZlnqnm2ryObK803WoDrudU98IcX9CZpcIoc97YnRUsb5TnGakNu2a9C0DfJJHmU2ANXXNXXLXRZe7tbId9cOuJ(qvxjj9fPDuiNfAijrX4(W4uy8qdLX3aISQlykaRtnyxGKmogY44qHXX7M30YOmX82qhLjSOeU5pPlROC2BKHa3WoDFrRiQb3UjIAWTqKoktyrjW44wI3n3qeqk4IfPuItjLBUb1eSvqDppV5LgOgg7im0asE6ByNUiQb3EErxZ9CZpcIoc97YnRUsb5TnGiR6cMcW6ud2fijJ7dgX4HSqW44Z4ki1PhsGYjLWwgY6UsqLX9HXPW44Z41zI9PaXHEbuQrFOQRKK(I0okKZcnKKOyCFyCk38MwgLjM3OUJk1v5kdd38N0Lvuo7nYqGByNUVOve1GB3ern4ggSJkzClxzyGXXTeVBUHiGuWflsPeNsk3CdQjyRG6EEEZlnqnm2ryObK803WoDrudU98I4Cp38JGOJq)UCZQRuqEJoGkvNv2aNabmo(moesbsbcGUJayvGWWIivqFOQNAaDGEi6n0MyU38MwgLjM3wOnRcIGsPxqssyV5pPlROC2BKHa3WoDFrRiQb3UjIAWn3qBwfebLIXdbjjHLXXTeVBUHiGuWflsPeNsk3CdQjyRG6EEEZlnqnm2ryObK803WoDrudU98IUU3Zn)ii6i0Vl3S6kfK3OdOs1zLnWjqaJJpJJlJ3N0zH2SkickLEbjjH1jL1WsIwgp0qz86mX(uG4SqBwfebLsVGKKW6Sqdjjkg3hgxBTZ4HgkJJlJlughcPaPabq3raSkqyyrKkOpu1tnGoqpe9gAtmxghFgxOmEIIajD0IsnWkjA1v5SnhGGOJqNXXJXX7M30YOmX8MMPqus0QthrQ8M)KUSIYzVrgcCd709fTIOgC7MiQb3W4tHOKOLXDjIujJJBjE3CdraPGlwKsjoLuU5gutWwb1988MxAGAySJWqdi5PVHD6IOgC75fd575MFeeDe63LBwDLcYBcLXPdOs1zLnWjqaJJpJlughxgprrGKoArPgyLeT6QC2Mdqq0rOZ44Z4cLXXLXRZe7tbIZcTzvqeuk9csscRZcnKKOyCFyCCzCT1oJJXy8ImoEmEOHY4BabyCFyCxX44X44X44Z4BabyCFyCH8M30YOmX82qhLjSOeU5pPlROC2BKHa3WoDFrRiQb3UjIAWTqKoktyrjW44weVBUHiGuWflsPeNsk3CdQjyRG6EEEZlnqnm2ryObK803WoDrudU98ILuUNB(rq0rOFxUz1vkiVLJwTrWPotSpfikghFghxghxghcPaPabq3Poe1SPsVoXUEDwGXdnugNoGkvhbYyeT6dvDQ7OsNabmoEmo(moDavQobentetDvUarBQXjqaJJpJ3b6aQuDwKRFwzfCujQgMXXigxiyC8zCHY40buP6m0rzclkLdXjqaJJ3nVPLrzI5nLK0xK2rHu6udwmV5pPlROC2BKHa3WoDFrRiQb3UjIAWnts6ls7OqU2kghdcwmV5gIasbxSiLsCkPCZnOMGTcQ755nV0a1WyhHHgqYtFd70frn42ZlwwEp38JGOJq)UCZQRuqEJoGkvNWYyus0Q3qvnsc4eiGXXNXXLXfkJdHuGuGaO7eEIPCrkDcuG6eq66fKXiJhAOmoQMsHbDGanjOyCFWigViJJ3nVPLrzI5nQ7OsvfZudCZFsxwr5S3idbUHD6(IwrudUDte1GByWoQuvXm1a3CdraPGlwKsjoLuU5gutWwb1988MxAGAySJWqdi5PVHD6IOgC75fllEp38JGOJq)UCZQRuqEBdiYQUGPaSo1GDbsY4(GrmoouU5nTmktmVrDhvQRYvggU5pPlROC2BKHa3WoDFrRiQb3UjIAWnmyhvY4wUYWaJJBr8U5gIasbxSiLsCkPCZnOMGTcQ755nV0a1WyhHHgqYtFd70frn42ZlwkK3Zn)ii6i0Vl3S6kfK3q1ukmOdeOjbfJ7dgX4fV5nTmktmVTqBwfebLsVGKKWEZFsxwr5S3idbUHD6(IwrudUDte1GBUH2SkickfJhcssclJJBr8U5gIasbxSiLsCkPCZnOMGTcQ755nV0a1WyhHHgqYtFd70frn42Zlw6Q75MFeeDe63LBwDLcYB4Y41zI9PaXzH2SkickLEbjjH1zHgssumogY44Y4ARDghJX4fzC8y8qdLXPdOs1rlk1aRKOvxLZ2CujQgMXXigVKcJJhJJpJxNj2Nceh6fqPg9HQUss6ls7Oqol0qsIIX9HX3acOCszd0Zr3vmo(mEIIajD0IsnWkjA1v5SnhGGOJq)M30YOmX8g1DuPUkxzy4M)KUSIYzVrgcCd709fTIOgC7MiQb3WGDujJB5kddmoUcjE3CdraPGlwKsjoLuU5gutWwb1988MxAGAySJWqdi5PVHD6IOgC75flfI75MFeeDe63LBwDLcYBcLXPdOs1zLnWjqaJJpJJlJlugprrGKoArPgyLeT6QC2Mdqq0rOZ4HgkJxNj2NceNfAZQGiOu6fKKewNfAijrX4(W44Y4ARDghpghVBEtlJYeZBdDuMWIs4M)KUSIYzVrgcCd709fTIOgC7MiQb3cr6OmHfLaJJRqI3n3qeqk4IfPuItjLBUb1eSvqDppV5LgOgg7im0asE6ByNUiQb3EEXsxZ9CZpcIoc97YnRUsb5T6mX(uG4qVak1Opu1vssFrAhfYzHgssumUpmEPqW44Z4Barw1fmfG1PgSlqsghdXighhkmo(m(gqaLtkBGEo6cjJ7dJRT2V5nTmktmVPzwI(qvVGKKWEZFsxwr5S3idbUHD6(IwrudUDte1GBy8zjm(qLXdbjjH9MBicifCXIukXPKYn3GAc2kOUNN38sdudJDegAajp9nStxe1GBpVyjo3Zn)ii6i0Vl3S6kfK3QZe7tbId9cOuJ(qvxjj9fPDuiNfAijrX4(W4BabuoPSb65O7QBEtlJYeZBu3rL6QCLHHB(t6YkkN9gziWnSt3x0kIAWTBIOgCdd2rLmULRmmW446k8U5gIasbxSiLsCkPCZnOMGTcQ755nV0a1WyhHHgqYtFd70frn42ZN3S6kfK3E(d]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170717.172459, [[dmemtaqivqUefs2evvFIcPyuqrNckmlkeDlke2frggeDmO0YOkEMkLMMkqUgvP2gfsPVHOACQa05qukRdrPY8quCpvQAFuLCqvkwOkKhQsLjIOu1fvHAJQa1iruYjHqUjfStk1pvbWsjjpvyQuv2keQVQcQ9I6VqAWkDyclMIESKMmcxgSzvYNPKrJiNMuVMKQztu3gQ2TOFRQHtIJRcOLl1ZLy6iDDQSDkuFxfDEiy9uivZNKY(vmJL9XrOavTqwB0fu9NSThVXYruBTcLdoi7HlHtMYhXHkqgefGT9Gel5ijhl5sir6XdwYghQabbc(04ahyoB7sDfv5pHwQ66gs6SZAeZ6b5SymRrnlwVnYznDxxsKCPf060cTDjGEccLpLAaxOZch3uP6plSp2gl7JJJtHPmqWhXruBTcLdmNTDPUIQ8NqlvDDdjDwVUF2BroRAQnRP76sIKlTGwNwOTlb0tqO8PKtzwmM1)SyolMZA6UUKAnoi5uM1)SWb60kkaHKc0fWyOfzfq)lukjafm)efx0ue6zXyw1uBwmNLkKHKkzjOKGwNwOf634sqkmLbIz9plMZs8uPgW)UaYqPGEQtk0snGl0zzwYC)SwvIzvtTzp0SepvQb8VlGmukON6KcTevxvxNwZIXSymlgCCJPwwtrGJgW)UaYqPGEQtk0CGOKqxf0V5i)e4WWtGyrBlWbo4WwGdCOcW)UaYqPm7H1jfAoubYGOaSThKyjhlsoubL31vOW(ykh3rcQQB4ngWHKYMCy4jSf4ahmLT9W(444uykde8rCe1wRq5aZzXC22L6kQYFcTu11nK0z96(z9GCw)ZwakQ5NUIevdnwYg6bPuN1RzrolgZQMAZ2Uuxrv(tOLQUUHKoRx3p7TiNvn1M10DDjrYLwqRtl02La6jiu(uYPmlgZ6Fwt31LuRXbjNch3yQL1ue4G0FkRtlutzrHYbIscDvq)MJ8tGddpbIfTTah4GdBboWbz9NY60A2JKffkhQazqua22dsSKJfjhQGY76kuyFmLJ7ibv1n8gd4qsztom8e2cCGdMY23Y(444uykde8rCe1wRq5OauuZpDfjQgApir9OuN1RzroR)zBxQROk)j0svx3qsN1RzpGEpR)zBxcZsM7N92z9pRP76ssrlllA0)c9Q)cvYPWXnMAznfboU6Vqrl0wRoWbIscDvq)MJ8tGddpbIfTTah4GdBboWXb3FHoBqBT6ahQazqua22dsSKJfjhQGY76kuyFmLJ7ibv1n8gd4qsztom8e2cCGdMY2he7JJJtHPmqWhXruBTcLJ2L6kQYFcTu11nK0zjZ9ZEqEpRAQnB7sOir14ak9r9EwYmRvLyw1uBwt31LejxAbToTqBxcONGq5tPgWf6SmRx3pRhoUXulRPiWXBkRPqlOahikj0vb9BoYpbom8eiw02cCGdoSf4ahhatznfAbf4qfidIcW2EqILCSi5qfuExxHc7JPCChjOQUH3yahskBYHHNWwGdCWu22B2hhhNctzGGpIJO2Afkh03YsgKQ)lt8Nzzw)ZI5STl1vuL)eAPQRBiPZsMzjh5S(N9qZA6UUKi5slO1PfA7sa9eekFk5uM1)STlHzjZSEM1)S1)Lj(ZuYSbbLe6FHw0jrlS(IqQbCHolZ61S369S(NfoqNwrbiKQFAm0wqwb0)c9sqHYSyWXnMAznfboi5slO1PfA7sa9eekFYbIscDvq)MJ8tGddpbIfTTah4GJtsqQceeiWrP2Afkh2cCGdYYLwqRtRzv5sy2ddcLp54osqvDdVXaoKu2KdvGmikaB7bjwYXIKdvGGabFACGdmNTDPUIQ8NqlvDDdjDwJywYrolgZAuZI1BJCwt31LejxAbToTqBxcONGq5tPgWf6SWHkO8UUcf2ht5WWtylWboykBB0Y(444uykde8rCe1wRq5G(wwYGu9FzI)mlZ6FwmNTDPUIQ8NqlvDDdjDwYmR3iN1)ShAwt31LejxAbToTqBxcONGq5tjNYS(NTDjuKOACaL(OEM1R7N92z9pB9FzI)mLmBqqjH(xOfDs0cRViKAaxOZYSEn7TiNfdoUXulRPiWbjxAbToTqBxcONGq5toqusORc63CKFcCy4jqSOTf4ahCCscsvGGabok1wRq5WwGdCqwU0cADAnRkxcZEyqO85SyIfdoUJeuv3WBmGdjLn5qfidIcW2EqILCSi5qfiiqWNgh4aZzBxQROk)j0svx3qsN1iM1BKZIXSg1Sy92iN10DDjrYLwqRtl02La6jiu(uQbCHolCOckVRRqH9Xuom8e2cCGdMY2KZ(444uykde8rCe1wRq5G(wwYGu9FzI)mlZ6FwmNTDPUIQ8NqlvDDdjDwYm7TEpR)zp0SMURljsU0cADAH2UeqpbHYNsoLz9pB7sOir14ak9r9mRx3pRNz9pB9FzI)mLmBqqjH(xOfDs0cRViKAaxOZYSEn7TiNfdoUXulRPiWbjxAbToTqBxcONGq5toqusORc63CKFcCy4jqSOTf4ahCCscsvGGabok1wRq5WwGdCqwU0cADAnRkxcZEyqO85Sy6bdoUJeuv3WBmGdjLn5qfidIcW2EqILCSi5qfiiqWNgh4aZzBxQROk)j0svx3qsN1iM9wVNfJznQzX6TroRP76sIKlTGwNwOTlb0tqO8Pud4cDw4qfuExxHc7JPCy4jSf4ahmLTpGSpooofMYabFehrT1kuoOVLLmiv)xM4pZYS(NfZzBxQROk)j0svx3qsNLmZ6b5S(N9qZA6UUKi5slO1PfA7sa9eekFk5uM1)STlHIevJdO0h1ZSED)SyN1)S1)Lj(ZuYSbbLe6FHw0jrlS(IqQbCHolZ61S3ICwm44gtTSMIahKCPf060cTDjGEccLp5arjHUkOFZr(jWHHNaXI2wGdCWXjjivbcce4OuBTcLdBboWbz5slO1P1SQCjm7HbHYNZI5TyWXDKGQ6gEJbCiPSjhQazqua22dsSKJfjhQabbc(04ahyoB7sDfv5pHwQ66gs6SZAeZ6b5SymRrnlwVnYznDxxsKCPf060cTDjGEccLpLAaxOZchQGY76kuyFmLddpHTah4GPSnzJ9XXXPWugi4J4iQTwHYb9TSKbP6)Ye)zwM1)SyolMZchOtROaes1plFtlO1xMaT(nmRAQnRP76ssrlllA0)c9Q)cvYPmlgZ6Fwt31LKlj9YiGwOnKwussoLz9plby6UUKAHr)BDfKkurv9zVFwVN1)ShAwt31L0BkRPqlO6pLCkZIbh3yQL1ue4OOtIwy9frb9Y1iWbIscDvq)MJ8tGddpbIfTTah4GdBboWrOtIwy9fHrtz2d21iWHkqgefGT9Gel5yrYHkO8UUcf2ht54osqvDdVXaoKu2KddpHTah4GPSnwKSpooofMYabFehrT1kuomDxxsQRLL1PfkUOssNGKtzw)ZI5ShAw4aDAffGqs9xMQBrbnHZR3LeONAz5zvtTzPcziPswckjO1PfAH(nUeKctzGyw1uBwrLQngqHeW1qzwVUFwpZIbh3yQL1ue44Q)cTurGsc4arjHUkOFZr(jWHHNaXI2wGdCWHTah44G7VqlveOKaoubYGOaSThKyjhlsoubL31vOW(ykh3rcQQB4ngWHKYMCy4jSf4ahmLTXIL9XXXPWugi4J4iQTwHYHOs1gdOqc4AOmRx3pRhoUXulRPiWrd4FxazOuqp1jfAoqusORc63CKFcCy4jqSOTf4ahCylWboub4FxazOuM9W6Kc9SyIfdoubYGOaSThKyjhlsoubL31vOW(ykh3rcQQB4ngWHKYMCy4jSf4ahmLTX6H9XXXPWugi4J4iQTwHYr7sDfv5pHwQ66gs6SK5(zj37zvtTzBxcZ61S3YXnMAznfboEtznfAbf4arjHUkOFZr(jWHHNaXI2wGdCWHTah44aykRPqlOWSyIfdoubYGOaSThKyjhlsoubL31vOW(ykh3rcQQB4ngWHKYMCy4jSf4ahmLTXEl7JJJtHPmqWhXruBTcLJ2L6kQYFcTu11nK0zjZSKJCw)ZEOznDxxsKCPf060cTDjGEccLpLCkZ6F22LqrIQXbu6JE7SEnRvLGJBm1YAkcCq67e9Vqp1jfAoqusORc63CKFcCy4jqSOTf4ahCylWboiRVZz)RzpSoPqZHkqgefGT9Gel5yrYHkO8UUcf2ht54osqvDdVXaoKu2KddpHTah4GPSn2dI9XXXPWugi4J4iQTwHYb9TSKbP6)Ye)zwM1)SyoB7sDfv5pHwQ66gs6SKzwpiNfdoUXulRPiWbGR8NqJ2UeqpbHYNCGOKqxf0V5i)e4WWtGyrBlWbo4WwGdCCmUYFc9SQCjm7HbHYNCOcKbrbyBpiXsowKCOckVRRqH9XuoUJeuv3WBmGdjLn5WWtylWboykt5WwGdCeA87M9G7Vqj7M18lZs1v11Pftzga]] )

    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170717.172459, [[dydCdaGEKeTjc0Ui0Rrs1(qeZgPMpb1nrs62u0ojQ9cTBvTFPAueqdJi)wPblLHdWbjiNcjLJrPohIeleelfrTyQYYL8usltu9CQmrePAQuOjdQPlCrkjxg11ryJusTvQkTzK40Q8yGMfb4ZuIVtbhwX5ffJgKwhvfNKQQVbORHiP7jk9xrEgschcrkJ2Oruvam4n0hvoXTpkNtQ2OQG1biqfv5XKr1VV9M116IEdYQ(0BWmLHGoqLmtZJJr5CjBGsaTbkkjLNBtkOsMh4mgptg1I4pWeG1axIXzYPytaLeqVvep7eJZKtXMYrviW423HgrzB0iQw9JhndJqqviVJ(ImO6v8eqtlLK7E4ASSUbv5XKrfsXtaT3wk9MEpCnww3GQ)h(aNylu)9zujZ084yuoxYgOTeQK5boJXZKrTi(dmbynWLyCMCk2eqjb0BfXZoX4m5uSPCunaLFY8aNbvhyDacuvW6aeOwe)bMaSg4seKOk(JEJKS9gqPEtWERiEU3ijBVLJbkNJgr1QF8OzyecQYJjJkzIV3Gu8eqrvbRdqGk8gIEfpb00sj5UhUglRBeJdK63BryHfi4U0WRHx0R4jGMwkj39W1yzDJyXMZ9USscwe)bMaSg4seKOk(dsYcusqbwepts2CHf2JGcfXIn3YX0SZLmCFWLibablINjjRn1OgQKzAECmkNlzd0wcv)p8boXwO(7ZOkK3rFrgulIpnGXTFI(CbQuDHLhtgv)(2BwxRl6niR6tV5v8eqXaLPc0iQw9JhndJqqvEmzujt89M82BqkEcOOQG1biqL0G3q0R4jGMwkj39W1yzDJyCGu)ElOsMP5XXOCUKnqBju9)Wh4eBH6VpJQqEh9fzqTi(0ag3(j6ZfOs1fwEmzu97BVzDTUO3GSQp92V9MxXtafdmqL0zkdbDGqWara]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170717.172459, [[dyZMeaGEkPQnPcSlvY2OKW(uPYSP42QQ2je7vA3uTFvXpPKkdJO(nudLssnyvLHtOdQcDms6Cus0cjslvvAXKQLlCAfpf1YavphstKsknvIyYKY0v6IQuESOEgjY1bzJQGSvvqTzr6WaNNs8vqHPrjjZdu0ivPQ)sWOfrFtfDsryDusX1irDpqPVtP(mjCzKRALuMfP8amJ1d2b7fbUYQL5CmIB5YiGFQCId)8DOaJUpFsXS188Pheytw(LmeaLkcCz1t5t1Zlzz4WvTYYVeqZIK5Nkhq(KfeX2uCLcmguHflOKC5J5DWoALue1kP8nhOBiTkTmNJrClx(LmeaLkcCz1tv5YjCTjdwCu2Xov(O(yM1s5G(Xbkziuub7XxkkJa(PYV0poqjdHI(8bJXxk6we4vs5Boq3qAvAzohJ4wU8lziakve4YQNQYLt4AtgS4OSJDQ8r9XmRLYIJXacbCQqAGr3YiGFQSvpgdiE(WPpFhkWOB3IOuLu(Md0nKwLwgb8tLLgeyt(8HtF(4X1cGcmkO8lziakve4YQNQYLt4AtgS4OSJDQmNJrClhqoDhSQheq(KfeX2uCLHIG89oypL7weRQskFZb6gsRslZ5ye3Y6qPPxX8txqIhOdLMELeYvqX4keciNeSjGi2V0W2(bbKpzbrSnfxzOiiFVdwLuU8lziakve4YQNQYLt4AtgS4OSJDQ8r9XmRLYjX2MXviOBaOBzeWpv(ESTzCfpFsna0TBruUskFZb6gsRslZ5ye3YbKpzbrSnfxzOiiFHjSNkx(LmeaLkcCz1tv5YjCTjdwCu2Xov(O(yM1szSUzwkalvgb8tLToDZSuawQBrSIkP8nhOBiTkTmNJrClhq(KfeX2uCLHIG8fMWEQ8b6qPPxjHCfumUcHaYjbBciI9lnSTx(LmeaLkcCz1tv5YjCTjdwCu2Xov(O(yM1s5K4WfWPc2JVuugb8tLVhh(Zho95dgJVu0TiNvs5Boq3qAvA5xYqauQiWLvpvLlZ5ye3YbKpzbrSnfxzOiiFHjSkjxoHRnzWIJYo2PYh1hZSwkNeYvqX4keciNeSjGi2l)sanlsMFQCa5twqeBtXvkWyqfwSGsYLTts(lb0SugnhJ4wgb8tLVhYvqX4kE(EHC65dgeqe7D7w2APuaKzR0UTa]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170717.172459, [[dGddeaGEsQQDHuTnrsTpPQA2O62IQ1bkLDQs7LA3k2VuAuIeggk(nWHv13urdwkgoO6GIOtjs0Xa5CKuXcrOLIswmswUsNxK6PqltfEoPMijvzQKKjtIPlCrrXPLCzIRJuSrPkTvsk1MrW2jPOhJOVksY0iPsFhLAKsv5qKuy0GI)kvoPi8zrPRjvX9aL8msk51iL(jOuTHSkJ3pxmMqTBB6Db6OTHiaHT2Mb02qTYhWyu9ecpn8WenYs4YRfFpyGozoHoPZWCCaPogrYTGhgnMKmkWOTkFHSkJzMNIlkMOrKCl4HrJSeU8AX3dgOtigJjgLI8dWACaJymjvXRiTXvYbRw4Iw3XUMqwJ3pxmYsYbRw4Iw32KQAczD47HvzmZ8uCrXenIKBbpmQgkGGoHfOJocIAkl9OiPTMSgzjC51IVhmqNqmgtmkf5hG14agXysQIxrAJWayZRjBhf)1HX7Nlg7dWMxt22gI8xho8vTSkJzMNIlkMOrKCl4HXLMPi7GdyllDsA2vMOFyDYyKLWLxl(EWaDcXymXOuKFawJdyeJjPkEfPnsyb6OthBrRy8(5IXExGoABWylAfh(QUwLXmZtXfft0isUf8WifneiqFRCHonWnYs4YRfFpyGoHymMyukYpaRXbmIXKufVI0gHbWMxt2ok(RdJ3pxm2hGnVMSTne5VoABsbRkxsPdF7XQmMzEkUOyIgrYTGhgnYs4YRfFpyGoHymMyukYpaRXbmIXKufVI0gbu8kK9dX49ZfJWofVcz)qC4BQTkJzMNIlkMOrKCl4HrsaGRayp0Pw5dy6ae601OSFwG(PVs(xJUFyb1JrwcxET47bd0jeJXeJsr(bynoGrmMKQ4vK2iHfOJoDSfTIX7Nlg7Db6OTbJTOvABsbukD47PvzmZ8uCrXenIKBbpmscaCfa7Ho1kFathGqNUgL9Zc0p9vY)A09dligJSeU8AX3dgOtigJjgLI8dWACaJymjvXRiTrya70bi0XUMqwJ3pxm2hyN2gaH2MuvtiRdhgr4cz98s9)OaJVh9a5Wg]] )
    

    storeDefault( [[Frost Primary]], 'displays', 20170624.232908, [[d0d4gaGEvKxcvLDrPO2MkkzMsQ8yumBfDCur3eQQMMKQUTk8nkv1oPQ9k2nr7Ne(PcnmvY4urfNMudfPgmQ0Wr4GsYZjCmQ4CQOQfkrlLsPftslNIhsL6PGLrLSokfzIQOyQqzYKOPR0fvWvPu4YqUos2Ok1wvrL2mQA7iQpkP4zOc9zOY3LWirfCyPgnknEOkNerUfLQCnkvopL8BvTwvuQxlP0XjybyAIv)Y7xUWAnrbgTbwDK8dbyAIv)Y7xUG(ekEhxbmTehYnlIP2ugqDQpDQM5xKYawJ88c06Ujw9lfXFfaVrEEbAD3eR(LI4VcWjfIcPKeZlb9ju81Ff4qlRgINJb4KcrHu6Ujw9lfPmG1ipVaTyTbhAfXFfqW(fqHEzyRgszab7xurTFkdOzEjq0mAjU4TlW2gCOTsYW(MaLJyyJ43ws1WbSaw52ENZ5TVRlh7Q35825IJx2)k82RE7cynYZlql(kfXBpNac2VaRn4qRiLbQvTsYW(MayJ02sQgoGfqlvQz69nvsg23eWws1WbSamnXQFzLKH9nbkhXWgXFaGaXO7P(uV6xgVl7Cciy)calLb4KcrHoJ2Gyw9ldylPA4awaj1bjMxkIV(acc0CEpBbR7F(MGfOJ3jGjENa4I3jGA8ozdiy)c3nXQFPiQbWBKNxG2kkth)vGMY0yweOaQu88boA8QO2p(RaQt9Pt1m)IQ5mQb6jbBdSFbn5H4Dc0tc229FO2ln5H4DcCgeFtn3ugONfTLGMmDkdqwl0Q6PETWSiqbudW0eR(Lvtnoza3dESbBdOuliMTfMfbkqhW0sCimlcuGwvp1RvGMY04xlrPmqTQ3VCb9ju8oUc0tc2gRn4qlnz64DcyqZaUh8yd2gqqGMZ7zlyJAGEsW2yTbhAPjpeVtaoPquiLKKk1m9(grkd4(jSuWf7dCBEXQGB14qGdTSIA)4VcSTbhAVF5cR1efy0gy1rYpeqjIVPMBfDDba9HBfCVnVyTjfCvI4BQ5gaV4Vciy)cOqVmSvu7NYa9KGTRMfTLGMmD8ob0mV8S))iEh7cqy0hTX6(LlOpHI3XvacdI5pu7TIUUaG(WTcU3MxS2KcUegeZFO2Ba(xUbOXuWfAPqbxFBmFrGJgVQH4Vcqy0hTXIeZlb9ju81FfyBdo0stEiQb4KcrHQMACYdKCdWeqW(f0KPtza8g55fOLKuPMP33iI)kG1ipVaTKKk1m9(gr8xb22GdT3VCdqJPGl0sHcU(2y(Ia4nYZlqlwBWHwr8xbeSFrfLPjj5)OgqW(fKKk1m9(grkdynYZlqBfLPJ)kqplAlbn5HugqW(f0Khszab7xunKYam)HAV0KPJAGMY0abAojDM4Vc0uMUsYW(MaLJyyJ4VUHBSanLPjj5FmlcuavkE(ahAjGf)vGTn4q79lxqFcfVJRaCsPzQ9C1cyTMOaDaMMy1V8(LBaAmfCHwkuW13gZxeONeST7)qTxAY0X7eyq2QtKYugqOpiMOQXH4DfOw17xUbOXuWfAPqbxFBmFrGEsW2vZI2sqtEiENam)HAV0KhIAGTn4qlnz6OgqW(f4dzPQLk1sCIugWw0e1cu8UUCS)1z5QEB2fhDSZfhdC04byX7eaVrEEbAXxPiENa9KGTb2VGMmD8ob4KcrHuE)Yf0NqX74kqTQ3VCH1AIcmAdS6i5hcWjfIcPeFLIugW3hOa3MxSk4sB0hTXkqtzABi1BaIzBHmzta]] )

    storeDefault( [[Frost AOE]], 'displays', 20170624.232908, [[dSJYgaGEPuVejXUuufVwkPzkLy2kCteupgPUTQyBkQu7Ks7vSBI2pb(Pu1WuL(TktdbzOOYGjOHdvhKk9Csogv1XrvSqfzPOkTyuA5u8qPWtbltrzDkQQjkfPPQQMmQQPR0fLkxfjLld56iAJqPTQOs2mH2os8rPOonP(mu8DQYirs6zkQy0Oy8iWjrOBjfHRHKQZtfhwYALIOVPOkD8ZpaDHV6tI9KlSoduGEQ9BHOTlaDHV6tI9KlOBJI1FwatjXGAWGOBntb4HerIChAmYhKCdqhWPxuuH2gf(QpPk23ae0lkQqBJcF1Nuf7BaCJ(PmoePpjOBJILqVbE0s3UyNtaEirKi(nk8vFsvMc40lkQq7VmyqRk23akMZd80lnJBxydOyopxY9cBafZ5bE6LMXLCVmfyldg06kPzotGP()VNW8sSzQ(d4eBtmZ)nabX(gqXCE)YGbTQmfOvwxjnZzc8754LyZu9hql5RPR9mUsAMZeGxInt1Fa6cF1N0vsZCMat9)FpHda4iADn0TRvFYyNrD)akMZd(zkapKisut1ge9QpzaEj2mv)bKKpePpPkwcfqHJgdSJsX04gNj)avS(byJ1paMy9dyI1pBafZ51OWx9jvHnab9IIk06sAQyFduKM67GJcWskkg4PiWLCVyFdWo0TB3848ChJWgOg4mfWCECu6I1pqnWzQg3dBTCu6I1pqtrIf5yZuGA4vokokCzkafTsZQh6157GJcWgGUWx9jDhAmYan6S)oEdWxRWhLZ3bhfGoGPKyqFhCuGIvp0RtGI0uewlrzkqRSyp5c62Oy9NfOg4m1VmyqlhfUy9dyqJan6S)oEdOWrJb2rPycBGAGZu)YGbTCu6I1papKiseFIs(A6ApJktbAC4oce(VaynNAfi0TVlGTEqbWAo1kqOBFxGTmyql2tUW6mqb6P2VfI2Ua8rIf5yD5AjaOFAiqiwZP25lqiFKyro2aTYI9KlSoduGEQ9BHOTlGM(KaErRLyIL6bQbot5o8khfhfUy9dudCMcyopokCX6ha3OFkJd2tUGUnkw)zbWni67HTwxUwca6NgceI1CQD(ceIBq03dBTbiOxuuHwQmPI1pWtrGBxSVbEkcGFS(b2YGbTCu6cBaErduPqXo71FEFN7zeAEMnhFQpBobumNhhfUmfqXCEub5WQL81smQmfyldg0YrHlSbOVh2A5O0f2a1aNPChELJIJsxS(bALf7j3aCFbcHsQei0wgZ5fqXCEeL8101EgvMc40lkQqRlPPI9nqn8khfhLUmfqXCEUDHnGI584O0LPa03dBTCu4cBGAGZunUh2A5OWfRFGI0uUsAMZeyQ))7jClDy)b4Hut36CPvW6mqbyd8OLWp23aBzWGwSNCbDBuS(ZcuKMIOu8(o4OaSKIIbOl8vFsSNCdW9fiekPsGqBzmNxGI0uaoAmi20yFd0jl2bIFMcO0p4dKBFxSZcOyopxstrukEHnab9IIk0(ldg0QI9nWwgmOf7j3aCFbcHsQei0wgZ5fWPxuuHwIs(A6ApJk23ae0lkQqlrjFnDTNrf7Ba2HUD7MhNxMcWdjIeXNi9jbDBuSe6nG4j3aCFbcHsQei0wgZ5fqtFYM8UNy9PEaEirKi(yp5c62Oy9NfWPxuuHwQmPITj8dWdjIeXNktQmf4rlDj3l23afPPOMuVbWhLdYKnba]] )

    storeDefault( [[Unholy Primary]], 'displays', 20170624.232908, [[d0d5gaGEfXlrKAxer12qKWmLQYJrPzRWXjc3KiY0KQ0TvIVjvHDsv7vSBc7Ni9tL0WukJdrIonPgkkgmr1Wr4GsLNtXXOuNJiklukTusKftslNkpKs6PGLrjwhIKMOIuMkuMmjmDvUOI6QivDzixhjBKOSvfPQnJQ2oI6Jsv1ZqQ0NvQ(UumsKkoSKrdvJhrCsKYTKQORrI68OYVv1AvKkVwrYXoybylIt)czV4GJBGcSspwF08ZbylIt)czV4a9eu82wc4kXoYkoIDQ0gqDONmP)X3e1aCR88g0zTio9lmXVfGKvEEd6SweN(fM43cibfIcPGg7la9eu89Ufyrl6MJNUbKGcrHuyTio9lmPna3kpVbDyLBhDM43cyW)gOrFS4DZPnGb)B6OUpTb0SVaikwTypELdCLBhDDcw83fODfdBvskrRF6GfGlY6jPuY6HLnBL71wYu2cD36Xw47zVkhGBLN3Gos3AIVN2bm4Fdw52rNjTbMsTtWI)UayRmkrRF6GfqluOzR7DDcw83fqjA9thSaSfXPFrNGf)DbAxXWwLuaGaXQRHEsD6xeVfLTeWG)nawAdibfIcnnTdXE6xeqjA9thSacQfASVWeFVbmeOXq2Om4w)X7cwGkE7aU4TdShVDa14TZfWG)nwlIt)ctudqYkpVbDDuUk(TafLRW4iqbuP45dSuK0rDF8Bbuh6jt6F8nDJrududc8cW)ggYZXBhOge4L1FrTogYZXBhyAi(IACPnqnAkoddzM0gGS2Ov1d9XHXrGcOgGTio9l6g6DraRZESzLcOqBigfhghbkqfWvIDeghbkqPQh6Jlqr5kjPfO0gykvzV4a9eu82wcudc8cRC7OJHmt82bCOraRZESzLcyiqJHSrzWJAGAqGxyLBhDmKNJ3oGeuikKcAcfA26ENjTbS(eCsLJ9bOxG)doPY7wNdSOfDu3h)wGRC7Ot2lo44gOaR0J1hn)Cafi(IACDm9fa0lwLkNEb(p4ivPYvG4lQXfGK43cyW)gOrFS4Du3N2a1GaV6gnfNHHmt82b0SVy6(FjEBLdq40lLJt2loqpbfVTLaeoe7VOwxhtFba9IvPYPxG)dosvQCchI9xuRla)lUamysLdLWivUVCUVjWsrs3C8BbiC6LYXrJ9fGEck(E3cCLBhDmKNJAajOquOUHExSGexa2akHgOYGI3YMDp2ifw6vYTqxBLTq3aKSYZBqhnHcnBDVZe)waUvEEd6OjuOzR7DM43cCLBhDYEXfGbtQCOegPY9LZ9nbizLN3GoSYTJot8Bbm4FthLROj4)OgWG)n0ek0S19otAdWTYZBqxhLRIFlqnAkodd550gWG)nmKNtBad(30nN2aS)IADmKzIAGIYvabAmOnT43cuuUQtWI)UaTRyyRsQVzzybkkxrtW)yCeOaQu88bw0cal(Tax52rNSxCGEckEBlbKGsZo10RnWXnqbQaSfXPFHSxCbyWKkhkHrQCF5CFtGAqGxw)f16yiZeVDGzrPoqksBaJEHyG6wNJ3sGPuL9IladMu5qjmsL7lN7Bcudc8QB0uCggYZXBhG9xuRJH8CudCLBhDmKzIAad(3qAeNQwOql2nPnGb)ByiZK2alfjaw82bizLN3Gos3AI3oqniWla)ByiZeVDajOquifYEXb6jO4TTeykvzV4GJBGcSspwF08ZbKGcrHuq6wtAd4Rfua6f4)GtQCgNEPCCbkkxrVqFbigfhYLlb]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170624.232908, [[dSJZgaGEfYlHQQDPqv9AjuZuHYSL0nrj8yK62QITbvf2jL2Ry3OA)KIFQidtv63knnuIgkHgmrA4iCqQ45uCmj64OuTqf1sjvSyuSCQ6HKQEkyzsW6GQstKuPMQQAYeX0v5Ik4QOuUmKRJKnskTvsL0MjQTJO(OeYPj5ZqLVtLgjkjptHkJgkJhQYjrKBrQexdLuNNGdl1AvOkFdQk6uMFa6M4ulx7Yp4eQOatS9hJKDiaDtCQLRD5hOgHITSqaFZXH0JHOloZbyNcrHCQkC8he)cqhqysw2Go9nXPwUj23a4njlBqN(M4ul3e7BacV6P9cKOxoOgHILLVbEuCNHyhxa2Pquij6BItTCtMdimjlBq3V94qNj23agS1fCvhnMZqycyWwxhQBdtad26cUQJgZH62mh4Apo05WPXwFG5P)FIf6qQiw9dieRUuO8naEX(gWGTU)2JdDMmhOyghon26d8Ne1HurS6hqXLOO7B9oCAS1hqhsfXQFa6M4ul3HtJT(aZt))elcaeiAvxvJ6tT8ylW6cbmyRl8ZCa2PquiDR8i6tT8a6qQiw9dWPEirVCtSSmGHavRARTbt)wxF(b6yldWeBzaCXwgWhBzUagS1vFtCQLBcta8MKLnOZHY3X(gOP89xGafGHswoWtJNd1TX(gGPQgnQO666uRHjqxjWAaBDfjpeBzGUsG163hM(ejpeBzaDJKBQ6L5aD1TfmIKfZCaYkJIrvvNWxGafGjaDtCQL7uv44b0py)d6eqIYquBHVabkaDaFZXH(ceOanJQQoHanLVzHIJYCGIz0U8duJqXwwiqxjW6F7XHorYIXwgWJQb0py)d6eWqGQvT12GfMaDLaR)Thh6ejpeBza2PquijK4su09TEtMdOFje0i9VbyJJTvbnsDMgcy7hua24yBvqJuNPHax7XHoTl)GtOIcmX2Fms2HasqYnv9CehlaOE0RrkBCSTkGVAKkbj3u1lqXmAx(bNqffyIT)yKSdbu0lhiAAfhxSSoqxjWANQBlyejlgBzGUsG1a26kswm2YaeE1t7f0U8duJqXwwiaHhrVpm95iowaq9OxJu24yBvaF1iLWJO3hM(cG3KSSbD4F2eBzGNgpNHyFd804b)yldCThh6ejpeMagS1vKSyMdOdQIAdk2cVL4Zx8rbwo(fgxjRlmUagS1f)ibgfxIIJZK5ax7XHorYIHja9(W0Ni5HWeOReyTt1TfmIKhITmqXmAx(fq8Rrk0CJgP227x3agS1LexIIUV1BYCaHjzzd6CO8DSVb6QBlyejpK5agS11zimbmyRRi5HmhGEFy6tKSyyc0vcSw)(W0NizXyld0u(2HtJT(aZt))elgBq7pa7uk6I1vLboHkkatGhfh(X(g4Apo0PD5hOgHITSqGMY3K4Y7xGafGHswoaDtCQLRD5xaXVgPqZnAKABVFDd0u(giq1kjDh7BGbEZursYCaJ6HOICMgITqad266q5BsC5nmbWBsw2GUF7XHotSVbU2JdDAx(fq8Rrk0CJgP227x3actYYg0rIlrr336nX(gaVjzzd6iXLOO7B9MyFdWuvJgvuDDdta2PquijKOxoOgHILLVbKx(fq8Rrk0CJgP227x3ak6LpE7(eBjRdWofIcjr7YpqncfBzHactYYg0H)ztS6sza2Pquij4F2K5apkUd1TX(gOP8nBC1fGO2ciFUe]] )



end

