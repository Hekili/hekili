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


    spec:RegisterPack( "Marksmanship", 20181230.2115, [[duKSJaqijbpIssBIsQrjj0PKe5vqHzrPQBbfXUi1VeWWOu5yqPwMKKNbf10KeLRrjX2eOQVbcPXHkLoNaLADGqzEssDpkX(ajoiielek5HOsHjkqrDrbkXgfOiJevk6KcuOvsPCtqOANGudvsuTubQ8uPmvq0vfOK2Rs)vQgmfhMQfdQhtYKf6YiBwv9zuXOHQtlA1cuWRrLmBjUnQA3a)wLHlOLd55kMoX1vLTdc(Uaz8qr68Os16bjnFj1(r5f7fYTfDHwORYoS5wSRcZ2PRcBSTcMRABc3dPTf6kUCo02aopTniUJ4A4DWGNHBl05E584c52M7Hu02SkZGls4aXceGtk4pyT64dmj)R4sEafY)sGj5vbGlhCa4VJjrccbcr3pl0eOYruW5zCcu5bxNB(acH6qChX1W7Gbpd1tYR2g8llsWiyH3w0fAHUk7WMBXUkmBNUkSX2kyg7T5pb)qBRL8CJTHNXibw4TfPrTnRYmqChX1W7GbpdzgU5dieIzZQmdUiHdelqaoPG)G1QJpWK8VIl5bui)lbMKxfaUCWbG)oMejieieD)SqtGkhrbNNXjqLhCDU5dieQdXDexdVdg8mupjVIzZQmtWmPiEycXmy2o7zMQSdBULzWeMPkSHyyxzmBmBwLz4g4oGdnqmMnRYmycZarIrkYmCJ7becXmn8t0mBwLzWeMbIeJuKzcopmJmtWuIiM5GaHygisYtrMPHFcZKFMH73JzCeXm8hesahnZMvzgmHzcwhIzKKN6Y1JjXmixWjeZi4oGzehXHeTK8uxUEmjMroMXbsQYqxiMHarM5(mJ64HDrVTsoYSqUnbLkUg8tMfYfASxi3MRK8aBd2riNdTnc4WfkUyTYcDvlKBZvsEGTryAy5MecuFWpzBeWHluCXALfAmVqUnc4WfkUyTnfkfcL(2GF)VwqPIR(GFYOFHmJ1mtfzghQekfs)p1BOy)NistahUqrMPUMzCOsOuiDc6co1r4CxW51ihWfZafMbBMPUMzCOsOui98qCsaN(GFYOjGdxOiZuxZmIxiGOhbroFjbKMaoCHImtL2MRK8aBd5HzS)teTYcDLTqUnc4WfkUyTnfkfcL(2GF)VwqPIR(GFYOFHmJ1md87)1HisLd1h8tgD8ccSnxj5b2MN8uSp4NSYcTvwi3gbC4cfxS2McLcHsFBWV)xlOuXvFWpz0VWT5kjpW2qEyg7)erRSqh8lKBJaoCHIlwBtHsHqPVn43)RfuQ4Qp4Nm64feGzQRzg43)RdrKkhQp4Nm6xiZuxZm)t9gMbkmde1UT5kjpW24Ffjh8twzHgIUqUnxj5b2wysivc40h8t2gbC4cfxSwzHMBxi3MRK8aBZ78puKq973vOlOzBeWHluCXALf6G9c52iGdxO4I12uOuiu6BdrFen4oCHygRzMkWmUsYdOhcfsaPpsc4Otq)xso4Y2CLKhyBdHcjG0hjbCwzHgB7wi3MRK8aBBeYJCVp4NSnc4WfkUyTYkBlsF)vKfYfASxi3MRK8aBtDpGqO(GFY2iGdxO4I1kl0vTqUnxj5b22BOEke)Snc4WfkUyTYcnMxi3gbC4cfxS2MRK8aBt5Ls3vsEGEjhzBLCKoW5PTPIZkl0v2c52iGdxO4I12uOuiu6BZvscbQtaIpPHzQMzW82CLKhyBkVu6UsYd0l5iBRKJ0bopTTrwzH2klKBJaoCHIlwBtHsHqPVnxjjeOobi(KgMbkmtvBZvsEGTP8sP7kjpqVKJSTsosh4802euQ4AWpzwzLTfIi1Xd7Yc5cn2lKBJaoCHIlwRSqx1c52iGdxO4I1kl0yEHCBeWHluCXALf6kBHCBeWHluCXABkukek9T5kjHa1jaXN0WmvZmyEBUsYdST5XZFGEijRSqBLfYTrahUqXfRvwOd(fYT5kjpW2cpjpW2iGdxO4I1kl0q0fYT5kjpW2WFaHqtN3rCTnc4WfkUyTYcn3UqUnc4WfkUyTTqeP8r6sYtBdB72MRK8aBlEp4c1fpCLf6G9c52iGdxO4I12crKYhPljpTnS1wzBUsYdSnb9Ob)KTPqPqO03MRKecuNaeFsdZafMPQvwOX2UfYTrahUqXfRTPqPqO03MRKecuNaeFsdZunZG5T5kjpW28KNI9b)KvwzBQ4SqUqJ9c52iGdxO4I12uOuiu6BlsWV)xJ)acHMoVJ4shVGaBZvsEGTH)acHMoVJ4ALf6Qwi3gbC4cfxS2McLcHsFBsYtD56XKyMQzgSTcZuxZmQ7kXliG2tEk2h8t0iI3tWWmvZmCurMXAMPImd87)1c6rd(j6xiZuxZmvGzeVqarR8sjbC6co1h8tgnbC4cfzMkXmwZmvKzQaZ4qLqPq65H4Kao9b)KrtahUqrMXAMPcmJ4fci6rqKZxsaPjGdxOiZynZubMXHkHsH0)t9gk2)jI0eWHluKzQ02CLKhyBX7bxOU4HRSqJ5fYTrahUqXfRTPqPqO03M6Us8ccOrEyg7)erAeX7jyyMQzgoQiZynZurMb(9)Ab9Ob)e9lKzQRzMkWmIxiGOvEPKaoDbN6d(jJMaoCHImtLygRzMkYmoujukKEEiojGtFWpz0eWHluKzQRzgXleq0JGiNVKastahUqrMPUMzCOsOui9)uVHI9FIinbC4cfzMkTnxj5b2w8EWfQlE4kl0v2c52iGdxO4I12uOuiu6BtDxjEbb0c6rd(jAeX7jyygOWmbVDBZvsEGTbtOHqCLaoRSqBLfYTrahUqXfRTPqPqO03M6Us8ccOf0Jg8t0iI3tWWmqHzWSDBZvsEGTbxUl2)pe3xzHo4xi3gbC4cfxS2McLcHsFBQ7kXliGwqpAWprJiEpbdZafMbZ2Tnxj5b2Mdu0iiV0vEPSYcneDHCBeWHluCXABkukek9TPUReVGaAb9Ob)enI49emmduygmB32CLKhyB)erWL7IRSqZTlKBZvsEGTvso4Y0dgEro8eq2gbC4cfxSwzHoyVqUnc4WfkUyTnfkfcL(2GF)VwqpAWprJixjmJ1md87)1WL7IL3iAe5kHzQRzg43)Rf0Jg8t0VqMXAMrCehs04KxeCDOsyMQzMQSJzSMzeVqarRCe9FLUN8Ac4WfkYm11mJK8uxUEmjMPAMPkRSnxj5b2w4j5bwzHgB7wi3gbC4cfxS2McLcHsFBWV)xdxUlwEJOFHmtDnZijp1LRhtIzGcZOUReVGaAb9Ob)eD8HCjpqNZJMHzWGzIpKl5byM6AMPImJ4ioKOXjVi46qLWmvZmvzhZuxZmvGzeVqarRCe9FLUN8Ac4WfkYmvIzQRzgj5PUC9ysmt1md2wzBUsYdSnb9Ob)KvwzBJSqUqJ9c52CLKhyBeMgwUjHa1h8t2gbC4cfxSwzHUQfYTrahUqXfRTPqPqO03MRKecuNaeFsdZafMb7T5kjpW2GDeY5qRSqJ5fYT5kjpW28o)dfju)(Df6cA2gbC4cfxSwzHUYwi3gbC4cfxS2McLcHsFBi6JOb3HleZynZubMXvsEa9qOqci9rsahDc6)sYbx2MRK8aBBiuibK(ijGZkl0wzHCBeWHluCXABkukek9T9p1ByMQzgRyhZynZurMb(9)A4YDXYBe9lKzSMzGF)VwqpAWpr)czM6AMb(9)Ab9Ob)eD8ccWmvABUsYdSnKhMX(pr0kl0b)c52iGdxO4I12uOuiu6Bd(9)AEFec15DexdVd0VqMXAMb(9)Ab9Ob)e9lKzSMz(N6nmdgmJYhPJioeGzQMz(N6nAEht3MRK8aBZrkhq9b)KvwOHOlKBJaoCHIlwBtHsHqPVn43)R5piq8eq0VqMXAMPImZ)uVHzWGzu(iDeXHamt1mZ)uVrZ7ykZuxZmoujukK(FQ3qX(prKMaoCHImtDnZ4qLqPq6e0fCQJW5UGZRroGlMbkmd2mtDnZ4qLqPq65H4Kao9b)KrtahUqrMPUMzeVqarpcIC(scinbC4cfzMkTnxj5b2gYdZy)NiALfAUDHCBeWHluCXABkukek9Tb)(FDiIu5q9b)KrhVGamtDnZOUReVGaAp5PyFWpr)FLshrkChXH6sYtmt1mJRK8aAp5PyFWprR8r6sYtmtDnZa)(FTGE0GFI(fUnxj5b2MN8uSp4NSYcDWEHCBeWHluCXABkukek9T9p1BygmygLpshrCiaZunZ8p1B08oMYm11mJdvcLcP)N6nuS)tePjGdxOiZuxZmoujukKobDbN6iCUl48AKd4IzGcZGnZuxZmoujukKEEiojGtFWpz0eWHluKzQRzgXleq0JGiNVKastahUqXT5kjpW2qEyg7)erRSqJTDlKBZvsEGTfMesLao9b)KTrahUqXfRvwOXg7fYTrahUqXfRTPqPqO032)uVHzGcZe82Xm11md87)1HisLd1h8tg9lKzSMzGF)VwqpAWprhVGaBZvsEGT5iLdO(GFYkl0yx1c52CLKhyBJqEK79b)KTrahUqXfRvwzLTbbcn5bwORYoS5wSRQk70ydrTJB3wqocKaoZ2cg5dpKqrMXkmJRK8amtjhz0mBBleD)SqBZQmde3rCn8oyWZqMHB(acHy2SkZGls4aXceGtk4pyT64dmj)R4sEafY)sGj5vbGlhCa4VJjrccbcr3pl0eOYruW5zCcu5bxNB(acH6qChX1W7Gbpd1tYRy2SkZemtkIhMqmdMTZEMPk7WMBzgmHzQcBig2vgZgZMvzgUbUd4qdeJzZQmdMWmqKyKImd34EaHqmtd)enZMvzgmHzGiXifzMGZdZiZemLiIzoiqiMbIK8uKzA4NWm5Nz4(9yghrmd)bHeWrZSzvMbtyMG1Hygj5PUC9ysmdYfCcXmcUdygXrCirljp1LRhtIzKJzCGKQm0fIziqKzUpZOoEyx0mBmBwLzcwWus9ekYmW0)qeZOoEyxygyItcgnZarukkugMbCamb3r8)xHzCLKhyyMdu4UMzZvsEGrhIi1Xd7ILFXhUy2CLKhy0HisD8WUGHLa(JdpbexYdWS5kjpWOdrK64HDbdlb(3fz2CLKhy0HisD8WUGHLaZJN)a9qsSp)wCLKqG6eG4tAQgZmBwLzAapCWpHzqEgzg43)trMzexgMbM(hIyg1Xd7cZatCsWWmoiYmHictcprsahMjhMjEasZS5kjpWOdrK64HDbdlbgGho4N0hXLHzZvsEGrhIi1Xd7cgwceEsEaMnxj5bgDiIuhpSlyyja(dieA68oIlMnRYmvoIu(imJGNdZ4dZqoQWDMXhMj8MjHleZihZeEcbK0lfUZmC8eWmo4eCcXmkFeMj(qjGdZi4eZ8to4IMzZvsEGrhIi1Xd7cgwceVhCH6IhAFiIu(iDj5jlyBhZMRK8aJoerQJh2fmSeqqpAWpX(qeP8r6sYtwWwBf7ZVfxjjeOobi(KgOufZMRK8aJoerQJh2fmSeWtEk2h8tSp)wCLKqG6eG4tAQgZmBmBwLzcwWus9ekYmeeie3zgj5jMrWjMXvYHyMCyghcEwC4cPz2CLKhySOUhqiuFWpHzZvsEGbdlbEd1tH4hMnxj5bgmSeq5Ls3vsEGEjhXEGZtwuXHzZvsEGbdlbuEP0DLKhOxYrSh48KLrSp)wCLKqG6eG4tAQgZmBUsYdmyyjGYlLURK8a9soI9aNNSiOuX1GFYyF(T4kjHa1jaXN0aLQy2y2CLKhy0Q4yb)becnDEhXL953sKGF)Vg)becnDEhXLoEbby2CLKhy0Q4GHLaX7bxOU4H2NFlsYtD56XKQgBRuxRUReVGaAp5PyFWprJiEpbt1CurRRi87)1c6rd(j6xyDDfeVqarR8sjbC6co1h8tgnbC4cfRK1vScoujukKEEiojGtFWpz0eWHlu06kiEHaIEee58LeqAc4WfkADfCOsOui9)uVHI9FIinbC4cfReZMRK8aJwfhmSeiEp4c1fp0(8BrDxjEbb0ipmJ9FIinI49emvZrfTUIWV)xlOhn4NOFH11vq8cbeTYlLeWPl4uFWpz0eWHluSswxrhQekfsppeNeWPp4NmAc4WfkwxlEHaIEee58LeqAc4Wfkwx7qLqPq6)PEdf7)erAc4WfkwjMnxj5bgTkoyyjamHgcXvc4yF(TOUReVGaAb9Ob)enI49emqj4TJzZvsEGrRIdgwcaxUl2)pe3Tp)wu3vIxqaTGE0GFIgr8EcgOGz7y2CLKhy0Q4GHLaoqrJG8sx5LI953I6Us8ccOf0Jg8t0iI3tWafmBhZMRK8aJwfhmSe4NicUCx0(8BrDxjEbb0c6rd(jAeX7jyGcMTJzZvsEGrRIdgwcuso4Y0dgEro8eqy2CLKhy0Q4GHLaHNKhW(8Bb(9)Ab9Ob)enICLyn87)1WL7IL3iAe5kPUg(9)Ab9Ob)e9l0AXrCirJtErW1HkP6QSZAXleq0khr)xP7jVMaoCHI11sYtD56XKQUkRWS5kjpWOvXbdlbe0Jg8tSp)wGF)VgUCxS8gr)cRRLKN6Y1Jjbf1DL4feqlOhn4NOJpKl5b6CE0myeFixYduxxrXrCirJtErW1HkP6QSRUUcIxiGOvoI(Vs3tEnbC4cfRuDTK8uxUEmPQX2kmBmBUsYdm6rSqyAy5MecuFWpHzZvsEGrpcgwca7iKZHSp)wCLKqG6eG4tAGc2mBUsYdm6rWWsaVZ)qrc1VFxHUGgMnxj5bg9iyyjWqOqci9rsah7ZVfe9r0G7WfY6k4kjpGEiuibK(ijGJob9Fj5GlmBUsYdm6rWWsaKhMX(prK953Y)uVPARyN1ve(9)A4YDXYBe9l0A43)Rf0Jg8t0VW6A43)Rf0Jg8t0XliqLy2CLKhy0JGHLaos5aQp4NyF(Ta)(FnVpcH68oIRH3b6xO1WV)xlOhn4NOFHw)p1BWq5J0rehcu9)uVrZ7ykZMRK8aJEemSea5HzS)tezF(Ta)(Fn)bbINaI(fADf)N6nyO8r6iIdbQ(FQ3O5DmTU2HkHsH0)t9gk2)jI0eWHluSU2HkHsH0jOl4uhHZDbNxJCaxqb76AhQekfsppeNeWPp4NmAc4WfkwxlEHaIEee58LeqAc4WfkwjMnxj5bg9iyyjGN8uSp4NyF(Ta)(FDiIu5q9b)KrhVGa11Q7kXliG2tEk2h8t0)xP0rKc3rCOUK8u1UsYdO9KNI9b)eTYhPljpvxd)(FTGE0GFI(fYS5kjpWOhbdlbqEyg7)er2NFl)t9gmu(iDeXHav)p1B08oMwx7qLqPq6)PEdf7)erAc4Wfkwx7qLqPq6e0fCQJW5UGZRroGlOGDDTdvcLcPNhItc40h8tgnbC4cfRRfVqarpcIC(scinbC4cfz2CLKhy0JGHLaHjHujGtFWpHzZvsEGrpcgwc4iLdO(GFI953Y)uVbkbVD11WV)xhIivouFWpz0VqRHF)VwqpAWprhVGamBUsYdm6rWWsGripY9(GFcZgZMRK8aJwqPIRb)KXcSJqohIzZvsEGrlOuX1GFYGHLaeMgwUjHa1h8ty2CLKhy0ckvCn4NmyyjaYdZy)NiY(8Bb(9)AbLkU6d(jJ(fADfDOsOui9)uVHI9FIinbC4cfRRDOsOuiDc6co1r4CxW51ihWfuWUU2HkHsH0ZdXjbC6d(jJMaoCHI11IxiGOhbroFjbKMaoCHIvIzZvsEGrlOuX1GFYGHLaEYtX(GFI953c87)1ckvC1h8tg9l0A43)RdrKkhQp4Nm64feGzZvsEGrlOuX1GFYGHLaipmJ9FIi7ZVf43)RfuQ4Qp4Nm6xiZMRK8aJwqPIRb)Kbdlb4Ffjh8tSp)wGF)VwqPIR(GFYOJxqG6A43)RdrKkhQp4Nm6xyD9)uVbkqu7y2CLKhy0ckvCn4Nmyyjqysivc40h8ty2CLKhy0ckvCn4NmyyjG35FOiH63VRqxqdZMRK8aJwqPIRb)KbdlbgcfsaPpsc4yF(TGOpIgChUqwxbxj5b0dHcjG0hjbC0jO)ljhCHzZvsEGrlOuX1GFYGHLaJqEK79b)KTnHKAHUkRuzRSYUa]] )
end