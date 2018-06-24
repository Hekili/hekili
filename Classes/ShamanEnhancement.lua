-- ShamanEnhancement.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


-- Generate the Enhancement spec database only if you're actually a Shaman.
if select( 2, UnitClass( 'player' ) ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 263 )

    spec:RegisterResource( Enum.PowerType.Mana )   
    spec:RegisterResource( Enum.PowerType.Maelstrom, {
        mainhand = {
            resource = 'maelstrom',
            -- setting = 'forecast_swings',

            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            stop = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return t - swing > state.swings.mainhand_speed * 1.5
            end,

            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            resource = 'maelstrom',
            -- setting = 'forecast_swings',

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            stop = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return t - swing > state.swings.offhand_speed * 1.5
            end,

            interval = 'offhand_speed',
            value = 5
        },

        fury_of_air = {
            resource = 'maelstrom',
            -- setting = 'forecast_fury',
            aura = 'fury_of_air',

            last = function ()
                local app = state.buff.fury_of_air.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x < 3
            end,

            interval = 1,
            value = -3,
        },
    } )


    -- TALENTS
    spec:RegisterTalents( {
        boulderfist = 22354,
        hot_hand = 22355,
        lightning_shield = 22353,

        landslide = 22636,
        forceful_winds = 22150,
        totem_mastery = 23109,

        spirit_wolf = 23165,
        earth_shield = 19260,
        static_charge = 23166,

        searing_assault = 23089,
        hailstorm = 23090,
        overcharge = 22171,

        natures_guardian = 22144,
        feral_lunge = 22149,
        wind_rush_totem = 21966,

        crashing_storm = 21973,
        fury_of_air = 22352,
        sundering = 22351,

        elemental_spirits = 21970,
        earthen_spike = 22977,
        ascendance = 21972
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3553, -- 196029
        adaptation = 3552, -- 214027
        gladiators_medallion = 3551, -- 208683

        forked_lightning = 719, -- 204349
        static_cling = 720, -- 211062
        thundercharge = 725, -- 204366
        shamanism = 722, -- 193876
        spectral_recovery = 3519, -- 204261
        ride_the_lightning = 721, -- 204357
        grounding_totem = 3622, -- 204336
        swelling_waves = 3623, -- 204264
        ethereal_form = 1944, -- 210918
        skyfury_totem = 3487, -- 204330
        counterstrike_totem = 3489, -- 204331
        purifying_waters = 3492, -- 204247
    } )


    spec:RegisterAuras( {
        ascendance = {
            id = 114051,
            duration = 15,
        },
        
        astral_shift = { 
            id = 108271,
            duration = 8,
        },

        boulderfist = {
            id = 218825,
            duration = 10,
        },

        chill_of_the_twisting_nether = {
            id = 207998,
            duration = 8,
        },

        crackling_surge = {
            id = 224127,
            duration = 15,
        },

        crash_lightning = {
            id = 187878,
            duration = 10,
        },

        crashing_lightning = {
            id = 242286,
            duration = 16,
            max_stack = 15,
        },

        earthen_spike = {
            id = 188089,
            duration = 10,
        },

        feral_spirit = {            
            name = "Feral Spirit",
            duration = 15,
            generate = function ()
                local cast = rawget( class.abilities.feral_spirit, "lastCast" ) or 0
                local up = cast + 15 > query_time

                local fs = buff.feral_spirit
                fs.name = "Feral Spirit"

                if up then
                    fs.count = 1
                    fs.expires = cast + 15
                    fs.applied = cast
                    fs.caster = "player"
                    return
                end
                fs.count = 0
                fs.expires = 0
                fs.applied = 0
                fs.caster = "nobody"
            end,
        },

        fire_of_the_twisting_nether = {
            id = 207995,
            duration = 8,
        },

        flametongue = {
            id = 194084,
            duration = 16,
        },

        frostbrand = {
            id = 196834,
            duration = 16,
        },

        fury_of_air = {
            id = 197211,
            duration = 3600,
        },

        hot_hand = {
            id = 215785,
            duration = 15,
        },

        landslide = {
            id = 202004,
            duration = 10,
        },

        lashing_flames = {
            id = 240842,
            duration = 10,
            max_stack = 99,
        },

        lightning_crash = {
            id = 242284,
            duration = 16
        },

        lightning_shield = {
            id = 192106,
            duration = 3600,
        },

        molten_weapon = {
            id = 271924,
            duration = 4,
        },

        shock_of_the_twisting_nether = {
            id = 207999,
            duration = 8,
        },

        stormbringer = {
            id = 201846,
            duration = 12,
            max_stack = 1,
        },

        totem_mastery = {
            name = "Totem Mastery",
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        expires = cast_time + 120
                        remains = expires - now
                        break
                    end
                end

                local up = buff.resonance_totem.up or remains > 110

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if expires > 0 and up then
                    tm.count = 4
                    tm.expires = expires
                    tm.applied = expires - 120
                    tm.caster = "player"

                    applyBuff( "resonance_totem", remains )
                    applyBuff( "tailwind_totem", remains )
                    applyBuff( "storm_totem", remains )
                    applyBuff( "ember_totem", remains )
                    return
                end

                tm.count = 0
                tm.expires = 0
                tm.applied = 0
                tm.caster = "nobody"
            end,
        }
    } )


    spec:RegisterStateTable( 'feral_spirit', 
        setmetatable( { onReset = function( self ) self.cast_time = nil end },
        { __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.feral_spirit.lastCast or 0
                return t.cast_time
            elseif k == 'active' or k == 'up' then
                return query_time < t.cast_time + 15
            elseif k == 'remains' then
                return max( 0, t.cast_time + 15 - query_time )
            end

            return false
        end } ) )

    spec:RegisterStateTable( 'twisting_nether',
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'count' then
                return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
            end
            
            return 0
        end } ) )

    spec:RegisterGear( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( 'force_of_the_mountain', {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( 'exposed_elements', {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( 'waycrest_legacy', 158362, 159631 )
    spec:RegisterGear( 'electric_mail', 161031, 161034, 161032, 161033, 161035 )
    -- spec:RegisterGear( 'fake_set_test', 155325, 155262, 159907 )

    spec:SetPotion( 'prolonged_power' )

    spec:RegisterHook( 'spend', function( amt, resource )
        -- n/a, this was actually an ele thing.
    end )

    spec:RegisterStateFunction( 'gambling', function ()
        -- n/a, this was actually an ele thing.
    end )

    spec:RegisterAbilities( {
        ascendance = {
            id = 114051,
            cast = 0,
            cooldown = 180,
            gcd = 'off',

            readyTime = function() return buff.ascendance.remains end,
            recheck = function () return buff.ascendance.remains end,
            
            nobuff = 'ascendance',
            talent = 'ascendance',
            toggle = 'cooldowns',

            startsCombat = false,

            handler = function ()
                applyBuff( 'ascendance', 15 )
                setCooldown( 'stormstrike', 0 )
                setCooldown( 'windstrike', 0 )
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = 'off',

            startsCombat = false,

            handler = function ()
                applyBuff( 'astral_shift', 8 )
            end,
        },

        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = 'spell', -- Ugh.
            
            spend = 0.215,
            spendType = 'mana',
            
            startsCombat = false,

            handler = function ()
                applyBuff( 'bloodlust', 40 )
            end,
        },

        crash_lightning = {
            id = 187874,
            cast = 0,
            cooldown = function () return 6 * haste end,
            gcd = 'spell',

            spend = 20,
            spendType = 'maelstrom',

            recheck = function () return buff.crash_lightning.remains end,
            
            startsCombat = true,

            handler = function ()
                if active_enemies >= 2 then
                    applyBuff( 'crash_lightning', 10 )
                end

                removeBuff( 'crashing_lightning' )
                
                if set_bonus.tier20_2pc > 1 then
                    applyBuff( 'lightning_crash' )
                end

                if level < 105 then 
                    if equipped.emalons_charged_core and spell_targets.crash_lightning >= 3 then
                        applyBuff( 'emalons_charged_core', 10 )
                    end

                    if equipped.eye_of_the_twisting_nether then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end
            end,
        },

        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136024,

            toggle = "cooldowns",            
            
            handler = function ()
                summonPet( "greater_earth_elemental", 60 )
            end,
        },
        
        earthen_spike = {
            id = 188089,
            cast = 0,
            cooldown = function () return 20 * haste end,
            gcd = 'spell',

            spend = 20,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                applyDebuff( 'target', 'earthen_spike' )
            end,
        },

        feral_spirit = {
            id = 51533,
            cast = 0,
            cooldown = function () return 120 - ( talent.elemental_spirits.enabled and 30 or 0 ) end,
            gcd = "spell",

            startsCombat = false,
            toggle = "cooldowns",

            handler = function () feral_spirit.cast_time = query_time; applyBuff( "feral_spirit" ) end
        },

        flametongue = {
            id = 193796,
            cast = 0,
            cooldown = function () return 12 * haste end,
            gcd = 'spell',

            recheck = function () return buff.flametongue.remains, buff.flametongue.remains - 4.8, buff.flametongue.remains - ( 6 + gcd ) end,

            startsCombat = true,

            handler = function ()
                applyBuff( 'flametongue', 16 + min( 4.8, buff.flametongue.remains ) )

                if level < 105 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether', 8 )
                end
            end,
        },


        --[[ Item Example
            draught_of_souls = {
            item = 140808,
            cast = 0,
            cooldown = 80,
            gcd = 'off',

            toggle = 'cooldowns',

            startsCombat = true,

            handler = function ()
                applyBuff( "fel_crazed_rage", 3 )
                setCooldown( "global_cooldown", 3 )
            end,
        }, ]]


        frostbrand = {
            id = 196834,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = 'maelstrom',

            startsCombat = true,

            recheck = function () return buff.frostbrand.remains, buff.frostbrand.remains - 4.8, buff.frostbrand.remains - ( 6 + gcd ) end,
            handler = function ()
                applyBuff( 'frostbrand', 16 + min( 4.8, buff.frostbrand.remains ) )
                if level < 105 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'chill_of_the_twisting_nether', 8 )
                end
            end,
        },


        fury_of_air = {
            id = 197211,
            cast = 0,
            cooldown = 0,
            gcd = function( x ) if buff.fury_of_air.up then return 'off' end end,

            spend = 3,
            spendType = "maelstrom",

            talent = 'fury_of_air',

            startsCombat = false,

            handler = function ()
                if buff.fury_of_air.up then removeBuff( 'fury_of_air' )
                else applyBuff( 'fury_of_air', 3600 ) end
            end,
        },


        healing_surge = {
            id = 188070,
            cast = function() return maelstrom.current >= 20 and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return maelstrom.current >= 20 and 20 or 0 end,
            spendType = "maelstrom",

            startsCombat = false,
        },


        heroism = {
            id = 32182,
            cast = 0,
            cooldown = 300,
            gcd = "spell", -- Ugh.

            spend = 0.215,
            spendType = 'mana',

            startsCombat = false,
            toggle = 'cooldowns',

            handler = function ()
                applyBuff( 'heroism' )
                applyDebuff( 'player', 'exhaustion', 600 )
            end,
        },


        lava_lash = {
            id = 60103,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function() return buff.hot_hand.up and 0 or 30 end,
            spendType = "maelstrom",

            startsCombat = true,

            handler = function ()
                removeBuff( 'hot_hand' )
                if level < 105 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                    if buff.crash_lightning.up then applyBuff( 'shock_of_the_twisting_nether' ) end
                end
            end,
        },


        lightning_bolt = {
            id = 187837,
            cast = 0,
            cooldown = function() return talent.overcharge.enabled and ( 12 * haste ) or 0 end,
            gcd = "spell",
            
            spend = function() return talent.overcharge.enabled and min( maelstrom.current, 40 ) or 0 end,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                if level < 105 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether' )
                end
            end,
        },


        lightning_shield = {
            id = 192106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = 'lightning_shield',
        
            readyTime = function () return buff.lightning_shield.remains - 120 end,
            usable = function () return buff.lightning_shield.remains < 120 end,
            handler = function () applyBuff( 'lightning_shield' ) end,
        },


        rockbiter = {
            id = 193786,
            cast = 0,
            cooldown = function() local x = 6 * haste; return talent.boulderfist.enabled and ( x * 0.85 ) or x end,
            recharge = function() local x = 6 * haste; return talent.boulderfist.enabled and ( x * 0.85 ) or x end,
            charges = 2,
            gcd = "spell",
            
            spend = -25,
            spendType = "maelstrom",

            startsCombat = true,

            recheck = function () return ( 1.7 - charges_fractional ) * recharge end,

            handler = function ()
                if level < 105 and equpped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether' )
                end
                removeBuff( 'force_of_the_mountain' )
                if set_bonus.tier21_4pc > 0 then applyDebuff( 'target', 'exposted_elements', 4.5 ) end
            end,
        },


        stormstrike = {
            id = 17364,
            cast = 0,
            cooldown = function()
                if buff.stormbringer.up then return 0 end
                if buff.ascendance.up then return 9 * 0.2 end
                return 9 * haste
            end,
            gcd = "spell",

            spend = function()
                if buff.stormbringer.up then return 0 end
                if buff.ascendance.up then return 6 end
                return 30
            end,

            spendType = 'maelstrom',

            startsCombat = true,
            texture = 132314,

            usable = function() return buff.ascendance.down end,
            handler = function ()
                removeBuff( 'stormbringer' )
                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )
    
                if level < 105 and equipped.storm_tempests then
                    applyDebuff( 'target', 'storm_tempests', 15 )
                end
    
                if set_bonus.tier20_4pc > 0 then
                    addStack( 'crashing_lightning', 16, 1 )
                end
    
                if level < 105 and equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
                end
            end,                    

            copy = "strike", -- copies this ability to this key or keys (if a table value)
        },


        sundering = {
            id = 197214,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            spend = 20,
            spendType = "maelstrom",

            startsCombat = true,
            talent = 'sundering',

            handler = function () if level < 105 and equipped.eye_of_the_twisting_nether then applyBuff( 'shock_of_the_twisting_nether' ) end end,
        },


        totem_mastery = {
            id = 210643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = "totem_mastery",

            usable = function () return buff.totem_mastery.remains < 15 end,
            handler = function ()
                applyBuff( 'resonance_totem', 120 )
                applyBuff( 'storm_totem', 120 )
                applyBuff( 'ember_totem', 120 )
                if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
                applyBuff( 'tailwind_totem', 120 )
                applyBuff( 'totem_mastery', 120 )
            end,
        },


        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "off",

            startsCombat = true,
            toggle = "interrupts",

            usable = function () return debuff.casting.up end,
            handler = function () interrupt() end,
        },

        windstrike = {
            id = 115356,
            cast = 0,
            cooldown = function() return buff.stormbringer.up and 0 or ( 9 * 0.2 * haste ) end,
            gcd = "off",

            spend = function() return buff.stormbringer.up and 0 or 6 end,
            spendType = "maelstrom",
            
            texture = 1029585,

            known = 17364,
            usable = function () return buff.ascendance.up end,
            handler = function ()
                setCooldown( 'stormstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                removeBuff( 'stormbringer' )

                if level < 105 and equipped.storm_tempests then
                    applyDebuff( 'target', 'storm_tempests', 15 )
                end
    
                if set_bonus.tier20_4pc > 0 then
                    addStack( 'crashing_lightning', 16, 1 )
                end
    
                if level < 105 and equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                    applyBuff( 'shock_of_the_twisting_nether', 8 )
                end
            end,
        },
    } )

    spec:RegisterAura( 'fel_crazed_rage', {
        id = 225141,
        duration = 3,
        incapacitate = true, -- ???
    } )

    spec:RegisterPack( "Enhancement", 20180619.223000,
        [[dm0EQaqiOkEKav2ei5tqvbJsL4uQOwfuviVcKAwqLULav1UK4xGOHPeDmb0YqP6zQK00uj11qPSnOQ6BQKyCqv6CqvrRtGQ08eOCpjzFQihuGQOfccpuGCrbOyKcqjNuGQWkfKDQc9tbidfQkTubOupLstvqTwOQqTxr)LugSqhMyXk1Jr1KHYLr2mO(SsA0sQtR41QGzRQBJIDl1VHmCLWYbEoftNQRtQ2Uk13faJxaQopuX8rj7NKZaZWPftCkpY(YaX7s8hi(SWo7SJpz7kP1XzbL2fc)GSsPTfgkTbmDT0CIHApTleCEKGLHtRbPd4uARDFHj4fsixigN2tx4igiXpg(4aofWdVmTB959GhDcrAXeNsl7ldeVb)L4p4hiEvr2dm49Q4pTMfeppYo(VAAXidpTHRhJkogvuuXfc)GSsQicwffUpOwf)X4gvegbuXaw0H5NsA)X4MmCA5iaLHZJbMHtl1Y(jSeI0YbJtGrs7Tagz)ubwhGtq1e)a7SLwH7dQtljaVMAnZI5aLEEK9mCAPw2pHLqKwoyCcmsAVOIBDy4chi8d)0RAgDWkv0xOISyPIBDy4YlnM5hmQOVqfpNwH7dQtBaMgZ4G5aLEE8Qz40sTSFclHiTCW4eyK0Erf36WWfoq4h(Px1m6GvQOVqfzXsf36WWLxAmZpyurFHkEwfHsfVfWi7NkW6aCcQM4hyNT0kCFqDAnocWyCWCGsppEDgoTul7NWsislhmobgjTU8u7f0nb41cyLkul7NWurOurgHEJdqmQ4PkveFYwAfUpOoT)Sw790RAB07PNhzldNwQL9tyjePLdgNaJKwH7ZnPrnXmKrfpvPI4vfzXsfVOIc3NBsJAIziJkEQsfXVkcLk6YtTx4aXup9QMXraMc1Y(jmv8CAfUpOoTCGyQ1(zT27PxtppI)mCAfUpOoTbyAmJdMduAPw2pHLqKEE8kz40sTSFclHiTCW4eyK0kCFUjnQjMHmQ4Pkv8QPv4(G60A0Bmcm9A65r8MHtl1Y(jSeI0YbJtGrs7whgUuJCTAPXkas4EAfUpOoTVClAVyQtppIpZWPLAz)ewcrA5GXjWiP1LNAVyibm9QMymI(7fQL9tyPv4(G60c)cd5OEvNsppg4YmCAPw2pHLqKwoyCcmsA36WWfJJamBW0ReOOVqfHsfVfWi7NkW6aCcQM4hyNT0kCFqDAnocWyCWCGsppgyGz40sTSFclHiTCW4eyK0kCFUjnQjMHmQ4Pkv8AvKflv8IkkCFUjnQjMHmQ4PkvKDvekv0LNAVWbIPE6vnJJamfQL9tyQ450kCFqDA5aXuR9ZAT3tVMEEmq2ZWPLAz)ewcrA5GXjWiP1LNAVGUjaVwaRuHAz)eMkcLkElGr2pvG1b4eunXpCnBQiuQiJqVXbigv8uLkE9Y0kCFqDA)zT27Px12O3tppg4vZWPLAz)ewcrA5GXjWiP9IkIhv0LNAVGUjaVwaRuHAz)eMkcLkElGr2pvG1b4eunXpCnBQ4zvKflv8Ik6YtTxq3eGxlGvQqTSFctfHsfVfWi7NkW6aCcQM4hUYsvekvKJqpgkaD5N1AVNEvBJEVaigzAJkEsfx5yQi(ivKDv8CAfUpOoTghbymoyoqPNhd86mCAPw2pHLqKwoyCcmsA36WWfg07uRfaswG6cGeUNwH7dQt7l3I2lM60ZJbYwgoTc3huNwJEJrGPxtl1Y(jSeI0ZJbI)mCAPw2pHLqKwoyCcmsAfUp3Kg1eZqgv8uLkE10kCFqDA5aXuR9ZAT3tVME6PfTGAcKHZJbMHtl1Y(jSeI0YbJtGrslJqVXbigvmyQyGSPIqPI(WqQyWuXvowAfUpOoTae)WECcKE6Pvm8mCEmWmCAfUpOoTKa8AQ1mlMduAPw2pHLqKEEK9mCAfUpOoTbyAmJdMduAPw2pHLqKE6PDbG4iMT4z48yGz40sTSFcl3PNhzpdNwH7dQt7cKpOoTul7NWsisppE1mCAfUpOoT)Sw790RAM6HES0sTSFclHi9841z40kCFqDADKtmAmIXjaoPLAz)ewcr65r2YWPv4(G60scWR1ONyO2LpTul7NWsisp90cp)tGmCEmWmCAPw2pHLqKwoyCcmsAze6noaXOIbtfVYY0kCFqDAbi(H94ei98i7z40sTSFclHiTCW4eyK0U1HHlWVWqoQx1PcGyKPnQyWuXRl4nTc3huNw4xyih1R6u65XRMHtl1Y(jSeI0YbJtGrsRlp1EPwM34iatHAz)eMkcLkU1HHlWaKX3aPXkaIrM2OIbtfVUGxvekvKrO34aeJkEsfVEzAfUpOoTWaKX3aPXsppEDgoTul7NWsislhmobgjTmc9ghGyuXtvQiBlvrOuXBbmY(Psafe(IqpExQIqPI3cyK9tfyDaobvt8d4DzAfUpOoTVClAVyQtppYwgoTc3huNwaIFypobsl1Y(jSeI0ZJ4pdNwQL9tyjePLdgNaJK2lQiJqVXbigv8uLkIF2urwSurxEQ9chiM6Px1mocWuOw2pHPISyPIc3NBsJAIziJkEQsfzxfpRIqPI3cyK9tLaki8fHE8VufHsfVfWi7NkW6aCcQM4hUMT0kCFqDA5aXuR9ZAT3tVMEE8kz40kCFqDAHFHHCuVQtPLAz)ewcr65r8MHtRW9b1P1roXOXigNa4KwQL9tyjePNEA5yMmCEmWmCAPw2pHL70YbJtGrsRlGvYl1K8EDzb3vXGPISZMkYILk6ddPINuXLf2wUmTc3huN29JqyVUXtppYEgoTul7NWsislhmobgjTBDy4Iy4uJjnNk6lurwSuXlQimbKxZSyaJxaeJmTrfpPISPINvrwSuXNUPxfdMkg4YLPv4(G60UjGHahMEn984vZWPLAz)ewcrA5GXjWiPDRddxedNAmP5urFHkYILkErfHjG8AMfdy8cGyKPnQ4jvKnv8SkYILk(0n9QyWuXaxUmTc3huN29JqyAW6aCsppEDgoTc3huNwyciVMzXagpTul7NWsisppYwgoTc3huNwsaETg9ed1U8PLAz)ewcr65r8NHtl1Y(jSeI0YbJtGrs7fvKJqpgkaDX4iaJXbZbQaigzAJkEsfxQINtRW9b1PvmCQXKMtPNEA36WWMmCEmWmCAPw2pHLqKwoyCcmsAXJk6d)W0RQiuQiJqVXbigv8KkYo7Pv4(G60cRdWrdbRjdi98i7z40sTSFclHiTCW4eyK0IhvCRddxGFHHCuVQtf9fPv4(G60c)cd5OEvNsppE1mCAPw2pHLqKwoyCcmsAVfWi7Nk1Y8ghbycQM4hurOuXBbmY(PcSoaNGQj(HRzlTc3huNwyaY4BG0yPNhVodNwQL9tyjePLdgNaJKw8OIBDy4chiMATFwR9E61I(cvekvu4(CtAutmdzuXtvQi7Pv4(G60YbIPw7N1AVNEn98iBz40sTSFclHiTCW4eyK0U1HHlaYGAP5KMJCIPaigzAJkgmvK90kCFqDADKtmAmIXjaoPNEAXiyr)9mCEmWmCAfUpOoTbyAmntnjG0sTSFclHi98i7z40sTSFclHiT3cqRfgkT1Y8ghbycQM4hsRW9b1P9waJSFkT3YRtP9Ik6YtTxQL5nocWuOw2pHPIqPI4rf36WWfyaY4BG0yf9fQ450ZJxndNwQL9tyjeP9waATWqPfwhGtq1e)aExMwH7dQt7Tagz)uAVLxNs7fvepQOlp1EbwhGJgcwtgqHAz)eMkYILkErfD5P2lW6aC0qWAYakul7NWurOurgHEJdqmQ4jveVlvXZQ450ZJxNHtl1Y(jSeI0ElaTwyO0cRdWjOAIF4kltRW9b1P9waJSFkT3YRtP9IkIhv0LNAVaRdWrdbRjdOqTSFctfzXsfVOIU8u7fyDaoAiynzafQL9tyQiuQiJqVXbigv8KkELLQ4zv8C65r2YWPLAz)ewcrAVfGwlmuAH1b4eunXpCnBPv4(G60ElGr2pL2B51P0ErfXJk6YtTxG1b4OHG1KbuOw2pHPISyPIxurxEQ9cSoahneSMmGc1Y(jmvekvKrO34aeJkEsfVMnv8SkEo98i(ZWPLAz)ewcrAVfGwlmuAH1b4eunXpWoBPv4(G60ElGr2pL2B51P0ErfXJk6YtTxG1b4OHG1KbuOw2pHPISyPIxurxEQ9cSoahneSMmGc1Y(jmvekvKrO34aeJkEsfzNnv8SkEo984vYWPLAz)ewcrAVfGwlmuAdOGWxe6dC5Y0kCFqDAVfWi7Ns7T86uAVOI4rfD5P2lOBcWRfWkvOw2pHPISyPIxurxEQ9c6Ma8AbSsfQL9tyQiuQ4fvKrO34aeJkEsfdC5svKflvKJqpgkaD5N1AVNEvBJEVaigzAJkEsfx5yQ4zv8SkEo98iEZWPLAz)ewcrAVfGwlmuAdOGWxe6X7Y0kCFqDAVfWi7Ns7T86uAVOI4rfD5P2lOBcWRfWkvOw2pHPISyPIxurxEQ9c6Ma8AbSsfQL9tyQiuQ4fvKrO34aeJkEsfX7svKflvKJqpgkaD5N1AVNEvBJEVaigzAJkEsfx5yQ4zv8SkEo98i(mdNwQL9tyjeP9waATWqPnGccFrO)kltRW9b1P9waJSFkT3YRtP9IkIhv0LNAVGUjaVwaRuHAz)eMkYILkErfD5P2lOBcWRfWkvOw2pHPIqPIxurgHEJdqmQ4jv8klvrwSuroc9yOa0LFwR9E6vTn69cGyKPnQ4jvCLJPINvXZQ450ZJbUmdNwQL9tyjeP9waATWqPnGccFrOh)ltRW9b1P9waJSFkT3YRtP9IkIhv0LNAVGUjaVwaRuHAz)eMkYILkErfD5P2lOBcWRfWkvOw2pHPIqPIxurgHEJdqmQ4jve)lvrwSuroc9yOa0LFwR9E6vTn69cGyKPnQ4jvCLJPINvXZQ450ZJbgygoTc3huNwr3rAI7c)qAPw2pHLqKEEmq2ZWPv4(G60QBiTXjgtAPw2pHLqKEEmWRMHtl1Y(jSeI0kCFqDA5Y)Ac3huR9JXt7pgxRfgkTOfutG0ZJbEDgoTul7NWsisRW9b1PLl)RjCFqT2pgpTCW4eyK0U1HHlIHtnM0CQOViT)yCTwyO0kgE65XazldNwQL9tyjePv4(G60YL)1eUpOw7hJN2FmUwlmuA36WWM0ZJbI)mCAPw2pHLqKwH7dQtlx(xt4(GATFmEA)X4ATWqPLJzsppg4vYWPLAz)ewcrAfUpOoTC5FnH7dQ1(X4P9hJR1cdLwocqPNhdeVz40sTSFclHiTc3huNwU8VMW9b1A)y80(JX1AHHsl88pbsp90t7nbmdQZJSVmq8Ue)bI3c7SVK90gab0tVAsBAfDVgbsBaBDJuN2fae88uAdovmGjGtCDNWuXnbJaKkYrmBXvXnToTPOIbp5CAHBuXg1b)AbWaR)QOW9b1gve1pofvOGt4(GAtzbG4iMT4vWVyoOcfCc3huBklaehXSfh6kiHrimvOGt4(GAtzbG4iMT4qxbPOVYqTl(GAvOGtfTTSWuJCveidMkU1HHjmv04IBuXnbJaKkYrmBXvXnToTrfLgtfxaOG)cK7tVQIJrfXqnvuHeUpO2uwaioIzlo0vqAAzHPg5AgxCJkKW9b1MYcaXrmBXHUcYfiFqTkKW9b1MYcaXrmBXHUcYFwR9E6vnt9qpMkKW9b1MYcaXrmBXHUcsh5eJgJyCcGJkKW9b1MYcaXrmBXHUcssaETg9ed1U8QqQqbNkgWeWjUUtyQiDtaCurFyiv0Rjvu4ocOIJrfLBzEz)urfs4(GAtvaMgtZutcqfs4(GAd0vqElGr2pHBlmuvTmVXraMGQj(bCVLxNQU4YtTxQL5nocWuOw2pHbfE26WWfyaY4BG0yf9fNvHeUpO2aDfK3cyK9t42cdvbRdWjOAIFaVlX9wEDQ6cEC5P2lW6aC0qWAYakul7NWyX6Ilp1EbwhGJgcwtgqHAz)egumc9ghGyoH3LNpRcjCFqTb6kiVfWi7NWTfgQcwhGtq1e)WvwI7T86u1f84YtTxG1b4OHG1KbuOw2pHXI1fxEQ9cSoahneSMmGc1Y(jmOye6noaXC6klpFwfs4(GAd0vqElGr2pHBlmufSoaNGQj(HRzd3B51PQl4XLNAVaRdWrdbRjdOqTSFcJfRlU8u7fyDaoAiynzafQL9tyqXi0BCaI501SD(SkKW9b1gORG8waJSFc3wyOkyDaobvt8dSZgU3YRtvxWJlp1EbwhGJgcwtgqHAz)eglwxC5P2lW6aC0qWAYakul7NWGIrO34aeZj2z78zviH7dQnqxb5Tagz)eUTWqvbuq4lc9bUCjU3YRtvxWJlp1EbDtaETawPc1Y(jmwSU4YtTxq3eGxlGvQqTSFcdQlmc9ghGyof4YLSyXrOhdfGU8ZAT3tVQTrVxaeJmT50kh785ZQqc3huBGUcYBbmY(jCBHHQcOGWxe6X7sCVLxNQUGhxEQ9c6Ma8AbSsfQL9tySyDXLNAVGUjaVwaRuHAz)eguxye6noaXCcVlzXIJqpgkaD5N1AVNEvBJEVaigzAZPvo25ZNvHeUpO2aDfK3cyK9t42cdvfqbHVi0FLL4ElVovDbpU8u7f0nb41cyLkul7NWyX6Ilp1EbDtaETawPc1Y(jmOUWi0BCaI50vwYIfhHEmua6YpR1Ep9Q2g9EbqmY0MtRCSZNpRcjCFqTb6kiVfWi7NWTfgQkGccFrOh)lX9wEDQ6cEC5P2lOBcWRfWkvOw2pHXI1fxEQ9c6Ma8AbSsfQL9tyqDHrO34aeZj8VKfloc9yOa0LFwR9E6vTn69cGyKPnNw5yNpFwfsfs4(GAd0vqk6ostCx4huHeUpO2aDfK6gsBCIXOcjCFqTb6ki5Y)Ac3huR9JXXTfgQcTGAcOcjCFqTb6ki5Y)Ac3huR9JXXTfgQsmCCh4QTomCrmCQXKMtf9fQqc3huBGUcsU8VMW9b1A)yCCBHHQ26WWgviH7dQnqxbjx(xt4(GATFmoUTWqvCmJkKW9b1gORGKl)RjCFqT2pgh3wyOkocqQqc3huBGUcsU8VMW9b1A)yCCBHHQGN)jGkKkKW9b1MIy4vKa8AQ1mlMdKkKW9b1MIy4qxbzaMgZ4G5aPcPcfCc3huBkBDyytfaXpShNa4oWvU8u7LxAmZpyuHAz)egu4zRddxEPXm)Grf9fQqc3huBkBDyyd0vqcRdWrdbRjda3bUcp(Wpm9kumc9ghGyoXo7Qqc3huBkBDyyd0vqc)cd5OEvNWDGRWZwhgUa)cd5OEvNk6luHeUpO2u26WWgORGegGm(gingUdC1Tagz)uPwM34iatq1e)au3cyK9tfyDaobvt8dxZMkKW9b1MYwhg2aDfKCGyQ1(zT27PxXDGRWZwhgUWbIPw7N1AVNETOVakH7ZnPrnXmK5uf7Qqc3huBkBDyyd0vq6iNy0yeJtaCWDGR26WWfazqT0CsZroXuaeJmTjySRcPcfCQiepcH96gxf5IXNEvf3uTCpiGkYmaacyurVMurZWO)IJaQOHCF6vJkcJaQ4cakGJJkUFec71nErfTePIOf(GAJkIpSFec71nU2ccWP2XhWvfLgtfXh2pcH96gxZhgcFOOIQqc3huBkCmt1(riSx344oWvUawjVutY71LfCpySZglw(WqNwwyB5sviH7dQnfoMb6ki3eWqGdtVI7axT1HHlIHtnM0CQOVGfRlWeqEnZIbmEbqmY0MtSDMfRNUPpybUCPkKW9b1MchZaDfK7hHW0G1b4G7axT1HHlIHtnM0CQOVGfRlWeqEnZIbmEbqmY0MtSDMfRNUPpybUCPkuWjCFqTPWXmqxb5cKpOg3bUARddxedNAmP5urFblw4XLNAVigo1ysZPc1Y(jmOGjG8AMfdy8cGyKPnNyJflxaRKx8HH0CKg2qbRc)lvHeUpO2u4ygORGeMaYRzwmGXvHeUpO2u4ygORGKeGxRrpXqTlVkKW9b1MchZaDfKIHtnM0Cc3bU6chHEmua6IXbZbQaigzAZPLNvHuHeUpO2u4iavrcWRPwZSyoq4oWv3cyK9tfyDaobvt8dSZMkKW9b1MchbiORGmatJzCWCGWDGRUS1HHlCGWp8tVQz0bRurFblwBDy4YlnM5hmQOV4SkKW9b1MchbiORG04iaJXbZbc3bU6YwhgUWbc)Wp9QMrhSsf9fSyT1HHlV0yMFWOI(IZqDlGr2pvG1b4eunXpWoBQqc3huBkCeGGUcYFwR9E6vTn6DCh4kxEQ9c6Ma8AbSsfQL9tyqXi0BCaI5uf(KnviH7dQnfocqqxbjhiMATFwR9E6vCh4kH7ZnPrnXmK5ufEzX6IW95M0OMygYCQc)q5YtTx4aXup9QMXraMc1Y(jSZQqc3huBkCeGGUcYamnMXbZbsfs4(GAtHJae0vqA0Bmcm9kUdCLW95M0OMygYCQ6QQqc3huBkCeGGUcYxUfTxm14oWvBDy4snY1QLgRaiH7Qqc3huBkCeGGUcs4xyih1R6eUdCLlp1EXqcy6vnXye93lul7NWuHeUpO2u4iabDfKghbymoyoq4oWvBDy4IXraMny6vcu0xa1Tagz)ubwhGtq1e)a7SPcjCFqTPWrac6ki5aXuR9ZAT3tVI7axjCFUjnQjMHmNQUMfRlc3NBsJAIziZPk2HYLNAVWbIPE6vnJJamfQL9tyNvHeUpO2u4iabDfK)Sw790RAB074oWvU8u7f0nb41cyLkul7NWG6waJSFQaRdWjOAIF4A2GIrO34aeZPQRxQcjCFqTPWrac6kinocWyCWCGWDGRUGhxEQ9c6Ma8AbSsfQL9tyqDlGr2pvG1b4eunXpCnBNzX6Ilp1EbDtaETawPc1Y(jmOUfWi7NkW6aCcQM4hUYsO4i0JHcqx(zT27Px12O3laIrM2CALJHpI9ZQqc3huBkCeGGUcYxUfTxm14oWvBDy4cd6DQ1cajlqDbqc3vHeUpO2u4iabDfKg9gJatVQcjCFqTPWrac6ki5aXuR9ZAT3tVI7axjCFUjnQjMHmNQUQkKkKW9b1Mc88pbQai(H94ea3bUIrO34aetWUYsviH7dQnf45FcaDfKWVWqoQx1jCh4QTomCb(fgYr9QovaeJmTjyxxWRkKW9b1Mc88pbGUcsyaY4BG0y4oWvU8u7LAzEJJamfQL9tyqT1HHlWaKX3aPXkaIrM2eSRl4fkgHEJdqmNUEPkKW9b1Mc88pbGUcYxUfTxm14oWvmc9ghGyovX2sOUfWi7Nkbuq4lc94Dju3cyK9tfyDaobvt8d4DPkKW9b1Mc88pbGUcsaIFypobuHeUpO2uGN)ja0vqYbIPw7N1AVNEf3bU6cJqVXbiMtv4NnwSC5P2lCGyQNEvZ4iatHAz)eglwc3NBsJAIziZPk2pd1Tagz)ujGccFrOh)lH6waJSFQaRdWjOAIF4A2uHeUpO2uGN)ja0vqc)cd5OEvNuHeUpO2uGN)ja0vq6iNy0yeJtaCuHuHeUpO2uqlOMavae)WECcG7axXi0BCaIjybYgu(WqbBLJLE6zca]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Enhancement",
    } )
end
