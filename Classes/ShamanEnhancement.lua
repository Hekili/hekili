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


    spec:SetPotion( 'prolonged_power' )

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


    spec:RegisterPack( "Enhancement", 20180916.0019, [[dGu1WaqiPOEejrTjkPpPQsAuirNcjSkPi4vKKMfLWTuvb7IQ(LuQHPs5yQuTmKupJkvMMuKUMczBKe5BuIACuPQZjfrwNQk08ij4EQk7tH6GsrOfIu6HuPCrsc5Jsru6KKeQwPuyMsruCtvvI2PQQ(PQk1qvvrlvkIQEQunvPKRQQsqFvkIk7vP)sPgmPomXIv0JrzYQ4YqBwv(Skz0k40sEnsYSbUnj2TOFJQHtLCCvvcSCepNIPlCDQy7ivFNsKXtsOCEKI1RQsO5tsTFqV33wB)ibU)P(2D3FRjD3Y(B3O(g1BpOXfUDxcJk5c3Ekk42vr5GKmubZy7UeAaC5ST2UH7qy42hIWL5hB3(QIbNPNXvABkfhGefpze5fTnLcR9eWNTNp5hoi92Ui8xbqt7wfsOM62TOMA7(GOiPTkkhKKHkygEtPW2(0PaHkEUZTFKa3)uF7U7V1KUBz)TB3Bs3hTDJlKT)PwLC32pOHTDvgQvr5GKmubZaQ7dIIKWgQmupeHlZp2U9vfdotpJR02ukoajkEYiYlABkfw7jGpBpFYpCq6TDr4VcGM2TkKqn1TBrn129brrsBvuoijdvWm8MsHbBOYqDhDfOYejq9DlBbut9T7UhQ)bO(2TF8(DOUj(lHnGnuzO2TbjVqZpcBOYq9pa1nXZbpqDlEGkq9VumbsObQdou)tcY4ktj8BhuMWST2oJtWT1()(2A7yktaEwA3oJubskz70fsjta6FoeACBazur9OTlSO452rHedyABCvuHBS)PEBTDmLjaplTBNrQajLSDHffD0gtuPqdup(dQD32fwu8C7gN8GKkV2y)7UT12XuMa8S0UDHffp3Uj4eftqkQWTZivGKs2U8lIKkqpOUgISYlBgppov4XuMa8a1wH6MH6doDEppOUgISYlBgppov4DCb1wHAHffD0gtuPqdupgQVd1wHAkH6PZ75nbNOmjvEHeVJlOwTAOMsOMUqkzcq)VD7NCoWY3GARqnDHuYeG(NdHg3gqgvUBeutbutX2z0WaODiKlmm7)7BS)B62A7yktaEwA3oJubskz7tN3ZBcorzsQ8cjEhxqTA1qnLq90598xsmGKkVSnbNOy8oUGARqnDHuYeG(F72p5CGLVb1wHA6cPKja9phcnUnGmQC3iOMITlSO452nbNOycsrfUX(F02A7yktaEwA3oJubskz7clk6OnMOsHgOE8hu7oO2kutxiLmbO)5qOXTbKrf1J2UWIINBNreZGnOUgISYRn2)Q02A7yktaEwA3oJubskz7HaWm8C6iHniKl0JPmb4bQTc1clk6OnMOsHgO(dQVd1wHA6cPKja9phcnUnGmQA6iO2kuRiiWeeUcup(dQB6TTlSO452b11qKvEzp5GyJ9VL3wBhtzcWZs72zKkqsjBNUqkzcq)VD7NCoWY3GARqnDHuYeG(NdHg3gqgvUB02fwu8C7MGtumbPOc3y)7(T12fwu8C7gN8GKkV2oMYeGNL2n2)nPT12XuMa8S0UDgPcKuY2dbGz4FCcdFoaBlv5X4XuMa8a1wHAHffD0gtuPqdupgQVd1wHA6cPKja9phcnUnGmQOE02fwu8C7mIygSb11qKvETX()(TT12XuMa8S0UDgPcKuY2dbGz4nOqQ8YwmgXbeEmLjapBxyrXZT)aIcg88Yb3y)F)(2A7yktaEwA3oJubskz7HaWm8d8WEqYJhtzcWduBfQNoVNFGh2dsE8euyX2fwu8C7aHUydeZWg7)7uVT2oMYeGNL2TZivGKs2UWIIoAJjQuObQhd13HARqnDHuYeG(NdHg3gqgvupA7clkEUDgrmd2G6AiYkV2yJTZDHjs2w7)7BRTJPmb4zPD7msfiPKTRiiWeeUcuRcq99rqTvOokfeQvbO(ID2UWIINBNWzunRajBSX2fdBBT)VVT2oMYeGNL2TZivGKs2EZq90598mIygSb11qKvE5DCb1wHAHffD0gtuPqdupgQVd1wHA6cPKja9phcnUnGmQOE02fwu8C7mIygSb11qKvETX(N6T12XuMa8S0UDgPcKuY2dbGz4bsEmG6GEmLjapqTvOUzOE68EEGKhdOoO3XfuBfQzdc5cn2pIWIINcaQhd139wE7clkEUDcNr1ScKSX(3DBRTlSO452TuLhtqkQWTJPmb4zPDJn2UlcY4ktj2w7)7BRTJPmb4zPDJ9p1BRTJPmb4zPDJ9V72wBhtzcWZs7g7)MUT2oMYeGNL2n2)J2wBxyrXZT7Ihfp3oMYeGNL2n2)Q02A7clkEUDqDnezLx2MHcbNTJPmb4zPDJ9VL3wBxyrXZTh8avSvetGeA2oMYeGNL2n2y7VcaqY2A)FFBTDmLjaplTBNrQajLSDfbbMGWvGAvaQT8TTlSO452jCgvZkqYg7FQ3wBhtzcWZs72zKkqsjBpeaMHNreZqLx2MGtu8yktaEGARqnDHuYeG(F72p5CGkDB7clkEUDgrmd2G6AiYkV2y)7UT12XuMa8S0UDgPcKuY2PlKsMa0)B3(jNdC)nO2kutxiLmbO)5qOXTbKrvthTDHffp3oqOl2aXmSX(VPBRTlSO452jCgvZkqY2XuMa8S0UX(F02A7clkEU9hquWGNxo42XuMa8S0UXgBNDmBR9)9T12XuMa8SZTZivGKs2EiKlm8dOaIbVlwa1Qaut9iOwTAOokfeQhd138JUDB7clkEU9jGZpahtSX(N6T12XuMa8S0UDgPcKuY2PeQdbGz4fddZJKm0JPmb4bQTc1tN3ZlggMhjzO3XfutbuRwnutjuhcaZWJaubZqa2gxfPcJhtzcWduBfQFira2gxfPcpbvKknq9yOEeutbuRwnutju3muhcaZWlggMhjzOhtzcWduBfQBgQdbGz4raQGziaBJRIuHXJPmb4bQPy7clkEU9jsmiHQkV2y)7UT12XuMa8S0UDgPcKuY2PeQdbGz4fddZJKm0JPmb4bQTc1uc1tN3ZlggMhjzO3XfuRwnuZ4CWHBP0lggMhjzONGksLgOEmup6gutbutbuRwnutju3muhcaZWlggMhjzOhtzcWduBfQPeQFira2gxfPcpbvKknq9yOEeuRwnuZ4CWHBP0)qIaSnUksfEcQivAG6Xq9OBqnfqnfBxyrXZTpbC(X(5qOzJ9Ft3wBhtzcWZs72zKkqsjBNsOoeaMHxmmmpsYqpMYeGhO2kutjupDEpVyyyEKKHEhxqTA1qnJZbhULsVyyyEKKHEcQivAG6Xq9OBqnfqnfqTA1qnLqDZqDiamdVyyyEKKHEmLjapqTvOMsO(HebyBCvKk8eurQ0a1JH6rqTA1qnJZbhULs)djcW24Qiv4jOIuPbQhd1JUb1ua1uSDHffp3(Ri4eW5Nn2)J2wBhtzcWZs72zKkqsjBNsOoeaMHxmmmpsYqpMYeGhO2kutjupDEpVyyyEKKHEhxqTA1qnJZbhULsVyyyEKKHEcQivAG6Xq9OBqnfqnfqTA1qnLqDZqDiamdVyyyEKKHEmLjapqTvOMsO(HebyBCvKk8eurQ0a1JH6rqTA1qnJZbhULs)djcW24Qiv4jOIuPbQhd1JUb1ua1uSDHffp3UKm0eebyZeayJ9VkTT2oMYeGNL2TZivGKs2(0598IHH5rsg6DCb1Qvd1nd1HaWm8IHH5rsg6XuMa8a1wH6hseGTXvrQWtqfPsdupgQhb1Qvd1HqUWWhLcAhC7tHqTk8b1Q0TTlSO452DXJINBS)T82A7clkEU9hseGTXvrQy7yktaEwA3y)7(T12XuMa8S0UDgPcKuY2zCo4WTu6nbPOc9eurQ0a1JH6BBxyrXZTlggMhjz4g7)M02A7clkEUDuiXGncqfmdbSDmLjaplTBSX2NoVNzBT)VVT2oMYeGNL2TZivGKs2EZq90598mIygSb11qKvE5DCb1wHAHffD0gtuPqdupgQVd1wHA6cPKja9phcnUnGmQOE02fwu8C7mIygSb11qKvETX(N6T12XuMa8S0UDgPcKuY2dbGz4bsEmG6GEmLjapqTvOUzOE68EEGKhdOoO3XfuBfQzdc5cn2pIWIINcaQhd139wE7clkEUDcNr1ScKSX(3DBRTJPmb4zPD7msfiPKT3muhfJQkVGARqTIGatq4kq94pOM6BBxyrXZT)Ci0yZF2sr2y)30T12XuMa8S0UDgPcKuY2BgQNoVN)befm45Ld6DCTDHffp3(dikyWZlhCJ9)OT12XuMa8S0UDgPcKuY2dbGz4hKcycorXJPmb4bQTc1nd1tN3Z)iCtmjsE8oUGARqnDHuYeG(NdHg3gqgvupA7clkEU9hHBIjrYZg7FvABTDmLjaplTBNrQajLS9PZ75FarbdEE5GEcQivAGAvaQBQ39qTQq9f7SDHffp3(dikyWZlhCJ9VL3wBhtzcWZs72zKkqsjBpeaMHFqkGj4efpMYeGhO2kupDEp)JWnXKi5XtqfPsduRcqDt9UhQvfQVyhO2kutxiLmbO)5qOXTbKrf1J2UWIINB)r4MysK8SX(39BRTJPmb4zPD7msfiPKTpDEppbn8usgAh8av8eurQ0a1Qaut92fwu8C7bpqfBfXeiHMn2y7h8joGyBT)VVT2UWIINB3svESndOq2oMYeGNL2n2)uVT2oMYeGNL2Ttxao42PeQBgQdbGz4FoeAS5pBPiEmLjapqTA1qnLqDiamd)ZHqJn)zlfXJPmb4bQTc1kccmbHRa1JH6MocQPaQPy7clkEUD6cPKja3oDHyNIcU9NdHg3gqgvnD0g7F3TT2oMYeGNL2Ttxao42PeQBgQdbGz4FoeAS5pBPiEmLjapqTA1qnLqDiamd)ZHqJn)zlfXJPmb4bQTc1kccmbHRa1JHA3ncQPaQPy7clkEUD6cPKja3oDHyNIcU9NdHg3gqgvUB0g7)MUT2oMYeGNL2Ttxao42PeQBgQdbGz4FoeAS5pBPiEmLjapqTA1qnLqDiamd)ZHqJn)zlfXJPmb4bQTc1kccmbHRa1JHAQhb1ua1uSDHffp3oDHuYeGBNUqStrb3(ZHqJBdiJkQhTX(F02A7yktaEwA3oDb4GBNsOUzOoeaMHNthjSbHCHEmLjapqTA1qTWIIoAJjQuObQhd13HA1QHAkH6qaygEoDKWgeYf6XuMa8a1wHAHffD0gtuPqdu)b13HARqnLqnJZbhULspOUgISYl7jheEcQivAG6XFqn1qDtaQVyhOwTAOwrqGjiCfOEmu7(BqnfqnfqnfBxyrXZTtxiLmb42Ple7uuWT)B3(jNdC)Tn2)Q02A7yktaEwA3oDb4GBNsOUzOoeaMHNthjSbHCHEmLjapqTA1qTWIIoAJjQuObQhd13HA1QHAkH6qaygEoDKWgeYf6XuMa8a1wHAHffD0gtuPqdu)b13HARqnLqnJZbhULspOUgISYl7jheEcQivAG6XFqn1qDtaQVyhOwTAOwrqGjiCfOEmuB5BqnfqnfqnfBxyrXZTtxiLmb42Ple7uuWT)B3(jNdS8Tn2)wEBTDmLjaplTBNUaCWTtju3muhcaZWZPJe2GqUqpMYeGhOwTAOwyrrhTXevk0a1JH67qTA1qnLqDiamdpNosydc5c9yktaEGARqTWIIoAJjQuObQ)G67qTvOMsOMX5Gd3sPhuxdrw5L9KdcpbvKknq94pOMAOUja1xSduRwnuRiiWeeUcupgQvPBqnfqnfqnfBxyrXZTtxiLmb42Ple7uuWT)B3(jNduPBBS)D)2A7clkEUDXj42secJQTJPmb4zPDJ9FtABTDHffp3UJbTRavmBhtzcWZs7g7)732wBhtzcWZs72fwu8C7mbaSfwu80guMy7GYe2POGBN7ctKSX()(9T12XuMa8S0UDgPcKuY2NoVNxmmmpsYqVJRTlSO452zcaylSO4PnOmX2bLjStrb3UyyBS)Vt92A7yktaEwA3UWIINBNjaGTWIIN2GYeBhuMWoffC7tN3ZSX()U72wBhtzcWZs72fwu8C7mbaSfwu80guMy7GYe2POGBNDmBS)V30T12XuMa8S0UDHffp3otaaBHffpTbLj2oOmHDkk42zCcUX()(OT12XuMa8S0UDHffp3otaaBHffpTbLj2oOmHDkk42FfaGKn2yJTthjMIN7FQVD393C)D35V7EQB62TKqYkVmBVjxtSj)Fv8)nz)rOgQBnGqDP4ItcO(Xjq9VEWN4aIFfQj4VaNIGhO2WvqOwCcUIe4bQzdsEHgpSrtMkrO29)iu)lmnoUCXjbEGAHffpH6FvCcUTeHWO6x9WgWgQ4kU4KapqT7HAHffpHAqzcJh2y7ItmWjBVxkoajkE6grEX2Dr4VcGBxLHAvuoijdvWmG6(GOijSHkd1dr4Y8JTBFvXGZ0Z4kTnLIdqIINmI8I2MsH1Ec4Z2ZN8dhKEBxe(RaOPDRcjutD7wutTDFquK0wfLdsYqfmdVPuyWgQmu3rxbQmrcuF3Ywa1uF7U7H6FaQVD7hVFhQBI)sydydvgQDBqYl08JWgQmu)dqDt8CWdu3IhOcu)lftGeAG6Gd1)KGmUYucpSbSHkd1QivmK5e4bQN4JtqOMXvMsa1t8QsJhQBImg6kmqDYZFyqikphaulSO4PbQ5jGgpSHWIINgVlcY4ktj(EaXqfSHWIINgVlcY4ktju9R9JZpWgclkEA8UiiJRmLq1V2IZLcMHefpHnuzOUNIlZapGAIuhOE68E4bQnHegOEIpobHAgxzkbupXRknqTKhO2fb)bx8iQ8cQlduF4j6Hnewu804DrqgxzkHQFTnP4YmWdBtiHb2qyrXtJ3fbzCLPeQ(12fpkEcBiSO4PX7IGmUYucv)AdQRHiR8Y2mui4aBiSO4PX7IGmUYucv)Ah8avSvetGeAGnGnuzOwfPIHmNapqnshj0a1rPGqDmGqTWcobQldul0Lcita6Hnewu808zPkp2MbuiWgclkEAu9RnDHuYeGwKIc(9Ci042aYOQPJSGUaCWpkBoeaMH)5qOXM)SLI4XuMa8OwnLHaWm8phcn28NTuepMYeGhRkccmbHRmUPJOGcydHffpnQ(1MUqkzcqlsrb)EoeACBazu5Urwqxao4hLnhcaZW)Ci0yZF2sr8yktaEuRMYqayg(NdHgB(ZwkIhtzcWJvfbbMGWvg7UruqbSHWIINgv)AtxiLmbOfPOGFphcnUnGmQOEKf0fGd(rzZHaWm8phcn28NTuepMYeGh1QPmeaMH)5qOXM)SLI4XuMa8yvrqGjiCLXupIckGnewu80O6xB6cPKjaTiff873U9toh4(Bwqxao4hLnhcaZWZPJe2GqUqpMYeGh1Qfwu0rBmrLcnJVRwnLHaWm8C6iHniKl0JPmb4XQWIIoAJjQuO57UvkzCo4WTu6b11qKvEzp5GWtqfPsZ4pQBcxSJA1kccmbHRm293OGckGnewu80O6xB6cPKjaTiff873U9tohy5Bwqxao4hLnhcaZWZPJe2GqUqpMYeGh1Qfwu0rBmrLcnJVRwnLHaWm8C6iHniKl0JPmb4XQWIIoAJjQuO57UvkzCo4WTu6b11qKvEzp5GWtqfPsZ4pQBcxSJA1kccmbHRm2Y3OGckGnewu80O6xB6cPKjaTiff873U9tohOs3SGUaCWpkBoeaMHNthjSbHCHEmLjapQvlSOOJ2yIkfAgFxTAkdbGz450rcBqixOhtzcWJvHffD0gtuPqZ3DRuY4CWHBP0dQRHiR8YEYbHNGksLMXFu3eUyh1QveeyccxzSkDJckOa2qyrXtJQFTfNGBlrimQGnewu80O6xBhdAxbQyGnewu80O6xBMaa2clkEAdktyrkk4h3fMib2qyrXtJQFTzcaylSO4PnOmHfPOGFIHzr9(MoVNxmmmpsYqVJlydHffpnQ(1MjaGTWIIN2GYewKIc(nDEpdSHWIINgv)AZeaWwyrXtBqzclsrb)yhdSHWIINgv)AZeaWwyrXtBqzclsrb)yCccBiSO4Pr1V2mbaSfwu80guMWIuuWVxbaib2a2qyrXtJxmSpgrmd2G6AiYkVSOEFnpDEppJiMbBqDnezLxEhxwfwu0rBmrLcnJVBLUqkzcq)ZHqJBdiJkQhbBiSO4PXlgMQFTjCgvZkqIf17leaMHhi5XaQd6XuMa8yT5PZ75bsEmG6GEhxwzdc5cn2pIWIINcy8DVLHnewu804fdt1V2wQYJjifviSbSHWIINg)059mFmIygSb11qKvEzr9(AE68EEgrmd2G6AiYkV8oUSkSOOJ2yIkfAgF3kDHuYeG(NdHg3gqgvupc2qyrXtJF68Egv)At4mQMvGelQ3xiamdpqYJbuh0JPmb4XAZtN3ZdK8ya1b9oUSYgeYfASFeHffpfW47EldBiSO4PXpDEpJQFTFoeAS5pBPiwuVVMJIrvLxwveeyccxz8h13Gnewu804NoVNr1V2pGOGbpVCqlQ3xZtN3Z)aIcg88Yb9oUGnewu804NoVNr1V2pc3etIKhlQ3xiamd)GuatWjkEmLjapwBE68E(hHBIjrYJ3XLv6cPKja9phcnUnGmQOEeSHWIINg)059mQ(1(befm45LdAr9(MoVN)befm45Ld6jOIuPrfAQ39QEXoWgclkEA8tN3ZO6x7hHBIjrYJf17leaMHFqkGj4efpMYeGhRtN3Z)iCtmjsE8eurQ0Ocn17EvVyhR0fsjta6FoeACBazur9iydHffpn(PZ7zu9RDWduXwrmbsOXI69nDEppbn8usgAh8av8eurQ0OcudBaBOYqnTao)aCmbuZetu5fupXbHEXjqTsriCIbQJbeQnLIdqcobQnyevEzG6hNa1UiCvmAG6jGZpaht4H6oIqn3vu80a1)6eW5hGJjSDHegMXVAbul5bQ)1jGZpahtyhLc(REOg2qyrXtJNDmFtaNFaoMWI69fc5cd)akGyW7IfQa1JuRokfC8n)OB3Gnewu804zhJQFTNiXGeQQ8YI69rziamdVyyyEKKHEmLjapwNoVNxmmmpsYqVJlkuRMYqaygEeGkygcW24Qivy8yktaES(qIaSnUksfEcQivAgpIc1QPS5qaygEXWW8ijd9yktaES2CiamdpcqfmdbyBCvKkmEmLjapuaBiSO4PXZogv)ApbC(X(5qOXI69rziamdVyyyEKKHEmLjapwPC68EEXWW8ijd9oUuRMX5Gd3sPxmmmpsYqpbvKknJhDJckuRMYMdbGz4fddZJKm0JPmb4XkLpKiaBJRIuHNGksLMXJuRMX5Gd3sP)HebyBCvKk8eurQ0mE0nkOa2qyrXtJNDmQ(1(veCc48Jf17JYqaygEXWW8ijd9yktaESs50598IHH5rsg6DCPwnJZbhULsVyyyEKKHEcQivAgp6gfuOwnLnhcaZWlggMhjzOhtzcWJvkFira2gxfPcpbvKknJhPwnJZbhULs)djcW24Qiv4jOIuPz8OBuqbSHWIINgp7yu9RTKm0eebyZeaWI69rziamdVyyyEKKHEmLjapwPC68EEXWW8ijd9oUuRMX5Gd3sPxmmmpsYqpbvKknJhDJckuRMYMdbGz4fddZJKm0JPmb4XkLpKiaBJRIuHNGksLMXJuRMX5Gd3sP)HebyBCvKk8eurQ0mE0nkOa2qyrXtJNDmQ(12fpkEAr9(MoVNxmmmpsYqVJl1QBoeaMHxmmmpsYqpMYeGhRpKiaBJRIuHNGksLMXJuRoeYfg(Ouq7GBFkuf(uPBWgclkEA8SJr1V2pKiaBJRIubSHWIINgp7yu9RTyyyEKKHwuVpgNdoClLEtqkQqpbvKknJVbBiSO4PXZogv)AJcjgSraQGziaydydHffpnEgNGFOqIbmTnUkQqlQ3hDHuYeG(NdHg3gqgvupc2qyrXtJNXjOQFTno5bjvEzr9(ewu0rBmrLcnJ)ChSHWIINgpJtqv)ABcorXeKIk0cgnmaAhc5cdZ3DlQ3N8lIKkqpOUgISYlBgppov4XuMa8yT5doDEppOUgISYlBgppov4DCzvyrrhTXevk0m(UvkNoVN3eCIYKu5fs8oUuRMs6cPKja9)2TFY5alFZkDHuYeG(NdHg3gqgvUBefuaBiSO4PXZ4eu1V2MGtumbPOcTOEFtN3ZBcorzsQ8cjEhxQvt50598xsmGKkVSnbNOy8oUSsxiLmbO)3U9tohy5BwPlKsMa0)Ci042aYOYDJOa2qyrXtJNXjOQFTzeXmydQRHiR8YI69jSOOJ2yIkfAg)5oR0fsjta6FoeACBazur9iydHffpnEgNGQ(1guxdrw5L9KdclQ3xiamdpNosydc5c9yktaESkSOOJ2yIkfA(UBLUqkzcq)ZHqJBdiJQMoYQIGatq4kJ)A6nydHffpnEgNGQ(12eCIIjifvOf17JUqkzcq)VD7NCoWY3SsxiLmbO)5qOXTbKrL7gbBiSO4PXZ4eu1V2gN8GKkVGnewu804zCcQ6xBgrmd2G6AiYkVSOEFHaWm8poHHphGTLQ8y8yktaESkSOOJ2yIkfAgF3kDHuYeG(NdHg3gqgvupc2qyrXtJNXjOQFTFarbdEE5GwuVVqaygEdkKkVSfJrCaHhtzcWdSHWIINgpJtqv)Ade6InqmdwuVVqayg(bEypi5XJPmb4X60598d8WEqYJNGclGnewu804zCcQ6xBgrmd2G6AiYkVSOEFclk6OnMOsHMX3TsxiLmbO)5qOXTbKrf1JGnGnewu804FfaGKpcNr1ScKyr9(ueeyccxrfS8nydHffpn(xbair1V2mIygSb11qKvEzr9(cbGz4zeXmu5LTj4efpMYeGhR0fsjta6)TB)KZbQ0nydHffpn(xbair1V2aHUydeZGf17JUqkzcq)VD7NCoW93SsxiLmbO)5qOXTbKrvthbBiSO4PX)kaajQ(1MWzunRajWgclkEA8VcaqIQFTFarbdEE5GWgWgclkEA8CxyIKpcNr1ScKyr9(ueeyccxrfUpYAukOkCXoBSXU]] )


end
