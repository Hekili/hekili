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
        addAura( 'static_overload', 191634, 'duration', 15 )
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

        --[[ ns.addSetting( 'st_fury', false, {
            name = "Enhancement: Single-Target Fury",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not recommend Fury of Air when there is only one enemy.  It will still budget and pool Maelstrom for Fury of Air (if talented accordingly), in case of AOE.\n\n" ..
                "If you are wearing the Smoldering Heart legendary, you will want to set this to |cFF00FF00true|r so that Fury of Air will help proc Ascendance.  Otherwise, simulations for 7.2.5 suggest that Fury of Air is slightly DPS negative in single-target, meaning there is a small DPS loss from using it in single-target.",
            width = "full",
        } ) ]]

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

        --[[ ns.addSetting( 'crash_st', false, {
            name = "Enhancement: Low Priority Single-Target Crash Lightning",
            type = "toggle",
            desc = "If |cFF00Ff00true|r, a very low-priority Crash Lightning will be enabled when almost no other actions are available (in the default Enhancement action lists).  It is technically a very marginal " ..
                "DPS increase to enable this setting, but many users were confused by the Crash Lightning recommendation for single-target.",
            width = "full",
        } ) ]]

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
            local overload = floor( ( buff.static_overload.up or ( settings.optimistic_overload and stat.mastery_value > 0.50 ) ) and ( 0.75 * max( 5, active_enemies ) * 6 ) or 0 )
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
            applyDebuff( 'target', 'flame_shock', min( class.auras.flame_shock.duration * 0.3, debuff.flame_shock.remains ) + 15 + ( 15 * ( cost / 20 ) ) )

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
            -- usable = function () return active_enemies > 1 or settings.st_fury end,
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
                local overload = ( buff.static_overload.up or ( settings.optimistic_overload and stat.mastery_value > 50 ) ) and 6 or 0
                return -1 * ( 8 + ( overload ) + ( buff.power_of_the_maelstrom.up and 6 or 0 ) )
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
            if artifact.static_overload.enabled then applyBuff( 'static_overload', 15 ) end
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170828.180304, [[dmunyaqiPqlsG0MeqJIOCkI0SeOAxKyyG4yiYYevEMarttGY1eG2griFtrACsbDofHADcG5jq4EiQ2hrWbffluuvpeLAIkcXfLsDsrvMPIOUjkzNK0pvePHQiILkr9uQMQe5QeHYwru(krOAVq)vrnyHomLfJWJvyYG6YQ2SG(Su0OLWPj1QvesETuYSr1TL0Ub(nHHdshxkWYr65s10v66Oy7evFxrW5fLwVIqQ5teTFrgjHLqFI8qJHVy(ORA1JURRStX2GcdmE9GnaPi8dng(IE5ZV1pQMdcPPqMMBQsUC5AyWq3hun0fD0ZmwTa0XsOkjSe6Tbgb)Wy(O7dQg6I(kA2KFfnypLYaD7ONHqZ1Bw0NGgap3lUrrppaSEyRGIoqao6SeWKzuvRE0rx1QhDjUgaNIEXnk6Lp)w)OAoiKMscc6LFxWqhVJLWfD2fF0ILq(RhSib6SeWQw9OJlQMdlHEBGrWpmMp6(GQHUOllfLLIRXpyvkmnVVcAv5aJGF4umWuSXuKGjmujKk6lb1aWkmqtrPPOKsMInMIRXpyvkmnVVcAv5aJGF4uuk6zi0C9MfD5gvBe8JEEay9WwbfDGaC0zjGjZOQw9OxyAEFf0k7IpAHUQvp6(kOpfjZ4mh9m0MD0bw9KxyAEFf0k7IpAfC5gN5Klt2A8dwLctZ7RGwvoWi4hoWgjycdvcPI(sqnaScduPskzJRXpyvkmnVVcAv5aJGFyPOx(8B9JQ5GqAkjiOx(DbdD8owcx0zx8rlwc5VEWIeOZsaRA1JoUOAqILqVnWi4hgZhDFq1qx0LLInMIRXpyvczOzNfHZMMQCGrWpCkkPKPOSuCn(bRsidn7SiC20uLdmc(HtXatXQDEFPIQYGHspytrjKIneskknfLIEgcnxVzrxUr1gb)ONhawpSvqrhiahDwcyYmQQvp6Hm0SSl(OvdHGUQvp6(kOpfjZ4mpfLrsk6zOn7OdS6jpKHMLDXhTAiKGl34mNCznUg)GvjKHMDweoBAQYbgb)WskPS14hSkHm0SZIWzttvoWi4hoWQDEFPIQeAiePsrV8536hvZbH0usqqV87cg64DSeUOZU4JwSeYF9GfjqNLaw1QhDCr1GHLqVnWi4hgZhDFq1qx0LLInMIRXpyvczOzNfHZMMQCGrWpCkkPKPOSuCn(bRsidn7SiC20uLdmc(HtXatXQDEFPIQYGHspytrjKItHKIstrPONHqZ1Bw0LBuTrWp65bG1dBfu0bcWrNLaMmJQA1JEidnl7IpAnfc6Qw9O7RG(uKmJZ8uuwoPONH2SJoWQN8qgAw2fF0AkKGl34mNCznUg)GvjKHMDweoBAQYbgb)WskPS14hSkHm0SZIWzttvoWi4hoWQDEFPIQeMcrQu0lF(T(r1CqinLee0l)UGHoEhlHl6Sl(OflH8xpyrc0zjGvT6rhxunGyj0Bdmc(HX8r3hun0fDzPyJP4A8dwLqgA2zr4SPPkhye8dNIskzkklfxJFWQeYqZolcNnnv5aJGF4umWuSAN3xQOQmyO0d2uucPyWcykknfLIEgcnxVzrxUr1gb)ONhawpSvqrhiahDwcyYmQQvp6Hm0SSl(OvWci6Qw9O7RG(uKmJZ8uuwqkf9m0MD0bw9KhYqZYU4JwblGbxUXzo5YACn(bRsidn7SiC20uLdmc(HLuszRXpyvczOzNfHZMMQCGrWpCGv78(sfvjeSakvk6Lp)w)OAoiKMscc6LFxWqhVJLWfD2fF0ILq(RhSib6SeWQw9OJlQkryj0Bdmc(HX8r3hun0fDzPyJP4A8dwLqgA2zr4SPPkhye8dNIskzkklfxJFWQeYqZolcNnnv5aJGF4umWuSAN3xQOQmyO0d2uucPyUaMIstrPONHqZ1Bw0LBuTrWp65bG1dBfu0bcWrNLaMmJQA1JEidnl7IpALlGORA1JUVc6trYmoZtrzbtk6zOn7OdS6jpKHMLDXhTYfWGl34mNCznUg)GvjKHMDweoBAQYbgb)WskPS14hSkHm0SZIWzttvoWi4hoWQDEFPIQeYfqPsrV8536hvZbH0usqqV87cg64DSeUOZU4JwSeYF9GfjqNLaw1QhDCr1Pyj0Bdmc(HX8r3hun0fDzPyJP4A8dwfH8thfgT5voWi4hofLuYuuwkUg)Gvri)0rHrBELdmc(HtXatXQDEFPIQYGHspytrjKItHKIstrPONHqZ1Bw0LBuTrWp65bG1dBfu0bcWrNLaMmJQA1J(KYEsec(uiORA1JUVc6trYmoZtrzbuk6zOn7OdS6jFszpjcbFkKGl34mNCznUg)Gvri)0rHrBELdmc(HLuszRXpyveYpDuy0Mx5aJGF4aR259LkQsykePsrV8536hvZbH0usqqV87cg64DSeUOZU4JwSeYF9GfjqNLaw1QhDCr1gILqVnWi4hgZhDFq1qx0LLInMIRXpyveYpDuy0Mx5aJGF4uusjtrzP4A8dwfH8thfgT5voWi4hofdmfR259LkQkdgk9GnfLqkkrqsrPPOu0ZqO56nl6YnQ2i4h98aW6HTck6ab4OZsatMrvT6rFszpjcbxIGGUQvp6(kOpfjZ4mpfLjrsrpdTzhDGvp5tk7jri4seKGl34mNCznUg)Gvri)0rHrBELdmc(HLuszRXpyveYpDuy0Mx5aJGF4aR259LkQsqIGivk6Lp)w)OAoiKMscc6LFxWqhVJLWfD2fF0ILq(RhSib6SeWQw9OJlQoXyj0Bdmc(HX8r3hun0fDzP4BaJgk0dR0Rco8PAqZ5IB0nfLIEgcnxVzrxUr1gb)ONhawpSvqrhiahDwcyYmQQvp6f3OB7gWOHc9WORA1JUVc6trYmoZtrztLIEgAZo6aREYlUr32nGrdf6HdUCJZCYL9gWOHc9WkKciPgsAILIE5ZV1pQMdcPPKGGE53fm0X7yjCrNDXhTyjK)6blsGolbSQvp64IQKGGLqVnWi4hgZhDFq1qx0LLIVbmAOqpSI1Y0aM(Sr0fCM9Ztum9vpEkkf9meAUEZIUCJQnc(rppaSEyRGIoqao6SeWKzuvRE0TwMgW0UbmAOqpm6Qw9O7RG(uKmJZ8uuwdLIEgAZo6aREYTwMgW0UbmAOqpCWLBCMtUS3agnuOhwHuqofsddMu0lF(T(r1CqinLee0l)UGHoEhlHl6Sl(OflH8xpyrc0zjGvT6rhxuLejSe6Tbgb)Wy(O7dQg6IUSuuUr1gb)kwltdyA3agnuOhofdmfjycdvke7CHbGvyGMIbMInMIemHHkHurFjOgawHbAkkf9meAUEZIUCJQnc(rppaSEyRGIoqao6SeWKzuvRE0TwMgWKXrx1QhDFf0NIKzCMNIYMyPONH2SJoWQNCRLPbmz8Gl34mNCzYnQ2i4xXAzAat7gWOHc9WbsWegQui25cdaRqVn2aBKGjmujKk6lb1aWkmqLIE5ZV1pQMdcPPKGGE53fm0X7yjCrNDXhTyjK)6blsGolbSQvp64IQKYHLqVnWi4hgZhDFq1qx0LLInMIemHHkCDZIfObnNhuRxOWanfdmf7FNjeaMUYQpnhK5CqhPOesriPOu0ZqO56nl6YnQ2i4h98aW6HTck6ab4OZsatMrvT6rFY6MflqdAYMA9cvXkXGIUQvp6(kOpfjZ4mpfLrcIu0ZqB2rhy1t(K1nlwGg0Kn16fQIvIbn4YnoZjxwJemHHkCDZIfObnNhuRxOWanW(3zcbGPRS6tZbzoh0Hu0lF(T(r1CqinLee0l)UGHoEhlHl6Sl(OflH8xpyrc0zjGvT6rhxuLuqILqVnWi4hgZhDFq1qx0LLIYsrcMWqfJdTWMNGGhQqF10GEkgePyUumWuKGjmuX4qlS5ji4Hk0xnnONIbrkMlfdmfjycdvmo0cBEccEOc9vtd6PyqKI5srPPyGPy4PgFUdvt1Rc9vtd6POesXGLIsrpdHMR3SOl3OAJGF0ZdaRh2kOOdeGJolbmzgv1QhDJdTWK4cEi7IpAHUQvp6(kOpfjZ4mpfLrIKu0ZqB2rhy1tUXHwysCbpKDXhTcUCJZCYLjd6xLqQOVZtqWdviycdvmo0cBEccEOc9vtd6brUaH(vjuFA25ji4HkemHHkghAHnpbbpuH(QPb9GixGq)QW1nlwGg0CEccEOcbtyOIXHwyZtqWdvOVAAqpiYjnWWtn(ChQMQxf6RMg0LqWKIE5ZV1pQMdcPPKGGE53fm0X7yjCrNDXhTyjK)6blsGolbSQvp64IQKcgwc92aJGFymF0ZqO56nl6m9pR3x7ONhawpSvqrhiahDwcyYmQQvp6ORA1JUeR)umV91o6Lp)w)OAoiKMscc6LFxWqhVJLWfD2fF0ILq(RhSib6SeWQw9OJlQskGyj0Bdmc(HX8rpdHMR3SOpmoF2gRwaM56(IEEay9WwbfDGaC0zjGjZOQw9OJUQvp6SnopfZmwTaKItw3x0ZqB2rhy1tEqDDLDk2guyGXRhSbiffqp40GIE5ZV1pQMdcPPKGGE53fm0X7yjCrNDXhTyjK)6blsGolbSQvp6UUYofBdkmW41d2aKIcOhCkUOkjjclHEBGrWpmMp6(GQHUOtWegQy9XbWgyCfgOONHqZ1Bw0hgNpBJvlaZCDFrppaSEyRGIoqao6SeWKzuvRE0rx1QhD2gNNIzgRwasXjR7BkkJKu0ZqB2rhy1tEqDDLDk2guyGXRhSbifT(iOOx(8B9JQ5GqAkjiOx(DbdD8owcx0zx8rlwc5VEWIeOZsaRA1JURRStX2GcdmE9GnaPO1h4IQKMILqVnWi4hgZh9meAUEZI(W48zBSAbyMR7l65bG1dBfu0bcWrNLaMmJQA1Jo6Qw9OZ248umZy1cqkozDFtrz5KIEgAZo6aREYdQRRStX2GcdmE9GnaPibtyypOOx(8B9JQ5GqAkjiOx(DbdD8owcx0zx8rlwc5VEWIeOZsaRA1JURRStX2GcdmE9GnaPibtyyhxuLudXsO3gye8dJ5JEgcnxVzrFyC(SnwTamZ19f98aW6HTck6ab4OZsatMrvT6rhDvRE0zBCEkMzSAbifNSUVPOSGuk6zOn7OdS6jpOUUYofBdkmW41d2aKISNi9GIE5ZV1pQMdcPPKGGE53fm0X7yjCrNDXhTyjK)6blsGolbSQvp6UUYofBdkmW41d2aKISNiDCrvstmwc92aJGFymF0ZqO56nl6dJZNTXQfGzUUVONhawpSvqrhiahDwcyYmQQvp6ORA1JoBJZtXmJvlaP4K19nfLfmPONH2SJoWQN8G66k7uSnOWaJxpydqkoe0hu0lF(T(r1CqinLee0l)UGHoEhlHl6Sl(OflH8xpyrc0zjGvT6r31v2PyBqHbgVEWgGuCiOhxunheSe6Tbgb)Wy(ONHqZ1Bw0hgNpBJvlaZCDFrppaSEyRGIoqao6SeWKzuvRE0rx1QhD2gNNIzgRwasXjR7BkklGsrpdTzhDGvp5b11v2PyBqHbgVEWgGumuZ5Ngu0lF(T(r1CqinLee0l)UGHoEhlHl6Sl(OflH8xpyrc0zjGvT6r31v2PyBqHbgVEWgGumuZ5NIlUO7q)qBC9eTTAbavZjrbjUic]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170828.180304, [[deJWbaGEukTluHxJk1mPkA2u5Ms42sANuAVKDR0(PQAysLFRYqHszWuvgUeDqrYXOWcPkTuPQfJQwou9qr0tbpwkRdLuteLIPkktgstx4IIuxg56IWwPkSzucBhLQdRQPbL0ZHyzO4ZIQrtrFdkojQKXbL40kopQO)Is02Gs1ZqjzzOmbSHyXNWfYRa7xjbWut63x6183gvPnyTFFL4u7Q8FiONC0JqYY0zGPdddgoyyyWcwfan8PmeiivlMBruMSgktq695DeQ8kaA4tziiU8ChXr5fZTicsXpUj4uq5fZTc4ArN2hhUG9wsqXH6XJB)kjqG9RKaSDXCRGEYrpcjltNbgJob9eYLaVriktHGKMuJ7IJDQsBiEbfhQ9RKafYYOmbP3N3rOYRGu8JBcof4MCZyNnNLiMd5qfW1IoTpoCb7TKGId1Jh3(vsGa7xjbEo5MXoBUFFG5qoub9KJEeswModmgDc6jKlbEJquMcbjnPg3fh7uL2q8ckou7xjbkuiakP28UHTFm3kld2zLcj]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20170828.180304, [[d4JKlaGEQuvTjQu2fs12ijP9bs1mrcTms0Svy(urUPu53K6BkvUm0ovP9k2nW(L0OOsAyiPXbsPZlv50igSugov4qurLtrL4ykYXbPOfIeTusyXGA5eEij1tr9yjwhvuvtKkvXujstwftxvxeKCvQuvEgvuUUszJuPkTvsInRu12vuhMYxjjXNbX3bPWRrkpNQgnr9xPQojr00ij11OsL7HeCoQOk3wjhKiCMI0WUhCVTn(qzyUiio(WHvGd08yUkPoTJ6oL7ORuPsOv1HzhyHydI73EIgKRsv1zHLO8enWhP5ofPHHcyWd8ekdZfbXXhE2eedEG03Vj6Pwgl0u6UWsatgKVxy0eVmc67DqOHHLeCif71IWanad3PpQyIRTWWHV2cddLjEzeuBSdcnmScCGMhZvj1PDtudRa96nrb9rA(WQLXcTo9mUqWh4WD6Z1wy485QmsddfWGh4jugMlcIJpSZvBWB73tVimVC)bbI8diai03CuBUvBw5jZyFeGlc6RnOtHAtzyjGjdY3lCryE5(dce5hqaqclj4qk2RfHbAagUtFuXexBHHdFTfgwTW8Y1gfjqKFabajScCGMhZvj1PDtudRa96nrb9rA(WQLXcTo9mUqWh4WD6Z1wy4856SinmuadEGNqzyjGjdY3lm0GaoEnasyjbhsXETimqdWWD6JkM4AlmC4RTWWQcbC8AaKWkWbAEmxLuN2nrnSc0R3ef0hP5dRwgl060Z4cbFGd3PpxBHHZNRQJ0Wqbm4bEcLH5IG44dBLNmJ9raUiOV2GofQnOT2CYPAZ1AZkpzg7JaCrqFTbDkuBQAT5wT92abp9IW8YeaK((xlw0rGbpWtT5syjGjdY3lCryE5(dce5hqaqclj4qk2RfHbAagUtFuXexBHHdFTfgwTW8Y1gfjqKFabaP2CDYLWkWbAEmxLuN2nrnSc0R3ef0hP5dRwgl060Z4cbFGd3PpxBHHZNR7I0Wqbm4bEcLHLaMmiFVWqdc44FbHggwsWHuSxlcd0amCN(OIjU2cdh(AlmSQqah)li0WWkWbAEmxLuN2nrnSc0R3ef0hP5dRwgl060Z4cbFGd3PpxBHHZNRQgPHHcyWd8ekdZfbXXhgEB)E6(xlwWccackOV5O2CR2MnbXGhi99BIEQLXcnLUlSeWKb57f2)AXY)ccnmSKGdPyVwegOby4o9rftCTfgo81wyy(1IL)feAyyf4anpMRsQt7MOgwb61BIc6J08HvlJfAD6zCHGpWH70NRTWW5ZDxKggkGbpWtOmmxeehFyR8KzSpcWfb91g0PqTP6AZjNQnxRnR8KzSpcWfb91g0PqTPS2CR2EBGGNEryEzcasF)Rfl6iWGh4P2CjSeWKb57fUimVC)bbI8diaiHLeCif71IWanad3PpQyIRTWWHV2cdRwyE5AJIeiYpGaGuBUQ0LWkWbAEmxLuN2nrnSc0R3ef0hP5dRwgl060Z4cbFGd3PpxBHHZNl0gPHHcyWd8ekdZfbXXh(TbcE66zuuKnbeKocm4bEQn3QTztqm4bsF)MONAzSqt1UR2CR2wgo8VqVOx2ece81g0PqTPAQHLaMmiFVWdce5hqaq6dRhFyjbhsXETimqdWWD6JkM4AlmC4RTWWuKar(beaKAJs94dRahO5XCvsDA3e1WkqVEtuqFKMpSAzSqRtpJle8boCN(CTfgoFUoVinmuadEGNqzyUiio(WUwBoxT92abpD9mkkYMacshbg8ap1MB12Sjig8aPVFt0tTmwOPA3vBUuBo5uT5AT92abpD9mkkYMacshbg8ap1MB12Sjig8aPVFt0tTmwObTuRnxclbmzq(EH9VwS8VGqddlj4qk2RfHbAagUtFuXexBHHdFTfgMFTy5FbHgwBUo5syf4anpMRsQt7MOgwb61BIc6J08HvlJfAD6zCHGpWH70NRTWW5ZDIAKggkGbpWtOmmxeehF4ztqm4bs3OzeWMeCyjGjdY3l8EH2)WcdCclj4qk2RfHbAagUtFuXexBHHdFTfg29k0(hwyGtyf4anpMRsQt7MOgwb61BIc6J08HvlJfAD6zCHGpWH70NRTWW5ZDAksddfWGh4jugMlcIJpm82(90L1FFzdCOV5O2CR2CT2CT2MnbXGhiDJMraBqbn3ioCGNAZTAdEB)E67fA)dlmWH(MJAZLAZjNQnNR2MnbXGhiDJMraBqbn3ioCGNAZLWsatgKVx4HnB9hMxoSKGdPyVwegOby4o9rftCTfgo81wyykAZwTrrZlhwboqZJ5QK60UjQHvGE9MOG(inFy1YyHwNEgxi4dC4o95AlmC(CNugPHHcyWd8ekdZfbXXh2kpzg7JaCrqFTbDkuBolSeWKb57f2VboOGaGewsWHuSxlcd0amCN(OIjU2cdh(AlmmVboOGaGewboqZJ5QK60UjQHvGE9MOG(inFy1YyHwNEgxi4dC4o95AlmC(CNCwKggkGbpWtOmmxeehFyR8KzSpcWfb91g0PqT5SAZjNQTztqm4bsNIeiYpGaGOwyE5R(DFoQnNCQ2MnbXGhiDB4q2uf9yVAzSqlSeWKb57fUimVC)bbI8diaiHLeCif71IWanad3PpQyIRTWWHV2cdRwyE5AJIeiYpGaGuBU6mxcRahO5XCvsDA3e1WkqVEtuqFKMpSAzSqRtpJle8boCN(CTfgoF(WxBHHzYsDTbfq2afCHG35xBfTaZNaa]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20170828.180304, [[b4vmErLxtruzMfwDSrNxc51utnMCPbhDEnLxtjvzSvwyZvMxojdmXCdm3iZnUiJmYGdnEn1uWv2yPfgBPPxy0L2BU5LtYyZmEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxt1wyLX2C0j3BT5Yy1jNCL5gD(bgp(bwm14hyM4hy0LwBL5hy84hyNngzEnvqILgBPrxEEnLCVn2AILgDLjNxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnLuVn2AILgDLjNxtjvzSvwyZvMxojdmXCtmW41usv2CVvNCJv2CErLx051udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnLx05fDEnLtH1wzEn1uP12q(bwrUHwyUnwzTvMB0PJFG9gCL5wzY5fDE5f]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170901.184729, [[d0dJhaGEcQ0MqLSlu12eb2NOOLjknBQA(iLBIeFdf1TvvhwQDIs7vz3QSFqJcjzyI04ebDEuKHsqjdgXWvLoeHcNcj1XqHtt0cjqlLIAXuy5c9qc4PKEmvwhbfnrrunvkYKfmDGlsO6zIOCzORJuTrcQARIiBMq2oQu)wYxjOW0iu03fvnsck1NrfJwuzEekDsrONtPRjkCpcQ4VQIETQWbjipgZ00KJIA6EWeCkB)XPQ8laKi(LRph(XdimHebsUDQz0JTfhB2ugmNMWSjKNrcttwQyovFrNS9sHBdK1n2SjiztfYbK1zNPXYyMMk(1gEmmJPQlkFbtbfhoEK3vLpu5plKWfKqfKa6iheWNdBpih)RdajIfsYMbKqJgKaKFesYess5ZinfsOEQqgsVeW00CySK2)0eVG01Gko9QdNsPcj1r2(JtNY2FCQWgJL0(NAg9yBXXMnLbZmsNAgTf9OdTZ0atfih6EqP4g)4bMXukvGT)40bgB2zAQ4xB4XWeCQ6IYxWuqXHJh5Dv5dv(ZcjCbjubjg0fjIVTo8c95qE6VqcnAqcvqIim2(N2xzuc4J4VLNfsYesYasOgsOrds8i3OhselKWinfsOEQqgsVeW0udmAX4d5XzAIxq6AqfNE1HtPuHK6iB)XPtz7povqmAX4d5XzQz0JTfhB2ugmZiDQz0w0Jo0otdmvGCO7bLIB8JhygtPub2(JthySjBMMk(1gEmmbNQUO8fmfuC44rExv(qL)SqcxqcvqIbDrI4BRdVqFoKN(lKqJgKqfKicJT)P9vgLa(i(B5zHKmHKmGeQHeA0GepYn6HeXcjmstHeQNkKH0lbmn1Wxv4Pi6rMMM4fKUguXPxD4ukviPoY2FC6u2(Jtf0xvaseE6rMMAg9yBXXMnLbZmsNAgTf9OdTZ0atfih6EqP4g)4bMXukvGT)40bgRyottf)AdpgMGtvxu(cMckoC8i)BbK1zHeUGeQGed6IeX3whEH(Cip9xiHgnirmGeq7XdW3whEH(CipETHhdqcxqIim2(N2xzuc4J4VLNfsYesYasOrdsaDKdc4bYp(eupdseseRWbssqkKq9uHmKEjGPPVfqw30eVG01Gko9QdNsPcj1r2(JtNY2FCQWQaY6MAg9yBXXMnLbZmsNAgTf9OdTZ0atfih6EqP4g)4bMXukvGT)40bgBgZ0uXV2WJHj4u1fLVGPGIdhpY7QYhQ8NDQqgsVeW0uryS9pTVYOemnXliDnOItV6WPuQqsDKT)40PS9hNk8yS9qI(kJsWuZOhBlo2SPmyMr6uZOTOhDODMgyQa5q3dkf34hpWmMsPcS9hNoWytWmnv8Rn8yycovDr5lykvqcvqIyajGIdhpY7QYhQ8Nfs4csaThpaFBD4f6ZH841gEmajCbjweaKhhlF79v(NH8pdOLPZbjudj0ObjUQ8Hk)X3whEH(CiFe)T8SqsMqscGeQHeA0Geq7XdWBu09bmksAb841gEmaj0Objb0GUir8yhb5W7P9v(a5P)ovidPxcyAAOQ)Z8YlyNM4fKUguXPxD4ukviPoY2FC6u2(JttEvFiryiVGDQz0JTfhB2ugmZiDQz0w0Jo0otdmvGCO7bLIB8JhygtPub2(JthySmpttf)AdpgMGtvxu(cMckoC8iVRkFOYFwiHliHkiHkiXvLpu5pElOIFlikFG8r83YZcjzcjPqc1qcxqIbDrI4BRdVqFoKpu5piH6Pczi9sattBRdVqFoCAIxq6AqfNE1HtPuHK6iB)XPtz7poviRdVqFoCQz0JTfhB2ugmZiDQz0w0Jo0otdmvGCO7bLIB8JhygtPub2(JthyGPQlkFbthyda]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170828.180304, [[d4Z8iaGEkf0Mie7sjTnIQSpLIMPsblJinBjMpqYnLQ(nsFJs1LH2jG9k2nO9lLrbKAysLXre68eWqvk0GL0WvkDqcPtbu6ykX5OuGfsGwkbTyvz5iEiP0tr9yfToIQstKOQyQeQjRQMUkxeO60K8mkf66uYgPu0wjI2mPy7eLBtXFPuAAaH5be51KkhMQrRu9zsvNKOYpbI6Aeb3dO45kCiIQQoorvLZsehw(GACRYfbdZtIA7foSqSG(adG0Uf7D2LAFvQuPseeH5T4u5fLn0pffgaPYZgdl68uu4iIdWsehgCO)k4pcgMNe12lSXXY4iuZ60Iqq41QGuRUiTlSOpvrDceMqN6EQdjHLd(vt)OKWqked3t)s6ea3GHdd4gmSq6u3tDijSqSG(adG0Uf7lDHfIdQfzIJioxyT74uxpvgAq4Lx4E6hWny4CbqAehgCO)k4pcgMNe12l8ZsJMvnf3GhfQ3cxjOXvWrRcsTkiwLyyrFQI6eiSMIBWJc1BHHLd(vt)OKWqked3t)s6ea3GHdd4gmSnlUbpkuVfgwiwqFGbqA3I9LUWcXb1ImXreNlS2DCQRNkdni8YlCp9d4gmCUayJrCyWH(RG)iyyEsuBVWGUvpVGWBDs8XUcQ32XrjMve6Vc(BvqbQw1NNsgAlcrJchT6MGPvL2QGTvfPv)4ZsJMv0j3ocTDSvPdxT22QI0QghlJJqnRtlcbHxRUjyAvq01QI0QYCIYFfCfK1UrkTiVUWI(uf1jq4jXh72wu63pOcQpSCWVA6hLegsHy4E6xsNa4gmCya3GH1s8XERUbL(9dQG6dlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaarehgCO)k4pcgMNe12l85feER7UQmokXSIq)vWFRksR(S0OzvdHoUhXH)vcACfC0QGuRcIvj2QI0QghlJJqnRtlcbHxRUzRcIUWI(uf1jqyne64Eeh(dlh8RM(rjHHuigUN(L0jaUbdhgWnyyBsOJ7rC4pSqSG(adG0Uf7lDHfIdQfzIJioxyT74uxpvgAq4Lx4E6hWny4CbqcrCyWH(RG)iyyEsuBVWYCIYFfC115kOf4Ypl12T4VvfPvL)T6ZsJMvne64Eeh(xT22QI0QghlJJqnRtlcbHxRUjyAv7siSOpvrDcewdHoUhXH)WYb)QPFusyifIH7PFjDcGBWWHbCdg2Me64Eeh(BvqVa2WcXc6dmas7wSV0fwioOwKjoI4CH1UJtD9uzObHxEH7PFa3GHZfa5fXHbh6Vc(JGHf9PkQtGWdl4hjkO(WYb)QPFusyifIH7PFjDcGBWWHbCdgMTGFKOG6dlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaShXHbh6Vc(JGH5jrT9cBCSmoc1SoTieeET6MGPvLqxRksRkZjk)vWvqw7gP0I9UwvKwvMtu(RGRASicODhN6KyxyrFQI6eiCXL52w8XEy5GF10pkjmKcXW90VKobWny4WaUbdVbxM3QBWh7HfIf0hyaK2TyFPlSqCqTitCeX5cRDhN66PYqdcV8c3t)aUbdNlasmIddo0Ff8hbdl6tvuNaHj0PUN6qsy5GF10pkjmKcXW90VKobWny4WaUbdlKo19uhsAvqVa2WcXc6dmas7wSV0fwioOwKjoI4CH1UJtD9uzObHxEH7PFa3GHZfaBqehgCO)k4pcgMNe12lmOBvJJLXrOM1PfHGWRv3emTQ8KqRckq1QNxq4Toj(yxb1B74OeZkc9xb)TkOavR6ZtjdTfHOrHJwDtW0QsBvW2QI0QYCIYFfCfK1UrkTiVUwvKwvMtu(RGRASicODhN6aHecl6tvuNaHNeFSBBrPF)GkO(WYb)QPFusyifIH7PFjDcGBWWHbCdgwlXh7T6gu63pOcQVvb9cydlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaw6I4WGd9xb)rWWI(uf1jqynf3GhfQ3cdlh8RM(rjHHuigUN(L0jaUbdhgWnyyBwCdEuOElSvb9cydlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxUWaUbdZkJ2wfC4UdNObHN8Tv1OkfKKlba]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170829.202855, [[dSJNgaGEij1MiGDrrBJuH9bPuZesIMnvUPs5BqILruTtv1EL2nW(fmkifnmimosf9BqxgzWu1WjkheI6uqkCmL00ivLfsqTuczXQYYH6HkvwfKsEScRdssMiKeMkHAYuA6QCrcYRGKYZivvxNcBujQTsQYMjLTdronjhcsLptKMhKQoSOxRegnrCBHojPsFxjY1GKQZRu1Fjqpxrpf1DTIlJkiT0WDv4Y8aRKDLllICuoP(LJyffe6uUonx1jc9JqFLzz0qLofQopfe0VCDO)YipofemR4(xR4YcbYNJSv4Y8aRKDLV0rGZ0La70PSKjbYNJSbVabp6c(NHMMPlb2PtzjtdzLr(PCQBFzmCS4PocxwxGvnYdIldGaQ8g0QxI)zKkx(NrQSi4yXtDeUSiYr5K6xoIvuwruwenHg4bnR4EL3jHgl2GirrcC9vEdA)zKk3RF5vCzHa5Zr2kCzEGvYUYOl4p1yHcin4fi4Jj5MhggnhgymbUGhTdE5YlJ8t5u3(YAg49cc1emv4Y6cSQrEqCzaeqL3Gw9s8pJu5Y)msLx2aVp4HAbpYkCzrKJYj1VCeROSIOSiAcnWdAwX9kVtcnwSbrIIe46R8g0(ZivUx)6VIlleiFoYwHlZdSs2voXNslhNz6KjjfCjOtZeNGfbpAh8icEbcEzycjbLoSMRMAeoDcoLPWQRmYpLtD7lpW5uIGoLujhqbKwwxGvnYdIldGaQ8g0QxI)zKkx(NrQ8oCoLe8OsLujhqbKwwe5OCs9lhXkkRiklIMqd8GMvCVY7KqJfBqKOibU(kVbT)msL71V(Q4YcbYNJSv4Y8aRKDLrxW)m00m1CzKoiqQbzAiRmYpLtD7lR5YiDqGudQSUaRAKhexgabu5nOvVe)ZivU8pJu5LDzKoiqQbvwe5OCs9lhXkkRiklIMqd8GMvCVY7KqJfBqKOibU(kVbT)msL71pQxXLfcKphzRWL5bwj7kFPJaNPKu5Mhehnjq(CKn4fi4rxW)m00m1WW59WjWAAil4fi4rkXQ85itnd8(DsOXc9H6Lr(PCQBFznmCEpCcSL1fyvJ8G4YaiGkVbT6L4FgPYL)zKkVmgoVhob2YIihLtQF5iwrzfrzr0eAGh0SI7vENeASydIefjW1x5nO9NrQCV(1rfxwiq(CKTcxMhyLSR8ZqtZuZLr6GaPgKjMIPcmdE0h86i4rTGx6Wg8ce8di0zHlbmTqyuWLua70etXubMbp6dEPdBWJwbV8Yi)uo1TVSMlJ0bbsnOY6cSQrEqCzaeqL3Gw9s8pJu5Y)msLx2Lr6GaPguWJMROrzrKJYj1VCeROSIOSiAcnWdAwX9kVtcnwSbrIIe46R8g0(ZivUx)OuXLfcKphzRWL5bwj7kFPJaNPKu5Mhehnjq(CKn4fi4FgAAMAy48E4eynXumvGzWJ(GxhbpQf8sh2GxGGFaHolCjGPfcJcUKcyNMykMkWm4rFWlDydE0k4Lxg5NYPU9L1WW59WjWwwxGvnYdIldGaQ8g0QxI)zKkx(NrQ8Yy48E4eydE0CfnklICuoP(LJyfLveLfrtObEqZkUx5DsOXInisuKaxFL3G2FgPY96v(NrQmRI7cEHassWGIe4qvb)ZqtB2Rf]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20170828.180304, [[dadxcaGEuv1UuQABOKmBeUPq(gIANc2lz3G2VOQHjHFdmyrPHJIoOOYXOKfkkwQszXuQLlYdvsEQQhlPNtXefkMQenzQmDfxev5zcvDDuQTIiTzuvA7Oeldv(QqPPHQIVJighkPUm0OrHxReNuj1HL60iDELk)vOYTPQ1HQkllvQhdY3MnXOm6NjwPnbL)9qbqf4yv86Bib2gubUclYfK5iVNJJJ18r)1eL5ORNRoua0OsfSuPopyBtGoLrpNnLGo70XonmqyCgM0fuFn0rR9as6qae1Jaos7uO9OUEO9OoVonmqy(SNjDb13qcSnOcCfwKTk03qdGDQIgvQrFfdSUebyb9iCKTEeWfApQRrbovQZd22eOtz0Fnrzo6vaGWbibU3mGK3mj6cUNnt9C2uc6St3ba(4iHcDg91qhT2diPdbqupc4iTtH2J66H2J6Xaa(8zJLcDg9nKaBdQaxHfzRc9n0ayNQOrLA0xXaRlrawqpchzRhbCH2J6AuiEvQZd22eOtz0ZztjOZoDsOqNzs0fuFn0rR9as6qae1Jaos7uO9OUEO9OESuOZmj6cQVHeyBqf4kSiBvOVHga7ufnQuJ(kgyDjcWc6r4iB9iGl0EuxJg9q7r9t9RYNLhKrdROhHd)YNTnvnsa]] )

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20170905.115544, [[dm0inaqiOkLfHQOnbvvnksHofPGDHknmvXXuvwgPQNHQGPPcKRbvfBtfqFdvPXPcQZPcuTovvzEqvL7PcY(qvOdkblevLhkHMiuLKlskTrva8rOkgjuLOtsuAMqvPBkr7ek)eQs1qHQKAPOINImvIQRcvjSvsrFvfG2R4VQOgmfhwQftKhlPjRsxgSzsfFwvA0QQCAcVMOy2OCBs2Ts)gYWvrwov9CQmDfxhQSDuv9Dvv15vHwVkqz(KkTFkD(I8qyTccrcvrRrlduWonZAWtRKyI99pR5c604ytiQ6fNMqH4amODqW0)8X7ZH1FyUFh(HhEoOq0jOkAM4G1JaTbt)bQpuH6iqRlYd2xKhs72sm4gPqu1lonHg07ld4wri2f9)6Sg83A0O1mT)fgU)GMn)4EQowd(zn6XhRrxDTMrOaRHhTMhU4ZZJ1OHqfKemXCmKedHUmCUjKS7vu7b5dTOfcvIUA2ESwbHcH1kieEj4rcNkehGbTdcM(NpE)EcXbCiC(k4I8mHk(dQYuI4huWorkuj6I1kiuMGPpYdPDBjgCdFHOQxCAcnO3xgW9eAeO1zn4V1OrRPIqSl6)LRocpCgyGc2PzC9GQfRZA4rRr)HFSgD11AM2)cd3rOGZd68vawd(DiR5aFSgneQGKGjMJHoHgbAdj7Ef1Eq(qlAHqLORMThRvqOqyTccHxJgbAdXbyq7GGP)5J3VNqCahcNVcUiptOI)GQmLi(bfStKcvIUyTccLjy8qKhs72sm4g(crvV40eAqVVmGRyhW7XDACHkijyI5yO)f79S7h0(qYUxrThKp0Iwiuj6Qz7XAfekewRGqhqXETg6h0(qCag0oiy6F(497jehWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqzc2bf5H0UTedUHVqu1lonHKWPJoC9GdT9wHZdAafxpOAX6Sg8ZA0hQGKGjMJHg0aQZQ2nG)yiz3RO2dYhArleQeD1S9yTccfcRvqi5Obuwtz7gWFmehGbTdcM(NpE)EcXbCiC(k4I8mHk(dQYuI4huWorkuj6I1kiuMGHprEiTBlXGB4lev9IttOb9(YaUveIDr)VUqfKemXCmKocpCgyGc2PzHKDVIApiFOfTqOs0vZ2J1kiuiSwbHoacpynAzGc2PzH4amODqW0)8X73tioGdHZxbxKNjuXFqvMse)Gc2jsHkrxSwbHYeSdmYdPDBjgCdFHOQxCAcnO3xgWTIqSl6)1fQGKGjMJHCdYRodmqb70SqYUxrThKp0Iwiuj6Qz7XAfekewRGq0G8kRrlduWonlehGbTdcM(NpE)EcXbCiC(k4I8mHk(dQYuI4huWorkuj6I1kiuMGXBKhs72sm4g(crvV40eAqVVmGBfHyx0)Rlubjbtmhdbmqb70SZQ2nG)yiz3RO2dYhArleQeD1S9yTccfcRvqiTmqb70mRPSDd4pgIdWG2bbt)ZhVFpH4aoeoFfCrEMqf)bvzkr8dkyNifQeDXAfektWoCKhs72sm4g(cvqsWeZXq4CWzXakxiz3RO2dYhArleQeD1S9yTccfcRvqi8chynYoGYfIdWG2bbt)ZhVFpH4aoeoFfCrEMqf)bvzkr8dkyNifQeDXAfektWo4rEiTBlXGB4lev9IttOb9(YaUveIDr)VoRb)TgnAn4nRzAgSd32vH92Bf4cBlXGR1ORUwJeoD0HB7QWE7TcCXDYA0vxRPIqSl6)LB7QWE7TcC9GQfRZA4rRbFESgneQGKGjMJHKyi09So48hdj7Ef1Eq(qlAHqLORMThRvqOqyTccXhdHUwZbaN)yioadAhem9pF8(9eId4q48vWf5zcv8huLPeXpOGDIuOs0fRvqOmb77jYdPDBjgCdFHOQxCAcnO3xgWTIqSl6)1zn4V1OrRbVzntZGD42UkS3ERaxyBjgCTgD11AKWPJoCBxf2BVvGlUtwJgcvqsWeZXqsG3bEze7Biz3RO2dYhArleQeD1S9yTccfcRvqi(aVd8Yi23qCag0oiy6F(497jehWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqzc23xKhs72sm4g(crvV40eQRJGF4mSGsaoRHhTg9HkijyI5yipU9CxhbApZeUjKS7vu7b5dTOfcvIUA2ESwbHcH1kiehCR1uOoc0An4RWnHk4FDH2wbhINKqv0A0YafStZSg80kjMyF)ZAkG31YZqCag0oiy6F(497jehWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqKqv0A0YafStZSg80kjMyF)ZAkG31MjyF6J8qA3wIb3WxiQ6fNMqtZGD42UkS3ERaxyBjgCTgD11Aya)aZAWpR575jubjbtmhd5XTN76iq7zMWnHKDVIApiFOfTqOs0vZ2J1kiuiSwbH4GBTMc1rGwRbFfUXA04NgcvW)6cTTcoepjHQO1OLbkyNMzn4PvsmX((N14e7ldSM2v5zioadAhem9pF8(9eId4q48vWf5zcv8huLPeXpOGDIuOs0fRvqisOkAnAzGc2PzwdEALetSV)znoX(YaRPD1mb7JhI8qA3wIb3WxiQ6fNMqtZGD4kQGo48h5cBlXGBOcscMyogYJBp31rG2ZmHBcj7Ef1Eq(qlAHqLORMThRvqOqyTccXb3AnfQJaTwd(kCJ1Or9Aiub)Rl02k4q8KeQIwJwgOGDAM1GNwjXe77FwJtSVmWAe6WZqCag0oiy6F(497jehWHW5RGlYZeQ4pOktjIFqb7ePqLOlwRGqKqv0A0YafStZSg80kjMyF)ZACI9LbwJqNmb77GI8qA3wIb3WxiQ6fNMqtZGD4YeV)MvSVN9OlxyBjgCdvqsWeZXqEC75Uoc0EMjCtiz3RO2dYhArleQeD1S9yTccfcRvqio4wRPqDeO1AWxHBSgnYdAiub)Rl02k4q8KeQIwJwgOGDAM1GNwjXe77FwJtSVmWAyEEgIdWG2bbt)ZhVFpH4aoeoFfCrEMqf)bvzkr8dkyNifQeDXAfeIeQIwJwgOGDAM1GNwjXe77FwJtSVmWAy(mzcHxb604yt4ltc]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20170905.115544, [[deZwcaGErK2fKW2GenBjDtk52e2jvTx0UjA)IsdJu(TudfQQgSOy4s0bfjhJuTqj0svslMelNkpuK6PGLPeRdQktueQPsPMmuMUWfLGlR66IkBfQyZIi2oKYhfH8CL6ZqQEmehwXZernAiPPjc6KqLghuLttX5jjFtu1RjP(RiWuN2e8J4eaJiD2mfQxCzm1Szs0iuQgj64lBMs3rAHYeeaeNPmiqy91p7t)IMEEn8wWdf64PLSwcjaLhXmvtsNW0s6xq5cHuiHPLBAtVoTjuqok1JXIeaeNPmien6Oxpkk7W0YnHukMQjurOSdtljGReZGmr7iiB5jy1y4mo)iobc(rCc4VdtljS(6N9PFrtpVUgH1V7CoKVPndcPr9iQTA0U4YGkeSAm)iobg0VqBcfKJs9ySiHukMQjuri64IeiMDCNkc4kXmit0ocYwEcwngoJZpItGGFeNGDhxKnJ1SJ7ury91p7t)IMEEDncRF35CiFtBgesJ6ruB1ODXLbviy1y(rCcmOpzAtOGCuQhJfjKsXunHkc7ODc1)L3raxjMbzI2rq2YtWQXWzC(rCce8J4eGODc1)L3ry91p7t)IMEEDncRF35CiFtBgesJ6ruB1ODXLbviy1y(rCcmyqiXpjtUAWImib]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20170905.115544, [[daK0raqiQsQnrvQrrj1POK8kkrHzrjkAxqLHHehJuTmLWZufLPPkQCnvrvBJsu9nvvnovLQZHKiRJsuQ5PQuUNQi7djPdQQyHkrpej1ersuUOQkBKQK8rKevNKsyMuL4Muv7eklLO6POMkszReL2R0FvsdwOdRyXe5XImzL6YGndv9zk1OjLtt41ivZMk3MIDJ43qgUQWXrsy5K8CrnDvUUQ02Pk(UQsoprX6PeLmFkr2VGREPvgBmqzwyOoe)5adqUXfIu5JrYji2w2HywqSDqi6uL5Ks84kxwo4GjdfBbf9)u((IVJt)7uEgLNRm)asIXjSSMtGifBHLVO8N0jqKCPvm9sR8pYi5GDxwMtkXJRSxhINirxqSdrlzPqCJoC4DJbwZAOeDCkWmcsoe)2tHODAx(JKWjozkJ3ngynRHs0lBbzlsZHuLjicu2hTLDuyJbkxgBmqzVYngieznuIEz5GdMmuSfu0)RtPSCiJEvjixA9ktTgKO7J8agGCvQSpAJngOCVITO0k)Jmsoy3LL)ijCItMYGdma5g3QKBYxzliBrAoKQmbrGY(OTSJcBmq5YyJbk)ZbgGCJlex6M8vwo4GjdfBbf9)6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3RypR0k)Jmsoy3LL5Ks84kl9IhpoiPHG8kc)6PbR2kyU18lzdkbXg37JYFKeoXjtzyuNgv8o0HYwq2I0CivzcIaL9rBzhf2yGYLXgdu(3OonQ4DOdLLdoyYqXwqr)VoLYYHm6vLGCP1Rm1AqIUpYdyaYvPY(On2yGY9k2ZvAL)rgjhS7YYCsjECLnd4YNczWLEvkGCHivFke11)hIwYsHOxhIJ6e4N0Hl)f4CcI9Qzax(uidoGmsoyhIEhIMbC5tHm4sVkfqUqKQpfIuPfL)ijCItMYWOoT1SgkrVSfKTinhsvMGiqzF0w2rHngOCzSXaL)nQtleznuIEz5GdMmuSfu0)RtPSCiJEvjixA9ktTgKO7J8agGCvQSpAJngOCVI98Lw5FKrYb7US8hjHtCYuoFiLHoapavzliBrAoKQmbrGY(OTSJcBmq5YyJbkZhszOdWdqvwo4GjdfBbf9)6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3RywEPv(hzKCWUll)rs4eNmLDcQ4vSxnJTzwp0bMYwq2I0CivzcIaL9rBzhf2yGYLXgdu2lcQ4vSdr)X2mHin0bMYYbhmzOylOO)xNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5Ef7FPv(hzKCWUllZjL4XvEJoC4DJbwZAOeDCkWmcsoePAiMM8TEcdeIEhIjeYTrFrwvWKUYFKeoXjtz34zwLEv5RSfKTinhsvMGiqzF0w2rHngOCzSXaL9Y4zcXLVQ8vwo4GjdfBbf9)6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3RyFV0k)Jmsoy3LL5Ks84kBDiAgWLpfYGl9Qua5crQ(uiUGsi6Dik9IhpoWbgGCJBfpk9MX9(ieTke9oeToevaEfK1gjheIwv(JKWjozkJ3ngynRHs0lBbzlsZHuLjicu2hTLDuyJbkxgBmqzVYngieznuIEiATUvL)OSZLVrzd3Qa)tkaVcYAJKdklhCWKHITGI(FDkLLdz0Rkb5sRxzQ1GeDFKhWaKRsL9rBSXaL7vmQuPv(hzKCWUllZjL4Xv2mGlFkKbx6vPaYfIu9PquxxpeTKLcrVoeh1jWpPdx(lW5ee7vZaU8PqgCazKCWoe9oend4YNczWLEvkGCHivFke)ULhIwYsHiqfVIhpGnUSb52GsqSx1GrDHO3HiqfVIhpGnUtdw3qceEavEvYHq71ht6crVdrZaU8PqgCPxLcixis1q8pLq07q8ghqoCd(duznuIooGmsoyx(JKWjozkdJ60wZAOe9Ywq2I0CivzcIaL9rBzhf2yGYLXgdu(3OoTqK1qj6HO16wvwo4GjdfBbf9)6uklhYOxvcYLwVYuRbj6(ipGbixLk7J2yJbk3Ry6ukTY)iJKd2DzzoPepUYsV4XJtbzezijy9qhyWPaZii5q8BHOoLq0swkeToeLEXJhNcYiYqsW6HoWGtbMrqYH43crRdrPx84Xn5eq2djb42VQ5eisiAzeIjeYTrFrWn5eq2djb4uGzeKCiAvi6DiMqi3g9fb3KtazpKeGtbMrqYH43cr9NpeTQ8hjHtCYu(qhywnt(aLmLTGSfP5qQYeebk7J2YokSXaLlJngOmn0bMq0FYhOKPSCWbtgk2ck6)1PuwoKrVQeKlTELPwds09rEadqUkv2hTXgduUxX01lTY)iJKd2DzzoPepUYwhIsV4XJ7b6lqTIWVEAWQzax(uidU3hHO3H4KoHhyfiGra5q8BH4ZcrRcrVdrRdXni9IhpoNWw7icI9QcTXTrFrcrRk)rs4eNmLDcBTJii2Rsi3v2cYwKMdPktqeOSpAl7OWgduUm2yGYEryRDebXoexICx5pk7C5Bu2WTkW)0gKEXJhNtyRDebXEvH242OViLLdoyYqXwqr)VoLYYHm6vLGCP1Rm1AqIUpYdyaYvPY(On2yGY9kM(IsR8pYi5GDxwMtkXJRS0lE84EG(cuRi8RNgSAgWLpfYG79ri6DioPt4bwbcyeqoe)wi(SYFKeoXjtzNWw7icI9QeYDLTGSfP5qQYeebk7J2YokSXaLlJngOSxe2AhrqSdXLi3fIwRBvz5GdMmuSfu0)RtPSCiJEvjixA9ktTgKO7J8agGCvQSpAJngOCVIP)SsR8pYi5GDxwMtkXJRS1H4KoHhyfiGra5qKQHOEi6DioPt4bwbcyeqoePAiQhIwfIEhIwhIBq6fpECoHT2ree7vfAJBJ(IeIwv(JKWjozkN0gbz1jS1oIGyx2cYwKMdPktqeOSpAl7OWgduUm2yGYuRncsi6fHT2ree7YFu25Y3OSHBvG)Pni9IhpoNWw7icI9QcTXTrFrklhCWKHITGI(FDkLLdz0Rkb5sRxzQ1GeDFKhWaKRsL9rBSXaL7vm9NR0k)Jmsoy3LL5Ks84kpPt4bwbcyeqoePAiQhIEhIt6eEGvGagbKdrQgI6L)ijCItMYjTrqwDcBTJii2LTGSfP5qQYeebk7J2YokSXaLlJngOm1AJGeIEryRDebXoeTw3QYYbhmzOylOO)xNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5Eft)5lTY)iJKd2DzzoPepUYBq6fpECoHT2ree7vfAJBJ(Iu(JKWjozk7e2AhrqSxLqURSfKTinhsvMGiqzF0w2rHngOCzSXaL9IWw7icIDiUe5Uq06fwv(JYox(gLnCRc8pTbPx84X5e2AhrqSxvOnUn6lsz5GdMmuSfu0)RtPSCiJEvjixA9ktTgKO7J8agGCvQSpAJngOCVIPB5Lw5FKrYb7US8hjHtCYu2jS1oIGyVkHCxzliBrAoKQmbrGY(OTSJcBmq5YyJbk7fHT2ree7qCjYDHO1pZQYYbhmzOylOO)xNsz5qg9QsqU06vMAnir3h5bma5QuzF0gBmq5Eft)FPv(hzKCWUllZjL4Xvwb4vqwBKCq5pscN4KPmE3yG1SgkrVm1AqIUpYdyaY1LL9rBzhf2yGYLTGSfP5qQYeebkJngOSx5gdeISgkrpeTEHvL)OSZLnipcI9t6wM3OSHBvG)jfGxbzTrYbLLdoyYqXwqr)VoLYYHm6vLGCP1RSpYJGyxm9Y(On2yGY9kM(3lTY)iJKd2Dz5pscN4KPmmQtBnRHs0ltTgKO7J8agGCDzzF0w2rHngOCzliBrAoKQmbrGYyJbk)BuNwiYAOe9q06fwv(JYox2G8ii2pPxwo4GjdfBbf9)6uklhYOxvcYLwVY(ipcIDX0l7J2yJbk3Ry6uPsR8pYi5GDxw(JKWjozkJ3ngynRHs0ltTgKO7J8agGCDzzF0w2rHngOCzliBrAoKQmbrGYyJbk7vUXaHiRHs0drRFMvL)OSZLnipcI9t6LLdoyYqXwqr)VoLYYHm6vLGCP1RSpYJGyxm9Y(On2yGY96vMkdWpVURl71c]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20170905.115544, [[de0cuaqiuuSjLGrPuQtPuXQukj9kLsIMfjrv7svzyqXXiXYOkEgksnnLsQRHIeBJKiFtvvJdfHZHIKwhjrL5PuPUNsO9HIQdQQYcvIEikLjssuCrLQ2ikI(ijrPtIs1mrrPBsvTtvzPevpfzQOKTssAVs)ffgSihwXIjYJPYKHQld2Ss6ZeLrtPonfVgknBHUnP2nHFdz4KuhxPelhvpxW0v56uY2Pk9DLk58kfRxPKW8jjSFrDvkRsVrdLiJMTCAFe0G4MyoPYoAPOritLlNcgHSiKtM1sKJBuFLkjhIWeG(8Gr5pgMWdt8PWeyyAmBDjsn4mt0SvmNbj6ZJk5P0p3zqIqz1NszvAVyKIaExwICCJ6ReZKtNXH1iKLtQqf5eo6(wJJgyeSroSFCqpgriN29I5KmhEPFsMO52uAnoAGrWg5WwIDbUXnhIxsGeqjFeUQd)nAOuP3OHsmzC0qor2ih2sYHimbOppyu(RGPKCiGS4oiuw9kXMn4W6J8cAqCvQKpc)nAOuV(8uwL2lgPiG3LLih3O(kjzTU(boBeeyGwzC2adzCyogblboWnczFwQZPfYj9aXWXr6pNfNdIlNy(I5etOsL(jzIMBtjy4N9wSgSqj2f4g3CiEjbsaL8r4Qo83OHsLEJgkTF4N9wSgSqj5qeMa0Nhmk)vWusoeqwChekRELyZgCy9rEbniUkvYhH)gnuQxFmDzvAVyKIaExwICCJ6RKK166NXbRw8nFwQZPfYj9aXWXr6pNfNdIlNy(I5KIIsoTqoXm5KK1663eCGaFeo4ZsDPFsMO52uALJchJGnYHTe7cCJBoeVKajGs(iCvh(B0qPsVrdLysokC5ezJCyljhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96BRlRs7fJueW7Ys)KmrZTPeebniUjYqkoHRe7cCJBoeVKajGs(iCvh(B0qPsVrdL2hbniUjMtlJt4kjhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96JPuwL2lgPiG3LLih3O(kPhigoos)5S4CqC5eZxmNuu(NtQqf5eZKtd)mRJ7(c7cIrJqgd9aXWXr6pqmsrapNwiN0dedhhP)CwCoiUCI5lMtmvpL(jzIMBtjy4NnJGnYHTe7cCJBoeVKajGs(iCvh(B0qPsVrdL2p8ZoNiBKdBj5qeMa0Nhmk)vWusoeqwChekRELyZgCy9rEbniUkvYhH)gnuQxFQuzvAVyKIaExwICCJ6RuPFsMO52ukCiUglaQbEj2f4g3CiEjbsaL8r4Qo83OHsLEJgkrhIRXcGAGxsoeHja95bJYFfmLKdbKf3bHYQxj2SbhwFKxqdIRsL8r4VrdL613)YQ0EXifb8USe54g1xPTZj9aXWXr6pNfNdIlN29I5KcgLCAHCA4NzDC3xyxqmAeYyOhigoos)bIrkc45KkuroXm50WpZ64UVWUGy0iKXqpqmCCK(deJueWZPfYj9aXWXr6pNfNdIlN29I50FvkN2jNwiNyMCsYAD9BcoqGpch8zPU0pjt0CBkzCWQfFtj2f4g3CiEjbsaL8r4Qo83OHsLEJgkXUdwT4BkjhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96JjkRs7fJueW7YsKJBuFLk9tYen3MsrZwSm4m0Jm9W4qhOlXUa34MdXljqcOKpcx1H)gnuQ0B0qjM1SfldEo5pY0toXcDGUKCicta6ZdgL)kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RpMAzvAVyKIaExwICCJ6RKK166NA0Uaod0kJZgyOhigoos)zPoNwiNKSwx)chIRXcGAG)zPoNwiNg3z8cmabOnqiN2DoX0L(jzIMBtPOrM9jmczmKqXRe7cCJBoeVKajGs(iCvh(B0qPsVrdLywJm7tyeYYPLO4vsoeHja95bJYFfmLKdbKf3bHYQxj2SbhwFKxqdIRsL8r4VrdL61NcMYQ0EXifb8USe54g1xjC09TghnWiyJCy)4GEmIqoX8CYnHJXz0qoTqo5qOioAxcgCyCxPFsMO52ukoEhgsw8WvIDbUXnhIxsGeqjFeUQd)nAOuP3OHsm74DYPLw8WvsoeHja95bJYFfmLKdbKf3bHYQxj2SbhwFKxqdIRsL8r4VrdL61NIszvAVyKIaExwICCJ6RKK166NXbRw8nFwQZPfYPTZj9aXWXr6pNfNdIlNy(I5Khm5KkurojzTU(zCWQfFZhh0JreYPDNtBNtkFmLCARMtb1qmYWEchKtB1CsYAD9Z4Gvl(MVWnoS50wzoPKt7Kt7u6NKjAUnLw5OWXiyJCylXUa34MdXljqcOKpcx1H)gnuQ0B0qjMKJcxor2ih2CABLDkjhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96tXtzvAVyKIaExwICCJ6R025KEGy44i9NZIZbXLtmFXCYdMCAHCsYAD9dIGge3ezSICwHpl150o50c5025ehw5qWEKIqoTtPFsMO52uAnoAGrWg5WwIDbUXnhIxsGeqjFeUQd)nAOuP3OHsmzC0qor2ih2CABLDk9Jllu6gUm4yywxKdRCiypsrOKCicta6ZdgL)kykjhcilUdcLvVsSzdoS(iVGgexLk5JWFJgk1RpfMUSkTxmsraVllroUr9vsYAD9Z4Gvl(Mpl1L(jzIMBtPvokCmc2ih2sSzdoS(iVGgexxwYhHR6WFJgkvIDbUXnhIxsGeqP3OHsmjhfUCISroS502E2P0pUSqjnYRriBrLsYHimbOppyu(RGPKCiGS4oiuw9k5J8AeY6tPKpc)nAOuV(u26YQ0EXifb8USe54g1xj9aXWXr6pNfNdIlNy(I5KIIsoPcvKtmton8ZSoU7lSlignczm0dedhhP)aXifb8CAHCspqmCCK(ZzX5G4YjMVyoXeQuoPcvKtWwSmQvd4FbnkIdCJqgdBy4xoTqobBXYOwnG)D2adCWbgVapWqkIq4mupUlNwiN0dedhhP)CwCoiUCI550Fm50c50nrqCFZ6b8GnYH9deJueWl9tYen3MsWWpBgbBKdBj2f4g3CiEjbsaL8r4Qo83OHsLEJgkTF4NDor2ih2CABLDkjhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96tHPuwL2lgPiG3LLih3O(kjzTU(XHasmchW4qhO)4GEmIqoT7CsbtPFsMO52u6qhOzONWb8nLyxGBCZH4LeibuYhHR6WFJgkv6nAOel0b6CYFchW3usoeHja95bJYFfmLKdbKf3bHYQxj2SbhwFKxqdIRsL8r4VrdL61NIkvwL2lgPiG3LLih3O(kjzTU(boBeeyGwzC2adzCyogblboWnczFwQl9tYen3MsWWp7TynyHsSlWnU5q8scKak5JWvD4VrdLk9gnuA)Wp7TynyHCABLDkjhIWeG(8Gr5VcMsYHaYI7Gqz1ReB2GdRpYlObXvPs(i83OHs96t5FzvAVyKIaExwICCJ6RKK166NA0Uaod0kJZgyOhigoos)zPoNwiNg3z8cmabOnqiN2DoX0L(jzIMBtPOrM9jmczmKqXRe7cCJBoeVKajGs(iCvh(B0qPsVrdLywJm7tyeYYPLO4LtBRStj5qeMa0Nhmk)vWusoeqwChekRELyZgCy9rEbniUkvYhH)gnuQxFkmrzvAVyKIaExwICCJ6R04oJxGbiaTbc5eZZjLCAHCACNXlWaeG2aHCI55KsPFsMO52uYzpgbJOrM9jmczLyxGBCZH4LeibuYhHR6WFJgkv6nAOeB2JrKtmRrM9jmczLKdrycqFEWO8xbtj5qazXDqOS6vInBWH1h5f0G4QujFe(B0qPE9PWulRs7fJueW7Ys)KmrZTPu0iZ(egHmgsO4vIDbUXnhIxsGeqjFeUQd)nAOuP3OHsmRrM9jmcz50su8YPT9Stj5qeMa0Nhmk)vWusoeqwChekRELyZgCy9rEbniUkvYhH)gnuQxFEWuwL2lgPiG3LLih3O(kXHvoeShPiu6NKjAUnLwJJgyeSroSLyZgCy9rEbniUUSKpcx1H)gnuQe7cCJBoeVKajGsVrdLyY4OHCISroS502E2P0pUSqjnYRriBrfv(B4YGJHzDroSYHG9ifHsYHimbOppyu(RGPKCiGS4oiuw9k5J8AeY6tPKpc)nAOuV(8OuwL2lgPiG3LL(jzIMBtjy4NnJGnYHTeB2GdRpYlObX1LL8r4Qo83OHsLyxGBCZH4Leibu6nAO0(HF25ezJCyZPT9StPFCzHsAKxJq2IkLKdrycqFEWO8xbtj5qazXDqOS6vYh51iK1NsjFe(B0qPE95XtzvAVyKIaExw6NKjAUnLwJJgyeSroSLyZgCy9rEbniUUSKpcx1H)gnuQe7cCJBoeVKajGsVrdLyY4OHCISroS502m9oL(XLfkPrEnczlQusoeHja95bJYFfmLKdbKf3bHYQxjFKxJqwFkL8r4VrdL61RKkdSowXRl71ca]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20170905.115544, [[dae)jaqifjSjLknkjHoLKGzjjc7ssAykLJrslJO6zsIY0is11uQiBtrs9nLQgNIuoNKiADkvuZtPc3dvI9PijhucwOe6HkQMOKi1fvu2OIe9rIuYjjcZevs3Ke7uHFsKsTue1tHMkc2kr0Ef)fvmyKCyQwmQ6XkzYs1LvTzfXNLuJwIonHxtuMnLUnP2nOFJYWjsoUIuTCkEUuMoW1rKTJqFNifNhvQ1ljsMVKOA)i1rnecoC9dIc9CAQz2Rpe4wAkPLR5Tcy9ottvqApliUmcPabds(27TNH8n19Btt(0QQoTTkBt6brP(s4wrLYbcgmd5tT8Gfwabd2cHmudHGZGoV99umybEHva4oydWmAz)sDtqjGDXYbmtqid(GkSUKUz46hm4W1picygTSFPUji5BV3EgY3u3RUfK8BmsM1BHqabNx(LmfgXRpee(GkS(W1pyazipecod6823tXG4YiKceeWQRTV6IXSDM0aBblWlSca3b926WUdxpOeWUy5aMjiKbFqfwxs3mC9dgC46hSqBDy3HRhK8T3Bpd5BQ7v3cs(ngjZ6TqiGGZl)sMcJ41hccFqfwF46hmGmQSqi4mOZBFpfdwGxyfaUdAftNKOZr71ANdGbUoOeWUy5aMjiKbFqfwxs3mC9dgC46hKRIPts0PPu8ATttrGbUoi5BV3EgY3u3RUfK8BmsM1BHqabNx(LmfgXRpee(GkS(W1pyazi9qi4mOZBFpfdIlJqkqWkst5lGG45C41I3OP2bnL0PP2LMs732agMU6IKXCiGMAQ4cnL8nAQkqtTlnvfPPmFI5TsN3EAQkeSaVWkaChCI11NtRKTKfucyxSCaZeeYGpOcRlPBgU(bdoC9doLwxFAkSKTKfSGPUfe4M6d4iMWfZNyER05Tpi5BV3EgY3u3RUfK8BmsM1BHqabNx(LmfgXRpee(GkS(W1pyazStHqWzqN3(EkgSaVWkaCh8UbuoDsUShucyxSCaZeeYGpOcRlPBgU(bdoC9doZnGYPtYL9GKV9E7ziFtDV6wqYVXizwVfcbeCE5xYuyeV(qq4dQW6dx)GbKXuhcbNbDE77PyqCzesbc2zGQtSU(CALSLSQMRDbSrtnv0ulVb4ae6ttTlnfpPjtQADIoNgjt9RsskAQDPPMcAkGBpeu1kQlbqbSMJH1REOZBFNMAxAkFbeepNdVw8gn1oOPKEWc8cRaWDqRt05WtY0abLa2flhWmbHm4dQW6s6MHRFWGdx)GC1j60ufjzAGGKV9E7ziFtDV6wqYVXizwVfcbeCE5xYuyeV(qq4dQW6dx)GbKX(qi4mOZBFpfdIlJqkqWPGMc42dbvTI6sauaR5yy9Qh6823PP2LMYxabXZ5WRfVrtTdAQDIMQYRCAkGBpeu1kQlbqbSMJH1REOZBFNMAxAkFbeepNdVw8gn1oOPKEWc8cRaWDWBV(qGB5WB9giOeWUy5aMjiKbFqfwxs3mC9dgC46hCM96dbULMQO1BGGKV9E7ziFtDV6wqYVXizwVfcbeCE5xYuyeV(qq4dQW6dx)GbKX0cHGZGoV99umybEHva4oO1j6C4VRdkbSlwoGzcczWhuH1L0ndx)GbhU(b5Qt0PPkExhK8T3Bpd5BQ7v3cs(ngjZ6TqiGGZl)sMcJ41hccFqfwF46hmGmQKHqWzqN3(EkgexgHuGG9ZtAYKQwrDjakG1CmSE1otAGblWlSca3bxLUaYXkQlbqbSoOeWUy5aMjiKbFqfwxs3mC9dgC46hCEPlG0uCvuxcGcyDWcM6wqGBQpGJycx6NN0KjvTI6sauaR5yy9QDM0ads(27TNH8n19QBbj)gJKz9wieqW5LFjtHr86dbHpOcRpC9dgqgQBHqWzqN3(EkgSaVWkaChCv6cihROUeafW6Gsa7ILdyMGqg8bvyDjDZW1pyWHRFW5LUastXvrDjakG10uvuTcbjF792Zq(M6E1TGKFJrYSEleci48YVKPWiE9HGWhuH1hU(bdidv1qi4mOZBFpfdwGxyfaUdADIohEsMgi48YVKPWiE9HGumOcRlPBgU(bdkbSlwoGzcczWhC46hKRorNMQijtdqtvr1keSGPUfuZikG1Crni5BV3EgY3u3RUfK8BmsM1BHqabvyefW6mudQW6dx)GbKHQ8qi4mOZBFpfdIlJqkqqZNyER05TpybEHva4o4eRRpNwjBjl48YVKPWiE9HGumOcRlPBgU(bdkbSlwoGzcczWhC46hCkTU(0uyjBjJMQIQviybtDlOMruaR5IALa4M6d4iMWfZNyER05Tpi5BV3EgY3u3RUfK8BmsM1BHqabvyefW6mudQW6dx)GbeqWk9N4KSGumGe]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20170905.115544, [[da0otaqicH2ebAuQcDkvbVsvczwQsO2LuAyqPJjWYKuEgHGPPkbxdQKSnOs5BiHXPkrNdQKADuPs18Osv3tsL9jPQdcvSqvrpKaMivQuUOQuBKkv8rQujojH0mHkXnLIDQQwkH6POMkbTvQu2RYFHQgmPoSOfJupMstwQUmyZqXNPcJwsonv9AK0SL42KSBe)gYWPIoouPA5e9CHMUkxxqBNk57eIops06PsL08vL0(P4fmHJ)PcgZELag97cOaYLfJ2Djv0fpXH7Urh9ehfWOZODmBLEN34XIHcKry)AydOa7lR9Y2GxIveW(cJzNG1NfV7AEEez)A4wTX4yppIeNW9dMWXVjjDb675y2k9oVXhYHJc0ArOshjss0Of0OF0O7ORftjva(yfYsTvcQ0tIgD9gnDigmTz0cKEsSqBpuMNhrmAbn6hn6ZRaJU(6mACdRr)6RgnDigmT0feQxcJxBOtJ(bJwqJ2IqLosKK2s6kXthkJxReuPNen66nASgTGgTiA00HyW0gpKurfaNGSn0Pr)WyCO9f)r54mAbspjwySOKU3MhsoMGiW4gu3Tu(tfmE8pvWyCIwG0tIfglgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72V2eo(njPlqFphZwP35nwen6ZBP6jom6xF1O7ORftjva(yfYsTvcQ0tIgT7RZODy7JXH2x8hLJXusfGpwHSuhlkP7T5HKJjicmUb1DlL)ubJh)tfm2DkPcmAUczPowmuGmc7xdBafbyhlgIOqPfIt4UXcubwQnixGci3Oh3G6)ubJ3TVimHJFts6c03ZXSv6DEJvjuINePATHsjqoJU(6m6AynAbnAjOspjA0UVoJMoedM2mAbspjwOThkZZJigTGgTfHkDKijTz0cKEsSqReuPNen6xKrthIbtBgTaPNel02dL55reJ291z09qzEEezmo0(I)OCmMsQa8XkKL6yrjDVnpKCmbrGXnOUBP8Nky84FQGXUtjvGrZvilvJ(XGhglgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72)fMWXVjjDb675yCO9f)r5yOakGCzbpDjJ3yrjDVnpKCmbrGXnOUBP8Nky84FQGXVlGcixwm6NLmEJfdfiJW(1Wgqra2XIHikuAH4eUBSavGLAdYfOaYn6XnO(pvW4D7JRMWXVjjDb675y2k9oVX0HyW0c2keeXJWG)Qa8oKqE4JHKoi9ehTHonAbnAr0OPdXGPnJwG0tIfAdDA0cA0QekXtIuT2qPeiNrxFDg9lXTX4q7l(JYXqkVkCpmPcJfL0928qYXeebg3G6ULYFQGXJ)Pcg)oLxfUhMuHXIHcKry)AydOia7yXqefkTqCc3nwGkWsTb5cua5g94gu)Nky8U9XTjC8BssxG(EoMTsVZBSkHs8KivRnukbYz01xNrheqHr)6RgTiA0P88ys71gfjukEId8QekXtIuTajPlq3Of0OvjuINePATHsjqoJU(6mACDTX4q7l(JYXqkVk8XkKL6yrjDVnpKCmbrGXnOUBP8Nky84FQGXVt5vz0CfYsDSyOaze2Vg2akcWowmerHsleNWDJfOcSuBqUafqUrpUb1)PcgVBFkMWXVjjDb675y2k9oVXJXH2x8hLJJhsQOcGtqowus3BZdjhtqeyCdQ7wk)Pcgp(NkymFiPIkaob5yXqbYiSFnSbueGDSyiIcLwioH7glqfyP2GCbkGCJECdQ)tfmE3(VCch)MK0fOVNJzR078gpghAFXFuoU4X9qFhVkDOs8h6a1yrjDVnpKCmbrGXnOUBP8Nky84FQGX4Ih3d9DJUjDOsJwi6a1yXqbYiSFnSbueGDSyiIcLwioH7glqfyP2GCbkGCJECdQ)tfmE3(46jC8BssxG(EoMTsVZBmDigmTorIeK4ryWFvaEvcL4jrQ2qNgTGgnDigmTXdjvubWjiBdDA0cA0P98Ua8abuEiA0U3OfHX4q7l(JYXfVJQJ4joWtJk3yrjDVnpKCmbrGXnOUBP8Nky84FQGX4I3r1r8ehg9tu5glgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72pa7eo(njPlqFphZwP35nUJUwmLub4Jvil1wjOspjA01B02mE4pVcmAbn6hnAlcv6irsWlH0Eg9RVA00HyW0Mrlq6jXcTHon6hgJdTV4pkhxsxjE6qz8glkP7T5HKJjicmUb1DlL)ubJh)tfmgxsxPr)mugVXIHcKry)AydOia7yXqefkTqCc3nwGkWsTb5cua5g94gu)Nky8U9dcMWXVjjDb675y2k9oVXpA0QekXtIuT2qPeiNrxFDgDnSgTGgnDigmTqbua5YcEmiBySn0Pr)GrlOr)OrlbmsiwL0fWOFymo0(I)OCmMsQa8XkKL6yrjDVnpKCmbrGXnOUBP8Nky84FQGXUtjvGrZvilvJ(XApmghPJ44lLoGdVhtDsaJeIvjDbglgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72pO2eo(njPlqFphZwP35nwLqjEsKQ1gkLa5m66RZOdccm6xF1OfrJoLNhtAV2OiHsXtCGxLqjEsKQfijDb6gTGgTkHs8KivRnukbYz01xNr)sCZOF9vJgW9qVtNqVnQqLoi9eh4RGuEgTGgnG7HENoHE7vb47Gf8UazepDbH64DM2ZOf0OvjuINePATHsjqoJUEJMcSgTGg9LfGCTjMdKXkKLAlqs6c0hJdTV4pkhdP8QWhRqwQJfL0928qYXeebg3G6ULYFQGXJ)Pcg)oLxLrZvilvJ(XGhglgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72pqeMWXVjjDb675y2k9oVX0HyW0kHiIKelG)qhOALGk9KOr7EJoaRr)6Rg9JgnDigmTsiIijXc4p0bQwjOspjA0U3OF0OPdXGPnJwG0tIfA7HY88iIr)ImAlcv6irsAZOfi9KyHwjOspjA0py0cA0weQ0rIK0Mrlq6jXcTsqLEs0ODVrhGRm6hgJdTV4pkhFOdu4vz8ajLJfL0928qYXeebg3G6ULYFQGXJ)PcgleDGYOBY4bskhlgkqgH9RHnGIaSJfdruO0cXjC3ybQal1gKlqbKB0JBq9FQGX72p4fMWXVjjDb675y2k9oVXP98Ua8abuEiA01B0bgTGgDApVlapqaLhIgD9gDWyCO9f)r54s6kXtdPASOKU3MhsoMGiW4gu3Tu(tfmE8pvWyCjDLg9tivJfdfiJW(1Wgqra2XIHikuAH4eUBSavGLAdYfOaYn6XnO(pvW4D7hGRMWXVjjDb675y2k9oVX0HyW06ejsqIhHb)vb4vjuINePAdDA0cA0P98Ua8abuEiA0U3OfHX4q7l(JYXfVJQJ4joWtJk3yrjDVnpKCmbrGXnOUBP8Nky84FQGX4I3r1r8ehg9tu5m6hdEySyOaze2Vg2akcWowmerHsleNWDJfOcSuBqUafqUrpUb1)PcgVB)aCBch)MK0fOVNJzR078gN2Z7cWdeq5HOrxVrhy0cA0P98Ua8abuEiA01B0bJXH2x8hLJTvPNGV4DuDepXXyrjDVnpKCmbrGXnOUBP8Nky84FQGXcuLEIrJlEhvhXtCmwmuGmc7xdBafbyhlgIOqPfIt4UXcubwQnixGci3Oh3G6)ubJ3TFaft443KKUa99Cmo0(I)OCCX7O6iEId80OYnwus3BZdjhtqeyCdQ7wk)Pcgp(NkymU4DuDepXHr)evoJ(XApmwmuGmc7xdBafbyhlgIOqPfIt4UXcubwQnixGci3Oh3G6)ubJ3TFWlNWXVjjDb675y2k9oVXsaJeIvjDbgJdTV4pkhJPKkaFSczPowGkWsTb5cua52ZXnOUBP8Nky8yrjDVnpKCmbrGX)ubJDNsQaJMRqwQg9JIWdJXr6iowHC5joQl4fFP0bC49yQtcyKqSkPlWyXqbYiSFnSbueGDSyiIcLwioH7g3GC5jo2pyCdQ)tfmE3(b46jC8BssxG(EoghAFXFuogs5vHpwHSuhlqfyP2GCbkGC754gu3Tu(tfmESOKU3MhsoMGiW4FQGXVt5vz0CfYs1OFS2dJXr6iowHC5joQlySyOaze2Vg2akcWowmerHsleNWDJBqU8eh7hmUb1)PcgVB)AyNWXVjjDb675yCO9f)r5ymLub4Jvil1XcubwQnixGci3EoUb1DlL)ubJhlkP7T5HKJjicm(NkyS7usfy0CfYs1OF8fEymoshXXkKlpXrDbJfdfiJW(1Wgqra2XIHikuAH4eUBCdYLN4y)GXnO(pvW4D7g7UbyYWYTN72a]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170905.115544, [[dieanaqisuyrOOSjLuAuOO6uOiTlOQHbIJbslJeEguQAAkPW1GsLTrIsFdL04usLZbLISoOOMhkIUNsQAFKO6GsIfseEOK0evsrDrIQncLsnsOuuNKiAMOiCtLyNG6NqPKHcLcwkk8uKPsKUkjkAReL(kuk0Ef)vszWu6Wkwmj9yjMSsDzvBMO4ZOuJgkCAcVgLy2O62KA3a)gYWvswov9CkMUuxhQSDOKVdf58sQwVskY8jr2pvoqJ0qR5lZGJ3rIq0QxedxSMMwGabwHYQieJZ)yEGvabkRqwNI1Hh66GG9qwJquXlw1HcvP0ceWePbgAKgsoyu5Fh1quXlw1HAeB28JVGq8nctaJZUwNL5oBpE2VXJXhEJb(vL2zzsNvb25SkPKZ2c9DwL7SqWJDqG4Smnufvbx01dHX9iHrhssWwuMg5dbqGhAbTLD8WJ(Hcbp6hcB(EKWOdX48pMhyfqGYkuiHyCdcNVCtKMouvmEHLfewxFqh1qlOn8OFO0bwrKgsoyu5FhjcrfVyvhQrSzZp(vOwGagNDTolZD2ccX3imbWlJW)ANF9b9WX7VEeaJZQCNvX6G4SkPKZ2JN9B8Tq)AnQ2wCNLjxVZQSqCwMgQIQGl66HwHAbcessWwuMg5dbqGhAbTLD8WJ(Hcbp6hcBa1ceieJZ)yEGvabkRqHeIXniC(YnrA6qvX4fwwqyD9bDudTG2WJ(HshySpsdjhmQ8VJeHOIxSQd1i2S5hVa037XTQnHQOk4IUEimja7Agm(4djjylktJ8HaiWdTG2YoE4r)qHGh9dHnkaBNLW4JpeJZ)yEGvabkRqHeIXniC(YnrA6qvX4fwwqyD9bDudTG2WJ(Hsh41isdjhmQ8VJeHOIxSQdPItgzW7Vbbgq51AuFnE)1JayCwM0zveQIQGl66HAuFDn9y67RhssWwuMg5dbqGhAbTLD8WJ(Hcbp6hskQV2zxgtFF9qmo)J5bwbeOScfsig3GW5l3ePPdvfJxyzbH11h0rn0cAdp6hkDGXUinKCWOY)oseIkEXQouJyZMF8feIVrycycvrvWfD9qYi8V25xFqp8qsc2IY0iFiac8qlOTSJhE0pui4r)qyBH)oRC(1h0dpeJZ)yEGvabkRqHeIXniC(YnrA6qvX4fwwqyD9bDudTG2WJ(HshyLnsdjhmQ8VJeHOIxSQd1i2S5hFbH4BeMaMqvufCrxpKPrEDTZV(GE4HKeSfLPr(qae4HwqBzhp8OFOqWJ(HOg51oRC(1h0dpeJZ)yEGvabkRqHeIXniC(YnrA6qvX4fwwqyD9bDudTG2WJ(HshywJ0qYbJk)7iriQ4fR6qnInB(Xxqi(gHjGjufvbx01dD(1h0dVMEm991djjylktJ8HaiWdTG2YoE4r)qHGh9djNF9b9WD2LX03xpeJZ)yEGvabkRqHeIXniC(YnrA6qvX4fwwqyD9bDudTG2WJ(Hsh41fPHKdgv(3rIqvufCrxpeoZRj6RnHKeSfLPr(qae4HwqBzhp8OFOqWJ(HuMM7Ss2xBcX48pMhyfqGYkuiHyCdcNVCtKMouvmEHLfewxFqh1qlOn8OFO0bgBksdjhmQ8VJeHOIxSQd1i2S5hFbH4BeMagNDTolZDwLHZ2d)Gg)ykhShq54pyu5F7SkPKZQItgzWpMYb7buoECRCwLuYzlieFJWea)ykhShq549xpcGXzvUZIDqCwMgQIQGl66Hu5i0UMm481djjylktJ8HaiWdTG2YoE4r)qHGh9djbhH2ol2gNVEigN)X8aRacuwHcjeJBq48LBI00HQIXlSSGW66d6OgAbTHh9dLoWqHePHKdgv(3rIquXlw1HAeB28JVGq8nctaJZUwNL5oRYWz7HFqJFmLd2dOC8hmQ8VDwLuYzvXjJm4ht5G9akhpUvoltdvrvWfD9qQ3BUNfbGDijbBrzAKpeabEOf0w2Xdp6hke8OFijU3Cplca7qmo)J5bwbeOScfsig3GW5l3ePPdvfJxyzbH11h0rn0cAdp6hkDGHcnsdjhmQ8VJeHOIxSQdnLwG1RDW1IBCwL7SkC216Sm3zNslW61o4AXnoRYDwfoRsk5StPfy9AhCT4gNv5oRcNLPHQOk4IUEipoqTP0ceOgxy6qvX4fwwqyD9bDudTG2YoE4r)qHGh9dXahWzRuAbc4SmHW0HQ4zBcbg9xpZiHUQZkNF9b9WXSZwbBjNzHyC(hZdSciqzfkKqmUbHZxUjsthssWwuMg5dbqGhAbTHh9drcDvNvo)6d6HJzNTc2sE6advrKgsoyu5FhjcrfVyvhQh(bn(XuoypGYXFWOY)2zvsjNLFSo3zzsNfkeiHQOk4IUEipoqTP0ceOgxy6qvX4fwwqyD9bDudTG2YoE4r)qHGh9dXahWzRuAbc4SmHW0olZHY0qv8SnHaJ(RNzKqx1zLZV(GE4y2zncaB(D2XuywigN)X8aRacuwHcjeJBq48LBI00HKeSfLPr(qae4HwqB4r)qKqx1zLZV(GE4y2zncaB(D2XushyOyFKgsoyu5FhjcrfVyvhQh(bnEr5YGZxh)bJk)7qvufCrxpKhhO2uAbcuJlmDOQy8clliSU(GoQHwqBzhp8OFOqWJ(HyGd4SvkTabCwMqyANL5kyAOkE2MqGr)1ZmsOR6SY5xFqpCm7SgbGn)oRqgMfIX5FmpWkGaLvOqcX4geoF5MinDijbBrzAKpeabEOf0gE0pej0vDw58RpOhoMDwJaWMFNvit6adDnI0qYbJk)7iriQ4fR6q9WpOXZfSXObca7AE0g)bJk)7qvufCrxpKhhO2uAbcuJlmDOQy8clliSU(GoQHwqBzhp8OFOqWJ(HyGd4SvkTabCwMqyANL5yptdvXZ2ecm6VEMrcDvNvo)6d6HJzN1iaS53z5EMfIX5FmpWkGaLvOqcX4geoF5MinDijbBrzAKpeabEOf0gE0pej0vDw58RpOhoMDwJaWMFNL7tNoe8OFisOR6SY5xFqpCm7S7lZGJ3Pta]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170905.115544, [[datucaGErq7se1RPeZwQUjP62e2jv2lA3eTFiYWiLFlzOqLAWqsdxkoOO4yK0cfjlfclMelNQEOO0tbpwPwhujtKsQMkLAYqz6cxuu1LvDDrLTcrTzrGTdP8CLmnkjoSILjLEMi0OHeFwe5KqfJds1PP48qvFtK6VusABuszQsBcw)jyY1dMIGBeNayezrc189lUmMoUqc1g)3LqzcciE)Z601QPMwd9w0twfDTe1Scby7nnbbcz2HPKlAtNkTjKxok9JXueGT30eeIkPK6p5MkmLCriJIPBc8eAQWusc4iXm7jkpbzjpb9cd5X7gXjqWnIta3vykjbeV)zD6A1utRQraXxvo)(lAZGqwu(2IEH2fxguHGEH5gXjWGUwAtiVCu6hJPiKrX0nbEcrfxyvXSI7XtahjMzpr5jil5jOxyipE3iobcUrCc2vCbsOQpR4E8eq8(N1PRvtnTQgbeFv587VOndczr5Bl6fAxCzqfc6fMBeNad6sK2eYlhL(XykczumDtGNWkkVWYFZ9eWrIz2tuEcYsEc6fgYJ3nItGGBeNaeLxy5V5EciE)Z601QPMwvJaIVQC(9x0MbHSO8Tf9cTlUmOcb9cZnItGbdcqZ3MPBs4eMssxR1Azqc]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170905.115544, [[de0nsaqiOOytuQAuKQCksvTkvrjELQOKMfrPk3IOuXUuvggsCmkzzkONrPIPPkQ6AQIkBJOu(gsY4GIQZbfLwhrPQMhukUNQi7dkvhekSqvHhsumrvrPUiuYgvffNKuPzsPs3uq7eQwkr1trnvKYwjvSxP)QqdwuhwPftKhtvtwrxgSzvvFwGrtkNMWRrQMnvUnf7gXVHmCf44qP0Yj55cnDvUUQ02Pu(ouKZJKA9eLknFIs2VixRsRm(AGYSWitkJLdma5wNSFkhfKahKYovz2RedUYL5bGxSoHS7EceP4dLTHLLdoyJqXhsXIkky(qm)ZcZPyhkpFz5WoPMMWaLNO773TgymQH80)uGzfKOSJEtq69))73TgymQH80)MVQ9eiYZcLp7OFzm8NarILwXTkTYyrwjhm7JYSxjgCLXmP8j80fKGuwwYkLNO773TgymQH80)uGzfKykJnpLYb(zzmKeoXrD5F3AGXOgYtVSUKPWVhsvMGiq5q0uNvHVgOCz81aLFg3AGuM1qE6LLdoyJqXhsXIklkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7v8HLwzSiRKdM9rzmKeoXrDzWbgGCRBuYTXRSUKPWVhsvMGiq5q0uNvHVgOCz81aLXYbgGCRlLF424vwo4GncfFiflQSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXTtPvglYk5GzFuM9kXGRS07))h41qqCe9pEAWyGc2Bm(sMGsqc(EhugdjHtCuxgw1PHTVlDOSUKPWVhsvMGiq5q0uNvHVgOCz81aLXAvNg2(U0HYYbhSrO4dPyrLfLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9k(ZxALXISsoy2hLzVsm4kBwWfpfY85FvkGCPm2FkLTSOkLLLSszmtkVQt8V(7lIjW5eKGrZcU4PqMpGSsoyMY2NYMfCXtHmF(xLcixkJ9Nszm7WYyijCIJ6YWQoTXOgYtVSUKPWVhsvMGiq5q0uNvHVgOCz81aLXAvNwkZAip9YYbhSrO4dPyrLfLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9k(ZvALXISsoy2hLXqs4eh1LJhszOdWaqvwxYu43dPktqeOCiAQZQWxduUm(AGY8Hug6amauLLdoyJqXhsXIklkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vCzR0kJfzLCWSpkZELyWvUmgscN4OUStGTVI5Ozdm74HoWuwxYu43dPktqeOCiAQZQWxduUm(AGY2vGTVIzkhUbMnLPHoWuwo4GncfFiflQSOuwoerVkpelTELLrd80dr2adqUkvoenXxduUxXPQ0kJfzLCWSpkZELyWvEIUVF3AGXOgYt)tbMvqIPm2tz)gVXtyGu2(u2JqUjctKrfS(RmgscN4OUSBTTJsVQ4vwxYu43dPktqeOCiAQZQWxduUm(AGY2DTTP8Jxv8klhCWgHIpKIfvwuklhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4yEPvglYk5GzFuM9kXGRSEPSzbx8uiZN)vPaYLYy)PuEiLu2(uw69))dCGbi36g)r(3437Guw)u2(uwVuwb)kiQTsoiL1VmgscN4OU8VBnWyud5PxwgnWtpezdma5Qu5q0uNvHVgOCz81aLFg3AGuM1qE6PSEw6xgdvqS8TQa4gf)pPGFfe1wjhuwo4GncfFiflQSOuwoerVkpelTEL1Lmf(9qQYeebkhIM4Rbk3R4y2sRmwKvYbZ(Om7vIbxzZcU4PqMp)RsbKlLX(tPSLLvkllzLYyMuEvN4F93xetGZjibJMfCXtHmFazLCWmLTpLnl4INcz(8VkfqUug7pLYyUSLYYswPmGTVIbdG5x0GCtqjibJAWQUu2(ugW2xXGbW870GXj4bHnqfhLCi0CCW6Vu2(u2SGlEkK5Z)Qua5szSNYurjLTpLV1bK7B)pqf1qE6FazLCWSmgscN4OUmSQtBmQH80lRlzk87HuLjicuoen1zv4RbkxgFnqzSw1PLYSgYtpL1Zs)YYbhSrO4dPyrLfLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kUfLsRmwKvYbZ(Om7vIbxzP3))pferKL4HXdDG5tbMvqIPm2KYwuszzjRuwVuw69))tbrezjEy8qhy(uGzfKykJnPSEPS07))3g9azUep8nFv7jqKu(znL9iKBIWe5BJEGmxIh(uGzfKykRFkBFk7ri3eHjY3g9azUep8PaZkiXugBszRNlL1VmgscN4OU8HoWmA24bkQlRlzk87HuLjicuoen1zv4RbkxgFnqzAOdmPC4gpqrDz5Gd2iu8HuSOYIsz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef3YQ0kJfzLCWSpkZELyWvwVuw69))BactGAe9pEAWOzbx8uiZ37Gu2(uE9NWgmceWiGykJnPSDsz9tz7tz9s5ji9())5ebAhrqcgvO53eHjskRFzmKeoXrDzNiq7icsWOeYDLLrd80dr2adqUkvoen1zv4RbkxgFnqz7kc0oIGeKYpqURmgQGy5BvbWnk(FAcsV))ForG2reKGrfA(nryIuwo4GncfFiflQSOuwoerVkpelTEL1Lmf(9qQYeebkhIM4Rbk3R4wdlTYyrwjhm7JYSxjgCLLE)))gGWeOgr)JNgmAwWfpfY89oiLTpLx)jSbJabmciMYytkBNYyijCIJ6YorG2reKGrjK7kRlzk87HuLjicuoen1zv4RbkxgFnqz7kc0oIGeKYpqUlL1Zs)YYbhSrO4dPyrLfLYYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kULDkTYyrwjhm7JYSxjgCL1lLx)jSbJabmciMYypLTsz7t51FcBWiqaJaIPm2tzRuw)u2(uwVuEcsV))ForG2reKGrfA(nryIKY6xgdjHtCux2RTcYOteODebjOSmAGNEiYgyaYvPYHOPoRcFnq5Y4RbklJ2kiPSDfbAhrqckJHkiw(wvaCJI)NMG07))NteODebjyuHMFteMiLLdoyJqXhsXIklkLLdr0RYdXsRxzDjtHFpKQmbrGYHOj(AGY9kU1ZxALXISsoy2hLzVsm4kV(tydgbcyeqmLXEkBLY2NYR)e2GrGagbetzSNYwLXqs4eh1L9ARGm6ebAhrqckRlzk87HuLjicuoen1zv4RbkxgFnqzz0wbjLTRiq7icsqkRNL(LLdoyJqXhsXIklkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vCRNR0kJfzLCWSpkZELyWvEcsV))ForG2reKGrfA(nryIugdjHtCux2jc0oIGemkHCxzz0ap9qKnWaKRsLdrtDwf(AGYLXxdu2UIaTJiibP8dK7sz9gQFzmubXY3QcGBu8)0eKE)))CIaTJiibJk08BIWePSCWbBek(qkwuzrPSCiIEvEiwA9kRlzk87HuLjicuoenXxduUxXTKTsRmwKvYbZ(OmgscN4OUSteODebjyuc5UY6sMc)EivzcIaLdrtDwf(AGYLXxdu2UIaTJiibP8dK7sz9SJ(LLdoyJqXhsXIklkLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vClQkTYyrwjhm7JYSxjgCLvWVcIARKdkJHKWjoQl)7wdmg1qE6LLrd80dr2adqU(OCiAQZQWxduUSUKPWVhsvMGiqz81aLFg3AGuM1qE6PSEd1VmgQGyzdYMGe8KLS3TQa4gf)pPGFfe1wjhuwo4GncfFiflQSOuwoerVkpelTELdr2eKGIBvoenXxduUxXTW8sRmwKvYbZ(OmgscN4OUmSQtBmQH80llJg4PhISbgGC9r5q0uNvHVgOCzDjtHFpKQmbrGY4RbkJ1QoTuM1qE6PSEd1VmgQGyzdYMGe8Kvz5Gd2iu8HuSOYIsz5qe9Q8qS06voeztqckUv5q0eFnq5Ef3cZwALXISsoy2hLzVsm4kFRkaUVPiElXdPm2tzzRmgscN4OU8VBnWyud5PxwgnWtpezdma56JYHOPoRcFnq5Y6sMc)EivzcIaLXxdu(zCRbszwd5PNY6zh9lJHkiw2GSjibpzvwo4GncfFiflQSOuwoerVkpelTELdr2eKGIBvoenXxduUxVYpB4FFDxF0Rfa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170905.115544, [[deKyuaqieQAtkbJsj0PuIAvQkuVsvHOzPQq4wQkKAxkvddbhJeltaptvrnneQ01qOITPQcFtvvJtvfDoevL1PQqY8uvj3tjY(qOCqeYcvkEiIYeruv5IQkTrvvQtssmtev5McANQYsjINIAQiYwjjTxP)cjdwKdRyXe1JPYKH4YGnRK(mrA0uQttXRHuZwu3Mu7MWVHA4KuhxvblhPNtvtxLRtjBxG(UQICELsRhrvvZhrL9l0vPKk)gnuMnAYIPVzqdIBYFuXK3iKMHyYSwMDuJ6RCzwn4mt2q(pNbl6lWpcuwcKHXd9fGGYFc)mWp3v(jHptG4wwcmiBjz0qze8TVMhnGYBJDO3PGEmc)h9IiGS166(AE0akVn2HEhXIoNbl(yc7FE5Ye5odw4lP(ukPYFfJCgq6MYSJAuFLj(y6mo0gH0yICKlMqW3(AE0akVn2HENc6Xi8X0VwkMK6qktKSjBUTLxZJgq5TXo0LvrGyCZHPLfybuoeJO6qFJgkx(nAO8VZJgIj2g7qxwcKHXd9fGGYFfcLLaESf1b(sQxzYSbh6qCqqdIRYLdXiVrdL71xGsQ8xXiNbKUPm7Og1xzzR11DWzJbpk8kQZgqjLcZHYBjqaQriD3sDmTqmPhi7pkwV7SOuqCXeXwkM(5pktKSjBUTLHHE2FWAqdLvrGyCZHPLfybuoeJO6qFJgkx(nAO83HE2FWAqdLLazy8qFbiO8xHqzjGhBrDGVK6vMmBWHoehe0G4QC5qmYB0q5E995sQ8xXiNbKUPm7Og1xzzR11DJdwTOB3Tuhtlet6bY(JI17olkfexmrSLIjffLyAHyI4JjzR119X7abYiCWUL6YejBYMBB5vk2FO82yh6YQiqmU5W0YcSakhIruDOVrdLl)gnu(3uS)Ij2g7qxwcKHXd9fGGYFfcLLaESf1b(sQxzYSbh6qCqqdIRYLdXiVrdL71hXTKk)vmYzaPBktKSjBUTLHmObXnzuY5XFLvrGyCZHPLfybuoeJO6qFJgkx(nAO83mObXn5yAtE8xzjqggp0xack)viuwc4Xwuh4lPELjZgCOdXbbniUkxoeJ8gnuUxFeNsQ8xXiNbKUPm7Og1xz9az)rX6DNfLcIlMi2sXKIY)yICKlMi(yAONzDC3U)tqoBesrPhi7pkwVdIrodiX0cXKEGS)Oy9UZIsbXfteBPyI8fOmrYMS52wgg6zJYBJDOlRIaX4MdtllWcOCigr1H(gnuU8B0q5Vd9SJj2g7qxwcKHXd9fGGYFfcLLaESf1b(sQxzYSbh6qCqqdIRYLdXiVrdL713pkPYFfJCgq6MYejBYMBBz)HPA0aOgOLvrGyCZHPLfybuoeJO6qFJgkx(nAOmFyQgnaQbAzjqggp0xack)viuwc4Xwuh4lPELjZgCOdXbbniUkxoeJ8gnuUxF)lPYFfJCgq6MYSJAuFLxmM0dK9hfR3DwukiUy6xlftkeuIPfIPHEM1XD7(pb5SrifLEGS)Oy9oig5mGetKJCXeXhtd9mRJ729FcYzJqkk9az)rX6DqmYzajMwiM0dK9hfR3DwukiUy6xlft))rmTCmTqmr8XKS166(4DGazeoy3sDzIKnzZTTSXbRw0TLvrGyCZHPLfybuoeJO6qFJgkx(nAOSkoy1IUTSeidJh6labL)keklb8ylQd8LuVYKzdo0H4GGgexLlhIrEJgk3RVFwsL)kg5mG0nLzh1O(kxMizt2CBlNnFWYGGsps1dQdFGUSkceJBomTSalGYHyevh6B0q5YVrdLjpZhSmiXu4ivpXej8b6YsGmmEOVaeu(RqOSeWJTOoWxs9ktMn4qhIdcAqCvUCig5nAOCV(iFLu5VIrodiDtz2rnQVYYwRR7QXFcOOWROoBaLEGS)Oy9UL6yAHys2ADD3FyQgnaQb6UL6yAHyACNjiGceG2a(y6xX0NltKSjBUTLZgP2NWiKIsgNVYQiqmU5W0YcSakhIruDOVrdLl)gnuM8msTpHrinM2GZxzjqggp0xack)viuwc4Xwuh4lPELjZgCOdXbbniUkxoeJ8gnuUxFkekPYFfJCgq6MYSJAuFLrW3(AE0akVn2HENc6Xi8XeXIj34puNrdX0cXKdJZi4pjqrHXDLjs2Kn32Y5j4Gs2I6VYQiqmU5W0YcSakhIruDOVrdLl)gnuM8MGtmTXI6VYsGmmEOVaeu(RqOSeWJTOoWxs9ktMn4qhIdcAqCvUCig5nAOCV(uukPYFfJCgq6MYSJAuFLLTwx3noy1IUD3sDmTqmTymTymPhi7pkwV7SOuqCXeXwkMcqiMwoMih5IjzR11DJdwTOB3PGEmcFm9RyAXyszN4etFCm5vd5mk7XFqm9XXKS166UXbRw0T7(BCOJPpYysjMwoMwUmrYMS52wELI9hkVn2HUSkceJBomTSalGYHyevh6B0q5YVrdL)nf7VyITXo0X0IklxwcKHXd9fGGYFfcLLaESf1b(sQxzYSbh6qCqqdIRYLdXiVrdL71NsGsQ8xXiNbKUPm7Og1x5fJj9az)rX6DNfLcIlMi2sXuacX0cXKS166oKbniUjJAf7S87wQJPLJPfIPfJjkSsbV9iNHyA5YejBYMBB518ObuEBSdDzYSbh6qCqqdIRYLdXiQo03OHYLFJgk)78OHyITXo0X0IklxMiQuF5BOsHdLzDjkSsbV9iNHYsGmmEOVaeu(RqOSeWJTOoWxs9kRIaX4MdtllWcOCig5nAOCV(u(Cjv(RyKZas3uMDuJ6RSS166UXbRw0T7wQltKSjBUTLxPy)HYBJDOltMn4qhIdcAqCDt5qmIQd9nAOCzveig3CyAzbwaLFJgk)Bk2FXeBJDOJPfdSCzIOs9L14GgH0LuklbYW4H(cqq5VcHYsap2I6aFj1RCioOriTpLYHyK3OHY96tH4wsL)kg5mG0nLzh1O(kRhi7pkwV7SOuqCXeXwkMuuuIjYrUyI4JPHEM1XD7(pb5SrifLEGS)Oy9oig5mGetlet6bY(JI17olkfexmrSLIPF(JyICKlMGpyzuRgq29ACgbOgHuu2WqVyAHyc(GLrTAaz)SbuiGdmbbQhLCgJrqPECxmTqmPhi7pkwV7SOuqCXeXIP)eIPfIPBYG42N1dOEBSd9oig5mGuMizt2CBldd9Sr5TXo0LvrGyCZHPLfybuoeJO6qFJgkx(nAO83HE2XeBJDOJPfvwUSeidJh6labL)keklb8ylQd8LuVYKzdo0H4GGgexLlhIrEJgk3RpfItjv(RyKZas3uMDuJ6RSS166of8yXiCaQdFGENc6Xi8X0VIjfcLjs2Kn32Yh(ank94pGUTSkceJBomTSalGYHyevh6B0q5YVrdLjHpqhtHJ)a62YsGmmEOVaeu(RqOSeWJTOoWxs9ktMn4qhIdcAqCvUCig5nAOCV(u(rjv(RyKZas3uMDuJ6RSS166o4SXGhfEf1zdOKsH5q5Teia1iKUBPUmrYMS52wgg6z)bRbnuwfbIXnhMwwGfq5qmIQd9nAOC53OHYFh6z)bRbnetlQSCzjqggp0xack)viuwc4Xwuh4lPELjZgCOdXbbniUkxoeJ8gnuUxFk)lPYFfJCgq6MYSJAuFLLTwx3vJ)eqrHxrD2ak9az)rX6Dl1X0cX04otqafiaTb8X0VIPpxMizt2CBlNnsTpHrifLmoFLvrGyCZHPLfybuoeJO6qFJgkx(nAOm5zKAFcJqAmTbNVyArLLllbYW4H(cqq5VcHYsap2I6aFj1Rmz2GdDioiObXv5YHyK3OHY96t5NLu5VIrodiDtz2rnQVYJ7mbbuGa0gWhtelMuIPfIPXDMGakqaAd4JjIftkLjs2Kn32Yo7XiqLnsTpHriTSkceJBomTSalGYHyevh6B0q5YVrdLjZEmIyI8msTpHriTSeidJh6labL)keklb8ylQd8LuVYKzdo0H4GGgexLlhIrEJgk3RpfYxjv(RyKZas3uMizt2CBlNnsTpHrifLmoFLvrGyCZHPLfybuoeJO6qFJgkx(nAOm5zKAFcJqAmTbNVyAXalxwcKHXd9fGGYFfcLLaESf1b(sQxzYSbh6qCqqdIRYLdXiVrdL71xacLu5VIrodiDtz2rnQVYuyLcE7rodLjs2Kn32YR5rdO82yh6YKzdo0H4GGgex3uoeJO6qFJgkxwfbIXnhMwwGfq53OHY)opAiMyBSdDmTyGLltevQVSgh0iKUKYhXnuPWHYSUefwPG3EKZqzjqggp0xack)viuwc4Xwuh4lPELdXbncP9PuoeJ8gnuUxFbukPYFfJCgq6MYejBYMBBzyONnkVn2HUmz2GdDioiObX1nLdXiQo03OHYLvrGyCZHPLfybu(nAO83HE2XeBJDOJPfdSCzIOs9L14GgH0LuklbYW4H(cqq5VcHYsap2I6aFj1RCioOriTpLYHyK3OHY96lqGsQ8xXiNbKUPm7Og1x5BOsHBhX4Vr4GyIyX0pktKSjBUTLxZJgq5TXo0LjZgCOdXbbniUUPCigr1H(gnuUSkceJBomTSalGYVrdL)DE0qmX2yh6yAXpVCzIOs9L14GgH0LuklbYW4H(cqq5VcHYsap2I6aFj1RCioOriTpLYHyK3OHY96vM8dwhR81n9Ab]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170905.115544, [[deeokaqijvytkunkIuofrOvrHIMffk1TOqj7IOAykLJjHLjP8muuAAeP6AsQOTjPk9nLQgNKQ6CuOI1rHknpfkDpuuTpjvYbLOwOe5HkvMifQYfviBusL6KejZKi4Mu0ov0pPqvTuu4PitfI2kr0Ef)fsgmQ6WuTyu6XkzYs1LvTzk4Zky0sYPj8AIYSP0Tjz3G(nudNc54kuSCs9CPmDGRdHTdP(okkopkY6PqH5lPk2pQCkcYqtx9qKqTJJFK9QdbU14YXx24pkeT0cJaHcz8UbhHfKsHyC792ZS2wX(T6xR(YlQ)gZUj9qmU3zcPq9qDmqUbRRoQwfEjtU(kxaBglP1plcdgKBW6QJQvHxYK3rODGadnMBYzwjgQ8ciWWwqMzrqgAe0zTVNsHkZkScatHAaSwj73ORdjfSlwoaRdbXWhYe3L01tx9qHMU6HiawRK9B01HyC792ZS2wX(ITqmEdJqVElidi0UQVKzIrF1HGWgYe3NU6HciZAbzOrqN1(EkfIwAHrGqa8WG9YxySTJzgyluzwHvaykK3wh2D46HKc2flhG1HGy4dzI7s66PREOqtx9qLBRd7oC9qmU9E7zwBRyFXwigVHrOxVfKbeAx1xYmXOV6qqydzI7tx9qbKjZgKHgbDw77PuOYScRaWuiRymieDukFq5OayWvHKc2flhG1HGy4dzI7s66PREOqtx9qsqmgeIohVPpOCoEKyWvHyC792ZS2wX(ITqmEdJqVElidi0UQVKzIrF1HGWgYe3NU6HcitPhKHgbDw77PuiAPfgbcjnoEFbeOpQdVs8gh)y54Loh)4C8k)2gqJvYxi06dbC81fZ54RTXXlro(X54LghV(g0Vv5S2ZXlXqLzfwbGPqgSU6OAv4LSq7Q(sMjg9vhccBitCxsxpD1dfA6QhQUTU6C8ufEjluz9qleW1dhGsyG56Bq)wLZAFig3EV9mRTvSVyleJ3Wi0R3cYacjfSlwoaRdbXWhYe3NU6HciZ6midnc6S23tPqLzfwbGPq31GQXGWL9qsb7ILdW6qqm8HmXDjD90vpuOPREOrUgungeUShIXT3BpZABf7l2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmR3Gm0iOZAFpLcrlTWiqOogi3G1vhvRcVKjxFLlGno(6IJF5nakGqDo(X54zryWGCRJ2r1qOhUCegXXpohFDWXdC7Ha5wXqfakGdO04U8dDw77C8JZX7lGa9rD4vI344hlhV0dvMvyfaMczD0okwe6giKuWUy5aSoeedFitCxsxpD1dfA6QhscoANJVecDdeIXT3BpZABf7l2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGm3hKHgbDw77PuiAPfgbcvhC8a3EiqUvmubGc4aknUl)qN1(oh)4C8(ciqFuhEL4no(XYXxNC81t9WXdC7Ha5wXqfakGdO04U8dDw77C8JZX7lGa9rD4vI344hlhV0dvMvyfaMcD7vhcClkwR3aHKc2flhG1HGy4dzI7s66PREOqtx9qJSxDiWTC8LSEdeIXT3BpZABf7l2cX4nmc96TGmGq7Q(sMjg9vhccBitCF6QhkGmRFqgAe0zTVNsHkZkScatHSoAhf7DviPGDXYbyDiig(qM4UKUE6Qhk00vpKeC0ohFP7QqmU9E7zwBRyFXwigVHrOxVfKbeAx1xYmXOV6qqydzI7tx9qbKPXjidnc6S23tPq0slmceQFwegmi3kgQaqbCaLg3L3XmdmuzwHvayk0QYfquwXqfakGdH2v9Lmtm6Roee2qM4UKUE6Qhk00vp0Ukxa54LGyOcafWHqL1dTqaxpCakHbM3plcdgKBfdvaOaoGsJ7Y7yMbgIXT3BpZABf7l2cX4nmc96TGmGqsb7ILdW6qqm8HmX9PREOaYSylidnc6S23tPqLzfwbGPqRkxarzfdvaOaoeskyxSCawhcIHpKjUlPRNU6HcnD1dTRYfqoEjigQaqbCGJxAfsmeJBV3EM12k2xSfIXBye61BbzaH2v9Lmtm6Roee2qM4(0vpuazwueKHgbDw77PuOYScRaWuiRJ2rXIq3aH2v9Lmtm6RoeKsHmXDjD90vpuiPGDXYbyDiig(qtx9qsWr7C8LqOBaoEPviXqL1dTqkmAbCG5fHyC792ZS2wX(ITqmEdJqVElidiKjgTaoKzritCF6QhkGmlQfKHgbDw77PuiAPfgbcPVb9BvoR9HkZkScatHmyD1r1QWlzH2v9Lmtm6RoeKsHmXDjD90vpuiPGDXYbyDiig(qtx9q1T1vNJNQWlzC8sRqIHkRhAHuy0c4aZlm2axpCakHbMRVb9BvoR9HyC792ZS2wX(ITqmEdJqVElidiKjgTaoKzritCF6QhkGacrg9LWTcJHdeyyM1Q3AbKaa]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170905.115544, [[da0CtaqicfTjKkJsvWPuf6vQsiZIQQuDlQQsAxsXWGkhtilts1ZiuyAQsW1uLk2MQK8nKW4uLuNtvQ06OQkL5rvvDpjL2NKIdQQQfQk6HivnrQQsCrvv2ivvXjPQYmvLOBkL2juwkH8uutfPSvcv7v5VqvdMuhw0Ij4XuAYs1LbBwv5ZufJwsonvEnsA2sCBs2nIFdz4uvoUQu1Yj65cMUkxxO2ovPVtO05rIwVQeQ5RkL9tXlA0gJLkym7u0B0)kGcixw83m6GJ4PagDgSJzR057gp2Fb(Y4YTNJfbfidWWQJlIcCVU(RBIEnoXa3lmweKDkP5uWyjOshj4Vke)91Kblq6jXcn9yzEoez8F75qKWOnSOrB8pskuG(EoMTsNVB8H84PanweQ0rILemA6m6hm6o6A(kPcWhQqwQnsqLosWORXOfI)(AYGfi9KyHMESmphIy00z0py0NtbgDn1A0VcNr)2BgTq83xJqbH6L4W1e7ZOF0OPZOTiuPJelPPKEt8cXYW1ibv6ibJUgJgNrtNrlMgTq83xt4qsfva8bYMyFg9JJ)l4kUJYXzWcKEsSWy)iDNnpKCmbrGXTOU4PelvW4XyPcg)pybspjwySiOazagwDCrueHBSiiGILwimA7gtFfyP2I8ckGCtyClQJLky8UHvF0g)JKcfOVNJzR057glMg95SuDepg9BVz0D018vsfGpuHSuBKGkDKGr7)AnAp2(4)cUI7OC8xjva(qfYsDSFKUZMhsoMGiW4wux8uILky8ySubJ9NsQaJMRqwQJfbfidWWQJlIIiCJfbbuS0cHrB3y6Ral1wKxqbKBcJBrDSubJ3nmXy0g)JKcfOVNJzR057gRsOeojs1yJLsGCgDn1A01Xz00z0sqLosWO9FTgTq83xtgSaPNel00JL55qeJMoJ2IqLosSKMmybspjwOrcQ0rcg9lYOfI)(AYGfi9KyHMESmphIy0(VwJUhlZZHiJ)l4kUJYXFLub4dvil1X(r6oBEi5ycIaJBrDXtjwQGXJXsfm2FkPcmAUczPA0pe94yrqbYamS64IOic3yrqaflTqy02nM(kWsTf5fua5MW4wuhlvW4Dd7fgTX)iPqb6754)cUI7OCmuafqUSGxOKHBSFKUZMhsoMGiW4wux8uILky8ySubJ)vafqUSy0plz4glckqgGHvhxefr4glccOyPfcJ2UX0xbwQTiVGci3eg3I6yPcgVByVZOn(hjfkqFphZwPZ3nwi(7RbSviiGh9H)Qa8EKqE4dXKoiDepnX(mA6mAX0OfI)(AYGfi9KyHMyFgnDgTkHs4KivJnwkbYz01uRr)6xn(VGR4okhdP8QEFCsfg7hP7S5HKJjicmUf1fpLyPcgpglvW4FP8QEFCsfglckqgGHvhxefr4glccOyPfcJ2UX0xbwQTiVGci3eg3I6yPcgVByVA0g)JKcfOVNJzR057gRsOeojs1yJLsGCgDn1A0rruy0V9MrlMgDkp3xAVMGyHsXr8GxLqjCsKQbiPqb6gnDgTkHs4KivJnwkbYz01uRr)U1h)xWvChLJHuEv4dvil1X(r6oBEi5ycIaJBrDXtjwQGXJXsfm(xkVkJMRqwQJfbfidWWQJlIIiCJfbbuS0cHrB3y6Ral1wKxqbKBcJBrDSubJ3nmkgTX)iPqb6754)cUI7OCC4qsfva8bYX(r6oBEi5ycIaJBrDXtjwQGXJXsfmMpKurfaFGCSiOazagwDCrueHBSiiGILwimA7gtFfyP2I8ckGCtyClQJLky8UH96rB8pskuG(EoMTsNVB84)cUI7OCCX9(yxhVk9Os8h6a1y)iDNnpKCmbrGXTOU4PelvW4XyPcg)s37JDDJUn9OsJMg6a1yrqbYamS64IOic3yrqaflTqy02nM(kWsTf5fua5MW4wuhlvW4Dd7DhTX)iPqb675y2kD(UXcXFFn(qIfK4rF4VkaVkHs4KivtSpJMoJwi(7RjCiPIka(aztSpJMoJoTNZlGhiGYbbJ2)gTym(VGR4okhxCEQoIJ4bVaQCJ9J0D28qYXeebg3I6INsSubJhJLky8lDEQoIJ4XOFIk3yrqbYamS64IOic3yrqaflTqy02nM(kWsTf5fua5MW4wuhlvW4Ddlc3On(hjfkqFphZwPZ3nUJUMVsQa8HkKLAJeuPJem6AmABgo8NtbgnDg9dgTfHkDKyj4LqApJ(T3mAH4VVMmybspjwOj2Nr)44)cUI7OCCj9M4fILHBSFKUZMhsoMGiW4wux8uILky8ySubJFz6nn6NXYWnweuGmadRoUikIWnweeqXslegTDJPVcSuBrEbfqUjmUf1XsfmE3WIIgTX)iPqb675y2kD(UXpy0QekHtIun2yPeiNrxtTgDDCgnDgTq83xduafqUSG)dzJdnX(m6hnA6m6hmAj8jHqvkuaJ(XX)fCf3r54VsQa8HkKL6y6Ral1wKxqbKBcJBrDXtjwQGXJXsfm2FkPcmAUczPA0pu)XX)LEcJVu6bo8UVALWNecvPqbglckqgGHvhxefr4glccOyPfcJ2UX(r6oBEi5ycIaJBrDSubJ3nSO6J24FKuOa99CmBLoF3yvcLWjrQgBSucKZORPwJokkYOF7nJwmn6uEUV0EnbXcLIJ4bVkHs4KivdqsHc0nA6mAvcLWjrQgBSucKZORPwJ(1VYOF7nJgEFSZNpO3euOshKoIh8vqkpJMoJgEFSZNpO3Cva(oybNxqgWluqOoEFP9mA6mAvcLWjrQgBSucKZORXOPaNrtNrFzbixt(DGmuHSuBaskuG(4)cUI7OCmKYRcFOczPo2ps3zZdjhtqeyClQlEkXsfmEmwQGX)s5vz0CfYs1OFi6XXIGcKbyy1XfrreUXIGakwAHWOTBm9vGLAlYlOaYnHXTOowQGX7gwKymAJ)rsHc03ZXSv68DJfI)(AKqarsIfWFOdunsqLosWO9VrhHZOF7nJ(bJwi(7Rrcbejjwa)Hoq1ibv6ibJ2)g9dgTq83xtgSaPNel00JL55qeJ(fz0weQ0rIL0Kblq6jXcnsqLosWOF0OPZOTiuPJelPjdwG0tIfAKGkDKGr7FJo6Dm6hh)xWvChLJp0bk8QmCGKYX(r6oBEi5ycIaJBrDXtjwQGXJXsfmMg6aLr3MHdKuoweuGmadRoUikIWnweeqXslegTDJPVcSuBrEbfqUjmUf1XsfmE3WIEHrB8pskuG(EoMTsNVBCApNxapqaLdcgDngDKrtNrN2Z5fWdeq5GGrxJrhn(VGR4okhxsVjEbivJ9J0D28qYXeebg3I6INsSubJhJLky8ltVPr)es1yrqbYamS64IOic3yrqaflTqy02nM(kWsTf5fua5MW4wuhlvW4Ddl6DgTX)iPqb675y2kD(UXcXFFn(qIfK4rF4VkaVkHs4KivtSpJMoJoTNZlGhiGYbbJ2)gTym(VGR4okhxCEQoIJ4bVaQCJ9J0D28qYXeebg3I6INsSubJhJLky8lDEQoIJ4XOFIkNr)q0JJfbfidWWQJlIIiCJfbbuS0cHrB3y6Ral1wKxqbKBcJBrDSubJ3nSOxnAJ)rsHc03ZXSv68DJt758c4bcOCqWORXOJmA6m60EoVaEGakhem6Am6OX)fCf3r5yBv6i4lopvhXr8m2ps3zZdjhtqeyClQlEkXsfmEmwQGX0xLoIr)sNNQJ4iEglckqgGHvhxefr4glccOyPfcJ2UX0xbwQTiVGci3eg3I6yPcgVByrumAJ)rsHc03ZX)fCf3r54IZt1rCep4fqLBSFKUZMhsoMGiW4wux8uILky8ySubJFPZt1rCepg9tu5m6hQ)4yrqbYamS64IOic3yrqaflTqy02nM(kWsTf5fua5MW4wuhlvW4Ddl61J24FKuOa99CmBLoF3yj8jHqvkuGX)fCf3r54VsQa8HkKL6y6Ral1wKxqbKBph3I6INsSubJh7hP7S5HKJjicmglvWy)PKkWO5kKLQr)Gy844)spHXkKxhXtTr(7xk9ahE3xTs4tcHQuOaJfbfidWWQJlIIiCJfbbuS0cHrB34wKxhXZWIg3I6yPcgVByrV7On(hjfkqFph)xWvChLJHuEv4dvil1X0xbwQTiVGci3EoUf1fpLyPcgp2ps3zZdjhtqeymwQGX)s5vz0CfYs1OFO(JJ)l9egRqEDep1gnweuGmadRoUikIWnweeqXslegTDJBrEDepdlAClQJLky8UHvh3On(hjfkqFphZwPZ3n(sPh4A6UWLely01y0VA8FbxXDuo(RKkaFOczPoM(kWsTf5fua52ZXTOU4PelvW4X(r6oBEi5ycIaJXsfm2FkPcmAUczPA0p8cpo(V0tySc51r8uB0yrqbYamS64IOic3yrqaflTqy02nUf51r8mSOXTOowQGX72nM9bwxwCV48CiYWQ)Q672aa]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20170905.115544, [[d4I8baGEcvTlcHTriA2sUjrQBJ0obzVIDR0(bmmsmofXGvvdNO6GkshJKwOIQLcQwmblhrpeuEk0YivRtrzIekMQkAYimDQUOcUmQRRqBwfA7ek9rIKptkpxL(Mk4XaDyk)wvojr0ZiK60sDEIWFjktJqYHiu5OMZGqgLdInfgWFOykVUvZa(x3wcJKa4l2lWxZOcvVAbrqYwUhmiCUy7Ybsxr9GYe9jIqDIIOvevquod2w1I38(TbsxK6bNc69BV5mqQ5m4WAcftK5bHmkheBkmG)qXuEDRa(szuHQxTGiizl3dQzuHQxTGtf6QDjcsoUYmqVFRSQVEq4CX2LdKUI6bvLGsUenO5pYG7B5GW57BKeKV5mEqPFeqgLdInfgWFOykVUvaFPmQq1R2mGpbF0glpEG0ZzWH1ekMiZdczuoi2uya)HIP86wfebjB5EqXPzuHQxTGtf6QDjcsoUYmqVFRSQVEq4CX2LdKUI6bvLGsUenO5pYG7B5GW57BKeKV5mEqPFeqgLdInfgWFOykVUvZa(e8rBS84Xdkg(OnwEMhpba]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170905.115544, [[d8tCiaqyQwVQQEjrv2fsQyBqe)gQzQQYYiIztQZRi3eIQtJQVPQipxODkQ9kTBc7xe)ecdJsghsQ0RvvQHsIblsdhHdQqhLsv1XuuNdjv1cvflLOYIfy5u8qf0tbpgfRJsvzIiPmvenzI00v5IO0vPuLlR01rQnQaBfIuTzbTDIYhvv4ZiX0GO8DvPrsuvptvjJMKgpsYjPuUfejxtvrDpis52qATiPkhNsL7CjlW4ehhlgGfhCt6Tac7r(ZwMTW5gk7PitPbfmUGYouDz(UpfSJEP3rnNIaDfxbMcticdJ7n0jooweB2QavicdJ7n0jooweB2QGD0l9k1gdwa8)BZiZQquf)osBCBIqCdkyh9sVsh6ehhlI9PWeIWW4EKUHYEXMTky)0l9glzZZLSaRWd0R0(uyK54yrs6pE8kaS)ssz1l6koxNKQywgmAGFfYo6way)LKYQx0vCUojvXSmy0a)ki3QxpUnlXAgjZwwFvaymCIRWXrxKMvVMLuYcScpqVs7tHrMJJfjP)4XRaW(ljLvVOR4CDsk12qNwFfYo6way)LKYQx0vCUojLABOtRVcYT61JBZsSMrYSL1xfagdN4k0RxHOk(fE5hJ6iBFkevXVJ0hUpfIQ4x4LFmQJ0hUpfo3qzVrbJk2u4bbjjcKlNTpKpzbQqegg3tEpXMNlqvZwfIQ4xs3qzVyFk8DWOGrfBkqIqroBFiFYcCHuoJFyZOGrfBkiNTpKpzbgN44yXOGrfBk8GGKebYlaeld318)(XXIMLGejfIQ4xGSpfSJEPxQXnlZXXIcYz7d5twqqJAJblInJScrIvRhO9O6qSgBkzbV55cMMNlqP55cbnp3Rquf)o0joowe7tbQqegg3BK24nBvq6g606Bu5xbGJomjLvVOR4CT9LKgpxi1nstsLftsP4ObAUGsbuNQr6d3SvHan)))p043rTUbfCnHQdQ4xfzSnpxW1eQ(qmAGFkYyBEUakxmsF4MTkqTn0P1xFk46xFkQitPpfKXJ8aUMFtKteBbVaJtCCSyuZPikmKntYkxbP8iH2NiNi2cEbxtO6J6xFkQiJT55cgxqzjNi2cEaxZVPcoTXroxS9PqiwCfgnCxNKMDJb)w47GbyXb8)BZZskm1bif11I6lbzwizE(tFzjrYNSAisHSpxW1eQoPBOSNImLMNlmHimmUN8EInJuZfmRUWq2mjRCfIeRwpq7r1guW1eQoPBOSNIm2MNl40gFuWOInfEqqsIa5)yhqwWo6LELAtiLZ4h2e7tbcdh1nt2yWcG)FBgzwfc08)))qJFBqHZnu2BawCWnP3ciSh5pBz2ci3PIJsJMKsYr3M)YQaJtCCSyawCa))28SKcaJHtCfk4AcvFu)6trfzknpxiQIFvKP0NcegoQBMgGfhW)VnplPaHzzWOb(nQ8RaWrhMKYQx0vCU2(ssjmldgnWVcYT61JBZsSM)KfsKiH6izwcsS(CbuNQr2MTkq66vCjPFyW0enBv4CdL9uKX2Gcrv8R82PaUqkxqj2NckgoQBMssh6ehhlkCUHYEXczhDlWQx0vCUojvXWrDZub7O5mFJ05r4M0BbVW3bdWIRGczsk4IysA2ng8BbN24KteBHa6WWcUMq1hIrd8trMsZZfIQ4xBcPCg)WMyFkG6ubKnpxW1V(uurgBFkevXVkYy7tHOk(DKTpfyWOb(PitPbfo3qzVbyXvqHmjfCrmjn7gd(TaNblacNHlO08Nl8DWaS4GBsVfqypYF2YSfq5cGSzRcNBOS3aS4a()T5zjfumCu3mLKo0joowKKosB8cfyCIJJfdWIRGczsk4IysA2ng8BbN24aXQ12OwZwfyfEGEL2NcrokHEhrW2SKcuHimmUNnHuoJFytSzRcticdJ7nsB8MTkmHimmUNnHuoJFytSzRcdXetjPK4cS6fDfNRtshrWwGbJg4NIm2guaLlgzB(RcuHimmUhPBOSxSzRcoTXTjcXKteBHa6WWcCgSG6HXOn)Lvb7Ox6v6aS4a()T5zjfCnHQdQ4xfzknpxWo6LELkVNyFkevXVWl)yuhrW2NcoTXTNGFfi0(0A61ca]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170905.115544, [[d8ZpiaqyrRxvvVKss7IsGxRG62OYmrIghLqnBkoVcDtufonkFJsKUSs7KQ2R0UjSFf5NqyyK0VH65cgkPmyf1Wr4Gc1rrvuDmvX5Oe0cvvwkQslMilNkpubEkyziP1rjKjsjLPcPjtuMUkxKexLsINrP01rQnsPAROkInlKTJQ6JkiFgIMMQk9DvPrsjvBtvfJMunEKWjjQUfLiUgLOUhQI0Jr0ArvuooLI7trlqMehdlSJfhCJMTacRGsPCVsHlDi3tJVwLk4sbYDG(soC)kizy))pKb)wPcJiIIc7nijogweQxTafiIIc7nijogweQxTGn0l9ktojwaS)B9)QwiOJFJPDPCreUsfSHEPxzdsIJHfH(vyeruuyp00HCVq9Qf450l9gkA9pfTGIiLmRS(viM8yyX0mLSWvVfxWNCBbqHYPzfZYTIlntZAULeZjLxbExZMHTEQQp)8OQABbG0XiUchJB5PQ9QNArlOisjZkRFfIjpgwmntjlC1)tbFYTfafkNMvml3kU0mnBTnkPnxbExZMHTEQQp)8OQARf8uaiDmIRqVEfc64x4LDK6XkvQqqh)gtF4kvGrIfarsYeiR3YfU0HCVybPo2v4dbkkcEWR8HSoAbkqeff2ZQFH6vlqr9Qfc64x00HCVq)kmSuSGuh7kGIqJx5dzD0cmHmgzEyxSGuh7kWR8HSoAbYK4yyrSGuh7k8HaffbpkaeljlnS)5XWI6P(d1cbD8lG2Vc2qV0R1yUL8yyrbELpK1rliO5KtIfH6)TqGyng7MmOpaBWUIwiR)PGu9pfqw)tbx9p9ke0XVdsIJHfH(vGcerrH9IPDz9QfKTrjT5I1OSaW4gmnRywUvCPXIMMdxkKLoztZ8dtZitojdtGSaxsrm9HRxTqAi0ZyZBog04Ru)tH0qONGo(vJVs9pfsdHEoaZjLNgFL6FkWXeX0hUEQfsZBog04R1Vc8zbMeZWUr0rITGubYK4yyrSHHuuyGIhvH3cYybctoIosSfilizy))pKb)gBmvQGlfix0rITqkXmSBSqs7sEWeB)kyTnkPnx)kmSKDS4a2)T(hQfgreff2ZQFH6vlKgc9enDi3tJVw9pfIWIRqSJLMPzF6C43cU1uyGIhvH3cbI1ySBYGELkKgc9enDi3tJVs9pfsAxkxeHrhj2cs0rrfSHEPxzYfYyK5HDH(vine6jOJF14Rv)tbchJlDJYjXcG9FR)x1cx6qUNDS4GB0SfqyfukL7vkWJKcghn30mkJBR3w1cKjXXWc7yXbS)B9pulaKogXviWeinBH0qONXM3CmOXxR(NcbD8RgFT(vGWX4s3ODS4a2)T(hQfiCljMtkVynklamUbtZkMLBfxASOPzc3sI5KYRGMJXLUXP5bjXXWIcU8y4cCjfXk1RwannR4MMhYHPjQxTWLoK7PXxPsfc64xRUJsmHmMazOFf4DnBg26PQ(yPQ)qLQfq9H6pQwUaxsbGwVAbFYTfuml3kU0mnhJqPWWs2XIRGg60mKIW0SpDo8BbBOzKdZtyb4gnBbPcjTlrhj2cs0rrfc64x5czmY8WUq)kKgc9CaMtkpn(A1)uinV5yqJVs)ke0XVXkvQqqh)QXxPFfiXCs5PXxRsfc64x4LDK6X0hUFfU0HCp7yXvqdDAgsryA2Noh(TWWs2XIdUrZwaHvqPuUxPahtaO1tTWLoK7zhloG9FR)HAbnhJlDJtZdsIJHftZX0USGDtYTtZGoMC4cKjXXWc7yXvqdDAgsryA2Noh(Tqs7sGyng5wRE1ckIuYSY6xHaJJWSXiuQNAbkqeff2tUqgJmpSluVAHrerrH9IPDz9Qfgreff2tUqgJmpSluVAHbyIXPzuCbfZYTIlntZXiukqI5KYtJVsLkyd9sVXggsb3kUcKf4yIyL6PwGcerrH9qthY9c1RwGrIf8mmMREBvlyd9sVYSJfhW(V1)qTWyTBj)yzvl8r1cT1sT1w1FTyBvBKL8RLlyd9sVYS6xOFfsAxgli1XUcFiqrrWdkvSJwiPDPveSRaHjhxxVwa]] )


end
