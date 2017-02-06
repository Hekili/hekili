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

        if state.spec.enhancement then setArtifact( 'doomhammer' )
        elseif state.spec.elemental then setArtifact( 'fist_of_raden' )
        else setArtifact() end

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


    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170201.1, [[dau5jaqiffzriuBsrPgfevNcbzxezykYXeyzevptr10ifvUMIs2gKY3qGXPOqoNIcSosrMhck3dIs2hcQoirzHKkpuqnrff0fjHnQOOgjPOQtsiwjPOyMquCtiStc(PIc1qjfLwQG8uutfISxP)ssgmKCyvwmIEmftMsxgSzsPpRugnPQtJ0RHunBOUTq7w0Vv1WjPwUcpxjtNQRtO2oc57KcNNeTEik18jK2Vs1nOivwrEKyWwDLfUiuMPXW7OuGHiK(H10oklO9eJ9YZqq7jg7vx5qagUfub5tbemfeixkOmRgm0dtr2Nt)ScYrtEzzgN(5QivHGIuzf5rIbBjllCrOSMhgpDflZMbvTx2)Tnmiz(hBFnY1SrUFJnWL0dh21lP24eM8zjQOonce(K0SMMiu5qagUfub5tbOfqG008YYiPyQRSmj(Flw8YllsAPMZ)r58tOCy9GbDeprqesVKLr8wHlcLRxb5fPYkYJed2QRmBgu1Ez)32WGK63PFUMnYjfRvReGHiK(HvfVLddLsIvlQO(n2axYPrqL)QSuGWqwZNevusXA1krI)3IfVCjXQjuzzKum1vww970pllsAPMZ)r58tOSWfHYA23PFww2yBvoViGSi2cNfRu124maXLdby4wqfKpfGwabstZlhwpyqhXteeH0lzzeVv4IqzITWzXkvTnodqC9kmVivwrEKyWwDLfUiugP3H4oke3YHHYYSzqv7LjfRvR0awFEPbu5VdrPbepAUim5Ldby4wqfKpfGwabstZllJKIPUYY(7quv8womuwwK0snN)JY5Nq5W6bd6iEIGiKEjlJ4TcxekxVcAUIuzf5rIbB1vw4Iq5zMoGDukWqes)WLzZGQ2l7)2ggKm)JTVg5QCiad3cQG8Pa0ciqAAEzzKum1vwwlDaQameH0pCzrsl1C(pkNFcLdRhmOJ4jcIq6LSmI3kCrOC9kmRIuzf5rIbB1vw4Iqz2)rChLcmeH0pCz2mOQ9Y(VTHbjZ)y7RrUkhcWWTGkiFkaTacKMMxwgjftDLLx(pIQameH0pCzrsl1C(pkNFcLdRhmOJ4jcIq6LSmI3kCrOC9kGwrQSI8iXGT6klCrOScmeH0p8oke3YHHYYSzqv7L9FBddsM)X2xJCvoeGHBbvq(uaAbeinnVSmskM6kldyicPFyvXB5Wqzzrsl1C(pkNFcLdRhmOJ4jcIq6LSmI3kCrOC9kqqrQSI8iXGT6klCrOSo8)2DuZS4HYYSzqv7L9FBddsM)X2xJCnBKpt(HH0LULbs7LgqcYJedwrfLuSwTs3YaP9sdijwTOIA(hBFnsPBzG0EPbKgq8O5IWN1eHkhcWWTGkiFkaTacKMMxwgjftDLLjX)BvPv8qzzrsl1C(pkNFcLdRhmOJ4jcIq6LSmI3kCrOC9kmJksLvKhjgSvxzHlcL1bJfmqNMBLzZGQ2l7)2ggKm)JTVg5A2iFM8ddPlDldK2lnGeKhjgSIkkPyTALULbs7LgqsSAcvoeGHBbvq(uaAbeinnVSmskM6kltcJfmqNMBLfjTuZ5)OC(juoSEWGoINiicPxYYiERWfHY1RWmOivwrEKyWwDLzZGQ2lFgNseOcsisHfHlFxZuwgjftDLLhItvNXPFQctxEzrsl1C(pkNFcLfUiuoK4ChLmJt)ChfYqxEzzJTv5YHamClOcYNcqlGaPP5Lz9VgiElvlfgRQRCy9GbDeprqesVKLr8wHlcLjMPXW7OuGHiK(H10okzZyfexVcbtfPYkYJed2QRmBgu1Ez)Wq6s3YaP9sdib5rIbBzzKum1vwEiovDgN(PkmD5LfjTuZ5)OC(juw4Iq5qIZDuYmo9ZDuidD57OqEaHklBSTkxoeGHBbvq(uaAbeinnVmR)1aXBPAPWyvDLdRhmOJ4jcIq6LSmI3kCrOmXmngEhLcmeH0pSM2rTO5gg2rDldX1RqqqrQSI8iXGT6kZMbvTx2pmKUe1aAfpukb5rIbBzzKum1vwEiovDgN(PkmD5LfjTuZ5)OC(juw4Iq5qIZDuYmo9ZDuidD57OqUCcvw2yBvUCiad3cQG8Pa0ciqAAEzw)RbI3s1sHXQ6khwpyqhXteeH0lzzeVv4IqzIzAm8okfyicPFynTJArZnmSJIQL46viqErQSI8iXGT6kZMbvTx2pmKUeMUP3tAUPA8wjipsmyllJKIPUYYdXPQZ40pvHPlVSiPLAo)hLZpHYcxekhsCUJsMXPFUJczOlFhfYNtOYYgBRYLdby4wqfKpfGwabstZlZ6Fnq8wQwkmwvx5W6bd6iEIGiKEjlJ4TcxektmtJH3rPadri9dRPDulAUHHDu4bX1RxMndQAVC9w]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170201.1, [[d8ImcaGErvAxiLTjQmBQCtv0Tr1oLyVKDJy)qsdte)wvdvuvdgkmCr5GivhdQwikzPuLwmswUKEivLNcEmeRJsjtKsHPcLMSknDHlIIUSY1Pu0MPuQTdPCyP(mk1ZPKLjsNxfgnKQ)cfDsiX3OuDAkUNOkEgvXIOQ61OWcxyfWK0uUDflbLMpbGH7dvmy6gFKOD2cvmYQd55uDiWgZ2TnDHyjW7CRTMkPj42tWXtPHlaYgIPDM82H5jQKMlvaDKW8elHvfCHvatst52vSeaivtwiiE2SDJw2hMNyjGoLXzIdbzFyEIauixdshFva5jtqP5tq(FyEIa6v2wcinF5X)D91DGj7AJm)c8o3ARPsAcEoC70s8iWh6dHX5J24JeIsW5FlnFc8FxFDhyYU2iZVcvsfwbmjnLBxXsqP5ta2pghvmoBRy1dbENBT1ujnbphUDAjEeqNY4mXHG4JXXK3wXQhcqHCniD8vbKNmb(qFimoF0gFKquco)BP5tGcv8iScysAk3UILGsZNai(kNXw2Qc8o3ARPsAcEoC70s8iGoLXzIdbwXx5m2YwvakKRbPJVkG8KjWh6dHX5J24JeIsW5FlnFcuOqaGunzHafsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170201.1, [[d0dLoaGEIePnPsQDrjBtc2NkjZKivZMuZNirDtvQdR0TP4BQe7eI9k2TI9tcJIsvdtf9BephjNxfmyIQHtsoerI4uQqogsDCvOSqs0svvzXqA5s6Hsupf1YikRJsL0evHQAQsOjRktxQlss9kvOkxgCDIyJej1PHAZey7e0Rvv(orktJsLyEej8mkLhtLrtO)svDsvv9zQY1uHk3JsfJJijNJsL6GsKdDkgw9SOA4fLHrwdeMXMYkKRwdgy6vBxviNcpEAqHCDn8XheSs0Dug(hOHLccISt6lN00YSOdZQahE1yP0TXKjiYkilCjxJjdvkge6umS6zr1WlkdJSgiSuRxdOqolsCFHzxfRQdlL0y3hE8c)d0Wsbbr2jDb6lwN2cxcfRX9HWc0Rb8PejUVW)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoiYsXWQNfvdVOmmYAGWQ3AlEmj7heMDvSQomQebcSaNibO8jc8BrW3RcB7tjzEqfpEwsuDTzbnvxjglNKAfM(k7ivfc)d0Wsbbr2jDb6lwN2cxcfRX9HWWwBXJjz)GW)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoi2sXWQNfvdVOmmYAGWQ3AlQqolsCFHzxfRQdBwqt1vIXYjPwHPVYo2TSW)anSuqqKDsxG(I1PTWLqXACFimS1w0NsK4(c)FEy32KA4Hmq4YIG77MiemW0bn8n5HSgiC6GyxsXWQNfvdVOmmYAGWCtQMpaub1WSRIv1HxxJfc(WagmqDLTW)anSuqqKDsxG(I1PTWLqXACFimvtQMpaub1W)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoihxkgw9SOA4fLHrwdewTgmW0RwHCL6LQd)d0Wsbbr2jDb6lwN2cxcfRX9HWGgmW0R2hvVuD4)Zd72MudpKbcxweCF3eHGbMoOHVjpK1aHthKcPyy1ZIQHxuggznqyPJpMe8tH871ZSkKxK0Gjm7QyvD411yHGpmGbduxzl8pqdlfeezN0fOVyDAlCjuSg3hcRXhtc(5BwpZ63KgmH)ppSBBsn8qgiCzrW9Dtecgy6Gg(M8qwdeoDqUKIHvplQgErzyK1aHL(kCvixPKkvhMDvSQo8J0wc0Rb8PejUpRkyw8qDLBPA)gBGRDeI(rK24xH11H)bAyPGGi7KUa9fRtBHlHI14(qy9kC9rLuP6W)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoisvkgw9SOA4fLHrwdewQ1RbuiNfjUpfYTN(OWSRIv1HnlOP6kXy5KuRW0xzhzNxJkrGalqdgy6v7lG4Kqzjr11vqqfOexune(hOHLccISt6c0xSoTfUekwJ7dHfOxd4tjsCFH)ppSBBsn8qgiCzrW9Dtecgy6Gg(M8qwdeoDqS7umS6zr1WlkdJSgiS6T2IkKZIe3Nc52tFuy2vXQ6WMf0uDLySCsQvy6RSJuvi8pqdlfeezN0fOVyDAlCjuSg3hcdBTf9PejUVW)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoi0NPyy1ZIQHxuggznq4IKgmkKFVunupeMDvSQomQebcSQafz2Xb(nPbJvfmlEOKc6tPSu2EujceyvbkYSJd8BsdgRkyw8qjf2JkrGaRLYbZBhhy9Ku3gtMJNJq0pI0gRLYbZBhhyvbZIhQJU2ri6hrAJ1s5G5TJdSQGzXdLuqFChf(hOHLccISt6c0xSoTfUekwJ7dHBsdgFZs1q9q4)Zd72MudpKbcxweCF3eHGbMoOHVjpK1aHtheA6umS6zr1WlkdJSgiS6T2IhtY(bkKBp9rHzxfRQdJkrGalWjsakFIa)we89QW2(usMhuXJNLevH)bAyPGGi7KUa9fRtBHlHI14(qyyRT4XKSFq4)Zd72MudpKbcxweCF3eHGbMoOHVjpK1aHtheAzPyy1ZIQHxuggznqyPJ9e7bpEkKRKO7WSRIv1HrLiqGLkI0GQprGFlc(Mf0uDLySKO6611yHGpmGbdusHTRFaQebcS0ypXEWJNFL8SEePnH)bAyPGGi7KUa9fRtBHlHI14(qyn2tSh845Js0D4)Zd72MudpKbcxweCF3eHGbMoOHVjpK1aHtheABPyy1ZIQHxuggznqyPJ9e7bpEkKRKOBfYTN(OWSRIv1HrLiqGLkI0GQprGFlc(Mf0uDLySKO6611yHGpmGbdusHTW)anSuqqKDsxG(I1PTWLqXACFiSg7j2dE88rj6o8)5HDBtQHhYaHllcUVBIqWath0W3KhYAGWPdcTDjfdREwun8IYWiRbcxwCXJc5sh7j2dE8cZUkwvhEDnwi4ddyWa1v0xVUgle8HbmyG6k6RFaQebcS0ypXEWJNFL8SEePnH)bAyPGGi7KUa9fRtBHlHI14(qyN4IhFn2tSh84f()8WUTj1WdzGWLfb33nriyGPdA4BYdznq40bH(4sXWQNfvdVOmmYAGWLfx8OqU0XEI9GhpfYTN(OWSRIv1HxxJfc(WagmqDf91RRXcbFyadgOUIo8pqdlfeezN0fOVyDAlCjuSg3hc7ex84RXEI9GhVW)Nh2TnPgEideUSi4(UjcbdmDqdFtEiRbcNoi0fsXWQNfvdVOmmYAGWsh7j2dE8uixjr3kKBVSJcZUkwvh(bOseiWsJ9e7bpE(vYZ6rK2e(hOHLccISt6c0xSoTfUekwJ7dH1ypXEWJNpkr3H)ppSBBsn8qgiCzrW9Dtecgy6Gg(M8qwdeoDqOVKIHvplQgErz4sOynUpewJ9e7bpE(OeDh()8WUTj1WdzGWiRbclDSNyp4XtHCLeDRqU92okC5donuCREqtf0W)anSuqqKDsxG(I1PTWLQEuHDhCAWV3Qh0u25bOseiWsJ9e7bpE(vYZsIQWLfb33nriyGPdA4BYdznq40bHwQsXWQNfvdVOmm7QyvD4kiOcuIlQgcxcfRX9HWc0Rb8PejUVW)Nh2TnPgEide(MiepEHPdJSgiSuRxdOqolsCFkKBVSJcxQ6rf2qeIhp7qh(hOHLccISt6c0xSoTfUSi4(UjcbdmDug(M8qwdeoDqOT7umS6zr1WlkdxcfRX9HWWwBrFkrI7l8)5HDBtQHhYaHVjcXJxy6WiRbcRERTOc5SiX9PqU9YokCPQhvydriE8SdD4FGgwkiiYoPlqFX60w4YIG77MiemW0rz4BYdznq40br2zkgw9SOA4fLHlHI14(qyb61a(uIe3x4)Zd72MudpKbcFteIhVW0HrwdewQ1RbuiNfjUpfYT32rHlv9OcBicXJNDOd)d0Wsbbr2jDb6lwN2cxweCF3eHGbMokdFtEiRbcNoDy2vXQ6WPta]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170201.1, [[d4JFoaGEKsvTjII2Le2gLY(ikmtfihwPztX8jkHBQqFtICBs9CKStvSxXUv1(jjJsb1WKu)gLZtsDAcdMenCs4qiLkDkfKJHOJRa1cjQwksXIry5u5HkIvrukwgQ06ikLMisPktvIAYOQPl1fPeVcPuXLbxxLSrfqVws2SIA7OIpJu9mkPPruI(UcG)Qs9yQA0ezEiLYjvKghrjDnIs19qk5Cka9uOdsP6qMYbT8lHb4J8GNvdbrHEIkLwmGg(EnYwvkPepDdOsPyoiThmVxMoYdsdyGLcYHBnzPAssUfKbrfGxSgbT)2c2NdxBCdA33c2tLY5qMYbT8lHb4J8GNvdbhOz1GkLOeZxfe9oHIoiTBl8vINEqAadSuqoCRjTrwQO2Aq7ecJOvhC2SA4MsI5Rco95f(TzUGp7HGtKaF1iJdOHVdrWrg)z1qW05WnLdA5xcdWh5bpRgcAzDT0GV2kii6DcfDqIR55cWlXaQB28Dlb30DW23uxpp4ep9IlfYuVGHQDmDH)Y5GVLbTKvBbPbmWsb5WTM0gzPIARbTtimIwDqyDT0GV2ki40Nx43M5c(Shcorc8vJmoGg(oebhz8NvdbtNJ1uoOLFjmaFKh8SAiOL11sQuIsmFvq07ek6G6fmuTJPl8xoh8TmO1aYninGbwkihU1K2ilvuBnODcHr0QdcRRLUPKy(QGtFEHFBMl4ZEi4ejWxnY4aA47qeCKXFwnemDoYYuoOLFjmaFKh8SAii2mNUcafGlinGbwkihU1K2ilvuBnODcHr0Qds1mNUcafGl40Nx43M5c(Shcorc8vJmoGg(oebhz8NvdbtNJSNYbT8lHb4J8GNvdbTyan89AuPuUzP6G0agyPGC4wtAJSurT1G2jegrRoiyan89AUjmlvhC6Zl8BZCbF2dbNib(QrghqdFhIGJm(ZQHGPZXwkh0YVegGpYdEwneCQhMVCQdIENqrhuVGHQDmDH)Y5GVPnAvYwqAadSuqoCRjTrwQO2Aq7ecJOvhu4H5lN6GtFEHFBMl4ZEi4ejWxnY4aA47qeCKXFwnemDoLs5Gw(LWa8rEWZQHGdsm4lbVkLJlD9Qszzwd6GO3ju0bxFl4a3WdAbqjdRbPbmWsb5WTM0gzPIARbTtimIwDqJyWxc(B9sxV3nRbDWPpVWVnZf8zpeCIe4RgzCan8DicoY4pRgcMohznLdA5xcdWh5bpRgcoibDP(fpDvkLZmDq07ek6GexZZfkyda4UzZ3TeCRxWq1oMU4sHmjUMNlOAMtxbGcWvCPqMRVfCGB4bTaOOnRbPbmWsb5WTM0gzPIARbTtimIwDqJGUu)IN(nbZ0bN(8c)2mxWN9qWjsGVAKXb0W3Hi4iJ)SAiy6CgWuoOLFjmaFKh8SAi4GwoRkLYVCuDq07ek6G8SUy2SA4MsI5RkCGEfpLm8lvF3cnitpJz4zdWF7G13bPbmWsb5WTM0gzPIARbTtimIwDqZYzVjUCuDWPpVWVnZf8zpeCIe4RgzCan8DicoY4pRgcMohY6uoOLFjmaFKh8SAi4aDmQwLsuI5RcIENqrhK4AEUq4H5lN6IlfYC4H1lyOAhtx4VCo4BzqlU1djlKfexZZfcpmF5ux4a9kEkAByYczx2qPamMBPLQbzdX18CHWdZxo1fu96RODihAOG0agyPGC4wtAJSurT1G2jegrRo4SJr13usmFvWPpVWVnZf8zpeCIe4RgzCan8DicoY4pRgcMohsYuoOLFjmaFKh8SAi4anRguPeLy(kvkhMCOGO3ju0b1lyOAhtx4VCo4BzqlU1YK4AEUamGg(En3Zm)fvXLcz6GzhqjTegiinGbwkihU1K2ilvuBnODcHr0QdoBwnCtjX8vbN(8c)2mxWN9qWjsGVAKXb0W3Hi4iJ)SAiy6Ci5MYbT8lHb4J8GO3ju0bjUMNleEy(YPU4srq7ecJOvhC2XO6BkjMVk40Nx43M5c(ShcoY4iE6bjdEwneCGogvRsjkX8vQuom5qbT7OtfuZ4iE60IminGbwkihU1K2ilvuBn4ejWxnY4aA47ip4iJ)SAiy6CiTMYbT8lHb4J8GNvdbTSUwsLsuI5RuPCyYHcIENqrhuVGHQDmDH)Y5GVLbTKvBbPbmWsb5WTM0gzPIARbTtimIwDqyDT0nLeZxfC6Zl8BZCbF2dbNib(QrghqdFhIGJm(ZQHGPZHuwMYbT8lHb4J8GNvdblZAqRs54s1GtDq07ek6GexZZfoGI977H7M1GUWb6v8u0gzDqAadSuqoCRjTrwQO2Aq7ecJOvhSznOV1lvdo1bN(8c)2mxWN9qWjsGVAKXb0W3Hi4iJ)SAiy6CiL9uoOLFjmaFKh8SAiOL11sd(ARavkhMCOGO3ju0bjUMNlaVedOUzZ3TeCt3bBFtD98Gt80lUueKgWalfKd3AsBKLkQTg0oHWiA1bH11sd(ARGGtFEHFBMl4ZEi4ejWxnY4aA47qeCKXFwnemDoK2s5Gw(LWa8rEWZQHGdsqxQFXtxLs5mtRs5WKdfe9oHIoiX18CHc2aaUB28Dlb36fmuTJPlUuiZ13coWn8Gwau0M1G0agyPGC4wtAJSurT1G2jegrRoOrqxQFXt)MGz6GtFEHFBMl4ZEi4ejWxnY4aA47qeCKXFwnemDoKLs5Gw(LWa8rEWZQHGtKwXRs5Ge0L6x80dIENqrhC9TGdCdpOfaLmiL56Bbh4gEqlakzqgKgWalfKd3AsBKLkQTg0oHWiA1b9sR4Vnc6s9lE6bN(8c)2mxWN9qWjsGVAKXb0W3Hi4iJ)SAiy6CiL1uoOLFjmaFKh8SAi4Ge0L6x80vPuoZ0Quom3HcsdyGLcYHBnPnYsf1wdANqyeT6GgbDP(fp9BcMPdo95f(TzUGp7HGtKaF1iJdOHVdrWrg)z1qW05qoGPCql)sya(ipi6DcfDqhm7akPLWabTtimIwDWzZQHBkjMVk40Nx43M5c(ShcoY4iE6bjdEwneCGMvdQuIsmFLkLdZDOG2D0PcQzCepDArgKgWalfKd3AsBKLkQTgCIe4RgzCan8DKhCKXFwnemDoCRt5Gw(LWa8rEq7ecJOvhewxlDtjX8vbN(8c)2mxWN9qWrghXtpizWZQHGwwxlPsjkX8vQuom3HcA3rNkOMXr80PfzqAadSuqoCRjTrwQO2AWjsGVAKXb0W3rEWrg)z1qW05WLmLdA5xcdWh5bTtimIwDWzZQHBkjMVk40Nx43M5c(ShcoY4iE6bjdEwneCGMvdQuIsmFLkLdBDOG2D0PcQzCepDArgKgWalfKd3AsBKLkQTgCIe4RgzCan8DKhCKXFwnemD6GO3ju0btNaa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170201.1, [[dWZthaGEIc1MKqTlPY2eH9rusZeK0Sr1nLONJu3MKdlStPSxQDRy)IOFsuqdtunoIc5BIuNxQQbtQA4GuhKuCkII6yi5CGezHi0sLuwmOwoIEOi5PqlJiTosL0ejkWujLMSsnDGlsuDAuUSQRlbBKOiVgbBMuX2LKpdIhRKPjH08Kq8xI4zsQgTO8DqI6KsvoePsDnIsCpqc)MWXjk1OivInL1Au(eW8VnrJTqDJitLkPE58R(acUUMuVgzOCJYGRtuGdmrJ1o)b9DtAov6CkkPDugrO)IfCMmoamX4M0esnQzbyIH2ADJYAnkFcy(3MOXwOUreiive(H(KgRD(d67M0CQeuP7YRBudmJZa9nsdeKkc)qFsJ9MnBfabPXrm3yQSViukQU6dWWglf7wOUrdCtQ1Au(eW8VnrJTqDJAOxF2XSUrCrYGgyeiGaH)ULqW3cO8qBS25pOVBsZPsqLUlVUrnWmod03yqV(SJzDJ9MnBfabPXrm3yQSViukQU6dWWglf7wOUrdCRU1Au(eW8VnrJTqDJqLj7cSDs9LbevKuVwb4kJ1o)b9DtAovcQ0D51nQbMXzG(g5mzxGTLOciQqcqaUYyVzZwbqqACeZnMk7lcLIQR(amSXsXUfQB0a3kQ1Au(eW8VnrJTqDJYepupPEmtSiyexKmObgJfGvDjFUID6Iu0IvX50asHQBvGK8dqwHcP5fRBqW)a64mizGHnqKqk2DFcy(3gRD(d67M0CQeuP7YRBudmJZa9nQdpuxcDMyrWyVzZwbqqACeZnMk7lcLIQR(amSXsXUfQB0a3KfR1O8jG5FBIgBH6gLhKGmzxiiCJ1o)b9DtAovcQ0D51nQbMXzG(gFqcYKDHGWn2B2SvaeKghXCJPY(IqPO6QpadBSuSBH6gnWTewRr5taZ)2en2c1nc1OksQNybsAGrCrYGgyClaD6Wd1LqNjwe6iVkydTSUcAGeat9IHlOJoD8OkKqxGeY7kaDX6ge8pGoodsgyydejKID3NaM)DXXcWQUKpxXoDrkQXAN)G(UjnNkbv6U86g1aZ4mqFJ8OkKaxGKgyS3SzRaiinoI5gtL9fHsr1vFag2yPy3c1nAGBPTwJYNaM)TjASfQBuo)QpGGNuprEqdmIlsg0aJ6ge8pGoodsgyydejKID3NaM)DXXcWQUKpxXoDrKfJ1o)b9DtAovcQ0D51nQbMXzG(gp)QpGGlbMh0aJ9MnBfabPXrm3yQSViukQU6dWWglf7wOUrdCtgzTgLpbm)Bt0ylu3iuJQiPEIpugRD(d67M0CQeuP7YRBudmJZa9nYJQqc8dLXEZMTcGG04iMBmv2xekfvx9byyJLIDlu3ObUbLSwJYNaM)TjASfQBmvwWMK6HkdsgyydeJ1o)b9DtAovcQ0D51nQbMXzG(gxzbBKWzqYadBGyS3SzRaiinoI5gtL9fHsr1vFag2yPy3c1nAGBu5wRr5taZ)2enQbMXzG(g5rvibUajnWyVzZwbqqACeZnwkQydeJugBH6gHAufj1tSajniPEDHsMnQHecTrLOInqGckJ1o)b9DtAovcQ0D51nMk7lcLIQR(amrJLIDlu3ObUrrzTgLpbm)Bt0iUizqdmsEDipDwaZVrnWmod03Oo8qDj0zIfbJ9MnBfabPXrm3yPOInqmszSfQBuM4H6j1JzIfHK61fkz2Ogsi0gvIk2abkOmw78h03nP5ujOs3Lx3yQSViukQU6dWenwk2TqDJgyGrCrYGgy0aB]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170201.1, [[d0ZRpaGEisvBIIyxezBuL2hvQMjvkMnLMpej3ecpMu3MKdlStiTxPDRy)uHrrv0WevJdQQ6BQq3dQkdMkA4ivhKQQtrv4yi5CqKYcPOwkuPfdLLlYdHkEkQLruwhfPQjcrQmvvWKvvtxPlsL8kksLldUUOSrOQYPjSzvY2rk)vL67uKmnicnpQu65QYHOiLrtHNrv5Kqv(mr11Gi48quVwf9BehhIOlvpu21eyw4xZLrdfuMfkCC40LfuWSH107W5tmYTGdNXtxgPdUIm7wZLXfSq8GIklN6yofLmjQYmDqlcRaPpwbzkQmVYk7xVcY86HIs1dLDnbMf(1Cz0qbL9)0W8JrdLzDsqFlVe5YTGKMqSFIPMNjE(jR0LnuW9ZGOpLsGkeZZDSSRlP4PH5hJgK(zPyfKXepxHcChFEZrkKcl76scZsiFB2BLYO7HjAcX(jMAKSbT4gll9wPeOcX8Cp3etdl76s6TKK6ea6qskJUhLXfSq8GIklNYl1rPCFL9JjSIf5YXtdZpgnugV5l0XssLhYaLXXa0Nii0afmBXkJG8rdfuUBrL1dLDnbMf(1Cz0qbLXpBOahozdI(SmRtc6BztBf6tXiVmUGfIhuuz5uEPokL7RSFmHvSix(Ygk4(zq0NLXB(cDSKu5HmqzCma9jccnqbZwSYiiF0qbL7wuF9qzxtGzHFnxgnuqz8ZgkWHt2GOpD40tkpkZ6KG(wwfG9TjIssNLsWSUJpz5MKaviMNBXhw21Lu80W8Jrds)SuScYyIMqSFIPgP4PH5hJgKsGkeZZ0HLDDjfpnm)y0G0plfRGmUfF)SuScYugxWcXdkQSCkVuhLY9v2pMWkwKlFzdfC)mi6ZY4nFHowsQ8qgOmogG(ebHgOGzlwzeKpAOGYDlksShk7Acml8R5YOHck7ksRbsMfNqzwNe03YyzxxsG2GaVBY19Aa3YtqS3VS5djXixkJUjMgw21Lu80W8Jrdsz0nrfG9TjIssNLsWSUJp83BzCblepOOYYP8sDuk3xz)ycRyrUmeP1ajZItOmEZxOJLKkpKbkJJbOprqObky2Ivgb5JgkOC3IIe6HYUMaZc)AUmAOGYUI0A4WjBq0NLzDsqFlRcW(2erjPZsjyw3XhstMjMgw21Lu80W8Jrdsz0lJlyH4bfvwoLxQJs5(k7htyflYLHiTg3pdI(SmEZxOJLKkpKbkJJbOprqObky2Ivgb5JgkOC3I6Thk7Acml8R5YOHckZljPobGoKkJlyH4bfvwoLxQJs5(k7htyflYLFljPobGoKkJ38f6yjPYdzGY4ya6teeAGcMTyLrq(OHck3TOh7HYUMaZc)AUmAOGYUSGcMnSoCA2gVTmUGfIhuuz5uEPokL7RSFmHvSixgSGcMnS3y24TLXB(cDSKu5HmqzCma9jccnqbZwSYiiF0qbL7wu8Vhk7Acml8R5YOHck7gbsMj(oCIiKRchopqwqvM1jb9TCOxbn4ggqjGN7(kJlyH4bfvwoLxQJs5(k7htyflYLTcKmt8VvHCvCVKfuLXB(cDSKu5HmqzCma9jccnqbZwSYiiF0qbL7wuKwpu21eyw4xZLrdfu2nc5g7ig5oCAMy3YSojOVLXYUUKOtmfKUjx3RbCRcW(2erjLr3eSSRlP3ssQtaOdjPm6Me6vqdUHbuc45wFLXfSq8GIklNYl1rPCFL9JjSIf5YwHCJDeJ8BmIDlJ38f6yjPYdzGY4ya6teeAGcMTyLrq(OHck3TOu59qzxtGzHFnxgnuqz3e0chonNLEBzwNe03YFYkDzdfC)mi6tPeOcX8CxhV9EfkWep1eI9tm1CNGqVifsHLDDjfpnm)y0GugDpkJlyH4bfvwoLxQJs5(k7htyflYLTbT4gll92Y4nFHowsQ8qgOmogG(ebHgOGzlwzeKpAOGYDlkfvpu21eyw4xZLrdfug)SHcC4Kni6tho9uMhLzDsqFlRcW(2erjPZsjyw3XNSCtWYUUKalOGzd79frN9KYOxgxWcXdkQSCkVuhLY9v2pMWkwKlFzdfC)mi6ZY4nFHowsQ8qgOmogG(ebHgOGzlwzeKpAOGYDlkLSEOSRjWSWVMlJgkOSRiTgoCYge9PdNEs5rzwNe03YQaSVnrus6SucM1D8H)ElJlyH4bfvwoLxQJs5(k7htyflYLHiTg3pdI(SmEZxOJLKkpKbkJJbOprqObky2Ivgb5JgkOC3Is5Rhk7Acml8R5YOHckFGSGYHteXBHeYLzDsqFlJLDDjLGhzIrd3lzbLucuHyEULkhPqkpXYUUKsWJmXOH7LSGskbQqmp36jw21Lu80W8Jrds)SuScYy60eI9tm1ifpnm)y0GucuHyEEyIMqSFIPgP4PH5hJgKsGkeZZTuibpkJlyH4bfvwoLxQJs5(k7htyflYLxYcQBv8wiHCz8MVqhljvEidughdqFIGqduWSfRmcYhnuq5UfLcj2dLDnbMf(1Cz0qbLDfP1ajZItWHtpP8OmRtc6BzSSRljqBqG3n56EnGB5ji27x28HKyKlLrVmUGfIhuuz5uEPokL7RSFmHvSixgI0AGKzXjugV5l0XssLhYaLXXa0Nii0afmBXkJG8rdfuUBrPqc9qzxtGzHFnxgnuqz3e0chondHQmRtc6B5qVcAWnmGsap3Pmj0RGgCddOeWZDQY4cwiEqrLLt5L6OuUVY(XewXICzBqlUXGqvgV5l0XssLhYaLXXa0Nii0afmBXkJG8rdfuUBrP82dLDnbMf(1Cz0qbLDJqUXoIrUdNMj21HtpP8OmRtc6BzSSRlj6etbPBY19Aa3QaSVnrusz0nj0RGgCddOeWZT(kJlyH4bfvwoLxQJs5(k7htyflYLTc5g7ig53ye7wgV5l0XssLhYaLXXa0Nii0afmBXkJG8rdfuUBrPo2dLDnbMf(1Cz0qbLXXieJdNUri3yhXiVmRtc6B5qVcAWnmGsap3Pmj0RGgCddOeWZDQY4cwiEqrLLt5L6OuUVY(XewXICzTriMBRqUXoIrEz8MVqhljvEidughdqFIGqduWSfRmcYhnuq5UfLc)7HYUMaZc)AUmAOGYUri3yhXi3HtZe76WPNY8OmUGfIhuuz5uEPokL7RSFmHvSix2kKBSJyKFJrSBz8MVqhljvEidughdqFIGqduWSfRmcYhnuq5UfLcP1dLDnbMf(1CzwNe03Yj4kbpJaZcL9JjSIf5Yx2qb3pdI(SmEZxOJLKkpKbkJGqtmYltvgnuqz8ZgkWHt2GOpD40tFEu2Fs(RSIqtmYXhvzCblepOOYYP8sDuk3xzCma9jccnqbZwZLrq(OHck3TOYY7HYUMaZc)AUSFmHvSixgI0AC)mi6ZY4nFHowsQ8qgOmccnXiVmvz0qbLDfP1WHt2GOpD40tzEu2Fs(RSIqtmYXhvzCblepOOYYP8sDuk3xzCma9jccnqbZwZLrq(OHck3TOYO6HYUMaZc)AUSFmHvSix(Ygk4(zq0NLXB(cDSKu5HmqzeeAIrEzQYOHckJF2qboCYge9PdNEIe9OS)K8xzfHMyKJpQY4cwiEqrLLt5L6OuUVY4ya6teeAGcMTMlJG8rdfuUB3YSojOVL72c]] )

    storeDefault( [[SEL Elemental Ascendance]], 'actionLists', 20170201.1, [[d4tJoaGEefvBsvQDbQTjK2NKWmru1Jjz2OA(sI6MikCyQ(MKYTLyNi1Ev2Tk7NumkjvnmHACik15jvonWGjLgUQYbLKoLQihdjNtsKwif1svfwmclNsperLEkXYuv9CrnrefLPketgKPl1fPqVcrjUm01fPnkPIxtQAZcA7isFMc(UQOMgIsAEicpJICievmArmEefXjvL8xbUMKiUhIOvIOi9BuoUKk9OwKjgpNGJqZ8eAVGteJKxJwJCSGx7CnARMv4b5NcNiFOc4CazU3a2n6)O)tEGC0Z4O)JPQftr9dtnruwWxpzsvvdyxErgn1ImX45eCeAMNikl4RN0mdg4iSIX4qSNV8BiwdhY9cgKtyk9WwS4GlxbrAyiSNv4b5NcHHsTEdy3BfJXHypFWCNupGi1MBylwCWLRi(n5qKggcNBMTOhXp0cN(nPkbGdADt8Scpi)u4Kxheq5nZo5yho5bYrpJJ(pMkkvn4yttO9coPAwHhKFkC9O)xKjgpNGJqZ8eYWjtaL0se3Aa78etteLf81tiNgO0dodtQsa4Gw3KqUxWGCctPFYRdcO8MzNCSdNq7fCsD4Eb1Ovsyk9tixDkogXTgWopIjpqo6zC0)XurPQbhBAIKWEMmyqGqaAZJy9OnTitmEobhHM5jIYc(6jfh552YkWQuRfVUcs(h)2IfhCzsqsI0WqypRWdYpfcdLA9gWU3kgJdXE(G9Scpi)uiSflo4YKfI0WqypRWdYpfcdLA9gWosqsOuR3a2nPkbGdADtc5EbdYjmL(jVoiGYBMDYXoCcTxWj1H7fuJwjHP0RrB9upn5bYrpJJ(pMkkvn4ytRhnzDrMy8CcocnZteLf81tisddHrvcdZbSWGobdmyrVdYPheAbNb40V3KdrAyiSNv4b5NcHt)ExCKNBlRubjj7OAitN8a5ONXr)htfLQgCSPjVoiGYBMDYXoCsvcah06MGUTtQBQRhNq7fCIr32j1n11JRhDLSitmEobhHM5jIYc(6jfh552YkWQuRfVUcswP)VjhI0WqypRWdYpfcN(n5bYrpJJ(pMkkvn4yttEDqaL3m7KJD4KQeaoO1nbDBNeKtyk9tO9coXOB7enALeMs)6rhDrMy8CcocnZteLf81tAMbdCe2Tni0vDGta4Gw3KQeaoO1nj3mBrpIFODYdKJEgh9FmvuQAWXMMijSNjdgeieG28iMq7fCI0mBrpIFODYRdcO8MzNCSdxp6AlYeJNtWrOzEIOSGVEYKhih9mo6)yQOu1GJnn51bbuEZSto2HtQsa4Gw3eKJf8ANhqW9CpH2l4eJCSGx7CnAnZ9CVE0K9ImX45eCeAMNikl4RN4QgqkgGhwayUcsAAsvcah06MWb1nfafuCdfpOznwM86GakVz2jh7Wjpqo6zC0)XurPQbhBAcTxWjKhu3uaKgTKHBO4A0gH1yz9OR0fzIXZj4i0mpruwWxpHinme(J9mAdyHbDcguCKNBlRaN(9Minmeo3mBrpIFOfo97TRAaPyaEybGzsyAYdKJEgh9FmvuQAWXMM86GakVz2jh7WjvjaCqRBchyiPpWziGGX7j0EbNqEGHK(aNbnAnZ496rtfVitmEobhHM5jIYc(6jqSgoK7fmiNWu6HTyXbxUcLN7GguW31Rymoe75lWIUQRCLjsddH9Scpi)uiC63ttEGC0Z4O)JPIsvdo20Kxheq5nZo5yhoPkbGdADt4oPEarQn3tO9coH8oPUgTMtT5E9OPOwKjgpNGJqZ8erzbF9KIJ8CBzLki5F8BI0WqyKJf8ANheYuPz40V3wm0I5eNGJtQsa4Gw3KqUxWGCctPFYRdcO8MzNCSdN8a5ONXr)htfLQgCSPj0EbNuhUxqnALeMsVgT1))06rt9VitmEobhHM5jIYc(6jfh552YkWQuRfVUcs(h)Minmeg5ybV25bHmvAgo97TRAaPyaeRHd5EbdYjmLEsuVRAaPyaEybGzsqstVDvdifdWdlamx5kB6Pjpqo6zC0)XurPQbhBAYRdcO8MzNO0P44eAVGtQd3lOgTsctPxJwYvNIJtQsa4Gw3KqUxWGCctPF9OPmTitmEobhHM5jIYc(6jfh552YkWQuRfVUcss2rN8a5ONXr)htfLQgCSPjVoiGYBMDYXoCsvcah06MGUTtcYjmL(j0EbNy0TDIgTsctPxJ26PEA9OPiRlYeJNtWrOzEIOSGVEcrAyiCZASeu8CJwDWwS4GltcQ4kx56jsddHBwJLGINB0Qd2IfhCzsqKggc7zfEq(PqyOuR3a2rwumghI98b7zfEq(PqylwCWLFRymoe75d2Zk8G8tHWwS4GltcQk5Pjpqo6zC0)XurPQbhBAYRdcO8MzNCSdNq7fCsewJfnAjdp3Ov3KQeaoO1nPznwckEUrRU1JMQswKjgpNGJqZ8erzbF9eI0WqyuLWWCalmOtWadw07GC6bHwWzao9Bsvcah06MGUTtQBQRhN86GakVz2jh7Wjpqo6zC0)XurPQbhBAcTxWjgDBNu3uxpQrB9upTE0urxKjgpNGJqZ8erzbF9ex1asXa8WcaZvq92vnGumapSaWCfutEGC0Z4O)JPIsvdo20Kxheq5nZo5yhoPkbGdADt4oPEab6Lj0EbNqENuxJwZOxwpAQAlYeJNtWrOzEIOSGVEcrAyi8h7z0gWcd6emO4ip3wwbo97TRAaPyaEybGzsyAYdKJEgh9FmvuQAWXMM86GakVz2jh7WjvjaCqRBchyiPpWziGGX7j0EbNqEGHK(aNbnAnZ4TgT1t906rtr2lYeJNtWrOzEIOSGVEIRAaPyaEybG5kOM8a5ONXr)htfLQgCSPjVoiGYBMDYXoCsvcah06MOsCWfWbgs6dCgMq7fCc5M4GtJwYdmK0h4mSE0uv6ImX45eCeAMNikl4RNm5bYrpJJ(pMkkvn4yttEDqaL3m7KJD4eAVGtipWqsFGZGgTMz8wJ26)FAsvcah06MWbgs6dCgciy8E9O)JxKjgpNGJqZ8erzbF9KcJuWz4TfdTyoXj44Khih9mo6)yQOu1GJnn51bbuEZSto2HtO9coPoCVGA0kjmLEnAR30ttQsa4Gw3KqUxWGCctPF9O)PwKjgpNGJqZ8erzbF9ex1asXa8WcaZvq92vnGumaI1WHCVGb5eMspjCvdifdWdlamp5bYrpJJ(pMkkvn4yttEDqaL3m7KJD4eAVGtQd3lOgTsctPxJ26jxDkoQr7)ttQsa4Gw3KqUxWGCctPF9O))xKjgpNGJqZ8eAVGtm62orJwjHP0RrB9)pn5bYrpJJ(pMkkvn4yttEDqaL3m7KJD4KQeaoO1nbDBNeKtyk9teLf81tkmsbNH1RNqMHHEkVN51B]] )

    storeDefault( [[SEL Elemental Icefury]], 'actionLists', 20170201.1, [[deKtoaqiufP2efQrraNcvPvHQq8kufkZcvrYUi0We4yOyzQONrqtdvr11qvu2gf5BuvnoufCovaMhfI7Ps0(ujCqHQfsr9qcetevHQlsbBKa1jfkRufqVevH0mPq6MQGANO0svHEkYuPQSxP)kObJQ6WkTyu5XuAYuXLbBMk9zOQrtvoTQEnuz2K62kA3q(njdxL64QaTCIEUctx01fY2vj9DcKgpQIW5HsRhvr08vbz)qXLP(kzaTCAWPMlrw5FNLkXJdUBKoR5shbnSdOSNbm(dyyofzkr3G9x9ZtU5RqL900zP428vOr9vwM6RKb0YPbNAUezL)DwINoFlUhHVuCUx)j2sU6DcHdpLfxPyiN3UPswcPqqPJGg2bu2Zagtm(fdewIDNqjbR3jGHp5PS4WWxGaEBw2Z6RKb0YPbNAUezL)DwIlY1veSEkyeQCdtpieVe2mCeHCa5JWlgDB8Cb9iLQPOnskbuEXL8GPshbnSdOSNbmMy8lgiSumKZB3ujlHuiOe7oHsgwz6DWOfhuko3R)eBjyLP3bJwCqZYkS(kzaTCAWPMlrw5FNL4ICDfFl4gjXkgDB8Cb9iLQPOnskbuEXL8GPsX5E9Nyl5kvJmC4PS4kfd582nvYsifckDe0WoGYEgWyIXVyGWsS7ekjyPAKy4tEklUMLLNxFLmGwon4uZLiR8VZsZf0JuQMI2iPeq5fxEaNyoWshbnSdOSNbmMy8lgiSumKZB3ujlHuiOe7oHsgwz6HHp5PS4kfN71FITeSY0lC4PS4AwwEw9vYaA50GtnxIDNqjkvYjoaUbzP4CV(tSLgPsoXbWnilfd582nvYsifckrw5FNLsfE8AqCL57U2mC5E9NynwG1M)vieqW8HXfmh6qdiZhHFiU4XlHX4VcHJujN4a4gK8w6iOHDaL9mGXeJFXaHnlRP6RKb0YPbNAUezL)DwQ0rqd7ak7zaJjg)Ibclfd582nvYsifckXUtOKbnmbuUAm8nR3rwko3R)eBjqdtaLRoKtVJSzz9xFLmGwon4uZLiR8VZsZf0JuQMI2iPeqPrU0VPsX5E9Nyl9wWnsITumKZB3ujlHuiO0rqd7ak7zaJjg)IbclXUtOuml4gjX2SS8q9vYaA50GtnxISY)olT28VcHacMpmU4sHLIZ96pXws)hm6DcNl(5gMQeMLIHCE7MkzjKcbLy3juYO)bJEhm8p8IFUy47tLWS0rqd7ak7zaJjg)IbcBw2dO(kzaTCAWPMlrw5FNL4ICDfVvckidvUHPheoxqpsPAkgDBmxKRR4ivYjoaUbPy0TXRn)RqiGG5ddJiSuCUx)j2s6hVxIEe(qoLolfd582nvYsifckDe0WoGYEgWyIXVyGWsS7ekz0hVxIEeEm8nR0jg(cq8O82SSmb1xjdOLtdo1CjYk)7SKJkfD17echEklorjm3hnUWUJmm)jG5alDe0WoGYEgWyIXVyGWsXqoVDtLSesHGsS7ekz096IHV5i5ilfN71FITKEVUHCrYr2SSmm1xjdOLtdo1CjYk)7SexKRR4Bb3ijwXOBJfyUGEKs1u0gjLakV4YZGdDiUixxX3cUrsSIsyUpAyebWBD4r4ICDfFl4gjXkoY1IJhJHxElfN71FITKRunYWHNYIRumKZB3ujlHuiO0rqd7ak7zaJjg)IbclXUtOKGLQrIHp5PS4WWxagEBwwMZ6RKb0YPbNAU0HxEIFgn9Ts8qokjSezL)DwAUGEKs1u0gjLakV4YZaJ5ICDfbnmbuU6qxLnAigDBSeCLWWB50aMdSuCUx)j2sU6DcHdpLfxPyiN3UPswcPqqj2DcLeSENag(KNYIRKGG1QbFRepKJYv6iOHDaL9mGXeJFXaHLipLGEyLZ7(GCuUMLLry9vYaA50GtnxISY)olnxqpsPAkAJKsaLxC5zGXCrUUIGgMakxDORYgneJUnwabwB(xHqabZhgxEA8AZ)ke6Osrx9oHWHNYIZiN8EOdjWAZ)keciy(W4IlfA8AZ)ke6Osrx9oHWHNYIZic5L3sX5E9Nyl5Q3jeo8uwCLIHCE7MkzjlwRgkXUtOKG17eWWN8uwCy4ladVLocAyhqzpdymX4xmqyZYYWZRVsgqlNgCQ5sKv(3zPP66JWZtXf56k(wWnsIvm6UuCUx)j2sUs1idhEklUsXqoVDtLSesHGshbnSdOSNbmMy8lgiSe7oHscwQgjg(KNYIddFbo5Tzzz4z1xjdOLtdo1CjYk)7S0Cb9iLQPOnskbuEXL8GPsX5E9NylbRm9chEklUsXqoVDtLSesHGsS7ekzyLPhg(KNYIddFby4T0rqd7ak7zaJjg)IbcBwwgt1xjdOLtdo1CjYk)7SexKRROegk0ISqyQsykkH5(OHryckDe0WoGYEgWyIXVyGWsXqoVDtLSesHGsX5E9NylLQeMHZDKGeBj2DcL8PsyIH)H3rcsSnllJ)6RKb0YPbNAUezL)DwIlY1veSEkyeQCdtpieVe2mCeHCa5JWlgDx6iOHDaL9mGXeJFXaHLIHCE7MkzjKcbLIZ96pXwcwz6DWOfhuIDNqjdRm9oy0IdWWxagEBwwgEO(kzaTCAWPMlXUtOKrF8Ej6r4XW3SsNLocAyhqzpdymX4xmqyPyiN3UPswcPqqjYk)7SexKRR4TsqbzOYnm9GW5c6rkvtXOBJxB(xHqabZhggryP4CV(tSL0pEVe9i8HCkD2SSmhq9vYaA50GtnxISY)olT28VcHacMpmUGP0rqd7ak7zaJjg)Ibclfd582nvYsifckfN71FITK1BFuO(X7LOhHVe7oHscI3(im8n6J3lrpcFZYEguFLmGwon4uZLiR8VZsLIZ96pXws)49s0JWhYP0zPyiN3UPswcPqqj2DcLm6J3lrpcpg(Mv6edFby4TuCj(rPshbnSdOSNbmMy8lgiSe5Pe0dRCE3hKJYvsq8alUdRUctaLLRzzpzQVsgqlNgCQ5sKv(3zPP66JWBSeCLWWB50qPJGg2bu2Zagtm(fdewkgY5TBQKLqkeuIDNqjbR3jGHp5PS4WWxGtElfN71FITKRENq4WtzX1SSNN1xjdOLtdo1CjYk)7S0uD9r4nET5FfcDuPORENq4WtzXzK1M)vieqW8HrPJGg2bu2Zagtm(fdewkgY5TBQKLqkeuko3R)eBjx9oHWHNYIRe7oHscwVtadFYtzXHHVaN8IHVGG1QHML9uy9vYaA50GtnxISY)olnvxFe(shbnSdOSNbmMy8lgiSumKZB3ujlHuiOuCUx)j2sWktVWHNYIRe7oHsgwz6HHp5PS4WWxGtEB2Se7oHsKbJIHVbnmbuUAm8Jzb3ij2MT]] )

    storeDefault( [[SEL Elemental LR]], 'actionLists', 20170201.1, [[d0dqoaGEeQuBcHSlkABIW(erntvknBKMpQkCtrKoSu3wfltvzNOyVk7gy)QQgfQQgMi9BsDoss15rvgmcgoiDqrvNIK4yG64QuyHuWsfvwmkTCQ6HKK8uIhtPNRkteHkzQurtgrtx4IKuNwYLHUoi2Okf9Ak0MvjBxu8zQ03frmneQY8qO8mQWHqOcJMeJhHk6KQunoss5Aiuv3dvLwjQk6BIs)fvEWZ5e1GMLIKZWeIl8QHqJzyctFWjI6B)jOMIheen9NWT5MKdPy)WX8LcNnfg(ZeEIafTvtlI7oknymFj(MK3gLg8MZXapNtudAwksodteRVGgtioIYASaUtYZw0k4n5I2hK7POTgNChqw2o0(janaNKdPy)WX8LcNaoRzQJjm9bNCtAFWFcII2A8Na)PQSymFZ5e1GMLIKZWeX6lOXewixxMOvrJpo9fxOGCUESdUheaj6lGRjeOeDAK(cV(yAH49iisMVQwIj5qk2pCmFPWjGZAM6yYDazz7q7Na0aCctFWjQBFOCdiTrCsE2IwbVjy7dLBaPnIlgJJ5CIAqZsrYzyIy9f0yYPr6l86JPfI3JGiz(Q6F)85KCif7hoMVu4eWzntDm5oGSSDO9taAaoHPp4e1Tpu(jikARXj5zlAf8MGTpu4EkARXfJH4nNtudAwksodty6dorcT)yerOOFsE2IwbVjVq7pgrek6NChqw2o0(janaNiwFbnMeAxxkA2(OUABW1SfTcEeXFBJkdYHa8u4lzy(GpEyefW9z2UUE89Qmi3l0(JreHIEvMKdPy)WX8LcNaoRzQJfJH4pNtudAwksodteRVGgtMKdPy)WX8LcNaoRzQJj3bKLTdTFcqdWjm9bNOMIheen9NGbA)Ij5zlAf8MGu8GGOPCS0(flgtI5CIAqZsrYzyIy9f0ysBJkdYHa8u4lz(6ysE2IwbVj06gqksUt7EAUqh4zYDazz7q7Na0aCctFWj3w3asr(tiPT7P)j4uh4zsoKI9dhZxkCc4SMPowmMSZ5e1GMLIKZWeX6lOXesDyEr7dY9u0wJME80f4LSTFbxuh8NpNKdPy)WX8LcNaoRzQJj3bKLTdTFcqdWjm9bNCBNP)jyaI)ftYZw0k4nH2zAowi(xSymQ2CornOzPi5mmjPnXzDGCC2ExmEtCmrS(cAm50i9fE9X0cX7rqKmF)sjIfY1LjsXdcIMYDPTqEMqGsKhV84tPzP4pFojpBrRG3KlAFqUNI2ACYDazz7q7Na0aCctFWj3K2h8NGOOTgNOkEwk6S9Uy8g7KCif7hoMVu4eWzntDmru0jjPAY6Qq)BSlgJQpNtudAwksodteRVGgtonsFHxFmTq8EeejZ3VuIyHCDzIu8GGOPCxAlKNjeOeXp)TnQmihcWtHp((ruBJkdYrQdZlAFqUNI2AKyFQWh8b)TnQmihcWtHVK5RdIABuzqosDyEr7dY9u0wJeZHkQmjpBrRG3KlAFqUNI2ACYDazz7q7Ny5zP4eM(GtUjTp4pbrrBn(tGFyvMKdPy)WX8LcNaoRzQJfJboDoNOg0SuKCgMiwFbnMCAK(cV(yAH49iisMVQwIj5zlAf8MGTpu4EkARXj3bKLTdTFcqdWjm9bNOU9HYpbrrBn(tGFyvMKdPy)WX8LcNaoRzQJfJbgEoNOg0SuKCgMiwFbnMWc56Y0JpnObwKl0bEm94PlWJyWPtYHuSF4y(sHtaN1m1XK7aYY2H2pbOb4K8SfTcEtcDGhUt)c0ZBctFWjo1bE(jK0(fON3IXa)nNtudAwksodteRVGgtyHCDzIwfn(40xCHcY56Xo4EqaKOVaUMqGojhsX(HJ5lfobCwZuhtUdilBhA)eGgGtYZw0k4nbBFOCdiTrCctFWjQBFOCdiTr8Na)WQSymWoMZjQbnlfjNHjm9bNCB5QeGc4(tWGMgtYHuSF4y(sHtaN1m1XK7aYY2H2pbOb4eX6lOXewixxMq1jb9C6lUqb5onsFHxFmHaLO2gvgKdb4PWhXCqejYc56YKwUkbOaUCEnPjPojGj5zlAf8MqlxLauaxownnwmgyI3CornOzPi5mmrS(cAmHfY1LjuDsqpN(IluqUtJ0x41htiqjQTrLb5qaEk8rmhe12OYGCK6W8I2hK7POTgj23KCif7hoMVu4eWzntDm5oGSSDO9tS8SuCctFWj3wUkbOaU)emOPXpb(vfplfvzsE2IwbVj0YvjafWLJvtJfJbM4pNtudAwksodteRVGgtABuzqoeGNcFjdtejYc56YKwUkbOaUCEnPjPojGF(CsoKI9dhZxkCc4SMPoMChqw2o0(janaNKNTOvWBIvPlahTCvcqbCNW0hCIQu6c8t42YvjafWDXyGtmNtudAwksodteRVGgtABuzqoeGNcFjdtelKRltA5QeGc4Y51KMqGsuBJkdYrQdtA5QeGc4Y51KeRTrLb5qaEk8njpBrRG3eRsxaoA5QeGc4o5oGSSDO9tS8SuCsoKI9dhZxkCc4SMPoMW0hCIQu6c8t42YvjafW9Na)QINLIQSymWzNZjQbnlfjNHjI1xqJjKilKRltA5QeGc4Y51KMK6KaMKNTOvWBcTCvcqbC5y10yYDazz7q7Na0aCctFWj3wUkbOaU)emOPXpb(HvzsEV7BYKCif7hoMVu4eWzntDmru0jjPAY6Qq)BStuLcAnMuDg8GGySlgdSQnNtudAwksodteRVGgtABuzqoeGNcFjdtuBJkdYrQdtA5QeGc4Y51KeRTrLb5qaEk8njhsX(HJ5lfobCwZuhtUdilBhA)elplfNKNTOvWBYLx)cUNI2ACctFWj3wUkbOaU)emOPXpb(Hv5NGQ4zP4IXaR6Z5e1GMLIKZWeX6lOXKj5qk2pCmFPWjGZAM6yYDazz7q7Na0aCsE2IwbVj0YvjafWLJvtJjm9bNCB5QeGc4(tWGMg)e4)tLfJ5lDoNOg0SuKCgMiwFbnMC0zkGlrE8YJpLMLItYHuSF4y(sHtaN1m1XK7aYY2H2pbOb4eM(GtUjTp4pbrrBn(tG)pvMKNTOvWBYfTpi3trBnUymFWZ5e1GMLIKZWeX6lOXKJotbCjQTrLb5i1H5fTpi3trBnsS2gvgKdb4PW3KCif7hoMVu4eWzntDm5oGSSDO9tS8SuCsE2IwbVjx0(GCpfT14eM(GtUjTp4pbrrBn(tG)pv(jOkEwkUymFFZ5e1GMLIKZWeX6lOXKJotbCNKdPy)WX8LcNaoRzQJj3bKLTdTFcqdWj5zlAf8MGTpu4EkARXjm9bNOU9HYpbrrBn(tG)pvwSyIy9f0yYIn]] )

    storeDefault( [[SEL Elemental Default]], 'actionLists', 20170201.1, [[d0ZuhaGEcuAtQOIDHOTrPAFQO0mPeMTuZNI4MuIwgcDBv1Hf2je7vz3K2Vk1pjkQHrvnocunkcKAOeiAWqQHJGdsuDkcuCmkCocewif1sjKftKLlYIiGNI6Xu55QYejk0uPKMSOMUKlsvwhrPUm46qYgjkYPrAZukBxfv1FjOptOMgbs(ofPNPICivumAIcMNkQYjvbVMOKUgrjoVkzLQOs)gQVPc9mM1XEAi1qEMhJeFym7zXnAVg(GwrFJwgbBbQUgZeahnAQGnkkwhcr7ehlcAiEWqi6BC03WGiPXy2LOeQXJL7kkwFZ6qmM1XEAi1qEMhJeFySGexuSoMDjkHACHflUbsc4II135iOptHflUbshg3zSP6ZetCyCNXMQK2Ojqi0Wh0kAYe8dQ(olrb3xWmwe0q8GHq03WUXrs)tJpOzQlkCASIvySCjAtRRXeWffRJTeNrIpmwacjCJvXqwibSPqsGvdH4So2tdPgYZ8y2LOeQXsOSzJSWf8f(JxbPlYe8dQ(opIJLlrBADnUWf8f(JxbPRXh0m1ffonwXkmgj(WyR4c(3OTmEfKUglcAiEWqi6By34iP)Pvd50So2tdPgYZ8y2LOeQXfwS4giDyCNXMQVXIGgIhmeI(g2nos6FA8bntDrHtJvScJrIpmwMOj4gTxdFqROhlxI206ASnAcecn8bTIE1qeuZ6ypnKAipZJzxIsOgxyXIBG0HXDgBQ(glcAiEWqi6By34iP)PXh0m1ffonwXkmgj(WyUWP)nAVg(GwrpwUeTP114xHtFHqdFqROxnezzwh7PHud5zEm7suc14clwCdKomUZyt13y5s0MwxJHg(Gwrl8hVcsxJpOzQlkCASIvySiOH4bdHOVHDJJK(NgJeFySxdFqROVrBz8kiDTAi2N1XEAi1qEMhZUeLqn(mv0GwKXZbAouhqcAi1q2etKqzZgz8CGMd1bKOiyIjomUZytvY45anhQditWpO67SYI)yrqdXdgcrFd7ghj9pn(GMPUOWPXkwHXiXhgBUX48nAzcv6ASCjAtRRXsngNfAdv6A1qooRJ90qQH8mpMDjkHA8zQObTiJNd0COoGe0qQHSjMiHYMnY45anhQdirrySiOH4bdHOVHDJJK(NgFqZuxu40yfRWyK4dJndPhKKvQkESCjAtRRXsq6bjzLQIxnebFwh7PHud5zEm7suc14Wv0Zheck8PW7SehJeFySiuQSVrlxM9glxI206ACcLkmCffRcB6RgFqZuxu40yfRWyrqdXdgcrFd7ghj9pn2sCgj(WybyplUr71Wh0k6B0YLzpbwnebXSo2tdPgYZ8yK4dJfHsL9nA5phO5qDWy2LOeQXv0GwKXZbAouhqcAi1qESiOH4bdHOVHDJJK(NgFqZuxu40yfRWy5s0MwxJtOuHHROyvytF1ylXzK4dJfG9S4gTxdFqROVrl)5anhQdey1qm8N1XEAi1qEMhJeFySiuQSVrFWb2qLUgZUeLqnUIg0IK6aBOsxKGgsnKVp3XIGgIhmeI(g2nos6FA8bntDrHtJvScJLlrBADnoHsfgUIIvHn9vJTeNrIpmwa2ZIB0En8bTI(g9bhydv6sGvdXWywh7PHud5zEms8HXIqPY(gTfuXYqPuv8nAr48y2LOeQXv0GwKnvSmukvflmHZKGgsnKhlcAiEWqi6By34iP)PXh0m1ffonwXkmwUeTP114ekvy4kkwf20xn2sCgj(WybyplUr71Wh0k6B0wisGvRglJGTavxZ8Qn]] )

    storeDefault( [[SEL Elemental AOE]], 'actionLists', 20170201.1, [[dSt9iaGEQe0MKQQDrvTnjP9rLqZuQkZgv3ek(MK4Wu2PQSxXUvA)urJcLadtQmoQe4XsCBsnysQHlPCqsYPOsKJrKZHsqleLAPkklgQwUQ6HsQEkYYikphfteLKAQuLMSctxLlsuDEQIldUovyJOK40q2mvQTlfVgk9DQK8zP08qj1ZKQ8xfz0KyAOe6KkQoekrUgvI6EOe1VjCCQK6NOKKJu8gs(A4Cye2Hy1GBZb)c7qu5JQDHcnd4GXa5jRtQsNKKmFPqunOGmoYfAhsS5jRQSqQkhsSmXBEsXBi5RHZHryh6zAieDIVgla1GFiv4io68eI5eFnwaQb)qZaoymqEY6KQkvXVRxO57avSt8dTIfcvxbkyXiAanSxWdHrmEMgcLlpzXBi5RHZHryh6zAiKkMcSdBlqiQ8r1UqNOTLd(fHGpeUAzcvxbkyXiAanSxWdnd4GXa5jRtQQuf)UEHMVduXoXp0kwiKkCehDEczmfyh2wGqyeJNPHq5YRx8gs(A4Cye2HEMgc1hY1oqdNQXyTAZPAVId0HuHJ4OZtioY1oqJjT1QTPtCGo0mGdgdKNSoPQsv876fA(oqf7e)qRyHq1vGcwmIgqd7f8qyeJNPHq5YJfJ3qYxdNdJWoev(OAxiTbCM7l0(fh)pSNlYYY66NLoJd75ZrTk3I22PVy4dRHZHr)FW9hyumCoesfoIJopHCZnnmXOikydvxbkyXiAanSxWd9mneIv4MgCQMuefSHMbCWyG8K1jvvQIFxVqKIWvyedKBe8zcEO57avSt8dTIfcHrmEMgcLlpxoEdjFnComc7qu5JQDHSYHAGjybncyynl2VvoudmneNVBUPHjgfrblRTYHAGjybncycPchXrNNqU5MgMyuefSHMVduXoXpuXtHdHEMgcXkCtdovtkIcwNQR7PWHqZaoymqEY6KQkvXVRxU8QgVHKVgohgHDONPHqYT)P4AhgwiKkCehDEcb2)uCTddleAgWbJbYtwNuvPk(D9cnFhOIDIFOvSqO6kqblgrdOH9cEimIXZ0qOC5vjEdjFnComc7qptdH6ZAmNQz74ZCHOYhv7cneNVBUPHjgfrbR)h0gAzCXIXCthsd9J7WTBFU1ytmo(TGVJA9ZsNXH985OwLBrB70xm8H1W5WOFRCOgycwqJagwZIHQRafSyenGg2l4HMbCWyG8K1jvvQIFxVqZ3bQyN4hAflesfoIJopH4wJnH74ZCHWigptdHYLNliEdjFnComc7qptdHKZbnSNXDQMn3yUqu5JQDHyPZ4WE(CuRYTOTD6lg(WA4Cy0VvoudmblOradRD5q1vGcwmIgqd7f8qZaoymqEY6KQkvXVRxO57avSt8dTIfcPchXrNNqah0WEgFcNBmximIXZ0qOC5XcJ3qYxdNdJWo0Z0qO(SgZPA2GPdPchXrNNqCRXMWbthAgWbJbYtwNuvPk(D9cnFhOIDIFOvSqO6kqblgrdOH9cEimIXZ0qOC5j1fVHKVgohgHDiQ8r1Uqda3HB3(CuRYTOTD6lg(dHR2qptdHQRyO1P6(qTk3I22q1vGcwmIgqd7f8qZaoymqEY6KQkvXVRxO57avSt8dTIfcPchXrNNqffdTtCuRYTOTnegX4zAiuU8KKI3qYxdNdJWoev(OAxiRCOgyAioFoQv5w02o9fdwBLd1atWcAeWeAgWbJbYtwNuvPk(D9cnFhOIDIFOvSqONPHq1vm06uDFOwLBrBRt119u4qiv4io68eQOyODIJAvUfTT5Ytsw8gs(A4Cye2HOYhv7cH7WTBFU1ytmo(TGVJAHuHJ4OZtiU1yt4o(mxO57avSt8dTIfcHr0G22qsHEMgc1N1yovZ2XN5CQMfi5sHu9BzcPfnOTLLLcnd4GXa5jRtQQuf)UEHifHRWigi3i4Ze2HQRafSyenGg2lSdHrmEMgcLlpPEXBi5RHZHryhIkFuTl0hC)bgfdNdHuHJ4OZti3CtdtmkIc2qZ3bQyN4hAflecJObTTHKc9mneIv4MgCQMuefSovZcKCPqQ(TmH0Ig02YYsHMbCWyG8K1jvvQIFxVq1vGcwmIgqd7f2HWigptdHYLl0Z0qisEFovlNdAypJ7uTkwL8Cja]] )

    storeDefault( [[SEL Elemental Precombat]], 'actionLists', 20170201.1, [[d8cmcaGEuvAxOuBJQ0mrvy2uCtPQBtPDkL9s2nI9dPAyI0Vv1qrv1GHcdxfoikCmOAHiPLsvzXi1Yf1IOkEkyzI45OYervQPcLMSknDHlIexw56OQyZOkA7sL(mk6XqCyjFtQy0qrNxfDsiXFHKonvUhQsEiKYZOQ61OKfUWkGcPOn7kQcaKS7ieiOv2jaOWd0XGIz2rIYGog8NhYBPRqGVzwXn1ssX7KIJNWgxaCmexzC8Tc3tulXBIagiH7jCcRA4cRakKI2SROkaqYUJqq8mzAg7JpCpHtadANXfNco(W9ebOqUoKk(SaYtMGwzNa()W9ebmYm5eqk74LN7QR5evM5czEe4BMvCtTKuCV4DyN6xaAyoew9F3zhjeTG()2k7e45U6AorLzUqMhfQLiScOqkAZUIQGwzNaSFml6y0xCXYNcyq7mU4uq8XSOAlUy5tb(Mzf3uljf3lEh2P(fGc56qQ4ZcipzcqdZHWQ)7o7iHOf0)3wzNafQ5xyfqHu0MDfvbTYobq8zlRTJLfWG2zCXPaU4ZwwBhllW3mR4MAjP4EX7Wo1VauixhsfFwa5jtaAyoew9F3zhjeTG()2k7eOqHaEpEw8XeIQcja]] )

    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170112.1, [[dauSDaqiPewerfAtqsJcsCkLQEfukyxqmmQ0XOILrKEgfzAOuCnOuABkfFtPY4iQKZrurRJOcyEOu6EqPAFevDqOWcLs9qLstKOc6IqrBKOsnsOuiNeQQzkLOBIs2jkgkrfOLcL8ustfQYxHsr7v1FHudgLQdlSyfESsMmLUmyZsLplvnAP40i9Ak0SjCBQA3s(nIHtuwoQEUIMUORdv2of8DPKopf16HsHA(er7Ni8DoExXSIHaSV9vMWdxvQFReSJz1e1c8qLYbKGDl0f4e5vvgSOHGInoskPoJ0nMUIfiGycNrQRZoxhhhetx1fNklVEfJvsj184DgNJ3vmRyia7BFLj8WvSjTSsWU2ab)QU4uz51K03laeALaNJtwoVIfiGycNrQRZgNDiUMUIXGkOP5RTsll6zde8R4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNr6X7kMvmeG9JRmHhUInc4e60FvxCQS8As67faYIqewsR1evuYG3djsdeISbr2kzRuSvsjtQhK3fbBDD3FflqaXeoJuxNno7qCnDfJbvqtZxhccXkWnZR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNX0X7kMvmeG9TVYeE4QCd8qib7QmkNMx1fNklVMK(EbGSieHL0AnrfLwe8K2fRejeYAc0TseDi8OmkVRKsIIpaXm5epYchNdvkp2L6I6IqewsRfYIhZg0cAFtw0QhHd(Gwt2I9(LD)(RybciMWzK66SXzhIRPRymOcAA(AhWdb6PmkNMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppdBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Q)QU4uz51GN0UyLiHqwtGUvIOdHhLr5DrvghmGUFzrCq6aEiqpLr508kwGaIjCgPUoBC2H4A6kgdQGMMVU4XSbTG23KfT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgS94DfZkgcW(2xzcpCTnWNa3iT6VQlovwEnj99cazriclP1AIkkdCDDiXCbLnQfGGtMKs2ImeqLiXCbLnQfGavmeGvsjfGbqWwhx39xXceqmHZi11zJZoextxXyqf0081bWNa3iT6VIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEMnhVRywXqa23(kt4HRTfeIvc2LBCCZx1fNklVMK(EbGSieHL0AnVIfiGycNrQRZgNDiUMUIXGkOP5RdbHyr3HJB(k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95z2D8UIzfdbyF7R6ItLLxtsFVaqKrskPMOIshWdb6PmkNMiCWh0Akp2kPKzW7HejPEaDsqBPaBX(g39xXyqf008vzKKsQR4xw6ksc)Ark4kt4HRYbjjLuxXG3pVwHhWUCugNiivpyrlJ0kWLJxXceqmHZi11zJZoextx32alJSigapu5hxzrSmHhUkhLXjcs1dw0YiTcC54ZZixhVRywXqa23(kt4HRTj4ewG3rN5vDXPYYRdCDDidcoHf4D0zIWbFqRjB7xwjLefFaIzYjEKfoohQKTyhBDrnwj1aGgkWtHP8y30(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJCE8UIzfdbyF7RmHhU2MGtybEhDMsWoko7VQlovwEDGRRdzqWjSaVJoteo4dAnzB)YkPKOSAcEpmr3XJvsjviK3bzh2IQpaXm5epYchNdvYwSpHmPv)ezqWjSaVJot0(aeZKt8OgRKAaqdf4PWKTyx6(RybciMWzK66SXzhIRPRymOcAA(6GGtybEhDMxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJJ7X7kMvmeG9TVYeE4kwKLXbnb(vDXPYYRziGkrerzNcQfqGkgcWI6axxhIik7uqTach8bTMSTFzVIfiGycNrQRZgNDiUMUIXGkOP5RCYY4GMa)k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zCCoExXSIHaSV9vMWdxLBCCZsWoPtc2XGYVQlovwETfjDzKw9O6dqmtoXJSWX5qLYlv6vSabet4msDD24SdX10vmgubnnFTdh3mAsh6GYVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghPhVRywXqa23(kt4HRYnNmZbpk7vDXPYYRziGkrAcQyMeUhbQyialQdCDDiDCYmh8OSiCWh0AYwomW11HUvAzjTEflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghthVRywXqa23(kt4HRYTi8qsQECWvDXPYYRdCDDiDIWdjP6XbiCWh0AYwomW11HUvAzjTkPKOSieHL0AHyjep6wPLDIWbFqRjB3G6axxhsNi8qsQECach8bTMSLn7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJdBoExXSIHaSV9vMWdxLdjeVeSJnPLDEflqaXeoJuxNno7qCnDfJbvqtZxTeIhDR0YoVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEghS94DfZkgcW(2xzcpCDlpMnsWElP9nzrREjyhfN9x1fNklVMHaQezXJzdT6rptc3JavmeGf1yLudaAOapfMYJDtOIslYqavI0euXmjCpcuXqawjLCGRRdPJtM5GhLfHd(Gwt57x29xXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4S54DfZkgcW(2xzcpCfZGNnqjb7QmQr4kwGaIjCgPUoBC2H4A6kgdQGMMVcbpBGc9ug1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8mo7oExXSIHaSV9vMWdxBjTVjlA1lb7TjI8QU4uz5vuYqavIqma8vtW7beOIHaSO6dqmtoXJSWX5qLYJD24IAlYqavI0HJBgnPdDq5iqfdby3lPKOKHaQeHya4RMG3diqfdbyrndbujshoUz0Ko0bLJavmeGfvFaIzYjEKfoohQuE24In0rc0YcRLw97VIfiGycNrQRZgNDiUMUIXGkOP5RcAFtw0Qh9GiYR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNXrUoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rr6(R6ItLLxh466qw8y2Gwq7BYIw9iCWh0AY2(Lf1yLudaAOapfMYJDPxXceqmHZi11zJZoextxXyqf0081fpMnOf0(MSOv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZ4iNhVRywXqa23(kt4HRytAzNKQ)kwGaIjCgPUoBC2H4A6kgdQGMMV2kTSts1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDpExXSIHaSV9vMWdxXyUGYg1cUQlovwEnj99cazriclP1AIkkdCDDiZKW9doT6bocoz7VIfiGycNrQRZgNDiUMUIXGkOP5RXCbLnQfCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msDoExXSIHaSV9vMWdxXM0Yoto1iCvxCQS86axxhYmjC)GtREGJGtgQOGsgcOsKoCCZOjDOdkhbQyialQ(aeZKt8ilCCouP8yxQl2qhjqllSwA1VxsjrPfziGkr6WXnJM0HoOCeOIHaS73FflqaXeoJuxNno7qCnDfJbvqtZxBLw2zYPgHR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrQ0J3vmRyia7BFLj8WvnjC)m5uJWvDXPYYRdCDDiZKW9doT6bocozOIckziGkr6WXnJM0HoOCeOIHaSO6dqmtoXJSWX5qLYJDPUydDKaTSWAPv)EjLeLwKHaQePdh3mAsh6GYrGkgcWUF)vSabet4msDD24SdX10vmgubnnFDMeUFMCQr4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zKA64DfZkgcW(2xzcpCTLHHqc2BzmBUQlovwEndbujsdjr3eLfbQyialQdCDDinKeDtuweCYUIfiGycNrQRZgNDiUMUIXGkOP5RIWqGweZMR4xw6ksc)Ark462gyzKfXa4Hk)4klILj8W1NNrkBoExXSIHaSV9vMWdx3YJzJeS3sAFtw0Qxc2rX0(R6ItLLxJvsnaOHc8uykp2zZvSabet4msDD24SdX10vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8msX2J3vmRyia7BFLj8WvSjTSZKtncsWoko7VIfiGycNrQRZgNDiUMUIXGkOP5RTsl7m5uJWv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZiDZX7kMvmeG9TVYeE4QMeUFMCQrqc2rXz)vDXPYYRziGkriga(Qj49acuXqawuxeIWsATqe0(MSOvp6brKiCWh0AY2(LfvFaIzYjEKfoohQuE5Y9kwGaIjCgPUoBC2H4A6kgdQGMMVotc3pto1iCf)Ysxrs4xlsbx32alJSigapu5hxzrSmHhU(8ms3D8UIzfdbyF7RmHhUQjH7NjNAeKGDuKU)QU4uz51meqLiD44Mrt6qhuocuXqawu9biMjN4rw44COs5zJl2qhjqllSwA1JkklcryjTwicAFtw0Qh9Giseo4dAnLVFzLuYwKHaQeHya4RMG3diqfdby3FflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY1X7kMvmeG9TVYeE4QMeUFMCQrqc2rX0(R6ItLLxBrgcOseIbGVAcEpGavmeGf1wKHaQePdh3mAsh6GYrGkgcWEflqaXeoJuxNno7qCnDfJbvqtZxNjH7NjNAeUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgPY5X7kMvmeG9TVQlovwEffuIvsnaOHc8uykVJKsMHaQezXJzdT6rptc3JavmeGvsjZqavImi4ewG3rNjcuXqa29O2IjKOhKc3ejPa3rorZgzl5D3lPKDapeONYOCAIWbFqRP8y7vmgubnnFDXJzdAbTVjlA1Ff)Ysxrs4xlsbxzcpCDlpMnsWElP9nzrREjyhf2S)kwGaIjCgPUoBC2H4A6Q2qALfXs7OaF(2x32alJSigapu5hxzrSmHhU(8mMCpExXSIHaSV9vMWdxLBozMdEuwjyhfN9x1fNklVMHaQePjOIzs4EeOIHaSOoW11H0XjZCWJYIWbFqRjBzdICDflqaXeoJuxNno7qCnDfJbvqtZx74Kzo4rzVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtohVRywXqa23(kt4HRTmmesWElJzJeSJIZ(R6ItLLxZqavI0HJBgnPdDq5iqfdbyrndbujcXaWxnbVhqGkgcWIkktirpifUjssbUJCIMnYwY7IQpaXm5epYchNdvkp2Ll39xXceqmHZi11zJZoextxXyqf008vryiqlIzZv8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZys6X7kMvmeG9TVYeE4AlddHeS3Yy2ib7OiD)vDXPYYRziGkr6WXnJM0HoOCeOIHaSO2ImeqLiedaF1e8EabQyialQOmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yhBnT)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtMoExXSIHaSV9vMWdxBzyiKG9wgZgjyhft7VQlovwEfLwmHe9Gu4Mijf4oYjA2iBjVlQ(aeZKt8ilCCouP8yFczsR(jIimeOfXSbTpaXm5e)EjLeLwKHaQePdh3mAsh6GYrGkgcWI6es0dsHBIKuG7iNOzJSL8UO6dqmtoXJSWX5qLYJD24U)kwGaIjCgPUoBC2H4A6kgdQGMMVkcdbArmBUIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgtS54DfZkgcW(2xzcpCvUfHhss1JdKGDuC2FvxCQS86axxhsNi8qsQECach8bTMSLniY1vSabet4msDD24SdX10vmgubnnFTteEijvpo4k(LLUIKWVwKcUUTbwgzrmaEOYpUYIyzcpC95zmHThVRywXqa23(kt4HRkUYcCA1FflqaXeoJuxNno7qCnDfJbvqtZxN4klWPv)v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZZyAZX7kMvmeG9TVYeE4kwKLXbnbUeSJIZ(RybciMWzK66SXzhIRPRymOcAA(kNSmoOjWVIFzPRij8RfPGRBBGLrwedGhQ8JRSiwMWdxFEgt7oExXSIHaSV9vMWdxLBr4HKu94ajyhfP7VIfiGycNrQRZgNDiUMUIXGkOP5RDIWdjP6XbxXVS0vKe(1IuW1TnWYilIbWdv(Xvwelt4HRppJj564DfZkgcW(2xzcpCTnbNWc8o6mLGDuKU)kwGaIjCgPUoBC2H4A6kgdQGMMVoi4ewG3rN5v8llDfjHFTifCDBdSmYIya8qLFCLfXYeE46ZNxLdHUaNiF7N)a]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170112.1, [[dedXbaGEukTlIyBIsZuLKztYnrvUTk2PI2l1Uf2VizyIQFlzOOegSiA4qCqc6yQYcjWsvjwmrTCv1dfHNcEmKwhkjteLOPsitwHPl1fjupJiDDuk2SkP2okvxg5Wq9zu8DurltL68OsnAs55KQtIk8nrXPv6EOKArOQ(Ri1RrLSFwKbXbwwrdlWWeFidWEsKkP4qdhO0HIMvPsI8j06iJBdacHUy1YwCVv45DwPgUqkcRtEEN)YK)EpjsnaO)fPnyqiAVvOBrE(SidIdSSIgwGba9ViTHUyyuKeKQ3k0niuEvBZTbKQ3kmWrmwuCxFdrfKHj(qgyr1Bfge(z0ne4dXA(i)svbdnsJuCsF(gUqkcRtEEN)Y(YijxQHeAekx8k2PdfTLnWRgt8HmWh5xQkyOrAKIt6Z3TN3wKbXbwwrdlWWeFidxTmADSbtQKG2sQHHlKIW6KN35VSVmsYLAqO8Q2MBdQLrRJnysRRTKAyGJySO4U(gIkidj0iuU4vSthkAlBGxnM4dzWTBdSKUgZgvBbUTb]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170112.1, [[dWdefaGEbyxQIyBeWmvfQdRYSf1RvfIBcrEMQu3MKZlq7uK9QSBK2pv)eIYWi04ufOtJyOezWugUqoOQYrfqhdKZPkileiTuc0IfQLlLhcWtrTmsX6acteszQaAYavthQlkORQkKUSKRdQncP6BquTzvjBhs(OQi9zimnsP(oqKrQkOEmPA0QQgpPKtQkQBruxdOCpvb8CcATar9BP6bnGJrgQQLVGlECGWfCbUBO3Py3ysa1sqAglHsYnz3aEnefEXJLAe11c6gGlct6u3(GB3yg3BQ4gHIOAJBvEmGWeWqbh)Ocl34OkNrpFc)x8yjuHUj7gWRHOWlESeQq3KDdT61bNXd0XsOcDt2naDv8Hx8yKoTikyLBajQAP3IJb5ExTeeyJz9gjcpESekj3KDdqxfF4fpwcLKBYUHw96GZ4b64GdD5hu8H0OTOaqqi)TOgnixCVK1gSXFil0nz3q60IOGvljowWkxNWAjnIqixecc6jVhhiCbxU9LjiOQIIhRp(dg3Dt2nKoTiky1sIJLqj5MSBaVgIc72xo6)wcAmtOiYLBYUHeHsuWQLehlHsYnz3qREDWzSBF5O)BjOXsOcDt2n0QxhCg72xo6)wcACGWfCjCaxcAahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4wuR07Q4dpoDQAmtuaClK(Fu9svumiClQv6Dv8HhlyLRtyTKgribGefFpM1BKi8ymrvpG4WlPzahhsV4Cb(aD8NoM0PU9yIq8yMOa4wi9)O6LQOyq4g41RdoJhNovnMjkaUfs)pQEPkkgeUbE96GZ4Xcw56ewlPresairX3dp8yjusUj7gGUk(WU9LJ(VLGgZrvoJE(e(7gGEU3gWX3sqJBlbngXsqJJxcA4Xa6rbDdyFCi9)O6LQOy3ycfrUKbEnefESeQq3KDdqxfFy3(Yr)3sqJdeUGl3qJ0kDmPthl4Zp9HbogT61bNXd0XbcxWf4U9SEN6gtcOwsBXXsOcDt2nGxdrHD7lh9FlbnoKEX5c8b64pyC3nz3qIqjky1sIJLAe11c6gGlct60XcBhM0h)HSq3KDdjcLOGvl9EmtOiYLBYUH0PfrbRwcAmWlxuSBpT1HJwsC8Z6DQq34)oirxs7XcEueLBa(l9hHqrm(Ijzco4yPgrDTGU9SEN6gtcOwsBXXO3P4XFnYLDlDTwhKgNovnoK(Fu9svuSBsnI6Abhl1iQRf0n07uSBmjGAjinJ5OsNCzsahM0PlPrG3J5OtNqrSeyJ)0XKo1naxeM0PchOJ1AjzbEcK4BWGatanGvYIIGn8g]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170112.1, [[dWt8eaGEIu7svL2MQGzkLKdRYSf1RfO4MGIRbkDBsoVQQ2Pi7vz3iTFk)uvOHjOFlvptadLqdMQHlKdkuhvGCmeDoPuSqGyPiKflflhWdvvEkQLreRtkvtKGmvGAYaPPd5IKYvfOQll56GSreQXjLqBwv02jWhLsQpdQMgb13Ls0ifOYJjQrRknEIKtQQIBrQonu3tGsphbRvkbFtkLEKd84GGkOcuZjUtrMZyPRLiLmweaRoG)MtCNImNXsxlrkzSiawDa)n)7Iq4o18yiGBmJ6aQgamfEbmgOYJ)0sG1iACWtOmNJQCM48r4DnJ5OtgtHVeSJffOzUU5cvppOmAGmwuGM56M)1vnhAnJH5KcRGuMdgRQLceoUf6D1sKWowuGO56Mlu98GYiZJZrV3sKJffiAUU5FDvZHwZyrbIMRBUq1ZdkJgiJ)pI1Fa2W2qg2MaTnqGqHBXaH7PUWWowQLchtuLRJqTKKqY2gsss(BGXbbvqL5XzmCQQOOXYJffOzUU5FDvZHmpoh9ElroweaRoG)M)JCNAoJLUws4WXIcenx38VUQ5qMhNJEVLihh)OM56MdZjfwbPwkCCSmc3PM)DriCNsyGmwuGM56Md(aGxO1mwuGO56Md(aGxO1mMJQCM48r418VEUdmWJVLih3Se5y4lrogyjYHg)1J(Bo4(yn67rLlvrrMh)O2yrbIMRBo4daEHmpoh9ElrooiOcQmximqjJWD6yI(P1bh4XPtvJ1OVhvUuffzE8JAJdcQGkqn)h5o1CglDTKWHJjUtrJJbWx280ba0B5yn61KlqhiJ5OsgFzS0hc3Plj5HaJj6OWlZ)El5GbtHp(AWzm6)44h1mx3CyWuScsTuGX)i3PemNF7TKUKWJbF5IImV1aDOOLchZyk8CzUU5WCsHvqQLchlcGvhWFZ)UieUthta4q4(4yiu3CDZH5KcRGulfowuGM56Md(aGxiZJZrV3sKJJHqDZ1nhgmfRGulfymJPWZL56MddMIvqQLcmoiOcQimWlroWJ1OxtUaDGmowgH7uZBfMaAmJvFMRrFpQCPkkQDZJak5UQ5qJtNQgZy1N5A03JkxQIIA38iGsURAo0yIQCDeQLKescB4d)krc5ywgahHgJWQkydhAjjd8yn61KlqhiJJLr4o18wHjGgZy1N5A03JkxQIIA3CqRNhugnoDQAmJvFMRrFpQCPkkQDZbTEEqz0yIQCDeQLKescB4d)krc5qdnMLbWrOXeWu45ASOanZ1nxO65bLrMhNJEVLihlu98GYObYqBa]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170201.1, [[dSt4eaGEIk7IOO2MkOzcLA2O6WkDtvPETqL62K6zqr7uWEL2Tc7NQFQc1WiYVvPZlugkedMYWfYbvuhLOQJbPZjuHfQkzPqjlwrwUQ6HOupfzzOKNdvnrvutfitMemDqxefxvOsUSORdyJqHttyZQiBhO(OkqFgQmnIsFxOQgPqvmoIImAs04jHoPkKBrsxtfW9eQOhRkwRqv6BefUOfuPJbNF(gRtLKhibsfCdJ7a6gjKlBaLvjeWiUP6gO9JlHDQeYxO3Fm3yVrqXD42mWFlv6N8sSzcGyWQuCHpDJIsohd(IxzNkHaMXnv3aTFCjStLqaZ4MQBNZtlah2xLqaZ4MQBSV6Pf2PsVxffAaTBGe6SbmLkfV3RUbmLkrpFreSujeWiUP6g7REAHDQecye3uD7CEAb4W(QuSIHQmjfhSKv6quuzGPelwYqQNuL9aLuSbPsyL8CXNnWscvgsOOSKz0sYdKaPBZCbUHohWspLMbGx3uD79QOqdOBqQecye3uDd0(XLq3M5rk3gqlrIboE6MQBVfdHgq3GuP5JzCt1T3RIcnGUbPsiGzCt1TZ5PfGdDBMhPCBaTecye3uD7CEAb4q3M5rk3gqlHagXnv3yF1tl0TzEKYTb0suuY5yWx8kDJ9LF)fuPTb0stnGwcxdOL(nGwyj23OyUb6wIHN6CaxUBZhZucbmJBQUX(QNwOBZ8iLBdOLKhibs3ol(5duChLW6OdgpGkndaVUP62BXqOb0nivsEGeivWTJEUd3iHCzdYkvcbmJBQUbA)4sOBZ8iLBdOLyg7epvOVkH8f69hZn2BeuChLG7hxcXxIedC80nv3EVkk0a6gqlnFmJBQU9wmeAaDdywc0YZb0Td(Varniv6ON7aVBKYB8hniBjS2bU0n2kZN4wmWvANeCbmwjKVqV)yUD0ZD4gjKlBqwPsHvNLy4PohWL7gYxO3FSsyChWsZFXYDlS))n(LoNNwaoSVkH8f69hZnmUdOBKqUSbuwLOO8rSCHCluChnW6qwLOO9rmW1Wbkn)af3HBS3iO4oW3xLKhibs8fudOfujMXoXtf6RsZpqXD4g2c8Wsed2UXWtDoGl3nKF(C1tlSuy1zjIbB3y4PohWL7gYpFU6PfwcRKNl(SbwsOhIkjHzj65lIGLGcDgNsf2aRcQeZyN4Pc9vP5hO4oCdBbEyjIbB3y4PohWL72580cWHLcRolrmy7gdp15aUC3oNNwaoSewjpx8zdSKqpevscZs0ZxeblvyHf2ca]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170201.1, [[dSZ7eaGEsKDPKuVwjfZevXSH6WQCtvf3MuFtjrpJiTtH2R0Ufz)u9tsOHruJtjbNxvyOOYGPmCbDqr5OKOogkDoLKSqqyPGOflQwoGhIQ6PiltGEokAIQsMQQQjlathYfb1vrvkxwX1bAJQkDAcBwv02bPpQkv(mkmnb03vsPrQKqBtjvJMigpj4KQs5wK01qvY9uLQESsSwuLQFRux2(xsrOda(E08skdoGtaU9DNqUrcLMgzdwIdkNBQU9FamguZlXbi0hWd34FHiXo5wgiWv6l(0JBKK9YAkbm4s8HJ)WqwI3yoUrHdg)fFmL08sCqHDt1T)dGXGAEjoOWUP62R55bIrfIsCqHDt1n(BD(HAEPpNccnO2TFHEAuQCjEFV1nkvUehuo3uD7188aXi3YWHsUgzlXbLZnv34V15hQ5L4GY5MQBVMNhigvik9OFvxNxYRIvEvsxPuPYbUcsL7t1a5vPmfHDt1TpNccnOUr5sqo45yonguMDLYSSbxnBjLbhWXTmSGrspjuPLsCqHDt1n(BD(HCldhk5AKTehGqFapC7TLDYnsO00yGYL4GY5MQB8368d5wgouY1iBjLbhWHz)BKT)LGtxoEcOqukBbj2j34rWevIG5Xny8ONe6WUXbmlBD(Hkfp9uIG5Xny8ONe6WUXbmlBD(Hkb5GNJ50yqz21zLLLwIwaeHOsiHEEVCrngS)LGtxoEcOqukBbj2j34rWevIG5Xny8ONe6WU9AEEGyuP4PNsempUbJh9Kqh2TxZZdeJkb5GNJ50yqz21zLLLUA2s0cGievQOIkLTGe7KB8VqKyNywikrH3IiXOrEvIcNfXHfkDiXo1yW1dwIchm(l(ykXn(B8gO)LUgzlb0iBjgnYwkVr2IkXFh(WT)Djy8ONe6WULPiCjoaH(aE423Dc5gjuAAKnyjLbhWXTxcGzbj2Psq(27wX)sXtpLGXJEsOd7wMIWLugCaNaC7TLDYnsO00yGYL(UtOszaId7w8aa2RTeC6YXtafIsCq5Ct1T)dGXGCldhk5AKTeKxIX4gFjZYAejgLUCbwGEuktry3uD7Jij0G6gLw6TLDIPBKK9AtngyP)dpjKBVdydg2OCjsKyGh3uD7ZPGqdQBuUehGqFapCJ)fIe7ujGdj2LYarB3uD7Jij0G6gLwIdkSBQU9FamgKBz4qjxJSLEnppqmQqukdeTDt1TpNccnOUr5sKiXapUP62hrsOb1nkTeTaicrLyksmWtjoOWUP62R55bIrULHdLCnYwsHgLlQfa]] )


end
