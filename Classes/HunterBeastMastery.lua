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


    spec:RegisterPack( "Beast Mastery", 20181211.0931, [[dWeRAaqiOsPhbv0MuK6tQaJcjPtHKyvqfsVcOAwkkDlGu7Is)IImmkuhdQAzQipdizAkIY1ubTnfb(MquACcroNqW6ueAEaLUhf1(qsDqOcwOIQhQiYevevxuik8rOsXive0jHkPwjfmtOsYnfIQDcedLcPwkfsEQknvvORcvi(kujmwOs0zHkv7vv)vHbd6WuTyO8yuMSOUmXMrQplKgTioTuRgQq9AGIzl42a2nKFR0WfPJlefTCu9CetN01fQTRi57iX4PqCEffRxi08vrTFj)4)J)n7Q8GCYy8rc)j84Tghbqz8Hr6V6mPYFtDgy8OYFroG835It0cg5orf(m)n1NjSE(p(xYgZzYFtunLmrtMI2AsmMLTaMinqCW1ErmUtRMinaZewyXmHr7GoltzkLV0DqiMmAUyuENjMmAJAmHXiv4J5It0rK7ev4Zyjna7VyXDqX1Oh7VzxLhKtgJps4pHhV14iakJpfH)ssf2dYPdb1Ft6Cwqp2FZcH9xCwW5It0cg5orf(mfCcJrQWld4SGjQMsMOjtrBnjgZYwatKgio4AVig3PvtKgGzclSyMWODqNLPmLYx6oietgnxmkVZetgTrnMWyKk8XCXj6iYDIk8zSKgGvgWzbNCHjaycVG4XpBbpzm(ivqqxqJJWepfHYqzaNfCsjokQqMyzaNfe0fehYzjxWjTXiv4f8MSAb1TGzH2JdAbDM2lQGHMO2YaoliOliocrkO2aYq3rULcs1Pi2cQopQOwTbKHUJCluPG6wqhPnRtDvkOGYfCPlOGyBmsfU9VP8LUdYFXzbNlorlyK7ev4ZuWjmgPcVmGZcMOAkzIMmfT1KymlBbmrAG4GR9IyCNwnrAaMjSWIzcJ2bDwMYukFP7Gqmz0CXO8otmz0g1ycJrQWhZfNOJi3jQWNXsAawzaNfCYfMaGj8cIh)Sf8KX4JubbDbnoct8uekdLbCwWjL4OOczILbCwqqxqCiNLCbN0gJuHxWBYQfu3cMfApoOf0zAVOcgAIAld4SGGUG4iePGAdidDh5wkivNIylO68OIA1gqg6oYTqLcQBbDK2So1vPGckxWLUGcITXiv42YqzaNfmYWiclwLCbXe6LlfKTayUwqmjAJi2cIdmMKQKcIweOtCoaDCOGot7frk4IcZyldot7frSPCHTayUAMo4eWugCM2lIyt5cBbWCfCZM84OacsDTxuzWzAViInLlSfaZvWnBIE3CzWzAViInLlSfaZvWnBIedaSOrQOLbCwWlYtjjRwqU35cIfttl5csuxjfetOxUuq2cG5AbXKOnIuqhLlykxaD6QAJIwWMuW8IeBzWzAViInLlSfaZvWnBIG8usYQdI6kPm4mTxeXMYf2cG5k4MnLUAVOYaolioKXXXeLuqnrkyoM7AVOc6OCbz7gYlfubx6cIdKuHPfCPlOMifex0HCbDuUGgnVb8qbX1iI2iMski2mfutKcMJ5U2lQGlDbDubJrjorLCbXntAYliLebvqnrM5aUuWyIKlykxylaMR2cIdKcIdRIlkyItkOxq8wqrkiUzstEbDuUGonTWusbBLib6cQjnPGnPG4T4j2YGZ0EreBkxylaMRGB2KtsfMow6HMidkDipBkxyorhAdiMXBXpBtBg36ru4Tk2uEd4HrJiAJykXkihli5YaolioKXXXeLuqnrkyoM7AVOc6OCbz7gYlfubx6coxiA7HcIl4UMuqhLl4e6ruk4sxqJYJkfeBMcQjsbZXCx7fvWLUGoQGXOeNOsUG4Mjn5fKsIGkOMiZCaxkymrYfmLlSfaZvBzWzAViInLlSfaZvWnBctiA7HbfURjZMYfMt0H2aIz82dNTPn7ru4Tk2uEd4HrJiAJykXkihli5YqzaNfmYWiclwLCbLPe(mfuBaPGAIuqNPlVGnPG(uEhCSGyldot7frmZ2yKk8bjz1YGZ0EreWnBkMiJwfaszWzAVic4MnHjCIWbtJIoBtBMTBiVuqwmHOThgu4UMy5cG3ic1GY4YGZ0EreWnBclSBEqhZNz2M2mB3qEPGSycrBpmOWDnXYfaVreQbLXLbNP9IiGB2KJycr5EyW8qy2M2mB3qEPGSycrBpmOWDnXYfaVreQbLXLbNP9IiGB2eDZfSWU5zBAZSDd5LcYIjeT9WGc31elxa8grOgugxgCM2lIaUztPR2lA2M2mwmnTftiA7HbfURj240PXIPPTojvy6yPhAImO0HSnoDAQQopQO2eXdAInLPGfuhE(mUv9GGuly6qq4Jgr0gXuRGCSGKPY5ZAdidDh5wa7Pdldot7fra3SjmNJj5bjz1zBAZPIAzUAXIPPT0CbfXzSXPtNkQL5QflMM2sZfueNXYfaVreWAoklBbCJC(mDCim4clX5rLH2acyJYYwa3itZ2nKxkilMq02ddkCxtSCbWBePm4mTxebCZMcD0eLmWXX5Oacsldot7fra3SjsARAJIoylg3ldot7fra3SjNKkmDS0dnrgu6qUm4mTxebCZM8bqmpl8Xspy8Lcz2M2SZ0EkziibOfIz8LbNP9IiGB2erDGujlZ20MXIPPTojvy6yPhAImO0HSnoDASyAAlMq02ddkCxtSXPNpRnGm0DKBbS4pSm4mTxebCZMaIdAtswD2M2mjvcHH68OIsO(00rzzlGBeqNkQL5QflMM2IjorhSG4tjwUa4nIqTX2thwgCM2lIaUztycrBpmOWDnz2M2mB3qEPGSojvy6yPhAImO0HSLlaEJiuFY4ZN1gqg6oYTaw8hwgCM2lIaUztyoN7rLzBAZot7PKHGeGwiuJVm4mTxebCZMyjnGlCFqswD2M2mjvcHH68OIsOgFzWzAVic4Mnbeh0MKS6SnTzsQecd15rfLqn(PJYYwa3iGovulZvlwmnTftCIoybXNsSCbWBeHAJTNoSm4mTxebCZMathcd2ca4OCzWzAVic4MnXsAax4(GKSAzWzAVic4Mn5dGyEw4JLEW4lfszWzAVic4MnLBUmWeNOLbNP9IiGB2eMZXK8GKS6SnT5urTmxTyX00wAUGI4m28sbnnvzjopQqg0CNP9I8a14Tr68zSyAAlMq02ddkCxtSXPu58z2UH8sbzDsQW0Xsp0ezqPdzlxa8gra7emThrH3Qyt5nGhgnIOnIPeRGCSGKpFwBazO7i3cyJqzWzAVic4MnH5CUhvkdot7fra3Sj2IX9bjz1zBAZu1zApLmeKa0cbSNoFMTBiVuqwW0HWGTaaokB5cG3ic10llMy1gqg6oaCJqLPPk9YIjGMTefC6LftSCjQGWrPkB3qEPGSGPdHbBbaCu2YfaVreqJNku7mTxKfmDimylaGJYw2s0ZNz7gYlfKfmDimylaGJYwUa4nIqnEWJYYuzA2UH8sbzbthcd2ca4OSLlaEJiuJVm4mTxebCZMCoZrYqxoxq6FNs4KErpiNmgFKmocNIG90j84)lfNJAuuYFXf4GrbcUgeCZelybpMifSbsxUwq6LxWdYcThh0dkixImJBUKlizbKc6X6c4QKlilXrrfITmGRAKuWinXcoPfnLWvjxWdsf1IlT4U1ApOG6wWdWDR1EqbP6jJqfBzax1iPG4NSjwWjTOPeUk5cEqQOwCPf3Tw7bfu3cEaUBT2dkivXBeQyld4QgjfeFKMybN0IMs4QKl4bPIAXLwC3AThuqDl4b4U1ApOGufVrOITmGRAKuWtGAIfCslAkHRsUGhKkQfxAXDR1Eqb1TGhG7wR9Gcsv8gHk2YqzaxdKUCvYf8ubDM2lQGHMOeBz4VESMS8)EBGj93qtuYF8VzH2Jd6F8bb)F8Vot7f9x2gJuHpijR(xb5ybj)ZF9b50F8Vot7f93yImAvai)vqowqY)8xFqa1F8VcYXcs(N)xgVvH3(Fz7gYlfKftiA7HbfURjwUa4nIuqQliOm(Vot7f9xmHteoyAu0xFqMS)4FfKJfK8p)VmERcV9)Y2nKxkilMq02ddkCxtSCbWBePGuxqqz8FDM2l6VyHDZd6y(mV(GC4F8VcYXcs(N)xgVvH3(Fz7gYlfKftiA7HbfURjwUa4nIuqQliOm(Vot7f9xhXeIY9WG5HWRpitWF8VcYXcs(N)xgVvH3(Fz7gYlfKftiA7HbfURjwUa4nIuqQliOm(Vot7f9x6MlyHDZV(Gez)J)vqowqY)8)Y4Tk82)lwmnTftiA7HbfURj240coDbXIPPTojvy6yPhAImO0HSnoTGtxqQwq15rf1MiEqtSPmTGGTGG6WcE(CbXTfu9GGuly6qq4Jgr0gXuRGCSGKlivk45ZfuBazO7i3sbbBbpD4FDM2l6VPR2l61hKi9h)RGCSGK)5)LXBv4T)xSyAAlnxqrCgBCAbNUGyX00wAUGI4mwUa4nIuqWAUGrzzlGBKcE(CbPJdHbxyjopQm0gqkiylyuw2c4gPGtxq2UH8sbzXeI2EyqH7AILlaEJi)1zAVO)I5CmjpijR(6dse(J)1zAVO)g6OjkzGJJZrbeK(xb5ybj)ZF9bbVX)X)6mTx0FjPTQnk6GTyC)VcYXcs(N)6dcE8)X)6mTx0FDsQW0Xsp0ezqPd5)kihli5F(Rpi4p9h)RGCSGK)5)LXBv4T)xNP9uYqqcqlKcAUG4)RZ0Er)1haX8SWhl9GXxkKxFqWdQ)4FfKJfK8p)VmERcV9)IfttBDsQW0Xsp0ezqPdzBCAbNUGyX00wmHOThgu4UMyJtl45ZfuBazO7i3sbbBbXF4FDM2l6Ve1bsLS86dc(j7p(xb5ybj)Z)lJ3QWB)VKujegQZJkkPGuxWtfC6cgLLTaUrkiOliwmnTftCIoybXNsSCbWBePGuxqJTNo8Vot7f9xG4G2KKvF9bb)H)X)kihli5F(Fz8wfE7)LTBiVuqwNKkmDS0dnrgu6q2YfaVrKcsDbpzCbpFUGAdidDh5wkiyli(d)RZ0Er)ftiA7HbfURjV(GGFc(J)vqowqY)8)Y4Tk82)RZ0EkziibOfsbPUG4)RZ0Er)fZ5CpQ86dc(i7F8VcYXcs(N)xgVvH3(FjPsimuNhvusbPUG4)RZ0Er)LL0aUW9bjz1xFqWhP)4FfKJfK8p)VmERcV9)ssLqyOopQOKcsDbXxWPlyuw2c4gPGGUGyX00wmXj6GfeFkXYfaVrKcsDbn2E6W)6mTx0FbIdAtsw91he8r4p(xNP9I(ly6qyWwaahL)RGCSGK)5V(GCY4)4FDM2l6VSKgWfUpijR(xb5ybj)ZF9b5e()4FDM2l6V(aiMNf(yPhm(sH8xb5ybj)ZF9b50P)4FDM2l6V5MldmXj6FfKJfK8p)1hKtG6p(xb5ybj)Z)lJ3QWB)VyX00wAUGI4m28sbvWPlivlilX5rfYGM7mTxKhki1feVnsf885cIfttBXeI2EyqH7AInoTGuPGNpxq2UH8sbzDsQW0Xsp0ezqPdzlxa8grkiyl4euWPlOhrH3Qyt5nGhgnIOnIPeRGCSGKl45ZfuBazO7i3sbbBbJWFDM2l6VyohtYdsYQV(GCAY(J)1zAVO)I5CUhv(RGCSGK)5V(GC6W)4FfKJfK8p)VmERcV9)s1c6mTNsgcsaAHuqWwWtf885cY2nKxkily6qyWwaahLTCbWBePGuxq6LftSAdidDhaUrkivk40fKQfKEzXKcc6cYwIwqWli9YIjwUevqfehTGuTGSDd5LcYcMoegSfaWrzlxa8grkiOli(csLcsDbDM2lYcMoegSfaWrzlBjAbpFUGSDd5LcYcMoegSfaWrzlxa8grki1feFbbVGrz5csLcoDbz7gYlfKfmDimylaGJYwUa4nIuqQli()6mTx0Fzlg3hKKvF9b50e8h)RZ0Er)15mhjdD5CbP)vqowqY)8xF9VPCHTayU(hFqW)h)RGCSGK)5V(GC6p(xb5ybj)ZF9bbu)X)kihli5F(Rpit2F8Vot7f9xsmaWIgPI(xb5ybj)ZF9b5W)4FfKJfK8p)1hKj4p(xNP9I(B6Q9I(RGCSGK)5V(Gez)J)vqowqY)8)MYfMt0H2aYFXBX)xNP9I(RtsfMow6HMidkDi)xgVvH3(FXTf0JOWBvSP8gWdJgr0gXuIvqowqYV(GeP)4FfKJfK8p)VPCH5eDOnG8x82d)RZ0Er)ftiA7HbfURj)LXBv4T)xpIcVvXMYBapmAerBetjwb5ybj)6RV(6R)d]] )

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
