-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 254 )

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
            duration = 4,
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
            id = 193526,
            duration = 15,
            max_stack = 1,
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
            cooldown = 12,
            recharge = 12,
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
            
            handler = function ()
                removeBuff( "steady_focus" )
            end,
        },
        

        explosive_shot_detonate = {
            id = 212679,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1044088,
            
            usable = function () return prev_gcd[1].explosive_shot end,
            handler = function ()
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
            cast = function () return 3 * ( talent.streamline.enabled and 1.3 or 1 ) * haste end,
            channeled = true,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 461115,
            
            handler = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "lethal_shots" )
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
            
            startsCombat = true,
            texture = 132213,
            
            handler = function ()
                if talent.steady_focus.enabled then applyBuff( "steady_focus", 12, min( 2, buff.steady_focus.stack + 1 ) ) end
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


    spec:RegisterPack( "Marksmanship", 20180911.2239, [[dK0(GaqibjpsqvBIe1NeeQrbiofaAvcc0RaOzrs1TiPODrPFrHgMGYXavTmjvEMKQMgjfUgOI2gOs(gOcJJKsoNGiRJKsnpaP7rc7daoOGGwiG6HGkLlkiGpcQuLrckQojOO0kPGzcQuXnfuXoLugQGOwQGk9ujMQK0vbff9vqLQAVs9xfgSqhMQfd0JHAYk6YeBwfFwsmAv60QA1GIcVMez2K62u0UH8BLgUahhuPslhvpx00rUoiBhu47GsJhuKZli16feY8jj7hLB47QDz6K01Qlm4vRWcj4H3wxD1hs1vFxOqhiDjWXk5vKUGCtPlHJZvknDuE)GUe4HwV(SR2LCH4yPlHNfVefKQTrJvE6cbAXRPX8nH0o9lcZ9dzmFtSrq9cAe84Q5uGHXa(EETKgdzUeU(ptJHC4oG5qis4JWX5kLMokVFGnFtCxaHEnbZIAWUmDs6A1fg8QvyHe8WBRRU6Qd(qQloeDxExkVjCRltjXDj8Sy44CLsthL3pGfH5qis4mdHNfVefKQTrJvE6cbAXRPX8nH0o9lcZ9dzmFtSrq9cAe84Q5uGHXa(EETKgdzUeU(ptJHC4oG5qis4JWX5kLMokVFGnFtmZq4zXIeqIjOWzr4HxDwSUWGxTyr1KfHpm1UUWyXqoCygygcplc3UoQIKQnZq4zr1KfdHZPmzr42cHiHZIL7s2UO)KYUAxi(JvkVlLD1Ug8D1U4y6xuxaDo3RiDrqoOwMnWn11QRR2fht)I6Iatb6nFyiJ8UuxeKdQLzdCtDT67QDrqoOwMnWDbZFs4V3fqOZXs8hR0iVlLwOawuzwmuSi5AbrwqNZ9kIvqoOwMDXX0VOUW9GFoopxAQRPgD1UiihulZg4UG5pj837ci05yj(JvAK3LslualQmlccDo2aUG)ug5DP0oxyrSOYSii05yNleOwgKhyNlSiwuzweiSyOyrY1cISAHUUEK3LsRGCqTmzrvQyrqOZXQf666rExkTqbSOkvS4zXqjlcaweUcJfbyxCm9lQl(BkZrExQPUgC2v7IGCqTmBG7cM)KWFVlGqNJL4pwPrExkTqbDXX0VOUW9GFoopxAQRbxD1UiihulZg4UG5pj837ci05yj(JvAK3Ls7CHfXIQuXIaHfbHohBaxWFkJ8UuAHcyrvQyrqOZXQf666rExkTqbSiazrLzrGWIHIfjxliYc6CUxrScYb1YKfvMfbHohBsIpd94SyO0oxyrSOYS4zXqjlcawunGtwuLkw8SyOKfbalchHXIaSloM(f1ftin95DPM6AWrxTloM(f1LGx44hvzK3L6IGCqTmBGBQRPwD1U4y6xux8HjeFk8XEgy(cB2fb5GAz2a3uxlK6QDrqoOwMnWDbZFs4V3fUC4sEDqT0fht)I6sk8abrJKEuLM6AWhwxTlcYb1YSbUly(tc)9UCwmuYIaYIypPbxQiiweOS4zXqP10HjwuLkweiSi5AbrwTqxxpY7sPvqoOwMSOYSii05y1cDD9iVlL25clIfbyxCm9lQljj(m0J8Uutn1LPCCin1v7AW3v7IJPFrDXHODK3L6IGCqTmBGBQRvxxTloM(f1f8cHiHpY7sDrqoOwMnWn11QVR2fht)I6cukJNeZSlcYb1YSbUPUMA0v7IGCqTmBG7IJPFrDb7A9WX0VOH(tQl6pPbYnLUGNztDn4SR2fb5GAz2a3fht)I6c216HJPFrd9NuxW8Ne(7DXX0ddziiX8LKfbklwFx0FsdKBkDjPM6AWvxTlcYb1YSbUloM(f1fSR1dht)Ig6pPUG5pj837IJPhgYqqI5ljlcawSUUO)Kgi3u6cXFSs5DPSPM6saxWRjOtD1Ug8D1UiihulZg4M6A11v7IGCqTmBGBQRvFxTlcYb1YSbUPUMA0v7IGCqTmBG7cM)KWFVloMEyidbjMVKSiqzX67IJPFrDjHmnx0iqOM6AWzxTlcYb1YSbUPUgC1v7IJPFrDjyPFrDrqoOwMnWn11GJUAxCm9lQlxiej8Cy6CL6IGCqTmBGBQRPwD1UiihulZg4UeWfSN0GEtPlWzxCm9lQlZfculdYdAQRfsD1UiihulZg4UG5pj837IJPhgYqqI5ljlcuwS(U4y6xux83uMJ8UutDn4dRR2fb5GAz2a3fm)jH)ExCm9WqgcsmFjzraWI11fht)I6Iatb6nFyiJ8Uutn1f8m7QDn47QDrqoOwMnWDbZFs4V3LPacDo2leIeEomDUs25clQloM(f1LleIeEomDUsn11QRR2fb5GAz2a3fm)jH)ExW7QNlSil3d(548CXYft)rjlcuwScE2fht)I6YCHa1YG8GM6A13v7IGCqTmBG7cM)KWFVl4D1ZfwKL4qsExYYft)rjlcawS(W6IJPFrDbu4PWv6rvAQRPgD1UiihulZg4UG5pj837cEx9CHfzjoKK3LSCX0FuYIaGfRpSU4y6xuxa17ohhiEOBQRbND1UiihulZg4UG5pj837cEx9CHfzjoKK3LSCX0FuYIaGfRpSU4y6xuxCewsI76b216M6AWvxTlcYb1YSbUly(tc)9UG3vpxyrwIdj5Djlxm9hLSiayX6dRloM(f1LZZfq9UZM6AWrxTloM(f1f9x5s5aMb0SIPGOUiihulZg4M6AQvxTlcYb1YSbUly(tc)9Uaewee6CSehsY7swU4yIfvMfbHohlOE3PgkjlxCmXIaKfvPIfbclceweVOeY0b1InGV6fvrMJGfwHZIkZIKZRiKLEtzq7y(clcuweUQJfbilQsflsoVIqw6nLbTJ5lSiqzX6HNfbyxCm9lQlbl9lQPUwi1v7IGCqTmBG7cM)KWFVl4D1ZfwK1FtzoY7sw815vKKfbklcplQsflsUwqKf05CVIyfKdQLjlQmlI3vpxyrw)nL5iVlzXxNxrYXH7y6xKRzrGYIWBRVloM(f1fIdj5DPMAQlj1v7AW3v7IJPFrDrGPa9MpmKrExQlcYb1YSbUPUwDD1UiihulZg4UG5pj837IJPhgYqqI5ljlcawe(U4y6xuxaDo3Rin11QVR2fb5GAz2a3fm)jH)ExaHohBaxWFkJ8UuAHcyrLzrGWI4D1ZfwK1FtzoY7s2dKwp4c(68kYGEtHfbklwbpzXqqwee6CSbCb)PmY7sPnjhRelcil6y6xK1FtzoY7swSN0GEtHfvPIfbHohRwORRh5DP0cfWIaSloM(f1fNJDKmY7sn11uJUAxeKdQLzdCxW8Ne(7DbiSyOyrY1cISAHUUEK3LsRGCqTmzrvQyrqOZXQf666rExkTqbSiazrLzrpej8Ne7zXqPmhNNlwb5GAzYIQuXIEis4pj2hnORm43qtxtl3rkXIaGfHVloM(f1fUh8ZX55stDn4SR2fb5GAz2a3fm)jH)ExaHohBaxWFkJ8UuANlSiwuzweiSii05yNleOwgKhyNlSiwuzw8aP1dUGVoVImO3uyrGYIypPb9MclcilwbpzrvQyrqOZXQf666rExkTqbSia7IJPFrDXFtzoY7sn11GRUAxeKdQLzdCxW8Ne(7DjuSi5AbrwTqxxpY7sPvqoOwMSOkvSii05y1cDD9iVlLwOGU4y6xux4EWphNNln11GJUAxCm9lQlbVWXpQYiVl1fb5GAz2a3uxtT6QDXX0VOU4dti(u4J9mW8f2SlcYb1YSbUPUwi1v7IGCqTmBG7cM)KWFVlC5WL86GAPloM(f1Lu4bcIgj9Okn11GpSUAxeKdQLzdCxW8Ne(7Dbe6CSbCb)PmY7sPDUWIyrLzrGWIHIfjxliYMK4ZqpolgkTcYb1YKfvMfplgkzraWIWrySOkvSyOyrY1cISAHUUEK3LsRGCqTmzrvQyrqOZXQf666rExkTqbSia7IJPFrDXFtzoY7sn11Gh(UAxeKdQLzdCxW8Ne(7Dbe6CSbCb)PmY7sPfkGfvPIfplgkzraWIWvySOYSiqyXqXIKRfez1cDD9iVlLwb5GAzYIQuXIGqNJvl011J8UuAHcyra2fht)I6IZXosg5DPM6AWxxxTlcYb1YSbUly(tc)9UCwmuYIaYIypPbxQiiweOS4zXqP10HjwuLkweiSi5AbrwTqxxpY7sPvqoOwMSOYSii05y1cDD9iVlL25clIfbyxCm9lQljj(m0J8UutDn4RVR2fht)I6IZXosg5DPUiihulZg4MAQPUadHN)I6A1fg8QvyWb8WHnm4vd4OlW6C0JQKDbUFimCRbZwdUNAZISy1RWIVzWYjw8SCwmepLJdPPqmlYf4UqpxMSyUMcl6q0A6Kmzr81rvK0Yma35rclcVAZIWmrjuqWYjzYIoM(fXIHyhI2rExkeBzgygGzndwojtweozrht)Iyr9NuAzg6sgi4UwDWPA0La(EET0LWZIHJZvknDuE)aweMdHiHZmeEw8suqQ2gnw5PleOfVMgZ3es70Vim3pKX8nXgb1lOrWJRMtbggd4751sAmK5s46)mngYH7aMdHiHpchNRuA6O8(b28nXmdHNflsajMGcNfHhE1zX6cdE1Ifvtwe(Wu76cJfd5WHzGzi8SiC76OksQ2mdHNfvtwmeoNYKfHBleIeolwUlzzgygyXqaysWqKmzrq5SCHfXRjOtSiOu5rPLfdHySeqjlIwKAEDU5bsZIoM(fLS4I0H2Ym4y6xuAd4cEnbDsXr7PsmdoM(fL2aUGxtqNauHrhQIPGiN(fXm4y6xuAd4cEnbDcqfgp7ozgCm9lkTbCbVMGobOcJjKP5IgbcP(Fu4y6HHmeKy(sc06zgcplwqEqExIf5(pzrqOZrMSysoLSiOCwUWI41e0jweuQ8OKfD0Kfd4IAgSe9OkS4NS4CrILzWX0VO0gWf8Ac6eGkmMipiVlnsYPKzWX0VO0gWf8Ac6eGkmgS0ViMbht)IsBaxWRjOtaQW4fcrcphMoxjMbht)IsBaxWRjOtaQW4CHa1YG8a1d4c2tAqVPOaozgCm9lkTbCbVMGobOcJ(BkZrExs9)OWX0ddziiX8LeO1Zm4y6xuAd4cEnbDcqfgfykqV5ddzK3Lu)pkCm9WqgcsmFjbqDmdmdHNfdbGjbdrYKffyi8qZI0BkSiDfw0X0YzXpzrhg(RDqTyzgCm9lkv4q0oY7smdoM(fLaQWiEHqKWh5DjMbht)IsavyekLXtIzYm4y6xucOcJyxRhoM(fn0FsQJCtrbEMmdoM(fLaQWi216HJPFrd9NK6i3uuKK6)rHJPhgYqqI5ljqRNzWX0VOeqfgXUwpCm9lAO)Kuh5MIcI)yLY7sP6)rHJPhgYqqI5ljaQJzGzWX0VO0INPIleIeEomDUsQ)hftbe6CSxiej8Cy6CLSZfweZGJPFrPfptavyCUqGAzqEG6)rbEx9CHfz5EWphNNlwUy6pkbAf8KzWX0VO0INjGkmck8u4k9OkQ)hf4D1ZfwKL4qsExYYft)rjaQpmMbht)IslEMaQWiOE354aXdT6)rbEx9CHfzjoKK3LSCX0FucG6dJzWX0VO0INjGkm6iSKe31dSR1Q)hf4D1ZfwKL4qsExYYft)rjaQpmMbht)IslEMaQW455cOE3P6)rbEx9CHfzjoKK3LSCX0FucG6dJzWX0VO0INjGkmQ)kxkhWmGMvmfeXm4y6xuAXZeqfgdw6xK6)rbqaHohlXHK8UKLloMuge6CSG6DNAOKSCXXeavPciabVOeY0b1InGV6fvrMJGfwHRm58kczP3ug0oMVau4QoaQsf58kczP3ug0oMVa06HhGmdoM(fLw8mbuHrIdj5Dj1)Jc8U65clY6VPmh5Djl(68kscu4vPICTGilOZ5EfXkihultLX7QNlSiR)MYCK3LS4RZRi54WDm9lY1afEB9mdmdoM(fL2KuiWuGEZhgYiVlXm4y6xuAtcqfgbDo3RiQ)hfoMEyidbjMVKaaEMbht)IsBsaQWOZXosg5Dj1)JcqOZXgWf8NYiVlLwOaLbcEx9CHfz93uMJ8UK9aP1dUGVoVImO3uaAf8meee6CSbCb)PmY7sPnjhReGoM(fz93uMJ8UKf7jnO3uuPce6CSAHUUEK3LsluaazgCm9lkTjbOcJCp4NJZZf1)JcGekY1cISAHUUEK3LsRGCqTmvPce6CSAHUUEK3Lsluaav2drc)jXEwmukZX55IvqoOwMQu5HiH)KyF0GUYGFdnDnTChPeaGNzWX0VO0MeGkm6VPmh5Dj1)JcqOZXgWf8NYiVlL25clszGacDo25cbQLb5b25cls5dKwp4c(68kYGEtbOypPb9McGvWtvQaHohRwORRh5DP0cfaqMbht)IsBsaQWi3d(548Cr9)OiuKRfez1cDD9iVlLwb5GAzQsfi05y1cDD9iVlLwOaMbht)IsBsaQWyWlC8JQmY7smdoM(fL2KauHrFycXNcFSNbMVWMmdoM(fL2KauHXu4bcIgj9OkQ)hfC5WL86GAHzWX0VO0MeGkm6VPmh5Dj1)JcqOZXgWf8NYiVlL25clszGekY1cISjj(m0JZIHsRGCqTmv(SyOeaWryQufkY1cISAHUUEK3LsRGCqTmvPce6CSAHUUEK3LsluaazgCm9lkTjbOcJoh7izK3Lu)pkaHohBaxWFkJ8UuAHcuP6SyOeaWvykdKqrUwqKvl011J8UuAfKdQLPkvGqNJvl011J8UuAHcaiZGJPFrPnjavymjXNHEK3Lu)pkolgkbe7jn4sfbb0ZIHsRPdtQubeY1cISAHUUEK3LsRGCqTmvge6CSAHUUEK3Ls7CHfbqMbht)IsBsaQWOZXosg5DjMbMbht)IslXFSs5DPubOZ5EfHzWX0VO0s8hRuExkbuHrbMc0B(Wqg5DjMbht)IslXFSs5DPeqfg5EWphNNlQ)hfGqNJL4pwPrExkTqbkhkY1cISGoN7veRGCqTmzgCm9lkTe)XkL3Lsavy0FtzoY7sQ)hfGqNJL4pwPrExkTqbkdcDo2aUG)ug5DP0oxyrkdcDo25cbQLb5b25clszGekY1cISAHUUEK3LsRGCqTmvPce6CSAHUUEK3LsluGkvNfdLaaUcdGmdoM(fLwI)yLY7sjGkmY9GFoopxu)pkaHohlXFSsJ8UuAHcygCm9lkTe)XkL3Lsavy0estFExs9)Oae6CSe)XknY7sPDUWIuPciGqNJnGl4pLrExkTqbQubcDowTqxxpY7sPfkaGkdKqrUwqKf05CVIyfKdQLPYGqNJnjXNHECwmuANlSiLplgkbGAaNQuDwmuca4imaYm4y6xuAj(JvkVlLaQWyWlC8JQmY7smdoM(fLwI)yLY7sjGkm6dti(u4J9mW8f2KzWX0VO0s8hRuExkbuHXu4bcIgj9OkQ)hfC5WL86GAHzWX0VO0s8hRuExkbuHXKeFg6rExs9)O4SyOeqSN0GlveeqplgkTMomPsfqixliYQf666rExkTcYb1YuzqOZXQf666rExkTZfweaBQPUb]] )
end