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

    spec:RegisterPack( "Enhancement", 20180625.1050,
        [[dmKEQaqiOkEKav2ei5tOuGrPs6uQeRcLcYRaPMfuPBjqvTlj(Lkvdtj6ycWYeqptfPMMkIRbv12qP03urY4GQ05qPQSobQsZtGY9KK9PI6GcufTqvkpuGCrukKrIsHYjfOkSsbzNQq)eLQmuukAPOuO6PuAQcQ1Isb1Ef9xszWcDyIfRupgvtgkxgzZG6ZkPrlPoTIxRcMTQUnk2Tu)gYWvclh45umDQUoPA7G47Ouz8OuvDEOI5Js2pjNbKHtlM4uEmWLbG3LSnq8lbS8KtcaVP1XzbL2fc)GSsPTfgkTSrDT0CIHApTleCEKGLHtRbPd4uARDFHj49(9fIXP90foI5oBXydZ(j2F4LPDRpVh8OZBPftCkTbUma8g8xY2GFa4vfdmGG3tZ20Awq88yGS90PfJm80gUEmQ4yurrfxi8dYkPIiyvu4(GAv8hJBuryeqfzJrhMFkP9hJBYWPLJaugopgqgoTul7NWYBPLdgNaJKwicyK9tfyDaobvt8dbIFAfUpOoTKa8AQ1mlMdu65XaZWPLAz)ewElTCW4eyK0Evf36WWfoq4h(Px1m6GvQOVqfzXsf36WWLxAmZpyurFHkEjTc3huNw2nnMXbZbk984PZWPLAz)ewElTCW4eyK0Evf36WWfoq4h(Px1m6GvQOVqfzXsf36WWLxAmZpyurFHkErfHsfHiGr2pvG1b4eunXpei(Pv4(G60ACeGX4G5aLEE8KmCAPw2pHL3slhmobgjTU8u7feecWRfWkvOw2pHPIqPImc9ghGyuXZvQi7d)0kCFqDA)zT27Px12O3tppIFgoTul7NWYBPLdgNaJKwH7desJAIziJkEUsfXRkYILkEvffUpqinQjMHmQ45kvKTQiuQOlp1EHdet90RAghbykul7NWuXlPv4(G60YbIPw7N1AVNEn98iBZWPv4(G60YUPXmoyoqPLAz)ewEl984PYWPLAz)ewElTCW4eyK0kCFGqAutmdzuXZvQ4PtRW9b1P1O3yey610ZJ4ndNwQL9ty5T0YbJtGrs7whgUuJCTAPXkas4EAfUpOoTVar0EXuNEEK9LHtl1Y(jS8wA5GXjWiP1LNAVyibm9QMymI(7fQL9tyPv4(G60c)cd5OEvNsppgWYmCAPw2pHL3slhmobgjTBDy4IXraMny6vcu0xOIqPIqeWi7NkW6aCcQM4hce)0kCFqDAnocWyCWCGsppgqaz40sTSFclVLwoyCcmsAfUpqinQjMHmQ45kv8evKflv8QkkCFGqAutmdzuXZvQyGQiuQOlp1EHdet90RAghbykul7NWuXlPv4(G60YbIPw7N1AVNEn98yabMHtl1Y(jS8wA5GXjWiP1LNAVGGqaETawPc1Y(jmvekveIagz)ubwhGtq1e)Wj4RIqPImc9ghGyuXZvQ4jltRW9b1P9N1AVNEvBJEp98yaNodNwQL9ty5T0YbJtGrs7vvepQOlp1EbbHa8AbSsfQL9tyQiuQiebmY(PcSoaNGQj(HtWxfVOISyPIxvrxEQ9cccb41cyLkul7NWurOuricyK9tfyDaobvt8dNAPkcLkYrOhdXUU8ZAT3tVQTrVxaeJmTrfpRIRCmvKnKkgOkEjTc3huNwJJamghmhO0ZJbCsgoTul7NWYBPLdgNaJK2TomCHb9o1ASJKfOUaiH7Pv4(G60(cer7ftD65XaWpdNwH7dQtRrVXiW0RPLAz)ewEl98yaSndNwQL9ty5T0YbJtGrsRW9bcPrnXmKrfpxPINoTc3huNwoqm1A)Sw790RPNEAfdpdNhdidNwH7dQtljaVMAnZI5aLwQL9ty5T0ZJbMHtRW9b1PLDtJzCWCGsl1Y(jS8w6PNwmcw0FpdNhdidNwH7dQtl7MgtZutciTul7NWYBPNhdmdNwiYRtP9Qk6YtTxQL5nocWuOw2pHPIqPI4rf36WWfyaY4BG0yf9fQ4L0sTSFclVLwH7dQtlebmY(P0craATWqPTwM34iatq1e)q65XtNHtle51P0EvfXJk6YtTxG1b4OHG1KbuOw2pHPISyPIxvrxEQ9cSoahneSMmGc1Y(jmvekvKrO34aeJkEwfX7sv8IkEjTul7NWYBPv4(G60craJSFkTqeGwlmuAH1b4eunXpG3LPNhpjdNwiYRtP9QkIhv0LNAVaRdWrdbRjdOqTSFctfzXsfVQIU8u7fyDaoAiynzafQL9tyQiuQiJqVXbigv8SkEQLQ4fv8sAPw2pHL3sRW9b1PfIagz)uAHiaTwyO0cRdWjOAIF4ultppIFgoTqKxNs7vvepQOlp1EbwhGJgcwtgqHAz)eMkYILkEvfD5P2lW6aC0qWAYakul7NWurOurgHEJdqmQ4zv8e8vXlQ4L0sTSFclVLwH7dQtlebmY(P0craATWqPfwhGtq1e)Wj4NEEKTz40crEDkTxvr8OIU8u7fyDaoAiynzafQL9tyQilwQ4vv0LNAVaRdWrdbRjdOqTSFctfHsfze6noaXOINvXaXxfVOIxsl1Y(jS8wAfUpOoTqeWi7NslebO1cdLwyDaobvt8dbIF65XtLHtle51P0EvfXJk6YtTxqqiaVwaRuHAz)eMkYILkEvfD5P2liieGxlGvQqTSFctfHsfVQImc9ghGyuXZQyalxQISyPICe6XqSRl)Sw790RAB07faXitBuXZQ4khtfVOIxuXlPLAz)ewElTc3huNwicyK9tPfIa0AHHsl7feBIqFalxMEEeVz40crEDkTxvr8OIU8u7feecWRfWkvOw2pHPISyPIxvrxEQ9cccb41cyLkul7NWurOuXRQiJqVXbigv8SkI3LQilwQihHEme76YpR1Ep9Q2g9EbqmY0gv8SkUYXuXlQ4fv8sAPw2pHL3sRW9b1PfIagz)uAHiaTwyO0YEbXMi0J3LPNhzFz40crEDkTxvr8OIU8u7feecWRfWkvOw2pHPISyPIxvrxEQ9cccb41cyLkul7NWurOuXRQiJqVXbigv8SkEQLQilwQihHEme76YpR1Ep9Q2g9EbqmY0gv8SkUYXuXlQ4fv8sAPw2pHL3sRW9b1PfIagz)uAHiaTwyO0YEbXMi0FQLPNhdyzgoTqKxNs7vvepQOlp1EbbHa8AbSsfQL9tyQilwQ4vv0LNAVGGqaETawPc1Y(jmvekv8QkYi0BCaIrfpRISDPkYILkYrOhdXUU8ZAT3tVQTrVxaeJmTrfpRIRCmv8IkErfVKwQL9ty5T0kCFqDAHiGr2pLwicqRfgkTSxqSjc9SDz65XacidNwH7dQtRO7inXDHFiTul7NWYBPNhdiWmCAfUpOoT6gsBCIXKwQL9ty5T0ZJbC6mCAPw2pHL3sRW9b1PLl)RjCFqT2pgpT)yCTwyO0IwqnbsppgWjz40sTSFclVLwH7dQtlx(xt4(GATFmEA5GXjWiPDRddxedNAmP5urFrA)X4ATWqPvm80ZJbGFgoTul7NWYBPv4(G60YL)1eUpOw7hJN2FmUwlmuA36WWM0ZJbW2mCAPw2pHL3sRW9b1PLl)RjCFqT2pgpT)yCTwyO0YXmPNhd4uz40sTSFclVLwH7dQtlx(xt4(GATFmEA)X4ATWqPLJau65XaWBgoTul7NWYBPv4(G60YL)1eUpOw7hJN2FmUwlmuAHN)jq6PN2faIJy2INHZJbKHtl1Y(jS8w65XaZWPv4(G60Ua5dQtl1Y(jS8w65XtNHtRW9b1P9N1AVNEvZup0JLwQL9ty5T0ZJNKHtRW9b1P1roXOXigNa4KwQL9ty5T0ZJ4NHtRW9b1PLeGxRrpXqTlFAPw2pHL3sp90YXmz48yaz40sTSFcl3PLdgNaJKwxaRKxQj596YcURIbtfdeFvKflv0hgsfpRIll4VCzAfUpOoT7hHWEDJNEEmWmCAPw2pHL3slhmobgjTBDy4Iy4uJjnNk6lurwSuXRQimbKxZSyaJxaeJmTrfpRI4RIxurwSuXNGqVkgmvmGLltRW9b1PDtadbom9A65XtNHtl1Y(jS8wA5GXjWiPDRddxedNAmP5urFHkYILkEvfHjG8AMfdy8cGyKPnQ4zveFv8IkYILk(ee6vXGPIbSCzAfUpOoT7hHW0G1b4KEE8KmCAfUpOoTWeqEnZIbmEAPw2pHL3sppIFgoTc3huNwsaETg9ed1U8PLAz)ewEl98iBZWPLAz)ewElTCW4eyK0Evf5i0JHyxxmocWyCWCGkaIrM2OINvXLQ4L0kCFqDAfdNAmP5u6PN2TomSjdNhdidNwQL9ty5T0YbJtGrslEurF4hMEvfHsfze6noaXOINvXadmTc3huNwyDaoAiynzaPNhdmdNwQL9ty5T0YbJtGrslEuXTomCb(fgYr9Qov0xKwH7dQtl8lmKJ6vDk984PZWPLAz)ewElTCW4eyK0craJSFQulZBCeGjOAIFqfHsfHiGr2pvG1b4eunXpCc(Pv4(G60cdqgFdKgl984jz40sTSFclVLwoyCcmsAXJkU1HHlCGyQ1(zT27Pxl6lurOurH7desJAIziJkEUsfdmTc3huNwoqm1A)Sw790RPNhXpdNwQL9ty5T0YbJtGrs7whgUaidQLMtAoYjMcGyKPnQyWuXatRW9b1P1roXOXigNa4KE6PfE(Naz48yaz40sTSFclVLwoyCcmsAze6noaXOIbtfp1Y0kCFqDAbi(H94ei98yGz40sTSFclVLwoyCcmsA36WWf4xyih1R6ubqmY0gvmyQ4jf8MwH7dQtl8lmKJ6vDk984PZWPLAz)ewElTCW4eyK06YtTxQL5nocWuOw2pHPIqPIBDy4cmaz8nqAScGyKPnQyWuXtk4vfHsfze6noaXOINvXtwMwH7dQtlmaz8nqAS0ZJNKHtl1Y(jS8wA5GXjWiPLrO34aeJkEUsfXFPkcLkcraJSFQWEbXMi0J3LQiuQiebmY(PcSoaNGQj(b8UmTc3huN2xGiAVyQtppIFgoTc3huNwaIFypobsl1Y(jS8w65r2MHtl1Y(jS8wA5GXjWiP9QkYi0BCaIrfpxPISfFvKflv0LNAVWbIPE6vnJJamfQL9tyQilwQOW9bcPrnXmKrfpxPIbQIxurOuricyK9tf2li2eHE2UufHsfHiGr2pvG1b4eunXpCc(Pv4(G60YbIPw7N1AVNEn984PYWPv4(G60c)cd5OEvNsl1Y(jS8w65r8MHtRW9b1P1roXOXigNa4KwQL9ty5T0tpTOfutGmCEmGmCAPw2pHL3slhmobgjTmc9ghGyuXGPIbGVkcLk6ddPIbtfx5yPv4(G60cq8d7Xjq6PNEAHqaZG68yGldaVlzBaSVsGbE60Yob0tVAsBAxaqWZtPn4ur2i2pX1Dctf3emcqQihXSfxf3060MIkg8KZPfUrfBuh8RfadS(RIc3huBuru)4uuHcoH7dQnLfaIJy2Ixb)I5GkuWjCFqTPSaqCeZwCORUdJqyQqbNW9b1MYcaXrmBXHU6UOVYqTl(GAvOGtfTTSWuJCveidMkU1HHjmv04IBuXnbJaKkYrmBXvXnToTrfLgtfxaOG)cK7tVQIJrfXqnvuHeUpO2uwaioIzlo0v3nTSWuJCnJlUrfs4(GAtzbG4iMT4qxDFbYhuRcjCFqTPSaqCeZwCORU)ZAT3tVQzQh6XuHeUpO2uwaioIzlo0v3DKtmAmIXjaoQqc3huBklaehXSfh6Q7Ka8An6jgQD5vHuHcovKnI9tCDNWurccbWrf9HHurVMurH7iGkogvuGiZl7NkQqc3huBQy30yAMAsaQqc3huBGU6oebmY(jCBHHQQL5nocWeunXpGle51PQRU8u7LAzEJJamfQL9tyqHNTomCbgGm(ginwrFXfviH7dQnqxDhIagz)eUTWqvW6aCcQM4hW7sCHiVovDfpU8u7fyDaoAiynzafQL9tySyD1LNAVaRdWrdbRjdOqTSFcdkgHEJdqmNX7YlxuHeUpO2aD1DicyK9t42cdvbRdWjOAIF4ulXfI86u1v84YtTxG1b4OHG1KbuOw2pHXI1vxEQ9cSoahneSMmGc1Y(jmOye6noaXC(ulVCrfs4(GAd0v3HiGr2pHBlmufSoaNGQj(HtWhxiYRtvxXJlp1EbwhGJgcwtgqHAz)eglwxD5P2lW6aC0qWAYakul7NWGIrO34aeZ5tW)YfviH7dQnqxDhIagz)eUTWqvW6aCcQM4hceFCHiVovDfpU8u7fyDaoAiynzafQL9tySyD1LNAVaRdWrdbRjdOqTSFcdkgHEJdqmNde)lxuHeUpO2aD1DicyK9t42cdvXEbXMi0hWYL4crEDQ6kEC5P2liieGxlGvQqTSFcJfRRU8u7feecWRfWkvOw2pHb1vgHEJdqmNdy5swS4i0JHyxx(zT27Px12O3laIrM2CELJD5YfviH7dQnqxDhIagz)eUTWqvSxqSjc94DjUqKxNQUIhxEQ9cccb41cyLkul7NWyX6Qlp1EbbHa8AbSsfQL9tyqDLrO34aeZz8UKfloc9yi21LFwR9E6vTn69cGyKPnNx5yxUCrfs4(GAd0v3HiGr2pHBlmuf7feBIq)PwIle51PQR4XLNAVGGqaETawPc1Y(jmwSU6YtTxqqiaVwaRuHAz)eguxze6noaXC(ulzXIJqpgIDD5N1AVNEvBJEVaigzAZ5vo2LlxuHeUpO2aD1DicyK9t42cdvXEbXMi0Z2L4crEDQ6kEC5P2liieGxlGvQqTSFcJfRRU8u7feecWRfWkvOw2pHb1vgHEJdqmNz7swS4i0JHyxx(zT27Px12O3laIrM2CELJD5YfviviH7dQnqxDx0DKM4UWpOcjCFqTb6Q76gsBCIXOcjCFqTb6Q7C5FnH7dQ1(X442cdvHwqnbuHeUpO2aD1DU8VMW9b1A)yCCBHHQedh3bUARddxedNAmP5urFHkKW9b1gORUZL)1eUpOw7hJJBlmu1whg2OcjCFqTb6Q7C5FnH7dQ1(X442cdvXXmQqc3huBGU6ox(xt4(GATFmoUTWqvCeGuHeUpO2aD1DU8VMW9b1A)yCCBHHQGN)jGkKkKW9b1MIy4vKa8AQ1mlMdKkKW9b1MIy4qxDNDtJzCWCGuHuHcoH7dQnLTomSPcG4h2JtaCh4kxEQ9YlnM5hmQqTSFcdk8S1HHlV0yMFWOI(cviH7dQnLTomSb6Q7W6aC0qWAYaWDGRWJp8dtVcfJqVXbiMZbgOkKW9b1MYwhg2aD1D4xyih1R6eUdCfE26WWf4xyih1R6urFHkKW9b1MYwhg2aD1DyaY4BG0y4oWvqeWi7Nk1Y8ghbycQM4hGcIagz)ubwhGtq1e)Wj4RcjCFqTPS1HHnqxDNdetT2pR1Ep9kUdCfE26WWfoqm1A)Sw790Rf9fqjCFGqAutmdzoxfOkKW9b1MYwhg2aD1Dh5eJgJyCcGdUdC1whgUaidQLMtAoYjMcGyKPnblqvivOGtfV9ie2RBCvKlgF6vvCt1cKbburMbaqaJk61KkAgg9xCeqfnK7tVAuryeqfxaqSFCuX9JqyVUXlQOLiveTWhuBur2G9JqyVUX1wqao1oBaUQO0yQiBW(riSx34A(WqSbfvufs4(GAtHJzQ2pcH96gh3bUYfWk5LAsEVUSG7blq8zXYhg68Yc(lxQcjCFqTPWXmqxDFtadbom9kUdC1whgUigo1ysZPI(cwSUcta51mlgW4faXitBoJ)fwSEcc9blGLlvHeUpO2u4ygORUVFectdwhGdUdC1whgUigo1ysZPI(cwSUcta51mlgW4faXitBoJ)fwSEcc9blGLlvHcoH7dQnfoMb6Q7lq(GACh4QTomCrmCQXKMtf9fSyHhxEQ9Iy4uJjnNkul7NWGcMaYRzwmGXlaIrM2CgFwSCbSsEXhgsZrAydfSk2Uufs4(GAtHJzGU6ombKxZSyaJRcjCFqTPWXmqxDNeGxRrpXqTlVkKW9b1MchZaD1DXWPgtAoH7axDLJqpgIDDX4G5avaeJmT58YlQqQqc3huBkCeGQib41uRzwmhiCh4kicyK9tfyDaobvt8dbIVkKW9b1MchbiORUZUPXmoyoq4oWvx36WWfoq4h(Px1m6GvQOVGfRTomC5LgZ8dgv0xCrfs4(GAtHJae0v3nocWyCWCGWDGRUU1HHlCGWp8tVQz0bRurFblwBDy4YlnM5hmQOV4cuqeWi7NkW6aCcQM4hceFviH7dQnfocqqxD)N1AVNEvBJEh3bUYLNAVGGqaETawPc1Y(jmOye6noaXCUI9HVkKW9b1MchbiORUZbIPw7N1AVNEf3bUs4(aH0OMygYCUcVSyDv4(aH0OMygYCUITq5YtTx4aXup9QMXraMc1Y(jSlQqc3huBkCeGGU6o7MgZ4G5aPcjCFqTPWrac6Q7g9gJatVI7axjCFGqAutmdzoxDAviH7dQnfocqqxD)fiI2lMACh4QTomCPg5A1sJvaKWDviH7dQnfocqqxDh(fgYr9QoH7ax5YtTxmKaMEvtmgr)9c1Y(jmviH7dQnfocqqxD34iaJXbZbc3bUARddxmocWSbtVsGI(cOGiGr2pvG1b4eunXpei(Qqc3huBkCeGGU6ohiMATFwR9E6vCh4kH7desJAIziZ5QtyX6QW9bcPrnXmK5CvGq5YtTx4aXup9QMXraMc1Y(jSlQqc3huBkCeGGU6(pR1Ep9Q2g9oUdCLlp1EbbHa8AbSsfQL9tyqbraJSFQaRdWjOAIF4e8HIrO34aeZ5QtwQcjCFqTPWrac6Q7ghbymoyoq4oWvxXJlp1EbbHa8AbSsfQL9tyqbraJSFQaRdWjOAIF4e8VWI1vxEQ9cccb41cyLkul7NWGcIagz)ubwhGtq1e)WPwcfhHEme76YpR1Ep9Q2g9EbqmY0MZRCm2qbErfs4(GAtHJae0v3FbIO9IPg3bUARddxyqVtTg7izbQlas4UkKW9b1MchbiORUB0Bmcm9QkKW9b1MchbiORUZbIPw7N1AVNEf3bUs4(aH0OMygYCU60QqQqc3huBkWZ)eOcG4h2JtaCh4kgHEJdqmb7ulvHeUpO2uGN)ja0v3HFHHCuVQt4oWvBDy4c8lmKJ6vDQaigzAtWoPGxviH7dQnf45FcaD1DyaY4BG0y4oWvU8u7LAzEJJamfQL9tyqT1HHlWaKX3aPXkaIrM2eStk4fkgHEJdqmNpzPkKW9b1Mc88pbGU6(lqeTxm14oWvmc9ghGyoxH)sOGiGr2pvyVGyte6X7sOGiGr2pvG1b4eunXpG3LQqc3huBkWZ)ea6Q7ae)WECcOcjCFqTPap)taORUZbIPw7N1AVNEf3bU6kJqVXbiMZvSfFwSC5P2lCGyQNEvZ4iatHAz)eglwc3hiKg1eZqMZvbEbkicyK9tf2li2eHE2UekicyK9tfyDaobvt8dNGVkKW9b1Mc88pbGU6o8lmKJ6vDsfs4(GAtbE(NaqxD3roXOXigNa4OcPcjCFqTPGwqnbQai(H94ea3bUIrO34aetWcaFO8HHc2khlTIUxJaPLnUUrQtp9mb]] )

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
