-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

-- needed for Frenzy.
local FindUnitBuffByID = ns.FindUnitBuffByID


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

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3562, -- 208683
        relentless = 3561, -- 196029
        adaptation = 3560, -- 214027

        survival_tactics = 3599, -- 202746
        dragonscale_armor = 3600, -- 202589
        viper_sting = 3602, -- 202797
        spider_sting = 3603, -- 202914
        scorpid_sting = 3604, -- 202900
        hiexplosive_trap = 3605, -- 236776
        the_beast_within = 693, -- 212668
        interlope = 1214, -- 248518
        hunting_pack = 3730, -- 203235
        wild_protector = 821, -- 204190
        dire_beast_hawk = 824, -- 208652
        dire_beast_basilisk = 825, -- 205691
        roar_of_sacrifice = 3612, -- 53480
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
            id = 118455,
            duration = 4,
            max_stack = 1,
            generate = function ()
                local bc = buff.beast_cleave
                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 118455 )

                if name then
                    bc.name = name
                    bc.count = 1
                    bc.expires = expires
                    bc.applied = expires - duration
                    bc.caster = caster
                    return
                end

                bc.count = 0
                bc.expires = 0
                bc.applied = 0
                bc.caster = "nobody"
            end,
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
            duration = function () return azerite.feeding_frenzy.enabled and 9 or 8 end,
            max_stack = 3,
            generate = function ()
                local fr = buff.frenzy
                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 272790 )

                if name then
                    fr.name = name
                    fr.count = count
                    fr.expires = expires
                    fr.applied = expires - duration
                    fr.caster = caster
                    return
                end

                fr.count = 0
                fr.expires = 0
                fr.applied = 0
                fr.caster = "nobody"
            end,
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

                if azerite.primal_instinct.enabled then gainCharges( "barbed_shot", 1 ) end
            end,
        },
        

        barbed_shot = {
            id = 217200,
            cast = 0,
            charges = 2,
            cooldown = function () return 12 * haste end,
            recharge = function () return 12 * haste end,
            gcd = "spell",

            velocity = 50,
            
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
            
            recheck = function () return buff.bestial_wrath.remains end,
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

            velocity = 50,

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

            velocity = 45,
            
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

            velocity = 50,
            
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
            
            usable = function () return target.casting end,
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
            
            recheck = function () return buff.barbed_shot.remains end,
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

            velocity = 50,
            
            spend = 40,
            spendType = "focus",
            
            startsCombat = true,
            texture = 132330,
            
            velocity = 40,

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
            
            recheck = function () return cooldown.bestial_wrath.remains - gcd, target.time_to_die - 15 end,
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

            essential = true,

            usable = function () return not pet.exists end,
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


    spec:RegisterPack( "Beast Mastery", 20180929.2211, [[dOu4waqiiqEeQcBcc1NuQyuIsCkHOwfePYRuqZsuQBPuv7IQ(fKmmuLogQQLjKEgkIPHIsxdfPTbb03Ga14ecDouuToHG5HQO7bP2he1bHiLfkuEOsvCrLQK(OqezKcr6KcryLOWmvQsDtiO2Pq1qHGSuuu8urMQO4RcruJfcWzHizVs(RQmyQCyklwjpgXKv0LjTzu5ZOuJwPCAPwTsvIxdrmBb3wvTBGFRYWvOJdrQA5i9COMoX1fvBxb67OKXdHCELkTErjnFfW(bDXVYuPPjAfpkV8JiVmpkZ9rJYNFLKDh1knAeKyS1kbSVwPyQHfOdHnSO0DR0OTB4SzLPs4lNs0kTjYiocOqXULT8LNCFu4(NhmPpaHACckC)jOwHBHAXz7p1brnspUoOyuievzgRNyuieZ8I0CGO0xm1WYdHnSO0D94(tQ0kVdsKauRknnrR4r5LFe5L5rzUpAuEzw(8ReEujv8OmLjvARNtfuRknvmPs8a6IPgwGoe2WIs3f6I0CGOuidEaDBImIJakuSBzlF5j3hfU)5bt6dqOgNGc3FcQv4wOwC2(tDquJ0JRdkgfcrvMX6jgfcXmVinhik9ftnS8qydlkDxpU)eidEaDjDu0)sPqxuMNn0fLx(re62h6Ignc8YeOdHqyididEaD7zZaSvCeGm4b0Tp0H0MtDcD75YbIsHU02jqNCq3u5S8GaDgr6daDHgl(knspUoOvIhqxm1Wc0HWgwu6UqxKMdeLczWdOBtKrCeqHIDlB5lp5(OW9ppysFac14eu4(tqTc3c1IZ2FQdIAKECDqXOqiQYmwpXOqiM5fP5arPVyQHLhcByrP76X9NazWdOlPJI(xkf6IY8SHUO8YpIq3(qx0OrGxMaDiecdzazWdOBpBgGTIJaKbpGU9HoK2CQtOBpxoquk0L2ob6Kd6MkNLheOZisFaOl0yXdzazWdOBVIiLKl6e6wk3rvOJC)Ljq3sz3aSh6qAeIokyOdCG93m6NlpaDgr6dGHUde21dzyePpa2psvY9xMGMlyyKazyePpa2psvY9xMmenklN9xbIj9bGmmI0ha7hPk5(ltgIgf3DtidJi9bW(rQsU)YKHOrHZ))d8gvbYGhqxcyJ4TtGoQ1tOBLZXPtOdlMGHULYDuf6i3Fzc0Tu2nadDgycDJuD)XtKgWg6Am0npG6HmmI0ha7hPk5(ltgIgfgyJ4TtEyXemKHrK(ay)ivj3FzYq0OgpPpaKHrK(ay)ivj3FzYq0Om8OsK3X9Kn9XQdZSBo0iilRkTf1ps7VfEnalnGiyVcSvqNqggr6dG9JuLC)LjdrJAPyPTWJf1KTSBo0wwvAlQFK2Fl8AawAarWEfyRGoHmGm4b0TxrKsYfDcD6GkDxOt6VcDYMcDgrok01yOZg06GTcQhYWisFamAYLdeL(WBNazyePpaEiAu5y91I(Xqggr6dGhIg1sPyLIKgWo7Mdn5UW8yb8lflTfESOMS5P63AagzMWlKHrK(a4HOrTc3nFC50DZU5qtUlmpwa)sXsBHhlQjBEQ(TgGrMj8czyePpaEiAugGOyHAHhXcHSBo0K7cZJfWVuS0w4XIAYMNQFRbyKzcVqggr6dGhIgfxt1v4Uz2nhAYDH5Xc4xkwAl8yrnzZt1V1amYmHxidJi9bWdrJk0S3e8BVKpz)vGazyePpaEiAuJN0hi7Md9kNJZVuS0w4XIAYMpFeXRCooVHhvI8oUNSPpwDy6ZhHmmI0hapenQLrx68H3oj7Md9OkEIj(vohNNJQGSURpFeXJQ4jM4x5CCEoQcY6UEQ(TgG5jA2KP)BicYWisFa8q0OS3pNov674Ee6XcNDZH2ispO(uG(BfJMpKHrK(a4HOrTm6sNp82jz3CO5YdHhvjBgLT(K(R8Knz6)gIqm5UW8yb8lflTfESOMS5P63AagYWisFa8q0OWJTinG9JClQbzyePpaEiAuyX(J6uZU5qVY548lflTfESOMS5ZhhyaYDH5Xc4xkwAl8yrnzZt1V1ampztMdmGyu2Q4L(Rp5EZw5jFMczyePpaEiAugEujY74EYM(y1HjKHrK(a4HOr9ZdsJ3oj7MdnEudHNyu2QGrokIztM(VHO9hvXtmXVY548l1WYJeuBq1t1V1amY86JYuidJi9bWdrJAPyPTWJf1KTSBo0iOvohNFPyPTWJf1KnF(iKHrK(a4HOrTmk1yRz3COnI0dQpfO)wXiZhYWisFa8q0OiB93uQ9WBNKDZHgpQHWtmkBvWiZhYWisFa8q0O(5bPXBNKDZHgpQHWtmkBvWiZhXSjt)3q0(JQ4jM4x5CC(LAy5rcQnO6P63AagzE9rzkKHrK(a4HOrHKoeEK7)nWeYWisFa8q0OiB93uQ9WBNazyePpaEiAu27NtNk9DCpc9yHHmmI0hapenQzt13snSazyePpaEiAulJU05dVDs2nh6rv8et8RCoophvbzDx)8ybqmzZOSv8JJAePpGfqMVpIdmGyu2Q4L(Rp5EZw5jZHmmI0hapenQLrPgBfYWisFa8q0Oi3IAp82jz3COZIrKEq9Pa93kMNrhyaYDH5Xc4rshcpY9)gy6P63AagzUJKJ9s)1NCVVHOiJ4SWDKC8(Kdld5oso2tv2kaPllK7cZJfWJKoeEK7)nW0t1V1a8(8JmYgr6d4rshcpY9)gy6jhwgyaYDH5Xc4rshcpY9)gy6P63Aagz(dztMrgXK7cZJfWJKoeEK7)nW0t1V1amY8HmmI0hapenkJsmG(KJsvGuPbvkUpqfpkV8JiVmNFe98JYuMwjwgf0a24kfjJ0yM4rI4rsra6GUmBk01)XJkqh3rHUDMkNLhKDGoQI0N3uDcD47RqNLl33eDcDKndWwXEiJ9Ubk0X8iaD75adQurNq3oJQ4raEKY797aDYbD7GuEVFhOllrruK9qg7DduOJptJa0TNdmOsfDcD7mQIhb4rkV3Vd0jh0Tds59(DGUSWhrr2dzS3nqHo(mpcq3EoWGkv0j0TZOkEeGhP8E)oqNCq3oiL373b6YcFefzpKXE3af6IYSra62ZbguPIoHUDgvXJa8iL373b6Kd62bP8E)oqxw4JOi7HmGmIe)XJk6e6IcDgr6daDHglypKrLcnwWvMknvolpivMko)ktLmI0hOsKlhik9H3oPskWwbDwXkPIhTYujJi9bQuowFTOFCLuGTc6SIvsfNjvMkPaBf0zfRseAlkTTkrUlmpwa)sXsBHhlQjBEQ(TgGHoKHoMWBLmI0hOslLIvksAa7sQ4mBLPskWwbDwXQeH2IsBRsK7cZJfWVuS0w4XIAYMNQFRbyOdzOJj8wjJi9bQ0kC38XLt3TKkotRmvsb2kOZkwLi0wuABvICxyESa(LIL2cpwut28u9BnadDidDmH3kzePpqLmarXc1cpIfcLuXrGvMkPaBf0zfRseAlkTTkrUlmpwa)sXsBHhlQjBEQ(TgGHoKHoMWBLmI0hOsCnvxH7MLuXrWvMkzePpqLcn7nb)2l5t2Ffivsb2kOZkwjv8iwzQKcSvqNvSkrOTO02Q0kNJZVuS0w4XIAYMpFe6qm0TY548gEujY74EYM(y1HPpFSsgr6duPXt6dusfN5vMkPaBf0zfRseAlkTTkTY548CufK1D95JqhIHUvohNNJQGSURNQFRbyOJNOHo2KP)BiQsgr6duPLrx68H3oPKkoFERmvsb2kOZkwLi0wuABvYispO(uG(BfdDOHo(vYisFGkzVFoDQ03X9i0JfUKkoF(vMkPaBf0zfRseAlkTTkXLhcpQs2mkB9j9xHoEcDSjt)3qe0HyOJCxyESa(LIL2cpwut28u9BnaxjJi9bQ0YOlD(WBNusfNF0ktLmI0hOs4XwKgW(rUf1QKcSvqNvSsQ48zsLPskWwbDwXQeH2IsBRsRCoo)sXsBHhlQjB(8rOBGbGoYDH5Xc4xkwAl8yrnzZt1V1am0XtOJnzcDdma0jgLTkEP)6tU3SvOJNqhFMwjJi9bQewS)Oo1sQ48z2ktLmI0hOsgEujY74EYM(y1HzLuGTc6SIvsfNptRmvsb2kOZkwLi0wuABvcpQHWtmkBvWqhYqxuOdXqhBY0)nebD7dDRCoo)snS8ib1gu9u9BnadDidD86JY0kzePpqL(5bPXBNusfNpcSYujfyRGoRyvIqBrPTvjee0TY548lflTfESOMS5ZhRKrK(avAPyPTWJf1KTsQ48rWvMkPaBf0zfRseAlkTTkzePhuFkq)TIHoKHo(vYisFGkTmk1yRLuX5hXktLuGTc6SIvjcTfL2wLWJAi8eJYwfm0Hm0XVsgr6dujYw)nLAp82jLuX5Z8ktLuGTc6SIvjcTfL2wLWJAi8eJYwfm0Hm0Xh6qm0XMm9Fdrq3(q3kNJZVudlpsqTbvpv)wdWqhYqhV(OmTsgr6duPFEqA82jLuXJYBLPsgr6dujK0HWJC)VbMvsb2kOZkwjv8O8RmvYisFGkr26VPu7H3oPskWwbDwXkPIhnALPsgr6duj79ZPtL(oUhHESWvsb2kOZkwjv8OmPYujJi9bQ0SP6BPgwQKcSvqNvSsQ4rz2ktLuGTc6SIvjcTfL2wLw5CCEoQcY6U(5XcaDig6iBgLTIFCuJi9bSa0Hm0X3hrOBGbGoXOSvXl9xFY9MTcD8e6yELmI0hOslJU05dVDsjv8OmTYujJi9bQ0YOuJTwjfyRGoRyLuXJIaRmvsb2kOZkwLi0wuABvklqNrKEq9Pa93kg64j0ff6gyaOJCxyESaEK0HWJC)VbMEQ(TgGHoKHoUJKJ9s)1NCVVHiOlYqhIHUSaDChjhdD7dDKdlq3qOJ7i5ypvzRaOdPd6Yc0rUlmpwaps6q4rU)3atpv)wdWq3(qhFOlYqhYqNrK(aEK0HWJC)VbMEYHfOBGbGoYDH5Xc4rshcpY9)gy6P63Aag6qg64dDdHo2Kj0fzOdXqh5UW8yb8iPdHh5(Fdm9u9BnadDidD8RKrK(avIClQ9WBNusfpkcUYujJi9bQKrjgqFYrPkqQKcSvqNvSskPsJuLC)LjvMko)ktLuGTc6SIvsfpALPskWwbDwXkPIZKktLuGTc6SIvsfNzRmvYisFGkHZ))d8gvPskWwbDwXkPIZ0ktLuGTc6SIvsfhbwzQKrK(avA8K(avsb2kOZkwjvCeCLPskWwbDwXQeH2IsBRsiiOZYQsBr9J0(BHxdWsdic2RaBf0zLmI0hOsgEujY74EYM(y1Hzjv8iwzQKcSvqNvSkrOTO02QKLvL2I6hP93cVgGLgqeSxb2kOZkzePpqLwkwAl8yrnzRKskPswUSD0kL6)EkPKQa]] )

    spec:RegisterOptions( {
        enabled = true,
    
        potion = "potion_of_rising_death",

        buffPadding = 0.25,

        nameplates = false,
        nameplateRange = 8,

        aoe = 3,
    
        damage = true,
        damageExpiration = 3,
    
        package = "Beast Mastery",
    } )
end
