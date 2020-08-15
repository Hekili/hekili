-- Hunter Beast Mastery
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- needed for Frenzy.
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


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
            value = 5,
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
            value = 5,
        },

        barbed_shot_3 = {
            resource = 'focus',
            aura = 'barbed_shot_3',

            last = function ()
                local app = state.buff.barbed_shot_3.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_4 = {
            resource = 'focus',
            aura = 'barbed_shot_4',

            last = function ()
                local app = state.buff.barbed_shot_4.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_5 = {
            resource = 'focus',
            aura = 'barbed_shot_5',

            last = function ()
                local app = state.buff.barbed_shot_5.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_6 = {
            resource = 'focus',
            aura = 'barbed_shot_6',

            last = function ()
                local app = state.buff.barbed_shot_6.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },
        
        barbed_shot_7 = {
            resource = 'focus',
            aura = 'barbed_shot_7',

            last = function ()
                local app = state.buff.barbed_shot_7.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },
        
        barbed_shot_8 = {
            resource = 'focus',
            aura = 'barbed_shot_8',

            last = function ()
                local app = state.buff.barbed_shot_8.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
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

        spitting_cobra = 22441, -- 257891
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
        bloodshed = 22295, -- 321530
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        dire_beast_basilisk = 825, -- 205691
        dire_beast_hawk = 824, -- 208652
        dragonscale_armor = 3600, -- 202589
        hiexplosive_trap = 3605, -- 236776
        hunting_pack = 3730, -- 203235
        interlope = 1214, -- 248518
        roar_of_sacrifice = 3612, -- 53480
        scorpid_sting = 3604, -- 202900
        spider_sting = 3603, -- 202914
        survival_tactics = 3599, --  202746
        the_beast_within = 693, -- 212668
        viper_sting = 3602, -- 202797
        wild_protector = 821, -- 204190
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
        
        barbed_shot_6 = {
            id = 284255,
            duration = 8,
            max_stack = 1,
        },
        
        barbed_shot_7 = {
            id = 284257,
            duration = 8,
            max_stack = 1,
        },
        
        barbed_shot_8 = {
            id = 284258,
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

        bloodshed = {
            id = 321538,
            duration = 18,
            max_stack = 1,
            generate = function ( t )
                local name, count, duration, expires, caster, _

                for i = 1, 40 do
                    name, _, count, _, duration, expires, caster = UnitDebuff( "target", 321538 )

                    if not name then break end
                    if name and UnitIsUnit( caster, "pet" ) then break end
                end

                if name then
                    t.name = name
                    t.count = count
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = "player"
                    return
                end

                fr.count = 0
                fr.expires = 0
                fr.applied = 0
                fr.caster = "nobody"
            end,            
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

        dire_beast = {
            id = 281036,
            duration = 8,
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

        hunters_mark = {
            id = 257284,
            duration = 3600,
            type = "Magic",
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

        predators_thirst = {
            id = 264663,
            duration = 3600,
            max_stack = 1,
        },

        primal_fury = {
            id = 264667,
            duration = 40,
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
            max_stack = 3,
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

        
        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "focus",
            
            startsCombat = true,
            texture = 132218,
            
            handler = function ()
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
                    for i = 2, 8 do
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
                if talent.scent_of_blood.enabled then gainCharges( "barbed_shot", 2 ) end
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


        bloodshed = {
            id = 321530,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132176,
            
            handler = function ()
                applyDebuff( "target", "bloodshed" )
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
                applyBuff( "posthaste" )
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

                

        hunters_mark = {
            id = 257284,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236188,
            
            handler = function ()
                applyDebuff( "target", "hunters_mark" )
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

            handler = function ()
            end,
        },


        

        kill_shot = {
            id = 53351,
            cast = 0,
            charges = 1,
            cooldown = 10,
            recharge = 10,
            gcd = "spell",
            
            spend = 10,
            spendType = "focus",
            
            startsCombat = true,
            texture = 236174,
            
            usable = function () return target.health_pct < 20 end,
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


        primal_rage = {
            id = 272678,
            cast = 0,
            cooldown = 360,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136224,
            
            usable = function () return pet.alive and pet.ferocity, "requires a living ferocity pet" end,
            handler = function ()
                applyBuff( "primal_Fury" )
                applyBuff( "bloodlust" )
                applyDebuff( "player", "exhaustion" )
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
            cooldown = 120,
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
            nomounted = true,

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


        tranquilizing_shot = {
            id = 19801,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136020,
            
            usable = function () return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires enrage or magic effect" end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
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


    spec:RegisterPack( "Beast Mastery", 20200614, [[dWeUobqiQiEKsH2evIprLKrjvLtjvvRcjk5vkvnlPIUfsuTls9lKIHPuYXKQSmLIEMOsMMsP6Air2gvK6BsfsJtuPCoPc16evQMhs4EuP2NujhejkwivupKkPAIkLs5IujLYhvkiJejkLtQuqTsrvZuQqCtLsPANiLgkvsPAPujL8uenvKkxfjkvFvPuYyPskoRsPyVe9xqdgvhwyXi8yGjtvxgAZk5ZuHrlfNwYQvkWRLk1Sf52Ky3Q8BfdxuoovKSCuEoHPt56K02rQ67iPXlvW5vQSErfZxkTFvTSNKojPpmus7MBT5wB5092UU3MBFtjPTldLKzbO7WbkjVqbLKoJHWE(2EimKTtsMf7st4L0jjfJkdGsYgZYe5on04OSgvcnyuOrukQPWQ5aSyz0ikfanssc1kzB4tsij9HHsA3CRn3AlNU32192C79OupjzOAndtsswkUUKSP8E8KesspkasYn(CNXqypFBpegY29CkBQNHSp)gFEJzzICNgACuwJkHgmk0ikf1uy1CawSmAeLcGMp)gFEE1dFEVT35Z3CRn36Z)534ZD9M4CGIC)ZVXNt5pNY49O)5U(OEgYEozZyp3MN7XvOMSNhaRM75Psy6p)gFoL)Ck7c85wPGqBG(cFEF0l0p3cMd00wPGqBG(c7)52884ScuzHHphp)ZN1ZXdmQNHm9NFJpNYFoLX7FUVezysqtMkZbkEo9v8CvRsLT75bWQ5EEQeM(ZVXNt5p3y11nAAxJUjeqWmj)q9EEjEU6juZYgMHE9NFJpNYFUR3GGUF(AyphWkdMbmiqLXWZ0sYujmHKojPhxHAYK0jPTNKojjEbrc9sNLKawziRcjPhjuxlniewDo0QzpVT95eQRL2xImmLcIecvchfqRM9822NtOUwAFjYWukisiepw4a1QzsYay1CssqKsWay1CWujmjzQeg8cfusQAvQSDsts7Ms6KK4fej0lDwscyLHSkKKzmKEOdGx3thImeyWzbTgesTs(N32(CRuqOnqFHpNINV5wsYay1CssvbcldvestsBUK0jjXlisOx6SKmawnNKmYr0eSqaxZzWzbZgQitscyLHSkKKGzs(H6Pdrgcm4SGwdcPwjVMHkrDcOdvuiEofpVhLEUlp3kfeAd0x4Z76592ssEHckjJCenbleW1CgCwWSHkYKMK2TlPtsIxqKqV0zjzaSAojziAOpouazroddcgwKKKawziRcjPhjuxlnlYzyqWWIe0JeQRLwn75U88(EUtEo6uQvwg61roIMGfc4Aodoly2qfzpVT95Gzs(H6PJCenbleW1CgCwWSHkY0mujQt88UEEU50pVT95OqGha1ePz8WzbTgeIhQStReBWWEE)p3LN33ZZyi9qhaVUNoeziWGZcAniKAL8pVT95o55OtPwzzOxd2bsJXMRaqIuiSN7YZjuxlDiYqGbNf0Aqi1k51mujQt88UEEh)8(FUlpVVN7KNJcbEaudMZJNa9WuTW1WaOwj2GH9822NtOUwAhQbZxXbNfmYbzJ1OvZEE)p3LN33ZTG5anDdgjRrNbSNtXZZfLEEB7ZDYZrHapaQbZ5XtGEyQw4AyauReBWWEEB7ZDYZTiHNP7UsjKbRty1bmnEbrc9pV)N32(8(EUhjuxlnlYzyqWWIe0JeQRL2puVN32(CRuqOnqFHpNINVPt)8(FUlp3kfeAd0x4Z765998n3(ZPSEEFphmtYpupnyhingBUcajsHW0mujQt889pF7pNINBLccTb6l859)8(LKxOGsYq0qFCOaYICggemSijnjTussNKeVGiHEPZsYay1CsshrcbrkHmbKyMtscyLHSkKKeQRLoeziWGZcAniKAL8AgQe1jEExpV3wpVT95Gzs(H6Pdrgcm4SGwdcPwjVMHkrDIN31Z3oLEEB7ZTsbH2a9f(CkEEVEsYluqjPJiHGiLqMasmZjnjToTKojjEbrc9sNLKbWQ5KKGDG0yS5kaKifctscyLHSkKKeQRLMafwfjivwynA)q9EEB7ZTsbH2a9f(CkEoLKK4AHadEHckjb7aPXyZvairkeM0K02rL0jjXlisOx6SKmawnNKeePemawnhmvctsMkHbVqbLKaVqAsAZnjDss8cIe6LoljbSYqwfsYayf9iepuPqXZP45BkjdGvZjjbrkbdGvZbtLWKKPsyWluqjPWKMK2owsNKeVGiHEPZssaRmKvHKmawrpcXdvku88UEEpjzaSAojjisjyaSAoyQeMKmvcdEHckjbjmOhLM0KKzmemkeHjPtsBpjDsYay1CssHQIYCWm0KK4fej0lDwAsA3usNKeVGiHEPZsYluqjzKJOjyHaUMZGZcMnurMKmawnNKmYr0eSqaxZzWzbZgQitAsAZLKojzaSAojj1HL80J1bzOyU4aOKeVGiHEPZsts72L0jjdGvZjjDOgmFfhCwWihKnwJKeVGiHEPZstslLK0jjdGvZjjvqLHTdolysfuEONHHIqsIxqKqV0zPjP1PL0jjXlisOx6SKmawnNKeSdKgJnxbGePqyssaRmKvHK0jpNfLhI0JNPRJE10HSGiHASdLWep3LN33ZrNsTYYqVM(GvbrcH1z4jkBh0r5iOFsgCeGkLcRohqggaBypVFjjUwiWGxOGssWoqAm2CfasKcHjnjTDujDss8cIe6LoljdGvZjjb7aPXyZvairkeMKeWkdzvijDYZzr5Hi94z66OxnDilisOg7qjmXZD5599CJvx3OP7PBcbemtYpuVNV)5gRUUrtVPUjeqWmj)q9EofpFZN32(C0PuRSm0RPpyvqKqyDgEIY2bDuoc6NKbhbOsPWQZbKHbWg2Z7xsIRfcm4fkOKeSdKgJnxbGePqystsBUjPtsIxqKqV0zjjGvgYQqs6KNZIYdr6XZ01rVA6qwqKqn2HsycjzaSAoj5AaQc0dJCqwziKadfPjPTJL0jjXlisOx6SKmJHGqyqRuqjzpDUKKbWQ5KKHidbgCwqRbHuRKxscyLHSkKKo55roiRmuNXkLibRty1bmHgVGiH(N7YZDYZrHapaQrHapacNf0Aq4AaQI6Calwj0kXgmSN7YZ775OtPwzzOxh5iAcwiGR5m4SGzdvK9822N7KNJoLALLHEnyhingBUcajsHWEE)stsBVTK0jjXlisOx6SKmJHGqyqRuqjzpnLKKbWQ5KKeOWQibPYcRrscyLHSkKKroiRmuNXkLibRty1bmHgVGiH(N7YZDYZrHapaQrHapacNf0Aq4AaQI6Calwj0kXgmSN7YZ775OtPwzzOxh5iAcwiGR5m4SGzdvK9822N7KNJoLALLHEnyhingBUcajsHWEE)stsBVEs6KKbWQ5KKzJvZjjXlisOx6S0KMKeKWGEusNK2Es6KK4fej0lDwsgaRMtssemc0dfnJjjbSYqwfssc11sVy4LZoTA2ZD55eQRLEXWlNDAgQe1jEofUFUdGxReD457ForWiqpu0mg0blaimdz14LKGDGecTG5anHK2Ests7Ms6KK4fej0lDwscyLHSkKKoaETs0HNt5pNqDT0eyimiiHb9OMHkrDIN31Z3sVjLKKbWQ5KKkQjRenJjnjT5ssNKeVGiHEPZsYay1CssIGrGEOOzmjjGvgYQqsUutjidbnbZbcTsbFofp3bWRvIo8CxEoyMKFOEAcuyvKGuzH1OzOsuNqsc2bsi0cMd0esA7jnjTBxsNKmawnNKmeziWGZcAniKAL8ss8cIe6LolnjTussNKeVGiHEPZssaRmKvHKKqDT0HidbgCwqRbHuRKxRM9CxEoH6APjqHvrcsLfwJwn75TTp3kfeAd0x4ZP459OKKmawnNKuyHsg6rPjP1PL0jjXlisOx6SKeWkdzvijbZK8d1thImeyWzbTgesTsEndvI6eqhQOq88UE(MB9822NBrcptphcPwwd0Aqywa6wJxqKq)ZBBFUvki0gOVWNtXZ7rjjzaSAojjbkSksqQSWAKMK2oQKojzaSAojjOPucKfqrZyss8cIe6LolnjT5MKojzaSAojzavuzEKbNfeWgQcjjEbrc9sNLMK2owsNKmawnNKKiySWbkjXlisOx6S0K02BljDss8cIe6LoljbSYqwfsYayf9iepuPqXZP45B)5TTp3jppYbzLHAwKvEidtt414fej0ljdGvZjj7UsjiyuuIZlnjT96jPtsgaRMts6lgcjWqyss8cIe6LolnjT92usNKeVGiHEPZsYay1CssIGrGEOOzmjjGvgYQqssOUw6fdVC2P9d175U88(EoOjyoqbCXcGvZfPN31Z7PZTN32(Cc11stGcRIeKklSgTA2Z7)5TTphmtYpupDiYqGbNf0Aqi1k51mujQt8CkEoH6APxm8YzN2RYcRM75u(ZDa8p3LNh5GSYqDgRuIeSoHvhWeA8cIe6FEB7ZbnbZbkGlwaSAUi98UEEp92FEB7ZTsbH2a9f(CkEEhljb7ajeAbZbAcjT9KMK2E5ssNKmawnNKCnavb6HroiRmesGHIKeVGiHEPZstsBVTlPtsgaRMtsMPYQ1U6CajsHWKK4fej0lDwAsA7rjjDsYay1CssWCa8mwyOhUsHckjXlisOx6S0K02ZPL0jjXlisOx6SKeWkdzvijjuxlndbDNqHaUgga1QzpVT95eQRLMHGUtOqaxddGqWOEgY0claD)CkEEVTKKbWQ5KKwdcvpIr98W1WaO0K02RJkPtsIxqKqV0zjjGvgYQqsg5GSYqnlYkpKHPj8A8cIe6FUlppawrpcXdvku88UE(MsYay1Cssf1KvIMXKMK2E5MKojjEbrc9sNLKawziRcjjyMKFOE6URuccgfL48AgQe1jEExpFnavH2kfeAduj6WZD55998ayf9iepuPqXZP45565TTp3jppYbzLHAwKvEidtt414fej0)8(LKbWQ5KKGHGfqrZystsBVowsNKmawnNKuKvMvNdiyiyHKeVGiHEPZstAssGxiPtsBpjDss8cIe6LoljbSYqwfssWmj)q90eOWQibPYcRrZqLOoXZ7655AljzaSAojzCauySibbrkjnjTBkPtsIxqKqV0zjjGvgYQqscMj5hQNMafwfjivwynAgQe1jEExppxBjjdGvZjjxfdjsZ4LMK2CjPtsIxqKqV0zjjGvgYQqsUgGQ45u881aufALOdp3LN33Zzr5Hi94z6W7fAgQe1jEExpVJ365TTp3jpNfLhI0JNPdVxOXouct8822NhaROhH4HkfkEExpV3Z7xsgaRMtssKMXdNf0AqiEOYoPjPD7s6KK4fej0lDwscyLHSkKKeQRLoeziWGZcAniKAL8A1SN7YZ775wPGqBG(cFExphmtYpupnbYeiR76CO9QSWQ5E((N7vzHvZ9822N33ZTG5anDdgjRrNbSNtXZZfLEEB7ZDYZTiHNP7UsjKbRty1bmnEbrc9pV)N3)ZBBFUvki0gOVWNtXZ7LljzaSAojjbYeiR76CinjTussNKeVGiHEPZssaRmKvHKKqDT0HidbgCwqRbHuRKxRM9CxEEFp3kfeAd0x4Z765Gzs(H6PjsZ4Hlv2oTxLfwn3Z3)CVklSAUN32(8(EUfmhOPBWizn6mG9CkEEUO0ZBBFUtEUfj8mD3vkHmyDcRoGPXlisO)59)8(FEB7ZTsbH2a9f(CkEEpNwsgaRMtssKMXdxQSDstsRtlPtsIxqKqV0zjjGvgYQqssOUw6fdVC2PvZEUlpNqDT0lgE5StZqLOoXZ765oaETs0HN32(CN8Cc11sVy4LZoTAMKmawnNKmvoAmbCdu9ouWZKMK2oQKojjEbrc9sNLKawziRcjjH6APjqHvrcsLfwJwn75U8Cc11shImeyWzbTgesTsETA2ZD55wWCGMUbJK1OZa2ZP455IspVT95998(EoyoHQsqKqD2y1CWzbvpcw5tOhUuz7EEB7ZbZjuvcIeQvpcw5tOhUuz7EE)p3LNBLccTb6l85u8CNU3ZBBFUvki0gOVWNtXZ30PFE)sYay1CsYSXQ5KMK2CtsNKeVGiHEPZssaRmKvHKSVNNXq6HoaEDpDiYqGbNf0Aqi1k5FEB7ZbZK8d1thImeyWzbTgesTsEndvI6epNIN7a4FEB7ZTG5anTvki0gOVWNtXZ3CRN3)ZBBFUtEoke4bqn9LOMdolygYwiWQ50k1nmjzaSAojj1HL80J1bzOyU4aO0K02Xs6KK4fej0lDwscyLHSkKKGzs(H6Pdrgcm4SGwdcPwjVMHkrDINtXZ7T1ZBBFUvki0gOVWN31ZdGvZPDOgmFfhCwWihKnwJgmtYpuVNV)55ARN32(CRuqOnqFHpNINNRTKKbWQ5KKoudMVIdolyKdYgRrAsA7TLKojzaSAojjRYYsiSoOilaOKeVGiHEPZstsBVEs6KKbWQ5KKkOYW2bNfmPckp0ZWqrijXlisOx6S0K02BtjDss8cIe6LoljbSYqwfsslyoqt3GrYA0za75D98CBRN32(Clyoqt3GrYA0za75u4(5BU1ZBBFUfmhOPTsbH2aZagCZTEExppxBjjdGvZjjzyKvNd4kfkOqAstskmjDsA7jPtsIxqKqV0zjjGvgYQqssOUw6fdVC2PvZEUlpNqDT0lgE5StZqLOoXZP45oa(NV)5ebJa9qrZyqhSaGWmKvJ)5TTphmtYpupnbkSksqQSWA0mujQt8CxEEFpFPMsqgcAcMdeALc(CkEUdG)5TTppYbzLH6mwPejyDcRoGj04fej0)CxEoyMKFOE6qKHadolO1GqQvYRzOsuN45u8Cha)Z7xsgaRMtssemc0dfnJjnjTBkPtsIxqKqV0zjjGvgYQqsUgGQ457F(AaQcndDG3ZPSEUdG)5u881aufALOdp3LNtOUwAcuyvKGuzH1O9d175U88(EUtEUFmnyoaEglm0dxPqbHeQStZqLOoXZD55o55bWQ50G5a4zSWqpCLcfuxhCLkhn2Z7)5TTpFPMsqgcAcMdeALc(CkEUdG)5TTp3kfeAd0x4ZP45ussgaRMtscMdGNXcd9WvkuqPjPnxs6KK4fej0lDwscyLHSkKKeQRLoeziWGZcAniKAL8A)q9EUlpVVNdMj5hQNMiyeOhkAgtdAcMdu8CkEEVN32(CN88ihKvgQZyLsKG1jS6aMqJxqKq)Z7xsgaRMtsgImeyWzbTgesTsEPjPD7s6KK4fej0lDwscyLHSkKKeQRLoeziWGZcAniKAL8A1SN7YZjuxlnbkSksqQSWA0QzpVT95wPGqBG(cFofpVhLKKbWQ5KKcluYqpknjTussNKmawnNKmGkQmpYGZccydvHKeVGiHEPZstsRtlPtsIxqKqV0zjjGvgYQqssOUwAcuyvKGuzH1O9d175TTp3kfeAd0x4ZP45ussgaRMtsUgGQa9WihKvgcjWqrAsA7Os6KK4fej0lDwscyLHSkKKeQRLMHGUtOqaxddGA1SN32(Cc11sZqq3juiGRHbqiyupdzAHfGUFofpV3wpVT95wPGqBG(cFofpNssYay1CssRbHQhXOEE4AyauAsAZnjDss8cIe6LoljbSYqwfssls4z65qi1YAGwdcZcq3A8cIe6FUlpNqDT0eOWQibPYcRrZqLOoXZP45oa(N32(Cc11stGcRIeKklSgTFOEp3LNdMj5hQNoeziWGZcAniKAL8AgQe1jEExpVhLEEB7ZTsbH2a9f(CkEEpk989p3bWljdGvZjjjqHvrcsLfwJ0K02Xs6KK4fej0lDwscyLHSkKKroiRmu7JdGWzb9yynAwCD)8UEEVN7YZjuxlTpoacNf0JH1OzOsuN45u8ChaVKmawnNKKiyeOhkAgtAsA7TLKojzaSAojz3vkbbJIsCEjjEbrc9sNLMK2E9K0jjXlisOx6SKeWkdzvijjuxlnbkSksqQSWA0(H69822NBbZbAARuqOnqFHpNINtjjzaSAojjr4aolOXkq3cPjPT3Ms6KKbWQ5KKGMsjqwafnJjjXlisOx6S0K02lxs6KKbWQ5KK(IHqcmeMKeVGiHEPZstsBVTlPtsIxqKqV0zjjGvgYQqsArcptphcPwwd0Aqywa6wJxqKq)ZD55GMG5afWflawnxKEExpVNMspVT95GMG5afWflawnxKEExpVNo3EEB7ZbZK8d1thImeyWzbTgesTsEndvI6epNINtOUw6fdVC2P9QSWQ5EoL)Cha)ZD55roiRmuNXkLibRty1bmHgVGiH(N32(CRuqOnqFHpNIN3XsYay1CssIGrGEOOzmPjPThLK0jjXlisOx6SKeWkdzvijjuxlnbkSksqQSWA0(H69822NBLccTb6l85u88CtsgaRMtsMPYQ1U6CajsHWKMK2EoTKojzaSAojjrAgpCwqRbH4Hk7KK4fej0lDwAsA71rL0jjdGvZjjjcglCGss8cIe6LolnjT9YnjDss8cIe6LoljbSYqwfsY(E(AaQINt5phmc757F(AaQcndDG3ZPSEEFphmtYpupD3vkbbJIsCEndvI6epNYFEVN3)Z765bWQ50DxPeemkkX51GrypVT95Gzs(H6P7UsjiyuuIZRzOsuN45D98EpF)ZDa8p3LNdMj5hQNMafwfjivwynAgQe1jGourH45D981aufARuqOnqLOdpVT95eQRLwbvg2o4SGjvq5HEggkcTA2Z7)5U8CWmj)q90DxPeemkkX51mujQt88UEEVN32(CRuqOnqFHpNINNljzaSAojjyiybu0mM0K02RJL0jjdGvZjjfzLz15acgcwijXlisOx6S0K0U5ws6KK4fej0lDwscyLHSkKKeQRLEXWlNDAVklSAUNt5p3bW)8UE(snLGme0emhi0kfusgaRMtssemc0dfnJjnPjjvTkv2ojDsA7jPtsgaRMtscg1Zqgu0mMKeVGiHEPZsts7Ms6KKbWQ5KKcKHxz7GEvHjjXlisOx6S0K0MljDsYay1Cssr2WqiinQEjjEbrc9sNLMK2TlPtsgaRMtskMXAQZbKAyitsIxqKqV0zPjPLss6KKbWQ5KKI5kaKifctsIxqKqV0zPjP1PL0jjdGvZjjp0Aqgu0mGULK4fej0lDwAsA7Os6KKbWQ5KKGMAdkb0yX5uQvQSDss8cIe6LolnjT5MKojzaSAojPiRyLbfndOBjjEbrc9sNLMK2owsNKmawnNK8ctLHcOdwaqjjEbrc9sNLM0KMKKEKjQ5K0U5wBU1wBFtkjjPgSRohcj52IY4Ar7gM2nuU)8Ntxd(8sjBy2Zxd75UYJRqnzU65m0Pulg6FUyuWNhQ2Oeg6FoOjohOq)57i1HpF75(ZD95Ohzg6FURmwDDJM21ObZK8d1Zvp3MN7kWmj)q90Ugx98(61H(1F(p)2IY4Ar7gM2nuU)8Ntxd(8sjBy2Zxd75UcKWGE0vpNHoLAXq)ZfJc(8q1gLWq)ZbnX5af6pFhPo859Y9N76ZrpYm0)CxLHM21O3gTw7QNBZZD12O1Ax98(2Sd9R)8DK6WNVzU)CxFo6rMH(N7Qm00Ug92O1Ax9CBEUR2gTw7QN3xVo0V(Z3rQdFEVnZ9N76ZrpYm0)CxLHM21O3gTw7QNBZZD12O1Ax98(2Sd9R)8F(TfLX1I2nmTBOC)5pNUg85Ls2WSNVg2ZDfWlC1ZzOtPwm0)CXOGppuTrjm0)CqtCoqH(Z3rQdFUtN7p31NJEKzO)5UkdnTRrVnAT2vp3MN7QTrR1U659LRo0V(Z)53wugxlA3W0UHY9N)C6AWNxkzdZE(Ayp3vcZvpNHoLAXq)ZfJc(8q1gLWq)ZbnX5af6pFhPo859Y9N76ZrpYm0)CxLHM21O3gTw7QNBZZD12O1Ax98(2Sd9R)8DK6WN3B75(ZD95Ohzg6FURYqt7A0BJwRD1ZT55UAB0ATREEF96q)6pFhPo85BUvU)CxFo6rMH(N7Qm00Ug92O1Ax9CBEUR2gTw7QN3xVo0V(Z)53WkzdZq)ZD6NhaRM75Psyc9NxsMXMvLqj5gFUZyiSNVThcdz7EoLn1Zq2NFJpVXSmrUtdnokRrLqdgfAeLIAkSAoalwgnIsbqZNFJppV6HpV32785BU1MB95)8B85UEtCoqrU)534ZP8Ntz8E0)CxFupdzpNSzSNBZZ94kut2ZdGvZ98ujm9NFJpNYFoLDb(CRuqOnqFHpVp6f6NBbZbAARuqOnqFH9)CBEECwbQSWWNJN)5Z654bg1ZqM(ZVXNt5pNY49p3xImmjOjtL5afpN(kEUQvPY298ay1Cppvct)534ZP8NBS66gnTRr3eciyMKFOEpVepx9eQzzdZqV(ZVXNt5p31Bqq3pFnSNdyLbZageOYy4z6p)NFJp31whqGQH(NtGRHHphmkeH9Cc0rDc9ZPmaaMzINFZr5nbtzPMEEaSAoXZNlTt)534ZdGvZj0zmemkeH5ELcr3F(n(8ay1CcDgdbJcry7DttO6qbplSAUp)gFEaSAoHoJHGrHiS9UPznJ)ZhaRMtOZyiyuicBVBAeQkkZbZq7ZVXNtErMOzSNZIY)Cc11c9pxyHjEobUgg(CWOqe2Zjqh1jEEC(NNXqkpBmRohpVep3phQ)8B85bWQ5e6mgcgfIW27MgXfzIMXGclmXNpawnNqNXqWOqe2E30OkqyzOsNxOGUJCenbleW1CgCwWSHkY(8bWQ5e6mgcgfIW27MgQdl5PhRdYqXCXbWpFaSAoHoJHGrHiS9UPXHAW8vCWzbJCq2ynF(ay1CcDgdbJcry7DtJcQmSDWzbtQGYd9mmueF(ay1CcDgdbJcry7DtJQaHLHkDIRfcm4fkOBWoqAm2CfasKcH1zTC7ewuEispEMUo6vthYcIeQXouct4sFOtPwzzOxtFWQGiHW6m8eLTd6OCe0pjdocqLsHvNdiddGnS()8bWQ5e6mgcgfIW27Mgvbcldv6exleyWluq3GDG0yS5kaKifcRZA52jSO8qKE8mDD0RMoKfejuJDOeMWL(mwDDJMUNUjeqWmj)q92BS66gn9M6MqabZK8d1JInBBrNsTYYqVM(GvbrcH1z4jkBh0r5iOFsgCeGkLcRohqggaBy9)5dGvZj0zmemkeHT3nnRbOkqpmYbzLHqcmu6SwUDclkpePhptxh9QPdzbrc1yhkHj(8B85ug)gOkmXZTg85Evwy1Cppo)ZbZK8d175Z65ugrgcSNpRNBn4Z3wvY)848p31oRuI0Z3WNWQdyINtS75wd(CVklSAUNpRNh3ZvVMqyO)5BixFB75uBW75wdUZvm85Qc0)8mgcgfIW0p3zeeQc85ugrgcSNpRNBn4Z3wvY)Cg6vbO45BixFB75e7E(MBTLIOZNBnL45L4590565cemNxOF(NpawnNqNXqWOqe2E30eImeyWzbTgesTs(oZyiieg0kf0DpDU6SwUDsKdYkd1zSsjsW6ewDatOXlisO3fNGcbEauJcbEaeolO1GW1auf15awSsOvInyyU0h6uQvwg61roIMGfc4Aodoly2qfzTTobDk1kld9AWoqAm2CfasKcH1)NFJpNY43avHjEU1Gp3RYcRM75X5FoyMKFOEpFwp3zuyvKE(2IfwZZJZ)CkBro4ZN1ZDTch4Zj29CRbFUxLfwn3ZN1ZJ75Qxtim0)8nKRVT9CQn49CRb35kg(Cvb6FEgdbJcry6pFaSAoHoJHGrHiS9UPHafwfjivwynDMXqqimOvkO7EAk1zTCh5GSYqDgRuIeSoHvhWeA8cIe6DXjOqGha1OqGhaHZcAniCnavrDoGfReALydgMl9HoLALLHEDKJOjyHaUMZGZcMnurwBRtqNsTYYqVgSdKgJnxbGePqy9)5dGvZj0zmemkeHT3nnzJvZ95)8bWQ5eAvRsLTZnyupdzqrZyF(ay1CcTQvPY2T3nncKHxz7GEvH95dGvZj0QwLkB3E30iYggcbPr1)5dGvZj0QwLkB3E30iMXAQZbKAyi7ZhaRMtOvTkv2U9UPrmxbGePqyF(ay1CcTQvPY2T3nnhAnidkAgq3F(ay1CcTQvPY2T3nnGMAdkb0yX5uQvQSDF(ay1CcTQvPY2T3nnISIvgu0mGU)8bWQ5eAvRsLTBVBAUWuzOa6Gfa8Z)534ZDT1beOAO)5i9iB3ZTsbFU1Gppa2WEEjEEqFuPGiH6pFaSAoHBqKsWay1CWujSoVqbDRAvQSDDwl3EKqDT0Gqy15qRM12sOUwAFjYWukisiujCuaTAwBlH6AP9LidtPGiHq8yHduRM95dGvZj27MgvbcldveDwl3zmKEOdGx3thImeyWzbTgesTs(2wRuqOnqFHuS5wF(ay1CI9UPrvGWYqLoVqbDh5iAcwiGR5m4SGzdvK1zTCdMj5hQNoeziWGZcAniKAL8AgQe1jGourHGIEuYfRuqOnqFHD1BRpFaSAoXE30OkqyzOsNxOGUdrd9XHcilYzyqWWIuN1YThjuxlnlYzyqWWIe0JeQRLwnZL(Cc6uQvwg61roIMGfc4Aodoly2qfzTTgRUUrth5iAcwiGR5m4SGzdvKPbZK8d1tZqLOorx5Mt32IcbEautKMXdNf0AqiEOYoTsSbdRFx6lJH0dDa86E6qKHadolO1GqQvY326e0PuRSm0Rb7aPXyZvairkeMleQRLoeziWGZcAniKAL8AgQe1j6QJ73L(Ccke4bqnyopEc0dt1cxddGALydgwBlH6APDOgmFfhCwWihKnwJwnRFx6ZcMd00nyKSgDgWOixuQT1jOqGha1G584jqpmvlCnmaQvInyyTToXIeEMU7kLqgSoHvhW04fej03FBBFEKqDT0SiNHbbdlsqpsOUwA)q9ABTsbH2a9fsXMoD)UyLccTb6lSR(2C7uw9bMj5hQNgSdKgJnxbGePqyAgQe1j2VDkSsbH2a9f2F)F(ay1CI9UPrvGWYqLoVqbD7isiisjKjGeZCDwl3eQRLoeziWGZcAniKAL8AgQe1j6Q3wTTGzs(H6Pdrgcm4SGwdcPwjVMHkrDIU2oLABTsbH2a9fsrVEF(ay1CI9UPrvGWYqLoX1cbg8cf0nyhingBUcajsHW6SwUjuxlnbkSksqQSWA0(H612ALccTb6lKck95dGvZj27MgqKsWay1CWujSoVqbDd8IpFaSAoXE30aIucgaRMdMkH15fkOBH1zTChaROhH4HkfkOyZpFaSAoXE30aIucgaRMdMkH15fkOBqcd6XoRL7ayf9iepuPqrx9(8F(ay1CcnWlChhafglsqqKsDwl3Gzs(H6PjqHvrcsLfwJMHkrDIUY1wF(ay1CcnWl27MMvXqI0m(oRLBWmj)q90eOWQibPYcRrZqLOorx5ARpFaSAoHg4f7DtdrAgpCwqRbH4Hk76SwUxdqvqXAaQcTs0bx6JfLhI0JNPdVxOzOsuNORoER2wNWIYdr6XZ0H3l0yhkHjABdGv0Jq8qLcfD1R)pFaSAoHg4f7DtdbYeiR76C0zTCtOUw6qKHadolO1GqQvYRvZCPpRuqOnqFHDbMj5hQNMazcK1DDo0Evwy1C79QSWQ5AB7ZcMd00nyKSgDgWOixuQT1jwKWZ0DxPeYG1jS6aMgVGiH((7VT1kfeAd0xif9Y1NpawnNqd8I9UPHinJhUuz76SwUjuxlDiYqGbNf0Aqi1k51QzU0Nvki0gOVWUaZK8d1ttKMXdxQSDAVklSAU9Evwy1CTT9zbZbA6gmswJodyuKlk126els4z6URuczW6ewDatJxqKqF)932ALccTb6lKIEo9NpawnNqd8I9UPjvoAmbCdu9ouWZ6SwUZqtdcttOUw6fdVC2PvZCjdnnimnH6APxm8YzNMHkrDIUCa8ALOdTTojdnnimnH6APxm8YzNwn7ZhaRMtObEXE30KnwnxN1YnH6APjqHvrcsLfwJwnZfc11shImeyWzbTgesTsETAMlwWCGMUbJK1OZagf5IsTT91hyoHQsqKqD2y1CWzbvpcw5tOhUuz7ABbZjuvcIeQvpcw5tOhUuz763fRuqOnqFHu409ABTsbH2a9fsXMoD)F(ay1CcnWl27MgQdl5PhRdYqXCXbWoRL7(Yyi9qhaVUNoeziWGZcAniKAL8TTGzs(H6Pdrgcm4SGwdcPwjVMHkrDckCa8TTwWCGM2kfeAd0xifBUv)TTobfc8aOM(suZbNfmdzley1CAL6g2NpawnNqd8I9UPXHAW8vCWzbJCq2ynDwl3Gzs(H6Pdrgcm4SGwdcPwjVMHkrDck6TvBRvki0gOVWUcGvZPDOgmFfhCwWihKnwJgmtYpuV95AR2wRuqOnqFHuKRT(8bWQ5eAGxS3nnSkllHW6GISaGF(ay1CcnWl27Mgfuzy7GZcMubLh6zyOi(8B85bWQ5eAGxS3nneHd4SGgRaDl(8bWQ5eAGxS3nnmmYQZbCLcfu0zTCBbZbA6gmswJodyDLBB12AbZbA6gmswJodyu4EZTABTG5anTvki0gygWGBUvx5ARp)NpawnNqdsyqp6MiyeOhkAgRtWoqcHwWCGMWDVoRL7m00GW0eQRLEXWlNDA1mxYqtdcttOUw6fdVC2PzOsuNGc3oaETs0H9ebJa9qrZyqhSaGWmKvJ)ZhaRMtObjmOh37Mgf1KvIMX6SwUDa8ALOduEgAAqyAc11stGHWGGeg0JAgQe1j6Al9Mu6ZhaRMtObjmOh37MgIGrGEOOzSob7ajeAbZbAc396SwUxQPeKHGMG5aHwPGu4a41krhCbmtYpupnbkSksqQSWA0mujQt85dGvZj0Geg0J7DttiYqGbNf0Aqi1k5)8bWQ5eAqcd6X9UPryHsg6XoRLBc11shImeyWzbTgesTsETAMleQRLMafwfjivwynA1S2wRuqOnqFHu0JsF(ay1CcniHb94E30qGcRIeKklSMoRLBWmj)q90HidbgCwqRbHuRKxZqLOob0HkkeDT5wTTwKWZ0ZHqQL1aTgeMfGU14fej032ALccTb6lKIEu6ZhaRMtObjmOh37MgqtPeilGIMX(8bWQ5eAqcd6X9UPjGkQmpYGZccydvXNpawnNqdsyqpU3nnebJfoWpFaSAoHgKWGECVBA6UsjiyuuIZ3zTChaROhH4HkfkOy7TTojYbzLHAwKvEidtt414fej0)5dGvZj0Geg0J7DtJVyiKadH95dGvZj0Geg0J7DtdrWiqpu0mwNGDGecTG5anH7EDwl3zOPbHPjuxl9IHxo70(H65sFGMG5afWflawnxK6QNo3ABjuxlnbkSksqQSWA0Qz932cMj5hQNoeziWGZcAniKAL8AgQe1jOidnnimnH6APxm8YzN2RYcRMJYDa8Ue5GSYqDgRuIeSoHvhWeA8cIe6BBbnbZbkGlwaSAUi1vp92BBTsbH2a9fsrh)5dGvZj0Geg0J7DtZAaQc0dJCqwziKadLpFaSAoHgKWGECVBAYuz1AxDoGePqyF(ay1CcniHb94E30aMdGNXcd9WvkuWpFaSAoHgKWGECVBASgeQEeJ65HRHbWoRLBc11sZqq3juiGRHbqTAwBlH6APziO7ekeW1WaiemQNHmTWcq3u0BRpFaSAoHgKWGECVBAuutwjAgRZA5oYbzLHAwKvEidtt414fej07saSIEeIhQuOORn)8bWQ5eAqcd6X9UPbmeSakAgRZA5gmtYpupD3vkbbJIsCEndvI6eDTgGQqBLccTbQeDWL(cGv0Jq8qLcfuKR2wNe5GSYqnlYkpKHPj8A8cIe67)ZhaRMtObjmOh37MgrwzwDoGGHGfF(pFaSAoHwyUjcgb6HIMX6SwUZqtdcttOUw6fdVC2PvZCjdnnimnH6APxm8YzNMHkrDckCa87jcgb6HIMXGoybaHziRgFBlyMKFOEAcuyvKGuzH1OzOsuNWL(wQPeKHGMG5aHwPGu4a4BBJCqwzOoJvkrcwNWQdycnEbrc9UaMj5hQNoeziWGZcAniKAL8AgQe1jOWbW3)NpawnNqlS9UPbmhapJfg6HRuOGDwl3RbOk2VgGQqZqh4rz5a4PynavHwj6GleQRLMafwfjivwynA)q9CPpN4htdMdGNXcd9WvkuqiHk70mujQt4ItcGvZPbZbWZyHHE4kfkOUo4kvoAS(BBxQPeKHGMG5aHwPGu4a4BBTsbH2a9fsbL(8bWQ5eAHT3nnHidbgCwqRbHuRKVZA5MqDT0HidbgCwqRbHuRKx7hQNl9bMj5hQNMiyeOhkAgtdAcMduqrV2wNe5GSYqDgRuIeSoHvhWeA8cIe67)ZhaRMtOf2E30iSqjd9yN1YnH6APdrgcm4SGwdcPwjVwnZfc11stGcRIeKklSgTAwBRvki0gOVqk6rPpFaSAoHwy7DttavuzEKbNfeWgQIpFaSAoHwy7DtZAaQc0dJCqwziKadLoRLBc11stGcRIeKklSgTFOETTwPGqBG(cPGsF(ay1CcTW27MgRbHQhXOEE4AyaSZA5MqDT0me0Dcfc4AyauRM12sOUwAgc6oHcbCnmacbJ6zitlSa0nf92QT1kfeAd0xifu6ZhaRMtOf2E30qGcRIeKklSMoRLBls4z65qi1YAGwdcZcq3A8cIe6DHqDT0eOWQibPYcRrZqLOobfoa(2wc11stGcRIeKklSgTFOEUaMj5hQNoeziWGZcAniKAL8AgQe1j6QhLABTsbH2a9fsrpkT3bW)5dGvZj0cBVBAicgb6HIMX6SwUJCqwzO2hhaHZc6XWA0S46UREUqOUwAFCaeolOhdRrZqLOobfoa(pFaSAoHwy7Dtt3vkbbJIsC(pFaSAoHwy7Dtdr4aolOXkq3IoRLBc11stGcRIeKklSgTFOETTwWCGM2kfeAd0xifu6ZhaRMtOf2E30aAkLazbu0m2NpawnNqlS9UPXxmesGHW(8bWQ5eAHT3nnebJa9qrZyDwl3wKWZ0ZHqQL1aTgeMfGU14fej07cOjyoqbCXcGvZfPU6PPuBlOjyoqbCXcGvZfPU6PZT2wWmj)q90HidbgCwqRbHuRKxZqLOobfzOPbHPjuxl9IHxo70Evwy1CuUdG3LihKvgQZyLsKG1jS6aMqJxqKqFBRvki0gOVqk64pFaSAoHwy7DttMkRw7QZbKifcRZA5MqDT0eOWQibPYcRr7hQxBRvki0gOVqkYTpFaSAoHwy7DtdrAgpCwqRbH4Hk7(8bWQ5eAHT3nnebJfoWpFaSAoHwy7Dtdyiybu0mwN1YDFRbOkOCWiS9RbOk0m0bEuw9bMj5hQNU7kLGGrrjoVMHkrDckVx)DfaRMt3DLsqWOOeNxdgH12cMj5hQNU7kLGGrrjoVMHkrDIU6T3bW7cyMKFOEAcuyvKGuzH1OzOsuNa6qffIUwdqvOTsbH2avIo02sOUwAfuzy7GZcMubLh6zyOi0Qz97cyMKFOE6URuccgfL48AgQe1j6QxBRvki0gOVqkY1NpawnNqlS9UPrKvMvNdiyiyXNpawnNqlS9UPHiyeOhkAgRZA5odnnimnH6APxm8YzN2RYcRMJYDa8DTutjidbnbZbcTsbLKImeiPDtkLlPjnPe]] )


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
