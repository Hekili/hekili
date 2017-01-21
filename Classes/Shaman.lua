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
        addAura( 'lava_surge', 77756, 'duration', 10 )
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
            known = function () return talent.ascendance.enabled end,
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
            setCooldown( 'stormstrike', 0 )
            gainCharges( 'lava_burst', class.abilities.lava_burst.charges )
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


    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170112.1, [[dau5jaqifqwec1MuGAuquDkeKDrKHPqhtGLrIEMcAAKIkxtbY2Gu(gcmofGCofawhPiZdbL7brj7dbvhKOSqsLhkOMOcGUijSrfqnssrvNKqSssrXmHO4MqyNe8tfGAOKIslvqEkQPcr2R0FjjdgsoSklgrpMIjtPld2mP0NvkJMu1Pr61qQMnu3wODl63QA4KulxrpxjtNQRtO2oc57KcNNOA9quQ5tiTFLQBqrQSI8iXGT6klCrOmtJH3rPadri9dRPDuwq7jg7LzZKQ2lxoeGHBbvq5yabJbbbsdlZQbd9WuK950pRGs0uwwMXPFUksviOivwrEKyWwYYSzsv7L9FBddsM)X2xJCnyK73CdCj9WHD9sQnoHPCqIkQtJaHpknOXrcvw4IqznpmF6kwwK0snN)ZY5NqzzKum1LxMe)VflE5LdRhmOJ4jcIq6LSCiad3cQGYXa0ciqACyzeVv4Iq56vqzrQSI8iXGT6kZMjvTx2)TnmiP(D6NRbJCsXA1kbyicPFyvXB5WuUKy1IkQFZnWLCAeu5VklfimK1WrrfLuSwTsK4)TyXlxsSAcvwgjftD5Lv)o9ZYIKwQ58Fwo)eklCrOSM9D6NLLn3wLZlcilITWzXYvTnpdqC5qagUfubLJbOfqG04WYH1dg0r8ebri9swgXBfUiuMylCwSCvBZZaexVcdlsLvKhjgSvxz2mPQ9YKI1QvAcRpV0aQ83HO0eIhnxeMYYcxekJ07qChfIB5WuEzrsl1C(plNFcLLrsXuxEz)DiQkElhMYlhwpyqhXteeH0lz5qagUfubLJbOfqG04WYiERWfHY1RGMRivwrEKyWwDLzZKQ2l7)2ggKm)JTVg5QSWfHYdmDc7OuGHiK(HllsAPMZ)z58tOSmskM6YlRLobvagIq6hUCy9GbDeprqesVKLdby4wqfuogGwabsJdlJ4TcxekxVcdQivwrEKyWwDLzZKQ2l7)2ggKm)JTVg5QSWfHYS)Z4okfyicPF4YIKwQ58Fwo)eklJKIPU8Yl)NrvagIq6hUCy9GbDeprqesVKLdby4wqfuogGwabsJdlJ4TcxekxVcOvKkRipsmyRUYSzsv7L9FBddsM)X2xJCvw4IqzfyicPF4DuiULdt5LfjTuZ5)SC(juwgjftD5LbmeH0pSQ4TCykVCy9GbDeprqesVKLdby4wqfuogGwabsJdlJ4TcxekxVceuKkRipsmyRUYSzsv7L9FBddsM)X2xJCnyKpq(HH0LULbs7LgqcYJedwrfLuSwTs3YaP9sdijwTOIA(hBFnsPBzG0EPbKMq8O5IWh0iHklCrOSo8)2DudS4P8YIKwQ58Fwo)eklJKIPU8YK4)TQ0kEkVCy9GbDeprqesVKLdby4wqfuogGwabsJdlJ4TcxekxVcdOIuzf5rIbB1vMntQAVS)BByqY8p2(AKRbJ8bYpmKU0TmqAV0asqEKyWkQOKI1Qv6wgiTxAajXQjuzHlcL1bZfmrNMBLfjTuZ5)SC(juwgjftD5LjH5cMOtZTYH1dg0r8ebri9swoeGHBbvq5yaAbeinoSmI3kCrOC9kmaksLvKhjgSvxz2mPQ9YNXPebQGeIuyr4k31mLLrsXuxE5P4u1zC6NQW0LxwK0snN)ZY5NqzHlcLdjo3rjZ40p3rHm0Lxw2CBvUCiad3cQGYXa0ciqACyzw)RbI3s1sH5Q6khwpyqhXteeH0lzzeVv4IqzIzAm8okfyicPFynTJs2awbX1RqWyrQSI8iXGT6kZMjvTx2pmKU0TmqAV0asqEKyWwwgjftD5LNItvNXPFQctxEzrsl1C(plNFcLfUiuoK4ChLmJt)ChfYqx(okKhqOYYMBRYLdby4wqfuogGwabsJdlZ6Fnq8wQwkmxvx5W6bd6iEIGiKEjlJ4TcxektmtJH3rPadri9dRPDulAUHHDu3YqC9keeuKkRipsmyRUYSzsv7L9ddPlrnGwXt5sqEKyWwwgjftD5LNItvNXPFQctxEzrsl1C(plNFcLfUiuoK4ChLmJt)ChfYqx(okKRKqLLn3wLlhcWWTGkOCmaTacKghwM1)AG4TuTuyUQUYH1dg0r8ebri9swgXBfUiuMyMgdVJsbgIq6hwt7Ow0Cdd7OOAjUEfcuwKkRipsmyRUYSzsv7L9ddPlHPB69KMBQMVvcYJed2YYiPyQlV8uCQ6mo9tvy6YllsAPMZ)z58tOSWfHYHeN7OKzC6N7Oqg6Y3rH8HeQSS52QC5qagUfubLJbOfqG04WYS(xdeVLQLcZv1voSEWGoINiicPxYYiERWfHYeZ0y4DukWqes)WAAh1IMByyhfEsC96LhGG2tm2RU6Ta]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170112.1, [[d8ImcaGEPsAxOKTrv1SPYnLQUnf7uk7LSBe7hs1WePFRQHkvQbdPmCrCqKYXGQfIQSuQslgjlxupuQ4PGLPcRdvLMiQQAQqPjRstx4IOuxw56OQyZOQY2HIEoQ8zu4XqCyjNxfnAiPVrvCsiXZqQonLUNujwevL)cfEnkAHlScytkk3UINGwzMaWA6GoASDZmsuo(IoAj5H8gQkeaizBsiqG35wXn1osX9KIJJZIUaizi2Yz7Af2NO2H)db0qc7t4ew1WfwbSjfLBxXtaGKTjHG4zWWnwjFyFcNaAuwNnofK8H9jcqHCTiv8zbKNmbTYmbD)H9jcOLzWjGuM1fF3vx3jgmYfY8jW7CR4MAhP4(X9WkLUGoOoeM9pMZmsikb9)TvMjW3D11DIbJCHmFku7qyfWMuuUDfpbTYmby)yg0rRV4ILpfqJY6SXPG4JzWWuCXYNc8o3kUP2rkUFCpSsPlafY1IuXNfqEYe0b1HWS)XCMrcrjO)VTYmbkuJUWkGnPOC7kEcALzcG4ZgMBjllGgL1zJtbCXNnm3swwG35wXn1osX9J7HvkDbOqUwKk(SaYtMGoOoeM9pMZmsikb9)TvMjqHcb8F8R4Jlepfsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170112.1, [[d0dLoaGEIePnPsYUOKTjH2NkPMjLkMnPMprI6MQupMk3MIdR0oHyVIDRy)eLrrPQ)sv9BeFtL48QGbtcdNK6GsWPuHCmK64QqzHKOLQQYIH0YL0dLOEkQLruToIeXevHQAQsKjRktxQlsP8kvOkxgCDIyJej50qTzcSDc65i57ePmnkvI5rKWRvvoeLkPrtONrsoPQQ(mv5AuQu3JivJJiPoNkuzyQOdDkf22SOA4fLHrwdeMXMYYuytdgy6vlLitbfE80Gmf6Ay2vXQ7WH)bAyPGGi)K(YjnnTLQWSAWHxnwkDBmzcI8IYdxW1yYqLsbHoLcBBwun8IYWSRIv3HTRn29HhVWiRbclv61aYuWIe3x4)Zd72MudpKbcxafRX9HWc0Rb8PejUVWLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40brEkf22SOA4fLHzxfRUdJkrGalWjsakFIa)we89QW2(usMhuXJNLe1xzwqt1vIXYjPwHPVw6sDXWiRbcBBRT4XKSFq4)Zd72MudpKbcxafRX9HWWwBXJjz)GWLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40brvkf22SOA4fLHzxfRUdBwqt1vIXYjPwHPVw6hN8WiRbcBBRTOmfSiX9f()8WUTj1WdzGWfqXACFimS1w0NsK4(cxweCF3eHGbMoOH)bAyPGGi)KUi9fRtvHVjpK1aHthe7skf22SOA4fLHzxfRUdVUgle8HbmyG6AvHrwdeMBs18bGAOg()8WUTj1WdzGWfqXACFimvtQMpaud1WLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40bXUtPW2MfvdVOmmYAGW20GbME1YuOuVuD4cOynUpeg0GbME1(O6LQd)d0Wsbbr(jDr6lwNQc)FEy32KA4Hmq4YIG77MiemW0bn8n5HSgiC6GumLcBBwun8IYWSRIv3HxxJfc(WagmqDTQWiRbcBh8XKGFYuCVEMvMIsKgmH)ppSBBsn8qgiCbuSg3hcRXhtc(5BwpZ63KgmHllcUVBIqWath0W)anSuqqKFsxK(I1PQW3KhYAGWPdYLukSTzr1WlkdZUkwDh(rAlb61a(uIe3NvfmlEOU2TuTFJnWvocr)isB8RW66WiRbcBNv4ktHsjvQo8)5HDBtQHhYaHlGI14(qy9kC9rLuP6WLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40brQtPW2MfvdVOmm7Qy1DyZcAQUsmwoj1km91sx(5vOseiWc0GbME1(ciojuwsuFvfeubkXfvdHrwdewQ0RbKPGfjUpzkSN(OW)Nh2TnPgEideUakwJ7dHfOxd4tjsCFHllcUVBIqWath0W)anSuqqKFsxK(I1PQW3KhYAGWPdYXLsHTnlQgErzy2vXQ7WMf0uDLySCsQvy6RLUuxmmYAGW22AlktblsCFYuyp9rH)ppSBBsn8qgiCbuSg3hcdBTf9PejUVWLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40bH(mLcBBwun8IYWSRIv3HrLiqGvfOiZooWVjnySQGzXdLuqFkLLY2JkrGaRkqrMDCGFtAWyvbZIhkPWEujceyTuoyE74aRNK62yYC8CeI(rK2yTuoyE74aRkyw8qD0vocr)isBSwkhmVDCGvfmlEOKcA7(OWiRbcxI0GrMI7LQH6HW)Nh2TnPgEideUakwJ7dHBsdgFZs1q9q4YIG77MiemW0bn8pqdlfee5N0fPVyDQk8n5HSgiC6GqtNsHTnlQgErzy2vXQ7WOseiWcCIeGYNiWVfbFVkSTpLK5bv84zjrDyK1aHTT1w8ys2pqMc7Ppk8)5HDBtQHhYaHlGI14(qyyRT4XKSFq4YIG77MiemW0bn8pqdlfee5N0fPVyDQk8n5HSgiC6GqlpLcBBwun8IYWSRIv3HrLiqGLAI0GQprGFlc(Mf0uDLySKO(Q11yHGpmGbdusHQREaQebcS0ypXEWJNFL8SEePnHrwde2oypXEWJNmfkj6o8)5HDBtQHhYaHlGI14(qyn2tSh845Js0D4YIG77MiemW0bn8pqdlfee5N0fPVyDQk8n5HSgiC6GqRkLcBBwun8IYWSRIv3HrLiqGLAI0GQprGFlc(Mf0uDLySKO(Q11yHGpmGbdusHQWiRbcBhSNyp4XtMcLeDltH90hf()8WUTj1WdzGWfqXACFiSg7j2dE88rj6oCzrW9Dtecgy6Gg(hOHLccI8t6I0xSovf(M8qwdeoDqOTlPuyBZIQHxugMDvS6o86ASqWhgWGbQRPVADnwi4ddyWa110x9aujceyPXEI9Ghp)k5z9isBcJSgiCzXfpYuyhSNyp4Xl8)5HDBtQHhYaHlGI14(qyN4IhFn2tSh84fUSi4(UjcbdmDqd)d0Wsbbr(jDr6lwNQcFtEiRbcNoi02Dkf22SOA4fLHzxfRUdVUgle8HbmyG6A6RwxJfc(WagmqDnDyK1aHllU4rMc7G9e7bpEYuyp9rH)ppSBBsn8qgiCbuSg3hc7ex84RXEI9GhVWLfb33nriyGPdA4FGgwkiiYpPlsFX6uv4BYdznq40bHUykf22SOA4fLHzxfRUd)aujceyPXEI9Ghp)k5z9isBcJSgiSDWEI9Ghpzkus0Tmf2l)OW)Nh2TnPgEideUakwJ7dH1ypXEWJNpkr3HllcUVBIqWath0W)anSuqqKFsxK(I1PQW3KhYAGWPdc9LukSTzr1WlkdxafRX9HWASNyp4XZhLO7W)Nh2TnPgEidegznqy7G9e7bpEYuOKOBzkSx1rHlFWPHsB1dAQGg(hOHLccI8t6I0xSovfUq1JkS7Gtd(9w9GMs6pavIabwASNyp4XZVsEwsuhUSi4(UjcbdmDqdFtEiRbcNoi0sDkf22SOA4fLHzxfRUdxbbvGsCr1q4cOynUpewGEnGpLiX9f()8WUTj1WdzGW3eH4XlmDyK1aHLk9AazkyrI7tMc7LFu4cvpQWgIq84jD6W)anSuqqKFsxK(I1PQWLfb33nriyGPJYW3KhYAGWPdc9XLsHTnlQgErz4cOynUpeg2Al6tjsCFH)ppSBBsn8qgi8nriE8cthgznqyBBTfLPGfjUpzkSx(rHlu9OcBicXJN0Pd)d0Wsbbr(jDr6lwNQcxweCF3eHGbMokdFtEiRbcNoiYptPW2MfvdVOmCbuSg3hclqVgWNsK4(c)FEy32KA4Hmq4BIq84fMomYAGWsLEnGmfSiX9jtH9QokCHQhvydriE8KoD4FGgwkiiYpPlsFX6uv4YIG77MiemW0rz4BYdznq40PdF8bbReDhLPta]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170112.1, [[d4JFoaGEKsvTjII2Le2gLY(ikmtfipMkZMI5tuc3uHoSs3MuFtIANQyVIDRQ9tsgLcYFvP(nkNNsCAcdMenCIQdsP6ukOogIoUcOfsclvrAXiz5u1dveRIOeTmuP1HuQ0erkvmvjYKrvtxQlss9kKsvUm46QKnQa1ZOK2SIA7OIpJu9AjzAeLIVRa0Zr4qeLsJMiZdPuojsX4ikPRruQUhsjNtbWtHgMK6qMsbv)lLb4JIGNvdbrHEIkLQnGg(En0UQusiE6gqLsXCq05fY7GbNcgyjGC4wtwUMKKSWAquo4eRrq7VTG95W1g3G2DTG9ePuoKPuq1)sza(Oii68c5DqzBlCvINEWZQHGd2SAqLsuI5QcsZZlCBZ8bF2dbTtjmI2sWzZQHBcjMRk4ejWvnY4aA47qfCkyGLaYHBnPnYYf1wdoY4pRgcMohUPuq1)sza(Oii68c5DqQR55cWjXaIB28Dlb309W23expp4fp9Il5YuVGHO9mDH7Y7HVLbTKvBbpRgcQE9T0aV2kiinpVWTnZh8zpe0oLWiAlbH13sd8ARGGtKax1iJdOHVdvWPGbwcihU1K2ilxuBn4iJ)SAiy6CSMsbv)lLb4JIGOZlK3b1lyiAptx4U8E4BzqRbGBWZQHGQxFlPsjkXCvbP55fUTz(Gp7HG2PegrBjiS(w6MqI5QcorcCvJmoGg(oubNcgyjGC4wtAJSCrT1GJm(ZQHGPZr2Ksbv)lLb4JIGNvdbXM51vaih8bTtjmI2sqIM51vaih8bNcgyjGC4wtAJSCrT1G088c32mFWN9qWjsGRAKXb0W3Hk4iJ)SAiy6CK9ukO6FPmaFue8SAiOAdOHVxJkLkmlrh0oLWiAlbbdOHVxZnLzj6GtbdSeqoCRjTrwUO2AqAEEHBBMp4ZEi4ejWvnY4aA47qfCKXFwnemDo2sPGQ)LYa8rrq05fY7G6fmeTNPlCxEp8nTrRY2cEwneKghmF5TeKMNx42M5d(ShcANsyeTLGchmF5TeCIe4QgzCan8DOcofmWsa5WTM0gz5IARbhz8NvdbtNt5ukO6FPmaFueeDEH8o46Abh4gEqlaczyn4z1qWbjg4LGxLYXLUEvPSeRbDqAEEHBBMp4ZEiODkHr0wcAed8sWFRx669UznOdorcCvJmoGg(oubNcgyjGC4wtAJSCrT1GJm(ZQHGPZrwtPGQ)LYa8rrq05fY7GuxZZfYzdi4VzZ3TeCRxWq0EMU4sUmPUMNliAMxxbGCWxCjxMRRfCGB4bTaiOnRbpRgcoibDP(fpDvkvWmDqAEEHBBMp4ZEiODkHr0wcAe0L6x80VPyMo4ejWvnY4aA47qfCkyGLaYHBnPnYYf1wdoY4pRgcMoNbiLcQ(xkdWhfbrNxiVdYZ6IzZQHBcjMRQWd6v8eYWTe9Dl0GmDmMHNnG)Thwxh8SAi4GwoRkLkU8eDqAEEHBBMp4ZEiODkHr0wcAwo7n1LNOdorcCvJmoGg(oubNcgyjGC4wtAJSCrT1GJm(ZQHGPZHSoLcQ(xkdWhfbrNxiVdsDnpxiCW8L3sXLCzo0q6fmeTNPlCxEp8TmOf36HLfYcQR55cHdMV8wk8GEfpbTnezHSlljKdgZT0s0GSK6AEUq4G5lVLcIEDv0EKdpCWZQHGd2ZiAvkrjMRkinpVWTnZh8zpe0oLWiAlbN9mI(MqI5QcorcCvJmoGg(oubNcgyjGC4wtAJSCrT1GJm(ZQHGPZHKmLcQ(xkdWhfbrNxiVdQxWq0EMUWD59W3YGwCRLj118Cbyan89AUNzUlIIl5Y0dZEGqAPmqWZQHGd2SAqLsuI5QuPCiYHdsZZlCBZ8bF2dbTtjmI2sWzZQHBcjMRk4ejWvnY4aA47qfCkyGLaYHBnPnYYf1wdoY4pRgcMohsUPuq1)sza(Oii68c5DqQR55cHdMV8wkUKh0oLWiAlbN9mI(MqI5QcsZZlCBZ8bF2dbhzCep9GKbpRgcoypJOvPeLyUkvkhIC4G290jcQzCepDArgCkyGLaYHBnPnYYf1wdorcCvJmoGg(okcoY4pRgcMohsRPuq1)sza(Oii68c5Dq9cgI2Z0fUlVh(wg0swTf8SAiO613sQuIsmxLkLdroCqAEEHBBMp4ZEiODkHr0wccRVLUjKyUQGtKax1iJdOHVdvWPGbwcihU1K2ilxuBn4iJ)SAiy6CiLnPuq1)sza(Oii68c5DqQR55cpqW(9DWDZAqx4b9kEcAJSo4z1qWsSg0QuoUen4TeKMNx42M5d(ShcANsyeTLGnRb9TEjAWBj4ejWvnY4aA47qfCkyGLaYHBnPnYYf1wdoY4pRgcMohszpLcQ(xkdWhfbrNxiVdsDnpxaojgqCZMVBj4MUh2(M465bV4PxCjp4z1qq1RVLg41wbQuoe5WbP55fUTz(Gp7HG2PegrBjiS(wAGxBfeCIe4QgzCan8DOcofmWsa5WTM0gz5IARbhz8NvdbtNdPTukO6FPmaFueeDEH8oi118CHC2ac(B28Dlb36fmeTNPlUKlZ11coWn8Gwae0M1GNvdbhKGUu)INUkLkyMwLYHihoinpVWTnZh8zpe0oLWiAlbnc6s9lE63umthCIe4QgzCan8DOcofmWsa5WTM0gz5IARbhz8NvdbtNdz5ukO6FPmaFueeDEH8o46Abh4gEqlaczqkZ11coWn8GwaeYGm4z1qWjsR4vPCqc6s9lE6bP55fUTz(Gp7HG2PegrBjOtAf)TrqxQFXtp4ejWvnY4aA47qfCkyGLaYHBnPnYYf1wdoY4pRgcMohsznLcQ(xkdWhfbpRgcoibDP(fpDvkvWmTkLdXD4G2PegrBjOrqxQFXt)MIz6GtbdSeqoCRjTrwUO2AqAEEHBBMp4ZEi4ejWvnY4aA47qfCKXFwnemDoKdqkfu9VugGpkcIoVqEh0dZEGqAPmqq7ucJOTeC2SA4MqI5QcsZZlCBZ8bF2dbhzCep9GKbpRgcoyZQbvkrjMRsLYH4oCq7E6eb1moINoTidofmWsa5WTM0gz5IARbNibUQrghqdFhfbhz8NvdbtNd36ukO6FPmaFue0oLWiAlbH13s3esmxvqAEEHBBMp4ZEi4iJJ4PhKm4z1qq1RVLuPeLyUkvkhI7WbT7PteuZ4iE60Im4uWalbKd3AsBKLlQTgCIe4QgzCan8DueCKXFwnemDoCjtPGQ)LYa8rrq7ucJOTeC2SA4MqI5QcsZZlCBZ8bF2dbhzCep9GKbpRgcoyZQbvkrjMRsLYHSoCq7E6eb1moINoTidofmWsa5WTM0gz5IARbNibUQrghqdFhfbhz8NvdbtNoiTdmVxMoksNaa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170112.1, [[dWZthaGEIe1MKuAxsLTjc7JujMjiPzJQBkrphPUnjpwP2Pu2l1UvSFsv)KibdtcJJiHoSW5LQmyr0WbPoiP4ueP4yi5CejYcrOLkPAXGA5i6HIKNcTmIQ1rQKMiirnvsPjRKPdCrIYPr5YQUUOyJeP0ZeL2mPITljFgeFtKAAskAEKk1FjIxJGrlQ(oiroPuvhssHRrKK7bs43eoorQgfrsTPSwJYMaM)LjASfQBezQu6tkJF1hqW1v9j1ifKze3KmObgnw)8h03n5fuPlOOO6YAeH(BwWzs5aWeJBYti3OMnGjgAR1nkR1OSjG5FzIgBH6grGGur4h6tAudmJZa9msdeKkc)qFsJ1p)b9DtEbvcQ0Dfzn2FwSDaeKghXCJPY)MqPO6QpadBSuSAH6gnWn5wRrztaZ)YenIBsg0aJabei83Tfc(saLgAJTqDJAO3FwXSVX(ZITdGG04iMBudmJZa9mg07pRy23yQ8VjukQU6dWWgRF(d67M8cQeuP7kYASuSAH6gnWTSwRrztaZ)Yen2c1ncvM0ZWw6twgquH(KAfGRmQbMXzGEg5mPNHTKOciQqcqaUYy9ZFqF3KxqLGkDxrwJ9NfBhabPXrm3yQ8VjukQU6dWWglfRwOUrdCRMwRrztaZ)YenIBsg0aJXgWQUKpxXoTURzTQ4CAaPq1TZqs(bOlqH8IARbi4FaDCgKCWWgisifRUpbm)lJTqDJslpuxFsmxSjyS)Sy7aiinoI5g1aZ4mqpJ6Wd1LqNl2emMk)BcLIQR(amSX6N)G(UjVGkbv6UISglfRwOUrdCtQSwJYMaM)LjASfQBuwqcYLEMGWnQbMXzGEgFqcYLEMGWnw)8h03n5fujOs3vK1y)zX2bqqACeZnMk)BcLIQR(amSXsXQfQB0a3syTgLnbm)lt0iUjzqdmUeGoD4H6sOZfBcDKxfSHwx2bnqcGPETWz0rNoEufsOZqc5DzGU2Aac(hqhNbjhmSbIesXQ7taZ)Q2ydyvxYNRyNw310ylu3iuJQqFsIziPbg7pl2oacsJJyUrnWmod0ZipQcjWziPbgtL)nHsr1vFag2y9ZFqF3KxqLGkDxrwJLIvlu3ObUL2AnkBcy(xMOrCtYGgySgGG)b0XzqYbdBGiHuS6(eW8VQn2aw1L85k2P1TuzSfQBug)QpGGRpjrEqdm2FwSDaeKghXCJAGzCgONXZV6di4sG5bnWyQ8VjukQU6dWWgRF(d67M8cQeuP7kYASuSAH6gnWnPO1Au2eW8VmrJTqDJqnQc9jj(qzudmJZa9mYJQqc8dLX6N)G(UjVGkbv6UISg7pl2oacsJJyUXu5FtOuuD1hGHnwkwTqDJg4MuYAnkBcy(xMOXwOUXu5bB0NeQmi5GHnqmQbMXzGEg35bBKWzqYbdBGyS(5pOVBYlOsqLURiRX(ZITdGG04iMBmv(3ekfvx9byyJLIvlu3ObUrvyTgLnbm)lt0OgygNb6zKhvHe4mK0aJ9NfBhabPXrm3yPOInqmszSfQBeQrvOpjXmK0a9jLAkPXOgsi0gvIk2abkOmw)8h03n5fujOs3vK1yQ8VjukQU6dWenwkwTqDJg4gfL1Au2eW8VmrJ4MKbnWi51H805bm)g1aZ4mqpJ6Wd1LqNl2em2FwSDaeKghXCJLIk2aXiLXwOUrPLhQRpjMl2e0NuQPKgJAiHqBujQydeOGYy9ZFqF3KxqLGkDxrwJPY)MqPO6Qpat0yPy1c1nAGbgHYxNidhyIgyda]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170112.1, [[d0ZRpaGEisvBIIyxezBuv2hvQMjvkMnLMpej3ecpMu3MKdlStOSxPDRy)urJIQOHjQghfP8nvO7bvLbtfgos1bPQ6uufogsoheHwif1sHkTyiTCrEie1trTmIQ1brQmrksvtvfmzvz6kDrQKxrrQCzW1fLncvvonHnRs2os55QQVtrY0GiL5rLsVwf9mQsJMchcQQ6Kqv(mr5AqeCEOI)Qs9BehhIOlvpu21eOw4vZLXcfuMfkKD6WLfuWSHfPZPJVyKzbNoIVUmRtc6B5Y4cwi(qXKNtDmNIIsYBzMoOfHvG0hRGmftUp5L9Rxbz(9qXO6HYUMa1cVAUmRtc6B5LitMfK0eI9rm18nXZhzLUSHcU)ge9PucuHy(UJMDDjfFnmVy0G0llfRGmM45kuG74ZxosHuOzxxsOwc5zZ(RugDpmrti2hXuJKnOf3OzP)kLaviMV75MG)Ozxxs)LKuNaqhssz09OmwOGY()AyEXOHY4npHowsQ8qgOSFuHvS4uo(AyEXOHYiBa6teeAGcMTOLXfSq8HIjpNYh1rPCVLrqEyHck3TyY7HYUMa1cVAUmRtc6Bz8Ff6tXiRmwOGY4NnuGthSbrFwgV5j0XssLhYaL9JkSIfNYx2qb3FdI(SmYgG(ebHgOGzlAzCbleFOyYZP8rDuk3BzeKhwOGYDlM3EOSRjqTWRMlZ6KG(wwfG9VjIssNLsWSUJp55MKaviMVBXhA21Lu81W8IrdsVSuScYyIMqSpIPgP4RH5fJgKsGkeZ30HMDDjfFnmVy0G0llfRGmUfFVSuScYugluqz8ZgkWPd2GOpD6WtkpkJ38e6yjPYdzGY(rfwXIt5lBOG7VbrFwgzdqFIGqduWSfTmUGfIpum55u(OokL7TmcYdluq5UfdP1dLDnbQfE1CzwNe03YOzxxsG2Ga)BY19Aa3YsqS3)S5bjXitkJUj4pA21Lu81W8Irdsz0nrfG9VjIssNLsWSUJptZxzSqbLDfP1ajZItOmEZtOJLKkpKbk7hvyfloLHiTgizwCcLr2a0Nii0afmBrlJlyH4dftEoLpQJs5ElJG8WcfuUBXqc9qzxtGAHxnxM1jb9TSka7FteLKolLGzDhFir5MG)OzxxsXxdZlgniLrVmwOGYUI0A40bBq0NLXBEcDSKu5Hmqz)OcRyXPmeP14(Bq0NLr2a0Nii0afmBrlJlyH4dftEoLpQJs5ElJG8WcfuUBX81dLDnbQfE1CzSqbL5LKuNaqhsL9JkSIfNY)LKuNaqhsLXfSq8HIjpNYh1rPCVLXBEcDSKu5HmqzKna9jccnqbZw0YiipSqbL7wSJ9qzxtGAHxnxgluqzxwqbZgwNomBJ)w2pQWkwCkdwqbZg2BuB83Y4cwi(qXKNt5J6OuU3Y4npHowsQ8qgOmYgG(ebHgOGzlAzeKhwOGYDlMP1dLDnbQfE1CzwNe03YHEf0GByaLa(U7TmwOGYUrGKzINthiczQWPJdKfuLXBEcDSKu5Hmqz)OcRyXPSvGKzI3TkKPI7LSGQmYgG(ebHgOGzlAzCbleFOyYZP8rDuk3BzeKhwOGYDlgsShk7Acul8Q5YSojOVLrZUUKOtmfKUjx3RbCRcW(3erjLr3e0SRlP)ssQtaOdjPm6Me6vqdUHbuc47wVLXcfu2nczg7igzoDyMy3Y4npHowsQ8qgOSFuHvS4u2kKzSJyKDJsSBzKna9jccnqbZw0Y4cwi(qXKNt5J6OuU3YiipSqbL7wmQ8EOSRjqTWRMlZ6KG(w(rwPlBOG7VbrFkLaviMV764V3RqbM4PMqSpIPM7ee6fPqk0SRlP4RH5fJgKYO7rzSqbLDtqlC6WCw6VLXBEcDSKu5Hmqz)OcRyXPSnOf3OzP)wgzdqFIGqduWSfTmUGfIpum55u(OokL7TmcYdluq5UfJIQhk7Acul8Q5YSojOVLvby)BIOK0zPemR74tEUjOzxxsGfuWSH9(IOZ(sz0lJfkOm(zdf40bBq0NoD4PCpkJ38e6yjPYdzGY(rfwXIt5lBOG7VbrFwgzdqFIGqduWSfTmUGfIpum55u(OokL7TmcYdluq5UfJsEpu21eOw4vZLzDsqFlRcW(3erjPZsjyw3XNP5RmwOGYUI0A40bBq0NoD4jLhLXBEcDSKu5Hmqz)OcRyXPmeP14(Bq0NLr2a0Nii0afmBrlJlyH4dftEoLpQJs5ElJG8WcfuUBXO82dLDnbQfE1CzwNe03YOzxxsj4tMy0W9swqjLaviMVBPYrkKYt0SRlPe8jtmA4EjlOKsGkeZ3TEIMDDjfFnmVy0G0llfRGmMonHyFetnsXxdZlgniLaviMVhMOje7JyQrk(AyEXObPeOcX8DlfsWJYyHckFGSGYPdeXFHeoLXBEcDSKu5Hmqz)OcRyXP8swqDRI)cjCkJSbOprqObky2IwgxWcXhkM8CkFuhLY9wgb5HfkOC3IrH06HYUMa1cVAUmRtc6Bz0SRljqBqG)n56EnGBzji27F28GKyKjLrVmwOGYUI0AGKzXj40HNuEugV5j0XssLhYaL9JkSIfNYqKwdKmloHYiBa6teeAGcMTOLXfSq8HIjpNYh1rPCVLrqEyHck3TyuiHEOSRjqTWRMlZ6KG(wo0RGgCddOeW3Dktc9kOb3Wakb8DNQmwOGYUjOfoDygcvz8MNqhljvEidu2pQWkwCkBdAXnkeQYiBa6teeAGcMTOLXfSq8HIjpNYh1rPCVLrqEyHck3Tyu(6HYUMa1cVAUmRtc6Bz0SRlj6etbPBY19Aa3QaS)nrusz0nj0RGgCddOeW3TElJfkOSBeYm2rmYC6WmXUoD4jLhLXBEcDSKu5Hmqz)OcRyXPSviZyhXi7gLy3YiBa6teeAGcMTOLXfSq8HIjpNYh1rPCVLrqEyHck3Tyuh7HYUMa1cVAUmRtc6B5qVcAWnmGsaF3Pmj0RGgCddOeW3DQYyHckJSrigNoCJqMXoIrwz8MNqhljvEidu2pQWkwCkRncXCBfYm2rmYkJSbOprqObky2IwgxWcXhkM8CkFuhLY9wgb5HfkOC3IrzA9qzxtGAHxnxgluqz3iKzSJyK50HzIDD6Wt5Eu2pQWkwCkBfYm2rmYUrj2TmUGfIpum55u(OokL7TmEZtOJLKkpKbkJSbOprqObky2Iwgb5HfkOC3IrHe7HYUMa1cVAUmRtc6B5eCLGVrGAHY(rfwXIt5lBOG7VbrFwgV5j0XssLhYaLrqOjgzLPkJfkOm(zdf40bBq0NoD4Pxpk7pj7xwrOjgz4JQmUGfIpum55u(OokL7TmYgG(ebHgOGzR5YiipSqbL7wm559qzxtGAHxnx2pQWkwCkdrAnU)ge9zz8MNqhljvEidugbHMyKvMQmwOGYUI0A40bBq0NoD4PCpk7pj7xwrOjgz4JQmUGfIpum55u(OokL7TmYgG(ebHgOGzR5YiipSqbL7wm5u9qzxtGAHxnx2pQWkwCkFzdfC)ni6ZY4npHowsQ8qgOmccnXiRmvzSqbLXpBOaNoydI(0PdprAEu2Fs2VSIqtmYWhvzCbleFOyYZP8rDuk3BzKna9jccnqbZwZLrqEyHck3TBztpCfz2TM72c]] )

    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170112.1, [[dauSDaqiPewerfAtqsJcsCkLQEfukyxqmmQ0XOILrKEgfzAOuCnOuABkfFtPY4iQKZrurRJOcyEOu6EqPAFevDqOWcLs9qLstKOc6IqrBKOsnsOuiNeQQzkLOBIs2jkgkrfOLcL8ustfQYxHsr7v1FHudgLQdlSyfESsMmLUmyZsLplvnAP40i9Ak0SjCBQA3s(nIHtuwoQEUIMUORdv2of8DPKopf16HsHA(er7Ni8DoExXSIHaSV9vMWdxvQFReSJz1e1c8qLYbKGDl0f4e5vvgSOHGInoskPoJ0nMUIfiGycNrQRZoxhhhetx1fNklVEfJvsj184DgNJ3vmRyia7BFLj8WvSjTSsWU2ab)QU4uz51K03laeALaNJtwoVIfiGycNrQRZgNDiUMUIXGkOP5RTsll6zde8R4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNr6X7kMvmeG9JRmHhUInc4e60FvxCQS8As67faYIqewsR1evuYG3djsdeISbr2kzRuSvsjtQhK3fbBDD3FflqaXeoJuxNno7qCnDfJbvqtZxhccXkWnZR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNX0X7kMvmeG9TVYeE4QCd8qib7QmkNMx1fNklVMK(EbGSieHL0AnrfLwe8K2fRejeYAc0TseDi8OmkVRKsIIpaXm5epYchNdvkp2L6I6IqewsRfYIhZg0cAFtw0QhHd(Gwt2I9(LD)(RybciMWzK66SXzhIRPRymOcAA(AhWdb6PmkNMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppdBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Q)QU4uz51GN0UyLiHqwtGUvIOdHhLr5DrvghmGUFzrCq6aEiqpLr508kwGaIjCgPUoBC2H4A6kgdQGMMVU4XSbTG23KfT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgS94DfZkgcW(2xzcpCTnWNa3iT6VQlovwEnj99cazriclP1AIkkdCDDiXCbLnQfGGtMKs2ImeqLiXCbLnQfGavmeGvsjfGbqWwhx39xXceqmHZi11zJZoextxXyqf0081bWNa3iT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEMnhVRywXqa23(kt4HRTfeIvc2LBCCZx1fNklVMK(EbGSieHL0AnVIfiGycNrQRZgNDiUMUIXGkOP5RdbHyr3HJB(k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95z2D8UIzfdbyF7R6ItLLxtsFVaqKrskPMOIshWdb6PmkNMiCWh0Akp2kPKzW7HejPEaDsqBPaBX(g39xXyqf008vzKKsQR4xw6ksc)Ark4kt4HRYbjjLuxXG3pVwHhWUCugNiivpyrlJ0kWLJxXceqmHZi11zJZoextx32alJSigapu5hxzrSmHhUkhLXjcs1dw0YiTcC54ZZixhVRywXqa23(kt4HRTj4ewG3rN5vDXPYYRdCDDidcoHf4D0zIWbFqRjB7xwjLefFaIzYjEKfoohQKTyhBDrnwj1aGgkWtHP8y30(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJCE8UIzfdbyF7RmHhU2MGtybEhDMsWoko7VQlovwEDGRRdzqWjSaVJoteo4dAnzB)YkPKOSAcEpmr3XJvsjviK3bzh2IQpaXm5epYchNdvYwSpHmPv)ezqWjSaVJot0(aeZKt8OgRKAaqdf4PWKTyx6(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJJ7X7kMvmeG9TVYeE4kwKLXbnb(vDXPYYRziGkrerzNcQfqGkgcWI6axxhIik7uqTach8bTMSTFzVIfiGycNrQRZgNDiUMUIXGkOP5RCYY4GMa)k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zCCoExXSIHaSV9vMWdxLBCCZsWoPtc2XGYVQlovwETfjDzKw9O6dqmtoXJSWX5qLYlv6vSabet4msDD24SdX10vmgubnnFTdh3mAsh6GYVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghPhVRywXqa23(kt4HRYnNmZbpk7vDXPYYRziGkrAcQyMeUhbQyialQdCDDiDCYmh8OSiCWh0AYwomW11HUvAzjTEflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghthVRywXqa23(kt4HRYTi8qsQECWvDXPYYRdCDDiDIWdjP6XbiCWh0AYwomW11HUvAzjTkPKOSieHL0AHyjep6wPLDIWbFqRjB3G6axxhsNi8qsQECach8bTMSLn7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJdBoExXSIHaSV9vMWdxLdjeVeSJnPLDEflqaXeoJuxNno7qCnDfJbvqtZxTeIhDR0YoVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghS94DfZkgcW(2xzcpCDlpMnsWElP9nzrREjyhfN9x1fNklVMHaQezXJzdT6rptc3JavmeGf1yLudaAOapfMYJDtOIslYqavI0euXmjCpcuXqawjLCGRRdPJtM5GhLfHd(Gwt57x29xXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4S54DfZkgcW(2xzcpCfZGNnqjb7QmQr4kwGaIjCgPUoBC2H4A6kgdQGMMVcbpBGc9ug1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8mo7oExXSIHaSV9vMWdxBjTVjlA1lb7TjI8QU4uz5vuYqavIqma8vtW7beOIHaSO6dqmtoXJSWX5qLYJD24IAlYqavI0HJBgnPdDq5iqfdby3lPKOKHaQeHya4RMG3diqfdbyrndbujshoUz0Ko0bLJavmeGfvFaIzYjEKfoohQuE24In0rc0YcRLw97VIfiGycNrQRZgNDiUMUIXGkOP5RcAFtw0Qh9GiYR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNXrUoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rr6(R6ItLLxh466qw8y2Gwq7BYIw9iCWh0AY2(Lf1yLudaAOapfMYJDPxXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4iNhVRywXqa23(kt4HRytAzNKQ)kwGaIjCgPUoBC2H4A6kgdQGMMV2kTSts1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDpExXSIHaSV9vMWdxXyUGYg1cUQlovwEnj99cazriclP1AIkkdCDDiZKW9doT6bocoz7VIfiGycNrQRZgNDiUMUIXGkOP5RXCbLnQfCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDoExXSIHaSV9vMWdxXM0Yoto1iCvxCQS86axxhYmjC)GtREGJGtgQOGsgcOsKoCCZOjDOdkhbQyialQ(aeZKt8ilCCouP8yxQl2qhjqllSwA1VxsjrPfziGkr6WXnJM0HoOCeOIHaS73FflqaXeoJuxNno7qCnDfJbvqtZxBLw2zYPgHR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrQ0J3vmRyia7BFLj8WvnjC)m5uJWvDXPYYRdCDDiZKW9doT6bocozOIckziGkr6WXnJM0HoOCeOIHaSO6dqmtoXJSWX5qLYJDPUydDKaTSWAPv)EjLeLwKHaQePdh3mAsh6GYrGkgcWUF)vSabet4msDD24SdX10vmgubnnFDMeUFMCQr4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zKA64DfZkgcW(2xzcpCTLHHqc2BzmBUQlovwEndbujsdjr3eLfbQyialQdCDDinKeDtuweCYUIfiGycNrQRZgNDiUMUIXGkOP5RIWqGweZMR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrkBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rX0(R6ItLLxJvsnaOHc8uykp2zZvSabet4msDD24SdX10vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msX2J3vmRyia7BFLj8WvSjTSZKtncsWoko7VIfiGycNrQRZgNDiUMUIXGkOP5RTsl7m5uJWv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZiDZX7kMvmeG9TVYeE4QMeUFMCQrqc2rXz)vDXPYYRziGkriga(Qj49acuXqawuxeIWsATqe0(MSOvp6brKiCWh0AY2(LfvFaIzYjEKfoohQuE5Y9kwGaIjCgPUoBC2H4A6kgdQGMMVotc3pto1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8ms3D8UIzfdbyF7RmHhUQjH7NjNAeKGDuKU)QU4uz51meqLiD44Mrt6qhuocuXqawu9biMjN4rw44COs5zJl2qhjqllSwA1JkklcryjTwicAFtw0Qh9Giseo4dAnLVFzLuYwKHaQeHya4RMG3diqfdby3FflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY1X7kMvmeG9TVYeE4QMeUFMCQrqc2rX0(R6ItLLxBrgcOseIbGVAcEpGavmeGf1wKHaQePdh3mAsh6GYrGkgcWEflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY5X7kMvmeG9TVQlovwEffuIvsnaOHc8uykVJKsMHaQezXJzdT6rptc3JavmeGvsjZqavImi4ewG3rNjcuXqa29O2IjKOhKc3ejPa3rorZgzl5D3lPKDapeONYOCAIWbFqRP8y7vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbxzcpCDlpMnsWElP9nzrREjyhf2S)kwGaIjCgPUoBC2H4A6Q2qALfXs7OaF(2x32alJSigapu5hxzrSmHhU(8mMCpExXSIHaSV9vMWdxLBozMdEuwjyhfN9x1fNklVMHaQePjOIzs4EeOIHaSOoW11H0XjZCWJYIWbFqRjBzdICDflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtohVRywXqa23(kt4HRTmmesWElJzJeSJIZ(R6ItLLxZqavI0HJBgnPdDq5iqfdbyrndbujcXaWxnbVhqGkgcWIkktirpifUjssbUJCIMnYwY7IQpaXm5epYchNdvkp2Ll39xXceqmHZi11zJZoextxXyqf008vryiqlIzZv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZys6X7kMvmeG9TVYeE4AlddHeS3Yy2ib7OiD)vDXPYYRziGkr6WXnJM0HoOCeOIHaSO2ImeqLiedaF1e8EabQyialQOmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yhBnT)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtMoExXSIHaSV9vMWdxBzyiKG9wgZgjyhft7VQlovwEfLwmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yFczsR(jIimeOfXSbTpaXm5e)EjLeLwKHaQePdh3mAsh6GYrGkgcWI6es0dsHBIKuG7iNOzJSL8UO6dqmtoXJSWX5qLYJD24U)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtS54DfZkgcW(2xzcpCvUfHhss1JdKGDuC2FvxCQS86axxhsNi8qsQECach8bTMSLniY1vSabet4msDD24SdX10vmgubnnFTteEijvpo4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zmHThVRywXqa23(kt4HRkUYcCA1FflqaXeoJuxNno7qCnDfJbvqtZxN4klWPv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZyAZX7kMvmeG9TVYeE4kwKLXbnbUeSJIZ(RybciMWzK66SXzhIRPRymOcAA(kNSmoOjWVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgt7oExXSIHaSV9vMWdxLBr4HKu94ajyhfP7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJj564DfZkgcW(2xzcpCTnbNWc8o6mLGDuKU)kwGaIjCgPUoBC2H4A6kgdQGMMVoi4ewG3rN5v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZNxLdHUaNiF7N)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170112.1, [[dedXbaGEukTlIyBIsZuLKztYnrvUTk2PI2l1Uf2VizyIQFlzOOegSiA4qCqc6yQYcjWsvjwmrTCv1dfHNcEmKwhkjteLOPsitwHPl1fjupJiDDuk2SkP2okvxg5Wq9zu8DurltL68OsnAs55KQtIk8nrXPv6EOKArOQ(Ri1RrLSFwKbXbwwrdlWWeFidWEsKkP4qdhO0HIMvPsI8j06iJBdacHUy1YwCVv45DwPgUqkcRtEEN)YK)EpjsnaO)fPnyqiAVvOBrE(SidIdSSIgwGba9ViTHUyyuKeKQ3k0niuEvBZTbKQ3kmWrmwuCxFdrfKHj(qgyr1Bfge(z0ne4dXA(i)svbdnsJuCsF(gUqkcRtEEN)Y(YijxQHeAekx8k2PdfTLnWRgt8HmWh5xQkyOrAKIt6Z3TN3wKbXbwwrdlWWeFidxTmADSbtQKG2sQHHlKIW6KN35VSVmsYLAqO8Q2MBdQLrRJnysRRTKAyGJySO4U(gIkidj0iuU4vSthkAlBGxnM4dzWTBdSKUgZgvBbUTb]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170112.1, [[d4JJoaGEsjuBsvQDbvVMc2NGYmjLQVjPmBuMVGQUjPu6XKCBjomv7eP2RYUvz)KIrjPQHjuJJukopf50qgmPYWvvoOi6uQcogsoNGkTqkQLQkAXiSCk9qsj1tjwgI8CrnrsjKPkitgktxQlsQ6vKsuxgCDrAJsQ4VcSzHSDvv(mf67QQQPrkrMNQQSnr4qKsYOLKXtkboPQKNHOUMGkUNQqRKuc63O64sQ0JAHMO)CcgGnZtO9cmr0RDn60ZGcCTZ0OlzwbhMFkyIwee5PSEMN8eyGNHrtkMQwmfffo5jIYI(6jtsQAe)Yl0OPwOj6pNGbyZ8erzrF9KMB0idWvCodJ))LFJXB8iMxGGCfxza3cfhD5WisJIW9Scom)uaowQ1Be)ER4Cgg))dN5)8aIuBUXTqXrxoS43AfrAueEU52Iba(alE63KKeigQnnXZk4W8tbtEDyiL3C7KJFWeAVatsMvWH5NcM8eyGNHrtkMkbvn8yYRhnPfAI(Zjya2mprBDTaujTeYTgHopH8erzrF9eTQrkdOZ4KKeigQnnjI5fiixXvgM86WqkV52jh)Gj0EbMuhMxan6KkUYWeT2KIbHCRrOZJyYtGbEggnPyQeu1WJjprQ4)RTCmuecS5rSE0KxOj6pNGbyZ8erzrF9KIdSCB5fCvQ1cxh2JKIFBHIJU8FpsKgfH7zfCy(PaCSuR3i(9wX5mm()hUNvWH5NcWTqXrxwltKgfH7zfCy(PaCSuR3i(93JyPwVr8Bssced1MMeX8ceKR4kdtEDyiL3C7KJFWKNad8mmAsXujOQHhtEcTxGj1H5fqJoPIRmOrx9upSE0APfAI(Zjya2mpruw0xpHinkchuvCihWJc6kiWOf8oiNEyGfDgXt)ERvePrr4EwbhMFkap97DXbwUT8sypQnj0Ofo5jWapdJMumvcQA4XKN86WqkV52jh)Gj0EbMO3TDvDtDdWKKeigQnnbCBxv3u3aSE0HZcnr)5emaBMNikl6RNuCGLBlVGRsTw46WEmCj9wRisJIW9Scom)uaE63KNad8mmAsXujOQHhtEYRddP8MBNC8dMq7fyIE32vA0jvCLHjjjqmuBAc42UkixXvgwp6el0e9NtWaSzEIOSOVEsZnAKb4UTrrUQdCced1ME7Qg9dcGdkiih2JKN8eyGNHrtkMkbvn8yYtEDyiL3C7KJFWeAVatKMBlga4dStssGyO20KCZTfda8b21JU2cnr)5emaBMNikl6RNm5jWapdJMumvcQA4XKN86WqkV52jh)Gj0EbMONbf4ANPrNzMN7jjjqmuBAcWGcCTZciyEUxpATzHMO)CcgGnZteLf91tCvJ(bbWbfeKd7rYtssGyO20egQUPiSGIBS4bnVHYKxhgs5n3o54hmH2lWeTJQBkctJoT1nwCn6cXBOm5jWapdJMumvcQA4XKxp6WDHMO)CcgGnZteLf91tisJIW)4)d2aEuqxbbfhy52Yl4PFVjsJIWZn3wmaWhyXt)E7Qg9dcGdkii)h5jpbg4zy0KIPsqvdpM8Kxhgs5n3o54hmH2lWeTJmw1h6mQrNzoRNKKaXqTPjmKXQ(qNXacoRxpAQ4fAI(Zjya2mpruw0xpbJ34rmVab5kUYaUfko6YHP8Ch0Oc8UEfNZW4)FbwWvD4dprAueUNvWH5NcWt)EyYtGbEggnPyQeu1WJjp51HHuEZTto(btO9cmr7(pxJoZP2CpjjbIHAtty(ppGi1M71JMIAHMO)CcgGnZteLf91tkoWYTLxc7rsXVjsJIWbguGRDwqexLMXt)EBHilKRCcgmjjbIHAttIyEbcYvCLHjVomKYBUDYXpycTxGj1H5fqJoPIRmOrx9KEyYtGbEggnPyQeu1WJjVE0uKwOj6pNGbyZ8erzrF9KIdSCB5fCvQ1cxh2JKIFtKgfHdmOax7SGiUknJN(92vn6heGXB8iMxGGCfxz4V6DvJ(bbWbfeK)7rYVDvJ(bbWbfeKdF4j)WKNad8mmAsXujOQHhtEYRddP8MBNOmPyWKKeigQnnjI5fiixXvgMq7fysDyEb0OtQ4kdA0P1Mumy9OPiVqt0FobdWM5jIYI(6jfhy52Yl4QuRfUoSh1MetEcmWZWOjftLGQgEm5jVomKYBUDYXpycTxGj6DBxPrNuXvg0OREQhMKKaXqTPjGB7QGCfxzy9OP0sl0e9NtWaSzEIOSOVEcrAueEZBOeu8Cdwt4wO4Ol)hvC4dF9ePrr4nVHsqXZnynHBHIJU8FePrr4EwbhMFkahl16nIFAzfNZW4)F4EwbhMFka3cfhD53koNHX))W9Scom)uaUfko6Y)rfopm5jWapdJMumvcQA4XKN86WqkV52jh)GjjjqmuBAsZBOeu8CdwttO9cmjeVHIgDARNBWAA9OPcNfAI(Zjya2mpruw0xpHinkchuvCihWJc6kiWOf8oiNEyGfDgXt)MKKaXqTPjGB7Q6M6gGjVomKYBUDYXpycTxGj6DBxv3u3aOrx9upm5jWapdJMumvcQA4XKxpAQel0e9NtWaSzEIOSOVEIRA0piaoOGGCyuVDvJ(bbWbfeKdJAYtGbEggnPyQeu1WJjp51HHuEZTto(btO9cmr7(pxJoZGxMKKaXqTPjm)NhqaEz9OPQTqt0FobdWM5jIYI(6jePrr4F8)bBapkORGGIdSCB5f80V3UQr)Ga4GccY)rEYtGbEggnPyQeu1WJjp51HHuEZTto(btO9cmr7iJv9HoJA0zMZAn6QN6HjjjqmuBAcdzSQp0zmGGZ61JMsBwOj6pNGbyZ8erzrF9ex1OFqaCqbb5WOM8eyGNHrtkMkbvn8yYtEDyiL3C7KJFWeAVat06khDA0PDKXQ(qNXjjjqmuBAIQYrxadzSQp0zC9OPc3fAI(Zjya2mpruw0xpzYtGbEggnPyQeu1WJjp51HHuEZTto(btssGyO20egYyvFOZyabN1tO9cmr7iJv9HoJA0zMZAn6QN0dRhnP4fAI(Zjya2mpruw0xpPW)HoJVTqKfYvobdM8eyGNHrtkMkbvn8yYtEDyiL3C7KJFWKKeigQnnjI5fiixXvgMq7fysDyEb0OtQ4kdA0vp5hwpAsul0e9NtWaSzEIOSOVEIRA0piaoOGGCyuVDvJ(bby8gpI5fiixXvg(Zvn6heahuqqEYtGbEggnPyQeu1WJjp51HHuEZTto(btssGyO20KiMxGGCfxzycTxGj1H5fqJoPIRmOrx9ATjfd0OJ0dRhnjsl0e9NtWaSzEcTxGj6DBxPrNuXvg0OREspm5jWapdJMumvcQA4XKN86WqkV52jh)GjIYI(6jf(p0zCssced1MMaUTRcYvCLH1RNiFGc5mKwS3i(nAsjiTEd]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170112.1, [[deKtoaqiufP2efQrHQ0PiGvHQq8kufkZcvrYUi0We0XqXYurpJGMgQIQRHQOSnkY3OQACOk4CQampke3tLO9Ps4GcvlKQYdjqmrufQUifSrcuNuOSsva9sufsZKcPBQcQDIklvf6PitLIAVs)vGbJQ6WkTyu6XuAYuPld2mv8zOQrtvoTQEnuz2K62kA3q(njdxL64QaTCIEUctx01fY2vj9DcKgpQIW5HsRhvr08vbz)qXLPMlzaTSAWT(krw5FNLkXTtOezWOy4BqdtaLRgd)ywWjsIT0rqd7ak3ziJ)qgggrHLOBW(R(5j38vOYDA6SuCB(k0OMlhtnxYaAz1GB9vISY)olXtNVf3JWxko7R)eBjh9oHGHNYIRumK7B3ujlHuiOe3oHscwVtadFYtzXHHpVHcu6iOHDaL7mKXeJFXqHnl3znxYaAz1GB9vISY)olXg54icwpfmcuobPheGxcBgmIqUG8r4fJUnEUGEKs1u0gjLakV4sEWuPJGg2buUZqgtm(fdfwkgY9TBQKLqkeuko7R)eBjyLP3bJwCqjUDcLmSY07GrloOz5ewZLmGwwn4wFLiR8VZsSrooIVfCIKyfJUnEUGEKs1u0gjLakV4sEWuP4SV(tSLCKQrgm8uwCLIHCF7MkzjKcbL42jusWs1iXWN8uwCLocAyhq5odzmX4xmuyZYXZR5sgqlRgCRVsKv(3zP5c6rkvtrBKucO8IlpGtmhyPJGg2buUZqgtm(fdfwkgY9TBQKLqkeuko7R)eBjyLPxWWtzXvIBNqjdRm9WWN8uwCnlhpRMlzaTSAWT(kXTtOeLk5eha3GSuC2x)j2sJujN4a4gKLIHCF7MkzjKcbLocAyhq5odzmX4xmuyjYk)7SuQWJxdIRmFN1Mbl7R)eRX8U28VcbacMpmUG5qhAaz(i8dXfpEjmg)viyKk5eha3GuGMLZunxYaAz1GB9vISY)olv6iOHDaL7mKXeJFXqHLIHCF7MkzjKcbLIZ(6pXwc0Weq5Qdy17ilXTtOKbnmbuUAm89P3r2SC(R5sgqlRgCRVsKv(3zP5c6rkvtrBKucO0ix63uP4SV(tSLEl4ejXwkgY9TBQKLqkeuIBNqPywWjsIT0rqd7ak3ziJjg)IHcBwoEOMlzaTSAWT(krw5FNLwB(xHaabZhgxCPWsXzF9NylP)dg9UbZf)CdsvcZsXqUVDtLSesHGshbnSdOCNHmMy8lgkSe3oHsg9py07IH)Hx8ZfdFZQeMnl3buZLmGwwn4wFLiR8VZsSrooI3kbfKbkNG0dcMlOhPunfJUnMnYXrCKk5eha3Gum6241M)viaqW8HHrewko7R)eBj9J3lrpcFaRsNLIHCF7MkzjKcbL42juYOpEVe9i8y47tPtm85L4rfO0rqd7ak3ziJjg)IHcBwoMWAUKb0YQb36RezL)DwYvLIo6DcbdpLfNOeM7Jgxy3rgK)eWCGLocAyhq5odzmX4xmuyPyi33UPswcPqqP4SV(tSL071nGnsoYsC7ekz096IHVVi5iBwogMAUKb0YQb36RezL)DwInYXr8TGtKeRy0TX8oxqpsPAkAJKsaLxC5z4HoeBKJJ4BbNijwrjm3hnmcV4TU8iSrooIVfCIKyfh5AXXJXiGaLIZ(6pXwYrQgzWWtzXvkgY9TBQKLqkeuIBNqjblvJedFYtzXHHpVmcu6iOHDaL7mKXeJFXqHnlhZznxYaAz1GB9v6WlpXpJMMxjEihLewISY)olnxqpsPAkAJKsaLxC5zOXSrooIGgMakxDGJYgneJUnwcosy4TSAaZbwko7R)eBjh9oHGHNYIRumK7B3ujlHuiOe3oHscwVtadFYtzXvsqWA1G5vIhYrzlDe0WoGYDgYyIXVyOWsKNsqpSY9DEqokBZYXiSMlzaTSAWT(krw5FNLMlOhPunfTrsjGYlU8m0y2ihhrqdtaLRoWrzJgIr3gZlVRn)RqaGG5dJlpnET5FfcCvPOJENqWWtzXzKtbo0H4DT5FfcaemFyCXLcnET5FfcCvPOJENqWWtzXzeHciqP4SV(tSLC07ecgEklUsXqUVDtLSKfRvdLocAyhq5odzmX4xmuyjUDcLeSENag(KNYIddFEzeOz5y451CjdOLvdU1xjYk)7S0uD9r45PyJCCeFl4ejXkgDxko7R)eBjhPAKbdpLfxPyi33UPswcPqqjUDcLeSunsm8jpLfhg(8EkqPJGg2buUZqgtm(fdf2SCm8SAUKb0YQb36RezL)DwAUGEKs1u0gjLakV4sEWuP4SV(tSLGvMEbdpLfxPyi33UPswcPqqPJGg2buUZqgtm(fdfwIBNqjdRm9WWN8uwCy4ZlJanlhJPAUKb0YQb36RezL)DwInYXrucdfArwiivjmfLWCF0WimHLocAyhq5odzmX4xmuyPyi33UPswcPqqjUDcLmRsyIH)H3rcsSLIZ(6pXwkvjmdM7ibj2MLJXFnxYaAz1GB9vISY)olXg54icwpfmcuobPheGxcBgmIqUG8r4fJUlDe0WoGYDgYyIXVyOWsXqUVDtLSesHGsC7ekzyLP3bJwCag(8YiqP4SV(tSLGvMEhmAXbnlhdpuZLmGwwn4wFL42juYOpEVe9i8y47tPZshbnSdOCNHmMy8lgkSumK7B3ujlHuiOuC2x)j2s6hVxIEe(awLolrw5FNLyJCCeVvckiduobPhemxqpsPAkgDB8AZ)keaiy(WWicBwoMdOMlzaTSAWT(krw5FNLwB(xHaabZhgxWu6iOHDaL7mKXeJFXqHLIHCF7MkzjKcbL42jusq82hHHVrF8Ej6r4lfN91FITK1BFuG(X7LOhHVz5odR5sgqlRgCRVsKv(3zPsXzF9NylPF8Ej6r4dyv6SumK7B3ujlHuiOe3oHsg9X7LOhHhdFFkDIHpVmcukUe)OuPJGg2buUZqgtm(fdfwI8uc6HvUVZdYrzljiEGf3HvxHjGYY2SCNm1CjdOLvdU1xjYk)7S0uD9r4nwcosy4TSAO0rqd7ak3ziJjg)IHclfd5(2nvYsifckfN91FITKJENqWWtzXvIBNqjbR3jGHp5PS4WWN3tbAwUZZAUKb0YQb36RezL)DwAQU(i8gV28VcbUQu0rVtiy4PS4mYAZ)keaiy(WO0rqd7ak3ziJjg)IHclfd5(2nvYsifckXTtOKG17eWWN8uwCy4Z7Pay4liyTAOuC2x)j2so6DcbdpLfxZYDkSMlzaTSAWT(krw5FNLMQRpcFPJGg2buUZqgtm(fdfwkgY9TBQKLqkeuIBNqjdRm9WWN8uwCy4Z7PaLIZ(6pXwcwz6fm8uwCnBwIhhC2iDw2MT]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170112.1, [[d0dqoaGEeQuBcHSlkABIW(erntvknBKMpQkCtrKoSuFtu6zKu7eL2RYUb2VQQrrsmmr63K6CKKQZJQmyqA4i4GIQofQQogOoUkfwivyPIklgflNQEijjpLyzQkpxvMicvYuPIMmIMUWfPqNwYLHUoi2Okf9AkyZQKTlk(mv67IiMgcvzEiuoecv4VOYOjX4rOIoPkvJJKuUgcv19qvPvIQIEmLUTkEWZ5eJGMHIKZXeIl8QHqJXmrS(IqmzsoKI9dh7xkC2uyyyt1tecOTAArC3rPbJ9lX3K82O0G3Cow45CIrqZqrY5yIy9fHycXruwdfWDsEMIwbVjx0(GCpfT1WK7aYY2H2pbOb4e2(GtUjTp4purrBn8dvLu(NKdPy)WX(LcNaoRzQ6fJ9BoNye0muKCoMiwFriMWa56YeTkA8XPV4cfKZ1JDW9GairFbCnHqGOtJ0x41htleVhbrY8v1smjhsX(HJ9lfobCwZu1tUdilBhA)eGgGtYZu0k4nbBFOCdiTbCcBFWjgBFOCdiTbCXyvpNtmcAgksohteRVietonsFHxFmTq8EeejZxv)7NpNKdPy)WX(LcNaoRzQ6j3bKLTdTFcqdWj5zkAf8MGTpu4EkARHjS9bNyS9HYpurrBnSySeV5CIrqZqrY5ycBFWjsO9hdisa9tYZu0k4n5fA)XaIeq)K7aYY2H2pbOb4KCif7ho2Vu4eWzntvprS(Iqmj0UUu0S9rD12GRzkAf8isL2gvgKdb4PWxYW8bF8WikG7ZSDD947vzqUxO9hdisa98VySe)5CIrqZqrY5yIy9fHyYKCif7ho2Vu4eWzntvp5oGSSDO9taAaojptrRG3eKIheenLJH2VycBFWjgP4bbrt)H6G2VyXytmNtmcAgksohteRVietABuzqoeGNcFjZx1tYZu0k4nHw3asrYDA3tZf6aptUdilBhA)eGgGtYHuSF4y)sHtaN1mv9e2(GtUTUbKI8hAsB3t)d1PoWZIXMDoNye0muKCoMiwFriMqQdZlAFqUNI2AW0JNUaVKT9l4I6G)85KCif7ho2Vu4eWzntvp5oGSSDO9taAaojptrRG3eANP5yG4FXe2(GtUTZ0)qDaX)IfJv1MZjgbndfjNJjjTjoRdKJZ27IXBI6jI1xeIjNgPVWRpMwiEpcIK57xkrmqUUmrkEqq0uUlTfYZecbI84LhFkndf)5Zj5zkAf8MCr7dY9u0wdtUdilBhA)eGgGty7do5M0(G)qffT1WevXZsrNT3fJ3yMKdPy)WX(LcNaoRzQ6jIIojjvtwxf6FJzXyv95CIrqZqrY5yIy9fHyYPr6l86JPfI3JGiz((LsedKRltKIheenL7sBH8mHqGivuPTrLb5qaEk8X3pIABuzqosDyEr7dY9u0wde7JF(GpuPTrLb5qaEk8LmFvtuBJkdYrQdZlAFqUNI2AGyQ5N)j5zkAf8MCr7dY9u0wdtUdilBhA)elplfNKdPy)WX(LcNaoRzQ6jS9bNCtAFWFOII2A4hQkW8VySWPZ5eJGMHIKZXeX6lcXKtJ0x41htleVhbrY8v1smjptrRG3eS9Hc3trBnm5oGSSDO9taAaojhsX(HJ9lfobCwZu1ty7doXy7dLFOII2A4hQkW8VySWWZ5eJGMHIKZXeX6lcXegixxME8PbnWICHoWJPhpDbEedoDsoKI9dh7xkCc4SMPQNChqw2o0(janaNW2hCItDGNFOjTFb65njptrRG3Kqh4H70Va98wmw4V5CIrqZqrY5yIy9fHycdKRlt0QOXhN(Iluqoxp2b3dcGe9fW1ecHj5qk2pCSFPWjGZAMQEYDazz7q7Na0aCcBFWjgBFOCdiTb8hQkW8pjptrRG3eS9HYnG0gWfJfw9CoXiOzOi5CmHTp4KBlxLaua3FOo00ysoKI9dh7xkCc4SMPQNChqw2o0(janaNKNPOvWBcTCvcqbC5y00yIy9fHycdKRltc6KGEo9fxOGCNgPVWRpMqiquBJkdYHa8u4JyQjIezGCDzslxLauaxoVM0KuNeWIXct8MZjgbndfjNJjI1xeIjmqUUmjOtc650xCHcYDAK(cV(ycHarTnQmihcWtHpIPMO2gvgKJuhMx0(GCpfT1aX(MKdPy)WX(LcNaoRzQ6j3bKLTdTFILNLItYZu0k4nHwUkbOaUCmAAmHTp4KBlxLaua3FOo004hQkQINLI8VySWe)5CIrqZqrY5yIy9fHysBJkdYHa8u4lzyIirgixxM0YvjafWLZRjnj1jb8ZNtYHuSF4y)sHtaN1mv9K7aYY2H2pbOb4e2(GtuLsxGFO3wUkbOaUtYZu0k4nXQ0fGJwUkbOaUlglCI5CIrqZqrY5yIy9fHysBJkdYHa8u4lzyIyGCDzslxLauaxoVM0ecbIABuzqosDyslxLauaxoVMKyTnQmihcWtHVj5zkAf8Myv6cWrlxLaua3j3bKLTdTFILNLIty7dorvkDb(HEB5QeGc4(dvfvXZsr(NKdPy)WX(LcNaoRzQ6fJfo7CoXiOzOi5CmrS(IqmHezGCDzslxLauaxoVM0KuNeWK8mfTcEtOLRsakGlhJMgtUdilBhA)eGgGty7do52YvjafW9hQdnn(HQcm)tY7DFtMKdPy)WX(LcNaoRzQ6jIIojjvtwxf6FJzIQuqRHKQZGheeJzXyHvT5CIrqZqrY5yIy9fHysBJkdYHa8u4lzyIABuzqosDyslxLauaxoVMKyTnQmihcWtHVj5qk2pCSFPWjGZAMQEYDazz7q7Ny5zP4e2(GtUTCvcqbC)H6qtJFOQaZ)puvXZsXj5zkAf8MC51VG7POTgwmwyvFoNye0muKCoMiwFriMmjhsX(HJ9lfobCwZu1tUdilBhA)eGgGty7do52YvjafW9hQdnn(HQYh)tYZu0k4nHwUkbOaUCmAASySFPZ5eJGMHIKZXeX6lcXKJotbCjYJxE8P0muCsoKI9dh7xkCc4SMPQNChqw2o0(janaNKNPOvWBYfTpi3trBnmHTp4KBs7d(dvu0wd)qv5J)fJ9dEoNye0muKCoMiwFriMC0zkGlrTnQmihPomVO9b5EkARbI12OYGCiapf(MKdPy)WX(LcNaoRzQ6j3bKLTdTFILNLIty7do5M0(G)qffT1Wpuv(4)hQQ4zP4K8mfTcEtUO9b5EkARHfJ97BoNye0muKCoMiwFriMC0zkG7KCif7ho2Vu4eWzntvp5oGSSDO9taAaoHTp4eJTpu(HkkARHFOQ8X)K8mfTcEtW2hkCpfT1WIfty7dormE7puJu8GGOP)qVn3In]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170112.1, [[dSt9iaGEQe0MKQQDrvTnjP9rLqZuQkZgv3ekUnP(MKYovL9k2Ts7Nk6NOKudtQmousYHP8mQsdMKA4svoij5uujQJrKZHsqleLAPkklgQwUQ6HsQEkYYiQEokMivcmvQutwHPRYfjkNxsCzW1PcBeLiNgYMPk2Uu8AO03PsYNLsZdLupwI)QiJMetdLqNur1HqjX1OsK7Hsu)MWXPsQrHsGJuChs2A4Cye2HCbGhZb)cEONPHqKS(CQwgh0WEg3PAvSAzHMbCWyG8K3jvRtssY3BiQhuqgh5cTdj28KxvEivLdjwM4opP4oKS1W5WiSd9mneIoXxJfGEWp0mGdgdKN8oPQs1878gsfoIJUkHyoXxJfGEWp08DGk2j(HwXcHQRafSyenGg2l4HWigptdHYLN84oKS1W5WiSdrLpQ3f6eTTCWVie8HWvltONPHqQykWoSTaHMbCWyG8K3jvvQMFN3qQWrC0vjKXuGDyBbcnFhOIDIFOvSqO6kqblgrdOH9cEimIXZ0qOC55nUdjBnComc7qptdH6d5AhOHt1ySwT5uTBXb6qZaoymqEY7KQkvZVZBiv4io6QeIJCTd0ysBTAB6ehOdnFhOIDIFOvSqO6kqblgrdOH9cEimIXZ0qOC5XIXDizRHZHryhIkFuVlK2aoZ9fA)IJ)h2Zfzz5D9ZkNXH985OwLBrB70xm8H1W5WO)p45dmkgohcPchXrxLqE4MgMyuefSHQRafSyenGg2l4HEMgcXsCtdovtkIc2qZaoymqEY7KQkvZVZBisr4kmIbYdc(mbp08DGk2j(HwXcHWigptdHYLNlf3HKTgohgHDiQ8r9Uqw5qnWeSGgbmSMf73khQbMgIZ3d30WeJIOGL1w5qnWeSGgbmHuHJ4ORsipCtdtmkIc2qZ3bQyN4hQuPWHqZaoymqEY7KQkvZVZBONPHqSe30Gt1KIOG1P66vkCixEvJ7qYwdNdJWo0Z0qiz2)uCTddleAgWbJbYtENuvPA(DEdPchXrxLqG9pfx7WWcHMVduXoXp0kwiuDfOGfJOb0WEbpegX4zAiuU8Qf3HKTgohgHDiQ8r9UqdX57HBAyIrruW6)bTHwgxSym30H0q)4o84XNBn2eJJFl47Ox)SYzCypFoQv5w02o9fdFynCom63khQbMGf0iGH1SyONPHq9znMt1SD8zUqZaoymqEY7KQkvZVZBiv4io6QeIBn2eUJpZfA(oqf7e)qRyHq1vGcwmIgqd7f8qyeJNPHq5YJvf3HKTgohgHDiQ8r9UqSYzCypFoQv5w02o9fdFynCom63khQbMGf0iGH1UuONPHqY4Gg2Z4ovZMBmxOzahmgip5DsvLQ535nKkCehDvcbCqd7z8jCUXCHMVduXoXp0kwiuDfOGfJOb0WEbpegX4zAiuU8yHXDizRHZHryh6zAiuFwJ5unBW0HMbCWyG8K3jvvQMFN3qQWrC0vje3ASjCW0HMVduXoXp0kwiuDfOGfJOb0WEbpegX4zAiuU8K6I7qYwdNdJWo0Z0qO6kgADQUpuRYTOTnev(OExObG7WJhFoQv5w02o9fd)HWvBOzahmgip5DsvLQ535nKkCehDvcvum0oXrTk3I22qZ3bQyN4hAfleQUcuWIr0aAyVGhcJy8mnekxEssXDizRHZHryhIkFuVlKvoudmneNph1QClABN(IbRTYHAGjybncycnd4GXa5jVtQQun)oVHMVduXoXp0kwiKkCehDvcvum0oXrTk3I22qptdHQRyO1P6(qTk3I2wNQRxPWHC5jjpUdjBnComc7qu5J6DHWD4XJp3ASjgh)wW3rVqQWrC0vje3ASjChFMl08DGk2j(HwXcHWiAqBBiPqptdH6ZAmNQz74ZCovZcKC5qQ(TmH0Ig02YYsHMbCWyG8K3jvvQMFN3qKIWvyedKhe8zc7q1vGcwmIgqd7f2HWigptdHYLNK34oKS1W5WiSdrLpQ3f6dE(aJIHZHqQWrC0vjKhUPHjgfrbBO57avSt8dTIfcHr0G22qsHEMgcXsCtdovtkIcwNQzbsUCiv)wMqArdABzzPqZaoymqEY7KQkvZVZBO6kqblgrdOH9c7qyeJNPHq5YfIkFuVluUea]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170112.1, [[d8cmcaGEuvAxOOTrvzMOkmBQCtPQVjs2Pu2lz3iTFiLHjIFRQHIQQbdfgUkCqu4yiSqQQwkvPfdvlxulIQ4PGLjvEoQmruLAQqPjRstx4IiYLvUoQk2mQI2Ui1NrPEmehwYZquJgk68QOtcjUnLonf3dvjpes6VqQEnkzriScirlC3UYVaajBocbc494zXhxiCbENBf3uRlHivcbbbtYcGJHykNHVvyEQAD(6eWajmpLtyvJqyfqIw4UDLFbas2CecINnB3yE8H5PCcyGBCM4uWXhMNkaf61GuXNfqF6e0k7eW)hMNkGrMnNaAzhV8CxDDNOZoxiZJaVZTIBQ1Lq4JifZeYcqfZHWQ)tp7OHWf0)3wzNap3vx3j6SZfY8OqToHvajAH72v(f0k7eG9JzrdJ(Ilw(uG35wXn16si8rKIzczbmWnotCki(yw0TfxS8PauOxdsfFwa9PtaQyoew9F6zhneUG()2k7eOqnYcRas0c3TR8lOv2jaIpBzTDSSaVZTIBQ1Lq4JifZeYcyGBCM4uax8zlRTJLfGc9AqQ4ZcOpDcqfZHWQ)tp7OHWf0)3wzNafke0k7eaK4bAyqYn7Or5qdd(Zd5T4vOqca]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170112.1, [[d0ZuhaGEKuPnjLkTlKABuQ2NukMjfPzRY8PiUjLW3Kc3gIld2PQAVk7M0(LkJcjv8xc63qnmQQHIKsgmKmCK4GevNcjfDmkCoPuLfsrTuczXez5IArijpf1JPYZvLjsuutLszYImDjxKQSoIs9mPORdP2irHonIntjTDKuQdjLsFMqnnPuvFNs04ikyzey0efzEiPWjLsEnsQ6AeL48svRukvCyHFsuspJzBSNgshKM5X)abgZEM2HY7aeqR46qjZG1a9vJLzWAG(QzESi4G4b7lW3OHVHHbDZXSltOuJhl3veS(MT9nMTXEAiDqAMh)deym1cxeSoMDzcLACHfl(aAk4IG1x7sDABHfl(aAhgFjSL6ZetCy8LWwQ0wjzqiCacOvC0zaji6RncKbFQ5yrWbXd2xGVHDJg0(nh3stexu48yfRWy5sKJu9JPGlcwhBbo9deymvuY4dRIHKqkylHmvR2xWSn2tdPdsZ8y2LjuQXsOTALUWfGiejEfK7PZasq0h1qWy5sKJu9JlCbicrIxb5(XT0eXffopwXkmweCq8G9f4By3ObTFZX)abgBdxashklIxb5(v73C2g7PH0bPzEm7Yek14clw8b0om(syl13yrWbXd2xGVHDJg0(nh3stexu48yfRWy5sKJu9JTsYGq4aeqR4g)deySmsYqhkVdqaTIB1(T)Sn2tdPdsZ8y2LjuQXfwS4dODy8LWwQVXIGdIhSVaFd7gnO9BoULMiUOW5XkwHXYLihP6h)kCgriCacOvCJ)bcmMlCgPdL3biGwXTAFzz2g7PH0bPzEm7Yek14clw8b0om(syl13y5sKJu9JHdqaTItis8ki3pULMiUOW5XkwHX)abg7DacOvCDOSiEfK7hlcoiEW(c8nSB0G2V5Q9TpBJ90q6G0mpMDzcLACBR4aTOJNd0uOoGg0q6GKjMiH2Qv645anfQdOrtXetCy8LWwQ0XZbAkuhqNbKGOV2il(JfbhepyFb(g2nAq73CClnrCrHZJvScJLlros1pw6W4KqROZ9J)bcm28HXPouYi6C)Q9BmBJ90q6G0mpMDzcLACBR4aTOJNd0uOoGg0q6GKjMiH2Qv645anfQdOrtzSi4G4b7lW3WUrdA)MJBPjIlkCESIvySCjYrQ(Xsq(bzQNOIh)deySzi)Gm1tuXR2xgMTXEAiDqAMhZUmHsnoCfHAdcbfqiWRncg)deySi0QS7qjxw9glxICKQFCgTkmCfbRcpYRg3stexu48yfRWyrWbXd2xGVHDJg0(nhBbo9deymvSNPDO8oab0kUouYLvpQwTF7nBJ90q6G0mp(hiWyrOvz3Hs(ZbAkuhmMDzcLACfhOfD8CGMc1b0GgshKglcoiEW(c8nSB0G2V54wAI4IcNhRyfglxICKQFCgTkmCfbRcpYRgBbo9deymvSNPDO8oab0kUouYFoqtH6aQwTVH)Sn2tdPdsZ84FGaJfHwLDhQwoWk6C)y2LjuQXvCGw0ehyfDUNg0q6Gux7mweCq8G9f4By3ObTFZXT0eXffopwXkmwUe5iv)4mAvy4kcwfEKxn2cC6hiWyQypt7q5DacOvCDOA5aROZ9uTAFdJzBSNgshKM5X)abglcTk7ouMseltLsuXDOeHtJzxMqPgxXbArFeXYuPevSWmordAiDqASi4G4b7lW3WUrdA)MJBPjIlkCESIvySCjYrQ(Xz0QWWveSk8iVASf40pqGXuXEM2HY7aeqR46qzQiQwTAmtbCK4iu3OiyDFb2fSAd]] )



    storeDefault( [[Enhancement Primary]], 'displays', 20170112.1, [[dWdefaGEbyxQIyBeWmvfQdRYSf1RvfIBcrEMQu3MKZlq7uK9QSBK2pv)eIYWi04ufOtJyOezWugUqoOQYrfqhdKZPkileiTuc0IfQLlLhcWtrTmsX6acteszQaAYavthQlkORQkKUSKRdQncP6BquTzvjBhs(OQi9zimnsP(oqKrQkOEmPA0QQgpPKtQkQBruxdOCpvb8CcATar9BP6bnGJrgQQLVGlECGWfCbUBO3Py3ysa1sqAglHsYnz3aEnefEXJLAe11c6gGlct6u3(GB3yg3BQ4gHIOAJBvEmGWeWqbh)Ocl34OkNrpFc)x8yjuHUj7gWRHOWlESeQq3KDdT61bNXd0XsOcDt2naDv8Hx8yKoTikyLBajQAP3IJb5ExTeeyJz9gjcpESekj3KDdqxfF4fpwcLKBYUHw96GZ4b64GdD5hu8H0OTOaqqi)TOgnixCVK1gSXFil0nz3q60IOGvljowWkxNWAjnIqixecc6jVhhiCbxU9LjiOQIIhRp(dg3Dt2nKoTiky1sIJLqj5MSBaVgIc72xo6)wcAmtOiYLBYUHeHsuWQLehlHsYnz3qREDWzSBF5O)BjOXsOcDt2n0QxhCg72xo6)wcACGWfCjCaxcAahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4wuR07Q4dpoDQAmtuaClK(Fu9svumiClQv6Dv8HhlyLRtyTKgribGefFpM1BKi8ymrvpG4WlPzahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4g41RdoJhNovnMjkaUfs)pQEPkkgeUbE96GZ4Xcw56ewlPresairX3dp8yjusUj7gGUk(WU9LJ(VLGgZrvoJE(e(7gGEU3gWX3sqJBlbngXsqJJxcA4Xa6rbDdyFCi9)O6LQOy3ycfrUKbEnefESeQq3KDdqxfFy3(Yr)3sqJdeUGl3qJ0kDmPthl4Zp9HbogT61bNXd0XbcxWf4U9SEN6gtcOwsBXXsOcDt2nGxdrHD7lh9FlbnoKEX5c8b64pyC3nz3qIqjky1sIJLAe11c6gGlct60XcBhM0h)HSq3KDdjcLOGvl9EmtOiYLBYUH0PfrbRwcAmWlxuSBpT1HJwsC8Z6DQq34)oirxs7XcEueLBa(l9hHqrm(Ijzco4yPgrDTGU9SEN6gtcOwsBXXO3P4XFnYLDlDTwhKgNovnoK(Fu9svuSBsnI6Abhl1iQRf0n07uSBmjGAjinJ5OsNCzsahM0PlPrG3J5OtNqrSeyJ)0XKo1naxeM0PchOJ1AjzbEcK4BWGatanGvYIIGn8g]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170112.1, [[dWt8eaGEIu7svL2MQGzkLKdRYSf1RfO4MGIRbkDBsoVQQ2Pi7vz3iTFk)uvOHjOFlvptadLqdMQHlKdkuhvGCmeDoPuSqGyPiKflflhWdvvEkQLreRtkvtKGmvGAYaPPd5IKYvfOQll56GSreQXjLqBwv02jWhLsQpdQMgb13Ls0ifOYJjQrRknEIKtQQIBrQonu3tGsphbRvkbFtkLEKd84GGkOcuZjUtrMZyPRLiLmweaRoG)MtCNImNXsxlrkzSiawDa)n)7Iq4o18yiGBmJ6aQgamfEbmgOYJ)0sG1iACWtOmNJQCM48r4DnJ5OtgtHVeSJffOzUU5cvppOmAGmwuGM56M)1vnhAnJH5KcRGuMdgRQLceoUf6D1sKWowuGO56Mlu98GYiZJZrV3sKJffiAUU5FDvZHwZyrbIMRBUq1ZdkJgiJ)pI1Fa2W2qg2MaTnqGqHBXaH7PUWWowQLchtuLRJqTKKqY2gsss(BGXbbvqL5XzmCQQOOXYJffOzUU5FDvZHmpoh9ElroweaRoG)M)JCNAoJLUws4WXIcenx38VUQ5qMhNJEVLihh)OM56MdZjfwbPwkCCSmc3PM)DriCNsyGmwuGM56Md(aGxO1mwuGO56Md(aGxO1mMJQCM48r418VEUdmWJVLih3Se5y4lrogyjYHg)1J(Bo4(yn67rLlvrrMh)O2yrbIMRBo4daEHmpoh9ElrooiOcQmximqjJWD6yI(P1bh4XPtvJ1OVhvUuffzE8JAJdcQGkqn)h5o1CglDTKWHJjUtrJJbWx280ba0B5yn61KlqhiJ5OsgFzS0hc3Plj5HaJj6OWlZ)El5GbtHp(AWzm6)44h1mx3CyWuScsTuGX)i3PemNF7TKUKWJbF5IImV1aDOOLchZyk8CzUU5WCsHvqQLchlcGvhWFZ)UieUthta4q4(4yiu3CDZH5KcRGulfowuGM56Md(aGxiZJZrV3sKJJHqDZ1nhgmfRGulfymJPWZL56MddMIvqQLcmoiOcQimWlroWJ1OxtUaDGmowgH7uZBfMaAmJvFMRrFpQCPkkQDZJak5UQ5qJtNQgZy1N5A03JkxQIIA38iGsURAo0yIQCDeQLKescB4d)krc5ywgahHgJWQkydhAjjd8yn61KlqhiJJLr4o18wHjGgZy1N5A03JkxQIIA3CqRNhugnoDQAmJvFMRrFpQCPkkQDZbTEEqz0yIQCDeQLKescB4d)krc5qdnMLbWrOXeWu45ASOanZ1nxO65bLrMhNJEVLihlu98GYObYqBa]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170112.1, [[dSt4eaGEIQ2frrTnvqZeImBuDyLUPQKxluf3MuptvQDkyVs7wH9t1pvHAyO0VvPZlugkKgmLHlKdQOokj4yq5Ccv0cbklfOAXkYYvvpKiEkYYisphQAIQOMkqMmj00bDruCvHk1LfDDaBeI60e2SkY2HWhvb8zOY0ik9DHQAKcvPXjuHrtIgprLtQc5wK01ub6Eef5XQI1kujFJOWfRGkDmI8Z3yDQKcajqQOBiFhq3iH8zdyslHIa1nv3aTFCjStLq)c9(J5MKnckUd3Mb(BPs)Kxsctaed4LIB8PBuuY5iZx8k7ujuemUP6gO9JlHDQekcg3uD7CEAb4WcwjuemUP6MKREAHDQ0RvoHgq7giHoB4nBP46E1n8MTe98frWsLqrG6MQBsU6Pf2PsOiqDt1TZ5PfGdlyLIvKvJd24uQSShIHjJ3SsLkd2Esv2dwsUgylbEYZfF2GuwmzWIHHjZVlPaqcKUnZf4g6Cal9uAgaEDt1TxRCcnGUb2sOiqDt1nq7hxcDBMhPCBaRejg44PBQU9smeAaDdSLuaibs8fudyfujMXoXtflyLMFGI7WnKe4HLigKCJHN6CaxUBO)85QNwyPWQZsedsUXWtDoGl3n0F(C1tlSe4jpx8zdszXoeJL9Dj65lIGLGcDktSf2G0cQeZyN4PIfSsZpqXD4gsc8WsedsUXWtDoGl3TZ5PfGdlfwDwIyqYngEQZbC5UDopTaCyjWtEU4ZgKYIDigl77s0ZxeblvyHLMFGI7WnjBeuCh4lyLOO9rmW1Wblj5gfZnq3sm8uNd4YDB(yMsuuY5iZx8kDtYLF)fuPTbSstnGvcxdyL(nGvyjkkFelxi)cf3rdspuAj0VqV)yUH8DaDJeYNnGjTKcajq62zXpFGI7Oe4hDG4fuPZ5PfGdlyLuaibsfD7ON7WnsiF2GSSLq(oGLM)IL7wy))B8lXm2jEQybRuy1zjgEQZbC5UH(f69hRe6xO3Fm3o65oCJeYNnilBP5JzCt1TxIHqdOB4DjW3bU0njkZN4rmWvANeCbmwPJEUd8UrkVXF0GSLaT8CaD7a)lqudSLiXahpDt1TxRCcnGUbSsOFHE)XCtYgbf3rj4(XLq8LqrW4MQBG2pUe62mps52awPza41nv3EjgcnGUb2sOiyCt1njx90cDBMhPCBaRekcu3uDtYvpTq3M5rk3gWkHIa1nv3oNNwao0TzEKYTbSsOiyCt1TZ5PfGdDBMhPCBaR08XmUP62RvoHgq3aBHT]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170112.1, [[dSZ7eaGEsODPKOxRkvMjiA2qDyvUPQs3MuFtiPNHQStb7vA3ISFk)Kezye14qvvoVQOHIkdMQHluhuuoQq4yO05usyHQkwkQklwuTCGEir8uKLPK65OOjQkzQQQMSq00HCrqDvuvvxwX1bSrq40e2SQW2bPpkKYNrHPrI67cPAKQsvBtvkJMinEsWjvs6wK01qvL7jKWJvI1kKOFRux2(xsjOdi(E28sramatKMdXoHmNekonWUUehuoZvn))azmOMxIduOpWNMl5IrIDY8maWRee4tpMts3lVRe4Gljbo8dZxj(N5yofpyme4JP0MxIdkS5QM)FGmguZlXbf2CvZFnpoamQFkXbf2CvZLS15hQ5L(Eki0aAZ)f6PbEYLIY9w3ap5sCq5mx18xZJdaJmpdhl9AGTehuoZvnxYwNFOMxIdkN5QM)AECayu)u6zHq9n(jVcw5vWlQ84jRm)XtUpuvMFLYuc2CvZ)Eki0a6gKlX3GNJ50WAz2OkZYYUsELIayagZZWcgj9KqLwkXbf2CvZLS15hY8mCS0Rb2sCGc9b(08vx2jZjHItdklxIdkN5QMlzRZpK5z4yPxdSLuOb5sCqHnx18xZJdaJmpdhl9AGTeTakIrLyksmWtjsKyGhZvn)Rij0a6g4vIIhmgc8XuQ5s24ny)lDnWwcSb2smAGTuEdSfvsYo(P5)7sW4rpj0Hnptj4szaOT5QM)9uqOb0nixkcGbym)LaCwqIDQeFRgT3)x6184aWO(PueadWeP5RUStMtcfNguwUehuyZvn))azmiZZWXsVgylbNUC8ez)ukdaTnx18VIKqdOBGxjoqH(aFAUKlgj2PsGhsSlLPeS5QM)vKeAaDd8krIed8yUQ5FpfeAaDdYL(p8KqMhnWnqCdYLwDzNyAojDh9udkxIVlXymxI0z5DIeJsxUalqplXbLZCvZ)pqgdY8mCS0Rb2sqStOszGIdBE4ab3rVu40tjy8ONe6WMNPeCjoqH(aFAoe7eYCsO40a76su8SioSqXdj2Pgw)26su8TismAGFLYwqIDYCjxmsStm7NsramadZ(3aB)lbNUC8ez)ukBbj2jZHuWevIGH0Cy8ONe6WMZbolBD(Hkfo9uIGH0Cy8ONe6WMZbolBD(HkX3GNJ50WAz23yLL5vIwafXOsiHEIc5IAyD)lbNUC8ez)ukBbj2jZHuWevIGH0Cy8ONe6WM)AECayuPWPNsemKMdJh9Kqh28xZJdaJkX3GNJ50WAz23yLL5Ts2s0cOigvQOIkQfa]] )


end
