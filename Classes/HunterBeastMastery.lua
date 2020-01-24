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


    spec:RegisterPack( "Beast Mastery", 20200124, [[dW0ojbqisipsjQ2ejQpjQWOuICkLqRsPkLxPuzwsjDlLQYUi1VGIgguOJjLAzkL6zIkAAkvX1Gc2gju(MOs04uIIZjQuwNOs18GsDpQu7tPKdQeLwijYdfvstuPkrxujiYhvQs1ivQs4KkvvzLIQMPsq6MkvvLDcLmuLGOwQsq4PGAQKGRQuvv9vLQKgROs4Skb1Er5VqgmHdlSyqEmWKf5YiBwQ(mv0OLItlz1kvvETuIztv3MK2Tk)wXWfLJtcvlhvpNOPt56q12Ps8DQW4vcCELI1tL08vs7xvZAZuGbNcJyyTng3gJyS927rJXCR9E2dd22Krm4Sa0s4KyWxOsmyLOqAVy)lKgX3WGZIn(jsmfyWYbNdigCJzzYChtmDwwdoKgmQyklvCFy1CaE0nmLLkatgmeE5T93XGyWPWigwBJXTXigBV9E0ym3AVNTvmgCGBndNbdxQ5kdUPsj6yqm4ejbm4L)cLOqAVy)lKgX38I9c8Zi(NF5VOXSmzUJjMolRbhsdgvmLLkUpSAoap6gMYsfG5NF5ViFC4bFZl2UDRVyBmUng)8F(L)ICTjoNKm3)8l)f77flBkrPxKRd(ze)fWnJ9cBErI6bU3EraSAUx4lPP)8l)f77f7)s6fwPsiBqPIEXsUi1VWcUtY0wPsiBqPIw8f28I4ScuzHrVGU0lM(lOdm4NrC9NF5VyFVyztPxKkzg5LyMHZDsYx4sfVa3kFzBEraSAUx4lPP)8l)f77fgVUwitNl0nHebMXNgh3lk5lWpjEw2WnkP)8l)f77f5AdbA5f9H)caVmugWqaCoNotZG9L0KmfyWjQh4EJPadR2mfyW0fqEkXuIbd4Lr8kyWjccV31GqA15uJN9I11xaH376ujZiVpG8esnCwanE2lwxFbeEVRtLmJ8(aYti64HtsJNXGdGvZXGbH3JcGvZH8L0yW(sAOlujgmUv(Y2WmgwBZuGbhaRMJbJljuzKQKbtxa5PetjMXWkNmfyW0fqEkXuIbhaRMJbhUkBcEir95m00rzJdIZGb8YiEfmyRujKnOurVyRx0gJm4lujgC4QSj4He1NZqthLnoioZyyThMcmy6cipLykXGdGvZXGdzJlXrsepCD4iWWdpdgWlJ4vWGteeEVR5HRdhbgE4rjccV314zVq5xS0lY4KliNGKUToKzeWqthzneYr5tVyD9fk6fKIJxzzusd2a8JXNRaiiFiTxO8lGW7DDiZiGHMoYAiKJYN0CsnQt(ITEbgEXIVq5xS0lSG7KmDdfERrNbSxG9lYjgEX66lu0liPKoaPbZLOtsjKV6uF4asRg73WFX66lu0lSWtNPBP8EIJQtA1bmnDbKNsVyXxSU(ILErIGW7DnpCD4iWWdpkrq49UonoUxSU(cRujKnOurVa7xSTI9IfFHYVWkvczdkv0l26fl9IT3Zl2BVyPxaMXNghNgSb4hJpxbqq(qAAoPg1jFXUxSNxG9lSG7KmTvQeYguQOxS4lwKbFHkXGdzJlXrsepCD4iWWdpZyyHbMcmy6cipLykXGdGvZXGbBa(X4ZvaeKpKgdgWlJ4vWGHW7DnejTk8ih8WA0PXX9I11xyLkHSbLk6fy)cmWGPENag6cvIbd2a8JXNRaiiFinMXWsXykWGPlG8uIPedoawnhdgeEpkawnhYxsJb7lPHUqLyWGKKzmSYLmfyW0fqEkXuIbd4Lr8kyWbWkxieDKArYxG9l2MbhaRMJbdcVhfaRMd5lPXG9L0qxOsmyPXmgwldtbgmDbKNsmLyWaEzeVcgCaSYfcrhPwK8fB9I2m4ay1Cmyq49Oay1CiFjngSVKg6cvIbd8u4cXmMXGZ4eyuHcJPadR2mfyWbWQ5yWsCv15qzKXGPlG8uIPeZyyTntbgmDbKNsmLyWxOsm4WvztWdjQpNHMokBCqCgCaSAogC4QSj4He1NZqthLnoioZyyLtMcm4ay1Cmyhd3NCHQdXj5CXbigmDbKNsmLygdR9WuGbhaRMJb7ep4Pko00rHReFSggmDbKNsmLygdlmWuGbhaRMJbRsQdFdA6ipoOsOeNcvjdMUaYtjMsmJHLIXuGbtxa5PetjgCaSAogmydWpgFUcGG8H0yWaEzeVcgSIEbpQeICHotxNl4(J4bKN00ckPjFHYVyPxqkoELLrjTlbVcipHQZOtw2gKZYz4Y4n0ibL3hwDorCka2WFXImyQ3jGHUqLyWGna)y85kacYhsJzmSYLmfyW0fqEkXuIbhaRMJbd2a8JXNRaiiFingmGxgXRGbROxWJkHixOZ015cU)iEa5jnTGsAYxO8lw6fgVUwit3w3eseygFACCVy3lmEDTqMEBDtirGz8PXX9cSFX2VyD9fKIJxzzus7sWRaYtO6m6KLTb5SCgUmEdnsq59HvNteNcGn8xSidM6DcyOlujgmydWpgFUcGG8H0ygdRLHPadMUaYtjMsmyaVmIxbdwrVGhvcrUqNPRZfC)r8aYtAAbL0Km4ay1Cm4(aWLucfUs8YieefQmJHvUXuGbtxa5PetjgCgNaH0qwPsm4262m4ay1Cm4qMradnDK1qihLpXGb8YiEfmyf9IWvIxgPZ4LA4r1jT6aMutxa5P0lu(fk6fKushG0KushGqthzneQpaCzDorfVKA1y)g(lu(fl9csXXRSmkPdxLnbpKO(CgA6OSXbXFX66lu0lifhVYYOKgSb4hJpxbqq(qAVyrMXWQngzkWGPlG8uIPedoJtGqAiRujgCBngyWbWQ5yWqK0QWJCWdRHbd4Lr8kyWHReVmsNXl1WJQtA1bmPMUaYtPxO8lu0liPKoaPjPKoaHMoYAiuFa4Y6CIkEj1QX(n8xO8lw6fKIJxzzushUkBcEir95m00rzJdI)I11xOOxqkoELLrjnydWpgFUcGG8H0EXImJHv72mfyWbWQ5yWzJvZXGPlG8uIPeZygdg4PWfIPadR2mfyW0fqEkXuIbhaRMJbdfCikHKnJXGb8YiEfmyi8Ex35056gnE2lu(fq49UUZPZ1nAoPg1jFb2UFHtqsRgl4f7EbuWHOes2mgYjpaekJ41KyWGnapHSG7KmjdR2mJH12mfyW0fqEkXuIbd4Lr8kyWobjTASGxSVxaH37AikKgc4PWfsZj1Oo5l26fyuVngyWbWQ5yWQ4ERKnJXmgw5KPadMUaYtjMsm4ay1CmyOGdrjKSzmgmGxgXRGb3X9EeNanb3jHSsLEb2VWjiPvJf8cLFbygFACCAisAv4ro4H1O5KAuNKbd2a8eYcUtYKmSAZmgw7HPadoawnhdoKzeWqthzneYr5tmy6cipLykXmgwyGPadMUaYtjMsmyaVmIxbdgcV31HmJagA6iRHqokFsJN9cLFbeEVRHiPvHh5GhwJgp7fRRVWkvczdkv0lW(fTXadoawnhdwAHAgLiMXWsXykWGPlG8uIPedgWlJ4vWGbZ4tJJthYmcyOPJSgc5O8jnNuJ6KiN4Ku(ITEX2y8fRRVWcpDMEoc5OSgK1qOSa0IMUaYtPxSU(cRujKnOurVa7x0gdm4ay1CmyisAv4ro4H1Wmgw5sMcm4ay1CmyqtPgepqYMXyW0fqEkXuIzmSwgMcm4ay1Cm4aPIZtehnDeGpoKmy6cipLykXmgw5gtbgCaSAogmuW5HtIbtxa5PetjMXWQngzkWGPlG8uIPedgWlJ4vWGdGvUqi6i1IKVa7xSNxSU(cf9IWvIxgP5rwLqCYprstxa5PedoawnhdULY7rGrvnUeZyy1UntbgCaSAogCQ4ecIcPXGPlG8uIPeZyy1EBMcmy6cipLykXGdGvZXGHcoeLqYMXyWaEzeVcgmeEVR7C6CDJonoUxO8lw6fGMG7KKOopawnx4FXwVOTEzEX66lGW7DnejTk8ih8WA04zVyXxSU(cWm(0440HmJagA6iRHqokFsZj1Oo5lW(fq49UUZPZ1n6eopSAUxSVx4eKEHYViCL4Lr6mEPgEuDsRoGj10fqEk9I11xaAcUtsI68ay1CH)fB9I2698I11xyLkHSbLk6fy)ICJbd2a8eYcUtYKmSAZmgwTZjtbgCaSAogCFa4skHcxjEzecIcvgmDbKNsmLygdR27HPadoawnhdodNx9n15eb5dPXGPlG8uIPeZyy1gdmfyWbWQ5yWG5a0z8WOeQ7dvIbtxa5PetjMXWQTIXuGbhaRMJbd5NjHMoYAieDK6ggmDbKNsmLygdR25sMcmy6cipLykXGb8YiEfmyi8ExZjqlEskr9HdinE2lwxFbeEVR5eOfpjLO(Wbecm4NrCT0cqlVa7x0gJm4ay1CmyRHq4h0GFjuF4aIzmSAVmmfyW0fqEkXuIbd4Lr8kyWHReVmsZJSkH4KFIKMUaYtPxO8lcGvUqi6i1IKVyRxSndoawnhdwf3BLSzmMXWQDUXuGbtxa5PetjgmGxgXRGbdMXNghNULY7rGrvnUKMtQrDYxS1l6daxQTsLq2GuJf8cLFXsViaw5cHOJuls(cSFroFX66lu0lcxjEzKMhzvcXj)ejnDbKNsVyrgCaSAogmyG4bs2mgZyyTngzkWGdGvZXGLzLz15ebgiEWGPlG8uIPeZygdgKKmfyy1MPadMUaYtjMsmyaVmIxbdgmJpnoonejTk8ih8WA0CsnQt(ITEroXidoawnhdooajnE4rGW7zgdRTzkWGPlG8uIPedgWlJ4vWGbZ4tJJtdrsRcpYbpSgnNuJ6KVyRxKtmYGdGvZXG7fNG8ZKygdRCYuGbtxa5PetjgmGxgXRGbdH376qMradnDK1qihLpPXZEHYVyPxyLkHSbLk6fB9cWm(0440qexs8wQZPoHZdRM7f7ErcNhwn3lwxFXsVWcUtY0nu4TgDgWEb2ViNy4fRRVqrVWcpDMULY7joQoPvhW00fqEk9IfFXIVyD9fwPsiBqPIEb2VODozWbWQ5yWqexs8wQZjZyyThMcmy6cipLykXGb8YiEfmyi8ExhYmcyOPJSgc5O8jnE2lu(fl9cRujKnOurVyRxaMXNghNgYptc1X5B0jCEy1CVy3ls48WQ5EX66lw6fwWDsMUHcV1OZa2lW(f5edVyD9fk6fw4PZ0TuEpXr1jT6aMMUaYtPxS4lw8fRRVWkvczdkv0lW(fTvmgCaSAogmKFMeQJZ3WmgwyGPadMUaYtjMsmyaVmIxbdgcV31DoDUUrJN9cLFbeEVR7C6CDJMtQrDYxS1lCcsA1ybVyD9fk6fq49UUZPZ1nA8mgCaSAogSVC2ys0(HNCQsNXmgwkgtbgmDbKNsmLyWaEzeVcgmeEVRHiPvHh5GhwJgp7fk)ci8ExhYmcyOPJSgc5O8jnE2lu(fl9cl4ojt3qH3A0za7fy)ICIHxSU(cf9cl80z6wkVN4O6KwDattxa5P0lw8fRRVyPxS0laZjXvdipPZgRMdnDe(bXRKNsOooFZlwxFbyojUAa5jn(bXRKNsOooFZlw8fk)cRujKnOurVa7xOyTFX66lSsLq2Gsf9cSFX2k2lwKbhaRMJbNnwnhZyyLlzkWGPlG8uIPedgWlJ4vWGHW7DnejTk8ih8WA04zVq5xaH376qMradnDK1qihLpPXZEHYVWcUtY0nu4TgDgWEb2ViNy4fRRVyPxS0laZjXvdipPZgRMdnDe(bXRKNsOooFZlwxFbyojUAa5jn(bXRKNsOooFZlw8fk)cRujKnOurVa7xOyTFX66lSsLq2Gsf9cSFX2k2lwKbhaRMJbNnwnhZyyTmmfyW0fqEkXuIbd4Lr8kyWq49U2xDcYptslTa0YlW(f7HbhaRMJb7y4(KluDiojNloaXmgw5gtbgmDbKNsmLyWaEzeVcgmygFACC6qMradnDK1qihLpP5KAuN8fy)I2y8fRRVWkvczdkv0l26fbWQ50oXdEQIdnDu4kXhRrdMXNgh3l29ICIXxSU(cRujKnOurVa7xKtmYGdGvZXGDIh8ufhA6OWvIpwdZyy1gJmfyWbWQ5yW8klZtO6qYSaqmy6cipLykXmgwTBZuGbhaRMJbRsQdFdA6ipoOsOeNcvjdMUaYtjMsmJzmyPXuGHvBMcmy6cipLykXGb8YiEfmyi8Ex35056gnE2lu(fq49UUZPZ1nAoPg1jFb2VWji9IDVak4qucjBgd5KhacLr8AsVyD9fGz8PXXPHiPvHh5GhwJMtQrDYxO8lw6fDCVhXjqtWDsiRuPxG9lCcsVyD9fHReVmsNXl1WJQtA1bmPMUaYtPxO8laZ4tJJthYmcyOPJSgc5O8jnNuJ6KVa7x4eKEXIm4ay1CmyOGdrjKSzmMXWABMcmy6cipLykXGb8YiEfm4(aWLVy3l6daxQ5Kt6EXE7fobPxG9l6daxQvJf8cLFbeEVRHiPvHh5GhwJonoUxO8lw6fk6fPX0G5a0z8WOeQ7dvcbHZpnNuJ6KVq5xOOxeaRMtdMdqNXdJsOUpujDDOUVC2yVyXxSU(IoU3J4eOj4ojKvQ0lW(fobPxSU(cRujKnOurVa7xGbgCaSAogmyoaDgpmkH6(qLygdRCYuGbtxa5PetjgmGxgXRGbdMXNghNgk4qucjBgtdAcUts(cSFr7xSU(cf9IWvIxgPZ4LA4r1jT6aMutxa5PedoawnhdoKzeWqthzneYr5tmJH1EykWGPlG8uIPedgWlJ4vWGHW7DDiZiGHMoYAiKJYN04zVq5xaH37AisAv4ro4H1OXZEX66lSsLq2Gsf9cSFrBmWGdGvZXGLwOMrjIzmSWatbgCaSAogCGuX5jIJMocWhhsgmDbKNsmLygdlfJPadMUaYtjMsmyaVmIxbdgcV31qK0QWJCWdRrNgh3lwxFHvQeYguQOxG9lWadoawnhdUpaCjLqHReVmcbrHkZyyLlzkWGPlG8uIPedgWlJ4vWGHW7DnNaT4jPe1hoG04zVyD9fq49UMtGw8KuI6dhqiWGFgX1slaT8cSFrBm(I11xyLkHSbLk6fy)cmWGdGvZXGTgcHFqd(Lq9HdiMXWAzykWGPlG8uIPedgWlJ4vWGv0lGW7DnejTk8ih8WA04zVq5xaMXNghNoKzeWqthzneYr5tAoPg1jFXwVOngEX66lSsLq2Gsf9cSFrBm8IDVWjiXGdGvZXGHiPvHh5GhwdZyyLBmfyW0fqEkXuIbd4Lr8kyWHReVmsNIdqOPJsuynAECT8ITEr7xO8lGW7DDkoaHMokrH1O5KAuN8fy)cNG0lu(faEzOmGHa4CoD2l26f7bJm4ay1CmyOGdrjKSzmMXWQngzkWGPlG8uIPedgWlJ4vWGHW7DDiZiGHMoYAiKJYN0CsnQt(ITErBm(IDVWji9I11xyLkHSbLk6fy)I2y8f7EHtqIbhaRMJbd5NjHMoYAieDK6gMXWQDBMcm4ay1Cm4wkVhbgv14smy6cipLykXmgwT3MPadoawnhdg0uQbXdKSzmgmDbKNsmLygdR25KPadoawnhdovCcbrH0yW0fqEkXuIzmSAVhMcmy6cipLykXGb8YiEfmyl80z65iKJYAqwdHYcqlA6cipLEHYVa0eCNKe15bWQ5c)l26fT1y4fRRVa0eCNKe15bWQ5c)l26fT1lZlwxFbygFACC6qMradnDK1qihLpP5KAuN8fy)ci8Ex35056gDcNhwn3l23lCcsVq5xeUs8YiDgVudpQoPvhWKA6cipLEX66lSsLq2Gsf9cSFrUXGdGvZXGHcoeLqYMXygdR2yGPadMUaYtjMsmyaVmIxbdgcV31qK0QWJCWdRrNgh3lwxFHvQeYguQOxG9lwggCaSAogCgoV6BQZjcYhsJzmSARymfyWbWQ5yWq(zsOPJSgcrhPUHbtxa5PetjMXWQDUKPadoawnhdgk48WjXGPlG8uIPeZyy1EzykWGPlG8uIPedgWlJ4vWGx6f9bGlFX(EbyK2l29I(aWLAo5KUxS3EXsVamJpnooDlL3JaJQACjnNuJ6KVyFVO9lw8fB9Iay1C6wkVhbgv14sAWiTxSU(cWm(0440TuEpcmQQXL0CsnQt(ITEr7xS7fobPxO8laZ4tJJtdrsRcpYbpSgnNuJ6KiN4Ku(ITErFa4sTvQeYgKASGxSU(ci8ExRsQdFdA6ipoOsOeNcvPgp7fl(cLFbygFACC6wkVhbgv14sAoPg1jFXwVO9lwxFHvQeYguQOxG9lYjdoawnhdgmq8ajBgJzmSANBmfyWbWQ5yWYSYS6CIadepyW0fqEkXuIzmS2gJmfyW0fqEkXuIbd4Lr8kyWq49UUZPZ1n6eopSAUxSVx4eKEXwVOJ79iobAcUtczLkXGdGvZXGHcoeLqYMXygZyW4w5lBdtbgwTzkWGdGvZXGbd(zehjBgJbtxa5PetjMXWABMcm4ay1CmyjXPRSnOeU0yW0fqEkXuIzmSYjtbgCaSAogSmB4ec4h8edMUaYtjMsmJH1EykWGdGvZXGLZyn15e5imIZGPlG8uIPeZyyHbMcm4ay1Cmy5Cfab5dPXGPlG8uIPeZyyPymfyWbWQ5yWhznehjBgqlmy6cipLykXmgw5sMcm4ay1CmyqtTFLez84uC8Yx2ggmDbKNsmLygdRLHPadoawnhdwMv8YqYMb0cdMUaYtjMsmJHvUXuGbhaRMJbFHHZjjYjpaedMUaYtjMsmJzmJb7cXL1CmS2gJTZnmMBBJbgSJGF15uYG3Rl7cbw7pS275(lEHcn0lk1SHBVOp8xKdGNcxOC8coP44fNsVqoQ0lcCBudJsVa0eNtsQ)8l06Ox0o3FrUoNle3O0lYrgz6CHEH1ADoEHnVihlSwRZXlwA7fSO(ZVqRJEX25(lY15CH4gLEroYitNl0lSwRZXlS5f5yH1ADoEXsTxWI6p)cTo6fT3o3FrUoNle3O0lYrgz6CHEH1ADoEHnVihlSwRZXlwA7fSO(Z)53Rl7cbw7pS275(lEHcn0lk1SHBVOp8xKdqsMJxWjfhV4u6fYrLErGBJAyu6fGM4Css9NFHwh9cmK7VixNZfIBu6f5iJmDUqVWATohVWMxKJfwR154flLZfSO(Z)53Rl7cbw7pS275(lEHcn0lk1SHBVOp8xKdPLJxWjfhV4u6fYrLErGBJAyu6fGM4Css9NFHwh9I25(lY15CH4gLEroYitNl0lSwRZXlS5f5yH1ADoEXsBVGf1F(fAD0lAVNC)f56CUqCJsVihzKPZf6fwR154f28ICSWATohVyP2lyr9NFHwh9ITXyU)ICDoxiUrPxKJmY05c9cR16C8cBErowyTwNJxSu7fSO(Z)53FQzd3O0luSxeaRM7f(sAs9NNblZiadRTXqozWz8PxEIbV8xOefs7f7FH0i(MxSxGFgX)8l)fnMLjZDmX0zzn4qAWOIPSuX9HvZb4r3WuwQam)8l)f5Jdp4BEX2TB9fBJXTX4N)ZV8xKRnX5KK5(NF5VyFVyztjk9ICDWpJ4VaUzSxyZlsupW92lcGvZ9cFjn9NF5VyFVy)xsVWkvczdkv0lwYfP(fwWDsM2kvczdkv0IVWMxeNvGklm6f0LEX0FbDGb)mIR)8l)f77flBk9IujZiVeZmCUts(cxQ4f4w5lBZlcGvZ9cFjn9NF5VyFVW411cz6CHUjKiWm(044ErjFb(jXZYgUrj9NF5VyFVixBiqlVOp8xa4LHYagcGZ50z6p)NF5VyH0ciaUrPxar9HtVamQqH9ciYzDs9lwwaGYm5lU52xtWv74(xeaRMt(I58B0F(L)Iay1CsDgNaJkuyU7(q2YNF5ViawnNuNXjWOcf2o3yg4ovPZcRM7ZV8xeaRMtQZ4eyuHcBNBm7ZK(8bWQ5K6mobgvOW25gtjUQ6COmY(8l)fWxKjBg7f8OsVacV3P0lKwyYxar9HtVamQqH9ciYzDYxex6fzCAFzJz158fL8fP5i9NF5ViawnNuNXjWOcf2o3ykVit2mgsAHj)8bWQ5K6mobgvOW25gtCjHkJuB9cvYD4QSj4He1NZqthLnoi(NpawnNuNXjWOcf2o3y6y4(KluDiojNloa95dGvZj1zCcmQqHTZnMoXdEQIdnDu4kXhR5ZhaRMtQZ4eyuHcBNBmvj1HVbnDKhhujuItHQ8ZhaRMtQZ4eyuHcBNBmXLeQmsTvQ3jGHUqLCd2a8JXNRaiiFiTwRUBfXJkHixOZ015cU)iEa5jnTGsAsLxIuC8klJsAxcEfqEcvNrNSSniNLZWLXBOrckVpS6CI4uaSHV4NpawnNuNXjWOcf2o3yIljuzKARuVtadDHk5gSb4hJpxbqq(qATwD3kIhvcrUqNPRZfC)r8aYtAAbL0KkVKXRRfY0T1nHebMXNgh3oJxxlKP3w3eseygFACCyV96kP44vwgL0Ue8kG8eQoJozzBqolNHlJ3qJeuEFy15eXPaydFXpFaSAoPoJtGrfkSDUXSpaCjLqHReVmcbrHARv3TI4rLqKl0z66Cb3FepG8KMwqjn5NF5Vyzt7hU0KVWAOxKW5HvZ9I4sVamJpnoUxm9xSSYmcyVy6VWAOxSxlF6fXLEXczEPg(xS)oPvhWKVaAZlSg6fjCEy1CVy6ViUxGFnH0O0l2756E5lC0q3lSgAto40lWLu6fzCcmQqHPFXYkFXYo2E9fnH8fXlARZP8f79CDV8fXLEr07eWKVOmj57VWAk5lk5lARBl1F(ay1CsDgNaJkuy7CJziZiGHMoYAiKJYNAnJtGqAiRuj3T1TBT6Uvu4kXlJ0z8sn8O6KwDatQPlG8uszfrsjDastsjDacnDK1qO(aWL15ev8sQvJ9B4kVeP44vwgL0HRYMGhsuFodnDu24G4RRkIuC8klJsAWgGFm(Cfab5dPT4NF5Vyzt7hU0KVWAOxKW5HvZ9I4sVamJpnoUxm9xOejTk8VyVYdR5fXLEXEr4k9IP)IfIWj9cOnVWAOxKW5HvZ9IP)I4Eb(1esJsVyVNR7LVWrdDVWAOn5GtVaxsPxKXjWOcfM(ZhaRMtQZ4eyuHcBNBmHiPvHh5GhwtRzCcesdzLk5UTgdTwD3HReVmsNXl1WJQtA1bmPMUaYtjLvejL0binjL0bi00rwdH6daxwNtuXlPwn2VHR8sKIJxzzushUkBcEir95m00rzJdIVUQisXXRSmkPbBa(X4ZvaeKpK2IF(ay1CsDgNaJkuy7CJz2y1CF(pFaSAoPg3kFzBCdg8Zios2m2NpawnNuJBLVSn7CJPK40v2gucxAF(ay1CsnUv(Y2SZnMYSHtiGFWtF(ay1CsnUv(Y2SZnMYzSM6CICegX)8bWQ5KACR8LTzNBmLZvaeKpK2NpawnNuJBLVSn7CJ5rwdXrYMb0YNpawnNuJBLVSn7CJjOP2VsImECkoE5lBZNpawnNuJBLVSn7CJPmR4LHKndOLpFaSAoPg3kFzB25gZlmCojro5bG(8F(L)IfslGa4gLEb5cX38cRuPxyn0lcGn8xuYxeUeLpG8K(ZhaRMt6geEpkawnhYxsR1luj34w5lBtRv3DIGW7DniKwDo14zRRq49UovYmY7dipHudNfqJNTUcH376ujZiVpG8eIoE4K04zF(ay1CYDUXexsOYiv5NpawnNCNBmXLeQmsT1luj3HRYMGhsuFodnDu24G4TwD3wPsiBqPI2Qng)8bWQ5K7CJjUKqLrQTEHk5oKnUehjr8W1HJadp8TwD3jccV318W1HJadp8OebH37A8mLxkJtUGCcs626qMradnDK1qihLpTUQisXXRSmkPbBa(X4ZvaeKpKMYq49UoKzeWqthzneYr5tAoPg1j3cdlQ8swWDsMUHcV1OZag25edRRkIKs6aKgmxIojLq(Qt9HdiTASFdFDvrw4PZ0TuEpXr1jT6aMMUaYtPfxxxkrq49UMhUoCey4HhLii8ExNgh36QvQeYguQiS3wXwuzRujKnOurBT027zVTeygFACCAWgGFm(Cfab5dPP5KAuNC3EW2cUtY0wPsiBqPIwCXpFaSAo5o3yIljuzKARuVtadDHk5gSb4hJpxbqq(qATwD3q49UgIKwfEKdEyn6044wxTsLq2GsfHng(8bWQ5K7CJji8EuaSAoKVKwRxOsUbj5NpawnNCNBmbH3JcGvZH8L0A9cvYT0AT6UdGvUqi6i1IKyV9NpawnNCNBmbH3JcGvZH8L0A9cvYnWtHluRv3DaSYfcrhPwKCR2F(pFaSAoPgKKUJdqsJhEei8(wRUBWm(0440qK0QWJCWdRrZj1Oo5w5eJF(ay1Csnij35gZEXji)mPwRUBWm(0440qK0QWJCWdRrZj1Oo5w5eJF(ay1Csnij35gtiIljEl15S1Q7gcV31HmJagA6iRHqokFsJNP8swPsiBqPI2cmJpnooneXLeVL6CQt48WQ52LW5HvZTUUKfCNKPBOWBn6mGHDoXW6QISWtNPBP8EIJQtA1bmnDbKNslU46QvQeYguQiSBNZpFaSAoPgKK7CJjKFMeQJZ30A1DdH376qMradnDK1qihLpPXZuEjRujKnOurBbMXNghNgYptc1X5B0jCEy1C7s48WQ5wxxYcUtY0nu4TgDgWWoNyyDvrw4PZ0TuEpXr1jT6aMMUaYtPfxCD1kvczdkve2TvSpFaSAoPgKK7CJPVC2ys0(HNCQsN1A1DNrMgeMgcV31DoDUUrJNPCgzAqyAi8Ex35056gnNuJ6KB5eK0QXcwxvugzAqyAi8Ex35056gnE2NpawnNudsYDUXmBSAUwRUBi8ExdrsRcpYbpSgnEMYq49UoKzeWqthzneYr5tA8mLxYcUtY0nu4TgDgWWoNyyDvrw4PZ0TuEpXr1jT6aMMUaYtPfxxxAjWCsC1aYt6SXQ5qthHFq8k5PeQJZ3SUcMtIRgqEsJFq8k5PeQJZ3SOYwPsiBqPIWwXAVUALkHSbLkc7TvSf)8bWQ5KAqsUZnMzJvZ1A1DdH37AisAv4ro4H1OXZugcV31HmJagA6iRHqokFsJNPSfCNKPBOWBn6mGHDoXW66slbMtIRgqEsNnwnhA6i8dIxjpLqDC(M1vWCsC1aYtA8dIxjpLqDC(Mfv2kvczdkve2kw71vRujKnOuryVTIT4NpawnNudsYDUX0XW9jxO6qCsoxCaQ1Q7gcV31(Qtq(zsAPfGwWEpF(ay1Csnij35gtN4bpvXHMokCL4J10A1DdMXNghNoKzeWqthzneYr5tAoPg1jXUngxxTsLq2GsfTvaSAoTt8GNQ4qthfUs8XA0Gz8PXXTlNyCD1kvczdkve25eJF(ay1Csnij35gtELL5juDizwaOpFaSAoPgKK7CJPkPo8nOPJ84GkHsCkuLF(pFaSAoPg4PWfYnuWHOes2mwRGnapHSG7KmP72TwD3zKPbHPHW7DDNtNRB04zkNrMgeMgcV31DoDUUrZj1Ooj2UDcsA1yb7GcoeLqYMXqo5bGqzeVM0NpawnNud8u4cTZnMQ4ERKnJ1A1D7eK0QXc2xgzAqyAi8ExdrH0qapfUqAoPg1j3cJ6TXWNpawnNud8u4cTZnMqbhIsizZyTc2a8eYcUtYKUB3A1D3X9EeNanb3jHSsLW2jiPvJfOmygFACCAisAv4ro4H1O5KAuN8ZhaRMtQbEkCH25gZqMradnDK1qihLp95dGvZj1apfUq7CJP0c1mkrTwD3q49UoKzeWqthzneYr5tA8mLHW7DnejTk8ih8WA04zRRwPsiBqPIWUng(8bWQ5KAGNcxODUXeIKwfEKdEynTwD3Gz8PXXPdzgbm00rwdHCu(KMtQrDsKtCsk3ABmUUAHNotphHCuwdYAiuwaArtxa5P06QvQeYguQiSBJHpFaSAoPg4PWfANBmbnLAq8ajBg7ZhaRMtQbEkCH25gZaPIZtehnDeGpoKF(ay1CsnWtHl0o3ycfCE4K(8bWQ5KAGNcxODUXSLY7rGrvnUuRv3DaSYfcrhPwKe79SUQOWvIxgP5rwLqCYprstxa5P0NpawnNud8u4cTZnMPItiikK2NpawnNud8u4cTZnMqbhIsizZyTc2a8eYcUtYKUB3A1DNrMgeMgcV31DoDUUrNghNYlbAcUtsI68ay1CHFR26LzDfcV31qK0QWJCWdRrJNT46kygFACC6qMradnDK1qihLpP5KAuNe7mY0GW0q49UUZPZ1n6eopSAU95eKuoCL4Lr6mEPgEuDsRoGj10fqEkTUcAcUtsI68ay1CHFR269SUALkHSbLkc7C7ZhaRMtQbEkCH25gZ(aWLucfUs8YieefQF(ay1CsnWtHl0o3yMHZR(M6CIG8H0(8bWQ5KAGNcxODUXemhGoJhgLqDFOsF(ay1CsnWtHl0o3yc5NjHMoYAieDK6MpFaSAoPg4PWfANBmTgcHFqd(Lq9HdOwRUBi8ExZjqlEskr9HdinE26keEVR5eOfpjLO(Wbecm4NrCT0cqly3gJF(ay1CsnWtHl0o3yQI7Ts2mwRv3D4kXlJ08iRsio5NiPPlG8us5ayLleIosTi5wB)5dGvZj1apfUq7CJjyG4bs2mwRv3nygFACC6wkVhbgv14sAoPg1j3QpaCP2kvczdsnwGYlfaRCHq0rQfjXoNRRkkCL4LrAEKvjeN8tK00fqEkT4NpawnNud8u4cTZnMYSYS6CIadep(8F(ay1CsT0CdfCikHKnJ1A1DNrMgeMgcV31DoDUUrJNPCgzAqyAi8Ex35056gnNuJ6Ky7eK2bfCikHKnJHCYdaHYiEnP1vWm(0440qK0QWJCWdRrZj1OoPYl1X9EeNanb3jHSsLW2jiTUgUs8YiDgVudpQoPvhWKA6cipLugmJpnooDiZiGHMoYAiKJYN0CsnQtITtqAXpFaSAoPwA7CJjyoaDgpmkH6(qLAT6U7daxURpaCPMtoPBV5eKWUpaCPwnwGYq49UgIKwfEKdEyn6044uEjfLgtdMdqNXdJsOUpujeeo)0CsnQtQSIcGvZPbZbOZ4Hrju3hQKUou3xoBSfxx74EpItGMG7KqwPsy7eKwxTsLq2GsfHng(8bWQ5KAPTZnMHmJagA6iRHqokFQ1Q7gmJpnoonuWHOes2mMg0eCNKe72RRkkCL4Lr6mEPgEuDsRoGj10fqEk95dGvZj1sBNBmLwOMrjQ1Q7gcV31HmJagA6iRHqokFsJNPmeEVRHiPvHh5GhwJgpBD1kvczdkve2TXWNpawnNulTDUXmqQ48eXrthb4Jd5NpawnNulTDUXSpaCjLqHReVmcbrHARv3neEVRHiPvHh5GhwJonoU1vRujKnOuryJHpFaSAoPwA7CJP1qi8dAWVeQpCa1A1DdH37AobAXtsjQpCaPXZwxHW7DnNaT4jPe1hoGqGb)mIRLwaAb72yCD1kvczdkve2y4ZhaRMtQL2o3ycrsRcpYbpSMwRUBfbH37AisAv4ro4H1OXZugmJpnooDiZiGHMoYAiKJYN0CsnQtUvBmSUALkHSbLkc72yyNtq6ZhaRMtQL2o3ycfCikHKnJ1A1DhUs8YiDkoaHMokrH1O5X1YwTvgcV31P4aeA6OefwJMtQrDsSDcskd4LHYagcGZ50zBThm(5dGvZj1sBNBmH8ZKqthzneIosDtRv3neEVRdzgbm00rwdHCu(KMtQrDYTAJXDobP1vRujKnOury3gJ7CcsF(ay1CsT025gZwkVhbgv14sF(ay1CsT025gtqtPgepqYMX(8bWQ5KAPTZnMPItiikK2NpawnNulTDUXek4qucjBgR1Q72cpDMEoc5OSgK1qOSa0IMUaYtjLbnb3jjrDEaSAUWVvBngwxbnb3jjrDEaSAUWVvB9YSUcMXNghNoKzeWqthzneYr5tAoPg1jXoJmnimneEVR7C6CDJoHZdRMBFobjLdxjEzKoJxQHhvN0QdysnDbKNsRRwPsiBqPIWo3(8bWQ5KAPTZnMz48QVPoNiiFiTwRUBi8ExdrsRcpYbpSgDACCRRwPsiBqPIWEz(8bWQ5KAPTZnMq(zsOPJSgcrhPU5ZhaRMtQL2o3ycfCE4K(8bWQ5KAPTZnMGbIhizZyTwD3l1haUCFGrA76daxQ5Kt62BlbMXNghNULY7rGrvnUKMtQrDY91EXTcGvZPBP8EeyuvJlPbJ0wxbZ4tJJt3s59iWOQgxsZj1Oo5wT35eKugmJpnoonejTk8ih8WA0CsnQtICIts5w9bGl1wPsiBqQXcwxHW7DTkPo8nOPJ84GkHsCkuLA8SfvgmJpnooDlL3JaJQACjnNuJ6KB1ED1kvczdkve258ZhaRMtQL2o3ykZkZQZjcmq84ZhaRMtQL2o3ycfCikHKnJ1A1DNrMgeMgcV31DoDUUrNW5HvZTpNG0wDCVhXjqtWDsiRujMXmgd]] )


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


end
