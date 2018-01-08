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
        addAura( 'echoes_of_the_great_sundering', 208722, 'duration', 10 )
        addAura( 'elemental_blast_critical_strike', 118522, 'duration', 10 )
        addAura( 'elemental_blast_haste', 118522, 'duration', 10 )
        addAura( 'elemental_blast_mastery', 173184, 'duration', 10 )
        addAura( 'elemental_focus', 16164, 'duration', 30, 'max_stack', 2 )
        addAura( 'elemental_mastery', 16166, 'duration', 20 )
        addAura( 'emalons_charged_core', 208742, 'duration', 10 )
        addAura( 'ember_totem', 210658, 'duration', 120 )
        addAura( 'fire_of_the_twisting_nether', 207995, 'duration', 8 )
        addAura( 'chill_of_the_twisting_nether', 207998, 'duration', 8 )
        addAura( 'shock_of_the_twisting_nether', 207999, 'duration', 8 )
        addAura( 'flame_shock', 188389, 'duration', 30 )
        addAura( 'frost_shock', 196840, 'duration', 5 )
        addAura( 'icefury', 210714, 'duration', 15, 'max_stack', 4 )
        addAura( 'lava_surge', 77762, 'duration', 10 )
        addAura( 'lightning_rod', 197209, 'duration', 10 )
        addAura( 'power_of_the_maelstrom', 191877, 'duration', 20, 'max_stack', 3 )
        addAura( 'resonance_totem', 202192, 'duration', 120 )
        addAura( 'static_overload', 191634, 'duration', 15 )
        addAura( 'storm_tempests', 214265, 'duration', 15 )
        addAura( 'storm_totem', 210652, 'duration', 120 )
        addAura( 'stormkeeper', 205495, 'duration', 15, 'max_stack', 3 )
        addAura( 'tailwind_totem', 210659, 'duration', 120 )
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

            elseif spell == class.abilities.earthen_spike.name then
                Hekili.DB.profile[ 'Toggle State: save_earthen_spike' ] = false

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
            local totem_remains = 0

            for i = 1, 5 do
                local _, totem_name, cast_time = GetTotemInfo( i )

                if totem_name == class.abilities.totem_mastery.name then
                    totem_expires = cast_time + 120
                    totem_remains = totem_expires - now
                end
            end

            local in_range = buff.resonance_totem.up or totem_remains > 118

            if totem_expires > 0 and in_range then
                buff.totem_mastery.name = class.abilities.totem_mastery.name
                buff.totem_mastery.count = 4
                buff.totem_mastery.expires = totem_expires
                buff.totem_mastery.applied = totem_expires - 120
                buff.totem_mastery.caster = 'player'

                applyBuff( "resonance_totem", totem_remains )
                applyBuff( "storm_totem", totem_remains )
                applyBuff( "ember_totem", totem_remains )
                applyBuff( "tailwind_totem", totem_remains )
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
            if state.spec.enhancement then
                state.feral_spirit.cast_time = nil 
            end

            if state.spec.elemental and state.talent.totem_mastery.enabled then
                local totem_expires = 0
                local totem_remains = 0

                for i = 1, 5 do
                    local _, totem_name, cast_time = GetTotemInfo( i )

                    if totem_name == class.abilities.totem_mastery.name then
                        totem_expires = cast_time + 120
                        totem_remains = totem_expires - state.now
                    end
                end

                local in_range = state.buff.resonance_totem.up or totem_remains > 118

                if totem_expires > 0 and in_range then
                    state.buff.totem_mastery.name = class.abilities.totem_mastery.name
                    state.buff.totem_mastery.count = 4
                    state.buff.totem_mastery.expires = totem_expires
                    state.buff.totem_mastery.applied = totem_expires - 120
                    state.buff.totem_mastery.caster = 'player'

                    state.applyBuff( "resonance_totem", totem_remains )
                    state.applyBuff( "storm_totem", totem_remains )
                    state.applyBuff( "ember_totem", totem_remains )
                    state.applyBuff( "tailwind_totem", totem_remains )
                    return
                else
                    state.buff.totem_mastery.name = class.abilities.totem_mastery.name
                    state.buff.totem_mastery.count = 0
                    state.buff.totem_mastery.expires = 0
                    state.buff.totem_mastery.applied = 0
                    state.buff.totem_mastery.caster = 'nobody'
                end
            end

        end )


        -- Pick an instant cast ability for checking the GCD.
        -- setGCD( 'global_cooldown' )

        -- Gear Sets
        addGearSet( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
            addAura( 'force_of_the_mountain', 254308, "duration", 10 )
            addAura( 'earthen_strength', 252141, "duration", 15 )
            addAura( 'exposed_elements', 252151, 'duration', 4.5 )

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
            if amt > 0 and resource == 'maelstrom' and state.spec.elemental and state.talent.aftershock.enabled then
                state.gain( amt * 0.3, 'maelstrom' )
            end
        end )


        ns.addMetaFunction( 'state', 'gambling', function ()
            return spec.elemental and equipped.smoldering_heart
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

        ns.addSetting( 'allow_dw_desync', true, {
            name = "Enhancement: Allow Doom Winds to Desynchronize from Ascendance",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not be able to recommend Doom Winds when cooldowns (|cFFFFD100toggle.cooldowns|r) are disabled and Ascendance is not on cooldown (if you've talented for Ascendance).\n\n" ..
                "When |cFF00FF00true|r, the addon will be able to recommend Doom Winds even if Ascendance is not on cooldown, such as when fighting trash and saving Ascendance for a boss fight.",
            width = "full",
        } )

        ns.addToggle( 'hold_t20_stacks', false, 'Save Tier 20 Stacks', "(Enhancement)  If checked, the addon will |cFFFF0000STOP|r recommending Crash Lightning when you have the specified number of Crashing Lightning stacks (or more).  " ..
            "This only applies when you have the tier 20 four-piece set bonus.  This may help to save stacks for a big burst of AOE instead of refreshing the tier 20 two-piece bonus." )


        ns.addToggle( 'save_earthen_spike', false, "Save Earthen Spike", "(Enhancement)  If checked, the addon will |cFFFF0000STOP|r recommending Earthen Spike until you cast the ability yourself.  " ..
            "This may be useful if you know you are fighting short-lived adds and you will want to use Earthen Spike on another target soon." )



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
            ready = function () return buff.ascendance.remains end,
            gcdType = 'off',
            talent = 'ascendance',
            cooldown = 180,
            passive = true,
            toggle = 'cooldowns',
            recheck = function () return buff.ascendance.remains end,
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
            nobuff = 'ascendance',
            texture = 136015,
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
            recheck = function () return buff.crash_lightning.remains end,
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
            recheck = function () return cooldown.stormstrike.remains, cooldown.ascendance.remains - 6 end,
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
            talent = 'earthen_spike',
            usable = function () return not toggle.save_earthen_spike end,
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
            return max( 10, min( 100 + ( artifact.swelling_maelstrom.enabled and 25 or 0 ), maelstrom.current ) ) -- * ( talent.aftershock.enabled and 0.7 or 1 )
        end )

        addHandler( 'earth_shock', function ()
            removeStack( 'elemental_focus' )
            removeBuff( "earthen_strength" )
            -- spend( min( maelstrom.current, 90 + ( artifact.swelling_maelstrom.enabled and 25 or 0 ) ), "maelstrom" )
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'earthquake', {
            id = 61882,
            spend = 50,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0
        } )

        modifyAbility( 'earthquake', 'spend', function( x )
            if buff.echoes_of_the_great_sundering.up then return 0 end
            return x -- * ( talent.aftershock.enabled and 0.7 or 1 )
        end )

        addHandler( 'earthquake', function ()
            removeStack( 'elemental_focus' )
            removeBuff( 'echoes_of_the_great_sundering' )
            removeBuff( "earthen_strength" )
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
            notalent = 'storm_elemental',
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
            cooldown = 12,
            recheck = function () return buff.flametongue.remains, buff.flametongue.remains - 4.8, buff.flametongue.remains - ( 6 + gcd ), cooldown.doom_winds.remains - gcd * 2 end,
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

            spend( cost, 'maelstrom' ) -- * ( talent.aftershock.enabled and 0.7 or 1 ), 'maelstrom' )
        end )


        addAbility( 'frostbrand', {
            id = 196834,
            spend = 20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            recheck = function () return buff.frostbrand.remains, buff.frostbrand.remains - 4.8, buff.frostbrand.remains - ( 6 + gcd ), cooldown.doom_winds.remains - gcd * 2 end,
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
            if talent.icefury.enabled then
                removeBuff( "earthen_strength" )
            end
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'chill_of_the_twisting_nether', 8 )
            end
            spend( cost, 'maelstrom' ) -- * ( talent.aftershock.enabled and 0.7 or 1 ), 'maelstrom' )
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
            known = 188443,
            spend = 0,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 0,
            buff = 'ascendance',
            texture = 236216
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
            if set_bonus.tier21_2pc > 0 then applyBuff( "earthen_strength" ) end
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
            usable = function () return not settings.save_for_aoe or active_enemies > 2 end
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
            recheck = function () return ( 1.7 - charges_fractional ) * recharge, buff.landslide.remains end,
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
            removeBuff( "force_of_the_mountain" )
            if set_bonus.tier21_4pc > 0 then applyDebuff( "target", "exposed_elements", 4.5 ) end
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
            toggle = 'artifact',
            usable = function () return not settings.save_for_aoe or active_enemies > 2 end
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
            usable = function() return target.casting end,
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20180107.232317, [[dueoAaqifLwefvTjkkJIiDkIYSOi1UiLHrHJbILjQ8mLszAksCnuLABOkX3ajJtPeNtPKADuKmpkQ09qvSpkchuuSqrvEirmrkQOlQioPOQMjQs6MOQ2jP6NkLkdvPu1svqpvyQkWvvkj2ki1xPOcVvrQ7QOyVi)fugSehMQfJspwKjJIlRAZs5ZkfJwHonLwTsjPETIQzt42s1UH8BsgUs1XPiA5q9CLmDGRJkBNO67ks68IsRxPKK5dQ2VKMGqdOWC(MZjauEue7pzDHDRYbwfI0ZXlBJIHxCFDspNbeOGaj3w0Ga124TbVPisy7oGckYKawfArdiDi0akMGCwXzO8OidRvybzPyQwedS14Dmf5JySjhOWuGuOtbFfd0ow37Nck09(PWCyrm1smEhtXWlUVoPNZacuqmOy4xkoC6lAabOqY4tZ5RK)(raILc(kgDVFkiaPNJgqXeKZkodLhfrcB3buiTwKwlaxCeqB0TIfqH7Ah5SIZulMvlZwlSCTMwdRwawSJy042Rfz1cC41YS1cWfhb0gDRybu4U2roR4m1ImkYWAfwqwkK7yRZkofsgFAoFL83pcqSuWxXaTJ19(Py0TIfqH7sgFAof6E)uap1AggPuRnDau4xlq7cUpdCmfzWBwuG8(5z0TIfqH7sgFAUPL7cUZJuPaxCeqB0TIfqH7Ah5SIZy2SSCTMwdRwawSJy042Lbh(SaxCeqB0TIfqH7Ah5SIZiJIHxCFDspNbeOGyqXWVuC40x0acqr(igBYbkmfif6uWxXO79tbbi9TrdOycYzfNHYJIiHT7akKwlZwlaxCeqRXHZct1G5wS2roR4m1cC41I0Ab4IJaAnoCwyQgm3I1oYzfNPwmRw6(flaw11sCy8rGAXe1YwmQfz1ImkYWAfwqwkK7yRZkofsgFAoFL83pcqSuWxXaTJ19(POXHZkz8P5BXGcDVFkGNAndJuQ1Moak8RfODb3NboUwKcrgfzWBwuG8(5PXHZkz8P5BXW0YDb35r6SaxCeqRXHZct1G5wS2roR4mWHlf4IJaAnoCwyQgm3I1oYzfNXSUFXcGvDtSfdzYOy4f3xN0Zzabkigum8lfho9fnGauKpIXMCGctbsHof8vm6E)uqasFk0akMGCwXzO8Oisy7oGcP1YS1cWfhb0AC4SWunyUfRDKZkotTahETiTwaU4iGwJdNfMQbZTyTJCwXzQfZQLUFXcGvDTehgFeOwmrTaLrTiRwKrrgwRWcYsHChBDwXPqY4tZ5RK)(raILc(kgODSU3pfnoCwjJpnhkdk09(PaEQ1mmsPwB6aOWVwG2fCFg44ArAozuKbVzrbY7NNghoRKXNMdLHPL7cUZJ0zbU4iGwJdNfMQbZTyTJCwXzGdxkWfhb0AC4SWunyUfRDKZkoJzD)IfaR6MakdzYOy4f3xN0Zzabkigum8lfho9fnGauKpIXMCGctbsHof8vm6E)uqasN30akMGCwXzO8Oisy7oGcP1YS1cWfhb0AC4SWunyUfRDKZkotTahETiTwaU4iGwJdNfMQbZTyTJCwXzQfZQLUFXcGvDTehgFeOwmrTmfExlYQfzuKH1kSGSui3XwNvCkKm(0C(k5VFeGyPGVIbAhR79trJdNvY4tZNcVPq37Nc4PwZWiLATPdGc)AbAxW9zGJRfPBtgfzWBwuG8(5PXHZkz8P5tH3MwUl4opsNf4IJaAnoCwyQgm3I1oYzfNboCPaxCeqRXHZct1G5wS2roR4mM19lwaSQBIPWBzYOy4f3xN0Zzabkigum8lfho9fnGauKpIXMCGctbsHof8vm6E)uqasNxObumb5SIZq5rrKW2DafsRLzRfGlocO14WzHPAWClw7iNvCMAbo8ArATaCXraTgholmvdMBXAh5SIZulMvlD)IfaR6Ajom(iqTyIAjhVRfz1ImkYWAfwqwkK7yRZkofsgFAoFL83pcqSuWxXaTJ19(POXHZkz8P554nf6E)uap1AggPuRnDau4xlq7cUpdCCTiDkYOidEZIcK3ppnoCwjJpnphVnTCxWDEKolWfhb0AC4SWunyUfRDKZkodC4sbU4iGwJdNfMQbZTyTJCwXzmR7xSayv3e54Tmzum8I7Rt65mGafedkg(LIdN(IgqakYhXytoqHPaPqNc(kgDVFkiaPdfnGIjiNvCgkpkIe2UdOqATmBTaCXranL8JtJoEZ1oYzfNPwGdVwKwlaxCeqtj)40OJ3CTJCwXzQfZQLUFXcGvDTehgFeOwmrTaLrTiRwKrrgwRWcYsHChBDwXPqY4tZ5RK)(raILc(kgODSU3pfBNKTxPeqzqHU3pfWtTMHrk1Athaf(1c0UG7Zahxls5TmkYG3SOa59ZZ2jz7vkbugMwUl4opsNf4IJaAk5hNgD8MRDKZkodC4sbU4iGMs(XPrhV5Ah5SIZyw3VybWQUjGYqMmkgEX91j9CgqGcIbfd)sXHtFrdiaf5JySjhOWuGuOtbFfJU3pfeG03cnGIjiNvCgkpkIe2UdOqATmBTaCXranL8JtJoEZ1oYzfNPwGdVwKwlaxCeqtj)40OJ3CTJCwXzQfZQLUFXcGvDTehgFeOwmrTWlg1ISArgfzyTclilfYDS1zfNcjJpnNVs(7hbiwk4RyG2X6E)uSDs2ELsWlguO79tb8uRzyKsT20bqHFTaTl4(mWX1IuErgfzWBwuG8(5z7KS9kLGxmmTCxWDEKolWfhb0uYpon64nx7iNvCg4WLcCXranL8JtJoEZ1oYzfNXSUFXcGvDtWlgYKrXWlUVoPNZacuqmOy4xkoC6lAabOiFeJn5afMcKcDk4Ry09(PGaK(wtdOycYzfNHYJIiHT7akKwl3KC299ZOT6kbZXw0gyJ3XGArgfzyTclilfYDS1zfNcjJpnNVs(7hbiwk4RyG2X6E)umEhdMyso7((zOq37Nc4PwZWiLATPdGc)AbAxW9zGJRfPqjJIm4nlkqE)8mEhdMyso7((zmTCxWDEKEtYz33pJgeEdzlq2Azum8I7Rt65mGafedkg(LIdN(IgqakYhXytoqHPaPqNc(kgDVFkiaPdXGgqXeKZkodLhfrcB3buiTwUj5S77NrZN7we3cMZUucoWHTvZTa20RfzuKH1kSGSui3XwNvCkKm(0C(k5VFeGyPGVIbAhR79tHp3TiUjMKZUVFgk09(PaEQ1mmsPwB6aOWVwG2fCFg44Ar6wKrrg8MffiVFE85UfXnXKC299ZyA5UG78i9MKZUVFgniBdkJTmfzum8I7Rt65mGafedkg(LIdN(IgqakYhXytoqHPaPqNc(kgDVFkiaPdbcnGIjiNvCgkpkIe2UdOqATCtYz33pJ2cOWDyG33)cSQfzuKH1kSGSui3XwNvCkKm(0C(k5VFeGyPGVIbAhR79tb499VatmjNDF)muO79tb8uRzyKsT20bqHFTaTl4(mWX1I0TwgfzWBwuG8(5b8((xGjMKZUVFgtl3fCNhP3KC299ZObzBqbXyBYOy4f3xN0Zzabkigum8lfho9fnGauKpIXMCGctbsHof8vm6E)uqashsoAaftqoR4muEuejSDhqH0ArUJToR4A(C3I4Myso7((zQfZQfwUwtBubGn6ignU9AXSAz2AHLR10Ay1cWIDeJg3ETiJImSwHfKLc5o26SItHKXNMZxj)9Jaelf8vmq7yDVFk85UfXLjOq37Nc4PwZWiLATPdGc)AbAxW9zGJRfPqmKrrg8MffiVFE85UfXLjmTCxWDEKk3XwNvCnFUBrCtmjNDF)mMXY1AAJkaSrhXOHVNaMnllxRP1WQfGf7ignUDzum8I7Rt65mGafedkg(LIdN(IgqakYhXytoqHPaPqNc(kgDVFkiaPdzB0akMGCwXzO8Oisy7oGcP1YS1clxRPjSBgbilAdSe2xJAC71Iz1Y6aySke3sdypoNbSC7PAXe1IrTiJImSwHfKLc5o26SItHKXNMZxj)9Jaelf8vmq7yDVFk4v7MraYI2ib7RrDfyRStHU3pfWtTMHrk1Athaf(1c0UG7ZahxlsHargfzWBwuG8(5HxTBgbilAJeSVg1vGTYUPL7cUZJ0zz5AnnHDZiazrBGLW(AuJB3S1bWyviULgWECody52tYOy4f3xN0Zzabkigum8lfho9fnGauKpIXMCGctbsHof8vm6E)uqashYuObumb5SIZq5rrKW2DafsRfP1clxRP5I9rh2uvIMg(D3Iw1I5wl5QfZQfwUwtZf7JoSPQenn87UfTQfZTwYvlMvlSCTMMl2hDytvjAA43DlAvlMBTKRwKvlMvlTJDbS1UfBbA43DlAvlMOwMsTiJImSwHfKLc5o26SItHKXNMZxj)9Jaelf8vmq7yDVFkCX(OBouIMKXNMtHU3pfWtTMHrk1Athaf(1c0UG7ZahxlsHKtgfzWBwuG8(5Xf7JU5qjAsgFAUPL7cUZJuP7hO1WQfa2uvIMglxRP5I9rh2uvIMg(D3IwMBoZ2pqRzpolSPQennwUwtZf7JoSPQenn87UfTm3CMTFGMWUzeGSOnWMQs00y5AnnxSp6WMQs00WV7w0YCZjZS2XUa2A3ITan87UfTmXuKrXWlUVoPNZacuqmOy4xkoC6lAabOiFeJn5afMcKcDk4Ry09(PGaKoeEtdOycYzfNHYJImSwHfKLcU1HzbVVOiFeJn5afMcKcDk4RyG2X6E)uqHU3pfWtTMHrk1AtVvwVwYh8(Ag4ykgEX91j9CgqGcIbfd)sXHtFrdiafsgFAoFL83pcqSuWxXO79tbbiDi8cnGIjiNvCgkpkYWAfwqwksUqaZtaRcbtyxakYhXytoqHPaPqNc(kgODSU3pfuO79tb8uRzyKsT20sCHOwYKawfQw4v7cmdCmfzWBwuG8(5X8HTlPwMGgDu69JaMQwu7hDS5Py4f3xN0Zzabkigum8lfho9fnGauiz8P58vYF)iaXsbFfJU3pfHTlPwMGgDu69JaMQwu7hDmbiDiqrdOycYzfNHYJIiHT7aky5AnnFLoIXrPRXTtrgwRWcYsrYfcyEcyviyc7cqHKXNMZxj)9Jaelf8vmq7yDVFkOq37Nc4PwZWiLATPL4crTKjbSkuTWR2fyg44ArkezuKbVzrbY7NhZh2UKAzcA0rP3pcyQAXxjZtXWlUVoPNZacuqmOy4xkoC6lAabOiFeJn5afMcKcDk4Ry09(PiSDj1Ye0OJsVFeWu1IVseG0HSfAaftqoR4muEuKH1kSGSuKCHaMNawfcMWUauKpIXMCGctbsHof8vmq7yDVFkOq37Nc4PwZWiLATPL4crTKjbSkuTWR2fyg44ArAozuKbVzrbY7NhZh2UKAzcA0rP3pcyQAHLR1wMNIHxCFDspNbeOGyqXWVuC40x0acqHKXNMZxj)9Jaelf8vm6E)ue2UKAzcA0rP3pcyQAHLR1weG0HS10akMGCwXzO8OidRvybzPi5cbmpbSkemHDbOiFeJn5afMcKcDk4RyG2X6E)uqHU3pfWtTMHrk1AtlXfIAjtcyvOAHxTlWmWX1I0TjJIm4nlkqE)8y(W2LultqJok9(ratvlsmNlZtXWlUVoPNZacuqmOy4xkoC6lAabOqY4tZ5RK)(raILc(kgDVFkcBxsTmbn6O07hbmvTiXCUiaPNZGgqXeKZkodLhfzyTclilfjxiG5jGvHGjSlaf5JySjhOWuGuOtbFfd0ow37Nck09(PaEQ1mmsPwBAjUqulzsaRcvl8QDbMboUwKofzuKbVzrbY7NhZh2UKAzcA0rP3pcyQAjPW38um8I7Rt65mGafedkg(LIdN(IgqakKm(0C(k5VFeGyPGVIr37NIW2LultqJok9(ratvljf(eG0ZbHgqXeKZkodLhfzyTclilfjxiG5jGvHGjSlaf5JySjhOWuGuOtbFfd0ow37Nck09(PaEQ1mmsPwBAjUqulzsaRcvl8QDbMboUwKYBzuKbVzrbY7NhZh2UKAzcA0rP3pcyQAPzfIJnpfdV4(6KEodiqbXGIHFP4WPVObeGcjJpnNVs(7hbiwk4Ry09(PiSDj1Ye0OJsVFeWu1sZkehtacqHU3pfHTlPwMGgDu69JaMQwyEZ5eacqe]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20180107.232317, [[dqtUbaGEukTlOeBtantOKMTeZhv0nfP7cLQVrH2jvTxYUvSFb1WOOFdzOqPmybA4OQoOGCmvAHcXsLulMsTCu8qHYtbpMkphQMikrtvetwftxQlkKEMaCDHQTIQ0MHITJs1YKKXHs4ZuWPv1Tf1Brj1OPKdR0jrfUmY1qvCEuPEnQK)IsX6qjzDvIawsy24Lwrea8j3VLNTB)Or(QadqqnvOfNKVY8A8ERybwUgdGhtEeaoMNFlqqix)ObxjYFvIGOZAxOJIiiK9x(MBb8r9JgbCmN3TnIrWGgsqk6W7Y43mjqGFZKaoDyWyA6CyWWASH6hnyNtgb1uHwCs(kZRXRPGAchfNXr4krTGywKJRue7uMMw2csrh)MjbQLVsjcIoRDHokIGq2F5BUfuEdw98Jb2GB9u5iGJ58UTrmcg0qcsrhExg)Mjbc8BMeG13Gvp)yiCqW6PYrqnvOfNKVY8A8AkOMWrXzCeUsuliMf54kfXoLPPLTGu0XVzsGA1c8BMeaFow4GrhRDCuMMMvHdYNHCOS92QLaa]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20180107.232317, [[diudpaqiOkztOknkkItrrAxkLHbvoMcwgL0ZOemnkHUgPeBJuP8nvLghufDosLkRdQsP5bvPY9uQ0(uQ4GqvTqufpKIAIKsIUOsvBeQsvNKuXmjvYnvODcPFcvHmusLQwkQQNsmvsXvjLe2kPuFfQc2R0FjvnyQ6WIwmepwOjRkxgSzuPpJkgnfonsVgknBLCBfTBe)MKHdfhNusTCuEovMUkxNsTDvvFNusA8qvkoVQI1dvHA(uI2VG7q1urRe4M2RR8ubnNqfHonh87jgjjctGC4TbFuXGk8HfKoOOwXn8DyWkEUn81cAbNwQiyGinxu848OksrTQBwOc(XJQiUQPOdvtL9KezbVYtfjYOyUk)jJMilyJRn7JzdiI1QwQGpcDrVpvGKDgarVddflurhYJgZtXQqueOYO6PDYqZjuPcAoHk7t2zaKGxWqXcv4dliDqrTIB47aUk8bNYMfbx10RIzdiIDu9dtGCfPYO6HMtOsVIATAQSNKil4vEQirgfZvbVcEeBUC3IS0zOFr5yCekHZMnMGN3GpJh9h0deysbxWVZUbV1k4Jqx07tLilDg6xuoghHs4urhYJgZtXQqueOYO6PDYqZjuPcAoHkMzPZi41fLJXrOeov4dliDqrTIB47aUk8bNYMfbx10RIzdiIDu9dtGCfPYO6HMtOsVIAHQPYEsISGx5Pc(i0f9(urRsjpNIWPIoKhnMNIvHOiqLr1t7KHMtOsf0CcvWduYZPiCQWhwq6GIAf3W3bCv4doLnlcUQPxfZgqe7O6hMa5ksLr1dnNqLEf1IvtL9KezbVYtfjYOyUkz8O)GEGatk4c(D2n4XZG3sldEtc(mE0FqpqGjfCb)o7g86wWZBWF5ci3wKLodkHJE3PyZnGKil4f8MwbFe6IEFQezPZq)IYX4iucNk6qE0yEkwfIIavgvpTtgAoHkvqZjuXmlDgbVUOCmocLWj4nzW0k8HfKoOOwXn8Daxf(GtzZIGRA6vXSbeXoQ(HjqUIuzu9qZjuPxr1s1uzpjrwWR8ubFe6IEFQOvPKN7yuSqfDipAmpfRcrrGkJQN2jdnNqLkO5eQGhOKN7yuSqf(WcshuuR4g(oGRcFWPSzrWvn9Qy2aIyhv)WeixrQmQEO5eQ0RO6w1uzpjrwWR8urImkMRcInxUBCvSiOxXv)za6NkBYLuYMnMGN3GpAKmoGtpxwgpQIKRGFNGFy7BWZBWNXJ(d6bcmPGl4X72n4Tyf8rOl69PctfXIqpGvrhYJgZtXQqueOYO6PDYqZjuPcAoHk8vrSi0dyv4dliDqrTIB47aUk8bNYMfbx10RIzdiIDu9dtGCfPYO6HMtOsVI(TAQSNKil4vEQirgfZvbVc(hGyZL7M7uSP(dMya352SXe88g8)jJMily7GjgWD71ABkgmWRc(i0f9(uXDk20DmkwOIzdiIDu9dtGCfPYO6PDYqZjuPcAoHkYPyt3XOyHk4Z44QCjJdC6PC3fVEaInxUBUtXM6pyIbCNBZgdV)jJMily7GjgWD71ABkgmWRcFybPdkQvCdFhWvHp4u2Si4QMEv0H8OX8uSkefbQmQEO5eQ0RO4z1uzpjrwWR8urImkMRcInxUBUtXMimkHdW2SXe88g8)jJMilyJRn7JzdiI1QwQGpcDrVpvCNInDhJIfQOd5rJ5Pyvikcuzu90ozO5eQubnNqf5uSP7yuSqWBYGPv4dliDqrTIB47aUk8bNYMfbx10RIzdiIDu9dtGCfPYO6HMtOsVIQ7QMk7jjYcELNksKrXCvY4r)b9abMuWf87SBWBXG3sldEtc(mE0FqpqGjfCb)o7g8wdEEd(lxa52IS0zqjC07ofBUbKezbVG30k4Jqx07tLilDg6xuoghHs4urhYJgZtXQqueOYO6PDYqZjuPcAoHkMzPZi41fLJXrOeobVjwnTcFybPdkQvCdFhWvHp4u2Si4QMEvmBarSJQFycKRivgvp0Ccv6v0bCvtL9KezbVYtfjYOyUki2C5UXvXIGEfx9NbOFQSjxsjB2yQGpcDrVpvyQiwe6bSk6qE0yEkwfIIavgvpTtgAoHkvqZjuHVkIfHEal4nzW0k8HfKoOOwXn8Daxf(GtzZIGRA6vXSbeXoQ(HjqUIuzu9qZjuPxrhgQMk7jjYcELNksKrXCvUCbKBt9dSOrY4aBajrwWl45n4)tgnrwWgxB2hZgqeRf1sWZBWpty5oMAUfTzmGCb)o7g8wexf8rOl69PYIYX4iuch9iQ1vrhYJgZtXQqueOYO6PDYqZjuPcAoHk6IYX4iucNGNh16QWhwq6GIAf3W3bCv4doLnlcUQPxfZgqe7O6hMa5ksLr1dnNqLEfDWA1uzpjrwWR8urImkMRIjb)mHL7yQ5w0MXaYf87SBWRfCbpVb)FYOjYc2WJmR7vQ1xCbpVb)FYOjYc24AZ(y2aIyXtCbpVb)dqS5YDdWBWOCWtpSGjqo3MnMGN3G)bi2C5UTsNbLWrp3vob3M7Yi2GFNGx3Hl4nn4T0YG3KGhXMl3nd1P3ijVnBmbpVbVjbVjb)FYOjYc2sSjLyVxRTPyWaVGN3GhXMl3nUmL7qyj5TzJj4nn4T0YG3KGhVc()KrtKfSLytkXEVwBtXGbEbVPbVPbVPvWhHUO3NkR8p1VsNrfDipAmpfRcrrGkJQN2jdnNqLkO5eQOR8pdEDLoJk8HfKoOOwXn8Daxf(GtzZIGRA6vXSbeXoQ(HjqUIuzu9qZjuPxrhSq1uzpjrwWR8urImkMRIjbpEf8xUaYTP(bw0izCGnGKil4f88g8)jJMilyJRn7JzdiI1IAj4nn4T0YG3KG)YfqUn1pWIgjJdSbKezbVGN3G)pz0ezbBCTzFmBarS4jUG30k4Jqx07tf3Pyt3XOyHk6qE0yEkwfIIavgvpTtgAoHkvqZjurofB6ogfle8My10k8HfKoOOwXn8Daxf(GtzZIGRA6vXSbeXoQ(HjqUIuzu9qZjuPxrhSy1uzpjrwWR8urImkMRYFYOjYc2sSjLyJVubFe6IEFQWLPChcljVk6qE0yEkwfIIavgvpTtgAoHkvqZjubVNPChcljVk8HfKoOOwXn8Daxf(GtzZIGRA6vXSbeXoQ(HjqUIuzu9qZjuPxrh0s1uzpjrwWR8urImkMRsgp6pOhiWKcUGFNDdElubFe6IEFQ4SjpGrjCQOd5rJ5Pyvikcuzu90ozO5eQubnNqfXM8agLWPcFybPdkQvCdFhWvHp4u2Si4QMEvmBarSJQFycKRivgvp0Ccv6v0bDRAQSNKil4vEQirgfZvjJh9h0deysbxWVZUbVfcElTm4)tgnrwWMUOCmocLWXmlDgOQtRatWBPLb)FYOjYc2YfgJepOwCnBarSvWhHUO3Nkrw6m0VOCmocLWPIoKhnMNIvHOiqLr1t7KHMtOsf0CcvmZsNrWRlkhJJqjCcEtSGPv4dliDqrTIB47aUk8bNYMfbx10RIzdiIDu9dtGCfPYO6HMtOsVEvKiJI5Q0Rfa]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20180107.232317, [[dadqbaGEjQ2KGyxssBtqA2Q0nvr3Mu7uj7LA3OSFLAyk0VjmyfnCfCqjXXeAHsQwQu1Ify5O6HsHNcEmrRtqzIcQMQuzYK00fDrjLldDDKQTkrSzjsBxIYZjXNLqnpPuhwvltfgTu04KqoPe0PrCnK05LaFdjEns5zsj7O7meow6t)MUUH1Rrdar3ypRXA(mjQrwg2EkgqgYn0Jx8vqVogJuIXJIQgP0I6ivdWakj)Lu(NebZRJqBzOImjcMI78k6od1yFWfvDDdGKtgsd6hVkjxORkPZ5il3Z27zK6EgYEMenUNT3ZILQgQeqUKSadCHKwajrUHczQe5NcUbMGHgofQL881RrdgwVgn0lK0cijYn0Jx8vqVogJuIJg6rfbDUevCNtdnAIsANIYqnYshy4uOUEnAWPtdGKtgsdoTba]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20180107.232317, [[d8ZLgaGmjP1tevBcju7IuTnIi7dc53qDAcZwjZxP6MsP7cHkFdcopKyNQ0Ef7wv7NsJssOHrkJdjepxIHcHQgmvnCv0HGqXPKeCmP4WkwiK0sjslgPwojpeI8uupMI1HestKOQMksAYuz6iUir4Zir9mIQCDLYgjIYwjQSzvy7qkxg8viuAAib8DjrJejOUTunAjL5He5KeL(lKQRruCpKaDqiQ3IeKxlP60eQHLpCmBlsqnmBuIts4WsHfmfi3QAni00uLIO3GG8KrtMW8jyeZsi5drG)CRkj5fgzdrG)sOMBtOgwIFOxGl0HzJsCsctgfLbIEnywKA6NgI1tjRVQmw)(U1teDW6rK1RPlJMwyKPflbbLW1afwu6HL9DcZqWQWp(HWTyNCJ6oDiC470HWuyqHfLEyPWcMcKBvTgeA0clfk4nLbkHAiHrQgyQ3Ird6WtcD4wS7oDiCi5wnudlXp0lWfudZgL4KeME74qFkg4DZBa9TtRFF36RO1BW4Ldx5R7W4o6vkExrF706RG1VVB9lanyz9uY6B00cJmTyjiOeMgufqvx8uoSSVtygcwf(XpeUf7KBu3PdHdFNoegvqvavDXt5WsHfmfi3QAni0OfwkuWBkduc1qcJunWuVfJg0HNe6WTy3D6q4qYvEHAyj(HEbUGAy2OeNKW0Bhh6tXaVBEdOVDA977wFfT(dqnl0lNcLGORG(i(I1JiRxgRVcw)(U1Va0GL1tjRVrtlmY0ILGGsy6fg7q)ytHsyzFNWmeSk8JFiCl2j3OUthch(oDimQlm2z9s2McLWsHfmfi3QAni0OfwkuWBkduc1qcJunWuVfJg0HNe6WTy3D6q4qYLceQHL4h6f4cQHzJsCsctVDCOpfd8U5nG(2P1VVB9igRNml4j6tXaVBEdOd)qVaN1tXw)bOMf6LtHsq0vqFeFX6rK1lJ1VVB9KrrzGOteDaDcgDNaSEkrbTEjPfgzAXsqqj8jMiWFyzFNWmeSk8JFiCl2j3OUthch(oDi8U54qtZyooOqiEmrGFe3UkSuybtbYTQwdcnAHLcf8MYaLqnKWivdm1BXObD4jHoCl2DNoeoKCLjudlXp0lWfudJmTyjiOe(auZc9YPqjiHL9DcZqWQWp(HWTyNCJ6oDiC470HWsgOML1ZNcLGewkSGPa5wvRbHgTWsHcEtzGsOgsyKQbM6Ty0Go8KqhUf7UthchsUskudlXp0lWfudZgL4Ke2GXlhUYxFkg4DZBaDf0hXxSEez9sY633TEYSGNOtJ3woqDikeD4h6f4S(9DR3b0Bhh6WOi1Gh9YPOoOVDggzAXsqqjSdJ7OxP4DLWY(oHziyv4h)q4wStUrDNoeo8D6qy5JXDRhXkExjSuybtbYTQwdcnAHLcf8MYaLqnKWivdm1BXObD4jHoCl2DNoeoKCriudlXp0lWfudZgL4KeUIwVbJxoCLVEHGv9crjQd6kOpIVy9iY61S(ky9uS1tVDCOpfd8U5nGUdx5hgzAXsqqj8umW7M3aHL9DcZqWQWp(HWTyNCJ6oDiC470HWixmW7M3aHLclykqUv1AqOrlSuOG3ugOeQHegPAGPElgnOdpj0HBXU70HWHes470HWSOJK1lXxBEd0HNqrTEKKFjKea]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20180107.232317, [[d4d5iaGEsvuBIiAxkLTPKK9PKyMKQQLrknBjMpq0nLuhMQBtX3Ke7uv2Ry3G2Vc)KuLmmLyCeQ68ekdLuLAWs1WvsDqcYPakDmk5CeQulKGAPeyXawoIhkj9uupwrpxktKufAQeYKvvtxLlcuDAsUm01PuBKuv2kryZeLTtkEgHk(mr10asnpLK63i9xIuJwPADeQKtsK8AsLRbuCpGWOasoePkYXjvbhRikSEeL52Llch(5gmmRmvhDWH7oCIgeEIRrxMQuqsybyb9gMN2fRkwwAf)MvfXbmlGjmVgNkVO0Z(POW80UkXjSqZtrHTikpRikm4qhOG)iCyEsuRVWghlTJqnBtBcbH3OV6r3s7YOl5Op3DICSjTmIppff6LrFLr3ARsyHauf1jwycDQdqDijSuWVA6hLegsHy4A6xcN8Cdgo8Znyyb0Poa1HKWcWc6nmpTlwvSwclaBuBYeBruUWv3XPUAQg0GWlaHRP)NBWW5YtBefgCOduWFeompjQ1xyaBzY2KvCdEuOCBCJGgxbBJ(QhDqVj(WcbOkQtSWYkUbpkuUngwk4xn9JscdPqmCn9lHtEUbdh(5gmS(kUbpkuUngwawqVH5PDXQI1sybyJAtMylIYfU6oo1vt1GgeEbiCn9)CdgoxEItefgCOduWFeompjQ1xyqn6Nxq4TnjEBxbLlD7OeZgcDGc(hDqcYr3NNsdkncrJcBJ(kGy01o6GD0LC0)iGTmzBOtUDekDBTshUzVE0LC0nowAhHA2M2eccVrFfqm6GEz0LC014eLduWn9QQEtPLvTewiavrDIfEs82U0fL89dQGYdlf8RM(rjHHuigUM(LWjp3GHd)CdgUkXB7JU(vY3pOckpSaSGEdZt7IvfRLWcWg1MmXweLlC1DCQRMQbni8cq4A6)5gmCU8aDefgCOduWFeompjQ1x4Zli822DvPDuIzdHoqb)JUKJoGTmzBYi02bqC4FJGgxbBJ(QhDqVj(rxYr34yPDeQzBAtii8g9vgDqVewiavrDIfwgH2oaId)HLc(vt)OKWqkedxt)s4KNBWWHFUbdRpcTDaeh(dlalO3W80UyvXAjSaSrTjtSfr5cxDhN6QPAqdcVaeUM(FUbdNlpWerHbh6af8hHdZtIA9fwJtuoqb3CDUcAdUEWwTEn(hDjhD90Odylt2MmcTDaeh(3Sxp6so6ghlTJqnBtBcbH3OVcig9kGjSqaQI6elSmcTDaeh(dlf8RM(rjHHuigUM(LWjp3GHd)CdgwFeA7aio8p6GYcSHfGf0ByEAxSQyTewa2O2Kj2IOCHRUJtD1unObHxacxt)p3GHZL3QIOWGdDGc(JWHfcqvuNyHB2Wpsuq5HLc(vt)OKWqkedxt)s4KNBWWHFUbdZ2Wpsuq5HfGf0ByEAxSQyTewa2O2Kj2IOCHRUJtD1unObHxacxt)p3GHZLxLikm4qhOG)iCyEsuRVWghlTJqnBtBcbH3OVcigDWSm6so6ACIYbk4MEvvVP0sLLrxYrxJtuoqb3KzteR6oo1j(LWcbOkQtSWfxJlDXB7HLc(vt)OKWqkedxt)s4KNBWWHFUbdRFxJp663B7HfGf0ByEAxSQyTewa2O2Kj2IOCHRUJtD1unObHxacxt)p3GHZLN4JOWGdDGc(JWHfcqvuNyHj0Poa1HKWsb)QPFusyifIHRPFjCYZny4Wp3GHfqN6auhsgDqzb2WcWc6nmpTlwvSwclaBuBYeBruUWv3XPUAQg0GWlaHRP)NBWW5YtChrHbh6af8hHdZtIA9fguJUXXs7iuZ20Mqq4n6RaIrh0Gz0bjih9Zli82MeVTRGYLUDuIzdHoqb)Joib5O7ZtPbLgHOrHTrFfqm6AhDWgwiavrDIfEs82U0fL89dQGYdlf8RM(rjHHuigUM(LWjp3GHd)CdgUkXB7JU(vY3pOckF0bLfydlalO3W80UyvXAjSaSrTjtSfr5cxDhN6QPAqdcVaeUM(FUbdNlpRLikm4qhOG)iCyHauf1jwyzf3Ghfk3gdlf8RM(rjHHuigUM(LWjp3GHd)CdgwFf3Ghfk3ghDqzb2WcWc6nmpTlwvSwclaBuBYeBruUWv3XPUAQg0GWlaHRP)NBWW5YfMNe16lCUea]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20180107.232317, [[dSJNgaGEikAteKDrHTbP0(OiYmPOkZMk3uP8nLklJOANQQ9kTBG9tvJcsrddsghfv1VbDAsgSGHtuoie6uqu5ykYFjGfsGwkrSyvz5q9qLQwfKcpwH1brHjsrutLqnzknDvUib1RGO0ZOOY1jvBurvBLI0MjLTdr(mr6WIMgevnpivUTqxgz0eYHOiCskkFxrLRbPQZdbVwr55k5POUtvCztM0sD3vblZdSs2vUSeYr5I6xoQPDttYnFJPDMd9OqFzwgnuPtHmZtbb9lhTMRmIJtbbRkU)PkUSWG85iBfSmpWkzx5lDe4mCjWUCklzqG85iRpiKpycF4PRPz4sGD5uwYqxwzeFkN6qOmgoM9uhHlBgWQg5bXLbqavEdAnnX)msLl)ZivwcCm7Pocxwc5OCr9lh10UjuLLqlOoEqRkUx59IOXSnisuKaxFL3G2FgPY96xEfxwyq(CKTcwMhyLSRSj8HtnMPas9bH8HysU1HHrJHogtGZhmjFqU8Yi(uo1HqznDmcca1eiv4YMbSQrEqCzaeqL3Gwtt8pJu5Y)msLNxhJGpa18bev4YsihLlQF5OM2nHQSeAb1XdAvX9kVxenMTbrIIe46R8g0(ZivUx)MRIllmiFoYwblZdSs2voXNslhNr6KjkfyoOtZaNGz(Gj5dO8bH8bzycjbKoSgtgAeoDcSKPWQRmIpLtDiuEGZLibCkPIoGciTSzaRAKhexgabu5nO10e)ZivU8pJu594CjYhmpLurhqbKwwc5OCr9lh10UjuLLqlOoEqRkUx59IOXSnisuKaxFL3G2FgPY96h5R4YcdYNJSvWY8aRKDLnHp8010m0CzKoiqQozOlRmIpLtDiuwZLr6GaP6uzZaw1ipiUmacOYBqRPj(NrQC5FgPYZ7YiDqGuDQSeYr5I6xoQPDtOklHwqD8GwvCVY7frJzBqKOibU(kVbT)msL71p6R4YcdYNJSvWY8aRKDLV0rGZquQCRdIJgeiFoY6dc5dMWhE6AAgAy46E4eyn0L5dc5diLyv(CKHMogH9IOXmKh9Lr8PCQdHYAy46E4eylBgWQg5bXLbqavEdAnnX)msLl)ZivEEmCDpCcSLLqokxu)YrnTBcvzj0cQJh0QI7vEViAmBdIefjW1x5nO9NrQCV(rBfxwyq(CKTcwMhyLSR8txtZqZLr6GaP6KbMIPcS8b05dO1hqwFq6W6dc5ddi0zHZbmSqyuG5ua7YatXubw(a68bPdRpGg(G8Yi(uo1HqznxgPdcKQtLndyvJ8G4YaiGkVbTMM4FgPYL)zKkpVlJ0bbs1jFanNqUYsihLlQF5OM2nHQSeAb1XdAvX9kVxenMTbrIIe46R8g0(ZivUx)7Q4YcdYNJSvWY8aRKDLV0rGZquQCRdIJgeiFoY6dc5dpDnndnmCDpCcSgykMkWYhqNpGwFaz9bPdRpiKpmGqNfohWWcHrbMtbSldmftfy5dOZhKoS(aA4dYlJ4t5uhcL1WW19WjWw2mGvnYdIldGaQ8g0AAI)zKkx(NrQ88y46E4ey9b0Cc5klHCuUO(LJAA3eQYsOfuhpOvf3R8Er0y2gejksGRVYBq7pJu5E9k)ZivMvX9(GWarjyqrcCidF4PRPT61c]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20180107.232317, [[dOtweaGEHOAtar7cLSnHi2NIkntHaZgs3uuDBb7uH9sTBO2Vu1OeI0WGOXjeLLru(MIYGvKHtIdkL6ucbDms64kQyHOGLIIwmrwoPEOuYtrEmGNtyIcjMkeMSitxYfjQoSsxw11LIZJszROuTzrX2fQonOVceMMqO(UqQNbKADcHmAPYVr1jrH(RO01asUNqsFwOCifv9AGARAeMIYZSnOLzW0yd3ebdT6NKJ7wmWdhxru)0kamX8OFf3dzivNPQklYyPod0GcjOmraAOszYuBGcYXcJWdvJWKC8kH(KzWuBjikSyZ0xD1DCwHce8nXiobb2IRnH54BkNNyF1JnCtMgB4MKV6Q74(jsbc(MyE0VI7HmKQZurAI5f8gnWfgHltT6oa4CE8hoUSKPCEASHBYLhYmctYXRe6tMbteGgQuMa4C0epAmlrX1brPHGpRgftTLGOWIntjopKnAiojmXiobb2IRnH54BkNNyF1JnCtMgB4MIcNh6NabeNeMyE0VI7HmKQZurAI5f8gnWfgHltT6oa4CE8hoUSKPCEASHBYLhG2imjhVsOpzgmraAOszA((jPMmzybOxrxwuySUcdXXy1O0pbY(PfOGXF2JFaEr)0CJA)KmtTLGOWInta6v0LffgRRWqCmtmItqGT4Atyo(MY5j2x9yd3KPXgUPw6v01pfbWyDfgIJzI5r)kUhYqQotfPjMxWB0axyeUm1Q7aGZ5XF44YsMY5PXgUjxEeXgHj54vc9jZGjcqdvktZ3pLUutMmSefxhYwpOCrjy1O0pbY(P4RgUsONv9GYfL850avuEYuBjikSyZu0qCsuAi4BQv3baNZJ)WXLLmLZtSV6XgUjtJnCtGaItIsdbFtT1XeMQvh7vwyMOoF6snzYWsuCDiB9GYfLGvJciJVA4kHEw1dkxuYNtdur5jtmp6xX9qgs1zQinX8cEJg4cJWLjgXjiWwCTjmhFt580yd3KlpaLrysoELqFYmyQTeefwSzkAiojkne8nXiobb2IRnH54BkNNyF1JnCtMgB4MabeNeLgc(9trQAeAI5r)kUhYqQotfPjMxWB0axyeUm1Q7aGZ5XF44YsMY5PXgUjxUmrkhaUOWiFlih7HSib0USba]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20171129.171639, [[dmutmaqiPOArqsTjiHAuqsCkirTlO0WaLJjLwgP4zsrzAqc5AsrSnsf13GcJduv15Ge06avzEKkY9KI0(Ge5GKsles5HKQMiOQIlsqBKubgjOQKtcvzLGQsntijDtjANG8tibgkOQslfIEkYuHkxfuvyReOVcQkAVI)kbdgOdt1Ij0JL0KLQlRAZqv9zqLrlfonQEnKQzt0Tjz3k(nkdhkA5u8CknDLUoe2ob8Dsf68sO1tQGMpPs7hWPn4cb)C8DeYnOfcYvpeXv6bafkV6Z6s4ba2p(oc5gc5L3TpqAG1IrBRMMGvtBZAMguyiQA4yUHcPTUC2ydUa1gCHeoUO89igIQgoMBO1nW9fBJ7YTbwmRlaOobaQPjaG6Qla4YvhaeLaaHHTjWGfsRixY3IHACdJBvHWB68QVmtOHnpujRlOBGC1dfcYvpe81nmUvfc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqAcUqchxu(EqlevnCm3qvgt2z64GfFU5fU8QpRlXAUY5JfaeLaa1a)HbaQRUaGRBG7l2LREHLvOZpaOo1uaqDgwiTICjFlgct2Yzti8MoV6lZeAyZdvY6c6gix9qHGC1db)YwoBcH8Y72hinWAXOfwiK3YqyQ3gCzdPVXROxYe4QpBedvY6qU6HYgOMfCHeoUO89GwiTICjFlgsh5tVGTXDti8MoV6lZeAyZdvY6c6gix9qHGC1dbFYNoai14UjeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqrbxiHJlkFpOfIQgoMBire4JpwZTSXN6lSS9kSMRC(yba1jaqnH0kYL8TyOLTxvq529MIHWB68QVmtOHnpujRlOBGC1dfcYvpeo2EfayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqnj4cjCCr57bTqAf5s(wme(CZlC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q6aU5aGcLx9zDziKxE3(aPbwlgTWcH8wgct92GlBi9nEf9sMax9zJyOswhYvpu2aPZbxiHJlkFpOfsRixY3IHSlZOkC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q0YmkaqHYR(SUmeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGWi4cjCCr57bTqAf5s(wm0Lx9zDzbLB3BkgcVPZR(YmHg28qLSUGUbYvpuiix9qcLx9zDjayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqW)GlKWXfLVh0cPvKl5BXqiSVaFVYgcVPZR(YmHg28qLSUGUbYvpuiix9qWh2daI3ELneYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqHbxiHJlkFpOfIQgoMBOMdaUU8ZI1T1pDFQh7hxu(oaOU6cakIaF8X626NUp1JfbMaG6QlayLXKDMooyDB9t3N6XAUY5JfaeLaaBcSqAf5s(wmKOKX6fWhHPyi8MoV6lZeAyZdvY6c6gix9qHGC1dHMKX6aG6aeMIHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzdulSGlKWXfLVh0crvdhZnuZbaxx(zX626NUp1J9JlkFhauxDbafrGp(yDB9t3N6XIaZqAf5s(wmK4n2BqNpWfcVPZR(YmHg28qLSUGUbYvpuiix9qODJ9g05dCHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzduBBWfs44IY3dAHOQHJ5gYRlxGx4Zv8BbarjaqnH0kYL8TyidIPGxxoBki52nK(gVIEjtGR(SrmujRlOBGC1dfcYvpesedaO26YzdaiQYTBiTg4SHgx9MIAIR0dakuE1N1LWdaulkqiQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baQffimBGA1eCHeoUO89GwiQA4yUHwx(zX626NUp1J9JlkFhauxDbabGVrfaWMdaUU8ZI1T1pDFQh7hxu(oaikgaS5aGRl)SyLC4ASdFGRGH1X(XfLVdaIIbaBoa46YplwE94JWue7hxu(oaikhsRixY3IHmiMcED5SPGKB3q6B8k6LmbU6ZgXqLSUGUbYvpuiix9qirmaGARlNnaGOk3UaGOslkhsRboBOXvVPOM4k9aGcLx9zDj8aaT8bo5baDBf1HqE5D7dKgyTy0cleYBzim1BdUSHWB68QVmtOHnpujRd5QhI4k9aGcLx9zDj8aaT8bo5baDBnBGABwWfs44IY3dAHOQHJ5gAD5NflVE8rykI9JlkFpKwrUKVfdzqmf86Yztbj3UH034v0lzcC1NnIHkzDbDdKREOqqU6HqIyaa1wxoBaarvUDbarfnOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhaKJpQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baA5dCYdaYXpBGArrbxiHJlkFpOfIQgoMBO1LFwSsoCn2HpWvWW6y)4IY3dPvKl5BXqgetbVUC2uqYTBi9nEf9sMax9zJyOswxq3a5QhkeKREiKigaqT1LZgaquLBxaquPzOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhauAqDiKxE3(aPbwlgTWcH8wgct92GlBi8MoV6lZeAyZdvY6qU6HiUspaOq5vFwxcpaqlFGtEaqPjB2qeMVYDjxh6lNnbsJoRjBca]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20171125.213329, [[d4socaGEQIAxIQ61qvZwQUjrDBc7KI9I2nj7xvLHjs)wLHskPbdjgou5GuLoMuohvHwivLLQQSyISCQ8qrLNcEmeRJQGjskLPsQMmuMUWffrxw56uvTviLntkvBhs1ZvLdlz0QQAzIYjHKEMOkNMsNNu8nr4VKsSnQImBuNG2M2l)9G(iykXiawrUFOKSpXur19WpuW5gYjKQGW36REJMS0wIwR5X8BTwAEzeaeNfxqGGxKWEQh1PPrDcjvLuFy0hbVs2Un0qa3f2travfMfPIZrqDQrq(WqRCMsmcemLye06f2tr4B9vVrtwAlrlLW3ENFhYEuNbHC)hcE5d9jMkOeb5dZuIrGbnzuNqsvj1hg9rWRKTBdneIlMqlI6fZPHaQkmlsfNJG6uJG8HHw5mLyeiykXiOFXe)qrUEXCAi8T(Q3OjlTLOLs4BVZVdzpQZGqU)dbV8H(etfuIG8HzkXiWGM8OoHKQsQpm6JGxjB3gAi8IZjWVHBocOQWSivCocQtncYhgALZuIrGGPeJaeNtGFd3Ce(wF1B0KL2s0sj8T353HSh1zqi3)HGx(qFIPckrq(WmLyeyWGaGBi2QB9Cf2trtMNYyqc]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20171125.213329, [[deeksaqikPQnrPQrrj6uuswfLukVIskvZIskXTOKISlvYWqIJrkltr5zQOyAQOextfLABuQOVbLACusHZrPcRJskP5bfL7PIQ9ru4GqHfQO6HiPMiLuuxekzJusLtsuAMuQ0nfv7eQwkr1trnvKQTsjSxP)QidwOdR0IjYJPQjRWLbBwL6ZIYOjvNMWRrkZMk3MIDJ43qgUkYXHIQLtYZfz6Q66QW2Pu(ouKZJKSEvusZNOO9l4Qv6LXxduMfgQdrSCGbi)6SwdXKGK5Gq0PkZEL40xUmFc8I1joR7lqKIpZoNvwo4GnbfFgfnS100SJlnnnkNzwz5WoOIUWaLhO)62TgykPJ80UuGzfKK1KLdq64((62TgykPJ80UghQ9fiI1gLRZyvzm8VarsLEX1k9Yyrwjhm68YSxjo9LT(q8fEAcswiktzgId0FD7wdmL0rEAxkWScskeXSZdXm)OmgscN4PQ8TBnWush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYwNBnqiY6ipTYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(SsVmwKvYbJoVm7vItFzPJ77lWRJG0e6E61HPmfS)u6GmaLGKDDCkeTpeT(qu64((AtEGmwIhUoovgdjHt8uvgw1RJ5hlnOSSKHWVpsvMGiq5C0WIvHVgOCz81aLXAvVoMFS0GYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(zk9Yyrwjhm68YyijCINQYGdma5x3KKBtFzzjdHFFKQmbrGY5OHfRcFnq5Y4RbkJLdma5xxio3TPVSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IFwk9Yyrwjhm68YSxjo9Lnl4sVczU8hkfq(qugNhIAAyhIYuMHO1hIR6f3R)VsycCobjBYSGl9kK5ciRKdgHO9HOzbx6viZL)qPaYhIY48q0oMvgdjHt8uvgw1RpL0rEALLLme(9rQYeebkNJgwSk81aLlJVgOmwR61drwh5Pvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXp7sVmwKvYbJoVmgscN4PQC6rkdnaobQYYsgc)(ivzcIaLZrdlwf(AGYLXxduMFKYqdGtGQSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IBNLEzSiRKdgDEzmKeoXtvzNaZpeJjZMz2Ph9GPSSKHWVpsvMGiq5C0WIvHVgOCz81aLTRaZpeJqmFZmBish9GPSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IJDPxglYk5GrNxM9kXPV8a9x3U1atjDKN2LcmRGKcrzeI(n9tVWaHO9HOhHCdeMitky9FzmKeoXtvz3ABNKouPVSSKHWVpsvMGiq5C0WIvHVgOCz81aLT7ABdX5hQ0xwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXTgLEzSiRKdgDEz2ReN(YwgIMfCPxHmx(dLciFikJZdXzucr7drPJ77lWbgG8RB6g5psxhNcrRcr7drldrfCRGK(k5Gq0QYyijCINQY3U1atjDKNwzQ1bpTCKnWaKVsLZrdlwf(AGYLXxdu26CRbcrwh5PfIwQzvzmuzPY)QYGFsCFUcUvqsFLCqz5Gd2eu8zu0WwJsz5qcDO8qQ07xwwYq43hPktqeOCoAGVgOC)IBhLEzSiRKdgDEz2ReN(YMfCPxHmx(dLciFikJZdrnnTquMYmeT(qCvV4E9)vctGZjiztMfCPxHmxazLCWieTpenl4sVczU8hkfq(qugNhIwd7meLPmdraZpeNobJRKb5gGsqYM0Hv9HO9HiG5hItNGX1RdtdWdcBGknj5qOX0P1)HO9HOzbx6viZL)qPaYhIYieXMsiAFi(Rdi)1E)GkPJ80UaYk5GrzmKeoXtvzyvV(ush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYyTQxpezDKNwiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCnkLEzSiRKdgDEz2ReN(Ysh33xkiHilXdtp6bZLcmRGKcrmle1OeIYuMHOLHO0X99LcsiYs8W0JEWCPaZkiPqeZcrldrPJ77Rn5bYyjE4ACO2xGiHO1Ei6ri3aHjY1M8azSepCPaZkiPq0Qq0(q0JqUbctKRn5bYyjE4sbMvqsHiMfIANDiAvzmKeoXtv5h9GzYSPhuuvwwYq43hPktqeOCoAyXQWxduUm(AGY0rpycX8n9GIQYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9lUMwPxglYk5GrNxM9kXPVSLHO0X991jeMa1e6E61HjZcU0RqMRJtHO9H46FHnyciGraPqeZcXZeIwfI2hIwgIdq64((YjY0FIGKnPqJRbctKq0QYyijCINQYorM(teKSjjK7ltTo4PLJSbgG8vQCoAyXQWxduUm(AGY2vKP)ebjleNJCFzmuzPY)QYGFsCF(aKoUVVCIm9Niiztk04AGWePSCWbBck(mkAyRrPSCiHouEiv69lllzi87JuLjicuohnWxduUFX1Mv6LXISsoy05LzVsC6llDCFFDcHjqnHUNEDyYSGl9kK564uiAFiU(xydMacyeqkeXSq8mLXqs4epvLDIm9Niiztsi3xwwYq43hPktqeOCoAyXQWxduUm(AGY2vKP)ebjleNJCFiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCTZu6LXISsoy05LzVsC6lBziU(xydMacyeqkeLriQfI2hIR)f2GjGagbKcrzeIAHOvHO9HOLH4aKoUVVCIm9Niiztk04AGWejeTQmgscN4PQSxFfKjNit)jcswzQ1bpTCKnWaKVsLZrdlwf(AGYLXxduMA9vqcr7kY0FIGKvgdvwQ8VQm4Ne3NpaPJ77lNit)jcs2KcnUgimrklhCWMGIpJIg2AuklhsOdLhsLE)YYsgc)(ivzcIaLZrd81aL7xCTZsPxglYk5GrNxM9kXPV86FHnyciGraPqugHOwiAFiU(xydMacyeqkeLriQvgdjHt8uv2RVcYKtKP)ebjRSSKHWVpsvMGiq5C0WIvHVgOCz81aLPwFfKq0UIm9NiizHOLAwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1o7sVmwKvYbJoVm7vItF5biDCFF5ez6prqYMuOX1aHjszmKeoXtvzNit)jcs2KeY9LPwh80Yr2adq(kvohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeTCMvLXqLLk)Rkd(jX95dq64((YjY0FIGKnPqJRbctKYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZol9Yyrwjhm68YyijCINQYorM(teKSjjK7lllzi87JuLjicuohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeT8mwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1WU0lJfzLCWOZlZEL40xwb3kiPVsoOmgscN4PQ8TBnWush5PvMADWtlhzdma578Y5iBcswX1kNJgwSk81aLlJVgOS15wdeISoYtleTCMvLXqLLkBq2eKSZ1Sw(vLb)K4(CfCRGK(k5GYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZAu6LXISsoy05LXqs4epvLHv96tjDKNwzQ1bpTCKnWaKVZlNJSjizfxRCoAyXQWxduUm(AGYyTQxpezDKNwiA5mRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3V4A2rPxglYk5GrNxgdjHt8uv(2TgykPJ80ktTo4PLJSbgG8DE5CKnbjR4ALZrdlwf(AGYLXxdu26CRbcrwh5PfIwEgRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3VFzRz4EpCFN3Vfa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20171125.213329, [[de00uaqivHSjsIrjs5uIOwLQq1RerQmlvHc3svOODPiddbhJelteEMQGMMQqPRHqfBterFdQ04qOsNtejRteP08Gk09ePAFiuoiczHkkperzIIifxuv0gHk4KiQMjcvDtfANQQLsu9uutfr2kjP9k9xvPbtLdR0IjYJfmzOCzWMvWNjkJMcNMQEnu1Sf1Tj1Uj8BidNK64IiSCKEUqtxLRtrBxK8DvboVIQ1lIu18HkA)u6QusL)RgkZEnzw3ZmObXT5KwRl6fYYG15hkZbQx9vUmRgc(n7t63ZJe9NijtuwoKHnc9NGGcUkkkj1KIIcHhMOSCyXMtYRHYyOBAiVA4nAGc4NOGE9I4JzAyGK5WW0qE1WB0afWpHzs3ZJepoHPhMCzIcNhjILu)kLu5NIvkdyDwzoq9QVYpY6oFaVxiZ6WjoTom0nnKxn8gnqb8tuqVEr06WX0TozbSYej5Z(BE5H8QH3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLXH8QbRJnqb8LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96prjv(PyLYawNvMduV6RSK5WWeemqq8fn8EgWRmkS3B0uGbuVq2KPARtfR7rwNK5WW0gdGaBfbyYuDzIK8z)nVmS0Zijmx8qzYfy(WEiAzbsaLhryQU0)QHYL)Rgk)CPNrsyU4HYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)WsQ8tXkLbSoRmrs(S)MxgYGge3MFLYB8ktUaZh2drllqcO8ict1L(xnuU8F1q5NzqdIBZw3S8gVYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)ylPYpfRugW6SYCG6vFLtZ60lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1LujSUKTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaFz5qg2i0Fcck4QqOSCiImPbiws9ktMbeWpIsbAqCvQ8ic7VAOCV(joLu5NIvkdyDwzoq9QVYsMddt(amysNpzQ26uX60lKJhfPNcMukioRJyPBDjiyDQyDpY6KmhgM2yaeyRiatMQTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938Yduu8EJgOa(YKlW8H9q0YcKakpIWuDP)vdLl)xnughOO4zDSbkGVSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jzjv(PyLYawNvMduV6RSEHC8Oi9uWKsbXzDelDRtrbxRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhXs36sQeLjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LMsYLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96h3sQ8tXkLbSoRmrs(S)MxoEiQgpaQbAzYfy(WEiAzbsaLhryQU0)QHYL)RgkZhIQXdGAGwwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFIBjv(PyLYawNvMduV6RCAwNEHC8Oi9uWKsbXzD4y6wNcbfRtfRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhoMU1HBsADjBDQyDpY6KmhgM2yaeyRiatMQltKKp7V5L9byWKoVm5cmFypeTSajGYJimvx6F1q5Y)vdLjpadM05LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96pPkPYpfRugW6SYej5Z(BE5Spjm9yV6vMEFp0b6YKlW8H9q0YcKakpIWuDP)vdLl)xnuM49jHPhZ6gxz616iHoqxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfcLu5NIvkdyDwzoq9QVYsMddtQrpaOVOH3ZaE1lKJhfPNmvBDQyDsMddtXdr14bqnqNmvBDQyDB48PGxqaApeToC06EyzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96xrPKk)uSszaRZkZbQx9vgdDtd5vdVrdua)ef0RxeToIzDHnEVNxdwNkwxaHYyOhiEPWgUYej5Z(BE58MAFLmPXRm5cmFypeTSajGYJimvx6F1q5Y)vdLj(n1ADZmPXRSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)kjkPYpfRugW6SYCG6vFLLmhgM8byWKoFYuT1PI1LM1LM1PxihpkspfmPuqCwhXs36sqW6s26WjoTojZHHjFagmPZNOGE9IO1HJwxAwNYeXX6ECRlQgY5xJnEG194wNK5WWKpadM05tXBd4TUKoRtX6s26sUmrs(S)MxEGII3B0afWxMCbMpShIwwGeq5reMQl9VAOC5)QHY4affpRJnqb8wxAkjxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFLhwsLFkwPmG1zL5a1R(kNM1PxihpkspfmPuqCwhXs36sqW6uX6KmhgMGmObXT53buWmozQ26s26uX6sZ6OWafIgRugSUKltKKp7V5LhYRgEJgOa(YKzab8JOuGgexLkpIWuDP)vdLl)xnughYRgSo2afWBDPPKCzIOYILVLkdUx)q6uyGcrJvkdLLdzyJq)jiOGRcHYYHiYKgGyj1Rm5cmFypeTSajGYJiS)QHY96x5XwsLFkwPmG1zL5a1R(klzomm5dWGjD(KP6Yej5Z(BE5bkkEVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1qzCGIIN1XgOaERlTejxMiQSyznkLxilDLYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9RqCkPYpfRugW6SYCG6vFL1lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1rCtsRdN406GKW0RwnGnf1Omgq9czVgWspRtfRdsctVA1a20zaVyqa8PaA8vkJqyVQ3WzDQyD6fYXJI0tbtkfeN1rmRdxcwNkw3TzqCt7Wb0ObkGFceRugWSovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LwIKllhYWgH(tqqbxfcLLdrKjnaXsQxzYmGa(rukqdIRsLhry)vdL71VsswsLFkwPmG1zL5a1R(klzommrHisSIa8EOd0tuqVEr06WrRtHqzIK8z)nV8Hoq)Q34b05LjxG5d7HOLfibuEeHP6s)Rgkx(VAOmj0bARBCJhqNxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfClPYpfRugW6SYCG6vFLLmhgMuJEaqFrdVNb8QxihpkspzQ26uX62W5tbVGa0EiAD4O19WYej5Z(BE5SxMXj8czVsO8vMCbMpShIwwGeq5reMQl9VAOC5)QHYeVxMXj8czw3mu(SU0usUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)ke3sQ8tXkLbSoRmhOE1x5nC(uWliaThIwhXSofRtfRBdNpf8ccq7HO1rmRtPmrs(S)MxoySEXB2lZ4eEHSYKlW8H9q0YcKakpIWuDP)vdLl)xnuMmJ1lSoI3lZ4eEHSYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9RKuLu5NIvkdyDwzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFwxAjsUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jiusLFkwPmG1zL5a1R(ktHbkenwPmuMijF2FZlpKxn8gnqb8LjZac4hrPaniUoR8ikLxiRFLYJimvx6F1q5Y)vdLXH8QbRJnqb8wxAjsUmruzXYAukVqw6kpg3sLb3RFiDkmqHOXkLHYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9NqPKk)uSszaRZktKKp7V5LHLEgVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1q5Nl9mSo2afWBDP9WKltevwSSgLYlKLUsz5qg2i0Fcck4QqOSCiImPbiws9ktUaZh2drllqcO8ic7VAOCV(tKOKk)uSszaRZktKKp7V5LhYRgEJgOa(YKzab8JOuGgexNvEeLYlK1Vs5reMQl9VAOC5)QHY4qE1G1XgOaERlThMCzIOYIL1OuEHS0vklhYWgH(tqqbxfcLLdrKjnaXsQxzYfy(WEiAzbsaLhry)vdL71RCsdmSM5RZ61c]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20171125.213329, [[deKhkaqijL0MGGgfukNIi0QKuqZssH6wskKDrIgMs5ye1YOu9miqttsvUMKsSnjLY3GqJtsr5CsQuRtsrmpjv19Gs1(KurhKszHKupur1eLuKUOIYgLuHtsentIGBsj7uHFkPOAPqXtrMkeTvsWEf)fsnyu5WuTyO6XkzYs5YQ2mj5ZkYOLKtt41ePzlXTj1Ub9Bugoj0XHawofpxQMoW1vQ2oK8DjLQZdLSEjfy(sQK9JQoYbzOHRFisONZZnRC9HaVut45SvZNfIwgHIGqHQPxLVxarDimVCV)mSVjJOSSCDRuwwEdbThcZ9gwif6hQXakvvC9r3RylPknx7cyVgHT2X3vPsPQIRp6EfBjvzB34abdwd3uIGsmKTfqWG9Gmd5Gm0mOJxElQdzdxueaSc1bmJw6VI3essytSCaZecYGpKfRPGBgU(HcnC9draMrl9xXBcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqg2dYqZGoE5TOoKnCrraWkK3xh2C46HKe2elhWmHGm4dzXAk4MHRFOqdx)q26RdBoC9qyE5E)zyFtgr5TqyENTBwVhKbeAE1xsTyOU(qqWdzXAdx)qbKbcgKHMbD8YBrDiB4IIaGvOIab2fn0AFs7ObmW1HKe2elhWmHGm4dzXAk4MHRFOqdx)qsqGa7IgpNLpPDEoKmW1HW8Y9(ZW(MmIYBHW8oB3SEpidi08QVKAXqD9HGGhYI1gU(HciJ6fKHMbD8YBrDiAzekccHnEoFbeOo6dVw8opx955Qhphc550(lDGHPvU2nMdb8C1j255SVXZjrEoeYZHnEoZvzEVYXlNNtIHSHlkcawHuvC9r3RylPHMx9LulgQRpee8qwSMcUz46hk0W1puDuC955Ok2sAiBMPEiGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqg1sqgAg0XlVf1HSHlkcawHUBaviWUl9HKe2elhWmHGm4dzXAk4MHRFOqdx)qZCdOcb2DPpeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazuBbzOzqhV8wuhIwgHIGqngqPQIRp6EfBjvP5Axa78C1jp3Y7a0aH(8CiKNdFxLkLfhLJUVBMUYDf55qipxTYZb8YHaLfXufakGtOnSMYdD8YB8CiKNZxabQJ(WRfVZZvFEU6fYgUOiayfQ4OC047MoiKKWMy5aMjeKbFilwtb3mC9dfA46hscokNNt9UPdcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqgigKHMbD8YBrDiAzekccvR8CaVCiqzrmvbGc4eAdRP8qhV8gphc558fqG6Op8AX78C1NNRw45QR6INd4LdbklIPkauaNqBynLh64L345qipNVacuh9HxlENNR(8C1lKnCrraWk0lxFiWlOXlEhessytSCaZecYGpKfRPGBgU(HcnC9dnRC9HaVWZPU4DqimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYOMfKHMbD8YBrDiB4IIaGvOIJYrJFxhssytSCaZecYGpKfRPGBgU(HcnC9djbhLZZP(UoeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazu3bzOzqhV8wuhIwgHIGqTJVRsLYIyQcafWj0gwtzJv7Wq2WffbaRqRkxarxetvaOaofAE1xsTyOU(qqWdzXAk4MHRFOqdx)qZRCbKNtcIPkauaNczZm1dbCZ0bOfQWE747QuPSiMQaqbCcTH1u2y1omeMxU3Fg23KruEleM3z7M17bzaHKe2elhWmHGm4dzXAdx)qbKH8wqgAg0XlVf1HSHlkcawHwvUaIUiMQaqbCkKKWMy5aMjeKbFilwtb3mC9dfA46hAELlG8CsqmvbGc4eph2KLyimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYqwoidnd64L3I6q2WffbaRqfhLJgF30bHMx9LulgQRpee1HSyOeWPmKdzXAk4MHRFOqdx)qsWr58CQ3nDaph2KLyiBMPEindLaoHD5qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqgY2dYqZGoE5TOoeTmcfbHmxL59khV8q2WffbaRqQkU(O7vSL0qZR(sQfd11hcI6qwmuc4ugYHSynfCZW1puOHRFO6O46ZZrvSLuEoSjlXq2mt9qAgkbCc7Y1yGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqaHif)s4frnWbcgmd71M9asaa]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20171217.142410, [[da04saqiKKAteQgfiPtbs8kqGmlPav3ceO2LuAyiQJrklti9mquMgiQCnPqABsH4BiuJdevDoqaRtkqmpPqDpqK9bcDqeYcLIEisLjkfiDrqQnkfWjjuMjiOBkr7eulLqEkQPIu2ksv7v5ViYGPQdlAXe8yknzP6YQ2mc(mPYOfQttXRrIzlPBtYUH63qgUqCCKKSCIEovMoW1LW2jv9DPGopsQ1lfOmFKe7xWtB0gZrU1Kvtdwcmi8GJ2irhdNQpMnk6cEORxDmiRnibVZG1vFWNo74g0tilQG1CSOxF6(GJswJynTOnABunidYIcbgl6zNAAg1hlVknyheSqbbcTPZECpX232lKjWGWJjYcmiSB0gS2OngACkuFFnhZwPjcyChbAjut1j5IrwkTYRsd2f8qm4fkiqOnD2J7j2(2EHmbgeo4fp4TiuTJAiUTM6tscfshOvEvAWUGhIbp5Gx8GNQdEHcceADaKur5pYLTfrgtKGPAaupoD2J7j2(XIH7gBcqYXye(JlrD6tjCQ(4XWP6JjYzpUNy7hl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWrhTXqJtH67R5y2knraJP6GhySumyDbpvOsW3rGwc1uDsUyKLsR8Q0GDbFJHuWRZ2htKGPAaupMqnvNKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFCdut1dEogzPmw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGHSrBm04uO((AoMTsteWyv(QdirQwBHuEmi4HiKc(OKdEXdE5vPb7c(gdPGxOGaH20zpUNy7B7fYeyq4Gx8G3Iq1oQH420zpUNy7BLxLgSl4HGcEHcceAtN94EITVTxitGbHd(gdPGVxitGbHhtKGPAaupMqnvNKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFCdut1dEogzPe8qvdkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9Xdmyi3OngACkuFFnhZwPjcySqbbcT3gJUJeIajq8jPt(eqYvG7xAW6AlIe8Ih8uDWluqGqB6Sh3tS9TfrgtKGPAaup(PeetvfjLpwmC3ytasogJWFCjQtFkHt1hpgovFm0PeetvfjLpw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGB0rBm04uO((AoMibt1aOE8RxDmiRKeQPdmwmC3ytasogJWFCjQtFkHt1hpgovFm01RogK1GVznDGXIE9P7dokznI1ipw0DOcP9UrBGX0fFlLsK(RogmHXLOoCQ(4bgCJmAJHgNc13xZXSvAIagRYxDajs1AlKYJbbpeHuWRPrCWtfQe8uDWNsGHqAbTUg(A1G1rsLV6asKQ94uO(EWlEWRYxDajs1AlKYJbbpeHuWdbIoMibt1aOE8tjiMKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFm0Peeh8CmYszSOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbt8OngACkuFFnhtKGPAaup2bqsfL)ixowmC3ytasogJWFCjQtFkHt1hpgovFmdqsfL)ixow0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGH8J2yOXPq991CmrcMQbq94QHQkmDsQuNkjbqGRglgUBSjajhJr4pUe1PpLWP6JhdNQpgcnuvHPh8LPovg80qGRgl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWqGrBm04uO((AoMTsteWyHcceAJGA4LKqeibIpjv(QdirQ2IibV4bVqbbcToasQO8h5Y2IibV4bFAbg9N0XxzUl4BCWdzJjsWunaQhxn6IbydwhjbufmwmC3ytasogJWFCjQtFkHt1hpgovFmeA0fdWgSUGVjQcgl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWAKhTXqJtH67R5y2knraJ7iqlHAQojxmYsPvEvAWUGhIbVnDasaJ6bV4bpudElcv7OgIjjFAbbpvOsWluqGqB6Sh3tS9TfrcEOmMibt1aOECn1NKekKoWyXWDJnbi5ymc)XLOo9PeovF8y4u9XqyQpd(MfshySOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbRPnAJHgNc13xZXSvAIagd1GxLV6asKQ1wiLhdcEicPGpk5Gx8GxOGaH2xV6yqwjrazlCTfrcEOe8Ih8qn4LNG8U4uO(GhkJjsWunaQhtOMQtYfJSugtx8Tukr6V6yWegxI60Ns4u9XJHt1h3a1u9GNJrwkbpuJcLXej15gdsPUdiziaj5jiVlofQFSOxF6(GJswJynYJfDhQqAVB0gySy4UXMaKCmgH)4suhovF8adwl6OngACkuFFnhZwPjcySkF1bKivRTqkpge8qesbVMMwWtfQe8uDWNsGHqAbTUg(A1G1rsLV6asKQ94uO(EWlEWRYxDajs1AlKYJbbpeHuWd5BKGNkuj4pvvyIe59wNcv7xAW6if)uccEXd(tvfMirEVfeFs9BVr)LoscveQtksAbbV4bVkF1bKivRTqkpge8qm4jMCWlEWdY6XG2Ka4sxmYsP94uO((yIemvdG6XpLGysUyKLYyXWDJnbi5ymc)XLOo9PeovF8y4u9XqNsqCWZXilLGhQAqzSOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbRbzJ2yOXPq991CmBLMiGXcfei0kVdHtS9KaiWvTYRsd2f8no41ih8uHkbpudEHcceAL3HWj2Esae4Qw5vPb7c(gh8qn4fkiqOnD2J7j2(2EHmbgeo4HGcElcv7OgIBtN94EITVvEvAWUGhkbV4bVfHQDudXTPZECpX23kVknyxW34GxRrdEOmMibt1aOEmabUIKkDGlPESy4UXMaKCmgH)4suN(ucNQpEmCQ(yAiWvbFz6axs9yrV(09bhLSgXAKhl6ouH0E3OnWy6IVLsjs)vhdMW4suhovF8adwdYnAJHgNc13xZXSvAIagNwGr)jD8vM7cEig8AbV4bFAbg9N0XxzUl4HyWRnMibt1aOECn1NKeEQglgUBSjajhJr4pUe1PpLWP6JhdNQpgct9zW38PASOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbR1OJ2yOXPq991CmBLMiGXcfei0gb1WljHiqceFsQ8vhqIuTfrcEXd(0cm6pPJVYCxW34GhYgtKGPAaupUA0fdWgSoscOkySy4UXMaKCmgH)4suN(ucNQpEmCQ(yi0OlgGnyDbFtufe8qvdkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9XdmyTgz0gdnofQVVMJzR0ebmoTaJ(t64Rm3f8qm41cEXd(0cm6pPJVYCxWdXGxBmrcMQbq9yBCAWKQgDXaSbRBSy4UXMaKCmgH)4suN(ucNQpEmCQ(y6Itdo4HqJUya2G1nw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWG1iE0gdnofQVVMJjsWunaQhxn6IbydwhjbufmwmC3ytasogJWFCjQtFkHt1hpgovFmeA0fdWgSUGVjQccEOgfkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9Xdmyni)OngACkuFFnhZwPjcyS8eK3fNc1pMibt1aOEmHAQojxmYszmDX3sPeP)QJbR54sKEdw3G1gxI60Ns4u9XJHt1h3a1u9GNJrwkbpuHmOmMiPo3yfsVbRdsAn4GuQ7asgcqsEcY7ItH6hl61NUp4OK1iwJ8yr3HkK27gTbglgUBSjajhJr4pUe1Ht1hpWG1GaJ2yOXPq991CmrcMQbq94NsqmjxmYszmDX3sPeP)QJbR54sKEdw3G1gxI60Ns4u9XJHt1hdDkbXbphJSucEOgfkJjsQZnwH0BW6GK2yrV(09bhLSgXAKhl6ouH0E3OnWyXWDJnbi5ymc)XLOoCQ(4bgCuYJ2yOXPq991CmrcMQbq9yc1uDsUyKLYy6IVLsjs)vhdwZXLi9gSUbRnUe1PpLWP6JhdNQpUbQP6bphJSucEOc5GYyIK6CJvi9gSoiPnw0RpDFWrjRrSg5XIUdviT3nAdmwmC3ytasogJWFCjQdNQpEGbgZwPjcy8aB]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20171125.224306, [[d8JyiaWyKA9QQ8sIsTluOYRvvQFd1mvv10uv0Sj58k0nHOCAu9nvf6WuTtPSxXUjSFf5NqyyuyCqKYZLQHsKbRkgochubhffkDmj5CeLyHkQLsuSyjA5u6HsONcwMKQ1rustefYur0KjQMUkxeLUQeWLv66qAJskBffQAZu02jfFuvjpdI4ZOOVRknsjqBtvbJMunEuWjjLUfejxdIQ7brQUnswlkuCCjOtvidq7ehhlQHfhCJQnaIcq(xBJnaTtCCSOgwCa)3Mwv9awxWClQV0FN5aLk(VFFPWVPmWictZ(EfDIJJf90mcWactZ(EfDIJJf90mcqy5uUDulnwa8FBAFAeGIlgytdjbkeDrx5fDIJJf9mhyeHPzFps3YCVEAgbySOl62dzAvHmaRWlvR8mhyG(4yX0ZFE)caS)NEyvl1koxn9izxAmvPFbAo1gay)p9WQwQvCUA6rYU0yQs)ciZQwVVPv3O6dvggijaqB5exGJtTiDJCPvpKbyfEPALN5ad0hhlME(Z7xaG9)0dRAPwX5QPhgTMoQ6c0CQnaW(F6HvTuR4C10dJwthvDbKzvR330QBu9HkddKeaOTCIlqUCb664x4LF06dSzoadimn77r6wM71tZiqxh)cV8JwFa9WzoGJADTctm5iXgOe10madimn77j75EAvbgryA23t2Z90qQQaDD8lPBzUxpZb(UCqqRJTbirijJ2VkizaUqoN2pSDqqRJTbKr7xfKmaTtCCSyqqRJTbMrqsIazbaILM7k(p)4yrA1)q9aDD8lqM5afIUOlJ42L(4yraz0(vbjdiqP0sJf90(mqNyvQAkVRxeRW2qgWtRkGnTQamtRkqzAv5c01XVfDIJJf9mhGbeMM99gqTEAgbKVMoQ6gK(ha4ufNEyvl1koxjRtpYxthvDbOCggqpCAgbkv8F)(sHFhuQugWve6oOJFL0WMwvaxrO7fXuL(jPHnTQauCXa6HtZiaJwthvDzoGRE9XUKgPmhqdVZl5k(nsosSb8a0oXXXIbfNPiqr2gjRmbKZ7ekFKCKyd4bCfHUpOE9XUKg20QcyDbZLCKyd4LCf)gd4OwhzCXM5aoQ1he06yBGzeKKiq2F2AKb(USgwCa)3Mwv9amKMraxrO7KUL5EsAKsRkWyQHuindzP(NgFOQ6JiXOE9pAetK6tKhWUQafzBKSYeOtSkvnL31tzaxrO7KUL5EsAytRkGRi0Dqh)kPrkTQafIUORCTc5CA)W2EMdui6IUY1sJfa)3M2NgbkeDr3bfNPGAfxa6aNBzUxnS4GBuTbquaY)ABSbqMZaNcLA6HKtTPHeJaNBzUNKgPugaOTCIlqaxrO7dQxFSlPrkTQaDD8RS3XsUqoxWSN5aewoLBhRHfhW)TPvvpaHDPXuL(ni9paWPko9WQwQvCUswNEiSlnMQ0VaswoLBhNEk6ehhlcCUL5E9auoddSPzeG0vR4ME(YIrjsZiW5wM7jPHnLb664xjnszoGmRA9(MwDJQpAilgiNXvvHCK)5NbAo1gGvTuR4C10JKLt52XafIYP)MXZ7WnQ2aEGVlRHfxajYPhWf9PNMBT43aoQ1jhj2aLOMMbCfHUxetv6NKgP0Qc01XVAfY50(HT9mhGYzaitRkGRE9XUKg2mhORJFL0WM5aDD87aBMdqJPk9tsJukdCUL5E1WIlGe50d4I(0tZTw8BaonwaeonxWmnKh47YAyXb3OAdGOaK)12ydqXfazAgbo3YCVAyXb8FBAv1diz5uUDC6POtCCSy6za16bcq7ehhlQHfxajYPhWf9PNMBT43aoQ1bIvP0YO0mcWk8s1kpZb6Ckc1oGGnT6byaHPzFpTc5CA)W2EAgbgryA23Ba16PzeyeHPzFpTc5CA)W2EAgbkIjgNEiXbyvl1koxn9mGGnanMQ0pjnSPmqxh)oGADTctCkd01XVdOhoZbo3YCVbbTo2gygbjjcKjJ2VkizaonwWyWyQ0qIrGcrx0vEnS4a(VnTQ6bmXIlWGL7QPNMBT43afIUORCzp3ZCGUo(fE5hT(ac2mhWrTEbe8laHYhxBUea]] )

    storeDefault( [[Elemental AOE]], 'displays', 20171213.230128, [[d8dmiaqyPwVQQEjjL2frKETcQFd1mHOwgr1SP48k0nrk50O8nIOCzL2jvTxXUjSFvXpHWWOKXrevpxsdLunyf1Wr4Gs0rrkvDmf5CKu0cvvwkryXOQLtLhQapf8yKSoIiMiLctfstMKmDvUijUkjv9miY1r0gPuTvKsXMLW2jkFub5ZivttvfFxvAKukABQQ0OjLXJuCsI0TiPW1iPY9qkvUnQSwKsPJtP0zkObOAIJHf2XIdUrZgaH6rrwQxjW1o67Pltp8bCTG(oqBPgoFbSLCj3sdJUGBfxaQaJikkQ7nOjogwuJ3kanikkQ7nOjogwuJ3kaHJX1UrPuybW(VX)JvaoMOujE5bSLCjxvdAIJHf18fyerrrDp02rFVA8wbO9Kl5wdA8tbnGIO5nRQ8fOK6yyXZmYS6fVKhW3CBaqb5NzfZYTIRnpZ6ULcZX3xajwZ21nE5wt)ozzHuaGYXiUahJBPDw5IxEqdOiAEZQkFbkPogw8mJmREX)BaFZTbafKFMvml3kU28mBJTOjnxajwZ21nE5wt)ozzHKKofaOCmIlqUCbQA4x4LDuALkHpqvd)wsE4WhGRPbqJ3kqt6APIcm6iXgGNSOiWySRg)Qol1CYsnrsYqcjRFKCKSsHA8J6cmIOOOUNA)QXBfOQHFrBh99Q5lWW8LcknSlakcDjKoKnrdqH547txMs4dq1ehdlkfuAyxGpeOOiOvGbyIXNzuCafZYTIRnpZLiucu1WVaA(cyl5sU2G5wQJHfbKq6q2enGGKtkfwuJ)NaJikkQ7jvOIr1h2vJ3kqvd)oOjogwuZxaAquuu3RK01XBfOjDn6iXgGNSOiaxttj5HJ3kanikkQ7jvOIr1h2vJ3kqBi0Aqd)Qltj(PaTHqRhG547txMs8tbSXw0KMlFbAZBpw1LPNVadZBhlUa6OpZqlQpZ(25WVbOAIJHfLggDrGbkEufjcyljJAyAdRc3OzdWhW3CBafZYTIRnpZLiuc4Ab9fDKyd08md7gd0KUMwmXMVa2sUKRkPuybW(VX)JvGH5TJfhW(VXpjpanikkQ7P2VA8wb0DmU2n(mpOjogw8mxs66a2nn3(mdAyQHdqdIII6EOTJ(E14Tc4wtGbkEufjcCTJ(E2XIlGo6Zm0I6ZSVDo8BG2qO1OTJ(E6YuIFkatOIr1h2vkO0WUasiDiBIgyyE7yXb3OzdGq9Oil1ReOneAnOHF1LPh)uGQg(fEzhLwj5HZxGRD03ZowCWnA2aiupkYs9kbOvtdJJK7zgLXTXJKvGreff19kjDD8wbakhJ4cuzc6MnqBi06sZBpw1LPh)uGM01LcknSlWhcuue0czf7ObiCmU2nAhloG9FJFsEac3sH547Ruh5aaJBWZSIz5wX1gj5zMWTuyo((ciXA2UUXl3AsYMMKRojvU8FqY63aCnnLkXBfaTnR4EMhYHjjI3kW1o67Pltj8bQA4x1UJ8mHkMGEnFb0DmU2n(mpOjogweW1hdhWwYLCvjvOIr1h2vZxaoMOK8WXlpGmwLXZmSBeDKydWhqfRsy6r0rInavG2qO1LM3ESQltj(Pavn8RuHkgvFyxnFbAsxdeRXi1gXBfOnV9yvxMs(cu1WV6YuYxGQg(Tuj8bOWC89Pltp8byuybq0umb94vxG2qO1OTJ(E6Y0JFkqLyng7MUQf(aCmbGgV8ax7OVNDS4a2)n(j5bOjERaunXXWc7yXfqh9zgAr9z23oh(nqBi06byo((0LPh)uafrZBwv5lqLXry2sekXJuaEd7))Hm43sJj8buTfnP5k1roaW4g8mRywUvCTrsEMvTfnP5cujwJXUPRAdWgSlOb64NcWh)ua6XpfWf)uUavn8RUm98fGQjogwyhloG9FJFsEaGyPyTH9VpgweV8FLhG3W()Fid(n8bQA43ssxlvuGdFagfwqBXyU4rYkGTKl5QYowCa7)g)K8ax7OVxPGsd7c8HaffbTKq6q2enGTKl5QsTF18fOalUaLowBEM9TZHFd0KUw9c2fGW0JRlxc]] )


end
