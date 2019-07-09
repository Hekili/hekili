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


    spec:RegisterPack( "Marksmanship", 20190709.1200, [[dqK)WaqisP6rQk0MiLmkvv1PuvLxPkmlbLBPQiTlk(LuvdtqCmvLwMGQNPQGPPQOUgIOTHi03uvHXrkfDoebRJukzEKIUhIAFQQ0bfKkluvYdjLs5IcsvgPGuvNuvruRKuzMQkcDtsPuTtvrdLuk0tv0uLQCvvfb7vL)sPbtLdlzXi8yitwkxMyZk8zsvJMeNw0QjLcETQuZwOBts7g0VvA4cCCvfrwouphy6OUovTDbjFNuy8cs58isRxvfnFPY(r67717MTIL7z4H8Lec5hHqcMVFGKFiCsEtM0a5Mbf6DPxUjSuLBQTx43a1ccuYGBguKg3QD9Ujy9yKCZpsDkmha0w97RpzfpHbTQ9bPQpwCUqeUgCFqQI6FtcFg5pz4rCZwXY9m8q(scH8JqibZ3pqYpe(NVz5zLfFZzQQTDtLS1e4rCZMaq38JuN2EHFduliqjdOUqFpKfmv3hPofMdaAR(91NSINWGw1(Gu1hloxicxdUpivr9P6(i1PZhjL6iHWOUWd5ljqDFk199R2kCss1r19rQtBtPG6fG2IQ7Ju3NsDHUwJ68CgtMuQlaNlozsPoEPUqN24NOHQ7Ju3NsDFcaH64uvS8ABPqD4Ivem1XkfK64cRxydNQILxBlfQJxQRGCIYGIfQtGnQBhuhAvjk2CZycyW17MmorVbkldUE3ZVxVBwiox4njkmU0l3uGfruA3RJVNHF9UzH4CH3ucTG4cYqjwGYY3uGfruA3RJVNF46DtbwerPDVUjcNSGZ6Me(XWW4e92cuwgy8buNwuhQSsOjipluNwuhHFmmT1teflxbgFWnleNl8MvQknlqz5JVNF(6DtbwerPDVUjcNSGZ6Me(XWW4e92cuwgy8buNwu3)ux9tbNSyglYdKMDKyXiWIiknQRRJ6QFk4KftcTSIyXkKYkQgCbFtD)sDFPUUoQR(PGtwmapwFc1BbkldmcSiIsJ666OoUIcKnaglLAmHIrGfruAu3F3SqCUWBIRGSzhjwo(EsYR3nfyreL296MiCYcoRBs4hddJt0BlqzzGXhqDArD)tDe(XWeGfucelqzzGPTAaPUUoQdTBSTAanvQknlqzzZWhJwSGukSEXYPQqDAsDfIZfAQuvAwGYYgubylNQc111rDe(XWWyVauw24dOU)UzH4CH3SsvPzbklF89KeVE3uGfruA3RBIWjl4SUjHFmmmorVTaLLbgFWnleNl8M4kiB2rILJVN)46DtbwerPDVUjcNSGZ6Me(XWW4e92cuwgyARgqQRRJ6i8JHjalOeiwGYYaJpG60I60o1r4hddJ9cqzzJpG666OUXI8aQ7xQ7hHCZcX5cVPQpYjqz5JVNAZR3nleNl8MJf5bsZw)uWjlwcPuVPalIO0UxhFpjHR3nleNl8MbECoinH6TeXcW3uGfruA3RJVNFd56DZcX5cVjAHibY4ILMDelv5McSiIs7ED89873R3nleNl8MeXDB2DyzfXkqrL0BkWIikT71X3ZVHF9UPalIO0Ux3eHtwWzDtc)yyWc6Duaa7yXiX4dOUUoQJWpggSGEhfaWowmsSO1dzbBaCHEtDAsDFd5MfIZfEtwrSEiX6Hn7yXi54753pC9UzH4CH3mifmkH6TaLLVPalIO0UxhFp)(5R3nleNl8MLv1JBc2UdlcVAaUPalIO0UxhFp)sYR3nfyreL296MiCYcoRBILbwakfruOoTOoTtDfIZfAacoqGSfWjuVjH2rm1RW3SqCUWBceCGazlGtO(JVNFjXR3nleNl8MawQgPwGYY3uGfruA3RJp(Mnzu(iF9UNFVE3uGfruA3RBIWjl4SUzti8JHbvaoH6n(aQRRJ6AcHFmmTeeiXyrefRAPprgFa111rDnHWpgMwccKySiIIvG4sVy8b3SqCUWBIQy0wioxOnMa(MXeWwyPk30Zzmzsp(Eg(17McSiIs7EDZcX5cVP(kkOkgfmWsSl8MiCYcoRBs4hddJ9cqzzJpG666OoTtDCffiBqvmMq9wwrSaLLbgbwerPrDDDuhNQILxBlfQttQ7Bi3ewQYn1xrbvXOGbwIDHhFp)W17McSiIs7EDteozbN1nj8JHHXEbOSSXhqDDDuN2PoUIcKnOkgtOElRiwGYYaJalIO0OUUoQJtvXYRTLc1Pj1fEi3SqCUWB6bInzrfC898ZxVBkWIikT71nleNl8MOkgTfIZfAJjGVzmbSfwQYnrnWX3tsE9UPalIO0Ux3eHtwWzDZcXzOeRaf1uauNMu3hUzH4CH3evXOTqCUqBmb8nJjGTWsvUjGp(EsIxVBkWIikT71nr4KfCw3SqCgkXkqrnfa19l1f(nleNl8MOkgTfIZfAJjGVzmbSfwQYnzCIEduwgC8X3malOvLO4R398717McSiIs7ED89m8R3nfyreL296475hUE3uGfruA3RJVNF(6DtbwerPDVo(EsYR3nleNl8MblNl8McSiIs7ED89KeVE3SqCUWBQ4HSGbw1c)(McSiIs7ED898hxVBkWIikT71ndWcQaSLtv5MFd5MfIZfEZ26jIILRGJVNAZR3nleNl8MAS4yluscTybSWcIKBkWIikT71X3ts46DZcX5cVPEFHBzbT7Ww)uWlRCtbwerPDVo(E(nKR3nleNl8MQI6Ij1UdB0JYMTHLsfCtbwerPDVo(E(9717McSiIs7EDZaSGkaB5uvU5xdjVzH4CH3KXEbOS8nr4KfCw3SqCgkXkqrnfa19l1f(X3ZVHF9UPalIO0Ux3eHtwWzDZcXzOeRaf1uauNMu3hUzH4CH3SsvPzbklF8X3e1axV753R3nfyreL296MiCYcoRB2ec)yyu8qwWaRAHFBARgqQtlQt7uhHFmmm2laLLn(GBwiox4nv8qwWaRAHFF89m8R3nfyreL296MiCYcoRBI2n2wnGgCfKn7iXIblQvcbuNMuNEuJ666Oo0UX2Qb0GRGSzhjwmyrTsiG60K6q7gBRgqtLQsZcuw2Gf1kHaQRRJ64uvS8ABPqDAsDHhYnleNl8MT1teflxbhFp)W17McSiIs7EDteozbN1nj8JHHXEbOSSXhqDArD)tDCQkwETTuOUFPo0UX2Qb0qiyGGFNq9MMhxCUqQ7b1184IZfsDDDu3)uhxy9cBuKkYkMaetDAsDHhc111rDAN64kkq2GkSm8rBLQgbwerPrD)rD)rDDDuhNQILxBlfQttQ77hUzH4CH3KqWab)oH6p(E(5R3nfyreL296MiCYcoRBs4hddJ9cqzzJpG60I6(N64uvS8ABPqD)sDODJTvdOHiUBZo8ysnnpU4CHu3dQR5XfNlK666OU)PoUW6f2OivKvmbiM60K6cpeQRRJ60o1XvuGSbvyz4J2kvncSiIsJ6(J6(J666OoovflV2wkuNMu3xs8MfIZfEtI4Un7WJj947jjVE3uGfruA3RBIWjl4SUjHFmmm2laLLn(aQtlQ7FQJtvXYRTLc19l1H2n2wnGMcIeaJROfvXOP5XfNlK6EqDnpU4CHuxxh19p1XfwVWgfPISIjaXuNMux4HqDDDuN2PoUIcKnOcldF0wPQrGfruAu3Fu3Fuxxh1XPQy512sH60K6(sI3SqCUWBwqKayCfTOkgp(EsIxVBkWIikT71nr4KfCw3KWpggg7fGYYgFa1Pf19p1XPQy512sH6(L6q7gBRgqZiXcrC3MP5XfNlK6EqDnpU4CHuxxh19p1XfwVWgfPISIjaXuNMux4HqDDDuN2PoUIcKnOcldF0wPQrGfruAu3Fu3Fuxxh1XPQy512sH60K6iHBwiox4nhjwiI72o(E(JR3nleNl8MXuVcdSAd(MEvbY3uGfruA3RJVNAZR3nfyreL296MiCYcoRBs4hdtmhcrC3MbWf6n1Pj195Bwiox4n1yXXwOKeAXcyHfejhFpjHR3nfyreL296MiCYcoRBI2n2wnGgg7fGYYgSOwjeqDAsDFj5nleNl8M69fULf0UdB9tbVSYX3ZVHC9UPalIO0Ux3eHtwWzDt0UX2Qb0WyVauw2Gf1kHaQttQ7h3SqCUWBIZGGOytOfeui54753VxVBwiox4nvf1ftQDh2OhLnBdlLk4McSiIs7ED898B4xVBkWIikT71nr4KfCw3KWpggg7fGYYgSuiM60I6i8JHHiUBl6bSblfIPUUoQJWpggg7fGYYgFa1Pf1HkReAcYZc111rDCQkwETTuOonPUWj5nleNl8MblNl84753pC9UPalIO0Ux3eHtwWzDZXI8aQ7xQJedH60I6(N6i8JHjalOeiwGYYatB1asDArDODJTvdObxbzZosSyWIALqa1Pf1XPQy512sH6(L6q7gBRgqdJ9cqzztZJloxOvVxaaQ7b1184IZfsDDDuhxy9cBuKkYkMaetDAsDHhc111rDAN64kkq2GkSm8rBLQgbwerPrD)rDDDuhNQILxBlfQttQ7ljVzH4CH3KXEbOS8XhFtaF9UNFVE3SqCUWBkHwqCbzOelqz5BkWIikT71X3ZWVE3uGfruA3RBIWjl4SUzH4muIvGIAkaQ7xQ77nleNl8Mefgx6LJVNF46DZcX5cVzzv94MGT7WIWRgGBkWIikT71X3ZpF9UPalIO0Ux3eHtwWzDtSmWcqPiIc1Pf1PDQRqCUqdqWbcKTaoH6nj0oIPEf(MfIZfEtGGdeiBbCc1F89KKxVBkWIikT71nr4KfCw3KWpggg7fGYYM2QbK666OUXI8aQttQ7hHCZcX5cVjUcYMDKy547jjE9UPalIO0Ux3eHtwWzDtc)yyySxaklB8buNwuhHFmmQfGfSvTWVbQf04dOoTOoTtDe(XWOkQlMu7oSrpkB2gwkvGXhCZcX5cVzHrfuSaLLp(E(JR3nfyreL296MiCYcoRBs4hddJ9cqzzJpG666OU)Poc)yyARNikwUcmTvdi111rDOYkHMG8SqD)rDArDe(XWeGfucelqzzGPTAaPUUoQB4JrlwqkfwVy5uvOonPoubylNQYnleNl8MvQknlqz5JVNAZR3nfyreL296MiCYcoRBs4hddJ9cqzzJpG60I6i8JHrTaSGTQf(nqTGgFa1Pf1r4hdJQOUysT7Wg9OSzByPubgFWnleNl8MfgvqXcuw(47jjC9UzH4CH3mifmkH6TaLLVPalIO0UxhFp)gY17MfIZfEZXI8aPzRFk4KflHuQ3uGfruA3RJVNF)E9UzH4CH3mWJZbPjuVLiwa(McSiIs7ED898B4xVBwiox4nrlejqgxS0SJyPk3uGfruA3RJVNF)W17MfIZfEtI4Un7oSSIyfOOs6nfyreL2964753pF9UPalIO0Ux3eHtwWzDtc)yyWc6Duaa7yXiX4dOUUoQJWpggSGEhfaWowmsSO1dzbBaCHEtDAsDFd5MfIZfEtwrSEiX6Hn7yXi5475xsE9UPalIO0Ux3eHtwWzDtc)yyySxaklBARgqQtlQ7FQJWpgMaSGsGybkldm(aQtlQ7FQBSipG6(L6(8xQRRJ6i8JHrTaSGTQf(nqTGgFa19h111rD)tDJf5bu3VuhjdH60I6QFk4KfZyrEG0SJelgbwerPrDDDu3yrEa19l19dssD)rDArD)tDODJTvdOHXEbOSSblQvcbu3VuhjPUUoQBSipG6(L60MHqD)rDDDuhNQILxBlfQttQJKu3F3SqCUWBwyubflqz5JVNFjXR3nleNl8MawQgPwGYY3uGfruA3RJp(MEoJjt617E(96DZcX5cVjA9qwWwGYY3uGfruA3RJVNHF9UzH4CH3eiybMmP2MhW3uGfruA3RJVNF46DZcX5cVjiyXIffxF7McSiIs7ED898ZxVBwiox4nb7YkjuVvJIf8nfyreL29647jjVE3SqCUWBcwyISeXcW3uGfruA3RJVNK417MfIZfEtOWkc2cuw07BkWIikT71X3ZFC9UzH4CH3ePKAdjWY4c(j5ZyYKEtbwerPDVo(EQnVE3SqCUWBccsCYwGYIEFtbwerPDVo(EscxVBwiox4nHf7XcWQhxi5McSiIs7ED8XhFZqjyqUW7z4H8Lec5dF)Hj8q(8NVPgfgMq9GB(jRgSywAuhjsDfIZfsDXeWadv3ndW7iJYn)i1PTx43a1ccuYaQl03dzbt19rQtH5aG2QFF9jR4jmOvTpiv9XIZfIW1G7dsvuFQUpsD68rsPosimQl8q(scu3NsDF)QTcNKuDuDFK602ukOEbOTO6(i19PuxOR1OopNXKjL6cW5ItMuQJxQl0Pn(jAO6(i19Pu3NaqOoovflV2wkuhUyfbtDSsbPoUW6f2WPQy512sH64L6kiNOmOyH6eyJ62b1HwvIInuDuDFK6c9cnb5zPrDeYyXc1HwvIIPocrFcbgQl0HqsadOo4c)uLcRo8rQRqCUqa1TWiPgQUcX5cbMaSGwvIIjpIf4nvxH4CHatawqRkrXpi3V86vfixCUqQUcX5cbMaSGwvIIFqU)y3gv3hPUjScakltD4kBuhHFmKg1b4IbuhHmwSqDOvLOyQJq0Nqa1vWg1fGLpnyzoH6PUeqDTfkgQUcX5cbMaSGwvIIFqUpawbaLLTaUyavxH4CHatawqRkrXpi3py5CHuDfIZfcmbybTQef)GCFfpKfmWQw43uDFK60gXcQam1XkjG6ka1jfosk1vaQlybGKikuhVuxWYcKZkgjL60xjK6k4YkcM6qfGPUMhNq9uhRiu3i1RWgQUcX5cbMaSGwvIIFqUFB9erXYvqybybva2YPQq(BiuDfIZfcmbybTQef)GCFnwCSfkjHwSawybrcvxH4CHatawqRkrXpi3xVVWTSG2DyRFk4LvO6keNleycWcAvjk(b5(QI6Ij1UdB0JYMTHLsfq1vioxiWeGf0Qsu8dY9zSxaklhwawqfGTCQkK)Aizy5GCH4muIvGIAkGFdNQRqCUqGjalOvLO4hK7xPQ0SaLLdlhKleNHsScuutbO5hO6O6keNley8CgtMuYO1dzbBbklt1vioxiW45mMmPpi3hiybMmP2MhWuDfIZfcmEoJjt6dY9bblwSO46BuDfIZfcmEoJjt6dY9b7YkjuVvJIfmvxH4CHaJNZyYK(GCFWctKLiwaMQRqCUqGXZzmzsFqUpuyfbBbkl6nvxH4CHaJNZyYK(GCFKsQnKalJl4NKpJjtkvxH4CHaJNZyYK(GCFqqIt2cuw0BQUcX5cbgpNXKj9b5(WI9yby1JlKq1r19rQl0l0eKNLg1jHsWKsDCQkuhRiuxH4ftDjG6QqvzSiIIHQRqCUqazufJ2cX5cTXeWHblvHSNZyYKgwoi3ec)yyqfGtOEJpORRje(XW0sqGeJfruSQL(ez8bDDnHWpgMwccKySiIIvG4sVy8buDfIZfcEqUVhi2Kf1WGLQqwFffufJcgyj2fgwoit4hddJ9cqzzJpORt7CffiBqvmMq9wwrSaLLbgbwerP11XPQy512srZVHq19rQRhMuQJxQlMqH68buxH4muflnQJXj8TWaQtJKvOUEyVauwMQRqCUqWdY99aXMSOcclhKj8JHHXEbOSSXh01PDUIcKnOkgtOElRiwGYYaJalIO0664uvS8ABPOz4Hq1vioxi4b5(OkgTfIZfAJjGddwQczudq1vioxi4b5(OkgTfIZfAJjGddwQczahwoixiodLyfOOMcqZpq1vioxi4b5(OkgTfIZfAJjGddwQczgNO3aLLbHLdYfIZqjwbkQPa(nCQoQUcX5cbgudqwXdzbdSQf(Dy5GCti8JHrXdzbdSQf(TPTAa1s7e(XWWyVauw24dO6keNleyqnWdY9BRNikwUcclhKr7gBRgqdUcYMDKyXGf1kHan1JADDODJTvdObxbzZosSyWIALqGMODJTvdOPsvPzbklBWIALqqxhNQILxBlfndpeQUcX5cbgud8GCFcbde87eQpSCqMWpggg7fGYYgFGw)ZPQy512s5x0UX2Qb0qiyGGFNq9MMhxCUWhnpU4CHDD)ZfwVWgfPISIjaXAgEiDDANROazdQWYWhTvQAeyreL2F)11XPQy512srZVFGQRqCUqGb1api3NiUBZo8ysdlhKj8JHHXEbOSSXhO1)CQkwETTu(fTBSTAaneXDB2HhtQP5XfNl8rZJloxyx3)CH1lSrrQiRycqSMHhsxN25kkq2GkSm8rBLQgbwerP93FDDCQkwETTu08ljs1vioxiWGAGhK7xqKayCfTOkgdlhKj8JHHXEbOSSXhO1)CQkwETTu(fTBSTAanfejagxrlQIrtZJlox4JMhxCUWUU)5cRxyJIurwXeGyndpKUoTZvuGSbvyz4J2kvncSiIs7V)664uvS8ABPO5xsKQRqCUqGb1api3FKyHiUBlSCqMWpggg7fGYYgFGw)ZPQy512s5x0UX2Qb0msSqe3TzAECX5cF084IZf219pxy9cBuKkYkMaeRz4H01PDUIcKnOcldF0wPQrGfruA)9xxhNQILxBlfnjbQUcX5cbgud8GC)yQxHbwTbFtVQazQUcX5cbgud8GCFnwCSfkjHwSawybrsy5GmHFmmXCieXDBgaxO3A(zQUcX5cbgud8GCF9(c3YcA3HT(PGxwjSCqgTBSTAanm2laLLnyrTsiqZVKKQRqCUqGb1api3hNbbrXMqliOqsy5GmA3yB1aAySxaklBWIALqGM)GQRqCUqGb1api3xvuxmP2DyJEu2SnSuQaQUcX5cbgud8GC)GLZfgwoit4hddJ9cqzzdwkeRfHFmmeXDBrpGnyPqCxhHFmmm2laLLn(aTqLvcnb5zPRJtvXYRTLIMHtsQUcX5cbgud8GCFg7fGYYHLdYJf5b)sIHO1)e(XWeGfucelqzzGPTAa1cTBSTAan4kiB2rIfdwuRec0ItvXYRTLYVODJTvdOHXEbOSSP5XfNl0Q3laWJMhxCUWUoUW6f2OivKvmbiwZWdPRt7CffiBqfwg(OTsvJalIO0(RRJtvXYRTLIMFjjvhvxH4CHadGjlHwqCbzOelqzzQUcX5cbga)GCFIcJl9sy5GCH4muIvGIAkGF)s1vioxiWa4hK7xwvpUjy7oSi8QbGQRqCUqGbWpi3hi4abYwaNq9HLdYyzGfGsrefT0EH4CHgGGdeiBbCc1BsODet9kmvxH4CHadGFqUpUcYMDKyjSCqMWpggg7fGYYM2QbSRBSipqZFecvxH4CHadGFqUFHrfuSaLLdlhKj8JHHXEbOSSXhOfHFmmQfGfSvTWVbQf04d0s7e(XWOkQlMu7oSrpkB2gwkvGXhq1vioxiWa4hK7xPQ0SaLLdlhKj8JHHXEbOSSXh019pHFmmT1teflxbM2QbSRdvwj0eKNL)0IWpgMaSGsGybkldmTvdyx3WhJwSGukSEXYPQOjQaSLtvHQRqCUqGbWpi3VWOckwGYYHLdYe(XWWyVauw24d0IWpgg1cWc2Qw43a1cA8bAr4hdJQOUysT7Wg9OSzByPubgFavxH4CHadGFqUFqkyuc1Bbklt1vioxiWa4hK7pwKhinB9tbNSyjKsLQRqCUqGbWpi3pWJZbPjuVLiwaMQRqCUqGbWpi3hTqKazCXsZoILQq1vioxiWa4hK7te3Tz3HLveRafvsP6keNleya8dY9zfX6HeRh2SJfJKWYbzc)yyWc6Duaa7yXiX4d66i8JHblO3rbaSJfJelA9qwWgaxO3A(neQUcX5cbga)GC)cJkOybklhwoit4hddJ9cqzztB1aQ1)e(XWeGfucelqzzGXhO1)Jf5b)(5VDDe(XWOwawWw1c)gOwqJp4VUU)hlYd(LKHOv9tbNSyglYdKMDKyXiWIikTUUXI8GF)bj)tR)r7gBRgqdJ9cqzzdwuRec(LKDDJf5b)Qnd5VUoovflV2wkAsY)O6keNleya8dY9bSunsTaLLP6O6keNleyyCIEduwgqMOW4sVq1vioxiWW4e9gOSm4b5(sOfexqgkXcuwMQRqCUqGHXj6nqzzWdY9RuvAwGYYHLdYe(XWW4e92cuwgy8bAHkReAcYZIwe(XW0wpruSCfy8buDfIZfcmmorVbkldEqUpUcYMDKyjSCqMWpgggNO3wGYYaJpqR)RFk4KfZyrEG0SJelgbwerP11v)uWjlMeAzfXIviLvun4c((3VDD1pfCYIb4X6tOElqzzGrGfruADDCffiBamwk1ycfJalIO0(JQRqCUqGHXj6nqzzWdY9RuvAwGYYHLdYe(XWW4e92cuwgy8bA9pHFmmbybLaXcuwgyARgWUo0UX2Qb0uPQ0SaLLndFmAXcsPW6flNQIMfIZfAQuvAwGYYgubylNQsxhHFmmm2laLLn(G)O6keNleyyCIEduwg8GCFCfKn7iXsy5GmHFmmmorVTaLLbgFavxH4CHadJt0BGYYGhK7R6JCcuwoSCqMWpgggNO3wGYYatB1a21r4hdtawqjqSaLLbgFGwANWpggg7fGYYgFqx3yrEWV)ieQUcX5cbggNO3aLLbpi3FSipqA26NcozXsiLkvxH4CHadJt0BGYYGhK7h4X5G0eQ3selat1vioxiWW4e9gOSm4b5(OfIeiJlwA2rSufQUcX5cbggNO3aLLbpi3NiUBZUdlRiwbkQKs1vioxiWW4e9gOSm4b5(SIy9qI1dB2XIrsy5GmHFmmyb9okaGDSyKy8bDDe(XWGf07Oaa2XIrIfTEilydGl0Bn)gcvxH4CHadJt0BGYYGhK7hKcgLq9wGYYuDfIZfcmmorVbkldEqUFzv94MGT7WIWRgaQUcX5cbggNO3aLLbpi3hi4abYwaNq9HLdYyzGfGsrefT0EH4CHgGGdeiBbCc1BsODet9kmvxH4CHadJt0BGYYGhK7dyPAKAbklFtqGGUNHtYpF8X3b]] )
end