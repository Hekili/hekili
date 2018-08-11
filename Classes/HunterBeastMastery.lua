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
            
            startsCombat = true,
            texture = 2058007,
            
            recheck = function () return buff.frenzy.remains - gcd, buff.frenzy.remains, full_recharge_time - gcd, target.time_to_die - 9, ( 1.4 - charges_fractional ) * recharge end,
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


    spec:RegisterPack( "Beast Mastery", 20180717.0149, [[dquauaqiLskpsPuTjaXOOk4uesTkLssVsPQzbj6wak2Li)IQQHrvPJjuwgvfpdsyAkLY1auABas8navghGuNdqvRtPeQ5PuX9iu7ds6GkLuTqHQhciPUiGKSrLsiJuPe5Kes0kPkDtLsWovkgkHewQsjXtvXufWEL8xvAWiomPflQhJ0KvYLPSzi(mKA0c60sTALsuVwPsZMk3gODd63kgUqworphQPJ66eSDQI(oaJNQqNNqSEcjnFbA)Q6kwfOolLTAJp(gdO9f4IbCjFJTnGFBaDDyrIS6eP0Dv0wDGkOvN4MI5NSfumBsrQtKkIB0vfOo4rqsT6eYCeEl2VF0nhkKt0b0pUbfCk3dKkve2pUbP(ZUj7pJOaZY80FKCqANH9lkK2wr7f2VOyRC3scq2K34MI57wqXSjfjHBqADYcTJfLWkxNLYwTXhFJb0(cCXaUKVX2gW7dqxhCKrRn(aSOOoldtRtGWg)Kg)eo0EYYqubh)eLY9aFsKs39jiJ8jXnfZpzlOy2KI8KTKaKnj(jn8jXr26P6ejhK2z1z7pjqyJFYYqubh)eLY9aFsKShzZI8exJ5N04NOc8aQCtvNtKNqLMY26jzfBRNmWNiYiiFcnuLkLnz69U9Nik5N04NOprz2aJ4NWZtIKJN9YEIiJWta0C4t0NOuUh4tCnMFchQ8tA8tYdh(eCdg5SNOW1tIKkLBQMDgkFVB)jacBN9ePHfCCdr)Kg(e9jGMcBiAeb3tu46jONz9eCdk4uUhy6jIs(jGQipbo8tKgwWXpPHpHdTNOz84eyZjYtcB0HgMFs0GXD2zpzfHtV3T)KTiZCpbrA2t45j2Qzu(eDPr8tu46jnyKC80EsZpHNNiYiiFYaa(eOzlC69U9NCAqbNY9abQLkc)Kg)e1bqfb)e3m72q0pbzKpriAPSHFIcxpPbJKJNgObz8t45jCO9KLHOco(jkL7b(exJzC69(E3(taQ8OrfyB9KSHms7j0bmR8tYg6gItpzRtPweJFcCGatOkbreCprPCpq8tgOtK07vPCpqCksA0bmRSyeNI399QuUhiofjn6aMvEVy)QaAqdYk3d89QuUhiofjn6aMvEVy)iZSEVkL7bItrsJoGzL3l2pwaeCG3iJFVB)jhOgHdh(jsTxpjlGGyRNGzLXpjBiJ0EcDaZk)KSHUH4NOW1tIKgWenm3q0pPXpznql9Evk3deNIKgDaZkVxSFmuJWHdFXSY43Rs5EG4uK0Odyw59I9hnCpW3Rs5EG4uK0Odyw59I9R4iJY3b5YH2fq7wV3372FcqLhnQaBRNyEAsrEc3G2t4q7jkLh5tA8tup12PzNLEVkL7bIfRc8CXHd)Evk3deVxSF6iaztEXHd)Evk3deVxSFbSDB2aXVxLY9aX7f7pBsSj3THOrzJiMoJBnaGPSH5wDxasLdtsduBigvu477vPCpq8EX(ZUzwxebPiOSretNXTgaWu2WCRUlaPYHjPbQneJkk899QuUhiEVy)kKAywQUlvDou2iIPZ4wdaykByUv3fGu5WK0a1gIrff((Evk3deVxSFKwAz3mlu2iIPZ4wdaykByUv3fGu5WK0a1gIrff((Evk3deVxSFxJoKX3TSWcnOb53Rs5EG49I9hnCpqu2iIZciiPSH5wDxasLdtcrajlGGKuCKr57GC5q7cODRKq07vPCpq8EX(ZQmBRloCyu2iIJmorvoLfqqsisdkQIKeIasKXjQYPSacscrAqrvKK0a1gI3rmA6kbQE89QuUhiEVy)6fuqUm5DqUu5aa)Evk3deVxSFCuZCdrFPtwQVxLY9aX7f7hZkyKTmu2iIZciiPSH5wDxasLdtcrbdsNXTgaWu2WCRUlaPYHjPbQneVdA6kyqwLOnoXnOD55UABNya77vPCpq8EX(vCKr57GC5q7cODR3Rs5EG49I9Nnm3Q7cqQCikBeXBTSacskByUv3fGu5WKq07vPCpq8EX(bfCCJdhgLnIyCK5CxwLOngJQpaXdrgNOkNYciiPSPy(sDM6PLKgO2q8oOPReO6XGbJmorvoLfqqsztX8L6m1tlTgaqr)Evk3deVxSFAydQMuV4WHFVkL7bI3l2)UTZDPdiOcxVxLY9aX7f7F1s7MnfZVxLY9aX7f7pRYSTU4WHrzJioY4ev5uwabjHinOOksAnaGaHgQs0g(Iivk3duDOglTTGbreCUR0OHQeTD5g02bnDLavpgmiRs0gN4g0U8CxTTdW)Evk3deVxS)SkLkA79QuUhiEVy)GcoUXHdJYgrmoYCUlRs0gJrngq8qKXjQYPSacskBkMVuNPEAjPbQneVdA6kbQEmyWiJtuLtzbeKu2umFPot90sRbau0VxLY9aX7f7NozPEXHdJYgrShuk3EAxdAGTH3XNGbPZ4wdayA325U0beuHRK0a1gIrfzOc4e3G2LNlO6rrdepKfqqszdZT6UaKkhMeIaIs52t7AqdSnmQXcgKoJBnaGPDBN7shqqfUssduBig1y7rtxaHoJBnaGPSH5wDxasLdtsduBigvKHkGtCdAxEUGQhdgezOcyGHoyEpYqfWjPH2GBvpqNXTgaW0UTZDPdiOcxjPbQnedmXenQkL7bM2TDUlDabv4krhml664PjX9aRn(4BmG2xGsmGp5JpalkQdavcBiACDQJRXmUcuNLHOcoUcuBIvbQJs5EG1rf45IdhUoguZoBvXlU24tfOokL7bwh6iaztEXHdxhdQzNTQ4fxBqrfOokL7bwhbSDB2aX1XGA2zRkEX1MTvbQJb1SZwv86qLnBYwRdDg3AaatzdZT6UaKkhMKgO2q8tq9jOW36OuUhyDYMeBYDBi6IRnaBfOoguZoBvXRdv2SjBTo0zCRbamLnm3Q7cqQCysAGAdXpb1NGcFRJs5EG1j7MzDreKIuCTbOubQJb1SZwv86qLnBYwRdDg3AaatzdZT6UaKkhMKgO2q8tq9jOW36OuUhyDui1WSuDxQ6CfxBaUkqDmOMD2QIxhQSzt2ADOZ4wdaykByUv3fGu5WK0a1gIFcQpbf(whLY9aRdslTSBMvX1gGUcuhLY9aRJRrhY47wwyHg0GCDmOMD2QIxCTb4Ra1XGA2zRkEDOYMnzR1jlGGKYgMB1Dbivomje9eG8KSacssXrgLVdYLdTlG2Tscr1rPCpW6enCpWIRnX8TcuhdQzNTQ41HkB2KTwNSacscrAqrvKKq0taYtYciijePbfvrssduBi(j7i(jOPR6OuUhyDYQmBRloC4IRnXIvbQJs5EG1rVGcYLjVdYLkha46yqn7SvfV4AtmFQa1rPCpW6GJAMBi6lDYsToguZoBvXlU2edfvG6yqn7SvfVouzZMS16KfqqszdZT6UaKkhMeIEsWGpHoJBnaGPSH5wDxasLdtsduBi(j78e001tcg8jSkrBCIBq7YZD12t25jXa26OuUhyDWScgzlR4AtSTvbQJs5EG1rXrgLVdYLdTlG2TQJb1SZwv8IRnXa2kqDmOMD2QIxhQSzt2AD2ApjlGGKYgMB1DbivomjevhLY9aRt2WCRUlaPYHfxBIbuQa1XGA2zRkEDOYMnzR1bhzo3LvjAJXpb1N4ZtaYt8WtYciiPSPy(sDM6PLKgO2q8t25jOPRNem4tYciiPSPy(sDM6PLwda4teDDuk3dSoGcoUXHdxCTjgWvbQJs5EG1Hg2GQj1loC46yqn7SvfV4AtmGUcuhLY9aRZUTZDPdiOcx1XGA2zRkEX1MyaFfOokL7bwNvlTB2umxhdQzNTQ4fxB8X3kqDmOMD2QIxhQSzt2ADYciijePbfvrsRba8ja5j0qvI2WxePs5EGQ7jO(KyPT9KGbFcIGZDLgnuLOTl3G2t25jOPRNem4tyvI24e3G2LN7QTNSZta(6OuUhyDYQmBRloC4IRn(eRcuhLY9aRtwLsfTvhdQzNTQ4fxB8XNkqDmOMD2QIxhQSzt2ADWrMZDzvI2y8tq9jXEcqEIhEswabjLnfZxQZupTK0a1gIFYopbnD9KGbFswabjLnfZxQZupT0AaaFIORJs5EG1buWXnoC4IRn(GIkqDmOMD2QIxhQSzt2AD8Wtuk3EAxdAGTHFYopXNNem4tOZ4wdayA325U0beuHRK0a1gIFcQpbzOc4e3G2LNlO6XNi6NaKN4HNKfqqszdZT6UaKkhMeIEcqEIs52t7AqdSn8tq9jXEsWGpHoJBnaGPDBN7shqqfUssduBi(jO(Kypz)tqtxpbipHoJBnaGPSH5wDxasLdtsduBi(jO(eKHkGtCdAxEUGQhFsWGpbzOc4NampHoy(j7FcYqfWjPH2GpzR(ep8e6mU1aaM2TDUlDabv4kjnqTH4Nampj2te9tq9jkL7bM2TDUlDabv4krhm)erxhLY9aRdDYs9IdhU4IRtK0Odyw5kqTjwfOoguZoBvXlU24tfOoguZoBvXlU2GIkqDmOMD2QIxCTzBvG6OuUhyDWcGGd8gzCDmOMD2QIxCTbyRa1XGA2zRkEX1gGsfOokL7bwNOH7bwhdQzNTQ4fxBaUkqDuk3dSokoYO8DqUCODb0UvDmOMD2QIxCXfxhvGdhzDefcqn0CwXfxfa]] )

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
