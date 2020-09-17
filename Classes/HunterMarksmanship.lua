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
        barrage = 22497, -- 120360
        explosive_shot = 22498, -- 212431

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        steady_focus = 22267, -- 193533
        streamline = 22286, -- 260367
        chimaera_shot = 21998, -- 342049

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shackles = 23463, -- 321468

        lethal_shots = 23063, -- 260393
        dead_eye = 23104, -- 321460
        double_tap = 22287, -- 260402

        calling_the_shots = 22274, -- 260404
        lock_and_load = 22308, -- 194595
        volley = 22288, -- 260243
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {         
        dragonscale_armor = 649, -- 202589
        survival_tactics = 651, -- 202746 
        viper_sting = 652, -- 202797
        scorpid_sting = 653, -- 202900
        spider_sting = 654, -- 202914
        scatter_shot = 656, -- 213691
        hiexplosive_trap = 657, -- 236776
        trueshot_mastery = 658, -- 203129
        roar_of_sacrifice = 3614, -- 53480
        hunting_pack = 3729, -- 203235
        rangers_finesse = 659, -- 248443
        sniper_shot = 660, -- 203155
    } )

    -- Auras
    spec:RegisterAuras( {
        a_murder_of_crows = {
            id = 131894,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_cheetah = {
            id = 186258,
            duration = 9,
            max_stack = 1,
        },
        aspect_of_the_turtle = {
            id = 186265,
            duration = 8,
            max_stack = 1,
        },
        binding_shot = {
            id = 117526,
            duration = 8,
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
            id = 260393,
            duration = 3600,
        },
        lock_and_load = {
            id = 194594,
            duration = 15,
            max_stack = 1,
        },
        lone_wolf = {
            id = 164273,
            duration = 3600,
            max_stack = 1,
        },
        master_marksman = {
            id = 260309,
            duration = 3600,
            max_stack = 1,
        },
        misdirection = {
            id = 34477,
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
            duration = 2,
            max_stack = 1,
        },
        serpent_sting = {
            id = 271788,
            duration = 18,
            type = "Poison",
            max_stack = 1,
        },
        steady_focus = {
            id = 193534,
            duration = 15,
            max_stack = 1,
        },
        streamline = {
            id = 342076,
            duration = 15,
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

    } )


    spec:RegisterStateExpr( "ca_execute", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 70 )
    end )

    spec:RegisterStateExpr( "ca_active", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 70 )
    end )


    local steady_focus_applied = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and ( subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) and spellID == 193534 then -- Steady Aim.
            steady_focus_applied = GetTime()
        end
    end )

    spec:RegisterStateExpr( "last_steady_focus", function ()
        return steady_focus_applied
    end )


    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end

        last_steady_focus = nil
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
            cast = function ()
                if buff.lock_and_load.up then return 0 end
                return 2.5 * haste * ( buff.trueshot.up and 0.5 or 1 ) * ( buff.streamline.up and 0.7 or 1 )
            end,

            charges = 2,
            cooldown = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            recharge = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            gcd = "spell",

            spend = function () return buff.lock_and_load.up and 0 or 35 end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            handler = function ()
                applyBuff( "precise_shots" )
                removeBuff( "lock_and_load" )
                removeBuff( "double_tap" )
                removeBuff( "trick_shots" )
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 132218,

            notalent = "chimaera_shot",

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeStack( "precise_shots" )
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

            start = function ()
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
       
       
        chimaera_shot = {
            id = 342049,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 236176,

            talent = "chimaera_shot",

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeStack( "precise_shots" )
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
            gcd = "off",

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
            cooldown = 120,
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

            talent = "explosive_shot",
            
            handler = function ()
                applyDebuff( "target", "explosive_shot" )
            end,
        },


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
            cooldown = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 236188,

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

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 132330,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                if active_enemies > 2 then applyBuff( "trick_shots" ) end
                removeStack( "precise_shots" )
            end,
        },


        rapid_fire = {
            id = 257044,
            cast = function () return ( 2 * haste ) end,
            channeled = true,
            cooldown = function () return ( buff.trueshot.up and 8 or 20 ) * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 461115,

            start = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "trick_shots" )
                if talent.streamline.enabled then applyBuff( "streamline" ) end
            end,

            finish = function ()
                removeBuff( "double_tap" )                
            end,
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

            handler = function ()
                applyDebuff( "target", "serpent_sting" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",

            spend = -0,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled and prev_gcd[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
                    applyBuff( "steady_focus" )
                    last_steady_focus = query_time
                end
                if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
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
            nomounted = true,

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
            cooldown = 25,
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

            nobuff = function ()
                if settings.trueshot_vop_overlap then return end
                return "trueshot"
            end,

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
        volley = {
            id = 260243,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0,
            spendType = "focus",

            startsCombat = true,
            texture = 132205,

            talent = "volley",

            start = function ()
            end,
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

    
    spec:RegisterSetting( "trueshot_vop_overlap", false, {
        name = "|T132329:0|t Trueshot Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T132329:0|t Trueshot even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Trueshot would cost you one or more uses of Trueshot in a given fight.",
        type = "toggle",
        width = 1.5
    } )  


    spec:RegisterPack( "Marksmanship", 20200916, [[dKuU)aqiOipcLeTjOkFckkAucQoLGYQqjPYRGsMLa1TeKc2fv(fuvddLQJPqwMG4zOKAAcsCnLkTnOO6BcsACOKKZjivRdkk08uOUNa2huHdkifzHOepuqkQlkiL4JOKu0ifKcDsOOGvcfMjkjLCtbPu7eQ0qrjPWsfKs6PQYuHs9vusk1yrjPQ9c5VumykDyrlgvEmstwrxMyZu1NvkJwvDAPwnuuYRrPmBLCBuSBq)wYWvWXHIsTCvEoW0jDDH2Ua57kvnEus48kvSEOIMpQA)igncHn6ntvq4gc7HWo7H(im3nk0zDOmAe6P7miO3qszl3e0dMmc6fANhBaMec(9a6nK7SQCIWg9av8Oc6Xkj2VQdamJ4J)wR)iNJwm4dAM4k1UG0l9k(GMHIp6Xf7LIzaI4qVzQcc3qype2zp0hH5UrHoRdjucv0lJ6Vo071mHMrVFpNceXHEtbqrpwjXgANhBaMec(9aXgAmcv5iyWkj2NmOcdNCe7impyIne2dHD0B1afGWg90RPSb(LcqyJWDecB0lPAxq0JTETmGFPONatULmrSGueUHGWg9sQ2fe9cQwlzh0tGj3sMiwqkcxwJWg9sQ2fe94Y7Ynb9eyYTKjIfKIWnuqyJEjv7cIEcRyyvGoiXa(LIEcm5wYeXcsr4UlcB0tGj3sMiwqp61QCDIECrV3PxtzZa(LcCXbIfpILMMKQDqcXIhXYf9E3SIClXO5GloGEjv7cIEzZitd4xksr4I5iSrpbMClzIyb9OxRY1j6Xf9ENEnLnd4xkWfhiw8i2Wj2eNY1Q48fncKPX3N4eyYTKjXYZtSjoLRvX1qJ(fZ93r)mUlHSrS4GyhrS88eBIt5AvCG4T1Wnd4xkWjWKBjtILNNy1Cjq1b0tsMvdfNatULmj2WqVKQDbrVlh6PX3NGueUHkcB0tGj3sMiwqp61QCDIECrV3PxtzZa(LcCXbIfpInCILl69UHtOnqmGFPa3S2djwEEILw1Aw7HUSzKPb8l15JRL5e6pVnXOnJqSJj2KQDbDzZitd4xQJMa1OnJqS88elx07D6ffWVuxCGydd9sQ2fe9YMrMgWVuKIWLvHWg9eyYTKjIf0JETkxNOhx07D61u2mGFPaxCa9sQ2fe9UCONgFFcsr4g6iSrpbMClzIyb9OxRY1j6Xf9ENEnLnd4xkWnR9qILNNy5IEVB4eAded4xkWfhiw8iwmrSCrV3Pxua)sDXbILNNy9fnciwCqSHk7Oxs1UGOhtCPn4xksr4oIDe2Oxs1UGONVOrGmnjoLRvXWjjd6jWKBjtelifH7OriSrVKQDbrVH41(DA4MHBLaf9eyYTKjIfKIWDuiiSrVKQDbrpAbPcuVuLPXVsgb9eyYTKjIfKIWDeRryJEjv7cIECRQMMYB0VyeOWSd6jWKBjtelifH7OqbHn6jWKBjtelOh9AvUorpUO37oHY2saaJVoQ4IdelppXYf9E3ju2wcay81rfdTIqvohqtkBe7yIDe7Oxs1UGON(fteYvr404RJkifH7ODryJEjv7cIEPHjEt5mL3qVApa9eyYTKjIfKIWDeMJWg9eyYTKjIf0JETkxNO3j(ta)KBjelEelMi2KQDbDa5geOAaAd3Cn04x92xrVKQDbrpGCdcunaTHBifH7OqfHn6LuTli6bujN7ya)srpbMClzIybPif9MIpJlfHnc3riSrVKQDbrpAfHQCgWVu0tGj3sMiwqkc3qqyJEjv7cIE6Lqm7yVAC2Wnd4xk6jWKBjtelifHlRryJEcm5wYeXc6LuTli6TIhBYbmne0ZUIaZw7v0JETkxNOhTQ1S2dD6ffWVu3jmzdbMTOaae7yID0UelppX67TVAoHjBiGyhtSSMD0dMmc6TIhBYbmne0ZUIaZw7vKIWnuqyJEcm5wYeXc6LuTli6L4e8ZlbgFbvt5nd1E5qp61QCDIEHtS(E7RMtyYgciwCqSjv7cAOvTM1EiXIfXY6qHy55jwnVnrDFjx63nqvIDmXgc7elppXQ5TjQtBgXOLzGQMqyNyhtSJ2LydJyXJyPvTM1EOtVOa(L6oHjBiWSffaGyhtSJ2Ly55jwFV9vZjmzdbe7yIL17IEWKrqVeNGFEjW4lOAkVzO2lhsr4UlcB0tGj3sMiwqVKQDbrVveOxfbMTAnfOzyfzYnb9OxRY1j6rRAnR9qNErb8l1Dct2qGzlkaaXoMy3Ly55jwFV9vZjmzdbe7yIne2rpyYiO3kc0RIaZwTMc0mSIm5MGueUyocB0tGj3sMiwqVKQDbrVTCj0CTKdy4QcIE0Rv56e9gojiZgD6g50lkGFPelppXIjIvZLavhnxRgUz0Vya)sbobMClzsS88eRV3(Q5eMSHaIDmXoID0dMmc6TLlHMRLCadxvqKIWnuryJEcm5wYeXc6LuTli6LGFqjuaMlXzDgAD5c9OxRY1j6nCsqMn60nYPxua)sjw8i2WjwUO372I5n7eAkVjXPCL(DXbILNNyXeXkaGaPIJwWPabY0SAV4RJkoMeZQoIfpILMMKQDqcXggXYZtStHl69UlXzDgAD5YmfUO37M1EiXYZtS(E7RMtyYgci2XeBiSJEWKrqVe8dkHcWCjoRZqRlxifHlRcHn6jWKBjtelOxs1UGO3qrztuqJtzAOfZqutTlOzkb1ub9OxRY1j6HjILl69o9Ic4xQloqS4rSyIyfaqGuXXTQAAkVr)IrGcZooMeZQoILNNyNcx07DCRQMMYB0VyeOWSJloqS88eRV3(Q5eMSHaIDmXUl6btgb9gkkBIcACktdTygIAQDbntjOMkifHBOJWg9eyYTKjIf0JETkxNO3Wjbz2Ot3iNErb8lLy55jwmrSAUeO6O5A1WnJ(fd4xkWjWKBjtILNNy992xnNWKneqSJj2qyh9sQ2fe9IaX0QWaqkc3rSJWg9eyYTKjIf0lPAxq0JMRLjPAxqZQbk6TAGAGjJGE0jaPiChncHn6jWKBjtelOh9AvUorVKQDqIrGctlaIDmXYA0lPAxq0JMRLjPAxqZQbk6TAGAGjJGEafPiChfccB0tGj3sMiwqp61QCDIEjv7GeJafMwaeloi2qqVKQDbrpAUwMKQDbnRgOO3QbQbMmc6Pxtzd8lfGuKIEdNqlgUuryJWDecB0tGj3sMiwqkc3qqyJEcm5wYeXcsr4YAe2ONatULmrSGueUHccB0tGj3sMiwqkc3DryJEcm5wYeXc6nCcnbQrBgb9gXo6LuTli6nRi3smAoGueUyocB0tGj3sMiwqpyYiOxItWpVey8funL3mu7Ld9sQ2fe9sCc(5LaJVGQP8MHAVCifHBOIWg9sQ2fe92x3AgK0qZjGcMqQGEcm5wYeXcsr4YQqyJEjv7cIEBX8MDcnL3K4uUs)ONatULmrSGueUHocB0lPAxq0JryQBht5nRiTNM5jjda9eyYTKjIfKIWDe7iSrpbMClzIyb9goHMa1OnJGEJC7IEjv7cIE6ffWVu0JETkxNOxs1oiXiqHPfaXIdIneKIWD0ie2ONatULmrSGEjv7cIEdL2fe9M7atMMAgozOu0Besr4okee2ONatULmrSGE0Rv56e9sQ2bjgbkmTai2XelRrVKQDbrVSzKPb8lfPif9OtacBeUJqyJEcm5wYeXc6rVwLRt0BkCrV39JqvoGHjp2CZApKyXJyXeXYf9ENErb8l1fhqVKQDbrVFeQYbmm5Xgsr4gccB0tGj3sMiwqp61QCDIE0QwZAp0D5qpn((e3jmzdbe7yIDJojwEEILw1Aw7HUlh6PX3N4oHjBiGyhtS0QwZAp0LnJmnGFPUtyYgciwEEI13BF1Cct2qaXoMydHD0lPAxq0BwrULy0CaPiCzncB0tGj3sMiwqp61QCDIEdNeKzJoDJC6ffWVuIfpInCI13BF1Cct2qaXIdILw1Aw7Hoo5aYXwd3CZ4LAxqIflIDgVu7csS88eB4eRM3MOUVKl97gOkXoMydHDILNNyXeXQ5sGQJMN4Jlt2mobMClzsSHrSHrS88eRV3(Q5eMSHaIDmXoI1Oxs1UGOhNCa5yRHBifHBOGWg9eyYTKjIf0JETkxNO3Wjbz2Ot3iNErb8lLyXJydNy992xnNWKneqS4GyPvTM1EOJBv104J3oUz8sTliXIfXoJxQDbjwEEInCIvZBtu3xYL(DduLyhtSHWoXYZtSyIy1Cjq1rZt8XLjBgNatULmj2Wi2WiwEEI13BF1Cct2qaXoMyhH5Oxs1UGOh3QQPXhVDqkc3DryJEcm5wYeXc6rVwLRt0B4KGmB0PBKtVOa(LsS4rSHtS(E7RMtyYgciwCqS0QwZAp0LqQa0lxgAUwUz8sTliXIfXoJxQDbjwEEInCIvZBtu3xYL(DduLyhtSHWoXYZtSyIy1Cjq1rZt8XLjBgNatULmj2Wi2WiwEEI13BF1Cct2qaXoMyhH5Oxs1UGOxcPcqVCzO5AHueUyocB0tGj3sMiwqp61QCDIEdNeKzJoDJC6ffWVuIfpInCI13BF1Cct2qaXIdILw1Aw7HoFFc3QQPBgVu7csSyrSZ4LAxqILNNydNy182e19LCPF3avj2XeBiStS88elMiwnxcuD08eFCzYMXjWKBjtInmInmILNNy992xnNWKneqSJj2qh9sQ2fe989jCRQMifHBOIWg9eyYTKjIf0JETkxNOhx07D6ffWVu3S2drVKQDbrVvV9vGbZko3yeOIueUSke2ONatULmrSGE0Rv56e94IEVtVOa(L6M1Ei6LuTli6XLBMYB0RPSbqkc3qhHn6jWKBjtelOh9AvUorpUO370lkGFPUzThsS4rSHtSAEBI6(sU0VBGQeloiwwf7elppXQ5TjQ7l5s)UbQsSJdqSHWoXYZtSAEBI60MrmAzgOQje2jwCqSSMDInm0lPAxq07KCOHBg)kzeasr4oIDe2ONatULmrSGE0Rv56e9cNyPvTM1EOlXj4Nxcm(cQMYBgQ9Y5oHjBiGyXbXgc7elppXIjIvWSJ9WGmDjob)8sGXxq1uEZqTxoILNNy992xnNWKneqSJjwAvRzTh6sCc(5LaJVGQP8MHAVCUz8sTliXIfXY6qHyXJy182e19LCPF3avjwCqSHWoXggXIhXgoXsRAnR9qNErb8l1Dct2qGzlkaaXoMyznXYZtSHtScaiqQ4cQbDbnL3miNxOAxqhtdRJyXJy992xnNWKneqS4GytQ2f0qRAnR9qIflILl69U91TMbjn0CcOGjKkUz8sTliXggXggXYZtS(E7RMtyYgci2XeBiSJEjv7cIE7RBndsAO5eqbtivqkc3rJqyJEcm5wYeXc6rVwLRt0lCILMMKQDqcXYZtS(E7RMtyYgciwCqSjv7cAOvTM1EiXIfXYA2j2Wiw8i2WjwUO370lkGFPU4aXYZtS0QwZAp0Pxua)sDNWKneqSJj2ryoXggXYZtS(E7RMtyYgci2XelRhHEjv7cIEBX8MDcnL3K4uUs)ifH7OqqyJEcm5wYeXc6rVwLRt0Jw1Aw7Ho9Ic4xQ7eMSHaIDmXgQOxs1UGO31ddlX0qdyiPcsr4oI1iSrpbMClzIyb9OxRY1j6HjILl69o9Ic4xQloGEjv7cIEmctD7ykVzfP90mpjzaifH7OqbHn6jWKBjtelOh9AvUorpUO370lkGFPUtsQsS4rSCrV3XTQAUIa1DssvILNNyhojiZgD6g50lkGFPelEeRM3MOUVKl97gOkXoMydHDILNNydNydNyPfeezsUL4gkTlOP8MiK765sMgF82Hy55jwAbbrMKBjUiK765sMgF82HydJyXJy992xnNWKneqSJjwmFeXYZtS(E7RMtyYgci2XeBiyoXgg6LuTli6nuAxqKIWD0UiSrpbMClzIyb9OxRY1j6Xf9ENErb8l1nR9qIfpILw1Aw7HUlh6PX3N4oHjBiGy55jwFV9vZjmzdbe7yID0UOxs1UGONErb8lfPif9akcBeUJqyJEjv7cIES1RLb8lf9eyYTKjIfKIWnee2Oxs1UGONWkgwfOdsmGFPONatULmrSGueUSgHn6jWKBjtelOh9AvUorVKQDqIrGctlaIfhe7i0lPAxq0JlVl3eKIWnuqyJEjv7cIEPHjEt5mL3qVApa9eyYTKjIfKIWDxe2Oxs1UGOxq1Aj7GEcm5wYeXcsr4I5iSrpbMClzIyb9OxRY1j6DI)eWp5wcXIhXIjInPAxqhqUbbQgG2Wnxdn(vV9v0lPAxq0di3GavdqB4gsr4gQiSrpbMClzIyb9OxRY1j6Xf9ENErb8l1nR9qILNNy9fnci2XelR3Ly55jwFrJaIDmXI5StS4rSyIy1Cjq1Te9Nld4xkWjWKBjtILNNy5IEVRHg9lM7VJ(zCNWKneqSJjwHvi0OkgTze0lPAxq07YHEA89jifHlRcHn6jWKBjtelOh9AvUorpUO370lkGFPU4aXIhXgoXYf9Exek31WntqnOlOdOjLnIfheBOqS88elMi2eNY1Q4Iq5UgUzcQbDbDcm5wYKydJy55jwFV9vZjmzdbe7yID0i0lPAxq0JBv10uEJ(fJafMDqkc3qhHn6jWKBjtelOh9AvUorpmrSCrV3Pxua)sDXbILNNy992xnNWKneqSJj2DrVKQDbrpFrJazAsCkxRIHtsgKIWDe7iSrpbMClzIyb9OxRY1j6Xf9ENErb8l1fhiw8iwmrSCrV3Xim1TJP8MvK2tZ8KKb4IdOxs1UGOxE0ekgWVuKIWD0ie2ONatULmrSGE0Rv56e94IEVtVOa(L6IdelEelMiwUO37yeM62XuEZks7PzEsYaCXb0lPAxq0J(BMuU0a(LIueUJcbHn6jWKBjtelOh9AvUorpUO370lkGFPU4aXYZtSHtSCrV3nRi3smAo4M1EiXYZtS00KuTdsi2Wiw8iwUO37goH2aXa(LcCZApKy55jwFCTmNq)5TjgTzeIDmXstGA0Mriw8iwAvRzTh60lkGFPUtyYgcqVKQDbrVSzKPb8lfPiChXAe2ONatULmrSGE0Rv56e94IEVtVOa(L6IdelEelx07DmctD7ykVzfP90mpjzaU4a6LuTli6LhnHIb8lfPiChfkiSrpbMClzIyb9OxRY1j6Xf9ENErb8l1fhiw8iwUO37yeM62XuEZks7PzEsYaCXb0lPAxq0J(BMuU0a(LIueUJ2fHn6jWKBjtelOh9AvUorpmrSCrV3Pxua)sDXbILNNy992xnNWKneqSJjwwf6LuTli6neV2Vtd3mCReOifH7imhHn6jWKBjtelOh9AvUorpFrJaIflI1x0iWDYMajwwDe7gDsSJjwFrJahtYkiw8iwUO370lkGFPUzThsS4rSHtSyIyNL6OfKkq9svMg)kzedx8GUtyYgciw8iwmrSjv7c6OfKkq9svMg)kzexdn(vV9vInmILNNy9X1YCc9N3My0Mri2Xe7gDsS88eRV3(Q5eMSHaIDmXUl6LuTli6rlivG6LQmn(vYiifH7OqfHn6jWKBjtelOh9AvUorpUO37oHY2saaJVoQ4IdelppXYf9E3ju2wcay81rfdTIqvohqtkBe7yIDe7elppX67TVAoHjBiGyhtS7IEjv7cIE6xmrixfHtJVoQGueUJyviSrpbMClzIyb9OxRY1j6Xf9ENErb8l1nR9qIfpInCILl69UHtOnqmGFPaxCGyXJydNy9fnciwCqS7UlXggXYZtS(Igbeloi2qDxILNNy992xnNWKneqSJj2Dj2WqVKQDbrV8OjumGFPifH7OqhHn6jWKBjtelOh9AvUorpUO370lkGFPUzThsS4rSHtSCrV3nCcTbIb8lf4IdelEeB4eRVOraXIdID3Dj2WiwEEI1x0iGyXbXgQ7sS88eRV3(Q5eMSHaIDmXUlXgg6LuTli6r)ntkxAa)srkc3qyhHn6LuTli6bujN7ya)srpbMClzIybPifPOxqYb6cIWne2dHD2d9rSg92NhSHBa0Jv7qtHwXfZaUSAIzKyjwS)cX2md1PeRVoIfZKobyMe7jy2X(KjXckgHyZOwmPktIL(t4MaCemy1QHcXoIDmJeBO5cgKCQmjwmt9AiBI6y17OvTM1EiMjXQfXIzsRAnR9qhREmtIn8qyfH5iyqWaZaZqDQmj2Dj2KQDbj2vduGJGb6nCLVxc6Xkj2q78ydWKqWVhi2qJrOkhbdwjX(Kbvy4KJyhX6Gj2qype2jyqWGvsSHwyfcnQYKy5eFDcXslgUujwozRHahXgAIsLbfqSWcgA4NhJpUi2KQDbbeBbx74iyKuTliWnCcTy4snGFLa2iyKuTliWnCcTy4sfRa4NXngbQP2fKGrs1UGa3Wj0IHlvScGVVQjbdwjX(G5a4xkXEzpjwUO3ltIfOPciwoXxNqS0IHlvILt2AiGyt4Kyhoj0WqPAd3i2gqSZckocgjv7ccCdNqlgUuXka(ayoa(LAaAQacgSsILvJtOjqjw93aInbeRK3AhInbe7qban3siwTi2HsfO25ATdXULnKytyPF5iwAcuIDgVgUrS6xiwFV9vhbJKQDbbUHtOfdxQyfa)zf5wIrZHGhoHMa1OnJeye7emsQ2fe4goHwmCPIva8JaX0QWemmzKajob)8sGXxq1uEZqTxocgjv7ccCdNqlgUuXka(7RBndsAO5eqbtiviyKuTliWnCcTy4sfRa4VfZB2j0uEtIt5k9tWiPAxqGB4eAXWLkwbWNryQBht5nRiTNM5jjdGGrs1UGa3Wj0IHlvScGVErb8ln4HtOjqnAZibg52n42hiPAhKyeOW0cahHqWiPAxqGB4eAXWLkwbWFO0UGbp3bMmn1mCYqPbgrWiPAxqGB4eAXWLkwbWpBgzAa)sdU9bsQ2bjgbkmTagZAcgemyLeBOfwHqJQmjwji52Hy1Mriw9leBs16i2gqSzqzVsUL4iyKuTliiaTIqvod4xkbJKQDbbyfaF9siMDSxnoB4Mb8lLGrs1UGaScGFeiMwfMGHjJeyfp2KdyAiONDfbMT2Rb3(a0QwZAp0Pxua)sDNWKney2IcamE0U88(E7RMtyYgcgZA2jyKuTliaRa4hbIPvHjyyYibsCc(5LaJVGQP8MHAVCb3(aH77TVAoHjBiah0QwZApelwhk88AEBI6(sU0VBGQJdHDEEnVnrDAZigTmdu1ec7JhTBy4rRAnR9qNErb8l1Dct2qGzlkaW4r7YZ77TVAoHjBiymR3LGrs1UGaScGFeiMwfMGHjJeyfb6vrGzRwtbAgwrMCtcU9bOvTM1EOtVOa(L6oHjBiWSffay8U88(E7RMtyYgcghc7emsQ2feGva8JaX0QWemmzKaB5sO5AjhWWvfm42hy4KGmB0PBKtVOa(LYZJjnxcuD0CTA4Mr)Ib8lf4eyYTKjpVV3(Q5eMSHGXJyNGrs1UGaScGFeiMwfMGHjJeib)GsOamxIZ6m06YvWTpWWjbz2Ot3iNErb8lfVW5IEVBlM3StOP8MeNYv63fh45XKaacKkoAbNceitZQ9IVoQ4ysmR6WJMMKQDqsy88tHl69UlXzDgAD5YmfUO37M1EipVV3(Q5eMSHGXHWobJKQDbbyfa)iqmTkmbdtgjWqrztuqJtzAOfZqutTlOzkb1uj42hatCrV3Pxua)sDXb8WKaacKkoUvvtt5n6xmcuy2XXKyw1XZpfUO374wvnnL3OFXiqHzhxCGN33BF1Cct2qW4DjyWkjwSVDiwTi2vdfInoqSjv7GsvMeREnKnrbe7(w)el2xua)sjyKuTliaRa4hbIPvHbeC7dmCsqMn60nYPxua)s55XKMlbQoAUwnCZOFXa(LcCcm5wYKN33BF1Cct2qW4qyNGrs1UGaScGpnxlts1UGMvd0GHjJeGobemsQ2feGva8P5AzsQ2f0SAGgmmzKaan42hiPAhKyeOW0cymRjyKuTliaRa4tZ1YKuTlOz1anyyYib0RPSb(LccU9bsQ2bjgbkmTaWriemiyKuTliWrNGa)iuLdyyYJTGBFGPWf9E3pcv5agM8yZnR9q8Wex07D6ffWVuxCGGrs1UGahDcWka(ZkYTeJMdb3(a0QwZAp0D5qpn((e3jmzdbJ3OtEEAvRzTh6UCONgFFI7eMSHGX0QwZAp0LnJmnGFPUtyYgc45992xnNWKnemoe2jyKuTliWrNaScGpNCa5yRHBb3(adNeKzJoDJC6ffWVu8c33BF1Cct2qaoOvTM1EOJtoGCS1Wn3mEP2feRz8sTlipF4AEBI6(sU0VBGQJdHDEEmP5sGQJMN4Jlt2mobMClzgwy88(E7RMtyYgcgpI1emsQ2fe4OtawbWNBv104J3ob3(adNeKzJoDJC6ffWVu8c33BF1Cct2qaoOvTM1EOJBv104J3oUz8sTliwZ4LAxqE(W182e19LCPF3avhhc788ysZLavhnpXhxMSzCcm5wYmSW45992xnNWKnemEeMtWiPAxqGJobyfa)esfGE5YqZ1k42hy4KGmB0PBKtVOa(LIx4(E7RMtyYgcWbTQ1S2dDjKka9YLHMRLBgVu7cI1mEP2fKNpCnVnrDFjx63nq1XHWoppM0Cjq1rZt8XLjBgNatULmdlmEEFV9vZjmzdbJhH5emsQ2fe4OtawbW33NWTQAgC7dmCsqMn60nYPxua)sXlCFV9vZjmzdb4Gw1Aw7HoFFc3QQPBgVu7cI1mEP2fKNpCnVnrDFjx63nq1XHWoppM0Cjq1rZt8XLjBgNatULmdlmEEFV9vZjmzdbJdDcgjv7ccC0jaRa4V6TVcmywX5gJa1GBFaUO370lkGFPUzThsWiPAxqGJobyfaFUCZuEJEnLnqWTpax07D6ffWVu3S2djyKuTliWrNaScG)j5qd3m(vYiGGBFaUO370lkGFPUzThIx4AEBI6(sU0VBGQ4GvXopVM3MOUVKl97gO64aHWopVM3MOoTzeJwMbQAcHDCWA2dJGrs1UGahDcWka(7RBndsAO5eqbtivcU9bcxVgYMOUeNGFEjW4lOAkVzO2lNJw1Aw7HUtyYgcWriSZZJjbZo2ddY0L4e8ZlbgFbvt5nd1E545992xnNWKnemwVgYMOUeNGFEjW4lOAkVzO2lNJw1Aw7HUz8sTliwSouWtZBtu3xYL(DdufhHWEy4foTQ1S2dD6ffWVu3jmzdbMTOaaJznpF4caiqQ4cQbDbnL3miNxOAxqhtdRdpFV9vZjmzdb4Gw1Aw7HyXf9E3(6wZGKgAobuWesf3mEP2fmSW45992xnNWKnemoe2jyKuTliWrNaScG)wmVzNqt5njoLR0FWTpq400KuTds45992xnNWKneGdAvRzThIfRzpm8cNl69o9Ic4xQloWZtRAnR9qNErb8l1Dct2qW4ryEy88(E7RMtyYgcgZ6remsQ2fe4OtawbW)6HHLyAObmKuj42hGw1Aw7Ho9Ic4xQ7eMSHGXHkbJKQDbbo6eGva8zeM62XuEZks7PzEsYacU9bWex07D6ffWVuxCGGrs1UGahDcWka(dL2fm42hGl69o9Ic4xQ7KKQ4Xf9Eh3QQ5kcu3jjv55hojiZgD6g50lkGFP4P5TjQ7l5s)UbQooe255dpCAbbrMKBjUHs7cAkVjc5UEUKPXhVD45PfeezsUL4IqURNlzA8XBNWWZ3BF1Cct2qWymFepVV3(Q5eMSHGXHG5HrWiPAxqGJobyfaF9Ic4xAWTpax07D6ffWVu3S2dXJw1Aw7HUlh6PX3N4oHjBiGN33BF1Cct2qW4r7sWGGrs1UGahqdWwVwgWVucgjv7ccCafRa4lSIHvb6Ged4xkbJKQDbboGIva85Y7Ynj42hiPAhKyeOW0cahJiyKuTliWbuScGFAyI3uot5n0R2diyKuTliWbuScGFq1Aj7qWiPAxqGdOyfaFGCdcunaTHBb3(aN4pb8tULGhMsQ2f0bKBqGQbOnCZ1qJF1BFLGrs1UGahqXka(xo0tJVpj42hGl69o9Ic4xQBw7H88(IgbJz9U88(IgbJXC2XdtAUeO6wI(ZLb8lf4eyYTKjppx07Dn0OFXC)D0pJ7eMSHGXcRqOrvmAZiemsQ2fe4akwbWNBv10uEJ(fJafMDcU9b4IEVtVOa(L6Id4fox07DrOCxd3mb1GUGoGMu2WrOWZJPeNY1Q4Iq5UgUzcQbDbDcm5wYmmEEFV9vZjmzdbJhnIGrs1UGahqXka((IgbY0K4uUwfdNKmb3(ayIl69o9Ic4xQloWZ77TVAoHjBiy8UemsQ2fe4akwbWppAcfd4xAWTpax07D6ffWVuxCapmXf9EhJWu3oMYBwrApnZtsgGloqWiPAxqGdOyfaF6Vzs5sd4xAWTpax07D6ffWVuxCapmXf9EhJWu3oMYBwrApnZtsgGloqWiPAxqGdOyfa)SzKPb8ln42hGl69o9Ic4xQloWZhox07DZkYTeJMdUzThYZttts1oijm84IEVB4eAded4xkWnR9qEEFCTmNq)5TjgTzKX0eOgTze8OvTM1EOtVOa(L6oHjBiGGrs1UGahqXka(5rtOya)sdU9b4IEVtVOa(L6Id4Xf9EhJWu3oMYBwrApnZtsgGloqWiPAxqGdOyfaF6Vzs5sd4xAWTpax07D6ffWVuxCapUO37yeM62XuEZks7PzEsYaCXbcgjv7ccCafRa4peV2Vtd3mCReOb3(ayIl69o9Ic4xQloWZ77TVAoHjBiymRIGrs1UGahqXka(0csfOEPktJFLmsWTpGVOraw(IgbUt2eiRUn6CSVOrGJjzf4Xf9ENErb8l1nR9q8chtZsD0csfOEPktJFLmIHlEq3jmzdb4HPKQDbD0csfOEPktJFLmIRHg)Q3(Ay88(4AzoH(ZBtmAZiJ3OtEEFV9vZjmzdbJ3LGrs1UGahqXka(6xmrixfHtJVoQeC7dWf9E3ju2wcay81rfxCGNNl69UtOSTeaW4RJkgAfHQCoGMu2gpIDEEFV9vZjmzdbJ3LGrs1UGahqXka(5rtOya)sdU9b4IEVtVOa(L6M1EiEHZf9E3Wj0gigWVuGloGx4(Igb4y3DdJN3x0iahH6U88(E7RMtyYgcgVByemsQ2fe4akwbWN(BMuU0a(LgC7dWf9ENErb8l1nR9q8cNl69UHtOnqmGFPaxCaVW9fncWXU7ggpVVOraoc1D55992xnNWKnemE3WiyKuTliWbuScGpqLCUJb8lLGbbJKQDbbo9AkBGFPGaS1RLb8lLGrs1UGaNEnLnWVuawbWpOATKDiyKuTliWPxtzd8lfGva85Y7YnHGrs1UGaNEnLnWVuawbWxyfdRc0bjgWVucgjv7ccC61u2a)sbyfa)SzKPb8ln42hGl69o9AkBgWVuGloGhnnjv7Ge84IEVBwrULy0CWfhiyKuTliWPxtzd8lfGva8VCONgFFsWTpax07D61u2mGFPaxCaVWtCkxRIZx0iqMgFFItGj3sM88joLRvX1qJ(fZ93r)mUlHSHJr88joLRvXbI3wd3mGFPaNatULm551Cjq1b0tsMvdfNatULmdJGrs1UGaNEnLnWVuawbWpBgzAa)sdU9b4IEVtVMYMb8lf4Id4fox07DdNqBGya)sbUzThYZtRAnR9qx2mY0a(L68X1YCc9N3My0MrgNuTlOlBgzAa)sD0eOgTzeEEUO370lkGFPU4qyemsQ2fe40RPSb(LcWka(xo0tJVpj42hGl69o9AkBgWVuGloqWiPAxqGtVMYg4xkaRa4ZexAd(LgC7dWf9ENEnLnd4xkWnR9qEEUO37goH2aXa(LcCXb8Wex07D6ffWVuxCGN3x0iahHk7emsQ2fe40RPSb(LcWka((IgbY0K4uUwfdNKmemsQ2fe40RPSb(LcWka(dXR970Wnd3kbkbJKQDbbo9AkBGFPaScGpTGubQxQY04xjJqWiPAxqGtVMYg4xkaRa4ZTQAAkVr)IrGcZoemsQ2fe40RPSb(LcWka(6xmrixfHtJVoQeC7dWf9E3ju2wcay81rfxCGNNl69UtOSTeaW4RJkgAfHQCoGMu2gpIDcgjv7ccC61u2a)sbyfa)0WeVPCMYBOxThqWiPAxqGtVMYg4xkaRa4dKBqGQbOnCl42h4e)jGFYTe8Wus1UGoGCdcunaTHBUgA8RE7RemsQ2fe40RPSb(LcWka(avY5ogWVu0dmiueUHSBOGuKIqa]] )


end