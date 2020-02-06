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

            start = function ()
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

            start = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "lethal_shots" )
                removeBuff( "trick_shots" )
            end,

            finish = function () removeBuff( "double_tap" ) end,
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


    spec:RegisterPack( "Marksmanship", 20200206, [[dSurdbqivfEKQISjuWNuQOmkjjNss0QOkrPxPu1SKK6wQkQSlQ8lvLggjXXqHwgvPEgvjnnQs4AkvABkv4BskQXPQOCoQsK1jPiMNsX9Ok2NKshuPIQfss6HskixKQev2ivjQ6JskOAKuLO4KkvewPKQzQurQBQurYorrgQsfrlvvrv6PQYuvv5QQkQQVQQOkgRKck7fQ)sQbtXHvSys8yunzjUmXMf6ZKuJMsoTuRwsbEnkQzRKBJs7wLFlA4uvhxsrA5GEoW0rUUGTRQQ(UsPXlPqNxsy9QQY8Pu7hYygX)WVYqcMjVvXBvuXBv2HJXD31l5vVIFuf(c(5pCMh1c(DdRGF7udKza7CaR2h)8Nkw5uW)WpqgGCb)(eYyrKpOM89R6MSckoEY(f0SH1qDEC4ePVGML)f)uc9I2joSc(vgsWm5TkERIkERYoCmU7UEjV6n(nbYkH43RzRHWpRUuKdRGFfbWXVpHm7udKza7CaR2hz8YeosGO6FczSiYhut((vDtwbfhpz)cA2WAOopoCI0xqZY)IQ)jKXlVOaddScKzhvJmERI3QGQJQ)jKPgYAo1cOMGQ)jK5ZHm78sbzcuVAQcKXh2jSPkqgkrMD(o5oTdv)tiZNdz(8bcYqnROPuxAbzGdzjqKHSMdzObQwih1SIMsDPfKHsKzoQ5T)qcYixbzYiYWtwLHC43Qbea)d)iyZzgyLea)dZeJ4F43WPop8tzGWrTGFYnklPGvftyM8g)d)go15HFsn6Vsq)VObwjHFYnklPGvftyM8k(h(j3OSKcwv8JdBsG9GFkHy0rWMZSgyLeWf8rggqg(OLAu4bsqggqgLqm6kzqzjAA8DbF8B4uNh(nnRu0aRKWeMjVa)d)KBuwsbRk(XHnjWEWpLqm6iyZzwdSsc4c(idditviZ8NaBsCXKhasrhBO4KBuwsbzSTrM5pb2K46ttwIgAvbzX6GZXmYulYWiYyBJmZFcSjXbcq19PwdSsc4KBuwsbzSTrgAwYroabLHD1N4KBuwsbzQe)go15HFWXVl6ydfmHzAx8p8tUrzjfSQ4hh2Ka7b)ucXOJGnNznWkjGl4JmmGmvHmkHy05dfEdenWkjGRKBpKX2gz4zUk52ZnnRu0aRKCXWAPHc3AGQfn1ScYSbzgo155MMvkAGvso(ain1ScYyBJmkHy0rWGaSsYf8rMkXVHtDE430SsrdSsctyM2b(h(j3OSKcwv8JdBsG9GFkHy0rWMZSgyLeWf8XVHtDE4hC87Io2qbtyMQz8p8tUrzjfSQ4hh2Ka7b)ucXOJGnNznWkjGRKBpKX2gzucXOZhk8giAGvsaxWhzyaz(azucXOJGbbyLKl4Jm22itm5baYulYuZQGFdN68Wp2WIAGvsycZ0NH)HFdN68WVyYdaPON)eytIwrgw8tUrzjfSQycZKxc)d)go15HF(byhROp1AL1ai8tUrzjfSQycZeJQG)HFdN68WpEEC5i4qsrhxdRGFYnklPGvftyMyKr8p8B4uNh(PSYSOZOMSeTCcBf4NCJYskyvXeMjg9g)d)KBuwsbRk(XHnjWEWpLqm6GcN5Laa6yc5Il4Jm22iJsigDqHZ8saaDmHCrZZWrc0bOHZmYSbzyuf8B4uNh(rwIoCkz4k6yc5cMWmXOxX)WVHtDE4NFlqEFQ1aRKWp5gLLuWQIjmtm6f4F43WPop8B0SbyrG6mQ5WCla)KBuwsbRkMWmX4U4F4NCJYskyvXpoSjb2d(bLiuawJYsqggqMpqMHtDEoGa9LJ0aQp1U(0XvR2IWVHtDE4hqG(YrAa1NAmHzIXDG)HFdN68WpajtPcnWkj8tUrzjfSQyct4xrItyr4FyMye)d)KBuwsbRk(XHnjWEWVIOeIrhFauFQDbFKX2gzucXOR0aFzTgLLOzh1n3f8rgBBKrjeJUsd8L1AuwIwo4OwCbF8B4uNh(XN1spCQZtVAaHFRgq6Byf8lq9QPkWeMjVX)Wp5gLLuWQIFdN68WVvaYSab6(aDPZaqRUJe(XHnjWEWpEMRsU9CemiaRKCqHD6dOvheaaz2GmmUlYyBJmuZkAk1LwqMniJxvb)UHvWVvaYSab6(aDPZaqRUJeMWm5v8p8tUrzjfSQ43WPop8B(dynWbOJ5r6mQ9ZTce)4WMeyp4xvid1SIMsDPfKPwKz4uNNMN5QKBpKzpY4vVazSTrgAGQfYzjZISC(Ccz2GmERcYyBJm0avlKJAwrtP2NtAVvbz2GmmUlYujYWaYWZCvYTNJGbbyLKdkStFaT6GaaiZgKHXDrgBBKHAwrtPU0cYSbz86U43nSc(n)bSg4a0X8iDg1(5wbIjmtEb(h(j3OSKcwv8B4uNh(TcacMbGwDUkYP9xb2rTGFCytcSh8JN5QKBphbdcWkjhuyN(aA1bbaqMniZUiJTnYqnROPuxAbz2GmERc(DdRGFRaGGzaOvNRICA)vGDulycZ0U4F4NCJYskyvXVHtDE4N6zj8zTeiqRK5HFCytcSh8tjeJocgeGvsUGpYyBJmFGm0SKJC8zT6tTMSenWkjGtUrzjfKX2gzOMv0uQlTGmBqggvb)UHvWp1Zs4ZAjqGwjZdtyM2b(h(j3OSKcwv8B4uNh(naR)NtaA48xc18eol8JdBsG9GFkHy0rWGaSsYf8rggqMQqgLqm6uhgyPNtNr98NatYYf8rgBBK5dKraa54IJNxroGu0RokXeYfh7udsiYWaYqduTqolzwKLZNtiZgKXBvqMkrgBBKPikHy0bN)sOMNWzPlIsigDLC7Hm22id1SIMsDPfKzdY4Tk43nSc(naR)NtaA48xc18eolmHzQMX)Wp5gLLuWQIFdN68Wp)KZSqG(pPO5jRFGgQZtxK)BUGFCytcSh87dKrjeJocgeGvsUGpYWaY8bYiaGCCXPSYSOZOMSeTCcBfo2PgKqKX2gzkIsigDkRml6mQjlrlNWwHl4Jm22id1SIMsDPfKzdYSl(DdRGF(jNzHa9FsrZtw)anuNNUi)3CbtyM(m8p8tUrzjfSQ4hh2Ka7b)ucXOJGbbyLKl4Jm22iZhidnl5ihFwR(uRjlrdSsc4KBuwsbzSTrgQzfnL6sliZgKXBvWVHtDE4xai6MewaMWm5LW)Wp5gLLuWQIFdN68Wp(Sw6HtDE6vdi8B1asFdRGF8catyMyuf8p8tUrzjfSQ4hh2Ka7b)go1)lA5e2waiZgKXR43WPop8JpRLE4uNNE1ac)wnG03Wk4hGWeMjgze)d)KBuwsbRk(XHnjWEWVHt9)IwoHTfaYulY4n(nCQZd)4ZAPho15PxnGWVvdi9nSc(rWMZmWkjaMWe(5dfEYQme(hMjgX)WVHtDE4Nv4ibc0SdKz8tUrzjfSQycZK34F4NCJYskyvXpFOWhaPPMvWpgvb)go15HFLmOSenn(ycZKxX)Wp5gLLuWQIF3Wk438hWAGdqhZJ0zu7NBfi(nCQZd)M)awdCa6yEKoJA)CRaXeMjVa)d)go15HFBt4Q8V0NgkG8MJl4NCJYskyvXeMPDX)WVHtDE4N6Wal9C6mQN)eysw4NCJYskyvXeMPDG)HFdN68WpwHnHvOZOEf4DrxGYWcWp5gLLuWQIjmt1m(h(j3OSKcwv8Zhk8bqAQzf8Jr3U43WPop8JGbbyLe(XHnjWEWVHt9)IwoHTfaYulY4nMWm9z4F43WPop8ZpPop8tUrzjfSQycZKxc)d)KBuwsbRk(XHnjWEWVHt9)IwoHTfaYSbz8k(nCQZd)MMvkAGvsyct4hVaW)WmXi(h(j3OSKcwv8JdBsG9GFfrjeJoRWrceOzhiZUsU9qggqMpqgLqm6iyqawj5c(43WPop8ZkCKabA2bYmMWm5n(h(j3OSKcwv8JdBsG9GF8mxLC75GJFx0XgkoOWo9bqMniJAEbzSTrgEMRsU9CWXVl6ydfhuyN(aiZgKHN5QKBp30SsrdSsYbf2PpaYyBJmuZkAk1LwqMniJ3QGFdN68WVsguwIMgFmHzYR4F4NCJYskyvXpoSjb2d(PeIrhbdcWkjxWhzyazQczOMv0uQlTGm1Im8mxLC75ueiqGm3NAxjahQZdz2JmLaCOopKX2gzQczObQwiNLmlYY5ZjKzdY4TkiJTnY8bYqZsoYXhOedl90So5gLLuqMkrMkrgBBKHAwrtPU0cYSbzy0R43WPop8trGabYCFQXeMjVa)d)KBuwsbRk(XHnjWEWpLqm6iyqawj5c(idditvid1SIMsDPfKPwKHN5QKBpNYkZIogGv4kb4qDEiZEKPeGd15Hm22itvidnq1c5SKzrwoFoHmBqgVvbzSTrMpqgAwYro(aLyyPNM1j3OSKcYujYujYyBJmuZkAk1LwqMnidJ7a)go15HFkRml6yawbMWmTl(h(j3OSKcwv8JdBsG9GFkHy0rWGaSsYf8rggqMQqgQzfnL6slitTidpZvj3EU54cGGZsZN1YvcWH68qM9itjahQZdzSTrMQqgAGQfYzjZISC(Ccz2GmERcYyBJmFGm0SKJC8bkXWspnRtUrzjfKPsKPsKX2gzOMv0uQlTGmBqgg3b(nCQZd)MJlacolnFwlmHzAh4F4NCJYskyvXpoSjb2d(PeIrhbdcWkjxWhzyazQczOMv0uQlTGm1Im8mxLC75InuuwzwCLaCOopKzpYucWH68qgBBKPkKHgOAHCwYSilNpNqMniJ3QGm22iZhidnl5ihFGsmS0tZ6KBuwsbzQezQezSTrgQzfnL6sliZgKXlHFdN68WVydfLvMfmHzQMX)WVHtDE43QvBraDniuuZkhHFYnklPGvftyM(m8p8B4uNh(PmQ1zutWMZma)KBuwsbRkMWm5LW)Wp5gLLuWQIFCytcSh8JgOAHCwYSilNpNqMArMptfKX2gzObQwiNLmlYY5ZjKzJhKXBvqgBBKHgOAHCuZkAk1(Cs7TkitTiJxvb)go15HFqz87tToUgwbGjmtmQc(h(j3OSKcwv8JdBsG9GFvHm8mxLC75M)awdCa6yEKoJA)CRaDqHD6dGm1ImERcYyBJmFGmsnn0((sXn)bSg4a0X8iDg1(5wbIm22id1SIMsDPfKzdYWZCvYTNB(dynWbOJ5r6mQ9ZTc0vcWH68qM9iJx9cKHbKHgOAHCwYSilNpNqMArgVvbzQezyazQcz4zUk52ZrWGaSsYbf2PpGwDqaaKzdY4vKX2gzQczeaqoU4(VbDE6mQ9fyu4uNNJTVeImmGmuZkAk1LwqMArMHtDEAEMRsU9qM9iJsigDBt4Q8V0NgkG8MJlUsaouNhYujYujYyBJmuZkAk1LwqMniJ3QGFdN68WVTjCv(x6tdfqEZXfmHzIrgX)Wp5gLLuWQIFCytcSh8RkKHpAPgfEGeKX2gzObQwih1SIMsDPfKPwKz4uNNMN5QKBpKzpY4vvqMkrggqMQqgLqm6iyqawj5c(iJTnYWZCvYTNJGbbyLKdkStFaKzdYW4oqMkrgBBKHAwrtPU0cYSbz8kJ43WPop8tDyGLEoDg1ZFcmjlmHzIrVX)Wp5gLLuWQIFCytcSh8JN5QKBphbdcWkjhuyN(aiZgKPMXVHtDE4hS99xIUpnWF4cMWmXOxX)Wp5gLLuWQIFCytcSh87dKrjeJocgeGvsUGp(nCQZd)yf2ewHoJ6vG3fDbkdlatyMy0lW)Wp5gLLuWQIFCytcSh8tjeJocgeGvsoOmCczyazucXOtzLzzfaKdkdNqgBBKrjeJocgeGvsUGpYWaYqduTqolzwKLZNtiZgKXBvqgBBKPkKPkKHNhiWoklX5NuNNoJ6WPa7Ysk6yawbYyBJm88ab2rzjUWPa7Ysk6yawbYujYWaYqnROPuxAbz2Gm7GrKX2gzOMv0uQlTGmBqgV3bYuj(nCQZd)8tQZdtyMyCx8p8tUrzjfSQ4hh2Ka7b)IjpaqMArMDOcYWaYufYOeIrNpu4nq0aRKaUsU9qggqgEMRsU9CWXVl6ydfhuyN(aiddid1SIMsDPfKPwKHN5QKBphbdcWkjxjahQZtRoiaaYShzucXOJGbbyLKReGd15Hm22itvidnq1c5SKzrwoFoHmBqgVvbzSTrMpqgAwYro(aLyyPNM1j3OSKcYujYWaYufY8bYi10q77lf38hWAGdqhZJ0zu7NBfiYyBJm8mxLC75M)awdCa6yEKoJA)CRaDqHD6dGm1ImmUlYujYujYyBJmuZkAk1LwqMnidJ7IFdN68WpcgeGvsyct4hGW)WmXi(h(nCQZd)KA0FLG(FrdSsc)KBuwsbRkMWm5n(h(j3OSKcwv8JdBsG9GFdN6)fTCcBlaKPwKHr8B4uNh(Pmq4OwWeMjVI)HFdN68WVrZgGfbQZOMdZTa8tUrzjfSQycZKxG)HFYnklPGvf)4WMeyp4huIqbynklbzyaz(azgo155ac0xosdO(u76thxTAlc)go15HFab6lhPbuFQXeMPDX)Wp5gLLuWQIFCytcSh8tjeJocgeGvsUsU9qgBBKjM8aaz2Gm1Sk43WPop8do(DrhBOGjmt7a)d)KBuwsbRk(XHnjWEWpLqm6iyqawj5c(idditviJsigDHtGW(uR)VbDEoanCMrMArgVazSTrMpqM5pb2K4cNaH9Pw)Fd68CYnklPGmvIm22id1SIMsDPfKzdYWiJ43WPop8tzLzrNrnzjA5e2kWeMPAg)d)KBuwsbRk(XHnjWEWVpqgLqm6iyqawj5c(iJTnYqnROPuxAbz2Gm7IFdN68WVyYdaPON)eytIwrgwmHz6ZW)Wp5gLLuWQIFCytcSh8tjeJocgeGvsUGpYWaYOeIrh7aibQzhiZa25CbFKHbK5dKrjeJowHnHvOZOEf4DrxGYWcCbF8B4uNh(nq(CIgyLeMWm5LW)Wp5gLLuWQIFCytcSh8tjeJocgeGvsUGpYyBJmvHmkHy0vYGYs0047k52dzSTrg(OLAu4bsqMkrggqgLqm68HcVbIgyLeWvYThYyBJmXWAPHc3AGQfn1ScYSbz4dG0uZkiddidpZvj3EocgeGvsoOWo9bWVHtDE430SsrdSsctyMyuf8p8tUrzjfSQ4hh2Ka7b)ucXOJGbbyLKl4JmmGmkHy0XoasGA2bYmGDoxWhzyazucXOJvytyf6mQxbEx0fOmSaxWh)go15HFdKpNObwjHjmtmYi(h(nCQZd)8BbY7tTgyLe(j3OSKcwvmHzIrVX)Wp5gLLuWQIFCytcSh87dKrjeJocgeGvsUGpYyBJmuZkAk1LwqMniZNHFdN68Wp)aSJv0NATYAaeMWmXOxX)Wp5gLLuWQIFCytcSh8lM8aaz2JmXKhaoOOwoKXllYOMxqMnitm5bGJDQrKHbKrjeJocgeGvsUsU9qggqMQqMpqMssoEEC5i4qsrhxdROvcWZbf2PpaYWaY8bYmCQZZXZJlhbhsk64AyfxF64QvBritLiJTnYedRLgkCRbQw0uZkiZgKrnVGm22idnq1c5OMv0uQlTGmBqMDXVHtDE4hppUCeCiPOJRHvWeMjg9c8p8tUrzjfSQ4hh2Ka7b)ucXOdkCMxcaOJjKlUGpYyBJmkHy0bfoZlba0XeYfnpdhjqhGgoZiZgKHrvqgBBKHAwrtPU0cYSbz2f)go15HFKLOdNsgUIoMqUGjmtmUl(h(j3OSKcwv8JdBsG9GFkHy0rWGaSsYvYThYWaYufYOeIrNpu4nq0aRKaUGpYWaYufYetEaGm1ImEbJiJTnYOeIrh7aibQzhiZa25CbFKPsKX2gzQczIjpaqMArMDvbzyazM)eytIlM8aqk6ydfNCJYskiJTnYetEaGm1Im18UitLidditvidpZvj3EocgeGvsoOWo9bqMArMDrgBBKjM8aazQfz(mvqMkrgBBKHAwrtPU0cYSbz2fzQe)go15HFdKpNObwjHjmtmUd8p8B4uNh(bizkvObwjHFYnklPGvftyc)cuVAQc8pmtmI)HFdN68WpEgosGAGvs4NCJYskyvXeMjVX)WVHtDE4hqGY1uf6saq4NCJYskyvXeMjVI)HFdN68WpGFcfnFLHc(j3OSKcwvmHzYlW)WVHtDE4hitYQp16Tdjq8tUrzjfSQycZ0U4F43WPop8dKxZ1kRbq4NCJYskyvXeMPDG)HFdN68WVtilbQbwjNz8tUrzjfSQycZunJ)HFdN68WpUvxdAGMGZvtd9QPkWp5gLLuWQIjmtFg(h(nCQZd)a(nSjnWk5mJFYnklPGvftyM8s4F43WPop87gkafGwnC4c(j3OSKcwvmHjmHF)lqqNhMjVvXBvuHrV9c8B7aV(udWVpp78pVmTtWun8AcYGm)SeKPz9tiHmXeIm7mEbSZqgOutdnukidizfKzcuYoKuqgU1CQfGdvFNUpbzyC3AcYudL3)cKKcYSZiyFmlKRgMJN5QKBVDgYqjYSZ4zUk52ZvdBNHmvXynwPdvhvFNG1pHKuqMDGmdN68qMvdiGdvh)a(chZK376f4NpmJ9sWVpHm7udKza7CaR2hz8YeosGO6FczSiYhut((vDtwbfhpz)cA2WAOopoCI0xqZY)IQ)jKXlVOaddScKzhvJmERI3QGQJQ)jKPgYAo1cOMGQ)jK5ZHm78sbzcuVAQcKXh2jSPkqgkrMD(o5oTdv)tiZNdz(8bcYqnROPuxAbzGdzjqKHSMdzObQwih1SIMsDPfKHsKzoQ5T)qcYixbzYiYWtwLHCO6O6Fcz8YvJcpqsbzuKycfKHNSkdHmkI6(aoKzNZ5IpbqMlVpN1azJHfYmCQZdGm5TQWHQ)jKz4uNhW5dfEYQmKN4AamJQ)jKz4uNhW5dfEYQm0EpFNGAw5OH68q1)eYmCQZd48HcpzvgAVNVXmlO6FczE34dSsczGtxqgLqmkfKbqdbqgfjMqbz4jRYqiJIOUpaYmxbz8HYNZpjQp1itdqMsEIdv)tiZWPopGZhk8KvzO9E(cUXhyLKgqdbq1ho15bC(qHNSkdT3ZxRWrceOzhiZO6Fcz2jHcFaeYqwnazgaYidCvbYmaKXpbGwzjidLiJFsYr9SwvGmQN(qM5sYsGidFaeYucW(uJmKLGmXwTf5q1ho15bC(qHNSkdT3Z3sguwIMg)Q9HcFaKMAwXdJQGQpCQZd48HcpzvgAVNVbGOBsyR(gwXZ8hWAGdqhZJ0zu7NBfiQ(WPopGZhk8KvzO9E(UnHRY)sFAOaYBoUGQpCQZd48HcpzvgAVNVQddS0ZPZOE(tGjzHQpCQZd48HcpzvgAVNVScBcRqNr9kW7IUaLHfGQpCQZd48HcpzvgAVNVemiaRKQ2hk8bqAQzfpm62T6o6z4u)VOLtyBbuR3O6dN68aoFOWtwLH275RFsDEO6dN68aoFOWtwLH27570SsrdSsQ6o6z4u)VOLtyBbSXRO6O6dN68aUa1RMQWdpdhjqnWkju9HtDEaxG6vtvS3ZxGaLRPk0LaGq1ho15bCbQxnvXEpFb(ju08vgkO6dN68aUa1RMQyVNVGmjR(uR3oKar1ho15bCbQxnvXEpFb51CTYAaeQ(WPopGlq9QPk2757jKLa1aRKZmQ(WPopGlq9QPk275l3QRbnqtW5QPHE1ufO6dN68aUa1RMQyVNVa)g2KgyLCMr1ho15bCbQxnvXEpFVHcqbOvdhUGQJQ)jKXlxnk8ajfKr(xGvGmuZkidzjiZWPeImnazM)NEnklXHQpCQZd4HpRLE4uNNE1aQ6ByfpbQxnvr1D0trucXOJpaQp1UGVTTsigDLg4lR1OSen7OU5UGVTTsigDLg4lR1OSeTCWrT4c(O6dN68a798naeDtcB13WkEwbiZceO7d0LodaT6osv3rp8mxLC75iyqawj5Gc70hqRoiaWgg312MAwrtPU0YgVQcQ(WPopWEpFdar3KWw9nSIN5pG1ahGoMhPZO2p3kWQ7ONQOMv0uQlTulpZvj3E79QxyBtduTqolzwKLZNtB8wfBBAGQfYrnROPu7ZjT3QSHXDRKbEMRsU9CemiaRKCqHD6dOvheaydJ7ABtnROPuxAzJx3fvF4uNhyVNVbGOBsyR(gwXZkaiygaA15QiN2Ffyh1s1D0dpZvj3EocgeGvsoOWo9b0QdcaSzxBBQzfnL6slB8wfu9HtDEG9E(gaIUjHT6ByfpQNLWN1sGaTsMx1D0JsigDemiaRKCbFB7pOzjh54ZA1NAnzjAGvsaNCJYsk22uZkAk1Lw2WOkO6dN68a798naeDtcB13WkEgG1)ZjanC(lHAEcNv1D0JsigDemiaRKCbFgQsjeJo1Hbw650zup)jWKSCbFB7peaqoU445vKdif9QJsmHCXXo1GeYanq1c5SKzrwoFoTXBvQ02UikHy0bN)sOMNWzPlIsigDLC7zBtnROPuxAzJ3QGQpCQZdS3Z3aq0njSvFdR4Xp5mleO)tkAEY6hOH680f5)Mlv3rpFOeIrhbdcWkjxWNHpeaqoU4uwzw0zutwIwoHTch7udsOTDrucXOtzLzrNrnzjA5e2kCbFBBQzfnL6slB2fv)tiZpyfidLiZQpbzc(iZWP()HKcYqW(ywiaYSTjlK5hmiaRKq1ho15b275Bai6Mewq1D0JsigDemiaRKCbFB7pOzjh54ZA1NAnzjAGvsaNCJYsk22uZkAk1Lw24TkO6dN68a798LpRLE4uNNE1aQ6Byfp8cavF4uNhyVNV8zT0dN680RgqvFdR4bqv3rpdN6)fTCcBlGnEfvF4uNhyVNV8zT0dN680RgqvFdR4HGnNzGvsGQ7ONHt9)IwoHTfqTEJQJQpCQZd44fGhRWrceOzhiZv3rpfrjeJoRWrceOzhiZUsU9y4dLqm6iyqawj5c(O6dN68aoEbS3Z3sguwIMg)Q7OhEMRsU9CWXVl6ydfhuyN(aBuZl228mxLC75GJFx0XgkoOWo9b2WZCvYTNBAwPObwj5Gc70hW2MAwrtPU0YgVvbvF4uNhWXlG9E(QiqGazUp1v3rpkHy0rWGaSsYf8zOkQzfnL6sl1YZCvYTNtrGabYCFQDLaCOoV9LaCOopB7QObQwiNLmlYY5ZPnERIT9h0SKJC8bkXWspnRtUrzjLkR02MAwrtPU0Ygg9kQ(WPopGJxa798vzLzrhdWkQUJEucXOJGbbyLKl4ZqvuZkAk1LwQLN5QKBpNYkZIogGv4kb4qDE7lb4qDE22vrduTqolzwKLZNtB8wfB7pOzjh54duIHLEAwNCJYskvwPTn1SIMsDPLnmUdu9HtDEahVa2757CCbqWzP5ZAvDh9OeIrhbdcWkjxWNHQOMv0uQlTulpZvj3EU54cGGZsZN1YvcWH682xcWH68STRIgOAHCwYSilNpN24Tk22FqZsoYXhOedl90So5gLLuQSsBBQzfnL6slByChO6dN68aoEbS3Z3ydfLvMLQ7OhLqm6iyqawj5c(muf1SIMsDPLA5zUk52ZfBOOSYS4kb4qDE7lb4qDE22vrduTqolzwKLZNtB8wfB7pOzjh54duIHLEAwNCJYskvwPTn1SIMsDPLnEju9HtDEahVa2757QvBraDniuuZkhHQpCQZd44fWEpFvg16mQjyZzgGQpCQZd44fWEpFHY43NADCnScO6o6HgOAHCwYSilNpNQ9ZuX2MgOAHCwYSilNpN24XBvSTPbQwih1SIMsTpN0ERsTEvfu9HtDEahVa27572eUk)l9PHciV54s1D0tv8mxLC75M)awdCa6yEKoJA)CRaDqHD6duR3QyB)HutdTVVuCZFaRboaDmpsNrTFUvG22uZkAk1Lw2WZCvYTNB(dynWbOJ5r6mQ9ZTc0vcWH6827vVGbAGQfYzjZISC(CQwVvPsgQIN5QKBphbdcWkjhuyN(aA1bba24vB7QeaqoU4(VbDE6mQ9fyu4uNNJTVeYa1SIMsDPLA5zUk52BVsigDBt4Q8V0NgkG8MJlUsaouNxLvABtnROPuxAzJ3QGQpCQZd44fWEpFvhgyPNtNr98NatYQ6o6Pk(OLAu4bsSTPbQwih1SIMsDPLA5zUk52BVxvPsgQsjeJocgeGvsUGVTnpZvj3EocgeGvsoOWo9b2W4oQ02MAwrtPU0YgVYiQ(WPopGJxa798f2((lr3Ng4pCP6o6HN5QKBphbdcWkjhuyN(aBQzu9HtDEahVa275lRWMWk0zuVc8UOlqzybv3rpFOeIrhbdcWkjxWhvF4uNhWXlG9E(6NuNx1D0JsigDemiaRKCqz4edkHy0PSYSScaYbLHt22kHy0rWGaSsYf8zGgOAHCwYSilNpN24Tk22vvfppqGDuwIZpPopDg1Htb2LLu0XaScBBEEGa7OSex4uGDzjfDmaROsgOMv0uQlTSzhmABtnROPuxAzJ37Osu9HtDEahVa275lbdcWkPQ7ONyYdGA3HkmuLsigD(qH3ardSsc4k52JbEMRsU9CWXVl6ydfhuyN(amqnROPuxAPwEMRsU9CemiaRKCLaCOopT6Gaa7vcXOJGbbyLKReGd15zBxfnq1c5SKzrwoFoTXBvST)GMLCKJpqjgw6PzDYnklPujdv9HutdTVVuCZFaRboaDmpsNrTFUvG22eSpMfYn)bSg4a0X8iDg1(5wb64zUk52Zbf2PpqTmUBLvABtnROPuxAzdJ7IQpCQZd4aKhPg9xjO)x0aRKq1ho15bCaAVNVkdeoQLQ7ONHt9)IwoHTfqTmIQpCQZd4a0EpFhnBaweOoJAom3cq1ho15bCaAVNVab6lhPbuFQRUJEGsekaRrzjm8XWPophqG(YrAa1NAxF64QvBrO6dN68aoaT3Zx443fDSHs1D0JsigDemiaRKCLC7zBhtEaSPMvbv)tith9OeIrhbdcWkjxWNHQucXOlCce2NA9)nOZZbOHZCTEHT9hZFcSjXfobc7tT()g055KBuwsPsBBAGQfYrnROPuxAzdJmIQpCQZd4a0EpFvwzw0zutwIwoHTIQ7OhLqm6iyqawj5c(muLsigDHtGW(uR)VbDEoanCMR1lST)y(tGnjUWjqyFQ1)3GopNCJYskvABtnROPuxAzdJmIQpCQZd4a0EpFJjpaKIE(tGnjAfzyRUJE(qjeJocgeGvsUGVTn1SIMsDPLn7IQpCQZd4a0EpFhiFordSsQ6o6rjeJocgeGvsUGpdkHy0XoasGA2bYmGDoxWNHpucXOJvytyf6mQxbEx0fOmSaxWhvF4uNhWbO9E(onRu0aRKQUJEucXOJGbbyLKl4BBxLsigDLmOSenn(UsU9ST5JwQrHhiPsgucXOZhk8giAGvsaxj3E22XWAPHc3AGQfn1SYg(ain1Scd8mxLC75iyqawj5Gc70havF4uNhWbO9E(oq(CIgyLu1D0JsigDemiaRKCbFgucXOJDaKa1SdKza7CUGpdkHy0XkSjScDg1RaVl6cugwGl4JQpCQZd4a0EpF9BbY7tTgyLeQ(WPopGdq7981pa7yf9PwRSgavDh98HsigDemiaRKCbFBBQzfnL6slB(mu9HtDEahG275lppUCeCiPOJRHvQUJEIjpa2htEa4GIA58YQMx2etEa4yNAKbLqm6iyqawj5k52JHQ(OKKJNhxocoKu0X1WkALa8CqHD6dWWhdN68C884YrWHKIoUgwX1NoUA1wuL22XWAPHc3AGQfn1SYg18ITnnq1c5OMv0uQlTSzxu9HtDEahG275lzj6WPKHROJjKlv3rpkHy0bfoZlba0XeYfxW32wjeJoOWzEjaGoMqUO5z4ib6a0WzEdJQyBtnROPuxAzZUO6dN68aoaT3Z3bYNt0aRKQUJEucXOJGbbyLKRKBpgQsjeJoFOWBGObwjbCbFgQkM8aOwVGrBBLqm6yhajqn7azgWoNl4xPTDvXKha1URkmm)jWMexm5bGu0Xgko5gLLuSTJjpaQTM3TsgQIN5QKBphbdcWkjhuyN(a1URTDm5bqTFMkvABtnROPuxAzZUvIQpCQZd4a0EpFbKmLk0aRKq1r1ho15bCeS5mdSsc4rzGWrTGQpCQZd4iyZzgyLeyVNVsn6Vsq)VObwjHQpCQZd4iyZzgyLeyVNVtZkfnWkPQ7OhLqm6iyZzwdSsc4c(mWhTuJcpqcdkHy0vYGYs0047c(O6dN68aoc2CMbwjb275lC87Io2qP6o6rjeJoc2CM1aRKaUGpdvn)jWMexm5bGu0Xgko5gLLuSTN)eytIRpnzjAOvfKfRdohZ1YOT98NaBsCGauDFQ1aRKao5gLLuSTPzjh5aeug2vFItUrzjLkr1ho15bCeS5mdSscS3Z3PzLIgyLu1D0JsigDeS5mRbwjbCbFgQsjeJoFOWBGObwjbCLC7zBZZCvYTNBAwPObwj5IH1sdfU1avlAQzLndN68CtZkfnWkjhFaKMAwX2wjeJocgeGvsUGFLO6dN68aoc2CMbwjb275lC87Io2qP6o6rjeJoc2CM1aRKaUGpQ(WPopGJGnNzGvsG9E(YgwudSsQ6o6rjeJoc2CM1aRKaUsU9STvcXOZhk8giAGvsaxWNHpucXOJGbbyLKl4BBhtEauBnRcQ(WPopGJGnNzGvsG9E(gtEaif98NaBs0kYWIQpCQZd4iyZzgyLeyVNV(byhROp1AL1aiu9HtDEahbBoZaRKa798LNhxocoKu0X1WkO6dN68aoc2CMbwjb275RYkZIoJAYs0YjSvGQpCQZd4iyZzgyLeyVNVKLOdNsgUIoMqUuDh9OeIrhu4mVeaqhtixCbFBBLqm6GcN5Laa6yc5IMNHJeOdqdN5nmQcQ(WPopGJGnNzGvsG9E(63cK3NAnWkju9HtDEahbBoZaRKa798D0SbyrG6mQ5WClavF4uNhWrWMZmWkjWEpFbc0xosdO(uxDh9aLiuawJYsy4JHtDEoGa9LJ0aQp1U(0XvR2Iq1ho15bCeS5mdSscS3ZxajtPcnWkjmHjmg]] )


end