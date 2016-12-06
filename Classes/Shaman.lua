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

            end

        end )

        addAura( 'feral_spirit', -10, 'name', 'Feral Spirit', 'duration', 15, 'feign', function ()
            local up = last_feral_spirit
            buff.feral_spirit.name = 'Feral Spirit'
            buff.feral_spirit.count = up and 1 or 0
            buff.feral_spirit.expires = up and last_feral_spirit + 15 or 0
            buff.feral_spirit.applied = up and last_feral_spirit or 0
            buff.feral_spirit.caster = 'player'
        end )

        addAura( 'alpha_wolf', -11, 'name', 'Alpha Wolf', 'duration', 8, 'feign', function ()
            local time_since_cl = now + offset - last_crash_lightning        
            local up = buff.feral_spirit.up and last_crash_lightning > buff.feral_spirit.applied
            buff.alpha_wolf.name = 'Alpha Wolf'
            buff.alpha_wolf.count = up and 1 or 0
            buff.alpha_wolf.expires = up and last_crash_lightning + 8 or 0
            buff.alpha_wolf.applied = up and last_crash_lightning or 0
            buff.alpha_wolf.caster = 'player'
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
            setPotion( 'old_war' )
            setRole( 'attack' )
        end )

        addHook( 'spend', function( amt, resource )
            if resource == 'maelstrom' and state.spec.elemental and state.talent.aftershock.enabled then
                local refund = amt * 0.25
                refund = refund - ( refund % 1 )
                gain( refund, 'maelstrom' )
            end
        end )


        ns.addToggle( 'doom_winds', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        ns.addSetting( 'doom_winds_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and Doom Winds will be shown regardless of your Doom Winds toggle.",
            width = "full"
        } )

        ns.addSetting( 'prioritize_buffs', true, {
            name = "Prioritize Buffs",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will use a modified priority list that recommends maintaining your Frostbrand and Flametongue buffs before hitting Stormstrike.  " ..
                "This deviates from the default SimulationCraft action list as of October 2016, but tends to show higher performance and maintains the good habit of keeping your " ..
                "weapon buffs active.",
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
            max = 0.5,
            step = 0.01
        } )

        ns.addMetaFunction( 'state', 'rebuff_window', function()
            return gcd + ( settings.safety_window or 0 )
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

        ns.addSetting( 'crash_lightning_maelstrom', 0, {
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
        }   )


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
        } )

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
            cooldown = PTR and 7.5 or 6,
            charges = 2,
            recharge = PTR and 7.5 or 6
        } )

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
            cooldown = 120,
        } )

        addHandler( 'earth_elemental', function ()
            summonPet( 'earth_elemental', 15 )
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
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'fire_of_the_twisting_nether', 8 )
            end
            spend( cost, 'maelstrom' )
        end )


        addAbility( 'frostbrand', {
            id = 196834,
            spend = PTR and 35 or 20,
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
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'chill_of_the_twisting_nether', 8 )
            end
            spend( cost, 'maelstrom' )
        end )


        addAbility( 'fury_of_air', {
            id = 197211,
            spend = 5,
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
            spend = 0,
            spend_type = 'mana',
            cast = 2,
            gcdType = 'spell',
            cooldown = 30
        } )

        modifyAbility( 'icefury', 'cast', function( x )
            return x * haste
        end )

        addHandler( 'icefury', function ()
            applyBuff( 'icefury', 15, 3 )
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
            cooldown = 0
        } )

        modifyAbility( 'lightning_bolt', 'id', function( x )
            if spec.elemental then return 188196 end
            return x
        end )

        class.abilities[ 188196 ] = class.abilities.lightning_bolt

        modifyAbility( 'lightning_bolt', 'spend', function( x )
            if spec.elemental then return -8 end
            if talent.overcharge.enabled then
                return min( maelstrom.current, PTR and 40 or 45 )
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
                return 9 * haste
            end
            return x
        end )

        addHandler( 'lightning_bolt', function ()
            if buff.stormkeeper.up then removeStack( 'stormkeeper' ) end 
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
            spend = -15,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            known = function() return not talent.boulderfist.enabled end
        } )

        addHandler( 'rockbiter', function ()
            if equipped.eye_of_the_twisting_nether then
                applyBuff( 'shock_of_the_twisting_nether', 8 )
            end
        end )


        addAbility( 'storm_elemental', {
            id = 192249,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300,
            known = function () return talent.storm_elemental.enabled end,
            toggle = 'cooldowns'
        } )

        addHandler( 'storm_elemental', function ()
            summonPet( 'storm_elemental', 60 )
            if talent.primal_elementalist.enabled then summonPet( 'primal_storm_elemental', 60 ) end
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
            spend = PTR and 20 or 60,
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
            known = function () return talent.totem_mastery.enabled end
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
            cooldown = PTR and 40 or 45,
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


    storeDefault( [[SimC Import: default]], 'actionLists', 20161206.1, [[d4dbxaGEQqSjKs7cOTrj2heYmPQKlJA2iMpvfhwXYGOBdvNNkANizVQ2TO9RuzuePggLACuH0PLmuQaAWkvnCO4GuLofrYXaCoQGYcPKwQuXIvYYb9qQa9uspgsRJkOQjsfatLQQjlLPlCrPsVIkOYZGsxxQAJuH65uSzIA7qO(osXxPcY0GanpLsnsQa0FrQgnr8nQItQu8zQ01GaUhe0HOQu)MWRvk5dC)x7MZIWTB9QIHrRHuoYeLipfslyVsn48vTWDWD73GJradh(D7BS80tIRDycpg(uiTbSaaG1ge4QIclmX1RErJsKM7)ua3)1U5SiC7wVQOWctCneUUegSYGHWEmH5Q3vrQW5vAQSr3iHh41nzRqNqaVMIKV2Hj8y4tH0gWcGhqBSaxPgC(QdvzB3EvcpWhNc59FTBolc3(6QIclmX1q46syquHG0e0KgALogOlhGs4HesaXGgBJeb8XNOWzezdIa22sD17Qiv486IiensVjUUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxDazOOm4pof27)A3CweUDRxPgC(QdGqGVBVdvzZC17Qiv48AtiWPttLnZ1nzRqNqaVMIKV2Hj8y4tH0gWcGhqBSaxvuyHjUU6LLbLjdohI0TNb7XqR0(ogcNbOKPiMqaXb5CweU5JpREzzqzOWel4KnWEms94ui49FTBolc3U1RkkSWexdHRlHbrfcstqtAOvAFhdHZaCj6jngkxMaKZzr4Mp(S6LLbxIEsJHYLja7XifTs77yiCgGKjBgs1yqoNfHB(4ZQxwgKmzZqQgd2JrkArfcstqtcIchJe6KYvsKv6ccz8PsZ2ieviinbnjOmdhcDdMcwbiKXNknoCUOTRExfPcNxLz4qOBWuWkUUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxDmdhYU9kMcwXJtHa3)1U5SiC7wVQOWctCDGrjpOb4qWizOtJGidY5SiCJwzgoe6gmfScqiJpvAqKlAJ2vVSm4qWizOtJGidcz8PsZ2UOTRExfPcNxrHJrcDs5kjYkDVUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxDq4yKSBVVkxjrwP7Jtz5(V2nNfHB36vQbNV6afrjYREHUMR5GZieduqePl3OJrqddV2Hj8y4tH0gWcGhqBSax3KTcDcb8Aks(QIclmX1q46syquHG0e0KgALwMHdHUbtbRaeY4tLgeHa(4tmqxoaJcNPhc6TI3gHyTL6Q3vrQW5vmIOe5Jt55(V2nNfHB36vffwyIRHW1LWGOcbPjOjn0k9QxwgCmOC2MeLb7X4Jp(ogcNb4yq5SnjkdY5SiCZhFimIzY2a22sD17Qiv486IHggUvLUx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5RwzOHHBvP7Jt5O3)1U5SiC7wVQOWctCneUUegeviinbnP5Q3vrQW51friA0L7HoVUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxTseI2U9oUh68XPCy3)1U5SiC7wVQOWctCngcNbikCmsQ0LUjeqCqoNfHB0oOrHyMoNmEXgeHqSx9UksfoVIchJe6KYvsKv6EDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV6GWXiz3EFvUsISs3D7LgqQhNcW((V2nNfHB36vffwyIRREzzWLON0yOCzcqiJpvA2gYREzz60uztqdT4dtmbuGdI2dHCgBJqeWM2bnkeZ05KXl2GieI9Q3vrQW51LON0yOCzIRBYwHoHaEnfjFTdt4XWNcPnGfapG2ybUsn48vRIEsJHYLjECkaG7)A3CweUDRxvuyHjUU6LLbxIEsJHYLjaHm(uPzBiV6LLPttLnbn(4J0OsgOlBOldh0Oe5qqeaOheGw8HjMakWbr7HqoJTrOHJOsxd4s0tAmuUmbD8HjMakWPDqJcXmDoz8InBJqKsD17Qiv486s0tAmuUmX1nzRqNqaVMIKV2Hj8y4tH0gWcGhqBSaxPgC(QvrpPXq5Ye72lnGupofaY7)A3CweUDRxvuyHjUU6LLbrHJrcDs5kjYkDbHm(uPzBiV6LLPttLnbn0oOrHyMoNmEXgeHqKx9UksfoVIchJe6KYvsKv6EDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV6GWXiz3EFvUsISs3D7LgPupofa27)A3CweUDRxvuyHjUA4iQ01aIbwcyfLJW0x9YYgAJHWzakzkIjeqCqoNfHB0U6LLbLHctSGt2aHm(uPzBiV6LLPttLnbnx9UksfoVkdfMybNSDDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV6yOWel4KTD7L2bclbScNs94uai49FTBolc3U1RkkSWexnCev6AaXalbSIYry6REzzdTREzzqzYGZHiD7zqiJpvA2gYREzz60uztqZvVRIuHZRYKbNdr62Zx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5RoMm4Cis3EE3EPDGWsaRWPupofacC)x7MZIWTB9QIclmX1bnkeZ05KXl2GieILwFhdHZauYuetiG4GColc3U6DvKkCELMkBMawBXx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5RouLntaRT4hNcWY9FTBolc3U1RkkSWexh0OqmtNtgVydIqiwA9DmeodqjtrmHaIdY5SiC7Q3vrQW5vtiG4MawBXx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5RAiG4MawBXpofGN7)A3CweUDRxvuyHjUU6LLbnHaIVGv6YqWEmx9UksfoVstLntaRT4RBYwHoHaEnfjFTdt4XWNcPnGfapG2ybUsn48vhQYMjG1w8U9sdi1Jtb4O3)1U5SiC7wVQOWctCD1lldAcbeFbR0LHG9yU6DvKkCE1eciUjG1w81nzRqNqaVMIKV2Hj8y4tH0gWcGhqBSaxPgC(QgciUjG1w8U9sdi1Jtb4WU)RDZzr42TEvrHfM4QVnCev6AaXalbSIYry6REzzdTXq4maLmfXecioiNZIWnAx9YYGYqHjwWjBGqgFQ0SnKx9YY0PPYMGMRExfPcNxLHctSGt2UUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxDmuyIfCY2JtH0((V2nNfHB36vffwyIR(2WruPRbedSeWkkhHPV6LLn0U6LLbLjdohI0TNbHm(uPzBx02vVRIuHZRYKbNdr62Zx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5RoMm4Cis3E(XPqcC)x7MZIWTB9k1GZxDOkBgr6E17Qiv48knv2mI096MSvOtiGxtrYx7WeEm8PqAdybWdOnwGhNcjY7)A3CweUDRxvuyHjUgcxxcdIkeKMGM0C17Qiv486yq5SnjkFDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV61GYzBsu(XPqI9(V2nNfHB36vffwyIR(ok0TQ09Q3vrQW5v5EOt6cz6tbVUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZxDCp05U9c5D79wWhNcjcE)x7MZIWTB9QIclmX1bnkeZ05KXl2GieI9Q3vrQW5vu4yKqNuUsISs3RBYwHoHaEnfjFTdt4XWNcPnGfapG2ybUsn48vheogj727RYvsKv6UBV0yL6XPqIa3)1U5SiC7wVsn48vhQYMjG1w8U9sJuQRExfPcNxPPYMjG1w81nzRqNqaVMIKV2Hj8y4tH0gWcGhqBSapofsl3)1U5SiC7wVsn48vneqCtaRT4D7LgPux9UksfoVAcbe3eWAl(6MSvOtiGxtrYx7WeEm8PqAdybWdOnwGhNcPN7)A3CweUDRxvuyHjUgdHZauGygIkzGUmiNZIWnAXhMycOaheThc5mqecTyF17Qiv48kPCLezLU0xcsCDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV6RYvsKv6UBVvbjECkKo69FTBolc3U1RkkSWexx9YYGsebDjt2a7XC17Qiv48kzq8qNmgjx3KTcDcb8Aks(AhMWJHpfsBalaEaTXcCLAW5R(Aq8SBVVgJKhNcPd7(V2nNfHB36vQbNV2DGHeo3TxXuBXx9UksfoVYdmKWjDdMAl(6MSvOtiGxtrYx7WeEm8PqAdybWdOnwGhNcR99FTBolc3U1RkkSWexh0OqmtNtgVydIa8XhPJHWzaIchJKkDPBcbehKZzr4gT4dtmbuGdI2dHCgicHgoIkDnGOWXiHoPCLezLU0XhMycOaxkF8rMHdHUbtbRaeY4tLgeT6LLbhcgjdDAeezqiJpvAU6DvKkCEffogj0jLRKiR096MSvOtiGxtrYx7WeEm8PqAdybWdOnwGRudoF1bHJrYU9(QCLezLU72lnck1JtHf4(V2nNfHB36vffwyIRXq4maLmfXecioiNZIWnAx9YYGYqHjwWjBGqgFQ0Sncc6Ox9UksfoVkdfMybNSDDt2k0jeWRPi5RDycpg(uiTbSa4b0glWvQbNV6yOWel4KTD7LgqQhNclY7)A3CweUDRxvuyHjUU6LLbLjdohI0TNbHm(uPzBee0rV6DvKkCEvMm4Cis3E(6MSvOtiGxtrYx7WeEm8PqAdybWdOnwGRudoF1XKbNdr62Z72lnGupofwS3)1U5SiC7wVsn48vTpBmSs3RExfPcNxn9zJHv6EDt2k0jeWRPi5RkkSWexXhMycOaheThc5mqecnCev6Aan9zJHv6shFyIjGc8RDycpg(uiTbSa4b0glWJtHfbV)RDZzr42TEvrHfM4k(Wetaf4GO9qiNbIqOHJOsxdizq8qNmgj0XhMycOa)Q3vrQW5vYG4HozmsUUjBf6ec41uK81omHhdFkK2awa8aAJf4k1GZx91G4z3EFngj72lnGupofwe4(V2nNfHB36vQbNV2rGU1QcgE17Qiv48kuGU1QcgEDt2k0jeWRPi5RDycpg(uiTbSa4b0glWJtH1Y9FTBolc3U1RudoF1XKbNdr62Z72lnsPU6DvKkCEvMm4Cis3E(6MSvOtiGxtrYx7WeEm8PqAdybWdOnwGhNcRN7)A3CweUDRxPgC(QvrpPXq5Ye72lnsPU6DvKkCEDj6jngkxM46MSvOtiGxtrYx7WeEm8PqAdybWdOnwGhpU6aWYtpjU1h)]] )

    storeDefault( [[SimC Import: precombat]], 'actionLists', 20161206.1, [[d0cEbaGEGODbkBduntuuZgPBJs7uj7LA3s2pQQHrs)wXqfvmyuLHdPdcIJrQfcrlLeTyrSCapuKQNQ6XqzDIQAIaHPcstwPMUuxuK8miCDrv2SOsFgQ(okYLjomIrJcltuojjCprkNw48avphv(lq6BaLT2q9tvKeQSns)JkybHgGK0XuELbhH)IWk(pytNppfSOdqNpFEOac2WMqAFLcviCIxzQA4AncvyA)JbeOTVpeSoMIZq9sBO(Pkscv2gP)Xac02VhCCQadBg6EyQ48HaGZ5xewjnuGHofUSbfDysa8HKe0Ob3hD6ykFf1oWi9a4xtj(kfQq4eVYu1W1GbtfH2Fryf)CMoMYTxzgQFQIKqLTr6ViSIpZboJUIcNpVZie62hssqJgCFAGZOROWbLJri0TVIAhyKEa8RPeFLcviCIxzQA4AWGPIq72TpiKCj5rBJ0Tn]] )

    storeDefault( [[Wordup's Wowhead APL]], 'actionLists', 20161206.1, [[dWtUnaGEciAtueTlqTnI0(OizMeGzJy(eq6tuKs3MOoSu7eWEf7wY(vIgLQkggj(nPwgigkbegSsYWbPdseNsvLogvDocKwiHSukyXk1Yr6HeiEk0Jb65QYePiftLIAYuz6kUij1Ziuxg11vv2ifHZtj2mLA7eOoTkFvjv9zc67us(gf6VQQA0KK5rjvNuj8ALuUgLuUhbunnLu5qeqzCuKQJpMdQU6nHDruqGwMdUEn19b10(wUA9ARuXTB5kjceciicspOtWGgyc3poaqu8s9EXkW(Giug8AYjq2ZPRaarQ4GsaNtxVyoa(yoO6Q3e2frbbAzoOi9hXXu77nbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4Gs2h5glb36pIJP23BcIG0d6eCAcxdmPl3JCogMREtyNj3F22WKUCpY5yykl3x9SoL3F22)T6kN2QmbasmhuD1Bc7IOGii9GobNMW1at6Y9iNJH5Q3e2zY9NTnmPl3JCogMYY9vpRt59NT9FRUYPTkObMW9JdaefVuVryfX(Glk3b2JMgS0fheOL5Gg0GRTVHPbLSpYnwcs1GRTVHPzcG4yoO6Q3e2frbrq6bDconHRbwvFK3OPYWC1Bc7m5(Z2g2MQFZM2LdMYY9vpRt59NT9FRUYPTkObMW9JdaefVuVryfX(Glk3b2JMgS0fhuY(i3yjOnv)MnTlxqGwMdAcQ(nBAxUmbyDXCq1vVjSlIcc0YCqtqAzE0LWpoObMW9JdaefVuVryfX(Glk3b2JMgS0fhuY(i3yjOnPL5rxc)4Gii9Gob3F22W2KwMhDj8JHPSCF1Z6uE)zB)3QRCARYeaRfZbvx9MWUikicspOtWGgyc3poaqu8s9gHve7dUOChypAAWsxCqGwMdU(RCpDjmOK9rUXsqRUY90LWmbqAmhuD1Bc7IOGii9GobdAGjC)4aarXl1BewrSp4IYDG9OPblDXbbAzoOKhixUUa5Gs2h5glb7hixUUa5mbWymhuD1Bc7IOGii9Gob3F22W2KwMhDj8JH)GAYFeytt4AGv1h5nAQmmx9MWobQaD)zBdBt1Vzt7Yb)b93Ggyc3poaqu8s9gHve7dUOChypAAWsxCqGwMdAA0A5LRw)vUxqj7JCJLGoTw(Vvx5EzcGPhZbvx9MWUikicspOtWGgyc3poaqu8s9gHve7dUOChypAAWsxCqGwMdAcM2KLRqOh9MGs2h5glbTzAt()GE0BYeabnMdQU6nHDruqeKEqNGcS5ax7kHbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4GaTmh0eFullxPTxUsYrdkzFKBSe0(JA5V2(FF0mbWReZbvx9MWUikicspOtWgCobZ)5ILp(zkbU4Gs2h5glbbP9t1FYju1uxjm4IYDG9OPblDXbnWeUFCaGO4L6ncRi2heOL5GccTFQwUsaNqvtDLWLR(rIw9VzcG3hZbvx9MWUikiqlZbXrtLFd9wJdAGjC)4aarXl1BewrSp4IYDG9OPblDXbLSpYnwc(gnv(n0BnoicspOtWmbWdjMdQU6nHDruqGwMdU(RCVHERXbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4Gs2h5glbT6k3BO3ACqeKEqNGzcGxCmhuD1Bc7IOGii9GobBW5em)Nlw(4NPe4qckzFKBSeeK2pv)jNqvtDLWGlk3b2JMgS0fh0at4(XbaIIxQ3iSIyFqGwMdki0(PA5kbCcvn1vcxU6hbHWTG5FZea)6I5GQREtyxefebPh0jiOwtCARk4T(J4yQ99gyqvnvi)(BtBW50vtmLh2O1cAGjC)4aarXl1BewrSp4IYDG9OPblDXbbAzoOi9hXXu77nlx9J)3Gs2h5glb36pIJP23BYeaV1I5GQREtyxefebPh0j40eUgyv9rEJMkdZvVjSZK7pBByBQ(nBAxoykl3x9S(6GTwqdmH7hhaikEPEJWkI9bxuUdShnnyPloiqlZbnbv)MnTl3Yv)4)nOK9rUXsqBQ(nBAxUmbWlnMdQU6nHDruqeKEqNG7pBByBslZJUe(XWuwUV6z91bBTGgyc3poaqu8s9gHve7dUOChypAAWsxCqGwMdAcslZJUe(Xlx9J)3Gs2h5glbTjTmp6s4hNjaEJXCq1vVjSlIcIG0d6eCAcxdSwWmfuvtfYWC1Bc7mPCZK3q1YWGFukxJPeuLGgyc3poaqu8s9gHve7dUOChypAAWsxCqGwMdkGtOQPUs4YvI0KjOK9rUXsqYju1uxj8)wtMmbWB6XCq1vVjSlIcIG0d6eC)zBdRsp)v1Ld(dAqdmH7hhaikEPEJWkI9bxuUdShnnyPloiqlZbfql4E5kb0pvbLSpYnwcsAb3)j9tvMa4f0yoO6Q3e2frbrq6bDcg0at4(XbaIIxQ3iSIyFWfL7a7rtdw6Idc0YCq1nDuX1Yvi0BnoOK9rUXsqUPJkU()GERXzcaeLyoO6Q3e2frbrq6bDconHRbgK2pvxj8)B0uzyU6nHDMuUzYBOAzyWpkLRXuMUsqdmH7hhaikEPEJWkI9bxuUdShnnyPloiqlZbfeA)uTCLaoHQM6kHbLSpYnwccs7NQ)KtOQPUsyMaaXhZbvx9MWUikicspOtq5MjVHQLHb)OuUgt59kbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4GaTmhe)khtVsyqj7JCJLGVVYX0ReMjaqGeZbvx9MWUikicspOtq5MjVHQLHb)OuUgtjOkbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4GaTmhuaTG7LReq)uTC1p(FdkzFKBSeK0cU)t6NQmbaI4yoO6Q3e2frbrq6bDcg0at4(XbaIIxQ3iSIyFWfL7a7rtdw6Idc0YCqr6pIJP23BwU6hi)guY(i3yj4w)rCm1(EtMaazDXCq1vVjSlIcc0YCqdAW123W0LR(X)BqdmH7hhaikEPEJWkI9bxuUdShnnyPloOK9rUXsqQgCT9nmnicspOtWmbaI1I5GQREtyxefebPh0j40eUg4T(J4yQ99gyU6nHDbnWeUFCaGO4L6ncRi2hCr5oWE00GLU4GaTmh0eKwMhDj8JxU6hi)guY(i3yjOnPL5rxc)4mzcAAy7(JmruMea]] )

    storeDefault( [[Wowhead Elemental 1-3]], 'actionLists', 20161206.1, [[d0ZUiaGEQqQnbQ0UiyBKk7JkyMQs0Srz(uPOBsLsEmj3wuhwyNGSxPDdSFc1OavmmIACuPuNJkuoVQyWKsdNiDqr4uQs1XOQJtLclKkAPIOfJklNspKke9uOLPQ65k1PvzQKQMmQA6kUirCzKNrixxvzJuPQdPkLAZGY2bv9nrYxvLsMgvO67QsXFvsZtvcJwj(Si1jPsUfviCnQu5EQsALuHKFtXRjfxF1xuci4yeFDwekYuX3Y8Mfk4fRvcJYeycMyTEhHOIjjgfBQq)YEDEzzrc(IOusDb7C0XCgqH(19xmHAodyx9fYx9fLacogXxNfrL9Kof5(GbtWsBdiakADmdLfSuooW(fE5IjjgfBQq)YED(ucYI8fDb4pvmgBrGbqfHImvuVzOSyTUvShY(umb3XU5P4ygkVMJ9q2Nof6V6lkbeCmIVolcfzQO7zrMeRfxmknftsmk2uH(L968PeKf5l6cWFQym2IadGkMG7y38ueglY06EXO0uev2t6u8TNtP5aP7uirvFrjGGJr81zrOitfLe2zrSwCXO0umjXOytf6x2RZNsqwKVOla)PIXylcmaQycUJDZtrkSZY6EXO0uev2t6umheBpwtwq9zTeyC4vh7VtHC8QVOeqWXi(YvekYurxkc2N9PysIrXMk0VSxNpLGSiFrxa(tfJXweyauXeCh7MNINIG9zFkIk7jDkobJaJWPiyF2hbceCmIVtHCx1xuci4yeFDwev2t6uuzmmEZBacSa(yL7ZUhb1syttBhKHlpX9bdMamwKP19IrPrWs54aBhc1CgGalGpw5(S7rqf7zDUmvmjXOytf6x2RZNsqwKVOla)PIXylcmaQiuKPIVmGpeR15NDpftWDSBEkYc4JvUp7E6uiDvFrjGGJr81zruzpPtXIjjgfBQq)YED(ucYI8fDb4pvmgBrGbqfHImvucJYeycMyTozXEkMG7y38uKyuMatWw5yXE6uOuvFrjGGJr81zruzpPtXIj4o2npfzNB8D8R5iDowhZq5IUa8NkgJTiWaOIjjgfBQq)YED(ucYI8fHImv8LNB8D8I16wr6CiwREZq5ofYTR(IsabhJ4RZIOYEsNICFWGjCkc2N9r4tkCHtoi2ESMSG6ZAjW4WR)YUPBMnWFG0VxmjXOytf6x2RZNsqwKVOla)PIXylcmaQiuKPIU3A2JyT4IrPPycUJDZtrywZEw3lgLMofYXQ(IsabhJ4RZIOYEsNI5Gy7XAYcQpRLaJdV(ld3qnh80kVzeGXImTUxmknViuZbpTsakF0gUHAo4PvEZiaJfzADVyuAEHOIj4o2npfHXImTUxmknfDb4pvmgBr1JIrfHImv09SitI1IlgLgXAHJdVxmjXOytf6x2RZNsqwKVtH8YvFrjGGJr81zruzpPtrEI7dgmbySitR7fJsJGLYXb2VWll4o4MdIThRjlO(Swcmo86VCXKeJInvOFzVoFkbzr(IUa8NkgJTiWaOIqrMk6EwKjXAXfJsJyTWX)EXeCh7MNIWyrMw3lgLMofY7R(IsabhJ4RZIOYEsNI5Gy7XAYcQpRLaJdV626kMKyuSPc9l715tjilYx0fG)uXySfbgavekYurjHDweRfxmknI1ch)7ftWDSBEksHDww3lgLMofY)x9fLacogXxNfrL9Kofht60ms4BtRNIG9zFkMKyuSPc9l715tjilYx0fG)uXySfbgavekYurxkc2N9rSw44FVycUJDZtXtrW(SpDkKxu1xuci4yeFDwev2t6uuzmmEZBacXwra(aOiblLJdSDW7UIjjgfBQq)YED(ucYI8fDb4pvmgBrGbqfHImvehJnRHiPKTycUJDZtX9ySznejLSDkK3XR(IsabhJ4RZIOYEsNIHAo4Pvcq5J2V6lMKyuSPc9l715tjilYx0fG)uXySfbgavekYuXxEPxgWbslwRtdBkMG7y38uKDPxgWbsVYzytNc5Dx1xuci4yeFDwekYurh5sCaXAF5LEzahiDXKeJInvOFzVoFkbzr(IUa8NkgJTiWaOIOYEsNIHAo4Pvcq5J2o4f7OkMG7y38uuTehyLDPxgWbs3PtruzpPtXoT]] )

    storeDefault( [[Wowhead Elemental 4+]], 'actionLists', 20161206.1, [[dedXcaGELQ0UaLTHKMji0SP0nbb3wk7uj7LSBG9Jsnmu8BrgmQy4svheLCmQCCqLfIQSuuvlMclNQEOsfEQQLPuEofnvPYKrQPlCrq6vkvYLHUUOyZkv1Jr4Ws(kOQMgOkFxPIEgs8xrvJgrDAfNuuzEkvQRPufNhr(MO0NrLEniA5uNouqzyrAXtFvnuh(PDsglA2CGAXgcIYYMd82LoF0ILjQ1gJJQJHHcmN(7rIPSZERysaT2OUPZIiMeWuDA5uNouqzyrAXt)e(Pp0nYS)(W8OzcuacmFKcSbZJTAaM72XOZYyStqspsb2Y3kZa9K0ZbOhIksEDqcG6RQH6DPaBS5aHYmqpjD(OfltuRnghvxwymuCk0AtD6qbLHfPfp9t4N(qxNLXyNGKUDGlZqNVvCBv(ifytphGEiQi51bjaQZhTyzIATX4O6YcJHItFvnuhIdCzgA2CGqXTvS50LcSPqlkQthkOmSiT4PVQgQdT8bz4YuqI68rlwMOwBmoQUSWyO40ZbOhIksEDqcG6Smg7eK0XYhKHltbjQFc)0h6k0cEQthkOmSiT4PVQgQ)i5BqIyp615JwSmrT2yCuDzHXqXPNdqpevK86Gea1zzm2jiPBgjFdse7rV(j8tFORqR9OoDOGYWI0IN(QAO(oixdGnhioCjhGbWvNpAXYe1AJXr1LfgdfNEoa9qurYRdsauNLXyNGKob5Aa5TdxYbyaC1pHF6dDfk0pHF6dDfsa]] )

    storeDefault( [[Wowhead Elemental Cooldowns]], 'actionLists', 20161206.1, [[d8YUcaGEfsTluLTHcZeHQzdCtfk3Ms7us7LSBP2psmmu63cnye1WrkhejDmbhhHyHOQwkkAXuy5k1dLO4PQwMcEoQmvemzLmDrxucpdrUocPnkrPnRq0xvizAke(Ucvxg6XkA0su1HP6KuuNg01KOY5rQ(gf5VsKpJqzfeb9I2na4s81RUf1hvC8YJ(Ic5caAXoDafYLjgbR44nNoteGohQ6aBGrGLLeVG(NBiTuxN6mHXMteunic6fTBaWL4RxDlQxw4gPqUaGwSthOZebOZHQoWgyemXJLuq3CVGtpJB9o2O(NBiTuxNQbeat66JeUXsiaTyNoqPQdIGEr7gaCj(6FUH0sDDMiaDou1b2aJGjESKc6M7fC6zCR3Xg1RUf1Fg3wkKlaOf70b6unGaysxNlJBBjeGwSthOuvsIGEr7gaCj(6v3I6u5MyV8EI6mra6COQdSbgbt8yjf0n3l40Z4wVJnQ)5gsl11PAabWKUUZnXE59evQ6ieb9I2na4s81RUf1laOf70buipMZL4MUoteGohQ6aBGrWepwsbDZ9co9mU17yJ6FUH0sDDQgqamPRJa0ID6GswNlXnDLQworqVODdaUeF9QBrDIdjcrHlkKhZjM1PqMqmrRoteGohQ6aBGrWepwsbDZ9co9mU17yJ6FUH0sDDQgqamPRdGeHOWvjRtmRxkJjAvQu)0Wj0bWr7jm2QoWyqPe]] )


    storeDefault( [[Enhancement Primary]], 'displays', 20161206.1, [[dWd8eaGEsj7cb12iHMjGKdRQzRWTj6MaX1qq(MIuNxrStH2R0Uf1(P6NiPmmsACiPYZrIHsWGPmCK6GQOJsICmqohGulebwkI0IjvlxWdvPEkQhROwhGyIiIPQsMmqA6qUiaxLuQ6YkDDqTrKKLrk2Sk02rOpQiXNbQPrc(UIKgjPu8ma1OruJNe1jvb3IqNgQ7HKQ(TiRLuQ8AsP0fQxLPgXnm(jvVSsWl8cQBuLYi3ySwBJqAkleWYpmXnQszKBmwRTrinLfcy5hM429tJWPSBNWHVmJsbPEaNbVHYHDu(gq8caPL1EkRBm9ogunEkKREzM(NXzWnsOYceb4MOBKShF4bQeuwGia3eD7oj1Fu1ldYRmwclD7cl3gbwTSsWl8sPxnc1RYaYV(ybTeu(CgHtz3akmfuzglVD7GKofqaXn6WoNK6pQC8LBzglVD7GKofqaXn6WoNK6pQmP7yFkBJAuHueAAcRcmuzEoGPrLry5s9Qf1OMEvgq(1hlOLGYNZiCk7gqHPGkZy5TBhK0PaciUb6E8HhOYXxULzS82Tds6uabe3aDp(Wduzs3X(u2g1OcPi00ewfyOIkQSarb3eDJK94dpqUDoOj)ncvwGOGBIUDNK6pQ6Lfik4MOBKShF4bQeuEsPsK6ubAnkOQie00aRQrZ0Q9OOceQSYnQwM0DSpLTrnQqkcbbSkHHkRe8cVUDoWGZYnJkpxwGia3eD7oj1FKBNdAYFJqLfik4MOBxFa8IC7Cqt(BeQSarb3eD7oj1FKBNdAYFJqLpPga3eDdKxzSew2OA5ZzeoLD7(Pr4uMsjOSaraUj621haVOQx(orpXTRuzazYFEELBg5gJZGhR41haVOYm9ogunEkKD7onsHEv(BeQSEJqLb3iu5qJqfvMP3z8pWA9iCk3OgfbUSarb3eD76dGxu1lRe8cVUrcoSZiCkxM0dtrBUkhF5wgqM8NNx5MrUjeWYpmPSsWl8cQBhMtz3ySwBJkOwMQugv(mG)HBXpestTmG8RpwqlbLfcy5hM42H5u2ngR12OcQLj9ZGx3UjVZAlodU8RJhy0KYNudGBIUbcoJLWYgbU8H5uMIBm50uZnQq5RFSzKBtjKGPBuTmJZGhRBIUbYRmwclBeQSqal)We3UFAeoLltj8iCQ8jmk5MOBGGZyjSSr1Yceb4MOBxFa8IC7Cqt(BeQmj7XhEGkbLpHrj3eDdKxzSew2OAzgNbpw3eDdeCglHLnQww7sjzJqeQSaraUj6gj7XhEGC7Cqt(BeQmphW0OYf1c]] )

    storeDefault( [[Enhancement AOE]], 'displays', 20161206.1, [[dWJ0eaGEsODbs12iuntffDyGzlYLv6MQuESO62eDEvQ2PG9kTBH2pLFQOYWiLFRWPrmucgmvdhPoOOCusfhdjNdKIfcswkOYIvrlxv9qvYtrTmc55qvteumvqmzvW0HCrf5QGu6zKORRkBeu13ivQ2mPQTdfFurjFgQmncLVROuJurHwNIQgnuA8KGtQcDls6AGs3trbJJujwlPs51KkPlvHuwN3(2dMd)iImNjkUnqjQSagbZvnhc4JBr9SSWNib)7MFbOrKr08S3huU8FtLVMcqMGRm0IFnNP3uc(eap2EwwaZK5QMdb8XTOEwwaZK5QMdZQh8sOcvzbmtMRA(1qEcq9S8nGce5tAoeICBqPwzDE7BXxinqviLNIGZ0EOqvolhrgrZNjbpQmtKxMFusp(O5nN(V5d5javoaKBzMiVm)OKE8rZBo9FZhYtaQmCBAb43gePrbRM4qxKiQYC(NqJkJiYDg0kQbrfs5Pi4mThkuLZYrKr08zsWJkZe5L5hL0JpAEZpS6bVeQCai3YmrEz(rj94JM38dREWlHkd3Mwa(TbrAuWQjo0fjIQOIkZ5FcnQmEsexAllGrWCvZVgYtaQNLfWiyUQ5WS6bVeQqv(EHxvCy1GgknOrPURuPMy6IsTQxvmylNn3K5QMFdOar(KnOvgUnTa8BdI0OeNIsPg0PkRZBFR5zjcUOCJOY5LfWmzUQ5xd5jazEwIglObQYcyemx1CiGpUfzEwIglObQYmjIlTMRA(nsKiFYguwwaJG5QMdZQh8siZZs0ybnqvwaZK5QMdZQh8siZZs0ybnqvw3gdzduWwwaJG5QMFnKNaK5zjASGgOkZ0BkbFcGhR5xJ04xiLbnqv(3avzCnqv(SbQIkFnOVBoKr5PiwqmFLBezE2CtLHz1dEjuHQSoV9TMdd5V5iYiwgUJZAgHuo7HgMRA(nsKiFYguwwN3(2dMFmFenNjkUniMwzbmtMRAoeWh3ImplrJf0av5Pi4mThkuLZEOH5QMFdOar(KnOvw4tKG)DZVa0iYiw(WQh8sOYzZnzUQ53irI8jBqzzMeXLwZvn)gqbI8jBqRmeqAJiZN1F8OBqR8X8reV5m2XSJniwz4arCR5xy3CDLeXvgCsse09Ym9MtajIIaezeBqK4kld)iIkN9jGK5bW)pMD5aqULNIybX8vUrK5zZnvw4tKG)DZpMpIMZef3getRSWNib)7Md)iImNjkUnqjQmtdYjrCnaB5SCezen)cqJiJi(cvzfAqROw]] )

    storeDefault( [[Elemental Primary]], 'displays', 20161206.1, [[dWJyfaGEQk2fvjBJQu7deQzsvWSrCyvUjiAzsHBlPRrvO2Pe7vz3KA)I(PQunms8BIELQKAOeAWcdxQCqvXrPQQJb0NbvleKAPeWIvvwouEib9uupwQ65sPjsvLPcktgqthYfPsxvvI8msQRdvBKQsFNKSzqW2b4JQsYxjqtdKmpvj0ivLG)ccz0QQgpvrNuvk3IkonsNxk6YuwRQe1RPkKh4Gn(Dagg5AUVX(JB4gWm8vQrzWuFSvaBmweJwpSMz4RuJYGP(yRa2ySigTEynZq41HOsDgp4y34XVuRLb3zeIVKR9FFJ5URNQHVIhpweGBgoz4NbHdNGg0Jfb4MHtgcL1VdTVXqEEsR41mGrR2kQvg7pUHBTd2kGd2yx99rmGd6Xp9iQuNHhOTOXckv9BhWmCjw10OJKHqPKauQs3oUCvBSGsv)2bmdxIvnn6iziukjaLQ0TJfWi21AR0qb0Bqff1EboM7XODOXijC4eZREPKauQs3o0kngSXU67Jyah0JF6ruPodpqBrJfuQ63oGz4sSQPrhjdqh1Jlx1glOu1VDaZWLyvtJosgGoQhlGrSR1wPHcO3GkkQ9cCm3Jr7qJVEefGbrM2QuR9fHAOvupyJD13hXaoOh)0JOsDgEG2IglOu1VDaZWLyvtJosgq96XLRAJfuQ63oGz4sSQPrhjdOE9ybmIDT2knua9gurrTxGJ5EmAhA81JOamiY0wLATqS6HgASiaXmCYWpdchobLXdP7)wbCSiaXmCYqOS(DO9nweGygoz4NbHdNGg0JBUItd1kJFE3ndNmG88KwXRROmwaJyxRTsdfqVbvuu7f4y)XnClJhcfUUAA04(XIaCZWjdHY63HY4H09FRaoweGygoza7WGBOmEiD)3kGJfbiMHtgcL1VdLXdP7)wbCSNROmweGBgoz4NbHdNGY4H09FRaoM7XODOXJ5oJq8LCT)ziusKyd24BfWXyRaog(kGJ)wbCOXcLDnZaMCSlXQMgDKmEE3D8dosMHtgqEEsR41vug7pUHBz4hfZ6ruPESaV9Qxa2yMQHtSmCYasQMwXRROm2FCd3aMXB9sDgm1hBfOug)GJKz4KbKunTIxxrzSR((igWb9yraUz4KbSddUHY4H09FRaoweJwpSMzi86quPEm6WGBO2XpV7MHtgqs10kEDfOgZunCILHtgqEEsR41vahd7iMgLXRWK4DROm(TEPUnd(xQsVcuJf40WTme(B9EevdF89rjuuZXIy06H1mJ36L6myQp2kqPm2xPgn(bJEKmkhgMu14YvTXUeRAA0rYqeJwpSMJfbiMHtgWom4gAFJ5oRNEeQphIk1R0W7gJfb4MHtgWom4gAFJF6ruPodHxhIk1Td6XVSuwxrTYqBa]] )

    storeDefault( [[Elemental AOE]], 'displays', 20161206.1, [[dWJ8eaGEsr7sQIxlvs7tQiMPujMnKhlLUPQQoSk3wsxtQu2Pq7vz3KSFQ(jPKHjr)gvxw0qrPbtz4s4GsXrjL6yO4Vsf0cHclLuXIvLwoOEiu5Peltv0ZvvMiu0ubQjdvnDexuqVsQu9mOKRdYgHs9zaTzsL2oq(Our9vPknnvv(oPQrkviBtQQgnaJNu4Ksv5wcCAKoVQWvLkuRvQinoPc8yg4jAbkHr3J9orBOekX7g2CfXnHQzUiZZjSW06b)WnS5kIBcvZCrMNtyHP1d(HB4UccLRCRbc(MGn6QPBcaEBxN0XFPBsrIqyJUpa7DIuCTufWf72ewqHUf4gMPUheImmMWck0Ta3WXRVhzVt(FAqRqv3atR5IyvorBOek)g4fzg4jHQ7fL4hgtAAjuUYTUq)it6LRhqE4DleL1uroKB44CeEUE13K4vZj9Y1dip8UfIYAQihYnCCocpxV6BIojkVVCXNLm9ZuwIvpmtKwyAbzcHdeik7PLZr456vFJS4ZbEsO6Erj(HXKMwcLRCRl0pYKE56bKhE3crznvKd52VUpjE1CsVC9aYdVBHOSMkYHC7x3NOtIY7lx8zjt)mLLy1dZePfMwqMCTekOSdtvwP5xNG1iJmrAHPfKjFufquoHfeRBbUHJxFpYENWcI1Ta3Wm19GqKHXKhlgW0bDBIglworNeL3xU4ZsM(zklXQhMjAdLqPBnikqvnvKjTtAGiC3cC7)PbTcvxSCclmTEWpCRVwUYnHQzU4VYjcvbeLUf42FQIwHQl(BsNY51fXQCstlHYvUH7kiuU6BymHfuOBbUb(GbMK9obhV4HBG5tcrznvKd5wJwHtKIeHWgDFaCdhhXHh4j3ImtExKzcWfzMaViZitKISLEiQMhHYvl(S)NtybX6wGBGpyGjzVt0gkHs3WKcNTekxnrN(6ChbEs8Q5Kquwtf5qU1Ov4eTHsOeVB91YvUjunZf)vobBUImPbMEi3Ihmmx)Kq19Is8dJjSGyDlWnWhmWK4wdQaWTiZeDofW0nCaY2UsvaNCVueL8ysJwHUf42FQIwHQl(BsFTC1NBcaUE1I)Ma(qPI4wNH5qflworOkGO0Ta3(FAqRq1flNWctRh8d3WDfekxnb(iu(Kgic3Ta3(tv0kuDXFtybf6wGBGpyGjXTgubGBrMjyM6EqiYENWck0Ta3WXRVhXTgubGBrMjSGyDlWnC867rCRbva4wKzcliw3cCdZu3dcrCRbva4wKzclOq3cCdZu3dcrCRbva4wKzsJwHUf42)tdAfQUy5iB]] )


end
