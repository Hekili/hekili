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

        spec:RegisterStateTable( "twisting_nether", setmetatable( {}, {
            __index = function( t, k )
                if k == 'count' then
                    return ( state.buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( state.buff.shock_of_the_twisting_nether.up and 1 or 0 )
                end

                return 0
            end
        } ) )

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

            recheck = function () return buff.flametongue.remains, buff.flametongue.remains - 4.8, buff.flametongue.remains - ( 6 + gcd ) end,

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

            recheck = function () return buff.frostbrand.remains, buff.frostbrand.remains - 4.8, buff.frostbrand.remains - ( 6 + gcd ) end,
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
                if level < 116 and equpped.eye_of_the_twisting_nether then
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
    
        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20180728.1809, [[dGKRRaqiLepsjPytIsFsjPAueHtHqTkLKKEfcmleYTiffTlr(LkPHPsCmbYYeqptaAAiixJuyBer(gcQXre15ussTosrPMhPi3tuTpq4GcG0cbrpuG6IkjL(OaOYivss4KcGyLIIzkaQ6McGIDQK6NkjXqfawkPOGNk0ufuxvjjrFvauAVs9xs1GP0HrTyL6XKmzqDzOnRIpRsnAL40kEniz2a3gr7wYVjmCb54KIcTCv9CkMovxNO2or67KIQXtkk58GuZNuA)iDhuhUJWSJ96aVeKKVq4aLCkijFzvFrJo6qhc7yiwbfFJDSysSJR2AHlfsIL3Xqm0abd3H7Ori)kSJlUhYOzF9694lY7KsqE1mKYa2hrPE(4xndP66gi2x3hwZegLEn0lodanxdp4hyqxdhyq6XfMKl9vBTWLcjXYtMHu1XT8a8aKQ3DeMDSxh4LGK8fchOKtbj5lbrOvDhnHqvVoqjfWocJgvhdVmgQDmultTHyfu8nsTId1YkFef1cgJBO2J4P2vfiudys0m0mbOWWim1g6rLGCZo1IL)qtThXtTHfossTbyyJJp0PocgJB6WDujESd3RdQd3rS4naHBi7O6hh)H7Ou(hEdW0r(Ho4fubvGA0rw5JO6iYVVGLUj0af2EVoWoChXI3aeUHSJQFC8hUJRqTB5ZjPE2SOdM7fVM6ojhIAZsTSYhPOowi5GgQfICQnWoYkFevhvpBw0bZ9IxtD3EVoGD4oIfVbiCdzhv)44pChzLpsrDSqYbnule5uRKPwTAPwjOww5JuuhlKCqd1cro1kjQnl16malpPE2Sm1TUXfpzclEdqyQL4oYkFevhvpBw0bZ9IxtD3EVMqD4oIfVbiCdzhv)44pCh3YNtY4INC)tDJFsouhzLpIQJgx8Kg)hOW271A0H7iw8gGWnKDu9JJ)WDKv(if1Xcjh0qTqKtTeIA1QLALGAzLpsrDSqYbnule5uBGuBwQ1zawEs9SzzQBDJlEYew8gGWulXDKv(iQoQE2SOdM7fVM6U9ETK6WDelEdq4gYoQ(XXF4o6malpjKIVAH)BmHfVbim1MLALY)WBaMoYp0bVGkOiKguBwQLKrGXFbj1cro1sOlDKv(iQocM7fVM6wFlaE79Ac3H7iw8gGWnKDu9JJ)WDucQDfQ1zawEsifF1c)3yclEdqyQnl1kL)H3amDKFOdEbvqfqnOwIPwTAPwjOwNby5jHu8vl8FJjS4naHP2SuRu(hEdW0r(Ho4fubLKVqTe3rw5JO6OXfpPX)bkS9ETK7WDKv(iQoAKly8N6UJyXBac3q2EVEv3H7iw8gGWnKDu9JJ)WD0zawEYG8p1ToBmSmWtyXBac3rw5JO64bWKOlQBzS9EDqx6WDelEdq4gYoQ(XXF4oULpN0IW1x4co9iR8oYkFevhbSuwhWML271bfuhUJyXBac3q2r1po(d3rw5JuuhlKCqd1cro1gWoYkFevhvpBw0bZ9IxtD3E7DegpSmW7W96G6WDKv(iQoQ5tbRBwq(7iw8gGWnKT3RdSd3rPmqg7OeuReuRZaS80cpaJlEYew8gGWuBwQDfQDlFoPZlm((5cojhIAjMA1QLAxHADgGLNw4byCXtMWI3aeMAjUJyXBac3q2rw5JO6Ou(hEdWokLF9IjXoUWdW4INm4fubv796a2H7OugiJDucQDfQ1zawE6i)qRlo688jS4naHPwTAPwjOwNby5PJ8dTU4OZZNWI3aeMAZsTsqTsqTKmcm(liPwiO2aQb1MLAvcbawO5vcm3lEn1T(wa80JK8ugQfICQnGu7Qk1ERGPwIPwTAPwsgbg)fKuleuRKVqTetTetTe3rS4naHBi7iR8ruDuk)dVbyhLYVEXKyhpYp0bVGkOK8L271eQd3rPmqg7Oeu7kuRZaS80r(HwxC055tyXBactTA1sTsqTodWYth5hADXrNNpHfVbim1MLAjzey8xqsTqqTe(c1sm1sChXI3aeUHSJSYhr1rP8p8gGDuk)6ftID8i)qh8cQGIWxAVxRrhUJszGm2rjO2vOwNby5PJ8dTU4OZZNWI3aeMA1QLALGADgGLNoYp06IJopFclEdqyQnl1sYiW4VGKAHGAjKgulXulXDelEdq4gYoYkFevhLY)WBa2rP8Rxmj2XJ8dDWlOckcPr79Aj1H7OugiJDucQDfQ1zawE6i)qRlo688jS4naHPwTAPwjOwNby5PJ8dTU4OZZNWI3aeMAZsTKmcm(liPwiO2aQb1sm1sChXI3aeUHSJSYhr1rP8p8gGDuk)6ftID8i)qh8cQGkGA0EVMWD4okLbYyhLGAxHADgGLNoYp06IJopFclEdqyQvRwQvcQ1zawE6i)qRlo688jS4naHP2SuljJaJ)csQfcQnqnOwIPwI7iw8gGWnKDKv(iQokL)H3aSJs5xVysSJh5h6GxqfubQr79Aj3H7OugiJDucQDfQ1zawEsifF1c)3yclEdqyQvRwQvcQ1zawEsifF1c)3yclEdqyQnl1sYiW4VGKAHGAj8fQLyQL4oIfVbiCdzhzLpIQJs5F4na7Ou(1lMe74QeCaieacFP9E9QUd3rPmqg7Oeu7kuRZaS8Kqk(Qf(VXew8gGWuRwTuReuRZaS8Kqk(Qf(VXew8gGWuBwQLKrGXFbj1cb1kPlulXulXDelEdq4gYoYkFevhLY)WBa2rP8Rxmj2Xvj4aqias6s796GU0H7iR8ruDKLDHo7oRGQJyXBac3q2EVoOG6WDKv(iQokBq9XrsthXI3aeUHS9EDqb2H7iw8gGWnKDKv(iQoQyaqNv(ikDWy8ocgJRxmj2rriSWV9EDqbSd3rS4naHBi7iR8ruDuXaGoR8ru6GX4Du9JJ)WDClFoj2OWcMlfMKd1rWyC9IjXoYgv796GiuhUJyXBac3q2rw5JO6OIbaDw5JO0bJX7iymUEXKyh3YNJP9EDqA0H7iw8gGWnKDKv(iQoQyaqNv(ikDWy8ocgJRxmj2rfSP9EDqsQd3rS4naHBi7iR8ruDuXaGoR8ru6GX4DemgxVysSJkXJT3RdIWD4oIfVbiCdzhzLpIQJkga0zLpIshmgVJGX46ftID8maa(T3EhzJQd3RdQd3rw5JO6iYVVGLUj0af2rS4naHBiBVxhyhUJyXBac3q2r1po(d3XvO2T85KupBw0bZ9IxtDNKdrTzPww5JuuhlKCqd1cro1gyhzLpIQJQNnl6G5EXRPUBVxhWoChXI3aeUHSJQFC8hUJodWYtaUGnGbgtyXBactTzP2vO2T85KaCbBadmMKdrTzPw1c)3Or)8SYhrXaQfcQnOeH7iR8ruD8fkO2JJF79Ac1H7iR8ruDuZNc24)af2rS4naHBiBV9og6rLGCZEhUxhuhUJyXBac3q2EVoWoChXI3aeUHS9EDa7WDelEdq4gY271eQd3rS4naHBiBVxRrhUJSYhr1XqcFevhXI3aeUHS9ETK6WDKv(iQocM7fVM6w3SmiaUJyXBac3q2EVMWD4oYkFevhDHJK6KSXXh6oIfVbiCdz7T3XT85y6W96G6WDelEdq4gYoQ(XXF4o6malpb4c2agymHfVbim1MLAxHA3YNtcWfSbmWysoe1MLAvl8FJg9ZZkFefdOwiO2GseUJSYhr1XxOGApo(T3RdSd3rS4naHBi7O6hh)H74kuRpkOM6MAZsTKmcm(liPwiO2adSJSYhr1XJ8dTU4OZZ3EVoGD4oIfVbiCdzhv)44pChxHA3YNt6ays0f1TmMKd1rw5JO64bWKOlQBzS9EnH6WDelEdq4gYoQ(XXF4o6malpTWdW4INmHfVbim1MLAxHA3YNt68cJVFUGtYHO2SuRu(hEdW0r(Ho4fubfH0OJSYhr1XZlm((5cU9ETgD4oIfVbiCdzhv)44pCh3YNt6ays0f1TmMEKKNYqTAIALe1sa1ERG7iR8ruD8ays0f1Tm2EVwsD4oIfVbiCdzhv)44pChDgGLNw4byCXtMWI3aeMAZsTB5ZjDEHX3pxWPhj5PmuRMOwjrTeqT3k4oYkFevhpVW47Nl4271eUd3rS4naHBi7O6hh)H74w(CspAefxku3fosMEKKNYqTAIAdSJSYhr1rx4iPojBC8HU927Oc20H71b1H7iw8gGW9UJQFC8hUJo)3ONwqg4lPqkNA1e1gOguRwTuRpKi1cb1EjPXLlDKv(iQoUbcbmq24T3RdSd3rS4naHBi7O6hh)H74w(CsSrHfmxkmjhIA1QLALGAp4ZaDtO5hp9ijpLHAHGA1GAjMA1QLAbOueqTAIAd6YLoYkFevh34BWhQPUBVxhWoChXI3aeUHSJQFC8hUJB5ZjXgfwWCPWKCiQvRwQvcQ9Gpd0nHMF80JK8ugQfcQvdQLyQvRwQfGsra1QjQnOlx6iR8ruDCdecy9J8dD79Ac1H7iw8gGWnKDu9JJ)WDClFoj2OWcMlfMKdrTA1sTRqTodWYtSrHfmxkmHfVbim1MLAp4ZaDtO5hp9ijpLHAHGA1GA1QLAD(Vrp5djQ7cD4bPwnLtTs6shzLpIQJHe(iQ271A0H7iR8ruD8Gpd0nHMF8oIfVbiCdz79Aj1H7iw8gGWnKDu9JJ)WDucQvjeayHMxjJ)duy6rsEkd1cb1EHAjMAZsTB5ZjXgfwWCPWeSqZRoYkFevhzJclyUuy79Ac3H7iR8ruDe53x0rasILZGoIfVbiCdz7T3XZaa43H71b1H7iw8gGWnKDu9JJ)WDKKrGXFbj1QjQLWx6iR8ruD8fkO2JJF796a7WDelEdq4gYoQ(XXF4o6malpzq(N6wNngwg4jS4naHPwTAP2T85KoaMeDrDlJPhj5PmuRMOwcLKChzLpIQJhatIUOULX271bSd3rS4naHBi7O6hh)H7OeuRZaS8K6zZYu36gx8KjS4naHPwTAPww5JuuhlKCqd1cro1gi1sm1MLAHXT85Kq(9fS0nHgOWKCiQnl1sYiW4VGKAHiNAj0fQnl1kL)H3amTkbhacbqsx6iR8ruDu9Szrhm3lEn1D79Ac1H7iw8gGWnKDu9JJ)WD0zawEAHhGXfpzclEdqyQnl1ULpN05fgF)CbNEKKNYqTAIAjusYuBwQLKrGXFbj1cb1sOlDKv(iQoEEHX3pxWT3R1Od3rS4naHBi7O6hh)H7ijJaJ)csQfICQvJluBwQvk)dVbyAvcoaecaHVqTzPwP8p8gGPJ8dDWlOckjFPJSYhr1ralL1bSzP9ETK6WDKv(iQo(cfu7XXVJyXBac3q2EVMWD4oIfVbiCdzhv)44pChLGAjzey8xqsTqKtTssdQvRwQ1zawEs9SzzQBDJlEYew8gGWuRwTulR8rkQJfsoOHAHiNAdKAjMAZsTs5F4natRsWbGqaK0fQnl1kL)H3amDKFOdEbvqrin6iR8ruDu9Szrhm3lEn1D79Aj3H7iR8ruD8ays0f1Tm2rS4naHBiBV9okcHf(D4EDqD4oIfVbiCdzhv)44pChjzey8xqsTAIAdsdQnl16djsTAIAVvWDKv(iQo(cfu7XXV92BVJsX3mIQxh4LGK8fchyGPGUeKgDuZ5VM620XaSbOAgwhGSoaNMn1sTHxqQDidjENApINAxDy8WYaF1P2h1mkppctTgbjsTSSlizhHPw1cx3OjrZeGFkKAd6IMn1UQSmYHcjEhHPww5JOO2vNLDHo7oRGA1t0m0mbiKHeVJWuRKPww5JOOwWyCtIMPJHEXzayhxnu7QvZcvYoctTB8iEKAvcYn7u7gVNYKO2auLcd5gQTeLM5c)Khza1YkFeLHAffa6endR8ruMuOhvcYn75haBGIMHv(iktk0Jkb5MDcYVEecyAgw5JOmPqpQeKB2ji)klFtILZ(ikAMvd1gloKzr4u7Zdm1ULpheMAno7gQDJhXJuRsqUzNA349ugQLlyQn0JAMHeUp1n1ogQfwuyIMHv(iktk0Jkb5MDcYVAkoKzr46gNDdndR8ruMuOhvcYn7eKFnKWhrrZWkFeLjf6rLGCZob5xbZ9IxtDRBwgeatZWkFeLjf6rLGCZob5xDHJK6KSXXhAAgAMvd1UA1SqLSJWulkfFOPwFirQ1xqQLvU4P2XqTSuEa8gGjAgw5JOm5A(uW6MfKFAgw5JOmeKFvk)dVbirftI5l8amU4jdEbvqrKugiJ5siHZaS80cpaJlEYew8gGWzxzlFoPZlm((5cojhIyTAxXzawEAHhGXfpzclEdqyIPzyLpIYqq(vP8p8gGevmjMFKFOdEbvqj5lejLbYyUeR4malpDKFO1fhDE(ew8gGWA1kHZaS80r(HwxC055tyXBacNvcjizey8xqcra1iRsiaWcnVsG5EXRPU13cGNEKKNYarEaxvVvWeRvljJaJ)csiK8fIjMyAgw5JOmeKFvk)dVbirftI5h5h6Gxqfue(crszGmMlXkodWYth5hADXrNNpHfVbiSwTs4malpDKFO1fhDE(ew8gGWzjzey8xqcbHVqmX0mSYhrzii)Qu(hEdqIkMeZpYp0bVGkOiKgejLbYyUeR4malpDKFO1fhDE(ew8gGWA1kHZaS80r(HwxC055tyXBacNLKrGXFbjeesdIjMMHv(ikdb5xLY)WBasuXKy(r(Ho4fubva1GiPmqgZLyfNby5PJ8dTU4OZZNWI3aewRwjCgGLNoYp06IJopFclEdq4SKmcm(liHiGAqmX0mSYhrzii)Qu(hEdqIkMeZpYp0bVGkOcudIKYazmxIvCgGLNoYp06IJopFclEdqyTALWzawE6i)qRlo688jS4naHZsYiW4VGeIa1GyIPzyLpIYqq(vP8p8gGevmjMVkbhacbGWxiskdKXCjwXzawEsifF1c)3yclEdqyTALWzawEsifF1c)3yclEdq4SKmcm(liHGWxiMyAgw5JOmeKFvk)dVbirftI5RsWbGqaK0fIKYazmxIvCgGLNesXxTW)nMWI3aewRwjCgGLNesXxTW)nMWI3aeoljJaJ)csiK0fIjMMHv(ikdb5xzzxOZUZkOOzyLpIYqq(vzdQposAOzyLpIYqq(vfda6SYhrPdgJtuXKyUiew4tZWkFeLHG8Rkga0zLpIshmgNOIjXC2OiAo5B5ZjXgfwWCPWKCiAgw5JOmeKFvXaGoR8ru6GX4evmjMVLphdndR8rugcYVQyaqNv(ikDWyCIkMeZvWgAgw5JOmeKFvXaGoR8ru6GX4evmjMRepsZWkFeLHG8Rkga0zLpIshmgNOIjX8Zaa4tZqZWkFeLjXgvoYVVGLUj0afsZWkFeLjXgfb5xvpBw0bZ9IxtDt0CYxzlFoj1ZMfDWCV41u3j5qzzLpsrDSqYbnqKhindR8ruMeBueKF9fkO2JJprZj3zawEcWfSbmWyclEdq4SRSLpNeGlydyGXKCOSQf(VrJ(5zLpIIbqeuIW0mSYhrzsSrrq(vnFkyJ)duindndR8ruM0w(Cm5Vqb1EC8jAo5odWYtaUGnGbgtyXBacNDLT85KaCbBadmMKdLvTW)nA0ppR8rumaIGseMMHv(iktAlFogcYVEKFO1fhDEEIMt(k(OGAQ7SKmcm(liHiWaPzyLpIYK2YNJHG8RhatIUOULrIMt(kB5ZjDamj6I6wgtYHOzyLpIYK2YNJHG8RNxy89ZfmrZj3zawEAHhGXfpzclEdq4SRSLpN05fgF)CbNKdLvk)dVby6i)qh8cQGIqAqZWkFeLjTLphdb5xpaMeDrDlJenN8T85KoaMeDrDlJPhj5PmAsseCRGPzyLpIYK2YNJHG8RNxy89ZfmrZj3zawEAHhGXfpzclEdq4SB5ZjDEHX3pxWPhj5PmAsseCRGPzyLpIYK2YNJHG8RUWrsDs244dnrZjFlFoPhnIIlfQ7chjtpsYtz0uG0m0mRgQfsGqadKno1QyJp1n1UXfw6iEQLC(x8gQ1xqQ1mKYa2fp1Aq3N62qThXtTHEHMf0u7gieWazJNO2iIuRiKpIYqTR(gieWazJRhcFfw(Qte1Yfm1U6BGqadKnUUpK4QNOwAgw5JOmjfSjFdecyGSXjAo5o)3ONwqg4lPqkxtbQHwT(qIqCjPXLl0mSYhrzskydb5x34BWhQPUjAo5B5ZjXgfwWCPWKCiTAL4Gpd0nHMF80JK8ugi0GyTAbOueOPGUCHMHv(iktsbBii)6gieW6h5hAIMt(w(CsSrHfmxkmjhsRwjo4ZaDtO5hp9ijpLbcniwRwakfbAkOlxOzyLpIYKuWgcYVgs4JOiAo5B5ZjXgfwWCPWKCiTAxXzawEInkSG5sHjS4naHZEWNb6MqZpE6rsEkdeAOvRZ)n6jFirDxOdpOMYL0fAgw5JOmjfSHG8Rh8zGUj08JtZWkFeLjPGneKFLnkSG5sHenNCjucbawO5vY4)afMEKKNYaXfIZULpNeBuybZLctWcnVOzyLpIYKuWgcYVI87l6iajXYzandndR8ruMKs8yoYVVGLUj0afs0CYLY)WBaMoYp0bVGkOcudAgw5JOmjL4rcYVQE2SOdM7fVM6MO5KVYw(CsQNnl6G5EXRPUtYHYYkFKI6yHKdAGipqAgw5JOmjL4rcYVQE2SOdM7fVM6MO5KZkFKI6yHKdAGixYA1kbR8rkQJfsoObICjL1zawEs9SzzQBDJlEYew8gGWetZWkFeLjPepsq(vJlEsJ)duirZjFlFojJlEY9p1n(j5q0mSYhrzskXJeKFv9Szrhm3lEn1nrZjNv(if1Xcjh0aroH0Qvcw5JuuhlKCqde5bM1zawEs9SzzQBDJlEYew8gGWetZWkFeLjPepsq(vWCV41u36BbWjAo5odWYtcP4Rw4)gtyXBacNvk)dVby6i)qh8cQGIqAKLKrGXFbje5e6cndR8ruMKs8ib5xnU4jn(pqHenNCjwXzawEsifF1c)3yclEdq4Ss5F4nath5h6GxqfubudI1QvcNby5jHu8vl8FJjS4naHZkL)H3amDKFOdEbvqj5letZWkFeLjPepsq(vJCbJ)u30mSYhrzskXJeKF9ays0f1Tms0CYDgGLNmi)tDRZgdld8ew8gGW0mSYhrzskXJeKFfWszDaBwiAo5B5ZjTiC9fUGtpYkNMHv(iktsjEKG8RQNnl6G5EXRPUjAo5SYhPOowi5GgiYdindndR8ruM0zaa8ZFHcQ944t0CYjzey8xqQjcFHMHv(ikt6maa(eKF9ays0f1Tms0CYDgGLNmi)tDRZgdld8ew8gGWA1ULpN0bWKOlQBzm9ijpLrtekjzAgw5JOmPZaa4tq(v1ZMfDWCV41u3enNCjCgGLNupBwM6w34INmHfVbiSwTSYhPOowi5GgiYdK4SW4w(Csi)(cw6Mqduysouwsgbg)fKqKtOlzLY)WBaMwLGdaHaiPl0mSYhrzsNbaWNG8RNxy89ZfmrZj3zawEAHhGXfpzclEdq4SB5ZjDEHX3pxWPhj5PmAIqjjNLKrGXFbjee6cndR8ruM0zaa8ji)kGLY6a2Sq0CYjzey8xqcrUgxYkL)H3amTkbhacbGWxYkL)H3amDKFOdEbvqj5l0mSYhrzsNbaWNG8RVqb1EC8PzyLpIYKodaGpb5xvpBw0bZ9IxtDt0CYLGKrGXFbje5ssdTADgGLNupBwM6w34INmHfVbiSwTSYhPOowi5GgiYdK4Ss5F4natRsWbGqaK0LSs5F4nath5h6GxqfuesdAgw5JOmPZaa4tq(1dGjrxu3YindndR8ruMKiew4N)cfu7XXNO5KtYiW4VGutbPrwFirnDRG7il7lIVJXHmyQvcndYgEHiQnaK)BK42BVBa]] )

end
