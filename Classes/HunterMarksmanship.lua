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


    spec:RegisterPack( "Marksmanship", 20190925, [[dWul9aqivHEKOqBsvvFsvk1OeL6uIswLac6vQkMLOOBPkLyxu5xQsgMOkhdrzzQcEMQuzAQsX1ij12evvFtavJtaLZjkW6eqY8uv5EKu7dr4GIQcler1dvLs6IciuFuabmsbKkNuuqALIkZuaPCtrbv7erAOIcklvab6Pk1uvv6QciKVkGu1yfvf9wbe1DfqK9c8xkgmPoSIfJWJrAYICzuBwOplqJMsoTKvlQk9AvrZwj3Me7wLFl1Wf0XffelhYZbnDIRtvBNKKVtsmEvPQZlaRhr08Pu7hQbKb(c2PryaPpKhzzqEzWdVXrwG9GQFdzGTeqid2Hd95eKb7BuyWodFqpHkZbTQqWoCcy1tc8fSHThrzWoJyTLiHWa1RxblXYt4OTYlyP4xJu9rrtuEblf6lWMWxljd9aeGDAegq6d5rwgKxg8WBCKfyp8WdboypEXQrG9UuERGTvLs8bia7edPGDgX6m8b9eQmh0QcX6aD(tyeoxgXAlrcHbQxVcwILNWrBLxWsXVgP6JIMO8cwk0x4CzeR3COWkemcRFq1zI1pKhzzaohoxgX63Q1CbzyGcNlJy9BbRZhPew7LAvsayDiQAujbG1sJ15JmSanhoxgX63cwhicYyTukSrAtQySgnIfJWAXAoSwguqwCsPWgPnPIXAPX65KIwHJWynFjSUJynTvigXb2RckqWxWwqf9j0Qfi4lGuYaFb7HkvFGnXGqtqgS5BiwCcqoqaK(a4lypuP6dS53hUAyPk2aTAbS5BiwCcqoqaK(oWxWMVHyXja5GnfvcJQbSj8XOtqf9PbA1c05dX6)ynDm87zQxyS(pwt4JrxQ9el2itOZhc2dvQ(a7Pu4KbA1cqaK(gWxWMVHyXja5GnfvcJQbSj8XOtqf9PbA1c05dX6)yD2y9qsgvc7In1d5Kjwi2X3qS4ewBBJ1djzujSRoJyXgKvaILIdn3tSMeynzyTTnwpKKrLWoOhfSUGgOvlqhFdXItyTTnwlZIpXbfepkR6yhFdXItyDwG9qLQpWgnHvYeledeaPQg8fS5BiwCcqoytrLWOAaBcFm6eurFAGwTaD(qS(pwNnwt4JrxiIPfKnqRwGUuRYH122ynT7vQv5CtPWjd0Qfx0VwgetTguq2iLcJ1)W6HkvFUPu4KbA1IJoqXiLcJ122ynHpgDcYZqRwC(qSolWEOs1hypLcNmqRwacG08d(c28nelobihSPOsyunGnHpgDcQOpnqRwGoFiypuP6dSrtyLmXcXabqAGd(c28nelobihSPOsyunGnHpgDcQOpnqRwGUuRYH122ynHpgDHiMwq2aTAb68Hy9FS(rSMWhJob5zOvloFiwBBJ1XM6HynjW6appWEOs1hyR4xsbTAbiasdmWxWEOs1hyhBQhYjZqsgvcBi4rbS5BiwCcqoqaKMbGVG9qLQpWo0JQya1f0qSgOa28nelobihiasjlpWxWEOs1hyt7JYNGgHtM4AuyWMVHyXja5abqkzKb(c2dvQ(aBIv3jthnIfB4JvcaS5BiwCcqoqaKs2dGVGnFdXItaYbBkQegvdyt4JrhIPpxmeAInIYoFiwBBJ1e(y0Hy6ZfdHMyJOSH2(tyKdkd9jw)dRjlpWEOs1hylwSXFeT)sMyJOmqaKs27aFb7HkvFGDyXiADbnqRwaB(gIfNaKdeaPK9gWxWEOs1hypgfpkXithnuuRceS5BiwCcqoqaKsMQbFbB(gIfNaKd2uujmQgWgXredTgIfJ1)X6hX6HkvFoiJc5tmqPUGU6mXvf0sa7HkvFGnKrH8jgOuxqGaiLS8d(c2dvQ(aBOWtkad0QfWMVHyXja5abiGDIJJFjGVasjd8fS5BiwCcqoytrLWOAa7et4JrhDGsDbD(qS22gRtmHpgDPcgYR1qSyJYeSOoFiwBBJ1jMWhJUubd51AiwSHp0eKD(qWEOs1hytN1YmuP6ZSkOa2RckMBuyW2l1QKaacG0haFbB(gIfNaKd2dvQ(a7GZIPZAXiOHO7dSPOsyunGnHpgDcYZqRwC(qS22gRFeRLzXN4OZAvxqJyXgOvlqhFdXItyTTnwlLcBK2KkgR)H1KLhyFJcd2bNftN1Irqdr3hqaK(oWxWMVHyXja5G9qLQpWEij0Aqd0e7tmD0e2QWiWMIkHr1a20UxPwLZjipdTAXHyLPoiw)dRjlWWABBSwkf2iTjvmw)dRFtEG9nkmypKeAnObAI9jMoAcBvyeqaK(gWxWMVHyXja5G9qLQpWEGwQAogAqdjBKH2Ozb2uujmQgWMWhJob5zOvloFiw)hRZgRj8XOlOFqPAothndjzulwoFiwBBJ1pI1zJ1meYhLD0(s8b5Kzvro2ik7uM8Try9FSMHq(OSJ2xIpiNmRkYXgrzhAUNynjuJ1VdRZcR)J10XWVNPEHX6SWABBSoXe(y0Hgs2idTrZYKycFm6sTkhwBBJ1sPWgPnPIX6Fy9d5b23OWG9aTu1Cm0Ggs2idTrZciasvn4lyZ3qS4eGCWEOs1hyh20NSalsYjdTvc9YivFMeRQIYGnfvcJQbSFeRj8XOtqEgA1IZhI1)X6hX6SXAgc5JYoIv3jthnIfB4JvcWPm5BJW6)yndH8rzhXQ7KPJgXIn8Xkb4qZ9eRjHAS(DyDwyTTnwNycFm6iwDNmD0iwSHpwjaNpeRTTXAPuyJ0MuXy9pSw1G9nkmyh20NSalsYjdTvc9YivFMeRQIYabqA(bFbB(gIfNaKd2uujmQgWMWhJob5zOvloFiwBBJ1pI1YS4tC0zTQlOrSyd0QfOJVHyXjS22gRLsHnsBsfJ1)W6hYdShQu9b2EiBkHvGabqAGd(c28nelobihShQu9b20zTmdvQ(mRckG9QGI5gfgSPjiqaKgyGVGnFdXItaYbBkQegvdypuPufB4JvkgI1)W63b2dvQ(aB6SwMHkvFMvbfWEvqXCJcd2qbiasZaWxWMVHyXja5GnfvcJQbShQuQIn8XkfdXAsG1pa2dvQ(aB6SwMHkvFMvbfWEvqXCJcd2cQOpHwTabcqa7qetBfIraFbKsg4lypuP6dSdBP6dS5BiwCcqoqaK(a4lypuP6dST8NWiOrzqpbB(gIfNaKdeaPVd8fS5BiwCcqoyhIy6afJukmytwEG9qLQpWo1EIfBKjeiasFd4lypuP6dSvPrRKQ46mig23CugS5BiwCcqoqaKQAWxWEOs1hyh0pOunNPJMHKmQflWMVHyXja5abqA(bFb7HkvFGTcR0OamD0S80kzsiEuGGnFdXItaYbcG0ah8fS5BiwCcqoyFJcd2djHwdAGMyFIPJMWwfgb2dvQ(a7HKqRbnqtSpX0rtyRcJacG0ad8fS5BiwCcqoyhIy6afJukmytMt1G9qLQpWwqEgA1cytrLWOAa7HkLQydFSsXqSMey9dabqAga(c28nelobihSPOsyunG9qLsvSHpwPyiw)dRFhypuP6dSNsHtgOvlabiGnnbbFbKsg4lyZ3qS4eGCWMIkHr1a2jMWhJol)jmcAug0txQv5W6)y9JynHpgDcYZqRwC(qWEOs1hyB5pHrqJYGEceaPpa(c28nelobihSPOsyunGnT7vQv5COjSsMyHyhIvM6Gy9pSoinH122ynT7vQv5COjSsMyHyhIvM6Gy9pSM29k1QCUPu4KbA1IdXktDqS22gRLsHnsBsfJ1)W6hYdShQu9b2P2tSyJmHabq67aFbB(gIfNaKd2uujmQgWMWhJob5zOvloFiw)hRZgRLsHnsBsfJ1KaRPDVsTkNJGrqg9SUGUKhns1hw)bRtE0ivFyTTnwNnwldkilolEwILlKky9pS(H8WABBS(rSwMfFIJoio6xMPuC8neloH1zH1zH122yTukSrAtQyS(hwt27a7HkvFGnbJGm6zDbbcG03a(c28nelobihSPOsyunGnHpgDcYZqRwC(qS(pwNnwlLcBK2KkgRjbwt7ELAvohXQ7Kj6rb4sE0ivFy9hSo5rJu9H122yD2yTmOGS4S4zjwUqQG1)W6hYdRTTX6hXAzw8jo6G4OFzMsXX3qS4ewNfwNfwBBJ1sPWgPnPIX6Fynz5hShQu9b2eRUtMOhfaqaKQAWxWMVHyXja5GnfvcJQbSj8XOtqEgA1IZhI1)X6SXAPuyJ0MuXynjWAA3RuRY5MJYqbnldDwlxYJgP6dR)G1jpAKQpS22gRZgRLbfKfNfplXYfsfS(hw)qEyTTnw)iwlZIpXrheh9lZuko(gIfNW6SW6SWABBSwkf2iTjvmw)dRjl)G9qLQpWEokdf0Sm0zTacG08d(c28nelobihSPOsyunGnHpgDcYZqRwC(qS(pwNnwlLcBK2KkgRjbwt7ELAvoxSqmXQ7Kl5rJu9H1FW6Khns1hwBBJ1zJ1YGcYIZINLy5cPcw)dRFipS22gRFeRLzXN4OdIJ(LzkfhFdXItyDwyDwyTTnwlLcBK2KkgR)H1zaypuP6dSJfIjwDNacG0ah8fShQu9b2RkOLan5RpfuHpbS5BiwCcqoqaKgyGVGnFdXItaYbBkQegvdyt4Jr3QImXQ7Kdkd9jw)dRFdw)hRFeRj8XOtqEgA1IZhc2dvQ(aBvA0kPkUodIH9nhLbcG0ma8fS5BiwCcqoytrLWOAa7SXA6y43ZuVWyTTnwlLcBK2KkgRjbwt7ELAvoxq)Gs1CMoAgsYOwSCjpAKQpS(dwN8OrQ(W6SW6)yD2ynHpgDcYZqRwC(qS22gRPDVsTkNtqEgA1IdXktDqS(hwtw(X6SWABBSwkf2iTjvmw)dRFhzG9qLQpWoOFqPAothndjzulwabqkz5b(c28nelobihSPOsyunGnT7vQv5CcYZqRwCiwzQdI1)W6ahShQu9b2OkmCXM6mWWHYabqkzKb(c28nelobihSPOsyunG9JynHpgDcYZqRwC(qWEOs1hyRWknkathnlpTsMeIhfiqaKs2dGVGnFdXItaYbBkQegvdyt4JrNG8m0QfhIhQG1)XAcFm6iwDNwEO4q8qfS22gRj8XOtqEgA1IZhI1)XA6y43ZuVWyTTnwNnwNnwt7d6vgIf7cBP6Z0rJ)iqvAXjt0JcaRTTXAAFqVYqSyN)iqvAXjt0JcaRZcR)J1sPWgPnPIX6FyD(jdRTTXAPuyJ0MuXy9pS(H8J1zb2dvQ(a7WwQ(acGuYEh4lyZ3qS4eGCWMIkHr1a2XM6HynjW68Nhw)hRZgRj8XOleX0cYgOvlqxQv5W6)ynT7vQv5COjSsMyHyhIvM6Gy9FSwkf2iTjvmwtcSM29k1QCob5zOvlUKhns1NjONHqS(dwN8OrQ(WABBSwguqwCw8SelxivW6Fy9d5H122y9JyTml(ehDqC0VmtP44BiwCcRZcRTTXAPuyJ0MuXy9pSMmvd2dvQ(aBb5zOvlabiGnuaFbKsg4lypuP6dS53hUAyPk2aTAbS5BiwCcqoqaK(a4lyZ3qS4eGCWMIkHr1a2dvkvXg(yLIHynjWAYa7HkvFGnXGqtqgiasFh4lypuP6dShJIhLyKPJgkQvbc28nelobihiasFd4lyZ3qS4eGCWMIkHr1a2ioIyO1qSyS(pw)iwpuP6ZbzuiFIbk1f0vNjUQGwcypuP6dSHmkKpXaL6cceaPQg8fS5BiwCcqoytrLWOAaBcFm6eKNHwT4sTkhwBBJ1XM6Hy9pSoWZdShQu9b2OjSsMyHyGain)GVGnFdXItaYbBkQegvdyt4JrNG8m0QfNpeR)J1zJ1e(y05pgHQlOrvfS6ZbLH(eRjbw)gS22gRFeRhsYOsyN)yeQUGgvvWQphFdXItyDwyTTnwlLcBK2KkgR)H1KrgypuP6dSjwDNmD0iwSHpwjaGainWbFbB(gIfNaKd2uujmQgW(rSMWhJob5zOvloFiwBBJ1sPWgPnPIX6FyTQb7HkvFGDSPEiNmdjzujSHGhfGainWaFbB(gIfNaKd2uujmQgWMWhJob5zOvloFiw)hRj8XOtzGcJmkd6juzoNpeR)J1pI1e(y0PWknkathnlpTsMeIhfOZhc2dvQ(a7brNJnqRwacG0ma8fS5BiwCcqoytrLWOAaBcFm6eKNHwT48HyTTnwNnwt4JrxQ9el2itOl1QCyTTnwthd)EM6fgRZcR)J1e(y0fIyAbzd0QfOl1QCyTTnwh9RLbXuRbfKnsPWy9pSMoqXiLcJ1)XAA3RuRY5eKNHwT4qSYuheShQu9b2tPWjd0QfGaiLS8aFbB(gIfNaKd2uujmQgWMWhJob5zOvloFiw)hRj8XOtzGcJmkd6juzoNpeR)J1e(y0PWknkathnlpTsMeIhfOZhc2dvQ(a7brNJnqRwacGuYid8fShQu9b2HfJO1f0aTAbS5BiwCcqoqaKs2dGVGnFdXItaYbBkQegvdy)iwt4JrNG8m0QfNpeRTTXAPuyJ0MuXy9pSoWa7HkvFGDOhvXaQlOHynqbiasj7DGVGnFdXItaYbBkQegvdyhBQhI1FW6yt9qhIdYhwhieRdsty9pSo2up0PmVhR)J1e(y0jipdTAXLAvoS(pwNnw)iwNAXr7JYNGgHtM4AuydHhDoeRm1bX6)y9Jy9qLQphTpkFcAeozIRrHD1zIRkOLG1zH122yD0VwgetTguq2iLcJ1)W6G0ewBBJ1YGcYItkf2iTjvmw)dRvnypuP6dSP9r5tqJWjtCnkmqaKs2BaFbB(gIfNaKd2uujmQgWMWhJoetFUyi0eBeLD(qS22gRj8XOdX0NlgcnXgrzdT9NWihug6tS(hwtwEyTTnwlLcBK2KkgR)H1QgShQu9b2IfB8hr7VKj2ikdeaPKPAWxWMVHyXja5GnfvcJQbSj8XOtqEgA1Il1QCy9FSoBSMWhJUqetliBGwTaD(qS(pwNnwhBQhI1KaRFdzyTTnwt4JrNYafgzug0tOYCoFiwNfwBBJ1zJ1XM6HynjWAvNhw)hRhsYOsyxSPEiNmXcXo(gIfNWABBSo2upeRjbwh4QgRZcR)J1zJ10UxPwLZjipdTAXHyLPoiwtcSw1yTTnwhBQhI1KaRdS8W6SWABBSwkf2iTjvmw)dRvnwNfypuP6dSheDo2aTAbiasjl)GVG9qLQpWgk8KcWaTAbS5BiwCcqoqacy7LAvsaGVasjd8fShQu9b202FcJmqRwaB(gIfNaKdeaPpa(c2dvQ(aBiJ4RKamjpuaB(gIfNaKdeaPVd8fShQu9b2WWgXg6Q9jWMVHyXja5abq6BaFb7HkvFGnSBXQUGgvgHrGnFdXItaYbcGuvd(c2dvQ(aByFf1qSgOa28nelobihiasZp4lypuP6dSpwSyKbA10NGnFdXItaYbcG0ah8fShQu9b2uRkFlOrqZLH4Rvjba28nelobihiasdmWxWEOs1hyddlujgOvtFc28nelobihiasZaWxWEOs1hyFJ4rm0eenugS5BiwCcqoqacqaBvXiy1hG0hYJSmiVaJS8d2QmORUGqWoqF(iqqsZqjnqGafwJ1FTySUucBKG1XgH1VDIJJFjVnwJ4meFH4ewdBfgRhV0kJWjSMAnxqg6W5c0QJX63eOW63AFQIrcNW63MHq(OSlF6cKvM8Tr2k11OajhAUNz8TXAPX63oBgc5JYU8PlqwzY3gzRuxJcK(ZqiFu2LpDO5Esc1zmR3gRZMS3NLdNlqRogRvDGcRFR9PkgjCcRFBgc5JYU8PlqwzY3gzRuxJcKCO5EMX3gRLgRF7SziKpk7YNUazLjFBKTsDnkq6pdH8rzx(0HM7jjuNXSEBSoBYEFwoCoCUmuLWgjCcRZpwpuP6dRxfuGoCoWggYuaPpO63a2HOowlgSZiwNHpONqL5GwviwhOZFcJW5YiwBjsimq96vWsS8eoAR8cwk(1ivFu0eLxWsH(cNlJy9MdfwHGry9dQotS(H8ildW5W5Yiw)wTMliddu4CzeRFlyD(iLWAVuRscaRdrvJkjaSwASoFKHfO5W5Yiw)wW6arqgRLsHnsBsfJ1OrSyewlwZH1YGcYItkf2iTjvmwlnwpNu0kCegR5lH1DeRPTcXioCoCUmI1bIFpt9cNWAco2igRPTcXiynbhSoOdRZhukhkqS(67TyniLOFH1dvQ(GyDFRaC4CzeRhQu9bDHiM2keJOoUg4tCUmI1dvQ(GUqetBfIr(O(14dQWNms1hoxgX6HkvFqxiIPTcXiFu)k2DcNlJy9(MqOvlynAQewt4JroH1qzeiwtWXgXynTvigbRj4G1bX65syDiIFlHTi1feRliwN6JD4CzeRhQu9bDHiM2keJ8r9l4nHqRwmqzeio3qLQpOleX0wHyKpQFf2s1ho3qLQpOleX0wHyKpQFz5pHrqJYGEIZLrSoddX0bkyTyvqSEGynpOvay9aX6WgclIfJ1sJ1HTWNuZAfawhCQdRNRflgH10bkyDYJQliwlwmwhRGwIdNBOs1h0fIyARqmYh1VsTNyXgzcZmeX0bkgPuy1KLho3qLQpOleX0wHyKpQFPsJwjvX1zqmSV5Omo3qLQpOleX0wHyKpQFf0pOunNPJMHKmQflCUHkvFqxiIPTcXiFu)sHvAuaMoAwEALmjepkqCUHkvFqxiIPTcXiFu)YdztjSsM3OWQhscTg0anX(ethnHTkmcNBOs1h0fIyARqmYh1VeKNHwTKziIPdumsPWQjZP6mRO6HkLQydFSsXqs8ao3qLQpOleX0wHyKpQFnLcNmqRwYSIQhQuQIn8Xkfd)9oCoCUHkvFqNxQvjbOM2(tyKbA1co3qLQpOZl1QKa(O(fKr8vsaMKhk4CdvQ(GoVuRsc4J6xWWgXg6Q9jCUHkvFqNxQvjb8r9ly3IvDbnQmcJW5gQu9bDEPwLeWh1VG9vudXAGco3qLQpOZl1QKa(O(1XIfJmqRM(eNBOs1h05LAvsaFu)IAv5BbncAUmeFTkjaCUHkvFqNxQvjb8r9lyyHkXaTA6tCUHkvFqNxQvjb8r9RBepIHMGOHY4C4CzeRde)EM6foH1SQyuayTukmwlwmwpuPryDbX6rvtTgIf7W5gQu9bvtN1YmuP6ZSkOK5nkSAVuRsciZkQoXe(y0rhOuxqNp02oXe(y0LkyiVwdXInktWI68H22jMWhJUubd51AiwSHp0eKD(qCUHkvFWpQF5HSPewjZBuy1bNftN1Irqdr3xMvunHpgDcYZqRwC(qB7hLzXN4OZAvxqJyXgOvlqhFdXIt22sPWgPnPI)rwE4CdvQ(GFu)YdztjSsM3OWQhscTg0anX(ethnHTkmkZkQM29k1QCob5zOvloeRm1b)rwGzBlLcBK2Kk(3BYdNBOs1h8J6xEiBkHvY8gfw9aTu1Cm0Ggs2idTrZkZkQMWhJob5zOvloF4)Sj8XOlOFqPAothndjzulwoFOT9JmeYhLD0(s8b5Kzvro2ik7uM8Tro0CpF3F6y43ZuVWzzBNycFm6qdjBKH2OzzsmHpgDPwLZ2wkf2iTjv8VhYdNBOs1h8J6xEiBkHvY8gfwDytFYcSijNm0wj0lJu9zsSQkkNzfv)iHpgDcYZqRwC(W)pYqiFu2rS6oz6OrSydFSsaoLjFBKdn3Z3zBNycFm6iwDNmD0iwSHpwjaNp02wkf2iTjv8pvJZLrS(lkaSwASEvhJ1(qSEOsPQr4ewlO6EYceRvPelS(lYZqRwW5gQu9b)O(LhYMsyfyMvunHpgDcYZqRwC(qB7hLzXN4OZAvxqJyXgOvlqhFdXIt22sPWgPnPI)9qE4CdvQ(GFu)IoRLzOs1NzvqjZBuy10eeNBOs1h8J6x0zTmdvQ(mRckzEJcRgkzwr1dvkvXg(yLIH)Eho3qLQp4h1VOZAzgQu9zwfuY8gfwTGk6tOvlWmRO6HkLQydFSsXqs8aoho3qLQpOJMGQT8NWiOrzqpZSIQtmHpgDw(tye0OmONUuRY9)rcFm6eKNHwT48H4CdvQ(GoAc(r9Ru7jwSrMWmROAA3RuRY5qtyLmXcXoeRm1b)fKMSTPDVsTkNdnHvYele7qSYuh8hT7vQv5CtPWjd0QfhIvM6G22sPWgPnPI)9qE4CdvQ(GoAc(r9lcgbz0Z6cMzfvt4JrNG8m0QfNp8F2sPWgPnPIjbT7vQv5CemcYON1f0L8OrQ((K8OrQ(STZwguqwCw8Selxiv(9qE22pkZIpXrheh9lZuko(gIfNYklBBPuyJ0MuX)i7D4CdvQ(GoAc(r9lIv3jt0JciZkQMWhJob5zOvloF4)SLsHnsBsftcA3RuRY5iwDNmrpkaxYJgP67tYJgP6Z2oBzqbzXzXZsSCHu53d5zB)Oml(ehDqC0VmtP44BiwCkRSSTLsHnsBsf)JS8JZnuP6d6Oj4h1VMJYqbnldDwRmROAcFm6eKNHwT48H)Zwkf2iTjvmjODVsTkNBokdf0Sm0zTCjpAKQVpjpAKQpB7SLbfKfNfplXYfsLFpKNT9JYS4tC0bXr)YmLIJVHyXPSYY2wkf2iTjv8pYYpo3qLQpOJMGFu)kwiMy1DkZkQMWhJob5zOvloF4)SLsHnsBsftcA3RuRY5IfIjwDNCjpAKQVpjpAKQpB7SLbfKfNfplXYfsLFpKNT9JYS4tC0bXr)YmLIJVHyXPSYY2wkf2iTjv8VmaNBOs1h0rtWpQFTQGwc0KV(uqf(eCUHkvFqhnb)O(LknALufxNbXW(MJYzwr1e(y0TQitS6o5GYqF(7n)FKWhJob5zOvloFio3qLQpOJMGFu)kOFqPAothndjzulwzwr1zthd)EM6f22wkf2iTjvmjODVsTkNlOFqPAothndjzulwUKhns13NKhns1xw)ZMWhJob5zOvloFOTnT7vQv5CcYZqRwCiwzQd(JS8NLTTukSrAtQ4FVJmCUHkvFqhnb)O(fQcdxSPodmCOCMvunT7vQv5CcYZqRwCiwzQd(lWX5gQu9bD0e8J6xkSsJcW0rZYtRKjH4rbMzfv)iHpgDcYZqRwC(qCUHkvFqhnb)O(vylvFzwr1e(y0jipdTAXH4Hk)j8XOJy1DA5HIdXdvSTj8XOtqEgA1IZh(Nog(9m1lSTD2zt7d6vgIf7cBP6Z0rJ)iqvAXjt0JcW2M2h0Rmel25pcuLwCYe9OaY6VukSrAtQ4F5NmBBPuyJ0MuX)Ei)zHZnuP6d6Oj4h1VeKNHwTKzfvhBQhsI8N3)Sj8XOleX0cYgOvlqxQv5(t7ELAvohAcRKjwi2HyLPo4FPuyJ0MuXKG29k1QCob5zOvlUKhns1NjONHWpjpAKQpBBzqbzXzXZsSCHu53d5zB)Oml(ehDqC0VmtP44BiwCklBBPuyJ0MuX)it14C4CdvQ(GoOOMFF4QHLQyd0QfCUHkvFqhu(O(fXGqtqoZkQEOsPk2WhRumKeKHZnuP6d6GYh1VgJIhLyKPJgkQvbIZnuP6d6GYh1VGmkKpXaL6cMzfvJ4iIHwdXI))4qLQphKrH8jgOuxqxDM4QcAj4CdvQ(GoO8r9l0ewjtSqCMvunHpgDcYZqRwCPwLZ2o2up8xGNhoxgX6kQMWhJob5zOvloF4)Sj8XOZFmcvxqJQky1Ndkd9jjEJT9JdjzujSZFmcvxqJQky1NJVHyXPSSTLbfKfNukSrAtQ4FKrgo3qLQpOdkFu)Iy1DY0rJyXg(yLaYSIQj8XOtqEgA1IZh(pBcFm68hJq1f0OQcw95GYqFsI3yB)4qsgvc78hJq1f0OQcw954BiwCklBBPuyJ0MuX)iJmCUHkvFqhu(O(vSPEiNmdjzujSHGhLmRO6hj8XOtqEgA1IZhABlLcBK2Kk(NQX5gQu9bDq5J6xdIohBGwTKzfvt4JrNG8m0QfNp8pHpgDkduyKrzqpHkZ58H)FKWhJofwPrby6Oz5PvYKq8OaD(qCUHkvFqhu(O(1ukCYaTAjZkQMWhJob5zOvloFOTD2e(y0LApXInYe6sTkNTnDm87zQx4S(t4JrxiIPfKnqRwGUuRYzBh9RLbXuRbfKnsPW)OdumsPW)PDVsTkNtqEgA1IdXktDqCUHkvFqhu(O(1GOZXgOvlzwr1e(y0jipdTAX5d)t4JrNYafgzug0tOYCoF4FcFm6uyLgfGPJMLNwjtcXJc05dX5gQu9bDq5J6xHfJO1f0aTAbNBOs1h0bLpQFf6rvmG6cAiwduYSIQFKWhJob5zOvloFOTTukSrAtQ4Fbgo3qLQpOdkFu)I2hLpbncNmX1OWzwr1XM6HFIn1dDioiFbcdst)In1dDkZ7)t4JrNG8m0QfxQv5(N9JPwC0(O8jOr4KjUgf2q4rNdXktDW)pouP6Zr7JYNGgHtM4AuyxDM4QcAjzzBh9RLbXuRbfKnsPW)cst22YGcYItkf2iTjv8pvJZnuP6d6GYh1Vel24pI2FjtSruoZkQMWhJoetFUyi0eBeLD(qBBcFm6qm95IHqtSru2qB)jmYbLH(8hz5zBlLcBK2Kk(NQX5gQu9bDq5J6xdIohBGwTKzfvt4JrNG8m0QfxQv5(NnHpgDHiMwq2aTAb68H)Zo2upKeVHmBBcFm6ugOWiJYGEcvMZ5dZY2o7yt9qsO68(pKKrLWUyt9qozIfID8nelozBhBQhsIax1z9pBA3RuRY5eKNHwT4qSYuhKeQ22o2upKebwEzzBlLcBK2Kk(NQZcNBOs1h0bLpQFbfEsbyGwTGZHZnuP6d6eurFcTAbQMyqOjiJZnuP6d6eurFcTAb(r9l(9HRgwQInqRwW5gQu9bDcQOpHwTa)O(1ukCYaTAjZkQMWhJobv0NgOvlqNp8pDm87zQx4)e(y0LApXInYe68H4CdvQ(Gobv0NqRwGFu)cnHvYeleNzfvt4JrNGk6td0QfOZh(p7HKmQe2fBQhYjtSqSJVHyXjB7HKmQe2vNrSydYkaXsXHM7jjiZ2EijJkHDqpkyDbnqRwGo(gIfNSTLzXN4GcIhLvDSJVHyXPSW5gQu9bDcQOpHwTa)O(1ukCYaTAjZkQMWhJobv0NgOvlqNp8F2e(y0fIyAbzd0QfOl1QC220UxPwLZnLcNmqRwCr)Azqm1AqbzJuk8VHkvFUPu4KbA1IJoqXiLcBBt4JrNG8m0QfNpmlCUHkvFqNGk6tOvlWpQFHMWkzIfIZSIQj8XOtqf9PbA1c05dX5gQu9bDcQOpHwTa)O(LIFjf0QLmROAcFm6eurFAGwTaDPwLZ2MWhJUqetliBGwTaD(W)ps4JrNG8m0QfNp02o2upKebEE4CdvQ(Gobv0NqRwGFu)k2upKtMHKmQe2qWJco3qLQpOtqf9j0Qf4h1Vc9OkgqDbneRbk4CdvQ(Gobv0NqRwGFu)I2hLpbncNmX1OW4CdvQ(Gobv0NqRwGFu)Iy1DY0rJyXg(yLaW5gQu9bDcQOpHwTa)O(LyXg)r0(lzInIYzwr1e(y0Hy6ZfdHMyJOSZhABt4JrhIPpxmeAInIYgA7pHroOm0N)ilpCUHkvFqNGk6tOvlWpQFfwmIwxqd0QfCUHkvFqNGk6tOvlWpQFngfpkXithnuuRceNBOs1h0jOI(eA1c8J6xqgfYNyGsDbZSIQrCeXqRHyX)FCOs1NdYOq(eduQlORotCvbTeCUHkvFqNGk6tOvlWpQFbfEsbyGwTaeGaa]] )


end