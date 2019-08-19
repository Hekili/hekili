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


    } )


    spec:RegisterPack( "Beast Mastery", 20190818, [[dWKybbqiQO6rkHAtuP8jQaJsjQtPKYQuIuELsLzjL0TGczxK6xkvnmQOCmPultjvpJkvnnLqUgukBdkv9nQGyCqPY5KsW6OcQ5rcDprX(GcoOucTqsWdPsLMiuOKlkLiYhHcfJujs4KkrsRuuAMsjs3ujs0oHIgQuIOwQuIWtbAQqjxfkuQVQePASubPZkLO2lK)IQbt4WclgWJbnzrUmYMLQptLmAP40swnuO61kbZMQUnjTBv(TIHlQoovQy5O8CIMoLRdvBNkY3jrJxjIZRKSEQqZxPSFvnQncleykmcH56oRDl4mSRn2PBVo2Wg2WEeOTkNqG5bCHWfHaVqLqGkqH0EXszinITcbMhR8tKqyHaLdodsiWgZYLo8(9UkRbhqdh19Ysf3hwnhKfDBVSuH7rGa4L3wQhcabMcJqyUUZA3cod7AJD62RJnSTihccmWTMHHablv3fb2uPeDiaeyIKqe4IFHcuiTxSugsJyREXsb(ze7ZU4x0ywU0H3V3vzn4aA4OUxwQ4(WQ5GSOB7LLkC)NDXVOfXDHlTx0g7A9fR7S2TWlWOx0EDhEro7Z(zx8lC3M4Crsh(ZU4xGrVOftjk9c3DWpJyVaSzSxyZlsupW92lcOvZ9cFjn9NDXVaJEbgBj9cRujUn8urVyzNK6xybZfzARujUn8urR9cBErCwbR8WOxqx6ft)f0bh8ZiM(ZU4xGrVOftPxKkzo5L7ZXzUi5lCQIxGBLVSvViGwn3l8L00F2f)cm6fgRUfit7q1nHKdNXNgL3lk5lWpjEE(WmkPrG(sAsewiWe1dCVHWcHzBewiq6capLqkGaHSYiwfiWebG37AyiT6CPXZFX22lseaEVRtLmN8(aWtC1Wvb145VyB7fjcaV31PsMtEFa4joDSWfPXZrGb0Q5qGWW75b0Q54(sAiqFjn(fQece3kFzRqgcZ1ryHadOvZHaXLeVmsvIaPla8ucPaYqy6Eewiq6capLqkGadOvZHadzJtXrsolCCyC4WcpceYkJyvGateaEVRzHJdJdhw45jcaV3145VWTxS8lYzKtCxWKUToK5e04tNBnexz5tVyB7fo)fK7Gx55usdxb9JXMRGCaFiTx42laW7DDiZjOXNo3AiUYYN045VyTx42lSG5ImDdfERrNdTxO4lCp2EX22lw(fjcaV31SWXHXHdl88ebG3760O8EX22lSsL42Wtf9cfFX6y)lw7fU9cRujUn8urVadVy5xS(IEXs7fl)c4m(0O80Wvq)yS5kihWhstZi1Oo5l29If9cfFHvQe3gEQOxS2lwdbEHkHadzJtXrsolCCyC4WcpYqyUiewiq6capLqkGadOvZHaHRG(XyZvqoGpKgceYkJyvGabW7DnajTk8CLSWA0Pr59ITTxyLkXTHNk6fk(cSHaPENGg)cvcbcxb9JXMRGCaFinKHWeBiSqG0faEkHuabgqRMdbcdVNhqRMJ7lPHa9L04xOsiqysImeMypcleiDbGNsifqGqwzeRceyaTYjIthPwK8fk(I1rGb0Q5qGWW75b0Q54(sAiqFjn(fQecuAidHPdbHfcKUaWtjKciqiRmIvbcmGw5eXPJuls(cm8I2iWaA1Ciqy498aA1CCFjneOVKg)cvcbc9u4eHmKHaZzeCubcdHfcZ2iSqGb0Q5qGsCv1545KHaPla8ucPaYqyUocleyaTAoey(y1Ciq6capLqkGmeMUhHfcKUaWtjKciWlujey4OSjyHK3NZ4tNNpkjgcmGwnhcmCu2eSqY7Zz8PZZhLedzimxecleyaTAoeOYH5tor1XzKCU4GecKUaWtjKcidHj2qyHadOvZHaDHhSufhF68WrInwdcKUaWtjKcidHj2JWcbgqRMdbQsQdBfF6CpoSs8eJcvjcKUaWtjKcidHPdbHfcKUaWtjKciWaA1Ciq4kOFm2CfKd4dPHaHSYiwfiqN)cwujo5eDMUoNW9hXcapPPLust(c3EXYVGCh8kpNsANcwfaEIxNrNSSvCxLRWPXB8rclVpS6CXzuaTH9I1qGuVtqJFHkHaHRG(XyZvqoGpKgYqyIDiSqG0faEkHuabczLrSkqGo)fSOsCYj6mDDoH7pIfaEstlPKMebgqRMdb2hiUKs8WrIvgXbOqfzimBbewiq6capLqkGaZzemKg3kvcb2w3gbgqRMdbgYCcA8PZTgIRS8jeiKvgXQab68xeosSYiDoRudpVoPvh0KA6capLEHBVW5VGKs6GKMKs6GeF6CRH49bIlRZfVyLuRgy8H9c3EXYVGCh8kpNs6WrztWcjVpNXNopFusSxST9cN)cYDWR8CkPHRG(XyZvqoGpK2lwdzimB7mewiq6capLqkGaZzemKg3kvcb2wJneyaTAoeiajTk8CLSWAqGqwzeRcey4iXkJ05Ssn886KwDqtQPla8u6fU9cN)cskPdsAskPds8PZTgI3hiUSox8IvsTAGXh2lC7fl)cYDWR8CkPdhLnblK8(CgF688rjXEX22lC(li3bVYZPKgUc6hJnxb5a(qAVynKHmei0tHtecleMTryHaPla8ucPacmGwnhceiyauIlBgdbczLrSkqGa49UUZOZXvA88x42laW7DDNrNJR0msnQt(cfZ8cxWKwnwYl29cGGbqjUSzmUlwajEoXQjHaHRGEIBbZfzseMTrgcZ1ryHaPla8ucPaceYkJyvGaDbtA1yjVaJEbaEVRbOqACONcNinJuJ6KVadVWz61XgcmGwnhcuf3BLSzmKHW09iSqG0faEkHuabgqRMdbcemakXLnJHaHSYiwfiWoU3ZzeSjyUiUvQ0lu8fUGjTASKx42lGZ4tJYtdqsRcpxjlSgnJuJ6Kiq4kON4wWCrMeHzBKHWCriSqGb0Q5qGHmNGgF6CRH4klFcbsxa4PesbKHWeBiSqG0faEkHuabczLrSkqGa49UoK5e04tNBnexz5tA88x42laW7DnajTk8CLSWA045VyB7fwPsCB4PIEHIVOn2qGb0Q5qGsluZPeHmeMypcleiDbGNsifqGqwzeRceiCgFAuE6qMtqJpDU1qCLLpPzKAuNK7cNKYxGHxSUZEX22lSWtNPNJ4klRHBneppGlOPla8u6fBBVWkvIBdpv0lu8fTXgcmGwnhceGKwfEUswynidHPdbHfcmGwnhce2uQbXcUSzmeiDbGNsifqgctSdHfcmGwnhcm4Q4SeX4tNdzJsjcKUaWtjKcidHzlGWcbgqRMdbcemw4IqG0faEkHuazimB7mewiq6capLqkGaHSYiwfiWaALteNosTi5lu8fl6fBBVW5ViCKyLrAwKxjoJ8tK00faEkHadOvZHaxO8EoCuvJlHmeMTBJWcbgqRMdbMkgXbOqAiq6capLqkGmeMTxhHfcKUaWtjKciWaA1CiqGGbqjUSzmeiKvgXQabcG376oJohxPtJY7fU9ILFbSjyUijVZcOvZf(xGHx0wJDVyB7fa49UgGKwfEUswynA88xS2l22EbCgFAuE6qMtqJpDU1qCLLpPzKAuN8fk(ca8Ex3z054kDcNfwn3lWOx4cMEHBViCKyLr6CwPgEEDsRoOj10faEk9ITTxaBcMlsY7SaA1CH)fy4fT1l6fBBVWkvIBdpv0lu8fTaceUc6jUfmxKjry2gzimB7EewiWaA1CiW(aXLuIhosSYioafQiq6capLqkGmeMTxecleyaTAoeyooR6RQZfhWhsdbsxa4PesbKHWSn2qyHadOvZHaHZbPZyHrjE3hQecKUaWtjKcidHzBShHfcmGwnhceWptIpDU1qC6i1viq6capLqkGmeMTDiiSqG0faEkHuabczLrSkqGa49UMrWf8KuY7ddsA88xST9ca8ExZi4cEsk59HbjoCWpJyAPfWfEHIVOTZqGb0Q5qGwdXXpGb)s8(WGeYqy2g7qyHaPla8ucPaceYkJyvGadhjwzKMf5vIZi)ejnDbGNsVWTxeqRCI40rQfjFbgEX6iWaA1CiqvCVvYMXqgcZ2TacleiDbGNsifqGqwzeRceiCgFAuE6fkVNdhv14sAgPg1jFbgErFG4sTvQe3gUASKx42lw(fb0kNioDKArYxO4lC)l22EHZFr4iXkJ0SiVsCg5NiPPla8u6fRHadOvZHaHdal4YMXqgcZ1DgcleyaTAoeOmVmRoxC4aWceiDbGNsifqgYqGWKeHfcZ2iSqG0faEkHuabczLrSkqGWz8Pr5PbiPvHNRKfwJMrQrDYxGHx4ENHadOvZHaJdssJfEom8EKHWCDewiq6capLqkGaHSYiwfiq4m(0O80aK0QWZvYcRrZi1Oo5lWWlCVZqGb0Q5qG9Ira(zsidHP7ryHaPla8ucPaceYkJyvGabW7DDiZjOXNo3AiUYYN045VWTxS8lSsL42Wtf9cm8c4m(0O80aetsSfQZLoHZcRM7f7ErcNfwn3l22EXYVWcMlY0nu4TgDo0EHIVW9y7fBBVW5VWcpDMEHY7jgVoPvh000faEk9I1EXAVyB7fwPsCB4PIEHIVOT7rGb0Q5qGaetsSfQZfYqyUiewiq6capLqkGaHSYiwfiqa8ExhYCcA8PZTgIRS8jnE(lC7fl)cRujUn8urVadVaoJpnkpnGFMeVJZwPt4SWQ5EXUxKWzHvZ9ITTxS8lSG5ImDdfERrNdTxO4lCp2EX22lC(lSWtNPxO8EIXRtA1bnnDbGNsVyTxS2l22EHvQe3gEQOxO4lAJ9iWaA1Ciqa)mjEhNTczimXgcleiDbGNsifqGqwzeRceiaEVR7m6CCLgp)fU9ca8Ex3z054knJuJ6KVadVWfmPvJL8ITTx48xaG376oJohxPXZrGb0Q5qG(YvJj5yC8Klv6mKHWe7ryHaPla8ucPaceYkJyvGabW7DnajTk8CLSWA045VWTxaG376qMtqJpDU1qCLLpPXZFHBVy5xybZfz6gk8wJohAVqXx4ES9ITTx48xyHNotVq59eJxN0QdAA6capLEXAVyB7fl)c4CsC1aWt68XQ54tNJFaSk5PeVJZw9c3EHvQe3gEQOxO4lW(2VyB7fwPsCB4PIEHIVyDS)fRHadOvZHaZhRMdzimDiiSqG0faEkHuabczLrSkqGa49U2xDcWptslTaUWlu8flcbgqRMdbQCy(KtuDCgjNloiHmeMyhcleiDbGNsifqGqwzeRceiCgFAuE6qMtqJpDU1qCLLpPzKAuN8fk(I2o7fBBVWkvIBdpv0lWWlcOvZPDHhSufhF68WrInwJgoJpnkVxS7fU3zVyB7fwPsCB4PIEHIVW9odbgqRMdb6cpyPko(05HJeBSgKHWSfqyHadOvZHazvEUN41XL5bKqG0faEkHuazimB7mewiWaA1CiqvsDyR4tN7XHvINyuOkrG0faEkHuazidbknewimBJWcbsxa4PesbeiKvgXQabcG376oJohxPXZFHBVaaV31DgDoUsZi1Oo5lu8fUGPxS7fabdGsCzZyCxSas8CIvt6fBBVaoJpnkpnajTk8CLSWA0msnQt(c3EXYVOJ79CgbBcMlIBLk9cfFHly6fBBViCKyLr6CwPgEEDsRoOj10faEk9c3EbCgFAuE6qMtqJpDU1qCLLpPzKAuN8fk(cxW0lwdbgqRMdbcemakXLnJHmeMRJWcbsxa4PesbeiKvgXQab2hiU8f7ErFG4snJCr3lwAVWfm9cfFrFG4sTASKx42laW7DnajTk8CLSWA0Pr59c3EXYVW5VinMgohKoJfgL4DFOsCaC2PzKAuN8fU9cN)IaA1CA4Cq6mwyuI39HkPRJ39LRg7fR9ITTx0X9EoJGnbZfXTsLEHIVWfm9ITTxyLkXTHNk6fk(cSHadOvZHaHZbPZyHrjE3hQeYqy6Eewiq6capLqkGaHSYiwfiq4m(0O80abdGsCzZyAytWCrYxO4lw)fBBVaaV31DgDoUslTaUWlWWlw)fBBVW5ViCKyLr6CwPgEEDsRoOj10faEkHadOvZHadzobn(05wdXvw(eYqyUiewiq6capLqkGaHSYiwfiqa8ExhYCcA8PZTgIRS8jnE(lC7fa49UgGKwfEUswynA88xST9cRujUn8urVqXx0gBiWaA1CiqPfQ5uIqgctSHWcbsxa4PesbeiKvgXQabcNXNgLNgGKwfEUswynAgPg1jrGb0Q5qGbxfNLigF6CiBukrgctShHfcKUaWtjKciqiRmIvbceaV31aK0QWZvYcRrNgL3l22EHvQe3gEQOxO4lWgcmGwnhcSpqCjL4HJeRmIdqHkYqy6qqyHaPla8ucPaceYkJyvGabW7DnJGl4jPK3hgK045VyB7fa49UMrWf8KuY7ddsC4GFgX0slGl8cfFrBN9ITTxyLkXTHNk6fk(cSHadOvZHaTgIJFad(L49HbjKHWe7qyHadOvZHabiPvHNRKfwdcKUaWtjKcidHzlGWcbgqRMdbUq59C4OQgxcbsxa4PesbKHWSTZqyHadOvZHaHnLAqSGlBgdbsxa4PesbKHWSDBewiWaA1CiWuXioafsdbsxa4PesbKHWS96iSqG0faEkHuabczLrSkqGa49UUZOZXv60O8EHBVy5xaBcMlsY7SaA1CH)fy4fT1y3l22EbaEVRbiPvHNRKfwJgp)fR9ITTxaNXNgLNoK5e04tNBnexz5tAgPg1jFHIVaaV31DgDoUsNWzHvZ9cm6fUGPx42lchjwzKoNvQHNxN0QdAsnDbGNsVyB7fHJeRmsNIds8PZtuynAwCl8cm8I2VWTxaG376uCqIpDEIcRrNgL3lC7fqwz8COXH4mgD2lWWlwKZEX22lSsL42Wtf9cfFrlGadOvZHabcgaL4YMXqgcZ2UhHfcKUaWtjKciqiRmIvbceaV31aK0QWZvYcRrNgL3l22EHvQe3gEQOxO4lWoeyaTAoeyooR6RQZfhWhsdzimBViewiWaA1Ciqa)mj(05wdXPJuxHaPla8ucPaYqy2gBiSqGb0Q5qGabJfUieiDbGNsifqgcZ2ypcleiDbGNsifqGqwzeRce4YVOpqC5lWOxahP9IDVOpqCPMrUO7flTxS8lGZ4tJYtVq59C4OQgxsZi1Oo5lWOx0(fR9cm8IaA1C6fkVNdhv14sA4iTxST9c4m(0O80luEphoQQXL0msnQt(cm8I2Vy3lCbtVyB7fa49UwLuh2k(05ECyL4jgfQsnE(lw7fU9c4m(0O80luEphoQQXL0msnQt(cm8I2iWaA1Ciq4aWcUSzmKHWSTdbHfcmGwnhcuMxMvNloCaybcKUaWtjKcidHzBSdHfcKUaWtjKciqiRmIvbce2emxKK3zb0Q5c)lWWlARxecmGwnhceiyauIlBgdzidbIBLVSviSqy2gHfcmGwnhceo4NrmUSzmeiDbGNsifqgcZ1ryHadOvZHaLeJUYwXt4sdbsxa4PesbKHW09iSqGb0Q5qGY8HrCOFWtiq6capLqkGmeMlcHfcmGwnhcuoJ1uNlUYWigcKUaWtjKcidHj2qyHadOvZHaLZvqoGpKgcKUaWtjKcidHj2JWcbgqRMdbEK1qmUSzGlGaPla8ucPaYqy6qqyHadOvZHaHnfgVKCJfN7Gx(YwHaPla8ucPaYqyIDiSqGb0Q5qGY8Ivgx2mWfqG0faEkHuazimBbewiWaA1CiWlmCgj5UybKqG0faEkHuazidziqNiMSMdH56oRDl4mSRn2JavgSRoxse4sVfBjWCPIjgJd)IxGvd9IsnFy2l6d7foa6PWjYbVGrUdEXO0lKJk9Ia3g1WO0lGnX5IK6pBlTo6fTD4x4UZ5eXmk9chKtM2HQBzTw7GxyZlCqlR1Ah8ILxFjRP)ST06OxSUd)c3DoNiMrPx4GCY0ouDlR1Ah8cBEHdAzTw7GxSC7LSM(Z2sRJEr71D4x4UZ5eXmk9chKtM2HQBzTw7GxyZlCqlR1Ah8ILxFjRP)SF2LEl2sG5sftmgh(fVaRg6fLA(WSx0h2lCamjDWlyK7Gxmk9c5OsViWTrnmk9cytCUiP(Z2sRJEb2C4x4UZ5eXmk9chKtM2HQBzTw7GxyZlCqlR1Ah8ILD)swt)z)Sl9wSLaZLkMymo8lEbwn0lk18HzVOpSx4aP5GxWi3bVyu6fYrLErGBJAyu6fWM4Crs9NTLwh9I2o8lC35CIygLEHdYjt7q1TSwRDWlS5foOL1ATdEXYRVK10F2wAD0lCVd)c3DoNiMrPx4GCY0ouDlR1Ah8cBEHdAzTw7GxSC7LSM(Z2sRJEr71D4x4UZ5eXmk9chKtM2HQBzTw7GxyZlCqlR1Ah8ILxFjRP)SF2LQA(Wmk9cS)fb0Q5EHVKMu)zrGYCcIWCDS5EeyoB6LNqGl(fkqH0EXszinIT6flf4NrSp7IFrJz5shE)ExL1GdOHJ6EzPI7dRMdYIUTxwQW9F2f)Iwe3fU0ErBSR1xSUZA3cVaJEr71D4f5Sp7NDXVWDBIZfjD4p7IFbg9IwmLO0lC3b)mI9cWMXEHnVir9a3BViGwn3l8L00F2f)cm6fySL0lSsL42Wtf9ILDsQFHfmxKPTsL42WtfT2lS5fXzfSYdJEbDPxm9xqhCWpJy6p7IFbg9IwmLErQK5KxUphN5IKVWPkEbUv(Yw9IaA1CVWxst)zx8lWOxyS6wGmTdv3esoCgFAuEVOKVa)K455dZOK(Z(zx8lAjTecIBu6fauFy0lGJkqyVaGCvNu)IwecPCt(IBomQjyQDC)lcOvZjFXC(v6p7IFraTAoPoNrWrfiSmDFix4ZU4xeqRMtQZzeCubcBxM9bUlv6SWQ5(Sl(fb0Q5K6CgbhvGW2LzFFM0NnGwnNuNZi4Oce2Um7L4QQZXZj7ZU4xaErUSzSxWIk9ca8ENsVqAHjFba1hg9c4Oce2laix1jFrCPxKZimkFmRoxVOKVinhP)Sl(fb0Q5K6CgbhvGW2LzV8ICzZyCPfM8ZgqRMtQZzeCubcBxM95JvZ9zdOvZj15mcoQaHTlZECjXlJuB9cvkt4OSjyHK3NZ4tNNpkj2NnGwnNuNZi4Oce2Um7vomFYjQooJKZfhK(Sb0Q5K6CgbhvGW2LzVl8GLQ44tNhosSXA(Sb0Q5K6CgbhvGW2LzVkPoSv8PZ94WkXtmkuLF2aA1CsDoJGJkqy7YShxs8Yi1wPENGg)cvkdCf0pgBUcYb8H0AT6zColQeNCIotxNt4(JybGN00skPjDBzYDWR8CkPDkyva4jEDgDYYwXDvUcNgVXhjS8(WQZfNrb0g2AF2aA1CsDoJGJkqy7YSVpqCjL4HJeRmIdqHARvpJZzrL4Kt0z66Cc3Fela8KMwsjn5NDXVOftyCCPjFH1qViHZcRM7fXLEbCgFAuEVy6VOfL5e0EX0FH1qVyPx(0lIl9IwYSsn8VyPEsRoOjFbWQxyn0ls4SWQ5EX0FrCVa)AcPrPxGX4UySEHYg6EH1qRCaJEbUKsViNrWrfim9lAr5lAXXw6VOjKViErBT7LVaJXDXy9I4sVi6DcAYxuMK89xynL8fL8fT1TL6pBaTAoPoNrWrfiSDz2hYCcA8PZTgIRS8PwZzemKg3kvktBD7wREgNhosSYiDoRudpVoPvh0KA6capLCZ5KushK0KushK4tNBneVpqCzDU4fRKA1aJpm3wMCh8kpNs6WrztWcjVpNXNopFusSTnNtUdELNtjnCf0pgBUcYb8H0w7ZU4x0IjmoU0KVWAOxKWzHvZ9I4sVaoJpnkVxm9xOajTk8VyPZcR5fXLEXsr4i9IP)IwIWf9cGvVWAOxKWzHvZ9IP)I4Eb(1esJsVaJXDXy9cLn09cRHw5ag9cCjLEroJGJkqy6pBaTAoPoNrWrfiSDz2dqsRcpxjlSMwZzemKg3kvktBn2AT6zchjwzKoNvQHNxN0QdAsnDbGNsU5CskPdsAskPds8PZTgI3hiUSox8IvsTAGXhMBltUdELNtjD4OSjyHK3NZ4tNNpkj22MZj3bVYZPKgUc6hJnxb5a(qAR9z)Sb0Q5KACR8LTkdCWpJyCzZyF2aA1CsnUv(YwTlZEjXORSv8eU0(Sb0Q5KACR8LTAxM9Y8HrCOFWtF2aA1CsnUv(YwTlZE5mwtDU4kdJyF2aA1CsnUv(YwTlZE5CfKd4dP9zdOvZj14w5lB1Um7pYAigx2mWf(Sb0Q5KACR8LTAxM9WMcJxsUXIZDWlFzR(Sb0Q5KACR8LTAxM9Y8Ivgx2mWf(Sb0Q5KACR8LTAxM9xy4msYDXci9z)Sl(fTKwcbXnk9cYjIT6fwPsVWAOxeqByVOKViCkkFa4j9NnGwnNmdm8EEaTAoUVKwRxOszWTYx2QwREMebG37AyiT6CPXZ32seaEVRtLmN8(aWtC1Wvb145BBjcaV31PsMtEFa4joDSWfPXZ)Sb0Q5K7YShxs8Yiv5NnGwnNCxM94sIxgP26fQuMq24uCKKZchhghoSW3A1ZKia8ExZchhghoSWZteaEVRXZDB5Cg5e3fmPBRdzobn(05wdXvw(02MZj3bVYZPKgUc6hJnxb5a(qAUbG376qMtqJpDU1qCLLpPXZxZnlyUit3qH3A05qtr3JTTTLteaEVRzHJdJdhw45jcaV31Pr5TTzLkXTHNksX1X(1CZkvIBdpvegwE9fT0wgoJpnkpnCf0pgBUcYb8H00msnQtUBrkALkXTHNkAT1(Sb0Q5K7YShxs8Yi1wPENGg)cvkdCf0pgBUcYb8H0AT6zaW7DnajTk8CLSWA0Pr5TTzLkXTHNksrS9zdOvZj3Lzpm8EEaTAoUVKwRxOszGj5NnGwnNCxM9WW75b0Q54(sATEHkLrATw9mb0kNioDKArsfx)ZgqRMtUlZEy498aA1CCFjTwVqLYa9u4e1A1ZeqRCI40rQfjXq7p7NnGwnNudtYmXbjPXcphgEFRvpdCgFAuEAasAv45kzH1OzKAuNedU3zF2aA1Csnmj3LzFVyeGFMuRvpdCgFAuEAasAv45kzH1OzKAuNedU3zF2aA1Csnmj3LzpaXKeBH6C1A1ZaG376qMtqJpDU1qCLLpPXZDBzRujUn8uryaoJpnkpnaXKeBH6CPt4SWQ52LWzHvZTTTSfmxKPBOWBn6COPO7X22MZTWtNPxO8EIXRtA1bnnDbGNsRT22MvQe3gEQifB7(pBaTAoPgMK7YShWptI3XzRAT6zaW7DDiZjOXNo3AiUYYN045UTSvQe3gEQimaNXNgLNgWptI3XzR0jCwy1C7s4SWQ522w2cMlY0nu4TgDo0u09yBBZ5w4PZ0luEpX41jT6GMMUaWtP1wBBZkvIBdpvKITX(pBaTAoPgMK7YS3xUAmjhJJNCPsN1A1ZKtMggMgaV31DgDoUsJN7wozAyyAa8Ex3z054knJuJ6KyWfmPvJLST58CY0WW0a49UUZOZXvA88pBaTAoPgMK7YSpFSAUwREga8ExdqsRcpxjlSgnEUBa49UoK5e04tNBnexz5tA8C3w2cMlY0nu4TgDo0u09yBBZ5w4PZ0luEpX41jT6GMMUaWtP122wgoNexna8KoFSAo(054haRsEkX74SvUzLkXTHNksrSV92MvQe3gEQifxh7x7ZgqRMtQHj5Um7vomFYjQooJKZfhKAT6zaW7DTV6eGFMKwAbCbfx0NnGwnNudtYDz27cpyPko(05HJeBSMwREg4m(0O80HmNGgF6CRH4klFsZi1OoPITD22MvQe3gEQimeqRMt7cpyPko(05HJeBSgnCgFAuE7CVZ22SsL42WtfPO7D2NnGwnNudtYDz2ZQ8CpXRJlZdi9zdOvZj1WKCxM9QK6WwXNo3JdRepXOqv(z)Sb0Q5KAONcNOmabdGsCzZyTcxb9e3cMlYKzA3A1ZKtMggMgaV31DgDoUsJN7wozAyyAa8Ex3z054knJuJ6KkMXfmPvJLSdiyauIlBgJ7IfqINtSAsF2aA1Csn0tHt0Um7vX9wjBgR1QNXfmPvJLGr5KPHHPbW7DnafsJd9u4ePzKAuNedotVo2(Sb0Q5KAONcNODz2demakXLnJ1kCf0tClyUitMPDRvpth375mc2emxe3kvsrxWKwnwIBWz8Pr5PbiPvHNRKfwJMrQrDYpBaTAoPg6PWjAxM9HmNGgF6CRH4klF6ZgqRMtQHEkCI2LzV0c1CkrTw9ma49UoK5e04tNBnexz5tA8C3aW7DnajTk8CLSWA045BBwPsCB4PIuSn2(Sb0Q5KAONcNODz2dqsRcpxjlSMwREg4m(0O80HmNGgF6CRH4klFsZi1Ooj3fojLyyDNTTzHNotphXvwwd3AiEEaxqtxa4P02MvQe3gEQifBJTpBaTAoPg6PWjAxM9WMsniwWLnJ9zdOvZj1qpfor7YSp4Q4SeX4tNdzJs5NnGwnNud9u4eTlZEGGXcx0NnGwnNud9u4eTlZ(fkVNdhv14sTw9mb0kNioDKArsfx02MZdhjwzKMf5vIZi)ejnDbGNsF2aA1Csn0tHt0Um7tfJ4auiTpBaTAoPg6PWjAxM9abdGsCzZyTcxb9e3cMlYKzA3A1ZKtMggMgaV31DgDoUsNgLNBldBcMlsY7SaA1CHhdT1y32gaEVRbiPvHNRKfwJgpFTTn4m(0O80HmNGgF6CRH4klFsZi1OoPI5KPHHPbW7DDNrNJR0jCwy1CyKlyYTWrIvgPZzLA451jT6GMutxa4P02gSjyUijVZcOvZfEm0wVOTnRujUn8urk2cF2aA1Csn0tHt0Um77dexsjE4iXkJ4auO(zdOvZj1qpfor7YSphNv9v15Id4dP9zdOvZj1qpfor7YShohKoJfgL4DFOsF2aA1Csn0tHt0Um7b8ZK4tNBneNosD1NnGwnNud9u4eTlZERH44hWGFjEFyqQ1QNbaV31mcUGNKsEFyqsJNVTbG37AgbxWtsjVpmiXHd(zetlTaUGITD2NnGwnNud9u4eTlZEvCVvYMXAT6zchjwzKMf5vIZi)ejnDbGNsUfqRCI40rQfjXW6F2aA1Csn0tHt0Um7Hdal4YMXAT6zGZ4tJYtVq59C4OQgxsZi1Oojg6dexQTsL42WvJL42Yb0kNioDKArsfD)2MZdhjwzKMf5vIZi)ejnDbGNsR9zdOvZj1qpfor7YSxMxMvNloCayXN9ZgqRMtQLwgGGbqjUSzSwREMCY0WW0a49UUZOZXvA8C3YjtddtdG376oJohxPzKAuNurxW0oGGbqjUSzmUlwajEoXQjTTbNXNgLNgGKwfEUswynAgPg1jDB5oU3ZzeSjyUiUvQKIUGPTTWrIvgPZzLA451jT6GMutxa4PKBWz8Pr5Pdzobn(05wdXvw(KMrQrDsfDbtR9zdOvZj1sBxM9W5G0zSWOeV7dvQ1QNPpqC5U(aXLAg5IULMlysX(aXLA1yjUbG37AasAv45kzH1OtJYZTLDEAmnCoiDglmkX7(qL4a4StZi1OoPBopGwnNgohKoJfgL4DFOs664DF5QXwBBRJ79CgbBcMlIBLkPOlyABZkvIBdpvKIy7ZgqRMtQL2Um7dzobn(05wdXvw(uRvpdCgFAuEAGGbqjUSzmnSjyUiPIRVTLtMggMgaV31DgDoUslTaUagwFBZ5HJeRmsNZk1WZRtA1bnPMUaWtPpBaTAoPwA7YSxAHAoLOwREga8ExhYCcA8PZTgIRS8jnEUBa49UgGKwfEUswynA88TnRujUn8urk2gBF2aA1CsT02LzFWvXzjIXNohYgLYwREg4m(0O80aK0QWZvYcRrZi1Oo5NnGwnNulTDz23hiUKs8WrIvgXbOqT1QNbaV31aK0QWZvYcRrNgL32MvQe3gEQifX2NnGwnNulTDz2Bneh)ag8lX7ddsTw9ma49UMrWf8KuY7ddsA88Tna8ExZi4cEsk59HbjoCWpJyAPfWfuSTZ22SsL42WtfPi2(Sb0Q5KAPTlZEasAv45kzH18zdOvZj1sBxM9luEphoQQXL(Sb0Q5KAPTlZEytPgel4YMX(Sb0Q5KAPTlZ(uXioafs7ZgqRMtQL2Um7bcgaL4YMXAT6zYjtddtdG376oJohxPtJYZTLHnbZfj5DwaTAUWJH2ASBBdaV31aK0QWZvYcRrJNV22gCgFAuE6qMtqJpDU1qCLLpPzKAuNuXCY0WW0a49UUZOZXv6eolSAomYfm5w4iXkJ05Ssn886KwDqtQPla8uABlCKyLr6uCqIpDEIcRrZIBbm02na8ExNIds8PZtuyn60O8CdYkJNdnoeNXOZWWIC22MvQe3gEQifBHpBaTAoPwA7YSphNv9v15Id4dP1A1ZaG37AasAv45kzH1OtJYBBZkvIBdpvKIy3NnGwnNulTDz2d4NjXNo3AioDK6QpBaTAoPwA7YShiySWf9zdOvZj1sBxM9WbGfCzZyTw9ml3hiUeJGJ021hiUuZix0T0wgoJpnkp9cL3ZHJQACjnJuJ6Kyu71WqaTAo9cL3ZHJQACjnCK22gCgFAuE6fkVNdhv14sAgPg1jXq7DUGPTna8ExRsQdBfF6CpoSs8eJcvPgpFn3GZ4tJYtVq59C4OQgxsZi1OojgA)zdOvZj1sBxM9Y8YS6CXHdal(Sb0Q5KAPTlZEGGbqjUSzSwREgytWCrsENfqRMl8yOTEridziea]] )


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
        desc = "If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier.",
        icon = 2058007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 1,
        step = 0.01,
        width = 1.5
    } )    


end
