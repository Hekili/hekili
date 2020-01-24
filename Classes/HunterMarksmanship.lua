-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 254, true )

    spec:RegisterResource( Enum.PowerType.Focus )

    -- Talents
    spec:RegisterTalents( {
        master_marksman = 22279, -- 260309
        serpent_sting = 22501, -- 271788
        a_murder_of_crows = 22289, -- 131894

        careful_aim = 22495, -- 260228
        volley = 22497, -- 260243
        explosive_shot = 22498, -- 212431

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        steady_focus = 22267, -- 193533
        streamline = 22286, -- 260367
        hunters_mark = 21998, -- 257284

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shot = 22499, -- 109248

        lethal_shots = 23063, -- 260393
        barrage = 23104, -- 120360
        double_tap = 22287, -- 260402

        calling_the_shots = 22274, -- 260404
        lock_and_load = 22308, -- 194595
        piercing_shot = 22288, -- 198670
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3564, -- 196029
        adaptation = 3563, -- 214027
        gladiators_medallion = 3565, -- 208683

        trueshot_mastery = 658, -- 203129
        hiexplosive_trap = 657, -- 236776
        scatter_shot = 656, -- 213691
        spider_sting = 654, -- 202914
        scorpid_sting = 653, -- 202900
        viper_sting = 652, -- 202797
        survival_tactics = 651, -- 202746
        dragonscale_armor = 649, -- 202589
        roar_of_sacrifice = 3614, -- 53480
        rangers_finesse = 659, -- 248443
        sniper_shot = 660, -- 203155
        hunting_pack = 3729, -- 203235
    } )

    -- Auras
    spec:RegisterAuras( {
        a_murder_of_crows = {
            id = 131894,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_cheetah = {
            id = 186257,
            duration = 9,
            max_stack = 1,
        },
        aspect_of_the_turtle = {
            id = 186265,
            duration = 8,
            max_stack = 1,
        },
        binding_shot = {
            id = 117405,
            duration = 3600,
            max_stack = 1,
        },
        bursting_shot = {
            id = 186387,
            duration = 6,
            max_stack = 1,
        },
        camouflage = {
            id = 199483,
            duration = 60,
            max_stack = 1,
        },
        concussive_shot = {
            id = 5116,
            duration = 6,
            max_stack = 1,
        },
        double_tap = {
            id = 260402,
            duration = 15,
            max_stack = 1,
        },
        eagle_eye = {
            id = 6197,
        },
        explosive_shot = {
            id = 212431,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        feign_death = {
            id = 5384,
            duration = 360,
            max_stack = 1,
        },
        hunters_mark = {
            id = 257284,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },
        lethal_shots = {
            id = 260395,
            duration = 15,
            max_stack = 1,
        },
        lock_and_load = {
            id = 194594,
            duration = 15,
            max_stack = 1,
        },
        lone_wolf = {
            id = 155228,
            duration = 3600,
            max_stack = 1,
        },
        master_marksman = {
            id = 269576,
            duration = 12,
            max_stack = 1,
        },
        misdirection = {
            id = 35079,
            duration = 8,
            max_stack = 1,
        },
        pathfinding = {
            id = 264656,
            duration = 3600,
            max_stack = 1,
        },
        posthaste = {
            id = 118922,
            duration = 4,
            max_stack = 1,
        },
        precise_shots = {
            id = 260242,
            duration = 15,
            max_stack = 2,
        },
        rapid_fire = {
            id = 257044,
            duration = 2.97,
            max_stack = 1,
        },
        serpent_sting = {
            id = 271788,
            duration = 12,
            type = "Poison",
            max_stack = 1,
        },
        steady_focus = {
            id = 193534,
            duration = 12,
            max_stack = 1,
        },
        survival_of_the_fittest = {
            id = 281195,
            duration = 6,
            max_stack = 1,
        },
        trailblazer = {
            id = 231390,
            duration = 3600,
            max_stack = 1,
        },
        trick_shots = {
            id = 257622,
            duration = 20,
            max_stack = 1,
        },
        trueshot = {
            id = 288613,
            duration = 15,
            max_stack = 1,
        },


        -- Azerite Powers
        unerring_vision = {
            id = 274447,
            duration = function () return buff.trueshot.duration end,
            max_stack = 10,
            meta = {
                stack = function () return buff.unerring_vision.up and max( 1, ceil( query_time - buff.trueshot.applied ) ) end,
            }
        },
    } )


    spec:RegisterStateExpr( "ca_execute", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 80 or target.health.pct < 20 )
    end )


    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        a_murder_of_crows = {
            id = 131894,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 645217,

            talent = "a_murder_of_crows",

            handler = function ()
                applyDebuff( "target", "a_murder_of_crows" )
            end,
        },


        aimed_shot = {
            id = 19434,
            cast = function () return buff.lock_and_load.up and 0 or ( 2.5 * haste ) end,
            charges = 2,
            cooldown = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            recharge = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            gcd = "spell",

            spend = function () return buff.lock_and_load.up and 0 or 30 end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            handler = function ()
                applyBuff( "precise_shots" )
                if talent.master_marksman.enabled then applyBuff( "master_marksman" ) end
                removeBuff( "lock_and_load" )
                removeBuff( "steady_focus" )
                removeBuff( "lethal_shots" )
                removeBuff( "double_tap" )
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.master_marksman.up and 0 or 15 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132218,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeBuff( "master_marksman" )
                removeStack( "precise_shots" )
                removeBuff( "steady_focus" )
            end,
        },


        aspect_of_the_cheetah = {
            id = 186257,
            cast = 0,
            cooldown = function () return 180 * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) end,
            gcd = "off",

            startsCombat = false,
            texture = 132242,

            handler = function ()
                applyBuff( "aspect_of_the_cheetah" )
            end,
        },


        aspect_of_the_turtle = {
            id = 186265,
            cast = 0,
            cooldown = function () return 180 * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) end,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 132199,

            handler = function ()
                applyBuff( "aspect_of_the_turtle" )
                setCooldown( "global_cooldown", 5 )
            end,
        },


        barrage = {
            id = 120360,
            cast = 3,
            channeled = true,
            cooldown = 20,
            gcd = "spell",

            spend = 30,
            spendType = "focus",

            startsCombat = true,
            texture = 236201,

            talent = "barrage",

            handler = function ()
            end,
        },


        binding_shot = {
            id = 109248,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 462650,

            handler = function ()
                applyDebuff( "target", "binding_shot" )
            end,
        },


        bursting_shot = {
            id = 186387,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 10,
            spendType = "focus",

            startsCombat = true,
            texture = 1376038,

            handler = function ()
                applyDebuff( "target", "bursting_shot" )
                removeBuff( "steady_focus" )
            end,
        },


        camouflage = {
            id = 199483,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 461113,

            usable = function () return time == 0 end,
            handler = function ()
                applyBuff( "camouflage" )
            end,
        },


        concussive_shot = {
            id = 5116,
            cast = 0,
            cooldown = 5,
            gcd = "spell",

            startsCombat = true,
            texture = 135860,

            handler = function ()
                applyDebuff( "target", "concussive_shot" )
            end,
        },


        counter_shot = {
            id = 147362,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            startsCombat = true,
            texture = 249170,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        disengage = {
            id = 781,
            cast = 0,
            charges = 1,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                if talent.posthaste.enabled then applyBuff( "posthaste" ) end
            end,
        },


        double_tap = {
            id = 260402,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 537468,

            handler = function ()
                applyBuff( "double_tap" )
            end,
        },


        --[[ eagle_eye = {
            id = 6197,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132172,

            handler = function ()
            end,
        }, ]]


        exhilaration = {
            id = 109304,
            cast = 0,
            cooldown = function () return azerite.natures_salve.enabled and 105 or 120 end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 461117,

            handler = function ()
            end,
        },


        explosive_shot = {
            id = 212431,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = false,
            texture = 236178,

            handler = function ()
                applyDebuff( "target", "explosive_shot" )
                removeBuff( "steady_focus" )
            end,
        },


        feign_death = {
            id = 5384,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            startsCombat = false,
            texture = 132293,

            handler = function ()
                applyBuff( "feign_death" )
            end,
        },


        --[[ flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135815,

            handler = function ()
            end,
        }, ]]


        freezing_trap = {
            id = 187650,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "freezing_trap" )
            end,
        },


        hunters_mark = {
            id = 257284,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 236188,

            talent = "hunters_mark",

            usable = function () return debuff.hunters_mark.down end,
            handler = function ()
                applyDebuff( "target", "hunters_mark" )
            end,
        },


        masters_call = {
            id = 272682,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 236189,

            handler = function ()
                applyBuff( "masters_call" )
            end,
        },


        misdirection = {
            id = 34477,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            startsCombat = false,
            texture = 132180,

            handler = function ()
                applyBuff( "misdirection" )
            end,
        },


        multishot = {
            id = 257620,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.master_marksman.up and 0 or 15 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132330,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                if active_enemies > 2 then applyBuff( "trick_shots" ) end
                removeBuff( "master_marksman" )
                removeStack( "precise_shots" )
                removeBuff( "steady_focus" )
            end,
        },


        piercing_shot = {
            id = 198670,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 35,
            spendType = "focus",

            startsCombat = true,
            texture = 132092,

            handler = function ()
                removeBuff( "steady_focus" )
            end,
        },


        rapid_fire = {
            id = 257044,
            cast = function () return ( 3 * haste ) + ( talent.streamline.enabled and 0.6 or 0 ) end,
            channeled = true,
            cooldown = function () return buff.trueshot.up and ( haste * 8 ) or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 461115,

            handler = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "lethal_shots" )
                removeBuff( "trick_shots" )
            end,
            postchannel = function () removeBuff( "double_tap" ) end,
        },


        serpent_sting = {
            id = 271788,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 10,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 45,

            talent = "serpent_sting",

            recheck = function () return remains - ( duration * 0.3 ), remains end,
            handler = function ()
                applyDebuff( "target", "serpent_sting" )
                removeBuff( "steady_focus" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.75,
            cooldown = 0,
            gcd = "spell",

            spend = -10,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled then applyBuff( "steady_focus", 12, min( 2, buff.steady_focus.stack + 1 ) ) end
                if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 4 end
            end,
        },


        summon_pet = {
            id = 883,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "focus",

            startsCombat = false,
            essential = true,
            texture = function () return GetStablePetInfo(1) or 'Interface\\ICONS\\Ability_Hunter_BeastCall' end,

            usable = function () return false and not pet.exists end, -- turn this into a pref!
            handler = function ()
                summonPet( 'made_up_pet', 3600, 'ferocity' )
            end,
        },


        survival_of_the_fittest = {
            id = function () return pet.exists and 264735 or 281195 end,
            cast = 0,
            cooldown = 180,
            gcd = "off",
            known = function ()
                if not pet.exists then return 155228 end
            end,

            toggle = "defensives",

            startsCombat = false,

            usable = function ()
                return not pet.exists or pet.alive, "requires either no pet or a living pet"
            end,
            handler = function ()
                applyBuff( "survival_of_the_fittest" )
            end,

            copy = { 264735, 281195, 155228 }
        },        


        tar_trap = {
            id = 187698,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 576309,

            handler = function ()
                applyDebuff( "target", "tar_trap" )
            end,
        },


        trueshot = {
            id = 288613,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132329,

            handler = function ()
                applyBuff( "trueshot" )
                if azerite.unerring_vision.enabled then
                    applyBuff( "unerring_vision" )
                end
            end,

            meta = {
                duration_guess = function( t )
                    return talent.calling_the_shots.enabled and 90 or t.duration
                end,
            }
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20200124, [[dO0qdbqiLk9ivfztOqFsPIyusQCkjrRsPcIxPu1SKKClLku7Ik)svPHrsCmvvTmQs9mQsAAQkQRPQW2qb5BssLXPurDojPQ1PubMNsX9Ok2NKQoOsfPfss6HOGQUikOIpQubPrIck5KOGcRuszMkviDtLke7ef1qvQGAPOGI6PQYuvv5QOGk9vuqrglkOu7fQ)sQbtPdRyXK4XOAYsCzInl0NjPgnfoTuRwsk8AuKzRKBJs7wLFlA4uvhxskA5GEoW0rUUGTtvIVRuA8ssPZljSEuG5tr7hY4)4F4xzibZS3Q4TkQ837p7uP6)x9F8b(rv4l4N)WzAul43nSc(TJmqMaSZbmAF8ZFQyLtb)d)azaYf87tiRbr(GDW3VQBYiO44j7xqZgwd15XHtK(cAw(x8tj0lIHXHvWVYqcMzVvXBvu5V3F2Ps1)V6)mdHFtGmsi(9AwgE8ZOlf5Wk4xraC87ti7oYazcWohWO9rwgwHJeiQ2NqwdI8b7GVFv3KrqXXt2VGMnSgQZJdNi9f0S8VOAFczRnxyGvGSE)VkK1Bv8wfunuTpHSm8gZPwa7auTpHS7yKDNwkiBG6vtvGS(WoHnvbYsjYUt3H3rDOAFcz3XildxGGSuZkAk1Lwqw4qgcezjJ5qwAGQfYrnROPuxAbzPezNJAE7pKGSYvq2mIS8Kvzih(TAabW)Wpc2CMagjbW)Wm)h)d)go15HFkdeoQf8tUrzjfSQycZS34F43WPop8tQw)vcAViAGrs4NCJYskyvXeMzVI)HFYnklPGvf)4WMeyp4NsigDeS5mPbgjbCbFKLrKLpAPAfEGeKLrKvjeJUsguwIMgFxWh)go15HFtZkfnWijmHz(Z4F4NCJYskyvXpoSjb2d(PeIrhbBotAGrsaxWhzzezRdzhgiWMexm5bGu0Xgko5gLLuqwttKDyGaBsC9PjdrdnQGmyDW5yczRhz)JSMMi7Wab2K4abO6(uRbgjbCYnklPGSMMilnl5ihGGYWU6tCYnklPGSvIFdN68Wp443fDSHcMWm)b(h(j3OSKcwv8JdBsG9GFkHy0rWMZKgyKeWf8rwgr26qwLqm68HcVbIgyKeWvYThYAAIS8mxLC75MMvkAGrsUyyT0qHBmq1IMAwbz3GSdN68CtZkfnWijhFaKMAwbznnrwLqm6iyqagj5c(iBL43WPop8BAwPObgjHjmZme(h(j3OSKcwv8JdBsG9GFkHy0rWMZKgyKeWf8XVHtDE4hC87Io2qbtyMRo8p8tUrzjfSQ4hh2Ka7b)ucXOJGnNjnWijGRKBpK10ezvcXOZhk8giAGrsaxWhzzez3fzvcXOJGbbyKKl4JSMMiBm5baYwpYwDQGFdN68Wp2WIAGrsycZ8oJ)HFdN68WVyYdaPOhgiWMeTImS4NCJYskyvXeM5Qh)d)go15HF(byhROp1AL1ai8tUrzjfSQycZ8FvW)WVHtDE4hppUCeCiPOJRHvWp5gLLuWQIjmZ))J)HFdN68WpLvMfDg1KHOLtyRa)KBuwsbRkMWm)3B8p8tUrzjfSQ4hh2Ka7b)ucXOdkCMwcaOJjKlUGpYAAISkHy0bfotlba0XeYfnpdhjqhGgoti7gK9Vk43WPop8JmeD4uYWv0XeYfmHz(VxX)WVHtDE4NFlqEFQ1aJKWp5gLLuWQIjmZ))m(h(nCQZd)gnBaweOoJAom3cWp5gLLuWQIjmZ))a)d)KBuwsbRk(XHnjWEWpOeHcWyuwcYYiYUlYoCQZZbeOVCKgq9P21NoUA1ge(nCQZd)ac0xosdO(uJjmZ)zi8p8B4uNh(bizkvObgjHFYnklPGvftyc)ksCclc)dZ8F8p8tUrzjfSQ4hh2Ka7b)kIsigD8bq9P2f8rwttKvjeJUsd8L1AuwIMDu3CxWhznnrwLqm6knWxwRrzjA5GJAXf8XVHtDE4hFwl9WPop9Qbe(TAaPVHvWVa1RMQatyM9g)d)KBuwsbRk(nCQZd)wbitceO7d0LodaT6os4hh2Ka7b)4zUk52ZrWGamsYbf2PpGwDqaaKDdY()dK10ezPMv0uQlTGSBqwVQc(DdRGFRaKjbc09b6sNbGwDhjmHz2R4F4NCJYskyvXVHtDE43WaGXahGoMhPZO2p3kq8JdBsG9GF1HSuZkAk1Lwq26r2HtDEAEMRsU9q29iRx)mYAAIS0avlKZqMfz485eYUbz9wfK10ezPbQwih1SIMsTpN0ERcYUbz))bYwjYYiYYZCvYTNJGbbyKKdkStFaT6Gaai7gK9)hiRPjYsnROPuxAbz3GSE9d87gwb)ggamg4a0X8iDg1(5wbIjmZFg)d)KBuwsbRk(nCQZd)wbabZaqRoxf50(Ra7OwWpoSjb2d(XZCvYTNJGbbyKKdkStFaT6Gaai7gK9dK10ezPMv0uQlTGSBqwVvb)UHvWVvaqWma0QZvroT)kWoQfmHz(d8p8tUrzjfSQ43WPop8t9Se(SwceOvY8WpoSjb2d(PeIrhbdcWijxWhznnr2DrwAwYro(Sw9PwtgIgyKeWj3OSKcYAAISuZkAk1Lwq2ni7FvWVByf8t9Se(SwceOvY8WeMzgc)d)KBuwsbRk(nCQZd)gGHxMtaA4WGeQ5jCw4hh2Ka7b)ucXOJGbbyKKl4JSmIS1HSkHy0PomWspNoJ6HbcmjdxWhznnr2DrwbaKJloEEf5asrV6OetixCSt1iHilJilnq1c5mKzrgoFoHSBqwVvbzReznnr2IOeIrhCyqc18eolDrucXORKBpK10ezPMv0uQlTGSBqwVvb)UHvWVby4L5eGgomiHAEcNfMWmxD4F4NCJYskyvXVHtDE4NFYzsiqZaPO5jRFGgQZtxeV0Cb)4WMeyp43UiRsigDemiaJKCbFKLrKDxKvaa54ItzLzrNrnziA5e2kCSt1iHiRPjYweLqm6uwzw0zutgIwoHTcxWhznnrwQzfnL6sli7gK9d87gwb)8totcbAgifnpz9d0qDE6I4LMlycZ8oJ)HFYnklPGvf)4WMeyp4NsigDemiaJKCbFK10ez3fzPzjh54ZA1NAnziAGrsaNCJYskiRPjYsnROPuxAbz3GSERc(nCQZd)car3KWcWeM5Qh)d)KBuwsbRk(nCQZd)4ZAPho15PxnGWVvdi9nSc(XlamHz(Vk4F4NCJYskyvXpoSjb2d(nCQ9IOLtyBbGSBqwVIFdN68Wp(Sw6HtDE6vdi8B1asFdRGFactyM))h)d)KBuwsbRk(XHnjWEWVHtTxeTCcBlaKTEK1B8B4uNh(XN1spCQZtVAaHFRgq6Byf8JGnNjGrsamHj8Zhk8Kvzi8pmZ)X)WVHtDE4Nr4ibc0SdKj8tUrzjfSQycZS34F4NCJYskyvXpFOWhaPPMvWV)QGFdN68WVsguwIMgFmHz2R4F4NCJYskyvXVByf8ByaWyGdqhZJ0zu7NBfi(nCQZd)ggamg4a0X8iDg1(5wbIjmZFg)d)go15HFBt4Q4fPpnua5nhxWp5gLLuWQIjmZFG)HFdN68Wp1Hbw650zupmqGjzGFYnklPGvftyMzi8p8B4uNh(XkSjScDg1RaVl6cugwa(j3OSKcwvmHzU6W)Wp5gLLuWQIF(qHpastnRGF)DFGFdN68WpcgeGrs4hh2Ka7b)go1Er0YjSTaq26rwVXeM5Dg)d)go15HF(j15HFYnklPGvftyMRE8p8tUrzjfSQ4hh2Ka7b)go1Er0YjSTaq2niRxXVHtDE430Ssrdmsctyc)4fa(hM5)4F4NCJYskyvXpoSjb2d(veLqm6mchjqGMDGm5k52dzzez3fzvcXOJGbbyKKl4JFdN68WpJWrceOzhitycZS34F4NCJYskyvXpoSjb2d(XZCvYTNdo(DrhBO4Gc70haz3GSQ5fK10ez5zUk52Zbh)UOJnuCqHD6dGSBqwEMRsU9CtZkfnWijhuyN(aiRPjYsnROPuxAbz3GSERc(nCQZd)kzqzjAA8XeMzVI)HFYnklPGvf)4WMeyp4NsigDemiaJKCbFKLrKToKLAwrtPU0cYwpYYZCvYTNtrGabYuFQDLaCOopKDpYwcWH68qwttKToKLgOAHCgYSidNpNq2niR3QGSMMi7Uilnl5ihFGsmS0tZ6KBuwsbzRezReznnrwQzfnL6sli7gK9VxXVHtDE4NIabcKP(uJjmZFg)d)KBuwsbRk(XHnjWEWpLqm6iyqagj5c(ilJiBDil1SIMsDPfKTEKLN5QKBpNYkZIogGv4kb4qDEi7EKTeGd15HSMMiBDilnq1c5mKzrgoFoHSBqwVvbznnr2DrwAwYro(aLyyPNM1j3OSKcYwjYwjYAAISuZkAk1Lwq2ni7Fgc)go15HFkRml6yawbMWm)b(h(j3OSKcwv8JdBsG9GFkHy0rWGamsYf8rwgr26qwQzfnL6sliB9ilpZvj3EU54cGGZsZN1YvcWH68q29iBjahQZdznnr26qwAGQfYziZImC(Ccz3GSERcYAAIS7IS0SKJC8bkXWspnRtUrzjfKTsKTsK10ezPMv0uQlTGSBq2)me(nCQZd)MJlacolnFwlmHzMHW)Wp5gLLuWQIFCytcSh8tjeJocgeGrsUGpYYiYwhYsnROPuxAbzRhz5zUk52ZfBOOSYS4kb4qDEi7EKTeGd15HSMMiBDilnq1c5mKzrgoFoHSBqwVvbznnr2DrwAwYro(aLyyPNM1j3OSKcYwjYwjYAAISuZkAk1Lwq2niB1JFdN68WVydfLvMfmHzU6W)WVHtDE43QvBqaD1iuuZkhHFYnklPGvftyM3z8p8B4uNh(PmQ1zutWMZea)KBuwsbRkMWmx94F4NCJYskyvXpoSjb2d(rduTqodzwKHZNtiB9i7oRcYAAIS0avlKZqMfz485eYUXdY6TkiRPjYsduTqoQzfnLAFoP9wfKTEK1RQGFdN68WpOm(9PwhxdRaWeM5)QG)HFYnklPGvf)4WMeyp4xDilpZvj3EUHbaJboaDmpsNrTFUvGoOWo9bq26rwVvbznnr2DrwPAgAFFP4ggamg4a0X8iDg1(5wbISMMil1SIMsDPfKDdYYZCvYTNByaWyGdqhZJ0zu7NBfOReGd15HS7rwV(zKLrKLgOAHCgYSidNpNq26rwVvbzRezzezRdz5zUk52ZrWGamsYbf2PpGwDqaaKDdY6vK10ezRdzfaqoU48sd680zu7lWOWPophBFjezzezPMv0uQlTGS1JSdN6808mxLC7HS7rwLqm62MWvXlsFAOaYBoU4kb4qDEiBLiBLiRPjYsnROPuxAbz3GSERc(nCQZd)2MWvXlsFAOaYBoUGjmZ))J)HFYnklPGvf)4WMeyp4xDilF0s1k8ajiRPjYsduTqoQzfnL6sliB9i7WPopnpZvj3Ei7EK1RQGSvISmIS1HSkHy0rWGamsYf8rwttKLN5QKBphbdcWijhuyN(ai7gK9pdHSvISMMil1SIMsDPfKDdY61)43WPop8tDyGLEoDg1ddeysgycZ8FVX)Wp5gLLuWQIFCytcSh8JN5QKBphbdcWijhuyN(ai7gKT6WVHtDE4hS99xIUpnWF4cMWm)3R4F4NCJYskyvXpoSjb2d(TlYQeIrhbdcWijxWh)go15HFScBcRqNr9kW7IUaLHfGjmZ))m(h(j3OSKcwv8JdBsG9GFkHy0rWGamsYbLHtilJiRsigDkRmlRaGCqz4eYAAISkHy0rWGamsYf8rwgrwAGQfYziZImC(Ccz3GSERcYAAIS1HS1HS88ab2rzjo)K680zuhofyxwsrhdWkqwttKLNhiWoklXfofyxwsrhdWkq2krwgrwQzfnL6sli7gKLH(JSMMil1SIMsDPfKDdY6ndHSvIFdN68Wp)K68WeM5)FG)HFYnklPGvf)4WMeyp4xm5baYwpYYqQGSmIS1HSkHy05dfEdenWijGRKBpKLrKLN5QKBphC87Io2qXbf2PpaYYiYsnROPuxAbzRhz5zUk52ZrWGamsYvcWH680QdcaGS7rwLqm6iyqagj5kb4qDEiRPjYsduTqodzwKHZNti7gK1BvqwttKDxKLMLCKJpqjgw6PzDYnklPGSvISmIS1HS7ISs1m0((sXnmaymWbOJ5r6mQ9ZTceznnrwEMRsU9CddagdCa6yEKoJA)CRaDqHD6dGS1JS))azRezReznnrwQzfnL6sli7gK9)h43WPop8JGbbyKeMWe(bi8pmZ)X)WVHtDE4NuT(Re0Er0aJKWp5gLLuWQIjmZEJ)HFYnklPGvf)4WMeyp43WP2lIwoHTfaYwpY(h)go15HFkdeoQfmHz2R4F43WPop8B0SbyrG6mQ5WCla)KBuwsbRkMWm)z8p8tUrzjfSQ4hh2Ka7b)GsekaJrzjilJi7Ui7WPophqG(YrAa1NAxF64QvBq43WPop8diqF5inG6tnMWm)b(h(j3OSKcwv8JdBsG9GFkHy0rWGamsYvYThYAAISXKhai7gKT6ub)go15HFWXVl6ydfmHzMHW)Wp5gLLuWQIFCytcSh8tjeJocgeGrsUGpYYiYwhYQeIrx4eiSp1AV0GophGgotiB9i7NrwttKDxKDyGaBsCHtGW(uR9sd68CYnklPGSvISMMil1SIMsDPfKDdY()p(nCQZd)uwzw0zutgIwoHTcmHzU6W)Wp5gLLuWQIFCytcSh8BxKvjeJocgeGrsUGpYAAISuZkAk1Lwq2ni7h43WPop8lM8aqk6HbcSjrRidlMWmVZ4F4NCJYskyvXpoSjb2d(PeIrhbdcWijxWhzzezvcXOJDaKa1SdKja7CUGpYYiYUlYQeIrhRWMWk0zuVc8UOlqzybUGp(nCQZd)giFordmsctyMRE8p8tUrzjfSQ4hh2Ka7b)ucXOJGbbyKKl4JSMMiBDiRsigDLmOSenn(UsU9qwttKLpAPAfEGeKTsKLrKvjeJoFOWBGObgjbCLC7HSMMiBmSwAOWngOArtnRGSBqw(ain1ScYYiYYZCvYTNJGbbyKKdkStFa8B4uNh(nnRu0aJKWeM5)QG)HFYnklPGvf)4WMeyp4NsigDemiaJKCbFKLrKvjeJo2bqcuZoqMaSZ5c(ilJiRsigDScBcRqNr9kW7IUaLHf4c(43WPop8BG85enWijmHz()F8p8B4uNh(53cK3NAnWij8tUrzjfSQycZ8FVX)Wp5gLLuWQIFCytcSh8BxKvjeJocgeGrsUGpYAAISuZkAk1Lwq2ni7oJFdN68Wp)aSJv0NATYAaeMWm)3R4F4NCJYskyvXpoSjb2d(ftEaGS7r2yYdahuulhYUdbzvZli7gKnM8aWXovlYYiYQeIrhbdcWijxj3EilJiBDi7UiBjjhppUCeCiPOJRHv0kb45Gc70hazzez3fzho15545XLJGdjfDCnSIRpDC1QniKTsK10ezJH1sdfUXavlAQzfKDdYQMxqwttKLgOAHCuZkAk1Lwq2ni7h43WPop8JNhxocoKu0X1WkycZ8)pJ)HFYnklPGvf)4WMeyp4NsigDqHZ0saaDmHCXf8rwttKvjeJoOWzAjaGoMqUO5z4ib6a0Wzcz3GS)vbznnrwQzfnL6sli7gK9d8B4uNh(rgIoCkz4k6yc5cMWm))d8p8tUrzjfSQ4hh2Ka7b)ucXOJGbbyKKRKBpKLrKToKvjeJoFOWBGObgjbCbFKLrKToKnM8aazRhz)8FK10ezvcXOJDaKa1SdKja7CUGpYwjYAAIS1HSXKhaiB9i7hQGSmISddeytIlM8aqk6ydfNCJYskiRPjYgtEaGS1JSv3hiBLilJiBDilpZvj3EocgeGrsoOWo9bq26r2pqwttKnM8aazRhz3zvq2krwttKLAwrtPU0cYUbz)azRe)go15HFdKpNObgjHjmZ)zi8p8B4uNh(bizkvObgjHFYnklPGvftyc)cuVAQc8pmZ)X)WVHtDE4hpdhjqnWij8tUrzjfSQycZS34F43WPop8diq5AQcDjai8tUrzjfSQycZSxX)WVHtDE4hWpHIMVYqb)KBuwsbRkMWm)z8p8B4uNh(bYKm6tTE7qce)KBuwsbRkMWm)b(h(nCQZd)a51CTYAae(j3OSKcwvmHzMHW)WVHtDE43jKHa1aJKZe(j3OSKcwvmHzU6W)WVHtDE4h3ORgnqtW5QMHE1uf4NCJYskyvXeM5Dg)d)go15HFa)g2KgyKCMWp5gLLuWQIjmZvp(h(nCQZd)UHcqbOvdhUGFYnklPGvftyct4NxeiOZdZS3Q8V6vP69(d8B7aV(udWpgM2PmmZmddM3HUdqwK9NHGSnRFcjKnMqKDNWlGDcYcLQzOHsbzbjRGStGs2HKcYYnMtTaCOA7O9ji7)p2bildFEErGKuq2Dcb7JjHCmSD8mxLC7Ttqwkr2DcpZvj3Eog27eKTU)vBLoununggS(jKKcYYqi7WPopKD1ac4q1WpGVWXm79hFg)8HzSxc(9jKDhzGmbyNdy0(ildRWrcev7tiRbr(GDW3VQBYiO44j7xqZgwd15XHtK(cAw(xuTpHS1MlmWkqwV)xfY6TkERcQgQ2NqwgEJ5ulGDaQ2Nq2DmYUtlfKnq9QPkqwFyNWMQazPez3P7W7OouTpHS7yKLHlqqwQzfnL6slilCidbISKXCilnq1c5OMv0uQlTGSuISZrnV9hsqw5kiBgrwEYQmKdvdv7tildNQv4bskiRIetOGS8KvziKvru3hWHS7uox8jaYE5TJngiBmSq2HtDEaKnVvfouTpHSdN68aoFOWtwLH8exdGjuTpHSdN68aoFOWtwLH2757euZkhnuNhQ2Nq2HtDEaNpu4jRYq798nMzbv7ti77gFGrsilC6cYQeIrPGSaAiaYQiXekilpzvgczve19bq25kiRpu2X(jr9PgzBaYwYtCOAFczho15bC(qHNSkdT3ZxWn(aJK0aAiaQ2WPopGZhk8KvzO9E(AeosGan7azcv7ti7omu4dGqwYObi7aqwzGRkq2bGS(ja0klbzPez9tsoQN1QcKv90hYoxsgcez5dGq2sa2NAKLmeKn2QnihQ2WPopGZhk8KvzO9E(wYGYs004xLpu4dG0uZkE(RcQ2WPopGZhk8KvzO9E(gaIUjHTQByfpddagdCa6yEKoJA)CRar1go15bC(qHNSkdT3Z3TjCv8I0NgkG8MJlOAdN68aoFOWtwLH275R6Wal9C6mQhgiWKmq1go15bC(qHNSkdT3ZxwHnHvOZOEf4DrxGYWcq1go15bC(qHNSkdT3ZxcgeGrsv5df(ain1SIN)UpQQJEgo1Er0YjSTaQ3BuTHtDEaNpu4jRYq7981pPopuTHtDEaNpu4jRYq798DAwPObgjvvh9mCQ9IOLtyBbSXROAOAdN68aUa1RMQWdpdhjqnWijuTHtDEaxG6vtvS3ZxGaLRPk0LaGq1go15bCbQxnvXEpFb(ju08vgkOAdN68aUa1RMQyVNVGmjJ(uR3oKar1go15bCbQxnvXEpFb51CTYAaeQ2WPopGlq9QPk2757jKHa1aJKZeQ2WPopGlq9QPk275l3ORgnqtW5QMHE1ufOAdN68aUa1RMQyVNVa)g2KgyKCMq1go15bCbQxnvXEpFVHcqbOvdhUGQHQ9jKLHt1k8ajfKv8IaRazPMvqwYqq2HtjezBaYoEz61OSehQ2WPopGh(Sw6HtDE6vdOQUHv8eOE1ufv1rpfrjeJo(aO(u7c(MMkHy0vAGVSwJYs0SJ6M7c(MMkHy0vAGVSwJYs0Ybh1Il4JQnCQZdS3Z3aq0njSvDdR4zfGmjqGUpqx6ma0Q7ivvh9WZCvYTNJGbbyKKdkStFaT6GaaB()HPj1SIMsDPLnEvfuTHtDEG9E(gaIUjHTQByfpddagdCa6yEKoJA)CRaRQJEQJAwrtPU0s98mxLC7T3RF20KgOAHCgYSidNpN24TkMM0avlKJAwrtP2NtAVvzZ)pQKrEMRsU9CemiaJKCqHD6dOvheayZ)pmnPMv0uQlTSXRFGQnCQZdS3Z3aq0njSvDdR4zfaemdaT6CvKt7VcSJAPQo6HN5QKBphbdcWijhuyN(aA1bba28HPj1SIMsDPLnERcQ2WPopWEpFdar3KWw1nSIh1Zs4ZAjqGwjZRQo6rjeJocgeGrsUGVP5U0SKJC8zT6tTMmenWijGtUrzjfttQzfnL6slB(RcQ2WPopWEpFdar3KWw1nSINby4L5eGgomiHAEcNvvD0JsigDemiaJKCbFgRtjeJo1Hbw650zupmqGjz4c(MM7kaGCCXXZRihqk6vhLyc5IJDQgjKrAGQfYziZImC(CAJ3QuPPzrucXOdomiHAEcNLUikHy0vYTNPj1SIMsDPLnERcQ2WPopWEpFdar3KWw1nSIh)KZKqGMbsrZtw)anuNNUiEP5svD0ZUkHy0rWGamsYf8zCxbaKJloLvMfDg1KHOLtyRWXovJeAAweLqm6uwzw0zutgIwoHTcxW30KAwrtPU0YMpq1(eY(dwbYsjYU6tq2GpYoCQ9YqsbzjyFmjeaz32KbY(dgeGrsOAdN68a798naeDtclOQo6rjeJocgeGrsUGVP5U0SKJC8zT6tTMmenWijGtUrzjfttQzfnL6slB8wfuTHtDEG9E(YN1spCQZtVAav1nSIhEbGQnCQZdS3Zx(Sw6HtDE6vdOQUHv8aOQ6ONHtTxeTCcBlGnEfvB4uNhyVNV8zT0dN680RgqvDdR4HGnNjGrsGQ6ONHtTxeTCcBlG69gvdvB4uNhWXlapgHJeiqZoqMQQJEkIsigDgHJeiqZoqMCLC7X4UkHy0rWGamsYf8r1go15bC8cyVNVLmOSenn(v1rp8mxLC75GJFx0XgkoOWo9b2OMxmn5zUk52Zbh)UOJnuCqHD6dSHN5QKBp30SsrdmsYbf2PpGPj1SIMsDPLnERcQ2WPopGJxa798vrGabYuFQRQJEucXOJGbbyKKl4ZyDuZkAk1LwQNN5QKBpNIabcKP(u7kb4qDE7lb4qDEMM1rduTqodzwKHZNtB8wftZDPzjh54duIHLEAwNCJYskvwPPj1SIMsDPLn)9kQ2WPopGJxa798vzLzrhdWkQQJEucXOJGbbyKKl4ZyDuZkAk1LwQNN5QKBpNYkZIogGv4kb4qDE7lb4qDEMM1rduTqodzwKHZNtB8wftZDPzjh54duIHLEAwNCJYskvwPPj1SIMsDPLn)ziuTHtDEahVa2757CCbqWzP5ZAvvh9OeIrhbdcWijxWNX6OMv0uQlTuppZvj3EU54cGGZsZN1YvcWH682xcWH68mnRJgOAHCgYSidNpN24TkMM7sZsoYXhOedl90So5gLLuQSsttQzfnL6slB(ZqOAdN68aoEbS3Z3ydfLvMLQ6OhLqm6iyqagj5c(mwh1SIMsDPL65zUk52ZfBOOSYS4kb4qDE7lb4qDEMM1rduTqodzwKHZNtB8wftZDPzjh54duIHLEAwNCJYskvwPPj1SIMsDPLnvpQ2WPopGJxa798D1QniGUAekQzLJq1go15bC8cyVNVkJADg1eS5mbq1go15bC8cyVNVqz87tToUgwbuvh9qduTqodzwKHZNt1VZQyAsduTqodzwKHZNtB84TkMM0avlKJAwrtP2NtAVvPEVQcQ2WPopGJxa798DBcxfVi9PHciV54svD0tD8mxLC75ggamg4a0X8iDg1(5wb6Gc70hOEVvX0CxPAgAFFP4ggamg4a0X8iDg1(5wbAAsnROPuxAzdpZvj3EUHbaJboaDmpsNrTFUvGUsaouN3EV(zgPbQwiNHmlYW5ZP69wLkzSoEMRsU9CemiaJKCqHD6dOvheayJxnnRtaa54IZlnOZtNrTVaJcN68CS9LqgPMv0uQlTuppZvj3E7vcXOBBcxfVi9PHciV54IReGd15vzLMMuZkAk1Lw24TkOAdN68aoEbS3Zx1Hbw650zupmqGjzuvh9uhF0s1k8ajMM0avlKJAwrtPU0s98mxLC7T3RQujJ1PeIrhbdcWijxW30KN5QKBphbdcWijhuyN(aB(ZqvAAsnROPuxAzJx)JQnCQZd44fWEpFHTV)s09Pb(dxQQJE4zUk52ZrWGamsYbf2PpWMQdvB4uNhWXlG9E(YkSjScDg1RaVl6cugwqvD0ZUkHy0rWGamsYf8r1go15bC8cyVNV(j15vvh9OeIrhbdcWijhugoXOsigDkRmlRaGCqz4KPPsigDemiaJKCbFgPbQwiNHmlYW5ZPnERIPzD1XZdeyhLL48tQZtNrD4uGDzjfDmaRW0KNhiWoklXfofyxwsrhdWkQKrQzfnL6slByO)MMuZkAk1Lw24ndvjQ2WPopGJxa798LGbbyKuvD0tm5bq9mKkmwNsigD(qH3ardmsc4k52JrEMRsU9CWXVl6ydfhuyN(amsnROPuxAPEEMRsU9CemiaJKCLaCOopT6Gaa7vcXOJGbbyKKReGd15zAsduTqodzwKHZNtB8wftZDPzjh54duIHLEAwNCJYskvYyD7kvZq77lf3WaGXahGoMhPZO2p3kqttc2htc5ggamg4a0X8iDg1(5wb64zUk52Zbf2Ppq9))OYknnPMv0uQlTS5)hOAOAdN68aoa5rQw)vcAViAGrsOAdN68aoaT3ZxLbch1svD0ZWP2lIwoHTfq9)r1go15bCaAVNVJMnalcuNrnhMBbOAdN68aoaT3ZxGa9LJ0aQp1v1rpqjcfGXOSeg3D4uNNdiqF5inG6tTRpDC1QniuTHtDEahG275lC87Io2qPQo6rjeJocgeGrsUsU9mnJjpa2uDQGQ9jKTJEucXOJGbbyKKl4ZyDkHy0fobc7tT2lnOZZbOHZu9F20C3HbcSjXfobc7tT2lnOZZj3OSKsLMM0avlKJAwrtPU0YM))r1go15bCaAVNVkRml6mQjdrlNWwrvD0JsigDemiaJKCbFgRtjeJUWjqyFQ1EPbDEoanCMQ)ZMM7omqGnjUWjqyFQ1EPbDEo5gLLuQ00KAwrtPU0YM))r1go15bCaAVNVXKhasrpmqGnjAfzyRQJE2vjeJocgeGrsUGVPj1SIMsDPLnFGQnCQZd4a0EpFhiFordmsQQo6rjeJocgeGrsUGpJkHy0XoasGA2bYeGDoxWNXDvcXOJvytyf6mQxbEx0fOmSaxWhvB4uNhWbO9E(onRu0aJKQQJEucXOJGbbyKKl4BAwNsigDLmOSenn(UsU9mn5JwQwHhiPsgvcXOZhk8giAGrsaxj3EMMXWAPHc3yGQfn1SYg(ain1ScJ8mxLC75iyqagj5Gc70havB4uNhWbO9E(oq(CIgyKuvD0JsigDemiaJKCbFgvcXOJDaKa1SdKja7CUGpJkHy0XkSjScDg1RaVl6cugwGl4JQnCQZd4a0EpF9BbY7tTgyKeQ2WPopGdq7981pa7yf9PwRSgavvh9SRsigDemiaJKCbFttQzfnL6slB2zuTHtDEahG275lppUCeCiPOJRHvQQJEIjpa2htEa4GIA52HOMx2etEa4yNQLrLqm6iyqagj5k52JX62TKKJNhxocoKu0X1WkALa8CqHD6dW4UdN68C884YrWHKIoUgwX1NoUA1guLMMXWAPHc3yGQfn1SYg18IPjnq1c5OMv0uQlTS5duTHtDEahG275lzi6WPKHROJjKlv1rpkHy0bfotlba0XeYfxW30ujeJoOWzAjaGoMqUO5z4ib6a0WzAZFvmnPMv0uQlTS5duTHtDEahG2757a5ZjAGrsv1rpkHy0rWGamsYvYThJ1PeIrNpu4nq0aJKaUGpJ1ftEau)N)BAQeIrh7aibQzhita25Cb)knnRlM8aO(puHXHbcSjXftEaifDSHItUrzjftZyYdG6RUpQKX64zUk52ZrWGamsYbf2Ppq9FyAgtEau)oRsLMMuZkAk1Lw28rLOAdN68aoaT3ZxajtPcnWijunuTHtDEahbBotaJKaEugiCulOAdN68aoc2CMagjb275RuT(Re0Er0aJKq1go15bCeS5mbmscS3Z3PzLIgyKuvD0JsigDeS5mPbgjbCbFg5JwQwHhiHrLqm6kzqzjAA8DbFuTHtDEahbBotaJKa798fo(DrhBOuvh9OeIrhbBotAGrsaxWNX6ggiWMexm5bGu0Xgko5gLLumnhgiWMexFAYq0qJkidwhCoMQ)VP5Wab2K4abO6(uRbgjbCYnklPyAsZsoYbiOmSR(eNCJYskvIQnCQZd4iyZzcyKeyVNVtZkfnWiPQ6OhLqm6iyZzsdmsc4c(mwNsigD(qH3ardmsc4k52Z0KN5QKBp30SsrdmsYfdRLgkCJbQw0uZkBgo155MMvkAGrso(ain1SIPPsigDemiaJKCb)kr1go15bCeS5mbmscS3Zx443fDSHsvD0JsigDeS5mPbgjbCbFuTHtDEahbBotaJKa798LnSOgyKuvD0JsigDeS5mPbgjbCLC7zAQeIrNpu4nq0aJKaUGpJ7QeIrhbdcWijxW30mM8aO(QtfuTHtDEahbBotaJKa798nM8aqk6HbcSjrRidlQ2WPopGJGnNjGrsG9E(6hGDSI(uRvwdGq1go15bCeS5mbmscS3ZxEEC5i4qsrhxdRGQnCQZd4iyZzcyKeyVNVkRml6mQjdrlNWwbQ2WPopGJGnNjGrsG9E(sgIoCkz4k6yc5svD0JsigDqHZ0saaDmHCXf8nnvcXOdkCMwcaOJjKlAEgosGoanCM28xfuTHtDEahbBotaJKa7981VfiVp1AGrsOAdN68aoc2CMagjb2757OzdWIa1zuZH5waQ2WPopGJGnNjGrsG9E(ceOVCKgq9PUQo6bkrOamgLLW4UdN68Cab6lhPbuFQD9PJRwTbHQnCQZd4iyZzcyKeyVNVasMsfAGrsyctym]] )


end