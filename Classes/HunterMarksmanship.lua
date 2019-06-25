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

        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20190317.2044, [[dq09NaqirGhjIQnrenkrItjs6vkPMLiv3sjj2ff)sjAyevDmIklte5zejnnIeDnvvzBej8nLegNss6CQQkRtjPmpIu3JOSprkhueeluvLhQKu1ffbfJueu5KkjcRKkAMkjIUPiiTtvfdvjPYtvQPQeUQiO0Ev5Vu1GjCyPwmsEmQMSexM0MvLptfgnsDAHvRKi9AvLMTKUnLSBe)wXWPshxeu1Yr55GMo01f12fr57eHXRQQ68IqRxjrnFk1(b(K7wC7sJ69jj5L7FYlv5wHjj5K)V)(3TXeD1B728VTd92K2sVDcTzFHwnbshU32TtSoD5wCB4KzC92jhiOr0fUAlx6iq6mLHpwlHHvU2ymeoRF4syyXxEBQCuXvcYrD7sJ69jj5L7FYlv5wHjj5K)V)wXT7mspSBVdRv)TPJsrjh1TlkKF7Kdej0M9fA1eiD4cejCzcQmGZKde0i6cxTLlDeiDMYWhRLWWkxBmgcN1pCjmS4lbotoqKqBgNgiKBfPdejjVC)diwfGij5xnPmjGtGZKdeRE6M4qHRgWzYbIvbisiLcqKXOgyIaHllgwGjce4aejKv3kPb4m5aXQaejSqfiWWs944lHceSgPvgqG0nbiWM5qrdgwQhhFjuGahGOjyWd3gvGqjfGyEabFSOA0C7Aar4T42il4FH0dcVf3h5Uf3U5ymKBt1mw7qVTsAQQwUFhEFs6wC7MJXqUT(F36aJKPEi9G3wjnvvl3VdVps9wCBL0uvTC)UnNfOYI(2u53ZGSG)1dPheAYUaHKabV96)vEgvGqsGGk)EMYKPQQhBxt292nhJHC7oS0Ihsp4H3hP8wCBL0uvTC)UnNfOYI(2u53ZGSG)1dPheAYUaHKarkarVYklq18gEgQf)lyQrjnvvlaHTnq0RSYcunbXJ0QNrNisBzyn5lqKgqihqyBde9kRSavdmZCeehEi9GqJsAQQwacBBGa7QsqdezABvdIAustv1cqK6TBogd52S2nk(xW0dVp)DlUTsAQQwUF3MZcuzrFBQ87zqwW)6H0dcnzxGqsGifGGk)EgxMYdO6H0dcnLrccqyBde8zQLrcIPdlT4H0dAE5A1ZuoDZCOEmSuGqAGO5ymethwAXdPh0WBi6XWsbcBBGGk)EgKLvi9GMSlqK6TBogd52DyPfpKEWdVpsXT42kPPQA5(DBolqLf9TPYVNbzb)Rhspi0KDVDZXyi3M1UrX)cME49zf3IBRKMQQL73T5Savw03Mk)EgKf8VEi9GqtzKGae22abv(9mUmLhq1dPheAYUaHKarcacQ87zqwwH0dAYUaHTnq8gEgcePbeRq(B3CmgYTTYvmG0dE49zvVf3U5ymKB7gkJhehEi9G3wjnvvl3VdVp)7wC7MJXqUD7TYSIY8ZZZzJeWBRKMQQL73H3h5K)wCBL0uvTC)UnNfOYI(2m9XuiDtvvGqsGibarZXyigOYCvc6HyqCycI)vdh04TBogd52qL5Qe0dXG44W7JCYDlUDZXyi3gIAxs0dPh82kPPQA5(D4H3UOVoxXBX9rUBXTvstv1Y972CwGkl6BxuQ87z4nedIdt2fiSTbIIsLFptjGUAT2uv1B1ocUj7ce22arrPYVNPeqxTwBQQ6vcRDOMS7TBogd528Uw9nhJH4RbeVDnGON0w6TZyudmXdVpjDlUTsAQQwUF3MZcuzrFBQ87zAORYr)88iT6LiQft2fiKeisbiWWs944lHcePbe8zQLrcIHszqL9niomLmRXyiaXAGOKzngdbiSTbIuacSzou0qRDfPnUCeiKgiK6FaHTnqKaGa7QsqZ3OwvMpiqmiC0OKMQQfGivGivGW2giWWs944lHcesdeYj1B3CmgYTZq1hOAbp8(i1BXTvstv1Y972nhJHCBExR(MJXq81aI3Ugq0tAl928c8W7JuElUTsAQQwUF3MZcuzrF7MJrYuVsuRqHaH0aHuVDZXyi3M31QV5ymeFnG4TRbe9K2sVnep8(83T42kPPQA5(DBolqLf9TBogjt9krTcfcePbejD7MJXqUnVRvFZXyi(AaXBxdi6jTLEBKf8Vq6bHhE4TDzkFSOA8wCFK7wCBL0uvTC)o8(K0T42kPPQA5(D49rQ3IBRKMQQL73H3hP8wCBL0uvTC)o8(83T42nhJHCB3bJHCBL0uvTC)o8(if3IB3CmgYTPZeuzqVvZ(EBL0uvTC)o8(SIBXTvstv1Y972UmL3q0JHLEB5K)2nhJHC7YKPQQhB3dVpR6T42kPPQA5(DBxMYBi6XWsVTCM)UDZXyi3gzzfsp4T5Savw03U5yKm1Re1kuiqKgqK0H3N)DlUTsAQQwUF3MZcuzrF7MJrYuVsuRqHaH0aHuVDZXyi3UdlT4H0dE4H3MxG3I7JC3IBRKMQQL73T5Savw03UOu53ZqNjOYGERM91ugjiaHKarcacQ87zqwwH0dAYU3U5ymKBtNjOYGERM99W7ts3IBRKMQQL73T5Savw03MptTmsqmS2nk(xWudtT6GabcPbch8cqyBde8zQLrcIH1UrX)cMAyQvheiqinqWNPwgjiMoS0IhspOHPwDqGaHTnqGHL6XXxcfiKgiss(B3CmgYTltMQQESDp8(i1BXTvstv1Y972CwGkl6BtLFpdYYkKEqt2fiKeisbiWWs944lHcePbe8zQLrcIHszqL9niomLmRXyiaXAGOKzngdbiSTbIuacSzou0qRDfPnUCeiKgissEGW2gisaqGDvjOH3m9LR(oSmkPPQAbisfisfiSTbcmSupo(sOaH0aHCs92nhJHCBkLbv23G44W7JuElUTsAQQwUF3MZcuzrFBQ87zqwwH0dAYUaHKarkabgwQhhFjuGinGGptTmsqmu1zk(xMLOPKzngdbiwdeLmRXyiaHTnqKcqGnZHIgATRiTXLJaH0arsYde22arcacSRkbn8MPVC13HLrjnvvlarQarQaHTnqGHL6XXxcfiKgiKtkUDZXyi3MQotX)YSep8(83T42kPPQA5(DBolqLf9TPYVNbzzfspOj7cescePaeyyPEC8LqbI0ac(m1YibX0eUcrwx98UwnLmRXyiaXAGOKzngdbiSTbIuacSzou0qRDfPnUCeiKgissEGW2gisaqGDvjOH3m9LR(oSmkPPQAbisfisfiSTbcmSupo(sOaH0aHCsXTBogd52nHRqK1vpVR1dVpsXT42kPPQA5(DBolqLf9TPYVNbzzfspOj7cescePaeyyPEC8LqbI0ac(m1YibX8cMsvNPykzwJXqaI1arjZAmgcqyBdePaeyZCOOHw7ksBC5iqinqKK8aHTnqKaGa7QsqdVz6lx9Dyzustv1cqKkqKkqyBdeyyPEC8LqbcPbI)D7MJXqU9lykvDMYH3NvClUDZXyi3UgoOrOFLMloSucEBL0uvTC)o8(SQ3IBRKMQQL73T5Savw03Mk)EgKLvi9GgM2CeiKeiOYVNHQotPMHOHPnhbcBBGGk)EgKLvi9GMSlqijqWBV(FLNrfiSTbcmSupo(sOaH0ars)D7MJXqUT7GXqo8(8VBXTvstv1Y972CwGkl6B)gEgcePbesH8aHKarkabv(9mUmLhq1dPheAkJeeGqsGGptTmsqmS2nk(xWudtT6GabcjbcmSupo(sOarAabFMAzKGyqwwH0dAkzwJXq8oYkeceRbIsM1ymeGW2giWM5qrdT2vK24YrGqAGij5bcBBGibab2vLGgEZ0xU67WYOKMQQfGivGW2giWWs944lHcesdeY93TBogd52ilRq6bp8WBdXBX9rUBXTBogd526)DRdmsM6H0dEBL0uvTC)o8(K0T42kPPQA5(DBolqLf9TBogjt9krTcfcePbeYD7MJXqUnvZyTd9W7JuVf3U5ymKB3ERmROm)88C2ib82kPPQA5(D49rkVf3wjnvvl3VBZzbQSOVntFmfs3uvfiKeisaq0CmgIbQmxLGEigehMG4F1WbnE7MJXqUnuzUkb9qmioo8(83T42kPPQA5(DBolqLf9TPYVNbzzfspOPmsqacBBG4n8meiKgiwH83U5ymKBZA3O4Fbtp8(if3IBRKMQQL73T5Savw03Mk)EgKLvi9GMSlqijqqLFpJvdrL5TA2xOvtmz3B3CmgYTBgVjQhsp4H3NvClUTsAQQwUF3MZcuzrFBQ87zqwwH0dAYUaHTnqKcqqLFptzYuv1JTRPmsqacBBGG3E9)kpJkqKkqijqqLFpJlt5bu9q6bHMYibbiSTbIxUw9mLt3mhQhdlfiKgi4ne9yyP3U5ymKB3HLw8q6bp8(SQ3IB3CmgYTDdLXdIdpKEWBRKMQQL73H3N)DlUTsAQQwUF3MZcuzrFBQ87zqwwH0dAkJeeGqsGifGGk)EgxMYdO6H0dcnzxGqsGifG4n8meisdiKs5acBBGGk)EgRgIkZB1SVqRMyYUarQaHTnqKcq8gEgcePbe)jpqijq0RSYcunVHNHAX)cMAustv1cqyBdeVHNHarAaXk(disfiKeisbi4ZulJeedYYkKEqdtT6GabI0aI)acBBG4n8meisdiwv5bIubcBBGadl1JJVekqinq8hqK6TBogd52nJ3e1dPh8W7JCYFlUDZXyi3gIAxs0dPh82kPPQA5(D4H3oJrnWeVf3h5Uf3U5ymKBZNmbvMhsp4Tvstv1Y97W7ts3IB3CmgYTHktjbMOVKH4Tvstv1Y97W7JuVf3U5ymKBdDhM651jxUTsAQQwUFhEFKYBXTBogd52Wzq6G4WlrJk72kPPQA5(D495VBXTBogd52WHeCpvTH4Tvstv1Y97W7JuClUDZXyi3MOiTY8q6H)92kPPQA5(D49zf3IB3CmgYT50XknGEK1Ke(CudmXBRKMQQL73H3Nv9wC7MJXqUn0nyb6H0d)7Tvstv1Y97W7Z)Uf3U5ymKBtAmZuO3bR56Tvstv1Y97Wdp82jtzWyi3NKKxU)jVuLBfMKKxkL6TLOzKG4aE7vcl3HHAbiKcGO5ymeGOgqeAaoVTlBErvVDYbIeAZ(cTAcKoCbIeUmbvgWzYbcAeDHR2YLocKotz4J1syyLRngdHZ6hUegw8LaNjhisOnJtdeYTI0bIKKxU)beRcqKK8RMuMeWjWzYbIvpDtCOWvd4m5aXQaejKsbiYyudmrGWLfdlWebcCaIeYQBL0aCMCGyvaIewOceyyPEC8LqbcwJ0kdiq6MaeyZCOObdl1JJVekqGdq0em4HBJkqOKcqmpGGpwunAaobotoqKW8FLNrTaeu6BykqWhlQgbck1rqGgGiHW5QlcbcYqwf6Mz9YvGO5ymeiqmKAIgGZMJXqGgxMYhlQgL9Qn8lWzZXyiqJlt5JfvJRLTSZoSuc2ymeGZMJXqGgxMYhlQgxlB5BMcWzYbInPDH0dceSokabv(90cqaXgHabL(gMce8XIQrGGsDeeiq0Kcq4Y0vXDqmioaIaceLHOgGZMJXqGgxMYhlQgxlBjK0Uq6b9qSriWzZXyiqJlt5JfvJRLT0DWyiaNnhJHanUmLpwunUw2s6mbvg0B1SVaNjhiwDmL3qeiq6acenei0MvteiAiq4oqyqvvGahGWDqLGrxRjceo6GaenzqALbe8gIarjZcIdGaPvG4foOrdWzZXyiqJlt5JfvJRLTSmzQQ6X2nDxMYBi6XWsLjN8aNnhJHanUmLpwunUw2sKLvi9GP7YuEdrpgwQm5m)LE8K1CmsM6vIAfkmTKaoBogdbACzkFSOACTSLDyPfpKEW0JNSMJrYuVsuRqHslvGtGZMJXqGMmg1atugFYeuzEi9GaNnhJHanzmQbM4AzlHktjbMOVKHiWzZXyiqtgJAGjUw2sO7WupVo5cWzZXyiqtgJAGjUw2s4miDqC4LOrLbC2Cmgc0KXOgyIRLTeoKG7PQneboBogdbAYyudmX1YwsuKwzEi9W)cC2Cmgc0KXOgyIRLTKthR0a6rwts4ZrnWeboBogdbAYyudmX1YwcDdwGEi9W)cC2Cmgc0KXOgyIRLTK0yMPqVdwZvGtGZKdejm)x5zulaHMmLLiqGHLceiTcenhhgqeqGOtwh1MQQgGZMJXqGY4DT6BogdXxdiMoPTuzzmQbMy6XtwrPYVNH3qmiomzxB7IsLFptjGUAT2uv1B1ocUj7ABxuQ87zkb0vR1MQQELWAhQj7cCcCMCGyblrGahGOgefiYUarZXiznQfGazb5RIqGqIaPbIfSScPhe4S5yme4AzlZq1hOAbtpEYOYVNPHUkh9ZZJ0QxIOwmzxjtbdl1JJVeAA8zQLrcIHszqL9niomLmRXyiRlzwJXqSTtbBMdfn0AxrAJlhLwQ)zBNaSRkbnFJAvz(GaXGWrJsAQQwsnvBBmSupo(sOslNuboBogdbUw2sExR(MJXq81aIPtAlvgVaboBogdbUw2sExR(MJXq81aIPtAlvgetpEYAogjt9krTcfkTuboBogdbUw2sExR(MJXq81aIPtAlvgYc(xi9GW0JNSMJrYuVsuRqHPLeWjWzZXyiqdVaLrNjOYGERM9n94jROu53ZqNjOYGERM91ugjisMaQ87zqwwH0dAYUaNnhJHan8cCTSLLjtvvp2UPhpz8zQLrcIH1UrX)cMAyQvheO0o4fBB(m1YibXWA3O4Fbtnm1QdcuA(m1YibX0HLw8q6bnm1Qdc02gdl1JJVeQ0jjpWzZXyiqdVaxlBjLYGk7BqCKE8KrLFpdYYkKEqt2vYuWWs944lHMgFMAzKGyOuguzFdIdtjZAmgY6sM1ymeB7uWM5qrdT2vK24YrPtsEB7eGDvjOH3m9LR(oSmkPPQAj1uTTXWs944lHkTCsf4S5ymeOHxGRLTKQotX)YSetpEYOYVNbzzfspOj7kzkyyPEC8LqtJptTmsqmu1zk(xMLOPKzngdzDjZAmgITDkyZCOOHw7ksBC5O0jjVTDcWUQe0WBM(YvFhwgL0uvTKAQ22yyPEC8LqLwoPa4S5ymeOHxGRLTSjCfISU65DTME8KrLFpdYYkKEqt2vYuWWs944lHMgFMAzKGyAcxHiRREExRMsM1ymK1LmRXyi22PGnZHIgATRiTXLJsNK822ja7QsqdVz6lx9Dyzustv1sQPABJHL6XXxcvA5KcGZMJXqGgEbUw2YxWuQ6mL0JNmQ87zqwwH0dAYUsMcgwQhhFj004ZulJeeZlykvDMIPKzngdzDjZAmgITDkyZCOOHw7ksBC5O0jjVTDcWUQe0WBM(YvFhwgL0uvTKAQ22yyPEC8LqL(FaNnhJHan8cCTSL1Wbnc9R0CXHLsqGZMJXqGgEbUw2s3bJHKE8KrLFpdYYkKEqdtBokjv(9mu1zk1menmT5OTnv(9milRq6bnzxj5Tx)VYZOABJHL6XXxcv6K(d4S5ymeOHxGRLTezzfspy6Xt2B4zyAsH8sMcv(9mUmLhq1dPheAkJeej5ZulJeedRDJI)fm1WuRoiqjXWs944lHMgFMAzKGyqwwH0dAkzwJXq8oYkeUUKzngdX2gBMdfn0AxrAJlhLoj5TTta2vLGgEZ0xU67WYOKMQQLuTTXWs944lHkTC)bCcC2Cmgc0arz6)DRdmsM6H0dcC2Cmgc0aX1Yws1mw7qtpEYAogjt9krTcfMMCaNnhJHanqCTSLT3kZkkZpppNnsaboBogdbAG4AzlHkZvjOhIbXr6XtgtFmfs3uvvYe0CmgIbQmxLGEigehMG4F1WbncC2Cmgc0aX1YwYA3O4FbttpEYOYVNbzzfspOPmsqSTFdpdLEfYdC2Cmgc0aX1Yw2mEtupKEW0JNmQ87zqwwH0dAYUssLFpJvdrL5TA2xOvtmzxGZMJXqGgiUw2YoS0Ihspy6Xtgv(9milRq6bnzxB7uOYVNPmzQQ6X21ugji2282R)x5zutvsQ87zCzkpGQhspi0ugji22VCT6zkNUzoupgwQ08gIEmSuGZMJXqGgiUw2s3qz8G4WdPhe4S5ymeObIRLTSz8MOEi9GPhpzu53ZGSScPh0ugjisMcv(9mUmLhq1dPheAYUsMYB4zyAsPC22u53Zy1quzERM9fA1et2nvB7uEdpdt7p5LSxzLfOAEdpd1I)fm1OKMQQfB73WZW0wXFPkzk8zQLrcIbzzfspOHPwDqGP9NT9B4zyARQ8PABJHL6XXxcv6)sf4S5ymeObIRLTeIAxs0dPhe4e4S5ymeObzb)lKEqOmQMXAhkWzZXyiqdYc(xi9GW1YwQ)3ToWizQhspiWzZXyiqdYc(xi9GW1Yw2HLw8q6btpEYOYVNbzb)Rhspi0KDLK3E9)kpJQKu53ZuMmvv9y7AYUaNnhJHanil4FH0dcxlBjRDJI)fmn94jJk)EgKf8VEi9Gqt2vYu6vwzbQM3WZqT4FbtnkPPQAX2UxzLfOAcIhPvpJorK2YWAY30KZ2UxzLfOAGzMJG4WdPheAustv1ITn2vLGgiY02Qge1OKMQQLuboBogdbAqwW)cPheUw2YoS0Ihspy6Xtgv(9mil4F9q6bHMSRKPqLFpJlt5bu9q6bHMYibX2MptTmsqmDyPfpKEqZlxREMYPBMd1JHLkDZXyiMoS0IhspOH3q0JHLABtLFpdYYkKEqt2nvGZMJXqGgKf8Vq6bHRLTK1UrX)cMME8KrLFpdYc(xpKEqOj7cC2Cmgc0GSG)fspiCTSLw5kgq6btpEYOYVNbzb)Rhspi0ugji22u53Z4YuEavpKEqOj7kzcOYVNbzzfspOj7AB)gEgM2kKh4S5ymeObzb)lKEq4AzlDdLXdIdpKEqGZMJXqGgKf8Vq6bHRLTS9wzwrz(555SrciWzZXyiqdYc(xi9GW1YwcvMRsqpedIJ0JNmM(ykKUPQQKjO5ymeduzUkb9qmiombX)QHdAe4S5ymeObzb)lKEq4AzlHO2Le9q6bVn0v53NK(tkp8W7aa]] )
end