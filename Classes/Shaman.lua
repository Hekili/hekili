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
if ( select(2, UnitClass('player')) == 'SHAMAN' ) then

    ns.initializeClassModule = function ()

        setClass( 'SHAMAN' )
        -- Hekili.LowImpact = true

        addResource( 'mana', SPELL_POWER_MANA )
        addResource( 'maelstrom', SPELL_POWER_MAELSTROM, true )

        -- Hackish to just leave this here, but...
        Hekili.DB.profile.clashes.windstrike = Hekili.DB.profile.clashes.windstrike or 0.25

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
        addAura( 'hot_hand', 215785, 'duration', 15 )
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
        addGearSet( 'smoldering_heart', 151819 )
        addGearSet( 'soul_of_the_farseer', 151647 )
        addGearSet( 'spiritual_journey', 138117 )
        addGearSet( 'storm_tempests', 137103 )
        addGearSet( 'uncertain_reminder', 143732 )


        setTalentLegendary( 'soul_of_the_farseer', 'enhancement',   'tempest' )
        setTalentLegendary( 'soul_of_the_farseer', 'elemental',     'echo_of_the_elements' )
        setTalentLegendary( 'soul_of_the_farseer', 'restoration',   'echo_of_the_elements' )


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
            desc = "If |cFF00FF00true|r, the addon will use action lists which prioritize spending large amounts of Maelstrom quickly in an attempt to trigger Ascendance.\n\n" ..
                "This requires the Smoldering Heart legendary to function.",
            width = "full",
        } )

        ns.addMetaFunction( 'state', 'gambling', function ()
            return spec.elemental and equipped.smoldering_heart and settings.elemental_gambling
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

        ns.addSetting( 'st_fury', false, {
            name = "Enhancement: Single-Target Fury",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not recommend Fury of Air when there is only one-enemy.  It will still budget and pool Maelstrom for Fury of Air (if talented accordingly), in case of AOE.\n\n" ..
                "Simulations for 7.2.5 suggest that Fury of Air is slightly DPS negative in single-target, meaning there is a small DPS loss from using it in single-target.",
            width = "full",
        } )

        ns.addSetting( 'allow_dw_desync', true, {
            name = "Enhancement: Allow Doom Winds to Desynchronize from Ascendance",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not be able to recommend Doom Winds when cooldowns (|cFFFFD100toggle.cooldowns|r) are disabled and Ascendance is not on cooldown (if you've talented for Ascendance).\n\n" ..
                "When |cFF00FF00true|r, the addon will be able to recommend Doom Winds even if Ascendance is not on cooldown, such as when fighting trash and saving Ascendance for a boss fight.",
            width = "full",
        } )

        ns.addToggle( 'hold_t20_stacks', false, 'Save Crash Lightning Stacks', "(Enhancement)  If checked, the addon will |cFFFF0000STOP|r recommending Crash Lightning when you have the specified number of Crashing Lightning stacks (or more).  " ..
            "This only applies when you have the tier 20 four-piece set bonus.  This may help to save stacks for a big burst of AOE instead of refreshing the tier 20 two-piece bonus." )

        ns.addSetting( 't20_stack_threshold', 12, {
            name = 'Enhancement: Crashing Lightning Stack Threshold',
            type = 'range',
            desc = "If |cFFFFD100Save Crash Lightning Stacks|r is enabled, the addon will stop recommending Crash Lightning when you at least this number of Crashing Lightning Stacks.  " ..
                "This only applies when you have the tier 20 four-piece set bonus.",
            width = "full",
            min = 0,
            max = 15,
            step = 1
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
            cooldown = 6,
            usable = function ()
                if set_bonus.tier20_4pc == 1 and toggle.hold_t20_stacks and buff.crashing_lightning.stack >= settings.t20_stack_threshold and active_enemies == 1 then return false end
                return true
            end
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

        class.abilities.strike = class.abilities.stormstrike -- For SimC compatibility.

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
                addStack( 'crashing_lightning', 16, 1 )
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
                addStack( 'crashing_lightning', 16, 1 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )

    end


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170716.234424, [[dmKnyaqiPqlsGQnjGgfr5uePzjqAxKyyG4yiyzsONjqyAcuUMayBsb9nfPXPiY5ueL1janpbIUhc1(icoOOyHsqpeLAIeHYfLsDsjWmjc5MOKDss)urunufHAPsupLQPkrUkrOARiKVQie7f6VkQbl0HPSye9yfMmOUSQnlOplfnAr1Pj1QvesETuYSr1TL0Ub(nHHdshxrWYr65s10v66Oy7evFxkW5fLwVIqQ5teTFrgjGLqxI9qJHVyHORA1JURRStX2GCdmE9GnGPi8dng(IE5ZV1pQwecHPqMsOHkfHemibOHO7dQg6Io6zgRwa6yjuLawc92aJKFySq09bvdDrFfnBYVIgSNszGUD0ZqQ56nl6nqdGN753OOxaawpSvqrhiahDwcyImQQvp6ORA1J(erdGtrp)gf9YNFRFuTiectjab9YVlyOJ3Xs4Io78pAXsi)1dwKeDwcyvRE0XfvlILqVnWi5hgleDFq1qx0LLIYsX14hSk5MM3xbTQCGrYpCkgyk2yksYegQesf9LKAayfgOPO0uusjtXgtX14hSk5MM3xbTQCGrYpCkkf9mKAUEZIUCJQns(rVaaSEyRGIoqao6SeWezuvRE0ZnnVVcALD(hTqx1QhDFf0NIezCMJEgAZo6aREIZnnVVcALD(hTcQCJZCILjBn(bRsUP59vqRkhyK8dhyJKmHHkHurFjPgawHbQujLSX14hSk5MM3xbTQCGrYpSu0lF(T(r1IqimLae0l)UGHoEhlHl6SZ)OflH8xpyrs0zjGvT6rhxuniWsO3gyK8dJfIUpOAOl6YsXgtX14hSkHm0SZIWzttvoWi5hofLuYuuwkUg)GvjKHMDweoBAQYbgj)WPyGPy1oVVurvzWqPhSPOesXjbjfLMIsrpdPMR3SOl3OAJKF0laaRh2kOOdeGJolbmrgv1Qh9qgAw25F0Asqqx1QhDFf0NIezCMNIYiif9m0MD0bw9ehYqZYo)JwtcsqLBCMtSSgxJFWQeYqZolcNnnv5aJKFyjLu2A8dwLqgA2zr4SPPkhyK8dhy1oVVurvctcIuPOx(8B9JQfHqykbiOx(DbdD8owcx0zN)rlwc5VEWIKOZsaRA1JoUOAWWsO3gyK8dJfIUpOAOl6YsXgtX14hSkHm0SZIWzttvoWi5hofLuYuuwkUg)GvjKHMDweoBAQYbgj)WPyGPy1oVVurvzWqPhSPOesXPqsrPPOu0ZqQ56nl6YnQ2i5h9caW6HTck6ab4OZsatKrvT6rpKHMLD(hTMcbDvRE09vqFksKXzEkkROu0ZqB2rhy1tCidnl78pAnfsqLBCMtSSgxJFWQeYqZolcNnnv5aJKFyjLu2A8dwLqgA2zr4SPPkhyK8dhy1oVVurvctHivk6Lp)w)OArieMsac6LFxWqhVJLWfD25F0ILq(RhSij6SeWQw9OJlQgaSe6Tbgj)WyHO7dQg6IUSuSXuCn(bRsidn7SiC20uLdms(HtrjLmfLLIRXpyvczOzNfHZMMQCGrYpCkgykwTZ7lvuvgmu6bBkkHumybifLMIsrpdPMR3SOl3OAJKF0laaRh2kOOdeGJolbmrgv1Qh9qgAw25F0kybaDvRE09vqFksKXzEkkliKIEgAZo6aREIdzOzzN)rRGfGGk34mNyznUg)GvjKHMDweoBAQYbgj)WskPS14hSkHm0SZIWzttvoWi5hoWQDEFPIQecwaKkf9YNFRFuTiectjab9YVlyOJ3Xs4Io78pAXsi)1dwKeDwcyvRE0XfvBiwc92aJKFySq09bvdDrxwk2ykUg)GvjKHMDweoBAQYbgj)WPOKsMIYsX14hSkHm0SZIWzttvoWi5hofdmfR259LkQkdgk9GnfLqkwmaPO0uuk6zi1C9MfD5gvBK8JEbay9WwbfDGaC0zjGjYOQw9OhYqZYo)Jwfda6Qw9O7RG(uKiJZ8uuwWKIEgAZo6aREIdzOzzN)rRIbiOYnoZjwwJRXpyvczOzNfHZMMQCGrYpSKskBn(bRsidn7SiC20uLdms(HdSAN3xQOkHIbqQu0lF(T(r1IqimLae0l)UGHoEhlHl6SZ)OflH8xpyrs0zjGvT6rhxuDkwc92aJKFySq09bvdDrxwk2ykUg)Gvri)0rUrBELdms(HtrjLmfLLIRXpyveYpDKB0Mx5aJKF4umWuSAN3xQOQmyO0d2uucP4uiPO0uuk6zi1C9MfD5gvBK8JEbay9WwbfDGaC0zjGjYOQw9Op5SNyHGpfc6Qw9O7RG(uKiJZ8uuwaKIEgAZo6aREINC2tSqWNcjOYnoZjwwJRXpyveYpDKB0Mx5aJKFyjLu2A8dwfH8th5gT5voWi5hoWQDEFPIQeMcrQu0lF(T(r1IqimLae0l)UGHoEhlHl6SZ)OflH8xpyrs0zjGvT6rhxuDsyj0Bdms(HXcr3hun0fDzPyJP4A8dwfH8th5gT5voWi5hofLuYuuwkUg)Gvri)0rUrBELdms(HtXatXQDEFPIQYGHspytrjKIneskknfLIEgsnxVzrxUr1gj)OxaawpSvqrhiahDwcyImQQvp6to7jwi4nec6Qw9O7RG(uKiJZ8uuwdLIEgAZo6aREINC2tSqWBiKGk34mNyznUg)Gvri)0rUrBELdms(HLuszRXpyveYpDKB0Mx5aJKF4aR259LkQsOHqKkf9YNFRFuTiectjab9YVlyOJ3Xs4Io78pAXsi)1dwKeDwcyvRE0XfvNmSe6Tbgj)WyHO7dQg6IUSu8tGrdf6Hv6vbh(unO5C(n6MIsrpdPMR3SOl3OAJKF0laaRh2kOOdeGJolbmrgv1Qh98B0T9ey0qHEy0vT6r3xb9PirgN5POSPsrpdTzhDGvpX53OB7jWOHc9WbvUXzoXY(ey0qHEyfcbGWKimzsrV8536hvlcHWucqqV87cg64DSeUOZo)JwSeYF9GfjrNLaw1QhDCrvcqWsO3gyK8dJfIUpOAOl6YsXpbgnuOhwXAzAatF2i7coZ(5jkM(QhpfLIEgsnxVzrxUr1gj)OxaawpSvqrhiahDwcyImQQvp6wltdyApbgnuOhgDvRE09vqFksKXzEkkBssrpdTzhDGvpXwltdyApbgnuOhoOYnoZjw2NaJgk0dRqiiMczsbtk6Lp)w)OArieMsac6LFxWqhVJLWfD25F0ILq(RhSij6SeWQw9OJlQsGawc92aJKFySq09bvdDrxwkk3OAJKFfRLPbmTNaJgk0dNIbMIKmHHk5IDo3aWkmqtXatXgtrsMWqLqQOVKudaRWanfLIEgsnxVzrxUr1gj)OxaawpSvqrhiahDwcyImQQvp6wltdyY4ORA1JUVc6trImoZtrztMu0ZqB2rhy1tS1Y0aMmEqLBCMtSm5gvBK8RyTmnGP9ey0qHE4ajzcdvYf7CUbGvO3gBGnsYegQesf9LKAayfgOsrV8536hvlcHWucqqV87cg64DSeUOZo)JwSeYF9GfjrNLaw1QhDCrvcfXsO3gyK8dJfIUpOAOl6YsXgtrsMWqfUUz(c0GMZdQ1ZvyGMIbMI9VZKcatxz1NweYCrOJuucPiKuuk6zi1C9MfD5gvBK8JEbay9WwbfDGaC0zjGjYOQw9Olr6M5lqdAYMA9CvXkXHIUQvp6(kOpfjY4mpfLraIu0ZqB2rhy1tSePBMVanOjBQ1ZvfRehAqLBCMtSSgjzcdv46M5lqdAopOwpxHbAG9VZKcatxz1NweYCrOdPOx(8B9JQfHqykbiOx(DbdD8owcx0zN)rlwc5VEWIKOZsaRA1JoUOkHGalHEBGrYpmwi6(GQHUOllfLLIKmHHkghAUn3abpuH(QPb9umitXIPyGPijtyOIXHMBZnqWdvOVAAqpfdYuSykgyksYegQyCO52Cde8qf6RMg0tXGmflMIstXatXWtn(ChQMQxf6RMg0trjKIblfLIEgsnxVzrxUr1gj)OxaawpSvqrhiahDwcyImQQvp6ghAUnre8q25F0cDvRE09vqFksKXzEkkJabPONH2SJoWQNyJdn3MicEi78pAfu5gN5eltg0VkHurFNBGGhQqYegQyCO52Cde8qf6RMg0dYIbc9RsO(0SZnqWdvizcdvmo0CBUbcEOc9vtd6bzXaH(vHRBMVanO5Cde8qfsMWqfJdn3MBGGhQqF10GEqwuAGHNA85ounvVk0xnnOlHGjf9YNFRFuTiectjab9YVlyOJ3Xs4Io78pAXsi)1dwKeDwcyvRE0XfvjemSe6Tbgj)WyHONHuZ1Bw0z6FwVV2rVaaSEyRGIoqao6SeWezuvRE0rx1QhDjE)Pyb7RD0lF(T(r1IqimLae0l)UGHoEhlHl6SZ)OflH8xpyrs0zjGvT6rhxuLqaWsO3gyK8dJfIEgsnxVzrFyC(SnwTamZ19f9caW6HTck6ab4OZsatKrvT6rhDvRE0zBCEkMzSAbifLiDFrpdTzhDGvpXb31v2PyBqUbgVEWgWuua9Gtdo6Lp)w)OArieMsac6LFxWqhVJLWfD25F0ILq(RhSij6SeWQw9O76k7uSni3aJxpydykkGEWP4IQeAiwc92aJKFySq09bvdDrNKjmuX6JdGnW4kmqrpdPMR3SOpmoF2gRwaM56(IEbay9WwbfDGaC0zjGjYOQw9OJUQvp6SnopfZmwTaKIsKUVPOmcsrpdTzhDGvpXb31v2PyBqUbgVEWgWu06JGJE5ZV1pQwecHPeGGE53fm0X7yjCrND(hTyjK)6blsIolbSQvp6UUYofBdYnW41d2aMIwFGlQsykwc92aJKFySq0ZqQ56nl6dJZNTXQfGzUUVOxaawpSvqrhiahDwcyImQQvp6ORA1JoBJZtXmJvlaPOeP7BkkROu0ZqB2rhy1tCWDDLDk2gKBGXRhSbmfjzcd7bh9YNFRFuTiectjab9YVlyOJ3Xs4Io78pAXsi)1dwKeDwcyvRE0DDLDk2gKBGXRhSbmfjzcd74IQeMewc92aJKFySq0ZqQ56nl6dJZNTXQfGzUUVOxaawpSvqrhiahDwcyImQQvp6ORA1JoBJZtXmJvlaPOeP7BkkliKIEgAZo6aREIdURRStX2GCdmE9GnGPiBjwp4Ox(8B9JQfHqykbiOx(DbdD8owcx0zN)rlwc5VEWIKOZsaRA1JURRStX2GCdmE9GnGPiBjwhxuLWKHLqVnWi5hgle9mKAUEZI(W48zBSAbyMR7l6faG1dBfu0bcWrNLaMiJQA1Jo6Qw9OZ248umZy1cqkkr6(MIYcMu0ZqB2rhy1tCWDDLDk2gKBGXRhSbmfhc6do6Lp)w)OArieMsac6LFxWqhVJLWfD25F0ILq(RhSij6SeWQw9O76k7uSni3aJxpydykoe0JlQwecwc92aJKFySq0ZqQ56nl6dJZNTXQfGzUUVOxaawpSvqrhiahDwcyImQQvp6ORA1JoBJZtXmJvlaPOeP7BkklasrpdTzhDGvpXb31v2PyBqUbgVEWgWumuZ5NgC0lF(T(r1IqimLae0l)UGHoEhlHl6SZ)OflH8xpyrs0zjGvT6r31v2PyBqUbgVEWgWumuZ5NIlUO7q)qBC9eTTAbavl2WGaxeba]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170716.234424, [[deZWbaGEuO2fkQTjsntPQmBQ6Ms42sANuzVKDR0(Punmu1VvzOOadMsz4sLdksogQSqk0sHIftrlhQEOi6PGhlL1HczIqPAQIYKHy6cxuQYLrUUiSvuQ2mukBhf5WQAAsv1ZH0YKOplQgnLCAfNeLY3OGRbL48OeVgL0FHs6zOGwCkta2jS9j8HmkW9vsam1K2T1BT(TrvAdgz3who1UQ5hcWqE6rj5k55mWBGlnZL89ZJL0cGg(0fceKQfZTOktooLjO3(MEcrgfan8PleexEUNyU7I5wubPmh)eSiO7I5wbSTit7JdxWEljO4qy)XDFLeiW9vsadUyUvagYtpkjxjpNboEbyi0lbEJqvMcbjTOgRfhtuL2qMckoe3xjbkKRuzc6TVPNqKrbPmh)eSiWp5wXoBowrTgYJiGTfzAFC4c2Bjbfhc7pU7RKabUVsc6BYTID2C72aRH8icWqE6rj5k55mWXladHEjWBeQYuiiPf1yT4yIQ0gYuqXH4(kjqHcbqh1M3pm(J5w5ktZqfs]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170716.234424, [[d4ZKlaGEqb1MOs1UqQ2gvI2hOOzck1YOIMTcZNk0nLKtJ4BGkxgANQyVIDdSFPmkQugginosu68kspNQgSunCsYbbvDkQKoMK64GczHeHLsclgjlNWdjPEkQhlX6OsOMivczQePjRstxvxuPQRckqpJkW1vkBeuq2kr0MvQSDf1HP8vQe8zq8DqH62k5VkIrtuVgPCssKPrIQRrf09aLCisuCoqb8BsDQJ0WUiCNTn(iryUiiQ(WHvGd08yooHwdhu4QDjDNqvouh6YWSkSqSbbg2EIgKJtx6GWWxEIg4J0CQJ0W7bg1aVrIWCrqu9HNnbXOgi9DBIPQLXcnNomm8uKb5NggnXlJGjEveAyyLaxsXETimqdWWv6RKM4ylmC4JTWW7nXlJGwNvrOHHvGd08yooHwdxn0WkqVEtuqFKMpSAzSqRspJle8HkCL(ESfgoFooJ0W7bg1aVrIWCrqu9HvMwNAB3o6fH5LNmiqKFabaH(MQw39w3kpzgNGaCrqFRdty16oddpfzq(PHlcZlpzqGi)acasyLaxsXETimqdWWv6RKM4ylmC4JTWWQfMxU1HnbI8diaiHvGd08yooHwdxn0WkqVEtuqFKMpSAzSqRspJle8HkCL(ESfgoFooisdVhyud8gjcdpfzq(PHHXeW1RbqcRe4sk2RfHbAagUsFL0ehBHHdFSfg2fiGRxdGewboqZJ54eAnC1qdRa96nrb9rA(WQLXcTk9mUqWhQWv67Xwy485O8in8EGrnWBKimxeevFyR8KzCccWfb9TomHvRRSTUJo26U16w5jZ4eeGlc6BDycRw3LTU7T(Bde80lcZltaqM4FTyrhbg1aVTURHHNImi)0WfH5LNmiqKFabajSsGlPyVwegOby4k9vstCSfgo8Xwyy1cZl36WMar(beaKw3TAxdRahO5XCCcTgUAOHvGE9MOG(inFy1YyHwLEgxi4dv4k99ylmC(CCyKgEpWOg4nsegEkYG8tddJjGR)feAyyLaxsXETimqdWWv6RKM4ylmC4JTWWUabC9VGqddRahO5XCCcTgUAOHvGE9MOG(inFy1YyHwLEgxi4dv4k99ylmC(CCzKgEpWOg4nseMlcIQpm12UD09VwSOeeaeuqFtvR7ERpBcIrnq672etvlJfAoDyy4PidYpnS)1IL)feAyyLaxsXETimqdWWv6RKM4ylmC4JTWW8Rfl)li0WWkWbAEmhNqRHRgAyfOxVjkOpsZhwTmwOvPNXfc(qfUsFp2cdNph4I0W7bg1aVrIWCrqu9HTYtMXjiaxe036WewTUYBDhDS1DR1TYtMXjiaxe036WewTUZw39w)TbcE6fH5Ljait8VwSOJaJAG3w31WWtrgKFA4IW8YtgeiYpGaGewjWLuSxlcd0amCL(kPjo2cdh(ylmSAH5LBDytGi)acasR7MtxdRahO5XCCcTgUAOHvGE9MOG(inFy1YyHwLEgxi4dv4k99ylmC(Cu2in8EGrnWBKimxeevF43gi4PRNrrr2eqq6iWOg4T1DV1NnbXOgi9DBIPQLXcnL7Ww39wFz4W)c9IEztiqW36WewTUYHggEkYG8tdpiqKFabazcLE8HvcCjf71IWanadxPVsAIJTWWHp2cddBce5hqaqADj0JpScCGMhZXj0A4QHgwb61BIc6J08HvlJfAv6zCHGpuHR03JTWW5ZbgisdVhyud8gjcZfbr1h2TwxzA93gi4PRNrrr2eqq6iWOg4T1DV1NnbXOgi9DBIPQLXcnL7Ww31w3rhBD3A93gi4PRNrrr2eqq6iWOg4T1DV1NnbXOgi9DBIPQLXcnLfAR7Ay4PidYpnS)1IL)feAyyLaxsXETimqdWWv6RKM4ylmC4JTWW8Rfl)li0Ww3TAxdRahO5XCCcTgUAOHvGE9MOG(inFy1YyHwLEgxi4dv4k99ylmC(CQHgPH3dmQbEJeH5IGO6dpBcIrnq6gnJa2GNddpfzq(PH3j0(NsyGByLaxsXETimqdWWv6RKM4ylmC4JTWWWqcT)Peg4gwboqZJ54eAnC1qdRa96nrb9rA(WQLXcTk9mUqWhQWv67Xwy485uxhPH3dmQbEJeH5IGO6dtTTBhDz9pr2ax6BQAD3BD3AD3A9ztqmQbs3OzeW2Ey0grLk826U36uB72rFNq7FkHbU03u16U26o6yRRmT(Sjig1aPB0mcyBpmAJOsfEBDxddpfzq(PHh2SnzyE5WkbUKI9AryGgGHR0xjnXXwy4WhBHHHTnBToSnVCyf4anpMJtO1WvdnSc0R3ef0hP5dRwgl0Q0Z4cbFOcxPVhBHHZNtTZin8EGrnWBKimxeevFyR8KzCccWfb9TomHvR7GWWtrgKFAy)g4IccasyLaxsXETimqdWWv6RKM4ylmC4JTWW8g4Iccasyf4anpMJtO1WvdnSc0R3ef0hP5dRwgl0Q0Z4cbFOcxPVhBHHZNtTdI0W7bg1aVrIWCrqu9HTYtMXjiaxe036WewTUdADhDS1NnbXOgiDytGi)acaIAH5Lp6hguvR7OJT(Sjig1aPBdvYMlOh7ulJfAHHNImi)0WfH5LNmiqKFabajSsGlPyVwegOby4k9vstCSfgo8Xwyy1cZl36WMar(beaKw3nh4Ayf4anpMJtO1WvdnSc0R3ef0hP5dRwgl0Q0Z4cbFOcxPVhBHHZNp8XwyyMSu367bYgOGle8U4wVOfy(ea]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170716.234424, [[dadqbaGEjuBsiSlPOTHKMTkDtLQVHu2Pc7LA3e2Vsggk9BsgSIgUu5GsKJPIfkjwQuAXKYYj6HsQEk4XO65OyIcjtvPmzs10fDrjLNjuCDKyRcv2SqPTlu1YKQMMe08KOonIldnAPWHv1jfsDBbxts68crFwc8AKQ1jHSpEZquySpLB6kgaUK0Lgm0Ix8zqp6zp0yPDO2SNTq2QunaDiN8xsXFsucp6PgJHs8KOemEZJJ3mut8Axu3vmaCjPlneE8YKsvOjNIuIICnlVMNQRzeRzsc4AwEnlGRBOKg5sYinivC6AKeLgIwOt4FQKgekbAyxPh3lhFanyy8b0qRItxJKO0qlEXNb9ON9q7WAOfzuuKCKXBonuVbYPVRIhdOiTMHDL(4dObNonm(aAaiH6RznrJxWXakYIwtvhkqPtBa]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170716.234424, [[dWJGhaGEkGAtui7IGTjIAFsjMnvnFPQBckltu6BGkNMODIs7vz3QA)qnkujdtK(TKlJmukanyidxkoiQItHQYXqHZdQAHOkTukQftOLtLhIk1tj9yHwhfqMOusMkfzYcMoWfPq9APINrbPRlQ2ifeBveAZOITJQQpJI(Qus10OazEuqnskaoSkJwQ0Tb5KIiFxuCnrW9Ksk)vk1ZP0HOa1JXmnTveNl3dgVt1Ot2aMo1m5PZsJnBkd4sHJrYcztnO0esEQ2qr55Lg4diRFSzt2qNYteiR3otJLXmn14)e9uyIt1Ot2aMckMm9KqSkFOY8wmYimIlmcCoMeqOlDEqxHMiaJmmgLnbmQVhJasicJAbJsfsinfJ4BkpIsVea)urFvbFUfmnPpiJhOCt)6PPWQqINJ9GOPtzpiAQbGCL0cn1m5PZsJnBkd4yKo1mzRCxKSZ0at5Ulf7aR4NGOhmXPWQa7brthySzNPPg)NONcJ3PA0jBatbftMEsiwLpuzElgzegXfgjMZHJWzJ0hUpsc5nyuFpgXfgXHCNVTTr6KabhbDY3IrTGrjGr8Hr99yKN4N8yKHXigPPyeFt5ru6La4Nksol56iFMtt6dY4bk30VEAkSkK45ypiA6u2dIMYl5SKRJ8zo1m5PZsJnBkd4yKo1mzRCxKSZ0at5Ulf7aR4NGOhmXPWQa7brthySg6mn14)e9uy8ovJozdykOyY0tcXQ8HkZBXiJWiUWiXCoCeoBK(W9rsiVbJ67XiUWioK78TTnsNei4iOt(wmQfmkbmIpmQVhJ8e)KhJmmgXinfJ4BkpIsVea)urFvH2CYDWpnPpiJhOCt)6PPWQqINJ9GOPtzpiAkV(QcyKHK7GFQzYtNLgB2ugWXiDQzYw5UizNPbMYDxk2bwXpbrpyItHvb2dIMoWynOzAQX)j6PW4DQgDYgWuqXKPNeAkGSElgzegXfgjMZHJWzJ0hUpsc5nyuFpgzWye480deoBK(W9rsG(t0tbmYimId5oFBBJ0jbcoc6KVfJAbJsaJ67XiW5ysabGeIAdQ2bjHrgU1WOKtXi(MYJO0lbWpTPaY6NM0hKXduUPF90uyviXZXEq00PShen1awaz9tntE6S0yZMYaogPtnt2k3fj7mnWuU7sXoWk(ji6btCkSkWEq00bgBcZ0uJ)t0tHX7un6KnGPGIjtpjeRYhQmVDkpIsVea)uoK78TTnsNemnPpiJhOCt)6PPWQqINJ9GOPtzpiAQHqUZJrAJ0jbtntE6S0yZMYaogPtnt2k3fj7mnWuU7sXoWk(ji6btCkSkWEq00bgBYZ0uJ)t0tHX7un6KnGPCHrCHrgmOyY0tcXQ8HkZBXiJWilbaYNPv48(kt7qM2bYc)hXi(WO(EmkwLpuzEHZgPpCFKeCe0jFlg1cgLmgXhg13JrGZtpqqSY9bYXrAbc0FIEkGr99yuGeZ5WrGohOl9TTnYoKqEZuEeLEja(PHQGANr(b70K(GmEGYn9RNMcRcjEo2dIMoL9GOPTQkimQ1LFWo1m5PZsJnBkd4yKo1mzRCxKSZ0at5Ulf7aR4NGOhmXPWQa7brthySWnttn(prpfgVt1Ot2aMckMm9KqSkFOY8wmYimsmNdhHZgPpCFKecvMhJmcJ4cJeZ5WrWckhKOt(mjNqEdg13JrXQ8HkZlybLdYcCYoKGJGo5BXOwWOumIVP8ik9sa8tpBK(W9rAAsFqgpq5M(1ttHvHeph7brtNYEq0uESr6d3hPPMjpDwASztzahJ0PMjBL7IKDMgyk3DPyhyf)ee9GjofwfypiA6admL9GOPQeIBmY4V79rcIEGbcJ4Uv2b2a]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170716.234424, [[d4d9iaGEIQsBIqSlf12ukAFkLAMsfAzKkZwI5duCtf50K8nPsxgANQYEf7g0(L0pvk0WOOFJ05jGHcKyWsz4aXbjKofqvhtQ6CevflKiSucAXQQLJ4HKINI6XkzDevrtKOkmvc1KbmDvUib65k8mIQQRtHnkvWwjI2mrz7ePBtPXPuW0ukzEaj9AsPdt1OvQ(mPQtsu5VsfDnGk3di1OakDiIQuhNOk50hXHLhOm3OCrIW8IOa5chwiwqFG5PZSVRz3(nN1zULj42mmdcUuErjF9trH5PBt5pSORtrHJioV(ioSGq)xqGiryEruGCHTowghHANxgeccVAduRTEDMHf9RkQtGWe6s7xDijSCqa1YpkjmKcXWtuajDYZTy4Wp3IHfsxA)QdjHfIf0hyE6m772BgwioOgKfoI4CH1SJlTtuPOfHx(HNOap3IHZLNUioSGq)xqGiryEruGCH)gYKnlR4w8Oq9g4mbTUcoQnqT22AEdHf9RkQtGWYkUfpkuVbgwoiGA5hLegsHy4jkGKo55wmC4NBXWDO4w8Oq9gyyHyb9bMNoZ(U9MHfIdQbzHJioxyn74s7evkAr4LF4jkWZTy4C5j)rCybH(VGarIW8IOa5cd2A78ccV5fXh7kO(ohhLyNrO)liqTbgWuB(6usXoriAv4O22g01MUAd81Mi1ga(nKjBgDYTJWohGO0IZgGuBIuBwhlJJqTZldcbHxTTnORTTmRnrQnPor5)coVrnGcLw20mSOFvrDceEr8XENfL(9dQG6dlheqT8JscdPqm8efqsN8Clgo8ZTyyneFSxBDuPF)GkO(WcXc6dmpDM9D7ndlehudYchrCUWA2XL2jQu0IWl)WtuGNBXW5YBRioSGq)xqGiryEruGCHpVGWBE3vLXrj2ze6)ccuBIuBFdzYMLrOJ7tCiWmbTUcoQnqT22AEd1Mi1M1XY4iu78YGqq4vBBxBBzgw0VQOobclJqh3N4qGWYbbul)OKWqkedprbK0jp3IHd)ClgUde64(ehcewiwqFG5PZSVBVzyH4GAqw4iIZfwZoU0orLIweE5hEIc8ClgoxEGlIdli0)feiseMxefixyPor5)co7ADf0qq5LHceqqGAtKAtExBFdzYMLrOJ7tCiWSbi1Mi1M1XY4iu78YGqq4vBBd6ARl4cl6xvuNaHLrOJ7tCiqy5GaQLFusyifIHNOas6KNBXWHFUfd3bcDCFIdbQnW2d(WcXc6dmpDM9D7ndlehudYchrCUWA2XL2jQu0IWl)WtuGNBXW5YBZioSGq)xqGiryr)QI6ei8WacGefuFy5GaQLFusyifIHNOas6KNBXWHFUfdZgqaKOG6dlelOpW80z23T3mSqCqnilCeX5cRzhxANOsrlcV8dprbEUfdNlVUrCybH(VGarIW8IOa5cBDSmoc1oVmieeE122GU2aNzTjsTj1jk)xW5nQbuO0sxZAtKAtQtu(VGZYmicOzhxA3Gzyr)QI6eiCXL6Dw8XEy5GaQLFusyifIHNOas6KNBXWHFUfd3rxQxBD0h7HfIf0hyE6m772BgwioOgKfoI4CH1SJlTtuPOfHx(HNOap3IHZL3gI4Wcc9FbbIeHf9RkQtGWe6s7xDijSCqa1YpkjmKcXWtuajDYZTy4Wp3IHfsxA)Qdj1gy7bFyHyb9bMNoZ(U9MHfIdQbzHJioxyn74s7evkAr4LF4jkWZTy4C5jFI4Wcc9FbbIeH5frbYfgS1M1XY4iu78YGqq4vBBd6ABtWvBGbm125feEZlIp2vq9DookXoJq)xqGAdmGP281PKIDIq0QWrTTnORnD1g4RnrQnPor5)coVrnGcLw20S2eP2K6eL)l4SmdIaA2XL2Taxyr)QI6ei8I4J9olk97hub1hwoiGA5hLegsHy4jkGKo55wmC4NBXWAi(yV26Os)(bvq91gy7bFyHyb9bMNoZ(U9MHfIdQbzHJioxyn74s7evkAr4LF4jkWZTy4C51BgXHfe6)ccejcl6xvuNaHLvClEuOEdmSCqa1YpkjmKcXWtuajDYZTy4Wp3IH7qXT4rH6nWAdS9GpSqSG(aZtNzF3EZWcXb1GSWreNlSMDCPDIkfTi8Yp8ef45wmCUCHFUfdZkRMAtq4UdxOfHN8S2KPkfKKlb]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170716.234424, [[dOJNgaGEij1MiGDrQ2gfv7dsQMjKeMnvUPs5Bkv2je7vA3a7xWOGu0Wuv9BqlJO60KmyHgor5GQkDkifoMs6YilKGSuczXQYYH6HkvTkiL8yfEUIMiKenvI0KP00v5IeuVcskpdsPUof2OsuBLIyZKY2HetJIIVRe5ZeX8Gu5qqQ62u1OjuVwjCskshw01OO05vv8xc06GKKNI6UwPLrLKwA4UkuzEGvYUYLfrokNurK)VU7F3Q56Y)nZVznVmlJgQ0Pq15PGGIi3C0U83XPGGzLwK1kTSWG85iBfQmpWkzx5lDe40DjWoDklPtG85iBikqiI(q8zOPP7sGD6uws3qw5VpLtDFkJHJfp1r4YMcSQrEqCzaeqL3Gwtsms6PYLrspvweCS4Pocxwe5OCsfr()6U1)YIOj0apOzL2R8EX0yXgefYtGRVYBqls6PY9kI8kTSWG85iBfQmpWkzxz0hINASqbKeIceI(KCZdd96ddmMaxiI6HOC5L)(uo19PSMb(JGqnbtfUSPaRAKhexgabu5nO1KeJKEQCzK0tLx2a)jeHAH4xfUSiYr5KkI8)1DR)LfrtObEqZkTx59IPXInikKNaxFL3GwK0tL7ve0UsllmiFoYwHkZdSs2voXNslhNE6KjofCjOtthNGfHiQhI)HOaHOmmHIGsgw9vDncNobNYuy1v(7t5u3NYdCoflOtjr8buajLnfyvJ8G4YaiGkVbTMKyK0tLlJKEQ8ECofhIOcLeXhqbKuwe5OCsfr()6U1)YIOj0apOzL2R8EX0yXgefYtGRVYBqls6PY9kIzQ0YcdYNJSvOY8aRKDLrFi(m0001CPNoiqIbPBiR83NYPUpL1CPNoiqIbv2uGvnYdIldGaQ8g0AsIrspvUms6PYl7spDqGedQSiYr5KkI8)1DR)LfrtObEqZkTx59IPXInikKNaxFL3GwK0tL7veZwPLfgKphzRqL5bwj7kFPJaNU4u5Mhe71jq(CKnefierFi(m0001WW59WjWQBilefierjXQ85iDnd8N9IPXcZy2YFFkN6(uwddN3dNaBztbw1ipiUmacOYBqRjjgj9u5YiPNkVmgoVhob2YIihLtQiY)x3T(xwenHg4bnR0EL3lMgl2GOqEcC9vEdArspvUxrmVsllmiFoYwHkZdSs2v(zOPPR5spDqGedsht(ubMHi6crZdruleLmSHOaH4acDw4saDle6fCjfWo1XKpvGziIUquYWgIOvikV83NYPUpL1CPNoiqIbv2uGvnYdIldGaQ8g0AsIrspvUms6PYl7spDqGedkerZv0OSiYr5KkI8)1DR)LfrtObEqZkTx59IPXInikKNaxFL3GwK0tL7vKDvAzHb5Zr2kuzEGvYUYx6iWPlovU5bXEDcKphzdrbcXNHMMUggoVhobwDm5tfygIOlenperTquYWgIceIdi0zHlb0TqOxWLua7uht(ubMHi6crjdBiIwHO8YFFkN6(uwddN3dNaBztbw1ipiUmacOYBqRjjgj9u5YiPNkVmgoVhob2qenxrJYIihLtQiY)x3T(xwenHg4bnR0EL3lMgl2GOqEcC9vEdArspvUxVYiPNkZk)(quyG4emipbouvi(m00M9Ab]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20170716.234424, [[dadxcaGEbr7cP02qjMnsUPaFdvANu1Ej7wv7xKAyOQFdAWIKHJIoOi6yuyHIWsvjlMIwUKEOO0tvESepNktuqAQIQjtPPdCruQNjOCDuXwrQAZOKA7QuTmv0xfunnus(UO40iUm0OrHxRcNePYHL6AQu68if)vLIBl06eewgkxluK1nhkGsOnMyH0uKq2ac8L)KLW0UqkSDO8N8gC55AWcTN8SI)ww0wPsyc00swae47uU8gkxJ93MuOvj0sAsOiaA0WUcyG)noMKduJU3sknaw1E4JAbql9D13rutZ3ruJDxbmWpDQXKCGAxif2ou(tEdUg8AxOdYPwqNYfqlldSCeaVJr8bYulaA9De1eq(tLRX(Btk0QeARujmbAfiKYcZ80MH8whOsoqA5WulPjHIaOrZcHXBYqERtJU3sknaw1E4JAbql9D13rutZ3ruluimMov4K360UqkSDO8N8gCn41UqhKtTGoLlGwwgy5iaEhJ4dKPwa067iQjG8HPCn2FBsHwLqlPjHIaOrld5ToqLCGA09wsPbWQ2dFulaAPVR(oIAA(oIAHtERdujhO2fsHTdL)K3GRbV2f6GCQf0PCb0YYalhbW7yeFGm1cGwFhrnbeqZ3ruBKy20Py)m6VGr8bHiDQ2veqca]] )

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20170716.234424, [[dmeenaqiOkvlcvv2eQIAuOQQtjjyxOIHPQCmvPLrQ6zsc10KeX1urX2Ke13GQACOkW5GQuSovvzEsI09urP9HQqhKuzHOk9qjPjkjKUiP0grvqFuvvnsOkPojrvZevrUPKANq5NscXqHQuAPOspfzQeLRcvjzRKcFfQsyVI)QImyQCyPwmrESetwLUmyZKI(SQy0QQCAcVgvLzJYTjz3k9BidxfSCk9CkMUIRdv2orLVdvX5vHwpuLO5RIQ9tvN3ilewRGqKqv170YafStZ8U)BLetSp)5DxqZghBcvrbnBCSj8gIlWG2abt)3l(F4)wzo6)QKVZu5q0bOiAMaVShbAdM(kRpKUYiqRjYc2BKfs72sm4gPquXkomHg0Zdd4uqi2fHN14D8S3XFVBA7dmC(bnB(X5qz8Uk170FgV78Z9UrOaVJh9UpoN57Z7QqiDscMyogsIHqxgoZes(9kk9GSHw0cHQrxnAlwRGqHWAfecVgSiHrfIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfektW0hzH0UTedUH3quXkomHg0Zdd4Canc0A8oE274V3vqi2fHNLJMclCcyGc2PzCSGQfRX74rVtpp4Z7o)CVBA7dmCgHconOtxb4Dv6z9Uk)5DviKojbtmhdDanc0gs(9kk9GSHw0cHQrxnAlwRGqHWAfecVfnc0gIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfektWQ4ilK2TLyWn8gIkwXHj0GEEyahXoG1I7WycPtsWeZXq4rS3tMFqBdj)EfLEq2qlAHq1ORgTfRvqOqyTccHxi2R3r)G2gIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfektWQKilK2TLyWn8gIkwXHjKeon1KJfmOT3cCAqdO4ybvlwJ3vPEN(q6KemXCm0GgqDs1MbShdj)EfLEq2qlAHq1ORgTfRvqOqyTccjdnGY7QBZa2JH4cmOnqW0)9I)7xiUGbHZwatKLju1FqHVAKCGc2jsHQrxSwbHYeSZezH0UTedUH3quXkomHg0Zdd4uqi2fHN1esNKGjMJH0uyHtaduWonlK87vu6bzdTOfcvJUA0wSwbHcH1kiepuybVtlduWonlexGbTbcM(Vx8F)cXfmiC2cyISmHQ(dk8vJKduWorkun6I1kiuMGv5ilK2TLyWn8gIkwXHj0GEEyaNccXUi8SMq6KemXCmKzqw1jGbkyNMfs(9kk9GSHw0cHQrxnAlwRGqHWAfeIgKv5DAzGc2PzH4cmOnqW0)9I)7xiUGbHZwatKLju1FqHVAKCGc2jsHQrxSwbHYem8JSqA3wIb3WBiQyfhMqd65HbCkie7IWZAcPtsWeZXqaduWon7KQndypgs(9kk9GSHw0cHQrxnAlwRGqHWAfeslduWonZ7QBZa2JH4cmOnqW0)9I)7xiUGbHZwatKLju1FqHVAKCGc2jsHQrxSwbHYemEqKfs72sm4gEdPtsWeZXq4mWjXakti53RO0dYgArleQgD1OTyTccfcRvqi8kd4DYpGYeIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfektWWBISqA3wIb3WBiQyfhMqd65HbCkie7IWZA8oE274V3H39UPzWoCAtb2BVfGdSTedUE35N7Ds40utoTPa7T3cWb3bV78Z9UccXUi8SCAtb2BVfGJfuTynEhp6DN5Z7QqiDscMyogsIHq3tAIZEmK87vu6bzdTOfcvJUA0wSwbHcH1kieVme66D8qC2JH4cmOnqW0)9I)7xiUGbHZwatKLju1FqHVAKCGc2jsHQrxSwbHYeS3VilK2TLyWn8gIkwXHj0GEEyaNccXUi8SgVJN9o(7D4DVBAgSdN2uG92Bb4aBlXGR3D(5ENeon1KtBkWE7TaCWDW7QqiDscMyogscSgWYNyFcj)EfLEq2qlAHq1ORgTfRvqOqyTccXlynGLpX(eIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfektWEFJSqA3wIb3WBiQyfhMqDzeYbNGfucW4D8O3PpKojbtmhdzXTN6Yiq7jMWmHKFVIspiBOfTqOA0vJ2I1kiuiSwbH4IB9oDLrGwVJNeMjKo7Jj02k4S8JeQQENwgOGDAM39FRKyI95pVtxfrl)cXfyqBGGP)7f)3VqCbdcNTaMiltOQ)GcF1i5afStKcvJUyTccrcvvVtlduWonZ7(VvsmX(8N3PRIOntWE1hzH0UTedUH3quXkomHMMb7WPnfyV9waoW2sm4gsNKGjMJHS42tDzeO9etyMqYVxrPhKn0Iwiun6QrBXAfekewRGqCXTENUYiqR3XtcZ4D8)TcH0zFmH2wbNLFKqv170YafStZ8U)BLetSp)5DgX(WaVRnf(fIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfeIeQQENwgOGDAM39FRKyI95pVZi2hg4DTPKjyVvCKfs72sm4gEdrfR4WeAAgSdhrb0eN9ihyBjgCdPtsWeZXqwC7PUmc0EIjmti53RO0dYgArleQgD1OTyTccfcRvqiU4wVtxzeO174jHz8o(RVcH0zFmH2wbNLFKqv170YafStZ8U)BLetSp)5DgX(WaVtOj)cXfyqBGGP)7f)3VqCbdcNTaMiltOQ)GcF1i5afStKcvJUyTccrcvvVtlduWonZ7(VvsmX(8N3ze7dd8oHMzc2BLezH0UTedUH3quXkomHMMb7WHjE(nRyFozrxoW2sm4gsNKGjMJHS42tDzeO9etyMqYVxrPhKn0Iwiun6QrBXAfekewRGqCXTENUYiqR3XtcZ4D8VIRqiD2htOTvWz5hjuv9oTmqb70mV7)wjXe7ZFENrSpmW7yw(fIlWG2abt)3l(VFH4cgeoBbmrwMqv)bf(QrYbkyNifQgDXAfeIeQQENwgOGDAM39FRKyI95pVZi2hg4DmBMmHOIvCycLjb]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20170716.234424, [[deZwcaGErI2LiPTbPmBjDtk52eTtQAVODty)sWWiv)wQHkcAWIudxIoOO4yKYcfLwQsAXKy5u5HsONcEmeRteyIIOmvk1KHY0fUOOQlR66IkBfs1Mfr12HK(OiHdR4ZqINRultj(gjz0qLonfNeQyAIqUMiIZts9AOQ)kc1ZerAQrBc(rEcGrwSq681lViMAH0PyKkvJaLeuiDP7iTuzccj7jFYvdMLW6RF2N(fDnv6Q0ql1f9ePNe0iaLhXmvtkNW0c6xqBHqgKW0InTPxJ2eYlgL6XywcaIZugeIgfuQp1YomTytiJIPAc1ek7W0cc4iWmit0ocIwCcwng6JZpYtGGFKNqc7W0ccRV(zF6x01uPPty97oNd5BAZGqrCpcERg1lViOcbRgZpYtGb9l0MqEXOupgZsiJIPAc1eIoUmXYzh3PMaocmdYeTJGOfNGvJH(48J8ei4h5jy3XLfsBn74o1ewF9Z(0VORPstNW63DohY30MbHI4Ee8wnQxErqfcwnMFKNad6tkTjKxmk1JXSeYOyQMqnHD0oj()Y7iGJaZGmr7iiAXjy1yOpo)ipbc(rEcq0oj()Y7iS(6N9PFrxtLMoH1V7CoKVPndcfX9i4TAuV8IGkeSAm)ipbgmiaiotzqGbj]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20170716.234424, [[daK0raqiQsQnrvQrrj1POK8kkrHzrjkAxqLHHehJuTmLWZuvvnnvvHRrvs2gscFtvPXPQk6CijY6OeLAEQQk3tvK9HK0bvvSqLOhIKAIijkxuvLnsjQ(isIQtsjmtQsCtQQDcLLsu9uutfPSvIs7v6VkPbl0HvSyI8yrMSsDzWMHQ(mLA0KYPj8AKQztLBtXUr8Bidxv44QQslNKNlQPRY1vL2ovX3vf15jkwpLOK5tjY(fC1lTYyJbkZcd1H4phyaYnUqKkFmsobX2YoeZcITdcrNQmvgGFEDxxwwo4GjdfBbf9Vu(Qtf4wq5pO4vurz(bKeJtyznNark2cQyr5pPtGi5sRy6Lw5FKrYb7USmNuIhxzVoeprIUGyhIwYsH4gD4W7gdSM1qj64uGzeKCi(VNcr70U8hjHtCYugVBmWAwdLOx2cYwKMdPktqeOSpAl7OWgduUm2yGYwUBmqiYAOe9YYbhmzOylOO)vNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5EfBrPv(hzKCWUll)rs4eNmLbhyaYnUvj3KVYwq2I0CivzcIaL9rBzhf2yGYLXgdu(Ndma5gxiU0n5RSCWbtgk2ck6F1PuwoKrVQeKlTELPwds09rEadqUkv2hTXgduUxX(FPv(hzKCWUllZjL4Xvw6fpECqsdb5ve(1tdwTvWCR5xYgucInU3hL)ijCItMYWOoT)(o0HYwq2I0CivzcIaL9rBzhf2yGYLXgdu(3OoT)(o0HYYbhmzOylOO)vNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5Ef7pkTY)iJKd2DzzoPepUYMbC5tHm4sVkfqUqKQpfI66FdrlzPq0RdXrDc8t6WLFgCobXE1mGlFkKbhqgjhSdrVdrZaU8PqgCPxLcixis1NcrQ0IYFKeoXjtzyuN2AwdLOx2cYwKMdPktqeOSpAl7OWgduUm2yGY)g1PfISgkrVSCWbtgk2ck6F1PuwoKrVQeKlTELPwds09rEadqUkv2hTXgduUxX8QsR8pYi5GDxw(JKWjozkNpKYqhGhGQSfKTinhsvMGiqzF0w2rHngOCzSXaL5dPm0b4bOklhCWKHITGI(xDkLLdz0Rkb5sRxzQ1GeDFKhWaKRsL9rBSXaL7vmQO0k)Jmsoy3LL)ijCItMYoXFFf7vZyBM1dDGPSfKTinhsvMGiqzF0w2rHngOCzSXaL9I4VVIDi6p2MjePHoWuwo4GjdfBbf9V6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3RyFlTY)iJKd2DzzoPepUYB0HdVBmWAwdLOJtbMrqYHivdX0KV1tyGq07qmHqUn6zYQcM0v(JKWjozk7gpZQ0RkFLTGSfP5qQYeebk7J2YokSXaLlJngOSxgptiU8vLVYYbhmzOylOO)vNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5Ef7plTY)iJKd2DzzoPepUYwhIMbC5tHm4sVkfqUqKQpfIlOeIEhIsV4XJdCGbi34wXJsVzCVpcrRcrVdrRdrfGxbzTrYbHOvL)ijCItMY4DJbwZAOe9Ywq2I0CivzcIaL9rBzhf2yGYLXgdu2YDJbcrwdLOhIwRBv5pk7C5Bu2WTkW)KcWRGS2i5GYYbhmzOylOO)vNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5EfJkvAL)rgjhS7YYCsjECLnd4YNczWLEvkGCHivFke111drlzPq0RdXrDc8t6WLFgCobXE1mGlFkKbhqgjhSdrVdrZaU8PqgCPxLcixis1NcX)KkcrlzPqe(7R4XdyJlBqUnOee7vnyuxi6Dic)9v84bSXDAW6gsGWdOYRsoeAV(ysxi6DiAgWLpfYGl9Qua5crQgIFPeIEhI34aYHBWFGkRHs0XbKrYb7YFKeoXjtzyuN2AwdLOx2cYwKMdPktqeOSpAl7OWgduUm2yGY)g1PfISgkrpeTw3QYYbhmzOylOO)vNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5EftNsPv(hzKCWUllZjL4Xvw6fpECkiJidjbRh6adofygbjhI)le1PeIwYsHO1HO0lE84uqgrgscwp0bgCkWmcsoe)xiADik9IhpUjNaYEija3(vnNarcrlJqmHqUn6zcUjNaYEijaNcmJGKdrRcrVdXec52ONj4MCci7HKaCkWmcsoe)xiQ7vHOvL)ijCItMYh6aZQzYhOKPSfKTinhsvMGiqzF0w2rHngOCzSXaLPHoWeI(t(aLmLLdoyYqXwqr)RoLYYHm6vLGCP1Rm1AqIUpYdyaYvPY(On2yGY9kMUEPv(hzKCWUllZjL4Xv26qu6fpECpqpdQve(1tdwnd4YNczW9(ie9oeN0j8aRabmcihI)le)FiAvi6DiADiUbPx84X5e2AhrqSxvOnUn6zsiAv5pscN4KPStyRDebXEvc5UYwq2I0CivzcIaL9rBzhf2yGYLXgdu2lcBTJii2H4sK7k)rzNlFJYgUvb(N2G0lE84CcBTJii2Rk0g3g9mPSCWbtgk2ck6F1PuwoKrVQeKlTELPwds09rEadqUkv2hTXgduUxX0xuAL)rgjhS7YYCsjECLLEXJh3d0ZGAfHF90GvZaU8PqgCVpcrVdXjDcpWkqaJaYH4)cX)x(JKWjozk7e2AhrqSxLqURSfKTinhsvMGiqzF0w2rHngOCzSXaL9IWw7icIDiUe5Uq0ADRklhCWKHITGI(xDkLLdz0Rkb5sRxzQ1GeDFKhWaKRsL9rBSXaL7vm9)xAL)rgjhS7YYCsjECLToeN0j8aRabmcihIune1drVdXjDcpWkqaJaYHivdr9q0Qq07q06qCdsV4XJZjS1oIGyVQqBCB0ZKq0QYFKeoXjt5K2iiRoHT2ree7Ywq2I0CivzcIaL9rBzhf2yGYLXgduMATrqcrViS1oIGyx(JYox(gLnCRc8pTbPx84X5e2AhrqSxvOnUn6zsz5GdMmuSfu0)QtPSCiJEvjixA9ktTgKO7J8agGCvQSpAJngOCVIP)hLw5FKrYb7USmNuIhx5jDcpWkqaJaYHivdr9q07qCsNWdSceWiGCis1quV8hjHtCYuoPncYQtyRDebXUSfKTinhsvMGiqzF0w2rHngOCzSXaLPwBeKq0lcBTJii2HO16wvwo4GjdfBbf9V6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3Ry6EvPv(hzKCWUllZjL4XvEdsV4XJZjS1oIGyVQqBCB0ZKYFKeoXjtzNWw7icI9QeYDLTGSfP5qQYeebk7J2YokSXaLlJngOSxe2AhrqSdXLi3fIwVWQYFu25Y3OSHBvG)Pni9IhpoNWw7icI9QcTXTrptklhCWKHITGI(xDkLLdz0Rkb5sRxzQ1GeDFKhWaKRsL9rBSXaL7vmDQO0k)Jmsoy3LL)ijCItMYoHT2ree7vjK7kBbzlsZHuLjicu2hTLDuyJbkxgBmqzViS1oIGyhIlrUleT()wvwo4GjdfBbf9V6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3Ry6FlTY)iJKd2DzzoPepUYkaVcYAJKdk)rs4eNmLX7gdSM1qj6LPwds09rEadqUUSSpAl7OWgduUSfKTinhsvMGiqzSXaLTC3yGqK1qj6HO1lSQ8hLDUSb5rqSFs3Y8gLnCRc8pPa8kiRnsoOSCWbtgk2ck6F1PuwoKrVQeKlTEL9rEee7IPx2hTXgduUxX0)ZsR8pYi5GDxw(JKWjozkdJ60wZAOe9YuRbj6(ipGbixxw2hTLDuyJbkx2cYwKMdPktqeOm2yGY)g1PfISgkrpeTEHvL)OSZLnipcI9t6LLdoyYqXwqr)RoLYYHm6vLGCP1RSpYJGyxm9Y(On2yGY9kMovQ0k)Jmsoy3LL)ijCItMY4DJbwZAOe9YuRbj6(ipGbixxw2hTLDuyJbkx2cYwKMdPktqeOm2yGYwUBmqiYAOe9q06)Bv5pk7CzdYJGy)KEz5GdMmuSfu0)QtPSCiJEvjixA9k7J8ii2ftVSpAJngOCVEL5Ks84k3Rfa]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20170716.234424, [[de0cuaqiuKAtkbJsPItPuPvrsv1RiPQywKuvAxQQgguCmsSmQINrsLMgksCnLeABkj6BkvnoLeCouK06iPkzEkj19ucTpuuoOQsluj6HOuMijvPUOQInIIOpssv0jrPAMKuXnPQ2PQSuIQNImvuYwjPSxP)IcdwKdRyXe5XuzYq1LbBwP8zIYOPuNMIxdLMTq3Mu7MWVHmCsYXvsYYr1ZfmDvUoLSDQsFhfHZRKA9KufMpkQ2VOUkLvP3OHsKrZwo9jcAqCtmNuphTu0iKPELtbJqweYjZwj1ByBSIxxwsoeHja95bJYEm7vw5VhmmfmR4klrQaNzIg1J5mirFEwPNsFDNbjcLvFkLvPpIrkc4DzjYXnQUsmDoDghwJqwoXCMNt4O7FloAGrWg5W(Zb9yeHCA1lMtYC4L(kzIMBDPT4ObgbBKdBj2f4g3CiEjbsaL8r4Qn83OHsLEJgkXKXrd5ezJCyljhIWeG(8GrzVcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96Ztzv6JyKIaExwICCJQRKK122p4SrqGbAJXzdmKXH5yeSe4a3iK9BPkNwiN0dedhhP)DwCoiUCIzlMtRWkl9vYen36sWWp7vznyHsSlWnU5q8scKak5JWvB4VrdLk9gnu6ZWp7vznyHsYHimbOppyu2RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(u3YQ0hXifb8USe54gvxjjRTTFJd2S4R)TuLtlKt6bIHJJ0)olohexoXSfZjffLCAHCIPZjjRTT)j4ab(iCWVLQsFLmrZTU0ghfogbBKdBj2f4g3CiEjbsaL8r4Qn83OHsLEJgkXKCu4YjYg5WwsoeHja95bJYEfmLKdbKf3bHYQxj2SbhwFKxqdIRsL8r4VrdL61htPSk9rmsraVll9vYen36sqe0G4MidP4eUsSlWnU5q8scKak5JWvB4VrdLk9gnu6te0G4MyoTmoHRKCicta6ZdgL9kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RVvSSk9rmsraVllroUr1vspqmCCK(3zX5G4YjMTyoPOSpNyoZZjMoNg(z2g39hycignczm0dedhhP)bXifb8CAHCspqmCCK(3zX5G4YjMTyoXu9u6RKjAU1LGHF2mc2ih2sSlWnU5q8scKak5JWvB4VrdLk9gnu6ZWp7CISroSLKdrycqFEWOSxbtj5qazXDqOS6vInBWH1h5f0G4QujFe(B0qPE9TYYQ0hXifb8USe54gvxPsFLmrZTUu4qCnwaub8sSlWnU5q8scKak5JWvB4VrdLk9gnuIoexJfavaVKCicta6ZdgL9kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RV9LvPpIrkc4DzjYXnQUs7Kt6bIHJJ0)olohexoT6fZjfmk50c50WpZ24U)ataXOriJHEGy44i9pigPiGNtmN55etNtd)mBJ7(dmbeJgHmg6bIHJJ0)GyKIaEoTqoPhigoos)7S4CqC50QxmN2VYCA3CAHCIPZjjRTT)j4ab(iCWVLQsFLmrZTUKXbBw81LyxGBCZH4LeibuYhHR2WFJgkv6nAOe7oyZIVUKCicta6ZdgL9kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RVvOSk9rmsraVllroUr1vQ0xjt0CRlfnRYYGZqpY0dJdDGUe7cCJBoeVKajGs(iC1g(B0qPsVrdLuhZQSm45K)itp5el0b6sYHimbOppyu2RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(yQLvPpIrkc4DzjYXnQUsswBB)QqmbWzG2yC2ad9aXWXr6Flv50c5KK122F4qCnwaub8Flv50c504oJxGbiaTbc50QZj1T0xjt0CRlfnYSpHriJHekELyxGBCZH4LeibuYhHR2WFJgkv6nAOK6yKzFcJqwoTefVsYHimbOppyu2RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(uWuwL(igPiG3LLih3O6kHJU)T4ObgbBKd7ph0JreYjMLtUjCmoJgYPfYjhcfXrmHGbhg3v6RKjAU1LIJ3HHKfpCLyxGBCZH4LeibuYhHR2WFJgkv6nAOK6mENCAPfpCLKdrycqFEWOSxbtj5qazXDqOS6vInBWH1h5f0G4QujFe(B0qPE9POuwL(igPiG3LLih3O6kjzTT9BCWMfF9VLQCAHCANCspqmCCK(3zX5G4YjMTyo5btoXCMNtswBB)ghSzXx)Zb9yeHCA150o5KY)kMtQ)CkOcIrg2t4GCs9NtswBB)ghSzXx)hUXHnNuFYjLCA3CA3sFLmrZTU0ghfogbBKdBj2f4g3CiEjbsaL8r4Qn83OHsLEJgkXKCu4YjYg5WMt7OSBj5qeMa0Nhmk7vWusoeqwChekRELyZgCy9rEbniUkvYhH)gnuQxFkEkRsFeJueW7YsKJBuDL2jN0dedhhP)DwCoiUCIzlMtEWKtlKtswBB)qe0G4MiJnKZk8BPkN2nNwiN2jN4Wghc2JueYPDl9vYen36sBXrdmc2ih2sSlWnU5q8scKak5JWvB4VrdLk9gnuIjJJgYjYg5WMt7OSBPVCzHs3WLbhdZ2ICyJdb7rkcLKdrycqFEWOSxbtj5qazXDqOS6vInBWH1h5f0G4QujFe(B0qPE9POULvPpIrkc4DzjYXnQUsswBB)ghSzXx)BPQ0xjt0CRlTXrHJrWg5WwInBWH1h5f0G46Ys(iC1g(B0qPsSlWnU5q8scKak9gnuIj5OWLtKnYHnN2XZUL(YLfkPrEnczlQusoeHja95bJYEfmLKdbKf3bHYQxjFKxJqwFkL8r4VrdL61NctPSk9rmsraVllroUr1vspqmCCK(3zX5G4YjMTyoPOOKtmN55etNtd)mBJ7(dmbeJgHmg6bIHJJ0)GyKIaEoTqoPhigoos)7S4CqC5eZwmNwHvMtmN55eSklJkva(FqJI4a3iKXWgg(LtlKtWQSmQub4)NnWahCGXlWdmKIieodvJ7YPfYj9aXWXr6FNfNdIlNywoThtoTqoDtee3)SDapyJCy)bXifb8sFLmrZTUem8ZMrWg5WwIDbUXnhIxsGeqjFeUAd)nAOuP3OHsFg(zNtKnYHnN2rz3sYHimbOppyu2RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(uwXYQ0hXifb8USe54gvxjjRTTFoeqIr4agh6a9ph0JreYPvNtkyk9vYen36sh6and9eoGVUe7cCJBoeVKajGs(iC1g(B0qPsVrdLyHoqNt(t4a(6sYHimbOppyu2RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(uwzzv6JyKIaExwICCJQRKK122p4SrqGbAJXzdmKXH5yeSe4a3iK9BPQ0xjt0CRlbd)SxL1GfkXUa34MdXljqcOKpcxTH)gnuQ0B0qPpd)SxL1GfYPDu2TKCicta6ZdgL9kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RpL9LvPpIrkc4DzjYXnQUsswBB)QqmbWzG2yC2ad9aXWXr6Flv50c504oJxGbiaTbc50QZj1T0xjt0CRlfnYSpHriJHekELyxGBCZH4LeibuYhHR2WFJgkv6nAOK6yKzFcJqwoTefVCAhLDljhIWeG(8GrzVcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96tzfkRsFeJueW7YsKJBuDLg3z8cmabOnqiNywoPKtlKtJ7mEbgGa0giKtmlNuk9vYen36so7XiyenYSpHriRe7cCJBoeVKajGs(iC1g(B0qPsVrdLyZEmICsDmYSpHriRKCicta6ZdgL9kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RpfMAzv6JyKIaExw6RKjAU1LIgz2NWiKXqcfVsSlWnU5q8scKak5JWvB4VrdLk9gnusDmYSpHrilNwIIxoTJNDljhIWeG(8GrzVcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96ZdMYQ0hXifb8USe54gvxjoSXHG9ifHsFLmrZTU0wC0aJGnYHTeB2GdRpYlObX1LL8r4Qn83OHsLyxGBCZH4Leibu6nAOetghnKtKnYHnN2XZUL(YLfkPrEnczlQO(EdxgCmmBlYHnoeShPiusoeHja95bJYEfmLKdbKf3bHYQxjFKxJqwFkL8r4VrdL61NhLYQ0hXifb8US0xjt0CRlbd)SzeSroSLyZgCy9rEbniUUSKpcxTH)gnuQe7cCJBoeVKajGsVrdL(m8ZoNiBKdBoTJNDl9LllusJ8AeYwuPKCicta6ZdgL9kykjhcilUdcLvVs(iVgHS(uk5JWFJgk1RppEkRsFeJueW7YsFLmrZTU0wC0aJGnYHTeB2GdRpYlObX1LL8r4Qn83OHsLyxGBCZH4Leibu6nAOetghnKtKnYHnN2rD3T0xUSqjnYRriBrLsYHimbOppyu2RGPKCiGS4oiuw9k5J8AeY6tPKpc)nAOuVELih3O6k1Rfa]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20170716.234424, [[dae)jaqifjSjLQmkjHoLKGzPuvAxssdtPCmsAzevptsennIuDnLQQTPivFtPY4KejNtsKADePuZtrs3dvI9PuvCqjyHsOhQOAIsIsxurzJks0hjsjNKimtujDtsStf(PKiSue1tHMkc2kr0Ef)fvmyKCyQwmQ6XkzYs1LvTzfXNLuJwIonHxtuMnLUnP2nOFJYWjsoUIuwofpxkth46iY2rOVtKIZJk16LefZxsuTFK6OgcbhU(brHEon1m71hcClnL0Y18wbSwAttvOsmlyL9tCswqkgK8T3Bpd5BQ722Po9QY3K(2(NEquQVeUvuzCGGbZq(0LhSWciyWwiKHAieCg05TVNIblWlSca3bBaMrl7xQBckbSlwoGzcczWhuH1L0ndx)GbhU(braZOL9l1nbjF792Zq(M6o1TGKFJrYSEleci48YVKPWiE9HGWhuH1hU(bdid5HqWzqN3(EkgexgHuGGawDT9vxmMTZKgylybEHva4oO3wh2D46bLa2flhWmbHm4dQW6s6MHRFWGdx)GfARd7oC9GKV9E7ziFtDN6wqYVXizwVfcbeCE5xYuyeV(qq4dQW6dx)GbKrLmecod6823tXGf4fwbG7GwX0ij6C0ET25ayGRdkbSlwoGzcczWhuH1L0ndx)GbhU(b5QyAKeDAkfVw70ueyGRds(27TNH8n1DQBbj)gJKz9wieqW5LFjtHr86dbHpOcRpC9dgqgspecod6823tXG4YiKceSI0u(ciiEohET4nAQPstjDAQ9OP0(TnGHPRUizmhcOP2hUqtjFJMQc0u7rtvrAkZNyER05TNMQcblWlSca3bNyD950kzlzbLa2flhWmbHm4dQW6s6MHRFWGdx)GtP11NMclzlzblyQBbbUP(aoIjCX8jM3kDE7ds(27TNH8n1DQBbj)gJKz9wieqW5LFjtHr86dbHpOcRpC9dgqg7pecod6823tXGf4fwbG7G3nGYPrYL9Gsa7ILdyMGqg8bvyDjDZW1pyWHRFWzUbuonsUShK8T3Bpd5BQ7u3cs(ngjZ6TqiGGZl)sMcJ41hccFqfwF46hmGmMEieCg05TVNIbXLrifiyNbQoX66ZPvYwYQAU2fWgn1(qtT8gGdqOpn1E0u8KMmPQ1j6CAKm1VkjPOP2JMAkOPaU9qqvROUeafWAogwV6HoV9DAQ9OP8fqq8Co8AXB0utLMs6blWlSca3bTorNdpjtdeucyxSCaZeeYGpOcRlPBgU(bdoC9dYvNOttvKKPbcs(27TNH8n1DQBbj)gJKz9wieqW5LFjtHr86dbHpOcRpC9dgqg7cHGZGoV99umiUmcPabNcAkGBpeu1kQlbqbSMJH1REOZBFNMApAkFbeepNdVw8gn1uPP2pnvLx50ua3EiOQvuxcGcynhdRx9qN3(on1E0u(ciiEohET4nAQPstj9Gf4fwbG7G3E9Ha3YH36nqqjGDXYbmtqid(GkSUKUz46hm4W1p4m71hcClnvrR3abjF792Zq(M6o1TGKFJrYSEleci48YVKPWiE9HGWhuH1hU(bdiJkvieCg05TVNIblWlSca3bTorNd)DDqjGDXYbmtqid(GkSUKUz46hm4W1pixDIonvX76GKV9E7ziFtDN6wqYVXizwVfcbeCE5xYuyeV(qq4dQW6dx)GbKrLoecod6823tXG4YiKceSFEstMu1kQlbqbSMJH1R2zsdmybEHva4o4Q0fqowrDjakG1bLa2flhWmbHm4dQW6s6MHRFWGdx)GZlDbKMIRI6sauaRdwWu3ccCt9bCet4s)8KMmPQvuxcGcynhdRxTZKgyqY3EV9mKVPUtDli53yKmR3cHacoV8lzkmIxFii8bvy9HRFWaYqDlecod6823tXGf4fwbG7GRsxa5yf1LaOawhucyxSCaZeeYGpOcRlPBgU(bdoC9doV0fqAkUkQlbqbSMMQIQvii5BV3EgY3u3PUfK8BmsM1BHqabNx(LmfgXRpee(GkS(W1pyazOQgcbNbDE77PyWc8cRaWDqRt05WtY0abNx(LmfgXRpeKIbvyDjDZW1pyqjGDXYbmtqid(Gdx)GC1j60ufjzAaAQkQwHGfm1TGAgrbSMlQbjF792Zq(M6o1TGKFJrYSEleciOcJOawNHAqfwF46hmGmuLhcbNbDE77PyqCzesbcA(eZBLoV9blWlSca3bNyD950kzlzbNx(LmfgXRpeKIbvyDjDZW1pyqjGDXYbmtqid(Gdx)GtP11NMclzlz0uvuTcblyQBb1mIcynxu3xGBQpGJycxmFI5TsN3(GKV9E7ziFtDN6wqYVXizwVfcbeuHruaRZqnOcRpC9dgqabXLrifiyaj]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20170716.234424, [[da0otaqiQcSjc0OuL4uQc9kKeXSesb7sknmOYXOQwMKYZqsQPjKQUMqQSnjv8nOOXjKsNdjrToHuuZtsLUNKQ2NQGdcfwOQOhsatuif6IQsTrQc6JijsNKQOzIKWnLIDQQwkH8uutLG2QqYEv(lu1Gj1HfTyK6XuAYs1LbBgk9zc1OLKttLxJeZwIBtYUr8BidNQ0XrsYYj65cMUkxxO2Uq8DQcDEKuRxifz(QsA)u88NWX)ubJzNsaJ(Dbua5YIrtLMk6IJioA2OdoI4cy0zWooAeWMXLBphlckqgG9RHZhtCy6xN2A4IECrxDgZEbRllUOP8CiY(1QtTXyyphIeMW99NWXVjjDb675y2kDEVXhsS4c0ArOsh5rsWOf0OFXO7ORfBjva(qfYsPvcQ0rcg9dgnDmwSTzWcKEsSqBpwMNdrmAbn6xm6ZPaJ(H6n66GZOF9vJMogl2w6cc1lXHRn2Rr)OrlOrBrOsh5rsBjJK4PJLHRvcQ0rcg9dgnoJwqJ2dmA6ySyBdhsQOaGxq2g71OFCmg0UI7OECgSaPNelm2ts3zZdjhtqeyCdQhvk)Pcgp(Nkymgblq6jXcJfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D7xBch)MK0fOVNJzR059g7bg95SuCeXg9RVA0D01ITKkaFOczP0kbv6ibJUU1B0IT9Xyq7kUJ6XylPcWhQqwkJ9K0D28qYXeebg3G6rLYFQGXJ)Pcg7HLubgnxHSuglckqgG9RHZhtFCJfbbuS0cHjC3ybQalLgueqbKB0JBq9FQGX72NQNWXVjjDb675y2kDEVXQekHtIuT2yPeiNr)q9gDnCgTGgTeuPJem66wVrthJfBBgSaPNel02JL55qeJwqJ2IqLoYJK2mybspjwOvcQ0rcgnvIrthJfBBgSaPNel02JL55qeJUU1B09yzEoezmg0UI7OEm2sQa8HkKLYypjDNnpKCmbrGXnOEuP8Nky84FQGXEyjvGrZvilfJ(f)hhlckqgG9RHZhtFCJfbbuS0cHjC3ybQalLgueqbKB0JBq9FQGX72p6NWXVjjDb675ymODf3r9yOakGCzbpDjd3ypjDNnpKCmbrGXnOEuP8Nky84FQGXVlGcixwm6NLmCJfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D7hDt443KKUa99CmBLoV3y6ySyBbBfcc4ryXFvaEXsip8HyshKoI42yVgTGgThy00XyX2Mblq6jXcTXEnAbnAvcLWjrQwBSucKZOFOEJoARZymODf3r9yiLxfvfNuGXEs6oBEi5ycIaJBq9Os5pvW4X)ubJFNYRIQItkWyrqbYaSFnC(y6JBSiiGILwimH7glqfyP0GIakGCJECdQ)tfmE3(1zch)MK0fOVNJzR059gRsOeojs1AJLsGCg9d1B0((yA0V(Qr7bgDkph20ETbpcLIJigVkHs4Kivlqs6c0nAbnAvcLWjrQwBSucKZOFOEJMkxBmg0UI7OEmKYRcFOczPm2ts3zZdjhtqeyCdQhvk)Pcgp(Nky87uEvgnxHSuglckqgG9RHZhtFCJfbbuS0cHjC3ybQalLgueqbKB0JBq9FQGX72hZjC8BssxG(EoMTsN3B8ymODf3r94WHKkka4fKJ9K0D28qYXeebg3G6rLYFQGXJ)PcgZhsQOaGxqoweuGma7xdNpM(4glccOyPfct4UXcubwknOiGci3Oh3G6)ubJ3TF0oHJFts6c03ZXSv68EJhJbTR4oQhxCuvSRJxLIvj(dDGASNKUZMhsoMGiW4gupQu(tfmE8pvWyQWrvXUUr3KIvPrleDGASiOaza2VgoFm9XnweeqXsleMWDJfOcSuAqrafqUrpUb1)PcgVBFQ8eo(njPlqFphZwPZ7nMogl2wVipcs8iS4VkaVkHs4KivBSxJwqJMogl22WHKkka4fKTXEnAbn60EUiaEGakhem66A0u9ymODf3r94ItC1rCeX4PrLBSNKUZMhsoMGiW4gupQu(tfmE8pvWyQWjU6ioIyJ(jQCJfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D77JBch)MK0fOVNJzR059g3rxl2sQa8HkKLsReuPJem6hmABgo8NtbgTGg9lgTfHkDKhj4LqApJ(1xnA6ySyBZGfi9KyH2yVg9JJXG2vCh1JlzKepDSmCJ9K0D28qYXeebg3G6rLYFQGXJ)PcgtfzK0OFgld3yrqbYaSFnC(y6JBSiiGILwimH7glqfyP0GIakGCJECdQ)tfmE3(((t443KKUa99CmBLoV34xmAvcLWjrQwBSucKZOFOEJUgoJwqJMogl2wOakGCzbpwKno0g71OF0Of0OFXOLawjeQs6cy0pogdAxXDupgBjva(qfYszSNKUZMhsoMGiW4gupQu(tfmE8pvWypSKkWO5kKLIr)sThhJHuCy8LsXWH3HTEjGvcHQKUaJfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D77xBch)MK0fOVNJzR059gRsOeojs1AJLsGCg9d1B0(((g9RVA0EGrNYZHnTxBWJqP4iIXRsOeojs1cKKUaDJwqJwLqjCsKQ1glLa5m6hQ3OJ26y0V(QrduvSZRxO3guOshKoIy8vqkpJwqJgOQyNxVqV9Qa8DWcUiGmGNUGqD8Et7z0cA0QekHtIuT2yPeiNr)GrJjoJwqJ(YcqU2e7bYqfYsPfijDb6JXG2vCh1JHuEv4dvilLXEs6oBEi5ycIaJBq9Os5pvW4X)ubJFNYRYO5kKLIr)I)JJfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D77t1t443KKUa99CmBLoV3y6ySyBLqarsIfWFOduTsqLosWORRr7JZOF9vJ(fJMogl2wjeqKKyb8h6avReuPJem66A0Vy00XyX2Mblq6jXcT9yzEoeXOPsmAlcv6ipsAZGfi9KyHwjOshjy0pA0cA0weQ0rEK0Mblq6jXcTsqLosWORRr7hDg9JJXG2vCh1Jp0bk8QmCGK6XEs6oBEi5ycIaJBq9Os5pvW4X)ubJfIoqz0nz4aj1JfbfidW(1W5JPpUXIGakwAHWeUBSavGLsdkcOaYn6XnO(pvW4D77h9t443KKUa99CmBLoV340EUiaEGakhem6hmAFJwqJoTNlcGhiGYbbJ(bJ2Fmg0UI7OECjJK4PHun2ts3zZdjhtqeyCdQhvk)Pcgp(NkymvKrsJ(jKQXIGcKby)A48X0h3yrqaflTqyc3nwGkWsPbfbua5g94gu)Nky8U99JUjC8BssxG(EoMTsN3BmDmwSTErEeK4ryXFvaEvcLWjrQ2yVgTGgDApxeapqaLdcgDDnAQEmg0UI7OECXjU6ioIy80OYn2ts3zZdjhtqeyCdQhvk)Pcgp(Nkymv4exDehrSr)evoJ(f)hhlckqgG9RHZhtFCJfbbuS0cHjC3ybQalLgueqbKB0JBq9FQGX723Vot443KKUa99CmBLoV340EUiaEGakhem6hmAFJwqJoTNlcGhiGYbbJ(bJ2Fmg0UI7OESTkDe8fN4QJ4iIh7jP7S5HKJjicmUb1JkL)ubJh)tfmwGQ0rmAQWjU6ioI4XIGcKby)A48X0h3yrqaflTqyc3nwGkWsPbfbua5g94gu)Nky8U99XCch)MK0fOVNJXG2vCh1JloXvhXreJNgvUXEs6oBEi5ycIaJBq9Os5pvW4X)ubJPcN4QJ4iIn6NOYz0Vu7XXIGcKby)A48X0h3yrqaflTqyc3nwGkWsPbfbua5g94gu)Nky8U99J2jC8BssxG(EoMTsN3BSeWkHqvsxGXyq7kUJ6XylPcWhQqwkJfOcSuAqrafqU9CCdQhvk)Pcgp2ts3zZdjhtqey8pvWypSKkWO5kKLIr)cv)4ymKIdJvOioI469JgUukgo8oS1lbSsiuL0fySiOaza2VgoFm9XnweeqXsleMWDJBqrCeX77pUb1)PcgVBFFQ8eo(njPlqFphJbTR4oQhdP8QWhQqwkJfOcSuAqrafqU9CCdQhvk)Pcgp2ts3zZdjhtqey8pvW43P8QmAUczPy0Vu7XXyifhgRqrCeX17pweuGma7xdNpM(4glccOyPfct4UXnOioI499h3G6)ubJ3TFnCt443KKUa99Cmg0UI7OEm2sQa8HkKLYybQalLgueqbKBph3G6rLYFQGXJ9K0D28qYXeebg)tfm2dlPcmAUczPy0Ve9pogdP4WyfkIJiUE)XIGcKby)A48X0h3yrqaflTqyc3nUbfXreVV)4gu)Nky8UDJzR059gVBd]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170716.234424, [[di07maqiIuXIqr1MuOQrrKYPqrzxqvddKogiwgj5zscmnIu11uOY2uO4BqfJdfjohkIyDqrnpjbDpfkTpjHoij1crj9qjPjIIGUir1grrsJefr6KejZefPUPc2jO(jkIAOOiKLIcpfzQeXvjsL2krPVIIqTxXFLugmLoSslMepMQMSIUSQntu8zuQrdfonHxJsmBuDBsTBGFdz4kKLlXZPy6sDDO02Hk9DOiNxs16rrG5ljA)u5ajscXeEzwS8oSgcE1pej0vDw58RpOxoMD25LzXY7qmo)R5bwfui4afhiJbVkOsp0XnMqKVig1HcP23ceWejbgsKesoyv4FgLqKVig1HAeB28J3Jq8jctaJZoENvAoBVf2VXJXxEJb(r(2zRqNv14C2kR0zBH(oBfDwO4hhuOolZcPwrWfD9qkCeAYXA6qsbMc)2Osiac8qdOPSBbE1pui4v)qmPVGegDigN)18aRckeCGaneJBqyl(BIK0HQIX9SmGW96d6OeAanHx9dLoWQIKqYbRc)ZWAiYxeJ6qnInB(Xpc1ceW4SJ3zLMZ6ri(eHjaEzeLx78RpOxo(Y1RayC2k6SQykqD2kR0z7TW(n(wOFTgvBkUZwHJ1zhduNLzHuRi4IUEOrOwGaHKcmf(TrLqae4Hgqtz3c8QFOqWR(HyIqTabcX48VMhyvqHGdeOHyCdcBXFtKKouvmUNLbeUxFqhLqdOj8QFO0bUcIKqYbRc)ZWAiYxeJ6qnInB(Xla9lfSJAti1kcUORhctcWSMbJVLqsbMc)2Osiac8qdOPSBbE1pui4v)qmXcW0zjm(wcX48VMhyvqHGdeOHyCdcBXFtKKouvmUNLbeUxFqhLqdOj8QFO0bw6JKqYbRc)ZWAiYxeJ6qkyLrg8LBqGf4FTg1xJVC9kagNTcDwvHuRi4IUEOg1xxtVM(L6HKcmf(TrLqae4Hgqtz3c8QFOqWR(HKG6RD2H10VupeJZ)AEGvbfcoqGgIXniSf)nrs6qvX4Ewgq4E9bDucnGMWR(Hsh4XfjHKdwf(NH1qKVig1HAeB28J3Jq8jctati1kcUORhsgr51o)6d6LhskWu43gvcbqGhAanLDlWR(HcbV6hIPkk3zLZV(GE5HyC(xZdSkOqWbc0qmUbHT4VjsshQkg3ZYac3RpOJsOb0eE1pu6apMijKCWQW)mSgI8fXOouJyZMF8EeIprycycPwrWfD9qMgv01o)6d6LhskWu43gvcbqGhAanLDlWR(HcbV6hIAur7SY5xFqV8qmo)R5bwfui4abAig3GWw83ejPdvfJ7zzaH71h0rj0aAcV6hkDGXjscjhSk8pdRHiFrmQd1i2S5hVhH4teMaMqQveCrxp05xFqV8A610VupKuGPWVnQecGap0aAk7wGx9dfcE1pKC(1h0l3zhwt)s9qmo)R5bwfui4abAig3GWw83ejPdvfJ7zzaH71h0rj0aAcV6hkDGzkrsi5GvH)zynKAfbx01dH18AI(AtiPatHFBujeabEOb0u2TaV6hke8QFiPR5oRu91Mqmo)R5bwfui4abAig3GWw83ejPdvfJ7zzaH71h0rj0aAcV6hkDGzsIKqYbRc)ZWAiYxeJ6qnInB(X7ri(eHjGXzhVZknNv64S9YpOXVg)bZf4p(dwf(NoBLv6SkyLrg8RXFWCb(Jh7iNTYkDwpcXNimbWVg)bZf4p(Y1RayC2k6SJdQZYSqQveCrxpKchHM1KbBPEiPatHFBujeabEOb0u2TaV6hke8QFiw5i00zzQyl1dX48VMhyvqHGdeOHyCdcBXFtKKouvmUNLbeUxFqhLqdOj8QFO0bgc0ijKCWQW)mSgI8fXOouJyZMF8EeIprycyC2X7SsZzLooBV8dA8RXFWCb(J)GvH)PZwzLoRcwzKb)A8hmxG)4XoYzzwi1kcUORhs5fZlSiaSdjfyk8BJkHaiWdnGMYUf4v)qHGx9dX6lMxyrayhIX5FnpWQGcbhiqdX4ge2I)MijDOQyCpldiCV(GokHgqt4v)qPdmeirsi5GvH)zyne5lIrDO13cCFTdUwCJZwrNvLZoENvAo76BbUV2bxlUXzROZQYzRSsND9Ta3x7GRf34Sv0zv5SmlKAfbx01dvWcQT(wGa14cthskWu43gvcbqGhAanLDlWR(HcbV6hIbwGZQ23ceWzzAHPdPUW2ecS6pwMtcDvNvo)6d6LJzNvntwoZdX48VMhyvqHGdeOHyCdcBXFtKKouvmUNLbeUxFqhLqdOj8QFisOR6SY5xFqVCm7SQzYYthyiQIKqYbRc)ZWAiYxeJ6q9YpOXVg)bZf4p(dwf(NHuRi4IUEOcwqT13ceOgxy6qsbMc)2Osiac8qdOPSBbE1pui4v)qmWcCw1(wGaoltlmTZknimlK6cBtiWQ)yzoj0vDw58RpOxoMDwJaWMFNDnEMhIX5FnpWQGcbhiqdX4ge2I)MijDOQyCpldiCV(GokHgqt4v)qKqx1zLZV(GE5y2zncaB(D214thyivqKesoyv4Fgwdr(IyuhQx(bnEH)YGTuh)bRc)ZqQveCrxpublO26BbcuJlmDiPatHFBujeabEOb0u2TaV6hke8QFigyboRAFlqaNLPfM2zLMkMfsDHTjey1FSmNe6QoRC(1h0lhZoRrayZVZkKH5HyC(xZdSkOqWbc0qmUbHT4VjsshQkg3ZYac3RpOJsOb0eE1pej0vDw58RpOxoMDwJaWMFNvit6adr6JKqYbRc)ZWAiYxeJ6q9YpOXZfSXObca7Af0e)bRc)ZqQveCrxpublO26BbcuJlmDiPatHFBujeabEOb0u2TaV6hke8QFigyboRAFlqaNLPfM2zLwfWSqQlSnHaR(JL5Kqx1zLZV(GE5y2zncaB(DwEH5HyC(xZdSkOqWbc0qmUbHT4VjsshQkg3ZYac3RpOJsOb0eE1pej0vDw58RpOxoMDwJaWMFNLxsNoen6EXYfmbBlqGaRAmQsNa]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170716.234424, [[datucaGErK2LukBdsmBP6MKY3iHDsL9I2nH9djnms63sgkuPgmKYWfvhuKCms1cfPwkewmfwov9qPKNcESs9CLmrrqtLIMmuMUWfffxw11fL2kKQnlLQTdvSmPyAIionLoSIxtIgne1Tj6KqKplI6AqLCEOQ)kc8mriRteQPonjKW3(KThmnbi)B70TjDcBjORbLgciE)Z601OQRqvHokT1OMevCHcby7T5bbcP2HTelAsNonjKrmg9JX0eGT3MheIk5K7VT8kSLyriLHTBd8eYRWwccijWS7jkpbrjobTcd9X7g5jqWnYta3vylbbeV)zD6Au1vORsaXxvw)(lAYGqlK)wPwHZLxe0GGwH5g5jWGUgAsiJym6hJPjKYW2TbEcrfxMa5SI7XtajbMDpr5jikXjOvyOpE3ipbcUrEcMvCjQOPnR4E8eq8(N1PRrvxHUkbeFvz97VOjdcTq(BLAfoxErqdcAfMBKNad6senjKrmg9JX0eszy72apHvuEPY)87jGKaZUNO8eeL4e0km0hVBKNab3ipbikVu5F(9eq8(N1PRrvxHUkbeFvz97VOjdcTq(BLAfoxErqdcAfMBKNadgeCJ8eaRSfQOLPF5fX0tmQOL7)UKgtWGea]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170716.234424, [[deKisaqivrvBIsvJIsYPOKAvuIIEfLOuZIsLs3IsLIDPQmmK4yKQLPGEMQOmnvrLRrjQ2gscFdkzCqrX5GIsRJsuyEij6EQISpKKoiuyHQcpKOyIuQuDrOuBKsLCsIsZKsf3uq7eQwkr1trnvKYwPe2R0FvOblQdR0IjYJPQjROld2SQQplWOjLtt41ivZMk3MIDJ43qgUcCCOOA5K8CHMUkxxvA7ukFhkY5rsTEkrjZNsK9lYvV0kJVgOmlmYKYy7adqU1zzKYrbjWbPStvM9kXGRCzEa4fRtyzTNark(qQyyz5Gd2iu8Hu0XIcw6uX3qkphflNkklh2j10egO8eDF)U1aJrnKN(NcmRGeTBSAcsV))F)U1aJrnKN(38vTNarSmP89mRlJH)eisS0kUEPvgBYk5GzFuM9kXGR8ZNYNWtxqcszlzPuEIUVF3AGXOgYt)tbMvqIPmv(ukh4NLXqs4eh1L)DRbgJAip9YYsMc)EivzcIaLdrtlwf(AGYLXxdu2UCRbszwd5Pxwo4GncfFifDS0PuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXhwALXMSsoy2hLXqs4eh1LbhyaYTUrj3gVYYsMc)EivzcIaLdrtlwf(AGYLXxdugBhyaYTUu(HBJxz5Gd2iu8Hu0XsNsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef)zLwzSjRKdM9rz2RedUYsV))FGxdbXr0)4PbJbkyVX4lzckbj47DqzmKeoXrDzyvNgM)U0HYYsMc)EivzcIaLdrtlwf(AGYLXxdug7vDAy(7shklhCWgHIpKIow6uklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4pxPvgBYk5GzFuM9kXGRSzbx8uiZN)vPaYLYu9PuwxhRu2swkLF(uEvN4F93xetGZjibJMfCXtHmFazLCWmLTpLnl4INcz(8VkfqUuMQpLYy2HLXqs4eh1LHvDAJrnKNEzzjtHFpKQmbrGYHOPfRcFnq5Y4RbkJ9QoTuM1qE6LLdoyJqXhsrhlDkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vClV0kJnzLCWSpkZELyWvUmgscN4OUC8qkdDagaQYYsMc)EivzcIaLdrtlwf(AGYLXxduMpKYqhGbGQSCWbBek(qk6yPtPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVItfLwzSjRKdM9rz2RedUYLXqs4eh1LDcm)vmhnBGzhp0bMYYsMc)EivzcIaLdrtlwf(AGYLXxdu2ocm)vmt5WnWSPmn0bMYYbhSrO4dPOJLoLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kowLwzSjRKdM9rz2RedUYt0997wdmg1qE6FkWScsmLPAk734nEcdKY2NYEeYnryImQG1FLXqs4eh1LDRTDu6vfVYYsMc)EivzcIaLdrtlwf(AGYLXxdu2oRTnLF8QIxz5Gd2iu8Hu0XsNsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5EfhZuALXMSsoy2hLzVsm4kBvkBwWfpfY85FvkGCPmvFkLhsjLTpLLE)))ahyaYTUXFK)n(9oiLToLTpLTkLvWVcIARKdszRlJHKWjoQl)7wdmg1qE6LLLmf(9qQYeebkhIMwSk81aLlJVgOSD5wdKYSgYtpLTs36YyOcILVvfa3O4)jf8RGO2k5GYYbhSrO4dPOJLoLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9koMT0kJnzLCWSpkZELyWv2SGlEkK5Z)Qua5szQ(ukRRRNYwYsP8ZNYR6e)R)(IycCobjy0SGlEkK5diRKdMPS9PSzbx8uiZN)vPaYLYu9PugZqfPSLSukdy(RyWay(fni3eucsWOgSQlLTpLbm)vmyam)onyCcEqyduXrjhcnhhS(lLTpLnl4INcz(8VkfqUuMQPmwusz7t5BDa5(2)durnKN(hqwjhmlJHKWjoQldR60gJAip9YYsMc)EivzcIaLdrtlwf(AGYLXxdug7vDAPmRH80tzR0TUSCWbBek(qk6yPtPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIRtP0kJnzLCWSpkZELyWvw69))tbrezjEy8qhy(uGzfKyktLPSoLu2swkLTkLLE)))uqerwIhgp0bMpfywbjMYuzkBvkl9())TrpqMlXdFZx1EcejLTStzpc5Mimr(2OhiZL4HpfywbjMYwNY2NYEeYnryI8TrpqMlXdFkWScsmLPYuw3YtzRlJHKWjoQlFOdmJMnEGI6YYsMc)EivzcIaLdrtlwf(AGYLXxduMg6atkhUXduuxwo4GncfFifDS0PuwoerVkpelTELLrd80dr2adqUkvoenXxduUxX11lTYytwjhm7JYSxjgCLTkLLE)))gGWeOgr)JNgmAwWfpfY89oiLTpLx)jSbJabmciMYuzk)Su26u2(u2QuEcsV))ForG2reKGrfA(nryIKYwxgdjHtCux2jc0oIGemkHCxzzjtHFpKQmbrGYHOPfRcFnq5Y4RbkBhrG2reKGu(bYDLXqfelFRkaUrX)ttq69))Zjc0oIGemQqZVjctKYYbhSrO4dPOJLoLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kU(WsRm2KvYbZ(Om7vIbxzP3))VbimbQr0)4PbJMfCXtHmFVdsz7t51FcBWiqaJaIPmvMYpRmgscN4OUSteODebjyuc5UYYsMc)EivzcIaLdrtlwf(AGYLXxdu2oIaTJiibP8dK7szR0TUSCWbBek(qk6yPtPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIR)SsRm2KvYbZ(Om7vIbxzRs51FcBWiqaJaIPmvtz9u2(uE9NWgmceWiGykt1uwpLToLTpLTkLNG07))NteODebjyuHMFteMiPS1LXqs4eh1L9ARGm6ebAhrqckllzk87HuLjicuoenTyv4RbkxgFnqzz0wbjLTJiq7icsqzmubXY3QcGBu8)0eKE)))CIaTJiibJk08BIWePSCWbBek(qk6yPtPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIR)CLwzSjRKdM9rz2RedUYR)e2GrGagbetzQMY6PS9P86pHnyeiGraXuMQPSEzmKeoXrDzV2kiJorG2reKGYYsMc)EivzcIaLdrtlwf(AGYLXxduwgTvqsz7ic0oIGeKYwPBDz5Gd2iu8Hu0XsNsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Efx3YlTYytwjhm7JYSxjgCLNG07))NteODebjyuHMFteMiLXqs4eh1LDIaTJiibJsi3vwwYu43dPktqeOCiAAXQWxduUm(AGY2reODebjiLFGCxkB1qRlJHkiw(wvaCJI)NMG07))NteODebjyuHMFteMiLLdoyJqXhsrhlDkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vCDQO0kJnzLCWSpkJHKWjoQl7ebAhrqcgLqURSSKPWVhsvMGiq5q00IvHVgOCz81aLTJiq7icsqk)a5Uu2QNzDz5Gd2iu8Hu0XsNsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5EfxhRsRm2KvYbZ(Om7vIbxzf8RGO2k5GYyijCIJ6Y)U1aJrnKNEzz0ap9qKnWaKRpkhIMwSk81aLlllzk87HuLjicugFnqz7YTgiLznKNEkB1qRlJHkiw2GSjibpPB3ERkaUrX)tk4xbrTvYbLLdoyJqXhsrhlDkLLdr0RYdXsRx5qKnbjO46Ldrt81aL7vCDmtPvgBYk5GzFugdjHtCuxgw1Png1qE6LLrd80dr2adqU(OCiAAXQWxduUSSKPWVhsvMGiqz81aLXEvNwkZAip9u2QHwxgdvqSSbztqcEsVSCWbBek(qk6yPtPSCiIEvEiwA9khISjibfxVCiAIVgOCVIRJzlTYytwjhm7JYyijCIJ6Y)U1aJrnKNEzz0ap9qKnWaKRpkhIMwSk81aLlllzk87HuLjicugFnqz7YTgiLznKNEkB1ZSUmgQGyzdYMGe8KEz5Gd2iu8Hu0XsNsz5qe9Q8qS06voeztqckUE5q0eFnq5E9kB3H)91D9rVwa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170716.234424, [[de0ruaqiuuSjLGrPk4ukrTkuK4vKKQAwKKsDlssv2Ls1WqHJrILjGNHIstJKuCnLiABQc5BQsgNseohksADKKknpvH6EkH2hkQoOQuluP4HOuMijPKlQkAJOiCsuQMjksDtbTtv1sjkpfzQOKTssSxP)cHblYHvSyI8yQmziDzWMvsFMOA0uQttXRHOzl0Tj1Uj8BOgoj1XvI0Yr1ZPQPRY1PKTlqFhfrNxP06jjvmFss2VOUkLvP)OHsKrZwo9mcAqCtu1nN8gH8iKtM1sKJBuFLkrQbNzIgvN5myr)bEuGsYGimEO)amuEX4LYJ2dWq1WyjFujzWGULLrdLqX3(AC0acVn2HCNd6Xi8QEpGcswRR7RXrdi82yhYDul(CgSGPWyNzxU0B3zWcFz1Vszv6PyKIaA3uICCJ6ReZKtNXH0iKNtQsv5ek(2xJJgq4TXoK7CqpgHpNE8I5KChAP3sMO52wAnoAaH3g7qwIDbQXnhMxsGfqPqmQkd)pAOuP)OHsmrC0qor2yhYsYGimEO)amuEPWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9pAOuV(duwLEkgPiG2nLih3O(kjzTUUdoBm4rGxrC2ac5CyoeElbkWnc57wQZPfYj9ar)XX6DNfNdIlNy(I50s8OsVLmrZTTem8ZEPwdsOe7cuJBomVKalGsHyuvg(F0qPs)rdLEo8ZEPwdsOKmicJh6padLxkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIr)Jgk1RFMTSk9umsraTBkroUr9vsYADD34Gvl(2Dl150c5KEGO)4y9UZIZbXLtmFXCsrrjNwiNyMCsYADDF8oqGochSBPU0Bjt0CBlTYX(dH3g7qwIDbQXnhMxsGfqPqmQkd)pAOuP)OHsmbh7VCISXoKLKbry8q)byO8sHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6F0qPE9RAkRspfJueq7MsVLmrZTTeebniUjIqko(Re7cuJBomVKalGsHyuvg(F0qPs)rdLEgbniUjMtBIJ)kjdIW4H(dWq5LcJsYap2I7aFz1ReB2GdzioiObXvPsHy0)OHs96FjlRspfJueq7MsKJBuFL0de9hhR3DwCoiUCI5lMtkkVYjvPQCIzYPHFM1XD7EMeIrJqoc9ar)XX6DqmsranNwiN0de9hhR3DwCoiUCI5lMtm1aLElzIMBBjy4NncVn2HSe7cuJBomVKalGsHyuvg(F0qPs)rdLEo8ZoNiBSdzjzqegp0FagkVuyusg4XwCh4lRELyZgCidXbbniUkvkeJ(hnuQx)pQSk9umsraTBkroUr9vQ0Bjt0CBl5pmxJea1aVe7cuJBomVKalGsHyuvg(F0qPs)rdLOdZ1ibqnWljdIW4H(dWq5LcJsYap2I7aFz1ReB2GdzioiObXvPsHy0)OHs96)vzv6PyKIaA3uICCJ6R0d5KEGO)4y9UZIZbXLtpEXCsHHsoTqon8ZSoUB3ZKqmAeYrOhi6powVdIrkcO5KQuvoXm50WpZ64UDptcXOrihHEGO)4y9oigPiGMtlKt6bI(JJ17olohexo94fZPxpkNwoNwiNyMCsYADDF8oqGochSBPU0Bjt0CBlzCWQfFBj2fOg3CyEjbwaLcXOQm8)OHsL(JgkXUdwT4BljdIW4H(dWq5LcJsYap2I7aFz1ReB2GdzioiObXvPsHy0)OHs96FjkRspfJueq7MsKJBuFLk9wYen32srZsTmOi0JC9G4WhOlXUa14MdZljWcOuigvLH)hnuQ0F0qjM2SuldAofoY1toXcFGUKmicJh6padLxkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIr)Jgk1RFMAzv6PyKIaA3uICCJ6RKK166UAmtcCe4veNnGqpq0FCSE3sDoTqojzTUU7pmxJea1aF3sDoTqonUZeeqacqBaFo94CIzl9wYen32srJC7tyeYriHJxj2fOg3CyEjbwaLcXOQm8)OHsL(JgkX0g52NWiKNtBWXRKmicJh6padLxkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIr)Jgk1RFfgLvPNIrkcODtjYXnQVsO4BFnoAaH3g7qUZb9ye(CI55KB8hIZOHCAHCYHXrumtkqWHXDLElzIMBBP4eCqizX9xj2fOg3CyEjbwaLcXOQm8)OHsL(JgkX0tWjN2yX9xjzqegp0FagkVuyusg4XwCh4lRELyZgCidXbbniUkvkeJ(hnuQx)kkLvPNIrkcODtjYXnQVsswRR7ghSAX3UBPoNwiNEiN0de9hhR3DwCoiUCI5lMtbyKtQsv5KK166UXbRw8T7CqpgHpNECo9qoPSVK5etjN8QHyeH94piNyk5KK166UXbRw8T7(BCiZjv)CsjNwoNwU0Bjt0CBlTYX(dH3g7qwIDbQXnhMxsGfqPqmQkd)pAOuP)OHsmbh7VCISXoK50dklxsgeHXd9hGHYlfgLKbESf3b(YQxj2SbhYqCqqdIRsLcXO)rdL61VsGYQ0tXifb0UPe54g1xPhYj9ar)XX6DNfNdIlNy(I5uag50c5KK166oebniUjIyf7S87wQZPLZPfYPhYjoSYbV9ifHCA5sVLmrZTT0AC0acVn2HSe7cuJBomVKalGsHyuvg(F0qPs)rdLyI4OHCISXoK50dklx6nxUV0nC5WHWSUihw5G3EKIqjzqegp0FagkVuyusg4XwCh4lRELyZgCidXbbniUkvkeJ(hnuQx)kmBzv6PyKIaA3uICCJ6RKK166UXbRw8T7wQl9wYen32sRCS)q4TXoKLyZgCidXbbniUUPuigvLH)hnuQe7cuJBomVKalGs)rdLyco2F5ezJDiZPhcSCP3C5(sACqJq(IkLKbry8q)byO8sHrjzGhBXDGVS6vkeh0iK3VsPqm6F0qPE9ROAkRspfJueq7MsKJBuFL0de9hhR3DwCoiUCI5lMtkkk5KQuvoXm50WpZ64UDptcXOrihHEGO)4y9oigPiGMtlKt6bI(JJ17olohexoX8fZPL4r5KQuvobl1YOwnGU714ikWnc5iSHHF50c5eSulJA1a6(zdiqbhyccCpcPigJIq94UCAHCspq0FCSE3zX5G4YjMNtVyKtlKt3ebXTpRhW92yhYDqmsraT0Bjt0CBlbd)Sr4TXoKLyxGACZH5LeybukeJQYW)Jgkv6pAO0ZHF25ezJDiZPhuwUKmicJh6padLxkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIr)Jgk1RFLLSSk9umsraTBkroUr9vsYADDNdESyeoaXHpqVZb9ye(C6X5KcJsVLmrZTT0HpqJqp(d4BlXUa14MdZljWcOuigvLH)hnuQ0F0qjw4d05u44pGVTKmicJh6padLxkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIr)Jgk1RFLhvwLEkgPiG2nLih3O(kjzTUUdoBm4rGxrC2ac5CyoeElbkWnc57wQl9wYen32sWWp7LAniHsSlqnU5W8scSakfIrvz4)rdLk9hnu65Wp7LAniHC6bLLljdIW4H(dWq5LcJsYap2I7aFz1ReB2GdzioiObXvPsHy0)OHs96x5vzv6PyKIaA3uICCJ6RKK166UAmtcCe4veNnGqpq0FCSE3sDoTqonUZeeqacqBaFo94CIzl9wYen32srJC7tyeYriHJxj2fOg3CyEjbwaLcXOQm8)OHsL(JgkX0g52NWiKNtBWXlNEqz5sYGimEO)amuEPWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9pAOuV(vwIYQ0tXifb0UPe54g1xPXDMGacqaAd4ZjMNtk50c504otqabiaTb85eZZjLsVLmrZTTKZEmcerJC7tyeYlXUa14MdZljWcOuigvLH)hnuQ0F0qj2ShJiNyAJC7tyeYljdIW4H(dWq5LcJsYap2I7aFz1ReB2GdzioiObXvPsHy0)OHs96xHPwwLEkgPiG2nLElzIMBBPOrU9jmc5iKWXRe7cuJBomVKalGsHyuvg(F0qPs)rdLyAJC7tyeYZPn44Ltpey5sYGimEO)amuEPWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9pAOuV(dWOSk9umsraTBkroUr9vIdRCWBpsrO0Bjt0CBlTghnGWBJDilXMn4qgIdcAqCDtPqmQkd)pAOuj2fOg3CyEjbwaL(JgkXeXrd5ezJDiZPhcSCP3C5(sACqJq(IkQ23WLdhcZ6ICyLdE7rkcLKbry8q)byO8sHrjzGhBXDGVS6vkeh0iK3VsPqm6F0qPE9hqPSk9umsraTBk9wYen32sWWpBeEBSdzj2SbhYqCqqdIRBkfIrvz4)rdLkXUa14MdZljWcO0F0qPNd)SZjYg7qMtpey5sV5Y9L04GgH8fvkjdIW4H(dWq5LcJsYap2I7aFz1RuioOriVFLsHy0)OHs96pqGYQ0tXifb0UP0Bjt0CBlTghnGWBJDilXMn4qgIdcAqCDtPqmQkd)pAOuj2fOg3CyEjbwaL(JgkXeXrd5ezJDiZPhy2Ll9Ml3xsJdAeYxuPKmicJh6padLxkmkjd8ylUd8LvVsH4GgH8(vkfIr)Jgk1RxjvlyDSIx30Rfa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170716.234424, [[deeokaqijv0MuQQrrKYPicwLsvQzrHsUffQYUiQgMs5ysyzskptsfMgrQUgkk2MKQ8nfQXrHIohfk16OqfZtPkUhkQ2NsvYbLOwOe5HkvMifQ0fviBusLCsIOzse6Mu0ov0pPqvTuu4PitfI2krYEf)fsgmQ6WuTyu6XkzYs1LvTzk4Zky0sYPj8AIYSP0Tjz3G(nudNc54sQQLtQNlLPdCDiSDi13rrPZJISEkuy(sQu7hvofbzOPREisO2XXpYE1Ha3AC44lB8hfIwAHrGqHmU3GJWcsPqmU9E7zwBRy824I6jV2M03yM6fIX9otifQhQJbYnyD1r1QWlzY1x5cyZ4jT(zryWGCdwxDuTk8sM8ocTdey4EVjVoKqOYlGadBbzMfbzOrqN1(EkfQmRWkamfQbWALSFJUoKKWUy5aSoeedFitCxkxpD1dfA6QhIayTs2VrxhIXT3BpZABfJl2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmRfKHgbDw77PuiAPfgbcbWdd2lFHX2oMzHTqLzfwbGPqEBDy3HRhssyxSCawhcIHpKjUlLRNU6HcnD1dvUToS7W1dX427TNzTTIXfBHy8ggHE9wqgqODvFjZeJ(QdbHnKjUpD1dfqM1rqgAe0zTVNsHkZkScatHSI6Jq0rP8bLJcGbxfssyxSCawhcIHpKjUlLRNU6HcnD1djrr9ri6C8M(GY54rIbxfIXT3BpZABfJl2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmLEqgAe0zTVNsHOLwyeiK0449fqG(Oo8kXBC87HJx6C87ZXR8BBanwjFHqRpeWXVxmNJV2ghVe443NJxAC86Bq)wLZAphVecvMvyfaMczW6QJQvHxYcjjSlwoaRdbXWhYe3LY1tx9qHMU6HQlRRohpvHxYcvwp0cbC9WbOegyU(g0Vv5S2hIXT3BpZABfJl2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmzMGm0iOZAFpLcvMvyfaMcDxdQQpcx2djjSlwoaRdbXWhYe3LY1tx9qHMU6Hg5Aqv9r4YEig3EV9mRTvmUyleJ3Wi0R3cYacTR6lzMy0xDiiSHmX9PREOaYSEbzOrqN1(EkfIwAHrGqDmqUbRRoQwfEjtU(kxaBC87fh)YBauaH6C87ZXZIWGb5whTJQHqpC5imIJFFo(6KJh42dbYTIHkauahqPXD5h6S23543NJ3xab6J6WReVXXVhoEPhQmRWkamfY6ODuSi0nqijHDXYbyDiig(qM4UuUE6Qhk00vpKeD0ohFje6gieJBV3EM12kgxSfIXBye61BbzaH2v9Lmtm6Roee2qM4(0vpuazooidnc6S23tPq0slmceQo54bU9qGCRyOcafWbuACx(HoR9Do(9549fqG(Oo8kXBC87HJNz44R76MJh42dbYTIHkauahqPXD5h6S23543NJ3xab6J6WReVXXVhoEPhQmRWkamf62Roe4wuSwVbcjjSlwoaRdbXWhYe3LY1tx9qHMU6HgzV6qGB54lz9gieJBV3EM12kgxSfIXBye61BbzaH2v9Lmtm6Roee2qM4(0vpuazAmdYqJGoR99ukuzwHvaykK1r7OyVRcjjSlwoaRdbXWhYe3LY1tx9qHMU6HKOJ254lDxfIXT3BpZABfJl2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmn2bzOrqN1(EkfIwAHrGq9ZIWGb5wXqfakGdO04U8oMzHHkZkScatHwvUaIYkgQaqbCiKKWUy5aSoeedFitCxkxpD1dfA6QhAxLlGC8sumubGc4qOY6HwiGRhoaLWaZ7NfHbdYTIHkauahqPXD5DmZcdX427TNzTTIXfBHy8ggHE9wqgqODvFjZeJ(QdbHnKjUpD1dfqMfBbzOrqN1(EkfQmRWkamfAv5cikRyOcafWHqsc7ILdW6qqm8HmXDPC90vpuOPREODvUaYXlrXqfakGdC8sRqcHyC792ZS2wX4ITqmEdJqVElidi0UQVKzIrF1HGWgYe3NU6HciZIIGm0iOZAFpLcvMvyfaMczD0okwe6gi0UQVKzIrF1HGukKjUlLRNU6HcjjSlwoaRdbXWhA6QhsIoANJVecDdWXlTcjeQSEOfsHrlGdmVieJBV3EM12kgxSfIXBye61BbzaHmXOfWHmlczI7tx9qbKzrTGm0iOZAFpLcrlTWiqi9nOFRYzTpuzwHvaykKbRRoQwfEjl0UQVKzIrF1HGukKjUlLRNU6HcjjSlwoaRdbXWhA6QhQUSU6C8ufEjJJxAfsiuz9qlKcJwahyEHXc46HdqjmWC9nOFRYzTpeJBV3EM12kgxSfIXBye61BbzaHmXOfWHmlczI7tx9qbeqiYOVeUvymCGadZSw9Qfqca]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170716.234424, [[daKxtaqiKqTjKkJsvOtPkXRqcIzjKI6wibPDjLggu5yuvlts5zekmnHu6AcPQTjPsFtvQXjKkNdjOwNqkY8KuX9Ku1(ufCqvvwOQOhIu1efsHUOQQ2iHIoPqYmrcCtPyNqzPeYtrnvKYwjuTxL)cvnysDyrlMGhtPjlvxgSzvLptvmAj50u51iPzlXTjz3i(nKHtv64iHSCIEUGPRY1fQTleFNqPZJeTEHuW8vL0(P45pAJXsfmMDk6n6)fqbKllrtgDWr8uaJod2XSv68EJhhncFzC52ZXIGcKbyy1W5)g3B)62wdx0Il6R7yrq2PKMtbJLGkDKafQq83xBgSaPNel02JL55qKX)SNdrcJ2W8hTX)jPqb675y2kDEVXhYJNc0ArOshjwsWOPZOF0O7OR9RKkaFOczP2kbv6ibJ(bJwi(7RndwG0tIfA7XY8CiIrtNr)OrFofy0puVrxxCg9RVA0cXFFTcfeQxIdxBSxJ(fJMoJ2IqLosSK2sgjXleldxReuPJem6hmACgnDgnfB0cXFFTHdjvubWliBJ9A0Vm(NGR4okhNblq6jXcJJI0D28qYXeebg3G6INsSubJhJLky8VGfi9KyHXIGcKbyy1W5)2h3yrqaflTqy02nM(kWsTbfbua5MW4guhlvW4DdR2On(pjfkqFphZwPZ7nMIn6ZzP6iEm6xF1O7OR9RKkaFOczP2kbv6ibJUo1B0ES9X)eCf3r54VsQa8HkKL64OiDNnpKCmbrGXnOU4PelvW4XyPcglMLubgnxHSuhlckqgGHvdN)BFCJfbbuS0cHrB3y6Ral1gueqbKBcJBqDSubJ3nmXy0g)NKcfOVNJzR059gRsOeojs1AJLsGCg9d1B01Wz00z0sqLosWORt9gTq83xBgSaPNel02JL55qeJMoJ2IqLosSK2mybspjwOvcQ0rcgnfIrle)91Mblq6jXcT9yzEoeXORt9gDpwMNdrg)tWvChLJ)kPcWhQqwQJJI0D28qYXeebg3G6INsSubJhJLkySywsfy0CfYs1OF0)LXIGcKbyy1W5)2h3yrqaflTqy02nM(kWsTbfbua5MW4guhlvW4DdlAhTX)jPqb6754FcUI7OCmuafqUSGxOKHBCuKUZMhsoMGiW4gux8uILky8ySubJ)xafqUSy0plz4glckqgGHvdN)BFCJfbbuS0cHrB3y6Ral1gueqbKBcJBqDSubJ3nSOF0g)NKcfOVNJzR059gle)91c2keeWJ(WFvaEpsip8HyshKoIN2yVgnDgnfB0cXFFTzWcKEsSqBSxJMoJwLqjCsKQ1glLa5m6hQ3OJU6o(NGR4okhdP8QOO4Kkmoks3zZdjhtqeyCdQlEkXsfmEmwQGX)t5vrrXjvySiOazagwnC(V9XnweeqXslegTDJPVcSuBqrafqUjmUb1XsfmE3WQ7On(pjfkqFphZwPZ7nwLqjCsKQ1glLa5m6hQ3O99FB0V(QrtXgDkp3xAV2GyHsXr8GxLqjCsKQfiPqb6gnDgTkHs4KivRnwkbYz0puVrtHRn(NGR4okhdP8QWhQqwQJJI0D28qYXeebg3G6INsSubJhJLky8)uEvgnxHSuhlckqgGHvdN)BFCJfbbuS0cHrB3y6Ral1gueqbKBcJBqDSubJ3nS3J24)KuOa99CmBLoV34X)eCf3r54WHKkQa4fKJJI0D28qYXeebg3G6INsSubJhJLkymFiPIkaEb5yrqbYamSA48F7JBSiiGILwimA7gtFfyP2GIakGCtyCdQJLky8UHfDJ24)KuOa99CmBLoV34X)eCf3r54IJIIDD8Q0JkXFOduJJI0D28qYXeebg3G6INsSubJhJLkymf4OOyx3OBspQ0OPHoqnweuGmadRgo)3(4glccOyPfcJ2UX0xbwQnOiGci3eg3G6yPcgVByu4rB8FskuG(EoMTsN3BSq83xRxKybjE0h(RcWRsOeojs1g71OPZOfI)(AdhsQOcGxq2g71OPZOt75Ia4bcOCqWORJrlgJ)j4kUJYXfNNQJ4iEWlGk34OiDNnpKCmbrGXnOU4PelvW4XyPcgtbopvhXr8y0prLBSiOazagwnC(V9XnweeqXslegTDJPVcSuBqrafqUjmUb1XsfmE3W8XnAJ)tsHc03ZXSv68EJ7OR9RKkaFOczP2kbv6ibJ(bJ2MHd)5uGrtNr)OrBrOshjwcEjK2ZOF9vJwi(7RndwG0tIfAJ9A0Vm(NGR4okhxYijEHyz4ghfP7S5HKJjicmUb1fpLyPcgpglvWykiJKg9Zyz4glckqgGHvdN)BFCJfbbuS0cHrB3y6Ral1gueqbKBcJBqDSubJ3nmF)rB8FskuG(EoMTsN3B8JgTkHs4KivRnwkbYz0puVrxdNrtNrle)91cfqbKll4)q24qBSxJ(fJMoJ(rJwcFsiuLcfWOFz8pbxXDuo(RKkaFOczPooks3zZdjhtqeyCdQlEkXsfmEmwQGXIzjvGrZvilvJ(XAVm(N0ty8LspWH39vVe(KqOkfkWyrqbYamSA48F7JBSiiGILwimA7gtFfyP2GIakGCtyCdQJLky8UH5xB0g)NKcfOVNJzR059gRsOeojs1AJLsGCg9d1B0(((g9RVA0uSrNYZ9L2RniwOuCep4vjucNePAbskuGUrtNrRsOeojs1AJLsGCg9d1B0rxDn6xF1Obkk251l0BdkuPdshXd(kiLNrtNrduuSZRxO3Eva(oybxeqgWluqOoEVP9mA6mAvcLWjrQwBSucKZOFWOFJZOPZOVSaKRn)oqgQqwQTajfkqF8pbxXDuogs5vHpuHSuhhfP7S5HKJjicmUb1fpLyPcgpglvW4)P8QmAUczPA0p6)YyrqbYamSA48F7JBSiiGILwimA7gtFfyP2GIakGCtyCdQJLky8UH5lgJ24)KuOa99CmBLoV3yH4VVwjeqKKyb8h6avReuPJem66y0(4m6xF1OF0OfI)(ALqarsIfWFOduTsqLosWORJr)Orle)91Mblq6jXcT9yzEoeXOPqmAlcv6iXsAZGfi9KyHwjOshjy0Vy00z0weQ0rIL0Mblq6jXcTsqLosWORJr7h9g9lJ)j4kUJYXh6afEvgoqs54OiDNnpKCmbrGXnOU4PelvW4XyPcgtdDGYOBYWbskhlckqgGHvdN)BFCJfbbuS0cHrB3y6Ral1gueqbKBcJBqDSubJ3nm)OD0g)NKcfOVNJzR059gN2ZfbWdeq5GGr)Gr7B00z0P9Cra8abuoiy0py0(J)j4kUJYXLmsIxas14OiDNnpKCmbrGXnOU4PelvW4XyPcgtbzK0OFcPASiOazagwnC(V9XnweeqXslegTDJPVcSuBqrafqUjmUb1XsfmE3W8J(rB8FskuG(EoMTsN3BSq83xRxKybjE0h(RcWRsOeojs1g71OPZOt75Ia4bcOCqWORJrlgJ)j4kUJYXfNNQJ4iEWlGk34OiDNnpKCmbrGXnOU4PelvW4XyPcgtbopvhXr8y0prLZOF0)LXIGcKbyy1W5)2h3yrqaflTqy02nM(kWsTbfbua5MW4guhlvW4DdZVUJ24)KuOa99CmBLoV340EUiaEGakhem6hmAFJMoJoTNlcGhiGYbbJ(bJ2F8pbxXDuo2wLoc(IZt1rCepJJI0D28qYXeebg3G6INsSubJhJLkym9vPJy0uGZt1rCepJfbfidWWQHZ)TpUXIGakwAHWOTBm9vGLAdkcOaYnHXnOowQGX7gM)7rB8FskuG(Eo(NGR4okhxCEQoIJ4bVaQCJJI0D28qYXeebg3G6INsSubJhJLkymf48uDehXJr)evoJ(XAVmweuGmadRgo)3(4glccOyPfcJ2UX0xbwQnOiGci3eg3G6yPcgVBy(r3On(pjfkqFphZwPZ7nwcFsiuLcfy8pbxXDuo(RKkaFOczPoM(kWsTbfbua52ZXnOU4PelvW4Xrr6oBEi5ycIaJXsfmwmlPcmAUczPA0pkgVm(N0tyScfXr8uVF08LspWH39vVe(KqOkfkWyrqbYamSA48F7JBSiiGILwimA7g3GI4iEgM)4guhlvW4DdZNcpAJ)tsHc03ZX)eCf3r5yiLxf(qfYsDm9vGLAdkcOaYTNJBqDXtjwQGXJJI0D28qYXeebgJLky8)uEvgnxHSun6hR9Y4FspHXkuehXt9(JfbfidWWQHZ)TpUXIGakwAHWOTBCdkIJ4zy(JBqDSubJ3nSA4gTX)jPqb6754FcUI7OC8xjva(qfYsDm9vGLAdkcOaYTNJBqDXtjwQGXJJI0D28qYXeebgJLkySywsfy0CfYs1OFmAFz8pPNWyfkIJ4PE)XIGcKbyy1W5)2h3yrqaflTqy02nUbfXr8mm)XnOowQGX72nM9cwxwCrd55qKHvRU12Tb]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20170716.234424, [[d4Y9baGEcvTjcHDriABsvMTKBsK62iTtqTxXUvA)aggP8BvAWQYWLchuQQJrslufSueSycwoqpeHEk0YKspxvnrcLMQkAYiA6uDrPYLrDDsSzPOTtO4JejFMuDykFJOADQqtJqLtseoTIRri15jI(lr5XGCicjh1Cge2OCqCOebEDft51T6iW772sAGKapX8bE6gvOMvpOy5MMs55qqcCX2NdCRMQCn5Q9ezRM40eDVGydgASAeV5ZDdCBV2G9H85U)Cgy1CgSBnHIjZHGie40WdQBuHAwDr4GkCqyJYbXHse41vmLx3kGNugvOMvpib(FvaH4FoJhSVWuJlzqqLvMb5ZDLvZ3dkXsoqMFbdU3LdsGl2(CGB1uLRQfu6ljSr5G4qjc86kMYRBfWtkJkuZQFe4rYnnLYJh42CgSBnHIjZHGie40WdkkDJkuZQhe2OCqCOebEDft51Tkib(FvaH4FoJhSVWuJlzqqLvMb5ZDLvZ3dkXsoqMFbdU3LdsGl2(CGB1uLRQfu6ljSr5G4qjc86kMYRB1rGhj30ukpE8Gie40Wdgpb]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170622.212605, [[d8tCiaqyQwVQQEjPQSlsvKTHc63qntvvwgLQztY5vu3efYPr13Ou45IStf2R0UjSFH6NqyycmosvuVwvPgkrnyrz4q6GkYrjvjDmk5CKQeluvSuuulwqlNIhQQ4PGhJuRtvjmruOMkctMiMUkxeLUkLIUSsxhjBuu1wvvI2Sq2or6JIk9ziAAOaFxvAKKQQNrP0OjLXJICssLBPQKUgPk19ivHUnIwlPk44IkUwLOaTJECSipwCWnR2ciSjXpDd2cNBqUNSu5gwW4cK7hTL(7(uihQLANuCKcYvCfOlmJikkT3hh94yrQJGcmHikkT3hh94yrQJGc5qTuReD0ybW)VDWGGcjn87eLX1jIWnSqoul1k5JJECSi1NcZiIIs7r4gK7L6iOGELAP2uj6WQefyfEOAL0Nct0hhlIZ(XtxbG9xCgRAjxX5Q4mzZsJjd9RWWj3ca7V4mw1sUIZvXzYMLgtg6xbMx16PTd7bwm0kiW2caTHJEfoo5Qhd61H9suGv4HQvsFkmrFCSio7hpDfa2FXzSQLCfNRIZy8g5uQRWWj3ca7V4mw1sUIZvXzmEJCk1vG5vTEA7WEGfdTccSTaqB4OxHE9kK0WVWl)O1My7tHKg(DI6W9Pqsd)cV8JwBI6W9PW5gK7njO1WMcpiiiqWiM1LR(jkm38FvphOxSZGagAzzdBdSB3gbn6RmqVleHfxHjd3vXzd3yWVfsA4xc3GCVuFk8D4KGwdBkqGqMzD5QFIcCHeoTFyZKGwdBkWSUC1prbAh94yXKGwdBk8GGGabJkaOln3v8)(XXIoSZq7fsA4xGOpfYHAPwgZnl9XXIcmRlx9tuqqrQJglsDWGcj0vPYR8K2hScBkrbVdRcHDyvazhwfmDy1Rqsd)(XrpowK6tbMqefL2BIY4DeuqYg5uQBs(xbGt(joJvTKR4C1xeNLoxiXnsIZKMIZq6KHkUazbsNPjQd3rqHqf)))Cv43jLQHfCfQMdA4xzPSDyvWvOA(hmzOFYsz7WQajxmrD4ockW4nYPuxFk4QxFojlvUpfKYt8qUIFZeZOBbVaTJECSysXrkk8HDqWYCbj8eQYNjMr3cEbxHQ5tQxFojlLTdRcgxGCjMr3cEixXV5coLXzexS9PGRq1Cqd)klvUdRcFhMhloG)F7WYEHzerrP903tQJVAvWvOAoHBqUNSu5oSkWeIOO0E67j1HvbZQk8HDqWYCHe6Qu5vEsRHfCfQMt4gK7jlLTdRcoLXNe0AytHheeeiy0p28efYHAPwj6es40(HnP(uWPmUoreMygDlesffvGjerrP9iCdY9sDeu4CdY9YJfhCZQTacBs8t3GTaJCM4KuKXzeCYTdBdkqYftSDyBbG2WrVcfCfQMpPE95KSu5oSkqJjd9twkBdlGA4KUzopwCa))2HL9cOMLgtg63K8VcaN8tCgRAjxX5QViod1S0yYq)k8bJohNrGlWQwYvCUkoBcbBbsNPj2ockq4QvCXz5AWuODeu4CdY9KLY2WcZiIIs7PtiHt7h2K6iOqsd)QVDoKlKWfit9PWmIOO0EtugVJGcmHikkTNoHeoTFytQJGcFhMhlUcYeXzGlsXzd3yWVfCkJtmJUfcPIIk4ughqxLshJ7iOqsd)QtiHt7h2K6tbsNjGOdRcU61NtYsz7tbzdN0nZXzFC0JJfXztugVqHKg(vwkBFkqJjd9twQCdlCUb5E5XIRGmrCg4IuC2Wng8BbonwaOonxGSd9UW3H5XIdUz1waHnj(PBWwGKlaIockCUb5E5XId4)3oSSxiPHFNy7tbAh94yrES4kiteNbUifNnCJb)wWvOA(hmzOFYsL7WQaRWdvRK(uiXjrv7ec2oSxihko93Fjpb3SAl4fgo5wGvTKR4CvCMSHt6M5cmVQ1tBh2dSSradTSvpz3YwllBuiPHFLLk3Nc0o6XXI8yXb8)Bhw2liB4KUzoo7JJECSOW5gK7LkeQ4))NRc)2WcOgoPBM1rJfa))2bdckWPXc9agt2HTbfYHAPwj5XId4)3oSSxGPockKd1sTs03tQpfsA4x4LF0Atiy7tbNY42uWVcOkFEn9Ab]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170622.212605, [[d8ZpiaqyrRxvLxsfYUikPxRq52OYmrunoIs1SP48kYnreonkFtvv5YkTtQAVs7MW(vf)ecdJu9BOEUGHssdwrnCeoOcokrj6yc15Oc0cvvwkrXIjYYP0dvipfSmQO1ruktKkutfstgv10v5IK4QuPYZquUosTrQKTQQQYMfY2rv(OcvFgIMgIOVRknsQG2MQQmAsz8isNKO6wubCnQu19uvv1JrYAjkHJtLYnUOfOsIJHfUWIdUjZwaH7qjxUxPWLwK7PYtTsfSPa5osBPgRFfKmSF)g3GFRuHjerrH9gLehdlc1RxGuerrH9gLehdlc1RxWn6LE5lNcla2VTEsQxiOHFhOTPCreUsfCJEPx(JsIJHfH(vycruuyp00ICVq96fKL0l9gkA9XfTGIiLml)(vyG6yyXZm5SWvVSxWNCBbqH8NzfZYTIlnpZQ2LcZjLxbzwZMHTEN6X)fRRtwbGYYiUchJB)F9E17SOfuePKz53VcduhdlEMjNfU6)RGp52cGc5pZkMLBfxAEMD8gL0MRGmRzZWwVt94)I11jtwJlauwgXvOxVcbn8l8YokTbLkviOHFhOpCLkWOWcGiPycK17(cxArU3GGsdBl8HaffbjKr(4oeTaPiIIc75OVq96fiTE9cbn8lAArUxOFfgtAqqPHTfqrOkJ8XDiAbMGpJkpSDqqPHTfKr(4oeTavsCmSyqqPHTf(qGIIGefaILILg2V8yyr9o)ZzHGg(fq7xb3Ox61Xm7sDmSOGmYh3HOfe0CYPWIq9KSqGyngxMmOncBW2IwiRpUGT(4ciRpUGu9X9ke0WVJsIJHfH(vGuerrH9gOTz96f4VrjT5gujVaW4g9mRywUvCPr2EMdxk4Nw(pZ8cpZitojdtGSaxs6a9HRxVqAi0YbZBofu5PuFCH0qOLGg(vLNs9XfsdHwocZjLNkpL6JlWXed0hUENfsZBofu5P2Vc8ybMeZWUj0jITGubQK4yyXGHHuuyKIhvrMc8zbctoHorSfOkizy)(nUb)oymvQGnfix0jITqkXmSBQqsBtsWeB)kmHikkSNJ(c1RxymjxyXbSFB9XolK02CqqPHTf(qGIIGeKR4cTqAi0s00ICpvEQ1hxiPTPCregDIylirhfvWUMcJu8OkYuiqSgJltg0QuH0qOLOPf5EQ8uQpUWuD5a)5EDhmw3bj7FKrMojLDY0BKdqs3xWn6LE5lxWNrLh2g6xbgfwilWyU6jtVaPiIIc7HMwK7fQxVWLwK75clo4MmBbeUdLC5ELcKijLXrZ9mJY426jtVahtmOuVZcaLLrCfcmbsZwineA5G5nNcQ8uRpUGB0l9oyyifCR4kqvGWY4s7KlS4a2VT(yNfiSlfMtkVbvYlamUrpZkMLBfxAKTNzc7sH5KYRafMtkpvEkvQaxs6Gs96fqtZkUN5XTyAI61lCPf5EQ8uQuHryIPNzuCbfZYTIlnpZdiuke0WVoANKyc(mbYq)kmHikkSNCbFgvEyBOE9ctiIIc7nqBZ61lqkIOOWEYf8zu5HTH61l4gnJAS)JfGBYSfKkK02eDIylirhfviOHFLl4ZOYdBd9RqsBtGyng5oUE9cP5nNcQ8u6xHGg(vLNs)ke0WVdkvQafMtkpvEQvQGQLXL2PN5rjXXWIN5bABwWLj52NzqdtnwHlTi3ZfwCfurFMHueEM9P1IFlmMKlS4GBYSfq4ouYL7vkWXeaA9olCPf5EUWIdy)26JDwiOHFHx2rPnqF4(vGkjogw4clUcQOpZqkcpZ(0AXVfsdHwocZjLNkp16JlOisjZYVFfcmocZoGqPENfgtYfwCfurFMHueEM9P1IFl4tUTGIz5wXLMN5bekf4ssb061lOAzCPD6zEusCmSOGnpgUqqd)QYtTFfOsIJHfUWIdy)26JDwqM1SzyR3PE8)0)lMmz1zmzXX)RaHLXL2j5uybW(T1ts9cPHqlbn8Rkp16Jl4g9sV8DHfhW(T1h7SqewCfgSS08m7tRf)wWn6LE57OVq)k44nkPnx)kK020Dc2vGWKtRTxla]] )


end
