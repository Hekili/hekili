-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 254 )

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
            duration = 4,
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
            id = 260240,
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
            id = 257621,
        },
        trueshot = {
            id = 193526,
            duration = 15,
            max_stack = 1,
        },
    } )


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
            cooldown = 12,
            recharge = 12,
            gcd = "spell",
            
            spend = function () return buff.lock_and_load.up and 0 or 30 end,
            spendType = "focus",
            
            startsCombat = true,
            texture = 135130,
            
            recheck = function () return buff.precise_shots.remains, focus.time_to_71, buff.steady_focus.remains, buff.double_tap.remains, full_recharge_time - cast_time + gcd end,
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
            
            recheck = function () return focus.time_to_71, buff.steady_focus.remains, focus.time_to_61, cooldown.aimed_shot.full_recharge_time - gcd * buff.precise_shots.stack + action.aimed_shot.cast_time end,
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
            gcd = "spell",
            
            startsCombat = true,
            texture = 249170,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
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
            
            recheck = function () return cooldown.rapid_fire.remains - gcd end,
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
            cooldown = 120,
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
                removeBuff( "steady_focus" )
            end,
        },
        

        explosive_shot_detonate = {
            id = 212679,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1044088,
            
            usable = function () return prev_gcd[1].explosive_shot end,
            handler = function ()
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
            
            recheck = function () return focus.time_to_91, focus.time_to_71, buff.steady_focus.remains, focus.time_to_46, cooldown.aimed_shot.full_recharge_time < gcd * buff.precise_shots.stack + action.aimed_shot.cast_time, buff.trick_shots.remains end,
            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
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
            cast = function () return 3 * ( talent.streamline.enabled and 1.3 or 1 ) * haste end,
            channeled = true,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 461115,
            
            handler = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "lethal_shots" )
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
            
            startsCombat = true,
            texture = 132213,
            
            handler = function ()
                if talent.steady_focus.enabled then applyBuff( "steady_focus", 12, min( 2, buff.steady_focus.stack + 1 ) ) end
            end,
        },
        

        survival_of_the_fittest = {
            id = 281195,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 136094,
            
            usable = function () return not pet.alive end,
            handler = function ()
                applyBuff( "survival_of_the_fittest" )
            end,
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
            id = 193526,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132329,
            
            handler = function ()
                applyBuff( "trueshot" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Marksmanship",        
    } )


    spec:RegisterPack( "Marksmanship", 20180715.224001, [[d4ZKuaGAkfvBsvyxQQxtiTpPQMjLIWTrPzdX8LsDtkfj)Is8nGu)wYoLI2lv7gQ9t0OOu6VImokf8ukopKsdwudxQCnGKtjvXXaIZrPqluvQlJSyuSCu9qkfPwfKcwMuYZvABsvQPsjnzvA6KEeLIIxjfEgq11b8yqttQs2Sk2UQO1bPqnlcXNjuZds1iHuiFNs1Ojy8qk6KukIUfLIsNw4EqYkvLCyfddOSdIB1n3rjVzlWaXgad0GaQFRw9cmWaXnkA7i30nqrhXKBWdl5gBQHl6Yo4vi6Ct3GwKAUUv3SfahsUrq1Ufn2IfXHkaW8HfRLnybqgnkmKph1YgSqlmifJfMZyZEPNwiS4atwGiZUj26cGqRLfMeaWkX)WUoBgBcqboObLByace1Me7mU5ok5nBbgi2ayGgeq9B1cCBeu92ndGkuC3ycwBA3CPf6gRcXkZXkZJm3nqrhXKmxhzEGAuyzgjwDL5tXLz0is0aj(UbjwDDRU5sNbarDREtqCRUzGAuy3maALwHsDdHhge66VD1B2YT6MbQrHDdSaWkXtRqPUHWddcD93U6nb3T6MbQrHDdWsPqj21neEyqOR)2vVzVCRUHWddcD93UbYdL4X4MlXaCoFbaSs8nXoCr)3Yo2nduJc7gbaSs8nXoCrD1Bck3QBi8WGqx)TBG8qjEmUbwfYTSJ)8PlUPtWPpNyNaVYm6YSy41nduJc7MBbWGqjD6C1B2B3QBi8WGqx)TBG8qjEmUbwfYTSJ)khGwHs)CIDc8kZ9LzWbZnduJc7ggIVex0al2vVjODRUHWddcD93UbYdL4X4gyvi3Yo(RCaAfk9Zj2jWRm3xMbhm3mqnkSByqQ6MoaC06Q30gCRUHWddcD93UbYdL4X4gyvi3Yo(RCaAfk9Zj2jWRm3xMbhm3mqnkSBgmKwLpij4GG4Q30gDRUHWddcD93UbYdL4X4gyvi3Yo(RCaAfk9Zj2jWRm3xMbhm3mqnkSBobNyqQ66Q3eeWCRUzGAuy3GeIf0nzZbUIzjS6gcpmi01F7Q3eeqCRUHWddcD93UbYdL4X4gBLzgGZ5RCaAfk9ZPbQY8dzMb4C(mivDraw9ZPbQYCpYC72YSTYSTYmSWla7WGq)oEHuyX0n1v2jUm)qM1HlM0VgSusR0nizgDzU3TK5EK52TLzD4Ij9RblL0kDdsMrxMbhezUh3mqnkSB6knkSREtqA5wDdHhge66VDdKhkXJXnWQqULD8Fcw6MwHs)qHHlMwzgDzge3mqnkSBuoaTcL6Q3eeWDRUHWddcD93UbYdL4X4MbQXtkryInOvM7lZG4MbQrHDdZW5JyYvVji9YT6gcpmi01F7gipuIhJBgOgpPeHj2GwzUVmdIBgOgf2neA2HuB8KsRqPU6nbbuUv3q4HbHU(B3a5Hs8yCZa14jLimXg0kZ9L5wY8dzMb4C(DCcglLwHs3pqNm)qMHvHCl74)eS0nTcL(paiijobfgUykPbljZOlZIHxzgniZmaNZVJtWyP0ku6(xDGIkZnK5bQrH)tWs30ku6hoRM0GLCZa1OWUHfarJvOux9MG0B3QBi8WGqx)TBG8qjEmUzGA8KseMydALz0LzWL5hYmdW5874emwkTcLUFGoz(HmdRc5w2X)jyPBAfk9FaqqsCckmCXusdwsMrxMfdVYmAqMzaoNFhNGXsPvO09V6afvMBiZduJc)NGLUPvO0pCwnPbl5MbQrHDZWHdMsRqPU6nbb0Uv3q4HbHU(B3a5Hs8yCddW5874emwkTcLU)BzhlZpKzgGZ5FlagekPt3)w2XY8dz2wzEGA8KseMydAL5(YClz(HmZaCoFLhqrtRqP7hOtMB3wMhOgpPeHj2GwzgDzgCz(HmFaqqsCckmCXusdwsMrxMHZQjnyjzUHmlgEL5ECZa1OWUzcw6MwHsD1BcIn4wDdHhge66VDdKhkXJXnduJNuIWeBqRmJUmdUm3UTmZaCoFLhqrtRqP7hOZnduJc7g(0f30j4KREtqSr3QBgOgf2neA2HuB8KsRqPUHWddcD93U6nBbMB1neEyqOR)2nqEOepg3WPdNwHHbHCZa1OWUzjEhH10QbwSREZwG4wDZa1OWUHz48rm5gcpmi01F7Q3Svl3QBgOgf2nDbXHbwCAfk1neEyqOR)2vVzlWDRUzGAuy3mjwa(L4P6KG8Y(6gcpmi01F7Q3SvVCRUHWddcD93UbYdL4X4MbQXtkryInOvM7lZTK5hYmdW58vEafnTcLU)Bzh7MbQrHDdlaIgRqPU6nBbk3QBi8WGqx)TBG8qjEmUHb4C(DCcglLwHs3)TSJL5hYSTY8PGaRm3xMbnyYC72YmdW58xLMlAtNccS)BzhlZ94MbQrHDZeS0nTcL6Q3SvVDRUHWddcD93UbYdL4X4MbQXtkryInOvM7lZTK5hYSTY8PGaRm3xMTrWK52TLzgGZ53XjySuAfkD)aDY8dz2wz(uqGvM7lZGgmzUDBzMb4C(RsZfTPtbb2)TSJL5hY8PGaRm3xM7fOK5EK5ECZa1OWUHfarJvOux9MTaTB1neEyqOR)2nqEOepg3mqnEsjctSbTYm6Ym4Y8dz2wz(uqGvM7lZGgmzUDBzMb4C(RsZfTPtbb2)TSJL5hYSTY8PGaRm3xM7nyYC72YmdW5874emwkTcLUFGozUhzUh3mqnkSBgoCWuAfk1vVzlBWT6MbQrHDZQ0CrBAfk1neEyqOR)2vxDthNGflZOUvVjiUv3mqnkSBeaWkX3e7Wf1neEyqOR)2vVzl3QBi8WGqx)TB64eCwnPbl5gq5MbQrHDZTayqOKoDU6nb3T6gcpmi01F7gipuIhJBgOgpPeHj2GwzgDzgC3mqnkSBMGLUPvOux9M9YT6gcpmi01F7gipuIhJBgOgpPeHj2GwzUVm3YnduJc7gcn7qQnEsPvOuxD1v38K4BuyVzlWaXgad0GaQFRwTaLBSpCCGfVUXnD86eiKBgOgfE)DCcwSmJIsaaReFtSdxu5RbQrH3FhNGflZOnqz5wamiusNor64eCwnPblHcuYxduJcV)ooblwMrBGYYeS0nTcLksCqnqnEsjctSbTOdU81a1OW7VJtWILz0gOSqOzhsTXtkTcLksCqnqnEsjctSbT9BjFjFnqnk82aLLbqR0kuQ81a1OWBduwGfawjEAfkv(AGAu4TbklalLcLyx5RbQrH3gOSiaGvIVj2HlQiXb1LyaoNVaawj(MyhUO)BzhlFnqnk82aLLBbWGqjD6ejoOGvHCl74pF6IB6eC6Zj2jWl6IHx5RbQrH3gOSWq8L4IgyXIehuWQqULD8x5a0ku6NtStG3(GdM81a1OWBduwyqQ6MoaC0ksCqbRc5w2XFLdqRqPFoXobE7doyYxduJcVnqzzWqAv(GKGdcIiXbfSkKBzh)voaTcL(5e7e4Tp4GjFnqnk82aLLtWjgKQUIehuWQqULD8x5a0ku6NtStG3(GdM81a1OWBduwqcXc6MS5axXSewLVgOgfEBGYsxPrHfjoOSLb4C(khGwHs)CAG6dgGZ5ZGu1fby1pNgO2t722AlSWla7WGq)oEHuyX0n1v2j(dD4Ij9RblL0kDdc9E3QN2T1HlM0VgSusR0ni0bhKEKVgOgfEBGYIYbOvOurIdkyvi3Yo(pblDtRqPFOWWftl6GiFnqnk82aLfMHZhXKiXb1a14jLimXg02he5RbQrH3gOSqOzhsTXtkTcLksCqnqnEsjctSbT9br(AGAu4TbklSaiAScLksCqnqnEsjctSbT9B9Gb4C(DCcglLwHs3pq3dyvi3Yo(pblDtRqP)dacsItqHHlMsAWsOlgErdmaNZVJtWyP0ku6(xDGI2yGAu4)eS0nTcL(HZQjnyj5RbQrH3gOSmC4GP0kuQiXb1a14jLimXg0Io4pyaoNFhNGXsPvO09d09awfYTSJ)tWs30ku6)aGGK4euy4IPKgSe6IHx0adW5874emwkTcLU)vhOOngOgf(pblDtRqPF4SAsdws(AGAu4TbkltWs30kuQiXbfdW5874emwkTcLU)Bzh)Gb4C(3cGbHs609VLD8dBhOgpPeHj2G2(TEWaCoFLhqrtRqP7hORD7bQXtkryInOfDWFCaqqsCckmCXusdwcD4SAsdwQHy4Th5RbQrH3gOSWNU4MobNejoOgOgpPeHj2Gw0bVDBgGZ5R8akAAfkD)aDYxduJcVnqzHqZoKAJNuAfkv(AGAu4TbkllX7iSMwnWIfjoO40HtRWWGqYxduJcVnqzHz48rmjFnqnk82aLLUG4WaloTcLkFnqnk82aLLjXcWVepvNeKx2x5RbQrH3gOSWcGOXkuQiXb1a14jLimXg02V1dgGZ5R8akAAfkD)3Yow(AGAu4TbkltWs30kuQiXbfdW5874emwkTcLU)Bzh)W2tbb2(GgS2TzaoN)Q0CrB6uqG9Fl74EKVgOgfEBGYclaIgRqPIehuduJNuIWeBqB)wpS9uqGTVncw72maNZVJtWyP0ku6(b6Ey7PGaBFqdw72maNZFvAUOnDkiW(VLD8Jtbb2(9cu90J81a1OWBduwgoCWuAfkvK4GAGA8KseMydArh8h2EkiW2h0G1UndW58xLMlAtNccS)Bzh)W2tbb2(9gS2TzaoNFhNGXsPvO09d01tpYxduJcVnqzzvAUOnTcL6MTJGEZwGQxU6Q7]] )
end