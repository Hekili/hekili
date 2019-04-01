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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
            end,
        },


    } )


    spec:RegisterPack( "Beast Mastery", 20190401.1442, [[dW0JSaqieKEKuj2eLQ(KsPgfcQtHqSkPscVcbMLuPULue7cPFjv1Wqu6ysfltkQNHqAAsr6AkvABsb13KcsJtQK6CkLyDkL08eb3JszFsHoicIfQu1druyIikQUOujrFerLAKikkNerLSskPzIOIUjII0ovkgkIIOLkvs6PkzQsvUkIIWxrufJfrfolIQAVQ8xrnyihwyXG8yOMmvDzuBguFwenAP0PLSAevPxRuXSPYTjLDRQFdmCr64sbXYP45KmDIRtQ2oLkFNsmEPaNhHA9IqZhr2VIVoxVB5dHVnnt2oBHSnLSDODAAt7S7TeIt5BLg4DIK8T(qJV1EouYGitdLWgIVvAqSde(R3TuaDdMVvRiPQT2VFYsA1HOyGwFvPP7cPap2eWsFvPH7Fli9YjKR)GULpe(20mz7SfY2uY2H2PPnTdrBO3k0LwG5wRsJmUvB598Fq3YZk8T6YG2ZHsgezAOe2q8GiZ0FHnJ1UmOwrsvBTF)KL0QdrXaT(Qst3fsbESjGL(Qsd3FS2LbriPMYnOoDpOMjBNTmOMmiYULT2P5X6yTldImAJpjR26yTldQjdIq8E2piYaO)cBg0QfidsadYZWHUtguGLc8dYvkHow7YGAYGitO4bjLgNfq2x8GiSDk6GKWKKfQuACwazFXezqcyqXlfUsdHhe)(bbGhe)yG(lSHow7YGAYGieVFq(sLYov)uDtswni7Qyq6s5kH4bfyPa)GCLsO3YvkrD9ULNHdDNC9UnDUE3I)aYX(B)TWMsytf3YZq6WWuCOK6ts1thejsdYZq6WWuFPszNlGCCwlswyQE6GirAqEgshgM6lvk7CbKJZ8BIKmvp9wbwkWFlC4C5alf4ZUsj3Yvkj)HgFlDPCLq8j3MMVE3kWsb(BPR4CjSM6w8hqo2F7p52q0R3T4pGCS)2FRalf4VfoCUCGLc8zxPKB5kLK)qJVf2Ro5200R3T4pGCS)2FlSPe2uXTcSu2Xz(zTIvdkHb18TcSuG)w4W5YbwkWNDLsULRus(dn(wk5KBZUxVBXFa5y)T)wytjSPIBfyPSJZ8ZAfRguJdQZTcSuG)w4W5YbwkWNDLsULRus(dn(wyhh2XNCYTsnmgObfY172056Dl(dih7V9NCBA(6Dl(dih7V9NCBi617w8hqo2F7p5200R3TcSuG)wkDnnWNtz5w8hqo2F7p52S717w8hqo2F7p520WxVBfyPa)Tsbsb(BXFa5y)T)KBtd96Dl(dih7V93k1W4qjzP04B1H25wbwkWFRqLYyjdGZslNTuo)TWMsytf3IqhuKiBkHPPMslC56vs9yrr5pGCS)KBtxF9Uf)bKJ93(BLAyCOKSuA8T6q39wbwkWFliwjv4YwmH0ElSPe2uXTIeztjmn1uAHlxVsQhlkk)bKJ9NCYTWooSJVE3MoxVBXFa5y)T)wytjSPIBbPddtHn8NiXu90bz)GG0HHPWg(tKyQH1I6vdkbBdkj2t1IgCRalf4VfuyGyFw1cKtUnnF9Uf)bKJ93(BHnLWMkUvsSNQfnyqnzqq6WWuiousg74WoMAyTOE1GACqKL28U3kWsb(BPP7Ks1cKtUne96Dl(dih7V93cBkHnvClyDNlByCBysYzP04bLWGsI9uTObdY(bHbaNhy5PqSsQWLTycPLAyTOE1TcSuG)wqHbI9zvlqo5200R3TcSuG)wHkLXsgaNLwoBPC(BXFa5y)T)KBZUxVBXFa5y)T)wytjSPIBbPddtdvkJLmaolTC2s58u90bz)GG0HHPqSsQWLTycPLQNoisKgKuACwazFXdkHb1z3BfyPa)TusOLYE(KBtdF9Uf)bKJ93(BHnLWMkUfgaCEGLNgQuglzaCwA5SLY5PgwlQxnOghuZKDqKiniP04SaY(IhucdQZU3kWsb(BbXkPcx2IjK2tUnn0R3TcSuG)w42slytKvTa5w8hqo2F7p5201xVBfyPa)TISMUXZMmaoJnalQBXFa5y)T)KBZwUE3kWsb(BbfgtKKVf)bKJ93(tUnDi717w8hqo2F7Vf2ucBQ4wbwk74m)SwXQbLWGA6GirAqe6GIeztjm1ePLpByhi8u(dih7VvGLc83ANY5YyGMw8(tUnD6C9UvGLc83YxgodXHsUf)bKJ93(tUnDA(6Dl(dih7V93cBkHnvCliDyykSH)ejM6bw(bz)Gi8GWTHjjRYWMalf4d3GACqDOD9GirAqq6WWuiwjv4YwmH0s1thergejsdcdaopWYtdvkJLmaolTC2s58udRf1RgucdcshgMcB4prIPEDtif4hutgusSFq2pOir2ucttnLw4Y1RK6XIIYFa5y)GirAqrISPeM6JhZzaC2ZH0snXVZGACqDgK9dcshgM6JhZzaC2ZH0s9al)GSFqkjek2uYGACqnLSdIePbjLgNfq2x8GsyqB5wbwkWFlOWaX(SQfiNCB6q0R3T4pGCS)2FlSPe2uXTIeztjm1ePLpByhi8u(dih7hK9dkWszhN5N1kwnOghuZ3kWsb(BPP7Ks1cKtUnDA617w8hqo2F7Vf2ucBQ4wyaW5bwE6oLZLXanT49udRf1RguJdcgG1vuP04SaYArdgK9dIWdkWszhN5N1kwnOegerhejsdIqhuKiBkHPMiT8zd7aHNYFa5y)GiYTcSuG)wyaKjYQwGCYTPZUxVBfyPa)TuPLi1NmJbqM4w8hqo2F7p520PHVE3I)aYX(B)TWMsytf3ksKnLWutKw(SHDGWt5pGCSFq2pOalLDCMFwRy1GACqnFRalf4VLMUtkvlqo5KBH9QR3TPZ17w8hqo2F7Vf2ucBQ4wyaW5bwEkeRKkCzlMqAPgwlQxnOgherj7TcSuG)wXJzLycxgho3j3MMVE3I)aYX(B)TWMsytf3cdaopWYtHyLuHlBXesl1WAr9Qb14GikzVvGLc83cUmmKda8NCBi617w8hqo2F7Vf2ucBQ4wq6WW0qLYyjdGZslNTuopvpDq2picpiP04SaY(IhuJdcdaopWYtHyJIn7uFsQx3esb(brWG86MqkWpisKgeHhKeMKSqB5WjT0uSmOeger3DqKinicDqs44xO7uohBY1RK6XcL)aYX(brKbrKbrI0GKsJZci7lEqjmOoe9wbwkWFli2OyZo1N8KBttVE3I)aYX(B)TWMsytf3cshgMgQuglzaCwA5SLY5P6PdY(br4bjLgNfq2x8GACqyaW5bwEkKda8zyDdXuVUjKc8dIGb51nHuGFqKinicpijmjzH2YHtAPPyzqjmiIU7GirAqe6GKWXVq3PCo2KRxj1Jfk)bKJ9dIidIidIePbjLgNfq2x8GsyqDA4BfyPa)TGCaGpdRBi(KBZUxVBXFa5y)T)wytjSPIBbPddtHn8NiXu90bz)GG0HHPWg(tKyQH1I6vdQXbLe7PArdgejsdIqheKommf2WFIet1tVvGLc83YvjBfvM8Q7tQXVCYTPHVE3I)aYX(B)TWMsytf3cshgMcXkPcx2IjKwQE6GSFqq6WW0qLYyjdGZslNTuopvpDq2picpijmjzH2YHtAPPyzqjmiIU7GirAqe6GKWXVq3PCo2KRxj1Jfk)bKJ9dIidIePbjLgNfq2x8GsyqnV7TcSuG)wPaPa)jNClLC9UnDUE3I)aYX(B)TWMsytf3cshgMcB4prIP6PdY(bbPddtHn8NiXudRf1Rguc2gusSNQfnyqKiniyDNlByCBysYzP04bLWGsI9uTObdY(bHbaNhy5PqSsQWLTycPLAyTOE1GirAqrISPeMMAkTWLRxj1JffL)aYX(bz)GWaGZdS80qLYyjdGZslNTuop1WAr9QbLWGsI93kWsb(Bbfgi2NvTa5KBtZxVBfyPa)TcvkJLmaolTC2s583I)aYX(B)j3gIE9UvGLc83kYA6gpBYa4m2aSOUf)bKJ93(tUnn96Dl(dih7V93cBkHnvCliDyyAOszSKbWzPLZwkNNQNoi7heKommfIvsfUSftiTu90brI0GKsJZci7lEqjmOo7ERalf4VLscTu2ZNCB296Dl(dih7V93cBkHnvClma48alpnuPmwYa4S0YzlLZtnSwuVAqnoOMj7GirAqsPXzbK9fpOeguNDVvGLc83cIvsfUSftiTNCBA4R3TcSuG)w7uoxgd00I3Fl(dih7V9NCBAOxVBfyPa)TWTLwWMiRAbYT4pGCS)2FYTPRVE3kWsb(B5ldNH4qj3I)aYX(B)j3MTC9Uf)bKJ93(BHnLWMkUfKommf2WFIet9al)GSFqeEq42WKKvzytGLc8HBqnoOo0UEqKiniiDyykeRKkCzlMqAP6PdIidIePbHbaNhy5PHkLXsgaNLwoBPCEQH1I6vdkHbbPddtHn8NiXuVUjKc8dQjdkj2pi7huKiBkHPPMslC56vs9yrr5pGCSFqKiniP04SaY(IhucdAl3kWsb(Bbfgi2NvTa5KBthYE9UvGLc83ckmMijFl(dih7V9NCB6056Dl(dih7V93cBkHnvClcpiyawxnOMmimqjdIGbbdW6kQHtY)G6kgeHhegaCEGLNUt5CzmqtlEp1WAr9Qb1Kb1zqezqnoOalf4P7uoxgd00I3tXaLmisKgegaCEGLNUt5CzmqtlEp1WAr9Qb14G6micgusSFqezq2pima48alpDNY5YyGMw8EQH1I6vdQXb15wbwkWFlmaYezvlqo520P5R3TcSuG)wQ0sK6tMXaitCl(dih7V9NCB6q0R3T4pGCS)2FlSPe2uXTWTHjjRYWMalf4d3GACqDOn9wbwkWFlOWaX(SQfiNCYT0LYvcXxVBtNR3TcSuG)wyG(lSjRAbYT4pGCS)2FYTP5R3TcSuG)wk2WFjeN96k5w8hqo2F7p52q0R3TcSuG)wQuGHZyhq3Fl(dih7V9NCBA617wbwkWFlfaiT1NmBje2Cl(dih7V9NCB296DRalf4VLc8fod5cLCl(dih7V9NCBA4R3TcSuG)wplTSjRAb4DUf)bKJ93(tUnn0R3TcSuG)w42I8wQSyIVHOxUsi(w8hqo2F7p5201xVBfyPa)TuPLPKSQfG35w8hqo2F7p52SLR3TcSuG)wFi6gwLtAcmFl(dih7V9NCYj3Yo2OkWFBAMSD2czBU5gM2mr3Dl3Ysy(6tQUf5Hq6QBixBi3BDqdQxlpOslfyKbbdmdABSJd74ThKHBi6LH9dsb04bf6cqle2piCB8jzfDSsoRNhuNToiYa82XgH9dA7uwOKdk5tP0ThKag02KpLs3EqeU5gqe6yLCwppOM36GidWBhBe2pOTtzHsoOKpLs3EqcyqBt(ukD7br4onGi0Xk5SEEqDAERdImaVDSry)G2oLfk5Gs(ukD7bjGbTn5tP0TheHBUbeHowhRKhcPRUHCTHCV1bnOET8GkTuGrgemWmOTXE12dYWne9YW(bPaA8GcDbOfc7heUn(KSIowjN1ZdA3ToiYa82XgH9dA7uwOKdk5tP0ThKag02KpLs3EqeMOnGi0X6yL8qiD1nKRnK7ToOb1RLhuPLcmYGGbMbTTs2EqgUHOxg2pifqJhuOlaTqy)GWTXNKv0Xk5SEEqD26GidWBhBe2pOTtzHsoOKpLs3EqcyqBt(ukD7br4MBarOJvYz98G2YwhezaE7yJW(bTDkluYbL8Pu62dsadABYNsPBpic3CdicDSowjxAPaJW(b1WdkWsb(b5kLOOJ1BLAaWLJVvxg0EouYGitdLWgIhezM(lSzS2Lb1ksQAR97NSKwDikgO1xvA6UqkWJnbS0xvA4(J1Umicj1uUb1P7b1mz7SLb1Kbr2TS1onpwhRDzqKrB8jz1whRDzqnzqeI3Z(brga9xyZGwTazqcyqEgo0DYGcSuGFqUsj0XAxgutgezcfpiP04SaY(IheHTtrhKeMKSqLsJZci7lMidsadkEPWvAi8G43pia8G4hd0FHn0XAxgutgeH49dYxQu2P6NQBsYQbzxfdsxkxjepOalf4hKRucDSow7YG6kBaJ1f2piiggy4bHbAqHmiioz9k6GiemMtf1GEW3K2WObR7guGLc8QbbEhX0XAGLc8kAQHXanOqSb7c1oJ1alf4v0udJbAqHqGT(HEsn(LqkWpwdSuGxrtnmgObfcb26dda(XAGLc8kAQHXanOqiWwFLUMg4ZPSmw7YGwFKQAbYGmr5heKomm7hKscrniiggy4bHbAqHmiioz9QbfVFqPgUjParQp5Gk1G8GNPJ1alf4v0udJbAqHqGT(QpsvTajRKquJ1alf4v0udJbAqHqGT(PaPa)yTldIq8KxDLOgK0YdYRBcPa)GI3pima48al)GaWdIquPmwgeaEqslpiYt58dkE)GitAkTWniY1RK6XIAqqepiPLhKx3esb(bbGhu8ds)BdLW(brUjdY8bzPL)bjTmXBB4bPRy)GsnmgObfcDqeIAqecqipdQnudkguhkrvdICtgK5dkE)GcyyglQbvIIDWdsAl1Gk1G6q7OOJ1alf4v0udJbAqHqGT(HkLXsgaNLwoBPC(Utnmouswkn2whANUlyBeAKiBkHPPMslC56vs9yrr5pGCSFS2LbriEYRUsudsA5b51nHuGFqX7hegaCEGLFqa4bTNvsfUbrEmH0oO49dImlsKheaEqD1ijpiiIhK0YdYRBcPa)GaWdk(bP)THsy)Gi3Kbz(GS0Y)GKwM4Tn8G0vSFqPggd0GcHowdSuGxrtnmgObfcb26dXkPcx2IjK2Utnmouswkn2wh6UDxW2Ieztjmn1uAHlxVsQhlkk)bKJ9J1XAGLc8kQUuUsi2ggO)cBYQwGmwdSuGxr1LYvcXeyRVIn8xcXzVUsgRbwkWRO6s5kHycS1xLcmCg7a6(XAGLc8kQUuUsiMaB9vaG0wFYSLqyZynWsbEfvxkxjetGT(kWx4mKluYynWsbEfvxkxjetGT(plTSjRAb4DgRbwkWRO6s5kHycS1h3wK3sLft8ne9YvcXJ1alf4vuDPCLqmb26RsltjzvlaVZynWsbEfvxkxjetGT(Fi6gwLtAcmpwhRDzqDLnGX6c7heBhBiEqsPXdsA5bfybyguPguyxuUaYX0XAGLc8kB4W5YbwkWNDLs6(dn2MUuUsiU7c2MNH0HHP4qj1NKQNsIKNH0HHP(sLYoxa54SwKSWu9usK8mKomm1xQu25cihN53ejzQE6ynWsbEfb26RR4CjSMASgyPaVIaB9XHZLdSuGp7kL09hASnSxnwdSuGxrGT(4W5YbwkWNDLs6(dn2Ms6UGTfyPSJZ8ZAfRsO5XAGLc8kcS1hhoxoWsb(SRus3FOX2WooSJ7UGTfyPSJZ8ZAfRASZyDSgyPaVII9kBXJzLycxghox3fSnma48alpfIvsfUSftiTudRf1RAKOKDSgyPaVII9kcS1hUmmKda8DxW2WaGZdS8uiwjv4YwmH0snSwuVQrIs2XAGLc8kk2RiWwFi2OyZo1NS7c2gKommnuPmwYa4S0YzlLZt1tTNWsPXzbK9f3igaCEGLNcXgfB2P(KuVUjKc8e41nHuGNejclHjjl0woCslnfljq0DjrIqLWXVq3PCo2KRxj1Jfk)bKJ9eHiKijLgNfq2xCcDi6ynWsbEff7veyRpKda8zyDdXDxW2G0HHPHkLXsgaNLwoBPCEQEQ9ewknolGSV4gXaGZdS8uiha4ZW6gIPEDtif4jWRBcPapjsewctswOTC4KwAkwsGO7sIeHkHJFHUt5CSjxVsQhlu(dih7jcrirsknolGSV4e60WJ1alf4vuSxrGT(UkzROYKxDFsn(LUlyBPSqXHqH0HHPWg(tKyQEQ9PSqXHqH0HHPWg(tKyQH1I6vnMe7PArdirIqtzHIdHcPddtHn8NiXu90XAGLc8kk2RiWw)uGuGV7c2gKommfIvsfUSftiTu9u7H0HHPHkLXsgaNLwoBPCEQEQ9ewctswOTC4KwAkwsGO7sIeHkHJFHUt5CSjxVsQhlu(dih7jcjssPXzbK9fNqZ7owhRbwkWROyhh2X2Gcde7ZQwG0DbBlLfkoekKommf2WFIet1tTpLfkoekKommf2WFIetnSwuVkbBjXEQw0GXAGLc8kk2XHDmb26RP7Ks1cKUlyBjXEQw0GMKYcfhcfshgMcXHsYyhh2XudRf1RAKS0M3DSgyPaVIIDCyhtGT(qHbI9zvlq6UGTbR7CzdJBdtsolLgNqsSNQfnWEma48alpfIvsfUSftiTudRf1RgRbwkWROyhh2XeyRFOszSKbWzPLZwkNFSgyPaVIIDCyhtGT(kj0szp3DbBdshgMgQuglzaCwA5SLY5P6P2dPddtHyLuHlBXeslvpLejP04SaY(ItOZUJ1alf4vuSJd7ycS1hIvsfUSftiTDxW2WaGZdS80qLYyjdGZslNTuop1WAr9QgBMSKijLgNfq2xCcD2DSgyPaVIIDCyhtGT(42slytKvTazSgyPaVIIDCyhtGT(rwt34ztgaNXgGf1ynWsbEff74WoMaB9HcJjsYJ1alf4vuSJd7ycS1FNY5YyGMw8(UlyBbwk74m)SwXQeAkjseAKiBkHPMiT8zd7aHNYFa5y)ynWsbEff74WoMaB99LHZqCOKXAGLc8kk2XHDmb26dfgi2NvTaP7c2wkluCiuiDyykSH)ejM6bwE7jmUnmjzvg2eyPaF4ASdTRjrcshgMcXkPcx2IjKwQEkrircdaopWYtdvkJLmaolTC2s58udRf1RsiLfkoekKommf2WFIet96MqkW3KKyV9rISPeMMAkTWLRxj1JffL)aYXEsKIeztjm1hpMZa4SNdPLAIFNg7ypKomm1hpMZa4SNdPL6bwE7vsiuSPKgBkzjrsknolGSV4e2YynWsbEff74WoMaB910DsPAbs3fSTir2uctnrA5Zg2bcpL)aYXE7dSu2Xz(zTIvn28ynWsbEff74WoMaB9XaitKvTaP7c2ggaCEGLNUt5CzmqtlEp1WAr9QgHbyDfvknolGSw0a7jCGLYooZpRvSkbIsIeHgjYMsyQjslF2Woq4P8hqo2tKXAGLc8kk2XHDmb26RslrQpzgdGmXynWsbEff74WoMaB910DsPAbs3fSTir2uctnrA5Zg2bcpL)aYXE7dSu2Xz(zTIvn28yDSgyPaVIQeBqHbI9zvlq6UGTLYcfhcfshgMcB4prIP6P2NYcfhcfshgMcB4prIPgwlQxLGTKypvlAajsW6ox2W42WKKZsPXjKe7PArdShdaopWYtHyLuHlBXesl1WAr9ksKIeztjmn1uAHlxVsQhlkk)bKJ92JbaNhy5PHkLXsgaNLwoBPCEQH1I6vjKe7hRbwkWROkHaB9dvkJLmaolTC2s58J1alf4vuLqGT(rwt34ztgaNXgGf1ynWsbEfvjeyRVscTu2ZDxW2G0HHPHkLXsgaNLwoBPCEQEQ9q6WWuiwjv4YwmH0s1tjrsknolGSV4e6S7ynWsbEfvjeyRpeRKkCzlMqA7UGTHbaNhy5PHkLXsgaNLwoBPCEQH1I6vn2mzjrsknolGSV4e6S7ynWsbEfvjeyR)oLZLXanT49J1alf4vuLqGT(42slytKvTazSgyPaVIQecS13xgodXHsgRbwkWROkHaB9Hcde7ZQwG0DbBlLfkoekKommf2WFIet9alV9eg3gMKSkdBcSuGpCn2H21KibPddtHyLuHlBXeslvpLiKiHbaNhy5PHkLXsgaNLwoBPCEQH1I6vjKYcfhcfshgMcB4prIPEDtif4BssS3(ir2ucttnLw4Y1RK6XIIYFa5ypjssPXzbK9fNWwgRbwkWROkHaB9HcJjsYJ1alf4vuLqGT(yaKjYQwG0DbBJWWaSUQjyGsiagG1vudNK)UccJbaNhy5P7uoxgd00I3tnSwuVQjDisJbwkWt3PCUmgOPfVNIbkHejma48alpDNY5YyGMw8EQH1I6vn2HGKyprShdaopWYt3PCUmgOPfVNAyTOEvJDgRbwkWROkHaB9vPLi1NmJbqMySgyPaVIQecS1hkmqSpRAbs3fSnCBysYQmSjWsb(W1yhAtVLkLX3MM3LONCYDa]] )


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
