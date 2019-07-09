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


    spec:RegisterPack( "Beast Mastery", 20190709.1200, [[dW0mZaqiuf1JKcztsr9jOOgfveNcvjRcvrOxPOmlfr3sQuTls9lPIHHQuhtuAzkQ8mufMMuPCnOiBtks9nPizCsHQZPOkRtrvnpPG7HQAFkchKksTqOWdPIKjIQi1frvK4JsHIrkkcoPOO0kPcZuuuCtrrODkvzOOksAPOkIEQctvQQRIQi4RIIuJvuKCwrr1Ev6Vu1Gj5WclgupgYKf5YiBgKptLA0sPtlz1IIOxlvYSP0TrLDRQFRYWfvhxkuA5u8CuMoX1HQTtf13PsgVueNxrA9IcZhkTFG3SB)DKcH2EZX7SZJ3nfVNNolpW0CDJh7qMMt7ipqDfUPD8bhTdmOGjavMyWeYmDh5Xu7fPT)oyhUbr7OvKC2870XDjT4WA0X1HvC42qQ7rMas6WkouNDaJxwjZ(l8osHqBV54D25X7MI3ZtNLhyAoE047iWL2ZSJrX5u7OTsj6x4DKigAhncOWGcMauzIbtiZuGkta)fYaC0iGQvKC2870XDjT4WA0X1HvC42qQ7rMas6WkouhGJgbuoWTtbQ5njqnhVZopGQ7av2SZFUSahahncOCQ24DtS5dC0iGQ7aLtNsucOCQd)fYauJ2tak5aQebf4wbOcKu3du2IjAGJgbuDhO4jWiGskoYlNpveq5eNzAGscJBs0sXrE58PI4fqjhqfVuOkpecOOpbuheqrp6WFHmAGJgbuDhOC6ucOsflNSSo54g3edOCUcGcxkBjtbQaj19aLTyIEh2IjST)oseuGBLT)2l72Fh0hWwkTySdKPeYuXosemoeKgfmPE3A8CGclwGkrW4qq6uXYjRnGTKNlCxinEoqHflqLiyCiiDQy5K1gWwYtVjCtA88DeiPUFhOWA9bsQ792Ij7WwmX)bhTdCPSLmDLT3CB)DeiPUFh4mYxcXX2b9bSLslgRS94X2Fh0hWwkTySJaj197afwRpqsDV3wmzh2Ij(p4ODGsSv2EDB7Vd6dylLwm2bYuczQyhbskNjp9exrmGQbGAUDeiPUFhOWA9bsQ792Ij7WwmX)bhTdMSY2dtB)DqFaBP0IXoqMsitf7iqs5m5PN4kIbutauz3rGK6(DGcR1hiPU3BlMSdBXe)hC0oqwkCMwzLDKBi0XbhY2F7LD7VJaj197GHZXDVpNKDqFaBP0IXkBV52(7iqsD)oYpPUFh0hWwkTySY2JhB)DeiPUFhUoJn5mvV3qS7Jhr7G(a2sPfJv2EDB7VJaj197WnEysv8(dYhzqMtA3b9bSLslgRS9W02FhbsQ73bhXDMP(dYBXrvYNmuWX2b9bSLslgRS9A6T)oOpGTuAXyh5gcfmXlfhTJS6S7iqsD)ocwoHe)b5LwY7QSPDGmLqMk2bpdurgKPesNBkUW6RNj1JeMM(a2sPv2En12Fh0hWwkTySJCdHcM4LIJ2rwnM2rGK6(DatmPcR3LjK2DGmLqMk2rKbzkH05MIlS(6zs9iHPPpGTuALv2bYsHZ02F7LD7Vd6dylLwm2rGK6(Dahgyk5zTNSdKPeYuXoGXHG0qg6ZyQgphOAgOGXHG0qg6ZyQ2qCr9mGQb(aLBusZfnzhOPil5LW4Me22l7kBV52(7G(a2sPfJDGmLqMk2HBusZfnbO6oqbJdbPHPGjEKLcNjTH4I6za1eafV1ZHPDeiPUFhC4wPyTNSY2JhB)DqFaBP0IXocKu3Vd4WatjpR9KDGmLqMk2beU16neQnmUjVuCeq1aq5gL0CrtaQMbk0D20561WetQW6DzcPvBiUOE2oqtrwYlHXnjSTx2v2EDB7VJaj197iy5es8hKxAjVRYM2b9bSLslgRS9W02Fh0hWwkTySdKPeYuXoGXHG0blNqI)G8sl5Dv2KgphOAgOGXHG0WetQW6DzcPvJNduyXcusXrE58PIaQgaQSyAhbsQ73btcUCkrRS9A6T)oOpGTuAXyhitjKPIDGUZMoxVoy5es8hKxAjVRYM0gIlQN5DJtmgqnbqnhVbkSybkjS0l67jVRsA9sl5ZduxA6dylLakSybkP4iVC(uravdavwmTJaj197aMysfwVltiTRS9AQT)ocKu3VduBXfKj8S2t2b9bSLslgRS9A8T)ocKu3VJWZHBsKXFqEK5CX2b9bSLslgRS9M32FhbsQ73bCymHBAh0hWwkTySY2llV3(7G(a2sPfJDGmLqMk2rGKYzYtpXvedOAaO6gqHflqXZavKbzkH0MiVsEdzViPPpGTuAhbsQ73rxL16rhhx8Pv2EzZU93rGK6(DKkd5HPGj7G(a2sPfJv2EzNB7Vd6dylLwm2rGK6(Dahgyk5zTNSdKPeYuXoGXHG0qg6ZyQoDUEGQzGYjafQnmUjMhYeiPUpSa1eavwDJduyXcuW4qqAyIjvy9UmH0QXZbkEbuyXcuO7SPZ1RdwoHe)b5LwY7QSjTH4I6zavdafmoeKgYqFgt1jCti19av3bk3Oeq1mqfzqMsiDUP4cRVEMupsyA6dylLakSybkuByCtmpKjqsDFybQjaQS6UbuyXcusXrE58PIaQgaQ5Td0uKL8syCtcB7LDLTxwES93rGK6(DaDiCgL8rgKPeYdtb3oOpGTuAXyLTx2UT93rGK6(DKJBkOP172dBdMSd6dylLwmwz7LftB)DeiPUFhO7r0lMqOKhYgC0oOpGTuAXyLTx2ME7VJaj197a2ExYFqEPL80tCt3b9bSLslgRS9Y2uB)DqFaBP0IXoqMsitf7aghcsBiuxwIX8qNbrA8CGclwGcghcsBiuxwIX8qNbrE0H)cz0mjqDbunauz59ocKu3VdPL84p8H)jp0zq0kBVSn(2Fh0hWwkTySdKPeYuXoImitjK2e5vYBi7fjn9bSLsavZavGKYzYtpXvedOMaOMBhbsQ73bhUvkw7jRS9YoVT)oOpGTuAXyhitjKPIDGUZMoxVURYA9OJJl(K2qCr9mGAcGc6q4mTuCKxopx0eGQzGYjavGKYzYtpXvedOAaO4bqHflqXZavKbzkH0MiVsEdzViPPpGTucO41ocKu3Vd0bBcpR9Kv2EZX7T)ocKu3VdwEjs9U9Od2e7G(a2sPfJvwzhOeB7V9YU93b9bSLslg7azkHmvSd0D20561WetQW6DzcPvBiUOEgqnbqXdEVJaj197iEeXety9OWAxz7n32Fh0hWwkTySdKPeYuXoq3ztNRxdtmPcR3LjKwTH4I6za1eafp49ocKu3VdOYqW27sRS94X2Fh0hWwkTySdKPeYuXoGXHG0blNqI)G8sl5Dv2KgphOAgOCcqjfh5LZNkcOMaOq3ztNRxdtggz6QE36eUjK6EGAgqLWnHu3duyXcuobOKW4MeDlfwPvNJeGQbGIhycOWIfO4zGscl9IURYAjJVEMups00hWwkbu8cO4fqHflqjfh5LZNkcOAaOYYJDeiPUFhWKHrMUQ39kBVUT93b9bSLslg7azkHmvSdyCiiDWYjK4piV0sExLnPXZbQMbkNausXrE58PIaQjak0D20561W27sEiCZuDc3esDpqndOs4MqQ7bkSybkNausyCtIULcR0QZrcq1aqXdmbuyXcu8mqjHLEr3vzTKXxptQhjA6dylLakEbu8cOWIfOKIJ8Y5tfbunauzB6DeiPUFhW27sEiCZ0v2EyA7Vd6dylLwm2bYuczQyhW4qqAid9zmvJNdunduW4qqAid9zmvBiUOEgqnbq5gL0CrtakSybkEgOGXHG0qg6ZyQgpFhbsQ73HTC3kmFMep5MJEzLTxtV93b9bSLslg7azkHmvSdyCiinmXKkSExMqA145avZafmoeKoy5es8hKxAjVRYM045avZaLtakjmUjr3sHvA15ibOAaO4bMakSybkEgOKWsVO7QSwY4RNj1Jen9bSLsafVakSybkP4iVC(uravda1CyAhbsQ73r(j19RS9AQT)oOpGTuAXyhitjKPIDaJdbPTfebBVlPzsG6cOAaO62ocKu3VdxNXMCMQ3Bi29XJOv2En(2FhbsQ73HB8WKQ49hKpYGmN0Ud6dylLwmwz7nVT)ocKu3VdtLNBjF9EwEGODqFaBP0IXkBVS8E7VJaj197GJ4oZu)b5T4Ok5tgk4y7G(a2sPfJvwzhmz7V9YU93b9bSLslg7azkHmvSdyCiinKH(mMQXZbQMbkyCiinKH(mMQnexupdOAGpq5gL0CrtakSybkiCR1BiuByCtEP4iGQbGYnkP5IMaunduO7SPZ1RHjMuH17YesR2qCr9mGclwGkYGmLq6CtXfwF9mPEKW00hWwkbunduO7SPZ1RdwoHe)b5LwY7QSjTH4I6zavdaLBuAhbsQ73bCyGPKN1EYkBV52(7iqsD)ocwoHe)b5LwY7QSPDqFaBP0IXkBpES93rGK6(DeEoCtIm(dYJmNl2oOpGTuAXyLTx32(7G(a2sPfJDGmLqMk2bmoeKoy5es8hKxAjVRYM045avZafmoeKgMysfwVltiTA8CGclwGskoYlNpveq1aqLft7iqsD)oysWLtjALThM2(7G(a2sPfJDGmLqMk2b6oB6C96GLtiXFqEPL8UkBsBiUOEgqnbqnhVbkSybkP4iVC(uravdavwmTJaj197aMysfwVltiTRS9A6T)ocKu3VJUkR1JooU4t7G(a2sPfJv2En12FhbsQ73bQT4cYeEw7j7G(a2sPfJv2En(2FhbsQ73rQmKhMcMSd6dylLwmwz7nVT)oOpGTuAXyhitjKPIDaJdbPHm0NXuD6C9avZaLtakuByCtmpKjqsDFybQjaQS6ghOWIfOGXHG0WetQW6DzcPvJNdu8cOWIfOq3ztNRxhSCcj(dYlTK3vztAdXf1ZaQgakyCiinKH(mMQt4MqQ7bQUduUrjGQzGkYGmLq6CtXfwF9mPEKW00hWwkbuyXcurgKPesNIhr(dYNOqA1M47cOMaOYcunduW4qq6u8iYFq(efsRoDUEGQzGczkXNJepc3yOxaQjaQUXBGclwGskoYlNpveq1aqnVDeiPUFhWHbMsEw7jRS9YY7T)ocKu3VdOdHZOKpYGmLqEyk42b9bSLslgRS9YMD7VJaj197ih3uqtR3Th2gmzh0hWwkTySY2l7CB)DeiPUFhO7r0lMqOKhYgC0oOpGTuAXyLTxwES93rGK6(DaBVl5piV0sE6jUP7G(a2sPfJv2Ez722FhbsQ73H0sE8h(W)Kh6miAh0hWwkTySY2llM2(7iqsD)oGdJjCt7G(a2sPfJv2EzB6T)oOpGTuAXyhitjKPID4eGc6q4mGQ7af6ycqndOGoeotBi30du8ebkNauO7SPZ1R7QSwp644IpPnexupdO6oqLfO4fqnbqfiPUx3vzTE0XXfFsJoMauyXcuO7SPZ1R7QSwp644IpPnexupdOMaOYcuZak3OeqHflqbJdbP5iUZm1FqEloQs(KHcoMgphO4fq1mqHUZMoxVURYA9OJJl(K2qCr9mGAcGk7ocKu3Vd0bBcpR9Kv2EzBQT)ocKu3VdwEjs9U9Od2e7G(a2sPfJv2EzB8T)oOpGTuAXyhitjKPIDGAdJBI5HmbsQ7dlqnbqLv3TDeiPUFhWHbMsEw7jRSYoWLYwY0T)2l72FhbsQ73b6WFHmEw7j7G(a2sPfJv2EZT93rGK6(DWid9Lm1NWzYoOpGTuAXyLThp2(7iqsD)oy5NH8i7HN2b9bSLslgRS9622FhbsQ73b7oPTE3ExHqMDqFaBP0IXkBpmT93rGK6(DWUVqEyBWKDqFaBP0IXkBVME7VJaj1974jPLmEw7H6Ah0hWwkTySY2RP2(7iqsD)oqTvMSyEXeFJfVSLmDh0hWwkTySY2RX3(7iqsD)oy5LPepR9qDTd6dylLwmwz7nVT)ocKu3VJpeCdX8UnbI2b9bSLslgRSYk7WzYWQ73EZX7SZJ3DlBtPNBoEWJD4kmF9Uz7it708K9YS9AmZhOaQ(TeqvC5NrakOZauygzPWzcZaLHAS4LHsaf74iGkWLJlekbuO24DtmnWrMPEcOYoFGYPU3zYiucOWCoj6mLoZ1AnMbk5akmN5ATgZaLtMRj8sdCKzQNaQ5Mpq5u37mzekbuyoNeDMsN5ATgZaLCafMZCTwJzGYjzBcV0ahzM6jGk7CZhOCQ7DMmcLakmNtIotPZCTwJzGsoGcZzUwRXmq5K5AcV0ahahzANMNSxMTxJz(afq1VLaQIl)mcqbDgGcZOedZaLHAS4LHsaf74iGkWLJlekbuO24DtmnWrMPEcOW08bkN6ENjJqjGcZ5KOZu6mxR1ygOKdOWCMR1AmduoHhnHxAGdGJmTtZt2lZ2RXmFGcO63savXLFgbOGodqHzMGzGYqnw8YqjGIDCeqf4YXfcLakuB8UjMg4iZupbuzNpq5u37mzekbuyoNeDMsN5ATgZaLCafMZCTwJzGYjZ1eEPboYm1ta18Mpq5u37mzekbuyoNeDMsN5ATgZaLCafMZCTwJzGYjZ1eEPboaoYSC5NrOeq10avGK6EGYwmHPbo2blNqBV5Wep2rU5GklTJgbuyqbtaQmXGjKzkqLjG)czaoAeq1ksoB(D64UKwCyn646WkoCBi19itajDyfhQdWrJakh42Pa18MeOMJ3zNhq1DGkB25pxwGdGJgbuovB8Uj28boAeq1DGYPtjkbuo1H)czaQr7jaLCavIGcCRaubsQ7bkBXenWrJaQUdu8eyeqjfh5LZNkcOCIZmnqjHXnjAP4iVC(ur8cOKdOIxkuLhcbu0NaQdcOOhD4VqgnWrJaQUduoDkbuPILtwwNCCJBIbuoxbqHlLTKPavGK6EGYwmrdCaC0iGINstieUqjGcMGodbuOJdoeGcMCxptduoncr5cdO(77EBy4GWTavGK6EgqDVDQg4OravGK6EMo3qOJdoe(q2G1fWrJaQaj19mDUHqhhCiZ43jWDZrVesDpWrJaQaj19mDUHqhhCiZ43b6UeWrGK6EMo3qOJdoKz87WW54U3NtcWrJaQXh5S2taktujGcghcIsaftcHbuWe0ziGcDCWHauWK76zav8jGk3qDp)ePE3avXaQ09Kg4OravGK6EMo3qOJdoKz87W(iN1EINjHWaocKu3Z05gcDCWHmJFN8tQ7bocKu3Z05gcDCWHmJFhxNXMCMQ3Bi29XJiGJaj19mDUHqhhCiZ43XnEysv8(dYhzqMtAbocKu3Z05gcDCWHmJFhoI7mt9hK3IJQKpzOGJbC0iGYPtzsCMWakPLaQeUjK6EGk(eqHUZMoxpqDqaLtZYjKauheqjTeqLPlBcOIpbu8unfxybQm7ZK6rcdOGNcuslbujCti19a1bbuXdu4FBWekbungNINgOC1spqjT0umBiGcNrjGk3qOJdoenq50mGYPpjtduTbdOcGkRMhmGQX4u80av8jGkGGiKWaQsyKfcOK2IbufdOYQZY0ahbsQ7z6CdHoo4qMXVtWYjK4piV0sExLnnzUHqbt8sXr8ZQZozbXNNJmitjKo3uCH1xptQhjmn9bSLsahncOC6uMeNjmGsAjGkHBcPUhOIpbuO7SPZ1duheqHbXKkSavM2eslqfFcOYeImiG6GakEYWnbuWtbkPLaQeUjK6EG6GaQ4bk8VnycLaQgJtXtduUAPhOKwAkMneqHZOeqLBi0XbhIg4iqsDptNBi0XbhYm(DGjMuH17Yes7K5gcfmXlfhXpRgttwq8JmitjKo3uCH1xptQhjmn9bSLsahahbsQ7zACPSLmLp6WFHmEw7jahbsQ7zACPSLmDg)omYqFjt9jCMaCeiPUNPXLYwY0z87WYpd5r2dpbCeiPUNPXLYwY0z87WUtAR3T3viKb4iqsDptJlLTKPZ43HDFH8W2GjahbsQ7zACPSLmDg)opjTKXZApuxahbsQ7zACPSLmDg)oO2ktwmVyIVXIx2sMcCeiPUNPXLYwY0z87WYltjEw7H6c4iqsDptJlLTKPZ435db3qmVBtGiGdGJgbu8uAcHWfkbuKZKzkqjfhbuslbubsodqvmGkCokBaBjnWrGK6EgFuyT(aj19EBXKj)GJ4JlLTKPtwq8temoeKgfmPE3A8CSytemoeKovSCYAdyl55c3fsJNJfBIGXHG0PILtwBaBjp9MWnPXZbocKu3ZMXVdoJ8LqCmGJaj19Sz87GcR1hiPU3BlMm5hCeFuIbCeiPUNnJFhuyT(aj19EBXKj)GJ4ZKjli(bskNjp9exrSgMd4iqsDpBg)oOWA9bsQ792Ijt(bhXhzPWzAYcIFGKYzYtpXveBISahahbsQ7zAuIXpEeXety9OWANSG4JUZMoxVgMysfwVltiTAdXf1ZMGh8g4iqsDptJsSz87avgc2ExAYcIp6oB6C9AyIjvy9UmH0QnexupBcEWBGJaj19mnkXMXVdmzyKPR6DpzbXhghcshSCcj(dYlTK3vztA88MDIuCKxoFQOjq3ztNRxdtggz6QE36eUjK6(zjCti19yX6ejmUjr3sHvA15iPbEGjSy5zjS0l6UkRLm(6zs9irtFaBPeV4fwSsXrE58PIAilpaocKu3Z0OeBg)oW27sEiCZ0jli(W4qq6GLtiXFqEPL8UkBsJN3StKIJ8Y5tfnb6oB6C9Ay7DjpeUzQoHBcPUFwc3esDpwSorcJBs0TuyLwDosAGhyclwEwcl9IURYAjJVEMups00hWwkXlEHfRuCKxoFQOgY20ahbsQ7zAuInJFhB5Uvy(mjEYnh9YKfe)Cs0Oq0W4qqAid9zmvJN3CojAuiAyCiinKH(mMQnexupBc3OKMlAcwS8CojAuiAyCiinKH(mMQXZbocKu3Z0OeBg)o5Nu3pzbXhghcsdtmPcR3LjKwnEEZW4qq6GLtiXFqEPL8UkBsJN3StKW4MeDlfwPvNJKg4bMWILNLWsVO7QSwY4RNj1Jen9bSLs8clwP4iVC(urnmhMaocKu3Z0OeBg)oUoJn5mvV3qS7Jhrtwq8HXHG02cIGT3L0mjqD1q3aocKu3Z0OeBg)oUXdtQI3Fq(idYCslWrGK6EMgLyZ43Xu55wYxVNLhic4iqsDptJsSz87WrCNzQ)G8wCuL8jdfCmGdGJaj19mnYsHZeF4WatjpR9KjrtrwYlHXnjm(zNSG4NtIgfIgghcsdzOpJPA88MZjrJcrdJdbPHm0NXuTH4I6znW3nkP5IMaCeiPUNPrwkCMMXVdhUvkw7jtwq8DJsAUOjDpNenkenmoeKgMcM4rwkCM0gIlQNnbV1ZHjGJaj19mnYsHZ0m(DGddmL8S2tMenfzjVeg3KW4NDYcIpeU16neQnmUjVuCudUrjnx0KMr3ztNRxdtmPcR3LjKwTH4I6zahbsQ7zAKLcNPz87eSCcj(dYlTK3vztahbsQ7zAKLcNPz87WKGlNs0KfeFyCiiDWYjK4piV0sExLnPXZBgghcsdtmPcR3LjKwnEowSsXrE58PIAilMaocKu3Z0ilfotZ43bMysfwVltiTtwq8r3ztNRxhSCcj(dYlTK3vztAdXf1Z8UXjgBI54nwSsyPx03tExL06LwYNhOU00hWwkHfRuCKxoFQOgYIjGJaj19mnYsHZ0m(DqTfxqMWZApb4iqsDptJSu4mnJFNWZHBsKXFqEK5CXaocKu3Z0ilfotZ43bomMWnbCeiPUNPrwkCMMXVtxL16rhhx8Pjli(bskNjp9exrSg6gwS8CKbzkH0MiVsEdzViPPpGTuc4iqsDptJSu4mnJFNuzipmfmb4iqsDptJSu4mnJFh4WatjpR9KjrtrwYlHXnjm(zNSG4NtIgfIgghcsdzOpJP6056B2jO2W4MyEitGK6(WorwDJJflmoeKgMysfwVltiTA8CEHfl6oB6C96GLtiXFqEPL8UkBsBiUOEwd5KOrHOHXHG0qg6ZyQoHBcPUV7UrPMJmitjKo3uCH1xptQhjmn9bSLsyXIAdJBI5HmbsQ7d7ez1DdlwP4iVC(urnmpGJaj19mnYsHZ0m(DGoeoJs(idYuc5HPGd4iqsDptJSu4mnJFNCCtbnTE3EyBWeGJaj19mnYsHZ0m(Dq3JOxmHqjpKn4iGJaj19mnYsHZ0m(DGT3L8hKxAjp9e3uGJaj19mnYsHZ0m(DKwYJ)Wh(N8qNbrtwq8HXHG0gc1LLymp0zqKgphlwyCiiTHqDzjgZdDge5rh(lKrZKa1vdz5nWrGK6EMgzPWzAg)oC4wPyTNmzbXpYGmLqAtKxjVHSxK00hWwk1CGKYzYtpXveBI5aocKu3Z0ilfotZ43bDWMWZApzYcIp6oB6C96UkR1JooU4tAdXf1ZMa6q4mTuCKxopx0KMDsGKYzYtpXveRbEGflphzqMsiTjYRK3q2lsA6dylL4fWrGK6EMgzPWzAg)oS8sK6D7rhSjaoaocKu3Z0mHpCyGPKN1EYKfe)Cs0Oq0W4qqAid9zmvJN3CojAuiAyCiinKH(mMQnexupRb(Urjnx0eSyHWTwVHqTHXn5LIJAWnkP5IM0m6oB6C9AyIjvy9UmH0Qnexupdl2idYucPZnfxy91ZK6rcttFaBPuZO7SPZ1RdwoHe)b5LwY7QSjTH4I6zn4gLaocKu3Z0mzg)oblNqI)G8sl5Dv2eWrGK6EMMjZ43j8C4Mez8hKhzoxmGJaj19mntMXVdtcUCkrtwq8HXHG0blNqI)G8sl5Dv2KgpVzyCiinmXKkSExMqA145yXkfh5LZNkQHSyc4iqsDptZKz87atmPcR3LjK2jli(O7SPZ1RdwoHe)b5LwY7QSjTH4I6ztmhVXIvkoYlNpvudzXeWrGK6EMMjZ43PRYA9OJJl(eWrGK6EMMjZ43b1wCbzcpR9eGJaj19mntMXVtQmKhMcMaCeiPUNPzYm(DGddmL8S2tMSG4NtIgfIgghcsdzOpJP6056B2jO2W4MyEitGK6(WorwDJJflmoeKgMysfwVltiTA8CEHfl6oB6C96GLtiXFqEPL8UkBsBiUOEwd5KOrHOHXHG0qg6ZyQoHBcPUV7UrPMJmitjKo3uCH1xptQhjmn9bSLsyXgzqMsiDkEe5piFIcPvBIVRjY2mmoeKofpI8hKprH0QtNRVzKPeFos8iCJHEzIUXBSyLIJ8Y5tf1W8aocKu3Z0mzg)oqhcNrjFKbzkH8WuWbCeiPUNPzYm(DYXnf006D7HTbtaocKu3Z0mzg)oO7r0lMqOKhYgCeWrGK6EMMjZ43b2ExYFqEPL80tCtbocKu3Z0mzg)osl5XF4d)tEOZGiGJaj19mntMXVdCymHBc4iqsDptZKz87Goyt4zTNmzbX3jqhcN1D0XKzqhcNPnKB65j6e0D20561DvwRhDCCXN0gIlQN19S8AIaj196UkR1JooU4tA0XeSyr3ztNRx3vzTE0XXfFsBiUOE2ezN5gLWIfghcsZrCNzQ)G8wCuL8jdfCmnEoVAgDNnDUEDxL16rhhx8jTH4I6ztKf4iqsDptZKz87WYlrQ3ThDWMa4iqsDptZKz87ahgyk5zTNmzbXh1gg3eZdzcKu3h2jYQ72kRSla]] )


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
