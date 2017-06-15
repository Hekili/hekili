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


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEATHKNIGHT') then

    ns.initializeClassModule = function ()

        -- Hekili.UseNewEngine = true

        setClass( "DEATHKNIGHT" )
        -- setSpecialization( "unholy" )

        -- Resources
        addResource( "runic_power", nil, true )
        addResource( "runes", nil, true )


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
                    local v = r.actual

                    if v == 6 then return -1 end

                    return r.expiry[ v + 1 ] - time
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
                    if k == 'actual' or k == 'current' then
                        local amount = 0

                        for i = 1, 6 do
                            amount = amount + ( t.expiry[i] <= state.query_time and 1 or 0 )
                        end

                        return amount

                    elseif k == 'time_to_next' then
                        return t[ 'time_to_' .. t.current + 1 ]

                    elseif k == 'time_to_max' then
                        return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

                    elseif k:sub( 1, 8 ) == 'time_to_' then
                        local amount = tonumber( k:sub(9) )

                        if not amount or amount > 6 then return 3600 end

                        return t.current >= amount and 0 or max( 0, t.expiry[ amount ] - state.query_time )

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
                    state.setCooldown( 'army_of_the_dead', cooldown.army_of_the_dead.remains - ( 6 * amount ) )
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
        if PTR then addAura( "chilled_heart", 235592, "duration", 3600, "max_stack", 20 ) end
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
        addGearSet( "consorts_cold_core", 144293 )
        addGearSet( "death_march", 144280 )
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
        addGearSet( "the_instructors_fourth_lesson", 132448 )
        addGearSet( "toravons_whiteout_bindings", 132458 )
        addGearSet( "uvanimor_the_unbeautiful", 137037 )
        
        if PTR then
            addGearSet( "cold_heart", 151796 ) -- chilled_heart stacks NYI
            -- addGearSet( "death_screamers", 151797 )
            addGearSet( "soul_of_the_deathlord", 151740 )
            addGearSet( "soulflayers_corruption", 151795 )
        end


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
            if PTR and equipped.cold_heart then removeBuff( "chilled_heart" ) end
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
            summonPet( "valkyr_battlemaiden", PTR and 20 or 15 )
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
            spend = PTR and 45 or 35,
            min_cost = PTR and 45 or 35,
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
            if talent.shadow_infusion.enabled and buff.dark_transformation.down then setCooldown( 'dark_transformation', cooldown.dark_transformation.remains - ( PTR and 7 or 5 ) ) end
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
                    gain( PTR and 6 or 8, "runic_power" )
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
            talent = "hungering_rune_weapon",
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


    storeDefault( [[SimC Unholy: generic]], 'actionLists', 20170531.211500, [[deeZqaqiHKweLkTjKuJsvOtPkyxc1WuLoMaltiEgssttveUMQOSnvr13avnokvOZrPcwhjQMhsI7rPQ9jKQdsPSqIkpKKAIcPCrKInsPI8rHe5KKiZuiHBkHDQQ(jLkQLIu6POMkrXvjrzRevTxL)krdgehMQftKhlQjtQldTzK4ZKWObPtJ41ivZMIBlPDd8BPgUGoUQiTCcpxKPRY1PKTtu67GkJxveDEsY6fsu7huEbtMX0aCjdQN04OHuClZn5gZzbj8gpMw0GEc3pYBa8Vp7f(4irEFFF2yoeZe3qIY(rAW(rEwKX2YhPbPjZ(btMX0aCjdQNCJ5SGeEJVwHcdgN72OB4ajQFmQ4tTiHHOo(C6huuqob5jtLjOTLrJIqxNOwybi5YWgoueRrkKm5OcvFFySnjIHCQgRDb9sxiroumwnumtVOLfRi4M04IwlVl(Efhp(7vCC0CbDyqSjKihkgtlAqpH7h5na(G3Xkb0KSFTymOb44Iw)9koE3(rMmJPb4sgup5gZzbj8gFTcfgmo3Tr3Wbsu)i(ulsyiQJpN(bffKtqEYuzcABz0Oi01jQfwasUmSHdfXAKcjtoQq1xQZDB0nCGyTlOxEchKO0IQFKgelWQtajQe5HX2KigYPAS2f0lDHe5qXy1qXm9IwwSIGBsJlAT8U47vC84VxXXrZf0HbXMqICOagKhdEymTOb9eUFK3a4dEhReqtY(1IXGgGJlA93R44D7t1jZyAaUKb1tUXCwqcVXxRqHbJZDB0nCGe1pkSaivSNQpm2MeXqovJtw1Adkv4cfTkdownumtVOLfRi4M04IwlVl(Efhp(7vCmBvRnagKOKlu0Qm4yArd6jC)iVbWh8owjGMK9RfJbnahx06VxXX72)jMmJPb4sgup5gZzbj8gFTcfgmo3Tr3Wbsu)i(ulsyiQJpN(bffKtqEYuzcABz0Oi01jQZDB0nCGyTlOxEchKO0IQFKgelWQtajQe8sTWcGuXEQ(WyBsed5unozvRnOuHlu0Qm4y1qXm9IwwSIGBsJlAT8U47vC84VxXXSvT2ayqIsUqrRYGWG8yWdJPfnONW9J8gaFW7yLaAs2Vwmg0aCCrR)EfhVB)NnzgtdWLmOEYnMZcs4nwJswuOetbthkiafLW1waDC68m9OB)ZPo3Tr3WbI9Wo7gvHjmwGvNasu5jgBtIyiNQXP2YukqpefJvdfZ0lAzXkcUjnUO1Y7IVxXXJ)EfhZTLbgeArpefJPfnONW9J8gaFW7yLaAs2Vwmg0aCCrR)EfhVB)NpzgtdWLmOEYnMZcs4nwJswuOetbthkiafLW1waDC68m9OB)ZhBtIyiNQXEyNDJQWeownumtVOLfRi4M04IwlVl(Efhp(7vCSTWo7gvHjCmTOb9eUFK3a4dEhReqtY(1IXGgGJlA93R44D7d)KzmnaxYG6j3yoliH3yHfGKldB4qrSgPqYKJkbVJTjrmKt1yn6h0YCtmJvdfZ0lAzXkcUjnUO1Y7IVxXXJ)Efhhn0pOWGOUjMX0Ig0t4(rEdGp4DSsanj7xlgdAaoUO1FVIJ3TVDCYmMgGlzq9KBmNfKWBCup3GGlw7c6LUqICOigbUKb1ulzrHsCYsRrqPU7ASvi1rvYIcLyaMfDIKITcPwybqQypvhBtIyiNQXA0pOL5MygRgkMPx0YIveCtACrRL3fFVIJh)9kooAOFqHbrDtmWG8yWdJPfnONW9J8gaFW7yLaAs2Vwmg0aCCrR)EfhVBF7WKzmnaxYG6j3yoliH34Zni4I1UGEPlKihkIrGlzqn1swuOeNS0AeuQ7UgBfsDUBJUHdeRDb9sxirouelWQtaPO)mQfwaKk2t1X2KigYPASg9dAzUjMXQHIz6fTSyfb3Kgx0A5DX3R44XFVIJJg6huyqu3edmipg5HX0Ig0t4(rEdGp4DSsanj7xlgdAaoUO1FVIJ3TFW7KzmnaxYG6j3yoliH3ynkzrHsmfmDOGauucxBb0XPZZ0PYZPo3Tr3WbI9Wo7gvHjmwGvNasuX(Np2MeXqovJPGPdfeGIY0ji0XXQHIz6fTSyfb3Kgx0A5DX3R44XFVIJTty6qbbOage(ee64yArd6jC)iVbWh8owjGMK9RfJbnahx06VxXX72piyYmMgGlzq9KBmNfKWBSgLSOqjMcMouqakkHRTa6405z6r3EQo2MeXqovJtTLPuGEikgRgkMPx0YIveCtACrRL3fFVIJh)9koMBldmi0IEikGb5XGhgtlAqpH7h5na(G3Xkb0KSFTymOb44Iw)9koE3(brMmJPb4sgup5gZzbj8gRrjlkuItTLPuGEikITcPoQAuYIcLyky6qbbOOeU2cOJTchBtIyiNQXuW0Hccqrz6ee64y1qXm9IwwSIGBsJlAT8U47vC84VxXX2jmDOGauadcFccDegKhdEymTOb9eUFK3a4dEhReqtY(1IXGgGJlA93R44D7hq1jZyAaUKb1tUXCwqcVXAuYIcL4uBzkfOhIIyRqQ1OKffkXuW0HccqrjCTfqhNoptp62hm2MeXqovJt52sOaltNGqhhRgkMPx0YIveCtACrRL3fFVIJh)9koMZTLqbcdcFccDCmTOb9eUFK3a4dEhReqtY(1IXGgGJlA93R44D7h8etMX0aCjdQNCJ5SGeEJ1OKffkXP2YukqpefXwHuRrjlkuIPGPdfeGIs4AlGooDEME0TpySnjIHCQgNnoCeGIYeux3WLgRgkMPx0YIveCtACrRL3fFVIJh)9kowTXHJauadcd11nCPX0Ig0t4(rEdGp4DSsanj7xlgdAaoUO1FVIJ3TFWZMmJPb4sgup5gx0A5DX3R44XFVIJJgsHyWXQHIz6fTSyfb3KgtlAqpH7h5na(G3Xkb0KSFTymOb4yBsed5unwJuigCCrR)EfhVB)GNpzgtdWLmOEYnMZcs4n2ZhrwSebyLGPOBFKX2KigYPAC2nMspFKguAiPBSsanj7xlgdAaoUO1Y7IVxXXJ)EfhR2ngyqSLpsdGbjkiPBSnHI0yGxr7TltQQHbrzaOTrLYHbXMDMg7oMw0GEc3pYBa8bVJvdfZ0lAzXkcUjnUO1FVIJzsvnmikdaTnQuomi2SZ0SB)a4NmJPb4sgup5gZzbj8gJp1IegI64dkwsaPtyLVwKkP0wIdAPbtPgm2MeXqovJZUXu65J0GsdjDJvcOjz)AXyqdWXfTwEx89koE83R4y1UXadIT8rAamirbjDWG8yWdJTjuKgd8kAVDzsvnmikdaTnQuomieq6ew5Rfj7oMw0GEc3pYBa8bVJvdfZ0lAzXkcUjnUO1FVIJzsvnmikdaTnQuomieq6ew5RfPD7hyhNmJPb4sgup5gZzbj8gh1Zni4IZE6ik8RfXiWLmOM6OIp1IegI64dkwsaPtyLVwKkP0wIdAPbtPgm2MeXqovJZUXu65J0GsdjDJvcOjz)AXyqdWXfTwEx89koE83R4y1UXadIT8rAamirbjDWG8yKhgBtOing4v0E7YKQAyqugaABuPCyqsNd0UqB3X0Ig0t4(rEdGp4DSAOyMErllwrWnPXfT(7vCmtQQHbrzaOTrLYHbjDoq7c9U9dSdtMX0aCjdQNCJ5SGeEJp3GGlo7PJOWVweJaxYGAQJk(ulsyiQJpOyjbKoHv(ArQKsBjoOLgmLAWyBsed5uno7gtPNpsdknK0nwjGMK9RfJbnahx0A5DX3R44XFVIJv7gdmi2YhPbWGefK0bdYJu9HX2eksJbEfT3UmPQggeLbG2gvkhgKSNoIc)AHDhtlAqpH7h5na(G3XQHIz6fTSyfb3Kgx06VxXXmPQggeLbG2gvkhgKSNoIc)AXUDJ)EfhZKQAyqugaABuPCyquGauqY72aa]] )

    storeDefault( [[SimC Unholy: default]], 'actionLists', 20170531.211500, [[dmeeqaqiOuSibH2ePOrraofbYTee0UuWWGIJPqltq9mbjtdOkUgqLTbuvFduzCqPY5aQswhuQAEcICpOuAFcsDqazHGQEiGAIeqxKGSrcu1jjbZuqGBku7eKFsGknucuXsHsEkQPsQCvcu2kj0xbQsTxv)fGbtsomLftOhdvtMOlJSzsvFMKA0a50qETaZMk3MQ2Tu)w0WfYXjOSCLEUIMUKRdkBhO8DsHXtq15jLwVGO2pj6pEDNfQnrhjV4zbs6nyU6WFMXxuuD(mwKJSjDOWygHdd4Wa3q4WyWGbCN5ichzouiBfk7dfgCHpdeEHYEEDhA86oluBIosE4pZ4lkQoxPA1oAa1fTlSOAEgirKdvAp7rTeG(LOqModmicpiobJ8uxx8CCkv0wiZtNpdzE6CmQLkvj4xIcz6mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVou4R7SqTj6i5H)mJVOO6CLQv7Ob8mDYuJEQPawynchquQbTdsspchvHomgbDgirKdvApBlU1eGk3L66mWGi8G4emYtDDXZXPurBHmpD(mK5PZaT4wtkvPl3L66mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVouOUUZc1MOJKh(Zm(IIQZvQwTJgWZ0jtn65zGerouP9SOltja9WwTNbgeHheNGrEQRlEooLkAlK5PZNHmpDgExMsLQe8WwTNXICKnPdfgZiCJyoRqlr4wL75oB6CCkHmpD(1Hapx3zHAt0rYd)zgFrr15kvR2rd4z6KPg98mqIihQ0EwK2jTbOw9zGbr4bXjyKN66INJtPI2czE68ziZtNHN2jTbOw9zSihzt6qHXmc3iMZk0seUv5EUZMohNsiZtNFDiWDDNfQnrhjp8Nz8ffvNRuTAhneLfk7PMcqeME9dWAqPtlGzTuRUanalsqNbse5qL2ZrzHY(mWGi8G4emYtDDXZXPurBHmpD(mK5PZcozHY(mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVoe4FDNfQnrhjp8Nz8ffvNXgzwdGHwyoQlarotnmAOq4bOw9zGerouP9CcRexYcoRqlr4wL75oB6CCkv0wiZtNpdzE6SGlSsCjl4mqR655Yw1ubaPhBXgzwdGHwyoQlarotnmAOq4bOw9zSihzt6qHXmc3iMZadIWdItWip11fphNsiZtNFDi4UUZc1MOJKh(Zm(IIQZKWGHIIi5qzbfiAr1Ie(eWeucZjPnYKtnXZ0jtn6bPTbaSvev0oSK3q9m0JGp4odKiYHkTNL2gaOwRN6Z1Bfk7ZadIWdItWip11fphNsfTfY805ZqMNolqBduQs3A9uFUERqzFglYr2KouymJWnI5ScTeHBvUN7SPZXPeY805xhc7UUZc1MOJKh(Zm(IIQZKWGHIIi5qzbfiAr1Ie(eWeucZjPnYKtnXMYCuxdtqMm1aaQ1dBIYEGAt0rsnXZ0jtn6bPTbaSvev0oSK3q9m0GdCNbse5qL2ZsBdauR1t956TcL9zGbr4bXjyKN66INJtPI2czE68ziZtNfOTbkvPBTEQpxVvOSvQsaJc6mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVoe411DwO2eDK8WFMXxuuDMegmuuejhklOarlQwKWNaMGsyojTrMCQzzoQRHjitMAaa16HnrzpqTj6iPM4z6KPg9G02aa2kIkAhwYBOEg6qbUZajICOs7zPTbaQ16P(C9wHY(mWGi8G4emYtDDXZXPurBHmpD(mK5PZc02aLQ0Twp1NR3ku2kvjGWc6mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVo0iMR7SqTj6i5H)mJVOO6mjmyOOisouwqbIwuTiHpbmbLWCsAJm5uZYw1unuipbOsasefs4z6KPg9G02aa2kIkAhwYBOEgcXUZajICOs7zPTbaQ16P(C9wHY(mWGi8G4emYtDDXZXPurBHmpD(mK5PZc02aLQ0Twp1NR3ku2kvjGqjOZyroYM0HcJzeUrmNvOLiCRY9CNnDooLqMNo)6qJJx3zHAt0rYd)zgFrr1zsyWqrrKCOSGceTOArcFcyckH5K0gzYPM4z6KPg9WeM3Nna12Qo16OHL8gQNHEe8XCgirKdvAplTnaqTwp1NR3ku2NbgeHheNGrEQRlEooLkAlK5PZNHmpDwG2gOuLU16P(C9wHYwPkbaEe0zSihzt6qHXmc3iMZk0seUv5EUZMohNsiZtNFDOXWx3zHAt0rYd)zgFrr1zsyWqrrKCOSGceTOArcFcyckH5K0gzYPMytzoQRHjitMAaa16HnrzpqTj6iPM4z6KPg9WeM3Nna12Qo16OHL8gQNHgCG7mqIihQ0EwABaGATEQpxVvOSpdmicpiobJ8uxx8CCkv0wiZtNpdzE6SaTnqPkDR1t956TcLTsvcaCc6mwKJSjDOWygHBeZzfAjc3QCp3ztNJtjK5PZVo0yOUUZc1MOJKh(Zm(IIQZKWGHIIi5qzbfiAr1Ie(eWeucZjPnYKtnlZrDnmbzYudaOwpSjk7bQnrhj1eptNm1OhMW8(SbO2w1PwhnSK3q9m0HcCNbse5qL2ZsBdauR1t956TcL9zGbr4bXjyKN66INJtPI2czE68ziZtNfOTbkvPBTEQpxVvOSvQsaGVGoJf5iBshkmMr4gXCwHwIWTk3ZD2054uczE68RdncEUUZc1MOJKh(Zm(IIQZKWGHIIi5qzbfiAr1Ie(eWeucZjPnYKtnlBvt1qH8eGkbiruiHNPtMA0dtyEF2auBR6uRJgwYBOEgcXUZajICOs7zPTbaQ16P(C9wHY(mWGi8G4emYtDDXZXPurBHmpD(mK5PZc02aLQ0Twp1NR3ku2kvja4e0zSihzt6qHXmc3iMZk0seUv5EUZMohNsiZtNFDOrWDDNfQnrhjp8Nz8ffvNXgsyWqrrKCOSGceTOArcFcyckH5K0gzYPMlSMcjSnuNbse5qL2ZsBdauR1t956TcL9zGbr4bXjyKN66INJtPI2czE68ziZtNfOTbkvPBTEQpxVvOSvQsayNGoJf5iBshkmMr4gXCwHwIWTk3ZD2054uczE68Rdnc(x3zHAt0rYd)zgFrr15fwtHe2gQZajICOs7zrhsnOIKawynbqdYIY(mWGi8G4emYtDDXZXPurBHmpD(mK5PZW7qQbvKuPkSG1KsvG3KfL9zSihzt6qHXmc3iMZk0seUv5EUZMohNsiZtNFDOr4UUZc1MOJKh(Zm(IIQZL5OUgK2gaWwrur7a1MOJKAgr1ayMlq7cq0QYrEdjPEWWley0zGerouP98cRby4fkBao0SoRqlr4wL75oB6CCkv0wiZtNpdzE6mwWALQacVqzRuvianRZaTQNNBZtyBiYipWkvjynO0Pf7vQcmZfODdXZyroYM0HcJzeUrmNbgeHheNGrEQRlEooLqMNoZipWkvjynO0Pf7vQcmZfODFDOrS76oluBIosE4pdKiYHkTNXnNdGHxOSb4qZ6ScTeHBvUN7SPZXPurBHmpD(mK5PZaBoNsvaHxOSvQkeGM1zGw1ZZT5jSnezKhyLQeSgu60I9kvPMAAr4H4zSihzt6qHXmc3iMZadIWdItWip11fphNsiZtNzKhyLQeSgu60I9kvPMAAr4VEDgY80zg5bwPkbRbLoTyVsvssVbZvV(ba]] )

    storeDefault( [[SimC Unholy: precombat]], 'actionLists', 20170531.211500, [[dattcaGEjvAxqsVgs1Sf1nPuFJsStQAVKDJ0(rfddHFl1qPK0GHkdxvCquPJrflusSuuLfJOLdXdLKEQYJvvpxetesmvuvtMIPRYffPUkLexgCDkPARqkBgkSDOOplP8DjvTmQ0Prz0qvhw4KQsDBjUMQKZdL(Ri5zuszDsQy5i(APPbzgmIudfaJW65tv02hH9CAA8GmejG8UeowiErybvxxccIxA7b(SiZQBCSMkV7lxnU)J10eXxEhXxlnniZGrv02hH9CAxxRwgq9Ppwtt04sYYSdR2tFSMQvfp8r3UXeka9ePMDBqlq8rb008rb0SAFSMQXdYqKaY7s4yXHq7n1W(X1iA0McA2TXhfqtN8UIVwAAqMbJQOz3g0ceFuannFuanEblb4GdfimAvXdF0TBmHcqprQXdYqKaY7s4yXHq7n1W(X1iA0McACjzz2Hvdjyjqkdegn724JcOPtERj(APPbzgmQI2(iSNt76A1YaQ)UZMUEAIgxswMDy1cKc2ungPo8qkdegTQ4Hp62nMqbONi1SBdAbIpkGMMpkGgxKcwo4Am4G7WdCWHcegnEqgIeqExchloeAVPg2pUgrJ2uqZUn(OaA60P5JcOnwPkhCwHIVZyRdhCpiWVlKXPtc]] )

    storeDefault( [[SimC Unholy: valkyr]], 'actionLists', 20170531.211500, [[dWtKfaGELc1MePs7IiTnLcSprQQzksvMnPUPaldv13euNgXof1EP2nO9ti)uPunmr8BuoSKZJunyuXWrIdseNsKkoMu1ZukXcvQSuLQwmblxOfPuspv1JLY6iuzIkf1uLkMmjth4IIKRsOQldDDK0gvkLTIuAZkY2LkDBL8DbzAkfY8qk6VevpxHrJQmoLICscLpJkDnrk3dPWdjkVwrnkLcA37o(PGLGgvwWFZ4urvd8o)3IekaF)9OgRb6m)K(WjPLewkF(jjjP5FkyJuAYgxacd6m)047lPbim4WDCU3D8tblbnQ8o)aMI2kMRf67NRf6VzSa8eXrgJO9LXdBZbSU4cHal4Vh1ynqN5N0hUpXxmOI0kal6dzq0xIarta09vyb4jVXiA)aMkxl03aN57o(PGLGgvEN)BrcfGVcfOonjDchamsGCLhIrfQKoavBMgBYxIarta09lkSwPPtzG(Y4HT5awxCHqGf8dykARyUwOVFUwOVekSwPPtzG(7rnwd0z(j9H7t8fdQiTcWI(qge9dyQCTqFdCElUJFkyjOrL35)wKqb4RqbQttsNWbaJeix5HyuHkPdq1MP5Ms3gJPvSqqPffwR00PmqPrCve4GMP5lrGOja6(t4aGrcKR8bisMrFz8W2CaRlUqiWc(bmfTvmxl03pxl0FB4aGrcKRiohejZO)EuJ1aDMFsF4(eFXGksRaSOpKbr)aMkxl03aN3i3XpfSe0OY78FlsOa8RgG0fLJqCrWr6td((seiAcGUFR0A5vdqyq5AYa4lgurAfGf9Hmi6hWu0wXCTqF)CTqFzLwlIJKgGWGI4KEKbWxsK7WhwlKgB9KLmrCepKhttxCI4iz7P2Q)EuJ1aDMFsF4(eFz8W2CaRlUqiWc(bmvUwO)jlzI4iEipMMU4eXrY2tzGZP5o(PGLGgvEN)BrcfGVcfOonjDchamsGCLhIrfQKoavBMM0yl(seiAcGU)eoayKa5kFaIKz0xgpSnhW6IlecSGFatrBfZ1c99Z1c93goayKa5kIZbrYmkIZg2No(7rnwd0z(j9H7t8fdQiTcWI(qge9dyQCTqFdCEdCh)uWsqJkVZ)TiHcWxHcuNMKoHdagjqUYdXOcvsPsXxIarta09hng1ixu(aejZOVmEyBoG1fxieyb)aMI2kMRf67NRf6)gJAKlkIZbrYm6Vh1ynqN5N0hUpXxmOI0kal6dzq0pGPY1c9nW5WUJFkyjOrL35)wKqb4RqbQttsNWbaJeix5HyuHkPuP4lrGOja6(nDfIa5kFWRuSqdFz8W2CaRlUqiWc(bmfTvmxl03pxl0xMUcrGCfX58kfl0WFpQXAGoZpPpCFIVyqfPvaw0hYGOFatLRf6BGb(5AH(NSKjIJ4H8yA6IteNULEME0aBa]] )

    storeDefault( [[SimC Unholy: AOE]], 'actionLists', 20170531.211500, [[dCtheaGEscTjsI2fr61iP9Hu1SH08jjDtr5BsHDkv7LA3qTFPKrPsPHrk)MWGjvnCK4GsrNsLQoMkSqiyPqOftILJspuf5PGhJQNtutePWuLsnzetxvxKiUQkkDzLRRsXYevBfPYMvPY2rrNwYHf(mPY3jP6EQO6VQKrdr3wKtIu6zif11iPCEuyAQOyDif5NKeSpCBdsWHc6iwXan2DXnOVrWaWzlkVbdio0fYZ9CTJgAQP1qAEUMMMAgakJxbAPIXxcS75QLBOj)lbw2TD)WTnibhkOJyemaC2IYBi4FXCxdVunz6pp3qtLcTEggilEKxbMCrgpyy4eYXPMjyU0WVvmKji0fS9indg6rAgOXIhzl9bM0spngpyyaXHUqEUNRD04qZaTysXJxWAalWZqMG0J0m439C32GeCOGoIrWaWzlkVHG)fZDn8s1KP)mgAQuO1ZWWOuKLkUHtihNAMG5sd)wXqMGqxW2J0myOhPzqcLISuXnG4qxip3Z1oACOzGwmP4XlynGf4zitq6rAg87on72gKGdf0rmcgaoBr5ne8VyURHxQMm9NNRYBjIxkzXJ8kWKlY4bdPFXPwyDQQkr8sj7UcDs)ItTW6U3qtLcTEggK5IBy1Tl5NTOodNqoo1mbZLg(TIHmbHUGThPzWqpsZaWf3WQBT0dpBrDgqCOlKN75Ahno0mqlMu84fSgWc8mKji9ind(D)mUTbj4qbDeJGbGZwuEdb)lM7A4LQjt)55Q8wI4Lsw8iVcm5ImEWq6xCQfwNQQseVuYURqN0V4ulSU7n0uPqRNHboAOEH1DjJmic1LnCc54uZemxA43kgYee6c2EKMbd9indNqd1lSUw6bKbrOUSbeh6c55EU2rJdnd0IjfpEbRbSapdzcspsZGF3vZTnibhkOJyemaC2IYBi4FXCxdVunz6Zn0uPqRNHHrPilvCdNqoo1mbZLg(TIHmbHUGThPzWqpsZGekfzPI3s)Th3BaXHUqEUNRD04qZaTysXJxWAalWZqMG0J0m43VHEKMbOsNAP)SyKcug0ul9nvbj(Tb]] )

    storeDefault( [[SimC Unholy: standard]], 'actionLists', 20170531.211500, [[dStilaGEqu0MOu2fs2gikSpPuZwKBkkNwv3gPEmvTtG2RYUvz)uQgLusddKghvQIdlCEqyWusdhvCqsrNce5yOQZrLQ0crLAPOswmGLJYdPsEkXYiLwhvQktKIWubvnzsMUKlskCvQuvDzORtQ2iiQARuu2mf2ofPNrLkpxQMgiQ8Dq5BGk)LkgTOAEGO0jPO6ZuIRjL4EuPCikIETu8Bep(b)enUaiHQbmr8SNtnzIWb9FKEiZOEYnqTTODcyqJtKN2LDRU)lNKGW9z3AVItfm1eUWegDCGAHYdh0wGchLwTqHcTLjCHHcc4FACct)Wov90OtrC0ortF9KRp4hi)GFIgxaKq14EI4zpNAIcb0nmOmWEHS)S4aJOFkQEf(giRBUZgt)EVdhcmKrPqJ3)vBE3nrtGp9fetmWEHS)S40l23GtCLJ(MmIPinE1aMKruMfmWGgNmbmOXjqESxi7pl2Tkf7BWjCHjm64a1cLhoEOtm)uVpkcBYroCsgrbg04Kvdu7GFIgxaKq14EI4zpNAIjb0nmOo0Zi9VtPZXwfj8kQd9ms)7u4fajuzJPFiK1n3nrtGp9fetuyu5oEYNM4kh9nzetrA8QbmjJOmlyGbnozcyqJtmbgvUDRUiFAcxycJooqTq5HJh6eZp17JIWMCKdNKruGbnoz1aD3GFIgxaKq14EI4zpNAcGUHb1HEgP)DkDo2uiGUHbLb2lK9Nfhye9tr1RW302nEBm979oCiWqgLcnE)xT5BzIMaF6liM09eDMf0PxSVbN4kh9nzetrA8QbmjJOmlyGbnozcyqJteprNzbTBvk23Gt4cty0XbQfkpC8qNy(PEFue2KJC4KmIcmOXjRgiKBWprJlasOACpr8SNtnbq3WG6qpJ0)oLohBkeq3WGYa7fY(ZIdmI(PO6v4BA7gVnM(9EhoeyiJsHgV)R288t0e4tFbXeFkG9NfNEEOiW6tCLJ(MmIPinE1aMKruMfmWGgNmbmOXjUsbS)Sy3QKhkcS(eUWegDCGAHYdhp0jMFQ3hfHn5ihojJOadACYQb2YGFIgxaKq14EI4zpNAcGUHbL(Ltsq40lgEwQCkDo2uiGUHbLb2lK9Nfhye9tr1RW302nEBm979oCiWqgLcnE)xT5BzIMaF6liM09eDMf0PxSVbN4kh9nzetrA8QbmjJOmlyGbnozcyqJteprNzbTBvk23G2T2kpKMWfMWOJduluE44HoX8t9(OiSjh5WjzefyqJtwnqiJb)enUaiHQX9eXZEo1eaDddk9lNKGWPxm8Su5u6CSPqaDddkdSxi7ploWi6NIQxHVPTB82y637D4qGHmkfA8(VAZZprtGp9fet8Pa2FwC65HIaRpXvo6BYiMI04vdysgrzwWadACYeWGgN4kfW(ZIDRsEOiW62T2kpKMWfMWOJduluE44HoX8t9(OiSjh5WjzefyqJtwnq4g8t04cGeQg3tep75uty6h22nT2uiGUHbLb2lK9Nfhye9tr1RW302nEBm979oCiWqgLcnE)xT5BzIMaF6liM09eDMf0PxSVbN4kh9nzetrA8QbmjJOmlyGbnozcyqJteprNzbTBvk23G2T2QwinHlmHrhhOwO8WXdDI5N69rrytoYHtYikWGgNSAGUNb)enUaiHQX9eXZEo1eM(HTDtRnfcOByqzG9cz)zXbgr)uu9k8nTDJ3gt)EVdhcmKrPqJ3)vBE(jAc8PVGyIpfW(ZItppuey9jUYrFtgXuKgVAatYikZcgyqJtMag04exPa2FwSBvYdfbw3U1w1cPjCHjm64a1cLhoEOtm)uVpkcBYroCsgrbg04Kvd09o4NOXfajunUNiE2ZPMurcVIQNhkcmN)m07p5OWlasOYwfj8kkvWACcgWxiJcVaiHkBMeq3WGsfSgNIfx3GWOJ6jhLohBEcjPiWokvWACcgWxiJIH0XF928TmrtGp9fetuyu5oEYNM4kh9nzetrA8QbmjJOmlyGbnozcyqJtmbgvUDRUiFYU1w5H0eUWegDCGAHYdhp0jMFQ3hfHn5ihojJOadACYQbYdDWprJlasOACpr8SNtnPIeEfvppueyo)zO3FYrHxaKqLntwrcVIsfSgNGb8fYOWlasOYMjb0nmOubRXPyX1nim6OEYrPZzIMaF6liMOWOYD8KpnXvo6BYiMI04vdysgrzwWadACYeWGgNycmQC7wDr(KDRTQfst4cty0XbQfkpC8qNy(PEFue2KJC4KmIcmOXjRgip)GFIgxaKq14EI4zpNAsfj8kkvWACcgWxiJcVaiHkBEcjPiWokvWACcgWxiJIH0XF928TmrtGp9fetuyu5oEYNM4kh9nzetrA8QbmjJOmlyGbnozcyqJtmbgvUDRUiFYU1wDhKMWfMWOJduluE44HoX8t9(OiSjh5WjzefyqJtwnqETd(jACbqcvJ7jIN9CQjMSIeEfvppueyo)zO3FYrHxaKqLntwrcVIsfSgNGb8fYOWlasOAIMaF6liMOWOYD8KpnXvo6BYiMI04vdysgrzwWadACYeWGgNycmQC7wDr(KDRTc5G0eUWegDCGAHYdhp0jMFQ3hfHn5ihojJOadACYQvtmbAe6PACVAda]] )

    storeDefault( [[SimC Unholy: castigator]], 'actionLists', 20170531.211500, [[dStwiaGEjkQnjGDHITHik7dvXSP0nLKtRQVbHomv7es7vz3QSFkyuqqddIgNef8yHUNevdMcnCuvhKu4uichtQCojk1crLSuuPwSuwospuGEkXYquRtIcnriWurfMmjtx0frfDver1LbxNuTrjkYwjLAZu02jf9xjmpjk5ZsKVlP8muLMgIiJwQ65iCssj3gLUMKkNhr6qsQ61c63q96ght488MfuRnbbGPRBZX1eHpeF3(LzpF8nuY1rEc3GfCcyOKr2HiY6qIidzYirISUjsK(8Zjt0iMp(ighdTBCmHZZBwqnUMir6ZpNOGMUPjJjqKa9Vsf1W6NIHi9yyzvojfGQFFSGpUgqzuG5h)KhY8orJ2B)K0jMarc0)kvqK0peMeShIHvynbw4Y1MuHvA7uuNfMmb1zHjLjGib6FLmyus6hct4gSGtadLmYoe7qorRt9rpX0jh(GjvyfQZctwouYJJjCEEZcQX1ejsF(5K6B6MMmhePyINGrNFG0TWLmhePyINGboVzbvaQ(bLv58orJ2B)K0jkWZ(Ii(Ttc2dXWkSMalC5AtQWkTDkQZctMG6SWeeaE2BWyq8BNWnybNagkzKDi2HCIwN6JEIPto8btQWkuNfMSCO8ooMW55nlOgxtKi95NtA6MMmhePyINGrNFaf00nnzmbIeO)vQOgw)umePhd5PCEdq1VpwWhxdOmkW8JFYdzENOr7TFs6eIiwNwckis6hctc2dXWkSMalC5AtQWkTDkQZctMG6SWejI1PLadgLK(HWeUbl4eWqjJSdXoKt06uF0tmDYHpysfwH6SWKLdLKght488MfuJRjsK(8ZjnDttg9RhBjTGiPWvk7z05hqbnDttgtGib6FLkQH1pfdr6XqEkN3au97Jf8X1akJcm)4N8qM3jA0E7NKoHiI1PLGcIK(HWKG9qmScRjWcxU2KkSsBNI6SWKjOolmrIyDAjWGrjPFiyWic7iXeUbl4eWqjJSdXoKt06uF0tmDYHpysfwH6SWKLdTUXXeopVzb14AIePp)Ccv)aEkNCaf00nnzmbIeO)vQOgw)umePhd5PCEdq1VpwWhxdOmkW8JFYdzENOr7TFs6eIiwNwckis6hctc2dXWkSMalC5AtQWkTDkQZctMG6SWejI1PLadgLK(HGbJiKmjMWnybNagkzKDi2HCIwN6JEIPto8btQWkuNfMSCOKSXXeopVzb14AIePp)Cs6w4sgIExHRv8NPoXJpg48Mfubs3cxYOCAyHtBFcug48MfubQVPBAYOCAyrs9JWetz98XhJo)arm2QW1ogLtdlCA7tGYqbw)pcE6QBIgT3(jPtuGN9fr8BNeShIHvynbw4Y1MuHvA7uuNfMmb1zHjia8S3GXG43AWic7iXeUbl4eWqjJSdXoKt06uF0tmDYHpysfwH6SWKLdfXXXeopVzb14AIePp)Cs6w4sgIExHRv8NPoXJpg48MfubQpDlCjJYPHfoT9jqzGZBwqfO(MUPjJYPHfj1pctmL1ZhFm68NOr7TFs6ef4zFre)2jb7HyyfwtGfUCTjvyL2of1zHjtqDwyccap7nymi(TgmIqYKyc3GfCcyOKr2HyhYjADQp6jMo5WhmPcRqDwyYYHwgght488MfuJRjsK(8ZjPBHlzuonSWPTpbkdCEZcQarm2QW1ogLtdlCA7tGYqbw)pcE6QBIgT3(jPtuGN9fr8BNeShIHvynbw4Y1MuHvA7uuNfMmb1zHjia8S3GXG43AWic5Let4gSGtadLmYoe7qorRt9rpX0jh(GjvyfQZctwo0YECmHZZBwqnUMir6ZpNuF6w4sgIExHRv8NPoXJpg48MfubQpDlCjJYPHfoT9jqzGZBwqnrJ2B)K0jkWZ(Ii(Ttc2dXWkSMalC5AtQWkTDkQZctMG6SWeeaE2BWyq8BnyeHKejMWnybNagkzKDi2HCIwN6JEIPto8btQWkuNfMSC5euNfMipBqdgj5xp2sAz0GXOtKFjpX0LBa]] )

    storeDefault( [[SimC Unholy: instructors]], 'actionLists', 20170531.211500, [[dSdclaGEPKOnrj2fs2MuIY(KsnBrUPO60aFdu5Wc7uvTxLDRY(PugfiyyGYVr8yQ6EuunykPHJuoiQQofOkhJkoNusTqsflfPQfRklhLhsP6PeldvzDsjstKujtfPYKjz6sUiQkxvkr1LHUoPSrPeXwPOSzkSDsv9xQ08KssttkHVds3gvEgi0OfLdbQQtsQYNPixJuPopi65s14KscVwkEoJUj8DXlHQ9MOl0i0s10zIqd9GibALrbi3(80nVj0Jjm64(8G5ahmDddokE8GbdMUNiEgGwnzc)(cqU(OBFNr3e(U4Lq10zI4zaA1ef(0mmOmWEHmWzYfkr7uu9k8nTQ5q0ct7aExAeOiJsHgapOA7aXj8)ajqb5edSxidCMC7fd0GtSNH(MCI(ihE1EtYjkZc2p4Wjt(bhoPLG9czGZKnRsXan4e6XegDCFEWCGZb2e9ofWhfHn5ihojNO(bhoz1(8gDt47IxcvtNjINbOvtG)tZWG6qpJ0bDknAwQiHxrDONr6GofEXlHklmTdBvZH4e(FGeOGCIcJkZ1taPj2ZqFtorFKdVAVj5eLzb7hC4Kj)GdNOlmQmBwTtaPj0Jjm64(8G5aNdSj6DkGpkcBYroCsor9doCYQ9H4OBcFx8sOA6mr8maTAYtZWG6qpJ0bDknAwu4tZWGYa7fYaNjxOeTtr1RW3028wyHPDaVlncuKrPqdGhuT516j8)ajqb5KUNOXmHU9IbAWj2ZqFtorFKdVAVj5eLzb7hC4Kj)GdNiEIgZeAZQumqdoHEmHrh3Nhmh4CGnrVtb8rrytoYHtYjQFWHtwTFlgDt47IxcvtNjINbOvtEAgguh6zKoOtPrZIcFAggugyVqg4m5cLODkQEf(M2MdrlmTd4DPrGImkfAa8GQTJZe(FGeOGCIpfqbNj3EwOiq7tSNH(MCI(ihE1EtYjkZc2p4Wjt(bhoXEkGcot2SkzHIaTpHEmHrh3Nhmh4CGnrVtb8rrytoYHtYjQFWHtwTVUhDt47IxcvtNjINbOvtEAgguAxgjbPBVy4zQYO0OzrHpnddkdSxidCMCHs0ofvVcFtBZBHfM2b8U0iqrgLcnaEq1MxRNW)dKafKt6EIgZe62lgObNypd9n5e9ro8Q9MKtuMfSFWHtM8doCI4jAmtOnRsXanOnRqWbEtOhty0X95bZbohyt07uaFue2KJC4KCI6hC4Kv73YgDt47IxcvtNjINbOvtEAgguAxgjbPBVy4zQYO0OzrHpnddkdSxidCMCHs0ofvVcFtBZHOfM2b8U0iqrgLcnaEq12Xzc)pqcuqoXNcOGZKBplueO9j2ZqFtorFKdVAVj5eLzb7hC4Kj)GdNypfqbNjBwLSqrG2TzfcoWBc9ycJoUppyoW5aBIENc4JIWMCKdNKtu)GdNSAF4gDt47IxcvtNjINbOvtyAh22CEwu4tZWGYa7fYaNjxOeTtr1RW3028wyHPDaVlncuKrPqdGhuT516j8)ajqb5KUNOXmHU9IbAWj2ZqFtorFKdVAVj5eLzb7hC4Kj)GdNiEIgZeAZQumqdAZke4bVj0Jjm64(8G5aNdSj6DkGpkcBYroCsor9doCYQ9BfJUj8DXlHQPZeXZa0QjmTdBBoplk8PzyqzG9czGZKluI2PO6v4BABoeTW0oG3LgbkYOuObWdQ2oot4)bsGcYj(uafCMC7zHIaTpXEg6BYj6JC4v7njNOmly)GdNm5hC4e7Pak4mzZQKfkc0UnRqGh8MqpMWOJ7ZdMdCoWMO3Pa(OiSjh5Wj5e1p4WjR2V1JUj8DXlHQPZeXZa0QjvKWRO6zHIa1fCgADa5OWlEjuzPIeEfLkynUb7bkKrHx8sOYc8FAgguQG14wS46gegxuaYrPrZINqskc0JsfSg3G9afYOyixaUEBhDpH)hibkiNOWOYC9eqAI9m03Kt0h5WR2BsorzwW(bhozYp4Wj6cJkZMv7eqYMvi4aVj0Jjm64(8G5aNdSj6DkGpkcBYroCsor9doCYQ9DGn6MW3fVeQMotepdqRMurcVIQNfkcuxWzO1bKJcV4LqLf4xrcVIsfSg3G9afYOWlEjuzb(pnddkvWAClwCDdcJlka5O0OnH)hibkiNOWOYC9eqAI9m03Kt0h5WR2BsorzwW(bhozYp4Wj6cJkZMv7eqYMviWdEtOhty0X95bZbohyt07uaFue2KJC4KCI6hC4Kv774m6MW3fVeQMotepdqRMurcVIsfSg3G9afYOWlEjuzXtijfb6rPcwJBWEGczumKlaxVTJUNW)dKafKtuyuzUEcinXEg6BYj6JC4v7njNOmly)GdNm5hC4eDHrLzZQDcizZkeGi8MqpMWOJ7ZdMdCoWMO3Pa(OiSjh5Wj5e1p4WjR23H3OBcFx8sOA6mr8maTAc8RiHxr1ZcfbQl4m06aYrHx8sOYc8RiHxrPcwJBWEGczu4fVeQMW)dKafKtuyuzUEcinXEg6BYj6JC4v7njNOmly)GdNm5hC4eDHrLzZQDcizZkeAb8MqpMWOJ7ZdMdCoWMO3Pa(OiSjh5Wj5e1p4WjRwn5hC4ebWz3M1w(Lrsq2sTzfC9IP5lcRVAda]] )


    storeDefault( [[SimC Frost: generic]], 'actionLists', 20170531.211500, [[dmKgzaqikcBsezueWPqLAwIOi3cvsyxeAyiQJjslJcEgrsMgrcxdvcBtef(gbACOssDoujADIOOMhrsX9KQ0(Oi6GeulKG8qkstKiP0fjsTrru9rujrJueLojvWkrLKCtezNOQFsKuTuI4PKMQuvBLk0xjs0EH(lrnyQ6WswmqpgHjlLlRAZuPptrnAaDAqVMcnBb3wu7wPFJYWLkhhvsz5i9CHMUIRdW2fHVtfDEuX6rLunFPk2pLgtX(Ok9wGH3qqu1UtaRaKRxdKTiVbUifv(kFuvy2uRp5uwCsMTEZFpfsGQu7DlaHbfcvjp8kEK3a5ubjZfKfu0GbYKjZfOk5vJtFy(OAIPcFhrxklorcodWl(TadVz912SEYwpJA9GaCDfncdb4AwoxeaH7fPpxWnIQWedKTrSpYNI9rv6TadVHcHQsqHDdQMyQW3rmcSM5u4AwoouOXhf)wGH3S(KSEbSEqaUUIqcoYtfyBuK(Cb3O1l1y9PICH1NK1pv47icj4ipvGTrXVfy4nRNBufgegGdhuDPS4ihhk04r1uGNWijwIN)oiiQKynhlkFLpQOYx5JAYPS4y96qHgpQob(vYRghuJeuy3GQKhEfpYBGCQGPKrvYRgN(W8rfeGRRiKGJ8ub2gfPpxWnA9CfwFQixGQdBdsudJI6Y2JkjwJVYhvCqEdyFuLElWWBOqOQeuy3G6uHVJyeynZPW1SCCOqJpk(TadVz9jz9TdcW1vKwCDgfsCX4uegT(ETEUavHbHb4WbvxkloYXHcnEunf4jmsIL45VdcIkjwZXIYx5JkQ8v(OMCklowVouOXB9cKYnQsE4v8iVbYPcMsgvh2gKOggf1LThvsSgFLpQ4G8sf2hvP3cm8gkeQkbf2nOAIgBeDPS4i7(eNkoqcJW1mQob(vYRghuJeuy3GQdBdsudJI6Y2JkjwZXIYx5JkQcdcdWHdQazodW1SmyOIdQ8v(OMSmNb4A26fkuXbvHPMJOof18hzOBVMOXgrxkloYUpXPIdKWiCnJQKhEfpYBGCQGPKrvYRgN(W8rTXgrxkloYUpXPI0Nl4gr1uGNWijwIN)oiiQKyn(kFuXb5LcSpQsVfy4nuiuvckSBqDQW3r0CnapfUMLJdJMf)wGH3qvyqyaoCqL(mJgF4XOSt4oNIQPapHrsSep)DqqujXAowu(kFurLVYhvjpZOXhEmA9sjCNtrvYdVIh5nqovWuYO6W2Ge1WOOUS9OsI14R8rfhKNlW(Ok9wGH3qHqvjOWUbvqaUUIuy(Ia6S(KS(Z1aa76EtS704tCATexM5kpaV8bzRCUOdhQ1NK1lG1dcW1vKbgGZP1azRyJ5CT(E6X6lIbM4YFFg(O1BYETEdwp3OkmimahoOsFMrJp8yu2jCNtr1HTbjQHrrDz7rLVYhvjpZOXhEmA9sjCNtTEbkUrvYdVIh5nqovWuYOk5vJtFy(OwedmXL)(m8rR3K9A9gS(ABwpzRNrTEqaUUImWaCoTgiBfPpxWnIQKhzaOepI9XbvNa)k5vJdQrckSBWb5tgyFuLElWWBOqOQeuy3GkiaxxrkmFraDwFswVawpiaxxrgyaoNwdKTInMZ167PhRVigyIl)9z4JwVj716ny9CB9jz9cy9M4CnaWUU3e7on(eNwlXLzUYdWlFq2kNl6WHA990J1BIPcFhrZ1a8u4AwoomAw8BbgEZ652YvHQWGWaC4GkqMZaCnldgQ4GQPapHrsSep)DqqujXAowu(kFurLVYh1KL5maxZwVqHkowVaPCJQtGFL8QXb1ibf2nOk5HxXJ8giNkykzuL8QXPpmFulIbM4YFFg(O1BYETEdwFTnRNS1ZOwpiaxxrgyaoNwdKTI0Nl4gr1HTbjQHrrDz7rLeRXx5JkoiVGyFuLElWWBOqOQeuy3GkiaxxrkmFraDwFswVawpiaxxrgyaoNwdKTInMZ167PhRVigyIl)9z4JwVj716ny9CB9jDUgayx3BIDNgFItRL4Ymx5b4LpiBLZfD4qT(KSCvtf(oIMRb4PW1SCCy0S43cm8M1NK1lG13oiaxxXUtJpXP1sCzMR8a8YhKTY5IoCOIa6S(E6X6jySqJ5CfPpZOXhEmk7eUZPI0Nl4gTEtA9sL1ZnQcdcdWHdQazodW1SmyOIdQMc8egjXs883bbrLeR5yr5R8rfv(kFutwMZaCnB9cfQ4y9cyGBuDc8RKxnoOgjOWUbvjp8kEK3a5ubtjJQKxno9H5JArmWex(7ZWhTEt2R1BW6RTz9KTEg16bb46kYadW50AGSvK(Cb3yYK13oiaxxXUtJpXP1sCzMR8a8YhKTY5IoCOIa6S(ABwpzRNrTEcgl0yoxr6ZmA8HhJYoH7CQi95cUrRNRW6LkuDyBqIAyuux2EujXA8v(OIdYZvJ9rv6TadVHcHQsqHDdQMaeGRRidmaNtRbYwraDwFswVaw)5AaGDDVjAKfgiTIY7D6YaSnzNWqW6tY6Nk8DeDPmU(x5oaH4f)wGH3S(KSEbS(4hzq2cikoWtt5szdDe9MA990J1h)idYwarXbEAkxklfDe9MA9CB9CJQWGWaC4GkdmaNtR5OAkWtyKelXZFheevsSMJfLVYhvu5R8rvQdgGZP1CuDc8RKxnoOgjOWUbvjp8kEK3a5ubtjJQKxno9H5JkiaxxrgyaoNwdKTI0Nl4gr1HTbjQHrrDz7rLeRXx5JkoipxI9rv6TadVHcHQsqHDdQualKqUJ58uX2DHeWrQP3uYOkmimahoO6szXroouOXJQPapHrsSep)DqqujXAowu(kFurLVYh1KtzXX61HcnERxadCJQtGFL8QXb1ibf2nOk5HxXJ8giNkykzuL8QXPpmFuPawiHChZ5PIdmF5HjZLKr1HTbjQHrrDz7rLeRXx5JkoiFkzSpQsVfy4nuiuvckSBqfeGRRidmaNtRbYwraDwFswVjab46kAegcW1SCUiac3lcOdvHbHb4WbvxkloYXHcnEunf4jmsIL45VdcIkjwZXIYx5JkQ8v(OMCklowVouOXB9civCJQtGFL8QXb1ibf2nOk5HxXJ8giNkykzuL8QXPpmFubb46kAegcW1SCUiac3lsFUGBevh2gKOggf1LThvsSgFLpQ4G8PPyFuLElWWBOqOQeuy3GArmWex(7ZWhTEt2R1BW6tY6fW6nXuHVJOlLfNibNb4f)wGH3S(E6X6nbiaxxrJWqaUMLZfbq4EraDwp3OkmimahoOsFMrJp8yu2jCNtr1uGNWijwIN)oiiQKynhlkFLpQOYx5JQKNz04dpgTEPeUZPwVaPCJQtGFL8QXb1ibf2nOk5HxXJ8giNkykzuL8QXPpmFunXuHVJOlLfNibNb4f)wGH3S(ABwpzRNrTEqaUUIgHHaCnlNlcGW9I0Nl4gr1HTbjQHrrDz7rLeRXx5JkoiFQbSpQsVfy4nuiuvckSBqvaRheGRROryiaxZY5IaiCViGoRpjRVigyIl)9z4JwVj716ny9CJQWGWaC4GQlLfNibNb4r1uGNWijwIN)oiiQKynhlkFLpQOYx5JAYPS4ej4mapQsE4v8iVbYPcMsgvh2gKOggf1LThvsSgFLpQ4G8Psf2hvP3cm8gkeQkbf2nOwedmXL)(m8rR3K9A9gqvyqyaoCq1COiGvqUAjQL4OAkWtyKelXZFheevsSMJfLVYhvu5R8rLRmueWky9c3sulXrvYdVIh5nqovWuYO6W2Ge1WOOUS9OsI14R8rfhKpvkW(Ok9wGH3qHqvjOWUb1IyGjU83NHpA9MSxRxQqvyqyaoCq1LYItKGZa8OAkWtyKelXZFheevsSMJfLVYhvu5R8rn5uwCIeCgG36fiLBuL8WR4rEdKtfmLmQoSnirnmkQlBpQKyn(kFuXb5t5cSpQsVfy4nuiuvckSBqfeGRROryiaxZY5IaiCViGoufgegGdhuzGb4CAnhvtbEcJKyjE(7GGOsI1CSO8v(OIkFLpQsDWaCoTMB9cKYnQsE4v8iVbYPcMsgvNa)k5vJdQfGHHQdBdsudJI6Y2JkjwJVYhvCq(0Kb2hvP3cm8gkeQkbf2nOov47iAUgGNcxZYXHrZIFlWWBwFsw)uHVJygaTDkdqu(UUqc4xcoIFlWWBwFswVawF8JmiBbefh4PPCPSHoIEtT(E6X6JFKbzlGO4apnLlLLIoIEtTEUrvyqyaoCq1LYIJCCOqJhvtbEcJKyjE(7GGOsI1CSO8v(OIkFLpQjNYIJ1RdfA8wVasb3Ok5HxXJ8giNkykzuDyBqIAyuux2EujXA8v(OIdYNki2hvP3cm8gkeQkbf2nOkG1pv47icKrxzMRSt4oNk(TadVz990J1pv47iceWA(u4AwMcyVSZxDSv8BbgEZ6526tY6fW6JFKbzlGO4apnLlLn0r0BQ13tpwF8JmiBbefh4PPCPSu0r0BQ1ZnQcdcdWHdQUuwCKJdfA8OAkWtyKelXZFheevsSMJfLVYhvu5R8rn5uwCSEDOqJ36fGl4gvjp8kEK3a5ubtjJQdBdsudJI6Y2JkjwJVYhvCq(uUASpQsVfy4nuiujXAowu(kFurLVYhvPoyaoNwZTEbmWnQcdcdWHdQmWaCoTMJQKhEfpYBGCQGPKr1uGNWijwIN)oiiQoSnirnmkQlBpQKyn(kFuXb5t5sSpQsVfy4nuiujXAowu(kFurLVYhvUYqraRG1lClrTe36fiLBufgegGdhunhkcyfKRwIAjoQsE4v8iVbYPcMsgvtbEcJKyjE(7GGO6W2Ge1WOOUS9OsI14R8rfhK3azSpQsVfy4nuiuvckSBq1eGaCDfbcynFkCnltbSx25Ro2kcOdvHbHb4WbvGm6kZCLDc35uunf4jmsIL45VdcIkjwZXIYx5JkQ8v(OMSm6A9mxRxkH7CkQob(vYRghuJeuy3GQKhEfpYBGCQGPKrvYRgN(W8rfeGRRiqaR5tHRzzkG9YoF1Xwr6ZfCJO6W2Ge1WOOUS9OsI14R8rfhK3qk2hvP3cm8gkeQKynhlkFLpQOYx5JAYPS4y96qHgV1lqYGBufgegGdhuDPS4ihhk04rvYdVIh5nqovWuYOAkWtyKelXZFheevh2gKOggf1LThvsSgFLpQ4G8gmG9rv6TadVHcHQsqHDdQtf(oIUugx)RChGq8IFlWWBOkmimahoOsFMrJp8yu2jCNtr1uGNWijwIN)oiiQKynhlkFLpQOYx5JQKNz04dpgTEPeUZPwVag4gvjp8kEK3a5ubtjJQdBdsudJI6Y2JkjwJVYhvCqEdsf2hvP3cm8gkeQkbf2nOomZMdxKGXcnMZnIQWGWaC4G6ZDmNNktbSx25Ro2IQPapHrsSep)DqqujXAowu(kFurLVYhvPZDmNNA9saS36LYxDSfvjp8kEK3a5ubtjJQdBdsudJI6Y2JkjwJVYhvCqEdsb2hvP3cm8gkeQkbf2nOomZMdxKGXcnMZnA9jz9cy9MaeGRRiqaR5tHRzzkG9YoF1XwraDwp3OkmimahoOceWA(u4AwMcyVSZxDSfvtbEcJKyjE(7GGOsI1CSO8v(OIkFLpQjlG18PW1S1lbWERxkF1XwuDc8RKxnoOgjOWUbvjp8kEK3a5ubtjJQKxno9H5JkiaxxrGawZNcxZYua7LD(QJTI0Nl4gr1HTbjQHrrDz7rLeRXx5Jko4GQsqHDdQ4Gi]] )

    storeDefault( [[SimC Frost: default]], 'actionLists', 20170531.211500, [[dqeouaqiaQfPKkBsQ4tcPsJIO0PeGzjKQ6wsLsTlOmmi1XGKLjv1ZiI00KkLCnPs12Kkf(grX4KkfDoLuvRtiL5reX9iIY(eq5GaYcfcpeqnrHuHlkeTrLuoPujRuivzMkPk3KOANu0pfsfnubelvQYtPAQayRaK9I8xGgmjhwYIH4Xk1KLYLrTzk8zHA0ePtd61eHztQBdv7wLFlA4c64ciTCv9CknDfxxj2UqY3vsoVaTEbunFIOA)eMqraqEKxHO5gHqE0bBul6HIGCZcNj3H4aluR9PDIMq1yJArpK7H8gwAyGxdmpYSF3rrEpwZLLjZ(Orjd6UJwgS(9rJgD3jVhxTGaaXzY)LdUbdZv8JzuATfCsW(Yqoq7bMNLaGmrraqEKxHO5gfb5((HHd5aMd0fyyi3W25ff)X8TzW0a0Og2kusUKluaEknFdgYZ1ifmnaTWR9vCAlm(ken3ihieOgobjpeQ11dMgGgFAhYbwkVLqEgfJZ3qiKlpBaQEZcNjNCZcNjpqGAD9cvAiuR9PDiVhR5YYKzF0OKbfAY76AWDn5t(LhtU8Szw4m50qM9jaipYRq0CJIGCF)WWHCoqxGHHCdBNxu8hZ3MbtdqJAyRq1rOMsZ3GH8Cnsbtdql8AFfN2cJVcrZnHQJqjRq9lhCdgMR4hBV8pFJqfysMq1D0cvhHANPULRomPlxm)Wlg8xogCfxH5H9mEbpRqjjcfk0cvaKdecudNGKhc166btdqJpTd5alL3sipJIX5BieYLNnavVzHZKtUzHZKhiqTUEHkneQ1(0ocLSOcG8vs5RhxTGKB3pmCiVhR5YYKzF0OKbfAY7XvliaqCM8F5GBWWCf)ydeNbNeS7OJ(c1otDlxDysxUy(Hxm4VCm4kUcZd7z8cEwHQBluOqtExxdURjFYV8yYLNnZcNjNgYusjaipYRq0CJIGCF)WWHCoqxGHHCdBNxu8hZ3MbtdqJAyRq1rOMsZ3GH8Cnsbtdql8AFfN2cJVcrZnHQJqjRqTZu3YvhgYZ1ifmnaTWR9vCAlSNXl4zfQatO6JwOcGCZcNjpqGAD9cvAiuR9PDekzrvbqoqiqnCcsEiuRRhmnan(0oK311G7AYN8lpM8ESMlltM9rJsguOjVhBZLFZwcaAOHm7weaKh5viAUrrqUVFy4q(KXXAgdEd))s4yjhieOgobjhhEnqJN5aNjhyP8wc5zumoFdHqU8SbO6nlCMCYnlCMC5WRjuR9mh4m59ynxwMm7JgLmOqtExxdURjFYV8yYLNnZcNjNgYS7eaKh5viAUrrqUVFy4q(KXXAgBNPULRoRq1rOKvO(LdUbdZv8J1yd4gocvGju9rluDekapLMVbd55AKcMgGw41(koTfgFfIMBcvaKdecudNGKx)UogCY)5BihyP8wc5zumoFdHqU8SbO6nlCMCYnlCMCG(DDSqbq(pFd5RKYxpUAbj3UFy4qEpwZLLjZ(Orjdk0K3JRwqaG4m5)Yb3GH5k(XmkT2cojOmRp5DDn4UM8j)YJjxE2mlCMCAiZUbba5rEfIMBueK77hgoKpzCSMX2zQB5QZkuDekzfQP08nyipxJuW0a0cV2xXPTW4Rq0CtO6iuTCWqEUgPGPbOfETVItBHnWTeWlwO6iu)Yb3GH5k(X2l)Z3iusIqjPOfQoc1VCSqjjcvFHkaYbcbQHtqYRFxhdo5)8nKdSuElH8mkgNVHqixE2au9Mfoto5Mfotoq)UowOai)NVrOKfvaKVskF94QfKC7(HHd59ynxwMm7JgLmOqtEpUAbbaIZK)lhCdgMR4hZO0Al4KG9xFY76AWDn5t(LhtU8Szw4m50qMYqaqEKxHO5gfb5((HHd5tghRzSDM6wU6ScvhHswHczXWaleQ11dMgGgFAhSLqHkaYbcbQHtqYr0z2anw(GKdSuElH8mkgNVHqixE2au9Mfoto5MfotEe6mBc1AlFqY7XAUSmz2hnkzqHM8UUgCxt(KF5XKlpBMfotonKz3KaG8iVcrZnkcY99ddhYNmowZy7m1TC1zfQocLScfYIHbwiuRRhmnan(0oylHcvaKdecudNGKJWVLFjGxm5alL3sipJIX5BieYLNnavVzHZKtUzHZKhb)w(LaEXK3J1CzzYSpAuYGcn5DDn4UM8j)YJjxE2mlCMCAiZ1NaG8iVcrZnkcY99ddhYNmowZyH5aZZkuDekzfkKfddSqOwxpyAaA8PDWwcfQocfG3zQB5Qdd55AKcMgGw41(koTf2Z4f8ScvGjuOfQaerpYbcbQHtqYdZbMh5alL3sipJIX5BieYLNnavVzHZKtUzHZKhi5aZJ8vs5RhxTGKB3pmCiVhR5YYKzF0OKbfAY7XvliaqCM8DM6wU6WqEUgPGPbOfETVItBH9mEbpl5DDn4UM8j)YJjxE2mlCMCAituOjaipYRq0CJIGCF)WWH8jJJ1mwyoW8ScvhHswHczXWaleQ11dMgGgFAhSLqHQJqb4P08nyipxJuW0a0cV2xXPTW4Rq0CtOcqe9i3SWzYdKCG5juYwbqoqiqnCcsEyoW8iVRRb31Kp5xEm59ynxwMm7JgLmOqtEp2Ml)MTea0qdzIcfba5rEfIMBueK77hgoKpzCSMX2zQB5QZkuDekzfkaZb6cmmKBy78S5pwWDQBG78zHQJqHSyyGfc166btdqJpTd2sOq1rOKvOqwmmWwoPPoiODE(IhPylHcLKl5cLqHSyyGfc166btdqJpTd2Z4f8ScLKiusQqfGq1rOAmYIHb2xbE(WnJzNAlHqjzcv3fQocfGrwmmWsenC4VgyEylHcvaKdecudNGKBHx7R40wwqJLpi5alL3sipJIX5BieYLNnavVzHZKtUzHZK7WR9vCARORvOwB5ds(kP81JRwqYT7hgoK3J1CzzYSpAuYGcn594QfeaiotoYIHb2Yjn1bbTZZx8ifBjuOQRjuOfQ8fkKfddSqOwxpyAaA8PDWEgVGNvO62cLKg9fkKfddSerdh(RbMh2Z4f8SK311G7AYN8lpMC5zZSWzYPHmr1NaG8iVcrZnkcY99ddhYNmowZy7m1TC1zfQocLScfhOlWWqUHTZZM)yb3PUbUZNfQocfYIHb2Yjn1bbTZZx8ifBjuO6iu7m1TC1Hfc166btdqJpTd2Z4f8ScvGju9rlubqoqiqnCcsUfETVItBzbnw(GKdSuElH8mkgNVHqixE2au9Mfoto5MfotUdV2xXPTIUwHATLpOqjlQaiVhR5YYKzF0OKbfAY76AWDn5t(LhtU8Szw4m50qMOKucaYJ8ken3Oii33pmCiFY4ynJTZu3YvNvO6iuYkuYkuaEknFdMXNboFGHlAlJXxHO5Mqj5sUqjRq9lhlusIq1xO6iu)Yb3GH5k(X2l)Z3iusIq1VBkubiubiuDekapLMVblUgP8dVyq7KpogFfIMBcvaKdecudNGKNiA4WFnW8ihyP8wc5zumoFdHqU8SbO6nlCMCYnlCM8OtenC4VgyEKVskF94QfKC7(HHd59ynxwMm7JgLmOqtEpUAbbaIZK)lhCdgMR4hZO0Al4KG9LH8UUgCxt(KF5XKlpBMfotonKjQUfba5rEfIMBueK77hgoKd4P08nyipxJuW0a0cV2xXPTW4Rq0CtO6iuawOKvOMsZ3GfxJu(HxmODYhhJVcrZnHQJqHSyyG9mE(wwZwl4k4n8JTekubqoqiqnCcs(U0AWApW8a1q7qExxdURjFYV8yYLNnavVzHZKtUzHZKdCP1cfq7bMNqTEq7qoqFSL8RWzjBDoehyHATpTt0eQy(4hUxh59ynxwMm7JgLmOqtoWs5TeYZOyC(gcHC5zZSWzYDioWc1AFANOjuX8XpCtdzIQ7eaKh5viAUrrqUVFy4q(uA(gmKNRrkyAaAHx7R40wy8viAUjuDeka3Ybd55AKcMgGw41(koTf2a3saVyYbcbQHtqY3Lwdw7bMhOgAhY76AWDn5t(LhtU8SbO6nlCMCYnlCMCGlTwOaApW8eQ1dAhHswubqoqFSL8RWzjBDoehyHATpTt0ekK0UoY7XAUSmz2hnkzqHMCGLYBjKNrX48nec5YZMzHZK7qCGfQ1(0ortOqslnKjQUbba5rEfIMBueK77hgoKpLMVbd55AKcMgGw41(koTfgFfIMBcvhHQLdgYZ1ifmnaTWR9vCAlSbULaEXKdecudNGKVlTgS2dmpqn0oK311G7AYN8lpMC5zdq1Bw4m5KBw4m5axATqb0EG5juRh0ocLS9dGCG(yl5xHZs26CioWc1AFANOjuiPvOg4wc4fVoY7XAUSmz2hnkzqHMCGLYBjKNrX48nec5YZMzHZK7qCGfQ1(0ortOqsRqnWTeWlMgYeLmeaKh5viAUrrqUVFy4q(uA(gS4AKYp8IbTt(4y8viAUjuDekKfddSNXZ3YA2AbxbVHFSLqHQJqb4P08nyipxJuW0a0cV2xXPTW4Rq0CJCGqGA4eK8DP1G1EG5bQH2H8UUgCxt(KF5XKlpBaQEZcNjNCZcNjh4sRfkG2dmpHA9G2rOKvsdGCG(yl5xHZs26CioWc1AFANOjuXwHAGBjGx86iVhR5YYKzF0OKbfAYbwkVLqEgfJZ3qiKlpBMfotUdXbwOw7t7enHk2kudClb8IPHgY99ddhYPHia]] )

    storeDefault( [[SimC Frost: precombat]], 'actionLists', 20170531.211500, [[b4vmErLxtvKBHjgBLrMxI51uevMzHvhB05LqEn1uWv2yPfgBPPxy0L2BU5LtYutmEnLuLXwzHnxzE5KmWeZnWudm34ImYadmWuJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtneALn2An9MDL1wzUrNxI51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtjvzSvwyZvMxojdmXCtmW41uj5gzPnwy09MCEnLBV5wzEnvtVrMtH1wzEnLx05fDEnLtH1wzEn1uP12q(bMrY92C0PJFGbNCLn2BTjwy05fDE5f]] )

    storeDefault( [[SimC Frost: gs ticking]], 'actionLists', 20170531.211500, [[d8d0kaqAOwVsv0MujAxsX2OuvSpIi8yuCyQMnPMVkHBsjhIc4BkvghruTtLSxXULSFk0pjI0WKQ(TQEoQ6YGbtPmCPYbrjDkkOJrrNJsvLfQsAPeLfRILt4HOsEkYYirRtPk0ePuvAQsjtwrthYfrj(Rk1ZiIY1jPnQuL2kQuBwPSDPuFKiI(QsvzAkvbFNinsLQQ5rPkJgv8zuQtseUfLQQUgfOZtcVMO62kmkkvoMPviwk)OHzoHOoGb7A8E6i8xzP0GMHw(acr4bxgTTxXZJ2JgTXM3OneMroUyhY(cBUQgLRHKbAW5HSu2BUR3G97AuQSVV3GHKb(url8acDu32A4OwSbbUyFlul4wk4DF1iGHJl(qSYGWFXNwzzMwHyP8JgM5AiIrG7qHoQBBnygf3ix)fFJagoU4TNzJbVe5AOqnygf3ix)fFdu(rdZqSEWAmsrOnXZJU5rcSCiexCag5wFByafkNqw)KBxS8bek0YhqO9kEEKrBesGLdHKYbkzGpveINrG7qHKbAW5HSu2BUZSpKmWNkAHhqOJ62wdMrXnY1FX3iGHJlE7VzJbdjrnXmo6fHQVGqw)C5diuqzPmTcXs5hnmZ1qw)KBxS8bek0YhqizW4f8Gg45nABF4cbIqSEWAmsribmEbpObE(BP4cbIqYan48qwk7n3z2hIloaJCRVnmGcLtijQjMXrViu9feY6NlFaHckljlTcXs5hnmZ1qeJa3HczG5JA2epp6EdAdIgeMroUyhI1dwJrkcX5LQXf77J25rH4IdWi36BddOq5eY6NC7ILpGqHw(acT)xQgxSnA7Q25rHKbAW5HSu2BUZSpKe1eZ4OxeQ(ccz9ZLpGqbL1EiTcXs5hnmZ1qeJa3HcDu32Ae4b0O2DPbS7OUT18hngbchH)QrT7sNbHBd3qbdmWBpLggI1dwJrkcX5LQXf77J25rH4IdWi36BddOq5eY6NC7ILpGqHw(acT)xQgxSnA7Q25rgTzNPHHKYbkzGpveYvrFizGgCEilL9M7m7drCEPw)eVHbbFoHKOMygh9Iq1xqiRFU8bekOSmyAfILYpAyMRHigbUdfc9SzRHgM)1ZxAXFPD2zaKRHc1Sj(9eQ7ovnp0aLF0W8IlStOwG9uEPqTWm3DVuq0WOkeqHSNsj3qdnmeRhSgJue6pAmceoc)viU4amYT(2WakuoHS(j3Uy5diuOLpGqs6rJrGWr4Vcjd0GZdzPS3CNzFijQjMXrViu9feY6NlFaHckl7tAfILYpAyMRHigbUdfsOwGKqYU4IJ62wJCSwJl23dNHdUGg1UlU4OUT18hngbchH)QrTleRhSgJue6pAmceoccXfhGrU13ggqHYjK1p52flFaHcT8besspAmceoccjd0GZdzPS3CNzFijQjMXrViu9feY6NlFaHckRDPviwk)OHzUgIye4ouiHAHzU7EPGOHrviGcjjK8(lUWUJ62wZF0yeiCe(Rg1UlnWrDBRrowRXf77HZWbxqJANHHy9G1yKIqBINhDZJey5qiU4amYT(2WakuoHS(j3Uy5diuOLpGq7v88iJ2iKalhmAZotddjd0GZdzPS3CNzFiPCGsg4tfHCv0hsIAIzC0lcvFbHS(5YhqOGYsYtRqSu(rdZCnK1p52flFaHcT8besspAmceocmAZotddX6bRXifH(JgJaHJGqYan48qwk7n3z2hIloaJCRVnmGcLtijQjMXrViu9feY6NlFaHckl7xAfILYpAyMRHigbUdfsOwyM7UxkiAyufcOq2Bx)Lg4OUT1WrTydcCX(wOwWTuW7(QrTleRhSgJueIZlQ7F7wkUqGiexCag5wFByafkNqw)KBxS8bek0YhqO9)IYOTFZOT9Hleicjd0GZdzPS3CNzFijQjMXrViu9feY6NlFaHcklZ(0kelLF0Wmxdz9tUDXYhqOqlFaHKKANb7AJ2yD22lgieRhSgJueIT2zWU(2NT9Ibcjd0GZdzPS3CNzFiU4amYT(2WakuoHKOMygh9Iq1xqiRFU8bekOSmntRqSu(rdZCnK1p52flFaHcT8beAVINhz0gHey5GrB2P0WqSEWAmsrOnXZJU5rcSCiKmqdopKLYEZDM9H4IdWi36BddOq5esIAIzC0lcvFbHS(5YhqOGYYuzAfILYpAyMRHigbUdfc9SzRHgM)1ZxAXFPDg4OUT1WrTydcCX(wOwWTuW7(QrTZWqSEWAmsrioQfBqGl23c1cULcE3xH4IdWi36BddOq5eY6NC7ILpGqHw(acTF1IniWfBJ2KPwGrB7d8UVcjLduYaFQiepJa3Hcjd0GZdzPS3CNzFizGpv0cpGqh1TTgoQfBqGl23c1cULcE3xncy44IpKe1eZ4OxeQ(ccz9ZLpGqbLLPKLwHyP8JgM5AiIrG7qHqpB2AOH5F98Lw8Hy9G1yKIqWO7LcIBHAb3sbV7RqCXbyKB9THbuOCcz9tUDXYhqOqlFaHyz09sbHrBYulWOT9bE3xHKbAW5HSu2BUZSpKe1eZ4OxeQ(ccz9ZLpGqbfuiIrG7qHckb]] )

    storeDefault( [[SimC Frost: bos]], 'actionLists', 20170531.211500, [[deuUqaqikbBIs0OisofrQBrjK2fbdtPCmjzzskptsvMMaQRjaBtajFdrzCiQkDokHADiQQAEiQY9Kuv7JsLdsPyHeHhkOmrbK6IukTrbvgPGQCskvTsevf3evStI6NucXsrLEkPPkqBvsLVkGyVq)fLgmvDyvwmHEmctwOld2mk8zkPrJIonsVwqMTsUTe7wv)wXWvQoUGQA5IEoftxQRJQSDIOVJiNhv16ruvz(iQSFQmwHbr12)exqefrv3bc6TOKFxtNhLRfqfQYxbqvPLWC(WLJPj)DEXXGAGgyC8wnkbQCHfCgaLRTvr2waBKjuR222waOYfUi)G0cGAY7PeS7djifyCRLHThwY2q1gIMoVbdIYvyquT9pXferjqvjs6EJAFl4BbkbF2(wZBeG)exq05T05f5XGHaLGpBFR5ncjuo6BCEYZ5RecW5T05jMzfhsVGycxZKDyWAOFmpRJ5esOC0348258bkuTrKUOnFuzKJPznDsdbOggtGieNrsOaFJIOYzI1DP8vaurv(kaQHlht78AN0qaQKycpx4I8r1qK09gvUWcodGY12QiRAdvUWf5hKwauf5XGHaLGpBFR5ncjuo6BCElQZxjeaQ2)rkX1tI6ppGkNjkFfavSr5AyquT9pXferjqvjs6EJAFl4BbRxZes6BL10tweG)exqevBePlAZh1ektAGfymSKOFdjQHXeicXzKekW3OiQCMyDxkFfavuLVcGkxOmPbwGX48bc9BirLlSGZaOCTTkYQ2q1(psjUEsu)5bu5mr5RaOInkxpmiQ2(N4cIOeOQejDVr1cXPfyKJPzzascPqtjcrFROsIj8CHlYhvdrs3BuT)JuIRNe1FEavotSUlLVcGkQ2isx0MpQmhsl6BLvCDMgv5RaOgEdPf9T68sSotJQnPvdQ9LwHMLYO(wioTaJCmnldqsifAkri6BfvUWcodGY12QiRAdvUWf5hKwauJtlWihtZYaKesHekh9nOggtGieNrsOaFJIOYzIYxbqfBuoWyquT9pXferjqvjs6EJApwTUabIzwXH0BCElDEPC(K3tjy3hsqkqWlt4BN3U678bS58w68s58wacFE09DikqmVKqAfEcGDyWY4AW48KJCopXmR4q6fyY7Tcj9TYM8EGLeC7ZlKq5OVH8Q2CEPDEPr1gr6I28rvmHRzYomyn0pMN1XCOggtGieNrsOaFJIOYzI1DP8vaurv(kaQsKW1mD(HHZR0pMN1XCOsIj8CHlYhvdrs3Bu5cl4makxBRISQnu5cxKFqAbqn59uc29HeKcnTaS9WgWgQ2)rkX1tI6ppGkNjkFfavSr5aWGOA7FIliIsGQsK09g1K3tjy3hsqkqWlt4BN3U678w8MZBPZBGMvCEEgHMczLfZg4DcN3oNFdvBePlAZhvg5yAwtN0qaQHXeicXzKekW3OiQCMyDxkFfavuLVcGA4YX0oV2jne48svjnQKycpx4I8r1qK09gvUWcodGY12QiRAdvUWf5hKwautEpLGDFibPqtlaBpSw8gQ2)rkX1tI6ppGkNjkFfavSr5afgevB)tCbrucuvIKU3OkYJbdHKwabE7oVLope(8O77quyhsdijK3taSdd2MjWcIZZwUS5NOAJiDrB(OMqzsdSaJHLe9BirnmMarioJKqb(gfrLZeR7s5RaOIQ8vau5cLjnWcmgNpqOFdPZlvL0OYfwWzauU2wfzvBOA)hPexpjQ)8aQCMO8vauXgLjddIQT)jUGikbQkrs3Buf5XGHqslGaVDN3sNxkNpoTqcLjnWcmgws0VHuOPeHOVvNNCKZ5jMzfhsVqcLjnWcmgws0VHuiHYrFJZBNZxjeGZtoY58s58wacFE09DikSdPbKeY7ja2HbBZeybX5zlx28tN3sN3c9TGVfSEntiPVvwtpzra(tCbrNxANxAuTrKUOnFuzoKw03kR46mnQHXeicXzKekW3OiQCMyDxkFfavuLVcGA4nKw03QZlX6mTZlvL0OYfwWzauU2wfzvBOA)hPexpjQ)8aQCMO8vauXgLjFXGOA7FIliIsGQsK09gvliYJbdHKwabE7oVLoVfKQVf8TG1Rzcj9TYA6jlcWFIliAPfKIyMvCi9cjuM0alWyyjr)gsHekh9n2vJCKl59GDbwAPDElD(K3doVDoF9q1gr6I28rDex0gYRbudJjqeIZijuGVrru5mX6Uu(kaQOkFfavlI4I2qEnGkjMWZfUiFunejDVrLlSGZaOCTTkYQ2qLlCr(bPfa1K3dgHMwa2EydSJ8bv7)iL46jr9NhqLZeLVcGk2OSfJbr12)exqeLavLiP7nQjVNsWUpKGuGGxMW32vFY2q1gr6I28rLroMM10jneGAymbIqCgjHc8nkIkNjw3LYxbqfv5RaOgUCmTZRDsdboVu1KgvsmHNlCr(OAis6EJkxybNbq5ABvKvTHkx4I8dslaQjVNsWUpKGuOPfGThwY2q1(psjUEsu)5bu5mr5RaOInkxTHbr12)exqeLavLiP7nQs589TGVfSEntiPVvwtpzra(tCbrN3sNNyMvCi9cjuM0alWyyjr)gsHekh9nop5581Z5T05jMzfhsVGycxZKDyWAOFmpRJ5esOC0348258vBoV0oVLoFY7bNN8C(aq1gr6I28rLroMM10jneGQ9FKsC9KO(ZdOkFfa1WLJPDETtAiW5LQ2jnQCHfCgaLRTvrw1gQCbZWljadgeBujXeEUWf5JQHiP7nQCHlYpiTaOsmZkoKEHektAGfymSKOFdPqcLJ(gN3I681dBuUQcdIQT)jUGikbQkrs3BuLY5f5XGHG1Rzcj9TYA6jlcM(ic58135R2CElDEIzwXH0liMW1mzhgSg6hZZ6yoHekh9noVDoFvaoV0OkFfa1WLJPDETtAiW5LQMO0OAJiDrB(OYihtZA6Kgcq1(psjUEsu)5bu5cMHxsagmi2OYfwWzauU2wfzvByJYv1WGOA7FIliIsGQsK09gvliYJbdHKwabE7oVLoVuoVf6BbFly9AMqsFRSMEYIa8N4cIop5iNZlLZtmZkoKEHektAGfymSKOFdPqcLJ(gN3oNVMZtoY58jVhCE7C(a78s78sJQnI0fT5J6iUOnKxdOggtGieNrsOaFJIOYzI1DP8vaurv(kaQweXfTH8AW5LQsAujXeEUWf5JQHiP7nQCHfCgaLRTvrw1gQCHlYpiTaOM8EWi00cW2dBaOA)hPexpjQ)8aQCMO8vauXgLRQhgevB)tCbrucuvIKU3OsmZkoKEbXeUMj7WG1q)yEwhZjKq5OVX5TZ5RcW5T05tEpLGDFibPabVmHVDEYR(opzBoVLoFY7bNN8C(aJQnI0fT5JkZjF2Hblj63qIAymbIqCgjHc8nkIkNjw3LYxbqfv5RaOgEt(o)WW5de63qIkjMWZfUiFunejDVrLlSGZaOCTTkYQ2qLlCr(bPfa1K3tjy3hsqkW4wldBpSKTHQ9FKsC9KO(ZdOYzIYxbqfBuUkWyquT9pXferjqvjs6EJkXmR4q6fet4AMSddwd9J5zDmNqcLJ(gN3oNVkauTrKUOnFuzKJPznDsdbOggtGieNrsOaFJIOYzI1DP8vaurv(kaQHlht78AN0qGZlv9KgvUWcodGY12QiRAdv7)iL46jr9NhqLZeLVcGk2OCvayquT9pXferjqvjs6EJkXmR4q6fet4AMSddwd9J5zDmNqcLJ(gN3oNVAdvBePlAZh1ektAGfymSKOFdjQHXeicXzKekW3OiQCMyDxkFfavuLVcGkxOmPbwGX48bc9BiDEPQjnQCHfCgaLRTvrw1gQkZHeNjszqH0GIOA)hPexpjQ)8aQCMO8vauXgBuvIKU3OInI]] )

    storeDefault( [[SimC Frost: bos ticking]], 'actionLists', 20170531.211500, [[dm0kyaqikvAtkrJIOYPiknlPIClGu0Ui0WaLJbQwMe1ZactdivxJiPTbKsFJi14asuNJsvToGe08ucDpPIAFajDqjIfsu1djsmrGeQlkvyJajIrsPkNujyLaPWnLkTtj8tGeYqbsKwQu1tPAQukBLOOVsuyVO(RcdMuhgQftjpwrtgWLvTzL0NPOrduNgXRbIMTsDBq2TWVHmCcooLkA5IEUKMosxxkBxI03PW5jI1dKaZNsf2pjZWzBS3rGT2hGTy3f(KG3eqbykbfCrzPcN9cm0z3jqsrPbLKOkfuOsBHQknLmbjjmzhu8xXTnLLN9(VpUEUOmm4sdtQWKwSCzyWGjv27pgqInc0zpBbzoeqgpfxX7DDqrJY2VtkTvBDveClmFscZr2IpmowafI5HWKOYEjtkbfv2gxaNTXEhb2AFawE29zseOSBxaevCnrv6y9L(uKsMGKeMSBa(r)XasyVotIaL9fcaYetrj7bko7DraYeNfyOZo7Lyr2eQe2bJm2KWCyTXvk7fyOZU9qgBsyQ0YVXvk7LKMv2P4080bzTZ2farfxtuLowFPpfPKjijHj79FFC9CrzyWLgom27pgqInc0zharfxtuLowFPpfZdHjrLDPa(tq2fv6HEqzl27IakWqNDMYfLzBS3rGT2hGLNDFMebk7zliZHaY4P4SL5dQsdQDwPbbmLEPslNsB1wxftc0fBck9sL(2zJiiCarHN1x6tCm)aToOG)4wOyaHtQKuPLL9sSiBcvc75Hqz97xRddsqFYUua)ji7Ik9qpOSf7DraYeNfyOZo7fyOZE)Hqz97xRkTmib9Pslhww2na)O)yajSxNjrGYE)3hxpxuggCPHdJ9(JbKyJaD2ZwqMdbKXtrkb6dkAacySVqaqMykkzpqXzVlcOadD2zkxac2g7DeyR9by5z3NjrGYE2cYCiGmEkoBz(GQ0GANvAqatPxQ0u8(bv0etb)KeMJkfLqIpWw7dO0lvAaevmpekRF)ADyqc6tX8qysuv6f7SsBobyVelYMqLWEEiuw)(16WGe0NSVqaqMykkzpqXzVadD27pekRF)AvPLbjOpvA5SKL9(VpUEUOmm4sdhg79hdiXgb6SNTGmhciJNIuc0hu0aeW6KsdGOI5Hqz97xRddsqFkMhctIQsdAQ0Mta27Ff1Y5RSnMYUb4h9hdiH96mjcuMYfGoBJ9ocS1(aS8S7ZKiqz3QTUkMeOl2eu6LkD2cYCiGmEkoBz(GQ0GANvAqaJ9sSiBcvc7GrgBsyoS24kLDPa(tq2fv6HEqzl27IaKjolWqND2lWqND7Hm2KWuPLFJRuLwo4yzz3a8J(JbKWEDMebk79FFC9CrzyWLgom27pgqInc0zpBbzoeqgpfPeOpOObiGX(cbazIPOK9afN9UiGcm0zNPCHuzBS3rGT2hGLNDFMebk7wT1vXKaDXMGsVuPLtPZwqMdbKXtXzlZhuLgu7SsxgMsVuPRNoSqrRksjpHB)bOlmvAqvPHP0YYEjwKnHkHDWiJnjmhwBCLY(cbazIPOK9afN9cm0z3EiJnjmvA534kvPLdULSS3)9X1ZfLHbxA4WyV)yaj2iqN9SfK5qaz8uKsG(GIgLHXUb4h9hdiH96mjcu27Ff1Y5RSnMYuUa0Y2yVJaBTpalp7(mjcu2ZwqMdbKXtXzlZhuLEXoR0slvL2oSdLoBXvAqvPbb7Lyr2eQe2rwBc9jME2Lc4pbzxuPh6bLTyVlcqM4SadD2zVadD2bfzTj0Ny6z3a8J(JbKWEDMebk79FFC9CrzyWLgom27pgqInc0zpBbzoeqgpfxX7DDqrdPLANu6SfVksjqFqrdqN9fcaYetrj7bko7DrafyOZot5cPzBS3rGT2hGLNDFMebk7wT1vXKaDXMGsVuPVD2icchqu4z9L(ehZpqRdk4pUfkgq4KkjzVelYMqLWEEiuw)(16WGe0NSlfWFcYUOsp0dkBXExeGmXzbg6SZEbg6S3Fiuw)(1QsldsqFQ0Ybhll79FFC9CrzyWLgom2xiaitmfLShO4S3fbuGHo7mLlaLzBS3rGT2hGLNDFMebk7u8(bv0etb)KeMJkfLqIpWw7dO0lvA5uAaevmpekRF)ADyqc6tX8qysuv6f7SsBobuA7WouA7cGOI5Hqz97xRddsqFksjtqsctLww2lXISjujSNhcL1VFTomib9j7leaKjMIs2duC2lWqN9(dHY63VwvAzqc6tLwo4wYYE)3hxpxuggCPHdJ9(JbKyJaD2bquX8qOS(9R1HbjOpfZdHjrvPbnvAZja7gGF0FmGe2RZKiqzV)vulNVY2ykt5c7Z2yVJaBTpalp7(mjcu2TARRIjb6InbLEPsNTGmhciJNIZwMpOknO2zLgeWyVelYMqLWoyKXMeMdRnUszxkG)eKDrLEOhu2I9UiazIZcm0zN9cm0z3EiJnjmvA534kvPLRSSSBa(r)XasyVotIaL9(VpUEUOmm4sdhg79hdiXgb6SNTGmhciJNIuc0hu0aeWyFHaGmXuuYEGIZExeqbg6SZuUaom2g7DeyR9by5z3NjrGYE2cYCiGmEkoBz(GQ0lQ0sdtPxQ021QTUkcUfMpjH5iBXhghlGcXMGsVuPZwCLErLwQSxIfztOsyhmkJbADyqc6t2Lc4pbzxuPh6bLTyVlcqM4SadD2zVadD2ThkdLgTQ0YGe0NSBa(r)XasyVotIaL9(VpUEUOmm4sdhg79hdiXgb6SB1wxfb3cZNKWCKT4dJJfqHyEimjQDsPZwqMdbKXtXv8Exhu0qAySVqaqMykkzpqXzVlcOadD2zkxahoBJ9ocS1(aS8S7ZKiqzNImn3xCIqBaKruv6LkTCk9TZgrq4aItuu6tZhZpqRJvm9vLEPsBxR26Qi4wy(KeMJSfFyCSakeBck9sLoBXv6fv6Yk9sLoBbzoeqgpfNTmFqv6fvAqatPLvbAOanyVelYMqLWo4wy(KeMJSfFyCSakyxkG)eKDrLEOhu2I9UiazIZcm0zN9cm0z3ETW8jjmv6(wCLwghlGcLwoSSSBa(r)XasyVotIaL9(VpUEUOmm4sdhg79hdiXgb6SNTGmhciJNIR49UoOOrz73jL2QTUkcUfMpjH5iBXhghlGcX8qysuzFHaGmXuuYEGIZExeqbg6SZuUaEz2g7DeyR9by5z3NjrGYofzAUV4eH2aiJOQ0lvA5u6BNnIGWbeNOO0NMpMFGwhRy6Rk9sL2UwT1vrWTW8jjmhzl(W4ybui2eu6LkD2IR0lQ0Lv6LkTCkD2cYCiGmEkoBz(GQ0lQ0sdtPxQ0u8(bv0etb)KeMJkfLqIpWw7dO0YQ0YYEjwKnHkHDWTW8jjmhzl(W4ybuW(cbazIPOK9afN9cm0z3ETW8jjmv6(wCLwghlGcLwolzzV)7JRNlkddU0WHXE)XasSrGo7zliZHaY4P4kEVRdkAaATFNuAR26Qi4wy(KeMJSfFyCSakeZdHjrLDdWp6pgqc71zseOS3)kQLZxzBmLPCbCqW2yVJaBTpalp7(mjcu2PitZ9fNi0gazevLEPslNsF7SreeoG4efL(08X8d06yftFvPxQ021QTUkcUfMpjH5iBXhghlGcXMGsVuPZwCLErLUSsVuPLtPP49dQiyugd06WGe0NIpWw7dO0lvAkE)GkAIPGFscZrLIsiXhyR9bu6LkD2cYCiGmEkoBz(GQ0lQ0svQkTSkTSSxIfztOsyhClmFscZr2IpmowafSVqaqMykkzpqXzVadD2TxlmFsctLUVfxPLXXcOqPLBkl79FFC9CrzyWLgom27pgqInc0zpBbzoeqgpfxX7DDqrdPk1oP0wT1vrWTW8jjmhzl(W4ybuiMhctIk79VIA58v2gtz3a8J(JbKWEDMebkt5c4GoBJ9ocS1(aS8S7ZKiqzNImn3xCIqBaKruv6LkTCknfVFqfZwqMdmL(OHPeui(aBTpGsVuPZwqMdbKXtXzlZhuLErLgeWu6LkTDTARRIGBH5tsyoYw8HXXcOqSjO0lv6SfxPxuPlR0YYEjwKnHkHDWTW8jjmhzl(W4ybuWUua)ji7Ik9qpOSf7DraYeNfyOZo7fyOZU9AH5tsyQ09T4kTmowafkTCWLLDdWp6pgqc71zseOS3)9X1ZfLHbxA4WyV)yaj2iqN9SfK5qaz8uCfV31bfnkB)oP0wT1vrWTW8jjmhzl(W4ybuiMhctIk7leaKjMIs2duC27IakWqNDMYfWLkBJ9ocS1(aS8S7ZKiqzNImn3xCIqBaKruv6LkTCkD2cYCiGmEkoBz(GQ0lQ0GqQk9sL2UwT1vrWTW8jjmhzl(W4ybui2eu6LkD2IR0lQ0WvAzzVelYMqLWo4wy(KeMJSfFyCSakyxkG)eKDrLEOhu2I9UiazIZcm0zN9cm0z3ETW8jjmv6(wCLwghlGcLwUYYYUb4h9hdiH96mjcu27)(465IYWGlnCyS3FmGeBeOZE2cYCiGmEkUI376GIgGa07KsB1wxfb3cZNKWCKT4dJJfqHyEimjQSVqaqMykkzpqXzVlcOadD2zkxah0Y2yVJaBTpalp7(mjcu2PitZ9fNi0gazevLEPslNsNTGmhciJNIZwMpOk9IkDzPQ0lvA7A1wxfb3cZNKWCKT4dJJfqHytqPxQ0zlUsVOsxwPLL9sSiBcvc7GBH5tsyoYw8HXXcOGDPa(tq2fv6HEqzl27IaKjolWqND2lWqND71cZNKWuP7BXvAzCSakuA5aHSSBa(r)XasyVotIaL9(VpUEUOmm4sdhg79hdiXgb6SNTGmhciJNIR49UoOOrzqVtkTvBDveClmFscZr2IpmowafI5HWKOY(cbazIPOK9afN9UiGcm0zNPCbCPzBS3rGT2hGLNDFMebk7uKP5(IteAdGmIQsVuPLtPZwqMdbKXtXzlZhuLErLUmmLww2lXISjujSFibKXZr2IpmowafSlfWFcYUOsp0dkBXExeGmXzbg6SZEbg6S3bKaY4Ps33IR0Y4ybuWUb4h9hdiH96mjcu27)(465IYWGlnCyS3FmGeBeOZE2cYCiGmEkUI376GIgWTp7leaKjMIs2duC27IakWqNDMYfWbLzBS3rGT2hGLNDFMebk7u8(bv0etb)KeMJkfLqIpWw7dyh2HDRNoSqrRksjpHB)bOlmbvySxIfztOsyppekRF)ADyqc6t2Lc4pbzxuPh6bLTyVlcqM4SadD2zVadD27pekRF)AvPLbjOpvA5kll7gGF0FmGe2XnkI9(VpUEUOmm4sdhg79hdiXgb6SZ(cbazIPOK9afN9UiGcm0zNPCbC7Z2yVJaBTpalp7(mjcu2ZwqMdbKXtXzlZh0fbbm2lXISjujSNhcL1VFTomib9j7leaKjMIs2duC2lWqN9(dHY63VwvAzqc6tLwUEqPGaMSS3)9X1ZfLHbxA4WyV)yaj2iqN9SfK5qaz8uCfV31bfnaH9zV)vulNVY2yk7gGF0FmGe2RZKiqzktz3NjrGYotzga]] )


    storeDefault( [[IV Frost BoS: default]], 'actionLists', 20170531.211500, [[dqZAdaGEqjTjKk7IqVguQ9bkMnsMpsv3erLBtP2jrTxODRY(LYOquAyuYVvAWs1WLuhKcCkKchtswiOAPiYIjYYf9usldepNktLcnzatx4IiLUmQRJWgLaBvcAZe0Pv1JbAwif9zkQVtroSIZlHgni9ncCsjQ)svxdrX9KipdrvRJc6qGsmwHgrL2BKOyaucvfm)6avu1Ag8hQhwN43dLHqMkujXu84yugIvLalYqElXkujXdqrJVnJAsCpOVEnXPy82SpwValA26jXXoX4TzFSEiOAay875qJOCfAevAVrIIbq4Okp2mQWtEcOT(kS11)aYX86guvW8RdutI7b91RjofbjYKVO1HPuRlWQ1PR1tIJBDyk16qq1aPN6JIOkL8eq9RqV7pGCmVUbvsmfpogLHyvjOYc1YhWdoXMOE7XOsIhGIgFBg1K4EqF9AItX4TzFSEbw0S1tIJDIXBZ(y9qq1eu(iXdqruDG5xhyGYqqJOs7nsumachv5XMrLeX16WtEcOOQG5xhOcSHOuYta1Vc9U)aYX86gX4bH9FMPNEYcUlfWA6eLsEcO(vO39hqoMx3iMS98NRKfDjX9G(61eNIGezYxatjbw0r2K4yykbHE6Liekumz7nDmf7CEt)fCksutxsCmmLQObnqLetXJJrziwvcQSqT8b8GtSjQ3EmQgi9uFue1K48dy875PExGk5wa5XMrTCHTEb56Iwh(Qg26sjpbumqzYJgrL2BKOyaeoQYJnJkjIR1L3whEYtafvfm)6avybydrPKNaQFf6D)bKJ51nIXdc7)mJkjMIhhJYqSQeuzHA5d4bNytuV9yunq6P(OiQjX5hW43Zt9UavYTaYJnJA5cB9cY1fTo8vnS1VT1LsEcOyGbQYJnJA5cB9cY1fTo8vnS1byHdbvGbI]] )

    storeDefault( [[IV Frost BoS: breath]], 'actionLists', 20170531.211500, [[dqJLeaGEkj1MOKAxQW2abTpquZMIBdODcQ9kTBQ2Vk1prQQggj9BedLssgmadNGdksDms1cjLwQkzXe1YfEkQLrkEosoTIPsKMmjMUsxuK8yrDzORd0gbb2kLeTzv0Hv15PeFfPktJscZdezKGqpdKA0IWFj0jfrFdPCnqY9qQ8Dk1NjI1HuvU6vA5u(lBqLkxMZXiSLlZcyEEZy1)oeVWAGsV8fAWNclSgvDAQqbT6HE5l8vSiDaILdqFYIceBmooFJHsCjIqRwoDEhItvPfwVslNYFzdQuTL5CmcB5YxObFkSWAu1PPRwoPRm5FjrzN4yz4hiw(cbsck0Guu3aO34lgLtlpMzTuoqGKGcnifLO94lgDlSMkTCk)LnOs1wMZXiSLlFHg8PWcRrvNMUA5KUYK)LeLDIJLHFGyzRAmMpUbqoVbabbHAlNwEmZAPSWymFisofpdc12TWqxPLt5VSbvQ2YWpqSS2a)nXnaY5naECL4LqO(YxObFkSWAu1PPRwoPRm5FjrzN4yzohJWwoaDeY0PBDa6twuGyJXrgmc0xithn1Uf2kQ0YP8x2GkvBzohJWwwg888igG4bOG1YGNNhjaDjymUeXa0rrB8fi(HcX2Toa9jlkqSX4idgb6lKPdAOkFHg8PWcRrvNMUA5KUYK)LeLDIJLHFGyzisSnJl5gGwZtTLtlpMzTuobX2mUerzZtTDlmuvA5u(lBqLQTmNJrylhG(Kffi2yCKbJa9fs0rdQYxObFkSWAu1PPRwoPRm5FjrzN4yz4hiwM(LnZIXVy50YJzwlLjYMzX4xSBHHWkTCk)LnOs1wMZXiSLdqFYIceBmoYGrG(cj6ObL1YGNNhjaDjymUeXa0rrB8fi(HcX2lFHg8PWcRrvNMUA5KUYK)LeLDIJLHFGyzisc)ga58ga9gFXOCA5XmRLYjiHlsofThFXOBHPvPLt5VSbvQ2YCogHTCa6twuGyJXrgmc0xirh0QLHFGyzic6sWyCj3aUaD8ga9WxG4LVqd(uyH1OQttxTCA5XmRLYjaDjymUeXa0rrB8fiE5KUYK)LeLDIJLVWxXI0biwoa9jlkqSX448ngkXLicTAz7eOFHVILYu5ye2UDld)aXYjTYBaqqqO2BaAjm9DdqoWFt0Tf]] )

    storeDefault( [[IV Frost BoS: no breath]], 'actionLists', 20170531.211500, [[dyZbeaGEss1UqITrsO9jvLzJQBlQ2Pk2l1UvSFP4NKK0WqPFdCyvnyP0WbPdkIofjvogO(gISqKYsrQwSkTCLEgjv9uOLHOwhjbNxumvsyYOy6cxuK6AIqxM46IGnkvvBLKeBgjTDsI8ye(kjftJKu(ojAKsv8CsnAq4qKe1jfjFwu60sUNuL(Ru51GOrrsPnSvym98xUW4RXZNlgtPknT9VaD00sdGQqt7aAAVR8begPlC51IpKzHjXMO6zPaBeHke1Zlv)Jcm(qoryJjjIcmARWhyRWy65VCHX0mIeBbnmAKUWLxl(qMfMemRXudtr8bynoGrmE(CXiDjhSAHlADtRAQjK1yYBXRiJXvYbRw4Iw3PSMqwh(q2kmME(lxymnJiXwqdJQmdiOqDb6OJQOsYsjkciRjRr6cxET4dzwysWSgtnmfXhG14agX45ZfJ9auYRjBtln(RdJjVfVImgHaOKxt2Ul)1HdFuVvym98xUWyAgrITGgg3eMIOdkqPSuisyxzI(6LeRr6cxET4dzwysWSgtnmfXhG14agX45ZfJ9VaD00IXwqkgtElEfzmsDb6OthBbP4WhvZkmME(lxymnJiXwqdJ3eOsLYw5cLeGAKUWLxl(qMfMemRXudtr8bynoGrmE(CXypaL8AY20sJ)6OPvT0RCrDgtElEfzmcbqjVMSDx(Rdh(KOvym98xUWyAgrITGggnsx4YRfFiZctcM1yQHPi(aSghWigpFUyuvV8kK9dXyYBXRiJrWLxHSFio8rfTcJPN)YfgtZisSf0WibaWzakhk3v(aIoa1oDnm7NfOFkRK)1O7Rx4ensx4YRfFiZctcM1yQHPi(aSghWigpFUyS)fOJMwm2csPPvTWQZyYBXRiJrQlqhD6ylifh(qYkmME(lxymnJiXwqdJeaaNbOCOCx5di6au701WSFwG(PSs(xJUVEHznsx4YRfFiZctcM1yQHPi(aSghWigpFUyShWonTaQnTQPMqwJjVfVImgHaSthGANYAczD4WisSf0WOdBa]] )


    storeDefault( [[Unholy Primary]], 'displays', 20170531.211500, [[dWd5gaGEfPxIi1UukQETIOzQimBfEmkDtKk(TQUTsAAkLStQSxXUjSFIQFQedtsgNsP0HLAOOYGjkdhHdkrNMuhtsDoLs1cLWsjrTysA5u6HufpfSmQsRdrstuPitfktgfnDvUOI6QOGld56izJKWwvkfBMiBhr9rLcpdrIpRu9DQQrIuPNtXOHQXJiojs5wKiDnuOZJQ(gjI1QuuoosvN6GfGTjo9lu8Ido(bkWcdytqZnhGTjo9lu8Id0trXv7nGTf7ip4i2jtra1HE60ngVFudWVijzqNNM40VWexvaswKKmOZttC6xyIRka9uiketASVa0trXTvvGvTOCoosja9uiketpnXPFHjfb4xKKmOdRT7OZexvad(7d(6JfVCofbm4VFj19PiGM9farZQf7XXyGRT7ORuWI)2aflyyl0rzABqxSa8rHs32TReVv1mUv92z0lPuPKQiP0Tyma)IKKbDKUWeNsRdyWFFS2UJotkcmPAPGf)TbWw4uM2g0flGwWuZ23BlfS4VnGY02GUybyBIt)Isbl(BduSGHTqNaabIv3d90(0VioVm6nGb)9bSueGEkefAtAlI90ViGY02GUybeuR0yFHjUTcyiqJHIrBW98J3gSaDC1buJRoWEC1bSXvNlGb)990eN(fMOgGKfjjd6kPSDCvbAkBJXtGcOsjjfyTjPK6(4QcOo0tNUX49lhJOgOhe4nG)(CKNJRoqpiWBp)QAFCKNJRoWMqsn14srGE438goYCPiazTrRQh6JhJNafqnaBtC6xuo07IaEMDyZkhGP2qmAEmEcuaMbSTyhHXtGc0Q6H(4d0u2MoAbkfbMuvXloqpffxT3a9GaVXA7o64iZfxDalAeWZSdBw5agc0yOy0g8OgOhe4nwB3rhh554QdqpfIcXKMGPMTV3AsrappbVCzyFage4)GxUSYL5aRArj19Xvf4A7o6u8Ido(bkWcdytqZnhGjsQPgxj3eba9Qh5YyqG)dEsvUmMiPMACbijUQag83h81hlEj19PiqpiW7YHFZB4iZfxDan7l2S)xJRMXaew9AB5v8Id0trXv7naHfX(RQ9vYnraqV6rUmge4)GNuLlJWIy)v1(ci9IlahMCzqlmYL5AR99dS2KuohxvacRETT80yFbONIIBRQaxB3rhh55OgGEkefQCO3fRiXfGnGYObQnO48wvRKkgRuYM71BvvfJbizrsYGoAcMA2(ERjUQa8lssg0rtWuZ23BnXvf4A7o6u8IlahMCzqlmYL5AR99dqYIKKbDyTDhDM4QcyWF)skBtti9rnGb)9PjyQz77TMueGFrsYGUskBhxvGE438goYZPiGb)95ipNIag83VCofby)v1(4iZf1anLTbc0yqBtXvfOPSDPGf)TbkwWWwOZeZkWc0u2MMq6X4jqbuPKKcSQfawCvbU2UJofV4a9uuC1EdqpLMDYTrBGJFGc0byBIt)cfV4cWHjxg0cJCzU2AF)a9GaV98RQ9XrMlU6aZIwDGyMIag9kXavUmhN3atQQ4fxaom5YGwyKlZ1w77hOhe4D5WV5nCKNJRoa7VQ2hh55Og4A7o64iZf1ag83N0iEvTGPwSBsrad(7ZrMlfbwBsaS4QdqYIKKbDKUWexDGEqG3a(7ZrMlU6a0tHOqmv8Id0trXv7nWKQkEXbh)afyHbSjO5MdqpfIcXK0fMueW1ROamiW)bVCzCw9AB5d0u2MbH(cqmAEKnxca]] )

    storeDefault( [[Frost Primary]], 'displays', 20170531.211500, [[dWd4gaGEf4LiPSlvc1RLOAMsuMTIEmkDtKu9BvDBvyAQeTtQSxXUjA)KOFQIgMKACij0HLAOOyWKKHJWbLKttQJrvDoKKAHuLLsszXuYYP4HsKNcwMcADijzIQemvOmzKQPR0fvORsc5YqUoI2Ok1wrsWMrvBhj(ijvpdjrFgQ8DjmsKIEoHrJkJxL0jHQUfjuxJeCEk13qkSwvc54iLo(blaBtS6xE)Yfw7jkWPIWkdVBmaBtS6xE)Yf0dqX5pmGPL4qL4qSLhVawt9GbQp)I4fW(KNxG2snXQFPiU6axp55fOTutS6xkIRoaTKiseD8SVe0dqXDzDGdTSAmoQmaTKise9snXQFPiEbSp55fOfRn4qRiU6acUVak0llx1y8ci4(IkY9Jxan7lbIMvlXfNcb22GdTvswU3eW7ed7K6QHxDAIfWo3kMks10yyTVcx6t1kmKkRPrD4v8LkeW(KNxGwQ5jItX(beCFbwBWHwr8cuUvLKL7nbWozudV60elGwsxZ27BQKSCVjGA4vNMybyBIv)Ykjl3Bc4DIHDs9aabIv3t9GE1VmUHk4hqW9faw8cqljIeDbTbXU6xgqn8QttSasYd8SVue3LbeeO58E2cUs)8nblqhNFaR48dGlo)aM48ZgqW9fLAIv)srScC9KNxG2ksthxDGM00y2eOawK88bo6RvK7hxDaRPEWa1NFr1CgRa9KGRbUVGHYyC(b6jbxx6pS6LHYyC(bUaIVjNB8c0ZI2wWqHjEbOOfAl9uV2y2eOawbyBIv)YQPgNmqPrh2OAbORfeZ2gZMafGEatlXHWSjqbAl9uV2bAsttDTefVaLBD)Yf0dqX5pmqpj4AS2GdTmuyIZpGbnduA0HnQwabbAoVNTGlwb6jbxJ1gCOLHYyC(bOLerIOJxsxZ27BeXlqPNWwPkSpWT5fRsvvNJbo0YkY9JRoW2gCO9(LlS2tuGtfHvgE3ya6i(MCUvmLfa0hLuQ628ILQuQIoIVjNBGRXvhqW9fqHEz5Qi3pEb6jbxxnlABbdfM48dOzF5f9)rC(keGWOpAJ99lxqpafN)Waege7Fy1Bftzba9rjLQUnVyPkLQimi2)WQ3a8VCdWGPuf0sHsvU2y(Iah91QX4Qdqy0hTXgp7lb9auCxwhyBdo0YqzmwbOLerIQMACYdKCdWgqW9fmuyIxGRN88c0IxsxZ27BeXvhW(KNxGw8s6A2EFJiU6aBBWH27xUbyWuQcAPqPkxBmFrGRN88c0I1gCOvexDab3xurAA8s(pwbeCFbEjDnBVVreVa2N88c0wrA64Qd0ZI2wWqzmEbeCFbdLX4fqW9fvJXla7Fy1ldfMyfOjnnqGMt8xiU6anPPRKSCVjG3jg2j1lB8glqtAA8s(hZMafWIKNpWHwcyXvhyBdo0E)Yf0dqX5pmaTKA2YPcAbS2tuGoaBtS6xE)YnadMsvqlfkv5AJ5lc0tcUU0Fy1ldfM48dmkBRjIE8ci0hetu15yCdduU19l3amykvbTuOuLRnMViqpj46QzrBlyOmgNFa2)WQxgkJXkW2gCOLHctSci4(cQHST0s6Ajor8cOgAIAbkUH1(0OwHAACXdhwxxRqGJ(kGfNFGRN88c0snprC(b6jbxdCFbdfM48dqljIer)(LlOhGIZFyGYTUF5cR9ef4uryLH3ngGwsejIo18eXlGRpqbUnVyvQIXOpAJDGM00ksQ3aeZ2gzYMa]] )

    storeDefault( [[Unholy AOE]], 'displays', 20170531.211500, [[dOJZgaGEPsVeLODPOs9APIMPuHzlLBIs42kPhJIDsP9k2nQ2pP4Nk0WuKFRQJPGHsObtKgochKknnfvCyjhhL0cvILsQyXi1YPQhsQ6PGLPO8CkMikvnvLAYeX0v5IsvxfLYLHCDKSrsPTcvf2mrTDe1hjv6zqvrFgQ8DQyKOu50KmAOmEOkNerUfuv6AkQ68eSoOQYAvujFdQQ6mKDaMI4upx7Zp4eAOaJST7GKTpatrCQNR95hO6IIDywaFXXH0JHy6mlbyLcrHCBkC8ve)cWeqyuw2Go9fXPEUj2Pa4nklBqN(I4up3e7uacVAT8cKyEoO6IIDotbwvC3(yXNbyLcrHKOVio1ZnzjGWOSSbD7YJdDMyNcyWEhWrDmyU9HoGb7DCPUp0bmyVd4OogmxQ7ZsGR84qNlNb79bwg37rwOdjDz3oGqS47SHPa4f7uad27Slpo0zYsGoPD5myVpWEuuhs6YUDafxIIPU37YzWEFaDiPl72bykIt9Cxod27dSmU3JSiaqGyuvt1To1ZJD28ZcyWEhyNLaSsHOqSx5rmN65b0HKUSBhGtTsI55MyNtadbQ102kdM(V9(SduXoeWh7qaCXoeGo2HCbmyVJ(I4up3e6a4nklBqNlLVIDkqr5RTabkanLSCG1cpxQ7JDkaDt1TRUT3XT1cDGQrGva27isUp2HavJaR0)R01jsUp2HaShjxuTllbQMtjyejlMLaKvgfTQPoHTabkaDaMI4up3TPWXdOV3U71jGeLHOvcBbcuaMa(IJdTfiqbkAvtDcbkkFXcfhLLaDsR95hO6IIDywGQrGv7YJdDIKfJDiGh1cOV3U71jGHa1AABLbl0bQgbwTlpo0jsUp2HaSsHOqsiXLOyQ79MSeq)tiOr6(dWgh7BcAK6o2hWwROaSXX(MGgPUJ9bUYJdDAF(bNqdfyKTDhKS9bKGKlQ25k2raqTQxJu24yFta)0ivcsUOAxGoP1(8doHgkWiB7oiz7dOyEoqumkoUyNpq1iWk3Mtjyejlg7qGQrGva27iswm2HaeE1A5f0(8duDrXomlaHhX8R015k2raqTQxJu24yFta)0iLWJy(v66cG3OSSbDSCXe7qG1cp3(yNcSw4b7yhcCLhh6ej3h6agS3rKSywcOdQHkdk2ztd4)08t4)CpB20008bmyVdlrc0kUefhNjlbUYJdDIKfdDaMFLUorY9Hoq1iWk3Mtjyej3h7qGoP1(8lG4wJuO4gnsTL3)obmyVdjUeftDV3KLacJYYg05s5RyNcunNsWisUplbmyVJBFOdyWEhrY9zjaZVsxNizXqhOAeyL(FLUorYIXoeOO8LlNb79bwg37rw0rV2DawPumDIpug4eAOa0bwvCyh7uGR84qN2NFGQlk2HzbkkFrIl)BbcuaAkz5amfXPEU2NFbe3AKcf3OrQT8(3jqr5lGa1AKyFStb65fDdjjlbmQvIgYDSp2zbmyVJlLViXL)qhaVrzzd62Lhh6mXof4kpo0P95xaXTgPqXnAKAlV)DcimklBqhjUeftDV3e7ua8gLLnOJexIIPU3BIDkaDt1TRUT3j0byLcrHKqI55GQlk25mfq(5xaXTgPqXnAKAlV)DcOyE(C9)ASdZhGvkefsI2NFGQlk2HzbegLLnOJLlMyX3HaSsHOqsy5IjlbwvCxQ7JDkqr5l24QlarReq(Cja]] )

    storeDefault( [[Frost AOE]], 'displays', 20170531.211500, [[dOJYgaGEPIxIGAxsLkVwQKzsvLzROBIK42QIhJu7Ks7vSBI2pQQFQGHjv9BvoMumuuzWeYWHQdsLMgHshwYXrsTqfAPeQwmkwofpKQYtbltvYZjzIsLYuvvtgvz6kDrP0vrs6YqUoI2iuSvvPsBMGTJqFKQQEMuPQpdL(ovzKekonPgnknEe4KiXTqqCnvPCEQyDiiTwvPIVPkvDAYpaDHV6tI5KlSotuGbQ(9JITnaDHV6tI5KlO7GIT5vatjXI8XIO7kJbOMerICNASYhKCdqhWzqqqHwFf(QpPk2(aemiiOqRVcF1NufBFaCJ(PmouOpjO7GIvS9bE0s32y7(autIir88v4R(KQmgWzqqqH2FzWIwvS9buSNh4PxAw32WeqXEEUK7fMak2Zd80lnRl5EzmWwgSO1vsZEMaJd))aveNI)I5hWjwc5vtFacITpGI98(LblAvzmqxmUsA2Ze4pWjof)fZpGwYttx7zCL0SNjG4u8xm)a0f(QpPRKM9mbgh()bQeaWr06AQ7uR(KX(6TMak2Zd(zma1Kisu30ge9QpzaXP4Vy(bKKpuOpPkwXgqHJMtmZsX67MNj)avSnbmX2eaBSnbyITjBaf755RWx9jvHjabdcck06sAQy7duKM67GJcWqkie4PiWLCVy7dWm1D64)88CNZWeOM4SfWEECeBJTjqnXzlF3dtTCeBJTjq3qcf5CZyGA6vokoICzmarTsZON6157GJcWeGUWx9jDNASYa(AT)wXdWtRWNLZ3bhfGoGPKyrFhCuGIrp1RtGI0uurlrzmqxmyo5c6oOyBEfOM4S1VmyrlhrUyBcyqZa(AT)wXdOWrZjMzPydtGAIZw)YGfTCeBJTja1KisepksEA6ApJkJb8D4o8f9VaymNA5lYDOnGTEqbWyo1YxK7qBGTmyrlMtUW6mrbgO63pk22a8qcf5CD58laOF8XxegZPwcLViEiHICUb6IbZjxyDMOadu97hfBBan9jb8IwlXg7BbQjoB5o9khfhrUyBcutC2cyppoICX2ea3OFkJdMtUGUdk2MxbWni67HPwxo)ca6hF8fHXCQLq5lc3GOVhMAdqWGGGcTeEufBtGNIa32y7d8uea)yBcSLblA5i2gMaIJMOsHI9vFZ77FR)9D3Rx999VfqXEECe5Yyaf75ryKdJwYtlXQYyGTmyrlhrUWeG(EyQLJyBycutC2YD6vokoITX2eOlgmNCdW95lckPIViBzmNxaf75rrYttx7zuzmGZGGGcTUKMk2(a10RCuCeBZyaf7552gMak2ZJJyBgdqFpm1YrKlmbQjoB57EyQLJixSnbkst5kPzptGXH)FGk(1I5hGAsnDxVRwbRZefGjWJwc)y7dSLblAXCYf0DqX28kqrAkksH77GJcWqkieGUWx9jXCYna3NViOKk(ISLXCEbkstb4O5Ks3ITpqRSyMiEzmGs)GprUdTX(kGI98CjnffPWfMaemiiOq7VmyrRk2(aBzWIwmNCdW95lckPIViBzmNxaNbbbfAPi5PPR9mQy7dqWGGGcTuK8001EgvS9byM6oD8FEEzma1Kisepk0Ne0DqXk2(acNCdW95lckPIViBzmNxan9jFN7EIT5TautIir8WCYf0DqX28kGZGGGcTeEuflH0eGAsejIhHhvzmWJw6sUxS9bkstrvPEdGplhKjBca]] )


end

