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
            
            recheck = function () return buff.precise_shots.remains, focus.time_to_71, buff.steady_focus.remains, buff.double_tap.remains, full_recharge_time - cast_time + gcd end,
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
            
            recheck = function () return focus.time_to_71, buff.steady_focus.remains, focus.time_to_61, cooldown.aimed_shot.full_recharge_time - gcd * buff.precise_shots.stack + action.aimed_shot.cast_time end,
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
            
            recheck = function () return cooldown.rapid_fire.remains - gcd end,
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
            
            recheck = function () return focus.time_to_91, focus.time_to_71, buff.steady_focus.remains, focus.time_to_46, cooldown.aimed_shot.full_recharge_time < gcd * buff.precise_shots.stack + action.aimed_shot.cast_time, buff.trick_shots.remains end,
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
    
        package = "Marksmanship",        
    } )


    spec:RegisterPack( "Marksmanship", 20180717.0147, [[dae6waWiqr1MuLmkffNsrPvbkkVsinlHWTeIODPQ(fLyyGshtvQLbQ8muktJuHRrQOTje13afghOkoNqKwhOiyEOuDpuY(ufDqqrIfQiEiOiQlkebJeue6KGIiRuOAMcrOBcksANcLNsXuPK2lv)vHbl4WsTyi9yGjRIlJSzv6ZKQgnPCArRguK61KknBiUnk2nu)wYWPulNKNR00jUoiBxr13vKgpOkDEqvnFvH9JQ93Uv3CAH8yWb7B4bwy8ggFyFRdy8gECJaFBYn2nq3wp5gCZqUbMAR0DzA8QL2UXUHps1h3QB2csbi3OjI9ctWIf9PObH(bfJLnzGqAjlmq1xXYMmalOifQf0Bhjp0ClewFIjlaKE3btDGqO1YcgAqyHuFGTnmpsuNSbdD6guOerGjHDu3CAH8yWb7B4bwy8ggFyFRdDOJi7Mgs0kLBmjdmz3COf4gRA5Yd5Ydnpy3aDB9epuxEObswyEajxz5HBP4byIKUjs(DdsUY6wDZHUneI4w9yVDRUPbswy30qsnwTsCdHBue64tCXJbNB1nnqYc7gqbHfsnwTsCdHBue64tCXJXMB1nnqYc7gOLgPqmRBiCJIqhFIlEmD4wDdHBue64tCdqLcPY2nhcf6E)AqyHu7GPv6(p1uSBAGKf2nAqyHu7GPv66IhtNUv3q4gfHo(e3auPqQSDdOkKtnf)vTDEg3urFfX0jE5b25b9GJBAGKf2nNccfHgsB7IhlYUv3q4gfHo(e3auPqQSDdOkKtnf)ffeTAL8vetN4LhEYdSbRBAGKf2nOKAjLUjwVlEmy4wDdHBue64tCdqLcPY2nGQqo1u8xuq0QvYxrmDIxE4jpWgSUPbswy3GIu1zCHuW3fpg84wDdHBue64tCdqLcPY2nGQqo1u8xuq0QvYxrmDIxE4jpWgSUPbswy30yaTIQrgGgbXfpwK6wDdHBue64tCdqLcPY2nGQqo1u8xuq0QvYxrmDIxE4jpWgSUPbswy3CtfHIu1Xfp2ByDRUPbswy3GK61KDatdD0ZqyXneUrrOJpXfp273Uv3q4gfHo(e3auPqQSDZm8ak09(ffeTAL8vudeE4fpGcDVFuKQoiqR8vudeEywE4XdEygEygEau4fIPrrOVTQqkSE6mSRPKIhEXdsR0tYxsgAi14KepWopez44Hz5Hhp4bPv6j5ljdnKACsIhyNhy7npmRBAGKf2n2LKf2fp2B4CRUHWnkcD8jUbOsHuz7gqviNAk(3jdDgRwjFGwR0tlpWop82nnqYc7grbrRwjU4XEZMB1neUrrOJpXnavkKkB30ajNtdctmjT8WtE4TBAGKf2nOTs16jx8yV1HB1neUrrOJpXnavkKkB30ajNtdctmjT8WtE4TBAGKf2ne8AJuBoNgRwjU4XERt3QBiCJIqhFIBaQuiv2UPbsoNgeMysA5HN8aC8WlEaf6E)2kcKlnwTs2pKnp8IhavHCQP4FNm0zSAL8Vqiidfb0ALEAijdXdSZd6bhEaMXdOq373wrGCPXQvY(xPb6Ydr5HgizH)DYqNXQvYh0RmKKHCtdKSWUHbcrYvRex8yVJSB1neUrrOJpXnavkKkB30ajNtdctmjT8a78aB8WlEaf6E)2kcKlnwTs2pKnp8IhavHCQP4FNm0zSAL8Vqiidfb0ALEAijdXdSZd6bhEaMXdOq373wrGCPXQvY(xPb6Ydr5HgizH)DYqNXQvYh0RmKKHCtdKSWUPvGgtJvRex8yVHHB1neUrrOJpXnavkKkB3GcDVFBfbYLgRwj7)utX8WlEaf6E)NccfHgsB)p1ump8IhMHhAGKZPbHjMKwE4jpahp8IhqHU3VOsGUJvRK9dzZdpEWdnqY50GWetslpWopWgp8IhUqiidfb0ALEAijdXdSZdGELHKmepeLh0do8WSUPbswy30jdDgRwjU4XEdpUv3q4gfHo(e3auPqQSDtdKConimXK0YdSZdSXdpEWdOq37xujq3XQvY(HSDtdKSWUr125zCtf5Ih7DK6wDtdKSWUHGxBKAZ50y1kXneUrrOJpXfpgCW6wDdHBue64tCdqLcPY2nk6QOvRrri30ajlSBwsztyzSsI17IhdU3Uv30ajlSBqBLQ1tUHWnkcD8jU4XGdo3QBAGKf2n2jPajw)y1kXneUrrOJpXfpgCS5wDtdKSWUPhmqQdPg1Dau101neUrrOJpXfpgC6WT6gc3Oi0XN4gGkfsLTBAGKZPbHjMKwE4jpahp8IhqHU3VOsGUJvRK9FQPy30ajlSByGqKC1kXfpgC60T6gc3Oi0XN4gGkfsLTBqHU3VTIa5sJvRK9FQPyE4fpmdpCla0Ydp5byalp84bpGcDV)vO(a)XTaq7)utX8WSUPbswy30jdDgRwjU4XGlYUv3q4gfHo(e3auPqQSDtdKConimXK0Ydp5b44Hx8Wm8WTaqlp8KhIuy5Hhp4buO79BRiqU0y1kz)q28WlEygE4waOLhEYdWawE4XdEaf6E)Rq9b(JBbG2)PMI5Hx8WTaqlp8Kh0Ho5Hz5HzDtdKSWUHbcrYvRex8yWbd3QBiCJIqhFIBaQuiv2UPbsoNgeMysA5b25b24Hx8Wm8WTaqlp8KhGbS8WJh8ak09(xH6d8h3caT)tnfZdV4Hz4HBbGwE4jpezy5Hhp4buO79BRiqU0y1kz)q28WS8WSUPbswy30kqJPXQvIlEm4Gh3QBAGKf2nRq9b(JvRe3q4gfHo(exCXn2kcumOT4w9yVDRUHWnkcD8jU4XGZT6gc3Oi0XN4IhJn3QBiCJIqhFIlEmD4wDdHBue64tCdqLcPY2nnqY50GWetslpWopWMBAGKf2nledtHh2K4IhtNUv3q4gfHo(ex8yr2T6MgizHDJDjzHDdHBue64tCXJbd3QBAGKf2nAqyHu7GPv66gc3Oi0XN4IhdECRUHWnkcD8jUXwrGELHKmKB0PBAGKf2nNccfHgsB7IhlsDRUHWnkcD8jUbOsHuz7Mgi5CAqyIjPLhyNhyZnnqYc7MozOZy1kXfp2ByDRUHWnkcD8jUbOsHuz7Mgi5CAqyIjPLhEYdW5MgizHDdbV2i1MZPXQvIlU4IBMtQnlShdoyFdpWcJ368dhC6awyF7MPTcNy9RBCJTQUjc5gyopejaVeasOdpGs3sr8aOyqBHhqj9jE)8amfaGSLLhWfosQ1kMlecp0ajl8Ydfgb(FE8gizH3VTIafdAlSUi9QlpEdKSW73wrGIbTLOSS0q6ziS0swyE8gizH3VTIafdAlrzz5w1HhVbsw49BRiqXG2suwwwigMcpSjjI8YQbsoNgeMysAzNnECyopyWT9QvcpO68WdOq3lD4HvAz5bu6wkIhafdAl8akPpXlp04dpyROiPDjsI1Zd5YdNctFE8gizH3VTIafdAlrzzzXT9QvYyLwwE8gizH3VTIafdAlrzzXUKSW84nqYcVFBfbkg0wIYYIgewi1oyALU84nqYcVFBfbkg0wIYYYPGqrOH02ryRiqVYqsgILo5XBGKfE)2kcumOTeLLLozOZy1kjI8YQbsoNgeMysAzNnE8gizH3VTIafdAlrzzHGxBKAZ50y1kjI8YQbsoNgeMysAFchpopomNhIeGxcaj0HhO5Kc(8GKmepiAep0aPu8qU8qpVtKgfH(84nqYcVSAiPgRwj84nqYcVrzzbuqyHuJvReE8gizH3OSSaT0ifIz5XBGKfEJYYIgewi1oyALUrKxwhcf6E)AqyHu7GPv6(p1umpEdKSWBuwwofekcnK2oI8YcufYPMI)Q2opJBQOVIy6eVSRhC4XBGKfEJYYckPwsPBI1hrEzbQc5utXFrbrRwjFfX0jEFYgS84nqYcVrzzbfPQZ4cPGFe5LfOkKtnf)ffeTAL8vetN49jBWYJ3ajl8gLLLgdOvunYa0iirKxwGQqo1u8xuq0QvYxrmDI3NSblpEdKSWBuwwUPIqrQ6erEzbQc5utXFrbrRwjFfX0jEFYgS84nqYcVrzzbj1Rj7aMg6ONHWcpEdKSWBuwwSljlCe5L1mOq37xuq0QvYxrnqEHcDVFuKQoiqR8vudKzF8yMzafEHyAue6BRkKcRNod7AkPEjTspjFjzOHuJtsShz4M9XdPv6j5ljdnKACsID2EplpEdKSWBuwwefeTALerEzbQc5utX)ozOZy1k5d0ALEAz)npEdKSWBuwwqBLQ1trKxwnqY50GWets7Z384nqYcVrzzHGxBKAZ50y1kjI8YQbsoNgeMysAF(MhVbsw4nkllmqisUALerEz1ajNtdctmjTpH7fk09(TveixASALSFi7xGQqo1u8Vtg6mwTs(xieKHIaATspnKKHyxp4aZqHU3VTIa5sJvRK9Vsd0nAdKSW)ozOZy1k5d6vgsYq84nqYcVrzzPvGgtJvRKiYlRgi5CAqyIjPLD2EHcDVFBfbYLgRwj7hY(fOkKtnf)7KHoJvRK)fcbzOiGwR0tdjzi21doWmuO79BRiqU0y1kz)R0aDJ2ajl8Vtg6mwTs(GELHKmepEdKSWBuww6KHoJvRKiYlluO79BRiqU0y1kz)NAk(fk09(pfekcnK2(FQP4xZ0ajNtdctmjTpH7fk09(fvc0DSALSFi7hpAGKZPbHjMKw2z71fcbzOiGwR0tdjzi2b9kdjzOO6bNz5XBGKfEJYYIQTZZ4MkkI8YQbsoNgeMysAzNThpqHU3VOsGUJvRK9dzZJ3ajl8gLLfcETrQnNtJvReE8gizH3OSSSKYMWYyLeRpI8YsrxfTAnkcXJ3ajl8gLLf0wPA9epEdKSWBuwwStsbsS(XQvcpEdKSWBuww6bdK6qQrDhavnD5XBGKfEJYYcdeIKRwjrKxwnqY50GWets7t4EHcDVFrLaDhRwj7)utX84nqYcVrzzPtg6mwTsIiVSqHU3VTIa5sJvRK9FQP4xZCla0(egW(4bk09(xH6d8h3caT)tnfplpEdKSWBuwwyGqKC1kjI8YQbsoNgeMysAFc3RzUfaAFgPW(4bk09(TveixASALSFi7xZCla0(egW(4bk09(xH6d8h3caT)tnf)6waO9Po05SZYJ3ajl8gLLLwbAmnwTsIiVSAGKZPbHjMKw2z71m3caTpHbSpEGcDV)vO(a)XTaq7)utXVM5waO9zKH9XduO79BRiqU0y1kz)q2ZolpEdKSWBuwwwH6d8hRwjUzTjGhdoDQdxCXDa]] )
end