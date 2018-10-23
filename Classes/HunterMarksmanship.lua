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


    spec:RegisterPack( "Marksmanship", 20181022.2042, [[dyewPaqisqpskQ2eOyusjoLusRsvPkEfO0SiPClbGDrQFjfgMa5yculta9msittvPCnbOTrc4BQkKXrc05ea16uvQmpPi3JeTpvfDqPOyHGQEiju1fLIsAJQkv1ifa5KsrPALcYmvvQs3uvbTtqLFkfLyOQkWsvvOEQIMQuQ9Q0FfzWu6WuTyqEmrtwuxg1MLQplOgTcNgy1srP8AsIztXTfYUr8BvgUqTCcpxY0HUUQSDvL8DssJNekNNKQ1tcvMVQQ9J0BWB7DMDKx4cmOGvWGdkWa1bg03cmOVTtu9yENXUufpmVtIhX78dDHkvKtQbiENXU6MZZB7Dw3ti5D2CQDGyC9DnAegGJhKwErnkq0Z4i4isH3Xgfis2aYCqnG6EaK5VAelUoWWvJpqWFSdYvJp4JtbOhbzr6dDHkvKtQbiwxGi5oHEad2StwODMDKx4cmOGvWGdkWa1bg03cwrkWo9hooXoNGif)ohGCMjl0oZCj3zZP2p0fQuroPgGyQna9iilOHAo1oqmU(UgncdWXdslVOgfi6zCeCePW7yJcejBazoOgqDpaY8xnIfxhy4QXhi4p2b5QXh8XPa0JGSi9HUqLkYj1aeRlqKKgQ5uBZIepiwqTbgOAuBGbfScsTba1QGF33cMA)GpKgIgQ5uRIF4KWC9D0qnNAdaQTzYzotTk(7rqwqTZXHAAOMtTba12m5mNP2p2JbzQ97dem1EFXcQTzarCMANJdPwqNAv)EuRlyQn6(cqcR3PbuyTT3jkasvQXH12EHl4T9oDjcoYoHCHWdZ7KjoKHZl8lUWf42ENUebhzNSIfBUc8fNQXH7KjoKHZl8lUWPOT9ozIdz48c)oLcaYcGVtOxVRrbqQsQghw6xm1cd1QqQfDdtqnKleEywZehYW5D6seCKDk8yqo1bcEXfUVTT3jtCidNx43Puaqwa8Dc96Dnkasvs14Ws)IPwyOwOxVRJfSeuCQghw68PkHAHHAHE9UoFpidNqpwNpvjulmuBluRcPw0nmb1gghUjvJdlntCidNP2)FQf617AdJd3KQXHL(ftT))uB)KVIA)KAvGGO2w3PlrWr2PdI4CQghU4cxa327KjoKHZl87ukaila(oHE9UgfaPkPACyPFX70Li4i7u4XGCQde8IlCkW2ENmXHmCEHFNsbazbW3j0R31OaivjvJdlD(uLqT))uBlul0R31XcwckovJdl9lMA))PwOxVRnmoCtQghw6xm12k1cd12c1QqQfDdtqnKleEywZehYWzQfgQf6176czpREQFYxPZNQeQfgQTFYxrTFsTFlGu7)p12p5RO2pP2pkiQT1D6seCKDg9miOghU4c3hTT3PlrWr2zmGfsajCQghUtM4qgoVWV4cNcUT3PlrWr2PNIEImlsxpjfNQ1ozIdz48c)IlCb4T9ozIdz48c)oLcaYcGVtb3fCnCidVtxIGJSZIfXmbtfciHxCHl4G227KjoKHZl87ukaila(o7N8vulSuR0lmj4WmHABIA7N8v6ixXO2)FQTfQfDdtqTHXHBs14WsZehYWzQfgQf617AdJd3KQXHLoFQsO2w3PlrWr2zHSNvpvJdxCXDM5U)m42EHl4T9oDjcoYoL3JGSivJd3jtCidNx4xCHlWT9oDjcoYoFfNaihv7KjoKHZl8lUWPOT9ozIdz48c)oDjcoYoLUXKCjcosYakCNgqHjIhX7uMRfx4(22ENmXHmCEHFNsbazbW3PlrWxCIjCeGlQTjQnqQfgQfDdtqTHXHBs14WsZehYWzQfgQfDdtqDHSNvp1p5R0mXHmCMAHHADfhlaiRlK9S6jhePforfQ9tQn4D6seCKDkEKKlrWrsgqH70akmr8iENfYEw9uHlUWfWT9ozIdz48c)oLcaYcGVtxIGV4et4iaxuBtuRI2PlrWr2P4rsUebhjzafUtdOWeXJ4Dw4IlCkW2ENmXHmCEHFNUebhzNIhj5seCKKbu4onGctepI3jkasvQXH1IlUZyblViih32lCbVT3jtCidNx4xCHlWT9ozIdz48c)IlCkABVtM4qgoVWV4c33227KjoKHZl87ukaila(oDjc(ItmHJaCrTnrTkANUebhzN1lk6iPygxCHlGB7DYehYW5f(fx4uGT9oDjcoYoJpeCKDYehYW5f(fx4(OT9oDjcoYohpcYIkf5cv2jtCidNx4xCHtb327KjoKHZl87mwWsVWecI4DgWD6seCKDMVhKHtOhV4cxaEBVtM4qgoVWVtPaGSa470Li4loXeocWf12e1QOD6seCKD6GioNQXHlUWfCqB7DYehYW5f(DkfaKfaFNUebFXjMWraUO2pP2a3PlrWr2jRyXMRaFXPAC4IlUtzU22lCbVT3jtCidNx43Puaqwa8DMzOxVRhpcYIkf5cv05tvYoDjcoYohpcYIkf5cvwCHlWT9ozIdz48c)oLcaYcGVt5DM8Pkrl8yqo1bcwl4ihqkQTjQnSmVtxIGJSZ89GmCc94fx4u02ENmXHmCEHFNsbazbW3P8ot(uLOrXJRXHAbh5asrTFsTkkOD6seCKDcXIIfQaiHxCH7BB7DYehYW5f(DkfaKfaFNY7m5tvIgfpUghQfCKdif1(j1QOG2PlrWr2jK5UCQ)eQV4cxa327KjoKHZl87ukaila(oL3zYNQenkECnoul4ihqkQ9tQvrbTtxIGJStNi5cfUjjDJzXfofyBVtM4qgoVWVtPaGSa47uENjFQs0O4X14qTGJCaPO2pPwff0oDjcoYo7abdzUlV4c3hTT3PlrWr2PbeEGvQz7LdhXeCNmXHmCEHFXfofCBVtM4qgoVWVtPaGSa47e617Au84ACOwWUePwyOwOxVRHm3LnVc1c2Li1()tTqVExJIhxJd1c2Li1cd1IUimJ6b7gCOJLi12e1gyqulmul6gMGAPl4(ZKCqKMjoKHZu7)p1IUimJAeeXj8szatTnrTbgWD6seCKDgFi4ilUWfG327KjoKHZl87ukaila(oBHAL3zYNQeTdI4CQghQLdxeMlQTjQnyQfgQvHul6gMGAdJd3KQXHLMjoKHZulmuRcPw0nmb1fYEw9u)KVsZehYWzQTvQ9)NAHE9UgYCx28kulyxIu7)p1IUimJAeeXj8szatTFsTY7m5tvIgfpUghQZpHJGJKc)4QOwyP28t4i4iu7)p12c12c1IUimJ6b7gCOJLi12e1gyqu7)p1QqQfDdtqT0fC)zsoisZehYWzQTvQfgQTfQf617AdJd3KQXHL(ftT))uRcPw0nmb1gghUjvJdlntCidNP2wP2wP2)FQfDryg1iiIt4LYaMABIAdoG70Li4i7efpUghU4I7SWT9cxWB7D6seCKDYkwS5kWxCQghUtM4qgoVWV4cxGB7DYehYW5f(DkfaKfaFNUebFXjMWraUO2pP2G3PlrWr2jKleEyEXfofTT3jtCidNx43Puaqwa8Dc96DDSGLGIt14Ws)IPwyO2wOw5DM8Pkr7GioNQXH6(ZyscwoCryoHGiMABIAdlZu73d1c96DDSGLGIt14WsxOlvHAHLADjcoI2brCovJd1sVWecIyQ9)NAHE9U2W4WnPACyPFXuBR70Li4i70fsNWPAC4IlCFBBVtM4qgoVWVtPaGSa47SfQvHul6gMGAdJd3KQXHLMjoKHZu7)p1c96DTHXHBs14Ws)IP2wPwyOwxXXcaY6(jFfNtDGG1mXHmCMA))PwxXXcaYAajHdojgQJJiTWjQqTFsTbVtxIGJStHhdYPoqWlUWfWT9ozIdz48c)oLcaYcGVtOxVRJUV4iMG6xm1cd12c1QqQfDdtqTHXHBs14WsZehYWzQ9)NAHE9U2W4WnPACyPFXuBR70Li4i7u4XGCQde8IlCkW2ENmXHmCEHFNsbazbW3j0R31XcwckovJdlD(uLqTWqTTqTqVExNVhKHtOhRZNQeQfgQT)mMKGLdxeMtiiIP2MOwPxycbrm1cl1gwMP2)FQf617AdJd3KQXHL(ftTTUtxIGJStheX5unoCXfUpABVtM4qgoVWVtPaGSa47uHul6gMGAdJd3KQXHLMjoKHZu7)p1c96DTHXHBs14Ws)I3PlrWr2PWJb5uhi4fx4uWT9oDjcoYoJbSqciHt14WDYehYW5f(fx4cWB7D6seCKD6PONiZI01tsXPATtM4qgoVWV4cxWbTT3jtCidNx43Puaqwa8Dk4UGRHdz4D6seCKDwSiMjyQqaj8IlCbh82ENmXHmCEHFNsbazbW3j0R31XcwckovJdlD(uLqTWqTTqTkKAr3Weuxi7z1t9t(kntCidNPwyO2(jFf1(j1(rbrT))uRcPw0nmb1gghUjvJdlntCidNP2)FQf617AdJd3KQXHL(ftTTUtxIGJStheX5unoCXfUGdCBVtM4qgoVWVtPaGSa47e6176yblbfNQXHL(ftT))uB)KVIA)KAvGGOwyO2wOwfsTOBycQnmoCtQghwAM4qgotT))ul0R31gghUjvJdl9lMABDNUebhzNUq6eovJdxCHlyfTT3jtCidNx43Puaqwa8D2p5ROwyPwPxysWHzc12e12p5R0rUIrT))uBlul6gMGAdJd3KQXHLMjoKHZulmul0R31gghUjvJdlD(uLqTTUtxIGJSZczpREQghU4cxWFBBVtxIGJStxiDcNQXH7KjoKHZl8lU4olK9S6Pc32lCbVT3jtCidNx43Puaqwa8Dc96DDHSNvp1p5R05tvc1()tTOlcZOgbrCcVugWuBtuBWkWoDjcoYo9u0tKzr66jP4uTwCHlWT9ozIdz48c)oLcaYcGVtOxVRnmoCtQghw6xm1()tTOlcZOgbrCcVugWuBtuRIO2)FQnZqVExxi7z1toisxOlvHAvsTbKAHHABHAHE9U2CsvsojNmNN1VyQ9)NA7pJjjy5WfH5ecIyQTjQv6fMqqetTTUtxIGJStheX5unoCXfofTT3jtCidNx43Puaqwa8Dc96DDSGLGIt14Ws)IPwyO2wOwOxVRnmoCtQghw6xm1()tTOlcZOEWUbh6yjsTFsTbge1cd1IUimJ6b7gCOJLi12e1QGbrTTUtxIGJStxiDcNQXHlUW9TT9ozIdz48c)oLcaYcGVtb3fCnCidVtxIGJSZIfXmbtfciHxCHlGB7D6seCKDwi7z1t14WDYehYW5f(fxCXD(flkWrw4cmOGvWGcWkkiDWbgWa3PQUGaiHRD2ShfFcKZuRcqTUebhHAnGclnn0oJfxhy4D2CQ9dDHkvKtQbiMAdqpcYcAOMtTdeJRVRrJWaC8G0YlQrbIEghbhrk8o2OarYgqMdQbu3dGm)vJyX1bgUA8bc(JDqUA8bFCka9iilsFOluPICsnaX6cejPHAo12SiXdIfuBGbQg1gyqbRGuBaqTk439TGP2p4dPHOHAo1Q4hojmxFhnuZP2aGABMCMZuRI)EeKfu7CCOMgQ5uBaqTntoZzQ9J9yqMA)(abtT3xSGABgqeNP254qQf0Pw1Vh16cMAJUVaKWAAiAOMtTnRkglFiNPwiUFcMALxeKJulehgqkn12msjhJf1sosamCru)zOwxIGJuu7rmQRPHCjcosPJfS8IGCuz34Lk0qUebhP0XcwErqocRYg(lCetqhbhHgYLi4iLowWYlcYryv2OFxMgYLi4iLowWYlcYryv2OErrhjfZOAGUsxIGV4et4iaxnPiAOMtTtIhxJdPwHdYul0R35m1wOJf1cX9tWuR8IGCKAH4WasrTojtTXcoaIpebKWulOO28rynnKlrWrkDSGLxeKJWQSrr84ACyQqhlAixIGJu6yblViihHvzJ4dbhHgYLi4iLowWYlcYryv2y8iilQuKluHgYLi4iLowWYlcYryv2iFpidNqpwTybl9ctiiIvgqAixIGJu6yblViihHvzdheX5unounqxPlrWxCIjCeGRMuenKlrWrkDSGLxeKJWQSbRyXMRaFXPACOAGUsxIGV4et4iaxFginenuZP2MvfJLpKZul)fluNArqetT4GPwxINGAbf16F5aJdzynnKlrWrkLY7rqwKQXH0qUebhPGvzJxXjaYrfnKlrWrkyv2q6gtYLi4ijdOq1iEeRuMlAOMtTndHADdYcIJm1wasydtTOlcZi1glaNaGQtT9tqTbsTNGAJobtTtK9S6uBZaIOwu4aSuJANi7z1P2V)jFLAuRtYu73lJd3qTZXHLMgYLi4ifSkBiEKKlrWrsgqHQr8iwzHSNvpvOAGUsxIGV4et4iaxnfimOBycQnmoCtQghwAM4qgodd6gMG6czpREQFYxPzIdz4mmUIJfaK1fYEw9KdI0cNOYNbtd5seCKcwLnepsYLi4ijdOq1iEeRSq1aDLUebFXjMWraUAsr0qUebhPGvzdXJKCjcosYakunIhXkrbqQsnoSOHOHCjcosPL5s54rqwuPixOIAGUYmd96D94rqwuPixOIoFQsOHCjcosPL5cwLnY3dYWj0Jvd0vkVZKpvjAHhdYPoqWAbh5as1uyzMgYLi4iLwMlyv2aIfflubqcRgORuENjFQs0O4X14qTGJCaP(urbrd5seCKslZfSkBazUlN6pH6Qb6kL3zYNQenkECnoul4ihqQpvuq0qUebhP0YCbRYgorYfkCts6gJAGUs5DM8PkrJIhxJd1coYbK6tffenKlrWrkTmxWQSrhiyiZDz1aDLY7m5tvIgfpUghQfCKdi1NkkiAixIGJuAzUGvzddi8aRuZ2lhoIjinKlrWrkTmxWQSr8HGJOgORe617Au84ACOwWUeHb617AiZDzZRqTGDj()d96DnkECnoulyxIWGUimJ6b7gCOJLytbgemOBycQLUG7ptYbrAM4qgo))JUimJAeeXj8sza3uGbKgYLi4iLwMlyv2afpUghQgORSf5DM8Pkr7GioNQXHA5WfH5QPGHrHOBycQnmoCtQghwAM4qgodJcr3Weuxi7z1t9t(kntCidNB9)h617AiZDzZRqTGDj()JUimJAeeXj8sza)P8ot(uLOrXJRXH68t4i4iPWpUkyZpHJGJ8)3slOlcZOEWUbh6yj2uGb9)Rq0nmb1sxW9Nj5GintCidNBfMwGE9U2W4WnPACyPFX))keDdtqTHXHBs14WsZehYW5wB9)hDryg1iiIt4LYaUPGdinenKlrWrkDHkzfl2Cf4lovJdPHCjcosPlewLnGCHWdZQb6kDjc(ItmHJaC9zW0qUebhP0fcRYgUq6eovJdvd0vc96DDSGLGIt14Ws)IHPf5DM8Pkr7GioNQXH6(ZyscwoCryoHGiUPWY83d0R31XcwckovJdlDHUufyDjcoI2brCovJd1sVWecI4)FOxVRnmoCtQghw6xCR0qUebhP0fcRYgcpgKtDGGvd0v2Icr3WeuByC4MunoS0mXHmC()h617AdJd3KQXHL(f3kmUIJfaK19t(koN6abRzIdz48)VR4ybaznGKWbNed1XrKw4ev(myAixIGJu6cHvzdHhdYPoqWQb6kHE9Uo6(IJycQFXW0Icr3WeuByC4MunoS0mXHmC()h617AdJd3KQXHL(f3knKlrWrkDHWQSHdI4CQghQgORe6176yblbfNQXHLoFQsGPfOxVRZ3dYWj0J15tvcm9NXKeSC4IWCcbrCtsVWecIyydlZ))qVExByC4MunoS0V4wPHCjcosPlewLneEmiN6abRgORuHOBycQnmoCtQghwAM4qgo))d96DTHXHBs14Ws)IPHCjcosPlewLnIbSqciHt14qAixIGJu6cHvzdpf9ezwKUEskovlAixIGJu6cHvzJIfXmbtfciHvd0vk4UGRHdzyAixIGJu6cHvzdheX5unounqxj0R31XcwckovJdlD(uLatlkeDdtqDHSNvp1p5R0mXHmCgM(jF1NFuq))keDdtqTHXHBs14WsZehYW5)FOxVRnmoCtQghw6xCR0qUebhP0fcRYgUq6eovJdvd0vc96DDSGLGIt14Ws)I))7N8vFQabbtlkeDdtqTHXHBs14WsZehYW5)FOxVRnmoCtQghw6xCR0qUebhP0fcRYgfYEw9unounqxz)KVcwPxysWHzst9t(kDKRy))TGUHjO2W4WnPACyPzIdz4mmqVExByC4MunoS05tvsR0qUebhP0fcRYgUq6eovJdPHOHCjcosPlK9S6Pcv6PONiZI01tsXPAPgORe6176czpREQFYxPZNQK)F0fHzuJGioHxkd4McwbOHCjcosPlK9S6PcHvzdheX5unounqxj0R31gghUjvJdl9l()hDryg1iiIt4LYaUjf9)NzOxVRlK9S6jhePl0LQOmGW0c0R31MtQsYj5K58S(f))3FgtsWYHlcZjeeXnj9ctiiIBLgYLi4iLUq2ZQNkewLnCH0jCQghQgORe6176yblbfNQXHL(fdtlqVExByC4MunoS0V4)F0fHzupy3GdDSe)mWGGbDryg1d2n4qhlXMuWGALgYLi4iLUq2ZQNkewLnkweZemviGewnqxPG7cUgoKHPHCjcosPlK9S6PcHvzJczpREQghsdrd5seCKsJcGuLACyPeYfcpmtd5seCKsJcGuLACybRYgSIfBUc8fNQXH0qUebhP0OaivPghwWQSHWJb5uhiy1aDLqVExJcGuLunoS0Vyyui6gMGAixi8WSMjoKHZ0qUebhP0OaivPghwWQSHdI4CQghQgORe617AuaKQKQXHL(fdd0R31XcwckovJdlD(uLad0R3157bz4e6X68PkbMwui6gMGAdJd3KQXHLMjoKHZ))qVExByC4MunoS0V4))(jF1NkqqTsd5seCKsJcGuLACybRYgcpgKtDGGvd0vc96Dnkasvs14Ws)IPHCjcosPrbqQsnoSGvzJONbb14q1aDLqVExJcGuLunoS05tvY)FlqVExhlyjO4unoS0V4)FOxVRnmoCtQghw6xCRW0Icr3Weud5cHhM1mXHmCggOxVRlK9S6P(jFLoFQsGPFYx953c4)F)KV6ZpkOwPHCjcosPrbqQsnoSGvzJyalKas4unoKgYLi4iLgfaPk14WcwLn8u0tKzr66jP4uTOHCjcosPrbqQsnoSGvzJIfXmbtfciHvd0vk4UGRHdzyAixIGJuAuaKQuJdlyv2Oq2ZQNQXHQb6k7N8vWk9ctcomtAQFYxPJCf7)Vf0nmb1gghUjvJdlntCidNHb617AdJd3KQXHLoFQsADNvmlx4cmGFBXf3f]] )
end