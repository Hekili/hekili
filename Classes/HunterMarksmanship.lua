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
            gcd = "spell",
            
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

        aoe = 2,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20190201.2306, [[dq0)NaqiLsEevQSjuOrrf1POI8kuWSukClskzxK6xsrdJkLJrsSmsQEgvQAAkLIRHIyBkvY3iPiJtPu15OcL1PuQmpsu3JkzFkfDqskklKK0djPuDrQqfBKkuPrssPCsskQwPu4MkvQ2jjYqvkLwQsLYtbzQkvDvQqv2lu)vIbJQdlAXG6XumzQ6YeBwjFMegnkDAHvtfQQxJIA2s62uYUv1VvmCP0YH8CvMoY1LQTRuX3PcgpjfopviRhfP5tP2pWyvW7Xq(KeSsQ7MkoMBQ7MkA1DVB7sDvWqKJAfmuBAyoviyOpTem0UNiMpR8p2Ofd1MoQoPhVhdDthzemK7aCwIAVTRztfbX2H1MXQ5fw9AsX8guUOMxyzAcxh4MWRuT8YonBrZkQY1CBrYULH)AUT7wrT1FsqLDprmFw5FSrR(cldgcUhvsn)XWyiFscwj1DtfhZn1DtfT6U3TDPogk7e7GWqqHLAhdXgEV8yymKxodgYDa(UNiMpR8p2OfWvB9NeeOH7aCwIAVTRztfbX2H1MXQ5fw9AsX8guUOMxyzAcxh4MWRuT8YonBrZkQY1CBrYULH)AUT7wrT1FsqLDprmFw5FSrR(cldOH7aChxbg1tKJaCv2aWv3nvCmaxTaC1vz7CZ9GgGgUdWv7S5RqUTd0WDaUAb4QzEV4bC1(0Fsqaoe7qAqd3b4QfG74DcGtHLuOP4dbWrjXkiaNyZhWPePqinfwsHMIpeaNgapFkmrBscGlVhWNfGBgl4K0yOAC0H3JHiuyy(yh6W7XkPcEpgknumpgcorOuHGHKpHRIhRkMWkPoEpgknumpgsuJ26CXos5yhcdjFcxfpwvmHvY949yi5t4Q4XQIHmOGeuKyi4(APjuyyUCSdD6ElGZiG7mGNmvqbj61y6N4lRajA5t4Q4bCBBapzQGcs0XxiwPGyDeXAPr5ZmGVjGRcGBBd4jtfuqI(6ifXROCSdDA5t4Q4bCBBaNYQ8K(iKKw14fT8jCv8aUtyO0qX8yiu2g(YkqcMWkTn49yi5t4Q4XQIHmOGeuKyi4(APjuyyUCSdD6ElGZiG7mGd3xlDlsmXjLJDOt7hhEa32gWnZu9JdVodlXxo2H0RETwqIHnrkKcfwcGRmGNgkMxNHL4lh7qAtEuHclbWDcdLgkMhdLHL4lh7qycRetW7XqYNWvXJvfdzqbjOiXqW91stOWWC5yh609wmuAOyEmekBdFzfibtyL2fEpgs(eUkESQyidkibfjgcUVwAcfgMlh7qN2po8aUTnGd3xlDlsmXjLJDOt3BbCBBaFnM(b4Bc4Qj3WqPHI5Xqw9kfh7qycRKAcVhdLgkMhd1gcYeVIYXoegs(eUkESQycR02J3JHsdfZJHYIvh5fuzwfdAC4WqYNWvXJvftyLCm8EmK8jCv8yvXqguqcksmeswi5yt4Qa4mc4Bb4PHI51NGALNkhfVcD8LvnuWsyO0qX8yOtqTYtLJIxbMWkPIB49yO0qX8yOJK07OYXoegs(eUkESQyctyiVSYELW7XkPcEpgknumpgYm9Neu5yhcdjFcxfpwvmHvsD8EmK8jCv8yvXqguqcksmeCFT0eQlh7q6ElGBBd4Bb4uwLN0MSwJxrHyLYXo0PLpHRIhWTTbCkSKcnfFiaUYaU6UHHsdfZJH6NucsSomHvY949yi5t4Q4XQIHsdfZJHmzTwsdfZxQXryOACu5tlbdz8hMWkTn49yi5t4Q4XQIHmOGeuKyO0qXosrEXkKdWvgWDpgknumpgYK1AjnumFPghHHQXrLpTem0rycRetW7XqYNWvXJvfdzqbjOiXqPHIDKI8IvihGVjGRogknumpgYK1AjnumFPghHHQXrLpTemeHcdZh7qhMWegQfjMXcoj8ESsQG3JHKpHRIhRkMWkPoEpgs(eUkESQycRK7X7XqYNWvXJvftyL2g8EmK8jCv8yvXewjMG3JHsdfZJHAhkMhdjFcxfpwvmHvAx49yO0qX8yi2(tc6kwjIzmK8jCv8yvXewj1eEpgs(eUkESQyOwKyYJkuyjyivCddLgkMhd5NoCvku2IjSsBpEpgs(eUkESQyOwKyYJkuyjyiv0mbdLgkMhdrOUCSdHHmOGeuKyO0qXosrEXkKdW3eWvhtyLCm8EmK8jCv8yvXqguqcksmuAOyhPiVyfYb4kd4UhdLgkMhdLHL4lh7qyctyiJ)W7XkPcEpgs(eUkESQyidkibfjgYlW91sZ2FsqxXkrmR9JdpgknumpgIT)KGUIvIygtyLuhVhdjFcxfpwvmKbfKGIedrHLuOP4dbWvgWvHjaUTnGBMP6hhEDgwIVCSdPrIvg)b4kd4kmEaNra3zahUVwAc1LJDiDVfWzeWDgWH7RLU)ccfVIYoXfZRpknmd4Bc47cWTTb8Ta8KPckir3FbHIxrzN4I51YNWvXd4ob422a(waoLv5jTjR14vuiwPCSdDA5t4Q4bCNaCgbCNb8Ta8KPckirFDKI4vuo2HoT8jCv8aoJa(waoLv5j9rijTQXlA5t4Q4bCgb8Ta8KPckirVgt)eFzfirlFcxfpG7egknumpgYpD4QuOSftyLCpEpgs(eUkESQyidkibfjgYmt1po8Au2g(YkqIgjwz8hGRmGRW4bCgbCNbC4(APjuxo2H09waNra3zahUVw6(liu8kk7exmV(O0WmGVjGVla32gW3cWtMkOGeD)fekEfLDIlMxlFcxfpG7eGBBd4Bb4uwLN0MSwJxrHyLYXo0PLpHRIhWDcWzeWDgWtMkOGe91rkIxr5yh60YNWvXd422aoLv5j9rijTQXlA5t4Q4bCBBapzQGcs0RX0pXxwbs0YNWvXd4oHHsdfZJH8thUkfkBXewPTbVhdjFcxfpwvmKbfKGIedb3xlnH6YXoKU3c4mc4od4uyjfAk(qa8nbCZmv)4WRHf0jiMJxH23rjfZd4ma4(okPyEa32gWDgWPePqinRKvIv3AiaxzaxD3aCBBaFlaNYQ8K2Kiz1RLmS0YNWvXd4ob4ob422aofwsHMIpeaxzaxf3JHsdfZJHGf0jiMJxbMWkXe8EmK8jCv8yvXqguqcksmeCFT0eQlh7q6ElGZiG7mGtHLuOP4dbW3eWnZu9JdVgUoJVS6ihP9DusX8aodaUVJskMhWTTbCNbCkrkesZkzLy1TgcWvgWv3na32gW3cWPSkpPnjsw9AjdlT8jCv8aUtaUtaUTnGtHLuOP4dbWvgWvzxyO0qX8yi46m(YQJCeMWkTl8EmK8jCv8yvXqguqcksmeCFT0eQlh7q6ElGZiG7mGtHLuOP4dbW3eWnZu9JdVoFJCekRftwRAFhLumpGZaG77OKI5bCBBa3zaNsKcH0SswjwDRHaCLbC1DdWTTb8TaCkRYtAtIKvVwYWslFcxfpG7eG7eGBBd4uyjfAk(qaCLbCv2fgknumpgkFJCekRftwRycRKAcVhdjFcxfpwvmKbfKGIedb3xlnH6YXoKU3c4mc4od4uyjfAk(qa8nbCZmv)4WRxbsGRZ41(okPyEaNba33rjfZd422aUZaoLifcPzLSsS6wdb4kd4Q7gGBBd4Bb4uwLN0MejRETKHLw(eUkEa3ja3ja32gWPWsk0u8Ha4kd4oggknumpgAfibUoJhtyL2E8EmuAOyEmunuWsxXXV7vyjpHHKpHRIhRkMWk5y49yi5t4Q4XQIHmOGeuKyi4(APjuxo2H0ijneGZiGd3xlnCDgFTFKgjPHaCBBahUVwAc1LJDiDVfWzeWnzrudX0jbWTTbCkSKcnfFiaUYaU6mbdLgkMhd1oumpMWkPIB49yi5t4Q4XQIHmOGeuKyiZmv)4WRrzB4lRajAKyLXFaoJaofwsHMIpeaFta3mt1po8Ac1LJDiTVJskMVOOl3b4ma4(okPyEa32gWDgWPePqinRKvIv3AiaxzaxD3aCBBaFlaNYQ8K2Kiz1RLmS0YNWvXd4ob422aofwsHMIpeaxzaxfMGHsdfZJHiuxo2HWeMWqhH3Jvsf8EmuAOyEmKOgT15IDKYXoegs(eUkESQycRK649yi5t4Q4XQIHmOGeuKyO0qXosrEXkKdW3eWvbdLgkMhdbNiuQqWewj3J3JHsdfZJHYIvh5fuzwfdAC4WqYNWvXJvftyL2g8EmK8jCv8yvXqguqcksmeswi5yt4Qa4mc4Bb4PHI51NGALNkhfVcD8LvnuWsyO0qX8yOtqTYtLJIxbMWkXe8EmK8jCv8yvXqguqcksm0Am9dWvgWzIBaoJaUZaoCFT0W1z81(r6ElGZiGd3xlnH6YXoKU3c422aoCFT0eQlh7qA)4Wd4oHHsdfZJHqzB4lRajycR0UW7XqYNWvXJvfdzqbjOiXqW91sBLhjOIvIy(SYx3BbCgbC4(APjuxo2H09waNraFnM(b4ma4M8OcsuipGRmGVgt)0wPAGHsdfZJHsKjFPCSdHjSsQj8EmK8jCv8yvXqguqcksmeCFT0TiXeNuo2HoTFC4bCBBa3mt1po86mSeF5yhsV61Abjg2ePqkuyjaUYaEAOyEDgwIVCSdPn5rfkSea32gWH7RLMqD5yhs3BXqPHI5Xqzyj(YXoeMWkT949yi5t4Q4XQIHmOGeuKyO1y6hGZaGBYJkirH8aUYa(Am9tBLQbGBBd4jtfuqIEnM(j(YkqIw(eUkEa32gWtMkOGeD8fIvkiwhrSwAu(md4Bc4Qa422aEYubfKOVosr8kkh7qNw(eUkEa32gWPSkpPpcjPvnErlFcxfpgknumpgcLTHVScKGjSsogEpgknumpgQneKjEfLJDimK8jCv8yvXewjvCdVhdjFcxfpwvmKbfKGIedTgt)a8nb8TNjaUTnG7mGd3xlDlsmXjLJDOt3BbCBBaFnM(b4Bc4BdtaCgbCZmv)4WRjuxo2H0iXkJ)aCgbCkSKcnfFiaUYaU6mbWDcWzeWH7RLMqD5yhs7hhEa32gWPWsk0u8Ha4kd4mbdLgkMhdLit(s5yhctyLurf8EmuAOyEm0rs6Du5yhcdjFcxfpwvmHjmHH2rqxmpwj1DtLTxf1DVBA1vrfMGHCirF8komKAUv7GiXd4mbWtdfZd414OtdAGHArZkQcgYDa(UNiMpR8p2OfWvB9NeeOH7aCwIAVTRztfbX2H1MXQ5fw9AsX8guUOMxyzAcxh4MWRuT8YonBrZkQY1CBrYULH)AUT7wrT1FsqLDprmFw5FSrR(cldOH7aChxbg1tKJaCv2aWv3nvCmaxTaC1vz7CZ9GgGgUdWv7S5RqUTd0WDaUAb4QzEV4bC1(0Fsqaoe7qAqd3b4QfG74DcGtHLuOP4dbWrjXkiaNyZhWPePqinfwsHMIpeaNgapFkmrBscGlVhWNfGBgl4K0GgGgUdWDCudX0jXd4WYAqcGBgl4KaCyrr8NgWvZmgPLoa)NxTytK1Qxb80qX8hGpF1rAqJ0qX8NUfjMXcojxRAEmdAKgkM)0TiXmwWjXGRMzxHL8usX8GgPHI5pDlsmJfCsm4Q5AgpOH7aCOpBp2HaCugEahUVwIhWpkPdWHL1Gea3mwWjb4WII4papFpG3Ie1QDikEfaECaUFErdAKgkM)0TiXmwWjXGRM3NTh7qLJs6ansdfZF6wKygl4KyWvZ2HI5bnsdfZF6wKygl4KyWvt2(tc6kwjIzqd3b4Blsm5raoXghGNhGljQ6iappaVDUlGRcGtdG3oK8uK1QJaCfz8aE(dXkia3Khb4(okEfaoXka(kuWsAqJ0qX8NUfjMXcojgC10pD4QuOSDJwKyYJkuyjUuXnqJ0qX8NUfjMXcojgC1KqD5yhAJwKyYJkuyjUurZKnILR0qXosrEXkKBt1bnsdfZF6wKygl4KyWvZmSeF5yhAJy5knuSJuKxSc5u29GgGgUdWDCudX0jXd4YocYraofwcGtScGNgAqaECaEUtg1eUkAqJ0qX8NlZ0FsqLJDiqdqd3b47rocWPbWRXlaEVfWtdf7KK4bCcfpZcDaUdbXc47rD5yhc0inum)XGRM9tkbjw3gXYfCFT0eQlh7q6ERT9wuwLN0MSwJxrHyLYXo0PLpHRI32MclPqtXhIYQ7gOrAOy(JbxnnzTwsdfZxQXrB8PL4Y4pqJ0qX8hdUAAYATKgkMVuJJ24tlX1rBelxPHIDKI8IviNYUh0inum)XGRMMSwlPHI5l14On(0sCrOWW8Xo0TrSCLgk2rkYlwHCBQoObOrAOy(tB8Nl2(tc6kwjI5nILlVa3xlnB)jbDfReXS2po8GgPHI5pTXFm4QPF6WvPqz7gXYffwsHMIpeLvHj22MzQ(XHxNHL4lh7qAKyLXFkRW4z0z4(APjuxo2H09wgDgUVw6(liu8kk7exmV(O0W8M7Y2ERKPckir3FbHIxrzN4I51YNWvX7KT9wuwLN0MSwJxrHyLYXo0PLpHRI3jgDERKPckirFDKI4vuo2HoT8jCv8mUfLv5j9rijTQXlA5t4Q4zCRKPckirVgt)eFzfirlFcxfVtGgPHI5pTXFm4QPF6WvPqz7gXYLzMQFC41OSn8LvGensSY4pLvy8m6mCFT0eQlh7q6ElJod3xlD)fekEfLDIlMxFuAyEZDzBVvYubfKO7VGqXROStCX8A5t4Q4DY2ElkRYtAtwRXROqSs5yh60YNWvX7eJoNmvqbj6RJueVIYXo0PLpHRI32MYQ8K(iKKw14fT8jCv822jtfuqIEnM(j(YkqIw(eUkENansdfZFAJ)yWvtybDcI54vSrSCb3xlnH6YXoKU3YOZuyjfAk(q20mt1po8AybDcI54vO9DusX8m47OKI5TTDMsKcH0SswjwDRHuwD3ST3IYQ8K2Kiz1RLmS0YNWvX7Kt22uyjfAk(quwf3dAKgkM)0g)XGRMW1z8Lvh5OnILl4(APjuxo2H09wgDMclPqtXhYMMzQ(XHxdxNXxwDKJ0(okPyEg8DusX822otjsHqAwjReRU1qkRUB22BrzvEsBsKS61sgwA5t4Q4DYjBBkSKcnfFikRYUansdfZFAJ)yWvZ8nYrOSwmzTUrSCb3xlnH6YXoKU3YOZuyjfAk(q20mt1po868nYrOSwmzTQ9DusX8m47OKI5TTDMsKcH0SswjwDRHuwD3ST3IYQ8K2Kiz1RLmS0YNWvX7Kt22uyjfAk(quwLDbAKgkM)0g)XGRMRajW1z8BelxW91stOUCSdP7Tm6mfwsHMIpKnnZu9JdVEfibUoJx77OKI5zW3rjfZBB7mLifcPzLSsS6wdPS6UzBVfLv5jTjrYQxlzyPLpHRI3jNSTPWsk0u8HOSJbAKgkM)0g)XGRM1qblDfh)UxHL8eOrAOy(tB8hdUA2oum)gXYfCFT0eQlh7qAKKgIr4(APHRZ4R9J0ijnKTnCFT0eQlh7q6ElJMSiQHy6KyBtHLuOP4drz1zcOrAOy(tB8hdUAsOUCSdTrSCzMP6hhEnkBdFzfirJeRm(JrkSKcnfFiBAMP6hhEnH6YXoK23rjfZxu0L7yW3rjfZBB7mLifcPzLSsS6wdPS6UzBVfLv5jTjrYQxlzyPLpHRI3jBBkSKcnfFikRctanansdfZF6JCjQrBDUyhPCSdbAKgkM)0hXGRMWjcLkKnILR0qXosrEXkKBtvansdfZF6JyWvZSy1rEbvMvXGghoqJ0qX8N(igC18euR8u5O4vSrSCHKfso2eUkmUvAOyE9jOw5PYrXRqhFzvdfSeOrAOy(tFedUAIY2Wxwbs2iwUwJPFkZe3y0z4(APHRZ4R9J09wgH7RLMqD5yhs3BTTH7RLMqD5yhs7hhENansdfZF6JyWvZezYxkh7qBelxW91sBLhjOIvIy(SYx3BzeUVwAc1LJDiDVLX1y6hdM8OcsuiVYRX0pTvQgGgPHI5p9rm4QzgwIVCSdTrSCb3xlDlsmXjLJDOt7hhEBBZmv)4WRZWs8LJDi9QxRfKyytKcPqHLOCAOyEDgwIVCSdPn5rfkSeBB4(APjuxo2H09wqJ0qX8N(igC1eLTHVScKSrSCTgt)yWKhvqIc5vEnM(PTs1W2ozQGcs0RX0pXxwbs0YNWvXBBNmvqbj64leRuqSoIyT0O8zEtvSTtMkOGe91rkIxr5yh60YNWvXBBtzvEsFessRA8Iw(eUkEqJ0qX8N(igC1SneKjEfLJDiqJ0qX8N(igC1mrM8LYXo0gXY1Am9BZTNj22od3xlDlsmXjLJDOt3BTTxJPFBUnmHrZmv)4WRjuxo2H0iXkJ)yKclPqtXhIYQZeNyeUVwAc1LJDiTFC4TTPWsk0u8HOmtansdfZF6JyWvZJK07OYXoeObOrAOy(ttOWW8Xo05corOuHaAKgkM)0ekmmFSdDm4QPOgT15IDKYXoeOrAOy(ttOWW8Xo0XGRMOSn8LvGKnILl4(APjuyyUCSdD6ElJoNmvqbj61y6N4lRajA5t4Q4TTtMkOGeD8fIvkiwhrSwAu(mVPk22jtfuqI(6ifXROCSdDA5t4Q4TTPSkpPpcjPvnErlFcxfVtGgPHI5pnHcdZh7qhdUAMHL4lh7qBelxW91stOWWC5yh609wgDgUVw6wKyItkh7qN2po822MzQ(XHxNHL4lh7q6vVwliXWMifsHclr50qX86mSeF5yhsBYJkuyjobAKgkM)0ekmmFSdDm4QjkBdFzfizJy5cUVwAcfgMlh7qNU3cAKgkM)0ekmmFSdDm4QPvVsXXo0gXYfCFT0ekmmxo2HoTFC4TTH7RLUfjM4KYXo0P7T22RX0VnvtUbAKgkM)0ekmmFSdDm4QzBiit8kkh7qGgPHI5pnHcdZh7qhdUAMfRoYlOYSkg04WbAKgkM)0ekmmFSdDm4Q5jOw5PYrXRyJy5cjlKCSjCvyCR0qX86tqTYtLJIxHo(YQgkyjqJ0qX8NMqHH5JDOJbxnpssVJkh7qyORvmyLuNjBdMWegd]] )
end