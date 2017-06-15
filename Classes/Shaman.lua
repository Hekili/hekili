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

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent
local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'SHAMAN') then

    ns.initializeClassModule = function ()

        setClass( 'SHAMAN' )
        Hekili.LowImpact = true

        -- addResource( SPELL_POWER_HEALTH )
        addResource( 'mana', true )
        addResource( 'maelstrom', nil, true )


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
        addAura( 'doom_winds', 204945, 'duration', 6 )
        addAura( 'earthen_spike', 188089, 'duration', 10 )
        addAura( 'flametongue', 194084, 'duration', 16 )
        addAura( 'frostbrand', 196834, 'duration', 16 )
        addAura( 'fury_of_air', 197211 )
        addAura( 'hot_hand', 215785, 'duraiton', 15 )
        addAura( 'landslide', 202004, 'duration', 10 )
        addAura( 'lashing_flames', 240842, 'duration', 10, 'max_stack', 99 )
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
        addGearSet( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
        addGearSet( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
        addGearSet( 'doomhammer', 128819 )
        addGearSet( 'fist_of_raden', 128935 )

        setArtifact( 'doomhammer' )
        setArtifact( 'fist_of_raden' )

        addGearSet( 'akainus_absolute_justice', 137084 )
        addGearSet( 'alakirs_acrimony', 137102 )
        addGearSet( 'deceivers_blood_pact', 137035 )
        addGearSet( 'echoes_of_the_great_sundering', 137074 )
        addGearSet( 'emalons_charged_core', 137616 )
        addGearSet( 'eye_of_the_twisting_nether', 137050 )
        addGearSet( 'pristine_protoscale_girdle', 137083 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'spiritual_journey', 138117 )
        addGearSet( 'storm_tempests', 137103 )
        addGearSet( 'uncertain_reminder', 143732 )


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

        ns.addSetting( 'boulderfist_maelstrom', 100, {
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
        end )

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
            known = function () return talent.ancestral_guidance.enabled end,
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
            toggle = 'cooldowns'
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

            if equipped.emalons_charged_core and active_enemies >= 3 then
                applyBuff( 'emalons_charged_core', 10 )
            end

            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end

            -- LegionFix:  Artifact Check
            if feral_spirit.active then
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
            known = function() return equipped.doomhammer and ( toggle.doom_winds or ( toggle.cooldowns and settings.doom_winds_cooldown ) ) end,
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
            known = function() return talent.earthen_spike.enabled end
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
            known = function () return talent.elemental_mastery.enabled end,
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
            known = function () return talent.elemental_blast.enabled end,
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
            known = function () return spec.elemental and not talent.storm_elemental.enabled end,
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
            known = function() return talent.fury_of_air.enabled end,
            usable = function () return talent.fury_of_air.enabled and active_enemies > 1 or settings.st_fury end,
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
            known = function() return mana.current / mana.max > 0.22 end,
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
            known = function () return spec.elemental and talent.ascendance.enabled and buff.ascendance.up end
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
            known = function() return talent.lightning_shield.enabled end,
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
            known = function () return talent.liquid_magma_totem.enabled end
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
            known = function() return talent.rainfall.enabled end,
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
            known = function () return talent.storm_elemental.enabled end,
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
            known = function() return equipped.fist_of_raden and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact ) ) end,
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
            known = function() return not buff.ascendance.up end
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
            known = function() return talent.sundering.enabled end
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
            known = function () return talent.totem_mastery.enabled end,
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
            known = function() return talent.windsong.enabled end
        } )

        addHandler( 'windsong', function ()
            applyBuff( 'windsong', 20 )
        end )


        addAbility( 'windstrike', {
            id = 115356,
            spend = 10,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 2.99,
            known = function() return buff.ascendance.up end
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
            setCooldown( "stormstrike", 3 * haste )

            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            
            removeBuff( 'stormbringer' )

            if equipped.storm_tempests then
                applyDebuff( 'target', 'storm_tempests', 15 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )

    end


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170615.082054, [[dmKYxaqirvTijs2KaAueQtriZsG0Uiyyq0Xusltk6zqOmnbQUMa02Ki13GGXjQsNta06evX8GqQ7HsAFsP6GIIfkr8qsyIqOQlkLCsPuMPaWnrP2jj9tiKmuieTuPWtPAQsuxfcH2kkXxHqL9I8xanyHomLfdPhRutgOlRAZc6ZkHrlHttQvdHaVwuz2O62sA3G(nrdhGJlqz5q9CPA6kUok2oj67ceNxuA9qiO5ReTFrMwPYK3cAO8dsLqUd4BTX1icTrlHKAZsJyKJ4FOXWhQeYBC(T(j1MixrazPxrmHMRi26kcK7BSgWqo5z2Jwc7uzsDLktElOHYpivc5(gRbmKpYfl4xqdNJXmaMo5zq1C9KL8GOHGa7f3WK3geuVTrIjhkHNC2sqwmSQvp5KRA1toItdbtrV4gM8gNFRFsTjYvewrsEJ3Lm497uzAixrX35ylv(6HdHsoBjOQvp50qQnPYK3cAO8dsLqUVXAad5ItrXP4y8dhHctZ7Jexfo0q5hmfdmfZpfrzcdfcXY(GIniOadGuuukUCzkMFkog)WrOW08(iXvHdnu(btrrKNbvZ1twYvAyTHYp5kk(ohBPYxpCiuYzlbzXWQw9KxyAEFK4QIIVZrUQvp5(iXpfzX4mN8m4fDYHw9SwyAEFK4QIIVZfuLgN5Skw8y8dhHctZ7Jexfo0q5hmW8rzcdfcXY(GIniOadarlxM)y8dhHctZ7Jexfo0q5hue5no)w)KAtKRiSIK8gVlzW73PY0qEBqq92gjMCOeEYzlbvT6jNgsfXOYK3cAO8dsLqUVXAad5ItX8tXX4hocHm4SaLHannw4qdLFWuC5YuuCkog)WriKbNfOmeOPXchAO8dMIbMIv78(GLvHndgF4KITNI5fzkkkffrEgunxpzjxPH1gk)KRO47CSLkF9WHqjNTeKfdRA1tEidoRIIVZLxKKRA1tUps8trwmoZtrXRIipdErNCOvpRHm4Skk(oxErguLgN5Sko)X4hocHm4SaLHannw4qdLFWLlfpg)WriKbNfOmeOPXchAO8dgy1oVpyzT98IuKiYBC(T(j1Mixryfj5nExYG3VtLPH82GG6Tnsm5qj8KZwcQA1tonKAWPYK3cAO8dsLqUVXAad5ItX8tXX4hocHm4SaLHannw4qdLFWuC5YuuCkog)WriKbNfOmeOPXchAO8dMIbMIv78(GLvHndgF4KITNIiGmffLIIipdQMRNSKR0WAdLFYvu8Do2sLVE4qOKZwcYIHvT6jpKbNvrX35qaj5Qw9K7Je)uKfJZ8uuCtrKNbVOto0QN1qgCwffFNdbKbvPXzoRIZFm(HJqidolqziqtJfo0q5hC5sXJXpCeczWzbkdbAASWHgk)GbwTZ7dwwBhbKIerEJZV1pP2e5kcRijVX7sg8(DQmnK3geuVTrIjhkHNC2sqvREYPHudivM8wqdLFqQeY9nwdyixCkMFkog)WriKbNfOmeOPXchAO8dMIlxMIItXX4hocHm4SaLHannw4qdLFWumWuSAN3hSSkSzW4dNuS9um4bmffLIIipdQMRNSKR0WAdLFYvu8Do2sLVE4qOKZwcYIHvT6jpKbNvrX35cEajx1QNCFK4NISyCMNIIrmrKNbVOto0QN1qgCwffFNl4bmOknoZzvC(JXpCeczWzbkdbAASWHgk)GlxkEm(HJqidolqziqtJfo0q5hmWQDEFWYA7bpGIerEJZV1pP2e5kcRijVX7sg8(DQmnK3geuVTrIjhkHNC2sqvREYPHulnvM8wqdLFqQeY9nwdyixCkMFkog)WriKbNfOmeOPXchAO8dMIlxMIItXX4hocHm4SaLHannw4qdLFWumWuSAN3hSSkSzW4dNuS9uSzatrrPOiYZGQ56jl5knS2q5NCffFNJTu5Rhoek5SLGSyyvREYdzWzvu8DUMbKCvREY9rIFkYIXzEkko4IipdErNCOvpRHm4Skk(oxZaguLgN5Sko)X4hocHm4SaLHannw4qdLFWLlfpg)WriKbNfOmeOPXchAO8dgy1oVpyzT9MbuKiYBC(T(j1Mixryfj5nExYG3VtLPH82GG6Tnsm5qj8KZwcQA1tonKkcuzYBbnu(bPsi33ynGHCXPy(P4y8dhbPYJ3fgEXfo0q5hmfxUmffNIJXpCeKkpExy4fx4qdLFWumWuSAN3hSSkSzW4dNuS9uebKPOOuue5zq1C9KLCLgwBO8tUIIVZXwQ81dhcLC2sqwmSQvp5ikfisPKJasYvT6j3hj(PilgN5PO4akI8m4fDYHw9SIOuGiLsocidQsJZCwfN)y8dhbPYJ3fgEXfo0q5hC5sXJXpCeKkpExy4fx4qdLFWaR259blRTJasrIiVX536NuBICfHvKK34DjdE)ovMgYBdcQ32iXKdLWtoBjOQvp50qQ5LktElOHYpivc5(gRbmKlofZpfhJF4iivE8UWWlUWHgk)GP4YLPO4uCm(HJGu5X7cdV4chAO8dMIbMIv78(GLvHndgF4KITNILgzkkkffrEgunxpzjxPH1gk)KRO47CSLkF9WHqjNTeKfdRA1toIsbIuk5Lgj5Qw9K7Je)uKfJZ8uuCPfrEg8Io5qREwrukqKsjV0idQsJZCwfN)y8dhbPYJ3fgEXfo0q5hC5sXJXpCeKkpExy4fx4qdLFWaR259blRTxAKIerEJZV1pP2e5kcRijVX7sg8(DQmnK3geuVTrIjhkHNC2sqvREYPHudqQm5TGgk)GujK7BSgWqU4u8bJrdaWbfwd4AExdWuue5zq1C9KLCLgwBO8tUIIVZXwQ81dhcLC2sqwmSQvp5f3WtRGXOba4GKRA1tUps8trwmoZtrXiiI8m4fDYHw9SwCdpTcgJgaGdguLgN5Sk(bJrdaWbfwd4AExdqrK348B9tQnrUIWksYB8UKbVFNktd5Tbb1BBKyYHs4jNTeu1QNCAi1vKuzYBbnu(bPsi33ynGHCXP4dgJgaGdky5mnKPd0q7soZCGicy6JE)uue5zq1C9KLCLgwBO8tUIIVZXwQ81dhcLC2sqwmSQvp5wotdzAfmgnaahKCvREY9rIFkYIXzEkkoVIipdErNCOvpRwotdzAfmgnaahmOknoZzv8dgJgaGdkSIyiGmVbxe5no)w)KAtKRiSIK8gVlzW73PY0qEBqq92gjMCOeEYzlbvT6jNgsDDLktElOHYpivc5(gRbmKlofvAyTHYVGLZ0qMwbJrdaWbtXatruMWqHc5aSWGGcmasXatX8truMWqHqSSpOydckWaiffrEgunxpzjxPH1gk)KRO47CSLkF9WHqjNTeKfdRA1tULZ0qMmo5Qw9K7Je)uKfJZ8uuCakI8m4fDYHw9SA5mnKjJhuLgN5SkwPH1gk)cwotdzAfmgnaahmquMWqHc5aSWGGc4B7jW8rzcdfcXY(GIniOadarK348B9tQnrUIWksYB8UKbVFNktd5Tbb1BBKyYHs4jNTeu1QNCAi11MuzYBbnu(bPsi33ynGHCXPy(PiktyOaxVOyGA4cGBS1leyaKIbMI9parLqMUWOpUjsGnbStX2trKPOiYZGQ56jl5knS2q5NCffFNJTu5Rhoek5SLGSyyvREYda9IIbQHluGTEHQCqebqUQvp5(iXpfzX4mpffVIue5zWl6KdT6zna0lkgOgUqb26fQYbreqqvACMZQ48rzcdf46ffdudxaCJTEHadGa7FaIkHmDHrFCtKaBcylI8gNFRFsTjYvewrsEJ3Lm497uzAiVniOEBJetoucp5SLGQw9KtdPUIyuzYBbnu(bPsi33ynGHCuMWqbJdOWagejpua)QPH9uerNIntXatXWJnoWoanwpc4xnnSNITNIbN8mOAUEYsUsdRnu(jxrX35ylv(6HdHsoBjilgw1QNCJdOWqCsEOIIVZrUQvp5(iXpfzX4mpffVUkI8m4fDYHw9SACafgItYdvu8DUGQ04mNvXIb8riel7dWGi5HcOmHHcghqHbmisEOa(vtd7i6Mbc4JqO(4SadIKhkGYegkyCafgWGi5Hc4xnnSJOBgiGpcC9IIbQHlagejpuaLjmuW4akmGbrYdfWVAAyhr3uuGHhBCGDaASEeWVAAyV9GlI8gNFRFsTjYvewrsEJ3Lm497uzAiVniOEBJetoucp5SLGQw9KtdPUgCQm5TGgk)GujKNbvZ1twY3gNd02JwcbY19H82GG6Tnsm5qj8KZwcYIHvT6jNCvREYvyCEkMzpAjmfdaDFipdErNCOvpRLY1vfPylyHb3VE4KNuuc4WJlf5no)w)KAtKRiSIK8gVlzW73PY0qUIIVZXwQ81dhcLC2sqvREYDDvrk2cwyW9Rho5jfLao8yAi11asLjVf0q5hKkHCFJ1agYfNIknS2q5xO4gEAfmgnaahmfxUmf7FaIkHmDHrF8AacSjGDk2EkImffLIbMIItX8tXX4hoc3WtXHa7a05UWHgk)GP4YLPO4uClLCqzqGc3WtXHa7a05Ua(vtd7Py7P4AkgykULsoOmiqbqPScmiAiyxa)QPH9uS9uCnffLIlxMIGhLjmu4gEkoeyhGo3fyaKIIipdQMRNSKheneSpyDUtEBqq92gjMCOeEYzlbzXWQw9KtUQvp5ioneSpyDUtEJZV1pP2e5kcRijVX7sg8(DQmnKRO47CSLkF9WHqjNTeu1QNCAi11stLjVf0q5hKkH8mOAUEYs(24CG2E0siqUUpK3geuVTrIjhkHNC2sqwmSQvp5KRA1tUcJZtXm7rlHPyaO7tkkEve5zWl6KdT6zTuUUQifBblm4(1dN8KIOmHH9srEJZV1pP2e5kcRijVX7sg8(DQmnKRO47CSLkF9WHqjNTeu1QNCxxvKITGfgC)6HtEsruMWWonK6kcuzYBbnu(bPsipdQMRNSKVnohOThTecKR7d5Tbb1BBKyYHs4jNTeKfdRA1to5Qw9KRW48umZE0sykga6(KIIBkI8m4fDYHw9SwkxxvKITGfgC)6HtEsrfi(EPiVX536NuBICfHvKK34DjdE)ovMgYvu8Do2sLVE4qOKZwcQA1tURRksXwWcdUF9WjpPOceFNgsDnVuzYBbnu(bPsipdQMRNSKVnohOThTecKR7d5Tbb1BBKyYHs4jNTeKfdRA1to5Qw9KRW48umZE0sykga6(KIIrmrKNbVOto0QN1s56QIuSfSWG7xpCYtkUL4xkYBC(T(j1Mixryfj5nExYG3VtLPHCffFNJTu5Rhoek5SLGQw9K76QIuSfSWG7xpCYtkUL4tdPUgGuzYBbnu(bPsipdQMRNSKVnohOThTecKR7d5Tbb1BBKyYHs4jNTeKfdRA1to5Qw9KRW48umZE0sykga6(KIIdUiYZGx0jhA1ZAPCDvrk2cwyW9Rho5jfd1C(XLI8gNFRFsTjYvewrsEJ3Lm497uzAixrX35ylv(6HdHsoBjOQvp5UUQifBblm4(1dN8KIHAo)yAOHCvREYDDvrk2cwyW9Rho5jfbFOXWhAica]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170615.082054, [[dat3baGEuI2fQW2OImtQOMnLUPu8nuv7uWEj7wP9lugMu63IgkkQgmvvdNIoivLJbLfIQSuuyXuy5Q0dfINcwMu55q1errmvPQjRW0LCrQWZesxxOAROs2mkkBhv0NPsFhLWLrESIgnv5WqojQu3wfNwvNhLYRrP6VOKwhkslm1lWXImS0q8eaM08r2NLO6ZvHoNIkGjeZqXTL4jGbzjeoPqxlg)wNWIYrhwumm(cG59nlbc8nRpxC1RaM6f4yrgwAiEcG59nlbv66AjomZ6ZfxGpJ3(fBcmZ6Zva374NOkVc2Cjbn5Gl0nGoKabb0HeW8S(CfWGSecNuORfJpwRageEg)ojC1RsqepAYEtYjDOTKHGMCeqhsG5nT56sdwntwqxvk0PEbowKHLgINaFgV9l2eyFxVA)1LvCVNSdbCVJFIQ8kyZLe0KdUq3a6qceeqhsGZVRxT)6gZp49KDiGbzjeoPqxlgFSwbmi8m(Ds4QxLGiE0K9MKt6qBjdbn5iGoKavQeeqhsa8NiX87y9q7Ko0wmnMFZlnZJbQujb]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170615.082054, [[d4JNlaGEjPQ2KKODHuTnqI2hiPzcs1HPmBfMpvKBkPEovDBLSmQWovP9k2nW(LQrjjzyiPXreLZRiDAedwkdNKCqKOtjjCmQ0Xbj0cjclLewmOwoHhss9uupwI1rfLAIssvMkrAYQy6Q6IkkxvsQ0LHUUs1gLKk2kjQnROA7kLNbs5RurX0KKY3bj4VkIxJugnrDoQOKtsI8zqCnQO6Eeroeru9Bs9nKWXnsdpdyWd8e4WxBHHzYsDVndiBGcUqW7S7TIwGHRE4CBF8rIWkWbAEmxhuDPGku6cn6oCHMRlfHzvyHyds13EIgKRdOeAHPS8enWhP56gPHNbm4bEIeH5IGO6dVzcIbpq6Z3ftvlJfAoCEykHjdYpnmAIxgbt8Qi0WWkboKI9AryGgGHR1hLnX1wy4WxBHHNzIxgb9gRIqddRahO5XCDq1LcxQHvGE9UOG(inFy1YyHwTEdxi4dC4A95AlmC(CDePHNbm4bEIeH5IGO6dl59g8(850lcZlpzqGi)acac9Dv9wL9MvEYgobb4IG(EdQsQ3CeMsyYG8tdxeMxEYGar(beaKWkboKI9AryGgGHR1hLnX1wy4WxBHHvlmVCVbDce5hqaqcRahO5XCDq1LcxQHvGE9UOG(inFy1YyHwTEdxi4dC4A95AlmC(CHwKgEgWGh4jseMsyYG8tddfiGJxdGewjWHuSxlcd0amCT(OSjU2cdh(AlmSZqahVgajScCGMhZ1bvxkCPgwb617Ic6J08HvlJfA16nCHGpWHR1NRTWW5ZTArA4zadEGNiryUiiQ(Ww5jB4eeGlc67nOkPEtY6nNCQ3QQ3SYt2Wjiaxe03Bqvs9gu2Bv2BVnqWtVimVmbazI)1IfDeyWd80BveMsyYG8tdxeMxEYGar(beaKWkboKI9AryGgGHR1hLnX1wy4WxBHHvlmVCVbDce5hqaq6TQCRiScCGMhZ1bvxkCPgwb617Ic6J08HvlJfA16nCHGpWHR1NRTWW5Z15rA4zadEGNirykHjdYpnmuGao(xqOHHvcCif71IWanadxRpkBIRTWWHV2cd7meWX)ccnmScCGMhZ1bvxkCPgwb617Ic6J08HvlJfA16nCHGpWHR1NRTWW5ZfkJ0WZag8aprIWCrqu9HH3NpNU)1IfSGaGGc67Q6Tk7Tntqm4bsF(UyQAzSqZHZdtjmzq(PH9VwS8VGqddRe4qk2RfHbAagUwFu2exBHHdFTfgMFTy5FbHggwboqZJ56GQlfUudRa96Drb9rA(WQLXcTA9gUqWh4W16Z1wy485srKgEgWGh4jseMlcIQpSvEYgobb4IG(EdQsQ3QwV5Kt9wv9MvEYgobb4IG(EdQsQ3C0Bv2BVnqWtVimVmbazI)1IfDeyWd80BveMsyYG8tdxeMxEYGar(beaKWkboKI9AryGgGHR1hLnX1wy4WxBHHvlmVCVbDce5hqaq6TQCuryf4anpMRdQUu4snSc0R3ff0hP5dRwgl0Q1B4cbFGdxRpxBHHZNRKfPHNbm4bEIeH5IGO6d)2abpD9gkkYMacshbg8ap9wL92Mjig8aPpFxmvTmwOvnN3Bv2Bldh(xOx0l7cbc(EdQsQ3Qg1WuctgKFA4bbI8diaitG1JpSsGdPyVwegOby4A9rztCTfgo81wyyOtGi)acasVjHE8HvGd08yUoO6sHl1WkqVExuqFKMpSAzSqRwVHle8boCT(CTfgoFUoRin8mGbpWtKimxeevF4Q6njV3EBGGNUEdffztabPJadEGNERYEBZeedEG0NVlMQwgl0QMZ7Tk6nNCQ3QQ3EBGGNUEdffztabPJadEGNERYEBZeedEG0NVlMQwgl0KmQ9wfHPeMmi)0W(xlw(xqOHHvcCif71IWanadxRpkBIRTWWHV2cdZVwS8VGqd7TQCRiScCGMhZ1bvxkCPgwb617Ic6J08HvlJfA16nCHGpWHR1NRTWW5Z1LAKgEgWGh4jseMlcIQp8Mjig8aPB0mcyNsomLWKb5NgEUq7FyHboHvcCif71IWanadxRpkBIRTWWHV2cdxDeA)dlmWjScCGMhZ1bvxkCPgwb617Ic6J08HvlJfA16nCHGpWHR1NRTWW5Z11nsdpdyWd8ejcZfbr1hgEF(C6Y6FISbo03v1Bv2Bv1Bv1BBMGyWdKUrZiG9zqXDIkv4P3QS3G3NpN(CH2)WcdCOVRQ3QO3CYPEtY7Tntqm4bs3OzeW(mO4orLk80BveMsyYG8tdpSnBYW8YHvcCif71IWanadxRpkBIRTWWHV2cddDBZ6nOBE5WkWbAEmxhuDPWLAyfOxVlkOpsZhwTmwOvR3Wfc(ahUwFU2cdNpxxhrA4zadEGNiryUiiQ(Ww5jB4eeGlc67nOkPEdAHPeMmi)0W(DWbfeaKWkboKI9AryGgGHR1hLnX1wy4WxBHH5DWbfeaKWkWbAEmxhuDPWLAyfOxVlkOpsZhwTmwOvR3Wfc(ahUwFU2cdNpxxOfPHNbm4bEIeH5IGO6dBLNSHtqaUiOV3GQK6nO1Bo5uVTzcIbpq6qNar(beae1cZlF1F1vvV5Kt92Mjig8aPBdvYMZOhZvlJfAHPeMmi)0WfH5LNmiqKFabajSsGdPyVwegOby4A9rztCTfgo81wyy1cZl3BqNar(beaKERkOvryf4anpMRdQUu4snSc0R3ff0hP5dRwgl0Q1B4cbFGdxRpxBHHZNpmxeevF48ja]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170615.082054, [[d4ssbaGEjrBscSljLTjPA2k1nrHBl0ovYEP2ns7xfdtQ63enyfnCPYbLIoMGfkfwQcwSkTCcpus6PGhtY6KOAIsctvHMmPA6IUiQ0LHUokzRsK2SeQTlrmpPuhwvphvnAPKLrkNuIYPrCnjOZlH8mu03qfVgLAh8ObU0)UrDFnS(iAaiXQNjxARNQWisZYptzhsrHHkWIFw70nmmGB85rV06dC6RhywtlWme4ya6qf53Kk)KiPEPvNPHMQKiP8E0RGhnWL(3nQ7ggaLG0LgIpU5tHmwtXsiqAEMTpZqHNzbNzsI4z2(m1m08s2KSidcPI9LKOWqzuDI6tPWavsrdmK6L(I1hrdgwFenmivSVKefggWn(8OxA9boHEddiVKLqH8E0PHQTqfBgYsWistFnWqQV(iAWPtdGsq6sdoTb]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170615.082054, [[d0ZxhaGEkaTjkODrOTrrX(Gk65cnBQmFuv3uP6XICBOCyv2jk2R0Uv1(rmkkQgMs8BfNhLyOqfYGrA4c6GOuoLa6ykPtt0crfTukYIjy5u1drfwffaltuzDqvLMiubtLcnzknDixeLQNbvLldUUszJuaTvrHnJQSDusFhQYxHQQAAqvvMhfOrcvOETOQrlk9nOsNua(mQ01efDpOQI)kqpL0HOO0DTgRY(FcoWwHQmhguvLyCqOS)zVpbyWJWVekh4qSkoa8UnhQCw1e4GlcLj3YkUlMzfFI5wX36kUv1qijpN0aEi58LjNzWxv2si58XASmR1yv2)tWb2kuvtEziQkA4Y1bIPzC2bVpsOgsOMtOOZZfqIzHZHYkgMqeQbj0CzsO85tOijgqO4KqxeZCzHqdSkBcsNeXsvb3mw3wevnG3kthA8v)5HQ7JnJZZCyq1Qmhgufhd(rgXQAcCWfHYKBzf31LQMG4S5tqSglQkhzHu(9HvadEufQUpwMddQwuzYvJvz)pbhylNv1KxgIQIgUCDGyAgNDW7JeQHeQ5eQWgpEIxmbV9(eiUfsO85tOMtO8a)5cgdLEjs0dyN8Jekoj0mj0aju(8juhWk4iudsORlleAGvztq6KiwQka(i4ZlFUvd4TY0HgF1FEO6(yZ48mhguTkZHbv5e8rWNx(CRAcCWfHYKBzf31LQMG4S5tqSglQkhzHu(9HvadEufQUpwMddQwuzWxnwL9)eCGTCwvtEziQkA4Y1bIPzC2bVpsOgsOMtOcB84jEXe827tG4wiHYNpHAoHYd8Nlymu6LirpGDYpsO4KqZKqdKq5ZNqDaRGJqniHUUSqObwLnbPtIyPQGBgBqEBEwQgWBLPdn(Q)8q19XMX5zomOAvMddQYPBglHAGBEwQAcCWfHYKBzf31LQMG4S5tqSglQkhzHu(9HvadEufQUpwMddQwuzWF1yv2)tWb2Yzvn5LHOQOHlxhigoi58rc1qc1CcvyJhpXlMG3EFce3cju(8juZsOOZbps8Ij4T3Nar4pbhyjudjuEG)CbJHsVej6bSt(rcfNeAMekF(ek68CbKisIbbrtqReiudIFiuZSqObwLnbPtIyPA4GKZxnG3kthA8v)5HQ7JnJZZCyq1Qmhgufhni58vnbo4IqzYTSI76svtqC28jiwJfvLJSqk)(WkGbpQcv3hlZHbvd9JBEUGny4Gh4lQmzwJvz)pbhylNv1KxgIQIgUCDGyAgNDW7Jvztq6KiwQYd8Nlymu6LOQb8wz6qJV6ppuDFSzCEMddQwL5WGQgi4phHQHsVev1e4GlcLj3YkURlvnbXzZNGynwuvoYcP87dRag8OkuDFSmhguTOYyMASk7)j4aB5SQM8YquvliSXJNiCEuw4dgdL5bXTqc1qcfDo4rIW5rzHpymuMheH)eCGLq5ZNqnlHIoh8ir48OSWhmgkZdIWFcoWwLnbPtIyPQDgSG4jFBSAaVvMo04R(Zdv3hBgNN5WGQvzomOkomdgHI)LVnw1e4GlcLj3YkURlvnbXzZNGynwuvoYcP87dRag8OkuDFSmhguTOYGBnwL9)eCGTCwvtEziQkA4Y1bIPzC2bVpsOgsOMvyJhpXlMG3EFce3cjudjuZjuHnE8eTZGfep5BJIBHekF(eAAgNDW7fTZGfep5BJIEa7KFKqXjHYnzjudaHIpcnWQSjiDselvVycE79jOAaVvMo04R(Zdv3hBgNN5WGQvzomOkBXe827tqvtGdUiuMClR4UUu1eeNnFcI1yrv5ilKYVpScyWJQq19XYCyq1IkQQM8Yqu1IAb]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170615.082054, [[d4dXjaGEIQQ2eb1UufBdOQ9PkvZujONROzlX8jcUPK6WuDBkwgP0ovv7vSBe7xQ(Pssnmj53iDEcYqjczWsz4kPoiH0PuL4yKQZruvAHeILsGfRulh0dPepf1JvyDeHYejQkMkHAYaMUkxeOCAsUm01PuBujWwjQSzsX2jsptjKXPKKptjnpLq9AIY3uIgnqMMQKojr0FvsCnIQCpGkhIiuDCIQkJsvkh9iomyeFxqGSd)DdgMvgl9gyeqozGgKCsSEtJQuqyy5dQXTlxejSaSG(eZxBL(YkWRVOhT6lsxFzyEnouErj)9trj5Rf8lkSOJtrjZioF9iomyeFxqGisyEavRVWghlZdsnpdBiejxVT4EtxBvyr3QI6ekmKoKTvhcdljbqn8JcdtOemCnfqoh(Ddgo83nyyb0HST6qyybyb9jMV2k9L6vHfGtQnCGZioxylGWHSAQu0GKl7W1uGVBWW5YxBehgmIVliqejmpGQ1x4TTgnpAkUbpkXQn(arJRiZEBX92RpRkSOBvrDcfwtXn4rjwTXWssaud)OWWekbdxtbKZHF3GHd)DdgEbf3GhLy1gdlalOpX81wPVuVkSaCsTHdCgX5cBbeoKvtLIgKCzhUMc8Ddgox(lkIddgX3feiIeMhq16lSXXY8GuZZWgcrY1BlgC92RvHfDRkQtOWq6q2wDimSKea1WpkmmHsWW1ua5C43ny4WF3GHfqhY2QdH92B6VewawqFI5RTsFPEvyb4KAdh4mIZf2ciCiRMkfni5YoCnf47gmCU8FnIddgX3feiIeMhq16l8B925fKCpdOpbPiwxzEuO5bj(UGa9MeKqV5JtjfxbjOrHZE7DW1BA7Tx6nH7naCBRrZd6WdeswzUwjdFSx3Bc3BghlZdsnpdBiejxV9o46TxR6nH7nPou57c(SAlseLwaFvyr3QI6ek8a6tqRuuwbDefXAyjjaQHFuyycLGHRPaY5WVBWWH)UbdBb6tq92cvwbDefXAybyb9jMV2k9L6vHfGtQnCGZioxylGWHSAQu0GKl7W1uGVBWW5YxErCyWi(UGarKW8aQwFHpVGK7bKRkZJcnpiX3feO3eU322A08ObsN3g6eGhiACfz2BlU3E9zv9MW9MXXY8GuZZWgcrY1BV3BVwfw0TQOoHcRbsN3g6eGWssaud)OWWekbdxtbKZHF3GHd)DdgEbq682qNaewawqFI5RTsFPEvyb4KAdh4mIZf2ciCiRMkfni5YoCnf47gmCU8bFehgmIVliqejmpGQ1xyPou57c(4YCfXgm5NTA9AeO3eU3K4922wJMhnq682qNa8yVU3eU3mowMhKAEg2qisUE7DW1BlLxyr3QI6ekSgiDEBOtacljbqn8JcdtOemCnfqoh(Ddgo83ny4faPZBdDcqV9M(lHfGf0Ny(AR0xQxfwaoP2WboJ4CHTachYQPsrdsUSdxtb(UbdNl)LrCyWi(UGarKWIUvf1ju4PnbaHkI1Wssaud)OWWekbdxtbKZHF3GHd)DdgMTjaiurSgwawqFI5RTsFPEvyb4KAdh4mIZf2ciCiRMkfni5YoCnf47gmCU8xvehgmIVliqejmpGQ1xyJJL5bPMNHneIKR3EhC9M8Q6nH7nPou57c(SAlseLwww1Bc3BsDOY3f8rJnuilGWHSvvfw0TQOoHcxCP(kfFckSKea1WpkmmHsWW1ua5C43ny4WF3GHxOl17Tf6tqHfGf0Ny(AR0xQxfwaoP2WboJ4CHTachYQPsrdsUSdxtb(UbdNlF5BehgmIVliqejSOBvrDcfgshY2QdHHLKaOg(rHHjucgUMciNd)Ubdh(7gmSa6q2wDiS3Et7lHfGf0Ny(AR0xQxfwaoP2WboJ4CHTachYQPsrdsUSdxtb(UbdNlF9QiomyeFxqGisyEavRVWA8Ye7nH7T36nJJL5bPMNHneIKR3EhC9g4LxVjbj0BNxqY9mG(eKIyDL5rHMhK47cc0Bsqc9MpoLuCfKGgfo7T3bxVPT3EP3eU3K6qLVl4ZQTiruAb8v9MW9MuhQ8DbF0ydfYciCi7v5fw0TQOoHcpG(e0kfLvqhrrSgwscGA4hfgMqjy4AkGCo87gmC4VBWWwG(euVTqLvqhrrS2BVP)sybyb9jMV2k9L6vHfGtQnCGZioxylGWHSAQu0GKl7W1uGVBWW5YxxpIddgX3feiIew0TQOoHcRP4g8OeR2yyjjaQHFuyycLGHRPaY5WVBWWH)UbdVGIBWJsSAJ92B6VewawqFI5RTsFPEvyb4KAdh4mIZf2ciCiRMkfni5YoCnf47gmCUCH5buT(cNlba]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170615.082054, [[dOtQgaGEifAteKDrHTPOY(Gu0mHuWSPYnvk3wWovP9kTBG9l0OGuQHbj)g0ZvYJvyWu1WjkhecDkiLCmf5WIwibAPePfRILd1dvQSkivAzevRtrrMOIIAQeQjtPPRQlcr9kivCzKRtQ2OIQ2kfXMjLTdr(UIsNMKPbPkZtrHNra9AkQrteFdcojfPdraUgKQ68kv9zc5Veupf1DQIlJmipoY2t5BgOYSkSl6rgijbdkqGFMI(JUM2Q8mtAPU7RGLLsokxuVYrnHaQ5MeOH8jbonHqzwgnuPtHgZxbb9kFobwgXXRGGvf37ufxgzqECKTcwMhyLSV8Noc8gUeyxoLLmiqECKn6fk6fq0F010mCjWUCklzOlRmIhLt97lJHdZh1t4YMcSQr(qCzaeqL3Gwts8ndu5Y3mqLLchMpQNWLLsokxuVYrnHWeQYsPfuhpOvf3V8oj0W8gejkqGVNYBq7ndu5(9kVIlJmipoYwblZdSs2xwar)RgMvarrVqrFij36XWGXqhJjWh9Oz0lxEzepkN63xwthVxyOMWPcx2uGvnYhIldGaQ8g0AsIVzGkx(MbQ88649rpul6ruHllLCuUOELJAcHjuLLslOoEqRkUF5DsOH5nisuGaFpL3G2BgOY97vGvCzKb5Xr2kyzEGvY(Yj(vA54nsNmjPWZcDAg4eyo6rZOhv0lu0ldtijSOH1yYqJWPt4Lmfw9Lr8OCQFF5boxse2Pej5bkGOYMcSQr(qCzaeqL3Gwts8ndu5Y3mqL3HZLKOhnOej5bkGOYsjhLlQx5OMqycvzP0cQJh0QI7xENeAyEdIefiW3t5nO9MbQC)ErVkUmYG84iBfSmpWkzFzbe9hDnndnxgOhcePtg6YkJ4r5u)(YAUmqpeisNkBkWQg5dXLbqavEdAnjX3mqLlFZavEExgOhcePtLLsokxuVYrnHWeQYsPfuhpOvf3V8oj0W8gejkqGVNYBq7ndu5(9I(vCzKb5Xr2kyzEGvY(YF6iWBijvU1dXbdcKhhzJEHIEbe9hDnndnmC9hCcSg6YIEHIEKsSkpoYqthVFNeAyg9q)YiEuo1VVSggU(dob2YMcSQr(qCzaeqL3Gwts8ndu5Y3mqLNhdx)bNaBzPKJYf1RCutimHQSuAb1XdAvX9lVtcnmVbrIce47P8g0EZavUFVZvXLrgKhhzRGL5bwj7lF010m0CzGEiqKozGPqQaROFgr)Crp6e9Ig2OxOOFaHolCwGHfcdcpRcyxgykKkWk6Nr0lAyJE0n6LxgXJYP(9L1CzGEiqKov2uGvnYhIldGaQ8g0AsIVzGkx(MbQ88UmqpeisNIE0EcTklLCuUOELJAcHjuLLslOoEqRkUF5DsOH5nisuGaFpL3G2BgOY97fHkUmYG84iBfSmpWkzF5pDe4nKKk36H4GbbYJJSrVqr)rxtZqddx)bNaRbMcPcSI(ze9Zf9Ot0lAyJEHI(be6SWzbgwimi8SkGDzGPqQaROFgrVOHn6r3OxEzepkN63xwddx)bNaBztbw1iFiUmacOYBqRjj(MbQC5BgOYZJHR)GtGn6r7j0QSuYr5I6voQjeMqvwkTG64bTQ4(L3jHgM3Girbc89uEdAVzGk3VFzEGvY(Y9Bba]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170613.213117, [[deKzmaqivLQweuv2KquJcQQofuL2LQQHPkDmvXYijpJOuMMQsrxtjfBdQI(gk04GQGZPQuX6uvY8ikv3tjL2NqKdssTquWdfstuvPuxKiTrIsYivvk5KevMjrjUPsStO8tOk0qvvQ0srPEkYujITsu1xjkP2R0FfkdMIdRyXK4XcMSsDzWMjk(mkA0QkonHxJsA2O62KA3Q8BidxOA5u1ZPY0fDDOY2rj(UsQoVsY6vvkmFHW(P09Pskj9gfoSldLO4qqmCX3ysb6kMk8uvjSrdLiHoQ1iLdA4YH)L1SbzgC8SeBGdJdkMQ3hgFXZNNFvVR55HXsuWlINLkPoKc05QKI9ujLKEJch2vPef8I4zPeXKjh(dieFJw)CwtKTg8Bn54zc5)hy45N)4H0AKDRr1ASMiIWAsHgSMiznV)R591AWBj1kcUixvsHJqBooxwsUBlctI8Lo0bLwqB5hp2OHsLWgnu6BbEKWPlXg4W4GIP69HXN3sSbhcNpaUkPzPOFGaRliwanCzvkTG2yJgk1SyQQKssVrHd7Yqjk4fXZsjIjto8hhLc05SMiBn43AcieFJw)(Lr4Hyah0WLd)3d6rCoRjswJk8WR1erewtoEMq(NcnelrX2cWAK91An45R1G3sQveCrUQuCukqxj5UTimjYx6qhuAbTLF8yJgkvcB0qPVlkfOReBGdJdkMQ3hgFElXgCiC(a4QKMLI(bcSUGyb0WLvP0cAJnAOuZIjBvsjP3OWHDzOef8I4zPeXKjh(fxcEpU4PRKAfbxKRkTU42XCFGXxsUBlctI8Lo0bLwqB5hp2OHsLWgnuswlUT1qFGXxInWHXbft17dJpVLydoeoFaCvsZsr)abwxqSaA4YQuAbTXgnuQzX(MvsjP3OWHDzOef8I4zjfCYiZVhCOBUaelrjO)9GEeNZAKDRrvj1kcUixvkrjOJPhxc(vLK72IWKiFPdDqPf0w(XJnAOujSrdLKGsqBnlJlb)QsSbomoOyQEFy85TeBWHW5dGRsAwk6hiW6cIfqdxwLslOn2OHsnl2AQKssVrHd7Yqjk4fXZsjIjto8hqi(gT(5kPwrWf5QsYi8qmGdA4YHxsUBlctI8Lo0bLwqB5hp2OHsLWgnuswj8G1iLdA4YHxInWHXbft17dJpVLydoeoFaCvsZsr)abwxqSaA4YQuAbTXgnuQzXWZkPK0Bu4WUmuIcEr8SuIyYKd)beIVrRFUsQveCrUQKlrEDmGdA4YHxsUBlctI8Lo0bLwqB5hp2OHsLWgnuIsKxBns5GgUC4LydCyCqXu9(W4ZBj2GdHZhaxL0Su0pqG1felGgUSkLwqBSrdLAwmgRKssVrHd7Yqjk4fXZsjIjto8hqi(gT(5kPwrWf5Qsah0WLdpMECj4xvsUBlctI8Lo0bLwqB5hp2OHsLWgnuskh0WLd3Awgxc(vLydCyCqXu9(W4ZBj2GdHZhaxL0Su0pqG1felGgUSkLwqBSrdLAwm8qLus6nkCyxgkrbViEwkrmzYH)acX3O1pN1ezRb)wZ3Bn5WHl)hxaU9Cb4hUrHdBRjIiSgfCYiZ)4cWTNla)4IBnreH1eqi(gT(9pUaC75cWVh0J4CwtKSM18An4TKAfbxKRkPWrODmzW5xvsUBlctI8Lo0bLwqB5hp2OHsLWgnuIbocTTgzfo)QsSbomoOyQEFy85TeBWHW5dGRsAwk6hiW6cIfqdxwLslOn2OHsnl23Pskj9gfoSldLOGxeplLiMm5WFaH4B06NZAIS1GFR57TMC4WL)Jla3EUa8d3OWHT1erewJcozK5FCb42ZfGFCXTg8wsTIGlYvLuaVd8SkoMLK72IWKiFPdDqPf0w(XJnAOujSrdLya8oWZQ4ywInWHXbft17dJpVLydoeoFaCvsZsr)abwxqSaA4YQuAbTXgnuQzXEERKssVrHd7Yqjk4fXZstifSaXGd0cWznrYAuznr2AWV1mHuWcedoqlaN1ejRrL1erewZesblqm4aTaCwtKSgvwdElPwrWf5QsECxSjKc0fJlCzj5UTimjYx6qhuAbTLF8yJgkvcB0qj24oRrDifOZAKfHllP2Z0v6gnSw8rcDuRrkh0WLd)lRrnEuk(kXg4W4GIP69HXN3sSbhcNpaUkPzPOFGaRliwanCzvkTG2yJgkrcDuRrkh0WLd)lRrnEuAZI98ujLKEJch2LHsuWlINLYHdx(pUaC75cWpCJch2LuRi4ICvjpUl2esb6IXfUSKC3weMe5lDOdkTG2YpESrdLkHnAOeBCN1OoKc0znYIWLwd(FWBj1EMUs3OH1IpsOJAns5GgUC4FznoXXKdwZ4c4ReBGdJdkMQ3hgFElXgCiC(a4QKMLI(bcSUGyb0WLvP0cAJnAOej0rTgPCqdxo8VSgN4yYbRzCHMf7rvLus6nkCyxgkrbViEwkhoC5ViaYGZV6hUrHd7sQveCrUQKh3fBcPaDX4cxwsUBlctI8Lo0bLwqB5hp2OHsLWgnuInUZAuhsb6Sgzr4sRb)QWBj1EMUs3OH1IpsOJAns5GgUC4FznoXXKdwJqg8vInWHXbft17dJpVLydoeoFaCvsZsr)abwxqSaA4YQuAbTXgnuIe6OwJuoOHlh(xwJtCm5G1iKPzXEKTkPK0Bu4WUmuIcEr8SuoC4YFUG5N8ehZyE0(hUrHd7sQveCrUQKh3fBcPaDX4cxwsUBlctI8Lo0bLwqB5hp2OHsLWgnuInUZAuhsb6Sgzr4sRb)YgElP2Z0v6gnSw8rcDuRrkh0WLd)lRXjoMCWA4E8vInWHXbft17dJpVLydoeoFaCvsZsr)abwxqSaA4YQuAbTXgnuIe6OwJuoOHlh(xwJtCm5G1W9nBw6BdYm44zzOzla]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170613.213117, [[d8cxcaGErI2LiPTjsz2s5MKQBtYoPYEr7MW(HkgMi(TKHsjXGLQA4IQdkkoguwiLyPqyXez5u1dLQ8uWYKkRJsQMiuvnvk1KH00fUiP0LvDDrPTcr2mLu2ouPpls1ZvYJvQdRy0quFJOCsOkNMIRbvLZtu9AsXFPK0ZejmXOnbTIrQDuAHGBuNayu9WPV22vxetZ640p3)DPKMGaK)TzAMuoHPe01LwhbeV9zD66sWKLKggwQDj4ddtgby7n5bbcz2HPelAthgTjOvmsTJsleGT3KheIk90Bp18kmLyriJKPzc5eYRWucc4jqn7jkpbrjob9cfPX7g1jqWnQtWkvykbbeV9zD66sWKHLqaXxvw)(lAZGqpK)wJEH7vxeuIGEH6g1jWGUoAtqRyKAhLwiKrY0mHCcrfxzv1SI7LtapbQzpr5jikXjOxOinE3OobcUrDc2vCfo91NvCVCciE7Z601LGjdlHaIVQS(9x0MbHEi)Tg9c3RUiOeb9c1nQtGbDPG2e0kgP2rPfczKmntiNWkkVsZF(9eWtGA2tuEcIsCc6fksJ3nQtGGBuNaeLxP5p)EciE7Z601LGjdlHaIVQS(9x0MbHEi)Tg9c3RUiOeb9c1nQtGbdc4)wBY2cAHbj]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170613.213117, [[deeZraqivrQnbQ0OOKCkkrRIOsYRiQuzwevkDlIkf7cuggsCmszzsONPkIPPePCnkPyBGk8nqvJtvKCoIkX6iQu18av09uIAFevCqvHfQeEisQjQeP6IQkTrLi5KucZujIBkr7eKLsuEkQPIu2krv7v8xL0GLQdRyXe5Xu1KvQldTzvvFMsnAs1Pj8AKQztLBtXUr8BGHRQ44usPLtYZL00v56QsBxc(UQOopsY6jQKA(us1(LYrl0c)LmsoCNfHHgdgMfgQB9Vo0GKBCY9TEvqSDyR7uHx64)86USim)b9IXjKRNtaibQiCumSm0HtfdurkAWtbo00GvKI1OPbFyz4SPIMWGH3Gd2VBm4Avh4PdtHMrqQYnwTrP3)Fy)UXGRvDGNoS9RAobGixrb2tSm8d)jaKAOfiTql8xYi5WDweM9kXNl8t36NWtxqSBDRB9wFdoy)UXGRvDGNomfAgbP26W5YTUTFh(HKWjoQc)7gdUw1bE6HTGSf(5aQWeabdxc2YpkOXGHddngm8s5gd26SoWtpSm0HtfdurkAWRrjSmScEvESgA5ctTo6PxckGgKCrkCjydngmCUavm0c)LmsoCNfHFijCIJQWOdni5g3QKBQxyliBHFoGkmbqWWLGT8JcAmy4WqJbd)1HgKCJR1x4M6fwg6WPIbQifn41OewgwbVkpwdTCHPwh90lbfqdsUifUeSHgdgoxGEsOf(lzKC4olcZEL4Zfw69)hg61byDf8VE64QTcNBT(s2OsqSH9(j8djHtCufgh1PBTVdDmSfKTWphqfMaiy4sWw(rbngmCyOXGH)oQt3AFh6yyzOdNkgOIu0GxJsyzyf8Q8yn0YfMAD0tVeuani5Iu4sWgAmy4CbAPfAH)sgjhUZIWSxj(CHnd6QNcyG5FvkKCTUCwU110GV1TU1B9NU1h1j(h)bR(m6CcI9Qzqx9uadmKmsoC36WT1nd6QNcyG5FvkKCTUCwU1Llfd)qs4ehvHXrD6RvDGNEyliBHFoGkmbqWWLGT8JcAmy4WqJbd)DuNERZ6ap9WYqhovmqfPObVgLWYWk4v5XAOLlm16ONEjOaAqYfPWLGn0yWW5cK1eAH)sgjhUZIWSxj(CHd)qs4ehvHRhqzOJ4huf2cYw4NdOctaemCjyl)OGgdgom0yWW8bug6i(bvHLHoCQyGksrdEnkHLHvWRYJ1qlxyQ1rp9sqb0GKlsHlbBOXGHZfi4i0c)LmsoCNfHzVs85ch(HKWjoQc7ew7RyVAgBZSEGdnHTGSf(5aQWeabdxc2YpkOXGHddngm8sew7Ry36LJTzADAGdnHLHoCQyGksrdEnkHLHvWRYJ1qlxyQ1rp9sqb0GKlsHlbBOXGHZfi4dTWFjJKd3zry2ReFUWBWb73ngCTQd80HPqZii1wxoTUFQ36jmyRd3w3daUn4zYQch)f(HKWjoQc7McZQ0RQEHTGSf(5aQWeabdxc2YpkOXGHddngm8sMctRV4vvVWYqhovmqfPObVgLWYWk4v5XAOLlm16ONEjOaAqYfPWLGn0yWW5c0tfAH)sgjhUZIWSxj(CHTQ1nd6QNcyG5FvkKCTUCwU1lsP1HBRl9()ddDObj34w)b(3kS3pTULToCBDRADf(RWQ(i5Ww3YWpKeoXrv4F3yW1QoWtpSfKTWphqfMaiy4sWw(rbngmCyOXGHxk3yWwN1bE6TUvAwg(HYUg(gLnERI)Lv4VcR6JKddldD4uXavKIg8AucldRGxLhRHwUWuRJE6LGcObjxKcxc2qJbdNlqYLql8xYi5WDweM9kXNlSzqx9uadm)RsHKR1LZYTUMMwRBDR36pDRpQt8p(dw9z05ee7vZGU6PagyizKC4U1HBRBg0vpfWaZ)Qui5AD5SCR)uWr4hscN4OkmoQtFTQd80dBbzl8ZbuHjacgUeSLFuqJbdhgAmy4VJ60BDwh4P36wPzzyzOdNkgOIu0GxJsyzyf8Q8yn0YfMAD0tVeuani5Iu4sWgAmy4CbsJsOf(lzKC4olcZEL4Zfw69)hMcRaYq846bo0atHMrqQToC26AuADRB9w3Qwx69)hMcRaYq846bo0atHMrqQToC26w16sV))WMQhj7H4ry7x1CcaP1L7ADpa42GNjWMQhj7H4ryk0mcsT1TS1HBR7ba3g8mb2u9izpepctHMrqQToC26AwtRBz4hscN4Ok8bo0SAM6HkQcBbzl8ZbuHjacgUeSLFuqJbdhgAmyyAGdnTE5upurvyzOdNkgOIu0GxJsyzyf8Q8yn0YfMAD0tVeuani5Iu4sWgAmy4Cbstl0c)LmsoCNfHzVs85cBvRl9()d7d4zuTc(xpDC1mOREkGb27NwhUT(4prbCfjOrG1whoB9N06w26WT1TQ13O07)pmNWw)icI9QcSHTbptADld)qs4ehvHDcB9Jii2Rsa3f2cYw4NdOctaemCjyl)OGgdgom0yWWlryRFebXU1xaCx4hk7A4Bu24Tk(xEJsV))WCcB9Jii2RkWg2g8mjSm0HtfdurkAWRrjSmScEvESgA5ctTo6PxckGgKCrkCjydngmCUaPvm0c)LmsoCNfHzVs85cl9()d7d4zuTc(xpDC1mOREkGb27NwhUT(4prbCfjOrG1whoB9Ne(HKWjoQc7e26hrqSxLaUlSfKTWphqfMaiy4sWw(rbngmCyOXGHxIWw)icIDRVa4Uw3knldldD4uXavKIg8AucldRGxLhRHwUWuRJE6LGcObjxKcxc2qJbdNlqApj0c)LmsoCNfHzVs85cBvRp(tuaxrcAeyT1LtRR16WT1h)jkGRibncS26YP11ADlBD426w16Bu69)hMtyRFebXEvb2W2GNjTULHFijCIJQWE9rqwDcB9Jii2HTGSf(5aQWeabdxc2YpkOXGHddngmm16JG06lryRFebXo8dLDn8nkB8wf)lVrP3)FyoHT(ree7vfydBdEMewg6WPIbQifn41OewgwbVkpwdTCHPwh90lbfqdsUifUeSHgdgoxG0wAHw4VKrYH7Sim7vIpx4XFIc4ksqJaRTUCADTwhUT(4prbCfjOrG1wxoTUw4hscN4OkSxFeKvNWw)icIDyliBHFoGkmbqWWLGT8JcAmy4WqJbdtT(iiT(se26hrqSBDR0SmSm0HtfdurkAWRrjSmScEvESgA5ctTo6PxckGgKCrkCjydngmCUaPznHw4VKrYH7Sim7vIpx4nk9()dZjS1pIGyVQaByBWZKWpKeoXrvyNWw)icI9QeWDHTGSf(5aQWeabdxc2YpkOXGHddngm8se26hrqSB9fa316wv0YWpu21W3OSXBv8V8gLE))H5e26hrqSxvGnSn4zsyzOdNkgOIu0GxJsyzyf8Q8yn0YfMAD0tVeuani5Iu4sWgAmy4CbsdocTWFjJKd3zr4hscN4OkStyRFebXEvc4UWwq2c)CavycGGHlbB5hf0yWWHHgdgEjcB9Jii2T(cG7ADREILHLHoCQyGksrdEnkHLHvWRYJ1qlxyQ1rp9sqb0GKlsHlbBOXGHZfin4dTWFjJKd3zry2ReFUWk8xHv9rYHHFijCIJQW)UXGRvDGNEyQ1rp9sqb0GKllcxc2YpkOXGHdBbzl8ZbuHjacggAmy4LYngS1zDGNERBvrld)qzxdBafee7L1KBVrzJ3Q4Fzf(RWQ(i5WWYqhovmqfPObVgLWYWk4v5XAOLlCjOGGyhiTWLGn0yWW5cK2tfAH)sgjhUZIWpKeoXrvyCuN(Avh4PhMAD0tVeuani5YIWLGT8JcAmy4Wwq2c)CavycGGHHgdg(7Oo9wN1bE6TUvfTm8dLDnSbuqqSxwlSm0HtfdurkAWRrjSmScEvESgA5cxckii2bslCjydngmCUaPjxcTWFjJKd3zry2ReFUW3OSXd2wuVH4XwxoToCe(HKWjoQc)7gdUw1bE6HPwh90lbfqdsUSiCjyl)OGgdgoSfKTWphqfMaiyyOXGHxk3yWwN1bE6TUvpXYWpu21WgqbbXEzTWYqhovmqfPObVgLWYWk4v5XAOLlCjOGGyhiTWLGn0yWW5YfM9kXNlCUea]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170613.213117, [[de09taqiuKSjLkgLsOtPeSkue1RijLAwKKkDlssf7svzyqPJrulJK6zOOyAKKQUMsuABkr13uv14uIIZHIiRJKu08qr4Ekr2hkQoOQkluj5HOuMijPWfvQAJkvQtIs1mrrPBkr7uvwkr8uKPIs2kjXEf)ffgSuoSIftIhtLjdvxgSzLYNjsJMsDAkEnumBjDBsTBc)gYWLGJJIulhvpNQMUkxNs2Ue67kvY5vsTEssjZNKK9lvh5Wk0EXOub8Sk0B0qiYOzR32xbniUPQA2BEJqAf6nZwivdyBSQxwfIkaoZunQwZzqI8uVC1HKavy8qEQXk)h7YLL)uJDzLL)hscm4Rzz0qiC09TvhnWWBJCy(4GEmcVQZI4GI1223wD0adVnYH5d3IpNbjyYy)yMfc9ZDgKWhw5jhwH2lgLkGNvHih3u4cXu92zCymcP9MQuvVHJUVT6ObgEBKdZhh0Jr47nMyPEtQdp0pft1CRdTvhnWWBJCycXUa34MdXdjqciujcxLH)gnek0B0qODxhn0BKnYHjKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlp1HvO9IrPc4zviYXnfUqkwBBFGZgbEgOngNnWqkhMJH3sGdCJq6NvHEBNEtpq1FCK(ZzX5G46nMVuVTmlp0pft1CRdbd)SzARbdeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7h(zZ0wdgiKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlpMjScTxmkvapRcroUPWfsXAB7Z4Gnl(6pRc92o9MEGQ)4i9NZIZbX1BmFPEtwwU32P3yQEtXAB7B8oqGpch8zvi0pft1CRdTXr(JH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7MJ8xVr2ihMqsGkmEip1yL)lJnKeWJS4oWhw5cXMn4WuIkcAqCrjujc)nAiuU8u9HvO9IrPc4zvOFkMQ5whcQGge3uzOuh)fIDbUXnhIhsGeqOseUkd)nAiuO3OHq7RGge3u7Tv1XFHKavy8qEQXk)xgBijGhzXDGpSYfInBWHPeve0G4IsOse(B0qOC5TSHvO9IrPc4zviYXnfUq6bQ(JJ0FolohexVX8L6nz5)9MQuvVXu92WpZ24Up)UGA1iKYqpq1FCK(deJsfW7TD6n9av)Xr6pNfNdIR3y(s9gtsDOFkMQ5whcg(zZWBJCycXUa34MdXdjqciujcxLH)gnek0B0qO9d)S7nYg5WescuHXd5PgR8FzSHKaEKf3b(Wkxi2SbhMsurqdIlkHkr4VrdHYL3YdRq7fJsfWZQqKJBkCHc9tXun36q(dX1yaOaWdXUa34MdXdjqciujcxLH)gnek0B0qi6qCngaka8qsGkmEip1yL)lJnKeWJS4oWhw5cXMn4WuIkcAqCrjujc)nAiuU8(hwH2lgLkGNvHih3u4cTyVPhO6pos)5S4CqC9gtSuVjJvU32P3g(z2g3953fuRgHug6bQ(JJ0FGyuQaEVPkv1BmvVn8ZSnU7ZVlOwncPm0du9hhP)aXOub8EBNEtpq1FCK(ZzX5G46nMyPE7)Y7Tf6TD6nMQ3uS22(gVde4JWbFwfc9tXun36qghSzXxhIDbUXnhIhsGeqOseUkd)nAiuO3OHqS7Gnl(6qsGkmEip1yL)lJnKeWJS4oWhw5cXMn4WuIkcAqCrjujc)nAiuU8wMWk0EXOub8Ske54McxOq)umvZTou1W0wgCg6rQEyCOd0HyxGBCZH4HeibeQeHRYWFJgcf6nAieZAyAldEVvos1tVXcDGoKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlpMuyfAVyuQaEwfICCtHlKI122xb0Uaod0gJZgyOhO6pos)zvO32P3uS22(8hIRXaqbG)zvO32P3g3zkcmabOnGV3yIEJzc9tXun36qvJu7tyeszOGQxi2f4g3CiEibsaHkr4Qm83OHqHEJgcXSgP2NWiK2BRq1lKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlpzSHvO9IrPc4zviYXnfUq4O7BRoAGH3g5W8Xb9ye(EJ59MB8hJZOHEBNEZHqvC0Uem4W4Uq)umvZTouDkomuS4(le7cCJBoepKajGqLiCvg(B0qOqVrdHy2P40BRS4(lKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlpz5Wk0EXOub8Ske54McxifRTTpJd2S4R)Sk0B70Bl2Bl2B6bQ(JJ0FolohexVX8L6n1y7Tf6nvPQEtXAB7Z4Gnl(6poOhJW3BmrVTyVj)TS9gtU38fGALH94pO3yY9MI122NXbBw81F(BCy6nv7EtU3wO3wi0pft1CRdTXr(JH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7MJ8xVr2ihMEBr5fcjbQW4H8uJv(Vm2qsapYI7aFyLleB2GdtjQiObXfLqLi83OHq5YtwDyfAVyuQaEwfICCtHl0I9MEGQ)4i9NZIZbX1BmFPEtn2EBNEtXAB7dQGge3uzSHCw(pRc92c92o92I9gh24G3EuQqVTqOFkMQ5whARoAGH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7UoAO3iBKdtVTO8cH(XL6dDdxkCmmBlXHno4ThLkescuHXd5PgR8FzSHKaEKf3b(Wkxi2SbhMsurqdIlkHkr4VrdHYLNmZewH2lgLkGNvHih3u4cPyTT9zCWMfF9NvHq)umvZTo0gh5pgEBKdti2SbhMsurqdIlRcvIWvz4VrdHcXUa34MdXdjqci0B0qODZr(R3iBKdtVTO6fc9Jl1hsJkAesxsoKeOcJhYtnw5)Yydjb8ilUd8HvUqLOIgH08KdvIWFJgcLlpzvFyfAVyuQaEwfICCtHlKEGQ)4i9NZIZbX1BmFPEtwwU3uLQ6nMQ3g(z2g3953fuRgHug6bQ(JJ0FGyuQaEVTtVPhO6pos)5S4CqC9gZxQ3wMLh6NIPAU1HGHF2m82ihMqSlWnU5q8qcKacvIWvz4VrdHc9gneA)Wp7EJSrom92IYlescuHXd5PgR8FzSHKaEKf3b(Wkxi2SbhMsurqdIlkHkr4VrdHYLN8YgwH2lgLkGNvHih3u4cPyTT9XbpsmchW4qhO)4GEmcFVXe9Mm2q)umvZTo0HoqZqp(d4RdXUa34MdXdjqciujcxLH)gnek0B0qiwOd09w54pGVoKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlp5LhwH2lgLkGNvHih3u4cPyTT9boBe4zG2yC2adPCyogElboWncPFwfc9tXun36qWWpBM2AWaHyxGBCZH4HeibeQeHRYWFJgcf6nAi0(HF2mT1Gb6TfLxiKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlp5)HvO9IrPc4zviYXnfUqkwBBFfq7c4mqBmoBGHEGQ)4i9NvHEBNEBCNPiWaeG2a(EJj6nMj0pft1CRdvnsTpHriLHcQEHyxGBCZH4HeibeQeHRYWFJgcf6nAieZAKAFcJqAVTcvVEBr5fcjbQW4H8uJv(Vm2qsapYI7aFyLleB2GdtjQiObXfLqLi83OHq5YtEzcRq7fJsfWZQqKJBkCHg3zkcmabOnGV3yEVj3B70BJ7mfbgGa0gW3BmV3Kd9tXun36qo7XiyunsTpHrine7cCJBoepKajGqLiCvg(B0qOqVrdHyZEmIEJznsTpHrinKeOcJhYtnw5)Yydjb8ilUd8HvUqSzdomLOIGgexucvIWFJgcLlpzMuyfAVyuQaEwf6NIPAU1HQgP2NWiKYqbvVqSlWnU5q8qcKacvIWvz4VrdHc9gneIznsTpHriT3wHQxVTO6fcjbQW4H8uJv(Vm2qsapYI7aFyLleB2GdtjQiObXfLqLi83OHq5Ytn2Wk0EXOub8Ske54McxioSXbV9OuHq)umvZTo0wD0adVnYHjeB2GdtjQiObXLvHkr4Qm83OHqHyxGBCZH4Heibe6nAi0URJg6nYg5W0BlQEHq)4s9H0OIgH0LKvDVHlfogMTL4Wgh82JsfcjbQW4H8uJv(Vm2qsapYI7aFyLlujQOrinp5qLi83OHq5YtTCyfAVyuQaEwf6NIPAU1HGHF2m82ihMqSzdomLOIGgexwfQeHRYWFJgcfIDbUXnhIhsGeqO3OHq7h(z3BKnYHP3wu9cH(XL6dPrfncPljhscuHXd5PgR8FzSHKaEKf3b(WkxOsurJqAEYHkr4VrdHYLNA1HvO9IrPc4zviYXnfUq3WLc3hUXFJWb9gZ7TLh6NIPAU1H2QJgy4TromHyZgCykrfbniUSkujcxLH)gneke7cCJBoepKajGqVrdH2DD0qVr2ihMEBrMzHq)4s9H0OIgH0LKdjbQW4H8uJv(Vm2qsapYI7aFyLlujQOrinp5qLi83OHq5YfICCtHluUea]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170613.213117, [[de0qkaqijLQnbHmkIGtreAvqO0SKuuULKsYUiQgMs5yKyzsuptsPmnfsDnuuABqO6BkuJtsr6CskQwNKsyEkKCpuuTpiuCqjYcjPEiemrjLOlkPAJkeCsIOzkPWnLWovYpLusTuu4PitfI2krYEf)fsgmQ6WuTyu6XkAYs5YQ2mj5Zky0sYPj8AIYSP0Tj1Ub9BOgorQJRq0YP45s10bUUs12HuFhffNhfz9skI5RqO9JkhLGmuDOZAFlQdTC9drcncC81TxFiWT1co(s166HiP)u4wrnXbcmmRYiE5q1YRY3TGOoeJBV3FwL3ugVH4kkYlVXSkkJdX4EJjKc9d1Wa5QSU(O6v4Pm5MRDbSxRKq7S7QujxL11hvVcpLjVTBCGadrSBYRnjgQ0eiWWEqMLsqgQo0zTVf1HkXkScatH6aSrl7x6BcjjSjMoaBcbXWhQa3KYnlx)qHwU(Hia2OL9l9nHyC79(ZQ8MYyLTqmEhVBMVhKbecHQpLvGrF9HGWgQa3wU(HciRYbzO6qN1(wuhIMgH0Gqa8WG9YNySTHzgypujwHvaykK3Nh2C48HKe2ethGnHGy4dvGBs5MLRFOqlx)qL6ZdBoC(qmU9E)zvEtzSYwigVJ3nZ3dYacHq1NYkWOV(qqydvGBlx)qbKvTfKHQdDw7BrDOsScRaWuiRyK7IgkTpODuam46qscBIPdWMqqm8HkWnPCZY1puOLRFOAig5UOXXx4dANJhjgCDig3EV)SkVPmwzleJ3X7M57bzaHqO6tzfy0xFiiSHkWTLRFOaYA0bzO6qN1(wuhIMgH0GqsGJ3Nab6J6WRfVZXpko(rZXJioETFBhyWA5ZDJ5qahpIH5C8L344LihpI44LahV5QmVx5S2ZXlXqLyfwbGPqQSU(O6v4PSqscBIPdWMqqm8HkWnPCZY1puOLRFOrW66ZXtv4PSqLmd9qa3mCakHkMBUkZ7voR9HyC79(ZQ8MYyLTqmEhVBMVhKbecHQpLvGrF9HGWgQa3wU(HcilMnidvh6S23I6qLyfwbGPq3nGQrU7YEijHnX0bytiig(qf4MuUz56hk0Y1puD3aQg5Ul7HyC79(ZQ8MYyLTqmEhVBMVhKbecHQpLvGrF9HGWgQa3wU(Hcilepidvh6S23I6q00iKgeQHbYvzD9r1RWtzYnx7cyNJhXWXp9oafqOphpI44z3vPsU1r7O67MHlFxAoEeXXx7C8a3EiqUvmubGc4akdUj)qN1(ghpI449jqG(Oo8AX7C8JIJF0HkXkScatHSoAhf7UPdcjjSjMoaBcbXWhQa3KYnlx)qHwU(HQHJ254vVB6GqmU9E)zvEtzSYwigVJ3nZ3dYacHq1NYkWOV(qqydvGBlx)qbK14GmuDOZAFlQdrtJqAqOANJh42dbYTIHkauahqzWn5h6S2344rehVpbc0h1HxlENJFuC8mlh)ioIC8a3EiqUvmubGc4akdUj)qN1(ghpI449jqG(Oo8AX7C8JIJF0HkXkScatHU96dbUffR17GqscBIPdWMqqm8HkWnPCZY1puOLRFO62Rpe4woE1wVdcX4279Nv5nLXkBHy8oE3mFpidiecvFkRaJ(6dbHnubUTC9dfqw10GmuDOZAFlQdvIvyfaMczD0ok276qscBIPdWMqqm8HkWnPCZY1puOLRFOA4ODoE131HyC79(ZQ8MYyLTqmEhVBMVhKbecHQpLvGrF9HGWgQa3wU(HciRAEqgQo0zTVf1HOPriniu7S7Quj3kgQaqbCaLb3K3WmdmujwHvayk0SYfquwXqfakGdHKe2ethGnHGy4dvGBs5MLRFOqlx)qiu5cihFnedvaOaoeQKzOhc4MHdqjuX82z3vPsUvmubGc4akdUjVHzgyig3EV)SkVPmwzleJ3X7M57bzaHqO6tzfy0xFiiSHkWTLRFOaYszlidvh6S23I6qLyfwbGPqZkxarzfdvaOaoessytmDa2ecIHpubUjLBwU(HcTC9dHqLlGC81qmubGc4ahVeuKyig3EV)SkVPmwzleJ3X7M57bzaHqO6tzfy0xFiiSHkWTLRFOaYsrjidvh6S23I6qLyfwbGPqwhTJID30bHqO6tzfy0xFiiQdvGBs5MLRFOqscBIPdWMqqm8HwU(HQHJ254vVB6aoEjOiXqLmd9qAmAbCG5kHyC79(ZQ8MYyLTqmEhVBMVhKbeQaJwahYsjubUTC9dfqwkLdYq1HoR9TOoenncPbHmxL59kN1(qLyfwbGPqQSU(O6v4PSqiu9PScm6Rpee1HkWnPCZY1puijHnX0bytiig(qlx)qJG11NJNQWtzC8sqrIHkzg6H0y0c4aZvQza3mCakHkMBUkZ7voR9HyC79(ZQ8MYyLTqmEhVBMVhKbeQaJwahYsjubUTC9dfqaHOPriniuaja]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170613.213117, [[daK2saqicH2KqyuQsCkLu9kLuKzrrQQBPKIAxQIHHihJclti9mcbttvs5AkPW2uLKVHGgNqKoNQKQ1rrQyEcrDpLe7tjPdIaluj6HiPMifPkxuvQnsrkNKIyMkP0nvWovvlfP6POMkszRes7v6ViQbtvhw0Ij4XKAYk1LbBgH(mHA0k0PP0RrIzROBtYUH63qgUs44crSCIEovMUkxxO2of13Pi58ijRNIuP5tiA)cUgLw534uyc7US8pvqz2QOo4FpbfGVCA6e8olw8ec(0PlZlaTnNwt38SiC)rFv0YMEaXmEEDzz6Wesh0Fusges6vggprjTgggewMoKBQOzvqzjOsl2TMfIjs8jDAaVtSgE2XY8SiCzc0NfHDLw)gLw534uyc7USmRL2fx5djw8eE0i0CJmf2f8re8Ve8B09qCMkGSBePP8ibvAXUGF1GxiMiXN0Pb8oXA4zhlZZIWbFebVgHMBKPWpZ0Cswiw6UhjOsl2f8Rg8Kc(icErm4fIjs8XDiPIcala5t8IGF9YeiyN2JQYPtd4DI1qztWBRopKSmgHHYdOTOP8NkOC5FQGYe40aENynuMomH0b9hLKbHgKkthCOyPgCLwVYupcAkdiZGcWxfkpG2)ubL71F0sR8BCkmHDxwM1s7IRSig8NvtXIfh8IuKb)gDpeNPci7grAkpsqLwSl4J8kbVy9Umbc2P9OQmXzQaYUrKMsztWBRopKSmgHHYdOTOP8NkOC5FQGYM2mvqWZJinLY0HjKoO)OKmi0Guz6Gdfl1GR06vM6rqtzazgua(Qq5b0(NkOCV(fHsR8BCkmHDxwM1s7IRSkHP7Ki1Jowkb8f8RUsWhLuWhrWlbvAXUGpYRe8cXej(KonG3jwdp7yzEweo4Ji41i0CJmf(jDAaVtSgEKGkTyxWVMcEHyIeFsNgW7eRHNDSmplch8rELGFhlZZIWLjqWoThvLjotfq2nI0ukBcEB15HKLXimuEaTfnL)ubLl)tfu20MPccEEePPe8VySEz6Wesh0FusgeAqQmDWHILAWvA9kt9iOPmGmdkaFvO8aA)tfuUx)VwPv(nofMWUlltGGDApQkdtqb4lNKfMP7kBcEB15HKLXimuEaTfnL)ubLl)tfu(9eua(YzWVCMURmDycPd6pkjdcnivMo4qXsn4kTELPEe0ugqMbfGVkuEaT)Pck3R)1O0k)gNcty3LLzT0U4kletK4dOhrGJmIi5Beilwc5r2fJ3G0If)eVi4Ji4fXGxiMiXN0Pb8oXA4jErWhrWRsy6ojs9OJLsaFb)QRe8r6RktGGDApQkdP8gJK4Kcu2e82QZdjlJryO8aAlAk)Pckx(NkO87uEJrsCsbkthMq6G(JsYGqdsLPdouSudUsRxzQhbnLbKzqb4RcLhq7FQGY96)vLw534uyc7USmRL2fxzvct3jrQhDSuc4l4xDLG3WGWGxKIm4fXGpLNLyQVhNPG50IftwLW0DsK6bWPWe2bFebVkHP7Ki1Jowkb8f8RUsW)6rltGGDApQkdP8gj7grAkLnbVT68qYYyegkpG2IMYFQGYL)Pck)oL3yWZJinLY0HjKoO)OKmi0Guz6Gdfl1GR06vM6rqtzazgua(Qq5b0(NkOCV(jS0k)gNcty3LLzT0U4kxMab70Euv2DiPIcalazztWBRopKSmgHHYdOTOP8NkOC5FQGY8HKkkaSaKLPdtiDq)rjzqObPY0bhkwQbxP1Rm1JGMYaYmOa8vHYdO9pvq5E9hPLw534uyc7USmRL2fx5YeiyN2JQYtBKeB3KvPyvs(qhOkBcEB15HKLXimuEaTfnL)ubLl)tfuET2ij2Ud(HuSkdEAOduLPdtiDq)rjzqObPY0bhkwQbxP1Rm1JGMYaYmOa8vHYdO9pvq5E9)6Lw534uyc7USmRL2fxzHyIeFwGmfijJis(gbYQeMUtIupXlc(icEHyIeFChsQOaWcq(eVi4Ji4t9zndKbmOSGl4JCWlcLjqWoThvLNwXJh2IftwanVYMG3wDEizzmcdLhqBrt5pvq5Y)ubLxRv84HTyXb)s08kthMq6G(JsYGqdsLPdouSudUsRxzQhbnLbKzqb4RcLhq7FQGY963GuPv(nofMWUllZAPDXvEJUhIZubKDJinLhjOsl2f8Rg860DKpRcc(ic(xcEncn3itHjlHuFbVifzWletK4t60aENyn8eVi4xVmbc2P9OQ8mnNKfILURSj4TvNhswgJWq5b0w0u(tfuU8pvq51MMZGFzS0DLPdtiDq)rjzqObPY0bhkwQbxP1Rm1JGMYaYmOa8vHYdO9pvq5E9ByuALFJtHjS7YYSwAxCLFj4vjmDNePE0XsjGVGF1vc(OKc(icEHyIeFGjOa8LtYer6y3t8IGF9GpIG)LGxceLGBmfMqWVEzceSt7rvzIZubKDJinLYMG3wDEizzmcdLhqBrt5pvq5Y)ubLnTzQGGNhrAkb)lrxVmbsXUYxkfdhzlXvKarj4gtHjuMomH0b9hLKbHgKkthCOyPgCLwVYupcAkdiZGcWxfkpG2)ubL71Vr0sR8BCkmHDxwM1s7IRSkHP7Ki1Jowkb8f8RUsWByye8IuKbVig8P8Set994mfmNwSyYQeMUtIupaofMWo4Ji4vjmDNePE0XsjGVGF1vc(i9vLjqWoThvLHuEJKDJinLYMG3wDEizzmcdLhqBrt5pvq5Y)ubLFNYBm45rKMsW)IX6LPdtiDq)rjzqObPY0bhkwQbxP1Rm1JGMYaYmOa8vHYdO9pvq5E9BicLw534uyc7USmRL2fxzHyIeFKGdHtSgiFOdupsqLwSl4JCWBqk4fPid(xcEHyIeFKGdHtSgiFOdupsqLwSl4JCW)sWletK4t60aENyn8SJL5zr4GFnf8AeAUrMc)KonG3jwdpsqLwSl4xp4Ji41i0CJmf(jDAaVtSgEKGkTyxWh5G3ync(1ltGGDApQkFOduKvP7ajvLnbVT68qYYyegkpG2IMYFQGYL)PcktdDGk4hs3bsQkthMq6G(JsYGqdsLPdouSudUsRxzQhbnLbKzqb4RcLhq7FQGY96341kTYVXPWe2DzzwlTlUYP(SMbYaguwWf8Rg8gbFebFQpRzGmGbLfCb)QbVrzceSt7rv5zAojlaPQSj4TvNhswgJWq5b0w0u(tfuU8pvq51MMZGFjKQY0HjKoO)OKmi0Guz6Gdfl1GR06vM6rqtzazgua(Qq5b0(NkOCV(nwJsR8BCkmHDxwM1s7IRSqmrIplqMcKKrejFJazvct3jrQN4fbFebFQpRzGmGbLfCbFKdErOmbc2P9OQ80kE8WwSyYcO5v2e82QZdjlJryO8aAlAk)Pckx(NkO8ATIhpSflo4xIMxW)IX6LPdtiDq)rjzqObPY0bhkwQbxP1Rm1JGMYaYmOa8vHYdO9pvq5E9B8QsR8BCkmHDxwM1s7IRCQpRzGmGbLfCb)QbVrWhrWN6ZAgidyqzbxWVAWBuMab70EuvwpMwm5Pv84HTyXLnbVT68qYYyegkpG2IMYFQGYL)Pckt9yAXb)ATIhpSflUmDycPd6pkjdcnivMo4qXsn4kTELPEe0ugqMbfGVkuEaT)Pck3RFdclTYVXPWe2DzzceSt7rv5Pv84HTyXKfqZRSj4TvNhswgJWq5b0w0u(tfuU8pvq51AfpEylwCWVenVG)LORxMomH0b9hLKbHgKkthCOyPgCLwVYupcAkdiZGcWxfkpG2)ubL71VrKwALFJtHjS7YYSwAxCLLarj4gtHjuMab70EuvM4mvaz3istPm1JGMYaYmOa81LLhqBrt5pvq5YMG3wDEizzmcdL)PckBAZubbppI0uc(xeH1ltGuSRScz2IfVIHP)LsXWr2sCfjqucUXuycLPdtiDq)rjzqObPY0bhkwQbxP1R8aYSflUFJYdO9pvq5E9B86Lw534uyc7USmbc2P9OQmKYBKSBePPuM6rqtzazgua(6YYdOTOP8NkOCztWBRopKSmgHHY)ubLFNYBm45rKMsW)s01ltGuSRScz2IfVIrz6Wesh0FusgeAqQmDWHILAWvA9kpGmBXI73O8aA)tfuUx)rjvALFJtHjS7YYSwAxCLVukgUNT1Djwdb)Qb)RktGGDApQktCMkGSBePPuM6rqtzazgua(6YYdOTOP8NkOCztWBRopKSmgHHY)ubLnTzQGGNhrAkb)lV26Ljqk2vwHmBXIxXOmDycPd6pkjdcnivMo4qXsn4kTELhqMTyX9BuEaT)Pck3RxzwlTlUY9Ab]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170613.213117, [[d4ZSoaGEePsBcrSlq9AkQ9rLQzsLILPQA2OmFQu6MQc5BIOBlPdlStKSxLDRY(jfJsvWWOQghIkDEsPtdmysLHRQCqjYPKO6yi1XLOyHuWsvfTyewoLEiIuEkXJj55IAIisftLkzYGmDPUif6visvxg66I0gLO0FPkBMk2oIY0quX3vLYNjvnpejBteoeIQmAjmEvHkNuvYZOixtvOCpvPALQcvDoev1Vr1JEUMy8ccgcndtiDqNiL1ZWeQOIteJUrJoJmSIxhmn6kLv4bfNcN8ezyKXr97tN0NC8jF4FFYjPFYjIYc(6jtkPAa)YZ1OONRjgVGGHqZWerzbF9KMRxpdHvCodI)2LjbI3WoSOIE5cUYmSfRb4YUtK64ahzfEqXPqyOuB0a(rIIZzq83oywqw4rKAZnSfRb4YU7tc5rK64aNBUTAgXp0cN(nPebGbATtIScpO4u4Kxheqfn3o54ho5jYWiJJ63NobDsyFttOIkoPuwHhuCkC9O(NRjgVGGHqZWKhfpoqnT6kS6XopX0erzbF9eYRbkZGt)KseagO1oXHfv0lxWvMN86GaQO52jh)WjurfNuwwurn6KcUY8estRIHUcRESZJyYtKHrgh1VpDc6KW(MMif83Eehc4aqBEeRhLP5AIXliyi0mmruwWxpPgil3wEfwLAT41U)(VpjwSgGltQ3jsDCGJScpO4uimuQnAa)irX5mi(BhCKv4bfNcHTynaxM0tK64ahzfEqXPqyOuB0a(rQ3HsTrd43KseagO1oXHfv0lxWvMN86GaQO52jh)WjurfNuwwurn6KcUYSgDpqx(KNidJmoQFF6e0jH9nTEuKZCnX4femeAgMikl4RNqK64aJQcoM94oEDb6P3Ir7Ltpi0co9WPFKqEePooWrwHhuCkeo9JKAGSCB5vyvQ1Ix7(7KBcnp(jprggzCu)(0jOtc7BAYRdcOIMBNC8dNuIaWaT2jyy7IYKgMXjurfNymSDrzsdZ46r9yZ1eJxqWqOzyIOSGVEsnqwUT8kSk1AXRD)DY)NeYJi1XboYk8GItHWPFtEImmY4O(9PtqNe230Kxheqfn3o54hoPebGbATtWW2fE5cUY8eQOItmg2UqJoPGRmVEujMRjgVGGHqZWerzbF9KMRxpdHdBdCcv7feagO1oPebGbATtYn3wnJ4hAN8ezyKXr97tNGojSVPjsb)ThXHaoa0MhXeQOItKMBRMr8dTtEDqav0C7KJF46rLCUMy8ccgcndteLf81tM8ezyKXr97tNGojSVPjVoiGkAUDYXpCsjcad0ANGmSIxhmpcwK7jurfNyKHv86GPrNbwK71JICNRjgVGGHqZWerzbF9Kq1aYqp8WkaZU)UPjLiamqRDcduMuaKxn0xdVM3yDYRdcOIMBNC8dN8ezyKXr97tNGojSVPjurfN4gqzsbqA09OqFn0OZfVX66rr(Z1eJxqWqOzyIOSGVEcrQJd8h)n06XD86c0Rgil3wEfo9JeIuhh4CZTvZi(Hw40pscvdid9WdRamtkttEImmY4O(9PtqNe230Kxheqfn3o54hoPebGbATtya9f9bo9EeCwpHkQ4e3a0x0h40RrNboRxpkA)5AIXliyi0mmruwWxpbI3WoSOIE5cUYmSfRb4YURIC71GksYdkoNbXF78SyOA36wIuhh4iRWdkofcN(v(KNidJmoQFF6e0jH9nn51bburZTto(HtkrayGw7ewqw4rKAZ9eQOItCtqwOrNHuBUxpkA65AIXliyi0mmruwWxpPgil3wEfwLAT41U)(VpjePooWidR41bZZHRsZWPFKyrhlMlccgoPebGbATtCyrf9YfCL5jVoiGkAUDYXpCYtKHrgh1VpDc6KW(MMqfvCszzrf1Otk4kZA09WF5Rhf9)CnX4femeAgMikl4RNudKLBlVcRsTw8A3F)3NeIuhhyKHv86G55WvPz40pscvdid9G4nSdlQOxUGRmtQhcvdid9WdRamtQ3nrsOAazOhEyfGz36wtLp5jYWiJJ63NobDsyFttEDqav0C7eLwfdNqfvCszzrf1Otk4kZA0rAAvmCsjcad0AN4WIk6Ll4kZRhfTP5AIXliyi0mmruwWxpPgil3wEfwLAT41U)o5MyYtKHrgh1VpDc6KW(MM86GaQO52jh)WjLiamqRDcg2UWlxWvMNqfvCIXW2fA0jfCLzn6EGU81JIMCMRjgVGGHqZWerzbF9eIuhh4M3y1Rg5gTAHTynaxMu0(U1TpqK64a38gRE1i3OvlSfRb4YKIi1XboYk8GItHWqP2Ob8J0R4Cge)TdoYk8GItHWwSgGltIIZzq83o4iRWdkofcBXAaUmPOFSYN8ezyKXr97tNGojSVPjVoiGkAUDYXpCcvuXjU4nw1O7rrUrR2jLiamqRDsZBS6vJCJwTRhf9JnxtmEbbdHMHjIYc(6jePooWOQGJzpUJxxGE6Ty0E50dcTGtpC63KseagO1obdBxuM0Wmo51bburZTto(HtEImmY4O(9PtqNe230eQOItmg2UOmPHzuJUhOlF9OOtmxtmEbbdHMHjIYc(6jHQbKHE4HvaMDNEYtKHrgh1VpDc6KW(MM86GaQO52jh)WjLiamqRDclil8iWOoHkQ4e3eKfA0zaJ66rrNCUMy8ccgcndteLf81tisDCG)4VHwpUJxxGE1az52YRWPFKeQgqg6HhwbyMuMM8ezyKXr97tNGojSVPjVoiGkAUDYXpCsjcad0ANWa6l6dC69i4SEcvuXjUbOVOpWPxJodCwRr3d0LVEu0K7CnX4femeAgMikl4RNeQgqg6Hhwby2D6jprggzCu)(0jOtc7BAYRdcOIMBNC8dNuIaWaT2jQIaCEmG(I(aN(jurfNqAfb40OZna9f9bo9Rhfn5pxtmEbbdHMHjIYc(6jtEImmY4O(9PtqNe230Kxheqfn3o54hoHkQ4e3a0x0h40RrNboR1O7H)YNuIaWaT2jmG(I(aNEpcoRxpQF)5AIXliyi0mmruwWxpPYjdC6jXIowmxeemCYtKHrgh1VpDc6KW(MM86GaQO52jh)WjurfNuwwurn6KcUYSgDpyQ8jLiamqRDIdlQOxUGRmVEu)0Z1eJxqWqOzyYRdcOIMBNO0Qy4erzbF9Kq1aYqp8WkaZUttsOAazOheVHDyrf9YfCLzsfQgqg6HhwbyEcPPvXqxHvp25rmPebGbATtCyrf9YfCL5jsb)ThXHaoa0MNHjurfNuwwurn6KcUYSgDpqAAvmuJU)YN8ezyKXr97tNGojSVP1J6)FUMy8ccgcndtOIkoXyy7cn6KcUYSgDp8x(KNidJmoQFF6e0jH9nn51bburZTto(HtkrayGw7emSDHxUGRmpruwWxpPYjdC6xVEI8HkqWaKUrd43O(t8VEd]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170613.213117, [[daKEoaqiiPuBII0Oqv5uOQAvqsjVcskAxeAycCmuzzQONrbttOGRjuiBJI6BuvgNkPCoiPAEueDpvI2NkHdQcwib9qvs1evjrDrk0gPiCsHQvQscVuLezMcfDtij7eflvf6PitLQQ9k9xbnycCyLwmk9yknzQ0LbBMQ8zuLrtfNwvVgcZMu3wr7gQFtYWvPoUqjlNONRW0fDDHSDiX3vjPXdjfopeTEHc18fk1(HuxU6VKr8YQb3kSeZoHsKXyIwGrnmbCUA0cIBbVijYsKv(3zPshbnSdOmNbC(cIHaux8mig8f4ReDd2F1FmEZxHlZP5ZshS5RWJ6VmC1FjJ4LvdUvyjYk)7SeQD(wepMxPdSV(tKL807echoklIsXXUVDtLSewHHshbnSdOmNbCM58jgyOeZoHsMqVtaTaYrzrGwaFb83SmN1FjJ4LvdUvyjYk)7SeBKNNiyDuWiu5fMoqipjSz4ic7cYhZtm6205c6rkvtrBKuc48IlVM5shbnSdOmNbCM58jgyOuCS7B3ujlHvyOeZoHsgxz6eROfbu6a7R)ezjyLPtSIweqZYyO(lzeVSAWTclrw5FNLyJ88eFl4fjrkgDB6Cb9iLQPOnskbCEXLxZCPdSV(tKL8KQrgoCuweLIJDF7MkzjScdLocAyhqzod4mZ5tmWqjMDcLmHuns0cihLfrZYed1FjJ4LvdUvyjYk)7S0Cb9iLQPOnskbCEXLO(j6RO0rqd7akZzaNzoFIbgkfh7(2nvYsyfgkXStOKXvMoOfqoklIshyF9NilbRmDchoklIMLjgv)LmIxwn4wHLy2juIsLCIaGBqw6a7R)ezPrQKteaCdYsXXUVDtLSewHHsKv(3zPuXJNgexz(ERndx2x)jst5BT5Jcecyy(W4cUyh7bK5J5nexE8KWy8OaHJujNia4gK8x6iOHDaL5mGZmNpXadnlJ56VKr8YQb3kSezL)DwQ0rqd7akZzaNzoFIbgkfh7(2nvYsyfgkXStOKrnmbCUA0ceQ3rw6a7R)ezjqdtaNRoKvVJSzz8v)LmIxwn4wHLiR8VZsZf0JuQMI2iPeWPjV0N5shyF9Nil9wWlsISuCS7B3ujlHvyO0rqd7akZzaNzoFIbgkXStOuCl4fjr2SmxR(lzeVSAWTclrw5FNLwB(OaHagMpmU4sdLoW(6prws)Xk6DdNlV5gMQeMLIJDF7MkzjScdLy2jukMFSIEx0cq1YBUOf4xLWS0rqd7akZzaNzoFIbgAwguV(lzeVSAWTclrw5FNLyJ88eVvxfKHkVW0bcNlOhPunfJUnLnYZtCKk5eba3Gum6201MpkqiGH5ddtAO0b2x)jYs6NNtIFmVqwLolfh7(2nvYsyfgkDe0WoGYCgWzMZNyGHsm7ekfZNNtIFmp0ceQ0jAb8rxj(BwgUG6VKr8YQb3kSezL)DwYvLIE6DcHdhLfHOeM7Jhxy3rgM)eqFfLocAyhqzod4mZ5tmWqP4y33UPswcRWqjMDcLI5IYIwGWi5ilDG91FISKErzdzJKJSzz44Q)sgXlRgCRWsKv(3zj2ippX3cErsKIr3MY3Cb9iLQPOnskbCEXLNbXo2SrEEIVf8IKifLWCF8WK8XZ6IAXg55j(wWlsIuCKRfbQjh)8x6a7R)ezjpPAKHdhLfrP4y33UPswcRWqPJGg2buMZaoZC(edmuIzNqjtivJeTaYrzrGwaFC83SmCN1FjJ4LvdUvyjuTOg)mA6FL8GCuYqjYk)7S0Cb9iLQPOnskbCEXLNbMYg55jcAyc4C1HEkB0qm62uj4jHHZYQb0xrPdSV(tKL807echoklIsXXUVDtLSewHHsm7ekzc9ob0cihLfrPRJ0Qb)RKhKJYw6iOHDaL5mGZmNpXadLih1vrLY99EqokBZYWzO(lzeVSAWTclrw5FNLMlOhPunfTrsjGZlU8mWu2ipprqdtaNRo0tzJgIr3MYhFRnFuGqadZhgxEA6AZhfi0vLIE6DcHdhLfHjp5p2XMV1MpkqiGH5dJlU0GPRnFuGqxvk6P3jeoCuweM0a)8x6a7R)ezjp9oHWHJYIOuCS7B3ujlzrA1qjMDcLmHENaAbKJYIaTa(44V0rqd7akZzaNzoFIbgAwgUyO(lzeVSAWTclrw5FNLyJ88eFl4fjrkgDx6a7R)ezjpPAKHdhLfrP4y33UPswcRWqjuPq5X8kdxjMDcLmHuns0cihLfbAb8DYFPJGg2buMZaoZC(edmuICuxfvk337b5OclDDhWIavkuGjGZkSzz4Ir1FjJ4LvdUvyjYk)7S0Cb9iLQPOnskbCEXLxZCPdSV(tKLGvMoHdhLfrP4y33UPswcRWqjMDcLmUY0bTaYrzrGwaFC8x6iOHDaL5mGZmNpXadnldN56VKr8YQb3kSezL)DwInYZtucdfEXwimvjmfLWCF8WKCbLocAyhqzod4mZ5tmWqP4y33UPswcRWqPdSV(tKLsvcZW5osqISeZoHs(vjmrlav7ibjYMLHZx9xYiEz1GBfwISY)olXg55jcwhfmcvEHPdeYtcBgoIWUG8X8eJUlDe0WoGYCgWzMZNyGHsXXUVDtLSewHHshyF9NilbRmDIv0IakXStOKXvMoXkAraOfWhh)nld31Q)sgXlRgCRWsm7ekfZNNtIFmp0ceQ0zPJGg2buMZaoZC(edmuko29TBQKLWkmuISY)olXg55jERUkidvEHPdeoxqpsPAkgDB6AZhfieWW8HHjnu6a7R)ezj9ZZjXpMxiRsNnldhQx)LmIxwn4wHLiR8VZsRnFuGqadZhgxWv6iOHDaL5mGZmNpXadLIJDF7MkzjScdLoW(6prwY6Spou)8Cs8J5vIzNqPR7SpgTGy(8Cs8J51SmNb1FjJ4LvdUvyjYk)7SuPdSV(tKL0ppNe)yEHSkDwko29TBQKLWkmuIzNqPy(8Cs8J5HwGqLorlGpo(lDqYBuQ0rqd7akZzaNzoFIbgkroQRIkL779GCu2sx3bSiqLcfyc4SSnlZjx9xYiEz1GBfwISY)olnvO8yEMkbpjmCwwnu6iOHDaL5mGZmNpXadLIJDF7MkzjScdLy2juYe6DcOfqoklc0c47K)shyF9Nil5P3jeoCuwenlZ5z9xYiEz1GBfwISY)olnvO8yEMU28rbcDvPONENq4WrzryY1MpkqiGH5dJshbnSdOmNbCM58jgyOuCS7B3ujlzrA1qPdSV(tKL807echoklIsm7ekzc9ob0cihLfbAb8DYpAbxhPvdnlZPH6VKr8YQb3kSezL)DwAQq5X8kDe0WoGYCgWzMZNyGHsXXUVDtLSewHHshyF9NilbRmDchoklIsm7ekzCLPdAbKJYIaTa(o5VzZsxzWBJ0zf2Sf]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170613.213117, [[d0dsoaGEqI0MaP2ffTnQk7tLWmvjA2iMpQk5MII8yk9nQQoSu7eL2RYUb2VQQrrsmmQYVj1LHopQYGbvdhuoOOQtrs6yOY5qvPwij1sfvwmswUipevvEkXYuvEUQmrrHYuPIMmsnDHlsbNwYZOqxheBeKWNPsBwLA7IshcKi(UOGPHQIMhiPxtf(lkgnjgVOq1jvjnouv4AGe19qvvRuuihxuu3wfpU5CIbqtrq6PEIytfSyYKmgE3qiXupjhsW(HJ9ZJZVhF6X3MFE8PFp)teyOTAsbL2rPbJ9Z33K82O0G3CowU5CIbqtrq6PEIytfSycusuwhfWDsEQIubVj3K(GmpfT1XKRa6Y2HonbOb4KCib7ho2ppoFC(n9moHTp4eOG0h8hUOOTo(HRINQlg73CoXaOPii9uprSPcwmHcY9TjAv04JrFZekiJBc7G5bbqJPc4Acbg0NgjViPpMwiPecIl4pF4BsoKG9dh7NhNpo)MEgNCfqx2o0PjanaNW2hCIHofkzgs7aNKNQivWBc2PqjZqAh4IXACoNya0ueKEQNi2ublMCAK8IK(yAHKsiiUG)893FgnjhsW(HJ9ZJZhNFtpJtUcOlBh60eGgGty7doXqNcLF4II26ysEQIubVjyNcfMNI26yXy5Z5CIbqtrq6PEcBFWjsOthhicdttYtvKk4n5f60XbIWW0KRa6Y2HonbOb4eXMkyXKq76sqZof1DBdMMQivWdAvABuzrgeGNcFxWXx81dJOaUpZ21nHVxLfzEHoDCGimmP6KCib7ho2ppoFC(n9mUySq55CIbqtrq6PEIytfSyYKCib7ho2ppoFC(n9mo5kGUSDOttaAaoHTp4ede8GGOj)Wvt6xmjpvrQG3eKGheenHHI0VyXy9nNtmaAkcsp1teBQGftABuzrgeGNcFxWFJtYtvKk4nHuzgsrZCA3tZe6aptUcOlBh60eGgGty7do5YkZqk6F4zQDp9pCN6aptYHeSF4y)848X530Z4IX6FoNya0ueKEQNi2ublMqRdZBsFqMNI26WmHNUaVlS9lyI6G)z0KCib7ho2ppoFC(n9mo5kGUSDOttaAaoHTp4Kl7S9pC1qsVysEQIubVjKoBZqbj9IfJLpMZjganfbPN6jzQZ41bYXzNCX4nX4eXMkyXKtJKxK0htlKucbXf8)ZdAki33MibpiiAcZT2c5zcbg0j8oHpLMIG)z0K8ufPcEtUj9bzEkARJjxb0LTdDAcqdWjS9bNafK(G)WffT1Xe(XZsqNDYfJ3OMKdjy)WX(5X5JZVPNXjIIodzstx3fMEJAXy575CIbqtrq6PEIytfSyYPrYls6JPfskHG4c()5bnfK7BtKGheenH5wBH8mHadAvuPTrLfzqaEk8X)pOBBuzrgADyEt6dY8u0whq9tv(IVuPTrLfzqaEk8Db)ncDBJklYqRdZBsFqMNI26aQgvv1j5Pksf8MCt6dY8u0whtUcOlBh60elplbNW2hCcuq6d(dxu0wh)WvHt1j5qc2pCSFEC(48B6zCXy58MZjganfbPN6jInvWIjNgjViPpMwiPecIl4pF4BsEQIubVjyNcfMNI26yYvaDz7qNMa0aCcBFWjg6uO8dxu0wh)WvHt1j5qc2pCSFEC(48B6zCXy54MZjganfbPN6jInvWIjuqUVnt4tdAGfzcDGhZeE6c8GkN3KCib7ho2ppoFC(n9mo5kGUSDOttaAaojpvrQG3Kqh4H50Vat8MW2hCItDGNF4zQFbM4TySCFZ5edGMIG0t9eXMkyXeki33MOvrJpg9ntOGmUjSdMheanMkGRjeytYHeSF4y)848X530Z4KRa6Y2HonbOb4K8ufPcEtWofkzgs7aNW2hCIHofkzgs7a)HRcNQlglNX5CIbqtrq6PEcBFWjxwUkbOaU)WvRjXKCib7ho2ppoFC(n9mo5kGUSDOttaAaorSPcwmHcY9TjmDgWeJ(MjuqMtJKxK0htiWGUTrLfzqaEk8bvJqtJuqUVnjLRsakGltstBsRZaysEQIubVjKYvjafWLHstIfJLJpNZjganfbPN6jInvWIjuqUVnHPZaMy03mHcYCAK8IK(ycbg0TnQSidcWtHpOAe62gvwKHwhM3K(GmpfT1bu)MKdjy)WX(5X5JZVPNXjxb0LTdDAILNLGty7do5YYvjafW9hUAnj(HRc)4zjOQtYtvKk4nHuUkbOaUmuAsSySCq55CIbqtrq6PEIytfSysBJklYGa8u47coOPrki33MKYvjafWLjPPnP1za8NrtYHeSF4y)848X530Z4KRa6Y2HonbOb4K8ufPcEtSkDbyiLRsakG7e2(Gt4NsxGF4xwUkbOaUlglNV5CIbqtrq6PEIytfSysBJklYGa8u47coOPGCFBskxLauaxMKM2ecmOBBuzrgADyskxLauaxMKMgQTnQSidcWtHVj5Pksf8Myv6cWqkxLaua3jxb0LTdDAILNLGtYHeSF4y)848X530Z4e2(Gt4NsxGF4xwUkbOaU)WvHF8Seu1fJLZ)CoXaOPii9uprSPcwmHgPGCFBskxLauaxMKM2KwNbWK8ufPcEtiLRsakGldLMetUcOlBh60eGgGty7do5YYvjafW9hUAnj(HRcNQtYNCFtMKdjy)WX(5X5JZVPNXjIIodzstx3fMEJAc)uqRJmPZIheeJAXy54J5CIbqtrq6PEIytfSysBJklYGa8u47coOBBuzrgADyskxLauaxMKMgQTnQSidcWtHVj5qc2pCSFEC(48B6zCYvaDz7qNMy5zj4K8ufPcEtiLRsakGldLMety7do5YYvjafW9hUAnj(HRcNQ)W5hplbxmwo(EoNya0ueKEQNi2ublMmjhsW(HJ9ZJZhNFtpJtUcOlBh60eGgGtYtvKk4nHuUkbOaUmuAsmHTp4KllxLaua3F4Q1K4hUkFQUySFEZ5edGMIG0t9eXMkyXKJoBbCHoH3j8P0ueCsoKG9dh7NhNpo)MEgNCfqx2o0PjanaNW2hCcuq6d(dxu0wh)Wv5t1j5Pksf8MCt6dY8u0whlg7h3CoXaOPii9uprSPcwm5OZwaxOBBuzrgADyEt6dY8u0whqTTrLfzqaEk8njhsW(HJ9ZJZhNFtpJtUcOlBh60elplbNKNQivWBYnPpiZtrBDmHTp4eOG0h8hUOOTo(HRYNQ)W5hplbxm2VV5CIbqtrq6PEIytfSyYrNTaUtYHeSF4y)848X530Z4KRa6Y2HonbOb4K8ufPcEtWofkmpfT1Xe2(Gtm0Pq5hUOOTo(HRYNQlwmHTp4eXWL)WnqWdcIM8d)YCl2a]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170613.213117, [[d0t0haGEcvvBIqfTlc2Mk0(urPzkGMTsZNq5McWJPQVrQ6WI2PQAVs7MY(vL(jjQAyKYVr1ZvPHsOkgmenCiCqs4ueQKJruNJqvAHKulfLAXez5u51KOYtrwgkADKeMijctLuzYcnDfxuqNgQNPICDuyJKO4ZeYMvbBNerFNK0xjuHPrIsZJeP(lk5YGrts0HurXjfOXrIKRPIQZRkwjHk1OiuvUnKUYvxPqlLwiw1LieGhNlw8NdMB9Z8iZs)efkrHb(ImCbuWMCFrQeWHKXoLydlKxOFMAY61uw5ZfK1ox7C9LiVdJykvsHFWC7wD9lxDLcTuAHyvxI8omIP0WfjAbbSnGZXaXClPqcV45PKQylY6QsiDLcArSphURKXnO0prHsIdSfFrsQesxj2Wc5f6NPMSEzTo9ZS6kfAP0cXQU0prHsIh(G5wjY7WiMsdxKOfeqWhm3UItX3zgUirli458nYv1UIjMNZ3ixvt4a2bSGfqbBYvWbOj2UNLPsPjUkXgwiVq)m1KpkRxq7uPGwe7ZH7kzCdkPqcV45Pec(G5wPa4XFIcLq44l3ebrwi4QcUo9FQ6kfAP0cXQUe5Dyetjjghoim8bqzHM3bCpcoanX2vPzwsHeEXZtPHpakl08oG7PuqlI95WDLmUbLydlKxOFMAYhL1lODQ0prHs64dG(ImG8oG7Pt)kB1vk0sPfIvDjY7WiMsdxKOfe8C(g5QA3sSHfYl0ptn5JY6f0ovkOfX(C4Usg3GskKWlEEkDa7awWcOGn5w6NOqjLb7GxKHlGc2KBN(pV6kfAP0cXQUe5DyetPHls0ccEoFJCvTBj2Wc5f6NPM8rz9cANkf0IyFoCxjJBqjfs4fppLUd3HYcwafSj3s)efkrd3H(ImCbuWMC70)XQRuOLsleR6sK3HrmLgUirli458nYv1ULuiHx88ucwafSjxwO5Da3tPGwe7ZH7kzCdk9tuOu4cOGn5(ImG8oG7PeByH8c9Zut(OSEbTtD6xF1vk0sPfIvDjY7WiMsNzYfSriVEWIP5bbWsPfIIjMeJdheYRhSyAEqGbcXeZZ5BKRQjKxpyX08GGdqtSDp75ALydlKxOFMAYhL1lODQuqlI95WDLmUbLuiHx88usA58iRdmCpL(jkus9Y5XxKkdd3tN(vQQRuOLsleR6sK3HrmLoZKlyJqE9GftZdcGLsleftmjghoiKxpyX08GadeLydlKxOFMAYhL1lODQuqlI95WDLmUbLuiHx88uscCxWPCytuPFIcLudUl4uoSjQt)I3QRuOLsleR6sK3HrmLs)GvsGfyakgUNLzPFIcLyZWuXlsfkFyjfs4fppLCmmwPFWCJ1IVtPGwe7ZH7kzCdkXgwiVq)m1KpkRxq7uPa4XFIcLOWaFrgUakytUVivO8HD6xwR6kfAP0cXQU0prHsSzyQ4fPIRhSyAEOe5DyetPjxWgH86blMMhealLwikMylOKWQ0YYALydlKxOFMAYhL1lODQuqlI95WDLmUbLuiHx88uYXWyL(bZnwl(oLcGh)jkuIcd8fz4cOGn5(IuX1dwmnp0PFz5QRuOLsleR6s)efkXMHPIxKb9WbgUNsK3HrmLMCbBeWE4ad3JayP0cXxXDj2Wc5f6NPM8rz9cANkf0IyFoCxjJBqjfs4fppLCmmwPFWCJ1IVtPa4XFIcLOWaFrgUakytUVid6HdmCpD6xMz1vk0sPfIvDPFIcLyZWuXlYaXIu5yyt0ls28yjY7WiMstUGnclwKkhdBIy54rbWsPfILydlKxOFMAYhL1lODQuqlI95WDLmUbLuiHx88uYXWyL(bZnwl(oLcGh)jkuIcd8fz4cOGn5(Imq2D6usjGdjJDQ6oTa]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170613.213117, [[dSZ(iaGEskPnjPQDjjBtkSpsk1mvuz2O6MqXTP4BKs7uv2Ry3QSFsv)KKsmmk14GsjhMQhlXGjfdxk6GKKtrsfhJiNJKkTquQLQOSyOA5QQhkL8uKLruEokMiuk1uLuMSctxPlsuDEkXLbxNuzJqP40q2mL02Lkptk13LuPPbLQ5rsXRrjFwQA0K44sQ4Kqj)vrUgjv5EkQYHuuvJIKQ63eosPwi5NJZHryhcBdwDD8nSd9CdeIKpNEnY5GbU1561OsTip0mGdodKNmBjT2y3wDRKzJDT2AdrnHcY5i1QViXLNSgYcPQSiXXKA5jLAHKFoohgHDONBGq0k(gwa0e(HMbCWzG8Kzl1qsBLD7qQWrC0AjeZk(gwa0e(HW6gOIVIFOtCqOwkqHfgrhyGBdEimIXZnqOS5jl1cj)CComc7qu5JAUHwrFphQkcbFiQ7Xe65giKkMcCd)kqOzahCgipz2snK0wz3oKkCehTwc5mf4g(vGqyDduXxXp0joiulfOWcJOdmWTbpegX45giu28ANAHKFoohgHDONBGqZHQJo0qVgmEVX1RPMybtOzahCgipz2snK0wz3oKkCehTwcXr1rhAmz8EJpTIfmHW6gOIVIFOtCqOwkqHfgrhyGBdEimIXZnqOS5H9ulK8ZX5WiSdrLpQ5gY4aNz)ctvr3)d3Q2ZtMD9ZFDoCBfh1RSh66N(IrfCoohg1)bRFGrXX5qiv4ioATeYk3nWeJIOWkulfOWcJOdmWTbp0ZnqiSH7gqVgsruyfAgWbNbYtMTudjTv2TdrkI6IrmqwrWNj4HW6gOIVIFOtCqimIXZnqOS5PEPwi5NJZHryhIkFuZnKxwuhmbhyqaJAWE9EzrDW0qSvw5UbMyuefwQXllQdMGdmiGjKkCehTwczL7gyIrruyfcRBGk(k(HkwkCi0mGdodKNmBPgsARSBh65gie2WDdOxdPikS0RPLLchYMxJulK8ZX5WiSd9CdesU)xL6OZzbHMbCWzG8Kzl1qsBLD7qQWrC0Aje4)vPo6CwqiSUbQ4R4h6eheQLcuyHr0bg42GhcJy8CdekBEAtTqYphNdJWoev(OMBOHyRSYDdmXOikSQ(GXrhJAxCMDArgOECDwTwX9oFIr3VhQ01S(5VohUTIJ6v2dD9tFXOcohNdJ69YI6Gj4adcyud2d9CdeAoVZ1RHTUpZgAgWbNbYtMTudjTv2TdPchXrRLqCVZNW19z2qyDduXxXp0joiulfOWcJOdmWTbpegX45giu28WwPwi5NJZHryhIkFuZn08xNd3wXr9k7HU(PVyubNJZHr9EzrDWeCGbbmQr9c9CdesohmWToxVg2CNzdnd4GZa5jZwQHK2k72HuHJ4O1siGdg4wNpHZDMnew3av8v8dDIdc1sbkSWi6adCBWdHrmEUbcLnp1n1cj)CComc7qp3aHMZ7C9AydUj0mGdodKNmBPgsARSBhsfoIJwlH4ENpHdUjew3av8v8dDIdc1sbkSWi6adCBWdHrmEUbcLnpj7ulK8ZX5WiSd9CdeQLIJo9AMd1RSh66drLpQ5gAa46SATIJ6v2dD9tFXOAiQ7fAgWbNbYtMTudjTv2TdPchXrRLqffhDtCuVYEORpew3av8v8dDIdc1sbkSWi6adCBWdHrmEUbcLnpjPulK8ZX5WiSdrLpQ5gYllQdMgITIJ6v2dD9tFXqnEzrDWeCGbbmHMbCWzG8Kzl1qsBLD7qyDduXxXpuXsHdHuHJ4O1sOIIJUjoQxzp01h65giulfhD61mhQxzp01RxtllfoKnpjzPwi5NJZHryhIkFuZneUoRwR4ENpXO73dv6AgsfoIJwlH4ENpHR7ZSHW6gOIVIFOtCqimIo01hsk0ZnqO58oxVg26(mREnQVK6es1VNjKr0HU(5jfAgWbNbYtMTudjTv2TdrkI6IrmqwrWNjSd1sbkSWi6adCByhcJy8CdekBEsTtTqYphNdJWoev(OMBOpy9dmkoohcPchXrRLqw5UbMyuefwHW6gOIVIFOtCqimIo01hsk0ZnqiSH7gqVgsruyPxJ6lPoHu97zczeDORFEsHMbCWzG8Kzl1qsBLD7qTuGclmIoWa3g2HWigp3aHYMnev(OMBOSja]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170613.213117, [[detncaGEQQ0UqfBtKmtirZMk3uf(guzNsAVKDJy)qkddf)wvdLQQgmuQHlQoik5yuLZrvPwik1sfHfJulxIfjs9uWYeLNJQMivvmvOQjRstx4IiXLvUovf2mvLSDivpgIPbjCyP(mQ05vrJgk8mr0jHKUnLonf3JQIEiuYFHIEnsA5j8cOqAA3UITaaPyYdbc8Z8v7dxi2csm3A(PAgJhoguW4BozmOahdobq(qmTZ43ompr1SuzcyHeMNWl8Q6j8cOqAA3UITaaPyYdbXZLRBCY)W8eEbSOnotCki)dZteGk5Aq64lcipzcQTDc8)dZteWQWLxaPTZNPVRVUtm5wAKLwqI5wZpvZy8s5HJdtsbyHXqOE8Op7iHOfC83ABNG031x3jMClnYsRq1mHxafst72vSfuB7eG)Jzrd7JMpw5uqI5wZpvZy8s5HJdtsbSOnotCki(ywmTnFSYPaujxdshFra5jtawymeQhp6ZosiAbh)T22jqHQjfEbuinTBxXwqTTtaeFXsDlFfbjMBn)unJXlLhoomjfWI24mXPa(4lwQB5RiavY1G0XxeqEYeGfgdH6XJ(SJeIwWXFRTDcuOqqTTtaqbLOHnf3SJeTdnS9VmK3s3Hcj]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170613.213117, [[d8tQiaqyQwpK0lPqSlsqTniHFJ0mfsEMqy2Q05fQBscCAcFdvLEUi7uu7vA3qTFf6NqQHruJJefVwi1qPObRidhLoOI6OKG4ycCosuAHkyPKqlwqlNupKiEk4XqSovOMiQkmvuzYePPRQlsPUkfsxwPRJOnQc2kQkQntjBNc(OkKpJQmnkuFxfnssuTmsQrJIXJQQtssUfKORjeDpsq62iSwuvKJtICdkxbeN9fu8bk(Hp(UfqBuUOuLTl8UM3(MgmBybTJ5TsywKO7qbLixYD(k4Hjw8xaPqmAlR0(sC2xqXPMLlWpAlR0(sC2xqXPMLlWQfeUowfcfdcu3MnwUaHapB3CefuICjxPsC2xqXPouigTLvAFoxZB)uZYfuiKl5MkxZbLRGn2dVR0ouyg5fu84uuI0xaeesgNSXmogzjw8F84eRErOeH(xi7eBbqqizCYgZ4yKLyX)XJtS6fHse6Fbf376PTz1YbOiqwoIcaIwW(fEbXQqL73S6YvWg7H3vAhkmJ8ckECkkr6laccjJt2yghJSel(pECs6A5K3Vq2j2cGGqY4KnMXXilXI)JhNKUwo59lO4ExpTnRwoafbYYr0VFHed9eofpcZSDhkWpAlR0(CUM3(PMLlq48dCnhuWj1UkSfLlMDlesAzvGF0wwP9nYqQ5Gc83mkrHchihrKbrIc1rUOuwoYcjg6jNR5TFQdfIoCgJWq1f4qBQOQJuoxbbwQaXFQEgJWq1fuu1rkNRaIZ(ckEgJWq1fgqZXHwbfKqzJhN4OfSXmogzjw8pobcmV7IsoxZB)cjg6jW1HckrUKlFi0lYlO4ckQ6iLZvatsOcHItnBCHy0wwP9vHLkq8NQtnlxiXqpL4SVGItDOa)OTSs7ptQ9MLliDTCY7pBgvbqqizCYgZ4yKLyX)XJtsxlN8(f8llJpFp94KPb7Mdkq48pt(0MLleEfOI6rx65892Wc(LLXbg6PPb7Mdk4xwgxcLi0Ftd2nhuGqGNjFAZYf8llJdm0ttdMnhuWVNECY0GzhkyqKeHIR4J5Iz3cHfqC2xqXZxbpCbj2zoBflivKyVEmxm7wWleD4bk(Hp(UfqBuUOuLTlODmVLlMDl4HIR4Jl4KAxbc82Hcwu8xywl874u21A6zHOdpqXpiqDBoqDH3182FgJWq1fgqZXHwbkQ6iLZvWVSmoNR5TVPbZMdkiqOy(eLs0CqKf07TGe7mNTIfsS79E46jMgwWVSmoNR5TVPb7MdkKyONWP4ryMjFAhkOe5sUsvHLkq8NQtDOGsKl5kvfcfdcu3MnwUq4vGkQhDPNnSW7AE7FGIF4JVBb0gLlkvz7ckW5xqqsmoXji2MJqUaIZ(ck(af)Ga1T5a1faeTG9luWVSm(890JtMgmBoOGI7D902SA5a(kBSSYQWQLnMVY8TaRwq464du8dcu3MduxGvViuIq)NnJQaiiKmozJzCmYsS4)4Xjw9Iqjc9VqIHEAAWSdfiC(NTBwUaNFx8poDKMsY2SCH318230GDdlyQfeUoECsIZ(ckUqs7VGwiXqpnYghkWsfyEPouGF0wwP9vHLkq8NQtnlxGpwlN8(DOq2j2c2yghJSel(hNm1ccxhxWVSmUekrO)MgmBoOW7AE7FGI)cMCJtGJtJtzxRPNfsm0tvyPce)P6uhkOePajA(SibF8Dl4f87PhNmny3Hcjg65SDhkKyONMgS7qbekrO)MgmBybNu7CXSBHqslRcjg65m5t7qbtTGW1XJtsC2xqXJtZKAVa8unrOwG5T6cecmW1SCH3182)af)Ga1T5a1fIo8af)fm5gNahNgNYUwtplG4SVGIpqXFbtUXjWXPXPSR10ZcoP2b29EvXhnRwoqzmoYc2yp8Us7qHKGG9UZOTBoIcXOTSs7ptQ9MLlKy379W1tmsOxQUCf8Mdke2CqbEnhuq3Cq)ca7Ii8Rav)fuCZQrrefqOeH(BAWUHfIrBzL23idPMrP6cjg65mP2vHTODOGsKcKOHp(Uf8ccekgyDebMxZrwWj1(mgHHQlmGMJdTcIY(axbLixYv6bk(bbQBZbQle3dOuzKvw1glJIGa(gHSA18vUwO04ilOe5sUsnYqQdfsm0t4u8imZOT7qbNu7gfl(cSxpE19Bba]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170613.213117, [[d8ZBiaWyaRhiEjju7svr9AvL63intjW0Kkz2k68sv3ei1Pj8nsjDyQ2Pu2Ry3G2Vc(jqnms14iHWLvAOuQbRqdhrhuIokjKCmvPZPQqluv1sjblMOwofpKiEk0YKkEUKMOQImvumzI00v5IK0vjLYZqfDDuAJsOTscP2mLSDsXhLk12iL4ZOsFxvmssPADQkz0OQXJkCss0TuvGRbKCpsi62iSwvf0XLGoVHjiGtEckSifE41p3GG1gtbkBQbbCYtqHfPWdfGSP92jOXHCxj8lW35pO8uaciDpPproypylR6EsCYtqH100dYbylR6EsCYtqH100dsAeeUPxjafIcq206spiHawQMgNblKDzxPsCYtqH18hShSLvDpg3WDVAA6bvuSl7wdtAVHjOk0LNR08hSe4eu4WybI6fefesggvH8oeyjw491WiPzbOeY(fS5eBquqizyufY7qGLyH3xdJKMfGsi7xqf2561nTo6VGsxlFUtN3GiGrqEbpbXQi1ZLwNWeuf6YZvA(dwcCckCySar9cIccjdJQqEhcSel8(Ayu6A5SZlyZj2GOGqYWOkK3HalXcVVggLUwo78cQWoxVUP1r)fu6A5ZD68MlxWkp9bFehaFPAKdw5PpLShnYbR80h8rCa8LShn)bp3WDVsiap1e8hmddyqRGYU1otW(u8d0cO0)4R(h5uRCYPExkco1J1h0fOcArHxWsJWNdJn3yOpbR80hg3WDVA(d(TCjeGNAcYa2wbLDRDMGcOubGFutjeGNAcQGYU1otqaN8euyjeGNAc(dMHbmOdIKlGWNcq8tqHP1rlCgSYtFqM8hSq2LD)KWSaNGcdQGYU1otqilHsakSMwxbRK7CwC6vEj0j1eMGEAVbLt7ni30EdAs7nxWkp9rItEckSM)GCa2YQUxjRXttpO01YzNxPDbbrbHKHrviVdbwIfEFnmkDTC25fKW5OK9OPPhuEkabKUN0NY5mYb9jjVJ80hBnQP9g0NK8UekHSF2Aut7niHawYE004mOpF8(QTg78huJOkKftX1Z0tUbLdc4KNGclNcUWGsuBmQkeuQOso9EMEYniqWpTwo78YFqJd5Um9KBqxwmfxFqN14Gwa38h0NK8E58X7R2Aut7n43YfPWdfGSP92jiaLq2pBnQroOpj5Dg3WDpBn2P9guaqHiPdiGCtdubn7mOe1gJQcbRK7CwC6v(ih0NK8oJB4UNTg10EdYbylR6Ek(VMMEWczx2vQsOubGFutn)bDwJxcb4PMG)Gzyad6culYeKdWww19yCd39QPPh8Cd39ksHhE9ZniyTXuGYMAqq7CiiyjggzeeBACQhSq2LDLQeGcrbiBADPhebmcYlyva5o3G(KK3lNpEF1wJDAVbp3WDpBn2roiPrq4M(Iu4Hcq20E7eK0Saucz)kTliikiKmmQc5DiWsSW7RHrsZcqjK9lOTrq4M(Hrjo5jOWGvJFcAqcNJs100dY4ZfEdJDBOSKPPh8Cd39S1Og5GkSZ1RBAD0F1QEx6F8ZD07sR6AnyLN(O4TxwaLkGCR5piHZbYKMEWMtSbvH8oeyjw4nmwcwn43YfPWlOnZWi6W6WyZng6tWczfaFROfv86NBq5GoRXz6j3GYSwwbR80hLqPca)OMA(d6tsExcLq2pBn2P9g0NpEF1wJA(dw5PpLQroyLN(yRrn)bbOeY(zRXoYb)wUifE41p3GG1gtbkBQbp3WDVIu4f0MzyeDyDyS5gd9jypylR6Ek(VMMEqcbezsJZGNB4Uxrk8qbiBAVDcABeeUPFyuItEckCySK14bXJAiKnci31eeWjpbfwKcVG2mdJOdRdJn3yOpbDwJJK7CQ8tPPhuf6YZvAKdwfeKZTeSAACgKdWww19ucLka8JAQPPhShSLvDVswJNMEWEWww19ucLka8JAQPPhSYtFS1yN)GsOK9dJm0GQqEhcSel8gglbRgSq2LDlNcUqIfEbbcw5PpLSgxj0Ig5GoRXvcTOm9KBqzwlRG(KK3rE6JTg70Edwi7YUslsHhkazt7TtqostpyHSl7kvX)18huaqHFiLsK2lOc6SgxBqXfKC69Rjxca]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170613.213117, [[d8JyiaWyKA9QQ8skuTlke51Qk1VHAMQQAAQkA2KCEPQBcr50O6BquDyQ2PK2Ry3e2VI8timmIACuiQNlLHsKbRkgochubhLcjoMI6Cui1cvOLIcTyjA5u6HsfpfSmj06OqPjcrAQiAYKIPRYfrPRkbCzLUoK2OuPTsHK2mfTDk4JQk5zqeFgf9DvPrQQGTjbA0KQXJcojP0TuvORrHI7rHq3gjRLcbhxc6mhYa0oXXXIUyXbxVAdGOaK)1wzdq7ehhl6IfhW)TPoxmG1fm3o6l93zmqPI)73xk8Bkd0JW0STxhN44yrlv5amGW0STxhN44yrlv5aewoLB71sJfa)3M6NYbO4Ib2ursGcrx0vthN44yrlJb6ryA22J0Tm3RLQCaJc6IUTqM6CidWk8s1QjJbgOpowm98N3Uaa7)Phw1sTIZvtps2Lgtv6xGQtTba2)tpSQLAfNRMEKSlnMQ0VamUQ1BBQfLNl4SSmsca0woXf44uRruoxQfdzawHxQwnzmWa9XXIPN)82fay)p9WQwQvCUA6bPRPJQUavNAdaS)NEyvl1koxn9G010rvxagx16Tn1IYZfCwwgjbaAlN4cKlxGMo(fE5hT(aBgdWactZ2EKUL5ETuLd00XVWl)O1hqpCgd4OwxRWet2tSbkrnnd0NUF0ilB0f)uUGZZihjYflIC5y(XpnMa9imnB7z8XwQFCoqth)s6wM71YyGVlhe06yBasesmQ9RpqgGl0WP9dBhe06yBag1(1hidq7ehhlge06yBGreKKiqwaGyP5UI)ZpowKAXcwmqth)cKzmqHOl6IuUDPpoweGrTF9bYacukT0yrl1pd0iwLQRYB6DWkSnKb8uNduM6CaMPohWM6CUanD8BhN44yrlJbyaHPzBVbuRNQCanRPJQUbP)baovNPhw1sTIZvg70JM10rvxakNHb0dNQCGsf)3VVu43bLkLbCfHUd64xjdSPohWve6EhmvPFsgytDoafxmGE4uLdG010rvxgd4QxVVjzqkJbmWB8sUIF9K9eBapaTtCCSyqXzkc0HTsYYyan8gHY7j7j2aEaxrO7dQxVVjzGn15awxWCj7j2aEjxXV(aoQ1rgxSzmGRi0Dqh)kzqk15aFx2floG)BtDUyagsvoGRi0Ds3YCpjdsPohGbeMMT9m(yl15a2vfOdBLKLXanIvP6Q8MEkd4kcDN0Tm3tYaBQZbCuRpiO1X2aJiijrGS)SDjdui6IUA0k0WP9dBBzmW5wM7niO1X2aJiijrGmg1(1hid00XVdOhoJbo3YCVUyXbxVAdGOaK)1wzdGmNbofk10djNAtfjYbA643buRRvyItzaG2YjUabCfHUpOE9(MKbPuNdqJPk9tYaBkdqy5uUTVlwCa)3M6CXae2Lgtv63G0)aaNQZ0dRAPwX5kJD6HWU0yQs)c0bt0p9qIdWQwQvCUA6zabBakNHb2uLdq6QvCtpFzXOePkh4ClZ9KmWMYa9imnB7PvOHt7h22svoqth)kzqkJb6ryA22Ba16PkhGbeMMT90k0WP9dBBPkh47YUyXfqIC6bCrB6P6wl(nGJADYEInqjQPzah16aXQuArAQYbA64xTcnCA)W2wgdq5maKPohWvVEFtYaBgdiz5uUTF6PJtCCSy6za16bc00XVsgyZyaAmvPFsgKszGZTm3RlwCbKiNEax0MEQU1IFdWPXcGWP5cMPAmb(USlwCW1R2aika5FTv2auCbqMQCGZTm3RlwCa)3M6CXanD87aBgdq7ehhl6IfxajYPhWfTPNQBT43aUIq37GPk9tYGuQZbyfEPA1KXanofHAhqWMAXafIYP)2OYBW1R2aEGQtTbyvl1koxn9iz5uUTpGKLt52(PNooXXXIaNBzUxlqth)A8TVKl0WfmBzmW5wM7jzqkLbyCvR32ulkpJC5pLnAJur5prUmYdui6IUdkotb1kUa0bkeDrxnAPXcG)Bt9t5aCASWiGXuPIe5afIUORMUyXb8FBQZfdyIfxGbl3vtpv3AXVbkeDrxngFSLXanD8l8YpA9beSzmGJA9ci4xacL3V2Cj]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170613.213117, [[d8dmiaWyKSEvLEjLGDrsjVwvHFd1mHOMMcYSP48k0nHionkFJsKNlPDsL9k2nH9Ri)ecddvnosk1LvAOKYGvfdhHdkrhLKcDmf15uvKfQQAPiLwmrwov9qf4PGLrPSosQyIKu1uH0KjjtxLlsIRsj0ZOKCDeTrkvBLKc2Se2or5JkOoSuFgP67QsJKsuBdI0OjvJhP4Kev3IKkDnvf19iPOUnQSwskYXPK6mh0aunXXWc7yXb3OzdGWIOil3PeGQjogwyhloG9DJB2waFlOVd0xQpYFaRjxYT0WOl4wXfGkWiIII6EdAIJHf144dqdIII6EdAIJHf144dq4zCTFuofwaSVBCdXhGJjkvIZwaRjxYv1GM4yyrn)bgruuu3dT903RghFa1i5sU1Gg3CqdOiAjZQk)bkPogwm9GmREXP2bCn3gauqE6rXSCR4AZ0JMFPWCs9fG21SDDJZg)msN55Tkaq5zexGJXTQz(CXzlObueTKzvL)aLuhdlMEqMvV4qAaxZTbafKNEuml3kU2m9O(TOjnxaAxZ21noB8ZiDMN3k1Aoaq5zexGC5cu1XVWl7O0lvIuaAquuu3dT903RghFagfwaenftqpUphOj9TCrbgDKydirwueGgeff19SWFno(aJikkQ7zH)AC8bQ64x02tFVA(d8HuPGsh7dGIqJw5dBz0amHkgvFyFPGsh7dqR8HTmAaQM4yyrPGsh7d8JaffbscaelfRnSV9XWI4SHuBbQ64xan)bSMCjx1Z8l1XWIa0kFylJgqqYjNclQXnuGkXAm2nDvFa2G9bnqh3CaFCZbOh3CaP4MZfOQJFh0ehdlQ5panikkQ7vs6744dOAlAsZvQHCaGXny6rXSCR4AJ6m9OAlAsZfGRPPK8WXXhOne6DP5ThRAYuIBoqBi0Bqh)QjtjU5aTHqVhG5K6ttMsCZb4yIsYdhNTaT5ThRAY0YFazSktIzy3i6iXgqkavtCmSO0WOlcmqXHQqBavSkHPhrhj2aubKmSVFh2GFlnMifW3c6l6iXgOLyg2ngOj9nsyIn)bkWIlqPN1MPhx7943aFizhloG9DJB2wGM03LckDSpWpcuueibzf7ObAdHEJ2E67PjtlU5ax7PVxPGsh7d8JaffbsOv(WwgnGFnbgO4qvOnqLyng7MUQhPaTHqVrBp990KPe3CGXyxDr6N5)0m)NSYswzf)qQTv8PqDh6ZbSMCjxvYfQyu9H918hOne6nOJF1KPf3CGQo(TK8WrkW1E67zhlo4gnBaewefz5oLaiPPHXrYn9GY424SIpqvh)ws6B5IcCKcauEgXfOYe0nBG2qO3LM3ESQjtlU5asg23VdBWVrkaHNX1(r7yXbSVBCZ2cq4xkmNuFLAihayCdMEuml3kU2Ootpe(LcZj1xakmNuFAYuIuaUMMsL44dG2MvCtpd7XKeXXh4Ap990KPePadWeJtpO4akMLBfxBMEkrOeOQJF1KPL)aJikkQ7jxOIr1h2xJJpWiIII6ELK(oo(a0GOOOUNCHkgvFyFno(awtYO(qnWQWnA2asbAsFJosSbKilkcu1XVYfQyu9H918hOj9nqSgJC1hhFG282Jvnzk5pqvh)Qjtj)bQ643sLifGcZj1NMmTifqZZ4A)40ZGM4yyX0tjPVdy30C70dOJP(iW1E67zhlUaAOtpqlQtpU27XVb(qYowCWnA2aiSikYYDkb4ycanoBbU2tFp7yXbSVBCZ2cu1XVWl7O0ljpC(dq1ehdlSJfxan0PhOf1Phx7943aTHqVhG5K6ttMwCZbueTKzvL)avghHzlrOeNTaFizhlUaAOtpqlQtpU27XVbCn3gqXSCR4AZ0tjcLaCnnaAC8bODnBx34SXpBj(H4)KAzJFilXBPavD8Rf2rjMqftqVM)ax7PVNMmTifqZZ4A)40ZGM4yyraFFmCaRjxYvLCkSayF34gIpaJclutymxCwXhWAYLCvzhloG9DJB2waAIJpG1Kl5QYc)18hq9BrtAU8hOj9TffSlaHPhxFUea]] )


end
