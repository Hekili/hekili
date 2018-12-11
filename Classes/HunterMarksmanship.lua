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
            duration = PTR and 6 or 4,
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
        trueshot = PTR and {
            id = 288613,
            duration = 15,
            max_stack = 1,
        } or {
            id = 193526,
            duration = 15,
            max_stack = 1,
        },


        -- Azerite Powers
        unerring_vision = {
            id = 274447,
            duration = function () return buff.trueshot.duration end,
            max_stack = 10,
            meta = {
                stack = function () return max( 1, ceil( query_time - buff.trueshot.applied ) ) end,
            }
        },
    } )


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
            cooldown = function () return haste * ( ( PTR and buff.trueshot.up ) and 4.8 or 12 ) end,
            recharge = function () return haste * ( ( PTR and buff.trueshot.up ) and 4.8 or 12 ) end,
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
        

        explosive_shot_detonate = not PTR and {
            id = 212679,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1044088,
            
            usable = function () return prev_gcd[1].explosive_shot end,
            handler = function ()
            end,
        } or nil,
        

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
            cast = function () return 3 * ( talent.streamline.enabled and ( PTR and 1.2 or 1.3 ) or 1 ) * haste end,
            channeled = true,
            cooldown = function () return ( PTR and buff.trueshot.up ) and ( haste * 8 ) or 20 end,
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

            spend = PTR and -10 or nil,
            spendType = PTR and "focus" or nil,
            
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
        

        trueshot = PTR and {
            id = 288613,
            cast = 0,
            cooldown = 120,
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
        } or {
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
    
        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20181211.0927, [[dyKtIaqirepIuInjIAusvXPKkPvjcsEfqmlrOBjvv2ff)Iu1WiL6yKiltQWZiL00erY1eb2gjQ6BIi14KQQohqkwNujAEaj3JuSpa4GsvjleO8qGu1efbPUOuvk2OiiAKaPYjLQs1kjvUjqkTtaAOsLWsfb1tL0uLQCvPQuAVk9xPmykDyQwmOEmQMSOUmYMb5ZKWOHQtlSArq41avZwIBts7wv)wLHlslhYZvmDIRdLTlvQVlv04jrLZtIY6bqZhq7hLxL2EBn7cTa2H2k1FL6qjLmAdA6iP1QYVvrzP0wtDo4UcARVRsBf06iWhv)h8iDRPUYkNN3EBDomeN2QwywCrsNUuVEfHGJbB4NQ(juXkUe3ZroKOFcvUE4YbRhgY7xM6wFk6GIcn67ceLWEKh9Drc3aDyVqOgO1rGpQ(p4rQzcv(wHXII03)fERzxOfWo0wP(RuhkPKrBqJ2jvhDSvhtWp0wRHkOFR4rot)cV1mn8TQfMf06iWhv)h8iLzbDyVqiMoTWS4IKoDPE9kcbhd2Wpv9tOIvCjUNJCir)eQC9WLdwpmK3Vm1T(u0bffA03fikH9ip67IeUb6WEHqnqRJaFu9FWJuZeQCMoTWSj0eNuHjeZQKsjYSDOTs9Nz7hZQD)7Ye0FMoMoTWSGEC)vqtxY0PfMTFmBFLZuMzb9h2leIzR4Nyy60cZ2pMTVYzkZSjSNgzMnHmqeZEDtiMTVcvkZSv8ty2aIzv2HXSoIyw1R74vyy60cZ2pMTVDiMvcvQjxlheZICbNqmRG7pZkosbjgjuPMCTCqmRCmR)sWJuxiML(mZEqml)uHDXS1smYS92QGco4d(jZ2BbuPT3wDUe3VvyhHCf0wP3HluEbBLfWo2EB15sC)wjLlTCt0n1g8t2k9oCHYlyRSaQ1T3wP3HluEbBRCuiek8TcJbbzeuWbVn4NmgSuMnzMTpmRdqcfczGoo2q5guGid9oCHYmlqGmRdqcfczIVj4udHRmbx1G8hCMfamRsmlqGmRdqcfczgmKI4v0g8tgd9oCHYmlqGmR4f6fZiiYvlXtg6D4cLz2UUvNlX9Bf5PrUbfiALfWKA7Tv6D4cLxW2khfcHcFRWyqqgbfCWBd(jJblLztMzHXGGmPiIhd1g8tgt(683QZL4(T6HkLBd(jRSaMGT3wP3HluEbBRCuiek8TcJbbzeuWbVn4NmgS0T6CjUFRipnYnOarRSaQ8BVTsVdxO8c2w5Oqiu4BfgdcYiOGdEBWpzm5RZNzbcKzHXGGmPiIhd1g8tgdwkZceiZcDCSHzbaZM0AVvNlX9BvfRiXGFYklGj92BRoxI73AAqiE8kAd(jBLEhUq5fSvwa7)2BRoxI73Q3uXqzc1oOghDDoBLEhUq5fSvwabnBVTsVdxO8c2w5Oqiu4BfrqiAWD4cXSjZSjHzDUe3BgcLsV0gjEfM4BqLqbUSvNlX9BDiuk9sBK4vSYcOsAV92QZL4(Toc5zL1g8t2k9oCHYlyRSYwZeKJvKT3cOsBVT6CjUFR8d7fc1g8t2k9oCHYlyRSa2X2BRoxI73k2qTqi1zR07WfkVGTYcOw3EBLEhUq5fST6CjUFRCVuAoxI7BLyKTwIrAVRsBLNNvwatQT3wP3HluEbBRoxI73k3lLMZL4(wjgzRCuiek8T6Cj6MA0tQbnmlOywTU1sms7DvARJSYcyc2EBLEhUq5fST6CjUFRCVuAoxI7BLyKTYrHqOW3QZLOBQrpPg0WSaGz7yRLyK27Q0wfuWbFWpzwzLTMIi(Pc7Y2BbuPT3wP3HluEbBLfWo2EBLEhUq5fSvwa162BR07WfkVGTYcysT92k9oCHYlyBLJcHqHVvNlr3uJEsnOHzbfZQ1T6CjUFRdMQ69TuswzbmbBVTsVdxO8c2klGk)2BRoxI73A6jX9BLEhUq5fSvwat6T3wDUe3VvCSxi00uDe4BLEhUq5fSvwa7)2BR07WfkVGT1ueX9rAsOsBvjT3QZL4(TMpm4c1epDLfqqZ2BR07WfkVGT1ueX9rAsOsBvjtc2QZL4(TkimAWpzRCuiek8T6Cj6MA0tQbnmlay2owzbujT3EBLEhUq5fSTYrHqOW3QZLOBQrpPg0WSGIz16wDUe3VvpuPCBWpzLv2kppBVfqL2EBLEhUq5fSTYrHqOW3AMGXGGm4yVqOPP6iWn5RZFRoxI73ko2leAAQoc8vwa7y7Tv6D4cLxW2khfcHcFRsOsn5A5GywqXSkLaMfiqMLFxjFD(gpuPCBWpXGivp(HzbfZQGNz2Kz2(WSWyqqgbHrd(jgSuMfiqMnjmR4f6fd3lL4v0eCQn4Nmg6D4cLz2UYSjZS9HztcZ6aKqHqMbdPiEfTb)KXqVdxOmZMmZMeMv8c9Izee5QL4jd9oCHYmBYmBsywhGekeYaDCSHYnOarg6D4cLz2UUvNlX9BnFyWfQjE6klGAD7Tv6D4cLxW2khfcHcFR87k5RZ3G80i3GcezqKQh)WSGIzvWZmBYmBFywymiiJGWOb)edwkZceiZMeMv8c9IH7Ls8kAco1g8tgd9oCHYmBxz2Kz2(WSoajuiKzWqkIxrBWpzm07WfkZSabYSIxOxmJGixTepzO3HluMzbcKzDasOqid0XXgk3GcezO3HluMz76wDUe3V18HbxOM4PRSaMuBVTsVdxO8c2w5Oqiu4BLFxjFD(gbHrd(jgeP6XpmlaywLx7T6CjUFRWeAie4XRyLfWeS92k9oCHYlyBLJcHqHVv(DL815Beegn4NyqKQh)WSaGz1Q2B15sC)wHl3LBqyiLTYcOYV92k9oCHYlyBLJcHqHVv(DL815Beegn4NyqKQh)WSaGz1Q2B15sC)w9NtJG8sJ7LYklGj92BR07WfkVGTvokecf(w53vYxNVrqy0GFIbrQE8dZcaMvRAVvNlX9BfkqeC5U8klG9F7TvNlX9BTekWLPLqGLvOsVSv6D4cLxWwzbe0S92k9oCHYlyBLJcHqHVvymiiJGWOb)edICUWSjZSWyqqg4YD5c2ige5CHzbcKzHXGGmccJg8tmyPmBYmR4ifKyWjVi4MuUWSGIz7qBMnzMv8c9IH7iccR08q1qVdxOmZceiZkHk1KRLdIzbfZ2rc2QZL4(TMEsC)klGkP92BR07WfkVGTvokecf(wHXGGmWL7YfSrmyPmlqGmReQutUwoiMfaml)Us(68nccJg8tmzmKlX9nfy0mmlimBgd5sCpZceiZ2hMvCKcsm4KxeCtkxywqXSDOnZceiZMeMv8c9IH7iccR08q1qVdxOmZ2vMfiqMvcvQjxlheZckMvPeSvNlX9Bvqy0GFYkRS1r2ElGkT92QZL4(TskxA5MOBQn4NSv6D4cLxWwzbSJT3wP3HluEbBRCuiek8T6Cj6MA0tQbnmlaywL2QZL4(Tc7iKRGwzbuRBVT6CjUFREtfdLju7GAC015Sv6D4cLxWwzbmP2EBLEhUq5fSTYrHqOW3kIGq0G7WfIztMztcZ6CjU3mekLEPns8kmX3GkHcCzRoxI736qOu6L2iXRyLfWeS92k9oCHYlyBLJcHqHVvymiitkI4XqTb)KXGLYSjZS87k5RZ34HkLBd(jgiSsPHioUJuqnjujMfumRcEMztOywymiitkI4XqTb)KXmIZbNzbHzDUe3B8qLYTb)ed3hPjHkTvNlX9B1rC)P2GFYklGk)2BR07WfkVGTvokecf(wHXGGmQx3Kk9IblLztMz7dZcDCSHzbHz5(inePGEMfuml0XXgJQRCmlqGmRdqcfczGoo2q5guGid9oCHYmlqGmRdqcfczIVj4udHRmbx1G8hCMfamRsmlqGmRdqcfczgmKI4v0g8tgd9oCHYmlqGmR4f6fZiiYvlXtg6D4cLz2UUvNlX9Bf5PrUbfiALfWKE7Tv6D4cLxW2khfcHcFRWyqqMueXJHAd(jJjFD(B15sC)w9qLYTb)Kvwa7)2BR07WfkVGTvokecf(wHoo2WSGWSCFKgIuqpZckMf64yJr1voMfiqM1biHcHmqhhBOCdkqKHEhUqzMfiqM1biHcHmX3eCQHWvMGRAq(doZcaMvjMfiqM1biHcHmdgsr8kAd(jJHEhUqzMfiqMv8c9Izee5QL4jd9oCHYB15sC)wrEAKBqbIwzbe0S92QZL4(TMgeIhVI2GFYwP3HluEbBLfqL0E7Tv6D4cLxW2khfcHcFRqhhBywaWSkV2mlqGmlmgeKjfr8yO2GFYyWs3QZL4(T6iU)uBWpzLfqLuA7TvNlX9BDeYZkRn4NSv6D4cLxWwzLv2A3eAI7xa7qBL6VsA3rhMo0oP6yRD6OpEfZw77QPhsOmZMaM15sCpZwIrgdt3wNuIVa2rcsQTMIoOOqBvlmlO1rGpQ(p4rkZc6WEHqmDAHzXfjD6s96vecogSHFQ6NqfR4sCph5qI(ju56HlhSEyiVFzQB9POdkk0OVlquc7rE03fjCd0H9cHAGwhb(O6)GhPMju5mDAHztOjoPctiMvjLsKz7qBL6pZ2pMv7(3LjO)mDmDAHzb94(RGMUKPtlmB)y2(kNPmZc6pSxieZwXpXW0PfMTFmBFLZuMztypnYmBczGiM96MqmBFfQuMzR4NWSbeZQSdJzDeXSQx3XRWW0PfMTFmBF7qmReQutUwoiMf5coHywb3FMvCKcsmsOsn5A5Gyw5yw)LGhPUqml9zM9Gyw(Pc7IHPJPtlmBFJYrCmHYmlmbDiIz5NkSlmlmPi(XWS9fNtPYWS)99d3rQqyfM15sC)WS3xuMHPZ5sC)ysre)uHDrduXhWz6CUe3pMueXpvyxarJEhtHk9IlX9mDoxI7htkI4NkSlGOrp0DzMoNlX9Jjfr8tf2fq0OFWuvVVLssIbKgNlr3uJEsnObuALPtlmB990b)eMf5rMzHXGGOmZoIldZctqhIyw(Pc7cZctkIFyw)ZmBkI6x6js8ky2yy289KHPZ5sC)ysre)uHDben6N3th8tAJ4YW05CjUFmPiIFQWUaIg9PNe3Z05CjUFmPiIFQWUaIg94yVqOPP6iWz60cZ2fiI7JWScEmmRpml5OIYywFy20BMaUqmRCmB6j0lHxkkJzv4XZS(FcoHywUpcZMXqXRGzfCIzHcf4IHPZ5sC)ysre)uHDben6ZhgCHAINMykI4(injujnkPntNZL4(XKIi(Pc7ciA0limAWpjXueX9rAsOsAuYKGedinoxIUPg9KAqda6GPZ5sC)ysre)uHDben69qLYTb)KedinoxIUPg9KAqdO0kthtNwy2(gLJ4ycLzwQBcPmMvcvIzfCIzDUCiMngM172JIdxidtNZL4(rd)WEHqTb)eMoNlX9diA0JnulesDy6CUe3pGOrp3lLMZL4(wjgjX3vjn88W05CjUFarJEUxknNlX9TsmsIVRsAgjXasJZLOBQrpPg0akTY05CjUFarJEUxknNlX9TsmsIVRsAeuWbFWpzsmG04Cj6MA0tQbnaOdMoMoNlX9JHNhn4yVqOPP6iWtmG0Kjymiido2leAAQocCt(68z6CUe3pgEEarJ(8HbxOM4PjgqAKqLAY1YbbkLsaqG87k5RZ34HkLBd(jgeP6XpGsbpNCFGXGGmccJg8tmyPabMeXl0lgUxkXROj4uBWpzm07Wfk31K7tsCasOqiZGHueVI2GFYyO3Hluo5KiEHEXmcIC1s8KHEhUq5KtIdqcfczGoo2q5guGid9oCHYDLPZ5sC)y45ben6ZhgCHAINMyaPHFxjFD(gKNg5guGidIu94hqPGNtUpWyqqgbHrd(jgSuGatI4f6fd3lL4v0eCQn4Nmg6D4cL7AY9XbiHcHmdgsr8kAd(jJHEhUqzGafVqVygbrUAjEYqVdxOmqGoajuiKb64ydLBqbIm07Wfk3vMoNlX9JHNhq0OhMqdHapEfjgqA43vYxNVrqy0GFIbrQE8dauETz6CUe3pgEEarJE4YD5gegszjgqA43vYxNVrqy0GFIbrQE8da0Q2mDoxI7hdppGOrV)CAeKxACVusmG0WVRKVoFJGWOb)edIu94haOvTz6CUe3pgEEarJEOarWL7YjgqA43vYxNVrqy0GFIbrQE8da0Q2mDoxI7hdppGOrFjuGltlHalRqLEHPZ5sC)y45ben6tpjUpXasdmgeKrqy0GFIbroxsggdcYaxUlxWgXGiNlabcJbbzeegn4NyWstwCKcsm4KxeCtkxavhANS4f6fd3reewP5HQHEhUqzGaLqLAY1YbbQosatNZL4(XWZdiA0limAWpjXasdmgeKbUCxUGnIblfiqjuPMCTCqaGFxjFD(gbHrd(jMmgYL4(McmAgqYyixI7bcSpIJuqIbN8IGBs5cO6qBGatI4f6fd3reewP5HQHEhUq5UceOeQutUwoiqPucy6y6CUe3pMr0qkxA5MOBQn4NW05CjUFmJaIg9Woc5kOedinoxIUPg9KAqdauIPZ5sC)ygben69MkgktO2b14ORZHPZ5sC)ygben6hcLsV0gjEfjgqAqeeIgChUqjNeNlX9MHqP0lTrIxHj(gujuGlmDoxI7hZiGOrVJ4(tTb)KedinWyqqMueXJHAd(jJblnz(DL815B8qLYTb)edewP0qeh3rkOMeQeOuWZjuWyqqMueXJHAd(jJzeNdoioxI7nEOs52GFIH7J0KqLy6CUe3pMrarJEKNg5guGOedinWyqqg1RBsLEXGLMCFGoo2ac3hPHif0dkOJJngvx5ac0biHcHmqhhBOCdkqKHEhUqzGaDasOqit8nbNAiCLj4QgK)GdaLac0biHcHmdgsr8kAd(jJHEhUqzGafVqVygbrUAjEYqVdxOCxz6CUe3pMrarJEpuPCBWpjXasdmgeKjfr8yO2GFYyYxNptNZL4(XmciA0J80i3GceLyaPb64ydiCFKgIuqpOGoo2yuDLdiqhGekeYaDCSHYnOarg6D4cLbc0biHcHmX3eCQHWvMGRAq(doauciqhGekeYmyifXROn4Nmg6D4cLbcu8c9Izee5QL4jd9oCHYmDoxI7hZiGOrFAqiE8kAd(jmDoxI7hZiGOrVJ4(tTb)KedinqhhBaGYRnqGWyqqMueXJHAd(jJblLPZ5sC)ygben6hH8SYAd(jmDmDoxI7hJGco4d(jJgyhHCfetNZL4(XiOGd(GFYaIg9KYLwUj6MAd(jmDoxI7hJGco4d(jdiA0J80i3GceLyaPbgdcYiOGdEBWpzmyPj3hhGekeYaDCSHYnOarg6D4cLbc0biHcHmX3eCQHWvMGRAq(doauciqhGekeYmyifXROn4Nmg6D4cLbcu8c9Izee5QL4jd9oCHYDLPZ5sC)yeuWbFWpzarJEpuPCBWpjXasdmgeKrqbh82GFYyWstggdcYKIiEmuBWpzm5RZNPZ5sC)yeuWbFWpzarJEKNg5guGOedinWyqqgbfCWBd(jJblLPZ5sC)yeuWbFWpzarJEvSIed(jjgqAGXGGmck4G3g8tgt(68bcegdcYKIiEmuBWpzmyPabcDCSbajT2mDoxI7hJGco4d(jdiA0NgeIhVI2GFctNZL4(XiOGd(GFYaIg9EtfdLju7GAC015W05CjUFmck4Gp4NmGOr)qOu6L2iXRiXasdIGq0G7Wfk5K4CjU3mekLEPns8kmX3GkHcCHPZ5sC)yeuWbFWpzarJ(ripRS2GFYkRSla]] )
end