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


        -- Player Buffs.
        addAura( 'ascendance', 114051 )
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


        -- Fake Buffs.
        registerCustomVariable( 'last_feral_spirit', 0 )
        registerCustomVariable( 'last_crash_lightning', 0 )
        registerCustomVariable( 'last_rainfall', 0 )

        RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'feral_spirit' ].name then
                state.last_feral_spirit = GetTime()
            
            elseif spell == class.abilities[ 'crash_lightning' ].name then
                state.last_crash_lightning = GetTime()

            elseif spell == class.abilities[ 'rainfall' ].name then
                state.last_rainfall = GetTime()

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

        ns.addHook( 'reset_postcast', function( x )
            state.feral_spirit.cast_time = nil 
            return x
        end )

        -- Pick an instant cast ability for checking the GCD.
        -- setGCD( 'global_cooldown' )

        -- Gear Sets
        addGearSet( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
        addGearSet( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
        addGearSet( 'doomhammer', 128819 )
        addGearSet( 'uncertain_reminder', 143732 )


        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( 'attack' )
        end )


        ns.addToggle( 'doom_winds', true, 'Doom Winds', 'Set a keybinding to toggle Doom Winds on/off in your priority lists.' )

        ns.addSetting( 'doom_winds_cooldown', true, {
            name = "Doom Winds: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for Doom Winds will be overriden and Doom Winds will be shown regardless of your Doom Winds toggle.",
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

        addHandler( 'ascendance', function ()
            applyBuff( 'ascendance', 15 )
            setCooldown( 'stormstrike', 0 )
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
        end )

        modifyAbility( 'boulderfist', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'boulderfist', 'recharge', function( x )
            return x * haste
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
            if active_enemies > 2 then
                applyBuff( 'crash_lightning', 10 )
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
        end )


        addAbility( 'lightning_bolt', {
            id = 187837,
            spend = 0,
            spend_type = 'maelstrom',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0
        } )

        modifyAbility( 'lightning_bolt', 'spend', function( x )
            if talent.overcharge.enabled then
                return min( maelstrom.current, PTR and 40 or 45 )
            end
            return x
        end )

        modifyAbility( 'lightning_bolt', 'cooldown', function( x )
            if talent.overcharge.enabled then
                return 9 * haste
            end
            return x
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
        end )

    end

    storeDefault( 'SimC Import: default', 'actionLists', 20161101.1, [[d0JxwaGEsr1MiLSlG2gLyFakZKkkZgX8buDzuhwQBdLLbHDIK9QA3I2pGmkQidJsnoaeNNkmusryWa0WHkhKk1PiL6yk5CKIOfsjTufyXk1Yb9qsr6PepgsRdajnraKAQuvnzfnDHlsv50sEgu11vOnsfvpNIntQ2oePVtk8vsrzAqu18Gigjas8xKYOrQ(gvYjvqFMQCnau3dIYHGOYVj51aWFD)x8L9MWZB9IGJrRMuAEhLkpfcl4Vq1y8fPW0uGaCigofmaOceGtwVhjXLbmHBdFke2lll7LfW1fbfw4IlxCJgLkn3)Pw3)fFzVj88wViOWcxCjuEEegSYGHWrCH5I7DrQWXfnQCsZqNB4LH5Sq7qbVKQKVmGjCB4tHWEzz5c0g)6cvJXx0SkNabOqNB4JtH4(V4l7nHNFFrqHfU4sO88imiQsrMknsJwofn0Jdq6Ctc6G4qdKGaGboWJcJbMniaBBR9f37IuHJlBIsnjJM4YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lauyOQmypof(7)IVS3eEERxOAm(caTsHbeGAwLtZf37IuHJltLcJMgvonxgMZcTdf8sQs(YaMWTHpfc7LLLlqB8RlckSWfx2J66G6KgJdv6nYGJ40YjKlAcNbi9UiMqbXa5S3eEcCGVh11b1HktSHDobhXP9JtH83)fFzVj88wViOWcxCjuEEegevPitLgP5I7DrQWXfDg2eAgCfSIldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJV4Cg2eGauWvWkECka((V4l7nHN36fbfw4Ilnmk9gnaBco6nnnueDqo7nHNAPZWMqZGRGvaczSUsdW8qNATh11bBco6nnnueDqiJ1vAqIh68I7DrQWXfuyBOtJuE0JSsVldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJVOPW2qhiaDw5rpYk9ECkl3)fFzVj88wVq1y8fnHkkvEXn0ZCjBmgz4GkIk94jnCkny4LbmHBdFke2lllxG24xxgMZcTdf8sQs(IGclCXLq55ryquLImvAKgTCsNHnHMbxbRaeYyDLgGbWah4rd94amkmMwOOnlgjidVT2xCVlsfoUGtfLkFCkx3)fFzVj88wViOWcxCjuEEegevPitLgPrlN2J66GTbLZzNOm4ioGdCKlAcNbyBq5C2jkdYzVj8e4aNWiLjizzBR9f37IuHJlBgAyiaQ07YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lwzOHHaOsVhNcGC)x8L9MWZB9IGclCXLq55ryquLImvAKMlU3fPchx2eLAstFe64YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lwjk1eiaD(i0XJtPjV)l(YEt45TErqHfU4s0eodquyBOxPhntOGyGC2Bcp1QrJcPmnozSInadz4V4ExKkCCbf2g60iLh9iR07YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lAkSn0bcqNvE0JSspGa0PL2po1Y((V4l7nHN36fbfw4Il7rDDWTAKmzOEzcqiJ1vAqcK3J6600OYPsdTWAMycOcdeDec5mqcYayBTA0OqktJtgRydWqg(lU3fPchx2QrYKH6LjUmmNfAhk4LuL8LbmHBdFke2lllxG24xxOAm(Iv1izYq9Yepo1AD)x8L9MWZB9IGclCXL9OUo4wnsMmuVmbiKX6knibY7rDDAAu5uPbWbUtO0BOhBOPdB0Ouzta2c0faRfwZetavyGOJqiNbsqMHJOspd4wnsMmuVmbnSMjMaQW0QrJcPmnozSInibzi0(I7DrQWXLTAKmzOEzIldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJVyvnsMmuVmbqa60s7hNAH4(V4l7nHN36fbfw4Il7rDDquyBOtJuE0JSspqiJ1vAqcK3J6600OYPsdTA0OqktJtgRydWqgIlU3fPchxqHTHons5rpYk9UmmNfAhk4LuL8LbmHBdFke2lllxG24xxOAm(IMcBdDGa0zLh9iR0diaDcH2po1c)9FXx2BcpV1lckSWfxmCev6zaXblfSIsZzA7rDDJwrt4maP3fXekigiN9MWtT2J66G6qLj2WoNGqgRR0GeiVh11PPrLtLgxCVlsfoUOdvMyd7CEzyol0ouWlPk5ldyc3g(uiSxwwUaTXVUq1y8fNdvMyd7CceGoPjGLcwHdTFCQfYF)x8L9MWZB9IGclCXfdhrLEgqCWsbRO0CM2Eux3O1EuxhuN0yCOsVrgeYyDLgKa59OUonnQCQ04I7DrQWXfDsJXHk9g5ldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJV4CsJXHk9gzGa0jnbSuWkCO9JtTa47)IVS3eEERxeuyHlU0OrHuMgNmwXgGHm8AHCrt4maP3fXekigiN9MWZlU3fPchx0OYPjGfa4ldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJVOzvonbSaa)4ull3)fFzVj88wViOWcxCPrJcPmnozSInadz41c5IMWzasVlIjuqmqo7nHNxCVlsfoUycfeZeWca8LH5Sq7qbVKQKVmGjCB4tHWEzz5c0g)6cvJXxKqbXmbSaa)4ulx3)fFzVj88wViOWcxCzpQRdAcfeBdR0JHGJ4U4ExKkCCrJkNMawaGVmmNfAhk4LuL8LbmHBdFke2lllxG24xxOAm(IMv50eWcamqa60s7hNAbqU)l(YEt45TErqHfU4YEuxh0eki2gwPhdbhXDX9Uiv44IjuqmtalaWxgMZcTdf8sQs(YaMWTHpfc7LLLlqB8RlungFrcfeZeWcamqa60s7hNAPjV)l(YEt45TErqHfU4cYz4iQ0ZaIdwkyfLMZ02J66gTIMWzasVlIjuqmqo7nHNATh11b1HktSHDobHmwxPbjqEpQRttJkNknU4ExKkCCrhQmXg258YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lohQmXg258XPqyF)x8L9MWZB9IGclCXfKZWruPNbehSuWkknNPTh11nATh11b1jnghQ0BKbHmwxPbjEOZlU3fPchx0jnghQ0BKVmmNfAhk4LuL8LbmHBdFke2lllxG24xxOAm(IZjnghQ0BKFCkeR7)IVS3eEERxOAm(IMv50OsVlU3fPchx0OYPrLExgMZcTdf8sQs(YaMWTHpfc7LLLlqB8RhNcbI7)IVS3eEERxeuyHlUekppcdIQuKPsJ0CX9Uiv44sBq5C2jkFzyol0ouWlPk5ldyc3g(uiSxwwUaTXVUq1y8f3guoNDIYpofc83)fFzVj88wViOWcxCb5Icfav6DX9Uiv44I(i0bnLoTUGxgMZcTdf8sQs(YaMWTHpfc7LLLlqB8RlungFX5JqhabOshiaDxWhNcbYF)x8L9MWZB9IGclCXLgnkKY04KXk2amKH)I7DrQWXfuyBOtJuE0JSsVldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJVOPW2qhiaDw5rpYk9acqNWR9JtHaGV)l(YEt45TEHQX4lAwLttalaWabOti0(I7DrQWXfnQCAcyba(YWCwODOGxsvYxgWeUn8PqyVSSCbAJF94uiSC)x8L9MWZB9cvJXxKqbXmbSaadeGoHq7lU3fPchxmHcIzcyba(YWCwODOGxsvYxgWeUn8PqyVSSCbAJF94uiCD)x8L9MWZB9IGclCXLOjCgGkKYqu6n0Jb5S3eEQfwZetavyGOJqiNbWqMf7lU3fPchxiLh9iR0J2wrIldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJV4SYJEKv6beGwvK4XPqaqU)l(YEt45TErqHfU4YEuxhKUkOrVZj4iUlU3fPchxinsBAK2q)YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4loRrAdeGoRn0FCkeAY7)IVS3eEERxOAm(IVgg05eiafCfa4lU3fPchx4gg05KMbxba(YWCwODOGxsvYxgWeUn8PqyVSSCbAJF94u4TV)l(YEt45TErqHfU4sJgfszACYyfBa2c4a3POjCgGOW2qVspAMqbXa5S3eEQfwZetavyGOJqiNbWqMHJOspdikSn0Prkp6rwPhnSMjMaQW0g4axNHnHMbxbRaeYyDLgGTh11bBco6nnnueDqiJ1vAU4ExKkCCbf2g60iLh9iR07YWCwODOGxsvYxgWeUn8PqyVSSCbAJFDHQX4lAkSn0bcqNvE0JSspGa0jKx7hNc)6(V4l7nHN36fbfw4Ilrt4maP3fXekigiN9MWtT2J66G6qLj2WoNGqgRR0GeKheGCX9Uiv44IouzInSZ5LH5Sq7qbVKQKVmGjCB4tHWEzz5c0g)6cvJXxCouzInSZjqa60s7hNcpI7)IVS3eEERxeuyHlUSh11b1jnghQ0BKbHmwxPbjipia5I7DrQWXfDsJXHk9g5ldZzH2HcEjvjFzat42WNcH9YYYfOn(1fQgJV4CsJXHk9gzGa0PL2pofE83)fFzVj88wVq1y8fzmNmSsVlU3fPchxmJ5KHv6Dzyol0ouWlPk5lckSWfxWAMycOcdeDec5magYmCev6zanJ5KHv6rdRzIjGkSldyc3g(uiSxwwUaTXVECk8i)9FXx2BcpV1lckSWfxWAMycOcdeDec5magYmCev6zajnsBAK2qNgwZetavyxCVlsfoUqAK20iTH(LH5Sq7qbVKQKVmGjCB4tHWEzz5c0g)6cvJXxCwJ0giaDwBOdeGoT0(XPWdW3)fFzVj88wVq1y8LbkuaSRGHxCVlsfoUavOayxbdVmmNfAhk4LuL8LbmHBdFke2lllxG24xpofEl3)fFzVj88wVq1y8fNtAmouP3ideGoHq7lU3fPchx0jnghQ0BKVmmNfAhk4LuL8LbmHBdFke2lllxG24xpofEx3)fFzVj88wVq1y8fRQrYKH6LjacqNqO9f37IuHJlB1izYq9YexgMZcTdf8sQs(YaMWTHpfc7LLLlqB8RhpUaqZ69ijU1h)]] )

    storeDefault( 'SimC Import: precombat', 'actionLists', 20161101.1, [[d0cEbaGEGs7cu2MqnturZgPBJIDQK9sTBj7hvzyK0VvmuGWGrLgoKoiiDmsTqiSus0Ify5aEOGQNQ6XqzDaPMiqXubvtwPMUuxuqEgjCDGKnde9zO67OcxM4WigneTmHCsuv3tq50Iopi65O0FbQ(giS1gUFOIeqLTr4Fublj0eSKoNYROyf(lcJ4)KjCEC5ZGoanO5XffqWgMas7RuOcHv8ksvhRv1XW0(hdirBFFOyDofRH7L2W9dvKaQSnc)JbKOTFp44ubg2m09WrX6dfaN1VimsyOadDkCzdo6WHa4dniPzdPp605u(8RDIr6bWVMs8vkuHWkEfPQJ1qatvH2FryeFqmDoLBVImC)qfjGkBJWFryeFotCKDLfopUhzk0Tp0GKMnK(0ehzxzHdolYuOBF(1oXi9a4xtj(kfQqyfVIu1XAiGPQq72TpyeqsafTnc32a]] )

    storeDefault( 'Wordup\'s Wowhead APL', 'actionLists', 20161101.1, [[dWtUnaGEciAtueTlqTnIyFuKmtcWSrmFci9jksPBtuhwQDcyVIDlz)krJsvfdJe)MuldedLacdwjz4G0bjsNsvLogvDocKwiHSusQfRulhPhsG4PqpgONRktKIumvkQjtLPR4IuWZiuxg11vv2ifHZtj2mLA7eOoTkFvjv9zc67us(gf6VQQA0KK5rjvNuj8ALuUgLuUhbunnLu5qeqzCuKQJpMdAO6nHDruqGwMdUEn19b10(wUA9ARuXTB5kPceciicspOtWGQzc3poaqu8s8kEjW(Giug8AYjq2ZPRaarI4GsbNtxVyoa(yoOHQ3e2frbbAzoOi9hXXu77nbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4Gs3h5glb36pIJP23BcIG0d6eCAcxdmPl3JCogMREtyNj3F22WKUCpY5yykl3x9SoL3F22)T6kN2Qmbasmh0q1Bc7IOGii9GobNMW1at6Y9iNJH5Q3e2zY9NTnmPl3JCogMYY9vpRt59NT9FRUYPTkOAMW9JdaefVeVryfX(Glk3b2JMgS0fheOL5GQ1GRTVHPbLUpYnwcs1GRTVHPzcG4yoOHQ3e2frbrq6bDconHRbwvFK3OPYWC1Bc7m5(Z2g2MQFZM2LdMYY9vpRt59NT9FRUYPTkOAMW9JdaefVeVryfX(Glk3b2JMgS0fhu6(i3yjOnv)MnTlxqGwMdAcQ(nBAxUmbyDXCqdvVjSlIcc0YCqtqAzE0LWpoOAMW9JdaefVeVryfX(Glk3b2JMgS0fhu6(i3yjOnPL5rxc)4Gii9Gob3F22W2KwMhDj8JHPSCF1Z6uE)zB)3QRCARYeaRfZbnu9MWUikicspOtWGQzc3poaqu8s8gHve7dUOChypAAWsxCqGwMdU(RCpDjmO09rUXsqRUY90LWmbqsmh0q1Bc7IOGii9GobdQMjC)4aarXlXBewrSp4IYDG9OPblDXbbAzoO0hixUUa5Gs3h5glb7hixUUa5mbWymh0q1Bc7IOGii9Gob3F22W2KwMhDj8JH)GAYFeytt4AGv1h5nAQmmx9MWobQaD)zBdBt1Vzt7Yb)b93GQzc3poaqu8s8gHve7dUOChypAAWsxCqGwMdAA0A5LRw)vUxqP7JCJLGoTw(Vvx5EzcGPhZbnu9MWUikicspOtWGQzc3poaqu8s8gHve7dUOChypAAWsxCqGwMdAcM2KLRqOh9MGs3h5glbTzAt()GE0BYeabnMdAO6nHDruqeKEqNGcS5ax7kHbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4GaTmh0eFullxPTxUs6rdkDFKBSe0(JA5V2(FF0mbWReZbnu9MWUikicspOtWgCobZ)5ILp(zkbU4Gs3h5glbbP9t1FYju1uxjm4IYDG9OPblDXbvZeUFCaGO4L4ncRi2heOL5GccTFQwUsaNqvtDLWLR(rQ2WVzcG3hZbnu9MWUikiqlZbXrtLFd9wJdQMjC)4aarXlXBewrSp4IYDG9OPblDXbLUpYnwc(gnv(n0BnoicspOtWmbWdjMdAO6nHDruqGwMdU(RCVHERXbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4Gs3h5glbT6k3BO3ACqeKEqNGzcGxCmh0q1Bc7IOGii9GobBW5em)Nlw(4NPe4qckDFKBSeeK2pv)jNqvtDLWGlk3b2JMgS0fhunt4(XbaIIxI3iSIyFqGwMdki0(PA5kbCcvn1vcxU6hbHWTG5FZea)6I5GgQEtyxefebPh0jiOwtCARk4T(J4yQ99gyqvnvi)(BtBW50vtmLh2O1cQMjC)4aarXlXBewrSp4IYDG9OPblDXbbAzoOi9hXXu77nlx9J)3Gs3h5glb36pIJP23BYeaV1I5GgQEtyxefebPh0j40eUgyv9rEJMkdZvVjSZK7pBByBQ(nBAxoykl3x9S(6GTwq1mH7hhaikEjEJWkI9bxuUdShnnyPloiqlZbnbv)MnTl3Yv)4)nO09rUXsqBQ(nBAxUmbWljMdAO6nHDruqeKEqNG7pBByBslZJUe(XWuwUV6z91bBTGQzc3poaqu8s8gHve7dUOChypAAWsxCqGwMdAcslZJUe(Xlx9J)3Gs3h5glbTjTmp6s4hNjaEJXCqdvVjSlIcIG0d6eCAcxdSwWmfuvtfYWC1Bc7mPCZK3q1YWGFukxJPeuLGQzc3poaqu8s8gHve7dUOChypAAWsxCqGwMdkGtOQPUs4YvI0KjO09rUXsqYju1uxj8)wtMmbWB6XCqdvVjSlIcIG0d6eC)zBdRsp)v1Ld(dAq1mH7hhaikEjEJWkI9bxuUdShnnyPloiqlZbfql4E5kb0pvbLUpYnwcsAb3)j9tvMa4f0yoOHQ3e2frbrq6bDcgunt4(XbaIIxI3iSIyFWfL7a7rtdw6Idc0YCqdnDuX1Yvi0BnoO09rUXsqUPJkU()GERXzcaeLyoOHQ3e2frbrq6bDconHRbgK2pvxj8)B0uzyU6nHDMuUzYBOAzyWpkLRXuMUsq1mH7hhaikEjEJWkI9bxuUdShnnyPloiqlZbfeA)uTCLaoHQM6kHbLUpYnwccs7NQ)KtOQPUsyMaaXhZbnu9MWUikicspOtq5MjVHQLHb)OuUgt59kbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4GaTmhe)khtVsyqP7JCJLGVVYX0ReMjaqGeZbnu9MWUikicspOtq5MjVHQLHb)OuUgtjOkbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4GaTmhuaTG7LReq)uTC1p(FdkDFKBSeK0cU)t6NQmbaI4yoOHQ3e2frbrq6bDcgunt4(XbaIIxI3iSIyFWfL7a7rtdw6Idc0YCqr6pIJP23BwU6hi)gu6(i3yj4w)rCm1(EtMaazDXCqdvVjSlIcc0YCq1AW123W0LR(X)Bq1mH7hhaikEjEJWkI9bxuUdShnnyPloO09rUXsqQgCT9nmnicspOtWmbaI1I5GgQEtyxefebPh0j40eUg4T(J4yQ99gyU6nHDbvZeUFCaGO4L4ncRi2hCr5oWE00GLU4GaTmh0eKwMhDj8JxU6hi)gu6(i3yjOnPL5rxc)4mzcAAy7(JmruMea]] )


    storeDefault( 'Enhancement Primary', 'displays', 20161101.1, [[dWtUeaGEIu7sLsBJiAMcPCyvnBrDBsDtaCnIGVPsX5fQ2jj7vA3c2pLFku0WiyCcj55qLHIudMQHtuhufoQq0Xa6CcPAHa0sHIwSIA5k8qq5POESISoHsMiOQPQIMmOY0rCrvYvjc5YkDDq2iuYYqsBwLQTdv9rHs9zannHW3fkmsIq9mOWOrIXtKCsOu3IqNgY9esQFlYAfs41cj6c2ZYrcTqlCMJvkqmNrsVvbsTm9aP)rCZXkfiMZiP3QaPwMEG0)iU5WEzckfm)aA8LzsAONhOaWDuES5YWUuNxywwIWTMZYBoJv(XrPZLz5FcfawLektJ)YCrZHFV)qzsbSmn(lZfnhwsp)KoxgGxkKgsB(jsVvHHq5iHwOfxpRcSNLVc)CEHRaw(yIGsbZJgchPkQLvVElZinmZXwlNgKyzU8yNs65NugZnVpUTkQcGscEZTcyawMNgizszcsVrTqjvrTNLVc)CEHRaw(yIGsbZJgchPkWYQxVLzKgM5yRLtdsSmhU9(dLjLXCZ7JBRIQaOKG3CRagGLuszA80MlAo879hktm)ilt5RcSmnEAZfnhwsp)KoxMgpT5IMd)E)HYKcy54flXOsi6uJqqsqWBWqGk1Be6DXiKqzPQsOmMBEFCBvufaLeuqi63cwosOfAn)iJag0BGuEQmn(lZfnhwsp)eZpYYu(QaltJN2CrZp)bWLy(rwMYxfyzA80MlAoSKE(jMFKLP8vbw(iMxMlAoaVuinKUkHYhteukyoSxMGsbCfWY04Vmx08ZFaCjDUmlVtOpJK(jOuOkQsIrzwEZzSYpokMdlLtJEw(RcS8CvGLbwfy5rvGLugwsoU5NPYxbkFyA1BGyoJcaZR45paUKY04Pnx08ZFaCjDUCKql0Ao8OXorqPqzmXo2s8zz1R3YxbkFyA1BGyo9aP)r8YrcTqlCMJ9ukyoJKERkcHYyLcKYhd0Nnx9JrkgLVc)CEHRawMEG0)iU5ypLcMZiP3QIqOmMFa4Aomk7uuIcal)ZOmIeV8rmVmx0CaqbKgsxfgLXEkfWzotjfJqvru(8ZBGyEShji5QekZOaW8AUO5a8sH0q6Qaltpq6Fe3CyVmbLcLXnEckv(aIKmx0CaqbKgsxLqzA8xMlA(5paUeZpYYu(Qald)E)HYKcy5disYCrZb4LcPH0vjuMrbG51CrZbafqAiDvcL5PbsMuUmn(lZfnh(9(dLjMFKLP8vbwoksjDvGsOKw]] )

    storeDefault( 'Enhancement AOE', 'displays', 20161101.1, [[dWJPeaGEsHDbsSnOkZurvoSQMTixwPBQI6XkYTP05vr2jj7vA3uSFQ(PIkdJO(TcNgPHsWGfgoHoiP6OKsoguohiPfQsAPGklwfwoqpeepf1YGkphIMiO0uvPMSkX0rCrr1vjLINjkUoGncQ6BKsLnROSDi1hfLYNHW0if9DrPAKIs06eL0OHKXdv1jbPUfrUgO4EIsyCKsvRLuk9Afv1fR3L1cyb2lEa)Wq8GPASvHHRSaAbpK84(brSKEuwaKAFWtEa5fj0HXdDaWVCzWnvgsU6ohUYAdY1dwCtj4tpsu9OSa6CpK84(brSKEuwaDUhsEa7o7bsKETSa6CpK8aYWE8KEu(8Jp1cy94MA3QYixwlGfyr27QW6D5CZFK2l9Az9jcDy8yEuKKQWvw92TmtTq8aAR4aKKvpeb3PH94jLHBt7JCRcNmgmY4bfC4WkZtGurszc1UzHCjvHR3LZn)rAV0RL1Ni0HXJ5rrsQcRS6TBzMAH4b0wXbijRECzN9ajsz420(i3QWjJbJmEqbhoSskPmpbsfjLrsnisBzb0cEi5bKH94j9OSaAbpK8a2D2dKi9A5tfEj8GrgQyYqnJ2LjJSMAFg5otstykRpxUhsEC(XNAbSvjxgUnTpYTkCYy4HjldvOGvwlGfy9qprrySRHuEQSoaz4HKhNF8PwaBvYLfql4HKh3piIL4HEse1xfwzMAqKwpK84m1qTa2QYuwBhdBvyWuwaTGhsEa7o7bsep0tIO(QWklGo3djpGDN9ajIh6jruFvyLfql4HKhqg2JN4HEse1xfwzwCtj4tpsuEazKgG9U8xfwzWQWkJOkSYhvHvszidXtECpkNBq9MP1UgIh6ZLxwaDUhsEazypEIh6jruFvyL1cybwpGLcUte6WugoOZwwExwhGm8qYJZud1cyRktzTawG9IhqpnmEWun2Q0uUmS7Shir61Y5M)iTx61YcOZ9qYJ7heXs8qpjI6RcRSai1(GN8aYlsOdt5l7ShirkRpxUhsECMAOwaBvzkZudI06HKhNF8PwaBvYLV)0AiEKnWbGyvYLHEAyq6bJAKDtvAwgU3Gy9acQDA(udIY)bnrjNkZI7e9tunEcDyQchEzkd)WqkRds)KhQheCK9YQ3ULZnOEZ0AxdXd95YllasTp4jpGEAy8GPASvPPCzbqQ9bp5b8ddXdMQXwfgUYS4prniQcMY6te6W4bKxKqhgK9Az8RsUKwa]] )



end