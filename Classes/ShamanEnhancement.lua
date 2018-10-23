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

        strength_of_earth = {
            id = 273465,
            duration = 10,
            max_stack = 1,
        }
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

                removeBuff( "strength_of_earth" )
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

                removeBuff( "strength_of_earth" )
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

                if azerite.strength_of_earth.enabled then applyBuff( "strength_of_earth" ) end
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

                removeBuff( "strength_of_earth" )

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

                removeBuff( "strength_of_earth" )

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


    spec:RegisterPack( "Enhancement", 20181022.2129, [[dGKwWaqiPqpsrr2eL0NuuunkuWPuv1QOePEfjXSOeUfkvYUOQFjLmmsshdfzzQIEgLOMMuGRPkSnuQ4BuPQXjf05uuO1HsLAEuI4EQk7tr1bvuQSquupKkLlQOu(OIsvDsffWkLIMPIcKBQOO0ovv5NkkzOuPYsPejpvQMQuQRQOOWxvuGAVk9xk1GP4WelwHhJyYQ4YqBwL(SQ0OvKtl51OqZg42Ky3c)gvdNk54kkkA5GEoPMUORtfBhL8DuQA8kkv58OuwVIcA(Ku7hPxM22B)ijU)EQktnKjvF(0)KPNZ4t2z7jBUWT7simkV42drb3(SftsqqfmYT7sydWLZ2E7AUdKGBFktxA2DRwVvo5m8eUslDP4aKS4bbk3SLUuiTga(O14kSRdYQLli)wau3QDHWNpB1(5t7(KOiH9SftsqqfmsVUuiBF4uGCgi2X2psI7VNQYudzs1Np9pz65m(8X2fNCId3EVuCasw8WnOCZTpvNdg7y7hut2(mrnZwmjbbvWiPM(KOibT5mrntz6sZUB16TYjNHNWvAPlfhGKfpiq5MT0LcP1aWhTgxHDDqwTCb53cG6wUdIwkPo6wUZsz3NefjSNTysccQGr61LcH2CMOMzrs(aHuZZNwqnpvLPgsnSlQzgz3pNrQXDZSBhu6uVT3o3fgiCBV)yABVDmKbaplZBNaReHLSDfbb6eYvOglHAy6b1yLAYsbPglHAEjNTlKS4X2HCcJJkr4MBU9BbaiCBV)yABVDmKbaplZBNaReHLSDfbb6eYvOglHACVQuJvQPrQz4CVEDcX4nNS5xBuG5K3X12fsw8y7qoHXrLiCZ93ZT92Xqga8SmVDcSsewY2tbGr6jqrpvXRTo5qfpgYaGhQXk1WsGLmaOFwU5oohWoQUDHKfp2obk6jBq9oLrfVBU)S82E7yidaEwM3obwjclz7Seyjda6NLBUJZbnuvQXk1WsGLmaO)6azZTjKWydESDHKfp2oqyj2arpT5(RbB7TlKS4X2HCcJJkr42Xqga8SmV5(7X2E7cjlES9lquWKhVo42Xqga8SmV5MB)GxXbKB79htB7TlKS4X2zFfhB9ekWTJHma4zzEZ93ZT92Xqga8SmVDwcWb3odutJutkams)1bYMn)Alf0JHma4HAuRMAyGAsbGr6Voq2S5xBPGEmKbapuJvQrrqGoHCfQzo10GhuZFQ5)2fsw8y7SeyjdaUDwc0oefC7xhiBUnHegBWJn3FwEBVDmKbaplZBNLaCWTZa10i1KcaJ0FDGSzZV2sb9yidaEOg1QPggOMuayK(RdKnB(1wkOhdzaWd1yLAueeOtixHAMtnw(b18NA(VDHKfp2olbwYaGBNLaTdrb3(1bYMBtiHrl)yZ9xd22BhdzaWZY82zjahC7mqnnsnPaWi9xhiB28RTuqpgYaGhQrTAQHbQjfagP)6azZMFTLc6Xqga8qnwPgfbb6eYvOM5uZZhuZFQ5)2fsw8y7SeyjdaUDwc0oefC7xhiBUnHegF(yZ93JT92Xqga8SmVDwcWb3odutJutkamspNfcjtc8f9yidaEOg1QPgHKfl0gduPqn1mNAyIAuRMAyGAsbGr65SqizsGVOhdzaWd1yLAeswSqBmqLc1uZh1We1yLAyGAiCo4WzF4b17ugv8Ap4G0drfPcn1m)JAEsnwAQ5LCOg1QPgfbb6eYvOM5utdvLA(tn)PM)BxizXJTZsGLma42zjq7quWTpl3ChNdAOQBU)yNT92Xqga8SmVDwcWb3odutJutkamspNfcjtc8f9yidaEOg1QPgHKfl0gduPqn1mNAyIAuRMAyGAsbGr65SqizsGVOhdzaWd1yLAeswSqBmqLc1uZh1We1yLAyGAiCo4WzF4b17ugv8Ap4G0drfPcn1m)JAEsnwAQ5LCOg1QPgfbb6eYvOM5uJ7vLA(tn)PM)BxizXJTZsGLma42zjq7quWTpl3ChNdCVQBU)C)2E7yidaEwM3olb4GBNbQPrQjfagPNZcHKjb(IEmKbapuJA1uJqYIfAJbQuOMAMtnmrnQvtnmqnPaWi9CwiKmjWx0JHma4HASsncjlwOngOsHAQ5JAyIASsnmqneohC4Sp8G6DkJkEThCq6HOIuHMAM)rnpPgln18souJA1uJIGaDc5kuZCQHDuLA(tn)PM)BxizXJTZsGLma42zjq7quWTpl3ChNdyhv3C)1WT92fsw8y7ItYTLmfcJBhdzaWZY8M7VzCBVDHKfp2UJgTRev0BhdzaWZY8M7pMuDBVDmKbaplZBxizXJTteaWwizXdBqPZTdkDAhIcUDUlmq4M7pMyABVDmKbaplZBNaReHLS9HZ96fnbJJee074A7cjlESDIaa2cjlEydkDUDqPt7quWTlAYM7pMEUT3ogYaGNL5TlKS4X2jcaylKS4HnO052bLoTdrb3(W5E1BU)yYYB7TJHma4zzE7cjlESDIaa2cjlEydkDUDqPt7quWTto6n3Fm1GT92Xqga8SmVDHKfp2oraaBHKfpSbLo3oO0PDik42jCiU5(JPhB7TJHma4zzE7cjlESDIaa2cjlEydkDUDqPt7quWTFlaaHBU52Dbrcxzi52E)X02E7yidaEwM3C)9CBVDmKbaplZBU)S82E7yidaEwM3C)1GT92Xqga8SmV5(7X2E7cjlESDx8S4X2Xqga8SmV5(JD22BxizXJTN8evSveDIq22ogYaGNL5n3FUFBVDHKfp2oOENYOIxB9uHGZ2Xqga8SmV5MBNC0B79htB7TJHma4zhBNaReHLSDzgIWkrVeeuNqbydrnpKGGEmKbapBxizXJTpaC(b4OZn3Fp32BhdzaWZY82jWkryjBNbQjfagPx0emosqqpgYaGhQXk1mCUxVOjyCKGGEhxuZFQrTAQHbQjfagPhbOcgPaS1UkyLApgYaGhQXk1CrOaS1UkyLEiQivOPM5uZdQ5p1Own1Wa10i1KcaJ0lAcghjiOhdzaWd1yLAAKAsbGr6raQGrkaBTRcwP2JHma4HA(VDHKfp2(aHAeYyfVBU)S82E7yidaEwM3obwjclz7mqnPaWi9IMGXrcc6Xqga8qnwPggOMHZ96fnbJJee074IAuRMAiCo4WzF4fnbJJee0drfPcn1mNAEOk18NA(tnQvtnmqnnsnPaWi9IMGXrcc6Xqga8qnwPggOMlcfGT2vbR0drfPcn1mNAEqnQvtneohC4Sp8xekaBTRcwPhIksfAQzo18qvQ5p18F7cjlES9bGZp2xhiBBU)AW2E7yidaEwM3obwjclz7mqnPaWi9IMGXrcc6Xqga8qnwPggOMHZ96fnbJJee074IAuRMAiCo4WzF4fnbJJee0drfPcn1mNAEOk18NA(tnQvtnmqnnsnPaWi9IMGXrcc6Xqga8qnwPggOMlcfGT2vbR0drfPcn1mNAEqnQvtneohC4Sp8xekaBTRcwPhIksfAQzo18qvQ5p18F7cjlES9BbXbGZpBU)EST3ogYaGNL5TtGvIWs2odutkamsVOjyCKGGEmKbapuJvQHbQz4CVErtW4ibb9oUOg1QPgcNdoC2hErtW4ibb9qurQqtnZPMhQsn)PM)uJA1uddutJutkamsVOjyCKGGEmKbapuJvQHbQ5IqbyRDvWk9qurQqtnZPMhuJA1udHZbho7d)fHcWw7QGv6HOIuHMAMtnpuLA(tn)3UqYIhBxccQtOaSjcaS5(JD22BhdzaWZY82jWkryjBF4CVErtW4ibb9oUOg1QPMgPMuayKErtW4ibb9yidaEOgRuZfHcWw7QGv6HOIuHMAMtnpOg1QPMuGVy6ZsbTtU9PqQXs(Og2r1TlKS4X2DXZIhBU)C)2E7cjlES9lcfGT2vbRC7yidaEwM3C)1WT92Xqga8SmVDcSsewY2jCo4WzF41jSye9qurQqtnZPgv3UqYIhBx0emosqWn3FZ42E7cjlESDuG5KncqfmsbSDmKbaplZBU52ho3REBV)yABVDmKbaplZBNaReHLS9gPMHZ96jqrpzdQ3PmQ4174IASsncjlwOngOsHAQzo1We1yLAyjWsga0FDGS52esy85JTlKS4X2jqrpzdQ3PmQ4DZ93ZT92Xqga8SmVDcSsewY2tbGr6bsC0G6GEmKbapuJvQPrQz4CVEGehnOoO3Xf1yLAitc8f12xOqYIhcGAMtnm5D)2fsw8y7qoHXrLiCZ9NL32BhdzaWZY82jWkryjBVrQjlcJv8snwPgfbb6eYvOM5FuZtv3UqYIhB)6azZMFTLcU5(RbB7TJHma4zzE7eyLiSKT3i1mCUx)fikyYJxh074A7cjlES9lquWKhVo4M7VhB7TJHma4zzE7eyLiSKTNcaJ0pjfqNCOIhdzaWd1yLAAKAgo3R)c56CaL44DCrnwPgwcSKba9xhiBUnHegF(y7cjlES9lKRZbuIZM7p2zBVDmKbaplZBNaReHLS9HZ96VarbtE86GEiQivOPglHAAGVHuJkuZl5SDHKfp2(fikyYJxhCZ9N732BhdzaWZY82jWkryjBpfagPFskGo5qfpgYaGhQXk1mCUx)fY15akXXdrfPcn1yjutd8nKAuHAEjhQXk1WsGLmaO)6azZTjKW4ZhBxizXJTFHCDoGsC2C)1WT92Xqga8SmVDcSsewY2ho3RhIAEibbTtEIkEiQivOPglHAEUDHKfp2EYtuXwr0jczBZn3UOjB79htB7TJHma4zzE7eyLiSKT3i1mCUxpbk6jBq9oLrfVEhxuJvQrizXcTXavkutnZPgMOgRudlbwYaG(RdKn3MqcJpFSDHKfp2obk6jBq9oLrfVBU)EUT3ogYaGNL5TtGvIWs2EkamspqIJguh0JHma4HASsnnsndN71dK4Ob1b9oUOgRudzsGVO2(cfsw8qauZCQHjV73UqYIhBhYjmoQeHBU)S82E7cjlESD2xXrNWIrC7yidaEwM3CZTt4qCBV)yABVDmKbaplZBNaReHLSDwcSKba9xhiBUnHegF(y7cjlESDuG5eg2AxfJ4M7VNB7TJHma4zzE7eyLiSKTlKSyH2yGkfQPM5FuJL3UqYIhBx7ehewX7M7plVT3ogYaGNL5TlKS4X21jhQOtyXiUDcSsewY2LzicRe9G6DkJkETj844uPhdzaWd1yLAAKAo4W5E9G6DkJkETj844uP3Xf1yLAeswSqBmqLc1uZCQHjQXk1Wa1mCUxVo5qLbSIxe6DCrnQvtnmqnSeyjda6NLBUJZbUxvQXk1WsGLmaO)6azZTjKWOLFqn)PM)BNWgbG2PaFXuV)yAZ9xd22BhdzaWZY82jWkryjBF4CVEDYHkdyfVi074IAuRMAyGAgo3R)vYjewXRTo5qfT3Xf1yLAyjWsga0pl3ChNdCVQuJvQHLalzaq)1bYMBtiHrl)GA(VDHKfp2Uo5qfDclgXn3Fp22BhdzaWZY82jWkryjBxizXcTXavkutnZ)OgltnwPgwcSKba9xhiBUnHegF(y7cjlESDcu0t2G6DkJkE3C)XoB7TJHma4zzE7eyLiSKTNcaJ0ZzHqYKaFrpgYaGhQXk1iKSyH2yGkfQPMpQHjQXk1WsGLmaO)6azZTjKWydEqnwPgfbb6eYvOM5FutduD7cjlESDq9oLrfV2doi3C)5(T92Xqga8SmVDcSsewY2zjWsga0pl3ChNdCVQuJvQHLalzaq)1bYMBtiHrl)y7cjlESDDYHk6ewmIBU)A42E7cjlESDTtCqyfVBhdzaWZY8M7VzCBVDmKbaplZBNaReHLS9uayK(lhsWRdWM9vC0EmKbapuJvQrizXcTXavkutnZPgMOgRudlbwYaG(RdKn3MqcJpFSDHKfp2obk6jBq9oLrfVBU)ys1T92Xqga8SmVDcSsewY2tbGr61OaR41w0AXbKEmKbapBxizXJTFbIcM841b3C)XetB7TJHma4zzE7eyLiSKTNcaJ0pXt7jjoEmKbapuJvQz4CV(jEApjXXdrHKBxizXJTdewInq0tBU)y652E7yidaEwM3obwjclz7cjlwOngOsHAQzo1We1yLAyjWsga0FDGS52esy85JTlKS4X2jqrpzdQ3PmQ4DZn3C7SqOU4X(7PQm1qvNrlRQ)5ZNBN9cmQ4vV9zWZol1VzGFZ(SBQHAApHutP4IdtQ5YHuZm)GxXbKZCQbIZmDkiEOgnxbPgXj5ksIhQHmjXlQ90MZGQaPMgYUPMzgH2XLlomXd1iKS4b1mZfNKBlzkegN5EAtAZzafxCyIhQPHuJqYIhudO0P2tBUDxq(Ta42NjQz2IjjiOcgj10NefjOnNjQzktxA2DRwVvo5m8eUslDP4aKS4bbk3SLUuiTga(O14kSRdYQLli)wau3YDq0sj1r3YDwk7(KOiH9SftsqqfmsVUui0MZe1mlsYhiKAE(0cQ5PQm1qQHDrnZi7(5msnUBML2K2CMOMzB2djojEOMbE5qKAiCLHKuZaFRq7PMzhHGUsn1e8GDnjqLRdGAesw8qtn8aWMN2uizXdT3fejCLHKFxGOzK2uizXdT3fejCLHKQ816Y5hAtHKfp0ExqKWvgsQYxlX5vbJuYIh0MZe10dXLEINuduQd1mCUx8qn6usn1mWlhIudHRmKKAg4BfAQrId14cISlx8mR4LAkn1C4b6Pnfsw8q7DbrcxziPkFT0H4spXtBDkPM2uizXdT3fejCLHKQ81YfplEqBkKS4H27cIeUYqsv(AL8evSveDIq2Onfsw8q7DbrcxziPkFTa17ugv8ARNkeCOnPnNjQz2M9qItIhQbzHq2OMSuqQjNqQrijhsnLMAewsbKba90McjlEO)yFfhB9ekqAtHKfp0Q81ILalzaqlcrb)Uoq2CBcjm2GhwWsao4hdnMcaJ0FDGSzZV2sb9yidaEuRMHuayK(RdKnB(1wkOhdzaWJvfbb6eYvM3Gh))tBkKS4HwLVwSeyjdaArik431bYMBtiHrl)WcwcWb)yOXuayK(RdKnB(1wkOhdzaWJA1mKcaJ0FDGSzZV2sb9yidaESQiiqNqUYCl)4)FAtHKfp0Q81ILalzaqlcrb)Uoq2CBcjm(8HfSeGd(XqJPaWi9xhiB28RTuqpgYaGh1QzifagP)6azZMFTLc6Xqga8yvrqGoHCL5pF8)pTPqYIhAv(AXsGLmaOfHOGFZYn3X5GgQQfSeGd(XqJPaWi9CwiKmjWx0JHma4rTAHKfl0gduPq9CMuRMHuayKEolesMe4l6Xqga8yvizXcTXavku)XKvgiCo4WzF4b17ugv8Ap4G0drfPc98VNw6xYrTAfbb6eYvM3qv)))pTPqYIhAv(AXsGLmaOfHOGFZYn3X5a3RQfSeGd(XqJPaWi9CwiKmjWx0JHma4rTAHKfl0gduPq9CMuRMHuayKEolesMe4l6Xqga8yvizXcTXavku)XKvgiCo4WzF4b17ugv8Ap4G0drfPc98VNw6xYrTAfbb6eYvM7Ev)))pTPqYIhAv(AXsGLmaOfHOGFZYn3X5a2rvlyjah8JHgtbGr65SqizsGVOhdzaWJA1cjlwOngOsH65mPwndPaWi9CwiKmjWx0JHma4XQqYIfAJbQuO(JjRmq4CWHZ(WdQ3PmQ41EWbPhIksf65FpT0VKJA1kcc0jKRmNDu9)))0McjlEOv5RL4KCBjtHWiTPqYIhAv(A5Or7krfnTPqYIhAv(AreaWwizXdBqPtlcrb)4UWaH0McjlEOv5RfraaBHKfpSbLoTief8t0elQ73W5E9IMGXrcc6DCrBkKS4HwLVwebaSfsw8Wgu60IquWVHZ9QPnfsw8qRYxlIaa2cjlEydkDArik4h5OPnfsw8qRYxlIaa2cjlEydkDArik4hHdrAtHKfp0Q81IiaGTqYIh2GsNweIc(DlaaH0M0McjlEO9IM8rGIEYguVtzuXRf19RXHZ96jqrpzdQ3PmQ4174YQqYIfAJbQuOEotwzjWsga0FDGS52esy85dAtHKfp0Ertu5RfKtyCujcTOUFPaWi9ajoAqDqpgYaGhRnoCUxpqIJguh074YkzsGVO2(cfsw8qaZzY7EAtHKfp0Ertu5Rf7R4OtyXisBsBkKS4H2pCUx9hbk6jBq9oLrfVwu3Vgho3RNaf9KnOENYOIxVJlRcjlwOngOsH65mzLLalzaq)1bYMBtiHXNpOnfsw8q7ho3RwLVwqoHXrLi0I6(LcaJ0dK4Ob1b9yidaES24W5E9ajoAqDqVJlRKjb(IA7luizXdbmNjV7Pnfsw8q7ho3RwLVwxhiB28RTuqlQ7xJzrySIxRkcc0jKRm)7PQ0McjlEO9dN7vRYxRlquWKhVoOf19RXHZ96VarbtE86GEhx0McjlEO9dN7vRYxRlKRZbuIJf19lfagPFskGo5qfpgYaGhRnoCUx)fY15akXX74YklbwYaG(RdKn3MqcJpFqBkKS4H2pCUxTkFTUarbtE86Gwu3VHZ96VarbtE86GEiQivOTKg4BOkVKdTPqYIhA)W5E1Q816c56CaL4yrD)sbGr6NKcOtouXJHma4X6W5E9xixNdOehpevKk0wsd8nuLxYXklbwYaG(RdKn3MqcJpFqBkKS4H2pCUxTkFTsEIk2kIoriBwu3VHZ96HOMhsqq7KNOIhIksfAl5jTjT5mrnUj6KAygW5hGJoPgfjCeaGnQPUutoHuZSBgIWkrQPnuQKAMDbb1juauJLc18qccsnLMACbrngPN2uizXdTNC0FdaNFao60I6(jZqewj6LGG6ekaBiQ5Hee0JHma4H2uizXdTNC0Q81AGqnczSIxlQ7hdPaWi9IMGXrcc6Xqga8yD4CVErtW4ibb9oU(RwndPaWi9iavWifGT2vbRu7Xqga8y9IqbyRDvWk9qurQqp)XF1QzOXuayKErtW4ibb9yidaES2ykamspcqfmsbyRDvWk1EmKbap)Pnfsw8q7jhTkFTgao)yFDGSzrD)yifagPx0emosqqpgYaGhRmmCUxVOjyCKGGEhxQvt4CWHZ(WlAcghjiOhIksf65pu9)F1QzOXuayKErtW4ibb9yidaESYWfHcWw7QGv6HOIuHE(d1QjCo4WzF4Viua2AxfSspevKk0ZFO6))0McjlEO9KJwLVw3cIdaNFSOUFmKcaJ0lAcghjiOhdzaWJvggo3Rx0emosqqVJl1QjCo4WzF4fnbJJee0drfPc98hQ()VA1m0ykamsVOjyCKGGEmKbapwz4IqbyRDvWk9qurQqp)HA1eohC4Sp8xekaBTRcwPhIksf65pu9)FAtHKfp0EYrRYxljiOoHcWMiaGf19JHuayKErtW4ibb9yidaESYWW5E9IMGXrcc6DCPwnHZbho7dVOjyCKGGEiQivON)q1))vRMHgtbGr6fnbJJee0JHma4XkdxekaBTRcwPhIksf65puRMW5GdN9H)IqbyRDvWk9qurQqp)HQ))tBkKS4H2toAv(A5INfpSOUFdN71lAcghjiO3XLA1nMcaJ0lAcghjiOhdzaWJ1lcfGT2vbR0drfPc98hQvNc8ftFwkODYTpfAjFSJQ0McjlEO9KJwLVwxekaBTRcwjTPqYIhAp5Ov5RLOjyCKGGwu3pcNdoC2hEDclgrpevKk0ZvL2uizXdTNC0Q81cfyozJaubJua0M0McjlEO9eoe)qbMtyyRDvmIwu3pwcSKba9xhiBUnHegF(G2uizXdTNWHOkFT0oXbHv8ArD)eswSqBmqLc1Z)SmTPqYIhApHdrv(APtourNWIr0ccBeaANc8ft9htwu3pzgIWkrpOENYOIxBcpoov6Xqga8yTXdoCUxpOENYOIxBcpoov6DCzvizXcTXavkupNjRmmCUxVo5qLbSIxe6DCPwndSeyjda6NLBUJZbUxvRSeyjda6Voq2CBcjmA5h))tBkKS4H2t4quLVw6Kdv0jSyeTOUFdN71RtouzaR4fHEhxQvZWW5E9VsoHWkET1jhQO9oUSYsGLmaOFwU5ooh4EvTYsGLmaO)6azZTjKWOLF8N2uizXdTNWHOkFTiqrpzdQ3PmQ41I6(jKSyH2yGkfQN)zzRSeyjda6Voq2CBcjm(8bTPqYIhApHdrv(AbQ3PmQ41EWbPf19lfagPNZcHKjb(IEmKbapwfswSqBmqLc1FmzLLalzaq)1bYMBtiHXg8WQIGaDc5kZ)AGQ0McjlEO9eoev5RLo5qfDclgrlQ7hlbwYaG(z5M74CG7v1klbwYaG(RdKn3MqcJw(bTPqYIhApHdrv(APDIdcR4L2uizXdTNWHOkFTiqrpzdQ3PmQ41I6(LcaJ0F5qcEDa2SVIJ2JHma4XQqYIfAJbQuOEotwzjWsga0FDGS52esy85dAtHKfp0EchIQ816cefm5XRdArD)sbGr61OaR41w0AXbKEmKbap0McjlEO9eoev5Rfqyj2arpzrD)sbGr6N4P9KehpgYaGhRdN71pXt7jjoEikKK2uizXdTNWHOkFTiqrpzdQ3PmQ41I6(jKSyH2yGkfQNZKvwcSKba9xhiBUnHegF(G2K2uizXdT)waac)GCcJJkrOf19trqGoHCflX9QATXHZ961jeJ3CYMFTrbMtEhx0McjlEO93caqOkFTiqrpzdQ3PmQ41I6(LcaJ0tGIEQIxBDYHkEmKbapwzjWsga0pl3ChNdyhvPnfsw8q7VfaGqv(AbewInq0twu3pwcSKba9ZYn3X5GgQQvwcSKba9xhiBUnHegBWdAtHKfp0(BbaiuLVwqoHXrLiK2uizXdT)waacv5R1fikyYJxhK2K2uizXdTN7cde(b5eghvIqlQ7NIGaDc5kwctpSMLcAjVKZ21UqY(7j7y5n3Cxa]] )


end
