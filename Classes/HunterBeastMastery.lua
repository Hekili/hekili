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


    spec:RegisterPack( "Beast Mastery", 20180918.1255, [[dS0dwaqivkPEeQcBcc6tckJcjPtHKyvQusELuQzjL0Tqs1UO0VGOHjiDmKyzqINbj10ePY1ee2MGO(MkLQXbj5CsjSoufnpiW9qk7dvPdcHkluK8qPeDrvkrFuKQIrksvojeQALqQzkiYnvPs7uenuvQyPiP4PIAQIWvfPQYxfPQQXQsPCwiu2RK)QIbtXHPAXQYJrmzP6YK2mQ8zuvJwkoTsRwLs41Qu1Sf62QQDd63kgUk54IuvA5O8COMoX1fy7cQ(os14HqoVkfRhjLMViL9dCrPsu5UlALeLqPGQqBbfuzPGsisxiOuz5MlTYxo5ENVwzO)1kNsDSam31XIYUPYx(nXX7vIkJNagrRCJixyEIej)vAcEwY8rI3Fq0LDGeMZjiX7NG8fNhYhNt9UgoYl2WTrfJ8omLA8TJrEhQ5KEbqrzNuQJLZDDSOSBS49tQ8lyJcIhwVk3DrRKOekfufAlOGklfucr6shQRm(sjvsucbQRCxXKkZdGjL6ybyURJfLDdWKEbqrza08ayAe5cZtKi5VstWZsMps8(dIUSdKWCobjE)eKV48q(4CQ31WrEXgUnQyK3HPuJVDmY7qnN0lakk7KsDSCURJfLDJfVFcanpaMSEj6)PmGHcQAfyqjukOcyOoWqbfEgI0bm35Ua0a08ayAzJd5RyEcqZdGH6adIR31oW0YjakkdyYnJamYamDLZdIcW4ezhiWexSyR8fB42OwzEamPuhlaZDDSOSBaM0lakkdGMhatJixyEIej)vAcEwY8rI3Fq0LDGeMZjiX7NG8fNhYhNt9UgoYl2WTrfJ8omLA8TJrEhQ5KEbqrzNuQJLZDDSOSBS49taO5bWK1lr)pLbmuqvRadkHsbvad1bgkOWZqKoG5o3fGgGMhatlBCiFfZtaAEamuhyqC9U2bMwobqrzatUzeGrgGPRCEquagNi7abM4IflananpaMBjIusGODG5PCdtbgY8FUampL)cXwGbXri6LGbg4aPEJZ(CbrGXjYoqmWmW4nwaANi7aX2lMsM)ZfACrhFpaTtKDGy7ftjZ)5sBAi9a(FfkUSdeG2jYoqS9IPK5)CPnnKCZ0bODISdeBVykz(pxAtdjo4)h45sfaAEamzOFHBgbyy(2bMxahN2bgS4cgyEk3WuGHm)NlaZt5VqmW4WoWCXuQFnISq(aZIbM(avlaTtKDGy7ftjZ)5sBAiXq)c3mYblUGbODISdeBVykz(pxAtd51i7abODISdeBVykz(pxAtdPJVuICgUJ0Oh6BSdqdqZdG5wIiLeiAhy0Wv2naJSFfyKgfyCImmGzXaJhUVr)fvlaTtKDGyAEGmhCZia0or2bIBtdjzcGIYo4MraODISde3MgYaSEwr)yaANi7aXTPH8PmSYUFH8BD5OrMj2h6q7tXY6XdDMlnwM(9fI5f1Hcq7ezhiUnnKV4m9dxa7MwxoAKzI9Ho0(uSSE8qN5sJLPFFHyErDOa0or2bIBtdPdjkwyE8q8yS1LJgzMyFOdTpflRhp0zU0yz63xiMxuhkaTtKDG420qYTm9fNP36YrJmtSp0H2NIL1Jh6mxASm97leZlQdfG2jYoqCBAiJl)gbFUfbD(Ffka0or2bIBtd51i7aBD5O9c44SpflRhp0zU0ydUq4lGJZ64lLiNH7in6H(g72GlaANi7aXTPH85SN2p4MrAD5ODPIL4I9fWXz5ykKAVXgCHWlvSexSVaoolhtHu7nwM(9fIran(KU97icG2jYoqCBAi9ZpG1v2z4oe2qh36YrZjYgUEuO(xftJcaTtKDG420q(C2t7hCZiTUC04cIXdtjnoJVEK9RiGpPB)oIqizMyFOdTpflRhp0zU0yz63xigG2jYoqCBAiXxRilK)HmpMdq7ezhiUnnKyX)xAxBD5O9c44SpflRhp0zU0ydUslnYmX(qhAFkwwpEOZCPXY0VVqmc4t6PLM4m(QyL9Rhzo9vraLqaq7ezhiUnnKo(sjYz4osJEOVXoaTtKDG420q(dIYIBgP1LJg(sJXJ4m(QG5ffes1lvSexSVaoo7tDSCir1dxTm97leJa(KU97iIka0or2bIBtd5tXY6XdDMlnTUC0U1Vaoo7tXY6XdDMln2GlaANi7aXTPHK0SFxz(b3msRlhn8LgJhXz8vbZlfaANi7aXTPH8heLf3msRlhn8LgJhXz8vbZlfes1lvSexSVaoo7tDSCir1dxTm97leJa(KU97iIka0or2bIBtd59BmEiZ)7WoaTtKDG420qsA2VRm)GBgbG2jYoqCBAi9ZpG1v2z4oe2qhdq7ezhiUnnK9LPNN6ybG2jYoqCBAiFo7P9dUzKwxoAxQyjUyFbCCwoMcP2BS9HoeHKgNXxXhoMtKDGEKxkwuLwAIZ4RIv2VEK50xfbTaG2jYoqCBAiFoJ581wxoAor2W1Jc1)QyEPaq7ezhiUnnKK5X8dUzKwxoAu1jYgUEuO(xfJauslnYmX(qhAVFJXdz(Fh2Tm97leZl3qcWwz)6rMZ3revqiv5gsaM6KblT5gsa2Yu(k8wrvYmX(qhAVFJXdz(Fh2Tm97letDkuHxNi7aT3VX4Hm)Vd7wYGL0sJmtSp0H273y8qM)3HDlt)(cX8sPnFsNkiKmtSp0H273y8qM)3HDlt)(cX8sbG2jYoqCBAiDgXH6rggtHsLdxz4DGvsucLcQcTfHIILslcfvvMUZGlKpUYP)ioQjjIpz6dpbgGjrJcm7)AycWWnmGjSUY5brjmGHPPVblt7adE(kW4bY8Dr7adPXH8vSfGoKwOcmu4jWK(bXbxxdt0oW4ezhiWeMhiZb3msywa6qAHkWqjuEcmTCGHRmr7atyxQyVnlIzT2WagzaMWqmR1ggWqvuqevSa0H0cvGHsiZtGPLdmCLjAhyc7sf7TzrmR1ggWidWegIzT2WagQsbruXcqhslubgkTGNatlhy4kt0oWe2Lk2BZIywRnmGrgGjmeZATHbmuLcIOIfGoKwOcmOKoEcmTCGHRmr7atyxQyVnlIzT2WagzaMWqmR1ggWqvkiIkwaAaAe))AyI2bguagNi7abM4IfSfGUYEG0mSkN3FlRCCXcUsu5UY5brPsujPujQStKDGv2dK5GBgPYk0FrTxPkPsIsLOYor2bwzYeafLDWnJuzf6VO2RuLujrDLOYor2bw5aSEwr)4kRq)f1ELQKkz6QevwH(lQ9kvLjSvu26vMmtSp0H2NIL1Jh6mxASm97ledm8cmOo0k7ezhyLFkdRS7xi)sQKHOsuzf6VO2RuvMWwrzRxzYmX(qhAFkwwpEOZCPXY0VVqmWWlWG6qRStKDGv(fNPF4cy3usLmKRevwH(lQ9kvLjSvu26vMmtSp0H2NIL1Jh6mxASm97ledm8cmOo0k7ezhyLDirXcZJhIhJLujV9krLvO)IAVsvzcBfLTELjZe7dDO9Pyz94HoZLglt)(cXadVadQdTYor2bwzULPV4m9sQKOQsuzNi7aRCC53i4ZTiOZ)RqPYk0FrTxPkPs2IkrLvO)IAVsvzcBfLTELFbCC2NIL1Jh6mxASbxadcbMxahN1Xxkrod3rA0d9n2Tbxv2jYoWkFnYoWsQKucTsuzf6VO2RuvMWwrzRx5xahNLJPqQ9gBWfWGqG5fWXz5ykKAVXY0VVqmWGaAadFs3(DevzNi7aR8ZzpTFWnJusLKcLkrLvO)IAVsvzcBfLTELDISHRhfQ)vXadnGHsLDISdSY(5hW6k7mChcBOJlPssbLkrLvO)IAVsvzcBfLTEL5cIXdtjnoJVEK9Radcag(KU97icyqiWqMj2h6q7tXY6XdDMlnwM(9fIRStKDGv(5SN2p4MrkPssb1vIk7ezhyLXxRilK)HmpMxzf6VO2RuLujPKUkrLvO)IAVsvzcBfLTELFbCC2NIL1Jh6mxASbxatAPbmKzI9Ho0(uSSE8qN5sJLPFFHyGbbadFshyslnGrCgFvSY(1JmN(QadcagkHOYor2bwzS4)lTRLujPeIkrLDISdSYo(sjYz4osJEOVXELvO)IAVsvsLKsixjQSc9xu7vQktyROS1Rm(sJXJ4m(QGbgEbguagecmufyEbCC2N6y5qIQhUAz63xigyqaWWN0TFhradvQStKDGv(heLf3msjvsk3ELOYk0FrTxPQmHTIYwVY3AG5fWXzFkwwpEOZCPXgCvzNi7aR8tXY6XdDMlnLujPGQkrLvO)IAVsvzcBfLTELXxAmEeNXxfmWWlWqPYor2bwzsZ(DL5hCZiLujP0IkrLvO)IAVsvzcBfLTELXxAmEeNXxfmWWlWqbyqiWqvG5fWXzFQJLdjQE4QLPFFHyGbbadFs3(DebmuPYor2bw5FquwCZiLujrj0krLDISdSY3VX4Hm)Vd7vwH(lQ9kvjvsuOujQStKDGvM0SFxz(b3msLvO)IAVsvsLefuQev2jYoWk7NFaRRSZWDiSHoUYk0FrTxPkPsIcQRev2jYoWk3xMEEQJLkRq)f1ELQKkjkPRsuzf6VO2RuvMWwrzRx5xahNLJPqQ9gBFOdbgecmKgNXxXhoMtKDGEey4fyOyrfWKwAaJ4m(QyL9Rhzo9vbgeamTOYor2bw5NZEA)GBgPKkjkHOsuzf6VO2RuvMWwrzRxzNiB46rH6FvmWWlWqPYor2bw5NZyoFTKkjkHCLOYk0FrTxPQmHTIYwVYufyCISHRhfQ)vXadcaguaM0sdyiZe7dDO9(ngpK5)Dy3Y0VVqmWWlWWnKaSv2VEK58DebmubyqiWqvGHBibyGH6adzWcW0gy4gsa2Yu(keyUvadvbgYmX(qhAVFJXdz(Fh2Tm97ledmuhyOamuby4fyCISd0E)gJhY8)oSBjdwaM0sdyiZe7dDO9(ngpK5)Dy3Y0VVqmWWlWqbyAdm8jDGHkadcbgYmX(qhAVFJXdz(Fh2Tm97ledm8cmuQStKDGvMmpMFWnJusLeLBVsuzNi7aRSZioupYWykuQSc9xu7vQskPYxmLm)NlvIkjLkrLvO)IAVsvsLeLkrLvO)IAVsvsLe1vIkRq)f1ELQKkz6Qev2jYoWkJd()bEUuPYk0FrTxPkPsgIkrLvO)IAVsvsLmKRev2jYoWkFnYoWkRq)f1ELQKk5TxjQStKDGv2Xxkrod3rA0d9n2RSc9xu7vQskPKskPka]] )

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
