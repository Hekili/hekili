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
            id = 193526,
            duration = 15,
            max_stack = 1,
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
            cooldown = 12,
            recharge = 12,
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
            
            startsCombat = true,
            texture = 132213,
            
            handler = function ()
                if talent.steady_focus.enabled then applyBuff( "steady_focus", 12, min( 2, buff.steady_focus.stack + 1 ) ) end
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
    
        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20180919.2239, [[dOuDIaqisQ6raeBIe1NOQOAuIsDkrjRsuOYRaKzrvPBrIWUi1VOKgMOIJrszzGIEMOstduQUgaPTbk03irY4iPsNduW6iPI5bk5EKW(aOoOOqwiG6HKiLlsvrXgPQO0hjrKmsse1jjreRKsmtsKkDtrb2jagQOGwkvf5PImvrvxvuOQVsIuXEv8xPAWu5WclgOhJYKLYLj2Sk(mvvJwLoTQwnjsvVgu1SP42uQDd53knCQYXjrKA5O65sMoY1bz7II(oOY4bLY5PQW6ffkZNKSFOEuBYpPwqYaamZrn1nhyqnyqdtyMRsLJsnjYhEYK8cg8HFzsOWwMugeC4l7av33BsEHpmB0M8tQwiotMeGGDxI8k1XQv)pDHa1S12A92qMG(fX4XHSwVnZkOzbTcEcLOjzA1JVN3iL1mKl(u8TYAg6tDLmeIeEpdco8LDGQ77PR3MnjqO3qkjObCsTGKbayMJAQBoWGAWGgMWmxavnyCsbeDx(KsVTsBsnPytcqWUmi4Wx2bQUVh2PKHqKWXwaeS7sKxPowT6)PleOMT2wR3gYe0VigpoK16TzwbnlOvWtOenjtRE898gPSMHCXNIVvwZqFQRKHqKW7zqWHVSduDFpD92mSfab7sIhj2Gch7udg8f7GzoQPUyNsGDQLJ6KlSJDzygGTGTaiyNs7gi)sPoylac2Peyxg1Asd7uAleIeo2LUlPXwaeStjWUmQ1Kg2jiI7dS7SCSZNcVVHD(SpxWo4Ucc7S3mFKFSl7mln2LrVT0WU0DPS0tY8fvt(jr8NbFDxQM8daQn5NuWOFrtcm48WVmjbfGgPnap0aamN8tky0VOjjWMNzRptPx3LMKGcqJ0gGhAai3j)KeuaAK2a8Ky8Ne(htce6C0e)zW3R7sLgYd7ug7up2rHrqKgm48WVOfuaAK2Kcg9lAs8W7B9ZZLHgaG9j)KeuaAK2a8Ky8Ne(htce6C0e)zW3R7sLgYd7ug7aHohThxyFj96UuPBlCiStzSde6C0Tfc0iDk80Tfoe2Pm2Ln2PESJcJGiTrOBy61DPslOa0inStLkSde6C0gHUHPx3LknKh2Psf2DwguHDag7GXCWUSMuWOFrtkEBP1R7sdnaaOt(jjOa0iTb4jX4pj8pMei05Oj(ZGVx3LknK3Kcg9lAs8W7B9ZZLHgaGXj)KeuaAK2a8Ky8Ne(htce6C0e)zW3R7sLUTWHWovQWUSXoqOZr7Xf2xsVUlvAipStLkSde6C0gHUHPx3LknKh2Lf2Pm2Ln2PESJcJGinyW5HFrlOa0inStzSde6C0fjrZh9ZYGkDBHdHDkJDNLbvyhGXoyhqXovQWUZYGkSdWyNsLd2L1Kcg9lAs2qg6R7sdnaOut(jfm6x0K8EHZEK)EDxAsckansBaEOba1DYpPGr)IMu0TH4nH33tNXx4QjjOa0iTb4HgaGHj)KeuaAK2a8Ky8Ne(htIlhUu3a0itky0VOjvc3tquVOh5FOba1YzYpjbfGgPnapjg)jH)XKoldQWoGWowuuNl(fe2blS7SmOsBhWg2Psf2Ln2rHrqK2i0nm96UuPfuaAKg2Pm2bcDoAJq3W0R7sLUTWHWUSMuWOFrtQijA(Ox3LgAOj1KtazOj)aGAt(jfm6x0KciA71DPjjOa0iTb4HgaG5KFsbJ(fnj2cHiH3R7stsqbOrAdWdnaK7KFsbJ(fnjOs6pj21KeuaAK2a8qdaW(KFsckansBaEsbJ(fnjwym9Gr)I6MVOjz(I6OWwMeRvdnaaOt(jjOa0iTb4jX4pj8pMuWOptPliX(Lc7Gf2L7Kcg9lAsSWy6bJ(f1nFrtY8f1rHTmPIgAaagN8tsqbOrAdWtIXFs4FmPGrFMsxqI9lf2bySdMtky0VOjXcJPhm6xu38fnjZxuhf2YKi(ZGVUlvdn0K84cBTbdAYpaO2KFsckansBaEObayo5NKGcqJ0gGhAai3j)KeuaAK2a8qdaW(KFsckansBaEsm(tc)Jjfm6Zu6csSFPWoyHD5oPGr)IMubzBVOUNqdnaaOt(jjOa0iTb4HgaGXj)Kcg9lAsEl9lAsckansBaEObaLAYpPGr)IM0fcrcV62bh(jjOa0iTb4Hgau3j)KeuaAK2a8K84clkQtVTmjaDsbJ(fnP2cbAKofEdnaadt(jjOa0iTb4jX4pj8pMuWOptPliX(Lc7Gf2L7Kcg9lAsXBlTEDxAOba1YzYpjbfGgPnapjg)jH)XKcg9zkDbj2VuyhGXoyoPGr)IMKaBEMT(mLEDxAOHMeRvt(ba1M8tsqbOrAdWtIXFs4FmPMacDo6leIeE1Tdo862chAsbJ(fnPleIeE1Tdo8dnaaZj)KeuaAK2a8Ky8Ne(htITRPTWH08W7B9ZZfnxSJhvyhSWo)S2Kcg9lAsTfc0iDk8gAai3j)KeuaAK2a8Ky8Ne(htITRPTWH0ehsQ7sAUyhpQWoaJD5MZKcg9lAsGcVeo8pY)qdaW(KFsckansBaEsm(tc)JjX210w4qAIdj1DjnxSJhvyhGXUCZzsbJ(fnjqZUT(bI7JHgaa0j)KeuaAK2a8Ky8Ne(htITRPTWH0ehsQ7sAUyhpQWoaJD5MZKcg9lAsbIjfXdtNfgZqdaW4KFsckansBaEsm(tc)JjX210w4qAIdj1DjnxSJhvyhGXUCZzsbJ(fnPZZfqZUTHgauQj)Kcg9lAsM3)LQUspuZVTGOjjOa0iTb4Hgau3j)KeuaAK2a8Ky8Ne(htkBSde6C0ehsQ7sAUemc7ug7aHohnOz3MbQinxcgHDzHDQuHDzJDzJDSfvq2bOr0E81Si)sR7TWjCStzSJcUFH00BlDA7TxWoyHDWimXUSWovQWok4(fstVT0PT3Eb7Gf2LRAyxwtky0VOj5T0VOHgaGHj)KeuaAK2a8Ky8Ne(htITRPTWH0XBlTEDxsZUb3VuyhSWo1WovQWokmcI0GbNh(fTGcqJ0WoLXo2UM2chshVT061Djn7gC)s1p8Gr)Icd2blStnDUtky0VOjrCiPUln0qtQOj)aGAt(jfm6x0KeyZZS1NP0R7stsqbOrAdWdnaaZj)KeuaAK2a8Ky8Ne(htky0NP0fKy)sHDag7uBsbJ(fnjWGZd)Yqda5o5NKGcqJ0gGNeJ)KW)ysGqNJ2JlSVKEDxQ0qEyNYyx2yhBxtBHdPJ3wA96UK(azmDUWUb3V0P3wWoyHD(znSlJd7aHohThxyFj96UuPlkyWJDaHDbJ(fPJ3wA96UKMff1P3wWovQWoqOZrBe6gMEDxQ0qEyxwtky0VOjfCwGKEDxAObayFYpjbfGgPnapjg)jH)XKYg7up2rHrqK2i0nm96UuPfuaAKg2Psf2bcDoAJq3W0R7sLgYd7Yc7ug7ImMWFs0NLbvsRFEUOfuaAKg2Psf2fzmH)KOFuNUsNF9bDT18abp2byStTjfm6x0K4H336NNldnaaOt(jjOa0iTb4jX4pj8pMei05OT3mfBbrAipStzSlBSt9yhfgbrAJq3W0R7sLwqbOrAyNkvyhi05OncDdtVUlvAipSlRjfm6x0K4H336NNldnaaJt(jjOa0iTb4jX4pj8pMei05O94c7lPx3LkDBHdHDkJDzJDGqNJUTqGgPtHNUTWHWoLXUdKX05c7gC)sNEBb7Gf2XII60BlyhqyNFwd7uPc7aHohTrOBy61DPsd5HDznPGr)IMu82sRx3LgAaqPM8tsqbOrAdWtIXFs4Fmj1JDuyeePncDdtVUlvAbfGgPHDQuHDGqNJ2i0nm96UuPH8MuWOFrtIhEFRFEUm0aG6o5NuWOFrtY7fo7r(71DPjjOa0iTb4HgaGHj)Kcg9lAsr3gI3eEFpDgFHRMKGcqJ0gGhAaqTCM8tsqbOrAdWtIXFs4FmjUC4sDdqJmPGr)IMujCpbr9IEK)HgautTj)KeuaAK2a8Ky8Ne(htce6C0ECH9L0R7sLUTWHWoLXUSXo1JDuyeePlsIMp6NLbvAbfGgPHDkJDNLbvyhGXoLkhStLkSt9yhfgbrAJq3W0R7sLwqbOrAyNkvyhi05OncDdtVUlvAipSlRjfm6x0KI3wA96U0qdaQbZj)KeuaAK2a8Ky8Ne(htce6C0ECH9L0R7sLgYd7uPc7oldQWoaJDWyoyNYyx2yN6XokmcI0gHUHPx3LkTGcqJ0WovQWoqOZrBe6gMEDxQ0qEyxwtky0VOjfCwGKEDxAOba1YDYpjbfGgPnapjg)jH)XKoldQWoGWowuuNl(fe2blS7SmOsBhWg2Psf2Ln2rHrqK2i0nm96UuPfuaAKg2Pm2bcDoAJq3W0R7sLUTWHWUSMuWOFrtQijA(Ox3LgAaqnyFYpPGr)IMuWzbs61DPjjOa0iTb4HgAOjLPWRFrdaWmh1u3CGb1utdtyMlmmj4co6r(RjP0jJ8jausaqjL6GDyx(RGDVT3YjS7SCSZN3KtaziFo2XfL0qpxAyxT2c2fq0AhK0Wo2nq(LsJTO09rc2PM6GDz8OcYZB5K0WUGr)IWoFEarBVUl5Z1ylylkj2ElNKg2bOyxWOFryN5lQ0yltQ8e2aambuyFsE898gzsac2Lbbh(Yoq199WoLmeIeo2cGGDxI8k1XQv)pDHa1S12A92qMG(fX4XHSwVnZkOzbTcEcLOjzA1JVN3iL1mKl(u8TYAg6tDLmeIeEpdco8LDGQ77PR3MHTaiyxs8iXgu4yNAWGVyhmZrn1f7ucStTCuNCHDSldZaSfSfab7uA3a5xk1bBbqWoLa7YOwtAyNsBHqKWXU0Djn2cGGDkb2LrTM0WobrCFGDNLJD(u49nSZN95c2b3vqyN9M5J8JDzNzPXUm6TLg2LUlLLgBbBb78zGnHbrsd7aLZYfSJT2GbHDGI)hvASlJymXJkSdTiL4gC7dKb7cg9lQWUfz8HgBjy0VOs7Xf2AdgKIJjk4Xwcg9lQ0ECHT2GbbKcRbKFBbrb9lcBjy0VOs7Xf2AdgeqkSE2THTem6xuP94cBTbdcifwliB7f19eY3)Oiy0NP0fKy)sbRCXwaeSlHcV6Ue2XJVHDGqNJ0WUIcQWoq5SCb7yRnyqyhO4)rf2fOg25XfLWBj6r(XUVWU2Ien2sWOFrL2JlS1gmiGuyTqHxDxQxuqf2sWOFrL2JlS1gmiGuy1BPFrylbJ(fvApUWwBWGasH1leIeE1Tdo8ylbJ(fvApUWwBWGasH12cbAKofE(6XfwuuNEBrbGITem6xuP94cBTbdcifwJ3wA96UKV)rrWOptPliX(Lcw5ITem6xuP94cBTbdcifwfyZZS1NP0R7s((hfbJ(mLUGe7xkadtSfSfab78zGnHbrsd7KmfUpWo6TfSJUc2fmA5y3xyxKz8Ma0iASLGr)IkfbeT96Ue2sWOFrfqkSYwiej8EDxcBjy0VOcifwHkP)KyxylbJ(fvaPWklmMEWOFrDZxKVOWwuWAf2sWOFrfqkSYcJPhm6xu38f5lkSfff57Fuem6Zu6csSFPGvUylbJ(fvaPWklmMEWOFrDZxKVOWwuq8NbFDxQ89pkcg9zkDbj2VuagMylylbJ(fvAwRuCHqKWRUDWH33)OOjGqNJ(cHiHxD7GdVUTWHWwcg9lQ0SwbKcRTfc0iDk889pky7AAlCinp8(w)8CrZf74rfS8ZAylbJ(fvAwRasHvqHxch(h533)OGTRPTWH0ehsQ7sAUyhpQaCU5GTem6xuPzTcifwbn726hiUp89pky7AAlCinXHK6UKMl2XJkaNBoylbJ(fvAwRasH1aXKI4HPZcJX3)OGTRPTWH0ehsQ7sAUyhpQaCU5GTem6xuPzTcifwppxan7289pky7AAlCinXHK6UKMl2XJkaNBoylbJ(fvAwRasHvZ7)svxPhQ53wqe2sWOFrLM1kGuy1BPFr((hfzdcDoAIdj1DjnxcgPmi05Obn72mqfP5sWOSuPk7SzlQGSdqJO94Rzr(Lw3BHt4ktb3VqA6TLoT92lWcgHzwQurb3VqA6TLoT92lWkx1YcBjy0VOsZAfqkSsCiPUl57FuW210w4q64TLwVUlPz3G7xkyPMkvuyeePbdop8lAbfGgPPmBxtBHdPJ3wA96UKMDdUFP6hEWOFrHbwQPZfBbBjy0VOsxKcb28mB9zk96Ue2sWOFrLUiGuyfm48WV47Fuem6Zu6csSFPaSAylbJ(fv6IasH1GZcK0R7s((hfGqNJ2JlSVKEDxQ0qEkNnBxtBHdPJ3wA96UK(azmDUWUb3V0P3wGLFwlJde6C0ECH9L0R7sLUOGbpqbJ(fPJ3wA96UKMff1P3wuPce6C0gHUHPx3LknKxwylbJ(fv6IasHvE49T(55IV)rr2QNcJGiTrOBy61DPslOa0invQaHohTrOBy61DPsd5LLYrgt4pj6ZYGkP1ppx0ckanstLQiJj8Ne9J60v68RpORTMhi4bSAylbJ(fv6IasHvE49T(55IV)rbi05OT3mfBbrAipLZw9uyeePncDdtVUlvAbfGgPPsfi05OncDdtVUlvAiVSWwcg9lQ0fbKcRXBlTEDxY3)Oae6C0ECH9L0R7sLUTWHuoBqOZr3wiqJ0PWt3w4qkFGmMoxy3G7x60BlWIff1P3waYpRPsfi05OncDdtVUlvAiVSWwcg9lQ0fbKcR8W7B9ZZfF)Jc1tHrqK2i0nm96UuPfuaAKMkvGqNJ2i0nm96UuPH8Wwcg9lQ0fbKcREVWzpYFVUlHTem6xuPlcifwJUneVj8(E6m(cxHTem6xuPlcifwlH7jiQx0J877FuWLdxQBaAeSLGr)IkDraPWA82sRx3L89pkaHohThxyFj96UuPBlCiLZw9uyeePlsIMp6NLbvAbfGgPP8zzqfGvQCuPs9uyeePncDdtVUlvAbfGgPPsfi05OncDdtVUlvAiVSWwcg9lQ0fbKcRbNfiPx3L89pkaHohThxyFj96UuPH8uP6SmOcWWyokNT6PWiisBe6gMEDxQ0ckanstLkqOZrBe6gMEDxQ0qEzHTem6xuPlcifwlsIMp61DjF)JIZYGkGyrrDU4xqW6SmOsBhWMkvztHrqK2i0nm96UuPfuaAKMYGqNJ2i0nm96UuPBlCOSWwcg9lQ0fbKcRbNfiPx3LWwWwcg9lQ0e)zWx3LkfGbNh(fSLGr)IknXFg81DPcifwfyZZS1NP0R7sylbJ(fvAI)m4R7sfqkSYdVV1ppx89pkaHohnXFg896UuPH8uw9uyeePbdop8lAbfGgPHTem6xuPj(ZGVUlvaPWA82sRx3L89pkaHohnXFg896UuPH8uge6C0ECH9L0R7sLUTWHuge6C0Tfc0iDk80TfoKYzREkmcI0gHUHPx3LkTGcqJ0uPce6C0gHUHPx3LknKNkvNLbvaggZjlSLGr)IknXFg81DPcifw5H336NNl((hfGqNJM4pd(EDxQ0qEylbJ(fvAI)m4R7sfqkSAdzOVUl57FuacDoAI)m471DPs3w4qQuLni05O94c7lPx3LknKNkvGqNJ2i0nm96UuPH8Ys5SvpfgbrAWGZd)IwqbOrAkdcDo6IKO5J(zzqLUTWHu(SmOcWWoGQs1zzqfGvQCYcBjy0VOst8NbFDxQasHvVx4Sh5Vx3LWwcg9lQ0e)zWx3LkGuyn62q8MW77PZ4lCf2sWOFrLM4pd(6UubKcRLW9ee1l6r(99pk4YHl1nanc2sWOFrLM4pd(6UubKcRfjrZh96UKV)rXzzqfqSOOox8liyDwguPTdytLQSPWiisBe6gMEDxQ0ckanstzqOZrBe6gMEDxQ0Tfouwdn0m]] )
end