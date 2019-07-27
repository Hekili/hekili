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


    spec:RegisterPack( "Beast Mastery", 20190722.0001, [[dWKY(aqiOu9iLOSjPeFIa1OiGofbYQOIs5vQIMLus3ckk7Iu)svyyeGJPewMsKNjkX0GIQRbLY2Ksv9nLOY4KsrNJkQSoQOyEurUhvY(GICqPuyHqjpKkQAIsPuCrQOu5JsPunsPukDsPuLwPOyMIsIBsfLWovLAOurPQLsfL0tvvtfkCvQOe9vPufJvus6SIsQ9c5VenysoSWIvQhdmzrUmYMLQptLA0sXPLSALOQxlk1SPQBtODRYVvmCr1XLsjlhLNJQPt56q12jO(ovy8sPY5vLSEcY8vs7h0Ofimq)uye69scyHZjGLBPL0cyXI2FXc03ELtOFEaYoCtO)fIe6JffCdQCweCJyVq)84LFIecd0Np4maH(nMLZDMhpCxwd(wdgXh8se3hwnhGfD7bVebpq)nE5T27H2OFkmc9EjbSW5eWYT0sOFGBndd9)LOZJ(nvkrhAJ(jIdq)Lbvyrb3GkNfb3i2lOQTf)mIbZSmOQXSCUZ84H7YAW3AWi(GxI4(WQ5aSOBp4Li4bmZYGQm4(xq1slAfQwsalCoOcZGQLeGZG5ydMbMzzqLZ3eNBI7mWmldQWmOQnsjkbvo)GFgXGQFZyqLnqvI6bU3GQay1CqLV4MgMzzqfMbvol5euzLijTrMkcQeOWCnuzbZnzARejPnYurccQSbQIZkqLhgbv0LGQPdv0bg8ZiMgMzzqfMbvTrkbvPINtE(JCCMBIdvcxbuHBLVSxqvaSAoOYxCtJ((IBCegOFI6bU3qyGEVaHb6txS9ucHf6dyLrSkq)eTX7Dni4wDU145q16kuLOnEVRtfpN8(y7jPy4UaA8COADfQs0gV31PINtEFS9KKow4M045OFaSAo0heEVmawnN0xCd99f3KxisOpUv(YEHm07LqyG(bWQ5qFCojlJe5OpDX2tjewid9olimqF6ITNsiSq)ay1COF(aYMmEjeLKGrmh3cRMtMiHlaH(awzeRc0h7q1gV31BIBv4LoyH1OXZrFQ3jGjVqKqFWlGFm2CfqU9b3qg6nMJWa9Pl2EkHWc9VqKq)G3iCCexYcHgMemSWJ(bWQ5q)G3iCCexYcHgMemSWJ(awzeRc0FJ376GNtatoDP1qshLpPzKyuhhQWeuTaBq16kuLOnEVRzHqdtcgw4LjAJ376044GQ1vOYkrsAJmveu5euTKaqg6n2qyG(0fBpLqyH(bWQ5qFq49Yay1CsFXn03xCtEHiH(GehzO3Tpcd0NUy7Pecl0hWkJyvG(bWkHjjDKyrCOYjOAj0pawnh6dcVxgaRMt6lUH((IBYlej0NBid9E5qyG(0fBpLqyH(awzeRc0pawjmjPJelIdvycQwG(bWQ5qFq49Yay1CsFXn03xCtEHiH(apfctidzOFoJaJ4omegO3lqyG(bWQ5qFoUO4CYCYqF6ITNsiSqg69simq)ay1COF(y1COpDX2tjewid9olimq)ay1COVJH5tct1jzeFU4ae6txS9ucHfYqVXCegOFaSAo03nEWsvCYPldHi2ynOpDX2tjewid9gBimq)ay1COVijoSxYPl94Gkjtmke5OpDX2tjewid9U9ryG(0fBpLqyH(bWQ5q)8bKnz8sikjbJyoUfwnNmrcxac9bSYiwfOp2HkwujjjmDMUoHX9hXITN0u7kUXrFQ3jGjVqKqFWlGFm2CfqU9b3qg69YHWa9Pl2EkHWc9bSYiwfOp2HkwujjjmDMUoHX9hXITN0u7kUXr)ay1COFFa4CkjdHiwzKCtHiYqVBtegOpDX2tjewOFoJab3KwjsO)cn2q)ay1CO)M4wfEPdwynOpGvgXQa9dHiwzKoNvIHxwh3QdyCnDX2tjOQfOc7qfX50binX50bi50Lwdj7daNxNBzXkUwmw(HbvTavceQO2cVYZPKoeI3eSGl7ZzYPlZhhedQwxHkSdvuBHx55usNpGSjJxcrjjyeZXTWQ5Kjs4cqq16kuHDOcmJpnoon4fWpgBUci3(GB6eolSAoOsqid925qyG(0fBpLqyH(5mceCtALiH(l0lq)ay1COFWZjGjNU0AiPJYNqFaRmIvb6JDOkeIyLr6CwjgEzDCRoGX10fBpLGQwGkSdveNthG0eNthGKtxAnKSpaCEDULfR4AXy5hgu1cujqOIAl8kpNs6qiEtWcUSpNjNUmFCqmOADfQWourTfELNtjD(aYMmEjeLKGrmh3cRMtMiHlabvRRqf2HkWm(0440Gxa)yS5kGC7dUPt4SWQ5GkbHmKH(apfctimqVxGWa9Pl2EkHWc9dGvZH(7GTPKK3mg6dyLrSkq)nEVR7m6e6LgphQAbQ249UUZOtOxAgjg1XHkNCbvUbjTy0oO6juTd2MssEZys3SaqYCIvtc9bVaEsAbZnzC07fid9EjegOpDX2tjewOpGvgXQa9DdsAXODqfMbvB8ExVPGBsGNcHjnJeJ64qfMGkbOxcBOFaSAo0xe3BfVzmKHENfegOpDX2tjewOFaSAo0FhSnLK8MXqFaRmIvb63X9EjJanbZnjTsKGkNGk3GKwmAhu1cubMXNghNEtCRcV0blSgnJeJ64Op4fWtslyUjJJEVazO3yocd0pawnh6h8CcyYPlTgs6O8j0NUy7PeclKHEJnegOpDX2tjewOpGvgXQa9349Uo45eWKtxAnK0r5tA8COQfOAJ376nXTk8shSWA045q16kuzLijTrMkcQCcQwGn0pawnh6ZTqmNseYqVBFegOpDX2tjewOpGvgXQa9bZ4tJJth8CcyYPlTgs6O8jnJeJ64s34eNdvycQwsaq16kuzHNotphjDuwJ0AizEaYwtxS9ucQwxHkRejPnYurqLtq1cSH(bWQ5q)nXTk8shSWAqg69YHWa9dGvZH(GMsmiwi5nJH(0fBpLqyHm072eHb6haRMd9dPiolrm50La24GJ(0fBpLqyHm0BNdHb6haRMd93bJfUj0NUy7PeclKHEVqaimqF6ITNsiSqFaRmIvb6haReMK0rIfXHkNGkmhQwxHkSdvHqeRmsZI8kjzKFIKMUy7Pe6haRMd9ZU8EjyefJlHm07flqyG(bWQ5q)uXi5McUH(0fBpLqyHm07flHWa9Pl2EkHWc9dGvZH(7GTPKK3mg6dyLrSkq)nEVR7m6e6LonooOQfOsGqfOjyUjUSZcGvZfEOctq1cDBcvRRq1gV31BIBv4LoyH1OXZHkbbvRRqfygFACC6GNtatoDP1qshLpPzKyuhhQCcQ249UUZOtOx6eolSAoOcZGk3Geu1cufcrSYiDoRedVSoUvhW4A6ITNsq16kubAcMBIl7Say1CHhQWeuTqJ5q16kuzLijTrMkcQCcQCo0h8c4jPfm3KXrVxGm07fzbHb6haRMd97daNtjzieXkJKBkerF6ITNsiSqg69cmhHb6haRMd9ZXzv)vDULBFWn0NUy7PeclKHEVaBimq)ay1COpyoaDglmkj7(qKqF6ITNsiSqg69I2hHb6haRMd93(zsYPlTgsshj(c9Pl2EkHWczO3lwoegOpDX2tjewOpGvgXQa9349UMrGS9eNl7ddqA8COADfQ249UMrGS9eNl7ddqsWGFgX0Clazdvobvlea6haRMd9TgsIF7b)sY(WaeYqVx0MimqF6ITNsiSqFaRmIvb6hcrSYinlYRKKr(jsA6ITNsqvlqvaSsysshjwehQWeuTe6haRMd9fX9wXBgdzO3lCoegOpDX2tjewOpGvgXQa9bZ4tJJtND59sWikgxsZiXOoouHjOQpaCU2krsAJumAhu1cujqOkawjmjPJelIdvobvzbQwxHkSdvHqeRmsZI8kjzKFIKMUy7Peuji0pawnh6dMnlK8MXqg69scaHb6haRMd955Lz15wcMnlqF6ITNsiSqgYqFqIJWa9Ebcd0NUy7Pecl0hWkJyvG(Gz8PXXP3e3QWlDWcRrZiXOoouHjOklca9dGvZH(XbiUXcVeeEpYqVxcHb6txS9ucHf6dyLrSkqFWm(0440BIBv4LoyH1OzKyuhhQWeuLfbG(bWQ5q)EXOTFMeYqVZccd0NUy7Pecl0hWkJyvG(B8Exh8CcyYPlTgs6O8jnEou1cujqOYkrsAJmveuHjOcmJpnoo9MyCILDDU1jCwy1Cq1tOkHZcRMdQwxHkbcvwWCtMUHcV1OZbgu5euLfSbvRRqf2Hkl80z6SlVNyY64wDattxS9ucQeeujiOADfQSsKK2itfbvobvlYc6haRMd93eJtSSRZnYqVXCegOpDX2tjewOpGvgXQa9349Uo45eWKtxAnK0r5tA8COQfOsGqLvIK0gzQiOctqfygFACC6TFMKSJZEPt4SWQ5GQNqvcNfwnhuTUcvceQSG5MmDdfERrNdmOYjOklydQwxHkSdvw4PZ0zxEpXK1XT6aMMUy7PeujiOsqq16kuzLijTrMkcQCcQw0(OFaSAo0F7Njj74Sxid9gBimqF6ITNsiSqFaRmIvb6VX7DDNrNqV045qvlq1gV31DgDc9sZiXOoouHjOYniPfJ2bvRRqf2HQnEVR7m6e6Lgph9dGvZH((YDJXLlpEYTiDgYqVBFegOpDX2tjewOpGvgXQa9349UEtCRcV0blSgnEou1cuTX7DDWZjGjNU0AiPJYN045qvlqLaHklyUjt3qH3A05adQCcQYc2GQ1vOc7qLfE6mD2L3tmzDCRoGPPl2EkbvccQwxHkRejPnYurqLtq1syd9dGvZH(5JvZHm07LdHb6txS9ucHf6dyLrSkq)nEVR9vN2(zsAUfGSHkNGkmh9dGvZH(ogMpjmvNKr85Idqid9UnryG(0fBpLqyH(awzeRc0hmJpnooDWZjGjNU0AiPJYN0msmQJdvobvleauTUcvwWCtM2krsAJmveuHjOkawnN2nEWsvCYPldHi2ynAWm(044GQNqvweauTUcvwWCtM2krsAJmveu5euLfbG(bWQ5qF34blvXjNUmeIyJ1Gm0BNdHb6haRMd9zvEUNK1j55bGqF6ITNsiSqg69cbGWa9dGvZH(IK4WEjNU0JdQKmXOqKJ(0fBpLqyHmKH(CdHb69cegOpDX2tjewOpGvgXQa9349UUZOtOxA8COQfOAJ376oJoHEPzKyuhhQCcQCdsq1tOAhSnLK8MXKUzbGK5eRMeuTUcvGz8PXXP3e3QWlDWcRrZiXOoou1cujqOQJ79sgbAcMBsALibvobvUbjOADfQcHiwzKoNvIHxwh3QdyCnDX2tjOQfOcmJpnooDWZjGjNU0AiPJYN0msmQJdvobvUbjOsqOFaSAo0FhSnLK8MXqg69simqF6ITNsiSqFaRmIvb63haohQEcv9bGZ1mYnDqLZgu5gKGkNGQ(aW5AXODqvlq1gV31BIBv4LoyH1OtJJdQAbQeiuHDOknMgmhGoJfgLKDFisYno70msmQJdvTavyhQcGvZPbZbOZyHrjz3hIKUoz3xUBmOsqq16ku1X9EjJanbZnjTsKGkNGk3GeuTUcvwjssBKPIGkNGkSH(bWQ5qFWCa6mwyus29HiHm07SGWa9Pl2EkHWc9bSYiwfOpygFACC6DW2usYBgtdAcMBIdvobvlbvRRq1gV31DgDc9sZTaKnuHjOAjOADfQWoufcrSYiDoRedVSoUvhW4A6ITNsOFaSAo0p45eWKtxAnK0r5tid9gZryG(0fBpLqyH(awzeRc0FJ376GNtatoDP1qshLpPXZHQwGQnEVR3e3QWlDWcRrJNdvRRqLvIK0gzQiOYjOAb2q)ay1COp3cXCkrid9gBimqF6ITNsiSqFaRmIvb6dMXNghNEtCRcV0blSgnJeJ64OFaSAo0pKI4SeXKtxcyJdoYqVBFegOpDX2tjewOpGvgXQa9349UEtCRcV0blSgDACCq16kuzLijTrMkcQCcQWg6haRMd97daNtjzieXkJKBkerg69YHWa9Pl2EkHWc9bSYiwfO)gV31mcKTN4CzFyasJNdvRRq1gV31mcKTN4CzFyascg8ZiMMBbiBOYjOAHaGQ1vOYkrsAJmveu5euHn0pawnh6BnKe)2d(LK9HbiKHE3Mimq)ay1CO)M4wfEPdwynOpDX2tjewid925qyG(bWQ5q)SlVxcgrX4sOpDX2tjewid9EHaqyG(bWQ5qFqtjgelK8MXqF6ITNsiSqg69Ifimq)ay1COFQyKCtb3qF6ITNsiSqg69ILqyG(0fBpLqyH(awzeRc0FJ376oJoHEPtJJdQAbQeiubAcMBIl7Say1CHhQWeuTq3Mq16kuTX7D9M4wfEPdwynA8COsqq16kubMXNghNo45eWKtxAnK0r5tAgjg1XHkNGQnEVR7m6e6LoHZcRMdQWmOYnibvTavHqeRmsNZkXWlRJB1bmUMUy7PeuTUcvHqeRmsNIdqYPltuynAwCzdvycQwavTavB8ExNIdqYPltuyn6044GQwGkaRmzoWKaCgJodQWeuH5caQwxHkRejPnYurqLtqLZH(bWQ5q)DW2usYBgdzO3lYccd0NUy7Pecl0hWkJyvG(B8ExVjUvHx6GfwJonooOADfQSsKK2itfbvobvTj6haRMd9ZXzv)vDULBFWnKHEVaZryG(bWQ5q)TFMKC6sRHK0rIVqF6ITNsiSqg69cSHWa9dGvZH(7GXc3e6txS9ucHfYqVx0(imqF6ITNsiSqFaRmIvb6lqOQpaCouHzqfy4gu9eQ6daNRzKB6GkNnOsGqfygFACC6SlVxcgrX4sAgjg1XHkmdQwavccQWeufaRMtND59sWikgxsdgUbvRRqfygFACC6SlVxcgrX4sAgjg1XHkmbvlGQNqLBqcQwxHQnEVRfjXH9soDPhhujzIrHixJNdvccQAbQaZ4tJJtND59sWikgxsZiXOoouHjOAb6haRMd9bZMfsEZyid9EXYHWa9dGvZH(88YS6ClbZMfOpDX2tjewid9ErBIWa9Pl2EkHWc9bSYiwfOpOjyUjUSZcGvZfEOctq1cnMJ(bWQ5q)DW2usYBgdzid9XTYx2legO3lqyG(bWQ5qFWGFgXK8MXqF6ITNsiSqg69simq)ay1COpNy0v2lzcNBOpDX2tjewid9olimq)ay1COppFyKe4h8e6txS9ucHfYqVXCegOFaSAo0NpJ1uNBPJWig6txS9ucHfYqVXgcd0pawnh6ZNRaYTp4g6txS9ucHfYqVBFegOFaSAo0)iRHysEZaYg9Pl2EkHWczO3lhcd0pawnh6dAQLV4sJfxBHx(YEH(0fBpLqyHm072eHb6haRMd955fRmjVzazJ(0fBpLqyHm0BNdHb6haRMd9VWWzex6Mfac9Pl2EkHWczidzOVWeJxZHEVKaw4Ccy5wAj03rWU6CZr)2tB4S(U9(UT7mqfuHrdbvLy(WmOQpmOsWapfctcgQyuBHxmkbv8rKGQa3gXWOeubAIZnX1WmzL6iOAHZavo)CctmJsqLGZjtNv1zTwRfmuzduj4SwR1cgQe4sTtqAyMSsDeuTKZavo)CctmJsqLGZjtNv1zTwRfmuzduj4SwR1cgQe4I2jinmtwPocQwSKZavo)CctmJsqLGZjtNv1zTwRfmuzduj4SwR1cgQe4sTtqAygyM2tB4S(U9(UT7mqfuHrdbvLy(WmOQpmOsWGexWqfJAl8IrjOIpIeuf42iggLGkqtCUjUgMjRuhbvyZzGkNFoHjMrjOsW5KPZQ6SwR1cgQSbQeCwR1AbdvcmlTtqAygyM2tB4S(U9(UT7mqfuHrdbvLy(WmOQpmOsWCtWqfJAl8IrjOIpIeuf42iggLGkqtCUjUgMjRuhbvlCgOY5NtyIzucQeCoz6SQoR1ATGHkBGkbN1ATwWqLaxQDcsdZKvQJGQS4mqLZpNWeZOeuj4CY0zvDwR1Abdv2avcoR1ATGHkbUODcsdZKvQJGQfl5mqLZpNWeZOeuj4CY0zvDwR1Abdv2avcoR1ATGHkbUu7eKgMbMP9kMpmJsqv7dvbWQ5GkFXnUgMb955ea9EjSLf0pNn9YtO)YGkSOGBqLZIGBe7fu12IFgXGzwgu1ywo3zE8WDzn4BnyeFWlrCFy1Caw0Th8se8aMzzqvgC)lOAPfTcvljGfohuHzq1scWzWCSbZaZSmOY5BIZnXDgyMLbvygu1gPeLGkNFWpJyq1VzmOYgOkr9a3BqvaSAoOYxCtdZSmOcZGkNLCcQSsKK2itfbvcuyUgQSG5MmTvIK0gzQibbv2avXzfOYdJGk6sq10Hk6ad(zetdZSmOcZGQ2iLGQuXZjp)rooZnXHkHRaQWTYx2lOkawnhu5lUPHzGzwgu5SRDea3OeuTP(WiOcmI7WGQn5UoUgQAdaGYnouDZHznbtSJ7HQay1CCOAo)lnmZYGQay1CCDoJaJ4omxDFWZgMzzqvaSAoUoNrGrCh2txpcC3I0zHvZbZSmOkawnhxNZiWiUd7PRh9zsWmbWQ546CgbgXDypD9GJlkoNmNmyMLbv)lY5nJbvSOsq1gV3PeuXTW4q1M6dJGkWiUddQ2K764qvCjOkNryw(ywDUHQIdvP5inmZYGQay1CCDoJaJ4oSNUEWViN3mMKBHXHzcGvZX15mcmI7WE66r(y1CWmbWQ546CgbgXDypD9WXW8jHP6KmIpxCacMjawnhxNZiWiUd7PRhUXdwQItoDzieXgRbMjawnhxNZiWiUd7PRhIK4WEjNU0JdQKmXOqKdZeaRMJRZzeye3H901dCojlJeBL6DcyYlejxGxa)yS5kGC7dU1A1DHDwujjjmDMUoHX9hXITN0u7kUXHzcGvZX15mcmI7WE66rFa4CkjdHiwzKCtHyRv3f2zrLKKW0z66eg3Fel2EstTR4ghMzzqvBKwECUXHkRHGQeolSAoOkUeubMXNghhunDOclIBv4HQ2dlSgOkUeu12gcrq10HkN1Wnbv7xqL1qqvcNfwnhunDOkoOc)AcUrjOQT78TnqLJg6GkRHEjygbv4Ckbv5mcmI7W0WmbWQ546CgbgXDypD9ytCRcV0blSMwZzei4M0krY1cn2AT6UcHiwzKoNvIHxwh3QdyCnDX2tPwWoX50binX50bi50Lwdj7daNxNBzXkUwmw(H1IaP2cVYZPKoeI3eSGl7ZzYPlZhheBDf7uBHx55usNpGSjJxcrjjyeZXTWQ5Kjs4cqRRyhmJpnoon4fWpgBUci3(GB6eolSAobbZSmOQnslpo34qL1qqvcNfwnhufxcQaZ4tJJdQMou1g8Ccyq10HkRHGQ2t5tqvCjOYzpRedpu1EpUvhW4q1(fuzneuLWzHvZbvthQIdQWVMGBucQA7oFBdu5OHoOYAOxcMrqfoNsqvoJaJ4omnu1gCOQngR9avnbhQcOAHolCOQT78TnqvCjOk6DcyCOQmo57qL1uCOQ4q1c9cUgMjawnhxNZiWiUd7PRhbpNaMC6sRHKokFQ1CgbcUjTsKCTqVO1Q7c7HqeRmsNZkXWlRJB1bmUMUy7PulyN4C6aKM4C6aKC6sRHK9bGZRZTSyfxlgl)WArGuBHx55ushcXBcwWL95m50L5JdITUIDQTWR8CkPZhq2KXlHOKemI54wy1CYejCbO1vSdMXNghNg8c4hJnxbKBFWnDcNfwnNGGzGzcGvZX14w5l7LlWGFgXK8MXGzcGvZX14w5l71txp4eJUYEjt4CdMjawnhxJBLVSxpD9GNpmsc8dEcMjawnhxJBLVSxpD9GpJ1uNBPJWigmtaSAoUg3kFzVE66bFUci3(GBWmbWQ54ACR8L96PRhhznetYBgq2WmbWQ54ACR8L96PRhGMA5lU0yX1w4LVSxWmbWQ54ACR8L96PRh88IvMK3mGSHzcGvZX14w5l71txpUWWzex6MfacMbMzzqLZU2raCJsqfjmXEbvwjsqL1qqvaSHbvfhQcHJYhBpPHzcGvZXDbcVxgaRMt6lU16fIKlCR8L9Q1Q7krB8ExdcUvNBnE(6AI249Uov8CY7JTNKIH7cOXZxxt0gV31PINtEFS9KKow4M045WmbWQ54pD9aNtYYiromtaSAo(txpW5KSmsSvQ3jGjVqKCbEb8JXMRaYTp4wRv3f2349UEtCRcV0blSgnEomtaSAo(txpW5KSmsS1lejxbVr44iUKfcnmjyyHV1Q7AJ376GNtatoDP1qshLpPzKyuhhtlW26AI249UMfcnmjyyHxMOnEVRtJJBD1krsAJmvKtljayMay1C8NUEacVxgaRMt6lU16fIKlqIdZeaRMJ)01dq49Yay1CsFXTwVqKCXTwRURayLWKKosSiUtlbZeaRMJ)01dq49Yay1CsFXTwVqKCb8uim1A1DfaReMK0rIfXX0cygyMay1CCniXDfhG4gl8sq49TwDxGz8PXXP3e3QWlDWcRrZiXOooMYIaGzcGvZX1Ge)PRh9IrB)mPwRUlWm(0440BIBv4LoyH1OzKyuhhtzraWmbWQ54AqI)01JnX4el76C3A1DTX7DDWZjGjNU0AiPJYN045TiqRejPnYurycmJpnoo9MyCILDDU1jCwy1Cpt4SWQ5wxfOfm3KPBOWBn6CG5uwW26k2TWtNPZU8EIjRJB1bmnDX2tjbjO1vRejPnYuroTilWmbWQ54AqI)01JTFMKSJZE1A1DTX7DDWZjGjNU0AiPJYN045TiqRejPnYurycmJpnoo92pts2XzV0jCwy1Cpt4SWQ5wxfOfm3KPBOWBn6CG5uwW26k2TWtNPZU8EIjRJB1bmnDX2tjbjO1vRejPnYuroTO9HzcGvZX1Ge)PRh(YDJXLlpEYTiDwRv3vozAqy6nEVR7m6e6LgpVLCY0GW0B8Ex3z0j0lnJeJ64yYniPfJ2TUI9CY0GW0B8Ex3z0j0lnEomtaSAoUgK4pD9iFSAUwRURnEVR3e3QWlDWcRrJN3YgV31bpNaMC6sRHKokFsJN3IaTG5MmDdfERrNdmNYc2wxXUfE6mD2L3tmzDCRoGPPl2EkjO1vRejPnYuroTe2GzcGvZX1Ge)PRhogMpjmvNKr85IdqTwDxB8Ex7RoT9ZK0Claz7eMdZeaRMJRbj(txpCJhSufNC6YqiInwtRv3fygFACC6GNtatoDP1qshLpPzKyuh3PfcyD1cMBY0wjssBKPIWuaSAoTB8GLQ4KtxgcrSXA0Gz8PXX9mlcyD1cMBY0wjssBKPICklcaMjawnhxds8NUEWQ8CpjRtYZdabZeaRMJRbj(txpejXH9soDPhhujzIrHihMbMjawnhxd8uim5AhSnLK8MXAf8c4jPfm3KXDTO1Q7kNmnim9gV31DgDc9sJN3sozAqy6nEVR7m6e6LMrIrDCNC5gK0Ir7EUd2MssEZys3SaqYCIvtcMjawnhxd8uim901drCVv8MXAT6UCdsAXODywozAqy6nEVR3uWnjWtHWKMrIrDCmja9sydMjawnhxd8uim901JDW2usYBgRvWlGNKwWCtg31IwRURoU3lzeOjyUjPvIKtUbjTy0UwaZ4tJJtVjUvHx6GfwJMrIrDCyMay1CCnWtHW0txpcEobm50LwdjDu(emtaSAoUg4Pqy6PRhCleZPe1A1DTX7DDWZjGjNU0AiPJYN045TSX7D9M4wfEPdwynA881vRejPnYuroTaBWmbWQ54AGNcHPNUESjUvHx6GfwtRv3fygFACC6GNtatoDP1qshLpPzKyuhx6gN4CmTKawxTWtNPNJKokRrAnKmpazRPl2EkTUALijTrMkYPfydMjawnhxd8uim901dqtjgelK8MXGzcGvZX1apfctpD9iKI4SeXKtxcyJdomtaSAoUg4Pqy6PRh7GXc3emtaSAoUg4Pqy6PRhzxEVemIIXLAT6UcGvcts6iXI4oH5RRypeIyLrAwKxjjJ8tK00fBpLGzcGvZX1apfctpD9ivmsUPGBWmbWQ54AGNcHPNUESd2MssEZyTcEb8K0cMBY4Uw0A1DLtMgeMEJ376oJoHEPtJJRfbcAcMBIl7Say1CHhtl0T566gV31BIBv4LoyH1OXZf06kygFACC6GNtatoDP1qshLpPzKyuh3PCY0GW0B8Ex3z0j0lDcNfwnhM5gKAjeIyLr6CwjgEzDCRoGX10fBpLwxbnbZnXLDwaSAUWJPfAmFD1krsAJmvKtohmtaSAoUg4Pqy6PRh9bGZPKmeIyLrYnfIWmbWQ54AGNcHPNUEKJZQ(R6Cl3(GBWmbWQ54AGNcHPNUEaMdqNXcJsYUpejyMay1CCnWtHW0txp2(zsYPlTgsshj(cMjawnhxd8uim901dRHK43EWVKSpma1A1DTX7DnJaz7jox2hgG045RRB8ExZiq2EIZL9HbijyWpJyAUfGSDAHaGzcGvZX1apfctpD9qe3BfVzSwRURqiIvgPzrELKmYprstxS9uQLayLWKKosSioMwcMjawnhxd8uim901dWSzHK3mwRv3fygFACC6SlVxcgrX4sAgjg1XXuFa4CTvIK0gPy0UweyaSsysshjwe3PSSUI9qiIvgPzrELKmYprstxS9usqWmbWQ54AGNcHPNUEWZlZQZTemBwaZaZeaRMJR5MRDW2usYBgR1Q7kNmnim9gV31DgDc9sJN3sozAqy6nEVR7m6e6LMrIrDCNCdsp3bBtjjVzmPBwaizoXQjTUcMXNghNEtCRcV0blSgnJeJ64TiWoU3lzeOjyUjPvIKtUbP11qiIvgPZzLy4L1XT6agxtxS9uQfWm(0440bpNaMC6sRHKokFsZiXOoUtUbjbbZeaRMJR52txpaZbOZyHrjz3hIuRv3vFa48N9bGZ1mYnDoBUbjN6daNRfJ21YgV31BIBv4LoyH1OtJJRfbI90yAWCa6mwyus29Hij34StZiXOoElypawnNgmhGoJfgLKDFis66KDF5UXe06Ah37Lmc0em3K0krYj3G06QvIK0gzQiNWgmtaSAoUMBpD9i45eWKtxAnK0r5tTwDxGz8PXXP3bBtjjVzmnOjyUjUtlTUMtMgeMEJ376oJoHEP5waYgtlTUI9qiIvgPZzLy4L1XT6agxtxS9ucMjawnhxZTNUEWTqmNsuRv31gV31bpNaMC6sRHKokFsJN3YgV31BIBv4LoyH1OXZxxTsKK2itf50cSbZeaRMJR52txpcPiolrm50La24G3A1DbMXNghNEtCRcV0blSgnJeJ64WmbWQ54AU901J(aW5usgcrSYi5McXwRURnEVR3e3QWlDWcRrNgh36QvIK0gzQiNWgmtaSAoUMBpD9WAij(Th8lj7ddqTwDxB8ExZiq2EIZL9HbinE(66gV31mcKTN4CzFyascg8ZiMMBbiBNwiG1vRejPnYuroHnyMay1CCn3E66XM4wfEPdwynWmbWQ54AU901JSlVxcgrX4sWmbWQ54AU901dqtjgelK8MXGzcGvZX1C7PRhPIrYnfCdMjawnhxZTNUESd2MssEZyTwDx5KPbHP349UUZOtOx6044ArGGMG5M4Yolawnx4X0cDBUUUX7D9M4wfEPdwynA8CbTUcMXNghNo45eWKtxAnK0r5tAgjg1XDkNmnim9gV31DgDc9sNWzHvZHzUbPwcHiwzKoNvIHxwh3QdyCnDX2tP11qiIvgPtXbi50LjkSgnlUSX0Iw249UofhGKtxMOWA0PXX1cGvMmhysaoJrNHjmxaRRwjssBKPICY5GzcGvZX1C7PRh54SQ)Qo3YTp4wRv31gV31BIBv4LoyH1OtJJBD1krsAJmvKtTjmtaSAoUMBpD9y7NjjNU0AijDK4lyMay1CCn3E66XoySWnbZeaRMJR52txpaZMfsEZyTwDxcSpaCoMbgU9SpaCUMrUPZztGGz8PXXPZU8EjyefJlPzKyuhhZwiimfaRMtND59sWikgxsdgUTUcMXNghNo7Y7LGrumUKMrIrDCmT4PBqADDJ37ArsCyVKtx6XbvsMyuiY145cQfWm(0440zxEVemIIXL0msmQJJPfWmbWQ54AU901dEEzwDULGzZcyMay1CCn3E66XoyBkj5nJ1A1DbAcMBIl7Say1CHhtl0yoYqgcb]] )


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
