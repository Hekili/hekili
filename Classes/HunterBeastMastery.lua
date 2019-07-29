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


    spec:RegisterPack( "Beast Mastery", 20190728, [[dW0GbbqiQu8iPu1MOs1NOIyukjoLsuRsjs5vkvMLuk3IeWUi1VuQAyKGoMsyzkj9mQinnLiUgvuTnQO4BqbACqbDoPeSoQuY8iHUNOyFqHoOuIAHqPEivk1eHcixukHKpcfGrQejCsLiPvkkntPeQBQejANqrdvkHulvkH4PanvOKRcfq9vLivJLeOoRuISxi)fvdMOdlSyapg0Kf5YiBwQ(mvYOLItlz1Ka51sjnBQ62K0Uv53kgUO64urPLJYZjmDkxhQ2ojY3PcJxkvoVsQ1tIA(kL9RQrlqyHatHrimxvHlAbfIbxfd1lWqNUKvxcc0wNtiW8a2A4IqGxOsiqSPqyVCPmegXwJaZJ1(jsiSqGIbNbjeyJz5c3A)ExL1GdOHJ6ErPI7dRMdYIUTxuQW9iqa8YBl1dbGatHrimxvHlAbfIbxfd1lWqNUKfyicmWTMHHablv3gb2uPeDiaeyIeqey7Fj2uiSxUugcJyRF5sb(ze7Z2(x2ywUWT2V3vzn4aA4OUxuQ4(WQ5GSOB7fLkC)NT9VmlUF9lxfdB7LRQWfTWlvGxUadDlN60p7NT9V0TBIZfjCRpB7FPc8YwoLO0lD7b)mI9sWMXEPnVmr9a3BVmGwn3l9LW0F22)sf4LyGf0lTsL42Wtf9YvusOFPfmxKPTsL42WtfT8lT5LXzfSYdJEjDPxo9xshCWpJy6pB7FPc8YwoLEzQe5KxSphN5IeVuPkEjUv(Yw)YaA1CV0xct)zB)lvGxAS6ALmTcw3ecoCgFACCVSeVe)e455dZOKgb6lHjqyHatupW9gcleMlqyHaPla8ucHnceYkJyvGateaEVRHHWQZLgp)LBBVmra49UovICY7dapXvdxfuJN)YTTxMia8ExNkro59bGN40XcxKgphbgqRMdbcdVNhqRMJ7lHHa9LW4xOsiqCR8LTgzimxfHfcmGwnhcexq8YivbcKUaWtje2idHPtryHaPla8ucHncmGwnhcmenkfhj4Sq5HXHdl8iqiRmIvbcmra49UMfkpmoCyHNNia8ExJN)s3F5kVmNrkXDbt6f6qKtqJpDU1qChLp9YTTx6MxsolELNtjnCn0pgBUcYb8HWEP7VeaV31HiNGgF6CRH4okFsJN)YLF522lx5LjcaV31Sq5HXHdl88ebG376044E522lTG5ImTvQe3gEQOxQ4lx1zE5YV09xAbZfzARujUn8urVeJVCLxU6sE5s7LR8s4m(0440W1q)yS5kihWhctZi1OoXl39YL8sfFPfmxKPTsL42Wtf9YLF5YiWlujeyiAukosWzHYdJdhw4rgcZLGWcbsxa4PecBeyaTAoey(aBLmrPmL4Wrnh3cRMJNiLkiHaHSYiwfiqa8ExdqcRcp3blSgDACCVCB7LwWCrM2kvIBdpv0lv8Lohbs9obn(fQeceUg6hJnxb5a(qyidHPZryHaPla8ucHncmGwnhcegEppGwnh3xcdb6lHXVqLqGWKazimDgewiq6capLqyJaHSYiwfiWaALseNosTiXlv8LRIadOvZHaHH3ZdOvZX9LWqG(sy8lujeOWqgctmicleiDbGNsiSrGqwzeRceyaTsjIthPwK4Ly8LlqGb0Q5qGWW75b0Q54(syiqFjm(fQece6PqjczidbMZi4OcegcleMlqyHadOvZHaf4QQZXZjdbsxa4PecBKHWCvewiWaA1CiW8XQ5qG0faEkHWgzimDkcleiDbGNsiSrGxOsiWqzrtWcbVpNXNopFCqmeyaTAoeyOSOjyHG3NZ4tNNpoigYqyUeewiWaA1CiqhdZNuIQJZiXCXbjeiDbGNsiSrgctNJWcbgqRMdb6cpyPko(05HYeBSgeiDbGNsiSrgctNbHfcmGwnhcuLuh2A(05ECyL4jgfQceiDbGNsiSrgctmicleiDbGNsiSrGb0Q5qG5dSvYeLYuIdh1CClSAoEIuQGeceYkJyvGaDZlzrL4Ks0z66uc3Fela8KMAxjmXlD)LR8sYzXR8CkPvkyva4jEDgDIYwZDvUcLgVXhbS8(WQZfNrb0g2lxgbs9obn(fQeceUg6hJnxb5a(qyidHjgIWcbsxa4PecBeiKvgXQab6MxYIkXjLOZ01PeU)iwa4jn1UsyceyaTAoeyFG4ckXdLjwzehGcvKHWSfqyHaPla8ucHncmNrWqyCRuje4c9ceyaTAoeyiYjOXNo3AiUJYNqGqwzeRceOBEzOmXkJ05Ssn886ewDqtOPla8u6LU)s38ssiOdsAsiOds8PZTgI3hiUOox8IvcTAOGg2lD)LR8sYzXR8CkPdLfnble8(CgF688XbXE522lDZljNfVYZPKgUg6hJnxb5a(qyVCzKHWCHcryHaPla8ucHncmNrWqyCRuje4cTZrGb0Q5qGaKWQWZDWcRbbczLrSkqGHYeRmsNZk1WZRty1bnHMUaWtPx6(lDZljHGoiPjHGoiXNo3AiEFG4I6CXlwj0QHcAyV09xUYljNfVYZPKouw0eSqW7Zz8PZZhhe7LBBV0nVKCw8kpNsA4AOFm2CfKd4dH9YLrgYqGqpfkriSqyUaHfcKUaWtje2iWaA1CiqGGbqjUOzmeiKvgXQabcG376oJoLxRXZFP7VeaV31DgDkVwZi1OoXlvmZlDbtA1ODVC3lbcgaL4IMX4UybK45eRMeceUg6jUfmxKjqyUazimxfHfcKUaWtje2iqiRmIvbc0fmPvJ29sf4La49UgGcHXHEkuI0msnQt8sm(sfQx15iWaA1CiqvCVvIMXqgctNIWcbsxa4PecBeyaTAoeiqWaOex0mgceYkJyvGa74EpNrWMG5I4wPsVuXx6cM0Qr7EP7VeoJpnoonajSk8ChSWA0msnQtGaHRHEIBbZfzceMlqgcZLGWcbgqRMdbgICcA8PZTgI7O8jeiDbGNsiSrgctNJWcbsxa4PecBeiKvgXQabcG376qKtqJpDU1qChLpPXZFP7VeaV31aKWQWZDWcRrJN)YTTxALkXTHNk6Lk(YfohbgqRMdbkSqnNseYqy6miSqG0faEkHWgbczLrSkqGWz8PXXPdrobn(05wdXDu(KMrQrDcUlCsiEjgF5Qk8LBBV0cpDMEoI7OSgU1q88a2QMUaWtPxUT9sRujUn8urVuXxUW5iWaA1Ciqasyv45oyH1GmeMyqewiWaA1CiqytPgel4IMXqG0faEkHWgzimXqewiWaA1CiWGRIZseJpDoKnoeiq6capLqyJmeMTacleyaTAoeiqWyHlcbsxa4PecBKHWCHcryHaPla8ucHnceYkJyvGadOvkrC6i1IeVuXxUKxUT9s38YqzIvgPzrEL4mYprstxa4PecmGwnhcS1Y75WrvnUeYqyUybcleyaTAoeyQyehGcHHaPla8ucHnYqyUyvewiq6capLqyJadOvZHabcgaL4IMXqGqwzeRceiaEVR7m6uETonoUx6(lx5LWMG5Ie8olGwnx4FjgF5cng(YTTxcG37Aasyv45oyH1OXZF5YVCB7LWz8PXXPdrobn(05wdXDu(KMrQrDIxQ4lbW7DDNrNYR1jCwy1CVubEPly6LU)YqzIvgPZzLA451jS6GMqtxa4P0l32EjSjyUibVZcOvZf(xIXxUqVKxUT9sRujUn8urVuXx2ciq4AON4wWCrMaH5cKHWCHtryHadOvZHa7dexqjEOmXkJ4auOIaPla8ucHnYqyUyjiSqGb0Q5qG54SQVUoxCaFimeiDbGNsiSrgcZfohHfcmGwnhceohKoJfgL4DFOsiq6capLqyJmeMlCgewiWaA1Ciqa)mj(05wdXPJuxJaPla8ucHnYqyUadIWcbsxa4PecBeiKvgXQabcG37AgbB1tcbVpmiPXZF522lbW7DnJGT6jHG3hgK4Wb)mIPfwaB9Lk(YfkebgqRMdbAneh)ag8lX7ddsidH5cmeHfcKUaWtje2iqiRmIvbcmuMyLrAwKxjoJ8tK00faEk9s3FzaTsjIthPwK4Ly8LRIadOvZHavX9wjAgdzimx0ciSqG0faEkHWgbczLrSkqGWz8PXXPBT8EoCuvJlPzKAuN4Ly8L9bIl0wPsCB4Qr7EP7VCLxgqRuI40rQfjEPIV0PVCB7LU5LHYeRmsZI8kXzKFIKMUaWtPxUmcmGwnhceoaSGlAgdzimxvHiSqGb0Q5qGI8YS6CXHdalqG0faEkHWgzidbctcewimxGWcbsxa4PecBeiKvgXQabcNXNghNgGewfEUdwynAgPg1jEjgFPtvicmGwnhcmoijmw45WW7rgcZvryHaPla8ucHnceYkJyvGaHZ4tJJtdqcRcp3blSgnJuJ6eVeJV0PkebgqRMdb2lgb4NjHmeMofHfcKUaWtje2iqiRmIvbceaV31HiNGgF6CRH4okFsJN)s3F5kV0kvIBdpv0lX4lHZ4tJJtdqmbXATox6eolSAUxU7LjCwy1CVCB7LR8slyUit3qH3A05q7Lk(sN68xUT9s38sl80z6wlVNy86ewDqttxa4P0lx(Ll)YTTxALkXTHNk6Lk(YfofbgqRMdbcqmbXAToxidH5sqyHaPla8ucHnceYkJyvGabW7DDiYjOXNo3AiUJYN045V09xUYlTsL42Wtf9sm(s4m(0440a(zs8ooBToHZcRM7L7EzcNfwn3l32E5kV0cMlY0nu4TgDo0EPIV0Po)LBBV0nV0cpDMU1Y7jgVoHvh000faEk9YLF5YVCB7LwPsCB4PIEPIVCHZGadOvZHab8ZK4DC2AKHW05iSqG0faEkHWgbczLrSkqGa49UUZOt51A88x6(lbW7DDNrNYR1msnQt8sm(sxWKwnA3l32EPBEjaEVR7m6uETgphbgqRMdb6lxnMGRGWtUuPZqgctNbHfcKUaWtje2iqiRmIvbceaV31aKWQWZDWcRrJN)s3FjaEVRdrobn(05wdXDu(Kgp)LU)YvEPfmxKPBOWBn6CO9sfFPtD(l32EPBEPfE6mDRL3tmEDcRoOPPla8u6Ll)YTTxUYlHZjWvdapPZhRMJpDo(bWQKNs8ooB9lD)LwPsCB4PIEPIV0zw8YTTxALkXTHNk6Lk(YvDMxUmcmGwnhcmFSAoKHWedIWcbsxa4PecBeiKvgXQabcG37AF1ja)mjTWcyRVuXxUeeyaTAoeOJH5tkr1XzKyU4GeYqyIHiSqG0faEkHWgbczLrSkqGWz8PXXPdrobn(05wdXDu(KMrQrDIxQ4lxOWxUT9sRujUn8urVeJVmGwnN2fEWsvC8PZdLj2ynA4m(044E5Ux6uf(YTTxALkXTHNk6Lk(sNQqeyaTAoeOl8GLQ44tNhktSXAqgcZwaHfcmGwnhcKv55EIxhxKhqcbsxa4PecBKHWCHcryHadOvZHavj1HTMpDUhhwjEIrHQabsxa4PecBKHmeOWqyHWCbcleiDbGNsiSrGqwzeRceiaEVR7m6uETgp)LU)sa8Ex3z0P8AnJuJ6eVuXx6cME5UxcemakXfnJXDXciXZjwnPxUT9s4m(0440aKWQWZDWcRrZi1OoXlD)LR8YoU3ZzeSjyUiUvQ0lv8LUGPxUT9YqzIvgPZzLA451jS6GMqtxa4P0lD)LWz8PXXPdrobn(05wdXDu(KMrQrDIxQ4lDbtVCzeyaTAoeiqWaOex0mgYqyUkcleiDbGNsiSrGqwzeRceyFG4IxU7L9bIl0mYfDVCP9sxW0lv8L9bIl0Qr7EP7VeaV31aKWQWZDWcRrNgh3lD)LR8s38Y0yA4Cq6mwyuI39HkXbWzNMrQrDIx6(lDZldOvZPHZbPZyHrjE3hQKUoE3xUASxU8l32Ezh375mc2emxe3kv6Lk(sxW0l32EPvQe3gEQOxQ4lDocmGwnhceohKoJfgL4DFOsidHPtryHaPla8ucHnceYkJyvGaHZ4tJJtdemakXfnJPHnbZfjEPIVC1xUT9sa8Ex3z0P8ATWcyRVeJVC1xUT9s38YqzIvgPZzLA451jS6GMqtxa4PecmGwnhcme5e04tNBne3r5tidH5sqyHaPla8ucHnceYkJyvGabW7DDiYjOXNo3AiUJYN045V09xcG37Aasyv45oyH1OXZF522lTsL42Wtf9sfF5cNJadOvZHafwOMtjczimDocleiDbGNsiSrGqwzeRceiCgFACCAasyv45oyH1OzKAuNabgqRMdbgCvCwIy8PZHSXHazimDgewiq6capLqyJaHSYiwfiqa8ExdqcRcp3blSgDACCVCB7LwPsCB4PIEPIV05iWaA1CiW(aXfuIhktSYioafQidHjgeHfcKUaWtje2iqiRmIvbceaV31mc2QNecEFyqsJN)YTTxcG37AgbB1tcbVpmiXHd(zetlSa26lv8Llu4l32EPvQe3gEQOxQ4lDocmGwnhc0Aio(bm4xI3hgKqgctmeHfcmGwnhceGewfEUdwyniq6capLqyJmeMTacleyaTAoeyRL3ZHJQACjeiDbGNsiSrgcZfkeHfcmGwnhce2uQbXcUOzmeiDbGNsiSrgcZflqyHadOvZHatfJ4auimeiDbGNsiSrgcZfRIWcbsxa4PecBeiKvgXQabcG376oJoLxRtJJ7LU)YvEjSjyUibVZcOvZf(xIXxUqJHVCB7La49UgGewfEUdwynA88xU8l32EjCgFACC6qKtqJpDU1qChLpPzKAuN4Lk(sa8Ex3z0P8ADcNfwn3lvGx6cMEP7VmuMyLr6CwPgEEDcRoOj00faEk9YTTxgktSYiDkoiXNoprH1OzX16lX4lx8s3FjaEVRtXbj(05jkSgDACCV09xczLXZHghIZy0zVeJVCjk8LBBV0kvIBdpv0lv8LTacmGwnhceiyauIlAgdzimx4uewiq6capLqyJaHSYiwfiqa8ExdqcRcp3blSgDACCVCB7LwPsCB4PIEPIVedrGb0Q5qG54SQVUoxCaFimKHWCXsqyHadOvZHab8ZK4tNBneNosDncKUaWtje2idH5cNJWcbgqRMdbcemw4IqG0faEkHWgzimx4miSqG0faEkHWgbczLrSkqGR8Y(aXfVubEjCe2l39Y(aXfAg5IUxU0E5kVeoJpnooDRL3ZHJQACjnJuJ6eVubE5IxU8lX4ldOvZPBT8EoCuvJlPHJWE522lHZ4tJJt3A59C4OQgxsZi1OoXlX4lx8YDV0fm9YTTxcG37AvsDyR5tN7XHvINyuOk045VC5x6(lHZ4tJJt3A59C4OQgxsZi1OoXlX4lxGadOvZHaHdal4IMXqgcZfyqewiWaA1CiqrEzwDU4WbGfiq6capLqyJmeMlWqewiq6capLqyJaHSYiwfiqytWCrcENfqRMl8VeJVCHEjiWaA1CiqGGbqjUOzmKHmeiUv(YwJWcH5cewiWaA1Ciq4GFgX4IMXqG0faEkHWgzimxfHfcmGwnhcuqm6kBnpHlmeiDbGNsiSrgctNIWcbgqRMdbkYhgXH(bpHaPla8ucHnYqyUeewiWaA1CiqXmwtDU4ocJyiq6capLqyJmeMohHfcmGwnhcumxb5a(qyiq6capLqyJmeModcleyaTAoe4rwdX4IMb2kcKUaWtje2idHjgeHfcmGwnhce2ukOsWnwColE5lBncKUaWtje2idHjgIWcbgqRMdbkYlwzCrZaBfbsxa4PecBKHWSfqyHadOvZHaVWWzKG7Ifqcbsxa4PecBKHmKHavIyIAoeMRQWfTGcXGRUQwHkuHlqGoc2vNlbcCP3YTiyUuXedWTE5lXQHEzPMpm7L9H9sNa9uOe5KxYiNfVyu6LIrLEzGBJAyu6LWM4Crc9NTfxh9YfU1lD75uIygLEPtYjtRG1TKwRDYlT5LoPL0ATtE5kR2UL1F2wCD0lx1TEPBpNseZO0lDsozAfSUL0ATtEPnV0jTKwRDYlxzr7ww)zBX1rVCXQU1lD75uIygLEPtYjtRG1TKwRDYlT5LoPL0ATtE5kR2UL1F2p7sVLBrWCPIjgGB9YxIvd9YsnFy2l7d7LobMeo5LmYzXlgLEPyuPxg42OggLEjSjoxKq)zBX1rV05U1lD75uIygLEPtYjtRG1TKwRDYlT5LoPL0ATtE5koTDlR)SF2LEl3IG5sftma36LVeRg6LLA(WSx2h2lDIWCYlzKZIxmk9sXOsVmWTrnmk9sytCUiH(Z2IRJE5c36LU9CkrmJsV0j5KPvW6wsR1o5L28sN0sAT2jVCLvB3Y6pBlUo6Lo1TEPBpNseZO0lDsozAfSUL0ATtEPnV0jTKwRDYlxzr7ww)zBX1rVCXQU1lD75uIygLEPtYjtRG1TKwRDYlT5LoPL0ATtE5kR2UL1F2p7svnFygLEPZ8YaA1CV0xctO)SiWC20lpHaB)lXMcH9YLYqyeB9lxkWpJyF22)YgZYfU1(9UkRbhqdh19Isf3hwnhKfDBVOuH7)ST)LzX9RF5QyyBVCvfUOfEPc8YfyOB5uN(z)ST)LUDtCUiHB9zB)lvGx2YPeLEPBp4NrSxc2m2lT5LjQh4E7Lb0Q5EPVeM(Z2(xQaVedSGEPvQe3gEQOxUIsc9lTG5ImTvQe3gEQOLFPnVmoRGvEy0lPl9YP)s6Gd(zet)zB)lvGx2YP0ltLiN8I954mxK4LkvXlXTYx26xgqRM7L(sy6pB7FPc8sJvxRKPvW6MqWHZ4tJJ7LL4L4NappFygL0F2pB7FzlQ2rqCJsVeG6dJEjCubc7LaKR6e6x2YqiLBIxEZPanbtTJ7FzaTAoXlNZVw)zB)ldOvZj05mcoQaHLP7drRF22)YaA1CcDoJGJkqy7YSpWDPsNfwn3NT9VmGwnNqNZi4Oce2Um77ZK(Sb0Q5e6CgbhvGW2LzVaxvDoEozF22)sWlYfnJ9swuPxcG37u6LclmXlbO(WOxchvGWEja5QoXlJl9YCgPa5Jz156LL4LP5i9NT9VmGwnNqNZi4Oce2Um7fxKlAgJlSWeF2aA1CcDoJGJkqy7YSpFSAUpBaTAoHoNrWrfiSDz2JliEzKABxOszcLfnble8(CgF688XbX(Sb0Q5e6CgbhvGW2LzVJH5tkr1XzKyU4G0NnGwnNqNZi4Oce2Um7DHhSufhF68qzInwZNnGwnNqNZi4Oce2Um7vj1HTMpDUhhwjEIrHQ4ZgqRMtOZzeCubcBxM94cIxgP2g17e04xOszGRH(XyZvqoGpewBvpJByrL4Ks0z66uc3Fela8KMAxjmH7RqolELNtjTsbRcapXRZOtu2AURYvO04n(iGL3hwDU4mkG2Ww(ZgqRMtOZzeCubcBxM99bIlOepuMyLrCakuBR6zCdlQeNuIotxNs4(JybGN0u7kHj(ST)LTCsbHlmXlTg6LjCwy1CVmU0lHZ4tJJ7Lt)LTSiNG2lN(lTg6Ll9YNEzCPx2IMvQH)Ll1ty1bnXlbw)sRHEzcNfwn3lN(lJ7L4xtimk9sma3gd0lD0q3lTgATty0lXfu6L5mcoQaHPFzllEzlp2s)LnH4LXlxODQ4LyaUngOxgx6LrVtqt8YYeKV)sRPeVSeVCHEHq)zdOvZj05mcoQaHTlZ(qKtqJpDU1qChLp1woJGHW4wPszwOx0w1Z4MqzIvgPZzLA451jS6GMqtxa4PK7UHec6GKMec6GeF6CRH49bIlQZfVyLqRgkOH5(kKZIx55ushklAcwi495m(055JdITT5gYzXR8CkPHRH(XyZvqoGpe2YF22)YwoPGWfM4Lwd9YeolSAUxgx6LWz8PXX9YP)sSjHvH)LlDwynVmU0lxkcLPxo9x2IeUOxcS(Lwd9YeolSAUxo9xg3lXVMqyu6LyaUngOx6OHUxAn0ANWOxIlO0lZzeCubct)zdOvZj05mcoQaHTlZEasyv45oyH10woJGHW4wPszwODEBvptOmXkJ05Ssn886ewDqtOPla8uYD3qcbDqstcbDqIpDU1q8(aXf15IxSsOvdf0WCFfYzXR8CkPdLfnble8(CgF688XbX22Cd5S4vEoL0W1q)yS5kihWhcB5p7NnGwnNqJBLVS1zGd(zeJlAg7ZgqRMtOXTYx26Dz2ligDLTMNWf2NnGwnNqJBLVS17YSxKpmId9dE6ZgqRMtOXTYx26Dz2lMXAQZf3rye7ZgqRMtOXTYx26Dz2lMRGCaFiSpBaTAoHg3kFzR3Lz)rwdX4IMb26NnGwnNqJBLVS17YSh2ukOsWnwColE5lB9NnGwnNqJBLVS17YSxKxSY4IMb26NnGwnNqJBLVS17YS)cdNrcUlwaPp7NT9VSfv7iiUrPxskrS1V0kv6Lwd9YaAd7LL4LHsr5dapP)Sb0Q5ezGH3ZdOvZX9LWA7cvkdUv(Yw3w1ZKia8ExddHvNlnE(2wIaW7DDQe5K3haEIRgUkOgpFBlra49UovICY7dapXPJfUinE(NnGwnNyxM94cIxgPk(Sb0Q5e7YShxq8Yi12UqLYeIgLIJeCwO8W4WHf(2QEMebG37AwO8W4WHfEEIaW7DnEU7RKZiL4UGj9cDiYjOXNo3AiUJYN22Cd5S4vEoL0W1q)yS5kihWhcZDa8ExhICcA8PZTgI7O8jnE(YBBRKia8ExZcLhghoSWZteaEVRtJJBBZcMlY0wPsCB4PIuCvNzz3TG5ImTvQe3gEQimUYQlzPTcCgFACCA4AOFm2CfKd4dHPzKAuNy3su0cMlY0wPsCB4PIwE5pBaTAoXUm7XfeVmsTnQ3jOXVqLYaxd9JXMRGCaFiS2QEga8ExdqcRcp3blSgDACCBBwWCrM2kvIBdpvKIo)ZgqRMtSlZEy498aA1CCFjS2UqLYatIpBaTAoXUm7HH3ZdOvZX9LWA7cvkJWAR6zcOvkrC6i1IekU6NnGwnNyxM9WW75b0Q54(syTDHkLb6PqjQTQNjGwPeXPJulsGXfF2pBaTAoHgMezIdscJfEom8(2QEg4m(0440aKWQWZDWcRrZi1OobgDQc)Sb0Q5eAysSlZ(EXia)mP2QEg4m(0440aKWQWZDWcRrZi1OobgDQc)Sb0Q5eAysSlZEaIjiwR15QTQNbaV31HiNGgF6CRH4okFsJN7(kwPsCB4PIWiCgFACCAaIjiwR15sNWzHvZTlHZcRMBBBflyUit3qH3A05qtrN68Tn3yHNot3A59eJxNWQdAA6capLwE5TnRujUn8urkUWPF2aA1Ccnmj2LzpGFMeVJZw3w1ZaG376qKtqJpDU1qChLpPXZDFfRujUn8uryeoJpnoonGFMeVJZwRt4SWQ52LWzHvZTTTIfmxKPBOWBn6COPOtD(2MBSWtNPBT8EIXRty1bnnDbGNslV82MvQe3gEQifx4mF2aA1Ccnmj2LzVVC1ycUccp5sLoRTQNjNmnmmnaEVR7m6uETgp39CY0WW0a49UUZOt51AgPg1jWOlysRgTBBZn5KPHHPbW7DDNrNYR145F2aA1Ccnmj2LzF(y1CTv9ma49UgGewfEUdwynA8C3bW7DDiYjOXNo3AiUJYN045UVIfmxKPBOWBn6COPOtD(2MBSWtNPBT8EIXRty1bnnDbGNslVTTcCobUAa4jD(y1C8PZXpawL8uI3XzRD3kvIBdpvKIoZITnRujUn8urkUQZS8NnGwnNqdtIDz27yy(KsuDCgjMloi1w1ZaG37AF1ja)mjTWcyRkUKpBaTAoHgMe7YS3fEWsvC8PZdLj2ynTv9mWz8PXXPdrobn(05wdXDu(KMrQrDcfxOWTnRujUn8urymGwnN2fEWsvC8PZdLj2ynA4m(04425ufUTzLkXTHNksrNQWpBaTAoHgMe7YSNv55EIxhxKhq6ZgqRMtOHjXUm7vj1HTMpDUhhwjEIrHQ4Z(zdOvZj0qpfkrzacgaL4IMXAdUg6jUfmxKjYSOTQNjNmnmmnaEVR7m6uETgp39CY0WW0a49UUZOt51AgPg1jumJlysRgTBhqWaOex0mg3flGepNy1K(Sb0Q5eAONcLODz2RI7Ts0mwBvpJlysRgTtbYjtddtdG37Aakegh6PqjsZi1OobgvOEvN)zdOvZj0qpfkr7YShiyauIlAgRn4AON4wWCrMiZI2QEMoU3ZzeSjyUiUvQKIUGjTA0o3HZ4tJJtdqcRcp3blSgnJuJ6eF2aA1Ccn0tHs0Um7drobn(05wdXDu(0NnGwnNqd9uOeTlZEHfQ5uIAR6zaW7DDiYjOXNo3AiUJYN045UdG37Aasyv45oyH1OXZ32SsL42WtfP4cN)zdOvZj0qpfkr7YShGewfEUdwynTv9mWz8PXXPdrobn(05wdXDu(KMrQrDcUlCsiW4QkCBZcpDMEoI7OSgU1q88a2QMUaWtPTnRujUn8urkUW5F2aA1Ccn0tHs0Um7HnLAqSGlAg7ZgqRMtOHEkuI2LzFWvXzjIXNohYghIpBaTAoHg6PqjAxM9abJfUOpBaTAoHg6PqjAxM9TwEphoQQXLAR6zcOvkrC6i1IekUKTn3ektSYinlYReNr(jsA6capL(Sb0Q5eAONcLODz2NkgXbOqyF2aA1Ccn0tHs0Um7bcgaL4IMXAdUg6jUfmxKjYSOTQNjNmnmmnaEVR7m6uETonoo3xb2emxKG3zb0Q5cpgxOXWTna8ExdqcRcp3blSgnE(YBBWz8PXXPdrobn(05wdXDu(KMrQrDcfZjtddtdG376oJoLxRt4SWQ5uaxWK7HYeRmsNZk1WZRty1bnHMUaWtPTnytWCrcENfqRMl8yCHEjBBwPsCB4PIuSf(Sb0Q5eAONcLODz23hiUGs8qzIvgXbOq9ZgqRMtOHEkuI2LzFooR6RRZfhWhc7ZgqRMtOHEkuI2LzpCoiDglmkX7(qL(Sb0Q5eAONcLODz2d4NjXNo3AioDK66pBaTAoHg6PqjAxM9wdXXpGb)s8(WGuBvpdaEVRzeSvpje8(WGKgpFBdaV31mc2QNecEFyqIdh8ZiMwybSvfxOWpBaTAoHg6PqjAxM9Q4ERenJ1w1ZektSYinlYReNr(jsA6capLCpGwPeXPJulsGXv)Sb0Q5eAONcLODz2dhawWfnJ1w1ZaNXNghNU1Y75WrvnUKMrQrDcm2hiUqBLkXTHRgTZ9vcOvkrC6i1Iek60Tn3ektSYinlYReNr(jsA6capLw(ZgqRMtOHEkuI2LzViVmRoxC4aWIp7NnGwnNqlSmabdGsCrZyTv9m5KPHHPbW7DDNrNYR145UNtMggMgaV31DgDkVwZi1OoHIUGPDabdGsCrZyCxSas8CIvtABdoJpnoonajSk8ChSWA0msnQt4(kDCVNZiytWCrCRujfDbtBBHYeRmsNZk1WZRty1bnHMUaWtj3HZ4tJJthICcA8PZTgI7O8jnJuJ6ek6cMw(ZgqRMtOf2Um7HZbPZyHrjE3hQuBvptFG4ID9bIl0mYfDlnxWKI9bIl0Qr7ChaV31aKWQWZDWcRrNghN7R4M0yA4Cq6mwyuI39HkXbWzNMrQrDc3DtaTAonCoiDglmkX7(qL01X7(YvJT82wh375mc2emxe3kvsrxW02MvQe3gEQifD(NnGwnNqlSDz2hICcA8PZTgI7O8P2QEg4m(0440abdGsCrZyAytWCrcfxDBlNmnmmnaEVR7m6uETwybSvmU62MBcLjwzKoNvQHNxNWQdAcnDbGNsF2aA1CcTW2LzVWc1CkrTv9ma49Uoe5e04tNBne3r5tA8C3bW7DnajSk8ChSWA045BBwPsCB4PIuCHZ)Sb0Q5eAHTlZ(GRIZseJpDoKnoeTv9mWz8PXXPbiHvHN7GfwJMrQrDIpBaTAoHwy7YSVpqCbL4HYeRmIdqHABvpdaEVRbiHvHN7GfwJonoUTnRujUn8urk68pBaTAoHwy7YS3Aio(bm4xI3hgKAR6zaW7DnJGT6jHG3hgK045BBa49UMrWw9KqW7ddsC4GFgX0clGTQ4cfUTzLkXTHNksrN)zdOvZj0cBxM9aKWQWZDWcR5ZgqRMtOf2Um7BT8EoCuvJl9zdOvZj0cBxM9WMsniwWfnJ9zdOvZj0cBxM9PIrCake2NnGwnNqlSDz2demakXfnJ1w1ZKtMggMgaV31DgDkVwNghN7RaBcMlsW7SaA1CHhJl0y42gaEVRbiHvHN7GfwJgpF5Tn4m(0440HiNGgF6CRH4okFsZi1OoHI5KPHHPbW7DDNrNYR1jCwy1CkGlyY9qzIvgPZzLA451jS6GMqtxa4P02wOmXkJ0P4GeF68efwJMfxRyCH7a49UofhK4tNNOWA0PXX5oKvgphACioJrNHXLOWTnRujUn8urk2cF2aA1CcTW2LzFooR6RRZfhWhcRTQNbaV31aKWQWZDWcRrNgh32MvQe3gEQifXWpBaTAoHwy7YShWptIpDU1qC6i11F2aA1CcTW2LzpqWyHl6ZgqRMtOf2Um7Hdal4IMXAR6zwPpqCHcahHTRpqCHMrUOBPTcCgFACC6wlVNdhv14sAgPg1juGflJXaA1C6wlVNdhv14sA4iSTn4m(0440TwEphoQQXL0msnQtGXf7CbtBBa49UwLuh2A(05ECyL4jgfQcnE(YUdNXNghNU1Y75WrvnUKMrQrDcmU4ZgqRMtOf2Um7f5Lz15Idhaw8zdOvZj0cBxM9abdGsCrZyTv9mWMG5Ie8olGwnx4X4c9sqGICcIWCvN7uKHmeca]] )


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
