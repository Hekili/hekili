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
        addAura( 'lashing_flames', 'duration', 10, 'max_stack', 99 )
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170328.1, [[deKfGaqiufTiOOWMKsnkQOtjLSlummL4ysXYiINbfzAOQY1OczBqr13usnouf6CubSoQarZJkO7HQQ2hrXbHswOsYdHctKkq5IqfBevbJKkq4KOIMjvOUjQ0orPHcffzPqPEkPPcv6RqrP9Q6VkyWOQCyHftvpwPMmLUmyZu4ZqvJwHonsRMkq1RjQMnHBlv7w0VHmCI0XPcKwoINROPl56uPTtr(orPZtrTEOOOMpQW(rv63CCVItgEby)QRSrhUQ0og8Yho5yKBOdz5GKx(SGr4kQRoyGr4kQV6k2GaIjCwjlnRxWKeEKP5QUjuP11RyTlkkNh3Z2CCVItgEby)QR6MqLwxleE8cGHMfqiUsR5v2OdxXS00YlF6ieKRymcB5CrMGoK19xXgeqmHZkzPzDZYvotlDhfICnrjCflpvqlZxLLM2H5ieKRCrw2OdxFDwjh3R4KHxa27VQBcvADTq4XlaMncjSizZ5v2OdxDqaeeD2VIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmF1lqiRWDwx5ISSrhU(6Sy64EfNm8cW(vx1nHkTUwi84faZgHewKS5STtEgKIAe7IjeshJbzrcdgsKYLzHdoC2dqmlcQZSDjeilz4VKL2BesyrYMmBsmhheu8Jvst8meOh0C6q(taVRHXGS00IKTvRRSrhUYdaje8YNkLsO1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5RgajedtPucTUYfzzJoC91z53X9koz4fG9RUQBcvADnif1i2ftiKogdYIegmKiLlZsBPeW0a(TLPHXaiHyykLsO1v2OdxXGeZrE5ZXu8Jvst8xXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVUjXCCqqXpwjnXFLlYYgD46RZ6OJ7vCYWla7xDv3eQ06AHWJxamBesyrYMZ2o9UggmXCdPnYnW4kLdomasigMsPeAXqGEqZPmoQ1v2OdxxbKjqKtt8xXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMV6bYeiYPj(RCrw2OdxFDwm)4EfNm8cW(vx1nHkTUwi84faZgHewKS5STtVRHbtm3qAJCdmUs5GddGeIHPukHwmeOh0CkJJADLn6W1vceYYlF8GlX8vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5REbczhmCjMVYfzzJoC91zxFCVItgEby)QR6MqLwxleE8cGrkQOOC22P31WGXdKjqKtt8mUs5GJki4HIPODyOqdwk4q(J5lTUILNkOL5RsrffLx5mT0DuiY1eLWv2OdxXmHkkkVIfb)8AgDG)ygsjibkXd2bPizbcMXvSbbet4SswAw3SCfJrylNlYe0HSU)kxKLn6WvmdPeKaL4b7GuKSabZ41z5XJ7vCYWla7xDv3eQ06Q31WGXJCfwGyqNfdb6bnNoKaExdJbzPPfjlhC4ShGyweuNz7siqwoK)oAPDSlQjyasOtHPm8htTUYgD46kKRWced6SUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmF1JCfwGyqN1vUilB0HRVoRdCCVItgEby)QR6MqLwx9UggmEKRWced6SyiqpO50HeW7AymilnTiz5GdN7XGGhMdgKyxuugczAyw7O29aeZIG6mBxcbYYH8Fcvrt8tgpYvybIbDwd9aeZIG6TJDrnbdqcDkmDi)L06kB0HRRqUclqmOZIx(C206kgJWwoxKjOdzD)vSbbet4SswAw3SCLZ0s3rHixtucxXYtf0Y8vpYvybIbDwx5ISSrhU(6Snlh3R4KHxa2V6QUjuP11keqwmIiTtb1cmqgEbyB7DnmyerANcQfyiqpO50HeW7AymilnTizBh7IAcgGe6uykZYv2OdxXgTL7PfqUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmFLG2Y90cix5ISSrhU(6Snnh3R4KHxa2V6QUjuP1vEw0TCAIVDpaXSiOoZ2LqGSKrIKRSrhUYdUeZ8YhYGx(WIsUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmF1WLyEazmeuYvUilB0HRVoBJKJ7vCYWla7xDv3eQ06AfcilMXGkMfI0zGm8cW227AyWyqqZYtI0YqGEqZPdjG31WyqwAArY22PtEwHaYIXWLyEazmeucdKHxa2wCWHZkeqwmgUeZdiJHGsyGm8cW2UhGyweuNz7siqwYiXrTADLn6WvEGGMLNeP9kgJWwoxKjOdzD)vSbbet4SswAw3SCLZ0s3rHixtucxXYtf0Y8vdcAwEsK2RCrw2OdxFD2gmDCVItgEby)QR6MqLwx9UggmgIOdfkX7cmeOh0C6qc4DnmgKLMwKSCWHZncjSiztglc1hKLM2jdb6bnNoeZB7DnmymerhkuI3fyiqpO50H8R1v2Odx5br0HcL4DHRymcB5CrMGoK19xXgeqmHZkzPzDZYvotlDhfICnrjCflpvqlZxnerhkuI3fUYfzzJoC91zB43X9koz4fG9RUYgD4Qdgc15LpmlnTZRy5PcAz(QfH6dYst78k2GaIjCwjlnRBwUYzAP7OqKRjkHRymcB5CrMGoK19x5ISSrhU(6Sno64EfNm8cW(vx1nHkTUwHaYIztI5inXpmlePZaz4fGTDSlQjyasOtHPm8htTDYZkeqwmJbvmlePZaz4fGLdo8Uggmge0S8KiTmeOh0Ckd(TT1v2OdxXGeZrE5ZXu8Jvst88YNZMwxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVUjXCCqqXpwjnXFLlYYgD46RZ2G5h3R4KHxa2V6kB0HR4eKAesE5tLsLdxXYtf0Y8vii1iKdtPu5WvSbbet4SswAw3SCLZ0s3rHixtucxXye2Y5ImbDiR7VYfzzJoC91zBwFCVItgEby)QR6MqLwxDwHaYIbzci7XGGhyGm8cW2UhGyweuNz7siqwYWF(T0MNviGSymCjMhqgdbLWaz4fGTfhC4ScbKfdYeq2JbbpWaz4fGTDfcilgdxI5bKXqqjmqgEbyB3dqmlcQZSDjeilz4hM36kB0HRoMIFSsAINx(wHe1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5Rck(XkPj(bpsux5ISSrhU(6Sn84X9koz4fG9RUQBcvAD17AyWSjXCCqqXpwjnXZqGEqZPdjG31WyqwAArY2o2f1emaj0PWug(l5kB0HRyqI5iV85yk(XkPjEE5ZPKwxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVUjXCCqqXpwjnXFLlYYgD46RZ24ah3R4KHxa2V6kB0HRywAANOe)vS8ubTmFvwAANOe)vSbbet4SswAw3SCLZ0s3rHixtucxXye2Y5ImbDiR7VYfzzJoC91zLSCCVItgEby)QR6MqLwxleE8cGzJqcls2C22P31WGzwis3tOjEGW4kT1v2OdxXAUH0g5gUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmFnMBiTrUHRCrw2OdxFDwjnh3R4KHxa2V6QUjuP1vVRHbZSqKUNqt8aHXvABNoRqazXy4smpGmgckHbYWlaB7EaIzrqDMTlHazjd)LG5T4GdN8ScbKfJHlX8aYyiOegidVaSTADLn6WvmlnTZIqLdxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVklnTZIqLdx5ISSrhU(6SsKCCVItgEby)QR6MqLwx9UggmZcr6EcnXdegxPTD6ScbKfJHlX8aYyiOegidVaST7biMfb1z2UecKLm8xcM3IdoCYZkeqwmgUeZdiJHGsyGm8cW2Q1v2Odx1cr6ZIqLdxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVolePplcvoCLlYYgD46RZkbth3R4KHxa2V6QUjuP1vWb1Lkvkyzc5bnDNdHFIeUfm4G7ol6gAxHaYIzevdJrAzGm8cW227AyWmIQHXiTmUsBZtVRHbJbbnlpjslJR02oDYZkeqwmgUeZdiJHGsyGm8cW2IdoCwHaYIXWLyEazmeucdKHxa229aeZIG6mBxcbYsgjoQvRRSrhUYde0S8KiT8YNZMwxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVAqqZYtI0ELlYYgD46RZkHFh3R4KHxa2V6QUjuP11keqwmJOAymsldKHxa22ExddMrunmgPLXv6v2OdxDCyk4LphhZXRymcB5CrMGoK19xXgeqmHZkzPzDZYvotlDhfICnrjCflpvqlZxfHPyqeZXRCrw2OdxFDwjo64EfNm8cW(vx1nHkTUg7IAcgGe6uykd)53v2OdxXGeZrE5ZXu8Jvst88YNtm16kgJWwoxKjOdzD)vSbbet4SswAw3SCLZ0s3rHixtucxXYtf0Y81njMJdck(XkPj(RCrw2OdxFDwjy(X9koz4fG9RUYgD4kMLM2zrOYbE5ZztRRy5PcAz(QS00olcvoCfBqaXeoRKLM1nlx5mT0DuiY1eLWvmgHTCUitqhY6(RCrw2OdxFDwjRpUxXjdVaSF1vDtOsRRviGSyqMaYEmi4bgidVaST3iKWIKnzeu8Jvst8dEKOyiqpO50HeW7AymilnTizB3dqmlcQZSDjeilz4XLRSrhUQfI0NfHkh4LpNnTUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmFDwisFweQC4kxKLn6W1xNvcpECVItgEby)QR6MqLwxRqazXy4smpGmgckHbYWlaB7EaIzrqDMTlHazjd)W82o3iKWIKnzeu8Jvst8dEKOyiqpO5ug8BlhCWZkeqwmitazpge8adKHxa2wxzJoCvlePplcvoWlFoL06kgJWwoxKjOdzD)vSbbet4SswAw3SCLZ0s3rHixtucxXYtf0Y81zHi9zrOYHRCrw2OdxFDwjoWX9koz4fG9RUQBcvADLNviGSyqMaYEmi4bgidVaST5zfcilgdxI5bKXqqjmqgEbyVYgD4QwisFweQCGx(CIPwxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVolePplcvoCLlYYgD46RZIPLJ7vCYWla7xDv3eQ06QtNXUOMGbiHofMY0WbhviGSy2Kyost8dZcr6mqgEby5GJkeqwmEKRWced6SyGm8cW2QnpNqn4rP7KPOaPXbg4N0TmlT4GddGeIHPukHwmeOh0CkJJUYgD4kgKyoYlFoMIFSsAINx(CYVwxXye2Y5ImbDiR7VIniGycNvYsZ6MLRCMw6oke5AIs4kwEQGwMVUjXCCqqXpwjnXFLlYYgD46RZIPMJ7vCYWla7xDv3eQ06AfcilMXGkMfI0zGm8cW227AyWyqqZYtI0YqGEqZPd5hdp22PtEwHaYIXWLyEazmeucdKHxa2wCWHZkeqwmgUeZdiJHGsyGm8cW2UhGyweuNz7siqwYiXrTADLn6WvEGGMLNePLx(CkP1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5Rge0S8KiTx5ISSrhU(6SysYX9koz4fG9RUQBcvADfCqDPsLcwMqEqt35q4NiHBbdo4UZIUH2807AyWyqqZYtI0Y4kTTtN8ScbKfJHlX8aYyiOegidVaST4GdNviGSymCjMhqgdbLWaz4fGTDpaXSiOoZ2LqGSKrIJA16kB0HR8abnlpjslV85etTUIXiSLZfzc6qw3FfBqaXeoRKLM1nlx5mT0DuiY1eLWvS8ubTmF1GGMLNeP9kxKLn6W1xNfty64EfNm8cW(vx1nHkTUwHaYIXWLyEazmeucdKHxa22viGSyqMaYEmi4bgidVaSTDoHAWJs3jtrbsJdmWpPBzwA3dqmlcQZSDjeilz4ppU06kB0HRoomf8YNJJ5iV85SP1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5RIWumiI54vUilB0HRVolM43X9koz4fG9RUQBcvADTcbKfJHlX8aYyiOegidVaST5zfcilgKjGShdcEGbYWlaBBNtOg8O0DYuuG04ad8t6wML29aeZIG6mBxcbYsg(7im16kB0HRoomf8YNJJ5iV85usRRymcB5CrMGoK19xXgeqmHZkzPzDZYvotlDhfICnrjCflpvqlZxfHPyqeZXRCrw2OdxFDwm5OJ7vCYWla7xDv3eQ06QtEoHAWJs3jtrbsJdmWpPBzwA3dqmlcQZSDjeilz4FJKLwCWHtEwHaYIXWLyEazmeucdKHxa22tOg8O0DYuuG04ad8t6wML29aeZIG6mBxcbYsg(ZVLwxzJoC1XHPGx(CCmh5LpNyQ1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5RIWumiI54vUilB0HRVolMW8J7vCYWla7xDv3eQ06Q31WGXqeDOqjExGHa9GMthYpgE8kB0HR8Gi6qHs8UaV85SP1vmgHTCUitqhY6(RydciMWzLS0SUz5kNPLUJcrUMOeUILNkOL5RgIOdfkX7cx5ISSrhU(6SyA9X9koz4fG9RUYgD4Q6MwGqt8xXYtf0Y81PBAbcnXFfBqaXeoRKLM1nlx5mT0DuiY1eLWvmgHTCUitqhY6(RCrw2OdxFDwmXJh3R4KHxa2V6kB0HRyJ2Y90ci8YNZMwxXYtf0Y8vcAl3tlGCfBqaXeoRKLM1nlx5mT0DuiY1eLWvmgHTCUitqhY6(RCrw2OdxFDwm5ah3R4KHxa2V6kB0HR8Gi6qHs8UaV85usRRy5PcAz(QHi6qHs8UWvSbbet4SswAw3SCLZ0s3rHixtucxXye2Y5ImbDiR7VYfzzJoC91z53YX9koz4fG9RUYgD46kKRWced6S4LpNsADflpvqlZx9ixHfig0zDfBqaXeoRKLM1nlx5mT0DuiY1eLWvmgHTCUitqhY6(RCrw2OdxF96Qkf20qqXmhffLNvcMJPx)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170328.1, [[diJVbaGEuq7cf51OKMjsHzt0nrvUTk2PI2l1Uf2pPQHjQ(TKHIuYGfHHRQoibDmsSquXsjvwmHwUQ8qrYtbpwLwhsrtePktfv1Kvy6sDrcCzORJuvhgXMrQ02rr9CszzIYNrY3rjopk04qQy0K0ZqPCsuQ(Mi1Pv6EiL6VIOfHkTnuGTI5BqqqeL4WCmmjh0aSNu6tiiujXfpy00uFI)dV1rK0gOhsxc9LT5yqhkrIg6zwUs6C2YOdtkgG7B)TbdcV9wHM57PI5BqqqeL4WCma33(BdDrrjrM(vVvOzqO4k3Mrd)Q3kmWEm2lPRNHOc0WKCqd0Q6TcdcFuAgcYbPn3)RKvqHJK)If8X1GouIen0ZSCL0k5gsPIxw5vmJhmAlAGxnMKdAG7)vYkOWrYFXc(462ZmZ3GGGikXH5yysoObASuQDSbL(eG6IYHbHIRCBgnixk1o2GkPM6IYHbDOejAONz5kPvYnWEm2lPRNHOc0qkv8YkVIz8GrBrd8QXKCqdUDBa(4DjYLHKERWZmgWMBBa]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170328.1, [[d4JRoaGEePQ2eIyxG61uK9jjmtevTmvvZgL5lPs3uviFts62sCievANi1Ev2Tk7NuAusQAyI04qKY5jfNgyWuWWvvoOKYPufCmKCojrAHuulvv0Iry5u6HQc1tjEmjpxuterQ0uPsMmitxQlsHEfIkCzORtvTrjv8BuTzQy7ikFMu13vLY0qurZtvQ(lv5zKkJweJhrQ4KQs2gvQRjjI7HizLisvoSWXLe1JAUMy8ccgcnZtiDrNWN1Z8e6OGteJKxRbJmSGxhmTgQLv4bfNcN8ezyKXr)Nsvnv3pPbtnruwWxpzsnvd4xEUgn1CnX4femeAMNikl4RN0C96ziSIZzq83Umjq8g2Hff0lNWvMGTyjaxUccFhh4iRWdkofcd5BJgWpsuCodI)2bZcYcpcFBUHTyjaxUIusixcFhh4CZTfti(Hwy)Vj1iamqRzsKv4bfNcN86GaQO52jh)WjprggzC0)PuUPQcNQBcDuWj1Yk8GItHRh9)CnX4femeAMN8OG0bu8lUcRESZt0nruwWxpHCBGYe40pPgbGbAntCyrb9YjCLPjVoiGkAUDYXpCcDuWj1HffuRbjHRmn5XAum0vy1JDEetEImmY4O)tPCtvfov3ejH)2J4qahaAZJy9O1nxtmEbbdHM5jIYc(6jLaz52YlWkFRfVUcs9NsIflb4YVtkcFhh4iRWdkofcd5BJgWpsuCodI)2bhzfEqXPqylwcWLjhe(ooWrwHhuCkegY3gnGFVtkiFB0a(nPgbGbAntCyrb9YjCLPjVoiGkAUDYXpCcDuWj1HffuRbjHRmP1q9upm5jYWiJJ(pLYnvv4uDRhn5CUMy8ccgcnZteLf81ti8DCGrvchZEChVob90BXO9Y(heAbNEy)psixcFhh4iRWdkofc7)rsjqwUT8cSY3AXRRGuKMBTKEtEImmY4O)tPCtvfov3Kxheqfn3o54hoPgbGbAntWW2jv2pmHtOJcoXyy7Kk7hMW1JUsMRjgVGGHqZ8erzbF9KsGSCB5fyLV1IxxbPQ0FsixcFhh4iRWdkofc7)n5jYWiJJ(pLYnvv4uDtEDqav0C7KJF4KAeagO1mbdBN4Lt4kttOJcoXyy7eTgKeUY06r7EUMy8ccgcnZteLf81tAUE9meoSnWjuTxqayGwZKAeagO1mj3CBXeIFODYtKHrgh9FkLBQQWP6Mij83Eehc4aqBEetOJcorAUTycXp0o51bburZTto(HRhD15AIXliyi0mpruwWxpzYtKHrgh9FkLBQQWP6M86GaQO52jh)Wj1iamqRzcYWcEDW8iyrUNqhfCIrgwWRdMwdMzrUxpAsBUMy8ccgcnZteLf81tcvdid9WdlamxbP0nPgbGbAntyGk7dG8kH(s418gltEDqav0C7KJF4KNidJmo6)uk3uvHt1nHok4eYdQSpasRHhf6lHwdU4nwwp6kDUMy8ccgcnZteLf81ti8DCG)4VHwpUJxNGELaz52YlW(FKq474aNBUTycXp0c7)rsOAazOhEybG531n5jYWiJJ(pLYnvv4uDtEDqav0C7KJF4KAeagO1mHb0N0h407rWz9e6OGtipqFsFGtVwdM5SE9OPsNRjgVGGHqZ8erzbF9eiEd7WIc6Lt4ktWwSeGlxHkYTxdkij1R4Cge)TZZIHQRBDj8DCGJScpO4uiS)3dtEImmY4O)tPCtvfov3Kxheqfn3o54hoPgbGbAntybzHhHVn3tOJcoH8bzHwdM9T5E9OPOMRjgVGGHqZ8erzbF9KsGSCB5fyLV1IxxbP(tjHW3XbgzybVoyEoCLFg2)Jel6yXCsqWWj1iamqRzIdlkOxoHRmn51bburZTto(HtEImmY4O)tPCtvfov3e6OGtQdlkOwdscxzsRH6)Fy9OP(NRjgVGGHqZ8erzbF9KsGSCB5fyLV1IxxbP(tjHW3XbgzybVoyEoCLFg2)JKq1aYqpiEd7WIc6Lt4ktVxFOAazOhEybG53jLoscvdid9Wdlamx36Q7HjprggzC0)PuUPQcNQBYRdcOIMBNO0Oy4e6OGtQdlkOwdscxzsRHhRrXWj1iamqRzIdlkOxoHRmTE0u6MRjgVGGHqZ8erzbF9KsGSCB5fyLV1IxxbPin3tEImmY4O)tPCtvfov3Kxheqfn3o54hoPgbGbAntWW2jE5eUY0e6OGtmg2orRbjHRmP1q9upSE0uKZ5AIXliyi0mpruwWxpHW3XbU5nw8krUrRgylwcWLFNkTU1TEcFhh4M3yXRe5gTAGTyjax(DcFhh4iRWdkofcd5BJgWpYHIZzq83o4iRWdkofcBXsaUmjkoNbXF7GJScpO4uiSflb4YVtvjpm5jYWiJJ(pLYnvv4uDtEDqav0C7KJF4e6OGtCXBSO1WJICJwntQrayGwZKM3yXRe5gTAwpAQkzUMy8ccgcnZteLf81ti8DCGrvchZEChVob90BXO9Y(heAbNEy)Vj1iamqRzcg2oPY(HjCYRdcOIMBNC8dN8ezyKXr)Ns5MQkCQUj0rbNymSDsL9dtOwd1t9W6rt5EUMy8ccgcnZteLf81tcvdid9Wdlamxb1KNidJmo6)uk3uvHt1n51bburZTto(HtQrayGwZewqw4rGrzcDuWjKpil0AWmgL1JMQ6CnX4femeAMNikl4RNq474a)XFdTEChVob9kbYYTLxG9)ijunGm0dpSaW876M8ezyKXr)Ns5MQkCQUjVoiGkAUDYXpCsncad0AMWa6t6dC69i4SEcDuWjKhOpPpWPxRbZCwR1q9upSE0uK2CnX4femeAMNikl4RNeQgqg6HhwayUcQjprggzC0)PuUPQcNQBYRdcOIMBNC8dNuJaWaTMjQKaCEmG(K(aN(j0rbN84KaCAnqEG(K(aN(1JMQsNRjgVGGHqZ8erzbF9KjprggzC0)PuUPQcNQBYRdcOIMBNC8dNqhfCc5b6t6dC61AWmN1Anu))dtQrayGwZegqFsFGtVhbN1Rh9F6CnX4femeAMNikl4RNu4Kbo9KyrhlMtccgo5jYWiJJ(pLYnvv4uDtEDqav0C7KJF4e6OGtQdlkOwdscxzsRH619WKAeagO1mXHff0lNWvMwp6FQ5AIXliyi0mp51bburZTtuAumCIOSGVEsOAazOhEybG5kOijunGm0dI3WoSOGE5eUY07HQbKHE4HfaMN8ynkg6kS6XopIj1iamqRzIdlkOxoHRmnrs4V9ioeWbG28mpHok4K6WIcQ1GKWvM0AO(hRrXqTg(FyYtKHrgh9FkLBQQWP6wp6))5AIXliyi0mpHok4eJHTt0Aqs4ktAnu))dtEImmY4O)tPCtvfov3Kxheqfn3o54hoPgbGbAntWW2jE5eUY0erzbF9KcNmWPF96jYhQabdq6hnGFJ(39)6n]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170328.1, [[dauDoaqikIOnrrAuOQCkuvTkkIWRujv1Ui0We4yOYYurpJGMgfr5AuePTrr9nQQgNkroNqrnpiPUNkj7tLWbfQwif6HQKYevjvCrkyJueoPkyLcf5LuevZuOWnHKStuSuvONImvQk7v6VcAWe4WkTyu6XuAYuPld2mv5ZOkJMkoTQEneMnPUTI2nu)MKHRsDCHsworpxHPl66cz7qIVRsuJxLuPZdrRxLuL5luQ9dPUC1xjd4LvdU1yjMDcLidXaTadAyc4C1OfCWcErsKLiR8VZsLocAyhqzod48hi88sICLOBW(R(VEB(kCzonFwkUnFfEuFLHR(kzaVSAWTglrw5FNLmjZ3I4X8kfN91FISKNENq4Wrzru6a29TBQKLWkmu6iOHDaL5mGZmNFXaHLy2juYe6DcOfqoklc0c4lG)ML5S(kzaVSAWTglrw5FNLyJ88ebRJcgHkVW0bc5jHndhryxq(yEIr3MoxqpsPAkAJKsaNxC1Lmx6iOHDaL5mGZmNFXaHLoGDF7MkzjScdLy2juYWktNyfTiGsXzF9NilbRmDIv0IaAwgH1xjd4LvdU1yjYk)7SeBKNN4BbVijsXOBtNlOhPunfTrsjGZlU6sMlfN91FISKNunYWHJYIO0bS7B3ujlHvyO0rqd7akZzaNzo)IbclXStOKjKQrIwa5OSiAwgtw9vYaEz1GBnwISY)olnxqpsPAkAJKsaNxCvmFIoMkDe0WoGYCgWzMZVyGWshWUVDtLSewHHsm7ekzyLPdAbKJYIOuC2x)jYsWktNWHJYIOzzmP1xjd4LvdU1yjMDcLOujNia4gKLIZ(6prwAKk5eba3GS0bS7B3ujlHvyOezL)Dwkv84PbXvMV3AZWL91FI0u(wB(OaHagMpmUGl2XEaz(yEdXLhpjmgpkq4ivYjcaUbj)LocAyhqzod4mZ5xmqyZYyU(kzaVSAWTglrw5FNLkDe0WoGYCgWzMZVyGWshWUVDtLSewHHsm7ekzqdtaNRgTaJ6DKLIZ(6prwc0WeW5Qdz17iBwg)1xjd4LvdU1yjYk)7S0Cb9iLQPOnskbCI6R8BUuC2x)jYsVf8IKilDa7(2nvYsyfgkDe0WoGYCgWzMZVyGWsm7ekDWcErsKnlZLQVsgWlRgCRXsKv(3zP1MpkqiGH5dJlUsyP4SV(tKL0FSIE3W5YBUHPkHzPdy33UPswcRWqjMDcLIXhRO3fTauT8MlAb(ujmlDe0WoGYCgWzMZVyGWMLjMRVsgWlRgCRXsKv(3zj2ippXB1LbzOYlmDGW5c6rkvtXOBtzJ88ehPsoraWnifJUnDT5Jcecyy(Wa1clfN91FISK(55K4hZlKvPZshWUVDtLSewHHshbnSdOmNbCM58lgiSeZoHsX455K4hZdTaJkDIwaFKjN)MLHlO(kzaVSAWTglrw5FNLCvPONENq4WrzrikH5(4Xf2DKH5pb0XuPJGg2buMZaoZC(fdew6a29TBQKLWkmuIzNqPySOSOfymsoYsXzF9NilPxu2q2i5iBwgoU6RKb8YQb3ASezL)DwInYZt8TGxKePy0TP8nxqpsPAkAJKsaNxC1zqSJnBKNN4BbVijsrjm3hpqnF8SUMeSrEEIVf8IKifh5ArC954N)sXzF9Nil5jvJmC4OSikDa7(2nvYsyfgkDe0WoGYCgWzMZVyGWsm7ekzcPAKOfqoklc0c4JJ)MLH7S(kzaVSAWTglHQ96(ZOPVvYdYrjHLiR8VZsZf0JuQMI2iPeW5fxDgykBKNNiOHjGZvh6PSrdXOBtLGNegolRgqhtLIZ(6prwYtVtiC4OSikDa7(2nvYsyfgkXStOKj07eqlGCuweLUgsRg8TsEqokBPJGg2buMZaoZC(fdewICuxgvk337b5OSnldNW6RKb8YQb3ASezL)DwAUGEKs1u0gjLaoV4QZatzJ88ebnmbCU6qpLnAigDBkF8T28rbcbmmFyC1PPRnFuGqxvk6P3jeoCuweO(K)yhB(wB(OaHagMpmU4kHMU28rbcDvPONENq4WrzrGAH8ZFP4SV(tKL807echoklIshWUVDtLSKfPvdLy2juYe6DcOfqoklc0c4JJ)shbnSdOmNbCM58lgiSzz4mz1xjd4LvdU1yjYk)7SeBKNN4BbVijsXO7sXzF9Nil5jvJmC4OSikDa7(2nvYsyfgkHkfkpMxz4kXStOKjKQrIwa5OSiqlGVt(lDe0WoGYCgWzMZVyGWsKJ6YOs5(Epih1yPR5aweOsHcmbCwJnldNjT(kzaVSAWTglrw5FNLMlOhPunfTrsjGZlU6sMlfN91FISeSY0jC4OSikDa7(2nvYsyfgkXStOKHvMoOfqoklc0c4JJ)shbnSdOmNbCM58lgiSzz4mxFLmGxwn4wJLiR8VZsSrEEIsyOWl2cHPkHPOeM7JhOMlO0rqd7akZzaNzo)IbclDa7(2nvYsyfgkfN91FISuQsygo3rcsKLy2juYNkHjAbOAhjir2SmC(RVsgWlRgCRXsKv(3zj2ipprW6OGrOYlmDGqEsyZWre2fKpMNy0DPJGg2buMZaoZC(fdew6a29TBQKLWkmuko7R)ezjyLPtSIweqjMDcLmSY0jwrlcaTa(44Vzz4Uu9vYaEz1GBnwIzNqPy88Cs8J5HwGrLolDe0WoGYCgWzMZVyGWshWUVDtLSewHHsKv(3zj2ippXB1LbzOYlmDGW5c6rkvtXOBtxB(OaHagMpmqTWsXzF9NilPFEoj(X8czv6Szz4I56RKb8YQb3ASezL)DwAT5Jcecyy(W4cUshbnSdOmNbCM58lgiS0bS7B3ujlHvyOuC2x)jYswN9XH6NNtIFmVsm7ekDnN9XOfeJNNtIFmVML5mO(kzaVSAWTglrw5FNLkfN91FISK(55K4hZlKvPZshWUVDtLSewHHsm7ekfJNNtIFmp0cmQ0jAb8XXFP4sEJsLocAyhqzod4mZ5xmqyjYrDzuPCFVhKJYw6AoGfbQuOataNLTzzo5QVsgWlRgCRXsKv(3zPPcLhZZuj4jHHZYQHshbnSdOmNbCM58lgiS0bS7B3ujlHvyOeZoHsMqVtaTaYrzrGwaFN8xko7R)ezjp9oHWHJYIOzzopRVsgWlRgCRXsKv(3zPPcLhZZ01MpkqORkf907echoklcuV28rbcbmmFyu6iOHDaL5mGZmNFXaHLoGDF7MkzjlsRgkfN91FISKNENq4WrzruIzNqjtO3jGwa5OSiqlGVt(rl4AiTAOzzofwFLmGxwn4wJLiR8VZstfkpMxPJGg2buMZaoZC(fdew6a29TBQKLWkmuko7R)ezjyLPt4WrzruIzNqjdRmDqlGCuweOfW3j)nBw66aEBKoRXMTa]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170328.1, [[d0ZqoaGEqIQnbsTlkABIW(erntvIMnI5tsk3uePld9nrXJP0orL9QSBG9RQAuKedtKghiHdl15rvgmOmCq1bfvDkuvDmK64QeSqkyPIklgflNQEijjpLyzQkpxvMiirAQurtgjtx4IuOtl5zKuxheBuLqhcKi2Sk12fL(mv67IiMgQk08ajDBv8xuA0Ky8GeLtQs6CKKQRHQcUhQkTsuv0Vj1RPcp65CIrqZqqQzyIy9f8yYeOu8UHqIzysoKG9dh3xkDMu1FqHj9eboARMuq5DuAW4(s8njVnkn4nNJJEoNye0meKAgMiwFbpMaLeL1rbCNKNPivWBYnPpi7trBDm5kGQSDO9taAaojhsW(HJ7lLobDgZu1t46do5IK(G)WefT1Xpmvs5FX4(MZjgbndbPMHjI1xWJjmqUVnrRIgFS6B2qbzD9yhSpiak0xaxtiWH(0i5fE9X0cX7rqKmFHIetYHeSF44(sPtqNXmv9KRaQY2H2pbOb4eU(Gtm2(q5cqAh4K8mfPcEtW2hkxas7axmo1Z5eJGMHGuZWeX6l4XKtJKx41htleVhbrY8v1)(5Zj5qc2pCCFP0jOZyMQEYvavz7q7Na0aCcxFWjgBFO8dtu0whtYZuKk4nbBFOW(u0whlghFCoNye0meKAgMW1hCIeA)XbIWr)K8mfPcEtEH2FCGiC0p5kGQSDO9taAaorS(cEmj0UUe0S9rD32GTzksf8GwL2gvwKfb4PWxY0QMQ9WikG7ZSDD947vzr2xO9hhich98pjhsW(HJ7lLobDgZu1lghFyoNye0meKAgMiwFbpMmjhsW(HJ7lLobDgZu1tUcOkBhA)eGgGt46doXibpiiAYpmdK(ftYZuKk4nbj4bbrtyzi9lwmUeZ5eJGMHGuZWeX6l4XK2gvwKfb4PWxY8v9K8mfPcEti1fGuuSN290SHoWZKRaQY2H2pbOb4eU(GtUSUaKI6hwsB3t)dZPoWZKCib7hoUVu6e0zmtvVyCzMZjgbndbPMHjI1xWJju6W8M0hK9POTom94PlWlzB)c2Oo4pFojhsW(HJ7lLobDgZu1tUcOkBhA)eGgGt46do5YoB)dZae)lMKNPivWBcPZ2Smq8VyX4GI5CIrqZqqQzyssBOS6a54S9Uy8MOEIy9f8yYPrYl86JPfI3JGiz((LcndK7BtKGheenH9wBH8mHahApE7XNsZqWF(CsEMIubVj3K(GSpfT1XKRaQY2H2pbOb4eU(GtUiPp4pmrrBDmrv8Se0z7DX4nMj5qc2pCCFP0jOZyMQEIOOtss1u1DH(3ywmovFoNye0meKAgMiwFbpMCAK8cV(yAH49iisMVFPqZa5(2ej4bbrtyV1wiptiWHwfvABuzrweGNcF89d62gvwKLshM3K(GSpfT1bu)4x1unvABuzrweGNcFjZx1q32OYISu6W8M0hK9POToGQA(5FsEMIubVj3K(GSpfT1XKRaQY2H2pXYZsWjC9bNCrsFWFyII264hMk08pjhsW(HJ7lLobDgZu1lghD6CoXiOzii1mmrS(cEm50i5fE9X0cX7rqKmFHIetYZuKk4nbBFOW(u0whtUcOkBhA)eGgGt46doXy7dLFyII264hMk08pjhsW(HJ7lLobDgZu1lghn9CoXiOzii1mmrS(cEmHbY9TPhFAqdSiBOd8y6XtxGhuPtNKdjy)WX9LsNGoJzQ6jxbuLTdTFcqdWj5zksf8Me6apSN(fON3eU(GtCQd88dlP9lqpVfJJ(BoNye0meKAgMiwFbpMWa5(2eTkA8XQVzdfK11JDW(GaOqFbCnHaFsoKG9dh3xkDc6mMPQNCfqv2o0(janaNKNPivWBc2(q5cqAh4eU(Gtm2(q5cqAh4pmvO5FX4OvpNtmcAgcsndt46do5YYvjafW9hMbnjMKdjy)WX9LsNGoJzQ6jxbuLTdTFcqdWjI1xWJjmqUVnHRtc6z13SHcYEAK8cV(ycbo0TnQSilcWtHpOQgAkKbY9TjPCvcqbCz9AktkDsatYZuKk4nHuUkbOaUSmAsSyC08X5CIrqZqqQzyIy9f8ycdK7Bt46KGEw9nBOGSNgjVWRpMqGdDBJklYIa8u4dQQHUTrLfzP0H5nPpi7trBDa1Vj5qc2pCCFP0jOZyMQEYvavz7q7Ny5zj4eU(GtUSCvcqbC)HzqtIFyQOkEwcY)K8mfPcEtiLRsakGllJMelghnFyoNye0meKAgMiwFbpM02OYISiapf(sMgAkKbY9TjPCvcqbCz9AktkDsa)85KCib7hoUVu6e0zmtvp5kGQSDO9taAaojptrQG3eRsxaws5QeGc4oHRp4evP0f4h2LLRsakG7IXrNyoNye0meKAgMiwFbpM02OYISiapf(sMgAgi33MKYvjafWL1RPmHah62gvwKLshMKYvjafWL1RPGABJklYIa8u4BsEMIubVjwLUaSKYvjafWDYvavz7q7Ny5zj4KCib7hoUVu6e0zmtvpHRp4evP0f4h2LLRsakG7pmvufplb5FX4OZmNtmcAgcsndteRVGhtOqgi33MKYvjafWL1RPmP0jbmjptrQG3es5QeGc4YYOjXKRaQY2H2pbOb4eU(GtUSCvcqbC)HzqtIFyQqZ)K8E33Kj5qc2pCCFP0jOZyMQEIOOtss1u1DH(3yMOkf06iP6S4bbXywmoAOyoNye0meKAgMiwFbpM02OYISiapf(sMg62gvwKLshMKYvjafWL1RPGABJklYIa8u4BsoKG9dh3xkDc6mMPQNCfqv2o0(jwEwcojptrQG3es5QeGc4YYOjXeU(GtUSCvcqbC)HzqtIFyQqZ)pmvXZsWfJJw1NZjgbndbPMHjI1xWJjtYHeSF44(sPtqNXmv9KRaQY2H2pbOb4K8mfPcEtiLRsakGllJMet46do5YYvjafW9hMbnj(HPYh)lg3x6CoXiOzii1mmrS(cEm5OZwaxO94ThFkndbNKdjy)WX9LsNGoJzQ6jxbuLTdTFcqdWjC9bNCrsFWFyII264hMkF8pjptrQG3KBsFq2NI26yX4(ONZjgbndbPMHjI1xWJjhD2c4cDBJklYsPdZBsFq2NI26aQTnQSilcWtHVj5qc2pCCFP0jOZyMQEYvavz7q7Ny5zj4K8mfPcEtUj9bzFkARJjC9bNCrsFWFyII264hMkF8)dtv8SeCX4((MZjgbndbPMHjI1xWJjhD2c4ojhsW(HJ7lLobDgZu1tUcOkBhA)eGgGtYZuKk4nbBFOW(u0wht46doXy7dLFyII264hMkF8VyXeU(GteJx(dZibpiiAYpSlZTyda]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170328.1, [[d0ZuhaGEcu1MKsv2fI2gLQ9jLsZKs0Svz(uGBsj8nPWTvvhwyNqSxLDtA)sLrrGkdJQACsPyziyOeOyWqQHJqhKO6uei1XOOZrGWcPqlLqwmrwUOweb8uupMkpxvMirbtLszYImDjxKQSoIsDzW1HKnsuKtJ0MPK2obk9BO(mHAAei67uq)LGEMuYOjkP5rGKtkf9AII6Aef68svRukv1HKsLFsuIN5Sn2tdPdsZ4yK4dJzpl7q7DWh0kUo0YaynqD1yzaSgOUAghlcoiEWqi4B2WVfH2qAoMDzkXA8y5UII13SneZzBSNgshKMXXiXhglyWffRJzxMsSgxyXIpGKiUOy91EcU2vyXIpG0HXxcBO(mWahgFjSHkPvAgech8bTIJmd)GQV2sOn(c6XIGdIhmec(M2nBq63ACtnrDrHZJvScJLlrpA1pMiUOyDSf4es8HXcqmJpSkgscjIneYcSAieMTXEAiDqAghZUmLynwcLvRKfUGVWF8ki3tMHFq1NGIWy5s0Jw9JlCbFH)4vqUFCtnrDrHZJvScJfbhepyie8nTB2G0V1yK4dJTHl43H2I4vqUF1qAnBJ90q6G0moMDzkXACHfl(ashgFjSH6BSi4G4bdHGVPDZgK(Tg3utuxu48yfRWy5s0Jw9JTsZGq4GpOvCJrIpmwMOzOdT3bFqR4wneb5Sn2tdPdsZ4y2LPeRXfwS4diDy8LWgQVXIGdIhmec(M2nBq63ACtnrDrHZJvScJLlrpA1p(v48xiCWh0kUXiXhgZfo)7q7DWh0kUvdrgNTXEAiDqAghZUmLynUWIfFaPdJVe2q9nwUe9Ov)y4GpOvCc)XRGC)4MAI6IcNhRyfgJeFyS3bFqR46qBr8ki3pweCq8GHqW30Uzds)wRgI9zBSNgshKMXXSltjwJBxfhOfz8CGMc1bKGgshKmWajuwTsgphOPqDajkIgyGdJVe2qLmEoqtH6aYm8dQ(ARm6pweCq8GHqW30Uzds)wJBQjQlkCESIvySCj6rR(XshgNeAfvUFms8HXgpmo1HwMqL7xnKgZ2ypnKoinJJzxMsSg3UkoqlY45anfQdibnKoizGbsOSALmEoqtH6asuehlcoiEWqi4BA3SbPFRXn1e1ffopwXkmwUe9Ov)yji)GSmtvXJrIpm2iKFqwMPQ4vdPnZ2ypnKoinJJzxMsSghUIkybHGcFk8AlHXiXhglcLk7o0YLfVXYLOhT6hNrPcdxrXQWJ(QXn1e1ffopwXkmweCq8GHqW30Uzds)wJTaNqIpmwa2ZYo0Eh8bTIRdTCzXtGvdrqmBJ90q6G0mogj(WyrOuz3Hw(ZbAkuhmMDzkXACfhOfz8CGMc1bKGgshKglcoiEWqi4BA3SbPFRXn1e1ffopwXkmwUe9Ov)4mkvy4kkwfE0xn2cCcj(Wybypl7q7DWh0kUo0YFoqtH6abwnet)zBSNgshKMXXiXhglcLk7o0nDGvu5(XSltjwJR4aTiPoWkQCpjOH0bPU2FSi4G4bdHGVPDZgK(Tg3utuxu48yfRWy5s0Jw9JZOuHHROyv4rF1ylWjK4dJfG9SSdT3bFqR46q30bwrL7fy1qmnNTXEAiDqAghJeFySiuQS7qBjvSSwkvf3HweonMDzkXACfhOf5rflRLsvXcZ4ejOH0bPXIGdIhmec(M2nBq63ACtnrDrHZJvScJLlrpA1poJsfgUIIvHh9vJTaNqIpmwa2ZYo0Eh8bTIRdTLIey1QXmrWrJJk4JII1HqWoHvB]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170328.1, [[dSJ9iaGEsvOnPOYUKOTjjTpsvXmLQQzJQBcf3MIVjPStvzVIDRY(jP(jPkyysLXrQsomvptcgmPy4svoij5uKQOJrKZbLswik1svuwmuTCv1dLu9uKLruEokMiuk1uLqtwHPR0fjQopPYLbxNuAJqP40q2SKy7sXVj8DPQyAkQY8Gs1JP0RrjJMe)vrojuYNLsxJuv6EsvPdPOQooPQAuKQuhPumK8ZX5WiSdHTHkUw(g2HEUbcrY7xTg5CWa36C1AuPhKhAgWbNbYtwNuTUcY0RsPqupWICosp6lsC5jRQSqQSlsCmPyEsPyi5NJZHryh65gieTIVHfa9GFOzahCgipzDsvLQv2viKkCehT6cXSIVHfa9GFiSUbY6R4h6eheQUcyzHr0ag42GhcJy8CdekBEYsXqYphNdJWoez)OEBOv02YHsRqWhI(CmHEUbcPIXc3WpleAgWbNbYtwNuvPALDfcPchXrRUqoJfUHFwiew3az9v8dDIdcvxbSSWiAadCBWdHrmEUbcLnVcPyi5NJZHryh65giu)i9RfnuRbJ3AC1AkkwWeAgWbNbYtwNuvPALDfcPchXrRUqCK(1IgtgV14tRybtiSUbY6R4h6eheQUcyzHr0ag42GhcJy8CdekBEZlfdj)CComc7qK9J6THmoWz2VWuA1()WT6tFL1n38xNd3wYrTk7HU2PVyucNJZHXCFOYhyuCCoesfoIJwDHQWDdmXOiSScvxbSSWiAadCBWd9CdecB4UbuRHuewwHMbCWzG8K1jvvQwzxHqKIOpyedufe8zcEiSUbY6R4h6ehecJy8CdekBE6Bkgs(54Cye2Hi7h1Bd52f1atWbgeWG95nNBxudmneBzfUBGjgfHLf2D7IAGj4adcycPchXrRUqv4UbMyuewwHW6giRVIFiRolhcnd4GZa5jRtQQuTYUcHEUbcHnC3aQ1qkcll1AQRZYHS5vnfdj)CComc7qp3aHK7)vr)ADwqOzahCgipzDsvLQv2viKkCehT6cb(Fv0VwNfecRBGS(k(HoXbHQRawwyenGbUn4HWigp3aHYMxTumK8ZX5WiSdr2pQ3gAi2YkC3atmkclRYpyC0XOpwNzNwKbMdxBLkLCVXNy0(BHsT9MB(RZHBl5OwL9qx70xmkHZX5Wyo3UOgycoWGagSpVqp3aH63BC1AyR9ZSHMbCWzG8K1jvvQwzxHqQWrC0Qle3B8jCTFMnew3az9v8dDIdcvxbSSWiAadCBWdHrmEUbcLnp9kfdj)CComc7qK9J6THM)6C42soQvzp01o9fJs4CComMZTlQbMGdmiGb76BONBGqY5GbU15Q1WM7mBOzahCgipzDsvLQv2viKkCehT6cbCWa368jCUZSHW6giRVIFOtCqO6kGLfgrdyGBdEimIXZnqOS5HTsXqYphNdJWo0ZnqO(9gxTg2GBcnd4GZa5jRtQQuTYUcHuHJ4OvxiU34t4GBcH1nqwFf)qN4Gq1vallmIgWa3g8qyeJNBGqzZtQlfdj)CComc7qp3aHQR4OtTM(rTk7HU2qK9J6THgaU2kvk5OwL9qx70xmkhI(CHMbCWzG8K1jvvQwzxHqQWrC0QlKvXr3eh1QSh6AdH1nqwFf)qN4Gq1vallmIgWa3g8qyeJNBGqzZtskfdj)CComc7qK9J6THC7IAGPHyl5OwL9qx70xmWUBxudmbhyqatOzahCgipzDsvLQv2view3az9v8dz1z5qiv4ioA1fYQ4OBIJAv2dDTHEUbcvxXrNAn9JAv2dDTQ1uxNLdzZtswkgs(54Cye2Hi7h1BdHRTsLsU34tmA)TqP2EHuHJ4OvxiU34t4A)mBiSUbY6R4h6ehecJObDTHKc9CdeQFVXvRHT2pZQwJElPNHu9BzczenORTVsHMbCWzG8K1jvvQwzxHqKIOpyedufe8zc7q1vallmIgWa3g2HWigp3aHYMNuHumK8ZX5WiSdr2pQ3g6dv(aJIJZHqQWrC0QlufUBGjgfHLviSUbY6R4h6ehecJObDTHKc9CdecB4UbuRHuewwQ1O3s6ziv)wMqgrd6A7RuOzahCgipzDsvLQv2viuDfWYcJObmWTHDimIXZnqOSzdr2pQ3gkBca]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170328.1, [[dadmcaGEQIAxOuBtQyMufmBQCtv03OQStPSxYUrSFiXWeXVv1qLkzWqQgUu1brHJHklePSuQQwmswUOwevPNcwMi9Cu1eHQQPcvMSknDHlcLEgs11HQYMPkY2HQCzLpJIEmehwY5vHrdPCBkDsiPXjvQttX9Ok0FHcpek61OKfNWjalPOC7kAcaKSPpeia)Ztf(CHOjW)CR4NAPjC(sON2nBobq)qmLZ45kmprT0oPcyGeMNWlCQXjCcWskk3UIMaajB6dbXZKPBS7)W8eEbmOmotCiO)dZteGk5AqQ4ZcipzcALDc66dZteWiZKxaPSZJEVRUUdmyMlK5vG)5wXp1st46W5JDcDbyI2qyD(4n7iHOeC(3wzNaV3vx3bgmZfY8QqTuHtawsr52v0e0k7eG7Jzrb9ZIpw(qG)5wXp1st46W5JDcDbmOmotCii(ywmSfFS8HaujxdsfFwa5jtaMOnewNpEZosikbN)Tv2jqHA0fobyjfLBxrtqRStaeF2YARFzb(NBf)ulnHRdNp2j0fWGY4mXHa(4ZwwB9llavY1GuXNfqEYeGjAdH15J3SJeIsW5FBLDcuOqqRStaG1dOGow3SJeLdf07kpK3svHcja]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170328.1, [[d4JxiaGEvvEjPO2fPi9AvLCyQMjLQ(nkZwPwNQQCtKkDEr6BQQkNMWofAVs7gy)IYprkdJOgNQc9mkvgkLmyr1Wr0bvLokPi6ycCovvvTqvXsjfwmfTCsEiQYtHwgP0ZvYevvWurYKrvnDvUOGUkLcxwX1rLnkIEmO2mf2oPQpkc9zeAAQk67iyKukABQk1OjY4rQ6KKk3cPIRjcUhPiCBqwRQQkhNsPBqPkc7KNGbsYahEP7PinBqzVUyyXZveNZsVvnlQCaXHN0a)vFkAUf)(L4MrOMftPzySMJNtEcgy1OCr6PzySMJNtEcgy1OCrB5gUHVoygaf)Mg)uU4sIr4Lt56agSAw0wUHB4ZZjpbdS6trB5eWFHx6Ek6f1KCd3SkvJbLQyiWn3d)(u8f(emqwU9I1vefq8YYdbsoaEGgW9xwoPAGzqM(vm6qtruaXllpei5a4bAa3Fz5KQbMbz6xrnM94RPrTYbFhilBxrewjiVINaA0eY9AuBPkgcCZ9WVpfFHpbdKLBVyDfrbeVS8qGKdGhObC)LLZFmCU9vm6qtruaXllpei5a4bAa3Fz58hdNBFf1y2JVMg1kh8DGSSD96vKEAggR5OCfX5wnkxeYPhPAmOOZPCDadgvk5u0KZWOi90mmwZP5NvJYftPzySMtZpRgLlUKyeOCfX5w9P4xMVayjMQifnln0LOnPkcZGm9ZsFynlc7KNGbEbWsmvXhAuu0OBrEmY0SCkwXqGKdGhObCz5OaqCp0HYveNR4sIraP6trB5gU5dc1aFcgOOg6s0MufbCq6GzGvJFwmLMHXAoDa(cy)yQvJYfxsmc8CYtWaR(uKEAggR5E5uEJYftPzySM7Lt5nkxeYP)L7ynkxKEAggR50b4lG9JPwnkx03KsokXiyPpSXGI(MuY5XGm9ZsFyJbf)Wy4C7Rpf9nbpDzP3Qpf)YmjdCfTOYYrhSYYJUsXiue2jpbd8Ufebf5fgPc1OiFXIC7PuPKtrVOYbehQuYPOBk2IlTOZPC6katFkUiN9o52xs8yBMQuf9gdkA2yqrInguu1yqVIFzMKbou8BAmqBrNt5uPKtrtodJIwkbKRsZY55KNGbYYF5uEr8ykitLaqCufJo0umei5a4bAaxwULsa5Q0IQzxKxyKkuJINRioxsg4kArLLJoyLLhDLIrOOVjLCkxrCol9Hngu03Ks(7MGNUS0h2yqXVmtYahEP7PinBqzVUyyX0MKoFu()1(P83bb)ZozTA)NCnOZNju05u(lawIPk(qJIIgDTpmjvXZveNljdC4LUNI0SbL96IHfPRtVaIdklNsannANCXLeJWl3X6trewjiVIf9nPK)Uj4Pll9wngumLMHXAokxrCUvJYfjvcixLMKbou8BAmqBrs1aZGm971Y(IOaIxwEiqYbWd0aU)YYjvdmdY0VI8hdNBFVw2xefq8YYdbsoaEGgW9xwo)XW52xriN(3WgLls57bCz5jQyCKnkx8CfX5S0hwZI6flHPylUuQuYPOzrnM94RPrTYb)t2oTFutdkc7KNGbsYahk(nngOTO5w87xIBgH39UMfTLB4g(6a8fW(XuR(uua4lG9JPEbWsmvrn0LOnPkAWaxXxLW3z5rxPyekUKye0b4lG9JPw9P4sIrWsVvFk6BcE6YsFyFk6BsjNhdY0pl9wnguCjXi8g2NIWmit)S0BvZI(MuYPCfX5S0B1yqrbmd8FmguJbjuCro7DYTVKQzribaPAuU45kIZLKbou8BAmqBXLeJGL(W(ue2jpbdKKbUIwuz5Odwz5rxPyek6CkhjN9w3hAuRCWh)mHIHa3Cp87tXLaICpV0cBuBrib4nSr7kcjaVChRr5IKkbKRs1bZaO4304NYfTucixLMLZZjpbduCP8tWkUKye08KAka8faIR(u0wUHBE3cIaObCfHlkGzaK0HfaInMqXZveN7falXufFOrrrJUAOlrBsv03KsokXiyP3QXGI2YnCd)KmWHIFtJbAlsFJ05Bnnq2Uecs4BTjm0rwoHI2YnCdFn)S6trKCGf(w8Zpbd0O2VTROZPCBaexrYTNoQETa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170328.1, [[d4JniaGEvjVKOu7sjv9AuQCyQMjjv)gPzRuRtvk3euLZlv9nIs60e2Pe7vSBG9lv(PQQHjjJtjr2gjfdLsgSKA4i6GkXrrPkDmvX5ikXcvvwkrXIjXYP4HOQEk0YOu9CPmrLuzQOyYOktxLlskxvjHNbQCDuzJukpgHntQ2or1hvs5ZOKPbQQVdkJKKsxwXOjY4rPCssYTqPQUMQuDpuQIBdYAvsuhxjPZtycs4KNGcSrbhE97j4)kyuxvrl45gwZzj3kkbnoG1WxAiyx(cQSfVET2Mclkb7)11BZX3jpbf0sPkiB)66T547KNGcAPufCvUHB4PIGcqXRjf4xfSjrHTWzCvaDAucUk3Wn847KNGcA5ly)VUEBog3WAUwkvbzVCd30ctkpHjOgWv2dV8fCH4euqxT6I2fefq87Q1asoGyGgW9wxnPziOqk(fS4qtquaXVRwdi5aIbAa3BD1KMHGcP4xqzM94Tjf7vpVxPM1B3(tqKWiiVGNaAypv5sXEycQbCL9WlFbxiobf0vRUODbrbe)UAnGKdigObCV1vZB0DU9fS4qtquaXVRwdi5aIbAa3BD18gDNBFbLz2J3MuSx98ELAwVD7p5YfKTFD92CmUH1CTuQcc5SHmPuf8CdR5waesutWVFgMF4jJQ1ultW(yJ9vZ7vYYtLSaNSchCvWFLGRk6Sp8FpiBPufSjrHX4gwZ1Yxq2PSaiKOMGm)wYOAn1YeKGcP4NLCTOeKWjpbfSaiKOMGF)mm)WliFkzFxndnOgqYbed0aUU6LFTGnjkmKjFbxLB4M1jmdXjOGGYOAn1YeeWbPIGcAPa)G9)66T5ub4ji8JAAPufSjrHX3jpbf0Yxq2(11BZTWz8uQc2)RR3MBHZ4PufeYzBH7OPufKTFD92CQa8ee(rnTuQc6BsjhLOWSKRLYtqFtk58Pqk(zjxlLNGfhAcQbKCaXanGRRE5xlOVH59nl5w5li7uSrbxqlMUA0bTU6IBmuybjCYtqblBblqq(AfgnzcYt0i3Eptp5e8vqJdynm9KtqxrSfxFqNZ4WtaM8fKDk2OGdfVMuEShCDJUZTV8f0YiGCtFxnFN8euqx9cNXdIh1aPyeawJjyJC2BBBVjXNUPMWe0t5jOjLNGSs5jOskp5cAMDq(AfgnzcEUH1C2OGlOftxn6GwxDXngkSG(MuYzCdR5SKRLYtW(FD92CY(RLsvq2PyJco863tW)vWOUQIwWMef2c3rJsqNZ4Qa6uMEYjOcNUEWZnSMZgfC41VNG)RGrDvfTGWZztaXb1vZiGMuGRkOZz8faHe1e87NH5hEQRzJjisyeKxWMaWApb9nPKVSH59nl5wP8eCvUHBw2cwaObCbjcsAeqUP3gfCO41KYJ9GKMHGcP43IL6brbe)UAnGKdigObCV1vtAgckKIFb9nPKVSH59nl5AP8eeYzBrlLQGm(Eaxx9Agkhzkvbp3WAol5ArjOCrtOi2IRNPNCcQeuMzpEBsXE1JSwbN9vA9pbfeuas6ecaRuEpiVr3523IL6brbe)UAnGKdigObCV1vZB0DU9fua4ji8JAwaesutqzuTMAzcUk3Wn8ub4ji8JAA5lOYw861ABkSL9okbBsuyQa8ee(rnT8f03KsoJBynNLCRuEc6ByEFZsUw(ckiOGvMsHs559GnjkSfT8fKGcP4NLCROe03KsoFkKIFwYTs5jytIcZsUw(c2iN9222BsrjiKaGmPaxWZnSMZgfCO41KYJ9Gnjkml5w5liHtEckWgfCbTy6Qrh06QlUXqHf05moso7TQ1LsvqnGRShE5lytarUNLFTuGliKaSOLcCbHeGfUJMcCbjnci30RIGcqXRjf4xf0YiGCtFxnFN8euqWMXpbnOofCbxmcF3vxCJHclytIct2tVIaWtay1YxqcN8euGnk4qXRjLh7brYHq4BXl)euqk2vdCb9nPKJsuywYTs5j4QCd3WZgfCO41KYJ9GS9RR3Mt2FTuQcUk3Wn8K9xlFbDoJZ0tobv401d6CgFfaXfKC79Jjxca]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170328.1, [[d0ZeiaGEvfVKsODPkK2gLGzQGomvZMOFd1nHiTmjX3ufQZlL2Pe7vSBu2VK6NQQggjgNQqCAsnucgSumCeoOI6OOsPoMICouPKfQkTuujlMsTCkEOQONcEmQ65s1evvYuH0KPKMUkxePUkLOUSsxhrBus61qeBMK2oH8rfOpJkMMQs9DimskrEMcy0k04HOojH6wOsvxdvQCpuPWTrYArLIoUQGZuqdW7eNgZQIzhCTYnWVLrhkUqh4CdN9eeje7agNXzFoU8ijVbSL6pFguIre7aT)QQ99E6eNgZ6POea5Fv1(EpDItJz9uuc8a5sUwfZJzG(ZMY3kb6JyeZKgxmtfh7apqUKR1NoXPXSEEd0(RQ23d1nC2RNIsaUn5sU9GMYuqdqZCB5AnVbM5pnMv3mu3Vaa9W6gA5sTSZL1ncMLhtz7xGItTba6H1n0YLAzNlRBemlpMY2VaCTY17BkvuMSWKIYabaEJM4cCAQLBOKlLkbnanZTLR18gyM)0ywDZqD)ca0dRBOLl1Yoxw381Q6KYlqXP2aa9W6gA5sTSZL1nFTQoP8cW1kxVVPurzYctkkdea4nAIlqUCbq(xvTVhQB4SxpfLauoYaAktbCsJlMPIrBj2a2KQQbq(xvTVNfF7POeO9xvTVNfF7POeOpIrG6go71ZBaKypZ4hXMaO)cCjEqlHgGhtz7NGi6yhG3jonMnZ4hXMaV)OO)inWtmrBDdkoaTCPw25Y6M5F6a9rmcanVbEGCj3V0ML)0ywaUepOLqdWiPeZJz9u(oq7VQAFpXmRAE)WMEkkb6JyepDItJz98ga5Fv1(EZKgpfLaT)QQ99MjnEkkbOCKNjpCkkbq(xvTVNyMvnVFytpfLaUKy0Hrmcbr0PmfWLeJ(tmLTFcIOtzkqXP2a0YLAzNlRBemAk30gWLi82UGiH8gaj2vXSlGaADd4SEDtXngmIa8oXPXSzPMdlWt6cknxbSQ7esVfTLyd4bmoJZI2sSbCBTuFTbCsJJunBZBaKyxfZoq)ztzQsGoXkLvLEF8jwInbnGNYuatktb4KYua7uMYfqWOPCtBDZtN40ywDZmPXdeWjnoAlXgWMuvnGzLbEsxqP5kW5go7vfZUacO1nGZ61nf3yWic4sIrh1nC2tqeDktb(AvDs5L3aiXUkMDW1k3a)wgDO4cDGZnC2BMXpInbE)rr)rkxIh0sOb6JyeZKhoVbo3WzVQy2bxRCd8Bz0HIl0bqQJSMIKQUbvtTPmGsaN04Zm(rSjW7pk6pshsxfnaWB0exGaUKy0NLi82UGiHuMcyDvDs5nlmmaqpSUHwUul7CzDZxRQtkVaegnLBARIzhO)SPmvjaHz5Xu2(nlmmaqpSUHwUul7CzDJGz5Xu2(fWLeJ(SeH32ferNYuakh5z6uucG6YLD1ndAWKePOe4CdN9eerh7aI0DTTwQVw0wInGDabJMYnT1npDItJzbo3WzVEaEN40ywvm7a9NnLPkbSL6pFguIrmlLXoWdKl5AvmZQM3pSPN3aAMvnVFyZmJFeBcWL4bTeAavm7cmB0USUP4gdgrG(igHyMvnVFytpVb6JyecIeYBaxIWB7cIOZBaxsm6OUHZEcIeszkqFeJyMoVb4Xu2(jisi2bCjXO)etz7NGiHuMcO5XmUjgtLYakb6eRuwv69XyhGsZa0uucCUHZEvXSd0F2uMQeOpIriiIoVb4DItJzvXSlGaADd4SEDtXngmIaoPXbIvkf)vkkbOzUTCTM3aDnfHCN)PtPsaknBMoLbcqPzZKhofLaegnLBAfZJzG(ZMY3kb4ALR33uQOm9yLbQ8ip6uGhixYDwQ5WOw2fGpqFeJWIBRTMzvZ40ZBanpMbeoVMXjfUlaYPOeWLeJomIriisiLPapqUKR1Qy2b6pBktvc0MQC)JOWTQ8TIfMME8akvQ8yLOY9FZDbEGCjxRw8TN3aaXYRDP(JFAmlLkwOsaN04wMPVaesVDn5sa]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170328.1, [[d0Z8haGEfPxsvr7IaPxRQOzQQ0HLmBsDCQQCtiIXPQGBJkNxkTtkTxXUrz)QIFQQAyK0VH60enucnyf1Wr4Gk4OeiCmf6CuvkluvAPislMIwovEOI4PGLrbpxQMieLPcPjtIMUkxevDvQk5zeW1rYgPqxwPntv2ob9rQQ6ZiQPbr13HWiPQW2GinAPy8iItsc3IavxtvHUhvLQhJuRLarFJaLZyqdqxeNeZmIzhCT6nWVVq)QWYh4kh59efkgZaUIrEN0S0FM3a(rTu7GwsMXTSlaDG2FpV(EtkItIz9yvdqYVNxFVjfXjXSESQb8JAPwLkOXmqoDJf5Qb6nyeduUsbZdhZa(rTuRYjfXjXSEEd0(7513dTCK3RhRAabb1sT9Gg7yqdWZkt9QmVbgOpjM9m)v2Vy)qaBXTba(VpZ86LBzxPFMfDlnMZSUaKU6T6BSguhr6OQQabaANK4cCsU13vZfRHGgGNvM6vzEdmqFsm7z(RSFXI0a2IBda8FFM51l3YUs)mJS1RO0xasx9w9nwdQJiDuvvabDmaq7KexGC5cqYVNxFp0YrEVESQb4ksa0yvduuUsbZdJ2sSbmP88c0gJcos)OQVnQ6BciyciGkY)GaQXtWr(hdqsSQb6nyeOLJ8E98g4tZbgDd2fa9xKuf(7d0a0yoZ6efYhZa0fXjXSbgDd2f49hf9hjbMGjAFMrXb41l3YUs)mp8ZhO3GraO5nGFul1ImPBPpjMfGuf(7d0amkof0ywpwKhO93ZRVNcMsjDDyxpw1a9gmIjfXjXSEEdqYVNxFVbkxfRAG2FpV(EduUkw1aCfjduhow1aK87513tbtPKUoSRhRAGst0uqdgHOq(yhduAIMAcMZSorH8XogWwCBaE9YTSR0pZd)8bknIQTlkumVb(00iMDberFMHI1FMTLZHreGUiojMnOLKzbMWBr5jnGszNqxTOTeBGPbCfJ8I2sSbktPwETbkkxHejBZBGpnnIzhiNUXoAiaYwVIsF5nGOtYvU2N5jfXjXSN5bkxfWOU42NzObt)zGIYvOTeBatkpVaUvhycVfLN0ax5iVNrm7ciI(mdfR)mBlNdJiqPjAk0YrEprH8XogO93ZRVNpF7XQg4ttJy2bxREd87l0VkS8bUYrEVbgDd2f49hf9hjKQWFFGgO3GrmqD4yg4kh59mIzhCT6nWVVq)QWYhajfjsokUNzuj3gRaQbkkxnWOBWUaV)OO)i5lVr0aaTtsCb6sgz9gO0en1Ggr12ffkg7yaLRxrPVbXVba(VpZ86LBzxPFMr26vu6laHtYvUwJy2bYPBSJgcq4wAmNzDdIFda8FFM51l3YUs)ml6wAmNzDbknrtnOruTDrH8XogGRizGpw1aOLEz3ZS)omfrSQbUYrEprH8XmGqzxAk1YRfTLydygG0vVvFJ1G6OGPkGHpiOJbOlItIzgXSdKt3yhneWulNo1FngXGwhZa(rTuRsfmLs66WUEEdizkL01HDdm6gSlaPk83hOb8WSlWGtw6NzB5Cyeb6nyekykL01HD98gO0enfA5iVNOqXyhduAevBxuiFEdiPXmbjgZfRaQb6nyed85nanMZSorHIXmqPjAQjyoZ6efkg7yGEdgHOq(8gOtSATrD1BIzaojdqJ1qGRCK3ZiMDGC6g7OHaaXsllTCADsmlwdi1qa6I4KyMrm7ciI(mdfR)mBlNdJiqr5kGy1Afilw1a8SYuVkZBGUKJqVd)8XAiqVbJquOyEdWjzd8XAiaNKnqD4yneGWj5kxRcAmdKt3yrUAarNKRCTpZtkItIzbC1jXb6nye(CBnLmLsg5EEdyQLtN6VgJiMbK0ygqu0sg5y)yGst0uqdgHOqXyhd4h1sTknIzhiNUXoAiaj)EE9985Bpw1a(rTuRsF(2ZBGoXQ1g1vVzcwJDbnqf7yaZyhdqo2XaUyhZfOOCLVyYlaHUAxxUea]] )


end

