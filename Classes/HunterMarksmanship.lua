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


    spec:RegisterPack( "Marksmanship", 20190728, [[duuh4aqijfpsskBcQ0OKu5usQAvqvb9kvfZssYTGQI2fv(LQWWeihtvvltsPNPkkttvuDnbkBtveFtvLACQQKZPkswNavmpvLUhfSpvvCqvrkleQYdfOsDrOQqnsOQaNeQkKvkjMPavv3uGkzNqfdvGQYtvQPQk5QQIuzVQ8xknysDyflgkpgPjlXLj2SqFwaJMKoTOvlqvETQuZwj3Me7g43snCbDCvrQA5iEoOPJ66u12HQQVtHA8qvPZtHSEjPA(u0(H89)ED7YWYHtTb9)Pc631(l3)F98GEwT3MnkuUD4qFpbKBdgf52bxd5nuzaq1m82HJrREk3RBdBpHk3UAiTkZHWGZJhbsw1J5OTYdyQ4xdNnGsMi)aMk0h3gZNlgFe4WUDzy5WP2G()ub97A)L7)VEEq1(RBpEwTj3ENkb33wnlfbCy3Uiq6TRgshCnK3qLbavZqKgFGhWcbvPAiTkZHWGZJhbsw1J5OTYdyQ4xdNnGsMi)aMk0hOkvdPR4xgH01(RQq6Ad6)tH04tK()VcoppiufuLQH0b3QdiGadoOkvdPXNi9tRuqApNRKncPdjzts2iKMBK(Pf8f87qvQgsJpr6NoOG0CQiwUTLuqAYWQcbPz1bG08qciSJtfXYTTKcsZnspaoPz4WcslGcs3rKM2kyd7U9kHm8EDBMK03q1MH3RdN)3RBpuoBWTXgczci3wad2skhEhF4u7962dLZgCBbFdxnmXVyHQnFBbmylPC4D8HZZUx3wad2skhE3Msswi5CBmFm6yssFBHQndD(qKgxKMowbFfQNfKgxKgZhJUs7XwILNqNp82dLZgC7jvKIfQ28Xhop)EDBbmylPC4DBkjzHKZTX8XOJjj9TfQ2m05drACr66q6P6cjzXfBQhkfBmjItad2skiTPjspvxijlUeyzvXsunIvvCKb8gP)bP)J0MMi9uDHKS4GEsGeeWcvBg6eWGTKcsBAI08Sea7GmrgLvceNagSLuq66V9q5Sb3MmHzXgtIC8HtWUx3wad2skhE3Msswi5CBmFm6yssFBHQndD(qKgxKUoKgZhJUqIqtOyHQndDL2yasBAI00UxL2yGBsfPyHQn7I(1YseQ6qciwoveK(lspuoBGBsfPyHQn7OdKTCQiiTPjsJ5Jrht8cuTzNpePR)2dLZgC7jvKIfQ28Xhop5EDBbmylPC4DBkjzHKZTX8XOJjj9TfQ2m05dV9q5Sb3MmHzXgtIC8HZVVx3wad2skhE3Msswi5CBmFm6yssFBHQndDL2yasBAI0y(y0fseAcfluTzOZhI04I01G0y(y0XeVavB25drAttKo2upeP)bP)Dq3EOC2GBR4xCcvB(4dNFDVU9q5Sb3o2upuk2P6cjzXIjJYTfWGTKYH3Xhop1962dLZgC7qpjJgLGawS1a5BlGbBjLdVJpC(h0962dLZgCBAdOcGjdlfBCnkYTfWGTKYH3Xho))FVU9q5Sb3gB1DX2rlRkwbikgDBbmylPC4D8HZ)AVx3wad2skhE3Msswi5CBmFm6ic99sGqBSjuX5drAttKgZhJoIqFVei0gBcvS02dyH4G8qFJ0Fr6)bD7HYzdUnRkwpaR9GIn2eQC8HZ)NDVU9q5Sb3omfcnbbSq1MVTagSLuo8o(W5)ZVx3EOC2GBpwfpPieBhTusBm82cyWws5W74dN)b7EDBbmylPC4DBkjzHKZTjsKiq1bBjinUiDni9q5SboOqcfaBHCcc4sGnUYaQ8ThkNn42qHeka2c5ee44dN)p5ED7HYzdUnKLPyKfQ28TfWGTKYH3XhF7Ieh)IVxho)Vx3wad2skhE3Msswi5C7IG5JrhDGCcc48HiTPjsxemFm6kjmuwRbBjwLjqsD(qK20ePlcMpgDLegkR1GTeRaitaX5dV9q5Sb3MoRLDOC2a7kH8TxjKTGrrUTNZvYgD8HtT3RBlGbBjLdVBpuoBWTdmlHoRLqGwSUb3Msswi5CBmFm6yIxGQn78HiTPjsxdsZZsaSJoRvccyzvXcvBg6eWGTKcsBAI0CQiwUTLuq6Vi9)GUnyuKBhywcDwlHaTyDdo(W5z3RBlGbBjLdVBpuoBWTdB6BHHz1LIL2kHEE4Sb2IG)Kk3Msswi5C7AqAmFm6yIxGQn78HinUiDDiDniTaHcGkoSv3fBhTSQyfGOyKtzcEnbPnnr6AqAbcfavCyRUl2oAzvXkarXihzaVr6FmG0pdPRhPnnr6IG5Jrh2Q7ITJwwvScqumY5drAttKMtfXYTTKcs)fPd2TbJIC7WM(wyywDPyPTsONhoBGTi4pPYXhop)EDBbmylPC4DBkjzHKZTX8XOJjEbQ2SZhI0MMiDninplbWo6SwjiGLvfluTzOtad2skiTPjsZPIy52wsbP)I01g0ThkNn42EOytwuGhF4eS71TfWGTKYH3ThkNn420zTSdLZgyxjKV9kHSfmkYTPf4Xhop5EDBbmylPC4DBkjzHKZThkN4xScqusbI0Fr6ND7HYzdUnDwl7q5Sb2vc5BVsiBbJICBiF8HZVVx3wad2skhE3Msswi5C7HYj(fRaeLuGi9piDT3EOC2GBtN1YouoBGDLq(2ReYwWOi3Mjj9nuTz4XhF7qIqBfSHVxho)Vx3EOC2GBh2C2GBlGbBjLdVJpCQ9ED7HYzdUTQhWcbAvgY7BlGbBjLdVJpCE2962cyWws5W72HeHoq2YPIC7)bD7HYzdUDP9ylXYt4Xhop)ED7HYzdUTXnzvWVKalrGnyau52cyWws5W74dNGDVU9q5Sb3oGFiLCa2oANQlKMvVTagSLuo8o(W5j3RBpuoBWTveLMyKTJ2LNMfBHiJc82cyWws5W74dNFFVUTagSLuo8UDirOdKTCQi3(Vly3EOC2GBZeVavB(2usYcjNBpuoXVyfGOKceP)bPR94dNFDVUTagSLuo8UnLKSqY52dLt8lwbikPar6Vi9ZU9q5Sb3EsfPyHQnF8X3MwG3RdN)3RBlGbBjLdVBtjjlKCUDrW8XOt1dyHaTkd5TR0gdqACr6AqAmFm6yIxGQn78H3EOC2GBR6bSqGwLH8(4dNAVx3wad2skhE3Msswi5CBA3RsBmWrMWSyJjrCerzsaeP)I0bOfK20ePPDVkTXahzcZInMeXreLjbqK(lst7EvAJbUjvKIfQ2SJiktcGiTPjsZPIy52wsbP)I01g0ThkNn42L2JTelpHhF48S71TfWGTKYH3TPKKfso3gZhJoM4fOAZoFisJlsxhsZPIy52wsbP)bPPDVkTXahMqGc5Dcc4kEYWzdq6piDXtgoBasBAI01H08qciStvMfR6cPms)fPRniK20ePRbP5zja2rhIe9l7KkobmylPG01J01J0MMinNkILBBjfK(ls))z3EOC2GBJjeOqENGahF48871TfWGTKYH3TPKKfso3gZhJoM4fOAZoFisJlsxhsZPIy52wsbP)bPPDVkTXah2Q7In6jg5kEYWzdq6piDXtgoBasBAI01H08qciStvMfR6cPms)fPRniK20ePRbP5zja2rhIe9l7KkobmylPG01J01J0MMinNkILBBjfK(ls))j3EOC2GBJT6UyJEIrhF4eS71TfWGTKYH3TPKKfso3gZhJoM4fOAZoFisJlsxhsZPIy52wsbP)bPPDVkTXa3aOcKjZYsN1Yv8KHZgG0Fq6INmC2aK20ePRdP5HeqyNQmlw1fszK(lsxBqiTPjsxdsZZsaSJoej6x2jvCcyWwsbPRhPRhPnnrAovel32ski9xK()tU9q5Sb3EaubYKzzPZAD8HZtUx3wad2skhE3Msswi5CBmFm6yIxGQn78HinUiDDinNkILBBjfK(hKM29Q0gdCXKiyRUlUINmC2aK(dsx8KHZgG0MMiDDinpKac7uLzXQUqkJ0Fr6AdcPnnr6AqAEwcGD0Hir)YoPItad2skiD9iD9iTPjsZPIy52wsbP)I0p1ThkNn42XKiyRUlhF48771ThkNn42RmGkdTbpFjGIa4BlGbBjLdVJpC(1962cyWws5W72usYcjNBJ5Jr3kJc2Q7IdYd9ns)fPFosJlsxdsJ5Jrht8cuTzNp82dLZgCBJBYQGFjbwIaBWaOYXhop1962cyWws5W72usYcjNBxhsthRGVc1ZcsBAI0CQiwUTLuq6Fq6A)hesxpsJlsxhsJ5Jrht8cuTzNpePnnrAA3RsBmWXeVavB2reLjbqK(ls))jiD9iTPjsZPIy52wsbP)I0plOBpuoBWTd4hsjhGTJ2P6cPz1JpC(h0962cyWws5W72usYcjNBt7EvAJboM4fOAZoIOmjaI0Fr6FF7HYzdUnjddxInbwy4qLJpC())EDBbmylPC4DBkjzHKZTRbPX8XOJjEbQ2SZhE7HYzdUTIO0eJSD0U80SylezuGhF48V271TfWGTKYH3TPKKfso3gZhJoM4fOAZoImugPXfPX8XOdB1Dz5HSJidLrAttKgZhJoM4fOAZoFisJlsthRGVc1ZcsBAI01H00ga9kd2sCHnNnW2rRhGrYYsk2ONyesJlsZPIy52wsbP)I0p5psBAI0CQiwUTLuq6ViDTpbPR)2dLZgC7WMZgC8HZ)NDVUTagSLuo8UnLKSqY52XM6Hi9pi9tccPXfPRdPX8XOlKi0ekwOAZqxPngG04I00UxL2yGJmHzXgtI4iIYKaisJlsZPIy52wsbP)bPPDVkTXaht8cuTzxXtgoBGnGxGqK(dsx8KHZgG0MMinpKac7uLzXQUqkJ0Fr6AdcPnnr6AqAEwcGD0Hir)YoPItad2skiD9iTPjsZPIy52wsbP)I0)d2ThkNn42mXlq1Mp(4Bd571HZ)71ThkNn42c(gUAyIFXcvB(2cyWws5W74dNAVx3wad2skhE3Msswi5C7HYj(fRaeLuGi9pi9)BpuoBWTXgczcihF48S71ThkNn42JvXtkcX2rlL0gdVTagSLuo8o(W553RBlGbBjLdVBtjjlKCUnrIebQoylbPXfPRbPhkNnWbfsOaylKtqaxcSXvgqLV9q5Sb3gkKqbWwiNGahF4eS71TfWGTKYH3TPKKfso3gZhJoM4fOAZUsBmaPnnr6yt9qK(ls)7GU9q5Sb3MmHzXgtIC8HZtUx3wad2skhE3Msswi5CBmFm6yIxGQn78HinUiDDinMpgDEGqijiGf)jmBGdYd9ns)ds)CK20ePRbPNQlKKfNhiesccyXFcZg4eWGTKcsxpsBAI0CQiwUTLuq6Vi9))3EOC2GBJT6Uy7OLvfRaefJo(W533RBlGbBjLdVBtjjlKCUDninMpgDmXlq1MD(qK20eP5urSCBlPG0Fr6GD7HYzdUDSPEOuSt1fsYIftgLJpC(1962cyWws5W72usYcjNBJ5Jrht8cuTzNpePXfPX8XOtzGSqSkd5nuzaoFisJlsxdsJ5JrNIO0eJSD0U80SylezuGoF4ThkNn42dHoaXcvB(4dNN6EDBbmylPC4DBkjzHKZTX8XOJjEbQ2SZhI0MMiDDinMpgDL2JTelpHUsBmaPnnrA6yf8vOEwq66rACrAmFm6cjcnHIfQ2m0vAJbiTPjsh9RLLiu1HeqSCQii9xKMoq2YPIG04I00UxL2yGJjEbQ2SJiktcG3EOC2GBpPIuSq1Mp(W5Fq3RBlGbBjLdVBtjjlKCUnMpgDmXlq1MD(qKgxKgZhJoLbYcXQmK3qLb48HinUinMpgDkIstmY2r7YtZITqKrb68H3EOC2GBpe6aeluT5JpC())ED7HYzdUDykeAccyHQnFBbmylPC4D8HZ)AVx3wad2skhE3Msswi5C7AqAmFm6yIxGQn78HiTPjsZPIy52wsbP)I0)62dLZgC7qpjJgLGawS1a5JpC()S71TfWGTKYH3TPKKfso3o2upeP)G0XM6HoIeqain(qKoaTG0Fr6yt9qNYGVinUinMpgDmXlq1MDL2yasJlsxhsxdsxA2rBavamzyPyJRrrSyEcWreLjbqKgxKUgKEOC2ahTbubWKHLInUgfXLaBCLbuzKUEK20ePJ(1YseQ6qciwoveK(lshGwqAttKMhsaHDCQiwUTLuq6ViDWU9q5Sb3M2aQayYWsXgxJIC8HZ)NFVUTagSLuo8UnLKSqY52y(y0re67LaH2ytOIZhI0MMinMpgDeH(EjqOn2eQyPThWcXb5H(gP)I0)dcPnnrAovel32ski9xKoy3EOC2GBZQI1dWApOyJnHkhF48py3RBlGbBjLdVBtjjlKCUnMpgDmXlq1MDL2yasJlsxhsJ5JrxirOjuSq1MHoFisJlsxhshBQhI0)G0p)psBAI0y(y0PmqwiwLH8gQmaNpePRhPnnr66q6yt9qK(hKoybH04I0t1fsYIl2upuk2yseNagSLuqAttKo2upeP)bP)DWq66rACr66qAA3RsBmWXeVavB2reLjbqK(hKoyiTPjshBQhI0)G0)kiKUEK20eP5urSCBlPG0Fr6GH01F7HYzdU9qOdqSq1Mp(W5)tUx3EOC2GBdzzkgzHQnFBbmylPC4D8X32Z5kzJUxho)Vx3EOC2GBtBpGfIfQ28TfWGTKYH3Xho1EVU9q5Sb3gkebKSr2IhY3wad2skhEhF48S71ThkNn42WWMiw6Q9LBlGbBjLdVJpCE(962dLZgCBy3SAccynEyHCBbmylPC4D8HtWUx3EOC2GBdBqsTyRbY3wad2skhEhF48K71ThkNn42aHvfIfQ2033wad2skhEhF48771ThkNn42u1m4LqltgWtVpxjB0TfWGTKYH3Xho)6ED7HYzdUnmmjjBHQn99TfWGTKYH3Xhop1962dLZgCBWWEIaTbidvUTagSLuo8o(4JVn(fcmBWHtTb9)Pc631wRlOGc6)TnEiGeeaEB8rkHnHLcs)eKEOC2aKELqg6qvUnmuOho1gSNF7qshZLC7QH0bxd5nuzaq1mePXh4bSqqvQgsRYCim484rGKv9yoAR8aMk(1WzdOKjYpGPc9bQs1q6k(LriDT)QkKU2G()uin(eP))RGZZdcvbvPAiDWT6aciWGdQs1qA8js)0kfK2Z5kzJq6qs2KKncP5gPFAbFb)ouLQH04tK(PdkinNkILBBjfKMmSQqqAwDainpKac74urSCBlPG0CJ0dGtAgoSG0cOG0DePPTc2WoufuLQH04JXxH6zPG0ysSjcstBfSHrAmjqcGoK(PrPsidrAqdWNQdrj6xi9q5SbqKUblJCOkvdPhkNna6cjcTvWg2qCnW3OkvdPhkNna6cjcTvWg(JHhJpGIa4HZgGQunKEOC2aOlKi0wbB4pgEe7UGQunKEdMqOAZinzYcsJ5JrPG0qEyisJjXMiinTvWggPXKajaI0dOG0HebFg2mNGaiDcr6sdehQs1q6HYzdGUqIqBfSH)y4bemHq1MTqEyiQYq5SbqxirOTc2WFm8iS5SbOkdLZgaDHeH2kyd)XWdvpGfc0QmK3OkvdPd(icDGmsZQjePhisldzzespqKoSHWeBjin3iDyZcGZzTmcPdmjaPhqZQcbPPdKr6INKGainRkiDmdOYouLHYzdGUqIqBfSH)y4rP9ylXYtyvHeHoq2YPIy4FqOkdLZgaDHeH2kyd)XWdJBYQGFjbwIaBWaOcQYq5SbqxirOTc2WFm8iGFiLCa2oANQlKMvrvgkNna6cjcTvWg(JHhkIstmY2r7YtZITqKrbIQmuoBa0fseARGn8hdpyIxGQnxvirOdKTCQig(7cwvz0Wq5e)IvaIskWFQfvzOC2aOlKi0wbB4pgEmPIuSq1MRkJggkN4xScqusb(9zOkOkdLZgaDEoxjBKbA7bSqSq1MrvgkNna68CUs2OpgEafIas2iBXdzuLHYzdGopNRKn6JHhWWMiw6Q9fuLHYzdGopNRKn6JHhWUz1eeWA8WcbvzOC2aOZZ5kzJ(y4bSbj1ITgiJQmuoBa055CLSrFm8aiSQqSq1M(gvzOC2aOZZ5kzJ(y4bvndEj0YKb807ZvYgHQmuoBa055CLSrFm8agMKKTq1M(gvzOC2aOZZ5kzJ(y4byyprG2aKHkOkOkvdPXhJVc1ZsbPf8leJqAoveKMvfKEOCtq6eI0d(NCnylXHQmuoBa0aDwl7q5Sb2vc5QaJIyWZ5kzJQkJgkcMpgD0bYjiGZhAAwemFm6kjmuwRbBjwLjqsD(qtZIG5JrxjHHYAnylXkaYeqC(quLHYzdGFm8WdfBYIsvGrrmeywcDwlHaTyDdQkJgW8XOJjEbQ2SZhAAwdplbWo6SwjiGLvfluTzOtad2skMMCQiwUTLu((piuLHYzdGFm8WdfBYIsvGrrme203cdZQlflTvc98WzdSfb)jvQkJgQbZhJoM4fOAZoFiU1vJaHcGkoSv3fBhTSQyfGOyKtzcEnX0SgbcfavCyRUl2oAzvXkarXihzaV)XWZQ30Siy(y0HT6Uy7OLvfRaefJC(qttovel32skFdgQs1q6xeJqAUr6vceK2hI0dLt8pSuqAMKG3cdrAJtwfPFr8cuTzuLHYzdGFm8WdfBYIcSQmAaZhJoM4fOAZoFOPzn8Sea7OZALGawwvSq1MHobmylPyAYPIy52ws5BTbHQmuoBa8JHh0zTSdLZgyxjKRcmkIbAbIQmuoBa8JHh0zTSdLZgyxjKRcmkIbixvgnmuoXVyfGOKc87ZqvgkNna(XWd6Sw2HYzdSReYvbgfXats6BOAZWQYOHHYj(fRaeLuG)ulQcQYq5SbqhTanO6bSqGwLH8UQmAOiy(y0P6bSqGwLH82vAJb4wdMpgDmXlq1MD(quLHYzdGoAb(XWJs7XwILNWQYObA3RsBmWrMWSyJjrCerzsa8BaAX0K29Q0gdCKjml2ysehruMea)s7EvAJbUjvKIfQ2SJiktcGMMCQiwUTLu(wBqOkdLZgaD0c8JHhycbkK3jiqvz0aMpgDmXlq1MD(qCRJtfXYTTKYp0UxL2yGdtiqH8obbCfpz4SbFkEYWzdmnRJhsaHDQYSyvxiL)wBqMM1WZsaSJoej6x2jvCcyWwsP(6nn5urSCBlP89)ZqvgkNna6Of4hdpWwDxSrpXOQYObmFm6yIxGQn78H4whNkILBBjLFODVkTXah2Q7In6jg5kEYWzd(u8KHZgyAwhpKac7uLzXQUqk)T2GmnRHNLayhDis0VStQ4eWGTKs91BAYPIy52ws57)NGQmuoBa0rlWpgEmaQazYSS0zTQkJgW8XOJjEbQ2SZhIBDCQiwUTLu(H29Q0gdCdGkqMmllDwlxXtgoBWNINmC2atZ64HeqyNQmlw1fs5V1gKPzn8Sea7OdrI(LDsfNagSLuQVEttovel32skF))euLHYzdGoAb(XWJyseSv3LQYObmFm6yIxGQn78H4whNkILBBjLFODVkTXaxmjc2Q7IR4jdNn4tXtgoBGPzD8qciStvMfR6cP83AdY0SgEwcGD0Hir)YoPItad2sk1xVPjNkILBBjLVpfQYq5SbqhTa)y4XkdOYqBWZxcOiagvzOC2aOJwGFm8W4MSk4xsGLiWgmaQuvgnG5Jr3kJc2Q7IdYd993NJBny(y0XeVavB25drvgkNna6Of4hdpc4hsjhGTJ2P6cPz1QYOH6OJvWxH6zX0KtfXYTTKYp1(pO6XTomFm6yIxGQn78HMM0UxL2yGJjEbQ2SJiktcGF))K6nn5urSCBlP89zbHQmuoBa0rlWpgEqYWWLytGfgouPQmAG29Q0gdCmXlq1MDerzsa87VrvgkNna6Of4hdpueLMyKTJ2LNMfBHiJcSQmAOgmFm6yIxGQn78HOkdLZgaD0c8JHhHnNnOQmAaZhJoM4fOAZoImugxmFm6WwDxwEi7iYqzttmFm6yIxGQn78H4shRGVc1ZIPzD0ga9kd2sCHnNnW2rRhGrYYsk2ONyeUCQiwUTLu((K)MMCQiwUTLu(w7tQhvzOC2aOJwGFm8GjEbQ2Cvz0qSPE4ppjiCRdZhJUqIqtOyHQndDL2yaU0UxL2yGJmHzXgtI4iIYKaiUCQiwUTLu(H29Q0gdCmXlq1MDfpz4Sb2aEbc)u8KHZgyAYdjGWovzwSQlKYFRnitZA4zja2rhIe9l7KkobmylPuVPjNkILBBjLV)dgQcQYq5SbqhKni4B4QHj(fluTzuLHYzdGoi)XWdSHqMasvz0Wq5e)IvaIskWF(JQmuoBa0b5pgEmwfpPieBhTusBmevzOC2aOdYFm8akKqbWwiNGavLrdejseO6GTeCRzOC2ahuiHcGTqobbCjWgxzavgvzOC2aOdYFm8GmHzXgtIuvgnG5Jrht8cuTzxPngyAgBQh(93bHQunKoJgW8XOJjEbQ2SZhIBDy(y05bcHKGaw8NWSboip03)8CtZAMQlKKfNhiesccyXFcZg4eWGTKs9MM8qciSJtfXYTTKY3))rvgkNna6G8hdpWwDxSD0YQIvaIIrvLrdy(y0XeVavB25dXTomFm68aHqsqal(ty2ahKh67FEUPznt1fsYIZdecjbbS4pHzdCcyWwsPEttovel32skF))hvzOC2aOdYFm8i2upuk2P6cjzXIjJsvz0qny(y0XeVavB25dnn5urSCBlP8nyOkdLZgaDq(JHhdHoaXcvBUQmAaZhJoM4fOAZoFiUy(y0PmqwiwLH8gQmaNpe3AW8XOtruAIr2oAxEAwSfImkqNpevzOC2aOdYFm8ysfPyHQnxvgnG5Jrht8cuTzNp00SomFm6kThBjwEcDL2yGPjDSc(kupl1JlMpgDHeHMqXcvBg6kTXatZOFTSeHQoKaILtf5lDGSLtfbxA3RsBmWXeVavB2reLjbquLHYzdGoi)XWJHqhGyHQnxvgnG5Jrht8cuTzNpexmFm6ugileRYqEdvgGZhIlMpgDkIstmY2r7YtZITqKrb68HOkdLZgaDq(JHhHPqOjiGfQ2mQYq5SbqhK)y4rONKrJsqal2AGCvz0qny(y0XeVavB25dnn5urSCBlP89xOkdLZgaDq(JHh0gqfatgwk24AuKQYOHyt9WpXM6HoIeqa4ddqlFJn1dDkd(IlMpgDmXlq1MDL2yaU1vtPzhTbubWKHLInUgfXI5jahruMeaXTMHYzdC0gqfatgwk24AuexcSXvgqLR30m6xllrOQdjGy5ur(gGwmn5HeqyhNkILBBjLVbdvzOC2aOdYFm8GvfRhG1EqXgBcvQkJgW8XOJi03lbcTXMqfNp00eZhJoIqFVei0gBcvS02dyH4G8qF)9FqMMCQiwUTLu(gmuLHYzdGoi)XWJHqhGyHQnxvgnG5Jrht8cuTzxPngGBDy(y0fseAcfluTzOZhIBDXM6H)88)MMy(y0PmqwiwLH8gQmaNpSEtZ6In1d)jybH7uDHKS4In1dLInMeXjGbBjftZyt9WF(DWQh36ODVkTXaht8cuTzhruMea)jyMMXM6H)8RGQ30KtfXYTTKY3GvpQYq5SbqhK)y4bKLPyKfQ2mQcQYq5Sbqhts6BOAZqdydHmbeuLHYzdGoMK03q1MHFm8qW3Wvdt8lwOAZOkdLZgaDmjPVHQnd)y4XKksXcvBUQmAaZhJoMK03wOAZqNpex6yf8vOEwWfZhJUs7XwILNqNpevzOC2aOJjj9nuTz4hdpitywSXKivLrdy(y0XKK(2cvBg68H4w3uDHKS4In1dLInMeXjGbBjftZP6cjzXLalRkwIQrSQIJmG3)830CQUqswCqpjqccyHQndDcyWwsX0KNLayhKjYOSsG4eWGTKs9OkdLZgaDmjPVHQnd)y4XKksXcvBUQmAaZhJoMK03wOAZqNpe36W8XOlKi0ekwOAZqxPngyAs7EvAJbUjvKIfQ2Sl6xllrOQdjGy5ur(ouoBGBsfPyHQn7OdKTCQiMMy(y0XeVavB25dRhvzOC2aOJjj9nuTz4hdpitywSXKivLrdy(y0XKK(2cvBg68HOkdLZgaDmjPVHQnd)y4HIFXjuT5QYObmFm6yssFBHQndDL2yGPjMpgDHeHMqXcvBg68H4wdMpgDmXlq1MD(qtZyt9WF(DqOkdLZgaDmjPVHQnd)y4rSPEOuSt1fsYIftgfuLHYzdGoMK03q1MHFm8i0tYOrjiGfBnqgvzOC2aOJjj9nuTz4hdpOnGkaMmSuSX1OiOkdLZgaDmjPVHQnd)y4b2Q7ITJwwvScqumcvzOC2aOJjj9nuTz4hdpyvX6byThuSXMqLQYObmFm6ic99sGqBSjuX5dnnX8XOJi03lbcTXMqflT9awioip03F)heQYq5Sbqhts6BOAZWpgEeMcHMGawOAZOkdLZgaDmjPVHQnd)y4Xyv8KIqSD0sjTXquLHYzdGoMK03q1MHFm8akKqbWwiNGavLrdejseO6GTeCRzOC2ahuiHcGTqobbCjWgxzavgvzOC2aOJjj9nuTz4hdpGSmfJSq1Mp(47a]] )
end