-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 0.80
    local offhand_mod = 0.80

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            -- setting = "forecast_fury",

            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 end,

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * ( base_rage_gen * fury_rage_mult * state.swings.mainhand_speed )
            end
        },

        offhand_fury = {
            -- setting = 'forecast_fury',

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = 'offhand_speed',

            stop = function () return state.time == 0 end,
            
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod
            end,
        },

        bladestorm = {
            aura = "bladestorm",

            last = function ()
                local app = state.buff.bladestorm.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = function () return 1 * state.haste end,

            value = 5,
        }
    } )
    
    -- Talents
    spec:RegisterTalents( {
        war_machine = 22632, -- 262231
        endless_rage = 22633, -- 202296
        fresh_meat = 22491, -- 215568

        double_time = 19676, -- 103827
        impending_victory = 22625, -- 202168
        storm_bolt = 23093, -- 107570

        inner_rage = 22379, -- 215573
        sudden_death = 22381, -- 280721
        furious_slash = 23372, -- 100130

        furious_charge = 23097, -- 202224
        bounding_stride = 22627, -- 202163
        warpaint = 22382, -- 208154

        carnage = 22383, -- 202922
        massacre = 22393, -- 206315
        frothing_berserker = 19140, -- 215571

        meat_cleaver = 22396, -- 280392
        dragon_roar = 22398, -- 118000
        bladestorm = 22400, -- 46924

        reckless_abandon = 22405, -- 202751
        anger_management = 22402, -- 152278
        siegebreaker = 16037, -- 280772
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3592, -- 208683
        relentless = 3591, -- 196029
        adaptation = 3590, -- 214027

        death_wish = 179, -- 199261
        enduring_rage = 177, -- 198877
        thirst_for_battle = 172, -- 199202
        battle_trance = 170, -- 213857
        barbarian = 166, -- 280745
        slaughterhouse = 3735, -- 280747
        spell_reflection = 1929, -- 216890
        death_sentence = 25, -- 198500
        disarm = 3533, -- 236077
        master_and_commander = 3528, -- 235941
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.recklessness.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            cooldown.recklessness.expires = cooldown.recklessness.expires - floor( rageSpent / 20 )
            rageSpent = rageSpent % 20
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
    end )


    -- Auras
    spec:RegisterAuras( {
        battle_shout = {
            id = 6673,
            duration = 3600,
            max_stack = 1,
        },
        berserker_rage = {
            id = 18499,
            duration = 6,
            type = "",
            max_stack = 1,
        },
        bladestorm = {
            id = 46924,
            duration = function () return 4 * haste end,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        dragon_roar = {
            id = 118000,
            duration = 6,
            max_stack = 1,
        },
        enrage = {
            id = 184362,
            duration = 4,
            max_stack = 1,
        },
        enraged_regeneration = {
            id = 184364,
            duration = 8,
            max_stack = 1,
        },
        frothing_berserker = {
            id = 215572,
            duration = 6,
            max_stack = 1,
        },
        furious_charge = {
            id = 202225,
            duration = 5,
            max_stack = 1,
        },
        furious_slash = {
            id = 202539,
            duration = 15,
            max_stack = 3,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        piercing_howl = {
            id = 12323,
            duration = 15,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        recklessness = {
            id = 1719,
            duration = function () return talent.reckless_abandon.enabled and 14 or 10 end,
            max_stack = 1,
        },
        siegebreaker = {
            id = 280773,
            duration = 10,
            max_stack = 1,
        },
        sign_of_the_skirmisher = {
            id = 186401,
            duration = 3600,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 4,
            max_stack = 1,
        },
        sudden_death = {
            id = 280776,
            duration = 10,
            max_stack = 1,
        },
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        victorious = {
            id = 32216,
            duration = 20,
        },
        whirlwind = {
            id = 85739,
            duration = 20,
            max_stack = 2,
        },
    } )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
        spec:RegisterAura( "raging_thirst", {
            id = 242300, 
            duration = 8
         } ) -- fury 2pc.
        spec:RegisterAura( "bloody_rage", {
            id = 242952,
            duration = 10,
            max_stack = 10
         } ) -- fury 4pc.

    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
        spec:RegisterAura( "slaughter", {
            id = 253384,
            duration = 4
        } ) -- fury 2pc dot.
        spec:RegisterAura( "outrage", {
            id = 253385,
            duration = 8
         } ) -- fury 4pc.

    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.


    spec:RegisterGear( "soul_of_the_battlelord", 151650 )


    -- Abilities
    spec:RegisterAbilities( {
        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132333,
            
            handler = function ()
                applyBuff( "battle_shout" )
            end,
        },
        

        berserker_rage = {
            id = 18499,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 136009,
            
            handler = function ()
                applyBuff( "berserker_rage" )
                if level < 116 and equipped.ceannar_charger then gain( 8, "rage" ) end
            end,
        },
        

        bladestorm = {
            id = 46924,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,
            
            handler = function ()
                applyBuff( "bladestorm" )
                gain( 5, "rage" )
                setCooldown( "global_cooldown", 4 * haste )

                if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end
            end,
        },
        

        bloodthirst = {
            id = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = -8,
            spendType = "rage",
            
            startsCombat = true,
            texture = 136012,
            
            handler = function ()
                gain( health.max * ( buff.enraged_regeneration.up and 0.25 or 0.05 ) * ( talent.fresh_meat.enabled and 1.2 or 1 ), "health" )
                if level < 116 and equipped.kazzalax_fujiedas_fury then addStack( "fujiedas_fury", 10, 1 ) end
                removeBuff( "bloody_rage" )
                removeStack( "whirlwind" )
            end,
        },
        

        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or 1 end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132337,
            
            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
            handler = function ()
                applyDebuff( "target", "charge" )
                if talent.furious_charge.enabled then applyBuff( "furious_charge" ) end
                setDistance( 5 )
            end,
        },
        

        dragon_roar = {
            id = 118000,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = -10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 642418,

            talent = "dragon_roar",
            
            handler = function ()
                applyDebuff( "target", "dragon_roar" )                
            end,
        },
        

        enraged_regeneration = {
            id = 184364,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 132345,
            
            handler = function ()
                applyBuff( "enraged_regeneration" )
            end,
        },
        

        execute = {
            id = function () return talent.massacre.enabled and 280735 or 5308 end,
            known = 5308,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",
            
            spend = -20,
            spendType = "rage",
            
            startsCombat = true,
            texture = 135358,
            
            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( talent.massacre.enabled and 35 or 20 ) end,
            handler = function ()
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                elseif buff.sudden_death.up then removeBuff( "sudden_death" ) end
                removeStack( "whirlwind" )
            end,

            copy = { 280735, 5308 }
        },
        

        furious_slash = {
            id = 100130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -4,
            spendType = "rage",

            startsCombat = true,
            texture = 132367,

            talent = "furious_slash",
            
            recheck = function () return buff.furious_slash.remains - 9, buff.furious_slash.remains - 3, buff.furious_slash.remains, cooldown.recklessness.remains < 3, cooldown.recklessness.remains end,
            handler = function ()
                if buff.furious_slash.stack < 3 then stat.haste = stat.haste + 0.02 end
                addStack( "furious_slash", 15, 1 )
                removeStack( "whirlwind" )
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or 1 end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236171,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },
        

        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132453,
            
            handler = function ()
            end,
        },
        

        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",
            
            handler = function ()
                gain( health.max * 0.2, "health" )
                removeStack( "whirlwind" )
            end,
        },
        

        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132154,
            
            handler = function ()
                applyDebuff( "target", "intimidating_shout" )
            end,
        },
        

        -- override this to account for recheck.
        lights_judgment = {
            id = 255647,
            cast = 0,
            cooldown = 150,
            gcd = "spell",
    
            toggle = 'cooldowns',

            usable = function () return race.lightforged_draenei end,
            recheck = function () return cooldown.recklessness.remains - 3, cooldown.recklessness.remains end,   
        },


        piercing_howl = {
            id = 12323,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 136147,
            
            handler = function ()
                applyDebuff( "target", "piercing_howl" )
            end,
        },
        

        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        raging_blow = {
            id = 85288,
            cast = 0,
            charges = 2,
            cooldown = function () return ( talent.inner_rage.enabled and 7 or 8 ) * haste end,
            recharge = function () return ( talent.inner_rage.enabled and 7 or 8 ) * haste end,
            gcd = "spell",

            spend = -12,
            spendType = "rage",
            
            startsCombat = true,
            texture = 589119,
            
            handler = function ()
                removeBuff( "raging_thirst" )
                if level < 116 and set_bonus.tier_21_4pc == 1 then addStack( "bloody_rage", 10, 1 ) end
                removeStack( "whirlwind" )
            end,
        },
        

        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 132351,
            
            handler = function ()
                applyBuff( "rallying_cry" )
            end,
        },
        

        rampage = {
            id = 184367,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if talent.carnage.enabled then return 75 end
                if talent.frothing_berserker.enabled then return 95 end
                return 85
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132352,
            
            recheck = function () return rage.time_to_91, buff.enrage.remains - gcd, buff.enrage.remains, cooldown.recklessness.remains - 3, cooldown.recklessness.remains end,
            handler = function ()
                if not buff.enrage.up then
                    stat.haste = stat.haste + 0.25
                end

                applyBuff( "enrage" )
                if talent.endless_rage.enabled then gain( 6, "rage" ) end

                if level < 116 and set_bonus.tier21_2pc == 1 then applyDebuff( "target", "slaughter" ) end

                if talent.frothing_berserker.enabled then
                    if buff.frothing_berserker.down then stat.haste = stat.haste + 0.05 end
                    applyBuff( "frothing_berserker" )
                end
                removeStack( "whirlwind" )
            end,
        },
        

        recklessness = {
            id = 1719,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458972,
            
            handler = function ()
                applyBuff( "recklessness" )
                if talent.reckless_abandon.enabled then gain( 100, "rage" ) end
            end,
        },
        

        siegebreaker = {
            id = 280772,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 294382,

            talent = "siegebreaker",
            
            handler = function ()
                applyDebuff( "target", "siegebreaker" )
                removeStack( "whirlwind" )
            end,
        },
        

        storm_bolt = {
            id = 107570,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 613535,
            
            talent = "storm_bolt",
            
            handler = function ()
                applyDebuff( "target", "storm_bolt" )
                removeStack( "whirlwind" )
            end,
        },
        

        taunt = {
            id = 355,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136080,

            handler = function ()
                applyDebuff( "target", "taunt" )
            end,
        },
        

        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132342,
            
            notalent = "impending_victory",

            buff = "victorious",
            handler = function ()
                removeBuff( "victorious" )
                removeStack( "whirlwind" )
            end,
        },
        

        whirlwind = {
            id = 190411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132369,
            
            handler = function ()
                applyBuff( "whirlwind", 20, 2 )

                if talent.meat_cleaver.enabled then
                    gain( min( 11, 3 + min( 3, active_enemies ) + active_enemies ), "rage" )
                else
                    gain( min( 8, 3 + active_enemies ), "rage" )
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
    
        package = "Fury",
    } )


    spec:RegisterPack( "Fury", 20180715.0705, [[diuWzaqifGfHkGEeQuAtisJsb5uaHxbQmlqv3sbe7IIFbknmfOJHkAzaPEgQqtdvQ6AujABkG03aImoGKohquZJkP7bu7JkHdQaQfIiUiQayJOcqJevkQtIkqwjvQzIkqTtqXqrLI8urMQczVQ8xu1GP0HjTyapMQMmixgAZk6ZimAe1PvA1ajEnrmBc3MO2TWVrz4uXXrLklxvpxY0L66IA7Os(Uc14rf05vqTEuPW8js7hPpoVrxcsB8Gb0dYjOoiiXPlndcsdcQCKZl1d7GxYr9suc8sHkJxIdy(h(so6WcMcDJUuXYVhV0a)EYRCVpRUeqEfnhuCaxcsB8Gb0dYjOoiiXPlndcsdoihbPlP5Mm7V0a)EYRCVpRUeew(lnI8wu7wuRsToQxIsGulBsTQVxwqTIT6IANSNA5MrjRynu3u3JiJu7aZnXbtTJ1IADEgxlecrTadtTd87jVY9(SIA1aIA3IAvQDm7Lmq2yG48mIhRYqDtDZbrTpkZ4cHO2MmsTCGYmUqzmAoqQ1r)UOw2KABYi1oWCtCWuBTHhP2Mmom1QpsTbRP2CHZSGA3GABYi16zrJCytTSj12K3IAviiwyUKyRUUrxQ2GqG8T(eyFJoy48gDjmuabcDKCj)Vn(REjG8CAE0lrGvfyvMSd1kvk16zmbeBCyE0lrGvfyvMhL1nkQ1fulOb1lP(EzXLQfjqGhvj4F9bdOVrxcdfqGqhjxY)BJ)QxcipNMh9seyvbwLj7qTsLsTdrTTkWOnZN1K3GGha)cFj4BWqbeie1kvk12QaJ241puc0GHciqiQLuQDiQfipNgmELanpkRBuuRRulHhIALkLAFLaPwxqTG8GuliOwPsP2wfy0gzTk1)ObdfqGqulPu7qulqEony8kbAEuw3OOwxPwcpe1kvk1(kbsTUGAb5bPwqqTG4sQVxwCPxLDuc86dgoEJUegkGaHosUK)3g)vVeqEony8kbAYoxs99YIlHCi6ZnE9bd3FJUegkGaHosUK)3g)vVeqEony8kbAGyJJlP(EzXLaemgutE)QV(GXL3OlHHciqOJKl5)TXF1l5jRpbwulyQf0xs99YIl9kXge8ac24RpygO3OlP(EzXLaemgutE)QVegkGaHosU(GbKUrxcdfqGqhjxY)BJ)QxY5rU4j8qgonVk7Oei1sk1oe1cKNttTibc8OkbFt2HALkLAha12QaJ2ulsGapQsW3GHciqiQfexs99YIlbiuiSA2lF9bdOEJUegkGaHosUK)3g)vVeqEony8kbAYoulPu7qulqEon1IeiWJQe8nzhQvQuQDauBRcmAtTibc8OkbFdgkGaHOwqCj13llUe0ReSG)z6F9bdiFJUegkGaHosUK)3g)vVuRcmAJx)qjqdgkGaHOwPsP2HO2wfy0gzTk1)ObdfqGqulPu7Rei16k1cQdsTGGALkLAhIABvGrBMpRjVbbpa(f(sW3GHciqiQLuQ9vcKADLAb5bPwqCj13llU0ReBqWdiyJV(GHZbVrxcdfqGqhjxY)BJ)QxQvbgTzM)LLl(sOfzdgkGaHUK67LfxAM)LLl(sOf5Rpy4KZB0LuFVS4sJjVVy8gqxcdfqGqhjxF9LGWPMf9n6GHZB0LuFVS4sAUz8A3QxYLWqbei0rY1hmG(gDj13llUKNS(e4LWqbei0rY1hmC8gDjmuabcDKCj)Vn(REPHO2xxiEKlmAtRpb2gOTAn8i16cQf0UKAjLAFDH4rUWOnYmUqzmAZguRlOwU3LuliOwPsP2bqTVUq8ixy0gzgxOmgTb5WT66sQVxwCjY4ZwpVavNRpy4(B0LWqbei0rYLcvgV0VbbpBY7zcH6uBqWpZD(X6sQVxwCPFdcE2K3Zec1P2GGFM78J1L8)24V6LqUlVooiK53GGNn59mHqDQni4N5o)yrTKsTa550GXReOj7qTKsTdGAbYZPPrzNw7LfMSZ1hmU8gDjmuabcDKCj)Vn(REPwfy0Mz(xwU4lHwKnyOaceIAjLAhIAbYZPzM)LLl(sOfzt1Qxc16k1YrQvQuQfipNMz(xwU4lHwKnpkRBuuRRulhPwPsP2HOwpJjGyJdZJEjcSQaRY8OSUrrTUsTCKAjLAbYZPzM)LLl(sOfzZJY6gf16k1cYuliOwqCj13llU0m)llx8LqlYxFWmqVrxcdfqGqhjxY)BJ)Qxc5U864Gqgjk3GBOcLd5NzqzriT4N5FyQLuQDiQfipNMzguwesl(z(h2aXghuRuPu7JY6gf16k1cAQfexs99YIlbiymOM8(vF9bdiDJUegkGaHosUK)3g)vVKNXeqSXH5rVebwvGvzEuw3OOwxPwoEj13llU0RYokbE9bdOEJUegkGaHosUK)3g)vVKNXeqSXH5rVebwvGvzEuw3OOwxPwoEj13llUKyji3fpOKHiKXOV(GbKVrxs99YIl9OxIaRkWQUegkGaHosU(GHZbVrxcdfqGqhjxkuz8szzGxf8Ymwqi0LlSUK67Lfxkld8QGxMXccHUCH1L8)24V6LqUlVooiKjld8QGxMXccHUCHf1sk1cKNtZJEjcSQaRYKDOwsPwG8CAW4vc0KDU(GHtoVrxcdfqGqhjxkuz8sswbOOiegfpq(Jni4hVf5lP(EzXLKScqrrimkEG8hBqWpElYxY)BJ)QxcipNMh9seyvbwLj7qTKsTa550GXReOj7C9bdNG(gDj13llUuUq(Tr56syOace6i56dgo54n6syOace6i5s(FB8x9sa5508OxIaRkWQmzNlP(EzXLaemge)m)dF9bdNC)n6syOace6i5s(FB8x9sa5508OxIaRkWQmzNlP(EzXLaWVWxYgexFWWPlVrxcdfqGqhjxY)BJ)Qx6vcKADLAb9GulPu7aOwG8CAE0lrGvfyvMSZLuFVS4s671a5B2)y0xFWW5a9gDjmuabcDKCj)Vn(REPYbfc(wFcSlZyY7lgVbe16cQLtQLuQDaulqEonJjVVy8gqMSZLuFVS4sJjVVy8gqxFWWjiDJUegkGaHosUK67Lfx6ZbV67Lf8IT6lj2Q5dvgVuTbHa5B9jW(6RVKmJlugJ(gDWW5n6sQVxwCjY4ZwpVavNlHHciqOJKRV(sop6zYaAFJoy48gDjmuabcDKCPEyh8sEwoAbwfV(YlwxFWa6B0LWqbei0rYL6HDWl1KrEY5G4hMxwj2QX)6dgoEJUegkGaHosUupSdEjiCUce66dgU)gDjmuabcDKC9bJlVrxcdfqGqhjxYH1llUetaXpw)lP(EzXLCy9YIRV(6lXf(1YIdgqpiNG6GGeNCVHto50LxAS(Xge1LUKZZMRaVK67LfLX5rptgqBWtHwsGVh2bb7z5Ofyv86lVyrDR(EzrzCE0ZKb0goWWozmi47HDqWnzKNCoi(H5LvITA8PUvFVSOmop6zYaAdhyy1mHmgT2llGVh2bbdHZvGqu3CR67LfLX5rptgqB4adlG2Ta5lYSCtDZTuBkuNImRP2xxiQfipNie1wT2f1cGt2JuRNjdOn1cGeBuuRgquRZJdehw3BqqTBrTqSanu3QVxwugNh9mzaTHdmSvOofzwZxT2f1T67LfLX5rptgqB4adRdRxwaFOYiyMaIFS(u3ul1n3sTCa4q0NBeIArUWFyQTxzKABYi1Q(M9u7wuRYLUcfqGgQB13llkWAUz8A3Qxc1T67LffCGH1twFcK6MBP2rK3IA3IALzvlgMABg168ixy0uRNXeqSXrrTZNjtTa4geuR69legTkedtT5cHOwO8Vbb1kZ4cLXOnu3Cl1Q(Ezrbhyy)CWR(EzbVyRg(qLrWYmUqzmA43jyzgxOmgTbARwdp6cxsDR(EzrbhyyjJpB98cuDGFNGh61fIh5cJ2iZ4cLXOnqB1A4rxaAxs6RlepYfgTrMXfkJrB2WfCVlbHuPd41fIh5cJ2iZ4cLXOnihUvxu3CR67LffCGH1H1llGpuzemtaXpwF43jyG8CAE0lrGvfyvMSd1T67LffCGHnxi)2Om8HkJG)ni4ztEptiuNAdc(zUZpwWVtWi3LxhheY8BqWZM8EMqOo1ge8ZCNFSifipNgmELanzhshaqEonnk70AVSWKDOUPwQB13llk4ad7m)llx8LqlYWVtWTkWOnZ8VSCXxcTiBWqbeiePdbKNtZm)llx8LqlYMQvVex5OuPa550mZ)YYfFj0IS5rzDJYvokv6qEgtaXghMh9seyvbwL5rzDJYvoskqEonZ8VSCXxcTiBEuw3OCfKbbiOUvFVSOGdmSacgdQjVF1WVtWi3LxhheYir5gCdvOCi)mdklcPf)m)dt6qa550mZGYIqAXpZ)Wgi24qQ0hL1nkxbniOUvFVSOGdmSVk7Oei87eSNXeqSXH5rVebwvGvzEuw3OCLJu3QVxwuWbgwXsqUlEqjdriJrd)ob7zmbeBCyE0lrGvfyvMhL1nkx5i1T67LffCGH9rVebwvGvrDR(EzrbhyyZfYVnkdFOYi4SmWRcEzglie6YfwWVtWi3LxhheYKLbEvWlZybHqxUWIuG8CAE0lrGvfyvMSdPa550GXReOj7qDR(EzrbhyyZfYVnkdFOYiyjRauuecJIhi)Xge8J3Im87emYD51XbHmswbOOiegfpq(Jni4hVfz43jyG8CAE0lrGvfyvMSdPa550GXReOj7qDZTQVxwuWbg2CH8BJYf87emqEonp6LiWQcSkt2H6w99YIcoWWMlKFBuUOUvFVSOGdmSacgdIFM)HHFNGbYZP5rVebwvGvzYou3QVxwuWbgwa8l8LSbb87emqEonp6LiWQcSkt2H6w99YIcoWWQVxdKVz)Jrd)ob)kb6kOhK0baKNtZJEjcSQaRYKDOUvFVSOGdmSJjVVy8gqWVtWLdke8T(eyxMXK3xmEdixWjPdaipNMXK3xmEdit2H6w99YIcoWW(5Gx99YcEXwn8HkJGRnieiFRpb2u3ul1T67LfLrMXfkJrdMm(S1Zlq1H6MAPUvFVSOm1gecKV1NaB4adBTibc8OkbF43jyG8CAE0lrGvfyvMSJuPEgtaXghMh9seyvbwL5rzDJYfGguPUvFVSOm1gecKV1NaB4ad7RYokbc)obdKNtZJEjcSQaRYKDKkDOwfy0M5ZAYBqWdGFHVe8nyOacesQ0wfy0gV(HsGgmuabcr6qa550GXReO5rzDJYvcpKuPVsGUaKheesL2QaJ2iRvP(hnyOaceI0HaYZPbJxjqZJY6gLReEiPsFLaDbipiiab1T67LfLP2GqG8T(eydhyyroe95gHFNGbYZPbJxjqt2H6w99YIYuBqiq(wFcSHdmSacgdQjVF1WVtWa550GXReObInoOUvFVSOm1gecKV1NaB4ad7ReBqWdiyJHFNG9K1NalWGM6w99YIYuBqiq(wFcSHdmSacgdQjVF1u3QVxwuMAdcbY36tGnCGHfqOqy1Sxg(Dc25rU4j8qgonVk7OeiPdbKNttTibc8OkbFt2rQ0b0QaJ2ulsGapQsW3GHciqiqqDR(EzrzQnieiFRpb2WbgwOxjyb)Z0h(DcgipNgmELanzhshcipNMArce4rvc(MSJuPdOvbgTPwKabEuLGVbdfqGqGG6w99YIYuBqiq(wFcSHdmSVsSbbpGGng(DcUvbgTXRFOeObdfqGqsLouRcmAJSwL6F0GHciqisFLaDfuheesLouRcmAZ8zn5ni4bWVWxc(gmuabcr6ReORG8GGG6w99YIYuBqiq(wFcSHdmSZ8VSCXxcTid)ob3QaJ2mZ)YYfFj0ISbdfqGqu3QVxwuMAdcbY36tGnCGHDm59fJ3a6sLd6pyajqF913b]] )
end
