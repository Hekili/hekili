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
            cooldown = function () return level > 55 and 25 or 30 end,
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
                if level > 53 then gain( 10, "focus" ) end
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
        spec:RegisterPack( "Beast Mastery", 20201013.9, [[dKKfNaqibIEebI2KGYNuj1OieDkcHvjOQ8kbzweQULGQQDr0VuIgMsfhtalJq5zkvAAkHY1ujzBei9nbcgNaPCocuwNGQmpvI7PsTpcWbjGkluPQhsGWhjGQgjbQ0jjqvRKszMkHQBsaL2Pi5NcKQwkbu8ujMQi1xjqfJvGqNvGK9k1FfAWI6WuTyO8yitwsxg1MvXNvkJweNwXQfivETsWSP42q1Ub(TQgUs64eqwoONJy6KUoLSDcPVtqJxjKZlqTEbvMpLQ9J0DGoDxQUYDkX2rSDcStGDL7iyb2zXc0fn4vUlRoAbFJ7cWX5USNDIsZcSorzyWDz1d28ETt3fYBbrCxsuDLeElxUnAIfMe94ljdULX15biOF0LKbhTSlywJrf8GgRlvx5oLy7i2ob2jWUYDeSa7SBqRlULM8WUugCbrxsMALbnwxQmb1fbjnVNDIsZcSorzyW0SGRfqzi1MGKMd6r6JXqAoWUItZITJy7qTrTjiP5fNfLn0SaO5R2r2fZqusNUlv(4wgTt3Pc0P7IJ05bDb9waLHrsYRDHboMHR9(w7uI1P7IJ05bDrHoqGSgZeUbSfjjV2fg4ygU27BTtTBNUlmWXmCT33feCugoExwHSOXnuvgq6KvgPX)e1eokCmvA2UDA(mBjAeY4(ai08fAwSD6IJ05bDXIWXrzCsRDQfRt3fg4ygU277IJ05bDb5gt0r68GOziAxmdrJahN7cQsATtDvNUlmWXmCT33feCugoExCKoIYrgW4dtO5l0SyDXr68GUGCJj6iDEq0meTlMHOrGJZDHOT2Pe0oDxyGJz4AVVli4OmC8U4iDeLJmGXhMqZcGMd0fhPZd6cYnMOJ05brZq0UygIgboo3fKHDr5wBTlRqg94yU2P7ub60DXr68GUqSWXFqCL1UWahZW1EFRDkX60DHboMHR9(UGGJYWX7c0cWNhUXsYBzopCJJmogdjswGSM1vU2fhPZd6I6WOc91w7u72P7cdCmdx79DzfYiNOrDW5UeqUBxCKopOlozLrA8prnHJchtT1o1I1P7cdCmdx79DzfYiNOrDW5UeqEvxCKopOlymrh3efcDnPli4OmC8UeK0S6ggOscIbA8prmZ)vjdCmdxP5WO5GKMHwa(8WnwsElZ5HBCKXXyirYcK1SUY1wBTlOkPt3Pc0P7cdCmdx79DbbhLHJ3f0)M6leiXyIoUjke6AIeY4(ai0SaO5D3PlosNh0fhGyIcDte5gtRDkX60DHboMHR9(UGGJYWX7c6Ft9fcKymrh3efcDnrczCFaeAwa08U70fhPZd6YzGmM5)ARDQD70DHboMHR9(UGGJYWX7cM15iDYkJ04FIAchfoMQ0ALMdJMfjnFMTenczCFaeAwa0m6Ft9fcKymKWWfgWMSAbDDEanhIMRwqxNhqZ2TtZIKMvhUXQmHDJMixrknFHM39kA2UDAoiPz1nmqLlmgddJdGOdaPsg4ygUsZIGMfbnB3onFMTenczCFaeA(cnhy3U4iDEqxWyiHHlmGTw7ulwNUlmWXmCT33feCugoExWSohPtwzKg)tut4OWXuLwR0Cy0SiP5ZSLOriJ7dGqZcGMr)BQVqGeZ8FnESGblRwqxNhqZHO5Qf015b0SD70SiPz1HBSkty3OjYvKsZxO5DVIMTBNMdsAwDddu5cJXWW4ai6aqQKboMHR0SiOzrqZ2TtZNzlrJqg3haHMVqZbe0U4iDEqxWm)xJhlyWT2PUQt3fg4ygU277ccokdhVlywNJ8azq4cwATsZHrZywNJ8azq4cwczCFaeAwa08gQkX9frZ2TtZbjnJzDoYdKbHlyP1AxCKopOlMzlrjXGoR6god0w7ucANUlmWXmCT33feCugoExWSohjgt0XnrHqxtKwR0Cy0mM15iDYkJ04FIAchfoMQ0ALMdJMvhUXQmHDJMixrknFHM39kA2UDAwK0SiPz0diw4oMHLRVopi(NOfadovdxJhlyW0SD70m6belChZWslagCQgUgpwWGPzrqZHrZNzlrJqg3haHMVqZcAaA2UDA(mBjAeY4(ai08fAwmbLMfrxCKopOlRVopO1w7cr70DQaD6UWahZW1EFxqWrz44DbZ6CKhidcxWsRvAomAgZ6CKhidcxWsiJ7dGqZxUP5nuLMTBNMpwgteYOehUXrDWzA(cnVHQ0Cy0m6Ft9fcKymrh3efcDnrczCFaeA2UDAg9VP(cbsmMOJBIcHUMiHmUpacnFHMdignhIM3qvAomAwDddujbXan(NiM5)QKboMHRDXr68GUG5qmUgjjV2ANsSoDxyGJz4AVVli4OmC8UaTa85HBSK8wMZd34iJJXqIKfiRzDLR0Cy0S6WOc9vjKX9bqO5l08gQsZHrZO)n1xiqEmoKLqg3haHMVqZBOAxCKopOlQdJk0xBTtTBNUlmWXmCT33feCugoExuhgvOVkTw7IJ05bD5yCi3ANAX60DXr68GUiCm1izDGJs6cdCmdx79T2PUQt3fhPZd6YcJXejjV2fg4ygU27BTtjOD6U4iDEqxogpyUgjjV2fg4ygU27BTtfe60DHboMHR9(UGGJYWX7Y5rweAoenJCIgH8gdO5l085rwejUVOU4iDEqxQSRjruIVa0XBTtf060DXr68GUGz(Vss4AxyGJz4AVV1oLG1P7IJ05bDXjRmsJ)jQjCu4yQDHboMHR9(w7ub2Pt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQab60DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkGyD6U4iDEqxWyIoUjke6AsxyGJz4AVV1ovGD70DXr68GUazYdCDaBrhcFHDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOllmgte944oO2fg4ygU27BTtfqq70DHboMHR9(UGGJYWX7cM15iXyIoUjke6AIS(cb0SD708z2s0iKX9bqO5l08vDXr68GUG5BX)ev4GwG0ANkqqOt3fhPZd6sDGCeJDI2fg4ygU27BTtfiO1P7cdCmdx79DbbhLHJ3LZSLOriJ7dGqZxOzbRlosNh0fmhIX1ij51w7ubeSoDxCKopOlyoe6BCxyGJz4AVV1oLy70P7cdCmdx79DbbhLHJ3frsZNhzrO5WpnJEIsZHO5ZJSisiVXaAo8rZIKMr)BQVqGCHXyIOhh3bvjKX9bqO5WpnhGMfbnlaA2r68a5cJXerpoUdQs0tuA2UDAg9VP(cbYfgJjIECChuLqg3haHMfanhGMdrZBOknhgnJ(3uFHajgt0XnrHqxtKqg3hajUzXecnlaA(8ilIuhCoQFe3xenlcAomAg9VP(cbYfgJjIECChuLqg3haHMfanhGMTBNMpZwIgHmUpacnFHM3TlosNh0f0Jb9ij51wBTlid7IYD6ovGoDxyGJz4AVVlosNh0fmhIX1ij51UGGJYWX7cM15ipqgeUGLwR0Cy0mM15ipqgeUGLqg3haHMVCtZBOAxqbJmCuD4gRKovGw7uI1P7cdCmdx79DbbhLHJ3fmRZrIXorJid7IYsiJ7dGqZxO5DKIDfnhIM3q1U4iDEqxWTm6qsET1o1UD6UWahZW1EFxqWrz44DbAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP5WOz1Hrf6RsiJ7dGqZxO5nuLMdJMr)BQVqG8yCilHmUpacnFHM3q1U4iDEqxuhgvOV2ANAX60DHboMHR9(UGGJYWX7I6WOc9vP1AxCKopOlhJd5w7ux1P7cdCmdx79DbbhLHJ3LZJSi0CiAg5enc5ngqZxO5ZJSisCFrDXr68GUuzxtIOeFbOJ3ANsq70DXr68GUiCm1izDGJs6cdCmdx79T2PccD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LJLXeHmkXHBCuhCMMVqZBOknhgnJ(3uFHajgt0XnrHqxtKqg3haHMTBNMr)BQVqGeJj64MOqORjsiJ7dGqZxO5aIrZHO5nuLMdJMv3WavsqmqJ)jIz(VkzGJz4AxqbJmCuD4gRKovGw7ubToDxCKopOlozLrA8prnHJchtTlmWXmCT33ANsW60DXr68GUGXeDCtui01KUWahZW1EFRDQa70P7IJ05bDbYKh46a2Ioe(c7cdCmdx79T2PceOt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQaI1P7IJ05bD5y8G5AKK8AxyGJz4AVV1ovGD70DXr68GUSWymrsYRDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOlyM)RKeU2fg4ygU27BTtfqq70DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkqqOt3fg4ygU277ccokdhVlywNJ8azq4cwczCFaeAwa0mVigzPCuhCUlosNh0fmhc9nU1ovGGwNUlmWXmCT33feCugoExopYIqZcGMrprP5q0SJ05bsClJoKKxLONODXr68GUSWymr0JJ7GARDQacwNUlmWXmCT33feCugoExWSohjgt0XnrHqxtK1xiGMTBNMpZwIgHmUpacnFHMVQlosNh0fmFl(NOch0cKw7uITtNUlosNh0L6a5ig7eTlmWXmCT33ANsSaD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LZSLOriJ7dGqZxOzbRlOGrgoQoCJvsNkqRDkXeRt3fg4ygU277ccokdhVlNhzrK6GZr9J4(IO5l08gQsZHpAwSU4iDEqxCiYbCKK8ART2AxeLHK5bDkX2rSDcStaXKcwxe6qWa2iDrWrGtGjLGpLaF4rZ0C6eMMh81hQ085H081Ok5AAgYcK1a5kntECMMDl9XDLR0mkXbBmrsTT4dGP5RcpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYDxKiKuBuBcocCcmPe8Pe4dpAMMtNW08GV(qLMppKMVMOxtZqwGSgixPzYJZ0SBPpURCLMrjoyJjsQTfFamnhi8OzbXdeLHkxP5RxzvgeLbLukVMM1NMVoOKs510SifBrIqsTrTj4iWjWKsWNsGp8OzAoDctZd(6dvA(8qA(AKHDr5RPzilqwdKR0m5XzA2T0h3vUsZOehSXej12IpaMMdeE0SG4bIYqLR081RSkdIYGskLxtZ6tZxhusP8AAwKITiriP2w8bW0SyHhnliEGOmu5knF9kRYGOmOKs510S(081bLukVMMfzGfjcj12IpaMMdeecpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYalsesQnQnbp(6dvUsZxrZosNhqZMHOej1wxwH)zmCxeK08E2jknlW6eLHbtZcUwaLHuBcsAoOhPpgdP5a7konl2oITd1g1MGKMxCwu2qZcGMVAhj1g1MJ05be5kKrpoMRHUxsSWXFqCLvQnhPZdiYviJECmxdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2CKopGixHm6XXCn09sNSYin(NOMWrHJPk(kKrorJ6GZ3bK7sT5iDEarUcz0JJ5AO7Lymrh3efcDnr8viJCIg1bNVdiVs85ChKQByGkjigOX)eXm)xLmWXmCnSGeAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2O2CKopGe6Ej6TakdJKKxP2CKopGe6EPcDGaznMjCdylssELAZr68asO7LweookJteFo3Rqw04gQkdiDYkJ04FIAchfoMQD7NzlrJqg3ha5Iy7qT5iDEaj09sKBmrhPZdIMHOIdCC(gvjuBosNhqcDVe5gt0r68GOziQ4ahNVjQ4Z52r6ikhzaJpm5IyuBosNhqcDVe5gt0r68GOziQ4ahNVrg2fLfFo3oshr5idy8Hjcia1g1MJ05bejQscDV0biMOq3erUXi(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxEgiJz(Vk(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxIXqcdxyaBIpNBmRZr6KvgPX)e1eokCmvP1AyI8mBjAeY4(aica9VP(cbsmgsy4cdytwTGUopiu1c668a72fP6WnwLjSB0e5ksVS7v2ThKQByGkxymgggharhasLmWXmCveIWU9ZSLOriJ7dGCjWUuBosNhqKOkj09smZ)14XcgS4Z5gZ6CKozLrA8prnHJchtvATgMipZwIgHmUpaIaq)BQVqGeZ8FnESGblRwqxNheQAbDDEGD7IuD4gRYe2nAICfPx29k72ds1nmqLlmgddJdGOdaPsg4ygUkcry3(z2s0iKX9bqUeqqP2CKopGirvsO7LMzlrjXGoR6goduXNZ9kRsCFasmRZrEGmiCblTwdBLvjUpajM15ipqgeUGLqg3haraBOQe3xKD7b5kRsCFasmRZrEGmiCblTwP2CKopGirvsO7LRVopq85CJzDosmMOJBIcHUMiTwddZ6CKozLrA8prnHJchtvATgM6WnwLjSB0e5ksVS7v2TlsrIEaXc3XmSC915bX)eTayWPA4A8ybd2UD0diw4oMHLwam4unCnESGblIWoZwIgHmUpaYfbnGD7NzlrJqg3ha5IycQiO2O2CKopGirg2fLdDVeZHyCnssEvCuWidhvhUXk5oG4Z5ELvjUpajM15ipqgeUGLwRHTYQe3hGeZ6CKhidcxWsiJ7dGC5EdvP2CKopGirg2fLdDVe3YOdj5vXNZ9kRsCFasmRZrIXorJid7IYsiJ7dGCzhPyxfAdvP2CKopGirg2fLdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxdtDyuH(QeY4(aix2q1Wq)BQVqG8yCilHmUpaYLnuLAZr68aIezyxuo09YJXHS4Z5wDyuH(Q0ALAZr68aIezyxuo09Yk7AseL4laDCXNZ95rwKqiNOriVXGlNhzrK4(IO2CKopGirg2fLdDVu4yQrY6ahLqT5iDEarImSlkh6EjMdX4AKK8Q4OGrgoQoCJvYDaXNZ9XYyIqgL4WnoQdoFzdvdd9VP(cbsmMOJBIcHUMiHmUpaID7O)n1xiqIXeDCtui01ejKX9bqUeqSqBOAyQByGkjigOX)eXm)xLmWXmCLAZr68aIezyxuo09sNSYin(NOMWrHJPsT5iDEarImSlkh6Ejgt0XnrHqxtO2CKopGirg2fLdDVeYKh46a2Ioe(cP2CKopGirg2fLdDVKOo(kxzXNZnM15iDYkJ04FIAchfoMQ0A1U9ZSLOriJ7dGCjWvuBosNhqKid7IYHUxEmEWCnssELAZr68aIezyxuo09YfgJjssELAZr68aIezyxuo09suYG7m0JKKxP2CKopGirg2fLdDVeZ8FLKWvQnhPZdisKHDr5q3l9iUfSYW4FIi4lKqT5iDEarImSlkh6EjMdH(gl(CUxzvI7dqIzDoYdKbHlyjKX9bqeaVigzPCuhCMAZr68aIezyxuo09YfgJjIECChufFo3Nhzrea6jAihPZdK4wgDijVkrprP2CKopGirg2fLdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKid7IYHUxwhihXyNOuBosNhqKid7IYHUxI5qmUgjjVkokyKHJQd3yLChq85CFMTenczCFaKlcg1MJ05bejYWUOCO7Loe5aossEv85CFEKfrQdoh1pI7l6YgQg(eJAJAZr68aIKOHUxI5qmUgjjVk(CUxzvI7dqIzDoYdKbHlyP1AyRSkX9biXSoh5bYGWfSeY4(aixU3qv72pwgteYOehUXrDW5lBOAyO)n1xiqIXeDCtui01ejKX9bqSBh9VP(cbsmMOJBIcHUMiHmUpaYLaIfAdvdtDddujbXan(NiM5)QKboMHRuBosNhqKen09s1Hrf6RIpNBOfGppCJLK3YCE4ghzCmgsKSaznRRCnm1Hrf6RsiJ7dGCzdvdd9VP(cbYJXHSeY4(aix2qvQnhPZdisIg6E5X4qw85CRomQqFvATsT5iDEars0q3lfoMAKSoWrjuBosNhqKen09YfgJjssELAZr68aIKOHUxEmEWCnssELAZr68aIKOHUxwzxtIOeFbOJl(CUppYIec5enc5ngC58ilIe3xe1MJ05bejrdDVeZ8FLKWvQnhPZdisIg6EPtwzKg)tut4OWXuP2CKopGijAO7Le1Xx5kl(CUXSohPtwzKg)tut4OWXuLwR2TFMTenczCFaKlbUIAZr68aIKOHUx6rClyLHX)erWxiHAZr68aIKOHUxIXeDCtui01eQnhPZdisIg6EjKjpW1bSfDi8fsT5iDEars0q3lrjdUZqpssELAZr68aIKOHUxUWymr0JJ7Gk1MJ05bejrdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKen09Y6a5ig7eLAZr68aIKOHUxI5qmUgjjVk(CUpZwIgHmUpaYfbJAZr68aIKOHUxI5qOVXuBosNhqKen09s0Jb9ij5vXNZTippYIe(rprdDEKfrc5nge(ej6Ft9fcKlmgte944oOkHmUpas4pGieGJ05bYfgJjIECChuLONO2TJ(3uFHa5cJXerpoUdQsiJ7dGiGaH2q1Wq)BQVqGeJj64MOqORjsiJ7dGe3SycraNhzrK6GZr9J4(IeryO)n1xiqUWymr0JJ7GQeY4(aiciGD7NzlrJqg3ha5YUDHSYOoLyxTBRT2na]] )
    else
        spec:RegisterPack( "Beast Mastery", 20201013.1, [[dSuTebqisqpsuOSjsKprcmkLOoLsIvbsQ8kqQzjk6wGK0Uq5xujnmLihtuAzkP8mssMMOGUgiX2efY3ucHXjkW5usfRtjvAEkf3Jk1(ucoOOq1cPs8qqszIGKiFujKAKGKqNujeTsLsZKKuCtqsu7Ke6NGKadfKe0sbjv9uuzQKO(QsizSKKsNvju2lH)cmyIoSWIb1JrAYu1LH2SK(Ss1OfvNwQvReQETssZwKBJQ2Tk)wXWLOJtsQwoINtQPt56uX2jP67Gy8kPQZtsSEskZxc7xvlYkuwW5ddfkU2sRTu2LYQk2sRt2SzZqbNPsjk4kd6QXok4UGhfCUGH2Eju5qBirfbxzOsAcVqzbNECiuuWLBwPEDD1192YDGz0H3vDZ7KcRNJsIQ5QU5PUk4GD6KTipbSGZhgkuCTLwBPSlLvvSLwNSzZMvWfow(qeCCnputWL3EpEcybNh1ubxg7LUGH2Eju5qBirLxcv05mK8BZyVeQaQnWi5LzvvMVCTLwBPF7VnJ9svdQoME5g3VeklXeCPwBAHYcopwdNKjuwOywHYcUGA9Cco64Cgsa68XeC4fWj0lCrycfxtOSGdVaoHEHlcokPnK0HGRKGQd2PEwwwOlrQbMkWYraKo5FzrXlTGSJgZAEeydW34l38Y1wsWfuRNtW5OrqBiVwycfvLqzbhEbCc9cxeCb165eCHA68GeAqDodmvq5abjcokPnK0HGJotYpqowOlrQbMkWYraKo5zeKp6td2DqT(LBEzwO8sLEPfKD0ywZJaBa(gF5cVm7scUl4rbxOMopiHguNZatfuoqqIWekMHcLfC4fWj0lCrWfuRNtWf6C1Jd1asO2qa0HejbhL0gs6qW5ryNALrc1gcGoKib8iStTYCkFPsVC5xQWxIQUtxwIEwOMopiHguNZatfuoqqYllkEjDMKFGCSqnDEqcnOoNbMkOCGGegb5J(0VCHxMbz0llkEjQ14rrgCAgpyQalhb4H8QW4JfFiVCLxQ0lx(LLeuDWo1ZYYcDjsnWubwocG0j)llkEPcFjQ6oDzj6zuvOPXiZ1uaCk02lv6LWo1kl0Li1atfy5iasN8mcYh9PF5cVCDE5kVuPxU8lv4lrTgpkYOZ5XtJEqQRyDiuKXhl(qEzrXlHDQv2Utq8DCGPcc1qYy5mNYxUYlv6Ll)sli7OXYXiz5SsQ9YnVuvq5LffVuHVe1A8OiJoNhpn6bPUI1HqrgFS4d5LffVuHV0IeEgB1oLqcOpT1h1y4fWj0)YvEzrXlx(LEe2PwzKqTHaOdjsapc7uRm)a5EzrXlTGSJgZAEeydW34l38Y1YOxUYlv6Lwq2rJznpcSb4B8Ll8YLF5Az4lH6E5YVKotYpqogvfAAmYCnfaNcTXiiF0N(Lq)Ym8LBEPfKD0ywZJaBa(gF5kVCfb3f8OGl05QhhQbKqTHaOdjsctOiuekl4WlGtOx4IGlOwpNGJQcnngzUMcGtH2eCusBiPdbhStTYGrT1rcaHewoZpqUxwu8sli7OXSMhb2a8n(YnVekcoSwrQbUGhfCuvOPXiZ1uaCk0MWekMrcLfC4fWj0lCrWfuRNtWrJuceuRNdKATj4sT2axWJcoQxlmHIlcHYco8c4e6fUi4OK2qshcUGAT6iapKVr9l38Y1eCb165eC0iLab165aPwBcUuRnWf8OGtBctOygiuwWHxaNqVWfbhL0gs6qWfuRvhb4H8nQF5cVmRGlOwpNGJgPeiOwphi1AtWLATbUGhfC0egQJctycUscshE4WeklumRqzbhEbCc9cxeCxWJcUqnDEqcnOoNbMkOCGGebxqTEobxOMopiHguNZatfuoqqIWekUMqzbxqTEobhKHK8QJ9biOEU4OOGdVaoHEHlctOOQekl4cQ1Zj42DcIVJdmvqOgsglxWHxaNqVWfHjumdfkl4cQ1Zj44r(HOcyQGKdT9apbdETGdVaoHEHlctOiuekl4WlGtOx4IGlOwpNGJQcnngzUMcGtH2eCusBiPdbNcFjjApavhpJ1N6oPdjbCcz46BTPFPsVC5xAK(wfnwwwEOb0zs(bY9sOFPr6Bv0yRXYdnGotYpqUxU5LR9YIIxIQUtxwIEM6bPd4ec6ZWt3MkG9EpuFsgy00oLcRVDabdQnKxUIGdRvKAGl4rbhvfAAmYCnfaNcTjmHIzKqzbhEbCc9cxeCusBiPdbNcFjjApavhpJ1N6oPdjbCcz46BTPfCb165eC1H6OrpiudjTHaym4fMqXfHqzbhEbCc9cxeCLeKgAdynpk4YYuLGlOwpNGl0Li1atfy5iasN8cokPnK0HGtHVmudjTHSssZhjqFARpQPz4fWj0)sLEPcFjQ14rrgQ14rrWubwocQd1r33oOjTMXhl(qEPsVC5xIQUtxwIEwOMopiHguNZatfuoqqYllkEPcFjQ6oDzj6zuvOPXiZ1uaCk02lxrycfZaHYco8c4e6fUi4kjin0gWAEuWLLbfbxqTEobhmQTosaiKWYfCusBiPdbxOgsAdzLKMpsG(0wFutZWlGtO)Lk9sf(suRXJImuRXJIGPcSCeuhQJUVDqtAnJpw8H8sLE5YVevDNUSe9SqnDEqcnOoNbMkOCGGKxwu8sf(su1D6Ys0ZOQqtJrMRPa4uOTxUIWeMGJ61cLfkMvOSGdVaoHEHlcokPnK0HGJotYpqogmQTosaiKWYzeKp6t)YfEPQwsWfuRNtWfhf1gjsaAKsctO4AcLfC4fWj0lCrWrjTHKoeC0zs(bYXGrT1rcaHewoJG8rF6xUWlv1scUGA9CcUAtq40mEHjuuvcLfC4fWj0lCrWrjTHKoeCWo1kl0Li1atfy5iasN8mNYxQ0lx(Lwq2rJznpcSb4B8Ll8s6mj)a5yWirJKv7BN5DiH1Z9sOFP3Hewp3llkE5YV0cYoASCmswoRKAVCZlvfuEzrXlv4lTiHNXwTtjKa6tB9rngEbCc9VCLxUYllkEPfKD0ywZJaBa(gF5MxMvvcUGA9CcoyKOrYQ9TlmHIzOqzbhEbCc9cxeCusBiPdbhStTYcDjsnWubwocG0jpZP8Lk9YLFPfKD0ywZJaBa(gF5cVKotYpqogCAgpO6quH5DiH1Z9sOFP3Hewp3llkE5YV0cYoASCmswoRKAVCZlvfuEzrXlv4lTiHNXwTtjKa6tB9rngEbCc9VCLxUYllkEPfKD0ywZJaBa(gF5MxMnJeCb165eCWPz8GQdrfHjuekcLfC4fWj0lCrWrjTHKoeCWo1kRsWtnvyoLVuPxc7uRSkbp1uHrq(Op9lx4L7upJpw)llkEPcFjStTYQe8utfMtPGlOwpNGl175MgS4o(DE8mHjumJekl4WlGtOx4IGJsAdjDi4GDQvgmQTosaiKWYzoLVuPxc7uRSqxIudmvGLJaiDYZCkFPsV0cYoASCmswoRKAVCZlvfuEzrXlx(Ll)s6CAh(aoHSYX65atf4CWK2NqpO6qu5LffVKoN2HpGtiZ5GjTpHEq1HOYlx5Lk9sli7OXSMhb2a8n(YnVmJY(YIIxAbzhnM18iWgGVXxU5LRLrVCfbxqTEobx5y9CctO4IqOSGdVaoHEHlcokPnK0HGB5xwsq1b7uplll0Li1atfy5iasN8VSO4L0zs(bYXcDjsnWubwocG0jpJG8rF6xU5L7u)llkEPfKD0ywZJaBa(gF5MxU2sVCLxwu8sf(suRXJIm1BDphyQGsKurQ1ZX47BicUGA9Ccoidj5vh7dqq9CXrrHjumdekl4WlGtOx4IGJsAdjDi4OZK8dKJf6sKAGPcSCeaPtEgb5J(0VCZlZU0llkEPfKD0ywZJaBa(gF5cVmOwphGotYpqUxc9l9oKW65EzrXlTGSJgZAEeydW34l38svTKGlOwpNGB3ji(ooWubHAizSCHjuCDekl4cQ1Zj4iDzzcb9b0LbffC4fWj0lCrycfZUKqzbxqTEobhpYpevatfKCOTh4jyWRfC4fWj0lCrycfZMvOSGdVaoHEHlcokPnK0HGZcYoASCmswoRKAVCHxMbl9YIIxAbzhnwogjlNvsTxUX9lxBPxwu8sli7OXSMhb2akPgyTLE5cVuvlj4cQ1Zj4iyu23oOMcEulmHj40MqzHIzfkl4cQ1Zj4wTtjGoFmbhEbCc9cxeMqX1ekl4cQ1Zj4GtZ415OxWHxaNqVWfHjuuvcLfC4fWj0lCrWrjTHKoeCWo1kRsWtnvyoLVuPxc7uRSkbp1uHrq(Op9l38YDQ)LffVKotYpqogmQTosaiKWYzeKp6t)sLE5YVS6KsacsZdYocSMhF5MxUt9VSO4LHAiPnKvsA(ib6tB9rnndVaoH(xQ0lPZK8dKJf6sKAGPcSCeaPtEgb5J(0VCZl3P(xUIGlOwpNGdoiWOhOZhtycfZqHYco8c4e6fUi4OK2qshcU6qD0Ve6xwhQJMrWD8Eju3l3P(xU5L1H6Oz8X6FPsVe2PwzWO26ibGqclN5hi3lv6Ll)sf(s)ym6Cu8msyOhutbpcGDihJG8rF6xQ0lv4ldQ1ZXOZrXZiHHEqnf8iRpqn1752lx5LffVS6KsacsZdYocSMhF5MxUt9VSO4Lwq2rJznpcSb4B8LBEjueCb165eC05O4zKWqpOMcEuycfHIqzbhEbCc9cxeCusBiPdbhStTYcDjsnWubwocG0jpZpqUxQ0lx(L0zs(bYXGdcm6b68Xy08GSJ6xU5LzFzrXlv4ld1qsBiRK08rc0N26JAAgEbCc9VCfbxqTEobxOlrQbMkWYraKo5fMqXmsOSGdVaoHEHlcokPnK0HGd2PwzHUePgyQalhbq6KN5u(sLEjStTYGrT1rcaHewoZP8LffV0cYoAmR5rGnaFJVCZlZcfbxqTEobN2c(s0JctO4IqOSGlOwpNGla8oepsatfqjdeTGdVaoHEHlctOygiuwWHxaNqVWfbhL0gs6qWb7uRmyuBDKaqiHLZ8dK7LffV0cYoAmR5rGnaFJVCZlHIGlOwpNGRouhn6bHAiPneaJbVWekUocLfC4fWj0lCrWrjTHKoeCWo1kJG0vtOwdQdHImNYxwu8syNALrq6QjuRb1HqraDCodjmTf0vF5MxMDPxwu8sli7OXSMhb2a8n(YnVekcUGA9Ccolhboh84CEqDiuuycfZUKqzbhEbCc9cxeCusBiPdbNfj8m2CiasB5alhbLbDvgEbCc9VuPxc7uRmyuBDKaqiHLZiiF0N(LBE5o1)YIIxc7uRmyuBDKaqiHLZ8dK7Lk9s6mj)a5yHUePgyQalhbq6KNrq(Op9lx4LzHYllkEPfKD0ywZJaBa(gF5MxMfkVe6xUt9cUGA9CcoyuBDKaqiHLlmHIzZkuwWHxaNqVWfbhL0gs6qWfQHK2qMpokcMkWJHLZiXT6lx4LzFPsVe2Pwz(4OiyQapgwoJG8rF6xU5L7uVGlOwpNGdoiWOhOZhtycfZUMqzbhEbCc9cxeCusBiPdbhStTYcDjsnWubwocG0jpJG8rF6xUWlZU0lH(L7u)llkEPfKD0ywZJaBa(gF5MxMDPxc9l3PEbxqTEobhCAgpyQalhb4H8QimHIzvLqzbxqTEob3QDkbOdpFCEbhEbCc9cxeMqXSzOqzbhEbCc9cxeCusBiPdbhStTYGrT1rcaHewoZpqUxwu8sli7OXSMhb2a8n(YnVekcUGA9Cco4yhmvGrA6QAHjumluekl4cQ1Zj4O5nFGKaOZhtWHxaNqVWfHjumBgjuwWfuRNtW5BccGXqBco8c4e6fUimHIzxecLfC4fWj0lCrWrjTHKoeCwKWZyZHaiTLdSCeug0vz4fWj0)sLEjnpi7Ogujb165I0lx4Lzzq5LffVKMhKDudQKGA9Cr6Ll8YSSm4LffVKotYpqowOlrQbMkWYraKo5zeKp6t)YnVe2PwzvcEQPcZ7qcRN7Lq1xUt9VuPxgQHK2qwjP5JeOpT1h10m8c4e6FzrXlTGSJgZAEeydW34l38Y1rWfuRNtWbhey0d05JjmHIzZaHYco8c4e6fUi4OK2qshcoyNALbJARJeacjSCMFGCVSO4Lwq2rJznpcSb4B8LBEzgi4cQ1Zj4kDiDvL(2bWPqBctOy21rOSGlOwpNGdoiKyhfC4fWj0lCrycfxBjHYco8c4e6fUi4OK2qshcULFzDOo6xcvFjD02lH(L1H6OzeChVxc19YLFjDMKFGCSv7ucqhE(48mcYh9PFju9LzF5kVCHxguRNJTANsa6WZhNNrhT9YIIxsNj5hihB1oLa0HNpopJG8rF6xUWlZ(sOF5o1)sLEjDMKFGCmyuBDKaqiHLZiiF0NgS7GA9lx4L1H6OzwZJaBa8X6FzrXlHDQvgpYpevatfKCOTh4jyWRzoLVCLxQ0lPZK8dKJTANsa6WZhNNrq(Op9lx4LzFzrXlTGSJgZAEeydW34l38svj4cQ1Zj4Odmja68XeMqX1YkuwWHxaNqVWfbhL0gs6qWb7uRSkbp1uH5DiH1Z9sO6l3P(xUWlRoPeGG08GSJaR5rbxqTEobhCqGrpqNpMWeMGJMWqDuOSqXScLfC4fWj0lCrWfuRNtWbhey0d05Jj4OK2qshcoyNALvj4PMkmNYxQ0lHDQvwLGNAQWiiF0N(LBC)YDQNXhRxWrvHMqGfKD00cfZkmHIRjuwWHxaNqVWfbhL0gs6qWTt9m(y9VeQ(syNALbJH2a0egQJmcYh9PF5cVCj2AqrWfuRNtWX7KSwNpMWekQkHYco8c4e6fUi4cQ1Zj4Gdcm6b68XeCusBiPdbx1jLaeKMhKDeynp(YnVCN6z8X6FPsVKotYpqogmQTosaiKWYzeKp6tl4OQqtiWcYoAAHIzfMqXmuOSGlOwpNGl0Li1atfy5iasN8co8c4e6fUimHIqrOSGdVaoHEHlcokPnK0HGd2PwzHUePgyQalhbq6KN5u(sLEjStTYGrT1rcaHewoZP8LffV0cYoAmR5rGnaFJVCZlZcfbxqTEobN2c(s0JctOygjuwWHxaNqVWfbhL0gs6qWrNj5hihl0Li1atfy5iasN8mcYh9Pb7oOw)YfE5Al9YIIxArcpJnhcG0woWYrqzqxLHxaNq)llkEPfKD0ywZJaBa(gF5MxMfkcUGA9CcoyuBDKaqiHLlmHIlcHYcUGA9CcoAEZhija68XeC4fWj0lCrycfZaHYcUGA9CcUaW7q8ibmvaLmq0co8c4e6fUimHIRJqzbxqTEobhCqiXok4WlGtOx4IWekMDjHYco8c4e6fUi4OK2qshcUGAT6iapKVr9l38Ym8LffVuHVmudjTHmsu2Eabtt4z4fWj0l4cQ1Zj4wTtjaD45JZlmHIzZkuwWfuRNtW5BccGXqBco8c4e6fUimHIzxtOSGdVaoHEHlcUGA9Cco4GaJEGoFmbhL0gs6qWb7uRSkbp1uH5hi3lv6Ll)sAEq2rnOscQ1ZfPxUWlZYYGxwu8syNALbJARJeacjSCMt5lx5LffVKotYpqowOlrQbMkWYraKo5zeKp6t)YnVe2PwzvcEQPcZ7qcRN7Lq1xUt9VuPxgQHK2qwjP5JeOpT1h10m8c4e6FzrXlP5bzh1GkjOwpxKE5cVmlldFzrXlTGSJgZAEeydW34l38Y1rWrvHMqGfKD00cfZkmHIzvLqzbxqTEobxDOoA0dc1qsBiagdEbhEbCc9cxeMqXSzOqzbxqTEobxPdPRQ03oaofAtWHxaNqVWfHjumluekl4cQ1Zj4OZrXZiHHEqnf8OGdVaoHEHlctOy2msOSGlOwpNGdonJhmvGLJa8qEveC4fWj0lCrycfZUiekl4WlGtOx4IGJsAdjDi4GDQvgbPRMqTguhcfzoLVSO4LWo1kJG0vtOwdQdHIa64CgsyAlOR(YnVm7scUGA9Ccolhboh84CEqDiuuycfZMbcLfC4fWj0lCrWrjTHKoeCHAiPnKrIY2diyAcpdVaoH(xQ0ldQ1QJa8q(g1VCHxUMGlOwpNGJ3jzToFmHjum76iuwWHxaNqVWfbhL0gs6qWrNj5hihB1oLa0HNpopJG8rF6xUWlRd1rZSMhb2a4J1)sLE5YVmOwRocWd5Bu)YnVuvVSO4Lk8LHAiPnKrIY2diyAcpdVaoH(xUIGlOwpNGJoWKaOZhtyctyco1rIUNtO4AlT2szxk7AS1rWbjixF7Ab3IkJd1R4IuXf96(YxQCo(YMVCi2lRd5LkWJ1Wjzk4Leu1DAc6FPE4Xxgo2Whg6FjnpUDuZ(TQM(WxMHR7lHAZPosm0)sfyK(wfnMQLrNj5hiNcEPnVub0zs(bYXuTk4LlND9RW(T)2fvghQxXfPIl619LVu5C8LnF5qSxwhYlva1RvWljOQ70e0)s9WJVmCSHpm0)sAEC7OM9Bvn9HVekR7lHAZPosm0)sfuIgt1YwmgJPGxAZlvWIXymf8YLv16xH9B)TlQmouVIlsfx0R7lFPY54lB(YHyVSoKxQaTPGxsqv3PjO)L6HhFz4ydFyO)L0842rn73QA6dFPQw3xc1MtDKyO)LkOenMQLTymgtbV0MxQGfJXyk4LlV26xH9Bvn9HVm7IyDFjuBo1rIH(xQGs0yQw2IXymf8sBEPcwmgJPGxUC21Vc73QA6dF5Azx3xc1MtDKyO)LkOenMQLTymgtbV0MxQGfJXyk4LlND9RW(T)2fvghQxXfPIl619LVu5C8LnF5qSxwhYlvanHH6OcEjbvDNMG(xQhE8LHJn8HH(xsZJBh1SFRQPp8Lzx3xc1MtDKyO)LkOenMQLTymgtbV0MxQGfJXyk4LlV26xH9Bvn9HVCT19LqT5uhjg6FPckrJPAzlgJXuWlT5LkyXymMcE5Yzx)kSFRQPp8LzxBDFjuBo1rIH(xQGs0yQw2IXymf8sBEPcwmgJPGxU8ARFf2V93Ui5lhIH(xcLxguRN7LPwBA2VvWvsMANqbxg7LUGH2Eju5qBirLxcv05mK8BZyVeQaQnWi5LzvvMVCTLwBPF7VnJ9svdQoME5g3VeklX(T)2GA9CAwjbPdpCyq72vhncAd5Z8cE0DOMopiHguNZatfuoqqYVnOwpNMvsq6Wdhg0UDfYqsE1X(aeupxCu83guRNtZkjiD4HddA3UU7eeFhhyQGqnKmw(VnOwpNMvsq6Wdhg0UDLh5hIkGPcso02d8em41)2GA9CAwjbPdpCyq72vhncAd5ZeRvKAGl4r3uvOPXiZ1uaCk0wMD1Tcjr7bO64zS(u3jDijGtidxFRnTslBK(wfnwwwEOb0zs(bYbTr6Bv0yRXYdnGotYpqUnRvuGQUtxwIEM6bPd4ec6ZWt3MkG9EpuFsgy00oLcRVDabdQnKv(Tb1650SscshE4WG2TR1H6OrpiudjTHaym4ZSRUvijApavhpJ1N6oPdjbCcz46BTP)TzSxMX9lUJ20V0YXx6DiH1Z9Y48VKotYpqUxo1xMX1Li1E5uFPLJVCr1j)lJZ)sOcjnFKE5I80wFut)syvEPLJV07qcRN7Lt9LX9sNlp0g6F5IgQbv6LqYX7LwoQIci4lD0O)LLeKo8WHXEPlinC04lZ46sKAVCQV0YXxUO6K)Le07qr9lx0qnOsVewLxU2slXRZ8LwERFzRFzwMQEPgPZ51SFBqTEonRKG0HhomOD7AOlrQbMkWYraKo5ZSKG0qBaR5r3zzQkZU6wHHAiPnKvsA(ib6tB9rnndVaoHELuiQ14rrgQ14rrWubwocQd1r33oOjTMXhl(quAzu1D6Ys0Zc105bj0G6CgyQGYbcskkuiQ6oDzj6zuvOPXiZ1uaCk02k)2m2lZ4(f3rB6xA54l9oKW65EzC(xsNj5hi3lN6lDb1whPxUOiHL)Y48VeQyOg(YP(sO(yhFjSkV0YXx6DiH1Z9YP(Y4EPZLhAd9VCrd1Gk9si549slhvrbe8LoA0)YscshE4Wy)2GA9CAwjbPdpCyq72vyuBDKaqiHLNzjbPH2awZJUZYGsMD1DOgsAdzLKMpsG(0wFutZWlGtOxjfIAnEuKHAnEuemvGLJG6qD09TdAsRz8XIpeLwgvDNUSe9SqnDEqcnOoNbMkOCGGKIcfIQUtxwIEgvfAAmYCnfaNcTTYV93guRNtdTBxPJZzibOZh73guRNtdTBxD0iOnKxNzxDxsq1b7uplll0Li1atfy5iasN8ffwq2rJznpcSb4BCZAl9BdQ1ZPH2TRoAe0gYN5f8O7qnDEqcnOoNbMkOCGGKm7QB6mj)a5yHUePgyQalhbq6KNrq(Opny3b16nzHIswq2rJznpcSb4BCHSl9BdQ1ZPH2TRoAe0gYN5f8O7qNRECOgqc1gcGoKiLzxD7ryNALrc1gcGoKib8iStTYCkvAzfIQUtxwIEwOMopiHguNZatfuoqqsrHr6Bv0yHA68GeAqDodmvq5abjm6mj)a5yeKp6tVqgKrffOwJhfzWPz8GPcSCeGhYRcJpw8HSIslxsq1b7uplll0Li1atfy5iasN8ffkevDNUSe9mQk00yK5AkaofAtjyNALf6sKAGPcSCeaPtEgb5J(0lSoRO0Yke1A8OiJoNhpn6bPUI1HqrgFS4dPOa2Pwz7obX3XbMkiudjJLZCkxrPLTGSJglhJKLZkP2gvbLIcfIAnEuKrNZJNg9GuxX6qOiJpw8HuuOqls4zSv7ucjG(0wFuJHxaNq)kffl7ryNALrc1gcGoKib8iStTY8dKROWcYoAmR5rGnaFJBwlJwrjli7OXSMhb2a8nUWYRLHqDltNj5hihJQcnngzUMcGtH2yeKp6tdDgUXcYoAmR5rGnaFJRSYVnOwpNgA3U6OrqBiFMyTIudCbp6MQcnngzUMcGtH2YSRUHDQvgmQTosaiKWYz(bYvuybzhnM18iWgGVXnq53guRNtdTBxPrkbcQ1ZbsT2Y8cE0n1R)Tb1650q72vAKsGGA9CGuRTmVGhDRTm7Q7GAT6iapKVr9M1(Tb1650q72vAKsGGA9CGuRTmVGhDttyOoMzxDhuRvhb4H8nQxi7V93guRNtZOET74OO2ircqJukZU6MotYpqogmQTosaiKWYzeKp6tVGQw63guRNtZOEn0UDT2eeonJpZU6MotYpqogmQTosaiKWYzeKp6tVGQw63guRNtZOEn0UDfgjAKSAF7z2v3Wo1kl0Li1atfy5iasN8mNsLw2cYoAmR5rGnaFJlqNj5hihdgjAKSAF7mVdjSEoO9oKW65kkw2cYoASCmswoRKABufukkuOfj8m2QDkHeqFARpQXWlGtOFLvkkSGSJgZAEeydW34MSQ63guRNtZOEn0UDfonJhuDiQKzxDd7uRSqxIudmvGLJaiDYZCkvAzli7OXSMhb2a8nUaDMKFGCm40mEq1HOcZ7qcRNdAVdjSEUIILTGSJglhJKLZkP2gvbLIcfArcpJTANsib0N26JAm8c4e6xzLIcli7OXSMhb2a8nUjBg9BdQ1ZPzuVgA3UM69CtdwCh)opEwMD1DjAm(OpgStTYQe8utfMtPsLOX4J(yWo1kRsWtnvyeKp6tVWo1Z4J1xuOWs0y8rFmyNALvj4PMkmNYFBqTEonJ61q721YX65YSRUHDQvgmQTosaiKWYzoLkb7uRSqxIudmvGLJaiDYZCkvYcYoASCmswoRKABufukkwEz6CAh(aoHSYX65atf4CWK2NqpO6quPOGoN2HpGtiZ5GjTpHEq1HOYkkzbzhnM18iWgGVXnzu2Icli7OXSMhb2a8nUzTmALFBqTEonJ61q72vidj5vh7dqq9CXrXm7Q7LljO6GDQNLLf6sKAGPcSCeaPt(Ic6mj)a5yHUePgyQalhbq6KNrq(Op9MDQVOWcYoAmR5rGnaFJBwBPvkkuiQ14rrM6TUNdmvqjsQi165y89nKFBqTEonJ61q721DNG474atfeQHKXYZSRUPZK8dKJf6sKAGPcSCeaPtEgb5J(0BYUurHfKD0ywZJaBa(gxGotYpqoO9oKW65kkSGSJgZAEeydW34gvT0VnOwpNMr9AOD7kPlltiOpGUmO4VnOwpNMr9AOD7kpYpevatfKCOTh4jyWR)Tb1650mQxdTBxjyu23oOMcEuNzxDBbzhnwogjlNvsTfYGLkkSGSJglhJKLZkP2g3RTurHfKD0ywZJaBaLudS2slOQL(T)2GA9CAgnHH6i0UDfoiWOhOZhltQk0ecSGSJM2D2m7Q7s0y8rFmyNALvj4PMkmNsLkrJXh9XGDQvwLGNAQWiiF0NEJ7DQNXhR)3guRNtZOjmuhH2TR8ojR15JLzxDVt9m(y9q1s0y8rFmyNALbJH2a0egQJmcYh9Pxyj2Aq53guRNtZOjmuhH2TRWbbg9aD(yzsvHMqGfKD00UZMzxDxDsjabP5bzhbwZJB2PEgFSELOZK8dKJbJARJeacjSCgb5J(0)2GA9CAgnHH6i0UDn0Li1atfy5iasN8)2GA9CAgnHH6i0UDvBbFj6Xm7QByNALf6sKAGPcSCeaPtEMtPsWo1kdg1whjaesy5mNYIcli7OXSMhb2a8nUjlu(Tb1650mAcd1rOD7kmQTosaiKWYZSRUPZK8dKJf6sKAGPcSCeaPtEgb5J(0GDhuRxyTLkkSiHNXMdbqAlhy5iOmORYWlGtOVOWcYoAmR5rGnaFJBYcLFBqTEonJMWqDeA3UsZB(ajbqNp2VnOwpNMrtyOocTBxdaVdXJeWubuYar)BdQ1ZPz0egQJq72v4GqID83guRNtZOjmuhH2TRR2PeGo88X5ZSRUdQ1QJa8q(g1BYWIcfgQHK2qgjkBpGGPj8m8c4e6)Tb1650mAcd1rOD7QVjiagdT9BdQ1ZPz0egQJq72v4GaJEGoFSmPQqtiWcYoAA3zZSRUlrJXh9XGDQvwLGNAQW8dKtPLP5bzh1GkjOwpxKwilldkkGDQvgmQTosaiKWYzoLRuuqNj5hihl0Li1atfy5iasN8mcYh9P3uIgJp6Jb7uRSkbp1uH5DiH1Zbv3PELc1qsBiRK08rc0N26JAAgEbCc9ff08GSJAqLeuRNlslKLLHffwq2rJznpcSb4BCZ68BdQ1ZPz0egQJq7216qD0OheQHK2qamg8)2GA9CAgnHH6i0UDT0H0vv6BhaNcT9BdQ1ZPz0egQJq72v6Cu8msyOhutbp(BdQ1ZPz0egQJq72v40mEWubwocWd5v53guRNtZOjmuhH2TRwocCo4X58G6qOyMD1nStTYiiD1eQ1G6qOiZPSOa2PwzeKUAc1AqDiueqhNZqctBbD1nzx63guRNtZOjmuhH2TR8ojR15JLzxDhQHK2qgjkBpGGPj8m8c4e6vkOwRocWd5BuVWA)2GA9CAgnHH6i0UDLoWKaOZhlZU6MotYpqo2QDkbOdpFCEgb5J(0luhQJMznpcSbWhRxPLdQ1QJa8q(g1BuvrHcd1qsBiJeLThqW0eEgEbCc9R8B)Tb1650mT5E1oLa68X(Tb1650mTbTBxHtZ415O)3guRNtZ0g0UDfoiWOhOZhlZU6UengF0hd2PwzvcEQPcZPuPs0y8rFmyNALvj4PMkmcYh9P3St9ff0zs(bYXGrT1rcaHewoJG8rFALwU6KsacsZdYocSMh3St9ffHAiPnKvsA(ib6tB9rnndVaoHELOZK8dKJf6sKAGPcSCeaPtEgb5J(0B2P(v(Tb1650mTbTBxPZrXZiHHEqnf8yMD1DDOoAORd1rZi4oEqD7u)M6qD0m(y9kb7uRmyuBDKaqiHLZ8dKtPLvOFmgDokEgjm0dQPGhbWoKJrq(OpTskmOwphJohfpJeg6b1uWJS(a1uVNBRuuuDsjabP5bzhbwZJB2P(Icli7OXSMhb2a8nUbk)2GA9CAM2G2TRHUePgyQalhbq6KpZU6g2PwzHUePgyQalhbq6KN5hiNsltNj5hihdoiWOhOZhJrZdYoQ3KTOqHHAiPnKvsA(ib6tB9rnndVaoH(v(Tb1650mTbTBx1wWxIEmZU6g2PwzHUePgyQalhbq6KN5uQeStTYGrT1rcaHewoZPSOWcYoAmR5rGnaFJBYcLFBqTEontBq721aW7q8ibmvaLmq0)2GA9CAM2G2TR1H6OrpiudjTHaym4ZSRUHDQvgmQTosaiKWYz(bYvuybzhnM18iWgGVXnq53guRNtZ0g0UD1YrGZbpoNhuhcfZSRUHDQvgbPRMqTguhcfzoLffWo1kJG0vtOwdQdHIa64CgsyAlORUj7sffwq2rJznpcSb4BCdu(Tb1650mTbTBxHrT1rcaHewEMD1Tfj8m2CiasB5alhbLbDvgEbCc9kb7uRmyuBDKaqiHLZiiF0NEZo1xua7uRmyuBDKaqiHLZ8dKtj6mj)a5yHUePgyQalhbq6KNrq(Op9czHsrHfKD0ywZJaBa(g3KfkqVt9)2GA9CAM2G2TRWbbg9aD(yz2v3HAiPnK5JJIGPc8yy5msCRUqwLGDQvMpokcMkWJHLZiiF0NEZo1)BdQ1ZPzAdA3UcNMXdMkWYraEiVkz2v3Wo1kl0Li1atfy5iasN8mcYh9Pxi7sqVt9ffwq2rJznpcSb4BCt2LGEN6)Tb1650mTbTBxxTtjaD45JZ)BdQ1ZPzAdA3Uch7GPcmstxvNzxDd7uRmyuBDKaqiHLZ8dKROWcYoAmR5rGnaFJBGYVnOwpNMPnOD7knV5dKeaD(y)2GA9CAM2G2TR(MGaym02VnOwpNMPnOD7kCqGrpqNpwMD1Tfj8m2CiasB5alhbLbDvgEbCc9krZdYoQbvsqTEUiTqwgukkO5bzh1GkjOwpxKwilldkkOZK8dKJf6sKAGPcSCeaPtEgb5J(0BkrJXh9XGDQvwLGNAQW8oKW65GQ7uVsHAiPnKvsA(ib6tB9rnndVaoH(Icli7OXSMhb2a8nUzD(Tb1650mTbTBxlDiDvL(2bWPqBz2v3Wo1kdg1whjaesy5m)a5kkSGSJgZAEeydW34Mm43guRNtZ0g0UDfoiKyh)Tb1650mTbTBxPdmja68XYSRUxUouhnuLoAd66qD0mcUJhu3Y0zs(bYXwTtjaD45JZZiiF0NgQMDLfcQ1ZXwTtjaD45JZZOJ2kkOZK8dKJTANsa6WZhNNrq(Op9czHEN6vIotYpqogmQTosaiKWYzeKp6td2DqTEH6qD0mR5rGna(y9ffWo1kJh5hIkGPcso02d8em41mNYvuIotYpqo2QDkbOdpFCEgb5J(0lKTOWcYoAmR5rGnaFJBu1VnOwpNMPnOD7kCqGrpqNpwMD1DjAm(OpgStTYQe8utfM3HewphuDN6xO6KsacsZdYocSMhfC6sKkuCnOOkHjmHa]] )
    end


end
