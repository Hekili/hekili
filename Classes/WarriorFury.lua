-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 1.00
    local offhand_mod = 0.50

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
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * ( base_rage_gen * fury_rage_mult * state.swings.mainhand_speed / state.haste )
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
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod / state.haste
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
            copy = "meat_cleaver"
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

            essential = true,
            nobuff = "battle_shout",
            
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
                    gain( 3 + min( 5, active_enemies ) + min( 3, active_enemies ), "rage" )
                else
                    gain( 3 + min( 5, active_enemies ), "rage" )
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


    spec:RegisterPack( "Fury", 20180813.1552, [[dG0PyaqiQQYIiejpssvSjkL(esqnkkfNIs0RqsMfvf3cjq7Ik)cj1WKu5yiILPkPNrimnQQ01uLyBib5BuvQXrvfNJQQADsQsnpcP7Hu2hLGdsiQfQk1frcOnsvjLpsisnsQkP6Kuc1kPKMjvLKDkPmukH0srcWtLyQuQUQKQK(QKQe7vQ)kjdgLdtAXQQhtXKbCzOnd0Njy0iQtR0QPQeVMqnBIUnvz3I(nQgUQ44ucXYv55kMUW1ry7isFhjA8sQQZJeA9eIy(iv7h0njT9UaOb21ETos8tD(Her4i5Lxi5fF3LGIpyxEuJyva7sQEyx81iok2LhLIsUc027YWjod2fr(mKxVyp(0LpXkdlo7Fxa0a7AVwhj(Po)qIiCK8YlK4xF3fLiiZVUiYNH86f7XNUaGJPl2jVdKTdKPq2JAeRciKXbHm1elpHm5oXazG8dY81rXRCDqRqR2jJqMiBr9vqgL6azphN0fabGSpfHmr(mKxVyp(azAcaz7azkKrj)etb3Kc(CCHdNXbTcTAXq2HECsrailiJqMiLhNu0dZqKcYE0lgiJdczbzeYezlQVcYMnniKfKrkcz6HqwYdiJyqqcjKTjKfKriZWZaRFazCqiliVdKPaa80bzqMfdzkaacazbzeYERririRqMteqMHmAedzAcazwucppuczG8dY2mW7iEIXbzqMfdzQC4qMNcGqgfG69OciKPKQRu)seY(ii)qitIKIsiZ3Vaz2mBAqi7qd3ZdtanwEoqwqgpeY0dHm5MIrail4qgf5ehKjrsrjK57xGSqLygqMHmFnOLUUi3jM2ExMnfKyvONagT9UgjT9UGP(Liq)UlMBd8wTlFcqq3HgXsCMeNXr8az0PdzgoxcWPmDhAelXzsCg3HE6MdKzbi7v)0f1elp7YSOa(pufJxhDTxB7Dbt9lrG(Dxm3g4TAx(eGGUdnIL4mjoJJ4bYOthYSbYcvIz4apEqEtHQpEdEIXZHP(LiaKrNoKzdKjrsrjKjkK57xGm60HSqLygoJEPkGom1VebGmlHmBHmBGSpbiOdZtfq3HE6MdKjkKjyaGm60HStfqiZcqM)RdYSeYOthYcvIz480zuZHom1VebGmBHmBGSpbiOdZtfq3HE6MdKjkKjyaGm60HStfqiZcqM)RdYSeYSSlQjwE2Lt9EubSJUMiA7Dbt9lrG(Dxm3g4TAx(eGGompvaDepDrnXYZUG1hneb2rxZVT9UGP(Liq)UlMBd8wTlFcqqhMNkGoaoLzxutS8SlFjNdeK3BIo6AV027cM6xIa97UyUnWB1UyiRNaoqgni71UOMy5zxovytHQVKtzhDnkuBVlQjwE2LVKZbcY7nrxWu)seOF3rxZ3T9UGP(Liq)UlMBd8wTlphsALGbWrI7uVhvaHmBHmBGma8tac6MffW)HQy8CepqgD6qM)GSqLygUzrb8FOkgphM6xIaqMLDrnXYZU8Lkaob)86OR5N2ExWu)seOF3fZTbER2LpbiOdZtfqhXdKzlKzdKbGFcqq3SOa(pufJNJ4bYOthY8hKfQeZWnlkG)dvX45Wu)seaYSSlQjwE2fGtf4z1X1RJUM)B7Dbt9lrG(Dxm3g4TAxcvIz4m6LQa6Wu)seaYOthYSbYcvIz480zuZHom1VebGmBHStfqituiZp1bzwcz0Pdz2azHkXmCGhpiVPq1hVbpX45Wu)seaYSfYovaHmrHm)xhKzzxutS8SlNkSPq1xYPSJUgj1127cM6xIa97UyUnWB1UeQeZWbsClNyQgPoKDyQFjc0f1elp7ciXTCIPAK6qUJUgjK027IAILNDHsY7jPCtGUGP(Liq)UJo6IhNu0dZOT31iPT3f1elp7cz84RPsI6txWu)seOF3rhDbabvcz027AK027IAILNDrjcELgHAe3fm1Veb63D01ETT3f1elp7IHSEcyxWu)seOF3rxteT9UOMy5zxEi88qzxWu)seOF3rxZVT9UGP(Liq)UlMBd8wTl2azNUaviPygopoPOhMHdyNqtdczwaYE9fiZwi70fOcjfZW5Xjf9WmCBczwaY87lqMLqgD6qM)GStxGkKumdNhNu0dZWH1FNy6IAILNDHmE81ujr9PJU2lT9UOMy5zxE4XYZUGP(Liq)UJUgfQT3fm1Veb63DXCBG3QDjujMHdK4woXunsDi7Wu)seaYSfYSbY(eGGoqIB5et1i1HSBc1igYefYebKrNoK9jabDGe3YjMQrQdz3HE6MdKjkKjciJoDiZgiZW5saoLP7qJyjotIZ4o0t3CGmrHmraz2czFcqqhiXTCIPAK6q2DONU5azIcz(hYSeYSSlQjwE2fqIB5et1i1HChDnF327cM6xIa97UyUnWB1UGweI95bbCIvrIirLA9Raj8Lfb0PcK4OiKzlKzdK9jabDGe(YIa6ubsCu0bWPmHm60HSd90nhitui7viZYUOMy5zx(sohiiV3eD018tBVlyQFjc0V7I52aVv7IHZLaCkt3HgXsCMeNXDONU5azIczIOlQjwE2Lt9EubSJUM)B7DrnXYZUCOrSeNjXz6cM6xIa97o6AKuxBVlyQFjc0V7I52aVv7Y8GszvONagJJsY7jPCtaiZcqgjqMTqM)GSpbiOZd1OYirLu8CepDrnXYZUqj59KuUjqhDnsiPT3fm1Veb63DXCBG3QD5tac6o0iwIZK4moINUOMy5zx(sohOcK4OyhDnsETT3fm1Veb63DXCBG3QD5tac6o0iwIZK4moINUOMy5zx(4n4jEtHo6AKiI2ExWu)seOF3fZTbER2LtfqituiZV1bz2cz(dY(eGGUdnIL4mjoJJ4PlQjwE2f9mAIvb)omJo6AK432ExWu)seOF3fZTbER2fdNlb4uMUdnIL4mjoJ7qpDZbYefYerxutS8SlYvGCmv(cbGGhMrhDnsEPT3fm1Veb63DXCBG3QD5tac6o0iwIZK4moINUOMy5zxa3d)sohOJUgjuO2ExWu)seOF3fZTbER2LpbiO7qJyjotIZ4iE6IAILNDrtdoXPYkJkLD01iX3T9UGP(Liq)UlQjwE2LJiRutS8SsUt0f5orvQEyxMnfKyvONagD0rxEo0W9(A027AK027cM6xIa97o6AV227cM6xIa97o6AIOT3fm1Veb63D018BBVlQjwE2LVgHeRgYCIOlyQFjc0V7OR9sBVlyQFjc0V7ORrHA7DrnXYZU8WJLNDbt9lrG(DhD0rxifVz5zx716iXp157xF1rsD1rsxOuVCtHPl1lImfqnlUMiD9gYGm7KriB9E4xazG8dYOWaiOsidkmKDOfHypeaYgUhczkrW90abGmdznfWXbT6R2eHmsQ3qw9Aoepp8lqaitnXYtiJcRebVsJqnIPWoOvOvl27HFbcaz(fYutS8eYK7eJdATlZdA6A((1U8CCWvIDPEGmkW6JgIabGSpcYpeYmCVVgq2hf2CCqMiBm4tmqwYtkiz98ajKqMAILNdKXtjfDqRQjwEoUNdnCVVg0aL6igAvnXYZX9COH791GkAudY5aqRQjwEoUNdnCVVgurJALqWdZqJLNqRQjwEoUNdnCVVgurJ6VgHeRgYCIaATEGSsQpdzEazNUaq2NaeebGSj0yGSpcYpeYmCVVgq2hf2CGmnbGSNdPGp8i2uaY2bYa4j6GwvtS8CCphA4EFnOIg1tQpdzEunHgd0QAILNJ75qd37Rbv0O(HhlpHwHwRhiJcS(OHiqaidjfpkczX6HqwqgHm1e8dY2bYus1vQFj6GwvtS8COPebVsJqnIHwvtS8COIg1gY6jGqRQjwEourJ6hcppucTwpqMDY7az7azE8jKueYcoK9CiPygqMHZLaCkZbYapUhK9XnfGm1ywamdvkPiKrmiaKbqCBkazECsrpmdh0A9azQjwEourJ6JiRutS8SsUt4tQEinpoPOhMHplinpoPOhMHdyNqtdAHxGwvtS8COIg1KXJVMkjQp(SG0S50fOcjfZW5Xjf9WmCa7eAAql86l2E6cuHKIz484KIEygUnTGFFXs6093PlqfskMHZJtk6Hz4W6VtmqRQjwEourJ6hES8eAvnXYZHkAudsClNyQgPoK9zbPfQeZWbsClNyQgPoKDyQFjcyRnFcqqhiXTCIPAK6q2nHAelQiOt)tac6ajULtmvJuhYUd90nhrfbD62y4CjaNY0DOrSeNjXzCh6PBoIkcB)eGGoqIB5et1i1HS7qpDZru)BPLqRQjwEourJ6VKZbcY7nHplin0IqSppiGtSksejQuRFfiHVSiGovGehfT1MpbiOdKWxweqNkqIJIoaoLjD6h6PBoI(QLqRQjwEourJ6t9Eub0NfKMHZLaCkt3HgXsCMeNXDONU5iQiGwvtS8COIg1hAelXzsCgOv1elphQOrnLK3ts5Ma(SG0MhukRc9eWyCusEpjLBcybsS1FFcqqNhQrLrIkP45iEGwvtS8COIg1FjNdubsCu0NfK2Nae0DOrSeNjXzCepqRQjwEourJ6pEdEI3uWNfK2Nae0DOrSeNjXzCepqRQjwEourJA9mAIvb)omdFwqANkGI636S1FFcqq3HgXsCMeNXr8aTQMy55qfnQLRa5yQ8fcabpmdFwqAgoxcWPmDhAelXzsCg3HE6MJOIaAvnXYZHkAudUh(LCoGpliTpbiO7qJyjotIZ4iEGwvtS8COIg1AAWjovwzuP0NfK2Nae0DOrSeNjXzCepqRQjwEourJ6JiRutS8SsUt4tQEiTztbjwf6jGb0k0QAILNJZJtk6HzqJmE81ujr9bAfAvnXYZXnBkiXQqpbmOnlkG)dvX45Zcs7tac6o0iwIZK4moIh60nCUeGtz6o0iwIZK4mUd90nhl8QFGwvtS8CCZMcsSk0tadQOr9PEpQa6Zcs7tac6o0iwIZK4moIh60TjujMHd84b5nfQ(4n4jgphM6xIa0PBJejfLI67xOtpujMHZOxQcOdt9lralT1MpbiOdZtfq3HE6MJOcga60pvaTG)RZs60dvIz480zuZHom1VebS1MpbiOdZtfq3HE6MJOcga60pvaTG)RZslHwvtS8CCZMcsSk0tadQOrnwF0qeOpliTpbiOdZtfqhXd0QAILNJB2uqIvHEcyqfnQ)sohiiV3e(SG0(eGGompvaDaCktOv1elph3SPGeRc9eWGkAuFQWMcvFjNsFwqAgY6jGdTxHwvtS8CCZMcsSk0tadQOr9xY5ab59MaAvnXYZXnBkiXQqpbmOIg1FPcGtWppFwqAphsALGbWrI7uVhvaT1ga8tac6MffW)HQy8Cep0P7VqLygUzrb8FOkgphM6xIawcTQMy554MnfKyvONagurJAGtf4z1X1ZNfK2Nae0H5PcOJ4XwBaWpbiOBwua)hQIXZr8qNU)cvIz4MffW)HQy8CyQFjcyj0QAILNJB2uqIvHEcyqfnQpvytHQVKtPpliTqLygoJEPkGom1VebOt3MqLygopDg1COdt9lraBpvaf1p1zjD62eQeZWbE8G8McvF8g8eJNdt9lraBpvaf1)1zj0QAILNJB2uqIvHEcyqfnQbjULtmvJuhY(SG0cvIz4ajULtmvJuhYom1VebGwvtS8CCZMcsSk0tadQOrnLK3ts5MaD0r3a]] )
end
