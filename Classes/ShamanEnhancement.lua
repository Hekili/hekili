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
            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',
            value = 5
        },

        offhand = {
            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = 'offhand_speed',
            value = 5
        },

        fury_of_air = {
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

        ls_overcharge = {
            aura = "lightning_shield_overcharge",

            last = function ()
                local app = state.buff.lightning_shield_overcharge.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10
        }
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

        ember_totem = {
            id = 262399,
            duration = 120,
            max_stack =1 ,
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

        gathering_storms = {
            id = 198300,
            duration = 12,
            max_stack = 1,
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
            max_stack = 20,
        },

        lightning_shield_overcharge = {
            id = 273323,
            duration = 10,
            max_stack = 1,
        },

        molten_weapon = {
            id = 271924,
            duration = 4,
        },

        resonance_totem = {
            id = 262417,
            duration = 120,
            max_stack =1 ,
        },

        shock_of_the_twisting_nether = {
            id = 207999,
            duration = 8,
        },

        storm_totem = {
            id = 262397,
            duration = 120,
            max_stack =1 ,
        },

        stormbringer = {
            id = 201846,
            duration = 12,
            max_stack = 1,
        },

        tailwind_totem = {
            id = 262400,
            duration = 120,
            max_stack =1 ,
        },
        
        totem_mastery = {
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        expires = cast + duration
                        remains = expires - now
                        break
                    end
                end

                local up = buff.resonance_totem.up and remains > 0

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
        },


        -- Azerite Powers
        lightning_conduit = {
            id = 275391,
            duration = 60,
            max_stack = 1
        },
    } )


    spec:RegisterStateTable( 'feral_spirit', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.feral_spirit.lastCast or 0
                return t.cast_time
            elseif k == 'active' or k == 'up' then
                return query_time < t.cast_time + 15
            elseif k == 'remains' then
                return max( 0, t.cast_time + 15 - query_time )
            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'twisting_nether', setmetatable( { onReset = function( self ) end }, { 
        __index = function( t, k )
            if k == 'count' then
                return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
            end
            
            return 0
        end 
    } ) )


    spec:RegisterGear( 'waycrest_legacy', 158362, 159631 )
    spec:RegisterGear( 'electric_mail', 161031, 161034, 161032, 161033, 161035 )

    spec:RegisterGear( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( 'force_of_the_mountain', {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( 'exposed_elements', {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( 'tier20', 147175, 147176, 147177, 147178, 147179, 147180 )
        spec:RegisterAura( "lightning_crash", {
            id = 242284,
            duration = 16
        } )
        spec:RegisterAura( "crashing_lightning", {
            id = 242286,
            duration = 16,
            max_stack = 15
        } )

    spec:RegisterGear( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
    spec:RegisterGear( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )
    


    spec:RegisterGear( 'akainus_absolute_justice', 137084 )
    spec:RegisterGear( 'emalons_charged_core', 137616 )
    spec:RegisterGear( 'eye_of_the_twisting_nether', 137050 )
        spec:RegisterAura( "fire_of_the_twisting_nether", {
            id = 207995,
            duration = 8 
        } )
        spec:RegisterAura( "chill_of_the_twisting_nether", {
            id = 207998,
            duration = 8 
        } )
        spec:RegisterAura( "shock_of_the_twisting_nether", {
            id = 207999,
            duration = 8 
        } )

    spec:RegisterGear( 'smoldering_heart', 151819 )
    spec:RegisterGear( 'soul_of_the_farseer', 151647 )
    spec:RegisterGear( 'spiritual_journey', 138117 )
    spec:RegisterGear( 'storm_tempests', 137103 )
    spec:RegisterGear( 'uncertain_reminder', 143732 )

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
                    applyBuff( "gathering_storms" )
                end

                removeBuff( 'crashing_lightning' )
                
                if level < 116 then 
                    if equipped.emalons_charged_core and spell_targets.crash_lightning >= 3 then
                        applyBuff( 'emalons_charged_core', 10 )
                    end

                    if set_bonus.tier20_2pc > 1 then
                        applyBuff( 'lightning_crash' )
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

            toggle = "defensives",            
            
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

            startsCombat = true,

            handler = function ()
                applyBuff( 'flametongue', 16 + min( 4.8, buff.flametongue.remains ) )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether', 8 )
                end
            end,
        },


        frostbrand = {
            id = 196834,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = 'maelstrom',

            startsCombat = true,

            handler = function ()
                applyBuff( 'frostbrand', 16 + min( 4.8, buff.frostbrand.remains ) )
                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'chill_of_the_twisting_nether', 8 )
                end
            end,
        },


        fury_of_air = {
            id = 197211,
            cast = 0,
            cooldown = 0,
            gcd = function( x )
                if buff.fury_of_air.up then return 'off' end
                return "spell"
            end,

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
                if level < 116 and equipped.eye_of_the_twisting_nether then
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
                if level < 116 and equipped.eye_of_the_twisting_nether then
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
            essential = true,
        
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
                if level < 116 and equipped.eye_of_the_twisting_nether then
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
                if buff.ascendance.up then return 3 * haste end
                return 9 * haste
            end,
            gcd = "spell",

            spend = function()
                if buff.stormbringer.up then return 0 end
                if buff.ascendance.up then return 10 end
                return 30
            end,

            spendType = 'maelstrom',

            startsCombat = true,
            texture = 132314,

            cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,

            usable = function() return buff.ascendance.down end,
            handler = function ()
                if buff.lightning_shield.up then
                    addStack( "lightning_shield", 3600, 2 )
                    if buff.lightning_shield.stack >= 20 then
                        applyBuff( "lightning_shield" )
                        applyBuff( "lightning_shield_overcharge" )
                    end
                end

                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                removeBuff( 'stormbringer' )
                removeBuff( "gathering_storms" )

                if azerite.lightning_conduit.enabled then
                    applyDebuff( "target", "lightning_conduit" )
                end

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end
    
                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
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

            handler = function () if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( 'shock_of_the_twisting_nether' ) end end,
        },


        totem_mastery = {
            id = 262395,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            talent = "totem_mastery",
            essential = true,

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
            cooldown = function() return buff.stormbringer.up and 0 or ( 3 * haste ) end,
            gcd = "spell",

            spend = function() return buff.stormbringer.up and 0 or 10 end,
            spendType = "maelstrom",
            
            texture = 1029585,

            known = 17364,
            usable = function () return buff.ascendance.up end,
            handler = function ()
                setCooldown( 'stormstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                removeBuff( 'stormbringer' )
                removeBuff( "gathering_storms" )

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end
    
                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "battle_potion_of_agility",
        
        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20180930.2220, [[dCehWaqiPqpsvb2eL0NuvigLQkNsvvRIsu5vOkMfLWTqvc7IQ(LuYWqbhdf1YqjEgQsnnQu5AkkBtvr9nPaJJkvDouLO1rjkMhQs6EQs7tr1bvviTquKhsLYfvvO(OQckDskrPwPu0mvvqv7uvPFQQidvkOLsjQ6Ps1uLsDvkrj9vvfuSxL(lLAWuCyIfRWJrmzvCzOnRsFwvmAf50sEnk0SbUnQSBHFtYWPsoUQcQSCqpNutx01PITJs9DkrgpLOeNhL06vvqMpQQ9J0lZB7TFKe3VSWaZUNbEjVzWZclSWWSpV9Kvx42DjegLhC7HWHB)JJjjiihg52DjScuYzBVDTYbsWTpLPlTLPvRNkNCgEIIRLU4CaswQGaLB2sxCKwdGA0ACfEXbz3YfuDlaQB1UqilS0QnlSy3NeojS)4ysccYHr61fhz7dNcKw2Xo2(rsC)Ycdm7Eg4L8MbplSWcdZ2U2fs2VS8zEV9P6CWyhB)GAY2)aQ5JJjjiihgj10NeojOn)aQzktxAltRwpvo5m8efxlDX5aKSubbk3SLU4iTga1O14k8IdYULlO6wau3QHq0Yl1r3QHwE7(KWjH9hhtsqqomsVU4i0MFa10rxjYnqi1WBgSGAyHbMDp1WlOgwyXYWadBhu6uVT3orbXT9(L5T92Xqga8SmTDcSsewY2zlWsga0FDGS62esyKLzBxizPITJcmNWWw7Qye3C)YY2E7yidaEwM2obwjclz7cjl2OngixHAQz(l1W7TlKSuX21oXbHv8S5(L3B7TJHma4zzA7cjlvSDDQGC6ewmIBNaReHLSD5dHWkrpOEMYOIhBIkoov6Xqga8qnwPMgPMdoCUxpOEMYOIhBIkoov6DCrnwPgHKfB0gdKRqn1mNAyMASsn)OMHZ961PcYnGv8GqVJlQHpFQ5h1WwGLmaO)tU1qLc0agOgRudBbwYaG(RdKv3MqcJ8Eg18NA(VDcReaANc8bt9(L5n3VUBBVDmKbapltBNaReHLS9HZ961PcYnGv8GqVJlQHpFQ5h1mCUx)JKtiSIhBDQGCAVJlQXk1WwGLmaO)tU1qLc0agOgRudBbwYaG(RdKv3MqcJ8Eg18F7cjlvSDDQGC6ewmIBUFNTT3ogYaGNLPTtGvIWs2UqYInAJbYvOMAM)sn8MASsnSfyjda6VoqwDBcjmYYSTlKSuX2jqrpzdQNPmQ4zZ97N32BhdzaWZY02jWkryjBpfagPxXgHKjb(GEmKbapuJvQrizXgTXa5kutnVudZuJvQHTalzaq)1bYQBtiHr3nJASsnCcc0juXrnZFPg3XW2fswQy7G6zkJkEShkqU5(TbB7TJHma4zzA7eyLiSKTZwGLmaO)tU1qLc0agOgRudBbwYaG(RdKv3MqcJ8E22fswQy76ub50jSye3C)6(T92fswQy7AN4GWkE2ogYaGNLPn3V8YT92Xqga8SmTDcSsewY2tbGr6VkibVoaBlvXr7Xqga8qnwPgHKfB0gdKRqn1mNAyMASsnSfyjda6VoqwDBcjmYYSTlKSuX2jqrpzdQNPmQ4zZ9lZmST3ogYaGNLPTtGvIWs2EkamsVgfyfp2IwloG0JHma4z7cjlvS9lq4Wufpo4M7xMzEBVDmKbapltBNaReHLS9uayK(jvApjXXJHma4HASsndN71pPs7jjoEikKC7cjlvSDGWwSbIEAZ9lZSST3ogYaGNLPTtGvIWs2UqYInAJbYvOMAMtnmtnwPg2cSKba9xhiRUnHegzz22fswQy7eOONSb1Zugv8S5MBx5cdeUT3VmVT3ogYaGNLPTtGvIWs2oNGaDcvCudVsnmpJASsnzXHudVsnpKZ2fswQy7qfHXrLiCZn3(bVIdi327xM32BxizPITBPko26juGBhdzaWZY0M7xw22BhdzaWZY02zlahC7)OMgPMuayK(RdKvB11wkOhdzaWd1WNp18JAsbGr6VoqwTvxBPGEmKbapuJvQHtqGoHkoQzo14UzuZFQ5)2fswQy7SfyjdaUD2c0oeoC7xhiRUnHegD3Sn3V8EBVDmKbapltBNTaCWT)JAAKAsbGr6VoqwTvxBPGEmKbapudF(uZpQjfagP)6az1wDTLc6Xqga8qnwPgobb6eQ4OM5udVNrn)PM)BxizPITZwGLma42zlq7q4WTFDGS62esyK3Z2C)6UT92Xqga8SmTD2cWb3(pQPrQjfagP)6az1wDTLc6Xqga8qn85tn)OMuayK(RdKvB11wkOhdzaWd1yLA4eeOtOIJAMtnSmJA(tn)3UqYsfBNTalzaWTZwG2HWHB)6az1TjKWilZ2C)oBBVDmKbapltBNTaCWT)JAAKAsbGr6vSrizsGpOhdzaWd1WNp1iKSyJ2yGCfQPM5udZudF(uZpQjfagPxXgHKjb(GEmKbapuJvQrizXgTXa5kutnVudZuJvQ5h1qukWrzPWdQNPmQ4XEOaPhICsfAQz(l1Wc1y5OMhYHA4ZNA4eeOtOIJAMtnUNbQ5p18NA(VDHKLk2oBbwYaGBNTaTdHd3(NCRHkfW9mS5(9ZB7TJHma4zzA7SfGdU9FutJutkamsVIncjtc8b9yidaEOg(8PgHKfB0gdKRqn1mNAyMA4ZNA(rnPaWi9k2iKmjWh0JHma4HASsncjl2OngixHAQ5LAyMASsn)OgIsboklfEq9mLrfp2dfi9qKtQqtnZFPgwOglh18qoudF(udNGaDcvCuZCQPbmqn)PM)uZ)TlKSuX2zlWsgaC7SfODiC42)KBnuPanGHn3VnyBVDmKbapltBNTaCWT)JAAKAsbGr6vSrizsGpOhdzaWd1WNp1iKSyJ2yGCfQPM5udZudF(uZpQjfagPxXgHKjb(GEmKbapuJvQrizXgTXa5kutnVudZuJvQ5h1qukWrzPWdQNPmQ4XEOaPhICsfAQz(l1Wc1y5OMhYHA4ZNA4eeOtOIJAMtnFMbQ5p18NA(VDHKLk2oBbwYaGBNTaTdHd3(NCRHkf4ZmS5(19B7TlKSuX2fNuzlzkeg3ogYaGNLPn3V8YT92fswQy7oA0UsKtVDmKbapltBUFzMHT92Xqga8SmTDHKLk2oraaBHKLkSbLo3oO0PDiC42vUWaHBUFzM5T92Xqga8SmTDcSsewY2ho3Rx0emosqqVJRTlKSuX2jcaylKSuHnO052bLoTdHd3UOjBUFzMLT92Xqga8SmTDHKLk2oraaBHKLkSbLo3oO0PDiC42ho3REZ9lZ8EBVDmKbapltBxizPITteaWwizPcBqPZTdkDAhchUDYrV5(Lz3TT3ogYaGNLPTlKSuX2jcaylKSuHnO052bLoTdHd3orbXn3VmpBBVDmKbapltBxizPITteaWwizPcBqPZTdkDAhchU9BbaiCZn3UlisuCdj327xM32BhdzaWZY0M7xw22BhdzaWZY0M7xEVT3ogYaGNLPn3VUBBVDmKbapltBUFNTT3UqYsfB3LklvSDmKbapltBUF)82E7cjlvS9uLiNnNOteY62Xqga8SmT5(TbB7TlKSuX2b1Zugv8yRNkeC2ogYaGNLPn3C73caq42E)Y82E7yidaEwM2obwjclz7Ccc0juXrn8k10ag2UqYsfBhQimoQeHBUFzzBVDmKbapltBNaReHLS9uayKEcu0tv8yRtfKZJHma4HASsnSfyjda6)KBnuPaFMHTlKSuX2jqrpzdQNPmQ4zZ9lV32BhdzaWZY02jWkryjBNTalzaq)NCRHkfW9mqnwPg2cSKba9xhiRUnHegD3STlKSuX2bcBXgi6Pn3VUBBVDHKLk2ouryCujc3ogYaGNLPn3VZ22BxizPITFbchMQ4Xb3ogYaGNLPn3C7dN7vVT3VmVT3ogYaGNLPTtGvIWs2EJuZW5E9eOONSb1Zugv84DCrnwPgHKfB0gdKRqn1mNAyMASsnSfyjda6VoqwDBcjmYYSTlKSuX2jqrpzdQNPmQ4zZ9llB7TJHma4zzA7eyLiSKTNcaJ0dK4Ob1b9yidaEOgRutJuZW5E9ajoAqDqVJlQXk1qMe4dQTVqHKLkea1mNAy23GTlKSuX2HkcJJkr4M7xEVT3ogYaGNLPTtGvIWs2EJutwegR4HASsnCcc0juXrnZFPgwyy7cjlvS9RdKvB11wk4M7x3TT3ogYaGNLPTtGvIWs2EJuZW5E9xGWHPkECqVJRTlKSuX2VaHdtv84GBUFNTT3ogYaGNLPTtGvIWs2Ekams)KuaDQGCEmKbapuJvQPrQz4CV(luPZbuIJ3Xf1yLAylWsga0FDGS62esyKLzBxizPITFHkDoGsC2C)(5T92Xqga8SmTDcSsewY2ho3R)ceomvXJd6HiNuHMA4vQXDE3tn8qnpKZ2fswQy7xGWHPkECWn3VnyBVDmKbapltBNaReHLS9uayK(jPa6ub58yidaEOgRuZW5E9xOsNdOehpe5Kk0udVsnUZ7EQHhQ5HCOgRudBbwYaG(RdKv3MqcJSmB7cjlvS9luPZbuIZM7x3VT3ogYaGNLPTtGvIWs2(W5E9quRcjiODQsKZdroPcn1WRudlBxizPITNQe5S5eDIqw3CZTto6T9(L5T92Xqga8SJTtGvIWs2U8HqyLOxccQtOaSHOwfsqqpgYaGNTlKSuX2haL6aC05M7xw22BhdzaWZY02jWkryjB)h1KcaJ0lAcghjiOhdzaWd1yLAgo3Rx0emosqqVJlQ5p1WNp18JAsbGr6raYHrkaBTRcwP2JHma4HASsnxekaBTRcwPhICsfAQzo1mJA(tn85tn)OMgPMuayKErtW4ibb9yidaEOgRutJutkamspcqomsbyRDvWk1EmKbapuZ)TlKSuX2hiuJqgR4zZ9lV32BhdzaWZY02jWkryjB)h1KcaJ0lAcghjiOhdzaWd1yLA(rndN71lAcghjiO3Xf1WNp1qukWrzPWlAcghjiOhICsfAQzo1mJbQ5p18NA4ZNA(rnnsnPaWi9IMGXrcc6Xqga8qnwPMFuZfHcWw7QGv6HiNuHMAMtnZOg(8PgIsboklf(lcfGT2vbR0droPcn1mNAMXa18NA(VDHKLk2(aOuh7RdK1n3VUBBVDmKbapltBNaReHLS9FutkamsVOjyCKGGEmKbapuJvQ5h1mCUxVOjyCKGGEhxudF(udrPahLLcVOjyCKGGEiYjvOPM5uZmgOM)uZFQHpFQ5h10i1KcaJ0lAcghjiOhdzaWd1yLA(rnxekaBTRcwPhICsfAQzo1mJA4ZNAikf4OSu4Viua2AxfSspe5Kk0uZCQzgduZFQ5)2fswQy73cIdGsD2C)oBBVDmKbapltBNaReHLS9FutkamsVOjyCKGGEmKbapuJvQ5h1mCUxVOjyCKGGEhxudF(udrPahLLcVOjyCKGGEiYjvOPM5uZmgOM)uZFQHpFQ5h10i1KcaJ0lAcghjiOhdzaWd1yLA(rnxekaBTRcwPhICsfAQzo1mJA4ZNAikf4OSu4Viua2AxfSspe5Kk0uZCQzgduZFQ5)2fswQy7sqqDcfGnraGn3VFEBVDmKbapltBNaReHLS9HZ96fnbJJee074IA4ZNAAKAsbGr6fnbJJee0JHma4HASsnxekaBTRcwPhICsfAQzo1mJA4ZNAsb(GPplo0ov2NcPgE9LA(mdBxizPIT7sLLk2C)2GT92fswQy7xekaBTRcw52Xqga8SmT5(19B7TJHma4zzA7eyLiSKTtukWrzPWRtyXi6HiNuHMAMtnmSDHKLk2UOjyCKGGBUF5LB7TlKSuX2rbMt2ia5WifW2Xqga8SmT5MBx0KT9(L5T92Xqga8SmTDcSsewY2BKAgo3RNaf9KnOEMYOIhVJlQXk1iKSyJ2yGCfQPM5udZuJvQHTalzaq)1bYQBtiHrwMTDHKLk2obk6jBq9mLrfpBUFzzBVDmKbapltBNaReHLS9uayKEGehnOoOhdzaWd1yLAAKAgo3RhiXrdQd6DCrnwPgYKaFqT9fkKSuHaOM5udZ(gSDHKLk2ouryCujc3C)Y7T92fswQy7wQIJoHfJ42Xqga8SmT5MBUD2iuxQy)Ycdm7Eg4Lm)zpdmWmVC7wsGrfp6T)H5JA5)Az)9dRLHAOM2ti1uCUuWKAUki18ro4vCa5hHAG4hoNcIhQrR4qQrCsfNK4HAits8GApT5h(kqQX9wgQXYAODC5sbt8qncjlvqnFeXjv2sMcHXpIN2K20YMZLcM4HACp1iKSub1akDQ90MBxCYjfC79IZbizPc3GYn3UlO6waC7Fa18XXKeeKdJKA6tcNe0MFa1mLPlTLPvRNkNCgEIIRLU4CaswQGaLB2sxCKwdGA0ACfEXbz3YfuDlaQB1qiA5L6OB1qlVDFs4KW(JJjjiihgPxxCeAZpGA6ORe5giKA4ndwqnSWaZUNA4fudlSyzyGbAtAZpGA(ylliXjXd1mWRcIudrXnKKAg4tfAp18rje0vQPMqf8IjbYDDauJqYsfAQrfaw90McjlvO9UGirXnK89cenJ0McjlvO9UGirXnKKN3wxL6qBkKSuH27cIef3qsEEBjopCyKswQG28dOMEiU0tQKAGsDOMHZ9IhQrNsQPMbEvqKAikUHKuZaFQqtnsCOgxqKx4sLzfputPPMJkqpTPqYsfAVlisuCdj55TLoex6jvARtj10McjlvO9UGirXnKKN3wUuzPcAtHKLk0ExqKO4gsYZBRuLiNnNOteYkTPqYsfAVlisuCdj55TfOEMYOIhB9uHGdTjT5hqnFSLfK4K4HAq2iKvQjloKAYjKAesQGutPPgHTuazaqpTPqYsf6xlvXXwpHcK2uizPcnpVTylWsga0Iq4W3RdKv3MqcJUBMfSfGd((RXuayK(RdKvB11wkOhdzaWdF()sbGr6VoqwTvxBPGEmKbapw5eeOtOIBU7M9)pTPqYsfAEEBXwGLmaOfHWHVxhiRUnHeg59mlylah89xJPaWi9xhiR2QRTuqpgYaGh(8)LcaJ0FDGSARU2sb9yidaESYjiqNqf3CEp7)FAtHKLk0882ITalzaqlcHdFVoqwDBcjmYYmlylah89xJPaWi9xhiR2QRTuqpgYaGh(8)LcaJ0FDGSARU2sb9yidaESYjiqNqf3CwM9)pTPqYsfAEEBXwGLmaOfHWHVFYTgQua3ZGfSfGd((RXuayKEfBesMe4d6Xqga8WNVqYInAJbYvOEoZ85)lfagPxXgHKjb(GEmKbapwfswSrBmqUc1VmB9hrPahLLcpOEMYOIh7HcKEiYjvON)YIL7HC4ZNtqGoHkU5UNH)))tBkKSuHMN3wSfyjdaAriC47NCRHkfObmybBb4GV)AmfagPxXgHKjb(GEmKbap85lKSyJ2yGCfQNZmF()sbGr6vSrizsGpOhdzaWJvHKfB0gdKRq9lZw)rukWrzPWdQNPmQ4XEOaPhICsf65VSy5Eih(85eeOtOIBEdy4)))0McjlvO55TfBbwYaGwech((j3AOsb(mdwWwao47VgtbGr6vSrizsGpOhdzaWdF(cjl2OngixH65mZN)VuayKEfBesMe4d6Xqga8yvizXgTXa5ku)YS1FeLcCuwk8G6zkJkEShkq6HiNuHE(llwUhYHpFobb6eQ4M)zg())pTPqYsfAEEBjoPYwYuimsBkKSuHMN3woA0UsKttBkKSuHMN3webaSfswQWgu60Iq4WxLlmqiTPqYsfAEEBreaWwizPcBqPtlcHdFfnXI6(oCUxVOjyCKGGEhx0McjlvO55TfraaBHKLkSbLoTieo8D4CVAAtHKLk0882IiaGTqYsf2GsNwech(soAAtHKLk0882IiaGTqYsf2GsNwech(suqK2uizPcnpVTicaylKSuHnO0PfHWHV3caqiTjTPqYsfAVOjVeOONSb1Zugv8yrDFBC4CVEcu0t2G6zkJkE8oUSkKSyJ2yGCfQNZSv2cSKba9xhiRUnHegzzgTPqYsfAVOj882cQimoQeHwu33uayKEGehnOoOhdzaWJ1gho3RhiXrdQd6DCzLmjWhuBFHcjlviG5m7BaTPqYsfAVOj882YsvC0jSyePnPnfswQq7ho3R(Laf9KnOEMYOIhlQ7BJdN71tGIEYguptzuXJ3XLvHKfB0gdKRq9CMTYwGLmaO)6az1TjKWilZOnfswQq7ho3RMN3wqfHXrLi0I6(McaJ0dK4Ob1b9yidaES24W5E9ajoAqDqVJlRKjb(GA7luizPcbmNzFdOnfswQq7ho3RMN3wxhiR2QRTuqlQ7BJzrySIhRCcc0juXn)LfgOnfswQq7ho3RMN3wxGWHPkECqlQ7BJdN71FbchMQ4Xb9oUOnfswQq7ho3RMN3wxOsNdOehlQ7Bkams)KuaDQGCEmKbapwBC4CV(luPZbuIJ3XLv2cSKba9xhiRUnHegzzgTPqYsfA)W5E18826ceomvXJdArDFho3R)ceomvXJd6HiNuHMxDN3988qo0McjlvO9dN7vZZBRluPZbuIJf19nfagPFskGovqopgYaGhRdN71FHkDoGsC8qKtQqZRUZ7EEEihRSfyjda6VoqwDBcjmYYmAtHKLk0(HZ9Q55TvQsKZMt0jcz1I6(oCUxpe1QqccANQe58qKtQqZRSqBsB(buJBIoPgMak1b4OtQHtchbayLAQl1Kti18r)qiSsKAAdLkPMpAqqDcfa1y5rTkKGGutPPgxquJr6PnfswQq7jh97aOuhGJoTOUVYhcHvIEjiOoHcWgIAvibb9yidaEOnfswQq7jhnpVTgiuJqgR4XI6((lfagPx0emosqqpgYaGhRdN71lAcghjiO3X1F(8)LcaJ0JaKdJua2AxfSsThdzaWJ1lcfGT2vbR0droPc98z)5Z)xJPaWi9IMGXrcc6Xqga8yTXuayKEeGCyKcWw7QGvQ9yidaE(tBkKSuH2toAEEBnak1X(6az1I6((lfagPx0emosqqpgYaGhR)go3Rx0emosqqVJl(8jkf4OSu4fnbJJee0droPc98zm8)pF()AmfagPx0emosqqpgYaGhR)Uiua2AxfSspe5Kk0ZNXNprPahLLc)fHcWw7QGv6HiNuHE(mg()N2uizPcTNC08826wqCauQJf199xkamsVOjyCKGGEmKbapw)nCUxVOjyCKGGEhx85tukWrzPWlAcghjiOhICsf65Zy4)F(8)1ykamsVOjyCKGGEmKbapw)DrOaS1UkyLEiYjvONpJpFIsboklf(lcfGT2vbR0droPc98zm8)pTPqYsfAp5O55TLeeuNqbyteaWI6((lfagPx0emosqqpgYaGhR)go3Rx0emosqqVJl(8jkf4OSu4fnbJJee0droPc98zm8)pF()AmfagPx0emosqqpgYaGhR)Uiua2AxfSspe5Kk0ZNXNprPahLLc)fHcWw7QGv6HiNuHE(mg()N2uizPcTNC0882YLklvyrDFho3Rx0emosqqVJl(8BmfagPx0emosqqpgYaGhRxekaBTRcwPhICsf65Z4Zpf4dM(S4q7uzFkKxF)md0McjlvO9KJMN3wxekaBTRcwjTPqYsfAp5O55TLOjyCKGGwu3xIsboklfEDclgrpe5Kk0ZzG2uizPcTNC0882cfyozJaKdJua0M0McjlvO9efeFrbMtyyRDvmIwu3x2cSKba9xhiRUnHegzzgTPqYsfAprbrEEBPDIdcR4XI6(kKSyJ2yGCfQN)YBAtHKLk0EIcI882sNkiNoHfJOfewja0of4dM6xMTOUVYhcHvIEq9mLrfp2evCCQ0JHma4XAJhC4CVEq9mLrfp2evCCQ074YQqYInAJbYvOEoZw)nCUxVovqUbSIhe6DCXN)p2cSKba9FYTgQuGgWGv2cSKba9xhiRUnHeg59S))PnfswQq7jkiYZBlDQGC6ewmIwu33HZ961PcYnGv8GqVJl(8)nCUx)JKtiSIhBDQGCAVJlRSfyjda6)KBnuPanGbRSfyjda6VoqwDBcjmY7z)PnfswQq7jkiYZBlcu0t2G6zkJkESOUVcjl2OngixH65V82kBbwYaG(RdKv3MqcJSmJ2uizPcTNOGipVTa1Zugv8ypuG0I6(McaJ0RyJqYKaFqpgYaGhRcjl2OngixH6xMTYwGLmaO)6az1TjKWO7MzLtqGoHkU5VUJbAtHKLk0EIcI882sNkiNoHfJOf19LTalzaq)NCRHkfObmyLTalzaq)1bYQBtiHrEpJ2uizPcTNOGipVT0oXbHv8qBkKSuH2tuqKN3weOONSb1Zugv8yrDFtbGr6VkibVoaBlvXr7Xqga8yvizXgTXa5kupNzRSfyjda6VoqwDBcjmYYmAtHKLk0EIcI8826ceomvXJdArDFtbGr61OaR4Xw0AXbKEmKbap0McjlvO9efe55Tfqyl2arpzrDFtbGr6NuP9KehpgYaGhRdN71pPs7jjoEikKK2uizPcTNOGipVTiqrpzdQNPmQ4XI6(kKSyJ2yGCfQNZSv2cSKba9xhiRUnHegzzgTjTPqYsfA)Taae(cveghvIqlQ7lNGaDcvC8AdyG2uizPcT)waac55Tfbk6jBq9mLrfpwu33uayKEcu0tv8yRtfKZJHma4XkBbwYaG(p5wdvkWNzG2uizPcT)waac55Tfqyl2arpzrDFzlWsga0)j3AOsbCpdwzlWsga0FDGS62esy0DZOnfswQq7VfaGqEEBbveghvIqAtHKLk0(BbaiKN3wxGWHPkECqAtAtHKLk0ELlmq4luryCujcTOUVCcc0juXXRmpZAwCiV(qoBU5U]] )


end
