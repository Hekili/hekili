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


    spec:RegisterPack( "Beast Mastery", 20190816, [[dWembbqiQu8iLq2evQ(evqJsjQtPezvae5vaYSKs6wqjSls9la1WOIQJjLAzqj9mQatdG01ibTnsaFJeiJJkkoNucToQuY8iHUNOyFauhKkLAHqPEOucMiuIKlkLiYhHseJeGaNeGqRuuAMsjs3eGG2juyOsjIAPsjcpfOPcfDvOeP(karnwsG6SsjQ9c5VOAWeDyHfRupg0Kf5YiBwQ(mvYOLItlz1qjQxRemBQ62K0Uv53kgUO64urPLJYZjmDkxhQ2ovOVtIgVsOopawpvK5RK2VQg1gHjcmfgHWaRoVDl6CNPTcOBRqh4moaqrGga5ecmpGleUie4fQeceBke2lbegcJyaGaZda8tKqyIafdodsiWgZYfUfWa7QSg8TgoQalkvCFy1Cqw0nGfLkeye4gV8gG4H2iWuyecdS682TOZDM2kGUTcDGZ4G2iWa3AggceSuBbeytLs0H2iWejGiWf9sSPqyVeqyimIbWlbeGFgX(Sl6LnMLlClGb2vzn4BnCubwuQ4(WQ5GSOBalkviWF2f9s3g3fUWEzBfO1xIvN3UfFjw8Y2k0TCGZ)SF2f9YwOjoxKWT(Sl6LyXlD7uIsVSfg8Zi2lbBg7L28Ye1dCV9YaA1CV0xct)zx0lXIxILwqV0kvIBdpv0lx2rH(LwWCrM2kvIBdpv0sV0MxgNvWkpm6L0LE50FjDWb)mIP)Sl6LyXlD7u6LPsKtEbW54mxK4LowXlXTYxgaVmGwn3l9LW0F2f9sS4LgRUfitRG1nHGdNXNgL3llXlXpbEE(WmkPrG(syceMiWe1dCVHWeHrBeMiq6ITNsiSrGqwzeRceyI249UggcRoxA88xUU(YeTX7DDQe5K3hBpXvdxfuJN)Y11xMOnEVRtLiN8(y7joDSWfPXZrGb0Q5qGWW75b0Q54(syiqFjm(fQece3kFzaGmegyfHjcmGwnhcexq8YivbcKUy7PecBKHWWbimrG0fBpLqyJadOvZHadrJJXrcolCAyC4WcpceYkJyvGat0gV31SWPHXHdl88eTX7DnE(lD)Ll)YCg5i3fmPBRdrobn(05wdXvw(0lxxFPBEj5S4vEoL0qaG(XyZvq(2hc7LU)YnEVRdrobn(05wdXvw(Kgp)Ll9Y11xU8lt0gV31SWPHXHdl88eTX7DDAuEVCD9LwPsCB4PIEPIVeRkWlx6LU)sRujUn8urVeWVC5xIva9LasVC5xcNXNgLNgca0pgBUcY3(qyAgPg1jEjqVeqFPIV0kvIBdpv0lx6LlHaVqLqGHOXX4ibNfonmoCyHhzimaueMiq6ITNsiSrGb0Q5qGqaG(XyZvq(2hcdbczLrSkqGB8ExVjHvHNRKfwJonkVxUU(sRujUn8urVuXxQqei17e04xOsiqiaq)yS5kiF7dHHmegkeHjcKUy7PecBeyaTAoeim8EEaTAoUVegc0xcJFHkHaHjbYqyOaimrG0fBpLqyJaHSYiwfiWaALJeNosTiXlv8LyfbgqRMdbcdVNhqRMJ7lHHa9LW4xOsiqHHmegkieMiq6ITNsiSrGqwzeRceyaTYrIthPwK4La(LTrGb0Q5qGWW75b0Q54(syiqFjm(fQece6PWrczidbMZi4OUddHjcJ2imrGb0Q5qGcCv1545KHaPl2EkHWgzimWkcteyaTAoey(y1Ciq6ITNsiSrgcdhGWebsxS9ucHnc8cvcbgojAcwi495m(055JsIHadOvZHadNenble8(CgF688rjXqgcdafHjcmGwnhcu5W8jhP64msmxCqcbsxS9ucHnYqyOqeMiWaA1Ciqx4blvXXNopCIyJ1GaPl2EkHWgzimuaeMiWaA1CiqvsDyaWNo3JdRepXOqvGaPl2EkHWgzimuqimrG0fBpLqyJadOvZHaHaa9JXMRG8TpegceYkJyvGaDZlzrL4KJ0z66Ce3Fel2EstlUeM4LU)YLFj5S4vEoL0ogSk2EIxNrNOma4UkxHJJ34JawEFy15IZOaAd7LlHaPENGg)cvcbcba6hJnxb5BFimKHWWzqyIaPl2EkHWgbczLrSkqGU5LSOsCYr6mDDoI7pIfBpPPfxctGadOvZHa7dexqjE4eXkJ4BkurgcJweHjcKUy7PecBeyoJGHW4wPsiW262iWaA1CiWqKtqJpDU1qCLLpHaHSYiwfiq38YWjIvgPZzLA451jS6GMqtxS9u6LU)s38ssiOdsAsiOds8PZTgI3hiUOox8IvcTAGLh2lD)Ll)sYzXR8CkPdNenble8(CgF688rjXE566lDZljNfVYZPKgca0pgBUcY3(qyVCjKHWOTZryIaPl2EkHWgbMZiyimUvQecSTwHiWaA1CiWnjSk8CLSWAqGqwzeRcey4eXkJ05Ssn886ewDqtOPl2Ek9s3FPBEjje0bjnje0bj(05wdX7dexuNlEXkHwnWYd7LU)YLFj5S4vEoL0HtIMGfcEFoJpDE(OKyVCD9LU5LKZIx55usdba6hJnxb5BFiSxUeYqgce6PWrcHjcJ2imrG0fBpLqyJadOvZHa3bBtjUOzmeiKvgXQabUX7DDNrNtaOXZFP7VCJ376oJoNaqZi1OoXlvmZlDbtA1yXVeOxUd2MsCrZyCxSas8CIvtcbcba6jUfmxKjqy0gzimWkcteiDX2tje2iqiRmIvbc0fmPvJf)sS4LB8ExVPqyCONchjnJuJ6eVeWV05ASQqeyaTAoeOkU3krZyidHHdqyIaPl2EkHWgbgqRMdbUd2MsCrZyiqiRmIvbcSJ79CgbBcMlIBLk9sfFPlysRgl(LU)s4m(0O80Bsyv45kzH1OzKAuNabcba6jUfmxKjqy0gzimaueMiWaA1CiWqKtqJpDU1qCLLpHaPl2EkHWgzimuicteiDX2tje2iqiRmIvbcCJ376qKtqJpDU1qCLLpPXZFP7VCJ376njSk8CLSWA045VCD9LwPsCB4PIEPIVSTcrGb0Q5qGcluZPeHmegkacteiDX2tje2iqiRmIvbceoJpnkpDiYjOXNo3AiUYYN0msnQtWDHtcXlb8lXQZF566lTWtNPNJ4klRHBneppGlOPl2Ek9Y11xALkXTHNk6Lk(Y2kebgqRMdbUjHvHNRKfwdYqyOGqyIadOvZHaHnLAqSGlAgdbsxS9ucHnYqy4mimrGb0Q5qGbxfNLigF6CiBukqG0fBpLqyJmegTicteyaTAoe4oySWfHaPl2EkHWgzimA7CeMiq6ITNsiSrGqwzeRceyaTYrIthPwK4Lk(sa9LRRV0nVmCIyLrAwKxjoJ8tK00fBpLqGb0Q5qGluEphoQQXLqgcJ2TryIadOvZHatfJ4BkegcKUy7PecBKHWOnwryIaPl2EkHWgbgqRMdbUd2MsCrZyiqiRmIvbcCJ376oJoNaqNgL3lD)Ll)sytWCrcENfqRMl8VeWVST2zE566l349UEtcRcpxjlSgnE(lx6LRRVeoJpnkpDiYjOXNo3AiUYYN0msnQt8sfF5gV31DgDobGoHZcRM7LyXlDbtV09xgorSYiDoRudpVoHvh0eA6ITNsVCD9LWMG5Ie8olGwnx4FjGFzBnG(Y11xALkXTHNk6Lk(Ywebcba6jUfmxKjqy0gzimA7aeMiWaA1CiW(aXfuIhorSYi(McveiDX2tje2idHrBafHjcmGwnhcmhNvDaQZfF7dHHaPl2EkHWgzimARqeMiWaA1Ciq4Cq6mwyuI39HkHaPl2EkHWgzimARaimrGb0Q5qGB)mj(05wdXPJubabsxS9ucHnYqy0wbHWebsxS9ucHnceYkJyvGa349UMrWf8KqW7ddsA88xUU(YnEVRzeCbpje8(WGeho4NrmTWc4cVuXx225iWaA1CiqRH443EWVeVpmiHmegTDgeMiq6ITNsiSrGqwzeRcey4eXkJ0SiVsCg5NiPPl2Ek9s3FzaTYrIthPwK4La(LyfbgqRMdbQI7Ts0mgYqy0UfryIaPl2EkHWgbczLrSkqGWz8Pr5PxO8EoCuvJlPzKAuN4La(L9bIl0wPsCB4QXIFP7VC5xgqRCK40rQfjEPIV0bVCD9LU5LHteRmsZI8kXzKFIKMUy7P0lxcbgqRMdbcNnl4IMXqgcdS6CeMiWaA1CiqrEzwDU4WzZceiDX2tje2idziqysGWeHrBeMiq6ITNsiSrGqwzeRceiCgFAuE6njSk8CLSWA0msnQt8sa)sh4CeyaTAoeyCqsySWZHH3JmegyfHjcKUy7PecBeiKvgXQabcNXNgLNEtcRcpxjlSgnJuJ6eVeWV0bohbgqRMdb2lgT9ZKqgcdhGWebsxS9ucHnceYkJyvGa349Uoe5e04tNBnexz5tA88x6(lx(LwPsCB4PIEjGFjCgFAuE6nXeeBH6CPt4SWQ5EjqVmHZcRM7LRRVC5xAbZfz6gk8wJohAVuXx6af(Y11x6MxAHNotVq59eJxNWQdAA6ITNsVCPxU0lxxFPvQe3gEQOxQ4lB7aeyaTAoe4MycITqDUqgcdafHjcKUy7PecBeiKvgXQabUX7DDiYjOXNo3AiUYYN045V09xU8lTsL42Wtf9sa)s4m(0O80B)mjEhNbGoHZcRM7La9YeolSAUxUU(YLFPfmxKPBOWBn6CO9sfFPdu4lxxFPBEPfE6m9cL3tmEDcRoOPPl2Ek9YLE5sVCD9LwPsCB4PIEPIVSTcGadOvZHa3(zs8oodaKHWqHimrG0fBpLqyJaHSYiwfiWnEVR7m6CcanE(lD)LB8Ex3z05eaAgPg1jEjGFPlysRgl(LRRV0nVCJ376oJoNaqJNJadOvZHa9LRgtWXY4jxQ0zidHHcGWebsxS9ucHnceYkJyvGa349UEtcRcpxjlSgnE(lD)LB8ExhICcA8PZTgIRS8jnE(lD)Ll)slyUit3qH3A05q7Lk(shOWxUU(s38sl80z6fkVNy86ewDqttxS9u6Ll9Y11xU8lHZjWvJTN05JvZXNoh)2Sk5PeVJZa4LU)sRujUn8urVuXxQaTF566lTsL42Wtf9sfFjwvGxUecmGwnhcmFSAoKHWqbHWebsxS9ucHnceYkJyvGa349U2xDA7NjPfwax4Lk(safbgqRMdbQCy(KJuDCgjMloiHmegodcteiDX2tje2iqiRmIvbceoJpnkpDiYjOXNo3AiUYYN0msnQt8sfFzBN)Y11xALkXTHNk6La(Lb0Q50UWdwQIJpDE4eXgRrdNXNgL3lb6LoW5VCD9LwPsCB4PIEPIV0bohbgqRMdb6cpyPko(05HteBSgKHWOfryIadOvZHazvEUN41Xf5bKqG0fBpLqyJmegTDocteyaTAoeOkPoma4tN7XHvINyuOkqG0fBpLqyJmKHafgctegTryIaPl2EkHWgbczLrSkqGB8Ex3z05eaA88x6(l349UUZOZja0msnQt8sfFPly6La9YDW2uIlAgJ7IfqINtSAsVCD9LWz8Pr5P3KWQWZvYcRrZi1OoXlD)Ll)YoU3ZzeSjyUiUvQ0lv8LUGPxUU(YWjIvgPZzLA451jS6GMqtxS9u6LU)s4m(0O80HiNGgF6CRH4klFsZi1OoXlv8LUGPxUecmGwnhcChSnL4IMXqgcdSIWebsxS9ucHnceYkJyvGa7dex8sGEzFG4cnJCr3lbKEPly6Lk(Y(aXfA1yXV09xUX7D9MewfEUswyn60O8EP7VC5x6MxMgtdNdsNXcJs8Upuj(gNDAgPg1jEP7V0nVmGwnNgohKoJfgL4DFOs664DF5QXE5sVCD9LDCVNZiytWCrCRuPxQ4lDbtVCD9LwPsCB4PIEPIVuHiWaA1Ciq4Cq6mwyuI39HkHmegoaHjcKUy7PecBeiKvgXQabcNXNgLNEhSnL4IMX0WMG5IeVuXxI1xUU(YnEVR7m6CcaTWc4cVeWVeRVCD9LU5LHteRmsNZk1WZRty1bnHMUy7PecmGwnhcme5e04tNBnexz5tidHbGIWebsxS9ucHnceYkJyvGa349Uoe5e04tNBnexz5tA88x6(l349UEtcRcpxjlSgnE(lxxFPvQe3gEQOxQ4lBRqeyaTAoeOWc1CkridHHcryIaPl2EkHWgbczLrSkqGWz8Pr5P3KWQWZvYcRrZi1OobcmGwnhcm4Q4SeX4tNdzJsbYqyOaimrG0fBpLqyJaHSYiwfiWnEVR3KWQWZvYcRrNgL3lxxFPvQe3gEQOxQ4lvicmGwnhcSpqCbL4HteRmIVPqfzimuqimrG0fBpLqyJaHSYiwfiWnEVRzeCbpje8(WGKgp)LRRVCJ37AgbxWtcbVpmiXHd(zetlSaUWlv8LTD(lxxFPvQe3gEQOxQ4lvicmGwnhc0Aio(Th8lX7ddsidHHZGWebgqRMdbUjHvHNRKfwdcKUy7PecBKHWOfryIadOvZHaxO8EoCuvJlHaPl2EkHWgzimA7CeMiWaA1CiqytPgel4IMXqG0fBpLqyJmegTBJWebgqRMdbMkgX3uimeiDX2tje2idHrBSIWebsxS9ucHnceYkJyvGa349UUZOZja0Pr59s3F5YVe2emxKG3zb0Q5c)lb8lBRDMxUU(YnEVR3KWQWZvYcRrJN)YLE566lHZ4tJYthICcA8PZTgIRS8jnJuJ6eVuXxUX7DDNrNtaOt4SWQ5Ejw8sxW0lD)LHteRmsNZk1WZRty1bnHMUy7P0lxxFz4eXkJ0P4GeF68efwJMf3cVeWVS9lD)LB8ExNIds8PZtuyn60O8EP7VeYkJNdnoeNXOZEjGFjG68xUU(sRujUn8urVuXx2IiWaA1CiWDW2uIlAgdzimA7aeMiq6ITNsiSrGqwzeRce4gV31Bsyv45kzH1OtJY7LRRV0kvIBdpv0lv8LodcmGwnhcmhNvDaQZfF7dHHmegTbueMiWaA1CiWTFMeF6CRH40rQaGaPl2EkHWgzimARqeMiWaA1CiWDWyHlcbsxS9ucHnYqy0wbqyIaPl2EkHWgbczLrSkqGl)Y(aXfVelEjCe2lb6L9bIl0mYfDVeq6Ll)s4m(0O80luEphoQQXL0msnQt8sS4LTF5sVeWVmGwnNEHY75WrvnUKgoc7LRRVeoJpnkp9cL3ZHJQACjnJuJ6eVeWVS9lb6LUGPxUU(YnEVRvj1HbaF6CpoSs8eJcvHgp)Ll9s3FjCgFAuE6fkVNdhv14sAgPg1jEjGFzBeyaTAoeiC2SGlAgdzimARGqyIadOvZHaf5Lz15IdNnlqG0fBpLqyJmegTDgeMiq6ITNsiSrGqwzeRceiSjyUibVZcOvZf(xc4x2wdOiWaA1CiWDW2uIlAgdzidbIBLVmaqyIWOncteyaTAoeiCWpJyCrZyiq6ITNsiSrgcdSIWebgqRMdbkigDLbapHlmeiDX2tje2idHHdqyIadOvZHaf5dJ4q)GNqG0fBpLqyJmegakcteyaTAoeOygRPoxCLHrmeiDX2tje2idHHcryIadOvZHafZvq(2hcdbsxS9ucHnYqyOaimrGb0Q5qGhzneJlAg4ciq6ITNsiSrgcdfecteyaTAoeiSPWYLGBS4Cw8Yxgaiq6ITNsiSrgcdNbHjcmGwnhcuKxSY4IMbUacKUy7PecBKHWOfryIadOvZHaVWWzKG7IfqcbsxS9ucHnYqgYqGosmrnhcdS682TOZvqy1zqGkd2vNlbceq2TBjWaqedSe36LVeZg6LLA(WSx2h2lDi0tHJKdFjJCw8IrPxkgv6LbUnQHrPxcBIZfj0F2wAD0lB7wVSfMZrIzu6LomNmTcw3YAT2HV0Mx6WwwR1o8LlJ1fVK(Z2sRJEjwDRx2cZ5iXmk9shMtMwbRBzTw7WxAZlDylR1Ah(YLBV4L0F2wAD0lBJv36LTWCosmJsV0H5KPvW6wwR1o8L28sh2YAT2HVCzSU4L0F2plGSB3sGbGigyjU1lFjMn0ll18HzVSpSx6qys4WxYiNfVyu6LIrLEzGBJAyu6LWM4Crc9NTLwh9sf6wVSfMZrIzu6LomNmTcw3YAT2HV0Mx6WwwR1o8Ll7GfVK(Z(zbKD7wcmaeXalXTE5lXSHEzPMpm7L9H9shkmh(sg5S4fJsVumQ0ldCBudJsVe2eNlsO)ST06Ox22TEzlmNJeZO0lDyozAfSUL1ATdFPnV0HTSwRD4lxgRlEj9NTLwh9sh4wVSfMZrIzu6LomNmTcw3YAT2HV0Mx6WwwR1o8Ll3EXlP)ST06Ox2gRU1lBH5CKygLEPdZjtRG1TSwRD4lT5LoSL1ATdF5YyDXlP)SFwar18Hzu6LkWldOvZ9sFjmH(ZIaZztV8ecCrVeBke2lbegcJya8sab4NrSp7IEzJz5c3cyGDvwd(wdhvGfLkUpSAoil6gWIsfc8NDrV0TXDHlSx2wbA9Ly15TBXxIfVSTcDlh48p7NDrVSfAIZfjCRp7IEjw8s3oLO0lBHb)mI9sWMXEPnVmr9a3BVmGwn3l9LW0F2f9sS4LyPf0lTsL42Wtf9YLDuOFPfmxKPTsL42WtfT0lT5LXzfSYdJEjDPxo9xshCWpJy6p7IEjw8s3oLEzQe5KxaCooZfjEPJv8sCR8LbWldOvZ9sFjm9NDrVelEPXQBbY0kyDti4Wz8Pr59Ys8s8tGNNpmJs6p7NDrVSL0IjiUrPxUP(WOxch1DyVCtUQtOFPBdHuUjE5nhw0em1oU)Lb0Q5eVCopa6p7IEzaTAoHoNrWrDhwMUpel8zx0ldOvZj05mcoQ7WakdWbUlv6SWQ5(Sl6Lb0Q5e6Cgbh1DyaLb4(mPpBaTAoHoNrWrDhgqzawGRQohpNSp7IEj4f5IMXEjlQ0l349oLEPWct8Yn1hg9s4OUd7LBYvDIxgx6L5mclYhZQZ1llXltZr6p7IEzaTAoHoNrWrDhgqzawCrUOzmUWct8zdOvZj05mcoQ7WakdW5JvZ9zdOvZj05mcoQ7WakdW4cIxgP26fQuMWjrtWcbVpNXNopFusSpBaTAoHoNrWrDhgqzaw5W8jhP64msmxCq6ZgqRMtOZzeCu3HbugGDHhSufhF68WjInwZNnGwnNqNZi4OUddOmaRsQdda(05ECyL4jgfQIpBaTAoHoNrWrDhgqzagxq8Yi1wPENGg)cvkdeaOFm2CfKV9HWAT6zCdlQeNCKotxNJ4(JyX2tAAXLWeUVm5S4vEoL0ogSk2EIxNrNOma4UkxHJJ34JawEFy15IZOaAdBPpBaTAoHoNrWrDhgqzaUpqCbL4HteRmIVPqT1QNXnSOsCYr6mDDoI7pIfBpPPfxct8zx0lD7ewgxyIxAn0lt4SWQ5EzCPxcNXNgL3lN(lDBrobTxo9xAn0lbKlF6LXLEzlzwPg(xciEcRoOjE5gGxAn0lt4SWQ5E50FzCVe)AcHrPxIL0cyPEPYg6EP1qa4qg9sCbLEzoJGJ6om9lDBXlD7XaKFztiEz8Y2AhiEjwslGL6LXLEz07e0eVSmb57V0AkXllXlBRBl0F2aA1CcDoJGJ6omGYaCiYjOXNo3AiUYYNAnNrWqyCRuPmT1TBT6zCt4eXkJ05Ssn886ewDqtOPl2Ek5UBiHGoiPjHGoiXNo3AiEFG4I6CXlwj0QbwEyUVm5S4vEoL0HtIMGfcEFoJpDE(OKyRRUHCw8kpNsAiaq)yS5kiF7dHT0NDrV0TtyzCHjEP1qVmHZcRM7LXLEjCgFAuEVC6VeBsyv4FjGmlSMxgx6LaccNOxo9x2seUOxUb4Lwd9YeolSAUxo9xg3lXVMqyu6LyjTawQxQSHUxAneaoKrVexqPxMZi4OUdt)zdOvZj05mcoQ7WakdWBsyv45kzH10AoJGHW4wPszARvyRvpt4eXkJ05Ssn886ewDqtOPl2Ek5UBiHGoiPjHGoiXNo3AiEFG4I6CXlwj0QbwEyUVm5S4vEoL0HtIMGfcEFoJpDE(OKyRRUHCw8kpNsAiaq)yS5kiF7dHT0N9ZgqRMtOXTYxgazGd(zeJlAg7ZgqRMtOXTYxgaaLbybXORma4jCH9zdOvZj04w5ldaGYaSiFyeh6h80NnGwnNqJBLVmaakdWIzSM6CXvggX(Sb0Q5eACR8Lbaqzawmxb5BFiSpBaTAoHg3kFzaaugGpYAigx0mWf(Sb0Q5eACR8Lbaqzag2uy5sWnwColE5ldGpBaTAoHg3kFzaaugGf5fRmUOzGl8zdOvZj04w5ldaGYa8fgoJeCxSasF2p7IEzlPftqCJsVKCKya8sRuPxAn0ldOnSxwIxgogLp2Es)zdOvZjYadVNhqRMJ7lH16fQugCR8LbqRvptI249UggcRoxA8811eTX7DDQe5K3hBpXvdxfuJNVUMOnEVRtLiN8(y7joDSWfPXZ)Sb0Q5eaLbyCbXlJufF2aA1CcGYamUG4LrQTEHkLjenoghj4SWPHXHdl8Tw9mjAJ37Aw40W4WHfEEI249Ugp39LZzKJCxWKUToe5e04tNBnexz5tRRUHCw8kpNsAiaq)yS5kiF7dH5(gV31HiNGgF6CRH4klFsJNV066YjAJ37Aw40W4WHfEEI249UonkV1vRujUn8urkIvfyj3TsL42Wtfb4LXkGciTmCgFAuEAiaq)yS5kiF7dHPzKAuNaiavrRujUn8urlT0NnGwnNaOmaJliEzKARuVtqJFHkLbca0pgBUcY3(qyTw9mB8ExVjHvHNRKfwJonkV1vRujUn8urkQWpBaTAobqzaggEppGwnh3xcR1luPmWK4ZgqRMtaugGHH3ZdOvZX9LWA9cvkJWAT6zcOvosC6i1IekI1pBaTAobqzaggEppGwnh3xcR1luPmqpfosTw9mb0khjoDKArca3(Z(zdOvZj0WKitCqsySWZHH33A1ZaNXNgLNEtcRcpxjlSgnJuJ6ea2bo)ZgqRMtOHjbqzaUxmA7Nj1A1ZaNXNgLNEtcRcpxjlSgnJuJ6ea2bo)ZgqRMtOHjbqzaEtmbXwOoxTw9mB8ExhICcA8PZTgIRS8jnEU7lBLkXTHNkcWWz8Pr5P3etqSfQZLoHZcRMdOeolSAU11LTG5ImDdfERrNdnfDGcxxDJfE6m9cL3tmEDcRoOPPl2EkT0sRRwPsCB4PIuSTd(Sb0Q5eAysaugG3(zs8oodGwREMnEVRdrobn(05wdXvw(Kgp39LTsL42Wtfby4m(0O80B)mjEhNbGoHZcRMdOeolSAU11LTG5ImDdfERrNdnfDGcxxDJfE6m9cL3tmEDcRoOPPl2EkT0sRRwPsCB4PIuSTc8zdOvZj0WKaOma7lxnMGJLXtUuPZAT6zYjtddtVX7DDNrNtaOXZDpNmnmm9gV31DgDobGMrQrDca7cM0QXIxxDtozAyy6nEVR7m6CcanE(NnGwnNqdtcGYaC(y1CTw9mB8ExVjHvHNRKfwJgp39nEVRdrobn(05wdXvw(Kgp39LTG5ImDdfERrNdnfDGcxxDJfE6m9cL3tmEDcRoOPPl2EkT066YW5e4QX2t68XQ54tNJFBwL8uI3Xza4UvQe3gEQifvG2RRwPsCB4PIueRkWsF2aA1CcnmjakdWkhMp5ivhNrI5IdsTw9mB8Ex7RoT9ZK0clGlOiG(zdOvZj0WKaOma7cpyPko(05HteBSMwREg4m(0O80HiNGgF6CRH4klFsZi1OoHITD(6QvQe3gEQiahqRMt7cpyPko(05HteBSgnCgFAuEa5aNVUALkXTHNksrh48pBaTAoHgMeaLbywLN7jEDCrEaPpBaTAoHgMeaLbyvsDyaWNo3JdRepXOqv8z)Sb0Q5eAONchPm7GTPex0mwRqaGEIBbZfzImTBT6zYjtddtVX7DDNrNtaOXZDpNmnmm9gV31DgDobGMrQrDcfZ4cM0QXIbAhSnL4IMX4UybK45eRM0NnGwnNqd9u4ibugGvX9wjAgR1QNXfmPvJfJf5KPHHP349UEtHW4qpfosAgPg1jaSZ1yvHF2aA1Ccn0tHJeqzaEhSnL4IMXAfca0tClyUitKPDRvpth375mc2emxe3kvsrxWKwnwS7Wz8Pr5P3KWQWZvYcRrZi1OoXNnGwnNqd9u4ibugGdrobn(05wdXvw(0NnGwnNqd9u4ibugGfwOMtjQ1QNzJ376qKtqJpDU1qCLLpPXZDFJ376njSk8CLSWA045RRwPsCB4PIuSTc)Sb0Q5eAONchjGYa8MewfEUswynTw9mWz8Pr5Pdrobn(05wdXvw(KMrQrDcUlCsiamwD(6QfE6m9CexzznCRH45bCbnDX2tP1vRujUn8urk2wHF2aA1Ccn0tHJeqzag2uQbXcUOzSpBaTAoHg6PWrcOmahCvCwIy8PZHSrP4ZgqRMtOHEkCKakdW7GXcx0NnGwnNqd9u4ibugGxO8EoCuvJl1A1ZeqRCK40rQfjueqxxDt4eXkJ0SiVsCg5NiPPl2Ek9zdOvZj0qpfosaLb4uXi(McH9zdOvZj0qpfosaLb4DW2uIlAgRviaqpXTG5ImrM2Tw9m5KPHHP349UUZOZja0Pr55(YWMG5Ie8olGwnx4bCBTZSUUX7D9MewfEUswynA88LwxHZ4tJYthICcA8PZTgIRS8jnJuJ6ekMtMggMEJ376oJoNaqNWzHvZHfUGj3dNiwzKoNvQHNxNWQdAcnDX2tP1vytWCrcENfqRMl8aUTgqxxTsL42WtfPyl(zdOvZj0qpfosaLb4(aXfuIhorSYi(Mc1pBaTAoHg6PWrcOmaNJZQoa15IV9HW(Sb0Q5eAONchjGYamCoiDglmkX7(qL(Sb0Q5eAONchjGYa82ptIpDU1qC6iva(Sb0Q5eAONchjGYaS1qC8Bp4xI3hgKAT6z249UMrWf8KqW7ddsA8811nEVRzeCbpje8(WGeho4NrmTWc4ck225F2aA1Ccn0tHJeqzawf3BLOzSwREMWjIvgPzrEL4mYprstxS9uY9aALJeNosTibGX6NnGwnNqd9u4ibugGHZMfCrZyTw9mWz8Pr5PxO8EoCuvJlPzKAuNaW9bIl0wPsCB4QXIDF5aALJeNosTiHIoyD1nHteRmsZI8kXzKFIKMUy7P0sF2aA1Ccn0tHJeqzawKxMvNloC2S4Z(zdOvZj0clZoyBkXfnJ1A1ZKtMggMEJ376oJoNaqJN7EozAyy6nEVR7m6CcanJuJ6ek6cMaAhSnL4IMX4UybK45eRM06kCgFAuE6njSk8CLSWA0msnQt4(YDCVNZiytWCrCRujfDbtRRHteRmsNZk1WZRty1bnHMUy7PK7Wz8Pr5Pdrobn(05wdXvw(KMrQrDcfDbtl9zdOvZj0cdOmadNdsNXcJs8UpuPwREM(aXfa1hiUqZix0bi5cMuSpqCHwnwS7B8ExVjHvHNRKfwJonkp3x2nPX0W5G0zSWOeV7dvIVXzNMrQrDc3DtaTAonCoiDglmkX7(qL01X7(YvJT06Ah375mc2emxe3kvsrxW06QvQe3gEQifv4NnGwnNqlmGYaCiYjOXNo3AiUYYNAT6zGZ4tJYtVd2MsCrZyAytWCrcfX66AozAyy6nEVR7m6CcaTWc4cagRRRUjCIyLr6CwPgEEDcRoOj00fBpL(Sb0Q5eAHbugGfwOMtjQ1QNzJ376qKtqJpDU1qCLLpPXZDFJ376njSk8CLSWA045RRwPsCB4PIuSTc)Sb0Q5eAHbugGdUkolrm(05q2Ou0A1ZaNXNgLNEtcRcpxjlSgnJuJ6eF2aA1CcTWakdW9bIlOepCIyLr8nfQTw9mB8ExVjHvHNRKfwJonkV1vRujUn8urkQWpBaTAoHwyaLbyRH443EWVeVpmi1A1ZSX7DnJGl4jHG3hgK045RRB8ExZi4cEsi49HbjoCWpJyAHfWfuSTZxxTsL42WtfPOc)Sb0Q5eAHbugG3KWQWZvYcR5ZgqRMtOfgqzaEHY75WrvnU0NnGwnNqlmGYamSPudIfCrZyF2aA1CcTWakdWPIr8nfc7ZgqRMtOfgqzaEhSnL4IMXAT6zYjtddtVX7DDNrNtaOtJYZ9LHnbZfj4DwaTAUWd42ANzDDJ376njSk8CLSWA045lTUcNXNgLNoe5e04tNBnexz5tAgPg1jumNmnmm9gV31DgDobGoHZcRMdlCbtUhorSYiDoRudpVoHvh0eA6ITNsRRHteRmsNIds8PZtuynAwCla42UVX7DDkoiXNoprH1OtJYZDiRmEo04qCgJodWaQZxxTsL42WtfPyl(zdOvZj0cdOmaNJZQoa15IV9HWAT6z249UEtcRcpxjlSgDAuERRwPsCB4PIu0z(Sb0Q5eAHbugG3(zs8PZTgIthPcWNnGwnNqlmGYa8oySWf9zdOvZj0cdOmadNnl4IMXAT6zwUpqCbwahHbuFG4cnJCrhG0YWz8Pr5PxO8EoCuvJlPzKAuNalAVeGdOvZPxO8EoCuvJlPHJWwxHZ4tJYtVq59C4OQgxsZi1OobGBdKlyADDJ37AvsDyaWNo3JdRepXOqvOXZxYD4m(0O80luEphoQQXL0msnQta42F2aA1CcTWakdWI8YS6CXHZMfF2aA1CcTWakdW7GTPex0mwRvpdSjyUibVZcOvZfEa3wdOiqrobryGvf6aKHmec]] )


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
