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


    spec:RegisterPack( "Beast Mastery", 20200301, [[dWe5mbqiOQ8iLsAtuj9jOQAukjDkLuwLsPkVsPYSKs1TGczxK6xqrdtPOJjLSmLcpJkrtJkvCnOGTrLqFtkfACuPkNtPuzDuPQMhuY9ek7tjvhuPuSqsQEivQ0evkLQlQukfFuPeAKkLQYjvkbRuOAMsPGBsLGANqPgQsPuAPujipfstfQYvvkvvFvPuYyPsGZQuI2lQ(lObt4WIwmepgyYcUmYMLQptsgTuCAjRwkf9ALeZMQUnj2TQ(TIHlKJdfQLJYZjA6uUovSDskFhQmEPu68kvTEQuMVsSFvM3IJhhnKgXXEJn3yZnD5MT0TWqlx6oyGJA7JioAucwjvrC0pvioQ6ukTt4cNsJy75Or5E)KboECu54WaehTXSiP7JjMQkRXbrdgfmLLIJpTAEal7gMYsbGjhfXP82w45iC0qAeh7n2CJn30LB2s3cdTCzRn4OPJ1mmokAP4UC0MkeONJWrdKeWr36juNsPDcx4uAeB)j2(CEJyx8TEIgZIKUpMyQQSghenyuWuwko(0Q5bSSByklfaMx8TEcx4KbAorR2pXgBUXMx8l(wpH72KVks6(x8TEcm6eBtiqHt4UJZBe7eOnJDcBorG6PJ3orcSA(t4lPPV4B9ey0j2(L0jSsHG2adfDIvvtQpHLmvKPTsHG2adfT2jS5e5BfOIsJob9Htm9tqpyCEJy6l(wpbgDITjeorOKrKxIzKdtfjpHAvEchR8LT)ejWQ5pHVKM(IV1tGrNWy1VczAxGUjLqWm(WG7prjpHZlDIIgMrb9fFRNaJoH72qGvorFyNaWkdgbmiWHXO30CuFjnjhpoAG6PJ344XXUfhpok9jINcC15OawzeRsoAGqC6DniLw9Q0orNyz5eio9UouYiY7tepbvsvfq7eDILLtG4076qjJiVpr8eKEwQI0orC0ey18Cuq69Wey18qFjnoQVKg8tfIJ6yLVS9CJJ9gC84O0NiEkWvNJcyLrSk5OrmsnOkqq3sNYicyWPdTgcIR8HtSSCcRuiOnWqrNaRtSXMC0ey18CuhjblJuKCJJTl54XrPpr8uGRohnbwnphnDt2KSuc7ZBWPdJgCeJJcyLrSk5OGz8Hb3Rtzebm40HwdbXv(GMrkz9sOkhskpbwNOfgoHRNWkfcAdmu0jw)eT2KJ(PcXrt3KnjlLW(8gC6WObhX4ghB3HJhhL(eXtbU6C0ey18C0u2Ow(KeYs3ggemS0ZrbSYiwLC0aH407Aw62WGGHLEyGqC6DTt0jC9eREc8DccJDQOikOt3KnjlLW(8gC6WObhXoXYYjaZ4ddUxNUjBswkH95n40HrdoIPzKswV8eRFc3ZfpXYYjiPKEaPr8ZeGthAneKEszVwjBZHDI1oHRNy1teXi1GQabDlDkJiGbNo0AiiUYhoXYYjW3jim2PIIOGgSh4hJnFbGi(uANW1tG4076ugradoDO1qqCLpOzKswV8eRFIT7eRDcxpXQNaFNGKs6bKgmFGEjfG(Qt9HbiTs2Md7ellNaXP31QCswOYhoDy6gXgRr7eDI1oHRNy1tyjtfz6gk9wJocyNaRt4smCILLtGVtqsj9asdMpqVKcqF1P(WaKwjBZHDILLtGVtyPNEtVs59edwV0QhyA6tepfoXANyz5eREIaH407Aw62WGGHLEyGqC6DDyW9Nyz5ewPqqBGHIobwNydx8eRDcxpHvke0gyOOtS(jw9eB4oNy7DIvpbygFyW9AWEGFm28faI4tPPzKswV8e7oH7CcSoHvke0gyOOtS2jwJJ(PcXrtzJA5tsilDByqWWsp34yJboECu6tepf4QZrtGvZZrb7b(XyZxaiIpLghfWkJyvYrrC6DncjTk9qCS0A0Hb3FILLtyLcbTbgk6eyDcmWrPENag8tfIJc2d8JXMVaqeFknUXX2f54XrPpr8uGRohnbwnphfKEpmbwnp0xsJJ6lPb)uH4OGGKBCSBJC84O0NiEkWvNJcyLrSk5OjWk1ii9KsrYtG1j2GJMaRMNJcsVhMaRMh6lPXr9L0GFQqCuPXno2Uhhpok9jINcC15OawzeRsoAcSsncspPuK8eRFIwC0ey18Cuq69Wey18qFjnoQVKg8tfIJc8uQgXnUXrJyeyuqsJJhh7wC84OjWQ55OshfL5HrKXrPpr8uGRo34yVbhpok9jINcC15OFQqC00nztYsjSpVbNomAWrmoAcSAEoA6MSjzPe2N3Gthgn4ig34y7soEC0ey18CuCdZhuJQhYi585diok9jINcC15ghB3HJhhnbwnphvLtYcv(WPdt3i2ynCu6tepf4QZno2yGJhhnbwnphvHug2E40HEhqfGbgLksok9jINcC15ghBxKJhhL(eXtbU6C0ey18CuWEGFm28faI4tPXrbSYiwLCu8DcwwbiPg9MUE1C8pXsepPP2wstEcxpXQNGWyNkkIcA1swLiEcwVrVSS9qvLQuTXBWrckVpT6vbzucSHDI14OuVtad(PcXrb7b(XyZxaiIpLg34y3g54XrPpr8uGRohnbwnphfSh4hJnFbGi(uACuaRmIvjhfFNGLvasQrVPRxnh)tSeXtAQTL0KNW1tS6jmw9RqMULUjLqWm(WG7pXUtyS6xHm9g6MucbZ4ddU)eyDInoXYYjim2PIIOGwTKvjING1B0llBpuvPkvB8gCKGY7tREvqgLaByNynok17eWGFQqCuWEGFm28faI4tPXno2Uhhpok9jINcC15OawzeRsok(oblRaKuJEtxVAo(NyjIN0uBlPj5OjWQ55O9b4iPamDJyLrqekv4gh7TJJhhL(eXtbU6C0igbsPbTsH4OT0T4OjWQ55OPmIagC6qRHG4kFGJcyLrSk5O47ePBeRmshXkL0dRxA1dmPM(eXtHt46jW3jiPKEaPjPKEabNo0AiyFaoY6vblwj1kzBoSt46jw9eeg7urruqNUjBswkH95n40HrdoIDILLtGVtqyStffrbnypWpgB(car8P0oXACJJDRn54XrPpr8uGRohnIrGuAqRuioAlng4OjWQ55OiK0Q0dXXsRHJcyLrSk5OPBeRmshXkL0dRxA1dmPM(eXtHt46jW3jiPKEaPjPKEabNo0AiyFaoY6vblwj1kzBoSt46jw9eeg7urruqNUjBswkH95n40HrdoIDILLtGVtqyStffrbnypWpgB(car8P0oXACJJDRwC84OjWQ55OrJvZZrPpr8uGRo34ghf4PunIJhh7wC84O0NiEkWvNJMaRMNJIKmekaLnJXrbSYiwLCueNEx3z072ETt0jC9eio9UUZO3T9AgPK1lpbwXoHkqqRKT9e7obsYqOau2mguflbemIy1e4OG9apbTKPImjh7wCJJ9gC84O0NiEkWvNJcyLrSk5OQabTs22tGrNaXP31iukniWtPAKMrkz9YtS(j2uVbg4OjWQ55OkoERKnJXno2UKJhhL(eXtbU6C0ey18CuKKHqbOSzmokGvgXQKJ2D8EiJanjtfbTsHobwNqfiOvY2EcxpbygFyW9AesAv6H4yP1OzKswVKJc2d8e0sMkYKCSBXno2UdhpoAcSAEoAkJiGbNo0AiiUYh4O0NiEkWvNBCSXahpok9jINcC15OawzeRsokItVRtzebm40HwdbXv(G2j6eUEceNExJqsRspehlTgTt0jwwoHvke0gyOOtG1jAHboAcSAEoQ0sLikqCJJTlYXJJsFI4PaxDokGvgXQKJcMXhgCVoLreWGthAneex5dAgPK1lHQCiP8eRFIn28ellNWsp9MEEcIRSgO1qWOeSIM(eXtHtSSCcRuiOnWqrNaRt0cdC0ey18CuesAv6H4yP1Wno2TroEC0ey18CuqtPKelHYMX4O0NiEkWvNBCSDpoEC0ey18C0eQ4WcedoDiGn4KCu6tepf4QZno2BhhpoAcSAEoksYyPkIJsFI4PaxDUXXU1MC84O0NiEkWvNJcyLrSk5OjWk1ii9KsrYtG1jCNtSSCc8DI0nIvgPzzufGmYpzqtFI4PahnbwnphDLY7HGrrj)a34y3QfhpoAcSAEoAOyeeHsPXrPpr8uGRo34y3AdoECu6tepf4QZrtGvZZrrsgcfGYMX4OawzeRsokItVR7m6DBVom4(t46jw9eGMKPIKWolbwnF6pX6NOL29oXYYjqC6DncjTk9qCS0A0orNyTtSSCcWm(WG71PmIagC6qRHG4kFqZiLSE5jW6eio9UUZO3T96GdlTA(tGrNqfiCcxpr6gXkJ0rSsj9W6Lw9atQPpr8u4ellNa0KmvKe2zjWQ5t)jw)eT0UZjwwoHvke0gyOOtG1j2ookypWtqlzQitYXUf34y3YLC84OjWQ55O9b4iPamDJyLrqekv4O0NiEkWvNBCSB5oC84OjWQ55OroSQVVEvqeFknok9jINcC15gh7wyGJhhnbwnphfmpGEJLgfGDFQqCu6tepf4QZno2TCroEC0ey18Cue)mb40HwdbPNu2ZrPpr8uGRo34y3QnYXJJsFI4PaxDokGvgXQKJI407AgbwXtsjSpmaPDIoXYYjqC6DnJaR4jPe2hgGGGX5nIPLwcw5eyDIwBYrtGvZZrTgc68iJZhG9HbiUXXUL7XXJJsFI4PaxDokGvgXQKJMUrSYinlJQaKr(jdA6tepfoHRNibwPgbPNuksEI1pXgC0ey18CufhVvYMX4gh7wBhhpok9jINcC15OawzeRsokygFyW96vkVhcgfL8dAgPK1lpX6NOpahP2kfcAdujB7jC9eREIeyLAeKEsPi5jW6eU8ellNaFNiDJyLrAwgvbiJ8tg00NiEkCI14OjWQ55OGbHLqzZyCJJ9gBYXJJMaRMNJkJkZQxfemiSKJsFI4PaxDUXnokii54XXUfhpok9jINcC15OawzeRsokygFyW9AesAv6H4yP1OzKswV8eRFcxUjhnbwnphnFajnw6HG075gh7n44XrPpr8uGRohfWkJyvYrbZ4ddUxJqsRspehlTgnJuY6LNy9t4Yn5OjWQ55O9Iri(zcCJJTl54XrPpr8uGRohfWkJyvYrrC6DDkJiGbNo0AiiUYh0orNW1tS6jSsHG2adfDI1pbygFyW9AeIjj2k1RshCyPvZFIDNi4WsRM)ellNy1tyjtfz6gk9wJocyNaRt4smCILLtGVtyPNEtVs59edwV0QhyA6tepfoXANyTtSSCcRuiOnWqrNaRt0YLC0ey18CueIjj2k1RIBCSDhoECu6tepf4QZrbSYiwLCueNExNYicyWPdTgcIR8bTt0jC9eREcRuiOnWqrNy9taMXhgCVgXpta2Dy71bhwA18Ny3jcoS0Q5pXYYjw9ewYurMUHsV1OJa2jW6eUedNyz5e47ew6P30RuEpXG1lT6bMM(eXtHtS2jw7ellNWkfcAdmu0jW6eTCroAcSAEokIFMaS7W2Zno2yGJhhL(eXtbU6CuaRmIvjhfXP31Dg9UTx7eDcxpbItVR7m6DBVMrkz9YtS(jubcALSTNyz5e47eio9UUZO3T9ANioAcSAEoQVu1ysyB6euPqVXno2Uihpok9jINcC15OawzeRsokItVRriPvPhIJLwJ2j6eUEceNExNYicyWPdTgcIR8bTt0jC9ewYurMUHsV1OJa2jW6eUedNyz5eREIvpbyEPJsI4jD0y18WPdDEewf8ua2Dy7pXYYjaZlDusepPDEewf8ua2Dy7pXANW1tyLcbTbgk6eyDcxS1jwwoHvke0gyOOtG1j2WfpXAC0ey18C0OXQ55gh72ihpok9jINcC15OawzeRso6QNiIrQbvbc6w6ugradoDO1qqCLpCILLtaMXhgCVoLreWGthAneex5dAgPK1lpbwNqfiCILLtyjtfzARuiOnWqrNaRtSXMNyTtSSCc8DcskPhqA1kznpC6WiI1jGvZRvQFyC0ey18CuCdZhuJQhYi585diUXX2944XrPpr8uGRohfWkJyvYrbZ4ddUxNYicyWPdTgcIR8bnJuY6LNaRt0AZtSSCcRuiOnWqrNy9tKaRMxRYjzHkF40HPBeBSgnygFyW9Ny3jC5MNyz5ewPqqBGHIobwNWLBYrtGvZZrv5KSqLpC6W0nInwd34yVDC84OjWQ55OSkkYtW6HYOeqCu6tepf4QZno2T2KJhhnbwnphvHug2E40HEhqfGbgLksok9jINcC15gh7wT44XrPpr8uGRohfWkJyvYrTKPImDdLERrhbStS(jCVnpXYYjSKPImDdLERrhbStGvStSXMNyz5ewYurM2kfcAdmcyWn28eRFcxUjhnbwnphLrzu9QGDFQqsUXnoQ044XXUfhpok9jINcC15OawzeRsokItVR7m6DBV2j6eUEceNEx3z072EnJuY6LNaRtOceoXUtGKmekaLnJbvXsabJiwnHtSSCcWm(WG71iK0Q0dXXsRrZiLSE5jC9eREIUJ3dzeOjzQiOvk0jW6eQaHtSSCI0nIvgPJyLs6H1lT6bMutFI4PWjC9eGz8Hb3Rtzebm40HwdbXv(GMrkz9YtG1jubcNynoAcSAEoksYqOau2mg34yVbhpok9jINcC15OawzeRsoAFaoYtS7e9b4i1msf9Ny7DcvGWjW6e9b4i1kzBpHRNaXP31iK0Q0dXXsRrhgC)jC9eREc8DIWyAW8a6nwAua29PcbrCyVMrkz9Yt46jW3jsGvZRbZdO3yPrby3NkKUEy3xQAStS2jwwor3X7Hmc0Kmve0kf6eyDcvGWjwwoHvke0gyOOtG1jWahnbwnphfmpGEJLgfGDFQqCJJTl54XrPpr8uGRohfWkJyvYrrC6DDkJiGbNo0AiiUYh0Hb3FcxpXQNamJpm4EnsYqOau2mMg0KmvK8eyDIwNyz5e47ePBeRmshXkL0dRxA1dmPM(eXtHtSghnbwnphnLreWGthAneex5dCJJT7WXJJsFI4PaxDokGvgXQKJI4076ugradoDO1qqCLpODIoHRNaXP31iK0Q0dXXsRr7eDILLtyLcbTbgk6eyDIwyGJMaRMNJkTujIce34yJboEC0ey18C0eQ4WcedoDiGn4KCu6tepf4QZno2Uihpok9jINcC15OawzeRsokItVRriPvPhIJLwJom4(tSSCcRuiOnWqrNaRtGboAcSAEoAFaoskat3iwzeeHsfUXXUnYXJJsFI4PaxDokGvgXQKJI407AgbwXtsjSpmaPDIoXYYjqC6DnJaR4jPe2hgGGGX5nIPLwcw5eyDIwBEILLtyLcbTbgk6eyDcmWrtGvZZrTgc68iJZhG9HbiUXX2944XrPpr8uGRohfWkJyvYrX3jqC6DncjTk9qCS0A0orNW1taMXhgCVoLreWGthAneex5dAgPK1lpX6NOfgoXYYjSsHG2adfDcSorlmCIDNqfiWrtGvZZrriPvPhIJLwd34yVDC84O0NiEkWvNJcyLrSk5OPBeRmshYhqWPdduAnAw(RCI1prRt46jqC6DDiFabNomqP1OzKswV8eyDcvGahnbwnphfjziuakBgJBCSBTjhpok9jINcC15OawzeRsokItVRtzebm40HwdbXv(GMrkz9YtS(jAT5j2DcvGWjwwoHvke0gyOOtG1jAT5j2DcvGahnbwnphfXptaoDO1qq6jL9CJJDRwC84OjWQ55ORuEpemkk5h4O0NiEkWvNBCSBTbhpok9jINcC15OawzeRsokItVRriPvPhIJLwJom4(tSSCclzQitBLcbTbgk6eyDcmWrtGvZZrrsvWPdnwbwrYno2TCjhpoAcSAEokOPusILqzZyCu6tepf4QZno2TChoEC0ey18C0qXiicLsJJsFI4PaxDUXXUfg44XrPpr8uGRohfWkJyvYrT0tVPNNG4kRbAnemkbROPpr8u4eUEcqtYursyNLaRMp9Ny9t0sJHtSSCcqtYursyNLaRMp9Ny9t0s7ENyz5eGz8Hb3Rtzebm40HwdbXv(GMrkz9YtG1jqC6DDNrVB71bhwA18NaJoHkq4eUEI0nIvgPJyLs6H1lT6bMutFI4PWjwwoHvke0gyOOtG1j2ooAcSAEoksYqOau2mg34y3Yf54XrPpr8uGRohfWkJyvYrrC6DncjTk9qCS0A0Hb3FILLtyLcbTbgk6eyDc3JJMaRMNJg5WQ((6vbr8P04gh7wTroEC0ey18Cue)mb40HwdbPNu2ZrPpr8uGRo34y3Y944XrtGvZZrrsglvrCu6tepf4QZno2T2ooECu6tepf4QZrbSYiwLC0vprFaoYtGrNams7e7orFaosnJur)j2ENy1taMXhgCVELY7HGrrj)GMrkz9YtGrNO1jw7eRFIey186vkVhcgfL8dAWiTtSSCcWm(WG71RuEpemkk5h0msjRxEI1prRtS7eQaHt46jaZ4ddUxJqsRspehlTgnJuY6LqvoKuEI1prFaosTvke0gOs22tSSCceNExRqkdBpC6qVdOcWaJsfP2j6eRDcxpbygFyW96vkVhcgfL8dAgPK1lpX6NO1jwwoHvke0gyOOtG1jCjhnbwnphfmiSekBgJBCS3ytoEC0ey18Cuzuzw9QGGbHLCu6tepf4QZno2B0IJhhL(eXtbU6CuaRmIvjhfXP31Dg9UTxhCyPvZFcm6eQaHtS(j6oEpKrGMKPIGwPqC0ey18CuKKHqbOSzmUXnoQJv(Y2ZXJJDloEC0ey18CuW48gXGYMX4O0NiEkWvNBCS3GJhhnbwnphvsm6lBpm4inok9jINcC15ghBxYXJJMaRMNJkJggbb(XjWrPpr8uGRo34y7oC84OjWQ55OYzSM6vbXLgX4O0NiEkWvNBCSXahpoAcSAEoQC(car8P04O0NiEkWvNBCSDroEC0ey18C0NSgIbLndyfok9jINcC15gh72ihpoAcSAEokOPAZscnw(ySt5lBphL(eXtbU6CJJT7XXJJMaRMNJkJkwzqzZawHJsFI4PaxDUXXE744XrtGvZZr)0CyKeQILaIJsFI4PaxDUXnUXrvJyYAEo2BS5gBU5gB4sokUK91RsYr3wBJle2BbS3IU)jobEn0jkLOHzNOpStG)a1thVH)tWim2Pyu4eYrHor6yJsAu4eGM8vrs9fVnupDc3X9pH7oVAeZOWjWVXQFfY0UanygFyW94)e2Cc8dMXhgCV2fG)tSAR2UM(IFX3wBJle2BbS3IU)jobEn0jkLOHzNOpStGFGNs1i8FcgHXofJcNqok0jshBusJcNa0KVksQV4TH6Pt0Y9pH7oVAeZOWjWFezAxGEl1An(pHnNa)BPwRX)jwDJ2UM(I3gQNoXgU)jC35vJygfob(Jit7c0BPwRX)jS5e4Fl1An(pXQTA7A6lEBOE6eT2W9pH7oVAeZOWjWFezAxGEl1An(pHnNa)BPwRX)jwDJ2UM(IFX3wBJle2BbS3IU)jobEn0jkLOHzNOpStGFqqI)tWim2Pyu4eYrHor6yJsAu4eGM8vrs9fVnupDcm4(NWDNxnIzu4e4pImTlqVLATg)NWMtG)TuR14)eR6Y2UM(IFX3wBJle2BbS3IU)jobEn0jkLOHzNOpStGFPH)tWim2Pyu4eYrHor6yJsAu4eGM8vrs9fVnupDIwU)jC35vJygfob(Jit7c0BPwRX)jS5e4Fl1An(pXQB0210x82q90jAHb3)eU78QrmJcNa)rKPDb6TuR14)e2Cc8VLATg)Ny1wTDn9fVnupDInA5(NWDNxnIzu4e4pImTlqVLATg)NWMtG)TuR14)eR2QTRPV4x8TGs0WmkCcx8ejWQ5pHVKMuFX5OrSPxEIJU1tOoLs7eUWP0i2(tS958gXU4B9enMfjDFmXuvznoiAWOGPSuC8PvZdyz3WuwkamV4B9eUWjd0CIwTFIn2CJnV4x8TEc3TjFvK09V4B9ey0j2MqGcNWDhN3i2jqBg7e2CIa1thVDIey18NWxstFX36jWOtS9lPtyLcbTbgk6eRQMuFclzQitBLcbTbgkATtyZjY3kqfLgDc6dNy6NGEW48gX0x8TEcm6eBtiCIqjJiVeZihMksEc1Q8eow5lB)jsGvZFcFjn9fFRNaJoHXQFfY0UaDtkHGz8Hb3FIsEcNx6efnmJc6l(wpbgDc3THaRCI(WobGvgmcyqGdJrVPV4x8TEITnTLaogfobc1hgDcWOGK2jqiv1l1NyBaakYKN4NhJAsMs3XFIey18YtmVFV(IV1tKaRMxQJyeyuqslw3NYvU4B9ejWQ5L6igbgfK02fdZ0rLc9wA18x8TEIey18sDeJaJcsA7IHzFMWfpbwnVuhXiWOGK2UyykDuuMhgr2fFRNa9ZizZyNGLv4eio9ofoH0stEceQpm6eGrbjTtGqQQxEI8dNiIryu0yw9QorjpryEsFX36jsGvZl1rmcmkiPTlgMYpJKnJbLwAYlEcSAEPoIrGrbjTDXW0rsWYiL2)uHILUjBswkH95n40HrdoIDXtGvZl1rmcmkiPTlgM4gMpOgvpKrY5Zhqx8ey18sDeJaJcsA7IHPkNKfQ8HthMUrSXAU4jWQ5L6igbgfK02fdtfszy7Hth6DavagyuQiV4jWQ5L6igbgfK02fdthjblJuAN6DcyWpvOyG9a)yS5laeXNsR9QhdFSScqsn6nD9Q54FILiEstTTKM01vjm2PIIOGwTKvjING1B0llBpuvPkvB8gCKGY7tREvqgLaByRDXtGvZl1rmcmkiPTlgMoscwgP0o17eWGFQqXa7b(XyZxaiIpLw7vpg(yzfGKA0B66vZX)elr8KMABjnPRRAS6xHmDlDtkHGz8Hb3VZy1Vcz6n0nPecMXhgCpwBSSqyStffrbTAjRsepbR3Oxw2EOQsvQ24n4ibL3Nw9QGmkb2Ww7INaRMxQJyeyuqsBxmm7dWrsby6gXkJGiuQ0E1JHpwwbiPg9MUE1C8pXsepPP2wstEX36j2MqB6in5jSg6ebhwA18Ni)WjaZ4ddU)et)eBJmIa2jM(jSg6eBRYhor(HtSTLvkP)eBHxA1dm5jq2FcRHorWHLwn)jM(jY)eoFtknkCITO7UTFcCn0FcRH2JFgDchjforeJaJcsA6tSnYtSnJTTortkprEIwAxkpXw0D32pr(HtK9obm5jkts((jSMsEIsEIw6ws9fpbwnVuhXiWOGK2UyyMYicyWPdTgcIR8H2JyeiLg0kfkwlDR2REm8LUrSYiDeRuspSEPvpWKA6tepfCfFKuspG0KuspGGthAneSpahz9QGfRKALSnhMRRsyStffrbD6MSjzPe2N3Gthgn4i2Yc(im2PIIOGgSh4hJnFbGi(uARDX36j2MqB6in5jSg6ebhwA18Ni)WjaZ4ddU)et)eQtsRs)j2wS0Aor(HtS9LUrNy6NWfkvrNaz)jSg6ebhwA18Ny6Ni)t48nP0OWj2IU72(jW1q)jSgAp(z0jCKu4ermcmkiPPV4jWQ5L6igbgfK02fdtesAv6H4yP10EeJaP0GwPqXAPXq7vpw6gXkJ0rSsj9W6Lw9atQPpr8uWv8rsj9astsj9acoDO1qW(aCK1RcwSsQvY2CyUUkHXovuef0PBYMKLsyFEdoDy0GJyll4JWyNkkIcAWEGFm28faI4tPT2fpbwnVuhXiWOGK2Uyygnwn)f)INaRMxQDSYx2(yGX5nIbLnJDXtGvZl1ow5lB)Uyykjg9LThgCK2fpbwnVu7yLVS97IHPmAyee4hNWfpbwnVu7yLVS97IHPCgRPEvqCPrSlEcSAEP2XkFz73fdt58faI4tPDXtGvZl1ow5lB)Uyy(K1qmOSzaRCXtGvZl1ow5lB)UyycAQ2SKqJLpg7u(Y2FXtGvZl1ow5lB)UyykJkwzqzZaw5INaRMxQDSYx2(DXW8tZHrsOkwcOl(fFRNyBtBjGJrHtqQrS9NWkf6ewdDIeyd7eL8ePAz5tepPV4jWQ5LXaP3dtGvZd9L0A)tfkMJv(Y23E1JfieNExdsPvVkTt0YcItVRdLmI8(eXtqLuvb0orllio9UouYiY7tepbPNLQiTt0fpbwnVCxmmDKeSmsr2E1JfXi1GQabDlDkJiGbNo0AiiUYhwwSsHG2adfH1gBEXtGvZl3fdthjblJuA)tfkw6MSjzPe2N3Gthgn4iw7vpgygFyW96ugradoDO1qqCLpOzKswVeQYHKsSAHbxTsHG2adfTERnV4jWQ5L7IHPJKGLrkT)PcflLnQLpjHS0THbbdl9Tx9ybcXP31S0THbbdl9WaH407ANixxfFeg7urruqNUjBswkH95n40HrdoITSyS6xHmD6MSjzPe2N3Gthgn4iMgmJpm4EnJuY6LR7EU4YcjL0dinIFMaC6qRHG0tk71kzBoS1CD1igPgufiOBPtzebm40HwdbXv(WYc(im2PIIOGgSh4hJnFbGi(uAUI4076ugradoDO1qqCLpOzKswVC9TBnxxfFKuspG0G5d0lPa0xDQpmaPvY2Cyllio9UwLtYcv(WPdt3i2ynANO1CDvlzQit3qP3A0radlxIHLf8rsj9asdMpqVKcqF1P(WaKwjBZHTSGpl90B6vkVNyW6Lw9attFI4PWAllRgieNExZs3ggemS0ddeItVRddUFzXkfcAdmuewB4IR5Qvke0gyOO1xDd3z7TkygFyW9AWEGFm28faI4tPPzKswVCN7GLvke0gyOO1w7INaRMxUlgMoscwgP0o17eWGFQqXa7b(XyZxaiIpLw7vpgItVRriPvPhIJLwJom4(LfRuiOnWqryHHlEcSAE5UyycsVhMaRMh6lP1(NkumqqEXtGvZl3fdtq69Wey18qFjT2)uHIjT2RESeyLAeKEsPijwBCXtGvZl3fdtq69Wey18qFjT2)uHIb8uQg1E1JLaRuJG0tkfjxV1f)INaRMxQbbzS8bK0yPhcsVV9QhdmJpm4EncjTk9qCS0A0msjRxUUl38INaRMxQbb5Uyy2lgH4Nj0E1JbMXhgCVgHKwLEiowAnAgPK1lx3LBEXtGvZl1GGCxmmriMKyRuVQ2REmeNExNYicyWPdTgcIR8bTtKRRALcbTbgkADWm(WG71ietsSvQxLo4WsRMFxWHLwn)YYQwYurMUHsV1OJagwUedll4Zsp9MELY7jgSEPvpW00NiEkS2AllwPqqBGHIWQLlV4jWQ5LAqqUlgMi(zcWUdBF7vpgItVRtzebm40HwdbXv(G2jY1vTsHG2adfToygFyW9Ae)mby3HTxhCyPvZVl4WsRMFzzvlzQit3qP3A0radlxIHLf8zPNEtVs59edwV0QhyA6tepfwBTLfRuiOnWqry1YfV4jWQ5LAqqUlgM(svJjHTPtqLc9w7vpwezAqAAeNEx3z072ETtKRrKPbPPrC6DDNrVB71msjRxUUkqqRKTDzbFrKPbPPrC6DDNrVB71orx8ey18snii3fdZOXQ5BV6XqC6DncjTk9qCS0A0orUI4076ugradoDO1qqCLpODIC1sMkY0nu6TgDeWWYLyyzz1vbZlDusepPJgRMhoDOZJWQGNcWUdB)YcyEPJsI4jTZJWQGNcWUdB)AUALcbTbgkclxS1YIvke0gyOiS2Wfx7INaRMxQbb5UyyIBy(GAu9qgjNpFa1E1JTAeJudQce0T0PmIagC6qRHG4kFyzbmJpm4EDkJiGbNo0AiiUYh0msjRxILkqyzXsMkY0wPqqBGHIWAJnxBzbFKuspG0QvYAE40HreRtaRMxRu)WU4jWQ5LAqqUlgMQCswOYhoDy6gXgRP9QhdmJpm4EDkJiGbNo0AiiUYh0msjRxIvRnxwSsHG2adfTEcSAETkNKfQ8HthMUrSXA0Gz8Hb3VZLBUSyLcbTbgkclxU5fpbwnVudcYDXWKvrrEcwpugLa6INaRMxQbb5UyyQqkdBpC6qVdOcWaJsf5fFRNibwnVudcYDXWejvbNo0yfyf5fpbwnVudcYDXWKrzu9QGDFQqY2REmlzQit3qP3A0raBD3BZLflzQit3qP3A0radRyBS5YILmvKPTsHG2aJagCJnx3LBEXV4jWQ5LAGNs1OyijdHcqzZyTd2d8e0sMkYKXA1E1JfrMgKMgXP31Dg9UTx7e5AezAqAAeNEx3z072EnJuY6LyftfiOvY2UdjziuakBgdQILacgrSAcx8ey18snWtPA0UyyQ44Ts2mw7vpMkqqRKTfJIitdstJ407AekLge4PunsZiLSE56BQ3adx8ey18snWtPA0UyyIKmekaLnJ1oypWtqlzQitgRv7vpw3X7Hmc0Kmve0kfclvGGwjBRRGz8Hb3RriPvPhIJLwJMrkz9YlEcSAEPg4PunAxmmtzebm40HwdbXv(WfpbwnVud8uQgTlgMslvIOa1E1JH4076ugradoDO1qqCLpODICfXP31iK0Q0dXXsRr7eTSyLcbTbgkcRwy4INaRMxQbEkvJ2fdtesAv6H4yP10E1JbMXhgCVoLreWGthAneex5dAgPK1lHQCiPC9n2CzXsp9MEEcIRSgO1qWOeSIM(eXtHLfRuiOnWqry1cdx8ey18snWtPA0UyycAkLKyju2m2fpbwnVud8uQgTlgMjuXHfigC6qaBWjV4jWQ5LAGNs1ODXWejzSufDXtGvZl1apLQr7IH5kL3dbJIs(H2RESeyLAeKEsPijwUZYc(s3iwzKMLrvaYi)Kbn9jINcx8ey18snWtPA0UyygkgbrOuAx8ey18snWtPA0UyyIKmekaLnJ1oypWtqlzQitgRv7vpwezAqAAeNEx3z072EDyW9UUkOjzQijSZsGvZN(1BPDVLfeNExJqsRspehlTgTt0AllGz8Hb3Rtzebm40HwdbXv(GMrkz9sSIitdstJ4076oJE32RdoS0Q5XivGGRPBeRmshXkL0dRxA1dmPM(eXtHLfqtYursyNLaRMp9R3s7ollwPqqBGHIWA7U4jWQ5LAGNs1ODXWSpahjfGPBeRmcIqPYfpbwnVud8uQgTlgMroSQVVEvqeFkTlEcSAEPg4PunAxmmbZdO3yPrby3Nk0fpbwnVud8uQgTlgMi(zcWPdTgcspPS)INaRMxQbEkvJ2fdtRHGopY48byFyaQ9QhdXP31mcSINKsyFyas7eTSG407AgbwXtsjSpmabbJZBetlTeScwT28INaRMxQbEkvJ2fdtfhVvYMXAV6Xs3iwzKMLrvaYi)Kbn9jINcUMaRuJG0tkfjxFJlEcSAEPg4PunAxmmbdclHYMXAV6XaZ4ddUxVs59qWOOKFqZiLSE569b4i1wPqqBGkzBDD1eyLAeKEsPijwUCzbFPBeRmsZYOkazKFYGM(eXtH1U4jWQ5LAGNs1ODXWugvMvVkiyqy5f)INaRMxQLwmKKHqbOSzS2RESiY0G00io9UUZO3T9ANixJitdstJ4076oJE32RzKswVelvGWoKKHqbOSzmOkwciyeXQjSSaMXhgCVgHKwLEiowAnAgPK1lDD1UJ3dzeOjzQiOvkewQaHLL0nIvgPJyLs6H1lT6bMutFI4PGRGz8Hb3Rtzebm40HwdbXv(GMrkz9sSubcRDXtGvZl1sBxmmbZdO3yPrby3Nku7vpwFaoYD9b4i1msf9BpvGaw9b4i1kzBDfXP31iK0Q0dXXsRrhgCVRRIVWyAW8a6nwAua29PcbrCyVMrkz9sxXxcSAEnyEa9glnka7(uH01d7(svJT2Ys3X7Hmc0Kmve0kfclvGWYIvke0gyOiSWWfpbwnVulTDXWmLreWGthAneex5dTx9yio9UoLreWGthAneex5d6WG7DDvWm(WG71ijdHcqzZyAqtYursSATSGV0nIvgPJyLs6H1lT6bMutFI4PWAx8ey18sT02fdtPLkruGAV6XqC6DDkJiGbNo0AiiUYh0orUI407AesAv6H4yP1ODIwwSsHG2adfHvlmCXtGvZl1sBxmmtOIdlqm40Ha2GtEXtGvZl1sBxmm7dWrsby6gXkJGiuQ0E1JH407AesAv6H4yP1OddUFzXkfcAdmuewy4INaRMxQL2UyyAne05rgNpa7ddqTx9yio9UMrGv8Kuc7ddqANOLfeNExZiWkEskH9HbiiyCEJyAPLGvWQ1MllwPqqBGHIWcdx8ey18sT02fdtesAv6H4yP10E1JHpeNExJqsRspehlTgTtKRGz8Hb3Rtzebm40HwdbXv(GMrkz9Y1BHHLfRuiOnWqry1cd7ubcx8ey18sT02fdtKKHqbOSzS2RES0nIvgPd5di40HbkTgnl)vwVLRio9UoKpGGthgO0A0msjRxILkq4INaRMxQL2UyyI4NjaNo0Aii9KY(2REmeNExNYicyWPdTgcIR8bnJuY6LR3AZDQaHLfRuiOnWqry1AZDQaHlEcSAEPwA7IH5kL3dbJIs(HlEcSAEPwA7IHjsQcoDOXkWkY2REmeNExJqsRspehlTgDyW9llwYurM2kfcAdmuewy4INaRMxQL2UyycAkLKyju2m2fpbwnVulTDXWmumcIqP0U4jWQ5LAPTlgMijdHcqzZyTx9yw6P30ZtqCL1aTgcgLGv00NiEk4kOjzQijSZsGvZN(1BPXWYcOjzQijSZsGvZN(1BPDVLfWm(WG71PmIagC6qRHG4kFqZiLSEjwrKPbPPrC6DDNrVB71bhwA18yKkqW10nIvgPJyLs6H1lT6bMutFI4PWYIvke0gyOiS2UlEcSAEPwA7IHzKdR67RxfeXNsR9QhdXP31iK0Q0dXXsRrhgC)YIvke0gyOiSCVlEcSAEPwA7IHjIFMaC6qRHG0tk7V4jWQ5LAPTlgMijJLQOlEcSAEPwA7IHjyqyju2mw7vp2Q9b4iXiWiTD9b4i1msf9BVvbZ4ddUxVs59qWOOKFqZiLSEjg1AT1tGvZRxP8EiyuuYpObJ0wwaZ4ddUxVs59qWOOKFqZiLSE56T2PceCfmJpm4EncjTk9qCS0A0msjRxcv5qs569b4i1wPqqBGkzBxwqC6DTcPmS9WPd9oGkadmkvKANO1CfmJpm4E9kL3dbJIs(bnJuY6LR3AzXkfcAdmuewU8INaRMxQL2UyykJkZQxfemiS8INaRMxQL2UyyIKmekaLnJ1E1JfrMgKMgXP31Dg9UTxhCyPvZJrQaH17oEpKrGMKPIGwPqCuzeb4yVbgCj34gNd]] )


    spec:RegisterOptions( {
        enabled = true,

        potion = "unbridled_fury",

        buffPadding = 0,

        nameplates = false,
        nameplateRange = 8,

        aoe = 3,

        damage = true,
        damageExpiration = 3,

        package = "Beast Mastery",
    } )


    spec:RegisterSetting( "aspect_vop_overlap", false, {
        name = "|T136074:0|t Aspect of the Wild Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T136074:0|t Aspect of the Wild even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Aspect of the Wild would cost you one or more uses of Aspect of the Wild in a given fight.",
        type = "toggle",
        width = "full"
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


end
