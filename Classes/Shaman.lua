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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170727.222840, [[dmKnyaqiPqlsGYMeqJIOCkI0SeOAxKyyG4yiyzIkpdHsttaCnbOTPuOVPuACkf5CkfL1jqmpbsDpIW(qO6GIIfkQQhIsnrbsCrPuNuuLzIqXnrj7KK(Psr1qvkOLkr9uQMQe5QcK0wriFvPa2l0FvQgSqhMYIr0JvYKb1LvTzb9zPOrlHttQvRuG8APKzJQBlPDd8BcdhKoUuGLJ0ZLQPR46Oy7evFxkOZlkTELcuZNiA)ImsalHEq5HgdFW8rx1QhDxxzNITbfgy96btqsr4hAm8b9YNFRFunhecBHSLWgvYrSbia5ca6(IQHoOJEM1OfGowcvjGLqVnWi5hgZhDFr1qh0hrZM8RObZPugOth9mKAUEYIEd1a49EXnk65bG1lBeu0bcWrNLaMiJQA1Jo6Qw9OVb0a4u0lUrrV8536hvZbHWwcqqV87cg66DSeoOZU4RwSeYF9GbjrNLaw1QhDCq1Cyj0Bdms(HX8r3xun0bDzPOSuCm(bJsHP59rqRkhyK8dNIbMInMIKmHHkHurFiPgawHbAkknfLuYuSXuCm(bJsHP59rqRkhyK8dNIsrpdPMRNSOl3OAJKF0ZdaRx2iOOdeGJolbmrgv1Qh9ctZ7JGwzx8vl0vT6r3hb9PirgN5ONH2SJoWQxIctZ7JGwzx8vRGl34mxczYgJFWOuyAEFe0QYbgj)Wb2ijtyOsiv0hsQbGvyGkvsjBCm(bJsHP59rqRkhyK8dlf9YNFRFunhecBjab9YVlyOR3Xs4Go7IVAXsi)1dgKeDwcyvRE0XbvjwSe6Tbgj)Wy(O7lQg6GUSuSXuCm(bJsidn7UiC30uLdms(HtrjLmfLLIJXpyuczOz3fH7MMQCGrYpCkgykwTZ7dvuvwmu6btks8uCtqsrPPOu0ZqQ56jl6YnQ2i5h98aW6Lnck6ab4OZsatKrvT6rpKHMLDXxT2ee0vT6r3hb9PirgN5POmcsrpdTzhDGvVeHm0SSl(Q1MGeC5gN5siRXX4hmkHm0S7IWDttvoWi5hwsjLng)GrjKHMDxeUBAQYbgj)WbwTZ7dvuj(MGivk6Lp)w)OAoie2sac6LFxWqxVJLWbD2fF1ILq(Rhmij6SeWQw9OJdQgaSe6Tbgj)Wy(O7lQg6GUSuSXuCm(bJsidn7UiC30uLdms(HtrjLmfLLIJXpyuczOz3fH7MMQCGrYpCkgykwTZ7dvuvwmu6btks8uClKuuAkkf9mKAUEYIUCJQns(rppaSEzJGIoqao6SeWezuvRE0dzOzzx8vRTqqx1QhDFe0NIezCMNIYYjf9m0MD0bw9seYqZYU4RwBHeC5gN5siRXX4hmkHm0S7IWDttvoWi5hwsjLng)GrjKHMDxeUBAQYbgj)WbwTZ7dvuj(wisLIE5ZV1pQMdcHTeGGE53fm017yjCqNDXxTyjK)6bdsIolbSQvp64GQbelHEBGrYpmMp6(IQHoOllfBmfhJFWOeYqZUlc3nnv5aJKF4uusjtrzP4y8dgLqgA2Dr4UPPkhyK8dNIbMIv78(qfvLfdLEWKIepfdqatrPPOu0ZqQ56jl6YnQ2i5h98aW6Lnck6ab4OZsatKrvT6rpKHMLDXxTcqarx1QhDFe0NIezCMNIYiwPONH2SJoWQxIqgAw2fF1kabm4YnoZLqwJJXpyuczOz3fH7MMQCGrYpSKskBm(bJsidn7UiC30uLdms(HdSAN3hQOs8aeqPsrV8536hvZbHWwcqqV87cg66DSeoOZU4RwSeYF9GbjrNLaw1QhDCq1nILqVnWi5hgZhDFr1qh0LLInMIJXpyuczOz3fH7MMQCGrYpCkkPKPOSuCm(bJsidn7UiC30uLdms(HtXatXQDEFOIQYIHspysrINI5cykknfLIEgsnxpzrxUr1gj)ONhawVSrqrhiahDwcyImQQvp6Hm0SSl(QvUaIUQvp6(iOpfjY4mpfLfaPONH2SJoWQxIqgAw2fF1kxadUCJZCjK14y8dgLqgA2Dr4UPPkhyK8dlPKYgJFWOeYqZUlc3nnv5aJKF4aR259HkQepxaLkf9YNFRFunhecBjab9YVlyOR3Xs4Go7IVAXsi)1dgKeDwcyvRE0Xbv3ILqVnWi5hgZhDFr1qh0LLInMIJXpyueYpDvy0Mx5aJKF4uusjtrzP4y8dgfH8txfgT5voWi5hofdmfR259HkQklgk9GjfjEkUfskknfLIEgsnxpzrxUr1gj)ONhawVSrqrhiahDwcyImQQvp6Bo7nui4BHGUQvp6(iOpfjY4mpfLfqPONH2SJoWQxInN9gke8TqcUCJZCjK14y8dgfH8txfgT5voWi5hwsjLng)Grri)0vHrBELdms(HdSAN3hQOs8TqKkf9YNFRFunhecBjab9YVlyOR3Xs4Go7IVAXsi)1dgKeDwcyvRE0Xbv3ewc92aJKFymF09fvdDqxwk2ykog)Grri)0vHrBELdms(HtrjLmfLLIJXpyueYpDvy0Mx5aJKF4umWuSAN3hQOQSyO0dMuK4P4gHKIstrPONHuZ1tw0LBuTrYp65bG1lBeu0bcWrNLaMiJQA1J(MZEdfc(gHGUQvp6(iOpfjY4mpfLTrPONH2SJoWQxInN9gke8ncj4YnoZLqwJJXpyueYpDvy0Mx5aJKFyjLu2y8dgfH8txfgT5voWi5hoWQDEFOIkX3iePsrV8536hvZbHWwcqqV87cg66DSeoOZU4RwSeYF9GbjrNLaw1QhDCq1ndlHEBGrYpmMp6(IQHoOllfFdy0qHEyLEvWHpvdAUxCJoPOu0ZqQ56jl6YnQ2i5h98aW6Lnck6ab4OZsatKrvT6rV4gDA3agnuOhgDvRE09rqFksKXzEkkBRu0ZqB2rhy1lrXn60UbmAOqpCWLBCMlHS3agnuOhwHqajSjcBMu0lF(T(r1CqiSLae0l)UGHUEhlHd6Sl(QflH8xpyqs0zjGvT6rhhuLaeSe6Tbgj)Wy(O7lQg6GUSu8nGrdf6HvSwMgW03nYUGZmFFdIPp61trPONHuZ1tw0LBuTrYp65bG1lBeu0bcWrNLaMiJQA1JU1Y0aM2nGrdf6Hrx1QhDFe0NIezCMNIY2Ku0ZqB2rhy1lH1Y0aM2nGrdf6HdUCJZCjK9gWOHc9Wkei2Tq2uaKIE5ZV1pQMdcHTeGGE53fm017yjCqNDXxTyjK)6bdsIolbSQvp64GQeiGLqVnWi5hgZhDFr1qh0LLIYnQ2i5xXAzAat7gWOHc9WPyGPijtyOsHy2lmaScd0umWuSXuKKjmujKk6dj1aWkmqtrPONHuZ1tw0LBuTrYp65bG1lBeu0bcWrNLaMiJQA1JU1Y0aMmo6Qw9O7JG(uKiJZ8uu2Mjf9m0MD0bw9syTmnGjJhC5gN5sitUr1gj)kwltdyA3agnuOhoqsMWqLcXSxyayf6T1eyJKmHHkHurFiPgawHbQu0lF(T(r1CqiSLae0l)UGHUEhlHd6Sl(QflH8xpyqs0zjGvT6rhhuLqoSe6Tbgj)Wy(O7lQg6GUSuSXuKKjmuHRBwmanO5(IA9cfgOPyGPy)ZoPaW0vg9P5GSNd6kfjEkcjfLIEgsnxpzrxUr1gj)ONhawVSrqrhiahDwcyImQQvp6eJUzXa0GMSPwVqvmbvOORA1JUpc6trImoZtrzeGif9m0MD0bw9sqm6MfdqdAYMA9cvXeuHgC5gN5siRrsMWqfUUzXa0GM7lQ1luyGgy)ZoPaW0vg9P5GSNd6sk6Lp)w)OAoie2sac6LFxWqxVJLWbD2fF1ILq(Rhmij6SeWQw9OJdQsGyXsO3gyK8dJ5JUVOAOd6YsrzPijtyOIXHwy7nuWdvOVAAqpfd6umxkgyksYegQyCOf2Edf8qf6RMg0tXGofZLIbMIKmHHkghAHT3qbpuH(QPb9umOtXCPO0umWum8uJV3HQP6rH(QPb9uK4PyasrPONHuZ1tw0LBuTrYp65bG1lBeu0bcWrNLaMiJQA1JUXHwyBabpKDXxTqx1QhDFe0NIezCMNIYiqqk6zOn7OdS6LW4qlSnGGhYU4RwbxUXzUeYKb9Jsiv0N9gk4HkKmHHkghAHT3qbpuH(QPb9GoxGq)OeQpn7Edf8qfsMWqfJdTW2BOGhQqF10GEqNlqOFu46MfdqdAU3qbpuHKjmuX4qlS9gk4Hk0xnnOh05Kgy4PgFVdvt1Jc9vtd6epasrV8536hvZbHWwcqqV87cg66DSeoOZU4RwSeYF9GbjrNLaw1QhDCqvcbalHEBGrYpmMp6zi1C9KfDM(31ZRD0ZdaRx2iOOdeGJolbmrgv1QhD0vT6rpO2FkM38Ah9YNFRFunhecBjab9YVlyOR3Xs4Go7IVAXsi)1dgKeDwcyvRE0XbvjeqSe6Tbgj)Wy(ONHuZ1tw0xgNVBRrla7CDFqppaSEzJGIoqao6SeWezuvRE0rx1QhD2gNNIzwJwasrIr3h0ZqB2rhy1lrWCDLDk2guyG1Rhmbjffqp40GHE5ZV1pQMdcHTeGGE53fm017yjCqNDXxTyjK)6bdsIolbSQvp6UUYofBdkmW61dMGKIcOhCkoOkHnILqVnWi5hgZhDFr1qh0jzcdvS(6aydSUcdu0ZqQ56jl6lJZ3T1OfGDUUpONhawVSrqrhiahDwcyImQQvp6ORA1JoBJZtXmRrlaPiXO7tkkJGu0ZqB2rhy1lrWCDLDk2guyG1RhmbjfT(kyOx(8B9JQ5GqylbiOx(DbdD9owch0zx8vlwc5VEWGKOZsaRA1JURRStX2GcdSE9GjiPO1x4GQe2ILqVnWi5hgZh9mKAUEYI(Y48DBnAbyNR7d65bG1lBeu0bcWrNLaMiJQA1Jo6Qw9OZ248umZA0cqksm6(KIYYjf9m0MD0bw9semxxzNITbfgy96btqsrsMWWEWqV8536hvZbHWwcqqV87cg66DSeoOZU4RwSeYF9GbjrNLaw1QhDxxzNITbfgy96btqsrsMWWooOkHnHLqVnWi5hgZh9mKAUEYI(Y48DBnAbyNR7d65bG1lBeu0bcWrNLaMiJQA1Jo6Qw9OZ248umZA0cqksm6(KIYiwPONH2SJoWQxIG56k7uSnOWaRxpycskYoO0dg6Lp)w)OAoie2sac6LFxWqxVJLWbD2fF1ILq(Rhmij6SeWQw9O76k7uSnOWaRxpycskYoO0XbvjSzyj0Bdms(HX8rpdPMRNSOVmoF3wJwa256(GEEay9YgbfDGaC0zjGjYOQw9OJUQvp6SnopfZSgTaKIeJUpPOSaif9m0MD0bw9semxxzNITbfgy96btqsXLG(GHE5ZV1pQMdcHTeGGE53fm017yjCqNDXxTyjK)6bdsIolbSQvp6UUYofBdkmW61dMGKIlb94GQ5GGLqVnWi5hgZh9mKAUEYI(Y48DBnAbyNR7d65bG1lBeu0bcWrNLaMiJQA1Jo6Qw9OZ248umZA0cqksm6(KIYcOu0ZqB2rhy1lrWCDLDk2guyG1Rhmbjfd1C(Pbd9YNFRFunhecBjab9YVlyOR3Xs4Go7IVAXsi)1dgKeDwcyvRE0DDLDk2guyG1Rhmbjfd1C(P4Gd6o0V0gxVbBJwaq1CBKyXbra]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170727.222840, [[daZWbaGEuq7cLyBOKMjukZMQUPKCBPStQSxYUvA)uQgMe9BvgkkWGPugUK6GIWXqLfkswkuSykA5q1dfLEk4Xs16GsmrOKMQeMmetx4IIIlJCDrQTIISzOuTDuktteDyv9CiTmkz0u4BOkNeLQNHcDAfNhf1NfvVgvL)IQQfNkeGvc7FAFOucCFJeatlRDBzwJF7uJ2al2TvJt9Rz(HamKNEusoRsoEL84yLflgtM0kPaOJp1Habj6XClQkKJtfcYSVPNqukbqhFQdbXLN7jwQVyUfvqcZXpbZcQVyUva7lY0)4WfS3scQoeMEC33ibcCFJeWGlMBfGH80JsYzvYXJRuagc9sJ3juvOqqwdQZx1Xg1OnKPGQdX9nsGc5SuHGm7B6jeLsqcZXpbZc8tUrSZMZpQXqEebSVit)JdxWEljO6qy6XDFJeiW9nsa2MCJyNn3UnWyipIamKNEusoRsoECLcWqOxA8oHQcfcYAqD(Qo2OgTHmfuDiUVrcuOqaut959dd)yUvolwzuHe]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170727.222840, [[d4ZKlaGEQuvTjQe7Ii2gir7dKYmrISmQWSvy(urUPKCzOVHeomLDQI9k2nW(LYOOszyiPXrfLoVI40igSunCsYbrkDkQKoMK64GeSqKILsclgulNWdjPEkQhlX6OIQAIurvMkrAYQ00v1fvQ6QuPk9mKOUUszJuPQSvsKnRuz7kQxJu9vQOYNbX3bj0TvYFvKgnr9CQ6KKOMgiPRrLk3dKQdrffNJkvXVj1Posd78WD224dnH5IGO6dhwboqZJ54GAnfuPOgkL4GYqfQoGAywfwi2G4(TNOb54akPCyAlprd8rAo1rA49adEG3qtyUiiQ(WZMGyWduYUnXe1YyHUd3fMwyYG8tcJM4LrWuVkcDmSYGlPyVwegOby4k9vjtCSfgo8Xwy49M4LrqRZQi0XWkWbAEmhhuRPOMAyfOxVjkOpsZhwTmwOxPNXfc(ahUsFp2cdNphhrA49adEG3qtyUiiQ(WotRdVTBNKIW8YtheiYpGaGiztvR7sRBLNmJtraUiOV1Hg0BDhHPfMmi)KWfH5LNoiqKFabajSYGlPyVwegOby4k9vjtCSfgo8Xwyy1cZl36uIar(beaKWkWbAEmhhuRPOMAyfOxVjkOpsZhwTmwOxPNXfc(ahUsFp2cdNphkhPH3dm4bEdnHPfMmi)KWqrc461aiHvgCjf71IWanadxPVkzIJTWWHp2cd7CeW1RbqcRahO5XCCqTMIAQHvGE9MOG(inFy1YyHELEgxi4dC4k99ylmC(CGAKgEpWGh4n0eMlcIQpSvEYmofb4IG(whAqV1D2w3jNAD3ADR8KzCkcWfb9To0GERdLTUlT(Bde8skcZltaqM6FTyjbbg8aVTURHPfMmi)KWfH5LNoiqKFabajSYGlPyVwegOby4k9vjtCSfgo8Xwyy1cZl36uIar(beaKw3TAxdRahO5XCCqTMIAQHvGE9MOG(inFy1YyHELEgxi4dC4k99ylmC(CCxKgEpWGh4n0eMwyYG8tcdfjGR)fe6yyLbxsXETimqdWWv6RsM4ylmC4JTWWohbC9VGqhdRahO5XCCqTMIAQHvGE9MOG(inFy1YyHELEgxi4dC4k99ylmC(CGYin8EGbpWBOjmxeevFy4TD7K4FTybliaiOqYMQw3LwF2eedEGs2TjMOwgl0D4UW0ctgKFsy)Rfl)li0XWkdUKI9AryGgGHR0xLmXXwy4WhBHH5xlw(xqOJHvGd08yooOwtrn1WkqVEtuqFKMpSAzSqVspJle8boCL(ESfgoFouePH3dm4bEdnH5IGO6dBLNmJtraUiOV1Hg0BDO26o5uR7wRBLNmJtraUiOV1Hg0BDhTUlT(Bde8skcZltaqM6FTyjbbg8aVTURHPfMmi)KWfH5LNoiqKFabajSYGlPyVwegOby4k9vjtCSfgo8Xwyy1cZl36uIar(beaKw3nhUgwboqZJ54GAnf1udRa96nrb9rA(WQLXc9k9mUqWh4Wv67Xwy4854SrA49adEG3qtyUiiQ(WVnqWlrpJIISjGGsqGbpWBR7sRpBcIbpqj72etulJf6q1DTUlT(YWH)f6LKYMqGGV1Hg0BDOsnmTWKb5NeEqGi)acaYuy94dRm4sk2RfHbAagUsFvYehBHHdFSfgMseiYpGaG060OhFyf4anpMJdQ1uutnSc0R3ef0hP5dRwgl0R0Z4cbFGdxPVhBHHZNJ7jsdVhyWd8gAcZfbr1h2Tw3zA93gi4LONrrr2eqqjiWGh4T1DP1NnbXGhOKDBIjQLXcDO6Uw31w3jNAD3A93gi4LONrrr2eqqjiWGh4T1DP1NnbXGhOKDBIjQLXcDNLAR7AyAHjdYpjS)1IL)fe6yyLbxsXETimqdWWv6RsM4ylmC4JTWW8Rfl)li0Xw3TAxdRahO5XCCqTMIAQHvGE9MOG(inFy1YyHELEgxi4dC4k99ylmC(CQPgPH3dm4bEdnH5IGO6dpBcIbpqjgDJa2OLdtlmzq(jH3j0(hwyGByLbxsXETimqdWWv6RsM4ylmC4JTWWUpH2)WcdCdRahO5XCCqTMIAQHvGE9MOG(inFy1YyHELEgxi4dC4k99ylmC(CQRJ0W7bg8aVHMWCrqu9HH32TtIS(NkBGRKnvTUlTUBTUBT(Sjig8aLy0ncyBpuyJOsfEBDxAD4TD7KStO9pSWaxjBQADxBDNCQ1DMwF2eedEGsm6gbSThkSruPcVTURHPfMmi)KWdB2MomVCyLbxsXETimqdWWv6RsM4ylmC4JTWWuYMTwNsMxoScCGMhZXb1AkQPgwb61BIc6J08HvlJf6v6zCHGpWHR03JTWW5ZP2rKgEpWGh4n0eMlcIQpSvEYmofb4IG(whAqV1PCyAHjdYpjSFdCrbbajSYGlPyVwegOby4k9vjtCSfgo8XwyyEdCrbbajScCGMhZXb1AkQPgwb61BIc6J08HvlJf6v6zCHGpWHR03JTWW5ZPMYrA49adEG3qtyUiiQ(Ww5jZ4ueGlc6BDOb9wNYTUto16ZMGyWducLiqKFabarTW8Yh97Ev16o5uRpBcIbpqj2qLS5C6Xo1YyHEyAHjdYpjCryE5Pdce5hqaqcRm4sk2RfHbAagUsFvYehBHHdFSfgwTW8YToLiqKFabaP1DJYUgwboqZJ54GAnf1udRa96nrb9rA(WQLXc9k9mUqWh4Wv67Xwy485dFSfgMjl1T(EGSbk4cbVZV1lAbMpba]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170727.222840, [[dadqbaGEjuBsPQDjrTnjYSvXnrkFdj2Pc7LA3e2VIgMu1Vr1GvYWLshuk6yQ0cvQSuPYIjLLJYdLcpf8yIEojMOqXuvktMunDrxus5zsQUojzRKu2SqLTlHSmHmnKQ5jjDzOdRQrljUTGtkbDAextO05jP6ZsGxJKwNqv7R3medg3R6KENbqYiTPbdD4bFf0JO(lLEk3sLJQtNEeDdqlkj)Hu8NeUWJOs1n0uMeUqXBEC9MHAIx7G6ENbqYiTPHWJhLKXdLLQymuKZv156g7CTFUssaNRQZvbsDdn1ihsQUbgxsvJKiZqHcDI8toZGGlqd046Q9SXhqdggFan0XLu1ijYm0Hh8vqpI6VuU9g6qfUkMev8MtdnQGsQ04fHbuKwZanU(4dObNonm(aAaiHgZvnrLxiXakY4NlElkqMtBa]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170727.222840, [[dWJGhaGEujvBIc1UiyBOsSpPeZMkZxQ6MGYYejFdu5Yi7eL2RYUv1(HAuOsnmr53soSkdfvsAWqgUO6GOkDkuvDmu48GQwiQklLIAXeA5u1drv8uspwO1HkPmrPKmvkYKfmDGlsHCAIEMiORlfBKcsBvezZOITtbMNiWxLsQMgfuFxKAKOsIpJIgTuQBdYjfHETuPRjI6EsjL)kv8CkDikiEmMPPTI4CnoW4BQg9YCW0PMjhDwASPYyaxgCm4IqQeAydNYWt1CkkpNKRFaz9Jnfxs4uEJaz92zASmMPPg9NOJctCQg9YCWuqXKPJeIv5cv63IrgJrCJrGZZKacTPZbAlKhbyucWOujJr99yeqcryulyuMqYzzye)t5vu6Ka4Nk6Qk4ASGPj(bz8aLF6xpnfwfs68ShenDk7brt5kKVKwOPMjhDwASPYyahJSPMjB14JKDMgykpTPyxyLbee9GjofwfypiA6aJn1mn1O)eDuy8nvJEzoykOyY0rcXQCHk9BXiJXiUXiXgoCeoBK(W9rsOjhJ67XiUXioK)CDS5sVei4jOt(wmQfmkzmIFmQVhJCKbKdJsagXildJ4FkVIsNea)urYBjFx5ZCAIFqgpq5N(1ttHvHKop7brtNYEq0u(iVL8DLpZPMjhDwASPYyahJSPMjB14JKDMgykpTPyxyLbee9GjofwfypiA6aJnHZ0uJ(t0rHX3un6L5GPGIjthjeRYfQ0VfJmgJ4gJeB4Wr4Sr6d3hjHMCmQVhJ4gJ4q(Z1XMl9sGGNGo5BXOwWOKXi(XO(EmYrgqomkbyeJSmmI)P8kkDsa8tfDvf6WPXd)0e)GmEGYp9RNMcRcjDE2dIMoL9GOP85QkGrgAJh(PMjhDwASPYyahJSPMjB14JKDMgykpTPyxyLbee9GjofwfypiA6aJ1WZ0uJ(t0rHX3un6L5GPGIjthjKxaz9wmYymIBmsSHdhHZgPpCFKeAYXO(EmYqWiW5OhiC2i9H7JKa9NOJcyKXyehYFUo2CPxce8e0jFlg1cgLmg13JrGZZKacaje1buDcscJsqRHrCjdJ4FkVIsNea)08ciRFAIFqgpq5N(1ttHvHKop7brtNYEq0uUAbK1p1m5OZsJnvgd4yKn1mzRgFKSZ0at5Pnf7cRmGGOhmXPWQa7brthySjpttn6prhfgFt1OxMdMckMmDKqSkxOs)2P8kkDsa8t5q(Z1XMl9sW0e)GmEGYp9RNMcRcjDE2dIMoL9GOPgk5phgP5sVem1m5OZsJnvgd4yKn1mzRgFKSZ0at5Pnf7cRmGGOhmXPWQa7brthySCzMMA0FIokm(MQrVmhmLBmIBmYqaftMosiwLluPFlgzmgzjaq(mTcNZvP7es3jqw4)igXpg13JrXQCHk9lC2i9H7JKGNGo5BXOwWiUGr8Jr99ye4C0deeRgxG8CKwGa9NOJcyuFpgfiXgoCeOZdAtFhBUSlj0KpLxrPtcGFAOkOoPLFWonXpiJhO8t)6PPWQqsNN9GOPtzpiAARQccJAD5hStnto6S0ytLXaogztnt2QXhj7mnWuEAtXUWkdii6btCkSkWEq00bglCZ0uJ(t0rHX3un6L5GPGIjthjeRYfQ0VfJmgJeB4Wr4Sr6d3hjHqL(XiJXiUXiXgoCeSGYdj6LptYl0KJr99yuSkxOs)cwq5HSaVSlj4jOt(wmQfmkdJ4FkVIsNea)0ZgPpCFKMM4hKXdu(PF90uyviPZZEq00PShenLxBK(W9rAQzYrNLgBQmgWXiBQzYwn(izNPbMYtBk2fwzabrpyItHvb2dIMoWatzpiAQkH4bJm6BFFKGOhW1WiEALDGna]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170727.222840, [[d4d9iaGEIsvBIqAxkLTbuAFaHzsQklJuA2smFGu3urUm03uuomv7uvTxXUbTFPmkGIHjv(nsNhOAOeOmyjnCfvhKiCkcKJjvDoIsLfsiwkbTyalhXdjfpf1JvY6iqvtKavMkHAYQY0v5IeWPj5zarUoLSrsv1wjk2mr12js3MI)sPY0ivzEar9AsLptPmALQXrPkNKi6NuQQRruY9asEUchIOu64eLItFehwWHYDRYfrcZlIA(foSqSG(aZxBx)SUz9GDtliPNEA1lmphxkVOK9(POW81cwqkSeRtrHJio)(ioSaqhOGVisyEruZVWghlJJqnBllcbHxRcYTAV2UWsaOkQd8We6shG6qsyjHp1YpkjmKcXWt0Nmo57gmC4VBWWcPlDaQdjHfIf0hy(A76N13fwioOwKfoI4CH1SJlDtuPObHxacprFF3GHZLV2ioSaqhOGVisyEruZVWawYLVjV4g8OqBw4gbnUcoAvqUv1BZEHLaqvuh4HLxCdEuOnlmSKWNA5hLegsHy4j6tgN8Ddgo83nyy9xCdEuOnlmSqSG(aZxBx)S(UWcXb1ISWreNlSMDCPBIkfni8cq4j677gmCU8bPioSaqhOGVisyEruZVWGPvpVGWBBr8XUcAZUXrjMne6af81QGg0TQVoLu0oeIgfoAvqaQwvBRkOwv0w9HawYLVHo52rODJ5kD4M18wv0w14yzCeQzBzrii8AvqaQwvVUwv0wvQtuoqb3SVgbJslGTlSeaQI6ap8I4JD7kkB7hubTfws4tT8JscdPqm8e9jJt(Ubdh(7gmSgIp2Bv9PSTFqf0wyHyb9bMV2U(z9DHfIdQfzHJioxyn74s3evkAq4fGWt033ny4C5RxehwaOduWxejmViQ5x4Zli822DvzCuIzdHoqbFTQOTkGLC5BYj0XbqC4BJGgxbhTki3Q6TzVwv0w14yzCeQzBzrii8Avq0Q61fwcavrDGhwoHooaIdFHLe(ul)OKWqkedprFY4KVBWWH)UbdRFcDCaeh(clelOpW8121pRVlSqCqTilCeX5cRzhx6MOsrdcVaeEI((UbdNlFzfXHfa6af8frcZlIA(fwQtuoqb3CDUcAjGSXsnFo(AvrBvzBRcyjx(MCcDCaeh(2SM3QI2QghlJJqnBllcbHxRccq1QZKvyjauf1bEy5e64aio8fws4tT8JscdPqm8e9jJt(Ubdh(7gmS(j0XbqC4RvbtVGclelOpW8121pRVlSqCqTilCeX5cRzhx6MOsrdcVaeEI((UbdNlFWgXHfa6af8frclbGQOoWdpSGpKOG2clj8Pw(rjHHuigEI(KXjF3GHd)DdgMTGpKOG2clelOpW8121pRVlSqCqTilCeX5cRzhx6MOsrdcVaeEI((UbdNl)zrCybGoqbFrKW8IOMFHnowghHA2wweccVwfeGQvLvxRkARk1jkhOGB2xJGrPLzDTQOTQuNOCGcUj3IaUMDCPZEDHLaqvuh4HlUu3UIp2dlj8Pw(rjHHuigEI(KXjF3GHd)DdgwFUuVv1Np2dlelOpW8121pRVlSqCqTilCeX5cRzhx6MOsrdcVaeEI((UbdNlF7fXHfa6af8frclbGQOoWdtOlDaQdjHLe(ul)OKWqkedprFY4KVBWWH)UbdlKU0bOoK0QGPxqHfIf0hy(A76N13fwioOwKfoI4CH1SJlDtuPObHxacprFF3GHZLVSlIdla0bk4lIeMxe18lmyAvJJLXrOMTLfHGWRvbbOAvWkRwf0GUvpVGWBBr8XUcAZUXrjMne6af81QGg0TQVoLu0oeIgfoAvqaQwvBRkOwv0wvQtuoqb3SVgbJslGTRvfTvL6eLduWn5weW1SJlD6jRWsaOkQd8WlIp2TROSTFqf0wyjHp1YpkjmKcXWt0Nmo57gmC4VBWWAi(yVv1NY2(bvqBTky6fuyHyb9bMV2U(z9DHfIdQfzHJioxyn74s3evkAq4fGWt033ny4C533fXHfa6af8frclbGQOoWdlV4g8OqBwyyjHp1YpkjmKcXWt0Nmo57gmC4VBWW6V4g8OqBwyRcMEbfwiwqFG5RTRFwFxyH4GArw4iIZfwZoU0nrLIgeEbi8e99DdgoxUWF3GHzLrtRkaC3Hl0GWtW3QYvLcsYLa]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170727.222840, [[dOJNgaGEiu1MiO2ff2MsK9bPWmHqLztLBQK(geStv1EL2nW(fAuqkzyqYVbTmc1LrgSGHtuDqiQtbPIJPuoSOfsGwkHSyvz5q9qLkRcsrpwHNROjcHIPsuMmLMUkxKG8kiL6zueDDs1gHq2kfPntkBhI8DkQonjttjQ5rr4qqQ62u1OjIxReojfLptKUgKkDELQ(lbSoiu6POUBvwzedPL6URcwMhyL8RCzrKJYj1VyuBiGcHTLmeBYLxw8YLz50qLofIppfe0V4LmzzKhNccMvw)BvwzHa5Zr2kyzEGvYVYx6iWz4sGD6uwYGa5Zr2yq4ya9XWtxtZWLa70PSKHU8Yi)uo1TVmgow8uhHlBgWQg5bXLbqavEfAnnX)0tLl)tpvweCS4Pocxwe5OCs9lg1gcBOklIMqD8GMvwVY7KqJfRqKipbU(kVcT)0tL71V4kRSqG85iBfSmpWk5xz0hdNASqbKgdchd(KCZdd9gdDmMaxmGgXGyXLr(PCQBFznD8EbGAcKkCzZaw1ipiUmacOYRqRPj(NEQC5F6PYishVpgGAXaYkCzrKJYj1VyuBiSHQSiAc1XdAwz9kVtcnwScrI8e46R8k0(tpvUx)MSYkleiFoYwblZdSs(voXNslhNr6KljfWCOtZaNGfXaAedOIbHJb5ycjbKoSgBgAeoDcmLRWQRmYpLtD7lpW5uIaoLujhqbKw2mGvnYdIldGaQ8k0AAI)PNkx(NEQ8oCoLedioLujhqbKwwe5OCs9lg1gcBOklIMqD8GMvwVY7KqJfRqKipbU(kVcT)0tL71)YvwzHa5Zr2kyzEGvYVYOpgE6AAgAU0theivNm0Lxg5NYPU9L1CPNoiqQov2mGvnYdIldGaQ8k0AAI)PNkx(NEQmICPNoiqQovwe5OCs9lg1gcBOklIMqD8GMvwVY7KqJfRqKipbU(kVcT)0tL71p6wzLfcKphzRGL5bwj)kFPJaNHKu5Mhe7niq(CKngeogqFm8010m0WW59WjWAOlpgeogqkXQ85idnD8(DsOXILr3Yi)uo1TVSggoVhob2YMbSQrEqCzaeqLxHwtt8p9u5Y)0tLregoVhob2YIihLtQFXO2qydvzr0eQJh0SY6vENeASyfIe5jW1x5vO9NEQCV(xQYkleiFoYwblZdSs(v(PRPzO5spDqGuDYat(ubMXGjIHLIb0ogKoSXGWXWacDwO5adle6fWCfWonWKpvGzmyIyq6WgdOzmiUmYpLtD7lR5spDqGuDQSzaRAKhexgabu5vO10e)tpvU8p9uze5spDqGuDkgqRn0PSiYr5K6xmQne2qvwenH64bnRSEL3jHglwHirEcC9vEfA)PNk3RFeQSYcbYNJSvWY8aRKFLV0rGZqsQCZdI9geiFoYgdchdpDnndnmCEpCcSgyYNkWmgmrmSumG2XG0HngeoggqOZcnhyyHqVaMRa2PbM8PcmJbtedsh2yanJbXLr(PCQBFznmCEpCcSLndyvJ8G4YaiGkVcTMM4F6PYL)PNkJimCEpCcSXaATHoLfrokNu)IrTHWgQYIOjuhpOzL1R8oj0yXkejYtGRVYRq7p9u5E9k)tpvMv(DXGqajjyqEcCi2y4PRPn71ca]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20170727.222840, [[d8cxcaGEHq7cPQTPOy2i5MuY3qP2jvTxYUvA)cLHjQ(nOblIgok6GIWXqvluKAPkYIPulxspuO6PQEScpNktui1ufLjtX0bUiQ4zifxhvARiv2SqW2rbFviAAkQ(Uizzs4YqJgLCyPojsP)kKCAeNhf61s0TfSofLw8ktpAmcnxkGsRFM4G0uKi2acCLVygA0NqkSDO8f58SZzZpd9f0mFEXC9pQeMaD9edabUoLjpVY05STnfAuA9e2ekcGrDSRaw4gLJjPe1PDnKrdGv9fUOUf0qxx9Da119Da150valCJL8mjLO(esHTdLViNNnFU(e6GCRd0Pmb0JZchLwqgWaUazRBbn(oG6ciFHY05STnfAuA9pQeMa9beszGPw6trwJdujLi9CzQNWMqramQBGWquPiRXPt7AiJgaR6lCrDlOHUU67aQR77aQhnegILmsYAC6tif2ou(ICE2856tOdYToqNYeqpolCuAbzad4cKTUf047aQlG80OmDoBBtHgLwpHnHIayupfznoqLuI60UgYObWQ(cxu3cAORR(oG66(oG6rswJdujLO(esHTdLViNNnFU(e6GCRd0Pmb0JZchLwqgWaUazRBbn(oG6ciGUVdO(jH4XsYzz17ad4cMnwY2neqca]] )

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20170727.222840, [[dm0inaqiOkPfHQuBcvrgfPqNIuj7cvmmvLJPkTmsvpdvbttfKRrkW2qvOVbv14GQuohuLW6uvL5HQOUhPsTpuL0bLGfIQYdLqtKuqDrsPncvP6JQQQrQcQ6KeLMjQsCtjANq5NKcYqHQeTuuPNImvIQRQcQSvsfFvfuSxXFvHgmfhwQftKhlPjRsxgSzsrFwvmAvvonHxtumBuUnj7wPFdz4QilNQEovMUIRdv2oQQ(oufNxf16vbLMVkW(P05nYdH1kiejufTgTmqb70mR5)wjXe7ZFwZf0SXXMqAyqZghBcFH4cmODqW0)9I)h(V8ih98WHoK(dfIobvrZeh2EeOny65r9HkuhbADrEWEJ8qA3wIb3ifIQEXPj0GEEyaNkcXUi8SoRHNSgnAnt7FGHZpOzZpoNQJ1WZwJEnWAo4aRzekWA4vR5JJg89zn6kubjbtmNdjXqOldNBcj7Ef1Eq(qlAHqLORoThRvqOqyTccD4bps4uH4cmODqW0)9I)7xiUGdHZxbxKNjuXFqvMse)Gc2jsHkrxSwbHYem9rEiTBlXGB4lev9IttOb98WaoNqJaToRHNSgnAnveIDr4z5OPWdhbgOGDAghpOAX6SgE1A0J3(SMdoWAM2)adNrOGJd64vawdpRBRHh)SgDfQGKGjMZHoHgbAdj7Ef1Eq(qlAHqLORoThRvqOqyTccHxIgbAdXfyq7GGP)7f)3VqCbhcNVcUiptOI)GQmLi(bfStKcvIUyTccLjy8qKhs72sm4g(crvV40eAqppmGJyhW7XDACHkijyI5Ci8i27r3pO9HKDVIApiFOfTqOs0vN2J1kiuiSwbHomI9An0pO9H4cmODqW0)9I)7xiUGdHZxbxKNjuXFqvMse)Gc2jsHkrxSwbHYeSdf5H0UTedUHVqu1lonHKWPPMC8GdT9wHJdAafhpOAX6SgE2A0hQGKGjMZHg0aQJQ2nG)Ciz3RO2dYhArleQeD1P9yTccfcRvqi5Obuwtz7gWFoexGbTdcM(Vx8F)cXfCiC(k4I8mHk(dQYuI4huWorkuj6I1kiuMGPbrEiTBlXGB4lev9IttOb98WaoveIDr4zDHkijyI5CinfE4iWafStZcj7Ef1Eq(qlAHqLORoThRvqOqyTccH3fEWA0YafStZcXfyq7GGP)7f)3VqCbhcNVcUiptOI)GQmLi(bfStKcvIUyTccLjy8yKhs72sm4g(crvV40eAqppmGtfHyxeEwxOcscMyohYniV6iWafStZcj7Ef1Eq(qlAHqLORoThRvqOqyTccrdYRSgTmqb70SqCbg0oiy6)EX)9lexWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqzcg(rEiTBlXGB4lev9IttOb98WaoveIDr4zDHkijyI5CiGbkyNMDu1Ub8Ndj7Ef1Eq(qlAHqLORoThRvqOqyTccPLbkyNMznLTBa)5qCbg0oiy6)EX)9lexWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqzcgElYdPDBjgCdFHkijyI5CiCo4OyaLlKS7vu7b5dTOfcvIU60ESwbHcH1ki0HZbwJSdOCH4cmODqW0)9I)7xiUGdHZxbxKNjuXFqvMse)Gc2jsHkrxSwbHYem8IipK2TLyWn8fIQEXPj0GEEyaNkcXUi8SoRHNSgnAn4vRzAgSdN2vH92Bf4aBlXGR1CWbwJeon1Kt7QWE7TcCWDYAo4aRPIqSlcplN2vH92Bf44bvlwN1WRwJg8zn6kubjbtmNdjXqO7rnX5phs29kQ9G8Hw0cHkrxDApwRGqHWAfeIpgcDTg8oo)5qCbg0oiy6)EX)9lexWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqzc27xKhs72sm4g(crvV40eAqppmGtfHyxeEwN1WtwJgTg8Q1mnd2Ht7QWE7TcCGTLyW1Ao4aRrcNMAYPDvyV9wbo4ozn6kubjbtmNdjbEh4LrSpHKDVIApiFOfTqOs0vN2J1kiuiSwbH4d8oWlJyFcXfyq7GGP)7f)3VqCbhcNVcUiptOI)GQmLi(bfStKcvIUyTccLjyVVrEiTBlXGB4lev9IttOUoc(HJWckb4SgE1A0hQGKGjMZH842JDDeO9it4MqYUxrThKp0Iwiuj6Qt7XAfekewRGqCXTwtH6iqR1Wlc3eQG)XfABfOBEtcvrRrlduWonZA(VvsmX(8N1uqdPL3H4cmODqW0)9I)7xiUGdHZxbxKNjuXFqvMse)Gc2jsHkrxSwbHiHQO1OLbkyNMzn)3kjMyF(ZAkOH0MjyV6J8qA3wIb3WxiQ6fNMqtZGD40UkS3ERahyBjgCTMdoWAya)aZA4zR597lubjbtmNd5XTh76iq7rMWnHKDVIApiFOfTqOs0vN2J1kiuiSwbH4IBTMc1rGwRHxeUXA04RUcvW)4cTTc0nVjHQO1OLbkyNMzn)3kjMyF(ZACI9Hbwt7Q8oexGbTdcM(Vx8F)cXfCiC(k4I8mHk(dQYuI4huWorkuj6I1kiejufTgTmqb70mR5)wjXe7ZFwJtSpmWAAxntWE5HipK2TLyWn8fIQEXPj00myhoIkOjo)zoW2sm4gQGKGjMZH842JDDeO9it4MqYUxrThKp0Iwiuj6Qt7XAfekewRGqCXTwtH6iqR1Wlc3ynAuVUcvW)4cTTc0nVjHQO1OLbkyNMzn)3kjMyF(ZACI9HbwJqtEhIlWG2bbt)3l(VFH4coeoFfCrEMqf)bvzkr8dkyNifQeDXAfeIeQIwJwgOGDAM18FRKyI95pRXj2hgyncnZeS3df5H0UTedUHVqu1lonHMMb7WHjE(nRyFo6rxoW2sm4gQGKGjMZH842JDDeO9it4MqYUxrThKp0Iwiuj6Qt7XAfekewRGqCXTwtH6iqR1Wlc3ynAKh0vOc(hxOTvGU5njufTgTmqb70mR5)wjXe7ZFwJtSpmWAyEEhIlWG2bbt)3l(VFH4coeoFfCrEMqf)bvzkr8dkyNifQeDXAfeIeQIwJwgOGDAM18FRKyI95pRXj2hgynmFMmHOQxCAcLjba]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20170727.222840, [[daZwcaGEkPAxIK2gKWSL0njLBtyNuzVODt0(Lqdtj(TudfQkdwKA4s0bffhJuTqrLLQKwmjwov9qj4PGhdX6Genrkjnvk1KHY0fUOOQlR66IsBfQyZusz7qQ(iLeFgQYHv8CLAzIy0qsFJsCsOsptK40uCEsY0GuEnj1FHQQPoTj4gXjagrHIPZxV4YyQftBLrOuns8qzX0L(J0cLjiy1BTjBnyocRV(zF6sw0TSyrhfPMKcAOLGgbO8iMPAS(eMwsxcksiKbjmTCtB60PnH8YrPEmMJaG4nLbHOXdV6tTSdtl3eYOyQMqfHYomTKaUsmdYeTNGSLNGwJHZ4DJ4ei4gXjGVomTKW6RF2NUKfDl6lew)UZ6r(M2miua1JOwRr)IldQqqRXCJ4eyqxcTjKxok1JXCeYOyQMqfHOJlWVy2X9QiGReZGmr7jiB5jO1y4mE3iobcUrCc2DCrX0AZoUxfH1x)SpDjl6w0xiS(DN1J8nTzqOaQhrTwJ(fxguHGwJ5gXjWGUuOnH8YrPEmMJqgft1eQiSJ2lu)xEpbCLygKjApbzlpbTgdNX7gXjqWnItaI2lu)xEpH1x)SpDjl6w0xiS(DN1J8nTzqOaQhrTwJ(fxguHGwJ5gXjWGbbaXBkdcmiba]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20170727.222840, [[daK0raqiLGAtkHgfLuNIsYRikvmlIsL2fuzyiXXivlJs1ZufLPHKQUMQOY2ikLVPQY4ufvDoKuX6ikv18uvk3tvK9HKYbvvSqLOhIKmrKujxuvvBujiFejvQtsjAMkbUjv1oHYsjQEkQPIu2kLWEL(RsAWcDyflMipwKjRuxgSzOQptvgnPCAcVgPA2u52uSBe)gYWvfoUQs1Yj55IA6QCDvPTtP8DvLCEII1tuQY8jkz)cU6LwzSXaLzHHQq8Vdma5gxisDpgjNG4j7hIzbXZbHOtvM6cWpVURlllhCWKHIzNI(pk)0LnC2Fg1t92P(Y8dijgNq2BobIum7YM9YFsNarYLwX0lTY)jJKd2DzzoPepUYlCiEIeDbXleLLScXn6WH3ngynRHs0XPaZii5q8BpfIEPD5pscN4KPmE3yG1SgkrVSLKTinhsvMGiqzF02IrHngOCzSXaLxi3yGqK1qj6LLdoyYqXStr)NoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9kM9sR8FYi5GDxw(JKWjozkdoWaKBCRsUjFLTKSfP5qQYeebk7J2wmkSXaLlJngO8FhyaYnUqCPBYxz5GdMmum7u0)PtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVI9SsR8FYi5GDxwMtkXJRS0lE84GKgcYRi8RNgS6PG5wZVKnOeepCVpk)rs4eNmLHrDAF)DOdLTKSfP5qQYeebk7J2wmkSXaLlJngO8)rDAF)DOdLLdoyYqXStr)NoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9kg1xAL)tgjhS7YYCsjECLnd4YNczWLEvkGCHi1Eke11)fIYswH4chIJ6e4N0Hl)f4CcI3Qzax(uidoGmsoyhIlgIMbC5tHm4sVkfqUqKApfIuh7L)ijCItMYWOoT1SgkrVSLKTinhsvMGiqzF02IrHngOCzSXaL)pQtleznuIEz5GdMmum7u0)PtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVI9CLw5)KrYb7US8hjHtCYuoFiLHoapavzljBrAoKQmbrGY(OTfJcBmq5YyJbkZhszOdWdqvwo4GjdfZof9F6uklhYOxvcYLwVYuPbj6(iBGbixLk7J2yJbk3RyYwPv(pzKCWUll)rs4eNmLDIV)k2RMXZmRh6atzljBrAoKQmbrGY(OTfJcBmq5YyJbkVaX3Ff7q0F8mtisdDGPSCWbtgkMDk6)0PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxX(vAL)tgjhS7YYCsjECL3OdhE3yG1SgkrhNcmJGKdrQfIPjFRNWaH4IHycHCB0xKvfmPR8hjHtCYu2n2MvPxv(kBjzlsZHuLjicu2hTTyuyJbkxgBmq5fm2MqC5RkFLLdoyYqXStr)NoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9k2ZxAL)tgjhS7YYCsjECLToend4YNczWLEvkGCHi1EkeTtjexmeLEXJhh4adqUXTIhLEZ4EFeIwfIlgIwhIkaVcYAJKdcrRk)rs4eNmLX7gdSM1qj6LTKSfP5qQYeebk7J2wmkSXaLlJngO8c5gdeISgkrpeTw3QYFuE5Y3O8GBvG)jfGxbzTrYbLLdoyYqXStr)NoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9kg1P0k)Nmsoy3LL5Ks84kBgWLpfYGl9Qua5crQ9uiQRRhIYswH4chIJ6e4N0Hl)f4CcI3Qzax(uidoGmsoyhIlgIMbC5tHm4sVkfqUqKApfIpVSfIYswHi89xXJhWgx2GCBqjiERAWOUqCXqe((R4XdyJ70G1nKaHnqLxLCi0E9XKUqCXq0mGlFkKbx6vPaYfIule)rjexmeVXbKd3G)avwdLOJdiJKd2L)ijCItMYWOoT1SgkrVSLKTinhsvMGiqzF02IrHngOCzSXaL)pQtleznuIEiATUvLLdoyYqXStr)NoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9kMoLsR8FYi5GDxwMtkXJRS0lE84uqgrgscwp0bgCkWmcsoe)wiQtjeLLScrRdrPx84XPGmImKeSEOdm4uGzeKCi(Tq06qu6fpECtobK9qsaU9RAobIeIYoHycHCB0xeCtobK9qsaofygbjhIwfIlgIjeYTrFrWn5eq2djb4uGzeKCi(Tqu)5crRk)rs4eNmLp0bMvZKpqjtzljBrAoKQmbrGY(OTfJcBmq5YyJbktdDGje9N8bkzklhCWKHIzNI(pDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vmD9sR8FYi5GDxwMtkXJRS1HO0lE84EG(cuRi8RNgSAgWLpfYG79riUyioPtydwbcyeqoe)wi(Sq0QqCXq06qCdsV4XJZj80oIG4TQqBCB0xKq0QYFKeoXjtzNWt7icI3QeYDLTKSfP5qQYeebk7J2wmkSXaLlJngO8ceEAhrq8cXLi3v(JYlx(gLhCRc8pTbPx84X5eEAhrq8wvOnUn6lsz5GdMmum7u0)PtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVIPBV0k)Nmsoy3LL5Ks84kl9IhpUhOVa1kc)6PbRMbC5tHm4EFeIlgIt6e2GvGagbKdXVfIpR8hjHtCYu2j80oIG4TkHCxzljBrAoKQmbrGY(OTfJcBmq5YyJbkVaHN2reeVqCjYDHO16wvwo4GjdfZof9F6uklhYOxvcYLwVYuPbj6(iBGbixLk7J2yJbk3Ry6pR0k)Nmsoy3LL5Ks84kBDioPtydwbcyeqoePwiQhIlgIt6e2GvGagbKdrQfI6HOvH4IHO1H4gKEXJhNt4PDebXBvH242OViHOvL)ijCItMYjTrqwDcpTJiiELTKSfP5qQYeebk7J2wmkSXaLlJngOmvAJGeIlq4PDebXR8hLxU8nkp4wf4FAdsV4XJZj80oIG4TQqBCB0xKYYbhmzOy2PO)tNsz5qg9QsqU06vMknir3hzdma5QuzF0gBmq5EftN6lTY)jJKd2DzzoPepUYt6e2GvGagbKdrQfI6H4IH4KoHnyfiGra5qKAHOE5pscN4KPCsBeKvNWt7icIxzljBrAoKQmbrGY(OTfJcBmq5YyJbktL2iiH4ceEAhrq8crR1TQSCWbtgkMDk6)0PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxX0FUsR8FYi5GDxwMtkXJR8gKEXJhNt4PDebXBvH242OViL)ijCItMYoHN2reeVvjK7kBjzlsZHuLjicu2hTTyuyJbkxgBmq5fi80oIG4fIlrUleT2UvL)O8YLVr5b3Qa)tBq6fpECoHN2reeVvfAJBJ(Iuwo4GjdfZof9F6uklhYOxvcYLwVYuPbj6(iBGbixLk7J2yJbk3Ry6YwPv(pzKCWUll)rs4eNmLDcpTJiiERsi3v2sYwKMdPktqeOSpABXOWgduUm2yGYlq4PDebXlexICxiA9ZSQSCWbtgkMDk6)0PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxX0)vAL)tgjhS7YYCsjECLvaEfK1gjhu(JKWjozkJ3ngynRHs0ltLgKO7JSbgGCDzzF02IrHngOCzljBrAoKQmbrGYyJbkVqUXaHiRHs0drRTBv5pkVCzdYMG49KUS7nkp4wf4Fsb4vqwBKCqz5GdMmum7u0)PtPSCiJEvjixA9k7JSjiEftVSpAJngOCVIP)8Lw5)KrYb7US8hjHtCYugg1PTM1qj6LPsds09r2adqUUSSpABXOWgduUSLKTinhsvMGiqzSXaL)pQtleznuIEiATDRk)r5LlBq2eeVN0llhCWKHIzNI(pDkLLdz0Rkb5sRxzFKnbXRy6L9rBSXaL7vmDQtPv(pzKCWUll)rs4eNmLX7gdSM1qj6LPsds09r2adqUUSSpABXOWgduUSLKTinhsvMGiqzSXaLxi3yGqK1qj6HO1pZQYFuE5YgKnbX7j9YYbhmzOy2PO)tNsz5qg9QsqU06v2hztq8kMEzF0gBmq5E9kZjL4XvUxla]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20170727.222840, [[de0cuaqiuuSjLGrPK0PuQyvkjOxPKanlssvTlvvddfogjwgvXZqrQPrskxdfj2MsL8nLQgNscDouK06ijvzEkvQ7PeAFOO6GQkTqLOhIszIKKkUOQInIIOpssQ0jrPAMOO0nPQ2PQSuIQNImvuYwjj2R0FHsdwKdRyXe5XuzYq1LbBwP8zIYOPuNMIxdfZwOBtQDt43qgoj1Xvs0Yr1ZfmDvUoLSDQsFhfHZRKA9kjG5tsY(f1vPSk9gnuImA2YPprqdIBI5KQ7OLIgHmvVCkyeYIqoz2kP6aBJv86YsYHimbOppmu2ZyVYU(9W0QMQ5r1krQbNzIMvG5mirFE2LNsFDNbjcLvFkLvPpIrkc4DzjYXnQVsmtoDghgJqwoPkvLt4O7FloAaBWg5W8Zb9yeHCA3lMtYC4L(kzIMBDPT4ObSbBKdtj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXKXrd5ezJCykjhIWeG(8WqzVcJsYHaYI7Gqz1ReB2GdJpYlObXvPs(i83OHs96Ztzv6JyKIaExwICCJ6RKK122p4SrqalAd7zdyLXH5WgSe4a3iK9BPoNwiN0dedhhP)DwCoiUCI5lMtR4Uk9vYen36sWWp7vAnyGsSlWnU5q8scKak5JWvz4VrdLk9gnu6ZWp7vAnyGsYHimbOppmu2RWOKCiGS4oiuw9kXMn4W4J8cAqCvQKpc)nAOuV(y6YQ0hXifb8USe54g1xjjRTTFJd2S4R)TuNtlKt6bIHJJ0)olohexoX8fZjffLCAHCIzYjjRTT)j4ab(iCWVL6sFLmrZTU0ghfoSbBKdtj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXKCu4YjYg5WusoeHja95HHYEfgLKdbKf3bHYQxj2SbhgFKxqdIRsL8r4VrdL61NQvwL(igPiG3LL(kzIMBDjicAqCteRuCcxj2f4g3CiEjbsaL8r4Qm83OHsLEJgk9jcAqCtmNwgNWvsoeHja95HHYEfgLKdbKf3bHYQxj2SbhgFKxqdIRsL8r4VrdL61htPSk9rmsraVllroUr9vspqmCCK(3zX5G4YjMVyoPOSpNuLQYjMjNg(z2g39hycignczy1dedhhP)bXifb8CAHCspqmCCK(3zX5G4YjMVyoXu9u6RKjAU1LGHF2yd2ihMsSlWnU5q8scKak5JWvz4VrdLk9gnu6ZWp7CISromLKdrycqFEyOSxHrj5qazXDqOS6vInBWHXh5f0G4QujFe(B0qPE9TRYQ0hXifb8USe54g1xPsFLmrZTUu4qCngaud8sSlWnU5q8scKak5JWvz4VrdLk9gnuIoexJba1aVKCicta6ZddL9kmkjhcilUdcLvVsSzdom(iVGgexLk5JWFJgk1RV9LvPpIrkc4DzjYXnQVsRMt6bIHJJ0)olohexoT7fZjfgk50c50WpZ24U)ataXOridREGy44i9pigPiGNtQsv5eZKtd)mBJ7(dmbeJgHmS6bIHJJ0)GyKIaEoTqoPhigoos)7S4CqC50UxmN2VRCANCAHCIzYjjRTT)j4ab(iCWVL6sFLmrZTUKXbBw81LyxGBCZH4LeibuYhHRYWFJgkv6nAOe7oyZIVUKCicta6ZddL9kmkjhcilUdcLvVsSzdom(iVGgexLk5JWFJgk1RVvSSk9rmsraVllroUr9vQ0xjt0CRlfnR0YGJvpY0d2dDGUe7cCJBoeVKajGs(iCvg(B0qPsVrdLywZkTm45K)itp5el0b6sYHimbOppmu2RWOKCiGS4oiuw9kXMn4W4J8cAqCvQKpc)nAOuV(yQLvPpIrkc4DzjYXnQVsswBB)QrmbWXI2WE2aw9aXWXr6Fl150c5KK122F4qCngaud8Fl150c504oJxaliaTbc50UZjMU0xjt0CRlfnYSpHridRekELyxGBCZH4LeibuYhHRYWFJgkv6nAOeZAKzFcJqwoTefVsYHimbOppmu2RWOKCiGS4oiuw9kXMn4W4J8cAqCvQKpc)nAOuV(uyuwL(igPiG3LLih3O(kHJU)T4ObSbBKdZph0JreYjMNtUjCypJgYPfYjhcfXrmHalhg3v6RKjAU1LIJ3bRKfpCLyxGBCZH4LeibuYhHRYWFJgkv6nAOeZoENCAPfpCLKdrycqFEyOSxHrj5qazXDqOS6vInBWHXh5f0G4QujFe(B0qPE9POuwL(igPiG3LLih3O(kjzTT9BCWMfF9VL6CAHCA1CspqmCCK(3zX5G4YjMVyo5HroPkvLtswBB)ghSzXx)Zb9yeHCA350Q5KYptjNwH5uqneJyTNWb50kmNKS22(noyZIV(pCJdtoTcMtk50o50oL(kzIMBDPnokCyd2ihMsSlWnU5q8scKak5JWvz4VrdLk9gnuIj5OWLtKnYHjNwvzNsYHimbOppmu2RWOKCiGS4oiuw9kXMn4W4J8cAqCvQKpc)nAOuV(u8uwL(igPiG3LLih3O(kTAoPhigoos)7S4CqC5eZxmN8WiNwiNKS22(HiObXnrSBiNv43sDoTtoTqoTAoXHnoeShPiKt7u6RKjAU1L2IJgWgSromLyxGBCZH4LeibuYhHRYWFJgkv6nAOetghnKtKnYHjNwvzNsF5YcLUHldoSMTf5Wghc2JuekjhIWeG(8WqzVcJsYHaYI7Gqz1ReB2GdJpYlObXvPs(i83OHs96tHPlRsFeJueW7YsKJBuFLKS22(noyZIV(3sDPVsMO5wxAJJch2GnYHPeB2GdJpYlObX1LL8r4Qm83OHsLyxGBCZH4Leibu6nAOetYrHlNiBKdtoTQNDk9LllusJ8AeYwuPKCicta6ZddL9kmkjhcilUdcLvVs(iVgHS(uk5JWFJgk1RpfvRSk9rmsraVllroUr9vspqmCCK(3zX5G4YjMVyoPOOKtQsv5eZKtd)mBJ7(dmbeJgHmS6bIHJJ0)GyKIaEoTqoPhigoos)7S4CqC5eZxmNwXDLtQsv5eSslJA1a(FqJI4a3iKH1gg(LtlKtWkTmQvd4)NnGfhCGXlWdyLIieow1J7YPfYj9aXWXr6FNfNdIlNyEoTNroTqoDtee3)SDapyJCy(bXifb8sFLmrZTUem8ZgBWg5WuIDbUXnhIxsGeqjFeUkd)nAOuP3OHsFg(zNtKnYHjNwvzNsYHimbOppmu2RWOKCiGS4oiuw9kXMn4W4J8cAqCvQKpc)nAOuV(uykLvPpIrkc4DzjYXnQVsswBB)CiGeJWbyp0b6FoOhJiKt7oNuyu6RKjAU1Lo0bAS6jCaFDj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXcDGoN8NWb81LKdrycqFEyOSxHrj5qazXDqOS6vInBWHXh5f0G4QujFe(B0qPE9PSRYQ0hXifb8USe54g1xjjRTTFWzJGaw0g2ZgWkJdZHnyjWbUri73sDPVsMO5wxcg(zVsRbduIDbUXnhIxsGeqjFeUkd)nAOuP3OHsFg(zVsRbdKtRQStj5qeMa0Nhgk7vyusoeqwChekRELyZgCy8rEbniUkvYhH)gnuQxFk7lRsFeJueW7YsKJBuFLKS22(vJycGJfTH9SbS6bIHJJ0)wQZPfYPXDgVawqaAdeYPDNtmDPVsMO5wxkAKzFcJqgwju8kXUa34MdXljqcOKpcxLH)gnuQ0B0qjM1iZ(egHSCAjkE50Qk7usoeHja95HHYEfgLKdbKf3bHYQxj2SbhgFKxqdIRsL8r4VrdL61NYkwwL(igPiG3LLih3O(knUZ4fWccqBGqoX8CsjNwiNg3z8cybbOnqiNyEoPu6RKjAU1LC2JrGnAKzFcJqwj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXM9ye5eZAKzFcJqwj5qeMa0Nhgk7vyusoeqwChekRELyZgCy8rEbniUkvYhH)gnuQxFkm1YQ0hXifb8US0xjt0CRlfnYSpHridRekELyxGBCZH4LeibuYhHRYWFJgkv6nAOeZAKzFcJqwoTefVCAvp7usoeHja95HHYEfgLKdbKf3bHYQxj2SbhgFKxqdIRsL8r4VrdL61NhgLvPpIrkc4DzjYXnQVsCyJdb7rkcL(kzIMBDPT4ObSbBKdtj2SbhgFKxqdIRll5JWvz4VrdLkXUa34MdXljqcO0B0qjMmoAiNiBKdtoTQNDk9LllusJ8AeYwur1)gUm4WA2wKdBCiypsrOKCicta6ZddL9kmkjhcilUdcLvVs(iVgHS(uk5JWFJgk1RppkLvPpIrkc4DzPVsMO5wxcg(zJnyJCykXMn4W4J8cAqCDzjFeUkd)nAOuj2f4g3CiEjbsaLEJgk9z4NDor2ihMCAvp7u6lxwOKg51iKTOsj5qeMa0Nhgk7vyusoeqwChekREL8rEncz9PuYhH)gnuQxFE8uwL(igPiG3LL(kzIMBDPT4ObSbBKdtj2SbhgFKxqdIRll5JWvz4VrdLkXUa34MdXljqcO0B0qjMmoAiNiBKdtoTktVtPVCzHsAKxJq2IkLKdrycqFEyOSxHrj5qazXDqOS6vYh51iK1NsjFe(B0qPE9kroUr9vQxl]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20170727.222840, [[dae)jaqifjSjLsgLKcNIiPzjPOAxkIHPuDmsAzevptsPmnLsDnfj12qLW3uunojLOZjPiTojfX8uKY9qL0(uKOdkbluc9qLIjkPK6IkkBurs(OKs4KeHzsK4MKyNk8tjfLLIOEk0urWwrLAVI)Ikgmsomvlgv9yLmzP6YQ2SKQpljJwIonHxtuMnLUnP2nOFJYWjsDCfPA5u8CPmDGRJiBhH(oQeDEIO1lPKmFjLQ9Juh1qi4W1pik0BOPMzV(qGBPPQfUM3kGv1eAQc1SzbR1VUtYcsXGKV9E7ziFxD((CvUyI8AB7TLVDqu6VeUvuRCGGbZqoxipyHfqWGTqid1qi4mOZBFpfdwGxyfajd2amJw2V03eucyxSCaZeeYGpOcRZTBgU(bdoC9dIaMrl7x6Bcs(27TNH8D15Q7bj)gJKz9wieqWnLFjtHr86dbHpOcRpC9dgqgYdHGZGoV99umiUmcPbbbSQk7NSymBNXLWwWc8cRaizqVToS7W1dkbSlwoGzcczWhuH152ndx)GbhU(bl0wh2D46bjF792Zq(U6C19GKFJrYSEleci4MYVKPWiE9HGWhuH1hU(bdiJAlecod6823tXGf4fwbqYGwX0jj6C0EL25ayGRdkbSlwoGzcczWhuH152ndx)GbhU(bLIy6KeDAkfVs70ueyGRds(27TNH8D15Q7bj)gJKz9wieqWnLFjtHr86dbHpOcRpC9dgqgBhcbNbDE77PyqCzesdcwdAkFbeepNdVw8gn10OP2MMAlAkTFBdyy6jlsgZHaAQPKR0uY3PPKkn1w0u1GMY86M3kDE7PPKAWc8cRaizW6wxFoTs2swqjGDXYbmtqid(GkSo3Uz46hm4W1p4uzD9PPWs2swWcMQwqGBQoGJOoxnVU5TsN3(GKV9E7ziFxDU6EqYVXizwVfcbeCt5xYuyeV(qq4dQW6dx)GbKXuhcbNbDE77PyWc8cRaizW7gq50j5YEqjGDXYbmtqid(GkSo3Uz46hm4W1p4m3akNojx2ds(27TNH8D15Q7bj)gJKz9wieqWnLFjtHr86dbHpOcRpC9dgqgCrieCg05TVNIbXLriniyNbMu366ZPvYwYMyU2fWgn1ustT8gGdqOpn1w0u8KQxFI1j6CAKmvFcjPPP2IMAkOPaU9qWeROQeafWkogwFYHoV9DAQTOP8fqq8Co8AXB0utJMA7Gf4fwbqYGwNOZHNKPbckbSlwoGzcczWhuH152ndx)GbhU(bLIt0PPksY0abjF792Zq(U6C19GKFJrYSEleci4MYVKPWiE9HGWhuH1hU(bdiJ5HqWzqN3(EkgexgH0GGtbnfWThcMyfvLaOawXXW6to05TVttTfnLVacINZHxlEJMAA0utnnvTx70ua3EiyIvuvcGcyfhdRp5qN3(on1w0u(ciiEohET4nAQPrtTDWc8cRaizWBV(qGB5WB9giOeWUy5aMjiKbFqfwNB3mC9dgC46hCM96dbULMQO1BGGKV9E7ziFxDU6EqYVXizwVfcbeCt5xYuyeV(qq4dQW6dx)GbKrTmecod6823tXGf4fwbqYGwNOZH)UoOeWUy5aMjiKbFqfwNB3mC9dgC46hukorNMQ4DDqY3EV9mKVRoxDpi53yKmR3cHacUP8lzkmIxFii8bvy9HRFWaYOMgcbNbDE77PyqCzesdc2ppP61NyfvLaOawXXW6t6mUegSaVWkasgCv6cihROQeafWQGsa7ILdyMGqg8bvyDUDZW1pyWHRFWnLUastjfrvjakGvblyQAbbUP6aoI6CTFEs1RpXkQkbqbSIJH1N0zCjmi5BV3EgY3vNRUhK8BmsM1BHqab3u(LmfgXRpee(GkS(W1pyazOUhcbNbDE77PyWc8cRaizWvPlGCSIQsauaRckbSlwoGzcczWhuH152ndx)GbhU(b3u6cinLuevLaOawrtvdvPgK8T3Bpd57QZv3ds(ngjZ6TqiGGBk)sMcJ41hccFqfwF46hmGmuvdHGZGoV99umybEHvaKmO1j6C4jzAGGBk)sMcJ41hcsXGkSo3Uz46hmOeWUy5aMjiKbFWHRFqP4eDAQIKmnanvnuLAWcMQwqnJOawXv1GKV9E7ziFxDU6EqYVXizwVfcbeuHruaRYqnOcRpC9dgqgQYdHGZGoV99umiUmcPbbnVU5TsN3(Gf4fwbqYG1TU(CALSLSGBk)sMcJ41hcsXGkSo3Uz46hmOeWUy5aMjiKbFWHRFWPY66ttHLSLmAQAOk1GfmvTGAgrbSIRQ1CGBQoGJOoxnVU5TsN3(GKV9E7ziFxDU6EqYVXizwVfcbeuHruaRYqnOcRpC9dgqabXLriniyaja]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20170727.222840, [[da0otaqicH2ebmkvHoLQGxPkHmlvju7sknmOQJjWYKuEgsitJqW1qcQTHe4BqrJtvcohsqwhvQunpQu19Ku1(Ku5GQsTqvrpKanrQuPCrOWgPsfFKkvItsLYmvLOBkf7uvTuc1trnvcARes7v5VqLbtQdlAXi1JP0KLQld2mu6ZuHrljNMQEnsA2sCBs2nIFdz4ujhhjulNONl00v56cA7urFNq05rIwpvQKMVQK2pfVGjC8pvWy2Re0OXOakGCzXODxsfDXtC4UB0rpXrbm6mAh7UbyZWYTNJfdfiJW(1WhGjEmdOG2AuKiic1eHXSlW6ZI3DnppISFnkO2432ZJiXjC)GjCmgKKUa99CmBLEx34d5WrbATiuPJejjA0cy0pA0D01ITKkaxSczP2kbv6jrJUoJMoel22mAbspjwOThkZZJigTag9Jg95vGrxx9gnfG3OF9vJMoel2w6cc1lHXRn0Lr)GrlGrBrOshjssBjDM4OdLXRvcQ0tIgDDgnEJwaJwenA6qSyBJhsQOcGlq2g6YOFy8BAFXFuooJwG0tIfg7gP7T5HKJjicmUb1fnL)ubJh)tfm(D0cKEsSWyXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(1MWXyqs6c03ZXSv6DDJfrJ(8wQEIdJ(1xn6o6AXwsfGlwHSuBLGk9KOr7(6nAh2(430(I)OCm2sQaCXkKL6y3iDVnpKCmbrGXnOUOP8Nky84FQGXUtjvGrZvil1XIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9POjCmgKKUa99CmBLEx3yvcL4jrQwBOucKZORREJUgEJwaJwcQ0tIgT7R3OPdXITnJwG0tIfA7HY88iIrlGrBrOshjssBgTaPNel0kbv6jrJ(fz00HyX2Mrlq6jXcT9qzEEeXODF9gDpuMNhrg)M2x8hLJXwsfGlwHSuh7gP7T5HKJjicmUb1fnL)ubJh)tfm2DkPcmAUczPA0pg8WyXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(IWeogdssxG(Eo(nTV4pkhdfqbKll4Olz8g7gP7T5HKJjicmUb1fnL)ubJh)tfmgJcOaYLfJ(zjJ3yXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(u4jCmgKKUa99CmBLEx3y6qSyBbBfcI4qyXDvaohsipCXqshKEIJ2qxgTagTiA00HyX2Mrlq6jXcTHUmAbmAvcL4jrQwBOucKZORREJ(fOGXVP9f)r5yiLxffhMuHXUr6EBEi5ycIaJBqDrt5pvW4X)ubJXiLxffhMuHXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9PGjCmgKKUa99CmBLEx3yvcL4jrQwBOucKZORREJoiatJ(1xnAr0Ot55XM2RnksOu8eh4ujuINePAbssxGUrlGrRsOepjs1AdLsGCgDD1B0uOAJFt7l(JYXqkVkCXkKL6y3iDVnpKCmbrGXnOUOP8Nky84FQGXyKYRYO5kKL6yXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(yoHJXGK0fOVNJzR076gp(nTV4pkhhpKurfaxGCSBKU3MhsoMGiW4gux0u(tfmE8pvWy(qsfvaCbYXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9FHjCmgKKUa99CmBLEx34XVP9f)r54INId9DCQ0HkXDOduJDJ0928qYXeebg3G6IMYFQGXJ)Pcg)spfh67gDt6qLgTq0bQXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9Pqt4ymijDb675y2k9UUX0HyX26cjsqIdHf3vb4ujuINePAdDz0cy00HyX2gpKurfaxGSn0LrlGrN2Z7eWbeq5HOr7EJMIg)M2x8hLJlEhvhXtCGJgvUXUr6EBEi5ycIaJBqDrt5pvW4X)ubJFP3r1r8ehg9tu5glgkqgH9RHpaZa8JfdruO0cXjC3ybRal1gKtqbKB0JBq9FQGX72pa)eogdssxG(EoMTsVRBChDTylPcWfRqwQTsqLEs0ORZOTz8WDEfy0cy0pA0weQ0rIKGtcP9m6xF1OPdXITnJwG0tIfAdDz0pm(nTV4pkhxsNjo6qz8g7gP7T5HKJjicmUb1fnL)ubJh)tfm(LPZ0OFgkJ3yXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(bbt4ymijDb675y2k9UUXpA0QekXtIuT2qPeiNrxx9gDn8gTagnDiwSTqbua5YcoSiBySn0Lr)GrlGr)OrlbSsiwL0fWOFy8BAFXFuogBjvaUyfYsDSBKU3MhsoMGiW4gux0u(tfmE8pvWy3PKkWO5kKLQr)yThg)w6io(sPd4W5XwVeWkHyvsxGXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9dQnHJXGK0fOVNJzR076gRsOepjs1AdLsGCgDD1B0bbbg9RVA0IOrNYZJnTxBuKqP4joWPsOepjs1cKKUaDJwaJwLqjEsKQ1gkLa5m66Q3OFbkWOF9vJgO4qVlxqVnQqLoi9eh4QGuEgTagnqXHExUGE7vb46Gf8obzehDbH64CL2ZOfWOvjuINePATHsjqoJUoJgt8gTag9LfGCTj2dKXkKLAlqs6c0h)M2x8hLJHuEv4Ivil1XUr6EBEi5ycIaJBqDrt5pvW4X)ubJXiLxLrZvilvJ(XGhglgkqgH9RHpaZa8JfdruO0cXjC3ybRal1gKtqbKB0JBq9FQGX72pGIMWXyqs6c03ZXSv6DDJPdXITvcrejjwa3Hoq1kbv6jrJ29gDaEJ(1xn6hnA6qSyBLqersIfWDOduTsqLEs0ODVr)OrthIfBBgTaPNel02dL55reJ(fz0weQ0rIK0Mrlq6jXcTsqLEs0OFWOfWOTiuPJejPnJwG0tIfALGk9KOr7EJoGcB0pm(nTV4pkhFOdu4uz8ajLJDJ0928qYXeebg3G6IMYFQGXJ)PcgleDGYOBY4bskhlgkqgH9RHpaZa8JfdruO0cXjC3ybRal1gKtqbKB0JBq9FQGX72pqeMWXyqs6c03ZXSv6DDJt75Dc4acO8q0ORZOdmAbm60EENaoGakpen66m6GXVP9f)r54s6mXrdPASBKU3MhsoMGiW4gux0u(tfmE8pvW4xMotJ(jKQXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9dOWt4ymijDb675y2k9UUX0HyX26cjsqIdHf3vb4ujuINePAdDz0cy0P98obCabuEiA0U3OPOXVP9f)r54I3r1r8eh4OrLBSBKU3MhsoMGiW4gux0u(tfmE8pvW4x6DuDepXHr)evoJ(XGhglgkqgH9RHpaZa8JfdruO0cXjC3ybRal1gKtqbKB0JBq9FQGX72pGcMWXyqs6c03ZXSv6DDJt75Dc4acO8q0ORZOdmAbm60EENaoGakpen66m6GXVP9f)r5yBv6j4kEhvhXtCm2ns3BZdjhtqeyCdQlAk)Pcgp(NkySGvPNy0V07O6iEIJXIHcKry)A4dWma)yXqefkTqCc3nwWkWsTb5eua5g94gu)Nky8U9dWCchJbjPlqFph)M2x8hLJlEhvhXtCGJgvUXUr6EBEi5ycIaJBqDrt5pvW4X)ubJFP3r1r8ehg9tu5m6hR9WyXqbYiSFn8bygGFSyiIcLwioH7glyfyP2GCckGCJECdQ)tfmE3(bVWeogdssxG(EoMTsVRBSeWkHyvsxGXVP9f)r5ySLub4Ivil1XcwbwQniNGci3EoUb1fnL)ubJh7gP7T5HKJjicm(NkyS7usfy0CfYs1OFKIEy8BPJ4yfYPN4O(Gx8LshWHZJTEjGvcXQKUaJfdfiJW(1WhGza(XIHikuAH4eUBCdYPN4y)GXnO(pvW4D7hqHMWXyqs6c03ZXVP9f)r5yiLxfUyfYsDSGvGLAdYjOaYTNJBqDrt5pvW4XUr6EBEi5ycIaJ)PcgJrkVkJMRqwQg9J1Ey8BPJ4yfYPN4O(GXIHcKry)A4dWma)yXqefkTqCc3nUb50tCSFW4gu)Nky8U9RHFchJbjPlqFph)M2x8hLJXwsfGlwHSuhlyfyP2GCckGC754gux0u(tfmESBKU3MhsoMGiW4FQGXUtjvGrZvilvJ(rr4HXVLoIJviNEIJ6dglgkqgH9RHpaZa8JfdruO0cXjC34gKtpXX(bJBq9FQGX72nMTsVRB8Un]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170727.222840, [[diKanaqisuYIqjSjLumkuIofkQ2fu1WaPJbILru9muKAAkP01qrY2qrPVbLACOiY5qrG1bf18irX9usL9rIQdkjwir4HsstujvPlscBefrnsue0jjIMjkkUPsStq9tueAOkPQSuu4PitLiDvsuQTsu6RkPQAVI)kPmykDyflMKEmvnzL6YQ2mrXNrPgnu40eEnkPzJQBtQDd8Bidxs1YL45umDPUouz7qjFhkY5vswVsQI5tISFQCGePHwVxMbhVJeHGh9drcDvNvb)6d6HJzNDFzgC8oeJZ)yEGLdfc2qXgcZIxotV21kFTHiFruVdfQIVfiGjsdmKinKcWOY)oQHiFruVd1i2S5hVhH4BeMagNDnollD2EkSFJhJp8gd819TZQmoRCMYzvsjNTf67Sk3zHINPGc1zzEOkQcUOxfsLJqBoothssWw4NgvcbqGhAbTLDkWJ(Hcbp6hIj8fKWOdX48pMhy5qHGneOHyCdcxXFtKMouvmUN1fewxFqh1qlOn8OFO0bwEKgsbyu5Fhjcr(IOEhQrSzZp(6OwGagNDnollDwpcX3imbWlJO8ANF9b9WXxUEeaJZQCNvotcQZQKsoBpf2VX3c9R1OABXDwLzDolZc1zzEOkQcUOxfQoQfiqijbBHFAujeabEOf0w2Pap6hke8OFO1hQfiqigN)X8alhkeSHaneJBq4k(BI00HQIX9SUGW66d6OgAbTHh9dLoWmDKgsbyu5Fhjcr(IOEhQrSzZpEbOFPGREBcvrvWf9Qqysa21my8PessWw4NgvcbqGhAbTLDkWJ(Hcbp6hA9laBNLW4tjeJZ)yEGLdfc2qGgIXniCf)nrA6qvX4EwxqyD9bDudTG2WJ(Hsh41gPHuagv(3rIqKViQ3HuXjJm4l3GadW)AnQVgF56ramoRY4SYdvrvWf9QqnQVUMEm9lRcjjyl8tJkHaiWdTG2Yof4r)qHGh9djf1x7SlJPFzvigN)X8alhkeSHaneJBq4k(BI00HQIX9SUGW66d6OgAbTHh9dLoWmvKgsbyu5Fhjcr(IOEhQrSzZpEpcX3imbmHQOk4IEvizeLx78RpOhEijbBHFAujeabEOf0w2Pap6hke8OFiMSOCNvb)6d6HhIX5FmpWYHcbBiqdX4geUI)MinDOQyCpRliSU(GoQHwqB4r)qPdmZgPHuagv(3rIqKViQ3HAeB28J3Jq8nctatOkQcUOxfY0OIU25xFqp8qsc2c)0Osiac8qlOTStbE0pui4r)quJkANvb)6d6HhIX5FmpWYHcbBiqdX4geUI)MinDOQyCpRliSU(GoQHwqB4r)qPdm2rAifGrL)DKie5lI6DOgXMn)49ieFJWeWeQIQGl6vHo)6d6HxtpM(LvHKeSf(PrLqae4HwqBzNc8OFOqWJ(HuWV(GE4o7Yy6xwfIX5FmpWYHcbBiqdX4geUI)MinDOQyCpRliSU(GoQHwqB4r)qPdmtksdPamQ8VJeHQOk4IEviCMxt0xBcjjyl8tJkHaiWdTG2Yof4r)qHGh9dPSn3zLSV2eIX5FmpWYHcbBiqdX4geUI)MinDOQyCpRliSU(GoQHwqB4r)qPdmtqKgsbyu5Fhjcr(IOEhQrSzZpEpcX3imbmo7ACww6SklNTh(bn(X4pypa)XFWOY)2zvsjNvfNmYGFm(d2dWF84Q7SkPKZ6ri(gHja(X4pypa)XxUEeaJZQCNLPG6Smpufvbx0RcPYrODnzWvwfssWw4NgvcbqGhAbTLDkWJ(Hcbp6hscocTDwMmUYQqmo)J5bwouiydbAig3GWv83ePPdvfJ7zDbH11h0rn0cAdp6hkDGHansdPamQ8VJeHiFruVd1i2S5hVhH4BeMagNDnollDwLLZ2d)Gg)y8hShG)4pyu5F7SkPKZQItgzWpg)b7b4pEC1DwMhQIQGl6vHuFX8cRca7qsc2c)0Osiac8qlOTStbE0pui4r)qs8I5fwfa2HyC(hZdSCOqWgc0qmUbHR4VjsthQkg3Z6ccRRpOJAOf0gE0pu6adbsKgsbyu5Fhjcr(IOEhA8TaRx7GRf34Sk3zL7SRXzzPZo(wG1RDW1IBCwL7SYDwLuYzhFlW61o4AXnoRYDw5olZdvrvWf9QqfCGAJVfiqnUW0HKeSf(PrLqae4HwqBzNc8OFOqWJ(HyGd4Sv8TabCwMry6qvkSnHaJ(RJfKqx1zvWV(GE4y2zRWevWIqmo)J5bwouiydbAig3GWv83ePPdvfJ7zDbH11h0rn0cAdp6hIe6QoRc(1h0dhZoBfMOI0bgI8inKcWOY)oseI8fr9oup8dA8JXFWEa(J)GrL)TZQKsol)yDUZQmoleOqdvrvWf9QqfCGAJVfiqnUW0HKeSf(PrLqae4HwqBzNc8OFOqWJ(HyGd4Sv8TabCwMryANLLqyEOkf2MqGr)1XcsOR6Sk4xFqpCm7SgbGn)o7y8SieJZ)yEGLdfc2qGgIXniCf)nrA6qvX4EwxqyD9bDudTG2WJ(HiHUQZQGF9b9WXSZAea287SJXNoWqy6inKcWOY)oseI8fr9oup8dA8c)Lbxzf(dgv(3HQOk4IEvOcoqTX3ceOgxy6qsc2c)0Osiac8qlOTStbE0pui4r)qmWbC2k(wGaolZimTZYs5mpuLcBtiWO)6ybj0vDwf8RpOhoMDwJaWMFNvidlcX48pMhy5qHGneOHyCdcxXFtKMouvmUN1fewxFqh1qlOn8OFisOR6Sk4xFqpCm7SgbGn)oRqM0bgYAJ0qkaJk)7iriYxe17q9WpOXZfSXObca7Af0g)bJk)7qvufCrVkubhO24BbcuJlmDijbBHFAujeabEOf0w2Pap6hke8OFig4aoBfFlqaNLzeM2zzjtZ8qvkSnHaJ(RJfKqx1zvWV(GE4y2zncaB(DwEHfHyC(hZdSCOqWgc0qmUbHR4VjsthQkg3Z6ccRRpOJAOf0gE0pej0vDwf8RpOhoMDwJaWMFNLxsNoev)EXWfRNPfiqGLZSYtNaa]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170727.222840, [[d8sucaGErO2LiY2ernBP6MK03iHDsL9I2nH9drgMu63sgkujdgsA4sXbfPogPSqrXsHWIjvlNQEOOYtbpwPEUsMOiWuPKjdLPlCrrPNjsCDrvBfszZqLA7qQMguXYOuxw1HvmAiXTj6KquFwK0PP48qvVMe9xriRte0uJwesWX9KVhmdbO5BZ0njEctjOZozBciE)Z60z3QPOvHwYjzNco4yJdby7nnbbcP3HPelArNgTiKvm69JXmeGT30eeIk1u7pPMkmLyriTUPBc8eAQWuccilWm7jkpbrjob1cdTX7g5jqWnYtaxvykbbeV)zD6SB1uO1saXxvE)(lAXGqou(wPAH(LxeuNGAH5g5jWGoBAriRy07hJziKw30nbEcrfxMi5SI7XtazbMzpr5jikXjOwyOnE3ipbcUrEcwvCjsOQoR4E8eq8(N1PZUvtHwlbeFv597VOfdc5q5BLQf6xErqDcQfMBKNad6sHweYkg9(XygcP1nDtGNWkkVu5FZ9eqwGz2tuEcIsCcQfgAJ3nYtGGBKNaeLxQ8V5EciE)Z60z3QPqRLaIVQ8(9x0IbHCO8Ts1c9lViOob1cZnYtGbdcUrEcGrMdjuZ2V8Iy6jejuB8Fxs9jyqca]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170727.222840, [[deKisaqivrvBIsvJIuLtrQQvruQ0Rikv1SufL0TufLyxQkddjogLSmf4zuQ00ikLRPkQSnKe9nOKXbffNdkkToIsfZdkQUNQi7djPdcfwOQWdjkMOQOuxek1gvffNKuPzsPIBkODcvlLO6POMkszRKk2R0FvOblQdR0IjYJPQjROld2SQQplWOjLtt41ivZMk3MIDJ43qgUc64ijSCsEUqtxLRRkTDkLVdf58iPwprPkZNOK9lY1Q0kZELy4vU8Zg(3x31hL5HGxSoHS3EceP4dOYbLLdoyJqXhqXclkyzrLFdSRSjBdKTYYHDsnnHbkpr33VBnWyud5P)PaZkiXNf9MG07))3VBnWyud5P)nFv7jqezxkF2v)Yy4pbIelTIBvALXMSsoy2hLzVsm8k)8P8j80fKGuwwYkLNO773TgymQH80)uGzfKykJ5pLYb(zzmKeoXrD5F3AGXOgYtVSUKPWVhsvMGiq5q0uNvHVgOCz81aLFg3AGuM1qE6LLdoyJqXhqXcllkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7v8bLwzSjRKdM9rzmKeoXrDzWbgGCRBuYTXRSUKPWVhsvMGiq5q0uNvHVgOCz81aLX2bgGCRlLF424vwo4GncfFaflSSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXTBPvgBYk5GzFuM9kXWRS07))h41qqCe9pEAWyGc2Bm(sMGsqc(EhwgdjHtCuxgw1PrfVlDOSUKPWVhsvMGiq5q0uNvHVgOCz81aLXEvNgv8U0HYYbhSrO4dOyHLfLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kUSvALXMSsoy2hLzVsm8kBwWfpfY85FvkGCPmvFkLTSWkLLLSs5NpLx1j(x)9fXe4CcsWOzbx8uiZhqwjhmtz7tzZcU4PqMp)RsbKlLP6tPmMDqzmKeoXrDzyvN2yud5PxwxYu43dPktqeOCiAQZQWxduUm(AGYyVQtlLznKNEz5Gd2iu8buSWYIsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef)5kTYytwjhm7JYSxjgELlJHKWjoQlhpKYqhGHGQSUKPWVhsvMGiq5q0uNvHVgOCz81aL5dPm0byiOklhCWgHIpGIfwwuklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4uzPvgBYk5GzFuM9kXWRCzmKeoXrDzNGkEfZrZgy2XdDGPSUKPWVhsvMGiq5q0uNvHVgOCz81aLTJGkEfZuoCdmBktdDGPSCWbBek(akwyzrPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIJvPvgBYk5GzFuM9kXWR8eDF)U1aJrnKN(NcmRGetzQMY(nEJNWaPS9PShHCteMiJky9xzmKeoXrDz3ABhLEvXRSUKPWVhsvMGiq5q0uNvHVgOCz81aLTZABt5hVQ4vwo4GncfFaflSSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXXmLwzSjRKdM9rz2RedVY6LYMfCXtHmF(xLcixkt1Ns5busz7tzP3))pWbgGCRB8h5FJFVdtz9tz7tz9szf8RGO2k5Guw)YyijCIJ6Y)U1aJrnKNEzDjtHFpKQmbrGYHOPoRcFnq5Y4Rbk)mU1aPmRH80tz9S0VmgQGy5BvbWnk(Fsb)kiQTsoOSCWbBek(akwyzrPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIJzlTYytwjhm7JYSxjgELnl4INcz(8VkfqUuMQpLYwwwPSSKvk)8P8QoX)6VViMaNtqcgnl4INcz(aYk5GzkBFkBwWfpfY85FvkGCPmvFkLXmuzkllzLYav8kgoeMFrdYnbLGemQbR6sz7tzGkEfdhcZVtdgNGhe2avCuYHqZXHR)sz7tzZcU4PqMp)RsbKlLPAkJfLu2(u(whqUV9)avud5P)bKvYbZYyijCIJ6YWQoTXOgYtVSUKPWVhsvMGiq5q0uNvHVgOCz81aLXEvNwkZAip9uwpl9llhCWgHIpGIfwwuklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4wukTYytwjhm7JYSxjgELLE)))uqerwIhgp0bMpfywbjMYyEkBrjLLLSsz9szP3))pferKL4HXdDG5tbMvqIPmMNY6LYsV))FB0dK5s8W38vTNarszz)u2JqUjctKVn6bYCjE4tbMvqIPS(PS9PShHCteMiFB0dK5s8WNcmRGetzmpLTEUuw)YyijCIJ6Yh6aZOzJhOOUSUKPWVhsvMGiq5q0uNvHVgOCz81aLPHoWKYHB8af1LLdoyJqXhqXcllkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vClRsRm2KvYbZ(Om7vIHxz9szP3))VHimbQr0)4PbJMfCXtHmFVdtz7t51FcBWiqaJaIPmMNY2nL1pLTpL1lLNG07))NteODebjyuHMFteMiPS(LXqs4eh1LDIaTJiibJsi3vwxYu43dPktqeOCiAQZQWxduUm(AGY2reODebjiLFGCxzmubXY3QcGBu8)0eKE)))CIaTJiibJk08BIWePSCWbBek(akwyzrPSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIBnO0kJnzLCWSpkZELy4vw69))BictGAe9pEAWOzbx8uiZ37Wu2(uE9NWgmceWiGykJ5PSDlJHKWjoQl7ebAhrqcgLqURSUKPWVhsvMGiq5q0uNvHVgOCz81aLTJiq7icsqk)a5Uuwpl9llhCWgHIpGIfwwuklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4w2T0kJnzLCWSpkZELy4vwVuE9NWgmceWiGykt1u2kLTpLx)jSbJabmciMYunLTsz9tz7tz9s5ji9())5ebAhrqcgvO53eHjskRFzmKeoXrDzV2kiJorG2reKGY6sMc)EivzcIaLdrtDwf(AGYLXxduwgTvqsz7ic0oIGeugdvqS8TQa4gf)pnbP3))pNiq7icsWOcn)MimrklhCWgHIpGIfwwuklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4wYwPvgBYk5GzFuM9kXWR86pHnyeiGraXuMQPSvkBFkV(tydgbcyeqmLPAkBvgdjHtCux2RTcYOteODebjOSUKPWVhsvMGiq5q0uNvHVgOCz81aLLrBfKu2oIaTJiibPSEw6xwo4GncfFaflSSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXTEUsRm2KvYbZ(Om7vIHx5ji9())5ebAhrqcgvO53eHjszmKeoXrDzNiq7icsWOeYDL1Lmf(9qQYeebkhIM6Sk81aLlJVgOSDebAhrqcs5hi3LY6nq)YyOcILVvfa3O4)Pji9())5ebAhrqcgvO53eHjsz5Gd2iu8buSWYIsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef3IklTYytwjhm7JYyijCIJ6YorG2reKGrjK7kRlzk87HuLjicuoen1zv4RbkxgFnqz7ic0oIGeKYpqUlL1ZU6xwo4GncfFaflSSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXTWQ0kJnzLCWSpkZELy4vwb)kiQTsoOmgscN4OU8VBnWyud5PxwgnWtpezdma56JYHOPoRcFnq5Y6sMc)EivzcIaLXxdu(zCRbszwd5PNY6nq)YyOcILniBcsWtwpR3QcGBu8)Kc(vquBLCqz5Gd2iu8buSWYIsz5qe9Q8qS06voeztqckUv5q0eFnq5Ef3cZuALXMSsoy2hLXqs4eh1LHvDAJrnKNEzz0ap9qKnWaKRpkhIM6Sk81aLlRlzk87HuLjicugFnqzSx1PLYSgYtpL1BG(LXqfelBq2eKGNSklhCWgHIpGIfwwuklhIOxLhILwVYHiBcsqXTkhIM4Rbk3R4wy2sRm2KvYbZ(OmgscN4OU8VBnWyud5PxwgnWtpezdma56JYHOPoRcFnq5Y6sMc)EivzcIaLXxdu(zCRbszwd5PNY6zx9lJHkiw2GSjibpzvwo4GncfFaflSSOuwoerVkpelTELdr2eKGIBvoenXxduUxVY4RbkZcJmPm2oWaKBDYoPCuqcCqk7u9Ab]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170727.222840, [[de0ruaqiuuSjLGrPQWPuIAvOiLxPebnlsIu3sjc1UuQggkCmsSmb8mvfzAKe11qrQ2gkcFtvLXPerNJKiwNseY8qr09ucTpuuDqvvTqLIhIszIKejxuvPnIIKtIs1mrrPBkODQklLO8uKPIs2kjP9k9ximyroSIftKhtLjdPld2Ss6ZevJMsDAkEnenBHUnP2nHFd1WjPoUsKwoQEovnDvUoLSDb67QkQZRuA9krG5tsy)I6QuwLih3O(kvsLcwhR41nLi1GZmrZsWCgSOVamrGsYGimEOVamu(X4NctSh4tQSkhqLljdg0TSmAOek(2xJJgq4TXoK7CqpgHFj(duqYADDFnoAaH3g7qUJAXNZGfmng7FA5s)DNbl8LvFkLvPVIrkcODtjYXnQVsmtoDghsJqEoPcvKtO4BFnoAaH3g7qUZb9ye(CIjxmNK7ql9xYen32sRXrdi82yhYsSlqnU5W8scSakfIrvD4VrdLk9gnuIPIJgYjYg7qwsgeHXd9fGHYpfgLKbESf3b(YQxj2SbhYqCqqdIRsLcXOVrdL61xGYQ0xXifb0UPe54g1xjjR11DWzJbpc8kIZgqiNdZHWBjqbUriF3sDoTqoPhi6powV7S4CqC5eZxmNwsMO0Fjt0CBlbd)SxQ1GekXUa14MdZljWcOuigv1H)gnuQ0B0qPVd)SxQ1GekjdIW4H(cWq5NcJsYap2I7aFz1ReB2GdzioiObXvPsHy03OHs967tLvPVIrkcODtjYXnQVsswRR7ghSAX3UBPoNwiN0de9hhR3DwCoiUCI5lMtkkk50c5eZKtswRR7J3bc0r4GDl1L(lzIMBBPvo2Fi82yhYsSlqnU5W8scSakfIrvD4VrdLk9gnuIP4y)LtKn2HSKmicJh6ladLFkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIrFJgk1RpvUSk9vmsraTBk9xYen32sqe0G4MicP44VsSlqnU5W8scSakfIrvD4VrdLk9gnu6Be0G4MyoTjo(RKmicJh6ladLFkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIrFJgk1RpMEzv6RyKIaA3uICCJ6RKEGO)4y9UZIZbXLtmFXCsr5xoPcvKtmton8ZSoUB3)zignc5i0de9hhR3bXifb0CAHCspq0FCSE3zX5G4YjMVyoPscu6VKjAUTLGHF2i82yhYsSlqnU5W8scSakfIrvD4VrdLk9gnu67Wp7CISXoKLKbry8qFbyO8tHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6B0qPE9XeLvPVIrkcODtjYXnQVsL(lzIMBBj)H5AKaOg4LyxGACZH5LeybukeJQ6WFJgkv6nAOeDyUgjaQbEjzqegp0xagk)uyusg4XwCh4lRELyZgCidXbbniUkvkeJ(gnuQxF)kRsFfJueq7MsKJBuFL(iN0de9hhR3DwCoiUCIjxmNuyOKtlKtd)mRJ729FgIrJqoc9ar)XX6DqmsranNuHkYjMjNg(zwh3T7)meJgHCe6bI(JJ17GyKIaAoTqoPhi6powV7S4CqC5etUyo9JjYPLZPfYjMjNKSwx3hVdeOJWb7wQl9xYen32sghSAX3wIDbQXnhMxsGfqPqmQQd)nAOuP3OHsS7Gvl(2sYGimEOVamu(PWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9nAOuV(wYYQ0xXifb0UPe54g1xPs)LmrZTTu0Suldkc9ixpio8b6sSlqnU5W8scSakfIrvD4VrdLk9gnuIznl1YGMtHJC9KtSWhOljdIW4H(cWq5NcJsYap2I7aFz1ReB2GdzioiObXvPsHy03OHs96tLuwL(kgPiG2nLih3O(kjzTUURg)zGJaVI4Sbe6bI(JJ17wQZPfYjjR11D)H5AKaOg47wQZPfYPXDMGacqaAd4ZjMmN(uP)sMO52wkAKBFcJqocjC8kXUa14MdZljWcOuigv1H)gnuQ0B0qjM1i3(egH8CAdoELKbry8qFbyO8tHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6B0qPE9PWOSk9vmsraTBkroUr9vcfF7RXrdi82yhYDoOhJWNtmpNCJ)qCgnKtlKtomoII)Sabhg3v6VKjAUTLItWbHKf3FLyxGACZH5LeybukeJQ6WFJgkv6nAOeZobNCAJf3FLKbry8qFbyO8tHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6B0qPE9POuwL(kgPiG2nLih3O(kjzTUUBCWQfF7UL6CAHC6JCspq0FCSE3zX5G4YjMVyofGroPcvKtswRR7ghSAX3UZb9ye(CIjZPpYjLDMEoX0YjVAigryp(dYjMwojzTUUBCWQfF7U)ghYCAjmNuYPLZPLl9xYen32sRCS)q4TXoKLyxGACZH5LeybukeJQ6WFJgkv6nAOetXX(lNiBSdzo9HYYLKbry8qFbyO8tHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6B0qPE9PeOSk9vmsraTBkroUr9v6JCspq0FCSE3zX5G4YjMVyofGroTqojzTUUdrqdIBIiwXol)UL6CA5CAHC6JCIdRCWBpsriNwU0Fjt0CBlTghnGWBJDilXUa14MdZljWcOuigv1H)gnuQ0B0qjMkoAiNiBSdzo9HYYL(ZL7lDdxoCimRlYHvo4ThPiusgeHXd9fGHYpfgLKbESf3b(YQxj2SbhYqCqqdIRsLcXOVrdL61NYNkRsFfJueq7MsKJBuFLKSwx3noy1IVD3sDP)sMO52wALJ9hcVn2HSeB2GdzioiObX1nLcXOQo83OHsLyxGACZH5Leybu6nAOetXX(lNiBSdzo9rGLl9Nl3xsJdAeYxuPKmicJh6ladLFkmkjd8ylUd8LvVsH4GgH8(ukfIrFJgk1RpfvUSk9vmsraTBkroUr9vspq0FCSE3zX5G4YjMVyoPOOKtQqf5eZKtd)mRJ729FgIrJqoc9ar)XX6DqmsranNwiN0de9hhR3DwCoiUCI5lMtljtKtQqf5eSulJA1a6UxJJOa3iKJWgg(LtlKtWsTmQvdO7NnGafCGjiW9iKIymkc1J7YPfYj9ar)XX6DNfNdIlNyEo9JroTqoDtee3(SEa3BJDi3bXifb0s)LmrZTTem8ZgH3g7qwIDbQXnhMxsGfqPqmQQd)nAOuP3OHsFh(zNtKn2HmN(qz5sYGimEOVamu(PWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9nAOuV(uy6LvPVIrkcODtjYXnQVsswRR7CWJfJWbio8b6DoOhJWNtmzoPWO0Fjt0CBlD4d0i0J)a(2sSlqnU5W8scSakfIrvD4VrdLk9gnuIf(aDofo(d4BljdIW4H(cWq5NcJsYap2I7aFz1ReB2GdzioiObXvPsHy03OHs96tHjkRsFfJueq7MsKJBuFLKSwx3bNng8iWRioBaHComhcVLaf4gH8Dl1L(lzIMBBjy4N9sTgKqj2fOg3CyEjbwaLcXOQo83OHsLEJgk9D4N9sTgKqo9HYYLKbry8qFbyO8tHrjzGhBXDGVS6vInBWHmehe0G4QuPqm6B0qPE9P8RSk9vmsraTBkroUr9vsYADDxn(ZahbEfXzdi0de9hhR3TuNtlKtJ7mbbeGa0gWNtmzo9Ps)LmrZTTu0i3(egHCes44vIDbQXnhMxsGfqPqmQQd)nAOuP3OHsmRrU9jmc550gC8YPpuwUKmicJh6ladLFkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIrFJgk1RpLLSSk9vmsraTBkroUr9vACNjiGaeG2a(CI55KsoTqonUZeeqacqBaFoX8CsP0Fjt0CBl5ShJar0i3(egH8sSlqnU5W8scSakfIrvD4VrdLk9gnuIn7XiYjM1i3(egH8sYGimEOVamu(PWOKmWJT4oWxw9kXMn4qgIdcAqCvQuig9nAOuV(uujLvPVIrkcODtP)sMO52wkAKBFcJqocjC8kXUa14MdZljWcOuigv1H)gnuQ0B0qjM1i3(egH8CAdoE50hbwUKmicJh6ladLFkmkjd8ylUd8LvVsSzdoKH4GGgexLkfIrFJgk1RVamkRsFfJueq7MsKJBuFL4Wkh82Juek9xYen32sRXrdi82yhYsSzdoKH4GGgex3ukeJQ6WFJgkvIDbQXnhMxsGfqP3OHsmvC0qor2yhYC6Jalx6pxUVKgh0iKVOIk9nC5WHWSUihw5G3EKIqjzqegp0xagk)uyusg4XwCh4lRELcXbnc59PukeJ(gnuQxFbukRsFfJueq7Ms)LmrZTTem8ZgH3g7qwInBWHmehe0G46MsHyuvh(B0qPsSlqnU5W8scSak9gnu67Wp7CISXoK50hbwU0FUCFjnoOriFrLsYGimEOVamu(PWOKmWJT4oWxw9kfIdAeY7tPuig9nAOuV(ceOSk9vmsraTBk9xYen32sRXrdi82yhYsSzdoKH4GGgex3ukeJQ6WFJgkvIDbQXnhMxsGfqP3OHsmvC0qor2yhYC6JpTCP)C5(sACqJq(IkLKbry8qFbyO8tHrjzGhBXDGVS6vkeh0iK3NsPqm6B0qPE9k9gnuImA2YPVrqdIBIlr5K3iKhHCYS2Rfa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170727.222840, [[deeokaqijvytkLmkIOofrKvjrcZsIKCljs0UiQggeoMewgP0ZqrLPPuQRjPI2gkQ6BkfJtIu6CsKuRtIumpjv19ic2NKk5Gsulus5HkutuIu5IkKnIIcNKi1mjcDts1ov0pLivTuu4PitfI2krYEf)fsgmQ6WuTyu6XkzYs1LvTzsXNvWOLKtt41eLztPBtYUb9BOgUeXXLuLLtXZLY0bUUs12HuFhfLopkY6rrrZxsLA)OYPiidrlJOeqOqujFjCRGz6abgMPwMxBOs3147wqQfIXT3BptTik2GytbZlxlZT92A3oeJ7DMqkupuhdKRX6QJQvHxYKBUYfWwPuY9ZURrJCnwxDuTk8sM8(UXbcmSuGqoZjPqLxabg2cYmlcYqJGoR99uluzwHvaykudGnkz)LCtiPHDXYbytiig(q64UuUz6Qhk00vpebWgLS)sUjeJBV3EMAruSParigVH3nR3cYacnU6lz6y0xDiiSH0X9PREOaYuBqgAe0zTVNAHOLrucieapmyV8fgB7yMf2cvMvyfaMc5T1HDhUEiPHDXYbytiig(q64UuUz6Qhk00vpu526WUdxpeJBV3EMAruSParigVH3nR3cYacnU6lz6y0xDiiSH0X9PREOaYK5cYqJGoR99uluzwHvaykKvuVDrhLYhuokagCviPHDXYbytiig(q64UuUz6Qhk00vpKef1Bx05419bLZXJedUkeJBV3EMAruSParigVH3nR3cYacnU6lz6y0xDiiSH0X9PREOaYC7Gm0iOZAFp1crlJOeqijZX7lGa9rD4vI344Rph)2C8BXXR8BBadwjFTBmhc44RljWXRfbhVK443IJxYC8MRX8wLZAphVKcvMvyfaMcPX6QJQvHxYcjnSlwoaBcbXWhsh3LYntx9qHMU6HygwxDoEQcVKfQSzOfc4MHdqj0ibZ1yERYzTpeJBV3EMAruSParigVH3nR3cYacnU6lz6y0xDiiSH0X9PREOaYSodYqJGoR99uluzwHvayk0DdOQE7UShsAyxSCa2ecIHpKoUlLBMU6HcnD1dnYnGQ6T7YEig3EV9m1IOytbIqmEdVBwVfKbeAC1xY0XOV6qqydPJ7tx9qbKjZhKHgbDw77PwiAzeLac1Xa5ASU6OAv4Lm5MRCbSXXxxC8lVbqbeQZXVfhp7UgnYToAhvB3mC57LWXVfhFDWXdC7Ha5wXqfakGdOm4U8dDw77C8BXX7lGa9rD4vI344Rph)2HkZkScatHSoAhf7UPbcjnSlwoaBcbXWhsh3LYntx9qHMU6HKOJ254RTBAGqmU9E7zQfrXMceHy8gE3SElidi04QVKPJrF1HGWgsh3NU6HciZnbzOrqN1(EQfIwgrjGq1bhpWThcKBfdvaOaoGYG7Yp0zTVZXVfhVVac0h1HxjEJJV(C81jhFDx3C8a3EiqUvmubGc4akdUl)qN1(oh)wC8(ciqFuhEL4no(6ZXVDOYScRaWuOBV6qGBrXA9giK0WUy5aSjeedFiDCxk3mD1dfA6QhAK9QdbULJVM1BGqmU9E7zQfrXMceHy8gE3SElidi04QVKPJrF1HGWgsh3NU6HciZsBqgAe0zTVNAHkZkScatHSoAhf7DviPHDXYbytiig(q64UuUz6Qhk00vpKeD0ohFT7QqmU9E7zQfrXMceHy8gE3SElidi04QVKPJrF1HGWgsh3NU6HciZsDqgAe0zTVNAHOLruciu)S7A0i3kgQaqbCaLb3L3XmlmuzwHvayk0QYfquwXqfakGdHKg2flhGnHGy4dPJ7s5MPREOqtx9qJRCbKJxIIHkauahcv2m0cbCZWbOeAKq)S7A0i3kgQaqbCaLb3L3XmlmeJBV3EMAruSParigVH3nR3cYacnU6lz6y0xDiiSH0X9PREOaYSarqgAe0zTVNAHkZkScatHwvUaIYkgQaqbCiK0WUy5aSjeedFiDCxk3mD1dfA6QhACLlGC8sumubGc4ahVKlKuig3EV9m1IOytbIqmEdVBwVfKbeAC1xY0XOV6qqydPJ7tx9qbKzrrqgAe0zTVNAHkZkScatHSoAhf7UPbcnU6lz6y0xDii1cPJ7s5MPREOqsd7ILdWMqqm8HMU6HKOJ254RTBAaoEjxiPqLndTqkmAbCqcfHyC792ZulIInficX4n8Uz9wqgqiDmAbCiZIq64(0vpuazwOnidnc6S23tTq0YikbeYCnM3QCw7dvMvyfaMcPX6QJQvHxYcnU6lz6y0xDii1cPJ7s5MPREOqsd7ILdWMqqm8HMU6HygwxDoEQcVKXXl5cjfQSzOfsHrlGdsOOubCZWbOeAKG5AmVv5S2hIXT3BptTik2uGieJ3W7M1BbzaH0XOfWHmlcPJ7tx9qbeqOPREisOgZXpYE1Ha3wA44lx6hfqca]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170727.222840, [[daKxtaqicfTjKkJceCkqOxbsiZIQQuDlQQsAxsPHbvDmbwMKYZiuyAiHCnKGSnKaFdu14aj4Cib16OQkL5rvvDpjv2NKQoiOYcbrpePQjsvvIlcsTrQQItsvLzcs0nLIDcLLsipf1urkBLq1Ev(luzWK6WIwmbpMstwQUSQndkFMQy0sYPPYRrsZwIBtYUr8BidNQYXrc1Yj65cnDGRlOTtv67ekDEKO1dsOMpiP9tXly0gZwPZhy8y23TUS4GItGdrgwnkO2y)LdldlGb5yrV8m(HvdFa84HpGcARjguefvJIgl6zNsAo1hlVkDKO)QqimyTz0Espj232dLjWHiJHZcCisC0gwWOngAskuEFqoMTsNpWyaYJNYBTiuPJeljA00z0qWO7iqlSsQoUyfYsTvEv6irJUEJwiegS2mApPNe7B7HYe4qeJMoJgcgnWPUrxFDgnfG3OHkunAHqyWAfkiuVegbTH(mAiA00z0weQ0rIL0wsVjoHqze0kVkDKOrxVrJ3OPZOftJwiegS2iajvu)9DzBOpJgIJHtWvCakhNr7j9Ky)y)iDNnbi5ycI8XnOU4PelvF8ySu9XWfTN0tI9Jf9YZ4hwn8bWhGFSOhrHs7JJ2aJPV6wQniVxDcycJBqDSu9XdmSAJ2yOjPq59b5y2kD(aJftJg4SuDepgnuHQr3rGwyLuDCXkKLAR8Q0rIgT)RZO9y7JHtWvCakhdRKQJlwHSuh7hP7SjajhtqKpUb1fpLyP6JhJLQp2FkP6gnxHSuhl6LNXpSA4dGpa)yrpIcL2hhTbgtF1TuBqEV6eWeg3G6yP6JhyyIXOngAskuEFqoMTsNpWyv(seirQwBOuEcWORVoJUgEJMoJwEv6irJ2)1z0cHWG1Mr7j9KyFBpuMahIy00z0weQ0rIL0Mr7j9KyFR8Q0rIgnuKrlecdwBgTN0tI9T9qzcCiIr7)6m6EOmboezmCcUIdq5yyLuDCXkKL6y)iDNnbi5ycI8XnOU4PelvF8ySu9X(tjv3O5kKLQrdHaiow0lpJFy1WhaFa(XIEefkTpoAdmM(QBP2G8E1jGjmUb1Xs1hpWWOOrBm0KuO8(GCmCcUIdq54xU6eqwWjuYiySFKUZMaKCmbr(4gux8uILQpEmwQ(yOlxDcilgnKLmcgl6LNXpSA4dGpa)yrpIcL2hhTbgtF1TuBqEV6eWeg3G6yP6JhyyuOrBm0KuO8(GCmBLoFGXcHWG1EBf6rCiy4avhNh5taUyiPFPJ4Pn0NrtNrlMgTqimyTz0Espj23g6ZOPZOv5lrGePATHs5jaJU(6mAOafmgobxXbOC8tjOIIdtQFSFKUZMaKCmbr(4gux8uILQpEmwQ(yOtjOIIdtQFSOxEg)WQHpa(a8Jf9ikuAFC0gym9v3sTb59QtatyCdQJLQpEGHrbJ2yOjPq59b5y2kD(aJv5lrGePATHs5jaJU(6m6Ga4nAOcvJwmn6ucCWslOnk2xkoIhCQ8LiqIuTNKcL3nA6mAv(seirQwBOuEcWORVoJMcxBmCcUIdq54NsqfUyfYsDSFKUZMaKCmbr(4gux8uILQpEmwQ(yOtjOYO5kKL6yrV8m(HvdFa8b4hl6ruO0(4OnWy6RULAdY7vNaMW4guhlvF8add(rBm0KuO8(GCmBLoFGXJHtWvCakhhbiPI6VVlh7hP7SjajhtqKpUb1fpLyP6JhJLQpMbiPI6VVlhl6LNXpSA4dGpa)yrpIcL2hhTbgtF1TuBqEV6eWeg3G6yP6JhyyqHrBm0KuO8(GCmBLoFGXJHtWvCakhxCuCORJtLEujoacC1y)iDNnbi5ycI8XnOU4PelvF8ySu9XqPJIdDDJUj9OsJMgcC1yrV8m(HvdFa8b4hl6ruO0(4OnWy6RULAdY7vNaMW4guhlvF8adJcpAJHMKcL3hKJzR05dmwiegSwFiXEjoemCGQJtLVebsKQn0NrtNrlecdwBeGKkQ)(USn0NrtNrNwGZ7XDYvUhnA)B0IXy4eCfhGYXfNNkaXr8GtavaJ9J0D2eGKJjiYh3G6INsSu9XJXs1hdLopvaIJ4XOHevaJf9YZ4hwn8bWhGFSOhrHs7JJ2aJPV6wQniVxDcycJBqDSu9XdmSa8J2yOjPq59b5y2kD(aJ7iqlSsQoUyfYsTvEv6irJUEJ2MraoGtDJMoJgcgTfHkDKyj4KpTaJgQq1OfcHbRnJ2t6jX(2qFgnehdNGR4auoUKEtCcHYiySFKUZMaKCmbr(4gux8uILQpEmwQ(yOm9MgnKHYiySOxEg)WQHpa(a8Jf9ikuAFC0gym9v3sTb59QtatyCdQJLQpEGHfemAJHMKcL3hKJzR05dmgcgTkFjcKivRnukpby01xNrxdVrtNrlecdw7lxDcil4GHSHX2qFgnenA6mAiy0Ydt(yvkuUrdXXWj4koaLJHvs1XfRqwQJ9J0D2eGKJjiYh3G6INsSu9XJXs1h7pLuDJMRqwQgneQbXXWj9ehdsPNdW5GvN8WKpwLcLpw0lpJFy1WhaFa(XIEefkTpoAdmM(QBP2G8E1jGjmUb1Xs1hpWWcQnAJHMKcL3hKJzR05dmwLVebsKQ1gkLNam66RZOdccmAOcvJwmn6ucCWslOnk2xkoIhCQ8LiqIuTNKcL3nA6mAv(seirQwBOuEcWORVoJgkqbgnuHQrFko05Z37TrfQ0V0r8GR6Pey00z0NIdD(89ElO6463EN3lJ4ekiuhNV0cmA6mAv(seirQwBOuEcWOR3OHhVrtNrdYYjG2eg4YyfYsT9KuO8(y4eCfhGYXpLGkCXkKL6y)iDNnbi5ycI8XnOU4PelvF8ySu9XqNsqLrZvilvJgcbqCSOxEg)WQHpa(a8Jf9ikuAFC0gym9v3sTb59QtatyCdQJLQpEGHfigJ2yOjPq59b5y2kD(aJfcHbRv(iIKe7XbqGRALxLos0O9VrhG3OHkunAiy0cHWG1kFersI94aiWvTYRshjA0(3OHGrlecdwBgTN0tI9T9qzcCiIrdfz0weQ0rIL0Mr7j9KyFR8Q0rIgnenA6mAlcv6iXsAZO9KEsSVvEv6irJ2)gDafYOH4y4eCfhGYXae4kCQmcUKYX(r6oBcqYXee5JBqDXtjwQ(4XyP6JPHaxz0nzeCjLJf9YZ4hwn8bWhGFSOhrHs7JJ2aJPV6wQniVxDcycJBqDSu9XdmSakA0gdnjfkVpihZwPZhyCAboVh3jx5E0OR3OdmA6m60cCEpUtUY9OrxVrhmgobxXbOCCj9M4eEQg7hP7SjajhtqKpUb1fpLyP6JhJLQpgktVPrd5t1yrV8m(HvdFa8b4hl6ruO0(4OnWy6RULAdY7vNaMW4guhlvF8adlGcnAJHMKcL3hKJzR05dmwiegSwFiXEjoemCGQJtLVebsKQn0NrtNrNwGZ7XDYvUhnA)B0IXy4eCfhGYXfNNkaXr8GtavaJ9J0D2eGKJjiYh3G6INsSu9XJXs1hdLopvaIJ4XOHevagnecG4yrV8m(HvdFa8b4hl6ruO0(4OnWy6RULAdY7vNaMW4guhlvF8adlGcgTXqtsHY7dYXSv68bgNwGZ7XDYvUhn66n6aJMoJoTaN3J7KRCpA01B0bJHtWvCakhBRshbxX5PcqCepJ9J0D2eGKJjiYh3G6INsSu9XJXs1htFv6ignu68ubioINXIE5z8dRg(a4dWpw0JOqP9XrBGX0xDl1gK3RobmHXnOowQ(4bgwa8J2yOjPq59b5y4eCfhGYXfNNkaXr8GtavaJ9J0D2eGKJjiYh3G6INsSu9XJXs1hdLopvaIJ4XOHevagneQbXXIE5z8dRg(a4dWpw0JOqP9XrBGX0xDl1gK3RobmHXnOowQ(4bgwauy0gdnjfkVpihZwPZhyS8WKpwLcLpgobxXbOCmSsQoUyfYsDm9v3sTb59QtadYXnOU4PelvF8y)iDNnbi5ycI8XyP6J9NsQUrZvilvJgcIbehdN0tCSc51r8uxG)oiLEoaNdwDYdt(yvku(yrV8m(HvdFa8b4hl6ruO0(4OnW4gKxhXZWcg3G6yP6Jhyybu4rBm0KuO8(GCmCcUIdq54NsqfUyfYsDm9v3sTb59QtadYXnOU4PelvF8y)iDNnbi5ycI8XyP6JHoLGkJMRqwQgneQbXXWj9ehRqEDep1fmw0lpJFy1WhaFa(XIEefkTpoAdmUb51r8mSGXnOowQ(4bgwn8J2yOjPq59b5y4eCfhGYXWkP64Ivil1X0xDl1gK3Robmih3G6INsSu9XJ9J0D2eGKJjiYhJLQp2FkP6gnxHSunAiqrqCmCspXXkKxhXtDbJf9YZ4hwn8bWhGFSOhrHs7JJ2aJBqEDepdlyCdQJLQpEGbgJLQpMDk6nAOlxDcil(BgD0r8uUrNr7aB]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20170727.222840, [[d4Y9baGEcQ2ecQDHGSnIOzl5Mej3gPDc0Ef7wP9dyyQWVvvdwLgor5GkIJrIfIalLalMqlhupeHEk0YiPNRktKGyQQOjJOPt1fvOlJ66KQnROSDcsFKi1NjLdt5BevRtr1ZuqDsfKPPiDAPopr4VkWJb5qeuok5miOr5GytjcChlMYRB1CG7ZTL0GjbUc9bC1mQy1RwqHWZm9YdbbfWfBpoGQhkYpKRijHuhE6u1PbrzmuBvlCZ7)gqvjvdobY7)(YzavYzWX1elMmeeeHGBzEqnJkw9QryhwNdcAuoi2uIa3XIP86wbCL2OIvVAbfWVVome)Yz8Gte7QDjccRVdmiV)7GQFEWHwYgY8pCW9VCqbCX2JdO6HICLJGs9jbnkheBkrG7yXuEDRaUsBuXQxT5axsEMPxE8aQMZGJRjwmziiicb3Y8GctZOIvVAbbnkheBkrG7yXuEDRckGFFDyi(LZ4bNi2v7seewFhyqE)3bv)8GdTKnK5F4G7F5Gc4IThhq1df5khbL6tcAuoi2uIa3XIP86wnh4sYZm9YJhpicb3Y8GXta]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170622.212605, [[d8tCiaqyQwVQQEjPQSlsvKTHc63qntvvwgLQztY5vu3efYPr13Ou45IStf2R0UjSFH6NqyycmosvuVwvPgkrnyrz4q6GkYrjvjDmk5CKQeluvSuuulwqlNIhQQ4PGhJuRtvjmruOMkctMiMUkxeLUkLIUSsxhjBuu1wvvI2Sq2or6JIk9ziAAOaFxvAKKQQNrP0OjLXJICssLBPQKUgPk19ivHUnIwlPk44IkUwLOaTJECSipwCWnR2ciSjXpDd2cNBqUNSu5gwW4cK7hTL(7(uihQLANuCKcYvCfOlmJikkT3hh94yrQJGcmHikkT3hh94yrQJGc5qTuReD0ybW)VDWGGcjn87eLX1jIWnSqoul1k5JJECSi1NcZiIIs7r4gK7L6iOGELAP2uj6WQefyfEOAL0Nct0hhlIZ(XtxbG9xCgRAjxX5Q4mzZsJjd9RWWj3ca7V4mw1sUIZvXzYMLgtg6xbMx16PTd7bwm0kiW2caTHJEfoo5Qhd61H9suGv4HQvsFkmrFCSio7hpDfa2FXzSQLCfNRIZy8g5uQRWWj3ca7V4mw1sUIZvXzmEJCk1vG5vTEA7WEGfdTccSTaqB4OxHE9kK0WVWl)O1My7tHKg(DI6W9Pqsd)cV8JwBI6W9PW5gK7njO1WMcpiiiqWiM1LR(jkm38FvphOxSZGagAzzdBdSB3gbn6RmqVleHfxHjd3vXzd3yWVfsA4xc3GCVuFk8D4KGwdBkqGqMzD5QFIcCHeoTFyZKGwdBkWSUC1prbAh94yXKGwdBk8GGGabJkaOln3v8)(XXIoSZq7fsA4xGOpfYHAPwgZnl9XXIcmRlx9tuqqrQJglsDWGcj0vPYR8K2hScBkrbVdRcHDyvazhwfmDy1Rqsd)(XrpowK6tbMqefL2BIY4DeuqYg5uQBs(xbGt(joJvTKR4C1xeNLoxiXnsIZKMIZq6KHkUazbsNPjQd3rqHqf)))Cv43jLQHfCfQMdA4xzPSDyvWvOA(hmzOFYsz7WQajxmrD4ockW4nYPuxFk4QxFojlvUpfKYt8qUIFZeZOBbVaTJECSysXrkk8HDqWYCbj8eQYNjMr3cEbxHQ5tQxFojlLTdRcgxGCjMr3cEixXV5coLXzexS9PGRq1Cqd)klvUdRcFhMhloG)F7WYEHzerrP903tQJVAvWvOAoHBqUNSu5oSkWeIOO0E67j1HvbZQk8HDqWYCHe6Qu5vEsRHfCfQMt4gK7jlLTdRcoLXNe0AytHheeeiy0p28efYHAPwj6es40(HnP(uWPmUoreMygDlesffvGjerrP9iCdY9sDeu4CdY9YJfhCZQTacBs8t3GTaJCM4KuKXzeCYTdBdkqYftSDyBbG2WrVcfCfQMpPE95KSu5oSkqJjd9twkBdlGA4KUzopwCa))2HL9cOMLgtg63K8VcaN8tCgRAjxX5QViod1S0yYq)k8bJohNrGlWQwYvCUkoBcbBbsNPj2ockq4QvCXz5AWuODeu4CdY9KLY2WcZiIIs7PtiHt7h2K6iOqsd)QVDoKlKWfit9PWmIOO0EtugVJGcmHikkTNoHeoTFytQJGcFhMhlUcYeXzGlsXzd3yWVfCkJtmJUfcPIIk4ughqxLshJ7iOqsd)QtiHt7h2K6tbsNjGOdRcU61NtYsz7tbzdN0nZXzFC0JJfXztugVqHKg(vwkBFkqJjd9twQCdlCUb5E5XIRGmrCg4IuC2Wng8BbonwaOonxGSd9UW3H5XIdUz1waHnj(PBWwGKlaIockCUb5E5XId4)3oSSxiPHFNy7tbAh94yrES4kiteNbUifNnCJb)wWvOA(hmzOFYsL7WQaRWdvRK(uiXjrv7ec2oSxihko93Fjpb3SAl4fgo5wGvTKR4CvCMSHt6M5cmVQ1tBh2dSSradTSvpz3YwllBuiPHFLLk3Nc0o6XXI8yXb8)Bhw2liB4KUzoo7JJECSOW5gK7LkeQ4))NRc)2WcOgoPBM1rJfa))2bdckWPXc9agt2HTbfYHAPwj5XId4)3oSSxGPockKd1sTs03tQpfsA4x4LF0Atiy7tbNY42uWVcOkFEn9Ab]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170622.212605, [[d8ZpiaqyrRxvLxsfYUikPxRq52OYmrunoIs1SP48kYnreonkFtvv5YkTtQAVs7MW(vf)ecdJu9BOEUGHssdwrnCeoOcokrj6yc15Oc0cvvwkrXIjYYP0dvipfSmQO1ruktKkutfstgv10v5IK4QuPYZquUosTrQKTQQQYMfY2rv(OcvFgIMgIOVRknsQG2MQQmAsz8isNKO6wubCnQu19uvv1JrYAjkHJtLYnUOfOsIJHfUWIdUjZwaH7qjxUxPWLwK7PYtTsfSPa5osBPgRFfKmSF)g3GFRuHjerrH9gLehdlc1RxGuerrH9gLehdlc1RxWn6LE5lNcla2VTEsQxiOHFhOTPCreUsfCJEPx(JsIJHfH(vycruuyp00ICVq96fKL0l9gkA9XfTGIiLml)(vyG6yyXZm5SWvVSxWNCBbqH8NzfZYTIlnpZQ2LcZjLxbzwZMHTEN6X)fRRtwbGYYiUchJB)F9E17SOfuePKz53VcduhdlEMjNfU6)RGp52cGc5pZkMLBfxAEMD8gL0MRGmRzZWwVt94)I11jtwJlauwgXvOxVcbn8l8YokTbLkviOHFhOpCLkWOWcGiPycK17(cxArU3GGsdBl8HaffbjKr(4oeTaPiIIc75OVq96fiTE9cbn8lAArUxOFfgtAqqPHTfqrOkJ8XDiAbMGpJkpSDqqPHTfKr(4oeTavsCmSyqqPHTf(qGIIGefaILILg2V8yyr9o)ZzHGg(fq7xb3Ox61Xm7sDmSOGmYh3HOfe0CYPWIq9KSqGyngxMmOncBW2IwiRpUGT(4ciRpUGu9X9ke0WVJsIJHfH(vGuerrH9gOTz96f4VrjT5gujVaW4g9mRywUvCPr2EMdxk4Nw(pZ8cpZitojdtGSaxs6a9HRxVqAi0YbZBofu5PuFCH0qOLGg(vLNs9XfsdHwocZjLNkpL6JlWXed0hUENfsZBofu5P2Vc8ybMeZWUj0jITGubQK4yyXGHHuuyKIhvrMc8zbctoHorSfOkizy)(nUb)oymvQGnfix0jITqkXmSBQqsBtsWeB)kmHikkSNJ(c1RxymjxyXbSFB9XolK02CqqPHTf(qGIIGeKR4cTqAi0s00ICpvEQ1hxiPTPCregDIylirhfvWUMcJu8OkYuiqSgJltg0QuH0qOLOPf5EQ8uQpUWuD5a)5EDhmw3bj7FKrMojLDY0BKdqs3xWn6LE5lxWNrLh2g6xbgfwilWyU6jtVaPiIIc7HMwK7fQxVWLwK75clo4MmBbeUdLC5ELcKijLXrZ9mJY426jtVahtmOuVZcaLLrCfcmbsZwineA5G5nNcQ8uRpUGB0l9oyyifCR4kqvGWY4s7KlS4a2VT(yNfiSlfMtkVbvYlamUrpZkMLBfxAKTNzc7sH5KYRafMtkpvEkvQaxs6Gs96fqtZkUN5XTyAI61lCPf5EQ8uQuHryIPNzuCbfZYTIlnpZdiuke0WVoANKyc(mbYq)kmHikkSNCbFgvEyBOE9ctiIIc7nqBZ61lqkIOOWEYf8zu5HTH61l4gnJAS)JfGBYSfKkK02eDIylirhfviOHFLl4ZOYdBd9RqsBtGyng5oUE9cP5nNcQ8u6xHGg(vLNs)ke0WVdkvQafMtkpvEQvQGQLXL2PN5rjXXWIN5bABwWLj52NzqdtnwHlTi3ZfwCfurFMHueEM9P1IFlmMKlS4GBYSfq4ouYL7vkWXeaA9olCPf5EUWIdy)26JDwiOHFHx2rPnqF4(vGkjogw4clUcQOpZqkcpZ(0AXVfsdHwocZjLNkp16JlOisjZYVFfcmocZoGqPENfgtYfwCfurFMHueEM9P1IFl4tUTGIz5wXLMN5bekf4ssb061lOAzCPD6zEusCmSOGnpgUqqd)QYtTFfOsIJHfUWIdy)26JDwqM1SzyR3PE8)0)lMmz1zmzXX)RaHLXL2j5uybW(T1ts9cPHqlbn8Rkp16Jl4g9sV8DHfhW(T1h7SqewCfgSS08m7tRf)wWn6LE57OVq)k44nkPnx)kK020Dc2vGWKtRTxla]] )


end
