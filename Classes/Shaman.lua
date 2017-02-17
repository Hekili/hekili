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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170216.1, [[daKTDaqiPewerfAtqQgfKYPuQ6vqLGDbXWOshJkwgr6zuKPHsX1GkPTPu8nLkJJOsohrfToIkG5HsP7bvQ9ru1bHcluk1dvknrIkOlcfTrIk1iHkHCsOQMPuIUjkzNOyOevGwkuXtjnvOkFfQeTxv)fsgmkvhwyXs1JvYKP0LbBwbFwHgTuCAKEnfA2eUnvTBj)gXWjklhvpxrtx01HsBNc(UusNNIA9qLqnFIO9te(ohVRywrxa23(Qkdw0qqXfhjLuNr6gtxLdHHaRiF7R4aciMWzK66SZvQJueNR6ItLLxVIXkPKAE8oJZX7kMv0fG9TVYeE4kUKwwjyxBGGFvxCQS8AsghfacTsGZXklNxXOtf0081wPLf1Sbc(vCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZi94DfZk6cW((vMWdxXfbCcD6VQlovwEnjJJcazriclP1AIoAzWhHePbcr2GiBLSvkUkPKj1dY7IGRUU7VIrNkOP5RDbHyfyN5vCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZy64DfZk6cW(2xzcpCvUbEiKGDvgLtZR6ItLLxtY4OaqweIWsATMOJwlcEshIvIecznbQwjIbeEugL3vsjrZhGyMCIhzHLZHkLh3sDrFriclP1czXJzdkbDSjlAnIWbFqRjBX94YUF)vm6ubnnFDa4Ha1ugLtZR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNHnhVRywrxa23(kt4HRB5XSrc2BjDSjlAnEvxCQS8AWt6qSsKqiRjq1krmGWJYO8UOlJdgqnUSioidapeOMYOCAEfJovqtZxx8y2GsqhBYIwJxXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppdUE8UIzfDbyF7RmHhU2g4tGBKwJx1fNklVMKXrbGSieHL0AnrhTo2HbKyUGYg1cqWktsjBrgcOsKyUGYg1cqGk6cWkPKcWaiyRJR7(Ry0PcAA(Ah4tGBKwJxXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppZMJ3vmROla7BFLj8W12ccXkb7YnwU5R6ItLLxtY4OaqweIWsATMxXOtf0081UGqSOgWYnFfhqaXeoJuxNno7qCnDDBdSmYIya8qLVFf)Ysxrs4xlsbxzrSmHhU(8m7oExXSIUaSV9vDXPYYRjzCuaiYijLut0rBa4Ha1ugLtteo4dAnLhxLuYm4JqIKupGkjOSuGT4EJ7(Ry0PcAA(Qmssj1v8llDfjHFTifCLj8Wv5GKKsQRyWhNxRWd4wokJteKAeSOKrAf4YXR4aciMWzK66SXzhIRPRBBGLrwedGhQ89RSiwMWdxLJY4ebPgblkzKwbUC85zKRJ3vmROla7BFLj8W12eSclWhOZ8QU4uz51o2HbKobRWc8b6mr4GpO1KTJlRKsIMpaXm5epYclNdvYwCJRUOhRKAaqbf4PWuECBA)vm6ubnnFTtWkSaFGoZR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNropExXSIUaSV9vMWdxBtWkSaFGotjyhnN9x1fNklV2XomG0jyfwGpqNjch8bTMSDCzLus0wnbFeMOg4XkPKkeY7GSdxr3hGyMCIhzHLZHkzlUNqM0ACI0jyfwGpqNjkFaIzYjE0JvsnaOGc8uyYwClD)vm6ubnnFTtWkSaFGoZR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNXX94DfZk6cW(2xzcpCfhYYyNMa)QU4uz51meqLiIOStb1ciqfDbyrVJDyareLDkOwaHd(Gwt2oUSxXOtf008vozzSttGFfhqaXeoJuxNno7qCnDDBdSmYIya8qLVFf)Ysxrs4xlsbxzrSmHhU(8moohVRywrxa23(kt4HRYnwUzjyNmib7yq5x1fNklV2IKUmsRr09biMjN4rwy5COs5Lk9kgDQGMMVoGLBgfzavq5xXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppJJ0J3vmROla7BFLj8Wv5MtMzNhL9QU4uz51meqLinbvmtc3Jav0fGf9o2HbKbozMDEuweo4dAnzlh6yhgq1kTSKwVIrNkOP5RdCYm78OSxXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppJJPJ3vmROla7BFLj8Wv5weEij1iw4QU4uz51o2HbKbr4HKuJybeo4dAnzlh6yhgq1kTSKwLus0weIWsATqSeIhvR0Yor4GpO1KTBqVJDyazqeEij1iwaHd(Gwt2YM9xXOtf0081br4HKuJyHR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNXHnhVRywrxa23(kt4HRYHeIxc2XL0YoVIdiGycNrQRZgNDiUMUIrNkOP5RwcXJQvAzNxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJdUE8UIzfDbyF7RmHhUULhZgjyVL0XMSO1OeSJMZ(R6ItLLxZqavIS4XSHwJOMjH7rGk6cWIESsQbafuGNct5XTj0rRfziGkrAcQyMeUhbQOlaRKs2XomGmWjZSZJYIWbFqRP8Jl7(Ry0PcAA(6IhZguc6ytw0A8koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zC2C8UIzfDbyF7RmHhUIzWZgOKGDvg1iCfhqaXeoJuxNno7qCnDfJovqtZxHGNnqHAkJAeUIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgNDhVRywrxa23(kt4HRTKo2KfTgLG92erEvxCQS8kAziGkriga(Qj4Jacurxaw09biMjN4rwy5COs5XnBCrVfziGkrgWYnJImGkOCeOIUaS7Lus0YqavIqma8vtWhbeOIUaSONHaQezal3mkYaQGYrGk6cWIUpaXm5epYclNdvkpBCXfgibkzH1sRX9xXOtf008vbDSjlAnIQte5vCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZ4ixhVRywrxa23(kt4HRB5XSrc2BjDSjlAnkb7OjD)vDXPYYRDSddilEmBqjOJnzrRreo4dAnz74YIEYXcOIvsnaOGc8uykpULEfJovqtZxx8y2GsqhBYIwJxXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppJJCE8UIzfDbyF7RmHhUIlPLDsQXR4aciMWzK66SXzhIRPRy0PcAA(AR0Yoj14v8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZi194DfZk6cW(2xzcpCfJ5ckBul4QU4uz51KmokaKfHiSKwRj6O1XomGmtc3350Ae4iyLT)kgDQGMMVgZfu2OwWvCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZi154DfZk6cW(2xzcpCfxsl7m5uJWvDXPYYRDSddiZKW9DoTgbocwzOJgAziGkrgWYnJImGkOCeOIUaSO7dqmtoXJSWY5qLYJBPU4cdKaLSWAP14EjLeTwKHaQezal3mkYaQGYrGk6cWUF)vm6ubnnFTvAzNjNAeUIdiGycNrQRZgNDiUMUUTbwgzrmaEOY3VIFzPRij8RfPGRSiwMWdxFEgPspExXSIUaSV9vMWdx1KW9ZKtncx1fNklV2XomGmtc3350Ae4iyLHoAOLHaQezal3mkYaQGYrGk6cWIUpaXm5epYclNdvkpUL6IlmqcuYcRLwJ7Lus0ArgcOsKbSCZOidOckhbQOla7(9xXOtf0081zs4(zYPgHR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNrQPJ3vmROla7BFLj8W1wggcjyVLXS5QU4uz51meqLinKevtuweOIUaSO3XomG0qsunrzrWk7kgDQGMMVkcdbkrmBUIdiGycNrQRZgNDiUMUUTbwgzrmaEOY3VIFzPRij8RfPGRSiwMWdxFEgPS54DfZk6cW(2xzcpCDlpMnsWElPJnzrRrjyhnt7VQlovwEnwj1aGckWtHP84MnxXOtf0081fpMnOe0XMSO14vCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZifxpExXSIUaSV9vMWdxXL0Yoto1iib7O5S)koGaIjCgPUoBC2H4A6kgDQGMMV2kTSZKtncxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJ0nhVRywrxa23(kt4HRAs4(zYPgbjyhnN9x1fNklVMHaQeHya4RMGpciqfDbyrFriclP1crqhBYIwJO6erIWbFqRjBhxw09biMjN4rwy5COs5Ll3Ry0PcAA(6mjC)m5uJWvCabet4msDD24SdX101TnWYilIbWdv((v8llDfjHFTifCLfXYeE46ZZiD3X7kMv0fG9TVYeE4QMeUFMCQrqc2rt6(R6ItLLxZqavImGLBgfzavq5iqfDbyr3hGyMCIhzHLZHkLNnU4cdKaLSWAP1i6OTieHL0AHiOJnzrRruDIir4GpO1u(XLvsjBrgcOseIbGVAc(iGav0fGD)vm6ubnnFDMeUFMCQr4koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zKkxhVRywrxa23(kt4HRAs4(zYPgbjyhnt7VQlovwETfziGkriga(Qj4Jacurxaw0BrgcOsKbSCZOidOckhbQOla7vm6ubnnFDMeUFMCQr4koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zKkNhVRywrxa23(QU4uz5v0qlwj1aGckWtHP8oskzgcOsKfpMn0Ae1mjCpcurxawjLmdbujsNGvyb(aDMiqfDby3JElMqIQtkStKKcCh5efBKTK3DVKsoa8qGAkJYPjch8bTMYJRxXOtf0081fpMnOe0XMSO14v8llDfjHFTifCLj8W1T8y2ib7TKo2KfTgLGD0yZ(R4aciMWzK66SXzhIRPRAdPvwelDGc85BFDBdSmYIya8qLVFLfXYeE46ZZyY94DfZk6cW(2xzcpCvU5Kz25rzLGD0C2FvxCQS8AgcOsKMGkMjH7rGk6cWIEh7WaYaNmZopklch8bTMSLniY1vm6ubnnFDGtMzNhL9koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zm5C8UIzfDbyF7RmHhU2YWqib7TmMnsWoAo7VQlovwEndbujYawUzuKbubLJav0fGf9meqLiedaF1e8rabQOlal6OnHevNuyNijf4oYjk2iBjVl6(aeZKt8ilSCouP84wUC3FfJovqtZxfHHaLiMnxXbeqmHZi11zJZoextx32alJSigapu57xXVS0vKe(1IuWvwelt4HRppJjPhVRywrxa23(kt4HRTmmesWElJzJeSJM09x1fNklVMHaQezal3mkYaQGYrGk6cWIElYqavIqma8vtWhbeOIUaSOJ2esuDsHDIKuG7iNOyJSL8UO7dqmtoXJSWY5qLYJBC10(Ry0PcAA(QimeOeXS5koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zmz64DfZk6cW(2xzcpCTLHHqc2BzmBKGD0mT)QU4uz5v0AXesuDsHDIKuG7iNOyJSL8UO7dqmtoXJSWY5qLYJ7jKjTgNiIWqGseZgu(aeZKt87Lus0ArgcOsKbSCZOidOckhbQOlal6tir1jf2jssbUJCIInYwY7IUpaXm5epYclNdvkpUzJ7(Ry0PcAA(QimeOeXS5koGaIjCgPUoBC2H4A662gyzKfXa4HkF)k(LLUIKWVwKcUYIyzcpC95zmXMJ3vmROla7BFLj8Wv5weEij1iwqc2rZz)vDXPYYRDSddidIWdjPgXciCWh0AYw2GixxXOtf0081br4HKuJyHR4aciMWzK66SXzhIRPRBBGLrwedGhQ89R4xw6ksc)Ark4klILj8W1NNXeUE8UIzfDbyF)kt4HRk2YcCAnEfhqaXeoJuxNno7qCnDfJovqtZxNyllWP14v8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZyAZX7kMv0fG9TVYeE4koKLXonbUeSJMZ(R4aciMWzK66SXzhIRPRy0PcAA(kNSm2PjWVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgt7oExXSIUaSV9vMWdxLBr4HKuJybjyhnP7VIdiGycNrQRZgNDiUMUIrNkOP5RdIWdjPgXcxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJj564DfZk6cW(2xzcpCTnbRWc8b6mLGD0KU)koGaIjCgPUoBC2H4A6kgDQGMMV2jyfwGpqN5v8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZNxzcpCvP(TsWoMvtulWdvkhqc2TWqGvKp)b]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170216.1, [[dedXbaGEukTlczBIIzQq1Sj6Me03iP2PI2l1Uf2VO0WuWVLmuusnyrLHRkhKKCmiTquLLQqwmjwoelIapfSms1ZjLjQqzQeQjRutxQlIQ6zIuxhLWMrPy7OuDzKhRQ(mk(oQKdd15rfgTiEOi5KOIUTsoTk3dLK)kQ61OsTouI2OwSb(bwrsBZZa8O)HLhBX9vHN6zsBymInywiBZZWissynYt9bu1d6O6IqnaFK71gmO63xfAwSNOwSb(bwrsBZZa8rUxBOlggjj6v9vHMbvkN8Aom8Q(QWaNX((4UqmevqgM4fzG1vFvyqfcJMHaViwj4HuYkyOD(xXfHiWWissynYt9b0mOQfnK2qQe6ZTWIDArrBfdcR9eVidcEiLScgAN)vCricC7PUfBGFGvK028mmXlYW4htshxWKnhKCKCByejjSg5P(aAgu1IgsBqLYjVMddYJjPJlyYRLCKCBGZyFFCxigIkidPsOp3cl2PffTvmiS2t8Im42THjErgGBLkBo(rco(0IIMLzZ9qOFTuWTBBa]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170216.1, [[d4JRoaGEePuBcrSlqTnQu7tsyMiQ6XKmBunFjvCtjv6WcFts63OStKAVk7wL9tknkjvnmrmoevCEsXPbgmPQHRQ6GskNsvWXqY5KeXcPGLQkAXiSCk9qvH6Peltv55IAIisjtLkzYGmDPUif6visvxg66uvBusuVMIAZuX2ru(mPY3vLY0qKkZtvQEgf5qiQ0OfPXJifDsvj)LQCnjr6EiswjIu44Qc52s8OMRjgVGGJqZWe5hvGGdiTJgWUr)5(BcPf6e(8EgM8e5yKXr)Lqvn5J6dMAIOSG)EYKAQgWU8CnAQ5AIXli4i0mmruwWFpPz60XryfJXHyVDzsGynSdpkOxoLPmdBXsaUCfe(ooWrwHhuCkegY3gnGDKOymoe7TdMhKfEe(2CdBXsaUCfjKqUe(ooW5MzlMr8hTW()tQra4GwZKiRWdkofo51bburZSto2HtEICmY4O)sOCtvfoX0e6OGtQLv4bfNcxp6V5AIXli4i0mmPUbPjO4xCfwDyNNyAIOSG)Ec52aLzWPBsncah0AM4WJc6LtzkZtEDqav0m7KJD4e6OGtQmpkOw9sktzEYJ1O4ORWQd78iM8e5yKXr)Lq5MQkCIPjsk7T6YGaoa0MhX6rBAUMy8ccocndteLf83tkbYZTLvGv(wlEDfK6lHelwcWLFNue(ooWrwHhuCkegY3gnGDKOymoe7TdoYk8GItHWwSeGlt6j8DCGJScpO4uimKVnAa7ENuq(2ObSBsncah0AM4WJc6LtzkZtEDqav0m7KJD4e6OGtQmpkOw9sktzwR(6PEyYtKJrgh9xcLBQQWjMwpAs3CnX4feCeAgMikl4VNq474aJQugM9yoEDk6PZIr7L9pi0coDW()KqUe(ooWrwHhuCke2)NKsG8CBzfyLV1IxxbPih3AjnM8e5yKXr)Lq5MQkCIPjVoiGkAMDYXoCsncah0AMGHTtFKFygNqhfCIXW2PpYpmJRhDLoxtmEbbhHMHjIYc(7jLa552YkWkFRfVUcsvjFKqUe(ooWrwHhuCke2)FYtKJrgh9xcLBQQWjMM86GaQOz2jh7Wj1iaCqRzcg2o1lNYuMNqhfCIXW2PA1lPmL51J29CnX4feCeAgMikl4VN0mD64iCyBGtOAVGaWbTMjprogzC0FjuUPQcNyAsncah0AMKBMTygXF0o51bburZSto2HtOJcorAMTygXF0orszVvxgeWbG28iwp6QZ1eJxqWrOzyIOSG)EYKNihJmo6Vek3uvHtmn51bburZSto2HtQra4GwZeKJf86G7rWJCpHok4eJCSGxhCT6nWJCVE0KZCnX4feCeAgMikl4VNeQgqg6HhwayUcszAsncah0AMWbpYha5vcDLWRznwM86GaQOz2jh7WjprogzC0FjuUPQcNyAcDuWjKh8iFaKw91n0vcT6DXASSE0vYCnX4feCeAgMikl4VNq474a)ZEdTEmhVof9kbYZTLvG9)jHW3Xbo3mBXmI)Of2)NKq1aYqp8WcaZVBAYtKJrgh9xcLBQQWjMM86GaQOz2jh7Wj1iaCqRzchOlTpWPZJGX7j0rbNqEGU0(aNoT6nW496rtLmxtmEbbhHMHjIYc(7jqSg2Hhf0lNYuMHTyjaxUcvKBVguqsQxXyCi2BNNfdvxN6q474ahzfEqXPqy))hM8e5yKXr)Lq5MQkCIPjVoiGkAMDYXoCsncah0AMWdYcpcFBUNqhfCc5dYcT6n4BZ96rtrnxtmEbbhHMHjIYc(7jLa552YkWkFRfVUcs9LqcHVJdmYXcEDW9Cyk)mS)pjw0XI50GGJtQra4GwZehEuqVCktzEYRdcOIMzNCSdN8e5yKXr)Lq5MQkCIPj0rbNuzEuqT6LuMYSw91)9W6rt9nxtmEbbhHMHjIYc(7jLa552YkWkFRfVUcs9LqcHVJdmYXcEDW9Cyk)mS)pjHQbKHEqSg2Hhf0lNYuMFV(q1aYqp8WcaZVtktKeQgqg6HhwayUo1X0dtEICmY4O)sOCtvfoX0KxheqfnZorPrXXj0rbNuzEuqT6LuMYSw9pwJIJtQra4GwZehEuqVCktzE9OPmnxtmEbbhHMHjIYc(7jLa552YkWkFRfVUcsroUN8e5yKXr)Lq5MQkCIPjVoiGkAMDYXoCsncah0AMGHTt9YPmL5j0rbNymSDQw9sktzwR(6PEy9OPiDZ1eJxqWrOzyIOSG)EcHVJdCZAS4vICJwnWwSeGl)ovsDQt9e(ooWnRXIxjYnA1aBXsaU87e(ooWrwHhuCkegY3gnGDKEfJXHyVDWrwHhuCke2ILaCzsumghI92bhzfEqXPqylwcWLFNQsFyYtKJrgh9xcLBQQWjMM86GaQOz2jh7Wj0rbN4I1yrR(6g5gTAMuJaWbTMjnRXIxjYnA1SE0uv6CnX4feCeAgMikl4VNq474aJQugM9yoEDk6PZIr7L9pi0coDW()tQra4GwZemSD6J8dZ4KxheqfnZo5yho5jYXiJJ(lHYnvv4ettOJcoXyy70h5hMrT6RN6H1JMY9CnX4feCeAgMikl4VNeQgqg6HhwayUcQjprogzC0FjuUPQcNyAYRdcOIMzNCSdNuJaWbTMj8GSWJaJYe6OGtiFqwOvVbmkRhnv15AIXli4i0mmruwWFpHW3Xb(N9gA9yoEDk6vcKNBlRa7)tsOAazOhEybG53nn5jYXiJJ(lHYnvv4ettEDqav0m7KJD4KAeaoO1mHd0L2h405rW49e6OGtipqxAFGtNw9gy8wR(6PEy9OPiN5AIXli4i0mmruwWFpjunGm0dpSaWCfutEICmY4O)sOCtvfoX0KxheqfnZo5yhoPgbGdAntuPb484aDP9boDtOJco5XPb40QN8aDP9boDRhnvLmxtmEbbhHMHjIYc(7jtEICmY4O)sOCtvfoX0KxheqfnZo5yhoHok4eYd0L2h40PvVbgV1QV(VhMuJaWbTMjCGU0(aNopcgVxp6VK5AIXli4i0mmruwWFpPWidC6iXIowmNgeCCYtKJrgh9xcLBQQWjMM86GaQOz2jh7Wj0rbNuzEuqT6LuMYSw91B6Hj1iaCqRzIdpkOxoLPmVE0FuZ1eJxqWrOzyIKYERUmiGdaT5zyIOSG)EsOAazOhEybG5kOijunGm0dI1Wo8OGE5uMY87HQbKHE4HfaMN8ynko6kS6WopIjprogzC0FjuUPQcNyAYRdcOIMzNO0O44e6OGtQmpkOw9sktzwR(6FSgfh1Q)7Hj1iaCqRzIdpkOxoLPmVE0FFZ1eJxqWrOzycDuWjgdBNQvVKYuM1QV(VhM8e5yKXr)Lq5MQkCIPjVoiGkAMDYXoCsncah0AMGHTt9YPmL5jIYc(7jfgzGt361tOJcormsET6nYXcEDW1QVwwHhuCkC9g]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170216.1, [[dauDoaqikIOnrrAuOQCkuvTkkIWRGuQAxeAycCmuSmv0ZOGPrruUgfrABuuFJQQXbPOZjuuZdsv3tLO9Ps4GQGfsqpesjtesP4IuOnsr4KcvRuOiVKIOAMcfUjKk7eLwQk0trMkvL9k9xbnycCyLwmQ8yknzQYLbBMk(mQYOPsNwvVgcZMu3wr7gQFtYWvPoUqjlNONRW0fDDHSDvsFhsHXdPu68q06HuQmFHsTFi5YuFLmIxon4vHLqBaNnsNvyj2DcLiJXaLaJAyc4C1Oee3corsKLocAyhqzpdy8hCYCkYuIUb7V6hTBZxHl7P5ZshS5RWJ6RSm1xjJ4LtdEvyjYk)7SKjz(wepMxPdCV(tKLC07echUklIsXXEVDtLSewHHshbnSdOSNbmMz8lgyOe7oHsMqVtaLaYvzrGsaFb83SSN1xjJ4LtdEvyjYk)7SexKJJiyDvWiu5eMUqipjSz4ic7bYhZtm6205c6rkvtrBKuc48IlrtZLocAyhqzpdymZ4xmWqP4yV3UPswcRWqj2DcLmUY0nwrlcO0bUx)jYsWkt3yfTiGML1q9vYiE50GxfwISY)olXf54i(wWjsIum6205c6rkvtrBKuc48IlrtZLoW96prwYrQgz4Wvzruko27TBQKLWkmu6iOHDaL9mGXmJFXadLy3juYes1irjGCvwenlRjR(kzeVCAWRclrw5FNLMlOhPunfTrsjGZlUmMprftLocAyhqzpdymZ4xmWqP4yV3UPswcRWqj2DcLmUY0fLaYvzru6a3R)ezjyLPB4Wvzr0SSM06RKr8YPbVkSe7oHsuQKteaCdYsh4E9NilnsLCIaGBqwko27TBQKLWkmuISY)olLkE80G4kZ3zTz4Y96prAkFRn)RqiGH5dJlyIDShqMpM3qC5XtcJXFfchPsoraWni5V0rqd7ak7zaJzg)IbgAwwZ1xjJ4LtdEvyjYk)7SuPJGg2bu2ZagZm(fdmuko27TBQKLWkmuIDNqjJAyc4C1OeiuVJS0bUx)jYsGgMaoxDiNEhzZY6V(kzeVCAWRclrw5FNLMlOhPunfTrsjGt0FPFZLoW96prw6TGtKezP4yV3UPswcRWqPJGg2bu2ZagZm(fdmuIDNqP4wWjsISzzrZ6RKr8YPbVkSezL)DwAT5FfcbmmFyCXLgkDG71FISK(Jv07foxEZnmvjmlfh792nvYsyfgkXUtOum(yf9EOeGUL3CrjWNkHzPJGg2bu2ZagZm(fdm0SSXC9vYiE50GxfwISY)olXf54iERqdqgQCctxiCUGEKs1um62uUihhXrQKteaCdsXOBtxB(xHqadZhgO3qPdCV(tKL0pp3e)yEHCkDwko27TBQKLWkmu6iOHDaL9mGXmJFXadLy3jukgpp3e)yEOeiuPtuc4Jm583SSmb1xjJ4LtdEvyjYk)7SKNkfD07echUklcrjm3hpUWUJmm)jGkMkDe0WoGYEgWyMXVyGHsXXEVDtLSewHHsS7ekfJ96IsGWi5ilDG71FISKEVUHCrYr2SSmm1xjJ4LtdEvyjYk)7SexKJJ4BbNijsXOBt5BUGEKs1u0gjLaoV4YZGyhBUihhX3corsKIsyUpEGE(4z9mj4ICCeFl4ejrkoY1IaTNHF(lDG71FISKJunYWHRYIOuCS3B3ujlHvyO0rqd7ak7zaJzg)IbgkXUtOKjKQrIsa5QSiqjGpg(BwwMZ6RKr8YPbVkSe6w02Fgn9TsEqokzOezL)DwAUGEKs1u0gjLaoV4YZat5ICCebnmbCU6qhLnAigDBQeCKWWD50aQyQ0bUx)jYso6DcHdxLfrP4yV3UPswcRWqj2DcLmHENakbKRYIOeAH0QbFRKhKJYv6iOHDaL9mGXmJFXadLixfAGoL378GCuUMLLXq9vYiE50GxfwISY)olnxqpsPAkAJKsaNxC5zGPCrooIGgMaoxDOJYgneJUnLp(wB(xHqadZhgxEA6AZ)ke6Psrh9oHWHRYIa9N8h7yZ3AZ)kecyy(W4Ilny6AZ)ke6Psrh9oHWHRYIa9g4N)sh4E9Nil5O3jeoCvweLIJ9E7MkzjlsRgkXUtOKj07eqjGCvweOeWhd)LocAyhqzpdymZ4xmWqZYYyYQVsgXlNg8QWsKv(3zjUihhX3corsKIr3LoW96prwYrQgz4Wvzruko27TBQKLWkmucDQRpMxzzkXUtOKjKQrIsa5QSiqjGVt(lDe0WoGYEgWyMXVyGHsKRcnqNY7DEqoQWsOLlyrGo1vyc4ScBwwgtA9vYiE50GxfwISY)olnxqpsPAkAJKsaNxCjAAU0bUx)jYsWkt3WHRYIOuCS3B3ujlHvyOe7oHsgxz6Isa5QSiqjGpg(lDe0WoGYEgWyMXVyGHMLLXC9vYiE50GxfwISY)olXf54ikHHcVyleMQeMIsyUpEGEMGshbnSdOSNbmMz8lgyOuCS3B3ujlHvyO0bUx)jYsPkHz4ChjirwIDNqjFQeMOeGUDKGezZYY4V(kzeVCAWRclrw5FNL4ICCebRRcgHkNW0fc5jHndhrypq(yEIr3LocAyhqzpdymZ4xmWqP4yV3UPswcRWqPdCV(tKLGvMUXkAraLy3juY4kt3yfTiauc4JH)MLLbnRVsgXlNg8QWsS7ekfJNNBIFmpuceQ0zPJGg2bu2ZagZm(fdmuko27TBQKLWkmuISY)olXf54iERqdqgQCctxiCUGEKs1um6201M)vieWW8Hb6nu6a3R)ezj9ZZnXpMxiNsNnlltmxFLmIxon4vHLiR8VZsRn)RqiGH5dJlykDe0WoGYEgWyMXVyGHsXXEVDtLSewHHsh4E9NilzD3hhQFEUj(X8kXUtOeA5UpgLGy88Ct8J51SSNb1xjJ4LtdEvyjYk)7SuPdCV(tKL0pp3e)yEHCkDwko27TBQKLWkmuIDNqPy88Ct8J5HsGqLorjGpg(lDqYBuQ0rqd7ak7zaJzg)IbgkrUk0aDkV35b5OCLqlxWIaDQRWeWz5Aw2tM6RKr8YPbVkSezL)DwAQU(yEMkbhjmCxonu6iOHDaL9mGXmJFXadLIJ9E7MkzjScdLy3juYe6DcOeqUklcuc47K)sh4E9Nil5O3jeoCvwenl75z9vYiE50GxfwISY)olnvxFmptxB(xHqpvk6O3jeoCvweOFT5FfcbmmFyu6iOHDaL9mGXmJFXadLIJ9E7MkzjlsRgkDG71FISKJENq4WvzruIDNqjtO3jGsa5QSiqjGVt(rjaTqA1qZYEAO(kzeVCAWRclrw5FNLMQRpMxPJGg2bu2ZagZm(fdmuko27TBQKLWkmu6a3R)ezjyLPB4WvzruIDNqjJRmDrjGCvweOeW3j)nBwISY)ol1Sfa]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170216.1, [[d0dqoaGEqvP2eOYUOOTjc7te1mvP0SrA(KKYnvPWJP0TvXHLANOYEv2nW(vvnkuv9xu8BsDoss15rvgmOmCq6GIQofjXXq44IiTqsQLkQSyuA5u1drvPNsSmvLNRkteuvyQurtgrtx4IuOtl5YqxheBuLIEnfSzvY2ffFMk9DretduvzEGQ8mQWHavfnAsmEqvjNuLQXHQcxduv19ijzLOQOVjknmr6rmNtmcAwkso1t46dormE7pmJu8GGOP)WUn3eX6lOXKj5qk2pCCFPezt)i(mjMiqrB10c(UJsdg3xIVj5TrPbV5CCeZ5eJGMLIKt9eX6lOXe4ZOSgkG7K8SfTcEtUO9bzEkARHj3bKLTdTFcqdWj5qk2pCCFPejiYAM6ycxFWj3K2h8hMOOTg(HXFQklg33CoXiOzPi5uprS(cAmHfY1LjAv04JrFXekiJRh7G5bbqI(c4AcbkCNgPVWRpMwiEpcIKvfFKysoKI9dh3xkrcISMPoMChqw2o0(janaNW1hCIX2hkjfsBaNKNTOvWBc2(qjPqAd4IX5yoNye0SuKCQNiwFbnMCAK(cV(yAH49iiswvQ(3pFojhsX(HJ7lLibrwZuhtUdilBhA)eGgGt46doXy7dLFyII2AysE2IwbVjy7dfMNI2AyX4GFZ5eJGMLIKt9eU(GtKq7pgqek6NKNTOvWBYl0(JbeHI(j3bKLTdTFcqdWjI1xqJjH21LIMTpQR2gmnBrRGhC832OYGmiapf(sMq1uThgrbCFMTRRhFVkdY8cT)yarOOxLj5qk2pCCFPejiYAM6yX4G)Z5eJGMLIKt9eX6lOXKj5qk2pCCFPejiYAM6yYDazz7q7Na0aCcxFWjgP4bbrt)HPM2VysE2IwbVjifpiiAkdlTFXIXLyoNye0SuKCQNiwFbnM02OYGmiapf(swvoMKNTOvWBcTskKIK50UNMj0bEMChqw2o0(janaNW1hCYTvsHuK)WUr7E6Fyo1bEMKdPy)WX9LsKGiRzQJfJl7CoXiOzPi5uprS(cAmHuhMx0(GmpfT1GPhpDbEjB7xWe1b)5Zj5qk2pCCFPejiYAM6yYDazz7q7Na0aCcxFWj32z6FyQH4FXK8SfTcEtODMMHfI)flghFmNtmcAwkso1tUrdFvhihNT3fJ3ehteRVGgtonsFHxFmTq8EeejRQVu4yHCDzIu8GGOPmxAlKNjeOW5Xlp(uAwk(ZNtYZw0k4n5I2hK5POTgMChqw2o0(janaNW1hCYnP9b)HjkARHj8LNLIoBVlgVXojhsX(HJ7lLibrwZuhtefDsUHMSUk0)g7IXP6Z5eJGMLIKt9eX6lOXKtJ0x41htleVhbrYQ6lfowixxMifpiiAkZL2c5zcbkC8ZFBJkdYGa8u4tvFW12OYGmK6W8I2hK5POTgG3NkQMQXFBJkdYGa8u4lzv5aU2gvgKHuhMx0(GmpfT1a8COIktYZw0k4n5I2hK5POTgMChqw2o0(jwEwkoHRp4KBs7d(dtu0wd)W4NqLj5qk2pCCFPejiYAM6yX4isNZjgbnlfjN6jI1xqJjNgPVWRpMwiEpcIKvfFKysE2IwbVjy7dfMNI2AyYDazz7q7Na0aCcxFWjgBFO8dtu0wd)W4NqLj5qk2pCCFPejiYAM6yX4iiMZjgbnlfjN6jI1xqJjSqUUm94tdAGfzcDGhtpE6c8Ghr6KCif7hoUVuIeezntDm5oGSSDO9taAaojpBrRG3Kqh4H50Va98MW1hCItDGNFy3OFb65TyCeFZ5eJGMLIKt9eX6lOXewixxMOvrJpg9ftOGmUESdMheaj6lGRjeOtYHuSF44(sjsqK1m1XK7aYY2H2pbOb4K8SfTcEtW2hkjfsBaNW1hCIX2hkjfsBa)HXpHklghHJ5CIrqZsrYPEcxFWj3wUkbOaU)WuRPXKCif7hoUVuIeezntDm5oGSSDO9taAaorS(cAmHfY1LjuDsqpJ(IjuqMtJ0x41htiqHRTrLbzqaEk8bphWrISqUUmPLRsakGlJxtAsQtcysE2IwbVj0YvjafWLHvtJfJJa(nNtmcAwkso1teRVGgtyHCDzcvNe0ZOVycfK50i9fE9Xecu4ABuzqgeGNcFWZbCTnQmidPomVO9bzEkARb49njhsX(HJ7lLibrwZuhtUdilBhA)elplfNW1hCYTLRsakG7pm1AA8dJF(YZsrvMKNTOvWBcTCvcqbCzy10yX4iG)Z5eJGMLIKt9eX6lOXK2gvgKbb4PWxYeWrISqUUmPLRsakGlJxtAsQtc4NpNKdPy)WX9LsKGiRzQJj3bKLTdTFcqdWj5zlAf8Myv6cWqlxLaua3jC9bNWxLUa)WUTCvcqbCxmoIeZ5eJGMLIKt9eX6lOXK2gvgKbb4PWxYeWXc56YKwUkbOaUmEnPjeOW12OYGmK6WKwUkbOaUmEnj8ABuzqgeGNcFtYZw0k4nXQ0fGHwUkbOaUtUdilBhA)elplfNKdPy)WX9LsKGiRzQJjC9bNWxLUa)WUTCvcqbC)HXpF5zPOklghr25CIrqZsrYPEIy9f0ycjYc56YKwUkbOaUmEnPjPojGj5zlAf8MqlxLauaxgwnnMChqw2o0(janaNW1hCYTLRsakG7pm1AA8dJFcvMK37(MmjhsX(HJ7lLibrwZuhtefDsUHMSUk0)g7e(QGwd3qNbpiig7IXrWhZ5eJGMLIKt9eX6lOXK2gvgKbb4PWxYeW12OYGmK6WKwUkbOaUmEnj8ABuzqgeGNcFtYHuSF44(sjsqK1m1XK7aYY2H2pXYZsXj5zlAf8MC51VG5POTgMW1hCYTLRsakG7pm1AA8dJFcv(HXxEwkUyCeQ(CoXiOzPi5uprS(cAmzsoKI9dh3xkrcISMPoMChqw2o0(janaNKNTOvWBcTCvcqbCzy10ycxFWj3wUkbOaU)WuRPXpm()uzX4(sNZjgbnlfjN6jI1xqJjhDMc4cNhV84tPzP4KCif7hoUVuIeezntDm5oGSSDO9taAaoHRp4KBs7d(dtu0wd)W4)tLj5zlAf8MCr7dY8u0wdlg3hXCoXiOzPi5uprS(cAm5OZuax4ABuzqgsDyEr7dY8u0wdWRTrLbzqaEk8njhsX(HJ7lLibrwZuhtUdilBhA)elplfNKNTOvWBYfTpiZtrBnmHRp4KBs7d(dtu0wd)W4)tLFy8LNLIlg333CoXiOzPi5uprS(cAm5OZua3j5qk2pCCFPejiYAM6yYDazz7q7Na0aCsE2IwbVjy7dfMNI2AycxFWjgBFO8dtu0wd)W4)tLflMaFGxneAm1l2a]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170216.1, [[d0ZuhaGEcuAtQOs7cQ2MkyFQOyMuIMTuZNcCtkHhtLVPcDyHDQQ2RYUjTFvQFsuKHrvnocunkvuvdLaPgmumCO0bjQoLkQYXOOZrGKfsHwkHSyISCrTic4POwgK8CvzIefmvkPjlY0LCrQY6ik1LbxhsTrIsCAK2mLY2jq0FjOptOMgbk(of0ZuroKkknAIIAEeiCskvVMOKUgrHoVkzLQOIBdXVr8mN1XEAi1qAghZybhnAQGnkkr3h1buJLbWwGURzCSiOH4b7JY38Opktu4MJzxMITgpwUROe9nR7BoRJ90qQH0mo(hiWybnPOeDm7YuS14IiwCd4yjfLOVZ98pBrelUbChH0jIH6ZadCesNigQ42Ozqi0acOv04zajO67mOeC)ZBSiOH4b7JY38G5rC)tJTRjQlksESsuySCjAtRRXyjfLOJTGK(bcmwaSzstuXqsiwIHqwGv7JAwh7PHudPzCm7YuS1yj02SHxKcqeIeVcYx4zajO6tqGASCjAtRRXfPaeHiXRG81y7AI6IIKhRefg)deySvsbi3ySiEfKVglcAiEW(O8npyEe3)0Q9pnRJ90qQH0moMDzk2ACrelUbChH0jIH6BSiOH4b7JY38G5rC)tJTRjQlksESsuy8pqGXYcnd3y8Aab0k6XYLOnTUgBJMbHqdiGwrVAFbZSo2tdPgsZ4y2LPyRXfrS4gWDesNigQVXIGgIhSpkFZdMhX9pn2UMOUOi5XkrHX)abgZfjJCJXRbeqROhlxI206A8RizeHqdiGwrVAFzCwh7PHudPzCm7YuS14IiwCd4ocPted13y5s0MwxJHgqaTIwis8kiFn2UMOUOi5XkrHXIGgIhSpkFZdMhX9pn(hiWyVgqaTI(gJfXRG81Q9pmRJ90qQH0moMDzk2A8zRObTWJNd0uOoah0qQHKbgiH2Mn845anfQdWrJ1adCesNigQ4XZbAkuhGNbKGQVZiJ(JfbnepyFu(MhmpI7FASDnrDrrYJvIcJ)bcm2ytiPBmYc681y5s0MwxJLAcjj0g681Q9poRJ90qQH0moMDzk2A8zRObTWJNd0uOoah0qQHKbgiH2Mn845anfQdWrJDSiOH4b7JY38G5rC)tJTRjQlksESsuy8pqGXgH8dYYkvfpwUeTP11yji)GSSsvXR2xWN1XEAi1qAghZUmfBnoCfvqccbfqOW7mOg)deySi0QSVXixM8glxI206ACgTkmCfLOcB6RgBxtuxuK8yLOWyrqdXd2hLV5bZJ4(NgBbj9deySaSNL3y8Aab0k6BmYLjpbwTVGAwh7PHudPzC8pqGXIqRY(gJ8Nd0uOoym7YuS14kAql845anfQdWbnKAinwe0q8G9r5BEW8iU)PX21e1ffjpwjkmwUeTP114mAvy4kkrf20xn2cs6hiWybyplVX41acOv03yK)CGMc1bcSAFt)zDSNgsnKMXX)abglcTk7Bm2DGn05RXSltXwJRObTWPoWg68foOHudP7ZzSiOH4b7JY38G5rC)tJTRjQlksESsuySCjAtRRXz0QWWvuIkSPVASfK0pqGXcWEwEJXRbeqROVXy3b2qNVey1(MMZ6ypnKAinJJ)bcmweAv23ySKkwMlLQIVXiIKgZUmfBnUIg0cVPIL5sPQyHzsch0qQH0yrqdXd2hLV5bZJ4(NgBxtuxuK8yLOWy5s0MwxJZOvHHROevytF1yliPFGaJfG9S8gJxdiGwrFJXsrcSA14FGaJzplVX41acOv03yKbWwGURvB]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170216.1, [[dSJ9iaGEsvOnjvv7sI2MK0(ivrZuQkZgv3ekUnfhMQDQk7vSBv2pP0pjvbdtknouc6BsQwgHmysQHljoij5uKQKJrW5qjPwik1svuwmuTCv1dLuEkYJP0ZrXerjjtvcnzfMUsxKqDEsLldUoPyJOK40q2SeSDP41qPVtQQ(SuzEOK6zsv(RImAsmnucDsfvhcLixdLa3dLO(nrhNuvgfPk1rifdj(CComc7qK9JQSHc9CdeIe3Nw1I5GbU15AvRspio0mGdodKNOwH6TIeevkeIQawKZr6rFrYlprvffsLDrYJjfZtifdj(CComc7qp3aHOv(nybOc8dPchXrRUqmR8BWcqf4hAgWbNbYtuRqvH6LT9cn)giRVYFOtEqOAkGflgzdyGBdEimYXZnqOS5jkfdj(CComc7qp3aHuXyHB4Nfcr2pQYgALDDCO0kL8Hu)htO53az9v(dDYdcPchXrRUqoJfUHFwiunfWIfJSbmWTbp0mGdodKNOwHQc1lB7fcJC8CdekBE9sXqIphNdJWo0ZnqO(q6tdAOvngVZ4AvxuUGjKkCehT6cXr6tdAmz8oJpTYfmHMbCWzG8e1kuvOEzBVqZVbY6R8h6KheQMcyXIr2ag42GhcJC8CdekBESykgs854Cye2Hi7hvzdzCGZSFPP0Q5)HB1twwuB)S06C42soQtzp01n9LJs4CCom6)df(aJIJZHqQWrC0QlubUBGjgfPfBOAkGflgzdyGBdEONBGqSc3nGw1KI0In0mGdodKNOwHQc1lB7fIuK6hJCGkGGptWdn)giRVYFOtEqimYXZnqOS5XcsXqIphNdJWoez)OkBi3UOgycoWGagwZI972f1atd5wwG7gyIrrAXYA3UOgycoWGaMqQWrC0QlubUBGjgfPfBO53az9v(dz1z5qONBGqSc3nGw1KI0IvR6A6SCi0mGdodKNOwHQc1lB7LnVQPyiXNJZHryh65giKy)Vk6tJJfcPchXrRUqG)xf9PXXcHMbCWzG8e1kuvOEzBVqZVbY6R8h6KheQMcyXIr2ag42GhcJC8CdekBE1tXqIphNdJWo0ZnqO(8gxRA2A(mBiY(rv2qd5wwG7gyIrrAXw(bJJog906m70Imq)4AkuOK7n(eJMFhuQPs)S06C42soQtzp01n9LJs4CCom63TlQbMGdmiGH1SyO53az9v(dDYdcPchXrRUqCVXNW18z2q1ualwmYgWa3g8qZao4mqEIAfQkuVSTximYXZnqOS5XctXqIphNdJWo0ZnqiXCWa36CTQzZDMnez)OkBiwADoCBjh1PSh66M(YrjCoohg972f1atWbgeWWAwqO53az9v(dDYdcPchXrRUqahmWToFcN7mBOAkGflgzdyGBdEOzahCgiprTcvfQx22leg545giu28y1PyiXNJZHryh65giuFEJRvnBWnHuHJ4OvxiU34t4GBcnd4GZa5jQvOQq9Y2EHMFdK1x5p0jpiunfWIfJSbmWTbpeg545giu28eAtXqIphNdJWoez)OkBObGRPqHsoQtzp01n9LJYHu)xONBGq1uC0PvDFOoL9qxxO53az9v(dDYdcPchXrRUqwfhDtCuNYEORlunfWIfJSbmWTbp0mGdodKNOwHQc1lB7fcJC8CdekBEccPyiXNJZHryhISFuLnKBxudmnKBjh1PSh66M(YbRD7IAGj4adcycnd4GZa5jQvOQq9Y2EHMFdK1x5pKvNLdHEUbcvtXrNw19H6u2dDDAvxtNLdHuHJ4OvxiRIJUjoQtzp01LnpbrPyiXNJZHryhISFuLneUMcfk5EJpXO53bLAQesfoIJwDH4EJpHR5ZSHMFdK1x5p0jpiegzd66cje65giuFEJRvnBnFMvRA9wqVcP63XeYiBqxhlleAgWbNbYtuRqvH6LT9crks9JroqfqWNjSdvtbSyXiBadCByhcJC8CdekBEc9sXqIphNdJWoez)OkBOpu4dmkoohcPchXrRUqf4UbMyuKwSHMFdK1x5p0jpiegzd66cje65gieRWDdOvnPiTy1QwVf0RqQ(DmHmYg01XYcHMbCWzG8e1kuvOEzBVq1ualwmYgWa3g2HWihp3aHYMneRck4A4ByNnb]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170216.1, [[d8cmcaGEQsAxOuBJQQzsvWSP4Msv3Ms7uk7LSBe7hs1WePFRQHsvQbdfgUkCqu4yi1cHQwQiSyKSCrTiQkpfSmu1ZrLjsvutfknzvA6cxeQCzLRtvIntvOTlv6ZOOhdXHL8nPIrdfDEv0jHe)fs60u5Euf5Hqkpte9AuYIwyfGJuuMDfEbTYobaopGog4mZosug0XW78qElvfc888y5fti8csmZkUPgFkDNuEAE20cGJH4kJZRv4EIA8(5fWajCpHtyvJwyfGJuuMDfEbas2DecINjtZyF8H7jCcyq5mU4uWXhUNiafY1HuXNfqEYe0k7e49hUNiGrMjNaszNN8DxDnNOYmxiZNGeZSIBQXNs7NUd70KcqdZHWQ)7o7iHOe0)3wzNaF3vxZjQmZfY8PqnEHvaosrz2v4f0k7eG9JzrhJ(Ilw(uadkNXfNcIpMfvBXflFkiXmR4MA8P0(P7WonPauixhsfFwa5jtaAyoew9F3zhjeLG()2k7eOqTKcRaCKIYSRWlOv2jaIpBzTDSSaguoJlofWfF2YA7yzbjMzf3uJpL2pDh2PjfGc56qQ4ZcipzcqdZHWQ)7o7iHOe0)3wzNafkeaiz3riqHea]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170216.1, [[dWdefaGEsu7svvzBqkZuvKoSkZwu3Mu3eiUgq5BquoVaTtr2RYUrA)u(jevdJqJtviUSKHsudMQHlOdQQCub0Xa5CQcYcbQwkbSyHA5s1db4POwgb9CsyIqQMkGMmez6qDrHCvvb8mG01b1gjqpMK2SQkBhs(OQq9zimnsKVRkIrQkKwNQQmAvPXlaNuvu3IiNgX9ufuVwvGwRQQQFlLh0aog5OQE(cU4XbcxWfsMlyJInNjkxlbjCSCNOVEqZfSrXMZeLRLGeowUt0xpO5aUqmPrn)dUFJzCRRJ7ekIQpUx5XaIsaJey8dOOmNdRCwW8P4DXJ5WtLqrSeyJLrfzUK5Ox)o4mEGpwgvK5sMdOPJp8IhdYfardRnhirxlbQ44aHl4sXaUe0aooIEX5cPb(4pvmPrn)Pef4XmrdW8i67rvlDrX)zEyVuB64dpoD6Amt0ampI(Eu1sxu8FMh2l1Mo(WJfOY1POwsOieAqIIGoMv7Kq8ymrxpS4WljCahhrV4CH0aF8NkM0OM)uIc8yMObyEe99OQLUO4)mhP63bNXJtNUgZenaZJOVhvT0ff)N5iv)o4mESavUof1scfHqdsue0HhESmkzZLmh963bNXM)LdFVLGglJs2CjZb00XhEXJLrjBUK5Ox)o4mEGpo4eu6reFiHkjIgeeYavuOqKjUFskb24awscT)bjckyqGHMqWkjrrWglqLRtrTKqriKjcbj8FqJdeUGlZ)YeeuDrXJvhlJkYCjZb00Xh28VC47Te0yzuYMlzoWRJOWM)LdFVLGglJs2CjZb00Xh28VC47Te0ywTtcXJhlJkYCjZrV(DWzS5F5W3BjOX)V10lbb2yMqrKlZLmhecLOH1ljoMdRCwW8P41CaTCRpGJVLGg3xcAmILGghVe0WJb0cdAoW24i67rvlDrXMZekICjb86ik84pyCZCjZb5cGOH1ljooq4cUmhDsVuXKgDSap)4hf4y0RFhCgpWhhiCbxiz(ZQnQ5mr5AjLehlJkYCjZbEDef28VC47Te04i6fNlKg4J)GXnZLmhecLOH1ljowUt0xpO5aUqmPrhROFysB8hYJmxYCqiuIgwVeOJzcfrUmxYCqUaiAy9sqJbE5IIn)X9gC4sIJFwTrvyo)2EcDjLglWrruMd4TuFqcfX4lMKj4GJL7e91dA(ZQnQ5mr5AjLehlyJIh)1jx28017TNmoD6ACe99OQLUOyZL7e91dowgLS5sMd86ik8IhZHLk5YeLpmPrxsiAGowgvK5sMd86ik8Ih)PIjnQ5aUqmPrvmWh)H8iZLmhKlaIgwVK4WBa]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170216.1, [[dWt8eaGEIu7svL2MQGzkLOdRYSf1Tj5MQQ6Xe13KsQZdk2Pq7vz3iTFk)uvfdtGXjLqNgQHsObt1Wf0bfPJkcogbNtkjleiwkO0ILILd4HQkpf1YquphbtKimvGAYaPPd5IKYvfHQNjIUoiBeHADsPAZQI2oI8rPu8zq10is(UuknsriUSKrRknEIOtQk0TivxdHCpri9ArOSwPe8BP6jmWJtaQGkqnN4ofzoJLUwuG8yrsIMRBo4daEHwZyraS6aGX8VleH7uZtHaUXmQdOAaWu4fWyGkp(tlcwd2XjoHYCoSYzIZhH31mwKKM56Md(aGxO1mwKKM56Mlr98GYObYyrsAMRB(xx1CO1m()jjwbPmhmwvlMmyCcqfuryGxuyGhRrVMCb6azCQmc3PM3smb0ygR(mxJ(Eu5svuu7MhcuYDvZHghpvnMXQpZ1OVhvUuff1U5HaLCx1COXWw56iulsoqGOGh(LmzHXSmaoengHvvIgm0IKh4XA0RjxGoqgNkJWDQ5TetanMXQpZ1OVhvUuff1U5GwppOmAC8u1ygR(mxJ(Eu5svuu7MdA98GYOXWw56iulsoqGOGh(LmzHHgAmldGdrJjGPWZ1yrsIMRB(xx1CO1mwKKO56Mlr98GYObYyygX6pquqRecAvYwNmzGuTyYG9uxkIgN(JM56M))KeRGulgmg2kxhHArYbcToqqG8VcJtaQGkZtZy4uvrrJLhlssZCDZ)6QMdzEAo89wuySijrZ1nh8baVqMNMdFVffgZyk8CzUU5)XuScsTyYXsUyW4uzeUtn)7cr4oLWazmhEYyk8fjASiawDaWyoXDkYCglDTOa5XCyLZeNpcVM)1ZDGbE8TOW4MffgdFrHXalkm04VEimMdUpwJ(Eu5svuK5P)OnweaRoaym)r5o1CglDTOubJtaQGkZLaduYiCNog2hBtIaEC8u1yn67rLlvrrMN(J24eGkOcuZFuUtnNXsxlkvWyI7u04ua8LnpEaa92owJEn5c0bYyoSKXxgl9HWD6IKFi5yypk8Y8V3soXWu4JVgCgJGzC6pAMRB(FmfRGulMC8JYDkbZ53EBPlk1yWxUOiZBdqhkCXGXmMcpxMRB()tsScsTyWyraS6aGX8VleH70XeaoeUpofc1nx38)NKyfKAXGXIK0mx3CWha8czEAo89wuySe1ZdkJgiJfjjAUU5FDvZHmpnh(ElkmUf6D1IcenwKKO56Mlr98GYiZtZHV3IcJfjPzUU5suppOmY80C47TOW4uiu3CDZ)JPyfKAXKdTb]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170216.1, [[dSt4eaGEIk7IOO2MkKzcPmBuDyLUPQKxluPUnPUMqvTtb7vA3kSFQ(PkuddLgNqvCEHYqHyWugUqoOI6OevDmuCoIISqvPwkKQfRilxv9qI0trESQ45qPjQIAQazYKGPd6Iq1vfQWLfDDaBes6Bef2SkY2bQpQc4ZqX0ik9DvGgPqL8miXOjrJNe6KQGUfjDAc3tOIwgrSwHQ0VvPltbv6yW5NVX6uj5bsGub3q9oGUrc5YgyKuc5l07pMBOEhq3iHCzdmskH8f69hZnPBeuChUnd83sL(jVKu8aiC0lfhyt3OOKZrLVyv2Psu0(igyAi(LqaJ7MQBNZtlah23LqaJ7MQBsV6Pf2PsVwffAaTBGe6SbuyljpqcKylOgykOs4JDINk03LMFGI7Wn0eyHLiC0CdNN6CaxUBi)85QNwyPWQZseoAUHZtDoGl3nKF(C1tlSe6jpxSzdsyzoIHLfLs0Zxeblbf6mozlSbjfuj8XoXtf67sZpqXD4gAcSWseoAUHZtDoGl3TZ5PfGdlfwDwIWrZnCEQZbC5UDopTaCyj0tEUyZgKWYCedllkLONVicwQWclHagXnv3oNNwao0TzEKYTbMsiGrCt1nPx90c7ujeWiUP62580cWH9DPyfv14HvMKil7rmmYafwjsKbBpPkB8lnFmUBQU9AvuOb0nWwc9KNl2SbjSmYGvclJmZusEGeiDBMlWm05aw6PecyC3uDt6vpTq3M5rk3gykHagXnv3aTFmj0TzEKYTbMsiGrCt1nPx90cDBMhPCBGPKInWwcbmUBQUDopTaCOBZ8iLBdmLONVicwQejgy4PBQU9smeAaDdSLOOKZrLVyv6M0l)(lOsBdmLMAGPeMgyk9BGPWssVrXCd0Teop15aUC3MpgV0ma86MQBVwffAaDdSLKhibs3ol(5duChLq)WdexGkndaVUP62lXqOb0nWwsEGeivWTdFUd3iHCzdYYwcbmUBQUbA)ysOBZ8iLBdmLWh7epvOVlH8f69hZnPBeuChLG7htcXwIedm80nv3ETkk0a6gyknFmUBQU9smeAaDdOuc0YZb0Td8VarnWw6WN7aRBKY7bhniBj03bM0nPkZN4wmWuANeCbmwjKVqV)yUD4ZD4gjKlBqw2sHvNLW5PohWL7gYxO3FSsOEhWsZFXYDlS))9GLoNNwaoSVlHagXnv3aTFmjStLOO8rSCHCluChni5ijLqaJ7MQBG2pMe2PsZpqXD4M0nckUdS9DP49E1nGcBHT]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170216.1, [[dSZ7eaGEsODPKOxlKQzcIMnupwjUPQIBtQVPkvUgQu2PG9kTBr2pLFsImmImouPQZRkzOO0GPA4c1bfLJkeDmu15esAHQkTuujlwuTCGEir5Pildv8Cu0evfMQQQjtIA6qUiOUQQu1LvCDaBeeEMQOnRKA7G0hvs4ZOW0ecFxiLrkKW2uLYOjQgpj4KkjDls60eUhQu5WQSwHe9BL6Y3)skbDaX3RMxksGbyu2Ci2jK5KqXPbEoLybf6d8L5qStiZjHItd8CkXck0h4lZLDXiXozEga4vcc8PhZj57LOxcCWLKbh(H5Q07zoMtXdgdb(ykV5LO4BrKy0a3kXcf2CvZFmRpamQFlXcf2CvZLT15hQ5L(Cki0aAZ)f6PHNsLIeyagM9Vb((xcoD54r5(Tu2csStMdPGjQebdP5W4rpj0HnNfCw268dvkC6PebdP5W4rpj0HnNfCw268dvIRbphZPbos8VXlj9SeTakIrLqc9WDsf1aN(xcoD54r5(Tu2csStMdPGjQebdP5W4rpj0Hn)XS(aWOsHtpLiyinhgp6jHoS5pM1hagvIRbphZPbos8VXlj9CL8LOfqrmQurfvIwafXOsmfjg4PeluwZvnx2wNFOMxIfkR5QM)ywFayu)w6vHq9nUjfvEPO(8DpFkfb3)uQRvJGBLuObPsCn45yonWrI)DsCK4xjFPibgGX8mSGrspjuPLszaOT5QM)5uqOb0nivIfuOpWxMV6YozojuCAicPsKiXapMRA(hrsOb0nWPuuU36gEkvkBbj2jZLDXiXoXSFlXcf2CvZ)pqgdQ5LO4zrCyHIhsStnW5noLO4bJHaFmLBUSnEd2)sxd8LaBGVeJg4lL3aFrLKTJFz()UemE0tcDyZZucUeluwZvn))azmOMxksGbym)HaCwqIDQexRUIO4Vu40tjy8ONe6WMNPeCPibgGrzZxDzNmNekoneHuji2juPmqXHnpCGG7OvcoD54r5(TeluwZvn))azmiZZWXYVg4lX1LymMlt(SeDrIrPlxGfOxLYuc2CvZ)iscnGUboLwDzNyAojFhTudru6)Wtcz(ka3aXnivIejg4XCvZ)Cki0a6gKkXck0h4lZLDXiXovc8qIDPma02CvZ)iscnGUboLyHcBUQ5)hiJbzEgow(1aFPhZ6daJ63sSqHnx1CzBD(Hmpdhl)AGVeluwZvnx2wNFiZZWXYVg4lXcL1CvZFmRpamY8mCS8Rb(sSqHnx18hZ6daJmpdhl)AGVuMsWMRA(NtbHgq3GurT]] )

end
