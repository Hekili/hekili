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


    spec:RegisterPack( "Beast Mastery", 20200223, [[d0K1mbqiusEKsPSjQK(evcJsPOtPuyvkLQ6vkvnlPuUfkQSls9luWWKs1XKQAzsjEgvQmnuu11qrzBujQVjLenous15ukH1rLQAEOq3tOSpPkDqLsQfsf1dPsvMOsPsDrQePAJujs5JkLiJuPuLoPsPIvkuntPKWnvkvXorrgQsPsAPujsEkKMkkXvvkvIVQuIASujIZQus2lQ(lObt4WIwmepgyYcUmYMvYNPcJwkoTKvlLKETufZMQUnj2TQ(TIHlKJJsklhQNt00PCDsA7ur(ok14LsQZRuz9uPmFPY(vzEFolC0qAeNPwAVL2BVLwCNU9TODwN5zDoQTlI4OrjON0bXr)uH4OotP0oX2tkncVJJgL78tg4SWrLJkgqC0gZIKUpdm4OSgvenyuyqwkQ(0Q5b4CzmilfadCue1YBBNNJWrdPrCMAP9wAV9wAXD623I2zDMVfoAQAndMJIwkUhhTPcb65iC0ajbC0TDcNPuANy7jLgH3DITx13i8fFBNOXSiP7ZadokRrfrdgfgKLIQpTAEaoxgdYsbWWfFBNWLgHGvt8Ut0slTDIwAVL2V4x8TDc3RjFhK09V4B7em3j26qGcNW9g13i8jqBg7e2CIaTsvVDIey18NWxstFX32jyUtSDrsNWkfcAdmu0j20jP(ewIDqM2kfcAdmu0gNWMtKVvGkkn6e0hoXSob9Gr9ncRV4B7em3j26q4eHsgrEjdrQyhK8eov5juTYx2UtKaRM)e(sA6l(2obZDcdxFpKPDj6MucbZ4dd7)eL8eQVunkAWgf0x8TDcM7eUxdb65eRbFcaUmyeWGavmMEtZr9L0KCw4ObALQEJZcNP(Cw4O0NiEkWDMJcWLr4k5ObcrDT0GuA17qRgDIUUtGOUw6qjJiVpr8eujDuaTA0j66obI6APdLmI8(eXtq6XPdsRgXrtGvZZrbP3dtGvZd9L04O(sAWpvioQQv(Y2XnotTWzHJsFI4Pa3zokaxgHRKJgHjNGoabDFDkJiGbNf0Aii7Yhorx3jSsHG2adfDcgprlTZrtGvZZrvLeSmsrYnotUJZchL(eXtbUZC0ey18C00nztItjCnVbNfmAytyokaxgHRKJcMXhg2VoLreWGZcAneKD5dAmPK1lHoujP8emEI(m7eUEcRuiOnWqrNO3t0VDo6NkehnDt2K4ucxZBWzbJg2eMBCMyEolCu6tepf4oZrtGvZZrtzJt5tsioDBWqWGtphfGlJWvYrdeI6APXPBdgcgC6HbcrDT0QrNW1tS5jy1jiwtTIIOGoDt2K4ucxZBWzbJg2e(eDDNamJpmSFD6MSjXPeUM3GZcgnSjSgtkz9Yt07jyDx(eDDNGKs6bKgXptaolO1qq6jLDALSvh8j24eUEInpreMCc6ae091PmIagCwqRHGSlF4eDDNGvNGyn1kkIcAWoGFm88faI4tPDcxpbI6APtzebm4SGwdbzx(Ggtkz9Yt07j2ItSXjC9eBEcwDcskPhqAW8b6Lua6RfTgmG0kzRo4t01Dce11s7qnXHkF4SGPBeESgTA0j24eUEInpHLyhKPBO0Bn6iGDcgpH7y2j66obRobjL0diny(a9ska91IwdgqALSvh8j66obRoHLE6nDpL3tyy9sREGPPpr8u4eBCIUUtS5jceI6APXPBdgcgC6HbcrDT0HH9FIUUtyLcbTbgk6emEIwC5tSXjC9ewPqqBGHIorVNyZt0cZFIT)j28eGz8HH9Rb7a(XWZxaiIpLMgtkz9YtS)em)jy8ewPqqBGHIoXgNydo6NkehnLnoLpjH40Tbdbdo9CJZeZ4SWrPpr8uG7mhnbwnphfSd4hdpFbGi(uACuaUmcxjhfrDT0iK0Q0dzJtRrhg2)j66oHvke0gyOOtW4jyghLwlcyWpviokyhWpgE(car8P04gNjxMZchL(eXtbUZC0ey18Cuq69Wey18qFjnoQVKg8tfIJccsUXzQvYzHJsFI4Pa3zokaxgHRKJMaRCIG0tkfjpbJNOfoAcSAEoki9EycSAEOVKgh1xsd(PcXrLg34mX6Cw4O0NiEkWDMJcWLr4k5OjWkNii9KsrYt07j6ZrtGvZZrbP3dtGvZd9L04O(sAWpviokWtPte34ghnctGrbjnolCM6ZzHJMaRMNJkvvuMhgrghL(eXtbUZCJZulCw4O0NiEkWDMJ(PcXrt3KnjoLW18gCwWOHnH5OjWQ55OPBYMeNs4AEdoly0WMWCJZK74SWrtGvZZrzpyFWjQEiMKZNpG4O0NiEkWDMBCMyEolC0ey18CuhQjou5dNfmDJWJ1WrPpr8uG7m34mXmolC0ey18CufszW7GZc6vbvagWuQi5O0NiEkWDMBCMCzolCu6tepf4oZrtGvZZrb7a(XWZxaiIpLghfGlJWvYrz1jWzfGKt0B66Ds1)eor8KMADjn5jC9eBEcI1uROikODkXvI4jy9g9YY2bDuosNgVbhjO8(0Q3betjWg8j2GJsRfbm4NkehfSd4hdpFbGi(uACJZuRKZchL(eXtbUZC0ey18CuWoGFm88faI4tPXrb4YiCLCuwDcCwbi5e9MUENu9pHtepPPwxstEcxpXMNWW13dz6(6MucbZ4dd7)e7pHHRVhY0TOBsjemJpmS)tW4jA5eDDNGyn1kkIcANsCLiEcwVrVSSDqhLJ0PXBWrckVpT6DaXucSbFIn4O0Arad(PcXrb7a(XWZxaiIpLg34mX6Cw4O0NiEkWDMJcWLr4k5OS6e4ScqYj6nD9oP6FcNiEstTUKMKJMaRMNJUgGQKcW0ncxgbrOuHBCM2colCu6tepf4oZrJWeiLg0kfIJ2x3NJMaRMNJMYicyWzbTgcYU8bokaxgHRKJYQtKUr4YiDeUuspSEPvpWKA6tepfoHRNGvNGKs6bKMKs6beCwqRHGRbOkR3bSWLuRKT6GpHRNyZtqSMAffrbD6MSjXPeUM3GZcgnSj8j66obRobXAQvuef0GDa)y45laeXNs7eBWnot9BNZchL(eXtbUZC0imbsPbTsH4O91mJJMaRMNJIqsRspKnoTgokaxgHRKJMUr4YiDeUuspSEPvpWKA6tepfoHRNGvNGKs6bKMKs6beCwqRHGRbOkR3bSWLuRKT6GpHRNyZtqSMAffrbD6MSjXPeUM3GZcgnSj8j66obRobXAQvuef0GDa)y45laeXNs7eBWnot97ZzHJMaRMNJgnwnphL(eXtbUZCJBCuGNsNiolCM6ZzHJsFI4Pa3zoAcSAEoksIrOau2mghfGlJWvYrruxl9ctVB70QrNW1tGOUw6fME32PXKswV8emg7eoabTs26tS)eijgHcqzZyqh4eqWicxtGJc2b8e0sSdYKCM6ZnotTWzHJsFI4Pa3zokaxgHRKJ6ae0kzRpbZDce11sJqP0GapLorAmPK1lprVNODDlmJJMaRMNJQO6Ts2mg34m5oolCu6tepf4oZrtGvZZrrsmcfGYMX4OaCzeUso6s17Hyc0Kyhe0kf6emEchGGwjB9jC9eGz8HH9RriPvPhYgNwJgtkz9sokyhWtqlXoitYzQp34mX8Cw4OjWQ55OPmIagCwqRHGSlFGJsFI4Pa3zUXzIzCw4O0NiEkWDMJcWLr4k5OiQRLoLreWGZcAneKD5dA1Ot46jquxlncjTk9q240A0QrNOR7ewPqqBGHIobJNOpZ4OjWQ55OslvIOaXnotUmNfok9jINcCN5OaCzeUsokygFyy)6ugradolO1qq2LpOXKswVe6qLKYt07jAP9t01Dcl90B65ji7YAGwdbJsqpA6tepforx3jSsHG2adfDcgprFMXrtGvZZrriPvPhYgNwd34m1k5SWrtGvZZrbnLss4ekBgJJsFI4Pa3zUXzI15SWrtGvZZrtOIkoqy4SGa8WwYrPpr8uG7m34mTfCw4OjWQ55OijgNoiok9jINcCN5gNP(TZzHJsFI4Pa3zokaxgHRKJMaRCIG0tkfjpbJNG5prx3jy1js3iCzKgNrvaIj)Kbn9jINcC0ey18C0EkVhcgfL8dCJZu)(Cw4OjWQ55OHctqekLghL(eXtbUZCJZu)w4SWrPpr8uG7mhnbwnphfjXiuakBgJJcWLr4k5OiQRLEHP3TD6WW(pHRNyZtaAsSdscx4ey18P)e9EI(Aw)eDDNarDT0iK0Q0dzJtRrRgDInorx3jaZ4dd7xNYicyWzbTgcYU8bnMuY6LNGXtGOUw6fME32PdQ40Q5pbZDchGWjC9ePBeUmshHlL0dRxA1dmPM(eXtHt01DcqtIDqs4cNaRMp9NO3t0xZ8NOR7ewPqqBGHIobJNyl4OGDapbTe7GmjNP(CJZuF3XzHJMaRMNJUgGQKcW0ncxgbrOuHJsFI4Pa3zUXzQpZZzHJMaRMNJgPIR1U6Dar8P04O0NiEkWDMBCM6ZmolC0ey18CuW8a6nCAuaU8PcXrPpr8uG7m34m13L5SWrtGvZZrr8ZeGZcAneKEszhhL(eXtbUZCJZu)wjNfok9jINcCN5OaCzeUsokI6APXeOhpjLW1GbKwn6eDDNarDT0yc0JNKs4AWaccg13iSwAjONtW4j63ohnbwnph1AiO6JmQFaUgmG4gNP(SoNfok9jINcCN5OaCzeUsoA6gHlJ04mQcqm5NmOPpr8u4eUEIeyLteKEsPi5j69eTWrtGvZZrvu9wjBgJBCM6VfCw4O0NiEkWDMJcWLr4k5OGz8HH9R7P8EiyuuYpOXKswV8e9EI1auLARuiOnqLS1NW1tS5jsGvorq6jLIKNGXt4Ut01DcwDI0ncxgPXzufGyYpzqtFI4PWj2GJMaRMNJcgeCcLnJXnotT0oNfoAcSAEoQmQmREhqWGGtok9jINcCN5g34OGGKZcNP(Cw4O0NiEkWDMJcWLr4k5OGz8HH9RriPvPhYgNwJgtkz9Yt07jCx7C0ey18C08bK0WPhcsVNBCMAHZchL(eXtbUZCuaUmcxjhfmJpmSFncjTk9q240A0ysjRxEIEpH7ANJMaRMNJUkmH4NjWnotUJZchL(eXtbUZCuaUmcxjhfrDT0PmIagCwqRHGSlFqRgDcxpXMNWkfcAdmu0j69eGz8HH9RriSKW9uVdDqfNwn)j2FIGkoTA(t01DInpHLyhKPBO0Bn6iGDcgpH7y2j66obRoHLE6nDpL3tyy9sREGPPpr8u4eBCInorx3jSsHG2adfDcgprF3XrtGvZZrriSKW9uVdUXzI55SWrPpr8uG7mhfGlJWvYrruxlDkJiGbNf0Aii7Yh0QrNW1tS5jSsHG2adfDIEpbygFyy)Ae)mb4sfVthuXPvZFI9NiOItRM)eDDNyZtyj2bz6gk9wJocyNGXt4oMDIUUtWQtyPNEt3t59egwV0QhyA6tepfoXgNyJt01DcRuiOnWqrNGXt03L5OjWQ55Oi(zcWLkEh34mXmolCu6tepf4oZrb4YiCLCue11sVW072oTA0jC9eiQRLEHP3TDAmPK1lprVNWbiOvYwFIUUtWQtGOUw6fME32PvJ4OjWQ55O(YrJjHTQAWHc9g34m5YCw4O0NiEkWDMJcWLr4k5OiQRLgHKwLEiBCAnA1Ot46jquxlDkJiGbNf0Aii7Yh0QrNW1tyj2bz6gk9wJocyNGXt4oMDIUUtS5j28eG5LQkjIN0rJvZdNfu9rWvWtb4sfV7eDDNamVuvjr8Kw9rWvWtb4sfV7eBCcxpHvke0gyOOtW4jC5(NOR7ewPqqBGHIobJNOfx(eBWrtGvZZrJgRMNBCMALCw4O0NiEkWDMJcWLr4k5OBEIim5e0biO7Rtzebm4SGwdbzx(Wj66obygFyy)6ugradolO1qq2LpOXKswV8emEchGWj66oHLyhKPTsHG2adfDcgprlTFInorx3jy1jiPKEaPDQK18WzbJi8IawnVwP(bZrtGvZZrzpyFWjQEiMKZNpG4gNjwNZchL(eXtbUZCuaUmcxjhfmJpmSFDkJiGbNf0Aii7Yh0ysjRxEcgpr)2prx3jSsHG2adfDIEprcSAETd1ehQ8HZcMUr4XA0Gz8HH9FI9NWDTFIUUtyLcbTbgk6emEc31ohnbwnph1HAIdv(Wzbt3i8ynCJZ0wWzHJMaRMNJIROipbRhkJsaXrPpr8uG7m34m1VDolC0ey18CufszW7GZc6vbvagWuQi5O0NiEkWDMBCM63NZchL(eXtbUZCuaUmcxjh1sSdY0nu6TgDeWorVNG1B)eDDNWsSdY0nu6TgDeWobJXorlTFIUUtyj2bzARuiOnWiGbBP9t07jCx7C0ey18CumLr17aU8Pcj5g34OsJZcNP(Cw4O0NiEkWDMJcWLr4k5OiQRLEHP3TDA1Ot46jquxl9ctVB70ysjRxEcgpHdq4e7pbsIrOau2mg0bobemIW1eorx3jaZ4dd7xJqsRspKnoTgnMuY6LNW1tS5jwQEpetGMe7GGwPqNGXt4aeorx3js3iCzKocxkPhwV0Qhysn9jINcNW1taMXhg2VoLreWGZcAneKD5dAmPK1lpbJNWbiCIn4OjWQ55OijgHcqzZyCJZulCw4O0NiEkWDMJcWLr4k5ORbOkpX(tSgGQuJjh0FIT)jCacNGXtSgGQuRKT(eUEce11sJqsRspKnoTgDyy)NW1tS5jy1jcJPbZdO3WPrb4YNkeerf)AmPK1lpHRNGvNibwnVgmpGEdNgfGlFQq66HlF5OXoXgNOR7elvVhIjqtIDqqRuOtW4jCacNOR7ewPqqBGHIobJNGzC0ey18CuW8a6nCAuaU8PcXnotUJZchL(eXtbUZCuaUmcxjhfmJpmSFnsIrOau2mMg0KyhK8emEI(NOR7eS6ePBeUmshHlL0dRxA1dmPM(eXtboAcSAEoAkJiGbNf0Aii7Yh4gNjMNZchL(eXtbUZCuaUmcxjhfrDT0PmIagCwqRHGSlFqRgDcxpbI6APriPvPhYgNwJwn6eDDNWkfcAdmu0jy8e9zghnbwnphvAPsefiUXzIzCw4OjWQ55OjurfhimCwqaEyl5O0NiEkWDMBCMCzolCu6tepf4oZrb4YiCLCue11sJqsRspKnoTgDyy)NOR7ewPqqBGHIobJNGzC0ey18C01auLuaMUr4YiicLkCJZuRKZchL(eXtbUZCuaUmcxjhfrDT0yc0JNKs4AWasRgDIUUtGOUwAmb6XtsjCnyabbJ6BewlTe0Zjy8e9B)eDDNWkfcAdmu0jy8emJJMaRMNJAneu9rg1paxdgqCJZeRZzHJsFI4Pa3zokaxgHRKJYQtGOUwAesAv6HSXP1OvJoHRNamJpmSFDkJiGbNf0Aii7Yh0ysjRxEIEprFMDIUUtyLcbTbgk6emEI(m7e7pHdqGJMaRMNJIqsRspKnoTgUXzAl4SWrPpr8uG7mhfGlJWvYrt3iCzKoKpGGZcgO0A04875e9EI(NW1tGOUw6q(acolyGsRrJjLSE5jy8eoaHt46ja4YGradcuXy6Tt07jy(25OjWQ55OijgHcqzZyCJZu)25SWrPpr8uG7mhfGlJWvYrruxlDkJiGbNf0Aii7Yh0ysjRxEIEpr)2pX(t4aeorx3jSsHG2adfDcgpr)2pX(t4ae4OjWQ55Oi(zcWzbTgcspPSJBCM63NZchnbwnphTNY7HGrrj)ahL(eXtbUZCJZu)w4SWrPpr8uG7mhfGlJWvYrruxlncjTk9q240A0HH9FIUUtyj2bzARuiOnWqrNGXtWmoAcSAEoks6aolOHlqpsUXzQV74SWrtGvZZrbnLss4ekBgJJsFI4Pa3zUXzQpZZzHJMaRMNJgkmbrOuACu6tepf4oZnot9zgNfok9jINcCN5OaCzeUsoQLE6n98eKDznqRHGrjOhn9jINcNW1taAsSdscx4ey18P)e9EI(AMDIUUtaAsSdscx4ey18P)e9EI(Aw)eDDNamJpmSFDkJiGbNf0Aii7Yh0ysjRxEcgpbI6APxy6DBNoOItRM)em3jCacNW1tKUr4YiDeUuspSEPvpWKA6tepforx3jSsHG2adfDcgpXwWrtGvZZrrsmcfGYMX4gNP(UmNfok9jINcCN5OaCzeUsokI6APriPvPhYgNwJomS)t01DcRuiOnWqrNGXtW6C0ey18C0ivCT2vVdiIpLg34m1VvYzHJMaRMNJI4NjaNf0Aii9KYook9jINcCN5gNP(SoNfoAcSAEoksIXPdIJsFI4Pa3zUXzQ)wWzHJsFI4Pa3zokaxgHRKJU5jwdqvEcM7eGrANy)jwdqvQXKd6pX2)eBEcWm(WW(19uEpemkk5h0ysjRxEcM7e9pXgNO3tKaRMx3t59qWOOKFqdgPDIUUtaMXhg2VUNY7HGrrj)Ggtkz9Yt07j6FI9NWbiCcxpbygFyy)AesAv6HSXP1OXKswVe6qLKYt07jwdqvQTsHG2avYwFIUUtGOUwAfszW7GZc6vbvagWuQi1QrNyJt46jaZ4dd7x3t59qWOOKFqJjLSE5j69e9prx3jSsHG2adfDcgpH74OjWQ55OGbbNqzZyCJZulTZzHJMaRMNJkJkZQ3bemi4KJsFI4Pa3zUXzQL(Cw4O0NiEkWDMJcWLr4k5OiQRLEHP3TD6GkoTA(tWCNWbiCIEpXs17Hyc0Kyhe0kfIJMaRMNJIKyekaLnJXnUXrvTYx2oolCM6ZzHJMaRMNJcg13imu2mghL(eXtbUZCJZulCw4OjWQ55OsctFz7GbvPXrPpr8uG7m34m5oolC0ey18Cuz0GjiWpQbok9jINcCN5gNjMNZchnbwnphvoJ1uVdi70imhL(eXtbUZCJZeZ4SWrtGvZZrLZxaiIpLghL(eXtbUZCJZKlZzHJMaRMNJ(K1qyOSza9WrPpr8uG7m34m1k5SWrtGvZZrbnvRwsOHZN1ulFz74O0NiEkWDMBCMyDolC0ey18CuzuHldkBgqpCu6tepf4oZnotBbNfoAcSAEo6NMkMKqh4eqCu6tepf4oZnUXnoQtewwZZzQL2BP92BPDMNJYoXF9oKC0T8w7sX02HPTK7FItWsdDIsjAW2jwd(eUiqRu1BU4eyI1ulmfoHCuOtKQ2OKgfobOjFhKuFXBf1tNG5D)t4EZ7eHnkCcxy467HmTlrdMXhg2VloHnNWfGz8HH9RDjU4eB2V1BOV4x8T8w7sX02HPTK7FItWsdDIsjAW2jwd(eUa4P0jYfNatSMAHPWjKJcDIu1gL0OWjan57GK6lEROE6e9D)t4EZ7eHnkCcxerM2LO3kTw7ItyZjCXwP1AxCInBP1BOV4TI6Pt0I7Fc3BENiSrHt4IiY0Ue9wP1AxCcBoHl2kTw7ItSz)wVH(I3kQNor)wC)t4EZ7eHnkCcxerM2LO3kTw7ItyZjCXwP1AxCInBP1BOV4x8T8w7sX02HPTK7FItWsdDIsjAW2jwd(eUaeKU4eyI1ulmfoHCuOtKQ2OKgfobOjFhKuFXBf1tNGzU)jCV5DIWgfoHlIit7s0BLwRDXjS5eUyR0ATloXMUR1BOV4x8T8w7sX02HPTK7FItWsdDIsjAW2jwd(eUqAU4eyI1ulmfoHCuOtKQ2OKgfobOjFhKuFXBf1tNOV7Fc3BENiSrHt4IiY0Ue9wP1AxCcBoHl2kTw7ItSzlTEd9fVvupDI(mZ9pH7nVte2OWjCrezAxIER0ATloHnNWfBLwRDXj2SFR3qFXBf1tNOL(U)jCV5DIWgfoHlIit7s0BLwRDXjS5eUyR0ATloXM9B9g6l(fF7OenyJcNWLprcSA(t4lPj1xCoQmIaCMAHzUJJgHNv5jo62oHZukTtS9KsJW7oX2R6Be(IVTt0ywK09zGbhL1OIObJcdYsr1NwnpaNlJbzPay4IVTt4sJqWQjE3jAPL2orlT3s7x8l(2oH71KVds6(x8TDcM7eBDiqHt4EJ6Be(eOnJDcBorGwPQ3orcSA(t4lPPV4B7em3j2UiPtyLcbTbgk6eB6KuFclXoitBLcbTbgkAJtyZjY3kqfLgDc6dNywNGEWO(gH1x8TDcM7eBDiCIqjJiVKHivSdsEcNQ8eQw5lB3jsGvZFcFjn9fFBNG5oHHRVhY0UeDtkHGz8HH9FIsEc1xQgfnyJc6l(2obZDc3RHa9CI1GpbaxgmcyqGkgtVPV4x8TDcx6TMaQgfobcTgmDcWOGK2jqih1l1NyRbakYKN4NN5AsSYs1FIey18YtmVFN(IVTtKaRMxQJWeyuqsl2YNYEU4B7ejWQ5L6imbgfK02hJHu1Hc9wA18x8TDIey18sDeMaJcsA7JXWAMWfpbwnVuhHjWOGK2(ymivvuMhgr2fFBNa9ZizZyNaNv4eiQRffoH0stEceAny6eGrbjTtGqoQxEI8dNictmx0yw9oorjpryEsFX32jsGvZl1rycmkiPTpgdYpJKnJbLwAYlEcSAEPoctGrbjT9XyqvsWYiL2(uHILUjBsCkHR5n4SGrdBcFXtGvZl1rycmkiPTpgdShSp4evpetY5Zhqx8ey18sDeMaJcsA7JXGd1ehQ8HZcMUr4XAU4jWQ5L6imbgfK02hJbfszW7GZc6vbvagWuQiV4jWQ5L6imbgfK02hJbvjblJuAJwlcyWpvOyGDa)y45laeXNsRTAfJv4ScqYj6nD9oP6FcNiEstTUKM01njwtTIIOG2PexjING1B0llBh0r5iDA8gCKGY7tREhqmLaBWBCXtGvZl1rycmkiPTpgdQscwgP0gTweWGFQqXa7a(XWZxaiIpLwB1kgRWzfGKt0B66Ds1)eor8KMADjnPRBA467HmDFDtkHGz8HH9V3W13dz6w0nPecMXhg2pJT01rSMAffrbTtjUsepbR3Oxw2oOJYr604n4ibL3Nw9oGykb2G34INaRMxQJWeyuqsBFmgwdqvsby6gHlJGiuQ0wTIXkCwbi5e9MUENu9pHtepPPwxstEX32j26qRQkn5jSg6ebvCA18Ni)WjaZ4dd7)eZ6eBTmIa2jM1jSg6eB5Yhor(HtSDfxkP)eBNxA1dm5jq2DcRHorqfNwn)jM1jY)eQFtknkCITK7TDFc2n0FcRH25cmDcvjforeMaJcsA6tS1YtS1JTLprtkprEI(A3jpXwY92Upr(HtKRfbm5jkts(1jSMsEIsEI(6(s9fpbwnVuhHjWOGK2(ymKYicyWzbTgcYU8H2IWeiLg0kfkwFD)2QvmwLUr4YiDeUuspSEPvpWKA6tepfCLvKuspG0KuspGGZcAneCnavz9oGfUKALSvhSRBsSMAffrbD6MSjXPeUM3GZcgnSjCxhRiwtTIIOGgSd4hdpFbGi(uABCX32j26qRQkn5jSg6ebvCA18Ni)WjaZ4dd7)eZ6eotsRs)j2Y40Aor(HtS9MUrNywNWLkDqNaz3jSg6ebvCA18NywNi)tO(nP0OWj2sU329jy3q)jSgANlW0juLu4erycmkiPPV4jWQ5L6imbgfK02hJbesAv6HSXP10weMaP0GwPqX6RzwB1kw6gHlJ0r4sj9W6Lw9atQPpr8uWvwrsj9astsj9acolO1qW1auL17aw4sQvYwDWUUjXAQvuef0PBYMeNs4AEdoly0WMWDDSIyn1kkIcAWoGFm88faI4tPTXfpbwnVuhHjWOGK2(ymenwn)f)INaRMxQvTYx2UyGr9ncdLnJDXtGvZl1Qw5lB3(ymijm9LTdguL2fpbwnVuRALVSD7JXGmAWee4h1WfpbwnVuRALVSD7JXGCgRPEhq2Pr4lEcSAEPw1kFz72hJb58faI4tPDXtGvZl1Qw5lB3(ym8K1qyOSza9CXtGvZl1Qw5lB3(ymaAQwTKqdNpRPw(Y2DXtGvZl1Qw5lB3(ymiJkCzqzZa65INaRMxQvTYx2U9Xy4ttftsOdCcOl(fFBNWLERjGQrHtqor4DNWkf6ewdDIeyd(eL8ePtz5tepPV4jWQ5LXaP3dtGvZd9L0A7tfkMQv(Y21wTIfie11sdsPvVdTAuxhI6APdLmI8(eXtqL0rb0QrDDiQRLouYiY7tepbPhNoiTA0fpbwnVCFmguLeSmsr2wTIfHjNGoabDFDkJiGbNf0Aii7Yh66SsHG2adfXylTFXtGvZl3hJbvjblJuA7tfkw6MSjXPeUM3GZcgnSjCB1kgygFyy)6ugradolO1qq2LpOXKswVe6qLKsg7ZmxTsHG2adf1B)2V4jWQ5L7JXGQKGLrkT9PcflLnoLpjH40Tbdbdo9TvRybcrDT040Tbdbdo9WaHOUwA1ix3KveRPwrruqNUjBsCkHR5n4SGrdBc31z467HmD6MSjXPeUM3GZcgnSjSgmJpmSFnMuY6L9Y6UCxhjL0dinIFMaCwqRHG0tk70kzRo4nCDZim5e0biO7Rtzebm4SGwdbzx(qxhRiwtTIIOGgSd4hdpFbGi(uAUIOUw6ugradolO1qq2LpOXKswVS3Tydx3KvKuspG0G5d0lPa0xlAnyaPvYwDWDDiQRL2HAIdv(Wzbt3i8ynA1OnCDtlXoit3qP3A0raJr3XSUowrsj9asdMpqVKcqFTO1GbKwjB1b31Xkl90B6EkVNWW6Lw9attFI4PWgDDBgie11sJt3gmem40ddeI6APdd7VRZkfcAdmueJT4YB4Qvke0gyOOE3SfMF7VjygFyy)AWoGFm88faI4tPPXKswVCpZZOvke0gyOOn24INaRMxUpgdQscwgP0gTweWGFQqXa7a(XWZxaiIpLwB1kgI6APriPvPhYgNwJomS)UoRuiOnWqrmYSlEcSAE5(ymasVhMaRMh6lP12NkumqqEXtGvZl3hJbq69Wey18qFjT2(uHIjT2QvSeyLteKEsPijJTCXtGvZl3hJbq69Wey18qFjT2(uHIb8u6e1wTILaRCIG0tkfj7T)f)INaRMxQbbzS8bK0WPhcsVVTAfdmJpmSFncjTk9q240A0ysjRx2R7A)INaRMxQbb5(ymSkmH4Nj0wTIbMXhg2VgHKwLEiBCAnAmPK1l71DTFXtGvZl1GGCFmgqiSKW9uVJ2Qvme11sNYicyWzbTgcYU8bTAKRBALcbTbgkQxWm(WW(1iews4EQ3HoOItRMFFqfNwnFx3MwIDqMUHsV1OJagJUJzDDSYsp9MUNY7jmSEPvpW00NiEkSXgDDwPqqBGHIySV7U4jWQ5LAqqUpgdi(zcWLkExB1kgI6APtzebm4SGwdbzx(GwnY1nTsHG2adf1lygFyy)Ae)mb4sfVthuXPvZVpOItRMVRBtlXoit3qP3A0raJr3XSUowzPNEt3t59egwV0QhyA6tepf2yJUoRuiOnWqrm23LV4jWQ5LAqqUpgd(YrJjHTQAWHc9wB1kwezAqAAe11sVW072oTAKRrKPbPPruxl9ctVB70ysjRx2RdqqRKTURJvrKPbPPruxl9ctVB70Qrx8ey18snii3hJHOXQ5BRwXquxlncjTk9q240A0QrUIOUw6ugradolO1qq2LpOvJC1sSdY0nu6TgDeWy0DmRRBZnbZlvvsepPJgRMholO6JGRGNcWLkExxhyEPQsI4jT6JGRGNcWLkE3gUALcbTbgkIrxUFxNvke0gyOigBXL34INaRMxQbb5(ymWEW(Gtu9qmjNpFa1wTITzeMCc6ae091PmIagCwqRHGSlFORdmJpmSFDkJiGbNf0Aii7Yh0ysjRxYOdqORZsSdY0wPqqBGHIySL23ORJvKuspG0ovYAE4SGreEraRMxRu)GV4jWQ5LAqqUpgdoutCOYholy6gHhRPTAfdmJpmSFDkJiGbNf0Aii7Yh0ysjRxYy)276SsHG2adf1BcSAETd1ehQ8HZcMUr4XA0Gz8HH9V3DT31zLcbTbgkIr31(fpbwnVudcY9XyaxrrEcwpugLa6INaRMxQbb5(ymOqkdEhCwqVkOcWaMsf5fFBNibwnVudcY9XyajDaNf0WfOh5fpbwnVudcY9Xyatzu9oGlFQqY2QvmlXoit3qP3A0raRxwV9UolXoit3qP3A0raJXyT0ExNLyhKPTsHG2aJagSL271DTFXV4jWQ5LAGNsNOyijgHcqzZyTb2b8e0sSdYKX63wTIfrMgKMgrDT0lm9UTtRg5AezAqAAe11sVW072onMuY6LmgZbiOvYwVhjXiuakBgd6aNacgr4Acx8ey18snWtPt0(ymOO6Ts2mwB1kMdqqRKTM5IitdstJOUwAekLge4P0jsJjLSEzVTRBHzx8ey18snWtPt0(ymGKyekaLnJ1gyhWtqlXoitgRFB1k2s17Hyc0Kyhe0kfIrhGGwjBTRGz8HH9RriPvPhYgNwJgtkz9YlEcSAEPg4P0jAFmgszebm4SGwdbzx(WfpbwnVud8u6eTpgdslvIOa1wTIHOUw6ugradolO1qq2LpOvJCfrDT0iK0Q0dzJtRrRg11zLcbTbgkIX(m7INaRMxQbEkDI2hJbesAv6HSXP10wTIbMXhg2VoLreWGZcAneKD5dAmPK1lHoujPS3wAVRZsp9MEEcYUSgO1qWOe0JM(eXtHUoRuiOnWqrm2Nzx8ey18snWtPt0(ymaAkLKWju2m2fpbwnVud8u6eTpgdjurfhimCwqaEylV4jWQ5LAGNsNO9XyajX40bDXtGvZl1apLor7JXqpL3dbJIs(H2QvSeyLteKEsPijJmFxhRs3iCzKgNrvaIj)Kbn9jINcx8ey18snWtPt0(ymekmbrOuAx8ey18snWtPt0(ymGKyekaLnJ1gyhWtqlXoitgRFB1kwezAqAAe11sVW072oDyy)UUjOjXoijCHtGvZN(E7Rz9Uoe11sJqsRspKnoTgTA0gDDGz8HH9Rtzebm4SGwdbzx(Ggtkz9sgJitdstJOUw6fME32PdQ40Q5zohGGRPBeUmshHlL0dRxA1dmPM(eXtHUoqtIDqs4cNaRMp992xZ8DDwPqqBGHIyClU4jWQ5LAGNsNO9XyynavjfGPBeUmcIqPYfpbwnVud8u6eTpgdrQ4ATREhqeFkTlEcSAEPg4P0jAFmgaZdO3WPrb4YNk0fpbwnVud8u6eTpgdi(zcWzbTgcspPS7INaRMxQbEkDI2hJbRHGQpYO(b4AWaQTAfdrDT0yc0JNKs4AWasRg11HOUwAmb6XtsjCnyabbJ6BewlTe0dJ9B)INaRMxQbEkDI2hJbfvVvYMXARwXs3iCzKgNrvaIj)Kbn9jINcUMaRCIG0tkfj7TLlEcSAEPg4P0jAFmgadcoHYMXARwXaZ4dd7x3t59qWOOKFqJjLSEzVRbOk1wPqqBGkzRDDZeyLteKEsPijJURRJvPBeUmsJZOkaXKFYGM(eXtHnU4jWQ5LAGNsNO9XyqgvMvVdiyqW5f)INaRMxQLwmKeJqbOSzS2QvSiY0G00iQRLEHP3TDA1ixJitdstJOUw6fME32PXKswVKrhGWEKeJqbOSzmOdCciyeHRj01bMXhg2VgHKwLEiBCAnAmPK1lDDZLQ3dXeOjXoiOvkeJoaHUU0ncxgPJWLs6H1lT6bMutFI4PGRGz8HH9Rtzebm4SGwdbzx(Ggtkz9sgDacBCXtGvZl1sBFmgaZdO3WPrb4YNkuB1k2AaQY9RbOk1yYb9BFhGaJRbOk1kzRDfrDT0iK0Q0dzJtRrhg2VRBYQWyAW8a6nCAuaU8PcbruXVgtkz9sxzvcSAEnyEa9gonkax(uH01dx(YrJTrx3s17Hyc0Kyhe0kfIrhGqxNvke0gyOigz2fpbwnVulT9XyiLreWGZcAneKD5dTvRyGz8HH9RrsmcfGYMX0GMe7GKm2VRJvPBeUmshHlL0dRxA1dmPM(eXtHlEcSAEPwA7JXG0sLikqTvRyiQRLoLreWGZcAneKD5dA1ixruxlncjTk9q240A0QrDDwPqqBGHIySpZU4jWQ5LAPTpgdjurfhimCwqaEylV4jWQ5LAPTpgdRbOkPamDJWLrqekvARwXquxlncjTk9q240A0HH931zLcbTbgkIrMDXtGvZl1sBFmgSgcQ(iJ6hGRbdO2Qvme11sJjqpEskHRbdiTAuxhI6APXeOhpjLW1GbeemQVryT0sqpm2V9UoRuiOnWqrmYSlEcSAEPwA7JXacjTk9q240AARwXyfI6APriPvPhYgNwJwnYvWm(WW(1PmIagCwqRHGSlFqJjLSEzV9zwxNvke0gyOig7ZS9oaHlEcSAEPwA7JXasIrOau2mwB1kw6gHlJ0H8beCwWaLwJgNFp923ve11shYhqWzbduAnAmPK1lz0bi4kaxgmcyqGkgtV1lZ3(fpbwnVulT9XyaXptaolO1qq6jLDTvRyiQRLoLreWGZcAneKD5dAmPK1l7TF77DacDDwPqqBGHIySF77Dacx8ey18sT02hJHEkVhcgfL8dx8ey18sT02hJbK0bCwqdxGEKTvRyiQRLgHKwLEiBCAn6WW(76Se7GmTvke0gyOigz2fpbwnVulT9Xya0ukjHtOSzSlEcSAEPwA7JXqOWeeHsPDXtGvZl1sBFmgqsmcfGYMXARwXS0tVPNNGSlRbAnemkb9OPpr8uWvqtIDqs4cNaRMp992xZSUoqtIDqs4cNaRMp992xZ6DDGz8HH9Rtzebm4SGwdbzx(Ggtkz9sgJitdstJOUw6fME32PdQ40Q5zohGGRPBeUmshHlL0dRxA1dmPM(eXtHUoRuiOnWqrmUfx8ey18sT02hJHivCT2vVdiIpLwB1kgI6APriPvPhYgNwJomS)UoRuiOnWqrmY6x8ey18sT02hJbe)mb4SGwdbPNu2DXtGvZl1sBFmgqsmoDqx8ey18sT02hJbWGGtOSzS2QvSnxdqvYCGrA7xdqvQXKd63(BcMXhg2VUNY7HGrrj)Ggtkz9sMR)g9MaRMx3t59qWOOKFqdgP11bMXhg2VUNY7HGrrj)Ggtkz9YE7V3bi4kygFyy)AesAv6HSXP1OXKswVe6qLKYExdqvQTsHG2avYw31HOUwAfszW7GZc6vbvagWuQi1QrB4kygFyy)6EkVhcgfL8dAmPK1l7TFxNvke0gyOigD3fpbwnVulT9XyqgvMvVdiyqW5fpbwnVulT9XyajXiuakBgRTAflImninnI6APxy6DBNoOItRMN5Cac9Uu9EiManj2bbTsH4g34Ca]] )


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
