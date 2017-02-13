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


    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170112.1, [[dauSDaqiPewerfAtqsJcsCkLQEfukyxqmmQ0XOILrKEgfzAOuCnOuABkfFtPY4iQKZrurRJOcyEOu6EqPAFevDqOWcLs9qLstKOc6IqrBKOsnsOuiNeQQzkLOBIs2jkgkrfOLcL8ustfQYxHsr7v1FHudgLQdlSyfESsMmLUmyZsLplvnAP40i9Ak0SjCBQA3s(nIHtuwoQEUIMUORdv2of8DPKopf16HsHA(er7Ni8DoExXSIHaSV9vMWdxvQFReSJz1e1c8qLYbKGDl0f4e5vvgSOHGInoskPoJ0nMUIfiGycNrQRZoxhhhetx1fNklVEfJvsj184DgNJ3vmRyia7BFLj8WvSjTSsWU2ab)QU4uz51K03laeALaNJtwoVIfiGycNrQRZgNDiUMUIXGkOP5RTsll6zde8R4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNr6X7kMvmeG9JRmHhUInc4e60FvxCQS8As67faYIqewsR1evuYG3djsdeISbr2kzRuSvsjtQhK3fbBDD3FflqaXeoJuxNno7qCnDfJbvqtZxhccXkWnZR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNX0X7kMvmeG9TVYeE4QCd8qib7QmkNMx1fNklVMK(EbGSieHL0AnrfLwe8K2fRejeYAc0TseDi8OmkVRKsIIpaXm5epYchNdvkp2L6I6IqewsRfYIhZg0cAFtw0QhHd(Gwt2I9(LD)(RybciMWzK66SXzhIRPRymOcAA(AhWdb6PmkNMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppdBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Q)QU4uz51GN0UyLiHqwtGUvIOdHhLr5DrvghmGUFzrCq6aEiqpLr508kwGaIjCgPUoBC2H4A6kgdQGMMVU4XSbTG23KfT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgS94DfZkgcW(2xzcpCTnWNa3iT6VQlovwEnj99cazriclP1AIkkdCDDiXCbLnQfGGtMKs2ImeqLiXCbLnQfGavmeGvsjfGbqWwhx39xXceqmHZi11zJZoextxXyqf0081bWNa3iT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEMnhVRywXqa23(kt4HRTfeIvc2LBCCZx1fNklVMK(EbGSieHL0AnVIfiGycNrQRZgNDiUMUIXGkOP5RdbHyr3HJB(k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95z2D8UIzfdbyF7R6ItLLxtsFVaqKrskPMOIshWdb6PmkNMiCWh0Akp2kPKzW7HejPEaDsqBPaBX(g39xXyqf008vzKKsQR4xw6ksc)Ark4kt4HRYbjjLuxXG3pVwHhWUCugNiivpyrlJ0kWLJxXceqmHZi11zJZoextx32alJSigapu5hxzrSmHhUkhLXjcs1dw0YiTcC54ZZixhVRywXqa23(kt4HRTj4ewG3rN5vDXPYYRdCDDidcoHf4D0zIWbFqRjB7xwjLefFaIzYjEKfoohQKTyhBDrnwj1aGgkWtHP8y30(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJCE8UIzfdbyF7RmHhU2MGtybEhDMsWoko7VQlovwEDGRRdzqWjSaVJoteo4dAnzB)YkPKOSAcEpmr3XJvsjviK3bzh2IQpaXm5epYchNdvYwSpHmPv)ezqWjSaVJot0(aeZKt8OgRKAaqdf4PWKTyx6(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJJ7X7kMvmeG9TVYeE4kwKLXbnb(vDXPYYRziGkrerzNcQfqGkgcWI6axxhIik7uqTach8bTMSTFzVIfiGycNrQRZgNDiUMUIXGkOP5RCYY4GMa)k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zCCoExXSIHaSV9vMWdxLBCCZsWoPtc2XGYVQlovwETfjDzKw9O6dqmtoXJSWX5qLYlv6vSabet4msDD24SdX10vmgubnnFTdh3mAsh6GYVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghPhVRywXqa23(kt4HRYnNmZbpk7vDXPYYRziGkrAcQyMeUhbQyialQdCDDiDCYmh8OSiCWh0AYwomW11HUvAzjTEflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghthVRywXqa23(kt4HRYTi8qsQECWvDXPYYRdCDDiDIWdjP6XbiCWh0AYwomW11HUvAzjTkPKOSieHL0AHyjep6wPLDIWbFqRjB3G6axxhsNi8qsQECach8bTMSLn7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJdBoExXSIHaSV9vMWdxLdjeVeSJnPLDEflqaXeoJuxNno7qCnDfJbvqtZxTeIhDR0YoVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghS94DfZkgcW(2xzcpCDlpMnsWElP9nzrREjyhfN9x1fNklVMHaQezXJzdT6rptc3JavmeGf1yLudaAOapfMYJDtOIslYqavI0euXmjCpcuXqawjLCGRRdPJtM5GhLfHd(Gwt57x29xXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4S54DfZkgcW(2xzcpCfZGNnqjb7QmQr4kwGaIjCgPUoBC2H4A6kgdQGMMVcbpBGc9ug1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8mo7oExXSIHaSV9vMWdxBjTVjlA1lb7TjI8QU4uz5vuYqavIqma8vtW7beOIHaSO6dqmtoXJSWX5qLYJD24IAlYqavI0HJBgnPdDq5iqfdby3lPKOKHaQeHya4RMG3diqfdbyrndbujshoUz0Ko0bLJavmeGfvFaIzYjEKfoohQuE24In0rc0YcRLw97VIfiGycNrQRZgNDiUMUIXGkOP5RcAFtw0Qh9GiYR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNXrUoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rr6(R6ItLLxh466qw8y2Gwq7BYIw9iCWh0AY2(Lf1yLudaAOapfMYJDPxXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4iNhVRywXqa23(kt4HRytAzNKQ)kwGaIjCgPUoBC2H4A6kgdQGMMV2kTSts1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDpExXSIHaSV9vMWdxXyUGYg1cUQlovwEnj99cazriclP1AIkkdCDDiZKW9doT6bocoz7VIfiGycNrQRZgNDiUMUIXGkOP5RXCbLnQfCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDoExXSIHaSV9vMWdxXM0Yoto1iCvxCQS86axxhYmjC)GtREGJGtgQOGsgcOsKoCCZOjDOdkhbQyialQ(aeZKt8ilCCouP8yxQl2qhjqllSwA1VxsjrPfziGkr6WXnJM0HoOCeOIHaS73FflqaXeoJuxNno7qCnDfJbvqtZxBLw2zYPgHR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrQ0J3vmRyia7BFLj8WvnjC)m5uJWvDXPYYRdCDDiZKW9doT6bocozOIckziGkr6WXnJM0HoOCeOIHaSO6dqmtoXJSWX5qLYJDPUydDKaTSWAPv)EjLeLwKHaQePdh3mAsh6GYrGkgcWUF)vSabet4msDD24SdX10vmgubnnFDMeUFMCQr4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zKA64DfZkgcW(2xzcpCTLHHqc2BzmBUQlovwEndbujsdjr3eLfbQyialQdCDDinKeDtuweCYUIfiGycNrQRZgNDiUMUIXGkOP5RIWqGweZMR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrkBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rX0(R6ItLLxJvsnaOHc8uykp2zZvSabet4msDD24SdX10vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msX2J3vmRyia7BFLj8WvSjTSZKtncsWoko7VIfiGycNrQRZgNDiUMUIXGkOP5RTsl7m5uJWv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZiDZX7kMvmeG9TVYeE4QMeUFMCQrqc2rXz)vDXPYYRziGkriga(Qj49acuXqawuxeIWsATqe0(MSOvp6brKiCWh0AY2(LfvFaIzYjEKfoohQuE5Y9kwGaIjCgPUoBC2H4A6kgdQGMMVotc3pto1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8ms3D8UIzfdbyF7RmHhUQjH7NjNAeKGDuKU)QU4uz51meqLiD44Mrt6qhuocuXqawu9biMjN4rw44COs5zJl2qhjqllSwA1JkklcryjTwicAFtw0Qh9Giseo4dAnLVFzLuYwKHaQeHya4RMG3diqfdby3FflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY1X7kMvmeG9TVYeE4QMeUFMCQrqc2rX0(R6ItLLxBrgcOseIbGVAcEpGavmeGf1wKHaQePdh3mAsh6GYrGkgcWEflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY5X7kMvmeG9TVQlovwEffuIvsnaOHc8uykVJKsMHaQezXJzdT6rptc3JavmeGvsjZqavImi4ewG3rNjcuXqa29O2IjKOhKc3ejPa3rorZgzl5D3lPKDapeONYOCAIWbFqRP8y7vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbxzcpCDlpMnsWElP9nzrREjyhf2S)kwGaIjCgPUoBC2H4A6Q2qALfXs7OaF(2x32alJSigapu5hxzrSmHhU(8mMCpExXSIHaSV9vMWdxLBozMdEuwjyhfN9x1fNklVMHaQePjOIzs4EeOIHaSOoW11H0XjZCWJYIWbFqRjBzdICDflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtohVRywXqa23(kt4HRTmmesWElJzJeSJIZ(R6ItLLxZqavI0HJBgnPdDq5iqfdbyrndbujcXaWxnbVhqGkgcWIkktirpifUjssbUJCIMnYwY7IQpaXm5epYchNdvkp2Ll39xXceqmHZi11zJZoextxXyqf008vryiqlIzZv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZys6X7kMvmeG9TVYeE4AlddHeS3Yy2ib7OiD)vDXPYYRziGkr6WXnJM0HoOCeOIHaSO2ImeqLiedaF1e8EabQyialQOmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yhBnT)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtMoExXSIHaSV9vMWdxBzyiKG9wgZgjyhft7VQlovwEfLwmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yFczsR(jIimeOfXSbTpaXm5e)EjLeLwKHaQePdh3mAsh6GYrGkgcWI6es0dsHBIKuG7iNOzJSL8UO6dqmtoXJSWX5qLYJD24U)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtS54DfZkgcW(2xzcpCvUfHhss1JdKGDuC2FvxCQS86axxhsNi8qsQECach8bTMSLniY1vSabet4msDD24SdX10vmgubnnFTteEijvpo4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zmHThVRywXqa23(kt4HRkUYcCA1FflqaXeoJuxNno7qCnDfJbvqtZxN4klWPv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZyAZX7kMvmeG9TVYeE4kwKLXbnbUeSJIZ(RybciMWzK66SXzhIRPRymOcAA(kNSmoOjWVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgt7oExXSIHaSV9vMWdxLBr4HKu94ajyhfP7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJj564DfZkgcW(2xzcpCTnbNWc8o6mLGDuKU)kwGaIjCgPUoBC2H4A6kgdQGMMVoi4ewG3rN5v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZNxLdHUaNiF7N)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170112.1, [[dedXbaGEukTlIyBIsZuLKztYnrvUTk2PI2l1Uf2VizyIQFlzOOegSiA4qCqc6yQYcjWsvjwmrTCv1dfHNcEmKwhkjteLOPsitwHPl1fjupJiDDuk2SkP2okvxg5Wq9zu8DurltL68OsnAs55KQtIk8nrXPv6EOKArOQ(Ri1RrLSFwKbXbwwrdlWWeFidWEsKkP4qdhO0HIMvPsI8j06iJBdacHUy1YwCVv45DwPgUqkcRtEEN)YK)EpjsnaO)fPnyqiAVvOBrE(SidIdSSIgwGba9ViTHUyyuKeKQ3k0niuEvBZTbKQ3kmWrmwuCxFdrfKHj(qgyr1Bfge(z0ne4dXA(i)svbdnsJuCsF(gUqkcRtEEN)Y(YijxQHeAekx8k2PdfTLnWRgt8HmWh5xQkyOrAKIt6Z3TN3wKbXbwwrdlWWeFidxTmADSbtQKG2sQHHlKIW6KN35VSVmsYLAqO8Q2MBdQLrRJnysRRTKAyGJySO4U(gIkidj0iuU4vSthkAlBGxnM4dzWTBdSKUgZgvBbUTb]] )

    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170212.1, [[dauSDaqiPewerfAtqsJcsCkLQEfukyxqmmQ0XOOLrKEgvyAOuCnOuABkfFtPY4iQKZrurRJOcyEOu6EqPAFevDqOWcLs9qLstKOc6IqrBKOsnsOuiNeQQzkLOBIs2jkgkrfOLcL8ustfQYxHsr7v1FHudgLQdlSyP6XkzYu6YGnRGpRqJwkonsVMcnBc3MQ2TKFJy4eLLJQNROPl66qLTtbFxkPZtfTEOuOMpr0(jcFZJ3vmROla7BFvoegcCI8TVYeE4Qs9BLGDmRMOwGhQuoGeSBHHaNiVIfiGycNrQR5oxttPiMx1fNklVEfJvsj184DgZJ3vmROla7BFLj8WvSjTSsWU2ab)QU4uz51KmokaeALaNJtwoVIfiGycNrQR5gZDiUoUIrNkOPZRTsll6zde8R4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNr6X7kMv0fG99RmHhUInc4e60FvxCQS8AsghfaYIqewsR1evuYGpcjsdeISbr2kzRuSvsjtQhK3fbBDD3FflqaXeoJuxZnM7qCDCfJovqtNx7ccXkWnZR4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNXXX7kMv0fG9TVYeE4QCd8qib7QmkNMx1fNklVMKXrbGSieHL0AnrfLwe8KoeRejeYAc0Tsedi8OmkVRKsIIpaXm5epYchNdvkp2L6I6IqewsRfYIhZg0c6ytw0AeHd(Gwt2I9XLD)(RybciMWzK6AUXChIRJRy0PcA686aWdb6PmkNMxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppdBoExXSIUaSV9vMWdx3YJzJeS3s6ytw0A8QU4uz51GN0HyLiHqwtGUvIyaHhLr5DrvghmGECzrmrgaEiqpLr508kwGaIjCgPUMBm3H464kgDQGMoVU4XSbTGo2KfTgVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgS94DfZk6cW(2xzcpCTnWNa3iTgVQlovwEnjJJcazriclP1AIkkDCddiXCbLnQfGGtMKs2ImeqLiXCbLnQfGav0fGvsjfGbqWwtx39xXceqmHZi11CJ5oexhxXOtf0051oWNa3iTgVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEMnhVRywrxa23(kt4HRTfeIvc2LBCCNx1fNklVMKXrbGSieHL0AnVIfiGycNrQR5gZDiUoUIrNkOPZRDbHyrpGJ78k(LLUIKWVwKcUUTbwgzrmaEOY3VYIyzcpC95z2D8UIzfDbyF7R6ItLLxtY4OaqKrskPMOIYaWdb6PmkNMiCWh0Akp2kPKzWhHejPEaDsqBPaBX(g39xXOtf005vzKKsQR4xw6ksc)Ark4kt4HRYbjjLuxXGpoVwHhWUCugNii1iyrlJ0kWLJxXceqmHZi11CJ5oexhx32alJSigapu57xzrSmHhUkhLXjcsncw0YiTcC54ZZixhVRywrxa23(kt4HRTj4ewGpqN5vDXPYYRDCddiDcoHf4d0zIWbFqRjBhxwjLefFaIzYjEKfoohQKTyhBDrnwj1aGgkWtHP8y3X(RybciMWzK6AUXChIRJRy0PcA68ANGtyb(aDMxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJCE8UIzfDbyF7RmHhU2MGtyb(aDMsWokM7VQlovwETJByaPtWjSaFGoteo4dAnz74YkPKOSAc(imrpWJvsjviK3ezh2IQpaXm5epYchNdvYwSpHmP14ePtWjSaFGot0(aeZKt8OgRKAaqdf4PWKTyx6(RybciMWzK6AUXChIRJRy0PcA68ANGtyb(aDMxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJP7X7kMv0fG9TVYeE4kwKLXonb(vDXPYYRziGkrerzNcQfqGk6cWIAh3WaIik7uqTach8bTMSDCzVIfiGycNrQR5gZDiUoUIrNkOPZRCYYyNMa)k(LLUIKWVwKcUUTbwgzrmaEOY3VYIyzcpC95zmnpExXSIUaSV9vMWdxLBCCNsWozqc2XGYVQlovwETfjDzKwJO6dqmtoXJSWX5qLYlv6vSabet4msDn3yUdX1Xvm6ubnDEDah3jAYa6GYVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgtPhVRywrxa23(kt4HRYnNmZopk7vDXPYYRziGkrAcQyMeUhbQOlalQDCddidCYm78OSiCWh0AYwo0XnmGUvAzjTEflqaXeoJuxZnM7qCDCfJovqtNxh4Kz25rzVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgthhVRywrxa23(kt4HRYTi8qsQrCWvDXPYYRDCddidIWdjPgXbiCWh0AYwo0XnmGUvAzjTkPKOSieHL0AHyjep6wPLDIWbFqRjB3GAh3WaYGi8qsQrCach8bTMSLn7VIfiGycNrQR5gZDiUoUIrNkOPZRdIWdjPgXbxXVS0vKe(1IuW1TnWYilIbWdv((vwelt4HRppJjBoExXSIUaSV9vMWdxLdjeVeSJnPLDEflqaXeoJuxZnM7qCDCfJovqtNxTeIhDR0YoVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgtS94DfZk6cW(2xzcpCDlpMnsWElPJnzrRrjyhfZ9x1fNklVMHaQezXJzdTgrptc3Jav0fGf1yLudaAOapfMYJDhOIslYqavI0euXmjCpcurxawjLSJByazGtMzNhLfHd(Gwt5hx29xXceqmHZi11CJ5oexhxXOtf0051fpMnOf0XMSO14v8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZyU54DfZk6cW(2xzcpCfZGNnqjb7QmQr4kwGaIjCgPUMBm3H464kgDQGMoVcbpBGc9ug1iCf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8mM7oExXSIUaSV9vMWdxBjDSjlAnkb7TjI8QU4uz5vuYqavIqma8vtWhbeOIUaSO6dqmtoXJSWX5qLYJD24IAlYqavImGJ7enzaDq5iqfDby3lPKOKHaQeHya4RMGpciqfDbyrndbujYaoUt0Kb0bLJav0fGfvFaIzYjEKfoohQuE24Inmqc0YcRLwJ7VIfiGycNrQR5gZDiUoUIrNkOPZRc6ytw0AeDNiYR4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNXuUoExXSIUaSV9vMWdx3YJzJeS3s6ytw0Auc2rr6(R6ItLLx74ggqw8y2GwqhBYIwJiCWh0AY2XLf1yLudaAOapfMYJDPxXceqmHZi11CJ5oexhxXOtf0051fpMnOf0XMSO14v8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZykNhVRywrxa23(kt4HRytAzNKA8kwGaIjCgPUMBm3H464kgDQGMoV2kTStsnEf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8msDpExXSIUaSV9vMWdxXyUGYg1cUQlovwEnjJJcazriclP1AIkkDCddiZKW9DoTgbocoz7VIfiGycNrQR5gZDiUoUIrNkOPZRXCbLnQfCf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8msnpExXSIUaSV9vMWdxXM0Yoto1iCvxCQS8Ah3WaYmjCFNtRrGJGtgQOGsgcOsKbCCNOjdOdkhbQOlalQ(aeZKt8ilCCouP8yxQl2WajqllSwAnUxsjrPfziGkrgWXDIMmGoOCeOIUaS73FflqaXeoJuxZnM7qCDCfJovqtNxBLw2zYPgHR4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNrQ0J3vmROla7BFLj8WvnjC)m5uJWvDXPYYRDCddiZKW9DoTgbocozOIckziGkrgWXDIMmGoOCeOIUaSO6dqmtoXJSWX5qLYJDPUyddKaTSWAP14EjLeLwKHaQezah3jAYa6GYrGk6cWUF)vSabet4msDn3yUdX1Xvm6ubnDEDMeUFMCQr4k(LLUIKWVwKcUUTbwgzrmaEOY3VYIyzcpC95zK644DfZk6cW(2xzcpCTLHHqc2BzmBUQlovwEndbujsdjr3eLfbQOlalQDCddinKeDtuweCYUIfiGycNrQR5gZDiUoUIrNkOPZRIWqGweZMR4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNrkBoExXSIUaSV9vMWdx3YJzJeS3s6ytw0Auc2rXX(R6ItLLxJvsnaOHc8uykp2zZvSabet4msDn3yUdX1Xvm6ubnDEDXJzdAbDSjlAnEf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8msX2J3vmROla7BFLj8WvSjTSZKtncsWokM7VIfiGycNrQR5gZDiUoUIrNkOPZRTsl7m5uJWv8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZiDZX7kMv0fG9TVYeE4QMeUFMCQrqc2rXC)vDXPYYRziGkriga(Qj4JacurxawuxeIWsATqe0XMSO1i6orKiCWh0AY2XLfvFaIzYjEKfoohQuE5Y9kwGaIjCgPUMBm3H464kgDQGMoVotc3pto1iCf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8ms3D8UIzfDbyF7RmHhUQjH7NjNAeKGDuKU)QU4uz51meqLid44ortgqhuocurxawu9biMjN4rw44COs5zJl2WajqllSwAnIkklcryjTwic6ytw0AeDNiseo4dAnLFCzLuYwKHaQeHya4RMGpciqfDby3FflqaXeoJuxZnM7qCDCfJovqtNxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgPY1X7kMv0fG9TVYeE4QMeUFMCQrqc2rXX(R6ItLLxBrgcOseIbGVAc(iGav0fGf1wKHaQezah3jAYa6GYrGk6cWEflqaXeoJuxZnM7qCDCfJovqtNxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEgPY5X7kMv0fG9TVQlovwEffuIvsnaOHc8uykVPKsMHaQezXJzdTgrptc3Jav0fGvsjZqavI0j4ewGpqNjcurxa29O2IjKO7Kc3ejPa3uorZgzl5D3lPKdapeONYOCAIWbFqRP8y7vm6ubnDEDXJzdAbDSjlAnEf)Ysxrs4xlsbxzcpCDlpMnsWElPJnzrRrjyhf2S)kwGaIjCgPUMBm3H464Q2qALfXshOaF(2x32alJSigapu57xzrSmHhU(8moCpExXSIUaSV9vMWdxLBozMDEuwjyhfZ9x1fNklVMHaQePjOIzs4EeOIUaSO2XnmGmWjZSZJYIWbFqRjBzdICDflqaXeoJuxZnM7qCDCfJovqtNxh4Kz25rzVIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEghMhVRywrxa23(kt4HRTmmesWElJzJeSJI5(R6ItLLxZqavImGJ7enzaDq5iqfDbyrndbujcXaWxnbFeqGk6cWIkktir3jfUjssbUPCIMnYwY7IQpaXm5epYchNdvkp2Ll39xXceqmHZi11CJ5oexhxXOtf005vryiqlIzZv8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZ4q6X7kMv0fG9TVYeE4AlddHeS3Yy2ib7OiD)vDXPYYRziGkrgWXDIMmGoOCeOIUaSO2ImeqLiedaF1e8rabQOlalQOmHeDNu4Mijf4MYjA2iBjVlQ(aeZKt8ilCCouP8yhBDS)kwGaIjCgPUMBm3H464kgDQGMoVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEghooExXSIUaSV9vMWdxBzyiKG9wgZgjyhfh7VQlovwEfLwmHeDNu4Mijf4MYjA2iBjVlQ(aeZKt8ilCCouP8yFczsRXjIimeOfXSbTpaXm5e)EjLeLwKHaQezah3jAYa6GYrGk6cWI6es0DsHBIKuGBkNOzJSL8UO6dqmtoXJSWX5qLYJD24U)kwGaIjCgPUMBm3H464kgDQGMoVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ89RSiwMWdxFEghS54DfZk6cW(2xzcpCvUfHhssnIdKGDum3FvxCQS8Ah3WaYGi8qsQrCach8bTMSLniY1vSabet4msDn3yUdX1Xvm6ubnDEDqeEij1io4k(LLUIKWVwKcUUTbwgzrmaEOY3VYIyzcpC95zCGThVRywrxa23VYeE4QIRSaNwJxXceqmHZi11CJ5oexhxXOtf0051jUYcCAnEf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(8mo2C8UIzfDbyF7RmHhUIfzzSttGlb7OyU)kwGaIjCgPUMBm3H464kgDQGMoVYjlJDAc8R4xw6ksc)Ark462gyzKfXa4HkF)klILj8W1NNXXUJ3vmROla7BFLj8Wv5weEij1ioqc2rr6(RybciMWzK6AUXChIRJRy0PcA686Gi8qsQrCWv8llDfjHFTifCDBdSmYIya8qLVFLfXYeE46ZZ4qUoExXSIUaSV9vMWdxBtWjSaFGotjyhfP7VIfiGycNrQR5gZDiUoUIrNkOPZRDcoHf4d0zEf)Ysxrs4xlsbx32alJSigapu57xzrSmHhU(85vvgSOHGInoskPoJ0noE(da]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170212.1, [[dedXbaGEukTlc12ePMPcLzt0njWTvQDQK9sTBH9lcdtb)wYqrj1GfjdxvDqc6yqSquLLkkTysSCv5HKupf8yiTousMikrtLqMSIMUuxKKCzKRJsXMvOA7OchgQNtQ(mk(oQKLjQopQOrtklcv1jrP6BIItRY9qj8xfYZerVgvQnIfzqvGvK008mWsACmBKT5zyH3Kb42QtKsvOHduAtrZQeP(pcT2k42qwssyDYR8bKmdii5IrmaOV73gmieTVk0TiVqSidQcSIKMMNba9D)2qxmmss8V6RcDdcvo51CA4x9vHb2J5HI76ziQGmSWBYaRR(QWGWhJUHaVjwW))kzfm0C0V4IE8nKLKewN8kFajnsgXdjnOwJq5wqXbTPOTIbb1CH3Kb()xjRGHMJ(fx0JVBVYTidQcSIKMMNHfEtgg7y064cMePaTJKtdzjjH1jVYhqsJKr8qsdcvo51CAqEmADCbZiDTJKtdShZdf31ZqubzqTgHYTGIdAtrBfdcQ5cVjdUDBa(e6HLhBX9vHx5Pt62ga]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170212.1, [[d4ZVoaGEeLuBsvLDbQxtr2NKWmru1YqKzJQ5lPIBQkKVjjDBjoSWorQ9QSBv2pP0OKu1WeX4quX5jfNgyWKQgUQYbLuoLQGJHKZjjslKcwQQOfJWYP0dvfQNs8ysEUOMiIsYuPkMmitxQlsHEfIs5YqxNQAJsI6qiQ0MPsBxvvFMu57QszAikvZtvQEgf12OknArA8ikHtQk5VuX1KeX9quSseLOFJYXLuPh18mX4feCeAgMqwHUHpVNHj0rbNigjVw9g5ybVo4A1xlRWdkofo5jYXiJJMucv1esjuWuteLf81tMut1a2LNNrtnptmEbbhHMHjIYc(6jntNoocRymoe7Tl)dI1WU8OGo5uMYeSflb4Yvq476chzfEqXPqyiFB0a29tXyCi2Bhmp(hoe(2CdBXsaUCfj)ixcFxx4CZSfti(Hwy)Vj1iaCqRzsKv4bfNcN86GaQOz2jh7WjprogzC0KsO8svfoX8e6OGtQLv4bfNcxpAsZZeJxqWrOzyYJcYcqXV4jS6WopX8erzbF9eYTbktGt3KAeaoO1mXLhf0jNYuMM86GaQOz2jh7Wj0rbNuzEuqT6LuMY0KhRrXrpHvh25rm5jYXiJJMucLxQQWjMNiPS3Eedc4cqBEeRhT55zIXli4i0mmruwWxpPeip3wwbw5BT41vqgsj)Syjax(DYq476chzfEqXPqyiFB0a29tXyCi2BhCKv4bfNcHTyjaxMSr476chzfEqXPqyiFB0a29ozG8Trdy3KAeaoO1mXLhf0jNYuMM86GaQOz2jh7Wj0rbNuzEuqT6LuMYKw91t9WKNihJmoAsjuEPQcNyE9Oj7ZZeJxqWrOzyIOSGVEcHVRlmQszy2H560POJolgTt2)Gql40b7)9JCj8DDHJScpO4uiS)3VsG8CBzfyLV1IxxbzihVAjlN8e5yKXrtkHYlvv4eZtEDqav0m7KJD4KAeaoO1mbdBNwx)WeoHok4eJHTtRRFycxp6kzEMy8ccocndteLf81tkbYZTLvGv(wlEDfKPsj9JCj8DDHJScpO4uiS)3KNihJmoAsjuEPQcNyEYRdcOIMzNCSdNuJaWbTMjyy7uNCktzAcDuWjgdBNQvVKYuMwpAVZZeJxqWrOzyIOSGVEsZ0PJJWHTbUHQDccah0AMuJaWbTMj5MzlMq8dTtEICmY4OjLq5LQkCI5jsk7ThXGaUa0MhXe6OGtKMzlMq8dTtEDqav0m7KJD46rxDEMy8ccocndteLf81tM8e5yKXrtkHYlvv4eZtEDqav0m7KJD4KAeaoO1mb5ybVo4oe8i3tOJcoXihl41bxREd8i3Rhn5mptmEbbhHMHjIYc(6jHQb)rh8WcaZvqgZtQra4GwZeoOU(aiNsOReonRXYKxheqfnZo5yho5jYXiJJMucLxQQWjMNqhfCc5b11haPv)JcDLqREpSglRhDLoptmEbbhHMHjIYc(6je(UUWFS3qRdZ1PtrNsG8CBzfy)VFe(UUW5MzlMq8dTW(F)cvd(Jo4HfaMF38KNihJmoAsjuEPQcNyEYRdcOIMzNCSdNuJaWbTMjCGU0(aNohcgVNqhfCc5b6s7dC60Q3aJ3RhnvY8mX4feCeAgMikl4RNaXAyxEuqNCktzc2ILaC5kurUDAqb)vVIX4qS3ohlgQUo1HW31foYk8GItHW(Fpm5jYXiJJMucLxQQWjMN86GaQOz2jh7Wj1iaCqRzcp(hoe(2CpHok4eYh)dT6n4BZ96rtrnptmEbbhHMHjIYc(6jLa552YkWkFRfVUcYqk5hHVRlmYXcEDWDCzk)mS)3pl6AXCAqWXj1iaCqRzIlpkOtoLPmn51bburZSto2HtEICmY4OjLq5LQkCI5j0rbNuzEuqT6LuMYKw91t6H1JMI08mX4feCeAgMikl4RNucKNBlRaR8Tw86kidPKFe(UUWihl41b3XLP8ZW(F)cvd(JoqSg2Lhf0jNYuMEV(q1G)OdEybG53jJ5FHQb)rh8WcaZ1PoMFyYtKJrghnPekVuvHtmp51bburZStuAuCCcDuWjvMhfuREjLPmPv)J1O44KAeaoO1mXLhf0jNYuMwpAkZZZeJxqWrOzyIOSGVEsjqEUTScSY3AXRRGmKJ3jprogzC0KsO8svfoX8KxheqfnZo5yhoPgbGdAntWW2Po5uMY0e6OGtmg2ovREjLPmPvF9upSE0uK95zIXli4i0mmruwWxpHW31fUznwCkrUrRgylwcWLFNkPo1PEcFxx4M1yXPe5gTAGTyjax(DcFxx4iRWdkofcd5BJgWoYMIX4qS3o4iRWdkofcBXsaU8pfJXHyVDWrwHhuCke2ILaC53PQKhM8e5yKXrtkHYlvv4eZtEDqav0m7KJD4e6OGt8WASOv)JICJwntQra4GwZKM1yXPe5gTAwpAQkzEMy8ccocndteLf81ti8DDHrvkdZomxNofD0zXODY(heAbNoy)Vj1iaCqRzcg2oTU(HjCYRdcOIMzNCSdN8e5yKXrtkHYlvv4eZtOJcoXyy7066hMqT6RN6H1JMY78mX4feCeAgMikl4RNeQg8hDWdlamxb1Vq1G)OdEybG5kOM8e5yKXrtkHYlvv4eZtEDqav0m7KJD4KAeaoO1mHh)dhcmktOJcoH8X)qREdyuwpAQQZZeJxqWrOzyIOSGVEcHVRl8h7n06WCD6u0Peip3wwb2)7xOAWF0bpSaW87MN8e5yKXrtkHYlvv4eZtEDqav0m7KJD4KAeaoO1mHd0L2h405qW49e6OGtipqxAFGtNw9gy8wR(6PEy9OPiN5zIXli4i0mmruwWxpjun4p6GhwayUcQjprogzC0KsO8svfoX8KxheqfnZo5yhoPgbGdAntuPb4C4aDP9boDtOJco5XPb40QN8aDP9boDRhnvLoptmEbbhHMHjIYc(6jtEICmY4OjLq5LQkCI5jVoiGkAMDYXoCcDuWjKhOlTpWPtREdmERvF9KEysncah0AMWb6s7dC6Ciy8E9OjLmptmEbbhHMHjIYc(6jf2FWP7NfDTyoni44KNihJmoAsjuEPQcNyEYRdcOIMzNCSdNqhfCsL5rb1QxszktA1xV5hMuJaWbTMjU8OGo5uMY06rtIAEMy8ccocndtEDqav0m7eLgfhNikl4RNeQg8hDWdlamxb1Vq1G)OdeRHD5rbDYPmLP3dvd(Jo4HfaMN8ynko6jS6WopIj1iaCqRzIlpkOtoLPmnrszV9igeWfG28mmHok4KkZJcQvVKYuM0QV(hRrXrT6j9WKNihJmoAsjuEPQcNyE9OjrAEMy8ccocndtOJcoXyy7uT6LuMYKw91t6HjprogzC0KsO8svfoX8KxheqfnZo5yhoPgbGdAntWW2Po5uMY0erzbF9Kc7p40TE9e5dvGGdiRJgWUrtYlP1Ba]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170212.1, [[de0toaqiufP2efQrraNcvPvHQq8kufkZcvrYUi0We4yOYYurpJGMgQIQRHQOSnkY3OQACOk4CQampcu3tLO9Ps4GcLfsr9qcKMiQcvxKc2ifItkuTsva9sufsZKcPBQcYorXsvHEkYuPQSxP)kObJQ6WkTyu6XuAYuXLbBMk9zi1OPkNwvVgsMnj3wr7gQFtQHRsDCvqTCIEUctx01fY2vj9DceJhvr48qy9OkIMVkq7hIUC1xjd4Lvbo1CjMDcLidgfjFdkyc4Cvi5h3cUrseLiR8VZsLockyhqzod48hCgWjYvIUb7VQNNCZxJlZPPZsXS5RXJ6RmC1xjd4Lvbo1CjYk)7SepD(wupgDPySV6teLCv7echEAlQsXXoVDtTSewJHshbfSdOmNbCM48lgiSeZoHsgrTtajFYtBrHKVab82SmN1xjd4Lvbo1CjYk)7SeBKRRiy90Wiu7gMEqiAjSz4ic7aYhJwm6245cQrk1trBKuc48Il5btLockyhqzod4mX5xmqyP4yN3UPwwcRXqjMDcLmSY07WrlkOum2x9jIsWktVdhTOGMLry9vYaEzvGtnxISY)olXg56k(wWnsIqm6245cQrk1trBKuc48Il5btLIX(QpruYvQhz4WtBrvko25TBQLLWAmu6iOGDaL5mGZeNFXaHLy2juYis9irYN80wunldpV(kzaVSkWPMlrw5FNLMlOgPupfTrsjGZlU8aorEGLockyhqzod4mX5xmqyP4yN3UPwwcRXqjMDcLmSY0djFYtBrvkg7R(erjyLPx4WtBr1Sm8S6RKb8YQaNAUeZoHsuQLtuaCdYsXyF1NiknsTCIcGBqwko25TBQLLWAmuISY)olLA0OvG4kZ3DTz4Y(QprySaRn)RqiGH5dJl4o4bhqMpg9qCrJwcJXFfchPworbWni5T0rqb7akZzaNjo)IbcBwgt1xjd4Lvbo1CjYk)7SuPJGc2buMZaotC(fdewko25TBQLLWAmuIzNqjdkyc4Cvi5BwTJSum2x9jIsGcMaoxviRAhzZY4V(kzaVSkWPMlrw5FNLMlOgPupfTrsjGtbFPFtLIX(Qpru6TGBKerP4yN3UPwwcRXqPJGc2buMZaotC(fdewIzNqP4wWnsIOzz4H6RKb8YQaNAUezL)DwAT5FfcbmmFyCXLclfJ9vFIOK6pC07eox0Znm1jmlfh782n1YsyngkXStOKr)dh9oi5FOf9CrY3NoHzPJGc2buMZaotC(fde2Smhq9vYaEzvGtnxISY)olXg56kERfeqgQDdtpiCUGAKs9um62y2ixxXrQLtuaCdsXOBJxB(xHqadZhgcwyPySV6teLupAVe)y0HSAvwko25TBQLLWAmu6iOGDaL5mGZeNFXaHLy2juYOpAVe)y0i5BwRsK8fG4r5Tzz4cQVsgWlRcCQ5sKv(3zjhDk6Q2jeo80wuIsyUpECHDhzy(ta5bw6iOGDaL5mGZeNFXaHLIJDE7MAzjSgdLy2juYO71fjFZrYrwkg7R(erj1EDdzJKJSzz44QVsgWlRcCQ5sKv(3zj2ixxX3cUrseIr3glWCb1iL6POnskbCEXLNbh8GSrUUIVfCJKieLWCF8qWcG26WJWg56k(wWnsIqCKRffpghV8wkg7R(erjxPEKHdpTfvP4yN3UPwwcRXqPJGc2buMZaotC(fdewIzNqjJi1JejFYtBrHKVaC82SmCN1xjd4Lvbo1CPdT8e)mA6BLOHCusyjYk)7S0Cb1iL6POnskbCEXLNbgZg56kckyc4CvHUAB0qm62yj4kHH3YQaKhyPySV6teLCv7echEAlQsXXoVDtTSewJHsm7ekze1obK8jpTfvjbfHvb(wjAihLT0rqb7akZzaNjo)IbclrEAb5qAN39b5OSnldNW6RKb8YQaNAUezL)DwAUGAKs9u0gjLaoV4YZaJzJCDfbfmbCUQqxTnAigDBSacS28VcHagMpmU8041M)vi0rNIUQDcHdpTfLGp59GhuG1M)vieWW8HXfxk041M)vi0rNIUQDcHdpTfLGfYlVLIX(QpruYvTtiC4PTOkfh782n1YswewfuIzNqjJO2jGKp5PTOqYxaoElDeuWoGYCgWzIZVyGWMLHJNxFLmGxwf4uZLiR8VZst91hJMNInY1v8TGBKeHy0DPySV6teLCL6rgo80wuLIJDE7MAzjSgdLockyhqzod4mX5xmqyjMDcLmIupsK8jpTffs(cCYBZYWXZQVsgWlRcCQ5sKv(3zP5cQrk1trBKuc48Il5btLIX(Qprucwz6fo80wuLIJDE7MAzjSgdLy2juYWktpK8jpTffs(cWXBPJGc2buMZaotC(fde2SmCMQVsgWlRcCQ5sKv(3zj2ixxrjm04fBHWuNWuucZ9XdbZfu6iOGDaL5mGZeNFXaHLIJDE7MAzjSgdLIX(Qpruk1jmdN7ibjIsm7ek5tNWej)dTJeKiAwgo)1xjd4Lvbo1CjYk)7SeBKRRiy90Wiu7gMEqiAjSz4ic7aYhJwm6U0rqb7akZzaNjo)Ibclfh782n1YsyngkfJ9vFIOeSY07WrlkOeZoHsgwz6D4OffGKVaC82SmC8q9vYaEzvGtnxIzNqjJ(O9s8JrJKVzTklDeuWoGYCgWzIZVyGWsXXoVDtTSewJHsKv(3zj2ixxXBTGaYqTBy6bHZfuJuQNIr3gV28VcHagMpmeSWsXyF1NikPE0Ej(XOdz1QSzz4oG6RKb8YQaNAUezL)DwAT5FfcbmmFyCbxPJGc2buMZaotC(fdewko25TBQLLWAmukg7R(erjR3(4q1J2lXpgDjMDcLeuV9Xi5B0hTxIFm6ML5mO(kzaVSkWPMlrw5FNLkfJ9vFIOK6r7L4hJoKvRYsXXoVDtTSewJHsm7ekz0hTxIFmAK8nRvjs(cWXBPys0JsLockyhqzod4mX5xmqyjYtlihs78UpihLTKG6bwuhsFfMaolBZYCYvFLmGxwf4uZLiR8VZst91hJ2yj4kHH3YQGshbfSdOmNbCM48lgiSuCSZB3ullH1yOeZoHsgrTtajFYtBrHKVaN8wkg7R(erjx1oHWHN2IQzzopRVsgWlRcCQ5sKv(3zPP(6JrB8AZ)ke6Otrx1oHWHN2IsWRn)RqiGH5dJshbfSdOmNbCM48lgiSuCSZB3ullzryvqPySV6teLCv7echEAlQsm7ekze1obK8jpTffs(cCYls(ckcRcAwMtH1xjd4Lvbo1CjYk)7S0uF9XOlDeuWoGYCgWzIZVyGWsXXoVDtTSewJHsXyF1NikbRm9chEAlQsm7ekzyLPhs(KN2IcjFbo5TzZs84G7gPYAUzla]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170212.1, [[d0dqoaGEqvP2eOYUOOTjs2NivZuLsZgP5JQc3uKspMsFtuCyP2jkTxLDdSFvvJIKyyI43K6CKKQZJQmyqA4GYHavLCkuvDmeoUkfwij1sfvTyuSCQ6HOQ0tjwMQYZvLjcQkmvQOjJOPlCrk0PLCzORdInQsrVMc2Skz7IsFMk9DrkMgOQY8av5zuHBRIrtIXdQk6KQunoss5AGQQUhjjRevfDqrL)IkpI5CIrqZqrYPEIy9fSyYe4d8QHqJPEsEKI9dh7xcrMKVectIjcm0wnTGV7O0GX(L6BsoBuAWBohlXCoXiOzOi5uprS(cwmb(kkRHc4ojhtrRG3KlAFqUNI2AyYDazz7q7Na0aCsEKI9dh7xcrkImMjoMW2hCYnP9b)HkkARHFOQKW)IX(nNtmcAgkso1teRVGftyGCDzIwfn(40xCHcY56Xo4EqaKOVaUMqGb3Pr6l86JPfI3JGiDvPAPMKhPy)WX(LqKIiJzIJj3bKLTdTFcqdWjS9bNyS9HYnG0gWj5ykAf8MGTpuUbK2aUySoMZjgbndfjN6jI1xWIjNgPVWRpMwiEpcI0vLQ)9ZNtYJuSF4y)sisrKXmXXK7aYY2H2pbOb4e2(Gtm2(q5hQOOTgMKJPOvWBc2(qH7POTgwmw43CoXiOzOi5upHTp4ej0(JbeHH(j5ykAf8M8cT)yaryOFYDazz7q7Na0aCIy9fSysODDPOz7J6QTbxZu0k4bNkTnQSihcWtHV0j4d(4Hrua3Nz766X3RYICVq7pgqeg65FsEKI9dh7xcrkImMjowmw4)CoXiOzOi5uprS(cwmzsEKI9dh7xcrkImMjoMChqw2o0(janaNW2hCIrkEqq00FOQP9lMKJPOvWBcsXdcIMYXq7xSySPMZjgbndfjN6jI1xWIjTnQSihcWtHV0vLJj5ykAf8MqRBaPi5oT7P5cDGNj3bKLTdTFcqdWjS9bNCBDdif5p002UN(hQtDGNj5rk2pCSFjePiYyM4yXyZmNtmcAgkso1teRVGfti1H5fTpi3trBny6XtxGx62(fCrDWF(CsEKI9dh7xcrkImMjoMChqw2o0(janaNW2hCYTD2(hQAi(xmjhtrRG3eANT5yG4FXIXQAZ5eJGMHIKt9K02WN1bYXz7DX4nXXeX6lyXKtJ0x41htleVhbr6Q6lbogixxMifpiiAk3L2c5zcbgCE8YJpLMHI)85KCmfTcEtUO9b5EkARHj3bKLTdTFcqdWjS9bNCtAFWFOII2AycF5zPOZ27IXBmtYJuSF4y)sisrKXmXXerrNM0QjRRc9VXSySQ(CoXiOzOi5uprS(cwm50i9fE9X0cX7rqKUQ(sGJbY1LjsXdcIMYDPTqEMqGbNkQ02OYICiapf(u1hCTnQSihPomVO9b5EkARb49XpFWhQ02OYICiapf(sxvoGRTrLf5i1H5fTpi3trBnaph8Z)KCmfTcEtUO9b5EkARHj3bKLTdTFILNLIty7do5M0(G)qffT1Wpuvi4FsEKI9dh7xcrkImMjowmwIK5CIrqZqrYPEIy9fSyYPr6l86JPfI3JGiDvPAPMKJPOvWBc2(qH7POTgMChqw2o0(janaNW2hCIX2hk)qffT1Wpuvi4FsEKI9dh7xcrkImMjowmwcI5CIrqZqrYPEIy9fSycdKRltp(0GgyrUqh4X0JNUap4rKmjpsX(HJ9lHifrgZehtUdilBhA)eGgGtYXu0k4nj0bE4o9lqpVjS9bN4uh45hAA7xGEElglX3CoXiOzOi5uprS(cwmHbY1LjAv04JtFXfkiNRh7G7bbqI(c4Acb2K8if7ho2VeIuezmtCm5oGSSDO9taAaojhtrRG3eS9HYnG0gWjS9bNyS9HYnG0gWFOQqW)IXs4yoNye0muKCQNW2hCYTLRsakG7pu1AAmjpsX(HJ9lHifrgZehtUdilBhA)eGgGteRVGftyGCDzctNg0ZPV4cfK70i9fE9Xecm4ABuzroeGNcFWZbCKidKRltA5QeGc4Y51KMK60aMKJPOvWBcTCvcqbC5y00yXyjGFZ5eJGMHIKt9eX6lyXegixxMW0Pb9C6lUqb5onsFHxFmHadU2gvwKdb4PWh8CaxBJklYrQdZlAFqUNI2AaEFtYJuSF4y)sisrKXmXXK7aYY2H2pXYZsXjS9bNCB5QeGc4(dvTMg)qvHV8SuK)j5ykAf8MqlxLauaxognnwmwc4)CoXiOzOi5uprS(cwmPTrLf5qaEk8LobCKidKRltA5QeGc4Y51KMK60a(5Zj5rk2pCSFjePiYyM4yYDazz7q7Na0aCsoMIwbVjwLUaC0YvjafWDcBFWj8vPlWp0BlxLaua3fJLi1CoXiOzOi5uprS(cwmPTrLf5qaEk8LobCmqUUmPLRsakGlNxtAcbgCTnQSihPomPLRsakGlNxtcV2gvwKdb4PW3KCmfTcEtSkDb4OLRsakG7K7aYY2H2pXYZsXj5rk2pCSFjePiYyM4ycBFWj8vPlWp0BlxLaua3FOQWxEwkY)IXsKzoNye0muKCQNiwFblMqImqUUmPLRsakGlNxtAsQtdysoMIwbVj0YvjafWLJrtJj3bKLTdTFcqdWjS9bNCB5QeGc4(dvTMg)qvHG)j58UVjtYJuSF4y)sisrKXmXXerrNM0QjRRc9VXmHVkO1qA1zXdcIXSySeQ2CoXiOzOi5uprS(cwmPTrLf5qaEk8LobCTnQSihPomPLRsakGlNxtcV2gvwKdb4PW3K8if7ho2VeIuezmtCm5oGSSDO9tS8SuCsoMIwbVjxE9l4EkARHjS9bNCB5QeGc4(dvTMg)qvHG)FO8LNLIlglHQpNtmcAgkso1teRVGftMKhPy)WX(LqKIiJzIJj3bKLTdTFcqdWj5ykAf8MqlxLauaxognnMW2hCYTLRsakG7pu1AA8dvLp(xm2VK5CIrqZqrYPEIy9fSyYrNTaUW5Xlp(uAgkojpsX(HJ9lHifrgZehtUdilBhA)eGgGty7do5M0(G)qffT1Wpuv(4FsoMIwbVjx0(GCpfT1WIX(rmNtmcAgkso1teRVGfto6SfWfU2gvwKJuhMx0(GCpfT1a8ABuzroeGNcFtYJuSF4y)sisrKXmXXK7aYY2H2pXYZsXj5ykAf8MCr7dY9u0wdty7do5M0(G)qffT1Wpuv(4)hkF5zP4IX(9nNtmcAgkso1teRVGfto6SfWDsEKI9dh7xcrkImMjoMChqw2o0(janaNKJPOvWBc2(qH7POTgMW2hCIX2hk)qffT1Wpuv(4FXIjS9bNigV9hQrkEqq00FO3MFXga]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170212.1, [[d0ZuhaGEcuAtQOIDHOTrvAFQOyMuqZwQ5tbUjLOVPcUTQ6Wc7eI9QSBs7xLmkcummk14ik4XuzOeimyi1WrWbjQofbIogfDovuLfsHwkHSyISCrTic4POwgc9CvzIefzQuftwKPl5IuvRJOuxgCDizJeL0PrAZusBNaj)LG(mHAAei13PeEMkYHurPrtuO5PIQ6KQqVMavxJOeNxLALQOs)gQFsuupZ5zSVgsnKMXXYeynq11mogj(Wy23Wl0(n8bTI(cTmbwduDnwe0q8GHq028GnrBtsZXSltjuJhl3vuS(MNHyopJ91qQH0mogj(WybbUOyDm7Yuc14clwCdKeWffRVZrWC2clwCdKomUtyl0Nbg4W4oHTqjTsZGqOHpOv0Kz4hu9DgIYGTGCSiOH4bdHOTPxZdK2NgFutuxu48yfRWy5s0Mw3JjGlkwhBjoHeFySaeY4gRIHKqcylGSaRgcX5zSVgsnKMXXSltjuJLqz1kzHl4l8hVcY3Kz4hu9D(ehlxI206ECHl4l8hVcY3JpQjQlkCESIvyms8HXEWf8VqBz8kiFpwe0q8GHq020R5bs7tRgYP5zSVgsnKMXXSltjuJlSyXnq6W4oHTqFJfbnepyieTn9AEG0(04JAI6IcNhRyfgJeFySSsZWfA)g(GwrpwUeTP19yR0mieA4dAf9QHiONNX(Ai1qAghZUmLqnUWIf3aPdJ7e2c9nwe0q8GHq020R5bs7tJpQjQlkCESIvyms8HXCHZ)l0(n8bTIESCjAtR7XVcN)cHg(GwrVAiYY8m2xdPgsZ4y2LPeQXfwS4giDyCNWwOVXYLOnTUhdn8bTIw4pEfKVhFutuxu48yfRWyrqdXdgcrBtVMhiTpngj(Wy)g(GwrFH2Y4vq(E1q8opJ91qQH0moMDzkHA8zRObTiJNd0uOoGe0qQHKbgiHYQvY45anfQdirrWadCyCNWwOKXZbAkuhqMHFq13zKf7XIGgIhmeI2MEnpqAFA8rnrDrHZJvScJrIpm2yJXPl0YkQ89y5s0Mw3JLAmoj0kQ89QHCyEg7RHudPzCm7Yuc14ZwrdArgphOPqDajOHudjdmqcLvRKXZbAkuhqIIWyrqdXdgcrBtVMhiTpn(OMOUOW5XkwHXiXhgBeYpil4uv8y5s0Mw3JLG8dYcovfVAiYW8m2xdPgsZ4y2LPeQXHROckqiOWNcVZqCms8HXIqPY(cTCz2FSCjAtR7XzuQWWvuSkSPVA8rnrDrHZJvScJfbnepyieTn9AEG0(0ylXjK4dJfG9n8cTFdFqROVqlxM9fy1qoV5zSVgsnKMXXiXhglcLk7l0YFoqtH6GXSltjuJRObTiJNd0uOoGe0qQH0yrqdXdgcrBtVMhiTpn(OMOUOW5XkwHXYLOnTUhNrPcdxrXQWM(QXwItiXhgla7B4fA)g(GwrFHw(ZbAkuhiWQHyAppJ91qQH0mogj(WyrOuzFH(OdSIkFpMDzkHACfnOfj1bwrLVjbnKAiDDUJfbnepyieTn9AEG0(04JAI6IcNhRyfglxI206ECgLkmCffRcB6RgBjoHeFySaSVHxO9B4dAf9f6JoWkQ8TaRgIP58m2xdPgsZ4yK4dJfHsL9fAdPILXsPQ4l0IWPXSltjuJRObTiBQyzSuQkwygNibnKAinwe0q8GHq020R5bs7tJpQjQlkCESIvySCjAtR7XzuQWWvuSkSPVASL4es8HXcW(gEH2VHpOv0xOnuKaRwnMjaoA0ubBuuSoeIEjUAd]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170212.1, [[dSt9iaGEQe0MKQQDrvTnjv7JkHMPuvMnQUjuCBs9njLDQk7vSBL2pv0pPsGHjjJdLKCykpwIbtsnCPWbjjNIkrogrohkbTquQLQOSyOA5QQhkf9uKLruEokMikj1uPknzfMUkxKO68uPUm46uHnIsItdzZufBxQ8AO03PsYNLsZdLuptQYFvKrtIPHsOtQO6qOe5AujQ7Hsu)MWXPsQrHsGJu8gs(A4Cye2HEMgcrY7ZPA5Cqd7zCNQv5cKhIvdEmh8lSdnd4GXa5jRsQwLSkjFPqudOGmoYfAhsS5jRUSqQkhsSmXBEsXBi5RHZHryh6zAieDIVglanGFiv4io6ChI5eFnwaAa)qZaoymqEYQKQlvZVQxO57avSt8dTIfc1ubkyXi6anSxWdHrmEMgcLlpzXBi5RHZHryh6zAiKkMcSdBlqiQ8rnUqNOTLd(fHGpeUAzc1ubkyXi6anSxWdnd4GXa5jRsQUun)QEHMVduXoXp0kwiKkCehDUdzmfyh2wGqyeJNPHq5YRx8gs(A4Cye2HEMgc1hY1oqdNQXyTAZPAVId0HuHJ4OZDioY1oqJjT1QTPtCGo0mGdgdKNSkP6s18R6fA(oqf7e)qRyHqnvGcwmIoqd7f8qyeJNPHq5YJfJ3qYxdNdJWoev(OgxiTbCM7l0(fh)pSNlYYYQ6NLoJd75ZrTk3I22PVy4dRHZHr)FWZhyumCoesfoIJo3H8WnnmXOikyd1ubkyXi6anSxWd9mneIv4MgCQMuefSHMbCWyG8KvjvxQMFvVqKIWvyedKhe8zcEO57avSt8dTIfcHrmEMgcLlpxoEdjFnComc7qu5JACHSYH6Gjybncyynl2VvouhmneNVhUPHjgfrblRTYH6GjybncycPchXrN7qE4MgMyuefSHMVduXoXpuXDHdHEMgcXkCtdovtkIcwNQB6UWHqZaoymqEYQKQlvZVQxU8QhVHKVgohgHDONPHqYT)P4AhgwiKkCehDUdb2)uCTddleAgWbJbYtwLuDPA(v9cnFhOIDIFOvSqOMkqblgrhOH9cEimIXZ0qOC5vlEdjFnComc7qptdH6Z6mNQz74ZCHOYh14cneNVhUPHjgfrbR)h0gAzCXIXCthsd9J7WJhFU1ztmo(TGVJg9ZsNXH985OwLBrB70xm8H1W5WOFRCOoycwqJagwZIHAQafSyeDGg2l4HMbCWyG8KvjvxQMFvVqZ3bQyN4hAflesfoIJo3H4wNnH74ZCHWigptdHYLhRkEdjFnComc7qptdHKZbnSNXDQMn3yUqu5JACHyPZ4WE(CuRYTOTD6lg(WA4Cy0VvouhmblOradRD5qnvGcwmIoqd7f8qZaoymqEYQKQlvZVQxO57avSt8dTIfcPchXrN7qah0WEgFcNBmximIXZ0qOC5XcJ3qYxdNdJWo0Z0qO(SoZPA2GPdPchXrN7qCRZMWbthAgWbJbYtwLuDPA(v9cnFhOIDIFOvSqOMkqblgrhOH9cEimIXZ0qOC5jvfVHKVgohgHDiQ8rnUqda3Hhp(CuRYTOTD6lg(dHR2qptdHAQyO1P6(qTk3I22qnvGcwmIoqd7f8qZaoymqEYQKQlvZVQxO57avSt8dTIfcPchXrN7qffdTtCuRYTOTnegX4zAiuU8KKI3qYxdNdJWoev(OgxiRCOoyAioFoQv5w02o9fdwBLd1btWcAeWeAgWbJbYtwLuDPA(v9cnFhOIDIFOvSqONPHqnvm06uDFOwLBrBRt1nDx4qiv4io6ChQOyODIJAvUfTT5Ytsw8gs(A4Cye2HOYh14cH7WJhFU1ztmo(TGVJgHuHJ4OZDiU1zt4o(mxO57avSt8dTIfcHr0H22qsHEMgc1N1zovZ2XN5CQMfi5sHu9BzcPfDOTLLLcnd4GXa5jRsQUun)QEHifHRWigipi4Ze2HAQafSyeDGg2lSdHrmEMgcLlpPEXBi5RHZHryhIkFuJl0h88bgfdNdHuHJ4OZDipCtdtmkIc2qZ3bQyN4hAflecJOdTTHKc9mneIv4MgCQMuefSovZcKCPqQ(TmH0Io02YYsHMbCWyG8KvjvxQMFvVqnvGcwmIoqd7f2HWigptdHYLlev(OgxOCja]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170212.1, [[d8cmcaGEQsAxOOTjcZKQGztXnvrFJQQDkL9s2nI9dfnmu1Vv1qPk1GLknCv4GqvhdPwikSuQklgjlxulsQ4PGLjsphvMivrMkuAYQ00fUiu5YkxNQeBMQO2ou4ZOKdl5XqCBknAiX5LQojKQ)cjDAQCpQc9qiLNjIEnk1IwyfGJuuMDfdbEAEU8Ijedbas2Dece4BMvCtTuEA)8P80mPfahdXvgNxRW9e1stKkaps4EcNWQgTWkahPOm7kgcaKS7ieeplwMX84d3t4eGNYzCrVGJpCpra6KRdPIplG8KjOv2jW7pCpra(mlobKYop25U6A6rLvUqwhb(Mzf3ulLNobTFM8jfGgkdH95JXSJeIsW5FBLDc6CxDn9OYkxiRJc1sfwb4ifLzxXqqRSta2pMfZUNfxSCVa8uoJl6feFmlQ2IlwUxGVzwXn1s5Ptq7NjFsbOtUoKk(SaYtMa0qziSpFmMDKquco)BRStGc1skScWrkkZUIHGwzNai(SL92XYcWt5mUOxax8zl7TJLf4BMvCtTuE6e0(zYNua6KRdPIplG8Kjanugc7ZhJzhjeLGZ)2k7eOqHGwzNaaNhWSloZSJeLbZUENhYBPQqHea]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170112.1, [[dWdefaGEbyxQIyBeWmvfQdRYSf1RvfIBcrEMQu3MKZlq7uK9QSBK2pv)eIYWi04ufOtJyOezWugUqoOQYrfqhdKZPkileiTuc0IfQLlLhcWtrTmsX6acteszQaAYavthQlkORQkKUSKRdQncP6BquTzvjBhs(OQi9zimnsP(oqKrQkOEmPA0QQgpPKtQkQBruxdOCpvb8CcATar9BP6bnGJrgQQLVGlECGWfCbUBO3Py3ysa1sqAglHsYnz3aEnefEXJLAe11c6gGlct6u3(GB3yg3BQ4gHIOAJBvEmGWeWqbh)Ocl34OkNrpFc)x8yjuHUj7gWRHOWlESeQq3KDdT61bNXd0XsOcDt2naDv8Hx8yKoTikyLBajQAP3IJb5ExTeeyJz9gjcpESekj3KDdqxfF4fpwcLKBYUHw96GZ4b64GdD5hu8H0OTOaqqi)TOgnixCVK1gSXFil0nz3q60IOGvljowWkxNWAjnIqixecc6jVhhiCbxU9LjiOQIIhRp(dg3Dt2nKoTiky1sIJLqj5MSBaVgIc72xo6)wcAmtOiYLBYUHeHsuWQLehlHsYnz3qREDWzSBF5O)BjOXsOcDt2n0QxhCg72xo6)wcACGWfCjCaxcAahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4wuR07Q4dpoDQAmtuaClK(Fu9svumiClQv6Dv8HhlyLRtyTKgribGefFpM1BKi8ymrvpG4WlPzahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4g41RdoJhNovnMjkaUfs)pQEPkkgeUbE96GZ4Xcw56ewlPresairX3dp8yjusUj7gGUk(WU9LJ(VLGgZrvoJE(e(7gGEU3gWX3sqJBlbngXsqJJxcA4Xa6rbDdyFCi9)O6LQOy3ycfrUKbEnefESeQq3KDdqxfFy3(Yr)3sqJdeUGl3qJ0kDmPthl4Zp9HbogT61bNXd0XbcxWf4U9SEN6gtcOwsBXXsOcDt2nGxdrHD7lh9FlbnoKEX5c8b64pyC3nz3qIqjky1sIJLAe11c6gGlct60XcBhM0h)HSq3KDdjcLOGvl9EmtOiYLBYUH0PfrbRwcAmWlxuSBpT1HJwsC8Z6DQq34)oirxs7XcEueLBa(l9hHqrm(Ijzco4yPgrDTGU9SEN6gtcOwsBXXO3P4XFnYLDlDTwhKgNovnoK(Fu9svuSBsnI6Abhl1iQRf0n07uSBmjGAjinJ5OsNCzsahM0PlPrG3J5OtNqrSeyJ)0XKo1naxeM0PchOJ1AjzbEcK4BWGatanGvYIIGn8g]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170112.1, [[dWt8eaGEIu7svL2MQGzkLKdRYSf1RfO4MGIRbkDBsoVQQ2Pi7vz3iTFk)uvOHjOFlvptadLqdMQHlKdkuhvGCmeDoPuSqGyPiKflflhWdvvEkQLreRtkvtKGmvGAYaPPd5IKYvfOQll56GSreQXjLqBwv02jWhLsQpdQMgb13Ls0ifOYJjQrRknEIKtQQIBrQonu3tGsphbRvkbFtkLEKd84GGkOcuZjUtrMZyPRLiLmweaRoG)MtCNImNXsxlrkzSiawDa)n)7Iq4o18yiGBmJ6aQgamfEbmgOYJ)0sG1iACWtOmNJQCM48r4DnJ5OtgtHVeSJffOzUU5cvppOmAGmwuGM56M)1vnhAnJH5KcRGuMdgRQLceoUf6D1sKWowuGO56Mlu98GYiZJZrV3sKJffiAUU5FDvZHwZyrbIMRBUq1ZdkJgiJ)pI1Fa2W2qg2MaTnqGqHBXaH7PUWWowQLchtuLRJqTKKqY2gsss(BGXbbvqL5XzmCQQOOXYJffOzUU5FDvZHmpoh9ElroweaRoG)M)JCNAoJLUws4WXIcenx38VUQ5qMhNJEVLihh)OM56MdZjfwbPwkCCSmc3PM)DriCNsyGmwuGM56Md(aGxO1mwuGO56Md(aGxO1mMJQCM48r418VEUdmWJVLih3Se5y4lrogyjYHg)1J(Bo4(yn67rLlvrrMh)O2yrbIMRBo4daEHmpoh9ElrooiOcQmximqjJWD6yI(P1bh4XPtvJ1OVhvUuffzE8JAJdcQGkqn)h5o1CglDTKWHJjUtrJJbWx280ba0B5yn61KlqhiJ5OsgFzS0hc3Plj5HaJj6OWlZ)El5GbtHp(AWzm6)44h1mx3CyWuScsTuGX)i3PemNF7TKUKWJbF5IImV1aDOOLchZyk8CzUU5WCsHvqQLchlcGvhWFZ)UieUthta4q4(4yiu3CDZH5KcRGulfowuGM56Md(aGxiZJZrV3sKJJHqDZ1nhgmfRGulfymJPWZL56MddMIvqQLcmoiOcQimWlroWJ1OxtUaDGmowgH7uZBfMaAmJvFMRrFpQCPkkQDZJak5UQ5qJtNQgZy1N5A03JkxQIIA38iGsURAo0yIQCDeQLKescB4d)krc5ywgahHgJWQkydhAjjd8yn61KlqhiJJLr4o18wHjGgZy1N5A03JkxQIIA3CqRNhugnoDQAmJvFMRrFpQCPkkQDZbTEEqz0yIQCDeQLKescB4d)krc5qdnMLbWrOXeWu45ASOanZ1nxO65bLrMhNJEVLihlu98GYObYqBa]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170201.1, [[dSt4eaGEIk7IOO2MkOzcLA2O6WkDtvPETqL62K6zqr7uWEL2Tc7NQFQc1WiYVvPZlugkedMYWfYbvuhLOQJbPZjuHfQkzPqjlwrwUQ6HOupfzzOKNdvnrvutfitMemDqxefxvOsUSORdyJqHttyZQiBhO(OkqFgQmnIsFxOQgPqvmoIImAs04jHoPkKBrsxtfW9eQOhRkwRqv6BefUOfuPJbNF(gRtLKhibsfCdJ7a6gjKlBaLvjeWiUP6gO9JlHDQeYxO3Fm3yVrqXD42mWFlv6N8sSzcGyWQuCHpDJIsohd(IxzNkHaMXnv3aTFCjStLqaZ4MQBNZtlah2xLqaZ4MQBSV6Pf2PsVxffAaTBGe6SbmLkfV3RUbmLkrpFreSujeWiUP6g7REAHDQecye3uD7CEAb4W(QuSIHQmjfhSKv6quuzGPelwYqQNuL9aLuSbPsyL8CXNnWscvgsOOSKz0sYdKaPBZCbUHohWspLMbGx3uD79QOqdOBqQecye3uDd0(XLq3M5rk3gqlrIboE6MQBVfdHgq3GuP5JzCt1T3RIcnGUbPsiGzCt1TZ5PfGdDBMhPCBaTecye3uD7CEAb4q3M5rk3gqlHagXnv3yF1tl0TzEKYTb0suuY5yWx8kDJ9LF)fuPTb0stnGwcxdOL(nGwyj23OyUb6wIHN6CaxUBZhZucbmJBQUX(QNwOBZ8iLBdOLKhibs3ol(5duChLW6OdgpGkndaVUP62BXqOb0nivsEGeivWTJEUd3iHCzdYkvcbmJBQUbA)4sOBZ8iLBdOLyg7epvOVkH8f69hZn2BeuChLG7hxcXxIedC80nv3EVkk0a6gqlnFmJBQU9wmeAaDdywc0YZb0Td(Varniv6ON7aVBKYB8hniBjS2bU0n2kZN4wmWvANeCbmwjKVqV)yUD0ZD4gjKlBqwPsHvNLy4PohWL7gYxO3FSsyChWsZFXYDlS))n(LoNNwaoSVkH8f69hZnmUdOBKqUSbuwLOO8rSCHCluChnW6qwLOO9rmW1Wbkn)af3HBS3iO4oW3xLKhibs8fudOfujMXoXtf6RsZpqXD4g2c8Wsed2UXWtDoGl3nKF(C1tlSuy1zjIbB3y4PohWL7gYpFU6PfwcRKNl(SbwsOhIkjHzj65lIGLGcDgNsf2aRcQeZyN4Pc9vP5hO4oCdBbEyjIbB3y4PohWL72580cWHLcRolrmy7gdp15aUC3oNNwaoSewjpx8zdSKqpevscZs0ZxeblvyHf2ca]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170201.1, [[dSZ7eaGEsKDPKuVwjfZevXSH6WQCtvf3MuFtjrpJiTtH2R0Ufz)u9tsOHruJtjbNxvyOOYGPmCbDqr5OKOogkDoLKSqqyPGOflQwoGhIQ6PiltGEokAIQsMQQQjlathYfb1vrvkxwX1bAJQkDAcBwv02bPpQkv(mkmnb03vsPrQKqBtjvJMigpj4KQs5wK01qvY9uLQESsSwuLQFRux2(xsrOda(E08skdoGtaU9DNqUrcLMgzdwIdkNBQU9FamguZlXbi0hWd34FHiXo5wgiWv6l(0JBKK9YAkbm4s8HJ)WqwI3yoUrHdg)fFmL08sCqHDt1T)dGXGAEjoOWUP62R55bIrfIsCqHDt1n(BD(HAEPpNccnO2TFHEAuQCjEFV1nkvUehuo3uD7188aXi3YWHsUgzlXbLZnv34V15hQ5L4GY5MQBVMNhigvik9OFvxNxYRIvEvsxPuPYbUcsL7t1a5vPmfHDt1TpNccnOUr5sqo45yonguMDLYSSbxnBjLbhWXTmSGrspjuPLsCqHDt1n(BD(HCldhk5AKTehGqFapC7TLDYnsO00yGYL4GY5MQB8368d5wgouY1iBjLbhWHz)BKT)LGtxoEcOqukBbj2j34rWevIG5Xny8ONe6WUXbmlBD(Hkfp9uIG5Xny8ONe6WUXbmlBD(Hkb5GNJ50yqz21zLLLwIwaeHOsiHEEVCrngS)LGtxoEcOqukBbj2j34rWevIG5Xny8ONe6WU9AEEGyuP4PNsempUbJh9Kqh2TxZZdeJkb5GNJ50yqz21zLLLUA2s0cGievQOIkLTGe7KB8VqKyNywikrH3IiXOrEvIcNfXHfkDiXo1yW1dwIchm(l(ykXn(B8gO)LUgzlb0iBjgnYwkVr2IkXFh(WT)Djy8ONe6WULPiCjoaH(aE423Dc5gjuAAKnyjLbhWXTxcGzbj2Psq(27wX)sXtpLGXJEsOd7wMIWLugCaNaC7TLDYnsO00yGYL(UtOszaId7w8aa2RTeC6YXtafIsCq5Ct1T)dGXGCldhk5AKTeKxIX4gFjZYAejgLUCbwGEuktry3uD7Jij0G6gLw6TLDIPBKK9AtngyP)dpjKBVdydg2OCjsKyGh3uD7ZPGqdQBuUehGqFapCJ)fIe7ujGdj2LYarB3uD7Jij0G6gLwIdkSBQU9FamgKBz4qjxJSLEnppqmQqukdeTDt1TpNccnOUr5sKiXapUP62hrsOb1nkTeTaicrLyksmWtjoOWUP62R55bIrULHdLCnYwsHgLlQfa]] )


end
