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


    spec:RegisterPack( "Beast Mastery", 20190925, [[dWK(bbqiQGEKsO2KOWNOcmkPuoLusRcGqVcqMLuQUfuO2fP(fGAyur5yayzauptuKPbq6AqPSnQOY3Gsvnorr5CqPY6KsW8iHUhvQ9bfCqPe1cjbpuuunracCrPes(iuizKqHuojarwPO0mLsOUjabTtOOHkLqQLkLq8uGMkuYvHcP6Rae1yHsvoRuISxi)fvdMOdlSyL6XGMSixgzZs1NPsgTuCAjRgkeVwjy2u1TjPDRYVvmCr1XPIQwokpNW0PCDOA7ur(ojA8kHCELO1tfA(kP9RQraGWcbMcJqycyNba25mSdWaQgGmdWodByFeOTmNqG5bCHWfHaVqLqGkqHWEjGWqyeBjcmpw6NiHWcbkgCgKqGnMLlAbGb2vzn4BnCubwuQ4(WQ5GSOBalkviWiWnE5naPdTrGPWieMa2zaGDod7amGQbiZaa7Wg2HadCRzyiqWsnZrGnvkrhAJatKaIax8lvGcH9saHHWi2YxIrd)mI9zx8lBmlx0cadSRYAW3A4OcSOuX9HvZbzr3awuQqG)Sl(LGuUrQBI9saJT2FjGDgay3N9ZU4xM5nX5IeTWNDXVeJFzlNsu6Lz(GFgXEjyZyV0MxMOEG7TxgqRM7L(sy6p7IFjg)sm6c6LwPsCB4PIEzBoj0V0cMlY0wPsCB4PIA9L28Y4Scw5HrVKU0lN(lPdo4Nrm9NDXVeJFzlNsVmvICYlaohN5IeV0PkEjUv(Yw(YaA1CV0xct)zx8lX4xAS6wGmn2t3ecoCgFAuEVSeVe)e455dZOKgb6lHjqyHatupW9gcleMaGWcbsxS9ucPaceYkJyvGat0gV31Wqy15sJN)Y11xMOnEVRtLiN8(y7jUA4QGA88xUU(YeTX7DDQe5K3hBpXPJfUinEocmGwnhcegEppGwnh3xcdb6lHXVqLqG4w5lBjYqycyewiWaA1CiqCbXlJufiq6ITNsifqgcZmHWcbsxS9ucPacmGwnhcmenofhj4SWXHXHdl8iqiRmIvbcmrB8ExZchhghoSWZt0gV3145VmJx22lZzKtCxWKgaDiYjOXNo3AiUYYNE566lD4ljNhVYZPKgUe6hJnxb5BFiSxMXl349Uoe5e04tNBnexz5tA88x26lZ4LT9slyUit3qH3A05q7Lk(YmHTxUU(sh(ssiOdsA4Cj6euI7Ro1hgK0QbgzyVS1xUU(Y2EzI249UMfoomoCyHNNOnEVRtJY7LRRV0kvIBdpv0lv8La25EzRVmJxALkXTHNk6Ly4LT9sadOVeq8LT9s4m(0O80WLq)yS5kiF7dHPzKAuN4La9sa9Lk(slyUitBLkXTHNk6LT(YwrGxOsiWq04uCKGZchhghoSWJmeMakcleiDX2tjKciWaA1Ciq4sOFm2CfKV9HWqGqwzeRce4gV31Bsyv45kzH1OtJY7LRRV0kvIBdpv0lv8Lydbs9obn(fQeceUe6hJnxb5BFimKHWeBiSqG0fBpLqkGadOvZHaHH3ZdOvZX9LWqG(sy8lujeimjqgctNdHfcKUy7PesbeiKvgXQabgqRCI40rQfjEPIVeWiWaA1Ciqy498aA1CCFjmeOVeg)cvcbkmKHWe7JWcbsxS9ucPaceYkJyvGadOvorC6i1IeVedVeaeyaTAoeim8EEaTAoUVegc0xcJFHkHaHEkCIqgYqG5mcoQ7WqyHWeaewiWaA1CiqbUQ6C8CYqG0fBpLqkGmeMagHfcmGwnhcmFSAoeiDX2tjKcidHzMqyHaPl2EkHuabEHkHadhfnble8(CgF688rjXqGb0Q5qGHJIMGfcEFoJpDE(OKyidHjGIWcbgqRMdbQCy(KtuDCgjMloiHaPl2EkHuazimXgcleyaTAoeOl8GLQ44tNhosSXAqG0fBpLqkGmeMohcleyaTAoeOkPoSL8PZ94WkXtmkufiq6ITNsifqgctSpcleiDX2tjKciWaA1Ciq4sOFm2CfKV9HWqGqwzeRceOdFjlQeNCIotxNt4(JyX2tAArLWeVmJx22ljNhVYZPK2PGvX2t86m6eLTK7QCfonEJpcy59HvNloJcOnSx2kcK6DcA8lujeiCj0pgBUcY3(qyidHzMHWcbsxS9ucPaceYkJyvGaD4lzrL4Kt0z66Cc3Fel2EstlQeMabgqRMdb2hiUGs8WrIvgX3uOImeMyhcleiDX2tjKciWCgbdHXTsLqGaObabgqRMdbgICcA8PZTgIRS8jeiKvgXQab6WxgosSYiDoRudpVoHvh0eA6ITNsVmJx6WxscbDqstcbDqIpDU1q8(aXf15IxSsOvdmYWEzgVSTxsopELNtjD4OOjyHG3NZ4tNNpkj2lxxFPdFj584vEoL0WLq)yS5kiF7dH9YwrgctaCgcleiDX2tjKciWCgbdHXTsLqGaOXgcmGwnhcCtcRcpxjlSgeiKvgXQabgosSYiDoRudpVoHvh0eA6ITNsVmJx6WxscbDqstcbDqIpDU1q8(aXf15IxSsOvdmYWEzgVSTxsopELNtjD4OOjyHG3NZ4tNNpkj2lxxFPdFj584vEoL0WLq)yS5kiF7dH9YwrgYqGqpforiSqycacleiDX2tjKciWaA1CiWDW2uIlAgdbczLrSkqGB8Ex3z054snE(lZ4LB8Ex3z054snJuJ6eVur3V0fmPvJf9sGE5oyBkXfnJXDXciXZjwnjeiCj0tClyUitGWeaKHWeWiSqG0fBpLqkGaHSYiwfiqxWKwnw0lX4xUX7D9McHXHEkCI0msnQt8sm8sNPbm2qGb0Q5qGQ4ERenJHmeMzcHfcKUy7PesbeyaTAoe4oyBkXfnJHaHSYiwfiWoU3ZzeSjyUiUvQ0lv8LUGjTASOxMXlHZ4tJYtVjHvHNRKfwJMrQrDceiCj0tClyUitGWeaKHWeqryHadOvZHadrobn(05wdXvw(ecKUy7PesbKHWeBiSqG0fBpLqkGaHSYiwfiWnEVRdrobn(05wdXvw(Kgp)Lz8YnEVR3KWQWZvYcRrJN)Y11xALkXTHNk6Lk(saWgcmGwnhcuyHAoLiKHW05qyHaPl2EkHuabczLrSkqGWz8Pr5Pdrobn(05wdXvw(KMrQrDcUlCsiEjgEjGD2lxxFPfE6m9CexzznCRH45bCbnDX2tPxUU(sRujUn8urVuXxca2qGb0Q5qGBsyv45kzH1GmeMyFewiWaA1CiqytPgel4IMXqG0fBpLqkGmeMzgcleyaTAoeyWvXzjIXNohYgLceiDX2tjKcidHj2HWcbgqRMdbUdglCriq6ITNsifqgctaCgcleiDX2tjKciqiRmIvbcmGw5eXPJuls8sfFjG(Y11x6WxgosSYinlYReNr(jsA6ITNsiWaA1CiWfkVNdhv14sidHjaaGWcbgqRMdbMkgX3uimeiDX2tjKcidHjaagHfcKUy7PesbeyaTAoe4oyBkXfnJHaHSYiwfiWnEVR7m6CCPonkVxMXlB7LWMG5Ie8olGwnx4FjgEja6m7LRRVCJ376njSk8CLSWA045VS1xUU(s4m(0O80HiNGgF6CRH4klFsZi1OoXlv8LB8Ex3z054sDcNfwn3lX4x6cMEzgVmCKyLr6CwPgEEDcRoOj00fBpLE566lHnbZfj4DwaTAUW)sm8sa0a6lxxFPvQe3gEQOxQ4lXoeiCj0tClyUitGWeaKHWeGmHWcbgqRMdb2hiUGs8WrIvgX3uOIaPl2EkHuazimbaqryHadOvZHaZXzvFzDU4BFimeiDX2tjKcidHjaydHfcmGwnhceohKoJfgL4DFOsiq6ITNsifqgctaCoewiWaA1CiWTFMeF6CRH40rQlrG0fBpLqkGmeMaG9ryHaPl2EkHuabczLrSkqGB8ExZi4cEsi49HbjnE(lxxF5gV31mcUGNecEFyqIdh8ZiMwybCHxQ4lbWziWaA1CiqRH443EWVeVpmiHmeMaKziSqG0fBpLqkGaHSYiwfiWWrIvgPzrEL4mYprstxS9u6Lz8YaALteNosTiXlXWlbmcmGwnhcuf3BLOzmKHWeaSdHfcKUy7PesbeiKvgXQabcNXNgLNEHY75WrvnUKMrQrDIxIHx2hiUqBLkXTHRgl6Lz8Y2EzaTYjIthPwK4Lk(Ym9Y11x6WxgosSYinlYReNr(jsA6ITNsVSveyaTAoeiC2SGlAgdzimbSZqyHadOvZHaf5Lz15IdNnlqG0fBpLqkGmKHaHjbcleMaGWcbsxS9ucPaceYkJyvGaHZ4tJYtVjHvHNRKfwJMrQrDIxIHxMjNHadOvZHaJdscJfEom8EKHWeWiSqG0fBpLqkGaHSYiwfiq4m(0O80Bsyv45kzH1OzKAuN4Ly4LzYziWaA1CiWEXOTFMeYqyMjewiq6ITNsifqGqwzeRce4gV31HiNGgF6CRH4klFsJN)YmEzBV0kvIBdpv0lXWlHZ4tJYtVjMGyluNlDcNfwn3lb6LjCwy1CVCD9LT9slyUit3qH3A05q7Lk(YmHTxUU(sh(sl80z6fkVNy86ewDqttxS9u6LT(YwF566lTsL42Wtf9sfFjazcbgqRMdbUjMGyluNlKHWeqryHaPl2EkHuabczLrSkqGB8ExhICcA8PZTgIRS8jnE(lZ4LT9sRujUn8urVedVeoJpnkp92ptI3Xzl1jCwy1CVeOxMWzHvZ9Y11x22lTG5ImDdfERrNdTxQ4lZe2E566lD4lTWtNPxO8EIXRty1bnnDX2tPx26lB9LRRV0kvIBdpv0lv8La4CiWaA1CiWTFMeVJZwImeMydHfcKUy7PesbeiKvgXQabUX7DDNrNJl145VmJxUX7DDNrNJl1msnQt8sm8sxWKwnw0lxxFPdF5gV31DgDoUuJNJadOvZHa9LRgtWXi4jxQ0zidHPZHWcbsxS9ucPaceYkJyvGa349UEtcRcpxjlSgnE(lZ4LB8ExhICcA8PZTgIRS8jnE(lZ4LT9slyUit3qH3A05q7Lk(YmHTxUU(sh(sl80z6fkVNy86ewDqttxS9u6LT(Y11x22lB7LW5e4QX2t68XQ54tNJFBwL8uI3XzlF566lHZjWvJTN043MvjpL4DC2Yx26lZ4LwPsCB4PIEPIV05a4LRRV0kvIBdpv0lv8La25EzRiWaA1CiW8XQ5qgctSpcleiDX2tjKciqiRmIvbcCJ37AF1PTFMKwybCHxQ4lbueyaTAoeOYH5tor1XzKyU4GeYqyMziSqG0fBpLqkGaHSYiwfiq4m(0O80HiNGgF6CRH4klFsZi1OoXlv8La4SxUU(sRujUn8urVedVmGwnN2fEWsvC8PZdhj2ynA4m(0O8EjqVmto7LRRV0kvIBdpv0lv8LzYziWaA1Ciqx4blvXXNopCKyJ1GmeMyhcleyaTAoeiRYZ9eVoUipGecKUy7PesbKHWeaNHWcbgqRMdbQsQdBjF6CpoSs8eJcvbcKUy7PesbKHmeOWqyHWeaewiq6ITNsifqGqwzeRce4gV31DgDoUuJN)YmE5gV31DgDoUuZi1OoXlv8LUGPxc0l3bBtjUOzmUlwajEoXQj9Y11xcNXNgLNEtcRcpxjlSgnJuJ6eVmJx22l74EpNrWMG5I4wPsVuXx6cME566ldhjwzKoNvQHNxNWQdAcnDX2tPxMXlHZ4tJYthICcA8PZTgIRS8jnJuJ6eVuXx6cMEzRiWaA1CiWDW2uIlAgdzimbmcleiDX2tjKciqiRmIvbcSpqCXlb6L9bIl0mYfDVeq8LUGPxQ4l7dexOvJf9YmE5gV31Bsyv45kzH1OtJY7Lz8Y2EPdFzAmnCoiDglmkX7(qL4BC2PzKAuN4Lz8sh(YaA1CA4Cq6mwyuI39HkPRJ39LRg7LT(Y11x2X9EoJGnbZfXTsLEPIV0fm9Y11xALkXTHNk6Lk(sSHadOvZHaHZbPZyHrjE3hQeYqyMjewiq6ITNsifqGqwzeRceiCgFAuE6DW2uIlAgtdBcMls8sfFjGF566l349UUZOZXLAHfWfEjgEjGF566lD4ldhjwzKoNvQHNxNWQdAcnDX2tjeyaTAoeyiYjOXNo3AiUYYNqgctafHfcKUy7PesbeiKvgXQabUX7DDiYjOXNo3AiUYYN045VmJxUX7D9MewfEUswynA88xUU(sRujUn8urVuXxca2qGb0Q5qGcluZPeHmeMydHfcKUy7PesbeiKvgXQabcNXNgLNEtcRcpxjlSgnJuJ6eiWaA1CiWGRIZseJpDoKnkfidHPZHWcbsxS9ucPaceYkJyvGa349UEtcRcpxjlSgDAuEVCD9LwPsCB4PIEPIVeBiWaA1CiW(aXfuIhosSYi(McvKHWe7JWcbsxS9ucPaceYkJyvGa349UMrWf8KqW7ddsA88xUU(YnEVRzeCbpje8(WGeho4NrmTWc4cVuXxcGZE566lTsL42Wtf9sfFj2qGb0Q5qGwdXXV9GFjEFyqczimZmewiWaA1CiWnjSk8CLSWAqG0fBpLqkGmeMyhcleyaTAoe4cL3ZHJQACjeiDX2tjKcidHjaodHfcmGwnhce2uQbXcUOzmeiDX2tjKcidHjaaGWcbgqRMdbMkgX3uimeiDX2tjKcidHjaagHfcKUy7PesbeiKvgXQabUX7DDNrNJl1Pr59YmEzBVe2emxKG3zb0Q5c)lXWlbqNzVCD9LB8ExVjHvHNRKfwJgp)LT(Y11xcNXNgLNoe5e04tNBnexz5tAgPg1jEPIVCJ376oJohxQt4SWQ5Ejg)sxW0lZ4LHJeRmsNZk1WZRty1bnHMUy7P0lxxFz4iXkJ0P4GeF68efwJMf3cVedVeGxMXl349UofhK4tNNOWA0Pr59YmEjKvgphACioJrN9sm8sa1zVCD9LwPsCB4PIEPIVe7qGb0Q5qG7GTPex0mgYqycqMqyHaPl2EkHuabczLrSkqGB8ExVjHvHNRKfwJonkVxUU(sRujUn8urVuXxMziWaA1CiWCCw1xwNl(2hcdzimbaqryHadOvZHa3(zs8PZTgIthPUebsxS9ucPaYqyca2qyHadOvZHa3bJfUieiDX2tjKcidHjaohcleiDX2tjKciqiRmIvbcSTx2hiU4Ly8lHJWEjqVSpqCHMrUO7LaIVSTxcNXNgLNEHY75WrvnUKMrQrDIxIXVeGx26lXWldOvZPxO8EoCuvJlPHJWE566lHZ4tJYtVq59C4OQgxsZi1OoXlXWlb4La9sxW0lxxF5gV31QK6WwYNo3JdRepXOqvOXZFzRVmJxcNXNgLNEHY75WrvnUKMrQrDIxIHxcacmGwnhceoBwWfnJHmeMaG9ryHadOvZHaf5Lz15IdNnlqG0fBpLqkGmeMaKziSqG0fBpLqkGaHSYiwfiqytWCrcENfqRMl8VedVeanGIadOvZHa3bBtjUOzmKHmeiUv(YwIWcHjaiSqGb0Q5qGWb)mIXfnJHaPl2EkHuazimbmcleyaTAoeOGy0v2sEcxyiq6ITNsifqgcZmHWcbgqRMdbkYhgXH(bpHaPl2EkHuazimbuewiWaA1CiqXmwtDU4kdJyiq6ITNsifqgctSHWcbgqRMdbkMRG8TpegcKUy7PesbKHW05qyHadOvZHapYAigx0mWfqG0fBpLqkGmeMyFewiWaA1CiqytHrkb3yX584LVSLiq6ITNsifqgcZmdHfcmGwnhcuKxSY4IMbUacKUy7PesbKHWe7qyHadOvZHaVWWzKG7IfqcbsxS9ucPaYqgYqGormrnhcta7maWoNHDa2ziqLb7QZLabci3YTiyciHjgvl8YxIvd9YsnFy2l7d7Loa6PWjYbVKropEXO0lfJk9Ya3g1WO0lHnX5Ie6pBlUo6La0cVmZNZjIzu6LoiNmn2t3sAT2bV0Mx6GwsR1o4LTb4f1Q(Z2IRJEjGBHxM5Z5eXmk9shKtMg7PBjTw7GxAZlDqlP1Ah8Y2ayrTQ)ST46OxcaGBHxM5Z5eXmk9shKtMg7PBjTw7GxAZlDqlP1Ah8Y2a8IAv)z)SaYTClcMasyIr1cV8Ly1qVSuZhM9Y(WEPdGjHdEjJCE8IrPxkgv6LbUnQHrPxcBIZfj0F2wCD0lXwl8YmFoNiMrPx6GCY0ypDlP1Ah8sBEPdAjTw7Gx2wMwuR6p7NfqULBrWeqctmQw4LVeRg6LLA(WSx2h2lDGWCWlzKZJxmk9sXOsVmWTrnmk9sytCUiH(Z2IRJEjaTWlZ85CIygLEPdYjtJ90TKwRDWlT5LoOL0ATdEzBaErTQ)ST46OxMPw4Lz(CormJsV0b5KPXE6wsR1o4L28sh0sAT2bVSnawuR6pBlUo6Laa4w4Lz(CormJsV0b5KPXE6wsR1o4L28sh0sAT2bVSnaVOw1F2plGKA(Wmk9sN7Lb0Q5EPVeMq)zrG5SPxEcbU4xQafc7LacdHrSLVeJg(ze7ZU4x2ywUOfagyxL1GV1WrfyrPI7dRMdYIUbSOuHa)zx8lbPCJu3e7LagBT)sa7maWUp7NDXVmZBIZfjAHp7IFjg)YwoLO0lZ8b)mI9sWMXEPnVmr9a3BVmGwn3l9LW0F2f)sm(Ly0f0lTsL42Wtf9Y2CsOFPfmxKPTsL42Wtf16lT5LXzfSYdJEjDPxo9xshCWpJy6p7IFjg)YwoLEzQe5KxaCooZfjEPtv8sCR8LT8Lb0Q5EPVeM(ZU4xIXV0y1TazASNUjeC4m(0O8EzjEj(jWZZhMrj9N9ZU4x2IAree3O0l3uFy0lHJ6oSxUjx1j0VSLHqk3eV8MdJBcMAh3)YaA1CIxoNFP(ZU4xgqRMtOZzeCu3H5U7dXcF2f)YaA1CcDoJGJ6omGCdCG7sLolSAUp7IFzaTAoHoNrWrDhgqUbUpt6ZgqRMtOZzeCu3HbKBGf4QQZXZj7ZU4xcErUOzSxYIk9YnEVtPxkSWeVCt9HrVeoQ7WE5MCvN4LXLEzoJW48XS6C9Ys8Y0CK(ZU4xgqRMtOZzeCu3HbKBGfxKlAgJlSWeF2aA1CcDoJGJ6omGCdC(y1CF2aA1CcDoJGJ6omGCdmUG4LrQTFHk5oCu0eSqW7Zz8PZZhLe7ZgqRMtOZzeCu3HbKBGvomFYjQooJeZfhK(Sb0Q5e6Cgbh1Dya5gyx4blvXXNopCKyJ18zdOvZj05mcoQ7WaYnWQK6WwYNo3JdRepXOqv8zdOvZj05mcoQ7WaYnW4cIxgP2o17e04xOsUHlH(XyZvq(2hcR9Q72HSOsCYj6mDDoH7pIfBpPPfvctKrBKZJx55us7uWQy7jEDgDIYwYDvUcNgVXhbS8(WQZfNrb0gwRF2aA1CcDoJGJ6omGCdCFG4ckXdhjwzeFtHA7v3TdzrL4Kt0z66Cc3Fel2EstlQeM4ZU4x2YjmcUWeV0AOxMWzHvZ9Y4sVeoJpnkVxo9x2YICcAVC6V0AOxcix(0lJl9Yw0Ssn8Veq6ewDqt8Y9YxAn0lt4SWQ5E50FzCVe)AcHrPxIrL5acEPYg6EP1qlDaJEjUGsVmNrWrDhM(LTS4LT8yaYVSjeVmEja6mjEjgvMdi4LXLEz07e0eVSmb57V0AkXllXlbqdGq)zdOvZj05mcoQ7WaYnWHiNGgF6CRH4klFQ9CgbdHXTsLCdGgG2RUBhgosSYiDoRudpVoHvh0eA6ITNsz4qsiOdsAsiOds8PZTgI3hiUOox8IvcTAGrgwgTropELNtjD4OOjyHG3NZ4tNNpkj26QdjNhVYZPKgUe6hJnxb5BFiSw)Sl(LTCcJGlmXlTg6LjCwy1CVmU0lHZ4tJY7Lt)LkqcRc)lbKzH18Y4sVeJw4i9YP)YwKWf9Y9YxAn0lt4SWQ5E50FzCVe)AcHrPxIrL5acEPYg6EP1qlDaJEjUGsVmNrWrDhM(ZgqRMtOZzeCu3HbKBG3KWQWZvYcRP9CgbdHXTsLCdGgBTxD3HJeRmsNZk1WZRty1bnHMUy7PugoKec6GKMec6GeF6CRH49bIlQZfVyLqRgyKHLrBKZJx55ushokAcwi495m(055JsITU6qY5XR8CkPHlH(XyZvq(2hcR1p7NnGwnNqJBLVSLUHd(zeJlAg7ZgqRMtOXTYx2sGCdSGy0v2sEcxyF2aA1CcnUv(YwcKBGf5dJ4q)GN(Sb0Q5eACR8LTei3alMXAQZfxzye7ZgqRMtOXTYx2sGCdSyUcY3(qyF2aA1CcnUv(YwcKBGpYAigx0mWf(Sb0Q5eACR8LTei3adBkmsj4gloNhV8LT8ZgqRMtOXTYx2sGCdSiVyLXfndCHpBaTAoHg3kFzlbYnWxy4msWDXci9z)Sl(LTOwebXnk9sYjIT8LwPsV0AOxgqByVSeVmCkkFS9K(ZgqRMt4ggEppGwnh3xcR9luj34w5lBz7v3DI249UggcRoxA8811eTX7DDQe5K3hBpXvdxfuJNVUMOnEVRtLiN8(y7joDSWfPXZ)Sb0Q5ea5gyCbXlJufF2aA1CcGCdmUG4LrQTFHk5oenofhj4SWXHXHdl8TxD3jAJ37Aw44W4WHfEEI249UgppJ2YzKtCxWKgaDiYjOXNo3AiUYYNwxDi584vEoL0WLq)yS5kiF7dHLXgV31HiNGgF6CRH4klFsJN3AgTzbZfz6gk8wJohAkMjSTU6qsiOdsA4Cj6euI7Ro1hgK0QbgzyTUU2wI249UMfoomoCyHNNOnEVRtJYBD1kvIBdpvKIa25AndRujUn8uryOnadOaITbNXNgLNgUe6hJnxb5BFimnJuJ6eabOkAbZfzARujUn8urT26NnGwnNai3aJliEzKA7uVtqJFHk5gUe6hJnxb5BFiS2RU7nEVR3KWQWZvYcRrNgL36QvQe3gEQifX2NnGwnNai3addVNhqRMJ7lH1(fQKBys8zdOvZjaYnWWW75b0Q54(syTFHk5wyTxD3b0kNioDKArcfb8NnGwnNai3addVNhqRMJ7lH1(fQKBONcNO2RU7aALteNosTibga4Z(zdOvZj0WKWDCqsySWZHH33E1DdNXNgLNEtcRcpxjlSgnJuJ6eyito7ZgqRMtOHjbqUbUxmA7Nj1E1DdNXNgLNEtcRcpxjlSgnJuJ6eyito7ZgqRMtOHjbqUbEtmbXwOoxTxD3B8ExhICcA8PZTgIRS8jnEEgTzLkXTHNkcdWz8Pr5P3etqSfQZLoHZcRMdOeolSAU112SG5ImDdfERrNdnfZe2wxDOfE6m9cL3tmEDcRoOPPl2Ek1ARRRwPsCB4PIueGm9zdOvZj0WKai3aV9ZK4DC2Y2RU7nEVRdrobn(05wdXvw(KgppJ2SsL42WtfHb4m(0O80B)mjEhNTuNWzHvZbucNfwn36ABwWCrMUHcV1OZHMIzcBRRo0cpDMEHY7jgVoHvh000fBpLAT11vRujUn8urkcGZ9zdOvZj0WKai3a7lxnMGJrWtUuPZAV6UZjtddtVX7DDNrNJl145zKtMggMEJ376oJohxQzKAuNadUGjTASO1vhMtMggMEJ376oJohxQXZ)Sb0Q5eAysaKBGZhRMR9Q7EJ376njSk8CLSWA045zSX7DDiYjOXNo3AiUYYN045z0MfmxKPBOWBn6COPyMW26QdTWtNPxO8EIXRty1bnnDX2tPwxxBRn4CcC1y7jD(y1C8PZXVnRsEkX74SLRRW5e4QX2tA8BZQKNs8ooBzRzyLkXTHNksrNdG1vRujUn8urkcyNR1pBaTAoHgMea5gyLdZNCIQJZiXCXbP2RU7nEVR9vN2(zsAHfWfueq)Sb0Q5eAysaKBGDHhSufhF68WrInwt7v3nCgFAuE6qKtqJpDU1qCLLpPzKAuNqraC26QvQe3gEQimeqRMt7cpyPko(05HJeBSgnCgFAuEaLjNTUALkXTHNksXm5SpBaTAoHgMea5gywLN7jEDCrEaPpBaTAoHgMea5gyvsDyl5tN7XHvINyuOk(SF2aA1Ccn0tHtK7DW2uIlAgRD4sON4wWCrMWnaTxD35KPHHP349UUZOZXLA88mYjtddtVX7DDNrNJl1msnQtOOBxWKwnweq7GTPex0mg3flGepNy1K(Sb0Q5eAONcNiGCdSkU3krZyTxD3UGjTASimoNmnmm9gV31Bkegh6PWjsZi1OobgCMgWy7ZgqRMtOHEkCIaYnW7GTPex0mw7WLqpXTG5ImHBaAV6U74EpNrWMG5I4wPsk6cM0QXIYaoJpnkp9MewfEUswynAgPg1j(Sb0Q5eAONcNiGCdCiYjOXNo3AiUYYN(Sb0Q5eAONcNiGCdSWc1CkrTxD3B8ExhICcA8PZTgIRS8jnEEgB8ExVjHvHNRKfwJgpFD1kvIBdpvKIaGTpBaTAoHg6PWjci3aVjHvHNRKfwt7v3nCgFAuE6qKtqJpDU1qCLLpPzKAuNG7cNecmayNTUAHNotphXvwwd3AiEEaxqtxS9uAD1kvIBdpvKIaGTpBaTAoHg6PWjci3adBk1Gybx0m2NnGwnNqd9u4ebKBGdUkolrm(05q2Ou8zdOvZj0qpfora5g4DWyHl6ZgqRMtOHEkCIaYnWluEphoQQXLAV6UdOvorC6i1IekcORRomCKyLrAwKxjoJ8tK00fBpL(Sb0Q5eAONcNiGCdCQyeFtHW(Sb0Q5eAONcNiGCd8oyBkXfnJ1oCj0tClyUit4gG2RU7CY0WW0B8Ex3z054sDAuEz0gSjyUibVZcOvZfEmaGoZwx349UEtcRcpxjlSgnEERRRWz8Pr5Pdrobn(05wdXvw(KMrQrDcfZjtddtVX7DDNrNJl1jCwy1CySlykJWrIvgPZzLA451jS6GMqtxS9uADf2emxKG3zb0Q5cpgaqdORRwPsCB4PIue7(Sb0Q5eAONcNiGCdCFG4ckXdhjwzeFtH6NnGwnNqd9u4ebKBGZXzvFzDU4BFiSpBaTAoHg6PWjci3adNdsNXcJs8UpuPpBaTAoHg6PWjci3aV9ZK4tNBneNosD5NnGwnNqd9u4ebKBGTgIJF7b)s8(WGu7v39gV31mcUGNecEFyqsJNVUUX7DnJGl4jHG3hgK4Wb)mIPfwaxqraC2NnGwnNqd9u4ebKBGvX9wjAgR9Q7oCKyLrAwKxjoJ8tK00fBpLYiGw5eXPJulsGba)zdOvZj0qpfora5gy4Szbx0mw7v3nCgFAuE6fkVNdhv14sAgPg1jWqFG4cTvQe3gUASOmAlGw5eXPJulsOyMwxDy4iXkJ0SiVsCg5NiPPl2Ek16NnGwnNqd9u4ebKBGf5Lz15IdNnl(SF2aA1CcTWCVd2MsCrZyTxD35KPHHP349UUZOZXLA88mYjtddtVX7DDNrNJl1msnQtOOlycODW2uIlAgJ7IfqINtSAsRRWz8Pr5P3KWQWZvYcRrZi1OorgT1X9EoJGnbZfXTsLu0fmTUgosSYiDoRudpVoHvh0eA6ITNszaNXNgLNoe5e04tNBnexz5tAgPg1ju0fm16NnGwnNqlmGCdmCoiDglmkX7(qLAV6U7dexauFG4cnJCrhGOlysX(aXfA1yrzSX7D9MewfEUswyn60O8YOnhMgtdNdsNXcJs8Upuj(gNDAgPg1jYWHb0Q50W5G0zSWOeV7dvsxhV7lxnwRRRDCVNZiytWCrCRujfDbtRRwPsCB4PIueBF2aA1CcTWaYnWHiNGgF6CRH4klFQ9Q7goJpnkp9oyBkXfnJPHnbZfjueWRR5KPHHP349UUZOZXLAHfWfWaGxxDy4iXkJ05Ssn886ewDqtOPl2Ek9zdOvZj0cdi3alSqnNsu7v39gV31HiNGgF6CRH4klFsJNNXgV31Bsyv45kzH1OXZxxTsL42WtfPiay7ZgqRMtOfgqUbo4Q4SeX4tNdzJsr7v3nCgFAuE6njSk8CLSWA0msnQt8zdOvZj0cdi3a3hiUGs8WrIvgX3uO2E1DVX7D9MewfEUswyn60O8wxTsL42WtfPi2(Sb0Q5eAHbKBGTgIJF7b)s8(WGu7v39gV31mcUGNecEFyqsJNVUUX7DnJGl4jHG3hgK4Wb)mIPfwaxqraC26QvQe3gEQifX2NnGwnNqlmGCd8MewfEUswynF2aA1CcTWaYnWluEphoQQXL(Sb0Q5eAHbKBGHnLAqSGlAg7ZgqRMtOfgqUbovmIVPqyF2aA1CcTWaYnW7GTPex0mw7v3DozAyy6nEVR7m6CCPonkVmAd2emxKG3zb0Q5cpgaqNzRRB8ExVjHvHNRKfwJgpV11v4m(0O80HiNGgF6CRH4klFsZi1OoHI5KPHHP349UUZOZXL6eolSAom2fmLr4iXkJ05Ssn886ewDqtOPl2EkTUgosSYiDkoiXNoprH1OzXTagaiJnEVRtXbj(05jkSgDAuEzazLXZHghIZy0zyaqD26QvQe3gEQifXUpBaTAoHwya5g4CCw1xwNl(2hcR9Q7EJ376njSk8CLSWA0Pr5TUALkXTHNksXm7ZgqRMtOfgqUbE7NjXNo3AioDK6YpBaTAoHwya5g4DWyHl6ZgqRMtOfgqUbgoBwWfnJ1E1D3wFG4cmgocdO(aXfAg5IoaX2GZ4tJYtVq59C4OQgxsZi1OobgdqRyiGwnNEHY75WrvnUKgocBDfoJpnkp9cL3ZHJQACjnJuJ6eyaaGCbtRRB8ExRsQdBjF6CpoSs8eJcvHgpV1mGZ4tJYtVq59C4OQgxsZi1Oobga4ZgqRMtOfgqUbwKxMvNloC2S4ZgqRMtOfgqUbEhSnL4IMXAV6UHnbZfj4DwaTAUWJba0akcuKtqeMagBzczidHa]] )


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
