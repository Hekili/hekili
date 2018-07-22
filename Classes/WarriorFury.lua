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


    spec:RegisterPack( "Fury", 20180722.1001, [[dmKeBaqibklcvq1JeiSjurJIkLtrLQxbQAwij3IkHAxK6xGkdtvWXqLAzcspdvsttGORHkX2ufIVjqACQc15eOAEujDpqzFuj6GQcPfQk1frfeTrubHrIki5KOcPvkGzIkOStvjdLkHSuubPEQuMQGAVQ8xsmyIomLfRQEmvnzqUm0MLQpJuJgjoTsRgvGxJQA2eUnjTBr)gLHtfhNkblh45kMUKRl02rs9DvrJhvOoVGy9OcX8rv2pIpUVWxdYk8Ef6dC)4hcAOHQ5(Hh4M7qVwfIdEnhZZ3OXRLMkEnoerqixZXcrWmOl81gwe4XR9OapLvTwaBU2pUIIJM3)AqwH3RqFG7h)qqdnu9dbNlpc3xZIffg4ApkWtzvRfWMRbHJ)AHPSdrUdrAePJ55B0irY6eP5RLLePyNAiYodqKCOq(Ry1KaKaHPGe5J6I4WiYN2qKoag1lecrK)qiYhf4PSQ1cydrAjerUdrAe5tgGVlEtxSdGrdWz0KaKaCuIeGQmQriISOGejhUkJAufZIdNiDmqnejRtKffKiFuxehgroB6rISOGHqKgajYKvezCWEuqKBsKffKi9SSqoUiswNilk7qKgeel1ejrYrjsdccHiYIcsKVTQeir2OWIfr6PGE(ePLqePlkQQIcISZae5MfcarNA0ejrYrjstmmIu1GqIKdTP6y0irAuBRW(cKi)yNbqIuGuJcImOCHiDB20Jeja9mvvmHSAz5qKffeGePbqIuSjFeIilgrgclcisbsnkiYGYfISmbMfr6PWwp6U(AIDQ5cFTztAbQugGgRl89I7l81W0(ce6EFnpyleS21(XExdqpFbotIZOJoejpEePNXeqSNPgGE(cCMeNrdqvBZHiDjrg6JVM5RLLxBwKg)a04JGRUxHEHVgM2xGq37R5bBHG1U2p27Aa65lWzsCgD0Hi5XJiDJiltGzP7awrztALpcgeWhbAmTVaHisE8is3isbsnkisxjYGYfIKhpISmbML2BG0OrnM2xGqeP7ejNePBe5p27AmbgnQbOQT5qKUsK0EiIKhpIey0ir6sIm4pqKUtK84rKLjWS0Q2mMhGAmTVaHisojs3iYFS31ycmAudqvBZHiDLiP9qejpEejWOrI0LezWFGiDNiD)AMVwwEnGP6y04v3lUEHVgM2xGq37R5bBHG1U2p27AmbgnQJoxZ81YYRHCm6JfE19kiVWxdt7lqO7918GTqWAx7h7DnMaJg1qSN51mFTS8AFbJbvuwWuxDV4Yf(AyAFbcDVVMhSfcw7AEkgGghIegrg61mFTS8AaJEtALVG98Q71JCHVM5RLLx7lymOIYcM6AyAFbcDVV6Ef0l81W0(ce6EFnpyleS21Cai1k0Ein3AGP6y0irYjr6gr(J9UEwKg)a04JaD0Hi5XJidgrwMaZsplsJFaA8rGgt7lqiI09Rz(Az51(cdcNIbuV6E94l81W0(ce6EFnpyleS21(XExJjWOrD0Hi5KiDJi)XExplsJFaA8rGo6qK84rKbJiltGzPNfPXpan(iqJP9fier6(1mFTS8AqaJMLkaMbU6Ef8l81W0(ce6EFnpyleS21ktGzP9ginAuJP9fierYJhr6grwMaZsRAZyEaQX0(ceIi5KibgnsKUsKp(bI0DIKhpI0nISmbMLUdyfLnPv(iyqaFeOX0(ceIi5KibgnsKUsKb)bI09Rz(Az51ag9M0kFb75v3lUF4cFnmTVaHU3xZd2cbRDTYeyw6EeSS4OmcBOOX0(ce6AMVwwETEeSS4OmcBOC19IBUVWxZ81YYR9KYcep3e6AyAFbcDVV6QRPYOgvXSUW3lUVWxZ81YYRrbbS1RiqZ5AyAFbcDVV6QRbHDlkQl89I7l81mFTS8AwSykwvMN)1W0(ce6EF19k0l81mFTS8AEkgGgVgM2xGq37RUxC9cFnZxllVMtuvffxdt7lqO79v3RG8cFnmTVaHU3xZd2cbRDn3isGTqki1yw6Ya0yPH2PS0JePljYq5crYjrcSfsbPgZsRYOgvXS0BsKUKidsUqKUtK84rKbJib2cPGuJzPvzuJQywAKJ3PMRz(Az51OGa26veO5C19Ilx4RHP9fi09(AEWwiyTRHUqCDCqinytAfwxXZecZz2KwPhRiahIKtI8h7DnMaJg1rhIKtImye5p276cvDkRwwQJoxlnv8AGnPvyDfptimNztALESIaCUM5RLLxdSjTcRR4zcH5mBsR0JveGZv3Rh5cFnmTVaHU3xZd2cbRDTYeyw6EeSS4OmcBOOX0(ceIi5KiDJi)XEx3JGLfhLrydf9uMNpr6krYvIKhpI8h7DDpcwwCugHnu0au12CisxjsUsK84rKUrKEgtaXEMAa65lWzsCgnavTnhI0vIKRejNe5p276EeSS4OmcBOObOQT5qKUsKbNiDNiD)AMVwwETEeSS4OmcBOC19kOx4RHP9fi09(AEWwiyTRHUqCDCqinFJJWrmHXXk9ihSiKnk9iieIKtI0nI8h7DDpYblczJspccrdXEMejpEejavTnhI0vImuI09Rz(Az51(cgdQOSGPU6E94l81W0(ce6EFnpyleS218mMaI9m1a0ZxGZK4mAaQABoePRejxVM5RLLxdyQognE19k4x4RHP9fi09(AEWwiyTR5zmbe7zQbONVaNjXz0au12CisxjsUEnZxllVMyPPuJcheHOvXSU6EX9dx4Rz(Az51aONVaNjXzUgM2xGq37RUxCZ9f(AyAFbcDVVMhSfcw7AOlexhheshv)atOOYyjTWwQXHi5Ki)XExdqpFbotIZOJoejNe5p27AmbgnQJoxlnv8Ar1pWekQmwslSLACUM5RLLxlQ(bMqrLXsAHTuJZv3lUd9cFnmTVaHU3xZd2cbRDTFS31a0ZxGZK4m6OdrYjr(J9UgtGrJ6OZ1stfVg)vWbgcH5O8JGCtALN7q5AMVwwEn(RGdmecZr5hb5M0kp3HYv3lU56f(AMVwwET4GkBHQZ1W0(ce6EF19I7G8cFnmTVaHU3xZd2cbRDTFS31a0ZxGZK4m6OZ1mFTS8AFbJbP0JGqU6EXnxUWxdt7lqO7918GTqWAx7h7Dna98f4mjoJo6CnZxllV2hbdc4Vj9v3lUFKl81W0(ce6EFnpyleS21agnsKUsKH(arYjrgmI8h7Dna98f4mjoJo6CnZxllVMb8wIkfdaWSU6EXDqVWxdt7lqO7918GTqWAxBCqHqPmanwJ(jLfiEUjer6sIKBIKtImye5p276NuwG45Mq6OZ1mFTS8ApPSaXZnHU6EX9JVWxdt7lqO791mFTS8AGyQy(AzPIyN6AIDkL0uXRnBslqLYa0yD1vxZbGEM63Ql89I7l81W0(ce6EFTkeh8AEwmlboJIbuxCU6Ef6f(AyAFbcDVVwfIdETIcQqjM0Gquun6DkeC19IRx4RHP9fi09(Avio41GW(kqORUxb5f(AMVwwETVvLavgkSyDnmTVaHU3xDV4Yf(AyAFbcDVV6E9ix4RHP9fi09(AoSAz51yciLNg4AMVwwEnhwTS8QRU6AuJGzz59k0h4(XpeuU5I(HG(axU2tdKBspx7AJd6Vxbn0R5ay9vGxZ81YYr7aqpt9BfSUWg(uvH4GW8SywcCgfdOU4qcy(Az5ODaONP(TcEyW1zmiQQqCqyffuHsmPbHOOA07uiGeW81YYr7aqpt9Bf8WGZI0QywwTSKQkehege2xbcrcy(Az5ODaONP(TcEyW9TQeOYqHflsGGGiBP5muyfrcSfIi)XEhHiYPSAiYp2zaKi9m1Vve5hP3CislHisha6IDyvTjnrUdrcXsutcy(Az5ODaONP(TcEyWnP5muyLYuwnKaMVwwoAha6zQFRGhgCoSAzjvPPIWyciLNgGeGijbccIKdjhJ(yHqejsnccHiRvfjYIcsKMVyaIChI0O2wH9fOMeW81YYbMflMIvL55tcy(Az5apm48umanscy(Az5apm4CIQQOGeiiiYWu2Hi3HivztjcHilgr6aqQXSispJjGypZHi7aMkr(XnPjsZ7ximlticHiJdcrKqrWM0ePkJAufZstceeeP5RLLd8WGdetfZxllve7uuLMkctLrnQIzr12HPYOgvXS0q7uw6rxYfsaZxllh4HbhfeWwVIanhQ2om3a2cPGuJzPvzuJQywAODkl9OldLlCcSfsbPgZsRYOgvXS0B6YGKlUZJxWa2cPGuJzPvzuJQywAKJ3PgsGGW81YYbEyW5WQLLuLMkcJjGuEAaQ2oSFS31a0ZxGZK4m6OdjG5RLLd8WGloOYwOkvPPIWaBsRW6kEMqyoZM0k9yfb4q12HHUqCDCqinytAfwxXZecZz2KwPhRiaho)XExJjWOrD0HZG9J9UUqvNYQLL6Odjarscy(Az5apm46rWYIJYiSHcvBhwzcmlDpcwwCugHnu0yAFbcXPB)yVR7rWYIJYiSHIEkZZ3vUYJ3p276EeSS4OmcBOObOQT54kx5XZnpJjGyptna98f4mjoJgGQ2MJRCLZFS319iyzXrze2qrdqvBZX1G7U7KaMVwwoWddUVGXGkklykQ2om0fIRJdcP5BCeoIjmowPh5GfHSrPhbHWPB)yVR7royriBu6rqiAi2ZKhpaQABoUgQ7KaMVwwoWddoGP6y0ivBhMNXeqSNPgGE(cCMeNrdqvBZXvUscy(Az5apm4elnLAu4GieTkMfvBhMNXeqSNPgGE(cCMeNrdqvBZXvUscy(Az5apm4aONVaNjXzibmFTSCGhgCXbv2cvPknvewu9dmHIkJL0cBPghQ2om0fIRJdcPJQFGjuuzSKwyl14W5p27Aa65lWzsCgD0HZFS31ycmAuhDibmFTSCGhgCXbv2cvPknveg)vWbgcH5O8JGCtALN7qHQTddDH464GqA(RGdmecZr5hb5M0kp3HcvBh2p27Aa65lWzsCgD0HZFS31ycmAuhDibccZxllh4HbxCqLTq1HQTd7h7Dna98f4mjoJo6qcy(Az5apm4IdQSfQoKaMVwwoWddUVGXGu6rqiuTDy)yVRbONVaNjXz0rhsaZxllh4Hb3hbdc4VjnvBh2p27Aa65lWzsCgD0HeW81YYbEyWzaVLOsXaamlQ2omGrJUg6dCgSFS31a0ZxGZK4m6OdjG5RLLd8WG7jLfiEUjevBh24GcHszaASg9tklq8CtixYnNb7h7D9tklq8CtiD0HeW81YYbEyWbIPI5RLLkIDkQstfHnBslqLYa0yrcqKKaMVwwoAvg1OkMfmkiGTEfbAoKaejjG5RLLJE2KwGkLbOXcEyWnlsJFaA8ravBh2p27Aa65lWzsCgD0HhppJjGyptna98f4mjoJgGQ2MJld9XKaMVwwo6ztAbQugGgl4HbhWuDmAKQTd7h7Dna98f4mjoJo6WJNBLjWS0DaROSjTYhbdc4JanM2xGq845MaPgfUguUWJxzcmlT3aPrJAmTVaHCNt3(XExJjWOrnavTnhxP9q84bmA0Lb)b35XRmbMLw1MX8auJP9fieNU9J9UgtGrJAaQABoUs7H4Xdy0Old(dU7ojG5RLLJE2KwGkLbOXcEyWHCm6Jfs12H9J9UgtGrJ6OdjG5RLLJE2KwGkLbOXcEyW9fmgurzbtr12H9J9UgtGrJAi2ZKeW81YYrpBslqLYa0ybpm4ag9M0kFb7jvBhMNIbOXbwOKaMVwwo6ztAbQugGgl4Hb3xWyqfLfmfjG5RLLJE2KwGkLbOXcEyW9fgeofdOs12H5aqQvO9qAU1at1XOroD7h7D9Sin(bOXhb6OdpEbRmbMLEwKg)a04JanM2xGqUtcy(Az5ONnPfOszaASGhgCqaJMLkaMbOA7W(XExJjWOrD0Ht3(XExplsJFaA8rGo6WJxWktGzPNfPXpan(iqJP9fiK7KaMVwwo6ztAbQugGgl4HbhWO3Kw5lypPA7WktGzP9ginAuJP9fiepEUvMaZsRAZyEaQX0(ceItGrJU(4hCNhp3ktGzP7awrztALpcgeWhbAmTVaH4ey0ORb)b3jbmFTSC0ZM0cuPmanwWddUEeSS4OmcBOq12HvMaZs3JGLfhLrydfnM2xGqKaMVwwo6ztAbQugGgl4Hb3tklq8CtORU6oa]] )
end
