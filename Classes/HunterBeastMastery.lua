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
        primal_instincts = {
            id = 279810,
            duration = 20,
            max_stack = 1
        }
    } )

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
            cooldown = 120,
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
                return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires enrage or magic debuff"
            end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
            end,
        },

        
    } )


    spec:RegisterPack( "Beast Mastery", 20190211.1332, [[d000PaqikQ0JKIYMKk5tkbJIi4uquTkPOIEfeAwkrUfff7IWVKcdJi0XKkwMiYZGiMMsOCniOTjfv9nLqLXrrvDoikToLqMNiQ7rr2NsuheIIfQK8qisMOsOQlkfvQnkfv4JerPrsefNKisTsk0mjIKBser7uQQHcrklLIQ8uLAQsvUQuujFLIkmwis1zjIQ9QYFf1GrCyHfdYJHAYu1LjTzq9zry0sPtlz1er41qGztLBdPDd8BvnCr64uurlNsphPPJ66e12LI8Dky8uu68kPwVuPMprA)k(6C9UTpy96NKe7GSsmPoDeDqcsssIl2T51P6TtdmcIe6TbbQE7vAq5HijdkR213onw7(WF9Un9LTy92TmNsxuJgjkUvgsGF0g0cv2fC9aSnG5g0cf3aY9qnGGdZ41MAKAF4YP0ginRAEr5PnqAMxwYidy1MxPbLZsYGYQDTGwO4BdjxowsdoOB7dwV(jjXoiRetQthrhKKKetcj3oK523E7DHIu3UT8EfCq32Ru8TB2qwPbLhIKmOSAxpejJmGv7ySzdPL5u6IA0irXTYqc8J2GwOYUGRhGTbm3GwO4gqUhQbeCygV2uJu7dxoL2aPzvZlkpTbsZ8YsgzaR28knOCwsguwTRf0cfpgB2qAouiRCyxpKoDwAijjXoi7qmZq6GKfLKehJJXMneKQnaju6IgJnBiMziiJ3R(HGuVmGv7q2Tppe(hIxHdzhpKaZ1dgIROSym2SHyMH0Cr1HWfQM5p7lDisOjQyiCytOSGlunZF2xkYhc)djaCHR0G1HOa)qE4HOa8ldy1kgJnBiMziiJ3peFrtvhTrQSnHshstvmezUCfVEibMRhmexrzXTDfLPxVB7v4q2XxVRFNR3Tvqa5u)T62yBXQTIB7vizyyboOCbsiKthIuPdXRqYWWcFrtvNlGCAgnsuyHC6qKkDiEfsggw4lAQ6CbKtZkWgjuHC6Tdmxp424W5YbMRhKDfLVTROCgeO6TL5Yv86JV(jD9UDG56b3wMQ5Ivu6Tvqa5u)T64RpsUE3wbbKt93QBhyUEWTXHZLdmxpi7kkFBxr5miq1BJ90JV(l2172kiGCQ)wDBSTy1wXTdmxnPzfOOLshsYdjPBhyUEWTXHZLdmxpi7kkFBxr5miq1Bt5JV(i86DBfeqo1FRUn2wSAR42bMRM0Scu0sPdz5H052bMRhCBC4C5aZ1dYUIY32vuodcu92yNgnPhF8TtTk(rHc(6D97C9UTcciN6VvhF9t66DBfeqo1FRo(6JKR3Tvqa5u)T64R)ID9UDG56b3MkJI(GCQY3wbbKt93QJV(i86DBfeqo1FRo(638xVBhyUEWTtFUEWTvqa5u)T64R)I76DBfeqo1FRUDQvXbLZCHQ3UJOZTdmxp42bnvXC(HZCRMnuo)TX2IvBf32Chs0TAlwfP2cnC5cq5cGzQqbbKt9hF9n)R3Tvqa5u)T62PwfhuoZfQE7oceE7aZ1dUnKs5kCzd2GBVn2wSAR42r3QTyvKAl0WLlaLlaMPcfeqo1F8X3g70Oj96D97C9UTcciN6Vv3gBlwTvCBizyybSvbDVwiNoKUgcKmmSa2QGUxlSkAua6qs20qsG9c0WS3oWC9GBdfwi1NPTpF81pPR3Tvqa5u)T62yBXQTIBNa7fOHzhIzgcKmmSasdkNXonAsfwfnkaDilpejkscH3oWC9GBJk74I2(8XxFKC9UTcciN6Vv3gBlwTvCByzNlBvCBytOzUq1HK8qsG9c0WSdPRHG)35FdabKs5kCzd2GBfwfnka92bMRhCBOWcP(mT95JV(l2172bMRhC7GMQyo)WzUvZgkN)2kiGCQ)wD81hHxVBRGaYP(B1TX2IvBf3gsggwe0ufZ5hoZTA2q58c50H01qGKHHfqkLRWLnydUviNoePshcxOAM)SV0HK8q6GWBhyUEWTPCGMQE94RFZF9UTcciN6Vv3gBlwTvCB8)o)BaicAQI58dN5wnBOCEHvrJcqhYYdjjjoePshcxOAM)SV0HK8q6GWBhyUEWTHukxHlBWgC7Xx)f3172bMRhCBCBHgQnY02NVTcciN6VvhF9n)R3Tdmxp42rgv26vB(HZy7BGEBfeqo1FRo(6JSxVBhyUEWTHcRnsO3wbbKt93QJV(DK4172bMRhCBeuoxg)OObWFBfeqo1FRo(63PZ172bMRhCBFz1mKgu(2kiGCQ)wD81VtsxVBRGaYP(B1TX2IvBf3gsggwaBvq3Rf(3ayiDnejmeCBytO0mSnWC9GWnKLhshH5pePshcKmmSasPCfUSbBWTc50HG8Hiv6qW)78VbGiOPkMZpCMB1SHY5fwfnkaDijpeizyybSvbDVw4LTbxpyiMzijW(H01qIUvBXQi1wOHlxakxamtfkiGCQFisLoeUq1m)zFPdj5HGS3oWC9GBdfwi1NPTpF81VdsUE3wbbKt93QBJTfR2kUn(FN)naeiOCUm(rrdGxyv0Oa0HS8qGFSmvWfQM5pJgM92bMRhCB8dzJmT95JV(DwSR3Tdmxp4200I5cKiJFiBCBfeqo1FRo(4BJ90R31VZ172kiGCQ)wDBSTy1wXTX)78VbGasPCfUSbBWTcRIgfGoKLhcsK4Tdmxp42baRu2gUmoCUJV(jD9UTcciN6Vv3gBlwTvCB8)o)BaiGukxHlBWgCRWQOrbOdz5HGejE7aZ1dUnCzvi3)(JV(i56DBfeqo1FRUn2wSAR42qYWWIGMQyo)WzUvZgkNxiNoKUgIegcxOAM)SV0HS8qW)78VbGasTu1IGcKq4LTbxpyiioeVSn46bdrQ0HiHHWHnHYIwnCCRifZdj5HGeeoePshI5oeoCkGfiOCo1MlaLlaMfkiGCQFiiFiiFisLoeUq1m)zFPdj5H0bj3oWC9GBdPwQArqbsC81FXUE3wbbKt93QBJTfR2kUnKmmSiOPkMZpCMB1SHY5fYPdPRHiHHWfQM5p7lDilpe8)o)BaiGC)7ZWY21cVSn46bdbXH4LTbxpyisLoejmeoSjuw0QHJBfPyEijpeKGWHiv6qm3HWHtbSabLZP2CbOCbWSqbbKt9db5db5drQ0HWfQM5p7lDijpKon)Tdmxp42qU)9zyz76JV(i86DBfeqo1FRUn2wSAR42qYWWcyRc6ETqoDiDneizyybSvbDVwyv0Oa0HS8qsG9c0WSdrQ0HyUdbsggwaBvq3RfYP3oWC9GB7QeTmnljK9jqvaF81V5VE3wbbKt93QBJTfR2kUnKmmSasPCfUSbBWTc50H01qGKHHfbnvXC(HZCRMnuoVqoDiDnejmeoSjuw0QHJBfPyEijpeKGWHiv6qm3HWHtbSabLZP2CbOCbWSqbbKt9db5drQ0HWfQM5p7lDijpKKq4Tdmxp42Ppxp44JVnLVEx)oxVBRGaYP(B1TX2IvBf3gsggwaBvq3RfYPdPRHajddlGTkO71cRIgfGoKKnnKeyVanm7qKkDiWYox2Q42WMqZCHQdj5HKa7fOHzhsxdb)VZ)gaciLYv4YgSb3kSkAua6qKkDir3QTyvKAl0WLlaLlaMPcfeqo1pKUgc(FN)naebnvXC(HZCRMnuoVWQOrbOdj5HKa7VDG56b3gkSqQptBF(4RFsxVBhyUEWTdAQI58dN5wnBOC(BRGaYP(B1XxFKC9UDG56b3oYOYwVAZpCgBFd0BRGaYP(B1Xx)f76DBfeqo1FRUn2wSAR42qYWWIGMQyo)WzUvZgkNxiNoKUgcKmmSasPCfUSbBWTc50Hiv6q4cvZ8N9LoKKhsheE7aZ1dUnLd0u1RhF9r4172kiGCQ)wDBSTy1wXTX)78VbGiOPkMZpCMB1SHY5fwfnkaDilpKKK4qKkDiCHQz(Z(shsYdPdcVDG56b3gsPCfUSbBWThF9B(R3Tdmxp42iOCUm(rrdG)2kiGCQ)wD81FXD9UDG56b3g3wOHAJmT95BRGaYP(B1XxFZ)6D7aZ1dUTVSAgsdkFBfeqo1FRo(6JSxVBRGaYP(B1TX2IvBf3gsggwaBvq3Rf(3ayiDnejmeCBytO0mSnWC9GWnKLhshH5pePshcKmmSasPCfUSbBWTc50HG8Hiv6qW)78VbGiOPkMZpCMB1SHY5fwfnkaDijpeizyybSvbDVw4LTbxpyiMzijW(H01qIUvBXQi1wOHlxakxamtfkiGCQFisLoeUq1m)zFPdj5HGS3oWC9GBdfwi1NPTpF81VJeVE3oWC9GBdfwBKqVTcciN6VvhF97056DBfeqo1FRUn2wSAR42syiWpwMoeZme8t5HG4qGFSmvy1ekyinNdrcdb)VZ)gaceuoxg)OObWlSkAua6qmZq6meKpKLhsG56bceuoxg)OObWlWpLhIuPdb)VZ)gaceuoxg)OObWlSkAua6qwEiDgcIdjb2peKpKUgc(FN)naeiOCUm(rrdGxyv0Oa0HS8q6C7aZ1dUn(HSrM2(8Xx)ojD9UDG56b3MMwmxGez8dzJBRGaYP(B1XhFBzUCfV(6D97C9UDG56b3g)YawTzA7Z3wbbKt93QJV(jD9UDG56b3MQwfu86SxMY3wbbKt93QJV(i56D7aZ1dUnn9TAg7Ez)Tvqa5u)T64R)ID9UDG56b3M(p3wGezdbR2BRGaYP(B1XxFeE9UDG56b3M(GcNHCbLVTcciN6VvhF9B(R3Tdmxp42aLBvBM2(yeCBfeqo1FRo(6V4UE3oWC9GBJBljrrZSnaMt5Yv86BRGaYP(B1XxFZ)6D7aZ1dUnnTSfNPTpgb3wbbKt93QJV(i7172bMRhCBqWYwLMtydSEBfeqo1FRo(4JVDtQLwp46NKe7GSsmjj2rKusi08VTHWckqc6TnhiJ51xs3xYUOHmKET6qk003Ydb(TdzbStJM0fgIvnNYLv9dH(O6qcz(rdw9db3gGekvmgLufqhsNfneK6bnPww9dzHuLfiDHKleIfgc)dzbjxielmejKKzrUymkPkGoKKw0qqQh0KAz1pKfsvwG0fsUqiwyi8pKfKCHqSWqKqhZICXyusvaDiDsArdbPEqtQLv)qwivzbsxi5cHyHHW)qwqYfcXcdrcjzwKlgJJrZbYyE9L09LSlAidPxRoKcn9T8qGF7qwa7PlmeRAoLlR6hc9r1HeY8JgS6hcUnajuQymkPkGoeeUOHGupOj1YQFilKQSaPlKCHqSWq4Fili5cHyHHibKywKlgJJrZbYyE9L09LSlAidPxRoKcn9T8qGF7qwGYlmeRAoLlR6hc9r1HeY8JgS6hcUnajuQymkPkGoKolAii1dAsTS6hYcPklq6cjxielme(hYcsUqiwyisijZICXyusvaDii7Igcs9GMulR(HSqQYcKUqYfcXcdH)HSGKleIfgIesYSixmghJsA003YQFin)qcmxpyiUIYuXy820ufF9tcHi52P2hUC6TB2qwPbLhIKmOSAxpejJmGv7ySzdPL5u6IA0irXTYqc8J2GwOYUGRhGTbm3GwO4gqUhQbeCygV2uJu7dxoL2aPzvZlkpTbsZ8YsgzaR28knOCwsguwTRf0cfpgB2qAouiRCyxpKoDwAijjXoi7qmZq6GKfLKehJJXMneKQnaju6IgJnBiMziiJ3R(HGuVmGv7q2Tppe(hIxHdzhpKaZ1dgIROSym2SHyMH0Cr1HWfQM5p7lDisOjQyiCytOSGlunZF2xkYhc)djaCHR0G1HOa)qE4HOa8ldy1kgJnBiMziiJ3peFrtvhTrQSnHshstvmezUCfVEibMRhmexrzXyCm2SH0CBwflZQFiqk8B1HGFuOGhcKMOauXqqgmwtz6qapWmTHffw2nKaZ1dOd5bU1IXyG56burQvXpkuWMGDbfbJXaZ1dOIuRIFuOGr0uJqobQc4GRhmgdmxpGksTk(rHcgrtnG)3pgdmxpGksTk(rHcgrtnOYOOpiNQ8ySzdzdIuA7ZdXgLFiqYWWQFiuoy6qGu43Qdb)OqbpeinrbOdja(HKAvZK(mxGedPOdX)avmgdmxpGksTk(rHcgrtnOGiL2(CMYbthJbMRhqfPwf)OqbJOPgPpxpym2SHGmEjHmLPdHB1H4LTbxpyibWpe8)o)BamKhEiidnvX8qE4HWT6qmhLZpKa4hcsZwOHBisAaLlaMPdbA9q4wDiEzBW1dgYdpKamezqBqz1pejlsT4hIHwfmeUvxVGvhImv9dj1Q4hfkyXqqg6qqMNnhdPnOdjgshbsOdrYIul(Hea)qcyyfZ0HumvDWdHBl6qk6q6i6qfJXaZ1dOIuRIFuOGr0uJGMQyo)WzUvZgkNFPuRIdkN5cvn1r0zPc2K5gDR2IvrQTqdxUauUayMkuqa5u)ySzdbz8sczkthc3QdXlBdUEWqcGFi4)D(3ayip8qwPuUc3qmh2GBhsa8drYeDRd5HhI5fj0HaTEiCRoeVSn46bd5HhsagImOnOS6hIKfPw8dXqRcgc3QRxWQdrMQ(HKAv8JcfSymgyUEavKAv8JcfmIMAaPuUcx2Gn42LsTkoOCMlu1uhbcxQGnfDR2IvrQTqdxUauUayMkuqa5u)yCmgyUEaviZLR41MWVmGvBM2(8ymWC9aQqMlxXRr0udQAvqXRZEzkpgdmxpGkK5Yv8Aen1GM(wnJDVSFmgyUEaviZLR41iAQb9FUTajYgcwTJXaZ1dOczUCfVgrtnOpOWzixq5XyG56buHmxUIxJOPgaLBvBM2(yemgdmxpGkK5Yv8Aen1a3wsIIMzBamNYLR41JXaZ1dOczUCfVgrtnOPLT4mT9XiymgyUEaviZLR41iAQbiyzRsZjSbwhJJXMnKMBZQyzw9drBsTRhcxO6q4wDibMF7qk6qIMIYfqovmgdmxpGAchoxoWC9GSRO8sGavnjZLR41lvWM8kKmmSahuUajeYPsL6vizyyHVOPQZfqonJgjkSqovQuVcjddl8fnvDUaYPzfyJeQqoDmgyUEafrtnKPAUyfLogdmxpGIOPg4W5YbMRhKDfLxceOQjSNogdmxpGIOPg4W5YbMRhKDfLxceOQjkVubBkWC1KMvGIwkn5KgJbMRhqr0udC4C5aZ1dYUIYlbcu1e2Prt6sfSPaZvtAwbkAP0L7mghJbMRhqfyp1uaWkLTHlJdNBPc2e(FN)naeqkLRWLnydUvyv0Oa0LrIehJbMRhqfypfrtnGlRc5(3VubBc)VZ)gaciLYv4YgSb3kSkAua6YirIJXaZ1dOcSNIOPgqQLQweuGelvWMGKHHfbnvXC(HZCRMnuoVqoTljWfQM5p7lDz8)o)BaiGulvTiOajeEzBW1dq0lBdUEGuPsGdBcLfTA44wrkMtgjiuQuZLdNcybckNtT5cq5cGzHcciN6roYLkLlunZF2xAYDqYymWC9aQa7PiAQbK7FFgw2UEPc2eKmmSiOPkMZpCMB1SHY5fYPDjbUq1m)zFPlJ)35FdabK7FFgw2Uw4LTbxparVSn46bsLkboSjuw0QHJBfPyozKGqPsnxoCkGfiOCo1MlaLlaMfkiGCQh5ixQuUq1m)zFPj3P5hJbMRhqfypfrtnCvIwMMLeY(eOkGxQGnLQSahSasggwaBvq3RfYPDLQSahSasggwaBvq3RfwfnkaD5eyVanmRuPMBQYcCWcizyybSvbDVwiNogdmxpGkWEkIMAK(C9GLkytqYWWciLYv4YgSb3kKt7csggwe0ufZ5hoZTA2q58c50UKah2eklA1WXTIumNmsqOuPMlhofWceuoNAZfGYfaZcfeqo1JCPs5cvZ8N9LMCsiCmogdmxpGkWonAsnbfwi1NPTpVubBkvzboybKmmSa2QGUxlKt7kvzboybKmmSa2QGUxlSkAuaAYMsG9c0WSJXaZ1dOcStJMuen1av2XfT95LkytjWEbAywZKQSahSasggwaPbLZyNgnPcRIgfGUSefjHWXyG56bub2PrtkIMAafwi1NPTpVubBcw25Ywf3g2eAMlun5eyVanmBx4)D(3aqaPuUcx2Gn4wHvrJcqhJbMRhqfyNgnPiAQrqtvmNF4m3QzdLZpgdmxpGkWonAsr0udkhOPQxxQGnbjddlcAQI58dN5wnBOCEHCAxqYWWciLYv4YgSb3kKtLkLlunZF2xAYDq4ymWC9aQa70OjfrtnGukxHlBWgC7sfSj8)o)BaicAQI58dN5wnBOCEHvrJcqxojjkvkxOAM)SV0K7GWXyG56bub2PrtkIMAGBl0qTrM2(8ymWC9aQa70OjfrtnImQS1R28dNX23aDmgyUEavGDA0KIOPgqH1gj0XyG56bub2PrtkIMAGGY5Y4hfna(XyG56bub2PrtkIMA4lRMH0GYJXaZ1dOcStJMuen1akSqQptBFEPc2uQYcCWcizyybSvbDVw4FdGUKaUnSjuAg2gyUEq4wUJW8LkfsggwaPuUcx2Gn4wHCkYLkf)VZ)gaIGMQyo)WzUvZgkNxyv0Oa0KtvwGdwajddlGTkO71cVSn46bMjb23v0TAlwfP2cnC5cq5cGzQqbbKt9sLYfQM5p7lnzKDmgyUEavGDA0KIOPg4hYgzA7ZlvWMW)78VbGabLZLXpkAa8cRIgfGUm8JLPcUq1m)z0WSJXaZ1dOcStJMuen1GMwmxGez8dzJX4ymWC9aQGYMGclK6Z02NxQGnLQSahSasggwaBvq3RfYPDLQSahSasggwaBvq3RfwfnkanztjWEbAywPsHLDUSvXTHnHM5cvtob2lqdZ2f(FN)naeqkLRWLnydUvyv0OauPsJUvBXQi1wOHlxakxamtfkiGCQVl8)o)BaicAQI58dN5wnBOCEHvrJcqtob2pgdmxpGkOmIMAe0ufZ5hoZTA2q58JXaZ1dOckJOPgrgv26vB(HZy7BGogdmxpGkOmIMAq5anv96sfSjizyyrqtvmNF4m3QzdLZlKt7csggwaPuUcx2Gn4wHCQuPCHQz(Z(stUdchJbMRhqfugrtnGukxHlBWgC7sfSj8)o)BaicAQI58dN5wnBOCEHvrJcqxojjkvkxOAM)SV0K7GWXyG56bubLr0udeuoxg)OObWpgdmxpGkOmIMAGBl0qTrM2(8ymWC9aQGYiAQHVSAgsdkpgdmxpGkOmIMAafwi1NPTpVubBkvzboybKmmSa2QGUxl8Vbqxsa3g2ekndBdmxpiCl3ry(sLcjddlGukxHlBWgCRqof5sLI)35FdarqtvmNF4m3QzdLZlSkAuaAYPklWblGKHHfWwf09AHx2gC9aZKa77k6wTfRIuBHgUCbOCbWmvOGaYPEPs5cvZ8N9LMmYogdmxpGkOmIMAafwBKqhJbMRhqfugrtnWpKnY02NxQGnjb4hltnd(PmIWpwMkSAcf0Ckb8)o)Baiqq5Cz8JIgaVWQOrbOMPdYxoWC9abckNlJFu0a4f4NYsLI)35FdabckNlJFu0a4fwfnkaD5oiMa7rEx4)D(3aqGGY5Y4hfnaEHvrJcqxUZymWC9aQGYiAQbnTyUajY4hYghF8Da]] )

    
    spec:RegisterOptions( {
        enabled = true,
    
        potion = "potion_of_rising_death",

        buffPadding = 0.25,

        nameplates = false,
        nameplateRange = 8,

        aoe = 3,
    
        damage = true,
        damageExpiration = 3,
    
        package = "Beast Mastery",
    } )
end
