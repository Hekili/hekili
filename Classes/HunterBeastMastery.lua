-- Hunter Beast Mastery
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Shadowlands
-- Legendaries
-- [x] Call of the Wild
-- [-] Nessingwary's Trapping Apparatus (leave as reactive)
-- [x] Soulforge Embers
-- [x] Craven Strategem

-- [-] Dire Command (passive/reactive)
-- [x] Flamewaker's Cobra Sting
-- [x] Qa'pla, Eredun War Order
-- [-] Rylakstalker's Piercing Fangs (passive/reactive)

-- Conduits
-- [x] Bloodletting
-- [-] Echoing Call
-- [x] Ferocious Appetite
-- [-] One with the Beast

-- Covenants
-- [-] Enfeebled Mark
-- [-] Empowered Release
-- [x] Necrotic Barrage
-- [x] Spirit Attunement

-- Endurance
-- [x] Harmony of the Tortollan
-- [-] Markman's Advantage (sp)
-- [x] Rejuvenating Wind
-- [-] Resilience of the Hunter

-- Finesse
-- [x] cheetahs_vigor
-- [x] reversal_of_fortune
-- [x] tactical_retreat


-- needed for Frenzy.
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


if UnitClassBase( "player" ) == "HUNTER" then
    local spec = Hekili:NewSpecialization( 253, true )

    spec:RegisterResource( Enum.PowerType.Focus, {
        aspect_of_the_wild = {
            resource = "focus",
            aura = "aspect_of_the_wild",

            last = function ()
                local app = state.buff.aspect_oF_the_wild.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 5,
        },

        barbed_shot = {
            resource = "focus",
            aura = "barbed_shot",

            last = function ()
                local app = state.buff.barbed_shot.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_2 = {
            resource = "focus",
            aura = "barbed_shot_2",

            last = function ()
                local app = state.buff.barbed_shot_2.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_3 = {
            resource = "focus",
            aura = "barbed_shot_3",

            last = function ()
                local app = state.buff.barbed_shot_3.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_4 = {
            resource = "focus",
            aura = "barbed_shot_4",

            last = function ()
                local app = state.buff.barbed_shot_4.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_5 = {
            resource = "focus",
            aura = "barbed_shot_5",

            last = function ()
                local app = state.buff.barbed_shot_5.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_6 = {
            resource = "focus",
            aura = "barbed_shot_6",

            last = function ()
                local app = state.buff.barbed_shot_6.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_7 = {
            resource = "focus",
            aura = "barbed_shot_7",

            last = function ()
                local app = state.buff.barbed_shot_7.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        barbed_shot_8 = {
            resource = "focus",
            aura = "barbed_shot_8",

            last = function ()
                local app = state.buff.barbed_shot_8.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 2,
            value = 5,
        },

        death_chakram = {
            resource = "focus",
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( state.query_time - state.buff.death_chakram.applied )
            end,

            interval = function () return class.auras.death_chakram.tick_time end,
            value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
        }
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
            id = 186258,
            duration = function () return conduit.cheetahs_vigor.enabled and 12 or 9 end,
            max_stack = 1,
        },

        aspect_of_the_cheetah_sprint = {
            id = 186257,
            duration = 3,
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
        },


        -- Conduits
        resilience_of_the_hunter = {
            id = 339461,
            duration = 8,
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

            talent = "a_murder_of_crows",

            startsCombat = true,
            texture = 645217,

            handler = function ()
                applyDebuff( "target", "a_murder_of_crows" )
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "focus",

            startsCombat = true,
            texture = 132218,

            handler = function ()
            end,
        },


        aspect_of_the_cheetah = {
            id = 186257,
            cast = 0,
            cooldown = function () return ( ( pvptalent.hunting_pack.enabled and 0.5 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * 180 ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 132242,

            handler = function ()
                applyBuff( "aspect_of_the_cheetah" )
                applyBuff( "aspect_of_the_cheetah_sprint" )
            end,
        },


        aspect_of_the_turtle = {
            id = 186265,
            cast = 8,
            cooldown = function() return ( ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * 180 ) + ( conduit.harmony_of_the_tortollan.mod * 0.001 ) end,
            gcd = "spell",
            channeled = true,

            startsCombat = false,
            texture = 132199,

            start = function ()
                applyBuff( "aspect_of_the_turtle" )
            end,
        },


        aspect_of_the_wild = {
            id = 193530,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136074,

            nobuff = function ()
                if settings.aspect_vop_overlap then return end
                return "aspect_of_the_wild"
            end,

            handler = function ()
                applyBuff( "aspect_of_the_wild" )

                if azerite.primal_instincts.enabled then gainCharges( "barbed_shot", 1 ) end
            end,
        },


        barbed_shot = {
            id = 217200,
            cast = 0,
            charges = 2,
            cooldown = function () return ( conduit.bloodletting.enabled and 11 or 12 ) * haste end,
            recharge = function () return ( conduit.bloodletting.enabled and 11 or 12 ) * haste end,
            gcd = "spell",

            velocity = 50,

            startsCombat = true,
            texture = 2058007,

            cycle = "barbed_shot",

            handler = function ()
                if buff.barbed_shot.down then applyBuff( "barbed_shot" )
                else
                    for i = 2, 8 do
                        if buff[ "barbed_shot_" .. i ].down then applyBuff( "barbed_shot_" .. i ); break end
                    end
                end

                addStack( "frenzy", 8, 1 )

                setCooldown( "bestial_wrath", cooldown.bestial_wrath.remains - 12 )
                applyDebuff( "target", "barbed_shot_dot" )

                if legendary.qapla_eredun_war_order.enabled then
                    reduceCooldown( "kill_command", 4 )
                end
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

            handler = function ()
                applyBuff( "bestial_wrath" )
                if pvptalent.the_beast_within.enabled then applyBuff( "the_beast_within" ) end
                if talent.scent_of_blood.enabled then gainCharges( "barbed_shot", 2 ) end
            end,
        },


        binding_shot = {
            id = 109248,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            talent = "binding_shot",

            startsCombat = true,
            texture = 462650,

            handler = function ()
                applyDebuff( "target", "binding_shot" )
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
                applyBuff( "camouflage" )
            end,
        },


        chimaera_shot = {
            id = 53209,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            velocity = 50,

            talent = "chimaera_shot",

            startsCombat = true,
            texture = 236176,

            handler = function ()
                gain( 10 * min( 2, active_enemies ), "focus" )
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
                if talent.killer_cobra.enabled and buff.bestial_wrath.up then setCooldown( "kill_command", 0 )
                else setCooldown( "kill_command", cooldown.kill_command.remains - 1 ) end
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
                applyDebuff( "target", "concussive_shot" )
            end,
        },


        counter_shot = {
            id = 147362,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            toggle = "interrupts",

            startsCombat = true,
            texture = 249170,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if conduit.reversal_of_fortune.enabled then
                    gain( conduit.reversal_of_fortune.mod, "focus" )
                end

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
                summonPet( "dire_beast", 8 )
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
            gcd = "off",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                if talent.posthaste.enabled then applyBuff( "posthaste" ) end
                if conduit.tactical_retreat.enabled and target.within8 then applyDebuff( "target", "tactical_retreat" ) end
            end,

            auras = {
                -- Conduits
                tactical_retreat = {
                    id = 339654,
                    duration = 3,
                    max_stack = 1
                }
            }
        },


        eagle_eye = {
            id = 6197,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132172,

            handler = function ()
                applyBuff( "eagle_eye", 60 )
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
                if conduit.rejuvenating_wind.enabled then applyBuff( "rejuvenating_wind" ) end
            end,

            auras = {
                -- Conduit
                rejuvenating_wind = {
                    id = 339400,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        feign_death = {
            id = 5384,
            cast = 0,
            cooldown = function () return legendary.craven_stategem.enabled and 15 or 30 end,
            gcd = "spell",

            startsCombat = false,
            texture = 132293,

            handler = function ()
                applyBuff( "feign_death" )

                if legendary.craven_strategem.enabled then
                    removeDebuff( "player", "dispellable_curse" )
                    removeDebuff( "player", "dispellable_disease" )
                    removeDebuff( "player", "dispellable_magic" )
                    removeDebuff( "player", "dispellable_poison" )
                end
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
                applyDebuff( "target", "flare" )

                if legendary.soulforge_embers.enabled and debuff.tar_trap.up then
                    applyDebuff( "target", "soulforge_embers" )
                    active_dot.soulforge_embers = max( 1, min( 5, active_dot.tar_trap ) )
                end
            end,

            auras = {
                soulforge_embers = {
                    id = 336746,
                    duration = 12,
                    max_stack = 1
                }
            }
        },


        freezing_trap = {
            id = 187650,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "freezing_trap" )
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
                applyDebuff( "target", "intimidation" )
            end,
        },


        kill_command = {
            id = 34026,
            cast = 0,
            cooldown = function () return 7.5 * haste end,
            gcd = "spell",

            spend = function () return buff.flamewakers_cobra_shot.up and 0 or 30 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132176,

            usable = function () return pet.alive, "requires a living pet" end,

            handler = function ()
                removeBuff( "flamewakers_cobra_shot" )

                if conduit.ferocious_appetite.enabled and stat.crit >= 100 then
                    reduceCooldown( "aspect_of_the_wild", conduit.ferocious_appetite.mod / 10 )
                end
            end,

            auras = {
                flamewakers_cobra_shot = {
                    id = 336826,
                    duration = 15,
                    max_stack = 1,
                }
            }
        },


        kill_shot = {
            id = 53351,
            cast = 0,
            charges = 1,
            cooldown = 10,
            recharge = 10,
            gcd = "spell",

            spend = function () return buff.flayers_mark.up and 0 or 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 236174,

            usable = function () return buff.flayers_mark.up or target.health_pct < 20 end,
            handler = function ()
                removeBuff( "flayers_mark" )
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

            handler = function ()
                applyBuff( "beast_cleave" )
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

            talent = "spitting_cobra",
            toggle = "cooldowns",

            startsCombat = true,
            texture = 236177,

            handler = function ()
                summonPet( "spitting_cobra", 20 )
                applyBuff( "spitting_cobra", 20 )
            end,
        },


        stampede = {
            id = 201430,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",
            talent = "stampede",

            startsCombat = true,
            texture = 461112,

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

            usable = function () return not pet.exists, "requires no active pet" end,

            handler = function ()
                summonPet( "made_up_pet", 3600, "ferocity" )
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


        --[[ Pet Abilities
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
        }, ]]


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
        },


        -- Hunter - Kyrian    - 308491 - resonating_arrow     (Resonating Arrow)
        resonating_arrow = {
            id = 308491,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 3565445,

            handler = function ()
                applyDebuff( "target", "resonating_arrow" )
                active_dot.resonating_arrow = active_enemies
            end,

            toggle = "essences",

            auras = {
                resonating_arrow = {
                    id = 308498,
                    duration = 10,
                    max_stack = 1,
                }
            }
        },

        -- Hunter - Necrolord - 325028 - death_chakram        (Death Chakram)
        death_chakram = {
            id = 325028,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 3578207,

            toggle = "essences",

            handler = function ()
                applyBuff( "death_chakram" )
            end,

            auras = {
                death_chakram = {
                    duration = 3.5,
                    tick_time = 0.5,
                    max_stack = 1,
                    generate = function( t, auraType )
                        local cast = action.death_chakram.lastCast or 0

                        if cast + class.auras.death_chakram.duration >= query_time then
                            t.name = class.abilities.death_chakram.name
                            t.count = 1
                            t.applied = cast
                            t.expires = cast + duration
                            t.caster = "player"
                            return
                        end
                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end
                }
            }
        },

        -- Hunter - Night Fae - 328231 - wild_spirits         (Wild Spirits)
        wild_spirits = {
            id = 328231,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 3636840,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "wild_mark" )
            end,

            auras = {
                wild_mark = {
                    id = 328275,
                    duration = function () return conduit.spirit_attunement.enabled and 18 or 15 end,
                    max_stack = 1
                }
            }
        },

        -- Hunter - Venthyr   - 324149 - flayed_shot          (Flayed Shot)
        flayed_shot = {
            id = 324149,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 3565719,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "flayed_shot" )
            end,

            auras = {
                flayed_shot = {
                    id = 324149,
                    duration = 20,
                    max_stack = 1,
                },
                flayers_mark = {
                    id = 324156,
                    duration = 12,
                    max_stack = 1
                }
            }
        }


    } )


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


    if state.level > 50 then
        spec:RegisterPack( "Beast Mastery", 20201012.9, [[dKeENaqikvPhrGkBse5teqJIq4ueIwLiQQxjqZIq6wkjIDr0VusnmLQ6yIWYiu9mvLmnLe11uQY2iq5BuQQgNsI05uvkRtevMNQI7PQAFeGdsGKwOsLhsGuFKavzKeOQojLQOvsPmtvLk3uvPQ2Pi5NIOkTuvLQ8ujMQi1xjqIXsPkCwkvL9k1FfAWI6WuTyO8yitwsxg1MvLpRugTGoTIvlIQ41kjnBkUnuTBGFRYWvIJtGy5GEoIPt66uY2ju(obnELeopLkRxeL5lG9J0DIoDxQUYDkX3x89tS)(2Vu8ejw5UO2TWDzXrR6BCxaoo3LDStuA(77eLH21Lf3oZ51oDxiNfeXDju1fsYTE92OHwys0HVMm4wgxNdGG(txtgC06UGzng1EcASUuDL7uIVV47Ny)9TFP4js81EF1f3sdpyxkdUGUlHtTYGgRlvMG6IGJM3XorP5VVtugAhnl4BbugsTj4O5KxKEymKMTFrPzX3x89P2O2eC083XIXgAwa08E7l7IzikPt3Lk)ClJ2P7uj60DXr6CGUGolGYWij80UWahZW1ExRDkX70DXr6CGUOqhiiwJzs2a2IKWt7cdCmdx7DT2P(Qt3fg4ygU276ccokdhVllqwS4gQktiDYcJ049IAihfoMknhian)MTqnczCFaeA(dnl((DXr6CGUyr44OmoP1o1k3P7cdCmdx7DDXr6CGUGCJj6iDoq0meTlMHOrGJZDbvjT2P2Rt3fg4ygU276ccokdhVloshX4idy8Hj08hAw8U4iDoqxqUXeDKohiAgI2fZq0iWX5Uq0w7ucwNUlmWXmCT31feCugoExCKoIXrgW4dtOzbqZj6IJ05aDb5gt0r6CGOziAxmdrJahN7cYWUyCRT2LfiJoCmx70DQeD6U4iDoqxiw44hiUWAxyGJz4AVR1oL4D6UWahZW1ExxqWrz44DbAb43b3yj5SmVdUXrghJHejliwZYcx7IJ05aDrDyuH(sRDQV60DHboMHR9UUSazKt0Oo4Cxsi)QlosNd0fNSWinEVOgYrHJP2ANAL70DHboMHR9UUSazKt0Oo4Cxsi3RlosNd0fmMOJBIcHUg2feCugoExSxAwDddujbXanEViM5UQKboMHR0Cs0S9sZqla)o4gljNL5DWnoY4ymKizbXAww4ARDQ960DHboMHR9UU4iDoqxwoDoqxQ2bC8bfxG8YPDjrRT2fuL0P7uj60DHboMHR9UUGGJYWX7c6ot9ecKymrh3efcDnuczCFaeAwa08x73fhPZb6IdqmrHUjICJP1oL4D6UWahZW1ExxqWrz44DbDNPEcbsmMOJBIcHUgkHmUpacnlaA(R97IJ05aD5nqgZCxT1o1xD6UWahZW1ExxqWrz44DbZ69KozHrA8ErnKJchtvATqZjrZIGMFZwOgHmUpacnlaAgDNPEcbsmgsy4QdytwTGUohGMdsZvlORZbO5abOzrqZQd3yvgYUrdLliLM)qZFThnhianBV0S6ggOYvhJHHXbq0bGujdCmdxPzrsZIKMdeGMFZwOgHmUpacn)HMt8vxCKohOlymKWWvhWwRDQvUt3fg4ygU276ccokdhVlywVN0jlmsJ3lQHCu4yQsRfAojAwe08B2c1iKX9bqOzbqZO7m1tiqIzURgFwq7KvlORZbO5G0C1c66CaAoqaAwe0S6WnwLHSB0q5csP5p08x7rZbcqZ2lnRUHbQC1XyyyCaeDaivYahZWvAwK0SiP5abO53SfQriJ7dGqZFO5ecwxCKohOlyM7QXNf0Uw7u71P7cdCmdx7DDbbhLHJ3fmR3t(Gmiz2jTwO5KOzmR3t(Gmiz2jHmUpacnlaAEdvL4(kO5abOz7LMXSEp5dYGKzN0APlosNd0fZSfQKyYJvDdNbARDkbRt3fg4ygU276ccokdhVlywVNeJj64MOqORHsRfAojAgZ69KozHrA8ErnKJchtvATqZjrZQd3yvgYUrdLliLM)qZFThnhianlcAwe0m6aelChZWYLtNdeVx0cGbNQHRXNf0oAoqaAgDaIfUJzyPfadovdxJplOD0SiP5KO53SfQriJ7dGqZFOzblbnhian)MTqnczCFaeA(dnlUGrZISlosNd0LLtNd0ARDHOD6ovIoDxyGJz4AVRli4OmC8UGz9EYhKbjZoP1cnNenJz9EYhKbjZojKX9bqO5p)08gQsZbcqZplJjczuOd34Oo4mn)HM3qvAojAgDNPEcbsmMOJBIcHUgkHmUpacnhianJUZupHajgt0XnrHqxdLqg3haHM)qZjeNMdsZBOknNenRUHbQKGyGgVxeZCxvYahZW1U4iDoqxWCigxJKWtBTtjENUlmWXmCT31feCugoExGwa(DWnwsolZ7GBCKXXyirYcI1SSWvAojAwDyuH(IeY4(ai08hAEdvP5KOz0DM6jeiFghYsiJ7dGqZFO5nuTlosNd0f1Hrf6lT2P(Qt3fg4ygU276ccokdhVlQdJk0xKwlDXr6CGU8moKBTtTYD6U4iDoqxeoMAKSmWrjDHboMHR9Uw7u71P7IJ05aDz1XyIKWt7cdCmdx7DT2PeSoDxCKohOlpJBhxJKWt7cdCmdx7DT2PS)oDxyGJz4AVRli4OmC8U8oKfHMdsZiNOriVXaA(dn)oKfrI7ROlosNd0Lk7Ayef6RcD8w7uR0oDxCKohOlyM7QKqU2fg4ygU27ATt9ToDxCKohOlozHrA8ErnKJchtTlmWXmCT31ANkX(D6UWahZW1ExxqWrz44DbZ69KozHrA8ErnKJchtvATqZbcqZVzluJqg3haHM)qZj2RlosNd0fI64lCLBTtLirNUlosNd0fpIBbRmmEVicEcjDHboMHR9Uw7ujeVt3fhPZb6cgt0XnrHqxd7cdCmdx7DT2Ps8vNUlosNd0fitoGRdyl6q4jSlmWXmCT31ANkXk3P7IJ05aDbfo4od9ij80UWahZW1ExRDQe71P7IJ05aDz1XyIOdh3b1UWahZW1ExRDQecwNUlmWXmCT31feCugoExWSEpjgt0XnrHqxdL1tiGMdeGMFZwOgHmUpacn)HM3RlosNd0fmFlEVOch0QKw7ujS)oDxCKohOl1bYrm2jAxyGJz4AVR1ovIvANUlmWXmCT31feCugoExEZwOgHmUpacn)HM)wxCKohOlyoeJRrs4PT2Ps8ToDxCKohOlyoe6BCxyGJz4AVR1oL473P7cdCmdx7DDbbhLHJ3frqZVdzrO5vcnJoIsZbP53HSisiVXaAo5tZIGMr3zQNqGC1XyIOdh3bvjKX9bqO5vcnNGMfjnlaA2r6Ca5QJXerhoUdQs0ruAoqaAgDNPEcbYvhJjIoCChuLqg3haHMfanNGMdsZBOknNenJUZupHajgt0XnrHqxdLqg3hajUzXecnlaA(DilIuhCoQxe3xbnlsAojAgDNPEcbYvhJjIoCChuLqg3haHMfanNGMdeGMFZwOgHmUpacn)HM)QlosNd0f0Hb9ij80wBTlid7IXD6ovIoDxyGJz4AVRlosNd0fmhIX1ij80UGGJYWX7cM17jFqgKm7Kwl0Cs0mM17jFqgKm7Kqg3haHM)8tZBOAxq2HmCuD4gRKovIw7uI3P7cdCmdx7DDbbhLHJ3fmR3tIXorJid7IXsiJ7dGqZFO59LIVhnhKM3q1U4iDoqxWTm6qcpT1o1xD6UWahZW1ExxqWrz44DbAb43b3yj5SmVdUXrghJHejliwZYcxP5KOz1Hrf6lsiJ7dGqZFO5nuLMtIMr3zQNqG8zCilHmUpacn)HM3q1U4iDoqxuhgvOV0ANAL70DHboMHR9UUGGJYWX7I6WOc9fP1sxCKohOlpJd5w7u71P7cdCmdx7DDbbhLHJ3L3HSi0CqAg5enc5ngqZFO53HSisCFfDXr6CGUuzxdJOqFvOJ3ANsW60DXr6CGUiCm1izzGJs6cdCmdx7DT2PS)oDxyGJz4AVRlosNd0fmhIX1ij80UGGJYWX7YZYyIqgf6WnoQdotZFO5nuLMtIMr3zQNqGeJj64MOqORHsiJ7dGqZbcqZO7m1tiqIXeDCtui01qjKX9bqO5p0CcXP5G08gQsZjrZQByGkjigOX7fXm3vLmWXmCTli7qgoQoCJvsNkrRDQvANUlosNd0fNSWinEVOgYrHJP2fg4ygU27ATt9ToDxCKohOlymrh3efcDnSlmWXmCT31ANkX(D6U4iDoqxGm5aUoGTOdHNWUWahZW1ExRDQej60DHboMHR9UUGGJYWX7cM17jDYcJ049IAihfoMQ0AHMdeGMFZwOgHmUpacn)HMtSxxCKohOle1Xx4k3ANkH4D6U4iDoqxEg3oUgjHN2fg4ygU27ATtL4RoDxCKohOlRogtKeEAxyGJz4AVR1ovIvUt3fhPZb6ckCWDg6rs4PDHboMHR9Uw7uj2Rt3fhPZb6cM5UkjKRDHboMHR9Uw7ujeSoDxCKohOlEe3cwzy8Ere8es6cdCmdx7DT2Psy)D6UWahZW1ExxqWrz44DbZ69KpidsMDsiJ7dGqZcGM5vWilLJ6GZDXr6CGUG5qOVXT2PsSs70DHboMHR9UUGGJYWX7Y7qweAwa0m6iknhKMDKohqIBz0HeEQeDeTlosNd0LvhJjIoCChuBTtL4BD6UWahZW1ExxqWrz44DbZ69Kymrh3efcDnuwpHaAoqaA(nBHAeY4(ai08hAEVU4iDoqxW8T49IkCqRsATtj((D6U4iDoqxQdKJySt0UWahZW1ExRDkXt0P7cdCmdx7DDXr6CGUG5qmUgjHN2feCugoExEZwOgHmUpacn)HM)wxq2HmCuD4gRKovIw7uIlENUlmWXmCT31feCugoExEhYIi1bNJ6fX9vqZFO5nuLMt(0S4DXr6CGU4qKd4ij80wBT1UigdjZb6uIVV47V)3(AF53(23(236IqhcgWgPlckcQFVu2ZucEjhntZPdzAEWxoOsZVdsZcevjcKMHSGynqUsZKdNPz3spCx5knJcDWgtKuBF3ayAEVKJMf0hqmgQCLMf4cRs7H0(KsPaPz9OzbAFsPuG0Si(AfIusTrTjOiO(9szptj4LC0mnNoKP5bF5Gkn)oinlqIkqAgYcI1a5kntoCMMDl9WDLR0mk0bBmrsT9DdGP5ejhnlOpGymu5knlWfwL2dP9jLsbsZ6rZc0(KsPaPzri(kePKAJAtqrq97LYEMsWl5OzAoDitZd(YbvA(DqAwGid7IXcKMHSGynqUsZKdNPz3spCx5knJcDWgtKuBF3ayAorYrZc6digdvUsZcCHvP9qAFsPuG0SE0SaTpPukqAweIVcrkP2(UbW0S4jhnlOpGymu5knlWfwL2dP9jLsbsZ6rZc0(KsPaPzrKyfIusT9DdGP5e2FYrZc6digdvUsZcCHvP9qAFsPuG0SE0SaTpPukqAwejwHiLuBuB2t8LdQCLM3JMDKohGMndrjsQTUqwyuNs89(QllW7ngUlcoAEh7eLM)(orzOD0SGVfqzi1MGJMtEr6HXqA2(fLMfFFX3NAJAtWrZFhlgBOzbqZ7TVKAJAZr6CaICbYOdhZ1G)Rjw44hiUWk1MJ05ae5cKrhoMRb)xRomQqFr059dTa87GBSKCwM3b34iJJXqIKfeRzzHRuBosNdqKlqgD4yUg8FTtwyKgVxud5OWXufDbYiNOrDW5)eYVO2CKohGixGm6WXCn4)AmMOJBIcHUgk6cKrorJ6GZ)jK7j68(Tx1nmqLeed049IyM7Qsg4ygUMK9cTa87GBSKCwM3b34iJJXqIKfeRzzHRuBosNdqKlqgD4yUg8F9YPZbeTAhWXhuCbYlN(NGAJAZr6CasW)1OZcOmmscpLAZr6CasW)1k0bcI1yMKnGTij8uQnhPZbib)xBr44Omor059VazXIBOQmH0jlmsJ3lQHCu4yQbc8MTqnczCFaKpIVp1MJ05aKG)RrUXeDKohiAgIkkWX5FuLqT5iDoaj4)AKBmrhPZbIMHOIcCC(NOIoVFhPJyCKbm(WKpItT5iDoaj4)AKBmrhPZbIMHOIcCC(hzyxmw0597iDeJJmGXhMiGeuBuBosNdqKOkj4)AhGyIcDte5gJOZ7hDNPEcbsmMOJBIcHUgkHmUpaIa(AFQnhPZbisuLe8F9BGmM5UQOZ7hDNPEcbsmMOJBIcHUgkHmUpaIa(AFQnhPZbisuLe8FngdjmC1bSj68(XSEpPtwyKgVxud5OWXuLwljjI3SfQriJ7dGia0DM6jeiXyiHHRoGnz1c66CGGvlORZbceqeQd3yvgYUrdLli9Zx7fiG9QUHbQC1XyyyCaeDaivYahZWvrkYabEZwOgHmUpaYNeFrT5iDoarIQKG)RXm3vJplODIoVFmR3t6KfgPX7f1qokCmvP1ssI4nBHAeY4(aicaDNPEcbsmZD14ZcANSAbDDoqWQf015abcic1HBSkdz3OHYfK(5R9ceWEv3WavU6ymmmoaIoaKkzGJz4QifzGaVzluJqg3ha5tcbJAZr6CaIevjb)xBMTqLetESQB4mqfDE)lSkX9biXSEp5dYGKzN0AjPfwL4(aKywVN8bzqYStczCFaebSHQsCFfbcyVlSkX9biXSEp5dYGKzN0AHAZr6CaIevjb)xVC6CarN3pM17jXyIoUjke6AO0AjjmR3t6KfgPX7f1qokCmvP1ssQd3yvgYUrdLli9Zx7fiGieb6aelChZWYLtNdeVx0cGbNQHRXNf0UabqhGyH7ygwAbWGt1W14ZcANit6nBHAeY4(aiFeSebc8MTqnczCFaKpIlyIKAJAZr6CaIezyxmo4)AmhIX1ij8urr2HmCuD4gRK)eIoV)fwL4(aKywVN8bzqYStATK0cRsCFasmR3t(Gmiz2jHmUpaYN)nuLAZr6CaIezyxmo4)AClJoKWtfDE)lSkX9biXSEpjg7enImSlglHmUpaYN9LIVxWnuLAZr6CaIezyxmo4)A1Hrf6lIoVFOfGFhCJLKZY8o4ghzCmgsKSGynllCnj1Hrf6lsiJ7dG8zdvtcDNPEcbYNXHSeY4(aiF2qvQnhPZbisKHDX4G)RFghYIoVF1Hrf6lsRfQnhPZbisKHDX4G)RRSRHruOVk0XfDE)VdzrcICIgH8gd(8oKfrI7RGAZr6CaIezyxmo4)AHJPgjldCuc1MJ05aejYWUyCW)1yoeJRrs4PIISdz4O6Wnwj)jeDE)plJjczuOd34Oo48Nnunj0DM6jeiXyIoUjke6AOeY4(aibcGUZupHajgt0XnrHqxdLqg3ha5tcXdUHQjPUHbQKGyGgVxeZCxvYahZWvQnhPZbisKHDX4G)RDYcJ049IAihfoMk1MJ05aejYWUyCW)1ymrh3efcDnKAZr6CaIezyxmo4)AitoGRdyl6q4jKAZr6CaIezyxmo4)AI64lCLfDE)ywVN0jlmsJ3lQHCu4yQsRLabEZwOgHmUpaYNe7rT5iDoarImSlgh8F9Z42X1ij8uQnhPZbisKHDX4G)RxDmMij8uQnhPZbisKHDX4G)RrHdUZqpscpLAZr6CaIezyxmo4)AmZDvsixP2CKohGirg2fJd(V2J4wWkdJ3lIGNqc1MJ05aejYWUyCW)1yoe6BSOZ7FHvjUpajM17jFqgKm7Kqg3hara8kyKLYrDWzQnhPZbisKHDX4G)RxDmMi6WXDqv059)oKfraOJObDKohqIBz0HeEQeDeLAZr6CaIezyxmo4)AmFlEVOch0QerN3pM17jXyIoUjke6AOSEcbbc8MTqnczCFaKp7rT5iDoarImSlgh8FDDGCeJDIsT5iDoarImSlgh8FnMdX4AKeEQOi7qgoQoCJvYFcrN3)B2c1iKX9bq(8nQnhPZbisKHDX4G)RDiYbCKeEQOZ7)DilIuhCoQxe3xXNnun5lo1g1MJ05aejrd(VgZHyCnscpv059VWQe3hGeZ69KpidsMDsRLKwyvI7dqIz9EYhKbjZojKX9bq(8VHQbc8SmMiKrHoCJJ6GZF2q1Kq3zQNqGeJj64MOqORHsiJ7dGeia6ot9ecKymrh3efcDnuczCFaKpjep4gQMK6ggOscIbA8ErmZDvjdCmdxP2CKohGijAW)1QdJk0xeDE)qla)o4gljNL5DWnoY4ymKizbXAww4AsQdJk0xKqg3ha5ZgQMe6ot9ecKpJdzjKX9bq(SHQuBosNdqKen4)6NXHSOZ7xDyuH(I0AHAZr6CaIKOb)xlCm1izzGJsO2CKohGijAW)1RogtKeEk1MJ05aejrd(V(zC74AKeEk1MJ05aejrd(VUYUggrH(Qqhx059)oKfjiYjAeYBm4Z7qwejUVcQnhPZbisIg8FnM5UkjKRuBosNdqKen4)ANSWinEVOgYrHJPsT5iDoars0G)RjQJVWvw059Jz9EsNSWinEVOgYrHJPkTwce4nBHAeY4(aiFsSh1MJ05aejrd(V2J4wWkdJ3lIGNqc1MJ05aejrd(VgJj64MOqORHuBosNdqKen4)AitoGRdyl6q4jKAZr6CaIKOb)xJchCNHEKeEk1MJ05aejrd(VE1XyIOdh3bvQnhPZbisIg8FnMVfVxuHdAvIOZ7hZ69Kymrh3efcDnuwpHGabEZwOgHmUpaYN9O2CKohGijAW)11bYrm2jk1MJ05aejrd(VgZHyCnscpv059)MTqnczCFaKpFJAZr6CaIKOb)xJ5qOVXuBosNdqKen4)A0Hb9ij8urN3ViEhYISsqhrd(oKfrc5ngK8fb6ot9ecKRogteD44oOkHmUpaYkjHifGJ05aYvhJjIoCChuLOJObcGUZupHa5QJXerhoUdQsiJ7dGiGeb3q1Kq3zQNqGeJj64MOqORHsiJ7dGe3SycraVdzrK6GZr9I4(kezsO7m1tiqU6ymr0HJ7GQeY4(aicirGaVzluJqg3ha5ZxT2A3]] )
    else
        spec:RegisterPack( "Beast Mastery", 20201012.1, [[dS0ffbqiIqpsurAteP(erWOKuCkjLwfiPYRaPMLOk3cKK2fQ(fvsdtsYXKeltuPNjQW0evuxdKyBeLY3ikPghrjoNKQyDsQsZtP4EuP2NOQoOKuyHev9qqszIGKiFuskzKGKOoPKu0kvkntIsYnbjH2jr0pbjbgkijOLcsQ6POyQejFvsk1yfveNvsQSxc)fyWKCyHfdQhJ0KPQldTzL8zLQrlkNwQvljv9AjvMTi3gL2Tk)wXWLWXjkvlhXZj10PCDQy7uj(oigVKQ68efRNOY8LO9RQfvesjy8HHcjZTQCRQsvvYLxLSKRSLJCwWyYuGcMIGwxSJcMlyrbJ8yOTxbvm0gsKrWueYKMWlKsWOhhcffmzMvORxxDDVTmhyoDyDv3SoPW65OKyzUQBwQRcgyNozvZtaly8HHcjZTQCRQsvvYLxLSKRSLRSiychlBicgMMfQjyYAVhpbSGXJAQGjN(k5XqBVcQyOnKiZRGk7Cgs(T50xbva1gyK8Qk5M3RYTQCR63(BZPVswHUGPxTX9RGsvCbtQ1MwiLGXJRWjzcPeswriLGjOwpNGHooNHeGoBmbdEbCc9c5fMqYCfsjyWlGtOxiVGHsAdjDiykiOlGDQNxHh6cKAGzbSmeaPt(xvw(kli7OXTMfb2a8n(QnVk3Qemb165emoAe0gYQfMqYCiKsWGxaNqVqEbtqTEobtiNoliHgSMZaZcumqqIGHsAdjDiyOZK8dKJh6cKAGzbSmeaPtEobzJ(0GDhuRF1MxvbkVs6xzbzhnU1SiWgGVXxL)RQuLG5cwuWeYPZcsObR5mWSafdeKimHK5SqkbdEbCc9c5fmb165emHoZL4qnGeYneaDirsWqjTHKoemEe2zT4KqUHaOdjsapc7SwCNIxj9RQ5vs8vOS70ffONhYPZcsObR5mWSafdeK8QYYxrNj5hihpKtNfKqdwZzGzbkgiiHtq2Op9RY)vYIS9QYYxHAnEuKdNMXdMfWYqaEiRmC2O6hYRQ9vs)QAEvbbDbSt98k8qxGudmlGLHaiDY)QYYxjXxHYUtxuGEovgAAmYCnfaNcT9kPFfSZAXdDbsnWSawgcG0jpNGSrF6xL)RQNxv7RK(v18kj(kuRXJIC6CE80OhK6fUgcf5Sr1pKxvw(kyN1IV7eeFhhywGqoKmwg3P4v1(kPFvnVYcYoA8mmswgVGAVAZRYbuEvz5RK4RqTgpkYPZ5XtJEqQx4AiuKZgv)qEvz5RK4RSiHNXRRtjKa6tB9rnoEbCc9VQ2xvw(QAELhHDwlojKBia6qIeWJWoRf3pqUxvw(kli7OXTMfb2a8n(QnVkxz7v1(kPFLfKD04wZIaBa(gFv(VQMxLBo)kOUxvZROZK8dKJtLHMgJmxtbWPqBCcYg9PFf0VkNF1MxzbzhnU1SiWgGVXxv7RQvWCblkycDMlXHAajKBia6qIKWescfHucg8c4e6fYlycQ1ZjyOYqtJrMRPa4uOnbdL0gs6qWa7SwCyuBDKaqiHLX9dK7vLLVYcYoACRzrGnaFJVAZRGIGbxlKAGlyrbdvgAAmYCnfaNcTjmHKYMqkbdEbCc9c5fmb165em0iLab165aPwBcMuRnWfSOGH61ctiPSwiLGbVaoHEH8cgkPnK0HGjOw7ccWdzBu)QnVkxbtqTEobdnsjqqTEoqQ1MGj1AdCblky0MWesklcPem4fWj0lKxWqjTHKoemb1AxqaEiBJ6xL)RQiycQ1ZjyOrkbcQ1ZbsT2emPwBGlyrbdnHHlOWeMGPGG0HfomHucjRiKsWGxaNqVqEbZfSOGjKtNfKqdwZzGzbkgiirWeuRNtWeYPZcsObR5mWSafdeKimHK5kKsWeuRNtWazijVlyFacQNlokkyWlGtOxiVWesMdHucMGA9CcMDNG474aZceYHKXYem4fWj0lKxycjZzHucMGA9CcgwKDiYaMfi5qBpWtWGvlyWlGtOxiVWescfHucg8c4e6fYlycQ1ZjyOYqtJrMRPa4uOnbdL0gs6qWiXxrI2dqxWZ495It6qsaNqow)wB6xj9RQ5vgPV6qJxHNfAaDMKFGCVc6xzK(QdnEU8SqdOZK8dK7vBEvUVQS8vOS70ffON7sq6aoHG(m80TjdyV3dxMKbgnTtPW6BhqWGAd5v1kyW1cPg4cwuWqLHMgJmxtbWPqBctiPSjKsWGxaNqVqEbdL0gs6qWiXxrI2dqxWZ495It6qsaNqow)wBAbtqTEobZAOoA0dc5qsBiagdwHjKuwlKsWGxaNqVqEbtbbPH2awZIcMk8CiycQ1ZjycDbsnWSawgcG0jVGHsAdjDiyK4Rc5qsBiVG0Src0N26JAAoEbCc9Vs6xjXxHAnEuKJAnEuemlGLHG1qD09TdAsR5Sr1pKxj9RQ5vOS70ffONhYPZcsObR5mWSafdeK8QYYxjXxHYUtxuGEovgAAmYCnfaNcT9QAfMqszriLGbVaoHEH8cMccsdTbSMffmv4qrWeuRNtWaJARJeacjSmbdL0gs6qWeYHK2qEbPzJeOpT1h10C8c4e6FL0VsIVc1A8Oih1A8OiywaldbRH6O7Bh0KwZzJQFiVs6xvZRqz3PlkqppKtNfKqdwZzGzbkgii5vLLVsIVcLDNUOa9CQm00yK5AkaofA7v1kmHK1JqkbdEbCc9c5fmb165emfJ1Zjy8YCbBtbfeSymbtfHjmbd1RfsjKSIqkbdEbCc9c5fmusBiPdbdDMKFGCCyuBDKaqiHLXjiB0N(v5)QCuLGjOwpNGjokQnsKa0iLeMqYCfsjyWlGtOxiVGHsAdjDiyOZK8dKJdJARJeacjSmobzJ(0Vk)xLJQemb165emRMGWPz8ctizoesjyWlGtOxiVGHsAdjDiyGDwlEOlqQbMfWYqaKo55ofVs6xvZRSGSJg3AweydW34RY)v0zs(bYXHrIgj113o37qcRN7vq)kVdjSEUxvw(QAELfKD04zyKSmEb1E1MxLdO8QYYxjXxzrcpJxxNsib0N26JAC8c4e6FvTVQ2xvw(kli7OXTMfb2a8n(QnVQsoemb165emWirJK66BxycjZzHucg8c4e6fYlyOK2qshcgyN1Ih6cKAGzbSmeaPtEUtXRK(v18kli7OXTMfb2a8n(Q8FfDMKFGCC40mEWYHid37qcRN7vq)kVdjSEUxvw(QAELfKD04zyKSmEb1E1MxLdO8QYYxjXxzrcpJxxNsib0N26JAC8c4e6FvTVQ2xvw(kli7OXTMfb2a8n(QnVQISjycQ1ZjyGtZ4blhImctijuesjyWlGtOxiVGHsAdjDiyGDwl(IGNCYWDkEL0Vc2zT4lcEYjdNGSrF6xL)R2PEoBu)xvw(kj(kyN1IVi4jNmCNcbtqTEobtQ3ZmnO6D87S4zctiPSjKsWGxaNqVqEbdL0gs6qWa7SwCyuBDKaqiHLXDkEL0Vc2zT4HUaPgywaldbq6KN7u8kPFLfKD04zyKSmEb1E1MxLdO8QYYxvZRQ5v050oSbCc5fJ1ZbMfW5GjTpHEWYHiZRklFfDoTdBaNqUZbtAFc9GLdrMxv7RK(vwq2rJBnlcSb4B8vBELSv5vLLVYcYoACRzrGnaFJVAZRYv2EvTcMGA9CcMIX65eMqszTqkbdEbCc9c5fmusBiPdbtnVQGGUa2PEEfEOlqQbMfWYqaKo5Fvz5ROZK8dKJh6cKAGzbSmeaPtEobzJ(0VAZR2P(xvw(kli7OXTMfb2a8n(QnVk3QEvTVQS8vs8vOwJhf5U06EoWSafizHuRNJZ23qemb165emqgsY7c2hGG65IJIctiPSiKsWGxaNqVqEbdL0gs6qWqNj5hihp0fi1aZcyziasN8CcYg9PF1MxvPQxvw(kli7OXTMfb2a8n(Q8FvqTEoaDMKFGCVc6x5DiH1Z9QYYxzbzhnU1SiWgGVXxT5v5OkbtqTEobZUtq8DCGzbc5qYyzctiz9iKsWeuRNtWq6IIec6dOlckkyWlGtOxiVWeswPkHucMGA9CcgwKDiYaMfi5qBpWtWGvlyWlGtOxiVWeswPIqkbdEbCc9c5fmusBiPdbJfKD04zyKSmEb1Ev(VswQ6vLLVYcYoA8mmswgVGAVAJ7xLBvVQS8vwq2rJBnlcSbuqnqUv9Q8FvoQsWeuRNtWqWOOVDWkfSOwyctWOnHucjRiKsWeuRNtWuxNsaD2ycg8c4e6fYlmHK5kKsWeuRNtWaNMXRZqVGbVaoHEH8ctizoesjyWlGtOxiVGHsAdjDiyGDwl(IGNCYWDkEL0Vc2zT4lcEYjdNGSrF6xT5v7u)RklFfDMKFGCCyuBDKaqiHLXjiB0N(vs)QAE1YjLaeKMfKDeynl(QnVAN6Fvz5Rc5qsBiVG0Src0N26JAAoEbCc9Vs6xrNj5hihp0fi1aZcyziasN8CcYg9PF1MxTt9VQwbtqTEobdCqGrpqNnMWesMZcPem4fWj0lKxWqjTHKoemRH6OFf0VAnuhnNG749kOUxTt9VAZRwd1rZzJ6)kPFfSZAXHrT1rcaHewg3pqUxj9RQ5vs8v(X405O4zKWqpyLcwea7qoobzJ(0Vs6xjXxfuRNJtNJINrcd9GvkyrEFGvQ3ZSxv7RklF1YjLaeKMfKDeynl(QnVAN6Fvz5RSGSJg3AweydW34R28kOiycQ1ZjyOZrXZiHHEWkfSOWescfHucg8c4e6fYlyOK2qshcgyN1Ih6cKAGzbSmeaPtEUFGCVs6xvZROZK8dKJdhey0d0zJXPzbzh1VAZRQ8QYYxjXxfYHK2qEbPzJeOpT1h10C8c4e6FvTcMGA9CcMqxGudmlGLHaiDYlmHKYMqkbdEbCc9c5fmusBiPdbdSZAXdDbsnWSawgcG0jp3P4vs)kyN1IdJARJeacjSmUtXRklFLfKD04wZIaBa(gF1MxvbkcMGA9CcgTfSfOhfMqszTqkbtqTEobtayDiEKaMfGsgiAbdEbCc9c5fMqszriLGbVaoHEH8cgkPnK0HGb2zT4WO26ibGqclJ7hi3RklFLfKD04wZIaBa(gF1MxbfbtqTEobZAOoA0dc5qsBiagdwHjKSEesjyWlGtOxiVGHsAdjDiyGDwlobP1LqTgSgcf5ofVQS8vWoRfNG06sOwdwdHIa64Cgs4AlO19QnVQsvVQS8vwq2rJBnlcSb4B8vBEfuemb165emwgcCo4X58G1qOOWeswPkHucg8c4e6fYlyOK2qshcgls4z85qaK2YawgckcADC8c4e6FL0Vc2zT4WO26ibGqclJtq2Op9R28QDQ)vLLVc2zT4WO26ibGqclJ7hi3RK(v0zs(bYXdDbsnWSawgcG0jpNGSrF6xL)RQaLxvw(kli7OXTMfb2a8n(QnVQcuEf0VAN6fmb165emWO26ibGqcltycjRuriLGbVaoHEH8cgkPnK0HGjKdjTHCFCuemlGhdlJtIRUxL)RQ8kPFfSZAX9XrrWSaEmSmobzJ(0VAZR2PEbtqTEobdCqGrpqNnMWeswjxHucg8c4e6fYlyOK2qshcgyN1Ih6cKAGzbSmeaPtEobzJ(0Vk)xvPQxb9R2P(xvw(kli7OXTMfb2a8n(QnVQsvVc6xTt9cMGA9Ccg40mEWSawgcWdzLrycjRKdHucMGA9CcM66ucqhw248cg8c4e6fYlmHKvYzHucg8c4e6fYlyOK2qshcgyN1IdJARJeacjSmUFGCVQS8vwq2rJBnlcSb4B8vBEfuemb165emWXoywaJ0060ctizfOiKsWeuRNtWqZA2ajbqNnMGbVaoHEH8ctizfztiLGjOwpNGX3eeaJH2em4fWj0lKxycjRiRfsjyWlGtOxiVGHsAdjDiySiHNXNdbqAldyziOiO1XXlGtO)vs)kAwq2rnyrcQ1ZfPxL)RQWHYRklFfnli7OgSib165I0RY)vv4YYRklFfDMKFGC8qxGudmlGLHaiDYZjiB0N(vBEfSZAXxe8KtgU3Hewp3RGQVAN6FL0VkKdjTH8csZgjqFARpQP54fWj0)QYYxzbzhnU1SiWgGVXxT5v1JGjOwpNGboiWOhOZgtycjRilcPem4fWj0lKxWqjTHKoemWoRfhg1whjaesyzC)a5Evz5RSGSJg3AweydW34R28kzrWeuRNtWu4q6Lm9TdGtH2eMqYk1JqkbtqTEobdCqiXokyWlGtOxiVWesMBvcPem4fWj0lKxWqjTHKoem18Q1qD0VcQ(k6OTxb9Rwd1rZj4oEVcQ7v18k6mj)a5411PeGoSSX55eKn6t)kO6RQ8QAFv(VkOwphVUoLa0HLnopNoA7vLLVIotYpqoEDDkbOdlBCEobzJ(0Vk)xv5vq)QDQ)vs)k6mj)a54WO26ibGqclJtq2Opny3b16xL)Rwd1rZTMfb2ayJ6)QYYxb7SwCwKDiYaMfi5qBpWtWGvZDkEvTVs6xrNj5hihVUoLa0HLnopNGSrF6xL)RQ8QYYxzbzhnU1SiWgGVXxT5v5qWeuRNtWqhysa0zJjmHK5wriLGbVaoHEH8cgkPnK0HGb2zT4lcEYjd37qcRN7vq1xTt9Vk)xTCsjabPzbzhbwZIcMGA9Ccg4GaJEGoBmHjmbdnHHlOqkHKvesjyWlGtOxiVGjOwpNGboiWOhOZgtWqjTHKoemWoRfFrWtoz4ofVs6xb7Sw8fbp5KHtq2Op9R24(v7upNnQVGHkdnHali7OPfswrycjZviLGbVaoHEH8cgkPnK0HGzN65Sr9Ffu9vWoRfhgdTbOjmCb5eKn6t)Q8Fvv8CHIGjOwpNGH1jzToBmHjKmhcPem4fWj0lKxWeuRNtWahey0d0zJjyOK2qshcMLtkbiinli7iWAw8vBE1o1ZzJ6)kPFfDMKFGCCyuBDKaqiHLXjiB0NwWqLHMqGfKD00cjRimHK5SqkbtqTEobtOlqQbMfWYqaKo5fm4fWj0lKxycjHIqkbdEbCc9c5fmusBiPdbdSZAXdDbsnWSawgcG0jp3P4vs)kyN1IdJARJeacjSmUtXRklFLfKD04wZIaBa(gF1MxvbkcMGA9CcgTfSfOhfMqsztiLGbVaoHEH8cgkPnK0HGHotYpqoEOlqQbMfWYqaKo55eKn6td2DqT(v5)QCR6vLLVYIeEgFoeaPTmGLHGIGwhhVaoH(xvw(kli7OXTMfb2a8n(QnVQcuemb165emWO26ibGqcltycjL1cPemb165em0SMnqsa0zJjyWlGtOxiVWesklcPemb165embG1H4rcywakzGOfm4fWj0lKxycjRhHucMGA9Ccg4GqIDuWGxaNqVqEHjKSsvcPem4fWj0lKxWqjTHKoemb1AxqaEiBJ6xT5v58RklFLeFvihsAd5KOO9acMMWZXlGtOxWeuRNtWuxNsa6WYgNxycjRuriLGjOwpNGX3eeaJH2em4fWj0lKxycjRKRqkbdEbCc9c5fmb165emWbbg9aD2ycgkPnK0HGb2zT4lcEYjd3pqUxj9RQ5v0SGSJAWIeuRNlsVk)xvHllVQS8vWoRfhg1whjaesyzCNIxv7RklFfDMKFGC8qxGudmlGLHaiDYZjiB0N(vBEfSZAXxe8KtgU3Hewp3RGQVAN6FL0VkKdjTH8csZgjqFARpQP54fWj0)QYYxrZcYoQblsqTEUi9Q8FvfEo)QYYxzbzhnU1SiWgGVXxT5v1JGHkdnHali7OPfswrycjRKdHucMGA9CcM1qD0OheYHK2qamgScg8c4e6fYlmHKvYzHucMGA9CcMchsVKPVDaCk0MGbVaoHEH8ctizfOiKsWeuRNtWqNJINrcd9GvkyrbdEbCc9c5fMqYkYMqkbtqTEobdCAgpywaldb4HSYiyWlGtOxiVWeswrwlKsWGxaNqVqEbdL0gs6qWa7SwCcsRlHAnynekYDkEvz5RGDwlobP1LqTgSgcfb0X5mKW1wqR7vBEvLQemb165emwgcCo4X58G1qOOWeswrwesjyWlGtOxiVGHsAdjDiyc5qsBiNefThqW0eEoEbCc9Vs6xfuRDbb4HSnQFv(VkxbtqTEobdRtYAD2yctizL6riLGbVaoHEH8cgkPnK0HGHotYpqoEDDkbOdlBCEobzJ(0Vk)xTgQJMBnlcSbWg1)vs)QAEvqT2feGhY2O(vBEvoEvz5RK4Rc5qsBiNefThqW0eEoEbCc9VQwbtqTEobdDGjbqNnMWeMWemUGeDpNqYCRk3QQuvvYAE9iyGeKRVDTGPAxnG6LSAkz1QEF1RKkdFvZwme7vRH8kj4Xv4Kmj8kck7onb9VspS4RchBydd9VIMf3oQ5)wzvF4RY569vqT5Cbjg6FLemsF1HgpNWPZK8dKtcVYMxjb6mj)a545ej8QAQu)A5)2FB1UAa1lz1uYQv9(Qxjvg(QMTyi2Rwd5vsG61s4veu2DAc6FLEyXxfo2Wgg6FfnlUDuZ)TYQ(WxbL69vqT5Cbjg6FLekqJNt4vhNZLWRS5vsO64CUeEvn5O(1Y)T)2QD1aQxYQPKvR69vVsQm8vnBXqSxTgYRKG2KWRiOS70e0)k9WIVkCSHnm0)kAwC7OM)BLv9HVkh17RGAZ5csm0)kjuGgpNWRooNlHxzZRKq1X5Cj8QAYT(1Y)TYQ(WxvrwxVVcQnNliXq)RKqbA8CcV64CUeELnVscvhNZLWRQPs9RL)BLv9HVk3k17RGAZ5csm0)kjuGgpNWRooNlHxzZRKq1X5Cj8QAQu)A5)2FB1UAa1lz1uYQv9(Qxjvg(QMTyi2Rwd5vsGMWWfucVIGYUttq)R0dl(QWXg2Wq)ROzXTJA(Vvw1h(Qk17RGAZ5csm0)kjuGgpNWRooNlHxzZRKq1X5Cj8QAYT(1Y)TYQ(WxLB9(kO2CUGed9VscfOXZj8QJZ5s4v28kjuDCoxcVQMk1Vw(Vvw1h(Qk5wVVcQnNliXq)RKqbA8CcV64CUeELnVscvhNZLWRQj36xl)3(BRMSfdXq)RGYRcQ1Z9QuRnn)3kykiZQtOGjN(k5XqBVcQyOnKiZRGk7Cgs(T50xbva1gyK8Qk5M3RYTQCR63(BZPVswHUGPxTX9RGsv8F7VnOwpNMxqq6Wchg0UD1rJG2q28UGfDhYPZcsObR5mWSafdeK8BdQ1ZP5feKoSWHbTBxHmKK3fSpab1Zfhf)Tb16508ccshw4WG2TR7obX3XbMfiKdjJL9BdQ1ZP5feKoSWHbTBxzr2HidywGKdT9apbdw9VnOwpNMxqq6Wchg0UD1rJG2q28W1cPg4cw0nvgAAmYCnfaNcTLxVClrs0Ea6cEgVpxCshsc4eYX63AtlDngPV6qJxHNfAaDMKFGCqBK(QdnEU8SqdOZK8dKBtULLOS70ffON7sq6aoHG(m80TjdyV3dxMKbgnTtPW6BhqWGAdP2FBqTEonVGG0HfomOD76AOoA0dc5qsBiagd286LBjsI2dqxWZ495It6qsaNqow)wB6FBo9vvdF17On9RSm8vEhsy9CVko)ROZK8dK7vZ6vvdDbsTxnRxzz4RQ2DY)Q48VcQqsZgPxvnpT1h10VcwMxzz4R8oKW65E1SEvCVY5YcTH(xvTGAqLEfKm8ELLHYibc(khn6FvbbPdlCy8xjpsdhn(QQHUaP2RM1RSm8vv7o5Ffb9ouu)QQfudQ0RGL5v5wvvS68ELL16x16xvHNJxPr6CEn)3guRNtZliiDyHddA3Ug6cKAGzbSmeaPt(8kiin0gWAw0DfEoYRxULyihsAd5fKMnsG(0wFutZXlGtOxAjIAnEuKJAnEuemlGLHG1qD09TdAsR5Sr1pePRbLDNUOa98qoDwqcnynNbMfOyGGKYsjIYUtxuGEovgAAmYCnfaNcTv7VnN(QQHV6D0M(vwg(kVdjSEUxfN)v0zs(bY9Qz9k5rT1r6vvBsyzVko)RGkhYHVAwVcQp2XxblZRSm8vEhsy9CVAwVkUx5CzH2q)RQwqnOsVcsgEVYYqzKabFLJg9VQGG0Hfom(VnOwpNMxqq6Wchg0UDfg1whjaesyz5vqqAOnG1SO7kCOKxVChYHK2qEbPzJeOpT1h10C8c4e6LwIOwJhf5OwJhfbZcyziynuhDF7GM0AoBu9dr6Aqz3PlkqppKtNfKqdwZzGzbkgiiPSuIOS70ffONtLHMgJmxtbWPqB1(BdQ1ZP5feKoSWHbTBxlgRNlpVmxW2uqbblgZDLF7VnOwpNgA3UshNZqcqNn2VnOwpNgA3U6OrqBiRoVE5UGGUa2PEEfEOlqQbMfWYqaKo5llTGSJg3AweydW34MCR63guRNtdTBxD0iOnKnVlyr3HC6SGeAWAodmlqXabj51l30zs(bYXdDbsnWSawgcG0jpNGSrFAWUdQ1BQafPTGSJg3AweydW3y(vQ63guRNtdTBxD0iOnKnVlyr3HoZL4qnGeYneaDirkVE52JWoRfNeYneaDirc4ryN1I7uiDnseLDNUOa98qoDwqcnynNbMfOyGGKYsJ0xDOXd50zbj0G1CgywGIbcs40zs(bYXjiB0NoFzr2klrTgpkYHtZ4bZcyziapKvgoBu9dPwPRPGGUa2PEEfEOlqQbMfWYqaKo5llLik7oDrb65uzOPXiZ1uaCk0M0WoRfp0fi1aZcyziasN8CcYg9PZVEQv6AKiQ14rroDopEA0ds9cxdHIC2O6hszjSZAX3DcIVJdmlqihsglJ7uuR01ybzhnEggjlJxqTn5akLLse1A8OiNoNhpn6bPEHRHqroBu9dPSuIwKWZ411Pesa9PT(OghVaoH(AllRXJWoRfNeYneaDirc4ryN1I7hixzPfKD04wZIaBa(g3KRSvR0wq2rJBnlcSb4Bm)AYnNH6QHotYpqoovgAAmYCnfaNcTXjiB0Ng6CEJfKD04wZIaBa(gRT2FBqTEon0UD1rJG2q28W1cPg4cw0nvgAAmYCnfaNcTLxVCd7SwCyuBDKaqiHLX9dKRS0cYoACRzrGnaFJBGYVnOwpNgA3UsJuceuRNdKATL3fSOBQx)BdQ1ZPH2TR0iLab165aPwB5Dbl6wB51l3b1AxqaEiBJ6n5(BdQ1ZPH2TR0iLab165aPwB5Dbl6MMWWfmVE5oOw7ccWdzBuNFLF7VnOwpNMt9A3XrrTrIeGgPuE9YnDMKFGCCyuBDKaqiHLXjiB0No)Cu1VnOwpNMt9AOD76QjiCAgFE9YnDMKFGCCyuBDKaqiHLXjiB0No)Cu1VnOwpNMt9AOD7kms0iPU(2ZRxUHDwlEOlqQbMfWYqaKo55ofsxJfKD04wZIaBa(gZNotYpqooms0iPU(25Ehsy9Cq7DiH1ZvwwJfKD04zyKSmEb12KdOuwkrls4z866ucjG(0wFuJJxaNqFT1wwAbzhnU1SiWgGVXnvYXVnOwpNMt9AOD7kCAgpy5qKjVE5g2zT4HUaPgywaldbq6KN7uiDnwq2rJBnlcSb4BmF6mj)a54WPz8GLdrgU3Hewph0Ehsy9CLL1ybzhnEggjlJxqTn5akLLs0IeEgVUoLqcOpT1h144fWj0xBTLLwq2rJBnlcSb4BCtfz73guRNtZPEn0UDn17zMgu9o(Dw8S86L7c04SrFCyN1IVi4jNmCNcPlqJZg9XHDwl(IGNCYWjiB0No)DQNZg1VSuIfOXzJ(4WoRfFrWtoz4of)2GA9CAo1RH2TRfJ1ZLxVCd7SwCyuBDKaqiHLXDkKg2zT4HUaPgywaldbq6KN7uiTfKD04zyKSmEb12KdOuwwtn050oSbCc5fJ1ZbMfW5GjTpHEWYHitzjDoTdBaNqUZbtAFc9GLdrMAL2cYoACRzrGnaFJBKTkLLwq2rJBnlcSb4BCtUYwT)2GA9CAo1RH2TRqgsY7c2hGG65IJI51l31uqqxa7upVcp0fi1aZcyziasN8LL0zs(bYXdDbsnWSawgcG0jpNGSrF6n7uFzPfKD04wZIaBa(g3KBv1wwkruRXJICxADphywGcKSqQ1ZXz7Bi)2GA9CAo1RH2TR7obX3XbMfiKdjJLLxVCtNj5hihp0fi1aZcyziasN8CcYg9P3uPQYsli7OXTMfb2a8nMpDMKFGCq7DiH1ZvwAbzhnU1SiWgGVXn5OQFBqTEonN61q72vsxuKqqFaDrqXFBqTEonN61q72vwKDiYaMfi5qBpWtWGv)BdQ1ZP5uVgA3UsWOOVDWkfSOoVE52cYoA8mmswgVGA5llvvwAbzhnEggjlJxqTnUZTQYsli7OXTMfb2akOgi3QYphv9B)Tb1650CAcdxqOD7kCqGrpqNnwEuzOjeybzhnT7k51l3fOXzJ(4WoRfFrWtoz4ofsxGgNn6Jd7Sw8fbp5KHtq2Op9g37upNnQ)VnOwpNMtty4ccTBxzDswRZglVE5EN65Sr9HQfOXzJ(4WoRfhgdTbOjmCb5eKn6tNFv8CHYVnOwpNMtty4ccTBxHdcm6b6SXYJkdnHali7OPDxjVE5E5KsacsZcYocSMf3St9C2O(stNj5hihhg1whjaesyzCcYg9P)Tb1650CAcdxqOD7AOlqQbMfWYqaKo5)Tb1650CAcdxqOD7Q2c2c0J51l3WoRfp0fi1aZcyziasN8CNcPHDwlomQTosaiKWY4ofLLwq2rJBnlcSb4BCtfO8BdQ1ZP50egUGq72vyuBDKaqiHLLxVCtNj5hihp0fi1aZcyziasN8CcYg9Pb7oOwNFUvvwArcpJphcG0wgWYqqrqRJJxaNqFzPfKD04wZIaBa(g3ubk)2GA9CAonHHli0UDLM1SbscGoBSFBqTEonNMWWfeA3UgawhIhjGzbOKbI(3guRNtZPjmCbH2TRWbHe74VnOwpNMtty4ccTBxRRtjaDyzJZNxVChuRDbb4HSnQ3KZLLsmKdjTHCsu0Eabtt454fWj0)BdQ1ZP50egUGq72vFtqamgA73guRNtZPjmCbH2TRWbbg9aD2y5rLHMqGfKD00URKxVCxGgNn6Jd7Sw8fbp5KH7hiN01qZcYoQblsqTEUiLFfUSuwc7SwCyuBDKaqiHLXDkQTSKotYpqoEOlqQbMfWYqaKo55eKn6tVPanoB0hh2zT4lcEYjd37qcRNdQUt9shYHK2qEbPzJeOpT1h10C8c4e6llPzbzh1GfjOwpxKYVcpNllTGSJg3AweydW34M653guRNtZPjmCbH2TRRH6OrpiKdjTHaymy)Tb1650CAcdxqOD7AHdPxY03oaofA73guRNtZPjmCbH2TR05O4zKWqpyLcw83guRNtZPjmCbH2TRWPz8GzbSmeGhYkZVnOwpNMtty4ccTBxTme4CWJZ5bRHqX86LByN1ItqADjuRbRHqrUtrzjSZAXjiTUeQ1G1qOiGooNHeU2cADBQu1VnOwpNMtty4ccTBxzDswRZglVE5oKdjTHCsu0Eabtt454fWj0lDqT2feGhY2Oo)C)Tb1650CAcdxqOD7kDGjbqNnwE9YnDMKFGC866ucqhw248CcYg9PZFnuhn3AweydGnQV01euRDbb4HSnQ3KJYsjgYHK2qojkApGGPj8C8c4e6R93(BdQ1ZP5AZDDDkb0zJ9BdQ1ZP5AdA3UcNMXRZq)VnOwpNMRnOD7kCqGrpqNnwE9YDbAC2OpoSZAXxe8KtgUtH0fOXzJ(4WoRfFrWtoz4eKn6tVzN6llPZK8dKJdJARJeacjSmobzJ(0sxZYjLaeKMfKDeynlUzN6lld5qsBiVG0Src0N26JAAoEbCc9stNj5hihp0fi1aZcyziasN8CcYg9P3St91(BdQ1ZP5AdA3UsNJINrcd9GvkyX86L71qD0qVgQJMtWD8G62P(nRH6O5Sr9Lg2zT4WO26ibGqclJ7hiN01ir)yC6Cu8msyOhSsblcGDihNGSrFAPLyqTEooDokEgjm0dwPGf59bwPEpZQTSC5KsacsZcYocSMf3St9LLwq2rJBnlcSb4BCdu(Tb1650CTbTBxdDbsnWSawgcG0jFE9YnSZAXdDbsnWSawgcG0jp3pqoPRHotYpqooCqGrpqNngNMfKDuVPszPed5qsBiVG0Src0N26JAAoEbCc91(BdQ1ZP5AdA3UQTGTa9yE9YnSZAXdDbsnWSawgcG0jp3PqAyN1IdJARJeacjSmUtrzPfKD04wZIaBa(g3ubk)2GA9CAU2G2TRbG1H4rcywakzGO)Tb1650CTbTBxxd1rJEqihsAdbWyWMxVCd7SwCyuBDKaqiHLX9dKRS0cYoACRzrGnaFJBGYVnOwpNMRnOD7QLHaNdECopynekMxVCd7SwCcsRlHAnynekYDkklHDwlobP1LqTgSgcfb0X5mKW1wqRBtLQklTGSJg3AweydW34gO8BdQ1ZP5AdA3UcJARJeacjSS86LBls4z85qaK2YawgckcADC8c4e6Lg2zT4WO26ibGqclJtq2Op9MDQVSe2zT4WO26ibGqclJ7hiN00zs(bYXdDbsnWSawgcG0jpNGSrF68RaLYsli7OXTMfb2a8nUPcuGEN6)Tb1650CTbTBxHdcm6b6SXYRxUd5qsBi3hhfbZc4XWY4K4Ql)ksd7SwCFCuemlGhdlJtq2Op9MDQ)3guRNtZ1g0UDfonJhmlGLHa8qwzYRxUHDwlEOlqQbMfWYqaKo55eKn6tNFLQGEN6llTGSJg3AweydW34Mkvb9o1)BdQ1ZP5AdA3UwxNsa6WYgN)3guRNtZ1g0UDfo2bZcyKMwNoVE5g2zT4WO26ibGqclJ7hixzPfKD04wZIaBa(g3aLFBqTEonxBq72vAwZgija6SX(Tb1650CTbTBx9nbbWyOTFBqTEonxBq72v4GaJEGoBS86LBls4z85qaK2YawgckcADC8c4e6LMMfKDudwKGA9Crk)kCOuwsZcYoQblsqTEUiLFfUSuwsNj5hihp0fi1aZcyziasN8CcYg9P3uGgNn6Jd7Sw8fbp5KH7DiH1Zbv3PEPd5qsBiVG0Src0N26JAAoEbCc9LLwq2rJBnlcSb4BCt98BdQ1ZP5AdA3Uw4q6Lm9TdGtH2YRxUHDwlomQTosaiKWY4(bYvwAbzhnU1SiWgGVXnYYVnOwpNMRnOD7kCqiXo(BdQ1ZP5AdA3Ushysa0zJLxVCxZAOoAOkD0g0RH6O5eChpOUAOZK8dKJxxNsa6WYgNNtq2OpnuTsT5huRNJxxNsa6WYgNNthTvwsNj5hihVUoLa0HLnopNGSrF68Ra9o1lnDMKFGCCyuBDKaqiHLXjiB0NgS7GAD(RH6O5wZIaBaSr9llHDwlolYoezaZcKCOTh4jyWQ5of1knDMKFGC866ucqhw248CcYg9PZVszPfKD04wZIaBa(g3KJFBqTEonxBq72v4GaJEGoBS86L7c04SrFCyN1IVi4jNmCVdjSEoO6o1N)YjLaeKMfKDeynlky0fivizUqjhctycb]] )
    end


end
