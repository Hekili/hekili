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


    spec:RegisterPack( "Beast Mastery", 20190226.2359, [[d0ukSaqiisEKurTjPcFsPkJcIQtbrzvsfP8ki0SKk1TOe1Ui8lPOHre6ykvwMi4zebttesxtPW2Gi6BkfPXPueNJisRtPOMNiY9OuTpPsoireluP0dHi1eHiOlcraBeIa9rkr0ijIQojLizLukZKseUjruANsvnuicTuPI4PkzQsvUQurQ(krumwkrQZkcXEv5VIAWqDyHfdYJrmzQ6YO2mO(Suy0sPtlz1erLxRuvZMk3gs7g43QA4I0XLkswofphPPt66e12Pe(oL04fH68qW6frnFI0(v8T76DlFO81pbjUtsLycjSPcjkrjMGet0BPiKY3kni7hn4Bbcu(wB5GQdwYguLniCR0ab3h(R3TOVSHW3Qv1u6MB2SrPTYqcYJ2KwOYUqRhqmbS2KwOKMqUhQjeCyzpBrZuZdxoM2ejA4ojkpTjsStYsEzGYM8woOAwYguLniiOfk5wqYLtTuGd6w(q5RFcsCNKkXesajfjiHn20DB6TczT9n3AvOi9TAlVNbh0T8mLCRop4TCq1blzdQYgegSKxgOSzS15b3QAkDZnB2O0wzib5rBsluzxO1diMawBslusti3d1ecoSSNTOzQ5HlhtBIenCNeLN2ej2jzjVmqztElhunlzdQYgee0cLm268GrcYqg5WGWGtaj7EWjiXDs6GT8GtqcBEdKCSn268Gr62a0GPBES15bB5bljEp7hms)YaLndE1(6G1FWEgoKD6GdIwpyWUIQIXwNhSLhCNoLhSwOCw)SV4bJClOIbRHPbRcTq5S(zFXiBW6p4aOfPsdLhmd8d(HhmdiVmqzJyS15bB5bljE)G9fnLD0MPYMgmDWwuXGL1YvkcdoiA9Gb7kQkULROk96DlpdhYo96D93D9Ufdcih7VT3IykLnvClpdjddlibvlqdHC6GLkDWEgsggw4lAk7CbKJZOrJIiKthSuPd2ZqYWWcFrtzNlGCCMbMOblKtVvq06b3IeoxoiA9GSRO6TCfvZGaLVLSwUsr40RFcxVBfeTEWTKPCUugLElgeqo2FBp96lHR3Tyqa5y)T9wbrRhCls4C5GO1dYUIQ3Yvundcu(wep90RFIE9Ufdcih7VT3IykLnvCRGOLfCMbmAX0bN0Gt4wbrRhCls4C5GO1dYUIQ3Yvundcu(wu90R)gxVBXGaYX(B7TiMsztf3kiAzbNzaJwmDWDn4D3kiA9GBrcNlheTEq2vu9wUIQzqGY3I44Wc(0tVvQHjpkuOxVR)UR3Tyqa5y)T90RFcxVBXGaYX(B7PxFjC9Ufdcih7VTNE9t0R3TcIwp4wuzu0hKtz9wmiGCS)2E61FJR3Tyqa5y)T90RpsE9Uvq06b3k916b3IbbKJ932tV(B617wmiGCS)2ERudtcQM1cLV1oXUBfeTEWTcAkt08dN1woBTC(BrmLYMkUfsn4iz2uklsnfA4YfGQfGOubdcih7p96VjxVBXGaYX(B7TsnmjOAwlu(w7eBCRGO1dUfet1kCzRMqBVfXukBQ4wrYSPuwKAk0WLlavlarPcgeqo2F6P3I44Wc(6D93D9Ufdcih7VT3IykLnvClizyybSHbjJGqoDWDmyizyybSHbjJGWWOrbOdoj7dUbXlqJeFRGO1dUfuyGyFM2(6Px)eUE3IbbKJ932BrmLYMkUvdIxGgjEWwEWqYWWcioOAM44Wcwyy0Oa0b31GLOiHnUvq06b3cv2PfT91tV(s46Dlgeqo2FBVfXukBQ4wWYox2WK2W0GZAHYdoPb3G4fOrIhChdM8VZ)wbciMQv4YwnH2kmmAua6TcIwp4wqHbI9zA7RNE9t0R3TcIwp4wbnLjA(HZAlNTwo)Tyqa5y)T90R)gxVBXGaYX(B7TiMsztf3csggwe0uMO5hoRTC2A58c50b3XGHKHHfqmvRWLTAcTviNoyPshSwOCw)SV4bN0G3TXTcIwp4wunqtzpF61hjVE3IbbKJ932BrmLYMkUf5FN)TcebnLjA(HZAlNTwoVWWOrbOdURbNGehSuPdwluoRF2x8GtAW724wbrRhCliMQv4YwnH2E61FtVE3kiA9GBrAl0GnrM2(6Tyqa5y)T90R)MC9Uvq06b3kYOYgpBYpCMyER0BXGaYX(B7PxFj96DRGO1dUfuymrd(wmiGCS)2E61FNeVE3IbbKJ932BrmLYMkUvq0YcoZagTy6GtAWj6GLkDWi1GJKztPSWePLpBy3hEbdcih7Vvq06b3A)Y5YKhfna(tV(72D9Uvq06b3YxgodXbvVfdcih7VTNE93LW17wmiGCS)2ElIPu2uXTGKHHfWggKmcc)Bfm4ogmYhmPnmnyAg2eeTEq4gCxdENytgSuPdgsggwaXuTcx2Qj0wHC6Gr2GLkDWK)D(3kqe0uMO5hoRTC2A58cdJgfGo4KgmKmmSa2WGKrq4LnHwpyWwEWni(b3XGJKztPSi1uOHlxaQwaIsfmiGCSFWsLoyTq5S(zFXdoPblP3kiA9GBbfgi2NPTVE61FNeUE3IbbKJ932BrmLYMkUvKmBkLfMiT8zd7(Wlyqa5y)G7yWbrll4mdy0IPdURbNWTcIwp4wOYoTOTVE61FxIE9Ufdcih7VT3IykLnvClY)o)Bfi2VCUm5rrdGxyy0Oa0b31GHFImvOfkN1pJgjEWDmyKp4GOLfCMbmAX0bN0GLWGLkDWi1GJKztPSWePLpBy3hEbdcih7hmYUvq06b3I8qMitBF90R)UnUE3kiA9GBrtlvlqJm5HmXTyqa5y)T90R)oK86Dlgeqo2FBVfXukBQ4wrYSPuwyI0YNnS7dVGbbKJ9dUJbheTSGZmGrlMo4UgCc3kiA9GBHk70I2(6PNElINE9U(7UE3IbbKJ932BrmLYMkUf5FN)TceqmvRWLTAcTvyy0Oa0b31GLGeVvq06b3kaeMQMWLjHZD61pHR3Tyqa5y)T9wetPSPIBr(35FRabet1kCzRMqBfggnkaDWDnyjiXBfeTEWTGldd5(3F61xcxVBXGaYX(B7TiMsztf3csggwe0uMO5hoRTC2A58c50b3XGr(G1cLZ6N9fp4Ugm5FN)TceqSHYM9lqdHx2eA9GbJ4G9YMqRhmyPshmYhSgMgSkA5WPTIuIo4KgSe2yWsLoyKAWA4yGk2VCo2KlavlarfmiGCSFWiBWiBWsLoyTq5S(zFXdoPbVtc3kiA9GBbXgkB2Vano96NOxVBXGaYX(B7TiMsztf3csggwe0uMO5hoRTC2A58c50b3XGr(G1cLZ6N9fp4Ugm5FN)TceqU)9zyzdccVSj06bdgXb7LnHwpyWsLoyKpynmnyv0YHtBfPeDWjnyjSXGLkDWi1G1WXavSF5CSjxaQwaIkyqa5y)Gr2Gr2GLkDWAHYz9Z(IhCsdEhsERGO1dUfK7FFgw2GWPx)nUE3IbbKJ932BrmLYMkUfKmmSa2WGKrqiNo4ogmKmmSa2WGKrqyy0Oa0b31GBq8c0iXdwQ0bJudgsggwaByqYiiKtVvq06b3YvnAvAwYj7BGYa90RpsE9Ufdcih7VT3IykLnvClizyybet1kCzRMqBfYPdUJbdjddlcAkt08dN1woBTCEHC6G7yWiFWAyAWQOLdN2ksj6GtAWsyJblv6GrQbRHJbQy)Y5ytUauTaevWGaYX(bJSblv6G1cLZ6N9fp4KgCcBCRGO1dUv6R1do90Br1R31F317wmiGCS)2ElIPu2uXTGKHHfWggKmcc50b3XGHKHHfWggKmccdJgfGo4KSp4geVans8GLkDWWYox2WK2W0GZAHYdoPb3G4fOrIhChdM8VZ)wbciMQv4YwnH2kmmAua6GLkDWrYSPuwKAk0WLlavlarPcgeqo2p4ogm5FN)TcebnLjA(HZAlNTwoVWWOrbOdoPb3G4Vvq06b3ckmqSptBF90RFcxVBfeTEWTcAkt08dN1woBTC(BXGaYX(B7PxFjC9Uvq06b3kYOYgpBYpCMyER0BXGaYX(B7Px)e96Dlgeqo2FBVfXukBQ4wqYWWIGMYen)WzTLZwlNxiNo4ogmKmmSaIPAfUSvtOTc50blv6G1cLZ6N9fp4Kg8UnUvq06b3IQbAk75tV(BC9Ufdcih7VT3IykLnvClY)o)BficAkt08dN1woBTCEHHrJcqhCxdobjoyPshSwOCw)SV4bN0G3TXTcIwp4wqmvRWLTAcT90RpsE9Uvq06b3A)Y5YKhfna(BXGaYX(B7Px)n96DRGO1dUfPTqd2ezA7R3IbbKJ932tV(BY17wbrRhClFz4mehu9wmiGCS)2E61xsVE3IbbKJ932BrmLYMkUfKmmSa2WGKrq4FRGb3XGr(GjTHPbtZWMGO1dc3G7AW7eBYGLkDWqYWWciMQv4YwnH2kKthmYgSuPdM8VZ)wbIGMYen)WzTLZwlNxyy0Oa0bN0GHKHHfWggKmccVSj06bd2YdUbXp4ogCKmBkLfPMcnC5cq1cquQGbbKJ9dwQ0bRfkN1p7lEWjnyj9wbrRhClOWaX(mT91tV(7K417wbrRhClOWyIg8Tyqa5y)T90R)UDxVBXGaYX(B7TiMsztf3c5dg(jY0bB5btEQoyehm8tKPcd3GbdUtBWiFWK)D(3kqSF5CzYJIgaVWWOrbOd2YdE3Gr2G7AWbrRhi2VCUm5rrdGxqEQoyPshm5FN)Tce7xoxM8OObWlmmAua6G7AW7gmIdUbXpyKn4ogm5FN)Tce7xoxM8OObWlmmAua6G7AW7Uvq06b3I8qMitBF90R)UeUE3kiA9GBrtlvlqJm5HmXTyqa5y)T90tVLSwUsr46D93D9Uvq06b3I8YaLnzA7R3IbbKJ932tV(jC9Uvq06b3IYggukczVmvVfdcih7VTNE9LW17wbrRhClA6B4mX9Y(BXGaYX(B7Px)e96DRGO1dUf9FTTanYwdLn3IbbKJ932tV(BC9Uvq06b3I(GIKHCbvVfdcih7VTNE9rYR3TcIwp4wawBztM2(K9Vfdcih7VTNE930R3TcIwp4wK2sYv0SAcqNsUCLIWTyqa5y)T90R)MC9Uvq06b3IMwMsZ02NS)Tyqa5y)T90RVKE9Uvq06b3ceQSHP5gMGW3IbbKJ932tp90BzbBO1dU(jiXDsQety3MkKOeL4g3YAyafOb9wsgjPt6BP6Bj38GhCVwEWfA6B0bd)MbVhXXHf8Ed2WDk5YW(btFuEWHS(OHY(btAdqdMkgBwIcWdE3Mhms)alyJY(bVxkRclTirecXEdw)bVxIieI9gmYtiXitm2SefGhCcBEWi9dSGnk7h8EPSkS0Ierie7ny9h8EjIqi2BWiFxIrMySzjkap4DjS5bJ0pWc2OSFW7LYQWslseHqS3G1FW7LicHyVbJ8esmYeJTXMKrs6K(wQ(wYnp4b3RLhCHM(gDWWVzW7r809gSH7uYLH9dM(O8Gdz9rdL9dM0gGgmvm2SefGh8gBEWi9dSGnk7h8EPSkS0Ierie7ny9h8EjIqi2BWixcjgzIX2ytYijDsFlvFl5Mh8G71YdUqtFJoy43m49O6Ed2WDk5YW(btFuEWHS(OHY(btAdqdMkgBwIcWdE3Mhms)alyJY(bVxkRclTirecXEdw)bVxIieI9gmYtiXitm2SefGhSKU5bJ0pWc2OSFW7LYQWslseHqS3G1FW7LicHyVbJ8esmYeJTXMLcn9nk7hmso4GO1dgSROkvm2UfnLjx)e2qc3k18WLJVvNh8woO6GLSbvzdcdwYldu2m268GBvnLU5MnBuARmKG8OnPfQSl06betaRnPfkPjK7HAcbhw2Zw0m18WLJPnrIgUtIYtBIe7KSKxgOSjVLdQMLSbvzdccAHsgBDEWibziJCyqyWjGKDp4eK4ojDWwEWjiHnVbso2gBDEWiDBaAW0np268GT8GLeVN9dgPFzGYMbVAFDW6pypdhYoDWbrRhmyxrvXyRZd2YdUtNYdwluoRF2x8GrUfuXG1W0GvHwOCw)SVyKny9hCa0IuPHYdMb(b)WdMbKxgOSrm268GT8GLeVFW(IMYoAZuztdMoylQyWYA5kfHbheTEWGDfvfJTXwNhmsGeZezL9dgIHFdpyYJcf6GH4gfGkgSKqiCQshm4bwUnmOWYUbheTEaDWpWHGySfeTEavKAyYJcfQDyxq3FSfeTEavKAyYJcfkI2BgYnqzGgA9GXwq06burQHjpkuOiAVj8)(Xwq06burQHjpkuOiAVjvgf9b5uwhBDEWlqKsBFDWMO8dgsggM9dMQHshmed)gEWKhfk0bdXnkaDWbWp4udB50x1c0yWfDW(hWIXwq06burQHjpkuOiAVjfeP02xZunu6yliA9aQi1WKhfkueT3m916bJTopyjXl5KPkDWAlpyVSj06bdoa(bt(35FRGb)WdwsOPmrh8dpyTLhSKPC(bha)GrIMcnCd2sbOAbikDWqimyTLhSx2eA9Gb)Wdoadwg0guL9d2sI0iHd2AldgS2YiSNHhSmL9do1WKhfkuXGLe6GLKxLmdUnOdog8oHeOd2sI0iHdoa(bhWWmrPdUuk7GhS2w0bx0bVtSJkgBbrRhqfPgM8OqHIO9MbnLjA(HZAlNTwoF3PgMeunRfkBFNyx3fSDKksMnLYIutHgUCbOAbikvWGaYX(XwNhSK4LCYuLoyTLhSx2eA9Gbha)Gj)78VvWGF4bVLPAfUblzmH2o4a4hSKpsMh8dp4ojAWdgcHbRT8G9YMqRhm4hEWbyWYG2GQSFWwsKgjCWwBzWG1wgH9m8GLPSFWPgM8OqHkgBbrRhqfPgM8OqHIO9MqmvRWLTAcTT7udtcQM1cLTVtSr3fS9iz2uklsnfA4YfGQfGOubdcih7hBJTGO1dOczTCLIGDYldu2KPTVo2cIwpGkK1YvkciAVjLnmOueYEzQo2cIwpGkK1YvkciAVjn9nCM4Ez)yliA9aQqwlxPiGO9M0)12c0iBnu2m2cIwpGkK1YvkciAVj9bfjd5cQo2cIwpGkK1YvkciAVjG1w2KPTpz)Xwq06buHSwUsrar7njTLKROz1eGoLC5kfHXwq06buHSwUsrar7nPPLP0mT9j7p2cIwpGkK1YvkciAVjiuzdtZnmbHhBJTopyKajMjYk7hmBbBqyWAHYdwB5bhe9ndUOdoSikxa5yXyliA9aQDs4C5GO1dYUIQDdcu2USwUsrO7c2UNHKHHfKGQfOHqovQupdjddl8fnLDUaYXz0OrreYPsL6zizyyHVOPSZfqooZat0GfYPJTGO1dOiAVPmLZLYO0Xwq06bueT3KeoxoiA9GSROA3GaLTt80Xwq06bueT3KeoxoiA9GSROA3GaLTt1Uly7brll4mdy0IPjLWyliA9akI2BscNlheTEq2vuTBqGY2jooSG7UGTheTSGZmGrlM21UX2yliA9aQG4P2daHPQjCzs4CDxW2j)78VvGaIPAfUSvtOTcdJgfG2LeK4yliA9aQG4PiAVjCzyi3)(Uly7K)D(3kqaXuTcx2Qj0wHHrJcq7scsCSfeTEavq8ueT3eInu2SFbA0DbBhsggwe0uMO5hoRTC2A58c50oqUwOCw)SV4Ui)78VvGaInu2SFbAi8YMqRhGOx2eA9aPsrUgMgSkA5WPTIuIMKe2qQuKsdhduX(LZXMCbOAbiQGbbKJ9idzsLQfkN1p7loPDsySfeTEavq8ueT3eY9VpdlBqO7c2oKmmSiOPmrZpCwB5S1Y5fYPDGCTq5S(zFXDr(35FRabK7FFgw2GGWlBcTEaIEztO1dKkf5AyAWQOLdN2ksjAssydPsrknCmqf7xohBYfGQfGOcgeqo2JmKjvQwOCw)SV4K2HKJTGO1dOcINIO9MUQrRsZsozFdugODxW2tzvqcvajddlGnmizeeYPDKYQGeQasggwaByqYiimmAuaAxniEbAKyPsrQuwfKqfqYWWcyddsgbHC6yliA9aQG4PiAVz6R1d6UGTdjddlGyQwHlB1eARqoTdizyyrqtzIMF4S2YzRLZlKt7a5AyAWQOLdN2ksjAssydPsrknCmqf7xohBYfGQfGOcgeqo2JmPs1cLZ6N9fNucBm2gBbrRhqfehhwW2Hcde7Z02x7UGTNYQGeQasggwaByqYiiKt7iLvbjubKmmSa2WGKrqyy0Oa0KS3G4fOrIhBbrRhqfehhwWiAVjQStlA7RDxW2Bq8c0iXwoLvbjubKmmSaIdQMjooSGfggnkaTljksyJXwq06bubXXHfmI2Bcfgi2NPTV2DbBhw25YgM0gMgCwluoPgeVansChK)D(3kqaXuTcx2Qj0wHHrJcqhBbrRhqfehhwWiAVzqtzIMF4S2YzRLZp2cIwpGkiooSGr0EtQgOPSN7UGTdjddlcAkt08dN1woBTCEHCAhqYWWciMQv4YwnH2kKtLkvluoRF2xCs72ySfeTEavqCCybJO9MqmvRWLTAcTT7c2o5FN)TcebnLjA(HZAlNTwoVWWOrbODLGeLkvluoRF2xCs72ySfeTEavqCCybJO9MK2cnytKPTVo2cIwpGkiooSGr0EZiJkB8Sj)WzI5TshBbrRhqfehhwWiAVjuymrdESfeTEavqCCybJO9M7xoxM8OObW3DbBpiAzbNzaJwmnPevQuKksMnLYctKw(SHDF4fmiGCSFSfeTEavqCCybJO9M(YWzioO6yliA9aQG44Wcgr7nHcde7Z02x7UGTNYQGeQasggwaByqYii8VvqhiN0gMgmndBcIwpiCDTtSjsLcjddlGyQwHlB1eARqofzsLs(35FRarqtzIMF4S2YzRLZlmmAuaAsPSkiHkGKHHfWggKmccVSj06bwUbX3rKmBkLfPMcnC5cq1cquQGbbKJ9sLQfkN1p7lojjDSfeTEavqCCybJO9MOYoTOTV2DbBpsMnLYctKw(SHDF4fmiGCSVJGOLfCMbmAX0UsySfeTEavqCCybJO9MKhYezA7RDxW2j)78VvGy)Y5YKhfnaEHHrJcq7c(jYuHwOCw)mAK4oqEq0YcoZagTyAssqQuKksMnLYctKw(SHDF4fmiGCShzJTGO1dOcIJdlyeT3KMwQwGgzYdzIXwq06bubXXHfmI2BIk70I2(A3fS9iz2uklmrA5Zg29HxWGaYX(ocIwwWzgWOft7kHX2yliA9aQGQ2Hcde7Z02x7UGTNYQGeQasggwaByqYiiKt7iLvbjubKmmSa2WGKrqyy0Oa0KS3G4fOrILkfw25YgM0gMgCwluoPgeVansChK)D(3kqaXuTcx2Qj0wHHrJcqLknsMnLYIutHgUCbOAbikvWGaYX(oi)78VvGiOPmrZpCwB5S1Y5fggnkanPge)yliA9aQGQiAVzqtzIMF4S2YzRLZp2cIwpGkOkI2BgzuzJNn5hotmVv6yliA9aQGQiAVjvd0u2ZDxW2HKHHfbnLjA(HZAlNTwoVqoTdizyybet1kCzRMqBfYPsLQfkN1p7loPDBm2cIwpGkOkI2BcXuTcx2Qj02Uly7K)D(3kqe0uMO5hoRTC2A58cdJgfG2vcsuQuTq5S(zFXjTBJXwq06bubvr0EZ9lNltEu0a4hBbrRhqfufr7njTfAWMitBFDSfeTEavqveT30xgodXbvhBbrRhqfufr7nHcde7Z02x7UGTNYQGeQasggwaByqYii8VvqhiN0gMgmndBcIwpiCDTtSjsLcjddlGyQwHlB1eARqofzsLs(35FRarqtzIMF4S2YzRLZlmmAuaAsPSkiHkGKHHfWggKmccVSj06bwUbX3rKmBkLfPMcnC5cq1cquQGbbKJ9sLQfkN1p7lojjDSfeTEavqveT3ekmMObp2cIwpGkOkI2BsEitKPTV2DbBh5WprMAzYtveHFImvy4gmOtd5K)D(3kqSF5CzYJIgaVWWOrbOwEhY6kiA9aX(LZLjpkAa8cYtvPsj)78VvGy)Y5YKhfnaEHHrJcq7AhIniEK1b5FN)Tce7xoxM8OObWlmmAuaAx7gBbrRhqfufr7nPPLQfOrM8qM40tVda]] )


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
