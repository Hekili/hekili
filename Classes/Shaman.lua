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

        ns.addSetting( 'st_fury', false, {
            name = "Enhancement: Single-Target Fury",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not recommend Fury of Air when there is only one enemy.  It will still budget and pool Maelstrom for Fury of Air (if talented accordingly), in case of AOE.\n\n" ..
                "If you are wearing the Smoldering Heart legendary, you will want to set this to |cFF00FF00true|r so that Fury of Air will help proc Ascendance.  Otherwise, simulations for 7.2.5 suggest that Fury of Air is slightly DPS negative in single-target, meaning there is a small DPS loss from using it in single-target.",
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

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20170828.180304, [[d0tBhaGEcbTjcv7IGTrizFIIwMimBbZhQ6MqXVv8nrvxgzNO0EL2TQ2pOrbvAyI04ie48qfdfkjnyGHRIoiQItbL6yOOtt0crvAPuulMclNkpevQNs6Xu16GsIjkk0uPitwOPd5IekFgv8mcHUokSrcr2QiYMrvTDujFxu5RIcAAIcmpcPgjus1FvbJwu62Q0jfrDyLUguI7bLuEoLoeHOETk0LznvnJe)LravERQEN8evTQzkqRLkBIuM5tZNiVqIejebzqv9K8YnifHlsoFztikrSkpEKCEBnvwM1uvX(1iqXAuv9o5jQkA4Wjqc(zcXj3BHaXHaCHa064qiHS0gqzfo9iiq0qqcSab4Xdbi5LGGmHGubSKMcbyxLhdzqIWPAwYns7TAYFu6x04Q(ZtvXmXKwh7EPQvz3lvfRtUrAVvntbATuztKYmpZ0QMj7WW5jBnvuvUZs(JygUOl9OAufZez3lvTOYMOMQk2VgbkwERQEN8evfnC4eib)mH4K7TqG4qaUqGbd(8fwRN(4(EsGXjeGhpeGleWNCB4G9u6KibhDx5BHGmHaSabydb4XdbbIlkabIgcyMMcbyxLhdzqIWPQb5SK7O85un5pk9lACv)5PQyMysRJDVu1QS7LQYl5SK7O85u1mfO1sLnrkZ8mtRAMSddNNS1urv5ol5pIz4IU0JQrvmtKDVu1IkRiwtvf7xJaflVvvVtEIQIgoCcKGFMqCY9wiqCiaxiWGbF(cR1tFCFpjW4ecWJhcWfc4tUnCWEkDsKGJUR8TqqMqawGaSHa84HGaXffGardbmttHaSRYJHmir4u1imt8aFgoCQM8hL(fnUQ)8uvmtmP1XUxQAv29sv5nmtecejgoCQAMc0APYMiLzEMPvnt2HHZt2AQOQCNL8hXmCrx6r1OkMjYUxQArLndQPQI9RrGIL3QQ3jprvrdhobs4CqY5TqG4qaUqGbd(8fwRN(4(EsGXjeGhpeiYqaAd0JewRN(4(EsG(1iqriqCiGp52Wb7P0jrco6UY3cbzcbybcWJhcqRJdHeqYlDanhIsccenwdcevkeGDvEmKbjcNQNdsoF1K)O0VOXv9NNQIzIjTo29svRYUxQkwDqY5RAMc0APYMiLzEMPvnt2HHZt2AQOQCNL8hXmCrx6r1OkMjYUxQArLfl1uvX(1iqXYBv17KNOQOHdNaj4NjeNCVTkpgYGeHtv(KBdhSNsNevn5pk9lACv)5PQyMysRJDVu1QS7LQksKBdqGEkDsuvZuGwlv2ePmZZmTQzYomCEYwtfvL7SK)iMHl6spQgvXmr29svlQSIQMQk2VgbkwERQEN8evfxiaxiqKHa0WHtGe8ZeItU3cbIdbwcHKphRWgctUdXChIKfN3dbydb4Xdb(zcXj3lSwp9X99KGJUR8TqqMqGOGaSHa84Ha0gOhjymmcrYXxArc0Vgbkcb4XdbrYGbF(c06qzP)G9uEKeyCwLhdzqIWPACM7HCYpARM8hL(fnUQ)8uvmtmP1XUxQAv29svZ4mxiidLF0w1mfO1sLnrkZ8mtRAMSddNNS1urv5ol5pIz4IU0JQrvmtKDVu1IkB(AQQy)AeOy5TQ6DYtuv0WHtGe8ZeItU3cbIdb4cb4cb(zcXj3lyrJ7Aro5rsWr3v(wiitiifcWgcehcmyWNVWA90h33tcXj3dbyxLhdzqIWP6A90h33tvt(Js)Igx1FEQkMjM06y3lvTk7EPQ8y90h33tvntbATuztKYmpZ0QMj7WW5jBnvuvUZs(JygUOl9OAufZez3lvTOIQYUxQQkVCdbI9z33tx6ryfiG7mAlQfa]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20170828.180304, [[d4Z8iaGEkf0Mie7sjTnIQSpLIMPsblJinBjMpqYnLQ(nsFJs1LH2jG9k2nO9lLrbKAysLXre68eWqvk0GL0WvkDqcPtbu6ykX5OuGfsGwkbTyvz5iEiP0tr9yfToIQstKOQyQeQjRQMUkxeO60K8mkf66uYgPu0wjI2mPy7eLBtXFPuAAaH5be51KkhMQrRu9zsvNKOYpbI6Aeb3dO45kCiIQQoorvLZsehw(GACRYfbdZtIA7foSqSG(adG0Uf7D2LAFvQuPseeH5T4u5fLn0pffgaPYZgdl68uu4iIdWsehgCO)k4pcgMNe12lSXXY4iuZ60Iqq41QGuRUiTlSOpvrDceMqN6EQdjHLd(vt)OKWqked3t)s6ea3GHdd4gmSq6u3tDijSqSG(adG0Uf7lDHfIdQfzIJioxyT74uxpvgAq4Lx4E6hWny4CbqAehgCO)k4pcgMNe12l8ZsJMvnf3GhfQ3cxjOXvWrRcsTkiwLyyrFQI6eiSMIBWJc1BHHLd(vt)OKWqked3t)s6ea3GHdd4gmSnlUbpkuVfgwiwqFGbqA3I9LUWcXb1ImXreNlS2DCQRNkdni8YlCp9d4gmCUayJrCyWH(RG)iyyEsuBVWGUvpVGWBDs8XUcQ32XrjMve6Vc(BvqbQw1NNsgAlcrJchT6MGPvL2QGTvfPv)4ZsJMv0j3ocTDSvPdxT22QI0QghlJJqnRtlcbHxRUjyAvq01QI0QYCIYFfCfK1UrkTiVUWI(uf1jq4jXh72wu63pOcQpSCWVA6hLegsHy4E6xsNa4gmCya3GH1s8XERUbL(9dQG6dlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaarehgCO)k4pcgMNe12l85feER7UQmokXSIq)vWFRksR(S0OzvdHoUhXH)vcACfC0QGuRcIvj2QI0QghlJJqnRtlcbHxRUzRcIUWI(uf1jqyne64Eeh(dlh8RM(rjHHuigUN(L0jaUbdhgWnyyBsOJ7rC4pSqSG(adG0Uf7lDHfIdQfzIJioxyT74uxpvgAq4Lx4E6hWny4CbqcrCyWH(RG)iyyEsuBVWYCIYFfC115kOf4Ypl12T4VvfPvL)T6ZsJMvne64Eeh(xT22QI0QghlJJqnRtlcbHxRUjyAv7siSOpvrDcewdHoUhXH)WYb)QPFusyifIH7PFjDcGBWWHbCdg2Me64Eeh(BvqVa2WcXc6dmas7wSV0fwioOwKjoI4CH1UJtD9uzObHxEH7PFa3GHZfa5fXHbh6Vc(JGHf9PkQtGWdl4hjkO(WYb)QPFusyifIH7PFjDcGBWWHbCdgMTGFKOG6dlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaShXHbh6Vc(JGH5jrT9cBCSmoc1SoTieeET6MGPvLqxRksRkZjk)vWvqw7gP0I9UwvKwvMtu(RGRASicODhN6KyxyrFQI6eiCXL52w8XEy5GF10pkjmKcXW90VKobWny4WaUbdVbxM3QBWh7HfIf0hyaK2TyFPlSqCqTitCeX5cRDhN66PYqdcV8c3t)aUbdNlasmIddo0Ff8hbdl6tvuNaHj0PUN6qsy5GF10pkjmKcXW90VKobWny4WaUbdlKo19uhsAvqVa2WcXc6dmas7wSV0fwioOwKjoI4CH1UJtD9uzObHxEH7PFa3GHZfaBqehgCO)k4pcgMNe12lmOBvJJLXrOM1PfHGWRv3emTQ8KqRckq1QNxq4Toj(yxb1B74OeZkc9xb)TkOavR6ZtjdTfHOrHJwDtW0QsBvW2QI0QYCIYFfCfK1UrkTiVUwvKwvMtu(RGRASicODhN6aHecl6tvuNaHNeFSBBrPF)GkO(WYb)QPFusyifIH7PFjDcGBWWHbCdgwlXh7T6gu63pOcQVvb9cydlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxaw6I4WGd9xb)rWWI(uf1jqynf3GhfQ3cdlh8RM(rjHHuigUN(L0jaUbdhgWnyyBwCdEuOElSvb9cydlelOpWaiTBX(sxyH4GArM4iIZfw7oo11tLHgeE5fUN(bCdgoxUWaUbdZkJ2wfC4UdNObHN8Tv1OkfKKlba]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20170829.202855, [[dSJNgaGEij1MiGDrrBJuH9bPuZesIMnvUPs5BqILruTtv1EL2nW(fmkifnmimosf9BqxgzWu1WjkheI6uqkCmL00ivLfsqTuczXQYYH6HkvwfKsEScRdssMiKeMkHAYuA6QCrcYRGKYZivvxNcBujQTsQYMjLTdronjhcsLptKMhKQoSOxRegnrCBHojPsFxjY1GKQZRu1Fjqpxrpf1DTIlJkiT0WDv4Y8aRKDLllICuoP(LJyffe6uUonx1jc9JqFLzz0qLofQopfe0VCDO)YipofemR4(xR4YcbYNJSv4Y8aRKDLV0rGZ0La70PSKjbYNJSbVabp6c(NHMMPlb2PtzjtdzLr(PCQBFzmCS4PocxwxGvnYdIldGaQ8g0QxI)zKkx(NrQSi4yXtDeUSiYr5K6xoIvuwruwenHg4bnR4EL3jHgl2GirrcC9vEdA)zKk3RF5vCzHa5Zr2kCzEGvYUYOl4p1yHcin4fi4Jj5MhggnhgymbUGhTdE5YlJ8t5u3(YAg49cc1emv4Y6cSQrEqCzaeqL3Gw9s8pJu5Y)msLx2aVp4HAbpYkCzrKJYj1VCeROSIOSiAcnWdAwX9kVtcnwSbrIIe46R8g0(ZivUx)6VIlleiFoYwHlZdSs2voXNslhNz6KjjfCjOtZeNGfbpAh8icEbcEzycjbLoSMRMAeoDcoLPWQRmYpLtD7lpW5uIGoLujhqbKwwxGvnYdIldGaQ8g0QxI)zKkx(NrQ8oCoLe8OsLujhqbKwwe5OCs9lhXkkRiklIMqd8GMvCVY7KqJfBqKOibU(kVbT)msL71V(Q4YcbYNJSv4Y8aRKDLrxW)m00m1CzKoiqQbzAiRmYpLtD7lR5YiDqGudQSUaRAKhexgabu5nOvVe)ZivU8pJu5LDzKoiqQbvwe5OCs9lhXkkRiklIMqd8GMvCVY7KqJfBqKOibU(kVbT)msL71pQxXLfcKphzRWL5bwj7kFPJaNPKu5Mhehnjq(CKn4fi4rxW)m00m1WW59WjWAAil4fi4rkXQ85itnd8(DsOXc9H6Lr(PCQBFznmCEpCcSL1fyvJ8G4YaiGkVbT6L4FgPYL)zKkVmgoVhob2YIihLtQF5iwrzfrzr0eAGh0SI7vENeASydIefjW1x5nO9NrQCV(1rfxwiq(CKTcxMhyLSR8ZqtZuZLr6GaPgKjMIPcmdE0h86i4rTGx6Wg8ce8di0zHlbmTqyuWLua70etXubMbp6dEPdBWJwbV8Yi)uo1TVSMlJ0bbsnOY6cSQrEqCzaeqL3Gw9s8pJu5Y)msLx2Lr6GaPguWJMROrzrKJYj1VCeROSIOSiAcnWdAwX9kVtcnwSbrIIe46R8g0(ZivUx)OuXLfcKphzRWL5bwj7kFPJaNPKu5Mhehnjq(CKn4fi4FgAAMAy48E4eynXumvGzWJ(GxhbpQf8sh2GxGGFaHolCjGPfcJcUKcyNMykMkWm4rFWlDydE0k4Lxg5NYPU9L1WW59WjWwwxGvnYdIldGaQ8g0QxI)zKkx(NrQ8Yy48E4eydE0CfnklICuoP(LJyfLveLfrtObEqZkUx5DsOXInisuKaxFL3G2FgPY96v(NrQmRI7cEHassWGIe4qvb)ZqtB2Rf]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20170828.180304, [[dadxcaGEuv1UuQABOKmBeUPq(gIANc2lz3G2VOQHjHFdmyrPHJIoOOYXOKfkkwQszXuQLlYdvsEQQhlPNtXefkMQenzQmDfxev5zcvDDuQTIiTzuvA7Oeldv(QqPPHQIVJighkPUm0OrHxReNuj1HL60iDELk)vOYTPQ1HQkllvQhdY3MnXOm6NjwPnbL)9qbqf4yv86Bib2gubUclYfK5iVNJJJ18r)1eL5ORNRoua0OsfSuPopyBtGoLrpNnLGo70XonmqyCgM0fuFn0rR9as6qae1Jaos7uO9OUEO9OoVonmqy(SNjDb13qcSnOcCfwKTk03qdGDQIgvQrFfdSUebyb9iCKTEeWfApQRrbovQZd22eOtz0Fnrzo6vaGWbibU3mGK3mj6cUNnt9C2uc6St3ba(4iHcDg91qhT2diPdbqupc4iTtH2J66H2J6Xaa(8zJLcDg9nKaBdQaxHfzRc9n0ayNQOrLA0xXaRlrawqpchzRhbCH2J6AuiEvQZd22eOtz0ZztjOZoDsOqNzs0fuFn0rR9as6qae1Jaos7uO9OUEO9OESuOZmj6cQVHeyBqf4kSiBvOVHga7ufnQuJ(kgyDjcWc6r4iB9iGl0EuxJg9q7r9t9RYNLhKrdROhHd)YNTnvnsa]] )

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20170828.180304, [[dmKinaqiOsXIiQytOkQrrQItruPDHknmvLJPkTmsLNPIcttfLCnOs12urrFdQyCKQuNtfLQ1PQkZdvHUNkQSpuf5GsWcrv6HsOjQIQYfjL2iPkXhvvvJufvPtsu1mrvWnLODcLFcvknuvuvTuuXtrMkr5QQOk2kPWxjvjTxXFvrgmfhwQftKhlPjRsxgSzsrFwvmAvvonHxJQQzJYTjz3k9BidxfA5u1ZPY0vCDOQTJQY3Hk58QG1RIsz(KQA)u68gzHWAfeIeQIwJwgOGDAM18FRKyI95pR5cA24ztOZhOzJNnH3qCag0oiy6(EX5dhD4WvNoD69zfIocvrZeNTEeOny6otDHkuhbADrwWEJSqA3wIb3ifIQEXXj0GEEya3kcXUiCToRHNTg9ynt7FGH7pOzZpUhRJ1WJwJoC3A0xFRzekWA4jR5JlU)9znYnubjbtmhcjXqOldVBcj)Ef1Eq(qlAHqLORgThRvqOqyTccDEbps4uH4amODqW099IZ7xioGdH3xbxKLjuXFqL)seFGc2jsHkrxSwbHYemDrwiTBlXGB4nev9IJtOb98WaUhrJaToRHNTg9ynveIDr4A5QPWdNagOGDAgxpOAX6SgEYA0P3FwJ(6Bnt7FGH7iuWPbD6kaRHhpN1CMFwJCdvqsWeZHqhrJaTHKFVIApiFOfTqOs0vJ2J1kiuiSwbHo)OrG2qCag0oiy6(EX59lehWHW7RGlYYeQ4pOYFjIpqb7ePqLOlwRGqzc2zezH0UTedUH3qu1looHg0Zdd4k2b8E8hhxOcscMyoecxI9EY9dAFi53RO2dYhArleQeD1O9yTccfcRvqi9QyVwd9dAFioadAhemDFV48(fId4q49vWfzzcv8hu5VeXhOGDIuOs0fRvqOmb7SISqA3wIb3WBiQ6fhNqs41utUEWH2ERWPbnGIRhuTyDwdpAn6cvqsWeZHqdAa1jv7gWFiK87vu7b5dTOfcvIUA0ESwbHcH1kiKm0akRPSDd4peIdWG2bbt33loVFH4aoeEFfCrwMqf)bv(lr8bkyNifQeDXAfektWW9ilK2TLyWn8gIQEXXj0GEEya3kcXUiCTUqfKemXCiKMcpCcyGc2PzHKFVIApiFOfTqOs0vJ2J1kiuiSwbH0lcpynAzGc2PzH4amODqW099IZ7xioGdH3xbxKLjuXFqL)seFGc2jsHkrxSwbHYeSZmYcPDBjgCdVHOQxCCcnONhgWTIqSlcxRlubjbtmhc5gKxDcyGc2PzHKFVIApiFOfTqOs0vJ2J1kiuiSwbHOb5vwJwgOGDAwioadAhemDFV48(fId4q49vWfzzcv8hu5VeXhOGDIuOs0fRvqOmbdNilK2TLyWn8gIQEXXj0GEEya3kcXUiCTUqfKemXCieWafStZoPA3a(dHKFVIApiFOfTqOs0vJ2J1kiuiSwbH0YafStZSMY2nG)qioadAhemDFV48(fId4q49vWfzzcv8hu5VeXhOGDIuOs0fRvqOmbtVJSqA3wIb3WBOcscMyoecVdojgq5cj)Ef1Eq(qlAHqLORgThRvqOqyTccDECG1i)akxioadAhemDFV48(fId4q49vWfzzcv8hu5VeXhOGDIuOs0fRvqOmb7ShzH0UTedUH3qu1looHg0Zdd4wri2fHR1zn8S1OhRb3yntZGD42UkS3ERaxyBjgCTg913AKWRPMCBxf2BVvGl(JwJ(6BnveIDr4A52UkS3ERaxpOAX6SgEYAW9pRrUHkijyI5qijgcDpPjE)HqYVxrThKp0Iwiuj6Qr7XAfekewRGq8YqOR1OxW7peIdWG2bbt33loVFH4aoeEFfCrwMqf)bv(lr8bkyNifQeDXAfektWE)ISqA3wIb3WBiQ6fhNqd65HbCRie7IW16SgE2A0J1GBSMPzWoCBxf2BVvGlSTedUwJ(6Bns41utUTRc7T3kWf)rRrUHkijyI5qijW7ap)I9jK87vu7b5dTOfcvIUA0ESwbHcH1kieVG3bE(f7tioadAhemDFV48(fId4q49vWfzzcv8hu5VeXhOGDIuOs0fRvqOmb79nYcPDBjgCdVHOQxCCc11rWhCcwqjaN1WtwJUqfKemXCiKh)EQRJaTNyc3es(9kQ9G8Hw0cHkrxnApwRGqHWAfeId(1AkuhbATgEq4Mqf8pUqBRGZjhsOkAnAzGc2PzwZ)TsIj2N)SMc4wTYjehGbTdcMUVxCE)cXbCi8(k4ISmHk(dQ8xI4duWorkuj6I1kiejufTgTmqb70mR5)wjXe7ZFwtbCR2mb7vxKfs72sm4gEdrvV44eAAgSd32vH92Bf4cBlXGR1OV(wdd4dywdpAnVFFHkijyI5qip(9uxhbApXeUjK87vu7b5dTOfcvIUA0ESwbHcH1kieh8R1uOoc0An8GWnwJEELBOc(hxOTvW5KdjufTgTmqb70mR5)wjXe7ZFwJtSpmWAAxvoH4amODqW099IZ7xioGdH3xbxKLjuXFqL)seFGc2jsHkrxSwbHiHQO1OLbkyNMzn)3kjMyF(ZACI9Hbwt7Qzc27zezH0UTedUH3qu1looHMMb7WvubnX7pWf2wIb3qfKemXCiKh)EQRJaTNyc3es(9kQ9G8Hw0cHkrxnApwRGqHWAfeId(1AkuhbATgEq4gRrp6KBOc(hxOTvW5KdjufTgTmqb70mR5)wjXe7ZFwJtSpmWAeAkNqCag0oiy6(EX59lehWHW7RGlYYeQ4pOYFjIpqb7ePqLOlwRGqKqv0A0YafStZSM)BLetSp)znoX(WaRrOzMG9EwrwiTBlXGB4nev9IJtOPzWoCzINFZk2NtE0LlSTedUHkijyI5qip(9uxhbApXeUjK87vu7b5dTOfcvIUA0ESwbHcH1kieh8R1uOoc0An8GWnwJEod5gQG)XfABfCo5qcvrRrlduWonZA(VvsmX(8N14e7ddSgMxoH4amODqW099IZ7xioGdH3xbxKLjuXFqL)seFGc2jsHkrxSwbHiHQO1OLbkyNMzn)3kjMyF(ZACI9HbwdZNjtiQ6fhNqzsa]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20170828.180304, [[deJwcaGEruTlLs2MsPMTKUjQ62OStQAVKDJ0(fvgMe9BPgkuvnyrXWLWbfjhJsTqrPLQuTyeTCQ8qLINcEmeRdQktueXuPKjdLPlCrrvxw11fP2kK0MfrA7qIpkIYHv8zOkpxjldHPjcz0qQ(gu5KqkJte40uCEuPxJk(RiONjc1Ywwc8d7cadBtUm5RNDAm1Czs2WiRgkE4lxMc3rAg5ecsYt6KUgkRG9x)SU8eL24kXrGBlccIeKibqXrmt1K8jmnvEITjeKcjmnDjl5TLLG80HSEmLvaG4mfHGOXdV63QOdttxcsrAQMGRGIomnvaAumdYeTtaTPxaFJH648d7ce4h2fG)omnvW(RFwxEIsBC2Lc2)Qt7q(swkeSb9JWHVr5StdrkGVX8d7cuipHSeKNoK1JPScsrAQMGRGOJZsiBwXDCfGgfZGmr7eqB6fW3yOoo)WUab(HDbwDCwUm8ZkUJRG9x)SU8eL24SlfS)vN2H8LSuiyd6hHdFJYzNgIuaFJ5h2fOq(ellb5Pdz9ykRGuKMQj4kyfTJX5V4obOrXmit0ob0MEb8ngQJZpSlqGFyxaeTJX5V4ob7V(zD5jkTXzxky)RoTd5lzPqWg0pch(gLZonePa(gZpSlqHcbaIZuecuib]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20170828.180304, [[dau0raqiLGAtkHgfLuNIsYROejMfLiPDbvggsCms1YOu9mvvPPPQkCnvvrBJsu9nvLgNsqohLiSokrQMNQQQ7PkY(qs5GQkwOs0drsMiLiYfvvzJuIYhPerDskHzQe4Muv7eklLO6POMkszReL2R0FvsdwOdRyXe5XImzL6YGndv9zQYOjLtt41ivZMk3MIDJ43qgUQWXvvvwojpxutxLRRkTDkLVRkQZtuSEkrkZhjv7xWvV0kJngOmlmufI)CGbi34crl5Xi5eepl9qmliEoieDQYwsa(51DDzz5GdMmum7u0)s5R9V4SB3(c9hL5hqsmoHL2CcePy2TC7L)KobIKlTIPxAL)rgjhS7YYCsjECLx4q8ej6cIxisDQhIB0HdVBmWAwdLOJtbMrqYH4)Fke9s7YFKeoXjtz8UXaRznuIEzliBrAoKQmbrGY(OTSJcBmq5YyJbkBzUXaHiRHs0llhCWKHIzNI(xDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vm7Lw5FKrYb7US8hjHtCYugCGbi34wLCt(kBbzlsZHuLjicu2hTLDuyJbkxgBmq5FoWaKBCH4s3KVYYbhmzOy2PO)vNsz5qg9QsqU06vMknir3hzdma5QuzF0gBmq5Ef7VLw5FKrYb7USmNuIhxzPx84XbjneKxr4xpny1tbZTMFjBqjiE4EFu(JKWjozkdJ60(37qhkBbzlsZHuLjicu2hTLDuyJbkxgBmq5FJ60(37qhklhCWKHIzNI(xDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vS)O0k)Jmsoy3LL5Ks84kBgWLpfYGl9Qua5crQ9uiQR)nePo1dXfoeh1jWpPdx(zW5eeVvZaU8PqgCazKCWoexmend4YNczWLEvkGCHi1EkeTe2l)rs4eNmLHrDARznuIEzliBrAoKQmbrGY(OTSJcBmq5YyJbk)BuNwiYAOe9YYbhmzOy2PO)vNsz5qg9QsqU06vMknir3hzdma5QuzF0gBmq5Ef7plTY)iJKd2Dz5pscN4KPC(qkdDaEaQYwq2I0CivzcIaL9rBzhf2yGYLXgduMpKYqhGhGQSCWbtgkMDk6F1PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxXS8sR8pYi5GDxw(JKWjozk7e)7vSxnJNzwp0bMYwq2I0CivzcIaL9rBzhf2yGYLXgduEbI)9k2HO)4zMqKg6atz5GdMmum7u0)QtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVI9T0k)Jmsoy3LL5Ks84kVrho8UXaRznuIoofygbjhIulett(wpHbcXfdXec52ONjRkysx5pscN4KPSBSnRsVQ8v2cYwKMdPktqeOSpAl7OWgduUm2yGYlySnH4Yxv(klhCWKHIzNI(xDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vSfQ0k)Jmsoy3LL5Ks84kBDiAgWLpfYGl9Qua5crQ9uiANsiUyik9IhpoWbgGCJBfpk9MX9(ieTkexmeToevaEfK1gjheIwv(JKWjozkJ3ngynRHs0lBbzlsZHuLjicu2hTLDuyJbkxgBmqzlZngieznuIEiATUvL)O8YLVr5b3Qa)tkaVcYAJKdklhCWKHIzNI(xDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vmlrPv(hzKCWUllZjL4Xv2mGlFkKbx6vPaYfIu7PquxxpePo1dXfoeh1jWpPdx(zW5eeVvZaU8PqgCazKCWoexmend4YNczWLEvkGCHi1EkexilpePo1dr4FVIhpGnUSb52Gsq8w1GrDH4IHi8VxXJhWg3PbRBibcBGkVk5qO96JjDH4IHOzax(uidU0RsbKlePwi(LsiUyiEJdihUb)bQSgkrhhqgjhSl)rs4eNmLHrDARznuIEzliBrAoKQmbrGY(OTSJcBmq5YyJbk)BuNwiYAOe9q0ADRklhCWKHIzNI(xDkLLdz0Rkb5sRxzQ0GeDFKnWaKRsL9rBSXaL7vmDkLw5FKrYb7USmNuIhxzPx84XPGmImKeSEOdm4uGzeKCi()quNsisDQhIwhIsV4XJtbzezijy9qhyWPaZii5q8)HO1HO0lE84MCci7HKaC7x1CcejeTucXec52ONj4MCci7HKaCkWmcsoeTkexmetiKBJEMGBYjGShscWPaZii5q8)HO(FgIwv(JKWjozkFOdmRMjFGsMYwq2I0CivzcIaL9rBzhf2yGYLXgduMg6ati6p5duYuwo4GjdfZof9V6uklhYOxvcYLwVYuPbj6(iBGbixLk7J2yJbk3Ry66Lw5FKrYb7USmNuIhxzRdrPx84X9a9mOwr4xpny1mGlFkKb37JqCXqCsNWgSceWiGCi()q8VHOvH4IHO1H4gKEXJhNt4PDebXBvH242ONjHOvL)ijCItMYoHN2reeVvjK7kBbzlsZHuLjicu2hTLDuyJbkxgBmq5fi80oIG4fIlrUR8hLxU8nkp4wf4FAdsV4XJZj80oIG4TQqBCB0ZKYYbhmzOy2PO)vNsz5qg9QsqU06vMknir3hzdma5QuzF0gBmq5Eft3EPv(hzKCWUllZjL4Xvw6fpECpqpdQve(1tdwnd4YNczW9(iexmeN0jSbRabmcihI)pe)B5pscN4KPSt4PDebXBvc5UYwq2I0CivzcIaL9rBzhf2yGYLXgduEbcpTJiiEH4sK7crR1TQSCWbtgkMDk6F1PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxX0)BPv(hzKCWUllZjL4Xv26qCsNWgSceWiGCisTqupexmeN0jSbRabmcihIule1drRcXfdrRdXni9IhpoNWt7icI3QcTXTrptcrRk)rs4eNmLtAJGS6eEAhrq8kBbzlsZHuLjicu2hTLDuyJbkxgBmqzQ0gbjexGWt7icIx5pkVC5BuEWTkW)0gKEXJhNt4PDebXBvH242ONjLLdoyYqXStr)RoLYYHm6vLGCP1RmvAqIUpYgyaYvPY(On2yGY9kM(FuAL)rgjhS7YYCsjECLN0jSbRabmcihIule1dXfdXjDcBWkqaJaYHi1cr9YFKeoXjt5K2iiRoHN2reeVYwq2I0CivzcIaL9rBzhf2yGYLXgduMkTrqcXfi80oIG4fIwRBvz5GdMmum7u0)QtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVIP)NLw5FKrYb7USmNuIhx5ni9IhpoNWt7icI3QcTXTrptk)rs4eNmLDcpTJiiERsi3v2cYwKMdPktqeOSpAl7OWgduUm2yGYlq4PDebXlexICxiATDRk)r5LlFJYdUvb(N2G0lE84CcpTJiiERk0g3g9mPSCWbtgkMDk6F1PuwoKrVQeKlTELPsds09r2adqUkv2hTXgduUxX0T8sR8pYi5GDxw(JKWjozk7eEAhrq8wLqURSfKTinhsvMGiqzF0w2rHngOCzSXaLxGWt7icIxiUe5Uq06)Avz5GdMmum7u0)QtPSCiJEvjixA9ktLgKO7JSbgGCvQSpAJngOCVIP)T0k)Jmsoy3LL5Ks84kRa8kiRnsoO8hjHtCYugVBmWAwdLOxMknir3hzdma56YY(OTSJcBmq5Ywq2I0CivzcIaLXgdu2YCJbcrwdLOhIwB3QYFuE5YgKnbX7jDl1BuEWTkW)KcWRGS2i5GYYbhmzOy2PO)vNsz5qg9QsqU06v2hztq8kMEzF0gBmq5EftFHkTY)iJKd2Dz5pscN4KPmmQtBnRHs0ltLgKO7JSbgGCDzzF0w2rHngOCzliBrAoKQmbrGYyJbk)BuNwiYAOe9q0A7wv(JYlx2GSjiEpPxwo4GjdfZof9V6uklhYOxvcYLwVY(iBcIxX0l7J2yJbk3Ry6wIsR8pYi5GDxw(JKWjozkJ3ngynRHs0ltLgKO7JSbgGCDzzF0w2rHngOCzliBrAoKQmbrGYyJbkBzUXaHiRHs0drR)RvL)O8YLniBcI3t6LLdoyYqXStr)RoLYYHm6vLGCP1RSpYMG4vm9Y(On2yGY96vMtkXJRCVwa]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20170828.180304, [[deKcuaqiuKSjLGrPuQtPuLvPus6vkLeMfjPs7sv1WqHJrILrjEgjjnnue5AkLuBJKeFtPY4ijLZHIOwhjPkZtPQCpLq7dfvhuvPfQe9quktuPKOlQQyJOi8rssfNeLQzIIu3KQANQYsjQEkYurjBLKyVs)fknyroSIftKhtLjdvxgSzL0NjkJMQCAkEnumBHUnP2nHFdz4KuhxPelhvpxW0v56uQTtj9DLQQZRuSEssvnFuu2VOUkLvP3OHsKrZwo9jcAqCtmNuDgTu0iKP6LtbJqweYjZAPTsyDSJxxwsoeHja9zHHYog7SS73IflQgtQePgCMjAu9NZGe9zrvSu6R7mirOS6tPSk9rmsraVllroUr9vIPYPZ4WyeYYjMXSCchD)RXrdydEihMFoOhJiKt7BXCsMdV0xjt0CBkTghnGn4HCykXUa34MdXljqcOKpcxLH)gnuQ0B0qjMioAiNipKdtj5qeMa0Nfgk7uyusoeq2ChekRELyZdCy8rwbniUkvYhH)gnuQxFwkRsFeJueW7YsKJBuFLKSxx)bNhccyrRyppaRmomh2GTah4gHSFB150c5KEGy44i9VZMZbXLtmFXCs1uLsFLmrZTPem8ZBl2dgOe7cCJBoeVKajGs(iCvg(B0qPsVrdL(m8ZBl2dgOKCicta6ZcdLDkmkjhciBUdcLvVsS5bom(iRGgexLk5JWFJgk1RpvTSk9rmsraVllroUr9vsYED934GvB(MFB150c5KEGy44i9VZMZbXLtmFXCsrrjNwiNyQCsYED9FcoqGpch8BRU0xjt0CBkTYrHdBWd5WuIDbUXnhIxsGeqjFeUkd)nAOuP3OHsmbhfUCI8qomLKdrycqFwyOStHrj5qazZDqOS6vInpWHXhzf0G4QujFe(B0qPE9XKkRsFeJueW7YsFLmrZTPeebniUjIvkoHRe7cCJBoeVKajGs(iCvg(B0qPsVrdL(ebniUjMtlJt4kjhIWeG(SWqzNcJsYHaYM7Gqz1ReBEGdJpYkObXvPs(i83OHs96BRlRsFeJueW7YsKJBuFL0dedhhP)D2CoiUCI5lMtkk7YjMXSCIPYPHFM1XD)H9dXOridREGy44i9pigPiGNtlKt6bIHJJ0)oBohexoX8fZjMSLsFLmrZTPem8ZdBWd5WuIDbUXnhIxsGeqjFeUkd)nAOuP3OHsFg(5LtKhYHPKCicta6ZcdLDkmkjhciBUdcLvVsS5bom(iRGgexLk5JWFJgk1RpvPSk9rmsraVllroUr9vQ0xjt0CBkfoexJba1aVe7cCJBoeVKajGs(iCvg(B0qPsVrdLOdX1yaqnWljhIWeG(SWqzNcJsYHaYM7Gqz1ReBEGdJpYkObXvPs(i83OHs96Bxzv6JyKIaExwICCJ6R025KEGy44i9VZMZbXLt7BXCsHHsoTqon8ZSoU7pSFignczy1dedhhP)bXifb8CIzmlNyQCA4NzDC3Fy)qmAeYWQhigoos)dIrkc450c5KEGy44i9VZMZbXLt7BXCANQKt7LtlKtmvojzVU(pbhiWhHd(Tvx6RKjAUnLmoy1MVPe7cCJBoeVKajGs(iCvg(B0qPsVrdLy3bR28nLKdrycqFwyOStHrj5qazZDqOS6vInpWHXhzf0G4QujFe(B0qPE9PALvPpIrkc4DzjYXnQVsL(kzIMBtPOzl2gCS6rMEWEOd0LyxGBCZH4LeibuYhHRYWFJgkv6nAOetB2ITbpN8hz6jNyHoqxsoeHja9zHHYofgLKdbKn3bHYQxj28ahgFKvqdIRsL8r4VrdL61htUSk9rmsraVllroUr9vsYED9xnA)ahlAf75by1dedhhP)TvNtlKts2RR)HdX1yaqnW)TvNtlKtJ7mwbSGa0giKt7lNu1sFLmrZTPu0iZ7egHmSsO4vIDbUXnhIxsGeqjFeUkd)nAOuP3OHsmTrM3jmcz50su8kjhIWeG(SWqzNcJsYHaYM7Gqz1ReBEGdJpYkObXvPs(i83OHs96tHrzv6JyKIaExwICCJ6Reo6(xJJgWg8qom)CqpgriNyEo5MWH9mAiNwiNCiuehTFbwomUR0xjt0CBkfhRdwjBE4kXUa34MdXljqcOKpcxLH)gnuQ0B0qjMESo50sBE4kjhIWeG(SWqzNcJsYHaYM7Gqz1ReBEGdJpYkObXvPs(i83OHs96trPSk9rmsraVllroUr9vsYED934GvB(MFB150c5025KEGy44i9VZMZbXLtmFXCYcJCIzmlNKSxx)noy1MV5Nd6Xic50(YPTZjL)ToN2Q5uqneJy9MWb50wnNKSxx)noy1MV5pCJdtoTvKtk50E50EL(kzIMBtPvokCydEihMsSlWnU5q8scKak5JWvz4VrdLk9gnuIj4OWLtKhYHjN2wzVsYHimbOplmu2PWOKCiGS5oiuw9kXMh4W4JScAqCvQKpc)nAOuV(uSuwL(igPiG3LLih3O(kTDoPhigoos)7S5CqC5eZxmNSWiNwiNKSxx)HiObXnrSRiND43wDoTxoTqoTDoXHvoe8gPiKt7v6RKjAUnLwJJgWg8qomLyxGBCZH4LeibuYhHRYWFJgkv6nAOetehnKtKhYHjN2wzVsF5YcLUHldoSM1f5WkhcEJuekjhIWeG(SWqzNcJsYHaYM7Gqz1ReBEGdJpYkObXvPs(i83OHs96trvlRsFeJueW7YsKJBuFLKSxx)noy1MV53wDPVsMO52uALJch2GhYHPeBEGdJpYkObX1LL8r4Qm83OHsLyxGBCZH4Leibu6nAOetWrHlNipKdtoTTL9k9LllusJSAeYwuPKCicta6ZcdLDkmkjhciBUdcLvVs(iRgHS(uk5JWFJgk1RpfMuzv6JyKIaExwICCJ6RKEGy44i9VZMZbXLtmFXCsrrjNygZYjMkNg(zwh39h2peJgHmS6bIHJJ0)GyKIaEoTqoPhigoos)7S5CqC5eZxmNunvjNygZYjyl2g1Qb8)GgfXbUridRhm8lNwiNGTyBuRgW)ppalo4aJvGhWkfriCSQh3LtlKt6bIHJJ0)oBohexoX8CAhJCAHC6MiiU)z9aEWd5W8dIrkc4L(kzIMBtjy4Nh2GhYHPe7cCJBoeVKajGs(iCvg(B0qPsVrdL(m8ZlNipKdtoTTYELKdrycqFwyOStHrj5qazZDqOS6vInpWHXhzf0G4QujFe(B0qPE9PS1LvPpIrkc4DzjYXnQVss2RR)CiGeJWbyp0b6FoOhJiKt7lNuyu6RKjAUnLo0bAS6jCaFtj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXcDGoN8NWb8nLKdrycqFwyOStHrj5qazZDqOS6vInpWHXhzf0G4QujFe(B0qPE9POkLvPpIrkc4DzjYXnQVss2RR)GZdbbSOvSNhGvghMdBWwGdCJq2VT6sFLmrZTPem8ZBl2dgOe7cCJBoeVKajGs(iCvg(B0qPsVrdL(m8ZBl2dgiN2wzVsYHimbOplmu2PWOKCiGS5oiuw9kXMh4W4JScAqCvQKpc)nAOuV(u2vwL(igPiG3LLih3O(kjzVU(RgTFGJfTI98aS6bIHJJ0)2QZPfYPXDgRawqaAdeYP9LtQAPVsMO52ukAK5DcJqgwju8kXUa34MdXljqcOKpcxLH)gnuQ0B0qjM2iZ7egHSCAjkE502k7vsoeHja9zHHYofgLKdbKn3bHYQxj28ahgFKvqdIRsL8r4VrdL61NIQvwL(igPiG3LLih3O(knUZyfWccqBGqoX8CsjNwiNg3zScybbOnqiNyEoPu6RKjAUnLCEJrGnAK5DcJqwj2f4g3CiEjbsaL8r4Qm83OHsLEJgkXM3ye5etBK5DcJqwj5qeMa0Nfgk7uyusoeq2ChekRELyZdCy8rwbniUkvYhH)gnuQxFkm5YQ0hXifb8US0xjt0CBkfnY8oHridRekELyxGBCZH4LeibuYhHRYWFJgkv6nAOetBK5DcJqwoTefVCABl7vsoeHja9zHHYofgLKdbKn3bHYQxj28ahgFKvqdIRsL8r4VrdL61NfgLvPpIrkc4DzjYXnQVsCyLdbVrkcL(kzIMBtP14ObSbpKdtj28ahgFKvqdIRll5JWvz4VrdLkXUa34MdXljqcO0B0qjMioAiNipKdtoTTL9k9LllusJSAeYwur19gUm4WAwxKdRCi4nsrOKCicta6ZcdLDkmkjhciBUdcLvVs(iRgHS(uk5JWFJgk1RplkLvPpIrkc4DzPVsMO52ucg(5Hn4HCykXMh4W4JScAqCDzjFeUkd)nAOuj2f4g3CiEjbsaLEJgk9z4NxorEihMCABl7v6lxwOKgz1iKTOsj5qeMa0Nfgk7uyusoeq2ChekREL8rwncz9PuYhH)gnuQxFwSuwL(igPiG3LL(kzIMBtP14ObSbpKdtj28ahgFKvqdIRll5JWvz4VrdLkXUa34MdXljqcO0B0qjMioAiNipKdtoTTQUxPVCzHsAKvJq2IkLKdrycqFwyOStHrj5qazZDqOS6vYhz1iK1NsjFe(B0qPE9kroUr9vQxl]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20170828.180304, [[da0(jaqijLQnPuYOKu4ueLmljfPDjPAykvhtclJi9mjfLPruQRPGW2uq03uiJtbjNtsr16iIQMNcQUNsP2NcsDqkLfsP6Hkftusj6IkuBusj9rIOYjrLAMerUjLStf9tjfXsrupfAQiyReH9k(lQyWi5WuTyu1JvYKLQlRAZkWNLKrlrNMWRjQMnf3MKDd63OmCIIJRGYYj1ZLY0bUoISDe67er58OswVKsy(skL9JuNIqi40vpikuBOPgBU6qGBOPKCUI3iGvsEAkB1KXbRLFGtYaI9GKV5E7zkDVy0(iPJQlvQ0Hs2brz(s4grTWbcgmtPdP0G2wabd2cHmlcHGJHoV59ypOnEHra4kydW0k5)YCDqUHDXYbmDqid(GwSUeUE6Qhm40vpicyAL8FzUoi5BU3EMs3lgvShK8Bms61BHqab3u(LClgXRoee(GwS(0vpyazknecog68M3J9G4slKbeeWQQmV(IXmDMKbBbTXlmcaxb926WUdxpi3WUy5aMoiKbFqlwxcxpD1dgC6Qh0wBDy3HRhK8n3BptP7fJk2ds(ngj96TqiGGBk)sUfJ4vhccFqlwF6QhmGmRzHqWXqN38ESh0gVWiaCf0iggjrNJYRuohadCvqUHDXYbmDqid(GwSUeUE6Qhm40vpOKedJKOttz5vkNMIadCvqY3CV9mLUxmQypi53yK0R3cHacUP8l5wmIxDii8bTy9PREWaYu2HqWXqN38EShexAHmGG1GMYxabXZ5WReVrtnCAkzttTfnLYVPb0mv9fjT(qan1qVnnL0DAkzrtTfnvnOP0FG(TsN3CAkzf0gVWiaCfCGXvNtRKTKhKByxSCatheYGpOfRlHRNU6bdoD1dwRgxDAkSKTKh0MUQfe46Qd4igST(d0Vv68MhK8n3BptP7fJk2ds(ngj96TqiGGBk)sUfJ4vhccFqlwF6QhmGmhIqi4yOZBEp2dAJxyeaUcExdkhgjx(dYnSlwoGPdczWh0I1LW1tx9GbNU6bh7Aq5Wi5YFqY3CV9mLUxmQypi53yK0R3cHacUP8l5wmIxDii8bTy9PREWaYCidHGJHoV59ypiU0czab7mq9bgxDoTs2sED9vUa2OPgAAQL3aCac1PP2IMIN0Gb1norNtJKU61jjdn1w0u1onfWnhcQBevLaOawXrZ61p05nVttTfnLVacINZHxjEJMA40uYoOnEHra4kOXj6C4jPBGGCd7ILdy6Gqg8bTyDjC90vpyWPREqj5eDAk7K0nqqY3CV9mLUxmQypi53yK0R3cHacUP8l5wmIxDii8bTy9PREWaYCuieCm05nVh7bXLwidiyTttbCZHG6grvjakGvC0SE9dDEZ70uBrt5lGG45C4vI3OPgon1qqtvB1gnfWnhcQBevLaOawXrZ61p05nVttTfnLVacINZHxjEJMA40uYoOnEHra4k4nxDiWnC4nEdeKByxSCatheYGpOfRlHRNU6bdoD1do2C1Ha3qtz34nqqY3CV9mLUxmQypi53yK0R3cHacUP8l5wmIxDii8bTy9PREWaYCOcHGJHoV59ypOnEHra4kOXj6C4VRcYnSlwoGPdczWh0I1LW1tx9GbNU6bLKt0PPSFxfK8n3BptP7fJk2ds(ngj96TqiGGBk)sUfJ4vhccFqlwF6QhmGmR5HqWXqN38EShexAHmGG9ZtAWG6grvjakGvC0SE9otYGbTXlmcaxbxLUaYXiQkbqbSki3WUy5aMoiKbFqlwxcxpD1dgC6QhCtPlG0ussuvcGcyvqB6QwqGRRoGJyW29ZtAWG6grvjakGvC0SE9otYGbjFZ92Zu6EXOI9GKFJrsVEleci4MYVKBXiE1HGWh0I1NU6bdiZI9qi4yOZBEp2dAJxyeaUcUkDbKJruvcGcyvqUHDXYbmDqid(GwSUeUE6Qhm40vp4MsxaPPKKOQeafWkAQAuiRGKV5E7zkDVyuXEqYVXiPxVfcbeCt5xYTyeV6qq4dAX6tx9GbKzrrieCm05nVh7bTXlmcaxbnorNdpjDdeCt5xYTyeV6qqSh0I1LW1tx9Gb5g2flhW0bHm4doD1dkjNOttzNKUbOPQrHScAtx1cQyefWQTlcs(M7TNP09Irf7bj)gJKE9wieqqlgrbSkZIGwS(0vpyazwinecog68M3J9G4slKbeu)b63kDEZdAJxyeaUcoW4QZPvYwYdUP8l5wmIxDii2dAX6s46PREWGCd7ILdy6Gqg8bNU6bRvJRonfwYwYPPQrHScAtx1cQyefWQTlQPaxxDahXGT1FG(TsN38GKV5E7zkDVyuXEqYVXiPxVfcbe0IruaRYSiOfRpD1dgqabXLwidiyaja]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20170828.180304, [[daKotaqiQcSjc0Ouf6uQcELQeYSOQkXUKsddQ6yczzIINHKuttvcUgsc2gsI(MQuJJQQ4Cij06OQkvZJQQ6EIs2NOuhekAHQIEibmrQQs6IqHnsvqFuvc1jPkAMQs0nLIDQQwkH8uutLG2kvv2RYFHkdMuhwYIrQhtPjlvxgSzO0NjuJwuDAQ8AKy2ICBs2nIFdz4uLoossworpxW0v56c12PQ8DQcDEKuRNQQuMVQK2pfVOjC8VuWy2PeWOXibkGCvYOFXLIo5iI93n6GJiobgDfSJ9xbSvC62ZXIGeuby)m4JEJ)DM3TzYKXFEHXSxW6QKZFRohISFgQmZymTNdrct4(rt4ymifDc675y2kDEVXhsS4e0ArOuh5rsWOf0OF0O7ORfBQuaUqoYsPvcQYrcgD2gnDmwSTvWcKErSqBpwwNdrmAbn6hn6ZPaJo7SmAQeVr)6RgnDmwST0jeQNIdxBSxJ(bJwqJ2IqPoYJK2u5RWrhldxReuLJem6SnA8gTGgThy00XyX2goKurbaVGSn2Rr)WymPDj3r94kybsViwySNKUZwhsoMGiW4gu3Vs(lfmE8VuWymdwG0lIfglcsqfG9ZGp6De(XIGakwAHWeUBSa5GLsdYhOaYn6XnO(VuW4D7NzchJbPOtqFphZwPZ7n2dm6ZzP4iIn6xF1O7ORfBQuaUqoYsPvcQYrcgT)ZYOfB7JXK2LCh1JXMkfGlKJSug7jP7S1HKJjicmUb19RK)sbJh)lfm2dtLcmAohzPmweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72NQNWXyqk6e03ZXSv68EJvfKcNePATXsjqoJo7Sm6m4nAbnAjOkhjy0(plJMogl22kybsViwOThlRZHigTGgTfHsDKhjTvWcKErSqReuLJem6xKrthJfBBfSaPxel02JL15qeJ2)zz09yzDoezmM0UK7OEm2uPaCHCKLYypjDNToKCmbrGXnOUFL8xky84FPGXEyQuGrZ5ilfJ(XOhglcsqfG9ZGp6De(XIGakwAHWeUBSa5GLsdYhOaYn6XnO(VuW4D7)ct4ymifDc675ymPDj3r9yibkGCvchDQc3ypjDNToKCmbrGXnOUFL8xky84FPGXyKafqUkz0ptv4glcsqfG9ZGp6De(XIGakwAHWeUBSa5GLsdYhOaYn6XnO(VuW4D7tfMWXyqk6e03ZXSv68EJPJXITfS5iiGdHf3Ld4elH6WfIjDq6iIBJ9A0cA0EGrthJfBBfSaPxel0g71Of0OvfKcNePATXsjqoJo7SmA)HkhJjTl5oQhdL8YPQ4Icm2ts3zRdjhtqeyCdQ7xj)Lcgp(xkymgL8YPQ4IcmweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72NkNWXyqk6e03ZXSv68EJvfKcNePATXsjqoJo7Sm6OO3g9RVA0EGrxYZHTSxBWJqk5iIXPkifojs1cKIobDJwqJwvqkCsKQ1glLa5m6SZYOPIzgJjTl5oQhdL8YXfYrwkJ9K0D26qYXeebg3G6(vYFPGXJ)LcgJrjVCJMZrwkJfbjOcW(zWh9oc)yrqaflTqyc3nwGCWsPb5dua5g94gu)xky8U9FpHJXGu0jOVNJzR059gpgtAxYDupoCiPIcaEb5ypjDNToKCmbrGXnOUFL8xky84FPGX8HKkka4fKJfbjOcW(zWh9oc)yrqaflTqyc3nwGCWsPb5dua5g94gu)xky8U99NjCmgKIob99CmBLoV34Xys7sUJ6Xjhvf764uLyvH7qhOg7jP7S1HKJjicmUb19RK)sbJh)lfm(LoQk21n6MsSQmAHOduJfbjOcW(zWh9oc)yrqaflTqyc3nwGCWsPb5dua5g94gu)xky8U9PIt4ymifDc675y2kDEVX0XyX26f5rqIdHf3Ld4ufKcNePAJ9A0cA00XyX2goKurbaVGSn2RrlOrx2Z5dWbeq5GGr7FJMQhJjTl5oQhNCIZpIJighnkDJ9K0D26qYXeebg3G6(vYFPGXJ)Lcg)sN48J4iIn6NO0nweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72pc)eogdsrNG(EoMTsN3BChDTytLcWfYrwkTsqvosWOZ2OTv4WDofy0cA0pA0wek1rEKGtcL9m6xF1OPJXITTcwG0lIfAJ9A0pmgtAxYDupov(kC0XYWn2ts3zRdjhtqeyCdQ7xj)Lcgp(xky8llFLr)mwgUXIGeuby)m4JEhHFSiiGILwimH7glqoyP0G8bkGCJECdQ)lfmE3(rrt4ymifDc675y2kDEVXpA0QcsHtIuT2yPeiNrNDwgDg8gTGgnDmwSTqcua5QeoSiBCOn2Rr)GrlOr)OrlbSsiKx0jWOFymM0UK7OEm2uPaCHCKLYypjDNToKCmbrGXnOUFL8xky84FPGXEyQuGrZ5ilfJ(XmpmgtP4W4RKIHdNdBwsaRec5fDcglcsqfG9ZGp6De(XIGakwAHWeUBSa5GLsdYhOaYn6XnO(VuW4D7hLzchJbPOtqFphZwPZ7nwvqkCsKQ1glLa5m6SZYOJIIm6xF1O9aJUKNdBzV2GhHuYreJtvqkCsKQfifDc6gTGgTQGu4KivRnwkbYz0zNLr7puPr)6RgnqvXoVEHEBqHsDq6iIXLdL8mAbnAGQIDE9c92lhW1bl48bYao6ec1X5TSNrlOrRkifojs1AJLsGCgD2g9B8gTGg9vjGCTf2dKHCKLslqk6e0hJjTl5oQhdL8YXfYrwkJ9K0D26qYXeebg3G6(vYFPGXJ)LcgJrjVCJMZrwkg9JrpmweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72pIQNWXyqk6e03ZXSv68EJPJXITvcbePiwa3Hoq1kbv5ibJ2)gDeEJ(1xn6hnA6ySyBLqarkIfWDOduTsqvosWO9Vr)OrthJfBBfSaPxel02JL15qeJ(fz0wek1rEK0wblq6fXcTsqvosWOFWOf0OTiuQJ8iPTcwG0lIfALGQCKGr7FJoIky0pmgtAxYDup(qhOWPQWbsQh7jP7S1HKJjicmUb19RK)sbJh)lfmwi6aLr3uHdKupweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72p6fMWXyqk6e03ZXSv68EJl758b4acOCqWOZ2OJmAbn6YEoFaoGakhem6Sn6OXys7sUJ6XPYxHJgk1ypjDNToKCmbrGXnOUFL8xky84FPGXVS8vg9tOuJfbjOcW(zWh9oc)yrqaflTqyc3nwGCWsPb5dua5g94gu)xky8U9JOct4ymifDc675y2kDEVX0XyX26f5rqIdHf3Ld4ufKcNePAJ9A0cA0L9C(aCabuoiy0(3OP6Xys7sUJ6XjN48J4iIXrJs3ypjDNToKCmbrGXnOUFL8xky84FPGXV0jo)ioIyJ(jkDg9JrpmweKGka7NbF07i8JfbbuS0cHjC3ybYblLgKpqbKB0JBq9FPGX72pIkNWXyqk6e03ZXSv68EJl758b4acOCqWOZ2OJmAbn6YEoFaoGakhem6Sn6OXys7sUJ6X28YrWLCIZpIJiESNKUZwhsoMGiW4gu3Vs(lfmE8VuWybYlhXOFPtC(rCeXJfbjOcW(zWh9oc)yrqaflTqyc3nwGCWsPb5dua5g94gu)xky8U9JEpHJXGu0jOVNJXK2LCh1JtoX5hXreJJgLUXEs6oBDi5ycIaJBqD)k5VuW4X)sbJFPtC(rCeXg9tu6m6hZ8WyrqcQaSFg8rVJWpweeqXsleMWDJfihSuAq(afqUrpUb1)LcgVB)i)zchJbPOtqFphZwPZ7nwcyLqiVOtWymPDj3r9ySPsb4c5ilLXcKdwkniFGci3EoUb19RK)sbJh7jP7S1HKJjicm(xkyShMkfy0CoYsXOFKQFymMsXHXkKphrCwr(lxjfdhoh2SKawjeYl6emweKGka7NbF07i8JfbbuS0cHjC34gKphr8(rJBq9FPGX72pIkoHJXGu0jOVNJXK2LCh1JHsE54c5ilLXcKdwkniFGci3EoUb19RK)sbJh7jP7S1HKJjicm(xkymgL8YnAohzPy0pM5HXykfhgRq(CeXzfnweKGka7NbF07i8JfbbuS0cHjC34gKphr8(rJBq9FPGX72pd(jCmgKIob99CmM0UK7OEm2uPaCHCKLYybYblLgKpqbKBph3G6(vYFPGXJ9K0D26qYXeebg)lfm2dtLcmAohzPy0p(cpmgtP4WyfYNJioROXIGeuby)m4JEhHFSiiGILwimH7g3G85iI3pACdQ)lfmE3UXSv68EJ3Tba]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170828.180304, [[di0)maqiIsXIqr1MafzueLCkuu2fu1WaPJbILrKEgjknnqbUgks2gjk(gOQXruQohOOY6aLAEOi19afAFKO6GsIfIs6HssteuqDrsyJOi0ibfvDsIIzIIOBQe7ek)efbdfuuSuu4PitLiUkrP0wjQ6RGIs7v8xjLbtPdRyXK0JLyYk1LvTzIkFgLA0kPonHxJsmBuDBsTBGFdz4sQwov9CkMUuxhQSDqLVdk58kjRhuqMpjY(PYbsKecg(Yn44Dyne2OFisOR6Sk4xFqpCy7S7l3GJ3HyC(hZdMuOqGhk8sHhVuPsLDyqiQ4f17qHQuAbcyIKGbjscPamQ8VJAiQ4f17qnInB(Xxqi(gblGXzHjNvwoBpE2VXV(dVxJVEPDwM2zLYuoRsk5STqFNv5olu8mfuOolZcvrvWf9QqRVhjm6qYa2IY0iFiac8qlOT8JhB0puiSr)qW83JegDigN)X8Gjfke4HaneJBq48LBIK0HQU(fwwqWD9bDudTG2yJ(HshmPrsifGrL)Dynev8I6DOgXMn)4RJAbcyCwyYzLLZwqi(gblaE5e(x78RpOhoE)1JayCwL7SsLDOoRsk5S94z)gFl0VwJQTf3zzAy0zvgOolZcvrvWf9Qq1rTabcjdylktJ8HaiWdTG2YpESr)qHWg9dbZGAbceIX5FmpysHcbEiqdX4geoF5MijDOQRFHLfeCxFqh1qlOn2OFO0btzJKqkaJk)7WAiQ4f17qnInB(Xla99EC1BtOkQcUOxfcwcWUMz9hFizaBrzAKpeabEOf0w(XJn6hke2OFiywby7S06p(qmo)J5btkuiWdbAig3GW5l3ejPdvD9lSSGG76d6OgAbTXg9dLoyWGijKcWOY)oSgIkEr9oKko5KdV)geyaLxRr9149xpcGXzzANvAOkQcUOxfQr9110JPVFvizaBrzAKpeabEOf0w(XJn6hke2OFijO(ANDzm99RcX48pMhmPqHapeOHyCdcNVCtKKou11VWYccURpOJAOf0gB0pu6GXursifGrL)Dynev8I6DOgXMn)4lieFJGfWeQIQGl6vHKt4FTZV(GE4HKbSfLPr(qae4HwqB5hp2OFOqyJ(HyIc)Dwf8RpOhEigN)X8Gjfke4HaneJBq48LBIK0HQU(fwwqWD9bDudTG2yJ(HshmLjscPamQ8VdRHOIxuVd1i2S5hFbH4BeSaMqvufCrVkKPrEDTZV(GE4HKbSfLPr(qae4HwqB5hp2OFOqyJ(HOg51oRc(1h0dpeJZ)yEWKcfc8qGgIXniC(Ynrs6qvx)clli4U(GoQHwqBSr)qPdg8rsifGrL)Dynev8I6DOgXMn)4lieFJGfWeQIQGl6vHo)6d6HxtpM((vHKbSfLPr(qae4HwqB5hp2OFOqyJ(HuWV(GE4o7Yy67xfIX5FmpysHcbEiqdX4geoF5MijDOQRFHLfeCxFqh1qlOn2OFO0bt2JKqkaJk)7WAOkQcUOxfcN51e91MqYa2IY0iFiac8qlOT8JhB0puiSr)qYwZDwz6RnHyC(hZdMuOqGhc0qmUbHZxUjsshQ66xyzbb31h0rn0cAJn6hkDWG5IKqkaJk)7WAiQ4f17qnInB(Xxqi(gblGXzHjNvwoRSXz7HFqJFmLd2dOC8hmQ8VDwLuYzvXjNC4ht5G9akhpU6oRsk5SfeIVrWcGFmLd2dOC8(RhbW4Sk3zzkOolZcvrvWf9QqQCeAxtoC(vHKbSfLPr(qae4HwqB5hp2OFOqyJ(HyLJqBNLjIZVkeJZ)yEWKcfc8qGgIXniC(Ynrs6qvx)clli4U(GoQHwqBSr)qPdgeOrsifGrL)Dynev8I6DOgXMn)4lieFJGfW4SWKZklNv24S9WpOXpMYb7buo(dgv(3oRsk5SQ4Kto8JPCWEaLJhxDNLzHQOk4IEvi17n3ZIaWoKmGTOmnYhcGap0cAl)4Xg9dfcB0peR3BUNfbGDigN)X8Gjfke4HaneJBq48LBIK0HQU(fwwqWD9bDudTG2yJ(HshmiqIKqkaJk)7WAiQ4f17qtPfW9AhCT4gNv5oRuNfMCwz5StPfW9AhCT4gNv5oRuNvjLC2P0c4ETdUwCJZQCNvQZYSqvufCrVkKhhO2uAbcuJlmDOQRFHLfeCxFqh1qlOT8JhB0puiSr)qmWbC2kLwGaoltkmDOkE2MqGrFyK5Kqx1zvWV(GE4W2zRWeuW8qmo)J5btkuiWdbAig3GW5l3ejPdjdylktJ8HaiWdTG2yJ(HiHUQZQGF9b9WHTZwHjOiDWGinscPamQ8VdRHOIxuVd1d)Gg)ykhShq54pyu5F7SkPKZYpCN7SmTZcbk0qvufCrVkKhhO2uAbcuJlmDOQRFHLfeCxFqh1qlOT8JhB0puiSr)qmWbC2kLwGaoltkmTZklimlufpBtiWOpmYCsOR6Sk4xFqpCy7SgbGn)o7ykmpeJZ)yEWKcfc8qGgIXniC(Ynrs6qYa2IY0iFiac8qlOn2OFisOR6Sk4xFqpCy7SgbGn)o7ykPdgeLnscPamQ8VdRHOIxuVd1d)GgVOC5W5xH)GrL)DOkQcUOxfYJduBkTabQXfMou11VWYccURpOJAOf0w(XJn6hke2OFig4aoBLslqaNLjfM2zLLuMfQINTjey0hgzoj0vDwf8RpOhoSDwJaWMFNvihZdX48pMhmPqHapeOHyCdcNVCtKKoKmGTOmnYhcGap0cAJn6hIe6QoRc(1h0dh2oRrayZVZkKlDWGadIKqkaJk)7WAiQ4f17q9WpOXZfSx3abGDnpAJ)GrL)DOkQcUOxfYJduBkTabQXfMou11VWYccURpOJAOf0w(XJn6hke2OFig4aoBLslqaNLjfM2zLLYYSqv8SnHaJ(WiZjHUQZQGF9b9WHTZAea287SCpZdX48pMhmPqHapeOHyCdcNVCtKKoKmGTOmnYhcGap0cAJn6hIe6QoRc(1h0dh2oRrayZVZY9PthIQ)Iy4cyOPfiqWKQmstNa]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170828.180304, [[daducaGErO2LiY2ivPzlv3Ku(gKANuzVODty)qudtu9Bjdve0GHKgUuCqrXXOuluKSuiSysA5u1dfLEk4Xk1ZvYefbMkLmzOmDHlkLCzvxxKARqIntQITtcwgunnsiJJuvDyfVMuz0qKBt0jLs9zruNMIZtI(ljupJuvwNiKPnTiKGRNjDpykcqZ3MPBs8eMsqhUEXjG49pRthEUn6C04Otchhx)kIaS9MMGaHm7WuIfTOZMweAjg1(XykcW2BAccrLCY9NutfMsSiKr10nHscnvykbH2cmZEIYtquItqRWqz8UrEceCJ8esyfMsqaX7FwNo8CB025eq8vL2V)IwmiKfPV1PvkC5fbvjOvyUrEcmOdNweAjg1(XykczunDtOKquXLkwoR4ELeAlWm7jkpbrjobTcdLX7g5jqWnYtWQIlrgvTzf3RKaI3)SoD452OTZjG4RkTF)fTyqilsFRtRu4YlcQsqRWCJ8eyqN(OfHwIrTFmMIqgvt3ekjSIYl193CpH2cmZEIYtquItqRWqz8UrEceCJ8eGO8sD)n3taX7FwNo8CB025eq8vL2V)IwmiKfPV1PvkC5fbvjOvyUrEcmyqWnYtamYSiJAR(LxetpriJAJ)7sQobds]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170828.180304, [[deKnsaqiOKytkqJIuLtrQQvPakEfPsPMLcO0TivkSlvLHHKogLSmkvptvuMMQOQRPkQSnKq9nvvnofqohusADKkLmpOK6EQISpKGdQQYcvfEirXevavxek1gjvQojPIzQaCtbTtOAPevpf1urkBLO0EL(RcnyrDyLwmrEmvnzfDzWMHIplWOjLtt41ivZMk3MIDJ43qgUc64iHSCsEUqtxLRRkTDkLVdL48irRNuPO5tQK9lY1Q0kJVgOmlmYKYy7adqU1PBLYrbjWbPStvM9kXWRCzEi4fRtOBUNarkUDk2Ez5Gd2iuC7uT(t9V9)F2TBFGE(YYHDsjnHbkpr3hg3AGXOgYt)tbMvqI6g6nbPxmy(W4wdmg1qE6FZx1EcezGH63Z0V8p)jqKyPvCRsRm2KvYbZ(Om7vIHxzSskFcpDbjiL1LUs5j6(W4wdmg1qE6FkWScsmLX6Ns5a)S8pjHtCuwgJBnWyud5PxwhYu43dPktqeOCiAk7QWxduUm(AGY6UBnqkZAip9YYbhSrO42PA93IAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef3EPvgBYk5GzFu(NKWjokldoWaKBDJsUnEL1Hmf(9qQYeebkhIMYUk81aLlJVgOm2oWaKBDP8d3gVYYbhSrO42PA93IAz5qe9Q8qS06vwgnWtpezdma5Qu5q0eFnq5Ef)zLwzSjRKdM9rz2RedVYsVyW8bEneehrygpnymqb7ngFjtqjibFVdl)ts4ehLLHvDAu07shkRdzk87HuLjicuoenLDv4RbkxgFnqzSx1PrrVlDOSCWbBekUDQw)TOwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXF(sRm2KvYbZ(Om7vIHxzZcU4PqMp)RsbKlLPWtPSL1)uwx6kLXkP8QobM1FFrSaoNGemAwWfpfY8bKvYbZuEWu2SGlEkK5Z)Qua5szk8ukJvTx(NKWjokldR60gJAip9Y6qMc)EivzcIaLdrtzxf(AGYLXxdug7vDAPmRH80llhCWgHIBNQ1FlQLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7v8NR0kJnzLCWSpk)ts4ehLLJhszOdWqqvwhYu43dPktqeOCiAk7QWxduUm(AGY8Hug6ameuLLdoyJqXTt16Vf1YYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9kofxALXMSsoy2hLzVsm8kx(NKWjokl7eu0RyoA2aZoEOdmL1Hmf(9qQYeebkhIMYUk81aLlJVgO8aeu0RyMYHBGztzAOdmLLdoyJqXTt16Vf1YYHi6v5HyP1RSmAGNEiYgyaYvPYHOj(AGY9k()sRm2KvYbZ(Om7vIHx5j6(W4wdmg1qE6FkWScsmLPqk734nEcdKYdMYEeYnryHmQG1FL)jjCIJYYU12ok9QIxzDitHFpKQmbrGYHOPSRcFnq5Y4RbkpG12MYpEvXRSCWbBekUDQw)TOwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXhOsRm2KvYbZ(Om7vIHxz9szZcU4PqMp)RsbKlLPWtPSDQP8GPS0lgmFGdma5w3igK)n(9omL1pLhmL1lLvagfe1wjhKY6x(NKWjoklJXTgymQH80llJg4PhISbgGCvQCiAk7QWxduUm(AGY6UBnqkZAip9uwpl9l)tfelFRkaUrbMNuagfe1wjhuwo4Gncf3ovR)wullhIOxLhILwVY6qMc)EivzcIaLdrt81aL7vCSAPvgBYk5GzFuM9kXWRSzbx8uiZN)vPaYLYu4Pu2YYkL1LUszSskVQtGz93xelGZjibJMfCXtHmFazLCWmLhmLnl4INcz(8VkfqUuMcpLYdefNY6sxPmqrVIHdH5x0GCtqjibJAWQUuEWugOOxXWHW870GXj4bHnqfhLCi0CC46VuEWu2SGlEkK5Z)Qua5szkKY)PMYdMY36aY9Tyoqf1qE6FazLCWS8pjHtCuwgw1Png1qE6L1Hmf(9qQYeebkhIMYUk81aLlJVgOm2R60szwd5PNY6zPFz5Gd2iuC7uT(BrTSCiIEvEiwA9klJg4PhISbgGCvQCiAIVgOCVIBrT0kJnzLCWSpkZELy4vw6fdMpferKL4HXdDG5tbMvqIPmwNYwutzDPRuwVuw6fdMpferKL4HXdDG5tbMvqIPmwNY6LYsVyW8TrpqMlXdFZx1EcejL1Ttzpc5MiSq(2OhiZL4HpfywbjMY6NYdMYEeYnryH8TrpqMlXdFkWScsmLX6u265sz9l)ts4ehLLp0bMrZgpqrzzDitHFpKQmbrGYHOPSRcFnq5Y4RbktdDGjLd34bkkllhCWgHIBNQ1FlQLLdr0RYdXsRxzz0ap9qKnWaKRsLdrt81aL7vClRsRm2KvYbZ(Om7vIHxz9szPxmy(gIWcOgrygpny0SGlEkK57DykpykV(tydgbcyeqmLX6u(zPS(P8GPSEP8eKEXG5Zjc0oIGemQqZVjclKuw)Y)KeoXrzzNiq7icsWOeYDLLrd80dr2adqUkvoenLDv4RbkxgFnq5bic0oIGeKYpqUR8pvqS8TQa4gfyEAcsVyW85ebAhrqcgvO53eHfsz5Gd2iuC7uT(BrTSCiIEvEiwA9kRdzk87HuLjicuoenXxduUxXTSxALXMSsoy2hLzVsm8kl9IbZ3qewa1icZ4PbJMfCXtHmFVdt5bt51FcBWiqaJaIPmwNYpR8pjHtCuw2jc0oIGemkHCxzDitHFpKQmbrGYHOPSRcFnq5Y4RbkparG2reKGu(bYDPSEw6xwo4Gncf3ovR)wullhIOxLhILwVYYObE6HiBGbixLkhIM4Rbk3R4wpR0kJnzLCWSpkZELy4vwVuE9NWgmceWiGyktHu2kLhmLx)jSbJabmciMYuiLTsz9t5btz9s5ji9IbZNteODebjyuHMFtewiPS(L)jjCIJYYETvqgDIaTJiibLLrd80dr2adqUkvoenLDv4RbkxgFnqzz0wbjLhGiq7icsq5FQGy5BvbWnkW80eKEXG5Zjc0oIGemQqZVjclKYYbhSrO42PA93IAz5qe9Q8qS06vwhYu43dPktqeOCiAIVgOCVIB98LwzSjRKdM9rz2RedVYR)e2GrGagbetzkKYwP8GP86pHnyeiGraXuMcPSv5FscN4OSSxBfKrNiq7icsqzDitHFpKQmbrGYHOPSRcFnq5Y4RbklJ2kiP8aebAhrqcsz9S0VSCWbBekUDQw)TOwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXTEUsRm2KvYbZ(Om7vIHx5ji9IbZNteODebjyuHMFtewiL)jjCIJYYorG2reKGrjK7klJg4PhISbgGCvQCiAk7QWxduUm(AGYdqeODebjiLFGCxkRND9l)tfelFRkaUrbMNMG0lgmForG2reKGrfA(nryHuwo4Gncf3ovR)wullhIOxLhILwVY6qMc)EivzcIaLdrt81aL7vClkU0kJnzLCWSpk)ts4ehLLDIaTJiibJsi3vwhYu43dPktqeOCiAk7QWxduUm(AGYdqeODebjiLFGCxkR3Z0VSCWbBekUDQw)TOwwoerVkpelTELLrd80dr2adqUkvoenXxduUxXT(xALXMSsoy2hLzVsm8kRamkiQTsoO8pjHtCuwgJBnWyud5PxwgnWtpezdma56JYHOPSRcFnq5Y6qMc)EivzcIaLXxduw3DRbszwd5PNY6zx)Y)ubXYgKnbj4jRb2BvbWnkW8KcWOGO2k5GYYbhSrO42PA93IAz5qe9Q8qS06voeztqckUv5q0eFnq5Ef3AGkTYytwjhm7JY)KeoXrzzyvN2yud5PxwgnWtpezdma56JYHOPSRcFnq5Y6qMc)EivzcIaLXxdug7vDAPmRH80tz9SRF5FQGyzdYMGe8Kvz5Gd2iuC7uT(BrTSCiIEvEiwA9khISjibf3QCiAIVgOCVIBHvlTYytwjhm7JYSxjgELVvfa33ueVL4HuMcPmfx(NKWjoklJXTgymQH80llJg4PhISbgGC9r5q0u2vHVgOCzDitHFpKQmbrGY4RbkR7U1aPmRH80tz9EM(L)PcILniBcsWtwLLdoyJqXTt16Vf1YYHi6v5HyP1RCiYMGeuCRYHOj(AGY96vEGdy2x31h9Ab]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170828.180304, [[deuyuaqiuuztkbJsjQtPezvOOOxrsKAwQkj5wQkj1UuQggkCmsSmsQNHIQMMQsQRHIcBtvP6BQkghjrDosIyDQkjAEOi6EkH2hkshuvvluP4HOuMijrYfvvzJOiCsuQMjkkDtbTtvzPeXtrMkkzRKK2R0FHKblYHvSyI6XuzYqCzWMvsFMinAk1PP41qQzlQBtQDt43qnCbCCvLy5O65u10v56uY2fOVRQuoVsP1RQKW8jjSFHUkLvP3OHsKrZwm9ldAqCt(RmM8gH0metM1sKJBcCLkrbaNzYMVI5myrFQ)U6ssGmmEOp1mu(W4J6p7QvRwL)6ssGbzllJgkHGV918ObuEBSd9oh0Jr4)QxgbKTwx3xZJgq5TXo07iw85mybZKXoZVuP)UZGf(YQpLYQ0pXiNbKUPe54MaxjMlMoJdTrinMuHkIje8TVMhnGYBJDO35GEmcFmXKlgtsDiL(lBYMBBP18ObuEBSdDj2fig3CyEjbwaLcXiQo83OHsLEJgkXe5rdXezJDOljbYW4H(uZq5JcJssap2I7aFz1ReB2GdDioiObXv5sHyK3OHs96tDzv6NyKZas3uICCtGRKS166o4SXGhfEf1zdOKYH5q5Teia3iKUBfiMwiM0dK9hhR3DwCoiUyIPlgtQ83l9x2Kn32sWWp7VynOHsSlqmU5W8scSakfIruD4VrdLk9gnu63Wp7VynOHssGmmEOp1mu(OWOKeWJT4oWxw9kXMn4qhIdcAqCvUuig5nAOuV(y(YQ0pXiNbKUPe54MaxjzR11DJdwT4B3Tcetlet6bY(JJ17olohexmX0fJjffLyAHyI5IjzR119X7abYiCWUvGs)LnzZTT0kh7puEBSdDj2fig3CyEjbwaLcXiQo83OHsLEJgkXeCS)IjYg7qxscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL613xxwL(jg5mG0nL(lBYMBBjidAqCtgLCE8xj2fig3CyEjbwaLcXiQo83OHsLEJgk9ldAqCtoM2Kh)vscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL61hZOSk9tmYzaPBkroUjWvspq2FCSE3zX5G4IjMUymPO8jMuHkIjMlMg(zwh3T7)gKZgHuu6bY(JJ17GyKZasmTqmPhi7powV7S4CqCXetxmMujQl9x2Kn32sWWpBuEBSdDj2fig3CyEjbwaLcXiQo83OHsLEJgk9B4NDmr2yh6ssGmmEOp1mu(OWOKeWJT4oWxw9kXMn4qhIdcAqCvUuig5nAOuV((Ezv6NyKZas3u6VSjBUTL8hMRrdqaGxIDbIXnhMxsGfqPqmIQd)nAOuP3OHs0H5A0aea4LKazy8qFQzO8rHrjjGhBXDGVS6vInBWHoehe0G4QCPqmYB0qPE99PSk9tmYzaPBkroUjWvA5yspq2FCSE3zX5G4IjMCXysHHsmTqmn8ZSoUB3)niNncPO0dK9hhR3bXiNbKysfQiMyUyA4NzDC3U)BqoBesrPhi7powVdIrodiX0cXKEGS)4y9UZIZbXftm5IX0NVhtlftletmxmjBTUUpEhiqgHd2Tcu6VSjBUTLmoy1IVTe7ceJBomVKalGsHyevh(B0qPsVrdLy3bRw8TLKazy8qFQzO8rHrjjGhBXDGVS6vInBWHoehe0G4QCPqmYB0qPE9PYLvPFIrodiDtjYXnbUsL(lBYMBBPS5lwgeu6rQEqD4d0LyxGyCZH5LeybukeJO6WFJgkv6nAOeZA(ILbjMchP6jMyHpqxscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL61NkPSk9tmYzaPBkroUjWvs2ADDpa(BahfEf1zdO0dK9hhR3TcetletYwRR7(dZ1ObiaW3TcetletJ7mbbuGa0gWhtmzmX8L(lBYMBBPSrQ9jmcPOKX5Re7ceJBomVKalGsHyevh(B0qPsVrdLywJu7tyesJPn48vscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL61NcJYQ0pXiNbKUPe54Maxje8TVMhnGYBJDO35GEmcFmX0yYn(d1z0qmTqm5W4mc(BcuCyCxP)YMS52wkpbhuYwC)vIDbIXnhMxsGfqPqmIQd)nAOuP3OHsm7eCIPnwC)vscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL61NIszv6NyKZas3uICCtGRKS166UXbRw8T7wbIPfIPLJPLJj9az)XX6DNfNdIlMy6IXKAgX0sXKkurmjBTUUBCWQfF7oh0Jr4JjMmMwoMu2zgXeZmM8bGCgL94piMyMXKS166UXbRw8T7(BCOJjv6ysjMwkMwQ0Fzt2CBlTYX(dL3g7qxIDbIXnhMxsGfqPqmIQd)nAOuP3OHsmbh7VyISXo0X0YklvscKHXd9PMHYhfgLKaESf3b(YQxj2Sbh6qCqqdIRYLcXiVrdL61NI6YQ0pXiNbKUPe54MaxPLJj9az)XX6DNfNdIlMy6IXKAgX0cXKS166oKbniUjJAf7S87wbIPLIPfIPLJjoSYbV9iNHyAPs)LnzZTT0AE0akVn2HUeB2GdDioiObXv5sHyevh(B0qPsVrdLyI8OHyISXo0X0Yklv6pxQV0nCPWHYSUihw5G3EKZqjjqggp0NAgkFuyusc4XwCh4lRELyxGyCZH5LeybukeJ8gnuQxFkmFzv6NyKZas3uICCtGRKS166UXbRw8T7wbk9x2Kn32sRCS)q5TXo0LyZgCOdXbbniUUPuigr1H)gnuQe7ceJBomVKalGsVrdLyco2FXezJDOJPLvVuP)CP(sACqJq6IkLKazy8qFQzO8rHrjjGhBXDGVS6vkeh0iK2NsPqmYB0qPE9P81LvPFIrodiDtjYXnbUs6bY(JJ17olohexmX0fJjffLysfQiMyUyA4NzDC3U)BqoBesrPhi7powVdIrodiX0cXKEGS)4y9UZIZbXftmDXysL)EmPcvetWxSmbcai7EnoJaCJqkkBy4xmTqmbFXYeiaGSF2akeWbMGa3JsoJXiOcmUlMwiM0dK9hhR3DwCoiUyIPX0hgX0cX0nzqC7Z6bCVn2HEheJCgqk9x2Kn32sWWpBuEBSdDj2fig3CyEjbwaLcXiQo83OHsLEJgk9B4NDmr2yh6yAzLLkjbYW4H(uZq5JcJssap2I7aFz1ReB2GdDioiObXv5sHyK3OHs96tHzuwL(jg5mG0nLih3e4kjBTUUZbpwmchG6WhO35GEmcFmXKXKcJs)LnzZTT0HpqJsp(d4BlXUaX4MdZljWcOuigr1H)gnuQ0B0qjw4d0Xu44pGVTKeidJh6tndLpkmkjb8ylUd8LvVsSzdo0H4GGgexLlfIrEJgk1RpLVxwL(jg5mG0nLih3e4kjBTUUdoBm4rHxrD2akPCyouElbcWncP7wbk9x2Kn32sWWp7VynOHsSlqmU5W8scSakfIruD4VrdLk9gnu63Wp7VynOHyAzLLkjbYW4H(uZq5JcJssap2I7aFz1ReB2GdDioiObXv5sHyK3OHs96t5tzv6NyKZas3uICCtGRKS166Ea83aok8kQZgqPhi7powVBfiMwiMg3zccOabOnGpMyYyI5l9x2Kn32szJu7tyesrjJZxj2fig3CyEjbwaLcXiQo83OHsLEJgkXSgP2NWiKgtBW5lMwwzPssGmmEOp1mu(OWOKeWJT4oWxw9kXMn4qhIdcAqCvUuig5nAOuV(uu5YQ0pXiNbKUPe54MaxPXDMGakqaAd4JjMgtkX0cX04otqafiaTb8XetJjLs)LnzZTTKZEmcuzJu7tyeslXUaX4MdZljWcOuigr1H)gnuQ0B0qj2ShJiMywJu7tyesljbYW4H(uZq5JcJssap2I7aFz1ReB2GdDioiObXv5sHyK3OHs96trLuwL(jg5mG0nL(lBYMBBPSrQ9jmcPOKX5Re7ceJBomVKalGsHyevh(B0qPsVrdLywJu7tyesJPn48ftlREPssGmmEOp1mu(OWOKeWJT4oWxw9kXMn4qhIdcAqCvUuig5nAOuV(uZOSk9tmYzaPBkroUjWvIdRCWBpYzO0Fzt2CBlTMhnGYBJDOlXMn4qhIdcAqCDtPqmIQd)nAOuj2fig3CyEjbwaLEJgkXe5rdXezJDOJPLvVuP)CP(sACqJq6IkFv3WLchkZ6ICyLdE7rodLKazy8qFQzO8rHrjjGhBXDGVS6vkeh0iK2NsPqmYB0qPE9PwPSk9tmYzaPBk9x2Kn32sWWpBuEBSdDj2Sbh6qCqqdIRBkfIruD4VrdLkXUaX4MdZljWcO0B0qPFd)SJjYg7qhtlREPs)5s9L04GgH0fvkjbYW4H(uZq5JcJssap2I7aFz1RuioOriTpLsHyK3OHs96tT6YQ0pXiNbKUPe54MaxPB4sHBhX4Vr4GyIPX03l9x2Kn32sR5rdO82yh6sSzdo0H4GGgex3ukeJO6WFJgkvIDbIXnhMxsGfqP3OHsmrE0qmr2yh6yAzMFPs)5s9L04GgH0fvkjbYW4H(uZq5JcJssap2I7aFz1RuioOriTpLsHyK3OHs96vsLcwhR81n9Ab]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170828.180304, [[de0nkaqifOAtkLAueHofrWQuaPzPaQULcOSlIQHbHJjrlJeEMcuMMcW1uqyBkO4BkuJtbLoNcewNcenpLsCpuu2NcIoOeAHsWdvkMOcKCrfYgvqYjjsMjkQUjjTtL8tfi1srHNImviARer7v8xizWOYHPAXO0Jv0KLYLvTzs0NLuJwsonHxtuMnLUnP2nOFd1WjsDCfuTCkEUunDGRRuTDi13vkPZJISEfqmFfKA)OQtzqgA56hIe6n8CJSxFiWTdsEUId6rHOPriniuOb1v67wqkeIXT37plfikhJySIXYvOqXWoGqmU3ycPq)qnmqUsRRpQEfEktU5Axa7dmj2o7UsLYvAD9r1RWtzYB7ghiWWbkc5dMecvCceyypiZQmidnc6S23sHqfzfwbGPqDa2OL9l9nHKc2ethGnHGy4dPIBs6MLRFOqlx)qeaB0Y(L(MqmU9E)zPar54seHy8oE3mFpidi0MQpLPIrF9HGWgsf3wU(HcilfbzOrqN1(wkeIMgH0GqaCDT9YNySTH3kShQiRWkamfY7ZdBoC(qsbBIPdWMqqm8HuXnjDZY1puOLRFOI95HnhoFig3EV)SuGOCCjIqmEhVBMVhKbeAt1NYuXOV(qqydPIBlx)qbK1GfKHgbDw7BPqOIScRaWuiRy47IgkTxRDuam46qsbBIPdWMqqm8HuXnjDZY1puOLRFiMlg(UOXZP61ANNdjgCDig3EV)SuGOCCjIqmEhVBMVhKbeAt1NYuXOV(qqydPIBlx)qbK1acYqJGoR9TuienncPbHKipNpbc0h1HxlENNBl8CdGNBBEoTFBhyWA5ZDJ5qap3qYmEofi45Kap328CsKNZCLM3RCw755KqOIScRaWuiLwxFu9k8uwOnvFktfJ(6dbHnKkUjPBwU(HcTC9dnuwxFEoQcpLfQOPUhc4M6dqjuYmZvAEVYzTpeJBV3FwkquoUerigVJ3nZ3dYacjfSjMoaBcbXWhsf3wU(HciRHiidnc6S23sHqfzfwbGPq3nGQHV7YEiPGnX0bytiig(qQ4MKUz56hk0Y1p0i3aQg(Ul7HyC79(ZsbIYXLicX4D8Uz(EqgqOnvFktfJ(6dbHnKkUTC9dfqwdtqgAe0zTVLcHOPriniuddKR066JQxHNYKBU2fWop3qYZn9oafqOpp328CS7kvk36ODu9Dt9LVlnp328CdophWThcKBf1vaOawJYGBYp0zTVXZTnpNpbc0h1HxlENNBl8CdiurwHvaykK1r7Oy3nDqiPGnX0bytiig(qQ4MKUz56hk0Y1peZD0opxHDtheIXT37plfikhxIieJ3X7M57bzaH2u9Pmvm6Rpee2qQ42Y1puaznoidnc6S23sHq00iKgeAW55aU9qGCROUcafWAugCt(HoR9nEUT558jqG(Oo8AX78CBHNBi45g6HMNd42dbYTI6kauaRrzWn5h6S23452MNZNab6J6WRfVZZTfEUbeQiRWkamf62Rpe4wuSwVdcjfSjMoaBcbXWhsf3K0nlx)qHwU(HgzV(qGB55ky9oieJBV3FwkquoUerigVJ3nZ3dYacTP6tzQy0xFiiSHuXTLRFOaYAydYqJGoR9TuiurwHvaykK1r7OyVRdjfSjMoaBcbXWhsf3K0nlx)qHwU(HyUJ255kCxhIXT37plfikhxIieJ3X7M57bzaH2u9Pmvm6Rpee2qQ42Y1puaznicYqJGoR9TuienncPbHANDxPs5wrDfakG1Om4M8gERWqfzfwbGPqZkxarzf1vaOawhAt1NYuXOV(qqydPIBs6MLRFOqlx)qBQCbKNJ5I6kauaRdv0u3dbCt9bOekzw7S7kvk3kQRaqbSgLb3K3WBfgIXT37plfikhxIieJ3X7M57bzaHKc2ethGnHGy4dPIBlx)qbKvjIGm0iOZAFlfcvKvyfaMcnRCbeLvuxbGcyDiPGnX0bytiig(qQ4MKUz56hk0Y1p0Mkxa55yUOUcafWAEojwkHqmU9E)zPar54seHy8oE3mFpidi0MQpLPIrF9HGWgsf3wU(HciRYYGm0iOZAFlfcvKvyfaMczD0ok2DtheAt1NYuXOV(qqkesf3K0nlx)qHKc2ethGnHGy4dTC9dXChTZZvy30b8CsSucHkAQ7H0y0cynZkdX4279NLceLJlreIX74DZ89GmGqQy0cyDwLHuXTLRFOaYQurqgAe0zTVLcHOPriniK5knVx5S2hQiRWkamfsP11hvVcpLfAt1NYuXOV(qqkesf3K0nlx)qHKc2ethGnHGy4dTC9dnuwxFEoQcpLXZjXsjeQOPUhsJrlG1mRCGdCt9bOekzM5knVx5S2hIXT37plfikhxIieJ3X7M57bzaHuXOfW6SkdPIBlx)qbeqis6pfUvmqCGadZsXWOiGea]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170828.180304, [[daKCtaqiKqTjKkJsvWPuf6vQsiZIQQuDlvju7skggu1XeYYKGNrvGPPkbxdjO2MQe9nvPghvvX5qcY6OQkX8OQQUNeQ9jHCqvvwOQOhIu1ePQkPlQQQnsvqNKQkZejWnLs7eklLqEkQPIu2kvr7v5VqLbtQdlAXe8yknzP6YGnRQ8zc1OLOttLxJKMTKUnj7gXVHmCQshhjKLt0ZfmDvUUqTDQkFNQqNhjA9uvLY8vL0(P4fnAJXsfmMDk6n6)vqbKlR(lgDWrexbJod2XSv68EJh7VcFzC92ZXIGkKbyyfWh9g)7cVBkuOG)8cJfbzNsAofmwcQ0rcVyH4VVMmybspjwOPhlZZHiJ)zphIegTHfnAJ)tsHk03ZXSv68EJpKyXvOXIq1oYJKGrtNr)Gr3rxZxnvaUqjYsTrcQ0rcgDrgTq83xtgSaPNel00JL55qeJMoJ(bJ(CkWOlQyJ(L4n6xF1OfI)(AeQiuVghUMyVg9JgnDgTfHQDKhjn10xItiwgUgjOshjy0fz04nA6mAk2OfI)(AchsQOcGxq2e71OFC8pbx1DuoodwG0tIfg7hP7S5HKJjicmUf19mLyPcgpglvW4Fblq6jXcJfbvidWWkGp6De(XIGakwAHWOTBm9LGLAlYhOaYnHXTOowQGX7gwHrB8FskuH(EoMTsN3BmfB0NZs1reB0V(Qr3rxZxnvaUqjYsTrcQ0rcgT)l2OfB7J)j4QUJYXF1ub4cLil1X(r6oBEi5ycIaJBrDptjwQGXJXsfm2dRPcmAUezPoweuHmadRa(O3r4hlccOyPfcJ2UX0xcwQTiFGci3eg3I6yPcgVByEWOn(pjfQqFphZwPZ7nwLqnCsKQXglLa5m6Ik2OlG3OPZOLGkDKGr7)InAH4VVMmybspjwOPhlZZHignDgTfHQDKhjnzWcKEsSqJeuPJem6xKrle)91Kblq6jXcn9yzEoeXO9FXgDpwMNdrg)tWvDhLJ)QPcWfkrwQJ9J0D28qYXeebg3I6EMsSubJhJLkyShwtfy0CjYs1OFi6XXIGkKbyyfWh9oc)yrqaflTqy02nM(sWsTf5dua5MW4wuhlvW4Dd7fgTX)jPqf6754FcUQ7OCmubfqUSItOMHBSFKUZMhsoMGiW4wu3ZuILky8ySubJ)xbfqUSA0pRz4glcQqgGHvaF07i8JfbbuS0cHrB3y6lbl1wKpqbKBcJBrDSubJ3nmk8On(pjfQqFphZwPZ7nwi(7RbSLiiGd9H7kbCILqE4cXKoiDeXnXEnA6mAk2OfI)(AYGfi9KyHMyVgnDgTkHA4KivJnwkbYz0fvSr7pVC8pbx1Duogs5vsrXjvySFKUZMhsoMGiW4wu3ZuILky8ySubJ)NYRKIItQWyrqfYamSc4JEhHFSiiGILwimA7gtFjyP2I8bkGCtyClQJLky8UH9YrB8FskuH(EoMTsN3BSkHA4KivJnwkbYz0fvSrhf92OF9vJMIn6uEUV0Enbpc1QJigNkHA4KivdqsHk0nA6mAvc1WjrQgBSucKZOlQyJMcvy8pbx1Duogs5vIluISuh7hP7S5HKJjicmUf19mLyPcgpglvW4)P8knAUezPoweuHmadRa(O3r4hlccOyPfcJ2UX0xcwQTiFGci3eg3I6yPcgVByVhTX)jPqf6754FcUQ7OCC4qsfva8cYX(r6oBEi5ycIaJBrDptjwQGXJXsfmMpKurfaVGCSiOczagwb8rVJWpweeqXslegTDJPVeSuBr(afqUjmUf1XsfmE3W8NrB8FskuH(EoMTsN3B84FcUQ7OCC1rrXUoovkwL4o0bQX(r6oBEi5ycIaJBrDptjwQGXJXsfmMcCuuSRB0TPyvA00qhOglcQqgGHvaF07i8JfbbuS0cHrB3y6lbl1wKpqbKBcJBrDSubJ3nmk0On(pjfQqFphZwPZ7nwi(7RXlYJGeh6d3vc4ujudNePAI9A00z0cXFFnHdjvubWliBI9A00z0P9C(aCabuoiy0(3O9GX)eCv3r54QtC5rCeX4eq1BSFKUZMhsoMGiW4wu3ZuILky8ySubJPaN4YJ4iIn6NO6nweuHmadRa(O3r4hlccOyPfcJ2UX0xcwQTiFGci3eg3I6yPcgVByr4hTX)jPqf675y2kDEVXD018vtfGluISuBKGkDKGrxKrBZWH7CkWOPZOFWOTiuTJ8ibNes7z0V(Qrle)91Kblq6jXcnXEn6hh)tWvDhLJRPVeNqSmCJ9J0D28qYXeebg3I6EMsSubJhJLkymfK(sJ(zSmCJfbvidWWkGp6De(XIGakwAHWOTBm9LGLAlYhOaYnHXTOowQGX7gwu0On(pjfQqFphZwPZ7n(bJwLqnCsKQXglLa5m6Ik2OlG3OPZOfI)(AGkOaYLvCFiBCOj2Rr)OrtNr)GrlHpjektHky0po(NGR6okh)vtfGluISuhtFjyP2I8bkGCtyClQ7zkXsfmEmwQGXEynvGrZLilvJ(Hcpo(NuCy8LsXWHZ9vSe(KqOmfQWyrqfYamSc4JEhHFSiiGILwimA7g7hP7S5HKJjicmUf1XsfmE3WIkmAJ)tsHk03ZXSv68EJvjudNePASXsjqoJUOIn6OOiJ(1xnAk2Ot55(s71e8iuRoIyCQeQHtIunajfQq3OPZOvjudNePASXsjqoJUOInA)5Lg9RVA0aff786f6nbfQ2bPJigxjKYZOPZObkk251l0BUsaxhSGZhid4eQiuhN30EgnDgTkHA4KivJnwkbYz0fz0VXB00z0xwbY1KFhidLil1gGKcvOp(NGR6okhdP8kXfkrwQJ9J0D28qYXeebg3I6EMsSubJhJLky8)uELgnxISun6hIECSiOczagwb8rVJWpweeqXslegTDJPVeSuBr(afqUjmUf1XsfmE3WI8GrB8FskuH(EoMTsN3BSq83xJecissSaUdDGQrcQ0rcgT)n6i8g9RVA0py0cXFFnsiGijXc4o0bQgjOshjy0(3OFWOfI)(AYGfi9KyHMESmphIy0ViJ2Iq1oYJKMmybspjwOrcQ0rcg9JgnDgTfHQDKhjnzWcKEsSqJeuPJemA)B0ruyJ(XX)eCv3r54dDGcNkdhiPCSFKUZMhsoMGiW4wu3ZuILky8ySubJPHoqz0Tz4ajLJfbvidWWkGp6De(XIGakwAHWOTBm9LGLAlYhOaYnHXTOowQGX7gw0lmAJ)tsHk03ZXSv68EJt758b4acOCqWOlYOJmA6m60EoFaoGakhem6Im6OX)eCv3r54A6lXjaPASFKUZMhsoMGiW4wu3ZuILky8ySubJPG0xA0pHunweuHmadRa(O3r4hlccOyPfcJ2UX0xcwQTiFGci3eg3I6yPcgVByru4rB8FskuH(EoMTsN3BSq83xJxKhbjo0hUReWPsOgojs1e71OPZOt758b4acOCqWO9Vr7bJ)j4QUJYXvN4YJ4iIXjGQ3y)iDNnpKCmbrGXTOUNPelvW4XyPcgtboXLhXreB0pr1ZOFi6XXIGkKbyyfWh9oc)yrqaflTqy02nM(sWsTf5dua5MW4wuhlvW4Ddl6LJ24)KuOc99CmBLoV340EoFaoGakhem6Im6iJMoJoTNZhGdiGYbbJUiJoA8pbx1Duo2wMocUQtC5rCeXJ9J0D28qYXeebg3I6EMsSubJhJLkym9LPJy0uGtC5rCeXJfbvidWWkGp6De(XIGakwAHWOTBm9LGLAlYhOaYnHXTOowQGX7gw07rB8FskuH(Eo(NGR6okhxDIlpIJigNaQEJ9J0D28qYXeebg3I6EMsSubJhJLkymf4exEehrSr)evpJ(HcpoweuHmadRa(O3r4hlccOyPfcJ2UX0xcwQTiFGci3eg3I6yPcgVByr(ZOn(pjfQqFphZwPZ7nwcFsiuMcvy8pbx1Duo(RMkaxOezPoM(sWsTf5dua52ZXTOUNPelvW4X(r6oBEi5ycIaJXsfm2dRPcmAUezPA0p4bpo(NuCySc5ZrexCK)(LsXWHZ9vSe(KqOmfQWyrqfYamSc4JEhHFSiiGILwimA7g3I85iIhw04wuhlvW4DdlIcnAJ)tsHk03ZX)eCv3r5yiLxjUqjYsDm9LGLAlYhOaYTNJBrDptjwQGXJ9J0D28qYXeebgJLky8)uELgnxISun6hk844FsXHXkKphrCXrJfbvidWWkGp6De(XIGakwAHWOTBClYNJiEyrJBrDSubJ3nSc4hTX)jPqf675y2kDEVXxkfdxt3fUKybJUiJ(LJ)j4QUJYXF1ub4cLil1X0xcwQTiFGci3EoUf19mLyPcgp2ps3zZdjhtqeymwQGXEynvGrZLilvJ(Hx4XX)KIdJviFoI4IJglcQqgGHvaF07i8JfbbuS0cHrB34wKphr8WIg3I6yPcgVB3y2lyDz15VLNdrgwHxwy3g]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20170828.180304, [[d0s8baGEIuTlIGTrez2sUjrv3gPDc0Ef7wP9RsdtrnoIugSQmCk0bvehJswOczPaAXeA5i6HGQNcTmcwNc1ejcnvaMmctNQlQGlJ66uQnRiTDIK(irLptrpxfhM03aLPre1jjk9yqoTuNNO4VuWVvvhIiXXkaccQuoi2u433qXuEDTgFFhxxcLK4(K65(mvQy1RzqjYtv7YZOGa5I1dhqHzlyZWeGjbbbbPj5GOrgQ1QLU69FdOGKecobY7)EcGaAfabhwvSyImkicr2g9GMkvS61miOs5GytHFFdft5116(KtPIvVMbbYNVnjeFcG4bNi2v7YeK0EnOqE)xdvF8GYUenK6FYG7F5Ga5I1dhqHzlywZbL)taQuoi2u433qXuEDTUp5uQy1R547JGNQ2LhpGcbqWHvflMiJcIqKTrpOumvQy1RzqqLYbXMc)(gkMYRRvqG85BtcXNaiEWjID1UmbjTxdkK3)1q1hpOSlrdP(Nm4(xoiqUy9Wbuy2cM1Cq5)eGkLdInf(9numLxxRX3hbpvTlpE8GiezB0dgpb]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170622.212605, [[d8tCiaqyQwVQQEjPQSlsvKTHc63qntvvwgLQztY5vu3efYPr13Ou45IStf2R0UjSFH6NqyycmosvuVwvPgkrnyrz4q6GkYrjvjDmk5CKQeluvSuuulwqlNIhQQ4PGhJuRtvjmruOMkctMiMUkxeLUkLIUSsxhjBuu1wvvI2Sq2or6JIk9ziAAOaFxvAKKQQNrP0OjLXJICssLBPQKUgPk19ivHUnIwlPk44IkUwLOaTJECSipwCWnR2ciSjXpDd2cNBqUNSu5gwW4cK7hTL(7(uihQLANuCKcYvCfOlmJikkT3hh94yrQJGcmHikkT3hh94yrQJGc5qTuReD0ybW)VDWGGcjn87eLX1jIWnSqoul1k5JJECSi1NcZiIIs7r4gK7L6iOGELAP2uj6WQefyfEOAL0Nct0hhlIZ(XtxbG9xCgRAjxX5Q4mzZsJjd9RWWj3ca7V4mw1sUIZvXzYMLgtg6xbMx16PTd7bwm0kiW2caTHJEfoo5Qhd61H9suGv4HQvsFkmrFCSio7hpDfa2FXzSQLCfNRIZy8g5uQRWWj3ca7V4mw1sUIZvXzmEJCk1vG5vTEA7WEGfdTccSTaqB4OxHE9kK0WVWl)O1My7tHKg(DI6W9Pqsd)cV8JwBI6W9PW5gK7njO1WMcpiiiqWiM1LR(jkm38FvphOxSZGagAzzdBdSB3gbn6RmqVleHfxHjd3vXzd3yWVfsA4xc3GCVuFk8D4KGwdBkqGqMzD5QFIcCHeoTFyZKGwdBkWSUC1prbAh94yXKGwdBk8GGGabJkaOln3v8)(XXIoSZq7fsA4xGOpfYHAPwgZnl9XXIcmRlx9tuqqrQJglsDWGcj0vPYR8K2hScBkrbVdRcHDyvazhwfmDy1Rqsd)(XrpowK6tbMqefL2BIY4DeuqYg5uQBs(xbGt(joJvTKR4C1xeNLoxiXnsIZKMIZq6KHkUazbsNPjQd3rqHqf)))Cv43jLQHfCfQMdA4xzPSDyvWvOA(hmzOFYsz7WQajxmrD4ockW4nYPuxFk4QxFojlvUpfKYt8qUIFZeZOBbVaTJECSysXrkk8HDqWYCbj8eQYNjMr3cEbxHQ5tQxFojlLTdRcgxGCjMr3cEixXV5coLXzexS9PGRq1Cqd)klvUdRcFhMhloG)F7WYEHzerrP903tQJVAvWvOAoHBqUNSu5oSkWeIOO0E67j1HvbZQk8HDqWYCHe6Qu5vEsRHfCfQMt4gK7jlLTdRcoLXNe0AytHheeeiy0p28efYHAPwj6es40(HnP(uWPmUoreMygDlesffvGjerrP9iCdY9sDeu4CdY9YJfhCZQTacBs8t3GTaJCM4KuKXzeCYTdBdkqYftSDyBbG2WrVcfCfQMpPE95KSu5oSkqJjd9twkBdlGA4KUzopwCa))2HL9cOMLgtg63K8VcaN8tCgRAjxX5QViod1S0yYq)k8bJohNrGlWQwYvCUkoBcbBbsNPj2ockq4QvCXz5AWuODeu4CdY9KLY2WcZiIIs7PtiHt7h2K6iOqsd)QVDoKlKWfit9PWmIOO0EtugVJGcmHikkTNoHeoTFytQJGcFhMhlUcYeXzGlsXzd3yWVfCkJtmJUfcPIIk4ughqxLshJ7iOqsd)QtiHt7h2K6tbsNjGOdRcU61NtYsz7tbzdN0nZXzFC0JJfXztugVqHKg(vwkBFkqJjd9twQCdlCUb5E5XIRGmrCg4IuC2Wng8BbonwaOonxGSd9UW3H5XIdUz1waHnj(PBWwGKlaIockCUb5E5XId4)3oSSxiPHFNy7tbAh94yrES4kiteNbUifNnCJb)wWvOA(hmzOFYsL7WQaRWdvRK(uiXjrv7ec2oSxihko93Fjpb3SAl4fgo5wGvTKR4CvCMSHt6M5cmVQ1tBh2dSSradTSvpz3YwllBuiPHFLLk3Nc0o6XXI8yXb8)Bhw2liB4KUzoo7JJECSOW5gK7LkeQ4))NRc)2WcOgoPBM1rJfa))2bdckWPXc9agt2HTbfYHAPwj5XId4)3oSSxGPockKd1sTs03tQpfsA4x4LF0Atiy7tbNY42uWVcOkFEn9Ab]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170622.212605, [[d8ZpiaqyrRxvLxsfYUikPxRq52OYmrunoIs1SP48kYnreonkFtvv5YkTtQAVs7MW(vf)ecdJu9BOEUGHssdwrnCeoOcokrj6yc15Oc0cvvwkrXIjYYP0dvipfSmQO1ruktKkutfstgv10v5IK4QuPYZquUosTrQKTQQQYMfY2rv(OcvFgIMgIOVRknsQG2MQQmAsz8isNKO6wubCnQu19uvv1JrYAjkHJtLYnUOfOsIJHfUWIdUjZwaH7qjxUxPWLwK7PYtTsfSPa5osBPgRFfKmSF)g3GFRuHjerrH9gLehdlc1RxGuerrH9gLehdlc1RxWn6LE5lNcla2VTEsQxiOHFhOTPCreUsfCJEPx(JsIJHfH(vycruuyp00ICVq96fKL0l9gkA9XfTGIiLml)(vyG6yyXZm5SWvVSxWNCBbqH8NzfZYTIlnpZQ2LcZjLxbzwZMHTEN6X)fRRtwbGYYiUchJB)F9E17SOfuePKz53VcduhdlEMjNfU6)RGp52cGc5pZkMLBfxAEMD8gL0MRGmRzZWwVt94)I11jtwJlauwgXvOxVcbn8l8YokTbLkviOHFhOpCLkWOWcGiPycK17(cxArU3GGsdBl8HaffbjKr(4oeTaPiIIc75OVq96fiTE9cbn8lAArUxOFfgtAqqPHTfqrOkJ8XDiAbMGpJkpSDqqPHTfKr(4oeTavsCmSyqqPHTf(qGIIGefaILILg2V8yyr9o)ZzHGg(fq7xb3Ox61Xm7sDmSOGmYh3HOfe0CYPWIq9KSqGyngxMmOncBW2IwiRpUGT(4ciRpUGu9X9ke0WVJsIJHfH(vGuerrH9gOTz96f4VrjT5gujVaW4g9mRywUvCPr2EMdxk4Nw(pZ8cpZitojdtGSaxs6a9HRxVqAi0YbZBofu5PuFCH0qOLGg(vLNs9XfsdHwocZjLNkpL6JlWXed0hUENfsZBofu5P2Vc8ybMeZWUj0jITGubQK4yyXGHHuuyKIhvrMc8zbctoHorSfOkizy)(nUb)oymvQGnfix0jITqkXmSBQqsBtsWeB)kmHikkSNJ(c1RxymjxyXbSFB9XolK02CqqPHTf(qGIIGeKR4cTqAi0s00ICpvEQ1hxiPTPCregDIylirhfvWUMcJu8OkYuiqSgJltg0QuH0qOLOPf5EQ8uQpUWuD5a)5EDhmw3bj7FKrMojLDY0BKdqs3xWn6LE5lxWNrLh2g6xbgfwilWyU6jtVaPiIIc7HMwK7fQxVWLwK75clo4MmBbeUdLC5ELcKijLXrZ9mJY426jtVahtmOuVZcaLLrCfcmbsZwineA5G5nNcQ8uRpUGB0l9oyyifCR4kqvGWY4s7KlS4a2VT(yNfiSlfMtkVbvYlamUrpZkMLBfxAKTNzc7sH5KYRafMtkpvEkvQaxs6Gs96fqtZkUN5XTyAI61lCPf5EQ8uQuHryIPNzuCbfZYTIlnpZdiuke0WVoANKyc(mbYq)kmHikkSNCbFgvEyBOE9ctiIIc7nqBZ61lqkIOOWEYf8zu5HTH61l4gnJAS)JfGBYSfKkK02eDIylirhfviOHFLl4ZOYdBd9RqsBtGyng5oUE9cP5nNcQ8u6xHGg(vLNs)ke0WVdkvQafMtkpvEQvQGQLXL2PN5rjXXWIN5bABwWLj52NzqdtnwHlTi3ZfwCfurFMHueEM9P1IFlmMKlS4GBYSfq4ouYL7vkWXeaA9olCPf5EUWIdy)26JDwiOHFHx2rPnqF4(vGkjogw4clUcQOpZqkcpZ(0AXVfsdHwocZjLNkp16JlOisjZYVFfcmocZoGqPENfgtYfwCfurFMHueEM9P1IFl4tUTGIz5wXLMN5bekf4ssb061lOAzCPD6zEusCmSOGnpgUqqd)QYtTFfOsIJHfUWIdy)26JDwqM1SzyR3PE8)0)lMmz1zmzXX)RaHLXL2j5uybW(T1ts9cPHqlbn8Rkp16Jl4g9sV8DHfhW(T1h7SqewCfgSS08m7tRf)wWn6LE57OVq)k44nkPnx)kK020Dc2vGWKtRTxla]] )


end
