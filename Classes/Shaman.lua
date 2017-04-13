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
local RegisterUnitEvent = ns.RegisterUnitEvent
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
        addAura( 'boulderfist', 218825, 'duration', 10 )
        addAura( 'crash_lightning', 187874, 'duration', 10 )
        addAura( 'doom_winds', 204945, 'duration', 6 )
        addAura( 'earthen_spike', 188089, 'duration', 10 )
        addAura( 'flametongue', 194084, 'duration', 16 )
        addAura( 'frostbrand', 196834, 'duration', 16 )
        addAura( 'fury_of_air', 197211 )
        addAura( 'hot_hand', 215785, 'duraiton', 15 )
        addAura( 'landslide', 202004, 'duration', 10 )
        addAura( 'lashing_flames', 240842, 'duration', 10, 'max_stack', 99 )
        addAura( 'lightning_shield', 192109, 'duration', 3600 )
        addAura( 'rainfall', 215864 )
        addAura( 'stormbringer', 201846, 'max_stack', 2 )
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

        addHook( 'reset_postcast', function( x )
            state.feral_spirit.cast_time = nil 
            -- if state.talent.ascendance.enabled then state.setCooldown( 'ascendance', max( 0, state.last_ascendance + 180 - state.now ) ) end
            return x
        end )

        addHook( 'advance_end', function( time )
            --[[ if state.equipped.spiritual_journey and state.cooldown.feral_spirit.remains > 0 and state.buff.ghost_wolf.up then
                state.setCooldown( 'feral_spirit', max( 0, state.cooldown.feral_spirit.remains - time * 2 ) )
            end ]]
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

        modifyAbility( 'chain_lightning', 'cycle', function( x )
            if talent.lightning_rod.enabled then
                return 'lightning_rod'
            end
            return x
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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170409.204707, [[deunGaqiIilsjvytuvnkQuNIQYUqXWuOJrvwgQQNPKY0qfCnQKSnLu13GcJJkHohQqToQeqZJkr3JiQ9ruCqOKfQK8qOOjsLGCrOInIkKrsLaCsufZKkPUjQ0orPHQKkYsHs9ustfQ0xvsL2RQ)QGbteoSWILYJvQjtPld2mf(mu1OvItJ0QPsq9AIQzt42s1UL8BidNiDCQeOLJ45kA6IUovSDkY3jkDEkQ1RKkQ5JkA)Ok99oUxXPIMaSF1vxiWiCe5xDvLcBAiORZrsr1z5V(1UIniGycNL)OhgJCyKpJh)1g5WAx1nHknVEfRDsr184EwVJ7vCQOja7xDv3eQ08AIWJxam0kbcXrAoVYgD466sllVsOlqqUI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QS0YomxGGCLlYYgD46ZZY)4EfNkAcW(2vDtOsZRjcpEbWSriHfjBnVYgD4QlaGGOZ(vmxGTCUitqhQ8TRydciMWz5p6HH34vEklDhjICTqfCfRgvqtZxBceYkCM5vUilB0HRpp7Ah3R4urta2V6QUjuP51eHhVay2iKWIKTM(DlPGKuJyNmHq6smilsyWqIsUmJCYP7EaIzsqDMTdHavkJK5p6FJqcls2IztI5YGGIFjlAHNHa9Gwtxkzc0CmmgKLwwKS(8DLn6WvociHGxjuPucnVI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QbqcXWukLqZRCrw2OdxFEwoCCVItfnby)QR6MqLMxdssnIDYecPlXGSiHbdjk5Ym6xkbmnGFBz8ymasigMsPeAELn6WvmjXCHxjCnf)sw0c)vmxGTCUitqhQ8TRydciMWz5p6HH34vEklDhjICTqfCfRgvqtZx3KyUmiO4xYIw4VYfzzJoC95zD1X9kov0eG9RUQBcvAEnr4XlaMncjSizRPF3nhddMyUHYg1gyCKYjNgajedtPucnziqpO1ugx57kB0HRRaYeiYPf(RyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMV2aYeiYPf(RCrw2OdxFE21FCVItfnby)QR6MqLMxteE8cGzJqcls2A63DZXWGjMBOSrTbghPCYPbqcXWukLqtgc0dAnLXv(UYgD46kbcz5vcoYHy(kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5RnbczhmCiMVYfzzJoC95zX44EfNkAcW(vx1nHknVMi84faJuusr10V7MJHbtditGiNw4zCKYjNzqWdjts7WqIgSuWLsE9J(UIvJkOP5Rsrjfvx5PS0DKiY1cvWv2OdxxNqjfvxXIGFETIoi51HucsGk8GDqkswGSoUIniGycNL)OhgEJxXCb2Y5ImbDOY3UYfzzJoCDDiLGeOcpyhKIKfiRJNN1fpUxXPIMaSF1vDtOsZRnhddMgYrybIbDMmeOh0A6sc0CmmgKLwwKSCYP7EaIzsqDMTdHav6sj7Qr)XoPMGbOGofMYi518DLn6W1vihHfig0zEfZfylNlYe0HkF7k2GaIjCw(JEy4nELNYs3rIixlubxXQrf0081gYrybIbDMx5ISSrhU(8SC8X9kov0eG9RUQBcvAET5yyW0qoclqmOZKHa9GwtxsGMJHXGS0YIKLtoDVxccEyoyqIDsrviKXJbdx5VhGyMeuNz7qiqLUuYtitAHFY0qoclqmOZCOhGyMeu3FStQjyakOtHPlLmFFxzJoCDfYrybIbDM8kHBpFxXCb2Y5ImbDOY3UIniGycNL)OhgEJx5PS0DKiY1cvWvSAubnnFTHCewGyqN5vUilB0HRppR34X9kov0eG9RUQBcvAEndbujJik7uqTadurtaw)nhddgru2PGAbgc0dAnDjbAoggdYsllsw)XoPMGbOGofMYmELn6WvSrB5nAcKRyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMVsqB5nAcKRCrw2OdxFEwpVJ7vCQOja7xDv3eQ08QKs6woTW7VhGyMeuNz7qiqLYWN)v2Odx5ihIzELazWReyrjxXCb2Y5ImbDOY3UIniGycNL)OhgEJx5PS0DKiY1cvWvSAubnnF1WHyEazmeuYvUilB0HRppRh)J7vCQOja7xDv3eQ08AgcOsMLGkMjI0zGkAcW6V5yyWyqqZSrIYYqGEqRPljqZXWyqwAzrY63TBjLHaQKXWHyEazmeucdurtawFCYP7meqLmgoeZdiJHGsyGkAcW6VhGyMeuNz7qiqLYW3v(8DLn6WvoIGMzJeL9kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5Rge0mBKOSx5ISSrhU(8SERDCVItfnby)QR6MqLMxBoggmgIOdjQW7ameOh0A6sc0CmmgKLwwKSCYP7ncjSizlglc1hKLw2jdb6bTMUC9(BoggmgIOdjQW7ameOh0A6so47kB0HRCKi6qIk8oWvmxGTCUitqhQ8TRydciMWz5p6HH34vEklDhjICTqfCfRgvqtZxnerhsuH3bUYfzzJoC95z94WX9kov0eG9RUYgD4Qlec15vI1Lw25vSAubnnF1Iq9bzPLDEfBqaXeol)rpm8gVYtzP7irKRfQGRyUaB5CrMGou5Bx5ISSrhU(8SEU64EfNkAcW(vx1nHknVMHaQKztI5cTWpmtePZav0eG1FStQjyakOtHPmsEn)ULugcOsMLGkMjI0zGkAcWYjNnhddgdcAMnsuwgc0dAnLb)267kB0HRysI5cVs4Ak(LSOfEELWTNVRyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMVUjXCzqqXVKfTWFLlYYgD46ZZ6T(J7vCQOja7xDLn6WvCcsUafVsOsPYHRy1OcAA(keKCbQHPuQC4k2GaIjCw(JEy4nELNYs3rIixlubxXCb2Y5ImbDOY3UYfzzJoC95z9W44EfNkAcW(vx1nHknV6odbujdYeq2lbbpWav0eG1FpaXmjOoZ2HqGkLrYCy0VKYqavYy4qmpGmgckHbQOjaRpo50DgcOsgKjGSxccEGbQOjaR)meqLmgoeZdiJHGsyGkAcW6VhGyMeuNz7qiqLYWH177kB0HRUMIFjlAHNxjwHe5vmxGTCUitqhQ8TRydciMWz5p6HH34vEklDhjICTqfCfRgvqtZxfu8lzrl8dnKiVYfzzJoC95z9CXJ7vCQOja7xDv3eQ08AZXWGztI5YGGIFjlAHNHa9GwtxsGMJHXGS0YIK1FStQjyakOtHPmsM)v2OdxXKeZfELW1u8lzrl88kHB((UI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(6MeZLbbf)sw0c)vUilB0HRppRhhFCVItfnby)QRSrhUUU0Yorf(Ry1OcAA(QS0Yorf(RydciMWz5p6HH34vEklDhjICTqfCfZfylNlYe0HkF7kxKLn6W1NNL)4X9kov0eG9RUQBcvAEnr4XlaMncjSizRPF3nhddMzIi9gHw4bcJJuFxzJoCfR5gkBuB4kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5RXCdLnQnCLlYYgD46ZZY374EfNkAcW(vx1nHknV2CmmyMjI0BeAHhimos972DgcOsgdhI5bKXqqjmqfnby93dqmtcQZSDieOszKm)17JtoDlPmeqLmgoeZdiJHGsyGkAcW6Z3v2OdxxxAzNjHkhUI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QS0YotcvoCLlYYgD46ZZYN)X9kov0eG9RUQBcvAET5yyWmteP3i0cpqyCK63T7meqLmgoeZdiJHGsyGkAcW6VhGyMeuNz7qiqLYiz(R3hNC6wsziGkzmCiMhqgdbLWav0eG1NVRSrhUQjI0NjHkhUI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(6mrK(mju5WvUilB0HRppl)1oUxXPIMaSF1vDtOsZRGlOdvQuWYeYdA5mhI2ejCsyWf2zM0n4pdbujZckhwIYYav0eG1FZXWGzbLdlrzzCK6xsnhddgdcAMnsuwghP(D7wsziGkzmCiMhqgdbLWav0eG1hNC6odbujJHdX8aYyiOegOIMaS(7biMjb1z2oecuPm8DLpFxzJoCLJiOz2irz5vc3E(UI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QbbnZgjk7vUilB0HRpplFoCCVItfnby)QR6MqLMxZqavYSGYHLOSmqfnby93Cmmywq5WsuwghPxzJoC11HPGxjCDmxUI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QimfdIyUCLlYYgD46ZZY3vh3R4urta2V6QUjuP51yNutWauqNctzKmhUYgD4kMKyUWReUMIFjlAHNxjCVMVRyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMVUjXCzqqXVKfTWFLlYYgD46ZZYF9h3R4urta2V6kB0HRRlTSZKqLd8kHBpFxXQrf008vzPLDMeQC4k2GaIjCw(JEy4nELNYs3rIixlubxXCb2Y5ImbDOY3UYfzzJoC95z5JXX9kov0eG9RUQBcvAEndbujdYeq2lbbpWav0eG1)gHewKSfJGIFjlAHFOHejdb6bTMUKanhdJbzPLfjR)EaIzsqDMTdHavkJloELn6WvnrK(mju5aVs42Z3vmxGTCUitqhQ8TRydciMWz5p6HH34vEklDhjICTqfCfRgvqtZxNjI0NjHkhUYfzzJoC95z57Ih3R4urta2V6QUjuP51meqLmgoeZdiJHGsyGkAcW6VhGyMeuNz7qiqLYWH1739gHewKSfJGIFjlAHFOHejdb6bTMYGFB5KtjLHaQKbzci7LGGhyGkAcW67kB0HRAIi9zsOYbELWnFFxXCb2Y5ImbDOY3UIniGycNL)OhgEJx5PS0DKiY1cvWvSAubnnFDMisFMeQC4kxKLn6W1NNLphFCVItfnby)QR6MqLMxLugcOsgKjGSxccEGbQOjaRFjLHaQKXWHyEazmeucdurta2RSrhUQjI0NjHkh4vc3R57kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5RZer6ZKqLdx5ISSrhU(8SRnECVItfnby)QR6MqLMxD7o2j1emaf0PWugpo5mdbujZMeZfAHFyMisNbQOjalNCMHaQKPHCewGyqNjdurtawF(L0eYHgQCMmjfiEC8ahKULz0hNCAaKqmmLsj0KHa9GwtzC1v2OdxXKeZfELW1u8lzrl88kHBo47kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5RBsmxgeu8lzrl8x5ISSrhU(8SR5DCVItfnby)QR6MqLMxZqavYSeuXmrKodurtaw)nhddgdcAMnsuwgc0dAnDjhyCr)UDlPmeqLmgoeZdiJHGsyGkAcW6JtoDNHaQKXWHyEazmeucdurtaw)9aeZKG6mBhcbQug(UYNVRSrhUYre0mBKOS8kHB((UI5cSLZfzc6qLVDfBqaXeol)rpm8gVYtzP7irKRfQGRy1OcAA(QbbnZgjk7vUilB0HRpp7A8pUxXPIMaSF1vDtOsZRGlOdvQuWYeYdA5mhI2ejCsyWf2zM0n4xsnhddgdcAMnsuwghP(D7wsziGkzmCiMhqgdbLWav0eG1hNC6odbujJHdX8aYyiOegOIMaS(7biMjb1z2oecuPm8DLpFxzJoCLJiOz2irz5vc3R57kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5Rge0mBKOSx5ISSrhU(8SRT2X9kov0eG9RUQBcvAEndbujJHdX8aYyiOegOIMaS(ZqavYGmbK9sqWdmqfnby97Ec5qdvotMKcepoEGds3Ym6VhGyMeuNz7qiqLYizxC03v2OdxDDyk4vcxhZfELWTNVRyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMVkctXGiMlx5ISSrhU(8SRXHJ7vCQOja7xDv3eQ08AgcOsgdhI5bKXqqjmqfnby9lPmeqLmitazVee8adurtaw)UNqo0qLZKjPaXJJh4G0TmJ(7biMjb1z2oecuPms2vR57kB0HRUomf8kHRJ5cVs4MVVRyUaB5CrMGou5BxXgeqmHZYF0ddVXR8uw6ose5AHk4kwnQGMMVkctXGiMlx5ISSrhU(8SR5QJ7vCQOja7xDv3eQ08QBjnHCOHkNjtsbIhhpWbPBzg93dqmtcQZSDieOszKSh)rFCYPBjLHaQKXWHyEazmeucdurtaw)tihAOYzYKuG4XXdCq6wMr)9aeZKG6mBhcbQugjZHrFxzJoC11HPGxjCDmx4vc3R57kMlWwoxKjOdv(2vSbbet4S8h9WWB8kpLLUJerUwOcUIvJkOP5RIWumiI5YvUilB0HRpp7AR)4EfNkAcW(vx1nHknV2CmmymerhsuH3byiqpO10LCGXfVYgD4khjIoKOcVdWReU98DfZfylNlYe0HkF7k2GaIjCw(JEy4nELNYs3rIixlubxXQrf008vdr0Hev4DGRCrw2OdxFE21W44EfNkAcW(vxzJoCvDklqOf(R6MqLMxJDsnbdqbDkmLX7k2GaIjCw(JEy4nEfRgvqtZxNoLfi0c)vmxGTCUitqhQ8TR8uw6ose5AHk4kxKLn6W1NNDnx84EfNkAcW(vxzJoCfB0wEJMaHxjC757kwnQGMMVsqB5nAcKRydciMWz5p6HH34vEklDhjICTqfCfZfylNlYe0HkF7kxKLn6W1NNDno(4EfNkAcW(vxzJoCLJerhsuH3b4vc389DfRgvqtZxnerhsuH3bUIniGycNL)OhgEJx5PS0DKiY1cvWvmxGTCUitqhQ8TRCrw2OdxFEwomECVItfnby)QRSrhUUc5iSaXGotELWnFFxXQrf0081gYrybIbDMxXgeqmHZYF0ddVXR8uw6ose5AHk4kMlWwoxKjOdv(2vUilB0HRpFELn6WvL2XKxjWPwIAdDOsxG8kHfmchr(8ha]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170409.204707, [[diZWbaGEuO2fkvBtLIzQsPztYnjW3ef7uf7LA3c7xuAye63sgkkWGvjgoehev5ye1crvTuvslMilxvTiuPNcESQ8Cs1evPQPsqtwHPl1frfptK66OqwgPSzuqBhL4YihgQPHs57OKopkQ)kQA0I4Zq6KIe3wrNwP7js6HIkVgfzDQuzlBHg4eyjfnmFd3tmeZivB(gae6Ty1YyCVv4J2nPnCLuewN8rtuoJiBIASlRLwKT0gG3FrAdg496TcDl0hzl0aNalPOH5BaE)fPn0fkQIyhP6TcDd8Kw12mBaP6TcdPeJ9H76BiQGmCWtYadQERWaVpQUHapPu5I8lvfO0ipsXk95A4kPiSo5JMOCgzrd5sOhtckwOjfTLmiOgh8KmWf5xQkqPrEKIv6Z1TpAwObobwsrdZ3Wbpjd3UOjDSbA2lqYsQHbEsRABMnOw0Ko2anVEYsQHHRKIW6KpAIYzKfnKsm2hURVHOcYqUe6XKGIfAsrBjdcQXbpjdUDB4GNKbyN5YEHtKGJhnPOVl7fKp9QPeUDBda]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170409.204707, [[d4ZSoaGEePsBcrSlqTnQu7ts0mru1Jjz2OA(scDtjvCyHVjPCBj2js2RYUvz)KsJssvdJQACiQ05jfNgyWKQgUQYbLKoLQGJHuNtsqlKcTuvrlgHLtPhIiLNsSmvvpxuterQyQujtgKPl1fPOEfIu1LHUUi2OKk9zkyZuX2ru(lv57QszAscmpejpJu5qiQy0I04vfQCsvjVMICnvHY9uLQvQku1Vr54Qc5rpxtmFbbhHMXjurbNiMjVw9M5ybVo4A1xnRWdkofor(qfi4as3ObSBu)U)N8e5yKXr97txZVc8)HP)15xb6Mikl4RNmPQQbSlpxJIEUMy(ccocnJteLf81tAMbdCewXyCi2BxMeiwd7WJc6LtzktWwSeGlxjrIJdCKv4bfNcHHsSrdyhjkgJdXE7G5bzHhrIn3WwSeGlxPpjKdrIJdCUz2Ije)qlCY3KQeaoO1mjYk8GItHtEDqav0m7KJD4KNihJmoQFFA301G91nHkk4KQzfEqXPW1J6FUMy(ccocnJtQt84aLKIRWAa78eDteLf81tiNgOmbodtQsa4GwZehEuqVCktzAYRdcOIMzNCSdNqffCsD5rb1Qxszkttinnko6kSgWopIjprogzCu)(0UPRb7RBIKYERomiGdaT5rSEu6MRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57)(KyXsaUmPENiXXboYk8GItHWqj2ObSJefJXHyVDWrwHhuCke2ILaCzsprIJdCKv4bfNcHHsSrdyhPEhkXgnGDtQsa4GwZehEuqVCktzAYRdcOIMzNCSdNqffCsD5rb1QxszktA1xp9dtEICmY4O(9PDtxd2x36rvbZ1eZxqWrOzCIOSGVEcrIJdmQszy2J541PONblgTxo5Gql4maN8rc5qK44ahzfEqXPq4KpskbYZTLvGvjwlEDLVtUU1(4N8e5yKXr97t7MUgSVUjVoiGkAMDYXoCsvcah0AMGHTtFusycNqffCI5W2PpkjmHRh1JnxtmFbbhHMXjIYc(6jLa552YkWQeRfVUY3RWFsihIehh4iRWdkofcN8n5jYXiJJ63N2nDnyFDtEDqav0m7KJD4KQeaoO1mbdBN6LtzkttOIcoXCy7uT6LuMY06r5EUMy(ccocnJteLf81tAMbdCeoSnWjuTxqa4GwZKQeaoO1mj3mBXeIFODYtKJrgh1VpTB6AW(6MiPS3Qddc4aqBEetOIcorAMTycXp0o51bburZSto2HRhvT5AI5li4i0moruwWxpzYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjvjaCqRzcYXcEDW9i4rUNqffCIzowWRdUw9g5rUxpkYDUMy(ccocnJteLf81tcvdid9Wdlamx576MuLaWbTMjCWJsaqELWqj8AwJLjVoiGkAMDYXoCYtKJrgh1VpTB6AW(6MqffCc5bpkbaPvFDcdLqRExSglRhvfoxtmFbbhHMXjIYc(6jejooWFS3qRhZXRtrVsG8CBzf4KpsisCCGZnZwmH4hAHt(ijunGm0dpSaWmP0n5jYXiJJ63N2nDnyFDtEDqav0m7KJD4KQeaoO1mHdmK2h4m4rW49eQOGtipWqAFGZGw9gz8E9OO9NRjMVGGJqZ4erzbF9eiwd7WJc6LtzktWwSeGlxPkYTxdkij1Rymoe7TZZIHQRyfjsCCGJScpO4uiCY3dtEICmY4O(9PDtxd2x3KxheqfnZo5yhoPkbGdAnt4bzHhrIn3tOIcoH8bzHw9gtS5E9OOPNRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57)(KqK44aJCSGxhCphMkjdN8rIfDSyoni44KQeaoO1mXHhf0lNYuMM86GaQOz2jh7WjprogzCu)(0UPRb7RBcvuWj1LhfuREjLPmPvF9)pSEu0)Z1eZxqWrOzCIOSGVEsjqEUTScSkXAXRR89FFsisCCGrowWRdUNdtLKHt(ijunGm0dI1Wo8OGE5uMYePQpunGm0dpSaWmPExhjHQbKHE4HfaMRyf19WKNihJmoQFFA301G91n51bburZStuAuCCcvuWj1LhfuREjLPmPvpPPrXXjvjaCqRzIdpkOxoLPmTEu06MRjMVGGJqZ4erzbF9KsG8CBzfyvI1Ixx57KR7jprogzCu)(0UPRb7RBYRdcOIMzNCSdNuLaWbTMjyy7uVCktzAcvuWjMdBNQvVKYuM0QVE6hwpk6kyUMy(ccocnJteLf81tisCCGBwJfVsKB0Qb2ILaCzsr7xXkwprIJdCZAS4vICJwnWwSeGltkIehh4iRWdkofcdLyJgWosVIX4qS3o4iRWdkofcBXsaUmjkgJdXE7GJScpO4uiSflb4YKI(XEyYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjurbN4I1yrR(6e5gTAMuLaWbTMjnRXIxjYnA1SEu0p2CnX8feCeAgNikl4RNqK44aJQugM9yoEDk6zWIr7Ltoi0codWjFtQsa4GwZemSD6Jsct4KxheqfnZo5yho5jYXiJJ63N2nDnyFDtOIcoXCy70hLeMqT6RN(H1JI29CnX8feCeAgNikl4RNeQgqg6HhwayUs6jprogzCu)(0UPRb7RBYRdcOIMzNCSdNuLaWbTMj8GSWJaJYeQOGtiFqwOvVrmkRhfDT5AI5li4i0moruwWxpHiXXb(J9gA9yoEDk6vcKNBlRaN8rsOAazOhEybGzsPBYtKJrgh1VpTB6AW(6M86GaQOz2jh7WjvjaCqRzchyiTpWzWJGX7jurbNqEGH0(aNbT6nY4Tw91t)W6rrtUZ1eZxqWrOzCIOSGVEsOAazOhEybG5kPN8e5yKXr97t7MUgSVUjVoiGkAMDYXoCsvcah0AMOsdW5Xbgs7dCgMqffCcPLgGtREYdmK2h4mSEu0v4CnX8feCeAgNikl4RNm5jYXiJJ63N2nDnyFDtEDqav0m7KJD4eQOGtipWqAFGZGw9gz8wR(6)Fysvcah0AMWbgs7dCg8iy8E9O(9NRjMVGGJqZ4erzbF9KcJmWzGel6yXCAqWXjprogzCu)(0UPRb7RBYRdcOIMzNCSdNqffCsD5rb1QxszktA1xVUhMuLaWbTMjo8OGE5uMY06r9tpxtmFbbhHMXjVoiGkAMDIsJIJteLf81tcvdid9WdlamxjnjHQbKHEqSg2Hhf0lNYuMivOAazOhEybG5jKMgfhDfwdyNhXKQeaoO1mXHhf0lNYuMMiPS3Qddc4aqBEgNqffCsD5rb1QxszktA1xpPPrXrT6)FyYtKJrgh1VpTB6AW(6wpQ))5AI5li4i0moHkk4eZHTt1QxszktA1x))dtEICmY4O(9PDtxd2x3KxheqfnZo5yhoPkbGdAntWW2PE5uMY0erzbF9KcJmWzy96jKoOtKW7zC9ga]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170409.204707, [[daKEoaqiiPuBII0Oqv5uOQAvqsjVcskAxeAyuvhdvwMk6ze00GKQRjueBJI6Bc04ujLZPscZJIO7Ps0(ujCqHQfsHEOkPAIQKOUifSrkcNufSsHI6LQKiZuOWnHKStuSuvONImvbSxP)kObtGdR0IrPhtPjtLUmyZuLpJQmAQ40Q61qy2K62kA3q9BsgUk1Xfkz5e9CfMUORlKTdj(UkjnEiPW5HO1luKMVqP2pK6Y1aLmGxwn4wJLiR8VZsLUYG3gPZAS0rqd7akZPpxqFu3)uK7uOpQlSeDd2F1FmDZxHlZP5ZsXT5RWJgOmCnqjd4LvdU1yjYk)7SeQD(wepMxP4SV(tKL807echoklIshWUVDtLSewHHshbnSdOmN(CM5ck6lSeZoHsMqVtaTaYrzrGwaF(83SmNnqjd4LvdU1yjYk)7SeBKNNiyDuWiu5fMoqipjSz4ic7cYhZtm6205c6rkvtrBKuc48IlVM5shbnSdOmN(CM5ck6lS0bS7B3ujlHvyOeZoHsgwz6eROfbuko7R)ezjyLPtSIweqZYiSbkzaVSAWTglrw5FNLyJ88eFl4fjrkgDB6Cb9iLQPOnskbCEXLxZCP4SV(tKL8KQrgoCuweLoGDF7MkzjScdLocAyhqzo95mZfu0xyjMDcLmHuns0cihLfrZYG6nqjd4LvdU1yjYk)7S0Cb9iLQPOnskbCEXLxXj6yU0rqd7akZPpNzUGI(clDa7(2nvYsyfgkXStOKHvMoOfqoklIsXzF9NilbRmDchoklIMLjM0aLmGxwn4wJLy2juIsLCIaGBqwko7R)ezPrQKteaCdYshWUVDtLSewHHsKv(3zPuXJNgexz(ERndx2x)jst5BT5Jcecyy(W4cUyh7bK5J5nexE8KWy8OaHJujNia4gK8x6iOHDaL50NZmxqrFHnlJ5gOKb8YQb3ASezL)DwQ0rqd7akZPpNzUGI(clDa7(2nvYsyfgkXStOKbnmbCUA0cmQ3rwko7R)ezjqdtaNRoKvVJSzzc2aLmGxwn4wJLiR8VZsZf0JuQMI2iPeWPjVmO5sXzF9Nil9wWlsIS0bS7B3ujlHvyO0rqd7akZPpNzUGI(clXStO0bl4fjr2SmxRbkzaVSAWTglrw5FNLwB(OaHagMpmU4sHLIZ(6prws)Xk6DdNlV5gMQeMLoGDF7MkzjScdLy2jukgFSIEx0cq1YBUOfeqLWS0rqd7akZPpNzUGI(cBwMRObkzaVSAWTglrw5FNLyJ88eVvxfKHkVW0bcNlOhPunfJUnLnYZtCKk5eba3Gum6201MpkqiGH5ddtkSuC2x)jYs6NNtIFmVqwLolDa7(2nvYsyfgkDe0WoGYC6ZzMlOOVWsm7ekfJNNtIFmp0cmQ0jAb8rxj(Bwgo)gOKb8YQb3ASezL)DwYvLIE6DcHdhLfHOeM7Jhxy3rgM)eqhZLocAyhqzo95mZfu0xyPdy33UPswcRWqjMDcLIXIYIwGXi5ilfN91FISKErzdzJKJSzz44AGsgWlRgCRXsKv(3zj2ippX3cErsKIr3MY3Cb9iLQPOnskbCEXLN(Xo2SrEEIVf8IKifLWCF8WK8XZ6IAXg55j(wWlsIuCKRfbQjh)8xko7R)ezjpPAKHdhLfrPdy33UPswcRWqPJGg2buMtFoZCbf9fwIzNqjtivJeTaYrzrGwaFC83SmCNnqjd4LvdU1yjuTOg)mAgyL8GCusyjYk)7S0Cb9iLQPOnskbCEXLN(MYg55jcAyc4C1HEkB0qm62uj4jHHZYQb0XCP4SV(tKL807echoklIshWUVDtLSewHHsm7ekzc9ob0cihLfrPRJ0QHaRKhKJYw6iOHDaL50NZmxqrFHLih1vrLY99EqokBZYWjSbkzaVSAWTglrw5FNLMlOhPunfTrsjGZlU803u2ipprqdtaNRo0tzJgIr3MYhFRnFuGqadZhgxEA6AZhfi0vLIE6DcHdhLfHjp5p2XMV1MpkqiGH5dJlUuOPRnFuGqxvk6P3jeoCuweMui)8xko7R)ezjp9oHWHJYIO0bS7B3ujlzrA1qjMDcLmHENaAbKJYIaTa(44V0rqd7akZPpNzUGI(cBwgouVbkzaVSAWTglrw5FNLyJ88eFl4fjrkgDxko7R)ezjpPAKHdhLfrPdy33UPswcRWqjuPq5X8kdxjMDcLmHuns0cihLfbAb8DYFPJGg2buMtFoZCbf9fwICuxfvk337b5OglDDhWIavkuGjGZASzz4Ijnqjd4LvdU1yjYk)7S0Cb9iLQPOnskbCEXLxZCP4SV(tKLGvMoHdhLfrPdy33UPswcRWqjMDcLmSY0bTaYrzrGwaFC8x6iOHDaL50NZmxqrFHnldN5gOKb8YQb3ASezL)DwInYZtucdfEXwimvjmfLWCF8WKC(LocAyhqzo95mZfu0xyPdy33UPswcRWqP4SV(tKLsvcZW5osqISeZoHsbujmrlav7ibjYMLHlyduYaEz1GBnwISY)olXg55jcwhfmcvEHPdeYtcBgoIWUG8X8eJUlDe0WoGYC6ZzMlOOVWshWUVDtLSewHHsXzF9NilbRmDIv0IakXStOKHvMoXkAraOfWhh)nld31AGsgWlRgCRXsm7ekfJNNtIFmp0cmQ0zPJGg2buMtFoZCbf9fw6a29TBQKLWkmuISY)olXg55jERUkidvEHPdeoxqpsPAkgDB6AZhfieWW8HHjfwko7R)ezj9ZZjXpMxiRsNnld3v0aLmGxwn4wJLiR8VZsRnFuGqadZhgxWv6iOHDaL50NZmxqrFHLoGDF7MkzjScdLIZ(6prwY6Spou)8Cs8J5vIzNqPR7SpgTGy88Cs8J51SmN(nqjd4LvdU1yjYk)7SuP4SV(tKL0ppNe)yEHSkDw6a29TBQKLWkmuIzNqPy88Cs8J5HwGrLorlGpo(lfxYBuQ0rqd7akZPpNzUGI(clroQRIkL779GCu2sx3bSiqLcfyc4SSnlZjxduYaEz1GBnwISY)olnvO8yEMkbpjmCwwnu6iOHDaL50NZmxqrFHLoGDF7MkzjScdLy2juYe6DcOfqoklc0c47K)sXzF9Nil5P3jeoCuwenlZ5zduYaEz1GBnwISY)olnvO8yEMU28rbcDvPONENq4WrzryY1MpkqiGH5dJshbnSdOmN(CM5ck6lS0bS7B3ujlzrA1qP4SV(tKL807echoklIsm7ekzc9ob0cihLfbAb8DYpAbxhPvdnlZPWgOKb8YQb3ASezL)DwAQq5X8kDe0WoGYC6ZzMlOOVWshWUVDtLSewHHsXzF9NilbRmDchoklIsm7ekzyLPdAbKJYIaTa(o5VzZsm7ekrgIbAbg0WeW5Qrl4Gf8IKiB2c]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170409.204707, [[d0dsoaGEqI0MaP2ffTnrY(ePAMQenBeZhvLCtvc(MO42Q4WsTtuzVk7gy)QQgfjXWeXVj1ZiPopQYGbvdhuoOOQtrs6yi54IuAHuWsfvwmkwov9quv1tjwMQYZvLjQsOmvQOjJutx4IuOtl5YqxheBeKWHujuTzvQTlknnuv03fP4ZuP5bs6Xu6VO0OjX4bjItQsACOQuxdKOUhQQSsuv4CQeYRPcpQ5CIrqZqq6zyYfdVBiKygMW1hCIy8YF4gj4bbrt(HFzUj5qc2pCCFjuzs4ZKptQp1j8P6jcm0wnPGs7O0GX9L6BsEBuAWBohh1CoXiOzii9mmrS(cwm5IhL1rbCNKNPivWBYnPpi7trBDm5kGUSDO9taAaojhsW(HJ7lHkfvgZe1t46dobki9b)HlkARJF4QKO6IX9nNtmcAgcspdteRVGftyGCFBIwfn(y13SHcY66XoyFqa0OVaUMqGb9PrYl86JPfI3JGiD(X3PMKdjy)WX9LqLIkJzI6jxb0LTdTFcqdWjC9bNyS9HsAH0oWj5zksf8MGTpuslK2bUyCQNZjgbndbPNHjI1xWIjNgjVWRpMwiEpcI053f99ZhtYHeSF44(sOsrLXmr9KRa6Y2H2pbOb4eU(Gtm2(q5hUOOToMKNPivWBc2(qH9POTowmo(CoNye0meKEgMW1hCIeA)XbIWq)K8mfPcEtEH2FCGim0p5kGUSDO9taAaorS(cwmj0UUe0S9rD32GTzksf8GwL2gvwKfb4PWx6u8fF9WikG7ZSDD947vzr2xO9hhicd9QojhsW(HJ7lHkfvgZe1lghuEoNye0meKEgMiwFblMmjhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46doXibpiiAYpCdK(ftYZuKk4nbj4bbrtyzi9lwmUuZ5eJGMHG0ZWeX6lyXK2gvwKfb4PWx68t9K8mfPcEtivAHu0SN290SHoWZKRa6Y2H2pbOb4eU(GtUSslKI(h(fA3t)d3PoWZKCib7hoUVeQuuzmtuVyCzMZjgbndbPNHjI1xWIj06W8M0hK9POTom94PlWlDB)c2Oo4pFmjhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46do5YoB)d3ae)lMKNPivWBcPZ2Smq8VyX4475CIrqZqq6zyYfAOK6a54S9Uy8MOEIy9fSyYPrYl86JPfI3JGiD(9LandK7BtKGheenH9wBH8mHadApE7XNsZqWF(ysEMIubVj3K(GSpfT1XKRa6Y2H2pbOb4eU(GtGcsFWF4II26yc)5zjOZ27IXBmtYHeSF44(sOsrLXmr9errNMlOPR7c9VXSyCx0CoXiOzii9mmrS(cwm50i5fE9X0cX7rqKo)(sGMbY9TjsWdcIMWERTqEMqGbTkQ02OYISiapf(43h0TnQSilTomVj9bzFkARdO(PkFXxQ02OYISiapf(sNFQHUTrLfzP1H5nPpi7trBDav1QQ6K8mfPcEtUj9bzFkARJjxb0LTdTFILNLGt46dobki9b)HlkARJF4QqP6KCib7hoUVeQuuzmtuVyCujZ5eJGMHG0ZWeX6lyXKtJKx41htleVhbr68JVtnjptrQG3eS9Hc7trBDm5kGUSDO9taAaoHRp4eJTpu(HlkARJF4QqP6KCib7hoUVeQuuzmtuVyCuuZ5eJGMHG0ZWeX6lyXegi33ME8PbnWISHoWJPhpDbEqLkzsoKG9dh3xcvkQmMjQNCfqx2o0(janaNKNPivWBsOd8WE6xGEEt46doXPoWZp8l0Va98wmoQV5CIrqZqq6zyIy9fSycdK7Bt0QOXhR(Mnuqwxp2b7dcGg9fW1ecSj5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjy7dL0cPDGt46doXy7dL0cPDG)WvHs1fJJs9CoXiOzii9mmHRp4KllxLaua3F4g0KysoKG9dh3xcvkQmMjQNCfqx2o0(janaNiwFblMWa5(2eMonONvFZgki7PrYl86Jjeyq32OYISiapf(GQAOPrgi33MKYvjafWL1RPnP1PbmjptrQG3es5QeGc4YYOjXIXrXNZ5eJGMHG0ZWeX6lyXegi33MW0Pb9S6B2qbzpnsEHxFmHad62gvwKfb4PWhuvdDBJklYsRdZBsFq2NI26aQFtYHeSF44(sOsrLXmr9KRa6Y2H2pXYZsWjC9bNCz5QeGc4(d3GMe)WvH)8Seu1j5zksf8MqkxLauaxwgnjwmokO8CoXiOzii9mmrS(cwmPTrLfzraEk8Lof00idK7Bts5QeGc4Y610M060a(5Jj5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjwLUaSKYvjafWDcxFWj8xPlWp8llxLaua3fJJk1CoXiOzii9mmrS(cwmPTrLfzraEk8Lof0mqUVnjLRsakGlRxtBcbg0TnQSilTomjLRsakGlRxtd12gvwKfb4PW3K8mfPcEtSkDbyjLRsakG7KRa6Y2H2pXYZsWj5qc2pCCFjuPOYyMOEcxFWj8xPlWp8llxLaua3F4QWFEwcQ6IXrLzoNye0meKEgMiwFblMqJmqUVnjLRsakGlRxtBsRtdysEMIubVjKYvjafWLLrtIjxb0LTdTFcqdWjC9bNCz5QeGc4(d3GMe)WvHs1j59UVjtYHeSF44(sOsrLXmr9errNMlOPR7c9VXmH)kO1Xf0zXdcIXSyCu89CoXiOzii9mmrS(cwmPTrLfzraEk8Lof0TnQSilTomjLRsakGlRxtd12gvwKfb4PW3KCib7hoUVeQuuzmtup5kGUSDO9tS8SeCsEMIubVjKYvjafWLLrtIjC9bNCz5QeGc4(d3GMe)WvHs1F48NNLGlgh1fnNtmcAgcspdteRVGftMKdjy)WX9LqLIkJzI6jxb0LTdTFcqdWj5zksf8MqkxLauaxwgnjMW1hCYLLRsakG7pCdAs8dxLpvxmUVK5CIrqZqq6zyIy9fSyYrNTaUq7XBp(uAgcojhsW(HJ7lHkfvgZe1tUcOlBhA)eGgGt46dobki9b)HlkARJF4Q8P6K8mfPcEtUj9bzFkARJfJ7JAoNye0meKEgMiwFblMC0zlGl0TnQSilTomVj9bzFkARdO22OYISiapf(MKdjy)WX9LqLIkJzI6jxb0LTdTFILNLGtYZuKk4n5M0hK9POToMW1hCcuq6d(dxu0wh)Wv5t1F48NNLGlg333CoXiOzii9mmrS(cwm5OZwa3j5qc2pCCFjuPOYyMOEYvaDz7q7Na0aCsEMIubVjy7df2NI26ycxFWjgBFO8dxu0wh)Wv5t1flMiwFblMSyda]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170409.204707, [[d4d0haGEIkQnHssTlcTnPu7tkjZKuPLPknBvMpPIBkL4WI(MaEnrvStv1Ev2nL9Rk(jrLmms53O6YGHsuHgmKmCi1bjkNIOICms6CevWcjrlLalMilNklcL4PipMQwhjWejQstLu1KfA6sUOuCAOEMGCDiAJevQptqBwG2okPQVtc9vusLPHsI5Hsk(lk1TrXOjbDiPK6KcQXruvUgrv15HWkrjjpxQgfkP0tD6h1yP0bXPCK8cbtKxnLJi0GhNhwoNfMB7)2(DKa4GSd7)QPgqJv0EfvFdPXkHgrEhgDnAKmFH5wF63xD6h1yP0bXPCe5Dy01OIlu4bIyRaNdj6QpsMe(WfIrkITi7UcH0nkSfX(S4Urg3Gr)KbgX6Ww8bfPqiDJeahKDy)xn1aQAR2)D6h1yP0bXPC0pzGrYrEH52iY7WORrfxOWderZlm36SAwBRlUqHhi658lYv066OJNZVixrtmi2bSHdyaRYt0bmj26T6v(0KtJeahKDy)xn12Qbe1cnkSfX(S4Urg3GrYKWhUqmcnVWCBul84pzGrSG2XpUjeISrZveCSSA)qt)OglLoioLJiVdJUgjHmyqXIxadBMSxGdHOdysS1znVJKjHpCHyuXlGHnt2lWHyuylI9zXDJmUbJeahKDy)xn12Qbe1cn6NmWi98cyEq1s2lWHy1(SY0pQXsPdIt5iY7WORrfxOWde9C(f5kA9rcGdYoS)RMAB1aIAHgf2IyFwC3iJBWizs4dxigfe7a2WbmGv5n6NmWi5g7GhunhWawL3Q9L)PFuJLsheNYrK3HrxJkUqHhi658lYv06JeahKDy)xn12Qbe1cnkSfX(S4Urg3GrYKWhUqmQxChdB4agWQ8g9tgyevChZdQMdyaRYB1(TN(rnwkDqCkhrEhgDnQ4cfEGONZVixrRpsMe(WfIrWbmGv5XMj7f4qmkSfX(S4Urg3Gr)Kbg1CadyvEpOAj7f4qmsaCq2H9F1uBRgqul0Q9dm9JASu6G4uoI8om6AuRR8aReZUhSyAEqeSu6GOo6iHmyqXS7blMMherIwhD8C(f5kAIz3dwmnpi6aMeB9wj)AJeahKDy)xn12Qbe1cnkSfX(S4Urg3GrYKWhUqms648i7GiDig9tgyKYJZJpOKBKoeR2x(M(rnwkDqCkhrEhgDnQ1vEGvIz3dwmnpicwkDquhDKqgmOy29GftZdIirpsaCq2H9F1uBRgqul0OWwe7ZI7gzCdgjtcF4cXijW1bN8GnHJ(jdmsj46GtEWMWv7lhM(rnwkDqCkhrEhgDnk9fM1dSbdyWqVvVJ(jdmsastbpOKjxnJKjHpCHyKdPXo9fMBSpCVgf2IyFwC3iJBWibWbzh2)vtTTAarTqJAHh)jdmIfQr3hunhWawL3dkzYvdlR2xvB6h1yP0bXPC0pzGrcqAk4bLSUhSyAEye5Dy01OkpWkXS7blMMheblLoiosaCq2H9F1uBRgqul0OWwe7ZI7gzCdgjtcF4cXihsJD6lm3yF4EnQfE8NmWiwOgDFq1CadyvEpOK19GftZdSSAFv1PFuJLsheNYr)KbgjaPPGhuH9qqKoeJiVdJUgv5bwjI9qqKoeIGLsheFyvJeahKDy)xn12Qbe1cnkSfX(S4Urg3GrYKWhUqmYH0yN(cZn2hUxJAHh)jdmIfQr3hunhWawL3dQWEiishcwwTV670pQXsPdIt5OFYaJeG0uWdkDXcvyzyt4dkb84iY7WORrvEGvIhwOcldBcz74rrWsPdIJeahKDy)xn12Qbe1cnkSfX(S4Urg3GrYKWhUqmYH0yN(cZn2hUxJAHh)jdmIfQr3hunhWawL3dkDfWYQvJ(jdmIA09bvZbmGv59GsEHGjYRwTb]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170409.204707, [[dSZ(iaGEskPnPOYUKKTjPAFKuQzkvvZgv3ekUnfpMs7uv2Ry3QSFsv)KKsmmjACsvPomvFtQYGjfdxkCqsYPiPIJrKZbLsTquQLQOSyOA5QQhkf9uKLruEokMiukzQsOjRW0v6IevNxcUm46KsBekfNgYMLu2Uu61OKVtsvtJKI5bLQNrQ8zPYOjXFvKtcLCifv5Asvj3trv9BchxQkgfjv6iLIHKFoohgHDONBGqK8(1RrohmWToxVgvQf5Hi7h1ydfAgWbNbYtwPuVs1ukRssMUs1Ole1aSiNJuR(IexEYQllKk7IehtkMNukgs(54Cye2HEUbcrR4Bybqd4hAgWbNbYtwPuDPEvL6cPchXrBHqmR4Bybqd4hcRBGS(k(HoXbHAQawwyeTGbUn4HWigp3aHYMNSumK8ZX5WiSdr2pQXgAfDDCOYke8Hq9htONBGqQySWn8ZcHMbCWzG8KvkvxQxvPUqQWrC0wiKZyHB4NfcH1nqwFf)qN4GqnvallmIwWa3g8qyeJNBGqzZtxkgs(54Cye2HEUbc1pQpArd9AW4DgxVMIIfmHMbCWzG8KvkvxQxvPUqQWrC0wieh1hTOXKX7m(0kwWecRBGS(k(HoXbHAQawwyeTGbUn4HWigp3aHYMNAsXqYphNdJWoez)OgBiJdCM9lmvwT)pCRApFzLZnV15WTvCuNYEORB6lgvW54Cym3hQ9bgfhNdHuHJ4OTqOAC3atmkclRqnvallmIwWa3g8qp3aHWgUBa9AifHLvOzahCgipzLs1L6vvQlePiupgXavdbFMGhcRBGS(k(HoXbHWigp3aHYMxFLIHKFoohgHDiY(rn2qUDrTWeCGbbmyxnZ52f1ctdXwvJ7gyIrryzHD3UOwycoWGaMqQWrC0wiunUBGjgfHLviSUbY6R4hYwWYHqZao4mqEYkLQl1RQuxONBGqyd3nGEnKIWYsVMMfSCiBE1tXqYphNdJWo0Znqi5(Fv6JwNfeAgWbNbYtwPuDPEvL6cPchXrBHqG)xL(O1zbHW6giRVIFOtCqOMkGLfgrlyGBdEimIXZnqOS51lfdj)CComc7qK9JASHgITQg3nWeJIWYQ6dghDmQT1z2PfzG5W1wRwf3B9jgT)oOsBJ5M36C42koQtzp01n9fJk4CComMZTlQfMGdmiGb7Qj0ZnqO(9wxVg2A)mBOzahCgipzLs1L6vvQlKkCehTfcX9wFcx7NzdH1nqwFf)qN4GqnvallmIwWa3g8qyeJNBGqzZRVtXqYphNdJWoez)OgBO5TohUTIJ6u2dDDtFXOcohNdJ5C7IAHj4adcyWEFf65giKCoyGBDUEnS5oZgAgWbNbYtwPuDPEvL6cPchXrBHqahmWToFcN7mBiSUbY6R4h6eheQPcyzHr0cg42GhcJy8CdekBEy7umK8ZX5WiSd9CdeQFV11RHn4MqZao4mqEYkLQl1RQuxiv4ioAleI7T(eo4MqyDdK1xXp0joiutfWYcJOfmWTbpegX45giu28KktXqYphNdJWo0ZnqOMko60RPFuNYEORlez)OgBObGRTwTkoQtzp01n9fJQHq9xOzahCgipzLs1L6vvQlKkCehTfczvC0nXrDk7HUUqyDdK1xXp0joiutfWYcJOfmWTbpegX45giu28KKsXqYphNdJWoez)OgBi3UOwyAi2koQtzp01n9fdS72f1ctWbgeWeAgWbNbYtwPuDPEvL6cH1nqwFf)q2cwoesfoIJ2cHSko6M4OoL9qxxONBGqnvC0Pxt)OoL9qxNEnnly5q28KKLIHKFoohgHDiY(rn2q4ARvRI7T(eJ2FhuPTriv4ioAleI7T(eU2pZgcRBGS(k(HoXbHWiArxxiPqp3aH63BD9AyR9ZS61OUsQtiv)oMqgrl66MVuOzahCgipzLs1L6vvQlePiupgXavdbFMWoutfWYcJOfmWTHDimIXZnqOS5jPlfdj)CComc7qK9JASH(qTpWO44CiKkCehTfcvJ7gyIrryzfcRBGS(k(HoXbHWiArxxiPqp3aHWgUBa9AifHLLEnQRK6es1VJjKr0IUU5lfAgWbNbYtwPuDPEvL6c1ubSSWiAbdCByhcJy8CdekB2qylOMRLVHD2ea]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170409.204707, [[datncaGErO2fs12ePMPiWSP0nfv3Mk7uI9s2nI9djnmk8Bvnurudgs1WvHdIsDmuzHOWsfflgjlxslsu6PGLrrphvnrKsMku1KvPPlCrOYLvUUiKnlcA7ifhwQPjI8nrYJH48QOrdP8mO0jHeFgLCAQ6EiL6VqHhcf9Au0It4fGJ0u2Dfdb0AjStKnedbL2nbaUeGk64SZns0wurp56qEhvhcYm7A(PIPbxkJKmmPZzI1ijScGJH4BRpXD4FIkMPnfWgj8pHx4vHt4fGJ0u2Dfdbas1FecINfl7OF8H)j8cyt5T(4uWXh(NiafY1J0XxfqEYeuA3eK8h(NiGDLfVas7gTZExFTNyWQ2ilRGmZUMFQyAWLMlfDdScWeTHWm)PzUrcrji)VL2nbzVRV2tmyvBKLvHkMcVaCKMYURyiO0Uja)hZHk65nFS6PGmZUMFQyAWLMlfDdScyt5T(4uq8XCy4A(y1tbOqUEKo(QaYtMamrBimZFAMBKqucY)BPDtGcvWk8cWrAk7UIHGs7Mai(QJ52XQcYm7A(PIPbxAUu0nWkGnL36Jtb8XxDm3owvakKRhPJVkG8Kjat0gcZ8NM5gjeLG8)wA3eOqHaaP6pcbkKaa]] )

    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170409.204707, [[d8dRkaWCGwVii2KiWUa02qQO9ri1mrQW3afZgQ5tu5MiLhtv3MKZtkTtKSxLDtz)uXpbiAyI04ai50igQiOAWKQHtKoiH6uGGJjkNdGsleuAPIOftWYL4HKINIAzeX6eH(SOAQGOjlPPlCrq1FjkpdPsDDQuBeGWIOs2mHy7GKVtu1xfbLPbqX8qQKrkcsVgKA0a4WsDsKQUSQRbq19iKCias9BiJce6Lnihd3Ab8Rd2XuT6JzIsJJoC8v3IgNOJE9I0UXX4Kh)g8JssAgmPaMualWSXS07jnMKq6GGSrjHoLmwSpiidCqoQSb5y4wlGFDcJPA1hNqFbravJzFHinghO8C8b6riCfjVbMaigDj)bqaEJdaak1h0Leaxo5cI6IofiGNMcHXAa4EOPHG6QBXegN843GFussZGjlDm9wL47avgBi7JflqWKq7ybmcvXUbJX0qvQw9XlgLKb5y4wlGFDWoM9fI0yCGYZXhOuuqqgycGOhHWvK8gqriLl74RUfngy5QMyGIwcGkvo5IUK)ayquxwGKvjNUefDMcHXIfiysODSuuqq2y6TkX3bQm2q2ht1QpoHJccYglUKdo2A1fLlPfegz5Vktks(xCno5XVb)OKKMbtw6ynaCp00qqD1TycJPHQuT6JDjTGWil)vzsrY)IRfJIUhKJHBTa(1b7yQw9XjmIvD0zaExgZ(crAmoq554dKyXlf3sdWXAa4EOPHG6QBXegN843GFussZGjlDm9wL47avgBi7JflqWKq7y5jwvgiaVlJPHQuT6JxmkaZGCmCRfWVoyht1QpgsuCLJoTgmEr7y2xisJXcUfreGLdIS28xwGIRawUQjgiDjzSgaUhAAiOU6wmHXjp(n4hLK0myYshtVvj(oqLXgY(yXcemj0ooqXvYuny8I2X0qvQw9XlgfGpihd3Ab8Rd2XuT6JbeKYD0HJV6w04XSVqKgJduEo(a9ieUIK3ahRbG7HMgcQRUftyCYJFd(rjjndMS0X0BvIVduzSHSpwSabtcTJfHuUSJV6w04X0qvQw9XlgfDoihd3Ab8Rd2XuT6J5avuo6WXxDlA8y2xisJXbkphFGEecxrYBGJ1aW9qtdb1v3Ijmo5XVb)OKKMbtw6y6TkX3bQm2q2hlwGGjH2XGbQOKD8v3IgpMgQs1QpEXOGzqogU1c4xhSJPA1hdhF1TOXo60AW4fTJzFHinghO8C8b6riCfjVbowda3dnneuxDlMW4Kh)g8JssAgmzPJP3QeFhOYydzFSybcMeAhF8v3Iglt1GXlAhtdvPA1hVyuaQb5y4wlGFDWoMQvFmSyeQ6OdiCx0oM9fI0yCGYZXhOhHWvK8gycGiGoA8Tayd6VvBZFG3Ab8RYjNGBrebyd6VvBZFGULkNCEecxrYBaBq)TAB(dSCvtmqrd4PqySgaUhAAiOU6wmHXjp(n4hLK0myYshtVvj(oqLXgY(yXcemj0owaJqvzI4UODmnuLQvF8IrbyhKJHBTa(1b7yQw9XW(c4lqtS8XSVqKgJduEo(a9ieUIK3ataeb0rJVfaBq)TAB(d8wlGFvo5eClIiaBq)TAB(d0Tuimwda3dnneuxDlMW4Kh)g8JssAgmzPJP3QeFhOYydzFSybcMeAhl8c4lqtS8X0qvQw9Xlgvw6GCmCRfWVoyhZ(crAmU9bbQl72vKdkAjjaITpiqDz3UICqrlro5AFqG6YUDf5GIwceglwGGjH2Xf3MS2heKjdtaJX0BvIVduzSHSpMQvFCs3MJUyFqqMJoDqaJXIl5GJTwDr5Ijkno6WXxDlACIo6IbKWDno5XVb)OKKMbtw6ynaCp00qqD1TycJPHQuT6JDXeLghD44RUfnorhDXas4UwmQSSb5y4wlGFDWoM9fI0yC04BbWg0FR2M)aV1c4xhlwGGjH2Xf3MS2heKjdtaJX0BvIVduzSHSpMQvFCs3MJUyFqqMJoDqadhDiMbHXIl5GJTwDr5Ijkno6WXxDlACIo6GelhFh9g07ACYJFd(rjjndMS0XAa4EOPHG6QBXegtdvPA1h7Ijkno6WXxDlACIo6GelhFh9g07AXOYKmihd3Ab8Rd2XSVqKgJJgFlas8xe3fTaV1c4xhlwGGjH2Xf3MS2heKjdtaJX0BvIVduzSHSpMQvFCs3MJUyFqqMJoDqadhDikbcJfxYbhBT6IYftuAC0HJV6w04eD0bjwo(o6erCno5XVb)OKKMbtw6ynaCp00qqD1TycJPHQuT6JDXeLghD44RUfnorhDqILJVJorexlgvgDpihd3Ab8Rd2XSVqKgJJgFlaIj5aegXYLvqvG3Ab8RJflqWKq74IBtw7dcYKHjGXy6TkX3bQm2q2ht1QpoPBZrxSpiiZrNoiGHJoePBimwCjhCS1QlkxmrPXrho(QBrJt0rhKy547OJlUgN843GFussZGjlDSgaUhAAiOU6wmHX0qvQw9XUyIsJJoC8v3IgNOJoiXYX3rhxCTyXy2xisJXl2a]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170409.204707, [[d8cjcaGEkv1UeH2gLcZMk3uuDBuTtPSxYUvz)svnmk53cdLsrdgIA4q6GqvhdfNJsLwOiAPIslgHLtvpuK6PGLjvwhLsnvOYKHY0LCrKQlR8CuA7qKhJOdRQPrPkFxeCEKYIefJwQYNrItcbFtKCAkUhLs(le61iPNrPIfJWjG(9eUHPKcApFcadpDFKP7gFx9oB3hzu)idoXxcYo3E2PwNftkl7zz3ezeaOJ08oJ9)YeNAD2OtaEYYehRWPgJWjG(9eUHPKcasVbTeubfkULiAuM4yfGNW4mfnbOrzItachMH8RWl4IBcApFcSzuM4eG3tHvW98zRmO(WfhLHHiAKW8zeKDU9StTolMumwcs3BKuZdKgFxjcb5bw75tqguF4IJYWqensy(mQuRt4eq)Ec3WusbTNpb4IA8(iN)S180eKDU9StTolMumwcWtyCMIMGkQXrK)S180eGWHzi)k8cU4MG09gj18aPX3vIqqEG1E(eOsn7iCcOFpHBykPG2ZNaOcpN6g68cYo3E2PwNftkglb4jmotrtaBfEo1n05fGWHzi)k8cU4MG09gj18aPX3vIqqEG1E(eOsLaG0BqlbQKa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170409.204707, [[d0tYoaGEePQ2Kiv7cu2gIu2NOuZKqQzt08jP0nbQVjQCBk(mLSti2R0UvA)ukJsuvddiJJqIhtQ7rs1GPkgUiCqrXPev5yq6CesAHKWsrelgHLtLhkIEkQLrPADisLonutLQ0Kbz6cxuK8kePkptKIRtO2OOeEoGnJO2ojAEKumlePIPjkrFhrYHePu)LQA0eCyfNKqCCrjDnrk58KKlR61GQFJ0fTElNAhc5HQIYiJ5LzSjPnpPK38ngjPRnpa41sEBEKUYKC5hGxe7GqZbklbjQWqlZjUgpsmP)ey6we7KM9Yz0bMUa1BrqR3YP2HqEOQOmYyE5SqoMBZdlq1WlZAhoruoTdSgoETuRAHObmYYXCFabQgom3ndEbuJ6wAOYjfUgoyQYB(gLOmjx(b4fXoi0COGklYcH1tqDLx6(YziWsCOQmz5yUpGavdVmykeYyE5gfXE9wo1oeYdvfLrgZlNACHqwfpWFzw7WjIYeIjtg21c0d4tj7hc33Y9j8beVq3HxlyItKUzUeiCudmTyN7BKT6IcPvoPW1WbtvEZ3OeLj5YpaVi2bHMdfuzrwiSEcQR8s3xodbwIdvL)4cHSkEG)YGPqiJ5LBuK0uVLtTdH8qvrzKX8YPgxiyZdlq1WlZAhoru2mxceoQbMwSZ9nYwDu0CQvTP94cm5rhWai1Ls8A5BMlbch1a77qipu6M5sGWrnW0IDUVr2QlQ2lNu4A4GPkV5BuIYKC5hGxe7GqZHcQSilewpb1vEP7lNHalXHQYFCHGpGavdVmykeYyE5gfjlR3YP2HqEOQOmYyEzoOod8)e3vM1oCIO8OdSY7)9g8butAkNu4A4GPkV5BuIYKC5hGxe7GqZHcQSilewpb1vEP7lNHalXHQYab1zG)N4UYGPqiJ5LBuK0QElNAhc5HQIYiJ5LtjV5BmsBEuihGOmjx(b4fXoi0COGkNHalXHQYxEZ3yK(eYbiklYcH1tqDLx6(YjfUgoyQYB(gLOmykeYyE5gfH0Q3YP2HqEOQOmYyEzrJZQymKnpGhlZyZJxACtzw7WjIYJoWkV)3BWhqnPPCsHRHdMQ8MVrjktYLFaErSdcnhkOYISqy9eux5LUVCgcSehQklXzvmgY3mwMXpOXnLbtHqgZl3Oi5Q3YP2HqEOQOmYyEzrpkhBEui2beLzTdNikdrdyKLJ5(acunCyUBg8cKTEac)aBE6Akvcrj167(OJYjfUgoyQYB(gLOmjx(b4fXoi0COGklYcH1tqDLx6(YziWsCOQSCuo(eIDarzWuiKX8YnkIOuVLtTdH8qvrzw7WjIYM5sGWrnW0IDUVr2QBhu6eIjtg2L38ngPpzQwmamXjs3DYUdimeYxodbwIdvLjlhZ9beOA4LfzHW6jOUYlDFzKX8YzHCm3MhwGQHBZt(O5voJZcOSwLwE)yCwpauhTmjx(b4fXoi0COGkNuLwEVJZ6bqvuoPW1WbtvEZ3OeLbtHqgZl3OiIA9wo1oeYdvfLrgZlNACHGnpSavd3MN8rZRmRD4erzZCjq4OgyAXo33iB1rrrvRAt7XfyYJoGbqQlL41Y3mxceoQb23HqEO0nZLaHJAGPf7CFJSvxuiTYjfUgoyQYB(gLOmjx(b4fXoi0COGklYcH1tqDLx6(YziWsCOQ8hxi4diq1WldMcHmMxUrrqbvVLtTdH8qvrzKX8YEPXn28aEaI7uvM1oCIOmHyYKH5oaDNvF)Gg3aZDZGxa1GcsTQnFcXKjdZDa6oR((bnUbM7MbVaQjFcXKjdBa0FHMvFyqIDtGPlPNMsLqusTWga9xOz1hM7MbVa5LUMsLqusTWga9xOz1hM7MbVaQbnTYRCsHRHdMQ8MVrjktYLFaErSdcnhkOYISqy9eux5LUVCgcSehQkh04gFZae3PQmykeYyE5gfbfTElNAhc5HQIYiJ5LtnUqiRIh43MN8rZRmRD4erzcXKjd7Ab6b8PK9dH7B5(e(aIxO7WRfmXjkNu4A4GPkV5BuIYKC5hGxe7GqZHcQSilewpb1vEP7lNHalXHQYFCHqwfpWFzWuiKX8YnkcQ96TCQDiKhQkkZAhoruMqmzYWsqj1D(uY(HW9nZLaHJAGjor6JoWkV)3BWhqnPjDOtiMmzysSLqS41Y3rHGbrj1wodbwIdvLLylHyXRLpbvgLfzHW6jOUYlDFzKX8YIgBjelETS5rbvgLZ4SakRvPL3pgN1da1rltYLFaErSdcnhkOYjvPL374SEaufLtkCnCWuL38nkrzWuiKX8YnkcAAQ3YP2HqEOQOmYyEzrJTeIfVw28OGkdBEYhnVYS2HteLjetMmSeusDNpLSFiCFZCjq4OgyItK(OdSY7)9g8butAkNu4A4GPkV5BuIYKC5hGxe7GqZHcQSilewpb1vEP7lNHalXHQYsSLqS41YNGkJYGPqiJ5LBue0SSElNAhc5HQIYS2HteLhDGvE)V3Gpq2OPp6aR8(FVbFGSrth6eIjtgMeBjelET8DuiyqusTLZqGL4qvzTWGxFj2siw8AvwKfcRNG6kV09LrgZlNuyWRnpIgBjelETkNXzbuwRslVFmoRhaQJwMKl)a8IyheAouqLtQslV3Xz9aOkkNu4A4GPkV5BuIYGPqiJ5LBue00QElNAhc5HQIYiJ5Ltkm41MhrJTeIfVw28KpAELzTdNikp6aR8(FVbFGSrtF0bw59)Ed(azJwoPW1WbtvEZ3OeLj5YpaVi2bHMdfuzrwiSEcQR8s3xodbwIdvL1cdE9LylHyXRvzWuiKX8YnkckPvVLtTdH8qvrzw7WjIYqNqmzYWKylHyXRLVJcbdIsQTCgcSehQklXwcXIxlFcQmklYcH1tqDLx6(YiJ5Lfn2siw8AzZJcQmS5jF75voJZcOSwLwE)yCwpauhTmjx(b4fXoi0COGkNuLwEVJZ6bqvuoPW1WbtvEZ3OeLbtHqgZl3OiO5Q3YP2HqEOQOmYyEzrJTeIfVw28OGkdBEYpn5vMKl)a8IyheAouqLZqGL4qvzj2siw8A5tqLrzrwiSEcQR8s3xoPW1WbtvEZ3OeLbtHqgZl3OiOIs9wo1oeYdvfLzTdNik7oz3begc5lNHalXHQYKLJ5(acun8YISqy9eux5LUVmyQs8Ave0YiJ5LZc5yUnpSavd3MN8TNx5molGYgQs8APokPJwLwE)yCwpauhTmjx(b4fXoi0COGkNuLwEVJZ6bqvuoPW1WbtvEZ3OkkdMcHmMxUrrqf16TCQDiKhQkkNHalXHQYFCHGpGavdVSilewpb1vEP7ldMQeVwfbTmYyE5uJleS5HfOA428KV98kNXzbu2qvIxl1rltYLFaErSdcnhkOYjfUgoyQYB(gvrzWuiKX8YnAuM1oCIOCJwa]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170409.204707, [[d4tqpaGEukL2eGyxG02qPK9bOAMsLQVrv1SPy(uPYnb4Xu62K6Wk2jq7vSBi7Nkzuasdtkghkv6EuPCAunyQOHtihKQYPauogOohkvSqQWsbrlgflNKhkvSkukvlJOSoukutJkvzQuLMmbtxYfPkEfkLINjvkxxjTrPsCzvBwj2oH6qOuWSqPq(mk57Ou0ZvQ)kvnAImpuQ6KGWXLkPRrLQ68evpf53q9AP0boEd5bnmMlehHah9drCDhxo9yU(OAmSXUCU5iwM7YjFjeK38z)akRb2FJ71WoqHdrIULpgoB7uCmkGYylzH8zlogTJ3achVH8GggZfIJqGJ(H6Iz03LtscBBdrwfxufInuCBlhXYDUtaxqxmJ(9BjSTfQ66HJ2S3nwwHqDKUTfaw81hvHjeK38z)akRb2pCtiiqcC7uyvieg9q(y4gEjp0Iz0VFlHTTHaGfah9dLkGYI3qEqdJ5cXriWr)qEgvj111P9HiRIlQcXSUSa9wj8394L(s69SuFQ(9ks4koIf0vrarp3Slfwd1UQuhva3n2LTc1r62wayXxFufMqqEZN9dOSgy)WnHGajWTtHvHqy0d5JHB4L8qFuLuxxN2hcawaC0puQa2T4nKh0WyUqCecC0puxu4D5YjjHTTHiRIlQcXSUSaLB)YQso0vrarp3Slfwd1UQuhva3nyy4qDKUTfaw81hvHjeK38z)akRb2pCtiiqcC7uyvieg9q(y4gEjp0IcVR(Te22gcawaC0puQa6EXBipOHXCH4ie4OFipJQKC5KKW22qKvXfvH0Zn7sH1qTRk1rfWDdg2V7ChByufFzSf0nBEJHJy1RNB2LcRHE0WyUaq0Zn7sH1qTRk1rfWDJDKfQJ0TTaWIV(OkmHG8Mp7hqznW(HBcbbsGBNcRcHWOhYhd3Wl5H(OkP(Te22gcawaC0puQa6(XBipOHXCH4ie4OFiQWkD7VORcrwfxufASfx87p6A(3SVBH6iDBlaS4RpQctiiV5Z(buwdSF4MqqGe42PWQqim6H8XWn8sEODHv62FrxfcawaC0puQaYwXBipOHXCH4ie4OFipMRpQgJlNomZUcb5nF2pGYAG9d3eYhd3Wl5HU56JQX0ZyMDfccKa3ofwfcHrpuhPBBbGfF9rvycbalao6hkva9hVH8GggZfIJqGJ(HGW(LvL8qKvXfvH0Zn7sH1qTRk1rf7DdUbouhPBBbGfF9rvycb5nF2pGYAG9d3eccKa3ofwfcHrpKpgUHxYdXTFzvjpeaSa4OFOubKDJ3qEqdJ5cXriWr)qDN31vUGlNagw6XLtV466qKvXfvHgBXf)(JUM)n77wOos32cal(6JQWecYB(SFaL1a7hUjeeibUDkSkecJEiFmCdVKhYW76kxOxpS0tFHRRdbalao6hkvazN4nKh0WyUqCecC0pu35SKkehXYLthytfISkUOkeZ6Ycury28QE8sFj9E9CZUuyn0vraHzDzb6UWkD7VORGUkciJT4IF)rxZ)M9DluhPBBbGfF9rvycb5nF2pGYAG9d3eccKa3ofwfcHrpKpgUHxYdz4SKkehXQNbBQqaWcGJ(Hsfq4M4nKh0WyUqCecC0pu3hXJlNowv7kezvCrvibCbDXm63VLW2wOQRhoAdC7SR(IRpqSySraZMOE1hBfQJ0TTaWIV(OkmHG8Mp7hqznW(HBcbbsGBNcRcHWOhYhd3Wl5HmJ4PNzvTRqaWcGJ(Hsfqy44nKh0WyUqCecC0puxu4D5YjjHTTUCcuyGfISkUOkeZ6YcuU9lRk5qxfbeGQNB2LcRHAxvQJkG7MSg35oM1LfOC7xwvYHQUE4On7bkmu3NTVfDJPxA21z7mRllq52VSQKdDxJTLTbgyaluhPBBbGfF9rvycb5nF2pGYAG9d3eccKa3ofwfcHrpKpgUHxYdTOW7QFlHTTHaGfah9dLkGWYI3qEqdJ5cXriYQ4IQq65MDPWAO2vL6Oc4UjRbimRllqV56JQX0VGTRBORIaI6lQVLggZd5JHB4L8qlMr)(Te22gccKa3ofwfcHrpe4OFOUyg9D5KKW2wxobkmWc5tXAhYk3AEFnkwV2UbhcYB(SFaL1a7hUjuh5wZ9okwV2XrOos32cal(6JQWecawaC0puQac3T4nKh0WyUqCeISkUOkeZ6YcuU9lRk5qxffYhd3Wl5Hwu4D1VLW22qqGe42PWQqim6HaGfZrSciCiWr)qDrH3LlNKe226YjqLbSq(uS2H0yXCel3Gdb5nF2pGYAG9d3eQJ0TTaWIV(Okocbalao6hkvaHDV4nKh0WyUqCecC0pKNrvsUCssyBRlNafgyHiRIlQcPNB2LcRHAxvQJkG7gmmS7ChByufFzSf0nBEJHJy1RNB2LcRHE0WyUaq0Zn7sH1qTRk1rfWDJDzRqDKUTfaw81hvHjeK38z)akRb2pCtiiqcC7uyvieg9q(y4gEjp0hvj1VLW22qaWcGJ(Hsfqy3pEd5bnmMlehHah9d5fxx7YjGzxxjpezvCrviM1LfOQVXObzFFHRRHQUE4On7HBc1r62wayXxFufMqqEZN9dOSgy)WnHGajWTtHvHqy0d5JHB4L8qfUUUxp76k5HaGfah9dLkGWSv8gYdAymxiocbo6hYZOkPUUoT3LtGcdSqKvXfvHywxwGERe(7E8sFj9EwQpv)EfjCfhXc6QOqDKUTfaw81hvHjeK38z)akRb2pCtiiqcC7uyvieg9q(y4gEjp0hvj111P9HaGfah9dLkGW(J3qEqdJ5cXriWr)qDNZsQqCelxoDGnLlNafgyHiRIlQcXSUSaveMnVQhV0xsVxp3SlfwdDveqgBXf)(JUM)n77wOos32cal(6JQWecYB(SFaL1a7hUjeeibUDkSkecJEiFmCdVKhYWzjvioIvpd2uHaGfah9dLkGWSB8gYdAymxiocbo6hQJ0WrUC2DolPcXrScrwfxufASfx87p6A(3ahgiJT4IF)rxZ)g4WH6iDBlaS4RpQctiiV5Z(buwdSF4MqqGe42PWQqim6H8XWn8sEiR0Wr9golPcXrScbalao6hkvaHzN4nKh0WyUqCecC0pu35SKkehXYLthyt5YjqLbSqqEZN9dOSgy)WnH8XWn8sEidNLuH4iw9mytfccKa3ofwfcHrpuhPBBbGfF9rvycbalao6hkvaL1eVH8GggZfIJqKvXfvHuFr9T0WyEiFmCdVKhAXm63VLW22qqGe42PWQqim6HaGfZrSciCiWr)qDXm67YjjHTTUCcuzalKpfRDinwmhXYny2iRCR591Oy9A7gCiiV5Z(buwdSF4MqDKBn37Oy9AhhH6iDBlaS4RpQIJqaWcGJ(HsfqzWXBipOHXCH4iKpgUHxYd9rvs9BjSTneeibUDkSkecJEiayXCeRachcC0pKNrvsUCssyBRlNavgWc5tXAhsJfZrSCdoeK38z)akRb2pCtOos32cal(6JQ4ieaSa4OFOuPcrwfxufkvca]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170409.204707, [[d0JmiaGEIuQnjjAxIITrKk7JivntqKzJQ5tIOBQGNJWTj13KK2PI2l1ULA)Iu)eevnmr14isrpwIZlsgSO0WreheL6uGOCmuCCsuTqe1svOwmOwoqpKO8uOLreRJiLCAKMkjmzatxPlsu9AuYLvDDfYgjr4VG0Mjs2UK6WcZIifMgIK5jj4zGOYNfXOjPVtIuNeeoejkUgjsUhIuNJeL(nHrjj0MXkmkVdy(bmzJZqFJivllDw58RFVbxALolBiVCJJp)bX9usot1CsLRSzymIK8cn4uPDSur7PePtIr2LLkAcRWtgRWO8oG5hWKnod9nIRauZ6NKdAC85piUNsYzQYKBKnmLt3ugjwbOM1pjh0ienaTeRa0yl6BuM6lSge1x)EnSXbbWm03OxpLyfgL3bm)aMSXzOVr2eL3arxUrSasjznUIKe(ZuecoGqPBcJYuFH1GO(63RHno(8he3tj5mvzYncrdqlXkan2I(gzdt50nLXGO8gi6YnoiaMH(g96jKZkmkVdy(bmzJZqFJqIQ8ruG0zhIeDKoRcXETXXN)G4EkjNPktUr2WuoDtzKtv(ikauDKOdORyV2ienaTeRa0yl6BuM6lSge1x)EnSXbbWm03OxpjLvyuEhW8dyYgNH(gvcEOF6SOQOWYiwaPKSgbVuGNqnG5VYOS06d9910tubsvPooNybf6mLrGGVxPN0sYnkt9fwdI6RFVg244ZFqCpLKZuLj3ienaTeRa0yl6BKnmLt3ugLIh6dLqvuyzCqamd9n61tLYkmkVdy(bmzJZqFJYdWvv5Jcw344ZFqCpLKZuLj3iBykNUPm(aCvv(OG1ncrdqlXkan2I(gLP(cRbr91VxdBCqamd9n61tPZkmkVdy(bmzJZqFJqkQJ0zjpcKynIfqkjRraXMrkEOpucvrHvgWRdAti9LGyHUu9ReEKusLHh1buIrGjpZisQuz2G)EZWPjQBt7eOGcGmVdy(bQmklT(qFFn9evGugLP(cRbr91VxdBC85piUNsYzQYKBeIgGwIvaASf9nYgMYPBkJ8OoGcpcKynoiaMH(g96zvRWO8oG5hWKnod9nkNF97n4PZsMheRrSasjznQmBWFVz40e1TPDcuqbqM3bm)avgLLwFOVVMEIkOukPsUb)9MHttu3M2jqbfazEhW8duzuwA9H((A6jQaPmkt9fwdI6RFVg244ZFqCpLKZuLj3ienaTeRa0yl6BKnmLt3ugp)63BWHcZdI14Gayg6B0RNstRWO8oG5hWKnod9ncPOosNL8dTXXN)G4EkjNPktUr2WuoDtzKh1bu4hAJq0a0sScqJTOVrzQVWAquF971WgheaZqFJE9uzTcJY7aMFat2iwaPKSgbo8iPKkdNMOUnTtGckaYaiu62iBykNUPmwudAdLttu3M2jgHObOLyfGgBrFJZqFJYudANolKOjQBt7eJSbtimwsv4h6gGjFjinJXXN)G4EkjNPktUrzPk8Riat(syYgLP(cRbr91VxdBCqamd9n61tMCRWO8oG5hWKnod9nktnOD6SqIMOUnTtsNTImqMXXN)G4EkjNPktUr2WuoDtzSOg0gkNMOUnTtmcrdqlXkan2I(gLP(cRbr91VxdBCqamd9n61tggRWO8oG5hWKnYgMYPBkJ8OoGcpcKyncrdqlXkan2I(ghe10oXtgJZqFJqkQJ0zjpcKytNTImqMr2Gjeg1IAANqAgJJp)bX9usotvMCJYuFH1GO(63RjBCqamd9n61tgjwHr5DaZpGjBelGuswJGxkWtOgW8BKnmLt3ugLIh6dLqvuyzeIgGwIvaASf9noiQPDINmgNH(gvcEOF6SOQOWkD2kYazgzdMqyulQPDcPzKgLuf(HUbyYxcsZyC85piUNsYzQYKBuwQc)kcWKVeMSrzQVWAquF971KnoiaMH(g961iwaPKSg9Ad]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170409.204707, [[d0ZUpaGEiOQnrOSlQ02GGSpQiZKQknBkMpe4Mq0Tj5BQu(mIANiSxLDl1(PknkvedtLmocv1Jj6EurnyQkdNuCqvuNIQQogbhxfPwivyPqOfdPLtPhQs1trTmsP1PIeDAKMQO0KvvtxYfPkELks4zuvX1vHnsOspxKnRk2oH8DeHzbbvMMksAEiIETQ0HfgnP6qeQ4KisxgCniOCErXFfvNJqv(nupHLDSNoqnWFogtekymtv396ZJbuqxH5u61xI2KnGxFrsogrWarcgH2lHBxN6L45kmM1asAyOi8rrX9i0IqAhFwwuCNw2riSSJ90bQb(ZXyIqbJpNKq)JwcJzPLQPgxyYKnGReJnFmj6KyN8XL7JjuqEshlFDTGkODYj0JNh3ijH(hTeC)h2OO4wStkQcCYze6cbia945Xf1GXFZrQCp04Vysm28XKODnHOih9WMkxlOcANC6smXb945XnvyR6fanG19qJ)JVRdYxKyrGc6AOJremqKGrO9s4MW1ys7pvgf2oUXnm(mk1qRmJJKe6F0syms8NiuW4vJq7Yo2thOg4phJjcfmwCnHc86J1XY3XS0s1uJfNIkFPnzeGGpUCFmHcYt6y5RRfubTtK0zYY)476G8fjweOGUg6yebdejyeAVeUjCnM0(tLrHTJBCdJpJsn0kZ4htOG8Kow(ogj(teky8Qr4NLDSNoqnWFogtekyS4Acf41hRJLVE9DIG)JzPLQPgRcWKklw5kpSwOlNCw7Lywqf0orsNrpEECJKe6F0sW9FyJIIBXKyS5Jjr7gjj0)OLGRfubTtNc0JNh3ijH(hTeC)h2OO4MKo)pSrrX9476G8fjweOGUg6yebdejyeAVeUjCnM0(tLrHTJBCdJpJsn0kZ4htOG8Kow(ogj(teky8QrCQl7ypDGAG)CmMiuWypHT0p9r8cJzPLQPgJE884csDmKYXp5LoKt2crLNo6pyPnz3dnIjoOhppUrsc9pAj4EOrmvaMuzXkx5H1cD5KZIpcn(UoiFrIfbkORHogrWarcgH2lHBcxJjT)uzuy74g3W4ZOudTYmgcBPF6J4fgJe)jcfmE1iqyl7ypDGAG)CmMiuWypHT096J1XY3XS0s1uJvbysLfRCLhwl0LtoliCdbiqCcBrFcz5Mibym0MCUkatQSyLl0bQb(IPcWKklw5kpSwOlNCw80o(UoiFrIfbkORHogrWarcgH2lHBcxJjT)uzuy74g3W4ZOudTYmgcBPNN0XY3XiXFIqbJxnceAzh7Pdud8NJXeHcgZf2QEbqdyhZslvtnoKfveKdnOOqIK(z8DDq(IelcuqxdDmIGbIemcTxc3eUgtA)PYOW2XnUHXNrPgALzCQWw1laAa7yK4prOGXRgXTLDSNoqnWFogtekyShdOGUcJxFomrQgJiyGibJq7LWnHRXNrPgALzmyaf0vyYrnrQgtA)PYOW2XnUHX31b5lsSiqbDn0XiXFIqbJxncXFzh7Pdud8NJXeHcg7x6PpOFV(qgKvHxFzXfOgZslvtnoKfveKdnOOqIK(z8DDq(IelcuqxdDmIGbIemcTxc3eUgtA)PYOW2XnUHXNrPgALzSHE6d6pxfKvrEHlqngj(teky8QriEl7ypDGAG)CmMiuWy)sjRxnTj71NdSPgZslvtng945XvdMeGnh)Kx6qUkatQSyL7HgXqpEECtf2QEbqdyDp0iwilQiihAqrHej9Z476G8fjweOGUg6yebdejyeAVeUjCnM0(tLrHTJBCdJpJsn0kZydLSE10MCok2uJrI)eHcgVAecxl7ypDGAG)CmMiuWy)gIcV(CCyt1ywAPAQXFC5(ycfKN0XYxxlOcANCsgPkVOkqStKyS5JjrNBHqwiabOhppUrsc9pAj4EOX)X31b5lsSiqbDn0XicgisWi0EjCt4AmP9NkJcBh34ggFgLAOvMXMquKJEyt1yK4prOGXRgHGWYo2thOg4phJzPLQPgBHhlK0dudiMkatQSyLR8WAHUCYzTxIHE884cgqbDfM8hS8i5EOz8zuQHwzg)ycfKN0XY3XK2FQmkSDCJBymrOGXIRjuGxFSow(613jA9F8zl50yzgPbYRWsgQKZcJremqKGrO9s4MW147zKgiByjdvAogFxhKViXIaf01qhJe)jcfmE1ie0USJ90bQb(ZXyIqbJ9e2s3RpwhlF967eb)hZslvtnwfGjvwSYvEyTqxo5SGGacqG4e2I(eYYnrcWyOn5CvaMuzXkxOdud8ftfGjvwSYvEyTqxo5S4JqJVRdYxKyrGc6AOJremqKGrO9s4MW1ys7pvgf2oUXnm(mk1qRmJHWw65jDS8Dms8NiuW4vJqWpl7ypDGAG)CmMiuW4S4cuE9HmsfyZmMLwQMAm6XZJRfs4oAjKx4cuUwqf0orsHleGGtqpEECTqc3rlH8cxGY1cQG2jsEc6XZJBKKq)JwcU)dBuuCFkKyS5Jjr7gjj0)OLGRfubTt(lMeJnFmjA3ijH(hTeCTGkODIKcim)hFxhKViXIaf01qhJiyGibJq7LWnHRXK2FQmkSDCJBy8zuQHwzgx4cu5QivGnZyK4prOGXRgHWPUSJ90bQb(ZXyIqbJ9e2s)0hXl413jc(pMLwQMAm6XZJli1Xqkh)Kx6qozlevE6O)GL2KDp0m(UoiFrIfbkORHogrWarcgH2lHBcxJjT)uzuy74g3W4ZOudTYmgcBPF6J4fgJe)jcfmE1ieqyl7ypDGAG)CmMiuWy)gIcV(CaHAmlTun14qwurqo0GIcjNeelKfveKdnOOqYjHX31b5lsSiqbDn0XicgisWi0EjCt4AmP9NkJcBh34ggFgLAOvMXMquKJcHAms8NiuW4vJqaHw2XE6a1a)5ymrOGX(LswVAAt2Rphyt513jc(pMLwQMAm6XZJRgmjaBo(jV0HCvaMuzXk3dnIfYIkcYHguuirs)m(UoiFrIfbkORHogrWarcgH2lHBcxJjT)uzuy74g3W4ZOudTYm2qjRxnTjNJIn1yK4prOGXRgHWTLDSNoqnWFogteky8D9G2E95xkz9QPn5XS0s1uJdzrfb5qdkkKCsqSqwurqo0GIcjNegFxhKViXIaf01qhJiyGibJq7LWnHRXK2FQmkSDCJBy8zuQHwzgl1dANBOK1RM2KhJe)jcfmE1iee)LDSNoqnWFogtekySFPK1RM2K96Zb2uE9DIw)hJiyGibJq7LWnHRXNrPgALzSHswVAAtohfBQXK2FQmkSDCJBy8DDq(IelcuqxdDms8NiuW4vJqq8w2XE6a1a)5ymlTun1yl8yHKEGAGXNrPgALz8JjuqEshlFhtA)PYOW2XnUHXiXIOn5rimMiuWyX1ekWRpwhlF967e)4)4ZwYPXkSiAt2zbeozgPbYRWsgQKZcJremqKGrO9s4MW147zKgiByjdvAogFxhKViXIaf01Cmgj(teky8QrO9Azh7Pdud8NJXNrPgALzme2sppPJLVJjT)uzuy74g3WyKyr0M8iegtekySNWw6E9X6y5RxFNO1)XNTKtJvyr0MSZcJremqKGrO9s4MW1476G8fjweOGUMJXiXFIqbJxTAmlTun14vBa]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170409.204707, [[d8tQiaWyiwpK0lPqSlvvHxRQs)gPzkeMgfQzRkNxOUjQkDAcFdvfogfTtrTxPDd1(vu)esnmsmoss6Yknuk1GvKHJshuHoQQQOdt15qvrTqfSuIOflOLtQhsuEkyzevpxKjQQknvenzI00v5IcCvkKEgr46OyJcPTsscBMs2of8rvvSniHpJQ8DvLrssQ1PQQgnQmEuvDssQBbj6Acr3JKeDBewlQkYXjjUMLSaIZEckokfFWf)2cOnkzeQZbfqC2tqXrP4deOUnBkVG2X8wzClYVDOq4tGkQ)8OFnSqmAlR0EYC2tqXPMvkWpAlR0EYC2tqXPMvkOcZYSsvJqXGa1TzJvkqiWJbnlrbvywMvQmN9euCQdfIrBzL2J0182l1SsH)Kzz2ujB2SKfcWE4BL2HcJiNGINNIqKUcGGq28uaMZXilXIV)NNy1lcLi0VczNylacczZtbyohJSel((FEIvViuIq)ki5(wpTnlxXefMkksuaq0c2RWjiwvPsVMLxYcbyp8Ts7qHrKtqXZtrisxbqqiBEkaZ5yKLyX3)ZtsxlN5DfYoXwaeeYMNcWCogzjw89)8K01YzExbj336PTz5kMOWurrIE9kK4OFWN4q4gd6qb(rBzL2J0182l1SsbcNFGSzZcNR5T3igHJQlmGMKenFLu9pQMSa)OTSs7zKHuZMfSO4RWOw4V5PSR10Vcjo6hPR5TxQdf(nCeJWr1firBlP6FunzbbwQaXpQEeJWr1fKu9pQMSaIZEckEeJWr1fgqtsIMVfKrzJNNiPfcWCogzjw8npbcmV3IssxZBVcjo6hq2HcQWSm7Ff6f5euCbjv)JQjlGziuJqXPMnUqmAlR0EQXsfi(r1PMvkK4OFYC2tqXPouGF0wwP9gz0EZkfKUwoZ7gTJOaiiKnpfG5CmYsS47)5jPRLZ8UccekMprPenBgzbcN)rMJ2SsHWNavu)5r)gFVgwWFSCoWr)Sne0Szb)XY5YOeH(zBiOzZcec8iZrBwPWVHrP4dU43waTrjJqDoOG)(84KTb7ouWGijcfpXftgZUfclG4SNGIhFcE4cYcYKbswqQiX(8yYy2TGxWFSC(47ZJt2gcA2SG2X8wYy2TGhkEIlUGZOD(kWBhkK4OFJmAxn2I2Hc)ggLIpqG62SP8cQWiq(fU43wWl4pwoN0182Z2GDZMfCgTpIr4O6cdOjjrZ3icIswqVVcYcYKbswiXUVx0NN4Ayb)XY5KUM3E2gcA2SqIJ(bFIdHBK5ODOGkmlZkvnwQaXpQo1HcoJ2vJTOKXSBHqglRcXnkkvvf(SCJvqHPjFiHIC58HsTqPXrw4CnV9IsXhCXVTaAJsgH6Cqb(68liyiMNifeBZsOuigTLvApJmKAgLYlaiAb7vOG)y58X3NhNSny3SzbekrOF2gcAybwTGW1XrP4deOUnBkVaRErOeH(nAhrbqqiBEkaZ5yKLyX3)ZtS6fHse6xbGDre(tGQFckUz5OqIceo)JbnRuG0Fl(MN(rtzyBwPW5AE7zBiOHfsS77f95joz0hvxYcEZMfcB2SaVMnlOB2SxHeh9Z2GDhkeJ2YkT3iJ2BwPWFxlN5DDOq2j2cbyohJSel(MNS1ccxhxWz0oWUVN6)2SCftv14ilCUM3ErP4RGn58e4408u21A6xHeh9tnwQaXpQo1Hc)ggLIVc2KZtGJtZtzxRPFf83NhNSne0Hcjo6NTHGouiXr)gd6qbekrOF2gSBybNr7KXSBHqglRc2AbHRJNNK5SNGINNgz0Eb4OAIqTaZB1fsC0VrMJ2Hcecmq2SsHZ182lkfFGa1Tzt5fuHrG8RQqKGl(Tf8cio7jO4Ou8vWMCEcCCAEk7An9RG)y5CzuIq)Sny3SzHaSh(wPDOqsqW(2r0bnlrb(rBzL2tnwQaXpQo1Ssbj336PTz5kM8HIXkY)dt5sOySefsC0pJSXHcSubMxQdfS1ccxhppjZzpbfxiP9tqlCUM3E2gSBybbcfdSoIaZR5ilOcZYSJpbpmXIVcify1ccxhRgHIbbQBZgRuWFSCoWr)Sny3SzbvywMvAuk(abQBZMYlWFZOef)HPIerAgjkKh5IsfLilOcZYSsnYqQdfsC0p4tCiCJOd6qbNr7gflUcSppE19Ab]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170409.204707, [[d8ZBiaqyQwpa9ssO2LQk8Avv53intsPEgaMTIoVu1nrvLtt4BsOYZL0oLYEf7g0(vOFcOHrjJdvvLTrkPHsPgScgoIoOeDuuvvDmvX5iHyHQklLeSyIA5u8qI4PqpgO1PQstuvfnvuAYePPRYfjPRskXLv66OyJsfBvcvTzs12jrFuQKpJQmnPs9DvPrkHYYKGrJkJhvLtskUfjKUMQQ6EOQkUncRfvvPJlHCEcBqqN8euyhk8WRFUbbQfwT10udEUH3E2kTJCqJd5Ts4wW)Yxq5Paqa7AsFJCWEG6619K4KNGcRPzfKpG6619K4KNGcRPzfSiMLzLQbKcrbGBADBfKqalvtdGGfXSmRujo5jOWA(c2duxVUhRB4TxnnRG8FMLzRHnTNWguf6YZvA(cwcEckCCqBr9cIccjJdQqohcUel8(DCG0SGucz)c2CInikiKmoOc5Ci4sSW73XbsZcsjK9lOc7C96MwbRN)T06pku4jicAeKxWtqS8hRCPviSbvHU8CLMVGLGNGchh0wuVGOGqY4GkKZHGlXcVFhhKU6oZ8c2CInikiKmoOc5Ci4sSW73XbPRUZmVGkSZ1RBAfSE(3sR)OqHNC5cw5OV4R4a5kvJCWkh9TK5OroOaKcrshua5L2)bp3WBVsiih1e8dillq(PGMUkgBq(aQRx3tXF10ScQtHxWsJWNJdn3yOVbRC0xw3WBVA(c(NCjeKJAcYc0wbnDvm2GcOubOFutjeKJAcQGMUkgBqqN8euyjeKJAc(bKLfi)cIKlOWNca9tqHPvqRaeSYrFr28fSiMLz)PWSGNGcdQGMUkgBqidHgqkSMw3bRK7C2z6voj0j1e2GEApbLt7jiV0EcAs7jxWkh9vItEckSMVG8buxVUxjJXtZkO0v3zMxPT2brbHKXbviNdbxIfE)ooiD1DM5fKW5RK5OPzfuEkaeWUM03Y5mYb9jjNJC0xBLQP9e0NKCUekHSF2kvt7j4pxDNzE5lOpF9(QTs78fuPOkKftX1Z2tUbLdc6KNGclNcEWGsuBSQkeuQOso9E2EYniyqcbSK5OPbqqJd5TS9KBqxwmfxFqNX48ta38fSiMLzlNcEqIfEbbd(NChk8qbGBApfc6mgxduNY2tUbLz01d6tsoN1n82ZwPDApbRC03sgJRbQtJCqZodkrTXQQqWk5oNDMELlYb9jjNZ6gE7zRunTNG8buxVUhRB4TxnnRGfXSmRunqPcq)OMA(c6mgVecYrnb)aYYcKFAR2HnyF6OOA9Flf5XsraO4aaaRU5FayfDfT7)dEUH3EDOWdV(5geOwy1wttni)C(eemeJdScInnaScYxAwbrqJG8cwfqEZnOpj58Y5R3xTvAN2tqqkHSF2kvJCqsJGWn9DOWdfaUP9uiiPzbPeY(vARDquqizCqfY5qWLyH3VJdKMfKsi7xqjuY(XbwAqviNdbxIfEJdLavds48vQMMvqwFUWBCOldLHmnRGNB4TNTs1ih02iiCt)4GeN8euyWQXpbnOc7C96MwbRNIZQBRc)4PaawDdqWEG66190aLka9JAQPzfShOUEDVsgJNMvq(aQRx3tduQa0pQPMMvWIyeG)v8IkE9ZnOCqNX4S9KBqzgD9Gvo6RgOubOFutnFbDgJJK7CQ5NPzf0NVEF1wPA(cw5OV2kvZxWkh9TunYbbPeY(zR0oYbTncc30poiXjpbfoouYy8G4rneYgbK3AcEUH3EDOWlOn74a6W64qZng6BWEG6619u8xnnRGeciYMgabp3WBVou4Hca30Eke8p5ou4Hx)CdculSARPPge0jpbf2HcVG2SJdOdRJdn3yOVb9jjNlHsi7NTs70EcQcD55knFbRccY5wcunnac(NChk8cAZooGoSoo0CJH(gS5eBqviNdbxIfEJdLavds48HSPzfSYrFTvANVGvo6RI3EzbuQaYRMVGGo5jOWou4Hca30EkeK0iiCtVgqkefaUP1TvqFsY5LZxVVARunTNG(KKZro6RTs70EcweZYSs7qHhkaCt7PqWkh9fFfhixjZrZxWIywMvQI)Q5lOaKc5VukrAp)h0zmUwGIli507xtUe]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170409.204707, [[d8JyiaqyQwVQQEPeODHsP8AiIFd1mvv5zsiZMKZlvDtisNgvFtvP65sANszVIDty)kQFcHHrQgNeGEmsgkrgSQy4q6Gk0rvvOoMcohkLQfQilfLQflrlNspuQ0tblJOSojGMikftfHjtunDvUikUQeKlR01r0gLk2kkL0MPOTtk9rvf9zuY0uvY3vLgPeuBtvbJMcJhI6KKIBPQuUMQc5EOuIBJuRvcGJlH6meIauo6XXIoyXbxVAdGOqe)00ycCUL1EsALszaRlyTDnwkKKPaftUK7OIZsqVIlavGEeMM1966OhhlQPPhazeMM1966OhhlQPPhOyYLCLRHcla()nTV0dqZfJmPvuGIjxYvExh94yrntb6ryAw3JWTS2RMMEGpMCj3AisBiebyeEPALNPaJuhhlMF(XRxaG538dJAPxX5Q5hj7sHPl9lqZP3aaZV5hg1sVIZvZps2Lctx6xa2x161nnz6dFyqxVOaaLLJEboo9Yw0ZLMSqeGr4LQvEMcmsDCSy(5hVEbaMFZpmQLEfNRMFyZA6KQlqZP3aaZV5hg1sVIZvZpSznDs1fG9vTEDttM(Whg01lkaqz5OxGC5cunWVWl)OmgzYuaKryAw3JWTS2RMMEGQb(fE5hLXi5HZuaN06AeMyIE0nqjPPzaKryAw3RGt10gcyIfxGrl3vZpn3AXVbQg4xc3YAVAMcGKYrbLb2gGaHe7A(SWeb4c5Ck)W2rbLb2gGDnFwyIauo6XXIrbLb2gycbbbcKgaqxkUR4)9JJfPj7dYcunWVarMcum5sUSHBxQJJfbyxZNfMiGGKwdfwut7Rav0vP6O8QrxScBdrapTHaLPneGvAdbSPnKlq1a)21rpowuZuaKryAw3BK06PPhq(A6KQBu6xaGt3D(HrT0R4Cvbo)iFnDs1fG2rEK8WPPhOuX)))tf(DuPszaxHA4Gb(vsltAdbCfQH3ftx6NKwM0gcWM10jvxMcqZfJKhon9aU617RsALYuaT8kVKR4xprp6gOmaLJECSyuXzjc0LPrWWEa58kQY7j6r3aEaofwuaWy60kspG1fSwIE0nGxYv8RpGtADKYfBMcGCA6bqszhS4a()nTbzbQg43rsRRryItzaxHA4eUL1EsALsBiq1a)osE4mfWUQaDzAemShOIUkvhLxnszaxHA4eUL1EsAzsBiGtA9rbLb2gycbbbcK(JPdrGIjxYvUgHCoLFyBntbo3YAVrbLb2gycbbbcKYUMplmrG(05BfqD2USV0)WWW3lsxMSVRhZV91hf4ClR96GfhC9QnaIcr8ttJjasDK50K0ZpeC6nTI0d0JW0SUxbNQP9THaaLLJEbc4kudFu969vjTsPneGctx6NKwMuga1YPDBFhS4a()nTbzbqTlfMU0VrPFbaoD35hg1sVIZvf48dQDPW0L(fOlgTF(HahGrT0R4C18ZicMa0oYJmPPhGWvR4MF(0IjrttpW5ww7jPLjLb6ryAw3tJqoNYpSTMMEGQb(vsRuMc0JW0SU3iP1ttpaYimnR7PriNt5h2wttpask7GfxajI5hWf15NMBT43aoP1j6r3aLKMMbCsRdORsPHnPPhOAGF1iKZP8dBRzkaTJmqK2qax969vjTmzkGKLt72(5NUo6XXI5NrsRhiq1a)kPLjtbOW0L(jPvkLbo3YAVoyXfqIy(bCrD(P5wl(naNclauNIlyL2hfajLDWIdUE1garHi(PPXeGMlaI00dCUL1EDWId4)30gKfOAGFhzYuakh94yrhS4cirm)aUOo)0CRf)gWvOgExmDPFsALsBiaJWlvR8mfOYPrv7icM0KfOysofsyR8kC9QnGhO50Bag1sVIZvZpswoTB7diz50UTF(PRJECSiW5ww7vdunWVfC7l5c5CbRAMcq5Ohhl6GfhW)VPnila7RA96MMm9HVR)LUm22GSI0)QOaLk())FQWVPmaQLt72EnuybW)VP9LEaxHA4Gb(vsRuAdbkMCjx5DWId4)30gKfWvOg(O617RsAzsBiqXKl5kVGt1mfOAGFHx(rzmIGjtbCsRxib)cGQ8(1Mlba]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170409.204707, [[d8dmiaqyPwVQQEjPuTlIs8Afu)gQzcrTmsy2uCEf6MiLCAu(grPCzL2jvTxXUjSFvXpHWWqvJJOKEUKgkLmyvPHJWbLOJIuQ6ykY5iLOfQQSuIIftKLtLhQapf8yeToIs1ejL0uH0KjQMUkxKKUkPuEge56izJsWwrkfBMsTDs0hvq(ms10uvX3vuJucLTPQsJMunEKItskUfPeUMeQUhsPYTrL1IukDCjKZuqdq2ehdlkGfhCJMnacTHISgVAGRD03ZsPvKc4Ab9DG(soC(cue1sTLggDb3kUaKbgryBx3BqtCmSOgpFaAqyBx3BqtCmSOgpFGIOwQvUgsSay)34)HpahtuQgVIafrTuR8bnXXWIA(cmIW2UUhA7OVxnE(a0EQLARbn(PGgqv0sMvE(cusEmS45fzw9Ixwd4BUnaOI8ZRQz5wX1MNxl3sI5K6lGmRz76gVc(PFN45rkaq6yexGJXT0o(CXRiObufTKzLNVaLKhdlEErMvV4)nGV52aGkYpVQMLBfxBEE16A3uMlGmRz76gVc(PFN45rswMcaKogXfixUavD8mmZos9s1ifGge2219qBh99QXZhGrIfartYe0JV4bAkxRryJrhj2asu22bgtbT43IZRLt8AjsYgsiX)JSIeFS1IFkEaBS4cu6yT5513ohEoqvhpJ2o67vZxGHLkfK6yxauewYOzOIHgGjKZi7d7kfK6yxaz0muXqdq2ehdlkfK6yxGpeOOiOvaGyjzTH9VpgweVIFveOQJNb08fOiQLA1kZTKhdlciJMHkgAabfNgsSOg)pbQeRXuW0v9byd2f0aD8tbCXpfGE8tbKIFkxGQoEEqtCmSOMVa0GW2UUxjLRJNpG81UPmxPfYbag3GNxvZYTIRnY(ZR81UPmxaUMMsQdhpFajd7))Hm45sJjsbAdHEd64zlLQXpfOne69amNuFwkvJFkGwx7MYC5lqBM7XQLsR8fqjRYKyg2nIosSbKcq2ehdlknm6Iadu9OQYeqoRsy6r0rInazaoMOK6WXRiGRf0x0rInqlXmSBmqt5AAXeB(cizy))pKbphPadlvaloG9FJFsrG2qO3LM5ESAPun(PaTHqVrBh99SuAf)uGQoEUKY1Ae24ifWTMadu9OQYeOsSgtbtx1JuG2qO3OTJ(EwkvJFkqvhpxsD4ifOiQLALRriNr2h2vZxagjwqBXyU4rIpW1o67vki1XUaFiqrrqlz0muXqdCTJ(EfWIdUrZgaH2qrwJxnaTAAyCuCpVOmUnEK4dqdcB76EA)RgpFaG0XiUavMGUzd0gc9U0m3JvlLwXpfGM45dq4yCTBSawCa7)g)KIaeULeZj1xPfYbag3GNxvZYTIRnY(ZlHBjXCs9fGeZj1NLs1ifGRPPunE(aOTzf3Z7qomfr88bU2rFplLQrkWamX4ZlkoGQz5wX1MN3seQbQ64zlLw5lWicB76EAeYzK9HD145dmIW2UUxjLRJNpaniSTR7PriNr2h2vJNpqrumYHPnSkCJMnGuGMY1OJeBajkB7avD8SgHCgzFyxnFbAkxdeRXOrRXZhOnZ9y1sPA(cu1XZwkvZxGQoEUunsbiXCs9zP0ksbSCmU2n(8oOjogw88ws56afmn3(8c6yYHdCTJ(EfWIlGf6Zl0I6ZRVDo8CGHLkGfhCJMnacTHISgVAaoMaqJxrGRD03RawCa7)g)KIavD8mmZos9sQdNVaKnXXWIcyXfWc95fAr9513ohEoqBi07byoP(SuAf)uavrlzw55lqLXry2seQXRiWWsfWIlGf6Zl0I6ZRVDo8CaFZTbunl3kU288wIqnaxtdGgpFazwZ21nEf8tYg)p8kKLjfiX)dsbQ64zTVJsmHCMGEnFbiBIJHffWIdy)34NueWYX4A34Z7GM4yyraxFmCachJRDJAiXcG9FJ)h(anLRlfK6yxGpeOOiOfYQfqdue1sTYlGfhW(VXpPiWicB76EA)RgpFGIOwQvU2)Q5lqBi0BqhpBP0k(PanLR1MGDbim946YLa]] )


end

