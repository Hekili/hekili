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
            aura = 'spect_of_the_wild',

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
        dire_beast_hawk = {
            id = 208684,
            duration = 3600,
            max_stack = 1,
        },

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

            velocity = 50,

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


    spec:RegisterPack( "Beast Mastery", 20190718.0001, [[dWuNZaqiss8iPqTjPO(euuJIKuNIQeRIKi4vkIzPi5wkszxu8lPIHrs4yIsldk4zuL00uKQRbfABsrQVrsuJtksohueRdksZtk4EKu7tQuhuuGfQO6HKK0effKUijrOpkkKgPOG4KIcXkPkMPOG6MKeP2PuLHssK0sjjIEQctvQQRssK4RIcLXkkuDwPqSxL(lLgmQoSWIb6XqMSixgzZa(mvLrlLoTKvlfsETujZMk3gQ2TQ(TkdxuDCPqQLtQNJY0jUoj2ovP(ovvJxkIZROSErrZhkTFqVz3(7ifcT9WGkYIjQqLZ2ugvOcvKfd7qMLt7ipqDf(OD8boTJ5uWeixLoycPNTJ8yM7I02FhStrJOD0ksodt70XxjTkGg0H3Hv4kUqQ7r6aq6WkCuNDaQuojJ8l4osHqBpmOISyIku5SQSbdEfJQmg3rOiTNEhJcxv3rBLs0VG7irm0oAmKpNcMa5Q0bti9mipdr5fsd90yiVvKCgM2PJVsAvanOdVdRWvCHu3J0bG0Hv4OoqpngY9O4Mb5zv5PGCmOISycKpniplgW0Sye6b6PXqUQ2gVpIHPqpngYNgKNbPeLGCv9uEH0q(O9eixoipraHItG8aj19qURyIb6PXq(0GCvkmcYLcNSYztfb5Q2BMbYLq7JeJu4KvoBQiVa5Yb5XlfQYdHGC6tq(ba50JoLxiTb6PXq(0G8miLG8uXYjhRtUI2hXGCVRaYvKYvYmipqsDpK7kMy2HRycB7VJebekoz7V9YU93b9bOJs78DeiPUFhOW5SbsQ7TUIj7aPlH0vSJebQaayqbtQ3NrjhYXIfYteOcaGjvSCY5cqhzXdFfYOKd5yXc5jcubaWKkwo5CbOJS0RdFKrjFhUIj2pWPDOiLRKzRS9WW2FhbsQ73HcJSLq4SDqFa6O0oFLTNx3(7G(a0rPD(ocKu3Vdu4C2aj19wxXKD4kMy)aN2bkXwz7n9T)oOpaDuANVJaj197afoNnqsDV1vmzhiDjKUIDeiP8MS0t4fXG8gGCmSdxXe7h40oyYkBpmU93b9bOJs78DeiPUFhOW5SbsQ7TUIj7aPlH0vSJajL3KLEcVigK3nKNDhUIj2pWPDGCu4nTYk7ixtOdhmKT)2l72FhbsQ73btbh)EBoj7G(a0rPD(kBpmS93rGK6(DKFsD)oOpaDuANVY2ZRB)DeiPUFh(pTl5nvVvtS7Jhr7G(a0rPD(kBVPV93rGK6(D4tj0PkE7byJmj9jT7G(a0rPD(kBpmU93rGK6(DGt4NEM9aSofuLSjnf4SDqFa6O0oFLTxtV93b9bOJs78DKRjuWeRu40oYAYUJaj197iy5esShGvAjR)YL2bsxcPRyhQcKhzs6sitUUWdNTEMupsyg6dqhLwz7PYB)DqFa6O0oFh5AcfmXkfoTJSgmUJaj197aKysfoRFDiT7aPlH0vSJitsxczY1fE4S1ZK6rcZqFa6O0kRSdKJcVPT)2l72Fh0hGokTZ3bsxcPRyhGkaagan9zoZOKd5nd5Gkaagan9zoZOj8OEgK3GAi3hkzWJMa5tGCWqdsjlR9eRpDGiBoPRlTJaj197am0GuYYApzhOzihzLq7Je22l7kBpmS93b9bOJs78DG0Lq6k2HpuYGhnbYNgKdQaayaPGjwKJcVjJMWJ6zqE3qUkmyaJ7iqsD)oWvCsXApzLTNx3(7G(a0rPD(oq6siDf7aqX5SAc1gAFKvkCcYBaY9Hsg8OjqEZqo6ox68)gqIjv4S(1H0A0eEupBhbsQ73byObPKL1EYoqZqoYkH2hjSTx2v2EtF7VJaj197iy5esShGvAjR)YL2b9bOJs78v2EyC7Vd6dqhL257aPlH0vSdqfaatWYjKypaR0sw)LlzuYH8MHCqfaadiXKkCw)6qAnk5qowSqUu4KvoBQiiVbiplg3rGK6(DWKapNs0kBVME7Vd6dqhL257aPlH0vSd0DU05)nblNqI9aSslz9xUKrt4r9mRpfIXG8UHCmOcihlwixch9I5EY6VKwR0s28a1LH(a0rjihlwixkCYkNnveK3aKNfJ7iqsD)oajMuHZ6xhs7kBpvE7VJaj197a1w4bPdlR9KDqFa6O0oFLTxtT93rGK6(DewCfDI02dWI0NF2oOpaDuANVY2dt2(7iqsD)oadTo8r7G(a0rPD(kBVSQy7Vd6dqhL257aPlH0vSJajL3KLEcVigK3aKpDihlwixvG8itsxcz0rELSAYDrYqFa6O0ocKu3VJUkNZIoC84tRS9YMD7VJaj197ivAYcsbt2b9bOJs78v2EzXW2Fh0hGokTZ3bsxcPRyhGkaagan9zoZKo)pK3mKRAih1gAFeZcOdKu3hoiVBipRPPGCSyHCqfaadiXKkCw)6qAnk5qUxGCSyHC0DU05)nblNqI9aSslz9xUKrt4r9miVbihubaWaOPpZzMKIoK6EiFAqUpucYBgYJmjDjKjxx4HZwptQhjmd9bOJsqowSqoQn0(iMfqhiPUpCqE3qEwZ0HCSyHCPWjRC2urqEdqoMSJaj197am0GuYYApzhOzihzLq7Je22l7kBVSED7VJaj197a4qkmkzJmjDjKfKc8DqFa6O0oFLTx2PV93rGK6(DKROlGz17Zc6cMSd6dqhL25RS9YIXT)ocKu3Vd09i6fDiuYc4cCAh0hGokTZxz7LTP3(7iqsD)oaD3LShGvAjl9e(SDqFa6O0oFLTxwvE7Vd6dqhL257aPlH0vSdqfaaJMqD5igZcCAezuYHCSyHCqfaaJMqD5igZcCAezrNYlK2WKa1fK3aKNvf7iqsD)oKwYQ8GNYNSaNgrRS9Y2uB)DqFa6O0oFhiDjKUIDezs6siJoYRKvtUlsg6dqhLG8MH8ajL3KLEcVigK3nKJHDeiPUFh4koPyTNSY2llMS93b9bOJs78DG0Lq6k2b6ox68)MUkNZIoC84tgnHh1ZG8UHCGdPWmsHtw5S4rtG8MHCvd5bskVjl9eErmiVbi3RqowSqUQa5rMKUeYOJ8kz1K7IKH(a0rji3l7iqsD)oqhOoSS2twz7HbvS93rGK6(DWYlrQ3NfDG6yh0hGokTZxzLDGsST)2l72Fh0hGokTZ3bsxcPRyhO7CPZ)BajMuHZ6xhsRrt4r9miVBi3RQyhbsQ73r8iIj6WzrHZTY2ddB)DqFa6O0oFhiDjKUIDGUZLo)VbKysfoRFDiTgnHh1ZG8UHCVQIDeiPUFhaLMaD3Lwz751T)oOpaDuANVdKUesxXoavaamblNqI9aSslz9xUKrjhYBgYvnKlfozLZMkcY7gYr35sN)3asAgP7QEFMKIoK6EiFcKNu0Hu3d5yXc5QgYLq7JetlfoP1KJeiVbi3RyeYXIfYvfixch9IPRY5iTTEMupsm0hGokb5EbY9cKJflKlfozLZMkcYBaYZ61DeiPUFhGKMr6UQ33kBVPV93b9bOJs78DG0Lq6k2bOcaGjy5esShGvAjR)YLmk5qEZqUQHCPWjRC2urqE3qo6ox68)gq3DjlGIEMjPOdPUhYNa5jfDi19qowSqUQHCj0(iX0sHtAn5ibYBaY9kgHCSyHCvbYLWrVy6QCosBRNj1Jed9bOJsqUxGCVa5yXc5sHtw5SPIG8gG8Sn9ocKu3Vdq3DjlGIE2kBpmU93b9bOJs78DG0Lq6k2bOcaGbqtFMZmk5qEZqoOcaGbqtFMZmAcpQNb5Dd5(qjdE0eihlwixvGCqfaadGM(mNzuY3rGK6(D4kFTcZ2Ous(WPxwz710B)DqFa6O0oFhiDjKUIDaQaayajMuHZ6xhsRrjhYBgYbvaamblNqI9aSslz9xUKrjhYBgYvnKlH2hjMwkCsRjhjqEdqUxXiKJflKRkqUeo6ftxLZrAB9mPEKyOpaDucY9cKJflKlfozLZMkcYBaYXag3rGK6(DKFsD)kBpvE7Vd6dqhL257aPlH0vSdqfaaJRaiq3DjdtcuxqEdq(03rGK6(D4)0UK3u9wnXUpEeTY2RP2(7iqsD)o8Pe6ufV9aSrMK(K2DqFa6O0oFLThMS93rGK6(DOR8ChzR3YYdeTd6dqhL25RS9YQIT)ocKu3VdCc)0ZShG1PGQKnPPaNTd6dqhL25RSYoyY2F7LD7Vd6dqhL257aPlH0vSdqfaadGM(mNzuYH8MHCqfaadGM(mNz0eEupdYBqnK7dLm4rtG8jqoyObPKL1EI1NoqKnN01LGCSyHCafNZQjuBO9rwPWjiVbi3hkzWJMa5nd5O7CPZ)BajMuHZ6xhsRrt4r9mihlwipYK0LqMCDHhoB9mPEKWm0hGokb5nd5O7CPZ)BcwoHe7byLwY6VCjJMWJ6zqEdqUpuAhbsQ73byObPKL1EYkBpmS93rGK6(DeSCcj2dWkTK1F5s7G(a0rPD(kBpVU93rGK6(DewCfDI02dWI0NF2oOpaDuANVY2B6B)DqFa6O0oFhiDjKUIDaQaaycwoHe7byLwY6VCjJsoK3mKdQaayajMuHZ6xhsRrjhYXIfYLcNSYztfb5na5zX4ocKu3VdMe45uIwz7HXT)oOpaDuANVdKUesxXoq35sN)3eSCcj2dWkTK1F5sgnHh1ZG8UHCmOcihlwixkCYkNnveK3aKNfJ7iqsD)oajMuHZ6xhs7kBVME7VJaj197ORY5SOdhp(0oOpaDuANVY2tL3(7iqsD)oqTfEq6WYApzh0hGokTZxz71uB)DeiPUFhPstwqkyYoOpaDuANVY2dt2(7G(a0rPD(oq6siDf7aubaWaOPpZzM05)H8MHCvd5O2q7JywaDGK6(Wb5Dd5znnfKJflKdQaayajMuHZ6xhsRrjhY9cKJflKJUZLo)Vjy5esShGvAjR)YLmAcpQNb5na5Gkaagan9zoZKu0Hu3d5tdY9HsqEZqEKjPlHm56cpC26zs9iHzOpaDucYXIfYJmjDjKjfpIShGnrH0A0X3fK3nKNfYBgYbvaamP4rK9aSjkKwt68)qEZqosxInhjwKIwtVa5Dd5txfqowSqUu4KvoBQiiVbiht2rGK6(DagAqkzzTNSY2lRk2(7iqsD)oaoKcJs2itsxczbPaFh0hGokTZxz7Ln72FhbsQ73rUIUaMvVplOlyYoOpaDuANVY2llg2(7iqsD)oq3JOx0HqjlGlWPDqFa6O0oFLTxwVU93rGK6(Da6UlzpaR0sw6j8z7G(a0rPD(kBVStF7VJaj197qAjRYdEkFYcCAeTd6dqhL25RS9YIXT)ocKu3VdWqRdF0oOpaDuANVY2lBtV93b9bOJs78DG0Lq6k2HQHCGdPWG8Pb5OJjq(eih4qkmJM8rpKRsaYvnKJUZLo)VPRY5SOdhp(Krt4r9miFAqEwi3lqE3qEGK6EtxLZzrhoE8jd6ycKJflKJUZLo)VPRY5SOdhp(Krt4r9miVBiplKpbY9HsqowSqoOcaGbNWp9m7byDkOkztAkWzgLCi3lqEZqo6ox68)MUkNZIoC84tgnHh1ZG8UH8S7iqsD)oqhOoSS2twz7LvL3(7iqsD)oy5Li17ZIoqDSd6dqhL25RS9Y2uB)DqFa6O0oFhiDjKUIDGAdTpIzb0bsQ7dhK3nKN1m9DeiPUFhGHgKsww7jRSYouKYvYST)2l72FhbsQ73b6uEH0ww7j7G(a0rPD(kBpmS93rGK6(DWin9LmZMuyYoOpaDuANVY2ZRB)DeiPUFhS8ttwK7us7G(a0rPD(kBVPV93rGK6(DWUtAR3N1FiKEh0hGokTZxz7HXT)ocKu3Vd29fYc6cMSd6dqhL25RS9A6T)ocKu3VJNKwsBzThQRDqFa6O0oFLTNkV93rGK6(DGARgvXSIo(gTs5kz2oOpaDuANVY2RP2(7iqsD)oy5LUelR9qDTd6dqhL25RS9WKT)ocKu3VJpefnXS(0bI2b9bOJs78vwzLD4nPz19BpmOISyIkuzvGjMSyyh(d9xVp2oYyzGkzVmsVmkMc5qE)wcYl88tlqoWPHCmJCu4nHzixtnALstjiND4eKhkYHhcLGCuB8(iMb6jdxpb5zXuixvV3BslucYXCojMmUPrmgdMHC5GCm3igJbZqUQXqt8Ib6jdxpb5yatHCv9EVjTqjihZ5KyY4MgXymygYLdYXCJymgmd5QoBt8Ib6jdxpb5zXaMc5Q69EtAHsqoMZjXKXnnIXyWmKlhKJ5gXymygYvngAIxmqpqpzSmqLSxgPxgftHCiVFlb5fE(Pfih40qoMrjgMHCn1OvknLGC2HtqEOihEiucYrTX7JygONmC9eKJrmfYv179M0cLGCmNtIjJBAeJXGzixoihZnIXyWmKRAV2eVyGEGEYyzGkzVmsVmkMc5qE)wcYl88tlqoWPHCmZemd5AQrRuAkb5SdNG8qro8qOeKJAJ3hXmqpz46jiplMc5Q69EtAHsqoMZjXKXnnIXyWmKlhKJ5gXymygYvngAIxmqpz46jihtWuixvV3BslucYXCojMmUPrmgdMHC5GCm3igJbZqUQXqt8Ib6b6jJGNFAHsqEtd5bsQ7HCxXeMb6zhSCcT9Wag96oY1hq5OD0yiFofmbYvPdMq6zqEgIYlKg6PXqERi5mmTthFL0QaAqhEhwHR4cPUhPdaPdRWrDGEAmK7rXndYZQYtb5yqfzXeiFAqEwmGPzXi0d0tJHCvTnEFedtHEAmKpnipdsjkb5Q6P8cPH8r7jqUCqEIacfNa5bsQ7HCxXed0tJH8Pb5QuyeKlfozLZMkcYvT3mdKlH2hjgPWjRC2urEbYLdYJxkuLhcb50NG8daYPhDkVqAd0tJH8Pb5zqkb5PILtowNCfTpIb5ExbKRiLRKzqEGK6Ei3vmXa9a90yixLytiKIqjihKaonb5OdhmeihK8vpZa5zacr5cdY)7NwBOXbuCqEGK6EgKFVBMb6PXqEGK6EMjxtOdhme1aUG1f0tJH8aj19mtUMqhoyitu3ju8HtVesDp0tJH8aj19mtUMqhoyitu3b4Ue0tGK6EMjxtOdhmKjQ7WuWXV3Mtc0tJH8Xh5S2tGCDujihubaGsqotcHb5GeWPjihD4GHa5GKV6zqE8jipxttl)ePEFqEXG809Kb6PXqEGK6EMjxtOdhmKjQ7W(iN1EILjHWGEcKu3Zm5AcD4GHmrDN8tQ7HEcKu3Zm5AcD4GHmrDh)N2L8MQ3Qj29XJiONaj19mtUMqhoyitu3XNsOtv82dWgzs6tAHEcKu3Zm5AcD4GHmrDhCc)0ZShG1PGQKnPPaNb90yipdsnkfMWGCPLG8KIoK6Eip(eKJUZLo)pKFaqEgWYjKa5haKlTeKNXkxcYJpb5Qu1fE4G8mYZK6rcdYbNb5slb5jfDi19q(ba5Xd5kFBWekb5zuvndfY93spKlT0mmRjixHrjipxtOdhmedKNbmipdojJb5TbdYdipRXRmipJQQzOqE8jipaaiKWG8syKdaYL2Ib5fdYZAYYmqpbsQ7zMCnHoCWqMOUtWYjKypaR0sw)LlnvUMqbtSsHtQZAYovbOwvImjDjKjxx4HZwptQhjmd9bOJsqpngYZGuJsHjmixAjipPOdPUhYJpb5O7CPZ)d5haKpNysfoipJPdPfYJpb5zirMeKFaqUkz4JGCWzqU0sqEsrhsDpKFaqE8qUY3gmHsqEgvvZqHC)T0d5slndZAcYvyucYZ1e6WbdXa9eiPUNzY1e6WbdzI6oGetQWz9RdPDQCnHcMyLcNuN1GXPka1rMKUeYKRl8WzRNj1JeMH(a0rjOhONaj19mJIuUsMPgDkVqAlR9eONaj19mJIuUsMnrDhgPPVKz2KctGEcKu3Zmks5kz2e1Dy5NMSi3PKGEcKu3Zmks5kz2e1Dy3jT17Z6pesd9eiPUNzuKYvYSjQ7WUVqwqxWeONaj19mJIuUsMnrDNNKwsBzThQlONaj19mJIuUsMnrDhuB1OkMv0X3OvkxjZGEcKu3Zmks5kz2e1Dy5LUelR9qDb9eiPUNzuKYvYSjQ78HOOjM1Noqe0d0tJHCvInHqkcLGCYBspdYLcNGCPLG8ajNgYlgKhEhLlaDKb6jqsDptnkCoBGK6ERRyYuFGtQvKYvYSPka1jcubaWGcMuVpJsowSjcubaWKkwo5CbOJS4HVczuYXInrGkaaMuXYjNlaDKLED4Jmk5qpbsQ7ztu3rHr2siCg0tGK6E2e1DqHZzdKu3BDftM6dCsnkXGEcKu3ZMOUdkCoBGK6ERRyYuFGtQzYufG6ajL3KLEcViwdya6jqsDpBI6oOW5SbsQ7TUIjt9boPg5OWBAQcqDGKYBYspHxeR7SqpqpbsQ7zguIPoEeXeD4SOW5MQauJUZLo)VbKysfoRFDiTgnHh1Z62RQa6jqsDpZGsSjQ7auAc0DxAQcqn6ox68)gqIjv4S(1H0A0eEupRBVQcONaj19mdkXMOUdiPzKUR69nvbOgubaWeSCcj2dWkTK1F5sgL8MvTu4KvoBQOUr35sN)3asAgP7QEFMKIoK6(jjfDi19yXQAj0(iX0sHtAn5iPbVIrSyvfjC0lMUkNJ026zs9iXqFa6OKx8cwSsHtw5SPIAiRxHEcKu3ZmOeBI6oGU7swaf9SPka1GkaaMGLtiXEawPLS(lxYOK3SQLcNSYztf1n6ox68)gq3DjlGIEMjPOdPUFssrhsDpwSQwcTpsmTu4KwtosAWRyelwvrch9IPRY5iTTEMupsm0hGok5fVGfRu4KvoBQOgY20qpbsQ7zguInrDhx5Rvy2gLsYho9YufG6CsmOqmGkaagan9zoZOK3CojguigqfaadGM(mNz0eEupRBFOKbpAcwSQsojguigqfaadGM(mNzuYHEcKu3ZmOeBI6o5Nu3pvbOgubaWasmPcN1VoKwJsEZGkaaMGLtiXEawPLS(lxYOK3SQLq7JetlfoP1KJKg8kgXIvvKWrVy6QCosBRNj1Jed9bOJsEblwPWjRC2urnGbmc9eiPUNzqj2e1D8FAxYBQERMy3hpIMQaudQaayCfab6UlzysG6QHPd9eiPUNzqj2e1D8Pe6ufV9aSrMK(KwONaj19mdkXMOUJUYZDKTEllpqe0tGK6EMbLytu3bNWp9m7byDkOkztAkWzqpqpbsQ7zgKJcVj1GHgKsww7jtHMHCKvcTpsyQZovbOoNedkedOcaGbqtFMZmk5nNtIbfIbubaWaOPpZzgnHh1ZAqTpuYGhnzcyObPKL1EI1NoqKnN01LGEcKu3ZmihfEttu3bxXjfR9KPka1(qjdE0KPLtIbfIbubaWasbtSihfEtgnHh1Z6wfgmGrONaj19mdYrH30e1DadniLSS2tMcnd5iReAFKWuNDQcqnGIZz1eQn0(iRu4ud(qjdE0KMr35sN)3asmPcN1VoKwJMWJ6zqpbsQ7zgKJcVPjQ7eSCcj2dWkTK1F5sqpbsQ7zgKJcVPjQ7WKapNs0ufGAqfaatWYjKypaR0sw)LlzuYBgubaWasmPcN1VoKwJsowSsHtw5SPIAilgHEcKu3ZmihfEttu3bKysfoRFDiTtvaQr35sN)3eSCcj2dWkTK1F5sgnHh1ZS(uigRBmOcSyLWrVyUNS(lP1kTKnpqDzOpaDuclwPWjRC2urnKfJqpbsQ7zgKJcVPjQ7GAl8G0HL1Ec0tGK6EMb5OWBAI6oHfxrNiT9aSi95Nb9eiPUNzqok8MMOUdyO1Hpc6jqsDpZGCu4nnrDNUkNZIoC84ttvaQdKuEtw6j8IynmDSyvLitsxcz0rELSAYDrYqFa6Oe0tGK6EMb5OWBAI6oPstwqkyc0tGK6EMb5OWBAI6oGHgKsww7jtHMHCKvcTpsyQZovbOoNedkedOcaGbqtFMZmPZ)3SQrTH2hXSa6aj19HR7SMMclwqfaadiXKkCw)6qAnk5Eblw0DU05)nblNqI9aSslz9xUKrt4r9SgYjXGcXaQaaya00N5mtsrhsD)08Hsnhzs6sitUUWdNTEMupsyg6dqhLWIf1gAFeZcOdKu3hUUZAMowSsHtw5SPIAatGEcKu3ZmihfEttu3b4qkmkzJmjDjKfKcCONaj19mdYrH30e1DYv0fWS69zbDbtGEcKu3ZmihfEttu3bDpIErhcLSaUaNGEcKu3ZmihfEttu3b0DxYEawPLS0t4ZGEcKu3ZmihfEttu3rAjRYdEkFYcCAenvbOgubaWOjuxoIXSaNgrgLCSybvaamAc1LJymlWPrKfDkVqAdtcuxnKvfqpbsQ7zgKJcVPjQ7GR4KI1EYufG6itsxcz0rELSAYDrYqFa6OuZbskVjl9eErSUXa0tGK6EMb5OWBAI6oOduhww7jtvaQr35sN)30v5Cw0HJhFYOj8OEw3ahsHzKcNSYzXJM0SQdKuEtw6j8Iyn4vSyvLitsxcz0rELSAYDrYqFa6OKxGEcKu3ZmihfEttu3HLxIuVpl6a1b0d0tGK6EMHjQbdniLSS2tMQauNtIbfIbubaWaOPpZzgL8MZjXGcXaQaaya00N5mJMWJ6znO2hkzWJMmbm0GuYYApX6thiYMt66syXcO4CwnHAdTpYkfo1GpuYGhnPz0DU05)nGetQWz9RdP1Oj8OEgwSrMKUeYKRl8WzRNj1JeMH(a0rPMr35sN)3eSCcj2dWkTK1F5sgnHh1ZAWhkb9eiPUNzyYe1DcwoHe7byLwY6VCjONaj19mdtMOUtyXv0jsBpalsF(zqpbsQ7zgMmrDhMe45uIMQaudQaaycwoHe7byLwY6VCjJsEZGkaagqIjv4S(1H0AuYXIvkCYkNnvudzXi0tGK6EMHjtu3bKysfoRFDiTtvaQr35sN)3eSCcj2dWkTK1F5sgnHh1Z6gdQalwPWjRC2urnKfJqpbsQ7zgMmrDNUkNZIoC84tqpbsQ7zgMmrDhuBHhKoSS2tGEcKu3ZmmzI6oPstwqkyc0tGK6EMHjtu3bm0GuYYApzQcqDojguigqfaadGM(mNzsN)VzvJAdTpIzb0bsQ7dx3znnfwSGkaagqIjv4S(1H0AuY9cwSO7CPZ)BcwoHe7byLwY6VCjJMWJ6znKtIbfIbubaWaOPpZzMKIoK6(P5dLAoYK0LqMCDHhoB9mPEKWm0hGokHfBKjPlHmP4rK9aSjkKwJo(U6oBZGkaaMu8iYEa2efsRjD()Mr6sS5iXIu0A6LUNUkWIvkCYkNnvudyc0tGK6EMHjtu3b4qkmkzJmjDjKfKcCONaj19mdtMOUtUIUaMvVplOlyc0tGK6EMHjtu3bDpIErhcLSaUaNGEcKu3ZmmzI6oGU7s2dWkTKLEcFg0tGK6EMHjtu3rAjRYdEkFYcCAeb9eiPUNzyYe1DadTo8rqpbsQ7zgMmrDh0bQdlR9KPka1Qg4qkSPHoMmb4qkmJM8rVkbvJUZLo)VPRY5SOdhp(Krt4r9SPL1lDhiPU30v5Cw0HJhFYGoMGfl6ox68)MUkNZIoC84tgnHh1Z6o7eFOewSGkaagCc)0ZShG1PGQKnPPaNzuY9sZO7CPZ)B6QCol6WXJpz0eEupR7SqpbsQ7zgMmrDhwEjs9(SOduhqpbsQ7zgMmrDhWqdsjlR9KPka1O2q7JywaDGK6(W1DwZ0xzLDb]] )


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
