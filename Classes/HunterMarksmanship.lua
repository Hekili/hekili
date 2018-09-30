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


    spec:RegisterPack( "Marksmanship", 20180930.1252, [[du06LaqiHOEKqInbPAuasNcqSkai8kaAwKOUfjf2fP(fL0WesDmHWYaqptQIPrsjxdaSnij(MqsnoHiDoHiwhauZds4EKW(GeDqsk1cbupKKI6Iaq0gHKQmsskYjbGKvsjMjaK6MqsLDkv1qHKulvijpvIPkvAVk(RugSGdt1Ib6XenzjDzuBwjFwQy0k1Pv1QHKQ61KiZMIBtP2nOFRYWfQLt45IMoY1Hy7sv67qkJhskNNKQ1djjZNKSFOEIy6oLQt80hGrhrKgDK0t06iaiaaWEa4ui1J5Pe7sL8o8uGUnpfuNlukTDyU)4Pe7QBoVoDNsEicjpLOGdBIItaSvRDEAJaQLNT18Trmo9huk8fznFBPvqZbAfC5QrL71AS4wVHtROAbhv(xtRO6OQPMqGelAOoxOuA7WC)X68TLtbe5neak4aoLQt80hGrhrKgDK0t06iaiaaWEMIJq7tmLYBRMNY(RvgoGtPYPCkrbhqDUqP02H5(JXb1ecKyb2suWHnrXja2Q1opTra1YZ2A(2igN(dkf(ISMVT0kO5aTcUC1OY9AnwCR3WPvuTGJk)RPvuDu1utiqIfnuNlukTDyU)yD(2sSLOGdfoMyBqwGd9eTY4aaJoIifhudCicacGbGOXwWwIcoOM3oSdNaySLOGdQboO21kxXb18HajwGdL9rASLOGdQboO21kxXHOYJ)koG69cghUEzboO2VnxXHY(iC4x4G6hco4cghSVEFyh9umFs50DkK4LkL7JYP70pIP7uCj9hCkGUq4D4PWqh0W1b4HM(aC6ofxs)bNcJAXMl)E5wUpAkm0bnCDaEOPFpt3PWqh0W1b4PifpXI3NciYAPjXlvQL7JsnsmoGooezCGCddjnOleEhwZqh0W1P4s6p4ueE8xBRxWdn9vRP7uyOdA46a8uKINyX7tbezT0K4Lk1Y9rPgjghqhharwlDSGLFYTCFuQRhAqCaDCaezT01db0WnYJ11dnioGooauCiY4a5ggsAdtB30Y9rPMHoOHR4Gkv4aiYAPnmTDtl3hLAKyCqLkCyDsKehqjoGkrJdazkUK(dof)T5Al3hn00haMUtHHoOHRdWtrkEIfVpfqK1stIxQul3hLAK4P4s6p4ueE8xBRxWdn9rLP7uyOdA46a8uKINyX7tbezT0K4Lk1Y9rPUEObXbvQWbGIdGiRLowWYp5wUpk1iX4Gkv4aiYAPnmTDtl3hLAKyCai4a64aqXHiJdKByiPbDHW7WAg6GgUIdOJdGiRLoj2RQ3wNej11dnioGooSojsIdOehulaahuPchwNejXbuIdrD04aqMIlP)GtXgXqFUpAOPFupDNIlP)Gtj(zH8HDA5(OPWqh0W1b4HM(r60DkUK(dofVzJiQSODRMuCOLtHHoOHRdWdn9JKP7uyOdA46a8uKINyX7trWlbNBh0WtXL0FWPKSiMHulPh2zOPFerpDNcdDqdxhGNIu8elEFkRtIK4aG4G0tQj4omehqboSojsQTDudhuPchakoqUHHK2W02nTCFuQzOdA4koGooaISwAdtB30Y9rPUEObXbGmfxs)bNssSxvVL7JgAOPu5LJyOP70pIP7uCj9hCkYdbsSOL7JMcdDqdxhGhA6dWP7uCj9hCkij3EITZPWqh0W1b4HM(9mDNcdDqdxhGNIlP)Gtr6gtZL0FWM5tAkMpPg0T5PiR5qtF1A6ofg6GgUoapfP4jw8(uCj99YngY2pN4akWbaIdOJdKByiPnmTDtl3hLAg6GgUIdOJdKByiPtI9Q6T1jrsndDqdxXb0XbhvXINyDsSxvV5VTw4qLWbuIdrmfxs)bNIab2Cj9hSz(KMI5tQbDBEkjXEv9wsdn9bGP7uyOdA46a8uKINyX7tXL03l3yiB)CIdOah6zkUK(dofbcS5s6pyZ8jnfZNud628usAOPpQmDNcdDqdxhGNIlP)GtrGaBUK(d2mFstX8j1GUnpfs8sLY9r5qdnLyblpBqNMUt)iMUtHHoOHRdWdn9b40Dkm0bnCDaEOPFpt3PWqh0W1b4HM(Q10Dkm0bnCDaEksXtS49P4s67LBmKTFoXbuGd9mfxs)bNsIyBFWwmtdn9bGP7uyOdA46a8qtFuz6ofxs)bNs8r)bNcdDqdxhGhA6h1t3P4s6p4u2iqIfzZ2fknfg6GgUoap00psNUtHHoOHRdWtjwWspPg928uaGP4s6p4uQhcOHBKhp00psMUtHHoOHRdWtrkEIfVpfxsFVCJHS9ZjoGcCONP4s6p4u83MRTCF0qt)iIE6ofg6GgUoapfP4jw8(uCj99YngY2pN4akXbaofxs)bNcJAXMl)E5wUpAOHMISMt3PFet3PWqh0W1b4PifpXI3NsLbrwl9gbsSiB2UqjD9qdofxs)bNYgbsSiB2UqPHM(aC6ofg6GgUoapfP4jw8(uK3zQhAqTWJ)AB9cwlyB)HjoGcCOJSofxs)bNs9qanCJ84HM(9mDNcdDqdxhGNIu8elEFkY7m1dnOMeiCUpslyB)HjoGsCONONIlP)GtbKfjlu6HDgA6Rwt3PWqh0W1b4PifpXI3NI8ot9qdQjbcN7J0c22FyIdOeh6j6P4s6p4uan3vBleH6dn9bGP7uyOdA46a8uKINyX7trENPEOb1KaHZ9rAbB7pmXbuId9e9uCj9hCkouYjjCtt6gZqtFuz6ofg6GgUoapfP4jw8(uK3zQhAqnjq4CFKwW2(dtCaL4qprpfxs)bNY6fmO5U6qt)OE6ofxs)bNI57SPSH6Ju7yZqAkm0bnCDaEOPFKoDNcdDqdxhGNIu8elEFkafharwlnjq4CFKwWUKWb0XbqK1sdAURAqsslyxs4aqWbvQWbGIdafhKhmrSDqdRJfN5GD4Al(qJf4a64a5IomPP3MB01QpJdOahqfaIdabhuPchix0Hjn92CJUw9zCaf4qprGdazkUK(doL4J(do00psMUtHHoOHRdWtrkEIfVpf5DM6Hgu7VnxB5(iTC7IoCIdOahIahuPchi3Wqsd6cH3H1m0bnCfhqhhK3zQhAqT)2CTL7J0YTl6WzBjCj9h0n4akWHi09mfxs)bNcjq4CF0qdnLKMUt)iMUtXL0FWPWOwS5YVxUL7JMcdDqdxhGhA6dWP7uyOdA46a8uKINyX7tXL03l3yiB)CIdOehIykUK(dofqxi8o8qt)EMUtHHoOHRdWtrkEIfVpfqK1shly5NCl3hLAKyCaDCaO4G8ot9qdQ93MRTCFKEHymnbl3UOd3O3MXbuGdDKvCaaboaISw6ybl)KB5(OuNKlvchaehCj9hu7VnxB5(iT0tQrVnJdQuHdGiRL2W02nTCFuQrIXbGmfxs)bNIlKoKB5(OHM(Q10Dkm0bnCDaEksXtS49PauCiY4a5ggsAdtB30Y9rPMHoOHR4Gkv4aiYAPnmTDtl3hLAKyCai4a64GJQyXtSEDsKKRT1lyndDqdxXbvQWbhvXINy9dB0MBIT602wlCOs4akXHiMIlP)Gtr4XFTTEbp00haMUtHHoOHRdWtrkEIfVpfqK1sBF9Y2mK0iX4a64aqXHiJdKByiPnmTDtl3hLAg6GgUIdQuHdGiRL2W02nTCFuQrIXbGmfxs)bNIWJ)AB9cEOPpQmDNcdDqdxhGNIu8elEFkGiRLowWYp5wUpk11dnioGooauCaezT01db0WnYJ11dnioGooSqmMMGLBx0HB0BZ4akWbPNuJEBghaeh6iR4Gkv4aiYAPnmTDtl3hLAKyCaitXL0FWP4VnxB5(OHM(r90Dkm0bnCDaEksXtS49PezCGCddjTHPTBA5(OuZqh0WvCqLkCaezT0gM2UPL7Jsns8uCj9hCkcp(RT1l4HM(r60DkUK(doL4NfYh2PL7JMcdDqdxhGhA6hjt3P4s6p4u8MnIOYI2TAsXHwofg6GgUoap00pIONUtHHoOHRdWtrkEIfVpfbVeCUDqdpfxs)bNsYIygsTKEyNHM(reX0Dkm0bnCDaEksXtS49PaISw6ybl)KB5(Ouxp0G4a64aqXHiJdKByiPtI9Q6T1jrsndDqdxXb0XH1jrsCaL4quhnoOsfoezCGCddjTHPTBA5(OuZqh0WvCqLkCaezT0gM2UPL7JsnsmoaKP4s6p4u83MRTCF0qt)ia40Dkm0bnCDaEksXtS49PaISw6ybl)KB5(OuJeJdQuHdRtIK4akXbujACaDCaO4qKXbYnmK0gM2UPL7JsndDqdxXbvQWbqK1sByA7MwUpk1iX4aqMIlP)GtXfshYTCF0qt)i6z6ofg6GgUoapfP4jw8(uwNejXbaXbPNutWDyioGcCyDsKuB7OgoOsfoauCGCddjTHPTBA5(OuZqh0WvCaDCaezT0gM2UPL7JsD9qdIdazkUK(doLKyVQEl3hn00pc1A6ofxs)bNIlKoKB5(OPWqh0W1b4HgAkjXEv9wst3PFet3P4s6p4u8MnIOYI2TAsXHwofg6GgUoap00hGt3PWqh0W1b4PifpXI3NciYAPnmTDtl3hLAK4P4s6p4u83MRTCF0qt)EMUtHHoOHRdWtrkEIfVpfqK1sByA7MwUpk11dn4uCj9hCkjXEv9wUpAOPVAnDNcdDqdxhGNIu8elEFkGiRLowWYp5wUpk1iXtXL0FWP4cPd5wUpAOPpamDNcdDqdxhGNIu8elEFkcEj4C7GgEkUK(doLKfXmKAj9Wodn9rLP7uCj9hCkjXEv9wUpAkm0bnCDaEOHgAk9YI8p40hGrhrKgDKerKObia7jsMcAUa(Wo5uaqzhFcIR4aQGdUK(dIdMpPuJTmLmMLtFacaQ1uIf36n8uIcoG6CHsPTdZ9hJdQjeiXcSLOGdBIItaSvRDEAJaQLNT18Trmo9huk8fznFBPvqZbAfC5QrL71AS4wVHtROAbhv(xtRO6OQPMqGelAOoxOuA7WC)X68TLylrbhkCmX2GSah6jALXbagDerkoOg4qeaeadarJTGTefCqnVDyhobWylrbhudCqTRvUIdQ5dbsSahk7J0ylrbhudCqTRvUIdrLh)vCa17fmoC9YcCqTFBUIdL9r4WVWb1peCWfmoyF9(WoASfSLOGdairnwIqCfha51jyCqE2GoHdGCNhMACqTLsoMsCaEq1y7c7fIbhCj9hmXHdAuxJT4s6pyQJfS8SbDsXY4PsylUK(dM6yblpBqNauHvhPJndjN(dIT4s6pyQJfS8SbDcqfwx3vXwCj9hm1XcwE2GobOcRjIT9bBXmP8Vu4s67LBmKTForrpylrbhkqpo3hHdc)R4aiYAXvCijNsCaKxNGXb5zd6eoaYDEyIdoSIdXcwnIpIEyhC4tCOEqwJT4s6pyQJfS8SbDcqfwtOhN7JAj5uIT4s6pyQJfS8SbDcqfwJp6pi2IlP)GPowWYZg0javyDJajwKnBxOe2IlP)GPowWYZg0javyTEiGgUrESYXcw6j1O3MvaaylUK(dM6yblpBqNauHv)T5Al3hP8Vu4s67LBmKTForrpylUK(dM6yblpBqNauHvg1Inx(9YTCFKY)sHlPVxUXq2(5eLaeBbBjk4aasuJLiexXbUxwOooqVnJd0MXbxsNah(eh8E934GgwJT4s6pyQqEiqIfTCFe2IlP)GjGkSIKC7j2oXwCj9hmbuHvPBmnxs)bBMpjLHUnRqwtSLOGdQnehCdXcOtmoKpSJHXbYfDychIf)jEsDCyDcCaG4WjWb7tW4qHyVQooO2Vnoqc)PuzCOqSxvhhq9ojsQmo4WkoaGMPTBWHY(OuJT4s6pycOcRceyZL0FWM5tszOBZksI9Q6TKu(xkCj99YngY2pNOaGOtUHHK2W02nTCFuQzOdA4k6KByiPtI9Q6T1jrsndDqdxr3rvS4jwNe7v1B(BRfoujugb2IlP)GjGkSkqGnxs)bBMpjLHUnRijL)LcxsFVCJHS9Zjk6bBXL0FWeqfwfiWMlP)GnZNKYq3MvqIxQuUpkXwWwCj9hm1YAQyJajwKnBxOKY)srLbrwl9gbsSiB2UqjD9qdIT4s6pyQL1eqfwRhcOHBKhR8VuiVZup0GAHh)126fSwW2(dtu0rwXwCj9hm1YAcOcRGSizHspSJY)sH8ot9qdQjbcN7J0c22FyIYEIgBXL0FWulRjGkScAUR2wic1v(xkK3zQhAqnjq4CFKwW2(dtu2t0ylUK(dMAznbuHvhk5KeUPjDJr5FPqENPEOb1KaHZ9rAbB7pmrzprJT4s6pyQL1eqfwxVGbn3vv(xkK3zQhAqnjq4CFKwW2(dtu2t0ylUK(dMAznbuHvZ3ztzd1hP2XMHe2IlP)GPwwtavyn(O)Gk)lfafezT0KaHZ9rAb7scDqK1sdAURAqsslyxsarLkGcu5bteBh0W6yXzoyhU2Ip0yb6Kl6WKMEBUrxR(mkqfacevQix0Hjn92CJUw9zu0teabBXL0FWulRjGkSsceo3hP8VuiVZup0GA)T5Al3hPLBx0HtueHkvKByiPbDHW7WAg6GgUIU8ot9qdQ93MRTCFKwUDrhoBlHlP)GUbfrO7bBbBXL0FWuNKcg1Inx(9YTCFe2IlP)GPojavyf0fcVdR8Vu4s67LBmKTForzeylUK(dM6KauHvxiDi3Y9rk)lfGiRLowWYp5wUpk1iXOdu5DM6Hgu7VnxB5(i9cXyAcwUDrhUrVnJIoYkacqK1shly5NCl3hL6KCPsa6s6pO2FBU2Y9rAPNuJEBwLkqK1sByA7MwUpk1iXabBXL0FWuNeGkSk84V2wVGv(xkaAKj3WqsByA7MwUpk1m0bnCvLkqK1sByA7MwUpk1iXabDhvXINy96KijxBRxWAg6GgUQsLJQyXtS(HnAZnXwDABRfoujugb2IlP)GPojavyv4XFTTEbR8VuaISwA7Rx2MHKgjgDGgzYnmK0gM2UPL7JsndDqdxvPcezT0gM2UPL7JsnsmqWwCj9hm1jbOcR(BZ1wUps5FPaezT0Xcw(j3Y9rPUEObrhOGiRLUEiGgUrESUEObrFHymnbl3UOd3O3MrH0tQrVndyhzvLkqK1sByA7MwUpk1iXabBXL0FWuNeGkSk84V2wVGv(xkIm5ggsAdtB30Y9rPMHoOHRQubISwAdtB30Y9rPgjgBXL0FWuNeGkSg)Sq(WoTCFe2IlP)GPojavy1B2iIklA3QjfhAj2IlP)GPojavynzrmdPwspSJY)sHGxco3oOHXwCj9hm1jbOcR(BZ1wUps5FPaezT0Xcw(j3Y9rPUEObrhOrMCddjDsSxvVTojsQzOdA4k6RtIKOmQJwLQitUHHK2W02nTCFuQzOdA4QkvGiRL2W02nTCFuQrIbc2IlP)GPojavy1fshYTCFKY)sbiYAPJfS8tUL7JsnsSkvRtIKOevIgDGgzYnmK0gM2UPL7JsndDqdxvPcezT0gM2UPL7JsnsmqWwCj9hm1jbOcRjXEv9wUps5FPyDsKeqPNutWDyikwNej12oQPsfqj3WqsByA7MwUpk1m0bnCfDqK1sByA7MwUpk11dniqWwCj9hm1jbOcRUq6qUL7JWwWwCj9hm1jXEv9wsk8MnIOYI2TAsXHwIT4s6pyQtI9Q6TKauHv)T5Al3hP8VuaISwAdtB30Y9rPgjgBXL0FWuNe7v1BjbOcRjXEv9wUps5FPaezT0gM2UPL7JsD9qdIT4s6pyQtI9Q6TKauHvxiDi3Y9rk)lfGiRLowWYp5wUpk1iXylUK(dM6KyVQEljavynzrmdPwspSJY)sHGxco3oOHXwCj9hm1jXEv9wsaQWAsSxvVL7JWwWwCj9hm1K4LkL7JsfGUq4DySfxs)btnjEPs5(Oeqfwzul2C53l3Y9rylUK(dMAs8sLY9rjGkSk84V2wVGv(xkarwlnjEPsTCFuQrIrpYKByiPbDHW7WAg6GgUIT4s6pyQjXlvk3hLaQWQ)2CTL7Ju(xkarwlnjEPsTCFuQrIrhezT0Xcw(j3Y9rPUEObrhezT01db0WnYJ11dni6anYKByiPnmTDtl3hLAg6GgUQsfiYAPnmTDtl3hLAKyvQwNejrjQenqWwCj9hm1K4LkL7Jsavyv4XFTTEbR8VuaISwAs8sLA5(OuJeJT4s6pyQjXlvk3hLaQWQnIH(CFKY)sbiYAPjXlvQL7JsD9qdQsfqbrwlDSGLFYTCFuQrIvPcezT0gM2UPL7JsnsmqqhOrMCddjnOleEhwZqh0Wv0brwlDsSxvVTojsQRhAq0xNejrPAbaQuTojsIYOoAGGT4s6pyQjXlvk3hLaQWA8Zc5d70Y9rylUK(dMAs8sLY9rjGkS6nBerLfTB1KIdTeBXL0FWutIxQuUpkbuH1KfXmKAj9Wok)lfcEj4C7GggBXL0FWutIxQuUpkbuH1KyVQEl3hP8VuSojscO0tQj4omefRtIKABh1uPcOKByiPnmTDtl3hLAg6GgUIoiYAPnmTDtl3hL66Hgeidn0m]] )
end