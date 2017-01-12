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
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole

local RegisterEvent = ns.RegisterEvent
local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'SHAMAN') then

    ns.initializeClassModule = function ()

        setClass( 'SHAMAN' )

        -- addResource( SPELL_POWER_HEALTH )
        addResource( 'mana', true )
        addResource( 'maelstrom' )

        addTalent( 'windsong', 201898 )
        addTalent( 'hot_hand', 201900 )
        addTalent( 'boulderfist', 201897 )

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
        addTalent( 'landslide', 197992 )
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


        -- Player Buffs.
        addAura( 'ascendance', 114051 )
        addAura( 'astral_shift', 108271, 'duration', 8 )
        addAura( 'boulderfist', 218825 )
        addAura( 'crash_lightning', 187874 )
        addAura( 'doom_winds', 204945 )
        addAura( 'earthen_spike', 188089 )
        addAura( 'flametongue', 194084 )
        addAura( 'frostbrand', 196834 )
        addAura( 'fury_of_air', 197211 )
        addAura( 'hot_hand', 215785 )
        addAura( 'landslide', 202004 )
        addAura( 'lightning_shield', 192109 )
        addAura( 'rainfall', 215864 )
        addAura( 'stormbringer', 201845 )
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
        addAura( 'lightning_rod', 210689, 'duration', 10 )
        addAura( 'power_of_the_maelstrom', 191877, 'duration', 20, 'max_stack', 3 )
        addAura( 'resonance_totem', 202192 )
        addAura( 'storm_tempests', 214265, 'duration', 15 )
        addAura( 'storm_totem', 210652 )
        addAura( 'stormkeeper', 205495, 'duration', 15, 'max_stack', 3 )
        addAura( 'tailwind_totem', 210659 )
        addAura( 'thunderstorm', 51490, 'duration', 5 )


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

        RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

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

        addHook( 'reset_postcast', function( x )
            state.feral_spirit.cast_time = nil 
            -- if state.talent.ascendance.enabled then state.setCooldown( 'ascendance', max( 0, state.last_ascendance + 180 - state.now ) ) end
            return x
        end )

        addHook( 'advance_end', function( time )
            if state.equipped.spiritual_journey and state.cooldown.feral_spirit.remains > 0 and state.buff.ghost_wolf.up then
                state.setCooldown( 'feral_spirit', max( 0, cooldown.feral_spirit.remains - time * 2 ) )
            end
        end )


        -- Pick an instant cast ability for checking the GCD.
        -- setGCD( 'global_cooldown' )

        -- Gear Sets
        addGearSet( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
        addGearSet( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
        addGearSet( 'doomhammer', 128819 )
        addGearSet( 'fist_of_raden', 128935 )

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

        addHook( 'advance_resource_regen', function( override, resource, time )
            
            if resource ~= 'maelstrom' or not state.spec.enhancement then return false end

            if state.spec.enhancement and resource == 'maelstrom' then

                local MH, OH, in_melee = UnitAttackSpeed( 'player' ), state.target.within5

                local nextMH = ( in_melee and state.settings.forecast_swings and MH and state.nextMH > 0 ) and state.nextMH or 0
                local nextOH = ( in_melee and state.settings.forecast_swings and OH and state.nextOH > 0 ) and state.nextOH or 0
                local nextFoA = ( state.buff.fury_of_air.up and state.settings.forecast_fury and state.nextFoA and state.nextFoA > 0 ) and state.nextFoA or 0

                local iter = 0

                local offset = state.offset

                -- print( 'checking maelstrom', state.query_time, nextMH, nextOH )

                while( iter < 10 and ( ( nextMH > 0 and nextMH < state.query_time ) or
                    ( nextOH > 0 and nextOH < state.query_time ) or
                    ( nextFoA > 0 and nextFoA < state.query_time ) ) ) do

                    if nextMH > 0 and nextMH < nextOH and ( nextMH < nextFoA or nextFoA == 0 ) then
                        state.offset = nextMH - state.now
                        local gain = state.buff.doom_winds.up and 15 or 5
                        state.offset = offset

                        resource.actual = min( resource.max, resource.actual + gain )
                        state.nextMH = state.nextMH + MH
                        nextMH = nextMH + MH

                    elseif nextOH > 0 and nextOH < nextMH and ( nextOH < nextFoA or nextFoA == 0 ) then
                        state.offset = nextOH - state.now
                        local gain = state.buff.doom_winds.up and 15 or 5
                        state.offset = offset

                        resource.actual = min( resource.max, resource.actual + gain )
                        state.nextOH = state.nextOH + OH
                        nextOH = nextOH + OH

                    elseif nextFoA > 0 and nextFoA < nextMH and nextFoA < nextOH then
                        resource.actual = max( 0, resource.actual - 3 )

                        if resource.actual == 0 then
                            state.offset = nextOH - state.now
                            state.removeBuff( 'fury_of_air' )
                            state.offset = offset

                            state.nextFoA = 0
                            nextFoA = 0
                        else
                            state.nextFoA = state.nextFoA + 1
                            nextFoA = nextFoA + 1
                        end

                    else
                        break

                    end

                    iter = iter + 1
                end

                return true

            end

            return false

        end )

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
                "This setting allows you to extend this safety window by up to 0.5 seconds.  It may be beneficial to set this at or near your latency value, to prevent tiny fractions of time where " ..
                "your buffs would fall off.  This value is checked as |cFFFFD100rebuff_window|r in the default APLs.",
            width = "full",
            min = 0,
            max = 1.5,
            step = 0.01
        } )

        ns.addSetting( 'foa_padding', 6, {
            name = "Fury of Air: Maelstrom Padding",
            type = "range",
            desc = "Set a small amount of buffer Maelstrom to conserve when using your Maelstrom spenders, when using Fury of Air.  Keeping this at 6 or greater will help prevent your Maelstrom from hitting zero " ..
                "and causing Fury of Air to drop off.  This value is checked as |cFFFFD100foa_padding|r in the default APLs.",
            width = "full",
            min = 0,
            max = 12,
            step = 1
        } )

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

        ns.addSetting( 'lava_lash_maelstrom', 120, {
            name = "Maelstrom: Lava Lash",
            type = "range",
            desc = "Set a |cFFFF0000minimum|r amount of Maelstrom required to cast Lava Lash in the default action lists.  This is ignored if Lava Lash would currently be free.\n\n" ..
                "The addon default and SimulationCraft all recommend using Lava Lash at/above 120 Maelstrom by default (without Tier 19 4pc).\n\n" .. 
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.lava_lash_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } )



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
            known = function () return talent.ascendance.enabled end,
            cooldown = 180,
            toggle = 'cooldowns'
        }, 114050 )

        modifyAbility( 'ascendance', 'id', function( x )
            if spec.elemental then return 114050 end
            return x
        end )

        class.abilities[ 114050 ] = class.abilities.ascendance -- Elemental.

        addHandler( 'ascendance', function ()
            applyBuff( 'ascendance', 15 )
            setCooldown( 'stormstrike', 0 )
            gainCharges( 'lava_burst', class.abilities.lava_burst.charges )
        end )


        addAbility( 'astral_shift', {
            id = 108271,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 90
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
            toggle = 'cooldowns'
        } )


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
            toggle = 'cooldowns'
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
            toggle = 'cooldowns'
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
            toggle = 'cooldowns'
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
            known = function() return talent.fury_of_air.enabled end
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
            known = function() return mana.current / mana.max > 0.22 end
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
            toggle = 'cooldowns'
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
            if buff.ascendance.up then return 0 end
            return x
        end )

        addHandler( 'lava_burst', function ()
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
            if buff.rainfall.up then
                buff.rainfall.expires = max( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
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
            known = function() return talent.rainfall.enabled end
        } )

        addHandler( 'rainfall', function ()
            applyBuff( 'rainfall', 10 )
        end )


        -- LegionFix: Adjust spend value based on artifact traits.
        addAbility( 'rockbiter', {
            id = 193786,
            spend = -20,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            known = function() return not talent.boulderfist.enabled end
        } )

        modifyAbility( 'rockbiter', 'spend', function( x  )
            return x - ( artifact.gathering_of_the_maelstrom.rank )
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
            toggle = 'cooldowns'
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
            return buff.stormbringer.up and x / 2 or x
        end )

        modifyAbility( 'stormstrike', 'cooldown', function( x )
            return buff.stormbringer.up and 0 or x * haste
        end )

        addHandler( 'stormstrike', function ()
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end
            removeStack( 'stormbringer' )

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
            spend = 40,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15,
            known = function() return buff.ascendance.up end
        } )

        modifyAbility( 'windstrike', 'spend', function( x )
            return buff.stormbringer.up and x / 2 or x
        end )

        modifyAbility( 'windstrike', 'cooldown', function( x )
            return buff.stormbringer.up and 0 or x * haste
        end )

        addHandler( 'windstrike', function ()
            if buff.rainfall.up then
                buff.rainfall.expires = min( buff.rainfall.applied + 30, buff.rainfall.expires + 3 )
            end

            removeStack( 'stormbringer' )

            if equipped.storm_tempests then
                applyDebuff( 'target', 'storm_tempests', 15 )
            end

            if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )

    end


    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170111.3, [[dau5jaqiffzriuBsrPgfevNcbzxezykYXeyzevptr10ifvUMIs2gKY3qGXPOqoNIcSosrMhck3dIs2hcQoirzHKkpuqnrff0fjHnQOOgjPOQtsiwjPOyMquCtiStc(PIc1qjfLwQG8uutfISxP)ssgmKCyvwmIEmftMsxgSzsPpRugnPQtJ0RHunBOUTq7w0Vv1WjPwUcpxjtNQRtO2oc57KcNNeTEik18jK2Vs1nOivwrEKyWwDLfUiuMPXW7OuGHiK(H10oklO9eJ9YZqq7jg7vx5qagUfub5tbemfeeijVmRgm0dtr2Nt)ScYrtEzzgN(5QivHGIuzf5rIbBjllCrOSMhgpDflZMbvTx2)Tnmiz(hBFnY1SrUFJnWL0dh21lP24eM8zjQOonce(K0SMMiuzzKum1vwMe)VflE5Ldby4wqfKpfGwabstZlhwpyqhXteeH0lzzrsl1C(pkNFcLr8wHlcLRxb5fPYkYJed2QRmBgu1Ez)32WGK63PFUMnYjfRvReGHiK(HvfVLddLsIvlQO(n2axYPrqL)QSuGWqwZNevusXA1krI)3IfVCjXQjuzzKum1vww970pllsAPMZ)r58tOSWfHYA23PFww2yBvoViGSi2cNfRu124maXLdby4wqfKpfGwabstZlhwpyqhXteeH0lzzeVv4IqzITWzXkvTnodqC9kmVivwrEKyWwDLfUiugP3H4oke3YHHYYSzqv7LjfRvR0awFEPbu5VdrPbepAUim5LLrsXuxzz)DiQkElhgklhcWWTGkiFkaTacKMMxoSEWGoINiicPxYYIKwQ58Fuo)ekJ4TcxekxVcAUIuzf5rIbB1vw4Iq5zMoGDukWqes)WLzZGQ2l7)2ggKm)JTVg5QSmskM6klRLoavagIq6hUCiad3cQG8Pa0ciqAAE5W6bd6iEIGiKEjllsAPMZ)r58tOmI3kCrOC9kmRIuzf5rIbB1vw4Iqz2)rChLcmeH0pCz2mOQ9Y(VTHbjZ)y7RrUklJKIPUYYl)hrvagIq6hUCiad3cQG8Pa0ciqAAE5W6bd6iEIGiKEjllsAPMZ)r58tOmI3kCrOC9kGwrQSI8iXGT6klCrOScmeH0p8oke3YHHYYSzqv7L9FBddsM)X2xJCvwgjftDLLbmeH0pSQ4TCyOSCiad3cQG8Pa0ciqAAE5W6bd6iEIGiKEjllsAPMZ)r58tOmI3kCrOC9kqqrQSI8iXGT6klCrOSo8)2DuZS4HYYSzqv7L9FBddsM)X2xJCnBKpt(HH0LULbs7LgqcYJedwrfLuSwTs3YaP9sdijwTOIA(hBFnsPBzG0EPbKgq8O5IWN1eHklJKIPUYYK4)TQ0kEOSCiad3cQG8Pa0ciqAAE5W6bd6iEIGiKEjllsAPMZ)r58tOmI3kCrOC9kmJksLvKhjgSvxzHlcL1bJfmqNMBLzZGQ2l7)2ggKm)JTVg5A2iFM8ddPlDldK2lnGeKhjgSIkkPyTALULbs7LgqsSAcvwgjftDLLjHXcgOtZTYHamClOcYNcqlGaPP5LdRhmOJ4jcIq6LSSiPLAo)hLZpHYiERWfHY1RWmOivwrEKyWwDLzZGQ2lFgNseOcsisHfHlFxZuwgjftDLLhItvNXPFQctxEzrsl1C(pkNFcLfUiuoK4ChLmJt)ChfYqxEzzJTv5YHamClOcYNcqlGaPP5Lz9VgiElvlfgRQRCy9GbDeprqesVKLr8wHlcLjMPXW7OuGHiK(H10okzZyfexVcbtfPYkYJed2QRmBgu1Ez)Wq6s3YaP9sdib5rIbBzzKum1vwEiovDgN(PkmD5LfjTuZ5)OC(juw4Iq5qIZDuYmo9ZDuidD57OqEaHklBSTkxoeGHBbvq(uaAbeinnVmR)1aXBPAPWyvDLdRhmOJ4jcIq6LSmI3kCrOmXmngEhLcmeH0pSM2rTO5gg2rDldX1RqqqrQSI8iXGT6kZMbvTx2pmKUe1aAfpukb5rIbBzzKum1vwEiovDgN(PkmD5LfjTuZ5)OC(juw4Iq5qIZDuYmo9ZDuidD57OqUCcvw2yBvUCiad3cQG8Pa0ciqAAEzw)RbI3s1sHXQ6khwpyqhXteeH0lzzeVv4IqzIzAm8okfyicPFynTJArZnmSJIQL46viqErQSI8iXGT6kZMbvTx2pmKUeMUP3tAUPA8wjipsmyllJKIPUYYdXPQZ40pvHPlVSiPLAo)hLZpHYcxekhsCUJsMXPFUJczOlFhfYNtOYYgBRYLdby4wqfKpfGwabstZlZ6Fnq8wQwkmwvx5W6bd6iEIGiKEjlJ4TcxektmtJH3rPadri9dRPDulAUHHDu4bX1RxMndQAVC9w]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170111.3, [[d8ImcaGErvAxiLTjQmBQCtv0Tr1oLyVKDJy)qsdte)wvdvuvdgkmCr5GivhdQwikzPuLwmswUKEivLNcEmeRJsjtKsHPcLMSknDHlIIUSY1Pu0MPuQTdPCyP(mk1ZPKLjsNxfgnKQ)cfDsiX3OuDAkUNOkEgvXIOQ61OWcxyfWK0uUDflbLMpbGH7dvmy6gFKOD2cvmYQd55uDiWgZ2TnDHyjW7CRTMkPj42tWXXPLkaYgIPDM82H5jQKMlvaDKW8elHvfCHvatst52vSeaivtwiiE2SDJw2hMNyjGoLXzIdbzFyEIauixdshFva5jtqP5tq(FyEIa6v2wcinF5X)D91DGj7AJm)c8o3ARPsAcEoC70s8iWh6dHX5J24JeIsW5FlnFc8FxFDhyYU2iZVcvsfwbmjnLBxXsqP5ta2pghvmoBRy1dbENBT1ujnbphUDAjEeqNY4mXHG4JXXK3wXQhcqHCniD8vbKNmb(qFimoF0gFKquco)BP5tGcv8iScysAk3UILGsZNai(kNXw2Qc8o3ARPsAcEoC70s8iGoLXzIdbwXx5m2YwvakKRbPJVkG8KjWh6dHX5J24JeIsW5FlnFcuOqaGunzHafsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170111.3, [[d0dLoaGEIePnPsQDrjBtcTpvsMjrQMnPMprI6MQuhwPBtX3uj2je7vSBf7Nenkkvnmv0Vr8CKCEvWGjHHtsoerI4uQqogsDCvOSqIQLQQYIH0YL0dLOEkQLruwhLkPjQcv1uLGjRktxQlss9kvOkxgCDIyJej1PHAZey7e0Rvv(orktJsLyEej8yQ8xQQrtONrPCsvv9zQY1uHk3JsfJJijNJsL6GsKdDkew9SOA4f5HrwdeMXMYkvOwdgy6vBxvQGcpEAqPcDn8XheSs0DKh(hOHLccISt6lN000wYcZQahE1yP0TXKjiYkklCjxJjdvkee6uiS6zr1WlYdJSgiSuRxdOublsCFHzxfRQdlL0y3hE8cxcfRX9HWc0Rb8PejUVW)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoiYsHWQNfvdVipmYAGWQ3AlEmj7heMDvSQomQebcSaNibO8jc8BrW3RcB7tjzEqfpEwsuDTzbnvxjglNKAfM(k7ivfdxcfRX9HWWwBXJjz)GW)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoi2sHWQNfvdVipmYAGWQ3AlQublsCFHzxfRQdBwqt1vIXYjPwHPVYo2TSWLqXACFimS1w0NsK4(c)d0Wsbbr2jDr6lwN2cxweCF3eHGbMoOH)ppSBBsn8qgi8n5HSgiC6GyxsHWQNfvdVipmYAGWCtQMpaub1WSRIv1HxxJfc(WagmqDLTWLqXACFimvtQMpaub1W)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoihxkew9SOA4f5HrwdewTgmW0RwPc56LQd)d0Wsbbr2jDr6lwN2cxcfRX9HWGgmW0R2hvVuD4)Zd72MudpKbcxweCF3eHGbMoOHVjpK1aHthKIPqy1ZIQHxKhgznqyPJpMe8tPI71ZSkvuG0Gjm7QyvD411yHGpmGbduxzlCjuSg3hcRXhtc(5BwpZ63KgmH)bAyPGGi7KUi9fRtBHllcUVBIqWath0W)Nh2TnPgEide(M8qwdeoDqUKcHvplQgErEyK1aHL(kCvQqUKkvhMDvSQo8J0wc0Rb8PejUpRkyw8qDLBPA)gBGRDeI(rK24xH11HlHI14(qy9kC9rLuP6W)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoisvkew9SOA4f5HrwdewQ1RbuQGfjUpLkSN(OWSRIv1HnlOP6kXy5KuRW0xzhzNxJkrGalqdgy6v7lG4Kqzjr11vqqfOexuneUekwJ7dHfOxd4tjsCFH)bAyPGGi7KUi9fRtBHllcUVBIqWath0W)Nh2TnPgEide(M8qwdeoDqS7uiS6zr1WlYdJSgiS6T2IkvWIe3Nsf2tFuy2vXQ6WMf0uDLySCsQvy6RSJuvmCjuSg3hcdBTf9PejUVW)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoi0NPqy1ZIQHxKhgznq4cKgmkvCVunupeMDvSQomQebcSQafz2Xb(nPbJvfmlEOKc6tPSu2EujceyvbkYSJd8BsdgRkyw8qjf2JkrGaRLYbZBhhy9Ku3gtMJNJq0pI0gRLYbZBhhyvbZIhQJU2ri6hrAJ1s5G5TJdSQGzXdLuqFChfUekwJ7dHBsdgFZs1q9q4FGgwkiiYoPlsFX60w4YIG77MiemW0bn8)5HDBtQHhYaHVjpK1aHtheA6uiS6zr1WlYdJSgiS6T2IhtY(bkvyp9rHzxfRQdJkrGalWjsakFIa)we89QW2(usMhuXJNLevHlHI14(qyyRT4XKSFq4FGgwkiiYoPlsFX60w4YIG77MiemW0bn8)5HDBtQHhYaHVjpK1aHtheAzPqy1ZIQHxKhgznqyPJ9e7bpEkviNO7WSRIv1HrLiqGLkI0GQprGFlc(Mf0uDLySKO6611yHGpmGbdusHTRFaQebcS0ypXEWJNFL8SEePnHlHI14(qyn2tSh845Js0D4FGgwkiiYoPlsFX60w4YIG77MiemW0bn8)5HDBtQHhYaHVjpK1aHtheABPqy1ZIQHxKhgznqyPJ9e7bpEkviNOBLkSN(OWSRIv1HrLiqGLkI0GQprGFlc(Mf0uDLySKO6611yHGpmGbdusHTWLqXACFiSg7j2dE88rj6o8pqdlfeezN0fPVyDAlCzrW9Dtecgy6Gg()8WUTj1WdzGW3KhYAGWPdcTDjfcREwun8I8WiRbcxwCXJsfsh7j2dE8cZUkwvhEDnwi4ddyWa1v0xVUgle8HbmyG6k6RFaQebcS0ypXEWJNFL8SEePnHlHI14(qyN4IhFn2tSh84f(hOHLccISt6I0xSoTfUSi4(UjcbdmDqd)FEy32KA4Hmq4BYdznq40bH(4sHWQNfvdVipmYAGWLfx8OuH0XEI9GhpLkSN(OWSRIv1HxxJfc(WagmqDf91RRXcbFyadgOUIoCjuSg3hc7ex84RXEI9GhVW)anSuqqKDsxK(I1PTWLfb33nriyGPdA4)Zd72MudpKbcFtEiRbcNoi0ftHWQNfvdVipmYAGWsh7j2dE8uQqor3kvyVSJcZUkwvh(bOseiWsJ9e7bpE(vYZ6rK2eUekwJ7dH1ypXEWJNpkr3H)bAyPGGi7KUi9fRtBHllcUVBIqWath0W)Nh2TnPgEide(M8qwdeoDqOVKcHvplQgErE4sOynUpewJ9e7bpE(OeDh()8WUTj1WdzGWiRbclDSNyp4XtPc5eDRuH92okC5donuyREqtf0W)anSuqqKDsxK(I1PTWLQEuHDhCAWV3Qh0u25bOseiWsJ9e7bpE(vYZsIQWLfb33nriyGPdA4BYdznq40bHwQsHWQNfvdVipm7QyvD4kiOcuIlQgcxcfRX9HWc0Rb8PejUVW)Nh2TnPgEide(MiepEHPdJSgiSuRxdOublsCFkvyVSJcxQ6rf2qeIhp7qh(hOHLccISt6I0xSoTfUSi4(UjcbdmDKh(M8qwdeoDqOT7uiS6zr1WlYdxcfRX9HWWwBrFkrI7l8)5HDBtQHhYaHVjcXJxy6WiRbcRERTOsfSiX9PuH9YokCPQhvydriE8SdD4FGgwkiiYoPlsFX60w4YIG77MiemW0rE4BYdznq40br2zkew9SOA4f5HlHI14(qyb61a(uIe3x4)Zd72MudpKbcFteIhVW0HrwdewQ1RbuQGfjUpLkS32rHlv9OcBicXJNDOd)d0Wsbbr2jDr6lwN2cxweCF3eHGbMoYdFtEiRbcNoDy2vXQ6WPta]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170111.3, [[d4JFoaGEKsvTjII2Le2gL0(ikmtfihwPztX8jkHBQqFtICBs9CeTtvSxXUv1(jrJsb1WKu)gLZtsDAcdMKmCIQdHuQ0PuqogchxbQfsclfPyXiz5u5HkIvrukwgQ06ikLMisPktvIAYOQPl1fPeVcPuXLbxxLAJkGETKSzf12rQ(mQ4Xu10ikrFxbWZOu(Rkz0ezEiLYjvKghrjDnIs19qk5Cka9uOdsP6qKYbT8lLb4JIGNvdbrHEIsvwmGg(EnYwLQifphdOuLyoiThmV3MokcsdyGLeYHBnrPAccIcUbr5GxSgbT)2c2NdxRCdA33c2tMY5qKYbT8lLb4JIGNvdbhOz1GsvOeZxfe9oH8oiTBl8vINtq7ucJOvhC2SA4IuI5RcsdyGLeYHBnHvIsf12corc8vJm6Gg(oubN(8c)2mxWN9qWrg)z1qW05WnLdA5xkdWhfbpRgcAzDT0GV3kii6Dc5DqQ755cWlXaYl28vlbxCCW2xK3pp4epNIB5YuVGHSDmDH)25GVLbTKvRbTtjmIwDqyDT0GV3kiinGbwsihU1ewjkvuBl4ejWxnYOdA47qfC6Zl8BZCbF2dbhz8NvdbtNJTuoOLFPmaFue8SAiOL11skvHsmFvq07eY7G6fmKTJPl83oh8TmO1aYnODkHr0QdcRRLUiLy(QG0agyjHC4wtyLOurTTGtKaF1iJoOHVdvWPpVWVnZf8zpeCKXFwnemDoYYuoOLFPmaFue8SAii2mNUca5GlinGbwsihU1ewjkvuBlODkHr0Qds2mNUca5Gl40Nx43M5c(Shcorc8vJm6Gg(oubhz8NvdbtNJSNYbT8lLb4JIGNvdbTyan89AuQsHzj7G0agyjHC4wtyLOurTTG2PegrRoiyan89AUOmlzhC6Zl8BZCbF2dbNib(QrgDqdFhQGJm(ZQHGPZXAkh0YVugGpkcEwneCQhMVDQdIENqEhuVGHSDmDH)25GVPnAvYAq7ucJOvhu4H5BN6G0agyjHC4wtyLOurTTGtKaF1iJoOHVdvWPpVWVnZf8zpeCKXFwnemDoLs5Gw(LYa8rrWZQHGdsm4BbVsvJlh9Quvzwd6GO3jK3bxFlOdxWdAbqkdBbTtjmIwDqJyW3c(l9YrVxnRbDqAadSKqoCRjSsuQO2wWjsGVAKrh0W3Hk40Nx43M5c(ShcoY4pRgcMohznLdA5xkdWhfbpRgcoibhP(fphLQuWmDq07eY7Gu3ZZfYzda4UyZxTeCPxWq2oMU4wUmPUNNliBMtxbGCWvClxMRVf0Hl4bTaiPnBbTtjmIwDqJGJu)INZffZ0bPbmWsc5WTMWkrPIABbNib(QrgDqdFhQGtFEHFBMl4ZEi4iJ)SAiy6CgWuoOLFPmaFue8SAi4Gw6RsvkUDKDq07eY7G8SUy2SA4IuI5RkCGEfpPm8lzF1cnitpJz4zdWF5G13bTtjmIwDqZsFVOUDKDqAadSKqoCRjSsuQO2wWjsGVAKrh0W3Hk40Nx43M5c(ShcoY4pRgcMohI6uoOLFPmaFue8SAi4aDmYwPkuI5RcIENqEhK6EEUq4H5BN6IB5YC4H1lyiBhtx4VDo4BzqlU1djlKfu3ZZfcpmF7ux4a9kEsAByIczx2qkhmMlPLSbzd198CHWdZ3o1fK96RODigAOG2PegrRo4SJr2xKsmFvqAadSKqoCRjSsuQO2wWjsGVAKrh0W3Hk40Nx43M5c(ShcoY4pRgcMohcIuoOLFPmaFue8SAi4anRguQcLy(kLQgMyOGO3jK3b1lyiBhtx4VDo4BzqlU1YK6EEUamGg(EnxZm)nzXTCz6GzhqkTugiODkHr0QdoBwnCrkX8vbPbmWsc5WTMWkrPIABbNib(QrgDqdFhQGtFEHFBMl4ZEi4iJ)SAiy6Ci4MYbT8lLb4JIGO3jK3bPUNNleEy(2PU4wEq7ucJOvhC2Xi7lsjMVk40Nx43M5c(ShcoYOlEobjcEwneCGogzRufkX8vkvnmXqbT74qguZOlEo0IiinGbwsihU1ewjkvuBl4ejWxnYOdA47Oi4iJ)SAiy6CiSLYbT8lLb4JIGNvdbTSUwsPkuI5RuQAyIHcIENqEhuVGHSDmDH)25GVLbTKvRbTtjmIwDqyDT0fPeZxfKgWaljKd3AcReLkQTfCIe4Rgz0bn8DOco95f(TzUGp7HGJm(ZQHGPZHqwMYbT8lLb4JIGNvdblZAqRu14s2GtDq07eY7Gu3ZZfoGK977HRM1GUWb6v8K0grDq7ucJOvhSznOV0lzdo1bPbmWsc5WTMWkrPIABbNib(QrgDqdFhQGtFEHFBMl4ZEi4iJ)SAiy6CiK9uoOLFPmaFue8SAiOL11sd(ERaLQgMyOGO3jK3bPUNNlaVediVyZxTeCXXbBFrE)8Gt8CkULh0oLWiA1bH11sd(ERGG0agyjHC4wtyLOurTTGtKaF1iJoOHVdvWPpVWVnZf8zpeCKXFwnemDoewt5Gw(LYa8rrWZQHGdsWrQFXZrPkfmtRu1Wedfe9oH8oi198CHC2aaUl28vlbx6fmKTJPlULlZ13c6Wf8GwaK0MTG2PegrRoOrWrQFXZ5IIz6G0agyjHC4wtyLOurTTGtKaF1iJoOHVdvWPpVWVnZf8zpeCKXFwnemDoeLs5Gw(LYa8rrWZQHGtKwXRu1GeCK6x8CcIENqEhC9TGoCbpOfaPmiK56BbD4cEqlaszqe0oLWiA1b9sR4Vmcos9lEobPbmWsc5WTMWkrPIABbNib(QrgDqdFhQGtFEHFBMl4ZEi4iJ)SAiy6CiK1uoOLFPmaFue8SAi4GeCK6x8CuQsbZ0kvnm3HcsdyGLeYHBnHvIsf12cANsyeT6GgbhP(fpNlkMPdo95f(TzUGp7HGtKaF1iJoOHVdvWrg)z1qW05qmGPCql)sza(Oii6Dc5Dqhm7asPLYabTtjmIwDWzZQHlsjMVk40Nx43M5c(ShcoYOlEobjcEwneCGMvdkvHsmFLsvdZDOG2DCidQz0fphAreKgWaljKd3AcReLkQTfCIe4Rgz0bn8DueCKXFwnemDoCRt5Gw(LYa8rrq7ucJOvhewxlDrkX8vbN(8c)2mxWN9qWrgDXZjirWZQHGwwxlPufkX8vkvnm3HcA3XHmOMrx8COfrqAadSKqoCRjSsuQO2wWjsGVAKrh0W3rrWrg)z1qW05WLiLdA5xkdWhfbTtjmIwDWzZQHlsjMVk40Nx43M5c(ShcoYOlEobjcEwneCGMvdkvHsmFLsvdBBOG2DCidQz0fphAreKgWaljKd3AcReLkQTfCIe4Rgz0bn8DueCKXFwnemD6GO3jK3btNaa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170111.3, [[dWZthaGEIc1MKqTlPY2eH9rusZeK0Sr1nLONJu3MKdlStPSxQDRy)IOFsuqdtunoIc5BIuNxQQbtQA4GuhKuCkII6yi5CGezHi0sLuwmOwoIEOi5PqlJiTosL0ejkWujLMSsnDGlsuDAuUSQRlbBKOiVgbBMuX2LKpdIhRKPjH08Kq8xI4zsQgTO8DqI6KsvoePsDnIsCpqc)MWXjk1OivInL1Au(eW8VnrJTqDJitLkPE58R(acUUMuVgzOCJYGRtuGdmrJ1o)b9DtAov6CkkQoPgrO)IfCMmoamX4M0esnQzbyIH2ADJYAnkFcy(3MOXwOUreiive(H(KgRD(d67M0CQeuP7YRBudmJZa9nsdeKkc)qFsJ9MnBfabPXrm3yQSViukQU6dWWglf7wOUrdCtQ1Au(eW8VnrJTqDJAOxF2XSUrCrYGgyeiGaH)ULqW3cO8qBudmJZa9ng0Rp7yw3yTZFqF3KMtLGkDxEDJPY(IqPO6QpadBS3SzRaiinoI5glf7wOUrdCRU1Au(eW8VnrJTqDJqLj7cSDs9LbevKuVwb4kJ1o)b9DtAovcQ0D51nQbMXzG(g5mzxGTLOciQqcqaUYyVzZwbqqACeZnMk7lcLIQR(amSXsXUfQB0a3kQ1Au(eW8VnrJTqDJYepupPEmtSiyexKmObgJfGvDjFUID6Iu0IvX50asHQBvGK8dqwHcP5fRBqW)a64mizGHnqKqk2DFcy(3g1aZ4mqFJ6Wd1LqNjwemw78h03nP5ujOs3Lx3yQSViukQU6dWWg7nB2kacsJJyUXsXUfQB0a3KfR1O8jG5FBIgBH6gLhKGmzxiiCJ1o)b9DtAovcQ0D51nQbMXzG(gFqcYKDHGWn2B2SvaeKghXCJPY(IqPO6QpadBSuSBH6gnWTewRr5taZ)2en2c1nc1OksQNybsAGrCrYGgyClaD6Wd1LqNjwe6iVkydTSUcAGeat9IHlOJoD8OkKqxGeY7kaDX6ge8pGoodsgyydejKID3NaM)DXXcWQUKpxXoDrkQrnWmod03ipQcjWfiPbgRD(d67M0CQeuP7YRBmv2xekfvx9byyJ9MnBfabPXrm3yPy3c1nAGBPTwJYNaM)TjASfQBuo)QpGGNuprEqdmIlsg0aJ6ge8pGoodsgyydejKID3NaM)DXXcWQUKpxXoDrKfJAGzCgOVXZV6di4sG5bnWyTZFqF3KMtLGkDxEDJPY(IqPO6QpadBS3SzRaiinoI5glf7wOUrdCtgzTgLpbm)Bt0ylu3iuJQiPEIpugRD(d67M0CQeuP7YRBudmJZa9nYJQqc8dLXEZMTcGG04iMBmv2xekfvx9byyJLIDlu3ObUbLSwJYNaM)TjASfQBmvwWMK6HkdsgyydeJ1o)b9DtAovcQ0D51nQbMXzG(gxzbBKWzqYadBGyS3SzRaiinoI5gtL9fHsr1vFag2yPy3c1nAGBu5wRr5taZ)2enQbMXzG(g5rvibUajnWyVzZwbqqACeZnwkQydeJugBH6gHAufj1tSajniPEDHsMnQHecTrLOInqGckJ1o)b9DtAovcQ0D51nMk7lcLIQR(amrJLIDlu3ObUrrzTgLpbm)Bt0iUizqdmsEDipDwaZVrnWmod03Oo8qDj0zIfbJ9MnBfabPXrm3yPOInqmszSfQBuM4H6j1JzIfHK61fkz2Ogsi0gvIk2abkOmw78h03nP5ujOs3Lx3yQSViukQU6dWenwk2TqDJgyGrCrYGgy0aB]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170111.3, [[d0ZRpaGEisvBIIyxezBuv2hvQMjvkMnLMpej3ecpMu3MKdlStiTxPDRy)urJIQOHjQghuv13uHUhuvgmvy4ivhKQQtrv4yi5CqKYcPOwkuPfdLLlYdHOEkQLruwhfPQjcrQmvvWKvvtxPlsL8kksLldUUOSrOQYPjSzvY2rk)vL67uKmnicnpQu65QYHOiLrtHNrv6Kqv(mr11Gi48qfVwf9BehhIOlvpu21eyw4xZLrdfuMfkKD6WLfuWSH1070XtmYTGthXtxgPdUIm7wZLXfSq8GIklN6yoffLKSYmDqlcRaPpwbzkQmFYk7xVcY86HIs1dLDnbMf(1Cz0qbL9)0W8JrdLzDsqFlVe5YTGKMqSFIPMNjE(jR0LnuW9ZGOpLsGkeZZDSSRlP4PH5hJgK(zPyfKXepxHcChF(YrkKcl76scZsiFB2BLYO7HjAcX(jMAKSbT4gll9wPeOcX8Cp3etdl76s6TKK6ea6qskJUhL9JjSIfNYXtdZpgnugxWcXdkQSCkFuhLY9wgzdqFIGqduWSfRmEZxOJLKkpKbkJG8rdfuUBrL1dLDnbMf(1Cz0qbLXpBOaNoydI(SmRtc6BztBf6tXiVSFmHvS4u(Ygk4(zq0NLXfSq8GIklNYh1rPCVLr2a0Nii0afmBXkJ38f6yjPYdzGYiiF0qbL7wuV9qzxtGzHFnxgnuqz8ZgkWPd2GOpD6WtkpkZ6KG(wwfG9TjIssNLsWSUJpz5MKaviMNBXhw21Lu80W8Jrds)SuScYyIMqSFIPgP4PH5hJgKsGkeZZ0HLDDjfpnm)y0G0plfRGmUfF)SuScYu2pMWkwCkFzdfC)mi6ZY4cwiEqrLLt5J6OuU3YiBa6teeAGcMTyLXB(cDSKu5HmqzeKpAOGYDlksShk7Acml8R5YOHck7ksRbsMfNqzwNe03YyzxxsG2GaVBY19Aa3YtqS3VS5djXixkJUjMgw21Lu80W8Jrdsz0nrfG9TjIssNLsWSUJp83xz)ycRyXPmeP1ajZItOmUGfIhuuz5u(OokL7TmYgG(ebHgOGzlwz8MVqhljvEidugb5JgkOC3IIe6HYUMaZc)AUmAOGYUI0A40bBq0NLzDsqFlRcW(2erjPZsjyw3XhstMjMgw21Lu80W8Jrdsz0l7htyfloLHiTg3pdI(SmUGfIhuuz5u(OokL7TmYgG(ebHgOGzlwz8MVqhljvEidugb5JgkOC3I6Rhk7Acml8R5YOHckZljPobGoKkJlyH4bfvwoLpQJs5El7htyfloLFljPobGoKkJ38f6yjPYdzGYiBa6teeAGcMTyLrq(OHck3TOh7HYUMaZc)AUmAOGYUSGcMnSoDy2gVTmUGfIhuuz5u(OokL7TSFmHvS4ugSGcMnS3y24TLXB(cDSKu5HmqzKna9jccnqbZwSYiiF0qbL7wu8Vhk7Acml8R5YOHck7gbsMj(oDGiKRcNooqwqvM1jb9TCOxbn4ggqjGN7El7htyfloLTcKmt8VvHCvCVKfuLXfSq8GIklNYh1rPCVLr2a0Nii0afmBXkJ38f6yjPYdzGYiiF0qbL7wuKwpu21eyw4xZLrdfu2nc5g7ig5oDyMy3YSojOVLXYUUKOtmfKUjx3RbCRcW(2erjLr3eSSRlP3ssQtaOdjPm6Me6vqdUHbuc45wVL9JjSIfNYwHCJDeJ8BmIDlJlyH4bfvwoLpQJs5ElJSbOprqObky2IvgV5l0XssLhYaLrq(OHck3TOu59qzxtGzHFnxgnuqz3e0cNomNLEBzwNe03YFYkDzdfC)mi6tPeOcX8CxhV9EfkWep1eI9tm1CNGqVifsHLDDjfpnm)y0GugDpk7htyfloLTbT4gll92Y4cwiEqrLLt5J6OuU3YiBa6teeAGcMTyLXB(cDSKu5HmqzeKpAOGYDlkfvpu21eyw4xZLrdfug)SHcC6Gni6tNo8uMhLzDsqFlRcW(2erjPZsjyw3XNSCtWYUUKalOGzd79frN9KYOx2pMWkwCkFzdfC)mi6ZY4cwiEqrLLt5J6OuU3YiBa6teeAGcMTyLXB(cDSKu5HmqzeKpAOGYDlkLSEOSRjWSWVMlJgkOSRiTgoDWge9PthEs5rzwNe03YQaSVnrus6SucM1D8H)(k7htyfloLHiTg3pdI(SmUGfIhuuz5u(OokL7TmYgG(ebHgOGzlwz8MVqhljvEidugb5JgkOC3Is5Thk7Acml8R5YOHckFGSGYPdeXBHeoLzDsqFlJLDDjLGhzIrd3lzbLucuHyEULkhPqkpXYUUKsWJmXOH7LSGskbQqmp36jw21Lu80W8Jrds)SuScYy60eI9tm1ifpnm)y0GucuHyEEyIMqSFIPgP4PH5hJgKsGkeZZTuibpk7htyfloLxYcQBv8wiHtzCblepOOYYP8rDuk3BzKna9jccnqbZwSY4nFHowsQ8qgOmcYhnuq5UfLcj2dLDnbMf(1Cz0qbLDfP1ajZItWPdpP8OmRtc6BzSSRljqBqG3n56EnGB5ji27x28HKyKlLrVSFmHvS4ugI0AGKzXjugxWcXdkQSCkFuhLY9wgzdqFIGqduWSfRmEZxOJLKkpKbkJG8rdfuUBrPqc9qzxtGzHFnxgnuqz3e0cNomdHQmRtc6B5qVcAWnmGsap3Pmj0RGgCddOeWZDQY(XewXItzBqlUXGqvgxWcXdkQSCkFuhLY9wgzdqFIGqduWSfRmEZxOJLKkpKbkJG8rdfuUBrP81dLDnbMf(1Cz0qbLDJqUXoIrUthMj21PdpP8OmRtc6BzSSRlj6etbPBY19Aa3QaSVnrusz0nj0RGgCddOeWZTEl7htyfloLTc5g7ig53ye7wgxWcXdkQSCkFuhLY9wgzdqFIGqduWSfRmEZxOJLKkpKbkJG8rdfuUBrPo2dLDnbMf(1Cz0qbLr2ieJthUri3yhXiVmRtc6B5qVcAWnmGsap3Pmj0RGgCddOeWZDQY(XewXItzTriMBRqUXoIrEzCblepOOYYP8rDuk3BzKna9jccnqbZwSY4nFHowsQ8qgOmcYhnuq5UfLc)7HYUMaZc)AUmAOGYUri3yhXi3PdZe760HNY8OmUGfIhuuz5u(OokL7TSFmHvS4u2kKBSJyKFJrSBz8MVqhljvEidugzdqFIGqduWSfRmcYhnuq5UfLcP1dLDnbMf(1CzwNe03Yj4kbpJaZcL9JjSIfNYx2qb3pdI(SmEZxOJLKkpKbkJGqtmYltvgnuqz8ZgkWPd2GOpD6WtVEu2Fs(RSIqtmYXhvzCblepOOYYP8rDuk3BzKna9jccnqbZwZLrq(OHck3TOYY7HYUMaZc)AUSFmHvS4ugI0AC)mi6ZY4nFHowsQ8qgOmccnXiVmvz0qbLDfP1WPd2GOpD6WtzEu2Fs(RSIqtmYXhvzCblepOOYYP8rDuk3BzKna9jccnqbZwZLrq(OHck3TOYO6HYUMaZc)AUSFmHvS4u(Ygk4(zq0NLXB(cDSKu5HmqzeeAIrEzQYOHckJF2qboDWge9PthEIe9OS)K8xzfHMyKJpQY4cwiEqrLLt5J6OuU3YiBa6teeAGcMTMlJG8rdfuUB3YSojOVL72c]] )

    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170111.3, [[dauSDaqiPewerfAtqsJcsCkLQEfukyxqmmQ0XOOLrKEgvyAOuCnOuABkfFtPY4iQKZrurRJOcyEOu6EqPAFevDqOWcLs9qLstKOc6IqrBKOsnsOuiNeQQzkLOBIs2jkgkrfOLcL8ustfQYxHsr7v1FHudgLQdlSyfESsMmLUmyZsLplvnAP40i9Ak0SjCBQA3s(nIHtuwoQEUIMUORdv2of8DPKopv06HsHA(er7Ni8npExXSIHaSV9vMWdxvQFReSJz1e1c8qLYbKGDl0f4e5v5qOlWjY3(kwGaIjCgPUM7CnnnrKEvxCQS86vmwjLuZJ3zmpExXSIHaSV9vDXPYYRjPVxai0kbohNSCELj8WvSjTSsWU2ab)k(LLUIKWVwKcUIXGkOPZRTsll6zde8RBBGLrwedGhQ8JRybciMWzK6AUXChIRJRSiwMWdxFEgPhVRywXqa2pUQlovwEnj99cazriclP1AIkkzW7HePbcr2GiBLSvk2kPKj1dY7IGTUU7VYeE4k2iGtOt)v8llDfjHFTifCfJbvqtNxhccXkWnZRBBGLrwedGhQ8JRybciMWzK6AUXChIRJRSiwMWdxFEghhVRywXqa23(QU4uz51K03laKfHiSKwRjQO0IGN0UyLiHqwtGUvIOdHhLr5DLusu8biMjN4rw44COs5XUuxuxeIWsATqw8y2Gwq7BYIw9iCWh0AYwS3VS73FLj8Wv5g4Hqc2vzuonVIFzPRij8RfPGRymOcA68AhWdb6PmkNMx32alJSigapu5hxXceqmHZi11CJ5oexhxzrSmHhU(8mS54DfZkgcW(2x1fNklVg8K2fRejeYAc0TseDi8OmkVlQY4Gb09llIjshWdb6PmkNMxzcpCDlpMnsWElP9nzrR(R4xw6ksc)Ark4kgdQGMoVU4XSbTG23KfT6VUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zW2J3vmRyia7BFvxCQS8As67faYIqewsR1evug466qI5ckBulabNmjLSfziGkrI5ckBulabQyiaRKskadGGTMUU7VYeE4ABGpbUrA1Ff)Ysxrs4xlsbxXyqf0051bWNa3iT6VUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95z2C8UIzfdbyF7R6ItLLxtsFVaqweIWsATMxzcpCTTGqSsWUCJJ78k(LLUIKWVwKcUIXGkOPZRdbHyr3HJ7862gyzKfXa4Hk)4kwGaIjCgPUMBm3H464klILj8W1NNz3X7kMvmeG9TVQlovwEnj99cargjPKAIkkDapeONYOCAIWbFqRP8yRKsMbVhsKK6b0jbTLcSf7BC3FfJbvqtNxLrskPUIFzPRij8RfPGRmHhUkhKKusDfdE)8AfEa7YrzCIGu9GfTmsRaxoEflqaXeoJuxZnM7qCDCDBdSmYIya8qLFCLfXYeE4QCugNiivpyrlJ0kWLJppJCD8UIzfdbyF7R6ItLLxh466qgeCclW7OZeHd(Gwt22VSskjk(aeZKt8ilCCoujBXo26IASsQbanuGNct5XUJ9xzcpCTnbNWc8o6mVIFzPRij8RfPGRymOcA686GGtybEhDMx32alJSigapu5hxXceqmHZi11CJ5oexhxzrSmHhU(8mY5X7kMvmeG9TVQlovwEDGRRdzqWjSaVJoteo4dAnzB)YkPKOSAcEpmr3XJvsjviK3ezh2IQpaXm5epYchNdvYwSpHmPv)ezqWjSaVJot0(aeZKt8OgRKAaqdf4PWKTyx6(RmHhU2MGtybEhDMsWokM7VIFzPRij8RfPGRymOcA686GGtybEhDMx32alJSigapu5hxXceqmHZi11CJ5oexhxzrSmHhU(8mMUhVRywXqa23(QU4uz51meqLiIOStb1ciqfdbyrDGRRdreLDkOwaHd(Gwt22VSxzcpCflYY4GMa)k(LLUIKWVwKcUIXGkOPZRCYY4GMa)62gyzKfXa4Hk)4kwGaIjCgPUMBm3H464klILj8W1NNX084DfZkgcW(2x1fNklV2IKUmsREu9biMjN4rw44COs5Lk9kt4HRYnoUtjyN0jb7yq5xXVS0vKe(1IuWvmgubnDETdh3jAsh6GYVUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zmLE8UIzfdbyF7R6ItLLxZqavI0euXmjCpcuXqawuh466q64Kzo4rzr4GpO1KTCyGRRdDR0YsA9kt4HRYnNmZbpk7v8llDfjHFTifCfJbvqtNx74Kzo4rzVUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zmDC8UIzfdbyF7R6ItLLxh466q6eHhss1Jdq4GpO1KTCyGRRdDR0YsAvsjrzriclP1cXsiE0Tsl7eHd(Gwt2Ub1bUUoKor4HKu94aeo4dAnzlB2FLj8Wv5weEijvpo4k(LLUIKWVwKcUIXGkOPZRDIWdjP6Xbx32alJSigapu5hxXceqmHZi11CJ5oexhxzrSmHhU(8mMS54DfZkgcW(2xzcpCvoKq8sWo2Kw25vmgubnDE1siE0Tsl78kwGaIjCgPUMBm3H464k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zmX2J3vmRyia7BFvxCQS8AgcOsKfpMn0Qh9mjCpcuXqawuJvsnaOHc8uykp2DGkkTidbujstqfZKW9iqfdbyLuYbUUoKoozMdEuweo4dAnLVFz3FLj8W1T8y2ib7TK23KfT6LGDum3Ff)Ysxrs4xlsbxXyqf0051fpMnOf0(MSOv)1TnWYilIbWdv(XvSabet4msDn3yUdX1Xvwelt4HRppJ5MJ3vmRyia7BFLj8WvmdE2aLeSRYOgHRymOcA68ke8Sbk0tzuJWvSabet4msDn3yUdX1Xv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZyU74DfZkgcW(2x1fNklVIsgcOseIbGVAcEpGavmeGfvFaIzYjEKfoohQuESZgxuBrgcOsKoCCNOjDOdkhbQyia7EjLeLmeqLiedaF1e8EabQyialQziGkr6WXDIM0HoOCeOIHaSO6dqmtoXJSWX5qLYZgxSHosGwwyT0QF)vMWdxBjTVjlA1lb7TjI8k(LLUIKWVwKcUIXGkOPZRcAFtw0Qh9GiYRBBGLrwedGhQ8JRybciMWzK6AUXChIRJRSiwMWdxFEgt564DfZkgcW(2x1fNklVoW11HS4XSbTG23KfT6r4GpO1KT9llQXkPga0qbEkmLh7sVYeE46wEmBKG9ws7BYIw9sWoks3Ff)Ysxrs4xlsbxXyqf0051fpMnOf0(MSOv)1TnWYilIbWdv(XvSabet4msDn3yUdX1Xvwelt4HRppJPCE8UIzfdbyF7RmHhUInPLDsQ(RymOcA68AR0Yojv)vSabet4msDn3yUdX1Xv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZi194DfZkgcW(2x1fNklVMK(EbGSieHL0AnrfLbUUoKzs4(bNw9ahbNS9xzcpCfJ5ckBul4k(LLUIKWVwKcUIXGkOPZRXCbLnQfCDBdSmYIya8qLFCflqaXeoJuxZnM7qCDCLfXYeE46ZZi184DfZkgcW(2x1fNklVoW11Hmtc3p40Qh4i4KHkkOKHaQePdh3jAsh6GYrGkgcWIQpaXm5epYchNdvkp2L6In0rc0YcRLw97LusuArgcOsKoCCNOjDOdkhbQyia7(9xzcpCfBsl7m5uJWv8llDfjHFTifCfJbvqtNxBLw2zYPgHRBBGLrwedGhQ8JRybciMWzK6AUXChIRJRSiwMWdxFEgPspExXSIHaSV9vDXPYYRdCDDiZKW9doT6bocozOIckziGkr6WXDIM0HoOCeOIHaSO6dqmtoXJSWX5qLYJDPUydDKaTSWAPv)EjLeLwKHaQePdh3jAsh6GYrGkgcWUF)vMWdx1KW9ZKtncxXVS0vKe(1IuWvmgubnDEDMeUFMCQr462gyzKfXa4Hk)4kwGaIjCgPUMBm3H464klILj8W1NNrQJJ3vmRyia7BFvxCQS8AgcOsKgsIUjklcuXqawuh466qAij6MOSi4KDLj8W1wggcjyVLXS5k(LLUIKWVwKcUIXGkOPZRIWqGweZMRBBGLrwedGhQ8JRybciMWzK6AUXChIRJRSiwMWdxFEgPS54DfZkgcW(2x1fNklVgRKAaqdf4PWuESZMRmHhUULhZgjyVL0(MSOvVeSJIJ9xXVS0vKe(1IuWvmgubnDEDXJzdAbTVjlA1FDBdSmYIya8qLFCflqaXeoJuxZnM7qCDCLfXYeE46ZZifBpExXSIHaSV9vMWdxXM0Yoto1iib7OyU)kgdQGMoV2kTSZKtncxXceqmHZi11CJ5oexhxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJ0nhVRywXqa23(QU4uz51meqLiedaF1e8EabQyialQlcryjTwicAFtw0Qh9Giseo4dAnzB)YIQpaXm5epYchNdvkVC5ELj8WvnjC)m5uJGeSJI5(R4xw6ksc)Ark4kgdQGMoVotc3pto1iCDBdSmYIya8qLFCflqaXeoJuxZnM7qCDCLfXYeE46ZZiD3X7kMvmeG9TVQlovwEndbujshoUt0Ko0bLJavmeGfvFaIzYjEKfoohQuE24In0rc0YcRLw9OIYIqewsRfIG23KfT6rpiIeHd(Gwt57xwjLSfziGkriga(Qj49acuXqa29xzcpCvtc3pto1iib7OiD)v8llDfjHFTifCfJbvqtNxNjH7NjNAeUUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zKkxhVRywXqa23(QU4uz51wKHaQeHya4RMG3diqfdbyrTfziGkr6WXDIM0HoOCeOIHaSxzcpCvtc3pto1iib7O4y)v8llDfjHFTifCfJbvqtNxNjH7NjNAeUUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zKkNhVRywXqa23(QU4uz5vuqjwj1aGgkWtHP8MskzgcOsKfpMn0Qh9mjCpcuXqawjLmdbujYGGtybEhDMiqfdby3JAlMqIEqkCtKKcCt5enBKTK3DVKs2b8qGEkJYPjch8bTMYJTxXyqf0051fpMnOf0(MSOv)v8llDfjHFTifCLj8W1T8y2ib7TK23KfT6LGDuyZ(RybciMWzK6AUXChIRJRAdPvwelTJc85BFDBdSmYIya8qLFCLfXYeE46ZZ4W94DfZkgcW(2x1fNklVMHaQePjOIzs4EeOIHaSOoW11H0XjZCWJYIWbFqRjBzdICDLj8Wv5MtM5GhLvc2rXC)v8llDfjHFTifCfJbvqtNx74Kzo4rzVUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zCyE8UIzfdbyF7R6ItLLxZqavI0HJ7enPdDq5iqfdbyrndbujcXaWxnbVhqGkgcWIkktirpifUjssbUPCIMnYwY7IQpaXm5epYchNdvkp2Ll39xzcpCTLHHqc2BzmBKGDum3Ff)Ysxrs4xlsbxXyqf005vryiqlIzZ1TnWYilIbWdv(XvSabet4msDn3yUdX1Xvwelt4HRppJdPhVRywXqa23(QU4uz51meqLiD44ort6qhuocuXqawuBrgcOseIbGVAcEpGavmeGfvuMqIEqkCtKKcCt5enBKTK3fvFaIzYjEKfoohQuESJTo2FLj8W1wggcjyVLXSrc2rr6(R4xw6ksc)Ark4kgdQGMoVkcdbArmBUUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zC444DfZkgcW(2x1fNklVIslMqIEqkCtKKcCt5enBKTK3fvFaIzYjEKfoohQuESpHmPv)eregc0Iy2G2hGyMCIFVKsIslYqavI0HJ7enPdDq5iqfdbyrDcj6bPWnrskWnLt0Sr2sExu9biMjN4rw44COs5XoBC3FLj8W1wggcjyVLXSrc2rXX(R4xw6ksc)Ark4kgdQGMoVkcdbArmBUUTbwgzrmaEOYpUIfiGycNrQR5gZDiUoUYIyzcpC95zCWMJ3vmRyia7BFvxCQS86axxhsNi8qsQECach8bTMSLniY1vMWdxLBr4HKu94ajyhfZ9xXVS0vKe(1IuWvmgubnDETteEijvpo462gyzKfXa4Hk)4kwGaIjCgPUMBm3H464klILj8W1NNXb2E8UIzfdbyF7RmHhUQ4klWPv)vmgubnDEDIRSaNw9xXceqmHZi11CJ5oexhxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJJnhVRywXqa23(kt4HRyrwgh0e4sWokM7VIXGkOPZRCYY4GMa)kwGaIjCgPUMBm3H464k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zCS74DfZkgcW(2xzcpCvUfHhss1JdKGDuKU)kgdQGMoV2jcpKKQhhCflqaXeoJuxZnM7qCDCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8moKRJ3vmRyia7BFLj8W12eCclW7OZuc2rr6(RymOcA686GGtybEhDMxXceqmHZi11CJ5oexhxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRpFEvLblAiOyJJKsQZiDJJN)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170111.3, [[dedXbaGEukTlc12ePMPcLzt0njWTvQDQK9sTBH9lcdtb)wYqrj1GfjdxvDqc6yqSquLLkkTysSCv5HKupf8yiTousMikrtLqMSIMUuxKKCzKRJsXMvOA7OchgQNtQ(mk(oQKLjQopQOrtklcv1jrP6BIItRY9qj8xfYZerVgvQnIfzqvGvK008mSWBYaCB1jsPk0WbkTPOzvIu)hHwBfCBGL04y2iBZZqwssyDYR8bKmdiiiIZnaOV73gmieTVk0TiVqSidQcSIKMMNba9D)2qxmmss8V6RcDdcvo51CA4x9vHb2J5HI76ziQGmSWBYaRR(QWGWhJUHaVjwW))kzfm0C0V4IE8nKLKewN8kFajnsgXdjnOwJq5wqXbTPOTIbb1CH3Kb()xjRGHMJ(fx0JVBVYTidQcSIKMMNHfEtgg7y064cMePaTJKtdcvo51CAqEmADCbZiDTJKtdzjjH1jVYhqsJKr8qsdShZdf31ZqubzqTgHYTGIdAtrBfdcQ5cVjdUDBa(e6HLhBX9vHx5Pt62ga]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170111.3, [[d8JVkaWykTEufQnHa7cOTjLAFOkntuvCyrZgP5tvCtQs8nfYTbCEHQDsI9QA3kTFfQrPOmmQ04qviNg0qjPQAWkIHlKdkuoLI0XiLJJQGfsswQIQfJklNIhIQOwfjvLLHqpxWePkvAQuvnzenDjxKu5zKQUm01LInIQiVwkzZky7uvwevPQNs8zPQVtszAuL08OkLrlvgpvPItIGoeQkDnsQCpuvDosQYVr5VuXx7(VOBtoksEvxusa8IOJpJNOJIa4wjD8KyblUK5AXlseAHjfYJZcY2RqSnXlZrkMb8keD1g5QPPbs8IynWO6YLy2cY2W9FfT7)IUn5Oi5vDrSgyuDPy99ue0YyusMAB4YCKIzaVcrxT2AJaD1FHWLeAZIzUSSfVeJdsHv8ldqd6Guea3kPxusa8cpbn44j6OiaUvsFDfI3)fDBYrrYR6IscGxu)ScY2lI1aJQlfRVNIGrScY2abZkiaYVRhpZkwFpfbTmgLKP2giyMLXOKm1wWbObDqkcGBLuqdcKWnWlrV66XJLXOKm1wWbObDqkcGBLuqdcKWnWV7ucMzzmkjtTfmdwCjZ1IGgeiHBWBEvDE8W1mmaMblUK5ArWMOPtNEzosXmGxHORwBTrGU6Vq4scTzXmxw2IxIXbPWk(Liwbz7fVWivsa8I3hzyu22JKorm1qJ3)6k6V)l62KJIKx1fXAGr1LI13trqlJrjzQTbcMrICnddGd0eaDcDmBlqdcKWnWl)AQZJN0wqFOdUiaed8QFkbZ4laZhC794HRzyaKM(sNqJPhbBIMEjghKcR4xYGfxYCT4fcxsOnlM5YYw8IscGxIfS4sMRfVeZ0hUCzosXmGxHORwBTrGU6ViDm18cJeoart4QUWZDOTLxy(qaCRZ96kE9(VOBtoksEvx8s6DGana(ttpwHl6ViwdmQUW3cABb3EpEMzqGeUbVXV6raqI0qzyaG2gJb3Ix(j6saxZWaisraCRK6mWSnbWMOPxIXbPWk(LbAcGoHoMT1fcxsOnlM5YYw8IscGx4jAcGJNiDmBRl8CClf9NMEScN7YCKIzaVcrxT2AJaD1Fr6yQ5fgjCaIMWv96kQ7(VOBtoksEvxeRbgvxML2c6dDWfbGyGFIeK2c6dDizf4anbqNqhZ2YBeN6XZS0wqFOdUiaed8YVEcsBb9HoKScCGMaOtOJzB5n9tVeJdsHv8ld0eaDcDmBRleUKqBwmZfBClfVmhPygWRq0vRT2iqx9xusa8cprtaC8ePJzBnEYmItFDL23)fDBYrrYR6IynWO6YL5ifZaEfIUAT1gb6Q)cHlj0MfZCzzlEjghKcR4xqkcGBLuhoAgQlkjaErhfbWTs64jQOzOEDLr3)fDBYrrYR6IynWO6sAlOp0bxeaIbE53RE8mlTf0h6GlcaXaV8RNGz8f5HgyuescI2oggCydovh60BWSCcnljAGBVhpHklWUmuiVUGQZD6upEMXxKhAGrrijy1HoKOfH(qtWHJYyKorPTiiuzb2LHc51fuDUtVmhPygWRq0vRT2iqx9xiCjH2SyMllBXlX4Guyf)cMMQJhAYw4fLeaVOlnvhp0KTWxxHhD)x0TjhfjVQlI1aJQlajsdLHbaABmgClE5x9iEzosXmGxHORwBTrGU6Vq4scTzXmxw2IxIXbPWk(fmnvNtOJzBDrjbWl6st1nEI0XSTEDf17(VOBtoksEvxeRbgvx4AggaJyQHgh2Gt1HoajsdLHba2erGLXOKm1wqA6lD4AmHc02LMEm4nIxMJumd4vi6Q1wBeOR(leUKqBwmZLLT4LyCqkSIFHc77QfU9oCmADrjbWl8b23vlC7hprfJwVUIM79Fr3MCuK8QUiwdmQUaKinuggaOTXyWT4LFEuBc4lxZWain9LoHgtpc2eDzosXmGxHORwBTrGU6Vq4scTzXmxw2IxIXbPWk(fmnvNtOJzBDrjbWl6st1nEI0XSTgpzM20xxrt7(VOBtoksEvxeRbgvxkwFpfbttbhsB5KCqkSIFzosXmGxHORwBTrGU6Vq4scTzXmxw2IxIXbPWk(LqXmaTqmcnxusa8IumdqleJqZRROr8(VOBtoksEvxeRbgvx4AggaPPV0j0y6rWMic4AggadfZa0cXi0aAqGeUbE5AggadfZaWzGBpAaTSMTuF9wYlZrkMb8keD1ARnc0v)fcxsOnlM5YYw8smoifwXVqtFPdxJjuxusa8cFsF54jQAmH61v00F)x0TjhfjVQlI1aJQlxMJumd4vi6Q1wBeOR(leUKqBwmZLLT4LyCqkSIFHM(shUgtOUOKa4f(K(YXtu1yc14jZ0M(6kAE9(VOBtoksEvxeRbgvxsBb9Ho4IaqmWl)ejGVCnddGrm1qJdBWP6qhGePHYWaaBIUmhPygWRq0vRT2iqx9xiCjH2SyMllBXlX4Guyf)ITlHRdf23vlC7VOKa4fEUlH74j8b23vlC7FDfn1D)x0TjhfjVQlI1aJQlxMJumd4vi6Q1wBeOR(leUKqBwmZLLT4LyCqkSIFHc77QfU9oCmADrjbWl8b23vlC7hprfJwJNmtB6Rxx8U4q2qRR61pa]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170111.3, [[dauUlaqiiuweeu2KiXOuHoLkyvqq1Ui0WOOJHWYuPEgLyAIKCniK2gvvFJQ04GqLZrbP5rb6EufTpQchuuAHePhsbXeHGuxKcTrrsDsrQvcbjZKc4MuqTtcgkeQAPsINIAQIO9Q8xk1GffhwQftupMktgrxgSzi6ZsQrRsoTQETK0Sr62qA3q9BsgUO64qiwoPEUetx46QOTtj9DiW4HGW5jI1dbrZxe2pvLhXso2iULPa5KoMD6ppgpgHgq2N0yshxbOqxGjCBs41KGGq8EmNdUVPpczhVcpHB)3JZ6IxHll5eiwYXgXTmfiN0XSt)5X4qvxtbrNsrjviaxgxbOqxGjCBs4NWROPLXPXKVRdLEmwHHXcnkmo1Vg8LXifqbC00XzLF6hsgJ81GnqbuahnDXeUxYXgXTmfiN0XSt)5X4qvxtbXCv8kCjLJXJcEAMiXXqvxtbrNsrjviaxs5OtPOKkeGfr(AWgOakGJMkQb0(XfpUtLzIeoLIsQqawe5RbBGcOaoAQOgq7hx808WHdJfAuymIxfVcpUcqHUat42KWpHxrtlJtJjFxhk9yScdJZk)0pKmoxfVcp2WksHgfgJWY1kQcxdK25keaAe2IjyzjhBe3YuGCshZo9NhJpgpkyWAhjc)oLCny1U2rksiI81Gnqbuahn9qIehJhfmyTJmfelxdwTRDKIeI02ABlFQlXHXzLF6hsgtBRTT8PUeJtJjFxhk9yScdJfAuySbARTVmsp1LWxMJMhgxbOqxGjCBs4NWROPLftivl5yJ4wMcKt6yd3iep6jAYwxdrzSLXSt)5XyelEx1hxNiXrnG2pUyqpn0uqBGwcTcv0DQ1ao8WZBZuKprIueOakGJMAJu5olIN5hgNv(PFizmsAJc2LlLR640yY31HspgRWWyHgfgNAAJc(YWxkx1XgIehfs26AiktECfGcDbMWTjHFcVIMwgZxkeyyf5J8bDzsxmbeDjhBe3YuGCshZo9NhJJhfmyTJeHNQXzLF6hsg)oa5PwY40yY31HspgRWW4kaf6cmHBtc)eEfnTmwOrHXPDaYtTeFzoAEyXe8VKJnIBzkqoPJzN(ZJXhBx8wbBadOpu88oL2fVvWMufIiPnkyxUuUQg8(qIehBx8wbBadOpu8WtlP0U4Tc2KQqejTrb7YLYv1GwomoR8t)qYyK0gfSlxkx1XPXKVRdLEStIJcJfAuyCQPnk4ldFPCv9L549HXvak0fyc3Me(j8kAAzXe8UKJnIBzkqoPJzN(ZJXJRauOlWeUnj8t4v00Y40yY31HspgRWWyHgfgBKcOaoAQVmsPDjgNv(PFizmqbuahn1wM2LyXeqCl5yJ4wMcKt6y2P)8yC7I3kydya9HIhEMQejo2U4Tc2agqFO4HNws5iIbiY5NNdKIG7sbfBfs74cSR1qh2LtmjOFCDIeLOdXRUeGhMIiQ5HdjsCeXae58ZZbsX4cSjbh8wbDXwMQuK25TlsPeDiE1La8WuernpmUcqHUat42KWpHxrtlJtJjFxhk9yScdJfAuySXwhxiYzxfgNv(PFizm064cro7QWIjyOl5yJ4wMcKt6y2P)8ymAd0sOvOIUtTgWHhEAO3JRauOlWeUnj8t4v00Y40yY31HspgRWWyHgfgBS1XLVm8LYvDCw5N(HKXqRJl7YLYvDXeimxYXgXTmfiN0XSt)5Xy0gOLqRqfDNAnGdd61VpeQXzLF6hsg)oa5PwY40yY31HspgRWWyHgfgN2bip1sgNvxxgpUcqHUat42KWpHxrtlJ5lfcmSI8r(GUm5XgYf4QAyLvafWXKxmbcILCSrCltbYjDm70FEmoxdwTRDKIeIVdqEQLmUcqHUat42KWpHxrtlJtJjFxhk9yScdJZk)0pKmgPwvc7YLYvDSqJcJtTwvcFz4lLR6IjqCVKJnIBzkqoPJzN(ZJXYNirksBRTD5uxdIN5js4ukkPcbyrABTTLp1Lq0D16AO4594kaf6cmHBtc)eEfnTmonM8DDO0JXkmmwOrHXgOT2(Yi9uxIXzLF6hsgtBRTT8PUelMaHLLCSrCltbYjDm70FEmgTbAj0kur3Pwd4WJBZejKprIu8DaYtTeXZ8Xvak0fyc3Me(j8kAAzCAm576qPhJvyyCw5N(HKXi1QsyxUuUQJfAuyCQ1Qs4ldFPCv9L5iXHftGivl5yJ4wMcKt6yHgfgZHsJwfGCqpoR8t)qY4sO0Ovbih0JtJjFxhk9yScdJzN(ZJXHQUMcIToEKTlSB5N(HKuo2U4Tc2agqFO4brIefiIhxxe76AnukVvWUeknAvaYb9HXvak0fyc3Me(j8kAAzXeiq0LCSrCltbYjDm70FEmECfGcDbMWTjHFcVIMwgNgt(Uou6Xyfggl0OWyd0wBFzKEQlHVmhjomoR8t)qYyABTTLp1LyXei8VKJnIBzkqoPJzN(ZJXYNirkMRqaOTviTJlWgTbAj0kuXZ8Xvak0fyc3Me(j8kAAzCAm576qPhJvyySqJcJnWxFf4hx7lJufn8L5iXHXzLF6hsgt)6Ra)4ABzfnwmbcVl5yJ4wMcKt6y2P)8yC7I3kydya9HIhEEpUcqHUat42KWpHxrtlJtJjFxhk9yScdJZk)0pKm2D1p2M(1xb(X1JfAuySHC1p2xgd81xb(X1lMabIBjhBe3YuGCshl0OWyd81xb(X1(YivrJXvak0fyc3Me(j8kAAzCAm576qPhJvyym70FEmECw5N(HKX0V(kWpU2wwrJflgl0OWy2Ob8LXifqbC0uFzs7aKNAjl2a]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170111.3, [[daKCmaqiavTiavAtKknka5ua0QauHDrIHrjhdfldbpdHMgkrDnuISnQKVjQmosf5COeAEakUhizFOKoOkYcrPEivunraL0fjjBKurDsvuZKkYnrjyNi6NaQOHcOuwQOQNsmvQWEv(lQmysQdlzXKYJfzYG6YqBMu1NPuJwuoTuVgKA2iDBG2TQ(nfdxfoovuwov9CvA6cxheBhv57KkmEaLQZtLA9akX8bW(rv9yMJjQ(sJIWJ9eYceNiQCIVAvuee)OO8v7u(jsY3hXKj5rkwxCKeSyYzXWWOqyICGPUOnWsfT5hjbxeMCkfT5VZXizMJjQ(sJIWJ9ej57JysySTPOsYyOWgD83j5rkwxCKeSyCXKtXI4KZpCNQW4N8MhNCsRPD4EI(2JCifbXpk6eYceNOZTh5RwffbXpk6IrsyoMO6lnkcp2tilqCcWMjAZprs((iMegBBkQCyI28xDbkAqeklaaaOWyBtrLKXqHn64V6cuYyOWgD8k6BpYHuee)OOkEeS6)Ykbw2caasgdf2OJxrF7roKIG4hfvXJGv)xOSaeqaNKhPyDXrsWIXftoflIto)WDQcJFYBECYjTM2H7jhMOn)ewWatwG4eG7H3qnVncZDy0b6bUlgjX5yIQV0Oi8yprs((iMuPO5HC4JGnEzfkItoP10oCpH2odsdZbw2GfxyceCY5hUtvy8tEZJtilqCItTZG0W8vZcLnyXxTdtGGtYJuSU4ijyX4IjNIfXfJKLNJjQ(sJIWJ9ewOa2BqiGokVng3jeNijFFeta(Otq3VnaaaKhbR(VaduSOUGfsVH3aQKG494hScfblD1GOxVcsrq8JIYP3KGCvGCa4KtAnTd3t0tlqK7Mzsqp58d3Pkm(jV5XjKfiorNPfiYxTKzsqpX5Utu0r5TX4oTj5rkwxCKeSyCXKtXI4ejZOdwWa36B0Fh7fJKLMJjQ(sJIWJ9ej57JycqvkAEih(iyJxOiOBLIMhYbBcf90ce5UzMe0adbabaaGQu08qo8rWgVScfrDRu08qoytOONwGi3nZKGgyic4KtAnTd3t0tlqK7Mzsqp58d3Pkm(jj3jkojpsX6IJKGfJlMCkweNqwG4eDMwGiF1sMjbnF1araWfJ01Cmr1xAueESNijFFetQu08qo8rWgVScfrDbc4Hrni61RqB7S473MZBGvGCaaavkAEihSjuOTDw89BZ5nWqvPO5HC4JGnEbCYjTM2H7jPSQFoABNfF)2to)WDQcJFYBECczbItCEw1pF1o12zX3V9K8ifRloscwmUyYPyrCXiZnhtu9LgfHh7jsY3hXKkfnpKdFeSXlRqruxyudIE9k02ol((T58gyfih6wPO5HCWMqH22zX3VnN3admvkAEih(iyJ3jN0AAhUNKYQ(5OTDw89Bp58d3Pkm(jj3jkoHSaXjopR6NVANA7S473MVAGCU7efbCsEKI1fhjblgxm5uSiUyK60Cmr1xAueESNijFFetQu08qo8rWgVqruxni61RqlEf3fI3gvGCm5Kwt7W9eAXR40G4VXKZpCNQW4N8MhNqwG4eNkEfF1SH4VbF1ar0bGtYJuSU4ijyX4IjNIfXfJKfNJjQ(sJIWJ9ej57JysLIMhYHpc24LvOyzaaaOkfnpKdFeSXlRqruxGaE0zq6Jdewbtzg8Yz0ZfziNThRG7c5HrF)2aaWnQqjRUbYQLclzbiGaaaqap6mi9XbcRezihmMWMh6VCAuJbM7OsHU3OcLS6giRwkSKfGtYJuSU4ijyX4IjNIfXjNF4ovHXp5npo5Kwt7W9eS8rMZGuqJtilqCIQYhzodsbnUyKmwZXevFPrr4XEIK89rmjAqeyStWahe09WJ84StWkmk6PfiYDZmjONCsRPD4EcT4vCAq83yY5hUtvy8tEZJtYJuSU4ijyX4IjNIfXjKfioXPIxXxnBi(BWxnqaNh4JEaxmsgM5yIQV0Oi8yprs((iMmjpsX6IJKGfJlMCkweNC(H7ufg)K384KtAnTd3tqkcIFuuonADJjKfiorffbXpkkF1SP1nwmsgcZXevFPrr4XEIK89rmbSq6n8gqLeeVh)GvOyrctYJuSU4ijyX4IjNIfXjNF4ovHXp5npo5Kwt7W9eS8rg3nZKGEczbItuv(iJVAjZKGEXiziohtu9LgfHh7jsY3hXeni61RqlEf3fI3gvGCmjpsX6IJKGfJlMCkweNC(H7ufg)K384KtAnTd3tOfVItdI)gtilqCItfVIVA2q83yXizy55yIQV0Oi8yprs((iMuPO5HC4JGnEzfkIaaWfJOF7RszB7X7T5HC3W4bHgXd0p5Kwt7W9KBy8GqJ4b6NC(H7ufg)K384K8ifRloscwmUyYPyrCczbItKW4bHgXd0VyKmS0Cmr1xAueESNqwG4evLpY4RwYmjO5RgigaNCsRPD4Ecw(iJ7Mzsqp58d3Pkm(jV5Xj5rkwxCKeSyCXKtXI4ej57JycyH0B4nGkjiEp(bRqPtUwmsgxZXevFPrr4XEIK89rmzsEKI1fhjblgxm5uSio58d3Pkm(jV5XjN0AAhUNqlEfNge)nMqwG4eNkEfF1SH4VbF1aXa4IrYKBoMO6lnkcp2tKKVpIjAq0Rx5WOd0Zz0ZfzihyH0B4nGkqoMKhPyDXrsWIXftoflIto)WDQcJFYBECYjTM2H7j02ol((T50m0yczbItCQTZIVFB(QzBObF1aXa4IrYOtZXevFPrr4XEIK89rmPsrZd5WhbB8YkueMKhPyDXrsWIXftoflIto)WDQcJFYBECczbItCEw1pF1o12zX3VnF1aXa4KtAnTd3tszv)C02ol((TxmsgwCoMO6lnkcp2tKKVpIjtYJuSU4ijyX4IjNIfXjNF4ovHXp5npo5Kwt7W9eABNfF)2CAgAmHSaXjo12zX3VnF1Sn0yXIjaRO(ccng7fB]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170111.3, [[d8sidaGELsAxe12ukMjbMnOBcrDBOANQ0EL2nv7xvgfePHPO(nLgmKgof5GkvNsPuhJqluGwQkSyISCv1IOOEkYJf65qzIkatLGMSsMoPlsHlJ66cAZcyAkL47kqTmf5WIgTcKNPGoPc1FvrNg48qyLkG(meX3uixXkSKHNsqE1GLUjoxIme8qnGmo7AcFOdGdKHqTezIJGec2AQaR370MPshmKtmU3PzXrZIIIYtLO4hyslvApQaRJvH9kwHLm8ucYRgSef)atAjPWabKvRY4N4jMYFeYl7G9s7saiqrusTkJFINyk)ruASVaXuT)sU15s3eNlj0Qm(df5et5pIshmKtmU3PzXnIJKNhwT3PkSKHNsqE1GLUjox6i0FO7rfy9hQaaMwIIFGjTKMq2v5elY(k9ilZEkb5vPdgYjg370S4gXrYZdln2xGyQ2Fj36CPDjaeOik9d9ZmQaRFcbyAjKTRBIZLmtgcEOgqgNDnHp0DSi7R0JS5Q9oSclz4PeKxnyPBIZLoc9h6Eubw)HkaGPpuKkUDjk(bM0sAczxLbroq4hHm7PeKxVbw6GHCIX9onlUrCK88WsJ9fiMQ9xYToxAxcabkIs)q)mJkW6NqaMwcz76M4CjZKHGhQbKXzxt4dDCKde(ryUAVBPclz4PeKxnyPBIZLoc9h6Eubw)HkaGPpuKoTDjk(bM0sAczxLHaKmi1boso)2Lm7PeKxLoyiNyCVtZIBehjppS0yFbIPA)LCRZL2LaqGIO0p0pZOcS(jeGPLq2UUjoxYmzi4HAazC21e(qfCyUA1sdGdKHqTbR2c]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170111.3, [[dWdefaGEbyxQI02iqZuvv5WQmBr9BP6MaPNbuDBsDEbANISxLDJ0(P6NquggHgNQqCAedLidMYWfYbvLoQa6yGCovH0cbklfszXc1YLYdb4POwgjSovrnrcyQaAYqKPd1ff0vvfWLLCDqTrivFdIQnRQY2HKpQkuFgctJe13vfXivfupMKgTQY4jroPQQClI6AaX9ufONtqRvvv1RvfKh0aogzOQw(cU4XbcxWfsUHENIDJjbulbPySekj3KDd41qu4fpwQr0xlOBaUimPtD7fUDJzCVPJBekIQnUv5XactadrB8diSCJJQCg98j8BXJLqf6MSBaVgIcV4XsOcDt2nbQFhCgpWglHk0nz3a01XhEXJb9uIOH1UbKORLaxC8)7D9sqGmMvBKi84XsOKCt2naDD8Hx8yjusUj7Ma1VdoJhyJdo0LFeXhvHYIccbHCWfvOa5I7NSYGm(fzHUj7gONsenSEjXXOv56ewlPqec5IqqqpvX4aHl4YT3mbbvxu8y1XVW4UBYUb6PerdRxsCSekj3KDd41quy3EZrF3sqJzcfrUCt2nqjuIgwVK4yLwswWNcjcoiqGiOcqkzrrqg)QIjDQBaUimPtfoWgZrNkHIyjqgdOhf0nG9XH0VJQw6IIDJjue5sg41qu4XCuLZONpHFUbON7TbC8Te042sqJrSe044LGgEmhvQKltc4WKoDjfcc(yPgrFTGUHENIDJjbulbPyCGWfC5MaKwPIjD6y0(7XpmWXPtxJdPFhvT0ff7MuJOVwWXbcxWfsU9NAN6gtcOwszXXO3P4XVnYLDlDTw)jJdPxCUqAGnwQr0xlOB)P2PUXKaQLuwCmAhfr5gGVs9HiueJVysMGdo(fzHUj7gOekrdRxc8X)P2PcDJ)6pHUKYJbE5IID7XToC0sIJzcfrUCt2nqpLiAy9sqJLAe91c6gGlct60XcBhM0h)cJ7Uj7gOekrdRxsCSeQq3KDd41quy3EZrF3sqJfO(DWz8aBSeQq3KDdqxhFy3EZrF3sqJLqj5MSBa664d72Bo67wcACGWfCjCaxcAahhsV4CH0aB8RkM0PU9pIq8yMOb4wi97OQLUO4NDlQvQDD8HhNoDnMjAaUfs)oQAPlk(z3IALAxhF4XOv56ewlPqesqirrWhZQnseEmMORhuC4LumGJdPxCUqAGn(vft6u3(hriEmt0aClK(Du1sxu8ZUHu97GZ4XPtxJzIgGBH0VJQw6IIF2nKQFhCgpgTkxNWAjfIqccjkc(WdpwcvOBYUjq97GZy3EZrF3sqJLqj5MSBcu)o4m2T3C03Te0WBa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170111.3, [[dWt8eaGEIu7svL2MQqZukjhwLzlQVjLs3eiDneYTj58QQANcTxLDJ0(P8tPunmb(TuTovbdLqdMQHlOdkshveCmcoNuIwiqSuqPflflhWdvvEkQLHOEocMiryQa1KbfthYfjLRkcvpteDDq2ic14KsOnRkA7iYhLsXNbvtJi67sj1ifHYJjQrRknEIKtQQIBrQonu3teIllzTsj41Iq6jmWJtaQGkymN4ofzoJLUwuG8yraS6a(BoXDkYCglDTOa5XIay1b838VleH7uZtHaUXmQdOAaWu4fWyGkp(tlcwd2XjoHYCoSYzIZhH31mMdpzmf(IenwKKM56Mlr98GYObYyrsAMRB(xx1CO1mg0tkScszoySQwmzW4wO3vlkq0yrsIMRBUe1ZdkJmpnh(ElkmwKKO56M)1vnhAnJfjjAUU5suppOmAGm()iw)rIcAPqqlt22KjdKSftgSN6ss0yPwmymSvUoc1IKdeABGGGWVKhNaubvMNMXWPQIIglpwKKM56M)1vnhY80C47TOWyraS6a(B(pYDQ5mw6Arjdglss0CDZ)6QMdzEAo89wuymldGdrJjGPWZ1yrsAMRBUe1ZdkJmpnh(ElkmobOcQimWlkmWJ1OxtUGzGmovgH7uZBfMaAmJvFMRrFpQCPkk6bZdbk5UQ5qJJNQgZy1N5A03JkxQIIEW8qGsURAo0yyRCDeQfjhiquWJ)sMSWywgahIgJWQkrcgArYd8yn61KlygiJtLr4o18wHjGgZy1N5A03JkxQIIEWCyQNhugnoEQAmJvFMRrFpQCPkk6bZHPEEqz0yyRCDeQfjhiquWJ)sMSWqdnMXu45YCDZbftXki1IjhZHvotC(i8A(xp3bg4X3IcJBwuym8ffgdSOWqJ)6H)nhCFSg99OYLQOiZtBxBCkeQBUU5GIPyfKAXKJtaQGkZLaduYiCNog2FAtIbESe1ZdkJgiJtaQGkym)h5o1CglDTOKbJfjPzUU5Gpa4fY80C47TOWyn61KlygiJtHqDZ1nh0tkScsTyWyraS6a(B(3fIWD6ycahc3hN2UM56MdkMIvqQftoMXu45YCDZb9KcRGulgmg8LlkY82a0Hcxmy8pYDkbZ53ERPlk5yypk8Y8V3sorXu4JVgCgJ(pMdlz8LXsFiCNUi5htoM4ofnofaFzZJhaqV1JJNQgRrFpQCPkkY8021glss0CDZbFaWlK5P5W3BrHXIKenx3CWha8cTMXIK0mx3CWha8cTMXPYiCNA(3fIWDkHbY4021mx3CqpPWki1IbdTb]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170111.3, [[dOJyeaGEcyxGuzBarZeimBuUPk0Hv62I8AbrTtsTxPDlQ9t1pvbggj9Bv5zqkdfudMYWf4Gc1rjqhdIZbsvleKSucYIvrlxv9qi5PilJqEoHAIcXubyYckthQlsIRQcQlR46Q0gbsFgeBwiTDa9rvqonQMgKQVlizKccnobrgnrz8euNuq1TiY1eK68evpgOwRGGVbs5IuaLoa48zR8EwsW7CNWCd0xg7gXfyQgrujyGWUj5gG9dzW9Se8NN2VC3qTby(l7w89VLk9hwjukAakcv6WIh3OGHXaLTIL1ZsWavCtYna7hYG7zjyGkUj5wKj6Ez4cvjyGkUj5gQx6CX9S0XvyE6MCdapnvJMAPq49svJMAjc8NhGlvcgiSBsUH6LoxCplbde2nj3Imr3ldxOkjVGkfsQqVi0vbjcc0qtvKiOP2OsOh6scxTAjHg2SINQfPIanveeeOtujbVZDClMXHKttgxcCP4l(5MKBhxH5PBQA1sWaHDtYna7hYGDlMfiBRgPeXZqyJBsUDKN5PBQA1sXhO4MKBhxH5PBQA1sWavCtYTit09YWUfZcKTvJucgiSBsUfzIUxg2TywGSTAKsWaHDtYnuV05IDlMfiBRgPefmmgOSvSm3q9yVFbuARgP0z1iLGunsPF1ifxIcgW8LXfyX8xUArGuujyGkUj5gQx6CXUfZcKTvJusW7Ch3IW)dym)Llju4hkebuk(IFUj52rEMNUPQvlj4DUtyUfo4x2nIlWun6QLGbQ4MKBa2pKb7wmlq2wnsjL8EYMWkuLG)80(L7gQnaZF5s49dzWIlr8me24MKBhxH5PBQAKsXhO4MKBh5zE6MQgTsaw2KXUDO)7guTAPWb)YIDJK9cvUA0lj0MHmUHs2aoK5ziL2toJJLxc(Zt7xUBHd(LDJ4cmvJUAj9MMskSjnz8YCd(Zt7xEjqFzCP4pFzUP3))fQsrMO7LHluLG)80(L7gOVm2nIlWunIOsOEbYDdWRKcBstgVm3IpqPefSG5zivh6sXGX8x2nuBaM)YIluLe8o3rCbunsbusjVNSjScvPyWy(l7gi4IXLifq4McBstgVm3Imr3ldxsVPPePac3uytAY4L5wKj6Ez4scnSzfpvlsfbKiQQOvIa)5b4sfxCXTa]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170111.3, [[dOdCeaGEcYUec9AHGzQi1SH6MQQCyv(Mqu)wHDkyVs7wK9t5NGsdJknoQOYZiudfsdM0WPkhKQ6OeuhdIZjKyHGILsfzXQklhKhsGNISmfvpNkmrHQPcOjlKA6O6Ie5QurPlR01vLnQO8zGAZcLTdKpkK0PrzAesFxiYiPIITPQkJgunEcXjvKClI6AQQQZRiEmaRLkQ62I6IuGLGf0cHVj9RKWV9TrB6SrIBkXeABazEjuqOMkBkWdc8Y7xjuiw(GMyQGZJZgjt9FqxPz4lVMsWhaIqjOfxsGuaOKtLCwhRPK3IXZWNd49RekijtLnf4bbE59RekijtLnn(g7EyEHPekijtLnvWi)D8(v63jcl)YMcKL3ge7wY5hJCdIDlHcc1uztJVXUhMBQp2d(1asjuqOMkBQGr(749RekiutLnn(g7EyEHP0Kot(V)DJcIBuehzXIDf15e72yYI(FjFyLmv20FNiS8l3GBjNw8Eo2gM7IezxeeKioVKWV9TM6JzGt5nXlbOekijtLnvWi)DCt9XEWVgqkHcXYh0etNcWizkXeABqu3sOGqnv2ubJ83Xn1h7b)AaPKWV9TokWgqkWssP7dVrxyk5dGZgjtNM5GxIKM2uj8M3e)WMgFJDpmVu4YBjsAAtLWBEt8dBA8n29W8soT49CSnm3f5pexxXrePebaI5XlvE5L8bWzJKPcopoBKCuykrEhawcCd)xsWWBIPahLKWBEt8dBQpSsLiVfJNHphWnvWapGkWsxdiLGAaPe4gqk91as5LiVfa7WmHooBKAy(FZlHcXYh0etNnsCtjMqBdiZlj8BFRPXzqlaoBKk50ur1zawkC5TKeEZBIFyt9HvQKWV9TrB6uagjtjMqBdI6wA2iXl5dXoSPHdcAePssP7dVrxykHcc1uztbEqGxUP(yp4xdiLC6sGxtfaFbebwcCP7JHz8jL8HvYuzt)XsS8l3G4stbyKCykbFePudIwc4H3e30OcnEEn4wIyjW41uzt)DIWYVCdULqHy5dAIPcopoBKkbDC2OK)Jpmv20FSel)YniUekijtLnf4bbE5M6J9GFnGuk(g7EyEHPK)Jpmv20FNiS8l3GBjILaJxtLn9hlXYVCdIlraGyE8soyjW4TekijtLnn(g7EyUP(yp4xdiLePb3YBba]] )




end
