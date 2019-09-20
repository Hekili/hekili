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


    spec:RegisterPack( "Beast Mastery", 20190920, [[dWeUbbqiQO8iLqTjQu(ejsJskvNsjyvae5vaYSKs6wKiSls9lOWWiboMs0YauEgvQmnakxJe02OIQ(gjIACuPQohavRtkbZJe6EII9bO6GsjQfcL6HuPkteGu5IsjK8raszKae4KaeALIsZukH6Mae0oHIgQucPwQucXtbAQqjxfGu1xbiQXsIiNvkr2lK)IQbt0HfwSs9yqtwKlJSzP6ZujJwkoTKvdqYRLsz2u1TjPDRYVvmCr1XPIklhLNty6uUouTDQiFNkmELqopawpjQ5RK2VQgTeHfcmfgHWeykyjGRaahykqRaaxHaoGbmeObqoHaZdyBHlcbEHkHaXMcH9saHHWigaiW8aa)ejewiqXGZGecSXSCrlGbgUkRbFRHJkgIsf3hwnhKfDddrPcXabUXlVbiEOncmfgHWeykyjGRaahykqRaaxHaU7aCeyGBnddbcwQUhcSPsj6qBeyIeqe4IFj2uiSxcimegXa4LacWpJyF2f)YgZYfTagy4QSg8TgoQyikvCFy1Cqw0nmeLkeJp7IFjiLBK6MyVeykO1xcmfSeW)SF2f)s3RjoxKOf(Sl(LkXlB5uIsV09g8Zi2lbBg7L28Ye1dCV9YaA1CV0xct)zx8lvIxcOxqV0kvIBdpv0lB3jH(LwWCrM2kvIBdpv0cV0MxgNvWkpm6L0LE50FjDWb)mIP)Sl(LkXlB5u6LPsKtEbg54mxK4LovXlXTYxgaVmGwn3l9LW0F2f)sL4LgRU2itRK0nHGdNXNgh3llXlXpbEE(WmkPrG(sycewiWe1dCVHWcH5sewiq6ITNsiSrGqwzeRceyI249UggcRoxA88xUU(YeTX7DDQe5K3hBpXvdxfuJN)Y11xMOnEVRtLiN8(y7joDSWfPXZrGb0Q5qGWW75b0Q54(syiqFjm(fQece3kFzaGmeMadHfcmGwnhcexq8YivbcKUy7PecBKHW0DiSqG0fBpLqyJadOvZHadrJtXrcoluEyC4WcpceYkJyvGat0gV31Sq5HXHdl88eTX7DnE(lD7LT)YCg5e3fmPxQdrobn(05wdXDu(0lxxFPZEj5C4vEoL0qaG(XyZvq(2hc7LU9YnEVRdrobn(05wdXDu(Kgp)Ll8s3Ez7V0cMlY0nu4TgDo0EPIV0Dk8LRRV0zVKec6GKgoxIobL4(Qt9HbjTAaOg2lx4LRRVS9xMOnEVRzHYdJdhw45jAJ376044E566lTsL42Wtf9sfFjWC(xUWlD7LwPsCB4PIEjWFz7Veya2lbKEz7VeoJpnooneaOFm2CfKV9HW0msnQt8sGEjG9sfFPfmxKPTsL42Wtf9YfE5ciWlujeyiACkosWzHYdJdhw4rgctadHfcKUy7PecBeyaTAoeieaOFm2CfKV9HWqGqwzeRce4gV31Bsyv45oyH1OtJJ7LRRV0kvIBdpv0lv8Lkebs9obn(fQececa0pgBUcY3(qyidHPcryHaPl2EkHWgbgqRMdbcdVNhqRMJ7lHHa9LW4xOsiqysGmeMopcleiDX2tje2iqiRmIvbcmGw5eXPJuls8sfFjWqGb0Q5qGWW75b0Q54(syiqFjm(fQecuyidHPsgHfcKUy7PecBeiKvgXQabgqRCI40rQfjEjWF5seyaTAoeim8EEaTAoUVegc0xcJFHkHaHEkCIqgYqG5mcoQ7WqyHWCjcleyaTAoeOaxvDoEoziq6ITNsiSrgctGHWcbgqRMdbMpwnhcKUy7PecBKHW0DiSqG0fBpLqyJaVqLqGHYIMGfcEFoJpDE(4GyiWaA1CiWqzrtWcbVpNXNopFCqmKHWeWqyHadOvZHaDmmFYjQooJeZfhKqG0fBpLqyJmeMkeHfcmGwnhc0fEWsvC8PZdLj2yniq6ITNsiSrgctNhHfcmGwnhcuLuhga8PZ94WkXtmkufiq6ITNsiSrgctLmcleiDX2tje2iWaA1Ciqiaq)yS5kiF7dHHaHSYiwfiqN9swujo5eDMUoNW9hXITN00IkHjEPBVS9xsohELNtjTtbRITN41z0jkdaURYv404n(iGL3hwDU4mkG2WE5ciqQ3jOXVqLqGqaG(XyZvq(2hcdzimDFewiq6ITNsiSrGqwzeRceOZEjlQeNCIotxNt4(JyX2tAArLWeiWaA1CiW(aXfuIhktSYi(McvKHWeWryHaPl2EkHWgbMZiyimUvQecCPEjcmGwnhcme5e04tNBne3r5tiqiRmIvbc0zVmuMyLr6CwPgEEDcRoOj00fBpLEPBV0zVKec6GKMec6GeF6CRH49bIlQZfVyLqRgaQH9s3Ez7VKCo8kpNs6qzrtWcbVpNXNopFCqSxUU(sN9sY5WR8CkPHaa9JXMRG8Tpe2lxazimxQaewiq6ITNsiSrG5mcgcJBLkHaxQvicmGwnhcCtcRcp3blSgeiKvgXQabgktSYiDoRudpVoHvh0eA6ITNsV0Tx6SxscbDqstcbDqIpDU1q8(aXf15IxSsOvda1WEPBVS9xsohELNtjDOSOjyHG3NZ4tNNpoi2lxxFPZEj5C4vEoL0qaG(XyZvq(2hc7LlGmKHaHEkCIqyHWCjcleiDX2tje2iWaA1CiWDW2uIlAgdbczLrSkqGB8Ex3z0PmaA88x62l349UUZOtza0msnQt8sfZ8sxWKwnw0lb6L7GTPex0mg3flGepNy1KqGqaGEIBbZfzceMlrgctGHWcbsxS9ucHnceYkJyvGaDbtA1yrVujE5gV31Bkegh6PWjsZi1OoXlb(lvGgykebgqRMdbQI7Ts0mgYqy6oewiq6ITNsiSrGb0Q5qG7GTPex0mgceYkJyvGa74EpNrWMG5I4wPsVuXx6cM0QXIEPBVeoJpnoo9MewfEUdwynAgPg1jqGqaGEIBbZfzceMlrgctadHfcmGwnhcme5e04tNBne3r5tiq6ITNsiSrgctfIWcbsxS9ucHnceYkJyvGa349Uoe5e04tNBne3r5tA88x62l349UEtcRcp3blSgnE(lxxFPvQe3gEQOxQ4lxQqeyaTAoeOWc1CkridHPZJWcbsxS9ucHnceYkJyvGaHZ4tJJthICcA8PZTgI7O8jnJuJ6eCx4Kq8sG)sGPGxUU(sl80z65iUJYA4wdXZdyBA6ITNsVCD9LwPsCB4PIEPIVCPcrGb0Q5qGBsyv45oyH1GmeMkzewiWaA1CiqytPgel4IMXqG0fBpLqyJmeMUpcleyaTAoeyWvXzjIXNohYghceiDX2tje2idHjGJWcbgqRMdbUdglCriq6ITNsiSrgcZLkaHfcKUy7PecBeiKvgXQabgqRCI40rQfjEPIVeWE566lD2ldLjwzKMf5vIZi)ejnDX2tjeyaTAoeyBL3ZHJQACjKHWC5sewiWaA1CiWuXi(McHHaPl2EkHWgzimxcmewiq6ITNsiSrGb0Q5qG7GTPex0mgceYkJyvGa349UUZOtza0PXX9s3Ez7Ve2emxKG3zb0Q5c)lb(lxQD)xUU(YnEVR3KWQWZDWcRrJN)YfE566lHZ4tJJthICcA8PZTgI7O8jnJuJ6eVuXxUX7DDNrNYaOt4SWQ5EPs8sxW0lD7LHYeRmsNZk1WZRty1bnHMUy7P0lxxFjSjyUibVZcOvZf(xc8xUudyVCD9LwPsCB4PIEPIVeWrGqaGEIBbZfzceMlrgcZLUdHfcmGwnhcSpqCbL4HYeRmIVPqfbsxS9ucHnYqyUeWqyHadOvZHaZXzvhG6CX3(qyiq6ITNsiSrgcZLkeHfcmGwnhceohKoJfgL4DFOsiq6ITNsiSrgcZLopcleyaTAoe42ptIpDU1qC6ivaqG0fBpLqyJmeMlvYiSqG0fBpLqyJaHSYiwfiWnEVRzeSnpje8(WGKgp)LRRVCJ37AgbBZtcbVpmiXHd(zetlSa22lv8LlvacmGwnhc0Aio(Th8lX7ddsidH5s3hHfcKUy7PecBeiKvgXQabgktSYinlYReNr(jsA6ITNsV0TxgqRCI40rQfjEjWFjWqGb0Q5qGQ4ERenJHmeMlbCewiq6ITNsiSrGqwzeRceiCgFACC62kVNdhv14sAgPg1jEjWFzFG4cTvQe3gUASOx62lB)Lb0kNioDKArIxQ4lD3lxxFPZEzOmXkJ0SiVsCg5NiPPl2Ek9YfqGb0Q5qGWzZcUOzmKHWeykaHfcmGwnhcuKxMvNloC2SabsxS9ucHnYqgceMeiSqyUeHfcKUy7PecBeiKvgXQabcNXNghNEtcRcp3blSgnJuJ6eVe4V0DkabgqRMdbghKegl8Cy49idHjWqyHaPl2EkHWgbczLrSkqGWz8PXXP3KWQWZDWcRrZi1OoXlb(lDNcqGb0Q5qG9IrB)mjKHW0DiSqG0fBpLqyJaHSYiwfiWnEVRdrobn(05wdXDu(Kgp)LU9Y2FPvQe3gEQOxc8xcNXNghNEtmbXARox6eolSAUxc0lt4SWQ5E566lB)LwWCrMUHcV1OZH2lv8LUtHVCD9Lo7Lw4PZ0TvEpX41jS6GMMUy7P0lx4Ll8Y11xALkXTHNk6Lk(YLUdbgqRMdbUjMGyTvNlKHWeWqyHaPl2EkHWgbczLrSkqGB8ExhICcA8PZTgI7O8jnE(lD7LT)sRujUn8urVe4VeoJpnoo92ptI3XzaOt4SWQ5EjqVmHZcRM7LRRVS9xAbZfz6gk8wJohAVuXx6of(Y11x6SxAHNot3w59eJxNWQdAA6ITNsVCHxUWlxxFPvQe3gEQOxQ4lx68iWaA1CiWTFMeVJZaazimvicleiDX2tje2iqiRmIvbcCJ376oJoLbqJN)s3E5gV31DgDkdGMrQrDIxc8x6cM0QXIE566lD2l349UUZOtza045iWaA1CiqF5QXeCafEYLkDgYqy68iSqG0fBpLqyJaHSYiwfiWnEVR3KWQWZDWcRrJN)s3E5gV31HiNGgF6CRH4okFsJN)s3Ez7V0cMlY0nu4TgDo0EPIV0Dk8LRRV0zV0cpDMUTY7jgVoHvh000fBpLE5cVCD9LT)s4CcC1y7jD(y1C8PZXVnRsEkX74maEPBV0kvIBdpv0lv8Lo)YxUU(sRujUn8urVuXxcmN)LlGadOvZHaZhRMdzimvYiSqG0fBpLqyJaHSYiwfiWnEVR9vN2(zsAHfW2EPIVeWqGb0Q5qGogMp5evhNrI5IdsidHP7JWcbsxS9ucHnceYkJyvGaHZ4tJJthICcA8PZTgI7O8jnJuJ6eVuXxUubVCD9LwPsCB4PIEjWFzaTAoTl8GLQ44tNhktSXA0Wz8PXX9sGEP7uWlxxFPvQe3gEQOxQ4lDNcqGb0Q5qGUWdwQIJpDEOmXgRbzimbCewiWaA1CiqwLN7jEDCrEajeiDX2tje2idH5sfGWcbgqRMdbQsQdda(05ECyL4jgfQceiDX2tje2idziqHHWcH5sewiq6ITNsiSrGqwzeRce4gV31DgDkdGgp)LU9YnEVR7m6uganJuJ6eVuXx6cMEjqVChSnL4IMX4UybK45eRM0lxxFjCgFACC6njSk8ChSWA0msnQt8s3Ez7VSJ79CgbBcMlIBLk9sfFPly6LRRVmuMyLr6CwPgEEDcRoOj00fBpLEPBVeoJpnooDiYjOXNo3AiUJYN0msnQt8sfFPly6LlGadOvZHa3bBtjUOzmKHWeyiSqG0fBpLqyJaHSYiwfiW(aXfVeOx2hiUqZix09saPx6cMEPIVSpqCHwnw0lD7LB8ExVjHvHN7GfwJonoUx62lB)Lo7LPX0W5G0zSWOeV7dvIVXzNMrQrDIx62lD2ldOvZPHZbPZyHrjE3hQKUoE3xUASxUWlxxFzh375mc2emxe3kv6Lk(sxW0lxxFPvQe3gEQOxQ4lvicmGwnhceohKoJfgL4DFOsidHP7qyHaPl2EkHWgbczLrSkqGWz8PXXP3bBtjUOzmnSjyUiXlv8La7LRRVCJ376oJoLbqlSa22lb(lb2lxxFPZEzOmXkJ05Ssn886ewDqtOPl2EkHadOvZHadrobn(05wdXDu(eYqycyiSqG0fBpLqyJaHSYiwfiWnEVRdrobn(05wdXDu(Kgp)LU9YnEVR3KWQWZDWcRrJN)Y11xALkXTHNk6Lk(YLkebgqRMdbkSqnNseYqyQqewiq6ITNsiSrGqwzeRceiCgFACC6njSk8ChSWA0msnQtGadOvZHadUkolrm(05q24qGmeMopcleiDX2tje2iqiRmIvbcCJ376njSk8ChSWA0PXX9Y11xALkXTHNk6Lk(sfIadOvZHa7dexqjEOmXkJ4BkurgctLmcleiDX2tje2iqiRmIvbcCJ37AgbBZtcbVpmiPXZF566l349UMrW28KqW7ddsC4GFgX0clGT9sfF5sf8Y11xALkXTHNk6Lk(sfIadOvZHaTgIJF7b)s8(WGeYqy6(iSqGb0Q5qGBsyv45oyH1GaPl2EkHWgzimbCewiWaA1CiW2kVNdhv14siq6ITNsiSrgcZLkaHfcmGwnhce2uQbXcUOzmeiDX2tje2idH5YLiSqGb0Q5qGPIr8nfcdbsxS9ucHnYqyUeyiSqG0fBpLqyJaHSYiwfiWnEVR7m6ugaDACCV0Tx2(lHnbZfj4DwaTAUW)sG)YLA3)LRRVCJ376njSk8ChSWA045VCHxUU(s4m(0440HiNGgF6CRH4okFsZi1OoXlv8LB8Ex3z0Pma6eolSAUxQeV0fm9s3EzOmXkJ05Ssn886ewDqtOPl2Ek9Y11xgktSYiDkoiXNoprH1OzX12lb(lx(s3E5gV31P4GeF68efwJonoUx62lHSY45qJdXzm6Sxc8xcyk4LRRV0kvIBdpv0lv8LaocmGwnhcChSnL4IMXqgcZLUdHfcKUy7PecBeiKvgXQabUX7D9MewfEUdwyn6044E566lTsL42Wtf9sfFP7JadOvZHaZXzvhG6CX3(qyidH5sadHfcmGwnhcC7NjXNo3AioDKkaiq6ITNsiSrgcZLkeHfcmGwnhcChmw4IqG0fBpLqyJmeMlDEewiq6ITNsiSrGqwzeRcey7VSpqCXlvIxchH9sGEzFG4cnJCr3lbKEz7VeoJpnooDBL3ZHJQACjnJuJ6eVujE5YxUWlb(ldOvZPBR8EoCuvJlPHJWE566lHZ4tJJt3w59C4OQgxsZi1OoXlb(lx(sGEPly6LRRVCJ37AvsDyaWNo3JdRepXOqvOXZF5cV0TxcNXNghNUTY75WrvnUKMrQrDIxc8xUebgqRMdbcNnl4IMXqgcZLkzewiWaA1CiqrEzwDU4WzZceiDX2tje2idH5s3hHfcKUy7PecBeiKvgXQabcBcMlsW7SaA1CH)La)Ll1agcmGwnhcChSnL4IMXqgYqG4w5ldaewimxIWcbgqRMdbch8Zigx0mgcKUy7PecBKHWeyiSqGb0Q5qGcIrxzaWt4cdbsxS9ucHnYqy6oewiWaA1Ciqr(Wio0p4jeiDX2tje2idHjGHWcbgqRMdbkMXAQZf3ryedbsxS9ucHnYqyQqewiWaA1CiqXCfKV9HWqG0fBpLqyJmeMopcleyaTAoe4rwdX4IMb2gcKUy7PecBKHWujJWcbgqRMdbcBkavj4gloNdV8LbacKUy7PecBKHW09ryHadOvZHaf5fRmUOzGTHaPl2EkHWgzimbCewiWaA1CiWlmCgj4UybKqG0fBpLqyJmKHmeOtetuZHWeykyjGRa3FP7JaDeSRoxceiGCl3IGjGiMaATWlFjwn0ll18HzVSpSxQuONcNiL(sg5C4fJsVumQ0ldCBudJsVe2eNlsO)ST46OxUSfEP7nNteZO0lvAozALKUL0ATsFPnVuPTKwRv6lBhylAb9NTfxh9sG1cV09MZjIzu6LknNmTss3sATwPV0MxQ0wsR1k9LTVCrlO)ST46OxUeyTWlDV5CIygLEPsZjtRK0TKwRv6lT5LkTL0ATsFz7aBrlO)SFwa5wUfbtarmb0AHx(sSAOxwQ5dZEzFyVuPWKqPVKrohEXO0lfJk9Ya3g1WO0lHnX5Ie6pBlUo6LkSfEP7nNteZO0lvAozALKUL0ATsFPnVuPTKwRv6lB3DlAb9N9Zci3YTiyciIjGwl8YxIvd9YsnFy2l7d7Lkvyk9LmY5WlgLEPyuPxg42OggLEjSjoxKq)zBX1rVCzl8s3BoNiMrPxQ0CY0kjDlP1AL(sBEPsBjTwR0x2oWw0c6pBlUo6LURfEP7nNteZO0lvAozALKUL0ATsFPnVuPTKwRv6lBF5Iwq)zBX1rVCjWAHx6EZ5eXmk9sLMtMwjPBjTwR0xAZlvAlP1AL(Y2b2Iwq)z)SaIQ5dZO0lD(xgqRM7L(syc9NfbkYjictGPq3HaZztV8ecCXVeBke2lbegcJya8sab4NrSp7IFzJz5IwadmCvwd(wdhvmeLkUpSAoil6ggIsfIXNDXVeKYnsDtSxcmf06lbMcwc4F2p7IFP71eNls0cF2f)sL4LTCkrPx6Ed(ze7LGnJ9sBEzI6bU3EzaTAUx6lHP)Sl(LkXlb0lOxALkXTHNk6LT7Kq)slyUitBLkXTHNkAHxAZlJZkyLhg9s6sVC6VKo4GFgX0F2f)sL4LTCk9YujYjVaJCCMls8sNQ4L4w5ldGxgqRM7L(sy6p7IFPs8sJvxBKPvs6MqWHZ4tJJ7LL4L4NappFygL0F2p7IFzlQfrqCJsVCt9HrVeoQ7WE5MCvNq)YwgcPCt8YBoLOjyQDC)ldOvZjE5CEa0F2f)YaA1CcDoJGJ6oSmDFiA7ZU4xgqRMtOZzeCu3HbugmcCxQ0zHvZ9zx8ldOvZj05mcoQ7Wakdg9zsF2aA1CcDoJGJ6omGYGHaxvDoEozF2f)sWlYfnJ9swuPxUX7Dk9sHfM4LBQpm6LWrDh2l3KR6eVmU0lZzKsKpMvNRxwIxMMJ0F2f)YaA1CcDoJGJ6omGYGH4ICrZyCHfM4ZgqRMtOZzeCu3HbugmYhRM7ZgqRMtOZzeCu3HbugmWfeVmsT1luPmHYIMGfcEFoJpDE(4GyF2aA1CcDoJGJ6omGYGHJH5tor1XzKyU4G0NnGwnNqNZi4OUddOmy4cpyPko(05HYeBSMpBaTAoHoNrWrDhgqzWqLuhga8PZ94WkXtmkufF2aA1CcDoJGJ6omGYGbUG4LrQTs9obn(fQugiaq)yS5kiF7dH1A1Z4mwujo5eDMUoNW9hXITN00IkHjCRDY5WR8CkPDkyvS9eVoJorzaWDvUcNgVXhbS8(WQZfNrb0g2cF2aA1CcDoJGJ6omGYGrFG4ckXdLjwzeFtHARvpJZyrL4Kt0z66Cc3Fel2EstlQeM4ZU4x2YjafUWeV0AOxMWzHvZ9Y4sVeoJpnoUxo9x2YICcAVC6V0AOxcix(0lJl9Yw0Ssn8Veq8ewDqt8YnaV0AOxMWzHvZ9YP)Y4Ej(1ecJsVeqZ9a09shn09sRHaqPm6L4ck9YCgbh1Dy6x2YIx2YJbi)YMq8Y4Ll1Ut8san3dq3lJl9YO3jOjEzzcY3FP1uIxwIxUuVuO)Sb0Q5e6Cgbh1DyaLbJqKtqJpDU1qChLp1AoJGHW4wPszwQx2A1Z4SqzIvgPZzLA451jS6GMqtxS9uYnNrcbDqstcbDqIpDU1q8(aXf15IxSsOvda1WCRDY5WR8CkPdLfnble8(CgF688XbXwxDg5C4vEoL0qaG(XyZvq(2hcBHp7IFzlNau4ct8sRHEzcNfwn3lJl9s4m(044E50Fj2KWQW)sazwynVmU0lbeektVC6VSfjCrVCdWlTg6LjCwy1CVC6VmUxIFnHWO0lb0CpaDV0rdDV0AiaukJEjUGsVmNrWrDhM(ZgqRMtOZzeCu3Hbugm2KWQWZDWcRP1CgbdHXTsLYSuRWwREMqzIvgPZzLA451jS6GMqtxS9uYnNrcbDqstcbDqIpDU1q8(aXf15IxSsOvda1WCRDY5WR8CkPdLfnble8(CgF688XbXwxDg5C4vEoL0qaG(XyZvq(2hcBHp7NnGwnNqJBLVmaYah8Zigx0m2NnGwnNqJBLVmaakdgcIrxzaWt4c7ZgqRMtOXTYxgaaLbdr(Wio0p4PpBaTAoHg3kFzaaugmeZyn15I7imI9zdOvZj04w5ldaGYGHyUcY3(qyF2aA1CcnUv(YaaOmyCK1qmUOzGT9zdOvZj04w5ldaGYGbSPauLGBS4Co8YxgaF2aA1CcnUv(YaaOmyiYlwzCrZaB7ZgqRMtOXTYxgaaLbJlmCgj4UybK(SF2f)YwulIG4gLEj5eXa4LwPsV0AOxgqByVSeVmCkkFS9K(ZgqRMtKbgEppGwnh3xcR1luPm4w5ldGwREMeTX7DnmewDU045RRjAJ376ujYjVp2EIRgUkOgpFDnrB8ExNkro59X2tC6yHlsJN)zdOvZjakdg4cIxgPk(Sb0Q5eaLbdCbXlJuB9cvktiACkosWzHYdJdhw4BT6zs0gV31Sq5HXHdl88eTX7DnEUBTNZiN4UGj9sDiYjOXNo3AiUJYNwxDg5C4vEoL0qaG(XyZvq(2hcZTnEVRdrobn(05wdXDu(KgpFb3A3cMlY0nu4TgDo0u0DkCD1zKqqhK0W5s0jOe3xDQpmiPvda1WwyDT9eTX7DnluEyC4WcpprB8ExNgh36QvQe3gEQifbMZVGBwPsCB4PIaE7adWaKAhoJpnooneaOFm2CfKV9HW0msnQtaeGPOfmxKPTsL42WtfTWcF2aA1CcGYGbUG4LrQTs9obn(fQugiaq)yS5kiF7dH1A1ZSX7D9MewfEUdwyn6044wxTsL42WtfPOc)Sb0Q5eaLbdy498aA1CCFjSwVqLYatIpBaTAobqzWagEppGwnh3xcR1luPmcR1QNjGw5eXPJulsOiW(Sb0Q5eaLbdy498aA1CCFjSwVqLYa9u4e1A1ZeqRCI40rQfja(Yp7NnGwnNqdtImXbjHXcphgEFRvpdCgFACC6njSk8ChSWA0msnQtaC3PGpBaTAoHgMeaLbJEXOTFMuRvpdCgFACC6njSk8ChSWA0msnQtaC3PGpBaTAoHgMeaLbJnXeeRT6C1A1ZSX7DDiYjOXNo3AiUJYN045U1UvQe3gEQiGdNXNghNEtmbXARox6eolSAoGs4SWQ5wxB3cMlY0nu4TgDo0u0DkCD1zw4PZ0TvEpX41jS6GMMUy7P0clSUALkXTHNksXLU7ZgqRMtOHjbqzWy7NjX74maAT6z249Uoe5e04tNBne3r5tA8C3A3kvIBdpveWHZ4tJJtV9ZK4DCga6eolSAoGs4SWQ5wxB3cMlY0nu4TgDo0u0DkCD1zw4PZ0TvEpX41jS6GMMUy7P0clSUALkXTHNksXLo)NnGwnNqdtcGYGHVC1ycoGcp5sLoR1QNjNmnmm9gV31DgDkdGgp3TCY0WW0B8Ex3z0PmaAgPg1jaUlysRglAD1z5KPHHP349UUZOtza045F2aA1Ccnmjakdg5JvZ1A1ZSX7D9MewfEUdwynA8C3249Uoe5e04tNBne3r5tA8C3A3cMlY0nu4TgDo0u0DkCD1zw4PZ0TvEpX41jS6GMMUy7P0cRRTdNtGRgBpPZhRMJpDo(TzvYtjEhNbGBwPsCB4PIu05xUUALkXTHNksrG58l8zdOvZj0WKaOmy4yy(KtuDCgjMloi1A1ZSX7DTV602ptslSa2MIa2NnGwnNqdtcGYGHl8GLQ44tNhktSXAAT6zGZ4tJJthICcA8PZTgI7O8jnJuJ6ekUubRRwPsCB4PIaEaTAoTl8GLQ44tNhktSXA0Wz8PXXbK7uW6QvQe3gEQifDNc(Sb0Q5eAysaugmyvEUN41Xf5bK(Sb0Q5eAysaugmuj1HbaF6CpoSs8eJcvXN9ZgqRMtOHEkCIYSd2MsCrZyTcba6jUfmxKjYSS1QNjNmnmm9gV31DgDkdGgp3TCY0WW0B8Ex3z0PmaAgPg1jumJlysRglcODW2uIlAgJ7IfqINtSAsF2aA1Ccn0tHteqzWqf3BLOzSwREgxWKwnwKsKtMggMEJ376nfcJd9u4ePzKAuNa4kqdmf(zdOvZj0qpforaLbJDW2uIlAgRviaqpXTG5ImrMLTw9mDCVNZiytWCrCRujfDbtA1yrUbNXNghNEtcRcp3blSgnJuJ6eF2aA1Ccn0tHteqzWie5e04tNBne3r5tF2aA1Ccn0tHteqzWqyHAoLOwREMnEVRdrobn(05wdXDu(Kgp3TnEVR3KWQWZDWcRrJNVUALkXTHNksXLk8ZgqRMtOHEkCIakdgBsyv45oyH10A1ZaNXNghNoe5e04tNBne3r5tAgPg1j4UWjHa4atbRRw4PZ0ZrChL1WTgINhW200fBpLwxTsL42WtfP4sf(zdOvZj0qpforaLbdytPgel4IMX(Sb0Q5eAONcNiGYGrWvXzjIXNohYghIpBaTAoHg6PWjcOmySdglCrF2aA1Ccn0tHteqzWOTY75WrvnUuRvptaTYjIthPwKqraBD1zHYeRmsZI8kXzKFIKMUy7P0NnGwnNqd9u4ebugmsfJ4Bke2NnGwnNqd9u4ebugm2bBtjUOzSwHaa9e3cMlYezw2A1ZKtMggMEJ376oJoLbqNghNBTdBcMlsW7SaA1CHh4l1U)66gV31Bsyv45oyH1OXZxyDfoJpnooDiYjOXNo3AiUJYN0msnQtOyozAyy6nEVR7m6ugaDcNfwnNs4cMCluMyLr6CwPgEEDcRoOj00fBpLwxHnbZfj4DwaTAUWd8LAaBD1kvIBdpvKIa(NnGwnNqd9u4ebugm6dexqjEOmXkJ4Bku)Sb0Q5eAONcNiGYGrooR6auNl(2hc7ZgqRMtOHEkCIakdgW5G0zSWOeV7dv6ZgqRMtOHEkCIakdgB)mj(05wdXPJub4ZgqRMtOHEkCIakdgwdXXV9GFjEFyqQ1QNzJ37AgbBZtcbVpmiPXZxx349UMrW28KqW7ddsC4GFgX0clGTP4sf8zdOvZj0qpforaLbdvCVvIMXAT6zcLjwzKMf5vIZi)ejnDX2tj3cOvorC6i1IeahyF2aA1Ccn0tHteqzWaoBwWfnJ1A1ZaNXNghNUTY75WrvnUKMrQrDcG3hiUqBLkXTHRglYT2dOvorC6i1Iek6U1vNfktSYinlYReNr(jsA6ITNsl8zdOvZj0qpforaLbdrEzwDU4WzZIp7NnGwnNqlSm7GTPex0mwRvptozAyy6nEVR7m6uganEUB5KPHHP349UUZOtza0msnQtOOlycODW2uIlAgJ7IfqINtSAsRRWz8PXXP3KWQWZDWcRrZi1OoHBT3X9EoJGnbZfXTsLu0fmTUgktSYiDoRudpVoHvh0eA6ITNsUbNXNghNoe5e04tNBne3r5tAgPg1ju0fmTWNnGwnNqlmGYGbCoiDglmkX7(qLAT6z6dexauFG4cnJCrhGKlysX(aXfA1yrUTX7D9MewfEUdwyn6044CRDNLgtdNdsNXcJs8Upuj(gNDAgPg1jCZzb0Q50W5G0zSWOeV7dvsxhV7lxn2cRRDCVNZiytWCrCRujfDbtRRwPsCB4PIuuHF2aA1CcTWakdgHiNGgF6CRH4okFQ1QNboJpnoo9oyBkXfnJPHnbZfjueyRR5KPHHP349UUZOtza0clGTbCGTU6SqzIvgPZzLA451jS6GMqtxS9u6ZgqRMtOfgqzWqyHAoLOwREMnEVRdrobn(05wdXDu(Kgp3TnEVR3KWQWZDWcRrJNVUALkXTHNksXLk8ZgqRMtOfgqzWi4Q4SeX4tNdzJdrRvpdCgFACC6njSk8ChSWA0msnQt8zdOvZj0cdOmy0hiUGs8qzIvgX3uO2A1ZSX7D9MewfEUdwyn6044wxTsL42WtfPOc)Sb0Q5eAHbugmSgIJF7b)s8(WGuRvpZgV31mc2MNecEFyqsJNVUUX7DnJGT5jHG3hgK4Wb)mIPfwaBtXLkyD1kvIBdpvKIk8ZgqRMtOfgqzWytcRcp3blSMpBaTAoHwyaLbJ2kVNdhv14sF2aA1CcTWakdgWMsniwWfnJ9zdOvZj0cdOmyKkgX3uiSpBaTAoHwyaLbJDW2uIlAgR1QNjNmnmm9gV31DgDkdGonoo3Ah2emxKG3zb0Q5cpWxQD)11nEVR3KWQWZDWcRrJNVW6kCgFACC6qKtqJpDU1qChLpPzKAuNqXCY0WW0B8Ex3z0Pma6eolSAoLWfm5wOmXkJ05Ssn886ewDqtOPl2EkTUgktSYiDkoiXNoprH1OzX1gWx62gV31P4GeF68efwJonoo3GSY45qJdXzm6mGdykyD1kvIBdpvKIa(NnGwnNqlmGYGrooR6auNl(2hcR1QNzJ376njSk8ChSWA0PXXTUALkXTHNksr3)ZgqRMtOfgqzWy7NjXNo3AioDKkaF2aA1CcTWakdg7GXcx0NnGwnNqlmGYGbC2SGlAgR1QNP9(aXfkbCegq9bIl0mYfDasTdNXNghNUTY75WrvnUKMrQrDcLy5capGwnNUTY75WrvnUKgocBDfoJpnooDBL3ZHJQACjnJuJ6eaFjqUGP11nEVRvj1HbaF6CpoSs8eJcvHgpFb3GZ4tJJt3w59C4OQgxsZi1OobWx(zdOvZj0cdOmyiYlZQZfhoBw8zdOvZj0cdOmySd2MsCrZyTw9mWMG5Ie8olGwnx4b(snGHmKHqa]] )


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
