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
        spec:RegisterPack( "Beast Mastery", 20201016.9, [[dKKfNaqibIEebI2KGYNuj1OieDkcHvjOQ8kbzweQULGQQDr0VuIgMsfhtalJq5zkvAAkHY1ujzBei9nbcgNaPCocuwNGQmpvI7PsTpcWbjGkluPQhsGWhjGQgjbQ0jjqvRKszMkHQBsaL2Pi5NcKQwkbu8ujMQi1xjqfJvGqNvGK9k1FfAWI6WuTyO8yitwsxg1MvXNvkJweNwXQfivETsWSP42q1Ub(TQgUs64eqwoONJy6KUoLSDcPVtqJxjKZlqTEbvMpLQ9J0DGoDxQUYDkX2rSDcStGDL7iyb2zXc0fn4vUlRoAbFJ7cWX5USNDIsZcSorzyWDz1d28ETt3fYBbrCxsuDLeElxUnAIfMe94ljdULX15biOF0LKbhTSlywJrf8GgRlvx5oLy7i2ob2jWUYDeSa7SBqRlULM8WUugCbrxsMALbnwxQmb1fbjnVNDIsZcSorzyW0SGRfqzi1MGKMd6r6JXqAoWUItZITJy7qTrTjiP5fNfLn0SaO5R2r2fZqusNUlv(4wgTt3Pc0P7IJ05bDb9waLHrsYRDHboMHR9(w7uI1P7IJ05bDrHoqGSgZeUbSfjjV2fg4ygU27BTtTBNUlmWXmCT33feCugoExwHSOXnuvgq6KvgPX)e1eokCmvA2UDA(mBjAeY4(ai08fAwSD6IJ05bDXIWXrzCsRDQfRt3fg4ygU277IJ05bDb5gt0r68GOziAxmdrJahN7cQsATtDvNUlmWXmCT33feCugoExCKoIYrgW4dtO5l0SyDXr68GUGCJj6iDEq0meTlMHOrGJZDHOT2Pe0oDxyGJz4AVVli4OmC8U4iDeLJmGXhMqZcGMd0fhPZd6cYnMOJ05brZq0UygIgboo3fKHDr5wBTlRqg94yU2P7ub60DXr68GUqSWXFqCL1UWahZW1EFRDkX60DHboMHR9(UGGJYWX7c0cWNhUXsYBzopCJJmogdjswGSM1vU2fhPZd6I6WOc91w7u72P7cdCmdx79DzfYiNOrDW5UeqUBxCKopOlozLrA8prnHJchtT1o1I1P7cdCmdx79DzfYiNOrDW5UeqEvxCKopOlymrh3efcDnPli4OmC8UeK0S6ggOscIbA8prmZ)vjdCmdxP5WO5GKMHwa(8WnwsElZ5HBCKXXyirYcK1SUY1wBTlOkPt3Pc0P7cdCmdx79DbbhLHJ3f0)M6leiXyIoUjke6AIeY4(ai0SaO5D3PlosNh0fhGyIcDte5gtRDkX60DHboMHR9(UGGJYWX7c6Ft9fcKymrh3efcDnrczCFaeAwa08U70fhPZd6YzGmM5)ARDQD70DHboMHR9(UGGJYWX7cM15iDYkJ04FIAchfoMQ0ALMdJMfjnFMTenczCFaeAwa0m6Ft9fcKymKWWfgWMSAbDDEanhIMRwqxNhqZ2TtZIKMvhUXQmHDJMixrknFHM39kA2UDAoiPz1nmqLlmgddJdGOdaPsg4ygUsZIGMfbnB3onFMTenczCFaeA(cnhy3U4iDEqxWyiHHlmGTw7ulwNUlmWXmCT33feCugoExWSohPtwzKg)tut4OWXuLwR0Cy0SiP5ZSLOriJ7dGqZcGMr)BQVqGeZ8FnESGblRwqxNhqZHO5Qf015b0SD70SiPz1HBSkty3OjYvKsZxO5DVIMTBNMdsAwDddu5cJXWW4ai6aqQKboMHR0SiOzrqZ2TtZNzlrJqg3haHMVqZbe0U4iDEqxWm)xJhlyWT2PUQt3fg4ygU277ccokdhVlywNJ8azq4cwATsZHrZywNJ8azq4cwczCFaeAwa08gQkX9frZ2TtZbjnJzDoYdKbHlyP1AxCKopOlMzlrjXGoR6god0w7ucANUlmWXmCT33feCugoExWSohjgt0XnrHqxtKwR0Cy0mM15iDYkJ04FIAchfoMQ0ALMdJMvhUXQmHDJMixrknFHM39kA2UDAwK0SiPz0diw4oMHLRVopi(NOfadovdxJhlyW0SD70m6belChZWslagCQgUgpwWGPzrqZHrZNzlrJqg3haHMVqZcAaA2UDA(mBjAeY4(ai08fAwmbLMfrxCKopOlRVopO1w7cr70DQaD6UWahZW1EFxqWrz44DbZ6CKhidcxWsRvAomAgZ6CKhidcxWsiJ7dGqZxUP5nuLMTBNMpwgteYOehUXrDWzA(cnVHQ0Cy0m6Ft9fcKymrh3efcDnrczCFaeA2UDAg9VP(cbsmMOJBIcHUMiHmUpacnFHMdignhIM3qvAomAwDddujbXan(NiM5)QKboMHRDXr68GUG5qmUgjjV2ANsSoDxyGJz4AVVli4OmC8UaTa85HBSK8wMZd34iJJXqIKfiRzDLR0Cy0S6WOc9vjKX9bqO5l08gQsZHrZO)n1xiqEmoKLqg3haHMVqZBOAxCKopOlQdJk0xBTtTBNUlmWXmCT33feCugoExuhgvOVkTw7IJ05bD5yCi3ANAX60DXr68GUiCm1izDGJs6cdCmdx79T2PUQt3fhPZd6YcJXejjV2fg4ygU27BTtjOD6U4iDEqxogpyUgjjV2fg4ygU27BTtfe60DHboMHR9(UGGJYWX7Y5rweAoenJCIgH8gdO5l085rwejUVOU4iDEqxQSRjruIVa0XBTtf060DXr68GUGz(Vss4AxyGJz4AVV1oLG1P7IJ05bDXjRmsJ)jQjCu4yQDHboMHR9(w7ub2Pt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQab60DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkGyD6U4iDEqxWyIoUjke6AsxyGJz4AVV1ovGD70DXr68GUazYdCDaBrhcFHDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOllmgte944oO2fg4ygU27BTtfqq70DHboMHR9(UGGJYWX7cM15iXyIoUjke6AIS(cb0SD708z2s0iKX9bqO5l08vDXr68GUG5BX)ev4GwG0ANkqqOt3fhPZd6sDGCeJDI2fg4ygU27BTtfiO1P7cdCmdx79DbbhLHJ3LZSLOriJ7dGqZxOzbRlosNh0fmhIX1ij51w7ubeSoDxCKopOlyoe6BCxyGJz4AVV1oLy70P7cdCmdx79DbbhLHJ3frsZNhzrO5WpnJEIsZHO5ZJSisiVXaAo8rZIKMr)BQVqGCHXyIOhh3bvjKX9bqO5WpnhGMfbnlaA2r68a5cJXerpoUdQs0tuA2UDAg9VP(cbYfgJjIECChuLqg3haHMfanhGMdrZBOknhgnJ(3uFHajgt0XnrHqxtKqg3hajUzXecnlaA(8ilIuhCoQFe3xenlcAomAg9VP(cbYfgJjIECChuLqg3haHMfanhGMTBNMpZwIgHmUpacnFHM3TlosNh0f0Jb9ij51wBTlid7IYD6ovGoDxyGJz4AVVlosNh0fmhIX1ij51UGGJYWX7cM15ipqgeUGLwR0Cy0mM15ipqgeUGLqg3haHMVCtZBOAxqbJmCuD4gRKovGw7uI1P7cdCmdx79DbbhLHJ3fmRZrIXorJid7IYsiJ7dGqZxO5DKIDfnhIM3q1U4iDEqxWTm6qsET1o1UD6UWahZW1EFxqWrz44DbAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP5WOz1Hrf6RsiJ7dGqZxO5nuLMdJMr)BQVqG8yCilHmUpacnFHM3q1U4iDEqxuhgvOV2ANAX60DHboMHR9(UGGJYWX7I6WOc9vP1AxCKopOlhJd5w7ux1P7cdCmdx79DbbhLHJ3LZJSi0CiAg5enc5ngqZxO5ZJSisCFrDXr68GUuzxtIOeFbOJ3ANsq70DXr68GUiCm1izDGJs6cdCmdx79T2PccD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LJLXeHmkXHBCuhCMMVqZBOknhgnJ(3uFHajgt0XnrHqxtKqg3haHMTBNMr)BQVqGeJj64MOqORjsiJ7dGqZxO5aIrZHO5nuLMdJMv3WavsqmqJ)jIz(VkzGJz4AxqbJmCuD4gRKovGw7ubToDxCKopOlozLrA8prnHJchtTlmWXmCT33ANsW60DXr68GUGXeDCtui01KUWahZW1EFRDQa70P7IJ05bDbYKh46a2Ioe(c7cdCmdx79T2PceOt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQaI1P7IJ05bD5y8G5AKK8AxyGJz4AVV1ovGD70DXr68GUSWymrsYRDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOlyM)RKeU2fg4ygU27BTtfqq70DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkqqOt3fg4ygU277ccokdhVlywNJ8azq4cwczCFaeAwa0mVigzPCuhCUlosNh0fmhc9nU1ovGGwNUlmWXmCT33feCugoExopYIqZcGMrprP5q0SJ05bsClJoKKxLONODXr68GUSWymr0JJ7GARDQacwNUlmWXmCT33feCugoExWSohjgt0XnrHqxtK1xiGMTBNMpZwIgHmUpacnFHMVQlosNh0fmFl(NOch0cKw7uITtNUlosNh0L6a5ig7eTlmWXmCT33ANsSaD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LZSLOriJ7dGqZxOzbRlOGrgoQoCJvsNkqRDkXeRt3fg4ygU277ccokdhVlNhzrK6GZr9J4(IO5l08gQsZHpAwSU4iDEqxCiYbCKK8ART2AxeLHK5bDkX2rSDcStaXKcwxe6qWa2iDrWrGtGjLGpLaF4rZ0C6eMMh81hQ085H081Ok5AAgYcK1a5kntECMMDl9XDLR0mkXbBmrsTT4dGP5RcpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYDxKiKuBuBcocCcmPe8Pe4dpAMMtNW08GV(qLMppKMVMOxtZqwGSgixPzYJZ0SBPpURCLMrjoyJjsQTfFamnhi8OzbXdeLHkxP5RxzvgeLbLukVMM1NMVoOKs510SifBrIqsTrTj4iWjWKsWNsGp8OzAoDctZd(6dvA(8qA(AKHDr5RPzilqwdKR0m5XzA2T0h3vUsZOehSXej12IpaMMdeE0SG4bIYqLR081RSkdIYGskLxtZ6tZxhusP8AAwKITiriP2w8bW0SyHhnliEGOmu5knF9kRYGOmOKs510S(081bLukVMMfzGfjcj12IpaMMdeecpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYalsesQnQnbp(6dvUsZxrZosNhqZMHOej1wxwH)zmCxeK08E2jknlW6eLHbtZcUwaLHuBcsAoOhPpgdP5a7konl2oITd1g1MGKMxCwu2qZcGMVAhj1g1MJ05be5kKrpoMRHUxsSWXFqCLvQnhPZdiYviJECmxdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2CKopGixHm6XXCn09sNSYin(NOMWrHJPk(kKrorJ6GZ3bK7sT5iDEarUcz0JJ5AO7Lymrh3efcDnr8viJCIg1bNVdiVs85ChKQByGkjigOX)eXm)xLmWXmCnSGeAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2O2CKopGe6Ej6TakdJKKxP2CKopGe6EPcDGaznMjCdylssELAZr68asO7LweookJteFo3Rqw04gQkdiDYkJ04FIAchfoMQD7NzlrJqg3ha5Iy7qT5iDEaj09sKBmrhPZdIMHOIdCC(gvjuBosNhqcDVe5gt0r68GOziQ4ahNVjQ4Z52r6ikhzaJpm5IyuBosNhqcDVe5gt0r68GOziQ4ahNVrg2fLfFo3oshr5idy8Hjcia1g1MJ05bejQscDV0biMOq3erUXi(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxEgiJz(Vk(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxIXqcdxyaBIpNBmRZr6KvgPX)e1eokCmvP1AyI8mBjAeY4(aica9VP(cbsmgsy4cdytwTGUopiu1c668a72fP6WnwLjSB0e5ksVS7v2ThKQByGkxymgggharhasLmWXmCveIWU9ZSLOriJ7dGCjWUuBosNhqKOkj09smZ)14XcgS4Z5gZ6CKozLrA8prnHJchtvATgMipZwIgHmUpaIaq)BQVqGeZ8FnESGblRwqxNheQAbDDEGD7IuD4gRYe2nAICfPx29k72ds1nmqLlmgddJdGOdaPsg4ygUkcry3(z2s0iKX9bqUeqqP2CKopGirvsO7LMzlrjXGoR6goduXNZ9kRsCFasmRZrEGmiCblTwdBLvjUpajM15ipqgeUGLqg3haraBOQe3xKD7b5kRsCFasmRZrEGmiCblTwP2CKopGirvsO7LRVopq85CJzDosmMOJBIcHUMiTwddZ6CKozLrA8prnHJchtvATgM6WnwLjSB0e5ksVS7v2TlsrIEaXc3XmSC915bX)eTayWPA4A8ybd2UD0diw4oMHLwam4unCnESGblIWoZwIgHmUpaYfbnGD7NzlrJqg3ha5IycQiO2O2CKopGirg2fLdDVeZHyCnssEvCuWidhvhUXk5oG4Z5ELvjUpajM15ipqgeUGLwRHTYQe3hGeZ6CKhidcxWsiJ7dGC5EdvP2CKopGirg2fLdDVe3YOdj5vXNZ9kRsCFasmRZrIXorJid7IYsiJ7dGCzhPyxfAdvP2CKopGirg2fLdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxdtDyuH(QeY4(aix2q1Wq)BQVqG8yCilHmUpaYLnuLAZr68aIezyxuo09YJXHS4Z5wDyuH(Q0ALAZr68aIezyxuo09Yk7AseL4laDCXNZ95rwKqiNOriVXGlNhzrK4(IO2CKopGirg2fLdDVu4yQrY6ahLqT5iDEarImSlkh6EjMdX4AKK8Q4OGrgoQoCJvYDaXNZ9XYyIqgL4WnoQdoFzdvdd9VP(cbsmMOJBIcHUMiHmUpaID7O)n1xiqIXeDCtui01ejKX9bqUeqSqBOAyQByGkjigOX)eXm)xLmWXmCLAZr68aIezyxuo09sNSYin(NOMWrHJPsT5iDEarImSlkh6Ejgt0XnrHqxtO2CKopGirg2fLdDVeYKh46a2Ioe(cP2CKopGirg2fLdDVKOo(kxzXNZnM15iDYkJ04FIAchfoMQ0A1U9ZSLOriJ7dGCjWvuBosNhqKid7IYHUxEmEWCnssELAZr68aIezyxuo09YfgJjssELAZr68aIezyxuo09suYG7m0JKKxP2CKopGirg2fLdDVeZ8FLKWvQnhPZdisKHDr5q3l9iUfSYW4FIi4lKqT5iDEarImSlkh6EjMdH(gl(CUxzvI7dqIzDoYdKbHlyjKX9bqeaVigzPCuhCMAZr68aIezyxuo09YfgJjIECChufFo3Nhzrea6jAihPZdK4wgDijVkrprP2CKopGirg2fLdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKid7IYHUxwhihXyNOuBosNhqKid7IYHUxI5qmUgjjVkokyKHJQd3yLChq85CFMTenczCFaKlcg1MJ05bejYWUOCO7Loe5aossEv85CFEKfrQdoh1pI7l6YgQg(eJAJAZr68aIKOHUxI5qmUgjjVk(CUxzvI7dqIzDoYdKbHlyP1AyRSkX9biXSoh5bYGWfSeY4(aixU3qv72pwgteYOehUXrDW5lBOAyO)n1xiqIXeDCtui01ejKX9bqSBh9VP(cbsmMOJBIcHUMiHmUpaYLaIfAdvdtDddujbXan(NiM5)QKboMHRuBosNhqKen09s1Hrf6RIpNBOfGppCJLK3YCE4ghzCmgsKSaznRRCnm1Hrf6RsiJ7dGCzdvdd9VP(cbYJXHSeY4(aix2qvQnhPZdisIg6E5X4qw85CRomQqFvATsT5iDEars0q3lfoMAKSoWrjuBosNhqKen09YfgJjssELAZr68aIKOHUxEmEWCnssELAZr68aIKOHUxwzxtIOeFbOJl(CUppYIec5enc5ngC58ilIe3xe1MJ05bejrdDVeZ8FLKWvQnhPZdisIg6EPtwzKg)tut4OWXuP2CKopGijAO7Le1Xx5kl(CUXSohPtwzKg)tut4OWXuLwR2TFMTenczCFaKlbUIAZr68aIKOHUx6rClyLHX)erWxiHAZr68aIKOHUxIXeDCtui01eQnhPZdisIg6EjKjpW1bSfDi8fsT5iDEars0q3lrjdUZqpssELAZr68aIKOHUxUWymr0JJ7Gk1MJ05bejrdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKen09Y6a5ig7eLAZr68aIKOHUxI5qmUgjjVk(CUpZwIgHmUpaYfbJAZr68aIKOHUxI5qOVXuBosNhqKen09s0Jb9ij5vXNZTippYIe(rprdDEKfrc5nge(ej6Ft9fcKlmgte944oOkHmUpas4pGieGJ05bYfgJjIECChuLONO2TJ(3uFHa5cJXerpoUdQsiJ7dGiGaH2q1Wq)BQVqGeJj64MOqORjsiJ7dGe3SycraNhzrK6GZr9J4(IeryO)n1xiqUWymr0JJ7GQeY4(aiciGD7NzlrJqg3ha5YUDHSYOoLyxTBRT2na]] )
    else
        spec:RegisterPack( "Beast Mastery", 20201016.1, [[dS0MfbqisqpssOSjsOprcmkfItPqAvQsQ8kvPMLKOBPkj2fr)seAykihtsAzkOEMKGPrb01uLyBua(McegNKqoNQKY6uOkZtrCpr0(uahusOAHIGhQkjnrfQQ8rfi1ivOQ0jvGOvQintkqCtfQQANKi)uHQcdvHQIwQQKQEksnvsuFvbsglfiDwfOSxs9xOgmHdt1Ivvpg0Kf1LrTzj(SIA0K0PLA1kq1RvOmBkDBKSBL(TkdxsDCkqTCiphX0fUofTDkuFxvmEfQCEkO1tHmFrA)aRRQvwtN9G1kn8qdpu1HQAaYQgy1HmWx00HH1SMU2HJ5ZSMEDkwtNa7Kaig)DsWid101UH2ZZAL10KZebznTAe1KXlXeN7q18lHhvIKMY06rFle5Lirstbtut)nBBmix9xtN9G1kn8qdpu1HQAaYQgy1HmWkOPDZq9qAA6M6v10QDoZR(RPZmbQPRyarcStcGy83jbJmeigFn3GrGPvmGy8bmUpJaIQgqLaXWdn8qGPGPvmGWGWgZwGyssG4LHKAABtcIwznDMlUPn0kRvQQwznTdJ(wnn8m3GryI6fAAE9VLZ6e0HwPH1kRP51)woRtqtdrDWO2101i2y8mmlRkDsndd8vWHkJFABgistbIspRgyet59saIjaXWdPPDy03QPnjmUdMIOdTsvqRSMMx)B5SobnTdJ(wnTBer1robxUnWxbxFpmstdrDWO210W7S57zLoPMHb(k4qLXpTnlrmL3lbpBYecqmbiQ(cqOiqu6z1aJykVxcqmaquDin96uSM2nIO6iNGl3g4RGRVhgPdTsgOwznnV(3YzDcAAhg9TAANOASVmbJCJoegEi3QPHOoyu7A6m)nlfjYn6qy4HCloZFZsrAwdekceJaekeiyd2SRR5S0nIO6iNGl3g4RGRVhgbePPab8oB(EwPBer1robxUnWxbxFpmsIykVxcqmaqurgaqKMcemHWlKLF7Dz8vWHkJ5LPmus5d(HaIrbcfbIraIAeBmEgMLvLoPMHb(k4qLXpTndePPaHcbc2Gn76AolHgcTxGUTH4V1jbqOiq8nlfPtQzyGVcouz8tBZset59saIbaIxdigfiueigbiuiqWecVqwcVnZlHZyBx4YHGSKYh8dbePPaX3SuKZMok3(IVc2nIrxOknRbIrbcfbIraIWrZCivz3gQYAyaetaIk8cqKMcekeiycHxilH3M5LWzSTlC5qqws5d(HaI0uGqHar4wEd5yT1YiCVKOxyi51)wodeJcePPaXiarM)MLIe5gDim8qUfN5VzPiZ3ZcePParPNvdmIP8EjaXeGyydaigfiueik9SAGrmL3lbigaigbig2abIxhqmcqaVZMVNvcneAVaDBdXFRtcjIP8EjaXBGWabIjarPNvdmIP8EjaXOaXOA61PynTtun2xMGrUrhcdpKB1HwPx0kRP51)woRtqt7WOVvtdneAVaDBdXFRtcnne1bJAxt)nlf5Njr7w8dYdvz(EwGinfik9SAGrmL3lbiMaeVOP5sHHbEDkwtdneAVaDBdXFRtcDOvYa0kRP51)woRtqt7WOVvtdDRf7WOVfBBsOPTnjWRtXAAyMOdTsdcTYAAE9VLZ6e00quhmQDnTdJ2ygZlt1mbiMaedRPDy03QPHU1IDy03ITnj002Me41Pynnj0HwPksRSMMx)B5Sobnne1bJAxt7WOnMX8YuntaIbaIQAAhg9TAAOBTyhg9TyBtcnTTjbEDkwtdTSBmRdDOPRrm8O(EOvwRuvTYAAhg9TAAIjf1T4Ao0086FlN1jOdTsdRvwtZR)TCwNGMEDkwt7gruDKtWLBd8vW13dJ00om6B10Urevh5eC52aFfC99WiDOvQcAL10om6B10phYMnM7fJyYT(cznnV(3YzDc6qRKbQvwt7WOVvtpB6OC7l(ky3igDHQMMx)B5SobDOv6fTYAAhg9TAAkM6qgIVc2Ac7moJyNIOP51)woRtqhALmaTYAAE9VLZ6e00om6B10qdH2lq32q836KqtdrDWO210keiqENXSX8gYEn20UmY)wwYJRjbbiueigbicuVJXHSQu1jy4D289SaXBGiq9oghYHLQobdVZMVNfiMaeddePPabBWMDDnNLg7O2)wg3BWlPddXZ9SB8zd8rGT16rVZye7W4qaXOAAUuyyGxNI10qdH2lq32q836KqhALgeAL1086FlN1jOPHOoyu7AAfceiVZy2yEdzVgBAxg5Fll5X1KGOPDy03QPlh0KWzSBeJ6GXF2P0HwPksRSMMx)B5SobnDnIHojWrtXA6QYkOPDy03QPDsndd8vWHkJFABwtdrDWO210keiCJyuhSSg1uUf3lj6fgejV(3YzGqrGqHabti8czjti8cz8vWHkJlh0K07mUrnrs5d(HacfbIrac2Gn76AolDJiQoYj4YTb(k467HrarAkqOqGGnyZUUMZsOHq7fOBBi(BDsaeJQdTsVMwznnV(3YzDcA6AedDsGJMI10vLVOPDy03QP)mjA3IFqEOQPHOoyu7AA3ig1blRrnLBX9sIEHbrYR)TCgiueiuiqWecVqwYecVqgFfCOY4Ybnj9oJButKu(GFiGqrGyeGGnyZUUMZs3iIQJCcUCBGVcU(EyeqKMcekeiyd2SRR5SeAi0Eb62gI)wNeaXO6qhAAyMOvwRuvTYAAE9VLZ6e00quhmQDnn8oB(Ew5Njr7w8dYdvjIP8EjaXaarfgst7WOVvt7lKjbYTyOBT6qR0WAL1086FlN1jOPHOoyu7AA4D289SYptI2T4hKhQset59saIbaIkmKM2HrFRMU0i(BVlRdTsvqRSMMx)B5Sobnne1bJAxt)nlfPtQzyGVcouz8tBZsZAGqrGyeGO0ZQbgXuEVeGyaGaENnFpR8ZicJgR3zz2e5rFlq8giYMip6BbI0uGyeGiC0mhsv2THQSggaXeGOcVaePPaHcbIWT8gYXARLr4EjrVWqYR)TCgigfigfistbIspRgyet59saIjar1kOPDy03QP)mIWOX6DwhALmqTYAAE9VLZ6e00quhmQDn93SuKoPMHb(k4qLXpTnlnRbcfbIraIspRgyet59saIbac4D289SYV9UmUyImuMnrE03ceVbISjYJ(wGinfigbichnZHuLDBOkRHbqmbiQWlarAkqOqGiClVHCS2AzeUxs0lmK86FlNbIrbIrbI0uGO0ZQbgXuEVeGycqu1a00om6B10F7DzCXezOo0k9IwznnV(3YzDcAAiQdg1UM(BwkYcIxJmuAwdekceFZsrwq8AKHset59saIbaIzyws5JdistbcfceFZsrwq8AKHsZAnTdJ(wnTTNvdcEWnZZu8g6qRKbOvwtZR)TCwNGMgI6GrTRP)MLI8ZKODl(b5HQ0Sgiuei(MLI0j1mmWxbhQm(PTzPznqOiqeoAMdPk72qvwddGycquHxaI0uGyeGyeGaElXKY)wwwFrFl(kyZ9J6SLZ4IjYqGinfiG3smP8VLLM7h1zlNXftKHaXOaHIarPNvdmIP8EjaXeGWaQcePParPNvdmIP8EjaXeGyydaigvt7WOVvtxFrFRo0kni0kRP51)woRtqtdrDWO210Jae1i2y8mmlRkDsndd8vWHkJFABgistbc4D289SsNuZWaFfCOY4N2MLiMY7LaetaIzygistbIspRgyet59saIjaXWdbeJcePPaHcbcMq4fYsJBsFl(k4Agvyy03kP69qAAhg9TA6NdzZgZ9Irm5wFHSo0kvrAL1086FlN1jOPHOoyu7AA4D289SsNuZWaFfCOY4N2MLiMY7LaetaIQdbePParPNvdmIP8EjaXaaHdJ(wm8oB(EwG4nqKnrE03cePParPNvdmIP8EjaXeGOcdPPDy03QPNnDuU9fFfSBeJUqvhALEnTYAAhg9TAAuxxBzCVysTdznnV(3YzDc6qRu1H0kRPDy03QPPyQdzi(kyRjSZ4mIDkIMMx)B5SobDOvQAvTYAAE9VLZ6e00quhmQDnD4OzoKQSBdvznmaIbaIkAiGinfichnZHuLDBOkRHbqmjjqm8qarAkqeoAMdz0umooCnmWdpeqmaquHH00om6B10i2R7DgxSoft0Ho00KqRSwPQAL10om6B10J1wlMOEHMMx)B5SobDOvAyTYAAhg9TA6V9UmrLZAAE9VLZ6e0HwPkOvwtZR)TCwNGMgI6GrTRP)MLISG41idLM1aHIaX3SuKfeVgzOeXuEVeGycqmdZarAkqaVZMVNv(zs0Uf)G8qvIykVxcqOiqmcqumTwmIHQoAMXrtXaXeGygMbI0uGWnIrDWYAut5wCVKOxyqK86FlNbcfbc4D289SsNuZWaFfCOY4N2MLiMY7LaetaIzygigfistbc4D289SYptI2T4hKhQset59saIjar1HbI3aXmmdekceHB5nKeiVb(k4V9USKx)B5SM2HrFRM(7OpNXe1l0HwjduRSMMx)B5Sobnne1bJAxtxoOjbiEdeLdAsKiEMxG41beZWmqmbikh0KiP8XbekceFZsr(zs0Uf)G8qvMVNfiueigbiuiqKVqcVfYBG8GZ4I1Py83eTset59sacfbcfceom6BLWBH8gip4mUyDkw2lUy7z1aigfistbIIP1Irmu1rZmoAkgiMaeZWmqKMceLEwnWiMY7LaetaIx00om6B10WBH8gip4mUyDkwhALErRSMMx)B5Sobnne1bJAxt)nlfPtQzyGVcouz8tBZY89SaHIaXiab8oB(Ew53rFoJjQxiHQoAMjaXeGOkqKMcekeiCJyuhSSg1uUf3lj6fgejV(3YzGyunTdJ(wnTtQzyGVcouz8tBZ6qRKbOvwtZR)TCwNGMgI6GrTRP)MLI0j1mmWxbhQm(PTzPznqOiq8nlf5Njr7w8dYdvPznqKMceLEwnWiMY7LaetaIQVOPDy03QPjHtvZzwhALgeAL10om6B10oMYeLze(kyi6EiAAE9VLZ6e0HwPksRSMMx)B5Sobnne1bJAxt)nlf5Njr7w8dYdvz(EwGinfik9SAGrmL3lbiMaeVOPDy03QPlh0KWzSBeJ6GXF2P0HwPxtRSMMx)B5Sobnne1bJAxt)nlfjIHJzzcbxoeKLM1arAkq8nlfjIHJzzcbxoeKXWZCdgjjHdhdiMaevhcistbIspRgyet59saIjaXlAAhg9TA6qLXM7)m3mUCiiRdTsvhsRSMMx)B5Sobnne1bJAxthUL3qsG8g4RG)27YsE9VLZarAkqeUL3qElJF6qfhQmU2HJj51)wodekceFZsr(zs0Uf)G8qvIykVxcqmbiMHzGinfi(MLI8ZKODl(b5HQmFplqOiqaVZMVNv6KAgg4RGdvg)02SeXuEVeGyaGO6larAkqu6z1aJykVxcqmbiQ(cq8giMHznTdJ(wn9Njr7w8dYdvDOvQAvTYAAE9VLZ6e00quhmQDnTBeJ6GLzFHm(k4m7HQe57yaXaarvGqrG4BwkYSVqgFfCM9qvIykVxcqmbiMHznTdJ(wn93rFoJjQxOdTsvhwRSMMx)B5Sobnne1bJAxt)nlfPtQzyGVcouz8tBZset59saIbaIQdbeVbIzygistbIspRgyet59saIjar1HaI3aXmmRPDy03QP)27Y4RGdvgZltzOo0kvTcAL10om6B10J1wlgEuu(M1086FlN1jOdTsvnqTYAAE9VLZ6e00quhmQDn93SuKFMeTBXpipuL57zbI0uGO0ZQbgXuEVeGycq8IM2HrFRM(7Z4RGdudhJOdTsvFrRSM2HrFRMgQ2uoJCmr9cnnV(3YzDc6qRuvdqRSM2HrFRMo3ig)zNeAAE9VLZ6e0HwPQdcTYAAE9VLZ6e00quhmQDnD4wEd5Tm(PdvCOY4AhoMKx)B5mqOiqavD0mtWfKdJ(w3cedaevLVaePPabu1rZmbxqom6BDlqmaquvwrarAkqaVZMVNv6KAgg4RGdvg)02SeXuEVeGycq8nlfzbXRrgkZMip6BbIxbiMHzGqrGWnIrDWYAut5wCVKOxyqK86FlNbI0uGO0ZQbgXuEVeGycq8AAAhg9TA6VJ(CgtuVqhALQwrAL1086FlN1jOPHOoyu7A6VzPi)mjA3IFqEOkZ3ZcePParPNvdmIP8EjaXeGOI00om6B101MOUyyVZ4V1jHo0kv910kRPDy03QP)oc5ZSMMx)B5SobDOvA4H0kRP51)woRtqtdrDWO210JaeLdAsaIxbiGhjaI3ar5GMejIN5fiEDaXiab8oB(Ew5yT1IHhfLVzjIP8EjaXRaevbIrbIbachg9TYXARfdpkkFZs4rcGinfiG3zZ3ZkhRTwm8OO8nlrmL3lbigaiQceVbIzygiueiG3zZ3Zk)mjA3IFqEOkrmL3lbpBYecqmaquoOjrgnfJJdt5JdistbIVzPiPyQdzi(kyRjSZ4mIDkI0SgigfiueiG3zZ3ZkhRTwm8OO8nlrmL3lbigaiQcePParPNvdmIP8EjaXeGOcAAhg9TAA49roMOEHo0knCvTYAAE9VLZ6e00quhmQDn93SuKfeVgzOmBI8OVfiEfGygMbIbaIIP1Irmu1rZmoAkwt7WOVvt)D0NZyI6f6qhAAOLDJzTYALQQvwtZR)TCwNGM2HrFRM(7OpNXe1l00quhmQDn93SuKfeVgzO0Sgiuei(MLISG41idLiMY7LaetsceZWSKYhhqKMceW7S57zLFMeTBXpipuLiMY7LaetaIQddeVbIzygiueic3YBijqEd8vWF7DzjV(3Yznn0qOLXHJM5GOvQQo0knSwznnV(3YzDcAAiQdg1UMEgMLu(4aIxbi(MLI8ZojWql7gZset59saIbaIHKd)IM2HrFRMMY0gnr9cDOvQcAL1086FlN1jOPDy03QP)o6Zzmr9cnne1bJAxtxmTwmIHQoAMXrtXaXeGygMLu(4acfbc4D289SYptI2T4hKhQset59s00qdHwghoAMdIwPQ6qRKbQvwt7WOVvt7KAgg4RGdvg)02SMMx)B5SobDOv6fTYAAE9VLZ6e00quhmQDn93SuKoPMHb(k4qLXpTnlnRbcfbIVzPi)mjA3IFqEOknRbI0uGO0ZQbgXuEVeGycqu9fnTdJ(wnnjCQAoZ6qRKbOvwtZR)TCwNGMgI6GrTRPd3YBijqEd8vWF7DzjV(3YzGinfiG3zZ3ZkDsndd8vWHkJFABwIykVxcE2KjeGyaGy4HaI0uGiClVH8wg)0HkouzCTdhtYR)TCgistbIspRgyet59saIjar1x00om6B10FMeTBXpipu1HwPbHwznTdJ(wnnuTPCg5yI6fAAE9VLZ6e0HwPksRSM2HrFRM2XuMOmJWxbdr3drtZR)TCwNGo0k9AAL10om6B10FhH8zwtZR)TCwNGo0kvDiTYAAE9VLZ6e00quhmQDnTdJ2ygZlt1mbiMaegiqKMcekeiCJyuhSe51DgJy75zjV(3YznTdJ(wn9yT1IHhfLVzDOvQAvTYAAhg9TA6CJy8NDsOP51)woRtqhALQoSwznnV(3YzDcAAhg9TA6VJ(CgtuVqtdrDWO210FZsrwq8AKHY89SaHIaXiabu1rZmbxqom6BDlqmaquvwrarAkq8nlf5Njr7w8dYdvPznqmkqKMceW7S57zLoPMHb(k4qLXpTnlrmL3lbiMaeFZsrwq8AKHYSjYJ(wG4vaIzygiueiCJyuhSSg1uUf3lj6fgejV(3YzGinfiGQoAMj4cYHrFRBbIbaIQsdeistbIspRgyet59saIjaXRPPHgcTmoC0mheTsv1HwPQvqRSM2HrFRMUCqtcNXUrmQdg)zNstZR)TCwNGo0kv1a1kRPDy03QPRnrDXWENXFRtcnnV(3YzDc6qRu1x0kRPDy03QPH3c5nqEWzCX6uSMMx)B5SobDOvQQbOvwt7WOVvt)T3LXxbhQmMxMYqnnV(3YzDc6qRu1bHwznnV(3YzDcAAiQdg1UM(BwksedhZYecUCiilnRbI0uG4BwksedhZYecUCiiJHN5gmsschogqmbiQoKM2HrFRMouzS5(pZnJlhcY6qRu1ksRSMMx)B5Sobnne1bJAxt7gXOoyjYR7mgX2ZZsE9VLZaHIaHdJ2ygZlt1mbigaigwt7WOVvttzAJMOEHo0kv910kRP51)woRtqtdrDWO210W7S57zLJ1wlgEuu(MLiMY7LaedaeLdAsKrtX44Wu(4acfbIrachgTXmMxMQzcqmbiQaqKMcekeiCJyuhSe51DgJy75zjV(3YzGyunTdJ(wnn8(ihtuVqh6qhAAJzePVvR0Wdn8qvhQAfKv10poA7DMOPhuv8xVsdsLg0JhqaekRYartvFOaikhciuqMlUPnuaqGyd2SrCgiihfdeUzCuEWzGaQ67mtKGPgKEzGWahpG4vV1ygfCgiuqG6DmoKguj8oB(EwfaeXbekaENnFpR0GQaGyKQJBujyky6GQI)6vAqQ0GE8acGqzvgiAQ6dfar5qaHcGzIcaceBWMnIZab5OyGWnJJYdodeqvFNzIem1G0ldeVmEaXRERXmk4mqOGAoKgu5GjLsfaeXbekyWKsPcaIrQW4gvcMcMoOQ4VELgKknOhpGaiuwLbIMQ(qbquoeqOasOaGaXgSzJ4mqqokgiCZ4O8GZabu13zMibtni9YarfgpG4vV1ygfCgiuqnhsdQCWKsPcaI4acfmysPubaXidpUrLGPgKEzGO6Gy8aIx9wJzuWzGqb1CinOYbtkLkaiIdiuWGjLsfaeJuDCJkbtni9YaXWvhpG4vV1ygfCgiuqnhsdQCWKsPcaI4acfmysPubaXivh3OsWuW0bvf)1R0GuPb94beaHYQmq0u1hkaIYHacfaTSBmRaGaXgSzJ4mqqokgiCZ4O8GZabu13zMibtni9Yar1XdiE1BnMrbNbcfuZH0GkhmPuQaGioGqbdMukvaqmYWJBujyQbPxgigE8aIx9wJzuWzGqb1CinOYbtkLkaiIdiuWGjLsfaeJuDCJkbtni9Yar1HhpG4vV1ygfCgiuqnhsdQCWKsPcaI4acfmysPubaXidpUrLGPGPdsQ6dfCgiEbiCy03ce2MeejyQMMuZqTsd)sf001OR0wwtxXaIeyNeaX4Vtcgziqm(AUbJatRyaX4dyCFgbevnGkbIHhA4HatbtRyaHbHnMTaXKKaXldjbtbtDy03sK1igEuFpENmrIjf1T4AoatDy03sK1igEuFpENmrtcJ7GPQCDkoPBer1robxUnWxbxFpmcm1HrFlrwJy4r994DYeFoKnBm3lgXKB9fYGPom6BjYAedpQVhVtM4SPJYTV4RGDJy0fQGPom6BjYAedpQVhVtMiftDidXxbBnHDgNrStratDy03sK1igEuFpENmrtcJ7GPQKlfgg41P4KqdH2lq32q836KOYUKuHiVZy2yEdzVgBAxg5Fll5X1KGO4ibQ3X4qwvQ6em8oB(E23bQ3X4qoSu1jy4D289StgonLnyZUUMZsJDu7FlJ7n4L0HH45E2n(Sb(iW2A9O3zmIDyCOrbtDy03sK1igEuFpENmXYbnjCg7gXOoy8NDQk7ssfI8oJzJ5nK9ASPDzK)TSKhxtccyAfdiQ45b3KeeGiuzGiBI8OVfi8ndeW7S57zbIRaevCsnddG4karOYaXGQTzGW3mqm(e1uUfigKlj6fgeG4BiqeQmqKnrE03cexbi8fimxvNeCgig0V64hq8OYlqeQSHkaXaHjHZarnIHh13djqKadDtcdevCsnddG4karOYaXGQTzGaXztitaIb9Ro(beFdbIHhAiksLarO2eGOjarvzfaccdVntKGPom6BjYAedpQVhVtMOtQzyGVcouz8tBZvwJyOtcC0uCYQYkuzxsQq3ig1blRrnLBX9sIEHbrYR)TCwrfYecVqwYecVqgFfCOY4Ybnj9oJButKu(GFifhHnyZUUMZs3iIQJCcUCBGVcU(EyuAQczd2SRR5SeAi0Eb62gI)wNeJcMwXaIkEEWnjbbicvgiYMip6BbcFZab8oB(EwG4karcmjA3cedkKhQaHVzGy81nIbIRaeVEFMbIVHarOYar2e5rFlqCfGWxGWCvDsWzGyq)QJFaXJkVarOYgQaedeMeode1igEuFpKGPom6BjYAedpQVhVtM4Njr7w8dYd1kRrm0jboAkozv5lv2LKUrmQdwwJAk3I7Le9cdIKx)B5SIkKjeEHSKjeEHm(k4qLXLdAs6Dg3OMiP8b)qkocBWMDDnNLUrevh5eC52aFfC99WO0ufYgSzxxZzj0qO9c0Tne)Tojgfmfm1HrFl5DYeHN5gmctuVam1HrFl5DYenjmUdMIuzxswJyJXZWSSQ0j1mmWxbhQm(PT500spRgyet59sMm8qGPom6BjVtMOjHXDWuvUofN0nIO6iNGl3g4RGRVhgvzxscVZMVNv6KAgg4RGdvg)02SeXuEVe8SjtitQ(IILEwnWiMY7Lmq1HatDy03sENmrtcJ7GPQCDkoPtun2xMGrUrhcdpKBRSljZ83SuKi3OdHHhYT4m)nlfPzTIJOq2Gn76AolDJiQoYj4YTb(k467HrPPbQ3X4q6gruDKtWLBd8vW13dJKW7S57zLiMY7LmqfzaPPmHWlKLF7Dz8vWHkJ5LPmus5d(HgvXrQrSX4zywwv6KAgg4RGdvg)02CAQczd2SRR5SeAi0Eb62gI)wNek(nlfPtQzyGVcouz8tBZset59sg41gvXruiti8czj82mVeoJTDHlhcYskFWpuA63SuKZMok3(IVc2nIrxOknRhvXrchnZHuLDBOkRHXKk8sAQczcHxilH3M5LWzSTlC5qqws5d(Hstvy4wEd5yT1YiCVKOxyi51)wopAA6iz(BwksKB0HWWd5wCM)MLImFpBAAPNvdmIP8Ejtg2agvXspRgyet59sgyKHnWx3iW7S57zLqdH2lq32q836KqIykVxYBdCsPNvdmIP8EjJokyQdJ(wY7KjAsyChmvLCPWWaVofNeAi0Eb62gI)wNev2LKFZsr(zs0Uf)G8qvMVNnnT0ZQbgXuEVKjVaM6WOVL8ozIq3AXom6BX2MevUofNeMjGPom6BjVtMi0TwSdJ(wSTjrLRtXjjrLDjPdJ2ygZlt1mzYWGPom6BjVtMi0TwSdJ(wSTjrLRtXjHw2nMRSljDy0gZyEzQMjdufmfm1HrFlrcZKK(czsGClg6wBLDjj8oB(Ew5Njr7w8dYdvjIP8EjduHHatDy03sKWm5DYelnI)27Yv2LKW7S57zLFMeTBXpipuLiMY7Lmqfgcm1HrFlrcZK3jt8ZicJgR35k7sYVzPiDsndd8vWHkJFABwAwR4iLEwnWiMY7Lma8oB(Ew5NregnwVZYSjYJ(23ztKh9TPPJeoAMdPk72qvwdJjv4L0ufgUL3qowBTmc3lj6fgsE9VLZJoAAAPNvdmIP8EjtQwbWuhg9TejmtENmXV9UmUyImSYUK8BwksNuZWaFfCOY4N2MLM1kosPNvdmIP8EjdaVZMVNv(T3LXftKHYSjYJ(23ztKh9TPPJeoAMdPk72qvwdJjv4L0ufgUL3qowBTmc3lj6fgsE9VLZJoAAAPNvdmIP8EjtQAaGPom6BjsyM8ozI2Ewni4b3mptXBuzxswZHKY7v(nlfzbXRrgknRvSMdjL3R8BwkYcIxJmuIykVxYaZWSKYhxAQcR5qs59k)MLISG41idLM1GPom6BjsyM8ozI1x03wzxs(nlf5Njr7w8dYdvPzTIFZsr6KAgg4RGdvg)02S0SwXWrZCivz3gQYAymPcVKMoYiWBjMu(3YY6l6BXxbBUFuNTCgxmrgMMcVLys5Flln3pQZwoJlMidhvXspRgyet59sMyavttl9SAGrmL3lzYWgWOGPom6BjsyM8ozIphYMnM7fJyYT(c5k7sYrQrSX4zywwv6KAgg4RGdvg)02CAk8oB(EwPtQzyGVcouz8tBZset59sMmdZPPLEwnWiMY7Lmz4HgnnvHmHWlKLg3K(w8vW1mQWWOVvs17HatDy03sKWm5DYeNnDuU9fFfSBeJUqTYUKeENnFpR0j1mmWxbhQm(PTzjIP8EjtQouAAPNvdmIP8EjdaVZMVN9D2e5rFBAAPNvdmIP8EjtQWqGPom6BjsyM8ozIOUU2Y4EXKAhYGPom6BjsyM8ozIum1HmeFfS1e2zCgXofbm1HrFlrcZK3jteXEDVZ4I1PysLDjz4OzoKQSBdvznmgOIgknnC0mhsv2THQSggtso8qPPHJM5qgnfJJdxdd8Wdnqfgcmfm1HrFlrcTSBm)ozIFh95mMOErLqdHwghoAMdsYQv2LK1CiP8ELFZsrwq8AKHsZAfR5qs59k)MLISG41idLiMY7Lmj5mmlP8XLMcVZMVNv(zs0Uf)G8qvIykVxYKQd)EgMvmClVHKa5nWxb)T3LL86FlNbtDy03sKql7gZVtMiLPnAI6fv2LKZWSKYh3RuZHKY7v(nlf5NDsGHw2nMLiMY7LmWqYHFbm1HrFlrcTSBm)ozIFh95mMOErLqdHwghoAMdsYQv2LKftRfJyOQJMzC0u8Kzyws5Jtr4D289SYptI2T4hKhQset59satDy03sKql7gZVtMOtQzyGVcouz8tBZGPom6BjsOLDJ53jtKeovnN5k7sYVzPiDsndd8vWHkJFABwAwR43SuKFMeTBXpipuLM1PPLEwnWiMY7LmP6lGPom6BjsOLDJ53jt8ZKODl(b5HALDjz4wEdjbYBGVc(BVll51)woNMcVZMVNv6KAgg4RGdvg)02SeXuEVe8Sjtidm8qPPHB5nK3Y4NouXHkJRD4ysE9VLZPPLEwnWiMY7LmP6lGPom6BjsOLDJ53jteQ2uoJCmr9cWuhg9Tej0YUX87Kj6yktuMr4RGHO7HaM6WOVLiHw2nMFNmXVJq(mdM6WOVLiHw2nMFNmXXARfdpkkFZv2LKomAJzmVmvZKjgyAQcDJyuhSe51DgJy75zjV(3YzWuhg9Tej0YUX87KjMBeJ)StcWuhg9Tej0YUX87Kj(D0NZyI6fvcneAzC4OzoijRwzxswZHKY7v(nlfzbXRrgkZ3ZQ4iqvhnZeCb5WOV1TduvwrPPFZsr(zs0Uf)G8qvAwpAAk8oB(EwPtQzyGVcouz8tBZset59sMuZHKY7v(nlfzbXRrgkZMip6BFLzywr3ig1blRrnLBX9sIEHbrYR)TConfQ6OzMGlihg9TUDGQsdmnT0ZQbgXuEVKjVgyQdJ(wIeAz3y(DYelh0KWzSBeJ6GXF2PatDy03sKql7gZVtMyTjQlg27m(BDsaM6WOVLiHw2nMFNmr4TqEdKhCgxSofdM6WOVLiHw2nMFNmXV9Um(k4qLX8YugcM6WOVLiHw2nMFNmXqLXM7)m3mUCiixzxs(nlfjIHJzzcbxoeKLM1PPFZsrIy4ywMqWLdbzm8m3Grss4WXMuDiWuhg9Tej0YUX87KjszAJMOErLDjPBeJ6GLiVUZyeBppl51)woROdJ2ygZlt1mzGHbtDy03sKql7gZVtMi8(ihtuVOYUKeENnFpRCS2AXWJIY3SeXuEVKbkh0KiJMIXXHP8XP4iomAJzmVmvZKjvinvHUrmQdwI86oJrS98SKx)B58OGPGPom6BjssKCS2AXe1latDy03sKK4DYe)27YevodM6WOVLijX7Kj(D0NZyI6fv2LK1CiP8ELFZsrwq8AKHsZAfR5qs59k)MLISG41idLiMY7LmzgMttH3zZ3Zk)mjA3IFqEOkrmL3lrXrkMwlgXqvhnZ4OP4jZWCAQBeJ6GL1OMYT4EjrVWGi51)woRi8oB(EwPtQzyGVcouz8tBZset59sMmdZJMMcVZMVNv(zs0Uf)G8qvIykVxYKQd)EgMvmClVHKa5nWxb)T3LL86FlNbtDy03sKK4DYeH3c5nqEWzCX6uCLDjz5GMK3LdAsKiEM3x3mmpPCqtIKYhNIFZsr(zs0Uf)G8qvMVNvXruy(cj8wiVbYdoJlwNIXFt0krmL3lrrf6WOVvcVfYBG8GZ4I1PyzV4ITNvJrttlMwlgXqvhnZ4OP4jZWCAAPNvdmIP8EjtEbm1HrFlrsI3jt0j1mmWxbhQm(PT5k7sYVzPiDsndd8vWHkJFABwMVNvXrG3zZ3Zk)o6Zzmr9cju1rZmzs10uf6gXOoyznQPClUxs0lmisE9VLZJcM6WOVLijX7KjscNQMZCLDj53SuKoPMHb(k4qLXpTnlnRv8BwkYptI2T4hKhQsZ600spRgyet59sMu9fWuhg9TejjENmrhtzIYmcFfmeDpeWuhg9TejjENmXYbnjCg7gXOoy8NDQk7sYVzPi)mjA3IFqEOkZ3ZMMw6z1aJykVxYKxatDy03sKK4DYedvgBU)ZCZ4YHGCLDj53SuKigoMLjeC5qqwAwNM(nlfjIHJzzcbxoeKXWZCdgjjHdhBs1Hstl9SAGrmL3lzYlGPom6Bjss8ozIFMeTBXpipuRSljd3YBijqEd8vWF7DzjV(3Y500WT8gYBz8thQ4qLX1oCmjV(3Yzf)MLI8ZKODl(b5HQeXuEVKjZWCA63SuKFMeTBXpipuL57zveENnFpR0j1mmWxbhQm(PTzjIP8Ejdu9L00spRgyet59sMu9L3ZWmyQdJ(wIKeVtM43rFoJjQxuzxs6gXOoyz2xiJVcoZEOkr(o2avv8BwkYSVqgFfCM9qvIykVxYKzygm1HrFlrsI3jt8BVlJVcouzmVmLHv2LKFZsr6KAgg4RGdvg)02SeXuEVKbQo07zyonT0ZQbgXuEVKjvh69mmdM6WOVLijX7KjowBTy4rr5Bgm1HrFlrsI3jt87Z4RGdudhJuzxs(nlf5Njr7w8dYdvz(E200spRgyet59sM8cyQdJ(wIKeVtMiuTPCg5yI6fGPom6Bjss8ozI5gX4p7Kam1HrFlrsI3jt87OpNXe1lQSljd3YBiVLXpDOIdvgx7WXK86FlNveQ6OzMGlihg9TUDGQYxstHQoAMj4cYHrFRBhOQSIstH3zZ3ZkDsndd8vWHkJFABwIykVxYKAoKuEVYVzPiliEnYqz2e5rF7RmdZk6gXOoyznQPClUxs0lmisE9VLZPPLEwnWiMY7Lm51atDy03sKK4DYeRnrDXWENXFRtIk7sYVzPi)mjA3IFqEOkZ3ZMMw6z1aJykVxYKkcm1HrFlrsI3jt87iKpZGPom6Bjss8ozIW7JCmr9Ik7sYrkh0K8kWJeVlh0Kir8mVVUrG3zZ3ZkhRTwm8OO8nlrmL3l5vQo6aom6BLJ1wlgEuu(MLWJePPW7S57zLJ1wlgEuu(MLiMY7Lmq13ZWSIW7S57zLFMeTBXpipuLiMY7LGNnzczGYbnjYOPyCCykFCPPFZsrsXuhYq8vWwtyNXze7uePz9OkcVZMVNvowBTy4rr5BwIykVxYavttl9SAGrmL3lzsfatDy03sKK4DYe)o6Zzmr9Ik7sYAoKuEVYVzPiliEnYqz2e5rF7RmdZdumTwmIHQoAMXrtX6qhAn]] )
    end


end
