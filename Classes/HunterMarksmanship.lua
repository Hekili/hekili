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

        potion = "unbridled_fury",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20190810, [[du014aqiLepsjv2eIyukjDkLuwfcvKxPkAwkb3cHkTlQ8lvHHjqDmePLHq5zcKMMQu6Aus12uLIVrjfJtjeNtjvzDusjZdbDpkX(uLQdsjLAHikpujK0frOcgPsQQCseQqRujAMkPQ0nvsvXoridvjK4Pk1uvLCveQO2Rk)LIbtQdRyXQQhJ0KL4YeBwOplGrtsNw0QvcPEncmBjDBsSBGFl1Wf0XvsvvlhYZbnDuxNQ2UaX3PKmEeQ68iQwVsOMpLA)q9r6962LHLJiIfmPRxWlcPb7iwqdAWVDrUntEOC7WHsWeqUnyuKBV(micGkdaQMH3oCiV2t5EDBy7ru52RdRvzoeATE8iqYQ(VJ2kpGPIVoC2akAI8dyQqFC7VpRmXrW9VDzy5iIybt66f8IqAWoIf0Gg8BF7ThpR2OBVtLf1BRMLIaU)TlcKE71H1RpdIaOYaGQziwV(5bSGWlxhwRYCi0A94rGKv9FhTvEatfFD4Sbu0e5hWuH(aVCDyT12hWdzS2AwaRjwWKUEynXfRjwWwRGgmEjE56W6fv1beqGwl8Y1H1exS2AxkyTNZAYKJ1HOSrjtowZnwBTxuwFD4LRdRjUynXzOG1CQigUnLuWA0WQccRz1bG18GciSJtfXWTPKcwZnwpaoPz4WcwlGcw3rSM2k)HD3UMqgEVUnJskbq1MH3RJisVx3EOC2GB)heAci3waZVkLJSJpIi2962dLZgCBH4dRnmdIyGQnFBbm)QuoYo(ikO3RBlG5xLYr2TPOKfuo3(7JrhJskbgOAZqNpeRjbRPJriEH6zbRjbR)(y0vA)VkgEcD(WBpuoBWTNurkgOAZhFe9271TfW8Rs5i72uuYckNB)9XOJrjLaduTzOZhI1KG1RI1ZIfuYIl2upukMyIeNaMFvkyTTnwplwqjlUeyyvXGujNvvCObqaw)owtkwBBJ1ZIfuYId6rbsqaduTzOtaZVkfS22gR5Pka2bzKmk1eiobm)QuW61U9q5Sb3gnHzXetKC8rK1Vx3waZVkLJSBtrjlOCU93hJogLucmq1MHoFiwtcwVkw)9XOlej0ekgOAZqxPTcG122ynT7APTc4MurkgOAZUOVwniHQoOaIHtfbRjeRhkNnWnPIumq1MD0bYgoveS22gR)(y0XiVavB25dX61U9q5Sb3EsfPyGQnF8r0BUx3waZVkLJSBtrjlOCU93hJogLucmq1MHoF4ThkNn42OjmlMyIKJpISM71TfW8Rs5i72uuYckNB)9XOJrjLaduTzOR0wbWABBS(7JrxisOjumq1MHoFiwtcwVcw)9XOJrEbQ2SZhI122yDSPEiw)owBnbF7HYzdUTIVYjuT5JpIwK71ThkNn42XM6HsXmlwqjlMVmk3waZVkLJSJpIwV71ThkNn42HEugjpbbm)6a5BlG5xLYr2XhrKg8962dLZgCBAdOcGrdlftSokYTfW8Rs5i74Jisj9ED7HYzdU9V2DX0rdRkgbikKFBbm)QuoYo(iIuIDVUTaMFvkhz3MIswq5C7VpgDiHsqvGqtSruX5dXABBS(7JrhsOeufi0eBevm02dyb5G8qjaRjeRjn4BpuoBWTzvX4b)2dkMyJOYXhrKg071ThkNn42HPGOjiGbQ28TfW8Rs5i74JisF7962dLZgC7XO4rfbz6OHIARG3waZVkLJSJpIi163RBlG5xLYr2TPOKfuo3gjrKavNFvWAsW6vW6HYzdCqbfka2a5eeWLatSMbu5BpuoBWTHckuaSbYjiWXhrK(M71ThkNn42qwMc5gOAZ3waZVkLJSJp(2fjo(kFVoIi9EDBbm)QuoYUnfLSGY52f57JrhDGCcc48HyTTnwxKVpgDLegk168RIrzcKuNpeRTTX6I89XORKWqPwNFvmcanbeNp82dLZgCB6uRMHYzdm1eY3UMq2agf52EoRjt(Xhre7EDBbm)QuoYU9q5Sb3oWuf6uRccA(DdUnfLSGY52FFm6yKxGQn78HyTTnwVcwZtvaSJo1AccyyvXavBg6eW8RsbRTTXAoved3MskynHynPbFBWOi3oWuf6uRccA(Ddo(ikO3RBlG5xLYr2ThkNn42uYP1MrniPMFDG8TPOKfuo3EfS(7JrhJ8cuTzNpeRjbRxfRxbRfiuauX9RDxmD0WQIraIc5oLzr3iS22gRxbRfiuauX9RDxmD0WQIraIc5o0aiaRF3cwhuSEnS22gRlY3hJUFT7IPJgwvmcqui35dXABBSMtfXWTPKcwtiwB9Bdgf52uYP1MrniPMFDG8XhrV9EDBbm)QuoYUnfLSGY52FFm6yKxGQn78HyTTnwVcwZtvaSJo1AccyyvXavBg6eW8RsbRTTXAoved3MskynHynXc(2dLZgCBpumjlkWJpIS(962cy(vPCKD7HYzdUnDQvZq5SbMAc5BxtiBaJICBAbE8r0BUx3waZVkLJSBtrjlOCU9q5miIraIskqSMqSoO3EOC2GBtNA1muoBGPMq(21eYgWOi3gYhFezn3RBlG5xLYr2TPOKfuo3EOCgeXiarjfiw)owtSBpuoBWTPtTAgkNnWutiF7AczdyuKBZOKsauTz4XhF7qKqBL)W3RJisVx3EOC2GBh2C2GBlG5xLYr2Xhre7ED7HYzdUTQhWccAugeb3waZVkLJSJpIc6962cy(vPCKD7qKqhiB4urUnPbF7HYzdUDP9)Qy4j84JO3EVU9q5Sb32QgvlbrsGbjWgmaQCBbm)QuoYo(iY63RBpuoBWTd4hujhGPJMzXcQz1BlG5xLYr2XhrV5ED7HYzdUTIO0iYnD0u90SykizuG3waZVkLJSJpISM71TfW8Rs5i72GrrU9SyO6GgOj2a20rtyBLGU9q5Sb3EwmuDqd0eBaB6OjSTsqhFeTi3RBlG5xLYr2TdrcDGSHtf52K6S(ThkNn42mYlq1MVnfLSGY52dLZGigbikPaX63XAID8r06DVUTaMFvkhz3MIswq5C7HYzqeJaeLuGynHyDqV9q5Sb3EsfPyGQnF8X3MwG3RJisVx3waZVkLJSBtrjlOCUDr((y0P6bSGGgLbrGR0wbWAsW6vW6VpgDmYlq1MD(WBpuoBWTv9awqqJYGi44JiIDVUTaMFvkhz3MIswq5CBA31sBfWHMWSyIjsCirzsaeRjeRdqlyTTnwt7UwARao0eMftmrIdjktcGynHynT7APTc4MurkgOAZoKOmjaI122ynNkIHBtjfSMqSMybF7HYzdUDP9)Qy4j84JOGEVUTaMFvkhz3MIswq5C7VpgDmYlq1MD(qSMeSEvSMtfXWTPKcw)owt7UwARaUVGGcIGeeWv8OHZgG1pX6IhnC2aS22gRxfR5bfqyNQmvw1fszSMqSMybJ122y9kynpvbWo6GKOVAMuXjG5xLcwVgwVgwBBJ1CQigUnLuWAcXAsd6ThkNn42FbbfebjiWXhrV9EDBbm)QuoYUnfLSGY52FFm6yKxGQn78Hynjy9QynNkIHBtjfS(DSM2DT0wbC)A3ft0Ji3v8OHZgG1pX6IhnC2aS22gRxfR5bfqyNQmvw1fszSMqSMybJ122y9kynpvbWo6GKOVAMuXjG5xLcwVgwVgwBBJ1CQigUnLuWAcXAsFZThkNn42)A3ft0Ji)4JiRFVUTaMFvkhz3MIswq5C7VpgDmYlq1MD(qSMeSEvSMtfXWTPKcw)owt7UwARaUbqfiJMQHo1QR4rdNnaRFI1fpA4SbyTTnwVkwZdkGWovzQSQlKYynHynXcgRTTX6vWAEQcGD0bjrF1mPItaZVkfSEnSEnS22gR5urmCBkPG1eI1K(MBpuoBWThavGmAQg6uRhFe9M71TfW8Rs5i72uuYckNB)9XOJrEbQ2SZhI1KG1RI1CQigUnLuW63XAA31sBfWftK8RDxCfpA4Sby9tSU4rdNnaRTTX6vXAEqbe2PktLvDHugRjeRjwWyTTnwVcwZtvaSJoij6RMjvCcy(vPG1RH1RH122ynNkIHBtjfSMqSE9U9q5Sb3oMi5x7UC8rK1CVU9q5Sb3UMbuzOzr7lbueaFBbm)QuoYo(iArUx3waZVkLJSBtrjlOCU93hJUAgLFT7IdYdLaSMqS(Tynjy9ky93hJog5fOAZoF4ThkNn42w1OAjiscmib2GbqLJpIwV71TfW8Rs5i72uuYckNBVkwthJq8c1ZcwBBJ1CQigUnLuW63XAA31sBfWfWpOsoathnZIfuZQUIhnC2aS(jwx8OHZgG1RH1KG1RI1FFm6yKxGQn78HyTTnwt7UwARaog5fOAZoKOmjaI1eI1K(gSEnS22gR5urmCBkPG1eI1bL0BpuoBWTd4hujhGPJMzXcQz1JpIin471TfW8Rs5i72uuYckNBt7UwARaog5fOAZoKOmjaI1eI1wZThkNn42OmmSkMeyGHdvo(iIusVx3waZVkLJSBtrjlOCU9ky93hJog5fOAZoF4ThkNn42kIsJi30rt1tZIPGKrbE8rePe7EDBbm)QuoYUnfLSGY52FFm6yKxGQn7qYqzSMeS(7Jr3V2DP6HSdjdLXABBS(7JrhJ8cuTzNpeRjbRPJriEH6zbRTTX6vXAAdGEL5xfxyZzdmD04bFuwQsXe9iYXAsWAoved3MskynHy9BifRTTXAoved3MskynHynXEdwV2ThkNn42HnNn44Jisd6962cy(vPCKDBkkzbLZTJn1dX63X63emwtcwVkw)9XOlej0ekgOAZqxPTcG1KG10URL2kGdnHzXetK4qIYKaiwtcwZPIy42usbRFhRPDxlTvahJ8cuTzxXJgoBGjGxGqS(jwx8OHZgG122ynpOac7uLPYQUqkJ1eI1elyS22gRxbR5Pka2rhKe9vZKkobm)QuW61WABBSMtfXWTPKcwtiwtQ1V9q5Sb3MrEbQ28XhFBiFVoIi9ED7HYzdUTq8H1gMbrmq1MVTaMFvkhzhFerS71TfW8Rs5i72uuYckNBpuodIyeGOKceRFhRj92dLZgC7)Gqta54JOGEVU9q5Sb3EmkEurqMoAOO2k4TfW8Rs5i74JO3EVUTaMFvkhz3MIswq5CBKercuD(vbRjbRxbRhkNnWbfuOaydKtqaxcmXAgqLV9q5Sb3gkOqbWgiNGahFez971TfW8Rs5i72uuYckNB)9XOJrEbQ2SR0wbWABBSo2upeRjeRTMGV9q5Sb3gnHzXetKC8r0BUx3waZVkLJSBtrjlOCU93hJog5fOAZoFiwtcwVkw)9XOZdeekbbmbjHzdCqEOeG1VJ1VfRTTX6vW6zXckzX5bccLGaMGKWSbobm)QuW61WABBSMtfXWTPKcwtiwtkP3EOC2GB)RDxmD0WQIraIc5hFezn3RBlG5xLYr2TPOKfuo3EfS(7JrhJ8cuTzNpeRTTXAoved3MskynHyT1V9q5Sb3o2upukMzXckzX8Lr54JOf5EDBbm)QuoYUnfLSGY52FFm6yKxGQn78Hynjy93hJoLbYcYOmicGkdW5dXAsW6vW6VpgDkIsJi30rt1tZIPGKrb68H3EOC2GBpi6aeduT5JpIwV71TfW8Rs5i72uuYckNB)9XOJrEbQ2SZhI122y9Qy93hJUs7)vXWtOR0wbWABBSMogH4fQNfSEnSMeS(7JrxisOjumq1MHUsBfaRTTX6OVwniHQoOaIHtfbRjeRPdKnCQiynjynT7APTc4yKxGQn7qIYKa4ThkNn42tQifduT5JpIin471TfW8Rs5i72uuYckNB)9XOJrEbQ2SZhI1KG1FFm6ugiliJYGiaQmaNpeRjbR)(y0PiknICthnvpnlMcsgfOZhE7HYzdU9GOdqmq1Mp(iIusVx3EOC2GBhMcIMGagOAZ3waZVkLJSJpIiLy3RBlG5xLYr2TPOKfuo3EfS(7JrhJ8cuTzNpeRTTXAoved3MskynHy9IC7HYzdUDOhLrYtqaZVoq(4Jisd6962cy(vPCKDBkkzbLZTJn1dX6NyDSPEOdjbeawtCcRdqlynHyDSPEOtziESMeS(7JrhJ8cuTzxPTcG1KG1RI1RG1LMD0gqfaJgwkMyDueZ3JaoKOmjaI1KG1RG1dLZg4OnGkagnSumX6OiUeyI1mGkJ1RH122yD0xRgKqvhuaXWPIG1eI1bOfS22gR5bfqyhNkIHBtjfSMqS263EOC2GBtBavamAyPyI1rro(iI03EVUTaMFvkhz3MIswq5C7VpgDiHsqvGqtSruX5dXABBS(7JrhsOeufi0eBevm02dyb5G8qjaRjeRjnyS22gR5urmCBkPG1eI1w)2dLZgCBwvmEWV9GIj2iQC8rePw)EDBbm)QuoYUnfLSGY52FFm6yKxGQn7kTvaSMeSEvS(7JrxisOjumq1MHoFiwtcwVkwhBQhI1VJ1VLuS22gR)(y0PmqwqgLbrauzaoFiwVgwBBJ1RI1XM6Hy97yT1dgRjbRNflOKfxSPEOumXejobm)QuWABBSo2upeRFhRTgRJ1RH1KG1RI10URL2kGJrEbQ2SdjktcGy97yT1XABBSo2upeRFhRxKGX61WABBSMtfXWTPKcwtiwBDSETBpuoBWTheDaIbQ28XhrK(M71ThkNn42qwMc5gOAZ3waZVkLJSJp(2EoRjt(96iI071ThkNn4202dybzGQnFBbm)QuoYo(iIy3RBpuoBWTHcsajtUP4H8TfW8Rs5i74JOGEVU9q5Sb3gg2iXqRTVCBbm)QuoYo(i6T3RBpuoBWTHDZQjiGXQHf0TfW8Rs5i74JiRFVU9q5Sb3g2GKA(1bY3waZVkLJSJpIEZ962dLZgCBGWQcYavBkb3waZVkLJSJpISM71ThkNn42u1CrNqdJgW6VpRjt(TfW8Rs5i74JOf5ED7HYzdUnmmrjBGQnLGBlG5xLYr2XhrR3962dLZgCBWWEKanbqdvUTaMFvkhzhF8X3oiccMn4iIybt66f8IeCqVTvdcKGaWBtCujSrSuW63G1dLZgG11eYqhE5TdrDmRYTxhwV(micGkdaQMHy96NhWccVCDyTkZHqR1Jhbsw1)D0w5bmv81HZgqrtKFatf6d8Y1H1wBFapKXARzbSMybt66H1exSMybBTcAW4L4LRdRxuvhqabATWlxhwtCXARDPG1EoRjtowhIYgLm5yn3yT1Erz91HxUoSM4I1eNHcwZPIy42usbRrdRkiSMvhawZdkGWooved3Mskyn3y9a4KMHdlyTakyDhXAAR8h2HxIxUoSM4aXluplfS(lXgjynTv(dJ1FjqcGoS2AtPsidXAqdiUQdsj6Ry9q5SbqSUbvYD4LRdRhkNna6crcTv(dBjwhib4LRdRhkNna6crcTv(d)0YJXhqra8WzdWlxhwpuoBa0fIeAR8h(PLhXUl4LRdR3GjeQ2mwJMSG1FFmkfSgYddX6VeBKG10w5pmw)LajaI1dOG1HiH4g2mNGayDcX6sdehE56W6HYzdGUqKqBL)WpT8acMqOAZgipmeVCOC2aOlej0w5p8tlpcBoBaE5q5SbqxisOTYF4NwEO6bSGGgLbraE56W6ffKqhiJ1SAcX6bI1YGQKJ1deRdBim)vbR5gRdBwaCo1k5yDGjby9aAwvqynDGmwx8OeeaRzvbRJzav2HxouoBa0fIeAR8h(PLhL2)RIHNWfcrcDGSHtfXcPbJxouoBa0fIeAR8h(PLhw1OAjiscmib2Gbqf8YHYzdGUqKqBL)WpT8iGFqLCaMoAMflOMvXlhkNna6crcTv(d)0YdfrPrKB6OP6PzXuqYOaXlhkNna6crcTv(d)0YdpumjlklagfXYSyO6GgOj2a20rtyBLGWlhkNna6crcTv(d)0Ydg5fOAZleIe6azdNkIfsDwFHmAzOCgeXiarjf47edVCOC2aOlej0w5p8tlpMurkgOAZlKrldLZGigbikPajmO4L4LdLZgaDEoRjtUfA7bSGmq1MXlhkNna68CwtM8NwEafKasMCtXdz8YHYzdGopN1Kj)PLhWWgjgAT9f8YHYzdGopN1Kj)PLhWUz1eeWy1WccVCOC2aOZZznzYFA5bSbj18RdKXlhkNna68CwtM8NwEaewvqgOAtjaVCOC2aOZZznzYFA5bvnx0j0WObS(7ZAYKJxouoBa055SMm5pT8agMOKnq1MsaE5q5SbqNNZAYK)0YdWWEKanbqdvWlXlxhwtCG4fQNLcwlbrqKJ1CQiynRky9q5gH1jeRNGmzD(vXHxouoBa0cDQvZq5SbMAc5faJIyXZznzYxiJwkY3hJo6a5eeW5dTTlY3hJUscdLAD(vXOmbsQZhABxKVpgDLegk168RIraOjG48H4LdLZgaFA5HhkMKfLfaJIyjWuf6uRccA(DdwiJw((y0XiVavB25dTTxHNQayhDQ1eeWWQIbQ2m0jG5xLITnNkIHBtjfcjny8YHYzdGpT8WdftYIYcGrrSqjNwBg1GKA(1bYlKrlR89XOJrEbQ2SZhsYQRiqOaOI7x7Uy6OHvfJaefYDkZIUr22RiqOaOI7x7Uy6OHvfJaefYDObqW7wc6A22f57Jr3V2DX0rdRkgbikK78H22CQigUnLui064LRdRFHihR5gRRjqWAFiwpuodYWsbRzuciqyiwBvYQy9lKxGQnJxouoBa8PLhEOyswuGlKrlFFm6yKxGQn78H22RWtvaSJo1AccyyvXavBg6eW8RsX2MtfXWTPKcHely8YHYzdGpT8Go1QzOC2atnH8cGrrSqlq8YHYzdGpT8Go1QzOC2atnH8cGrrSa5fYOLHYzqeJaeLuGegu8YHYzdGpT8Go1QzOC2atnH8cGrrSWOKsauTz4cz0Yq5miIraIskW3jgEjE5q5SbqhTaTO6bSGGgLbrWcz0sr((y0P6bSGGgLbrGR0wbizLVpgDmYlq1MD(q8YHYzdGoAb(0YJs7)vXWt4cz0cT7APTc4qtywmXejoKOmjasyaAX2M2DT0wbCOjmlMyIehsuMeajK2DT0wbCtQifduTzhsuMeaTT5urmCBkPqiXcgVCOC2aOJwGpT84liOGiibbwiJw((y0XiVavB25djzvoved3MskVt7UwARaUVGGcIGeeWv8OHZg8S4rdNnW2EvEqbe2PktLvDHuMqIfST9k8ufa7OdsI(QzsfNaMFvkRTMTnNkIHBtjfcjnO4LdLZgaD0c8PLh)A3ft0JiFHmA57JrhJ8cuTzNpKKv5urmCBkP8oT7APTc4(1UlMOhrUR4rdNn4zXJgoBGT9Q8GciStvMkR6cPmHelyB7v4Pka2rhKe9vZKkobm)QuwBnBBoved3Mskes6BWlhkNna6Of4tlpgavGmAQg6uRlKrlFFm6yKxGQn78HKSkNkIHBtjL3PDxlTva3aOcKrt1qNA1v8OHZg8S4rdNnW2EvEqbe2PktLvDHuMqIfST9k8ufa7OdsI(QzsfNaMFvkRTMTnNkIHBtjfcj9n4LdLZgaD0c8PLhXej)A3LfYOLVpgDmYlq1MD(qswLtfXWTPKY70URL2kGlMi5x7U4kE0WzdEw8OHZgyBVkpOac7uLPYQUqktiXc22EfEQcGD0bjrF1mPItaZVkL1wZ2MtfXWTPKcHRhE5q5SbqhTaFA5rndOYqZI2xcOiagVCOC2aOJwGpT8WQgvlbrsGbjWgmaQSqgT89XORMr5x7U4G8qjGW3sYkFFm6yKxGQn78H4LdLZgaD0c8PLhb8dQKdW0rZSyb1S6cz0YQ0XieVq9SyBZPIy42us5DA31sBfWfWpOsoathnZIfuZQUIhnC2GNfpA4SbRrYQFFm6yKxGQn78H220URL2kGJrEbQ2SdjktcGes6BwZ2MtfXWTPKcHbLu8YHYzdGoAb(0YduggwftcmWWHklKrl0URL2kGJrEbQ2SdjktcGeAn4LdLZgaD0c8PLhkIsJi30rt1tZIPGKrbUqgTSY3hJog5fOAZoFiE5q5SbqhTaFA5ryZzdwiJw((y0XiVavB2HKHYK89XO7x7Uu9q2HKHY22FFm6yKxGQn78HKqhJq8c1ZIT9Q0ga9kZVkUWMZgy6OXd(OSuLIj6rKtcNkIHBtjfcFdP22CQigUnLuiKyVzn8YHYzdGoAb(0Ydg5fOAZlKrlXM6HV)MGjz1VpgDHiHMqXavBg6kTvasODxlTvahAcZIjMiXHeLjbqs4urmCBkP8oT7APTc4yKxGQn7kE0Wzdmb8ce(S4rdNnW2MhuaHDQYuzvxiLjKybBBVcpvbWo6GKOVAMuXjG5xLYA22CQigUnLuiKuRJxIxouoBa0bzlcXhwBygeXavBgVCOC2aOdYpT84pi0eqwiJwgkNbrmcqusb(oP4LdLZgaDq(PLhJrXJkcY0rdf1wbXlhkNna6G8tlpGckuaSbYjiWcz0csIibQo)QqYkdLZg4GckuaSbYjiGlbMyndOY4LdLZgaDq(PLhOjmlMyIKfYOLVpgDmYlq1MDL2kGTDSPEiHwtW4LRdRZOLVpgDmYlq1MD(qsw97JrNhiiuccycscZg4G8qj493ABVYSybLS48abHsqatqsy2aNaMFvkRzBZdkGWooved3MskeskP4LdLZgaDq(PLh)A3fthnSQyeGOq(cz0Y3hJog5fOAZoFijR(9XOZdeekbbmbjHzdCqEOe8(BTTxzwSGswCEGGqjiGjijmBGtaZVkL1ST5urmCBkPqiPKIxouoBa0b5NwEeBQhkfZSybLSy(YOSqgTSY3hJog5fOAZoFOTnNkIHBtjfcToE5q5SbqhKFA5XGOdqmq1MxiJw((y0XiVavB25dj57JrNYazbzugebqLb48HKSY3hJofrPrKB6OP6PzXuqYOaD(q8YHYzdGoi)0YJjvKIbQ28cz0Y3hJog5fOAZoFOT9QFFm6kT)xfdpHUsBfW2MogH4fQNL1i57JrxisOjumq1MHUsBfW2o6RvdsOQdkGy4uriKoq2WPIqcT7APTc4yKxGQn7qIYKaiE5q5SbqhKFA5XGOdqmq1MxiJw((y0XiVavB25dj57JrNYazbzugebqLb48HK89XOtruAe5MoAQEAwmfKmkqNpeVCOC2aOdYpT8imfenbbmq1MXlhkNna6G8tlpc9OmsEccy(1bYlKrlR89XOJrEbQ2SZhABZPIy42usHWfbVCOC2aOdYpT8G2aQay0WsXeRJISqgTeBQh(m2up0HKacG4uaAHWyt9qNYq8K89XOJrEbQ2SR0wbiz1vkn7OnGkagnSumX6OiMVhbCirzsaKKvgkNnWrBavamAyPyI1rrCjWeRzavEnB7OVwniHQoOaIHtfHWa0ITnpOac74urmCBkPqO1XlhkNna6G8tlpyvX4b)2dkMyJOYcz0Y3hJoKqjOkqOj2iQ48H22FFm6qcLGQaHMyJOIH2EalihKhkbesAW22CQigUnLui064LdLZgaDq(PLhdIoaXavBEHmA57JrhJ8cuTzxPTcqYQFFm6crcnHIbQ2m05djz1yt9W3FlP22FFm6ugiliJYGiaQmaNpCnB7vJn1dF36btYSybLS4In1dLIjMiXjG5xLITDSPE47wJ1xJKvPDxlTvahJ8cuTzhsuMeaF3622XM6HVVibVMTnNkIHBtjfcT(A4LdLZgaDq(PLhqwMc5gOAZ4L4LdLZgaDmkPeavBgA5pi0eqWlhkNna6yusjaQ2m8PLhcXhwBygeXavBgVCOC2aOJrjLaOAZWNwEmPIumq1MxiJw((y0XOKsGbQ2m05djHogH4fQNfs((y0vA)VkgEcD(q8YHYzdGogLucGQndFA5bAcZIjMizHmA57JrhJskbgOAZqNpKKvNflOKfxSPEOumXejobm)QuSTNflOKfxcmSQyqQKZQko0ai4DsTTNflOKfh0JcKGagOAZqNaMFvk228ufa7GmsgLAceNaMFvkRHxouoBa0XOKsauTz4tlpMurkgOAZlKrlFFm6yusjWavBg68HKS63hJUqKqtOyGQndDL2kGTnT7APTc4MurkgOAZUOVwniHQoOaIHtfHWHYzdCtQifduTzhDGSHtfX2(7JrhJ8cuTzNpCn8YHYzdGogLucGQndFA5bAcZIjMizHmA57JrhJskbgOAZqNpeVCOC2aOJrjLaOAZWNwEO4RCcvBEHmA57JrhJskbgOAZqxPTcyB)9XOlej0ekgOAZqNpKKv((y0XiVavB25dTTJn1dF3AcgVCOC2aOJrjLaOAZWNwEeBQhkfZSybLSy(YOGxouoBa0XOKsauTz4tlpc9OmsEccy(1bY4LdLZgaDmkPeavBg(0YdAdOcGrdlftSokcE5q5SbqhJskbq1MHpT84x7Uy6OHvfJaefYXlhkNna6yusjaQ2m8PLhSQy8GF7bftSruzHmA57JrhsOeufi0eBevC(qB7VpgDiHsqvGqtSruXqBpGfKdYdLacjny8YHYzdGogLucGQndFA5rykiAccyGQnJxouoBa0XOKsauTz4tlpgJIhveKPJgkQTcIxouoBa0XOKsauTz4tlpGckuaSbYjiWcz0csIibQo)QqYkdLZg4GckuaSbYjiGlbMyndOY4LdLZgaDmkPeavBg(0YdiltHCduT5Bddf6reXS(Bp(47a]] )


end