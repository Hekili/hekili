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
        addAura( 'crash_lightning', 187878, 'duration', 10 )
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
        addAura( 'echoes_of_the_great_sundering', 208723, 'duration', 10 )
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
        addGearSet( 'the_deceivers_blood_pact', 137035 ) 
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20180122.221851, [[du0sGaqirPwejGnrQyuOWPqKzjkYUqPHrjhdQSmPsptbLPrQKRjk02ivkFJeACII6CKa16uaMNcOUhuv7tuYbLkwOcYdjvnrsG4IkvDsfOzsQuDtsQDsP(POGgQOalvP4PsMQuLRQaITcv5RkG0Bvk1DvkzVe)ffnyHomvlgHhtXKHYLbBwrFMKmAr1PfSAsGuVwPYSr62sz3Q63OA4KOJRGQLd55kz6QCDsz7iQVtc68svTEsGK5Rq7xKfCspPuqGPRrpziPS9givfA6tX9FU)gOb)nGuedMUg9KAdqbFbIDxlCz2cNLISDhw3HHtrPkdkO8KsQoMlW)L0tSXj9KA)7euatgsQoebA46lLcdpgZvo4iPg8Xcg)4iPE(dsPMJHNJS9giLu2EdKAGgESuSYbhj1gGc(ce7Uw4ueNLuBGfxdzGL0toP0NdMDQ5KHg8NqiLAoMT3aPKtS7k9KA)7euatgsQYGckpPyKImsXZPWFS5EGUooQXcVtqbSuuNum7uKqBozNi(6iq(JXQPmfjLIJJPy2P45u4p2Cpqxhh1yH3jOawkssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKk3d01Xrn95GzNu2EdKA0mNwwgZCUDDCeKI45unyRrKuDqQws9EdWp3d01Xrn95GzxMi7unaFgmoNc)XM7b664Ogl8obfW0jBcT5KDI4RJa5pgRMssJJzFof(Jn3d01Xrnw4DckGrsQnaf8fi2DTWPiolP2alUgYalPNCsn4Jfm(Xrs98hKsnhZ2BGuYj2dt6j1(3jOaMmKuLbfuEsXifZofpNc)Xo1q9zYNm9aIfENGcyP44ykYifpNc)Xo1q9zYNm9aIfENGcyPOoPyZb66q8gRrdHG)sXSsXmBLIKsrss1HiqdxFPi7OGtqbP0NdMDQ5KHg8NqiLAogEoY2BGutnuF95GzxMTKY2BGuJM50YYyMZTRJJGuepNQbBnIsrg4ijvhKQLuV3a8NAO(6ZbZUmBLjYovdWNr2NtH)yNAO(m5tMEaXcVtqbSXrgNtH)yNAO(m5tMEaXcVtqbmDAoqxhI3YkZwKij1gGc(ce7Uw4ueNLuBGfxdzGL0toPg8Xcg)4iPE(dsPMJz7nqk5eBDj9KA)7euatgsQYGckpPyKIzNINtH)yNAO(m5tMEaXcVtqbSuCCmfzKINtH)yNAO(m5tMEaXcVtqbSuuNuS5aDDiEJ1OHqWFPywPOIwPiPuKKuDic0W1xkYok4euqk95GzNAozOb)jesPMJHNJS9gi1ud1xFoy2POLu2EdKA0mNwwgZCUDDCeKI45unyRrukYOljP6GuTK69gG)ud1xFoy2POvMi7unaFgzFof(JDQH6ZKpz6bel8obfWghzCof(JDQH6ZKpz6bel8obfW0P5aDDiEllfTirsQnaf8fi2DTWPiolP2alUgYalPNCsn4Jfm(Xrs98hKsnhZ2BGuYj2zu6j1(3jOaMmKuLbfuEsXifZofpNc)Xo1q9zYNm9aIfENGcyP44ykYifpNc)Xo1q9zYNm9aIfENGcyPOoPyZb66q8gRrdHG)sXSsrDLXuKukssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKAQH6Rphm70vgLY2BGuJM50YYyMZTRJJGuepNQbBnIsrgdJKuDqQws9EdWFQH6Rphm70vgZezNQb4Zi7ZPWFStnuFM8jtpGyH3jOa24iJZPWFStnuFM8jtpGyH3jOaMonhORdXBzPRmsIKuBak4lqS7AHtrCwsTbwCnKbwsp5KAWhly8JJK65piLAoMT3aPKtS1nPNu7FNGcyYqsvguq5jfJum7u8Ck8h7ud1NjFY0diw4DckGLIJJPiJu8Ck8h7ud1NjFY0diw4DckGLI6KInhORdXBSgnec(lfZkf7MXuKukssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKAQH6Rphm76MrPS9gi1OzoTSmM5C764iifXZPAWwJOuKHUijvhKQLuV3a8NAO(6ZbZUUzmtKDQgGpJSpNc)Xo1q9zYNm9aIfENGcyJJmoNc)Xo1q9zYNm9aIfENGcy60CGUoeVLv3msIKuBak4lqS7AHtrCwsTbwCnKbwsp5KAWhly8JJK65piLAoMT3aPKtSvu6j1(3jOaMmKuLbfuEsXifpNc)XYjditUJubSW7eualf1jfj7OGtqb2PgQV(CWStxzmf1jfBoqxhI3ynAie8xkMf(POUSsrss1HiqdxFPi7OGtqbP0NdMDQ5KHg8NqiLAogEoY2BGuCYaYK7ivGu2EdKA0mNwwgZCUDDCeKI45unyRrukYiJKKQds1sQ3Ba(CYaYK7ivqMi7unaFgNtH)y5KbKj3rQaw4DckGPdzhfCckWo1q91NdMD6kJ60CGUoeVLf(6YIKuBak4lqS7AHtrCwsTbwCnKbwsp5KAWhly8JJK65piLAoMT3aPKtSZS0tQ9VtqbmziPkdkO8KIrkMDkEof(JLtgqMChPcyH3jOawkooMImsXZPWFSCYaYK7ival8obfWsrDsrgPyZb66q8gRrdHG)sXSsrCwwP44ykA4CkgxHplnOk)(WRIjbNESiO5HFLIzLIQmyPiPuKukssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKkd1NbCofNLLu2EdKA0mNwwgZCUDDCeKI45unyRrukYq3ijvhKQLuV3a8Zq9zaNtXzzLjYovdWNr2NtH)y5KbKj3rQaw4DckGnoY4Ck8hlNmGm5osfWcVtqbmDy0CGUoeVLfolRXrdNtX4k8zPbv53hEvmj40Jfbnp8RSuzWirIKuBak4lqS7AHtrCwsTbwCnKbwsp5KAWhly8JJK65piLAoMT3aPKtSvWspP2)obfWKHKQmOGYtkgPy2P45u4pwozazYDKkGfENGcyP44ykYifpNc)XYjditUJubSW7eualf1jfzKInhORdXBSgnec(lfZkfZSvkooMIgoNIXv4ZsdQYVp8QysWPhlcAE4xPywPOkdwkskfjLIKKQdrGgU(sr2rbNGcsPphm7uZjdn4pHqk1Cm8CKT3aPYq9zaNtZSLu2EdKA0mNwwgZCUDDCeKI45unyRrukYqrss1bPAj17na)muFgW50mBLjYovdWNr2NtH)y5KbKj3rQaw4DckGnoY4Ck8hlNmGm5osfWcVtqbmDy0CGUoeVLvMTghnCofJRWNLguLFF4vXKGtpwe08WVYsLbJejssTbOGVaXURfofXzj1gyX1qgyj9KtQbFSGXposQN)GuQ5y2EdKsoXgNL0tQ9VtqbmziPkdkO8KIrkMDkEof(JLtgqMChPcyH3jOawkooMImsXZPWFSCYaYK7ival8obfWsrDsrgPyZb66q8gRrdHG)sXSsrfTsXXXu0W5umUcFwAqv(9Hxftco9yrqZd)kfZkfvzWsrsPiPuKKuDic0W1xkYok4euqk95GzNAozOb)jesPMJHNJS9givgQpd4CQIwsz7nqQrZCAzzmZ521XrqkINt1GTgrPiJmtsQoivlPEVb4NH6ZaoNQOvMi7unaFgzFof(JLtgqMChPcyH3jOa24iJZPWFSCYaYK7ival8obfW0HrZb66q8wwkAnoA4CkgxHplnOk)(WRIjbNESiO5HFLLkdgjsKKAdqbFbIDxlCkIZsQnWIRHmWs6jNud(ybJFCKup)bPuZXS9giLCInoCspP2)obfWKHKQmOGYtkgPy2P45u4pwozazYDKkGfENGcyP44ykYifpNc)XYjditUJubSW7eualf1jfzKInhORdXBSgnec(lfZkf1nRuCCmfnCofJRWNLguLFF4vXKGtpwe08WVsXSsrvgSuKukskfjjvhIanC9LISJcobfKsFoy2PMtgAWFcHuQ5y45iBVbsLH6ZaoNQBwsz7nqQrZCAzzmZ521XrqkINt1GTgrPidfmjP6GuTK69gGFgQpd4CQUzLjYovdWNr2NtH)y5KbKj3rQaw4DckGnoY4Ck8hlNmGm5osfWcVtqbmDy0CGUoeVLLUznoA4CkgxHplnOk)(WRIjbNESiO5HFLLkdgjsKKAdqbFbIDxlCkIZsQnWIRHmWs6jNud(ybJFCKup)bPuZXS9giLCInUUspP2)obfWKHKQmOGYtkgPimCTGsLag7QXPyak8QyMdo6srss1HiqdxFPi7OGtqbP0NdMDQ5KHg8NqiLAogEoY2BGu5GJU9dxlOujGjLT3aPgnZPLLXmNBxhhbPiEovd2AeLImWzrsQoivlPEVb4Ndo62pCTGsLawMi7unaFgWW1ckvcyS4YiUmJtbtsQnaf8fi2DTWPiolP2alUgYalPNCsn4Jfm(Xrs98hKsnhZ2BGuYj24gM0tQ9VtqbmziPkdkO8KIrkcdxlOujGX678WRTy6elov7aMkO1wxWaPijP6qeOHRVuKDuWjOGu6ZbZo1CYqd(tiKsnhdphz7nqkFNhET9dxlOujGjLT3aPgnZPLLXmNBxhhbPiEovd2AeLImWHJKuDqQws9EdW335HxB)W1ckvcyzISt1a8zadxlOujGXIBykALzDrsQnaf8fi2DTWPiolP2alUgYalPNCsn4Jfm(Xrs98hKsnhZ2BGuYj240L0tQ9VtqbmziPkdkO8KIrkcdxlOujGXUooQX8GMsyDRuuNum7uedi0Mt21XrnMh0ucRBXQPmfjjvhIanC9LISJcobfKsFoy2PMtgAWFcHuQ5y45iBVbsTooQ1dAkH1TKY2BGuJM50YYyMZTRJJGuepNQbBnIsrg46ssQoivlPEVb4VooQ1dAkH1TYezNQb4ZagUwqPsaJf3WueN1W0jBmGqBozxhh1yEqtjSUfRMsssTbOGVaXURfofXzj1gyX1qgyj9KtQbFSGXposQN)GuQ5y2EdKsoXgxgLEsT)DckGjdjvzqbLNumsrYok4euG135HxB)W1ckvcyPOoPiH2CYMZpM5(JXQPmf1jfZofj0Mt2jIVocK)ySAktrss1HiqdxFPi7OGtqbP0NdMDQ5KHg8NqiLAogEoY2BGu(op8ADkPS9gi1OzoTSmM5C764iifXZPAWwJOuKbUHrsQoivlPEVb4778WR1PYezNQb4ZGSJcobfy9DE412pCTGsLaMoeAZjBo)yM7pglcCZPt2eAZj7eXxhbYFmwnLKKAdqbFbIDxlCkIZsQnWIRHmWs6jNud(ybJFCKup)bPuZXS9giLCInoDt6j1(3jOaMmKuLbfuEsXifZofj0MtwAqv(9HxftdYx5SAktrDsXfCmj4V2I9caQRfZUknPywPOvkssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKs3dQYVp8Q0J8vUn)gikLY2BGuJM50YYyMZTRJJGuepNQbBnIsrg40fjP6GuTK69gGVUhuLFF4vPh5RCB(nquMjYovdWNr2eAZjlnOk)(WRIPb5RCwnL6SGJjb)1wSxaqDTy2vPHKuBak4lqS7AHtrCwsTbwCnKbwsp5KAWhly8JJK65piLAoMT3aPKtSXPO0tQ9VtqbmziPkdkO8KIrkYifj0MtwNQm3zQqoDYIGMh(vkoWPy3uuNuKqBozDQYCNPc50jlcAE4xP4aNIDtrDsrcT5K1PkZDMkKtNSiO5HFLIdCk2nfjLI6KIta5uMlLbu4yrqZd)kfZkf1vkssQoebA46lfzhfCckiL(CWStnNm0G)ecPuZXWZr2EdKYPkZ9bkNo1NdMDsz7nqQrZCAzzmZ521XrqkINt1GTgrPidCzKKuDqQws9EdW3PkZ9bkNo1NdMDzISt1a8zWqjCSteFDmviNozj0MtwNQm3zQqoDYIGMh(1a3vhLWXodaQptfYPtwcT5K1PkZDMkKtNSiO5HFnWD1rjCS0GQ87dVkMkKtNSeAZjRtvM7mviNozrqZd)AG7ssNjGCkZLYakCSiO5HFLLUij1gGc(ce7Uw4ueNLuBGfxdzGL0toPg8Xcg)4iPE(dsPMJz7nqk5eBCzw6j1(3jOaMmKuDic0W1xkTfWmCqBj1GpwW4hhj1ZFqk1Cm8CKT3aPKY2BGuJM50YYyMZThilifh8G2ARrKuBak4lqS7AHtrCwsTbwCnKbwsp5KsFoy2PMtgAWFcHuQ5y2EdKsoXgNcw6j1(3jOaMmKuDic0W1xkJtPmDZf4ptAyDsn4Jfm(Xrs98hKsnhdphz7nqkPS9gi1OzoTSmM5CB9oLMIDmxG)POUhw3wJiP6GuTK69gGVcuHM(uC)N7VbAWFdif5kHhqkGuBak4lqS7AHtrCwsTbwCnKbwsp5KsFoy2PMtgAWFcHuQ5y2EdKQcn9P4(p3Fd0G)gqkYvcpGKtS7Aj9KA)7euatgsQYGckpPi0MtwFzGhZFdWQPuQoebA46lLXPuMU5c8NjnSoP0NdMDQ5KHg8NqiLAogEoY2BGusz7nqQrZCAzzmZ526Dknf7yUa)trDpSUTgrPidCKKQds1sQ3Ba(kqfA6tX9FU)gOb)nGu0xgfqQnaf8fi2DTWPiolP2alUgYalPNCsn4Jfm(Xrs98hKsnhZ2BGuvOPpf3)5(BGg83asrFzKtS7It6j1(3jOaMmKuDic0W1xkJtPmDZf4ptAyDsn4Jfm(Xrs98hKsnhdphz7nqkPS9gi1OzoTSmM5CB9oLMIDmxG)POUhw3wJOuKrxss1bPAj17naFfOcn9P4(p3Fd0G)gqksOnNlfqQnaf8fi2DTWPiolP2alUgYalPNCsPphm7uZjdn4pHqk1CmBVbsvHM(uC)N7VbAWFdifj0MZLCID3UspP2)obfWKHKQdrGgU(szCkLPBUa)zsdRtQbFSGXposQN)GuQ5y45iBVbsjLT3aPgnZPLLXmNBR3P0uSJ5c8pf19W62AeLImggjP6GuTK69gGVcuHM(uC)N7VbAWFdif1RGSuaP2auWxGy31cNI4SKAdS4AidSKEYjL(CWStnNm0G)ecPuZXS9givfA6tX9FU)gOb)nGuuVcYsoXU7WKEsT)DckGjdjvhIanC9LY4ukt3Cb(ZKgwNud(ybJFCKup)bPuZXWZr2EdKskBVbsnAMtllJzo3wVtPPyhZf4FkQ7H1T1ikfzOlss1bPAj17naFfOcn9P4(p3Fd0G)gqkA4iqbKAdqbFbIDxlCkIZsQnWIRHmWs6jNu6ZbZo1CYqd(tiKsnhZ2BGuvOPpf3)5(BGg83asrdhbYj2D1L0tQ9VtqbmziP6qeOHRVugNsz6MlWFM0W6KAWhly8JJK65piLAogEoY2BGusz7nqQrZCAzzmZ526Dknf7yUa)trDpSUTgrPiJmssQoivlPEVb4RavOPpf3)5(BGg83asXzGsbKci1gGc(ce7Uw4ueNLuBGfxdzGL0toP0NdMDQ5KHg8NqiLAoMT3aPQqtFkU)Z93an4VbKIZaLci5KtQsjyconOGYVa)f7U62WKtea]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20180122.221851, [[dmtUbaGEujTlqLEnQsZeuLzlX8rvCtr6UOsCBrTtb7LSBf7NQYWGYVHmuqvnyHy4uOdsv1XqPfkuwkOSyk1YHQhkIEQQhtL1Hk0erfzQsYKbz6sDrr4YixxOARuu2SKA7OQ6Wk9zkYZrXYOKNjKgnvzCOI6KOQ8nk40aNhvQ3sr1FbvSnublwvPZjQEJxAftpSzs)GCsFrsmE74Omnnh9fXio5qz7T1HrfAzifSWy5mglMb4Af1kkRb97WbgBDD)UgGggvPaRQ0tmRDHGumD)2GcO5w3iQbOrNVbc42gHRpOH0trqMT4Hnt66Hnt684QRXWCU6AZHpQbOHl8GRdJk0YqkyHXAGfthgXGIJ7igvPwpPh54nfXpLPPLTEkckSzsxTcwQspXS2fcsX09BdkGMB9cWKxpGXeCy8aubsNVbc42gHRpOH0trqMT4Hnt66Hnt6WdyYRhWyYxK7bOcKomQqldPGfgRbwmDyedkoUJyuLA9KEKJ3ue)uMMw26PiOWMjD1Q1VrYb2cGRBdqJcwCiQAja]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20180122.221851, [[diurqaqikuQnrrzuuiNIuQDbrddchtcltI8mkQmnkQ6AsuSnjk5BkvghuPCokuX6KOuMhuPs3dQK9PuvhKKyHqPEifzIqLkUiuXgLOuDsssZuPk3ukTtv5NuOkdLcv1sjPEkQPcvDvOsvTvsjFLcfTxXFPGbRWHPAXQQhlPjdPld2mP4ZqXOjvNgPxtIMTuDBLSBe)MWWjHJtHkTCIEoLMUkxxk2Us57uOKXtHcNhkz9qLQmFjQ2VIofbFyChqJ30VGDyUkPkUWHvdDWTqELquGBikqSdzjZvYCf7cZkGk17uCp)OcsELklZfwL6rfeBWNxrWhghI)7aAWomxLufx4nxs9FhqQPrILjDOQSuzcRYN2PhwHbxE6aXGvbvjewvckT6NqgMiiq4wbQwU85liC4NVGW44YthiZbRGQecRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxELc(W4q8Fhqd2H5QKQ4cBSNJFJgniRs3QBOtXOFekbdYgfZHzZHxp6gyaiWIc25yFCnhLcRYN2PhwHRs3QBOtXOFekbtyvjO0QFczyIGaHBfOA5YNVGWHF(ccBs6w95ypkg9JqjycRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxEMl4dJdX)DanyhwLpTtpScBSOeuRGGjSQeuA1pHmmrqGWTcuTC5Zxq4WpFbHnMucQvqWewn0b3c5vcrXUceHvdwrJSc2Gpxyt6qvzRydwa5YpCRa95liCU8mFWhghI)7aAWomxLufxyVE0nWaqGffSZX(4AoWT5O8YNdJMdVE0nWaqGffSZX(4AokR5WS548oqoKvPB1PemgSNqUqce)3b05q7WQ8PD6Hv4Q0T6g6um6hHsWewvckT6NqgMiiq4wbQwU85liC4NVGWMKUvFo2JIr)iucM5WOcTdRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxELj4dJdX)DanyhMRsQIl8VrJgKAeYkyqOXWPdgwIgY5ucYgfZHzZrv3LyaRbnsVEubX7ZX(ZrbYDZHzZHxp6gyaiWIc25a3fxZH5dRYN2PhwHLIQYp9azyvjO0QFczyIGaHBfOA5YNVGWHF(ccRwuv(PhidRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxELvWhghI)7aAWomxLufx4nxs9FhqApHCHhwka7zdRYN2PhwHTNqUSNKQecBshQkBfBWcix(HBfOA5YNVGWHF(ccZNqUSNKQecRIeJn85smWzGQbxBUK6)oG0Ec5cpSua2Zgwn0b3c5vcrXUceHvdwrJSc2GpxyvjO0QFczyIGaHBfOpFbHZL3UGpmoe)3b0GDyUkPkUW)gnAqApHC9LucgqISrXCy2CS5sQ)7asnnsSmPdvLLktyv(0o9WkS9eYL9KuLqyvjO0QFczyIGaHBfOA5YNVGWHF(ccZNqUSNKQeMdJk0oSAOdUfYReIIDficRgSIgzfSbFUWM0HQYwXgSaYLF4wb6Zxq4C5HBbFyCi(VdOb7WCvsvCH3Cj1)DaPydKvDxIbMdZMdu43OrdsWyOqybudqhwa5SiBuewLpTtpSc3Py0pcLGXWx0VWQsqPv)eYWebbc3kq1YLpFbHd)8feEpkg9JqjyMdSf9lSAOdUfYReIIDficRgSIgzfSbFUWM0HQYwXgSaYLF4wb6Zxq4C5zCc(W4q8Fhqd2H5QKQ4c71JUbgacSOGDo2hxZH5NJYlFomAo86r3adabwuWoh7JR5O0Cy2CCEhihYQ0T6ucgd2tixibI)7a6CODyv(0o9WkCv6wDdDkg9JqjycRkbLw9tidteeiCRavlx(8feo8Zxqyts3Qph7rXOFekbZCyujTdRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxEfic(W4q8Fhqd2H5QKQ4c)B0ObPgHScgeAmC6GHLOHCoLGSrryv(0o9WkSuuv(PhidRkbLw9tidteeiCRavlx(8feo8Zxqy1IQYp9a5CyuH2HvdDWTqELquSRary1Gv0iRGn4Zf2Kouv2k2GfqU8d3kqF(ccNlVIIGpmoe)3b0GDyUkPkUWN3bYHuSbYQUlXaibI)7a6Cy2CS5sQ)7asnnsSmPdvLMVmZHzZXYHU9KIfYAJucKBo2hxZH5rewLpTtpSc3Py0pcLGXWx0VWQsqPv)eYWebbc3kq1YLpFbHd)8feEpkg9JqjyMdSf9BomQq7WQHo4wiVsik2vGiSAWkAKvWg85cBshQkBfBWcix(HBfOpFbHZLxrPGpmoe)3b0GDyUkPkUWgnh)gnAqQlod6obfzJI5WS5WO5WO5yZLu)3bKUsNsAWX42qvOaqNdZMJFJgni1if27lDckYgfZH2Zr5Lphgnhg75yZLu)3bKUsNsAWX42qvOaqNdTNdTNdTdRYN2PhwH7(MBO7w9WQsqPv)eYWebbc3kq1YLpFbHd)8feEpFZNJ9CREy1qhClKxjef7kqewnyfnYkyd(CHnPdvLTInybKl)WTc0NVGW5YRWCbFyCi(VdOb7WCvsvCHnAowo0TNuSqwBKsGCZX(4AokdI5WS5yZLu)3bKgptgFHOVdXCy2CS5sQ)7asnnsSmPdvL4gI5WS5af(nA0Gemgkewa1a0HfqolYgfZHzZbk8B0Obz3T6ucgdA6(cSiTNxvoh7phgheZH2Hv5t70dRWDFZn0DREyvjO0QFczyIGaHBfOA5YNVGWHF(ccVNV5ZXEUvFomQq7WQHo4wiVsik2vGiSAWkAKvWg85cBshQkBfBWcix(HBfOpFbHZLxH5d(W4q8Fhqd2H5QKQ4cV5sQ)7asXgiR6UedewLpTtpSc3Py0pcLGXWx0VWQsqPv)eYWebbc3kq1YLpFbHd)8feEpkg9JqjyMdSf9BomQK2HvdDWTqELquSRary1Gv0iRGn4Zf2Kouv2k2GfqU8d3kqF(ccNlVIYe8HXH4)oGgSdZvjvXfEZLu)3bKAAKyzshQknFzMdZMdJMJnxs9FhqA8mz8fIoUHyokV8543OrdsuHyzWyrjOwKnkMdTdRYN2PhwHTNqUSNKQecRkbLw9tidteeiCRavlx(8feo8Zxqy(eYL9KuLWCyujTdRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxEfLvWhghI)7aAWomxLufx4nxs9Fhq6kDkPrfoSkFANEyfwJuyVV0jOHvLGsR(jKHjcceUvGQLlF(cch(5liCzxkS3x6e0WQHo4wiVsik2vGiSAWkAKvWg85cBshQkBfBWcix(HBfOpFbHZLxXUGpmoe)3b0GDyUkPkUWE9OBGbGalkyNJ9X1CyUWQ8PD6HvyBdbfKucMWQsqPv)eYWebbc3kq1YLpFbHd)8feMBiOGKsWewn0b3c5vcrXUceHvdwrJSc2Gpxyt6qvzRydwa5YpCRa95liCU8kWTGpmoe)3b0GDyUkPkUWE9OBGbGalkyNJ9X1CyU5O8YNJnxs9FhqUhfJ(rOemMKUv)joCFfZr5LphBUK6)oG07k0DJPORXKouvgwLpTtpScxLUv3qNIr)iucMWQsqPv)eYWebbc3kq1YLpFbHd)8fe2K0T6ZXEum6hHsWmhgzoTdRg6GBH8kHOyxbIWQbROrwbBWNlSjDOQSvSblGC5hUvG(8feoxUWpFbHz6Y0CGdr3jvybKRSnhvHeYLa]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20180122.221851, [[dadqbaGEjQ2KqXUKI2guPzdLBIK(gsStLSxQDt0(vQHrkJtIyWkA4sLdkjDmfwOKQLkLwmjTCcpeQ4PGhJYZjXeLqMQu1Kjvtx0fLuEgu11rQ2Qe0MLqTDjkltiFwOQ5jj(nQUSQrlfUTGtku50iUMe48cLomKxJuwNeP9W9gk6fJOJLUUbGjiDPbdTh7iL7vK2OeTHgLMr4JWpOya6oJGWiLJscx6veU4nuLLeUuX9EnCVHAsKk21DDdatq6sdb0Xusbp0KrxiUm3Zk75OG9mM9mjHVNv2Z4z6gQQsWizSgeCgnvsEHH4K6egk5cdsU8gOY1lejwOWnyyHc3qlNrtLKxyO9yhPCVI0gugAgAVcNUGDf370aonoJgvEzpCzAvdu56lu4gC60WcfUbGeWzpRjBGKShUmlDp5DxEHtBa]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20180122.221851, [[da0UgaqiKeTjHIgfrkNcjv7Isnmk5ykvltiEgsktdjsUMkW2is8nvOXHevwhsu18qs6EijyFQGoiKYcrcpesAIcfUiKQnsKkJejHojrv3uPStigksuSuIYtrnvIyRev(ksK6TirP7Ier7v6VQunysoSOfJupMktMQUmyZQOptK0OfsNMWRfQMTIUTs2TQ(nudxHoorQA5u8CbthX1vW2vP8DHsNhsSEKimFvY(j1DVskhd4mhMKsrzKCbLzXcvTc9pA(oybpHYRvOgJqzzWeYauKiw7uoRDRJ2rOweQTFSmpcorofuIKiWFrIifQvgnhrG)qLuK9kPm6FspbFPlZoJyKuMKgPce7OqojrThDeTIQAvKd0QRlTIiwGwDOwzzFGLvz0OftbbLYrbdwewLL)9cxsWMYp(HYByVCPbjxq5Yi5cktfbdwewLLbtidqrIyTFC3QSmiGhmoiujLug1OGl(g(gSGNu6YBypsUGYLuKivsz0)KEc(srz2zeJKY0dNN2zWbVpFhypmQvxxAL00khgp94yFBpgVUhR49b7HrTI6A11LwnHBWuROQwTBzvgnAXuqqPmnycGjU4LAz5FVWLeSP8JFO8g2lxAqYfuUmsUGYuaMayIlEPwwgmHmafjI1(XDRYYGaEW4GqLuszuJcU4B4BWcEsPlVH9i5ckxsrOwLug9pPNGVuuMDgXiPm9W5PDgCW7Z3b2dJA11LwjnT6em58EyuyeeBdSsXh0Qd1Qd0kQRvxxA1eUbtTIQA1ULvz0OftbbLY0tm2F)CWGsz5FVWLeSP8JFO8g2lxAqYfuUmsUGYumXyVwjDdgukldMqgGIeXA)4UvzzqapyCqOskPmQrbx8n8nybpP0L3WEKCbLlPiuQkPm6FspbFPOm7mIrsz6HZt7m4G3NVdShg1QRlTsAAfvQvKCcpXodo4957aB4t6j41QyQvuPwDlnIKEc2rH0qqx6heJJGxRIPwDcMCEpmkmcITbwP4dA1HA1bAf11QRlTIKgPceBIyb3j47EbOvuLkOvsXQmA0IPGGs5rmrG)YY)EHljyt5h)q5nSxU0GKlOCzKCbLVCNNwwo35jLLYGjc8tjVmLLbtidqrIyTFC3QSmiGhmoiujLug1OGl(g(gSGNu6YBypsUGYLuKdQKYO)j9e8LIYOrlMcckLpbtoVhgfgbPS8Vx4sc2u(XpuEd7Llni5ckxgjxqzPdm5uR4rHrqkldMqgGIeXA)4UvzzqapyCqOskPmQrbx8n8nybpP0L3WEKCbLlPisPskJ(N0tWxkkZoJyKu2HXtpo23odo4957aBdSsXh0Qd1kPOvxxAfjNWtSPXdtpyofbIn8j9e8A11Lw5b6HZtBinKOWFpmkId2dJLrJwmfeuk7X419yfVpuw(3lCjbBk)4hkVH9YLgKCbLlJKlOCmW4LwrPfVpuwgmHmafjI1(XDRYYGaEW4GqLuszuJcU4B4BWcEsPlVH9i5ckxsrowjLr)t6j4lfLzNrmsklnTYHXtpo23oqWMvGyeXbBdSsXh0Qd1klTI6Avm1k6HZt7m4G3NVdS94y)YOrlMcckLZGdEF(oOS8Vx4sc2u(XpuEd7Llni5ckxgjxqz0co4957GYYGjKbOirS2pUBvwgeWdgheQKskJAuWfFdFdwWtkD5nShjxq5skPm7mIrs5sAb]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20180122.221851, [[d4Z(iaGEHcAteu7sPSnHcTpLeZuOKLrkMTG5deDtL43i9nHQldTtvzVs7g0(f1OasnmHmoGKZtinuGqdwKHRK6GeKtbu6yuY5ekWcjelLalgWYr8qsLNI6XkADeH0ejcXujutwvnDvUiq1Pj5zcL66uQnQKKTsKSzIY2jQUnfFMuAAebZdi4Wu9AsvJwP6VePojr0pvsQRju09akEUchIiuDCIq5AvXLLiOm3oCvKY8KOwFLlladOpW(0ezbQiRO4BAITMyBfVmVgNkpOIH(POW(0eJXUSqZtrHJkUpRkUm4qhiG)kszEsuRVYghdJJqnBtBcbHxobc5KLMOCs4CAU7eT4qAzeFEkk0d50k5K1w8YcbOcQt0Ye6upG6qszjHF10pkPmKcXYl0Vuo55gSC5NBWYcOt9aQdjLfGb0hyFAISIBfvwaoO2KjoQ4EL1TJt9lu5ObHxbkVq)p3GL71NMkUm4qhiG)kszEsuRVYa2YKTjl4g8OqT24gbnUcoYjqiNKWgOkleGkOorlll4g8OqT2yzjHF10pkPmKcXYl0Vuo55gSC5NBWYRk4g8OqT2yzbya9b2NMiR4wrLfGdQnzIJkUxzD74u)cvoAq4vGYl0)Zny5E9f7kUm4qhiG)kszEsuRVYGoNopGWBBs8XUcQv6XrjMne6ab8NtGeK5KppLCuAeIgfoYPvatoPjNaBojCo9raBzY2qNC7iu6XALECZEDojCozCmmoc1SnTjeeE50kGjNKquojCoj3jkhiGBRwhisPbqfvwiavqDIwEs8XU0bL29dQGAllj8RM(rjLHuiwEH(LYjp3GLl)CdwwhXh75uSuA3pOcQTSamG(a7ttKvCROYcWb1MmXrf3RSUDCQFHkhni8kq5f6)5gSCV(KqfxgCOdeWFfPmpjQ1x5Zdi822DvyCuIzdHoqa)5KW5eGTmzBYi0XbqC4FJGgxbh5eiKtsydu5KW5KXXW4iuZ20Mqq4LtRKtsiQSqaQG6eTSmcDCaeh(llj8RM(rjLHuiwEH(LYjp3GLl)CdwEve64aio8xwagqFG9PjYkUvuzb4GAtM4OI7vw3oo1VqLJgeEfO8c9)CdwUxFXSIldo0bc4VIuMNe16RSCNOCGaU56Df0gCjMTA9A8NtcNts8CcWwMSnze64aio8VzVoNeoNmogghHA2M2eccVCAfWKtXJzzHaub1jAzze64aio8xws4xn9JskdPqS8c9lLtEUblx(5gS8Qi0XbqC4pNaTfylladOpW(0ezf3kQSaCqTjtCuX9kRBhN6xOYrdcVcuEH(FUbl3RVySIldo0bc4VIuwiavqDIwEyd)irb1wws4xn9JskdPqS8c9lLtEUblx(5gSmBd)irb1wwagqFG9PjYkUvuzb4GAtM4OI7vw3oo1VqLJgeEfO8c9)CdwUxFXR4YGdDGa(RiL5jrT(kBCmmoc1SnTjeeE50kGjNIzuojCoj3jkhiGBRwhisPbROOCs4CsUtuoqa3Kztev3oo1hpQSqaQG6eTCWL7sh8XEzjHF10pkPmKcXYl0Vuo55gSC5NBWYXYL75uS8XEzbya9b2NMiR4wrLfGdQnzIJkUxzD74u)cvoAq4vGYl0)Zny5E9bQkUm4qhiG)kszHaub1jAzcDQhqDiPSKWVA6hLugsHy5f6xkN8CdwU8Znyzb0PEa1HKCc0wGTSamG(a7ttKvCROYcWb1MmXrf3RSUDCQFHkhni8kq5f6)5gSCV(IbvCzWHoqa)vKY8KOwFLbDozCmmoc1SnTjeeE50kGjNKqmZjqcYC68acVTjXh7kOwPhhLy2qOdeWFobsqMt(8uYrPriAu4iNwbm5KMCcS5KW5KCNOCGaUTADGiLgavuzHaub1jA5jXh7shuA3pOcQTSKWVA6hLugsHy5f6xkN8CdwU8ZnyzDeFSNtXsPD)GkO2Cc0wGTSamG(a7ttKvCROYcWb1MmXrf3RSUDCQFHkhni8kq5f6)5gSCV(SIQ4YGdDGa(RiLfcqfuNOLLfCdEuOwBSSKWVA6hLugsHy5f6xkN8CdwU8Zny5vfCdEuOwBmNaTfylladOpW(0ezf3kQSaCqTjtCuX9kRBhN6xOYrdcVcuEH(FUbl3Rx5NBWYSYOlNahU7WjAq4jrZjzQqaj9Ab]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20180122.221851, [[dSJNgaGEiOAteKDrHTbP0(Gu0mHGy2u5MkLBtvlJOStv1EL2nW(fAuqkmmiACqq6WI(MsLbly4evhesCkkICmf1NjIfsqTuczXQYYH6HksRcsQEScpxjtKIOMkrAYuA6QCrc4vqs6YixNuTrkQ2kfLntkBhcDAsEgKQMgKuMhKkVwrCikcJMqToiOCsksFhcCnijoVsv)La9Bqpf1DUslBYKwQ7UkC5F6PYSYpngeaiobdYtGdHfdpDnTvzrKJYf1VmKZiuKZi3zid9Yq)8UYSCAOsNcHNNcc6xgArFzugNccwvA)ZvAzba5Zr2kCzEGvYVYx6iWz4sGD5uwYGa5Zr2yqOyWeXWtxtZWLa7YPSKHU8YO8uo1TVmgoM8uhHlBkWQg5bXLbqavEdAnlX)0tLl)tpvweCm5Pocxwe5OCr9ld58UzKLfrlOoEqRkTx5PIPXKniIKNaxFL3G2F6PY96xwLwwaq(CKTcxMhyL8RSjIHtnMOasIbHIbFsU1HHEJHogtGlgqZyqMSYO8uo1TVSMoEVGqnbtfUSPaRAKhexgabu5nO1Se)tpvU8p9uzZ1X7JbOwmGIcxwe5OCr9ld58UzKLfrlOoEqRkTx5PIPXKniIKNaxFL3G2F6PY96h9vAzba5Zr2kCzEGvYVYj(uA54msNCXPGia60mWjysmGMXaYyqOyqoMquqjdRXSHgHtNGl5kS6kJYt5u3(YdCUelOtjr8buajLnfyvJ8G4YaiGkVbTML4F6PYL)PNkpfNlXXacrjr8buajLfrokxu)YqoVBgzzr0cQJh0Qs7vEQyAmzdIi5jW1x5nO9NEQCV(rTkTSaG85iBfUmpWk5xztedpDnndnx6PdcKOtg6YlJYt5u3(YAU0theirNkBkWQg5bXLbqavEdAnlX)0tLl)tpv2Cx6PdcKOtLfrokxu)YqoVBgzzr0cQJh0Qs7vEQyAmzdIi5jW1x5nO9NEQCV(rLkTSaG85iBfUmpWk5x5lDe4meNk36GyVbbYNJSXGqXGjIHNUMMHggUUhobwdD5XGqXaIjwLphzOPJ3pvmnMGAOszuEkN62xwddx3dNaBztbw1ipiUmacOYBqRzj(NEQC5F6PYMJHR7HtGTSiYr5I6xgY5DZillIwqD8GwvAVYtftJjBqejpbU(kVbT)0tL71pAR0YcaYNJSv4Y8aRKFLF6AAgAU0theirNmWKpvGvmGUyaTXaQgdsg2yqOyyaHolebadle6febkGDzGjFQaRyaDXGKHngq9yqwzuEkN62xwZLE6Gaj6uztbw1ipiUmacOYBqRzj(NEQC5F6PYM7spDqGeDkgqJztQSiYr5I6xgY5DZillIwqD8GwvAVYtftJjBqejpbU(kVbT)0tL71)UkTSaG85iBfUmpWk5x5lDe4meNk36GyVbbYNJSXGqXWtxtZqddx3dNaRbM8PcSIb0fdOngq1yqYWgdcfddi0zHiayyHqVGiqbSldm5tfyfdOlgKmSXaQhdYkJYt5u3(YAy46E4eylBkWQg5bXLbqavEdAnlX)0tLl)tpv2CmCDpCcSXaAmBsLfrokxu)YqoVBgzzr0cQJh0Qs7vEQyAmzdIi5jW1x5nO9NEQCVEL5bwj)k3Rf]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20180122.221851, [[dKZgeaGEsKAtKaTlHQTrcQ9rcYmjbmBeUPq(MiStrTxQDRQ9JugfjKgMszCKqSmKQbJKgosCqr0Pir4yKYVrzHiILIOwmHworpus5PqpwjphvtKevtvKMSetxQlkuUm4zKQCDc68eOTIiTzsITtsDAv(kPQMgju9DsshwXFLunAj51kvNKaUTGRrcL7rIYNjvoejIwhjs2Ao1OYbvgHeTjXisbw3qCk90h7DMUcRNrYabmCWz6BAkYM2wI401JUEAjmIl5rPnAm5Qp2ZDQZAo1ySFejGIjXysXJ4AbncJSRGVoNYTdgf4l3AAM04ZEWyeRq6iZtamAmpbWySr2vWtJks52bJKbcy4GZ030sOTzKmWzcLlG7u3gRvbR9iMAiaFBrJrSsEcGr3ot3PgJ9JibumjgXL8O0gxmgrHP6hN3mzG3YBhIlKIXKIhX1cASWyH6QEFHBuGVCRPzsJp7bJrScPJmpbWOX8eaJkNXc0OQ)9fUrYabmCWz6BAj02msg4mHYfWDQBJ1QG1EetneGVTOXiwjpbWOBN1ZPgJ9JibumjgXL8O0gvsAuffQIkXxYHxvN40v1)96IlKcnQkinQZQp1qD4HWbCAuviLrJkDJjfpIRf04so8Q6eNUQ(VxNrb(YTMMjn(ShmgXkKoY8eaJgZtamwto8kAuvGtxv)3RZizGago4m9nTeABgjdCMq5c4o1TXAvWApIPgcW3w0yeRKNay0TZkUtng7hrcOysmIl5rPnQEK3isaX5ntgsHafG3CJjfpIRf0OQ3x4T82bJ1QG1EetneGVTOXiwH0rMNay0yEcGr9VVWB5Tdgtk1Xn2Juh01pvuM6rEJibeN3mzifcuaEZnsgiGHdotFtlH2MrYaNjuUaUtDBuGVCRPzsJp7bJrSsEcGr3oRyo1ySFejGIjXysXJ4AbnQ69fElVDWOaF5wtZKgF2dgJyfshzEcGrJ5jag1)(cVL3oqJQIQPegjdeWWbNPVPLqBZizGZekxa3PUnwRcw7rm1qa(2IgJyL8eaJUDBmpbWiEHA0Og7RMFbb4BLIg1HVCBd]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20171129.171639, [[dmutmaqiPOArqsTjiHAuqsCkirTlO0WaLJjLwgP4zsrzAqc5AsrSnsf13GcJduv15Ge06avzEKkY9KI0(Ge5GKsles5HKQMiOQIlsqBKubgjOQKtcvzLGQsntijDtjANG8tibgkOQslfIEkYuHkxfuvyReOVcQkAVI)kbdgOdt1Ij0JL0KLQlRAZqv9zqLrlfonQEnKQzt0Tjz3k(nkdhkA5u8CknDLUoe2ob8Dsf68sO1tQGMpPs7hWPn4cb)C8DeYnOfcYvpeXv6bafkV6Z6s4ba2p(oc5gc5L3TpqAG1IrBRMMGvtBZAMguyiQA4yUHcPTUC2ydUa1gCHeoUO89igIQgoMBO1nW9fBJ7YTbwmRlaOobaQPjaG6Qla4YvhaeLaaHHTjWGfsRixY3IHACdJBvHWB68QVmtOHnpujRlOBGC1dfcYvpe81nmUvfc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqAcUqchxu(EqlevnCm3qvgt2z64GfFU5fU8QpRlXAUY5JfaeLaa1a)HbaQRUaGRBG7l2LREHLvOZpaOo1uaqDgwiTICjFlgct2Yzti8MoV6lZeAyZdvY6c6gix9qHGC1db)YwoBcH8Y72hinWAXOfwiK3YqyQ3gCzdPVXROxYe4QpBedvY6qU6HYgOMfCHeoUO89GwiTICjFlgsh5tVGTXDti8MoV6lZeAyZdvY6c6gix9qHGC1dbFYNoai14UjeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqrbxiHJlkFpOfIQgoMBire4JpwZTSXN6lSS9kSMRC(yba1jaqnH0kYL8TyOLTxvq529MIHWB68QVmtOHnpujRlOBGC1dfcYvpeo2EfayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqnj4cjCCr57bTqAf5s(wme(CZlC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q6aU5aGcLx9zDziKxE3(aPbwlgTWcH8wgct92GlBi9nEf9sMax9zJyOswhYvpu2aPZbxiHJlkFpOfsRixY3IHSlZOkC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q0YmkaqHYR(SUmeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGWi4cjCCr57bTqAf5s(wm0Lx9zDzbLB3BkgcVPZR(YmHg28qLSUGUbYvpuiix9qcLx9zDjayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqW)GlKWXfLVh0cPvKl5BXqiSVaFVYgcVPZR(YmHg28qLSUGUbYvpuiix9qWh2daI3ELneYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqHbxiHJlkFpOfIQgoMBOMdaUU8ZI1T1pDFQh7hxu(oaOU6cakIaF8X626NUp1JfbMaG6QlayLXKDMooyDB9t3N6XAUY5JfaeLaaBcSqAf5s(wmKOKX6fWhHPyi8MoV6lZeAyZdvY6c6gix9qHGC1dHMKX6aG6aeMIHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzdulSGlKWXfLVh0crvdhZnuZbaxx(zX626NUp1J9JlkFhauxDbafrGp(yDB9t3N6XIaZqAf5s(wmK4n2BqNpWfcVPZR(YmHg28qLSUGUbYvpuiix9qODJ9g05dCHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzduBBWfs44IY3dAHOQHJ5gYRlxGx4Zv8BbarjaqnH0kYL8TyidIPGxxoBki52nK(gVIEjtGR(SrmujRlOBGC1dfcYvpesedaO26YzdaiQYTBiTg4SHgx9MIAIR0dakuE1N1LWdaulkqiQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baQffimBGA1eCHeoUO89GwiQA4yUHwx(zX626NUp1J9JlkFhauxDbabGVrfaWMdaUU8ZI1T1pDFQh7hxu(oaikgaS5aGRl)SyLC4ASdFGRGH1X(XfLVdaIIbaBoa46YplwE94JWue7hxu(oaikhsRixY3IHmiMcED5SPGKB3q6B8k6LmbU6ZgXqLSUGUbYvpuiix9qirmaGARlNnaGOk3UaGOslkhsRboBOXvVPOM4k9aGcLx9zDj8aaT8bo5baDBf1HqE5D7dKgyTy0cleYBzim1BdUSHWB68QVmtOHnpujRd5QhI4k9aGcLx9zDj8aaT8bo5baDBnBGABwWfs44IY3dAHOQHJ5gAD5NflVE8rykI9JlkFpKwrUKVfdzqmf86Yztbj3UH034v0lzcC1NnIHkzDbDdKREOqqU6HqIyaa1wxoBaarvUDbarfnOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhaKJpQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baA5dCYdaYXpBGArrbxiHJlkFpOfIQgoMBO1LFwSsoCn2HpWvWW6y)4IY3dPvKl5BXqgetbVUC2uqYTBi9nEf9sMax9zJyOswxq3a5QhkeKREiKigaqT1LZgaquLBxaquPzOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhauAqDiKxE3(aPbwlgTWcH8wgct92GlBi8MoV6lZeAyZdvY6qU6HiUspaOq5vFwxcpaqlFGtEaqPjB2qeMVYDjxh6lNnbsJoRjBca]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20171125.213329, [[d4socaGEQIAxIQ61qvZwQUjrDBc7KI9I2nj7xvLHjs)wLHskPbdjgou5GuLoMuohvHwivLLQQSyISCQ8qrLNcEmeRJQGjskLPsQMmuMUWffrxw56uvTviLntkvBhs1ZvLdlz0QQAzIYjHKEMOkNMsNNu8nr4VKsSnQImBuNG2M2l)9G(iykXiawrUFOKSpXur19WpuW5gYjKQGW36REJMS0wIwR5X8BTwAEzeaeNfxqGGxKWEQh1PPrDcjvLuFy0hbVs2Un0qa3f2travfMfPIZrqDQrq(WqRCMsmcemLye06f2tr4B9vVrtwAlrlLW3ENFhYEuNbHC)hcE5d9jMkOeb5dZuIrGbnzuNqsvj1hg9rWRKTBdneIlMqlI6fZPHaQkmlsfNJG6uJG8HHw5mLyeiykXiOFXe)qrUEXCAi8T(Q3OjlTLOLs4BVZVdzpQZGqU)dbV8H(etfuIG8HzkXiWGM8OoHKQsQpm6JGxjB3gAi8IZjWVHBocOQWSivCocQtncYhgALZuIrGGPeJaeNtGFd3Ce(wF1B0KL2s0sj8T353HSh1zqi3)HGx(qFIPckrq(WmLyeyWGaGBi2QB9Cf2trtMNYyqc]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20171125.213329, [[deeksaqikPQnrPQrrj6uuswfLukVIskvZIskXTOKISlvYWqIJrkltr5zQOyAQOextfLABuQOVbLACusHZrPcRJskP5bfL7PIQ9ru4GqHfQO6HiPMiLuuxekzJusLtsuAMuQ0nfv7eQwkr1trnvKQTsjSxP)QidwOdR0IjYJPQjRWLbBwL6ZIYOjvNMWRrkZMk3MIDJ43qgUkYXHIQLtYZfz6Q66QW2Pu(ouKZJKSEvusZNOO9l4Qv6LXxduMfgQdrSCGbi)6SwdXKGK5Gq0PkZEL40xUmFc8I1joR7lqKIpZoNvwo4GnbfFgfnS100SJlnnnkNzwz5WoOIUWaLhO)62TgykPJ80UuGzfKK1KLdq64((62TgykPJ80UghQ9fiI1gLRZyvzm8VarsLEX1k9Yyrwjhm68YSxjo9LT(q8fEAcswiktzgId0FD7wdmL0rEAxkWScskeXSZdXm)OmgscN4PQ8TBnWush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYwNBnqiY6ipTYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(SsVmwKvYbJoVm7vItFzPJ77lWRJG0e6E61HPmfS)u6GmaLGKDDCkeTpeT(qu64((AtEGmwIhUoovgdjHt8uvgw1RJ5hlnOSSKHWVpsvMGiq5C0WIvHVgOCz81aLXAvVoMFS0GYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(zk9Yyrwjhm68YyijCINQYGdma5x3KKBtFzzjdHFFKQmbrGY5OHfRcFnq5Y4RbkJLdma5xxio3TPVSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IFwk9Yyrwjhm68YSxjo9Lnl4sVczU8hkfq(qugNhIAAyhIYuMHO1hIR6f3R)VsycCobjBYSGl9kK5ciRKdgHO9HOzbx6viZL)qPaYhIY48q0oMvgdjHt8uvgw1RpL0rEALLLme(9rQYeebkNJgwSk81aLlJVgOmwR61drwh5Pvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXp7sVmwKvYbJoVmgscN4PQC6rkdnaobQYYsgc)(ivzcIaLZrdlwf(AGYLXxduMFKYqdGtGQSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IBNLEzSiRKdgDEzmKeoXtvzNaZpeJjZMz2Ph9GPSSKHWVpsvMGiq5C0WIvHVgOCz81aLTRaZpeJqmFZmBish9GPSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IJDPxglYk5GrNxM9kXPV8a9x3U1atjDKN2LcmRGKcrzeI(n9tVWaHO9HOhHCdeMitky9FzmKeoXtvz3ABNKouPVSSKHWVpsvMGiq5C0WIvHVgOCz81aLT7ABdX5hQ0xwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXTgLEzSiRKdgDEz2ReN(YwgIMfCPxHmx(dLciFikJZdXzucr7drPJ77lWbgG8RB6g5psxhNcrRcr7drldrfCRGK(k5Gq0QYyijCINQY3U1atjDKNwzQ1bpTCKnWaKVsLZrdlwf(AGYLXxdu26CRbcrwh5PfIwQzvzmuzPY)QYGFsCFUcUvqsFLCqz5Gd2eu8zu0WwJsz5qcDO8qQ07xwwYq43hPktqeOCoAGVgOC)IBhLEzSiRKdgDEz2ReN(YMfCPxHmx(dLciFikJZdrnnTquMYmeT(qCvV4E9)vctGZjiztMfCPxHmxazLCWieTpenl4sVczU8hkfq(qugNhIwd7meLPmdraZpeNobJRKb5gGsqYM0Hv9HO9HiG5hItNGX1RdtdWdcBGknj5qOX0P1)HO9HOzbx6viZL)qPaYhIYieXMsiAFi(Rdi)1E)GkPJ80UaYk5GrzmKeoXtvzyvV(ush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYyTQxpezDKNwiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCnkLEzSiRKdgDEz2ReN(Ysh33xkiHilXdtp6bZLcmRGKcrmle1OeIYuMHOLHO0X99LcsiYs8W0JEWCPaZkiPqeZcrldrPJ77Rn5bYyjE4ACO2xGiHO1Ei6ri3aHjY1M8azSepCPaZkiPq0Qq0(q0JqUbctKRn5bYyjE4sbMvqsHiMfIANDiAvzmKeoXtv5h9GzYSPhuuvwwYq43hPktqeOCoAyXQWxduUm(AGY0rpycX8n9GIQYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9lUMwPxglYk5GrNxM9kXPVSLHO0X991jeMa1e6E61HjZcU0RqMRJtHO9H46FHnyciGraPqeZcXZeIwfI2hIwgIdq64((YjY0FIGKnPqJRbctKq0QYyijCINQYorM(teKSjjK7ltTo4PLJSbgG8vQCoAyXQWxduUm(AGY2vKP)ebjleNJCFzmuzPY)QYGFsCF(aKoUVVCIm9Niiztk04AGWePSCWbBck(mkAyRrPSCiHouEiv69lllzi87JuLjicuohnWxduUFX1Mv6LXISsoy05LzVsC6llDCFFDcHjqnHUNEDyYSGl9kK564uiAFiU(xydMacyeqkeXSq8mLXqs4epvLDIm9Niiztsi3xwwYq43hPktqeOCoAyXQWxduUm(AGY2vKP)ebjleNJCFiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCTZu6LXISsoy05LzVsC6lBziU(xydMacyeqkeLriQfI2hIR)f2GjGagbKcrzeIAHOvHO9HOLH4aKoUVVCIm9Niiztk04AGWejeTQmgscN4PQSxFfKjNit)jcswzQ1bpTCKnWaKVsLZrdlwf(AGYLXxduMA9vqcr7kY0FIGKvgdvwQ8VQm4Ne3NpaPJ77lNit)jcs2KcnUgimrklhCWMGIpJIg2AuklhsOdLhsLE)YYsgc)(ivzcIaLZrd81aL7xCTZsPxglYk5GrNxM9kXPV86FHnyciGraPqugHOwiAFiU(xydMacyeqkeLriQvgdjHt8uv2RVcYKtKP)ebjRSSKHWVpsvMGiq5C0WIvHVgOCz81aLPwFfKq0UIm9NiizHOLAwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1o7sVmwKvYbJoVm7vItF5biDCFF5ez6prqYMuOX1aHjszmKeoXtvzNit)jcs2KeY9LPwh80Yr2adq(kvohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeTCMvLXqLLk)Rkd(jX95dq64((YjY0FIGKnPqJRbctKYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZol9Yyrwjhm68YyijCINQYorM(teKSjjK7lllzi87JuLjicuohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeT8mwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1WU0lJfzLCWOZlZEL40xwb3kiPVsoOmgscN4PQ8TBnWush5PvMADWtlhzdma578Y5iBcswX1kNJgwSk81aLlJVgOS15wdeISoYtleTCMvLXqLLkBq2eKSZ1Sw(vLb)K4(CfCRGK(k5GYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZAu6LXISsoy05LXqs4epvLHv96tjDKNwzQ1bpTCKnWaKVZlNJSjizfxRCoAyXQWxduUm(AGYyTQxpezDKNwiA5mRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3V4A2rPxglYk5GrNxgdjHt8uv(2TgykPJ80ktTo4PLJSbgG8DE5CKnbjR4ALZrdlwf(AGYLXxdu26CRbcrwh5PfIwEgRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3VFzRz4EpCFN3Vfa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20171125.213329, [[de00uaqivHSjsIrjs5uIOwLQq1RerQmlvHc3svOODPiddbhJelteEMQGMMQqPRHqfBterFdQ04qOsNtejRteP08Gk09ePAFiuoiczHkkperzIIifxuv0gHk4KiQMjcvDtfANQQLsu9uutfr2kjP9k9xvPbtLdR0IjYJfmzOCzWMvWNjkJMcNMQEnu1Sf1Tj1Uj8BidNK64IiSCKEUqtxLRtrBxK8DvboVIQ1lIu18HkA)u6QusL)RgkZEnzw3ZmObXT5KwRl6fYYG15hkZbQx9vUmRgc(n7t63ZJe9NijtuwoKHnc9NGGcUkkkj1KIIcHhMOSCyXMtYRHYyOBAiVA4nAGc4NOGE9I4JzAyGK5WW0qE1WB0afWpHzs3ZJepoHPhMCzIcNhjILu)kLu5NIvkdyDwzoq9QVYpY6oFaVxiZ6WjoTom0nnKxn8gnqb8tuqVEr06WX0TozbSYej5Z(BE5H8QH3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLXH8QbRJnqb8LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96prjv(PyLYawNvMduV6RSK5WWeemqq8fn8EgWRmkS3B0uGbuVq2KPARtfR7rwNK5WW0gdGaBfbyYuDzIK8z)nVmS0Zijmx8qzYfy(WEiAzbsaLhryQU0)QHYL)Rgk)CPNrsyU4HYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)WsQ8tXkLbSoRmrs(S)MxgYGge3MFLYB8ktUaZh2drllqcO8ict1L(xnuU8F1q5NzqdIBZw3S8gVYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)ylPYpfRugW6SYCG6vFLtZ60lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1LujSUKTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaFz5qg2i0Fcck4QqOSCiImPbiws9ktMbeWpIsbAqCvQ8ic7VAOCV(joLu5NIvkdyDwzoq9QVYsMddt(amysNpzQ26uX60lKJhfPNcMukioRJyPBDjiyDQyDpY6KmhgM2yaeyRiatMQTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938Yduu8EJgOa(YKlW8H9q0YcKakpIWuDP)vdLl)xnughOO4zDSbkGVSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jzjv(PyLYawNvMduV6RSEHC8Oi9uWKsbXzDelDRtrbxRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhXs36sQeLjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LMsYLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96h3sQ8tXkLbSoRmrs(S)MxoEiQgpaQbAzYfy(WEiAzbsaLhryQU0)QHYL)RgkZhIQXdGAGwwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFIBjv(PyLYawNvMduV6RCAwNEHC8Oi9uWKsbXzD4y6wNcbfRtfRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhoMU1HBsADjBDQyDpY6KmhgM2yaeyRiatMQltKKp7V5L9byWKoVm5cmFypeTSajGYJimvx6F1q5Y)vdLjpadM05LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96pPkPYpfRugW6SYej5Z(BE5Spjm9yV6vMEFp0b6YKlW8H9q0YcKakpIWuDP)vdLl)xnuM49jHPhZ6gxz616iHoqxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfcLu5NIvkdyDwzoq9QVYsMddtQrpaOVOH3ZaE1lKJhfPNmvBDQyDsMddtXdr14bqnqNmvBDQyDB48PGxqaApeToC06EyzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96xrPKk)uSszaRZkZbQx9vgdDtd5vdVrdua)ef0RxeToIzDHnEVNxdwNkwxaHYyOhiEPWgUYej5Z(BE58MAFLmPXRm5cmFypeTSajGYJimvx6F1q5Y)vdLj(n1ADZmPXRSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)kjkPYpfRugW6SYCG6vFLLmhgM8byWKoFYuT1PI1LM1LM1PxihpkspfmPuqCwhXs36sqW6s26WjoTojZHHjFagmPZNOGE9IO1HJwxAwNYeXX6ECRlQgY5xJnEG194wNK5WWKpadM05tXBd4TUKoRtX6s26sUmrs(S)MxEGII3B0afWxMCbMpShIwwGeq5reMQl9VAOC5)QHY4affpRJnqb8wxAkjxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFLhwsLFkwPmG1zL5a1R(kNM1PxihpkspfmPuqCwhXs36sqW6uX6KmhgMGmObXT53buWmozQ26s26uX6sZ6OWafIgRugSUKltKKp7V5LhYRgEJgOa(YKzab8JOuGgexLkpIWuDP)vdLl)xnughYRgSo2afWBDPPKCzIOYILVLkdUx)q6uyGcrJvkdLLdzyJq)jiOGRcHYYHiYKgGyj1Rm5cmFypeTSajGYJiS)QHY96x5XwsLFkwPmG1zL5a1R(klzomm5dWGjD(KP6Yej5Z(BE5bkkEVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1qzCGIIN1XgOaERlTejxMiQSyznkLxilDLYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9RqCkPYpfRugW6SYCG6vFL1lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1rCtsRdN406GKW0RwnGnf1Omgq9czVgWspRtfRdsctVA1a20zaVyqa8PaA8vkJqyVQ3WzDQyD6fYXJI0tbtkfeN1rmRdxcwNkw3TzqCt7Wb0ObkGFceRugWSovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LwIKllhYWgH(tqqbxfcLLdrKjnaXsQxzYmGa(rukqdIRsLhry)vdL71VsswsLFkwPmG1zL5a1R(klzommrHisSIa8EOd0tuqVEr06WrRtHqzIK8z)nV8Hoq)Q34b05LjxG5d7HOLfibuEeHP6s)Rgkx(VAOmj0bARBCJhqNxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfClPYpfRugW6SYCG6vFLLmhgMuJEaqFrdVNb8QxihpkspzQ26uX62W5tbVGa0EiAD4O19WYej5Z(BE5SxMXj8czVsO8vMCbMpShIwwGeq5reMQl9VAOC5)QHYeVxMXj8czw3mu(SU0usUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)ke3sQ8tXkLbSoRmhOE1x5nC(uWliaThIwhXSofRtfRBdNpf8ccq7HO1rmRtPmrs(S)MxoySEXB2lZ4eEHSYKlW8H9q0YcKakpIWuDP)vdLl)xnuMmJ1lSoI3lZ4eEHSYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9RKuLu5NIvkdyDwzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFwxAjsUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jiusLFkwPmG1zL5a1R(ktHbkenwPmuMijF2FZlpKxn8gnqb8LjZac4hrPaniUoR8ikLxiRFLYJimvx6F1q5Y)vdLXH8QbRJnqb8wxAjsUmruzXYAukVqw6kpg3sLb3RFiDkmqHOXkLHYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9NqPKk)uSszaRZktKKp7V5LHLEgVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1q5Nl9mSo2afWBDP9WKltevwSSgLYlKLUsz5qg2i0Fcck4QqOSCiImPbiws9ktUaZh2drllqcO8ic7VAOCV(tKOKk)uSszaRZktKKp7V5LhYRgEJgOa(YKzab8JOuGgexNvEeLYlK1Vs5reMQl9VAOC5)QHY4qE1G1XgOaERlThMCzIOYIL1OuEHS0vklhYWgH(tqqbxfcLLdrKjnaXsQxzYfy(WEiAzbsaLhry)vdL71RCsdmSM5RZ61c]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20171125.213329, [[deKhkaqijL0MGGgfukNIi0QKuqZssH6wskKDrIgMs5ye1YOu9miqttsvUMKsSnjLY3GqJtsr5CsQuRtsrmpjv19Gs1(KurhKszHKupur1eLuKUOIYgLuHtsentIGBsj7uHFkPOAPqXtrMkeTvsWEf)fsnyu5WuTyO6XkzYs5YQ2mj5ZkYOLKtt41ePzlXTj1Ub9Bugoj0XHawofpxQMoW1vQ2oK8DjLQZdLSEjfy(sQK9JQoYbzOHRFisONZZnRC9HaVut45SvZNfIwgHIGqHQPxLVxarDimVCV)mSVjJOSSCDRuwwEdbThcZ9gwif6hQXakvvC9r3RylPknx7cyVgHT2X3vPsPQIRp6EfBjvzB34abdwd3uIGsmKTfqWG9Gmd5Gm0mOJxElQdzdxueaSc1bmJw6VI3essytSCaZecYGpKfRPGBgU(HcnC9draMrl9xXBcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqg2dYqZGoE5TOoKnCrraWkK3xh2C46HKe2elhWmHGm4dzXAk4MHRFOqdx)q26RdBoC9qyE5E)zyFtgr5TqyENTBwVhKbeAE1xsTyOU(qqWdzXAdx)qbKbcgKHMbD8YBrDiB4IIaGvOIab2fn0AFs7ObmW1HKe2elhWmHGm4dzXAk4MHRFOqdx)qsqGa7IgpNLpPDEoKmW1HW8Y9(ZW(MmIYBHW8oB3SEpidi08QVKAXqD9HGGhYI1gU(HciJ6fKHMbD8YBrDiAzekccHnEoFbeOo6dVw8opx955Qhphc550(lDGHPvU2nMdb8C1j255SVXZjrEoeYZHnEoZvzEVYXlNNtIHSHlkcawHuvC9r3RylPHMx9LulgQRpee8qwSMcUz46hk0W1puDuC955Ok2sAiBMPEiGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqg1sqgAg0XlVf1HSHlkcawHUBaviWUl9HKe2elhWmHGm4dzXAk4MHRFOqdx)qZCdOcb2DPpeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazuBbzOzqhV8wuhIwgHIGqngqPQIRp6EfBjvP5Axa78C1jp3Y7a0aH(8CiKNdFxLkLfhLJUVBMUYDf55qipxTYZb8YHaLfXufakGtOnSMYdD8YB8CiKNZxabQJ(WRfVZZvFEU6fYgUOiayfQ4OC047MoiKKWMy5aMjeKbFilwtb3mC9dfA46hscokNNt9UPdcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqgigKHMbD8YBrDiAzekccvR8CaVCiqzrmvbGc4eAdRP8qhV8gphc558fqG6Op8AX78C1NNRw45QR6INd4LdbklIPkauaNqBynLh64L345qipNVacuh9HxlENNR(8C1lKnCrraWk0lxFiWlOXlEhessytSCaZecYGpKfRPGBgU(HcnC9dnRC9HaVWZPU4DqimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYOMfKHMbD8YBrDiB4IIaGvOIJYrJFxhssytSCaZecYGpKfRPGBgU(HcnC9djbhLZZP(UoeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazu3bzOzqhV8wuhIwgHIGqTJVRsLYIyQcafWj0gwtzJv7Wq2WffbaRqRkxarxetvaOaofAE1xsTyOU(qqWdzXAk4MHRFOqdx)qZRCbKNtcIPkauaNczZm1dbCZ0bOfQWE747QuPSiMQaqbCcTH1u2y1omeMxU3Fg23KruEleM3z7M17bzaHKe2elhWmHGm4dzXAdx)qbKH8wqgAg0XlVf1HSHlkcawHwvUaIUiMQaqbCkKKWMy5aMjeKbFilwtb3mC9dfA46hAELlG8CsqmvbGc4eph2KLyimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYqwoidnd64L3I6q2WffbaRqfhLJgF30bHMx9LulgQRpee1HSyOeWPmKdzXAk4MHRFOqdx)qsWr58CQ3nDaph2KLyiBMPEindLaoHD5qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqgY2dYqZGoE5TOoeTmcfbHmxL59khV8q2WffbaRqQkU(O7vSL0qZR(sQfd11hcI6qwmuc4ugYHSynfCZW1puOHRFO6O46ZZrvSLuEoSjlXq2mt9qAgkbCc7Y1yGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqaHif)s4frnWbcgmd71M9asaa]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20171217.142410, [[da04saqiKKAteQgfiPtbs8kqGmlPav3ceO2LuAyiQJrklti9mquMgiQCnPqABsH4BiuJdevDoqaRtkqmpPqDpqK9bcDqeYcLIEisLjkfiDrqQnkfWjjuMjiOBkr7eulLqEkQPIu2ksv7v5ViYGPQdlAXe8yknzP6YQ2mc(mPYOfQttXRrIzlPBtYUH63qgUqCCKKSCIEovMoW1LW2jv9DPGopsQ1lfOmFKe7xWtB0gZrU1Kvtdwcmi8GJ2irhdNQpMnk6cEORxDmiRnibVZG1vFWNo74g0tilQG1CSOxF6(GJswJynTOnABunidYIcbgl6zNAAg1hlVknyheSqbbcTPZECpX232lKjWGWJjYcmiSB0gS2OngACkuFFnhZwPjcyChbAjut1j5IrwkTYRsd2f8qm4fkiqOnD2J7j2(2EHmbgeo4fp4TiuTJAiUTM6tscfshOvEvAWUGhIbp5Gx8GNQdEHcceADaKur5pYLTfrgtKGPAaupoD2J7j2(XIH7gBcqYXye(JlrD6tjCQ(4XWP6JjYzpUNy7hl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWrhTXqJtH67R5y2knraJP6GhySumyDbpvOsW3rGwc1uDsUyKLsR8Q0GDbFJHuWRZ2htKGPAaupMqnvNKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFCdut1dEogzPmw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGHSrBm04uO((AoMTsteWyv(QdirQwBHuEmi4HiKc(OKdEXdE5vPb7c(gdPGxOGaH20zpUNy7B7fYeyq4Gx8G3Iq1oQH420zpUNy7BLxLgSl4HGcEHcceAtN94EITVTxitGbHd(gdPGVxitGbHhtKGPAaupMqnvNKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFCdut1dEogzPe8qvdkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9Xdmyi3OngACkuFFnhZwPjcySqbbcT3gJUJeIajq8jPt(eqYvG7xAW6AlIe8Ih8uDWluqGqB6Sh3tS9TfrgtKGPAaup(PeetvfjLpwmC3ytasogJWFCjQtFkHt1hpgovFm0PeetvfjLpw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGB0rBm04uO((AoMibt1aOE8RxDmiRKeQPdmwmC3ytasogJWFCjQtFkHt1hpgovFm01RogK1GVznDGXIE9P7dokznI1ipw0DOcP9UrBGX0fFlLsK(RogmHXLOoCQ(4bgCJmAJHgNc13xZXSvAIagRYxDajs1AlKYJbbpeHuWRPrCWtfQe8uDWNsGHqAbTUg(A1G1rsLV6asKQ94uO(EWlEWRYxDajs1AlKYJbbpeHuWdbIoMibt1aOE8tjiMKlgzPmwmC3ytasogJWFCjQtFkHt1hpgovFm0Peeh8CmYszSOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbt8OngACkuFFnhtKGPAaup2bqsfL)ixowmC3ytasogJWFCjQtFkHt1hpgovFmdqsfL)ixow0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWGH8J2yOXPq991CmrcMQbq94QHQkmDsQuNkjbqGRglgUBSjajhJr4pUe1PpLWP6JhdNQpgcnuvHPh8LPovg80qGRgl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWqGrBm04uO((AoMTsteWyHcceAJGA4LKqeibIpjv(QdirQ2IibV4bVqbbcToasQO8h5Y2IibV4bFAbg9N0XxzUl4BCWdzJjsWunaQhxn6IbydwhjbufmwmC3ytasogJWFCjQtFkHt1hpgovFmeA0fdWgSUGVjQcgl61NUp4OK1iwJ8yr3HkK27gTbgtx8Tukr6V6yWegxI6WP6JhyWAKhTXqJtH67R5y2knraJ7iqlHAQojxmYsPvEvAWUGhIbVnDasaJ6bV4bpudElcv7OgIjjFAbbpvOsWluqGqB6Sh3tS9TfrcEOmMibt1aOECn1NKekKoWyXWDJnbi5ymc)XLOo9PeovF8y4u9XqyQpd(MfshySOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbRPnAJHgNc13xZXSvAIagd1GxLV6asKQ1wiLhdcEicPGpk5Gx8GxOGaH2xV6yqwjrazlCTfrcEOe8Ih8qn4LNG8U4uO(GhkJjsWunaQhtOMQtYfJSugtx8Tukr6V6yWegxI60Ns4u9XJHt1h3a1u9GNJrwkbpuJcLXej15gdsPUdiziaj5jiVlofQFSOxF6(GJswJynYJfDhQqAVB0gySy4UXMaKCmgH)4suhovF8adwl6OngACkuFFnhZwPjcySkF1bKivRTqkpge8qesbVMMwWtfQe8uDWNsGHqAbTUg(A1G1rsLV6asKQ94uO(EWlEWRYxDajs1AlKYJbbpeHuWd5BKGNkuj4pvvyIe59wNcv7xAW6if)uccEXd(tvfMirEVfeFs9BVr)LoscveQtksAbbV4bVkF1bKivRTqkpge8qm4jMCWlEWdY6XG2Ka4sxmYsP94uO((yIemvdG6XpLGysUyKLYyXWDJnbi5ymc)XLOo9PeovF8y4u9XqNsqCWZXilLGhQAqzSOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbRbzJ2yOXPq991CmBLMiGXcfei0kVdHtS9KaiWvTYRsd2f8no41ih8uHkbpudEHcceAL3HWj2Esae4Qw5vPb7c(gh8qn4fkiqOnD2J7j2(2EHmbgeo4HGcElcv7OgIBtN94EITVvEvAWUGhkbV4bVfHQDudXTPZECpX23kVknyxW34GxRrdEOmMibt1aOEmabUIKkDGlPESy4UXMaKCmgH)4suN(ucNQpEmCQ(yAiWvbFz6axs9yrV(09bhLSgXAKhl6ouH0E3OnWy6IVLsjs)vhdMW4suhovF8adwdYnAJHgNc13xZXSvAIagNwGr)jD8vM7cEig8AbV4bFAbg9N0XxzUl4HyWRnMibt1aOECn1NKeEQglgUBSjajhJr4pUe1PpLWP6JhdNQpgct9zW38PASOxF6(GJswJynYJfDhQqAVB0gymDX3sPeP)QJbtyCjQdNQpEGbR1OJ2yOXPq991CmBLMiGXcfei0gb1WljHiqceFsQ8vhqIuTfrcEXd(0cm6pPJVYCxW34GhYgtKGPAaupUA0fdWgSoscOkySy4UXMaKCmgH)4suN(ucNQpEmCQ(yi0OlgGnyDbFtufe8qvdkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9XdmyTgz0gdnofQVVMJzR0ebmoTaJ(t64Rm3f8qm41cEXd(0cm6pPJVYCxWdXGxBmrcMQbq9yBCAWKQgDXaSbRBSy4UXMaKCmgH)4suN(ucNQpEmCQ(y6Itdo4HqJUya2G1nw0RpDFWrjRrSg5XIUdviT3nAdmMU4BPuI0F1XGjmUe1Ht1hpWG1iE0gdnofQVVMJjsWunaQhxn6IbydwhjbufmwmC3ytasogJWFCjQtFkHt1hpgovFmeA0fdWgSUGVjQccEOgfkJf96t3hCuYAeRrESO7qfs7DJ2aJPl(wkLi9xDmycJlrD4u9Xdmyni)OngACkuFFnhZwPjcyS8eK3fNc1pMibt1aOEmHAQojxmYszmDX3sPeP)QJbR54sKEdw3G1gxI60Ns4u9XJHt1h3a1u9GNJrwkbpuHmOmMiPo3yfsVbRdsAn4GuQ7asgcqsEcY7ItH6hl61NUp4OK1iwJ8yr3HkK27gTbglgUBSjajhJr4pUe1Ht1hpWG1GaJ2yOXPq991CmrcMQbq94NsqmjxmYszmDX3sPeP)QJbR54sKEdw3G1gxI60Ns4u9XJHt1hdDkbXbphJSucEOgfkJjsQZnwH0BW6GK2yrV(09bhLSgXAKhl6ouH0E3OnWyXWDJnbi5ymc)XLOoCQ(4bgCuYJ2yOXPq991CmrcMQbq9yc1uDsUyKLYy6IVLsjs)vhdwZXLi9gSUbRnUe1PpLWP6JhdNQpUbQP6bphJSucEOc5GYyIK6CJvi9gSoiPnw0RpDFWrjRrSg5XIUdviT3nAdmwmC3ytasogJWFCjQdNQpEGbgZwPjcy8aB]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20180205.201220, [[da0)jaqlvvYUuvPmmk5ykYYiPEMqvtdPixJczBKe(MQkvJdPOwhsf3tOI6GkXcvupKqnrKkDrk1gfkFKc1ivvXjrvEjjjZevv3KKu7uWpb0qfYrfQilfPQNcnvuCvsI2Qqf6RcvYyfQG1kuP2R0Gvfhw0IvspgOjdWLPAZu0NjKrJsNMOxJuy2k1TrLDd63igobhxvvlNupxHPRY1rY2PGVRQmEuvopjwpsP9RkDNktrWu4Keymc8Wtz7fbQsg(5fSlcMcNKaJrGhkP1BysDrDcf5IzDqA05IRBjT0A8M811Ikannh(jofojboAWQiFannh(jofojboAWQ4FkNYbWdKarjTEdgzvKtcxSBi(I)PCkhG4u4Ke4OZf5trmbAW1NdOZf)tjbPbEkBVywmor5u(OmnmvMI2WCD7a6CXfWtsGVp8lhxruYj(9XgYMqqNZHhDEFe0oiHBnVIHKZlIsoXVp2q2ec6Co8OZ7JG2bjCR5vKEF75WBqT1KkMSSIVicQLcxXtY5XzREnOUmfTH562b05IlGNKaFF4xoUIOKt87JnKnHGoNdp68(aWntQ9vmKCEruYj(9XgYMqqNZHhDEFa4Mj1(ksVV9C4nO2AsftwwX3RxXbl5d)Khi7IDNloyjFluhPZf5s(qMgMkEPwKFlqqwIU4mqggGQMEEg)dtrfGMMd)wO0zdwfb47ujgbEfJyEFWeoEFcPwt(kYhqtZHFQAE0WurfGMMd)u18OHFPUOcqtZHF013Psdwf5dOP5Wp667uPbRIdwYhtQf53OZfPX6ceKLOlYamIEEg)dtrbTKl1k8ajW4sc4yBWiRI)PCkhapqcmUKao2gmYQ4GL8TqPtEqtsNlcs4wZlYGDxlkOLCPwHhib(JlfXEnyKvra(ovIrGhEkBViqvYWpVGDr66Mj1(6CXKsNlqqwIU4mqggGQMF7ymfLqasW8i6fiilrxKEEg)dtXl1I8lYquxlcMcNKaxGGSeDXzGmmavDXHGV3X25Gvmzt0LPy2WurDdtff1WuX1gM6vefCqzUL0MNKaBqTkIV4GL8HmDU4FkNYPRu7GNKalsppJ)HPiKIJhiboAGMkQk3fwgco4rFEssNlUUL0sRXBY3YE31Ikannh(XdcqcMhrpAWQ4GL8jofojbo6Cr(aAAo8BHsNnyvmP0jJIGxCLY0SiFannh(XdcqcMhrpAWQiaFNklqqwIUidWi(TJXuKl5BH6inyvm3cS5Y(lvgrgSByQyUfytKL8fzWUHPI5wGnft4wZlYGDdtfdjNx0gYMqqNZH37tKwYLALI)PCkhapqc8hxkI9AWiRI5(lvgrgI6CrASgJaVIrmVpychVpHuRjFfbtHtsGlBPiyrX2bgB6l(NscsJ4OCGNY2lMff0sUuRWdKarjTEdgzvuNqroJIGxmxLB5PumP0PQLqVZf)t5u(ceKLOlsppJ)HPinwJrGhkP1BysDXClWMIjCR5fziQHPIrAjxQvEFeNcNKaFFwO0zr8iAUvTekY1fhSKp667uPiJDCGPO23ffBhySPV4LAr(fJaVIrmVpychVpHuRjFfZTaBYKAr(fzWUHPI0yngbE4PS9Iavjd)8c2f)t5uoaEqasW8i6rNlQ0WVupzvKVg(fnRU4LAr(fJap8u2ErGQKHFEb7IQo5tYrX9(Wi58gI3Q4FkNYXtz7fPNNX)Wueb1sHRyXClWMl7VuzeziQHPI)PCkFzlfb5C4veSOGwYLALye4HsA9gMuxuq7GeU18wI4Vik5e)(ydztiOZ5WJoVpcAhKWTMxr69TNdVb1wt)ULkuR(3upPwfwgvKl5BXUbRIm52H37JXAcLqdwfVulYVid2DT4GL8PkxzvcbiHIgDU4GL8fziQZfb4Mj1(wI4Vik5e)(ydztiOZ5WJoVpaCZKAFfhSKVid2DUOb5qUk3YtHrrWlUwmsl5sTY7J4u4KeyXHopjP4qW37y7CW21IdwYhpiajyEe9OZfbihc7uHrrWlMfZ9xQmImy35ICs4c1rAWQ4GL8Ty35IGeU18Ime11I8b00C4htQf53ObRI5wGnzsTi)Ime1WuXClWMil5lYqudtf5KqKPbRIxQf5xmc8qjTEdtQl(NYP8fiilrd00C4xdgvemfojbgJaVIrmVpychVpHuRjFftkDIc(EZJUnO2AIMPjJkAdZ1TdOZfhsoHTVa0UH4lYFooXeObxpKeydQTMOzRPjA63IVOcqtZHFmPwKFJgSkoyjF4N8azxOosNlMu6Kh0KWOi4fxPmnlcW3Psmc8qjTEdtQlkbjquibLqrnyurtc8kUOL5(9jKAn5RyCtiCIjqdU(CaDUOeKaJBcHRH4Tk(NYPCaXiWdL06nmPUOyIGY7ddPOnKnHGoNdV3hucfT9FXKAr(v8pLt5au18OZfhSKp8tEGSlaT7CXKsNQekVIc7uX19Ab]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20180205.201220, [[dau1jaqlHk1UeQYWeYXuflJq9mkKPjuvxtvsBdPKVrIiJJebRdPs3tOcDqr1cb0djKjIuXfPuBuO8rkuJuvItIkEjjkZevQBsIQDk4Namur5OKiQLIu1tHMkkUkjsBLeH(QqLmwHkyTcv0ELgSs1HvSyk5XanzvLlt1MPOptcJgLonrVgPuZwj3gvTBq)gXWj44iflNupxKPRY1rY2PGVRQA8OsopjTEvP2Vs5(uMIGJWjjWye4HN6YlcqPmCZjyxeCeojbgJapu(2B4rCr9av4IyDqAxGfPHYP88LubK3HxrWIQamnt(jAeojbMAiQinuoL)XbKaFXLkyVgmkQOGwYpAvoGeikF7ne)OI8syUDdgvKgkNY)encNKatfyrUufrGgC95FfyrvaMMj)ygTc)snevujt5uEQmn8uMI2WXA5FfyXCWtsGB7CltxruYlAB3gYoqqN3HhD32f0oiH3AUIHH3lIsErB72q2bc68o8O72UG2bj8wZvKEF5tYBqC0ZRr0kEIf)ueb1sHR4j594yuVgexMI2WXA5FfyXCWtsGB7CltxruYlAB3gYoqqN3HhD32)CZHADfddVxeL8I22THSde05D4r3T9p3COwxr69LpjVbXrpVgrR4jw8tVEftSKF8xEGS521QyIL8NtDKAvmXs(XF5bYMtDKcS4nAf(Ldbzj6IabWWaq50ZX4xykQ2qC)qRxlYvdXTsqCrvaMMj)OJVg1gIkYfatZKF0XxJAdrftSKFMrRWVubwK2w5qqwIUidGm65y8lmf5cGPzYVCk90quXpFnQXiWdLV9gEexCwcSt(6FutzgSB4PinuoL)PmGPcSOGwYpAvoGe4lUub71Grrf5cGPzYpLbm1qurAOCk)JdibgxYVJTHxJkou6jhcYs0fbcGHbGY52ogtrqcV1CzgSRvrABfJaVIzmB74atB7HrRj)fbhHtsG5qqwIUiqammauErAOCk)JdibIY3EdXpQik4GYzjFpNKaBqmTmQyIL8JmfyXpFnQXiWRygZ2ooW02Ey0AYFrifphqcm1q8lEJwHFzgYQvXel5pZqwbwmj4RvS1KyfrweDzkon8u0QHNIkA4POUHNEftSKFrJWjjWubwuzUlKNeCWJ(5KKcS4NBouRlpJ7IOKx02UnKDGGoVdp6UT)5Md16kMPL8JwDBx0iCscSyspNKuKF4czAiQi)Wvo1rAiQO1s((TXlYF(AvRIZsGDqwYFMb7gEkolb2reH3AUmd2n8uKoU5qTUcSyy49I2q2bc68o822ZbyxCw)JAkZqwbw0GmjTKl5PYOk4fTkcocNKaZxsfWIISdm20x8tMewJkJQGxeSOjbEfZ1YzTThgTM8x8ZxJAoeKLOlYaiJB7ymfhk9OCj0lWI0q5uEoeKLOlsphJFHPiTTIrGhkF7n8iUO2xffzhySPV4SeyhMrRWVmdzn8uCO0dhOjHrvWlArzAwmXs(PJVg1Im2XbMIjbFTITMeBTkolb2Hz0k8lZGDdpfNLa7iIWBnxMHSgEksBRye4HN6YlcqPmCZjyxCwcSdYs(ZmK1WtrjibIcdOeQOHxlEJwHFXiWdp1LxeGsz4MtWUOYhUK8u8B7msEVbJIksdLt54PU8I0ZX4xykIGAPWvmjHkwEXzjWo5R)rnLziRHNIwl573gVi)1QOGwYpA1ye4HY3EdpIlkODqcV1C5zCxeL8I22THSde05D4r3TDbTds4TMROiIG62odPOnKDGGoVdVT9Ca2f5hUYTBiQiZSC4TTBSMqj0quXB0k8lZGDTkQcW0m5NYaMAiQi9(YNK3G4OhLueTeloEIFetROxlEJwHFXiWRygZ2ooW02Ey0AYFXmTKF0QB7IgHtsGB75u6PiEenVLwcv46ICbW0m5hh4NeCoIo1quXel5p3UwfPHscsBLOmHN6YlAvmXs(5a)KGZr0PcSinuoL)Xb(jbNJOtfyXz9pQPmd2fyXHspmQcErlktZIjwYFMb7cSiiH3AUmdz1QOkatZKF5u6PHOIQamnt(Xb(jbNJOtnevmXs(vMRAjHFsOIubwKxcrMgmQ4nAf(fJapu(2B4rCrAOCkphcYs0amnt(1WRfbhHtsGXiWRygZ2ooW02Ey0AYFXHspOGVwCOtdrfTHJ1Y)kWIjjVWYZby3Grf5EsNic0GRtscSbXrpkHONN4hpXfLGeyCsi8nyuurUayAM8t0iCscm1quXel5pNspCGMKAvKlaMMj)ygTc)snevupqfoJQGxCSKl5PwKxcZPosdgvmojeEreObxF(xbw8ZxJAmc8WtD5fbOugU5eSlsdLt5FXiWdLV9gEexuc)KGZr05qqwIUi9Cm(fMIcAj)Ov5asGXL87yB41OI0q5uoDKAh8Keyr65y8lmfhk9OuO8kkSgvx3Rf]] )

    storeDefault( [[Elemental Primary]], 'displays', 20180205.200440, [[daeYjaqlvvv7sjrnmfCmfAzKONHqmnKQCnvvzBkj13uvvACkjP1PKe3tjbDqLyHkLhsLAIkPCrsAJujFKsQrQKQtIuEjLeZuvLBsjPDsv)ecdLkoQsc1srOEkyQi6Qiv1wvsiFvjrgRscSwvvf7vAWQIdlAXQspgjtgIUSWMPuFMegnHonrVgH0Sj1Tjy3O63qnCuCCey5u8CfnDvUoK2oL47QkJhPY5rP1JG2Vs1DSKfOsMtI5UW8dowDuab9j)rZRw4sJI4CS403cMKRiClgueTBfianqJfTubxi4xbQcSiSTNX5ozojMpRFOabObAGKgfMVEiviE1)3qbcqd0ajnkmhKeg1tVHctr83cQjPXTX9TabObAG0DYCsmF2Tc0X6gZTeMlq2TcSiSTNXrMgfXnRFOWkgnqJzjRFSKfu55Roq2TcluNeZ3F(jNxbq93(JQoec(L69hhtqHfEZRGpfIcG6V9hvDie8l17poMGcl8MxbIdDKZOELdJRECyGifakJK5kCsHyfo0RELLSGkpF1bYUvyH6Ky((Zp58kaQ)2Fu1HqWVuV)SwyNO6RGpfIcG6V9hvDie8l17pRf2jQ(kqCOJCg1RCyC1JddePaqzKmxHE9kmfXFWN8Oexu7wb6qyBpJJmnkIBw)qHPi(d(KhL4c6H7wHe1K042yswMOWlQTDHuZiMGi(ZXIt9JfyR))khhkqx9)FvvwGfHT9mU1cDYw)qb6qyBpJBTqNS1puykI)itJI4MDRarFx4uIytbseoetZ61jlqhcB7zClOMS(HcidDY6cZpqsyu)OYceGgObsRSn7wbwe22Z4SY2S()pwGXifsdlnkmF9qQq8Q)VHccs(c6HRFOqIAYfoLi2uydbjjcR(t1fzbcqd0ajnkmFLKipX6)BOGKJusLh2SWPeXMcetZ61jl8QLesO1A8xFlqLmNeZx4uIytHneKKiSAbhJuinS7pUtMtI5fU0OiUzbGjOKPwsyEsmVELRwzHPi(di7wbKHozDH5xbhY9hi5Z9hFAm4VcCubAuy(SE6vGkzojM7cZpqsyu)OYctr8NJfNUvyYeATlDofDJ1ytjlK1pwWu)ybf1pw4T(XEfMI4p3jZjX8z3kyLiywMmb1rCEsC3kGmStu9T48RaifCV)OQdHGFPEv2Fqg2jQ(kqCOJCg1RCy8Fhhv(3kRuj9iYWQl4tHOGQoec(L69hhJuinSfes6wqpC9dfE1scj0An(BrR7BHuZiMGi(ZXIA9JfsnJy6gl8MNJf16hlSwyNO6RBfSX8RWIrM69hFAm4VcP(lzNowC6wblYP8vQLhljltuilqLmNeZx0sf8cUv9KQexGaujfrxrYjCS6OqwGoe22Z4SY2S(XcidDYUWPeXMcKiC(P6ISqIAsRk5r3kqaAGglCkrSPaX0SEDYce91fMFGKWO(rLfmHUGBvpPkXfsnJysMgfX5yXP(XcPMrmDJfEZZXIt9JfMI4V1cDYwGuDfqwyYeATlDof7BHuZiMKPrrCowuRFSWLgfXTWPeXMcBiijryvIPz96KfianqdK04iLu5HnZUvykI)wqpC3kqHfEZZXIAFlCPrrCUW8dowDuab9j)rZRwWQjDsbuH9hsPquprgkqaAGgWXQJcetZ61jlaugjZvOqQzeZf9xYoDS4u)yb3yg29hsCbvDie8l17pliulWyKcPH1fMFGKWO(rLfymbfw4nVfNFfaPG79hvDie8l1RY(dJjOWcV5vGOVUW8dowDuab9j)rZRwqiPBrT(HcKPo43(J1gmkt9dfU0OiohlQ9TGKcZbMKsYvu)FfMI4pReSVsosjxXSBfU0Oioxy(vWHC)bs(C)XNgd(RarFDH5xbhY9hi5Z9hFAm4Vctr8NJf1UvWXifsd7(J7K5Ky((ZcQjluqsH5)dgluprgkmfXF04iLu5HnZUvqiPdiRFSqQ)s2PJf1Uvirnjjltu4f12UWue)TO2TcuyH38CS403c0HW2EghnosjvEyZS(HcSiSTNXTGAY6hkWIW2EghnosjvEyZS(Hccsoqw)qHlnkIZfMFGKWO(rLfianqJfoLi2GW2Egx9)vGkzojM7cZVcoK7pqYN7p(0yWFfsutcmHwtBT6hkOYZxDGSBfMsbgDSGqTELf(LZZnMBjmtjMxVYHXvDyCKERSYc0HW2EgN7K5Ky(S(HcmgPqAyPrH5GKWOE6nuqqYxuRNifmjxrqYYefYxPwESfsnJyUO)s2PJf16hlGuoz0jljltuil8pySGBm3syUaz3kGm0jRlm)GJvhfqqFYF08QfianqdKUW8dKeg1pQSabObASM0euNeZlqmnRxNSaJrkKgwAuy(kjrEI1)3qHPi(d(KhL4cc1Uvirnj95YRaJozdtVwa]] )

    storeDefault( [[Elemental AOE]], 'displays', 20180205.200440, [[daKLjaqlPs0UGuYWOQoMszzKONrKAAsL01qQQTHuLVbbQXbbSoiqUhKs1bLQwOQYdLkMie0fPsBKk8rQOgPuPojs5LejntiPBsfXoP4NkvdvkDuiLYsrQ8uWur0vjsSvQiPVsfPglvKyTsLWEfdwv6WkwSu8yKmzi6Ys2mv5ZeXOjQtt41qkMnLUnjTBu9BOgokooeA5K65kz6QCDe2oj8DvvJhs15rP1dj2VQ4SfYaudZjWChy(bhRTcSlfsuPzCdqnmNaZDG5hiqPIztza9WLuDKlk0KVanwbkO4Sf)NMaS7EER66mmNaZxX4ha9DpVvDDgMtG5Ry8dWOfQJMLgfMdcuQy6QFavbV3ngLbqKOikKDgMtG5R8faD2oyUIsFfY8fGD3ZBvh5OLu3kg)aOnIIOwHmMTqgWLpn2cz(c0tDcm)5fvX6Ibbcyg1ka4I6ZRRTul(n2N3wDrHvBMlaDLTMvfJs)n6T57lDaGslyUaNqTq7(5Irzid4YNgBHmFb6PobM)8IQyDXqVaMrTcaUO(86Al1IFJ95fHL3qyVa0v2Awvmk93O3MVV0O1waGslyUa5YfyjJ)HFXrj37MMaOV75TQJC0sQBfJFa1bDGmg)a3OLuxpNsgRd8TtsU7e6O5C3KbqF3ZBvNu)wX4hGD3ZBvNu)wX4hGD3ZBvhcl7WgJFa0398w1HWYoSX4hyjJ)jhTK6w5laAA65uYyDaY9w6O5C3Kby398w11tONy8dGSSdRdm)abkvmBkdiOWCGzOeCjXq)amAH6OzPrH5oTa5jhd99dWOfQJMLgfM3DjKiFXiTFGLm(h(fhLCpXHZxakSAZCTkCttaKLDyDG5hCS2kWUuirLMXnGGJuqnhw3ZPKX6a0rZ5UjdOk49ehogLbOgMtG59CkzSoW3oj5UtcGirruiuOlQtG5bOJMZDtgaykkXyfOmNaZJrj9ugyjJ)bY8fazzhwhy(fOL85fg(651mAn(paNqLgfMVIPRbeuyExGXQXiTFaPwft)IPOo6MtGZxa2DpVvD04ifuZH1Ry8dSKX)DgMtG5R8fa9DpVvD9e6jg)adHEizzQaneEEbqKOikK0OW8UlHe5lgP9dOqSencR4yjzzQanbuh07joCm(bqF3ZBvhnosb1Cy9kg)aJLrEaz8FRc3y2cmwg5PdwTzUwfUXSfaHL3qyV8fWmQvaxBPw8BSpV97Ubg7)WUAv0MVaOPXbMFbAjFEHHVEEnJwJ)dqnmNaZ7Tcj8aDCnKU0farcbfACQIfCS2kqtGB0sQRvrBAcGSSdBpNsgRdqU3IQRdYadHECIGx5laIefr1ZPKX6a0rZ5UjdGMghy(bcuQy2ugyjJ)ryzh2aKUofYaTAH6OzFE7mmNaZFE7j0tah2rTEEbzmfAcGMghy(bhRTcSlfsuPzCdOlBGoUgsx6cCJwsDoW8lql5Zlm81ZRz0A8FGXYipKJwsDTkCJzlWyzKNoy1M5Av0gZwaejkIcjnosb1Cy9kFbqKOiQERqcxT4xaQaSX0LB0J(bUrlPohy(bhRTcSlfsuPzCd4KbDHkH6ZlPqTIrA)aisuefCS2kaD0CUBYaaLwWCbwcUeBfySmYtV9FyxTkAJzlWqOhACpmjltfOHWZlaJwOoAwhy(bcuQy2ugGrxuy1M56Brnaiu7886Al1IFJfb98YOlkSAZCbwmL16Wol50eqDqV3ng)aKJT43ZRZAmbtm(bUrlPUwfUPjWsg)l1ITrWrk4sw5lqRwOoA2N3odZjW8a65e4alz8FRI28fyXuwRd7SK7GTyDidmXSfqhZwajXSfOjMTCbAScuqXzl(V3AttGLm(V3nnbglJ80B)h2vRc3y2cSKX)04ifuZH1R8faz5ne2RVf1aGqTZZRRTul(nwe0ZlYYBiSxGX(pSRwfU5lasXIXoSKSmvaQalz8FRc38fGcR2mxRI20ea9y6seqzGXYipKJwsDTkAJzlaDLTMvfJs)ne8MYnPrlLs7VPebcOk4azmkdCJwsDoW8deOuXSPmaIefr1ZPKX6DpVvDXq)audZjWChy(fOL85fg(651mAn(pWqOhGPSwAimg)aU8PXwiZxGLqLXw97UXiDauN11bZvu6LaZJrP)gc4VT1v0s6aisuefsAuyoiqPIPR(bwY4)Ec9qJ7HttGLm(VN4WPjGE4skswMkW0iSIJnGhMFb61IX(8AgTg)harIIOqsJcZDAbYtog67hOlWy1oyUIsFfY8fySmYdiJ)Bv0gZwaejkIcPdm)abkvmBkdme6PNtjJ1b(2jj3DcQUoidGirruiL63kFb6GzyFEjXbCTLAXVX(82V7gyi0Ju4IlaJDylDUe]] )


end
