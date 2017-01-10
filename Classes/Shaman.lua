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


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( 'attack' )
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

        ns.addSetting( 'safety_window', 0, {
            name = "Buff Safety Window",
            type = "range",
            desc = "Set a safety period for refreshing buffs when they are about to fall off.  The default action lists will recommend refreshing buffs if they fall off wihin 1 global cooldown. " ..
                "This setting allows you to extend this safety window by up to 0.5 seconds.  It may be beneficial to set this at or near your latency value, to prevent tiny fractions of time where " ..
                "your buffs would fall off.  This value is checked as |cFFFFD100rebuff_window|r in the default APLs.",
            width = "full",
            min = 0,
            max = 1.5,
            step = 0.01
        } )

        ns.addMetaFunction( 'state', 'rebuff_window', function()
            return gcd + ( settings.safety_window or 0 )
        end )

        ns.addSetting( 'foa_padding', 6, {
            name = "Fury of Air: Maelstrom Padding",
            type = "range",
            desc = "Set a small amount of buffer Maelstrom to conserve when using your Maelstrom spenders, when using Fury of Air.  Keeping this at 6 or greater will help prevent your Maelstrom from hitting zero " ..
                "and causing Fury of Air to drop off.",
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
                "The addon default is 0 (but obeys the cost of Crash Lightning).  Wordup's Enhancement Shaman guide on Wowhead recommends Crash Lightning in Single Target if you have > 80 Maelstrom.\n\n" ..
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.crash_lightning_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } )

        ns.addSetting( 'lava_lash_maelstrom', 90, {
            name = "Maelstrom: Lava Lash",
            type = "range",
            desc = "Set a |cFFFF0000minimum|r amount of Maelstrom required to cast Lava Lash in the default action lists.  This is ignored if Lava Lash would currently be free.\n\n" ..
                "The addon default, Wordup's Wowhead guide, and SimulationCraft all recommend using Lava Lash at/above 90 Maelstrom by default.\n\n" .. 
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.lava_lash_maelstrom|r syntax.",
            min = 0,
            max = 150,
            step = 1,
            width = 'full'
        } )

        ns.addSetting( 'sundering_maelstrom', 0, {
            name = "Maelstrom: Sundering",
            type = "range",
            desc = "Set a |cFFFF0000minimum|r amount of Maelstrom required to recommend Sundering (if talented) in the default action lists.  This is useful if you are concerned with maintaining a minimum Maelstrom pool to use on Stormbringer procs, etc.\n\n" ..
                "The addon default is 0 (but obeys the cost of Sundering).  Wordup's Enhancement Shaman guide on Wowhead recommends Sundering if you have > 110 Maelstrom.\n\n" ..
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.sundering_maelstrom|r syntax.",
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
        addMetaFunction( 'state', 'active_enemies', function ()
            local enemies = state.spec.enhancement and ns.getNameplateTargets() or -1
          
            state.active_enemies = max( 1, enemies > -1 and enemies or ns.numTargets() )

            if state.min_targets > 0 then state.active_enemies = max( state.min_targets, state.active_enemies ) end
            if state.max_targets > 0 then state.active_enemies = min( state.max_targets, state.active_enemies ) end

            return state.active_enemies
        end )


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
            gain( 6 * max( 5, active_enemies ), 'maelstrom' )
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
            gain( 6 * max( 5, active_enemies ), 'maelstrom' )
        end )


        addAbility( 'lava_burst', {
            id = 51505,
            spend = -8,
            spend_type = 'maelstrom',
            cast = 2,
            gcdType = 'spell',
            cooldown = 8,
            charges = 1,
            recharge = 8
        } )

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
                return -8 - ( buff.power_of_the_maelstrom.up and 6 or 0 )
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
            known = function () return talent.totem_mastery.enabled end,
            usable = function () return buff.totem_mastery.remains < 15 end
        } )

        addHandler( 'totem_mastery', function ()
            applyBuff( 'resonance_totem', 3600 )
            applyBuff( 'storm_totem', 3600 )
            applyBuff( 'ember_totem', 3600 )
            if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
            applyBuff( 'tailwind_totem', 3600 )
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


    storeDefault( [[SimC Elemental: default]], 'actionLists', 20170110.2, [[dau5jaqifISieQnPqQrbr1Pqq2frgMcoMalJe9mfQPrkQCnfs2gKY3qGXPqiNtHaRJuK5HGY9GOK9HGQdsuwiPYdfutuHGUijSrfIAKKIQojHyLKIIzcrXnHWoj4NkeQHskkTub5POMkezVs)LKmyi5WQSye9ykMmLUmyZKsFwPmAsvNgPxdPA2qDBH2TOFRQHtsTCf9CLmDQUoHA7iKVtkCEIQ1drPMpH0(vQUbfPYkYJed2QR8ie0EIXE1vMntQAVC5qagUfubLdbemeemifuMvdg6HPi7ZPFwbLOPSSmJt)CvKQqqrQSI8iXGTKLfUiuwZdZNUILzZKQ2l7)2ggKm)JTVg5A0i3V5g4s6Hd76LuBCct5OevuNgbcFqAuddeQCiad3cQGYHa0ciqAyCzzKum1LxMe)VflE5LfjTuZ5)SC(juoSEWGoINiicPxYYiERWfHY1RGYIuzf5rIbB1vMntQAVS)BByqs970pxJg5KI1QvcWqes)WQI3YHPCjXQfvu)MBGl50iOYFvwkqyiRXdIkkPyTALiX)BXIxUKy1eQSmskM6YlR(D6NLfjTuZ5)SC(juw4Iqzn770pllBUTkNxeqweBHZILRABEgG4YHamClOckhcqlGaPHXLdRhmOJ4jcIq6LSmI3kCrOmXw4Sy5Q2MNbiUEfgxKkRipsmyRUYcxekJ07qChfIB5WuEz2mPQ9YKI1QvAcRpV0aQ83HO0eIhnxeMYYHamClOckhcqlGaPHXLLrsXuxEz)DiQkElhMYllsAPMZ)z58tOCy9GbDeprqesVKLr8wHlcLRxbnxrQSI8iXGT6klCrO8itNWokfyicPF4YSzsv7L9FBddsM)X2xJCvoeGHBbvq5qaAbeinmUSmskM6YlRLobvagIq6hUSiPLAo)NLZpHYH1dg0r8ebri9swgXBfUiuUEfgvrQSI8iXGT6klCrOm7)mUJsbgIq6hUmBMu1Ez)32WGK5FS91ixLdby4wqfuoeGwabsdJllJKIPU8Yl)NrvagIq6hUSiPLAo)NLZpHYH1dg0r8ebri9swgXBfUiuUEfqRivwrEKyWwDLfUiuwbgIq6hEhfIB5WuEz2mPQ9Y(VTHbjZ)y7RrUkhcWWTGkOCiaTacKggxwgjftD5LbmeH0pSQ4TCykVSiPLAo)NLZpHYH1dg0r8ebri9swgXBfUiuUEfiOivwrEKyWwDLfUiuwh(F7oQrw8uEz2mPQ9Y(VTHbjZ)y7RrUgnYhj)Wq6s3YaP9sdib5rIbROIskwRwPBzG0EPbKeRwurn)JTVgP0TmqAV0astiE0Cr4JAGqLdby4wqfuoeGwabsdJllJKIPU8YK4)TQ0kEkVSiPLAo)NLZpHYH1dg0r8ebri9swgXBfUiuUEfgrfPYkYJed2QRSWfHY6G5cMOtZTYSzsv7L9FBddsM)X2xJCnAKps(HH0LULbs7LgqcYJedwrfLuSwTs3YaP9sdijwnHkhcWWTGkOCiaTacKggxwgjftD5LjH5cMOtZTYIKwQ58Fwo)ekhwpyqhXteeH0lzzeVv4Iq56vyeuKkRipsmyRUYSzsv7LpJtjcubjePWIWvURzklJKIPU8YtXPQZ40pvHPlVSiPLAo)NLZpHYcxekhsCUJsMXPFUJczOlVSS52QC5qagUfubLdbOfqG0W4YS(xdeVLQLcZv1voSEWGoINiicPxYYiERWfHYeZ0y4DukWqes)WAAhLSrScIRxHGHIuzf5rIbB1vMntQAVSFyiDPBzG0EPbKG8iXGTSmskM6YlpfNQoJt)ufMU8YIKwQ58Fwo)eklCrOCiX5okzgN(5okKHU8DuipGqLLn3wLlhcWWTGkOCiaTacKggxM1)AG4TuTuyUQUYH1dg0r8ebri9swgXBfUiuMyMgdVJsbgIq6hwt7Ow0Cdd7OULH46viiOivwrEKyWwDLzZKQ2l7hgsxIAaTINYLG8iXGTSmskM6YlpfNQoJt)ufMU8YIKwQ58Fwo)eklCrOCiX5okzgN(5okKHU8DuixjHklBUTkxoeGHBbvq5qaAbeinmUmR)1aXBPAPWCvDLdRhmOJ4jcIq6LSmI3kCrOmXmngEhLcmeH0pSM2rTO5gg2rr1sC9keOSivwrEKyWwDLzZKQ2l7hgsxct307jn3unFReKhjgSLLrsXuxE5P4u1zC6NQW0LxwK0snN)ZY5NqzHlcLdjo3rjZ40p3rHm0LVJc5JjuzzZTv5YHamClOckhcqlGaPHXLz9VgiElvlfMRQRCy9GbDeprqesVKLr8wHlcLjMPXW7OuGHiK(H10oQfn3WWok8K461llCrOmtJH3rPadri9dRPDuwq7jg71Bb]] )

    storeDefault( [[SimC Elemental: precombat]], 'actionLists', 20170110.2, [[d8ImcaGEPsAxOuBtenBQCtPQVjvStrTxYUrSFOWWqv)wvdLQidgs1WfPdIuDmOAHOOLsvzXiz5szrIWtbltfEoQmrQIAQqPjRstx4IOKlRCDPsTzQc2ou0HL8zu4XqCBkoVkA0qk)fs6KqIhsv1PP09Ok0ZOk9AKY6KkXcxyfWIuuUDftbEEEO62fIPaaPztdbc8n3kUP8bpEhECCE24cG0HylNTRvyFIYhjpeqhjSpHtyvgxyfWIuuUDftbasZMgcINbd3yN(H9jCcOtzD24uq6h2NiafY1IuX3eqEYeKlZe4PpSpra9gdobKYmpM4U66orLrRqwcb(MBf3u(GhpjEh28Ef4hTHqR)XCMrcrjO)V5YmbjURUUtuz0kKLqHYhcRawKIYTRykixMja7hZGb69fxS2PaFZTIBkFWJNeVdBEVcOtzD24uq8XmOAkUyTtbOqUwKk(MaYtMa)OneA9pMZmsikb9)nxMjqHYEfwbSifLBxXuqUmtaeFZqBlDnb(MBf3u(GhpjEh28EfqNY6SXPaU4BgABPRjafY1IuX3eqEYe4hTHqR)XCMrcrjO)V5YmbkuiixMjaSg)yGol3mJeLRlyGEABiVHQcfsa]] )

    storeDefault( [[SimC Elemental: single lr]], 'actionLists', 20170110.2, [[d0dLoaGEIePnPsYUOKTjH2NkPMjrQMnPMprI6MQuhwPVPs8yQSti2Ry3k2pjmkkvnmv0VrCBkoVe1GjkdNs5GsWPuHCmK64QqzHKOLQQYIH0YL0dvbpf1YiQwhrIyIQqvMQezYQY0L6IKKxrPs6YGRteBKiPonuBMaBNGoKkuvFNiLPrPsmpIeETQYFPQgnHEgj1jvv1NPkxJsL6EuQyCej5CQqLNJKdDkfw1SOA4fLHpEGGvIUJYWSRIT1Hd)d0Wsbbr(j9LtA6tl6WSnWHxnwkDBmzcI8IYdxW1yYqLsbHoLcRAwun8IYWiRbcl161akKXIe3xy2vX26Wh)g7(WJx4FGgwkiiYpPlsFX6uD4cOynUlhwGEnGpLiX9f()8WUTj1WdzGWheb33nriyGPdA4BYdznq40brEkfw1SOA4fLHrwdew1wBXJjz)GWSRIT1HrLiqGf4ejaLprGFlc(EvyBFkjZdQ4XZsITRmlOP6kXy5KuRW0xBhPQy4FGgwkiiYpPlsFX6uD4cOynUlhg2AlEmj7he()8WUTj1WdzGWheb33nriyGPdA4BYdznq40brDkfw1SOA4fLHrwdew1wBrfYyrI7lm7QyBDyZcAQUsmwoj1km91254Kh(hOHLccI8t6I0xSovhUakwJ7YHHT2I(uIe3x4)Zd72MudpKbcFqeCF3eHGbMoOHVjpK1aHthe7skfw1SOA4fLHrwdeMBs18bGnOgMDvSTo86ASqWhgWGbQRvh(hOHLccI8t6I0xSovhUakwJ7YHPAs18bGnOg()8WUTj1WdzGWheb33nriyGPdA4BYdznq40bXUtPWQMfvdVOmmYAGWQ0GbME1kKPuVuD4FGgwkiiYpPlsFX6uD4cOynUlhg0GbME1(O6LQd)FEy32KA4Hmq4dIG77MiemW0bn8n5HSgiC6GumLcRAwun8IYWiRbclD8XKGFkKDVEMvHSsKgmHzxfBRdVUgle8HbmyG6A1H)bAyPGGi)KUi9fRt1HlGI14UCyn(ysWpFZ6zw)M0Gj8)5HDBtQHhYaHpicUVBIqWath0W3KhYAGWPdYLukSQzr1WlkdJSgiS0xHRczkLuP6WSRIT1HFK2sGEnGpLiX9zvbZIhQRDlv73ydCLJq0pI0g)kSUo8pqdlfee5N0fPVyDQoCbuSg3LdRxHRpQKkvh()8WUTj1WdzGWheb33nriyGPdA4BYdznq40brQsPWQMfvdVOmmYAGWsTEnGczSiX9PqM90hfMDvSToSzbnvxjglNKAfM(A7i)8kujceybAWatVAFbeNeklj2UQccQaL4IQHW)anSuqqKFsxK(I1P6WfqXACxoSa9AaFkrI7l8)5HDBtQHhYaHpicUVBIqWath0W3KhYAGWPdYXLsHvnlQgErzyK1aHvT1wuHmwK4(uiZE6JcZUk2wh2SGMQReJLtsTctFTDKQIH)bAyPGGi)KUi9fRt1HlGI14UCyyRTOpLiX9f()8WUTj1WdzGWheb33nriyGPdA4BYdznq40bH(mLcRAwun8IYWiRbcxI0GrHS7LQHA5WSRIT1HrLiqGvfOiZooWVjnySQGzXdLuqFkLLY2JkrGaRkqrMDCGFtAWyvbZIhkPWEujceyTuoyE74aRNK62yYyxDeI(rK2yTuoyE74aRkyw8qD0vocr)isBSwkhmVDCGvfmlEOKcA7(OW)anSuqqKFsxK(I1P6WfqXACxoCtAW4BwQgQLd)FEy32KA4Hmq4dIG77MiemW0bn8n5HSgiC6GqtNsHvnlQgErzyK1aHvT1w8ys2pqHm7Ppkm7QyBDyujceyborcq5te43IGVxf22NsY8GkE8SKyl8pqdlfee5N0fPVyDQoCbuSg3LddBTfpMK9dc)FEy32KA4Hmq4dIG77MiemW0bn8n5HSgiC6GqlpLcRAwun8IYWiRbclDSNyp4XtHmLeDhMDvSTomQebcSSrKgu9jc8BrW3SGMQReJLeBxTUgle8HbmyGskuF1dqLiqGLg7j2dE88RKN1JiTj8pqdlfee5N0fPVyDQoCbuSg3LdRXEI9GhpFuIUd)FEy32KA4Hmq4dIG77MiemW0bn8n5HSgiC6GqRoLcRAwun8IYWiRbclDSNyp4XtHmLeDRqM90hfMDvSTomQebcSSrKgu9jc8BrW3SGMQReJLeBxTUgle8HbmyGskuh(hOHLccI8t6I0xSovhUakwJ7YH1ypXEWJNpkr3H)ppSBBsn8qgi8brW9Dtecgy6Gg(M8qwdeoDqOTlPuyvZIQHxuggznq4dIlEuit6ypXEWJxy2vX26WRRXcbFyadgOUM(Q11yHGpmGbduxtF1dqLiqGLg7j2dE88RKN1JiTj8pqdlfee5N0fPVyDQoCbuSg3Ld7ex84RXEI9GhVW)Nh2TnPgEide(Gi4(UjcbdmDqdFtEiRbcNoi02Dkfw1SOA4fLHrwde(G4IhfYKo2tSh84PqM90hfMDvSTo86ASqWhgWGbQRPVADnwi4ddyWa110H)bAyPGGi)KUi9fRt1HlGI14UCyN4IhFn2tSh84f()8WUTj1WdzGWheb33nriyGPdA4BYdznq40bHUykfw1SOA4fLHrwdew6ypXEWJNczkj6wHm7LFuy2vX26WpavIabwASNyp4XZVsEwpI0MW)anSuqqKFsxK(I1P6WfqXACxoSg7j2dE88rj6o8)5HDBtQHhYaHpicUVBIqWath0W3KhYAGWPdc9LukSQzr1WlkdxafRXD5WASNyp4XZhLO7W)Nh2TnPgEidegznqyPJ9e7bpEkKPKOBfYSx9rHpu2PHsB1dAQGg(hOHLccI8t6I0xSovhUq1JkSRStd(9w9GMYopavIabwASNyp4XZVsEwsSf(Gi4(UjcbdmDqdFtEiRbcNoi0svkfw1SOA4fLHzxfBRdxbbvGsCr1q4cOynUlhwGEnGpLiX9f()8WUTj1WdzGW3eH4XlmDyK1aHLA9AafYyrI7tHm7LFu4cvpQWgIq84zh6W)anSuqqKFsxK(I1P6Wheb33nriyGPJYW3KhYAGWPdc9XLsHvnlQgErz4cOynUlhg2Al6tjsCFH)ppSBBsn8qgi8nriE8cthgznqyvBTfviJfjUpfYSx(rHlu9OcBicXJNDOd)d0Wsbbr(jDr6lwNQdFqeCF3eHGbMokdFtEiRbcNoiYptPWQMfvdVOmCbuSg3LdlqVgWNsK4(c)FEy32KA4Hmq4BIq84fMomYAGWsTEnGczSiX9PqM9QpkCHQhvydriE8SdD4FGgwkiiYpPlsFX6uD4dIG77MiemW0rz4BYdznq40PdJSgimJnhuitLgmW0RwkrHmk84PbfY010ja]] )

    storeDefault( [[SimC Elemental: single if]], 'actionLists', 20170110.2, [[d4JFoaGEKsvTjII2Le2gL0(ikmtfOoSsZMI5tukUPc9yQ8njYTj1ovXEf7wv7NKmkfKHjj)gLZtjonHbtIgojCqkvNsb1Xq0XvaTqIQLQiTyewov9qfXQikHLHkToKsvMisPIPkrnzu10L6IKuVIOu6YGRRsTrfihcPuPnRO2os1NrfVwsnnIs03va8mkL)QsgnrMhsPCsKIXrusxtbO7HuY5ikvphjpf6qMYbv)lHb4J8G0oW8EB6ipi68cfDWGtbdSuqoCRilvrswvqgevaoXAe0(BlyFoCTYnODxlypvkNdzkhu9VegGpYdEwneCqMvdQuIsmxDq05fk6G0UTWvlEobNcgyPGC4wrALSurLTG2jegrBj4Sz1WfLeZvhKMNx42M5d(ShcorcC1Jm6Gg(oebhz8NvdbtNd3uoO6FjmaFKh8SAiO613sd8ERHGOZlu0bjUNNlaNedOUyZxTeCXXdBFrD)8Gx8CkUvit9cgQ2Z0fUBVh(wg0swTgCkyGLcYHBfPvYsfv2cANqyeTLGW6BPbEV1qqAEEHBBMp4ZEi4ejWvpYOdA47qeCKXFwnemDo2s5GQ)LWa8rEWZQHGQxFlPsjkXC1brNxOOdQxWq1EMUWD79W3YGwYo3GtbdSuqoCRiTswQOYwq7ecJOTeewFlDrjXC1bP55fUTz(Gp7HGtKax9iJoOHVdrWrg)z1qW05ilt5GQ)LWa8rEWZQHGyZ86Aaua(GtbdSuqoCRiTswQOYwq7ecJOTeKQzEDnakaFqAEEHBBMp4ZEi4ejWvpYOdA47qeCKXFwnemDodykhu9VegGpYdEwneuTb0W3RrLs5MLQdofmWsb5WTI0kzPIkBbTtimI2sqWaA471CrywQoinpVWTnZh8zpeCIe4Qhz0bn8DicoY4pRgcMohRPCq1)sya(ip4z1qqACW8T3sq05fk6G6fmuTNPlC3Ep8nTrRswdofmWsb5WTI0kzPIkBbTtimI2sqHdMV9wcsZZlCBZ8bF2dbNibU6rgDqdFhIGJm(ZQHGPZPukhu9VegGpYdEwneCWIbEl4vPCC5OxvklZAqheDEHIo46AbD4cEqlakzyl4uWalfKd3ksRKLkQSf0oHWiAlbnIbEl4V0lh9E1Sg0bP55fUTz(Gp7HGtKax9iJoOHVdrWrg)z1qW05iRPCq1)sya(ip4z1qWbl4i1V45OsPCMPdIoVqrhK4EEUqbBaa)fB(QLGl9cgQ2Z0f3kKjX98CbvZ86Aaua(IBfYCDTGoCbpOfafTzl4uWalfKd3ksRKLkQSf0oHWiAlbncos9lEoxemthKMNx42M5d(ShcorcC1Jm6Gg(oebhz8NvdbtNJSNYbv)lHb4J8GNvdbh8sFvPu(TNQdIoVqrhKN1fZMvdxusmxDHh0R4PKHBP6RwObz6ymdpBa(lpSUo4uWalfKd3ksRKLkQSf0oHWiAlbnl99I42t1bP55fUTz(Gp7HGtKax9iJoOHVdrWrg)z1qW05qwLYbv)lHb4J8GNvdbhKNr1QuIsmxDq05fk6Ge3ZZfchmF7TuCRqMdnKEbdv7z6c3T3dFldAXTAyzJSH4EEUq4G5BVLcpOxXtrBdrwmGYckfGXCjTuniliUNNleoy(2BPGQxxTSLC4HdofmWsb5WTI0kzPIkBbTtimI2sWzpJQVOKyU6G088c32mFWN9qWjsGREKrh0W3Hi4iJ)SAiy6Cijt5GQ)LWa8rEWZQHGdYSAqLsuI5QvPCiYHdIoVqrhuVGHQ9mDH727HVLbT4wjtI755cWaA471CnZC3uf3kKPhM9aL0syGGtbdSuqoCRiTswQOYwq7ecJOTeC2SA4IsI5QdsZZlCBZ8bF2dbNibU6rgDqdFhIGJm(ZQHGPZHKBkhu9VegGpYdIoVqrhK4EEUq4G5BVLIBfbTtimI2sWzpJQVOKyU6G088c32mFWN9qWrgDXZjizWZQHGdYZOAvkrjMRwLYHihoODphQGAgDXZHwKbNcgyPGC4wrALSurLTGtKax9iJoOHVJ8GJm(ZQHGPZH0wkhu9VegGpYdEwneu96BjvkrjMRwLYHihoi68cfDq9cgQ2Z0fUBVh(wg0swTgCkyGLcYHBfPvYsfv2cANqyeTLGW6BPlkjMRoinpVWTnZh8zpeCIe4Qhz0bn8DicoY4pRgcMohszzkhu9VegGpYdEwneSmRbTkLJlvdElbrNxOOdsCppx4bk2VVdUAwd6cpOxXtrBKvbNcgyPGC4wrALSurLTG2jegrBjyZAqFPxQg8wcsZZlCBZ8bF2dbNibU6rgDqdFhIGJm(ZQHGPZHCat5GQ)LWa8rEWZQHGQxFlnW7TguPCiYHdIoVqrhK4EEUaCsmG6InF1sWfhpS9f19ZdEXZP4wrWPGbwkihUvKwjlvuzlODcHr0wccRVLg49wdbP55fUTz(Gp7HGtKax9iJoOHVdrWrg)z1qW05qAnLdQ(xcdWh5bpRgcoybhP(fphvkLZmTkLdroCq05fk6Ge3ZZfkyda4VyZxTeCPxWq1EMU4wHmxxlOdxWdAbqrB2cofmWsb5WTI0kzPIkBbTtimI2sqJGJu)INZfbZ0bP55fUTz(Gp7HGtKax9iJoOHVdrWrg)z1qW05qwkLdQ(xcdWh5bpRgcorAfVkLdwWrQFXZji68cfDW11c6Wf8GwauYGuMRRf0Hl4bTaOKbzWPGbwkihUvKwjlvuzlODcHr0wc6KwXFzeCK6x8CcsZZlCBZ8bF2dbNibU6rgDqdFhIGJm(ZQHGPZHuwt5GQ)LWa8rEWZQHGdwWrQFXZrLs5mtRs5qCho4uWalfKd3ksRKLkQSf0oHWiAlbncos9lEoxemthKMNx42M5d(ShcorcC1Jm6Gg(oebhz8NvdbtNdPSNYbv)lHb4J8GOZlu0b9WShOKwcde0oHWiAlbNnRgUOKyU6G088c32mFWN9qWrgDXZjizWZQHGdYSAqLsuI5QvPCiUdh0UNdvqnJU45qlYGtbdSuqoCRiTswQOYwWjsGREKrh0W3rEWrg)z1qW05WTkLdQ(xcdWh5bTtimI2sqy9T0fLeZvhKMNx42M5d(ShcoYOlEobjdEwneu96BjvkrjMRwLYH4oCq7Eoub1m6INdTidofmWsb5WTI0kzPIkBbNibU6rgDqdFh5bhz8NvdbtNdxYuoO6FjmaFKh0oHWiAlbNnRgUOKyU6G088c32mFWN9qWrgDXZjizWZQHGdYSAqLsuI5QvPCiBdh0UNdvqnJU45qlYGtbdSuqoCRiTswQOYwWjsGREKrh0W3rEWrg)z1qW0PdEwneef6jQuQ2aA471q7PsjL45yavkfZPtaa]] )

    storeDefault( [[SimC Elemental: AOE]], 'actionLists', 20170110.2, [[dWZthaGEIe1MKqTlPY2eP2hrkntqsZgv3usoSW3ejpwP2Pu2l1UvSFrXOisXWivJdKi3MKZlv1GfrdhK6GevNseIJHKZbsuleHwQKYIb1Yr0dfLEk0YifRJibtuestLuAYkz6axKOCAuUSQRlbBKiPEMKQnlc2Ue9CK61i4ZGyEIqnnje)LigTO67ej0jLQCiqcxJij3tcPFt44eP6NejYMYAnkBcy(xMOXe9jef4at0iUjzqdmAS25pOVBA0PsPtrP3rzeH(BwWzs5aWeJBAsRXO8nGjgAR1nkR1OSjG5FzIgBH6grGGur4h6tAS25pOVBA0PstLQtVUr5Wmod03inqqQi8d9jn2BwSDaeKghXCJzZ)MqLO8QpadBSsSAH6gnWnnwRrztaZ)Yen2c1nkNE)zfZ(gXnjdAGrGace(72cbFjKIdTXAN)G(UPrNknvQo96gLdZ4mqFJb9(ZkM9n2BwSDaeKghXCJzZ)MqLO8QpadBSsSAH6gnWT6wRrztaZ)Yen2c1ncvM0lWwzswfqurMKAfGRmw78h03nn6uPPs1Px3OCygNb6BKZKEb2sIkGOcjab4kJ9MfBhabPXrm3y28VjujkV6dWWgReRwOUrdCRiwRrztaZ)Yen2c1nk18q9mjXCXMGrCtYGgym2aw5L85k2PtCrkwfNtdifQUDbsYpaPTOA0lgkab)dOJZGKdg2arcPy19jG5FzS25pOVBA0PstLQtVUr5Wmod03yc8qDj05InbJ9MfBhabPXrm3y28VjujkV6dWWgReRwOUrdCtQSwJYMaM)LjASfQBuwqcYLEHGWnw78h03nn6uPPs1Px3OCygNb6B8bjix6fcc3yVzX2bqqACeZnMn)BcvIYR(amSXkXQfQB0a3sBTgLnbm)lt0ylu3iuJYitsIfiPbgXnjdAGXLa0LapuxcDUytOJ8QGn0s7oObsam1lgUqcj0XJYqcDbsiVRa0fdfGG)b0XzqYbdBGiHuS6(eW8Vko2aw5L85k2PtCrmw78h03nn6uPPs1Px3OCygNb6BKhLHe4cK0aJ9MfBhabPXrm3y28VjujkV6dWWgReRwOUrdClL1Au2eW8VmrJTqDJY4x9be8mjjYdAGrCtYGgyekab)dOJZGKdg2arcPy19jG5FvCSbSYl5ZvStNyPYyTZFqF30OtLMkvNEDJYHzCgOVXZV6di4sG5bnWyVzX2bqqACeZnMn)BcvIYR(amSXkXQfQB0a3GswRrztaZ)Yen2c1nc1OmYKK4dLXAN)G(UPrNknvQo96gLdZ4mqFJ8OmKa)qzS3Sy7aiinoI5gZM)nHkr5vFag2yLy1c1nAGBqzR1OSjG5FzIgBH6gZMhSjtsOYGKdg2aXyTZFqF30OtLMkvNEDJYHzCgOVXDEWgjCgKCWWgig7nl2oacsJJyUXS5FtOsuE1hGHnwjwTqDJg4gLU1Au2eW8VmrJYHzCgOVrEugsGlqsdm2BwSDaeKghXCJvIs2aXiLXwOUrOgLrMKelqsdYKuAOseJYjHqBujkzdKIszS25pOVBA0PstLQtVUXS5FtOsuE1hGjASsSAH6gnWnkkR1OSjG5FzIgXnjdAGrYNa5PZdy(nkhMXzG(gtGhQlHoxSjyS3Sy7aiinoI5gReLSbIrkJTqDJsnpuptsmxSjKjP0qLigLtcH2OsuYgifLYyTZFqF30OtLMkvNEDJzZ)MqLO8Qpat0yLy1c1nAGbgBH6grMkBMKY4x9beCPqMKYLsYmWg]] )

    storeDefault( [[SimC Elemental: single asc]], 'actionLists', 20170110.2, [[d0ZRpaGEisvBIIyxezBuv2hvQMjvknBknFisUjeoSW3uHEmP2jK2R0UvSFQWOOkAyIY4OiLBtY9GQYGPIgos1bPQ6uufogsoheblKIAPqLwmuwUipeI6POwgr16OivnrisLPQcMSQA6kDrQKxrrQCzW1fvBeQQCAcBwLSDKYRvrFNIKPbrkZJkfhcQQ6zuLgnf(Rk1jHQ8zIY1Gi05HkEUQ8BehhIOlvpu21eyw4xZLr6GRi3U1CzwNe03YLXfSq8GIkpJ6ygfvMevzMoOfHvG0hRGmfvUp5L9RxbzE9qrP6HYUMaZc)AUmAOGY(FAy(XOHYSojOVLxImzwqsti2pXuZZep)Kv6Ygk4(zq0NsjqfI55ow(1Lu80W8Jrds)8uScYyINRqbUJpFzifsHLFDjHzjKVn)Ts509WenHy)etns2GwCJLNERucuHyEUNzc(JLFDj9wssDcaDijLt3JY4cwiEqrLNr5J6OuM3Y(XewXIt54PH5hJgkJ38f6yjPYdzGYiBa6teeAGcMTyLrq(OHck3TOY7HYUMaZc)AUmAOGY4NnuGdNSbrFwM1jb9Tm(Vc9PyKvgxWcXdkQ8mkFuhLY8w2pMWkwCkFzdfC)mi6ZY4nFHowsQ8qgOmYgG(ebHgOGzlwzeKpAOGYDlQ3EOSRjWSWVMlJgkOm(zdf4WjBq0NoC6jLhLzDsqFlRcW(2erjPZtjyw3XN8mtsGkeZZn4dl)6skEAy(XObPFEkwbzmrti2pXuJu80W8JrdsjqfI5z6WYVUKINgMFmAq6NNIvqg3GVFEkwbzkJlyH4bfvEgLpQJszEl7htyfloLVSHcUFge9zz8MVqhljvEidugzdqFIGqduWSfRmcYhnuq5UffP1dLDnbMf(1Cz0qbLDfP1ajZJtOmRtc6BzS8RljqBqG3n56EnGBzji27x(8HKyKjLt3e8hl)6skEAy(XObPC6MOcW(2erjPZtjyw3XNP5RmUGfIhuu5zu(OokL5TSFmHvS4ugI0AGK5XjugV5l0XssLhYaLr2a0Nii0afmBXkJG8rdfuUBrrI9qzxtGzHFnxgnuqzxrAnC4Kni6ZYSojOVLvbyFBIOK05PemR74dji3e8hl)6skEAy(XObPC6LXfSq8GIkpJYh1rPmVL9JjSIfNYqKwJ7NbrFwgV5l0XssLhYaLr2a0Nii0afmBXkJG8rdfuUBr91dLDnbMf(1Cz0qbL5LKuNaqhsLXfSq8GIkpJYh1rPmVL9JjSIfNYVLKuNaqhsLXB(cDSKu5HmqzKna9jccnqbZwSYiiF0qbL7w0J9qzxtGzHFnxgnuqzxwqbZgwhonBJ3wgxWcXdkQ8mkFuhLY8w2pMWkwCkdwqbZg2BmB82Y4nFHowsQ8qgOmYgG(ebHgOGzlwzeKpAOGYDlQP1dLDnbMf(1Cz0qbLDRajZfFhoreYuHdNhilOkZ6KG(wo0RGgCddOeWZDVLXfSq8GIkpJYh1rPmVL9JjSIfNYwbsMl(3QqMkUxYcQY4nFHowsQ8qgOmYgG(ebHgOGzlwzeKpAOGYDlksOhk7Acml8R5YOHck7wHmJDeJmhontSBzwNe03Yy5xxs0jMcs3KR71aUvbyFBIOKYPBcw(1L0Bjj1ja0HKuoDtc9kOb3Wakb8CJ3Y4cwiEqrLNr5J6OuM3Y(XewXItzRqMXoIr2ngXULXB(cDSKu5HmqzKna9jccnqbZwSYiiF0qbL7wuQSEOSRjWSWVMlJgkOSBdAHdNMZtVTmRtc6B5pzLUSHcUFge9PucuHyEURJ3EVcfyINAcX(jMAUtqOxKcPWYVUKINgMFmAqkNUhLXfSq8GIkpJYh1rPmVL9JjSIfNY2GwCJLNEBz8MVqhljvEidugzdqFIGqduWSfRmcYhnuq5UfLIQhk7Acml8R5YOHckJF2qboCYge9PdNEk3JYSojOVLvbyFBIOK05PemR74tEMjy5xxsGfuWSH9(IOZFs50lJlyH4bfvEgLpQJszEl7htyfloLVSHcUFge9zz8MVqhljvEidugzdqFIGqduWSfRmcYhnuq5UfLsEpu21eyw4xZLrdfu2vKwdhozdI(0HtpP8OmRtc6Bzva23MikjDEkbZ6o(mnFLXfSq8GIkpJYh1rPmVL9JjSIfNYqKwJ7NbrFwgV5l0XssLhYaLr2a0Nii0afmBXkJG8rdfuUBrP82dLDnbMf(1Cz0qbLpqwq5WjI4TqcNYSojOVLXYVUKsWJmXOH7LSGskbQqmp3qLHuiLNy5xxsj4rMy0W9swqjLaviMNB8el)6skEAy(XObPFEkwbzmDAcX(jMAKINgMFmAqkbQqmppmrti2pXuJu80W8JrdsjqfI55gkKOhLXfSq8GIkpJYh1rPmVL9JjSIfNYlzb1TkElKWPmEZxOJLKkpKbkJSbOprqObky2Ivgb5JgkOC3IsH06HYUMaZc)AUmAOGYUI0AGK5Xj4WPNuEuM1jb9Tmw(1LeOniW7MCDVgWTSee79lF(qsmYKYPxgxWcXdkQ8mkFuhLY8w2pMWkwCkdrAnqY84ekJ38f6yjPYdzGYiBa6teeAGcMTyLrq(OHck3TOuiXEOSRjWSWVMlJgkOSBdAHdNMHqvM1jb9TCOxbn4ggqjGN7uMe6vqdUHbuc45ovzCblepOOYZO8rDukZBz)ycRyXPSnOf3yqOkJ38f6yjPYdzGYiBa6teeAGcMTyLrq(OHck3TOu(6HYUMaZc)AUmAOGYUviZyhXiZHtZe76WPNuEuM1jb9Tmw(1LeDIPG0n56EnGBva23MikPC6Me6vqdUHbuc45gVLXfSq8GIkpJYh1rPmVL9JjSIfNYwHmJDeJSBmIDlJ38f6yjPYdzGYiBa6teeAGcMTyLrq(OHck3TOuh7HYUMaZc)AUmAOGYiBeIXHt3kKzSJyKvM1jb9TCOxbn4ggqjGN7uMe6vqdUHbuc45ovzCblepOOYZO8rDukZBz)ycRyXPS2ieZTviZyhXiRmEZxOJLKkpKbkJSbOprqObky2Ivgb5JgkOC3IszA9qzxtGzHFnxgnuqz3kKzSJyK5WPzIDD40t5EugxWcXdkQ8mkFuhLY8w2pMWkwCkBfYm2rmYUXi2TmEZxOJLKkpKbkJSbOprqObky2Ivgb5JgkOC3IsHe6HYUMaZc)AUmRtc6B5eCLGNrGzHY(XewXIt5lBOG7NbrFwgV5l0XssLhYaLrqOjgzLPkJgkOm(zdf4WjBq0NoC6Pxpk7pj7vwrOjgz4JQmUGfIhuu5zu(OokL5TmYgG(ebHgOGzR5YiiF0qbL7wu5z9qzxtGzHFnx2pMWkwCkdrAnUFge9zz8MVqhljvEidugbHMyKvMQmAOGYUI0A4WjBq0NoC6PCpk7pj7vwrOjgz4JQmUGfIhuu5zu(OokL5TmYgG(ebHgOGzR5YiiF0qbL7wu5u9qzxtGzHFnx2pMWkwCkFzdfC)mi6ZY4nFHowsQ8qgOmccnXiRmvz0qbLXpBOahozdI(0HtprAEu2Fs2RSIqtmYWhvzCblepOOYZO8rDukZBzKna9jccnqbZwZLrq(OHck3TBz0qbLzHczhoDzbfmByn9oC(eJml4Wz80DBb]] )

    storeDefault( [[SimC Enhancement: default]], 'actionLists', 20170110.2, [[daeBDaqiPewerfAtqsJcsCkLQEfueSliggL6yu0YispJsmnukUguK2MsX3uQmoIk5Cev06iQaMhkLUhuu7JOQdcPSqPupuP0ejQGUiKQnsuPgjueYjHQAMsj6MOKDIIHsubAPqHNsAQqv(kueTxv)fknyuQoSWILQhROjtLld2Sc(ScnAP40i9Aky2eUnvTBr)gXWjklhvpxjtxY1HkBNc9DPKopL06HIqnFIO9te(MhVRONrxaU3(QCime4e1BFvLbtAiOyIJIsYZiDJLRyaciwWzKABUZ200gX8Qo5uz11ROnlkjxhVZyE8UIEgDb4E7R6KtLvxlY4OaqOzbCooz16kt4HRysA6KGDTbc(1TnW0alIrWdz9(vmabel4msTn3yUdX2Yv8thDgfHFnjjCfTovqlRxBLMoSRgi4xzrCmHhU(6mspExrpJUaCVFvNCQS6ArghfaYKqeosR5cvuQGpcfsdeIQbr2SyRumvsjlQhK3gbtTT3FLj8WvmraNqx(RBBGPbweJGhY69RyaciwWzKABUXChITLR4No6mkc)Ass4kADQGwwV2feItGBvxzrCmHhU(6mwoExrpJUaCV9vDYPYQRfzCuaitcr4iTMlurPfbVOdXSqcHSMaBReXacpsdYBlPKO4dqSkoXJmXX5qwYJzP2OojeHJ0AIm5XQbRGo2ujnhr4GpO5ITyEC62V)kt4HRYnWdHeSRYOCADDBdmnWIye8qwVFfdqaXcoJuBZnM7qSTCf)0rNrr4xtscxrRtf0Y61bGhcSlzuoTUYI4ycpC91zyZX7k6z0fG7TVQtovwDn4fDiMfsiK1eyBLigq4rAqEBuLXbJyhNoetKbGhcSlzuoTUYeE46wESAKG9wshBQKMJx32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEDYJvdwbDSPsAoELfXXeE46RZGPhVRONrxaU3(Qo5uz11ImokaKjHiCKwZfQO0XnmGeRjKUiNacozskzlQqazHeRjKUiNacKrxaojLuagbbBnTT3FLj8W12aFbCd0C862gyAGfXi4HSE)kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUIwNkOL1RDGVaUbAoELfXXeE46RZS54Df9m6cW92x1jNkRUwKXrbGmjeHJ0AUUYeE4ABbH4KGD5gh361TnW0alIrWdz9(vmabel4msTn3yUdX2Yv8thDgfHFnjjCfTovqlRx7ccXHDah36vweht4HRVoZUJ3v0ZOla3BFvNCQS6ArghfaImsrj5cvugaEiWUKr50cHd(GMl5XujLSc(iuif1dylcwhfylM3yV)kADQGwwVkJuusEf)0rNrr4xtscxzcpCvoiPOK8kA8X11m8aMLJY4ebjhbhwzKwbUC8kgGaIfCgP2MBm3HyB562gyAGfXi4HSE)klIJj8Wv5OmorqYrWHvgPvGlhFDg564Df9m6cW92x1jNkRU2XnmG0j4eoGpqxfch8bnxSDC6Kusu8biwfN4rM44Cil2Izm1g1ywuJawibpfwYJzl7VYeE4ABcoHd4d0vDDBdmnWIye8qwVFfdqaXcoJuBZnM7qSTCf)0rNrr4xtscxrRtf0Y61obNWb8b6QUYI4ycpC91zKZJ3v0ZOla3BFvNCQS6Ah3WasNGt4a(aDviCWh0CX2XPtsjrz2e8ryHDGhZIsYqiVjYomfvFaIvXjEKjoohYITy202g1ywuJawibpfwSfZs3FLj8W12eCchWhORsc2rXC)1TnW0alIrWdz9(vmabel4msTn3yUdX2Yv8thDgfHFnjjCfTovqlRx7eCchWhOR6klIJj8W1xNX0(4Df9m6cW92x1jNkRUwHaYcrePBjOoabYOlahQDCddiIiDlb1biCWh0CX2XP7kt4HRyqMg60c4x32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSELtMg60c4xzrCmHhU(6mMMhVRONrxaU3(Qo5uz11wu0PbAoIQpaXQ4epYehNdzjVuPxzcpCvUXXTkb7Kbjyhnk)62gyAGfXi4HSE)kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUIwNkOL1Rd44wXsgWgu(vweht4HRVoJP0J3v0ZOla3BFvNCQS6AfcilKMGkwfH7rGm6cWHAh3WaYaNSQopshch8bnxSLdDCddyBLMosRxzcpCvU5Kv15r6UUTbMgyrmcEiR3VIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRO1PcAz96aNSQops3vweht4HRVoJPLJ3v0ZOla3BFvNCQS6Ah3WaYGi8qrYrCach8bnxSLdDCddyBLMosRskjktcr4iTMiocXJTvA6wiCWh0CX2nO2XnmGmicpuKCehGWbFqZfBzZ(RmHhUk3IWdfjhXbx32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEDqeEOi5io4klIJj8W1xNXKnhVRONrxaU3(kt4HRYHeIxc2XK00TUIwNkOL1RocXJTvA6wxXaeqSGZi12CJ5oeBlxXpD0zue(1KKW1TnW0alIrWdz9(vweht4HRVoJjME8UIEgDb4E7R6KtLvxRqazHm5XQHMJyxfH7rGm6cWHAmlQralKGNcl5XSfurPfviGSqAcQyveUhbYOlaNKs2XnmGmWjRQZJ0HWbFqZL8Jt3(RmHhUULhRgjyVL0XMkP5OeSJI5(RBBGPbweJGhY69RyaciwWzKABUXChITLR4No6mkc)Ass4kADQGwwVo5XQbRGo2ujnhVYI4ycpC91zm3C8UIEgDb4E7RmHhUIEWRgiLGDvg1aCfTovqlRxHGxnqIDjJAaUIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRBBGPbweJGhY69RSioMWdxFDgZDhVRONrxaU3(Qo5uz1vuQqazHqmc8ztWhbeiJUaCO6dqSkoXJmXX5qwYJz2yJAlQqazHmGJBflzaBq5iqgDb42lPKOuHaYcHye4ZMGpciqgDb4qTcbKfYaoUvSKbSbLJaz0fGdvFaIvXjEKjoohYsE2yJjmqcSYcNJMJ7VYeE4AlPJnvsZrjyVnrux32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEvqhBQKMJy7erDLfXXeE46RZykxhVRONrxaU3(Qo5uz11oUHbKjpwnyf0XMkP5ich8bnxSDC6qnMf1iGfsWtHL8yw6vMWdx3YJvJeS3s6ytL0Cuc2rr6(RBBGPbweJGhY69RyaciwWzKABUXChITLR4No6mkc)Ass4kADQGwwVo5XQbRGo2ujnhVYI4ycpC91zmLZJ3v0ZOla3BFLj8WvmjnDlsoEfTovqlRxBLMUfjhVIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRBBGPbweJGhY69RSioMWdxFDgP2hVRONrxaU3(Qo5uz11ImokaKjHiCKwZfQO0XnmGSkc3350Ce4i4KT)kt4HROTMq6ICcx32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEnwtiDroHRSioMWdxFDgPMhVRONrxaU3(Qo5uz11oUHbKvr4(oNMJahbNmurbLkeqwid44wXsgWguocKrxaou9biwfN4rM44Cil5XSuBmHbsGvw4C0CCVKsIslQqazHmGJBflzaBq5iqgDb42V)kt4HRysA6wfNAaUUTbMgyrmcEiR3VIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRO1PcAz9AR00Tko1aCLfXXeE46RZiv6X7k6z0fG7TVQtovwDTJByazveUVZP5iWrWjdvuqPcbKfYaoUvSKbSbLJaz0fGdvFaIvXjEKjoohYsEml1gtyGeyLfohnh3lPKO0Ikeqwid44wXsgWguocKrxaU97VYeE4QweUFvCQb462gyAGfXi4HSE)kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUIwNkOL1RRIW9RItnaxzrCmHhU(6msTC8UIEgDb4E7R6KtLvxRqazH0qkSnr6qGm6cWHAh3WasdPW2ePdbNSRmHhU2YWyib7Tmwnx32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEvegdSIy1CLfXXeE46RZiLnhVRONrxaU3(Qo5uz11ywuJawibpfwYJz2CLj8W1T8y1ib7TKo2ujnhLGDuSS)62gyAGfXi4HSE)kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUIwNkOL1RtESAWkOJnvsZXRSioMWdxFDgPy6X7k6z0fG7TVYeE4kMKMUvXPgajyhfZ9xrRtf0Y61wPPBvCQb4kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUUTbMgyrmcEiR3VYI4ycpC91zKU54Df9m6cW92x1jNkRUwHaYcHye4ZMGpciqgDb4qDsichP1erqhBQKMJy7erHWbFqZfBhNou9biwfN4rM44Cil5Ll7RmHhUQfH7xfNAaKGDum3FDBdmnWIye8qwVFfdqaXcoJuBZnM7qSTCf)0rNrr4xtscxrRtf0Y61vr4(vXPgGRSioMWdxFDgP7oExrpJUaCV9vDYPYQRviGSqgWXTILmGnOCeiJUaCO6dqSkoXJmXX5qwYZgBmHbsGvw4C0CevuMeIWrAnre0XMkP5i2oruiCWh0Cj)40jPKTOcbKfcXiWNnbFeqGm6cWT)kt4HRAr4(vXPgajyhfP7VUTbMgyrmcEiR3VIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRO1PcAz96QiC)Q4udWvweht4HRVoJu564Df9m6cW92x1jNkRU2IkeqwieJaF2e8rabYOlahQTOcbKfYaoUvSKbSbLJaz0fG7kt4HRAr4(vXPgajyhfl7VUTbMgyrmcEiR3VIbiGybNrQT5gZDi2wUIF6OZOi8RjjHRO1PcAz96QiC)Q4udWvweht4HRVoJu584Df9m6cW92x1jNkRUIckXSOgbSqcEkSK3usjRqazHm5XQHMJyxfH7rGm6cWjPKviGSq6eCchWhORcbYOla3EuBXckSDsIBHuuGBkNyzJSP827LuYbGhcSlzuoTq4GpO5sEm9kt4HRB5XQrc2BjDSPsAokb7OWM9x32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEDYJvdwbDSPsAoELfXXeE46RZyX(4Df9m6cW92x1jNkRUwHaYcPjOIvr4EeiJUaCO2XnmGmWjRQZJ0HWbFqZfBzdICDLj8Wv5MtwvNhPtc2rXC)1TnW0alIrWdz9(vmabel4msTn3yUdX2Yv8thDgfHFnjjCfTovqlRxh4Kv15r6UYI4ycpC91zSyE8UIEgDb4E7R6KtLvxRqazHmGJBflzaBq5iqgDb4qTcbKfcXiWNnbFeqGm6cWHkklOW2jjUfsrbUPCILnYMYBJQpaXQ4epYehNdzjpMLl79xzcpCTLHXqc2BzSAKGDum3FDBdmnWIye8qwVFfdqaXcoJuBZnM7qSTCf)0rNrr4xtscxrRtf0Y6vrymWkIvZvweht4HRVoJfPhVRONrxaU3(Qo5uz11keqwid44wXsgWguocKrxaouBrfcileIrGpBc(iGaz0fGdvuwqHTtsClKIcCt5elBKnL3gvFaIvXjEKjoohYsEmJPw2FLj8W1wggdjyVLXQrc2rr6(RBBGPbweJGhY69RyaciwWzKABUXChITLR4No6mkc)Ass4kADQGwwVkcJbwrSAUYI4ycpC91zSy54Df9m6cW92x1jNkRUIslwqHTtsClKIcCt5elBKnL3gvFaIvXjEKjoohYsEmBk1EVKsIslQqazHmGJBflzaBq5iqgDb4qDbf2ojXTqkkWnLtSSr2uEBu9biwfN4rM44Cil5XmBS3FLj8W1wggdjyVLXQrc2rXY(RBBGPbweJGhY69RyaciwWzKABUXChITLR4No6mkc)Ass4kADQGwwVkcJbwrSAUYI4ycpC91zSWMJ3v0ZOla3BFvNCQS6Ah3WaYGi8qrYrCach8bnxSLniY1vMWdxLBr4HIKJ4ajyhfZ9x32atdSigbpK17xXaeqSGZi12CJ5oeBlxXpD0zue(1KKWv06ubTSEDqeEOi5io4klIJj8W1xNXcME8UIEgDb4E7RmHhUQ4shWP54v06ubTSEDHlDaNMJxXaeqSGZi12CJ5oeBlxXpD0zue(1KKW1TnW0alIrWdz9(vweht4HRVoJLnhVRONrxaU3(kt4HRyqMg60c4sWokM7VIwNkOL1RCY0qNwa)kgGaIfCgP2MBm3HyB5k(PJoJIWVMKeUUTbMgyrmcEiR3VYI4ycpC91zSS74Df9m6cW92xzcpCvUfHhksoIdKGDuKU)kADQGwwVoicpuKCehCfdqaXcoJuBZnM7qSTCf)0rNrr4xtscx32atdSigbpK17xzrCmHhU(6mwKRJ3v0ZOla3BFLj8W12eCchWhORsc2rr6(RO1PcAz9ANGt4a(aDvxXaeqSGZi12CJ5oeBlxXpD0zue(1KKW1TnW0alIrWdz9(vweht4HRVEDLj8WvL63kb7ONnrobpKLCajy3bdbor96h]] )

    storeDefault( [[SimC Enhancement: precombat]], 'actionLists', 20170110.2, [[dedXbaGEukTlc12efZuLKzt0njKVjsTtf2l1Uf2VkXWeXVLmuvsnysQHdPdIQ6yqSqcAPIklMelxvwebEk4XQQNtkteLutfvzYkA6sDrsYZevDDuI2mkjBhv0YuPUmYNrX3rfomuNhvQrtQEOi5KOuDBvCALUhkH)kk9AujRdLInI5zqvGvK00cnWAIvywkBl0aGs)flx2I7TcpUZK3qossynYJ7eK0jiijIrma)3I2gmW)3BfAMNhiMNbvbwrstl0a8FlABOlggjjgT6Tcnd8vw52CBaT6TcdShZ9J76ziQGmmWhYW1vVvyG)JrZqGpeleG(kzfm0mlAXb9eyihjjSg5XDcsgK0ItYBiLo95suXjDOOTIbr1CGpKbbOVswbdnZIwCqpbU9428mOkWksAAHgg4dz4QLrVJnyUOg0xsonWxzLBZTb5YO3Xgmz10xsonKJKewJ84objdsAXj5nWEm3pURNHOcYqkD6ZLOIt6qrBfdIQ5aFidUDByGpKbypPUOwvOJJpDOOzZf1Op6xhfC72ga]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20170110.2, [[dOJ)eaGEsj7ssvTnsrZusvMTe3eqoSk3MKVjPsTtkTxLDJ0(f(PQsnmI8BPCnqPHsWGPA4u0bvfhLuXXq48KQwiOyPislwswUu9qaEkQhtuphrnreXuvvnzGy6qUifUQKk6YIUoiBKuQNbO2mqA7GQpQQqFgOMgPGVRQGrskuRtvjJwvA8KkDsvfDlcDAOUNKkzzskRvsfEnPqEe7F83WZE50VQX6aLqjiHRDJIcNXALZsuBSqhRUU(W1UrrHZyTYzjQnwOJvxxF4aoteUrd)bQFJzuRRQ6yk4SpUNLXamS)gKoUojNHZMzPOD5i)UQXS5jJPGNf2XcWncxmCssqpOcAWmwaUr4IHdOPQo0Qgd0PlwbPc)hRYzbwASoqjusE)ZsS)Xg0RQKGmyg)iJWnA41dtgnMXkaHBqFpQCQsk6RWn7PCtvDOX2tLJzScq4g03JkNQKI(kCZEk3uvhAmPzjpY5S1Ki0Kqsc4XSChBIgJWQSUKgA2A7FSb9QkjidMXpYiCJgE9WKrJzScq4g03JkNQKI(kCqsqpOcAS9u5ygRaeUb99OYPkPOVchKe0dQGgtAwYJCoBnjcnjKKaEOHglaxiCXWjjb9GkOWFkMV3SeJfGleUy4aAQQdTQXcWfcxmCssqpOcAWmw)SI1awASUZkQz9jKagwcy1SgSPOKeSJjnl5roNTMerDlrqivFIX6aLqz4pfmyQkPOXYJfGBeUy4aAQQdf(tX89MLySaCHWfd))6Gtu4pfZ3BwIXcWfcxmCanv1Hc)Py(EZsm(5BJWfdhOtxScsnR04hzeUrdhWzIWnk5bZyb4gHlg()1bNOvnMntz8vWADiCJoBnnbEmBMLI2LJ8B4aALwF)JVzjgxnlXyWZsmUplXqJb0m1h(FBSb99OYPkPOWzmfCjf)Vo4enwaUq4IH)FDWjAvJ1bkHYWjb3tzeUrht6NFuJ)hBpvo2G(Eu5uLuu4cDS666hRducLGe(NYnA4mwRCwninw7gfn(PJVs42R3BFySb9QkjidMXcDS666d)t5gnCgRvoRgKgt6rbNHd4nL1imf84RcxWi9JF(2iCXWbctXki1Sap(t5gLC48B7d0z1W4)RKuu4FS3GmNvAmJPGlz4IHd0PlwbPMLySqhRUU(WbCMiCJoMC)q424hiulCXWbctXki1SsJfGBeUy4)xhCIc)Py(EZsmMKe0dQGgmJFGqTWfdhOtxScsnR0ygtbxYWfdhimfRGuZknUoAn1SeWowaUr4IHtsc6bvqH)umFVzjgZYDSjA8qB]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20170110.2, [[dWt8eaGEIu7svL2MuQMPukoSkZwu3MKBcepMO(MuIopOyNuAVk7gP9t1pvvXWivJtekNgQHsOblmCk6GI0rfbhdrNtkLwOQQwkO0ILILd4HQkpf1YiI1Pk0eritfOMmqA6qUiPCvrO6YsUoiBeH6zIOnRkA7e4Jsj1NrW0is(UusgPiephunAvPXtqDsvb3IcxJGCpPe61IqATsj43s1JCGhNaubvG6bXDkYdglDnlPKXIce9WWdWhaHcTMXIay1baJhFNjc3PEKcbCJzuhq1aGPekGXavE8NMfSgSJtC4LhSzLZeNp4VRzSOanpm8a8bqOqRzSOanpm8GO65bLr7)yrbAEy4Xxx1CO1mgKtyScs5bySQMnP(4eGkOc(apl5apwJEn5c09FCQmc3PE0gmC0ygR(8qJ(Eu5svu0JEycuYDvZHgBpvnMXQpp0OVhvUuff9OhMaLCx1COXWw56GxZkrNui92)vIeYXSma2engHvvlQp0Ssg4XA0RjxGU)JtLr4o1J2GHJgZy1NhA03JkxQIIE0dqRNhugn2EQAmJvFEOrFpQCPkk6rpaTEEqz0yyRCDWRzLOtkKE7)krc5qdnMLbWMOXWXuc5ASOarpm84RRAo0Aglkq0ddpiQEEqz0(pgMrSr7cP3ws92MSLjtQlvILuFpnKsOXP)O5HHhGCcJvqQz1hdBLRdEnReDYwQtsQ)l54eGkOYJ0mMavvu0y5XIc08WWJVUQ5qEKMnFVzjhlkq0ddpaFaekKhPzZ3BwYXmMsixEy4biykwbPMn54uiu3ddpabtXki1SjhlkqZddpiQEEqzKhPzZ3BwYXIce9WWdIQNhug5rA289MLCCl07QzjfAmBw5mX5d(RhF9ChyGhFZsogywYXeMLCCZSKdn(RBcJhG7J1OVhvUuff5r6pAJffi6HHhFDvZH8inB(EZsoobOcQ8GimqjJWD6yyFO1jc4XevppOmA)hNaubvG6XdYDQhmw6AwP0hlkqZddpaFaekKhPzZ3BwYXA0RjxGU)JtHqDpm8aKtyScsnR(yraS6aGXJVZeH70XWboeUpo9hnpm8aemfRGuZMCmJPeYLhgEaYjmwbPMvFm4lxuKhTgOdzoR(4hK7u4EWV9wrNvQXWEucLhFVLCIIPegFn4mgbZy2SKXxgl9HWD6SsAp5yI7u04ua8L9WEaa9wn2EQASg99OYLQOips)rBSiawDaW4XdYDQhmw6AwP0hlcGvhamEqCNI8GXsxZskzmBEYykHzfACQmc3PE8DMiCNcF)hl8S6dTb]] )

    storeDefault( [[Elemental Primary]], 'displays', 20170110.2, [[dWt4eaGEIk7Ii12uqntIeoSkZMWTj1nvv5Akk(grPZRa7uO9kTBLSFk)urPHHKFRuptGmuKAWunCbDqf5OevDmqDobkTqvvTuOKfRqlhWdvvEkQhRk9COQjcfMkiMSQOPd5IK0vjsQll66aTrOOXjqvBwvy7G0hvq6ZqLPbL67kigPafRtrvJwaJNO4KkQClsCAe3JijlJiwlrIETavUWfs5zHMaIBqhllpycMpnhZ9czotKlBewszAaI(agyoM7fYCMix2iSKY0ae9bmW8Vler2lZNabUYLbsr5p1ievSkl14tZ5WuiWuC4d0XYC49sw4ACMY0qvnxXCmYhhOa1)LPHQAUI5FB94H6y5FNmenO2CieD2yquLLhmbt8fsJWfsz11nkYN9F5PxezVmxki4rLzI(ZCvrQZf6eZBEiq(U1JhQC80zzMO)mxvKMlR0WspZ8MhcKVB94HkJvkYdF2Oek4HHPOcQm)cqcrLreDkvuf1OKcPS66gf5Z(V80lISxMlfe8OYmr)zUQi15cDI5n)z(4afOYXtNLzI(ZCvrAUSsdl9mZB(Z8XbkqLXkf5HpBucf8WWuubvurLPHsBUI5yKpoqbY8jryGRr4Y0qPnxX8VTE8qDSmnuAZvmhJ8Xbkq9F5bftLGNkyLGn1WWWYgeLejYs1hkypt5PzvnxX8FNmenOUrQYyLI8WNnkHcwwkyykPHllpycMMpji4w6CHk)wMgQQ5kM)T1JhY8jryGRr4Y0qPnxXCihaUez(KimW1iCzAO0MRy(3wpEiZNeHbUgHlltJuLPHQAUI5yKpoqbY8jryGRr4Y8lajevUmtw4eP5kM)JSiAqDJuL5WuiWuC4dy(3wSbkKYxJWLbAeUmUgHlp2iCrL)2HdmhYUSQi15cDcZNMvT8eiABUI5)oziAqDJuLLhmbtZXGaKViYEvgR5gAWaP8eiABUI5)ilIgu3ivz5btW8P5Z9UxMZe5YgXMQmnuvZvmhYbGlrMpjcdCncxwDDJI8z)xMgGOpGbM)DHiYEvgDa4se(YmzHtKMRy(VtgIgu3iC5PzvnxX8FKfrdQBe7YqorUqMpuGnyyJuLN7DVWBohypKvJyxgRBHln)lq(gCKfUY3irqqdktdq0hWaZN7DVmNjYLnInv54PZYQIuNl0jmNgGOpGbLXCVqLNaiNW84baShszmYhhOa1)LPHsBUI5qoaCjQJL5W8LCcIChISxnkzyjLPHQAUI5qoaCjQJLNErK9Y8Vler2l89FzPCV1ngevrTa]] )

    storeDefault( [[Elemental AOE]], 'displays', 20170110.2, [[dWt(eaGEbXUifSnLuMPGkpwjMnshwLBQk11aP62KCEvr7uO9kTBr2pLFskzye8BLACKc1qjYGPA4KQdkkhvq6yiCoLeTqvvTuqLflQwoGhQQ8uultvYZruteu1ubXKvvz6qUirDvbf9mc56aTrqY3eu1Mvf2oO8rqk(mImnsP(UscJeKsRtjvJMqnEsrNujPBjWPH6EckCzfRLuiVwqPlrHuwlyda9E28YHcoGZpZHANqMZ4qMgjEvwcaRoGNMd1oHmNXHmns8QSeawDapn)70r4DY8mqGRmu0tnMZI3lHTmWql)jhHidx5WK8yoRpuku0JS4MxM1VfCIuJqVSemzZdmh(5Xbsr9FzjyYMhy(3wLFOMx(9PjwbQmhcwnnksOCOGd4qUqAKOqklNUC68R)lNTGW7K5HdtgvMXQpZLPJAsOJUU56aZYwLFOYXtnLzS6ZCz6OMe6ORBUoWSSv5hQmCdDoYtJVeiwJqqqKgikZlayDuzewnHHqrn(QqklNUC68R)lNTGW7K5HdtgvMXQpZLPJAsOJUU5)MhhifvoEQPmJvFMlth1KqhDDZ)npoqkQmCdDoYtJVeiwJqqqKgikZlayDu5IkQmVaG1rLjJtKOtzjysMhy(3wLFOMxwcMK5bMd)84aPO(V8ZcvWAqxyLecRuu4fjsqBnwKqFeOn0lRzJcLHBOZrEA8Lar4fiie0ar5qbhWX8mkMusnju5LYzGOT5bM)(0eRavnkuwcaRoGNMV6YozoJdzAuBHYmorIoMhy(BCcRavnkQSgT3QgfjuoBbH3jZ)oDeENi3)LLGjBEG5qoasdQ5Lz9zbFuCihcVtn(ATxLz9HsHIEKfB(3MUbkKYxJeLZBKOmPgjkd0irrL)26pnhYUSmDutcDuZZ0sUSemjZdmhYbqAqnVCOGd4yo8yGzbH3PYWTk0aTqkhp1uwMoQjHoQ5zAjxouWbC(z(Ql7K5moKPrTfkd1oHkNbGpQ5XdayVIYYPlNo)6)YsWKmpWCihaPbzEgvx81irz4UePX8pXZsyXjsLVCmfJEwotlzZdm)noHvGQgfvE1LDIS5S49ksnQDzihDsiZHgGnOEJcLzCIeDmpW83NMyfOQrHYsay1b808VthH3PYahcVlNbI2Mhy(BCcRavnkQSemzZdmhYbqAqMNr1fFnsug(5Xbsr9FzjyYMhy(3wLFiZZO6IVgjklbtY8aZ)2Q8dzEgvx81irzjysMhyo8ZJdKImpJQl(AKOSemzZdmh(5XbsrMNr1fFnsuotlzZdm)9PjwbQAuOOwa]] )


end
