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
            duration = 8,
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


    spec:RegisterPack( "Beast Mastery", 20180902.1908, [[dSKbvaqijfLhHkXMaL6tIGrbk6uGswLKIQxjPAwavUfuKDrQFbQggu4ycQLbuEgOW0KuQRbuvBtsj(MsfgNGKZPujRdkQ5bKCpuv7dvQdkPKwOi5HskCrjfPpkivzKOsQtcKQwjuAMcs5MkvQDkIgQsfTuGQ8urnvrQRkiv8vbPQglqQCwGu2Ru)fWGr5WuTyL8yetwIltzZq1NrvgTs50QSAjfXRvQYSf62GSBi)wXWLKJlivA5K8CKMoX1fy7cIVJkgVsvDErO1JkjZhi2VQUd3P7CXfRtcggHdfg7cdW0H3fg7ag1UZsIvwNRCYEopRZihY6CkZPYZ2TtftLyNR8eJJx60DMobkI15nrQOygoCENSfS0Kbco9GcIUCdIOCCbo9GiWxXzbFH7yQyHaVsn4x0OW3PYap)ku47e8a46aKykGuMtfGD7uXujQPhePZRGlkGEuV6CXfRtcggHdfg7cdW0Hdf4hQAx7otRmsNemWhgDUyusN5YZszovE2UDQyQeFgxhGet9y5YZ2ePIIz4W5DYwWstgi40dki6YniIYXf40dIaFfNf8fUJPIfc8k1GFrJcFNkd88RqHVtWdGRdqIPaszova2TtftLOMEqKhlxEw2QedAzQNbg4EgyyeoupdtpBhygdmE2o39J9XYLNvJnhXZOy(XYLNHPNvRLIvEwnMaKyQNL3g5zY8SIH7br5zorUb9S4rfDNRud(fToZLNLYCQ8SD7uXuj(mUoajM6XYLNTjsffZWHZ7KTGLMmqWPhuq0LBqeLJlWPheb(kol4lChtfle4vQb)Igf(ovg45xHcFNGhaxhGetbKYCQaSBNkMkrn9GipwU8SSvjg0YupdmW9mWWiCOEgME2oWmgy8SDU7h7JLlpRgBoINrX8JLlpdtpRwlfR8SAmbiXuplVnYZK5zfd3dIYZCICd6zXJk6h7JLlpRMUVrceR8SLHpk7zKbA5YZwgVdr1pRwjeRsOpdnimT5ki8G4ZCICdI(Sbftu)yDICdIQRugzGwUWhp609ESorUbr1vkJmqlxQZhUhWdYqIl3GESorUbr1vkJmqlxQZho(mLhRtKBquDLYid0YL68HtdGGgeqLjpwU8SmYROBJ8mLFLNTcWXTYZOIl0NTm8rzpJmqlxE2Y4Di6ZCu5zvkdtvJihI3Zo6ZkdY0pwNi3GO6kLrgOLl15dNI8k62iauXf6J1jYniQUszKbA5sD(WRg5g0J1jYniQUszKbA5sD(WDALreGbhq2maoxS8yFSC5z109nsGyLNzHyQeFMCq2ZKn7zorg1Zo6Z8q8l6ROPFSorUbr57bYaq3g5X6e5geToF4KjajMcGUnYJ1jYniAD(WdOgWjge9X6e5geToF4ltrn1EhIh4oC(KzILHdsVmQCEeGJYLnTYG8dr5ggy8yDICdIwNp8vCMcaEGkrWD48jZeldhKEzu58iahLlBALb5hIYnmW4X6e5geToF4oIyur5raIhJG7W5tMjwgoi9YOY5raokx20kdYpeLByGXJ1jYniAD(WXpLTIZua3HZNmtSmCq6LrLZJaCuUSPvgKFik3WaJhRtKBq068HhpEBcfOMeu4bzi5X6e5geToF4vJCdcCho)vaoUEzu58iahLlB6GkyVcWX1oTYicWGdiBgaNlw0bvpwNi3GO15dF5QLvaOBJaUdNpEqmcOmYMR4zaYbzGIhPOH89bbKkt0ex0RaCCnUYqCvI6GkyxzIM4IEfGJRXvgIRsuRmi)quqXNhPOH89FSorUbrRZhUdafOkMcyWbiQHd9X6e5geToF40QtKdXdGmlL)yDICdIwNpCQ4qvwXa3HZFfGJRxgvopcWr5YMoOceqiZeldhKEzu58iahLlBALb5hIckEKciGiUINjA5GmazakNbQWG)J1jYniAD(WDALreGbhq2maoxS8yDICdIwNp8LrLZJaCuUSbUdNFnBfGJRxgvopcWr5YMoO6X6e5geToF4qbr5OBJaUdNpTYIraXv8mHYnyWgMvMOjUOxb446L5ubGenpetRmi)quqXJu0q((GasLjAIl6vaoUEzovairZdX0LHdcwpwNi3GO15dNSDqUPCa62ipwNi3GO15dFVlgbideKJkpwNi3GO15dVCkdyzovESorUbrRZh(YvlRaq3gbCho)kt0ex0RaCCnUYqCvI6YWbbBYMR4zuaCLtKBqEK7W6qbciIR4zIwoidqgGYzGAxpwNi3GO15dF5kLZZa3HZ3jYfIbyid6mk3HFSorUbrRZhouquo62iG7W5tRSyeqCfptOChg2WSYenXf9kahxVmNkaKO5HyALb5hIckEKIgY3heqQmrtCrVcWX1lZPcajAEiMUmCqW6X6e5geToF4KzPCa62iG7W5dtNixigGHmOZOGcmqaHmtSmCq69UyeGmqqoQOvgKFik34djGQLdYaKbaY3hwWgM4djGIjYqL64djGQvgpdvZHjzMyz4G07DXiazGGCurRmi)qumfgwC7e5gKEVlgbideKJkAYqfqaHmtSmCq69UyeGmqqoQOvgKFik3HRZJuGfSjZeldhKEVlgbideKJkALb5hIYD4hRtKBq068H7kIJmazukdjDoetrVb1jbdJWHcJDeEhAmcx7D1zoUcDiE0oh6xRGxsqFYqpm)SNLEZE2bvnk5z4J6zjumCpikj8mLf6gCkR8m6azpZdKbYfR8mYMJ4zu9Jn0oK9SWy(zHoiAqv1OeR8mNi3GEwcEGma0Trsq)ydTdzplmgy(z1yqHykXkplHkt0GonOP16eEMmplbqtR1j8myc2(Ws)ydTdzplCTG5NvJbfIPeR8SeQmrd60GMwRt4zY8SeanTwNWZGjy7dl9Jn0oK9mWWaZpRgdketjw5zjuzIg0PbnTwNWZK5zjaAAToHNbZW7dl9Jn0oK9mWadZpRgdketjw5zjuzIg0PbnTwNWZK5zjaAAToHNbtW2hw6h7Jf0dvnkXkpdSN5e5g0ZIhvO6hBN9azBuDoFq1OZXJk0oDNlgUheLoDNmCNUZorUb1zpqga62iD2q(kALovlDsW60D2jYnOotMaKyka62iD2q(kALovlDsy0P7StKBqDoGAaNyq0oBiFfTsNQLozT70D2q(kALovNjQtm15DMmtSmCq6LrLZJaCuUSPvgKFi6Z4(zWaJo7e5guNxMIAQ9oeVw6KGFNUZgYxrR0P6mrDIPoVZKzILHdsVmQCEeGJYLnTYG8drFg3pdgy0zNi3G68kotbapqLylDYAPt3zd5ROv6uDMOoXuN3zYmXYWbPxgvopcWr5YMwzq(HOpJ7Nbdm6StKBqD2reJkkpcq8ySLo5o60D2q(kALovNjQtm15DMmtSmCq6LrLZJaCuUSPvgKFi6Z4(zWaJo7e5guNXpLTIZuAPtgQoDNDICdQZXJ3MqbQjbfEqgs6SH8v0kDQw6K7Qt3zd5ROv6uDMOoXuN35vaoUEzu58iahLlB6GQNb7NTcWX1oTYicWGdiBgaNlw0bvD2jYnOoxnYnOw6KHXOt3zd5ROv6uDMOoXuN3z8GyeqzKnxXZaKdYEgOEgpsrd57)mqa5zRaCCnUYqCvI6GQNb7NTcWX14kdXvjQvgKFi6Zaf)NXJu0q((D2jYnOoVC1Yka0TrAPtgoCNUZorUb1zhakqvmfWGdqudhANnKVIwPt1sNmmyD6o7e5guNPvNihIhazwkVZgYxrR0PAPtgggD6oBiFfTsNQZe1jM68oVcWX1lJkNhb4OCzthu9mqa5zKzILHdsVmQCEeGJYLnTYG8drFgOEgps5zGaYZexXZeTCqgGmaLZEgOEwyWVZorUb1zQ4qvwXAPtgU2D6o7e5guNDALreGbhq2maoxS0zd5ROv6uT0jdd(D6oBiFfTsNQZe1jM68oxZE2kahxVmQCEeGJYLnDqvNDICdQZlJkNhb4OCzRLoz4APt3zd5ROv6uDMOoXuN3zALfJaIR4zc9zC)mWEgSFgmF2kahxVmNkaKO5HyALb5hI(mq9mEKIgY3)zGaYZwb446L5ubGenpetxgoONbRo7e5guNHcIYr3gPLoz4D0P7StKBqDMSDqUPCa62iD2q(kALovlDYWHQt3zNi3G68Exmcqgiihv6SH8v0kDQw6KH3vNUZorUb15YPmGL5uPZgYxrR0PAPtcggD6oBiFfTsNQZe1jM68oVcWX14kdXvjQldh0ZG9ZiBUINrbWvorUb5XNX9ZcRd1ZabKNjUINjA5GmazakN9mq9SD1zNi3G68YvlRaq3gPLojyH70D2q(kALovNjQtm15D2jYfIbyid6m6Z4(zH7StKBqDE5kLZZAPtcgyD6oBiFfTsNQZe1jM68otRSyeqCfptOpJ7Nf(zW(zW8zRaCC9YCQaqIMhIPvgKFi6Za1Z4rkAiF)NbcipBfGJRxMtfas08qmDz4GEgS6StKBqDgkikhDBKw6KGbJoDNnKVIwPt1zI6etDENH5ZCICHyagYGoJ(mq9mWEgiG8mYmXYWbP37IraYab5OIwzq(HOpJ7NHpKaQwoidqgaiF)NbRNb7NbZNHpKa6ZW0ZidvEw9NHpKaQwz8m0ZQ5pdMpJmtSmCq69UyeGmqqoQOvgKFi6ZW0Zc)my9mUFMtKBq69UyeGmqqoQOjdvEgiG8mYmXYWbP37IraYab5OIwzq(HOpJ7Nf(z1Fgps5zW6zW(zKzILHdsV3fJaKbcYrfTYG8drFg3plCNDICdQZKzPCa62iT0jbR2D6o7e5guNDfXrgGmkLHKoBiFfTsNQLw6CLYid0YLoDNmCNUZgYxrR0PAPtcwNUZgYxrR0PAPtcJoDNnKVIwPt1sNS2D6o7e5guNPbqqdcOYKoBiFfTsNQLoj43P7SH8v0kDQw6K1sNUZorUb15QrUb1zd5ROv6uT0j3rNUZorUb1zNwzebyWbKndGZflD2q(kALovlT0slT0na]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",
    
        package = "Beast Mastery",
    } )
end
