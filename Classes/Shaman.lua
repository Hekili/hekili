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

        --[[ addHook( 'spend', function( amt, resource )
            if amt > 0 and resource == 'maelstrom' and state.spec.elemental and state.talent.aftershock.enabled then
                local refund = amt * 0.3
                refund = refund - ( refund % 1 )
                state.gain( refund, 'maelstrom' )
            end
        end ) ]]


        --[[ ns.addToggle( 'doom_winds', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        ns.addSetting( 'doom_winds_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and Doom Winds will be shown regardless of your Doom Winds toggle.",
            width = "full"
        } ) ]]

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

        ns.addSetting( 'save_for_aoe', false, {
            name = "Elemental: Save Stormkeeper, Liquid Magma Totem for AOE",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will not recommend Stormkeeper or Liquid Magma Totem unless there are 3 or more targets available.\n\n" ..
                "This may be useful on some fights, but would be a DPS loss overall if left on all the time.",
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



        --[[ addMetaFunction( 'toggle', 'artifact_ability', function()
            return state.toggle.artifact
        end )

        addMetaFunction( 'settings', 'artifact_cooldown', function()
            return state.settings.doom_winds_cooldown
        end ) ]]

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
            cooldown = 0,
            aura = 'lightning_rod',
            cycle = 'lightning_rod'
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
            passive = true,
            toggle = 'artifact'
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
            return max( 10, min( 100 + ( artifact.swelling_maelstrom.enabled and 25 or 0 ), maelstrom.current ) ) * ( talent.aftershock.enabled and 0.7 or 1 )
        end )

        addHandler( 'earth_shock', function ()
            removeStack( 'elemental_focus' )
            -- spend( min( maelstrom.current, 90 + ( artifact.swelling_maelstrom.enabled and 25 or 0 ) ), "maelstrom" )
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
            if buff.echoes_of_the_great_sundering.up then return 0 end
            return x * ( talent.aftershock.enabled and 0.7 or 1 )
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

            spend( cost * ( talent.aftershock.enabled and 0.7 or 1 ), 'maelstrom' )
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
            spend( cost * ( talent.aftershock.enabled and 0.7 or 1 ), 'maelstrom' )
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
        }, 8004 )

        modifyAbility( 'healing_surge', 'id', function( x )
            if spec.elemental then return 8004 end
            return x
        end )

        modifyAbility( 'healing_surge', 'cast', function( x )
            if spec.enhancement and maelstrom.current >= 20 then
                return 0
            end
            return x
        end )

        modifyAbility( 'healing_surge', 'spend', function( x )
            if spec.elemental then return 0.22 end
            return maelstrom.current >= 20 and 20 or x
        end )

        modifyAbility( 'healing_surge', 'spend_type', function( x )
            if spec.elemental then return "mana" end
            return x
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
            velocity = 1000,
            aura = 'lightning_rod',
            cycle = 'lightning_rod'
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
            passive = true,
            toggle = 'artifact'
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

    storeDefault( [[SimC Elemental Gambling: default]], 'actionLists', 20171119.111032, [[dm0rnaqiuiArKc2KqvgfkfNcLs7cLmmvvhtfTmsvpJujMgkKCnHQABKc13Gknoui15ifY6GkmpsL09uvI9rQuhuiwikvpuinrui4IKsBefk9rvLAKQkP6KerZefQUPkStO8tuOyOOqOLIIEkYujsxvvjLTsk6RQkj2R0FfkdMIdlAXe1Jfmzv5YGntQ4ZQuJwvXPr1RjcZMWTjz3k(nKHRsSCQ65uz6kDDOQTJc(ourNxL06vvsA(cv2pLUNvAjSubLiUkQ1Ovaky2uynFNkzbFUXH18aDs8ITef88lBPsmbbKoOy6)pX988uJyD(hFCp1Os0fiWtb)RMlhnftVgRVuKWYrJRsl2zLws7KYc4v5suWZVSLw09TayfqiXdHZXznXZAyJ1SP)gwwFGuSFyDjSwJUAn6JV1exCwZYvG1OBR5Nv8))Tg2wkImxW3RL(aEe3Pkj584HCr(sdAGshONMPhlvqPsyPck91bpI7uLycciDqX0)FI75FjMGdH3haxL2Tu0pqqIdedGcMTYLoqpSubL6wm9vAjTtklGxzVef88lBPfDFlawxqlhnoRjEwdBSMacjEiCoS0H7HyGauWSPGLhujFCwJUTg9m6FRjU4SMn93WYA5ki2II94G1ORFXA04FRHTLIiZf89APlOLJMssopEixKV0GgO0b6Pz6XsfuQewQGsmIOLJMsmbbKoOy6)pX98VetWHW7dGRs7wk6hiiXbIbqbZw5shOhwQGsDlMUuPL0oPSaEL9suWZVSLw09TayXNf8E8xwxPiYCbFVwcN85fZ9bsFjjNhpKlYxAqdu6a90m9yPckvclvqPVcFEwd9bsFjMGashum9)N4E(xIj4q49bWvPDlf9deK4aXaOGzRCPd0dlvqPUfJrvPL0oPSaEL9suWZVSLKXRJoS8Gdn5eGylAbflpOs(4SgD1A0xkImxW3RLw0cQyQ0TG)AjjNhpKlYxAqdu6a90m9yPckvclvqjPOfuwZr6wWFTetqaPdkM()tCp)lXeCi8(a4Q0ULI(bcsCGyauWSvU0b6HLkOu3If)kTK2jLfWRSxIcE(LT0IUVfaRacjEiCoUsrK5c(ETKoCpedeGcMnfLKCE8qUiFPbnqPd0tZ0JLkOujSubLySCpynAfGcMnfLycciDqX0)FI75FjMGdH3haxL2Tu0pqqIdedGcMTYLoqpSubL6wmnUslPDszb8k7LOGNFzlTO7BbWkGqIhcNJRuezUGVxl5wKxfdeGcMnfLKCE8qUiFPbnqPd0tZ0JLkOujSubLOf5vwJwbOGztrjMGashum9)N4E(xIj4q49bWvPDlf9deK4aXaOGzRCPd0dlvqPUfd3kTK2jLfWRSxIcE(LT0IUVfaRacjEiCoUsrK5c(ETeiafmBkIPs3c(RLKCE8qUiFPbnqPd0tZ0JLkOujSubL0kafmBkSMJ0TG)AjMGashum9)N4E(xIj4q49bWvPDlf9deK4aXaOGzRCPd0dlvqPUfJrxPL0oPSaEL9srK5c(ETeEheJVGYvsY5Xd5I8Lg0aLoqpntpwQGsLWsfu6R5aRrYfuUsmbbKoOy6)pX98VetWHW7dGRs7wk6hiiXbIbqbZw5shOhwQGsDlMgvPL0oPSaEL9suWZVSLw09TayfqiXdHZXznXZAyJ1WiTMnfWSSsxaMxobGfmPSaEwtCXznY41rhwPlaZlNaWc)fRjU4SMacjEiCoSsxaMxobGLhujFCwJUTM4)BnSTuezUGVxljlqOxmDW7VwsY5Xd5I8Lg0aLoqpntpwQGsLWsfuIDbc9SgglE)1smbbKoOy6)pX98VetWHW7dGRs7wk6hiiXbIbqbZw5shOhwQGsDl25FLws7KYc4v2lrbp)YwAr33cGvaHepeohN1epRHnwdJ0A2uaZYkDbyE5eawWKYc4znXfN1iJxhDyLUamVCcal8xSg2wkImxW3RLKbVd8sWN7ssopEixKV0GgO0b6Pz6XsfuQewQGsSdEh4LGp3LycciDqX0)FI75FjMGdH3haxL2Tu0pqqIdedGcMTYLoqpSubL6wSZZkTK2jLfWRSxIcE(LTugwodqmyafhCwJUTg9wt8Sg2ynzy5maXGbuCWzn62A0BnXfN1KHLZaedgqXbN1OBRrV1W2srK5c(ETKh)eldlhnXeC3wk6hiiXbIbqbZw5shONMPhlvqPsyPckXe)ynrclhnwdJZDBPi(BxPjvWx0aXvrTgTcqbZMcR57ujl4ZnoSMimgTAOetqaPdkM()tCp)lXeCi8(a4Q0ULKCE8qUiFPbnqPd0dlvqjIRIAnAfGcMnfwZ3PswWNBCynrymA7wSt9vAjTtklGxzVef88lBPnfWSSsxaMxobGfmPSaELIiZf89Ajp(jwgwoAIj4UTu0pqqIdedGcMTYLoqpntpwQGsLWsfuIj(XAIewoASggN7wRHnNSTue)TR0Kk4lAG4QOwJwbOGztH18DQKf85ghwJJp3cWAsxqdLycciDqX0)FI75FjMGdH3haxL2TKKZJhYf5lnObkDGEyPckrCvuRrRauWSPWA(ovYc(CJdRXXNBbynPl0TyN6sLws7KYc4v2lrbp)YwAtbmllEa0bV)klyszb8kfrMl471sE8tSmSC0etWDBPOFGGehigafmBLlDGEAMESubLkHLkOet8J1ejSC0ynmo3TwdB0Z2sr83UstQGVObIRIAnAfGcMnfwZ3PswWNBCyno(ClaRHRJgkXeeq6GIP))e3Z)smbhcVpaUkTBjjNhpKlYxAqdu6a9WsfuI4QOwJwbOGztH18DQKf85ghwJJp3cWA460TyNmQkTK2jLfWRSxIcE(LT0Mcywwc(9ND4ZDmp6XcMuwaVsrK5c(ETKh)eldlhnXeC3wk6hiiXbIbqbZw5shONMPhlvqPsyPckXe)ynrclhnwdJZDR1WgDHTLI4VDLMubFrdexf1A0kafmBkSMVtLSGp34WAC85wawJWRHsmbbKoOy6)pX98VetWHW7dGRs7wsY5Xd5I8Lg0aLoqpSubLiUkQ1Ovaky2uynFNkzbFUXH144ZTaSgHVB3smcGojEXw272ca]] )

    storeDefault( [[SimC Elemental Gambling: precombat]], 'actionLists', 20171119.111032, [[dedDcaGErkTlOuBdHYSf1nf42OANcTxYUrA)kKHPO(TKHksXGvKgUGoOc1XG05ePAHqWsHOfJOLtPhQapfSmO45k1erOAQIyYq10P6IkIlR66kOTIaBgcz7iKpks0NPOonkpwjhwQrJG(gfCsOK1js4AqOopf61uK)ksQNjsYcvjcIn)cagFWOPtYNFQ35rttzZjZmQ5umAAO9RIt2UayzzHUabiF(9(kIzg1akkA6yJoJydOPlac)I1zwABNvufXqmmcgVCwr3krruLiycTjZhxiiawwwOlWlZMZh7WYzfDlymjlZCJcclNvubyrXzR2lRaArVGGcNG2gB(fii28linLZkQaKp)EFfXmJAaDwaYVRH213krUGbe(LPGIOZp1fPGGcp28lqUIyuIGj0MmFCHGGXKSmZnkWl)8uZ7TFRrbyrXzR2lRaArVGGcNG2gB(fii28liP8ZhnnO3(TgfG8537RiMzudOZcq(Dn0U(wjYfmGWVmfueD(PUifeu4XMFbYvmvkrWeAtMpUqqaSSSqxGxMnNp2T1ziQxUGXKSmZnky7LLB6p8wbyrXzR2lRaArVGGcNG2gB(fii28la8YYn9hERaKp)EFfXmJAaDwaYVRH213krUGbe(LPGIOZp1fPGGcp28lqUCbe)iQhMDHGCja]] )

    storeDefault( [[SimC Elemental Gambling: single lr]], 'actionLists', 20171119.111032, [[dauvraqiKcTjvknkvsDkvkELQi0Sufr7cjnmK4ye1YekpdPGPPkcUgPsABKkLVPkzCQIKZrQuTosLOMNQOCpbv7dPOdQkSqb5HQunrsLixuvQnQks9rsLGtsQyMckUPkStv1sjfpf1uHuBfP0Ev(RkAWsCyrlMipMIjdXLbBMu6Zcz0cCAsEns1SPQBtPDJ43qnCvIJRkQwoHNtLPl11HKTtQ67ckDEHQ1tQeA(QKSFj9Kh6X)0cJzL9ET82dwG0PVw0fsRKxrI0LRfNIe5HAXlgZgH6spESgWdPd2pgf5xYYY6ovzk66lzDFmFbmQ0R0fZwHj7ht3In(HPvyIBO3xEOh)MKsEazHgZgH6spMgRLwzORir1Yvxvli4MQwFAHtxa2qNQaSPI4QLNfETezqg)qs5vD8XA9PfoDbyd9X6qquMSXIXembgFGrOnf)0cJh)tlm(P9PfQfoaBOpwd4H0b7hJI8lzkJ1aomkHbCd96X3dad9dSEWcKEsJpWi)0cJxVFSHE8Bsk5bKfA8djLx1XhdEWcKo9Ns(01J1HGOmzJfJjycm(aJqBk(Pfgp(Nwy8BpybsN(AjKpD9ynGhshSFmkYVKPmwd4WOegWn0RhFpam0pW6blq6jn(aJ8tlmE9(0Wqp(njL8aYcnMnc1LESekTAPcMam4oXAp7a4msazF6qrqaHIerf1LXpKuEvhFmKIo45Os6WyDiikt2yXycMaJpWi0MIFAHXJ)Pfg)ofDWZrL0HXAapKoy)yuKFjtzSgWHrjmGBOxp(EayOFG1dwG0tA8bg5Nwy869Fcd943KuYdil0y2iux6X2e8UwGTunOecG01cndVwKLFvlxDvTqJ1skAL200uDHf8Efj60MG31cSLkqsjpGul3wl2e8UwGTunOecG01cndVw09yJFiP8Qo(yifDWPlaBOpwhcIYKnwmMGjW4dmcTP4Nwy84FAHXVtrhulCa2qFSgWdPd2pgf5xYugRbCyucd4g61JVhag6hy9Gfi9KgFGr(PfgVEFDDOh)MKsEazHgZgH6spUXrrEGAkAL2001YT1Y11sAALE4eiGvbUAHM1sSA5QRQfASwCq3ksKJQl1dNAXIZed1YnJFiP8Qo(yxJfw6aCbeJ1HGOmzJfJjycm(aJqBk(Pfgp(Nwym3yHLoaxaXynGhshSFmkYVKPmwd4WOegWn0RhFpam0pW6blq6jn(aJ8tlmE9(62qp(njL8aYcnMnc1LECAALE4eiGvbUAHM1sSA5QRQfASwCq3ksKJQl1dNAXIZedJFiP8Qo(yV65OuiN2mYMNnUb7yDiikt2yXycMaJpWi0MIFAHXJ)Pfghg1ZrPqQLJmYM1cACd2XAapKoy)yuKFjtzSgWHrjmGBOxp(EayOFG1dwG0tA8bg5Nwy869Fn0JFtsjpGSqJzJqDPhJGBQA9PfoDbydDQcWMkIRwOzTysxF2klul3wlgm2JGdl5uaPPh)qs5vD8X(uFEkHs46X6qquMSXIXembgFGrOnf)0cJh)tlmomP(SwcHs46XAapKoy)yuKFjtzSgWHrjmGBOxp(EayOFG1dwG0tA8bg5Nwy869FQHE8Bsk5bKfAmBeQl94RRfBcExlWwQgucbq6AHMHxlXOul3wlsO0QLk4blq60FQfBq5OI6sTCtTCBTCDTiaTcWfKsEOwUz8djLx1XhR1Nw40fGn0hFpam0pW6blq6jn(aJqBk(PfgpwhcIYKnwmMGjW4FAHXpTpTqTWbyd9A5A5Bg)qe5gBIB8WzNIiODHl)KDkIG(uPnCbOvaUGuYdJ1aEiDW(XOi)sMYynGdJsya3qVE894gpGofrq7wOXhyKFAHXR3x3h6XVjPKhqwOXSrOU0JTj4DTaBPAqjeaPRfAgETillxlxDvTqJ1skAL200uDHf8Efj60MG31cSLkqsjpGul3wl2e8UwGTunOecG01cndVwEkDRwU6QAbEok1LlacvNf7raHIeDgaPORLBRf45OuxUaiu7a4ebmGspiCNsEmg58sA6A52AXMG31cSLQbLqaKUwOzT8IsTCBT0Phin1uBdcxa2qNkqsjpGm(HKYR64JHu0bNUaSH(yDiikt2yXycMaJpWi0MIFAHXJ)Pfg)ofDqTWbyd9A5A5BgRb8q6G9Jrr(LmLXAahgLWaUHE947bGH(bwpybspPXhyKFAHXR3xMYqp(njL8aYcnMnc1LESekTAPkahMKedC24gSufGnvexT8SArMsTC1v1Y11IekTAPkahMKedC24gSufGnvexT8SA56ArcLwTutNbiijXaurqjYwHj1YtSwmyShbhwc10zacssmavbytfXvl3ul3wlgm2JGdlHA6mabjjgGQaSPI4QLNvlY6ATCBTKMwHjutNbiijXaubsk5bKA5MXpKuEvhFCJBWEAtxdI4J1HGOmzJfJjycm(aJqBk(Pfgp(NwymACd2A5iDniIpwd4H0b7hJI8lzkJ1aomkHbCd96X3dad9dSEWcKEsJpWi)0cJxVVS8qp(njL8aYcnMnc1LESekTAPEbhwqCI1E2bWPnbVRfylvuxQLBRL00k9WjqaRcC1YZQfAy8djLx1Xh7vrbnrrIoLW(E89aWq)aRhSaPN04dmcTP4Nwy8yDiikt2yXycMaJ)PfghgvuqtuKOAje23JFiICJnXnE4Stre0UWLhRb8q6G9Jrr(LmLXAahgLWaUHE947XnEaDkIG2TqJpWi)0cJxVVCSHE8Bsk5bKfAmBeQl9yjuA1s9coSG4eR9SdGtBcExlWwQOUul3wlPPv6HtGawf4QLNvl0W4hskVQJp2RIcAIIeDkH99yDiikt2yXycMaJpWi0MIFAHXJ)PfghgvuqtuKOAje231Y1Y3mwd4H0b7hJI8lzkJ1aomkHbCd96X3dad9dSEWcKEsJpWi)0cJxVVmnm0JFtsjpGSqJzJqDPhNMwPhobcyvGRwOzTip(HKYR64JnbPIC6vrbnrrIgFpam0pW6blq6jn(aJqBk(PfgpwhcIYKnwmMGjW4FAHX3dsfPwcJkkOjks04hIi3ytCJho7uebTlCAySgWdPd2pgf5xYugRbCyucd4g61JVh34b0PicA3KgFGr(PfgVEF5NWqp(njL8aYcnMnc1LECAALE4eiGvbUAHM1I84hskVQJp2eKkYPxff0efjASoeeLjBSymbtGXhyeAtXpTW4X)0cJVhKksTegvuqtuKOA5A5BgRb8q6G9Jrr(LmLXAahgLWaUHE947bGH(bwpybspPXhyKFAHXR3xwxh6XVjPKhqwOXpKuEvhFSxff0efj6uc77X6qquMSXIXembgFGrOnf)0cJhFpam0pW6blq6jn(NwyCyurbnrrIQLqyFxlxh7MXperUXM4gpC2PicAx4YJ1aEiDW(XOi)sMYynGdJsya3qVE894gpGofrq7wOXhyKFAHXR3xw3g6XVjPKhqwOXpKuEvhFSxff0efj6uc77X6qquMSXIXembgFGrOnf)0cJh)tlmomQOGMOir1siSVRLRPHBgRb8q6G9Jrr(LmLXAahgLWaUHE947bGH(bwpybspPXhyKFAHXR3x(1qp(njL8aYcnMnc1LESa0kaxqk5HXpKuEvhFSwFAHtxa2qF89aWq)aRhSaPxOX6qquMSXIXembgFGrOnf)0cJhFG1Rir7lp(Nwy8t7tlulCa2qVwUo2nJFiICJTy9ksu4YpPjUXdNDkIG2fU8t2Pic6tL2WfGwb4csjpmwd4H0b7hJI8lzkJ1aomkHbCd96X3JB8a6uebTBHgFGr(PfgVEF5NAOh)MKsEazHg)qs5vD8Xqk6Gtxa2qF89aWq)aRhSaPxOXhyeAtXpTW4X6qquMSXIXembg)tlm(Dk6GAHdWg61Y1XUz8drKBSfRxrIcxESgWdPd2pgf5xYugRbCyucd4g61JpW6vKO9LhFGr(PfgVE9yDjqBIY3l06na]] )

    storeDefault( [[SimC Elemental Gambling: single if]], 'actionLists', 20171119.111032, [[deKVtaqivsAtKunkvjDkvjwLkPkVsuOywKazxQuddrogHwMOQNPsIMMOq11ujHTrc4BqHXPsQCorHSosGY8GI09efTpsqhekzHQepek1effkDrvP2iuu(OkPQojj0mHIQBQc7uvTus0trnve1wjPSxP)QkgSqhwXIj4XuAYq1LbBwf9zeA0uPttQxJGzlYTPy3e9BidNKCCvsz5i9CQA6kDDQy7IsFhkIZlQSEsGQ5lky)cUILC5)yGYS2GDi(obgqUtkeV(JriPLevWcrVwsmbHO(SmBPAvB5YkHemEO)8KeXquumJUfjDfyiMrLzvGvpjTc(SAKS)8kq(Yyzxns6l5(fl5YVLJqcW7LYSLQvTLVAiUAlbTKyiMHmeI4O9(mng4X7ISeUPGz0sFiIPzgIeT4LXsqN0BUYNPXapExKLqzfL4A7SiAzjscLpq4Qn0)yGYL)JbkJzPXaHi7ISekResW4H(ZtsedrsLvcEKd1c(sUBzSDblHduwWaYTcLpq4)XaL72F(sU8B5iKa8EPmBPAvBzbNZZBW6Ia)d68zDHhIuy2hVJehOAjXBhvHO6HOzGKFPiZT1Hsb5gIkmZq86uGYyjOt6nxzyOR71CgcqzfL4A7SiAzjscLpq4Qn0)yGYL)Jbk)EOR71CgcqzLqcgp0FEsIyisQSsWJCOwWxYDlJTlyjCGYcgqUvO8bc)pgOC3(VYsU8B5iKa8EPmBPAvBzbNZZBTfoDO5UDufIQhIMbs(LIm3whkfKBiQWmdrrrXqu9q8QHOGZ5594TGeFKw42rvzSe0j9MR8jf53hVlYsOSIsCTDweTSejHYhiC1g6Fmq5Y)XaLXmkYVHi7ISekResW4H(ZtsedrsLvcEKd1c(sUBzSDblHduwWaYTcLpq4)XaL72FgVKl)wocjaVxkJLGoP3CLHeya5oPhH043YkkX12zr0YsKekFGWvBO)XaLl)hdu(DcmGCNuiEjn(TSsibJh6ppjrmejvwj4roul4l5ULX2fSeoqzbdi3ku(aH)hduUB)xrjx(TCesaEVuMTuTQTSzGKFPiZT1Hsb5gIkmZquueJqmdzieVAio0vFo292JjqkPLeFmdK8lfzUb5iKa8qu9q0mqYVuK526qPGCdrfMziMr5lJLGoP3CLHHUUpExKLqzfL4A7SiAzjscLpq4Qn0)yGYL)Jbk)EORBiYUilHYkHemEO)8KeXqKuzLGh5qTGVK7wgBxWs4aLfmGCRq5de(Fmq5U9RaLC53Yrib49sz2s1Q2YlIiXeCp0vFo2nevpeFneVAi6HD1sI(B)KfEor0NbbH4lLXsqN0BUY(frneaqfqlROexBNfrllrsO8bcxTH(hduU8FmqzErudbaub0YkHemEO)8KeXqKuzLGh5qTGVK7wgBxWs4aLfmGCRq5de(Fmq5U9Jrjx(TCesaEVuMTuTQT8RHOzGKFPiZT1Hsb5gIyAMHOijXqu9qCOR(CS7ThtGuslj(ygi5xkYCdYrib4HygYqiE1qCOR(CS7ThtGuslj(ygi5xkYCdYrib4HO6HOzGKFPiZT1Hsb5gIyAMHigkqi(siQEiE1quW588E8wqIpslC7OQmwc6KEZvwBHthAUYkkX12zr0YsKekFGWvBO)XaLl)hduwrlC6qZvwjKGXd9NNKigIKkRe8ihQf8LC3Yy7cwchOSGbKBfkFGW)Jbk3T)RRKl)wocjaVxkZwQw1w(QHOh2vlj6V9tw45erFgeuglbDsV5kN0xZrJ)ygIM5zrlykROexBNfrllrsO8bcxTH(hduU8FmqzmxFnhnEiEmentisgTGPSsibJh6ppjrmejvwj4roul4l5ULX2fSeoqzbdi3ku(aH)hduUB)zujx(TCesaEVuMTuTQTSGZ55TkeMa0h05Z6cpMbs(LIm3oQcr1drbNZZB)IOgcaOcO3oQcr1dXXU6SWdibJg8HiMgIxzzSe0j9MRCst0DLAjXhbuAlROexBNfrllrsO8bcxTH(hduU8Fmqzmxt0DLAjXq8ckTLvcjy8q)5jjIHiPYkbpYHAbFj3Tm2UGLWbklya5wHYhi8)yGYD7xKujx(TCesaEVuMTuTQTmoAVptJbE8UilHBkygT0hIkmeTJFFwTbcr1drlcLWryI8HcJDlJLGoP3CLtt25rWH63YkkX12zr0YsKekFGWvBO)XaLl)hdugZNStiEXH63YkHemEO)8KeXqKuzLGh5qTGVK7wgBxWs4aLfmGCRq5de(Fmq5U9lkwYLFlhHeG3lLzlvRAll4CEERTWPdn3TJQqu9q81quW588wBHthAUBkygT0hIyAi(AikEFfH41le9QGu6XD8leIxVquW588wBHthAUB)owcHygtikgIVeIVuglbDsV5kFsr(9X7ISekROexBNfrllrsO8bcxTH(hduU8FmqzmJI8BiYUilHq8vXxkResW4H(ZtsedrsLvcEKd1c(sUBzSDblHduwWaYTcLpq4)XaL72Vy(sU8B5iKa8EPmBPAvB5xdrZaj)srMBRdLcYnevyMHyEsHO6HOGZ55nKadi3j9CISo(BhvH4lHO6H4RHifoPG3Desqi(szSe0j9MR8zAmWJ3fzjugBxWs4aLfmGCRq5deUAd9pgOCzfL4A7SiAzjscL)JbkJzPXaHi7ISecXxfFPmwuI(Y2C2e8SdLiS(mfvq7qjc7J(mtkCsbV7iKGYkHemEO)8KeXqKuzLGh5qTGVK7wg7C2eqEOeH13lLpq4)XaL72V4vwYLFlhHeG3lLzlvRAll4CEERTWPdn3TJQYyjOt6nx5tkYVpExKLqzSDblHduwWaYTxkFGWvBO)XaLlROexBNfrllrsO8FmqzmJI8BiYUilHq818VuglkrFzdkRwsmtXYkHemEO)8KeXqKuzLGh5qTGVK7w(aLvlj2Vy5de(Fmq5U9lMXl5YVLJqcW7LYSLQvTLndK8lfzUTouki3quHzgIIIIHygYqiE1qCOR(CS7ThtGuslj(ygi5xkYCdYrib4HO6HOzGKFPiZT1Hsb5gIkmZq86uGqmdzieHR5OvPcWV9guchOAjXhxyOBiQEicxZrRsfGFVUWdoybDwG6Fesie(JQXUHO6HOzGKFPiZT1Hsb5gIkmeXGuiQEiUtcK79CUa17ISeUb5iKa8YyjOt6nxzyOR7J3fzjuwrjU2olIwwIKq5deUAd9pgOC5)yGYVh66gISlYsieFv8LYkHemEO)8KeXqKuzLGh5qTGVK7wgBxWs4aLfmGCRq5de(Fmq5U9lEfLC53Yrib49sz2s1Q2YcoNN3uWJKJ0cplAbZnfmJw6drmnefjvglbDsV5kVOfmpMXVanxzfL4A7SiAzjscLpq4Qn0)yGYL)JbktgTGjepg)c0CLvcjy8q)5jjIHiPYkbpYHAbFj3Tm2UGLWbklya5wHYhi8)yGYD7xubk5YVLJqcW7LYSLQvTLfCopVbRlc8pOZN1fEisHzF8osCGQLeVDuvglbDsV5kddDDVMZqakROexBNfrllrsO8bcxTH(hduU8Fmq53dDDVMZqacXxfFPSsibJh6ppjrmejvwj4roul4l5ULX2fSeoqzbdi3ku(aH)hduUB)IyuYLFlhHeG3lLzlvRAll4CEERcHja9bD(SUWJzGKFPiZTJQqu9qCSRol8asWObFiIPH4vwglbDsV5kN0eDxPws8raL2YkkX12zr0YsKekFGWvBO)XaLl)hdugZ1eDxPwsmeVGsBi(Q4lLvcjy8q)5jjIHiPYkbpYHAbFj3Tm2UGLWbklya5wHYhi8)yGYD7x86k5YVLJqcW7LYSLQvTLh7QZcpGemAWhIkmefdr1dXXU6SWdibJg8HOcdrXYyjOt6nxzR7OLpjnr3vQLelROexBNfrllrsO8bcxTH(hduU8FmqzSDhTmeXCnr3vQLelResW4H(ZtsedrsLvcEKd1c(sUBzSDblHduwWaYTcLpq4)XaL72VygvYLFlhHeG3lLXsqN0BUYjnr3vQLeFeqPTSIsCTDweTSejHYhiC1g6Fmq5Y)XaLXCnr3vQLedXlO0gIVM)LYkHemEO)8KeXqKuzLGh5qTGVK7wgBxWs4aLfmGCRq5de(Fmq5U9NNujx(TCesaEVuMTuTQTmfoPG3DesqzSe0j9MR8zAmWJ3fzjugBxWs4aLfmGC7LYkkX12zr0YsKekFGWvBO)XaLlFGYQLe7xS8FmqzmlngiezxKLqi(A(xkJfLOVSbLvljMPOcYMZMGNDOeH1NPOcAhkryF0NzsHtk4DhHeuwjKGXd9NNKigIKkRe8ihQf8LC3YyNZMaYdLiS(EP8bc)pgOC3(ZlwYLFlhHeG3lLXsqN0BUYWqx3hVlYsOm2UGLWbklya52lLpq4Qn0)yGYLvuIRTZIOLLiju(pgO87HUUHi7ISecXxZ)szSOe9LnOSAjXmflResW4H(ZtsedrsLvcEKd1c(sUB5duwTKy)ILpq4)XaL72TCglCooPTx62ca]] )

    storeDefault( [[SimC Elemental Gambling: AOE]], 'actionLists', 20171119.111032, [[daevkaqiLqztarJsjWPiOAwiQ0UusnmeCmcTmPsptjeMMsuUgIk2Mse(gqACkbPZrqX6iOK5Pev3diSpLi6GsKfsbpuIAIkHOlQKSrLq1hjOuNKaMjIQUPe2Ps9tLGYsrINcnvGAReO9k(lImyuCyQwmk9yjnzaxw1Mru(mfnAPQtt0RPqZMKBtPDd63OA4eKJRePLtQNlLPR46iPTJqFxjioVuX6vcQMVsiTFK6igWb3U9brPTmnZk1ThoUIMry7wwLeAkSOzkTWwfeRAPqtWGuU6E7z3LGiOIIIcZArcKdOIctquOxLUsUW9rYHz3Dj6gSuDKCylGZwmGdUc6SQdedbXQwk0eC4MMQV21JKmVoblXkvYPtW2W1wJ)cDDqbGaYQpCDqih(GfCabD92TpyWTBFqC4ARXFHUoiLRU3E2DjicQiHGuEJtvxFlGZeSC)Rgl4eV9WjSbl4aB3(GzYUBahCf0zvhigcIvTuOj4WnnvFDLZva8fcSfSeRujNob9w9qahwFqbGaYQpCDqih(GfCabD92TpyWTBFWsT6HaoS(GuU6E7z3LGiOIecs5novD9TaotWY9VASGt82dNWgSGdSD7dMj7frahCf0zvhigcwIvQKtNGk5sPkbizDtRtA4ZTbfaciR(W1bHC4dwWbe01B3(Gb3U9bjVCPuLa0mfUP1PzaZNBds5Q7TNDxcIGksiiL34u113c4mbl3)QXcoXBpCcBWcoW2TpyMSxwahCf0zvhigcIvTuOj4cOz86ijEshER8nAMLtZSmAgqsZy9RAJMBxxPQ1ho0mljiOz6sGMr40mGKMzb0m6tM(TENvDAgHhSeRujNobjt52tQ1ZRgdwU)vJfCI3E4e2GfCabD92TpyqbGaYQpCDqih(GB3(GlUYTNMb75vJblPnBbRDQQtACT5Ngiej3X1MFijjde6tM(TENv9GuU6E7z3LGiOIecs5novD9TaotWYDQQd21MFAXqWcoW2TpyMSjNao4kOZQoqmeSeRujNobVRN(Ls1n(GcabKvF46Gqo8bl4ac66TBFWGB3(GRC90VuQUXhKYv3Bp7UeebvKqqkVXPQRVfWzcwU)vJfCI3E4e2GfCGTBFWmzVebCWvqNvDGyiiw1sHMGa8znzk3EsTEE14A9TUe2OzwsAMQ3gsJ0EAgqsZWsLmYwRCIoPgvT5xtviAgqsZSy0mJRoCwRKM9ducnjP5aRp0zvhGMbK0mEDKepPdVv(gnZYPzwwWsSsLC6eu5eDsSu1TjOaqaz1hUoiKdFWcoGGUE72hm42Tpi5DIonJbQ62eKYv3Bp7UeebvKqqkVXPQRVfWzcwU)vJfCI3E4e2GfCGTBFWmzdAahCf0zvhigcIvTuOj4IrZmU6WzTsA2pqj0KKMdS(qNvDaAgqsZ41rs8Ko8w5B0mlNMHCOzw0fLMzC1HZAL0SFGsOjjnhy9HoR6a0mGKMXRJK4jD4TY3OzwonZYcwIvQKtNGxD7HJRiXQ82euaiGS6dxheYHpybhqqxVD7dgC72hCL62dhxrZyq5TjiLRU3E2DjicQiHGuEJtvxFlGZeSC)Rgl4eV9WjSbl4aB3(GzYEHgWbxbDw1bIHGLyLk50jOYj6KyVBdkaeqw9HRdc5WhSGdiOR3U9bdUD7dsENOtZy4UniLRU3E2DjicQiHGuEJtvxFlGZeSC)Rgl4eV9WjSbl4aB3(GzYwyc4GRGoR6aXqqSQLcnbhxD4Swjn7hOeAssZbwFOZQoqWsSsLC6eS27sijL0SFGsOzWY9VASGt82dNWgSGdiOR3U9bdkaeqw9HRdc5WhC72hSCVlH0mKxA2pqj0myjTzlyTtvDsJRn)0aHyqkxDV9S7sqeurcbP8gNQU(waNjy5ov1b7AZpTyiybhy72hmt2Iec4GRGoR6aXqWsSsLC6eS27sijL0SFGsOzqbGaYQpCDqih(GfCabD92TpyWTBFWY9UesZqEPz)aLqtAMfik8GuU6E7z3LGiOIecs5novD9TaotWY9VASGt82dNWgSGdSD7dMjBrXao4kOZQoqmeSeRujNobvorNelvDBcwU)vJfCI3E4edbl4ac66TBFWGcabKvF46Gqo8b3U9bjVt0Pzmqv3gAMfik8GL0MTGworj0eeIbPC192ZUlbrqfjeKYBCQ66BbCMGfCIsOz2Ibl4aB3(GzYwSBahCf0zvhigcIvTuOjO(KPFR3zvpyjwPsoDcsMYTNuRNxngSC)Rgl4eV9Wjgckaeqw9HRdc5WhSGdiOR3U9bdwWjkHMzlgC72hCXvU90mypVAKMzbIcpyjTzlOLtucnbHi5w7uvN04AZpnqisUJRn)qssgi0Nm9B9oR6bPC192ZUlbrqfjeKYBCQ66BbCMGL7uvhSRn)0IHGfCGTBFWmzcUipzov1edzsa]] )

    storeDefault( [[SimC Elemental Gambling: single asc]], 'actionLists', 20171119.111032, [[dauFtaqivLytiuJskvNskLxjLqnlPKQDjjddjDmQQLjP6zekAAsjKRjLu2MQs5BiOXjLiNJqH1jLGAEsj5EskTpHuhejSqvfpejAIsjGlIq2OuI6JsjqNKq1mvvs3uQSteTuQINsAQeYwfs2RYFLQgmkhw0Ij4Xumzv5YGnRQ6ZiLrlfNMsVgPA2sCBQSBO(nKHlehxvPA5e9CbtxLRluBNQ03ju68iW6LsqMVKI9JQN)enLmDWu16OKZiQaoaFzHZAbtNqXIP1cZzblMwb4SmyMQgPnYnDQhOazagzDQ(e677lgv(uBnc9fJPAeWyZITfkplcpY6FR(ukmNfHdt0i9NOPeHtHc82NPQrAJCtpenAfOYGqLhsS4aNrmN1oN9qx1FjDqFObzOxjbxAXbolAoti()Vkdga)sSbQEXY8SimNrmN1oNDwhWzrxlN9nQCwn1WzcX))vcfe6vIdxvCeoRnoJyoZGqLhsS4Qs6n7fILHRscU0IdCw0CgvoJyo7lCMq8)Fv4qshDaIaYQ4iCwBtPqWwShbtZGbWVeBGPIJFwtEi5umcdt7qVOsjz6GPtjthmLIGbWVeBGPEGcKbyK1P6tOp1PEGakwAGWeTBkLnGHEhYl4a8nHPDOhz6GP7gz9jAkr4uOaV9zQAK2i30VWzN1q3IPXz1udN9qx1FjDqFObzOxjbxAXboRv1Yz0mVPuiyl2JGP)L0b9HgKH(uXXpRjpKCkgHHPDOxuPKmDW0PKPdM2YL0bCM2Gm0N6bkqgGrwNQpH(uN6bcOyPbct0UPu2ag6DiVGdW3eM2HEKPdMUBKI5enLiCkuG3(mvnsBKBQlHs4KixLjwkb8XzrxlNvNkNrmNLMZIWvzWa4xInqfGtHc84mI5mj4sloWzTQwoti()Vkdga)sSbQEXY8SimNrmNzqOYdjwCvgma(LydujbxAXboRfZzcX))vzWa4xInq1lwMNfH5SwvlN9IL5zr4Puiyl2JGP)L0b9HgKH(uXXpRjpKCkgHHPDOxuPKmDW0PKPdM2YL0bCM2Gm05S29BBQhOazagzDQ(e6tDQhiGILgimr7MszdyO3H8coaFtyAh6rMoy6Ur2IMOPeHtHc82NPuiyl2JGPqbCa(YsVqjd3uXXpRjpKCkgHHPDOxuPKmDW0PKPdMsubCa(YcN9PKHBQhOazagzDQ(e6tDQhiGILgimr7MszdyO3H8coaFtyAh6rMoy6Ur2At0uIWPqbE7Zu1iTrUPcX))vGPbbHE0F)1a90KqE9Hy8dKwmTQ4iCgXC2x4mH4))Qmya8lXgOkocNrmN5sOeojYvzILsaFCw01YzT03MsHGTypcMcP8A(ECshMko(zn5HKtXimmTd9IkLKPdMoLmDWuIs51894Kom1duGmaJSovFc9Po1deqXsdeMODtPSbm07qEbhGVjmTd9ithmD3i)2enLiCkuG3(mvnsBKBQlHs4KixLjwkb8XzrxlN57tiNvtnC2x4SuE2)0CvbXcLIftR3LqjCsKRcWPqbECgXCMlHs4KixLjwkb8XzrxlNjg1NsHGTypcMcP8A6dnid9PIJFwtEi5umcdt7qVOsjz6GPtjthmLOuEnCM2Gm0N6bkqgGrwNQpH(uN6bcOyPbct0UPu2ag6DiVGdW3eM2HEKPdMUBKeortjcNcf4TptvJ0g5MEiA0kqvkp7FAooJyoRDolnN1l0dyWzHaNfnNvNZQPgo7lCwaUZIPfQcPxO)hj7teWzTnLcbBXEemnCiPJoara5uXXpRjpKCkgHHPDOxuPKmDW0PKPdMQhs6Odqeqo1duGmaJSovFc9Po1deqXsdeMODtPSbm07qEbhGVjmTd9ithmD3iBPjAkr4uOaV9zQAK2i300CwVqpGbNfcCw0CwDoRMA4SVWzb4olMwOkKEH(FKSprWukeSf7rW0I97X2xVlP5Y(dDGBQ44N1KhsofJWW0o0lQusMoy6uY0bt)Q97X2hN1L0CjNjcDGBQhOazagzDQ(e6tDQhiGILgimr7MszdyO3H8coaFtyAh6rMoy6Urkgt0uIWPqbE7Zu1iTrUPcX))vrqIfK9O)(Rb6DjucNe5QIJWzeZzcX))vHdjD0biciRIJWzeZzP5SEHEadole4SwXzI5ukeSf7rW0ILwZHTyA9cOYnvC8ZAYdjNIryyAh6fvkjthmDkz6GPF1sR5Wwmno7dQCt9afidWiRt1NqFQt9abuS0aHjA3ukBad9oKxWb4Bct7qpY0bt3nsFQt0uIWPqbE7Zu1iTrUPp0v9xsh0hAqg6vsWLwCGZIMZmz46pRd4mI5S25mdcvEiXI7LqAooRMA4mH4))Qmya8lXgOkocN12ukeSf7rW0s6n7fILHBQ44N1KhsofJWW0o0lQusMoy6uY0bt)A6n5SpXYWn1duGmaJSovFc9Po1deqXsdeMODtPSbm07qEbhGVjmTd9ithmD3i99NOPeHtHc82NPQrAJCtBNZCjucNe5QmXsjGpol6A5S6u5mI5mH4))kOaoaFzP)hzIdvXr4S24mI5S25mj8lHqtkuaoRTPuiyl2JGP)L0b9HgKH(ukBad9oKxWb4Bct7qVOsjz6GPtfh)SM8qYPyegMsMoyAlxshWzAdYqNZAVEBtPqslm1qGPa9xkPbxOw)w)sjn46T)1kHFjeAsHcm1duGmaJSovFc9Po1deqXsdeMODtPKatbeLsAWf2NPDOhz6GP7gPF9jAkr4uOaV9zQAK2i3uxcLWjrUktSuc4JZIUwoZ33NZQPgo7lCwkp7FAUQGyHsXIP17sOeojYvb4uOapoJyoZLqjCsKRYelLa(4SORLZAPVXz1udNbFp2gjc8Qcou5bslMwFdKYJZiMZGVhBJebEvxd0)ady9cYqVqbHE9rsZXzeZzUekHtICvMyPeWhNfnNrivoJyo7YcGVQ8)azObzOxb4uOaVPuiyl2JGPqkVM(qdYqFQ44N1KhsofJWW0o0lQusMoy6uY0btjkLxdNPnidDoRD)2M6bkqgGrwNQpH(uN6bcOyPbct0UPu2ag6DiVGdW3eM2HEKPdMUBK(I5enLiCkuG3(mvnsBKBQq8)FLeciCInq)HoWvjbxAXboRvCMpvoRMA4S25mH4))kjeq4eBG(dDGRscU0IdCwR4S25mH4))Qmya8lXgO6flZZIWCwlMZmiu5HelUkdga)sSbQKGlT4aN1gNrmNzqOYdjwCvgma(LydujbxAXboRvCMFRXzeZzP5SiCvgma(Lydub4uOapoRTPuiyl2JGPh6axVldhijyQ44N1KhsofJWW0o0lQusMoy6uY0btfHoWXzDz4ajbt9afidWiRt1NqFQt9abuS0aHjA3ukBad9oKxWb4Bct7qpY0bt3ns)w0enLiCkuG3(mvnsBKBAAoRxOhWGZcbolAoZNZiMZsZz9c9agCwiWzrZz(tPqWwShbtlP3Sxas3uXXpRjpKCkgHHPDOxuPKmDW0PKPdM(10BYzFG0n1duGmaJSovFc9Po1deqXsdeMODtPSbm07qEbhGVjmTd9ithmD3i9BTjAkr4uOaV9zQAK2i3uH4))QiiXcYE0F)1a9UekHtICvXr4mI5S0CwVqpGbNfcCwR4mXCkfc2I9iyAXsR5WwmTEbu5Mko(zn5HKtXimmTd9IkLKPdMoLmDW0VAP1CylMgN9bvooRD)2M6bkqgGrwNQpH(uN6bcOyPbct0UPu2ag6DiVGdW3eM2HEKPdMUBK(FBIMseofkWBFMQgPnYnnnN1l0dyWzHaNfnN5ZzeZzP5SEHEadole4SO5m)Puiyl2JGPMM0I7lwAnh2IPnvC8ZAYdjNIryyAh6fvkjthmDkz6GPu2KwmN9vlTMdBX0M6bkqgGrwNQpH(uN6bcOyPbct0UPu2ag6DiVGdW3eM2HEKPdMUBK(eortjcNcf4TptPqWwShbtlwAnh2IP1lGk3uXXpRjpKCkgHHPDOxuPKmDW0PKPdM(vlTMdBX04SpOYXzTxVTPEGcKbyK1P6tOp1PEGakwAGWeTBkLnGHEhYl4a8nHPDOhz6GP7gPFlnrtjcNcf4TptvJ0g5MkHFjeAsHcmLcbBXEem9VKoOp0Gm0NszdyO3H8coaF7ZuXXpRjpKCkgHHPDOxuPKmDW0PDiVwmTr6pLmDW0wUKoGZ0gKHoN1Uy22ukK0ctDiVwmTA9BDdbMc0FPKgCHA9B9lL0GR3(xRe(LqOjfkWupqbYamY6u9j0N6upqaflnqyI2nLscmfqukPbxyFM2HEKPdMUBK(IXenLiCkuG3(mLcbBXEemfs510hAqg6tPSbm07qEbhGV9zAh6fvkjthmDQ44N1KhsofJWWuY0btjkLxdNPnidDoR96TnLcjTWuhYRftRw)PEGcKbyK1P6tOp1PEGakwAGWeTBAhYRftBK(t7qpY0bt3TBAla8NXLBF2Tb]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20171119.111032, [[diu7maqiuK0IisztGegfkQofkk7cQAyqXXuOLrQ8mjbMgkICnqI2grQ6BqjJdfjoNKGwhiL5rKk3dKK9jj0bjvTquspusAIGKkxKOAJOi0irrqNKizMOi1nvWob1prrudfKu1srHNImvI4QGKITsu6ROiWEf)vszWu5WkTys5XsmzfDzvBMO4ZOuJgeDAu9AuIzt42KSBGFdz4GWYP0ZPy6sDDOY2Hs9DqQoVKQ1dsknFjr7NQoJrsiOUlZIt0H1qeeVWxbhQDBoceyDsVUqmU4R5bwhMrSghhRq8JyGsSgRWquXYHOdfsFP5iGjsc8yKesoy1eFgTquXYHOd1i2SfhFbHete0bgVdk8oM7D9Az)gpKFfnK4HO0EN05D6GsVRYk9UMRU3vrVddEOedgVJzH0RXf8UEiiVfXnQqsbM8Y2iBiac8qdOPSRfEvpui4v9qmH3I4gvigx818aRdZiwJycX4geoB5MijDOQq(cldiSV6GoAHgqt4v9qPdSUijKCWQj(mSgIkwoeDOgXMT44Ha1CeW4DqH3XCVRGqIjc6a8YWTV2fxDqVc82RwoW4Dv070XuW4DvwP31RL9B8nx9AnQ2KFVt6GkVt6X4DmlKEnUG31dbbQ5iqiPatEzBKneabEOb0u21cVQhke8QEiOEuZrGqmU4R5bwhMrSgXeIXniC2Ynrs6qvH8fwgqyF1bD0cnGMWR6Hsh4kiscjhSAIpdRHOILdrhQrSzloEoOV1IdI2esVgxW76HGohmRzG8RnKuGjVSnYgcGap0aAk7AHx1dfcEvpetahm9ocYV2qmU4R5bwhMrSgXeIXniC2Ynrs6qvH8fwgqyF1bD0cnGMWR6HshyMuKesoy1eFgwdrflhIoKgozKbV9geybLxRr9v4TxTCGX7KoVtxi9ACbVRhQr9v1uRPVTEiPatEzBKneabEOb0u21cVQhke8QEijO(kVByn9T1dX4IVMhyDygXAetig3GWzl3ejPdvfYxyzaH9vh0rl0aAcVQhkDGHYijKCWQj(mSgIkwoeDOgXMT44liKyIGoWesVgxW76HKHBFTlU6GEfHKcm5LTr2qae4Hgqtzxl8QEOqWR6HyIC79o5IRoOxrigx818aRdZiwJycX4geoB5MijDOQq(cldiSV6GoAHgqt4v9qPdS0hjHKdwnXNH1quXYHOd1i2SfhFbHete0bMq614cExpKPrwvTlU6GEfHKcm5LTr2qae4Hgqtzxl8QEOqWR6HOgzvENCXvh0RieJl(AEG1HzeRrmHyCdcNTCtKKouviFHLbe2xDqhTqdOj8QEO0bgRijKCWQj(mSgIkwoeDOgXMT44liKyIGoWesVgxW76HU4Qd6vutTM(26HKcm5LTr2qae4Hgqtzxl8QEOqWR6HKlU6GEfE3WA6BRhIXfFnpW6WmI1iMqmUbHZwUjsshQkKVWYac7RoOJwOb0eEvpu6aZuIKqYbRM4ZWAi9ACbVRhcN5149vMqsbM8Y2iBiac8qdOPSRfEvpui4v9qqnM7Ds1xzcX4IVMhyDygXAetig3GWzl3ejPdvfYxyzaH9vh0rl0aAcVQhkDGRWijKCWQj(mSgIkwoeDOgXMT44liKyIGoW4DqH3XCVJP6D9koOXVMYbZfuo(dwnXNExLv6DA4Krg8RPCWCbLJhheExLv6DfesmrqhGFnLdMlOC82RwoW4Dv07GsmEhZcPxJl4D9qAceAwtgC26HKcm5LTr2qae4Hgqtzxl8QEOqWR6HyvGqtVJjIZwpeJl(AEG1HzeRrmHyCdcNTCtKKouviFHLbe2xDqhTqdOj8QEO0bEetKesoy1eFgwdrflhIouJyZwC8fesmrqhy8oOW7yU3Xu9UEfh04xt5G5ckh)bRM4tVRYk9onCYid(1uoyUGYXJdcVJzH0RXf8UEiTBn3YchWoKuGjVSnYgcGap0aAk7AHx1dfcEvpeR3AULfoGDigx818aRdZiwJycX4geoB5MijDOQq(cldiSV6GoAHgqt4v9qPd84yKesoy1eFgwdrflhIo0wAo2V2bxXVX7QO3PZ7GcVJ5E3wAo2V2bxXVX7QO3PZ7QSsVBlnh7x7GR434Dv0705DmlKEnUG31dzXbQTLMJa1eCthQkKVWYac7RoOJwOb0u21cVQhke8QEig4aEN(sZraVJP5MoKElBtiWQoujnIRQ6DYfxDqVcO5D6zYYLwigx818aRdZiwJycX4geoB5MijDiPatEzBKneabEOb0eEvpeXvv9o5IRoOxb08o9mz5Pd8OUijKCWQj(mSgIkwoeDOEfh04xt5G5ckh)bRM4Zq614cExpKfhO2wAocutWnDOQq(cldiSV6GoAHgqtzxl8QEOqWR6HyGd4D6lnhb8oMMBAVJ5JmlKElBtiWQoujnIRQ6DYfxDqVcO5DgoGT4E3AksleJl(AEG1HzeRrmHyCdcNTCtKKoKuGjVSnYgcGap0aAcVQhI4QQENCXvh0RaAENHdylU3TMs6apwbrsi5Gvt8zynevSCi6q9koOXZlxgC264py1eFgsVgxW76HS4a12sZrGAcUPdvfYxyzaH9vh0rl0aAk7AHx1dfcEvpedCaVtFP5iG3X0Ct7DmxhZcP3Y2ecSQdvsJ4QQENCXvh0RaAENHdylU3XLrAHyCXxZdSomJynIjeJBq4SLBIK0HKcm5LTr2qae4Hgqt4v9qexv17KlU6GEfqZ7mCaBX9oUmPd8itkscjhSAIpdRHOILdrhQxXbnEbNnKnGdyxZIM4py1eFgsVgxW76HS4a12sZrGAcUPdvfYxyzaH9vh0rl0aAk7AHx1dfcEvpedCaVtFP5iG3X0Ct7DmVcywi9w2MqGvDOsAexv17KlU6GEfqZ7mCaBX9oHvAHyCXxZdSomJynIjeJBq4SLBIK0HKcm5LTr2qae4Hgqt4v9qexv17KlU6GEfqZ7mCaBX9oHnD6qWR6HiUQQ3jxC1b9kGM3nVmlorNoba]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20171119.111032, [[daJAcaGEjuTlc41eQzlLBsHBtQDk0Er7MK9dfnmL43IgQeWGHsgUGoOKQJbPZjrAHsulfclMIwoLEOKYtbpwQwNeOjkbzQcmzOA6uDrjPlR66sITsG2SeX2Hs9zLKNRuhwXYGOrRK6Be0jHcNMORjH48eYFLq6zsOSnjOMOmGqHEjtLMZYeIJ(eaPUgMyvTD9v(0kiMyfAFp1MJtaXBF2NrKlOcrrrlva0LIieTucq3kdDceQ3DzQ2mGrugqOQAmBhNLjaDRm0j45QvTlqy6YuTju3u2KUicHPltfbmu4Y(4PLGkvNGrIl4yJJ(eieh9juG0LPIaI3(SpJixqfIUqaX3zfB)BgqNqT1Vl2iX(6RCAsWiXJJ(eOZisgqOQAmBhNLju3u2KUicE6xxu9S9BfradfUSpEAjOs1jyK4co24OpbcXrFcbPFnMyzmB)wreq82N9ze5cQq0fci(oRy7FZa6eQT(DXgj2xFLttcgjEC0NaDglgdiuvnMTJZYeGUvg6e8C1Q2fySUSKP7eQBkBsxeHTNwT4)WBjGHcx2hpTeuP6emsCbhBC0NaH4OpbWtRw8F4Teq82N9ze5cQq0fci(oRy7FZa6eQT(DXgj2xFLttcgjEC0NaD6eGW3Lttw8XLPIrKfgjDsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20171119.111032, [[di0hsaqiKsztQaJsuLtjQQvHev1RqkvAwir0TqkvzxQuddP6yKYYurEMOsMMOcCnrf12evKVHeghsu5CIk06qkvmpKOCpvq7tvLoiuYcvr9qKIjIev5IqP2iseojvOzkQu3uLStOAPKupf1ursBLkyVk)vugSGdlzXK4XuAYQYLbBgk(mvA0KQtt41KKzl0TPy3i(nKHRcDCKiTCIEovnDPUUQY2PI(osjJxubDEvvTEKsvnFvvSFrEAJ6y8YaJzHHMua7iyasxrANuWliUrifIYXSvko2JhZhbROIcA)QfiYWpLtNgRgIq5HHFIUgfAAA54Tg9CMcTCCSAOE)PkmW4hQVXeldK51rwv3sWucIN2lVhO8HbZnMyzGmVoYQ6(9jRwGiu(0VZv(JXY2ceXpQdxBuhJnPuIWBNhZwP4ypM2sHwyvjiUPWp)KcpuFJjwgiZRJSQULGPeeFkqzhMcU23ySuerr)FmMyzGmVoYQASJKNWwnsoMGiW4l0ZHsIxgy8y8YaJPeXYaPaRJSQgRgIq5HHFIUgfA0hRg8OpPf8J66X0OdwvxiNGbi9ugFHE4LbgVE4Ng1XytkLi825XyPiII()yicgG0vmtjw(ESJKNWwnsoMGiW4l0ZHsIxgy8y8YaJXocgG0vmfohlFpwneHYdd)eDnk0Opwn4rFsl4h11JPrhSQUqobdq6Pm(c9WldmE9WZ1OogBsPeH3opMTsXXESYhgm3Gvhb(meMSwhYCLq1z(pYdKcI793XXyPiII()yOKToL(vQGXosEcB1i5ycIaJVqphkjEzGXJXldmg7s26u6xPcgRgIq5HHFIUgfA0hRg8OpPf8J66X0OdwvxiNGbi9ugFHE4LbgVE45GrDm2KsjcVDEmBLIJ9ytbrFlrMB7NucKof(9WuqtJIu4NFsbAlfkzlWu2(2tligfe3mtbrFlrMBGukr4LchKcMcI(wIm32pPeiDk87HPqoEAmwkIOO)pgkzRN51rwvJDK8e2QrYXeebgFHEous8YaJhJxgym2LS1tbwhzvnwneHYdd)eDnk0Opwn4rFsl4h11JPrhSQUqobdq6Pm(c9WldmE9WZ5rDm2KsjcVDEmBLIJ94g56gH7s2cmLTtHdsH8sHY2cNqgqaJa8PWVPWPu4NFsbAlf8q3cIR)2xoHmmizwHGui)XyPiII()yFJKgvaCeKJDK8e2QrYXeebgFHEous8YaJhJxgym3iPrfahb5y1qekpm8t01OqJ(y1Gh9jTGFuxpMgDWQ6c5emaPNY4l0dVmW41dpNg1XytkLi825XSvko2JlBlCczabmcWNc)McNsHF(jfOTuWdDliU(BF5eYWGKzfcgJLIik6)JJck9t8YmLRPYAudMXosEcB1i5ycIaJVqphkjEzGXJXldmo3ck9t8sHRY1uPavudMXQHiuEy4NORrHg9XQbp6tAb)OUEmn6Gv1fYjyaspLXxOhEzGXRhofJ6ySjLseE78y2kfh7XpuFJjwgiZRJSQULGPeeFk8BkylFN1cdKchKcwek(q0IKjHY2JXsref9)XXYzLP8j99yhjpHTAKCmbrGXxONdLeVmW4X4LbgN7YzLcN)K(ESAicLhg(j6AuOrFSAWJ(KwWpQRhtJoyvDHCcgG0tz8f6Hxgy86Ht5g1XytkLi825XSvko2JZlfmfe9TezUTFsjq6u43dtHt0tHdsbLpmyUHiyasxXmmi7N)(7ykKFkCqkKxkibmsWRxkrifYFmwkIOO)pgtSmqMxhzvnMgDWQ6c5emaPNY4l0ZHsIxgy8y8YaJPeXYaPaRJSQsH80YFmwsx)4UKUqNjWCOeWibVEPeHXQHiuEy4NORrHg9XQbp6tAb)OUESJKNWwnsoMGiW4l0dVmW41dphh1XytkLi825XSvko2Jnfe9TezUTFsjq6u43dtbnnTu4NFsbAlfkzlWu2(2tligfe3mtbrFlrMBGukr4LchKcMcI(wIm32pPeiDk87HPaLlNsHF(jfak9tC8i8U9gu8bsbXnthkzNchKcaL(joEeE3ToK9aliCcsFMseHEzhlBNchKcMcI(wIm32pPeiDk8Bkqb9u4GuORiq67ctdsVoYQ6giLseEJXsref9)XqjB9mVoYQASJKNWwnsoMGiW4l0ZHsIxgy8y8YaJXUKTEkW6iRQuipT8hRgIq5HHFIUgfA0hRg8OpPf8J66X0OdwvxiNGbi9ugFHE4LbgVE4A0h1XytkLi825XSvko2Jv(WG5wcEePiwiRrnyULGPeeFkqzPGg9u4NFsH8sbLpmyULGhrkIfYAudMBjykbXNcuwkKxkO8HbZD5Ta5velC)(KvlqKuG2nfSiu8HOf5U8wG8kIfULGPeeFkKFkCqkyrO4drlYD5Ta5velClbtji(uGYsbTCofoifkBlqK7YBbYRiw4giLseEPq(JXsref9)XnQbtMP8ni)p2rYtyRgjhtqey8f65qjXldmEmEzGXurnysHRY3G8)y1qekpm8t01OqJ(y1Gh9jTGFuxpMgDWQ6c5emaPNY4l0dVmW41dxtBuhJnPuIWBNhFv5qH5ZqTKUq7hNRXSvko2Jv(WG5(iIwGmdHjR1HmtbrFlrM7VJPWbPqzBHtidiGra(uGYsHCnglfru0)hhfU6nrqCZuqXEmn6Gv1fYjyaspLXxONdLeVmW4XosEcB1i5ycIaJXldmo3cx9MiiUPWzuShJL01p2(3gHSUKUq7puJsAQCyM9VnczDjDH2FyUgRgIq5HHFIUgfA0hRg8OpPf8J66X083gbQL0fA)op(c9WldmE9W1onQJXMukr4TZJzRuCShR8HbZ9reTazgctwRdzMcI(wIm3FhtHdsHY2cNqgqaJa8PaLLc5AmwkIOO)pokC1BIG4MPGI9yhjpHTAKCmbrGXxONdLeVmW4X4LbgNBHREtee3u4mk2PqEA5pwneHYdd)eDnk0Opwn4rFsl4h11JPrhSQUqobdq6Pm(c9WldmE9W1Y1OogBsPeH3opMTsXXECEPqzBHtidiGra(u43uqlfoifkBlCczabmcWNc)McAPq(PWbPqEPWdu(WG5okC1BIG4MjrV7hIwKui)XyPiII()yREjizrHREtee3X0OdwvxiNGbi9ugFHEous8YaJhJxgymn6LGKc5w4Q3ebXDmwsx)4UKUqNjWC4du(WG5okC1BIG4MjrV7hIwKXQHiuEy4NORrHg9XQbp6tAb)OUESJKNWwnsoMGiW4l0dVmW41dxlhmQJXMukr4TZJzRuCShx2w4eYacyeGpf(nf0sHdsHY2cNqgqaJa8PWVPG2ySuerr)FSvVeKSOWvVjcI7yhjpHTAKCmbrGXxONdLeVmW4X4LbgtJEjiPqUfU6nrqCtH80YFSAicLhg(j6AuOrFSAWJ(KwWpQRhtJoyvDHCcgG0tz8f6Hxgy86HRLZJ6ySjLseE78y2kfh7Xpq5ddM7OWvVjcIBMe9UFiArgJLIik6)JJcx9MiiUzkOypMgDWQ6c5emaPNY4l0ZHsIxgy8y8YaJZTWvVjcIBkCgf7uiVt5pglPRFCxsxOZeyo8bkFyWChfU6nrqCZKO39drlYy1qekpm8t01OqJ(y1Gh9jTGFuxp2rYtyRgjhtqey8f6Hxgy86HRLtJ6ySjLseE78ySuerr)FCu4Q3ebXntbf7XosEcB1i5ycIaJVqphkjEzGXJXldmo3cx9MiiUPWzuStH8Yv(JvdrO8WWprxJcn6JvdE0N0c(rD9yA0bRQlKtWaKEkJVqp8YaJxpCnkg1XytkLi825XSvko2JLagj41lLimglfru0)hJjwgiZRJSQgtJoyvDHCcgG078yhjpHTAKCmbrGXxONdLeVmW4XxiNcI7W1gJxgymLiwgifyDKvvkK3P8hJL01p2GCkiUhQrjT)TriRlPl0(d1OKDjDHotG5qjGrcE9sjcJvdrO8WWprxJcn6JvdE0N0c(rD9yA(BJa1s6cTFNhFHE4LbgVE4AuUrDm2KsjcVDEmwkIOO)pgkzRN51rwvJPrhSQUqobdq6DE8f65qjXldmESJKNWwnsoMGiWy8YaJXUKTEkW6iRQuiVt5pglPRFSb5uqCpuBSAicLhg(j6AuOrFSAWJ(KwWpQRhFHCkiUdxB8f6Hxgy861JP8am1xS351B]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20171119.111032, [[deKduaqiLQYMergLsvoLsfRIKqELik0Serr3IKq1UukddHogjwMi5zKe10uQQY1erPTHGY3GcJtPQY5ijY6erbZtvkDpLkTpeKdIaluvYdjctKKq5IqrBKKGtsenteuDtL0ovvlLi9uutfrTvss7v6VQIbl0HvSyI6Xu1KHQld2Ss8zez0uQttQxdLMTOUnf7MWVHmCsQJlIQLJ0ZPY0v56uY2fHVRkfNxKA9kvv18vLQ9l4QuYL)JbkZAJeHiMzWaIBYjdHOtliLHquVuM9uT6RCzwn41twV)NtJe9NIWsvwkKHXb9NIOcgkkkQ0McXKfdfvQSuyWttwBGY4OBBjpg4XzJ8y3OGz0cNk(E4GS1YY2sEmWJZg5XUHBrNtJeQiIBQ8oLjWFAKWvY9RuYLXumYzaVVkZEQw9vEFH4P9y1csH47VhI4OBBjpg4XzJ8y3OGz0cxi(2DdrsE8YeiRZ6lD5L8yGhNnYJTSKcCTFoeTSajGYRiCvh6Fmq5Y)XaLvH8yGqKTrESLLczyCq)PiQGHcXYsbhYI6bxj3RSe2Gh7kkbyaXv5YRi8)yGY96pvjxgtXiNb8(Qm7PA1xzzRLLnWBJa3dA55SHhsuyUhNLahOAbPnl1HysHOzGS7OiZM3IsbXfIeA3qC)iSYeiRZ6lDzyONDYTgSqzjf4A)CiAzbsaLxr4Qo0)yGYL)JbkJ5qp7KBnyHYsHmmoO)uevWqHyzPGdzr9GRK7vwcBWJDfLamG4QC5ve(Fmq5E9RYLCzmfJCgW7RYSNQvFLLTww20EyXIMEZsDiMuiAgi7okYS5TOuqCHiH2nevuucXKcX9fIYwllBJZdc8r4Hnl1LjqwN1x6YluK7EC2ip2YskW1(5q0YcKakVIWvDO)XaLl)hduwfOi3fISnYJTSuidJd6pfrfmuiwwk4qwup4k5ELLWg8yxrjadiUkxEfH)hduUx)7VsUmMIrod49vzcK1z9LUmKbdiUj)iNh3vwsbU2phIwwGeq5veUQd9pgOC5)yGYyMbdiUjhIVYJ7klfYW4G(trubdfILLcoKf1dUsUxzjSbp2vucWaIRYLxr4)XaL71FYwYLXumYzaVVkZEQw9v2mq2DuKzZBrPG4crcTBiQOGri((7H4(cXHE6LXFBU3a5Swq6Xmq2DuKzdeJCgWdXKcrZaz3rrMnVfLcIlej0UHOkLQmbY6S(sxgg6z)4SrESLLuGR9ZHOLfibuEfHR6q)Jbkx(pgOmMd9Sdr2g5XwwkKHXb9NIOcgkellfCilQhCLCVYsydESROeGbexLlVIW)Jbk3RFcRKlJPyKZaEFvM9uT6R8HirkdBd90lJ)cXKcX9cXXF6eWdiaJgCHiHcXuH47VhI7leDWDAbj3MBsapli6ZGGqCNYeiRZ6lDz3HOgSaOgOLLuGR9ZHOLfibuEfHR6q)Jbkx(pgOmFiQblaQbAzPqggh0FkIkyOqSSuWHSOEWvY9klHn4XUIsagqCvU8kc)pgOCV(XOKlJPyKZaEFvM9uT6R8EHOzGS7OiZM3IsbXfIVD3quHOsiMuio0tVm(BZ9giN1cspMbYUJImBGyKZaEi((7H4(cXHE6LXFBU3a5Swq6Xmq2DuKzdeJCgWdXKcrZaz3rrMnVfLcIleF7UHigewiUtiMuiUVqu2AzzBCEqGpcpSzPUmbY6S(sxw7HflA6YskW1(5q0YcKakVIWvDO)XaLl)hduwspSyrtxwkKHXb9NIOcgkellfCilQhCLCVYsydESROeGbexLlVIW)Jbk3R)9RKlJPyKZaEFvM9uT6R84pDc4beGrdUqKqHyQq893dX9fIo4oTGKBZnjGNfe9zqqzcK1z9LUCwNCln(JzizMNdDGPSKcCTFoeTSajGYRiCvh6Fmq5Y)XaLjCDYT04H46qYmHiz0bMYsHmmoO)uevWqHyzPGdzr9GRK7vwcBWJDfLamG4QC5ve(Fmq5E9RsLCzmfJCgW7RYSNQvFLLTww2uJEdqFqlpNn8ygi7okYSzPoetkeLTww2ChIAWcGAGUzPoetkeh)PtapGamAWfIVnev5YeiRZ6lD5SMK9j0cspYO8vwsbU2phIwwGeq5veUQd9pgOC5)yGYeUMK9j0csH4lu(klfYW4G(trubdfILLcoKf1dUsUxzjSbp2vucWaIRYLxr4)XaL71VcXsUmMIrod49vz2t1QVY4OBBjpg4XzJ8y3OGz0cxisOq0pU750gietke9iugh9gXdfg)vMazDwFPlNNeZJSf1DLLuGR9ZHOLfibuEfHR6q)Jbkx(pgOmHpjMq8Lf1DLLczyCq)PiQGHcXYsbhYI6bxj3RSe2Gh7kkbyaXv5YRi8)yGY96xrPKlJPyKZaEFvM9uT6RSS1YYM2dlw00BwQdXKcX9crzRLLnThwSOP3OGz0cxi(2qCVquzlzdrvui6ud58J94oievrHOS1YYM2dlw00BUB8ydXKXquje3je3PmbY6S(sxEHIC3JZg5XwwsbU2phIwwGeq5veUQd9pgOC5)yGYQaf5UqKTrESH4Ek7uwkKHXb9NIOcgkellfCilQhCLCVYsydESROeGbexLlVIW)Jbk3RFLuLCzmfJCgW7RYSNQvFL3lendKDhfz28wukiUqKq7gIPigIjfIYwllBqgmG4M8ZcYB52SuhI7eIjfI7fIuyHco7rodH4oLjqwN1x6Yl5XapoBKhBzjSbp2vucWaIRYLxr4Qo0)yGYL)JbkRc5XaHiBJ8ydX9u2PmbusUY3qjb3JEzxkSqbN9iNHYsHmmoO)uevWqHyzPGdzr9GRK7vwsbU2phIwwGeq5ve(Fmq5E9ROYLCzmfJCgW7RYSNQvFLLTww20EyXIMEZsDzcK1z9LU8cf5UhNnYJTSe2Gh7kkbyaX1xLxr4Qo0)yGYLLuGR9ZHOLfibu(pgOSkqrUlezBKhBiUxQDktaLKRSbLqliTRszPqggh0FkIkyOqSSuWHSOEWvY9kVIsOfK6xP8kc)pgOCV(v2FLCzmfJCgW7RYSNQvFLndKDhfz28wukiUqKq7gIkkkH47VhI7leh6Pxg)T5EdKZAbPhZaz3rrMnqmYzapetkendKDhfz28wukiUqKq7gI7hHfIV)Eicj3sRwnGV5mOmoq1csp2WqVqmPqesULwTAaF7SHhCWd6ea19iNri8h1J)cXKcrZaz3rrMnVfLcIlejuiIbXqmPq8MmiUTz5aQZg5XUbIrod4LjqwN1x6YWqp7hNnYJTSKcCTFoeTSajGYRiCvh6Fmq5Y)XaLXCONDiY2ip2qCpLDklfYW4G(trubdfILLcoKf1dUsUxzjSbp2vucWaIRYLxr4)XaL71VsYwYLXumYzaVVkZEQw9vw2AzzJcoKyeE45qhy2OGz0cxi(2quHyzcK1z9LU8HoW8yg3b00LLuGR9ZHOLfibuEfHR6q)Jbkx(pgOmz0bMqCDChqtxwkKHXb9NIOcgkellfCilQhCLCVYsydESROeGbexLlVIW)Jbk3RFfcRKlJPyKZaEFvM9uT6RSS1YYg4TrG7bT8C2Wdjkm3JZsGduTG0ML6YeiRZ6lDzyONDYTgSqzjf4A)CiAzbsaLxr4Qo0)yGYL)JbkJ5qp7KBnyHqCpLDklfYW4G(trubdfILLcoKf1dUsUxzjSbp2vucWaIRYLxr4)XaL71VcgLCzmfJCgW7RYSNQvFLLTww2uJEdqFqlpNn8ygi7okYSzPoetkeh)PtapGamAWfIVnev5YeiRZ6lD5SMK9j0cspYO8vwsbU2phIwwGeq5veUQd9pgOC5)yGYeUMK9j0csH4lu(cX9u2PSuidJd6pfrfmuiwwk4qwup4k5ELLWg8yxrjadiUkxEfH)hduUx)k7xjxgtXiNb8(Qm7PA1x5XF6eWdiaJgCHiHcrLqmPqC8Nob8acWObxisOquPmbY6S(sx2BpAXtwtY(eAbPYskW1(5q0YcKakVIWvDO)XaLl)hduwc7rlcrcxtY(eAbPYsHmmoO)uevWqHyzPGdzr9GRK7vwcBWJDfLamG4QC5ve(Fmq5E9ROsLCzmfJCgW7RYeiRZ6lD5SMK9j0cspYO8vwsbU2phIwwGeq5veUQd9pgOC5)yGYeUMK9j0csH4lu(cX9sTtzPqggh0FkIkyOqSSuWHSOEWvY9klHn4XUIsagqCvU8kc)pgOCV(trSKlJPyKZaEFvM9uT6RmfwOGZEKZqzcK1z9LU8sEmWJZg5XwwcBWJDfLamG46RYskW1(5q0YcKakVIWvDO)XaLlVIsOfK6xP8FmqzvipgiezBKhBiUxQDktaLKRSpTpdp3qjbNBxLKPbLqliTRsY8gkj4E0l7sHfk4Sh5muwkKHXb9NIOcgkellfCilQhCLCVYsK2NbYdLeCU(Q8kc)pgOCV(tPuYLXumYzaVVktGSoRV0LHHE2poBKhBzjSbp2vucWaIRVkVIWvDO)XaLllPax7NdrllqcO8Fmqzmh6zhISnYJne3l1oLjGsYv2GsOfK2vPSuidJd6pfrfmuiwwk4qwup4k5ELxrj0cs9RuEfH)hduUxVYQyWYyLV(Qxla]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20171119.111032, [[dieVkaqiOKAtqjgfQQ6uOQYQuKsnlOKClfPk7IOAyGQJrsltr8mffnnfLCnuvyBkk4BGOXPiv6Cav16uKcZtrPUNIK9HQIoOe1cLipeOmrfPKlQOAJkk0jjkMjQkDtjzNa(PIu0srvEkYubPTsuAVI)cKbJkhMQftKhlvtwHlRAZKWNLWOLuNMWRjrZMs3MIDd53OmCOuhhOILtQNlLPR01bLTdfFhOkJxrQ48GW6vKQA(avA)q1rnqdb4MhIegWW5MBV5O1TtdCUYtZ5HOUwG9gk006kCy2nLcX727ThGjWvHuvvf8LRcNpGuf8dX7(acOcZdnyRCfw3CqTAwxPC9nUa1ME8FCjykuixH1nhuRM1vkFat7RGHM2WLpt(fQCFfmulqdGAGgAoYLSFKsHOUwG9gAzff2l31RqH33qLLewXcrO2Y0gL)yFDizqdr3xMoeIHEOk2qwxd4MhkeGBEiAzAJYFSVoeVBV3EaMaxfsv4H49gdMU)wGMney1VRSIH5MJ2ifQInaCZdLnatc0qZrUK9Juke11cS3qlROWE5DgZoyGhQfQSKWkwic5T(rdh1Fizqdr3xMoeIHEOk2qwxd4MhkeGBEOYT(rdh1FiE3EV9ambUkKQWdX7ngmD)TanBiWQFxzfdZnhTrkufBa4MhkBaMzGgAoYLSFKsHOUwG9gY7RaZbD0nI3W54ZPW5Mjoh4cU4Cynox77kqfn5GNlwqkyAqo7HkljSIfIqwb4atmaz8cJdAz7nHKbneDFz6qig6HQydzDnGBEOqaU5H4RaCGjg4CvEHXX5GY2BcX727ThGjWvHufEiEVXGP7VfOzdbw97kRyyU5OnsHQyda38qzdWSc0qZrUK9Juke11cS3q8hNZ7RaZbD0nI3W5Mno3SW5WcoNXVTTAMrEhMwF0IZXNtHZnbooh)W5Wcoh)X50xH(TAxYECo(fQSKWkwicPW6MdQvZ6kdbw97kRyyU5OnsHQydzDnGBEOqYGgIUVmDied9qaU5HMrRBoohvZ6kdvwx0c1HOBpO11fFBtPIvgF6aADDX32uZeRwxx8fKqXu6Rq)wTlzFiE3EV9ambUkKQWdX7ngmD)TanBiWGOBpuxx8TLsHQyda38qzdaFeOHMJCj7hPuOYscRyHi0D9wdoWCLpKmOHO7lthcXqpufBiRRbCZdfcWnp0CxV1Gdmx5dX727ThGjWvHufEiEVXGP7VfOzdbw97kRyyU5OnsHQyda38qzdWmeOHMJCj7hPuiQRfyVHgSvUcRBoOwnRRuU(gxGA4C8jox3BlOvyoohwW5KGPqHCRJXb1GPlUCyyJZHfCoSgNBD7rRCROOErcubinBi)ixY(bohwW58(kWCqhDJ4nCUzJZnRqLLewXcriRJXbjbt32qYGgIUVmDied9qvSHSUgWnpuia38q81X44CLGPBBiE3EV9ambUkKQWdX7ngmD)TanBiWQFxzfdZnhTrkufBa4MhkBaGmqdnh5s2psPquxlWEdH14CRBpALBff1lsGkaPzd5h5s2pW5WcoN3xbMd6OBeVHZnBCo(aNdCbxCU1ThTYTII6fjqfG0SH8JCj7h4CybNZ7RaZbD0nI3W5Mno3ScvwsyfleHU9MJw3csY6TnKmOHO7lthcXqpufBiRRbCZdfcWnp0C7nhTUfNRK1BBiE3EV9ambUkKQWdX7ngmD)TanBiWQFxzfdZnhTrkufBa4MhkBaMUbAO5ixY(rkfQSKWkwiczDmoiP7MqYGgIUVmDied9qvSHSUgWnpuia38q81X44CLUBcX727ThGjWvHufEiEVXGP7VfOzdbw97kRyyU5OnsHQyda38qzda4hOHMJCj7hPuiQRfyVHgxcMcfYTII6fjqfG0SH8bd8qHkljSIfIq9AxGazff1lsGkcbw97kRyyU5OnsHQydzDnGBEOqaU5HaR2fiCo(kkQxKaveQSUOfADDXxqcftnUemfkKBff1lsGkaPzd5dg4HcX727ThGjWvHufEiEVXGP7VfOzdjdAi6(Y0Hqm0dvXgaU5HYgav4bAO5ixY(rkfQSKWkwic1RDbcKvuuVibQiKmOHO7lthcXqpufBiRRbCZdfcWnpey1UaHZXxrr9IeOcCo(RYVq8U9E7bycCvivHhI3Bmy6(BbA2qGv)UYkgMBoAJuOk2aWnpu2aOQgOHMJCj7hPuOYscRyHiK1X4GKGPBBiWQFxzfdZnhTPuOk2qwxd4MhkKmOHO7lthcXqpeGBEi(6yCCUsW0TfNJ)Q8luzDrlKHHrGkMsneVBV3EaMaxfsv4H49gdMU)wGMnufdJavea1qvSbGBEOSbqDsGgAoYLSFKsHOUwG9gsFf63QDj7dvwsyfleHuyDZb1QzDLHaR(DLvmm3C0MsHQydzDnGBEOqYGgIUVmDied9qaU5HMrRBoohvZ6kX54Vk)cvwx0czyyeOIPuXQ11fFbjumL(k0Vv7s2hI3T3BpatGRcPk8q8EJbt3FlqZgQIHrGkcGAOk2aWnpu2SHiSFx4wX03xbdfGjZWKSja]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20171119.111032, [[daKmtaqiqqBcrzuGOofiYRqufMfIQOBjfa7sOggsCmQQLjf9mQcAAsb01KcY2quvFdu14Kc05OkW6quLmpqG7bcTpHuherAHGkpKiAIiQsDreXgLcQtkKmtevCtP0oryPevpf1ujsBLQO9Q8xqAWKCyrlgPEmftwQUSQndkFMOmAj60u61iPzlPBtLDd1VHmCH44iQ0Yj8Cbth46sy7uL(ovHopry9sbO5lfA)K65pPJjs3hZwNKAfj17ogKvYlTkyXYQxRYGzmBe2iGXJjVpSSOcgCJL)6ZWhrtk(W7777bX(uAi499GXYF2LqQ19XI7slo0aqxadwCgmh3tS5X9crcSi8ysnalchM0r4pPJjbN013hCJzJWgbmgGKjR(ydcv7ipIdAfzAfK1QocedRMUdnuImuJf3LwCqRIwROlGblodMJ7j284EHibwewRitRmiuTJ8ioUMEtO0fIaiwCxAXbTkATIIwrMwbHAfDbmyXbas4O(h5I4IiAfKgtkTTAbsmodMJ7j28XrH7wtcqIXye(JBrDptbr6(4XeP7JjnyoUNyZhl)1NHpIMu8H3NYy5pGkeMhM0bglz5nuBrEV7yWOh3I6eP7JhyenN0XKGt667dUXSryJagdHAfWAOAXY0QgBuR6iqmSA6o0qjYqnwCxAXbTccGOwjZ0htkTTAbsmgwnDhAOezOookC3AsasmgJWFClQ7zkis3hpMiDFCdxt31kUezOow(RpdFenP4dVpLXYFavimpmPdmwYYBO2I8E3XGrpUf1js3hpWi8WjDmj4KU((GBmBe2iGXU81aqGCXMcH4yGwfne1QMu0kY0Q0aSiCCgmh3tS5XhN0131kY0kXDPfh0kiaIAfDbmyXzWCCpXMh3lejWIWAfzALbHQDKhXXzWCCpXMhlUlT4GwrEOv0fWGfNbZX9eBECVqKalcRvqae1QEHibweEmP02QfiXyy10DOHsKH64OWDRjbiXymc)XTOUNPGiDF8yI09XnCnDxR4sKHQwbzFinw(RpdFenP4dVpLXYFavimpmPdmwYYBO2I8E3XGrpUf1js3hpWiAGt6ysWjD99b3ysPTvlqIXVE3XGScLUMbW4OWDRjbiXymc)XTOUNPGiDF8yI09XKuV7yqw1k4Qzamw(RpdFenP4dVpLXYFavimpmPdmwYYBO2I8E3XGrpUf1js3hpWiAOjDmj4KU((GBmBe2iGX0fWGfFtj6bOiyqbLhQmXta0qbUFHfllUiIwrMwbHAfDbmyXzWCCpXMhxerRitRC5RbGa5InfcXXaTkAiQvni5pMuAB1cKy8tbOKClsQFCu4U1KaKymgH)4wu3ZuqKUpEmr6(yssbOKClsQFS8xFg(iAsXhEFkJL)aQqyEyshySKL3qTf59UJbJEClQtKUpEGrq(t6ysWjD99b3y2iSraJD5RbGa5InfcXXaTkAiQv((WRvn2OwbHAvkawyPbeh84Rvlwgux(AaiqU4Jt667AfzALlFnaeixSPqiogOvrdrTYdAoMuAB1cKy8tbOeAOezOookC3AsasmgJWFClQ7zkis3hpMiDFmjPauQvCjYqDS8xFg(iAsXhEFkJL)aQqyEyshySKL3qTf59UJbJEClQtKUpEGra)KoMeCsxFFWnMncBeWyasMS6JtbWclnaTImTcYAvAawVh6X3zFqRIwRAQvn2OwbHAv4aGfllehsVhkmKaAIUwbPXKsBRwGeJdaKWr9pYfJJc3TMeGeJXi8h3I6EMcI09XJjs3hZaKWr9pYfJL)6ZWhrtk(W7tzS8hqfcZdt6aJLS8gQTiV3Dmy0JBrDI09XdmIgCshtcoPRVp4gZgHncyCAawVh6X3zFqRIwRAQvn2OwbHAv4aGfllehsVhkmKaAI(ysPTvlqIXvl5wy7qDPmxcfGa3nokC3AsasmgJWFClQ7zkis3hpMiDFm5yj3cBxRAtzUuRKIa3nw(RpdFenP4dVpLXYFavimpmPdmwYYBO2I8E3XGrpUf1js3hpWi8GjDmj4KU((GBmBe2iGX0fWGfhb5XlGIGbfuEOU81aqGCXfr0kY0k6cyWIdaKWr9pYfXfr0kY0Q0aSEp0JVZ(GwbbALhoMuAB1cKyC1kReGTyzqPrvW4OWDRjbiXymc)XTOUNPGiDF8yI09XKJvwjaBXY0k4qvWy5V(m8r0KIp8(ugl)buHW8WKoWyjlVHAlY7Dhdg94wuNiDF8aJWNYKoMeCsxFFWnMncBeW4ocedRMUdnuImuJf3LwCqRIwRmzaafyDxRitRGSwzqOAh5rmuXtdqRASrTIUagS4myoUNyZJlIOvqAmP02QfiX4A6nHsxicGXrH7wtcqIXye(JBrDptbr6(4XeP7JjN0BQvWvicGXYF9z4JOjfF49Pmw(dOcH5HjDGXswEd1wK37ogm6XTOor6(4bgHV)KoMeCsxFFWnMncBeWyiRvU81aqGCXMcH4yGwfne1QMu0kY0k6cyWIF9UJbzfkmKPiexerRGKwrMwbzTsCyIhkt661kinMuAB1cKymSA6o0qjYqDSKL3qTf59UJbJEClQ7zkis3hpMiDFCdxt31kUezOQvqUjKgtQqwymifYoaQfgefhM4HYKU(XYF9z4JOjfF49Pmw(dOcH5HjDGXrH7wtcqIXye(JBrDI09Xdmc)Mt6ysWjD99b3y2iSraJD5RbGa5InfcXXaTkAiQv(((AvJnQvqOwLcGfwAaXbp(A1ILb1LVgacKl(4KU(UwrMw5YxdabYfBkeIJbAv0quRAqYxRASrT6KBHnsK3JdouTFHfldA5tbqRitRo5wyJe59yq5H2V5wVxeGsxrOo0iPbOvKPvU81aqGCXMcH4yGwfTwbpfTImTcK1JbXjmWfHsKHA8XjD99XKsBRwGeJFkaLqdLid1XrH7wtcqIXye(JBrDptbr6(4XeP7JjjfGsTIlrgQAfK9H0y5V(m8r0KIp8(ugl)buHW8WKoWyjlVHAlY7Dhdg94wuNiDF8aJW3dN0XKGt667dUXSryJagtxadwS4beoXMdfGa3flUlT4GwbbALpfTQXg1kiRv0fWGflEaHtS5qbiWDXI7sloOvqGwbzTIUagS4myoUNyZJ7fIeyryTI8qRmiuTJ8ioodMJ7j28yXDPfh0kiPvKPvgeQ2rEehNbZX9eBES4U0IdAfeOv(nKwrMwLgGfHJZG54EInp(4KU(UwbPXKsBRwGeJbiWDqDzaCHeJJc3TMeGeJXi8h3I6EMcI09XJjs3hlfbUtRAZa4cjgl)1NHpIMu8H3NYy5pGkeMhM0bglz5nuBrEV7yWOh3I6eP7Jhye(nWjDmj4KU((GBmBe2iGXPby9EOhFN9bTkATYxRitRsdW69qp(o7dAv0AL)ysPTvlqIX10BcL(PBCu4U1KaKymgH)4wu3ZuqKUpEmr6(yYj9MAfCpDJL)6ZWhrtk(W7tzS8hqfcZdt6aJLS8gQTiV3Dmy0JBrDI09Xdmc)gAshtcoPRVp4gZgHncymDbmyXrqE8cOiyqbLhQlFnaeixCreTImTknaR3d947SpOvqGw5HJjL2wTajgxTYkbylwguAufmokC3AsasmgJWFClQ7zkis3hpMiDFm5yLvcWwSmTcoufOvq2hsJL)6ZWhrtk(W7tzS8hqfcZdt6aJLS8gQTiV3Dmy0JBrDI09XdmcFYFshtcoPRVp4gZgHncyCAawVh6X3zFqRIwR81kY0Q0aSEp0JVZ(GwfTw5pMuAB1cKySPmTyOvRSsa2ILnokC3AsasmgJWFClQ7zkis3hpMiDFSKLPfRvKJvwjaBXYgl)1NHpIMu8H3NYy5pGkeMhM0bglz5nuBrEV7yWOh3I6eP7Jhye(WpPJjbN013hCJjL2wTajgxTYkbylwguAufmokC3AsasmgJWFClQ7zkis3hpMiDFm5yLvcWwSmTcoufOvqUjKgl)1NHpIMu8H3NYy5pGkeMhM0bglz5nuBrEV7yWOh3I6eP7Jhye(n4KoMeCsxFFWnMncBeWyXHjEOmPRFmP02QfiXyy10DOHsKH6yjlVHAlY7DhdgCJBrDptbr6(4XrH7wtcqIXye(Jjs3h3W10DTIlrgQAfK9qinMuHSWyhYRfldI(KNGui7aOwyquCyIhkt66hl)1NHpIMu8H3NYy5pGkeMhM0bg3I8AXYgH)4wuNiDF8aJW3dM0XKGt667dUXKsBRwGeJFkaLqdLid1XswEd1wK37ogm4g3I6EMcI09XJJc3TMeGeJXi8htKUpMKuak1kUezOQvqUjKgtQqwySd51ILbr)XYF9z4JOjfF49Pmw(dOcH5HjDGXTiVwSSr4pUf1js3hpWaJ5i3yZQTbmbweEenj)MdSba]] )

    storeDefault( [[SimC Elemental: standard vs gambling]], 'actionLists', 20171119.111032, [[d0I8baGEIO2LsOTbuz2sUPsWTrANGAVIDRy)QYWaYVvXGbmCIQdcuoMQ6CePwOsQLIGftOLJOhIqpfAzkL1PKmrIqtvPAYemDQUiL6YOUoLSzLOTte5JeL(mf9nk40s9yqojrYZvPRreCEII)sHomPdbu15N9GWkLdInL4dWUykpUwREaxxhbLu4biP7dWuPIvpMbriYwUhmibUy9YbEd03W))LEXpijy4lDquod1A1sw9(mbEdCBbbdY7ZCZEG)zpO9OIflK1bHvkheBkXhGDXuECTEaYQuXQhZGiezl3dAQuXQhZGGj2v7YeK0AmQqEFgJvF9Ge4I1lh4nqFdFqbLAeAi1pKbNZWbjW3JfjeFZE8GlCeGvkheBkXhGDXuECTEaYQuXQhZvpabEPAvE8aVL9G2JkwSqwhewPCqSPeFa2ft5X1kicr2Y9GG3uPIvpMbbtSR2LjiP1yuH8(mgR(6bjWfRxoWBG(g(Gck1i0qQFidoNHdsGVhlsi(M94bx4iaRuoi2uIpa7IP84AT6biWlvRYJhpOe5LQv5zD8ea]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170905.115544, [[d8tCiaqyQwVQQEjrv2fsQyBqe)gQzQQYYiIztQZRi3eIQtJQVPQipxODkQ9kTBc7xe)ecdJsghsQ0RvvQHsIblsdhHdQqhLsv1XuuNdjv1cvflLOYIfy5u8qf0tbpgfRJsvzIiPmvenzI00v5IO0vPuLlR01rQnQaBfIuTzbTDIYhvv4ZiX0GO8DvPrsuvptvjJMKgpsYjPuUfejxtvrDpis52qATiPkhNsL7CjlW4ehhlgGfhCt6Tac7r(ZwMTW5gk7PitPbfmUGYouDz(UpfSJEP3rnNIaDfxbMcticdJ7n0jooweB2QavicdJ7n0jooweB2QGD0l9k1gdwa8)BZiZQquf)osBCBIqCdkyh9sVsh6ehhlI9PWeIWW4EKUHYEXMTky)0l9glzZZLSaRWd0R0(uyK54yrs6pE8kaS)ssz1l6koxNKQywgmAGFfYo6way)LKYQx0vCUojvXSmy0a)ki3QxpUnlXAgjZwwFvaymCIRWXrxKMvVMLuYcScpqVs7tHrMJJfjP)4XRaW(ljLvVOR4CDsk12qNwFfYo6way)LKYQx0vCUojLABOtRVcYT61JBZsSMrYSL1xfagdN4k0RxHOk(fE5hJ6iBFkevXVJ0hUpfIQ4x4LFmQJ0hUpfo3qzVrbJk2u4bbjjcKlNTpKpzbQqegg3tEpXMNlqvZwfIQ4xs3qzVyFk8DWOGrfBkqIqroBFiFYcCHuoJFyZOGrfBkiNTpKpzbgN44yXOGrfBk8GGKebYlaeld318)(XXIMLGejfIQ4xGSpfSJEPxQXnlZXXIcYz7d5twqqJAJblInJScrIvRhO9O6qSgBkzbV55cMMNlqP55cbnp3Rquf)o0joowe7tbQqegg3BK24nBvq6g606Bu5xbGJomjLvVOR4CT9LKgpxi1nstsLftsP4ObAUGsbuNQr6d3SvHan)))p043rTUbfCnHQdQ4xfzSnpxW1eQ(qmAGFkYyBEUakxmsF4MTkqTn0P1xFk46xFkQitPpfKXJ8aUMFtKteBbVaJtCCSyuZPikmKntYkxbP8iH2NiNi2cEbxtO6J6xFkQiJT55cgxqzjNi2cEaxZVPcoTXroxS9PqiwCfgnCxNKMDJb)w47GbyXb8)BZZskm1bif11I6lbzwizE(tFzjrYNSAisHSpxW1eQoPBOSNImLMNlmHimmUN8EInJuZfmRUWq2mjRCfIeRwpq7r1guW1eQoPBOSNIm2MNl40gFuWOInfEqqsIa5)yhqwWo6LELAtiLZ4h2e7tbcdh1nt2yWcG)FBgzwfc08)))qJFBqHZnu2BawCWnP3ciSh5pBz2ci3PIJsJMKsYr3M)YQaJtCCSyawCa))28SKcaJHtCfk4AcvFu)6trfzknpxiQIFvKP0NcegoQBMgGfhW)VnplPaHzzWOb(nQ8RaWrhMKYQx0vCU2(ssjmldgnWVcYT61JBZsSM)KfsKiH6izwcsS(CbuNQr2MTkq66vCjPFyW0enBv4CdL9uKX2Gcrv8R82PaUqkxqj2NckgoQBMssh6ehhlkCUHYEXczhDlWQx0vCUojvXWrDZub7O5mFJ05r4M0BbVW3bdWIRGczsk4IysA2ng8BbN24KteBHa6WWcUMq1hIrd8trMsZZfIQ4xBcPCg)WMyFkG6ubKnpxW1V(uurgBFkevXVkYy7tHOk(DKTpfyWOb(PitPbfo3qzVbyXvqHmjfCrmjn7gd(TaNblacNHlO08Nl8DWaS4GBsVfqypYF2YSfq5cGSzRcNBOS3aS4a()T5zjfumCu3mLKo0joowKKosB8cfyCIJJfdWIRGczsk4IysA2ng8BbN24aXQ12OwZwfyfEGEL2NcrokHEhrW2SKcuHimmUNnHuoJFytSzRcticdJ7nsB8MTkmHimmUNnHuoJFytSzRcdXetjPK4cS6fDfNRtshrWwGbJg4NIm2guaLlgzB(RcuHimmUhPBOSxSzRcoTXTjcXKteBHa6WWcCgSG6HXOn)Lvb7Ox6v6aS4a()T5zjfCnHQdQ4xfzknpxWo6LELkVNyFkevXVWl)yuhrW2NcoTXTNGFfi0(0A61ca]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170905.115544, [[d8ZpiaqyrRxvvVKss7IsGxRG62OYmrIghLqnBkoVcDtufonkFJsKUSs7KQ2R0UjSFf5NqyyK0VH65cgkPmyf1Wr4Gc1rrvuDmvX5Oe0cvvwkQslMilNkpubEkyziP1rjKjsjLPcPjtuMUkxKexLsINrP01rQnsPAROkInlKTJQ6JkiFgIMMQk9DvPrsjvBtvfJMunEKWjjQUfLiUgLOUhQI0Jr0ArvuooLI7trlqMehdlSJfhCJMTacRGsPCVsHlDi3tJVwLk4sbYDG(soC)kizy))pKb)wPcJiIIc7nijogweQxTafiIIc7nijogweQxTGn0l9ktojwaS)B9)QwiOJFJPDPCreUsfSHEPxzdsIJHfH(vyeruuyp00HCVq9Qf450l9gkA9pfTGIiLmRS(viM8yyX0mLSWvVfxWNCBbqHYPzfZYTIlntZAULeZjLxbExZMHTEQQp)8OQABbG0XiUchJB5PQ9QNArlOisjZkRFfIjpgwmntjlC1)tbFYTfafkNMvml3kU0mnBTnkPnxbExZMHTEQQp)8OQARf8uaiDmIRqVEfc64x4LDK6XkvQqqh)gtF4kvGrIfarsYeiR3YfU0HCVybPo2v4dbkkcEWR8HSoAbkqeff2ZQFH6vlqr9Qfc64x00HCVq)kmSuSGuh7kGIqJx5dzD0cmHmgzEyxSGuh7kWR8HSoAbYK4yyrSGuh7k8HaffbpkaeljlnS)5XWI6P(d1cbD8lG2Vc2qV0R1yUL8yyrbELpK1rliO5KtIfH6)TqGyng7MmOpaBWUIwiR)PGu9pfqw)tbx9p9ke0XVdsIJHfH(vGcerrH9IPDz9QfKTrjT5I1OSaW4gmnRywUvCPXIMMdxkKLoztZ8dtZitojdtGSaxsrm9HRxTqAi0ZyZBog04Ru)tH0qONGo(vJVs9pfsdHEoaZjLNgFL6FkWXeX0hUEQfsZBog04R1Vc8zbMeZWUr0rITGubYK4yyrSHHuuyGIhvH3cYybctoIosSfilizy))pKb)gBmvQGlfix0rITqkXmSBSqs7sEWeB)kyTnkPnx)kmSKDS4a2)T(hQfgreff2ZQFH6vlKgc9enDi3tJVw9pfIWIRqSJLMPzF6C43cU1uyGIhvH3cbI1ySBYGELkKgc9enDi3tJVs9pfsAxkxeHrhj2cs0rrfSHEPxzYfYyK5HDH(vine6jOJF14Rv)tbchJlDJYjXcG9FR)x1cx6qUNDS4GB0SfqyfukL7vkWJKcghn30mkJBR3w1cKjXXWc7yXbS)B9pulaKogXviWeinBH0qONXM3CmOXxR(NcbD8RgFT(vGWX4s3ODS4a2)T(hQfiCljMtkVynklamUbtZkMLBfxASOPzc3sI5KYRGMJXLUXP5bjXXWIcU8y4cCjfXk1RwannR4MMhYHPjQxTWLoK7PXxPsfc64xRUJsmHmMazOFf4DnBg26PQ(yPQ)qLQfq9H6pQwUaxsbGwVAbFYTfuml3kU0mnhJqPWWs2XIRGg60mKIW0SpDo8BbBOzKdZtyb4gnBbPcjTlrhj2cs0rrfc64x5czmY8WUq)kKgc9CaMtkpn(A1)uinV5yqJVs)ke0XVXkvQqqh)QXxPFfiXCs5PXxRsfc64x4LDK6X0hUFfU0HCp7yXvqdDAgsryA2Noh(TWWs2XIdUrZwaHvqPuUxPahtaO1tTWLoK7zhloG9FR)HAbnhJlDJtZdsIJHftZX0USGDtYTtZGoMC4cKjXXWc7yXvqdDAgsryA2Noh(Tqs7sGyng5wRE1ckIuYSY6xHaJJWSXiuQNAbkqeff2tUqgJmpSluVAHrerrH9IPDz9Qfgreff2tUqgJmpSluVAHbyIXPzuCbfZYTIlntZXiukqI5KYtJVsLkyd9sVXggsb3kUcKf4yIyL6PwGcerrH9qthY9c1RwGrIf8mmMREBvlyd9sVYSJfhW(V1)qTWyTBj)yzvl8r1cT1sT1w1FTyBvBKL8RLlyd9sVYS6xOFfsAxgli1XUcFiqrrWdkvSJwiPDPveSRaHjhxxVwa]] )


end
