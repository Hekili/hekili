-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- needed for Frenzy.
local FindUnitBuffByID = ns.FindUnitBuffByID


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 253, true )

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

        dire_beast_basilisk = {
            id = 209967,
            duration = 30,
            max_stack = 1,
        },

        dire_beast_hawk = {
            id = 208684,
            duration = 3600,
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


        -- PvP Talents
        dire_beast_hawk = {
            id = 208684,
            duration = 3600,
            max_stack = 1,
        },

        hiexplosive_trap = {
            id = 236777,
            duration = 0.1,
            max_stack = 1,
        },

        interlope = {
            id = 248518,
            duration = 45,
            max_stack = 1,
        },

        roar_of_sacrifice = {
            id = 53480,
            duration = 12,
            max_stack = 1,
        },

        scorpid_sting = {
            id = 202900,
            duration = 8,
            type = "Poison",
            max_stack = 1,
        },

        spider_sting = {
            id = 202914,
            duration = 4,
            type = "Poison",
            max_stack = 1,
        },

        the_beast_within = {
            id = 212704,
            duration = 15,
            max_stack = 1,
        },

        viper_sting = {
            id = 202797,
            duration = 6,
            type = "Poison",
            max_stack = 1,
        },

        wild_protector = {
            id = 204205,
            duration = 3600,
            max_stack = 1,
        },


        -- Azerite Powers
        primal_instincts = {
            id = 279810,
            duration = 20,
            max_stack = 1
        }
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
            cooldown = function () return pvptalent.hunting_pack.enabled and 90 or 180 end,
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

                if azerite.primal_instincts.enabled then gainCharges( "barbed_shot", 1 ) end
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
                if pvptalent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
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
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

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
        

        dire_beast_basilisk = {
            id = 205691,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 60,
            spendType = "focus",
            
            toggle = "cooldowns",
            pvptalent = "dire_beast_basilisk",

            startsCombat = true,
            texture = 1412204,
            
            handler = function ()
                applyDebuff( "target", "dire_beast_basilisk" )
            end,
        },
        

        dire_beast_hawk = {
            id = 208652,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 30,
            spendType = "focus",

            pvptalent = "dire_beast_hawk",
            
            startsCombat = true,
            texture = 612363,
            
            handler = function ()
                applyDebuff( "target", "dire_beast_hawk" )
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
        

        hiexplosive_trap = {
            id = 236776,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            pvptalent = "hiexplosive_trap",
            
            startsCombat = false,
            texture = 135826,
            
            handler = function ()
            end,
        },
        

        interlope = {
            id = 248518,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "interlope",
            
            startsCombat = false,
            texture = 132180,
            
            handler = function ()
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

            nopvptalent = "interlope",
            
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
        

        roar_of_sacrifice = {
            id = 53480,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            pvptalent = "roar_of_sacrifice",
            
            startsCombat = false,
            texture = 464604,
            
            handler = function ()
                applyBuff( "roar_of_sacrifice" )
            end,
        },
        

        scorpid_sting = {
            id = 202900,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            pvptalent = "scorpid_sting",
            
            startsCombat = true,
            texture = 132169,
            
            handler = function ()
                applyDebuff( "target", "scorpid_sting" )
                setCooldown( "spider_sting", max( 8, cooldown.spider_sting.remains ) )
                setCooldown( "viper_sting", max( 8, cooldown.viper_sting.remains ) )
            end,
        },
        

        spider_sting = {
            id = 202914,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "spider_sting",
            
            startsCombat = true,
            texture = 1412206,
            
            handler = function ()
                applyDebuff( "target", "spider_sting" )
                setCooldown( "scorpid_sting", max( 8, cooldown.scorpid_sting.remains ) )
                setCooldown( "viper_sting", max( 8, cooldown.viper_sting.remains ) )
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

        viper_sting = {
            id = 202797,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "viper_sting",
            
            startsCombat = true,
            texture = 236200,
            
            handler = function ()
                applyDebuff( "target", "spider_sting" )
                setCooldown( "scorpid_sting", max( 8, cooldown.scorpid_sting.remains ) )
                setCooldown( "viper_sting", max( 8, cooldown.viper_sting.remains ) )
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


    spec:RegisterPack( "Beast Mastery", 20190201.2258, [[d004LaqikP4rsc2KiQpjP0Our1PurzvusL6vqjZsfYTqvQDH0VKqddvrhtsAzOQ6zOkmnkPQRjjABsQKVrjvmojH6CqP06KuX8OKCpryFsQ6GqPQfcfEOkuMOkuPlkjeTrjHWhHsHrcfvDsOOYkPeZekkDtOOyNQidvsLAPusPNQQMQk4QusL8vOu0yvHQoluQSxq)vudgYHfwSQ8yetMQUmXMvPplbJwIoTuRwsi9AOiZMk3gQ2nWVvA4I0XvHkwofphLPt66uQTlI8DuX4rvY5rvz9skMpQ0(vmSk8a87dvGN4NNvXwEYppRs5N)kTovwxWVYxQa)Pbbtrbb(bbUa)yibtheMjyQy4d(td(CB4HhGF2ABic8xQAkRoflwO1s7hLS4fznUTl0EbetC1ISgNu852xX3n4TxsQyQzVTtyfRBJyTr7zfRBRnJ5TbQyYyibtZyMGPIHpkRXjW)ZUDkMdaFWVpubEIFEwfB5j)8SkLF(TERtL1f8h2A5AG)FJFm4VS9EbaFWVxye4Vcdcdjy6GWmbtfdFdcZBduXmwQWGkvnLvNIfl0AP9Jsw8ISg32fAVaIjUArwJtk(C7R47g82ljvm1S32jSI1TrS2O9SI1T1MX82avmzmKGPzmtWuXWhL14KXsfgufH8m2HHVbv9ObXppRITdI3dIF(RJ1x5yzSuHbDSYauqy1zSuHbX7bH9EV4h0XwBGkMb9lxDq6oiVCdBNoOGO9cgKRzkDSuHbX7bzDXKbPnUK1n7BzqNNeJoinmfeLQnUK1n7B5SbP7GcG2KonuzqcWpO9oibqwBGkgk87AMYGhGFVCdBNcpapvfEa(dI2la(jRnqftMvUk8lG45epedOcpXp8a8heTxa8BZKCRcod(fq8CIhIbuHN4b8a8lG45eped4piAVa4NeoxoiAVGSRzk87AMMbbUa)epdQWtwp8a8lG45eped4NyAvmDa)br7KKSae8wydYQbXp8heTxa8tcNlheTxq21mf(DntZGaxGFMcv4PkHhGFbepN4Hya)etRIPd4piANKKfGG3cBq1pOQWFq0EbWpjCUCq0EbzxZu431mndcCb(jojssGkuH)uJqw8xOWdWtvHhGFbepN4Hyav4j(HhGFbepN4Hyav4jEapa)ciEoXdXaQWtwp8a8heTxa8ZSXXxqovu4xaXZjEigqfEQs4b4xaXZjEigqfEQUGhG)GO9cG)0v7fa)ciEoXdXaQWtwh4b4xaXZjEigWFQribtZAJlWFvAv4piAVa4pyPcrZ7nRLsMt78WpX0Qy6a(TMbf1iMwfAQPXdxUbmTbeLrfq8CIhQWtvm8a8lG45eped4p1iKGPzTXf4VkTs4piAVa4)jmTdxMJj0s4NyAvmDa)rnIPvHMAA8WLBatBarzubepN4HkuHFINbpapvfEa(fq8CIhIb8tmTkMoGFYUo)YbqFct7WL5ycTKAe8ObSbv)G4bpH)GO9cG)aqeMAcxMeohuHN4hEa(fq8CIhIb8tmTkMoGFYUo)YbqFct7WL5ycTKAe8ObSbv)G4bpH)GO9cG)BBKNBxpuHN4b8a8lG45eped4NyAvmDa)p77LgSuHO59M1sjZPDEQD6GsEqNpiTXLSUzFldQ(br215xoa6tmmXGPguG6TnH2lyqyniVTj0EbdIl3bD(G0WuquAPeoTKMs0bz1G4rLdIl3bzndsdNaukMANtm5gW0gquQaINt8d6SbD2G4YDqAJlzDZ(wgKvdQkpG)GO9cG)NyyIbtnOauHNSE4b4xaXZjEigWpX0Qy6a(F23lnyPcrZ7nRLsMt78u70bL8GoFqAJlzDZ(wgu9dISRZVCa0NBxF(AB4J6TnH2lyqyniVTj0EbdIl3bD(G0WuquAPeoTKMs0bz1G4rLdIl3bzndsdNaukMANtm5gW0gquQaINt8d6SbD2G4YDqAJlzDZ(wgKvdQADb)br7fa)p3U(812WhuHNQeEa(fq8CIhIb8tmTkMoG)N99sVgbudFu70bL8GE23l9Aeqn8rncE0a2GQFqfiEkEWRbXL7GSMb9SVx61iGA4JANc)br7fa)UUqPYYvuBFbCbOqfEQUGhGFbepN4Hya)etRIPd4)zFV0NW0oCzoMqlP2Pdk5b9SVxAWsfIM3BwlLmN25P2Pdk5bD(G0WuquAPeoTKMs0bz1G4rLdIl3bzndsdNaukMANtm5gW0gquQaINt8d6SbXL7G0gxY6M9TmiRge)vc)br7fa)PR2laQqf(zk8a8uv4b4xaXZjEigWpX0Qy6a(F23l9Aeqn8rTthuYd6zFV0Rra1Wh1i4rdydYQedQaXtXdEniUCh0125YgHugMcswBCzqwnOcepfp41GsEqKDD(LdG(eM2HlZXeAj1i4rdydIl3bf1iMwfAQPXdxUbmTbeLrfq8CIFqjpiYUo)YbqdwQq08EZAPK50op1i4rdydYQbvG4H)GO9cG)xyEIpZkxfQWt8dpa)br7fa)blviAEVzTuYCANh(fq8CIhIbuHN4b8a8heTxa8hzCBJxm59MjMLdd(fq8CIhIbuHNSE4b4xaXZjEigWpX0Qy6a(F23lnyPcrZ7nRLsMt78u70bL8GE23l9jmTdxMJj0sQD6G4YDqAJlzDZ(wgKvdQALWFq0EbWptd8uXlqfEQs4b4xaXZjEigWpX0Qy6a(j768lhanyPcrZ7nRLsMt78uJGhnGnO6he)8CqC5oiTXLSUzFldYQbvTs4piAVa4)jmTdxMJj0sOcpvxWdWFq0EbWpMANltwC8a4HFbepN4Hyav4jRd8a8heTxa8tkB8qmrMvUk8lG45epedOcpvXWdWFq0EbWVVns(jbtHFbepN4Hyav4jSfEa(fq8CIhIb8tmTkMoG)N99sVgbudFu)YbmOKh05dIugMcclFnbr7feUbv)GQsR4bXL7GE23l9jmTdxMJj0sQD6GoBqC5oiYUo)YbqdwQq08EZAPK50op1i4rdydYQb9SVx61iGA4J6TnH2lyq8Eqfi(bL8GIAetRcn104Hl3aM2aIYOciEoXpiUChK24sw3SVLbz1GWw4piAVa4)fMN4ZSYvHk8uvEcpa)br7fa)VWyIcc8lG45epedOcpvTk8a8lG45eped4NyAvmDa)NpO7sSzdI3dISmDqynO7sSzuJuqadY6EqNpiYUo)YbqXu7CzYIJhap1i4rdydI3dQ6GoBq1pOGO9cOyQDUmzXXdGNswMoiUChezxNF5aOyQDUmzXXdGNAe8ObSbv)GQoiSgubIFqNnOKhezxNF5aOyQDUmzXXdGNAe8ObSbv)GQc)br7fa)K9zImRCvOcpvLF4b4piAVa4NL2Q2GczY(mb8lG45epedOcv4N4KijbEaEQk8a8lG45eped4NyAvmDa)p77LEncOg(O2Pdk5b9SVx61iGA4JAe8ObSbzvIbvG4P4bVG)GO9cG)xyEIpZkxfQWt8dpa)ciEoXdXa(jMwfthWFbINIh8Aq8Eqp77L(KGPzItIKeQrWJgWgu9dINu(Re(dI2la(XTDAZkxfQWt8aEa(fq8CIhIb8tmTkMoG)RTZLncPmmfKS24YGSAqfiEkEWRbL8Gi768lha9jmTdxMJj0sQrWJgWG)GO9cG)xyEIpZkxfQWtwp8a8heTxa8hSuHO59M1sjZPDE4xaXZjEigqfEQs4b4xaXZjEigWpX0Qy6a(F23lnyPcrZ7nRLsMt78u70bL8GE23l9jmTdxMJj0sQD6G4YDqAJlzDZ(wgKvdQALWFq0EbWptd8uXlqfEQUGhGFbepN4Hya)etRIPd4NSRZVCa0GLkenV3SwkzoTZtncE0a2GQFq8ZZbXL7G0gxY6M9TmiRgu1kH)GO9cG)NW0oCzoMqlHk8K1bEa(dI2la(jLnEiMiZkxf(fq8CIhIbuHNQy4b4piAVa4pY42gVyY7ntmlhg8lG45epedOcpHTWdWFq0EbW)lmMOGa)ciEoXdXaQWtv5j8a8heTxa8JP25YKfhpaE4xaXZjEigqfEQAv4b4piAVa433gj)KGPWVaINt8qmGk8uv(HhGFbepN4Hya)etRIPd4)zFV0Rra1Wh1VCadk5bD(GiLHPGWYxtq0EbHBq1pOQ0kEqC5oON99sFct7WL5ycTKANoOZgexUdISRZVCa0GLkenV3SwkzoTZtncE0a2GSAqp77LEncOg(OEBtO9cgeVhubIFqjpOOgX0QqtnnE4YnGPnGOmQaINt8dIl3bPnUK1n7BzqwniSf(dI2la(FH5j(mRCvOcpvLhWdWVaINt8qmGFIPvX0b8t215xoakMANltwC8a4PgbpAaBq1pO7sSzuTXLSUz8GxWFq0EbWpzFMiZkxfQWtvTE4b4piAVa4NL2Q2GczY(mb8lG45epedOcvOc)jjgwVa4j(5z1kUk)vRs5j2YJQWpNWaAqbg8JnXER9eM7e2OodAqhkLb14PRrh0DndQwINv7GmYXXUnIFqSfxguyRlEOIFqKYauqy0XcMTbYGQSod6ylijXOIFq1Mkk94PyhLsRDq6oOAXokLw7GoNh86m6yzSGnXER9eM7e2OodAqhkLb14PRrh0DndQwMw7GmYXXUnIFqSfxguyRlEOIFqKYauqy0XcMTbYGQwNbDSfKKyuXpOAtfLE8uSJsP1oiDhuTyhLsRDqNZpVoJowWSnqge2wNbDSfKKyuXpOAtfLE8uSJsP1oiDhuTyhLsRDqNZpVoJowglytS3ApH5oHnQZGg0HszqnE6A0bDxZGQL4KijP2bzKJJDBe)GylUmOWwx8qf)GiLbOGWOJfmBdKbvTod6ylijXOIFq1Mkk94PyhLsRDq6oOAXokLw7GoNFEDgDSGzBGmi(RZGo2cssmQ4huTPIspEk2rP0AhKUdQwSJsP1oOZRYRZOJfmBdKbvL)6mOJTGKeJk(bvBQO0JNIDukT2bP7GQf7OuATd6C(51z0XYybZHNUgv8dQYbfeTxWGCntz0Xc8Zsfc8e)vYd4p1S32jWFfgegsW0bHzcMkg(geM3gOIzSuHbvQAkRoflwO1s7hLS4fznUTl0EbetC1ISgNu852xX3n4TxsQyQzVTtyfRBJyTr7zfRBRnJ5TbQyYyibtZyMGPIHpkRXjJLkmOkc5zSddFdQ6rdIFEwfBheVhe)8xhRVYXYyPcd6yLbOGWQZyPcdI3dc79EXpOJT2avmd6xU6G0DqE5g2oDqbr7fmixZu6yPcdI3dY6IjdsBCjRB23YGopjgDqAykikvBCjRB23Yzds3bfaTjDAOYGeGFq7DqcGS2avm0XYyPcdQIKxcXwf)GEYDnYGil(l0b9KcnGrhe2tisQYgeyb8Umm4xB3GcI2lGnOf44JowcI2lGrtnczXFHM46cgMglbr7fWOPgHS4VqXkrXWUaUa0q7fmwcI2lGrtnczXFHIvII3D9JLGO9cy0uJqw8xOyLOiZghFb5urhlvyqFqKYkxDqMO9d6zFVIFqmnu2GEYDnYGil(l0b9KcnGnOa4huQr4D6QAdkmOMni)ce6yjiAVagn1iKf)fkwjkYarkRC1mtdLnwcI2lGrtnczXFHIvIIPR2lySuHbH9(kQntzdslLb5TnH2lyqbWpiYUo)YbmO9oiSNLkeDq7DqAPmiSz78dka(bv3MgpCdcZbyAdikBqp(gKwkdYBBcTxWG27GcWGSbLbtf)GWgh74oioLcyqAPWxTgzq2mXpOuJqw8xO0bH9SbH9RInhuzWgumOQuEWge24yh3bfa)GI7vikBqTYe3DqAzZguZguvAvgDSeeTxaJMAeYI)cfRefdwQq08EZAPK50o)rPgHemnRnUKOkT6r9nH1e1iMwfAQPXdxUbmTbeLrfq8CIFSuHbH9(kQntzdslLb5TnH2lyqbWpiYUo)YbmO9oimeM2HBqyttOLdka(bH5JAKbT3bzTrbzqp(gKwkdYBBcTxWG27GcWGSbLbtf)GWgh74oioLcyqAPWxTgzq2mXpOuJqw8xO0Xsq0EbmAQril(luSsu8jmTdxMJj0YJsncjyAwBCjrvALh13ernIPvHMAA8WLBatBarzubepN4hlJLkmOksEjeBv8dsssm8niTXLbPLYGcIUMb1SbfjfTlEoHowcI2lGLGS2avmzw5QJLGO9cyyLOOntYTk4SXsq0EbmSsuKeoxoiAVGSRz6rGaxsq8SXsq0EbmSsuKeoxoiAVGSRz6rGaxsW0J6BIGODsswacElmR4FSeeTxadRefjHZLdI2li7AMEeiWLeeNejjh13ebr7KKSae8wy1xDSmwcI2lGrjEwIaqeMAcxMeo3r9nbzxNF5aOpHPD4YCmHwsncE0aw98GNJLGO9cyuINHvII32ip3U(J6BcYUo)YbqFct7WL5ycTKAe8ObS65bphlbr7fWOepdRefFIHjgm1Gch13ep77LgSuHO59M1sjZPDEQDAYNRnUK1n7BPEYUo)YbqFIHjgm1GcuVTj0Eby5TnH2lGl3Z1WuquAPeoTKMsuR4rLC5AnA4eGsXu7CIj3aM2aIsfq8CI)SZ4YvBCjRB23Ivv5XyjiAVagL4zyLO4ZTRpFTn8DuFt8SVxAWsfIM3BwlLmN25P2PjFU24sw3SVL6j768lha9521NV2g(OEBtO9cWYBBcTxaxUNRHPGO0sjCAjnLOwXJk5Y1A0WjaLIP25etUbmTbeLkG45e)zNXLR24sw3SVfRQwxJLGO9cyuINHvIIUUqPYYvuBFbCbOh13ePIsjHsF23l9Aeqn8rTttovukju6Z(EPxJaQHpQrWJgWQVaXtXdEXLR1KkkLek9zFV0Rra1Wh1oDSeeTxaJs8mSsumD1Ebh13ep77L(eM2HlZXeAj1on5N99sdwQq08EZAPK50op1on5Z1WuquAPeoTKMsuR4rLC5AnA4eGsXu7CIj3aM2aIsfq8CI)mUC1gxY6M9Tyf)vowglbr7fWOeNejjjEH5j(mRC1J6BIurPKqPp77LEncOg(O2PjNkkLek9zFV0Rra1Wh1i4rdywLOaXtXdEnwcI2lGrjojssWkrrCBN2SYvpQVjkq8u8Gx8ovukju6Z(EPpjyAM4KijHAe8ObS65jL)khlbr7fWOeNejjyLO4lmpXNzLREuFtCTDUSriLHPGK1gxSQaXtXdELmzxNF5aOpHPD4YCmHwsncE0a2yjiAVagL4KijbRefdwQq08EZAPK50o)yjiAVagL4KijbRefzAGNkE5O(M4zFV0GLkenV3SwkzoTZtTtt(zFV0NW0oCzoMqlP2PC5QnUK1n7BXQQvowcI2lGrjojssWkrXNW0oCzoMqlpQVji768lhanyPcrZ7nRLsMt78uJGhnGvp)8KlxTXLSUzFlwvTYXsq0EbmkXjrscwjkskB8qmrMvU6yjiAVagL4KijbRefJmUTXlM8EZeZYHnwcI2lGrjojssWkrXxymrbzSeeTxaJsCsKKGvIIyQDUmzXXdGFSeeTxaJsCsKKGvII(2i5NemDSeeTxaJsCsKKGvIIVW8eFMvU6r9nrQOusO0N99sVgbudFu)YbK85KYWuqy5RjiAVGWvFvAfZL7Z(EPpHPD4YCmHwsTtpJlxYUo)YbqdwQq08EZAPK50op1i4rdywLkkLek9zFV0Rra1Wh1BBcTxaVlq8jh1iMwfAQPXdxUbmTbeLrfq8CINlxTXLSUzFlwHTJLGO9cyuItIKeSsuKSptKzLREuFtq215xoakMANltwC8a4PgbpAaR(7sSzuTXLSUz8GxJLGO9cyuItIKeSsuKL2Q2GczY(mXyzSeeTxaJY0eVW8eFMvU6r9nrQOusO0N99sVgbudFu70KtfLscL(SVx61iGA4JAe8ObmRsuG4P4bV4Y9A7CzJqkdtbjRnUyvbINIh8kzYUo)YbqFct7WL5ycTKAe8ObmUCJAetRcn104Hl3aM2aIYOciEoXNmzxNF5aOblviAEVzTuYCANNAe8ObmRkq8JLGO9cyuMIvIIblviAEVzTuYCANFSeeTxaJYuSsumY42gVyY7ntmlh2yjiAVagLPyLOitd8uXlh13ep77LgSuHO59M1sjZPDEQDAYp77L(eM2HlZXeAj1oLlxTXLSUzFlwvTYXsq0EbmktXkrXNW0oCzoMqlpQVji768lhanyPcrZ7nRLsMt78uJGhnGvp)8KlxTXLSUzFlwvTYXsq0EbmktXkrrm1oxMS44bWpwcI2lGrzkwjkskB8qmrMvU6yjiAVagLPyLOOVns(jbthlbr7fWOmfRefFH5j(mRC1J6BIurPKqPp77LEncOg(O(Ldi5ZjLHPGWYxtq0EbHR(Q0kMl3N99sFct7WL5ycTKANEgxUKDD(LdGgSuHO59M1sjZPDEQrWJgWSkvukju6Z(EPxJaQHpQ32eAVaExG4toQrmTk0utJhUCdyAdikJkG45epxUAJlzDZ(wScBhlbr7fWOmfRefFHXefKXsq0EbmktXkrrY(mrMvU6r9nX53LyZ4nzzkw3LyZOgPGaSUpNSRZVCaum1oxMS44bWtncE0agVREw9br7fqXu7CzYIJhapLSmLlxYUo)YbqXu7CzYIJhap1i4rdy1xfRce)zjt215xoakMANltwC8a4PgbpAaR(QJLGO9cyuMIvIIS0w1guit2NjGkuHqa]] )

    
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
