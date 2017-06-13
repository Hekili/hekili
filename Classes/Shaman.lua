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

            enh_ascendance = ( not PTR ) and {
                resource = 'maelstrom',

                spec = 'enhancement',
                talent = 'ascendance',
                aura = 'ascendance',

                last = function ()
                    local app = state.buff.ascendance.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                stop = function( x )
                    return state.buff.ascendance.expires < x end,

                interval = 1,
                value = 12
            } or nil,
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
        addTalent( 'boulderfist', PTR and 246035 or 201897 )
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
        addAura( 'stormbringer', 201846, 'max_stack', PTR and 1 or 2 )
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
                state.nextMH = ( state.combat ~= 0 and state.swings.mh_projected > state.now ) and state.swings.mh_projected or state.now + 0.01
                state.nextOH = ( state.combat ~= 0 and state.swings.oh_projected > state.now ) and state.swings.oh_projected or state.now + ( state.swings.oh_speed / 2 )

                local next_foa_tick = ( state.buff.fury_of_air.applied % 1 ) - ( state.now % 1 )
                if next_foa_tick < 0 then next_foa_tick = next_foa_tick + 1 end                

                state.nextFoA = state.buff.fury_of_air.up and ( state.now + next_foa_tick ) or 0
                while state.nextFoA > 0 and state.nextFoA < state.now do state.nextFoA = state.nextFoA + 1 end
            end
        end )

        addHook( 'reset_postcast', function( x )
            state.feral_spirit.cast_time = nil 
            -- if state.talent.ascendance.enabled then state.setCooldown( 'ascendance', max( 0, state.last_ascendance + 180 - state.now ) ) end
            return x
        end )

        addHook( 'advance_end', function( time )
            --[[ if state.equipped.spiritual_journey and state.cooldown.feral_spirit.remains > 0 and state.buff.ghost_wolf.up then
                state.setCooldown( 'feral_spirit', max( 0, state.cooldown.feral_spirit.remains - time * 2 ) )
            end ]]
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

        ns.addSetting( 'safety_window', 0, {
            name = "Enhancement: Buff Safety Window",
            type = "range",
            desc = "Set a safety period for refreshing buffs when they are about to fall off.  The default action lists will recommend refreshing buffs if they fall off wihin 1 global cooldown. " ..
                "This setting allows you to extend this safety window by up to 1.5 seconds.  It may be beneficial to set this at or near your latency value, to prevent tiny fractions of time where " ..
                "your buffs would fall off.  This value is checked as |cFFFFD100rebuff_window|r in the default APLs.",
            width = "full",
            min = 0,
            max = 1.5,
            step = 0.01
        } )

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


        if not PTR then
            addAbility( 'boulderfist', {
                id = 201897,
                spend = -25,
                spend_type = 'maelstrom',
                cast = 0,
                gcdType = 'spell',
                known = function () return talent.boulderfist.enabled end,
                cooldown = 6,
                charges = 2,
                recharge = 6
            } )

            modifyAbility( 'boulderfist', 'spend', function( x )
                return x - artifact.gathering_of_the_maelstrom.rank
            end )

            addHandler( 'boulderfist', function ()
                applyBuff( 'boulderfist', 10 )
                if talent.landslide.enabled then
                    applyBuff( 'landslide', 10 )
                end
                if equipped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
                end
            end )

            modifyAbility( 'boulderfist', 'cooldown', function( x )
                return x * haste
            end )

            modifyAbility( 'boulderfist', 'recharge', function( x )
                return x * haste
            end )
        end


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
            spend = PTR and -25 or -20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = PTR and 6 or 0,
            charges = PTR and 2 or nil,
            recharge = PTR and 6 or nil,
            known = function() return PTR or not talent.boulderfist.enabled end
        } )

        modifyAbility( 'rockbiter', 'spend', function( x  )
            return x - ( artifact.gathering_of_the_maelstrom.rank )
        end )

        modifyAbility( 'rockbiter', 'cooldown', function( x )
            if PTR and talent.boulderfist.enabled then x = x * 0.85 end
            return x
        end )

        modifyAbility( 'rockbiter', 'recharge', function( x )
            if not PTR then return nil end
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
            cooldown = PTR and 15 or 16,
            known = function() return not buff.ascendance.up end
        } )

        modifyAbility( 'stormstrike', 'spend', function( x )
            if buff.stormbringer.up then x = x / 2 end
            if PTR and buff.ascendance.up then x = x / 4 end
            return x
        end )

        modifyAbility( 'stormstrike', 'cooldown', function( x )
            if buff.stormbringer.up then return 0 end
            if PTR and buff.ascendance.up then x = x / 4 end
            return x * haste
        end )

        addHandler( 'stormstrike', function ()
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            
            if PTR then
                removeBuff( 'stormbringer' )
            else
                removeStack( 'stormbringer' )
            end

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
            spend = PTR and 10 or 40,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = PTR and 3 or 16,
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
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            
            if PTR then
                removeBuff( 'stormbringer' )
            else
                removeStack( 'stormbringer' )
            end


            if equipped.storm_tempests then
                applyDebuff( 'target', 'storm_tempests', 15 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )

    end


    if not PTR then
        storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170414.211237, [[diuuLaqiKQArKkvAtaXOKcNskAxOYWujhtkTmsPNbKmnGuxJsv2gsv8nGY4ivkNJuKwhsvQAEKI6EKkzFKkoisXcbQEisYejvQYfrkTrsrmsKQu5KOQmtkv1nfQDQQgksvkwksLNsmvufBfvPVIuLSxL)QsnysHdt1ILQhRktMIldTzH8zKy0QOtJYQjvQQxtjMnj3wWUL8BedNu1XjvQy5GEoGPl66QW2PK(oLkNNsz9ivP08rsTFuv9AhptOT8Ucnd8j6EyKFOYb(KVhWjclqf)AqBD61ddyL075xddg5hQCcDOcDaCFTxTGDb6lnLt7fOb7cSjYdY0NtMqZlzKcy8SF74zcTL3vOzGprEqM(CssOqrHCSkri8qFcmHMotXsBtSJvMBGt0HtO6eFwIjwXaw56tIjgED43d4KjFpGtOxSYWVgYj6Wj0Hk0bW91E1cw71e(kd75jboPifojMy(EaNSCFTJNj0wExHM1NipitFojjuOOqUhHOme7kaqAKoKcMCNORYto9VuZATh1uNSaQZfN9UUAoHMotXsBt6kcXOoaYjuDIplXeRyaRC9jXedVo87bCYKVhWj07qiHbeMqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY9b14zcTL3vOzGprEqM(CssOqrHCpcrzi2vaG0G(omzr(l5CL(t)2oIkId6LfDUOM6gbhvajKe4EhqiwPo6s7fipcrzi2vCpOdCERyuoZIvu4GyWzfGM1fLNPzZj00zkwABsecD1nGEgKLtO6eFwIjwXaw56tIjgED43d4KjFpGt0ee6k(1q0ZGSCcDOcDaCFTxTG1EnHVYWEEsGtksHtIjMVhWjl3h0JNj0wExHMb(e5bz6Zjomzr(l5CL(t)2oIkId6LfDUarpeTEt5z4A5IqORUb0ZGSCcnDMIL2M8GoW5TIr5mlwrzcvN4ZsmXkgWkxFsmXWRd)EaNm57bCcvqh4KFnSpJYzwSIYe6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUV9gptOT8Ucnd8jYdY0NtscfkkK7rikdXUcaKg9JOioh4HLXRhYDONAQBeHqxDdONbzjhedoRa0XEnPMAfAfvAU96Q5eA6mflTnPJqaeAHvuMq1j(SetSIbSY1Netm86WVhWjt(EaNaocbqOfwrzcDOcDaCFTxTG1EnHVYWEEsGtksHtIjMVhWjl3NEgptOT8Ucnd8jYdY0NtscfkkK7rikdXUcaKg9JOioh4HLXRhYDONAQBeHqxDdONbzjhedoRa0XEnPMAfAfvAU96Q5eA6mflTnPRieZD0b02eQoXNLyIvmGvU(KyIHxh(9aozY3d4eWveIHFn0KdOTj0Hk0bW91E1cw71e(kd75jboPifojMy(EaNSCFWgptOT8Ucnd8jYdY0NtscfkkKtpjzKcaKg9JOiUocbqOfwrH7qp1uNoKcMCjlG3j52WqnRl65Q5eA6mflTnrpjzKAcFLH98KaNuKcNetm86WVhWjt(EaNqVHKmsnHgifGjLhqDP7QhsuKIcAU1tSdH6UtOdvOdG7R9QfS2RjuDIplXeRyaRC9jXeZ3d4e9qIIuuqZTEIDiC5(624zcTL3vOzGprEqM(Cs)ikIRtougegXasoigCwbOzi2pIIUTJvgIDutDJGJkGescCVdieRuZ6YExG4VKzfVXcdmeqhDbQMtOPZuS02Ko5qzqyediNq1j(SetSIbSY1Netm86WVhWjt(EaNao5qzqyediNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY910XZeAlVRqZaFI8Gm95K(ruexNCOmimIbKCqm4ScqZqSFefDBhRme7OM6gVthsbbUJG(lzKYv60YbM9aj4OciHKa37acXk1SU6KdLbHrmG8o4OciHKai(lzwXBSWadb0SU02CcnDMIL2M0jhkdcJya5eQoXNLyIvmGvU(KyIHxh(9aozY3d4eWjhkdcJyaj)A0OT5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUF714zcTL3vOzGprEqM(Cs6kSsoLxgafZGCy5DfAaPFefXP8YaOygKdIbNvaAgI9JOOB7yLHy3eA6mflTnbsEw6SeHtO6eFwIjwXaw56tIjgED43d4KjFpGtOJ8S0zjcNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY9BBhptOT8Ucnd8jYdY0NtOFYEwyffqcoQasijW9oGqSsD0QDcnDMIL2MeDaTDtIUDgCcvN4ZsmXkgWkxFsmXWRd)EaNm57bCIMCaTXVgKi(1GggCcDOcDaCFTxTG1EnHVYWEEsGtksHtIjMVhWjl3Vv74zcTL3vOzGprEqM(Cs6kSsUtNPascmWHL3vObK(ruexeKaKDOxgoigCwbOzi2pIIUTJvgIDG0Ob9txHvYfDaTDtIUDgKdlVRqttQPUr6kSsUOdOTBs0TZGCy5DfAaj4OciHKa37acXk1rR9A2CcnDMIL2Mebjazh6LzcvN4ZsmXkgWkxFsmXWRd)EaNm57bCIMajazh6LzcDOcDaCFTxTG1EnHVYWEEsGtksHtIjMVhWjl3VfuJNj0wExHMb(e5bz6Zj9JOiUiLhWKuuoqoigCwbOzi2pIIUTJvgIDutDJhHOme7kodHeUTJvgaoigCwbOz6bK(ruexKYdyskkhihedoRa0mOBoHMotXsBtIuEatsr5aNq1j(SetSIbSY1Netm86WVhWjt(EaNOjkpGjPOCGtOdvOdG7R9QfS2Rj8vg2ZtcCsrkCsmX89aoz5(TGE8mH2Y7k0mWNetm86WVhWjt(EaNO7rib(1GEXkdWe6qf6a4(AVAbR9AcnDMIL2MyiKWTDSYamHVYWEEsGtksHtO6eFwIjwXaw56tIjMVhWjl3V1EJNj0wExHMb(e5bz6ZjPRWk5Eqh4KvuUbscmWHL3vObe)LmR4nwyGHa6Olqbsd6NUcRK70zkGKadCy5DfAOM6(ruexeKaKDOxgoigCwbOdLNP5eA6mflTn5bDGZBfJYzwSIYeQoXNLyIvmGvU(KyIHxh(9aozY3d4eQGoWj)AyFgLZSyff(1OrBZj0Hk0bW91E1cw71e(kd75jboPifojMy(EaNSC)w6z8mH2Y7k0mWNetm86WVhWjt(EaNqRdZtS4xdrpZcoHouHoaUV2RwWAVMqtNPyPTjOdZtSUb0ZSGt4RmSNNe4KIu4eQoXNLyIvmGvU(KyI57bCYY9BbB8mH2Y7k0mWNipitFoPr6kSsoIve(oDifKdlVRqdibhvajKe4EhqiwPo6c0xGq)0vyLCrhqB3KOBNb5WY7k00KAQBKUcRKJyfHVthsb5WY7k0as6kSsUOdOTBs0TZGCy5DfAaj4OciHKa37acXk1b00tZj00zkwABIIr5mlwr5Utu5eQoXNLyIvmGvU(KyIHxh(9aozY3d4e7ZOCMfROWVgGtu5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUFRUnEMqB5DfAg4tKhKPpN0pII4Eqh48wXOCMfROWbXGZkandX(ru0TDSYqSde)LmR4nwyGHa6OlTtOPZuS02Kh0boVvmkNzXkktO6eFwIjwXaw56tIjgED43d4KjFpGtOc6aN8RH9zuoZIvu4xJgABoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL73QPJNj0wExHMb(KyIHxh(9aozY3d4e6fRmaKIYe6qf6a4(AVAbR9AcnDMIL2MyhRmaKIYe(kd75jboPifoHQt8zjMyfdyLRpjMy(EaNSCFTxJNj0wExHMb(e5bz6ZjjHcffY9ieLHyxbasJ(ruehqsGHoKvuqi3H(MtOPZuS02eh4HLXRhoHQt8zjMyfdyLRpjMy41HFpGtM89aoHgGhwgVE4e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUV22XZeAlVRqZaFI8Gm95K(ruehqsGHoKvuqi3HEqA0iDfwjx0b02nj62zqoS8UcnGeCubKqsG7DaHyL6OlT0ttQPUb9txHvYfDaTDtIUDgKdlVRqtZMtOPZuS02e7yLbiHml4eQoXNLyIvmGvU(KyIHxh(9aozY3d4e6fRmajKzbNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY91QD8mH2Y7k0mWNipitFoPFefXbKeyOdzffeYDOhKgnsxHvYfDaTDtIUDgKdlVRqdibhvajKe4EhqiwPo6sl90KAQBq)0vyLCrhqB3KOBNb5WY7k00S5eA6mflTnbijWaqczwWjuDIplXeRyaRC9jXedVo87bCYKVhWjssGbGeYSGtOdvOdG7R9QfS2Rj8vg2ZtcCsrkCsmX89aoz5(Ab14zcTL3vOzGprEqM(CcQ7CW0RhnCUfNvha3EhGOos8w3)aizpeK0vyLCNK8(0ldhwExHgq6hrrCNK8(0ld3HEqOF)ikIlcsaYo0ld3HEqA0G(PRWk5IoG2Ujr3odYHL3vOPj1u3iDfwjx0b02nj62zqoS8UcnGeCubKqsG7DaHyL6O1EnBoHMotXsBtIGeGSd9YmHQt8zjMyfdyLRpjMy41HFpGtM89aortGeGSd9YWVgnABoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7Rf0JNj0wExHMb(e5bz6ZjPRWk5oj59PxgoS8UcnG0pII4oj59PxgUd9tOPZuS02eLB1VvoW5eQoXNLyIvmGvU(KyIHxh(9aozY3d4e77wD(1W(oW5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUVw7nEMqB5DfAg4tKhKPpNKUcRKJyfHVthsb5WY7k0aYJqugIDfNIr5mlwr5UtujhedoRa0mLNbKGJkGescCVdieRuhD7AcnDMIL2MyhRmajKzbNq1j(SetSIbSY1Netm86WVhWjt(EaNqVyLbiHmli)A0OT5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUVw6z8mH2Y7k0mWNipitFojDfwjx0b02nj62zqoS8UcnGeCubKqsG7DaHyL6aA6bKgpcrzi2vCkgLZSyfL7orLCqm4Scqhkpd1ut)0vyLCeRi8D6qkihwExHMMtOPZuS02e7yLbiHml4eQoXNLyIvmGvU(KyIHxh(9aozY3d4e6fRmajKzb5xJgABoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7RfSXZeAlVRqZaFI8Gm95e6NUcRKJyfHVthsb5WY7k0ac9txHvYfDaTDtIUDgKdlVRqZeA6mflTnXowzasiZcoHQt8zjMyfdyLRpjMy41HFpGtM89aoHEXkdqczwq(1ObOAoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7Rv3gptOT8Ucnd8jYdY0Nt8xYSI3yHbgcOJUa1eA6mflTnb4OmiKvuMq1j(SetSIbSY1Netm86WVhWjt(EaNihLbHSIYe6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUVwnD8mH2Y7k0mWNipitFoXFjZkEJfgyiGo6c0tOPZuS02Kh0boVvmkNzXkktO6eFwIjwXaw56tIjgED43d4KjFpGtOc6aN8RH9zuoZIvu4xJgGQ5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUpOUgptOT8Ucnd8jYdY0NtsxHvYrSIW3PdPGCy5DfAa5rikdXUItXOCMfROC3jQKdIbNvaAMYZasWrfqcjbU3beIvQJUDnHMotXsBtascmaKqMfCcvN4ZsmXkgWkxFsmXWRd)EaNm57bCIKeyaiHmli)A0OT5e6qf6a4(AVAbR9AcFLH98KaNuKcNetmFpGtwUpOAhptOT8Ucnd8jYdY0NtsxHvYfDaTDtIUDgKdlVRqdibhvajKe4EhqiwPoGMEaPXJqugIDfNIr5mlwr5UtujhedoRa0HYZqn10pDfwjhXkcFNoKcYHL3vOP5eA6mflTnbijWaqczwWjuDIplXeRyaRC9jXedVo87bCYKVhWjssGbGeYSG8RrdTnNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY9bL2XZeAlVRqZaFI8Gm95e6NUcRKJyfHVthsb5WY7k0ac9txHvYfDaTDtIUDgKdlVRqZeA6mflTnbijWaqczwWjuDIplXeRyaRC9jXedVo87bCYKVhWjssGbGeYSG8Rrdq1CcDOcDaCFTxTG1EnHVYWEEsGtksHtIjMVhWjl3huGA8mH2Y7k0mWNipitFoPrd)LmR4nwyGHa60sn1PRWk5Eqh4KvuUbscmWHL3vOHAQtxHvY1jhkdcJyajhwExHMMGqFamV7K6aGlziSvtVbT(NoxnPM6ie6QBa9mil5GyWzfGo2BcnDMIL2M8GoW5TIr5mlwrzcvN4ZsmXkgWkxFsmXWRd)EaNm57bCcvqh4KFnSpJYzwSIc)A0a0nNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY9bfOhptOT8Ucnd8jYdY0Nt8xYSI3yHbgcOJUa1eA6mflTn5bDGZBfJYzwSIYeQoXNLyIvmGvU(KyIHxh(9aozY3d4eQGoWj)AyFgLZSyff(1OH9AoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7dk7nEMqB5DfAg4tKhKPpNKUcRK70zkGKadCy5DfAaPFefXfbjazh6LHdIbNvaAg0C6ginAq)0vyLCrhqB3KOBNb5WY7k00KAQBKUcRKl6aA7MeD7mihwExHgqcoQasijW9oGqSsD0AVMnNqtNPyPTjrqcq2HEzMq1j(SetSIbSY1Netm86WVhWjt(EaNOjqcq2HEz4xJgABoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7dk6z8mH2Y7k0mWNipitFob1Doy61Jgo3IZQdGBVdquhjER7FaKShcc97hrrCrqcq2HEz4o0dsJg0pDfwjx0b02nj62zqoS8UcnnPM6gPRWk5IoG2Ujr3odYHL3vObKGJkGescCVdieRuhT2RzZj00zkwABseKaKDOxMjuDIplXeRyaRC9jXedVo87bCYKVhWjAcKaKDOxg(1ObOAoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7dkWgptOT8Ucnd8jYdY0NtsxHvYfDaTDtIUDgKdlVRqdiPRWk5iwr470HuqoS8UcnG0aaZ7oPoa4sgcB10BqR)PZfibhvajKe4EhqiwPo6s3UAoHMotXsBtuUv)w5aNtO6eFwIjwXaw56tIjgED43d4KjFpGtSVB15xd77aN8RrJ2MtOdvOdG7R9QfS2Rj8vg2ZtcCsrkCsmX89aoz5(Gs3gptOT8Ucnd8jYdY0NtsxHvYfDaTDtIUDgKdlVRqdi0pDfwjhXkcFNoKcYHL3vObKgayE3j1baxYqyRMEdA9pDUaj4OciHKa37acXk1rx2dunNqtNPyPTjk3QFRCGZjuDIplXeRyaRC9jXedVo87bCYKVhWj23T68RH9DGt(1OH2MtOdvOdG7R9QfS2Rj8vg2ZtcCsrkCsmX89aoz5(GsthptOT8Ucnd8jYdY0NtAqFamV7K6aGlziSvtVbT(NoxGeCubKqsG7DaHyL6ORwTxnPM6g0pDfwjx0b02nj62zqoS8UcnGaG5DNuhaCjdHTA6nO1)05cKGJkGescCVdieRuhDb6RMtOPZuS02eLB1VvoW5eQoXNLyIvmGvU(KyIHxh(9aozY3d4e77wD(1W(oWj)A0aunNqhQqha3x7vlyTxt4RmSNNe4KIu4KyI57bCYY9b914zcTL3vOzGprEqM(Cs)ikIls5bmjfLdKdIbNvaAg0C62eA6mflTnjs5bmjfLdCcvN4ZsmXkgWkxFsmXWRd)EaNm57bCIMO8aMKIYbYVgnABoHouHoaUV2RwWAVMWxzyppjWjfPWjXeZ3d4KL7d62XZeAlVRqZaFsmXWRd)EaNm57bCcDKNLolri)A0OT5e6qf6a4(AVAbR9AcnDMIL2MajplDwIWj8vg2ZtcCsrkCcvN4ZsmXkgWkxFsmX89aoz5(Gw74zcTL3vOzGpjMy41HFpGtM89aortuEatsr5a5xJgABoHouHoaUV2RwWAVMqtNPyPTjrkpGjPOCGt4RmSNNe4KIu4eQoXNLyIvmGvU(KyI57bCYY9bnOgptOT8Ucnd8jXedVo87bCYKVhWjGtougegXas(1OH2MtOdvOdG7R9QfS2Rj00zkwABsNCOmimIbKt4RmSNNe4KIu4eQoXNLyIvmGvU(KyI57bCYYLte94J5kg9wpzKAFT0dOwUba]] )

        storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170414.211237, [[dqt3baGEurTluLEnQQMjvQMnLUPcDBrTtr2lz3sTFf0WqPFlzOqunybz4q6GuKJrvDoublKcTub1IPILROhcrEk4XqzDquMiQqtLkzYcnDvUif1LrUoQihwPTsb2muL2oQKNlWYGW0Os57uqNhvQfHQYOPkFgfNevX3GkNwv3dQI)QaBdQkpdQQw(YLaZ96yPOmkGJeExozpzuqAZKa4ZinmK52BBmkt9HSHHqNewLD2tqyYsBaPecwFCSUXYbErW6gowCcaS5JEceyc7(QdKlL8LlbM71XsrzuaGnF0tWvmmwIx06(QdeyY5T)XTa06(QfWthFS9QPGUAsWyfnyNPntceK2mja519vlW0KjqqVzcp8HolB1muCaAzin5tqyYsBaPecwFC(ScqYJW4FS4IYuFYrWyftBMeGolB1muCaAzin1Pec5sG5EDSuugfmwrd2zAZKabPntcC)z8U(BMHHaVNSrbHjlTbKsiy9X5ZkWKZB)JBb2NX76Vzge49KnkGNo(y7vtbD1KaK8im(hlUOm1NCemwX0Mjb60jaqjSFTpN37Rwje4d)6Ka]] )
    
    else
        storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170611.200523, [[deKBtaqifKfjiztcIrrQCksvZsqQDrsdJeoMQyzcLNPGY0uL4AQsABkq6BKOgNqvoNcuwhkvMNce3dLY(qH6GcXcfQ8quYevGQlkbNubmtfuDtu0ojLLkj9uktvsCvHQsBff8vHQQ9c9xfAWICyQwmIESIMSQ6YGnlWNvLA0s0Pr1QfQk61cQzt42sz3Q8BIgUK64Ou1Yr65s10v66iSDH03rHCEj06fQkmFsK9lQXhScAfoNuaFmo008gGMXBSYPcxPFtOb3YUC6dboHyrZQHj3f84dF5Yd1InOddTQGa8oGAXu8OSIxEErn2ZtSHPmA2KYRx0qlYC5YRJvqThScAfoNuaFmo0SjLxVOTY3VfGk)wGsjQ3oAri5c(wengXV)yVeCkAdCF(0xjfTtEaAmLFgCQM3a0qtZBaAXp)(5KvcofTQGa8oGAXu8O8Jc0QcDjbDcDScUOXQeMHzkJcn4wKenMYVM3a0Wf1IHvqRW5Kc4JXHMnP86fnD5KUCADbCRAPZf9vsBQW5Kc4NtHKtdLtKebbQbuzFjP(9vjQZj95KskLtdLtRlGBvlDUOVsAtfoNua)CspAri5c(weTOoL7KcanwLWmmtzuOb3IKOXu(zWPAEdqR05I(kPnwLWmmAAEdqZwjfYjgCbbGwe67oAN3a2kDUOVsAJvjmdh6OUGaytNU1fWTQLox0xjTPcNtkGFidrseeOgqL9LK63xLOwVskn06c4w1sNl6RK2uHZjfWxpAvbb4Da1IP4r5hfOvf6sc6e6yfCrBG7ZN(kPODYdqJP8R5nanCrTHHvqRW5Kc4JXHMnP86fnD50q506c4w1acAXrzWOZPQW5Kc4NtkPuoPlNwxa3QgqqlokdgDovfoNua)CkKCQ5GOVuztDsqPWT5eJZP4PiN0Nt6rlcjxW3IOf1PCNuaOXQeMHzkJcn4wKenMYpdovZBaAbe0ISkHz44PannVbOzRKc5edUGaYjDp6rlc9DhTZBaBbe0ISkHz44Pi0rDbbWMUHwxa3QgqqlokdgDovfoNuaFLus36c4w1acAXrzWOZPQW5Kc4hsZbrFPYgJJNc96rRkiaVdOwmfpk)OaTQqxsqNqhRGlAdCF(0xjfTtEaAmLFnVbOHlQ9cwbTcNtkGpghA2KYRx00LtdLtRlGBvdiOfhLbJoNQcNtkGFoPKs5KUCADbCRAabT4Omy05uv4Csb8ZPqYPMdI(sLn1jbLc3MtmoNE51CsFoPhTiKCbFlIwuNYDsbGgRsygMPmk0GBrs0yk)m4unVbOfqqlYQeMHF5v008gGMTskKtm4cciN0ftpArOV7ODEdylGGwKvjmd)YRHoQlia20n06c4w1acAXrzWOZPQW5Kc4RKs6wxa3QgqqlokdgDovfoNua)qAoi6lv2y8lVQxpAvbb4Da1IP4r5hfOvf6sc6e6yfCrBG7ZN(kPODYdqJP8R5nanCrTxXkOv4Csb8X4qZMuE9IMUCAOCADbCRAabT4Omy05uv4Csb8ZjLukN0LtRlGBvdiOfhLbJoNQcNtkGFofso1Cq0xQSPojOu42CIX5uSxZj95KE0IqYf8TiArDk3jfaASkHzyMYOqdUfjrJP8ZGt18gGwabTiRsygo2ROP5nanBLuiNyWfeqoPBy6rlc9DhTZBaBbe0ISkHz4yVg6OUGayt3qRlGBvdiOfhLbJoNQcNtkGVskPBDbCRAabT4Omy05uv4Csb8dP5GOVuzJXXEvVE0QccW7aQftXJYpkqRk0Le0j0Xk4I2a3Np9vsr7KhGgt5xZBaA4IAdkwbTcNtkGpghA2KYRx00Lta7j411Wx951N49my5KE0IqYf8TiArDk3jfaASkHzyMYOqdUfjrJP8ZGt18gGwj40Ta7j411WhnnVbOzRKc5edUGaYjDVOhTi03D0oVbSvcoDlWEcEDn8dDuxqaSPdypbVUg(QpV(eVNbtpAvbb4Da1IP4r5hfOvf6sc6e6yfCrBG7ZN(kPODYdqJP8R5nanCrnLXkOv4Csb8X4qZMuE9IMUCcypbVUg(QEyNFe9rNSlfelmgFs0x(eYj9OfHKl4Br0I6uUtka0yvcZWmLrHgClsIgt5NbNQ5nanpSZpIcSNGxxdF008gGMTskKtm4cciN09QE0IqF3r78gWMh25hrb2tWRRHFOJ6ccGnDa7j411Wx9zykRiEVOhTQGa8oGAXu8O8Jc0QcDjbDcDScUOnW95tFLu0o5bOXu(18gGgUOw8WkOv4Csb8X4qZMuE9IMUCkQt5oPau9Wo)ikWEcEDn8ZPqYjsIGa1s5ow63xLOoNcjNgkNijccudOY(ss97RsuNt6rlcjxW3IOf1PCNuaOXQeMHzkJcn4wKenMYpdovZBaAEyNFerm008gGMTskKtm4cciN0nO6rlc9DhTZBaBEyNFerSqh1feaB6I6uUtkavpSZpIcSNGxxd)qijcculL7yPFFvk4ZnKHijccudOY(ss97RsuRhTQGa8oGAXu8O8Jc0QcDjbDcDScUOnW95tFLu0o5bOXu(18gGgUO2GHvqRW5Kc4JXHMnP86fnD50q5ejrqGQG)UCp(9ECs9EPkrDofso1HDKuEeD1Ld0ykgJvpZjgNtkYj9OfHKl4Br0I6uUtka0yvcZWmLrHgClsIgt5NbNQ5naTHZFxUh)EZI69sn5gFRrtZBaA2kPqoXGliGCsNY6rlc9DhTZBaBdN)UCp(9Mf17LAYn(wh6OUGayt3qKebbQc(7Y9437Xj17LQe1H0HDKuEeD1Ld0ykgJvp1JwvqaEhqTykEu(rbAvHUKGoHowbx0g4(8PVskAN8a0yk)AEdqdxu7rbwbTcNtkGpghA2KYRx00LtKebbQUOU0hzKueOsHMZVEoni5uSCkKCkaOUySxZP8vLcnNF9CIX50l5KE0IqYf8TiArDk3jfaASkHzyMYOqdUfjrJP8ZGt18gGMlQl94xkcyvcZWOP5nanBLuiNyWfeqoPlE6rlc9DhTZBaBUOU0JFPiGvjmdh6OUGaytNUAyvdOY(oYiPiqLKiiq1f1L(iJKIavk0C(1hKyHudRAahOfhzKueOsseeO6I6sFKrsrGkfAo)6dsSqQHvvWFxUh)EpYiPiqLKiiq1f1L(iJKIavk0C(1hKy6djaOUySxZP8vLcnNFDg)IE0QccW7aQftXJYpkqRk0Le0j0Xk4I2a3Np9vsr7KhGgt5xZBaA4IAppyf0kCoPa(yCOfHKl4Br0MUqm6ZLlVrbVVOnW95tFLu0o5bOXu(zWPAEdqdnnVbOXYfICkYC5YlNgoVVOfH(UJ25nGTqz8gRCQWv63eAWTSlNK1Wb0qHwvqaEhqTykEu(rbAvHUKGoHowbx0yvcZWmLrHgClsIgt5xZBaAgVXkNkCL(nHgCl7YjznCafxu7jgwbTcNtkGpghA2KYRx00LtrDk3jfGAj40Ta7j411WpNusPCQd7iP8i6QlhOpd2yS6zoX4CsroPpNcjN0LtdLtRlGBvbNULWn2R5Hbv4Csb8ZjLukN0LttPu8Lm6ubNULWn2R5Hbvk0C(1ZjgNtp5ui50ukfFjJo1Vu2gze)(Dvk0C(1ZjgNtp5K(CsjLYPpqseeOcoDlHBSxZddQe15KE0IqYf8TiAmIF)(s5Hb0g4(8PVskAN8a0yk)m4unVbOHMM3a0IF(97lLhgqRkiaVdOwmfpk)OaTQqxsqNqhRGlASkHzyMYOqdUfjrJP8R5nanCrTNHHvqRW5Kc4JXHwesUGVfrB6cXOpxU8gf8(I2a3Np9vsr7KhGgt5NbNQ5nan008gGglxiYPiZLlVCA48(Mt6E0Jwe67oAN3a2cLXBSYPcxPFtOb3YUCIKiiOhk0QccW7aQftXJYpkqRk0Le0j0Xk4IgRsygMPmk0GBrs0yk)AEdqZ4nw5uHR0Vj0GBzxorsee0Xf1EEbRGwHZjfWhJdTiKCbFlI20fIrFUC5nk49fTbUpF6RKI2jpanMYpdovZBaAOP5nanwUqKtrMlxE50W59nN0ftpArOV7ODEdylugVXkNkCL(nHgCl7YjwdEpuOvfeG3bulMIhLFuGwvOljOtOJvWfnwLWmmtzuOb3IKOXu(18gGMXBSYPcxPFtOb3YUCI1G3Xf1EEfRGwHZjfWhJdTiKCbFlI20fIrFUC5nk49fTbUpF6RKI2jpanMYpdovZBaAOP5nanwUqKtrMlxE50W59nN0nm9OfH(UJ25nGTqz8gRCQWv63eAWTSlNMskek0QccW7aQftXJYpkqRk0Le0j0Xk4IgRsygMPmk0GBrs0yk)AEdqZ4nw5uHR0Vj0GBzxonLuaxu7zqXkOv4Csb8X4qlcjxW3IOnDHy0NlxEJcEFrBG7ZN(kPODYdqJP8ZGt18gGgAAEdqJLle5uK5YLxonCEFZjDVOhTi03D0oVbSfkJ3yLtfUs)MqdULD5uaxiaAOqRkiaVdOwmfpk)OaTQqxsqNqhRGlASkHzyMYOqdUfjrJP8R5nanJ3yLtfUs)MqdULD5uaxiakU4I2GdboHyX4Wfra]] )

        storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170611.200523, [[daJZbaGEuuTluITHcAMOaZMk3uIUTK2jvTxYUvSFrQHjHFR0qrHAWIWWfvhKI6yqAHuKLkvTykSCO6HIKNcESuwhkstefLPkvMmetx4IOkpdv46IOTIkAZOq2oQKPHs1LroSklJsgnL65q5KOK(gQQtRQZJs5ZIYRrL6VOiwOQtaV5mCeImjWFvsa81uPtWBSVPrvAcMMoroo12QXfcGCQ9N7z(f)oYBXqoe0to6Wi5Tkq5xWok7SyHIAXbFbqd)Zdbcm3IFhm1jpQ6eWBodhHitcGg(NhcInlZrSKVXVdMaZgV7d2eKVXVJawhKVDXIly2HeuUiCE4(Rsce4VkjGXB87iONC0HrYBvGYhTqqpHTjXBeM6uiiLn14UC5IQ0eYqq5I4VkjqH8wQtaV5mCeImjWSX7(GnbUpZoMFYycM9toebSoiF7IfxWSdjOCr48W9xLeiWFvsad(m7y(jlDcW(jhIGEYrhgjVvbkF0cb9e2MeVryQtHGu2uJ7YLlQstidbLlI)QKafkeWmIrxsxitkKaa]] )

        storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170611.200523, [[d0JLlaGEvsuBIkLDHu2gsu2hsKzQsQzRW8PcUPK8CQ62k6BiP2Pk2Ry3QA)szuujggi9BsESeNxjmyPA4KQoKkj5uujDmj1XvjPwirYsjflgulNWdjvEkQLrfToKOQtJyQeXKvQPdCrLORQsI8msP66GyJQKGTskzZiHTRKomLVskLMgvO(osu51ivJJukgnr9xvItsK6ZQuxJkK7rLQldDovsOdIKCQJKWlFdEG7ah(ytmmtM6A9LVS9fCIpGY36fLadRbhO5XCCcTMAOuwDnT6WCrq0dchMQcGOEFKKtDKeE5BWdChPcZfbrpi8Qjig8aPrbeXcDYyHUthfMkyYGawegnbqg)lE9e6yyP)nPyaLi8REmCLARLjo2edh(ytm8staKXV1z9e6yyn4anpMJtO1uxdnSg0RGikOpsciSozSqVsTIt8bboCLAFSjgoGCCgjHx(g8a3rQWCrq0dcddHckOveMx(YGCldEYFttGtJ8(w39whAR7wRBfazfVGpojOV1PK7TUZWubtgeWIWfH5LVmi3YGN83HL(3KIbuIWV6XWvQTwM4ytmC4JnXW6eMxU1VMCldEYFhwdoqZJ54eAn11qdRb9kiIc6JKacRtgl0RuR4eFqGdxP2hBIHdihThjHx(g8a3rQWCrq0dcBfazfVGpojOV1PK7TU206o4qR7sRBfazfVGpojOV1PK7ToL16U16aBGpGwryEzYFFXduIjn8n4bUBDxdtfmzqalcxeMx(YGCldEYFhw6Ftkgqjc)QhdxP2AzIJnXWHp2edRtyE5w)AYTm4j)DR7sTRH1Gd08yooHwtDn0WAqVcIOG(ijGW6KXc9k1koXhe4WvQ9XMy4aYXXrs4LVbpWDKkmvWKbbSimLJ8BV6Vdl9VjfdOeHF1JHRuBTmXXMy4WhBIH1wYV9Q)oSgCGMhZXj0AQRHgwd6vqef0hjbewNmwOxPwXj(GahUsTp2edhqookscV8n4bUJuHPcMmiGfHPCKF7bccDmS0)MumGse(vpgUsT1YehBIHdFSjgwBj)2dee6yyn4anpMJtO1uxdnSg0RGikOpsciSozSqVsTIt8bboCLAFSjgoGCOSij8Y3Gh4osfMlcIEqyyiuqbnpqjMWcYFJcAq036U16RMGyWdKgfqel0jJf6oDuyQGjdcyrypqjMEGGqhdl9VjfdOeHF1JHRuBTmXXMy4WhBIHzGsm9abHogwdoqZJ54eAn11qdRb9kiIc6JKacRtgl0RuR4eFqGdxP2hBIHdihQJKWlFdEG7ivyUii6bHTcGSIxWhNe036uY9w3XTUdo06U06wbqwXl4Jtc6BDk5ER7S1DR1b2aFaTIW8YK)(IhOetA4BWdC36UgMkyYGaweUimV8Lb5wg8K)oS0)MumGse(vpgUsT1YehBIHdFSjgwNW8YT(1KBzWt(7w3fNUgwdoqZJ54eAn11qdRb9kiIc6JKacRtgl0RuR4eFqGdxP2hBIHdihTjscV8n4bUJuH5IGOhegyd8b0uROOiBIBKg(g8a3TUBT(Qjig8aPrbeXcDYyHUJDuR7wRpnC4bc1KwbIqGpO1PK7TUJHgMkyYGaweEqULbp5VVaRgGWs)BsXakr4x9y4k1wltCSjgo8XMy4Rj3YGN83TUuQbiSgCGMhZXj0AQRHgwd6vqef0hjbewNmwOxPwXj(GahUsTp2edhqoxXij8Y3Gh4osfMlcIEqyxA9RQ1b2aFan1kkkYM4gPHVbpWDR7wRVAcIbpqAuarSqNmwO7yh16U26o4qR7sRdSb(aAQvuuKnXnsdFdEG7w3TwF1eedEG0OaIyHozSqxBG26UgMkyYGawe2duIPhii0XWs)BsXakr4x9y4k1wltCSjgo8XMyygOetpqqOJTUl1UgwdoqZJ54eAn11qdRb9kiIc6JKacRtgl0RuR4eFqGdxP2hBIHdiNAOrs4LVbpWDKkmxee9GWRMGyWdKMr3ipeQ4WubtgeWIWuiuEaSW(DyP)nPyaLi8REmCLARLjo2edh(ytm8vqO8ayH97WAWbAEmhNqRPUgAynOxbruqFKeqyDYyHELAfN4dcC4k1(ytmCa5uxhjHx(g8a3rQWCrq0dcddHckOjRaxKTFtdI(w3Tw3Lw3LwF1eedEG0m6g5HS8QHq0Rh3TUBTomekOGgfcLhalSFtdI(w31w3bhA9RQ1xnbXGhinJUrEilVAie96XDR7AyQGjdcyr4HTAxgMxoS0)MumGse(vpgUsT1YehBIHdFSjg(AB1A9RnVCyn4anpMJtO1uxdnSg0RGikOpsciSozSqVsTIt8bboCLAFSjgoGCQDgjHx(g8a3rQWCrq0dcBfazfVGpojOV1PK7TU2dtfmzqalc7H8Buq(7Ws)BsXakr4x9y4k1wltCSjgo8XMyygYVrb5VdRbhO5XCCcTM6AOH1GEferb9rsaH1jJf6vQvCIpiWHRu7JnXWbKtT2JKWlFdEG7ivyUii6bHTcGSIxWhNe036uY9wx7TUdo06RMGyWdK21KBzWt(BDcZlFuGRK(w3bhA9vtqm4bsZg6LnTvnOqNmwOhMkyYGaweUimV8Lb5wg8K)oS0)MumGse(vpgUsT1YehBIHdFSjgwNW8YT(1KBzWt(7w3fT7Ayn4anpMJtO1uxdnSg0RGikOpsciSozSqVsTIt8bboCLAFSjgoGacZ6XcXgKRSbiQphNuM2diba]] )

        storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170611.200523, [[dWsobaGEHuBIQIDju2MeA2k1nHk3Mk7ur7LSBe7xjdts9BugScdxQCqjQJjyHcrlvkTyOSCu9qjPNcwMu16OOAQsXKPktx0fPixw11LeBviz7cH5jrEofEmLgTq1HHCsQQ60iDnQQCEkkVgQ6BsWZOQ0kOgbMiiS99eMGjYDba1vDnmrIJi27ojnFnyDNCUG2VpY4A2xhkuxmeIfeawoTlfiOSnPmIHA0mOgbMiiS99uKcalN2LcCOVnsoZfZwHZpjxJsRrWV1WN1iPUVgLwJEbLXOBAAMaoZIhJMNlWFIh1IsgxaHrUaCmVOq8jYDbcMi3f0YS4XO55cA)(iJRzFDOqOwq7nyv42BOgLcQg)w84yrC3jPWeGJ5nrUlqPsbq3Tu0MgnkPmIM9f9vPea]] )

        storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170611.200523, [[dWt(gaGEuj0Mec7IcBdvk7dvQMnLMpQYnvjpxWTH4BOc7es7vA3qTFugLq0Wev)wPhlYqvrvgmsdxOoicCkkQoMkCEurlKuYsjvTyeTCQ8qe0tjwMkY6urLMiQKAQOQMmvnDvDreQttYZiLkxxLAJOs0wPOSzsLTJqMhPu(QkQQPrkv9DksJufv8xrXOfshwXjPi(mP4AQOCpuj4YGdHkjVwu6Eu(vigpKwWxYkOdcuruieYOeJJo4eGa4)Czuc56qf9GfMau0t5hCKZTJdJJksYPI)kvii9Qfhk)IEu(vigpKwWxYksYPI)k)QrJfms7A9RP4aJgbJgjJ(Jtd8grHX(rnItpJQng90zmkpEm6RqagL7mAUXz55mQ5viGuzvpNviT76T3HVIjyVkn)6QGxmu5A9Mno0bbQubDqGkNd4wvaPIEWctak6P8dooYROhc7TlbHYVFfcJcPSxlracG)sw5A9OdcuPFrpv(vigpKwWxTQijNk(R8RgnwWiTR1VMIdmAemAKmk5ToDgtiby)GtGXDmJYJhJgjJQdCJntiw5uVHdqgfoWOCNrpJrnNr5XJrTarGLr1gJEKNZOMxHasLv9CwHeCbWLvH1uXeSxLMFDvWlgQCTEZgh6GavQGoiqfTaxaCzvynv0dwycqrpLFWXrEf9qyVDjiu(9RqyuiL9Ajcqa8xYkxRhDqGk9lQ2v(vigpKwWxTQijNk(R8RgnwWiTR1VMIdmAemAKmk5ToDgtiby)GtGXDmJYJhJgjJQdCJntiw5uVHdqgfoWOCNrpJrnNr5XJrTarGLr1gJEKNZOMxHasLv9CwH0URpJUBhNvmb7vP5xxf8IHkxR3SXHoiqLkOdcurl7UEgLlVDCwrpyHjaf9u(bhh5v0dH92LGq53VcHrHu2RLiabWFjRCTE0bbQ0VOAF5xHy8qAbF1QIKCQ4VYVA0ybJ49vloWOrWOrYOK360zmHeG9dobg3XmkpEmkxXO)yb8BmHeG9dobgaEiTGNrJGr1bUXMjeRCQ3WbiJchyuUZONXO84XO)40aVXRqGm)MXRagvBCbgLB5mQ5viGuzvpNvI3xT4kMG9Q08RRcEXqLR1B24qheOsf0bbQCE7RwCf9GfMau0t5hCCKxrpe2BxccLF)kegfszVwIaea)LSY16rheOs)IEw5xHy8qAbF1QIKCQ4VYVA0ybJ0Uw)AkouHasLv9Cwrh4gBMqSYP(kMG9Q08RRcEXqLR1B24qheOsf0bbQWLGBSmQeRCQVIEWctak6P8dooYROhc7TlbHYVFfcJcPSxlracG)sw5A9OdcuPFr5w5xHy8qAbF1QIKCQ4VIhiV1PZag3hfWzcXQSGXDmJgbJ(JfWVbmUpkGZeIvzbdapKwWZO84XOCfJ(JfWVbmUpkGZeIvzbdapKwWxHasLv9CwXVlsgtvyFOIjyVkn)6QGxmu5A9Mno0bbQubDqGkC9Uim65RW(qf9GfMau0t5hCCKxrpe2BxccLF)kegfszVwIaea)LSY16rheOs)IYr5xHy8qAbF1QIKCQ4VYVA0ybJ0Uw)AkoWOrWOrYOK360z43fjJPkSpyChZOMxHasLv9Cwzcja7hCcQyc2RsZVUk4fdvUwVzJdDqGkvqheOcbHeG9dobv0dwycqrpLFWXrEf9qyVDjiu(9RqyuiL9Ajcqa8xYkxRhDqGk97xrIHKASkU48Qfx0tCt763c]] )

        storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170611.200523, [[dSZRjaGEQQO2KkIDPQABej2hr0mvrYSv08viDtfCBsTtvAVIDJy)sAueqdtf(nspNsFtf1GLy4uLoevvOtraogrDoQQKfsewkOAXGSCGhQQ4POwgvX6OQI8yQmvcAYQY0v6IQkDpIupJQk11POnsvvTvcXMPQSDfQttYFjuMMcX8OQkhwQXPIuJguEnfCscvFMcDnIKopH0LHoovvWbjqh5im8xsdnXxGcFBngMv6p1YxcSM4qnsw)uT4tnNiimCCITfZ1ZH85dPil)lhMDaL3nCybDRIsSryUYry4VKgAIViry2buE3WoynWiAfZhODRIs6zTiP01ICTCsTOBCAxav)7mbaKS1I)QfzphHfesnvROHbuNbi1IGWItEkxVuqycLGHhOprAWT1y4W3wJHHtDgGulccdhNyBXC9CiFw(imC0snbo0gHzd)bg6mmqhJAKSbk8a9DBngoBUEIWWFjn0eFrIWSdO8UHHm95733S14sjgnXFaQBfXwl(Rwg5)0HfesnvROH9nBnUuIrtmS4KNY1lfeMqjy4b6tKgCBngo8T1yy)pBnUuIrtmmCCITfZ1ZH8z5JWWrl1e4qBeMn8hyOZWaDmQrYgOWd03T1y4S563ry4VKgAIViry2buE3W6gN2fq1)otaajBT4pPRLrocliKAQwrddOodqQfbHfN8uUEPGWekbdpqFI0GBRXWHVTgddN6maPweulcuwaHHJtSTyUEoKplFegoAPMahAJWSH)adDggOJrns2afEG(UTgdNn3rIWWFjn0eFrIWSdO8UHfyTS9ej7Vd0wykIrXSlfO)rsdnXxTm6O1s7w1yumKGAfARfjLUw8ulcOwoPwEiKPpF)ydwyirmRxLb830BTCsTOBCAxav)7mbaKS1IKsxlJCewqi1uTIg2bAlmXMkJWwIIymS4KNY1lfeMqjy4b6tKgCBngo8T1y4pG2cRwoLYiSLOigddhNyBXC9CiFw(imC0snbo0gHzd)bg6mmqhJAKSbk8a9DBngoBUsncd)L0qt8fjcZoGY7gE7js2FyTAAxkq)JKgAIVA5KAbY0NVFFaQDHan59dqDRi2AXF1Yi)NUwoPw0noTlGQ)DMaas2ArYAzKJWccPMQv0W(au7cbAYlS4KNY1lfeMqjy4b6tKgCBngo8T1yy)dO2fc0Kxy44eBlMRNd5ZYhHHJwQjWH2imB4pWqNHb6yuJKnqHhOVBRXWzZvkry4VKgAIViry2buE3WJBGQHM4FBOveZV(btLxV4RwoPw8J1cKPpF)(au7cbAY730BTCsTOBCAxav)7mbaKS1IKsxlNLAybHut1kAyFaQDHan5fwCYt56LcctOem8a9jsdUTgdh(2AmS)bu7cbAYRweOSacdhNyBXC9CiFw(imC0snbo0gHzd)bg6mmqhJAKSbk8a9DBngoBUNJWWFjn0eFrIWSdO8UH1noTlGQ)DMaas2ArsPRfPi1WccPMQv0WwtYdbkIXWItEkxVuqycLGHhOprAWT1y4W3wJHztYdbkIXWWXj2wmxphYNLpcdhTutGdTry2WFGHodd0XOgjBGcpqF3wJHZM7PJWWFjn0eFrIWSdO8UH1noTlGQ)DMaas2ArsPRLZsTwgD0AXIRyquIP9Fviq2VeBeVUArYA5OwoPw0noTlGQ)DMaas2ArsPRLrocliKAQwrdp7XTyZ2clS4KNY1lfeMqjy4b6tKgCBngo8T1y4t1J7A5uTfwy44eBlMRNd5ZYhHHJwQjWH2imB4pWqNHb6yuJKnqHhOVBRXWzZ1VIWWFjn0eFrIWccPMQv0W(MTgxkXOjgwCYt56LcctOem8a9jsdUTgdh(2AmS)NTgxkXOjwlcuwaHHJtSTyUEoKplFegoAPMahAJWSH)adDggOJrns2afEG(UTgdNnx5Jim8xsdnXxKiSGqQPAfnmG6maPweewCYt56LcctOem8a9jsdUTgdh(2AmmCQZaKArqTiqpcimCCITfZ1ZH8z5JWWrl1e4qBeMn8hyOZWaDmQrYgOWd03T1y4S5klhHH)sAOj(IeHzhq5DdRBCAxav)7mbaKS1IKsxlsrQ1YOJwlBprY(7aTfMIyum7sb6FK0qt8vlJoAT0UvngfdjOwH2ArsPRfpHfesnvROHDG2ctSPYiSLOigdlo5PC9sbHjucgEG(ePb3wJHdFBng(dOTWQLtPmcBjkIXArGYcimCCITfZ1ZH8z5JWWrl1e4qBeMn8hyOZWaDmQrYgOWd03T1y4SzdZErNQNk)CVkkjxpsXVZMa]] )

        storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170611.200523, [[d0tMhaGEIu0Mis2frTnKi7JiLMjsuz2uz(ePYnb45I62k8neYobAVs7wL9tvJIuKggIACirPhRK7rKcdwKHJKoic1PifQJPOonjluryPiLfRulNWdbuRIuelJu16qIQoSWujIjtX0v1frcVIuGldDDk1grG2kPKntjBhbnpeWxrIIPrkOVRi61KkpJivnAe5qKI6KKs9zKQRrkKZdipf1FvK(nO7CLuMIl2o00DzWyGLz1ayFIIJuClCG3t59PTTLvUmn0HrglOEYZerMsZZYZL5Lqr9lxM41RGxUsk4CLuMIl2o00jkZlHI6x(dhEVSlot2PmOmEX2HgFskFABBzj7IZKDkdklWrOUSpraPHprUmXBLt9avwax62QhfL1(mQv8qr5dEyzaqJwHamgy5YGXaltdU0TvpkktdDyKXcQN8mrZKltdZqBXcZvs)Yatcx6aajeh49Dxga0agdSC)cQVsktXfBhA6eL5Lqr9lRzF6vlDQJUpjLpnc0LFbCiVSfc8EFsA9j96lt8w5upqLTSfanfAnnuIYAFg1kEOO8bpSmaOrRqagdSCzWyGLjOTaiFcA5teReLPHomYyb1tEMOzYLPHzOTyH5kPFzGjHlDaGeId8(UldaAaJbwUFbL(kPmfxSDOPtuMxcf1VCiELvSE5WrLumDsOZsweNoFsA9jY(Ku(evbs4u6lJ8SSfkc30mvLq9LjERCQhOYlrKjn1POt6p1rVS2NrTIhkkFWdldaA0keGXalxgmgyzGfrMKpr5u0j9N6OxMg6WiJfup5zIMjxMgMH2IfMRK(LbMeU0basioW77UmaObmgy5(fudRKYuCX2HMorzEjuu)YA2N22wwYwUyGp8OBJY2ult8w5upqLTCXaF4r3glR9zuR4HIYh8WYaGgTcbymWYLbJbwMGUyGp8OBJLPHomYyb1tEMOzYLPHzOTyH5kPFzGjHlDaGeId8(UldaAaJbwUFb1OkPmfxSDOPtuMxcf1V8ho8EzsHYLFOyiJxSDOXNKYN0SpTTTSKTeW8VfXzKTP6ts5tegcvSDOSLTaiGjHlDAOgvM4TYPEGkBjG5FlIZuw7ZOwXdfLp4HLbanAfcWyGLldgdSmbfW8VfXzktdDyKXcQN8mrZKltdZqBXcZvs)Yatcx6aajeh49Dxga0agdSC)csPkPmfxSDOPtuMxcf1V822Ys2Yfd8HhDBuwGJqDzFIa(eL8jnWNOVm(Ku(0ccDg4KNSbchtNuDMSSahH6Y(eb8j6lJpPj(K(YeVvo1duzlxmWhE0TXYAFg1kEOO8bpSmaOrRqagdSCzWyGLjOlg4dp62OpPPZACzAOdJmwq9KNjAMCzAygAlwyUs6xgys4shaiH4aVV7YaGgWyGL7xqIQKYuCX2HMorzEjuu)YF4W7Ljfkx(HIHmEX2HgFskFABBzjBjG5FlIZilWrOUSpraFIs(Kg4t0xgFskFAbHodCYt2aHJPtQotwwGJqDzFIa(e9LXN0eFsFzI3kN6bQSLaM)TiotzTpJAfpuu(Ghwga0OviaJbwUmymWYeuaZ)weNXN00znUmn0HrglOEYZentUmnmdTflmxj9ldmjCPdaKqCG33DzaqdymWY9liLTsktXfBhA6eL5Lqr9lBWTTLLmgINeEtZuv6qzBQ(Ku(0ho8Ezmepj8MMPQ0HY4fBhA8jPt68jn7tF4W7LXq8KWBAMQshkJxSDOPmXBLt9avEs1zYWJEzTpJAfpuu(Ghwga0OviaJbwUmymWYug1zYWJEzAOdJmwq9KNjAMCzAygAlwyUs6xgys4shaiH4aVV7YaGgWyGL73VmtfxQWPKMXRGxb1tjPVFl]] )        

    end

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170409.204707, [[d4ZSoaGEePsBcrSlqTnQu7ts0mru1Jjz2OA(scDtjvCyHVjPCBj2js2RYUvz)KsJssvdJQACiQ05jfNgyWKQgUQYbLKoLQGJHuNtsqlKcTuvrlgHLtPhIiLNsSmvvpxuterQyQujtgKPl1fPOEfIu1LHUUi2OKk9zkyZuX2ru(lv57QszAscmpejpJu5qiQy0I04vfQCsvjVMICnvHY9uLQvQku1Vr54Qc5rpxtmFbbhHMXjurbNiMjVw9M5ybVo4A1xnRWdkofor(qfi4as3ObSBu)U)N8e5yKXr97txZVc8)HP)15xb6Mikl4RNmPQQbSlpxJIEUMy(ccocnJteLf81tAMbdCewXyCi2BxMeiwd7WJc6LtzktWwSeGlxjrIJdCKv4bfNcHHsSrdyhjkgJdXE7G5bzHhrIn3WwSeGlxPpjKdrIJdCUz2Ije)qlCY3KQeaoO1mjYk8GItHtEDqav0m7KJD4KNihJmoQFFA301G91nHkk4KQzfEqXPW1J6FUMy(ccocnJtQt84aLKIRWAa78eDteLf81tiNgOmbodtQsa4GwZehEuqVCktzAYRdcOIMzNCSdNqffCsD5rb1Qxszkttinnko6kSgWopIjprogzCu)(0UPRb7RBIKYERomiGdaT5rSEu6MRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57)(KyXsaUmPENiXXboYk8GItHWqj2ObSJefJXHyVDWrwHhuCke2ILaCzsprIJdCKv4bfNcHHsSrdyhPEhkXgnGDtQsa4GwZehEuqVCktzAYRdcOIMzNCSdNqffCsD5rb1QxszktA1xp9dtEICmY4O(9PDtxd2x36rvbZ1eZxqWrOzCIOSGVEcrIJdmQszy2J541PONblgTxo5Gql4maN8rc5qK44ahzfEqXPq4KpskbYZTLvGvjwlEDLVtUU1(4N8e5yKXr97t7MUgSVUjVoiGkAMDYXoCsvcah0AMGHTtFusycNqffCI5W2PpkjmHRh1JnxtmFbbhHMXjIYc(6jLa552YkWQeRfVUY3RWFsihIehh4iRWdkofcN8n5jYXiJJ63N2nDnyFDtEDqav0m7KJD4KQeaoO1mbdBN6LtzkttOIcoXCy7uT6LuMY06r5EUMy(ccocnJteLf81tAMbdCeoSnWjuTxqa4GwZKQeaoO1mj3mBXeIFODYtKJrgh1VpTB6AW(6MiPS3Qddc4aqBEetOIcorAMTycXp0o51bburZSto2HRhvT5AI5li4i0moruwWxpzYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjvjaCqRzcYXcEDW9i4rUNqffCIzowWRdUw9g5rUxpkYDUMy(ccocnJteLf81tcvdid9Wdlamx576MuLaWbTMjCWJsaqELWqj8AwJLjVoiGkAMDYXoCYtKJrgh1VpTB6AW(6MqffCc5bpkbaPvFDcdLqRExSglRhvfoxtmFbbhHMXjIYc(6jejooWFS3qRhZXRtrVsG8CBzf4KpsisCCGZnZwmH4hAHt(ijunGm0dpSaWmP0n5jYXiJJ63N2nDnyFDtEDqav0m7KJD4KQeaoO1mHdmK2h4m4rW49eQOGtipWqAFGZGw9gz8E9OO9NRjMVGGJqZ4erzbF9eiwd7WJc6LtzktWwSeGlxPkYTxdkij1Rymoe7TZZIHQRyfjsCCGJScpO4uiCY3dtEICmY4O(9PDtxd2x3KxheqfnZo5yhoPkbGdAnt4bzHhrIn3tOIcoH8bzHw9gtS5E9OOPNRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57)(KqK44aJCSGxhCphMkjdN8rIfDSyoni44KQeaoO1mXHhf0lNYuMM86GaQOz2jh7WjprogzCu)(0UPRb7RBcvuWj1LhfuREjLPmPvF9)pSEu0)Z1eZxqWrOzCIOSGVEsjqEUTScSkXAXRR89FFsisCCGrowWRdUNdtLKHt(ijunGm0dI1Wo8OGE5uMYePQpunGm0dpSaWmPExhjHQbKHE4HfaMRyf19WKNihJmoQFFA301G91n51bburZStuAuCCcvuWj1LhfuREjLPmPvpPPrXXjvjaCqRzIdpkOxoLPmTEu06MRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57KR7jprogzCu)(0UPRb7RBYRdcOIMzNCSdNuLaWbTMjyy7uVCktzAcvuWjMdBNQvVKYuM0QVE6hwpk6kyUMy(ccocnJteLf81tisCCGBwJfVsKB0Qb2ILaCzsr7xXkwprIJdCZAS4vICJwnWwSeGltkIehh4iRWdkofcdLyJgWosVIX4qS3o4iRWdkofcBXsaUmjkgJdXE7GJScpO4uiSflb4YKI(XEyYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjurbN4I1yrR(6e5gTAMuLaWbTMjnRXIxjYnA1SEu0p2CnX8feCeAgNikl4RNqK44aJQugM9yoEDk6zWIr7Ltoi0codWjFtQsa4GwZemSD6Jsct4KxheqfnZo5yho5jYXiJJ63N2nDnyFDtOIcoXCy70hLeMqT6RN(H1JI29CnX8feCeAgNikl4RNeQgqg6HhwayUs6jprogzCu)(0UPRb7RBYRdcOIMzNCSdNuLaWbTMj8GSWJaJYeQOGtiFqwOvVrmkRhfDT5AI5li4i0moruwWxpHiXXb(J9gA9yoEDk6vcKNBlRaN8rsOAazOhEybGzsPBYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjvjaCqRzchyiTpWzWJGX7jurbNqEGH0(aNbT6nY4Tw91t)W6rrtUZ1eZxqWrOzCIOSGVEsOAazOhEybG5kPN8e5yKXr97t7MUgSVUjVoiGkAMDYXoCsvcah0AMOsdW5Xbgs7dCgMqffCcPLgGtREYdmK2h4mSEu0v4CnX8feCeAgNikl4RNm5jYXiJJ63N2nDnyFDtEDqav0m7KJD4eQOGtipWqAFGZGw9gz8wR(6)Fysvcah0AMWbgs7dCg8iy8E9O(9NRjMVGGJqZ4erzbF9KcJmWzGel6yXCAqWXjprogzCu)(0UPRb7RBYRdcOIMzNCSdNqffCsD5rb1QxszktA1xVUhMuLaWbTMjo8OGE5uMY06r9tpxtmFbbhHMXjVoiGkAMDIsJIJteLf81tcvdid9WdlamxjnjHQbKHEqSg2Hhf0lNYuMivOAazOhEybG5jKMgfhDfwdyNhXKQeaoO1mXHhf0lNYuMMiPS3Qddc4aqBEgNqffCsD5rb1QxszktA1xpPPrXrT6)FyYtKJrgh1VpTB6AW(6wpQ))5AI5li4i0moHkk4eZHTt1QxszktA1x))dtEICmY4O(9PDtxd2x3KxheqfnZo5yhoPkbGdAntWW2PE5uMY0erzbF9KcJmWzy96jKoOtKW7zC9ga]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170409.204707, [[daKEoaqiiPuBII0Oqv5uOQAvqsjVcskAxeAyuvhdvwMk6ze00GKQRjueBJI6Bc04ujLZPscZJIO7Ps0(ujCqHQfsHEOkPAIQKOUifSrkcNufSsHI6LQKiZuOWnHKStuSuvONImvbSxP)kObtGdR0IrPhtPjtLUmyZuLpJQmAQ40Q61qy2K62kA3q9BsgUk1Xfkz5e9CfMUORlKTdj(UkjnEiPW5HO1luKMVqP2pK6Y1aLmGxwn4wJLiR8VZsLUYG3gPZAS0rqd7akZPpxqFu3)uK7uOpQlSeDd2F1FmDZxHlZP5ZsXT5RWJgOmCnqjd4LvdU1yjYk)7SeQD(wepMxP4SV(tKL807echoklIshWUVDtLSewHHshbnSdOmN(CM5ck6lSeZoHsMqVtaTaYrzrGwaF(83SmNnqjd4LvdU1yjYk)7SeBKNNiyDuWiu5fMoqipjSz4ic7cYhZtm6205c6rkvtrBKuc48IlVM5shbnSdOmN(CM5ck6lS0bS7B3ujlHvyOeZoHsgwz6eROfbuko7R)ezjyLPtSIweqZYiSbkzaVSAWTglrw5FNLyJ88eFl4fjrkgDB6Cb9iLQPOnskbCEXLxZCP4SV(tKL8KQrgoCuweLoGDF7MkzjScdLocAyhqzo95mZfu0xyjMDcLmHuns0cihLfrZYG6nqjd4LvdU1yjYk)7S0Cb9iLQPOnskbCEXLxXj6yU0rqd7akZPpNzUGI(clDa7(2nvYsyfgkXStOKHvMoOfqoklIsXzF9NilbRmDchoklIMLjM0aLmGxwn4wJLy2juIsLCIaGBqwko7R)ezPrQKteaCdYshWUVDtLSewHHsKv(3zPuXJNgexz(ERndx2x)jst5BT5Jcecyy(W4cUyh7bK5J5nexE8KWy8OaHJujNia4gK8x6iOHDaL50NZmxqrFHnlJ5gOKb8YQb3ASezL)DwQ0rqd7akZPpNzUGI(clDa7(2nvYsyfgkXStOKbnmbCUA0cmQ3rwko7R)ezjqdtaNRoKvVJSzzc2aLmGxwn4wJLiR8VZsZf0JuQMI2iPeWPjVmO5sXzF9Nil9wWlsIS0bS7B3ujlHvyO0rqd7akZPpNzUGI(clXStO0bl4fjr2SmxRbkzaVSAWTglrw5FNLwB(OaHagMpmU4sHLIZ(6prws)Xk6DdNlV5gMQeMLoGDF7MkzjScdLy2jukgFSIEx0cq1YBUOfeqLWS0rqd7akZPpNzUGI(cBwMRObkzaVSAWTglrw5FNLyJ88eVvxfKHkVW0bcNlOhPunfJUnLnYZtCKk5eba3Gum6201MpkqiGH5ddtkSuC2x)jYs6NNtIFmVqwLolDa7(2nvYsyfgkDe0WoGYC6ZzMlOOVWsm7ekfJNNtIFmp0cmQ0jAb8rxj(Bwgo)gOKb8YQb3ASezL)DwYvLIE6DcHdhLfHOeM7Jhxy3rgM)eqhZLocAyhqzo95mZfu0xyPdy33UPswcRWqjMDcLIXIYIwGXi5ilfN91FISKErzdzJKJSzz44AGsgWlRgCRXsKv(3zj2ippX3cErsKIr3MY3Cb9iLQPOnskbCEXLN(Xo2SrEEIVf8IKifLWCF8WK8XZ6IAXg55j(wWlsIuCKRfbQjh)8xko7R)ezjpPAKHdhLfrPdy33UPswcRWqPJGg2buMtFoZCbf9fwIzNqjtivJeTaYrzrGwaFC83SmCNnqjd4LvdU1yjuTOg)mAgyL8GCusyjYk)7S0Cb9iLQPOnskbCEXLN(MYg55jcAyc4C1HEkB0qm62uj4jHHZYQb0XCP4SV(tKL807echoklIshWUVDtLSewHHsm7ekzc9ob0cihLfrPRJ0QHaRKhKJYw6iOHDaL50NZmxqrFHLih1vrLY99EqokBZYWjSbkzaVSAWTglrw5FNLMlOhPunfTrsjGZlU803u2ipprqdtaNRo0tzJgIr3MYhFRnFuGqadZhgxEA6AZhfi0vLIE6DcHdhLfHjp5p2XMV1MpkqiGH5dJlUuOPRnFuGqxvk6P3jeoCuweMui)8xko7R)ezjp9oHWHJYIO0bS7B3ujlzrA1qjMDcLmHENaAbKJYIaTa(44V0rqd7akZPpNzUGI(cBwgouVbkzaVSAWTglrw5FNLyJ88eFl4fjrkgDxko7R)ezjpPAKHdhLfrPdy33UPswcRWqjuPq5X8kdxjMDcLmHuns0cihLfbAb8DYFPJGg2buMtFoZCbf9fwICuxfvk337b5OglDDhWIavkuGjGZASzz4Ijnqjd4LvdU1yjYk)7S0Cb9iLQPOnskbCEXLxZCP4SV(tKLGvMoHdhLfrPdy33UPswcRWqjMDcLmSY0bTaYrzrGwaFC8x6iOHDaL50NZmxqrFHnldN5gOKb8YQb3ASezL)DwInYZtucdfEXwimvjmfLWCF8WKC(LocAyhqzo95mZfu0xyPdy33UPswcRWqP4SV(tKLsvcZW5osqISeZoHsbujmrlav7ibjYMLHlyduYaEz1GBnwISY)olXg55jcwhfmcvEHPdeYtcBgoIWUG8X8eJUlDe0WoGYC6ZzMlOOVWshWUVDtLSewHHsXzF9NilbRmDIv0IakXStOKHvMoXkAraOfWhh)nld31AGsgWlRgCRXsm7ekfJNNtIFmp0cmQ0zPJGg2buMtFoZCbf9fw6a29TBQKLWkmuISY)olXg55jERUkidvEHPdeoxqpsPAkgDB6AZhfieWW8HHjfwko7R)ezj9ZZjXpMxiRsNnld3v0aLmGxwn4wJLiR8VZsRnFuGqadZhgxWv6iOHDaL50NZmxqrFHLoGDF7MkzjScdLIZ(6prwY6Spou)8Cs8J5vIzNqPR7SpgTGy88Cs8J51SmN(nqjd4LvdU1yjYk)7SuP4SV(tKL0ppNe)yEHSkDw6a29TBQKLWkmuIzNqPy88Cs8J5HwGrLorlGpo(lfxYBuQ0rqd7akZPpNzUGI(clroQRIkL779GCu2sx3bSiqLcfyc4SSnlZjxduYaEz1GBnwISY)olnvO8yEMkbpjmCwwnu6iOHDaL50NZmxqrFHLoGDF7MkzjScdLy2juYe6DcOfqoklc0c47K)sXzF9Nil5P3jeoCuwenlZ5zduYaEz1GBnwISY)olnvO8yEMU28rbcDvPONENq4WrzryY1MpkqiGH5dJshbnSdOmN(CM5ck6lS0bS7B3ujlzrA1qP4SV(tKL807echoklIsm7ekzc9ob0cihLfbAb8DYpAbxhPvdnlZPWgOKb8YQb3ASezL)DwAQq5X8kDe0WoGYC6ZzMlOOVWshWUVDtLSewHHsXzF9NilbRmDchoklIsm7ekzyLPdAbKJYIaTa(o5VzZsm7ekrgIbAbg0WeW5Qrl4Gf8IKiB2c]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170409.204707, [[d0dsoaGEqI0MaP2ffTnrY(ePAMQenBeZhvLCtvc(MO42Q4WsTtuzVk7gy)QQgfjXWeXVj1ZiPopQYGbvdhuoOOQtrs6yi54IuAHuWsfvwmkwov9quv1tjwMQYZvLjQsOmvQOjJutx4IuOtl5YqxheBeKWHujuTzvQTlknnuv03fP4ZuP5bs6Xu6VO0OjX4bjItQsACOQuxdKOUhQQSsuv4CQeYRPcpQ5CIrqZqq6zyYfdVBiKygMW1hCIy8YF4gj4bbrt(HFzUj5qc2pCCFjuzs4ZKptQp1j8P6jcm0wnPGs7O0GX9L6BsEBuAWBohh1CoXiOzii9mmrS(cwm5IhL1rbCNKNPivWBYnPpi7trBDm5kGUSDO9taAaojhsW(HJ7lHkfvgZe1t46dobki9b)HlkARJF4QKO6IX9nNtmcAgcspdteRVGftyGCFBIwfn(y13SHcY66XoyFqa0OVaUMqGb9PrYl86JPfI3JGiD(X3PMKdjy)WX9LqLIkJzI6jxb0LTdTFcqdWjC9bNyS9HsAH0oWj5zksf8MGTpuslK2bUyCQNZjgbndbPNHjI1xWIjNgjVWRpMwiEpcI053f99ZhtYHeSF44(sOsrLXmr9KRa6Y2H2pbOb4eU(Gtm2(q5hUOOToMKNPivWBc2(qH9POTowmo(CoNye0meKEgMW1hCIeA)XbIWq)K8mfPcEtEH2FCGim0p5kGUSDO9taAaorS(cwmj0UUe0S9rD32GTzksf8GwL2gvwKfb4PWx6u8fF9WikG7ZSDD947vzr2xO9hhicd9QojhsW(HJ7lHkfvgZe1lghuEoNye0meKEgMiwFblMmjhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46doXibpiiAYpCdK(ftYZuKk4nbj4bbrtyzi9lwmUuZ5eJGMHG0ZWeX6lyXK2gvwKfb4PWx68t9K8mfPcEtivAHu0SN290SHoWZKRa6Y2H2pbOb4eU(GtUSslKI(h(fA3t)d3PoWZKCib7hoUVeQuuzmtuVyCzMZjgbndbPNHjI1xWIj06W8M0hK9POTom94PlWlDB)c2Oo4pFmjhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46do5YoB)d3ae)lMKNPivWBcPZ2Smq8VyX4475CIrqZqq6zyYfAOK6a54S9Uy8MOEIy9fSyYPrYl86JPfI3JGiD(9LandK7BtKGheenH9wBH8mHadApE7XNsZqWF(ysEMIubVj3K(GSpfT1XKRa6Y2H2pbOb4eU(GtGcsFWF4II26yc)5zjOZ27IXBmtYHeSF44(sOsrLXmr9errNMlOPR7c9VXSyCx0CoXiOzii9mmrS(cwm50i5fE9X0cX7rqKo)(sGMbY9TjsWdcIMWERTqEMqGbTkQ02OYISiapf(43h0TnQSilTomVj9bzFkARdO(PkFXxQ02OYISiapf(sNFQHUTrLfzP1H5nPpi7trBDav1QQ6K8mfPcEtUj9bzFkARJjxb0LTdTFILNLGt46dobki9b)HlkARJF4QqP6KCib7hoUVeQuuzmtuVyCujZ5eJGMHG0ZWeX6lyXKtJKx41htleVhbr68JVtnjptrQG3eS9Hc7trBDm5kGUSDO9taAaoHRp4eJTpu(HlkARJF4QqP6KCib7hoUVeQuuzmtuVyCuuZ5eJGMHG0ZWeX6lyXegi33ME8PbnWISHoWJPhpDbEqLkzsoKG9dh3xcvkQmMjQNCfqx2o0(janaNKNPivWBsOd8WE6xGEEt46doXPoWZp8l0Va98wmoQV5CIrqZqq6zyIy9fSycdK7Bt0QOXhR(Mnuqwxp2b7dcGg9fW1ecSj5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjy7dL0cPDGt46doXy7dL0cPDG)WvHs1fJJs9CoXiOzii9mmHRp4KllxLaua3F4g0KysoKG9dh3xcvkQmMjQNCfqx2o0(janaNiwFblMWa5(2eMonONvFZgki7PrYl86Jjeyq32OYISiapf(GQAOPrgi33MKYvjafWL1RPnP1PbmjptrQG3es5QeGc4YYOjXIXrXNZ5eJGMHG0ZWeX6lyXegi33MW0Pb9S6B2qbzpnsEHxFmHad62gvwKfb4PWhuvdDBJklYsRdZBsFq2NI26aQFtYHeSF44(sOsrLXmr9KRa6Y2H2pXYZsWjC9bNCz5QeGc4(d3GMe)WvH)8Seu1j5zksf8MqkxLauaxwgnjwmokO8CoXiOzii9mmrS(cwmPTrLfzraEk8Lof00idK7Bts5QeGc4Y610M060a(5Jj5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjwLUaSKYvjafWDcxFWj8xPlWp8llxLaua3fJJk1CoXiOzii9mmrS(cwmPTrLfzraEk8Lof0mqUVnjLRsakGlRxtBcbg0TnQSilTomjLRsakGlRxtd12gvwKfb4PW3K8mfPcEtSkDbyjLRsakG7KRa6Y2H2pXYZsWj5qc2pCCFjuPOYyMOEcxFWj8xPlWp8llxLaua3F4QWFEwcQ6IXrLzoNye0meKEgMiwFblMqJmqUVnjLRsakGlRxtBsRtdysEMIubVjKYvjafWLLrtIjxb0LTdTFcqdWjC9bNCz5QeGc4(d3GMe)WvHs1j59UVjtYHeSF44(sOsrLXmr9errNMlOPR7c9VXmH)kO1Xf0zXdcIXSyCu89CoXiOzii9mmrS(cwmPTrLfzraEk8Lof0TnQSilTomjLRsakGlRxtd12gvwKfb4PW3KCib7hoUVeQuuzmtup5kGUSDO9tS8SeCsEMIubVjKYvjafWLLrtIjC9bNCz5QeGc4(d3GMe)WvHs1F48NNLGlgh1fnNtmcAgcspdteRVGftMKdjy)WX9LqLIkJzI6jxb0LTdTFcqdWj5zksf8MqkxLauaxwgnjMW1hCYLLRsakG7pCdAs8dxLpvxmUVK5CIrqZqq6zyIy9fSyYrNTaUq7XBp(uAgcojhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46dobki9b)HlkARJF4Q8P6K8mfPcEtUj9bzFkARJfJ7JAoNye0meKEgMiwFblMC0zlGl0TnQSilTomVj9bzFkARdO22OYISiapf(MKdjy)WX9LqLIkJzI6jxb0LTdTFILNLGtYZuKk4n5M0hK9POToMW1hCcuq6d(dxu0wh)Wv5t1F48NNLGlg333CoXiOzii9mmrS(cwm5OZwa3j5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjy7df2NI26ycxFWjgBFO8dxu0wh)Wv5t1flMiwFblMSyda]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170415.105057, [[d0t0haGEcvQnrQuTlc2Mk0(urLzkaZwP5tOCtb03iLUnkoSIDQQ2R0UPSFvPFsOkdJK(nQEUknuvuvdgIgoeoir5ueQKJrIZrujlKuSuuQftKLtLxtufpf5Xu16ivYejQOPsQAYcnDrxuqNgQldUoKSrIQ0NjKnlqBNuP8DsfFLqfnnvuAEev4VOKdPIIrtuvJJqvDsvWZurUgrL68QIvQIQSmi1OiuHRs1xk0gPfIvtP)WaLOWaErgUady5SViLti4GAZsYjeCqTz1uInSWCH(rRQOv9SQYLaA1ZQvvBjY7WiYsLK5tm3UvF)kvFPqBKwiwnLiVdJilLCrIwqaBj4COqK3sYKWloFkPd2ISUYhgxPdwe7NK7kzCdk9hgOK4eBXxKK8HXvInSWCH(rRQOvrTz)OR(sH2iTqSAk9hgO05Ztm3krEhgrwk5IeTGacEI52v3fhNj5IeTGGNZ3ixh7kMyEoFJCDmHGyhWcwGbSCwbhWmy7Eo0IVQ4QeByH5c9Jwv5OIwb1tLoyrSFsURKXnOKmj8IZNsi4jMBLcKh)dducHJVCteezHGRd4A2)PQVuOnsleRMsK3HrKLKqfmOqYtGHfZCtW9i4aMbBx5aDjzs4fNpLsEcmSyMBcUNshSi2pj3vY4guInSWCH(rRQCurRG6Ps)HbkPNNaZlYaNBcUNM9F2QVuOnsleRMsK3HrKLsUirli458nY1XULydlmxOF0Qkhv0kOEQ0blI9tYDLmUbLKjHxC(uki2bSGfyalNT0FyGsYl2bVidxGbSC2M9l3vFPqBKwiwnLiVdJilLCrIwqWZ5BKRJDlXgwyUq)OvvoQOvq9uPdwe7NK7kzCdkjtcV48P0n5ogwWcmGLZw6pmqjk5oMxKHlWawoBZ(pw9LcTrAHy1uI8omISuYfjAbbpNVrUo2TKmj8IZNsWcmGLZYIzUj4EkDWIy)KCxjJBqP)WaLcxGbSC2xKbo3eCpLydlmxOF0Qkhv0kOEQz)AR(sH2iTqSAkrEhgrw6m5SGLcZ1dwCmpia2iTqumXKqfmOWC9GfhZdcOqiMyEoFJCDmH56bloMheCaZGT75KB1sSHfMl0pAvLJkAfupv6GfX(j5Usg3GsYKWloFkjTCEKvquUNs)HbkPz584ls5fL7Pz)IF1xk0gPfIvtjY7WiYsNjNfSuyUEWIJ5bbWgPfIIjMeQGbfMRhS4yEqafIsSHfMl0pAvLJkAfupv6GfX(j5Usg3GsYKWloFkjbUl4KhSjQ0FyGsAa3fCYd2e1SF5Q6lfAJ0cXQPe5DyezPXNyDdybgWGH75qx6pmqj2OmD9IuM4fwsMeEX5tjhkJ14tm3yT4Bw6GfX(j5Usg3GsSHfMl0pAvLJkAfupvkqE8pmqjkmGxKHlWawo7lszIxyZ(vuR(sH2iTqSAk9hgOeBuMUErk76bloMhkrEhgrwkNfSuyUEWIJ5bbWgPfIIj2c6gSYHIIAj2WcZf6hTQYrfTcQNkDWIy)KCxjJBqjzs4fNpLCOmwJpXCJ1IVzPa5X)WaLOWaErgUady5SViLD9GfhZdn7xrP6lfAJ0cXQP0FyGsSrz66f5bpeeL7Pe5DyezPCwWsbShcIY9ia2iTq898kXgwyUq)OvvoQOvq9uPdwe7NK7kzCdkjtcV48PKdLXA8jMBSw8nlfip(hgOefgWlYWfyalN9f5bpeeL7Pz)kOR(sH2iTqSAk9hgOeBuMUErgawK8tdBIErYMhlrEhgrwkNfSuyXIKFAytelhpka2iTqSeByH5c9Jwv5OIwb1tLoyrSFsURKXnOKmj8IZNsougRXNyUXAX3SuG84FyGsuyaVidxGbSC2xKbWUzZsecWJNflUNeZT(rFeDZw]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170409.204707, [[dSZ(iaGEskPnPOYUKKTjPAFKuQzkvvZgv3ekUnfpMs7uv2Ry3QSFsv)KKsmmjACsvPomvFtQYGjfdxkCqsYPiPIJrKZbLsTquQLQOSyOA5QQhkf9uKLruEokMiukzQsOjRW0v6IevNxcUm46KsBekfNgYMLu2Uu61OKVtsvtJKI5bLQNrQ8zPYOjXFvKtcLCifv5Asvj3trv9BchxQkgfjv6iLIHKFoohgHDONBGqK8(1RrohmWToxVgvQf5Hi7h1ydfAgWbNbYtwPuVs1ukRssMUs1Ole1aSiNJuR(IexEYQllKk7IehtkMNukgs(54Cye2HEUbcrR4Bybqd4hAgWbNbYtwPuDPEvL6cPchXrBHqmR4Bybqd4hcRBGS(k(HoXbHAQawwyeTGbUn4HWigp3aHYMNSumK8ZX5WiSdr2pQXgAfDDCOYke8Hq9htONBGqQySWn8ZcHMbCWzG8KvkvxQxvPUqQWrC0wiKZyHB4NfcH1nqwFf)qN4GqnvallmIwWa3g8qyeJNBGqzZtxkgs(54Cye2HEUbc1pQpArd9AW4DgxVMIIfmHMbCWzG8KvkvxQxvPUqQWrC0wieh1hTOXKX7m(0kwWecRBGS(k(HoXbHAQawwyeTGbUn4HWigp3aHYMNAsXqYphNdJWoez)OgBiJdCM9lmvwT)pCRApFzLZnV15WTvCuNYEORB6lgvW54Cym3hQ9bgfhNdHuHJ4OTqOAC3atmkclRqnvallmIwWa3g8qp3aHWgUBa9AifHLvOzahCgipzLs1L6vvQlePiupgXavdbFMGhcRBGS(k(HoXbHWigp3aHYMxFLIHKFoohgHDiY(rn2qUDrTWeCGbbmyxnZ52f1ctdXwvJ7gyIrryzHD3UOwycoWGaMqQWrC0wiunUBGjgfHLviSUbY6R4hYwWYHqZao4mqEYkLQl1RQuxONBGqyd3nGEnKIWYsVMMfSCiBE1tXqYphNdJWo0Znqi5(Fv6JwNfeAgWbNbYtwPuDPEvL6cPchXrBHqG)xL(O1zbHW6giRVIFOtCqOMkGLfgrlyGBdEimIXZnqOS51lfdj)CComc7qK9JASHgITQg3nWeJIWYQ6dghDmQT1z2PfzG5W1wRwf3B9jgT)oOsBJ5M36C42koQtzp01n9fJk4CComMZTlQfMGdmiGb7Qj0ZnqO(9wxVg2A)mBOzahCgipzLs1L6vvQlKkCehTfcX9wFcx7NzdH1nqwFf)qN4GqnvallmIwWa3g8qyeJNBGqzZRVtXqYphNdJWoez)OgBO5TohUTIJ6u2dDDtFXOcohNdJ5C7IAHj4adcyWEFf65giKCoyGBDUEnS5oZgAgWbNbYtwPuDPEvL6cPchXrBHqahmWToFcN7mBiSUbY6R4h6eheQPcyzHr0cg42GhcJy8CdekBEy7umK8ZX5WiSd9CdeQFV11RHn4MqZao4mqEYkLQl1RQuxiv4ioAleI7T(eo4MqyDdK1xXp0joiutfWYcJOfmWTbpegX45giu28KktXqYphNdJWo0ZnqOMko60RPFuNYEORlez)OgBObGRTwTkoQtzp01n9fJQHq9xOzahCgipzLs1L6vvQlKkCehTfczvC0nXrDk7HUUqyDdK1xXp0joiutfWYcJOfmWTbpegX45giu28KKsXqYphNdJWoez)OgBi3UOwyAi2koQtzp01n9fdS72f1ctWbgeWeAgWbNbYtwPuDPEvL6cH1nqwFf)q2cwoesfoIJ2cHSko6M4OoL9qxxONBGqnvC0Pxt)OoL9qxNEnnly5q28KKLIHKFoohgHDiY(rn2q4ARvRI7T(eJ2FhuPTriv4ioAleI7T(eU2pZgcRBGS(k(HoXbHWiArxxiPqp3aH63BD9AyR9ZS61OUsQtiv)oMqgrl66MVuOzahCgipzLs1L6vvQlePiupgXavdbFMWoutfWYcJOfmWTHDimIXZnqOS5jPlfdj)CComc7qK9JASH(qTpWO44CiKkCehTfcvJ7gyIrryzfcRBGS(k(HoXbHWiArxxiPqp3aHWgUBa9AifHLLEnQRK6es1VJjKr0IUU5lfAgWbNbYtwPuDPEvL6c1ubSSWiAbdCByhcJy8CdekB2qylOMRLVHD2ea]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170409.204707, [[datncaGErO2fs12ePMPiWSP0nfv3Mk7uI9s2nI9djnmk8Bvnurudgs1WvHdIsDmuzHOWsfflgjlxslsu6PGLrrphvnrKsMku1KvPPlCrOYLvUUiKnlcA7ifhwQPjI8nrYJH48QOrdP8mO0jHeFgLCAQ6EiL6VqHhcf9Au0It4fGJ0u2Dfdb0AjStKnedbL2nbaUeGk64SZns0wurp56qEhvhcYm7A(PIPbxkJKmmPZzI1ijScGJH4BRpXD4FIkMPnfWgj8pHx4vHt4fGJ0u2Dfdbas1FecINfl7OF8H)j8cyt5T(4uWXh(NiafY1J0XxfqEYeuA3eK8h(NiGDLfVas7gTZExFTNyWQ2ilRGmZUMFQyAWLMlfDdScWeTHWm)PzUrcrji)VL2nbzVRV2tmyvBKLvHkMcVaCKMYURyiO0Uja)hZHk65nFS6PGmZUMFQyAWLMlfDdScyt5T(4uq8XCy4A(y1tbOqUEKo(QaYtMamrBimZFAMBKqucY)BPDtGcvWk8cWrAk7UIHGs7Mai(QJ52XQcYm7A(PIPbxAUu0nWkGnL36Jtb8XxDm3owvakKRhPJVkG8Kjat0gcZ8NM5gjeLG8)wA3eOqHaaP6pcbkKaa]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170611.205117, [[deKzmaqiOkYIisSjLenkOQCkOQAxqLHbjhdIwgr5zkj10eIY1usyBej13qPACqvuNdQcADqqZJij3tjj7tiYbjPwik4HcLjcvHCrIQncvjgjuf4KKeZeQsDtLyNq5NqvsdfQc1srjpfzQeXwjj9vHOQ9k9xH0GP4WkwmjEmvnzL6YQ2mrQpJIgne60eEnkLzJQBtQDd8BqdxOA5cEovMUORdP2ok03HaNxj16fIkZxiSFkDrwjLKdgf(3LHsyJ(LiHoM1iNF9b5WrO1SV0dAEwcp6spO5zzOeRZ)4EXKHcj7OImzRaNmKr2QxTSsKpiINLkP2NciWvjfdzLusoyu4FxLsKpiINLsitM8JZdH8nebaN1SsRbFwtobMpXH4hEIiU4(0AKkRr2kSMiIWAsH(wtKSgu4wbkuwd(lPwrWf56skCiCZr7YsQa2c)KWqjae8slWTQtaB0VujSr)s4bpafoDjwN)X9Ijdfs2rIQeR7GOd(7QKMLIH49STaz86dYQuAbUXg9l1SyYQKsYbJc)7YqjYheXZsjKjt(XfhMciWznR0AWN14Hq(gIaaoPfHh98RpihoUW1Ja4SMiznYWZOSMiIWAYjW8jUuOF0egDlU1ivRYAKAuwd(lPwrWf56sXHPackPcyl8tcdLaqWlTa3QobSr)sLWg9lHhdtbeuI15FCVyYqHKDKOkX6oi6G)UkPzPyiEpBlqgV(GSkLwGBSr)snl2QRKsYbJc)7YqjYheXZsjKjt(Xja5db0Xtxj1kcUixxcbcWoQdXpHsQa2c)KWqjae8slWTQtaB0VujSr)srEbyBneIFcLyD(h3lMmuizhjQsSUdIo4VRsAwkgI3Z2cKXRpiRsPf4gB0VuZIfzvsj5GrH)DzOe5dI4zjf0slnUWDqWa8pAcZRXfUEeaN1ivwJSsQveCrUUucZRJQhx(W6sQa2c)KWqjae8slWTQtaB0VujSr)ssG51wZY4YhwxI15FCVyYqHKDKOkX6oi6G)UkPzPyiEpBlqgV(GSkLwGBSr)snl2kQKsYbJc)7YqjYheXZsjKjt(X5Hq(gIaGRKAfbxKRljTi8ONF9b5WlPcyl8tcdLaqWlTa3QobSr)sLWg9lHxeHBnY5xFqo8sSo)J7ftgkKSJevjw3brh83vjnlfdX7zBbY41hKvP0cCJn6xQzXK6kPKCWOW)UmuI8br8SuczYKFCEiKVHia4kPwrWf56sUeg0rp)6dYHxsfWw4NegkbGGxAbUvDcyJ(LkHn6xIsyqBnY5xFqo8sSo)J7ftgkKSJevjw3brh83vjnlfdX7zBbY41hKvP0cCJn6xQzXyVskjhmk8VldLiFqeplLqMm5hNhc5BicaUsQveCrUU05xFqo8O6XLpSUKkGTWpjmucabV0cCR6eWg9lvcB0VKC(1hKd3Awgx(W6sSo)J7ftgkKSJevjw3brh83vjnlfdX7zBbY41hKvP0cCJn6xQzXWZvsj5GrH)DzOe5dI4zPeYKj)48qiFdraWznR0AWN1GNSMC4hK4gN)G9a8h3bJc)BRjIiSgf0slnUX5pypa)XHoU1erewJhc5Bica4gN)G9a8hx46raCwtKSMvGYAWFj1kcUixxsHdH7OsJoSUKkGTWpjmucabV0cCR6eWg9lvcB0VedCiCBn4f0H1LyD(h3lMmuizhjQsSUdIo4VRsAwkgI3Z2cKXRpiRsPf4gB0VuZIHhwjLKdgf(3LHsKpiINLsitM8JZdH8nebaN1SsRbFwdEYAYHFqIBC(d2dWFChmk8VTMiIWAuqlT04gN)G9a8hh64wd(lPwrWf56skp4EGnbGzjvaBHFsyOeacEPf4w1jGn6xQe2OFjgEW9aBcaZsSo)J7ftgkKSJevjw3brh83vjnlfdX7zBbY41hKvP0cCJn6xQzXqIQskjhmk8VldLiFqepln(uW4JEW1I7SMiznYSMvAn4ZAgFky8rp4AXDwtKSgzwterynJpfm(OhCT4oRjswJmRb)LuRi4ICDPaAq0XNciikx4YsQa2c)KWqjae8slWTQtaB0VujSr)sSqdSg1(uabwdElCzj1bMUsGr)vjfsOJznY5xFqoCeAnQXRYLsjwN)X9Ijdfs2rIQeR7GOd(7QKMLIH49STaz86dYQuAbUXg9lrcDmRro)6dYHJqRrnEvEZIHezLusoyu4Fxgkr(GiEwkh(bjUX5pypa)XDWOW)UKAfbxKRlfqdIo(uabr5cxwsfWw4NegkbGGxAbUvDcyJ(LkHn6xIfAG1O2NciWAWBHlTg8He)Luhy6kbg9xLuiHoM1iNF9b5WrO14eaM8BnJZlLsSo)J7ftgkKSJevjw3brh83vjnlfdX7zBbY41hKvP0cCJn6xIe6ywJC(1hKdhHwJtayYV1moFZIHuwLusoyu4Fxgkr(GiEwkh(bjoH)sJoSg3bJc)7sQveCrUUuani64tbeeLlCzjvaBHFsyOeacEPf4w1jGn6xQe2OFjwObwJAFkGaRbVfU0AWNm8xsDGPRey0FvsHe6ywJC(1hKdhHwJtayYV1iKwkLyD(h3lMmuizhjQsSUdIo4VRsAwkgI3Z2cKXRpiRsPf4gB0Vej0XSg58RpihocTgNaWKFRriDZIHC1vsj5GrH)DzOe5dI4zPC4hK44cMiMabGz0aCJ7GrH)Dj1kcUixxkGgeD8PacIYfUSKkGTWpjmucabV0cCR6eWg9lvcB0Vel0aRrTpfqG1G3cxAn4B14VK6atxjWO)QKcj0XSg58RpihocTgNaWKFRHhKsjwN)X9Ijdfs2rIQeR7GOd(7QKMLIH49STaz86dYQuAbUXg9lrcDmRro)6dYHJqRXjam53A4HMnlrXVxmCrKBsbeumzsTSMTa]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170611.205117, [[dadxcaGErI2LivBJeYSL0njvFtuzNuzVODty)qKHjr)wQHsrvdgkA4s4GIIJrklKeTuiSyOA5u1dfLEk4Xk1ZvYefjmvrmzinDHlsrUSQRlQARqHntrPTdL60uAAIKoSILrHBt0OHsEgj4KquFwKY1OO48KuVMK8xkQSosOMAmHGjXGxpkvsak(2ovBkNW2c6muKbHuCZo5RbvsaXRFwNoJsTCLPAyM0n0svbfmiaBVTiiqiZoSTyXe60ycbtIbVEuQKaS92IGq0PLw9Px0HTflczWTvBOMqrh2wqazbQDpr7jiAXjO3OymE3ipbcUrEcMVdBliG41pRtNrPwoTsci(QZ73FXegeYI13Q0BSV8IG4e0Bu3ipbg0zWecMedE9OujHm42Qnuti64sZjNvCVAcilqT7jApbrlob9gfJX7g5jqWnYtiPJlrct9zf3RMaIx)SoDgLA50kjG4RoVF)ftyqilwFRsVX(YlcItqVrDJ8eyqNcmHGjXGxpkvsidUTAd1ewr7LQ(lUNaYcu7EI2tq0ItqVrXy8UrEceCJ8eGO9sv)f3taXRFwNoJsTCALeq8vN3V)IjmiKfRVvP3yF5fbXjO3OUrEcmyqWnYtaSYSiHPP6LxetvXiHzH)7wIpbdsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170611.205117, [[deeZraqiLq1MavAuusofLOvruP0RucfMfrLQUfrLk7cuggs6yKQLrP6zuszAkb6AkbSnIk5BGQghOcDoqfSoIkfZdur3tvW(iQ4GQIwOs0drctuju6IQkTrkPQtsjmtLqUPeTtqwkr5POMkszRevTxXFvsdwQoSIftKhtvtwPUm0Mvv9zjmAs50eEns1SPYTPy3i(nWWvvCCkPYYj55sA6QCDvPTtP8DvHops06vcfnFLG2Vuo6Hw4VKrYH7Sm8If)Nx3LLHzVs85chM)GEX4elMZjaKazxUShwg6WPIbYovD4PUG2xay21xqRzn7HLHZMsAcdgEdoy)UXGRvnGNomfAgbPk3z1gLE))H97gdUw1aE6W2VQ5eaIClvywZYWp9NaqQHwG0dTWFjJKd3zzy2ReFUWlERFcpDbPO1x4cB9n4G97gdUw1aE6WuOzeKARdNp06f(D4NscN4Om8VBm4Avd4Ph2cYw4NdOctaemCjyl)OGgdgom0yWWwVBmyRZAap9WYqhovmq2PQdVo1WYWk4v5XAOLlmfAONEjWgAqYfPWLGn0yWW5cK9ql8xYi5WDwg(PKWjokdJo0GKBCRsUPEHTGSf(5aQWeabdxc2YpkOXGHddngm8xhAqYnUwFPBQxyzOdNkgi7u1HxNAyzyf8Q8yn0YfMcn0tVeydni5Iu4sWgAmy4CbYAHw4VKrYH7Smm7vIpxyP3)FyOxdG1vW)6PHRfkCU16lzJkbPa27NWpLeoXrzyCuNM19o0XWwq2c)CavycGGHlbB5hf0yWWHHgdg(7OonR7DOJHLHoCQyGStvhEDQHLHvWRYJ1qlxyk0qp9sGn0GKlsHlbBOXGHZfOfm0c)LmsoCNLHzVs85cBg0vpfWaZ)Qui5AD58qRRRdFRVWf26lERpQt8p(dw9r05eKIvZGU6PagyizKC4U1HBRBg0vpfWaZ)Qui5AD58qRdhSh(PKWjokdJJ60wRAap9Wwq2c)CavycGGHlbB5hf0yWWHHgdg(7OoTwN1aE6HLHoCQyGStvhEDQHLHvWRYJ1qlxyk0qp9sGn0GKlsHlbBOXGHZfOfi0c)LmsoCNLHzVs85ch(PKWjokdxpGYqhXpOkSfKTWphqfMaiy4sWw(rbngmCyOXGH5dOm0r8dQcldD4uXazNQo86udldRGxLhRHwUWuOHE6LaBObjxKcxc2qJbdNlqYvOf(lzKC4oldZEL4Zfo8tjHtCug2jSUxXE1mfMz9ahAcBbzl8ZbuHjacgUeSLFuqJbdhgAmy4fjSUxXU1lNcZ060ahAcldD4uXazNQo86udldRGxLhRHwUWuOHE6LaBObjxKcxc2qJbdNlqWhAH)sgjhUZYWSxj(CH3Gd2VBm4Avd4PdtHMrqQTUCAD)uV1tyWwhUTUhaCBWJKvfo(l8tjHtCug2n2MvPxv9cBbzl8ZbuHjacgUeSLFuqJbdhgAmy4fn2MwF5RQEHLHoCQyGStvhEDQHLHvWRYJ1qlxyk0qp9sGn0GKlsHlbBOXGHZfi4yOf(lzKC4oldZEL4Zf2Qw3mOREkGbM)vPqY16Y5Hw3o1whUTU07)pm0HgKCJB9h4FRWE)06w26WT1TQ1v4VcRAJKdBDld)us4ehLH)DJbxRAap9Wwq2c)CavycGGHlbB5hf0yWWHHgdg26DJbBDwd4P36wPBz4NQIA4Buf4Tk(FqH)kSQnsomSm0HtfdKDQ6WRtnSmScEvESgA5ctHg6PxcSHgKCrkCjydngmCUabhcTWFjJKd3zzy2ReFUWMbD1tbmW8VkfsUwxop06666T(cxyRV4T(OoX)4py1hrNtqkwnd6QNcyGHKrYH7whUTUzqx9uadm)RsHKR1LZdToCuUc)us4ehLHXrDARvnGNEyliBHFoGkmbqWWLGT8JcAmy4WqJbd)DuNwRZAap9w3kDldldD4uXazNQo86udldRGxLhRHwUWuOHE6LaBObjxKcxc2qJbdNlq6udTWFjJKd3zzy2ReFUWsV))WuyfqgIhxpWHgyk0mcsT1HZwxNARVWf26w16sV))WuyfqgIhxpWHgyk0mcsT1HZw3Qwx69)h2u9izpepcB)QMtaiT(IrR7ba3g8ib2u9izpepctHMrqQTULToCBDpa42GhjWMQhj7H4ryk0mcsT1HZwxFbADld)us4ehLHpWHMvZupurzyliBHFoGkmbqWWLGT8JcAmy4WqJbdtdCOP1lN6HkkdldD4uXazNQo86udldRGxLhRHwUWuOHE6LaBObjxKcxc2qJbdNlq66Hw4VKrYH7Smm7vIpxyRADP3)FyFapIQvW)6PHRMbD1tbmWE)06WT1h)jSHRibncS26WzRBTw3YwhUTUvT(gLE))H5efAhrqkwvGnSn4rsRBz4NscN4OmStuODebPyvc4UWwq2c)CavycGGHlbB5hf0yWWHHgdgErIcTJiifT(sG7c)uvudFJQaVvX)dBu69)hMtuODebPyvb2W2GhjHLHoCQyGStvhEDQHLHvWRYJ1qlxyk0qp9sGn0GKlsHlbBOXGHZfiD7Hw4VKrYH7Smm7vIpxyP3)FyFapIQvW)6PHRMbD1tbmWE)06WT1h)jSHRibncS26WzRBTWpLeoXrzyNOq7icsXQeWDHTGSf(5aQWeabdxc2YpkOXGHddngm8IefAhrqkA9La316wPBzyzOdNkgi7u1HxNAyzyf8Q8yn0YfMcn0tVeydni5Iu4sWgAmy4Cbs3AHw4VKrYH7Smm7vIpxyRA9XFcB4ksqJaRTUCAD9whUT(4pHnCfjOrG1wxoTUERBzRd3w3QwFJsV))WCIcTJiifRkWg2g8iP1Tm8tjHtCug2RncYQtuODebPiSfKTWphqfMaiy4sWw(rbngmCyOXGHPqBeKwFrIcTJiifHFQkQHVrvG3Q4)Hnk9()dZjk0oIGuSQaByBWJKWYqhovmq2PQdVo1WYWk4v5XAOLlmfAONEjWgAqYfPWLGn0yWW5cK(cgAH)sgjhUZYWSxj(CHh)jSHRibncS26YP11BD426J)e2WvKGgbwBD5066HFkjCIJYWETrqwDIcTJiifHTGSf(5aQWeabdxc2YpkOXGHddngmmfAJG06lsuODebPO1Ts3YWYqhovmq2PQdVo1WYWk4v5XAOLlmfAONEjWgAqYfPWLGn0yWW5cK(ceAH)sgjhUZYWSxj(CH3O07)pmNOq7icsXQcSHTbpsc)us4ehLHDIcTJiifRsa3f2cYw4NdOctaemCjyl)OGgdgom0yWWlsuODebPO1xcCxRBLDld)uvudFJQaVvX)dBu69)hMtuODebPyvb2W2GhjHLHoCQyGStvhEDQHLHvWRYJ1qlxyk0qp9sGn0GKlsHlbBOXGHZfiD5k0c)LmsoCNLHFkjCIJYWorH2reKIvjG7cBbzl8ZbuHjacgUeSLFuqJbdhgAmy4fjk0oIGu06lbUR1TYAwgwg6WPIbYovD41PgwgwbVkpwdTCHPqd90lb2qdsUifUeSHgdgoxG0Hp0c)LmsoCNLHzVs85cRWFfw1gjhg(PKWjokd)7gdUw1aE6HPqd90lb2qdsUSmCjyl)OGgdgoSfKTWphqfMaiyyOXGHTE3yWwN1aE6TUv2Tm8tvrnSbytqkEqxU)gvbERI)hu4VcRAJKddldD4uXazNQo86udldRGxLhRHwUWLaBcsrG0dxc2qJbdNlq6WXql8xYi5WDwg(PKWjokdJJ60wRAap9WuOHE6LaBObjxwgUeSLFuqJbdh2cYw4NdOctaemm0yWWFh1P16SgWtV1TYULHFQkQHnaBcsXd6HLHoCQyGStvhEDQHLHvWRYJ1qlx4sGnbPiq6HlbBOXGHZfiD4qOf(lzKC4oldZEL4Zf(gvbEW2I6nep26YP1LRWpLeoXrz4F3yW1QgWtpmfAONEjWgAqYLLHlbB5hf0yWWHTGSf(5aQWeabddngmS17gd26SgWtV1TYAwg(PQOg2aSjifpOhwg6WPIbYovD41PgwgwbVkpwdTCHlb2eKIaPhUeSHgdgoxUWqJbdZcdfT(xhAqYno5MwVkifoS1DQCja]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170611.205117, [[de09taqiuuAtkvmkLGtPezvKKIxrsQywKKQClssvTlvLHbLogjwgj1ZuIQPPujUMsuSnvvX3qrgNsu6CkvsRJKuQ5PQQCpLq7dfvhuvLfQK8quktKKuYfvQAJQQsNeLQzQQQ6Ms0ovLLsepfzQOKTssSxXFrHblLdRyXe1JPYKHQld2Ss5ZePrtPonfVgkMTKUnP2nHFdz4sWXrrXYr1ZPQPRY1PKTlH(UsL68kPwpjPsZNKK9lvhLWk0EXixb8SkKQfSnw1lRcroUPWfkevaCMPAuDNZGe5P(pQdjbQW4H8uJvHjS7I6L5tTYUS8LRoKeyWxZYOHq4O7BRoAGH3g5W8Xb9yeEv)fWbzRTTVT6ObgEBKdZhUfFodsOAW(T8Lc9ZDgKWhw5PewH2lg5kGNvHih3u4cXS92zCymcP9MQuvVHJUVT6ObgEBKdZhh0Jr47T)TyVj1Hh6NSPAU1H2QJgy4TromHyxGBCZH4HeibeQeHRYWFJgcf6nAi0FRJg6nYg5WescuHXd5PgRctkydjb8ilUd8HvUqSzdomLOIGgexKdvIWFJgcLlp1HvO9IrUc4zviYXnfUqYwBBFGZgbEgOngNnWqkhMJH3sGdCJq6NvHEBNEtpq1FCK(ZzX5G46nMVyVTS)j0pzt1CRdbd)SzgRbdeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7h(zZmwdgiKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxElpScTxmYvapRcroUPWfs2AB7Z4Gnl(6pRc92o9MEGQ)4i9NZIZbX1BmFXEtrrP32P3y2Et2AB7B8oqGpch8zvi0pzt1CRdTXr(JH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq)LJ8xVr2ihMqsGkmEip1yvysbBijGhzXDGpSYfInBWHPeve0G4ICOse(B0qOC5TlHvO9IrUc4zvOFYMQ5whcQGge3uzixh)fIDbUXnhIhsGeqOseUkd)nAiuO3OHq7RGge3u7Tv1XFHKavy8qEQXQWKc2qsapYI7aFyLleB2GdtjQiObXf5qLi83OHq5YBzcRq7fJCfWZQqKJBkCH0du9hhP)CwCoiUEJ5l2Bkkm1BQsv9gZ2Bd)mBJ7(87gQvJqkd9av)Xr6pqmYvaV32P30du9hhP)CwCoiUEJ5l2B7Q6q)KnvZToem8ZMH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7h(z3BKnYHjKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxE)jScTxmYvapRcroUPWfk0pzt1CRd5pexJbGcape7cCJBoepKajGqLiCvg(B0qOqVrdHOdX1yaOaWdjbQW4H8uJvHjfSHKaEKf3b(Wkxi2SbhMsurqdIlYHkr4VrdHYLhtHvO9IrUc4zviYXnfUql0B6bQ(JJ0FolohexV9Vf7nfSk92o92WpZ24Up)UHA1iKYqpq1FCK(deJCfW7nvPQEJz7THFMTXDF(Dd1QriLHEGQ)4i9hig5kG3B70B6bQ(JJ0FolohexV9Vf7nM(tVTuVTtVXS9MS12234DGaFeo4ZQqOFYMQ5whY4Gnl(6qSlWnU5q8qcKacvIWvz4VrdHc9gneIDhSzXxhscuHXd5PgRctkydjb8ilUd8HvUqSzdomLOIGgexKdvIWFJgcLlVLnScTxmYvapRcroUPWfk0pzt1CRdvnmJLbNHEKQhgh6aDi2f4g3CiEibsaHkr4Qm83OHqHEJgc9FdZyzW7TYrQE6nwOd0HKavy8qEQXQWKc2qsapYI7aFyLleB2GdtjQiObXf5qLi83OHq5YBxdRq7fJCfWZQqKJBkCHKT22(kG2nWzG2yC2ad9av)Xr6pRc92o9MS122N)qCngaka8pRc92o924otrGbiaTb892)6TLh6NSPAU1HQgP2NWiKYqgvVqSlWnU5q8qcKacvIWvz4VrdHc9gne6)gP2NWiK2BRq1lKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxEkydRq7fJCfWZQqKJBkCHWr33wD0adVnYH5Jd6Xi89gZ7n34pgNrd92o9MdHQ4ODlyWHXDH(jBQMBDO6uCyiBX9xi2f4g3CiEibsaHkr4Qm83OHqHEJgc9)P40BRS4(lKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxEkkHvO9IrUc4zviYXnfUqYwBBFghSzXx)zvO32P3wO3wO30du9hhP)CwCoiUEJ5l2BQX2Bl1BQsv9MS122NXbBw81FCqpgHV3(xVTqVP8Tm9MQP38fGALH94pO3un9MS122NXbBw81F(BCy6nvNEtP3wQ3wk0pzt1CRdTXr(JH3g5WeIDbUXnhIhsGeqOseUkd)nAiuO3OHq)LJ8xVr2ihMEBbLLcjbQW4H8uJvHjfSHKaEKf3b(Wkxi2SbhMsurqdIlYHkr4VrdHYLNI6Wk0EXixb8Ske54McxOf6n9av)Xr6pNfNdIR3y(I9MAS92o9MS122hubniUPYyd5S8Fwf6TL6TD6Tf6noSXbV9ixHEBPq)KnvZTo0wD0adVnYHje7cCJBoepKajGqLiCvg(B0qOqVrdH(BD0qVr2ihMEBbLLc9Jl1h6gUu4yy2wKdBCWBpYviKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxEklpScTxmYvapRcroUPWfs2AB7Z4Gnl(6pRcH(jBQMBDOnoYFm82ihMqSzdomLOIGgexwfQeHRYWFJgcfIDbUXnhIhsGeqO3OHq)LJ8xVr2ihMEBb1lf6hxQpKgv0iKUOsijqfgpKNASkmPGnKeWJS4oWhw5cvIkAesZtjujc)nAiuU8u2LWk0EXixb8Ske54Mcxi9av)Xr6pNfNdIR3y(I9MIIsVPkv1BmBVn8ZSnU7ZVBOwncPm0du9hhP)aXixb8EBNEtpq1FCK(ZzX5G46nMVyVTS)j0pzt1CRdbd)Sz4TromHyxGBCZH4HeibeQeHRYWFJgcf6nAi0(HF29gzJCy6TfuwkKeOcJhYtnwfMuWgsc4rwCh4dRCHyZgCykrfbniUihQeH)gnekxEkltyfAVyKRaEwfICCtHlKS122hh8iXiCaJdDG(Jd6Xi892)6nfSH(jBQMBDOdDGMHE8hWxhIDbUXnhIhsGeqOseUkd)nAiuO3OHqSqhO7TYXFaFDijqfgpKNASkmPGnKeWJS4oWhw5cXMn4WuIkcAqCroujc)nAiuU8u(tyfAVyKRaEwfICCtHlKS122h4SrGNbAJXzdmKYH5y4Te4a3iK(zvi0pzt1CRdbd)SzgRbdeIDbUXnhIhsGeqOseUkd)nAiuO3OHq7h(zZmwdgO3wqzPqsGkmEip1yvysbBijGhzXDGpSYfInBWHPeve0G4ICOse(B0qOC5PWuyfAVyKRaEwfICCtHlKS122xb0Ubod0gJZgyOhO6pos)zvO32P3g3zkcmabOnGV3(xVT8q)KnvZTou1i1(egHugYO6fIDbUXnhIhsGeqOseUkd)nAiuO3OHq)3i1(egH0EBfQE92cklfscuHXd5PgRctkydjb8ilUd8HvUqSzdomLOIGgexKdvIWFJgcLlpLLnScTxmYvapRcroUPWfACNPiWaeG2a(EJ59MsVTtVnUZueyacqBaFVX8Etj0pzt1CRd5ShJGr1i1(egH0qSlWnU5q8qcKacvIWvz4VrdHc9gneIn7Xi6T)BKAFcJqAijqfgpKNASkmPGnKeWJS4oWhw5cXMn4WuIkcAqCroujc)nAiuU8u21Wk0EXixb8Sk0pzt1CRdvnsTpHriLHmQEHyxGBCZH4HeibeQeHRYWFJgcf6nAi0)nsTpHriT3wHQxVTG6LcjbQW4H8uJvHjfSHKaEKf3b(Wkxi2SbhMsurqdIlYHkr4VrdHYLNASHvO9IrUc4zviYXnfUqCyJdE7rUcH(jBQMBDOT6ObgEBKdti2SbhMsurqdIlRcvIWvz4VrdHcXUa34MdXdjqci0B0qO)whn0BKnYHP3wq9sH(XL6dPrfncPlQO6DdxkCmmBlYHno4Th5kescuHXd5PgRctkydjb8ilUd8HvUqLOIgH08ucvIWFJgcLlp1kHvO9IrUc4zvOFYMQ5whcg(zZWBJCycXMn4WuIkcAqCzvOseUkd)nAiui2f4g3CiEibsaHEJgcTF4NDVr2ihMEBb1lf6hxQpKgv0iKUOsijqfgpKNASkmPGnKeWJS4oWhw5cvIkAesZtjujc)nAiuU8uRoScTxmYvapRcroUPWf6gUu4(Wn(BeoO3yEV9Nq)KnvZTo0wD0adVnYHjeB2GdtjQiObXLvHkr4Qm83OHqHyxGBCZH4Heibe6nAi0FRJg6nYg5W0BlS8Lc9Jl1hsJkAesxujKeOcJhYtnwfMuWgsc4rwCh4dRCHkrfncP5PeQeH)gnekxUqVrdHiJMTEBFf0G4MQQDV5ncPvO3mB5sa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170611.205117, [[de0qkaqifc2ee0OiICkIqRIKkmlsQKBrsfTlIQHPuDmjAzKWZuizAerDnuuABke6BqOXrsv6CKuPwhjvX8GaUhkQ2NcroOKYcjjpuHAIKuvUOKQncbYjjsntIGBkHDQKFssv1srHNImviARej7v8xizWOQdt1IrPhROjlLlRAZKOpRGrljNMWRjkZMs3Mu7g0VHA4KuoUcPwofpxQMoW1vkBhs9DuuCEuK1dbQ5Rqu7hvoLbzO6qN1(wufIu7tHBfiyhiWWSumIkcrtJqnqOqQVR03SGOkeJBV3Fwk2lrCxYkyw5kkL8OgLIqmU3ycPq)qnmqUsRRpQEfEktU5Axa7Qtj1o7MsLYvAD9r1RWtzYBBghiWq1XU8rjXq1Mabg2dYSkdYq1HoR9TOkunwHvaykuhGnAz)QDtiPHnX0bytiig(qf4MuUz56hk0Y1pebWgTSF1UjeJBV3Fwk2lrSCpeJ3XBM57bzaHgx9PScm6Rpee2qf42Y1puazPiidvh6S23IQq00iudecGhgSx(eJTnmZa7HQXkScatH8(8WMdNpK0WMy6aSjeedFOcCtk3SC9dfA56hQwFEyZHZhIXT37plf7LiwUhIX74nZ89GmGqJR(uwbg91hccBOcCB56hkGSgvqgQo0zTVfvHQXkScatHSIrVjAO0(G2rbWGRdjnSjMoaBcbXWhQa3KYnlx)qHwU(HKGy0BIghFHpODoEKyW1HyC79(ZsXEjIL7Hy8oEZmFpidi04QpLvGrF9HGWgQa3wU(HciljhKHQdDw7BrviAAeQbcjjoEFceOpQdVw8ohpcWXlzoEeYXR9B7adwlFUzmhc44hjMZXRyNJxIC8iKJxsC8MR08ELZAphVedvJvyfaMcP066JQxHNYcjnSjMoaBcbXWhQa3KYnlx)qHwU(HqqwxFoEQcpLfQMzOhc4MHdqjuYCZvAEVYzTpeJBV3Fwk2lrSCpeJ3XBM57bzaHgx9PScm6Rpee2qf42Y1puazXSbzO6qN1(wufQgRWkamf6Ubun6nx2djnSjMoaBcbXWhQa3KYnlx)qHwU(HQ7gq1O3CzpeJBV3Fwk2lrSCpeJ3XBM57bzaHgx9PScm6Rpee2qf42Y1puaznIbzO6qN1(wufIMgHAGqnmqUsRRpQEfEktU5Axa7C8Jeh)07auaH(C8iKJNDtPs5whTJQVzgU8n144rih)iWXdC7Ha5wXqfakGdOm4M8dDw7BC8iKJ3Nab6J6WRfVZXJaC8sounwHvaykK1r7Oy3mDqiPHnX0bytiig(qf4MuUz56hk0Y1pKeC0ohVQntheIXT37plf7LiwUhIX74nZ89GmGqJR(uwbg91hccBOcCB56hkGSqmidvh6S23IQq00iudeAe44bU9qGCRyOcafWbugCt(HoR9noEeYX7tGa9rD41I354raoEMLJFKhzoEGBpei3kgQaqbCaLb3KFOZAFJJhHC8(eiqFuhET4DoEeGJxYHQXkScatHU96dbUffR17GqsdBIPdWMqqm8HkWnPCZY1puOLRFO62Rpe4woEvwVdcX4279NLI9sel3dX4D8Mz(EqgqOXvFkRaJ(6dbHnubUTC9dfqwQ3GmuDOZAFlQcvJvyfaMczD0ok276qsdBIPdWMqqm8HkWnPCZY1puOLRFij4ODoEv31HyC79(ZsXEjIL7Hy8oEZmFpidi04QpLvGrF9HGWgQa3wU(Hcil1DqgQo0zTVfvHOPrOgiu7SBkvk3kgQaqbCaLb3K3WmdmunwHvayk0SYfquwXqfakGdHKg2ethGnHGy4dvGBs5MLRFOqlx)qJRCbKJxcIHkauahcvZm0dbCZWbOekzE7SBkvk3kgQaqbCaLb3K3WmdmeJBV3Fwk2lrSCpeJ3XBM57bzaHgx9PScm6Rpee2qf42Y1puazvUhKHQdDw7BrvOAScRaWuOzLlGOSIHkauahcjnSjMoaBcbXWhQa3KYnlx)qHwU(Hgx5cihVeedvaOaoWXlPsjgIXT37plf7LiwUhIX74nZ89GmGqJR(uwbg91hccBOcCB56hkGSkldYq1HoR9TOkunwHvaykK1r7Oy3mDqOXvFkRaJ(6dbrvOcCtk3SC9dfsAytmDa2ecIHp0Y1pKeC0ohVQnthWXlPsjgQMzOhsJrlGdmVmeJBV3Fwk2lrSCpeJ3XBM57bzaHkWOfWHSkdvGBlx)qbKvPIGmuDOZAFlQcrtJqnqiZvAEVYzTpunwHvaykKsRRpQEfEkl04QpLvGrF9HGOkubUjLBwU(HcjnSjMoaBcbXWhA56hcbzD954Pk8ughVKkLyOAMHEingTaoW8s1fWndhGsOK5MR08ELZAFig3EV)SuSxIy5EigVJ3mZ3dYacvGrlGdzvgQa3wU(HciGqlx)qKqpMJVU96dbUv9WXxt9xpGea]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170611.205117, [[daK2saqicH2KqYOuL4ukP6vQskMLqkQBPkP0UufddrogLAzcXZuLKPriY1esPTri4BiuJtivDovjvRtifmpLeUNss7tjLdIqwOs0drsnrHuKlQk1gje1jjuntLeDtfStv1srQEkQPIu2kHYEL(lIAWu1HfTycEmPMSsDzWMrWNPeJwHonfVgjMTIUnj7gQFdz4kHJlKklNONtLPRY1fQTtj9DcPopsY6fsHMpHK9l4AxALFJtHjS7YY8cqBYPjAmpdc3FeriszwlnlUYLJMacz886YY0HjKoO)iKSjMKifjAFIylsV6vrkthYnv0mkOSeuPb7ETcXei8KonG3jwdp7yzEgeUmr6ZGWUsRF7sR8BCkmHDxwM1sZIR8HSyzcpAeAUrIg7c(Oc(xc(n6Eimtfq2nI0uEKGknyxWVwWletGWt60aENyn8SJL5zq4GpQGxJqZns04NzAnjlelD3JeuPb7c(1cEsbFubVig8cXei84oKurbGfG8jErWVEzIemtZrv50Pb8oXAOS44TrNhswgJWq5b0wSu(tfuU8pvqzICAaVtSgkthMq6G(JqYMyBsLPdouSudUsRxzQhbnLbKvqb4RcLhq7FQGY96psPv(nofMWUllZAPzXvwed(ZOPyWwcErjQGFJUhcZubKDJinLhjOsd2f8Ry1G3IExMibZ0CuvMWmvaz3istPS44TrNhswgJWq5b0wSu(tfuU8pvqzrEMki45rKMsz6Wesh0Fes2eBtQmDWHILAWvA9kt9iOPmGSckaFvO8aA)tfuUx)VQ0k)gNcty3LLzT0S4kRsy6ojs9OJLsaFb)ARg8rif8rf8sqLgSl4xXQbVqmbcpPtd4DI1WZowMNbHd(OcEncn3irJFsNgW7eRHhjOsd2f8VMGxiMaHN0Pb8oXA4zhlZZGWb)kwn43XY8miCzIemtZrvzcZubKDJinLYIJ3gDEizzmcdLhqBXs5pvq5Y)ubLf5zQGGNhrAkb)l2RxMomH0b9hHKnX2KkthCOyPgCLwVYupcAkdiRGcWxfkpG2)ubL71VivALFJtHjS7YYejyMMJQYWeua(YjzHz6UYIJ3gDEizzmcdLhqBXs5pvq5Y)ubLFpbfGVCg8lNP7kthMq6G(JqYMyBsLPdouSudUsRxzQhbnLbKvqb4RcLhq7FQGY96pAlTYVXPWe2DzzwlnlUYcXei8a6re4iJiq(gbYwKqEKDX4ninylpXlc(OcErm4fIjq4jDAaVtSgEIxe8rf8QeMUtIup6yPeWxWV2QbF0lcLjsWmnhvLHuEJrxCsbkloEB05HKLXimuEaTflL)ubLl)tfu(DkVXOloPaLPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9lcLw534uyc7USmRLMfxzvct3jrQhDSuc4l4xB1G32M4GxuIk4fXGpLNHqQVhNOH50GTqwLW0DsK6bWPWe2bFubVkHP7Ki1Jowkb8f8RTAW)6rktKGzAoQkdP8gj7grAkLfhVn68qYYyegkpG2ILYFQGYL)Pck)oL3yWZJinLY0HjKoO)iKSj2Muz6Gdfl1GR06vM6rqtzazfua(Qq5b0(NkOCV(jU0k)gNcty3LLzT0S4kxMibZ0Cuv2DiPIcalazzXXBJopKSmgHHYdOTyP8NkOC5FQGY8HKkkaSaKLPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9h9Lw534uyc7USmRLMfx5YejyMMJQYtt0fB2KvPfvs(qhOkloEB05HKLXimuEaTflL)ubLl)tfuELMOl2Sd(H0IkdEAOduLPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9)6Lw534uyc7USmRLMfxzHyceEwGenijJiq(gbYQeMUtIupXlc(OcEHyceEChsQOaWcq(eVi4Jk4t9zScKbmOmGl4xrW)QYejyMMJQYtJLXdBWwilGMxzXXBJopKSmgHHYdOTyP8NkOC5FQGYR0yz8WgSLGFjAELPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9BtQ0k)gNcty3LLzT0S4kVr3dHzQaYUrKMYJeuPb7c(1cED6oYNrbbFub)lbVgHMBKOXKLqQVGxuIk4fIjq4jDAaVtSgEIxe8RxMibZ0CuvEMwtYcXs3vwC82OZdjlJryO8aAlwk)Pckx(NkO8ktRzWVmw6UY0HjKoO)iKSj2Muz6Gdfl1GR06vM6rqtzazfua(Qq5b0(NkOCV(TTlTYVXPWe2DzzwlnlUYVe8QeMUtIup6yPeWxWV2QbFesbFubVqmbcpWeua(YjzciDS7jErWVEWhvW)sWlbcsWnMcti4xVmrcMP5OQmHzQaYUrKMszXXBJopKSmgHHYdOTyP8NkOC5FQGYI8mvqWZJinLG)LiRxMiPfx5lLwGJSHWQsGGeCJPWekthMq6G(JqYMyBsLPdouSudUsRxzQhbnLbKvqb4RcLhq7FQGY963osPv(nofMWUllZAPzXvwLW0DsK6rhlLa(c(1wn4TTTdErjQGxed(uEgcP(ECIgMtd2czvct3jrQhaNctyh8rf8QeMUtIup6yPeWxWV2QbF0lcLjsWmnhvLHuEJKDJinLYIJ3gDEizzmcdLhqBXs5pvq5Y)ubLFNYBm45rKMsW)I96LPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9B)QsR8BCkmHDxwM1sZIRSqmbcpsWHWjwdKp0bQhjOsd2f8Ri4Tjf8Isub)lbVqmbcpsWHWjwdKp0bQhjOsd2f8Ri4Fj4fIjq4jDAaVtSgE2XY8miCW)AcEncn3irJFsNgW7eRHhjOsd2f8Rh8rf8AeAUrIg)KonG3jwdpsqLgSl4xrWBhTb)6LjsWmnhvLp0bkYQ0DGKQYIJ3gDEizzmcdLhqBXs5pvq5Y)ubLPHoqf8dP7ajvLPdtiDq)riztSnPY0bhkwQbxP1Rm1JGMYaYkOa8vHYdO9pvq5E9BlsLw534uyc7USmRLMfx5uFgRazadkd4c(1cE7GpQGp1NXkqgWGYaUGFTG3UmrcMP5OQ8mTMKfGuvwC82OZdjlJryO8aAlwk)Pckx(NkO8ktRzWVesvz6Wesh0Fes2eBtQmDWHILAWvA9kt9iOPmGSckaFvO8aA)tfuUx)2rBPv(nofMWUllZAPzXvwiMaHNfirdsYicKVrGSkHP7Ki1t8IGpQGp1NXkqgWGYaUGFfb)RktKGzAoQkpnwgpSbBHSaAELfhVn68qYYyegkpG2ILYFQGYL)PckVsJLXdBWwc(LO5f8VyVEz6Wesh0Fes2eBtQmDWHILAWvA9kt9iOPmGSckaFvO8aA)tfuUx)2IqPv(nofMWUllZAPzXvo1NXkqgWGYaUGFTG3o4Jk4t9zScKbmOmGl4xl4TltKGzAoQkRhtdM80yz8WgSLYIJ3gDEizzmcdLhqBXs5pvq5Y)ubLPEmn4GFLglJh2GTuMomH0b9hHKnX2KkthCOyPgCLwVYupcAkdiRGcWxfkpG2)ubL71VnXLw534uyc7USmrcMP5OQ80yz8WgSfYcO5vwC82OZdjlJryO8aAlwk)Pckx(NkO8knwgpSbBj4xIMxW)sK1lthMq6G(JqYMyBsLPdouSudUsRxzQhbnLbKvqb4RcLhq7FQGY963o6lTYVXPWe2DzzwlnlUYsGGeCJPWektKGzAoQktyMkGSBePPuM6rqtzazfua(6YYdOTyP8NkOCzXXBJopKSmgHHY)ubLf5zQGGNhrAkb)lVA9YejT4kRqwnylRAhnFP0cCKnewvceKGBmfMqz6Wesh0Fes2eBtQmDWHILAWvA9kpGSAWw63U8aA)tfuUx)2VEPv(nofMWUlltKGzAoQkdP8gj7grAkLPEe0ugqwbfGVUS8aAlwk)PckxwC82OZdjlJryO8pvq53P8gdEEePPe8Vez9YejT4kRqwnylRAxMomH0b9hHKnX2KkthCOyPgCLwVYdiRgSL(TlpG2)ubL71FesLw534uyc7USmRLMfx5lLwG7zBCxI1qWVwWlcLjsWmnhvLjmtfq2nI0ukt9iOPmGSckaFDz5b0wSu(tfuUS44TrNhswgJWq5FQGYI8mvqWZJinLG)frA9YejT4kRqwnylRAxMomH0b9hHKnX2KkthCOyPgCLwVYdiRgSL(TlpG2)ubL71R8pvqz2OOo4FpbfGVCgne8od2Yec(0P71c]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170409.204707, [[d8tQiaWyiwpK0lPqSlvvHxRQs)gPzkeMgfQzRkNxOUjQkDAcFdvfogfTtrTxPDd1(vu)esnmsmoss6Yknuk1GvKHJshuHoQQQOdt15qvrTqfSuIOflOLtQhsuEkyzevpxKjQQknvenzI00v5IcCvkKEgr46OyJcPTsscBMs2of8rvvSniHpJQ8DvLrssQ1PQQgnQmEuvDssQBbj6Acr3JKeDBewlQkYXjjUMLSaIZEckokfFWf)2cOnkzeQZbfqC2tqXrP4deOUnBkVG2X8wzClYVDOq4tGkQ)8OFnSqmAlR0EYC2tqXPMvkWpAlR0EYC2tqXPMvkOcZYSsvJqXGa1TzJvkqiWJbnlrbvywMvQmN9euCQdfIrBzL2J0182l1SsH)Kzz2ujB2SKfcWE4BL2HcJiNGINNIqKUcGGq28uaMZXilXIV)NNy1lcLi0VczNylacczZtbyohJSel((FEIvViuIq)ki5(wpTnlxXefMkksuaq0c2RWjiwvPsVMLxYcbyp8Ts7qHrKtqXZtrisxbqqiBEkaZ5yKLyX3)ZtsxlN5DfYoXwaeeYMNcWCogzjw89)8K01YzExbj336PTz5kMOWurrIE9kK4OFWN4q4gd6qb(rBzL2J0182l1SsbcNFGSzZcNR5T3igHJQlmGMKenFLu9pQMSa)OTSs7zKHuZMfSO4RWOw4V5PSR10Vcjo6hPR5TxQdf(nCeJWr1firBlP6FunzbbwQaXpQEeJWr1fKu9pQMSaIZEckEeJWr1fgqtsIMVfKrzJNNiPfcWCogzjw8npbcmV3IssxZBVcjo6hq2HcQWSm7Ff6f5euCbjv)JQjlGziuJqXPMnUqmAlR0EQXsfi(r1PMvkK4OFYC2tqXPouGF0wwP9gz0EZkfKUwoZ7gTJOaiiKnpfG5CmYsS47)5jPRLZ8UccekMprPenBgzbcN)rMJ2SsHWNavu)5r)gFVgwWFSCoWr)Sne0Szb)XY5YOeH(zBiOzZcec8iZrBwPWVHrP4dU43waTrjJqDoOG)(84KTb7ouWGijcfpXftgZUfclG4SNGIhFcE4cYcYKbswqQiX(8yYy2TGxWFSC(47ZJt2gcA2SG2X8wYy2TGhkEIlUGZOD(kWBhkK4OFJmAxn2I2Hc)ggLIpqG62SP8cQWiq(fU43wWl4pwoN0182Z2GDZMfCgTpIr4O6cdOjjrZ3icIswqVVcYcYKbswiXUVx0NN4Ayb)XY5KUM3E2gcA2SqIJ(bFIdHBK5ODOGkmlZkvnwQaXpQo1HcoJ2vJTOKXSBHqglRcXnkkvvf(SCJvqHPjFiHIC58HsTqPXrw4CnV9IsXhCXVTaAJsgH6Cqb(68liyiMNifeBZsOuigTLvApJmKAgLYlaiAb7vOG)y58X3NhNSny3SzbekrOF2gcAybwTGW1XrP4deOUnBkVaRErOeH(nAhrbqqiBEkaZ5yKLyX3)ZtS6fHse6xbGDre(tGQFckUz5OqIceo)JbnRuG0Fl(MN(rtzyBwPW5AE7zBiOHfsS77f95joz0hvxYcEZMfcB2SaVMnlOB2SxHeh9Z2GDhkeJ2YkT3iJ2BwPWFxlN5DDOq2j2cbyohJSel(MNS1ccxhxWz0oWUVN6)2SCftv14ilCUM3ErP4RGn58e4408u21A6xHeh9tnwQaXpQo1Hc)ggLIVc2KZtGJtZtzxRPFf83NhNSne0Hcjo6NTHGouiXr)gd6qbekrOF2gSBybNr7KXSBHqglRc2AbHRJNNK5SNGINNgz0Eb4OAIqTaZB1fsC0VrMJ2Hcecmq2SsHZ182lkfFGa1Tzt5fuHrG8RQqKGl(Tf8cio7jO4Ou8vWMCEcCCAEk7An9RG)y5CzuIq)Sny3SzHaSh(wPDOqsqW(2r0bnlrb(rBzL2tnwQaXpQo1Ssbj336PTz5kM8HIXkY)dt5sOySefsC0pJSXHcSubMxQdfS1ccxhppjZzpbfxiP9tqlCUM3E2gSBybbcfdSoIaZR5ilOcZYSJpbpmXIVcify1ccxhRgHIbbQBZgRuWFSCoWr)Sny3SzbvywMvAuk(abQBZMYlWFZOef)HPIerAgjkKh5IsfLilOcZYSsnYqQdfsC0p4tCiCJOd6qbNr7gflUcSppE19Ab]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170409.204707, [[d8ZBiaqyQwpa9ssO2LQk8Avv53intsPEgaMTIoVu1nrvLtt4BsOYZL0oLYEf7g0(vOFcOHrjJdvvLTrkPHsPgScgoIoOeDuuvvDmvX5iHyHQklLeSyIA5u8qI4PqpgO1PQstuvfnvuAYePPRYfjPRskXLv66OyJsfBvcvTzs12jrFuQKpJQmnPs9DvPrkHYYKGrJkJhvLtskUfjKUMQQ6EOQkUncRfvvPJlHCEcBqqN8euyhk8WRFUbbQfwT10udEUH3E2kTJCqJd5Ts4wW)Yxq5Paqa7AsFJCWEG6619K4KNGcRPzfKpG6619K4KNGcRPzfSiMLzLQbKcrbGBADBfKqalvtdGGfXSmRujo5jOWA(c2duxVUhRB4TxnnRG8FMLzRHnTNWguf6YZvA(cwcEckCCqBr9cIccjJdQqohcUel8(DCG0SGucz)c2CInikiKmoOc5Ci4sSW73XbsZcsjK9lOc7C96MwbRN)T06pku4jicAeKxWtqS8hRCPviSbvHU8CLMVGLGNGchh0wuVGOGqY4GkKZHGlXcVFhhKU6oZ8c2CInikiKmoOc5Ci4sSW73XbPRUZmVGkSZ1RBAfSE(3sR)OqHNC5cw5OV4R4a5kvJCWkh9TK5OroOaKcrshua5L2)bp3WBVsiih1e8dillq(PGMUkgBq(aQRx3tXF10ScQtHxWsJWNJdn3yOVbRC0xw3WBVA(c(NCjeKJAcYc0wbnDvm2GcOubOFutjeKJAcQGMUkgBqqN8euyjeKJAc(bKLfi)cIKlOWNca9tqHPvqRaeSYrFr28fSiMLz)PWSGNGcdQGMUkgBqidHgqkSMw3bRK7C2z6voj0j1e2GEApbLt7jiV0EcAs7jxWkh9vItEckSMVG8buxVUxjJXtZkO0v3zMxPT2brbHKXbviNdbxIfE)ooiD1DM5fKW5RK5OPzfuEkaeWUM03Y5mYb9jjNJC0xBLQP9e0NKCUekHSF2kvt7j4pxDNzE5lOpF9(QTs78fuPOkKftX1Z2tUbLdc6KNGclNcEWGsuBSQkeuQOso9E2EYniyqcbSK5OPbqqJd5TS9KBqxwmfxFqNX48ta38fSiMLzlNcEqIfEbbd(NChk8qbGBApfc6mgxduNY2tUbLz01d6tsoN1n82ZwPDApbRC03sgJRbQtJCqZodkrTXQQqWk5oNDMELlYb9jjNZ6gE7zRunTNG8buxVUhRB4TxnnRGfXSmRunqPcq)OMA(c6mgVecYrnb)aYYcKFAR2HnyF6OOA9Flf5XsraO4aaaRU5FayfDfT7)dEUH3EDOWdV(5geOwy1wttni)C(eemeJdScInnaScYxAwbrqJG8cwfqEZnOpj58Y5R3xTvAN2tqqkHSF2kvJCqsJGWn9DOWdfaUP9uiiPzbPeY(vARDquqizCqfY5qWLyH3VJdKMfKsi7xqjuY(XbwAqviNdbxIfEJdLavds48vQMMvqwFUWBCOldLHmnRGNB4TNTs1ih02iiCt)4GeN8euyWQXpbnOc7C96MwbRNIZQBRc)4PaawDdqWEG66190aLka9JAQPzfShOUEDVsgJNMvq(aQRx3tduQa0pQPMMvWIyeG)v8IkE9ZnOCqNX4S9KBqzgD9Gvo6RgOubOFutnFbDgJJK7CQ5NPzf0NVEF1wPA(cw5OV2kvZxWkh9TunYbbPeY(zR0oYbTncc30poiXjpbfoouYy8G4rneYgbK3AcEUH3EDOWlOn74a6W64qZng6BWEG6619u8xnnRGeciYMgabp3WBVou4Hca30Eke8p5ou4Hx)CdculSARPPge0jpbf2HcVG2SJdOdRJdn3yOVb9jjNlHsi7NTs70EcQcD55knFbRccY5wcunnac(NChk8cAZooGoSoo0CJH(gS5eBqviNdbxIfEJdLavds48HSPzfSYrFTvANVGvo6RI3EzbuQaYRMVGGo5jOWou4Hca30EkeK0iiCtVgqkefaUP1TvqFsY5LZxVVARunTNG(KKZro6RTs70EcweZYSs7qHhkaCt7PqWkh9fFfhixjZrZxWIywMvQI)Q5lOaKc5VukrAp)h0zmUwGIli507xtUe]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170409.204707, [[d8JyiaqyQwVQQEPeODHsP8AiIFd1mvv5zsiZMKZlvDtisNgvFtvP65sANszVIDty)kQFcHHrQgNeGEmsgkrgSQy4q6Gk0rvvOoMcohkLQfQilfLQflrlNspuQ0tblJOSojGMikftfHjtunDvUikUQeKlR01r0gLk2kkL0MPOTtk9rvf9zuY0uvY3vLgPeuBtvbJMcJhI6KKIBPQuUMQc5EOuIBJuRvcGJlH6meIauo6XXIoyXbxVAdGOqe)00ycCUL1EsALszaRlyTDnwkKKPaftUK7OIZsqVIlavGEeMM1966OhhlQPPhazeMM1966OhhlQPPhOyYLCLRHcla()nTV0dqZfJmPvuGIjxYvExh94yrntb6ryAw3JWTS2RMMEGpMCj3AisBiebyeEPALNPaJuhhlMF(XRxaG538dJAPxX5Q5hj7sHPl9lqZP3aaZV5hg1sVIZvZps2Lctx6xa2x161nnz6dFyqxVOaaLLJEboo9Yw0ZLMSqeGr4LQvEMcmsDCSy(5hVEbaMFZpmQLEfNRMFyZA6KQlqZP3aaZV5hg1sVIZvZpSznDs1fG9vTEDttM(Whg01lkaqz5OxGC5cunWVWl)OmgzYuaKryAw3JWTS2RMMEGQb(fE5hLXi5HZuaN06AeMyIE0nqjPPzaKryAw3RGt10gcyIfxGrl3vZpn3AXVbQg4xc3YAVAMcGKYrbLb2gGaHe7A(SWeb4c5Ck)W2rbLb2gGDnFwyIauo6XXIrbLb2gycbbbcKgaqxkUR4)9JJfPj7dYcunWVarMcum5sUSHBxQJJfbyxZNfMiGGKwdfwut7Rav0vP6O8QrxScBdrapTHaLPneGvAdbSPnKlq1a)21rpowuZuaKryAw3BK06PPhq(A6KQBu6xaGt3D(HrT0R4Cvbo)iFnDs1fG2rEK8WPPhOuX)))tf(DuPszaxHA4Gb(vsltAdbCfQH3ftx6NKwM0gcWM10jvxMcqZfJKhon9aU617RsALYuaT8kVKR4xprp6gOmaLJECSyuXzjc0LPrWWEa58kQY7j6r3aEaofwuaWy60kspG1fSwIE0nGxYv8RpGtADKYfBMcGCA6bqszhS4a()nTbzbQg43rsRRryItzaxHA4eUL1EsALsBiq1a)osE4mfWUQaDzAemShOIUkvhLxnszaxHA4eUL1EsAzsBiGtA9rbLb2gycbbbcK(JPdrGIjxYvUgHCoLFyBntbo3YAVrbLb2gycbbbcKYUMplmrG(05BfqD2USV0)WWW3lsxMSVRhZV91hf4ClR96GfhC9QnaIcr8ttJjasDK50K0ZpeC6nTI0d0JW0SUxbNQP9THaaLLJEbc4kudFu969vjTsPneGctx6NKwMuga1YPDBFhS4a()nTbzbqTlfMU0VrPFbaoD35hg1sVIZvf48dQDPW0L(fOlgTF(HahGrT0R4C18ZicMa0oYJmPPhGWvR4MF(0IjrttpW5ww7jPLjLb6ryAw3tJqoNYpSTMMEGQb(vsRuMc0JW0SU3iP1ttpaYimnR7PriNt5h2wttpask7GfxajI5hWf15NMBT43aoP1j6r3aLKMMbCsRdORsPHnPPhOAGF1iKZP8dBRzkaTJmqK2qax969vjTmzkGKLt72(5NUo6XXI5NrsRhiq1a)kPLjtbOW0L(jPvkLbo3YAVoyXfqIy(bCrD(P5wl(naNclauNIlyL2hfajLDWIdUE1garHi(PPXeGMlaI00dCUL1EDWId4)30gKfOAGFhzYuakh94yrhS4cirm)aUOo)0CRf)gWvOgExmDPFsALsBiaJWlvR8mfOYPrv7icM0KfOysofsyR8kC9QnGhO50Bag1sVIZvZpswoTB7diz50UTF(PRJECSiW5ww7vdunWVfC7l5c5CbRAMcq5Ohhl6GfhW)VPnila7RA96MMm9HVR)LUm22GSI0)QOaLk())FQWVPmaQLt72EnuybW)VP9LEaxHA4Gb(vsRuAdbkMCjx5DWId4)30gKfWvOg(O617RsAzsBiqXKl5kVGt1mfOAGFHx(rzmIGjtbCsRxib)cGQ8(1Mlba]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170409.204707, [[d8dmiaqyPwVQQEjPuTlIs8Afu)gQzcrTmsy2uCEf6MiLCAu(grPCzL2jvTxXUjSFvXpHWWqvJJOKEUKgkLmyvPHJWbLOJIuQ6ykY5iLOfQQSuIIftKLtLhQapf8yeToIs1ejL0uH0KjQMUkxKKUkPuEge56izJsWwrkfBMsTDs0hvq(ms10uvX3vuJucLTPQsJMunEKItskUfPeUMeQUhsPYTrL1IukDCjKZuqdq2ehdlkGfhCJMnacTHISgVAGRD03ZsPvKc4Ab9DG(soC(cue1sTLggDb3kUaKbgryBx3BqtCmSOgpFaAqyBx3BqtCmSOgpFGIOwQvUgsSay)34)HpahtuQgVIafrTuR8bnXXWIA(cmIW2UUhA7OVxnE(a0EQLARbn(PGgqv0sMvE(cusEmS45fzw9Ixwd4BUnaOI8ZRQz5wX1MNxl3sI5K6lGmRz76gVc(PFN45rkaq6yexGJXT0o(CXRiObufTKzLNVaLKhdlEErMvV4)nGV52aGkYpVQMLBfxBEE16A3uMlGmRz76gVc(PFN45rswMcaKogXfixUavD8mmZos9s1ifGge2219qBh99QXZhGrIfartYe0JV4bAkxRryJrhj2asu22bgtbT43IZRLt8AjsYgsiX)JSIeFS1IFkEaBS4cu6yT5513ohEoqvhpJ2o67vZxGHLkfK6yxauewYOzOIHgGjKZi7d7kfK6yxaz0muXqdq2ehdlkfK6yxGpeOOiOvaGyjzTH9VpgweVIFveOQJNb08fOiQLA1kZTKhdlciJMHkgAabfNgsSOg)pbQeRXuW0v9byd2f0aD8tbCXpfGE8tbKIFkxGQoEEqtCmSOMVa0GW2UUxjLRJNpG81UPmxPfYbag3GNxvZYTIRnY(ZR81UPmxaUMMsQdhpFajd7))Hm45sJjsbAdHEd64zlLQXpfOne69amNuFwkvJFkGwx7MYC5lqBM7XQLsR8fqjRYKyg2nIosSbKcq2ehdlknm6Iadu9OQYeqoRsy6r0rInazaoMOK6WXRiGRf0x0rInqlXmSBmqt5AAXeB(cizy))pKbphPadlvaloG9FJFsrG2qO3LM5ESAPun(PaTHqVrBh99SuAf)uGQoEUKY1Ae24ifWTMadu9OQYeOsSgtbtx1JuG2qO3OTJ(EwkvJFkqvhpxsD4ifOiQLALRriNr2h2vZxagjwqBXyU4rIpW1o67vki1XUaFiqrrqlz0muXqdCTJ(EfWIdUrZgaH2qrwJxnaTAAyCuCpVOmUnEK4dqdcB76EA)RgpFaG0XiUavMGUzd0gc9U0m3JvlLwXpfGM45dq4yCTBSawCa7)g)KIaeULeZj1xPfYbag3GNxvZYTIRnY(ZlHBjXCs9fGeZj1NLs1ifGRPPunE(aOTzf3Z7qomfr88bU2rFplLQrkWamX4ZlkoGQz5wX1MN3seQbQ64zlLw5lWicB76EAeYzK9HD145dmIW2UUxjLRJNpaniSTR7PriNr2h2vJNpqrumYHPnSkCJMnGuGMY1OJeBajkB7avD8SgHCgzFyxnFbAkxdeRXOrRXZhOnZ9y1sPA(cu1XZwkvZxGQoEUunsbiXCs9zP0ksbSCmU2n(8oOjogw88ws56afmn3(8c6yYHdCTJ(EfWIlGf6Zl0I6ZRVDo8CGHLkGfhCJMnacTHISgVAaoMaqJxrGRD03RawCa7)g)KIavD8mmZos9sQdNVaKnXXWIcyXfWc95fAr9513ohEoqBi07byoP(SuAf)uavrlzw55lqLXry2seQXRiWWsfWIlGf6Zl0I6ZRVDo8CaFZTbunl3kU288wIqnaxtdGgpFazwZ21nEf8tYg)p8kKLjfiX)dsbQ64zTVJsmHCMGEnFbiBIJHffWIdy)34NueWYX4A34Z7GM4yyraxFmCachJRDJAiXcG9FJ)h(anLRlfK6yxGpeOOiOfYQfqdue1sTYlGfhW(VXpPiWicB76EA)RgpFGIOwQvU2)Q5lqBi0BqhpBP0k(PanLR1MGDbim946YLa]] )




end
