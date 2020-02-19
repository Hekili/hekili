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
            aura = 'aspect_of_the_wild',

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
        },


        -- Utility
        mend_pet = {
            id = 136,
            duration = 10,
            max_stack = 1
        }
    } )

    spec:RegisterStateExpr( "barbed_shot_grace_period", function ()
        return ( settings.barbed_shot_grace_period or 0 ) * gcd.max
    end )

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

            start = function ()
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

            nobuff = function ()
                if settings.aspect_vop_overlap then return end
                return "aspect_of_the_wild"
            end,

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

            start = function ()
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


        -- Utility
        mend_pet = {
            id = 136,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return true
            end,
        }


    } )


    spec:RegisterPack( "Beast Mastery", 20200204, [[d0u0lbqiusEKsPSjQeFIkjJsj0PukAvkLk9kLQMLsWTqbzxK6xOqdtkvhtjAzkfEgvQmnuqDnuGTrLu(MucACuPkNtPu16OsvnpuI7ju2NushuPKSqQOEivs1evkPQlQusfBeLuv9rLskJuPurNuPeSsHQzkLa3uPuHDIImuLsQ0srjv5PGAQOOUkkPQ8vLsOXIsQCwLs0Er1FHmychw0Ib5XatwWLr2Su9zuQrlfNwYQLsOxlLYSPQBtIDRYVvmCHCCusz5q9CIMoLRtsBNkY3PcJxkrNxPY6Psz(kP9RQ5l5mZHdPrCM2O9nAV9nANH1l3GbmO9TNdB7IioCucAlztC4lvioSZukTxSDKsJW74Wr5o)KboZCy5OIbehUXSiP7ZiJSlRrfsdgfgLLIQpTAoao7gJYsbWihgsT82w44qC4qAeNPnAFJ2BFJ2zy9YnyadAFdoCQAndMddxkUohUPcb64qC4ajbC4T9cNPuAVy7iLgH39ITt1Zi8hFBVOXSiP7ZiJSlRrfsdgfgLLIQpTAoao7gJYsbW4hFBVG1pbHvt8Ux4UfEXgTVr7F8p(2EHR3KhBs6(F8T9cg6fBviqHx46J6ze(fWnJ9cBErG6PQ3ErcSAUx4lPP)4B7fm0ly9jPxyLcHSbfk6fl6Ku)clXSjtBLcHSbfkAZxyZlYZkqfLg9c6cVy6VGoWOEgH1F8T9cg6fBvi8IqjJiVKXivmBs(cNQ8fQw5lB3lsGvZ9cFjn9hFBVGHEHHRRnY0SoDtkrGz8HXX9Is(c1tQgfnyJc6p(2Ebd9cxVHaT9I(GFbaxgkcyiGkgtNP5W(sAsoZC4a1tvVXzMZ0soZCy6sipf4oZHb4YiCLC4abP27AqkT6yRvJEX66lGu7DDOKrK3NqEcPKSlGwn6fRRVasT31HsgrEFc5jeD4KnPvJ4WjWQ54WG07rjWQ5q(sACyFjn0Lkehw1kFz74gNPn4mZHtGvZXHvLeQmsrYHPlH8uG7m34m5ooZCy6sipf4oZHtGvZXHt3KnjoLO(CgA6OOXbH5WaCzeUsomygFyCC6ugradnDK1qihLpOXKswNeXwLKYxWYlwYGx4YlSsHq2Gcf9IwFXY25WxQqC40nztItjQpNHMokACqyUXzIH5mZHPlH8uG7mhobwnhhoLnoLhjr40TbJado9CyaUmcxjhoqqQ9UgNUnyeyWPhfii1ExRg9cxEXIVGvVGyn1kkIc60nztItjQpNHMokACq4xSU(cWm(W440PBYMeNsuFodnDu04GWAmPK1jFrRVW9CTxSU(cskPdqAi)mb00rwdHOJu2PvYwCWVyZx4Ylw8fryYjeBqqVuNYicyOPJSgc5O8HxSU(cw9cI1uROikOb7a(XWZvaeKpL2lC5fqQ9UoLreWqthzneYr5dAmPK1jFrRVGbVyZx4Ylw8fS6fKushG0G5c0jPaYxDQpyaPvYwCWVyD9fqQ9UMTAIdvEOPJs3i8ynA1OxS5lC5fl(clXSjt3qP3A0ra7fS8c3XGxSU(cw9cskPdqAWCb6Kua5Ro1hmG0kzlo4xSU(cw9cl90z62kVNWO6KwDattxc5PWl28fRRVyXxeii1ExJt3gmcm40JceKAVRdJJ7fRRVWkfczdku0ly5fB4AVyZx4YlSsHq2Gcf9IwFXIVydg(fB3xS4laZ4dJJtd2b8JHNRaiiFknnMuY6KVy)ly4xWYlSsHq2Gcf9InFXMC4lvioCkBCkpsIWPBdgbgC65gNjgWzMdtxc5Pa3zoCcSAoomyhWpgEUcGG8P04WaCzeUsomKAVRHiPvPh5aNwJomoUxSU(cRuiKnOqrVGLxWaom17eWqxQqCyWoGFm8Cfab5tPXnotUgNzomDjKNcCN5WjWQ54WG07rjWQ5q(sACyFjn0LkehgeKCJZulKZmhMUeYtbUZCyaUmcxjhobw5eHOJuks(cwEXgC4ey1CCyq69Oey1CiFjnoSVKg6sfIdlnUXzY94mZHPlH8uG7mhgGlJWvYHtGvori6iLIKVO1xSKdNaRMJddsVhLaRMd5lPXH9L0qxQqCyGNsNiUXnoCeMaJcuACM5mTKZmhobwnhhwQQOmhkImomDjKNcCN5gNPn4mZHPlH8uG7mh(sfIdNUjBsCkr95m00rrJdcZHtGvZXHt3KnjoLO(CgA6OOXbH5gNj3XzMdNaRMJd7yW(GtuDimjNlpaXHPlH8uG7m34mXWCM5WjWQ54WSvtCOYdnDu6gHhRHdtxc5Pa3zUXzIbCM5WjWQ54WkKYG3HMoYRcQakGPurYHPlH8uG7m34m5ACM5W0LqEkWDMdNaRMJdd2b8JHNRaiiFknomaxgHRKdZQxGZkGiNOZ015KQ)iCc5jn1YsAYx4Ylw8feRPwrruq7uIReYtO6m6KLTdXUyNonEdnsq59PvhBeMsGn4xSjhM6DcyOlviomyhWpgEUcGG8P04gNPwiNzomDjKNcCN5WjWQ54WGDa)y45kacYNsJddWLr4k5WS6f4SciYj6mDDoP6pcNqEstTSKM8fU8IfFHHRRnY0l1nPebMXhgh3l2)cdxxBKP3q3KseygFyCCVGLxSXlwxFbXAQvuef0oL4kH8eQoJozz7qSl2PtJ3qJeuEFA1XgHPeyd(fBYHPENag6sfIdd2b8JHNRaiiFknUXzY94mZHPlH8uG7mhgGlJWvYHz1lWzfqKt0z66Cs1FeoH8KMAzjnjhobwnhhUpavjfqPBeUmcbrPc34mT9CM5W0LqEkWDMdhHjqknKvkehEPEjhobwnhhoLreWqthzneYr5dCyaUmcxjhMvViDJWLr6iCPKEuDsRoGj10LqEk8cxEbREbjL0binjL0bi00rwdH6dqvwhBuHlPwjBXb)cxEXIVGyn1kkIc60nztItjQpNHMokACq4xSU(cw9cI1uROikOb7a(XWZvaeKpL2l2KBCMw2oNzomDjKNcCN5WrycKsdzLcXHxQzahobwnhhgIKwLEKdCAnCyaUmcxjhoDJWLr6iCPKEuDsRoGj10LqEk8cxEbREbjL0binjL0bi00rwdH6dqvwhBuHlPwjBXb)cxEXIVGyn1kkIc60nztItjQpNHMokACq4xSU(cw9cI1uROikOb7a(XWZvaeKpL2l2KBCMwUKZmhobwnhhoASAoomDjKNcCN5g34WapLorCM5mTKZmhMUeYtbUZC4ey1CCyOedrbKSzmomaxgHRKddP276oMo32PvJEHlVasT31DmDUTtJjLSo5lyj2lydcALSLVy)lGsmefqYMXqSXjGqreUMahgSd4jKLy2Kj5mTKBCM2GZmhMUeYtbUZCyaUmcxjhMniOvYw(cg6fqQ9UgIsPHaEkDI0ysjRt(IwFr76nyahobwnhhwr1BLSzmUXzYDCM5W0LqEkWDMdNaRMJddLyikGKnJXHb4YiCLC4UQ3JWeOjXSjKvk0ly5fSbbTs2Yx4YlaZ4dJJtdrsRspYboTgnMuY6KCyWoGNqwIztMKZ0sUXzIH5mZHtGvZXHtzebm00rwdHCu(ahMUeYtbUZCJZed4mZHPlH8uG7mhgGlJWvYHHu7DDkJiGHMoYAiKJYh0QrVWLxaP27AisAv6roWP1OvJEX66lSsHq2Gcf9cwEXsgWHtGvZXHLwQerbIBCMCnoZCy6sipf4oZHb4YiCLCyWm(W440PmIagA6iRHqokFqJjLSojITkjLVO1xSr7VyD9fw6PZ0ZrihL1GSgcfLG200LqEk8I11xyLcHSbfk6fS8ILmGdNaRMJddrsRspYboTgUXzQfYzMdNaRMJddAkLKWjs2mghMUeYtbUZCJZK7XzMdNaRMJdNifvCGWOPJa4XHKdtxc5Pa3zUXzA75mZHtGvZXHHsmoztCy6sipf4oZnotlBNZmhMUeYtbUZCyaUmcxjhobw5eHOJuks(cwEbd)I11xWQxKUr4YinoJQact(jdA6sipf4WjWQ54WTvEpcmkk5f4gNPLl5mZHtGvZXHdfMqquknomDjKNcCN5gNPLBWzMdtxc5Pa3zoCcSAoomuIHOas2mghgGlJWvYHHu7DDhtNB70HXX9cxEXIVa0Ky2Ke1XjWQ5s)lA9fl1U3lwxFbKAVRHiPvPh5aNwJwn6fB(I11xaMXhghNoLreWqthzneYr5dAmPK1jFblVasT31DmDUTthuXPvZ9cg6fSbHx4Yls3iCzKocxkPhvN0QdysnDjKNcVyD9fGMeZMKOoobwnx6FrRVyPMHFX66lSsHq2Gcf9cwEX2ZHb7aEczjMnzsotl5gNPLUJZmhobwnhhUpavjfqPBeUmcbrPchMUeYtbUZCJZ0sgMZmhobwnhhosfx9D1Xgb5tPXHPlH8uG7m34mTKbCM5WjWQ54WG5a0z40OaQ7tfIdtxc5Pa3zUXzAPRXzMdNaRMJdd5NjGMoYAieDKYoomDjKNcCN5gNPLTqoZCy6sipf4oZHb4YiCLCyi1ExJjqBEskr9bdiTA0lwxFbKAVRXeOnpjLO(GbecmQNryT0sqBVGLxSSDoCcSAooS1qi1dAuVaQpyaXnotlDpoZCy6sipf4oZHb4YiCLC40ncxgPXzufqyYpzqtxc5PWlC5fjWkNieDKsrYx06l2GdNaRMJdRO6Ts2mg34mTC75mZHPlH8uG7mhgGlJWvYHbZ4dJJt3w59iWOOKxqJjLSo5lA9f9bOk1wPqiBqkzlFHlVyXxKaRCIq0rkfjFblVWDVyD9fS6fPBeUmsJZOkGWKFYGMUeYtHxSjhobwnhhgmq4ejBgJBCM2ODoZC4ey1CCyzuzwDSrGbcNCy6sipf4oZnUXHbbjNzotl5mZHPlH8uG7mhgGlJWvYHbZ4dJJtdrsRspYboTgnMuY6KVO1x4U25WjWQ54W5biPHtpcKEp34mTbNzomDjKNcCN5WaCzeUsomygFyCCAisAv6roWP1OXKswN8fT(c31ohobwnhhUxycYptGBCMChNzomDjKNcCN5WaCzeUsomKAVRtzebm00rwdHCu(Gwn6fU8IfFHvkeYguOOx06laZ4dJJtdryjHBRo26GkoTAUxS)fbvCA1CVyD9fl(clXSjt3qP3A0ra7fS8c3XGxSU(cw9cl90z62kVNWO6KwDattxc5PWl28fB(I11xyLcHSbfk6fS8ILUJdNaRMJddryjHBRo2CJZedZzMdtxc5Pa3zomaxgHRKddP276ugradnDK1qihLpOvJEHlVyXxyLcHSbfk6fT(cWm(W440q(zcOUkENoOItRM7f7FrqfNwn3lwxFXIVWsmBY0nu6TgDeWEblVWDm4fRRVGvVWspDMUTY7jmQoPvhW00LqEk8InFXMVyD9fwPqiBqHIEblVyPRXHtGvZXHH8ZeqDv8oUXzIbCM5W0LqEkWDMddWLr4k5WqQ9UUJPZTDA1Ox4YlGu7DDhtNB70ysjRt(IwFbBqqRKT8fRRVGvVasT31DmDUTtRgXHtGvZXH9f7gtIAr1aBf6mUXzY14mZHPlH8uG7mhgGlJWvYHHu7DnejTk9ih40A0QrVWLxaP276ugradnDK1qihLpOvJEHlVWsmBY0nu6TgDeWEblVWDm4fRRVyXxS4laZjvvsipPJgRMdnDK6bHRGNcOUkE3lwxFbyoPQsc5jT6bHRGNcOUkE3l28fU8cRuiKnOqrVGLx4AlFX66lSsHq2Gcf9cwEXgU2l2KdNaRMJdhnwnh34m1c5mZHPlH8uG7mhgGlJWvYHx8fryYjeBqqVuNYicyOPJSgc5O8HxSU(cWm(W440PmIagA6iRHqokFqJjLSo5ly5fSbHxSU(clXSjtBLcHSbfk6fS8InA)fB(I11xWQxqsjDas7ujR5qthfr4obSAoTsDdMdNaRMJd7yW(GtuDimjNlpaXnotUhNzomDjKNcCN5WaCzeUsomygFyCC6ugradnDK1qihLpOXKswN8fS8ILT)I11xyLcHSbfk6fT(Iey1CA2Qjou5HMokDJWJ1ObZ4dJJ7f7FH7A)fRRVWkfczdku0ly5fURDoCcSAoomB1ehQ8qthLUr4XA4gNPTNZmhobwnhhgxrrEcvhsgLaIdtxc5Pa3zUXzAz7CM5WjWQ54WkKYG3HMoYRcQakGPurYHPlH8uG7m34mTCjNzoCcSAoomuYgnDKHlqBsomDjKNcCN5gNPLBWzMdtxc5Pa3zomaxgHRKdBjMnz6gk9wJocyVO1x4ET)I11xyjMnz6gk9wJocyVGLyVyJ2FX66lSeZMmTvkeYgueWqB0(lA9fURDoCcSAoomMYO6yJ6(uHKCJBCyPXzMZ0soZCy6sipf4oZHb4YiCLCyi1Ex3X052oTA0lC5fqQ9UUJPZTDAmPK1jFblVGni8I9VakXquajBgdXgNacfr4AcVyD9fGz8HXXPHiPvPh5aNwJgtkzDYx4Ylw8fDvVhHjqtIztiRuOxWYlydcVyD9fPBeUmshHlL0JQtA1bmPMUeYtHx4YlaZ4dJJtNYicyOPJSgc5O8bnMuY6KVGLxWgeEXMC4ey1CCyOedrbKSzmUXzAdoZCy6sipf4oZHb4YiCLC4(auLVy)l6dqvQXeB6EX29fSbHxWYl6dqvQvYw(cxEbKAVRHiPvPh5aNwJomoUx4Ylw8fS6fHX0G5a0z40OaQ7tfcbPIpnMuY6KVWLxWQxKaRMtdMdqNHtJcOUpviDDOUVy3yVyZxSU(IUQ3JWeOjXSjKvk0ly5fSbHxSU(cRuiKnOqrVGLxWaoCcSAoomyoaDgonkG6(uH4gNj3XzMdtxc5Pa3zomaxgHRKddMXhghNgkXquajBgtdAsmBs(cwEXYxSU(cw9I0ncxgPJWLs6r1jT6aMutxc5PahobwnhhoLreWqthzneYr5dCJZedZzMdtxc5Pa3zomaxgHRKddP276ugradnDK1qihLpOvJEHlVasT31qK0Q0JCGtRrRg9I11xyLcHSbfk6fS8ILmGdNaRMJdlTujIce34mXaoZC4ey1CC4ePOIdegnDeapoKCy6sipf4oZnotUgNzomDjKNcCN5WaCzeUsomKAVRHiPvPh5aNwJomoUxSU(cRuiKnOqrVGLxWaoCcSAooCFaQskGs3iCzecIsfUXzQfYzMdtxc5Pa3zomaxgHRKddP27AmbAZtsjQpyaPvJEX66lGu7DnMaT5jPe1hmGqGr9mcRLwcA7fS8ILT)I11xyLcHSbfk6fS8cgWHtGvZXHTgcPEqJ6fq9bdiUXzY94mZHPlH8uG7mhgGlJWvYHz1lGu7DnejTk9ih40A0QrVWLxaMXhghNoLreWqthzneYr5dAmPK1jFrRVyjdEX66lSsHq2Gcf9cwEXsg8I9VGniWHtGvZXHHiPvPh5aNwd34mT9CM5W0LqEkWDMddWLr4k5WPBeUmshYdqOPJcuAnACET9IwFXYx4YlGu7DDipaHMokqP1OXKswN8fS8c2GWlC5faCzOiGHaQymD2lA9fmC7C4ey1CCyOedrbKSzmUXzAz7CM5W0LqEkWDMddWLr4k5WqQ9UoLreWqthzneYr5dAmPK1jFrRVyz7Vy)lydcVyD9fwPqiBqHIEblVyz7Vy)lydcC4ey1CCyi)mb00rwdHOJu2XnotlxYzMdNaRMJd3w59iWOOKxGdtxc5Pa3zUXzA5gCM5WjWQ54WGMsjjCIKnJXHPlH8uG7m34mT0DCM5WjWQ54WHctiikLghMUeYtbUZCJZ0sgMZmhMUeYtbUZCyaUmcxjh2spDMEoc5OSgK1qOOe0MMUeYtHx4YlanjMnjrDCcSAU0)IwFXsndEX66lanjMnjrDCcSAU0)IwFXsT79I11xaMXhghNoLreWqthzneYr5dAmPK1jFblVasT31DmDUTthuXPvZ9cg6fSbHx4Yls3iCzKocxkPhvN0QdysnDjKNcVyD9fwPqiBqHIEblVy75WjWQ54WqjgIcizZyCJZ0sgWzMdtxc5Pa3zomaxgHRKddP27AisAv6roWP1OdJJ7fRRVWkfczdku0ly5fUhhobwnhhosfx9D1Xgb5tPXnotlDnoZC4ey1CCyi)mb00rwdHOJu2XHPlH8uG7m34mTSfYzMdNaRMJddLyCYM4W0LqEkWDMBCMw6ECM5W0LqEkWDMddWLr4k5Wl(I(auLVGHEbyK2l2)I(auLAmXMUxSDFXIVamJpmooDBL3JaJIsEbnMuY6KVGHEXYxS5lA9fjWQ50TvEpcmkk5f0GrAVyD9fGz8HXXPBR8EeyuuYlOXKswN8fT(ILVy)lydcVWLxaMXhghNgIKwLEKdCAnAmPK1jrSvjP8fT(I(auLARuiKniLSLVyD9fqQ9UwHug8o00rEvqfqbmLksTA0l28fU8cWm(W440TvEpcmkk5f0ysjRt(IwFXYxSU(cRuiKnOqrVGLx4ooCcSAoomyGWjs2mg34mTC75mZHtGvZXHLrLz1XgbgiCYHPlH8uG7m34mTr7CM5W0LqEkWDMddWLr4k5WqQ9UUJPZTD6GkoTAUxWqVGni8IwFrx17ryc0Ky2eYkfIdNaRMJddLyikGKnJXnUXHvTYx2ooZCMwYzMdNaRMJddg1Zims2mghMUeYtbUZCJZ0gCM5WjWQ54Wsctxz7qbvPXHPlH8uG7m34m5ooZC4ey1CCyz0GjeWpQbomDjKNcCN5gNjgMZmhobwnhhwoJ1uhBKJ0imhMUeYtbUZCJZed4mZHtGvZXHLZvaeKpLghMUeYtbUZCJZKRXzMdNaRMJdFK1qyKSzaTXHPlH8uG7m34m1c5mZHtGvZXHbnvlwsKHZJ1ulFz74W0LqEkWDMBCMCpoZC4ey1CCyzuHldjBgqBCy6sipf4oZnotBpNzoCcSAoo8LMkMKi24eqCy6sipf4oZnUXnoStewwZXzAJ23O92xUbdZHDK4Ro2so8wCRy9yAlW0wZ9FXlyUHErPeny7f9b)cxfOEQ6nx9cmXAQfMcVqok0lsvBusJcVa0KhBsQ)4TG6OxWWU)lC95CIWgfEHRmCDTrMM1PbZ4dJJZvVWMx4kWm(W440Sox9Ifx2Yn1F8p(wCRy9yAlW0wZ9FXlyUHErPeny7f9b)cxb8u6e5QxGjwtTWu4fYrHErQAJsAu4fGM8yts9hVfuh9ILU)lC95CIWgfEHRIitZ60BPwRD1lS5fUAl1ATREXIB0Yn1F8wqD0l2W9FHRpNte2OWlCvezAwNEl1ATREHnVWvBPwRD1lwCzl3u)XBb1rVy5gU)lC95CIWgfEHRIitZ60BPwRD1lS5fUAl1ATREXIB0Yn1F8p(wCRy9yAlW0wZ9FXlyUHErPeny7f9b)cxbcsx9cmXAQfMcVqok0lsvBusJcVa0KhBsQ)4TG6OxWa3)fU(CoryJcVWvrKPzD6TuR1U6f28cxTLAT2vVyr31Yn1F8p(wCRy9yAlW0wZ9FXlyUHErPeny7f9b)cxjnx9cmXAQfMcVqok0lsvBusJcVa0KhBsQ)4TG6OxS09FHRpNte2OWlCvezAwNEl1ATREHnVWvBPwRD1lwCJwUP(J3cQJEXsg29FHRpNte2OWlCvezAwNEl1ATREHnVWvBPwRD1lwCzl3u)XBb1rVyJ2D)x46Z5eHnk8cxfrMM1P3sTw7QxyZlC1wQ1Ax9Ifx2Yn1F8p(wqjAWgfEHR9Iey1CVWxstQ)4C4i80lpXH32lCMsP9ITJuAeE3l2ovpJWF8T9IgZIKUpJmYUSgvinyuyuwkQ(0Q5a4SBmklfaJF8T9cw)eewnX7EH7w4fB0(gT)X)4B7fUEtESjP7)X32lyOxSvHafEHRpQNr4xa3m2lS5fbQNQE7fjWQ5EHVKM(JVTxWqVG1NKEHvkeYguOOxSOts9lSeZMmTvkeYguOOnFHnVipRavuA0lOl8IP)c6aJ6zew)X32lyOxSvHWlcLmI8sgJuXSj5lCQYxOALVSDVibwn3l8L00F8T9cg6fgUU2itZ60nPebMXhgh3lk5lupPAu0GnkO)4B7fm0lC9gc02l6d(faCzOiGHaQymDM(J)X32l260scOAu4fquFW0laJcuAVaIyxNu)ITcaOit(IBogQjXkDv)lsGvZjFXC(D6p(2ErcSAoPoctGrbkTyDFkB7JVTxKaRMtQJWeyuGsBFmgtv2k0zPvZ9X32lsGvZj1rycmkqPTpgJ9zcF8ey1CsDeMaJcuA7JXOuvrzouezF8T9c4lJKnJ9cCwHxaP27u4fsln5lGO(GPxagfO0EbeXUo5lYl8IimXqrJz1X(fL8fH5i9hFBVibwnNuhHjWOaL2(ymkVms2mgsAPj)4jWQ5K6imbgfO02hJrvjHkJuw4sfkw6MSjXPe1NZqthfnoi8hpbwnNuhHjWOaL2(ym6yW(GtuDimjNlpa9XtGvZj1rycmkqPTpgJSvtCOYdnDu6gHhR5JNaRMtQJWeyuGsBFmgviLbVdnDKxfubuatPI8JNaRMtQJWeyuGsBFmgvLeQmszbQ3jGHUuHIb2b8JHNRaiiFkTfQEmwHZkGiNOZ015KQ)iCc5jn1YsAsxwKyn1kkIcANsCLqEcvNrNSSDi2f70PXBOrckVpT6yJWucSbV5hpbwnNuhHjWOaL2(ymQkjuzKYcuVtadDPcfdSd4hdpxbqq(uAlu9yScNvarorNPRZjv)r4eYtAQLL0KUSOHRRnY0l1nPebMXhgh3EdxxBKP3q3KseygFyCCSSX6kXAQvuef0oL4kH8eQoJozz7qSl2PtJ3qJeuEFA1XgHPeydEZpEcSAoPoctGrbkT9XySpavjfqPBeUmcbrPYcvpgRWzfqKt0z66Cs1FeoH8KMAzjn5hFBVyRcTOQ0KVWAOxeuXPvZ9I8cVamJpmoUxm9xSvYicyVy6VWAOxSflF4f5fEXwxCPK(xSfoPvhWKVaA3lSg6fbvCA1CVy6ViVxOEnP0OWl2AU(w)lC0q3lSgANRW0luLu4frycmkqPPFXwjFXwn2w8fnP8f5lwQDN8fBnxFR)f5fEr27eWKVOmj57VWAk5lk5lwQxk1F8ey1CsDeMaJcuA7JXykJiGHMoYAiKJYhwictGuAiRuOyl1lxO6Xyv6gHlJ0r4sj9O6KwDatQPlH8uWfwrsjDastsjDacnDK1qO(auL1Xgv4sQvYwCWUSiXAQvuef0PBYMeNsuFodnDu04GWRRSIyn1kkIcAWoGFm8Cfab5tPT5hFBVyRcTOQ0KVWAOxeuXPvZ9I8cVamJpmoUxm9x4mjTk9VylItR5f5fEX2z6g9IP)cwVKn9cODVWAOxeuXPvZ9IP)I8EH61KsJcVyR56B9VWrdDVWAODUctVqvsHxeHjWOaLM(JNaRMtQJWeyuGsBFmgHiPvPh5aNwZcrycKsdzLcfBPMblu9yPBeUmshHlL0JQtA1bmPMUeYtbxyfjL0binjL0bi00rwdH6dqvwhBuHlPwjBXb7YIeRPwrruqNUjBsCkr95m00rrJdcVUYkI1uROikOb7a(XWZvaeKpL2MF8ey1CsDeMaJcuA7JXy0y1CF8pEcSAoPw1kFz7Ibg1Zims2m2hpbwnNuRALVSD7JXOKW0v2ouqvAF8ey1CsTQv(Y2TpgJYObtiGFudF8ey1CsTQv(Y2TpgJYzSM6yJCKgH)4jWQ5KAvR8LTBFmgLZvaeKpL2hpbwnNuRALVSD7JX4rwdHrYMb02hpbwnNuRALVSD7JXiOPAXsImCESMA5lB3hpbwnNuRALVSD7JXOmQWLHKndOTpEcSAoPw1kFz72hJXlnvmjrSXjG(4F8T9IToTKaQgfEb5eH39cRuOxyn0lsGn4xuYxKoLLpH8K(JNaRMtgdKEpkbwnhYxsBHlvOyQw5lB3cvpwGGu7DniLwDS1QrRRqQ9UouYiY7tipHus2fqRgTUcP276qjJiVpH8eIoCYM0QrF8ey1CY9XyuvsOYif5hpbwnNCFmgvLeQmszHlvOyPBYMeNsuFodnDu04GWlu9yGz8HXXPtzebm00rwdHCu(GgtkzDseBvskzzjdCXkfczdkuuRlB)JNaRMtUpgJQscvgPSWLkuSu24uEKeHt3gmcm40Vq1Jfii1ExJt3gmcm40JceKAVRvJCzrwrSMAffrbD6MSjXPe1NZqthfnoi86QHRRnY0PBYMeNsuFodnDu04GWAWm(W440ysjRt2Q75ARRKushG0q(zcOPJSgcrhPStRKT4G30LfJWKti2GGEPoLreWqthzneYr5dRRSIyn1kkIcAWoGFm8Cfab5tP5cKAVRtzebm00rwdHCu(GgtkzDYwzWMUSiRiPKoaPbZfOtsbKV6uFWasRKT4GxxHu7DnB1ehQ8qthLUr4XA0QrB6YIwIztMUHsV1OJaglUJbRRSIKs6aKgmxGojfq(Qt9bdiTs2IdEDLvw6PZ0TvEpHr1jT6aMMUeYtHnxxxmqqQ9UgNUnyeyWPhfii1Exhgh36QvkeYguOiw2W120fRuiKnOqrTU4gm82DrWm(W440GDa)y45kacYNstJjLSo5EgMfRuiKnOqrBU5hpbwnNCFmgvLeQmszbQ3jGHUuHIb2b8JHNRaiiFkTfQEmi1ExdrsRspYboTgDyCCRRwPqiBqHIyHbF8ey1CY9XyeKEpkbwnhYxsBHlvOyGG8JNaRMtUpgJG07rjWQ5q(sAlCPcftAlu9yjWkNieDKsrsw24JNaRMtUpgJG07rjWQ5q(sAlCPcfd4P0jAHQhlbw5eHOJuks26Yp(hpbwnNudcYy5biPHtpcKE)cvpgygFyCCAisAv6roWP1OXKswNSv31(hpbwnNudcY9XySxycYptyHQhdmJpmoonejTk9ih40A0ysjRt2Q7A)JNaRMtQbb5(ymcryjHBRo2lu9yqQ9UoLreWqthzneYr5dA1ixw0kfczdkuuRGz8HXXPHiSKWTvhBDqfNwn3(GkoTAU11fTeZMmDdLERrhbmwChdwxzLLE6mDBL3tyuDsRoGPPlH8uyZnxxTsHq2GcfXYs39XtGvZj1GGCFmgH8ZeqDv8UfQEmi1ExNYicyOPJSgc5O8bTAKllALcHSbfkQvWm(W440q(zcOUkENoOItRMBFqfNwn366IwIztMUHsV1OJaglUJbRRSYspDMUTY7jmQoPvhW00LqEkS5MRRwPqiBqHIyzPR9XtGvZj1GGCFmg9f7gtIAr1aBf6SfQESiY0G00qQ9UUJPZTDA1ixIitdstdP276oMo32PXKswNSv2GGwjB56kRIitdstdP276oMo32PvJ(4jWQ5KAqqUpgJrJvZTq1JbP27AisAv6roWP1OvJCbsT31PmIagA6iRHqokFqRg5ILy2KPBO0Bn6iGXI7yW66IlcMtQQKqEshnwnhA6i1dcxbpfqDv8U1vWCsvLeYtA1dcxbpfqDv8UnDXkfczdkuelU2Y1vRuiKnOqrSSHRT5hpbwnNudcY9Xy0XG9bNO6qysoxEaAHQhBXim5eIniOxQtzebm00rwdHCu(W6kygFyCC6ugradnDK1qihLpOXKswNKf2GW6QLy2KPTsHq2GcfXYgTV56kRiPKoaPDQK1COPJIiCNawnNwPUb)XtGvZj1GGCFmgzRM4qLhA6O0ncpwZcvpgygFyCC6ugradnDK1qihLpOXKswNKLLTVUALcHSbfkQ1ey1CA2Qjou5HMokDJWJ1ObZ4dJJBV7AFD1kfczdkuelUR9pEcSAoPgeK7JXiUII8eQoKmkb0hpbwnNudcY9XyuHug8o00rEvqfqbmLkYpEcSAoPgeK7JXiuYgnDKHlqBYpEcSAoPgeK7JXiMYO6yJ6(uHKlu9ywIztMUHsV1OJawRUx7RRwIztMUHsV1OJaglX2O91vlXSjtBLcHSbfbm0gT3Q7A)J)XtGvZj1apLorXGsmefqYMXwaSd4jKLy2KjJTCHQhlImninnKAVR7y6CBNwnYLiY0G00qQ9UUJPZTDAmPK1jzjgBqqRKTCpuIHOas2mgInobekIW1e(4jWQ5KAGNsNO9Xyur1BLSzSfQEm2GGwjBjdfrMgKMgsT31qukneWtPtKgtkzDYwBxVbd(4jWQ5KAGNsNO9XyekXquajBgBbWoGNqwIztMm2YfQESUQ3JWeOjXSjKvkelSbbTs2sxaZ4dJJtdrsRspYboTgnMuY6KF8ey1CsnWtPt0(ymMYicyOPJSgc5O8HpEcSAoPg4P0jAFmgLwQerbAHQhdsT31PmIagA6iRHqokFqRg5cKAVRHiPvPh5aNwJwnAD1kfczdkuellzWhpbwnNud8u6eTpgJqK0Q0JCGtRzHQhdmJpmooDkJiGHMoYAiKJYh0ysjRtIyRsszRB0(6QLE6m9CeYrzniRHqrjOnnDjKNcRRwPqiBqHIyzjd(4jWQ5KAGNsNO9Xye0ukjHtKSzSpEcSAoPg4P0jAFmgtKIkoqy00ra84q(XtGvZj1apLor7JXiuIXjB6JNaRMtQbEkDI2hJX2kVhbgfL8clu9yjWkNieDKsrswy41vwLUr4YinoJQact(jdA6sipf(4jWQ5KAGNsNO9XymuycbrP0(4jWQ5KAGNsNO9XyekXquajBgBbWoGNqwIztMm2YfQESiY0G00qQ9UUJPZTD6W44CzrqtIztsuhNaRMl9TUu7ERRqQ9UgIKwLEKdCAnA1OnxxbZ4dJJtNYicyOPJSgc5O8bnMuY6KSerMgKMgsT31DmDUTthuXPvZXqSbbxs3iCzKocxkPhvN0QdysnDjKNcRRGMeZMKOoobwnx6BDPMHxxTsHq2GcfXY2)XtGvZj1apLor7JXyFaQskGs3iCzecIsLpEcSAoPg4P0jAFmgJuXvFxDSrq(uAF8ey1CsnWtPt0(ymcMdqNHtJcOUpvOpEcSAoPg4P0jAFmgH8ZeqthzneIosz3hpbwnNud8u6eTpgJwdHupOr9cO(Gb0cvpgKAVRXeOnpjLO(GbKwnADfsT31yc0MNKsuFWacbg1ZiSwAjOnww2(hpbwnNud8u6eTpgJkQERKnJTq1JLUr4YinoJQact(jdA6sipfCjbw5eHOJuks26gF8ey1CsnWtPt0(ymcgiCIKnJTq1JbMXhghNUTY7rGrrjVGgtkzDYw7dqvQTsHq2GuYw6YIjWkNieDKsrswC36kRs3iCzKgNrvaHj)KbnDjKNcB(XtGvZj1apLor7JXOmQmRo2iWaHZp(hpbwnNulTyqjgIcizZylu9yrKPbPPHu7DDhtNB70QrUerMgKMgsT31DmDUTtJjLSojlSbH9qjgIcizZyi24eqOicxtyDfmJpmoonejTk9ih40A0ysjRt6YIDvVhHjqtIztiRuiwydcRRPBeUmshHlL0JQtA1bmPMUeYtbxaZ4dJJtNYicyOPJSgc5O8bnMuY6KSWge28JNaRMtQL2(ymcMdqNHtJcOUpvOfQES(auL77dqvQXeB62USbbw6dqvQvYw6cKAVRHiPvPh5aNwJomooxwKvHX0G5a0z40OaQ7tfcbPIpnMuY6KUWQey1CAWCa6mCAua19PcPRd19f7gBZ11UQ3JWeOjXSjKvkelSbH1vRuiKnOqrSWGpEcSAoPwA7JXykJiGHMoYAiKJYhwO6XaZ4dJJtdLyikGKnJPbnjMnjzz56kRs3iCzKocxkPhvN0QdysnDjKNcF8ey1CsT02hJrPLkruGwO6XGu7DDkJiGHMoYAiKJYh0QrUaP27AisAv6roWP1OvJwxTsHq2GcfXYsg8XtGvZj1sBFmgtKIkoqy00ra84q(XtGvZj1sBFmg7dqvsbu6gHlJqquQSq1JbP27AisAv6roWP1OdJJBD1kfczdkuelm4JNaRMtQL2(ymAnes9Gg1lG6dgqlu9yqQ9UgtG28KuI6dgqA1O1vi1ExJjqBEskr9bdieyupJWAPLG2yzz7RRwPqiBqHIyHbF8ey1CsT02hJrisAv6roWP1Sq1JXki1ExdrsRspYboTgTAKlGz8HXXPtzebm00rwdHCu(GgtkzDYwxYG1vRuiKnOqrSSKb7zdcF8ey1CsT02hJrOedrbKSzSfQES0ncxgPd5bi00rbkTgnoV2ADPlqQ9UoKhGqthfO0A0ysjRtYcBqWfaUmueWqavmMoRvgU9pEcSAoPwA7JXiKFMaA6iRHq0rk7wO6XGu7DDkJiGHMoYAiKJYh0ysjRt26Y23ZgewxTsHq2GcfXYY23Zge(4jWQ5KAPTpgJTvEpcmkk5f(4jWQ5KAPTpgJGMsjjCIKnJ9XtGvZj1sBFmgdfMqqukTpEcSAoPwA7JXiuIHOas2m2cvpMLE6m9CeYrzniRHqrjOnnDjKNcUaAsmBsI64ey1CPV1LAgSUcAsmBsI64ey1CPV1LA3BDfmJpmooDkJiGHMoYAiKJYh0ysjRtYsezAqAAi1Ex3X052oDqfNwnhdXgeCjDJWLr6iCPKEuDsRoGj10LqEkSUALcHSbfkILT)JNaRMtQL2(ymgPIR(U6yJG8P0wO6XGu7DnejTk9ih40A0HXXTUALcHSbfkIf37JNaRMtQL2(ymc5NjGMoYAieDKYUpEcSAoPwA7JXiuIXjB6JNaRMtQL2(ymcgiCIKnJTq1JTyFaQsgcmsBFFaQsnMyt32DrWm(W440TvEpcmkk5f0ysjRtYql3S1ey1C62kVhbgfL8cAWiT1vWm(W440TvEpcmkk5f0ysjRt26Y9SbbxaZ4dJJtdrsRspYboTgnMuY6Ki2QKu2AFaQsTvkeYgKs2Y1vi1ExRqkdEhA6iVkOcOaMsfPwnAtxaZ4dJJt3w59iWOOKxqJjLSozRlxxTsHq2GcfXI7(4jWQ5KAPTpgJYOYS6yJadeo)4jWQ5KAPTpgJqjgIcizZylu9yrKPbPPHu7DDhtNB70bvCA1CmeBqO1UQ3JWeOjXSjKvkehwgraotBWa3XnUX5a]] )


    spec:RegisterOptions( {
        enabled = true,

        potion = "unbridled_fury",

        buffPadding = 0.25,

        nameplates = false,
        nameplateRange = 8,

        aoe = 3,

        damage = true,
        damageExpiration = 3,

        package = "Beast Mastery",
    } )


    spec:RegisterSetting( "barbed_shot_grace_period", 0.5, {
        name = "|T2058007:0|t Barbed Shot Grace Period",
        desc = "If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier.",
        icon = 2058007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 1,
        step = 0.01,
        width = 1.5
    } )    


    spec:RegisterSetting( "aspect_vop_overlap", false, {
        name = "|T136074:0|t Aspect of the Wild Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T136074:0|t Aspect of the Wild even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Aspect of the Wild would cost you one or more uses of Aspect of the Wild in a given fight.",
        type = "toggle",
        width = 1.5
    } )    
end
