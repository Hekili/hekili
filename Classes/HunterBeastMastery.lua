-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 253 )

    spec:RegisterResource( Enum.PowerType.Focus, {
        aspect_of_the_wild = {
            resource = 'focus',
            aura = 'spect_of_the_wild',

            last = function ()
                local app = state.buff.aspect_oF_the_wild.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 5,
        },

        barbed_shot = {
            resource = 'focus',
            aura = 'barbed_shot',

            last = function ()
                local app = state.buff.barbed_shot.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = function () return state.talent.scent_of_blood.enabled and 7 or 5 end,
        },

        barbed_shot_2 = {
            resource = 'focus',
            aura = 'barbed_shot_2',

            last = function ()
                local app = state.buff.barbed_shot_2.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = function () return state.talent.scent_of_blood.enabled and 7 or 5 end,
        },

        barbed_shot_3 = {
            resource = 'focus',
            aura = 'barbed_shot',

            last = function ()
                local app = state.buff.barbed_shot_3.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = function () return state.talent.scent_of_blood.enabled and 7 or 5 end,
        },

        barbed_shot_4 = {
            resource = 'focus',
            aura = 'barbed_shot',

            last = function ()
                local app = state.buff.barbed_shot_4.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = function () return state.talent.scent_of_blood.enabled and 7 or 5 end,
        },

        barbed_shot_5 = {
            resource = 'focus',
            aura = 'barbed_shot',

            last = function ()
                local app = state.buff.barbed_shot_5.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = function () return state.talent.scent_of_blood.enabled and 7 or 5 end,
        },
    } )
    
    -- Talents
    spec:RegisterTalents( {
        killer_instinct = 22291, -- 273887
        animal_companion = 22280, -- 267116
        dire_beast = 22282, -- 120679

        scent_of_blood = 22500, -- 193532
        one_with_the_pack = 22266, -- 199528
        chimaera_shot = 22290, -- 53209

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        venomous_bite = 22441, -- 257891
        thrill_of_the_hunt = 22347, -- 257944
        a_murder_of_crows = 22269, -- 131894

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shot = 22499, -- 109248

        stomp = 19357, -- 199530
        barrage = 22002, -- 120360
        stampede = 23044, -- 201430

        aspect_of_the_beast = 22273, -- 191384
        killer_cobra = 21986, -- 199532
        spitting_cobra = 22295, -- 194407
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

        aspect_of_the_wild = {
            id = 193530,
            duration = 20,
            max_stack = 1,
        },

        barbed_shot = {
            id = 246152,
            duration = 8,
            max_stack = 1,
        },

        barbed_shot_2 = {
            id = 246851,
            duration = 8,
            max_stack = 1,
        },

        barbed_shot_3 = {
            id = 246852,
            duration = 8,
            max_stack = 1,
        },

        barbed_shot_4 = {
            id = 246853,
            duration = 8,
            max_stack = 1,
        },

        barbed_shot_5 = {
            id = 246854,
            duration = 8,
            max_stack = 1,
        },        

        barbed_shot_dot = {
            id = 217200,
            duration = 8,
            max_stack = 1,
        },

        barrage = {
            id = 120360,
        },

        beast_cleave = {
            id = 115939,
            duration = 4,
            max_stack = 1,
        },

        bestial_wrath = {
            id = 19574,
            duration = 15,
            max_stack = 1,
        },

        binding_shot = {
            id = 117405,
            duration = 3600,
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

        eagle_eye = {
            id = 6197,
            duration = 60,
        },

        exotic_beasts = {
            id = 53270,
        },

        feign_death = {
            id = 5384,
            duration = 360,
            max_stack = 1,
        },

        freezing_trap = {
            id = 3355,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },

        frenzy = {
            id = 272790,
            duration = 8,
            max_stack = 3,
        },

        growl = {
            id = 2649,
            duration = 3,
            max_stack = 1,
        },

        intimidation = {
            id = 24394,
            duration = 5,
            max_stack = 1,
        },

        kindred_spirits = {
            id = 56315,
        },

        masters_call = {
            id = 54216,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },

        misdirection = {
            id = 35079,
            duration = 8,
            max_stack = 1,
        },

        parsels_tongue = {
            id = 248085,
            duration = 8,
            max_stack = 4,
        },

        posthaste = {
            id = 118922,
            duration = 4,
            max_stack = 1,
        },

        spitting_cobra = {
            id = 194407,
            duration = 20,
            max_stack = 1,
        },

        stampede = {
            id = 201430,
        },

        tar_trap = {
            id = 135299,
            duration = 3600,
            max_stack = 1,
        },

        thrill_of_the_hunt = {
            id = 257946,
            duration = 8,
            max_stack = 2,
        },

        trailblazer = {
            id = 231390,
            duration = 3600,
            max_stack = 1,
        },

        wild_call = {
            id = 185789,
        },
    } )

    -- Abilities
    spec:RegisterAbilities( {
        a_murder_of_crows = {
            id = 131894,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 30,
            spendType = "focus",

            talent = 'a_murder_of_crows',   
            
            startsCombat = true,
            texture = 645217,
            
            handler = function ()
                applyDebuff( 'target', 'a_murder_of_crows' )
            end,
        },
        

        aspect_of_the_cheetah = {
            id = 186257,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132242,
            
            handler = function ()
                applyBuff( 'aspect_of_the_cheetah' )
            end,
        },
        

        aspect_of_the_turtle = {
            id = 186265,
            cast = 8,
            cooldown = 180,
            gcd = "spell",
            channeled = true,

            startsCombat = false,
            texture = 132199,
            
            handler = function ()
                applyBuff( 'aspect_of_the_turtle' )
            end,
        },
        

        aspect_of_the_wild = {
            id = 193530,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = 'cooldowns',
            
            startsCombat = false,
            texture = 136074,
            
            handler = function ()
                applyBuff( 'aspect_of_the_wild' )
            end,
        },
        

        barbed_shot = {
            id = 217200,
            cast = 0,
            charges = 2,
            cooldown = function () return 12 * haste end,
            recharge = function () return 12 * haste end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 2058007,
            
            handler = function ()
                if buff.barbed_shot.down then applyBuff( 'barbed_shot' )
                else
                    for i = 2, 5 do
                        if buff[ 'barbed_shot_' .. i ].down then applyBuff( 'barbed_shot_' .. i ); break end
                    end
                end
                addStack( 'frenzy', 8, 1 )
                setCooldown( 'bestial_wrath', cooldown.bestial_wrath.remains - 12 )
                applyDebuff( 'target', 'barbed_shot_dot' )
            end,
        },
        

        barrage = {
            id = 120360,
            cast = function () return 3 * haste end,
            cooldown = 20,
            gcd = "spell",
            channeled = true,
            
            spend = 60,
            spendType = "focus",
            
            startsCombat = true,
            texture = 236201,
            
            handler = function ()
            end,
        },
        

        bestial_wrath = {
            id = 19574,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132127,
            
            handler = function ()
                applyBuff( 'bestial_wrath' )
            end,
        },
        

        binding_shot = {
            id = 109248,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            talent = 'binding_shot',

            startsCombat = true,
            texture = 462650,
            
            handler = function ()
                applyDebuff( 'target', 'binding_shot' )
            end,
        },
        

        camouflage = {
            id = 199483,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 461113,
            
            handler = function ()
                applyBuff( 'camouflage' )
            end,
        },
        

        chimaera_shot = {
            id = 53209,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            talent = 'chimaera_shot',
            
            startsCombat = true,
            texture = 236176,
            
            handler = function ()
                gain( 10 * min( 2, active_enemies ), 'focus' )                
            end,
        },
        

        cobra_shot = {
            id = 193455,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 35,
            spendType = "focus",
            
            startsCombat = true,
            texture = 461114,
            
            handler = function ()                
                if talent.venomous_bite.enabled then setCooldown( 'bestial_wrath', cooldown.bestial_wrath.remains - 1 ) end
                if talent.killer_cobra.enabled and buff.bestial_wrath.up then setCooldown( 'kill_command', 0 )
                else setCooldown( 'kill_command', cooldown.kill_command.remains - 1 ) end
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
                applyDebuff( 'target', 'concussive_shot' )
            end,
        },
        

        counter_shot = {
            id = 147362,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            toggle = 'interrupts',
            
            startsCombat = true,
            texture = 249170,
            
            usable = function () return debuff.casting.up end,
            handler = function ()
                interrupt()
            end,
        },
        

        dire_beast = {
            id = 120679,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 25,
            spendType = "focus",
            
            startsCombat = true,
            texture = 236186,
            
            handler = function ()
                summonPet( 'dire_beast', 8 )
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
            end,
        },
        

        eagle_eye = {
            id = 6197,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132172,
            
            handler = function ()
                applyBuff( 'eagle_eye', 60 )
            end,
        },
        

        exhilaration = {
            id = 109304,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 461117,
            
            handler = function ()
                gain( 0.3 * health.max, "health" )
            end,
        },
        

        feign_death = {
            id = 5384,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132293,
            
            handler = function ()
                applyBuff( 'feign_death' )
            end,
        },
        

        flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135815,
            
            handler = function ()
            end,
        },
        

        freezing_trap = {
            id = 187650,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135834,
            
            handler = function ()
                applyDebuff( 'target', 'freezing_trap' )
            end,
        },
        

        intimidation = {
            id = 19577,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132111,
            
            handler = function ()
                applyDebuff( 'target', 'intimidation' )
            end,
        },
        

        kill_command = {
            id = 34026,
            cast = 0,
            cooldown = function () return 7.5 * haste end,
            gcd = "spell",
            
            spend = 30,
            spendType = "focus",
            
            startsCombat = true,
            texture = 132176,
            
            recheck = function () return buff.dire_frenzy.remains end,
            handler = function ()
            end,
        },
        

        masters_call = {
            id = 272682,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236189,
            
            handler = function ()
            end,
        },
        

        misdirection = {
            id = 34477,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132180,
            
            handler = function ()
            end,
        },
        

        multishot = {
            id = 2643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 40,
            spendType = "focus",
            
            startsCombat = true,
            texture = 132330,
            
            recheck = function () return buff.beast_cleave.remains - gcd, buff.beast_cleave.remains end,
            handler = function ()
                applyBuff( 'beast_cleave' )
            end,
        },
        

        spitting_cobra = {
            id = 194407,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            talent = 'spitting_cobra',
            toggle = 'cooldowns',
            
            startsCombat = true,
            texture = 236177,
            
            handler = function ()
                summonPet( 'spitting_cobra', 20 )
                applyBuff( 'spitting_cobra', 20 )
            end,
        },
        

        stampede = {
            id = 201430,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = 'cooldowns',
            talent = 'stampede',
            
            startsCombat = true,
            texture = 461112,
            
            handler = function ()
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
            texture = 'Interface\\ICONS\\Ability_Hunter_BeastCall',

            usable = function () return not talent.lone_wolf.enabled and not pet.exists end,
            handler = function ()
                summonPet( 'made_up_pet', 3600, 'ferocity' )
            end,
        },

        tar_trap = {
            id = 187698,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 576309,
            
            handler = function ()
            end,
        },

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
    } )


    spec:RegisterPack( "Beast Mastery", 20180619.225300, [[dGemEaqiiv9iQuQnjr(KQssgfIQtHiTkQu8kjOzjr1TuvsTlc)crmmvL6ysOLPQ4zQkX0OsKRbjPTjrHVrLOghvk5CuqSoijAEujDpk0(GehuvjXcHuEOQssnrjksxuIIyJuqcJKcs5KuqIwjIYnLOO2jvQ(jfKQHcjHLsbj9ueMkf4RsuQ9s0FfzWahwyXI6XuAYs6YO2Ss9zvvJMkoTIxlbMnvDBi2ns)wLHtrhhsLLd1ZbnDsxxv2ofuFxjnEiPopvcRxIsMVsSFPwwuAGKOgklD)Z3fDRVlJIgI4Zhu9dQkjuxyYscZWwq8ZscAGWsc04aQnOmhqLXUqsygUWFrvAGKaEpSLLeoQAcrLKqY)OoVSWEiKahKNp05OwCSvsGdILKS)YKK3XxxzdtIj(2JNHKGkWSHAmvijOcd1KH2JQmoHghqnvMdOYyxiGdIvsKFJxnusLzjrnuws857IU1x)Dz81fnKg85dQ0Lmejb0KTs3)GQFrsuzOvsyGZaBWaBG6WnOY7451gewDoAdmdBbnyF4gGghqTbL5aQm2fnWq7rvgdBWqBaA7VIqs4hOcLgijQ8oEEvAG09IsdKeHvNJkjINEjOZPscMgzpxLOjvP7FKgijyAK9CvIMKWIhLXtijy09gttUkGSPZRSGjiBXS2Gsnqd8pRIkNF7TWgqDO)cmhwTbLAG9oF9wPI8BVfq205vwWeKTywfpZguQbOVb53ElGSPZRSGjiBXSkEMsIWQZrLe27rvgNGoNkvP7FrAGKiS6CujXdYPrzeOKGPr2ZvjAsv6UljnqsW0i75QenjHfpkJNqsSp7dkQ8ESJ2aum2GV8TKiS6CujrGTbLt6HXmvLQ0DuvAGKGPr2ZvjAsclEugpHKi)2BrMH6e(0kouhbMrIHcBaknWLBqPgqEdqFdGSMYh9bf6W4pFN(yABakn47gSS0G8BVfzgQt4tR4qDeygjgkSbU2GIfBaPsIWQZrLezgdzCbd9xQs3ldPbscMgzpxLOjjS4rz8esI8BVfzgQt4tR4qDeygjgkSbO0axwsewDoQKi7VRM2pSlKQ0DxwAGKGPr2ZvjAsclEugpHKi)2BrMH6e(0kouhXZSbLAq(T3IaAYwnD7K6WP1Xxfptjry15OscZtNJkvP7UL0ajbtJSNRs0Kew8OmEcjH9oF9wPImd1j8PvCOocmJedf2axBWxAWYsd0a)ZQqheoPxQoCdCTbfldjry15OsIiH8WvgNUDYIVvOuLUBisdKemnYEUkrtsyXJY4jKe53ElY(7Q(hufpZgSS0G8BVfzgQt4tR4qDepZgSS0a7D(6TsfzgQt4tR4qDeygjgkSbUASbFAWYsd0a)ZQqheoPxQoCdC1ydk6ssIWQZrLeqnqm5klvP7f)wAGKGPr2ZvjAsclEugpHKa9ni)2BrMH6e(0kouhXZusewDoQKiZqDcFAfhQJuLUxSO0ajbtJSNRs0Kew8OmEcjb5nGr3Bmn5QWgEF62j1HtRJV2GsnGr3Bmn5QWEudZ4FMA50Tt7qzydk1an8mvfhLtRJ6Kuhozg2cemnYEU2asBWYsdYV9wKzOoHpTId1rGzKyOWgGsdC5gSS0anW)Sk0bHt6LQd3axBqXpsIWQZrLeb0KTA62j1HtRJVkvP7f)inqsW0i75Qenjry15OsIcgVpzpeKGwLew8OmEcjb5na9nqdptvroWzUMGoNkyAK9CTbllnG8gKF7Tih4mxtqNtfygjgkSbO0GFBTbUPbffFAWYsdiVbOVb53ElYboZ1e05uXZSbLAa6BGgEMQIJYP1rDsQdNmdBbcMgzpxBaPnG0gqAdk1aYBaYqrLzgQt4tBgF2rDHaZiXqHnGujHg4FwtZwsGmuuzMH6e(0MXNDuxiWmsmuOuLUx8lsdKemnYEUkrtsyXJY4jKeqwt5J(GcDy8NVtFmTnaLg8Ddk1aOj79jnW)ScfipVoqNtBGXguSbLAa6BaJU3yAYvb6ctFKymxF00AGthUY4guQbK3G8BVfzgQt4tR4qDepZguQb53ElYmuNWNwXH6iWmsmuydCTb)2AdCtd(0asBqPgqEdqFd0WZuvKdCMRjOZPcMgzpxBWYsdYV9wKdCMRjOZPcmJedf2auAWVT2a30GIIpnGujry15Osc7LXrc6CQuLUx0LKgijyAK9CvIMKWIhLXtijS35R3kvKzOoHpTId1rGzKyOWgGsd(0GsnG8gqEdqFdy09gttUkqxy6JeJ56JMwdC6Wvg3GLLgyVZxVvQOGX7t2dbjOvbMrIHcBakgBqXgqAdwwAW(59jmBDc8pN0bHBGRn43wBWYsdS35R3kvOJguysDE0kJfpZgSS0aOj79jnW)ScBaknOydivsewDoQKOoyoL5aQsv6EruvAGKGPr2ZvjAsclEugpHKi)2BroWzUMGoNkWmsmuydC1yd(T1g4Mguu8PbllnG8gOHNPQ4OCADuNK6WjZWwGGPr2Z1guQbK3a7D(6TsfzgQt4tR4qDeygjgkSbO0GV0GsnW6e4FgM24WQZrdFdqPbffFAaPnG0gSS0G9Z7ty26e4FoPdc3axBWVT2GLLgOb(NvHoiCsVuD4g4Admejry15OsICGZCnbDovQs3lwgsdKemnYEUkrtsyXJY4jKeqt27tAG)zfkYbgh)CdqPbfLeHvNJkjYbgh)SuLUx0LLgijyAK9CvIMKWIhLXtijGMS3N0a)ZkSbO0axQbLAa5ni)2BrMdOMSEommlWmsmuydCTb)2AdwwAq(T3Imhqnz9CyywuVvAdivsewDoQKa551b6CQuLUx0TKgijcRohvsuW49j7HGe0QKGPr2ZvjAsv6ErdrAGKGPr2ZvjAsclEugpHKaAYEFsd8pRWgGsdk2GsnG8gKF7TiZbutwphgMfygjgkSbU2GFBTbllni)2BrMdOMSEommlQ3kTbKkjcRohvsG886aDovQs3)8T0ajbtJSNRs0Kew8OmEcjX(SpydCTbgY3sIWQZrLewNbjyCKGoNkvP7FkknqsW0i75QenjHfpkJNqsWO7nMMCvGVaNUDsD4eKnmtt(5OWguQbqt27tAG)zfkqEEDGoN2aJnOydk1aYBG9oF9wPIcgVpzpeKGwfygjgkSbO0G9zFqHoiCsVesG6g4Mg8TWTq1guQb2781BLkYmuNWNwXH6iWmsmuydqPb7Z(GcDq4KEjKa1nWnn4BHBHQnGujry15Osc7LXrc6CQuLU)5J0ajbtJSNRs0Kew8OmEcjb5nWENVERurbJ3NShcsqRcmJedf2auAW(SpOqheoPxcjqDdk1a7D(6TsfzgQt4tR4qDeygjgkSbO0G9zFqHoiCsVesG6gqAdwwAa5ni)2BrMH6e(0kouhXZSbLAa5naAYEFsd8pRqbYZRd050gySbfBWYsd2N9bfy(NPnWnnWENVERurbJ3NShcsqRcmJedf2auAqy15OIcgVpzpeKGwf2dQnG0gqAdwwAGg4Fwf6GWj9s1HBGRnWENVERurbJ3NShcsqRcmJedf2GLLgqEdy09gttUkmdmK9WKE0)h3Gsni)2BHzGHShM0J()ybMrIHcBGRgBWVT2a30GpnGujry15Osc7LXrc6CQuLU)5lsdKemnYEUkrtsyXJY4jKe53ElYmuNWNwXH6iEMsIWQZrLe1bZPmhqvQsvsyIz7HKdvAG09IsdKemnYEUkrtQs3)inqsW0i75QenPkD)lsdKemnYEUkrtQs3DjPbsIWQZrLeWhcYrtMSkjyAK9CvIMuLUJQsdKemnYEUkrtQs3ldPbsIWQZrLeMNohvsW0i75QenPkvPkjwdmDO)qjHKWeF7XZsc3UbLjOMTpLRniZ7dZnWEi5qBqM)hku0GVI1YMkSb0J(1obgz)8niS6CuydoQ3fIMSWQZrHctmBpKCOg3(awqtwy15OqHjMThso0cnss8(ryQg6C0MSWQZrHctmBpKCOfAKK9D1MSWQZrHctmBpKCOfAKe4db5OjtwBYC7gqqdtOZPnahtTb53EZ1ga1qHniZ7dZnWEi5qBqM)hkSbbT2atm)1MNQd9VbdSb1JYIMSWQZrHctmBpKCOfAKeinmHoNMGAOWMSWQZrHctmBpKCOfAKeZtNJ2K1K52nOmb1S9PCTbSHzSlAGoiCduhUbHvpCdgydcdhJpYEw0KfwDok0y80lbDoTjlS6CuyHgjXEpQY4e050YNTrgDVX0KRciB68klycYwmRL0a)ZQOY53ElSbuh6VaZHvlzVZxVvQi)27eKnDELfmbzlMvXZSe6ZV9waztNxzbtq2Izv8mBYcRohfwOrsEqonkJaBYcRohfwOrscSnOCspmMPA5Z24(SpOOY7Xokkg)Y3nzHvNJcl0ijzgdzCbd9V8zBm)2BrMH6e(0kouhbMrIHcrXLlro6HSMYh9bf6W4pFN(yAxwYV9wKzOoHpTId1rGzKyOqxlwK0MSWQZrHfAKKS)UAA)WUO8zBm)2BrMH6e(0kouhbMrIHcrXLBYcRohfwOrsmpDoA5Z2y(T3Imd1j8PvCOoINzP8BVfb0KTA62j1HtRJVkEMnzHvNJcl0ijrc5HRmoD7KfFRWYNTr7D(6TsfzgQt4tR4qDeygjgk01VSSOb(NvHoiCsVuDyxlwgnzHvNJcl0ijqnqm5kx(SnMF7Ti7VR6Fqv8mxwYV9wKzOoHpTId1r8mxwS35R3kvKzOoHpTId1rGzKyOqxn(zzrd8pRcDq4KEP6WUASOl1KfwDokSqJKKzOoHpTId1P8zBe953ElYmuNWNwXH6iEMnzUDdk7rDAq(uNg8voTSBGTIBa8EyldBqqRnWqFvrfL3GhKBWOn4OnWwfnWqxDy86a5gygdUbJ2G1rDAaAmuNW3GYghQJOjlS6CuyHgjjGMSvt3oPoCAD81YNTrYz09gttUkSH3NUDsD4064RLy09gttUkSh1Wm(NPwoD70ougwsdptvXr506Ooj1HtMHTabtJSNRKUSKF7TiZqDcFAfhQJaZiXqHO4YllAG)zvOdcN0lvh21IFAYC7gu2J60ap)Z0AGDrdY3PWgm6xfSbMheozp3GGwBqMP8ESt4BGEna551PEAduhUbOXqDcFdmuW4ZoQlAq2ZCv0KfwDokSqJKuW49j7HGe0A5AG)znnBJidfvMzOoHpTz8zh1fcmJedfw(SnIEn8mvf5aN5Ac6CQGPr2Z1LfYnzvydvKF7Tih4mxtqNtfygjgkeLFBvGeO2nffFwwih9MSkSHkYV9wKdCMRjOZPINzj0RHNPQ4OCADuNK6WjZWwGGPr2ZvsjTjZTBqzpQZ90g45FMwdSlAq(ofwEd0OaUbr1WbvJFUb3UbQd3a9Z3n4JPTb5J(Gni7IgydOo0)g8vFzC0acNtBWzyg3GYu0AWqBG6WnWhqTb27z65gaz7rRWgC7gGwzlAYcRohfwOrsSxghjOZPLpBJqwt5J(GcDy8NVtFmTLGMS3N0a)ZkuG886aDo1yXsONr3Bmn5QaDHPpsmMRpAAnWPdxzCjYZV9wKzOoHpTId1r8mlLF7TiZqDcFAfhQJaZiXqHU(BRcKa1U5dPLih9A4zQkYboZ1e05ubtJSNRllMSkSHkYV9wKdCMRjOZPcmJedfIYVTkqcu7MIIpK2KfwDokSqJKuhmNYCa1YNTr7D(6TsfzgQt4tR4qDeygjgkeLpLiNC0ZO7nMMCvGUW0hjgZ1hnTg40HRmEzXENVERurbJ3NShcsqRcmJedfIIXIKUSSFEFcZwNa)ZjDqyx)TvbsG6Lf7D(6Tsf6ObfMuNhTYyXZCzbAYEFsd8pRquksAtwy15OWcnssoWzUMGoNw(SnAYQWgQi)2BroWzUMGoNkWmsmuORg)TvbsGA3uu8zzHCn8mvfhLtRJ6Kuhozg2cemnYEUwIC7D(6TsfzgQt4tR4qDeygjgkeLVuY6e4FgM24WQZrdpkffFiL0LL9Z7ty26e4FoPdc76VTkqcuVSOb(NvHoiCsVuDyxnKMSWQZrHfAKKCGXXpx(SncnzVpPb(NvOihyC8ZOuSjlS6CuyHgjb551b6CA5Z2i0K9(Kg4FwHO4sLi3KvHnur(T3Imhqnz9CyywGzKyOqx)TvbsG6Lftwf2qf53ElYCa1K1ZHHzr9wPK2KfwDokSqJKuW49j7HGe0Atwy15OWcnscYZRd050YNTrOj79jnW)ScrPyjYnzvydvKF7TiZbutwphgMfygjgk01FBvGeOEzXKvHnur(T3Imhqnz9CyywuVvkPnzHvNJcl0ijwNbjyCKGoNw(SnUp7d6QH8DtMB3auXD(g4ziSb7Z(Gny1HPnyLd8q)BGN)zAnWUObz2RIMSWQZrHfAKe7LXrc6CA5Z2iJU3yAYvb(cC62j1Htq2Wmn5NJclbnzVpPb(NvOa551b6CQXILi3ENVERurbJ3NShcsqRcmJedfIY(SpOqheoPxcjqTB(w4wOAj7D(6TsfzgQt4tR4qDeygjgkeL9zFqHoiCsVesGA38TWTqvsBYcRohfwOrsSxghjOZPLpBJKBVZxVvQOGX7t2dbjOvbMrIHcrzF2huOdcN0lHeOUK9oF9wPImd1j8PvCOocmJedfIY(SpOqheoPxcjqnPllKNF7TiZqDcFAfhQJ4zwICOj79jnW)ScfipVoqNtnwCzzF2huG5FM6g7D(6TsffmEFYEiibTkWmsmuikHvNJkky8(K9qqcAvypOskPllAG)zvOdcN0lvh2v7D(6TsffmEFYEiibTkWmsmu4Yc5m6EJPjxfMbgYEysp6)JlLF7TWmWq2dt6r)FSaZiXqHUA83wfibQDZhsBYcRohfwOrsQdMtzoGA5Z2y(T3Imd1j8PvCOoINPKiEQZHLeOIhnCyplvPkLa]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Beast Mastery",
    } )
end