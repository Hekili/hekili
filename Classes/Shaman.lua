-- Shaman.lua
-- October 2016

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
local addTalent = ns.addTalent
local addTrait = ns.addTrait
local addResource = ns.addResource
local addStance = ns.addStance

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
if (select(2, UnitClass('player')) == 'SHAMAN') then

    ns.initializeClassModule = function ()

        setClass( 'SHAMAN' )
        -- Hekili.LowImpact = true

        addResource( 'mana', SPELL_POWER_MANA )
        addResource( 'maelstrom', SPELL_POWER_MAELSTROM, true )

        if not Hekili.DB.profile.clashes.windstrike then Hekili.DB.profile.clashes.windstrike = 0.25 end

        setRegenModel( {
            mainhand = {
                resource = 'maelstrom',

                spec = 'enhancement',
                setting = 'forecast_swings',

                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                value = function( x )
                    if state.buff.doom_winds.expires > x then return 15 end
                    return 5
                end,
            },

            offhand = {
                resource = 'maelstrom',

                spec = 'enhancement',
                setting = 'forecast_swings',

                last = function ()
                    local swing = state.swings.offhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
                end,

                interval = 'offhand_speed',

                value = function( x )
                    if state.buff.doom_winds.expires > x then return 15 end
                    return 5
                end,
            },

            fury_of_air = {
                resource = 'maelstrom',
                setting = 'forecast_fury',

                spec = 'enhancement',
                talent = 'fury_of_air',
                aura = 'fury_of_air',

                last = function ()
                    local app = state.buff.fury_of_air.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                stop = function( x )
                    return x < 3
                end,

                interval = 1,
                value = -3,
            },

        } )


        -- TODO:  Decide if modeling feral_spirit gain is worth it.


        addTalent( 'windsong', 201898 )
        addTalent( 'hot_hand', 201900 )
        addTalent( 'landslide', 197992 )

        addTalent( 'rainfall', 215864 )
        addTalent( 'feral_lunge', 196884 )
        addTalent( 'wind_rush_totem', 192077 )

        addTalent( 'lightning_surge_totem', 192058 )
        addTalent( 'earthgrab_totem', 51485 )
        addTalent( 'voodoo_totem', 196932 )

        addTalent( 'lightning_shield', 192106 )
        addTalent( 'ancestral_swiftness', 192087 )
        addTalent( 'hailstorm', 210853 )

        addTalent( 'tempest', 192234 )
        addTalent( 'overcharge', 210727 )
        addTalent( 'empowered_stormlash', 210731 )

        addTalent( 'crashing_storm', 192246 )
        addTalent( 'fury_of_air', 197211 )
        addTalent( 'sundering', 197214 )

        addTalent( 'ascendance', 114051 )
        addTalent( 'boulderfist', 246035 )
        addTalent( 'earthen_spike', 188089 )


        addTalent( 'path_of_flame', 201909 )
        addTalent( 'earthen_rage', 170374 )
        addTalent( 'totem_mastery', 210643 )

        addTalent( 'gust_of_wind', 192063 )
        addTalent( 'ancestral_swiftness', 108281 )

        addTalent( 'elemental_blast', 117014 )
        addTalent( 'echo_of_the_elements', 108283 )

        addTalent( 'elemental_fusion', 192235 )
        addTalent( 'primal_elementalist', 117013 )
        addTalent( 'icefury', 210714 )

        addTalent( 'elemental_mastery', 16166 )
        addTalent( 'storm_elemental', 192249 )
        addTalent( 'aftershock', 210707 )

        addTalent( 'lightning_rod', 210689 )
        addTalent( 'liquid_magma_totem', 192222 )


        -- Traits
        -- Enhancement
        addTrait( "alpha_wolf", 198434 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "crashing_hammer", 238070 )
        addTrait( "doom_vortex", 199107 )
        addTrait( "doom_winds", 204945 )
        addTrait( "doom_wolves", 198505 )
        addTrait( "earthshattering_blows", 214932 )
        addTrait( "elemental_healing", 198248 )
        addTrait( "forged_in_lava", 198236 )
        addTrait( "gathering_of_the_maelstrom", 198349 )
        addTrait( "gathering_storms", 198299 )
        addTrait( "hammer_of_storms", 198228 )
        addTrait( "lashing_flames", 238142 )
        addTrait( "might_of_the_earthen_ring", 241203 )
        addTrait( "raging_storms", 198361 )
        addTrait( "spirit_of_the_maelstrom", 198238 )
        addTrait( "spiritual_healing", 198296 )
        addTrait( "stormflurry", 198367 )
        addTrait( "unleash_doom", 198736 )
        addTrait( "weapons_of_the_elements", 215381 )
        addTrait( "wind_strikes", 198292 )
        addTrait( "wind_surge", 198247 )
        addTrait( "winds_of_change", 238106 )

        -- Elemental
        addTrait( "call_the_thunder", 191493 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "earthen_attunement", 191598 )
        addTrait( "electric_discharge", 191577 )
        addTrait( "elemental_destabilization", 238069 )
        addTrait( "elementalist", 191512 )
        addTrait( "firestorm", 191740 )
        addTrait( "fury_of_the_storms", 191717 )
        addTrait( "lava_imbued", 191504 )
        addTrait( "master_of_the_elements", 191647 )
        addTrait( "molten_blast", 191572 )
        addTrait( "power_of_the_earthen_ring", 241202 )
        addTrait( "power_of_the_maelstrom", 191861 )
        addTrait( "protection_of_the_elements", 191569 )
        addTrait( "seismic_storm", 238141 )
        addTrait( "shamanistic_healing", 191582 )
        addTrait( "static_overload", 191602 )
        addTrait( "stormkeeper", 205495 )
        addTrait( "stormkeepers_power", 214931 )
        addTrait( "surge_of_power", 215414 )
        addTrait( "swelling_maelstrom", 238105 )
        addTrait( "the_ground_trembles", 191499 )
        addTrait( "volcanic_inferno", 192630 )


        -- Player Buffs.
        addAura( 'ascendance', 114051, 'duration', 15 )
        addAura( 'astral_shift', 108271, 'duration', 8 )
        addAura( 'boulderfist', 218825, 'duration', 10 )
        addAura( 'crash_lightning', 187874, 'duration', 10 )
        addAura( 'crashing_lightning', 242286, 'duration', 16, 'max_stack', 15 )
        addAura( 'doom_winds', 204945, 'duration', 6 )
        addAura( 'earthen_spike', 188089, 'duration', 10 )
        addAura( 'flametongue', 194084, 'duration', 16 )
        addAura( 'frostbrand', 196834, 'duration', 16 )
        addAura( 'fury_of_air', 197211 )
        addAura( 'hot_hand', 215785, 'duraiton', 15 )
        addAura( 'landslide', 202004, 'duration', 10 )
        addAura( 'lashing_flames', 240842, 'duration', 10, 'max_stack', 99 )
        addAura( 'lightning_crash', 242284, 'duration', 16 )
        addAura( 'lightning_shield', 192109, 'duration', 3600 )
        addAura( 'rainfall', 215864 )
        addAura( 'stormbringer', 201846, 'max_stack', 1 )
        addAura( 'windsong', 201898 )

        addAura( 'ancestral_guidance', 108281 )
        addAura( 'echoes_of_the_great_sundering', 208722, 'duration', 50 )
        addAura( 'elemental_blast_critical_strike', 118522, 'duration', 10 )
        addAura( 'elemental_blast_haste', 118522, 'duration', 10 )
        addAura( 'elemental_blast_mastery', 173184, 'duration', 10 )
        addAura( 'elemental_focus', 16164, 'duration', 30, 'max_stack', 2 )
        addAura( 'elemental_mastery', 16166, 'duration', 20 )
        addAura( 'emalons_charged_core', 208742, 'duration', 10 )
        addAura( 'ember_totem', 210658 )
        addAura( 'fire_of_the_twisting_nether', 207995, 'duration', 8 )
        addAura( 'chill_of_the_twisting_nether', 207998, 'duration', 8 )
        addAura( 'shock_of_the_twisting_nether', 207999, 'duration', 8 )
        addAura( 'flame_shock', 188389, 'duration', 30 )
        addAura( 'frost_shock', 196840, 'duration', 5 )
        addAura( 'icefury', 210714, 'duration', 15, 'max_stack', 4 )
        addAura( 'lava_surge', 77762, 'duration', 10 )
        addAura( 'lightning_rod', 197209, 'duration', 10 )
        addAura( 'power_of_the_maelstrom', 191877, 'duration', 20, 'max_stack', 3 )
        addAura( 'resonance_totem', 202192 )
        addAura( 'storm_tempests', 214265, 'duration', 15 )
        addAura( 'storm_totem', 210652 )
        addAura( 'stormkeeper', 205495, 'duration', 15, 'max_stack', 3 )
        addAura( 'tailwind_totem', 210659 )
        addAura( 'thunderstorm', 51490, 'duration', 5 )


        class.auras[ 114050 ] = class.auras[ 114051 ]
        modifyAura( 'ascendance', 'id', function( x )
            if spec.elemental then return 114050 end
            return x
        end )


        -- Fake Buffs.
        registerCustomVariable( 'last_feral_spirit', 0 )
        registerCustomVariable( 'last_crash_lightning', 0 )
        registerCustomVariable( 'last_rainfall', 0 )
        registerCustomVariable( 'last_ascendance', 0 )
        registerCustomVariable( 'last_totem_mastery', 0 )

        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'feral_spirit' ].name then
                state.last_feral_spirit = GetTime()
            
            elseif spell == class.abilities[ 'crash_lightning' ].name then
                state.last_crash_lightning = GetTime()

            elseif spell == class.abilities[ 'rainfall' ].name then
                state.last_rainfall = GetTime()

            elseif spell == class.abilities[ 'ascendance' ].name then
                state.last_ascendance = GetTime()

            elseif spell == class.abilities[ 'totem_mastery' ].name then
                state.last_totem_mastery = GetTime()

            end

        end )

        addAura( 'feral_spirit', -100, 'name', 'Feral Spirit', 'duration', 15, 'feign', function ()
            local up = last_feral_spirit
            buff.feral_spirit.name = 'Feral Spirit'
            buff.feral_spirit.count = up and 1 or 0
            buff.feral_spirit.expires = up and last_feral_spirit + 15 or 0
            buff.feral_spirit.applied = up and last_feral_spirit or 0
            buff.feral_spirit.caster = 'player'
        end )

        addAura( 'alpha_wolf', -101, 'name', 'Alpha Wolf', 'duration', 8, 'feign', function ()
            local time_since_cl = now + offset - last_crash_lightning        
            local up = buff.feral_spirit.up and last_crash_lightning > buff.feral_spirit.applied
            buff.alpha_wolf.name = 'Alpha Wolf'
            buff.alpha_wolf.count = up and 1 or 0
            buff.alpha_wolf.expires = up and last_crash_lightning + 8 or 0
            buff.alpha_wolf.applied = up and last_crash_lightning or 0
            buff.alpha_wolf.caster = 'player'
        end )

        addAura( 'totem_mastery', -102, 'name', 'Totem Mastery', 'duration', 120, 'feign', function ()
            local totem_expires = 0

            for i = 1, 5 do
                local _, totem_name, cast_time = GetTotemInfo( i )

                if totem_name == class.abilities.totem_mastery.name then
                    totem_expires = cast_time + 120
                end
            end

            local in_range = buff.resonance_totem.up

            if totem_expires > 0 and in_range then
                buff.totem_mastery.name = class.abilities.totem_mastery.name
                buff.totem_mastery.count = 4
                buff.totem_mastery.expires = totem_expires
                buff.totem_mastery.applied = totem_expires - 120
                buff.totem_mastery.caster = 'player'

                buff.resonance_totem.expires = totem_expires
                buff.storm_totem.expires = totem_expires
                buff.ember_totem.expires = totem_expires
                buff.tailwind_totem.expires = totem_expires
                return
            end

            buff.totem_mastery.name = class.abilities.totem_mastery.name
            buff.totem_mastery.count = 0
            buff.totem_mastery.expires = 0
            buff.totem_mastery.applied = 0
            buff.totem_mastery.caster = 'nobody'
        end )


        state.feral_spirit = setmetatable( {}, {
            __index = function( t, k )
                if k == 'cast_time' then
                    t.cast_time = state.last_feral_spirit and state.last_feral_spirit or 0
                    return t[k]
                elseif k == 'active' then
                    return state.query_time < t.cast_time + 15 or false
                elseif k == 'remains' then
                    return max( 0, t.cast_time + 15 - state.query_time )
                end

                return false
            end
        } )

        state.twisting_nether = setmetatable( {}, {
            __index = function( t, k )
                if k == 'count' then
                    return ( state.buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.shock_of_the_twisting_nether.up and 1 or 0 )
                end

                return 0
            end
        } )


        addHook( 'reset_precast', function( x )
            -- A decent start, but assumes our first ability is always aggressive. Not necessarily true...
            if state.spec.enhancement then
                state.feral_spirit.cast_time = nil 

                --[[ state.nextMH = ( state.combat ~= 0 and state.swings.mh_projected > state.now ) and state.swings.mh_projected or state.now + 0.01
                state.nextOH = ( state.combat ~= 0 and state.swings.oh_projected > state.now ) and state.swings.oh_projected or state.now + ( state.swings.oh_speed / 2 )


                local next_foa_tick = ( state.buff.fury_of_air.applied % 1 ) - ( state.now % 1 )
                if next_foa_tick < 0 then next_foa_tick = next_foa_tick + 1 end                

                state.nextFoA = state.buff.fury_of_air.up and ( state.now + next_foa_tick ) or 0
                while state.nextFoA > 0 and state.nextFoA < state.now do state.nextFoA = state.nextFoA + 1 end ]]
            end
        end )


        -- Pick an instant cast ability for checking the GCD.
        -- setGCD( 'global_cooldown' )

        -- Gear Sets
        addGearSet( 'tier20', 147175, 147176, 147177, 147178, 147179, 147180 )
        addGearSet( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
        addGearSet( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
        
        addGearSet( 'doomhammer', 128819 )
        setArtifact( 'doomhammer' )
        addGearSet( 'fist_of_raden', 128935 )
        setArtifact( 'fist_of_raden' )

        addGearSet( 'akainus_absolute_justice', 137084 )
        addGearSet( 'alakirs_acrimony', 137102 )
        addGearSet( 'deceivers_blood_pact', 137035 )
        addGearSet( 'echoes_of_the_great_sundering', 137074 )
        addGearSet( 'emalons_charged_core', 137616 )
        addGearSet( 'eye_of_the_twisting_nether', 137050 )
        addGearSet( 'pristine_protoscale_girdle', 137083 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'smouldering_heart', 151819 )
        addGearSet( 'soul_of_the_farseer', 151647 )
        addGearSet( 'spiritual_journey', 138117 )
        addGearSet( 'storm_tempests', 137103 )
        addGearSet( 'uncertain_reminder', 143732 )


        setTalentLegendary( 'soul_of_the_farseer', 'enhancement',   'tempest' )
        setTalentLegendary( 'soul_of_the_farseer', 'elemental',     'echo_of_the_elements' )


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( 'attack' )
            state.ranged = state.spec.elemental
        end )

        addHook( 'spend', function( amt, resource )
            if resource == 'maelstrom' and state.spec.elemental and state.talent.aftershock.enabled then
                local refund = amt * 0.3
                refund = refund - ( refund % 1 )
                state.gain( refund, 'maelstrom' )
            end
        end )


        ns.addToggle( 'doom_winds', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        ns.addSetting( 'doom_winds_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and Doom Winds will be shown regardless of your Doom Winds toggle.",
            width = "full"
        } )

        ns.addSetting( 'elemental_gambling', false, {
            name = "Elemental: Use Gambling Action List",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will use action lists which prioritize spending large amounts of Maelstrom quickly in an attempt to trigger Ascendance.  This requires the Smouldering Heart " ..
                "legendary to function.",
            width = "full",
        } )

        ns.addMetaFunction( 'state', 'gambling', function ()
            return spec.elemental and equipped.smouldering_heart and settings.elemental_gambling
        end )

        ns.addSetting( 'aggressive_stormkeeper', true, {
            name = "Elemental: Aggressive Stormkeeper",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will recommend Stormkeeper roughly on cooldown, encouraging you to spend the Stormkeeper stacks quickly.\n\n" ..
                "Used by the SEL Elemental Ascendance, SEL Elemental Icefury, and SEL Elemental LR (Lightning Rod) action lists.",
            width = "full"
        } )

        ns.addSetting( 'optimistic_overload', false, {
            name = "Elemental: Optimistic Overload Prediction",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Mastery value is greater than 50%, the addon will anticipate that your cast will Overload and adjust recommendations accordingly.\n\n" ..
                "Otherwise, the addon is conservative and does not try to predict Overload Maelstrom generation at all.",
            width = "full",
        } )

        ns.addMetaFunction( 'state', 'rebuff_window', function()
            return gcd + ( settings.safety_window or 0 )
        end )

        ns.addSetting( 'st_fury', true, {
            name = "Enhancement: Single-Target Fury",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not recommend Fury of Air when there is only one-enemy.  It will still budget and pool Maelstrom for Fury of Air (if talented accordingly), in case of AOE.\n\n" ..
                "Simulations for 7.2 suggest that Fury of Air is DPS neutral in single-target, meaning there is no DPS gain or loss from using it in single-target.",
            width = "full",
        } )

        ns.addSetting( 'crash_st', false, {
            name = "Enhancement: Low Priority Single-Target Crash Lightning",
            type = "toggle",
            desc = "If |cFF00Ff00true|r, a very low-priority Crash Lightning will be enabled when almost no other actions are available (in the default Enhancement action lists).  It is technically a very marginal " ..
                "DPS increase to enable this setting, but many users were confused by the Crash Lightning recommendation for single-target.",
            width = "full",
        } )

        ns.addSetting( 'forecast_fury', true, {
            name = 'Enhancement: Predict Fury of Air MP',
            type = 'toggle',
            desc = "If checked, the addon will predict Maelstrom expenditure (3 per second) from Fury of Air and factor this in to future recommendations.  This is generally reliable and conservative, as " ..
                "Fury of Air ticks are rather consistent.  However, if Fury of Air does not tick when predicted, the addon may give recommendations assuming you have less Maelstrom than you actually do.  " ..
                "The default value is |cFFFFD100true|r.",
            width = 'full'
        } )

        ns.addSetting( 'forecast_swings', true, {
            name = 'Enhancement: Predict Melee MP',
            type = 'toggle',
            desc = "If checked, the addon will predict when your next melee swings will land, generating 5 Maelstrom (or 15 if Doom Winds is active).  This is generally reliable and conservative, but " ..
                "can result in occasional recommendations that are overly optimistic about your Maelstrom income.  This can also be inaccurate if you are frequently outside of melee range of your " ..
                "target.  The default value is |cFFFFD100true|r.",
            width = "full"
        } )

        --[[ ns.addSetting( 'safety_window', 0, {
            name = "Enhancement: Buff Safety Window",
            type = "range",
            desc = "Set a safety period for refreshing buffs when they are about to fall off.  The default action lists will recommend refreshing buffs if they fall off wihin 1 global cooldown. " ..
                "This setting allows you to extend this safety window by up to 1.5 seconds.  It may be beneficial to set this at or near your latency value, to prevent tiny fractions of time where " ..
                "your buffs would fall off.  This value is checked as |cFFFFD100rebuff_window|r in the default APLs.",
            width = "full",/
            min = 0,
            max = 1.5,
            step = 0.01
        } ) ]]

        ns.addMetaFunction( 'state', 'rebuff_window', function ()
            return state.gcd + ( settings.safety_window or 0 )
        end )

        --[[ ns.addSetting( 'foa_padding', 6, {
            name = "Fury of Air: Maelstrom Padding",
            type = "range",
            desc = "Set a small amount of buffer Maelstrom to conserve when using your Maelstrom spenders, when using Fury of Air.  Keeping this at 6 or greater will help prevent your Maelstrom from hitting zero " ..
                "and causing Fury of Air to drop off.  This value is checked as |cFFFFD100foa_padding|r in the default APLs.",
            width = "full",
            min = 0,
            max = 12,
            step = 1
        } ) ]]


        ns.addMetaFunction( 'state', 'foa_padding', function ()
            return settings.foa_padding or 6
        end )

        --[[ ns.addSetting( 'boulderfist_maelstrom', 100, {
            name = "Maelstrom: Boulderfist",
            type = "range",
            desc = "Set a |cFFFF0000maximum|r amount of Maelstrom for the Boulderfist ability (if talented) in the default action lists.  This is useful if you are concerned with wasting Maelstrom by using Boulderfist when some/all of the Maelstrom it would generate would be wasted.\n\n" ..
                "The addon default is 100, but is ignored if your Boulderfist/Landslide buffs will fall off within a global cooldown.  SimulationCraft and Wordup both recommend Boulderfist without regard for Maelstrom overcapping.\r\n" ..
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.boulderfist_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } )

        addMetaFunction( 'state', 'boulderfist_maelstrom', function ()
            return state.settings.boulderfist_maelstrom
        end ) ]]

        --[[ ns.addSetting( 'crash_lightning_maelstrom', 0, {
            name = "Maelstrom: Crash Lightning",
            type = "range",
            desc = "Set a |cFFFF0000minimum|r amount of Maelstrom required to recommend Crash Lightning in the default action lists.  This is useful if you are concerned with maintaining a minimum Maelstrom pool to use on Stormbringer procs, etc.\n\n" ..
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.crash_lightning_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } ) ]]

        --[[ ns.addSetting( 'lava_lash_maelstrom', 120, {
            name = "Maelstrom: Lava Lash",
            type = "range",
            desc = "Set a |cFFFF0000minimum|r amount of Maelstrom required to cast Lava Lash in the default action lists.  This is ignored if Lava Lash would currently be free.\n\n" ..
                "The addon default and SimulationCraft all recommend using Lava Lash at/above 120 Maelstrom by default (without Tier 19 4pc).\n\n" .. 
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.lava_lash_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } ) ]]



        addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.doom_winds
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.doom_winds_cooldown
        end )

        -- Overriding the default active_enemies handler because Elemental needs to count targets based on what's been hit.
        --[[ addMetaFunction( 'state', 'active_enemies', function ()
            local enemies = state.spec.enhancement and ns.getNumberTargets() or -1
          
            state.active_enemies = max( 1, enemies > -1 and enemies or ns.numTargets() )

            if state.min_targets > 0 then state.active_enemies = max( state.min_targets, state.active_enemies ) end
            if state.max_targets > 0 then state.active_enemies = min( state.max_targets, state.active_enemies ) end

            return state.active_enemies
        end ) ]]


        addAbility( 'ancestral_guidance', {
            id = 108281,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            talent = 'ancestral_guidance',
            passive = true,
            cooldown = 120
        } )

        addHandler( 'ancestral_guidance', function ()
            applyBuff( 'ancestral_guidance', 10 )
        end )


        addAbility( 'ascendance', {
            id = 114051,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            talent = 'ascendance',
            cooldown = 180,
            passive = true,
            toggle = 'cooldowns',
            usable = function () return buff.ascendance.down end,
        }, 114050 )

        modifyAbility( 'ascendance', 'id', function( x )
            if spec.elemental then return 114050 end
            return x
        end )

        class.abilities[ 114050 ] = class.abilities.ascendance -- Elemental.

        addHandler( 'ascendance', function ()
            applyBuff( 'ascendance', 15 )
            if spec.enhancement then setCooldown( 'stormstrike', 0 ); setCooldown( 'windstrike', 0 ) end
            if spec.elemental then gainCharges( 'lava_burst', class.abilities.lava_burst.charges ) end
        end )


        addAbility( 'astral_shift', {
            id = 108271,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            passive = true,
        } )

        addHandler( 'astral_shift', function ()
            applyBuff( 'astral_shift', 8 )
        end )


        addAbility( 'bloodlust', {
            id = 2825,
            spend = 0.215,
            cast = 0,
            gcdType = 'off',
            cooldown = 300,
            toggle = 'cooldowns',
            passive = true,
        } )


        addAbility( 'chain_lightning', {
            id = 188443,
            spend = 0,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 0
        } )

        modifyAbility( 'chain_lightning', 'cast', function( x )
            if buff.stormkeeper.up then return 0 end
            return x * haste
        end )

        modifyAbility( 'chain_lightning', 'cycle', function( x )
            if talent.lightning_rod.enabled then
                return 'lightning_rod'
            end
            return x
        end )

        addHandler( 'chain_lightning', function ()
            local overload = floor( settings.optimistic_overload and stat.mastery_value > 0.50 and ( 0.75 * max( 5, active_enemies ) * 6 ) or 0 )
            gain( 6 * max( 5, active_enemies ) + overload, 'maelstrom' )
            removeStack( 'stormkeeper', 1 )
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'crash_lightning', {
            id = 187874,
            spend = 20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 6
        } )

        addHandler( 'crash_lightning', function ()
            if active_enemies >= 2 then
                applyBuff( 'crash_lightning', 10 )
            end

            removeBuff( 'crashing_lightning' )
            if set_bonus.tier20_2pc > 1 then
                applyBuff( 'lightning_crash' )
            end

            if equipped.emalons_charged_core and active_enemies >= 3 then
                applyBuff( 'emalons_charged_core', 10 )
            end

            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end

            if feral_spirit.active and artifact.alpha_wolf.enabled then
                applyBuff( 'alpha_wolf', min( 8, buff.feral_spirit.remains ) )
            end
        end )

        modifyAbility( 'crash_lightning', 'cooldown', function( x )
            return x * haste
        end )


        addAbility( 'doom_winds', {
            id = 204945,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 60,
            known = function() return equipped.doomhammer end,
            usable = function () return toggle.doom_winds or ( toggle.cooldowns and settings.doom_winds_cooldown ) end,
            passive = true,
            -- toggle = 'cooldowns'
        } )

        addHandler( 'doom_winds', function ()
            applyBuff( 'doom_winds', 6 )
        end )


        addAbility( 'earthen_spike', {
            id = 188089,
            spend = 30,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 20,
            talent = 'earthen_spike'
        } )

        addHandler( 'earthen_spike', function ()
            applyDebuff( 'target', 'earthen_spike', 10 )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'earth_elemental', {
            id = 198103,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300,
            passive = true,
        } )

        addHandler( 'earth_elemental', function ()
            summonPet( 'earth_elemental', 60 )
        end )


        addAbility( 'earth_shock', {
            id = 8042,
            spend = 10,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
        } )

        modifyAbility( 'earth_shock', 'spend', function( x )
            return max( 10, maelstrom.current )
        end )

        addHandler( 'earth_shock', function ()
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'earthquake', {
            id = 61882,
            spend = 50,
            spend_type = 'maelstrom',
            cast =0,
            gcdType = 'spell',
            cooldown = 0
        } )

        modifyAbility( 'earthquake', 'spend', function( x )
            return buff.echoes_of_the_great_sundering.up and 0 or x
        end )

        addHandler( 'earthquake', function ()
            removeStack( 'elemental_focus' )
            removeBuff( 'echoes_of_the_great_sundering' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'elemental_mastery', {
            id = 16166,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            talent = 'elemental_mastery',
            toggle = 'cooldowns',
            passive = true,
        } )

        addHandler( 'elemental_mastery', function ()
            applyBuff( 'elemental_mastery', 20 )
            stat.spell_haste = stat.spell_haste + 0.20 -- LegionFix: Giving more than 0.20, actually.
        end )


        addAbility( 'elemental_blast', {
            id = 117014,
            spend = 0,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 12,
            talent = 'elemental_blast'
        } )

        modifyAbility( 'elemental_blast', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'elemental_blast', function ()
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
                applyBuff( 'chill_of_the_twisting_nether', 8 )
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'feral_spirit', {
            id = 51533,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 120,
            toggle = 'cooldowns',
            passive = true,
        } )

        addHandler( 'feral_spirit', function ()
            summonPet( 'feral_spirit', 15 )
            feral_spirit.cast_time = state.now + state.offset
        end )


        addAbility( 'fire_elemental', {
            id = 198067,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300,
            known = function () return spec.elemental end,
            notalent = 'fire_elemental',
            toggle = 'cooldowns',
            passive = true,
        } )

        addHandler( 'fire_elemental', function ()
            summonPet( 'fire_elemental', 60 )
            if talent.primal_elementalist.enabled then summonPet( 'primal_fire_elemental', 60 ) end
        end )


        addAbility( 'flametongue', {
            id = 193796,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12
        } )

        modifyAbility( 'flametongue', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'flametongue', function ()
            applyBuff( 'flametongue', 16 + min( 4.8, buff.flametongue.remains ) )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'flame_shock', {
            id = 188389,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            cycle = 'flame_shock'
        } )

        addHandler( 'flame_shock', function ()
            local cost = min( 20, maelstrom.current )
            applyDebuff( 'target', 'flame_shock', 15 + ( 15 * ( cost / 20 ) ) )

            removeStack( 'elemental_focus' )

            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
            end
            spend( cost, 'maelstrom' )
        end )


        addAbility( 'frostbrand', {
            id = 196834,
            spend = 20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
        } )

        addHandler( 'frostbrand', function ()
            applyBuff( 'frostbrand', 16 + min( 4.8, buff.frostbrand.remains ) )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'chill_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'frost_shock', {
            id = 196840,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0
        } )

        addHandler( 'frost_shock', function ()
            local cost = min( 20, maelstrom.current ) 
            applyDebuff( 'target', 'frost_shock', 5 + ( 5 * ( cost / 20 ) ) )
            removeStack( 'icefury' )
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'chill_of_the_twisting_nether', 8 )
            end
            spend( cost, 'maelstrom' )
        end )


        addAbility( 'fury_of_air', {
            id = 197211,
            spend = 3,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            talent = 'fury_of_air',
            usable = function () return active_enemies > 1 or settings.st_fury end,
            passive = true,
        } )

        modifyAbility( 'fury_of_air', 'gcdType', function( x )
            if buff.fury_of_air.up then return 'off' end
            return x
        end )

        addHandler( 'fury_of_air', function ()
            if buff.fury_of_air.up then
                removeBuff( 'fury_of_air' )
            else
                applyBuff( 'fury_of_air', 3600 )
            end
        end )


        addAbility( 'healing_surge', {
            id = 188070,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 2.0,
            gcdType = 'spell',
            cooldown = 0,
            usable = function() return mana.current / mana.max > 0.22 end,
            passive = true,
        } )

        modifyAbility( 'healing_surge', 'cast', function( x )
            if maelstrom.current >= 20 then
                return 0
            end
            return x
        end )

        modifyAbility( 'healing_surge', 'spend', function( x )
            return maelstrom.current >= 20 and 20 or x
        end )


        addAbility( 'heroism', {
            id = 32182,
            spend = 0.215,
            cast = 0,
            gcdType = 'off',
            cooldown = 300,
            toggle = 'cooldowns',
            passive = true,
        } )

        if state.faction == 'Alliance' then
            class.abilities.bloodlust = class.abilities.heroism
        else
            class.abilities.heroism = class.abilities.bloodlust
        end


        addAbility( 'icefury', {
            id = 210714,
            spend = -24,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 30
        } )

        modifyAbility( 'icefury', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'icefury', function ()
            applyBuff( 'icefury', 15, 4 )
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'chill_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'lava_beam', {
            id = 114074,
            spend = 0,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 0,
            usable = function () return spec.elemental and talent.ascendance.enabled and buff.ascendance.up end
        } )

        modifyAbility( 'lava_beam', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'lava_beam', function ()
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 ) -- or shock?
            end
            local overload = floor( settings.optimistic_overload and stat.mastery_value > 0.50 and ( 0.75 * max( 5, active_enemies ) * 6 ) or 0 )
            gain( 6 * max( 5, active_enemies ) + overload, 'maelstrom' )
        end )


        addAbility( 'lava_burst', {
            id = 51505,
            spend = -12,
            spend_type = 'maelstrom',
            cast = 2,
            gcdType = 'spell',
            cooldown = 8,
            charges = 1,
            recharge = 8
        } )

        modifyAbility( 'lava_burst', 'spend', function( x )
            local overload = floor( settings.optimistic_overload and stat.mastery_value > 0.50 and ( 0.75 * 12 ) or 0 )
            return x - overload
        end )

        modifyAbility( 'lava_burst', 'cast', function( x )
            return x * haste
        end )

        modifyAbility( 'lava_burst', 'charges', function( x )
            if talent.echo_of_the_elements.enabled then return 2 end
            return x
        end )

        modifyAbility( 'lava_burst', 'recharge', function( x )
            if buff.ascendance.up then return 0 end
            return x
        end )

        modifyAbility( 'lava_burst', 'cooldown', function( x )
            if buff.ascendance.up or buff.lava_surge.up then return 0 end
            return x
        end )

        addHandler( 'lava_burst', function ()
            removeBuff( 'lava_surge' ) 
            if talent.path_of_flame.enabled then active_dot.flame_shock = min( active_enemies, active_dot.flame_shock + 1 ) end
            if artifact.elementalist.enabled then
                if talent.storm_elemental.enabled then
                    setCooldown( 'storm_elemental', max( 0, cooldown.storm_elemental.remains - 2 ) )
                else
                    setCooldown( 'fire_elemental', max( 0, cooldown.fire_elemental.remains - 2 ) )
                end
            end
            removeStack( 'elemental_focus' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
            end
        end )



        addAbility( 'lava_lash', {
            id = 60103,
            spend = 30,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0
        } )

        modifyAbility( 'lava_lash', 'spend', function( x )
            if buff.hot_hand.up then return 0 end
            return x
        end )

        addHandler( 'lava_lash', function ()
            removeBuff( 'hot_hand' )
            removeDebuff( 'target', 'lashing_flames' )
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
                if buff.crash_lightning.up then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
                end
            end
        end )


        addAbility( 'lightning_bolt', {
            id = 187837,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            velocity = 1000
        } )

        modifyAbility( 'lightning_bolt', 'id', function( x )
            if spec.elemental then return 188196 end
            return x
        end )

        class.abilities[ 188196 ] = class.abilities.lightning_bolt

        modifyAbility( 'lightning_bolt', 'spend', function( x )
            if spec.elemental then
                local overload = settings.optimistic_overload and stat.mastery_value > 50 and 6 or 0
                return -1 * ( 8 + ( overload ) +  ( buff.power_of_the_maelstrom.up and 6 or 0 ) )
            end

            if talent.overcharge.enabled then
                return min( maelstrom.current, 40 )
            end
            return x
        end )

        modifyAbility( 'lightning_bolt', 'cast', function( x )
            if spec.elemental then 
                if buff.stormkeeper.up then return 0 end
                return 2 * haste
            end
            return x
        end )

        modifyAbility( 'lightning_bolt', 'cooldown', function( x )
            if talent.overcharge.enabled then
                return 12 * haste
            end
            return x
        end )

        modifyAbility( 'lightning_bolt', 'cycle', function( x )
            if talent.lightning_rod.enabled then
                return 'lightning_rod'
            end
            return x
        end )

        addHandler( 'lightning_bolt', function ()
            if buff.stormkeeper.up then removeStack( 'stormkeeper' ) end 
            removeStack( 'elemental_focus' )
            removeStack( 'power_of_the_maelstrom' )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'lightning_shield', {
            id = 192106,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            talent = 'lightning_shield',
            usable = function() return buff.lightning_shield.remains < 30 end,
            passive = true,
        } )

        addHandler( 'lightning_shield', function ()
            applyBuff( 'lightning_shield', 3600 )
        end )


        addAbility( 'liquid_magma_totem', {
            id = 192222,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            talent = 'liquid_magma_totem',
        } )

        addHandler( 'liquid_magma_totem', function ()
            summonPet( 'liquid_magma_totem', 15 )
        end )


        addAbility( 'rainfall', {
            id = 215864,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell', 
            cooldown = 10,
            talent = 'rainfall',
            passive = true,
        } )

        addHandler( 'rainfall', function ()
            applyBuff( 'rainfall', 10 )
        end )


        -- LegionFix: Adjust spend value based on artifact traits.
        addAbility( 'rockbiter', {
            id = 193786,
            spend = -25,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 6,
            charges = 2,
            recharge = 6,
        } )

        modifyAbility( 'rockbiter', 'spend', function( x )
            return x - ( artifact.gathering_of_the_maelstrom.rank )
        end )

        modifyAbility( 'rockbiter', 'cooldown', function( x )
            if talent.boulderfist.enabled then x = x * 0.85 end
            return x
        end )

        modifyAbility( 'rockbiter', 'recharge', function( x )
            if talent.boulderfist.enabled then x = x * 0.85 end
            return x
        end )

        addHandler( 'rockbiter', function ()
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
            if talent.landslide.enabled then
                applyBuff( 'landslide', 10 )
            end
        end )


        addAbility( 'storm_elemental', {
            id = 192249,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 150,
            talent = 'storm_elemental',
            toggle = 'cooldowns',
            passive = true,
        } )

        addHandler( 'storm_elemental', function ()
            summonPet( 'storm_elemental', 60 )
            if talent.primal_elementalist.enabled then summonPet( 'primal_storm_elemental', 30 ) end
        end )


        addAbility( 'stormkeeper', {
            id = 205495,
            spend = 0,
            spend_type = 'mana',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 60,
            known = function() return equipped.fist_of_raden end,
            usable = function () return toggle.artifact_ability or ( toggle.cooldowns and settings.artifact ) end,
            passive = true,
        } )

        modifyAbility( 'stormkeeper', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'stormkeeper', function ()
            applyBuff( 'stormkeeper', 15, 3 )
            if artifact.fury_of_the_storms.enabled then summonPet( 'fury_of_the_storms', 8 ) end
        end )


        addAbility( 'stormstrike', {
            id = 17364,
            spend = 40,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'melee',
            cooldown = 15,
            usable = function() return not buff.ascendance.up end
        } )

        modifyAbility( 'stormstrike', 'spend', function( x )
            if buff.stormbringer.up then x = x / 2 end
            if buff.ascendance.up then x = x / 5 end
            return x
        end )

        modifyAbility( 'stormstrike', 'cooldown', function( x )
            if buff.stormbringer.up then return 0 end
            if buff.ascendance.up then x = x / 5 end
            return x * haste
        end )

        addHandler( 'stormstrike', function ()
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            
            removeBuff( 'stormbringer' )

            if equipped.storm_tempests then
                applyDebuff( 'target', 'storm_tempests', 15 )
            end

            if set_bonus.tier20_4pc > 0 then
                addStack( 'crashing_lightning', 16, 2 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'sundering', {
            id = 197214,
            spend = 20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 40,
            talent = 'sundering'
        } )

        addHandler( 'sundering', function ()
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )



        addAbility( 'thunderstorm', {
            id = 51490,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
        } )

        addHandler( 'thunderstorm', function ()
            applyDebuff( 'thunderstorm', 'target', 5 )
            removeStack( 'elemental_focus' )

            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'totem_mastery', {
            id = 210643,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            passive = true,
            talent = 'totem_mastery',
            usable = function () return buff.totem_mastery.remains < 15 end
        } )

        addHandler( 'totem_mastery', function ()
            applyBuff( 'resonance_totem', 120 )
            applyBuff( 'storm_totem', 120 )
            applyBuff( 'ember_totem', 120 )
            if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
            applyBuff( 'tailwind_totem', 120 )
            applyBuff( 'totem_mastery', 120 )
        end )


        addAbility( 'wind_shear', {
            id = 57994,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'off',
            cooldown = 12,
            usable = function() return toggle.interrupts and target.casting end,
            toggle = 'interrupts'
        } )

        addHandler( 'wind_shear', function ()
            interrupt()
        end )

        registerInterrupt( 'wind_shear' )


        addAbility( 'windsong', {
            id = 201898,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 45,
            talent = 'windsong'
        } )

        addHandler( 'windsong', function ()
            applyBuff( 'windsong', 20 )
        end )


        addAbility( 'windstrike', {
            id = 115356,
            spend = 8,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 3,
            known = 17364,
            usable = function () return buff.ascendance.up end
        } )

        modifyAbility( 'windstrike', 'spend', function( x )
            if buff.stormbringer.up then x = x / 2 end
            return x
        end )

        modifyAbility( 'windstrike', 'cooldown', function( x )
            if buff.stormbringer.up then return 0 end
            return x * haste
        end )

        addHandler( 'windstrike', function ()
            setCooldown( 'stormstrike', 3 * haste )

            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            
            removeBuff( 'stormbringer' )

            if equipped.storm_tempests then
                applyDebuff( 'target', 'storm_tempests', 15 )
            end

            if set_bonus.tier20_4pc > 0 then
                addStack( 'crashing_lightning', 16, 2 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )

    end


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170622.214457, [[dmeMxaqijIfrsPnrIAue0PiHzrsLDrOHbkhdeltu5zKuyAKu11av12evLVPinorv6CkIyDKinpsk6EOe7duLdkkwOePhIsnrse1fLIoPIWmjr4MeyNKYpvevdvruwQu4PunvjQRQisTvqLVsIi7f6VkQbl0HPSye9yPAYiCzvBMu9zPuJwcNwWQvejETuYSr1TL0Ub(nrdhKoUOkwospxHPR01rX2jjFxuvDErP1RisA(OK2ViJqWYORKVUXWxSu0DOVhmEys12GeGA5YNAGEJZVnoQLdgKPWYxUCI5GKlFWGp6ENgGUOJEM(gKGbwg1GGLrVjWi5NalfDVtdqx0xz728lga7PugO7a9mKbEyZIE(daI5rXnk6taicDBLu0bsWrxGKaoJQz1Jo6Aw9ORKcaIu0lUrrVX53gh1YbdYuiWqVXhsgA)dSmUOZU49wcKQE9GfjrxGKqZQhDCrTCyz0Bcms(jWsr370a0fDHPOWuCn(bRyHf4JvsRIhyK8tKIkNILKIKm66I6u5yjPgGqKbAkQifzL1uSKuCn(bRyHf4JvsRIhyK8tKIkqpdzGh2SORYObJKF0zx8ElbsvVEWIKOlqsaNr1S6rVWc8XkPv2fV3cDnRE09vsFkcNXzo6zOThOdS6zPWc8XkPv2fV3sDQmoZzrOW14hSIfwGpwjTkEGrYpHYLqYORlQtLJLKAacrgOkyL1swJFWkwyb(yL0Q4bgj)ekqVX53gh1YbdYuiWqVXhsgA)dSmUOpbGi0TvsrhibhDbscnRE0Xf1udSm6nbgj)eyPO7DAa6IUWuSKuCn(bROodn7SuF2cuXdms(jsrwznffMIRXpyf1zOzNL6ZwGkEGrYprkQCkwTZhlvwf7mu6bBkcVumVWsrfPOc0Zqg4Hnl6QmAWi5hD2fV3sGu1RhSij6cKeWzunRE01zOzzx8ER8cdDnRE09vsFkcNXzEkkeIc0ZqBpqhy1ZIodnl7I3BLxyQtLXzolclzn(bROodn7SuF2cuXdms(jyLvHRXpyf1zOzNL6ZwGkEGrYpHYv78XsLv4LxykuGEJZVnoQLdgKPqGHEJpKm0(hyzCrFcarOBRKIoqco6cKeAw9OJlQPESm6nbgj)eyPO7DAa6IUWuSKuCn(bROodn7SuF2cuXdms(jsrwznffMIRXpyf1zOzNL6ZwGkEGrYprkQCkwTZhlvwf7mu6bBkcVuCkSuurkQa9mKbEyZIUkJgms(rNDX7Teiv96blsIUajbCgvZQhDDgAw2fV3Akm01S6r3xj9PiCgN5POWCkqpdT9aDGvpl6m0SSlEV1uyQtLXzolclzn(bROodn7SuF2cuXdms(jyLvHRXpyf1zOzNL6ZwGkEGrYpHYv78XsLv4nfMcfO348BJJA5GbzkeyO34djdT)bwgx0Naqe62kPOdKGJUajHMvp64IAWhlJEtGrYpbwk6ENgGUOlmfljfxJFWkQZqZol1NTav8aJKFIuKvwtrHP4A8dwrDgA2zP(SfOIhyK8tKIkNIv78XsLvXodLEWMIWlfvp8trfPOc0Zqg4Hnl6QmAWi5hD2fV3sGu1RhSij6cKeWzunRE01zOzzx8El1dF01S6r3xj9PiCgN5POq1qb6zOThOdS6zrNHMLDX7Tup8vNkJZCwewYA8dwrDgA2zP(SfOIhyK8tWkRcxJFWkQZqZol1NTav8aJKFcLR25JLkRWt9WxHc0BC(TXrTCWGmfcm0B8HKH2)alJl6taicDBLu0bsWrxGKqZQhDCrT8HLrVjWi5NalfDVtdqx0fMILKIRXpyf1zOzNL6ZwGkEGrYprkYkRPOWuCn(bROodn7SuF2cuXdms(jsrLtXQD(yPYQyNHspytr4LI5GFkQifvGEgYapSzrxLrdgj)OZU49wcKQE9GfjrxGKaoJQz1JUodnl7I3BLd(ORz1JUVs6tr4moZtrHQxb6zOThOdS6zrNHMLDX7TYbF1PY4mNfHLSg)GvuNHMDwQpBbQ4bgj)eSYQW14hSI6m0SZs9zlqfpWi5Nq5QD(yPYk8YbFfkqVX53gh1YbdYuiWqVXhsgA)dSmUOpbGi0TvsrhibhDbscnRE0Xf1MILrVjWi5NalfDVtdqx0fMILKIRXpyfLQoTxy02x8aJKFIuKvwtrHP4A8dwrPQt7fgT9fpWi5NifvofR25JLkRIDgk9GnfHxkofwkQifvGEgYapSzrxLrdgj)OZU49wcKQE9GfjrxGKaoJQz1J(KZEYKs(uyORz1JUVs6tr4moZtrHWxb6zOThOdS6zzYzpzsjFkm1PY4mNfHLSg)GvuQ60EHrBFXdms(jyLvHRXpyfLQoTxy02x8aJKFcLR25JLkRWBkmfkqVX53gh1YbdYuiWqVXhsgA)dSmUOpbGi0TvsrhibhDbscnRE0Xf1Ylwg9MaJKFcSu09onaDrxykwskUg)GvuQ60EHrBFXdms(jsrwznffMIRXpyfLQoTxy02x8aJKFIuu5uSANpwQSk2zO0d2ueEPy(GLIksrfONHmWdBw0vz0GrYp6SlEVLaPQxpyrs0fijGZOAw9Op5SNmPKNpyORz1JUVs6tr4moZtrH5tb6zOThOdS6zzYzpzsjpFWuNkJZCwewYA8dwrPQt7fgT9fpWi5NGvwfUg)GvuQ60EHrBFXdms(juUANpwQScV8btHc0BC(TXrTCWGmfcm0B8HKH2)alJl6taicDBLu0bsWrxGKqZQhDCrTjblJEtGrYpbwk6ENgGUOlmfFEycqHEcriWhsEHmjPOc0Zqg4Hnl6QmAWi5hD2fV3sGu1RhSij6cKeWzunRE0lUr3M5Hjaf6jqxZQhDFL0NIWzCMNIcNQa9m02d0bw9SuCJUnZdtak0tOovgN5Si85Hjaf6jeHaFi5fYKOa9gNFBCulhmitHad9gFizO9pWY4I(eaIq3wjfDGeC0fij0S6rhxudcmSm6nbgj)eyPO7DAa6IUWu85Hjaf6jeTwwaWmMnYHKZSFEsHzSH(trfONHmWdBw0vz0GrYp6SlEVLaPQxpyrs0fijGZOAw9OBTSaGPzEycqHEc01S6r3xj9PiCgN5POW8Qa9m02d0bw9SyTSaGPzEycqHEc1PY4mNfHppmbOqpHie1ykS8QEfO348BJJA5GbzkeyO34djdT)bwgx0Naqe62kPOdKGJUajHMvp64IAqGGLrVjWi5NalfDVtdqx0fMIQmAWi5x0AzbatZ8WeGc9ePOYPijJUUyHCNlmaHid0uu5uSKuKKrxxuNkhlj1aeImqtrfONHmWdBw0vz0GrYp6SlEVLaPQxpyrs0fijGZOAw9OBTSaGjJJUMvp6(kPpfHZ4mpffojkqpdT9aDGvplwllayY4QtLXzolcvz0GrYVO1YcaMM5Hjaf6juMKrxxSqUZfgGqKERVkxcjJUUOovowsQbiezGQa9gNFBCulhmitHad9gFizO9pWY4I(eaIq3wjfDGeC0fij0S6rhxudsoSm6nbgj)eyPO7DAa6IUWuSKuKKrxxKhAxSGaO9CNAJcrgOPOYP447mPeWme3WP5GnNdApfHxkclfvGEgYapSzrxLrdgj)OZU49wcKQE9GfjrxGKaoJQz1JUseAxSGaOnBQnk0K7Kgk6Aw9O7RK(ueoJZ8uuieykqpdT9aDGvplkrODXccG2SP2OqtUtAOQtLXzolclHKrxxKhAxSGaO9CNAJcrgOkp(otkbmdXnCAoyZ5G2vGEJZVnoQLdgKPqGHEJpKm0(hyzCrFcarOBRKIoqco6cKeAw9OJlQbrnWYO3eyK8tGLIU3PbOl6ctrHPijJUUOXHwyZ5xY1fPVAbWifvZumxkQCksYORlACOf2C(LCDr6Rwamsr1mfZLIkNIKm66IghAHnNFjxxK(QfaJuuntXCPOIuu5uu)uJppGgOHvK(QfaJueEPO6trfONHmWdBw0vz0GrYp6SlEVLaPQxpyrs0fijGZOAw9OBCOfMssY1zx8El01S6r3xj9PiCgN5POqiquGEgA7b6aREwmo0ctjj56SlEVL6uzCMZIqHq)kQtLJDo)sUUijJUUOXHwyZ5xY1fPVAbWqnZPm0VI6HtZoNFjxxKKrxx04qlS58l56I0xTayOM5ug6xrEODXccG2Z5xY1fjz01fno0cBo)sUUi9vlagQzofkRFQXNhqd0WksF1cGb8uVc0BC(TXrTCWGmfcm0B8HKH2)alJl6taicDBLu0bsWrxGKqZQhDCrniQhlJEtGrYpbwk6zid8WMf9UX5ZwFdsWmpmw0Naqe62kPOdKGJUajbCgvZQhD01S6rNTX5PyM(gKGuujcJf9m02d0bw9SOwpuzNInbfgO)6bRstrj0dovTO348BJJA5GbzkeyO34djdT)bwgx0zx8ElbsvVEWIKOlqsOz1JUhQStXMGcd0F9GvPPOe6bNIlQbb(yz0Bcms(jWsr370a0fDsgDDrB0pGWa9lYaf9mKbEyZIE348zRVbjyMhgl6SlEVLaPQxpyrs0fijGZOAw9OJUMvp6SnopfZ03GeKIkrySPOqikqpdT9aDGvplQ1dv2PytqHb6VEWQ0u0gD1IEJZVnoQLdgKPqGHEJpKm0(hyzCrFcarOBRKIoqco6cKeAw9O7Hk7uSjOWa9xpyvAkAJoUOgK8HLrVjWi5Nalf9mKbEyZIE348zRVbjyMhgl6taicDBLu0bsWrxGKaoJQz1Jo6Aw9OZ248umtFdsqkQeHXMIcZPa9m02d0bw9SOwpuzNInbfgO)6bRstrsgD9HArVX53gh1YbdYuiWqVXhsgA)dSmUOZU49wcKQE9GfjrxGKqZQhDpuzNInbfgO)6bRstrsgD9bUOgKPyz0Bcms(jWsrpdzGh2SO3noF26BqcM5HXI(eaIq3wjfDGeC0fijGZOAw9OJUMvp6SnopfZ03GeKIkrySPOq1qb6zOThOdS6zrTEOYofBckmq)1dwLMISvYd1IEJZVnoQLdgKPqGHEJpKm0(hyzCrNDX7Teiv96blsIUajHMvp6EOYofBckmq)1dwLMISvYdCrni5flJEtGrYpbwk6zid8WMf9UX5ZwFdsWmpmw0Naqe62kPOdKGJUajbCgvZQhD01S6rNTX5PyM(gKGuujcJnffQEfONH2EGoWQNf16Hk7uSjOWa9xpyvAk2L0Rw0BC(TXrTCWGmfcm0B8HKH2)alJl6SlEVLaPQxpyrs0fij0S6r3dv2PytqHb6VEWQ0uSlPhxudYKGLrVjWi5Nalf9mKbEyZIE348zRVbjyMhgl6taicDBLu0bsWrxGKaoJQz1Jo6Aw9OZ248umtFdsqkQeHXMIcHVc0ZqBpqhy1ZIA9qLDk2euyG(RhSknf1dC(PQf9gNFBCulhmitHad9gFizO9pWY4Io7I3BjqQ61dwKeDbscnRE09qLDk2euyG(RhSknf1dC(P4Il6Aw9O7Hk7uSjOWa9xpyvAksCDJHV4Iia]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170622.214457, [[daZWbaGEuI2fkLTjcZuQQMnvDtPY3er7Kk7LSBL2pLYWOWVvmuPQmykvdxchuK6yOYcfflfkwmfTCO6HsvEk4Xs65qAIqjnvjAYqmDHlkk9mOuUUizROK2mkHTJQ0NfvldfNwLlJmAk52s5KOkoSQUguQopkvVgvL)IQQ1bLyXPsbyLyXNYhkJaOGQ37pw(XnRCmjWMamKNEusogdUKgjyyyJHJjHb2fav8RieiiDnUzrvPCCQuq29n9eIYiaQ4xriiM8CpXwXe3SOcsBE(lyxqXe3Sc4zrU6hdUGDwsq3GW6J7(gjqG7BKG(M4MvagYtpkjhJbxsodbyi0jfELqvPcb9SOkFDdVuJ2qMc6ge33ibkKJrLcYUVPNqugbPnp)fSlWF5wXEBo)Owh5reWZIC1pgCb7SKGUbH1h39nsGa33ib9F5wXEBUn7G1rEebyip9OKCmgCj5meGHqNu4vcvLke0ZIQ81n8snAdzkOBqCFJeOqHa33ibW16zZE2163k1OnWIn7f4uDAMFOqca]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170622.214457, [[d4ZKlaGEqc1MOsAxivBJkr7dKYmbjTms0Svy(urUPKCyk3wjFdj1ovP9k2nW(LQrrLYWqIXrfvoVI40igSugov4GijNIkvhtsDCqISqIWsjHfdQLt4HKupf1JL45u1ebjOPsKMSkMUQUOsLRsfv1ZOIY1vuBeKaBLKyZkvTDLYLH(kjjnnQe(oir9xfP1bsiJMOEns5KerFgexJKu3dKQZrfv5qKK43K6uhPHHcX9284JeHV2cdZKL6EBhq2afCHGhkQ3kAbgwboqZJ5QKsn1uCPsL0vwR0LuuDy2bwi2GafBprdYvPlDwyQkprd8rAU1rA4DadEGNiryUiio(WBMGyWdK((zXe1YyHMsvhMkyYG8tcJM4LrWuVdcnmSKGdPyVwegOby4k9rftCTfgo81wy4DM4LrqVXoi0WWkWbAEmxLuQPUMsyfOxplkOpsZhwTmwOvP3Wfc(ahUsFU2cdNpxLrA4DadEGNiryUiio(WQsVbpVFp9IW8YtheiYpGaGqF2rV5AVzLNSHtraUiOV3Gg07nLHPcMmi)KWfH5LNoiqKFabajSKGdPyVwegOby4k9rftCTfgo81wyy1cZl3BqLar(beaKWkWbAEmxLuQPUMsyfOxplkOpsZhwTmwOvP3Wfc(ahUsFU2cdNpxNfPH3bm4bEIeHPcMmi)KWqzc441aiHLeCif71IWanadxPpQyIRTWWHV2cdRQeWXRbqcRahO5XCvsPM6AkHvGE9SOG(inFy1YyHwLEdxi4dC4k95AlmC(CDrKgEhWGh4jseMlcIJpSvEYgofb4IG(EdAqV3CUEZjN6n36nR8KnCkcWfb99g0GEV5YEZ1E7TbcE6fH5Ljait9VwSOJadEGNEZ9WubtgKFs4IW8YtheiYpGaGewsWHuSxlcd0amCL(OIjU2cdh(AlmSAH5L7nOsGi)acasV5wT7HvGd08yUkPutDnLWkqVEwuqFKMpSAzSqRsVHle8boCL(CTfgoFUQosdVdyWd8ejctfmzq(jHHYeWX)ccnmSKGdPyVwegOby4k9rftCTfgo81wyyvLao(xqOHHvGd08yUkPutDnLWkqVEwuqFKMpSAzSqRsVHle8boCL(CTfgoFUUmsdVdyWd8ejcZfbXXhgEE)E6(xlwWccackOp7O3CT32mbXGhi99ZIjQLXcnLQomvWKb5Ne2)AXY)ccnmSKGdPyVwegOby4k9rftCTfgo81wyy(1IL)feAyyf4anpMRsk1uxtjSc0RNff0hP5dRwgl0Q0B4cbFGdxPpxBHHZNl1rA4DadEGNiryUiio(Ww5jB4ueGlc67nOb9EZf9Mto1BU1Bw5jB4ueGlc67nOb9EtzV5AV92abp9IW8YeaKP(xlw0rGbpWtV5EyQGjdYpjCryE5Pdce5hqaqclj4qk2RfHbAagUsFuXexBHHdFTfgwTW8Y9gujqKFabaP3CtP7HvGd08yUkPutDnLWkqVEwuqFKMpSAzSqRsVHle8boCL(CTfgoFUoxKgEhWGh4jseMlcIJp8Bde801BOOiBciiDeyWd80BU2BBMGyWdK((zXe1YyHMluDV5AVTmC4FHErVmlei47nOb9EZfuctfmzq(jHheiYpGaGmfwp(WscoKI9AryGgGHR0hvmX1wy4WxBHHHkbI8diai9Me6XhwboqZJ5QKsn11ucRa96zrb9rA(WQLXcTk9gUqWh4Wv6Z1wy48568I0W7ag8aprIWCrqC8HDR3uLE7TbcE66nuuKnbeKocm4bE6nx7Tntqm4bsF)SyIAzSqZfQU3CV3CYPEZTE7TbcE66nuuKnbeKocm4bE6nx7Tntqm4bsF)SyIAzSqZ5O0BUhMkyYG8tc7FTy5FbHggwsWHuSxlcd0amCL(OIjU2cdh(Almm)AXY)ccnS3CR29WkWbAEmxLuQPUMsyfOxplkOpsZhwTmwOvP3Wfc(ahUsFU2cdNp3AkrA4DadEGNiryUiio(WBMGyWdKUrZiGzQ4WubtgKFs49cT)Hfg4ewsWHuSxlcd0amCL(OIjU2cdh(AlmmuGq7FyHboHvGd08yUkPutDnLWkqVEwuqFKMpSAzSqRsVHle8boCL(CTfgoFU11rA4DadEGNiryUiio(WWZ73txw)tLnWH(SJEZ1EZTEZTEBZeedEG0nAgbmVdkntC4ap9MR9g88(903l0(hwyGd9zh9M79Mto1BQsVTzcIbpq6gnJaM3bLMjoCGNEZ9WubtgKFs4HTzthMxoSKGdPyVwegOby4k9rftCTfgo81wyyOABwVbvZlhwboqZJ5QKsn11ucRa96zrb9rA(WQLXcTk9gUqWh4Wv6Z1wy485wRmsdVdyWd8ejcZfbXXh2kpzdNIaCrqFVbnO3BolmvWKb5Ne2pdoOGaGewsWHuSxlcd0amCL(OIjU2cdh(AlmmpdoOGaGewboqZJ5QKsn11ucRa96zrb9rA(WQLXcTk9gUqWh4Wv6Z1wy485w7Sin8oGbpWtKimxeehFyR8KnCkcWfb99g0GEV5SEZjN6Tntqm4bshQeiYpGaGOwyE5R(D(o6nNCQ32mbXGhiDB4q2uv9yVAzSqlmvWKb5NeUimV80bbI8diaiHLeCif71IWanadxPpQyIRTWWHV2cdRwyE5EdQeiYpGaG0BU5m3dRahO5XCvsPM6AkHvGE9SOG(inFy1YyHwLEdxi4dC4k95AlmC(8H5IG44dNpb]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170622.214457, [[d8cqbaGEjuBIKYUKeBJKmBv6Miv3wWovYEP2nH9ROHjKFJQbRWWLshukCmvSqKWsLklMuwokpuk6PGht06ekMijvtvQAYKQPl6IsQUm01rkBvOYMfkTDjWNfQAEskpNehwvJwIAzk1jLqonIRjrops03KKEns6zsq7J7nOog7t7MMcdRpGgasO5Cuxu(fsmGImM5G3IcKzOdV4RGETJovJuT3v2NTQOsgGwus(lP4pjCHxBvfAOHmjCHI7964Ed1fV2f1nfgajJ0MgcpEvsgpursJXqroh1MJtP5qT5ijbCoQnhXl1n0qJCjjLgyCjvnsImdfj0jYp5mdcUanqNRh3ZwFanyy9b0qhxsvJKiZqhEXxb9AhDQEIm0HkCAmjQ4ENgAwgLuPZladOiTMb6C91hqdoDAaKmsBAWPna]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170622.214457, [[dWZqhaGEcf1Mef2fbBtfL9jkA2cMpiDtqSmkQBRsFdvQDII9kTBvTFKgff0WePFR4WknuvuvdgXWfvheL4ueQogOCEujleLYsPilgvTCk9quspL0JPQNtLjkcAQuOjl00bUif40e9mcL66QWgjuYwfrTzq12rf9ArPVQIkMgHc(okvJKqrwNkQ0OvrMNiWjfr(mHCnrO7PIQCzO)IkCicf6cRgRMqe(EeaLTQm7fRQYlRuIb)P994fFW5sjSMqxvtyaxhwgZPW4o9mZMfmdZ8zPjwvZrVCdsX8cKZxgZNj2vzXdKZ7QXYaRgRAWV8bmw(QQ3kZbvbJirbuWptioS)okjdkXqkbSwriq4eUbWjHCpGssaLyorkbkukbiViLKjLKkKyAkLiEvw4LbjGRQ8HzIHdhOAsFu6xWyR(ZJvHmXKxlZEXQvz2lwvmH2r6UvnHbCDyzmNcJByPvnHU5W6rxnwqvwpH(SqgoXl(GYxfYez2lwTGYyUgRAWV8bmw2QQERmhufmIefqb)mH4W(7OKmOedPe(d4WfwNh)4(Eu4iNsGcLsmKsGJ2nWHlxALablEx57OKmPKePeXPeOqPKaYjgOKeqjWstPeXRYcVmibCvLhTo0Mv(IQM0hL(fm2Q)8yvitm51YSxSAvM9IvzdTo0Mv(IQAcd46WYyofg3WsRAcDZH1JUASGQSEc9zHmCIx8bLVkKjYSxSAbLrSRXQg8lFaJLTQQ3kZbvbJirbuWptioS)okjdkXqkH)aoCH15XpUVhfoYPeOqPedPe4ODdC4YLwjqWI3v(okjtkjrkrCkbkukjGCIbkjbucS0ukr8QSWldsaxv5dZe5a(HLRQj9rPFbJT6ppwfYetETm7fRwLzVyv2cZePeX6WYvvtyaxhwgZPW4gwAvtOBoSE0vJfuL1tOplKHt8IpO8vHmrM9IvlOmIHASQb)YhWyzRQ6TYCqvWisuafYhGCEhLKbLyiLWFahUW684h33Jch5ucuOuIyKsaBaFGW684h33Jc4V8bmsjzqjWr7g4WLlTsGGfVR8DusMusIucuOucyTIqGaqEroadhrjsjj48OKZsPeXRYcVmibCvnFaY5RM0hL(fm2Q)8yvitm51YSxSAvM9Ivp)biNVQjmGRdlJ5uyCdlTQj0nhwp6QXcQY6j0NfYWjEXhu(QqMiZEXQfuMeRXQg8lFaJLTQQ3kZbvbJirbuWptioS)UQSWldsaxvHJ2nWHlxALGQj9rPFbJT6ppwfYetETm7fRwLzVyvXcTBGs0CPvcQAcd46WYyofg3WsRAcDZH1JUASGQSEc9zHmCIx8bLVkKjYSxSAbL5SASQb)YhWyzRQ6TYCqv)mH4W(lSop(X99OGfVR8DusMuYzucuOucyd4de4NJqeTWLoGa(lFaJucuOuse5pGdxaxl4e(C4YLzrHJ8QSWldsaxvJZC5GD5hDvt6Js)cgB1FESkKjM8Az2lwTkZEXQjCMlLCoYp6QAcd46WYyofg3WsRAcDZH1JUASGQSEc9zHmCIx8bLVkKjYSxSAbLH7ASQb)YhWyzRQ6TYCqvWisuaf8ZeId7VJsYGsmKsmKs4pGdxWbg7L3kFrOv4iNsGcLs8ZeId7VGdyLzrblEx57OKmPKukrCkjdkH)aoCH15XpUVhfId7pLiEvw4LbjGRQRZJFCFpwnPpk9lySv)5XQqMyYRLzVy1Qm7fRYIZJFCFpw1egW1HLXCkmUHLw1e6MdRhD1ybvz9e6Zcz4eV4dkFvitKzVy1ckOQ6TYCq1cAb]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170622.214457, [[d4JfjaGEQksBcjAxk02ukAFajZKQswgrA2ImFGs3uroSWTPY3aIDQk7vA3G2pf)eivdtb)MW5rcdfiLbtPHRu6GiPofvvoMI6CuvqlKiSuKYIvvlhXdjv9uupwjpxutKQcmvKQjdy6QCrKKttYLHUovzJuvQTseTzsX2jk)LOQptQmnGQMNsHwhvfQxtknALQNrvrDsIkJtPGRbuCpGkJIQQoevfXXPQqUZLEzFaQj8sxLO8lCyzw50BSub3d4cDi88XgRgvkHKY0WegzSpPdZGmSPuPJsNLU5aykZBXLkskFACkbSpPB6ZLPEDkbmx69nx6LPcg)ecujkZlIA7v2fykFeHBC5rii8m2nASZshkt9xLuhfLjIL2V6qsz5GaQvCcszOaILNeasgKx4WYLFHdlttS0(vhsktdtyKX(KomdY8qzAyw4rwyU07vw)oU0ojKHoeE9xEsa8chwUxFsl9YubJFcbQeL5frT9k)90OzutkC4jG68Wrc6cfmBSB0yb)4gkt9xLuhfL1KchEcOopSSCqa1kobPmuaXYtcajdYlCy5YVWHL9DkC4jG68WY0WegzSpPdZGmpuMgMfEKfMl9EL1VJlTtczOdHx)LNeaVWHL71Npx6LPcg)ecujkZlIA7v2FJ9IecVXfjY7kOo5ZNG4gry8tiGXcwWASX6uYq5ri6uy2ybf4mwPgRFglLgla(90OzedYTJq5ZBvAXrVTglLgRlWu(ic34YJqq4zSGcCgl4hmwknwzbrf)eoc66bnHiT5qzQ)QK6OO8Ie5D5tkD7hub1vwoiGAfNGugkGy5jbGKb5foSC5x4WY6jrE3y9Ls3(bvqDLPHjmYyFshMbzEOmnml8ilmx69kRFhxANeYqhcV(lpjaEHdl3RpWx6LPcg)ecujkZlIA7v(IecVX9qLYNG4gry8tiGXsPX(90OzudrKVpjGaJe0fky2y3OXc(XnySuASUat5JiCJlpcbHNXckJf8dLP(RsQJIYAiI89jbeOSCqa1kobPmuaXYtcajdYlCy5YVWHL9nrKVpjGaLPHjmYyFshMbzEOmnml8ilmx69kRFhxANeYqhcV(lpjaEHdl3RpWu6LPcg)ecujkZlIA7vwwquXpHJH2qb9OYh5P2UfbmwknwFIX(90OzudrKVpjGaJEBnwknwxGP8reUXLhHGWZybf4mwqatzQ)QK6OOSgIiFFsabklheqTItqkdfqS8KaqYG8chwU8lCyzFte57tciGX6)SFLPHjmYyFshMbzEOmnml8ilmx69kRFhxANeYqhcV(lpjaEHdl3RVnl9YubJFcbQeLP(RsQJIYzpiasuqDLLdcOwXjiLHciwEsaizqEHdlx(foSm7bbqIcQRmnmHrg7t6WmiZdLPHzHhzH5sVxz974s7Kqg6q41F5jbWlCy5E9bsPxMky8tiqLOmViQTxzxGP8reUXLhHGWZybf4mwWmySuASYcIk(jCe01dAcrcKbJLsJvwquXpHJA8iuOFhxA3WqzQ)QK6OOCkKfYNI8Ez5GaQvCcszOaILNeasgKx4WYLFHdl7RqwyS(kY7LPHjmYyFshMbzEOmnml8ilmx69kRFhxANeYqhcV(lpjaEHdl3RVnu6LPcg)ecujkt9xLuhfLjIL2V6qsz5GaQvCcszOaILNeasgKx4WYLFHdlttS0(vhsmw)N9RmnmHrg7t6WmiZdLPHzHhzH5sVxz974s7Kqg6q41F5jbWlCy5E95dl9YubJFcbQeL5frT9k7VXgRtjdLhHOtHzJfuGZyLASGfSgR)gBgVtb1LhxKiVlF(mwknw)nwxGP8reUXLhHGWZybf4m2nbJXcwWASxKq4nUirExb1jF(ee3icJFcbmw)mw)mw)mwknwzbrf)eoc66bnHiT5GXsPXkliQ4NWrnEek0VJlTGhmLP(RsQJIYlsK3LpP0TFqfuxz5GaQvCcszOaILNeasgKx4WYLFHdlRNe5DJ1xkD7hub1zS(p7xzAycJm2N0HzqMhktdZcpYcZLEVY63XL2jHm0HWR)YtcGx4WY96BEO0ltfm(jeOsuM6VkPokkRjfo8eqDEyz5GaQvCcszOaILNeasgKx4WYLFHdl77u4Wta15HgR)Z(vMgMWiJ9jDygK5HY0WSWJSWCP3RS(DCPDsidDi86V8Ka4foSCVEL5frT9k3Rf]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170622.214457, [[dOJNgaGEiv0MiK2ff2MsW(GuPzQeQMnvUPs52u1ovv7vA3a7xOrra1WGOFdAzqYHfnybdNO6GqkNIaYXusFdcTqcXsjIfRklhQhQu1QGuvpwHNROjcPctLqnzknDvUib1RiaDzKRtQ2OsKTsrSzsz7qWNjsNMKPbPkZJa57krToLqz0eLdrG6KuKEnf11uc58kv(lb5zeapf1DTIlJoiTu3DvKY)0tLzLFFmimqwcgKNa3IfdpDnTzzjKJYj1pkKRiICbuOmqTIAbKlQmlNgQ0PqN5PGG(rTGaugTXPGGzf3)Afxwyq(CKTIuMhyL8R8LocCgUeyNoLLmiq(CKngengeCm8010mCjWoDklzOlVmApLtD7kJHdZp1r4YMcSQrEqCzaeqL3Gwts8p9u5Y)0tLLahMFQJWLLqokNu)OqUI4kYYsOjuhpOzf3R8Ez0W8gebYtGRVYBq7p9u5E9JQIllmiFoYwrkZdSs(vwWXWPgMvaPXGOXGpj38WqVXqhJjWfdOBmGcvz0EkN62vwthVtiOMqPcx2uGvnYdIldGaQ8g0AsI)PNkx(NEQ8s64DXaulgqtHllHCuoP(rHCfXvKLLqtOoEqZkUx59YOH5nicKNaxFL3G2F6PY96xaQ4YcdYNJSvKY8aRKFLt8P0YXzKo5YsHwg60mWjWCmGUXaYyq0yqoMqqiPdRXQHgHtNqt5kS6kJ2t5u3UYdCoLjKtjv2buaPLnfyvJ8G4YaiGkVbTMK4F6PYL)PNkVhNtzXWIRKk7akG0YsihLtQFuixrCfzzj0eQJh0SI7vEVmAyEdIa5jW1x5nO9NEQCV(rVkUSWG85iBfPmpWk5xzbhdpDnndnx6PdcKQtg6YlJ2t5u3UYAU0theivNkBkWQg5bXLbqavEdAnjX)0tLl)tpvEjx6PdcKQtLLqokNu)OqUI4kYYsOjuhpOzf3R8Ez0W8gebYtGRVYBq7p9u5E9VOkUSWG85iBfPmpWk5x5lDe4mKLk38GyVbbYNJSXGOXGGJHNUMMHggoVhobwdD5XGOXacjwLphzOPJ3TxgnmJElQmApLtD7kRHHZ7HtGTSPaRAKhexgabu5nO1Ke)tpvU8p9u5LWW59WjWwwc5OCs9Jc5kIRillHMqD8GMvCVY7LrdZBqeipbU(kVbT)0tL71)cvCzHb5Zr2kszEGvYVYpDnndnx6PdcKQtgyYNkWmgeumSqmiGXG0HngenggqOZcxgyyHqVqlRa2PbM8PcmJbbfdsh2ya9JbuLr7PCQBxznx6PdcKQtLnfyvJ8G4YaiGkVbTMK4F6PYL)PNkVKl90bbs1PyqGxfOYsihLtQFuixrCfzzj0eQJh0SI7vEVmAyEdIa5jW1x5nO9NEQCV(rSIllmiFoYwrkZdSs(v(shbodzPYnpi2BqG85iBmiAm8010m0WW59WjWAGjFQaZyqqXWcXGagdsh2yq0yyaHolCzGHfc9cTScyNgyYNkWmgeumiDyJb0pgqvgTNYPUDL1WW59WjWw2uGvnYdIldGaQ8g0AsI)PNkx(NEQ8sy48E4eyJbbEvGklHCuoP(rHCfXvKLLqtOoEqZkUx59YOH5nicKNaxFL3G2F6PY96vMhyL8RCVwa]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20170622.214457, [[d8cxcaGEbP2fsLTPOA2i5MuYTfANuzVKDdSFrQHrP(nOblsgokCqrXXqLfkkTufzXcSCfEOOQNQ6Xs65u1efHMQenzkMUsxeLCzORJsTvKInliz7kkFvqzzOQVlQ8nr0HLA0OO)kO6KiLonIRji68iv9AjSobHNjcwCQuprmunBQvz1DDe1pjMpDkwaMnOIreSHiDQ2x1NqkS9OC82CjTNZZthph)C7qQ)6GWy11Zuxce4vPCCQuNfOdOqJYQNjGqrw61XESmrq4EgKcuNwGHu7fo0bqaQBbn00dxhrDDxhrDw9yzIG0PodsbQpHuy7r54T5sYzRpHEi7rf9QuREEMyTWcodJiyvGUf046iQRvoEvQZc0buOrz1FDqyS6viKYaZbOlhby87GuG0XMHEMacfzPx3aHXWZragVoTadP2lCOdGau3cAOPhUoI66UoI6jcHX0PcJamE9jKcBpkhVnxsoB9j0dzpQOxLA1ZZeRfwWzyebRc0TGgxhrDTYLGk1zb6ak0OS6zciuKLE9CeGXVdsbQtlWqQ9ch6aia1TGgA6HRJOUURJOEyeGXVdsbQpHuy7r54T5sYzRpHEi7rf9QuREEMyTWcodJiyvGUf046iQRvR(zGvstrcDVeiqo(5jOvc]] )

    -- storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170622.212605, [[d4ZSoaGEePuBcrSlqTnQO9jjzMiQAzQQMnQMVKkUPKuDyHVjjUm0orQ9QSBv2pPyusQAyI04quPZtkDAGbtbdxv5GskNsvWXqY5KKslKISuvrlgHLtPhQkupL4XK8CrnrePWuPctgKPl1fPOEfIu5zKkxNQAJsQ0FPkBMkTDeLptQ67QszAisvZtvQEnf62smArmEePKtQk5qiQ4AssX9qKSsePOFJYXvfYJAoMy(ccocnttinq3WN3Z0e5dvGGdiTJgWUr)78FYtKJrgh9FkvLuNu6G)P0rrvzIOSGVEYKAQgWU8CmAQ5yI5li4i0mnruwWxpPz61ZryfJXHyVDzsGynSlpkOxoHPmcBXsaUCve(UUWrwHhuCkegY3gnGDKOymoe7TdMhKfEe(2CdBXsaUCvPKqoe(UUW5Mzlgr8dTW(FtQra4Gw7KiRWdkofo51bburZSto2HtOJcoPwwHhuCkCYtKJrgh9FkLtQkWP6wp6)5yI5li4i0mnP6bPfO4xCew9yNNOBIOSGVEc50aLrWPFsncah0AN4YJc6LtykJtEDqav0m7KJD4e6OGtQlpkOgdsctzCYJ1Q4OJWQh78iM8e5yKXr)Ns5KQcCQUjsc7TQZGaUa0MhX6rRBoMy(ccocntteLf81tkbYZTLvGv(wlEDvK6pLelwcWLFNue(UUWrwHhuCkegY3gnGDKOymoe7TdoYk8GItHWwSeGlt6i8DDHJScpO4uimKVnAa7ENuq(2ObSBsncah0AN4YJc6LtykJtEDqav0m7KJD4KNihJmo6)ukNuvGt1nHok4K6YJcQXGKWug1yOEQhwpAs)CmX8feCeAMMikl4RNq476cJQegM9yUEDc6P3Ir7L9pi0co9W(FKqoe(UUWrwHhuCke2)JKsG8CBzfyLV1IxxfPixNAinN8e5yKXr)Ns5KQcCQUjVoiGkAMDYXoCcDuWjMdBN8i)WioPgbGdATtWW2jpYpmIRhD1mhtmFbbhHMPjIYc(6jLa552YkWkFRfVUksvT)Kqoe(UUWrwHhuCke2)BYtKJrgh9FkLtQkWP6M86GaQOz2jh7Wj0rbNyoSDIgdsctzCsncah0ANGHTt8YjmLX1J25CmX8feCeAMMikl4RN0m965iCyBGBOAVGaWbT2jsc7TQZGaUa0MhXKNihJmo6)ukNuvGt1n51bburZSto2HtOJcorAMTyeXp0oPgbGdATtYnZwmI4hAxp6kZXeZxqWrOzAIOSGVEYKNihJmo6)ukNuvGt1n51bburZSto2HtOJcoXmhl41bxJbt8i3tQra4Gw7eKJf86G7rWJCVE0K7CmX8feCeAMMikl4RNeQgqg6HhwayUksPBsncah0ANWbpYha5vc9LWRznwM86GaQOz2jh7Wj0rbNqEWJ8bqAmu9qFj0yWbRXYKNihJmo6)ukNuvGt1TE0v7CmX8feCeAMMikl4RNq476c)XEdTEmxVob9kbYZTLvG9)iHW31fo3mBXiIFOf2)JKq1aYqp8WcaZVRBYtKJrgh9FkLtQkWP6M86GaQOz2jh7Wj0rbNqEG(K(aNEngmX49KAeaoO1oHd0N0h407rW496rtLohtmFbbhHMPjIYc(6jqSg2Lhf0lNWugHTyjaxUkvKBVguqsQxXyCi2BNNfdvxN6q476chzfEqXPqy)VhM8e5yKXr)Ns5KQcCQUjVoiGkAMDYXoCcDuWjKpil0yWKVn3tQra4Gw7eEqw4r4BZ96rtrnhtmFbbhHMPjIYc(6jLa552YkWkFRfVUks9NscHVRlmYXcEDW9Czk)mS)hjw01I5KGGJtQra4Gw7exEuqVCctzCYRdcOIMzNCSdNqhfCsD5rb1yqsykJAmu))dtEICmY4O)tPCsvbov36rt9phtmFbbhHMPjIYc(6jLa552YkWkFRfVUks9NscHVRlmYXcEDW9Czk)mS)hjHQbKHEqSg2Lhf0lNWugFV(q1aYqp8WcaZVtkDKeQgqg6HhwayUo1r3dtEICmY4O)tPCsvbov3KxheqfnZorPvXXj1iaCqRDIlpkOxoHPmoHok4K6YJcQXGKWug1y4XAvCC9OP0nhtmFbbhHMPjIYc(6jLa552YkWkFRfVUksrUoN8e5yKXr)Ns5KQcCQUjVoiGkAMDYXoCcDuWjMdBNOXGKWug1yOEQhMuJaWbT2jyy7eVCctzC9OPi9ZXeZxqWrOzAIOSGVEcHVRlCZAS4vICJwTWwSeGl)ovADQt9e(UUWnRXIxjYnA1cBXsaU87e(UUWrwHhuCkegY3gnGDKofJXHyVDWrwHhuCke2ILaCzsumghI92bhzfEqXPqylwcWLFNQAEyYtKJrgh9FkLtQkWP6M86GaQOz2jh7Wj1iaCqRDsZAS4vICJwTtOJcoXbRXIgdvpYnA1UE0uvZCmX8feCeAMMikl4RNq476cJQegM9yUEDc6P3Ir7L9pi0co9W(FtQra4Gw7emSDYJ8dJ4KxheqfnZo5yhoHok4eZHTtEKFye1yOEQhM8e5yKXr)Ns5KQcCQU1JMY5CmX8feCeAMMikl4RNeQgqg6HhwayUkQjprogzC0)PuoPQaNQBYRdcOIMzNCSdNqhfCc5dYcngmHrzsncah0ANWdYcpcmkRhnvL5yI5li4i0mnruwWxpHW31f(J9gA9yUEDc6vcKNBlRa7)rsOAazOhEybG531n5jYXiJJ(pLYjvf4uDtEDqav0m7KJD4e6OGtipqFsFGtVgdMy8wJH6PEysncah0ANWb6t6dC69iy8E9OPi35yI5li4i0mnruwWxpjunGm0dpSaWCvutEICmY4O)tPCsvbov3KxheqfnZo5yhoHok4KhNeGtJbYd0N0h40pPgbGdATtujb484a9j9bo9Rhnv1ohtmFbbhHMPjIYc(6jtEICmY4O)tPCsvbov3KxheqfnZo5yhoPgbGdATt4a9j9bo9EemEpHok4eYd0N0h40RXGjgV1yO()hwp6)05yI5li4i0mnruwWxpPWidC6jXIUwmNeeCCYtKJrgh9FkLtQkWP6M86GaQOz2jh7Wj1iaCqRDIlpkOxoHPmoHok4K6YJcQXGKWug1yOEDpSE0)uZXeZxqWrOzAsncah0AN4YJc6LtykJteLf81tcvdid9WdlamxffjHQbKHEqSg2Lhf0lNWugFpunGm0dpSaW8KhRvXrhHvp25rm5jYXiJJ(pLYjvf4uDtKe2BvNbbCbOnpttOJcoPU8OGAmijmLrngQ)XAvCuJH)hM86GaQOz2jkTkoUE0))ZXeZxqWrOzAcDuWjMdBNOXGKWug1yO()hM8e5yKXr)Ns5KQcCQUjVoiGkAMDYXoCIOSGVEsHrg40pPgbGdATtWW2jE5eMY461tOJcormtEngmZXcEDW1yOwwHhuCkC9ga]] )

    -- storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170622.212605, [[daKEoaqikkrBIIQrHQYPqv1QOOeEfksv7IqdtGJbPLPIEgbnnkkLRrrjTnkY3OQACOi6Ccf18qr19ujAFQeoOq1cPqpefjtefP4IuWgPO4KQGvkuKxsrPAMcfUjkk7eLwQk0trMkvL9k9xbnycCyLwmQ8yknzQYLbBMk(mQYOPsNwvVgcZMu3wr7gQFtYWvPoUqjlNONRW0fDDHSDvsFhfHXJIu68q06rrQmFHsTFu4IwFLmGxon4vJLy3juImedgcmOHjGZvZqWbl4ejrwIPbC2iDwJLocAyhqzpdq9hycvO4jQquu)LOBW(R(z628v4YEA6SuCB(k8O(klA9vYaE50GxnwISY)olzwMVfXJ5vko3R)ezjh9oHWHRYIO0bS3B3ujlHvyOe7oHsMrVtGHaYvzrWqaFb8x6iOHDaL9ma1eQFXaHnl7z9vYaE50GxnwISY)olXf54icwxfmcvoHPleYtcBgoIWEG8X8eJUnFUGEKs1u0gjLaoV4sM0uPJGg2bu2ZautO(fdew6a27TBQKLWkmuko3R)ezjyLPBSIweqj2DcLmSY0nwrlcOzzfwFLmGxon4vJLiR8VZsCrooIVfCIKifJUnFUGEKs1u0gjLaoV4sM0uP4CV(tKLCKQrgoCvweLoG9E7MkzjScdLy3juYms1iziGCvweLocAyhqzpdqnH6xmqyZYA2QVsgWlNg8QXsKv(3zP5c6rkvtrBKuc48IlJ5tgXuPJGg2bu2ZautO(fdew6a27TBQKLWkmuko3R)ezjyLPB4WvzruIDNqjdRmDziGCvwenlRzT(kzaVCAWRglXUtOeLk5eba3GSuCUx)jYsJujNia4gKLoG9E7MkzjScdLocAyhqzpdqnH6xmqyjYk)7SuQ4XtdIRmFN1MHl3R)eP58T28VcHagMpmUan2XEaz(yEdXLhpjmg)viCKk5eba3GK)ML1u9vYaE50GxnwISY)olv6iOHDaL9ma1eQFXaHLoG9E7MkzjScdLIZ96prwc0WeW5Qd507ilXUtOKbnmbCUAgcmQ3r2SS(RVsgWlNg8QXsKv(3zP5c6rkvtrBKuc4K5x63uP4CV(tKLEl4ejrw6a27TBQKLWkmuIDNqPdwWjsIS0rqd7ak7zaQju)IbcBwwMS(kzaVCAWRglrw5FNLwB(xHqadZhgxCPWsX5E9NilP)yf9EHZL3CdtvcZshWEVDtLSewHHshbnSdOSNbOMq9lgiSe7oHsX4Jv07XqaZwEZLHaFQeMnlBmxFLmGxon4vJLiR8VZsCrooI3kMaKHkNW0fcNlOhPunfJUnNlYXrCKk5eba3Gum6281M)vieWW8HbZfwko3R)ezj9ZZnXpMxiNsNLoG9E7MkzjScdLy3jukgpp3e)yEmeyuPtgc4Jm78x6iOHDaL9ma1eQFXaHnllAq9vYaE50GxnwISY)ol5Psrh9oHWHRYIqucZ9XJlS7idZFcmIPshbnSdOSNbOMq9lgiS0bS3B3ujlHvyOuCUx)jYs696gYfjhzj2DcLIXEDziWyKCKnllkA9vYaE50GxnwISY)olXf54i(wWjsIum62C(MlOhPunfTrsjGZlU8mi2XMlYXr8TGtKePOeM7JhmNpEwpZcUihhX3corsKIJCTiy6r5N)sX5E9Nil5ivJmC4QSikDa792nvYsyfgkXUtOKzKQrYqa5QSiyiGpu(lDe0WoGYEgGAc1VyGWMLf9S(kzaVCAWRglXSLP9NrtFRKhKJsclrw5FNLMlOhPunfTrsjGZlU8mWCUihhrqdtaNRo0rzJgIr3MlbhjmCxonWiMkfN71FISKJENq4Wvzru6a27TBQKLWkmuIDNqjZO3jWqa5QSikXuiTAW3k5b5OCLocAyhqzpdqnH6xmqyjYvXemt59opihLRzzrfwFLmGxon4vJLiR8VZsZf0JuQMI2iPeW5fxEgyoxKJJiOHjGZvh6OSrdXOBZ5JV1M)vieWW8HXLNMV28VcHEQu0rVtiC4QSiy(j)Xo28T28VcHagMpmU4sHMV28VcHEQu0rVtiC4QSiyUq(5VuCUx)jYso6DcHdxLfrPdyV3UPswYI0QHshbnSdOSNbOMq9lgiSe7oHsMrVtGHaYvzrWqaFO83SSOMT6RKb8YPbVASezL)DwIlYXr8TGtKePy0DP4CV(tKLCKQrgoCvweLoG9E7MkzjScdLyM66J5vw0sS7ekzgPAKmeqUklcgc47K)shbnSdOSNbOMq9lgiSe5QycMP8ENhKJASet5cwemtDfMaoRXMLf1SwFLmGxon4vJLiR8VZsZf0JuQMI2iPeW5fxYKMkfN71FISeSY0nC4QSikDa792nvYsyfgkDe0WoGYEgGAc1VyGWsS7ekzyLPldbKRYIGHa(q5VzzrnvFLmGxon4vJLiR8VZsCrooIsyOWl2cHPkHPOeM7JhmhnO0rqd7ak7zaQju)IbclDa792nvYsyfgkXUtOKpvctgcy2osqISuCUx)jYsPkHz4Chjir2SSO(RVsgWlNg8QXsKv(3zjUihhrW6QGrOYjmDHqEsyZWre2dKpMNy0DPJGg2bu2ZautO(fdew6a27TBQKLWkmuIDNqjdRmDJv0IayiGpu(lfN71FISeSY0nwrlcOzzrzY6RKb8YPbVASe7oHsX455M4hZJHaJkDw6iOHDaL9ma1eQFXaHLoG9E7MkzjScdLIZ96prws)8Ct8J5fYP0zjYk)7SexKJJ4TIjazOYjmDHW5c6rkvtXOBZxB(xHqadZhgmxyZYIgZ1xjd4LtdE1yjYk)7S0AZ)kecyy(W4c0shbnSdOSNbOMq9lgiS0bS3B3ujlHvyOe7oHsmL7(ygcIXZZnXpMxP4CV(tKLSU7Jd1pp3e)yEnl7zq9vYaE50GxnwISY)olvko3R)ezj9ZZnXpMxiNsNLoG9E7MkzjScdLy3jukgpp3e)yEmeyuPtgc4dL)sXL8gLkDe0WoGYEgGAc1VyGWsKRIjyMY7DEqokxjMYfSiyM6kmbCwUML9eT(kzaVCAWRglrw5FNLMQRpMN5sWrcd3LtdLocAyhqzpdqnH6xmqyPdyV3UPswcRWqP4CV(tKLC07echUklIsS7ekzg9obgcixLfbdb8DYFZYEEwFLmGxon4vJLiR8VZst11hZZ81M)vi0tLIo6DcHdxLfbZxB(xHqadZhgLocAyhqzpdqnH6xmqyPdyV3UPswYI0QHsS7ekzg9obgcixLfbdb8DYpdbmfsRgkfN71FISKJENq4Wvzr0SSNcRVsgWlNg8QXsKv(3zPP66J5v6iOHDaL9ma1eQFXaHLoG9E7MkzjScdLy3juYWktxgcixLfbdb8DYFP4CV(tKLGvMUHdxLfrZMLiR8VZsnBb]] )

    -- storeDefault( [[SEL Elemental LR]], 'actionLists', 20170622.212605, [[d0dsoaGEKuP2esYUOOTrfTprrZuLOzJy(KuLBkk0JP03erhwQDIk7vz3a7xv1OiPmmr63K6CKuvNhvzWG0WrIdkQ6uOQ6yG64QeSqk0sfvwmkwov9qsQ8uILPQ8CvzIiPIMQimzKA6cxKcoTKNrsUoi2OkHoesQWMvP2UO0NPsFxuW0qsvMhskVMk8xuA0Ky8iPsoPkPXHQIUgsQQ7HQsRevfUm0TvXdEjMya0meKEgNiwFrjMmHRp4eXWL)qnqWdcIM8d9YCtYHeSF44(sHtM6ewL5hSky4KtekOTAsrD3rPbJ7Z53K82O0G3smo4LyIbqZqq6zCIy9fLyc1ruwhfWDsEMIubVj3K(GSpfT1XKRa6Y2H2pbOb4eU(GtUiPp4purrBD8dvTu(NKdjy)WX9Lc7eoPzQQfJ7BjMya0meKEgNiwFrjMWa5(2eTkA8XQVzdfK11JDW(GaOrFbCnHqHQtJKx41htleVhbrM8LpDojhsW(HJ7lf2jCsZuvtUcOlBhA)eGgGtYZuKk4nbBFOCbiTdCcxFWjgAFOCbiTdCX4uTetmaAgcspJteRVOetonsEHxFmTq8EeezYx1)7NpMKdjy)WX9Lc7eoPzQQjxb0LTdTFcqdWj5zksf8MGTpuyFkARJjC9bNyO9HYpurrBDSyCuVLyIbqZqq6zCcxFWjsO9hhisb9tYZuKk4n5fA)XbIuq)KRa6Y2H2pbOb4KCib7hoUVuyNWjntvnrS(Ismj0UUe0S9rD32GTzksf8OsT2gvwKfb4PWxMWQN69WikG7ZSDD947vzr2xO9hhisb98VyCu)LyIbqZqq6zCIy9fLyYKCib7hoUVuyNWjntvn5kGUSDO9taAaojptrQG3eKGheenHLH0VycxFWjgi4bbrt(HAK0VyX4CUetmaAgcspJteRVOetABuzrweGNcFzYxvtYZuKk4nHuxasrZEA3tZg6aptUcOlBhA)eGgGtYHeSF44(sHDcN0mv1eU(GtUSUaKI(hAgB3t)dnHoWZIXLCjMya0meKEgNiwFrjMqRdZBsFq2NI26W0JNUaVmT9lyJ6G)8XKCib7hoUVuyNWjntvn5kGUSDO9taAaojptrQG3esNTzzG4FXeU(GtUSZ2)qncX)IfJJpxIjgandbPNXjzSPUQdKtI27IXBIQjI1xuIjNgjVWRpMwiEpcIm57xkvmqUVnrcEqq0e2BTfYZecfQ84ThFkndb)5Jj5zksf8MCt6dY(u0whtUcOlBhA)eGgGt46do5IK(G)qffT1Xe1XZsWeT3fJ3yMKdjy)WX9Lc7eoPzQQjIIodzutx3f6FJzX4u)LyIbqZqq6zCIy9fLyYPrYl86JPfI3JGit((LsfdK7BtKGheenH9wBH8mHqHk1uRTrLfzraEk8X3pQABuzrwADyEt6dY(u0whu7JF1t9uRTrLfzraEk8LjFvrvBJklYsRdZBsFq2NI26GAQ4N)j5zksf8MCt6dY(u0whtUcOlBhA)elplbNKdjy)WX9Lc7eoPzQQjC9bNCrsFWFOII264hQAW8VyCWPlXedGMHG0Z4eX6lkXKtJKx41htleVhbrM8LpDojptrQG3eS9Hc7trBDm5kGUSDO9taAaojhsW(HJ7lf2jCsZuvt46doXq7dLFOII264hQAW8VyCWWlXedGMHG0Z4eX6lkXegi33ME8PbnWISHoWJPhpDbEudoDsoKG9dh3xkSt4KMPQMCfqx2o0(janaNW1hCscDGNFOzSFb65njptrQG3Kqh4H90Va98wmo4VLyIbqZqq6zCIy9fLycdK7Bt0QOXhR(Mnuqwxp2b7dcGg9fW1ecLj5qc2pCCFPWoHtAMQAYvaDz7q7Na0aCcxFWjgAFOCbiTd8hQAW8pjptrQG3eS9HYfG0oWfJdw1smXaOzii9moHRp4KllxLaua3FOg1KysoKG9dh3xkSt4KMPQMCfqx2o0(janaNKNPivWBcPCvcqbCzz0KyIy9fLycdK7Btk6mGEw9nBOGSNgjVWRpMqOqvBJklYIa8u4JAQOIgzGCFBskxLauaxwVM2KwNbWIXbt9wIjgandbPNXjI1xuIjmqUVnPOZa6z13SHcYEAK8cV(ycHcvTnQSilcWtHpQPIQ2gvwKLwhM3K(GSpfT1b1(MKdjy)WX9Lc7eoPzQQjxb0LTdTFILNLGtYZuKk4nHuUkbOaUSmAsmHRp4KllxLaua3FOg1K4hQAQJNLG8VyCWu)LyIbqZqq6zCIy9fLysBJklYIa8u4ltyQOrgi33MKYvjafWL1RPnP1za8ZhtYHeSF44(sHDcN0mv1KRa6Y2H2pbOb4eU(GtuNsxGFOxwUkbOaUtYZuKk4nXQ0fGLuUkbOaUlghSZLyIbqZqq6zCIy9fLysBJklYIa8u4ltyQyGCFBskxLauaxwVM2ecfQABuzrwADyskxLauaxwVMMATnQSilcWtHVj5zksf8Myv6cWskxLaua3jxb0LTdTFILNLGt46dorDkDb(HEz5QeGc4(dvn1XZsq(NKdjy)WX9Lc7eoPzQQfJdo5smXaOzii9morS(IsmHgzGCFBskxLauaxwVM2KwNbWK8mfPcEtiLRsakGllJMetUcOlBhA)eGgGt46do5YYvjafW9hQrnj(HQgm)tY7DFtMKdjy)WX9Lc7eoPzQQjIIodzutx3f6FJzI6uqRJmQZIheeJzX4G5ZLyIbqZqq6zCIy9fLysBJklYIa8u4ltyQABuzrwADyskxLauaxwVMMATnQSilcWtHVj5qc2pCCFPWoHtAMQAYvaDz7q7Ny5zj4eU(GtUSCvcqbC)HAutIFOQbZ)pu1XZsWj5zksf8MqkxLauaxwgnjwmoy1FjMya0meKEgNiwFrjMmjhsW(HJ7lf2jCsZuvtUcOlBhA)eGgGt46do5YYvjafW9hQrnj(HQ2h)tYZuKk4nHuUkbOaUSmAsSyCFPlXedGMHG0Z4eX6lkXKJoBbCPYJ3E8P0meCsoKG9dh3xkSt4KMPQMCfqx2o0(janaNKNPivWBYnPpi7trBDmHRp4Kls6d(dvu0wh)qv7J)fJ7dEjMya0meKEgNiwFrjMC0zlGlvTnQSilTomVj9bzFkARdQ12OYISiapf(MKdjy)WX9Lc7eoPzQQjxb0LTdTFILNLGt46do5IK(G)qffT1Xpu1(4)hQ64zj4K8mfPcEtUj9bzFkARJfJ77BjMya0meKEgNiwFrjMC0zlG7KCib7hoUVuyNWjntvn5kGUSDO9taAaoHRp4edTpu(HkkARJFOQ9X)K8mfPcEtW2hkSpfT1XIftOoX7gcjMXfBa]] )

    -- storeDefault( [[SEL Elemental Default]], 'actionLists', 20170622.212605, [[d0t0haGEIu0Murs7IGTjq7tfPMjjvZwP5RI6MQiEmv9nsXHfTtv1EL2nL9Rk9tseggP63O61KiAOejPbdHHdjhKeofrI6ye6CejvlKKSuuYIjQLtLldEkYYGO1rIQjsIKPsknzHMUIlQcNgQNjGRdP2irk9xIyZcY2jrQVts5RejY0iskZtfjUnkoercJMeLXrKkNuq9zuQRrKQoVQyLejXZvPrrKcxXQT0HLYleRQsekWJZflnZbZT(rgezjLccLO3PQkXcwiVq)i1f1OhumGasXaIIAkrEhg1uQKc)G52TA7xSAlDyP8cXQQe5DyutPHZM9ccyBaNdnQ5wsHmEXZtj1WwuYvzq6kf2IyFoCxjJBqjwWc5f6hPUOgr9s)KbkjLWw8fbPmiDD6hz1w6Ws5fIvvPFYaLKQ8bZTsK3HrnLgoB2liGIpyUDpvPHumC2SxqWZ5BKRMDpF2Z5BKRMjec7ajWcmGn5k4aMeB3tJu60LYLyblKxOFK6Ibf1iOhOuylI95WDLmUbLuiJx88ucfFWCR0j84pzGsOC8LBSHOeuC1axN(duTLoSuEHyvvI8omQPKm6qHeg(amsyY7aUhbhWKy7EkilPqgV45P0WhGrctEhW9ukSfX(C4Usg3Gs)KbkPLpaZlItY7aUNsSGfYl0psDXGIAe0d0PFPw1w6Ws5fIvvjY7WOMsdNn7fe8C(g5Qz3sSGfYl0psDXGIAe0dukSfX(C4Usg3Gs)KbkjTyh8I4ybgWMClPqgV45PuiSdKalWa2KBN(L(QT0HLYleRQsK3HrnLgoB2li458nYvZULyblKxOFK6Ibf1iOhOuylI95WDLmUbL(jduIgUJ5fXXcmGn5wsHmEXZtP7WDmsGfyaBYTt)bR2shwkVqSQkrEhg1uA4SzVGGNZ3ixn7wsHmEXZtjybgWMCLWK3bCpLcBrSphURKXnOelyH8c9JuxmOOgb9aL(jdu6ybgWMCFrCsEhW90PFnvBPdlLxiwvLiVdJAkjftUGnc51dwmnpiawkVq88zz0HcjKxpyX08GaAuNp758nYvZeYRhSyAEqWbmj2UNw61lXcwiVq)i1fdkQrqpqPWwe7ZH7kzCdk9tgOKQLZJViKw0UNskKXlEEkjVCEusi0UNo9lDvBPdlLxiwvLiVdJAkjftUGnc51dwmnpiawkVq88zz0HcjKxpyX08GaAuLyblKxOFK6Ibf1iOhOuylI95WDLmUbL(jdusf4UGtjXg7skKXlEEkjdUl4usSXUt)s9QT0HLYleRQsK3HrnLs)GvAqcyadgUNgzPFYaLyH2u(lcfkXrjfY4fppLCOnjPFWCtYIVtPWwe7ZH7kzCdkXcwiVq)i1fdkQrqpqPt4XFYaLOd1FrCSadytUViuOehD6xuVAlDyP8cXQQ0pzGsSqBk)fHIRhSyAEOe5DyutPjxWgH86blMMhealLxiE(8cknSNIOOEjwWc5f6hPUyqrnc6bkf2IyFoCxjJBqjfY4fppLCOnjPFWCtYIVtPt4XFYaLOd1FrCSadytUViuC9GftZdD6xuSAlDyP8cXQQ0pzGsSqBk)frypecT7Pe5DyutPjxWgbShcH29iawkVq8vQuIfSqEH(rQlguuJGEGsHTi2Nd3vY4gusHmEXZtjhAts6hm3KS47u6eE8Nmqj6q9xehlWa2K7lIWEieA3tN(frwTLoSuEHyvv6NmqjwOnL)IqDmBLng2y)IGfpwI8omQP0KlyJWIzRSXWgBjoEuaSuEHyjwWc5f6hPUyqrnc6bkf2IyFoCxjJBqjfY4fppLCOnjPFWCtYIVtPt4XFYaLOd1FrCSadytUViuNvNoL(jduIou)fXXcmGn5(IqPGqj6D60ca]] )

    -- storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170622.212605, [[dSZ(iaGEjaTjPQAxsY2Ku2NeqZuQkZgv3ek(Me1JP0ovL9k2Tk7NumkjqnmPyCOKuhMQNrQmysvdxQYbjjNcLahJGZHsqleLAPkklgQwUQ6HsQEkYYiKNJIjkbWuLqtwHPR0fjuNNu6YGRtsTruICAiBwISDPYRHsFxcYNLsZdLu3MI)QiJMetdLqNur1HqjX1Ka5EOe1Vj64sq9tusYrifdj(CComc7qfaOKRMVHDiY(r92qHMbCWzG8e1iuUPMGUkrc6eekhI6bwKZrfqFrYlpr1efsLDrYJjfZtifdj(CComc7qp3aHOv(nybOh8dPchXrR2qmR8BWcqp4hAgWbNbYtuJqnHYvn6cn)giRVYFOtEqO6kGflgzhyGBdEimYXZnqOS5jkfdj(CComc7qp3aHuXyHB4Nfcr2pQ3gALTTCOYkL8HSqhtO53az9v(dDYdcPchXrR2qoJfUHFwiuDfWIfJSdmWTbp0mGdodKNOgHAcLRA0fcJC8CdekBE6sXqIphNdJWo0ZnqO(qfwnAOrpgV14A0xuUGjKkCehTAdXrfwnAmz8wJpTYfmHMbCWzG8e1iutOCvJUqZVbY6R8h6KheQUcyXIr2bg42GhcJC8CdekBESykgs854Cye2Hi7h1BdzCGZSFPPYQ()HBlqwwut)SY6C42koQvzp01o9LJk4CCom6)dL(aJIJZHqQWrC0QnujUBGjgfPfBO6kGflgzhyGBdEONBGqSe3nGg9KI0In0mGdodKNOgHAcLRA0fIuKfcJCGkHGptWdn)giRVYFOtEqimYXZnqOS5vqPyiXNJZHryhISFuVnKBxuhmbhyqadRzX(D7I6GPHCRkXDdmXOiTyzTBxuhmbhyqativ4ioA1gQe3nWeJI0In08BGS(k)HSATCi0ZnqiwI7gqJEsrAXQrFDTwoeAgWbNbYtuJqnHYvn6YMxTumK4ZX5WiSd9CdesS)xLcR2XcHuHJ4OvBiW)RsHv7yHqZao4mqEIAeQjuUQrxO53az9v(dDYdcvxbSyXi7adCBWdHroEUbcLnVYPyiXNJZHryh65giuFENRrpB1FMnez)OEBOHCRkXDdmXOiTyR(GXrhtbADMDArgOFC1LkvX9oFIr9VfQu3RFwzDoCBfh1QSh6AN(YrfCoohg972f1btWbgeWWAwm08BGS(k)Ho5bHuHJ4OvBiU35t4Q)mBO6kGflgzhyGBdEOzahCgiprnc1ekx1Oleg545giu28y1PyiXNJZHryh65giKyoyGBDUg9S5oZgISFuVneRSohUTIJAv2dDTtF5OcohNdJ(D7I6Gj4adcyyDbfA(nqwFL)qN8GqQWrC0QneWbdCRZNW5oZgQUcyXIr2bg42GhAgWbNbYtuJqnHYvn6cHroEUbcLnpwykgs854Cye2HEUbc1N35A0ZgCtiv4ioA1gI7D(eo4MqZao4mqEIAeQjuUQrxO53az9v(dDYdcvxbSyXi7adCBWdHroEUbcLnpHMumK4ZX5WiSdr2pQ3gAa4QlvQIJAv2dDTtF5OAil0f65giuDfhDA03hQvzp01gA(nqwFL)qN8GqQWrC0QnKvXr3eh1QSh6AdvxbSyXi7adCBWdnd4GZa5jQrOMq5QgDHWihp3aHYMNGqkgs854Cye2Hi7h1Bd52f1btd5wXrTk7HU2PVCWA3UOoycoWGaMqZao4mqEIAeQjuUQrxO53az9v(dz1A5qONBGq1vC0PrFFOwL9qxRg911A5qiv4ioA1gYQ4OBIJAv2dDTzZtqukgs854Cye2Hi7h1BdHRUuPkU35tmQ)TqL6EHuHJ4OvBiU35t4Q)mBO53az9v(dDYdcHr2HU2qcHEUbc1N35A0Zw9Nz1OVGfybHu9BzczKDORLLfcnd4GZa5jQrOMq5QgDHifzHWihOsi4Ze2HQRawSyKDGbUnSdHroEUbcLnpbDPyiXNJZHryhISFuVn0hk9bgfhNdHuHJ4OvBOsC3atmksl2qZVbY6R8h6KhecJSdDTHec9CdeIL4Ub0ONuKwSA0xWcSGqQ(TmHmYo01YYcHMbCWzG8e1iutOCvJUq1valwmYoWa3g2HWihp3aHYMn0ZnqisCFA0lMdg4wNRrVkwL4Sja]] )

    -- storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170622.212605, [[d8sncaGEQkAxufBdfMjvjMnLUPkCBQStPSxYUrA)qLgMi(nKHsvPblvA4svheL6yQYcrjlLQQfJOLlQfjv8uWYePNJQMivPAQqvtwLMUWfrWLvUovjTzQkSDOWNrfpwvDyjFdfnAOuNxfDsOONHqNMI7rvkpek5VqfVgvA9eEbeOfPDxXsa8ZM(qGGw5MaGGxWTlb7CJgLf3U(M3h5iRqG)zxXp1stEmty8i6j9r89yka633uwJpRWGOQLYiva7FyquEHxTNWlGaTiT7kwcGF20hcceho25PhfgeLxaBsJ1eNc6rHbrfGj9A(vGYcOi6e0k3e4lkmiQa2zo8cOLBERZD11EIdNC9xhb(NDf)uln5X4X0tcrbyH9(Cpqym3OHifCGUTYnbDURU2tC4KR)6OqTuHxabArA3vSe0k3eGhfZHB3JIpw(uaBsJ1eNccumhoUIpw(uG)zxXp1stEmEm9KquaM0R5xbklGIOtawyVp3degZnAisbhOBRCtGc1ik8ciqls7UILGw5Maiqzh3T(LfWM0ynXPa(aLDC36xwG)zxXp1stEmEm9KquaM0R5xbklGIOtawyVp3degZnAisbhOBRCtGcfc8(8r5vBiwkKa]] )

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20170622.212605, [[deeSmaqiOIyrqLAtQI0OqcofsODbvnmvvhtvzzKsptveMMQiQRbvsBJueFJizCqfPZPkQY6Gkmpsr6EQIY(if1bfIfsk8qHYfjQ2iur5JQsmsvrfNKuPzcvIBQc7ek)eQOAOQIQAPeXtrnvIYwjv8vvrL2R0FfsdMIdlAXi1Jfmzv6YGntQYNvrJwvQtt41ePMnIBtYUv8BidxOA5u1ZPY0v66iPTJe9DvjDEvH1RkImFsvTFkD)QSYYNKMa3sxglvqzwOIznYjGcMnjwZlPIMiMtCynxqVKkzllbiq6GIP9)tQFnrRw8FL5GxeFlxosyfOXvzf7RYklFsAcClDzo4fX3Yl68Ka4die5IEDCwZtTgkynB6pHf)Bij7B8XdR1OPwJwC1A0xFRzfkWA0S18Jhx))TgkwocTGi2hLPji0Lq1TL1DUIqUiF5bnq5d0vN0JLkOCzSubLFoGhjCQYsacKoOyA))K67VSeWHO6dGRY6wo2Bii9bIsqbZw6YhOlwQGYDlM2kRS8jPjWTAuMdEr8T8Iopja(4OvGgN18uRHcwtaHix0RdE9eEikqafmBsW7bvkgN1OzRrlo93A0xFRzt)jS4xHcIUOOxbynA6ZSgn53AOy5i0cIyFuooAfOPSUZveYf5lpObkFGU6KESubLlJLkO8ZhTc0uwcqG0bft7)NuF)LLaoevFaCvw3YXEdbPpqucky2sx(aDXsfuUBXEIkRS8jPjWTAuMdEr8T8IopjaEXSG3tn(6khHwqe7JYVkMBu3Bi9L1DUIqUiF5bnq5d0vN0JLkOCzSubLFUI5An8Bi9LLaeiDqX0()j13FzjGdr1haxL1TCS3qq6deLGcMT0LpqxSubL7wSNCLvw(K0e4wnkZbVi(wMMQE6H3do0KtaIUOfu49GkfJZA0uRrB5i0cIyFuErlOIQs3c(hL1DUIqUiF5bnq5d0vN0JLkOCzSubLLHwqznhPBb)JYsacKoOyA))K67VSeWHO6dGRY6wo2Bii9bIsqbZw6YhOlwQGYDlgUwzLLpjnbUvJYCWlIVLx05jbWhqiYf964khHwqe7JY6j8quGaky2Kuw35kc5I8Lh0aLpqxDspwQGYLXsfugNj8G1iNaky2KuwcqG0bft7)NuF)LLaoevFaCvw3YXEdbPpqucky2sx(aDXsfuUBX0KkRS8jPjWTAuMdEr8T8Iopja(acrUOxhx5i0cIyFu2TiVkkqafmBskR7CfHCr(YdAGYhORoPhlvq5YyPckZlYRSg5eqbZMKYsacKoOyA))K67VSeWHO6dGRY6wo2Bii9bIsqbZw6YhOlwQGYDlMuvwz5tstGB1Omh8I4B5fDEsa8beICrVoUYrOfeX(OmqafmBsIQs3c(hL1DUIqUiF5bnq5d0vN0JLkOCzSubLLtafmBsSMJ0TG)rzjabshumT)Fs99xwc4qu9bWvzDlh7neK(arjOGzlD5d0flvq5UfdNwzLLpjnbUvJYCWlIVLx05jbWhqiYf964SMNAnuWAWjwZMeyw8PlaZnNaGhMKMaxRrF9TgAQ6Ph(0fG5MtaWtnU1OV(wtaHix0Rd(0fG5MtaW7bvkgN1OzRbx)TgkwocTGi2hLPji0nQEu9pkR7CfHCr(YdAGYhORoPhlvq5YyPckRbbHUwdoJQ)rzjabshumT)Fs99xwc4qu9bWvzDlh7neK(arjOGzlD5d0flvq5Uf75vzLLpjnbUvJYCWlIVLx05jbWhqiYf964SMNAnuWAWjwZMeyw8PlaZnNaGhMKMaxRrF9TgAQ6Ph(0fG5MtaWtnU1qXYrOfeX(Omn4DGxAXCww35kc5I8Lh0aLpqxDspwQGYLXsfuwdW7aV0I5SSeGaPdkM2)pP((llbCiQ(a4QSULJ9gcsFGOeuWSLU8b6ILkOC3I99xzLLpjnbUvJYCWlIVLZWkOeIcdOeGZA0S1O1AEQ1qbRjdRGsikmGsaoRrZwJwRrF9TMmSckHOWakb4SgnBnATgkwocTGi2hL9uNOzyfOjkr42Y6oxrixKV8GgO8b6Qt6XsfuUmwQGYsOowtKWkqJ1Glc3woI)0vEsf8mCZcvmRrobuWSjXAEjv0eXCIdRjcoxoUllbiq6GIP9)tQV)YsahIQpaUkRB5yVHG0hikbfmBPlFGUyPckZcvmRrobuWSjXAEjv0eXCIdRjcoxE3I99vzLLpjnbUvJYCWlIVL3KaZIpDbyU5ea8WK0e4wocTGi2hL9uNOzyfOjkr42Y6oxrixKV8GgO8b6Qt6XsfuUmwQGYsOowtKWkqJ1Glc3Anu4JILJ4pDLNubpd3SqfZAKtafmBsSMxsfnrmN4WACI5Kawt6c4USeGaPdkM2)pP((llbCiQ(a4QSULJ9gcsFGOeuWSLU8b6ILkOmluXSg5eqbZMeR5LurteZjoSgNyojG1KUq3I9PTYklFsAcCRgL5GxeFlVjbMfVia6r1)apmjnbULJqliI9rzp1jAgwbAIseUTSUZveYf5lpObkFGU6KESubLlJLkOSeQJ1ejSc0yn4IWTwdf0sXYr8NUYtQGNHBwOIznYjGcMnjwZlPIMiMtCynoXCsaRrOhUllbiq6GIP9)tQV)YsahIQpaUkRB5yVHG0hikbfmBPlFGUyPckZcvmRrobuWSjXAEjv0eXCIdRXjMtcync96wSVNOYklFsAcCRgL5GxeFlVjbMfprC(EhXCg1JU4HjPjWTCeAbrSpk7PorZWkqtuIWTL1DUIqUiF5bnq5d0vN0JLkOCzSubLLqDSMiHvGgRbxeU1AOWtqXYr8NUYtQGNHBwOIznYjGcMnjwZlPIMiMtCynoXCsaRH4XDzjabshumT)Fs99xwc4qu9bWvzDlh7neK(arjOGzlD5d0flvqzwOIznYjGcMnjwZlPIMiMtCynoXCsaRH472TmhhcIKiEs5kqtX0QjA72c]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20170622.212605, [[d0IvcaGEkQAxIGTjcnBPCtkCBI2jv2lA3e2Vi1WKk)wYqPOYGfLgUO6GIKJrsleQ0sLQwmKwov9qrXtblJsTokknvkzYqmDHlsIUSQRdvSvOkBhk5Jqv1NHs9CL8yLA0qHdR4KqrFteDAsDEs41uK)cvLNrrXuLweukg02rikb3ipbqlZKoRY2LxetlDw8ps0MwGTztNn3)DjrNGq)BFwNo7o1KDjABNGkby715bbcP2HUelArNkTiOumOTJqCjaBVopief2y3Ec5vOlXIqkuDthkiKxHUeeWuGO3tuEcIsCcgfcEJ3nYtGGBKNG5Qqxcc9V9zD6S7utQ2rO)Rch)(lAXGqgm(2KrH1LxeeLGrH4g5jWGoBArqPyqBhH4sifQUPdfeIkUeFYzf3RGaMce9EIYtquItWOqWB8UrEceCJ8eSQ4Y0znMvCVcc9V9zD6S7utQ2rO)Rch)(lAXGqgm(2KrH1LxeeLGrH4g5jWGoZqlckfdA7iexcPq1nDOGWkkV00F(9eWuGO3tuEcIsCcgfcEJ3nYtGGBKNaeLxA6p)Ec9V9zD6S7utQ2rO)Rch)(lAXGqgm(2KrH1LxeeLGrH4g5jWGbbi)B900MFcDjOZorBgK]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20170622.212605, [[d8tZraWneP1tjsSjLk2LQQTrjI9HKYmPe1Jfz2uz(iP6MuvhwXTP4EkvANiSxPDd1(fAuusggsmovfYPjCivfQbly4kvDqvrNIsQJrQohIaluvyPevlgPwojpej5POwgLQ1PQGAEiIAQeXKvY0v5IQk9kkrspdrKRRkTrvfyReL2mIA7ukFKsKYSOePAAQkiFxvr)vP8CrnAs5YGtsj8zQY1qe05jk(nKJJi0Rjsx9kP8x8q7GvPltmgOmlmufdFDGbW34IblTXq7eyVpCmKfyphedovz5GdMmuc7u0jLILy3(VEzoPe7VYLFMobcNRKsOxjL)IhAhS6JYCsj2FL)4y4ejPcSxmqDQhdl09t2ngylRHss)vGze4CmqY7gdEPv5N0cN4KPmz3yGTSgkjTSf4LinhsvgJWqzF0s2rrmgOCzIXaL)a3yGyG1qjPLLdoyYqjStrNuDkLLdz0Rkb5kPxzQ0GKuFKnWa4R0L9rlIXaL7vc7vs5V4H2bR(O8tAHtCYugCGbW342ODt(kBbEjsZHuLXimu2hTKDueJbkxMymq5VoWa4BCXWd3KVYYbhmzOe2POtQoLYYHm6vLGCL0RmvAqsQpYgya8v6Y(OfXyGY9kbjvjL)IhAhS6JYCsj2FLPFjt(hsAiiVHiVDAWMNcMBl)IxGsG9(F3x(jTWjozkdJ60iX3rku2c8sKMdPkJryOSpAj7OigduUmXyGYFh1PrIVJuOSCWbtgkHDk6KQtPSCiJEvjixj9ktLgKK6JSbgaFLUSpArmgOCVs8HQKYFXdTdw9rzoPe7VYMbC5tHm)PxLcWxmqTDJbDDsJbQt9y4JJHrDcYt6(ZFcoNa7TzgWLpfY8d4H2bRyyNyWmGlFkK5p9Qua(IbQTBmqcSx(jTWjozkdJ602YAOK0YwGxI0CivzmcdL9rlzhfXyGYLjgdu(7OoTyG1qjPLLdoyYqjStrNuDkLLdz0Rkb5kPxzQ0GKuFKnWa4R0L9rlIXaL7vcsyLu(lEODWQpk)Kw4eNmLZhszKcWEqv2c8sKMdPkJryOSpAj7OigduUmXyGY8HugPaShuLLdoyYqjStrNuDkLLdz0Rkb5kPxzQ0GKuFKnWa4R0L9rlIXaL7vclPsk)fp0oy1hLFslCItMYobj(kwBMXZmBh6atzlWlrAoKQmgHHY(OLSJIymq5YeJbkBzbj(kwXG)4zMyqc6atz5GdMmuc7u0jvNsz5qg9QsqUs6vMknij1hzdma(kDzF0Iymq5ELG0kP8x8q7GvFuMtkX(R8cD)KDJb2YAOK0Ffygbohdulgst(2oHbIHDIHec5wOpXBkysx5N0cN4KPSBSnB0VQ8v2c8sKMdPkJryOSpAj7OigduUmXyGYwESnXWJxv(klhCWKHsyNIoP6uklhYOxvcYvsVYuPbjP(iBGbWxPl7JweJbk3ReFuLu(lEODWQpkZjLy)v2QyWmGlFkK5p9Qua(IbQTBmyNsmStmq)sM8p4adGVXTrgLEZ)V7JbRJHDIbRIbfqwbzTH2bXG1LFslCItMYKDJb2YAOK0YwGxI0CivzmcdL9rlzhfXyGYLjgdu(dCJbIbwdLKgdwPBD5NkVC5BuEWTjiVRciRGS2q7GYYbhmzOe2POtQoLYYHm6vLGCL0RmvAqsQpYgya8v6Y(OfXyGY9kbjOsk)fp0oy1hL5KsS)kBgWLpfY8NEvkaFXa12ng011JbQt9y4JJHrDcYt6(ZFcoNa7TzgWLpfY8d4H2bRyyNyWmGlFkK5p9Qua(IbQTBm8rwsmqDQhdaj(k2Vhw)zdYTaLa7TPbJ6IHDIbGeFf73dR)td2wqce2avEJ2HqRT9t6IHDIbZaU8PqM)0Rsb4lgOwmqkLyyNy4ghGV)H8bQSgkj9hWdTdwLFslCItMYWOoTTSgkjTSf4LinhsvgJWqzF0s2rrmgOCzIXaL)oQtlgynusAmyLU1LLdoyYqjStrNuDkLLdz0Rkb5kPxzQ0GKuFKnWa4R0L9rlIXaL7vcDkvs5V4H2bR(OmNuI9xz6xYK)vqgHhCc2o0bMFfygbohdKCmOtjgOo1JbRIb6xYK)vqgHhCc2o0bMFfygbohdKCmyvmq)sM8)KtaEn4e8VEvZjq4yWsngsiKBH(e)p5eGxdob)kWmcCogSog2jgsiKBH(e)p5eGxdob)kWmcCogi5yqNegdwx(jTWjozkFOdmBMjFGsMYwGxI0CivzmcdL9rlzhfXyGYLjgduwc6atm4p5duYuwo4GjdLWofDs1PuwoKrVQeKRKELPsdss9r2adGVsx2hTigduUxj01RKYFXdTdw9rzoPe7VYwfd0VKj)Vh9jO2qK3onyZmGlFkK5)DFmStmmPtyd2amyeqogi5yGKIbRJHDIbRIHfq)sM8Vt4PDyb2BtHw)l0N4yW6YpPfoXjtzNWt7WcS3gnYDLTaVeP5qQYyegk7JwYokIXaLltmgOSLfEAhwG9IHhi3v(PYlx(gLhCBcY7Ua6xYK)DcpTdlWEBk06FH(exwo4GjdLWofDs1PuwoKrVQeKRKELPsdss9r2adGVsx2hTigduUxj0TxjL)IhAhS6JYCsj2FLPFjt(Fp6tqTHiVDAWMzax(uiZ)7(yyNyysNWgSbyWiGCmqYXajv(jTWjozk7eEAhwG92OrURSf4LinhsvgJWqzF0s2rrmgOCzIXaLTSWt7WcSxm8a5UyWkDRllhCWKHsyNIoP6uklhYOxvcYvsVYuPbjP(iBGbWxPl7JweJbk3Re6KuLu(lEODWQpkZjLy)v2QyysNWgSbyWiGCmqTyqpg2jgM0jSbBagmcihdulg0JbRJHDIbRIHfq)sM8Vt4PDyb2BtHw)l0N4yW6YpPfoXjt5K2iWBoHN2HfyVYwGxI0CivzmcdL9rlzhfXyGYLjgduMkTrGJbll80oSa7v(PYlx(gLhCBcY7Ua6xYK)DcpTdlWEBk06FH(exwo4GjdLWofDs1PuwoKrVQeKRKELPsdss9r2adGVsx2hTigduUxj0)qvs5V4H2bR(OmNuI9x5jDcBWgGbJaYXa1Ib9yyNyysNWgSbyWiGCmqTyqV8tAHtCYuoPnc8Mt4PDyb2RSf4LinhsvgJWqzF0s2rrmgOCzIXaLPsBe4yWYcpTdlWEXGv6wxwo4GjdLWofDs1PuwoKrVQeKRKELPsdss9r2adGVsx2hTigduUxj0jHvs5V4H2bR(OmNuI9x5fq)sM8Vt4PDyb2BtHw)l0N4YpPfoXjtzNWt7WcS3gnYDLTaVeP5qQYyegk7JwYokIXaLltmgOSLfEAhwG9IHhi3fdwz36YpvE5Y3O8GBtqE3fq)sM8Vt4PDyb2BtHw)l0N4YYbhmzOe2POtQoLYYHm6vLGCL0RmvAqsQpYgya8v6Y(OfXyGY9kHULujL)IhAhS6JYpPfoXjtzNWt7WcS3gnYDLTaVeP5qQYyegk7JwYokIXaLltmgOSLfEAhwG9IHhi3fdwrswxwo4GjdLWofDs1PuwoKrVQeKRKELPsdss9r2adGVsx2hTigduUxj0jTsk)fp0oy1hL5KsS)kRaYkiRn0oO8tAHtCYuMSBmWwwdLKwMknij1hzdma(6JY(OLSJIymq5YwGxI0CivzmcdLjgdu(dCJbIbwdLKgdwz36YpvE5YgKnb2BxDl9BuEWTjiVRciRGS2q7GYYbhmzOe2POtQoLYYHm6vLGCL0RSpYMa7vc9Y(OfXyGY9kH(hvjL)IhAhS6JYpPfoXjtzyuN2wwdLKwMknij1hzdma(6JY(OLSJIymq5YwGxI0CivzmcdLjgdu(7OoTyG1qjPXGv2TU8tLxUSbztG92vVSCWbtgkHDk6KQtPSCiJEvjixj9k7JSjWELqVSpArmgOCVsOtcQKYFXdTdw9r5N0cN4KPmz3yGTSgkjTmvAqsQpYgya81hL9rlzhfXyGYLTaVeP5qQYyegktmgO8h4gdedSgkjngSIKSU8tLxUSbztG92vVSCWbtgkHDk6KQtPSCiJEvjixj9k7JSjWELqVSpArmgOCVEL59qsmoHLYCceUe2Te79Ab]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20170622.212605, [[daK8taqiuKSjssJsPkNsjvRsji9kLGOzPee2LQYWqHJrILrv8mLannueX1ucW2usPVPQQXPeuNdfrToLaY8uQQUNsO9HIQdQQYcvIEikLlQuzJkvLpQeqDsuQMjksDtQQDQklLO6PitfLSvsI9k9xOYGf5WkwmrEmvMmuUmyZkLptugnL60u8AOQzl0Tj1Uj8BidNK64kPy5O65cMUkxNs2ovPVJIW5vswpkI08rrz)I6QuwL2jgPiGvPsVrdLiJMTCAxe0G4MyoTapAPOriBbkNcgHSiKtMTsYHimbOppmu(ZyTE88PuICCJ6RuPFUZGeHYQpLYQ0oXifbSUSe54g1xjMkNoJdVrilNygZYjm09TfhnGlyJC4)4GEmIqoT)fZjzoSs)KmrZTQ0wC0aUGnYHVe7cmJBoeVKajGs(imvg(B0qPsVrdL2xC0qor2ih(sYHimbOppmu(RWOKCiGS4oiuw9kXMn4W7J8cAqCvQKpc7nAOuV(8uwL2jgPiG1LLih3O(kjzTT9boBeeWH2WD2aozCyoCblbgWnczFwQZjvZj9aXWXr6pNfNdIlNy(I50cV2s)KmrZTQem8ZEnwdEOe7cmJBoeVKajGs(imvg(B0qPsVrdL2n8ZEnwdEOKCicta6ZddL)kmkjhcilUdcLvVsSzdo8(iVGgexLk5JWEJgk1RVfSSkTtmsraRllroUr9vsYAB7Z4Gnl(Qpl15KQ5KEGy44i9NZIZbXLtmFXCsrrjNunNyQCsYAB7BcoqGnch8zPU0pjt0CRkTXrHdxWg5WxIDbMXnhIxsGeqjFeMkd)nAOuP3OHs7JJcxor2ih(sYHimbOppmu(RWOKCiGS4oiuw9kXMn4W7J8cAqCvQKpc7nAOuV(yskRs7eJueW6Ys)KmrZTQeebniUjItkoHRe7cmJBoeVKajGs(imvg(B0qPsVrdL2fbniUjMtlJt4kjhIWeG(8Wq5VcJsYHaYI7Gqz1ReB2GdVpYlObXvPs(iS3OHs96BbuwL2jgPiG1LLih3O(kPhigoos)5S4CqC5eZxmNuu(NtmJz5etLtd)mBJ7(cmbeJgHmC6bIHJJ0FGyKIawoPAoPhigoos)5S4CqC5eZxmNyYEk9tYen3QsWWpBCbBKdFj2fyg3CiEjbsaL8ryQm83OHsLEJgkTB4NDor2ih(sYHimbOppmu(RWOKCiGS4oiuw9kXMn4W7J8cAqCvQKpc7nAOuV(wBzvANyKIawxw6NKjAUvLchIRXdGAGxIDbMXnhIxsGeqjFeMkd)nAOuP3OHs0H4A8aOg4LKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE99VSkTtmsraRllroUr9vAVCspqmCCK(ZzX5G4YP9VyoPWqjNunNg(z2g39fycigncz40dedhhP)aXifbSCIzmlNyQCA4NzBC3xGjGy0iKHtpqmCCK(deJueWYjvZj9aXWXr6pNfNdIlN2)I50)1MtRNtQMtmvojzTT9nbhiWgHd(Sux6NKjAUvLmoyZIVQe7cmJBoeVKajGs(imvg(B0qPsVrdLy3bBw8vLKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE9TWLvPDIrkcyDzPFsMO5wvkAwJLbdNEKPhCh6aDj2fyg3CiEjbsaL8ryQm83OHsLEJgkX0M1yzWYj)rMEYjwOd0LKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE9XKlRs7eJueW6YsKJBuFLKS22(uJycGJdTH7SbC6bIHJJ0FwQZjvZjjRTTVWH4A8aOg4FwQZjvZPXDgVaoqaAdeYP9NtlyPFsMO5wvkAKzFcJqgoju8kXUaZ4MdXljqcOKpctLH)gnuQ0B0qjM2iZ(egHSCAjkELKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE9PWOSkTtmsraRllroUr9vcdDFBXrd4c2ih(poOhJiKtmpNCt4WDgnKtQMtoekIHycboomUR0pjt0CRkfhVdojlE4kXUaZ4MdXljqcOKpctLH)gnuQ0B0qjME8o50slE4kjhIWeG(8Wq5VcJsYHaYI7Gqz1ReB2GdVpYlObXvPs(iS3OHs96trPSkTtmsraRllroUr9vsYAB7Z4Gnl(Qpl15KQ50E5KEGy44i9NZIZbXLtmFXCYdJCIzmlNKS22(moyZIV6Jd6Xic50(ZP9YjLVfqoTqZPGAigXzpHdYPfAojzTT9zCWMfF1x4gh(CAHmNuYP1ZP1l9tYen3QsBCu4WfSro8LyxGzCZH4LeibuYhHPYWFJgkv6nAO0(4OWLtKnYHpN2tz9sYHimbOppmu(RWOKCiGS4oiuw9kXMn4W7J8cAqCvQKpc7nAOuV(u8uwL2jgPiG1LLih3O(kTxoPhigoos)5S4CqC5eZxmN8WiNunNKS22(GiObXnrCBiNv4ZsDoTEoPAoTxoXHnoeShPiKtRx6NKjAUvL2IJgWfSro8LyxGzCZH4LeibuYhHPYWFJgkv6nAO0(IJgYjYg5WNt7PSEPFCzHs3WLbhoZ2ICyJdb7rkcLKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE9PSGLvPDIrkcyDzjYXnQVsswBBFghSzXx9zPU0pjt0CRkTXrHdxWg5WxInBWH3h5f0G46Ys(imvg(B0qPsSlWmU5q8scKak9gnuAFCu4YjYg5WNt75z9s)4YcL0iVgHSfvkjhIWeG(8Wq5VcJsYHaYI7Gqz1RKpYRriRpLs(iS3OHs96tHjPSkTtmsraRllroUr9vspqmCCK(ZzX5G4YjMVyoPOOKtmJz5etLtd)mBJ7(cmbeJgHmC6bIHJJ0FGyKIawoPAoPhigoos)5S4CqC5eZxmNw41MtmJz5eSglJA1a2xqJIya3iKHZgg(LtQMtWASmQvdyFNnGddCGXlWd4KIiego1J7YjvZj9aXWXr6pNfNdIlNyEo9NroPAoDtee33SDapyJC4)aXifbSs)KmrZTQem8ZgxWg5WxIDbMXnhIxsGeqjFeMkd)nAOuP3OHs7g(zNtKnYHpN2tz9sYHimbOppmu(RWOKCiGS4oiuw9kXMn4W7J8cAqCvQKpc7nAOuV(uwaLvPDIrkcyDzjYXnQVsswBBFCiGeJWb4o0b6poOhJiKt7pNuyu6NKjAUvLo0bAC6jCaFvj2fyg3CiEjbsaL8ryQm83OHsLEJgkXcDGoN8NWb8vLKdrycqFEyO8xHrj5qazXDqOS6vInBWH3h5f0G4QujFe2B0qPE9PS2YQ0oXifbSUSe54g1xjjRTTpWzJGao0gUZgWjJdZHlyjWaUri7ZsDPFsMO5wvcg(zVgRbpuIDbMXnhIxsGeqjFeMkd)nAOuP3OHs7g(zVgRbpKt7PSEj5qeMa0Nhgk)vyusoeqwChekRELyZgC49rEbniUkvYhH9gnuQxFk)lRs7eJueW6YsKJBuFLKS22(uJycGJdTH7SbC6bIHJJ0FwQZjvZPXDgVaoqaAdeYP9NtlyPFsMO5wvkAKzFcJqgoju8kXUaZ4MdXljqcOKpctLH)gnuQ0B0qjM2iZ(egHSCAjkE50EkRxsoeHja95HHYFfgLKdbKf3bHYQxj2SbhEFKxqdIRsL8ryVrdL61NYcxwL2jgPiG1LLih3O(knUZ4fWbcqBGqoX8CsjNunNg3z8c4abOnqiNyEoPu6NKjAUvLC2JrGlAKzFcJqwj2fyg3CiEjbsaL8ryQm83OHsLEJgkXM9ye5etBKzFcJqwj5qeMa0Nhgk)vyusoeqwChekRELyZgC49rEbniUkvYhH9gnuQxFkm5YQ0oXifbSUS0pjt0CRkfnYSpHridNekELyxGzCZH4LeibuYhHPYWFJgkv6nAOetBKzFcJqwoTefVCAppRxsoeHja95HHYFfgLKdbKf3bHYQxj2SbhEFKxqdIRsL8ryVrdL61NhgLvPDIrkcyDzjYXnQVsCyJdb7rkcL(jzIMBvPT4ObCbBKdFj2SbhEFKxqdIRll5JWuz4VrdLkXUaZ4MdXljqcO0B0qP9fhnKtKnYHpN2ZZ6L(XLfkPrEnczlQSqCdxgC4mBlYHnoeShPiusoeHja95HHYFfgLKdbKf3bHYQxjFKxJqwFkL8ryVrdL61NhLYQ0oXifbSUS0pjt0CRkbd)SXfSro8LyZgC49rEbniUUSKpctLH)gnuQe7cmJBoeVKajGsVrdL2n8ZoNiBKdFoTNN1l9JllusJ8AeYwuPKCicta6ZddL)kmkjhcilUdcLvVs(iVgHS(uk5JWEJgk1RppEkRs7eJueW6Ys)KmrZTQ0wC0aUGnYHVeB2GdVpYlObX1LL8ryQm83OHsLyxGzCZH4Leibu6nAO0(IJgYjYg5WNt7TGRx6hxwOKg51iKTOsj5qeMa0Nhgk)vyusoeqwChekREL8rEncz9PuYhH9gnuQxVsKAWzMOHjDods0NN16Pxl]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20170622.212605, [[d8Z9jaWCPA9erLnbuzxsQ2gru2hakZKiYJv0SPy(aqDts6WuDBsDEuv2Pc7vSBq7hv(jaqddiJdaKtt4BaLbJudNi5GsWPis1XiX5aaSqj0srvwmswoLEiG6PqlJOADaq8zjzQiyYsz6kDrjLxtuUSQRJiBeaXwrv1MbOTJqFeauZcastdq08aK8xe1ZiIQgTe9DaPojryuePCnauDpGQoeas)gLJdiCucHG1GoL5TqfC46hefAG5ORzU(W1nC0aWUMYiGvaiC0faaRfK3n37pd5GuadKKjxEDLG40kKAdgSWCfmypeYqjecwd6uM3sXGfOegXYxW(YSAz)sDBqjGnX0xMniKbFqvwJF3oC9dgC46hexMvl7xQBdY7M79NHCqkGPakiV3zKSZ3dHSbbU8tzQmIxF4gQGQS2W1py2mKhcbRbDkZBPyqCAfsTbxwvL51NmMPXaAypybkHrS8f07ZdBoC(GsaBIPVmBqid(GQSg)UD46hm4W1pyH(8WMdNpiVBU3FgYbPaMcOG8ENrYoFpeYge4YpLPYiE9HBOcQYAdx)GzZqYhcbRbDkZBPyWcucJy5lOraeKenYAVs7Kx2EDqjGnX0xMniKbFqvwJF3oC9dgC46huscGGKOXrR6vANJMaBVoiVBU3FgYbPaMcOG8ENrYoFpeYge4YpLPYiE9HBOcQYAdx)GzZaidHG1GoL5TumioTcP2GsJJ2NRG4jF41I35ObkoAGKJgCC0A)M(Az66tsw7Hlhnad8C0YbXrlDoAWXrlnoA7b0(EPtzohT0dwGsyelFbb046tUxYMYckbSjM(YSbHm4dQYA872HRFWGdx)GaeJRphnwYMYcwWw1dUUT6lzbGG3EaTVx6uMhK3n37pd5GuatbuqEVZizNVhczdcC5NYuzeV(WnubvzTHRFWSzaWdHG1GoL5TumybkHrS8f8UDlbcsUShucytm9LzdczWhuL143Tdx)GbhU(bR52Teii5YEqE3CV)mKdsbmfqb59oJKD(EiKniWLFktLr86d3qfuL1gU(bZMHKfcbRbDkZBPyqCAfsTbBSToGgxFY9s2uwD71Ua25ObyC0tVVKxH(C0GJJMIeGaw34eDYDs2QxNKuC0GJJgGYrVU5WTUruvUqbSISL1QFOtzEJJgCC0(Cfep5dVw8ohnqXrdKblqjmILVGgNOtMIKTVbLa2etFz2Gqg8bvzn(D7W1pyWHRFqj5eDo6IKS9niVBU3FgYbPaMcOG8ENrYoFpeYge4YpLPYiE9HBOcQYAdx)GzZaSqiynOtzElfdItRqQniaLJEDZHBDJOQCHcyfzlRv)qNY8ghn44O95kiEYhET4DoAGIJgGZrdGbWC0RBoCRBevLluaRiBzT6h6uM34ObhhTpxbXt(WRfVZrduC0azWcucJy5l4nxF46gYugVVbLa2etFz2Gqg8bvzn(D7W1pyWHRFWAMRpCDdhDrJ33G8U5E)zihKcykGcY7Dgj789qiBqGl)uMkJ41hUHkOkRnC9dMndaOqiynOtzElfdwGsyelFbnorNm1DDqjGnX0xMniKbFqvwJF3oC9dgC46husorNJU4DDqE3CV)mKdsbmfqb59oJKD(EiKniWLFktLr86d3qfuL1gU(bZMbaqieSg0PmVLIbXPvi1gSDksacyDJOQCHcyfzlRvVXaAyWcucJy5l4S0fqYgrv5cfWQGsaBIPVmBqid(GQSg)UD46hm4W1piWLUaYrljrv5cfWQGfSv9GRBR(swai4BNIeGaw3iQkxOawr2YA1BmGggK3n37pd5GuatbuqEVZizNVhczdcC5NYuzeV(WnubvzTHRFWSzOakecwd6uM3sXGfOegXYxWzPlGKnIQYfkGvbLa2etFz2Gqg8bvzn(D7W1pyWHRFqGlDbKJwsIQYfkGvC0str6b5DZ9(ZqoifWuafK37ms257Hq2Gax(PmvgXRpCdvqvwB46hmBgkkHqWAqNY8wkgSaLWiw(cACIozks2(ge4YpLPYiE9HBkguL143Tdx)GbLa2etFz2Gqg8bhU(bLKt05OlsY2xoAPPi9GfSv9GAgrbSc8kb5DZ9(ZqoifWuafK37ms257Hq2GQmIcyvgkbvzTHRFWSzOipecwd6uM3sXG40kKAdApG23lDkZdwGsyelFbb046tUxYMYccC5NYuzeV(WnfdQYA872HRFWGsaBIPVmBqid(Gdx)GaeJRphnwYMY4OLMI0dwWw1dQzefWkWRaGUUT6lzbGG3EaTVx6uMhK3n37pd5GuatbuqEVZizNVhczdQYikGvzOeuL1gU(bZMnik1Nc3iKC(kyWmKlzYZMa]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20170622.212605, [[d8d9saqBswpssYMiO2LuABiKSpPOMjcHhtXSLy(ijUPK6WI(gc15rsTtqTxLDd1(P0OarnmezCcr60u5ViyWu1WfsheK6uGihJuDoKKyHGWsjulgPworpKG8uultkSoHi47KcnvcmzPA6axeK8kHi6zKcCDjzJij1wjfTze12jL(OqeAwijPMgcrMNquhIuqpxWOfQxJeNui8zc5Aie19KICzv)gYXri1tFcgdfoPlVp6XWP6JzNsiRhQYvhdYI1hjMk6IdlksW6doSOYT(mygl(LNHp4gK0jMer1OrR(y2iDrbJhdTb4q4Wemy9jymu4KU8(GymBKUOGXaKirL3AqOshPrCW6f26HS13rGwYLuDcHyKHsR8Q0HdwFZwpDfzYTzWCCpXM32RKjWHWwVWwVbHkDKgXTLuBsGUsgaTYRshoy9nB9KSEHTEn06PRitUnaqsfL)Ox2wf16H0yOPDfhG6XzWCCpXMpocC3zsasogJWFCnQRzkHt1hpgovFm0bZX9eB(yXV8m8b3GKoX6Kgl(buL08WemWyHIVHsns7vhdg94AuhovF8adUXemgkCsxEFqmMnsxuWyn06bodfhwK1tfQy9DeOLCjvNqigzO0kVkD4G1h5MSErM(yOPDfhG6XKlP6ecXidLXrG7otcqYXye(JRrDntjCQ(4XWP6JP6sQU1ZXidLXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgSgmbJHcN0L3heJzJ0ffmwLVeasKQ1ujLhdS(MBY6BqY6f26LxLoCW6JCtwpDfzYTzWCCpXM32RKjWHWwVWwVbHkDKgXTzWCCpXM3kVkD4G1hjTE6kYKBZG54EInVTxjtGdHT(i3K13RKjWHWJHM2vCaQhtUKQtieJmughbU7mjajhJr4pUg11mLWP6JhdNQpMQlP6wphJmuSEiRdPXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgmrAcgdfoPlVpigdnTR4aup(LRogKfc0LmaghbU7mjajhJr4pUg11mLWP6JhdNQpgQYvhdYI1drjdGXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgmrEcgdfoPlVpigZgPlkymDfzYT3eJEGaImbq8jis(eqiuH7x6WIARIA9cB9AO1txrMCBgmh3tS5TvrTEHTEv(sairQwtLuEmW6BUjRpsjQXqt7koa1JFkbXeDvs5JJa3DMeGKJXi8hxJ6AMs4u9XJHt1hdvkbXeDvs5Jf)YZWhCds6eRtAS4hqvsZdtWaJfk(gk1iTxDmy0JRrD4u9XdmyIAcgdfoPlVpigZgPlkySkFjaKivRPskpgy9n3K1RRtS1tfQy9AO1NsGJCAaTbn(sXHfrqLVeasKQ94KU8U1lS1RYxcajs1AQKYJbwFZnz9uLgJHM2vCaQh)ucIjeIrgkJJa3DMeGKJXi8hxJ6AMs4u9XJHt1hdvkbXwphJmugl(LNHp4gK0jwN0yXpGQKMhMGbglu8nuQrAV6yWOhxJ6WP6JhyWepbJHcN0L3heJHM2vCaQhhaiPIYF0lhhbU7mjajhJr4pUg11mLWP6JhdNQpMbiPIYF0lhl(LNHp4gK0jwN0yXpGQKMhMGbglu8nuQrAV6yWOhxJ6WP6JhyWr6emgkCsxEFqmgAAxXbOECXr0vUobvksLeaiWvJJa3DMeGKJXi8hxJ6AMs4u9XJHt1hteoIUY1T(6uKkTEbiWvJf)YZWhCds6eRtAS4hqvsZdtWaJfk(gk1iTxDmy0JRrD4u9XdmyQYemgkCsxEFqmMnsxuWy6kYKBJI04LeqKjaIpbv(sairQ2QOwVWwpDfzYTbasQO8h9Y2QOwVWwFAaoTNWXx5EW6JS1RbJHM2vCaQhxCIIbyhwebAubmocC3zsasogJWFCnQRzkHt1hpgovFmr4efdWoSiRhcubmw8lpdFWniPtSoPXIFavjnpmbdmwO4BOuJ0E1XGrpUg1Ht1hpWG1jnbJHcN0L3heJzJ0ffmUJaTKlP6ecXidLw5vPdhS(MTEtgaeao1TEHTEiB9geQ0rAetq(0aSEQqfRNUIm52myoUNyZBRIA9qAm00UIdq94sQnjqxjdGXrG7otcqYXye(JRrDntjCQ(4XWP6JjIuBA9qujdGXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgSU(emgkCsxEFqmMnsxuWyiB9Q8LaqIuTMkP8yG13CtwFdswVWwpDfzYTVC1XGSqGmYufARIA9qY6f26HS1lpz5dXjD5wpKgdnTR4aupMCjvNqigzOmocC3zsasogJWFCnQRzkHt1hpgovFmvxs1TEogzOy9qUbKgdTuuymiLIoGGJCtYtw(qCsx(yXV8m8b3GKoX6Kgl(buL08WemWyHIVHsns7vhdg94AuhovF8adwVXemgkCsxEFqmMnsxuWyv(sairQwtLuEmW6BUjRxxx36PcvSEn06tjWronG2GgFP4WIiOYxcajs1ECsxE36f26v5lbGePAnvs5XaRV5MS(iLOSEQqfR)eDLlA03BdkuPFPdlIq8tjW6f26prx5Ig99wq8j0V5oTxgiqxqOoHOPby9cB9Q8LaqIuTMkP8yG13S1tmjRxyRhKLJbTjzWLHyKHs7XjD59Xqt7koa1JFkbXecXidLXrG7otcqYXye(JRrDntjCQ(4XWP6JHkLGyRNJrgkwpK1H0yXV8m8b3GKoX6Kgl(buL08WemWyHIVHsns7vhdg94AuhovF8adwxdMGXqHt6Y7dIXSr6IcgtxrMCR8beoXMtaGax1kVkD4G1hzRxNK1tfQy9q26PRitUv(acNyZjaqGRALxLoCW6JS1dzRNUIm52myoUNyZB7vYe4qyRpsA9geQ0rAe3MbZX9eBER8Q0HdwpKSEHTEdcv6inIBZG54EInVvEv6WbRpYwVor26H0yOPDfhG6Xae4kcQmaUK6XrG7otcqYXye(JRrDntjCQ(4XWP6JfGaxz91zaCj1Jf)YZWhCds6eRtAS4hqvsZdtWaJfk(gk1iTxDmy0JRrD4u9XdmyDI0emgkCsxEFqmMnsxuW40aCApHJVY9G13S1RB9cB9Pb40EchFL7bRVzRxFm00UIdq94sQnjq)unocC3zsasogJWFCnQRzkHt1hpgovFmrKAtRhINQXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgSorEcgdfoPlVpigZgPlkymDfzYTrrA8sciYeaXNGkFjaKivBvuRxyRpnaN2t44RCpy9r261GXqt7koa1JlorXaSdlIanQaghbU7mjajhJr4pUg11mLWP6JhdNQpMiCIIbyhwK1dbQaSEiRdPXIF5z4dUbjDI1jnw8dOkP5HjyGXcfFdLAK2Rogm6X1OoCQ(4bgSornbJHcN0L3heJzJ0ffmonaN2t44RCpy9nB96wVWwFAaoTNWXx5EW6B261hdnTR4aup2eNomHItuma7WIghbU7mjajhJr4pUg11mLWP6JhdNQpwO40HTEIWjkgGDyrJf)YZWhCds6eRtAS4hqvsZdtWaJfk(gk1iTxDmy0JRrD4u9XdmyDINGXqHt6Y7dIXqt7koa1JlorXaSdlIanQaghbU7mjajhJr4pUg11mLWP6JhdNQpMiCIIbyhwK1dbQaSEi3asJf)YZWhCds6eRtAS4hqvsZdtWaJfk(gk1iTxDmy0JRrD4u9Xdmy9iDcgdfoPlVpigZgPlkyS8KLpeN0LpgAAxXbOEm5sQoHqmYqzSqX3qPgP9QJbdIX1OUMPeovF84iWDNjbi5ymc)XWP6JP6sQU1ZXidfRhYAaKgdTuuyScP1Hf1KovniLIoGGJCtYtw(qCsx(yXV8m8b3GKoX6Kgl(buL08WemW4AKwhw0G1hxJ6WP6JhyW6uLjymu4KU8(Gym00UIdq94NsqmHqmYqzSqX3qPgP9QJbdIX1OUMPeovF84iWDNjbi5ymc)XWP6JHkLGyRNJrgkwpKBaPXqlffgRqADyrnPpw8lpdFWniPtSoPXIFavjnpmbdmUgP1Hfny9X1OoCQ(4bgCdstWyOWjD59bXyOPDfhG6XKlP6ecXidLXcfFdLAK2RogmigxJ6AMs4u9XJJa3DMeGKJXi8hdNQpMQlP6wphJmuSEitKG0yOLIcJviToSOM0hl(LNHp4gK0jwN0yXpGQKMhMGbgxJ06WIgS(4AuhovF8admMJEJlloQQe4q4b3GOAmWg]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170622.212605, [[deKzmaqivPQweuvTjHOgfrItbvLDPQAyQkhtvSmsYZusPPPkv01GQKTbvrFdfACqvW5uLQyDQszEej19usX(eICqsQfIcEOqAIQsL6IeLnsKeJuvQKtsuzMqvQBQe7ek)eQcnuvPkTuuQNImvIyRev9vIK0EL(RqzWuCyflMepwWKvQld2mrQpJIgTQKtt41OKMnQUnP2Tk)gYWfQwov9CQmDrxhQSDuIVRKQZRKSEvPcZxiSFkDFQKsYUrHd7Yqjkoeedx8oMuGUIPcpvv6Ddsp44zzOeBGdJdkMQVhg)WZN1(R6zTppmwIcEr8Suj1HuGoxLuSNkPKSBu4WUkLOGxeplLiMm5WFaH4B06NZAIS1ifRjhpti)FbdpF9hpKwJuBnQWlRjIiSMuObRjswZ3pE99zn4RKAfbxKRkPWrOnhNllj3TfHjr(sh6GslOT8JhB0qPsyJgk9Uaps40LydCyCqXu99W4Zxj2GdHZhaxL0Su0xqG1felGgUSkLwqBSrdLAwmvvsjz3OWHDzOef8I4zPeXKjh(JJsb6CwtKTgPynbeIVrRF)sl8qmGdA4YH)7b9ioN1ejRrfE4ZAIicRjhpti)tHgILOyBbyns9ASg88ZAWxj1kcUixvkokfORKC3weMe5lDOdkTG2YpESrdLkHnAO07fLc0vInWHXbft13dJpFLydoeoFaCvsZsrFbbwxqSaA4YQuAbTXgnuQzXwBLus2nkCyxgkrbViEwkrmzYHFXLG3JlE6kPwrWf5QsRlUDm3ly8LK72IWKiFPdDqPf0w(XJnAOujSrdLKQIBBn0ly8LydCyCqXu99W4Zxj2GdHZhaxL0Su0xqG1felGgUSkLwqBSrdLAwS3zLus2nkCyxgkrbViEwsbN0s)7bh6MlaXsuc6FpOhX5SgP2AuvsTIGlYvLsuc6y6XLGFvj5UTimjYx6qhuAbTLF8yJgkvcB0qjjOe0wZY4sWVQeBGdJdkMQVhgF(kXgCiC(a4QKMLI(ccSUGyb0WLvP0cAJnAOuZIHxvsjz3OWHDzOef8I4zPeXKjh(dieFJw)CLuRi4ICvjPfEigWbnC5Wlj3TfHjr(sh6GslOT8JhB0qPsyJgkjveEWAKXbnC5WlXg4W4GIP67HXNVsSbhcNpaUkPzPOVGaRliwanCzvkTG2yJgk1Sy4zLus2nkCyxgkrbViEwkrmzYH)acX3O1pxj1kcUixvYLiVogWbnC5Wlj3TfHjr(sh6GslOT8JhB0qPsyJgkrjYRTgzCqdxo8sSbomoOyQ(Ey85ReBWHW5dGRsAwk6liW6cIfqdxwLslOn2OHsnlgJvsjz3OWHDzOef8I4zPeXKjh(dieFJw)CLuRi4ICvjGdA4YHhtpUe8Rkj3TfHjr(sh6GslOT8JhB0qPsyJgkjJdA4YHBnlJlb)QsSbomoOyQ(Ey85ReBWHW5dGRsAwk6liW6cIfqdxwLslOn2OHsnlgEOskj7gfoSldLOGxeplLiMm5WFaH4B06NZAIS1ifR59TMC4WL)Jla3EUa8d3OWHT1erewJcoPL(FCb42ZfGFCXTMiIWAcieFJw)(hxaU9Cb43d6rCoRjswdE9zn4RKAfbxKRkPWrODmPX5xvsUBlctI8Lo0bLwqB5hp2OHsLWgnuIbocTTgPco)QsSbomoOyQ(Ey85ReBWHW5dGRsAwk6liW6cIfqdxwLslOn2OHsnl27Pskj7gfoSldLOGxeplLiMm5WFaH4B06NZAIS1ifR59TMC4WL)Jla3EUa8d3OWHT1erewJcoPL(FCb42ZfGFCXTg8vsTIGlYvLuaVd8SkoMLK72IWKiFPdDqPf0w(XJnAOujSrdLya8oWZQ4ywInWHXbft13dJpFLydoeoFaCvsZsrFbbwxqSaA4YQuAbTXgnuQzXE(QKsYUrHd7Yqjk4fXZstifSaXGd0cWznrYAuznr2AKI1mHuWcedoqlaN1ejRrL1erewZesblqm4aTaCwtKSgvwd(kPwrWf5QsECxSjKc0fJlCzj5UTimjYx6qhuAbTLF8yJgkvcB0qj24oRrDifOZAWBHllP2Z0v6gnSg8tcDuRrgh0WLd)nRrnEug(lXg4W4GIP67HXNVsSbhcNpaUkPzPOVGaRliwanCzvkTG2yJgkrcDuRrgh0WLd)nRrnEuwZI98ujLKDJch2LHsuWlINLYHdx(pUaC75cWpCJch2LuRi4ICvjpUl2esb6IXfUSKC3weMe5lDOdkTG2YpESrdLkHnAOeBCN1OoKc0zn4TWLwJuEWxj1EMUs3OH1GFsOJAnY4GgUC4VznoXXKdwZ4c4VeBGdJdkMQVhgF(kXgCiC(a4QKMLI(ccSUGyb0WLvP0cAJnAOej0rTgzCqdxo83SgN4yYbRzCHMf7rvLus2nkCyxgkrbViEwkhoC5ViasJZV6hUrHd7sQveCrUQKh3fBcPaDX4cxwsUBlctI8Lo0bLwqB5hp2OHsLWgnuInUZAuhsb6Sg8w4sRrkQWxj1EMUs3OH1GFsOJAnY4GgUC4VznoXXKdwJqA8xInWHXbft13dJpFLydoeoFaCvsZsrFbbwxqSaA4YQuAbTXgnuIe6OwJmoOHlh(BwJtCm5G1iKUzXEwBLus2nkCyxgkrbViEwkhoC5pxW8vEIJzmpA)d3OWHDj1kcUixvYJ7InHuGUyCHllj3TfHjr(sh6GslOT8JhB0qPsyJgkXg3znQdPaDwdElCP1iL1IVsQ9mDLUrdRb)Kqh1AKXbnC5WFZACIJjhSgUh)LydCyCqXu99W4Zxj2GdHZhaxL0Su0xqG1felGgUSkLwqBSrdLiHoQ1iJdA4YH)M14ehtoynCFZMLWgnuIe6OwJmoOHlh(BwZgKEWXZMTa]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170622.212605, [[d4cxcaGErq7sezBIqZwk3KuDBs2jv2lA3e2pe1WKk)wYqPKYGHQmCr1bfjhdslKOAPqyXez5u1dfPEk4Xk16ebMiLKMkLAYqz6cxKsCzvxxQYwHk2mLeBhQQplI6WkEUsgnuPLjkNuQQNbronfNNu6BKIxtu(lLunrPnblIrQDmkNGBuNayuPrgplTRUiMwcqgVC)3LsAccw9wz61ckNaI3(SoDzDOA6sefPKYqrcfvdby7n5bbcP2HPelAthkTjyrmsTJr5eGT3KheIk5KBpP8kmLyriLKPzcTeYRWucc9fyM9eLNGOeNGEHHZ4DJ6ei4g1jyTkmLGaI3(SoDzDOAq7iG4RQNF)fTzqinUFltVW)QlckrqVWCJ6eyqxgTjyrmsTJr5esjzAMqlHOIRSUAwX9Aj0xGz2tuEcIsCc6fgoJ3nQtGGBuNGDfxHmE6ZkUxlbeV9zD6Y6q1G2raXxvp)(lAZGqAC)wMEH)vxeuIGEH5g1jWGoKOnblIrQDmkNqkjtZeAjSIYRK9NFpH(cmZEIYtquItqVWWz8UrDceCJ6eGO8kz)53taXBFwNUSounODeq8v1ZV)I2miKg3VLPx4F1fbLiOxyUrDcmyqaY)2mntcNWuc6YsmJbja]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170622.212605, [[deetsaqiKqztuQAuusofLuRIsfYROubnlkvOUfuk0Uuvggs6yKQLPGEgrPMguk4AqPKTbLQ(guY4GsPohukADiHQMhsi3tvK9HeCqvvwOQWdjkMisOYfvv1gPurNKsyMuQ0nf0oHQLsu9uutfPSvkr7v6Vk0Gf1HvAXe5Xu1Kv0LbBgk(SaJMuonHxJunBQCBk2nIFdz4kWXHsLLtYZfA6QCDvPTtP8DvrDEKO1tPcmFIs2Vix9sR8FYk5GzFuMIdWSVURpkZELyWvUmpa8I1jSd2tGifFi2pSSCWbBek(qQ6yrf71L93qDzRRJvz5WoPKMWaLNO7dJBnWyud5P)PaZkirSrRMG0lgmFyCRbgJAip9V5RApbIyhr9t2wx(N)eisS0kUEPv(pzLCWSpkZELyWvMILYNWtxqcszzjRuEIUpmU1aJrnKN(NcmRGetzk6PuoWpl)ts4ehLLX4wdmg1qE6LTGmf(9qQYeebkhIMwUk81aLlJVgOSD6wdKYSgYtVSCWbBek(qQ6yPtTSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIpS0k)NSsoy2hL)jjCIJYYGdma5w3OKBJxzlitHFpKQmbrGYHOPLRcFnq5Y4Rbk)3bgGCRlLF424vwo4GncfFivDS0PwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXLDPv(pzLCWSpkZELyWvw6fdMpWRHG4icZ4PbJbkyVX4lzckbj47Dq5FscN4OSmSQtd7Ex6qzlitHFpKQmbrGYHOPLRcFnq5Y4Rbk)FvNg29U0HYYbhSrO4dPQJLo1YYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9ko2qPv(pzLCWSpkZELyWv2SGlEkK5Z)Qua5szk8ukRRJvkllzLYuSuEvNaZ6VV4ZGZjibJMfCXtHmFazLCWmLTpLnl4INcz(8VkfqUuMcpLYyZHL)jjCIJYYWQoTXOgYtVSfKPWVhsvMGiq5q00YvHVgOCz81aL)VQtlLznKNEz5Gd2iu8Hu1XsNAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5EfhBvAL)twjhm7JYSxjgCLl)ts4ehLLJhszOdWaqv2cYu43dPktqeOCiAA5QWxduUm(AGY8Hug6amauLLdoyJqXhsvhlDQLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vCSV0k)NSsoy2hLzVsm4kx(NKWjokl7ey3RyoA2aZoEOdmLTGmf(9qQYeebkhIMwUk81aLlJVgOSDfy3RyMYHBGztzAOdmLLdoyJqXhsvhlDQLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vCSkTY)jRKdM9rz2RedUYt09HXTgymQH80)uGzfKyktHu2VXB8egiLTpL9iKBIEMmQG1FL)jjCIJYYU12ok9QIxzlitHFpKQmbrGYHOPLRcFnq5Y4RbkB312MYpEvXRSCWbBek(qQ6yPtTSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIJTlTY)jRKdM9rz2RedUYwLYMfCXtHmF(xLcixktHNs5Hutz7tzPxmy(ahyaYTUrmi)B87DqkBDkBFkBvkRamkiQTsoiLTU8pjHtCuwgJBnWyud5Px2cYu43dPktqeOCiAA5QWxduUm(AGY2PBnqkZAip9u2kDRl)tfelFRkaUrbMNuagfe1wjhuwo4GncfFivDS0PwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXXMLw5)KvYbZ(Om7vIbxzZcU4PqMp)RsbKlLPWtPSUUEkllzLYuSuEvNaZ6VV4ZGZjibJMfCXtHmFazLCWmLTpLnl4INcz(8VkfqUuMcpLYyBSpLLLSsza7EfdgaZVOb5MGsqcg1GvDPS9PmGDVIbdG53PbJtWdcBGkok5qO54G1FPS9PSzbx8uiZN)vPaYLYuiLXIAkBFkFRdi33I5avud5P)bKvYbZY)KeoXrzzyvN2yud5Px2cYu43dPktqeOCiAA5QWxduUm(AGY)x1PLYSgYtpLTs36YYbhSrO4dPQJLo1YYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kUo1sR8FYk5GzFuM9kXGRS0lgmFkiIilXdJh6aZNcmRGetzkkL1PMYYswPSvPS0lgmFkiIilXdJh6aZNcmRGetzkkLTkLLEXG5BJEGmxIh(MVQ9eiskBhMYEeYnrpt(2OhiZL4HpfywbjMYwNY2NYEeYnrpt(2OhiZL4HpfywbjMYuukRJTszRl)ts4ehLLp0bMrZgpqrzzlitHFpKQmbrGYHOPLRcFnq5Y4RbktdDGjLd34bkkllhCWgHIpKQow6ullhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R466Lw5)KvYbZ(Om7vIbxzRszPxmy(gGEguJimJNgmAwWfpfY89oiLTpLx)jSbJabmciMYuukl7u26u2(u2QuEcsVyW85ebAhrqcgvO53e9mjLTU8pjHtCuw2jc0oIGemkHCxzlitHFpKQmbrGYHOPLRcFnq5Y4RbkBxrG2reKGu(bYDL)PcILVvfa3OaZttq6fdMpNiq7icsWOcn)MONjLLdoyJqXhsvhlDQLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vC9HLw5)KvYbZ(Om7vIbxzPxmy(gGEguJimJNgmAwWfpfY89oiLTpLx)jSbJabmciMYuukl7Y)KeoXrzzNiq7icsWOeYDLTGmf(9qQYeebkhIMwUk81aLlJVgOSDfbAhrqcs5hi3LYwPBDz5Gd2iu8Hu1XsNAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Efxx2Lw5)KvYbZ(Om7vIbxzRs51FcBWiqaJaIPmfsz9u2(uE9NWgmceWiGyktHuwpLToLTpLTkLNG0lgmForG2reKGrfA(nrptszRl)ts4ehLL9ARGm6ebAhrqckBbzk87HuLjicuoenTCv4RbkxgFnqzz0wbjLTRiq7icsq5FQGy5BvbWnkW80eKEXG5Zjc0oIGemQqZVj6zsz5Gd2iu8Hu1XsNAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5EfxhBO0k)NSsoy2hLzVsm4kV(tydgbcyeqmLPqkRNY2NYR)e2GrGagbetzkKY6L)jjCIJYYETvqgDIaTJiibLTGmf(9qQYeebkhIMwUk81aLlJVgOSmARGKY2veODebjiLTs36YYbhSrO4dPQJLo1YYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kUo2Q0k)NSsoy2hLzVsm4kpbPxmy(CIaTJiibJk08BIEMu(NKWjokl7ebAhrqcgLqURSfKPWVhsvMGiq5q00YvHVgOCz81aLTRiq7icsqk)a5Uu2QHwx(Nkiw(wvaCJcmpnbPxmy(CIaTJiibJk08BIEMuwo4GncfFivDS0PwwoerVkpelTELLrd80dr2adqUkvoenXxduUxX1X(sR8FYk5GzFu(NKWjokl7ebAhrqcgLqURSfKPWVhsvMGiq5q00YvHVgOCz81aLTRiq7icsqk)a5Uu2kzBDz5Gd2iu8Hu1XsNAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5EfxhRsR8FYk5GzFuM9kXGRScWOGO2k5GY)KeoXrzzmU1aJrnKNEzz0ap9qKnWaKRpkhIMwUk81aLlBbzk87HuLjicugFnqz70TgiLznKNEkB1qRl)tfelBq2eKGN0TJVvfa3OaZtkaJcIARKdklhCWgHIpKQow6ullhIOxLhILwVYHiBcsqX1lhIM4Rbk3R46y7sR8FYk5GzFu(NKWjokldR60gJAip9YYObE6HiBGbixFuoenTCv4Rbkx2cYu43dPktqeOm(AGY)x1PLYSgYtpLTAO1L)PcILniBcsWt6LLdoyJqXhsvhlDQLLdr0RYdXsRx5qKnbjO46Ldrt81aL7vCDSzPv(pzLCWSpkZELyWv(wvaCFtr8wIhszkKYyF5FscN4OSmg3AGXOgYtVSmAGNEiYgyaY1hLdrtlxf(AGYLTGmf(9qQYeebkJVgOSD6wdKYSgYtpLTs2wx(Nkiw2GSjibpPxwo4GncfFivDS0PwwoerVkpelTELdr2eKGIRxoenXxduUxVY4RbkZcJmP8FhyaYTok(uokiboiLDQETa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170622.212605, [[de0Duaqiuu1MucgLsOtPezvOiLxrsvYSiPQ4wKuvAxkvddfogjwMaEMQGMgjvvxdfPABQc5BQsgNQq5CQcvRJKQO5HIW9uIAFOOCqvPwOsXdrPmrsQcxuv0grr0jrPAMOOYnf0ovvlLO8uKPIs2kjL9k9xizWICyflMipMktgIld2Ss6ZevJMsDAkEnKA2I62KA3e(nudNKCCvbwoQEovnDvUoLSDb67Oi58kLwpjvPMpjv2VqxLYQ0tXiLbKUPK6bSow5RBkroUr1vQePcCMjBuVNZGf9h4rbkjdYW4H(dWq5fJhP8W9akpur5vjzWGSLLrdLqW3(AE0akVn2HENd6Xi8QVlIaswRR7R5rdO82yh6Del(CgSGPXy)Hlv6T7myHVS6xPSk9umszaPBkroUr1vI5JPZ4qBeYJj1PUycbF7R5rdO82yh6DoOhJWhtmXYXKChsP3sMS52wAnpAaL3g7qxIDbIXnhMxsGfqPqmIAd)pAOuP)OHsmzE0qmr2yh6sYGmmEO)amuEPWOKmWJT4oWxw9kXMn4qhIdcAqCvQuig5pAOuV(duwLEkgPmG0nLih3O6kjzTUUdoBm4rHxrD2ak5CyouElbcWnc57wQIPfIj9az)XX6DNfNdIlMy2YX0J9OsVLmzZTTem8Z(bwdAOe7ceJBomVKalGsHye1g(F0qPs)rdLEo8Z(bwdAOKmidJh6padLxkmkjd8ylUd8LvVsSzdo0H4GGgexLkfIr(Jgk1R)hwwLEkgPmG0nLih3O6kjzTUUBCWQfF7ULQyAHyspq2FCSE3zX5G4IjMTCmPOOetletmFmjzTUUpEhiqgHd2Tuv6TKjBUTLw5y)HYBJDOlXUaX4MdZljWcOuigrTH)hnuQ0F0qjMKJ9xmr2yh6sYGmmEO)amuEPWOKmWJT4oWxw9kXMn4qhIdcAqCvQuig5pAOuV(v)LvPNIrkdiDtP3sMS52wcYGge3KrjLh)vIDbIXnhMxsGfqPqmIAd)pAOuP)OHspZGge3KJPn5XFLKbzy8q)byO8sHrjzGhBXDGVS6vInBWHoehe0G4QuPqmYF0qPE9Z0lRspfJugq6MsKJBuDL0dK9hhR3DwCoiUyIzlhtkkVIj1PUyI5JPHFM1XD7EMcYzJqok9az)XX6DqmszajMwiM0dK9hhR3DwCoiUyIzlhtpEGsVLmzZTTem8ZgL3g7qxIDbIXnhMxsGfqPqmIAd)pAOuP)OHsph(zhtKn2HUKmidJh6padLxkmkjd8ylUd8LvVsSzdo0H4GGgexLkfIr(Jgk1R)hvwLEkgPmG0nLih3O6kv6TKjBUTL8hMRrdGkGxIDbIXnhMxsGfqPqmIAd)pAOuP)OHs0H5A0aOc4LKbzy8q)byO8sHrjzGhBXDGVS6vInBWHoehe0G4QuPqmYF0qPE9)QSk9umszaPBkroUr1vAXyspq2FCSE3zX5G4IjMy5ysHHsmTqmn8ZSoUB3ZuqoBeYrPhi7powVdIrkdiXK6uxmX8X0WpZ64UDptb5SrihLEGS)4y9oigPmGetlet6bY(JJ17olohexmXelhtVEumTumTqmX8XKK166(4DGazeoy3svP3sMS52wY4Gvl(2sSlqmU5W8scSakfIruB4)rdLk9hnuIDhSAX3wsgKHXd9hGHYlfgLKbESf3b(YQxj2Sbh6qCqqdIRsLcXi)rdL61)JvwLEkgPmG0nLih3O6kv6TKjBUTLYMhyzqqPh56b1HpqxIDbIXnhMxsGfqPqmIAd)pAOuP)OHsmN5bwgKykCKRNyIf(aDjzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)pEzv6PyKYas3uICCJQRKK166UkmtbCu4vuNnGspq2FCSE3svmTqmjzTUU7pmxJgavaF3svmTqmnUZeeqbcqBaFmXeX0dl9wYKn32szJC7tyeYrjHZxj2fig3CyEjbwaLcXiQn8)OHsL(JgkXCg52NWiKhtBW5RKmidJh6padLxkmkjd8ylUd8LvVsSzdo0H4GGgexLkfIr(Jgk1RFfgLvPNIrkdiDtjYXnQUsi4BFnpAaL3g7qVZb9ye(yIzXKB8hQZOHyAHyYHXzemtjqXHXDLElzYMBBP8eCqjzX9xj2fig3CyEjbwaLcXiQn8)OHsL(JgkXCtWjM2yX9xjzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)kkLvPNIrkdiDtjYXnQUsswRR7ghSAX3UBPkMwiMwmMwmM0dK9hhR3DwCoiUyIzlhtbyetlftQtDXKK166UXbRw8T7CqpgHpMyIyAXyszNPhtmTyYRcYzu2J)GyIPftswRR7ghSAX3U7VXHoMuVIjLyAPyAPsVLmzZTT0kh7puEBSdDj2fig3CyEjbwaLcXiQn8)OHsL(JgkXKCS)IjYg7qhtlQSujzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)kbkRspfJugq6MsKJBuDLwmM0dK9hhR3DwCoiUyIzlhtbyetletswRR7qg0G4MmQvSZYVBPkMwkMwiMwmM4Wkh82JugIPLk9wYKn32sR5rdO82yh6sSlqmU5W8scSakfIruB4)rdLk9hnuIjZJgIjYg7qhtlQSuP3C5(s3WLdhkZ6YCyLdE7rkdLKbzy8q)byO8sHrjzGhBXDGVS6vInBWHoehe0G4QuPqmYF0qPE9R8WYQ0tXiLbKUPe54gvxjjR11DJdwT4B3Tuv6TKjBUTLw5y)HYBJDOlXMn4qhIdcAqCDtPqmIAd)pAOuj2fig3CyEjbwaL(JgkXKCS)IjYg7qhtlgyPsV5Y9L04GgH8LvkjdYW4H(dWq5LcJsYap2I7aFz1RuioOriVFLsHyK)OHs96xr9xwLEkgPmG0nLih3O6kPhi7powV7S4CqCXeZwoMuuuIj1PUyI5JPHFM1XD7EMcYzJqok9az)XX6DqmszajMwiM0dK9hhR3DwCoiUyIzlhtp2JIj1PUycEGLrLkaz3RXzeGBeYrzdd)IPfIj4bwgvQaK9ZgqHaoWee4EuszmgbLQXDX0cXKEGS)4y9UZIZbXftmlMEXiMwiMUjdIBFwpG7TXo07GyKYasP3sMS52wcg(zJYBJDOlXUaX4MdZljWcOuigrTH)hnuQ0F0qPNd)SJjYg7qhtlQSujzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)km9YQ0tXiLbKUPe54gvxjjR11Do4XIr4auh(a9oh0Jr4JjMiMuyu6TKjBUTLo8bAu6XFaFBj2fig3CyEjbwaLcXiQn8)OHsL(JgkXcFGoMch)b8TLKbzy8q)byO8sHrjzGhBXDGVS6vInBWHoehe0G4QuPqmYF0qPE9R8OYQ0tXiLbKUPe54gvxjjR11DWzJbpk8kQZgqjNdZHYBjqaUriF3svP3sMS52wcg(z)aRbnuIDbIXnhMxsGfqPqmIAd)pAOuP)OHsph(z)aRbnetlQSujzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)kVkRspfJugq6MsKJBuDLKSwx3vHzkGJcVI6Sbu6bY(JJ17wQIPfIPXDMGakqaAd4JjMiMEyP3sMS52wkBKBFcJqokjC(kXUaX4MdZljWcOuigrTH)hnuQ0F0qjMZi3(egH8yAdoFX0IklvsgKHXd9hGHYlfgLKbESf3b(YQxj2Sbh6qCqqdIRsLcXi)rdL61VYJvwLEkgPmG0nLih3O6knUZeeqbcqBaFmXSysjMwiMg3zccOabOnGpMywmPu6TKjBUTLC2JrGkBKBFcJqEj2fig3CyEjbwaLcXiQn8)OHsL(JgkXM9yeXeZzKBFcJqEjzqggp0FagkVuyusg4XwCh4lRELyZgCOdXbbniUkvkeJ8hnuQx)kpEzv6PyKYas3u6TKjBUTLYg52NWiKJscNVsSlqmU5W8scSakfIruB4)rdLk9hnuI5mYTpHripM2GZxmTyGLkjdYW4H(dWq5LcJsYap2I7aFz1ReB2GdDioiObXvPsHyK)OHs96paJYQ0tXiLbKUPe54gvxjoSYbV9iLHsVLmzZTT0AE0akVn2HUeB2GdDioiObX1nLcXiQn8)OHsLyxGyCZH5Leybu6pAOetMhnetKn2HoMwmWsLEZL7lPXbnc5lRO(CdxoCOmRlZHvo4ThPmusgKHXd9hGHYlfgLKbESf3b(YQxPqCqJqE)kLcXi)rdL61FaLYQ0tXiLbKUP0Bjt2CBlbd)Sr5TXo0LyZgCOdXbbniUUPuigrTH)hnuQe7ceJBomVKalGs)rdLEo8ZoMiBSdDmTyGLk9Ml3xsJdAeYxwPKmidJh6padLxkmkjd8ylUd8LvVsH4GgH8(vkfIr(Jgk1R)abkRspfJugq6MsKJBuDLUHlhUDeJ)gHdIjMftpQ0Bjt2CBlTMhnGYBJDOlXMn4qhIdcAqCDtPqmIAd)pAOuj2fig3CyEjbwaL(JgkXK5rdXezJDOJPfF4sLEZL7lPXbnc5lRusgKHXd9hGHYlfgLKbESf3b(YQxPqCqJqE)kLcXi)rdL61R0F0qjYOzlMEMbniUjREgtEJqEgIjZAVwa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170622.212605, [[de0qkaqijLYMuk1OKu4ueHwLKIywskk3ssrAxevddchJeltI6zkKmnfsDnjLQTHIsFtHACskrNtsr16KucZtPe3dfv7tHGdkrwij1dvkMOKsYfLuTrLsYjjsMjrWnLWovYpLusTuu4PitfI2kr0Ef)fsgmQ6WuTyu6XkAYs5YQ2mj5Zky0sYPj8AIYSP0Tj1Ub9BOgorQJRq0YP45s10bUUs12HuFhffNhfz9kLuZxHq7hvokbzO6qN1(wuhIK(tHBfBTdeyywLz2YHOPriniuOA1v57wquhIXT37pRYiugJGzvgL8YkJsrzCig3BmHuOFOggixL11hvVcpLj3CTlG9AAnANDxLk5QSU(O6v4Pm5TDJdeyynbH8rjXqLMabg2dYSucYq1HoR9TOoujwHvaykuhGnAz)sFtiPGnX0bytiig(qf4MKUz56hk0Y1pebWgTSFPVjeJBV3FwLrOmwbrigVJ3nZ3dYacTP6tzfy0xFiiSHkWTLRFOaYQCqgQo0zTVf1HOPrinieapmyV8jgBByMb2dvIvyfaMc595HnhoFiPGnX0bytiig(qf4MKUz56hk0Y1puP(8WMdNpeJBV3FwLrOmwbrigVJ3nZ3dYacTP6tzfy0xFiiSHkWTLRFOaYAubzO6qN1(wuhQeRWkamfYkg5UOHs7dAhfadUoKuWMy6aSjeedFOcCts3SC9dfA56hscIrUlAC8f(G254rIbxhIXT37pRYiugRGieJ3X7M57bzaH2u9PScm6Rpee2qf42Y1puazn6GmuDOZAFlQdrtJqAqOAWX7tGa9rD41I3543ch)O543MJx732bgSw(C3yoeWXpcmNJVmcoEjYXVnhFn44nxL59kN1EoEjgQeRWkamfsL11hvVcpLfskytmDa2ecIHpubUjPBwU(HcTC9dTvwxFoEQcpLfQKzOhc4MHdqjuXCZvzEVYzTpeJBV3FwLrOmwbrigVJ3nZ3dYacTP6tzfy0xFiiSHkWTLRFOaYQ2dYq1HoR9TOoujwHvayk0DdOAK7UShskytmDa2ecIHpubUjPBwU(HcTC9dv3nGQrU7YEig3EV)SkJqzScIqmEhVBMVhKbeAt1NYkWOV(qqydvGBlx)qbKfZgKHQdDw7BrDiAAesdc1Wa5QSU(O6v4Pm5MRDbSZXpcC8tVdqbe6ZXVnhp7UkvYToAhvF3mC57sZXVnhFTXXdC7Ha5wXqfakGdOm4M8dDw7BC8BZX7tGa9rD41I3543ch)OdvIvyfaMczD0ok2DtheskytmDa2ecIHpubUjPBwU(HcTC9djbhTZXRE30bHyC79(ZQmcLXkicX4D8Uz(EqgqOnvFkRaJ(6dbHnubUTC9dfqwJdYq1HoR9TOoenncPbHQnoEGBpei3kgQaqbCaLb3KFOZAFJJFBoEFceOpQdVw8oh)w44RDo(rCe54bU9qGCRyOcafWbugCt(HoR9no(T549jqG(Oo8AX7C8BHJF0HkXkScatHU96dbUffR17GqsbBIPdWMqqm8HkWnjDZY1puOLRFO62Rpe4woE1wVdcX4279NvzekJvqeIX74DZ89GmGqBQ(uwbg91hccBOcCB56hkGSQLbzO6qN1(wuhQeRWkamfY6ODuS31HKc2ethGnHGy4dvGBs6MLRFOqlx)qsWr7C8QVRdX4279NvzekJvqeIX74DZ89GmGqBQ(uwbg91hccBOcCB56hkGSQ5bzO6qN1(wuhIMgH0GqTZURsLCRyOcafWbugCtEdZmWqLyfwbGPqZkxarzfdvaOaoeskytmDa2ecIHpubUjPBwU(HcTC9dTPYfqoEjigQaqbCiujZqpeWndhGsOI5TZURsLCRyOcafWbugCtEdZmWqmU9E)zvgHYyfeHy8oE3mFpidi0MQpLvGrF9HGWgQa3wU(HcilfebzO6qN1(wuhQeRWkamfAw5cikRyOcafWHqsbBIPdWMqqm8HkWnjDZY1puOLRFOnvUaYXlbXqfakGdC81qrIHyC79(ZQmcLXkicX4D8Uz(EqgqOnvFkRaJ(6dbHnubUTC9dfqwkkbzO6qN1(wuhQeRWkamfY6ODuS7Moi0MQpLvGrF9HGOoubUjPBwU(HcjfSjMoaBcbXWhA56hscoANJx9UPd44RHIedvYm0dPXOfWbMReIXT37pRYiugRGieJ3X7M57bzaHkWOfWHSucvGBlx)qbKLs5GmuDOZAFlQdrtJqAqiZvzEVYzTpujwHvaykKkRRpQEfEkl0MQpLvGrF9HGOoubUjPBwU(HcjfSjMoaBcbXWhA56hARSU(C8ufEkJJVgksmujZqpKgJwahyUsnd4MHdqjuXCZvzEVYzTpeJBV3FwLrOmwbrigVJ3nZ3dYacvGrlGdzPeQa3wU(HciGqlx)qKqVHJVU96dbUTwWXxQwxpGe]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170622.212605, [[daKwtaqikb2esvJce1PajEfiPywcPOUfiP0UKsddrDmk1YKcpdePPHeW1ajvBdKKVHGgNqkDoKaToHuK5jKQ7jf1(KICqeyHGWdrQmrHuOlcsTrkbDskrZeeXnLu7eulLO8uutfPSvHK9Q8xezWu5WIwmrEmPMSuDzvBgH(mr1OLKttXRrsZwIBtYUH63qgoL0XrcA5eEUGPdCDHA7cX3Pe68irRxifmFKq7NQE2J2yOXPu59bXy261MSyIgsGbHhCdOQXywlmwbJhhnEIzCbmigl7LNHp4gKTjKmuzdPTnSHuBBchl7zNsAg1hlUkn4auRumrITzqFCpX632JfjWGWJjqdmiCy0gS9OngACkvEFqmM1cJvWyasU8YB1iuPJSio4D07Dq276iqlXsQoPqfstTvCvAWbVRjVtkMiX2mOpUNy9B7XIeyqyVJEVtJqLoYI42sgjjjflcGwXvPbh8UM8oYEh9ENf4DsXej2gaiHI6V1lAJT6DqzmbsMIbq54mOpUNy9hBjUB0jajgJr4pUg1JkfWP6JhdNQpMGG(4EI1FSSxEg(GBq2MqBYJL9akwOFy0gymDvxtTgf5QJbtACnQdNQpEGb3y0gdnoLkVpigZAHXkySf4DaJMQbl37Oif9Uoc0sSKQtkuH0uBfxLgCW7IEZENCDFmbsMIbq5yILuDsHkKM6ylXDJobiXymc)X1OEuPaovF8y4u9Xwyjv374kKM6yzV8m8b3GSnH2Khl7buSq)WOnWy6QUMAnkYvhdM04AuhovF8adgshTXqJtPY7dIXSwyScgRYxcabs1QJfIJbExtn7Dni7D07DIRsdo4DrVzVtkMiX2mOpUNy9B7XIeyqyVJEVtJqLoYI42mOpUNy9BfxLgCW7GA8oPyIeBZG(4EI1VThlsGbH9UO3S31JfjWGWJjqYumakhtSKQtkuH0uhBjUB0jajgJr4pUg1JkfWP6JhdNQp2clP6EhxH0u9oiBdLXYE5z4dUbzBcTjpw2dOyH(HrBGX0vDn1AuKRogmPX1OoCQ(4bgmfy0gdnoLkVpigtGKPyauo(LRogKfssLmagBjUB0jajgJr4pUg1JkfWP6JhdNQpg6YvhdYI3brjdGXYE5z4dUbzBcTjpw2dOyH(HrBGX0vDn1AuKRogmPX1OoCQ(4bgmuF0gdnoLkVpigZAHXkySumrITxxHEGeIijq1jjx8eqkeJ7xyWYBJT6D07DwG3jftKyBg0h3tS(TXw9o69ov(saiqQwDSqCmW7AQzVlAHQXeizkgaLJFkavuyCs9JTe3n6eGeJXi8hxJ6rLc4u9XJHt1hdDkavuyCs9JL9YZWhCdY2eAtESShqXc9dJ2aJPR6AQ1OixDmysJRrD4u9XdmyOA0gdnoLkVpigZAHXkySkFjaeivRowiog4Dn1S3zBtO3rrk6DwG3LcGHyQbTbl(sXGLtsLVeacKQ94uQ8U3rV3PYxcabs1QJfIJbExtn7DuWgJjqYumakh)uaQifQqAQJTe3n6eGeJXi8hxJ6rLc4u9XJHt1hdDkavEhxH0uhl7LNHp4gKTj0M8yzpGIf6hgTbgtx11uRrrU6yWKgxJ6WP6JhyWeoAJHgNsL3heJzTWyfmEmbsMIbq54aajuu)TEXylXDJobiXymc)X1OEuPaovF8y4u9Xmajuu)TEXyzV8m8b3GSnH2Khl7buSq)WOnWy6QUMAnkYvhdM04AuhovF8adoAhTXqJtPY7dIXSwyScgpMajtXaOCCXqHXMojvkxLKaiWvJTe3n6eGeJXi8hxJ6rLc4u9XJHt1hdjgkm209U6uUk9oAiWvJL9YZWhCdY2eAtESShqXc9dJ2aJPR6AQ1OixDmysJRrD4u9Xdmyk4OngACkvEFqmM1cJvWyPyIeBTIS4fKqejbQojv(saiqQ2yREh9ENumrITbasOO(B9I2yREh9ExQbMiN0XxzEW7IU3bPJjqYumakhxmYRaydwojjubm2sC3OtasmgJWFCnQhvkGt1hpgovFmKyKxbWgSCVdcubmw2lpdFWniBtOn5XYEafl0pmAdmMUQRPwJIC1XGjnUg1Ht1hpWGTjpAJHgNsL3heJzTWyfmUJaTelP6Kcvin1wXvPbh8UM8oDgaKag19o69oi7DAeQ0rwets8ud8oksrVtkMiX2mOpUNy9BJT6DqzmbsMIbq54sgjjjflcGXwI7gDcqIXye(JRr9OsbCQ(4XWP6JHKms6DqelcGXYE5z4dUbzBcTjpw2dOyH(HrBGX0vDn1AuKRogmPX1OoCQ(4bgST9OngACkvEFqmM1cJvWyi7DQ8LaqGuT6yH4yG31uZExdYEh9ENumrITVC1XGSqIishhAJT6DqX7O37GS3jorXdvPu5EhugtGKPyauoMyjvNuOcPPo2sC3OtasmgJWFCnQhvkGt1hpgovFSfws19oUcPP6DqUbugtGqEymifYpGKHyZItu8qvkv(yzV8m8b3GSnH2Khl7buSq)WOnWy6QUMAnkYvhdM04AuhovF8ad2UXOngACkvEFqmM1cJvWyv(saiqQwDSqCmW7AQzVZ2227Oif9olW7sbWqm1G2GfFPyWYjPYxcabs1ECkvE37O37u5lbGaPA1XcXXaVRPM9UOfQ8oksrV7uySXQ13BdkuPFHblNu1tbW7O37ofgBSA99wq1j1V(MixeijvqOojRPg4D07DQ8LaqGuT6yH4yG31K3rizVJEVdKLJbTjrWfHkKMA7XPu59XeizkgaLJFkavKcvin1XwI7gDcqIXye(JRr9OsbCQ(4XWP6JHofGkVJRqAQEhKTHYyzV8m8b3GSnH2Khl7buSq)WOnWy6QUMAnkYvhdM04AuhovF8ad2gshTXqJtPY7dIXSwyScglftKyR4beoX6tcGax1kUkn4G3fDVZMS3rrk6Dq27KIjsSv8acNy9jbqGRAfxLgCW7IU3bzVtkMiX2mOpUNy9B7XIeyqyVdQX70iuPJSiUnd6J7jw)wXvPbh8oO4D07DAeQ0rwe3Mb9X9eRFR4Q0GdEx09oBOU3bLXeizkgaLJbiWvKuzaCbLJTe3n6eGeJXi8hxJ6rLc4u9XJHt1htdbUY7QZa4ckhl7LNHp4gKTj0M8yzpGIf6hgTbgtx11uRrrU6yWKgxJ6WP6JhyW2uGrBm04uQ8(GymRfgRGXPgyICshFL5bVRjVZ27O37snWe5Ko(kZdExtEN9ycKmfdGYXLmsss6PASL4UrNaKymgH)4AupQuaNQpEmCQ(yijJKEhepvJL9YZWhCdY2eAtESShqXc9dJ2aJPR6AQ1OixDmysJRrD4u9XdmyBO(OngACkvEFqmM1cJvWyPyIeBTIS4fKqejbQojv(saiqQ2yREh9ExQbMiN0XxzEW7IU3bPJjqYumakhxmYRaydwojjubm2sC3OtasmgJWFCnQhvkGt1hpgovFmKyKxbWgSCVdcub4Dq2gkJL9YZWhCdY2eAtESShqXc9dJ2aJPR6AQ1OixDmysJRrD4u9XdmyBOA0gdnoLkVpigZAHXkyCQbMiN0XxzEW7AY7S9o69UudmroPJVY8G31K3zpMajtXaOCSUknysfJ8ka2GLp2sC3OtasmgJWFCnQhvkGt1hpgovFmDvPb7DqIrEfaBWYhl7LNHp4gKTj0M8yzpGIf6hgTbgtx11uRrrU6yWKgxJ6WP6JhyW2eoAJHgNsL3heJjqYumakhxmYRaydwojjubm2sC3OtasmgJWFCnQhvkGt1hpgovFmKyKxbWgSCVdcub4DqUbugl7LNHp4gKTj0M8yzpGIf6hgTbgtx11uRrrU6yWKgxJ6WP6JhyW2r7OngACkvEFqmM1cJvWyXjkEOkLkFmbsMIbq5yILuDsHkKM6y6QUMAnkYvhdgeJRr9OsbCQ(4XwI7gDcqIXye(JHt1hBHLuDVJRqAQEhKHuOmMaH8WyfkIblVz7OzqkKFajdXMfNO4HQuQ8XYE5z4dUbzBcTjpw2dOyH(HrBGX1OigS8bBpUg1Ht1hpWGTPGJ2yOXPu59bXycKmfdGYXpfGksHkKM6y6QUMAnkYvhdgeJRr9OsbCQ(4XwI7gDcqIXye(JHt1hdDkavEhxH0u9oi3akJjqipmwHIyWYB2ESSxEg(GBq2MqBYJL9akwOFy0gyCnkIblFW2JRrD4u9Xdm4gKhTXqJtPY7dIXSwyScgdsH8dA7MaiX67Dn5Dq1ycKmfdGYXelP6Kcvin1X0vDn1AuKRogmigxJ6rLc4u9XJTe3n6eGeJXi8hdNQp2clP6EhxH0u9oitbGYyceYdJvOigS8MThl7LNHp4gKTj0M8yzpGIf6hgTbgxJIyWYhS94AuhovF8admgovFmBu05DqxU6yqwIM8UGblVCVld6b2a]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20170622.212605, [[dKc5baGEvv1UuvLTraZwYnjqFtiTta7LA3k2VQmmL43k1GvPHlihuvLJjWcjOwkOAXiA5i8qq5PqlJOwNqmvL0Kbz6IUirUmQRRQSzbLTlO6JesFwOEUkojH42iDAPopb5XaDys)LqTd8QrPrjlgYKgbukBeBkS3vQykpPwrE3tQdKsa9UHFE3yLsw9eBeoxSEydiVeeDraz5)cmIGeDO0OXFGzVNJxnqGxnknkzXqwyJakLnInf27kvmLNuR3vuLsw9eBebj6qPXyLsw9eBeoxSEydiVeenyX4pYU6uiJeFJyfm79iU6tAeoF2FeG8XRonkYa1GAUjmo7Hnk4gcqPSrSPWExPIP8KA9UIQuYQN4iVlehM(vPtdi7vJsJswmKf2iGszJytH9Usft5j1Yics0HsJgHZfRh2aYlbrdwm(JSRofYiX3iwbZEpIR(KgHZN9hbiF8QtJImqnOMBcJZEyJcUHaukBeBkS3vQykpPwrExiom9RsNonIHyWwR(Fn79yazbKDAd]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170622.212605, [[d8tCiaqyQwVQQEjPQSlsvKTHc63qntvvwgLQztY5vu3efYPr13Ou45IStf2R0UjSFH6NqyycmosvuVwvPgkrnyrz4q6GkYrjvjDmk5CKQeluvSuuulwqlNIhQQ4PGhJuRtvjmruOMkctMiMUkxeLUkLIUSsxhjBuu1wvvI2Sq2or6JIk9ziAAOaFxvAKKQQNrP0OjLXJICssLBPQKUgPk19ivHUnIwlPk44IkUwLOaTJECSipwCWnR2ciSjXpDd2cNBqUNSu5gwW4cK7hTL(7(uihQLANuCKcYvCfOlmJikkT3hh94yrQJGcmHikkT3hh94yrQJGc5qTuReD0ybW)VDWGGcjn87eLX1jIWnSqoul1k5JJECSi1NcZiIIs7r4gK7L6iOGELAP2uj6WQefyfEOAL0Nct0hhlIZ(XtxbG9xCgRAjxX5Q4mzZsJjd9RWWj3ca7V4mw1sUIZvXzYMLgtg6xbMx16PTd7bwm0kiW2caTHJEfoo5Qhd61H9suGv4HQvsFkmrFCSio7hpDfa2FXzSQLCfNRIZy8g5uQRWWj3ca7V4mw1sUIZvXzmEJCk1vG5vTEA7WEGfdTccSTaqB4OxHE9kK0WVWl)O1My7tHKg(DI6W9Pqsd)cV8JwBI6W9PW5gK7njO1WMcpiiiqWiM1LR(jkm38FvphOxSZGagAzzdBdSB3gbn6RmqVleHfxHjd3vXzd3yWVfsA4xc3GCVuFk8D4KGwdBkqGqMzD5QFIcCHeoTFyZKGwdBkWSUC1prbAh94yXKGwdBk8GGGabJkaOln3v8)(XXIoSZq7fsA4xGOpfYHAPwgZnl9XXIcmRlx9tuqqrQJglsDWGcj0vPYR8K2hScBkrbVdRcHDyvazhwfmDy1Rqsd)(XrpowK6tbMqefL2BIY4DeuqYg5uQBs(xbGt(joJvTKR4C1xeNLoxiXnsIZKMIZq6KHkUazbsNPjQd3rqHqf)))Cv43jLQHfCfQMdA4xzPSDyvWvOA(hmzOFYsz7WQajxmrD4ockW4nYPuxFk4QxFojlvUpfKYt8qUIFZeZOBbVaTJECSysXrkk8HDqWYCbj8eQYNjMr3cEbxHQ5tQxFojlLTdRcgxGCjMr3cEixXV5coLXzexS9PGRq1Cqd)klvUdRcFhMhloG)F7WYEHzerrP903tQJVAvWvOAoHBqUNSu5oSkWeIOO0E67j1HvbZQk8HDqWYCHe6Qu5vEsRHfCfQMt4gK7jlLTdRcoLXNe0AytHheeeiy0p28efYHAPwj6es40(HnP(uWPmUoreMygDlesffvGjerrP9iCdY9sDeu4CdY9YJfhCZQTacBs8t3GTaJCM4KuKXzeCYTdBdkqYftSDyBbG2WrVcfCfQMpPE95KSu5oSkqJjd9twkBdlGA4KUzopwCa))2HL9cOMLgtg63K8VcaN8tCgRAjxX5QViod1S0yYq)k8bJohNrGlWQwYvCUkoBcbBbsNPj2ockq4QvCXz5AWuODeu4CdY9KLY2WcZiIIs7PtiHt7h2K6iOqsd)QVDoKlKWfit9PWmIOO0EtugVJGcmHikkTNoHeoTFytQJGcFhMhlUcYeXzGlsXzd3yWVfCkJtmJUfcPIIk4ughqxLshJ7iOqsd)QtiHt7h2K6tbsNjGOdRcU61NtYsz7tbzdN0nZXzFC0JJfXztugVqHKg(vwkBFkqJjd9twQCdlCUb5E5XIRGmrCg4IuC2Wng8BbonwaOonxGSd9UW3H5XIdUz1waHnj(PBWwGKlaIockCUb5E5XId4)3oSSxiPHFNy7tbAh94yrES4kiteNbUifNnCJb)wWvOA(hmzOFYsL7WQaRWdvRK(uiXjrv7ec2oSxihko93Fjpb3SAl4fgo5wGvTKR4CvCMSHt6M5cmVQ1tBh2dSSradTSvpz3YwllBuiPHFLLk3Nc0o6XXI8yXb8)Bhw2liB4KUzoo7JJECSOW5gK7LkeQ4))NRc)2WcOgoPBM1rJfa))2bdckWPXc9agt2HTbfYHAPwj5XId4)3oSSxGPockKd1sTs03tQpfsA4x4LF0Atiy7tbNY42uWVcOkFEn9Ab]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170622.212605, [[d8ZpiaqyrRxvLxsfYUikPxRq52OYmrunoIs1SP48kYnreonkFtvv5YkTtQAVs7MW(vf)ecdJu9BOEUGHssdwrnCeoOcokrj6yc15Oc0cvvwkrXIjYYP0dvipfSmQO1ruktKkutfstgv10v5IK4QuPYZquUosTrQKTQQQYMfY2rv(OcvFgIMgIOVRknsQG2MQQmAsz8isNKO6wubCnQu19uvv1JrYAjkHJtLYnUOfOsIJHfUWIdUjZwaH7qjxUxPWLwK7PYtTsfSPa5osBPgRFfKmSF)g3GFRuHjerrH9gLehdlc1RxGuerrH9gLehdlc1RxWn6LE5lNcla2VTEsQxiOHFhOTPCreUsfCJEPx(JsIJHfH(vycruuyp00ICVq96fKL0l9gkA9XfTGIiLml)(vyG6yyXZm5SWvVSxWNCBbqH8NzfZYTIlnpZQ2LcZjLxbzwZMHTEN6X)fRRtwbGYYiUchJB)F9E17SOfuePKz53VcduhdlEMjNfU6)RGp52cGc5pZkMLBfxAEMD8gL0MRGmRzZWwVt94)I11jtwJlauwgXvOxVcbn8l8YokTbLkviOHFhOpCLkWOWcGiPycK17(cxArU3GGsdBl8HaffbjKr(4oeTaPiIIc75OVq96fiTE9cbn8lAArUxOFfgtAqqPHTfqrOkJ8XDiAbMGpJkpSDqqPHTfKr(4oeTavsCmSyqqPHTf(qGIIGefaILILg2V8yyr9o)ZzHGg(fq7xb3Ox61Xm7sDmSOGmYh3HOfe0CYPWIq9KSqGyngxMmOncBW2IwiRpUGT(4ciRpUGu9X9ke0WVJsIJHfH(vGuerrH9gOTz96f4VrjT5gujVaW4g9mRywUvCPr2EMdxk4Nw(pZ8cpZitojdtGSaxs6a9HRxVqAi0YbZBofu5PuFCH0qOLGg(vLNs9XfsdHwocZjLNkpL6JlWXed0hUENfsZBofu5P2Vc8ybMeZWUj0jITGubQK4yyXGHHuuyKIhvrMc8zbctoHorSfOkizy)(nUb)oymvQGnfix0jITqkXmSBQqsBtsWeB)kmHikkSNJ(c1RxymjxyXbSFB9XolK02CqqPHTf(qGIIGeKR4cTqAi0s00ICpvEQ1hxiPTPCregDIylirhfvWUMcJu8OkYuiqSgJltg0QuH0qOLOPf5EQ8uQpUWuD5a)5EDhmw3bj7FKrMojLDY0BKdqs3xWn6LE5lxWNrLh2g6xbgfwilWyU6jtVaPiIIc7HMwK7fQxVWLwK75clo4MmBbeUdLC5ELcKijLXrZ9mJY426jtVahtmOuVZcaLLrCfcmbsZwineA5G5nNcQ8uRpUGB0l9oyyifCR4kqvGWY4s7KlS4a2VT(yNfiSlfMtkVbvYlamUrpZkMLBfxAKTNzc7sH5KYRafMtkpvEkvQaxs6Gs96fqtZkUN5XTyAI61lCPf5EQ8uQuHryIPNzuCbfZYTIlnpZdiuke0WVoANKyc(mbYq)kmHikkSNCbFgvEyBOE9ctiIIc7nqBZ61lqkIOOWEYf8zu5HTH61l4gnJAS)JfGBYSfKkK02eDIylirhfviOHFLl4ZOYdBd9RqsBtGyng5oUE9cP5nNcQ8u6xHGg(vLNs)ke0WVdkvQafMtkpvEQvQGQLXL2PN5rjXXWIN5bABwWLj52NzqdtnwHlTi3ZfwCfurFMHueEM9P1IFlmMKlS4GBYSfq4ouYL7vkWXeaA9olCPf5EUWIdy)26JDwiOHFHx2rPnqF4(vGkjogw4clUcQOpZqkcpZ(0AXVfsdHwocZjLNkp16JlOisjZYVFfcmocZoGqPENfgtYfwCfurFMHueEM9P1IFl4tUTGIz5wXLMN5bekf4ssb061lOAzCPD6zEusCmSOGnpgUqqd)QYtTFfOsIJHfUWIdy)26JDwqM1SzyR3PE8)0)lMmz1zmzXX)RaHLXL2j5uybW(T1ts9cPHqlbn8Rkp16Jl4g9sV8DHfhW(T1h7SqewCfgSS08m7tRf)wWn6LE57OVq)k44nkPnx)kK020Dc2vGWKtRTxla]] )


end
