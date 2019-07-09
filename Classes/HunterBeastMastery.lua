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
        dance_of_death = {
            id = 274443,
            duration = 8,
            max_stack = 1
        },
        
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
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

            cycle = 'barbed_shot',

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
            gcd = "off",

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


        -- Pet Abilities
        -- Moths
        serenity_dust = {
            id = 264055,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Sporebats
        spore_cloud = {
            id = 264056,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Water Striders
        soothing_water = {
            id = 264262,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Bats
        sonic_blast = {
            id = 264263,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Nether Rays
        nether_shock = {
            id = 264264,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Cranes
        chijis_tranquility = {
            id = 264028,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Spirit Beasts
        spirit_shock = {
            id = 264265,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


        -- Stags
        natures_grace = {
            id = 264266,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            toggle = "interrupts",

            startsCombat = true,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
            end,
        },


    } )


    spec:RegisterPack( "Beast Mastery", 20190417.2233, [[dWetTaqies9iPsztIiFsPIrHq5uiuTkPsf9ke0SKk5wsrSlK(LsXWivQJjvSmQu9mLsnnPiDneITjfQ(gcjgNuPQZrQqRtPsMNiQ7rQAFsrDqLk1cvQ6HKkyIiKuxeHK4JsHIrsQiCssLOvsLmtsLWnjveTtPkdfHK0sLkv6PkzQsvDvPsf(kPIQXsQOCwsL0Ev5VIAWqDyHfdYJHmzQ6YO2mO(SimAP0PLSAsfPxRuYSP0TjLDRQFdmCr64sHslNINtY0jUovSDQu(oIA8sHCEey9sbZhr2VIVox)B5dHVEUR7o6OUBAhIc1D33E7MsKBjeKY3knqBfj4B9HgFR9COKbRtgkHneCR0Gali8x)BPaogeFRwrsv7AZMeL06arraTnQsZXgsbEKjGLnQsdT5wqoLv0L)bDlFi81ZDD3rh1Dt7quOU7(2B3u3Vv4iTaZTwLMoCR2Y75)GULNvOB1TbVNdLmyDYqjSHGbRt48cBgxDBWTIKQ21MnjkP1bIIaABuLMJnKc8italBuLgAZ4QBdE3PMYo4oeLUgS76UJoo4Mmy3DFxBV94AC1TbRdTXNGv7AC1Tb3KbVBVN9dwhaoVWMbVAbYGfWG9mC4yLbhiPa)GTLsOJRUn4Mm4UdfpyP04SaY(IhmXCtrhSeMeSqLsJZci7lM4dwadoEPqvAi8G53pya8G5hbCEHn0Xv3gCtg8U9(b7lvkBvBsDmjy1GDRIb7iLTecgCGKc8d2wkHElBPe11)wEgoCSY1)6156Fl(dil7V93czkHnvClpd5adtrHsQpb1jDWKinypd5adt9LkLT2aYYzTirHOoPdMePb7zihyyQVuPS1gqwoZVjsWuN0BfiPa)TqH1MdKuGpBlLClBPK8hA8TCKYwcbNC9C)6FRajf4VLJIZLWAQBXFazz)T)KR32x)BXFazz)T)wbskWFluyT5ajf4Z2sj3Ywkj)HgFlKxDY1RPx)BXFazz)T)witjSPIBfiPCJZ8ZAfRgCYd29BfiPa)TqH1MdKuGpBlLClBPK8hA8TuYjxpIC9Vf)bKL93(BHmLWMkUvGKYnoZpRvSAWnp4o3kqsb(BHcRnhiPaF2wk5w2sj5p04BHSC4gFYj3k1WiGguix)RxNR)T4pGSS)2FY1Z9R)T4pGSS)2FY1B7R)T4pGSS)2FY1RPx)BfiPa)TuoAAGpNYYT4pGSS)2FY1Jix)BXFazz)T)KRxJF9VvGKc83kfif4Vf)bKL93(tUEeLR)T4pGSS)2FRudJcLKLsJVvhANBfiPa)TcvkJKmaolTCMCz93czkHnvClIEWrdSPeMMAkTWMRxj1JefL)aYY(tUED)1)w8hqw2F7VvQHrHsYsPX3QdLi3kqsb(BbXkPcBMSjK2BHmLWMkUv0aBkHPPMslS56vs9irr5pGSS)KtUfYYHB81)6156Fl(dil7V93kqsb(Bbfgi2NvTa5witjSPIBb5adtHn83abuN0bN0GHCGHPWg(BGaQH1I6vdoz9dobYt1IgDlebilNLWKGf11RZjxp3V(3I)aYY(B)TqMsytf3kbYt1Ign4MmyihyykehkjJSC4gtnSwuVAWnpyDtDNi3kqsb(BP5yLs1cKtUEBF9Vf)bKL93(BfiPa)TGcde7ZQwGClKPe2uXTGDS2SHrTHjbNLsJhCYdobYt1Ign4KgmcaSEa5NcXkPcBMSjKwQH1I6v3craYYzjmjyrD96CY1RPx)BfiPa)TcvkJKmaolTCMCz93I)aYY(B)jxpIC9Vf)bKL93(BHmLWMkUfKdmmnuPmsYa4S0YzYL1tDshCsdgYbgMcXkPcBMSjKwQt6GjrAWsPXzbK9fp4KhChICRajf4VLscTu2ZNC9A8R)T4pGSS)2FlKPe2uXTqaG1di)0qLYijdGZslNjxwp1WAr9QCchwPgCZd2DDpysKgSew(fk45m5sAZslNtd0wu(dil7hmjsdwknolGSV4bN8G7qKBfiPa)TGyLuHnt2es7jxpIY1)wbskWFluBPfSjYQwGCl(dil7V9NC96(R)TcKuG)wrwZX4ztgaNrgaz1T4pGSS)2FY1thV(3kqsb(BbfgtKGVf)bKL93(tUED091)w8hqw2F7VfYucBQ4wbsk34m)SwXQbN8GB6GjrAWe9GJgytjm1ePLpByli8u(dil7VvGKc83ARYAZiGMw8(tUED6C9VvGKc83YxgodXHsUf)bKL93(tUEDC)6Fl(dil7V93kqsb(Bbfgi2NvTa5witjSPIBb5adtHn83abupG8p4KgmXgmQnmjyvg2eiPaFyhCZdUdT7hmjsdgYbgMcXkPcBMSjKwQt6Gj(GjrAWiaW6bKFAOszKKbWzPLZKlRNAyTOE1GtEWqoWWuyd)nqa17ycPa)GBYGtG8doPbhnWMsyAQP0cBUELupsuu(dil7hmjsdoAGnLWuF8iodGZEoKwQj(TgCZdUZGtAWqoWWuF8iodGZEoKwQhq(hCsdwjHqrMsgCZdUP6EWKinyP04SaY(IhCYdwhVfIaKLZsysWI6615KRxNTV(3I)aYY(B)TqMsytf3kAGnLWutKw(SHTGWt5pGSSFWjn4ajLBCMFwRy1GBEWUFRajf4VLMJvkvlqo561PPx)BXFazz)T)witjSPIBHaaRhq(PBvwBgb00I3tnSwuVAWnpyyaYrrLsJZciRfnAWjnyIn4ajLBCMFwRy1GtEWBpysKgmrp4Ob2uctnrA5Zg2ccpL)aYY(bt8BfiPa)TqaitKvTa5KRxhIC9VvGKc83sLwIuFImcazIBXFazz)T)KRxNg)6Fl(dil7V93czkHnvCROb2uctnrA5Zg2ccpL)aYY(bN0GdKuUXz(zTIvdU5b7(TcKuG)wAowPuTa5KtUfYRU(xVox)BXFazz)T)witjSPIBHaaRhq(PqSsQWMjBcPLAyTOE1GBEWBR7BfiPa)TIhXkXe2mkS2tUEUF9Vf)bKL93(BHmLWMkUfcaSEa5NcXkPcBMSjKwQH1I6vdU5bVTUVvGKc83cUmmKfa8NC92(6Fl(dil7V93czkHnvClihyyAOszKKbWzPLZKlRN6Ko4KgmXgSuACwazFXdU5bJaaRhq(PqSrXMTQpb17ycPa)GjCWEhtif4hmjsdMydwctcwOTCyLwAksgCYdEBImysKgmrpyjS8l0TkRLn56vs9iHYFazz)Gj(Gj(GjrAWsPXzbK9fp4KhCNTVvGKc83cInk2Sv9jo5610R)T4pGSS)2FlKPe2uXTGCGHPHkLrsgaNLwotUSEQt6GtAWeBWsPXzbK9fp4MhmcaSEa5NczbaFg2Xqa17ycPa)GjCWEhtif4hmjsdMydwctcwOTCyLwAksgCYdEBImysKgmrpyjS8l0TkRLn56vs9iHYFazz)Gj(Gj(GjrAWsPXzbK9fp4KhCNg)wbskWFlila4ZWogco56rKR)T4pGSS)2FlKPe2uXTGCGHPWg(BGaQt6GtAWqoWWuyd)nqa1WAr9Qb38GtG8uTOrdMePbt0dgYbgMcB4VbcOoP3kqsb(BzReTIkRtD8j04xo5614x)BXFazz)T)witjSPIBb5adtHyLuHnt2esl1jDWjnyihyyAOszKKbWzPLZKlRN6Ko4KgmXgSeMeSqB5WkT0uKm4Kh82ezWKinyIEWsy5xOBvwlBY1RK6rcL)aYY(bt8btI0GLsJZci7lEWjpy3jYTcKuG)wPaPa)jNClLC9VEDU(3I)aYY(B)TqMsytf3cYbgMcB4VbcOoPdoPbd5adtHn83abudRf1RgCY6hCcKNQfnAWKinyyhRnByuBysWzP04bN8GtG8uTOrdoPbJaaRhq(PqSsQWMjBcPLAyTOE1GjrAWrdSPeMMAkTWMRxj1JefL)aYY(bN0GraG1di)0qLYijdGZslNjxwp1WAr9QbN8GtG83kqsb(Bbfgi2NvTa5KRN7x)BfiPa)TcvkJKmaolTCMCz93I)aYY(B)jxVTV(3kqsb(BfznhJNnzaCgzaKv3I)aYY(B)jxVME9Vf)bKL93(BHmLWMkUfKdmmnuPmsYa4S0YzYL1tDshCsdgYbgMcXkPcBMSjKwQt6GjrAWsPXzbK9fp4KhChICRajf4VLscTu2ZNC9iY1)w8hqw2F7VfYucBQ4wiaW6bKFAOszKKbWzPLZKlRNAyTOE1GBEWUR7btI0GLsJZci7lEWjp4oe5wbskWFliwjvyZKnH0EY1RXV(3kqsb(BTvzTzeqtlE)T4pGSS)2FY1JOC9VvGKc83c1wAbBISQfi3I)aYY(B)jxVU)6FRajf4VLVmCgIdLCl(dil7V9NC90XR)T4pGSS)2FlKPe2uXTGCGHPWg(BGaQhq(hCsdMydg1gMeSkdBcKuGpSdU5b3H29dMePbd5adtHyLuHnt2esl1jDWeFWKinyeay9aYpnuPmsYa4S0YzYL1tnSwuVAWjpyihyykSH)giG6DmHuGFWnzWjq(bN0GJgytjmn1uAHnxVsQhjkk)bKL9dMePblLgNfq2x8GtEW64TcKuG)wqHbI9zvlqo561r3x)BfiPa)TGcJjsW3I)aYY(B)jxVoDU(3I)aYY(B)TqMsytf3IydggGCudUjdgbuYGjCWWaKJIA4e8p4UZbtSbJaaRhq(PBvwBgb00I3tnSwuVAWnzWDgmXhCZdoqsbE6wL1MranT49ueqjdMePbJaaRhq(PBvwBgb00I3tnSwuVAWnp4odMWbNa5hmXhCsdgbawpG8t3QS2mcOPfVNAyTOE1GBEWDUvGKc83cbGmrw1cKtUEDC)6FRajf4VLkTeP(ezeaYe3I)aYY(B)jxVoBF9Vf)bKL93(BHmLWMkUfQnmjyvg2eiPaFyhCZdUdTP3kqsb(Bbfgi2NvTa5KtULJu2si46F96C9VvGKc83cbCEHnzvlqUf)bKL93(tUEUF9VvGKc83sXg(lHGS3rj3I)aYY(B)jxVTV(3kqsb(BPsbgoJSah)T4pGSS)2FY1RPx)BfiPa)TuaG0wFIm5qyZT4pGSS)2FY1Jix)BfiPa)TuGVqziBOKBXFazz)T)KRxJF9VvGKc836zPLnzvlaT1T4pGSS)2FY1JOC9VvGKc83c1w60sLft8nwNYwcb3I)aYY(B)jxVU)6FRajf4VLkTmLKvTa0w3I)aYY(B)jxpD86FRajf4V1hIJHv5eMaX3I)aYY(B)jNCYTCJnQc8xp31DhDu3nv3DODAAtD)wKdZxFc1T057U72tx2RXSRbp4(T8GlTuGrgmmWm4DqwoCJ3zWgUX6ug2pyfqJhC4iaTqy)GrTXNGv0XLUOEEWD21G1bW7gBe2p4DszHQZO6kLs3zWcyW7ORukDNbtm3BeXPJlDr98GDFxdwhaVBSry)G3jLfQoJQRukDNblGbVJUsP0DgmX60iIthx6I65b3X9DnyDa8UXgH9dENuwO6mQUsP0DgSag8o6kLs3zWeZ9grC64ACPZ3D3TNUSxJzxdEW9B5bxAPaJmyyGzW7G8QDgSHBSoLH9dwb04bhocqle2pyuB8jyfDCPlQNhmr21G1bW7gBe2p4DszHQZO6kLs3zWcyW7ORukDNbtSTBeXPJRXLoF3D3E6YEnMDn4b3VLhCPLcmYGHbMbVJs2zWgUX6ug2pyfqJhC4iaTqy)GrTXNGv0XLUOEEWD21G1bW7gBe2p4DszHQZO6kLs3zWcyW7ORukDNbtm3BeXPJlDr98G1XDnyDa8UXgH9dENuwO6mQUsP0DgSag8o6kLs3zWeZ9grC64ACPl1sbgH9dUXhCGKc8d2wkrrhx3sLYORN7ez7BLAaWLLVv3g8EouYG1jdLWgcgSoHZlSzC1Tb3ksQAxB2KOKwhikcOTrvAo2qkWJmbSSrvAOnJRUn4DNAk7G7qu6AWUR7o64GBYGD39DT92JRXv3gSo0gFcwTRXv3gCtg8U9E2pyDa48cBg8Qfidwad2ZWHJvgCGKc8d2wkHoU62GBYG7ou8GLsJZci7lEWeZnfDWsysWcvknolGSVyIpybm44LcvPHWdMF)GbWdMFeW5f2qhxDBWnzW727hSVuPSvTj1XKGvd2TkgSJu2siyWbskWpyBPe64AC1TbtuPrmYry)GHyyGHhmcObfYGH4e1ROdE3ieNkQb)GVjTHrd2Xo4ajf4vdg8wcOJRajf4v0udJaAqHOh2gQTgxbskWROPggb0GcHq9BcNeA8lHuGFCfiPaVIMAyeqdkec1Vbga8JRajf4v0udJaAqHqO(nkhnnWNtzzC1TbV(iv1cKbBIYpyihyy2pyLeIAWqmmWWdgb0GczWqCI6vdoE)GtnCtsbIuFIbxQb7bpthxbskWROPggb0GcHq9BuFKQAbswjHOgxbskWROPggb0GcHq9Bsbsb(Xv3g8U96uhLOgS0Yd27ycPa)GJ3pyeay9aY)GbWdE3QugjdgapyPLhSoVS(bhVFWevnLwyhSU8vs9irnyicgS0Yd27ycPa)GbWdo(b78THsy)GBm6ar9Gj3Y)GLwMGDm8GDuSFWPggb0GcHo4DRg8UbIoFWTHAWXG7q3wn4gJoqup449doGHzKOgCjk2cpyPTudUudUdTJIoUcKuGxrtnmcObfcH63eQugjzaCwA5m5Y67k1WOqjzP0y9DOD6QG1t0rdSPeMMAkTWMRxj1JefL)aYY(Xv3g8U96uhLOgS0Yd27ycPa)GJ3pyeay9aY)GbWdEpRKkSdwNBcPDWX7hSor0apya8G7UrcEWqemyPLhS3Xesb(bdGhC8d25BdLW(b3y0bI6btUL)blTmb7y4b7Oy)GtnmcObfcDCfiPaVIMAyeqdkec1VbIvsf2mztiTDLAyuOKSuAS(ouI0vbRpAGnLW0utPf2C9kPEKOO8hqw2pUgxbskWROoszlHa9iGZlSjRAbY4kqsbEf1rkBjeqO(nk2WFjeK9okzCfiPaVI6iLTeciu)gvkWWzKf44hxbskWROoszlHac1VrbasB9jYKdHnJRajf4vuhPSLqaH63OaFHYq2qjJRajf4vuhPSLqaH638S0YMSQfG2ACfiPaVI6iLTeciu)guBPtlvwmX3yDkBjemUcKuGxrDKYwcbeQFJkTmLKvTa0wJRajf4vuhPSLqaH638H4yyvoHjq84AC1TbtuPrmYry)Gz3ydbdwknEWslp4ajaZGl1Gd3IYgqwMoUcKuGxPhfwBoqsb(STusxFOX6DKYwcbDvW69mKdmmffkP(euNusK8mKdmm1xQu2AdilN1IefI6KsIKNHCGHP(sLYwBaz5m)MibtDshxbskWRiu)ghfNlH1uJRajf4veQFdkS2CGKc8zBPKU(qJ1J8QXvGKc8kc1VbfwBoqsb(STusxFOX6vsxfS(ajLBCMFwRyvYUpUcKuGxrO(nOWAZbskWNTLs66dnwpYYHBCxfS(ajLBCMFwRyvZDgxJRajf4vuKxPpEeRetyZOWA7QG1JaaRhq(PqSsQWMjBcPLAyTOEvZBR7XvGKc8kkYRiu)g4YWqwaW3vbRhbawpG8tHyLuHnt2esl1WAr9QM3w3JRajf4vuKxrO(nqSrXMTQprxfSEihyyAOszKKbWzPLZKlRN6KMeXKsJZci7lUzeay9aYpfInk2Sv9jOEhtif4j07ycPapjsetctcwOTCyLwAkssEBIqIerlHLFHUvzTSjxVsQhju(dil7joXjrsknolGSV4K7S94kqsbEff5veQFdKfa8zyhdbDvW6HCGHPHkLrsgaNLwotUSEQtAsetknolGSV4MraG1di)uila4ZWogcOEhtif4j07ycPapjsetctcwOTCyLwAkssEBIqIerlHLFHUvzTSjxVsQhju(dil7joXjrsknolGSV4K704JRajf4vuKxrO(n2krROY6uhFcn(LUky9PSqrHqHCGHPWg(BGaQtAsPSqrHqHCGHPWg(BGaQH1I6vnNa5PArJirIOtzHIcHc5adtHn83abuN0XvGKc8kkYRiu)MuGuGVRcwpKdmmfIvsf2mztiTuN0KGCGHPHkLrsgaNLwotUSEQtAsetctcwOTCyLwAkssEBIqIerlHLFHUvzTSjxVsQhju(dil7jojssPXzbK9fNS7ezCnUcKuGxrrwoCJ1dfgi2NvTaPlebilNLWKGfL(oDvW6tzHIcHc5adtHn83abuN0KszHIcHc5adtHn83abudRf1RswFcKNQfnACfiPaVIISC4gtO(nAowPuTaPRcwFcKNQfnQjPSqrHqHCGHPqCOKmYYHBm1WAr9QM1n1DImUcKuGxrrwoCJju)gOWaX(SQfiDHiaz5SeMeSO03PRcwpSJ1MnmQnmj4SuACYjqEQw0OKqaG1di)uiwjvyZKnH0snSwuVACfiPaVIISC4gtO(nHkLrsgaNLwotUS(XvGKc8kkYYHBmH63OKqlL9CxfSEihyyAOszKKbWzPLZKlRN6KMeKdmmfIvsf2mztiTuNusKKsJZci7lo5oezCfiPaVIISC4gtO(nqSsQWMjBcPTRcwpcaSEa5NgQugjzaCwA5m5Y6PgwlQxLt4WkvZURBsKKWYVqbpNjxsBwA5CAG2IYFazzpjssPXzbK9fNChImUcKuGxrrwoCJju)guBPfSjYQwGmUcKuGxrrwoCJju)MiR5y8SjdGZidGSACfiPaVIISC4gtO(nqHXej4XvGKc8kkYYHBmH63SvzTzeqtlEFxfS(ajLBCMFwRyvYnLejIoAGnLWutKw(SHTGWt5pGSSFCfiPaVIISC4gtO(n(YWziouY4kqsbEffz5WnMq9BGcde7ZQwG0fIaKLZsysWIsFNUky9PSqrHqHCGHPWg(BGaQhq(tIyO2WKGvzytGKc8HT5o0UNejihyykeRKkSzYMqAPoPeNejeay9aYpnuPmsYa4S0YzYL1tnSwuVk5uwOOqOqoWWuyd)nqa17ycPaFtsG8jfnWMsyAQP0cBUELupsuu(dil7jrkAGnLWuF8iodGZEoKwQj(TAUtsqoWWuF8iodGZEoKwQhq(tsjHqrMsAUP6MejP04SaY(ItwhhxbskWROilhUXeQFJMJvkvlq6QG1hnWMsyQjslF2Wwq4P8hqw2NuGKYnoZpRvSQz3hxbskWROilhUXeQFdcazISQfiDvW6raG1di)0TkRnJaAAX7PgwlQx1mma5OOsPXzbK1IgLeXcKuUXz(zTIvjVnjseD0aBkHPMiT8zdBbHNYFazzpXhxbskWROilhUXeQFJkTeP(ezeaYeJRajf4vuKLd3yc1VrZXkLQfiDvW6Jgytjm1ePLpByli8u(dil7tkqs5gN5N1kw1S7JRXvGKc8kQs0dfgi2NvTaPRcwFkluuiuihyykSH)giG6KMukluuiuihyykSH)giGAyTOEvY6tG8uTOrKib7yTzdJAdtcolLgNCcKNQfnkjeay9aYpfIvsf2mztiTudRf1RirkAGnLW0utPf2C9kPEKOO8hqw2NecaSEa5NgQugjzaCwA5m5Y6PgwlQxLCcKFCfiPaVIQec1VjuPmsYa4S0YzYL1pUcKuGxrvcH63eznhJNnzaCgzaKvJRajf4vuLqO(nkj0szp3vbRhYbgMgQugjzaCwA5m5Y6PoPjb5adtHyLuHnt2esl1jLejP04SaY(ItUdrgxbskWROkHq9BGyLuHnt2esBxfSEeay9aYpnuPmsYa4S0YzYL1tnSwuVQz31njssPXzbK9fNChImUcKuGxrvcH63SvzTzeqtlE)4kqsbEfvjeQFdQT0c2ezvlqgxbskWROkHq9B8LHZqCOKXvGKc8kQsiu)gOWaX(SQfiDvW6tzHIcHc5adtHn83abupG8NeXqTHjbRYWMajf4dBZDODpjsqoWWuiwjvyZKnH0sDsjojsiaW6bKFAOszKKbWzPLZKlRNAyTOEvYPSqrHqHCGHPWg(BGaQ3Xesb(MKa5tkAGnLW0utPf2C9kPEKOO8hqw2tIKuACwazFXjRJJRajf4vuLqO(nqHXej4XvGKc8kQsiu)geaYezvlq6QG1tmyaYr1eeqjecdqokQHtWF3jXqaG1di)0TkRnJaAAX7PgwlQx1KoeV5ajf4PBvwBgb00I3traLqIecaSEa5NUvzTzeqtlEp1WAr9QM7qycKN4jHaaRhq(PBvwBgb00I3tnSwuVQ5oJRajf4vuLqO(nQ0sK6tKraitmUcKuGxrvcH63afgi2NvTaPRcwpQnmjyvg2eiPaFyBUdTPNCYD]] )


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
