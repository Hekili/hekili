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


    spec:RegisterPack( "Marksmanship", 20190217.0008, [[dyuOOaqiGkpsIInrrzuaHtbe9kLkZsIQBrbYUO0VKidJc6yuOwMGYZukLPjrjxJcyBuG6BavzCaj5CajwNsPQ5rcDpkY(asDqGQQfcuEOsPsxKIQuBuIsXiPOkoPeLQwPGmtjkvUjqvzNkvnukQQLcKupvjtvP4QsukTxv(RqdMuhw0IrXJr1KLYLj2mGptIgnkDAQwTsPIxtcMTKUnjTBq)wXWLWXPOkz5q9CvnDKRlvBNIkFxq14vkX5PqwVsjnFb2pKpJVn3QLKC7dZqJbfddZyWZAOHgckgg2TiJkKBvKCfsLYTGPQClWxIv4vt4Z6f3QinQoz72CRF6yUCRYG0Sev8BFPskDITZy5JAP3v71K8bYXjav6DvEjM6WuIbinOMyUsf4bWRYxY8XcOo92xY8b1rZthscoc(sScVAcFwVW(Uk)wmDVsL9WJ5wTKKBFygAmOyyygdEwdn0qqXqJVv2j2bFRLRUDVfR3Ac8yUvtE(Tkdsd(sScVAcFwVaPnpDijyuOYG0Sev8BFPskDITZy5JAP3v71K8bYXjav6DvEjM6WuIbinOMyUsf4bWRYxY8XcOo92xY8b1rZthscoc(sScVAcFwVW(UkhfQmiDzJWG7j2iK2yWRCKomdnguqAdcPn0WT3qqfkekuzq6TlBcvk)2JcvgK2GqAWFRH0DYRozesxG9b7Krinnin438l7SOqLbPniKUS9fKMCvjstS5csJtIvWinXMqKMsSsHSKRkrAInxqAAq6eso3lssqAb2q6baP5Jkts2Bv9N(BZTiSZv4zh6Vn3EJVn3k5KpWBXKyCQuULatMQ0oWo62h2T5wjN8bElzlf15DZjXNDOBjWKPkTdSJU9B72ClbMmvPDGDlo2jb75Ty6aawc7CfIp7qVTxG0MH0GaPZTkyNelWW7V0IaowScmzQsdPdcq6CRc2jX6WiXkrmRreRQfNqfqAqJ0gJ0bbiDUvb7Ky)owPdvgF2HERatMQ0q6GaKMYQaj7tyjvRouScmzQsdPb5Tso5d8w4SWBrahlhD7lRBZTeyYuL2b2T4yNeSN3IPdayjSZvi(Sd92EbsBgsdcKMPdaylWc3Fj(Sd922eoePdcqA(m12eo0MUQ0Ip7qwGETgXcNnXkLi5QcsRisNCYhOnDvPfF2HS88Pi5QcsdYBLCYh4TsxvAXNDOJU9g42ClbMmvPDGDlo2jb75Ty6aawc7CfIp7qVTxCRKt(aVfol8weWXYr3Ed(2ClbMmvPDGDlo2jb75Ty6aawc7CfIp7qVTnHdr6GaKMPdaylWc3Fj(Sd92EbsheG0adV)inOrAWZWBLCYh4Tu7vYF2Ho62dE3MBLCYh4TkCbZDOY4Zo0TeyYuL2b2r3Eq1T5wjN8bERmQ2XnbhhGihpH)3sGjtvAhyhD7bLBZTeyYuL2b2T4yNeSN3clay5ztMQG0MH0GdPto5d0(cUqGu8jhQ06Wiq1vYs3k5KpWB9cUqGu8jhQ8OBVXgEBUvYjFG36jjBgfF2HULatMQ0oWo6OB1eGSxPBZT34BZTeyYuL2b2T4yNeSN3QjmDaalpFYHkT9cKoiaPBcthaW28VqQ1KPkr1uPZT9cKoiaPBcthaW28VqQ1KPkrbItLITxCRKt(aVfpR1yYjFGXQ)0TQ(tryQk3QtE1jJo62h2T5wcmzQs7a7wCStc2ZBX0baSeUlp7q2EbsheG0GdPPSkqYYZA1HkJeReF2HERatMQ0q6GaKMCvjstS5csRishMH3k5KpWB1Fj6KO(hD732T5wcmzQs7a7wjN8bElEwRXKt(aJv)PBv9NIWuvUfV9hD7lRBZTeyYuL2b2T4yNeSN3k5KBojkqr1LhPveP32Tso5d8w8SwJjN8bgR(t3Q6pfHPQCRNo62BGBZTeyYuL2b2T4yNeSN3k5KBojkqr1LhPbnsh2Tso5d8w8SwJjN8bgR(t3Q6pfHPQClc7CfE2H(Jo6wfyHpQmjDBU9gFBULatMQ0oWo62h2T5wcmzQs7a7OB)2Un3sGjtvAhyhD7lRBZTeyYuL2b2r3EdCBUvYjFG3QyiFG3sGjtvAhyhD7n4BZTso5d8wSDij4pQMyfULatMQ0oWo62dE3MBjWKPkTdSBvGfE(uKCv5wgB4Tso5d8wTPZuLiLfhD7bv3MBjWKPkTdSBvGfE(uKCv5wgBnWTso5d8weUlp7q3IJDsWEERKtU5KOafvxEKg0iDyhD7bLBZTeyYuL2b2T4yNeSN3k5KBojkqr1LhPveP32Tso5d8wPRkT4Zo0rhDlE7Vn3EJVn3sGjtvAhy3IJDsWEERMW0baSSDij4pQMyfSTjCisBgsdoKMPdayjCxE2HS9IBLCYh4Ty7qsWFunXkC0TpSBZTeyYuL2b2T4yNeSN3IptTnHdT4SWBrahlwSOMo8rAfrAL8Mvn3csheG0KRkrAInxqAfr6Wm8wjN8bER20zQsKYIJU9B72ClbMmvPDGDlo2jb75Ty6aawc3LNDiBVaPndPbbstUQePj2CbPbnsZNP2MWHwgb)cwbhQ0264K8bI07q6whNKpqKoiaPbbstjwPqwwjReRTGtiTIiDygI0bbin4qAkRcKS8ela9AmDvRatMQ0qAqI0GePdcqAYvLinXMliTIiTXB7wjN8bElgb)cwbhQ8OBFzDBULatMQ0oWUfh7KG98wmDaalH7YZoKTxG0MH0GaPjxvI0eBUG0GgP5ZuBt4qltDMweOJnY264K8bI07q6whNKpqKoiaPbbstjwPqwwjReRTGtiTIiDygI0bbin4qAkRcKS8ela9AmDvRatMQ0qAqI0GePdcqAYvLinXMliTIiTXg8Tso5d8wm1zArGo2OJU9g42ClbMmvPDGDlo2jb75Ty6aawc3LNDiBVaPndPbbstUQePj2CbPbnsZNP2MWH2eYLNWznYZA1264K8bI07q6whNKpqKoiaPbbstjwPqwwjReRTGtiTIiDygI0bbin4qAkRcKS8ela9AmDvRatMQ0qAqI0GePdcqAYvLinXMliTIiTXg8Tso5d8wjKlpHZAKN16r3Ed(2ClbMmvPDGDlo2jb75Ty6aawc3LNDiBVaPndPbbstUQePj2CbPbnsZNP2MWHwahlm1zA2whNKpqKEhs364K8bI0bbiniqAkXkfYYkzLyTfCcPvePdZqKoiaPbhstzvGKLNybOxJPRAfyYuLgsdsKgKiDqastUQePj2CbPvePbLBLCYh4TaCSWuNPD0Th8Un3k5KpWBvDLS0h3o9Msvbs3sGjtvAhyhD7bv3MBjWKPkTdSBXXojypVfthaWs4U8SdzXsYjK2mKMPdayzQZ0Q9NSyj5esheG0mDaalH7YZoKTxG0MH08mkBr4Dsq6GaKMCvjstS5csRishMbUvYjFG3QyiFGhD7bLBZTeyYuL2b2T4yNeSN3IptTnHdT4SWBrahlwSOMo8rAZqAYvLinXMlinOrA(m12eo0s4U8SdzBDCs(aJk7Y)i9oKU1Xj5dePdcqAqG0uIvkKLvYkXAl4esRishMHiDqasdoKMYQajlpXcqVgtx1kWKPknKgKiDqastUQePj2CbPvePn2a3k5KpWBr4U8SdD0r36PBZT34BZTso5d8wYwkQZ7MtIp7q3sGjtvAhyhD7d72ClbMmvPDGDlo2jb75Tso5MtIcuuD5rAqJ0gFRKt(aVftIXPs5OB)2Un3k5KpWBLr1oUj44ae54j8)wcmzQs7a7OBFzDBULatMQ0oWUfh7KG98wybalpBYufK2mKgCiDYjFG2xWfcKIp5qLwhgbQUsw6wjN8bERxWfcKIp5qLhD7nWT5wcmzQs7a7wCStc2ZBbm8(J0kI0gWqKoiaPz6aawhgjwjIznIyvTyrnD4J0kI0jN8bAXzH3IaowS88Pi5QYTso5d8w4SWBrahlhD7n4BZTeyYuL2b2T4yNeSN3IPdayvZNeCunXk8Qj02lqAZqAMoaGLWD5zhY2lqAZqAGH3FKEhsZZNIyrParAfrAGH3FRAULBLCYh4TsmpHs8zh6OBp4DBULatMQ0oWUfh7KG98wGaPbhsZ0baSTPZuLiLf2EbsheG08mkBr4Dsq6GaKgein4q6CRc2jXcm8(lTiGJfRatMQ0qAZqAWH05wfStI97yLouz8zh6TcmzQsdPndPbhstzvGK9jSKQvhkwbMmvPH0GePbjsBgsZ0baSfyH7VeF2HEBBchI0bbinFMABchAtxvAXNDilqVwJyHZMyLsKCvbPvePto5d0MUQ0Ip7qwE(uKCvbPdcqAMoaGLWD5zhY2lUvYjFG3kDvPfF2Ho62dQUn3sGjtvAhy3IJDsWEElGH3FKEhsZZNIyrParAfrAGH3FRAUfKoiaPZTkyNelWW7V0IaowScmzQsdPdcq6CRc2jX6WiXkrmRreRQfNqfqAqJ0gJ0bbiDUvb7Ky)owPdvgF2HERatMQ0q6GaKMYQaj7tyjvRouScmzQs7wjN8bElCw4TiGJLJU9GYT5wjN8bERcxWChQm(SdDlbMmvPDGD0T3ydVn3sGjtvAhy3IJDsWEElGH3FKg0in4zaKoiaPbbsZ0baSfyH7VeF2HEBVaPdcqAGH3FKg0iDzzaK2mKMptTnHdTeUlp7qwSOMo8rAZqAYvLinXMliTIiDygaPbjsBgsZ0baSeUlp7q22eoePdcqAYvLinXMliTIiTbUvYjFG3kX8ekXNDOJU9gB8T5wjN8bERNKSzu8zh6wcmzQs7a7OJUvN8QtgDBU9gFBUvYjFG3IpDij44Zo0TeyYuL2b2r3(WUn3k5KpWB9cwGozuS1F6wcmzQs7a7OB)2Un3k5KpWB9fdwI860B3sGjtvAhyhD7lRBZTso5d8w)meRdvgdpjbFlbMmvPDGD0T3a3MBLCYh4T(b68itnF6wcmzQs7a7OBVbFBUvYjFG3ckeRGJp7Wv4wcmzQs7a7OBp4DBUvYjFG3IZ6Bh)JeoHMxDV6Kr3sGjtvAhyhD7bv3MBLCYh4T(ch7u8zhUc3sGjtvAhyhD7bLBZTso5d8wWK6y5JkXjxULatMQ0oWo6OJUL5e87d82hMHgdkggMXgBnEBBBB3k8edDOY)wL9QfdMKgsBWiDYjFGiD1F6TOq36le(Tpmduw3QapaEvUvzqAWxIv4vt4Z6fiT5PdjbJcvgKMLOIF7lvsPtSDglFul9UAVMKpqoobOsVRYlXuhMsmaPb1eZvQapaEv(sMpwa1P3(sMpOoAE6qsWrWxIv4vt4Z6f23v5OqLbPlBegCpXgH0gdELJ0HzOXGcsBqiTHgU9gcQqHqHkdsVDztOs53EuOYG0gesd(BnKUtE1jJq6cSpyNmcPPbPb)MFzNffQmiTbH0LTVG0KRkrAInxqACsScgPj2eI0uIvkKLCvjstS5cstdsNqY5ErscslWgspainFuzsYIcHcvgK28ElcVtsdPzeGblinFuzscPzeLo8Tin4NZLc6rA4ani2eRc0RiDYjFGpspWQrwuOKt(aFBbw4JktsMaQ5RakuYjFGVTal8rLjPDMkLDLQcKsYhikuYjFGVTal8rLjPDMkbmtdfQmi9cMfp7qino9gsZ0baKgs)uspsZiadwqA(OYKesZikD4J0jSH0fyXGkgICOsK2FKUnqXIcLCYh4BlWcFuzsANPspmlE2HIpL0JcLCYh4BlWcFuzsANPsfd5defk5KpW3wGf(OYK0otLy7qsWFunXkGcvgK28XcpFcPjw)r68rAjXvJq68r6I5FNPkinniDXqcK8SwncPvMoePt4qScgP55tiDRJDOsKMyfKgWvYswuOKt(aFBbw4Jkts7mvQnDMQePSO8cSWZNIKRkMm2quOKt(aFBbw4Jkts7mvIWD5zhQ8cSWZNIKRkMm2AGYDatjNCZjrbkQU8GomuOKt(aFBbw4Jkts7mvkDvPfF2Hk3bmLCYnNefOO6YR42qHqHso5d8TDYRozKj(0HKGJp7qOqjN8b(2o5vNmANPsVGfOtgfB9NqHso5d8TDYRoz0otL(IblrED6nuOKt(aFBN8QtgTZuPFgI1HkJHNKGrHso5d8TDYRoz0otL(b68itnFcfk5KpW32jV6Kr7mvckeRGJp7Wvafk5KpW32jV6Kr7mvIZ6Bh)JeoHMxDV6KrOqjN8b(2o5vNmANPsFHJDk(SdxbuOKt(aFBN8QtgTZujysDS8rL4KlOqOqLbPnV3IW7K0qAXCc2iKMCvbPjwbPtonyK2FKonx61KPkwuOKt(aFt8SwJjN8bgR(tLdtvXuN8QtgvUdyQjmDaalpFYHkT9IGGMW0baSn)lKAnzQsunv6CBViiOjmDaaBZ)cPwtMQefiovk2Ebkekuzq6nyJqAAq6QdfKUxG0jNCZLK0qAc7qfe6r6WDIfP3G7YZoekuYjFG)otL6VeDsu)YDatmDaalH7YZoKTxeeaokRcKS8SwDOYiXkXNDO3kWKPkTGaYvLinXMlkgMHOqjN8b(7mvIN1Am5KpWy1FQCyQkM4Thfk5KpWFNPs8SwJjN8bgR(tLdtvX0tL7aMso5MtIcuuD5vCBOqjN8b(7mvIN1Am5KpWy1FQCyQkMiSZv4zh6l3bmLCYnNefOO6Yd6WqHqHso5d8T82BITdjb)r1eRq5oGPMW0baSSDij4pQMyfSTjCOzGJPdayjCxE2HS9cuOKt(aFlV97mvQnDMQePSOChWeFMABchAXzH3IaowSyrnD4ROsEZQMBjiGCvjstS5IIHzikuYjFGVL3(DMkXi4xWk4qLL7aMy6aawc3LNDiBVWmqqUQePj2Cb08zQTjCOLrWVGvWHkTToojFG7ADCs(adcabLyLczzLSsS2coPyyggeaokRcKS8ela9AmDvRatMQ0ajidcixvI0eBUOOXBdfk5KpW3YB)otLyQZ0IaDSrL7aMy6aawc3LNDiBVWmqqUQePj2Cb08zQTjCOLPotlc0XgzBDCs(a3164K8bgeackXkfYYkzLyTfCsXWmmiaCuwfiz5jwa61y6QwbMmvPbsqgeqUQePj2CrrJnyuOKt(aFlV97mvkHC5jCwJ8Swl3bmX0baSeUlp7q2EHzGGCvjstS5cO5ZuBt4qBc5Yt4Sg5zTABDCs(a3164K8bgeackXkfYYkzLyTfCsXWmmiaCuwfiz5jwa61y6QwbMmvPbsqgeqUQePj2CrrJnyuOKt(aFlV97mvcWXctDMw5oGjMoaGLWD5zhY2lmdeKRkrAInxanFMABchAbCSWuNPzBDCs(a3164K8bgeackXkfYYkzLyTfCsXWmmiaCuwfiz5jwa61y6QwbMmvPbsqgeqUQePj2Crrqbfk5KpW3YB)otLQUsw6JBNEtPQajuOKt(aFlV97mvQyiFGL7aMy6aawc3LNDilwsozgthaWYuNPv7pzXsYPGaMoaGLWD5zhY2lmJNrzlcVtsqa5QsKMyZffdZaOqjN8b(wE73zQeH7YZou5oGj(m12eo0IZcVfbCSyXIA6W3mYvLinXMlGMptTnHdTeUlp7q2whNKpWOYU8)UwhNKpWGaqqjwPqwwjReRTGtkgMHbbGJYQajlpXcqVgtx1kWKPknqgeqUQePj2CrrJnakekuYjFGV9jtYwkQZ7MtIp7qOqjN8b(2N2zQetIXPsPChWuYj3CsuGIQlpOngfk5KpW3(0otLYOAh3eCCaIC8e(JcLCYh4BFANPsVGleifFYHkl3bmHfaS8SjtvmdCjN8bAFbxiqk(KdvADyeO6kzjuOKt(aF7t7mvcNfElc4yPChWeWW7VIgWWGaMoaG1HrIvIywJiwvlwuth(kMCYhOfNfElc4yXYZNIKRkOqjN8b(2N2zQuI5juIp7qL7aMy6aaw18jbhvtScVAcT9cZy6aawc3LNDiBVWmGH3)D88PiwukqfbgE)TQ5wqHso5d8TpTZuP0vLw8zhQChWeiahthaW2MotvIuwy7fbb8mkBr4Dsccab4YTkyNelWW7V0IaowScmzQsZmWLBvWoj2VJv6qLXNDO3kWKPknZahLvbs2NWsQwDOyfyYuLgibPzmDaaBbw4(lXNDO32MWHbb8zQTjCOnDvPfF2HSa9AnIfoBIvkrYvffto5d0MUQ0Ip7qwE(uKCvjiGPdayjCxE2HS9cuOKt(aF7t7mvcNfElc4yPChWeWW7)oE(uelkfOIadV)w1Clbb5wfStIfy49xArahlwbMmvPfeKBvWojwhgjwjIznIyvT4eQaOnoii3QGDsSFhR0HkJp7qVvGjtvAbbuwfizFclPA1HIvGjtvAOqjN8b(2N2zQuHlyUdvgF2HqHso5d8TpTZuPeZtOeF2Hk3bmbm8(dAWZabbGGPdaylWc3Fj(Sd92ErqaWW7pOlldygFMABchAjCxE2HSyrnD4Bg5QsKMyZffdZaG0mMoaGLWD5zhY2MWHbbKRkrAInxu0aOqjN8b(2N2zQ0ts2mk(SdHcHcLCYh4BjSZv4zh6nXKyCQuqHso5d8Te25k8Sd97mvs2srDE3Cs8zhcfk5KpW3syNRWZo0VZujCw4TiGJLYDatmDaalHDUcXNDO32lmde5wfStIfy49xArahlwbMmvPfeKBvWojwhgjwjIznIyvT4eQaOnoii3QGDsSFhR0HkJp7qVvGjtvAbbuwfizFclPA1HIvGjtvAGefk5KpW3syNRWZo0VZuP0vLw8zhQChWethaWsyNRq8zh6T9cZabthaWwGfU)s8zh6TTjCyqaFMABchAtxvAXNDilqVwJyHZMyLsKCvrXKt(aTPRkT4ZoKLNpfjxvajkuYjFGVLWoxHNDOFNPs4SWBrahlL7aMy6aawc7CfIp7qVTxGcLCYh4BjSZv4zh63zQKAVs(Zou5oGjMoaGLWoxH4Zo0BBt4WGaMoaGTalC)L4Zo0B7fbbadV)Gg8mefk5KpW3syNRWZo0VZuPcxWChQm(SdHcLCYh4BjSZv4zh63zQugv74MGJdqKJNWFuOKt(aFlHDUcp7q)otLEbxiqk(KdvwUdyclay5ztMQyg4so5d0(cUqGu8jhQ06Wiq1vYsOqjN8b(wc7CfE2H(DMk9KKnJIp7qhD0Da]] )
end