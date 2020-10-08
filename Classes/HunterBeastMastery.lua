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
            value = function () return conduit.necrotic_barrage.enabled and 5 or 3 end,
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
        spec:RegisterPack( "Beast Mastery", 20201007.9, [[dKeENaqikvPhrGkBse5teqJIq4ueIwLiQQxjqZIq6wkjIDr0VusnmLQ6yIWYiu9mvLmnLe11uQY2iq5BuQQgNsI05uvkRtevMNQI7PQAFeGdsGKwOsLhsGuFKavzKeOQojLQOvsPmtvLk3uvPQ2Pi5NIOkTuvLQ8ujMQi1xjqIXsPkCwkvL9k1FfAWI6WuTyO8yitwsxg1MvLpRugTGoTIvlIQ41kjnBkUnuTBGFRYWvIJtGy5GEoIPt66uY2ju(obnELeopLkRxeL5lG9J0DIoDxQUYDkX3x89tS)(2Vu8ejw5UO2TWDzXrR6BCxaoo3LDStuA(77eLH21Lf3oZ51oDxiNfeXDju1fsYTE92OHwys0HVMm4wgxNdGG(txtgC06UGzng1EcASUuDL7uIVV47Ny)9TFP4js81EF1f3sdpyxkdUGUlHtTYGgRlvMG6IGJM3XorP5VVtugAhnl4BbugsTj4O5KxKEymKMTFrPzX3x89P2O2eC083XIXgAwa08E7l7IzikPt3Lk)ClJ2P7uj60DXr6CGUGolGYWij80UWahZW1ExRDkX70DXr6CGUOqhiiwJzs2a2IKWt7cdCmdx7DT2P(Qt3fg4ygU276ccokdhVllqwS4gQktiDYcJ049IAihfoMknhian)MTqnczCFaeA(dnl((DXr6CGUyr44OmoP1o1k3P7cdCmdx7DDXr6CGUGCJj6iDoq0meTlMHOrGJZDbvjT2P2Rt3fg4ygU276ccokdhVloshX4idy8Hj08hAw8U4iDoqxqUXeDKohiAgI2fZq0iWX5Uq0w7ucwNUlmWXmCT31feCugoExCKoIXrgW4dtOzbqZj6IJ05aDb5gt0r6CGOziAxmdrJahN7cYWUyCRT2LfiJoCmx70DQeD6U4iDoqxiw44hiUWAxyGJz4AVR1oL4D6UWahZW1ExxqWrz44DbAb43b3yj5SmVdUXrghJHejliwZYcx7IJ05aDrDyuH(sRDQV60DHboMHR9UUSazKt0Oo4Cxsi)QlosNd0fNSWinEVOgYrHJP2ANAL70DHboMHR9UUSazKt0Oo4Cxsi3RlosNd0fmMOJBIcHUg2feCugoExSxAwDddujbXanEViM5UQKboMHR0Cs0S9sZqla)o4gljNL5DWnoY4ymKizbXAww4ARDQ960DHboMHR9UU4iDoqxwoDoqxQ2bC8bfxG8YPDjrRT2fuL0P7uj60DHboMHR9UUGGJYWX7c6ot9ecKymrh3efcDnuczCFaeAwa08x73fhPZb6IdqmrHUjICJP1oL4D6UWahZW1ExxqWrz44DbDNPEcbsmMOJBIcHUgkHmUpacnlaA(R97IJ05aD5nqgZCxT1o1xD6UWahZW1ExxqWrz44DbZ69KozHrA8ErnKJchtvATqZjrZIGMFZwOgHmUpacnlaAgDNPEcbsmgsy4QdytwTGUohGMdsZvlORZbO5abOzrqZQd3yvgYUrdLliLM)qZFThnhianBV0S6ggOYvhJHHXbq0bGujdCmdxPzrsZIKMdeGMFZwOgHmUpacn)HMt8vxCKohOlymKWWvhWwRDQvUt3fg4ygU276ccokdhVlywVN0jlmsJ3lQHCu4yQsRfAojAwe08B2c1iKX9bqOzbqZO7m1tiqIzURgFwq7KvlORZbO5G0C1c66CaAoqaAwe0S6WnwLHSB0q5csP5p08x7rZbcqZ2lnRUHbQC1XyyyCaeDaivYahZWvAwK0SiP5abO53SfQriJ7dGqZFO5ecwxCKohOlyM7QXNf0Uw7u71P7cdCmdx7DDbbhLHJ3fmR3t(Gmiz2jTwO5KOzmR3t(Gmiz2jHmUpacnlaAEdvL4(kO5abOz7LMXSEp5dYGKzN0APlosNd0fZSfQKyYJvDdNbARDkbRt3fg4ygU276ccokdhVlywVNeJj64MOqORHsRfAojAgZ69KozHrA8ErnKJchtvATqZjrZQd3yvgYUrdLliLM)qZFThnhianlcAwe0m6aelChZWYLtNdeVx0cGbNQHRXNf0oAoqaAgDaIfUJzyPfadovdxJplOD0SiP5KO53SfQriJ7dGqZFOzblbnhian)MTqnczCFaeA(dnlUGrZISlosNd0LLtNd0ARDHOD6ovIoDxyGJz4AVRli4OmC8UGz9EYhKbjZoP1cnNenJz9EYhKbjZojKX9bqO5p)08gQsZbcqZplJjczuOd34Oo4mn)HM3qvAojAgDNPEcbsmMOJBIcHUgkHmUpacnhianJUZupHajgt0XnrHqxdLqg3haHM)qZjeNMdsZBOknNenRUHbQKGyGgVxeZCxvYahZW1U4iDoqxWCigxJKWtBTtjENUlmWXmCT31feCugoExGwa(DWnwsolZ7GBCKXXyirYcI1SSWvAojAwDyuH(IeY4(ai08hAEdvP5KOz0DM6jeiFghYsiJ7dGqZFO5nuTlosNd0f1Hrf6lT2P(Qt3fg4ygU276ccokdhVlQdJk0xKwlDXr6CGU8moKBTtTYD6U4iDoqxeoMAKSmWrjDHboMHR9Uw7u71P7IJ05aDz1XyIKWt7cdCmdx7DT2PeSoDxCKohOlpJBhxJKWt7cdCmdx7DT2PS)oDxyGJz4AVRli4OmC8U8oKfHMdsZiNOriVXaA(dn)oKfrI7ROlosNd0Lk7Ayef6RcD8w7uR0oDxCKohOlyM7QKqU2fg4ygU27ATt9ToDxCKohOlozHrA8ErnKJchtTlmWXmCT31ANkX(D6UWahZW1ExxqWrz44DbZ69KozHrA8ErnKJchtvATqZbcqZVzluJqg3haHM)qZj2RlosNd0fI64lCLBTtLirNUlosNd0fpIBbRmmEVicEcjDHboMHR9Uw7ujeVt3fhPZb6cgt0XnrHqxd7cdCmdx7DT2Ps8vNUlosNd0fitoGRdyl6q4jSlmWXmCT31ANkXk3P7IJ05aDbfo4od9ij80UWahZW1ExRDQe71P7IJ05aDz1XyIOdh3b1UWahZW1ExRDQecwNUlmWXmCT31feCugoExWSEpjgt0XnrHqxdL1tiGMdeGMFZwOgHmUpacn)HM3RlosNd0fmFlEVOch0QKw7ujS)oDxCKohOl1bYrm2jAxyGJz4AVR1ovIvANUlmWXmCT31feCugoExEZwOgHmUpacn)HM)wxCKohOlyoeJRrs4PT2Ps8ToDxCKohOlyoe6BCxyGJz4AVR1oL473P7cdCmdx7DDbbhLHJ3frqZVdzrO5vcnJoIsZbP53HSisiVXaAo5tZIGMr3zQNqGC1XyIOdh3bvjKX9bqO5vcnNGMfjnlaA2r6Ca5QJXerhoUdQs0ruAoqaAgDNPEcbYvhJjIoCChuLqg3haHMfanNGMdsZBOknNenJUZupHajgt0XnrHqxdLqg3hajUzXecnlaA(DilIuhCoQxe3xbnlsAojAgDNPEcbYvhJjIoCChuLqg3haHMfanNGMdeGMFZwOgHmUpacn)HM)QlosNd0f0Hb9ij80wBTlid7IXD6ovIoDxyGJz4AVRlosNd0fmhIX1ij80UGGJYWX7cM17jFqgKm7Kwl0Cs0mM17jFqgKm7Kqg3haHM)8tZBOAxq2HmCuD4gRKovIw7uI3P7cdCmdx7DDbbhLHJ3fmR3tIXorJid7IXsiJ7dGqZFO59LIVhnhKM3q1U4iDoqxWTm6qcpT1o1xD6UWahZW1ExxqWrz44DbAb43b3yj5SmVdUXrghJHejliwZYcxP5KOz1Hrf6lsiJ7dGqZFO5nuLMtIMr3zQNqG8zCilHmUpacn)HM3q1U4iDoqxuhgvOV0ANAL70DHboMHR9UUGGJYWX7I6WOc9fP1sxCKohOlpJd5w7u71P7cdCmdx7DDbbhLHJ3L3HSi0CqAg5enc5ngqZFO53HSisCFfDXr6CGUuzxdJOqFvOJ3ANsW60DXr6CGUiCm1izzGJs6cdCmdx7DT2PS)oDxyGJz4AVRlosNd0fmhIX1ij80UGGJYWX7YZYyIqgf6WnoQdotZFO5nuLMtIMr3zQNqGeJj64MOqORHsiJ7dGqZbcqZO7m1tiqIXeDCtui01qjKX9bqO5p0CcXP5G08gQsZjrZQByGkjigOX7fXm3vLmWXmCTli7qgoQoCJvsNkrRDQvANUlosNd0fNSWinEVOgYrHJP2fg4ygU27ATt9ToDxCKohOlymrh3efcDnSlmWXmCT31ANkX(D6U4iDoqxGm5aUoGTOdHNWUWahZW1ExRDQej60DHboMHR9UUGGJYWX7cM17jDYcJ049IAihfoMQ0AHMdeGMFZwOgHmUpacn)HMtSxxCKohOle1Xx4k3ANkH4D6U4iDoqxEg3oUgjHN2fg4ygU27ATtL4RoDxCKohOlRogtKeEAxyGJz4AVR1ovIvUt3fhPZb6ckCWDg6rs4PDHboMHR9Uw7uj2Rt3fhPZb6cM5UkjKRDHboMHR9Uw7ujeSoDxCKohOlEe3cwzy8Ere8es6cdCmdx7DT2Psy)D6UWahZW1ExxqWrz44DbZ69KpidsMDsiJ7dGqZcGM5vWilLJ6GZDXr6CGUG5qOVXT2PsSs70DHboMHR9UUGGJYWX7Y7qweAwa0m6iknhKMDKohqIBz0HeEQeDeTlosNd0LvhJjIoCChuBTtL4BD6UWahZW1ExxqWrz44DbZ69Kymrh3efcDnuwpHaAoqaA(nBHAeY4(ai08hAEVU4iDoqxW8T49IkCqRsATtj((D6U4iDoqxQdKJySt0UWahZW1ExRDkXt0P7cdCmdx7DDXr6CGUG5qmUgjHN2feCugoExEZwOgHmUpacn)HM)wxq2HmCuD4gRKovIw7uIlENUlmWXmCT31feCugoExEhYIi1bNJ6fX9vqZFO5nuLMt(0S4DXr6CGU4qKd4ij80wBT1UigdjZb6uIVV47V)3(AF53(23(236IqhcgWgPlckcQFVu2ZucEjhntZPdzAEWxoOsZVdsZcevjcKMHSGynqUsZKdNPz3spCx5knJcDWgtKuBF3ayAEVKJMf0hqmgQCLMf4cRs7H0(KsPaPz9OzbAFsPuG0Si(AfIusTrTjOiO(9szptj4LC0mnNoKP5bF5Gkn)oinlqIkqAgYcI1a5kntoCMMDl9WDLR0mk0bBmrsT9DdGP5ejhnlOpGymu5knlWfwL2dP9jLsbsZ6rZc0(KsPaPzri(kePKAJAtqrq97LYEMsWl5OzAoDitZd(YbvA(DqAwGid7IXcKMHSGynqUsZKdNPz3spCx5knJcDWgtKuBF3ayAorYrZc6digdvUsZcCHvP9qAFsPuG0SE0SaTpPukqAweIVcrkP2(UbW0S4jhnlOpGymu5knlWfwL2dP9jLsbsZ6rZc0(KsPaPzrKyfIusT9DdGP5e2FYrZc6digdvUsZcCHvP9qAFsPuG0SE0SaTpPukqAwejwHiLuBuB2t8LdQCLM3JMDKohGMndrjsQTUqwyuNs89(QllW7ngUlcoAEh7eLM)(orzOD0SGVfqzi1MGJMtEr6HXqA2(fLMfFFX3NAJAtWrZFhlgBOzbqZ7TVKAJAZr6CaICbYOdhZ1G)Rjw44hiUWk1MJ05ae5cKrhoMRb)xRomQqFr059dTa87GBSKCwM3b34iJJXqIKfeRzzHRuBosNdqKlqgD4yUg8FTtwyKgVxud5OWXufDbYiNOrDW5)eYVO2CKohGixGm6WXCn4)AmMOJBIcHUgk6cKrorJ6GZ)jK7j68(Tx1nmqLeed049IyM7Qsg4ygUMK9cTa87GBSKCwM3b34iJJXqIKfeRzzHRuBosNdqKlqgD4yUg8F9YPZbeTAhWXhuCbYlN(NGAJAZr6CasW)1OZcOmmscpLAZr6CasW)1k0bcI1yMKnGTij8uQnhPZbib)xBr44Omor059VazXIBOQmH0jlmsJ3lQHCu4yQbc8MTqnczCFaKpIVp1MJ05aKG)RrUXeDKohiAgIkkWX5FuLqT5iDoaj4)AKBmrhPZbIMHOIcCC(NOIoVFhPJyCKbm(WKpItT5iDoaj4)AKBmrhPZbIMHOIcCC(hzyxmw0597iDeJJmGXhMiGeuBuBosNdqKOkj4)AhGyIcDte5gJOZ7hDNPEcbsmMOJBIcHUgkHmUpaIa(AFQnhPZbisuLe8F9BGmM5UQOZ7hDNPEcbsmMOJBIcHUgkHmUpaIa(AFQnhPZbisuLe8FngdjmC1bSj68(XSEpPtwyKgVxud5OWXuLwljjI3SfQriJ7dGia0DM6jeiXyiHHRoGnz1c66CGGvlORZbceqeQd3yvgYUrdLli9Zx7fiG9QUHbQC1XyyyCaeDaivYahZWvrkYabEZwOgHmUpaYNeFrT5iDoarIQKG)RXm3vJplODIoVFmR3t6KfgPX7f1qokCmvP1ssI4nBHAeY4(aicaDNPEcbsmZD14ZcANSAbDDoqWQf015abcic1HBSkdz3OHYfK(5R9ceWEv3WavU6ymmmoaIoaKkzGJz4QifzGaVzluJqg3ha5tcbJAZr6CaIevjb)xBMTqLetESQB4mqfDE)lSkX9biXSEp5dYGKzN0AjPfwL4(aKywVN8bzqYStczCFaebSHQsCFfbcyVlSkX9biXSEp5dYGKzN0AHAZr6CaIevjb)xVC6CarN3pM17jXyIoUjke6AO0AjjmR3t6KfgPX7f1qokCmvP1ssQd3yvgYUrdLli9Zx7fiGieb6aelChZWYLtNdeVx0cGbNQHRXNf0UabqhGyH7ygwAbWGt1W14ZcANit6nBHAeY4(aiFeSebc8MTqnczCFaKpIlyIKAJAZr6CaIezyxmo4)AmhIX1ij8urr2HmCuD4gRK)eIoV)fwL4(aKywVN8bzqYStATK0cRsCFasmR3t(Gmiz2jHmUpaYN)nuLAZr6CaIezyxmo4)AClJoKWtfDE)lSkX9biXSEpjg7enImSlglHmUpaYN9LIVxWnuLAZr6CaIezyxmo4)A1Hrf6lIoVFOfGFhCJLKZY8o4ghzCmgsKSGynllCnj1Hrf6lsiJ7dG8zdvtcDNPEcbYNXHSeY4(aiF2qvQnhPZbisKHDX4G)RFghYIoVF1Hrf6lsRfQnhPZbisKHDX4G)RRSRHruOVk0XfDE)VdzrcICIgH8gd(8oKfrI7RGAZr6CaIezyxmo4)AHJPgjldCuc1MJ05aejYWUyCW)1yoeJRrs4PIISdz4O6Wnwj)jeDE)plJjczuOd34Oo48Nnunj0DM6jeiXyIoUjke6AOeY4(aibcGUZupHajgt0XnrHqxdLqg3ha5tcXdUHQjPUHbQKGyGgVxeZCxvYahZWvQnhPZbisKHDX4G)RDYcJ049IAihfoMk1MJ05aejYWUyCW)1ymrh3efcDnKAZr6CaIezyxmo4)AitoGRdyl6q4jKAZr6CaIezyxmo4)AI64lCLfDE)ywVN0jlmsJ3lQHCu4yQsRLabEZwOgHmUpaYNe7rT5iDoarImSlgh8F9Z42X1ij8uQnhPZbisKHDX4G)RxDmMij8uQnhPZbisKHDX4G)RrHdUZqpscpLAZr6CaIezyxmo4)AmZDvsixP2CKohGirg2fJd(V2J4wWkdJ3lIGNqc1MJ05aejYWUyCW)1yoe6BSOZ7FHvjUpajM17jFqgKm7Kqg3hara8kyKLYrDWzQnhPZbisKHDX4G)RxDmMi6WXDqv059)oKfraOJObDKohqIBz0HeEQeDeLAZr6CaIezyxmo4)AmFlEVOch0QerN3pM17jXyIoUjke6AOSEcbbc8MTqnczCFaKp7rT5iDoarImSlgh8FDDGCeJDIsT5iDoarImSlgh8FnMdX4AKeEQOi7qgoQoCJvYFcrN3)B2c1iKX9bq(8nQnhPZbisKHDX4G)RDiYbCKeEQOZ7)DilIuhCoQxe3xXNnun5lo1g1MJ05aejrd(VgZHyCnscpv059VWQe3hGeZ69KpidsMDsRLKwyvI7dqIz9EYhKbjZojKX9bq(8VHQbc8SmMiKrHoCJJ6GZF2q1Kq3zQNqGeJj64MOqORHsiJ7dGeia6ot9ecKymrh3efcDnuczCFaKpjep4gQMK6ggOscIbA8ErmZDvjdCmdxP2CKohGijAW)1QdJk0xeDE)qla)o4gljNL5DWnoY4ymKizbXAww4AsQdJk0xKqg3ha5ZgQMe6ot9ecKpJdzjKX9bq(SHQuBosNdqKen4)6NXHSOZ7xDyuH(I0AHAZr6CaIKOb)xlCm1izzGJsO2CKohGijAW)1RogtKeEk1MJ05aejrd(V(zC74AKeEk1MJ05aejrd(VUYUggrH(Qqhx059)oKfjiYjAeYBm4Z7qwejUVcQnhPZbisIg8FnM5UkjKRuBosNdqKen4)ANSWinEVOgYrHJPsT5iDoars0G)RjQJVWvw059Jz9EsNSWinEVOgYrHJPkTwce4nBHAeY4(aiFsSh1MJ05aejrd(V2J4wWkdJ3lIGNqc1MJ05aejrd(VgJj64MOqORHuBosNdqKen4)AitoGRdyl6q4jKAZr6CaIKOb)xJchCNHEKeEk1MJ05aejrd(VE1XyIOdh3bvQnhPZbisIg8FnMVfVxuHdAvIOZ7hZ69Kymrh3efcDnuwpHGabEZwOgHmUpaYN9O2CKohGijAW)11bYrm2jk1MJ05aejrd(VgZHyCnscpv059)MTqnczCFaKpFJAZr6CaIKOb)xJ5qOVXuBosNdqKen4)A0Hb9ij8urN3ViEhYISsqhrd(oKfrc5ngK8fb6ot9ecKRogteD44oOkHmUpaYkjHifGJ05aYvhJjIoCChuLOJObcGUZupHa5QJXerhoUdQsiJ7dGiGeb3q1Kq3zQNqGeJj64MOqORHsiJ7dGe3SycraVdzrK6GZr9I4(kezsO7m1tiqU6ymr0HJ7GQeY4(aicirGaVzluJqg3ha5ZxT2A3]] )
    else
        spec:RegisterPack( "Beast Mastery", 20200930.11199, [[dSepfbqiuuEevQOnru5tOqnkLKoLsIvPuu1RaOzjk5wkPu7cv)IkXWucDmLOLjk1ZOsPPHIQUMsQ2gvk6BuPQmoQuPZrLQSoLIY8ukDprX(ucoikewik4HOOYerHK(Osk0iPsvvNujfSsa8sQuvXmrHu3uPOYorrgkvQQ0srHepfOPsu6ROq0yPsfoRskzVK8xKgmHdlSyu6XiMmvDzOnlPpRunAr1PLA1kPOxRuy2ICBISBv(TIHlHJtLclh0Zj10PCDQy7uj9DanELICEII1tu18LO9RQvlvYQa9HHkMYEXSxCr3l715l6Elz(1ZwbAYuGkWIGSrSJkWlKqfidyOTxS5cTHqzuGfHmPj8kzvG6XbsqfyUzf6nZfx2Bl3HLtgjx0TKtkSEocmQMl6wI4IcK1Pt2A4uSkqFyOIPSxm7fx09YED(IU3sMN5Zwbgow(avGGTeZPaZBVhpfRc0JAIc0D(cgWqBVyZfAdHY8c3FNZq4dG78fGyHHsSi8fzVEwVi7fZEXhGha35ly0ORy6fBZ8I1xKRatT20kzvGESgojtjRIPLkzvGbX65uGKX5mes15JPaXlytOxXGYumLTswfiEbBc9kguGeyBiSdfybeDLUt88L8qxGeJovQLJuGDY)IYYxybChnU1si1gQVXxS9fzVOcmiwpNc0rJ02qjTYum5wLSkq8c2e6vmOadI1ZPad515bm006CgDQ0IbicvGeyBiSdfizMKFaE8qxGeJovQLJuGDYZHOu0NMU7GA9l2(ILR)c5EHfWD04wlHuBO(gFXcVy5IkWlKqfyiVopGHMwNZOtLwmarOYumX8kzvG4fSj0RyqbgeRNtbg6CxJd1uyi)aPKbgjfib2gc7qb6rwNALdd5hiLmWir9iRtTYDkEHCVy1xWSxGUHtxuGEEiVopGHMwNZOtLwmar4lklFbzMKFaE8qEDEadnToNrNkTyaIqoeLI(0VyHx4UU5lklFbQ14rqoBAgpDQulhP4HsYWLI1CGVyLxi3lw9ffq0v6oXZxYdDbsm6uPwosb2j)lklFbZEb6goDrb65eziPXGZ1ekBk02lK7fSo1kp0fiXOtLA5ifyN8Cikf9PFXcVW9EXkVqUxS6ly2lqTgpcYjZ5XtJEAQRyDGeKlfR5aFrz5lyDQv(Uta9DC0Psd5r4y5CNIxSYlK7fR(clG7OXZXiz58cI9ITVWTR)IYYxWSxGAnEeKtMZJNg90uxX6ajixkwZb(IYYxWSxyrcpJVrNsiK2N26JyC8c2e6FXkVOS8fR(cpY6uRCyi)aPKbgjQhzDQvUFaEVOS8fwa3rJBTesTH6B8fBFr2U5lw5fY9clG7OXTwcP2q9n(IfEXQViBM)fB(xS6liZK8dWJtKHKgdoxtOSPqBCikf9PFbGVG5FX2xybChnU1si1gQVXxSYlwrbEHeQadDURXHAkmKFGuYaJKYumTUswfiEbBc9kguGbX65uGeziPXGZ1ekBk0McKaBdHDOazDQvolQTosuGWWY5(b49IYYxybChnU1si1gQVXxS9fRRaXAfjg9cjubsKHKgdoxtOSPqBktXKBQKvbIxWMqVIbfyqSEofijsjAqSEoAQ1Mcm1AJEHeQajETYum5(uYQaXlytOxXGcKaBdHDOadI1UIu8qPg1Vy7lYwbgeRNtbsIuIgeRNJMATPatT2OxiHkqTPmftURswfiEbBc9kguGeyBiSdfyqS2vKIhk1O(fl8ILkWGy9CkqsKs0Gy9C0uRnfyQ1g9cjubssy4kQmLPalGizKydtjRIPLkzvG4fSj0RyqbEHeQad515bm006CgDQ0IbicvGbX65uGH868agAADoJovAXaeHktXu2kzvGbX65uGahyY7k2hfI65IJGkq8c2e6vmOmftUvjRcmiwpNcC3jG(oo6uPH8iCSCfiEbBc9kguMIjMxjRcmiwpNcucLgOm0PstoK2t9qmK0kq8c2e6vmOmftRRKvbIxWMqVIbfyqSEofirgsAm4CnHYMcTPajW2qyhkqM9cy0Ek6kEgVpxDshcd2eYXn1At)c5EXQVWG9TbA8L88qtjZK8dW7fa(cd23gOXZMNhAkzMKFaEVy7lY(fLLVaDdNUOa9CxdyhSjK2NHNUnzO79E46Km6OjDkfwF7uigeBGVyffiwRiXOxiHkqImK0yW5AcLnfAtzkMCtLSkq8c2e6vmOajW2qyhkqM9cy0Ek6kEgVpxDshcd2eYXn1AtRadI1ZPaRdXrJEAipcBdPSyiPmftUpLSkq8c2e6vmOalGij0g1AjubUK7wfyqSEofyOlqIrNk1YrkWo5vGeyBiSdfiZEripcBd5fWwks0(0wFetZXlytO)fY9cM9cuRXJGCuRXJG0PsTCKwhIJUVDAdBnxkwZb(c5EXQVaDdNUOa98qEDEadnToNrNkTyaIWxuw(cM9c0nC6Ic0ZjYqsJbNRju2uOTxSIYum5UkzvG4fSj0RyqbwarsOnQ1sOcCjFDfyqSEofilQTosuGWWYvGeyBiSdfyipcBd5fWwks0(0wFetZXlytO)fY9cM9cuRXJGCuRXJG0PsTCKwhIJUVDAdBnxkwZb(c5EXQVaDdNUOa98qEDEadnToNrNkTyaIWxuw(cM9c0nC6Ic0ZjYqsJbNRju2uOTxSIYum5EkzvG4fSj0RyqbgeRNtbwmwpNc0lZfsnHwaXIXuGlvMYuGeVwjRIPLkzvG4fSj0RyqbsGTHWouGKzs(b4XzrT1rIcegwohIsrF6xSWlC7IkWGy9CkW4iO2GrIsIuszkMYwjRceVGnHEfdkqcSne2HcKmtYpapolQTosuGWWY5quk6t)IfEHBxubgeRNtbwBiYMMXRmftUvjRceVGnHEfdkqcSne2HcK1Pw5HUajgDQulhPa7KN7u8c5EXQVWc4oACRLqQnuFJVyHxqMj5hGhNfHAeUrF7CVdmSEUxa4l8oWW65Erz5lw9fwa3rJNJrYY5fe7fBFHBx)fLLVGzVWIeEgFJoLqiTpT1hX44fSj0)IvEXkVOS8fwa3rJBTesTH6B8fBFXs3QadI1ZPazrOgHB03UYumX8kzvG4fSj0RyqbsGTHWouGSo1kp0fiXOtLA5ifyN8CNIxi3lw9fwa3rJBTesTH6B8fl8cYmj)a84SPz80QdugU3bgwp3la8fEhyy9CVOS8fR(clG7OXZXiz58cI9ITVWTR)IYYxWSxyrcpJVrNsiK2N26JyC8c2e6FXkVyLxuw(clG7OXTwcP2q9n(ITVyPBQadI1ZPaztZ4PvhOmktX06kzvG4fSj0RyqbsGTHWouGSo1kVcXtEz4ofVqUxW6uR8kep5LHdrPOp9lw4f7epxk20lklFbZEbRtTYRq8KxgUtHcmiwpNcm175MMUMo(Dj8mLPyYnvYQaXlytOxXGcKaBdHDOazDQvolQTosuGWWY5ofVqUxW6uR8qxGeJovQLJuGDYZDkEHCVWc4oA8CmswoVGyVy7lC76VOS8fR(IvFbzoTJuWMqEXy9C0PsDowy7tONwDGY8IYYxqMt7ifSjK7CSW2NqpT6aL5fR8c5EHfWD04wlHuBO(gFX2x4MlFrz5lSaUJg3AjKAd134l2(ISDZxSIcmiwpNcSySEoLPyY9PKvbIxWMqVIbfib2gc7qbU6lkGOR0DINVKh6cKy0PsTCKcSt(xuw(cYmj)a84HUajgDQulhPa7KNdrPOp9l2(IDI)fLLVWc4oACRLqQnuFJVy7lYEXxSYlklFbZEbQ14rqURTUNJovAbcRiX654s9nqfyqSEofiWbM8UI9rHOEU4iOYum5UkzvG4fSj0RyqbsGTHWouGKzs(b4XdDbsm6uPwosb2jphIsrF6xS9flx8fLLVWc4oACRLqQnuFJVyHxeeRNJsMj5hG3la8fEhyy9CVOS8fwa3rJBTesTH6B8fBFHBxubgeRNtbU7eqFhhDQ0qEeowUYum5EkzvGbX65uGWUOiH0(O6IGGkq8c2e6vmOmftlxujRcmiwpNcucLgOm0PstoK2t9qmK0kq8c2e6vmOmftlxQKvbIxWMqVIbfib2gc7qbAbChnEogjlNxqSxSWlC3fFrz5lSaUJgphJKLZli2l2M5fzV4lklFHfWD04wlHuBOfeJM9IVyHx42fvGbX65uGqmk6BNwtHeQvMYuGAtjRIPLkzvGbX65uGB0PevNpMceVGnHEfdktXu2kzvGbX65uGSPz86C0RaXlytOxXGYum5wLSkq8c2e6vmOajW2qyhkqwNALxH4jVmCNIxi3lyDQvEfIN8YWHOu0N(fBFXoX)IYYxqMj5hGhNf1whjkqyy5Cikf9PFHCVy1xuDsjkej5bChPwlHVy7l2j(xuw(IqEe2gYlGTuKO9PT(iMMJxWMq)lK7fKzs(b4XdDbsm6uPwosb2jphIsrF6xS9f7e)lwrbgeRNtbYgqw0t15JPmftmVswfiEbBc9kguGeyBiSdfyDio6xa4lQdXrZH4oEVyZ)IDI)fBFrDioAUuSPxi3lyDQvolQTosuGWWY5(b49c5EXQVGzVWpgNmhbpdgg6P1uiHuwh4XHOu0N(fY9cM9IGy9CCYCe8myyONwtHeY7Jwt9EU9IvErz5lQoPefIK8aUJuRLWxS9f7e)lklFHfWD04wlHuBO(gFX2xSUcmiwpNcKmhbpdgg6P1uiHktX06kzvG4fSj0RyqbsGTHWouGSo1kp0fiXOtLA5ifyN8C)a8EHCVy1xqMj5hGhNnGSONQZhJtYd4oQFX2xS8fLLVGzViKhHTH8cylfjAFARpIP54fSj0)IvuGbX65uGHUajgDQulhPa7KxzkMCtLSkq8c2e6vmOajW2qyhkqwNALh6cKy0PsTCKcStEUtXlK7fSo1kNf1whjkqyy5CNIxuw(clG7OXTwcP2q9n(ITVy56kWGy9CkqTfsfOhvMIj3NswfyqSEofyqLCGEesNkLahGAfiEbBc9kguMIj3vjRceVGnHEfdkqcSne2HcK1Pw5SO26irbcdlN7hG3lklFHfWD04wlHuBO(gFX2xSUcmiwpNcSoehn6PH8iSnKYIHKYum5EkzvG4fSj0RyqbsGTHWouGSo1khIKnsOwtRdKGCNIxuw(cwNALdrYgjuRP1bsqkzCodHCTfKnEX2xSCXxuw(clG7OXTwcP2q9n(ITVyDfyqSEofOLJuNJDCopToqcQmftlxujRceVGnHEfdkqcSne2Hc0IeEgFoKcSTCQLJ0IGSbhVGnH(xi3lyDQvolQTosuGWWY5quk6t)ITVyN4Frz5lyDQvolQTosuGWWY5(b49c5EbzMKFaE8qxGeJovQLJuGDYZHOu0N(fl8ILR)IYYxybChnU1si1gQVXxS9flx)fa(IDIxbgeRNtbYIARJefimSCLPyA5sLSkq8c2e6vmOajW2qyhkWqEe2gY9Xrq6uPEmSComUnEXcVy5lK7fSo1k3hhbPtL6XWY5quk6t)ITVyN4vGbX65uGSbKf9uD(yktX0YSvYQaXlytOxXGcKaBdHDOazDQvEOlqIrNk1YrkWo55quk6t)IfEXYfFbGVyN4Frz5lSaUJg3AjKAd134l2(ILl(caFXoXRadI1ZPaztZ4PtLA5ifpusgLPyAPBvYQadI1ZPa3OtjkzKKIZRaXlytOxXGYumTK5vYQaXlytOxXGcKaBdHDOazDQvolQTosuGWWY5(b49IYYxybChnU1si1gQVXxS9fRRadI1ZPazJD6uPgSjBOvMIPLRRKvbgeRNtbsYBPaHbvNpMceVGnHEfdktX0s3ujRcmiwpNc03qKYIH2uG4fSj0RyqzkMw6(uYQaXlytOxXGcKaBdHDOaTiHNXNdPaBlNA5iTiiBWXlytO)fY9csEa3rnTcdI1ZfPxSWlwYx)fLLVGKhWDutRWGy9Cr6fl8ILC39fLLVGmtYpapEOlqIrNk1YrkWo55quk6t)ITVG1Pw5viEYld37adRN7fR9l2j(xi3lc5ryBiVa2srI2N26JyAoEbBc9VOS8fwa3rJBTesTH6B8fBFH7PadI1ZPazdil6P68XuMIPLURswfiEbBc9kguGeyBiSdfiRtTYzrT1rIcegwo3paVxuw(clG7OXTwcP2q9n(ITVWDvGbX65uGfoWUktF7u2uOnLPyAP7PKvbgeRNtbYgqySJkq8c2e6vmOmftzVOswfiEbBc9kguGeyBiSdf4QVOoeh9lw7xqgT9caFrDioAoe3X7fB(xS6liZK8dWJVrNsuYijfNNdrPOp9lw7xS8fR8IfErqSEo(gDkrjJKuCEoz02lklFbzMKFaE8n6uIsgjP48Cikf9PFXcVy5la8f7e)lK7fKzs(b4XzrT1rIcegwohIsrFA6UdQ1VyHxuhIJMBTesTHkfB6fLLVG1Pw5sO0aLHovAYH0EQhIHKM7u8IvEHCVGmtYpap(gDkrjJKuCEoeLI(0VyHxS8fLLVWc4oACRLqQnuFJVy7lCRcmiwpNcKmSWGQZhtzkMYEPswfiEbBc9kguGeyBiSdfiRtTYRq8KxgU3bgwp3lw7xSt8VyHxuDsjkej5bChPwlHkWGy9Ckq2aYIEQoFmLPmfijHHROswftlvYQaXlytOxXGcmiwpNcKnGSONQZhtbsGTHWouGSo1kVcXtEz4ofVqUxW6uR8kep5LHdrPOp9l2M5f7epxk2KcKidjHulG7OPvmTuzkMYwjRceVGnHEfdkqcSne2HcCN45sXMEXA)cwNALZIH2OKegUICikf9PFXcVyrE2RRadI1ZPaLCswRZhtzkMCRswfiEbBc9kguGbX65uGSbKf9uD(ykqcSne2HcS6KsuisYd4osTwcFX2xSt8CPytVqUxqMj5hGhNf1whjkqyy5Cikf9PvGezijKAbChnTIPLktXeZRKvbgeRNtbg6cKy0PsTCKcStEfiEbBc9kguMIP1vYQaXlytOxXGcKaBdHDOazDQvEOlqIrNk1YrkWo55ofVqUxW6uRCwuBDKOaHHLZDkErz5lSaUJg3AjKAd134l2(ILRRadI1ZPa1wivGEuzkMCtLSkq8c2e6vmOajW2qyhkqYmj)a84HUajgDQulhPa7KNdrPOpnD3b16xSWlYEXxuw(cls4z85qkW2YPwoslcYgC8c2e6Frz5lSaUJg3AjKAd134l2(ILRRadI1ZPazrT1rIcegwUYum5(uYQadI1ZPaj5TuGWGQZhtbIxWMqVIbLPyYDvYQadI1ZPadQKd0Jq6uPe4auRaXlytOxXGYum5EkzvGbX65uGSbeg7OceVGnHEfdktX0YfvYQaXlytOxXGcKaBdHDOadI1UIu8qPg1Vy7ly(xuw(cM9IqEe2gYHrr7PqmnHNJxWMqVcmiwpNcCJoLOKrskoVYumTCPswfyqSEofOVHiLfdTPaXlytOxXGYumTmBLSkq8c2e6vmOadI1ZPazdil6P68XuGeyBiSdfiRtTYRq8KxgUFaEVqUxS6li5bCh10kmiwpxKEXcVyj3DFrz5lyDQvolQTosuGWWY5ofVyLxuw(cYmj)a84HUajgDQulhPa7KNdrPOp9l2(cwNALxH4jVmCVdmSEUxS2VyN4FHCViKhHTH8cylfjAFARpIP54fSj0)IYYxqYd4oQPvyqSEUi9IfEXsoZ)IYYxybChnU1si1gQVXxS9fUNcKidjHulG7OPvmTuzkMw6wLSkWGy9CkW6qC0ONgYJW2qklgskq8c2e6vmOmftlzELSkWGy9CkWchyxLPVDkBk0MceVGnHEfdktX0Y1vYQadI1ZPajZrWZGHHEAnfsOceVGnHEfdktX0s3ujRcmiwpNcKnnJNovQLJu8qjzuG4fSj0RyqzkMw6(uYQaXlytOxXGcKaBdHDOazDQvoejBKqTMwhib5ofVOS8fSo1khIKnsOwtRdKGuY4Cgc5AliB8ITVy5IkWGy9CkqlhPoh74CEADGeuzkMw6UkzvG4fSj0RyqbsGTHWouGH8iSnKdJI2tHyAcphVGnH(xi3lcI1UIu8qPg1VyHxKTcmiwpNcuYjzToFmLPyAP7PKvbIxWMqVIbfib2gc7qbsMj5hGhFJoLOKrskophIsrF6xSWlQdXrZTwcP2qLIn9c5EXQViiw7ksXdLAu)ITVWTVOS8fm7fH8iSnKdJI2tHyAcphVGnH(xSIcmiwpNcKmSWGQZhtzktzkqxrOUNtXu2lM9Il6MlzEfiWaE9TRvGmsgbJctRbMwJB2lEHS54lAPIbAVOoWxWypwdNKX4xar3WPHO)f6rcFr4yJuyO)fK842rn)bGr3h(cMFZEbZnNRi0q)lySb7Bd04UdozMKFaEm(f28cgtMj5hGh3DW4xS6YnTc)b4bGrYiyuyAnW0ACZEXlKnhFrlvmq7f1b(cgt8Ag)ci6gone9Vqps4lchBKcd9VGKh3oQ5pam6(WxS(M9cMBoxrOH(xW4c04Ud(AX5Cg)cBEbJxloNZ4xSQB30k8hGhagjJGrHP1atRXn7fVq2C8fTuXaTxuh4lyS2y8lGOB40q0)c9iHViCSrkm0)csEC7OM)aWO7dFHB3SxWCZ5kcn0)cgxGg3DWxloNZ4xyZly8AX5Cg)IvZEtRWFay09HVyP7BZEbZnNRi0q)lyCbAC3bFT4CoJFHnVGXRfNZz8lwD5MwH)aWO7dFr2l3SxWCZ5kcn0)cgxGg3DWxloNZ4xyZly8AX5Cg)IvxUPv4papamsgbJctRbMwJB2lEHS54lAPIbAVOoWxWyscdxrg)ci6gone9Vqps4lchBKcd9VGKh3oQ5pam6(WxSCZEbZnNRi0q)lyCbAC3bFT4CoJFHnVGXRfNZz8lwn7nTc)bGr3h(IS3SxWCZ5kcn0)cgxGg3DWxloNZ4xyZly8AX5Cg)IvxUPv4pam6(WxSm7n7fm3CUIqd9VGXfOXDh81IZ5m(f28cgVwCoNXVy1S30k8hGhG1GuXan0)I1FrqSEUxKATP5pakWc4u7eQaDNVGbm02l2CH2qOmVW935me(a4oFbiwyOelcFr2RN1lYEXSx8b4bWD(cgn6kMEX2mVy9f5papabX6508cisgj2WamJloAK2gkL1fsyMqEDEadnToNrNkTyaIWhGGy9CAEbejJeByaMXfGdm5Df7Jcr9CXrWhGGy9CAEbejJeByaMXLDNa674OtLgYJWXYFacI1ZP5fqKmsSHbygxKqPbkdDQ0KdP9upedj9dqqSEonVaIKrInmaZ4IJgPTHszH1ksm6fsygImK0yW5AcLnfAlRUMHzWO9u0v8mEFU6KoegSjKJBQ1MwUvnyFBGgFjpp0uYmj)a8a0G9TbA8S55HMsMj5hG32Sllr3WPlkqp31a2bBcP9z4PBtg6EVhUojJoAsNsH13ofIbXg4kpabX6508cisgj2WamJl1H4OrpnKhHTHuwmKYQRzygmApfDfpJ3NRoPdHbBc54MATPFaCNVGr4xthTPFHLJVW7adRN7fX5FbzMKFaEVyQVGrOlqI9IP(clhFbJSt(xeN)fUFHTuKEXA40wFet)cwzEHLJVW7adRN7ft9fX9cNlp0g6FXAK5yuFbWC8EHLJYWyi(chn6FrbejJeBy8xWaschn(cgHUaj2lM6lSC8fmYo5Fbe9oeu)I1iZXO(cwzEr2lUOKoRxy5T(fT(fl5U9fAKmNxZFacI1ZP5fqKmsSHbygxcDbsm6uPwosb2jFwfqKeAJATeMzj3Tz11mmlKhHTH8cylfjAFARpIP54fSj0lhZqTgpcYrTgpcsNk1YrADio6(2PnS1CPynhOCRIUHtxuGEEiVopGHMwNZOtLwmaryzjZq3WPlkqpNidjngCUMqztH2w5bWD(cgHFnD0M(fwo(cVdmSEUxeN)fKzs(b49IP(cgqT1r6fmsyy5Vio)lC)d5Xxm1xWOe74lyL5fwo(cVdmSEUxm1xe3lCU8qBO)fRrMJr9faZX7fwokdJH4lC0O)ffqKmsSHXFacI1ZP5fqKmsSHbygxyrT1rIcegwEwfqKeAJATeMzjF9S6AMqEe2gYlGTuKO9PT(iMMJxWMqVCmd1A8iih1A8iiDQulhP1H4O7BN2WwZLI1CGYTk6goDrb65H868agAADoJovAXaeHLLmdDdNUOa9CImK0yW5AcLnfABLhGGy9CAEbejJeByaMXLIX65YYlZfsnHwaXIXYS8b4biiwpNgWmUqgNZqivNp2dqqSEonGzCXrJ02qjDwDntbeDLUt88L8qxGeJovQLJuGDYxwAbChnU1si1gQVXTzV4dqqSEonGzCXrJ02qPSUqcZeYRZdyOP15m6uPfdqeMvxZqMj5hGhp0fiXOtLA5ifyN8Cikf9PP7oOwVD56YzbChnU1si1gQVXfwU4dqqSEonGzCXrJ02qPSUqcZe6CxJd1uyi)aPKbgPS6AgpY6uRCyi)aPKbgjQhzDQvUtHCRYm0nC6Ic0Zd515bm006CgDQ0IbicllnyFBGgpKxNhWqtRZz0PslgGiKtMj5hGhhIsrF6fCx3SSe1A8iiNnnJNovQLJu8qjz4sXAoWvKB1ci6kDN45l5HUajgDQulhPa7KVSKzOB40ffONtKHKgdoxtOSPqBYX6uR8qxGeJovQLJuGDYZHOu0NEb3Bf5wLzOwJhb5K584Prpn1vSoqcYLI1CGLLSo1kF3jG(oo6uPH8iCSCUtXkYTQfWD045yKSCEbX2621llzgQ14rqozopEA0ttDfRdKGCPynhyzjZSiHNX3Otjes7tB9rmoEbBc9RuwUQhzDQvomKFGuYaJe1JSo1k3paVYslG7OXTwcP2q9nUnB3Cf5SaUJg3AjKAd134cRMnZV5xLmtYpaporgsAm4CnHYMcTXHOu0NgqMFRfWD04wlHuBO(gxzLhGGy9CAaZ4IJgPTHszH1ksm6fsygImK0yW5AcLnfAlRUMH1Pw5SO26irbcdlN7hGxzPfWD04wlHuBO(g3U(dqqSEonGzCHePeniwphn1AlRlKWmeV(biiwpNgWmUqIuIgeRNJMATL1fsygTLvxZeeRDfP4HsnQ3M9dqqSEonGzCHePeniwphn1AlRlKWmKegUIz11mbXAxrkEOuJ6fw(a8aeeRNtZjEnGzCjocQnyKOKiLYQRziZK8dWJZIARJefimSCoeLI(0l42fFacI1ZP5eVgWmUuBiYMMXNvxZqMj5hGhNf1whjkqyy5Cikf9PxWTl(aeeRNtZjEnGzCHfHAeUrF7z11mSo1kp0fiXOtLA5ifyN8CNc5w1c4oACRLqQnuFJlqMj5hGhNfHAeUrF7CVdmSEoa9oWW65klx1c4oA8CmswoVGyBD76LLmZIeEgFJoLqiTpT1hX44fSj0VYkLLwa3rJBTesTH6BC7s3(aeeRNtZjEnGzCHnnJNwDGYKvxZW6uR8qxGeJovQLJuGDYZDkKBvlG7OXTwcP2q9nUazMKFaEC20mEA1bkd37adRNdqVdmSEUYYvTaUJgphJKLZli2w3UEzjZSiHNX3Otjes7tB9rmoEbBc9RSszPfWD04wlHuBO(g3U0nFacI1ZP5eVgWmUK69Cttxth)UeEwwDntbACPOpoRtTYRq8KxgUtHCfOXLI(4So1kVcXtEz4quk6tVWoXZLInvwYSc04srFCwNALxH4jVmCNIhGGy9CAoXRbmJlfJ1ZLvxZW6uRCwuBDKOaHHLZDkKJ1Pw5HUajgDQulhPa7KN7uiNfWD045yKSCEbX2621llxDvYCAhPGnH8IX65OtL6CSW2NqpT6aLPSKmN2rkyti35yHTpHEA1bkZkYzbChnU1si1gQVXTU5YYslG7OXTwcP2q9nUnB3CLhGGy9CAoXRbmJlahyY7k2hfI65IJGz11mRwarxP7epFjp0fiXOtLA5ifyN8LLKzs(b4XdDbsm6uPwosb2jphIsrF6T7eFzPfWD04wlHuBO(g3M9IRuwYmuRXJGCxBDphDQ0cewrI1ZXL6BGpabX650CIxdygx2DcOVJJovAipchlpRUMHmtYpapEOlqIrNk1YrkWo55quk6tVD5ILLwa3rJBTesTH6BCbYmj)a8a07adRNRS0c4oACRLqQnuFJBD7IpabX650CIxdygxGDrrcP9r1fbbFacI1ZP5eVgWmUiHsdug6uPjhs7PEigs6hGGy9CAoXRbmJlqmk6BNwtHeQZQRzSaUJgphJKLZli2cU7ILLwa3rJNJrYY5feBBMSxSS0c4oACRLqQn0cIrZEXfC7IpapabX650CTbygxC)0P0laZh7biiwpNMRnaZ4cdPz86C0)aeeRNtZ1gGzCHHaYI(xaMpwwDntbACPOpoRtTYRq8KxgUtHCfOXLI(4So1kVcXtEz4quk6tVDN4lljZK8dWJZIARJefimSCoeLI(0YTA1jLOqKKhWDKATeUDN4lld5ryBiVa2srI2N26JyAoEbBc9YrMj5hGhp0fiXOtLA5ifyN8Cikf9P3Ut8R8aeeRNtZ1gGzCHmhbpdgg6P1uiHz11m1H4ObSoehnhI74T53j(T1H4O5sXMKJ1Pw5SO26irbcdlN7hGNCRYm)yCYCe8myyONwtHeszDGhhIsrFA5ywqSEoozocEgmm0tRPqc59rRPEp3wPSS6KsuisYd4osTwc3Ut8LLwa3rJBTesTH6BC76pabX650CTbygxye6cKyVyQVWYXxWi7KpRUMH1Pw5HUajgDQulhPa7KN7hGNCRsMj5hGhNnGSONQZhJtYd4oQ3USSKzH8iSnKxaBPir7tB9rmnhVGnH(vEacI1ZP5AdWmUaAHub6XS6AgwNALh6cKy0PsTCKcStEUtHCSo1kNf1whjkqyy5CNIYslG7OXTwcP2q9nUD56pabX650CTbygxyeVyZ5a9i8ft9fmhCaQFacI1ZP5AdWmUuhIJg90qEe2gszXqkRUMH1Pw5SO26irbcdlN7hGxzPfWD04wlHuBO(g3U(dqqSEonxBaMXflhPoh74CEADGemRUMH1Pw5qKSrc1AADGeK7uuwY6uRCis2iHAnToqcsjJZziKRTGSX2LlwwAbChnU1si1gQVXTR)aeeRNtZ1gGzCHbuBDKEbJegwEwDnJfj8m(CifyB5ulhPfbzdoEbBc9YX6uRCwuBDKOaHHLZHOu0NE7oXxwY6uRCwuBDKOaHHLZ9dWtoYmj)a84HUajgDQulhPa7KNdrPOp9clxVS0c4oACRLqQnuFJBxUoG7e)dqqSEonxBaMXfgcil6Fby(yz11mH8iSnK7JJG0Ps9yy5CyCBSWs5yDQvUpocsNk1JHLZHOu0NE7oX)aeeRNtZ1gGzCHnnJNovQLJu8qjzYQRzyDQvEOlqIrNk1YrkWo55quk6tVWYfbCN4llTaUJg3AjKAd1342Llc4oX)aeeRNtZ1gGzCX9tNsVG5gjP48pabX650CTbygxyJD6uPgSjBOZQRzyDQvolQTosuGWWY5(b4vwAbChnU1si1gQVXTR)aeeRNtZ1gGzCH5YBPaHXlaZh7biiwpNMRnaZ4cJAdXxWagA7biiwpNMRnaZ4cdbKf9VamFSS6Agls4z85qkW2YPwoslcYgC8c2e6LJKhWDutRWGy9CrAHL81llj5bCh10kmiwpxKwyj3DlljZK8dWJh6cKy0PsTCKcStEoeLI(0BlqJlf9XzDQvEfIN8YW9oWW65w7DIxUqEe2gYlGTuKO9PT(iMMJxWMqFzPfWD04wlHuBO(g36EpabX650CTbygxkCGDvM(2PSPqBz11mSo1kNf1whjkqyy5C)a8klTaUJg3AjKAd134w39biiwpNMRnaZ4cdbeg74dqqSEonxBaMXfMByHXlaZhlRUMz16qC0Rnz0gG1H4O5qChVn)QKzs(b4X3OtjkzKKIZZHOu0NETxUYcbX654B0PeLmssX55KrBLLKzs(b4X3OtjkzKKIZZHOu0NEHLaUt8YrMj5hGhNf1whjkqyy5Cikf9PP7oOwVqDioAU1si1gQuSPYswNALlHsdug6uPjhs7PEigsAUtXkYrMj5hGhFJoLOKrskophIsrF6fwwwAbChnU1si1gQVXTU9biiwpNMRnaZ4cdbKf9VamFSS6AMc04srFCwNALxH4jVmCVdmSEU1EN4xO6KsuisYd4osTwcFaEacI1ZP5KegUIaMXfgcil6Fby(yzrKHKqQfWD00zwMvxZuGgxk6JZ6uR8kep5LH7uixbACPOpoRtTYRq8KxgoeLI(0BZSt8CPytpabX650CscdxraZ4YMZjz9AdMpwwDnZoXZLInT2fOXLI(4So1kNfdTrjjmCf5quk6tVWI8Sx)biiwpNMtsy4kcygxyiGSO)fG5JLfrgscPwa3rtNzzwDnt1jLOqKKhWDKATeUDN45sXMKJmtYpapolQTosuGWWY5quk6t)aeeRNtZjjmCfbmJlmcDbsSxm1xy54lyKDY)aeeRNtZjjmCfbmJlGwivGEmRUMH1Pw5HUajgDQulhPa7KN7uihRtTYzrT1rIcegwo3POS0c4oACRLqQnuFJBxU(dqqSEonNKWWveWmUWaQTosVGrcdlpRUMHmtYpapEOlqIrNk1YrkWo55quk6tt3DqTEHSxSS0IeEgFoKcSTCQLJ0IGSbhVGnH(YslG7OXTwcP2q9nUD56pabX650CscdxraZ4cZL3sbcJxaMp2dqqSEonNKWWveWmUWiEXMZb6r4lM6lyo4au)aeeRNtZjjmCfbmJlmeqySJpabX650CscdxraZ4I7NoLEbZnssX5ZQRzcI1UIu8qPg1Bz(YsMfYJW2qomkApfIPj8C8c2e6FacI1ZP5KegUIaMXfg1gIVGbm02dqqSEonNKWWveWmUWqazr)laZhllImKesTaUJMoZYS6AMc04srFCwNALxH4jVmC)a8KBvsEa3rnTcdI1ZfPfwYD3YswNALZIARJefimSCUtXkLLKzs(b4XdDbsm6uPwosb2jphIsrF6TfOXLI(4So1kVcXtEz4Ehyy9CR9oXlxipcBd5fWwks0(0wFetZXlytOVSKKhWDutRWGy9CrAHLCMVS0c4oACRLqQnuFJBDVhGGy9CAojHHRiGzCPoehn6PH8iSnKYIH0dqqSEonNKWWveWmUu4a7Qm9TtztH2EacI1ZP5KegUIaMXfYCe8myyONwtHe(aeeRNtZjjmCfbmJlSPz80PsTCKIhkjZdqqSEonNKWWveWmUy5i15yhNZtRdKGz11mSo1khIKnsOwtRdKGCNIYswNALdrYgjuRP1bsqkzCodHCTfKn2UCXhGGy9CAojHHRiGzCrYjzToFSS6AMqEe2gYHrr7PqmnHNJxWMqVCbXAxrkEOuJ6fY(biiwpNMtsy4kcygxyUHfgVamFSS6AgYmj)a84B0PeLmssX55quk6tVqDioAU1si1gQuSj5wniw7ksXdLAuV1TLLmlKhHTHCyu0Ekett454fSj0VIcuxGeftzVUBvMYuka]] )
    end


end
