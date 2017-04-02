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

local setArtifact = ns.setArtifact
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
        Hekili.LowImpact = true

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
        addAura( 'ascendance', 114051, 'duration', 15 )
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
        addAura( 'stormbringer', 201845, 'max_stack', 2 )
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
        addAura( 'lashing_flames', 240842, 'duration', 10, 'max_stack', 99 )
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

        setArtifact( 'doomhammer' )
        setArtifact( 'fist_of_raden' )

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

        ns.addSetting( 'st_fury', true, {
            name = "Enhancement: Single-Target Fury",
            type = "toggle",
            desc = "If |cFFFF0000false|r, the addon will not recommend Fury of Air when there is only one-enemy.  It will still budget and pool Maelstrom for Fury of Air (if talented accordingly), in case of AOE.\n\n" ..
                "Simulations for 7.2 suggest that Fury of Air is DPS neutral in single-target, meaning there is no DPS gain or loss from using it in single-target.",
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

        ns.addSetting( 'safety_window', 0, {
            name = "Enhancement: Buff Safety Window",
            type = "range",
            desc = "Set a safety period for refreshing buffs when they are about to fall off.  The default action lists will recommend refreshing buffs if they fall off wihin 1 global cooldown. " ..
                "This setting allows you to extend this safety window by up to 1.5 seconds.  It may be beneficial to set this at or near your latency value, to prevent tiny fractions of time where " ..
                "your buffs would fall off.  This value is checked as |cFFFFD100rebuff_window|r in the default APLs.",
            width = "full",
            min = 0,
            max = 1.5,
            step = 0.01
        } )

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
            usable = function () return talent.fury_of_air.enabled and active_enemies > 1 or settings.st_fury end,
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
            if artifact.lashing_flames.enabled then removeDebuff( 'target', 'lashing_flames' ) end
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170402.123043, [[deemGaqiufTiOOWMOQAuurNIQYUqXWuIJrvwgr8mOitdvvUgviBdkQ(MsQXHQqNJkG1rfiAEubDpuv1(ikoiuYcvsEiuyIubkxeQyJOkyKubcNev0mPc1nrL2jknuOOilfk1tjnvOsFfkkTxv)vbdgvLdlSyP8yLAYu6YGntHpdvnAf60iTAQavVMOA2eUTuTBj)gYWjshNkqA5iEUIMUORtL2of57eLopf16HIIA(Oc7hvPV3X9kov0eG9RU6GbgHRi)QRSrhUQ0og8Yho1yuBOdv6GKx(SGr4kYRydciMWzLS4TEbts4rgVR6MqLMxVI1oPOAECpR3X9kov0eG9RUYgD4kMLwwE5thHGCv3eQ08AIWJxam0kbcXvAoVIvJkOP5RYsl7WCecYvSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zLCCVItfnbyF7kB0HRoiacIo7x1nHknVMi84faZgHewKS18kwnQGMMV2eiKv4oZRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZIPJ7vCQOja7xDLn6WvEaiHGx(uPucnVQBcvAEnr4XlaMncjSizRPFN8mij1i2jtiKogdYIegmKOKlZchC4ShGyMeuNz7siqLYWFjl(3iKWIKTy2KyooiO4hZIw4ziqpO10H8NanxdJbzPLfjRpFxXQrf008vdGeIHPukHMxXgeqmHZkzXBT3YvmgHTCUitqhQ8TRCww6ose5AHk4kxKLn6W1NNLFh3R4urta2V6kB0HRyqI5iV85yk(XSOf(R6MqLMxdssnIDYecPJXGSiHbdjk5YS4xkbmnGFBz8ymasigMsPeAEfRgvqtZx3KyooiO4hZIw4VIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRppRJoUxXPIMaSF1v2OdxxbKjqKtl8x1nHknVMi84faZgHewKS10VZMRHbtm3qzJAdmUs5GddGeIHPukHMmeOh0AkJJ8DfRgvqtZxBazce50c)vSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zX8J7vCQOja7xDLn6W1vceYYlF8GlX8vDtOsZRjcpEbWSriHfjBn97S5AyWeZnu2O2aJRuo4WaiHyykLsOjdb6bTMY4iFxXQrf0081MaHSdgUeZxXgeqmHZkzXBT3YvmgHTCUitqhQ8TRCww6ose5AHk4kxKLn6W1NND9X9kov0eG9RUQBcvAEnr4XlagPOKIQPFNnxddMgqMaroTWZ4kLdoYGGhsMK2HHenyPGd5pMV47kwnQGMMVkfLuuDLZYs3rIixlubxzJoCfZekPO6kwe8ZRv0b(JziLGeOcpyhKIKfiygxXgeqmHZkzXBT3YvmgHTCUitqhQ8TRCrw2OdxXmKsqcuHhSdsrYcemJNNLhpUxXPIMaSF1v2OdxxHCfwGyqN5vDtOsZRnxddMgYvybIbDMmeOh0A6qc0CnmgKLwwKSCWHZEaIzsqDMTlHav6q(7Of)XoPMGbOGofMYWFm57kwnQGMMV2qUclqmOZ8k2GaIjCwjlER9wUIXiSLZfzc6qLVDLZYs3rIixlubx5ISSrhU(8SoWX9kov0eG9RUYgD46kKRWced6m5LpNE(UQBcvAET5AyW0qUclqmOZKHa9GwthsGMRHXGS0YIKLdoCUhdcEyoyqIDsrviKXJzTJ83dqmtcQZSDjeOshY)jKjTWpzAixHfig0zo0dqmtcQ7p2j1emaf0PW0H8xIVRy1OcAA(Ad5kSaXGoZRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZ6TCCVItfnby)QRSrhUInAlVrtGCv3eQ08AgcOsgru2PGAbgOIMaS(BUggmIOStb1cmeOh0A6qc0CnmgKLwwKS(JDsnbdqbDkmLz5kwnQGMMVsqB5nAcKRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZ65DCVItfnby)QRSrhUYdUeZ8YhYGx(WIsUQBcvAELNjDlNw493dqmtcQZSDjeOszKi5kwnQGMMVA4smpGmgck5k2GaIjCwjlER9wUIXiSLZfzc6qLVDLZYs3rIixlubx5ISSrhU(8SEsoUxXPIMaSF1v2Odx5bcAMnsu2R6MqLMxZqavYmguXmrKodurtaw)nxddgdcAMnsuwgc0dAnDibAUggdYsllsw)oDYZmeqLmgUeZdiJHGsyGkAcW6JdoCMHaQKXWLyEazmeucdurtaw)9aeZKG6mBxcbQugjoYNVRy1OcAA(QbbnZgjk7vSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95z9W0X9kov0eG9RUYgD4kpiIoKOcVlCv3eQ08AZ1WGXqeDirfExGHa9GwthsGMRHXGS0YIKLdoCUriHfjBXyrO(GS0YoziqpO10HyU)MRHbJHi6qIk8Uadb6bTMoKF(UIvJkOP5RgIOdjQW7cxXgeqmHZkzXBT3YvmgHTCUitqhQ8TRCww6ose5AHk4kxKLn6W1NN1JFh3R4urta2V6kB0HRoyiuNx(WS0YoVIniGycNvYI3AVLRy1OcAA(QfH6dYsl78kNLLUJerUwOcUIXiSLZfzc6qLVDLlYYgD46ZZ65OJ7vCQOja7xDLn6WvmiXCKx(Cmf)yw0cpV850Z3vDtOsZRziGkz2Kyosl8dZer6mqfnby9h7KAcgGc6uykd)XKFN8mdbujZyqfZer6mqfnby5GJMRHbJbbnZgjkldb6bTMYGFB9DfRgvqtZx3KyooiO4hZIw4VIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRppRhMFCVItfnby)QRSrhUItqYrO4LpvkvoCfBqaXeoRKfV1ElxXQrf008vii5iudtPu5WvollDhjICTqfCfJrylNlYe0HkF7kxKLn6W1NN1B9X9kov0eG9RUYgD4QJP4hZIw45LVvirEv3eQ08QZmeqLmitazpge8adurtaw)9aeZKG6mBxcbQug(ZVf)8mdbujJHlX8aYyiOegOIMaS(4GdNziGkzqMaYEmi4bgOIMaS(ZqavYy4smpGmgckHbQOjaR)EaIzsqDMTlHavkd)WCFxXQrf008vbf)yw0c)qdjYRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZ6XJh3R4urta2V6kB0HRyqI5iV85yk(XSOfEE5ZPeFx1nHknV2Cnmy2KyooiO4hZIw4ziqpO10HeO5AymilTSiz9h7KAcgGc6uykd)LCfRgvqtZx3KyooiO4hZIw4VIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRppRNdCCVItfnby)QRSrhUIzPLDIk8xXgeqmHZkzXBT3YvSAubnnFvwAzNOc)vollDhjICTqfCfJrylNlYe0HkF7kxKLn6W1NNvYYX9kov0eG9RUYgD4kwZnu2O2WvDtOsZRjcpEbWSriHfjBn97S5AyWmteP3i0cpqyCL67kwnQGMMVgZnu2O2WvSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zL4DCVItfnby)QRSrhUIzPLDMeQC4QUjuP51MRHbZmrKEJql8aHXvQFNoZqavYy4smpGmgckHbQOjaR)EaIzsqDMTlHavkd)LG5(4GdN8mdbujJHlX8aYyiOegOIMaS(8DfRgvqtZxLLw2zsOYHRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZkrYX9kov0eG9RUYgD4QMisFMeQC4QUjuP51MRHbZmrKEJql8aHXvQFNoZqavYy4smpGmgckHbQOjaR)EaIzsqDMTlHavkd)LG5(4GdN8mdbujJHlX8aYyiOegOIMaS(8DfRgvqtZxNjI0NjHkhUIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRppRemDCVItfnby)QRSrhUYde0mBKOS8YNtpFx1nHknVcoOUuPsbltipOL7CiAtKWnHbhC3zs3G)meqLmJOCymkldurtaw)nxddMruomgLLXvQFE2CnmymiOz2irzzCL63PtEMHaQKXWLyEazmeucdurtawFCWHZmeqLmgUeZdiJHGsyGkAcW6VhGyMeuNz7siqLYiXr(8DfRgvqtZxniOz2irzVIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRppRe(DCVItfnby)QRSrhU64WuWlFooMJx1nHknVMHaQKzeLdJrzzGkAcW6V5AyWmIYHXOSmUsVIvJkOP5RIWumiI54vSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zL4OJ7vCQOja7xDLn6WvmiXCKx(Cmf)yw0cpV85et(UQBcvAEn2j1emaf0PWug(ZVRy1OcAA(6MeZXbbf)yw0c)vSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zLG5h3R4urta2V6kB0HRywAzNjHkh4LpNE(UIniGycNvYI3AVLRy1OcAA(QS0YotcvoCLZYs3rIixlubxXye2Y5ImbDOY3UYfzzJoC95zLS(4EfNkAcW(vxzJoCvtePptcvoWlFo98Dv3eQ08AgcOsgKjGShdcEGbQOjaR)ncjSizlgbf)yw0c)qdjsgc0dAnDibAUggdYsllsw)9aeZKG6mBxcbQugEC5kwnQGMMVotePptcvoCfBqaXeoRKfV1ElxXye2Y5ImbDOY3UYzzP7irKRfQGRCrw2OdxFEwj84X9kov0eG9RUYgD4QMisFMeQCGx(CkX3vDtOsZRziGkzmCjMhqgdbLWav0eG1FpaXmjOoZ2LqGkLHFyUFNBesyrYwmck(XSOf(HgsKmeOh0Akd(TLdo4zgcOsgKjGShdcEGbQOjaRVRy1OcAA(6mrK(mju5WvSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zL4ah3R4urta2V6kB0HRAIi9zsOYbE5ZjM8Dv3eQ08kpZqavYGmbK9yqWdmqfnby9ZZmeqLmgUeZdiJHGsyGkAcWEfRgvqtZxNjI0NjHkhUIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRpplMwoUxXPIMaSF1v2OdxXGeZrE5ZXu8Jzrl88YNt(57QUjuP5vNoJDsnbdqbDkmLXJdoYqavYSjXCKw4hMjI0zGkAcWYbhziGkzAixHfig0zYav0eG1NFEoHCOHk3jtsbINdmWpPBzw8XbhgajedtPucnziqpO1ughDfRgvqtZx3KyooiO4hZIw4VIniGycNvYI3AVLRymcB5CrMGou5Bx5SS0DKiY1cvWvUilB0HRpplM8oUxXPIMaSF1v2Odx5bcAMnsuwE5ZPeFx1nHknVMHaQKzmOIzIiDgOIMaS(BUggmge0mBKOSmeOh0A6q(XWJ(D6KNziGkzmCjMhqgdbLWav0eG1hhC4mdbujJHlX8aYyiOegOIMaS(7biMjb1z2UecuPmsCKpFxXQrf008vdcAMnsu2RydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZIjjh3R4urta2V6kB0HR8abnZgjklV85et(UQBcvAEfCqDPsLcwMqEql35q0MiHBcdo4UZKUb)8S5AyWyqqZSrIYY4k1VtN8mdbujJHlX8aYyiOegOIMaS(4GdNziGkzmCjMhqgdbLWav0eG1FpaXmjOoZ2LqGkLrIJ857kwnQGMMVAqqZSrIYEfBqaXeoRKfV1ElxXye2Y5ImbDOY3UYzzP7irKRfQGRCrw2OdxFEwmHPJ7vCQOja7xDLn6WvhhMcE5ZXXCKx(C657QUjuP51meqLmgUeZdiJHGsyGkAcW6pdbujdYeq2JbbpWav0eG1VZjKdnu5ozskq8CGb(jDlZI)EaIzsqDMTlHavkd)5XfFxXQrf008vrykgeXC8k2GaIjCwjlER9wUIXiSLZfzc6qLVDLZYs3rIixlubx5ISSrhU(8SyIFh3R4urta2V6kB0HRoomf8YNJJ5iV85uIVR6MqLMxZqavYy4smpGmgckHbQOjaRFEMHaQKbzci7XGGhyGkAcW635eYHgQCNmjfiEoWa)KULzXFpaXmjOoZ2LqGkLH)oct(UIvJkOP5RIWumiI54vSbbet4Ssw8w7TCfJrylNlYe0HkF7kNLLUJerUwOcUYfzzJoC95zXKJoUxXPIMaSF1v2OdxDCyk4LphhZrE5ZjM8Dv3eQ08QtEoHCOHk3jtsbINdmWpPBzw83dqmtcQZSDjeOsz4VNKfFCWHtEMHaQKXWLyEazmeucdurtaw)tihAOYDYKuG45ad8t6wMf)9aeZKG6mBxcbQug(ZVfFxXQrf008vrykgeXC8k2GaIjCwjlER9wUIXiSLZfzc6qLVDLZYs3rIixlubx5ISSrhU(8SycZpUxXPIMaSF1v2Odx5br0Hev4DbE5ZPNVR6MqLMxBUggmgIOdjQW7cmeOh0A6q(XWJxXQrf008vdr0Hev4DHRydciMWzLS4T2B5kgJWwoxKjOdv(2vollDhjICTqfCLlYYgD46ZZIP1h3R4urta2V6QUjuP51yNutWauqNctz8UYgD4Q6wwGql8x5SS0DKiY1cvWvSbbet4Ssw8w7TCfJrylNlYe0HkF7kwnQGMMVoDllqOf(RCrw2OdxFEwmXJh3R4urta2V6kB0HRyJ2YB0ei8YNtpFxXgeqmHZkzXBT3YvSAubnnFLG2YB0eix5SS0DKiY1cvWvmgHTCUitqhQ8TRCrw2OdxFEwm5ah3R4urta2V6kB0HR8Gi6qIk8UaV85uIVRydciMWzLS4T2B5kwnQGMMVAiIoKOcVlCLZYs3rIixlubxXye2Y5ImbDOY3UYfzzJoC95z53YX9kov0eG9RUYgD46kKRWced6m5LpNs8DfBqaXeoRKfV1ElxXQrf0081gYvybIbDMx5SS0DKiY1cvWvmgHTCUitqhQ8TRCrw2OdxF(8Qkf20qqXmhjfvNvcMJPN)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170402.123043, [[diJVbaGEuq7cf51OKMjsHzt0nrvUTk2PI2l1Uf2pPQHjQ(TKHIuYGfHHRQoibDmsSquXsjvwmHwUQ8qrYtbpwLwhsrtePktfv1Kvy6sDrcCzORJuvhgXMrQ02rr9CszzIYNrY3rjopk04qQy0K0ZqPCsuQ(Mi1Pv6EiL6VIOfHkTnuGTI5BqqqeL4WCmqpKUe6lBZXWKCqdWEsPpHGqLex8Grtt9j(p8whrsBqhkrIg6zwUs6C2YOdtkgG7B)TbdcV9wHM57PI5BqqqeL4WCma33(BdDrrjrM(vVvOzqO4k3Mrd)Q3kmWEm2lPRNHOc0WKCqd0Q6TcdcFuAgcYbPn3)RKvqHJK)If8X1GouIen0ZSCL0k5gsPIxw5vmJhmAlAGxnMKdAG7)vYkOWrYFXc(462ZmZ3GGGikXH5yysoObASuQDSbL(eG6IYHbDOejAONz5kPvYniuCLBZOb5sP2Xguj1uxuomWEm2lPRNHOc0qkv8YkVIz8GrBrd8QXKCqdUDBa(4DjYLHKERWZmgWMBBa]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170402.123043, [[d4JRoaGEePQ2eIyxG61uu7tsyMiQ6BskZgvZxsu3usLEmj3wIdHOs7ej7vz3QSFsXOufmmrACQc15jLonWGjvnCvLdkjDkjvDmK6CsIyHuOLQkAXiSCk9qeP8uILPQ65IAIisvMkvYKbz6sDrkYRqurxg66uvBusf)gLntfBhr5ZuW3vLY0quH5Hi5VuLNrQmArmEePItQkzBuPUMKiDpvPALisLoSWXvfYJEUMy6ccocnJtOIcormrEn6nXXcEDW1OVAwHhuCkCcPh6e(8EgN8e5yKXr9Nsxlv3)JHPNikl4RNmPQQbSlpxJIEUMy6ccocnJteLf81tAMbdCewXyCi2BxMeiwd7WJc6LtykZWwSeGlxbHVJdCKv4bfNcHH8TrdyhjkgJdXE7G5bzHhHVn3WwSeGlxrkjKlHVJdCUz2Ize)qlS)3KQeaoO1ojYk8GItHtEDqav0m7KJD4eQOGtQMv4bfNcN8e5yKXr9Ns7MUgCQU1J6FUMy6ccocnJtQBq6ak(fxH1a25j6Mikl4RNqUnqzgCgMuLaWbT2jo8OGE5eMY8KxheqfnZo5yhoHkk4K6WJcQrVKWuMNqAAvC0vynGDEetEICmY4O(tPDtxdov3ejH9wDzqahaAZJy9O0nxtmDbbhHMXjIYc(6jLa552YkWkFRfVUI3)tjXILaCzs9oHVJdCKv4bfNcHH8TrdyhjkgJdXE7GJScpO4uiSflb4YKtcFhh4iRWdkofcd5BJgWos9oKVnAa7MuLaWbT2jo8OGE5eMY8KxheqfnZo5yho5jYXiJJ6pL2nDn4uDtOIcoPo8OGA0ljmLzn6FGU(1JICmxtmDbbhHMXjIYc(6je(ooWOkHHzpMJxNGEgSy0Ez)dcTGZaS)hjKlHVJdCKv4bfNcH9)iPeip3wwbw5BT41v8(JDRH0DYtKJrgh1FkTB6AWP6M86GaQOz2jh7WjurbNykSDYJ8dZ4KQeaoO1obdBN8i)WmUEuv6CnX0feCeAgNikl4RNucKNBlRaR8Tw86kEVs(jHCj8DCGJScpO4uiS)3KNihJmoQ)uA301Gt1n51bburZSto2HtOIcoXuy7en6LeMY8KQeaoO1obdBN4LtykZRhL75AIPli4i0moruwWxpPzgmWr4W2aNq1EbbGdATtEDqav0m7KJD4KQeaoO1oj3mBXmIFODIKWERUmiGdaT5rmHkk4ePz2Ize)q7KNihJmoQ)uA301Gt1TEu1MRjMUGGJqZ4erzbF9KjprogzCu)P0UPRbNQBYRdcOIMzNCSdNqffCIjowWRdUg9g5rUNuLaWbT2jihl41b3JGh5E9OE8CnX0feCeAgNikl4RNeQgqg6HhwayUI31nPkbGdATt4Gh5dG8kHHs41SgltEDqav0m7KJD4eQOGtip4r(ain6RByOeA07I1yzYtKJrgh1FkTB6AWP6wpQkzUMy6ccocnJteLf81ti8DCG)yVHwpMJxNGELa552YkW(FKq474aNBMTygXp0c7)rsOAazOhEybGzsPBYtKJrgh1FkTB6AWP6M86GaQOz2jh7WjurbNqEGHK(aNbn6nY49KQeaoO1oHdmK0h4m4rW496rrNoxtmDbbhHMXjIYc(6jqSg2Hhf0lNWuMHTyjaxUcvKBVguqsEqXyCi2BNNfdvx5kt474ahzfEqXPqy)V6N8e5yKXr9Ns7MUgCQUjVoiGkAMDYXoCcvuWjKpil0O3OVn3tQsa4Gw7eEqw4r4BZ96rrtpxtmDbbhHMXjIYc(6jLa552YkWkFRfVUI3)tjHW3Xbg5ybVo4EomLFg2)Jel6yXCsqWXjvjaCqRDIdpkOxoHPmp51bburZSto2HtOIcoPo8OGA0ljmLzn6F4V(jprogzCu)P0UPRbNQB9OO)NRjMUGGJqZ4erzbF9KsG8CBzfyLV1IxxX7)PKq474aJCSGxhCphMYpd7)rsOAazOheRHD4rb9YjmLzs9qOAazOhEybGzs9Uoscvdid9Wdlamx5kRR(jprogzCu)P0UPRbNQBYRdcOIMzNO0Q44KQeaoO1oXHhf0lNWuMNqffCsD4rb1OxsykZA0tAAvCC9OO1nxtmDbbhHMXjIYc(6jLa552YkWkFRfVUI3FS7jprogzCu)P0UPRbNQBYRdcOIMzNCSdNqffCIPW2jA0ljmLzn6FGU(jvjaCqRDcg2oXlNWuMxpkAYXCnX0feCeAgNikl4RNq474a3SglELi3OvlSflb4YKIoTYv(bcFhh4M1yXRe5gTAHTyjaxMue(ooWrwHhuCkegY3gnGDKtfJXHyVDWrwHhuCke2ILaCzsumghI92bhzfEqXPqylwcWLjfDLw)KNihJmoQ)uA301Gt1n51bburZSto2HtQsa4Gw7KM1yXRe5gTANqffCIlwJfn6RBKB0QD9OOR05AIPli4i0moruwWxpHW3Xbgvjmm7XC86e0ZGfJ2l7FqOfCgG9)MuLaWbT2jyy7Kh5hMXjVoiGkAMDYXoCcvuWjMcBN8i)WmQr)d01p5jYXiJJ6pL2nDn4uDRhfT75AIPli4i0moruwWxpjunGm0dpSaWCf0tEICmY4O(tPDtxdov3KxheqfnZo5yhoHkk4eYhKfA0BeJYKQeaoO1oHhKfEeyuwpk6AZ1etxqWrOzCIOSGVEcHVJd8h7n06XC86e0Reip3wwb2)JKq1aYqp8WcaZKs3KNihJmoQ)uA301Gt1n51bburZSto2HtOIcoH8adj9bodA0BKXBn6FGU(jvjaCqRDchyiPpWzWJGX71JI(XZ1etxqWrOzCIOSGVEsOAazOhEybG5kON8e5yKXr9Ns7MUgCQUjVoiGkAMDYXoCcvuWjKwsaon6jpWqsFGZWKQeaoO1orLeGZJdmK0h4mSEu0vYCnX0feCeAgNikl4RNm5jYXiJJ6pL2nDn4uDtEDqav0m7KJD4KQeaoO1oHdmK0h4m4rW49eQOGtipWqsFGZGg9gz8wJ(h(RF9O(tNRjMUGGJqZ4erzbF9KcJmWzGel6yXCsqWXjprogzCu)P0UPRbNQBYRdcOIMzNCSdNuLaWbT2jo8OGE5eMY8eQOGtQdpkOg9sctzwJ(h0v)6r9tpxtmDbbhHMXjprogzCu)P0UPRbNQBIOSGVEsOAazOhEybG5kOjjunGm0dI1Wo8OGE5eMYmPcvdid9WdlampH00Q4ORWAa78iMuLaWbT2jo8OGE5eMY8KxheqfnZorPvXXjurbNuhEuqn6LeMYSg9pqAAvCuJ()6NijS3Qldc4aqBEgxpQ))5AIPli4i0moHkk4etHTt0OxsykZA0)WF9tEICmY4O(tPDtxdov3KxheqfnZo5yhoruwWxpPWidCgMuLaWbT2jyy7eVCctzE96jYhQabhq6hnGDJ639)6n]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170402.123043, [[dauDoaqikIOnrrAuOQCkuvTkkIWRujv1Ui0We4yOYYurpJGMgfr5AuePTrr9nQQgNkroNqrnpiPUNkj7tLWbfQwif6HQKYevjvCrkyJueoPkyLcf5LuevZuOWnHKStuSuvONImvQk7v6VcAWe4WkTyu6XuAYuPld2mv5ZOkJMkoTQEneMnPUTI2nu)MKHRsDCHsworpxHPl66cz7qIVRsuJxLuPZdrRxLuL5luQ9dPUC1xjd4LvdU1yjYk)7SujMDcLidXaTadAyc4C1OfCWcErsKLocAyhqzod48hi88sICLOBW(R(VEB(kCzonFwkUnFfEuFLHR(kzaVSAWTglrw5FNLmjZ3I4X8kfN91FISKNENq4Wrzru6a29TBQKLWkmuIzNqjtO3jGwa5OSiqlGVa(lDe0WoGYCgWzMZVyGWML5S(kzaVSAWTglrw5FNLyJ88ebRJcgHkVW0bc5jHndhryxq(yEIr3MoxqpsPAkAJKsaNxC1Lmx6iOHDaL5mGZmNFXaHLoGDF7MkzjScdLIZ(6prwcwz6eROfbuIzNqjdRmDIv0IaAwgH1xjd4LvdU1yjYk)7SeBKNN4BbVijsXOBtNlOhPunfTrsjGZlU6sMlfN91FISKNunYWHJYIO0bS7B3ujlHvyOeZoHsMqQgjAbKJYIO0rqd7akZzaNzo)IbcBwgtw9vYaEz1GBnwISY)olnxqpsPAkAJKsaNxCvmFIoMkDe0WoGYCgWzMZVyGWshWUVDtLSewHHsXzF9NilbRmDchoklIsm7ekzyLPdAbKJYIOzzmP1xjd4LvdU1yjMDcLOujNia4gKLIZ(6prwAKk5eba3GS0bS7B3ujlHvyO0rqd7akZzaNzo)Ibclrw5FNLsfpEAqCL57T2mCzF9NinLV1MpkqiGH5dJl4IDShqMpM3qC5XtcJXJceosLCIaGBqYFZYyU(kzaVSAWTglrw5FNLkDe0WoGYCgWzMZVyGWshWUVDtLSewHHsXzF9NilbAyc4C1HS6DKLy2juYGgMaoxnAbg17iBwg)1xjd4LvdU1yjYk)7S0Cb9iLQPOnskbCI6R8BUuC2x)jYsVf8IKilDa7(2nvYsyfgkXStO0bl4fjrw6iOHDaL5mGZmNFXaHnlZLQVsgWlRgCRXsKv(3zP1MpkqiGH5dJlUsyP4SV(tKL0FSIE3W5YBUHPkHzPdy33UPswcRWqPJGg2buMZaoZC(fdewIzNqPy8Xk6DrlavlV5IwGpvcZMLjMRVsgWlRgCRXsKv(3zj2ippXB1LbzOYlmDGW5c6rkvtXOBtzJ88ehPsoraWnifJUnDT5Jcecyy(Wa1clfN91FISK(55K4hZlKvPZshWUVDtLSewHHsm7ekfJNNtIFmp0cmQ0jAb8rMC(lDe0WoGYCgWzMZVyGWMLHlO(kzaVSAWTglrw5FNLCvPONENq4WrzrikH5(4Xf2DKH5pb0XuPJGg2buMZaoZC(fdew6a29TBQKLWkmuko7R)ezj9IYgYgjhzjMDcLIXIYIwGXi5iBwgoU6RKb8YQb3ASezL)DwInYZt8TGxKePy0TP8nxqpsPAkAJKsaNxC1zqSJnBKNN4BbVijsrjm3hpqnF8SUMeSrEEIVf8IKifh5ArC954N)sXzF9Nil5jvJmC4OSikDa7(2nvYsyfgkXStOKjKQrIwa5OSiqlGpo(lDe0WoGYCgWzMZVyGWMLH7S(kzaVSAWTglHQ96(ZOPVvYdYrjHLiR8VZsZf0JuQMI2iPeW5fxDgykBKNNiOHjGZvh6PSrdXOBtLGNegolRgqhtLIZ(6prwYtVtiC4OSikDa7(2nvYsyfgkXStOKj07eqlGCuweLUgsRg8TsEqokBPJGg2buMZaoZC(fdewICuxgvk337b5OSnldNW6RKb8YQb3ASezL)DwAUGEKs1u0gjLaoV4QZatzJ88ebnmbCU6qpLnAigDBkF8T28rbcbmmFyC1PPRnFuGqxvk6P3jeoCuweO(K)yhB(wB(OaHagMpmU4kHMU28rbcDvPONENq4WrzrGAH8ZFP4SV(tKL807echoklIshWUVDtLSKfPvdLocAyhqzod4mZ5xmqyjMDcLmHENaAbKJYIaTa(44Vzz4mz1xjd4LvdU1yjYk)7SeBKNN4BbVijsXO7sXzF9Nil5jvJmC4OSikDa7(2nvYsyfgkHkfkpMxz4kXStOKjKQrIwa5OSiqlGVt(lDe0WoGYCgWzMZVyGWsKJ6YOs5(Epih1yPR5aweOsHcmbCwJnldNjT(kzaVSAWTglrw5FNLMlOhPunfTrsjGZlU6sMlfN91FISeSY0jC4OSikDa7(2nvYsyfgkDe0WoGYCgWzMZVyGWsm7ekzyLPdAbKJYIaTa(44Vzz4mxFLmGxwn4wJLiR8VZsSrEEIsyOWl2cHPkHPOeM7JhOMlO0rqd7akZzaNzo)IbclDa7(2nvYsyfgkXStOKpvct0cq1osqISuC2x)jYsPkHz4Chjir2SmC(RVsgWlRgCRXsKv(3zj2ipprW6OGrOYlmDGqEsyZWre2fKpMNy0DPJGg2buMZaoZC(fdew6a29TBQKLWkmuIzNqjdRmDIv0IaqlGpo(lfN91FISeSY0jwrlcOzz4Uu9vYaEz1GBnwIzNqPy88Cs8J5HwGrLolDe0WoGYCgWzMZVyGWshWUVDtLSewHHsXzF9NilPFEoj(X8czv6SezL)DwInYZt8wDzqgQ8cthiCUGEKs1um6201MpkqiGH5ddulSzz4I56RKb8YQb3ASezL)DwAT5Jcecyy(W4cUshbnSdOmNbCM58lgiS0bS7B3ujlHvyOeZoHsxZzFmAbX455K4hZRuC2x)jYswN9XH6NNtIFmVML5mO(kzaVSAWTglrw5FNLkfN91FISK(55K4hZlKvPZshWUVDtLSewHHsm7ekfJNNtIFmp0cmQ0jAb8XXFP4sEJsLocAyhqzod4mZ5xmqyjYrDzuPCFVhKJYw6AoGfbQuOataNLTzzo5QVsgWlRgCRXsKv(3zPPcLhZZuj4jHHZYQHshbnSdOmNbCM58lgiS0bS7B3ujlHvyOuC2x)jYsE6DcHdhLfrjMDcLmHENaAbKJYIaTa(o5VzzopRVsgWlRgCRXsKv(3zPPcLhZZ01MpkqORkf907echoklcuV28rbcbmmFyu6iOHDaL5mGZmNFXaHLoGDF7MkzjlsRgkXStOKj07eqlGCuweOfW3j)OfCnKwnuko7R)ezjp9oHWHJYIOzzofwFLmGxwn4wJLiR8VZstfkpMxPJGg2buMZaoZC(fdew6a29TBQKLWkmuIzNqjdRmDqlGCuweOfW3j)LIZ(6prwcwz6eoCuwenBw66aEBKoRXMTa]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170402.123043, [[d0ZqoaGEqIQnbsTlkABIW(erntvIMnI5tsk3uePld9nrPdl1orL9QSBG9RQAuOQAyI0Vj14ajCEuLbdQgoOCqrLtrsCmKCCvcwifSurvlgPwov9quv6PepMspxvMiirAQurtgftx4IuOtl5zKuxheBuLqhcKi2Sk12ffFMk9Dretdvfmpqs3wf)fLgnjgpir5KQKohjP6AOQq3JKKvIQIwMQYRPcpQ5CIrqttqMzycukE3qiXmmrS(cwmzsEKG9dh3xkv2u1FqHj1ebgARMuq5DuAW4(s8njNnkn4nNJJAoNye00eKzgMiwFblMaLeL1rbCNKJUivWBYnPpi7trBDm5kGPSDO9taAaoHRp4Kls6d(dxu0wh)W5pvLj5rc2pCCFPujOYAMQEX4(MZjgbnnbzMHjI1xWIj0qUVnrRIgFS6B2qbzD9yhSpiag0xaxtiWG(0i5fE9X0cX7rqKSQGIetYJeSF44(sPsqL1mv9KRaMY2H2pbOb4KC0fPcEtW2hkxas7aNW1hCIX2hkxas7axmo1Z5eJGMMGmZWeX6lyXKtJKx41htleVhbrYQs1)(5Zj5rc2pCCFPujOYAMQEYvatz7q7Na0aCso6IubVjy7df2NI26ycxFWjgBFO8dxu0whlghFyoNye00eKzgMW1hCIeA)XbIWq)KC0fPcEtEH2FCGim0p5kGPSDO9taAaojpsW(HJ7lLkbvwZu1teRVGftcTRlbnBFu3TnyB6IubpO5VTrLbzraEk8LmLQPApmIc4(mBxxp(EvgK9fA)XbIWqVklghFCoNye00eKzgMiwFblMmjpsW(HJ7lLkbvwZu1tUcykBhA)eGgGtYrxKk4nbj4bbrtyPj9lMW1hCIrcEqq0KF4gi9lwmUeZ5eJGMMGmZWeX6lyXK2gvgKfb4PWxYQs9KC0fPcEti1fGumSN290SHoWZKRaMY2H2pbOb4K8ib7hoUVuQeuzntvpHRp4KlRlaPy(HN0290)WDQd8SyCzNZjgbnnbzMHjI1xWIjm6W8M0hK9POTom94PlWlzB)c2Oo4pFojpsW(HJ7lLkbvwZu1tUcykBhA)eGgGtYrxKk4nH0zAwAi(xmHRp4Kl7m9pCdq8VyX4GI5CIrqttqMzyssBOS6a54S9Uy8MOEIy9fSyYPrYl86JPfI3JGizv9LcnnK7BtKGheenH9wBH8mHadApE7XNsttWF(Cso6IubVj3K(GSpfT1XKRaMY2H2pbOb4eU(GtUiPp4pCrrBDmHV8Se0z7DX4n6j5rc2pCCFPujOYAMQEIOOtss1m1DH(3OxmovFoNye00eKzgMiwFblMCAK8cV(yAH49iiswvFPqtd5(2ej4bbrtyV1wiptiWGMF(BBuzqweGNcFQ6d62gvgKLrhM3K(GSpfT1bu)ur1un(BBuzqweGNcFjRk1q32OYGSm6W8M0hK9POToGQAvuzso6IubVj3K(GSpfT1XKRaMY2H2pXYZsWj5rc2pCCFPujOYAMQEcxFWjxK0h8hUOOTo(HZpLklghv6CoXiOPjiZmmrS(cwm50i5fE9X0cX7rqKSQGIetYrxKk4nbBFOW(u0whtUcykBhA)eGgGtYJeSF44(sPsqL1mv9eU(Gtm2(q5hUOOTo(HZpLklghf1CoXiOPjiZmmrS(cwmHgY9TPhFAqdSiBOd8y6XtxGhuPsNKhjy)WX9LsLGkRzQ6jxbmLTdTFcqdWjC9bN4uh45hEs7xGEEtYrxKk4nj0bEyp9lqpVfJJ6BoNye00eKzgMiwFblMqd5(2eTkA8XQVzdfK11JDW(GayqFbCnHaBsEKG9dh3xkvcQSMPQNCfWu2o0(janaNW1hCIX2hkxas7a)HZpLktYrxKk4nbBFOCbiTdCX4OupNtmcAAcYmdt46do5YYvjafW9hUbnjMKhjy)WX9LsLGkRzQ6jxbmLTdTFcqdWj5Olsf8MqkxLauaxwAnjMiwFblMqd5(2eMojONvFZgki7PrYl86Jjeyq32OYGSiapf(GQAOzqAi33MKYvjafWL1Rzmz0jbSyCu8H5CIrqttqMzyIy9fSycnK7Bty6KGEw9nBOGSNgjVWRpMqGbDBJkdYIa8u4dQQHUTrLbzz0H5nPpi7trBDa1Vj5rc2pCCFPujOYAMQEYvatz7q7Ny5zj4KC0fPcEtiLRsakGllTMet46do5YYvjafW9hUbnj(HZpF5zjOklghfFCoNye00eKzgMiwFblM02OYGSiapf(sMcAgKgY9TjPCvcqbCz9AgtgDsa)85K8ib7hoUVuQeuzntvp5kGPSDO9taAaoHRp4e(Q0f4h(LLRsakG7KC0fPcEtSkDbyjLRsakG7IXrLyoNye00eKzgMiwFblM02OYGSiapf(sMcAAi33MKYvjafWL1RzmHad62gvgKLrhMKYvjafWL1RzGABJkdYIa8u4Bso6IubVjwLUaSKYvjafWDYvatz7q7Ny5zj4eU(Gt4RsxGF4xwUkbOaU)W5NV8SeuLj5rc2pCCFPujOYAMQEX4OYoNtmcAAcYmdteRVGftyqAi33MKYvjafWL1Rzmz0jbmjhDrQG3es5QeGc4YsRjXKRaMY2H2pbOb4eU(GtUSCvcqbC)HBqtIF48tPYKCE33Kj5rc2pCCFPujOYAMQEIOOtss1m1DH(3ONWxf06iP6m4bbXOxmokOyoNye00eKzgMiwFblM02OYGSiapf(sMc62gvgKLrhMKYvjafWL1RzGABJkdYIa8u4BsEKG9dh3xkvcQSMPQNCfWu2o0(jwEwcoHRp4KllxLaua3F4g0K4ho)uQ8dNV8SeCso6IubVjKYvjafWLLwtIfJJs1NZjgbnnbzMHjI1xWIjtYJeSF44(sPsqL1mv9KRaMY2H2pbOb4eU(GtUSCvcqbC)HBqtIF48)PYKC0fPcEtiLRsakGllTMelg3x6CoXiOPjiZmmrS(cwm5OZuaxO94ThFknnbNKhjy)WX9LsLGkRzQ6jxbmLTdTFcqdWj5Olsf8MCt6dY(u0wht46do5IK(G)WffT1XpC()uzX4(OMZjgbnnbzMHjI1xWIjhDMc4cDBJkdYYOdZBsFq2NI26aQTnQmilcWtHVj5rc2pCCFPujOYAMQEYvatz7q7Ny5zj4eU(GtUiPp4pCrrBD8dN)pv(HZxEwcojhDrQG3KBsFq2NI26yX4((MZjgbnnbzMHjI1xWIjhDMc4ojpsW(HJ7lLkbvwZu1tUcykBhA)eGgGt46doXy7dLF4II264ho)FQmjhDrQG3eS9Hc7trBDSyXeU(GteJx(d3ibpiiAYp8lZVyda]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170402.123043, [[d4ZYhaGEIkQnHsk2fH2MsQ9PevZujY3eWSvz(uGBsj1HvCBu8CLANQQ9kTBs7xv6NevQHrPgNsuEnrLmukj1GHOHdPoir5uevOJrrNdLKSqk0srPwmrwovwekXtrEmvToIQAIusYuPetwOPl6Ic60qDzW1HWgjQs)gvBwjSDusLVtb9vIkyAOKsZJOI8xc8mLKrtjXHqjXjfOptqxJOkoVQyLOKuldsgfkPQRzTukuhPdI1yjRcwmiUSgl9hgOefU0lYWdyanN7fPvblgexwInCWSH(rzBgWEfQLjAwI8om6Sujz(eZ1DT0VzTukuhPdI1yjY7WOZsjxOWdeXAcohc05UKmj8HZNsgI1OGTvGXvkOgX(j5UskxHsSHdMn0pkBZaM2L(ddusoG14lsYkW4A2pQAPuOosheRXs)Hbkz18eZ1sK3HrNLsUqHhiIMNyUUznSEwj5cfEGONZVi3qDBGbEo)ICdvXfyhiaoGb0CorhWmyDVCulZwowInCWSH(rzBU2mGO9Qsb1i2pj3vs5kusMe(W5tj08eZ1swZJ)HbkXcAh)4Qqikan3qWXsZ(xvlLc1r6GynwI8om6SKeIfletEcmcyMDcUhrhWmyDlNqvsMe(W5tPKNaJaMzNG7PuqnI9tYDLuUcL(dduYcpbMxKwp7eCpLydhmBOFu2MRndiAVQz)S2APuOosheRXsK3HrNLsUqHhi658lYnu3LydhmBOFu2MRndiAVQuqnI9tYDLuUcL(ddusEXo4fz4bmGMZvsMe(W5tPfyhiaoGb0CUM9lp1sPqDKoiwJLiVdJolLCHcpq0Z5xKBOUlXgoy2q)OSnxBgq0EvPGAe7NK7kPCfk9hgOeLChZlYWdyanNRKmj8HZNs7K7yeahWaAoxZ(xxlLc1r6GynwI8om6SuYfk8arpNFrUH6UKmj8HZNsWbmGMZjGz2j4EkfuJy)KCxjLRqj2WbZg6hLT5AZaI2Rk9hgOu4bmGMZ9I06zNG7Pz)bQLsH6iDqSglrEhgDwIvY5anfNTh04OEqe0r6GObgiHyXcXz7bnoQherG2ad8C(f5gQIZ2dACupi6aMbR7Llp2LydhmBOFu2MRndiAVQuqnI9tYDLuUcL(dduY4X5XxKYlc3tjzs4dNpLKoopkybc3tZ(xwTukuhPdI1yjY7WOZsSsohOP4S9Ggh1dIGoshenWajelwioBpOXr9Gic0LydhmBOFu2MRndiAVQuqnI9tYDLuUcL(dduYi42GtUWQWsYKWhoFkjbUn4KlSkSz)SQAPuOosheRXsK3HrNLgFIzDGaqbgmSxoQs)HbkXgHk)xKYK7WsYKWhoFk5qOcgFI5QGdVZsb1i2pj3vs5kuInCWSH(rzBU2mGO9QswZJ)HbkXcfU0lYWdyanN7fPm5oKLM9BAxlLc1r6Gynw6pmqj2iu5)Iu22dACupuI8om6SuohOP4S9Ggh1dIGoshelXgoy2q)OSnxBgq0EvPGAe7NK7kPCfkjtcF48PKdHky8jMRco8olznp(hgOelu4sVidpGb0CUxKY2EqJJ6bwA2VPzTukuhPdI1yP)WaLyJqL)lYGEybc3tjY7WOZs5CGMIypSaH7re0r6G4lRUeB4Gzd9JY2CTzar7vLcQrSFsURKYvOKmj8HZNsoeQGXNyUk4W7SK184FyGsSqHl9Im8agqZ5Erg0dlq4EyPz)MOQLsH6iDqSgl9hgOeBeQ8FrUewOvsfRcFrYMhlrEhgDwkNd0u8WcTsQyvOahpkc6iDqSeB4Gzd9JY2CTzar7vLcQrSFsURKYvOKmj8HZNsoeQGXNyUk4W7SK184FyGsSqHl9Im8agqZ5ErUeBwA2SeHg845WY5jXCTFuRr1Sfa]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170402.123043, [[dSJ9iaGEsvOnPOYUKOTjjTpsvXmLQQzJQBcf3MIVjPStvzVIDRY(jP(jPkyysLXrQsomvptcgmPy4svoij5uKQOJrKZbLswik1svuwmuTCv1dLu9uKLruEokMiuk1uLqtwHPR0fjQopPYLbxNuAJqP40q2SKy7sXVj8DPQyAkQY8Gs1JP0RrjJMe)vrojuYNLsxJuv6EsvPdPOQooPQAuKQuhPumK8ZX5WiSd9CdeIK3VAnY5GbU15Q1Ospipe2gQ4A5ByhAgWbNbYtwNuTUcY0RsPqupWICosp6lsC5jRQSqQSlsCmPyEsPyi5NJZHryh65gieTIVHfa9GFiv4ioA1fIzfFdla6b)qZao4mqEY6KQkvRSRqiSUbY6R4h6eheQUcyzHr0ag42GhcJy8CdekBEYsXqYphNdJWo0Znqivmw4g(zHqK9J6THwrBlhkTcbFi6ZXeQUcyzHr0ag42GhAgWbNbYtwNuvPALDfcH1nqwFf)qN4GqQWrC0QlKZyHB4NfcHrmEUbcLnVcPyi5NJZHryh65giu)i9RfnuRbJ3AC1AkkwWesfoIJwDH4i9RfnMmERXNwXcMqZao4mqEY6KQkvRSRqiSUbY6R4h6eheQUcyzHr0ag42GhcJy8CdekBEZlfdj)CComc7qK9J6THmoWz2VWuA1()WT6tFL1n38xNd3wYrTk7HU2PVyucNJZHXCFOYhyuCCoesfoIJwDHQWDdmXOiSScvxbSSWiAadCBWd9CdecB4UbuRHuewwHMbCWzG8K1jvvQwzxHqKIOpyedufe8zcEiSUbY6R4h6ehecJy8CdekBE6Bkgs(54Cye2Hi7h1Bd52f1atWbgeWG95nNBxudmneBzfUBGjgfHLf2D7IAGj4adcycPchXrRUqv4UbMyuewwHW6giRVIFiRolhc9CdecB4UbuRHuewwQ1uxNLdHMbCWzG8K1jvvQwzxHS5vnfdj)CComc7qp3aHK7)vr)ADwqiv4ioA1fc8)QOFToli0mGdodKNSoPQs1k7kecRBGS(k(HoXbHQRawwyenGbUn4HWigp3aHYMxTumK8ZX5WiSd9CdeQFVXvRHT2pZgISFuVn0qSLv4UbMyuewwLFW4OJrFSoZoTidmhU2kvk5EJpXO93cLA7n38xNd3wYrTk7HU2PVyucNJZHXCUDrnWeCGbbmyFEHQRawwyenGbUn4HMbCWzG8K1jvvQwzxHqyDdK1xXp0joiKkCehT6cX9gFcx7NzdHrmEUbcLnp9kfdj)CComc7qp3aHKZbdCRZvRHn3z2qK9J6THM)6C42soQvzp01o9fJs4CComMZTlQbMGdmiGb76BO6kGLfgrdyGBdEOzahCgipzDsvLQv2view3az9v8dDIdcPchXrRUqahmWToFcN7mBimIXZnqOS5HTsXqYphNdJWo0ZnqO(9gxTg2GBcPchXrRUqCVXNWb3eAgWbNbYtwNuvPALDfcH1nqwFf)qN4Gq1vallmIgWa3g8qyeJNBGqzZtQlfdj)CComc7qK9J6THgaU2kvk5OwL9qx70xmkhI(CHEUbcvxXrNAn9JAv2dDTHQRawwyenGbUn4HMbCWzG8K1jvvQwzxHqyDdK1xXp0joiKkCehT6czvC0nXrTk7HU2qyeJNBGqzZtskfdj)CComc7qK9J6THC7IAGPHyl5OwL9qx70xmWUBxudmbhyqatOzahCgipzDsvLQv2view3az9v8dz1z5qONBGq1vC0Pwt)OwL9qxRAn11z5qiv4ioA1fYQ4OBIJAv2dDTzZtswkgs(54Cye2Hi7h1BdHRTsLsU34tmA)TqP2EHuHJ4OvxiU34t4A)mBiSUbY6R4h6ehecJObDTHKc9CdeQFVXvRHT2pZQwJElPNHu9BzczenORTVsHMbCWzG8K1jvvQwzxHqKIOpyedufe8zc7q1vallmIgWa3g2HWigp3aHYMNuHumK8ZX5WiSdr2pQ3g6dv(aJIJZHqQWrC0QlufUBGjgfHLviSUbY6R4h6ehecJObDTHKc9CdecB4UbuRHuewwQ1O3s6ziv)wMqgrd6A7RuOzahCgipzDsvLQv2viuDfWYcJObmWTHDimIXZnqOSzdr2pQ3gkBca]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170402.123043, [[dadmcaGEQIAxOuBtQyMufmBkDtv4BuL2Pu2lz3i2pKyyI43QAOsLmyivdxfDqKQJHklePSuQQwmswUOwevLNcwMi9Cu1eHQYuHktwLMUWfHspdfUUuP2muvTDOOlR8zu0HLmoQICEPQrdPCBkojK0JH40u5Euf6VqHhcv51OKfNWjalPOS7kAcW3WF1Tnenbas2Dgce4F2v8tT0eoVjms9eBobW5qCL155kCprT0oPcOJeUNWlCQXjCcWskk7UIMaaj7odbXZKPDSp)W9eEb0PCwx0l48d3teGk56qQ4ZcipzcALzc66d3teqpZKxaPmZJ(URU2EmyMlK5tG)zxXp1st46W5LDcdb4H2qyD8yoZiHOeC83wzMaF3vxBpgmZfY8PqTuHtawsrz3v0e0kZeG7Jzqb9JIpwUxaDkN1f9cIpMbdtXhl3lW)SR4NAPjCD48YoHHaujxhsfFwa5jtaEOnewhpMZmsikbh)TvMjqHAmeobyjfLDxrtqRmtaeF2WA7Czb0PCwx0lGp(SH125Yc8p7k(PwAcxhoVStyiavY1HuXNfqEYeGhAdH1XJ5mJeIsWXFBLzcuOqqRmtaG1dOGow7mJeLff07kpK3qvHcja]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170402.123043, [[d8dPiaqyQwpK0ljQQDPQs8Avv8BKMPqX6uvvZwvoVqUjIOtt4BQQsxwPDkQ9kTBO2VI6NqQHrjJtvL6XqmukmyfA4OQdQihLOk6yu05iQsTqfSuIslMsTCsEir6PGLrk9CrMOQQyQOyYeX0v5IcCvsv6zefxhL2Oq1wvvjTzbTDsXhfk9ze10Ge(UQYijvX2qegnQmEePtsQClirxJuv3JOkCBewlrvYXjQCnltbeN)euCCk(Gl6TfqRxMy0LdkCUI8EgAmQDbLJjVs5wKF6qb5yx2D6jiJjw8vaPqe6WW0EsD(tqXPMTkqk6WW0EsD(tqXPMTkih7YUs0HqXGa1TzuyviXr)MyvUoCiT2fKJDzxjsD(tqXPouicDyyApgxrEVuZwfKNSl7MktZMLPqa2TFRKouyc5eu88ymI0vaeesNhdWCogzjw89)8iVArOe2(vi7eBbqqiDEmaZ5yKLyX3)ZJ8QfHsy7xbz336PTzTwMKW0YsMcaIsWFfobXkpS61S2Yuia72VvshkmHCckEEmgr6kaccPZJbyohJSel((FEuYg6SVRq2j2cGGq68yaMZXilXIV)NhLSHo77ki7(wpTnR1YKeMwwY0RxHeh9d(ehc3uqhkK4OFtShTdfsC0p4tCiCtShTdfoxrEVjmchvvyanddAskRUy1dtbsrhgM2t(dPMnlqAZOKe)IPLm6BQpj0Q)Isll9lK4OFmUI8EPou4h7jmchvvGbTHS6IvpmfqOe2(zOjO2fqC(tqXtyeoQQWaAgg0KSaWVic)jq1pbf3SwsitHeh9dy6qb5yx29pc1ICckUGS6IvpmfWSe6qO4uZOOqe6WW0E6Wsei(rvPMTkK4OFsD(tqXPouGu0HHP9MyvEZwfIqhgM2BIv5nBvqIiX)8iMi(TGxGWjDI9OnBvGu0HHP90HLiq8JQsnBvWF8CoWr)m0e0Szb)XZ5sPe2(zOjOzZc)zdD231Hcj(99I)8eNu6JQktbVzZcQMnlqUzZc2nB2RG)(8OKHgJou4h74u8vWGzEeCCAEm7kf9RaIZFckE6jiJliniZeiBb5yfi)8RIeCrVTGxi7eBHamNJrwIfFZJgkbHRIkOCm5LjIFl42IN4Ik4SkNKc82HcsP8rZJm0cbyohJSel(MhbbM8BrjJRiVxHFSJtXhiqDB2uBHOghL)2sERffwKW08VYyPv7FTAikrH(fmuccxfnpk15pbfppoXQ8cWrve2kbM8Qk4pEoh4OFgAmA2SGAFfKgKzcKTW5kY7fNIVcgmZJGJtZJzxPOFf8hpNZ4kY7zOjOzZcrOddt7j)HuZOuBHFSJtXhCrVTaA9YeJUCqb)XZ5tVppkzOjOzZcoRY1HdPmr8BbB2WWcNRiVxCk(Gl6TfqRxMy0LdkqsNubblX8iJGyBwgRceoPatZMfaeLG)kuWF8C(07ZJsgAmA2SG9tGkQX(OF1UaVsq4QO4u8bcu3Mn1wGxTiucB)MmIPaiiKopgG5CmYsS47)5rE1IqjS9RqIJ(j)nYwGLiWKtDOaHt6uqZwfy83IV5Xyvuw(MTkCUI8EgAcQDbz336PTzTwM)1sgT)(xmlyOeeUkAEuQZFckUqs5NGwGxjiCvKoekgeOUnJcRcec8e7rB2QaHapf0SmfCwLd877P7pnR1Y83Oq)ccSebIFu1egHJQkiRUy1dtHeh9thwIaXpQk1HcHu8vysj838y2vk6xb)95rjdnbDOqIJ(zOXOdfsC0VPGouaHsy7NHgJAxiXr)m0e0HccekwErPenBQFHe)(EXFEIR2fieyGPzRcNRiVxCk(abQBZMAl4pEoNXvK3ZqJrZMfqC(tqXXP4RGbZ8i4408y2vk6xb)XZ5sPe2(zOXOzZcby3(Ts6qHKGG)TtOdAwMcYXUSReDyjce)OQuhky)eOIASp6307v7cio)jO44u8bcu3Mn1wqYg6SVBYiMcGGq68yaMZXilXIV)NhLSHo77kOrKe2IN4IyI43c2fKJvG8dCrVTGxGu0HHP9yCf59snBvqGqXaVJiWKBw)coRYNWiCuvHb0mmOjzmbXzkih7YUsItXhiqDB2uBbNv5mr8BbB2WWcYXUSRe5pK6qHeh9d(ehc3e6GouWzvUEXIRa)ZJwvVwa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170402.123043, [[d8JAiaWyaRxvvVKuk7sjvTnsj9BKMjLIPbuA2k15vIBIQkNMW3iH45sStjTxXUbTFPYpbYWKIXrcvxwXqPKblvnCeDqP0rrvv6yQIZrcLfQQSusWIjQLtXdjspfAzuQwNQkMOsQmvumzIy6QCrs6QKs8mGQRJsBujzROQk2mPA7KIpQKYHP6ZOkFxvAKKs1RvvPrJkJhvLtsIUfjKUgqX9qvv1TryTOQQCCkLopHjiGtEckCffE4TSNGG0cJnkRQbbCYtqHROWdf)NuFSh04qEJuUb438f0w2HDA3cEqIbEbbcUasxVmNuN8euyj1MG8bsxVmNuN8euyj1MG2YoSJeLauik(pPc2MGfo6BlRXvc1ProOTSd7irQtEckSKVGlG01lZX4gEZvsTji)LDyNsys9jmbvHU8EKKVGTaNGc76TruUGOGqAxVkKZHadXaVF66jndaLq2VGvNycIccPD9Qqohcmed8(PRN0maucz)cQWShVmPAV5bmnAD92T)eebmcYl4jig(FtUuThMGQqxEpsYxWwGtqHD92ikxquqiTRxfY5qGHyG3pD9sgDNDFbRoXeefes76vHCoeyig49txVKr3z3xqfM94Ljv7npGPrRR3U9NC5cw4OV4R4a4AvJCWch9TL9OroyHJ(IVIdGRL9O5lOZACLqDkZc5euMvxp4swPOAfmnk2tJIbUIao4nGvXbVj6kkybtWfq66L502xj1MGfo6lJB4nxjFb)vUfcWrnbzazPGY10otqakHSFwAuJCqaN8euyleGJAc(bIHbe)ckLsU01ZqdQc5CiWqmWRRVfKAWch9fzYxqBzh2zDcZaCckmOckxt7mbHSekbOWsQGn4ciD9YCkHsea(rnLuBcw4OVsDYtqHL8fKpq66L5AznEQnbxaPRxMRL14P2eKW5RL9OP2eKpq66L5ucLia8JAkP2e03KCoYrFT0OM6tqFtY5sPeY(zPrn1NGvNycQc5CiWqmWRRVfKAqF)6lflnw5l4VYROWlOftxp6WsxF1ng6BqaN8euy7wWdguQALrvHG2Yka(L)ik4TSNGYbLikKBFHzHCcce04qEdZc5e0LfBXTe0zno)eWjFbx3O7S7lFb)vEffEO4)K6J9GoRXzwiNGYS66bTmcc3S01l1jpbf213YA8G4rneYgbK3ycYxQnbnZoOu1kJQcbp3WBUvu4f0IPRhDyPRV6gd9nOVj5Cg3WBolnQP(eKW5dzsTj4VYROWdVL9eeKwySrzvnOVj5CKJ(APXk1NGNB4nxleGJAc(bIHbe)uq5AANj45gEZTIcp8w2tqqAHXgLv1G8Z5tqWs01ZiiMubVjisoacFl(7NGct1UwbpicyeKxWIaYBpb9njN3UF9LILgRuFcEUH3CwASICqsJGWnlROWdf)NuFShK0maucz)ATSjikiK21Rc5CiWqmW7NUEsZaqjK9lOofEbBncF31xDJH(gKW5Rvn1MGm(EGxx)AgklzQnbp3WBolnQroyHJ(QTzrwaLiG8k5lOcZE8YKQ9MhfPbC7k(6FcAzeeUzPRxQtEckmyX4NGgK0iiCZIsakef)NubBtqcbSL9OPcEq5T4))120329oYbjeWw1ubpyHJ(Qekra4h1uYxqN14i5S3kxxQnb99RVuS0OMVG(MKZzCdV5S0yL6tWch9TvnYbbOeY(zPXkYblC0xlnQ5lyHC27vBVWf5Gfo6RLgR8fKqarMubp45gEZTIcpu8Fs9XEqbafY)OuIuFatqaN8eu4kk8cAX01JoS01xDJH(g03KCUukHSFwASs9jOk0L3JK8fSiii3tli1ubpOTSd7irjuIaWpQPKVGcOebGFutleGJAcQGY10otqjJUZUVwlBcIccPD9Qqohcmed8(PRxYO7S7lOaGcrshqa5LkycQrueYIT4wywiNGYbL3I))xBtFJCqFtY5T7xFPyPrn1NG8bsxVmhJB4nxj1MGoRXBHaCutWpqmmG4NnQRycAl7WoswrHhk(pP(ypiFG01lZPTVsQnbTLDyhjA7RKVGfYzVxT9cNu6MActqp1NGYP(eKxQpbnP(KlOZACTafxqYTVmMCja]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170402.123043, [[d4dwiaGEvv9skLAxOuHxRQIdt1mvvCCjkZMKLjrUjePZlv(MevDAc7uk7vSBuTFf1pHWWivJJsHUnkgkrgScnCeDqPQJIsv6yQsNdLQyHkYsrPSyjSCkEOQspf8yK65sAIQQ0uryYuQMUkxejxvIkxwPRdPnQaBfLkAZuY2jkFub5ZOKPbr8DvXiPuYZuqnAsz8quNKO6wOuvxJsb3dLk53qTwuQuBJsrN3qeG2jpbMpaZp46uBaeLJ4J8gvGZnS2tsMukcyCoR9R2s)tMcuOe))pKc)KIaDiSSQ791jpbMxttpaYiSSQ791jpbMxttpqzOl6AxonMdI)BAirpqvd)0JAC5ClCkcug6IU2)6KNaZRzkqhclR6EeUH1E100dWErx0TgI0EdrakUxOw7zkqp9jW85XpI6faO(mpsPwMLFUAEuYS0yMc)c0CMnaq9zEKsTml)C18OKzPXmf(fGTvTEDtRK(RnF11hoaqBeKxGtWSSl9CPvkebO4EHATNPa90NaZNh)iQxaG6Z8iLAzw(5Q5XFxlhvDbAoZgaO(mpsPwMLFUAE831Yrvxa2w161nTs6V28vxF4aaTrqEbYLlqvd)apIJwRNktbQA4NE0dNPavn8d8ioATE0dNPaNByTxpNwdBcmHGGabszt(q2IiaYiSSQ7z7PAA6b6qyzv3Z2t100du1WpeUH1E1mf4NIEoTg2eGaHeBYhYwebOXmf(jjJkfbODYtG59CAnSjWeccceinWxmz38iboaLAzw(5Q5XEeubQA4hGitbkdDr3FfML(eyEa2KpKTicWrzKtJ510qsGk5QuduEv7lwHnHiGN2BGI0EdWkT3aM0EZfOQHF(6KNaZRzkaYiSSQ71JA800d0HWYQUxpQXttpaJJCp6HttpaYiSSQ7jNBxq7h2uttpGRi1Cqd)ijJkT3aUIuZ)Izk8tsgvAVbAoZgGsTml)C18OKrW4MUa2fvsL3r0rUb8aU6X7QsYKYuGFkgG5xajI5rW515XMBm4Na0o5jW8ELGfpWxQgbfBbkdvq)d7uuHRtTb8aDiSSQ7jNBxq7h2uttpGX5SwIoYnGxiuIRlGJACKk4BMc4OgNOJCduGAzf4NIby(bI)BAVLc87A5OQltbKmcg30np(1jpbMpp2JA8ab6Ya23g1zpLqIUnFFl)W6LkvE9yX(iXgcywvGVunck2cCUH1EdW8lGeX8i4868yZng8taxrQ5eUH1EsYOs7nGRi1Cqd)ijtkT3a)umaZp46uBaeLJ4J8gvaKryzv3JWnS2RMMEabnMdKoTGZknBiW5gw7naZp46uBaeLJ4J8gvaK6ilyqzMhjemBAdRha500da0gb5fiGRi18E1J3vLKjL2BGYqx0TxjyXzw(fGoaPrW4MUby(bI)BAVLcqAwAmtHF9sFcauFMhPulZYpxnpkzwAmtHFbQA4hBVDfcUDbNvntbyCK7PstpaHRw(npoKbJsMMEGZnS2tsgvkcW2QwVUPvs)T86dxYgzhVbKmcg30np(1jpbMh4CdR9Qbincg30jNgZbX)nnKOhGrW7rpCA6beC7cA)WMEoTg2eGn5dzlIawy(fO3iC18yZng8tah14a5QuY)nn9avn8JCUDbTFytntbye8EQ0goGRE8UQKmQmfqqJ5SBmMjTH1du1Wp9uzkanMPWpjzsPiGRi1Cc3WApjzsP9gOsUk1aLx1srGQg(rsgvMcWi4arA6bo3WAVby(bI)BAVLcu1WpsYKYuaAN8ey(am)cirmpcoVop2CJb)eWvKA(xmtHFsYKs7naf3luR9mfOkyivBpcQ0kfOm0fDTlNBxq7h2uZuGcL4))Hu4NELkfbODYtG5dW8de)30ElfqMOkkekX1r0rUbkc4ksnVx94DvjzuP9gGXrgis7nGJAC5Clmrh5gOa1YkG91YrvxV0Naa1N5rk1YS8ZvZJ)UwoQ6c4OgVNtRHnbMqqqGaPFOgqeOm0fDTpaZpq8Ft7TuaGCPfUs83pbMNwjBwkqzOl6A32t1mfOQHFGhXrR1JGktbCuJxoU4cqQ8U1Klb]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170402.123043, [[d4ZjiaGEvv9ssQAxeLYRLqDyPMPQk3MqZMIXPiQBcr68k4BeLQtJQDsL9k2nk7xv6NqyyKQFd1LvAOKyWQIHJWbLOJsusDmf6CKu0cvvwkrXIjYYPQhQi9uWYOepxsteIQPcPjtjnDvUibxLKkpdP01r0gLGTsuI2mLA7evFur4ZivtdIY3vuJKKsBdIy0KY4rkojj5wKu4AkICpIs4XizTeLKJlHCgdAaQM44ywbm7GBWSbqOo0FQCcbU2tFpf5krkGVz03PAlvX5lqrKl5wA40zIl7cqfyaHTDDVPnXXXSAC6bObHTDDVPnXXXSAC6bkICjxRQOWmG)FJdz6bQA45ssFRIzJJuGIixY160M44ywnFbgqyBx3dT903RgNEazn5sU1Gg3yqdiWAjZAnFbkPooM9(8JxV4MCaxlUbaHFVpcMvCzxBEFu8lfwuQVaYSMTRBCw0hrYOUoTbakpN4cCCXvwONlolbnGaRLmR18fOK64y27ZpE9IdjbCT4gae(9(iywXLDT59b5RDtAUaYSMTRBCw0hrYOUoTY2yaGYZjUa5YfOQHNHz(rPvkePavn8Cj5HJuGQgEgM5hLwj5HZxGR903RKrPH9b(qGIIaPYOAc1IgyifudKmjD1CuxnPv2PLwDKnzA1JTAGSjfyaHTDDp1)vJtpqvdpJ2E67vZxGILkzuAyFauekYOAc1IgGclk1NICHifGQjooMvYO0W(aFiqrrG0atXedVpO4acMvCzxBEFkrieOQHNb08fOiYLCro3VuhhZciJQjulAagPOkkmRghYcmGW2UUNkMvovFyFno9avn880M44ywnFbObHTDDVssFhNEGbe2219kj9DC6beBAkjpCC6bObHTDDpvmRCQ(W(AC6bAdHwdA4zf5cXngOneA9uSOuFkYfIBmGRf3acMvCzxBEFkrieOnZ9qvrUs(cuSubm7cOG((anR((4AVhphGQjooMvA40zbMk4qfKjqrKCQILL8kCdMnGuaR8kHPhqhi2aub8nJ(IoqSbAjUHFdbAsFJuoBZxaKV2nP5YxGILkGzhW)VXnAjqLynMcMUQnfBW(GgOJBmGpUXa0JBmGuCJ5cO45ITF49zAtCCm79PK03bkyAX99b0WufhGM40d4xtGPcoubzcCTN(EfWSlGc67d0S67JR9E8CG2qO1OTN(EkYfIBmaniSTR7P(VAC6bkwQaMDWny2aiuh6pvoHaTHqRbn8SICL4gdqdcB76EOTN(E140dCTN(EfWSdUbZgaH6q)PYjeaPnnCrsX3huU4ghT6bKm8))NWGNJuaGYZjUavoJUzd0gcTU0m3dvf5kXngGtHzartXz0JBsbi8CX2puaZoG)FJB0sac)sHfL6Ru5xaq437JGzfx21M3hf)sHfL6lqvdpR(DqIZSYz0R5lGyttPqC6bqBZYU3Nj8ysI40dCTN(EkYfIuafpxS9dVptBIJJzb89XXbKznBx34SOpk760AzYY2yacpxS9dQOWmG)FJdz6be5SsYdhNLaICwPqCwcyJzxGspVnVpU27XZbQA4zf5k5lqvdpRIzLt1h2xZxGM03aXAmQqEC6bAZCpuvKlKVaTHqRrBp99uKRe3yGQgEUuisbOWIs9PixjsbQA4zf5c5lqLynMcMUQfPaaXsXBd)FFCmloliXsarodqJZsGR903RaMDa))g3OLaCkmtwHXIXrREaQM44ywbm7cOG((anR((4AVhphOneA9uSOuFkYvIBmGaRLmR18fOYfjmBjcH4SeGZSYP6d7lzuAyFazunHArdue5sUwvXSYP6d7R5lGKH)))eg8CPXePaunXXXScy2b8)BCJwciNx5sCd)gqhi2asbAdHwxAM7HQICH4gdi20aOXPhOj9TkMngDGydirABhOj9DjJsd7d8Haffbs)juanqrKl5ATaMDa))g3OLawx7M0CLk)cac)EFemR4YU28(G81UjnxGIixY1Q6)Q5lqt6B0bInGePTDGM03QJXVaeMEy95sa]] )



end

