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


    spec:RegisterPack( "Marksmanship", 20190816, [[dWu(8aqivqpsuOnHi(KaGrjQ4uIkTkbiLxPIAwIIULaO2fv(LkYWev1XuPSmefptfW0ub6AikTnrv8nrbgNauNtuqRtLenpvQUhj1(uj1bfGyHKepuLe6IcavFuaimsbGYjfvj1kfLMPaiDtrvI2jI0qfvjzPcarpvPMQkXvfasFvas1yvjbVvasURai2lWFPyWK6WkwmcpgPjlYLrTzH(SanAk50swTOk1RvHMTsUnj2TQ(TudxqhxuLWYH8CqtN46u12ru13jjnEvs68cO1JOY8Pu7hQb3axa70imGuYK)Tmm)a(wEC3i7bpizjlylbgYGD4qpobzW(hfgSZlh0rOY8qRkeSdNax9KaxaBy7rugSZiwBjsi8kpDkyjwEchTvoblf)AKQFkAIYjyPqpb2e(Aj51pGaStJWasjt(3YW8d4B5XDJSh8GKHmG94fRgb27s5kc2wvkXpGaStmKc2zeRZlh0rOY8qRkeRdG5FHr4SzeRTejeELNofSelpHJ2kNGLIFns1pfnr5eSuONWzZiwhq8b9qbRVLNmXAYK)TmeRdWy9nYELhGS4S4SzeRVIwZhKHxjoBgX6amwhqsjS2l1QKaX6qu1OsceRLgRdi5vbOoC2mI1bySoakKXAPuyJ0MuXynAelgH1I18yTmOGS4KsHnsBsfJ1sJ1ZlfTchHXA(tyDhXAARqmIdSxfuGGlGTGk6rOvlqWfaP3axa7Hkv)GnXGqtqgS5FiwCcOcqaKsgWfWEOs1pyZxnC1WI8SbA1cyZ)qS4eqfGai9aGlGn)dXItavaBkQegvdyt4JrNGk6rd0QfOZhI1KG10XWxLPEHXAsWAcFm6sTNyXgzcD(qWEOs1pypLcNmqRwacG0dcUa28pelobubSPOsyunGnHpgDcQOhnqRwGoFiwtcwNdwpKJrLWUyt9qozIfID8peloH122y9qogvc7Q3iwSbzfOyP4qZFeRVgRVH122y9qogvc7GEuW6dAGwTaD8peloH122yTml(fhuq8OSQND8peloH15c2dvQ(bB0ewjtSqmqaKswWfWM)HyXjGkGnfvcJQbSj8XOtqf9ObA1c05dXAsW6CWAcFm6crmTGSbA1c0LAvFS22gRPDVsTQVBkfozGwT4I(1YGyQ1GcYgPuyS(owpuP63nLcNmqRwC0bkgPuyS22gRj8XOtqEgA1IZhI15c2dvQ(b7Pu4KbA1cqaKMhWfWM)HyXjGkGnfvcJQbSj8XOtqf9ObA1c05db7Hkv)GnAcRKjwigiasZaWfWM)HyXjGkGnfvcJQbSj8XOtqf9ObA1c0LAvFS22gRj8XOleX0cYgOvlqNpeRjbRpeRj8XOtqEgA1IZhI122yDSPEiwFnwNb5d2dvQ(bBf)skOvlabqAadUa2dvQ(b7yt9qozgYXOsydbpkGn)dXItavacG0meCbShQu9d2HEufdS(GgI1afWM)HyXjGkabq6T8bxa7Hkv)GnTFk)cAeozIRrHbB(hIfNaQaeaP3UbUa2dvQ(bBIv3jthnIfB4NvceS5FiwCcOcqaKEJmGlGn)dXItavaBkQegvdyt4JrhIPhxmeAInIYoFiwBBJ1e(y0Hy6XfdHMyJOSH2(xyKdkd9iwFhRVLpypuP6hSfl24FI2)jtSrugiasVDaWfWEOs1pyhwmIwFqd0QfWM)HyXjGkabq6TdcUa2dvQ(b7XO4rjgz6OHIAvHGn)dXItavacG0BKfCbS5FiwCcOcytrLWOAaBehrm0AiwmwtcwFiwpuP63bzui)Ibk1h0vVjUQGwcypuP6hSHmkKFXaL6dceaP3Yd4cypuP6hSHcpPanqRwaB(hIfNaQaeGa2joo(LaUai9g4cyZ)qS4eqfWMIkHr1a2jMWhJo6aL6d68HyTTnwNycFm6sfmKxRHyXgLjyrD(qS22gRtmHpgDPcgYR1qSyd)Oji78HG9qLQFWMoRLzOs1VzvqbSxfum)OWGTxQvjbceaPKbCbS5FiwCcOcypuP6hSdolMoRfJGgIUFWMIkHr1a2e(y0jipdTAX5dXABBS(qSwMf)IJoRv9bnIfBGwTaD8peloH122yTukSrAtQyS(owFlFW(hfgSdolMoRfJGgIUFGai9aGlGn)dXItava7Hkv)G9qoO1GgOj2Vy6OjSvLrGnfvcJQbSPDVsTQVtqEgA1IdXkt9qS(owFlGXABBSwkf2iTjvmwFhRpy(G9pkmypKdAnObAI9lMoAcBvzeqaKEqWfWM)HyXjGkG9qLQFWEGwKFEgAqd5AKH2Ozb2uujmQgWMWhJob5zOvloFiwtcwNdwt4Jrxq)Gs18MoAgYXOwSC(qS22gRpeRZbRziKFk7O9N4hYjZQICSru2Pm5DJWAsWAgc5NYoA)j(HCYSQihBeLDO5pI1xRgRpawNlwtcwthdFvM6fgRZfRTTX6et4JrhAixJm0gnltIj8XOl1Q(yTTnwlLcBK2KkgRVJ1KjFW(hfgShOf5NNHg0qUgzOnAwabqkzbxaB(hIfNaQa2dvQ(b7WMEKfyroozOTsOxgP63KyYxugSPOsyunG9HynHpgDcYZqRwC(qSMeS(qSohSMHq(PSJy1DY0rJyXg(zLaDktE3iSMeSMHq(PSJy1DY0rJyXg(zLaDO5pI1xRgRpawNlwBBJ1jMWhJoIv3jthnIfB4Nvc05dXABBSwkf2iTjvmwFhRjly)Jcd2Hn9ilWICCYqBLqVms1VjXKVOmqaKMhWfWM)HyXjGkGnfvcJQbSj8XOtqEgA1IZhI122y9HyTml(fhDwR6dAel2aTAb64FiwCcRTTXAPuyJ0MuXy9DSMm5d2dvQ(bBpKnLWkqGaindaxaB(hIfNaQa2dvQ(bB6SwMHkv)MvbfWEvqX8Jcd20eeiasdyWfWM)HyXjGkGnfvcJQbShQuKNn8ZkfdX67y9ba7Hkv)GnDwlZqLQFZQGcyVkOy(rHbBOaeaPzi4cyZ)qS4eqfWMIkHr1a2dvkYZg(zLIHy91ynza7Hkv)GnDwlZqLQFZQGcyVkOy(rHbBbv0JqRwGabiGDiIPTcXiGlasVbUa2dvQ(b7WwQ(bB(hIfNaQaeaPKbCbShQu9d2w(xye0OmOJGn)dXItavacG0daUa28pelobubSdrmDGIrkfgSVLpypuP6hStTNyXgzcbcG0dcUa2dvQ(bBvB0krEUEdIH9ppLbB(hIfNaQaeaPKfCbShQu9d2b9dkvZB6OzihJAXcS5FiwCcOcqaKMhWfWEOs1pyRWknkqthnlpTsMeIhfiyZ)qS4eqfGaindaxaB(hIfNaQa2)OWG9qoO1GgOj2Vy6OjSvLrG9qLQFWEih0Aqd0e7xmD0e2QYiGainGbxaB(hIfNaQa2HiMoqXiLcd23CKfShQu9d2cYZqRwaBkQegvdypuPipB4NvkgI1xJ1KbiasZqWfWM)HyXjGkGnfvcJQbShQuKNn8ZkfdX67y9ba7Hkv)G9ukCYaTAbiabSPji4cG0BGlGn)dXItavaBkQegvdyNycFm6S8VWiOrzqhDPw1hRjbRpeRj8XOtqEgA1IZhc2dvQ(bBl)lmcAug0rGaiLmGlGn)dXItavaBkQegvdyt7ELAvFhAcRKjwi2HyLPEiwFhRdstyTTnwt7ELAvFhAcRKjwi2HyLPEiwFhRPDVsTQVBkfozGwT4qSYupeRTTXAPuyJ0MuXy9DSMm5d2dvQ(b7u7jwSrMqGai9aGlGn)dXItavaBkQegvdyt4JrNG8m0QfNpeRjbRZbRLsHnsBsfJ1xJ10UxPw13rWiiJowFqxYJgP6hRpJ1jpAKQFS22gRZbRLbfKfNfplXYfsfS(owtM8XABBS(qSwMf)IJoio6xMPuC8peloH15I15I122yTukSrAtQyS(owF7aG9qLQFWMGrqgDS(Gabq6bbxaB(hIfNaQa2uujmQgWMWhJob5zOvloFiwtcwNdwlLcBK2KkgRVgRPDVsTQVJy1DYe9OaDjpAKQFS(mwN8OrQ(XABBSohSwguqwCw8SelxivW67ynzYhRTTX6dXAzw8lo6G4OFzMsXX)qS4ewNlwNlwBBJ1sPWgPnPIX67y9T8a2dvQ(bBIv3jt0Jceiasjl4cyZ)qS4eqfWMIkHr1a2e(y0jipdTAX5dXAsW6CWAPuyJ0MuXy91ynT7vQv9DZtzOGMLHoRLl5rJu9J1NX6Khns1pwBBJ15G1YGcYIZINLy5cPcwFhRjt(yTTnwFiwlZIFXrheh9lZuko(hIfNW6CX6CXABBSwkf2iTjvmwFhRVLhWEOs1pyppLHcAwg6SwabqAEaxaB(hIfNaQa2uujmQgWMWhJob5zOvloFiwtcwNdwlLcBK2KkgRVgRPDVsTQVlwiMy1DYL8OrQ(X6ZyDYJgP6hRTTX6CWAzqbzXzXZsSCHubRVJ1KjFS22gRpeRLzXV4OdIJ(Lzkfh)dXItyDUyDUyTTnwlLcBK2KkgRVJ1ziypuP6hSJfIjwDNacG0maCbShQu9d2RkOLan5TpfuHFbS5FiwCcOcqaKgWGlGn)dXItavaBkQegvdyt4Jr3QImXQ7Kdkd9iwFhRpiwtcwFiwt4JrNG8m0QfNpeShQu9d2Q2OvI8C9ged7FEkdeaPzi4cyZ)qS4eqfWMIkHr1a25G10XWxLPEHXABBSwkf2iTjvmwFnwt7ELAvFxq)Gs18MoAgYXOwSCjpAKQFS(mwN8OrQ(X6CXAsW6CWAcFm6eKNHwT48HyTTnwt7ELAvFNG8m0QfhIvM6Hy9DS(wEW6CXABBSwkf2iTjvmwFhRpWnWEOs1pyh0pOunVPJMHCmQflGai9w(GlGn)dXItavaBkQegvdyt7ELAvFNG8m0QfhIvM6Hy9DSoda7Hkv)GnQcdxSPEdmCOmqaKE7g4cyZ)qS4eqfWMIkHr1a2hI1e(y0jipdTAX5db7Hkv)GTcR0OanD0S80kzsiEuGabq6nYaUa28pelobubSPOsyunGnHpgDcYZqRwCiEOcwtcwt4JrhXQ70YdfhIhQG122ynHpgDcYZqRwC(qSMeSMog(Qm1lmwBBJ15G10(HELHyXUWwQ(nD04FcuLwCYe9OaXAsWAPuyJ0MuXy9DSop3WABBSwkf2iTjvmwFhRjtEW6Cb7Hkv)GDylv)abq6TdaUa28pelobubSPOsyunGDSPEiwFnwNN8XAsW6CWAcFm6crmTGSbA1c0LAvFSMeSM29k1Q(o0ewjtSqSdXkt9qSMeSwkf2iTjvmwFnwt7ELAvFNG8m0QfxYJgP63e0ZqiwFgRtE0iv)yTTnwldkilolEwILlKky9DSMm5J122y9HyTml(fhDqC0VmtP44FiwCcRZfRTTXAPuyJ0MuXy9DS(gzb7Hkv)GTG8m0QfGaeWgkGlasVbUa2dvQ(bB(QHRgwKNnqRwaB(hIfNaQaeaPKbCbS5FiwCcOcytrLWOAa7Hkf5zd)SsXqS(AS(gypuP6hSjgeAcYabq6baxa7Hkv)G9yu8OeJmD0qrTQqWM)HyXjGkabq6bbxaB(hIfNaQa2uujmQgWgXredTgIfJ1KG1hI1dvQ(DqgfYVyGs9bD1BIRkOLa2dvQ(bBiJc5xmqP(GabqkzbxaB(hIfNaQa2uujmQgWMWhJob5zOvlUuR6J122yDSPEiwFhRZG8b7Hkv)GnAcRKjwigiasZd4cyZ)qS4eqfWMIkHr1a2e(y0jipdTAX5dXAsW6CWAcFm68pJq1h0q(cw97GYqpI1xJ1heRTTX6dX6HCmQe25FgHQpOH8fS63X)qS4ewNlwBBJ1sPWgPnPIX67y9TBG9qLQFWMy1DY0rJyXg(zLabcG0maCbS5FiwCcOcytrLWOAa7dXAcFm6eKNHwT48HyTTnwlLcBK2KkgRVJ1KfShQu9d2XM6HCYmKJrLWgcEuacG0agCbS5FiwCcOcytrLWOAaBcFm6eKNHwT48HynjynHpgDkduyKrzqhHkZ78Hynjy9HynHpgDkSsJc00rZYtRKjH4rb68HG9qLQFWEq05zd0QfGaindbxaB(hIfNaQa2uujmQgWMWhJob5zOvloFiwBBJ15G1e(y0LApXInYe6sTQpwBBJ10XWxLPEHX6CXAsWAcFm6crmTGSbA1c0LAvFS22gRJ(1YGyQ1GcYgPuyS(owthOyKsHXAsWAA3RuR67eKNHwT4qSYupeShQu9d2tPWjd0QfGai9w(GlGn)dXItavaBkQegvdyt4JrNG8m0QfNpeRjbRj8XOtzGcJmkd6iuzENpeRjbRj8XOtHvAuGMoAwEALmjepkqNpeShQu9d2dIopBGwTaeaP3UbUa2dvQ(b7WIr06dAGwTa28pelobubiasVrgWfWM)HyXjGkGnfvcJQbSpeRj8XOtqEgA1IZhI122yTukSrAtQyS(owhWG9qLQFWo0JQyG1h0qSgOaeaP3oa4cyZ)qS4eqfWMIkHr1a2XM6Hy9zSo2up0H4G8J1b0W6G0ewFhRJn1dDkZvXAsWAcFm6eKNHwT4sTQpwtcwNdwFiwNAXr7NYVGgHtM4AuydHh9oeRm1dXAsW6dX6Hkv)oA)u(f0iCYexJc7Q3exvqlbRZfRTTX6OFTmiMAnOGSrkfgRVJ1bPjS22gRLbfKfNukSrAtQyS(owtwWEOs1pyt7NYVGgHtM4AuyGai92bbxaB(hIfNaQa2uujmQgWMWhJoetpUyi0eBeLD(qS22gRj8XOdX0JlgcnXgrzdT9VWihug6rS(owFlFS22gRLsHnsBsfJ13XAYc2dvQ(bBXIn(NO9FYeBeLbcG0BKfCbS5FiwCcOcytrLWOAaBcFm6eKNHwT4sTQpwtcwNdwt4JrxiIPfKnqRwGoFiwtcwNdwhBQhI1xJ1h8gwBBJ1e(y0PmqHrgLbDeQmVZhI15I122yDoyDSPEiwFnwt28XAsW6HCmQe2fBQhYjtSqSJ)HyXjS22gRJn1dX6RX6mGSyDUynjyDoynT7vQv9DcYZqRwCiwzQhI1xJ1KfRTTX6yt9qS(ASoGZhRZfRTTXAPuyJ0MuXy9DSMSyDUG9qLQFWEq05zd0QfGai9wEaxa7Hkv)Gnu4jfObA1cyZ)qS4eqfGaeW2l1QKabxaKEdCbShQu9d202)cJmqRwaB(hIfNaQaeaPKbCbShQu9d2qgXFjbAsEOa28pelobubiaspa4cypuP6hSHHnIn0v7tGn)dXItavacG0dcUa2dvQ(bBy3Iv9bnQocJaB(hIfNaQaeaPKfCbShQu9d2W(lQHynqbS5FiwCcOcqaKMhWfWEOs1py)SyXid0QPhbB(hIfNaQaeaPza4cypuP6hSPwvExqJGMpVWxRsceS5FiwCcOcqaKgWGlG9qLQFWggwOsmqRMEeS5FiwCcOcqaKMHGlG9qLQFW(hXJyOjiAOmyZ)qS4eqfGaeGa2KNrWQFaPKj)Bzy(b8T8a2QoOV(GqWoGEajassZRjnaIReRX6lwmwxkHnsW6yJW6aqIJJFjbaSgX5f(cXjSg2kmwpEPvgHtyn1A(Gm0HZgGwpJ1h8kX6Ry)KNrcNW6aadH8tz3vWfqPm5DJSvQVrbio08hZyaaRLgRda5Wqi)u2DfCbuktE3iBL6BuacjmeYpLDxbhA(JxRoJ5gaW6CUD1CD4SbO1ZynzVsS(k2p5zKWjSoaWqi)u2DfCbuktE3iBL6BuaIdn)XmgaWAPX6aqomeYpLDxbxaLYK3nYwP(gfGqcdH8tz3vWHM)41QZyUbaSoNBxnxholoBETsyJeoH15bRhQu9J1RckqholyhI6yTyWoJyDE5GocvMhAvHyDam)lmcNnJyTLiHWR80PGLy5jC0w5eSu8RrQ(POjkNGLc9eoBgX6aIpOhky9T8KjwtM8VLHyDagRVr2R8aKfNfNnJy9v0A(Gm8kXzZiwhGX6askH1EPwLeiwhIQgvsGyT0yDajVka1HZMrSoaJ1bqHmwlLcBK2KkgRrJyXiSwSMhRLbfKfNukSrAtQySwASEEPOv4imwZFcR7iwtBfIrC4S4SzeRdGFvM6foH1eCSrmwtBfIrWAcoy9qhwhqOuouGy93Fa2Aqkr)cRhQu9dX6(xb6WzZiwpuP6h6crmTvigrDCnWJ4SzeRhQu9dDHiM2keJCw9PXhuHFzKQFC2mI1dvQ(HUqetBfIroR(uS7eoBgX69pHqRwWA0ujSMWhJCcRHYiqSMGJnIXAARqmcwtWbRhI1ZNW6qehGdBrQpiwxqSo1p7WzZiwpuP6h6crmTvig5S6tWFcHwTyGYiqC2Hkv)qxiIPTcXiNvFkSLQFC2Hkv)qxiIPTcXiNvFYY)cJGgLbDeNnJyDEfIPduWAXQGy9aXAEqRaX6bI1HnewelgRLgRdBHFPM1kqSo4upwpFlwmcRPduW6KhvFqSwSySowbTeho7qLQFOleX0wHyKZQpLApXInYeMziIPdumsPWQVLpo7qLQFOleX0wHyKZQpPAJwjYZ1BqmS)5Pmo7qLQFOleX0wHyKZQpf0pOunVPJMHCmQflC2Hkv)qxiIPTcXiNvFsHvAuGMoAwEALmjepkqC2Hkv)qxiIPTcXiNvFYdztjSsM)OWQhYbTg0anX(fthnHTQmcNDOs1p0fIyARqmYz1NeKNHwTKziIPdumsPWQV5iBMvu9qLI8SHFwPy41KbNDOs1p0fIyARqmYz1NMsHtgOvlzwr1dvkYZg(zLIH3paolo7qLQFOZl1QKavtB)lmYaTAbNDOs1p05LAvsGNvFcYi(ljqtYdfC2Hkv)qNxQvjbEw9jyyJydD1(eo7qLQFOZl1QKapR(eSBXQ(GgvhHr4SdvQ(HoVuRsc8S6tW(lQHynqbNDOs1p05LAvsGNvF6zXIrgOvtpIZouP6h68sTkjWZQprTQ8UGgbnFEHVwLeio7qLQFOZl1QKapR(emSqLyGwn9io7qLQFOZl1QKapR(0pIhXqtq0qzCwC2mI1bWVkt9cNWAM8mkqSwkfgRflgRhQ0iSUGy9q(PwdXID4SdvQ(HQPZAzgQu9BwfuY8hfwTxQvjbMzfvNycFm6OduQpOZhABNycFm6sfmKxRHyXgLjyrD(qB7et4JrxQGH8Anel2WpAcYoFio7qLQF4z1N8q2ucRK5pkS6GZIPZAXiOHO7pZkQMWhJob5zOvloFOT9HYS4xC0zTQpOrSyd0QfOJ)HyXjBBPuyJ0MuX3VLpo7qLQF4z1N8q2ucRK5pkS6HCqRbnqtSFX0rtyRkJYSIQPDVsTQVtqEgA1IdXkt9W73cyBBPuyJ0MuX3py(4SdvQ(HNvFYdztjSsM)OWQhOf5NNHg0qUgzOnAwzwr1e(y0jipdTAX5djjhcFm6c6huQM30rZqog1ILZhABFidH8tzhT)e)qozwvKJnIYoLjVBKdn)XdqcDm8vzQx4CTTtmHpgDOHCnYqB0SmjMWhJUuR6BBlLcBK2Kk(ozYhNDOs1p8S6tEiBkHvY8hfwDytpYcSihNm0wj0lJu9Bsm5lkNzfvFiHpgDcYZqRwC(qsoKHq(PSJy1DY0rJyXg(zLaDktE3ihA(JhW2oXe(y0rS6oz6OrSyd)SsGoFOTTukSrAtQ47KfNnJy9fuGyT0y9QEgR9Hy9qLI8JWjSwq1FKfiwRAjwy9fKNHwTGZouP6hEw9jpKnLWkWmROAcFm6eKNHwT48H22hkZIFXrN1Q(GgXInqRwGo(hIfNSTLsHnsBsfFNm5JZouP6hEw9j6SwMHkv)MvbLm)rHvttqC2Hkv)WZQprN1YmuP63SkOK5pkSAOKzfvpuPipB4NvkgE)a4SdvQ(HNvFIoRLzOs1VzvqjZFuy1cQOhHwTaZSIQhQuKNn8ZkfdVMm4S4SdvQ(HoAcQ2Y)cJGgLbDmZkQoXe(y0z5FHrqJYGo6sTQpjhs4JrNG8m0QfNpeNDOs1p0rtWZQpLApXInYeMzfvt7ELAvFhAcRKjwi2HyLPE49G0KTnT7vQv9DOjSsMyHyhIvM6H3PDVsTQVBkfozGwT4qSYup02wkf2iTjv8DYKpo7qLQFOJMGNvFIGrqgDS(Gzwr1e(y0jipdTAX5djjhPuyJ0MuXxt7ELAvFhbJGm6y9bDjpAKQ)ZjpAKQFB7CKbfKfNfplXYfsL7KjFB7dLzXV4OdIJ(Lzkfh)dXIt5MRTTukSrAtQ473oao7qLQFOJMGNvFIy1DYe9OaZSIQj8XOtqEgA1IZhssosPWgPnPIVM29k1Q(oIv3jt0Jc0L8OrQ(pN8OrQ(TTZrguqwCw8SelxivUtM8TTpuMf)IJoio6xMPuC8peloLBU22sPWgPnPIVFlp4SdvQ(HoAcEw9P5PmuqZYqN1kZkQMWhJob5zOvloFij5iLcBK2Kk(AA3RuR67MNYqbnldDwlxYJgP6)CYJgP632ohzqbzXzXZsSCHu5ozY32(qzw8lo6G4OFzMsXX)qS4uU5ABlLcBK2Kk((T8GZouP6h6Oj4z1NIfIjwDNYSIQj8XOtqEgA1IZhssosPWgPnPIVM29k1Q(UyHyIv3jxYJgP6)CYJgP632ohzqbzXzXZsSCHu5ozY32(qzw8lo6G4OFzMsXX)qS4uU5ABlLcBK2Kk(EgIZouP6h6Oj4z1NwvqlbAYBFkOc)co7qLQFOJMGNvFs1gTsKNR3Gyy)Zt5mROAcFm6wvKjwDNCqzOhVFqsoKWhJob5zOvloFio7qLQFOJMGNvFkOFqPAEthnd5yulwzwr15qhdFvM6f22wkf2iTjv810UxPw13f0pOunVPJMHCmQflxYJgP6)CYJgP6pxsYHWhJob5zOvloFOTnT7vQv9DcYZqRwCiwzQhE)wEY12wkf2iTjv89dCdNDOs1p0rtWZQpHQWWfBQ3adhkNzfvt7ELAvFNG8m0QfhIvM6H3ZaC2Hkv)qhnbpR(KcR0OanD0S80kzsiEuGzwr1hs4JrNG8m0QfNpeNDOs1p0rtWZQpf2s1FMvunHpgDcYZqRwCiEOcje(y0rS6oT8qXH4Hk22e(y0jipdTAX5djHog(Qm1lSTDo0(HELHyXUWwQ(nD04FcuLwCYe9Oajrkf2iTjv898CZ2wkf2iTjv8DYKNCXzhQu9dD0e8S6tcYZqRwYSIQJn1dVop5tsoe(y0fIyAbzd0QfOl1Q(Kq7ELAvFhAcRKjwi2HyLPEijsPWgPnPIVM29k1Q(ob5zOvlUKhns1VjONHWZjpAKQFBBzqbzXzXZsSCHu5ozY32(qzw8lo6G4OFzMsXX)qS4uU22sPWgPnPIVFJS4S4SdvQ(HoOOMVA4QHf5zd0QfC2Hkv)qhuoR(eXGqtqoZkQEOsrE2WpRum86B4SdvQ(HoOCw9PXO4rjgz6OHIAvH4SdvQ(HoOCw9jiJc5xmqP(Gzwr1ioIyO1qSysoCOs1VdYOq(fduQpOREtCvbTeC2Hkv)qhuoR(eAcRKjwioZkQMWhJob5zOvlUuR6BBhBQhEpdYhNnJyDfvt4JrNG8m0QfNpKKCi8XOZ)mcvFqd5ly1Vdkd941h02(WHCmQe25FgHQpOH8fS63X)qS4uU22YGcYItkf2iTjv89B3WzhQu9dDq5S6teRUtMoAel2WpReyMvunHpgDcYZqRwC(qsYHWhJo)Ziu9bnKVGv)oOm0JxFqB7dhYXOsyN)zeQ(GgYxWQFh)dXIt5ABlLcBK2Kk((TB4SdvQ(HoOCw9Pyt9qozgYXOsydbpkzwr1hs4JrNG8m0QfNp02wkf2iTjv8DYIZouP6h6GYz1NgeDE2aTAjZkQMWhJob5zOvloFije(y0PmqHrgLbDeQmVZhsYHe(y0PWknkqthnlpTsMeIhfOZhIZouP6h6GYz1NMsHtgOvlzwr1e(y0jipdTAX5dTTZHWhJUu7jwSrMqxQv9TTPJHVkt9cNlje(y0fIyAbzd0QfOl1Q(22r)Azqm1AqbzJuk8D6afJukmj0UxPw13jipdTAXHyLPEio7qLQFOdkNvFAq05zd0QLmROAcFm6eKNHwT48HKq4JrNYafgzug0rOY8oFije(y0PWknkqthnlpTsMeIhfOZhIZouP6h6GYz1NclgrRpObA1co7qLQFOdkNvFk0JQyG1h0qSgOKzfvFiHpgDcYZqRwC(qBBPuyJ0MuX3dyC2Hkv)qhuoR(eTFk)cAeozIRrHZSIQJn1dphBQh6qCq(dOfKMUhBQh6uMRscHpgDcYZqRwCPw1NKCom1IJ2pLFbncNmX1OWgcp6DiwzQhsYHdvQ(D0(P8lOr4KjUgf2vVjUQGwsU22r)Azqm1AqbzJuk89G0KTTmOGS4KsHnsBsfFNS4SdvQ(HoOCw9jXIn(NO9FYeBeLZSIQj8XOdX0JlgcnXgrzNp02MWhJoetpUyi0eBeLn02)cJCqzOhVFlFBBPuyJ0MuX3jlo7qLQFOdkNvFAq05zd0QLmROAcFm6eKNHwT4sTQpj5q4JrxiIPfKnqRwGoFij5eBQhE9bVzBt4JrNYafgzug0rOY8oFyU225eBQhEnzZNKHCmQe2fBQhYjtSqSJ)HyXjB7yt9WRZaYMlj5q7ELAvFNG8m0QfhIvM6HxtwB7yt9WRd48Z12wkf2iTjv8DYMlo7qLQFOdkNvFck8Kc0aTAbNfNDOs1p0jOIEeA1cunXGqtqgNDOs1p0jOIEeA1c8S6t8vdxnSipBGwTGZouP6h6eurpcTAbEw9PPu4KbA1sMvunHpgDcQOhnqRwGoFij0XWxLPEHjHWhJUu7jwSrMqNpeNDOs1p0jOIEeA1c8S6tOjSsMyH4mROAcFm6eurpAGwTaD(qsYzihJkHDXM6HCYele74FiwCY2EihJkHD1Bel2GScuSuCO5pE9nB7HCmQe2b9OG1h0aTAb64FiwCY2wMf)IdkiEuw1Zo(hIfNYfNDOs1p0jOIEeA1c8S6ttPWjd0QLmROAcFm6eurpAGwTaD(qsYHWhJUqetliBGwTaDPw132M29k1Q(UPu4KbA1Il6xldIPwdkiBKsHVpuP63nLcNmqRwC0bkgPuyBBcFm6eKNHwT48H5IZouP6h6eurpcTAbEw9j0ewjtSqCMvunHpgDcQOhnqRwGoFio7qLQFOtqf9i0Qf4z1Nu8lPGwTKzfvt4JrNGk6rd0QfOl1Q(22e(y0fIyAbzd0QfOZhsYHe(y0jipdTAX5dTTJn1dVodYhNDOs1p0jOIEeA1c8S6tXM6HCYmKJrLWgcEuWzhQu9dDcQOhHwTapR(uOhvXaRpOHynqbNDOs1p0jOIEeA1c8S6t0(P8lOr4KjUgfgNDOs1p0jOIEeA1c8S6teRUtMoAel2WpReio7qLQFOtqf9i0Qf4z1Nel24FI2)jtSruoZkQMWhJoetpUyi0eBeLD(qBBcFm6qm94IHqtSru2qB)lmYbLHE8(T8XzhQu9dDcQOhHwTapR(uyXiA9bnqRwWzhQu9dDcQOhHwTapR(0yu8OeJmD0qrTQqC2Hkv)qNGk6rOvlWZQpbzui)Ibk1hmZkQgXredTgIftYHdvQ(DqgfYVyGs9bD1BIRkOLGZouP6h6eurpcTAbEw9jOWtkqd0QfWggYuaPKHSheiabaa]] )


end