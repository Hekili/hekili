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


    spec:RegisterPack( "Marksmanship", 20190211.1333, [[dy0ZRaqiuqpsG0MqLAucQoLukVsjzwkHUfksTlk(LuYWus5yOkTmPu9mufMMsGUgQI2MsqFtjv14qrIZjqyDOiP5HQQ7jG9HcCqLuLfII6Hce5IkPc2OsQqJuGOoPsQKwPGmtLurDtuvWorHgQsalfvf6Pk1uvIUQsQi7f4VIAWKCyjlgupMutwKltSzq(mQy0O0PPA1kPs9AujZwOBtj7wv)wXWLIJRKkXYH65QmDKRlvBhfX3fOgpQk68ckRhvLMpLA)qgWlyjyNksam2(A8geR1oV8A4Lh8yH8GhGnfwJa2nLMRIJa2FzjGnFOWCDw1FSEdy3uHfNkbwc230XAbSdksXsuZXuB1IJtSDyJESADUvpwKpVgxquRZT0TGJdClyOIPtctA1GhipkxRfal8XYtxRfGpMdY9NeCMpuyUoR6pwVXCULgSH7EKwxFamyNksam2(A8geR1oV8A4Lh8yH8aSRoXoyWE7wbjWM1tj5bWGDsonyhuKIpuyUoR6pwVbPcY9NemkuqrkwIAoMARwCCITdB0JvRZT6XI8514cIADULUfCCGBbdvmDsysRg8a5r5ATayHpwE6ATa8XCqU)KGZ8HcZ1zv)X6nMZT0OqbfPwhfyCVWHHu8Y7Iiv7RXBqGumnsXlpyQ8GhOqOqbfPcsS1ZroMkkuqrkMgPwVussivqA6pjyKAZoKbfkOiftJuRtNGuKBjzAYjxqkCrScgPi26rkQWCeYqULKPjNCbPObPQNCT3uKGuYNqQbcP0JfCrguOGIumnsTEPes1jp6uyivd2hStHHu0GuR3cSoBa7OF0bwc2e21CDSdDGLag5fSeSln5Zd2WfgxCeWw(cokjaZacWy7GLGDPjFEWw4ZM4CotK8XoeylFbhLeGzabyKhGLGT8fCusaMbBn2jb7fyd3HGme21CLp2HotVbP4gPchPk(kyNed0O7NKYqowmYxWrjHu22ivXxb7Ky8ptSsgZggXAzW1ZfsXaKIxKY2gPk(kyNeZ1XC8Nt(yh6mYxWrjHu22ifvr5jZryPSI(lg5l4OKqQ2a7st(8GnUA8ugYXcGamUGGLGT8fCusaMbBn2jb7fyd3HGme21CLp2HotVbP4gPchPG7qqMgSO9tYh7qNjnb)iLTnsPNjMMGFt5wskFSdzG6XyglA2cZrYKBjif)ivPjFEt5wskFSdz01rzYTeKQnWU0KppyxULKYh7qacWipblbB5l4OKamd2AStc2lWgUdbziSR5kFSdDMEdyxAYNhSXvJNYqowaeGXfcwc2YxWrjbygS1yNeSxGnChcYqyxZv(yh6mPj4hPSTrk4oeKPblA)K8Xo0z6niLTnsbn6(HumaPw)1a7st(8GTvps(XoeGamU(GLGDPjFEWUXfS2Fo5JDiWw(cokjaZacWitbSeSln5Zd2v2QJtcopqznEc(aB5l4OKamdiaJbbyjylFbhLeGzWwJDsWEb2ybclhBbhfKIBKIHivPjFEZj4g5P8r(ZX4Fgk6CyjWU0KppyFcUrEkFK)CaeGrExdSeSln5Zd2hjvkS8XoeylFbhLeGzabiWojqvpsGLag5fSeSLVGJscWmyRXojyVa7Ka3HGm66i)5y6niLTnsLe4oeKj5xJeJfCuYwfhxB6niLTnsLe4oeKj5xJeJfCuYYJloIP3a2LM85bBDfJ5st(85OFeyh9JYFzjGDN8OtHbiaJTdwc2YxWrjbygS1yNeSxGnChcYq4UCSdz6niLTnsXqKIQO8KrxXO)CYeRKp2HoJ8fCusiLTnsrULKPjNCbP4hPAFnWU0Kppy3pj7KyDacWipalbB5l4OKamd2LM85bBDfJ5st(85OFeyh9JYFzjGToDacW4ccwc2YxWrjbygS1yNeSxGDPjNjswEXYLdP4hP4byxAYNhS1vmMln5ZNJ(rGD0pk)LLa2hbiaJ8eSeSLVGJscWmyRXojyVa7stotKS8ILlhsXaKQDWU0KppyRRymxAYNph9Ja7OFu(llbSjSR56yh6aeGa7gSOhl4IalbmYlyjylFbhLeGzabySDWsWw(cokjaZacWipalbB5l4OKamdiaJliyjylFbhLeGzabyKNGLGDPjFEWUziFEWw(cokjaZacW4cblb7st(8GnB)jbFzRcZfylFbhLeGzabyC9blbB5l4OKamd2nyrxhLj3saBExdSln5Zd2PPdhLmvnacWitbSeSLVGJscWmy3GfDDuMClbS51WtWU0Kppyt4UCSdb2AStc2lWU0KZejlVy5YHumaPAhqagdcWsWw(cokjaZGTg7KG9cSln5mrYYlwUCif)ifpa7st(8GD5wskFSdbiab260bwcyKxWsWw(cokjaZGTg7KG9cStcChcYW2FsWx2QWCzstWpyxAYNhSz7pj4lBvyUaeGX2blbB5l4OKamd2AStc2lWMCljtto5csXpsXlprkBBKsptmnb)MYTKu(yhYGfRY)dP4hP4Otif3iv4ifChcYq4UCSdz6nif3iv4ifChcY0FbJ9NtMj(5ZBoQ0CHumaPwiszBJumePk(kyNet)fm2FozM4NpVr(cokjKQnKY2gPyisrvuEYORy0FozIvYh7qNr(cokjKQnKIBKkCKIHivXxb7KyUoMJ)CYh7qNr(cokjKIBKIHifvr5jZryPSI(lg5l4OKqkUrkgIufFfStIbA09tszihlg5l4OKqQ2a7st(8GDA6WrjtvdGamYdWsWw(cokjaZGTg7KG9cS1ZettWVbxnEkd5yXGfRY)dP4hP4Otif3iv4ifChcYq4UCSdz6nif3iv4ifChcY0FbJ9NtMj(5ZBoQ0CHumaPwiszBJumePk(kyNet)fm2FozM4NpVr(cokjKQnKY2gPyisrvuEYORy0FozIvYh7qNr(cokjKQnKIBKkCKQ4RGDsmxhZXFo5JDOZiFbhLeszBJuufLNmhHLYk6VyKVGJscPSTrQIVc2jXan6(jPmKJfJ8fCusivBGDPjFEWonD4OKPQbqagxqWsWw(cokjaZGTg7KG9cSH7qqgc3LJDitVbP4gPchPi3sY0KtUGumaP0ZettWVbwWNG5YFoMuhxKppsTcPsDCr(8iLTnsfosrfMJqgwPIeRPrtif)iv7RHu22ifdrkQIYtgDHfOEmxULr(cokjKQnKQnKY2gPi3sY0KtUGu8Ju8YdWU0Kppydl4tWC5phabyKNGLGT8fCusaMbBn2jb7fyd3HGmeUlh7qMEdsXnsfosrULKPjNCbPyasPNjMMGFdCCMugQJdZK64I85rQvivQJlYNhPSTrQWrkQWCeYWkvKynnAcP4hPAFnKY2gPyisrvuEYOlSa1J5YTmYxWrjHuTHuTHu22if5wsMMCYfKIFKI3fc2LM85bB44mPmuhhgGamUqWsWw(cokjaZGTg7KG9cSH7qqgc3LJDitVbP4gPchPi3sY0KtUGumaP0ZettWVPETCeUIzDfJMuhxKppsTcPsDCr(8iLTnsfosrfMJqgwPIeRPrtif)iv7RHu22ifdrkQIYtgDHfOEmxULr(cokjKQnKQnKY2gPi3sY0KtUGu8Ju8UqWU0KppyxVwocxXSUIrabyC9blbB5l4OKamd2AStc2lWgUdbziCxo2Hm9gKIBKkCKICljtto5csXaKsptmnb)gihlWXzsMuhxKppsTcPsDCr(8iLTnsfosrfMJqgwPIeRPrtif)iv7RHu22ifdrkQIYtgDHfOEmxULr(cokjKQnKQnKY2gPi3sY0KtUGu8JubbyxAYNhSHCSahNjbiaJmfWsWU0KppyhDoS0Lx39ehl5jWw(cokjaZacWyqawc2YxWrjbygS1yNeSxGnChcYq4UCSdzWsPjKIBKcUdbzGJZKI9JmyP0eszBJuWDiidH7YXoKP3GuCJu6kl8PO7KGu22if5wsMMCYfKIFKQDEc2LM85b7MH85beGrExdSeSLVGJscWmyRXojyVaB9mX0e8BWvJNYqowmyXQ8)qkUrkYTKmn5Klifdqk9mX0e8BiCxo2HmPoUiF(mNUChsTcPsDCr(8iLTnsfosrfMJqgwPIeRPrtif)iv7RHu22ifdrkQIYtgDHfOEmxULr(cokjKQnKY2gPi3sY0KtUGu8Ju8YtWU0Kppyt4UCSdbiab2hbwcyKxWsWU0Kppyl8ztCoNjs(yhcSLVGJscWmGam2oyjylFbhLeGzWwJDsWEb2LMCMiz5flxoKIbifVGDPjFEWgUW4IJaiaJ8aSeSln5Zd2v2QJtcopqznEc(aB5l4OKamdiaJliyjylFbhLeGzWwJDsWEb2ybclhBbhfKIBKIHivPjFEZj4g5P8r(ZX4Fgk6CyjWU0KppyFcUrEkFK)CaeGrEcwc2YxWrjbygS1yNeSxGn0O7hsXpsXZ1qkUrQWrk4oeKbootk2pY0BqkUrk4oeKHWD5yhY0BqkBBKcUdbziCxo2HmPj4hPAdSln5Zd24QXtzihlacW4cblbB5l4OKamd2AStc2lWgUdbzSQJeC2QWCDw1B6nif3ifChcYq4UCSdz6nif3if0O7hsTcP01rzSWrEKIFKcA09Zyv8jyxAYNhSlSUEjFSdbiaJRpyjylFbhLeGzWwJDsWEb2WDiitdw0(j5JDOZKMGFKY2gP0ZettWVPCljLp2Hmq9ymJfnBH5izYTeKIFKQ0KpVPCljLp2Hm66Om5wcszBJuWDiidH7YXoKP3a2LM85b7YTKu(yhcqagzkGLGT8fCusaMbBn2jb7fydn6(HuRqkDDuglCKhP4hPGgD)mwfFIu22ivXxb7KyGgD)KugYXIr(cokjKY2gPk(kyNeJ)zIvYy2WiwldUEUqkgGu8Iu22ivXxb7KyUoMJ)CYh7qNr(cokjKY2gPOkkpzoclLv0FXiFbhLeyxAYNhSXvJNYqowaeGXGaSeSln5Zd2nUG1(ZjFSdb2YxWrjbygqag5DnWsWw(cokjaZGTg7KG9cSHgD)qkgGumfEIu22iv4ifChcY0GfTFs(yh6m9gKY2gPGgD)qkgGuliprkUrk9mX0e8BiCxo2HmyXQ8)qkUrkYTKmn5Klif)iv78ePAdP4gPG7qqgc3LJDitAc(rkBBKICljtto5csXpsXtWU0KppyxyD9s(yhcqag5LxWsWU0KppyFKuPWYh7qGT8fCusaMbeGa7o5rNcdSeWiVGLGDPjFEWwp9NeC(yhcSLVGJscWmGam2oyjyxAYNhSpblVtHLt9JaB5l4OKamdiaJ8aSeSln5Zd2xZGLSoo9eylFbhLeGzabyCbblb7st(8G9ndX6pNCWfjyWw(cokjaZacWipblb7st(8G9nVRZWX6iWw(cokjaZacW4cblb7st(8G9leRGZh7O5cSLVGJscWmGamU(GLGDPjFEWwZ6RB)YeU(1LUhDkmWw(cokjaZacWitbSeSln5Zd2xJJDkFSJMlWw(cokjaZacWyqawc2LM85b7VOowUmhCPfWw(cokjaZacqacSzIGpFEaJTVgVbXATVgVM25XAleSdUWV)CoWED1QzWKKqQfIuLM85rQOF0zqHa7g8a5rbSdksXhkmxNv9hR3Gub5(tcgfkOiflrnhtTvlooX2Hn6XQ15w9yr(8ACbrTo3s3cooWTGHkMojmPvdEG8OCTwaSWhlpDTwa(yoi3FsWz(qH56SQ)y9gZ5wAuOGIuRJcmUx4WqkE5DrKQ914niqkMgP4LhmvEWduiuOGIubj265ihtffkOiftJuRxkjjKkin9NemsTzhYGcfuKIPrQ1PtqkYTKmn5KlifUiwbJueB9ifvyoczi3sY0KtUGu0Gu1tU2Bksqk5ti1aHu6XcUidkuqrkMgPwVucP6KhDkmKQb7d2PWqkAqQ1BbwNnOqOqbfPwh4tr3jjHuWc0GfKspwWfHuWch)pdsTEAT0qhs9ZZ0Sf2cQhrQst(8hsnFmmdkuPjF(Z0Gf9ybxuaOyDCHcvAYN)mnyrpwWfTkqRQZXsEQiFEuOst(8NPbl6XcUOvbAbntcfkOi1(RMJDiKcxEcPG7qqscPoQOdPGfObliLESGlcPGfo(Fiv9jKQblmDZqK)Cqk)qQ08IbfQ0Kp)zAWIESGlAvGw3xnh7q5Jk6qHkn5ZFMgSOhl4IwfOvZq(8OqLM85ptdw0JfCrRc0IT)KGVSvH5cfkOi1cGfDDesrS(Hu1HusHJHHu1HunZDoCuqkAqQMHKN8kgddP4u(Ju1peRGrkDDesL6y)5GueRGuqohwYGcvAYN)mnyrpwWfTkqR00HJsMQMfBWIUoktULeG31qHkn5ZFMgSOhl4IwfOfH7YXo0InyrxhLj3scWRHNl6qbkn5mrYYlwUCmODuOst(8NPbl6XcUOvbAvULKYh7ql6qbkn5mrYYlwUC8ZduiuOst(8NPtE0PWcON(tcoFSdHcvAYN)mDYJof2QaToblVtHLt9JqHkn5ZFMo5rNcBvGwxZGLSoo9ekuPjF(Z0jp6uyRc06MHy9Nto4IemkuPjF(Z0jp6uyRc06M31z4yDekuPjF(Z0jp6uyRc06fIvW5JD0CHcvAYN)mDYJof2QaT0S(62VmHRFDP7rNcdfQ0Kp)z6KhDkSvbADno2P8XoAUqHkn5ZFMo5rNcBvGwFrDSCzo4slOqOqbfPwh4tr3jjHucteCyif5wcsrScsvAAWiLFivXKYJfCumOqLM85Va6kgZLM85Zr)Of)Ysc0jp6uyl6qbscChcYORJ8NJP3yBNe4oeKj5xJeJfCuYwfhxB6n22jbUdbzs(1iXybhLS84IJy6nOqOqbfPwIddPObPI(livVbPkn5mPijHue2FUe6qQGDIfPwI7YXoekuPjF(BvGw9tYojw3Ioua4oeKHWD5yhY0BSTzivr5jJUIr)5KjwjFSdDg5l4OKSTj3sY0KtUWF7RHcvAYN)wfOLUIXCPjF(C0pAXVSKa60HcvAYN)wfOLUIXCPjF(C0pAXVSKahTOdfO0KZejlVy5YXppqHkn5ZFRc0sxXyU0KpFo6hT4xwsac7AUo2HUfDOaLMCMiz5flxog0okekuPjF(ZOtxa2(tc(YwfMRfDOajbUdbzy7pj4lBvyUmPj4hfQ0Kp)z0PBvGwPPdhLmvnl6qbi3sY0KtUWpV802wptmnb)MYTKu(yhYGfRY)JFo6e3Hd3HGmeUlh7qMEd3Hd3HGm9xWy)5KzIF(8MJknxmyH22mS4RGDsm9xWy)5KzIF(8g5l4OKAZ2MHufLNm6kg9NtMyL8Xo0zKVGJsQnUdNHfFfStI56yo(ZjFSdDg5l4OK4MHufLNmhHLYk6VyKVGJsIBgw8vWojgOr3pjLHCSyKVGJsQnuOst(8NrNUvbALMoCuYu1SOdfqptmnb)gC14PmKJfdwSk)p(5OtChoChcYq4UCSdz6nChoChcY0FbJ9NtMj(5ZBoQ0CXGfABZWIVc2jX0FbJ9NtMj(5ZBKVGJsQnBBgsvuEYORy0FozIvYh7qNr(cokP24o8IVc2jXCDmh)5Kp2HoJ8fCus22ufLNmhHLYk6VyKVGJsY2U4RGDsmqJUFskd5yXiFbhLuBOqLM85pJoDRc0cwWNG5YFol6qbG7qqgc3LJDitVH7Wj3sY0KtUWa9mX0e8BGf8jyU8NJj1Xf5ZVk1Xf5ZBBhovyoczyLksSMgnXF7RzBZqQIYtgDHfOEmxULr(cokP2AZ2MCljtto5c)8YduOst(8NrNUvbAbhNjLH64Ww0Hca3HGmeUlh7qMEd3HtULKPjNCHb6zIPj43ahNjLH64WmPoUiF(vPoUiFEB7WPcZridRurI10Oj(BFnBBgsvuEYOlSa1J5YTmYxWrj1wB22KBjzAYjx4N3fIcvAYN)m60TkqR61Yr4kM1vmUOdfaUdbziCxo2Hm9gUdNCljtto5cd0ZettWVPETCeUIzDfJMuhxKp)QuhxKpVTD4uH5iKHvQiXAA0e)TVMTndPkkpz0fwG6XC5wg5l4OKARnBBYTKmn5Kl8Z7crHkn5ZFgD6wfOfKJf44mPfDOaWDiidH7YXoKP3WD4KBjzAYjxyGEMyAc(nqowGJZKmPoUiF(vPoUiFEB7WPcZridRurI10Oj(BFnBBgsvuEYOlSa1J5YTmYxWrj1wB22KBjzAYjx4piqHkn5ZFgD6wfOv05WsxED3tCSKNqHkn5ZFgD6wfOvZq(8l6qbG7qqgc3LJDidwknXnChcYahNjf7hzWsPjBB4oeKHWD5yhY0B4wxzHpfDNeBBYTKmn5Kl83oprHkn5ZFgD6wfOfH7YXo0Ioua9mX0e8BWvJNYqowmyXQ8)4MCljtto5cd0ZettWVHWD5yhYK64I85ZC6YDRsDCr(822HtfMJqgwPIeRPrt83(A22mKQO8KrxybQhZLBzKVGJsQnBBYTKmn5Kl8ZlprHqHkn5ZFMJci8ztCoNjs(yhcfQ0Kp)zoAvGwWfgxCKfDOaLMCMiz5flxogWlkuPjF(ZC0QaTQSvhNeCEGYA8e8HcvAYN)mhTkqRtWnYt5J8NZIouaSaHLJTGJc3mS0KpV5eCJ8u(i)5y8pdfDoSekuPjF(ZC0QaTWvJNYqoww0Hcan6(XppxJ7WH7qqg44mPy)itVHB4oeKHWD5yhY0BSTH7qqgc3LJDitAc(BdfQ0Kp)zoAvGwfwxVKp2Hw0Hca3HGmw1rcoBvyUoR6n9gUH7qqgc3LJDitVHBOr3Vv66Omw4ip)qJUFgRIprHkn5ZFMJwfOv5wskFSdTOdfaUdbzAWI2pjFSdDM0e8BBRNjMMGFt5wskFSdzG6XyglA2cZrYKBj8xAYN3uULKYh7qgDDuMClX2gUdbziCxo2Hm9guOst(8N5OvbAHRgpLHCSSOdfaA09BLUokJfoYZp0O7NXQ4tB7IVc2jXan6(jPmKJfJ8fCus22fFfStIX)mXkzmByeRLbxpxmGxB7IVc2jXCDmh)5Kp2HoJ8fCus22ufLNmhHLYk6VyKVGJscfQ0Kp)zoAvGwnUG1(ZjFSdHcvAYN)mhTkqRcRRxYh7ql6qbGgD)yatHN22Hd3HGmnyr7NKp2HotVX2gA09Jblip5wptmnb)gc3LJDidwSk)pUj3sY0KtUWF78SnUH7qqgc3LJDitAc(TTj3sY0KtUWpprHkn5ZFMJwfO1rsLclFSdHcHcvAYN)me21CDSdDbGlmU4iOqLM85pdHDnxh7q3QaTe(SjoNZejFSdHcvAYN)me21CDSdDRc0cxnEkd5yzrhkaChcYqyxZv(yh6m9gUdV4RGDsmqJUFskd5yXiFbhLKTDXxb7Ky8ptSsgZggXAzW1Zfd412U4RGDsmxhZXFo5JDOZiFbhLKTnvr5jZryPSI(lg5l4OKAdfQ0Kp)ziSR56yh6wfOv5wskFSdTOdfaUdbziSR5kFSdDMEd3Hd3HGmnyr7NKp2HotAc(TT1ZettWVPCljLp2Hmq9ymJfnBH5izYTe(ln5ZBk3ss5JDiJUoktUL0gkuPjF(ZqyxZ1Xo0TkqlC14PmKJLfDOaWDiidHDnx5JDOZ0BqHkn5ZFgc7AUo2HUvbAz1JKFSdTOdfaUdbziSR5kFSdDM0e8BBd3HGmnyr7NKp2HotVX2gA09JbR)AOqLM85pdHDnxh7q3QaTACbR9Nt(yhcfQ0Kp)ziSR56yh6wfOvLT64KGZduwJNGpuOst(8NHWUMRJDOBvGwNGBKNYh5pNfDOaybclhBbhfUzyPjFEZj4g5P8r(ZX4Fgk6CyjuOst(8NHWUMRJDOBvGwhjvkS8XoeyFnIgWy78CbbeGaaa]] )
end