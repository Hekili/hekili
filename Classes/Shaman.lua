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


        --[[  Need to cannibalize this into recheck system.
        
        function class.setupIterationSteps( times )            

            if state.spec.elemental then
                if state.buff.resonance_totem.up then
                    local remains = state.buff.resonance_totem.remains

                    if remains > 0         then tinsert( times, remains ) end           -- APL checks for Resonance Totem expiry.
                    if remains - 2.01 > 0  then tinsert( times, remains - 2.01 ) end    -- APL checks for Resonance Totem < 2 sec.
                    if remains - 10.01 > 0 then tinsert( times, remains - 10.01 ) end   -- APL checks for Resonance Totem < 10 sec.
                end

                if state.debuff.flame_shock.up then
                    local remains = state.debuff.flame_shock.remains

                    -- APL checks for Flame Shock debuff down.
                    if remains > 0 then
                        tinsert( times, remains )
                    end 

                    -- APL checks for Flame Shock debuff is refreshable.
                    remains = remains - ( state.debuff.flame_shock.duration * 0.3 ) - 0.01
                    if remains > 0 then
                        tinsert( times, remains )
                    end
                end

            elseif state.spec.enhancement then
                if state.buff.alpha_wolf.up then
                    local remains = state.buff.alpha_wolf.remains

                    -- AW is down.
                    if remains > 0 then tinsert( times, remains ) end

                    -- AW < 2 sec.
                    if remains - 2.01 > 0 then tinsert( times, remains - 2.01 ) end
                end

                if state.feral_spirit.up then
                    local remains = state.feral_spirit.remains

                    -- FS are up.
                    if remains > 0 then tinsert( times, remains ) end

                    -- FS < 5 sec.
                    if remains - 5.01 > 0 then tinsert( times, remains - 5.01 ) end

                    -- FS < 4 sec.
                    if remains - 4.01 > 0 then tinsert( times, remains - 4.01 ) end
                end

                if state.buff.flametongue.up then
                    local remains = state.buff.flametongue.remains

                    -- FT is down.
                    if remains > 0 then tinsert( times, remains ) end

                    -- FT expires in GCD + 6 sec.
                    if remains - ( 6.01 + state.gcd ) > 0 then tinsert( times, remains - ( 6.01 + state.gcd ) ) end

                    -- FT reaches pandemic range.
                    if remains - 4.81 > 0 then tinsert( times, remains - 4.81 ) end
                end

                if state.talent.hailstorm.enabled and state.buff.frostbrand.up then
                    local remains = state.buff.frostbrand.remains

                    -- FB is down.
                    if remains > 0 then tinsert( times, remains ) end

                    -- FB expires in GCD + 6 sec.
                    if remains - ( 6.01 + state.gcd ) > 0 then tinsert( times, remains - ( 6.01 + state.gcd ) ) end

                    -- FT reaches pandemic range.
                    if remains - 4.81 > 0 then tinsert( times, remains - 4.81 ) end
                end

                if state.buff.doom_winds.up then
                    local remains = state.buff.doom_winds.remains

                    -- DW is down.
                    if remains > 0 then tinsert( times, remains ) end

                    -- DW expires in 2 GCDs.
                    if remains - 0.01 - ( state.gcd * 2 ) > 0 then tinsert( times, remains - 0.01 - ( state.gcd * 2 ) ) end
                end
            end

            tsort( times )

            return times

        end ]]


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

        ns.addToggle( 'hold_t20_stacks', false, 'Save Crash Lightning Stacks', "(Enhancement)  If checked, the addon will |cFFFF0000STOP|r recommending Crash Lightning when you have the specified number of Crashing Lightning stacks (or more).  " ..
            "This only applies when you have the tier 20 four-piece set bonus.  This may help to save stacks for a big burst of AOE instead of refreshing the tier 20 two-piece bonus." )

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
            cast =0,
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

            spend( cost, 'maelstrom' ) -- * ( talent.aftershock.enabled and 0.7 or 1 ), 'maelstrom' )
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20171128.173505, [[dm0gyaqijQwKaPnjGgfHCkcAwcuTlsmmqCmqAzIQEgIKMMOcxtaABis8nfPXjq5CkIyDcG5jq09iG9Hi1bffluIYdrPMOabxuk6KIkntfrDtuYojPFQisdvrOwQu4PunvjYvfi0wreFvri2l0FvudwOdtzXi8yfMmOUSQnlOplLA0s40KA1kcjVwkz2O62sA3a)MOHJOoUOIwospxQMUsxhfBNq9DfbNxuA9kcPMpbA)ImcflHEq4HgdFXYq3j)H246jAB1saQMNuiv0BC(T(r18qGofsWYhmfObdcPcjhO7dQM8Io6zgRwc6yjufkwc9MaJGFySm0ZqO56nl6tqdGN7f3OONlawpSvsrhibhDwsysmQQvp6ORA1J(erdGtrV4gf9gNFRFunpeOtHcb9gVlzOJ3Xs4Io7IpAXsk(1dwKaDwsyvRE0XfvZJLqVjWi4hgldDFq1Kx0fLIIsX14hSkfMM3xjTQCGrWpCkgykwEksWegQesL9LGAayfgYPOWuuqbtXYtX14hSkfMM3xjTQCGrWpCkke9meAUEZIUyJQnc(rNDXhTyjf)6blsGoljmjgv1Qh9ctZ7RKwzx8rl0vT6r3xj9PijgN5ONH2UJoWQxGctZ7RKwzx8rRGl24mxarIwJFWQuyAEFL0QYbgb)WbwobtyOsiv2xcQbGvyiluqblFn(bRsHP59vsRkhye8dle9gNFRFunpeOtHcb9gVlzOJ3Xs4IEUay9WwjfDGeC0zjHvT6rhxuLuXsO3eye8dJLHUpOAYl6IsXYtX14hSkHm0SZYWzttvoWi4hoffuWuuukUg)GvjKHMDwgoBAQYbgb)WPyGPy1oVVuzvzWqPhSPiPtXGbjffMIcrpdHMR3SOl2OAJGF0zx8rlwsXVEWIeOZsctIrvT6rpKHMLDXhTcge0vT6r3xj9PijgN5POiOcrpdTDhDGvVaHm0SSl(OvWGeCXgN5ciQ814hSkHm0SZYWzttvoWi4hwqbfTg)GvjKHMDwgoBAQYbgb)WbwTZ7lvwjDWGiui6no)w)OAEiqNcfc6nExYqhVJLWf9CbW6HTsk6aj4OZscRA1JoUOAoWsO3eye8dJLHUpOAYl6IsXYtX14hSkHm0SZYWzttvoWi4hoffuWuuukUg)GvjKHMDwgoBAQYbgb)WPyGPy1oVVuzvzWqPhSPiPtXPqsrHPOq0ZqO56nl6InQ2i4hD2fF0ILu8RhSib6SKWKyuvRE0dzOzzx8rRPqqx1QhDFL0NIKyCMNIIYle9m02D0bw9ceYqZYU4JwtHeCXgN5ciQ814hSkHm0SZYWzttvoWi4hwqbfTg)GvjKHMDwgoBAQYbgb)WbwTZ7lvwj9uicfIEJZV1pQMhc0PqHGEJ3Lm0X7yjCrpxaSEyRKIoqco6SKWQw9OJlQgqSe6nbgb)WyzO7dQM8IUOuS8uCn(bRsidn7SmC20uLdmc(HtrbfmffLIRXpyvczOzNLHZMMQCGrWpCkgykwTZ7lvwvgmu6bBks6umhbmffMIcrpdHMR3SOl2OAJGF0zx8rlwsXVEWIeOZsctIrvT6rpKHMLDXhTYrarx1QhDFL0NIKyCMNIIivHONH2UJoWQxGqgAw2fF0khbm4InoZfqu5RXpyvczOzNLHZMMQCGrWpSGckAn(bRsidn7SmC20uLdmc(HdSAN3xQSs6CeqHcrVX536hvZdb6uOqqVX7sg64DSeUONlawpSvsrhibhDwsyvRE0XfvjfSe6nbgb)WyzO7dQM8IUOuS8uCn(bRsidn7SmC20uLdmc(HtrbfmffLIRXpyvczOzNLHZMMQCGrWpCkgykwTZ7lvwvgmu6bBks6umFatrHPOq0ZqO56nl6InQ2i4hD2fF0ILu8RhSib6SKWKyuvRE0dzOzzx8rR8beDvRE09vsFksIXzEkkkhcrpdTDhDGvVaHm0SSl(Ov(agCXgN5ciQ814hSkHm0SZYWzttvoWi4hwqbfTg)GvjKHMDwgoBAQYbgb)WbwTZ7lvwjD(akui6no)w)OAEiqNcfc6nExYqhVJLWf9CbW6HTsk6aj4OZscRA1JoUO6uSe6nbgb)WyzO7dQM8IUOuS8uCn(bRIu8PJcJ2(khye8dNIckykkkfxJFWQifF6OWOTVYbgb)WPyGPy1oVVuzvzWqPhSPiPtXPqsrHPOq0ZqO56nl6InQ2i4hD2fF0ILu8RhSib6SKWKyuvRE0Nu2tSuYNcbDvRE09vsFksIXzEkkkGcrpdTDhDGvVatk7jwk5tHeCXgN5ciQ814hSksXNokmA7RCGrWpSGckAn(bRIu8PJcJ2(khye8dhy1oVVuzL0tHiui6no)w)OAEiqNcfc6nExYqhVJLWf9CbW6HTsk6aj4OZscRA1JoUOAWWsO3eye8dJLHUpOAYl6IsXYtX14hSksXNokmA7RCGrWpCkkOGPOOuCn(bRIu8PJcJ2(khye8dNIbMIv78(sLvLbdLEWMIKofjfiPOWuui6zi0C9MfDXgvBe8Jo7IpAXsk(1dwKaDwsysmQQvp6tk7jwk5Kce0vT6r3xj9PijgN5POisri6zOT7OdS6fyszpXsjNuGeCXgN5ciQ814hSksXNokmA7RCGrWpSGckAn(bRIu8PJcJ2(khye8dhy1oVVuzL0KceHcrVX536hvZdb6uOqqVX7sg64DSeUONlawpSvsrhibhDwsyvRE0XfvNeSe6nbgb)WyzO7dQM8IUOu85KrtM8Hv6vjh(unO9CXn6MIcrpdHMR3SOl2OAJGF0zx8rlwsXVEWIeOZsctIrvT6rV4gDBMtgnzYhgDvRE09vsFksIXzEkkAQq0ZqB3rhy1lqXn62mNmAYKpCWfBCMlGONtgnzYhwbAaHgmOtIq0BC(T(r18qGofke0B8UKHoEhlHl65cG1dBLu0bsWrNLew1QhDCrvOqWsO3eye8dJLHUpOAYl6IsXNtgnzYhwXAzAatF2i6soZ(5jkM(QhpffIEgcnxVzrxSr1gb)OZU4JwSKIF9GfjqNLeMeJQA1JU1Y0aMM5KrtM8Hrx1QhDFL0NIKyCMNIIcMq0ZqB3rhy1lG1Y0aMM5KrtM8HdUyJZCbe9CYOjt(Wkqj1PqcwoeIEJZV1pQMhc0PqHGEJ3Lm0X7yjCrpxaSEyRKIoqco6SKWQw9OJlQcfkwc9MaJGFySm09bvtErxukk2OAJGFfRLPbmnZjJMm5dNIbMIemHHkfYDUWaWkmKtXatXYtrcMWqLqQSVeudaRWqoffIEgcnxVzrxSr1gb)OZU4JwSKIF9GfjqNLeMeJQA1JU1Y0aMmo6Qw9O7RK(uKeJZ8uu0Kie9m02D0bw9cyTmnGjJhCXgN5cisSr1gb)kwltdyAMtgnzYhoqcMWqLc5oxyayf6TXgy5emHHkHuzFjOgawHHSq0BC(T(r18qGofke0B8UKHoEhlHl65cG1dBLu0bsWrNLew1QhDCrvO5XsO3eye8dJLHUpOAYl6IsXYtrcMWqfUUDXc0G2ZdQ1luyiNIbMI9VZesatxz1NMhYCEYJuK0PiKuui6zi0C9MfDXgvBe8Jo7IpAXsk(1dwKaDwsysmQQvp6tw3UybAqB2uRxOk3Giz0vT6r3xj9PijgN5POiOqeIEgA7o6aREbMSUDXc0G2SPwVqvUbrYbxSXzUaIkNGjmuHRBxSanO98GA9cfgYb2)otibmDLvFAEiZ5jpeIEJZV1pQMhc0PqHGEJ3Lm0X7yjCrpxaSEyRKIoqco6SKWQw9OJlQcLuXsO3eye8dJLHUpOAYl6IsrrPibtyOIXjxyZtqYdvOVAAqpfdYumFkgyksWegQyCYf28eK8qf6RMg0tXGmfZNIbMIemHHkgNCHnpbjpuH(QPb9umitX8POWumWum8uJp3jRP6vH(QPb9uK0PyosrHONHqZ1Bw0fBuTrWp6Sl(OflP4xpyrc0zjHjXOQw9OBCYf2erYdzx8rl0vT6r3xj9PijgN5POiOqfIEgA7o6aREbmo5cBIi5HSl(OvWfBCMlGirK)QesL9DEcsEOcbtyOIXjxyZtqYdvOVAAqpiZhi5VkH6tZopbjpuHGjmuX4KlS5ji5Hk0xnnOhK5dK8xfUUDXc0G2ZtqYdviycdvmo5cBEcsEOc9vtd6bzEHbgEQXN7K1u9QqF10GoPZHq0BC(T(r18qGofke0B8UKHoEhlHl65cG1dBLu0bsWrNLew1QhDCrvO5alHEtGrWpmwg6zi0C9MfDM(N17RD0ZfaRh2kPOdKGJoljmjgv1QhD0vT6rpi2FkM7(Ah9gNFRFunpeOtHcb9gVlzOJ3Xs4Io7IpAXsk(1dwKaDwsyvRE0XfvHgqSe6nbgb)WyzONHqZ1Bw0hgNpBJvlbZCDFrpxaSEyRKIoqco6SKWKyuvRE0rx1QhD2gNNIzgRwcsXjR7l6zOT7OdS6fiOUUYofBckmW41d2aKIsYhCAqrVX536hvZdb6uOqqVX7sg64DSeUOZU4JwSKIF9GfjqNLew1QhDxxzNInbfgy86bBasrj5dofxufkPGLqVjWi4hgldDFq1Kx0jycdvS(4aydmUcdz0ZqO56nl6dJZNTXQLGzUUVOZU4JwSKIF9GfjqNLeMeJQA1Jo6Qw9OZ248umZy1sqkozDFtrrqfIEgA7o6aREbcQRRStXMGcdmE9GnaPO1hbf9gNFRFunpeOtHcb9gVlzOJ3Xs4IEUay9WwjfDGeC0zjHvT6r31v2PytqHbgVEWgGu06dCrvOtXsO3eye8dJLHEgcnxVzrFyC(SnwTemZ19f9CbW6HTsk6aj4OZsctIrvT6rhDvRE0zBCEkMzSAjifNSUVPOO8crpdTDhDGvVab11v2PytqHbgVEWgGuKGjmShu0BC(T(r18qGofke0B8UKHoEhlHl6Sl(OflP4xpyrc0zjHvT6r31v2PytqHbgVEWgGuKGjmSJlQcnyyj0Bcmc(HXYqpdHMR3SOpmoF2gRwcM56(IEUay9WwjfDGeC0zjHjXOQw9OJUQvp6SnopfZmwTeKItw33uuePke9m02D0bw9ceuxxzNInbfgy86bBasr2bHEqrVX536hvZdb6uOqqVX7sg64DSeUOZU4JwSKIF9GfjqNLew1QhDxxzNInbfgy86bBasr2bHoUOk0jblHEtGrWpmwg6zi0C9Mf9HX5Z2y1sWmx3x0ZfaRh2kPOdKGJoljmjgv1QhD0vT6rNTX5PyMXQLGuCY6(MIIYHq0ZqB3rhy1lqqDDLDk2euyGXRhSbifhs6dk6no)w)OAEiqNcfc6nExYqhVJLWfD2fF0ILu8RhSib6SKWQw9O76k7uSjOWaJxpydqkoK0JlQMhcwc9MaJGFySm0ZqO56nl6dJZNTXQLGzUUVONlawpSvsrhibhDwsysmQQvp6ORA1JoBJZtXmJvlbP4K19nfffqHONH2UJoWQxGG66k7uSjOWaJxpydqkgQ58tdk6no)w)OAEiqNcfc6nExYqhVJLWfD2fF0ILu8RhSib6SKWQw9O76k7uSjOWaJxpydqkgQ58tXfx0vT6r31v2PytqHbgVEWgGue(HgdFXfra]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20171128.173505, [[deZQbaGEKO2LOQ2MOkZeHy2cDtb9nQWoP0Ej7wP9tvmmu53GgkcPbtvA4OOdsLCmu1cPsTueSykSCu6HIkpv1JLYZr0ercMQatwQMUKlsf9mKkxNQQTIu1MrOA7ifltuMgsOXrv5YqVgP0OPOBlYjrsoSItdCEKuFgf(lcL1HezXRaDkGeF8hl5w)mXgyIakpfaUYMLhD6eWioKOSzC8o48L5lFEFC0Xrr93ybmlDDxTcaxsfilVc0DUJre7YTUldqeuuRZewa4Qt12bTPGS6lCr9qyN(H1ojux3ojuNOWcaxDcyehsu2moEh8C6eqsOF2gsQav65mXgTHqAWeULm0dHD7KqDvYMPaDN7yeXUCR7Yaebf16radZAbldIrAcWyxNQTdAtbz1x4I6HWo9dRDsOUUDsOorammRfSm849Mam21jGrCirzZ44DWZPtajH(zBiPcuPNZeB0gcPbt4wYqpe2Ttc1vPs3oju)GuopEDUMZ2WeUfL84Ljl2GjJPujba]] )

    storeDefault( [[SimC Enhancement: core]], 'actionLists', 20171128.173505, [[d4ttmaGEKeQnjPYUqQ2gva7djLzIK0YOIMTunFQq3usomLBROVHuStLAVIDdSFLmkjLggi(njNxfCAedwHHtQCqIWPKu1XKIJJKOwisPLsKwmOwoHhsQ6POEmv9CjMOKczQeLjRstxvxuf6QijONre11LsBejHSvIkBMkz7QO1jPq9vQa9zq67ijYHKuW4OcA0KYRrItsu10iICnjfDpKuDzO)sL6CijWPjYcxJqxwB)dTH32edZKP(14iqZaECIGVgVgELadlf7OvWSDcPHgio0PdP34qisgIKcZ6qpX6eQy7jkq2oDajhwc)tuGsKLDtKf(iWG74n0gM9cIUp8PjigChP7QvCqVg6P4SMHLaM0j)HWOjEne4UOJqbdlp4s82ReHbkagUsDLZeBBIHdVTjg(OjEneSgSocfmSuSJwbZ2jKgAAGewkwuTcpwIS8H1RHEkvQtCIGpWHRu3TnXW5Z2zKf(iWG74n0gM9cIUpCnSgWTUCr3lSIM7obQ2diaO0B1Tg1TgM)jNOBeGtcwwdQr91WzyjGjDYFiSxyfn3DcuThqaqdlp4s82ReHbkagUsDLZeBBIHdVTjgwVWkARbvjq1EabanSuSJwbZ2jKgAAGewkwuTcpwIS8H1RHEkvQtCIGpWHRu3TnXW5ZwYrw4JadUJ3qByjGjDYFimvIaUffaAy5bxI3ELimqbWWvQRCMyBtmC4TnXWoibClka0WsXoAfmBNqAOPbsyPyr1k8yjYYhwVg6PuPoXjc(ahUsD32edNpBjfzHpcm4oEdTHzVGO7dB(NCIUraojyznOg1xdhUgo64Au7Ay(NCIUraojyznOg1xdhynQBnERJGNUxyfncaQ7YRet6iWG74DnQpSeWKo5pe2lSIM7obQ2diaOHLhCjE7vIWafadxPUYzITnXWH32edRxyfT1GQeOApGaGUg12uFyPyhTcMTtin00ajSuSOAfESez5dRxd9uQuN4ebFGdxPUBBIHZNDnJSWhbgChVH2Wsat6K)qyQebClVGqbdlp4s82ReHbkagUsDLZeBBIHdVTjg2bjGB5fekyyPyhTcMTtin00ajSuSOAfESez5dRxd9uQuN4ebFGdxPUBBIHZNTdezHpcm4oEdTHzVGO7dd36Yf9YRetybbaff0B1Tg1TgNMGyWDKURwXb9AONIZAgwcysN8hcxELywEbHcgwEWL4TxjcduamCL6kNj22edhEBtmm)kXS8ccfmSuSJwbZ2jKgAAGewkwuTcpwIS8H1RHEkvQtCIGpWHRu3TnXW5ZMMil8rGb3XBOnm7feDFyZ)Kt0ncWjblRb1O(AiP1WrhxJAxdZ)Kt0ncWjblRb1O(A4CnQBnERJGNUxyfncaQ7YRet6iWG74DnQpSeWKo5pe2lSIM7obQ2diaOHLhCjE7vIWafadxPUYzITnXWH32edRxyfT1GQeOApGaGUg16S(WsXoAfmBNqAOPbsyPyr1k8yjYYhwVg6PuPoXjc(ahUsD32edNpBhgzHpcm4oEdTHzVGO7dd36YfDxkHhDRC5(1q3tvl4ncGERUWsat6K)qyHYtbM8OiS8GlXBVsegOay4k1votSTjgo82MyyPkpfyYJIWsXoAfmBNqAOPbsyPyr1k8yjYYhwVg6PuPoXjc(ahUsD32edNpBQGil8rGb3XBOnm7feDF436i4PRorHxZeqr6iWG74DnQBnonbXG7iDxTId61qpfjvZ1OU1yAyV8c1KUVviqWVguJ6RHKGewcysN8hc3jq1Eaba1nSQ)HLhCjE7vIWafadxPUYzITnXWH32edtvcuThqaqxdAv9pSuSJwbZ2jKgAAGewkwuTcpwIS8H1RHEkvQtCIGpWHRu3TnXW5ZUbsKf(iWG74n0gM9cIUpCTRrnSgV1rWtxDIcVMjGI0rGb3X7Au3ACAcIb3r6UAfh0RHEksQMRr9RHJoUg1UgV1rWtxDIcVMjGI0rGb3X7Au3ACAcIb3r6UAfh0RHEkoeYAuFyjGjDYFiC5vIz5fekyy5bxI3ELimqbWWvQRCMyBtmC4TnXW8ReZYliuW1O2M6dlf7OvWSDcPHMgiHLIfvRWJLilFy9AONsL6eNi4dC4k1DBtmC(SBAISWhbgChVH2WSxq09HpnbXG7iDJIraTsWHLaM0j)HWUeQYdlmWnS8GlXBVsegOay4k1votSTjgo82MyyQiHQ8WcdCdlf7OvWSDcPHMgiHLIfvRWJLilFy9AONsL6eNi4dC4k1DBtmC(SBCgzHpcm4oEdTHzVGO7dd36YfDn17wZax6T6wJ6wJAxJAxJttqm4os3Oyeq7rQClrNo8Ug1TgWTUCr3LqvEyHbU0B1Tg1Vgo64AudRXPjigChPBumcO9ivULOthExJ6dlbmPt(dH72P5UBfTWYdUeV9kryGcGHRux5mX2My4WBBIHPQDARbvTIwyPyhTcMTtin00ajSuSOAfESez5dRxd9uQuN4ebFGdxPUBBIHZNDJKJSWhbgChVH2WSxq09Hn)tor3iaNeSSguJ6RHKdlbmPt(dHlTGlkiaOHLhCjE7vIWafadxPUYzITnXWH32edZTGlkiaOHLID0ky2oH0qtdKWsXIQv4XsKLpSEn0tPsDIte8boCL6UTjgoF2nskYcFeyWD8gAdZEbr3h28p5eDJaCsWYAqnQVgsEnC0X140eedUJ0PkbQ2diaO6fwrBREQqDRHJoUgNMGyWDKU11PzoOQ7sVg6PewcysN8hc7fwrZDNav7bea0WYdUeV9kryGcGHRux5mX2My4WBBIH1lSI2AqvcuThqaqxJALC9HLID0ky2oH0qtdKWsXIQv4XsKLpSEn0tPsDIte8boCL6UTjgoF(WSxq09HZNaa]] )

    storeDefault( [[SimC Enhancement: opener]], 'actionLists', 20171128.173505, [[b4vmErLxtruzMfwDSrNxc51uofwBL51utLwBd5hyf5gAH52yL1wzUrNo(b2BWvMBLjNxtjvzSvwyZvMxojdmXCdm4idoUedoWmdm041utbxzJLwySLMEHrxAV5MxojJnZ41ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnvBHvgBZrNCV1MlJvNCYvMB05hy84hyXuJFGzIFGrxATvMFGXJFGD2yK51ubjwASLgD551uY92yRjwA0vMCEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51us92yRjwA0vMCEnLuLXwzHnxzE5KmWeZnXaJxtjvzZ9wDYnwzZ5fvErNxtneALn2An9MDL1wzUrNxI51un9gzofwBL51uErNx051utnMCPbhDEnLx05Lx]] )

    storeDefault( [[SimC Enhancement: CDs]], 'actionLists', 20171128.173505, [[d4tIgaGEefAtiQyxe12qcTpvLSmjXVHmBPmFe5MkLld(MQIZJq2PQSxXUvz)umksjggPACik40egQQsPbtPHRuDivLkNIushtjDoefTqeQLsKwmsTCsEOQQEkQhtvRtsLmrjvmvIyYuz6qDrKOpJe8meLCDLyJik1wjf2msA7iW8qu1xLuPMgIk9DsPgPQsv3wQgTK0HvCssrVws5AsQ6EQkf)vvLNlXbrqN1ijCDaQZsdhIdZELyhhoSuObtbYRI(6hDYuFvELmqUFQqMH5DWlMMGmoyb6YRcfjRWe6Xc0vIK8wJKWuEdDdCHom7vIDCy8OOaGLRctdxvE3JnwYBSvQ3yjrYyXIoySFzS6Y1RRhMqArtGjkCvqHeLEynpNWpyKk8Hoi8gYPXOEthch(nDi83dkKO0dlfAWuG8QOV(zvpSuOGwuEOejbh(FvWxBdra0Hdh6WBi3B6q4GZRsKeMYBOBGlehM9kXoom9cvQYtXdNBopiVSBSKizSAXy9iuZH0(KDiu)N2IZvKx2nwTASKizSnGaOzSK3yx11dtiTOjWefMgufqvtCuiSMNt4hmsf(qheEd50yuVPdHd)MoeMyqvavnXrHWsHgmfiVk6RFw1dlfkOfLhkrsWH)xf812qeaD4WHo8gY9Moeo48iRijmL3q3axiom7vIDCy6fQuLNIho3CEqEz3yjrYy1IXsfut7xzxOeyzf0hXvm2Vm26nwTASKizSnGaOzSK3yx11dtiTOjWefMUHqUFuxuefwZZj8dgPcFOdcVHCAmQ30HWHFthctCdHCglzVOikSuObtbYRI(6Nv9WsHcAr5HsKeC4)vbFTnebqhoCOdVHCVPdHdopYnsct5n0nWfIdZELyhhMEHkv5P4HZnNhKx2nwsKm2VZyXtdoS8u8W5MZdYWn0nWzSKJXsfut7xzxOeyzf0hXvm2Vm26nwsKmw8OOaGLXIo8dJ(5eGXs(VXyPOEycPfnbMOW7iSaDH18Cc)GrQWh6GWBiNgJ6nDiC430HWFlclqxyPqdMcKxf91pR6HLcf0IYdLij4W)Rc(ABicGoC4qhEd5EthchCE1hjHP8g6g4cXHjKw0eyIctfut7xzxOe4WAEoHFWiv4dDq4nKtJr9Moeo8B6qyYgutZy5DHsGdlfAWuG8QOV(zvpSuOGwuEOejbh(FvWxBdra0Hdh6WBi3B6q4GZJIrsykVHUbUqCy2Re74WEeQ5qAFYtXdNBopiRG(iUIX(LXsrJLejJfpn4WY0OLMduuffSmCdDdCgljsgRdOxOsvggfUkC)k7IAG8YEycPfnbMOWoeQ)tBX5kH18Cc)GrQWh6GWBiNgJ6nDiC430HW1bH6gBDloxjSuObtbYRI(6Nv9WsHcAr5HsKeC4)vbFTnebqhoCOdVHCVPdHdoVprsykVHUbUqCy2Re74WAXy9iuZH0(KlyKQxWkrnqwb9rCfJ9lJv3y1QXsogl9cvQYtXdNBopi7qAFHjKw0eyIcpfpCU58qynpNWpyKk8Hoi8gYPXOEthch(nDimHfpCU58qyPqdMcKxf91pR6HLcf0IYdLij4W)Rc(ABicGoC4qhEd5EthchCWHFthcZI(FJLYR6CEOdhUUm2)1PeCc]] )

    storeDefault( [[SimC Enhancement: filler]], 'actionLists', 20171128.173505, [[d4d9iaGEfGAteIDPO2gru7tPOzQGyzKkZwI5du6MkYHP62u6BkL2PQAVIDdA)s6NeOmmkACkfopq1qvqAWsz4aXbjcNcO4yk05iqvlKqAPe0IvLLJ4HKspf1JvYZLQjsGktLqnzatxLlsaNMKldDDkSrfqBLi1MjQ2or5zajnnfuFMu18asSofa9AsXOvQ(nsNKi5VkqxJiY9iqoKcqoUcaJci1zmIdl4q5Ur5IOH)UfdZkR2Ata4UdxOfH3aS2KRkfKewiwqVJ5RZCCR5g62yECdtq1C4Wmi4s5f1a2pffMVojdQHLyDkkShX5pgXHfa6VccerdZlIcKlS1Xs)iu78YGqq4vBGsTnQZmSepvrDGhMqxAEQdjHLccOw(rjHHuigEIciTt(Ufdh(7wmSq6sZtDijSqSGEhZxN542rZWcXo1GSWEeNlS2DCPzIkdTi8Yl8ef47wmCU81fXHfa6VccerdZlIcKl8ZqU8z5f3IhfQ3aNjO1vWETbk12WZBewINQOoWdlV4w8Oq9gyyPGaQLFusyifIHNOas7KVBXWH)UfdpWIBXJc1BGHfIf07y(6mh3oAgwi2PgKf2J4CH1UJlntuzOfHxEHNOaF3IHZLpOgXHfa6VccerdZlIcKlmORTZli8MxeVVRG6hSFuIDgH(RGa1gybBT5RtjdheHOvH9ABtbvB6QnWuBIuBa4ZqU8z0j3ochSdIsdoBasTjsTzDS0pc1oVmieeE12McQ2g2S2eP2K5eL)k4SGPDOuArYMHL4PkQd8WlI33hSO0VFqfuFyPGaQLFusyifIHNOas7KVBXWH)UfdRL499ABik97hub1hwiwqVJ5RZCC7OzyHyNAqwypIZfw7oU0mrLHweE5fEIc8Dlgox(dhXHfa6VccerdZlIcKl85feEZ7UQ0pkXoJq)vqGAtKA7zix(SCcTFpIdbMjO1vWETbk12WZBuBIuBwhl9JqTZldcbHxTTzTnSzyjEQI6apSCcTFpIdbclfeqT8JscdPqm8efqAN8Dlgo83Ty4bsO97rCiqyHyb9oMVoZXTJMHfIDQbzH9ioxyT74sZevgAr4Lx4jkW3Ty4C5lPioSaq)vqGiAyEruGCHL5eL)k4SRXvqdbgagkqabbQnrQTbuT9mKlFwoH2VhXHaZgGuBIuBwhl9JqTZldcbHxTTPGQTTskSepvrDGhwoH2VhXHaHLccOw(rjHHuigEIciTt(Ufdh(7wm8aj0(9ioeO2a9iyclelO3X81zoUD0mSqStnilShX5cRDhxAMOYqlcV8cprb(UfdNlFjhXHfa6VccerdlXtvuh4H7gqaKOG6dlfeqT8JscdPqm8efqAN8Dlgo83Tyy2acGefuFyHyb9oMVoZXTJMHfIDQbzH9ioxyT74sZevgAr4Lx4jkW3Ty4C5VnIdla0FfeiIgMxefixyRJL(rO25LbHGWR22uq1MKmRnrQnzor5VcolyAhkLw2AwBIuBYCIYFfCwUbbCT74sZgMHL4PkQd8WfxMpyX77HLccOw(rjHHuigEIciTt(Ufdh(7wm8qCzETneVVhwiwqVJ5RZCC7OzyHyNAqwypIZfw7oU0mrLHweE5fEIc8Dlgox(BeXHfa6VccerdlXtvuh4Hj0LMN6qsyPGaQLFusyifIHNOas7KVBXWH)UfdlKU08uhsQnqpcMWcXc6DmFDMJBhndle7udYc7rCUWA3XLMjQm0IWlVWtuGVBXW5YxWhXHfa6VccerdZlIcKlmORnRJL(rO25LbHGWR22uq1MKLuTbwWwBNxq4nViEFxb1py)Oe7mc9xbbQnWc2AZxNsgoicrRc712McQ20vBGP2eP2K5eL)k4SGPDOuArYM1Mi1MmNO8xbNLBqax7oU0mSKclXtvuh4HxeVVpyrPF)GkO(Wsbbul)OKWqkedprbK2jF3IHd)DlgwlX7712qu63pOcQV2a9iyclelO3X81zoUD0mSqStnilShX5cRDhxAMOYqlcV8cprb(UfdNl)rZioSaq)vqGiAyjEQI6apS8IBXJc1BGHLccOw(rjHHuigEIciTt(Ufdh(7wm8alUfpkuVbwBGEemHfIf07y(6mh3oAgwi2PgKf2J4CH1UJlntuzOfHxEHNOaF3IHZLlmVikqUW5sa]] )

    storeDefault( [[SimC Enhancement: buffs]], 'actionLists', 20171128.173505, [[dWJNgaGEijAtev2ffTncI9bjvZKuvz2u5MkPLbP(ge63G2PQAVs7gy)cgfbKHbrJJa0Pj5VeudMQgoPYbHeNIa4ykvNJuv1cjKwkHAXQYYH6HkfRIuv8yfwhKeMiPQ0ujIjtPPRYfjeVcskpJaQRtHnQe1wjvzZKY2HGptKoSOPbjP5rG62cDzKrtuoebPtsu13vICncKZRu61kHNRONI6UxjL1xslnCxfTmpWkDx5YIjhLtQF0i3rePaIw)nrJeTakibvM1rdv6uOY8uqq)OfIaxgLXPGGzL0)ELuweq(CKTIwMhyLUR8LocCMUeyNoLLmjq(CKn4Ll4fAW)m00mDjWoDklzAORmkpLtDBlJHJfp1r4YYdSQrEqCzaeqLxHw9s8pJu5Y)msLfdhlEQJWLftokNu)OrUJ4oYYIPj0apOzL0R8gz0yXkebksGRVYRq7pJu5E9JUsklciFoYwrlZdSs3vwOb)PgluaPbVCbFmj38WWO5WaJjWf8OEWJgDzuEkN62wwZaVvyOMWPcxwEGvnYdIldGaQ8k0QxI)zKkx(NrQ8Yg4Tbpul4rrHllMCuoP(rJChXDKLfttObEqZkPx5nYOXIvicuKaxFLxH2FgPY96xGRKYIaYNJSv0Y8aR0DLt8P0YXzMoDYsHxc60mXjyrWJ6bpYGxUGxhMqqyPdR5UPgHtNWtDkS6kJYt5u32YdCoLjStjv2buaPLLhyvJ8G4YaiGkVcT6L4FgPYL)zKkVbNtzbV(PKk7akG0YIjhLtQF0i3rChzzX0eAGh0Ss6vEJmASyfIafjW1x5vO9NrQCV(r1kPSiG85iBfTmpWkDxzHg8pdnntnxgPdcKAqMg6kJYt5u32YAUmshei1GklpWQg5bXLbqavEfA1lX)msLl)ZivEzxgPdcKAqLftokNu)OrUJ4oYYIPj0apOzL0R8gz0yXkebksGRVYRq7pJu5E9lOkPSiG85iBfTmpWkDx5lDe4mLLk38G4OjbYNJSbVCbVqd(NHMMPggoVhobwtdDbVCbpcjwLphzQzG3UrgnwGQcQmkpLtDBlRHHZ7HtGTS8aRAKhexgabu5vOvVe)ZivU8pJu5LXW59WjWwwm5OCs9Jg5oI7illMMqd8GMvsVYBKrJfRqeOibU(kVcT)msL71VqQKYIaYNJSv0Y8aR0DLFgAAMAUmshei1GmXumvGzWl4GxibpQf8sh2GxUGFaHolCjGPfcJcVKcyNMykMkWm4fCWlDydE9j4rxgLNYPUTL1CzKoiqQbvwEGvnYdIldGaQ8k0QxI)zKkx(NrQ8YUmshei1GcEbAxaklMCuoP(rJChXDKLfttObEqZkPx5nYOXIvicuKaxFLxH2FgPY96hXkPSiG85iBfTmpWkDx5lDe4mLLk38G4OjbYNJSbVCb)ZqtZuddN3dNaRjMIPcmdEbh8cj4rTGx6Wg8Yf8di0zHlbmTqyu4Lua70etXubMbVGdEPdBWRpbp6YO8uo1TTSggoVhob2YYdSQrEqCzaeqLxHw9s8pJu5Y)msLxgdN3dNaBWlq7cqzXKJYj1pAK7iUJSSyAcnWdAwj9kVrgnwScrGIe46R8k0(ZivUxVY)msLzvCtWlcqwcguKahQi4FgAAZETa]] )

    storeDefault( [[SimC Enhancement: asc]], 'actionLists', 20171128.173505, [[datxcaGEkPAxisVwcZgHBsPUTGDsv7LSBO2VOyyOY4GunyrLHJIoOOQJHQwOq1sHOflKLlYdfLEQQhlPNtXefkMQenzQmDfxKsCzW1rP2kkyZqO2oKYYGKVkuAAus67OqFdcoSuJgLSokjojIQNHOCAKopI4Vqi)wPTrjLfVk1JbqCZMyuCDFha9tdzZKZcMvJRqaWJvYKRnvDKab0gqEuC8iWHok0jLhDoY4SQ(RjkZrxpFDOl2Os55vPUfChraofxpFeLGoKOdDAybyezyslaDYXoATNnPJxmOBVog6KVdGUUVdGULonSaCMCNjTa0rceqBa5rXXJapNosWSStvWOsn6zzb1c7fnia4rr62RZ3bqxJ8OuPUfChraofx)1eL5Ox3LWTmIj1mBkyMeTaiLnt98ruc6qIUB3aIyKIDgDYXoATNnPJxmOBVog6KVdGUUVdGEm7gYKlwk2z0rceqBa5rXXJapNosWSStvWOsn6zzb1c7fnia4rr62RZ3bqxJ8KPsDl4oIaCkUE(ikbDirNrk2zMeTa0jh7O1E2KoEXGU96yOt(oa66(oa6XsXoZKOfGosGaAdipkoEe450rcMLDQcgvQrpllOwyVObbapks3ED(oa6A0OFMqL2euR3dDXYJYAKPrca]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20171129.171639, [[dmutmaqiPOArqsTjiHAuqsCkirTlO0WaLJjLwgP4zsrzAqc5AsrSnsf13GcJduv15Ge06avzEKkY9KI0(Ge5GKsles5HKQMiOQIlsqBKubgjOQKtcvzLGQsntijDtjANG8tibgkOQslfIEkYuHkxfuvyReOVcQkAVI)kbdgOdt1Ij0JL0KLQlRAZqv9zqLrlfonQEnKQzt0Tjz3k(nkdhkA5u8CknDLUoe2ob8Dsf68sO1tQGMpPs7hWPn4cb)C8DeYnOfcYvpeXv6bafkV6Z6s4ba2p(oc5gc5L3TpqAG1IrBRMMGvtBZAMguyiQA4yUHcPTUC2ydUa1gCHeoUO89igIQgoMBO1nW9fBJ7YTbwmRlaOobaQPjaG6Qla4YvhaeLaaHHTjWGfsRixY3IHACdJBvHWB68QVmtOHnpujRlOBGC1dfcYvpe81nmUvfc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqAcUqchxu(EqlevnCm3qvgt2z64GfFU5fU8QpRlXAUY5JfaeLaa1a)HbaQRUaGRBG7l2LREHLvOZpaOo1uaqDgwiTICjFlgct2Yzti8MoV6lZeAyZdvY6c6gix9qHGC1db)YwoBcH8Y72hinWAXOfwiK3YqyQ3gCzdPVXROxYe4QpBedvY6qU6HYgOMfCHeoUO89GwiTICjFlgsh5tVGTXDti8MoV6lZeAyZdvY6c6gix9qHGC1dbFYNoai14UjeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqrbxiHJlkFpOfIQgoMBire4JpwZTSXN6lSS9kSMRC(yba1jaqnH0kYL8TyOLTxvq529MIHWB68QVmtOHnpujRlOBGC1dfcYvpeo2EfayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqnj4cjCCr57bTqAf5s(wme(CZlC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q6aU5aGcLx9zDziKxE3(aPbwlgTWcH8wgct92GlBi9nEf9sMax9zJyOswhYvpu2aPZbxiHJlkFpOfsRixY3IHSlZOkC5vFwxgcVPZR(YmHg28qLSUGUbYvpuiix9q0YmkaqHYR(SUmeYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGWi4cjCCr57bTqAf5s(wm0Lx9zDzbLB3BkgcVPZR(YmHg28qLSUGUbYvpuiix9qcLx9zDjayPB3Bkgc5L3TpqAG1IrlSqiVLHWuVn4YgsFJxrVKjWvF2igQK1HC1dLnqW)GlKWXfLVh0cPvKl5BXqiSVaFVYgcVPZR(YmHg28qLSUGUbYvpuiix9qWh2daI3ELneYlVBFG0aRfJwyHqEldHPEBWLnK(gVIEjtGR(SrmujRd5QhkBGqHbxiHJlkFpOfIQgoMBOMdaUU8ZI1T1pDFQh7hxu(oaOU6cakIaF8X626NUp1JfbMaG6QlayLXKDMooyDB9t3N6XAUY5JfaeLaaBcSqAf5s(wmKOKX6fWhHPyi8MoV6lZeAyZdvY6c6gix9qHGC1dHMKX6aG6aeMIHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzdulSGlKWXfLVh0crvdhZnuZbaxx(zX626NUp1J9JlkFhauxDbafrGp(yDB9t3N6XIaZqAf5s(wmK4n2BqNpWfcVPZR(YmHg28qLSUGUbYvpuiix9qODJ9g05dCHqE5D7dKgyTy0cleYBzim1BdUSH034v0lzcC1NnIHkzDix9qzduBBWfs44IY3dAHOQHJ5gYRlxGx4Zv8BbarjaqnH0kYL8TyidIPGxxoBki52nK(gVIEjtGR(SrmujRlOBGC1dfcYvpesedaO26YzdaiQYTBiTg4SHgx9MIAIR0dakuE1N1LWdaulkqiQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baQffimBGA1eCHeoUO89GwiQA4yUHwx(zX626NUp1J9JlkFhauxDbabGVrfaWMdaUU8ZI1T1pDFQh7hxu(oaikgaS5aGRl)SyLC4ASdFGRGH1X(XfLVdaIIbaBoa46YplwE94JWue7hxu(oaikhsRixY3IHmiMcED5SPGKB3q6B8k6LmbU6ZgXqLSUGUbYvpuiix9qirmaGARlNnaGOk3UaGOslkhsRboBOXvVPOM4k9aGcLx9zDj8aaT8bo5baDBf1HqE5D7dKgyTy0cleYBzim1BdUSHWB68QVmtOHnpujRd5QhI4k9aGcLx9zDj8aaT8bo5baDBnBGABwWfs44IY3dAHOQHJ5gAD5NflVE8rykI9JlkFpKwrUKVfdzqmf86Yztbj3UH034v0lzcC1NnIHkzDbDdKREOqqU6HqIyaa1wxoBaarvUDbarfnOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhaKJpQdH8Y72hinWAXOfwiK3YqyQ3gCzdH305vFzMqdBEOswhYvpeXv6bafkV6Z6s4baA5dCYdaYXpBGArrbxiHJlkFpOfIQgoMBO1LFwSsoCn2HpWvWW6y)4IY3dPvKl5BXqgetbVUC2uqYTBi9nEf9sMax9zJyOswxq3a5QhkeKREiKigaqT1LZgaquLBxaquPzOCiTg4SHgx9MIAIR0dakuE1N1LWda0Yh4KhauAqDiKxE3(aPbwlgTWcH8wgct92GlBi8MoV6lZeAyZdvY6qU6HiUspaOq5vFwxcpaqlFGtEaqPjB2qeMVYDjxh6lNnbsJoRjBca]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20171125.213329, [[d4socaGEQIAxIQ61qvZwQUjrDBc7KI9I2nj7xvLHjs)wLHskPbdjgou5GuLoMuohvHwivLLQQSyISCQ8qrLNcEmeRJQGjskLPsQMmuMUWffrxw56uvTviLntkvBhs1ZvLdlz0QQAzIYjHKEMOkNMsNNu8nr4VKsSnQImBuNG2M2l)9G(iykXiawrUFOKSpXur19WpuW5gYjKQGW36REJMS0wIwR5X8BTwAEzeaeNfxqGGxKWEQh1PPrDcjvLuFy0hbVs2Un0qa3f2travfMfPIZrqDQrq(WqRCMsmcemLye06f2tr4B9vVrtwAlrlLW3ENFhYEuNbHC)hcE5d9jMkOeb5dZuIrGbnzuNqsvj1hg9rWRKTBdneIlMqlI6fZPHaQkmlsfNJG6uJG8HHw5mLyeiykXiOFXe)qrUEXCAi8T(Q3OjlTLOLs4BVZVdzpQZGqU)dbV8H(etfuIG8HzkXiWGM8OoHKQsQpm6JGxjB3gAi8IZjWVHBocOQWSivCocQtncYhgALZuIrGGPeJaeNtGFd3Ce(wF1B0KL2s0sj8T353HSh1zqi3)HGx(qFIPckrq(WmLyeyWGaGBi2QB9Cf2trtMNYyqc]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20171125.213329, [[deeksaqikPQnrPQrrj6uuswfLukVIskvZIskXTOKISlvYWqIJrkltr5zQOyAQOextfLABuQOVbLACusHZrPcRJskP5bfL7PIQ9ru4GqHfQO6HiPMiLuuxekzJusLtsuAMuQ0nfv7eQwkr1trnvKQTsjSxP)QidwOdR0IjYJPQjRWLbBwL6ZIYOjvNMWRrkZMk3MIDJ43qgUkYXHIQLtYZfz6Q66QW2Pu(ouKZJKSEvusZNOO9l4Qv6LXxduMfgQdrSCGbi)6SwdXKGK5Gq0PkZEL40xUmFc8I1joR7lqKIpZoNvwo4GnbfFgfnS100SJlnnnkNzwz5WoOIUWaLhO)62TgykPJ80UuGzfKK1KLdq64((62TgykPJ80UghQ9fiI1gLRZyvzm8VarsLEX1k9Yyrwjhm68YSxjo9LT(q8fEAcswiktzgId0FD7wdmL0rEAxkWScskeXSZdXm)OmgscN4PQ8TBnWush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYwNBnqiY6ipTYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(SsVmwKvYbJoVm7vItFzPJ77lWRJG0e6E61HPmfS)u6GmaLGKDDCkeTpeT(qu64((AtEGmwIhUoovgdjHt8uvgw1RJ5hlnOSSKHWVpsvMGiq5C0WIvHVgOCz81aLXAvVoMFS0GYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9l(zk9Yyrwjhm68YyijCINQYGdma5x3KKBtFzzjdHFFKQmbrGY5OHfRcFnq5Y4RbkJLdma5xxio3TPVSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IFwk9Yyrwjhm68YSxjo9Lnl4sVczU8hkfq(qugNhIAAyhIYuMHO1hIR6f3R)VsycCobjBYSGl9kK5ciRKdgHO9HOzbx6viZL)qPaYhIY48q0oMvgdjHt8uvgw1RpL0rEALLLme(9rQYeebkNJgwSk81aLlJVgOmwR61drwh5Pvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXp7sVmwKvYbJoVmgscN4PQC6rkdnaobQYYsgc)(ivzcIaLZrdlwf(AGYLXxduMFKYqdGtGQSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IBNLEzSiRKdgDEzmKeoXtvzNaZpeJjZMz2Ph9GPSSKHWVpsvMGiq5C0WIvHVgOCz81aLTRaZpeJqmFZmBish9GPSCWbBck(mkAyRrPSCiHouEiv69ltTo4PLJSbgG8vQCoAGVgOC)IJDPxglYk5GrNxM9kXPV8a9x3U1atjDKN2LcmRGKcrzeI(n9tVWaHO9HOhHCdeMitky9FzmKeoXtvz3ABNKouPVSSKHWVpsvMGiq5C0WIvHVgOCz81aLT7ABdX5hQ0xwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFXTgLEzSiRKdgDEz2ReN(YwgIMfCPxHmx(dLciFikJZdXzucr7drPJ77lWbgG8RB6g5psxhNcrRcr7drldrfCRGK(k5Gq0QYyijCINQY3U1atjDKNwzQ1bpTCKnWaKVsLZrdlwf(AGYLXxdu26CRbcrwh5PfIwQzvzmuzPY)QYGFsCFUcUvqsFLCqz5Gd2eu8zu0WwJsz5qcDO8qQ07xwwYq43hPktqeOCoAGVgOC)IBhLEzSiRKdgDEz2ReN(YMfCPxHmx(dLciFikJZdrnnTquMYmeT(qCvV4E9)vctGZjiztMfCPxHmxazLCWieTpenl4sVczU8hkfq(qugNhIwd7meLPmdraZpeNobJRKb5gGsqYM0Hv9HO9HiG5hItNGX1RdtdWdcBGknj5qOX0P1)HO9HOzbx6viZL)qPaYhIYieXMsiAFi(Rdi)1E)GkPJ80UaYk5GrzmKeoXtvzyvV(ush5PvwwYq43hPktqeOCoAyXQWxduUm(AGYyTQxpezDKNwiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCnkLEzSiRKdgDEz2ReN(Ysh33xkiHilXdtp6bZLcmRGKcrmle1OeIYuMHOLHO0X99LcsiYs8W0JEWCPaZkiPqeZcrldrPJ77Rn5bYyjE4ACO2xGiHO1Ei6ri3aHjY1M8azSepCPaZkiPq0Qq0(q0JqUbctKRn5bYyjE4sbMvqsHiMfIANDiAvzmKeoXtv5h9GzYSPhuuvwwYq43hPktqeOCoAyXQWxduUm(AGY0rpycX8n9GIQYYbhSjO4ZOOHTgLYYHe6q5HuP3Vm16GNwoYgyaYxPY5Ob(AGY9lUMwPxglYk5GrNxM9kXPVSLHO0X991jeMa1e6E61HjZcU0RqMRJtHO9H46FHnyciGraPqeZcXZeIwfI2hIwgIdq64((YjY0FIGKnPqJRbctKq0QYyijCINQYorM(teKSjjK7ltTo4PLJSbgG8vQCoAyXQWxduUm(AGY2vKP)ebjleNJCFzmuzPY)QYGFsCF(aKoUVVCIm9Niiztk04AGWePSCWbBck(mkAyRrPSCiHouEiv69lllzi87JuLjicuohnWxduUFX1Mv6LXISsoy05LzVsC6llDCFFDcHjqnHUNEDyYSGl9kK564uiAFiU(xydMacyeqkeXSq8mLXqs4epvLDIm9Niiztsi3xwwYq43hPktqeOCoAyXQWxduUm(AGY2vKP)ebjleNJCFiAPMvLLdoytqXNrrdBnkLLdj0HYdPsVFzQ1bpTCKnWaKVsLZrd81aL7xCTZu6LXISsoy05LzVsC6lBziU(xydMacyeqkeLriQfI2hIR)f2GjGagbKcrzeIAHOvHO9HOLH4aKoUVVCIm9Niiztk04AGWejeTQmgscN4PQSxFfKjNit)jcswzQ1bpTCKnWaKVsLZrdlwf(AGYLXxduMA9vqcr7kY0FIGKvgdvwQ8VQm4Ne3NpaPJ77lNit)jcs2KcnUgimrklhCWMGIpJIg2AuklhsOdLhsLE)YYsgc)(ivzcIaLZrd81aL7xCTZsPxglYk5GrNxM9kXPV86FHnyciGraPqugHOwiAFiU(xydMacyeqkeLriQvgdjHt8uv2RVcYKtKP)ebjRSSKHWVpsvMGiq5C0WIvHVgOCz81aLPwFfKq0UIm9NiizHOLAwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1o7sVmwKvYbJoVm7vItF5biDCFF5ez6prqYMuOX1aHjszmKeoXtvzNit)jcs2KeY9LPwh80Yr2adq(kvohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeTCMvLXqLLk)Rkd(jX95dq64((YjY0FIGKnPqJRbctKYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZol9Yyrwjhm68YyijCINQYorM(teKSjjK7lllzi87JuLjicuohnSyv4RbkxgFnqz7kY0FIGKfIZrUpeT8mwvwo4GnbfFgfnS1OuwoKqhkpKk9(LPwh80Yr2adq(kvohnWxduUFX1WU0lJfzLCWOZlZEL40xwb3kiPVsoOmgscN4PQ8TBnWush5PvMADWtlhzdma578Y5iBcswX1kNJgwSk81aLlJVgOS15wdeISoYtleTCMvLXqLLkBq2eKSZ1Sw(vLb)K4(CfCRGK(k5GYYbhSjO4ZOOHTgLYYHe6q5HuP3VSSKHWVpsvMGiq5C0aFnq5(fxZAu6LXISsoy05LXqs4epvLHv96tjDKNwzQ1bpTCKnWaKVZlNJSjizfxRCoAyXQWxduUm(AGYyTQxpezDKNwiA5mRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3V4A2rPxglYk5GrNxgdjHt8uv(2TgykPJ80ktTo4PLJSbgG8DE5CKnbjR4ALZrdlwf(AGYLXxdu26CRbcrwh5PfIwEgRkJHklv2GSjizNRvwo4GnbfFgfnS1OuwoKqhkpKk9(LLLme(9rQYeebkNJg4Rbk3VFzRz4EpCFN3Vfa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20171125.213329, [[de00uaqivHSjsIrjs5uIOwLQq1RerQmlvHc3svOODPiddbhJelteEMQGMMQqPRHqfBterFdQ04qOsNtejRteP08Gk09ePAFiuoiczHkkperzIIifxuv0gHk4KiQMjcvDtfANQQLsu9uutfr2kjP9k9xvPbtLdR0IjYJfmzOCzWMvWNjkJMcNMQEnu1Sf1Tj1Uj8BidNK64IiSCKEUqtxLRtrBxK8DvboVIQ1lIu18HkA)u6QusL)RgkZEnzw3ZmObXT5KwRl6fYYG15hkZbQx9vUmRgc(n7t63ZJe9NijtuwoKHnc9NGGcUkkkj1KIIcHhMOSCyXMtYRHYyOBAiVA4nAGc4NOGE9I4JzAyGK5WW0qE1WB0afWpHzs3ZJepoHPhMCzIcNhjILu)kLu5NIvkdyDwzoq9QVYpY6oFaVxiZ6WjoTom0nnKxn8gnqb8tuqVEr06WX0TozbSYej5Z(BE5H8QH3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLXH8QbRJnqb8LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96prjv(PyLYawNvMduV6RSK5WWeemqq8fn8EgWRmkS3B0uGbuVq2KPARtfR7rwNK5WW0gdGaBfbyYuDzIK8z)nVmS0Zijmx8qzYfy(WEiAzbsaLhryQU0)QHYL)Rgk)CPNrsyU4HYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)WsQ8tXkLbSoRmrs(S)MxgYGge3MFLYB8ktUaZh2drllqcO8ict1L(xnuU8F1q5NzqdIBZw3S8gVYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9)ylPYpfRugW6SYCG6vFLtZ60lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1LujSUKTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaFz5qg2i0Fcck4QqOSCiImPbiws9ktMbeWpIsbAqCvQ8ic7VAOCV(joLu5NIvkdyDwzoq9QVYsMddt(amysNpzQ26uX60lKJhfPNcMukioRJyPBDjiyDQyDpY6KmhgM2yaeyRiatMQTovSojZHHjyPNbiEJhfeYoJjt1LjsYN938Yduu8EJgOa(YKlW8H9q0YcKakpIWuDP)vdLl)xnughOO4zDSbkGVSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jzjv(PyLYawNvMduV6RSEHC8Oi9uWKsbXzDelDRtrbxRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhXs36sQeLjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LMsYLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96h3sQ8tXkLbSoRmrs(S)MxoEiQgpaQbAzYfy(WEiAzbsaLhryQU0)QHYL)RgkZhIQXdGAGwwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFIBjv(PyLYawNvMduV6RCAwNEHC8Oi9uWKsbXzD4y6wNcbfRtfRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRdN406EK1T0ZpSHBk(aiN9czV6fYXJI0tGyLYaM1PI1PxihpkspfmPuqCwhoMU1HBsADjBDQyDpY6KmhgM2yaeyRiatMQltKKp7V5L9byWKoVm5cmFypeTSajGYJimvx6F1q5Y)vdLjpadM05LLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96pPkPYpfRugW6SYej5Z(BE5Spjm9yV6vMEFp0b6YKlW8H9q0YcKakpIWuDP)vdLl)xnuM49jHPhZ6gxz616iHoqxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfcLu5NIvkdyDwzoq9QVYsMddtQrpaOVOH3ZaE1lKJhfPNmvBDQyDsMddtXdr14bqnqNmvBDQyDB48PGxqaApeToC06EyzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFLLdzyJq)jiOGRcHYYHiYKgGyj1Rmzgqa)ikfObXvPYJiS)QHY96xrPKk)uSszaRZkZbQx9vgdDtd5vdVrdua)ef0RxeToIzDHnEVNxdwNkwxaHYyOhiEPWgUYej5Z(BE58MAFLmPXRm5cmFypeTSajGYJimvx6F1q5Y)vdLj(n1ADZmPXRSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)kjkPYpfRugW6SYCG6vFLLmhgM8byWKoFYuT1PI1LM1LM1PxihpkspfmPuqCwhXs36sqW6s26WjoTojZHHjFagmPZNOGE9IO1HJwxAwNYeXX6ECRlQgY5xJnEG194wNK5WWKpadM05tXBd4TUKoRtX6s26sUmrs(S)MxEGII3B0afWxMCbMpShIwwGeq5reMQl9VAOC5)QHY4affpRJnqb8wxAkjxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFLhwsLFkwPmG1zL5a1R(kNM1PxihpkspfmPuqCwhXs36sqW6uX6KmhgMGmObXT53buWmozQ26s26uX6sZ6OWafIgRugSUKltKKp7V5LhYRgEJgOa(YKzab8JOuGgexLkpIWuDP)vdLl)xnughYRgSo2afWBDPPKCzIOYILVLkdUx)q6uyGcrJvkdLLdzyJq)jiOGRcHYYHiYKgGyj1Rm5cmFypeTSajGYJiS)QHY96x5XwsLFkwPmG1zL5a1R(klzomm5dWGjD(KP6Yej5Z(BE5bkkEVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1qzCGIIN1XgOaERlTejxMiQSyznkLxilDLYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9RqCkPYpfRugW6SYCG6vFL1lKJhfPNcMukioRJyPBDkkkwhoXP19iRBPNFyd3u8bqo7fYE1lKJhfPNaXkLbmRtfRtVqoEuKEkysPG4SoILU1rCtsRdN406GKW0RwnGnf1Omgq9czVgWspRtfRdsctVA1a20zaVyqa8PaA8vkJqyVQ3WzDQyD6fYXJI0tbtkfeN1rmRdxcwNkw3TzqCt7Wb0ObkGFceRugWSovSojZHHjyPNbiEJhfeYoJjt1LjsYN938YWspJ3ObkGVm5cmFypeTSajGYJimvx6F1q5Y)vdLFU0ZW6yduaV1LwIKllhYWgH(tqqbxfcLLdrKjnaXsQxzYmGa(rukqdIRsLhry)vdL71VsswsLFkwPmG1zL5a1R(klzommrHisSIa8EOd0tuqVEr06WrRtHqzIK8z)nV8Hoq)Q34b05LjxG5d7HOLfibuEeHP6s)Rgkx(VAOmj0bARBCJhqNxwoKHnc9NGGcUkeklhIitAaILuVYKzab8JOuGgexLkpIW(Rgk3RFfClPYpfRugW6SYCG6vFLLmhgMuJEaqFrdVNb8QxihpkspzQ26uX62W5tbVGa0EiAD4O19WYej5Z(BE5SxMXj8czVsO8vMCbMpShIwwGeq5reMQl9VAOC5)QHYeVxMXj8czw3mu(SU0usUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)ke3sQ8tXkLbSoRmhOE1x5nC(uWliaThIwhXSofRtfRBdNpf8ccq7HO1rmRtPmrs(S)MxoySEXB2lZ4eEHSYKlW8H9q0YcKakpIWuDP)vdLl)xnuMmJ1lSoI3lZ4eEHSYYHmSrO)eeuWvHqz5qezsdqSK6vMmdiGFeLc0G4Qu5re2F1q5E9RKuLu5NIvkdyDwzIK8z)nVC2lZ4eEHSxju(ktUaZh2drllqcO8ict1L(xnuU8F1qzI3lZ4eEHmRBgkFwxAjsUSCidBe6pbbfCviuwoerM0aelPELjZac4hrPaniUkvEeH9xnuUx)jiusLFkwPmG1zL5a1R(ktHbkenwPmuMijF2FZlpKxn8gnqb8LjZac4hrPaniUoR8ikLxiRFLYJimvx6F1q5Y)vdLXH8QbRJnqb8wxAjsUmruzXYAukVqw6kpg3sLb3RFiDkmqHOXkLHYYHmSrO)eeuWvHqz5qezsdqSK6vMCbMpShIwwGeq5re2F1q5E9NqPKk)uSszaRZktKKp7V5LHLEgVrduaFzYmGa(rukqdIRZkpIs5fY6xP8ict1L(xnuU8F1q5Nl9mSo2afWBDP9WKltevwSSgLYlKLUsz5qg2i0Fcck4QqOSCiImPbiws9ktUaZh2drllqcO8ic7VAOCV(tKOKk)uSszaRZktKKp7V5LhYRgEJgOa(YKzab8JOuGgexNvEeLYlK1Vs5reMQl9VAOC5)QHY4qE1G1XgOaERlThMCzIOYIL1OuEHS0vklhYWgH(tqqbxfcLLdrKjnaXsQxzYfy(WEiAzbsaLhry)vdL71RCsdmSM5RZ61c]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20171125.213329, [[deKhkaqijL0MGGgfukNIi0QKuqZssH6wskKDrIgMs5ye1YOu9miqttsvUMKsSnjLY3GqJtsr5CsQuRtsrmpjv19Gs1(KurhKszHKupur1eLuKUOIYgLuHtsentIGBsj7uHFkPOAPqXtrMkeTvsWEf)fsnyu5WuTyO6XkzYs5YQ2mj5ZkYOLKtt41ePzlXTj1Ub9Bugoj0XHawofpxQMoW1vQ2oK8DjLQZdLSEjfy(sQK9JQoYbzOHRFisONZZnRC9HaVut45SvZNfIwgHIGqHQPxLVxarDimVCV)mSVjJOSSCDRuwwEdbThcZ9gwif6hQXakvvC9r3RylPknx7cyVgHT2X3vPsPQIRp6EfBjvzB34abdwd3uIGsmKTfqWG9Gmd5Gm0mOJxElQdzdxueaSc1bmJw6VI3essytSCaZecYGpKfRPGBgU(HcnC9draMrl9xXBcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqg2dYqZGoE5TOoKnCrraWkK3xh2C46HKe2elhWmHGm4dzXAk4MHRFOqdx)q26RdBoC9qyE5E)zyFtgr5TqyENTBwVhKbeAE1xsTyOU(qqWdzXAdx)qbKbcgKHMbD8YBrDiB4IIaGvOIab2fn0AFs7ObmW1HKe2elhWmHGm4dzXAk4MHRFOqdx)qsqGa7IgpNLpPDEoKmW1HW8Y9(ZW(MmIYBHW8oB3SEpidi08QVKAXqD9HGGhYI1gU(HciJ6fKHMbD8YBrDiAzekccHnEoFbeOo6dVw8opx955Qhphc550(lDGHPvU2nMdb8C1j255SVXZjrEoeYZHnEoZvzEVYXlNNtIHSHlkcawHuvC9r3RylPHMx9LulgQRpee8qwSMcUz46hk0W1puDuC955Ok2sAiBMPEiGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqg1sqgAg0XlVf1HSHlkcawHUBaviWUl9HKe2elhWmHGm4dzXAk4MHRFOqdx)qZCdOcb2DPpeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazuBbzOzqhV8wuhIwgHIGqngqPQIRp6EfBjvP5Axa78C1jp3Y7a0aH(8CiKNdFxLkLfhLJUVBMUYDf55qipxTYZb8YHaLfXufakGtOnSMYdD8YB8CiKNZxabQJ(WRfVZZvFEU6fYgUOiayfQ4OC047MoiKKWMy5aMjeKbFilwtb3mC9dfA46hscokNNt9UPdcH5L79NH9nzeL3cH5D2Uz9EqgqO5vFj1IH66dbbpKfRnC9dfqgigKHMbD8YBrDiAzekccvR8CaVCiqzrmvbGc4eAdRP8qhV8gphc558fqG6Op8AX78C1NNRw45QR6INd4LdbklIPkauaNqBynLh64L345qipNVacuh9HxlENNR(8C1lKnCrraWk0lxFiWlOXlEhessytSCaZecYGpKfRPGBgU(HcnC9dnRC9HaVWZPU4DqimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYOMfKHMbD8YBrDiB4IIaGvOIJYrJFxhssytSCaZecYGpKfRPGBgU(HcnC9djbhLZZP(UoeMxU3Fg23KruEleM3z7M17bzaHMx9LulgQRpee8qwS2W1puazu3bzOzqhV8wuhIwgHIGqTJVRsLYIyQcafWj0gwtzJv7Wq2WffbaRqRkxarxetvaOaofAE1xsTyOU(qqWdzXAk4MHRFOqdx)qZRCbKNtcIPkauaNczZm1dbCZ0bOfQWE747QuPSiMQaqbCcTH1u2y1omeMxU3Fg23KruEleM3z7M17bzaHKe2elhWmHGm4dzXAdx)qbKH8wqgAg0XlVf1HSHlkcawHwvUaIUiMQaqbCkKKWMy5aMjeKbFilwtb3mC9dfA46hAELlG8CsqmvbGc4eph2KLyimVCV)mSVjJO8wimVZ2nR3dYacnV6lPwmuxFii4HSyTHRFOaYqwoidnd64L3I6q2WffbaRqfhLJgF30bHMx9LulgQRpee1HSyOeWPmKdzXAk4MHRFOqdx)qsWr58CQ3nDaph2KLyiBMPEindLaoHD5qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqgY2dYqZGoE5TOoeTmcfbHmxL59khV8q2WffbaRqQkU(O7vSL0qZR(sQfd11hcI6qwmuc4ugYHSynfCZW1puOHRFO6O46ZZrvSLuEoSjlXq2mt9qAgkbCc7Y1yGBMoaTqf2nxL59khV8qyE5E)zyFtgr5TqyENTBwVhKbessytSCaZecYGpKfRnC9dfqaHif)s4frnWbcgmd71M9asaa]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20171125.213329, [[dauetaqiKKAteQgfiQtbf8kOqXSesrDlOqPDjLggu1XiLLjfEgssMgscUguOABcj6BqPghscDoHuADcPG5jKQ7jf1(KICqOKfccpKGmrHuOlcfTrHeojHYmHc5Ms0ob1sjKNIAQeyReu7v5VqLbtLdlAXi1JP0KLQlRAZG0NjvgTeonfVgjMTKUnj7gXVHmCH44ijA5e9Cbth46c12jv9DHKopsQ1lKImFqK9tvpTjymCQ(y2OeY7WSE1jGSgn4Dbdrx9ExgSJzR0ebmEC04HMXvWGySOxFg(GBGxdBnnTOTvttdpv1ySONDQfyuFS8Q0qcyS0XqH2Mb7j9KyFBpwMadImgllWGiHjyWAtWymjjD99bXy2knraJ7iql0AQoUqbYsPvEvAibVRjVJogk02mypPNe7B7XYeyqeVtCVdYEhWOU31uZExuI37GeK8o6yOqBPRiuVghaTXr8om4DI7DweQ2rrL0wt9jo6yza0kVknKG31K3H37e37OAVJogk02aajvu(JCzBCKXyrBQga1JZG9KEsSFSyKUXMaKCmbr(4sux4ucNQpEmCQ(ySc2t6jX(XIE9z4dUbEnS1Wpw0dOyP9HjyGXcvClLsK(Robm6XLOoCQ(4bgCJjymMKKU((GymBLMiGXuT3bmwkgIoVdsqY76iql0AQoUqbYsPvEvAibVl6n7D6S9XyrBQga1JHwt1XfkqwkJfJ0n2eGKJjiYhxI6cNs4u9XJHt1hhf1uDVJlqwkJf96ZWhCd8AyRHFSOhqXs7dtWaJfQ4wkLi9xDcy0JlrD4u9XdmyQAcgJjjPRVpigZwPjcySkFnaKivRnwkpb4Dn1S31aV3jU3jVknKG3f9M9o6yOqBZG9KEsSVThltGbr8oX9olcv7OOsAZG9KEsSVvEvAibVdJX7OJHcTnd2t6jX(2ESmbgeX7IEZExpwMadImglAt1aOEm0AQoUqbYszSyKUXMaKCmbr(4sux4ucNQpEmCQ(4OOMQ7DCbYsX7GSgggl61NHp4g41Wwd)yrpGIL2hMGbgluXTukr6V6eWOhxI6WP6JhyWuHjymMKKU((GymBLMiGX0XqH2EBb6bCiO4afhNo5taUqmPFPHORnoI3jU3r1EhDmuOTzWEspj23ghzmw0MQbq94NsqbvgNu(yXiDJnbi5ycI8XLOUWPeovF8y4u9XyMsqbvgNu(yrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adgJpbJXKK013heJXI2unaQh)6vNaYko6AgaJfJ0n2eGKJjiYhxI6cNs4u9XJHt1hJz9Qtaz17GOMbWyrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adokNGXyss667dIXSvAIagRYxdajs1AJLYtaExtn7DAAy7DqcsEhv7DPeyGMwqBiQVwneD4u5RbGePApjPRV7DI7DQ81aqIuT2yP8eG31uZEx02ymw0MQbq94NsqbUqbYszSyKUXMaKCmbr(4sux4ucNQpEmCQ(ymtjOW74cKLYyrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adg7jymMKKU((Gymw0MQbq94aajvu(JC5yXiDJnbi5ycI8XLOUWPeovF8y4u9Xmajvu(JC5yrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adMkobJXKK013heJXI2unaQhxnuzSPJtL6ujoacC1yXiDJnbi5ycI8XLOUWPeovF8y4u9XyKHkJnDVRm1PsVtacC1yrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adoANGXyss667dIXSvAIagthdfABeuuVehckoqXXPYxdajs1ghX7e37OJHcTnaqsfL)ix2ghX7e37slWO)4o5kZdEx09oQAmw0MQbq94QrxbGyi6WrJQGXIr6gBcqYXee5JlrDHtjCQ(4XWP6JXiJUcaXq05DqGQGXIE9z4dUbEnS1Wpw0dOyP9HjyGXcvClLsK(Robm6XLOoCQ(4bgSg(jymMKKU((GymBLMiGXDeOfAnvhxOazP0kVknKG31K3zZaahWOU3jU3bzVZIq1okQeCYNwG3bji5D0XqH2Mb7j9KyFBCeVddJXI2unaQhxt9jo6yzamwms3ytasoMGiFCjQlCkHt1hpgovFmgL6tVdIyzamw0RpdFWnWRHTg(XIEaflTpmbdmwOIBPuI0F1jGrpUe1Ht1hpWG10MGXyss667dIXSvAIagdzVtLVgasKQ1glLNa8UMA27AG37e37OJHcT91RobKvCqr24qBCeVddEN4EhK9o5HkFOiPR37WWySOnvdG6XqRP64cfilLXcvClLsK(Robm6XLOUWPeovF8y4u9Xrrnv374cKLI3b5gyymwsDHXGuQ7aCgOnlpu5dfjD9Jf96ZWhCd8AyRHFSOhqXs7dtWaJfJ0n2eGKJjiYhxI6WP6JhyWAnMGXyss667dIXSvAIagRYxdajs1AJLYtaExtn7DAAAEhKGK3r1ExkbgOPf0gI6Rvdrhov(AairQ2ts667EN4ENkFnaKivRnwkpb4Dn1S3rfJsVdsqY7ovgBIe592Gcv7xAi6Wv8uc8oX9UtLXMirEVfuCC9BVr)LbC0veQJlsAbEN4ENkFnaKivRnwkpb4Dn5DyJ37e37az9eqBcfCzOazP0EssxFFmw0MQbq94NsqbUqbYszSyKUXMaKCmbr(4sux4ucNQpEmCQ(ymtjOW74cKLI3bznmmw0RpdFWnWRHTg(XIEaflTpmbdmwOIBPuI0F1jGrpUe1Ht1hpWG1OQjymMKKU((GymBLMiGX0XqH2kFarsI94aiWvTYRsdj4Dr370W7DqcsEhK9o6yOqBLpGijXECae4Qw5vPHe8UO7Dq27OJHcTnd2t6jX(2ESmbgeX7Wy8olcv7OOsAZG9KEsSVvEvAibVddEN4ENfHQDuujTzWEspj23kVknKG3fDVtdJ7Dyymw0MQbq9yacCfovgaxs9yXiDJnbi5ycI8XLOUWPeovF8y4u9XcqGR8UYmaUK6XIE9z4dUbEnS1Wpw0dOyP9HjyGXcvClLsK(Robm6XLOoCQ(4bgSgvycgJjjPRVpigZwPjcyCAbg9h3jxzEW7AY708oX9U0cm6pUtUY8G31K3PnglAt1aOECn1N4OFQglgPBSjajhtqKpUe1foLWP6JhdNQpgJs9P3bXt1yrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adwdJpbJXKK013heJzR0ebmMogk02iOOEjoeuCGIJtLVgasKQnoI3jU3LwGr)XDYvMh8UO7Du1ySOnvdG6XvJUcaXq0HJgvbJfJ0n2eGKJjiYhxI6cNs4u9XJHt1hJrgDfaIHOZ7GavbEhK1WWyrV(m8b3aVg2A4hl6buS0(WemWyHkULsjs)vNag94suhovF8adwlkNGXyss667dIXSvAIagNwGr)XDYvMh8UM8onVtCVlTaJ(J7KRmp4Dn5DAJXI2unaQhBlsdbx1ORaqmeDJfJ0n2eGKJjiYhxI6cNs4u9XJHt1hlurAiEhgz0vaigIUXIE9z4dUbEnS1Wpw0dOyP9HjyGXcvClLsK(Robm6XLOoCQ(4bgSg2tWymjjD99bXySOnvdG6XvJUcaXq0HJgvbJfJ0n2eGKJjiYhxI6cNs4u9XJHt1hJrgDfaIHOZ7GavbEhKBGHXIE9z4dUbEnS1Wpw0dOyP9HjyGXcvClLsK(Robm6XLOoCQ(4bgSgvCcgJjjPRVpigZwPjcyS8qLpuK01pglAt1aOEm0AQoUqbYszSqf3sPeP)QtadIXLi9gIUbRnUe1foLWP6JhdNQpokQP6EhxGSu8oitvyymwsDHXkKEdrxZArZGuQ7aCgOnlpu5dfjD9Jf96ZWhCd8AyRHFSOhqXs7dtWaJfJ0n2eGKJjiYhxI6WP6JhyWAr7emgtssxFFqmglAt1aOE8tjOaxOazPmwOIBPuI0F1jGbX4sKEdr3G1gxI6cNs4u9XJHt1hJzkbfEhxGSu8oi3adJXsQlmwH0Bi6AwBSOxFg(GBGxdBn8Jf9akwAFycgySyKUXMaKCmbr(4suhovF8adUb(jymMKKU((Gymw0MQbq9yO1uDCHcKLYyHkULsjs)vNageJlr6neDdwBCjQlCkHt1hpgovFCuut19oUazP4DqMkGHXyj1fgRq6neDnRnw0RpdFWnWRHTg(XIEaflTpmbdmwms3ytasoMGiFCjQdNQpEGbgZrU1Kvt0ucmiYGBeLngyda]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170622.212605, [[d8tQiaWyiwpK0lfkzxcLYRvr53intkutdsy2Q05fYnrvPtt4Bui9Cr2PO2R0UHA)kQFcPggLACevPlR0qPObRqdhLoOICuHs1XiX5iQIwOcwkr0If0Yj1djspfSmkyDqIMiQkmvenzIY0v1ff4Qev1Zqv11rXgfQ2kQkYMPKTts9rvehMQpJQ8DvyKui2MksJgvgpr4KKKBPIQRjuCpuvu3gH1sufoorLRsjlG4SVGIJtXp8r3TaA5tASQCqbeN9fuCCk(bbQBZkgkODmVvk3ICwhkeEfOI6jx6rdleH2YkTVuN9fuCQz7csG2YkTVuN9fuCQz7cYXSmRmviumiqDBgf2fsC0JjgTRcBr7qb5ywMvMuN9fuCQdfKJrGCg8r3TGxi2zwMnvYMvkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJS6fHse6FHStSfabH05XamNJrwIf)OCEKvViuIq)li5ExpTnBWw5ufBB(laiAb7x4felF2UFZgkzHaShExzDOWeYlO45rJfPVaiiKopgG5CmYsS4hLZJYwlN5(fYoXwaeesNhdWCogzjw8JY5rzRLZC)csU31tBZgSvovX2M)(9lK4OhWH4r4Mc6qbjqBzL2N0182p1SDbbcfdSoIaZR5yk4mAxf2IsgXUfczSSke14NlV2YtdOW(uffJYVTbdg1UwNJIykyrXFHjTWVZJzxRPhfsC0dsxZB)uhkCw4egHJQlqI2usvNyeYccSmbI)u9egHJQliPQtmczbeN9fu8egHJQlmGMKenFliLYgnpssleG5CmYsS4FEeeyE39CsxZB)cjo6bq2HcYXSmlFi0lYlO4csQ6eJqwaZqOcHItnJIcrOTSs7RcltG4pvNA2UqIJEi1zFbfN6qbjqBzL2FIr7nBxq2A5m3FY04cGGq68yaMZXilXIFuopkBTCM7xWVSC(09WJsMQdAwPaHlXeZtB2Uq4vGkQNCPht3Bdl4xwoh4OhMQdAwPGFz5CPuIq)nvh0SsbcbEI5PnBxWz0(egHJQlmGMKenFnoiozb)E4rjt1MDOGArsekUIpImIDlewaXzFbfpDf8WfKgKjdKSGmrI96rKrSBbVGCmlZktfwMaXFQo1HcAhZBjJy3cEO4k(OcoJ25RaVDOGenF(PXMIn)XOeZPgIzp32oMcNfgNIFqG62SIHcVR5T)egHJQlmGMKenFLu1jgHSGFz5CsxZBFt1MnRuqGqXYdkLOzLykO3BbPbzYajlKy37n(1tCnSGFz5CsxZBFt1bnRuGWLaiBwPWzHXP4h(O7waT8jnwvoOaRwq46iviumiqDBgf2fKJzz2PRGhMyXFbKcVR5TFCk(Hp6UfqlFsJvLdkWxxcbbdX8iPGyBMF7cVR5TVPAZgwaq0c2Vqb)YY5t3dpkzQ2SzLcMAbHRJMhL6SVGIlK0(lOfy1ccxhfNIFqG62SIHcS6fHse6)KPXfabH05XamNJrwIf)OCEKvViuIq)lK4OhXAJcfyzcmVuhkq4smf0SDbs)U4FE8enLHTz7cVR5TVP6GgwqY9UEAB2GTIrTpvH)yZGc)kkgTqIJEyQ2SdfKaTLvAFvyzce)P6uZ2f4J1YzUFhkKDITqaMZXilXI)5rtTGW1rf8llNlLse6VPAZMvk8UM3(XP4VGj58i4408y21A6rHeh9qfwMaXFQo1HcYXiqoJpjsWhD3cEb)E4rjt1bDOqIJEmf0Hcjo6HP6GouaHse6VPAZgwWz0oze7wiKXYQqIJEmX80ouWuliCD08OuN9fu884eJ2lapvteQfyERUaHadKnBx4DnV9JtXpiqDBwXqHZcJtXFbtY5rWXP5XSR10Jcio7lO44u8xWKCEeCCAEm7An9OGZODGDVxv8rZgSvKxuetHaShExzDOqsqWE3j0bnZFHi0wwP9Ny0EZ2fsS79g)6joP0lvxYcEZkfcBwPaVMvkOBwPFbGDre(vGQ)ckUzdNYFHi0wwP9J1qQ5ZnuaHse6VP6GgwGqGNcAM)crOTSs7t6AE7NA2UqIJEahIhHBI5PDOGFz5CGJEyQ2SzLcYXSmRS4u8dcu3Mvmuqc0wwP9J1qQzLcYXSmRSynK6qHeh9aoepc3e6GouWz0U8XIVa71JwD)wa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170622.212605, [[d8ZBiaqyQwVQsVKuIDPiLxRQOFJ0mjLADajZwvoVcUjjWPjCBeUSs7us7vSBq7xQ6Na1WKsJJeeBdvWqPKbRqdhrhukokjiDmPY5ib1cvvTusOftulNIhsKEk0YOu9CjMOIunvuAYeX0v5IK0vjL0ZaIRJInQi2kqQSzs12jfFurYNrLMgQqFxrnskL8yaJgvnEurNKeDlkLY1uv4EukvFdiL1cKQooLItxydc4KNGcNqHhEdVniyTYQTYQAWZnC3ZsJvKdACi3vk)c8z(dAdZYSnpbxiXcVGabhaRRx2tQtEckSKABqobRRx2tQtEckSKABqBywMvIsakefF3u5yBWcpDUHX4kH60ih0gMLzLi1jpbfwYFWbW66L9yDd39kP2guHYSmBjSP2f2GQqx(TsYFWgGtqH9JAlkxquqiTFufY7qGLyHhO6hjnlaLq2VGvNydIccP9JQqEhcSel8av)iPzbOeY(fuX9TEzt1EB3hTCyA2T3febmcYl4jiwBVnxQ2dBqvOl)wj5pydWjOW(rTfLlikiK2pQc5DiWsSWdu9JswDN5DbRoXgefes7hvH8oeyjw4bQ(rjRUZ8UGkUV1lBQ2B7(OLdtZU9UC5cw4PZ4S4a4BuJCqobRRx2J1nC3RKABWcpDgNfhaFdZrZFqNX4kH6u2bYnOmJUEqobRRx2tl)LuBdYzQTbl80zw3WDVs(d(PCdeGNAcYc2srLtzl2GcOebGFutdeGNAcQOYPSfBqaN8euydeGNAc(dMLfSccIKlGWFIV(jOWuTZbqcw4PZiB(dAdZYStxywGtqHbvu5u2IniKHqjafwsLJblK77n55fEP0h1e2GEQDbLtTli3u7cAsTlxWcpDwQtEckSK)GCcwxVSxdJXtTnOKv3zExJL2brbH0(rviVdbwIfEGQFuYQ7mVliHZzdZrtTnO8t897up6CZ7f5G(JK3rE6SLg1u7c6psExkLq2plnQP2fKqaByoAQGe0FZ(qXsJv(dQrueYIN4gyhi3GYbbCYtqHnpbxyqPQvwvfdkruiF(a7a5gei40xDN5D5pOXHCx2bYnOllEIBiOZyCfiGB(d6psEV5n7dflnQP2f8t5ju4HIVBQD2d6mgVbcWtnb)bZYcwbARoHnO)i5Dw3WDplnwP2fCitSno8rRc31QWGaAGaslhviG0gDBJJFe0SVGsvRSQkgSqUV3KNx4JCq)rY7SUH7EwAutTl45gU71ab4PMG)GzzbRafvoLTydAdZYSsucLia8JAk5pOaGcb9ukrQDFeSWtNByoAKdEUH7EtOWdVH3geSwz1wzvnOcCofeme9JScInvqAdsAeeUzqjafIIVBQCSnicyeKxWIaY9Tb9hjV38M9HILgRu7cc4KNGcNqHhk(UP2zpiPrq4MHju4HIVBQD2dsAwakHSFnwAhefes7hvH8oeyjw4bQ(rsZcqjK9lyHNoRLDqwaLiGCl5piHZzJAQTbz93cV(XPmugYuBdEUH7EwAuJCWcpD2sJv(dAzeeUzOFuQtEckmyX4NGgKW5eztTny1j2GQqEhcSel86hBaRg8t5ju4f0ITFeDyPFS6gdDoOnmcGpbDIcEdVnOCqNX4SdKBqzgD9GfE6SsOebGFutj)b9hjVlLsi7NLgRu7c6VzFOyPrn)bl805g1ihSWtNT0OM)Gaucz)S0yf5GFkpHcp8gEBqWALvBLv1GNB4U3ek8cAX2pIoS0pwDJHohCaSUEzpT8xsTniHaISPcsWZnC3BcfEO47MAN9GwgbHBg6hL6KNGc7hBymEq8OgczJaYDnbbCYtqHtOWlOfB)i6Ws)y1ng6CqNX4i5(EkNEQTbvHU8BLe5Gfbb5BBaRMkib5eSUEzpLqjca)OMsQTbhaRRx2RHX4P2gCaSUEzpLqjca)OMsQTbvCFRx2uT32bATCOdKPzVdKUoqlOuk5q)ilnOkK3HalXcV(XgWQbLFIVFN6rNJCqcbSrnvqckaOqK0beqUP(rq)rY7ipD2sJvQDbTHzzwjtOWdfF3u7ShuNcVGngH)6hRUXqNdAdZYSs0YFj)bbOeY(zPrnYbDgJRvO4cs(8H1Klba]] )

    storeDefault( [[Elemental Primary]], 'displays', 20171125.224306, [[d8JyiaWyKA9QQ8sIsTluOYRvvQFd1mvv10uv0Sj58k0nHOCAu9nvf6WuTtPSxXUjSFf5NqyyuyCqKYZLQHsKbRkgochubhffkDmj5CeLyHkQLsuSyjA5u6HsONcwMKQ1rustefYur0KjQMUkxeLUQeWLv66qAJskBffQAZu02jfFuvjpdI4ZOOVRknsjqBtvbJMunEuWjjLUfejxdIQ7brQUnswlkuCCjOtvidq7ehhlQHfhCJQnaIcq(xBJnaTtCCSOgwCa)3Mwv9awxWClQV0FN5aLk(VFFPWVPmWictZ(EfDIJJf90mcWactZ(EfDIJJf90mcqy5uUDulnwa8FBAFAeGIlgytdjbkeDrx5fDIJJf9mhyeHPzFps3YCVEAgbySOl62dzAvHmaRWlvR8mhyG(4yX0ZFE)caS)NEyvl1koxn9izxAmvPFbAo1gay)p9WQwQvCUA6rYU0yQs)ciZQwVVPv3O6dvggijaqB5exGJtTiDJCPvpKbyfEPALN5ad0hhlME(Z7xaG9)0dRAPwX5QPhgTMoQ6c0CQnaW(F6HvTuR4C10dJwthvDbKzvR330QBu9HkddKeaOTCIlqUCb664x4LF06dSzoadimn77r6wM71tZiqxh)cV8JwFa9WzoGJADTctm5iXgOe10madimn77j75EAvbgryA23t2Z90qQQaDD8lPBzUxpZb(UCqqRJTbirijJ2VkizaUqoN2pSDqqRJTbKr7xfKmaTtCCSyqqRJTbMrqsIazbaILM7k(p)4yrA1)q9aDD8lqM5afIUOlJ42L(4yraz0(vbjdiqP0sJf90(mqNyvQAkVRxeRW2qgWtRkGnTQamtRkqzAv5c01XVfDIJJf9mhGbeMM99gqTEAgbKVMoQ6gK(ha4ufNEyvl1koxjRtpYxthvDbOCggqpCAgbkv8F)(sHFhuQugWve6oOJFL0WMwvaxrO7fXuL(jPHnTQauCXa6HtZiaJwthvDzoGRE9XUKgPmhqdVZl5k(nsosSb8a0oXXXIbfNPiqr2gjRmbKZ7ekFKCKyd4bCfHUpOE9XUKg20QcyDbZLCKyd4LCf)gd4OwhzCXM5aoQ1he06yBGzeKKiq2F2AKb(USgwCa)3Mwv9amKMraxrO7KUL5EsAKsRkWyQHuindzP(NgFOQ6JiXOE9pAetK6tKhWUQafzBKSYeOtSkvnL31tzaxrO7KUL5EsAytRkGRi0Dqh)kPrkTQafIUORCTc5CA)W2EMdui6IUY1sJfa)3M2NgbkeDr3bfNPGAfxa6aNBzUxnS4GBuTbquaY)ABSbqMZaNcLA6HKtTPHeJaNBzUNKgPugaOTCIlqaxrO7dQxFSlPrkTQaDD8RS3XsUqoxWSN5aewoLBhRHfhW)TPvvpaHDPXuL(ni9paWPko9WQwQvCUswNEiSlnMQ0VaswoLBhNEk6ehhlcCUL5E9auoddSPzeG0vR4ME(YIrjsZiW5wM7jPHnLb664xjnszoGmRA9(MwDJQpAilgiNXvvHCK)5NbAo1gGvTuR4C10JKLt52XafIYP)MXZ7WnQ2aEGVlRHfxajYPhWf9PNMBT43aoQ1jhj2aLOMMbCfHUxetv6NKgP0Qc01XVAfY50(HT9mhGYzaitRkGRE9XUKg2mhORJFL0WM5aDD87aBMdqJPk9tsJukdCUL5E1WIlGe50d4I(0tZTw8BaonwaeonxWmnKh47YAyXb3OAdGOaK)12ydqXfazAgbo3YCVAyXb8FBAv1diz5uUDC6POtCCSy6za16bcq7ehhlQHfxajYPhWf9PNMBT43aoQ1bIvP0YO0mcWk8s1kpZb6Ckc1oGGnT6byaHPzFpTc5CA)W2EAgbgryA23Ba16PzeyeHPzFpTc5CA)W2EAgbkIjgNEiXbyvl1koxn9mGGnanMQ0pjnSPmqxh)oGADTctCkd01XVdOhoZbo3YCVbbTo2gygbjjcKjJ2VkizaonwWyWyQ0qIrGcrx0vEnS4a(VnTQ6bmXIlWGL7QPNMBT43afIUORCzp3ZCGUo(fE5hT(ac2mhWrTEbe8laHYhxBUea]] )

    storeDefault( [[Elemental AOE]], 'displays', 20171125.224306, [[d8dmiaWyKSEvLEjLq7cPu9AfKFd1mHOMMQcZMIZRq3ePKtJY3iI45sANuzVIDty)kQFcHHrIXreLlR0qjLbRkgochuIoksP4ykY5GiSqvvlLiSyu1YPQhkHEkyzkW6iI0ePezQqAYevtxLlssxLsupJsY1r0gLGTcruBMsTDI0hvqDyP(ms13vLgjLGTbrA0KQXJuCsIYTiIQRPQO7HukDBuzTqe54usDMcAaQM4yyrbS4GB0SbqyzuKL5udq1ehdlkGfhW(UXnniGVf03I6l1q5pG1Kl5wAy0fCR4cqfyeHTDDVInXXWIACkbObHTDDVInXXWIACkbi8mU2pkJcla23nUpucWXeLQXniG1Kl5kVytCmSOM)aJiSTR7H2E67vJtjaTHCj3AqJBkObufnVzLN)aLuhdlMFqMvV4KSaUMBdaQip)OAwUvCTz(rZVuyo((ciXA2UUXnqzcPtkkwfaO8mIlWX4wARsU4ge0aQIM3SYZFGsQJHfZpiZQxCinGR52aGkYZpQMLBfxBMFS0A3KMlGeRz76g3aLjKoPOyfTpfaO8mIlqUCbQ64x4LDu6LQHpaniSTR7H2E67vJtjaJclaIMIjOh3NbU2tFVsbLo2h4hbkkcAjHSHTaAGXuqYr6NkiXKcsyLKyLvkFizwPeBj)JpdyJfxGspRnZpU27XVbQ64x02tFVA(dmeFPGsh7dGIqtczdBb0amHCgvFyFPGsh7diHSHTaAaQM4yyrPGsh7d8JaffbTcaelfRnSV9XWI4gG0bbQ64xan)bSMCjxlX8l1XWIasiBylGgqqYjJclQX9rGkXAmfmDvVi2G9bnqh3ua(4McqpUPa(4MYfOQJFl2ehdlQ5paniSTR7vs674uciFTBsZvQHCaGXvC(r1SCR4AJKo)iFTBsZfGRPPK8WXPeOne6DP5ThRAsvJBkqBi0Bqh)QjvnUPaTHqVlI547ttQACtb4yIsYdh3GaT5ThRAs1YFaPSkJNzy3i6iXgGpavtCmSO0WOlcuu1HQkra5SkHPhrhj2aub4nSVFh2GFlnMWhW3c6l6iXgO5zg2ngOj9nTyIn)bS0A3KMl)bgIVawCa77g30GaJiSTR7zX)ACkbAdHEJ2E67PjvlUPa0eNsa)Acuu1HQkrGkXAmfmDvp8bAdHEJ2E67PjvnUPanPVLjSXOJeBaEsB7awtUKRCzc5mQ(W(A(d0K(UuqPJ9b(rGIIGwiRwanG1Kl5kxgfwaSVBCFOe4Ap99kGfhCJMnaclJISmNAaA10W4i5MFqzCBCwPe4Ap990KQf(aaLNrCbQmbDZgOne6DP5ThRAs1IBkqvh)AXDKNjKZe0R5paHNX1(XcyXbSVBCtdcq4xkmhFFLAihayCfNFunl3kU2iPZpe(LcZX3xajwZ21nUbktsIcsO8jTpn95NF8raUMMs14ucG2MvCZpd7XKeXPe4Ap990KQg(avD8RMuT8hqZZ4A)48tXM4yyraFFmCaUMganoLaUMBdOAwUvCTz(PeHAGH4lGfxan05hOf15hx7943awtYOgcjZQWnA2a8bAsFJosSb4jTTdu1XVYeYzu9H918hOne6DrmhFFAs1IBkqBE7XQMu18hOQJFlvdFGQo(vtQA(dqH547ttQw4du1XVWl7O0ljpC(dCTN(EfWIlGg68d0I68JR9E8BGH4lGfhCJMnaclJISmNAaoMaqJBqGR903RawCa77g30GaAEgx7hNFk2ehdlMFkj9DGcMMBNFaDm1qbOAIJHffWIlGg68d0I68JR9E8BGM03aXAmYSuCkbufnVzLN)avghHzlrOg3Ga0GW2UUNmHCgvFyFnoLaJiSTR7vs674ucmIW2UUNmHCgvFyFnoLafXeJZpO4aQMLBfxBMFkrOgGcZX3NMu1WhG3W((Dyd(n8bQ643ssFltyJdFGQo(TK8WHpaJclqsymxCwPeWAYLCLxaloG9DJBAqaAqyBx3ZI)14ucyn5sUYT4Fn)bAdHEd64xnPAXnfOj9TLfSlaHPhxFUea]] )



end
