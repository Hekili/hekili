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


    spec:RegisterPack( "Beast Mastery", 20190217.0005, [[d0uDRaqiqv8iPISjPO(KssJcuvNcsXQKkk1RavMLuvDlkjTlc)skmmLehtQYYKk8miLMMiuUMuv2Mur13uIW4uIOZbkvRtjsZteCpkv7tjQdcPIfQK6HGQ0ebLIUiOuWgbLc9rkjyKqQkNKscTskLzcPkUjKQ0ovcdfukTurO6Pk1uLkDvPIs(kKkzSqQQolLeTxv(ROgmuhwyXG8yetMQUmQndXNfrJwkDAjRgsL61GsMnvUnr2nWVv1WfPJlvuSCkEostN01jQTtj13PeJxeY5bfRxkY8HK9R4R3192(q5BrhR0d2xPJElHyLvwPVed2VTctkF70GaRijFBqiX3EnhuDWO3GQSbMBNgW4(WFDVn9Lne(2TQMsxAJgjlTvgsqEPg0ss2fA9aIjq0g0sI0aY9qnGqcR6zRBKAEKYX0gWwdN4r5PnGTjEg9jdu2KxZbvZO3GQSbgbTKi3gsUCQveCq32hkFl6yLEW(kD0BjeRSYk9LyDC7qwBFZT3Le8E72Y7zWbDBptj3UtdEnhuDWO3GQSbMbJ(KbkBgBDAWTQMsxAJgjlTvgsqEPg0ss2fA9aIjq0g0sI0aY9qnGqcR6zRBKAEKYX0gWwdN4r5PnGTjEg9jdu2KxZbvZO3GQSbgbTKiJTonyyJmKromWm4Elr)dUJv6b7d2QdELvw6k9n2gBDAWWBBasY0Lo260GT6GrhVN9dgEFzGYMbVBFDW6pypJeYoDWbrRhmyxrvXyRtd2QdUZIYdwljoRF2x8GHV1uXG1WKKvHwsCw)SVy0my9hCa0IuPHYdMb(b)idMbKxgOSrm260GT6GrhVFW(IMYoAJuztsMoyRRyWYA5kfMbheTEWGDfvf32vuLEDVTNrczNEDVf9UU3MbbKJ936BtmLYMkUTNHKrqeKGQfiPqoDWOqnypdjJGi8fnLDUaYXzPizreYPdgfQb7zizeeHVOPSZfqooZatKKfYP3oiA9GBtcNlheTEq2vu92UIQzqiX3wwlxPWC6TOJR7TdIwp42YuoxklrVndcih7V1NElq7192miGCS)wF7GO1dUnjCUCq06bzxr1B7kQMbHeFBINE6TiXUU3MbbKJ936BtmLYMkUDq0YAoZawQy6GtyWDC7GO1dUnjCUCq06bzxr1B7kQMbHeFBQE6TOVR7Tzqa5y)T(2etPSPIBheTSMZmGLkMo4LhCVBheTEWTjHZLdIwpi7kQEBxr1miK4BtCCynF6P3o1WKxck0R7TO3192miGCS)wF6TOJR7Tzqa5y)T(0BbAVU3MbbKJ936tVfj2192brRhCBQSK0dYPSEBgeqo2FRp9w03192miGCS)wF6TOZVU3oiA9GBN(A9GBZGaYX(B9P3IL46EBgeqo2FRVDQHjbvZAjX3UNO3TdIwp42bnLjA(rYAlNTuo)TjMsztf3gEgC0eBkLfPMskC5cq1cquQGbbKJ9NElwYR7Tzqa5y)T(2PgMeunRLeF7EI(UDq06b3gIPAfUSftOT3MykLnvC7Oj2uklsnLu4YfGQfGOubdcih7p90BtCCynFDVf9UU3MbbKJ936BtmLYMkUnKmcIaXWGMGriNo4MhmKmcIaXWGMGryyPOa0bNG9bNK4fsrIUDq06b3gkmqSptBF90Brhx3BZGaYX(B9TjMsztf3ojXlKIenyRoyizeebehuntCCynlmSuua6GxEWRi6OVBheTEWTLKDArBF90BbAVU3MbbKJ936BtmLYMkUnISZLnmPnmj5Sws8GtyWjjEHuKOb38Gj)78VfGaIPAfUSftOTcdlffGE7GO1dUnuyGyFM2(6P3Ie76E7GO1dUDqtzIMFKS2YzlLZFBgeqo2FRp9w03192miGCS)wFBIPu2uXTHKrqebnLjA(rYAlNTuoVqoDWnpyizeebet1kCzlMqBfYPdgfQbRLeN1p7lEWjm4E9D7GO1dUnvdPu2ZNEl68R7Tzqa5y)T(2etPSPIBt(35FlarqtzIMFKS2YzlLZlmSuua6GxEWDSYGrHAWAjXz9Z(IhCcdUxF3oiA9GBdXuTcx2Ij02tVflX192brRhCBsBjfSjY02xVndcih7V1NElwYR7TdIwp42rws24zt(rYeZBHEBgeqo2FRp9wa7x3BheTEWTHcJjsY3MbbKJ936tVf9w56EBgeqo2FRVnXukBQ42brlR5mdyPIPdoHbNydgfQbdpdoAInLYctKw(SHDF4fmiGCS)2brRhCByvoxM8ssbWF6TOxVR7TdIwp42(YWzioO6Tzqa5y)T(0BrVoUU3MbbKJ936BtmLYMkUnKmcIaXWGMGr4FlGb38GH)GjTHjjtZiMGO1dc3GxEW9el5GrHAWqYiiciMQv4YwmH2kKthmAgmkudM8VZ)waIGMYen)izTLZwkNxyyPOa0bNWGHKrqeigg0emcVSj06bd2QdojXp4MhC0eBkLfPMskC5cq1cquQGbbKJ9dgfQbRLeN1p7lEWjmyy)2brRhCBOWaX(mT91tVf9q7192miGCS)wFBIPu2uXTJMytPSWePLpBy3hEbdcih7hCZdoiAznNzalvmDWlp4oUDq06b3ws2PfT91tVf9sSR7Tzqa5y)T(2etPSPIBt(35FlabSkNltEjPa4fgwkkaDWlpyKNitfAjXz9ZsrIgCZdg(doiAznNzalvmDWjmy0oyuOgm8m4Oj2uklmrA5Zg29HxWGaYX(bJMBheTEWTjpKjY02xp9w0RVR7TdIwp4200s1cKmtEitCBgeqo2FRp90Bt80R7TO3192miGCS)wFBIPu2uXTj)78VfGaIPAfUSftOTcdlffGo4LhmAx52brRhC7aqyQAcxMeo3P3IoUU3MbbKJ936BtmLYMkUn5FN)TaeqmvRWLTycTvyyPOa0bV8Gr7k3oiA9GBJuggY9V)0BbAVU3MbbKJ936BtmLYMkUnKmcIiOPmrZpswB5SLY5fYPdU5bd)bRLeN1p7lEWlpyY)o)BbiGydLnWQajfEztO1dgmCd2lBcTEWGrHAWWFWAysYQOLdN2ksj6GtyWOTVbJc1GHNbRHJbQawLZXMCbOAbiQGbbKJ9dgndgndgfQbRLeN1p7lEWjm4EO92brRhCBi2qzdSkqYtVfj2192miGCS)wFBIPu2uXTHKrqebnLjA(rYAlNTuoVqoDWnpy4pyTK4S(zFXdE5bt(35FlabK7FFgr2aJWlBcTEWGHBWEztO1dgmkudg(dwdtswfTC40wrkrhCcdgT9nyuOgm8mynCmqfWQCo2KlavlarfmiGCSFWOzWOzWOqnyTK4S(zFXdoHb3RZVDq06b3gY9VpJiBG50BrFx3BZGaYX(B9TjMsztf3gsgbrGyyqtWiKthCZdgsgbrGyyqtWimSuua6GxEWjjEHuKObJc1GHNbdjJGiqmmOjyeYP3oiA9GB7QKTknJUL9jLyGE6TOZVU3MbbKJ936BtmLYMkUnKmcIaIPAfUSftOTc50b38GHKrqebnLjA(rYAlNTuoVqoDWnpy4pynmjzv0YHtBfPeDWjmy023GrHAWWZG1WXavaRY5ytUauTaevWGaYX(bJMbJc1G1sIZ6N9fp4egCh9D7GO1dUD6R1do90Bt1R7TO3192miGCS)wFBIPu2uXTHKrqeigg0emc50b38GHKrqeigg0emcdlffGo4eSp4KeVqks0GrHAWiYox2WK2WKKZAjXdoHbNK4fsrIgCZdM8VZ)waciMQv4YwmH2kmSuua6GrHAWrtSPuwKAkPWLlavlarPcgeqo2p4Mhm5FN)TaebnLjA(rYAlNTuoVWWsrbOdoHbNK4VDq06b3gkmqSptBF90Brhx3BheTEWTdAkt08JK1woBPC(BZGaYX(B9P3c0EDVDq06b3oYsYgpBYpsMyEl0BZGaYX(B9P3Ie76EBgeqo2FRVnXukBQ42qYiiIGMYen)izTLZwkNxiNo4MhmKmcIaIPAfUSftOTc50bJc1G1sIZ6N9fp4egCV(UDq06b3MQHuk75tVf9DDVndcih7V13MykLnvCBY)o)BbicAkt08JK1woBPCEHHLIcqh8YdUJvgmkudwljoRF2x8GtyW9672brRhCBiMQv4YwmH2E6TOZVU3oiA9GBdRY5YKxska(BZGaYX(B9P3IL46E7GO1dUnPTKc2ezA7R3MbbKJ936tVfl5192brRhCBFz4mehu92miGCS)wF6Ta2VU3MbbKJ936BtmLYMkUnKmcIaXWGMGr4FlGb38GH)GjTHjjtZiMGO1dc3GxEW9el5GrHAWqYiiciMQv4YwmH2kKthmAgmkudM8VZ)waIGMYen)izTLZwkNxyyPOa0bNWGHKrqeigg0emcVSj06bd2QdojXp4MhC0eBkLfPMskC5cq1cquQGbbKJ9dgfQbRLeN1p7lEWjmyy)2brRhCBOWaX(mT91tVf9w56E7GO1dUnuymrs(2miGCS)wF6TOxVR7Tzqa5y)T(2etPSPIBd)bJ8ez6GT6GjpvhmCdg5jYuHHtYGb3zpy4pyY)o)BbiGv5CzYljfaVWWsrbOd2QdU3GrZGxEWbrRhiGv5CzYljfaVG8uDWOqnyY)o)BbiGv5CzYljfaVWWsrbOdE5b3BWWn4Ke)GrZGBEWK)D(3cqaRY5YKxskaEHHLIcqh8YdU3TdIwp42KhYezA7RNEl61X192brRhCBAAPAbsMjpKjUndcih7V1NE6TL1Yvkmx3BrVR7TdIwp42KxgOSjtBF92miGCS)wF6TOJR7TdIwp42u2WGsHj7LP6Tzqa5y)T(0BbAVU3oiA9GBttFdNjUx2FBgeqo2FRp9wKyx3BheTEWTP)RTfiz2sOS52miGCS)wF6TOVR7TdIwp420huKmKlO6Tzqa5y)T(0BrNFDVDq06b3gWAlBY02NaRBZGaYX(B9P3IL46E7GO1dUnPTq3fnRMa0zKlxPWCBgeqo2FRp9wSKx3BheTEWTPPLP0mT9jW62miGCS)wF6Ta2VU3oiA9GBdcv2W0Cstq4BZGaYX(B9PNE6TTMn06b3IowPhSVsh96j6Hw02XTTegqbssVn6cDs8fwXfwHLo4b3TLhCjL(gDWiVzWRsCCynV6GnCNrUmSFW0xIhCiRVuOSFWK2aKKPIXg6Pa8G7T0bdVpWA2OSFWRMYQa9lSsHqS6G1FWRALcHy1bd)oseAeJn0tb4b3Xshm8(aRzJY(bVAkRc0VWkfcXQdw)bVQvkeIvhm87Li0igBONcWdUxhlDWW7dSMnk7h8QPSkq)cRuieRoy9h8QwPqiwDWWVJeHgXyBSHUqNeFHvCHvyPdEWDB5bxsPVrhmYBg8QepD1bB4oJCzy)GPVep4qwFPqz)GjTbijtfJn0tb4b33shm8(aRzJY(bVAkRc0VWkfcXQdw)bVQvkeIvhm8rBIqJySn2qxOtIVWkUWkS0bp4UT8GlP03Odg5ndEvQU6GnCNrUmSFW0xIhCiRVuOSFWK2aKKPIXg6Pa8G7T0bdVpWA2OSFWRMYQa9lSsHqS6G1FWRALcHy1bd)oseAeJn0tb4bd7lDWW7dSMnk7h8QPSkq)cRuieRoy9h8QwPqiwDWWVJeHgXyBSzfLsFJY(b35doiA9Gb7kQsfJTBttzYTOJ(q7Ttnps54B3PbVMdQoy0Bqv2aZGrFYaLnJTon4wvtPlTrJKL2kdjiVudAjj7cTEaXeiAdAjrAa5EOgqiHv9S1nsnps5yAdyRHt8O80gW2epJ(KbkBYR5GQz0Bqv2aJGwsKXwNgmSrgYihgygCVLO)b3Xk9G9bB1bVYklDL(gBJTony4Tnajz6shBDAWwDWOJ3Z(bdVVmqzZG3TVoy9hSNrczNo4GO1dgSROQyS1PbB1b3zr5bRLeN1p7lEWW3AQyWAysYQqljoRF2xmAgS(doaArQ0q5bZa)GFKbZaYldu2igBDAWwDWOJ3pyFrtzhTrQSjjthS1vmyzTCLcZGdIwpyWUIQIX2yRtdg2qIyISY(bdXiVHhm5LGcDWqCYcqfdgDieovPdg8aR2ggjez3GdIwpGo4h4Grm2cIwpGksnm5LGc1oIlOWASfeTEavKAyYlbfkC2BeYjLyGgA9GXwq06burQHjVeuOWzVbY)(Xwq06burQHjVeuOWzVbvws6b5uwhBDAWBqKsBFDWMO8dgsgbH9dMQHshmeJ8gEWKxck0bdXjlaDWbWp4udB10x1cKCWfDW(hWIXwq06burQHjVeuOWzVbfeP02xZunu6yliA9aQi1WKxcku4S3i916bJTony0XJULPkDWAlpyVSj06bdoa(bt(35FlGb)idgDOPmrh8JmyTLhm6QC(bha)GHTMskCd2kcOAbikDWqWmyTLhSx2eA9Gb)idoadwg0guL9d2kaVWMd2sldgS2YWSQHhSmL9do1WKxckuXGrh6GrNxrxdUnOdogCpbAPd2kaVWMdoa(bhiimrPdUuk7qgS2w0bx0b3t0JkgBbrRhqfPgM8sqHcN9gbnLjA(rYAlNTuoF)PgMeunRLeBVNOx)fID4jAInLYIutjfUCbOAbikvWGaYX(XwNgm64r3YuLoyTLhSx2eA9Gbha)Gj)78VfWGFKbVMPAfUbJUmH2o4a4hm6lAIh8Jm4epsYdgcMbRT8G9YMqRhm4hzWbyWYG2GQSFWwb4f2CWwAzWG1wgMvn8GLPSFWPgM8sqHkgBbrRhqfPgM8sqHcN9gqmvRWLTycTT)udtcQM1sIT3t0x)fI9Oj2uklsnLu4YfGQfGOubdcih7hBJTGO1dOczTCLcJDYldu2KPTVo2cIwpGkK1YvkmWzVbLnmOuyYEzQo2cIwpGkK1YvkmWzVbn9nCM4Ez)yliA9aQqwlxPWaN9g0)12cKmBju2m2cIwpGkK1YvkmWzVb9bfjd5cQo2cIwpGkK1YvkmWzVbG1w2KPTpbwJTGO1dOczTCLcdC2BqAl0DrZQjaDg5YvkmJTGO1dOczTCLcdC2BqtltPzA7tG1yliA9aQqwlxPWaN9gGqLnmnN0eeESn260GHnKiMiRSFWS1SbMbRLepyTLhCq03m4Io4W6OCbKJfJTGO1dO2jHZLdIwpi7kQ2piKy7YA5kfM(le7EgsgbrqcQwGKc5uuO8mKmcIWx0u25cihNLIKfriNIcLNHKrqe(IMYoxa54mdmrswiNo2cIwpGcN9gYuoxklrhBbrRhqHZEds4C5GO1dYUIQ9dcj2oXthBbrRhqHZEds4C5GO1dYUIQ9dcj2ov7VqSheTSMZmGLkMMqhJTGO1dOWzVbjCUCq06bzxr1(bHeBN44WAU)cXEq0YAoZawQy6Y9gBJTGO1dOcINApaeMQMWLjHZ1FHyN8VZ)waciMQv4YwmH2kmSuua6YODLXwq06bubXtHZEdKYWqU)99xi2j)78VfGaIPAfUSftOTcdlffGUmAxzSfeTEavq8u4S3aInu2aRcKS)cXoKmcIiOPmrZpswB5SLY5fYPndFTK4S(zFXlt(35FlabeBOSbwfiPWlBcTEaCEztO1dqHc(AysYQOLdN2ksjAcOTpuOGhnCmqfWQCo2KlavlarfmiGCShnObfkTK4S(zFXj0dTJTGO1dOcINcN9gqU)9zezdm9xi2HKrqebnLjA(rYAlNTuoVqoTz4RLeN1p7lEzY)o)BbiGC)7ZiYgyeEztO1dGZlBcTEakuWxdtswfTC40wrkrtaT9Hcf8OHJbQawLZXMCbOAbiQGbbKJ9ObnOqPLeN1p7loHED(yliA9aQG4PWzVHRs2Q0m6w2NuIbA)fI9uwfKqfqYiiceddAcgHCAZPSkiHkGKrqeigg0emcdlffGUCsIxifjcfk4jLvbjubKmcIaXWGMGriNo2cIwpGkiEkC2BK(A9G(le7qYiiciMQv4YwmH2kKtBgsgbre0uMO5hjRTC2s58c50MHVgMKSkA5WPTIuIMaA7dfk4rdhdubSkNJn5cq1cqubdcih7rdkuAjXz9Z(ItOJ(gBJTGO1dOcIJdRz7qHbI9zA7R9xi2tzvqcvajJGiqmmOjyeYPnNYQGeQasgbrGyyqtWimSuuaAc2ts8cPirJTGO1dOcIJdRz4S3qs2PfT91(le7jjEHuKiRMYQGeQasgbraXbvZehhwZcdlffGU8kIo6BSfeTEavqCCyndN9gqHbI9zA7R9xi2rKDUSHjTHjjN1sItijXlKIe1m5FN)TaeqmvRWLTycTvyyPOa0Xwq06bubXXH1mC2Be0uMO5hjRTC2s58JTGO1dOcIJdRz4S3GQHuk75(le7qYiiIGMYen)izTLZwkNxiN2mKmcIaIPAfUSftOTc5uuO0sIZ6N9fNqV(gBbrRhqfehhwZWzVbet1kCzlMqB7VqSt(35FlarqtzIMFKS2YzlLZlmSuua6YDSckuAjXz9Z(ItOxFJTGO1dOcIJdRz4S3G0wsbBImT91Xwq06bubXXH1mC2BezjzJNn5hjtmVf6yliA9aQG44WAgo7nGcJjsYJTGO1dOcIJdRz4S3awLZLjVKua89xi2dIwwZzgWsfttiXqHcEIMytPSWePLpBy3hEbdcih7hBbrRhqfehhwZWzVHVmCgIdQo2cIwpGkiooSMHZEdOWaX(mT91(le7PSkiHkGKrqeigg0emc)Bb0m8jTHjjtZiMGO1dc3Y9eljkuqYiiciMQv4YwmH2kKtrdkuK)D(3cqe0uMO5hjRTC2s58cdlffGMqkRcsOcizeebIHbnbJWlBcTEGvts8nhnXMszrQPKcxUauTaeLkyqa5ypkuAjXz9Z(Ita2hBbrRhqfehhwZWzVHKStlA7R9xi2JMytPSWePLpBy3hEbdcih7BoiAznNzalvmD5ogBbrRhqfehhwZWzVb5HmrM2(A)fIDY)o)BbiGv5CzYljfaVWWsrbOlJ8ezQqljoRFwksuZWpiAznNzalvmnb0Icf8enXMszHjslF2WUp8cgeqo2JMXwq06bubXXH1mC2BqtlvlqYm5HmXyBSfeTEavqv7qHbI9zA7R9xi2tzvqcvajJGiqmmOjyeYPnNYQGeQasgbrGyyqtWimSuuaAc2ts8cPirOqHi7CzdtAdtsoRLeNqsIxifjQzY)o)BbiGyQwHlBXeARWWsrbOOqfnXMszrQPKcxUauTaeLkyqa5yFZK)D(3cqe0uMO5hjRTC2s58cdlffGMqsIFSfeTEavqv4S3iOPmrZpswB5SLY5hBbrRhqfufo7nISKSXZM8JKjM3cDSfeTEavqv4S3GQHuk75(le7qYiiIGMYen)izTLZwkNxiN2mKmcIaIPAfUSftOTc5uuO0sIZ6N9fNqV(gBbrRhqfufo7nGyQwHlBXeAB)fIDY)o)BbicAkt08JK1woBPCEHHLIcqxUJvqHsljoRF2xCc96BSfeTEavqv4S3awLZLjVKua8JTGO1dOcQcN9gK2skytKPTVo2cIwpGkOkC2B4ldNH4GQJTGO1dOcQcN9gqHbI9zA7R9xi2tzvqcvajJGiqmmOjye(3cOz4tAdtsMMrmbrRheUL7jwsuOGKrqeqmvRWLTycTviNIguOi)78VfGiOPmrZpswB5SLY5fgwkkanHuwfKqfqYiiceddAcgHx2eA9aRMK4BoAInLYIutjfUCbOAbikvWGaYXEuO0sIZ6N9fNaSp2cIwpGkOkC2BafgtKKhBbrRhqfufo7nipKjY02x7VqSdFKNitTk5PkCiprMkmCsg0zdFY)o)BbiGv5CzYljfaVWWsrbOwThAwoiA9abSkNltEjPa4fKNQOqr(35FlabSkNltEjPa4fgwkkaD5EWLK4rtZK)D(3cqaRY5YKxskaEHHLIcqxU3yliA9aQGQWzVbnTuTajZKhYeNE6Da]] )

    
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
