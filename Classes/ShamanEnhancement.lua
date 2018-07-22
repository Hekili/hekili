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

                if buff.lightning_shield.up then
                    addStack( "lightning_shield", 3600, 2 )
                    if buff.lightning_shield.stack >= 20 then
                        applyBuff( "lightning_shield" )
                        applyBuff( "lightning_shield_overcharge" )
                    end
                end

                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

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


    spec:RegisterPack( "Enhancement", 20180722.1015,
        [[dmeeRaqiLepsuQQnjs9jkkWOqiNcHAvIsL6viWSqq3IIczxc9lvsdtL4yIqlte8mkQmnLKUgrQTrK4BejnorPCokkiRtuQqZJIs3tuTpq0bfLkzHGWdfLCrrPkJuuQiNKIcQvkkUPOurTtLu)KIQAOuuLLkkvWtfmvr0EL8xkmykDyulwPEmjtguxgAZQ4ZQuJwjoTIxdsMnWTr0UL63egUiz5Q65KA6uDDIA7eX3POOXtrH68GuZNISFKUsSswby2XADcxsmBxKAcjet8sIs1Csxbh6uyfsXkO4BScntIvi71lCRqsS9kKIHgiy4kzf0c5xHvyX9u6SJxVEp(I8oQeKx1dPmG9r0QNp(v9qQUUbI919HnJGrjxt9IZaq91Kd(jK41KjKOryHj52i71lCRqsS9OEivvylpa3mCx7kaZowRt4sIz7IutiHyIxsuQjUAf0PqvTobPyUkaJAvfsUmAQD0ultTPyfu8nsTId1YkFen1cgTRP2J4P2StiudyI0m0mzxWWim1M6rLGCZo1IT)qtThXtTjfossTzNzTJp0XkagTRRKvqjESswRtSswbS5naHliQG6hh)HRGe(hEdW4r(HoRfubvcsxbw5JORaYVVGTHo1afwEToHkzfWM3aeUGOcQFC8hUcRqTB5ZjQEwVyaM7fVN(okNIAttTSYhjOb2i5GAQfYCQnHkWkFeDfupRxmaZ9I3tFxET2CvYkGnVbiCbrfu)44pCfyLpsqdSrYb1ulK5uB2OwtMOwIOww5Je0aBKCqn1czo1kfQnn16maBpQEwVm9TH2fpzeBEdqyQL4kWkFeDfupRxmaZ9I3tFxETE1kzfWM3aeUGOcQFC8hUcB5ZjQDXtU)PVXpkNQcSYhrxbTlEsT)duy51APRKvaBEdq4cIkO(XXF4kWkFKGgyJKdQPwiZP2vPwtMOwIOww5Je0aBKCqn1czo1Ma1MMADgGThvpRxM(2q7INmInVbim1sCfyLpIUcQN1lgG5EX7PVlVwlLkzfWM3aeUGOcQFC8hUcodW2Jcj4Rw4)gJyZBactTPPwj8p8gGXJ8dDwlOcQvLMAttTKmc0(liPwiZP2vVubw5JORayUx8E6BJTa4LxRLALScyZBacxqub1po(dxbIO2vOwNby7rHe8vl8FJrS5naHP20uRe(hEdW4r(HoRfubL5KMAjMAnzIAjIADgGThfsWxTW)ngXM3aeMAttTs4F4naJh5h6Swqfuz7c1sCfyLpIUcAx8KA)hOWYR1zRswbw5JORGwUHXF67kGnVbiCbr51AZqvYkGnVbiCbrfu)44pCfCgGTh1i)tFBWAnld8i28gGWvGv(i6kCamj6I(wglVwN4LkzfWM3aeUGOcQFC8hUcB5ZjUiCJfUHJpYkVcSYhrxbalHnaSEP8ADIjwjRa28gGWfevq9JJ)WvGv(ibnWgjhutTqMtTMRcSYhrxb1Z6fdWCV4903LxEfePWg)kzToXkzfWM3aeUGOcQFC8hUcKmc0(liPwZsTjkn1MMA9HePwZsT3k4kWkFeDfEHcQ944xE5vagpSmWRK16eRKvGv(i6kyMtdBOxq(Ra28gGWfeLxRtOswbS5naHliQGegiJvGiQLiQ1za2ECHhG2fpzeBEdqyQnn1Uc1ULpN45fAF)CdhLtrTetTMmrTRqTodW2Jl8a0U4jJyZBactTexbw5JORGe(hEdWkiHFJMjXkSWdq7INmRfubv51AZvjRa28gGWfevqcdKXkqe1Uc16maBpEKFOnehdE(i28gGWuRjtulruRZaS94r(H2qCm45JyZBactTPPwIOwIOwsgbA)fKulKuR5KMAttTkHaalmZocM7fVN(2ylaE8rsEAn1czo1AoQn7MAVvWulXuRjtuljJaT)csQfsQnBxOwIPwIPwIRaR8r0vqc)dVbyfKWVrZKyfoYp0zTGkOY2LYR1RwjRa28gGWfevqcdKXkqe1Uc16maBpEKFOnehdE(i28gGWuRjtulruRZaS94r(H2qCm45JyZBactTPPwsgbA)fKulKuRuVqTetTexbw5JORGe(hEdWkiHFJMjXkCKFOZAbvqj1lLxRLUswbS5naHliQGegiJvGiQDfQ1za2E8i)qBiog88rS5naHPwtMOwIOwNby7XJ8dTH4yWZhXM3aeMAttTKmc0(liPwiP2vLMAjMAjUcSYhrxbj8p8gGvqc)gntIv4i)qN1cQGAvPlVwlLkzfWM3aeUGOcsyGmwbIO2vOwNby7XJ8dTH4yWZhXM3aeMAnzIAjIADgGThpYp0gIJbpFeBEdqyQnn1sYiq7VGKAHKAnN0ulXulXvGv(i6kiH)H3aScs43OzsSch5h6SwqfuMt6YR1sTswbS5naHliQGegiJvGiQDfQ1za2E8i)qBiog88rS5naHPwtMOwIOwNby7XJ8dTH4yWZhXM3aeMAttTKmc0(liPwiP2eKMAjMAjUcSYhrxbj8p8gGvqc)gntIv4i)qN1cQGkbPlVwNTkzfWM3aeUGOcsyGmwbIO2vOwNby7rHe8vl8FJrS5naHPwtMOwIOwNby7rHe8vl8FJrS5naHP20uljJaT)csQfsQvQxOwIPwIRaR8r0vqc)dVbyfKWVrZKyfm)SmpHai1lLxRndvjRa28gGWfevqcdKXkqe1Uc16maBpkKGVAH)BmInVbim1AYe1se16maBpkKGVAH)BmInVbim1MMAjzeO9xqsTqsTs5c1sm1sCfyLpIUcs4F4naRGe(nAMeRG5NL5jeaPCP8ADIxQKvGv(i6kWYUWGDNvqvbS5naHlikVwNyIvYkWkFeDfK1OX4iPUcyZBacxquEToXeQKvaBEdq4cIkWkFeDfumayWkFeTby0EfaJ2nAMeRGif24xETorZvjRa28gGWfevq9JJ)WvylForwRWgMBfgLtvbw5JORGIbadw5JOnaJ2Ray0UrZKyfyTQ8ADIRwjRa28gGWfevGv(i6kOyaWGv(iAdWO9kagTB0mjwHT85OlVwNO0vYkGnVbiCbrfyLpIUckgamyLpI2amAVcGr7gntIvqbRlVwNOuQKvaBEdq4cIkWkFeDfumayWkFeTby0EfaJ2nAMeRGs8y516eLALScyZBacxqubw5JORGIbadw5JOnaJ2Ray0UrZKyfodaGF5LxHupQeKB2RK16eRKvaBEdq4cIYR1jujRa28gGWfeLxRnxLScyZBacxquETE1kzfWM3aeUGO8AT0vYkWkFeDfsj8r0vaBEdq4cIYR1sPswbw5JORGlCK0GK1o(qxbS5naHlikVwl1kzfyLpIUcG5EX7PVn0ldcGRa28gGWfeLxEfodaGFLSwNyLScyZBacxqub1po(dxbsgbA)fKuRzPwPEPcSYhrxHxOGApo(LxRtOswbS5naHliQG6hh)HRGZaS9Og5F6BdwRzzGhXM3aeMAnzIA3YNt8ays0f9TmgFKKNwtTMLAxnMTkWkFeDfoaMeDrFlJLxRnxLScyZBacxqub1po(dxbIOwNby7r1Z6LPVn0U4jJyZBactTMmrTSYhjOb2i5GAQfYCQnbQLyQnn1cJB5ZjI87lyBOtnqHr5uuBAQLKrG2Fbj1czo1U6fQnn1kH)H3amA(zzEcbqkxQaR8r0vq9SEXam3lEp9D516vRKvaBEdq4cIkO(XXF4k4maBpUWdq7INmInVbim1MMA3YNt88cTVFUHJpsYtRPwZsTRgZg1MMAjzeO9xqsTqsTREPcSYhrxHZl0((5gU8AT0vYkGnVbiCbrfu)44pCfizeO9xqsTqMtTsFHAttTs4F4naJMFwMNqaK6fQnn1kH)H3amEKFOZAbvqLTlvGv(i6kayjSbG1lLxRLsLScSYhrxHxOGApo(vaBEdq4cIYR1sTswbS5naHliQG6hh)HRaruljJaT)csQfYCQvkstTMmrTodW2JQN1ltFBODXtgXM3aeMAnzIAzLpsqdSrYb1ulK5uBculXuBAQvc)dVby08ZY8ecGuUqTPPwj8p8gGXJ8dDwlOcQvLUcSYhrxb1Z6fdWCV4903LxRZwLScSYhrxHdGjrx03YyfWM3aeUGO8YRWw(C0vYADIvYkGnVbiCbrfu)44pCfCgGThbCdRbdmgXM3aeMAttTRqTB5Zjc4gwdgymkNIAttTQf(VrTX5zLpIMbulKuBIrPwbw5JORWluqThh)YR1jujRa28gGWfevq9JJ)WvyfQ1hfutFtTPPwsgbA)fKulKuBcjubw5JORWr(H2qCm45lVwBUkzfWM3aeUGOcQFC8hUcRqTB5ZjEamj6I(wgJYPQaR8r0v4ays0f9TmwETE1kzfWM3aeUGOcQFC8hUcodW2Jl8a0U4jJyZBactTPP2vO2T85epVq77NB4OCkQnn1kH)H3amEKFOZAbvqTQ0vGv(i6kCEH23p3WLxRLUswbS5naHliQG6hh)HRWw(CIhatIUOVLX4JK80AQ1SuRuOwcO2BfCfyLpIUchatIUOVLXYR1sPswbS5naHliQG6hh)HRGZaS94cpaTlEYi28gGWuBAQDlFoXZl0((5go(ijpTMAnl1kfQLaQ9wbxbw5JORW5fAF)CdxETwQvYkGnVbiCbrfu)44pCf2YNt8rTO5wHgUWrY4JK80AQ1SuBcvGv(i6k4chjnizTJp0LxEfuW6kzToXkzfWM3aeU2vq9JJ)WvW5)g94cYaFjMs5uRzP2eKMAnzIA9HePwiP2lrPVCPcSYhrxHnqiGbYAV8ADcvYkGnVbiCbrfu)44pCf2YNtK1kSH5wHr5uuRjtulru7bFgyOtn)4Xhj5P1ulKuR0ulXuRjtulaLGaQ1SuBIxUubw5JORWgFn(qn9D51AZvjRa28gGWfevq9JJ)WvylForwRWgMBfgLtrTMmrTerTh8zGHo18JhFKKNwtTqsTstTetTMmrTauccOwZsTjE5sfyLpIUcBGqaBCKFOlVwVALScyZBacxqub1po(dxHT85ezTcByUvyuof1AYe1Uc16maBpYAf2WCRWi28gGWuBAQ9Gpdm0PMF84JK80AQfsQvAQ1KjQ15)g9OpKOHlmGhKAnBo1kLlvGv(i6kKs4JOlVwlDLScSYhrxHd(mWqNA(XRa28gGWfeLxRLsLScyZBacxqub1po(dxbIOwLqaGfMzh1(pqHXhj5P1ulKu7fQLyQnn1ULpNiRvydZTcJWcZSRaR8r0vG1kSH5wHLxRLALScSYhrxbKFFXabij2odQa28gGWfeLxEfyTQswRtSswbw5JORaYVVGTHo1afwbS5naHlikVwNqLScyZBacxqub1po(dxHvO2T85evpRxmaZ9I3tFhLtrTPPww5Je0aBKCqn1czo1MqfyLpIUcQN1lgG5EX7PVlVwBUkzfWM3aeUGOcQFC8hUcodW2JaUH1GbgJyZBactTPP2vO2T85ebCdRbdmgLtrTPPw1c)3O248SYhrZaQfsQnXOuRaR8r0v4fkO2JJF516vRKvGv(i6kyMtdR9FGcRa28gGWfeLxE5vqc(6r016eUKy2UiLeKoM4fPRGzYFp9TUcvGL9fXxHWqMf1su2bznVqi1AEY)nsCfs9IZaWkK9P2SNzmQKDeMA34r8i1QeKB2P2nEpTosTzxkfMY1uBlAZOf(jpYaQLv(iAn1kAa0rAgw5JO1XupQeKB2ZpawdfndR8r06yQhvcYn7eKF9ieW0mSYhrRJPEuji3Stq(vw(MeBN9r00mzFQn0Ck9IWP2NhyQDlFoim1QD21u7gpIhPwLGCZo1UX7P1ul3WuBQhnJsjCF6BQD0ulSOXindR8r06yQhvcYn7eKFv3Ck9IWn0o7AAgw5JO1XupQeKB2ji)AkHpIMMHv(iADm1Jkb5MDcYV6chjnizTJp00mSYhrRJPEuji3Stq(vWCV4903g6LbbW0m0mzFQn7zgJkzhHPwuc(qtT(qIuRVGulRCXtTJMAzj8a4naJ0mSYhrRZnZPHn0li)0mSYhrRji)Qe(hEdqcBMeZx4bODXtM1cQGIqjmqgZjIiNby7XfEaAx8KrS5naHtVYw(CINxO99ZnCuofXMmTIZaS94cpaTlEYi28gGWetZWkFeTMG8Rs4F4najSzsm)i)qN1cQGkBxiucdKXCIwXza2E8i)qBiog88rS5naHnzIiNby7XJ8dTH4yWZhXM3aeonrerYiq7VGesZjDALqaGfMzhbZ9I3tFBSfap(ijpTgYCZLDFRGj2KjsgbA)fKqMTletmX0mSYhrRji)Qe(hEdqcBMeZpYp0zTGkOK6fcLWazmNOvCgGThpYp0gIJbpFeBEdqytMiYza2E8i)qBiog88rS5naHttYiq7VGesPEHyIPzyLpIwtq(vj8p8gGe2mjMFKFOZAbvqTQ0ekHbYyorR4maBpEKFOnehdE(i28gGWMmrKZaS94r(H2qCm45JyZBacNMKrG2FbjKRknXetZWkFeTMG8Rs4F4najSzsm)i)qN1cQGYCstOegiJ5eTIZaS94r(H2qCm45JyZBacBYerodW2Jh5hAdXXGNpInVbiCAsgbA)fKqAoPjMyAgw5JO1eKFvc)dVbiHntI5h5h6SwqfujinHsyGmMt0kodW2Jh5hAdXXGNpInVbiSjte5maBpEKFOnehdE(i28gGWPjzeO9xqczcstmX0mSYhrRji)Qe(hEdqcBMeZn)SmpHai1lekHbYyorR4maBpkKGVAH)BmInVbiSjte5maBpkKGVAH)BmInVbiCAsgbA)fKqk1letmndR8r0AcYVkH)H3aKWMjXCZplZtias5cHsyGmMt0kodW2Jcj4Rw4)gJyZBacBYerodW2Jcj4Rw4)gJyZBacNMKrG2FbjKs5cXetZWkFeTMG8RSSlmy3zfu0mSYhrRji)QSgnghj10mSYhrRji)QIbadw5JOnaJ2jSzsmxKcB8PzyLpIwtq(vfdagSYhrBagTtyZKyoRveoN8T85ezTcByUvyuofndR8r0AcYVQyaWGv(iAdWODcBMeZ3YNJMMHv(iAnb5xvmayWkFeTby0oHntI5kynndR8r0AcYVQyaWGv(iAdWODcBMeZvIhPzyLpIwtq(vfdagSYhrBagTtyZKy(zaa8PzOzyLpIwhzTkh53xW2qNAGcPzyLpIwhzTIG8RQN1lgG5EX7PVjCo5RSLpNO6z9IbyUx8E67OCQ0SYhjOb2i5GAiZtGMHv(iADK1kcYV(cfu7XXNW5K7maBpc4gwdgymInVbiC6v2YNteWnSgmWyuovA1c)3O248SYhrZaitmkvAgw5JO1rwRii)QzonS2)bkKMHMHv(iADClFo68xOGApo(eoNCNby7ra3WAWaJrS5naHtVYw(CIaUH1GbgJYPsRw4)g1gNNv(iAgazIrPsZWkFeToULphnb5xpYp0gIJbppHZjFfFuqn9DAsgbA)fKqMqc0mSYhrRJB5Zrtq(1dGjrx03YiHZjFLT85epaMeDrFlJr5u0mSYhrRJB5Zrtq(1Zl0((5gMW5K7maBpUWdq7INmInVbiC6v2YNt88cTVFUHJYPslH)H3amEKFOZAbvqTQ00mSYhrRJB5Zrtq(1dGjrx03YiHZjFlFoXdGjrx03Yy8rsEATzLcb3kyAgw5JO1XT85Oji)65fAF)Cdt4CYDgGThx4bODXtgXM3aeo9w(CINxO99ZnC8rsEATzLcb3kyAgw5JO1XT85Oji)QlCK0GK1o(qt4CY3YNt8rTO5wHgUWrY4JK80AZMandnt2NAHaieWazTtTkw7tFtTBCHLmINAjN)fVMA9fKA1dPmGDXtTA09PV1u7r8uBQxygdn1Ubcbmqw7rQnGi1ks5JO1uRzWgieWazTBKcFf2UzaHul3WuRzWgieWazTB4djAgePwAgw5JO1rfSoFdecyGS2jCo5o)3Ohxqg4lXuk3SjiTjt(qIqEjk9Ll0mSYhrRJkynb5x34RXhQPVjCo5B5ZjYAf2WCRWOCktMi6Gpdm0PMF84JK80AiLMytMaOeey2eVCHMHv(iADubRji)6gieWgh5hAcNt(w(CISwHnm3kmkNYKjIo4ZadDQ5hp(ijpTgsPj2KjakbbMnXlxOzyLpIwhvWAcYVMs4JOjCo5B5ZjYAf2WCRWOCktMwXza2EK1kSH5wHrS5naHtFWNbg6uZpE8rsEAnKsBYKZ)n6rFirdxyapOzZLYfAgw5JO1rfSMG8Rh8zGHo18JtZWkFeToQG1eKFL1kSH5wHeoNCIucbawyMDu7)afgFKKNwd5fItVLpNiRvydZTcJWcZSPzyLpIwhvWAcYVI87lgiajX2zandndR8r06Os8yoYVVGTHo1afs4CYLW)WBagpYp0zTGkOsqAAgw5JO1rL4rcYVQEwVyaM7fVN(MW5KVYw(CIQN1lgG5EX7PVJYPsZkFKGgyJKdQHmpbAgw5JO1rL4rcYVQEwVyaM7fVN(MW5KZkFKGgyJKdQHmpBMmreR8rcAGnsoOgYCPK2za2Eu9SEz6BdTlEYi28gGWetZWkFeToQepsq(vTlEsT)duiHZjFlForTlEY9p9n(r5u0mSYhrRJkXJeKFv9SEXam3lEp9nHZjNv(ibnWgjhudz(QMmreR8rcAGnsoOgY8es7maBpQEwVm9TH2fpzeBEdqyIPzyLpIwhvIhji)kyUx8E6BJTa4eoNCNby7rHe8vl8FJrS5naHtlH)H3amEKFOZAbvqTQ0PjzeO9xqcz(QxOzyLpIwhvIhji)Q2fpP2)bkKW5Kt0kodW2Jcj4Rw4)gJyZBacNwc)dVby8i)qN1cQGYCstSjte5maBpkKGVAH)BmInVbiCAj8p8gGXJ8dDwlOcQSDHyAgw5JO1rL4rcYVQLBy8N(MMHv(iADujEKG8RhatIUOVLrcNtUZaS9Og5F6BdwRzzGhXM3aeMMHv(iADujEKG8RawcBay9cHZjFlFoXfHBSWnC8rw50mSYhrRJkXJeKFv9SEXam3lEp9nHZjNv(ibnWgjhudzU5OzOzyLpIwhpdaGF(luqThhFcNtojJaT)csZk1l0mSYhrRJNbaWNG8RhatIUOVLrcNtUZaS9Og5F6BdwRzzGhXM3ae2KPT85epaMeDrFlJXhj5P1MD1y2OzyLpIwhpdaGpb5xvpRxmaZ9I3tFt4CYjYza2Eu9SEz6BdTlEYi28gGWMmXkFKGgyJKdQHmpbItdJB5ZjI87lyBOtnqHr5uPjzeO9xqcz(QxslH)H3amA(zzEcbqkxOzyLpIwhpdaGpb5xpVq77NBycNtUZaS94cpaTlEYi28gGWP3YNt88cTVFUHJpsYtRn7QXSLMKrG2FbjKREHMHv(iAD8maa(eKFfWsydaRxiCo5Kmc0(liHmx6lPLW)WBagn)SmpHai1lPLW)WBagpYp0zTGkOY2fAgw5JO1XZaa4tq(1xOGApo(0mSYhrRJNbaWNG8RQN1lgG5EX7PVjCo5erYiq7VGeYCPiTjtodW2JQN1ltFBODXtgXM3ae2Kjw5Je0aBKCqnK5jqCAj8p8gGrZplZtias5sAj8p8gGXJ8dDwlOcQvLMMHv(iAD8maa(eKF9ays0f9TmsZqZWkFeToksHn(5Vqb1EC8jCo5Kmc0(linBIsN2hs0S3k4YlVka]] )

end
