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

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
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
        },


        -- Legendaries
        nessingwarys_trapping_apparatus = {
            id = 336744,
            duration = 5,
            max_stack = 1
        }
    } )

    spec:RegisterStateExpr( "barbed_shot_grace_period", function ()
        return ( settings.barbed_shot_grace_period or 0 ) * gcd.max
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if amt < 0 and resource == "focus" and buff.nessingwarys_trapping_apparatus.up then
            amt = amt * 2
        end

        return amt, resource
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

                if level > 33 then
                    setCooldown( "bestial_wrath", cooldown.bestial_wrath.remains - 12 )
                end

                applyDebuff( "target", "barbed_shot_dot" )

                if legendary.qapla_eredun_war_order.enabled then
                    reduceCooldown( "kill_command", 5 )
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

            spend = function () return buff.flamewakers_cobra_sting.up and 0 or 30 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132176,

            usable = function () return pet.alive, "requires a living pet" end,

            handler = function ()
                removeBuff( "flamewakers_cobra_sting" )

                if conduit.ferocious_appetite.enabled and stat.crit >= 100 then
                    reduceCooldown( "aspect_of_the_wild", conduit.ferocious_appetite.mod / 10 )
                end
            end,

            auras = {
                flamewakers_cobra_sting = {
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
                applyBuff( "wild_spirits" )
            end,

            auras = {
                wild_mark = {
                    id = 328275,
                    duration = function () return conduit.spirit_attunement.enabled and 18 or 15 end,
                    max_stack = 1
                },
                wild_spirits = {
                    duration = function () return conduit.spirit_attunement.enabled and 18 or 15 end,
                    max_stack = 1,
                    generate = function( t )
                        local cast = action.wild_spirits.lastCast or 0
                        local up = cast + t.duration > state.query_time
        
                        t.name = t.name or class.abilities.wild_spirits.name
                        t.count = up and 1 or 0
                        t.expires = up and cast + t.duration or 0
                        t.applied = up and cast or 0
                        t.caster = "player"
                    end,
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


    spec:RegisterPack( "Beast Mastery", 20201125, [[dWKNtbqiuuEePiytss(KsPrjj6uscRIsu8kq0SOK6wucKDrXViOgMsrhts1YifEgPOMgLGUgiyBssLVrkIghiuohLOADkfmpuK7rkTpkHoOKuLfsqEOsHMiiKYfPeL(iiegjiKQtccrRuszMss5Mucu2ji1pPeWqPeOAPKIqpfutff6RGqYyrr1zLKQAVi9xsgmrhwyXO0Jr1KvYLH2SeFwugnL60kwniu9AqsZwKBtQ2Tu)wLHlQooPiTCv9CetNQRtOTJc(obgpLiNNsY6bjMVs1(bMwNYifEfosHwJn1yZ611acgn20cHGgqGc7wLJu48Gd1idPWDOJuyHWG4aPfSG44BffopSkDXIYifMCIphPW2UNt2GWcNnUTiRHF6ctgDXu4Z18pkUWKrNlmfMvCsoeztzPWRWrk0ASPgBwVUgqWOXMwie2ecu4q0TVNcdp6BKcBpRf2uwk8cjCkSMaqkegehiTGfehFRasi6ITJpOMMaqc9XaQZIpqQHMTgi1ytn2KcNgItOmsHxyjetoLrk01PmsHdUpxtH5Ny74Ri2NtHXoyt4Ike1PqRbLrkm2bBcxuHOWb3NRPW8tSD8ve7ZPW8FC8NGc)InwUpdnem3wekev(F8uOh(CTb7GnHlGCFhijNyID6LPhRcIYVlru53qUgi33bYkbs(1lXXnpYa(KiPUIQCVl2Ob7GnHlGSkGKza5l2y5(m0qWCBrOqu5)XtHE4Z1gSd2eUaYkOWPPrfFrH18MuNcTMPmsHdUpxtHfjOACuNqHXoyt4Ike1PqBHugPWb3NRPW(hTMkoPbktNPi2NtHXoyt4Ike1PqdbkJuySd2eUOcrH5)44pbfo)rguz8LPUji5i3vxr52OsWKwa5(oqwMmBx9OEmnbizci1ytkCW95AkSibvJJ6eQtHU6OmsHXoyt4Ikefo4(CnfoGcXo(GOkx7QROYpb4tH5)44pbfMFxADcAtqYrURUIYTrLGjTmpQhttuzIiHaKmbK1HaqwfqwMmBx9OEmnbiTiqwFtkCh6ifoGcXo(GOkx7QROYpb4tDk0AskJuySd2eUOcrHdUpxtHdIndrJe1hq5Ef)(irH5)44pbfEHSILI5dOCVIFFKulKvSumI5azvazLajZasutfN8CCzcOqSJpiQY1U6kQ8ta(a5(oqYVlTobTjGcXo(GOkx7QROYpb4BEupMMaKweiHyvhqUVdKiHGnhnSP7wQROCBuHnQBLrpG43dKvaKvbKvcK5pYGkJVm1nbjh5U6kk3gvcM0ci33bsMbKOMko554YWTINo)VE4k2uqCGSkGKvSumbjh5U6kk3gvcM0Y8OEmnbiTiqA5azfazvazLajZasKqWMJg(1lSj4sLMcwUNJg9aIFpqUVdKSILIjtm(1eT6kQak4FUTrmhiRaiRciRei94Zq3yJrYTn5Chizci1meaY9DGKzajsiyZrd)6f2eCPstbl3ZrJEaXVhi33bsMbKEKW2nqDsj8vtt8P5Ub7GnHlGScGCFhiReixiRyPy(ak3R43hj1czflfZ6e0a5(oqwMmBx9OEmnbizci1O6aYkaYQaYYKz7Qh1JPjaPfbYkbsnSqG0YaKvcK87sRtqB4wXtN)xpCfBkiU5r9yAcqcjqAHajtazzYSD1J6X0eGScGSckCh6ifoi2mensuFaL7v87Je1PqdXOmsHXoyt4Ikefo4(CnfMBfpD(F9WvSPG4uy(po(tqHzflfdls8jskbF42M1jObY9DGSmz2U6r9yAcqYeqcbkmwki3vDOJuyUv805)1dxXMcItDk0woLrkm2bBcxuHOWb3NRPW8iLub3NRvPH4u40qCvh6ifMViuNcD9nPmsHXoyt4IkefM)JJ)eu4G7ddOcBuFqcqYeqQbfo4(CnfMhPKk4(CTkneNcNgIR6qhPWeN6uORxNYifg7GnHlQquy(po(tqHdUpmGkSr9bjaPfbY6u4G7Z1uyEKsQG7Z1Q0qCkCAiUQdDKcZtyWasDQtHZFKF6SHtzKcDDkJu4G7Z1uyIOU(1QC0PWyhSjCrfI6uO1GYifg7GnHlQqu4o0rkCafID8brvU2vxrLFcWNchCFUMchqHyhFquLRD1vu5Na8PofAntzKchCFUMcl4(0IbCA1JKRJMJuySd2eUOcrDk0wiLrkm2bBcxuHOW5pYdIR8rhPW1nqGchCFUMc7XR8pYPW8FC8NGc)InwUpdnKtmvUpdvOol(ed2bBcxa5(oq(InwUpdnnsitNjiERik)J88PZurEE8HlsmyhSjCrDk0qGYifg7GnHlQqu48h5bXv(OJu46giqHdUpxtHzrIprsj4d3McZ)XXFckmZaspsy7gchBxDffB6ULb7GnHlGSkGKza5l2y5(m0qoXu5(muH6S4tmyhSjCrDk0vhLrkCW95AkCMy8RjA1vubuW)CBkm2bBcxuHOofAnjLrkCW95AkSoQFVvQROsI8zPwpg6ekm2bBcxuHOofAigLrkm2bBcxuHOWb3NRPWCR4PZ)RhUInfeNcZ)XXFckmZaYpMLczaB3mndIPg)GnHg0sdXjazvazLaP)tdv0n1n2brXVlTobnqcjq6)0qfDJgg7GO43LwNGgizci1ai33bsutfN8CCzyi(jytOAAhBY4wPYMSGHl5QJWNuk8PZupgC)EGSckmwki3vDOJuyUv805)1dxXMcItDk0woLrkm2bBcxuHOW8FC8NGcZmG8JzPqgW2ntZGyQXpytObT0qCcfo4(CnfUCCrcUubuWFCuXIHo1PqxFtkJuySd2eUOcrHZFKhex5JosHRB0mfo4(Cnfoi5i3vxr52OsWKwuy(po(tqHzgqgqb)Xrt(p6rsnnXNM7ed2bBcxazvajZasKqWMJgKqWMJQROCBuvoUiz6m18dXOhq87bYQaYkbsutfN8CCzcOqSJpiQY1U6kQ8ta(a5(oqYmGe1uXjphxgUv805)1dxXMcIdKvqDk01RtzKcJDWMWfvikC(J8G4kF0rkCDdeOWb3NRPWSiXNiPe8HBtH5)44pbfoGc(JJM8F0JKAAIpn3jgSd2eUaYQasMbKiHGnhniHGnhvxr52OQCCrY0zQ5hIrpG43dKvbKvcKOMko554YeqHyhFquLRD1vu5Na8bY9DGKzajQPItEoUmCR4PZ)RhUInfehiRG6uNcZxekJuORtzKcJDWMWfvikm)hh)jOW87sRtqByrIprsj4d328OEmnbiTiqQ5nPWb3NRPWrZrI)rsXJuI6uO1GYifg7GnHlQquy(po(tqH53LwNG2WIeFIKsWhUT5r9yAcqArGuZBsHdUpxtHlZJSP7wuNcTMPmsHXoyt4IkefM)JJ)eu4kbswXsXiyslfjF(XjgXCGCFhizgqYpgWoA30tMTRkbcKvbKSILIji5i3vxr52OsWKwgXCGSkGKvSumSiXNiPe8HBBeZbYkaYQaYkbYYKz7Qh1JPjaPfbs(DP1jOnS4tWhQtNzwIF4Z1ajKa5s8dFUgi33bYkbsp(m0n2yKCBto3bsMasndbGCFhizgq6rcB3a1jLWxnnXNM7gSd2eUaYkaYkaY9DGSmz2U6r9yAcqYeqwxZu4G7Z1uyw8j4d1PZOofAlKYifg7GnHlQquy(po(tqHReizflfJGjTuK85hNyeZbY9DGKzaj)ya7ODtpz2UQeiqwfqYkwkMGKJCxDfLBJkbtAzeZbYQaswXsXWIeFIKsWhUTrmhiRaiRciReiltMTREupMMaKwei53LwNG2WMUBPkIVvML4h(CnqcjqUe)WNRbY9DGSsG0JpdDJngj32KZDGKjGuZqai33bsMbKEKW2nqDsj8vtt8P5Ub7GnHlGScGScGCFhiltMTREupMMaKmbK1RokCW95AkmB6ULQi(wrDk0qGYifo4(Cnfonz2orbXfxz6y7uySd2eUOcrDk0vhLrkm2bBcxuHOW8FC8NGcZkwkMGKJCxDfLBJkbtAzeZbY9DGSmz2U6r9yAcqYeqQr1rHdUpxtHZpFUM6uO1KugPWyhSjCrfIcZ)XXFckCLaz(JmOY4ltDtqYrURUIYTrLGjTaY9DGKFxADcAtqYrURUIYTrLGjTmpQhttasMaYm(ci33bYYKz7Qh1JPjajtaPgBcKvaK77ajZasKqWMJgggYCT6kQC8li3NRn6tFpfo4(CnfwW9Pfd40QhjxhnhPofAigLrkm2bBcxuHOW8FC8NGcZVlTobTji5i3vxr52OsWKwMh1JPjajtaz9nbY9DGSmz2U6r9yAcqArGm4(CTIFxADcAGesGCj(HpxdK77azzYSD1J6X0eGKjGuZBsHdUpxtHZeJFnrRUIkGc(NBtDk0woLrkCW95Ak8p55junTIKhCKcJDWMWfviQtHU(MugPWb3NRPW6O(9wPUIkjYNLA9yOtOWyhSjCrfI6uORxNYifg7GnHlQquy(po(tqH94Zq3yJrYTn5ChiTiqcX2ei33bsp(m0n2yKCBto3bsM0cKASjqUVdKE8zOB8rhv(PY5UsJnbslcKAEtkCW95Ak8Jr(0zQsk0rc1PofM4ugPqxNYifo4(Cnfoi5i3vxr52OsWKwuySd2eUOcrDk0AqzKcJDWMWfvikm)hh)jOWSILIP8ydfRmI5azvajRyPykp2qXkZJ6X0eGKjTazgFrHdUpxtHzJNfxkI95uNcTMPmsHXoyt4IkefM)JJ)eu4xSXY9zOHCIPY9zOc1zXNyWoyt4ciRci94v(h5Mh1JPjajtazgFbKvbK87sRtqBkP4rZJ6X0eGKjGmJVOWb3NRPWE8k)JCQtH2cPmsHXoyt4IkefM)JJ)euypEL)rUrmhiRciFXgl3NHgYjMk3NHkuNfFIb7GnHlkCW95AkCjfpsDk0qGYifo4(CnfMnD3IyJlkm2bBcxuHOof6QJYifo4(CnfwWKwks(8JtOWyhSjCrfI6uO1KugPWb3NRPWLuyfUue7ZPWyhSjCrfI6uOHyugPWyhSjCrfIcZ)XXFckmRyPykPWk8jk94HQ5r9yAcqYeqcbGCFhi94Zq3yJrYTn5ChizslqQXMu4G7Z1uyOoPKIyFo1PqB5ugPWyhSjCrfIcZ)XXFckCLaj)U06e0gbtAPi5ZpoX8OEmnbiTiqwetj1JC74ZqLp6iqUVdKmdi5hdyhTB6jZ2vLabYkaYQaYkbs(DP1jOnSiXNiPe8HBBEupMMaKmbK11aiTmaj3o(mKOkFW956ibKqcKz8fqwfq6rcB3q4y7QROyt3TmyhSjCbK77azrmLupYTJpdv(OJajtazgFbKvbK87sRtqByrIprsj4d328OEmnbiRai33bsp(m0n(OJk)uRbbsMaslNchCFUMcZgplUue7ZPof66BszKcJDWMWfvikm)hh)jOWLJlsasibsEqC1JzydKmbKLJlsm6HLOWb3NRPWlmCBf3oG6h6uNcD96ugPWyhSjCrfIcZ)XXFckmRyPycsoYD1vuUnQemPLrmhi33bYYKz7Qh1JPjajtazDiqHdUpxtHjEONJlK6uORRbLrkm2bBcxuHOW8FC8NGcxoUibiHeilhxKyEmdBG0YaKz8fqYeqwoUiXOhwciRcizflfdls8jskbF42M1jObYQaYkbsMbKRZn8R5y7F44svsHoQyf)28OEmnbiRcizgqgCFU2WVMJT)HJlvjf6OzAvjnz2oqwbqUVdKfXus9i3o(mu5JocKmbKz8fqUVdKLjZ2vpQhttasMasiqHdUpxtH5xZX2)WXLQKcDK6uORRzkJu4G7Z1u4qPl(l8vxrX)taHcJDWMWfviQtHUUfszKcJDWMWfvikm)hh)jOWSILIHfj(ejLGpCBJyoqUVdKLjZ2vpQhttasMaY6BsHdUpxtHFKCD4tNPI)pbuNcDDiqzKcJDWMWfvikm)hh)jOW87sRtqBemPLIKp)4eZJ6X0eG0IazDiaK77ajZas(Xa2r7MEYSDvjqGCFhiltMTREupMMaKmbK1Hafo4(CnfMfj(ejLGpCBQtHUE1rzKchCFUMcZTh9a)qrSpNcJDWMWfviQtHUUMKYifg7GnHlQquy(po(tqHzflfdls8jskbF42M1jObY9DGSmz2U6r9yAcqYeqcbkCW95AkC54IeCPcOG)4OIfdDQtHUoeJYifg7GnHlQquy(po(tqHzflfZJCOMqcrvUNJgXCGCFhizflfZJCOMqcrvUNJk(j2o(gIhCOcKmbK13ei33bYYKz7Qh1JPjajtajeOWb3NRPWUnQeB2tSxQY9CK6uORB5ugPWyhSjCrfIcZ)XXFckmRyPyyrIprsj4d32iMdK77azzYSD1J6X0eGKjGS(Mu4G7Z1u4hjxh(0zQ4)ta1PqRXMugPWyhSjCrfIcZ)XXFckm)U06e0gbtAPi5ZpoX8OEmnbiTiqwhca5(oqYmGKFmGD0UPNmBxvcei33bYYKz7Qh1JPjajtazDiqHdUpxtHzrIprsj4d3M6uO1OoLrkCW95Akm3E0d8dfX(Ckm2bBcxuHOofAn0GYifg7GnHlQquy(po(tqHzflftqYrURUIYTrLGjTmpQhttaslcK13eiHeiZ4lGCFhiltMTREupMMaKmbK13eiHeiZ4lkCW95AkmB6UL6kk3gvyJ6wrDk0AOzkJu4G7Z1uyOoPKIF66rVOWyhSjCrfI6uO1WcPmsHXoyt4IkefM)JJ)euywXsXWIeFIKsWhUTzDcAGCFhiltMTREupMMaKmbKqGchCFUMcZgzQRO8F4qLqDk0AabkJu4G7Z1u418OIfdItHXoyt4Ike1PqRr1rzKcJDWMWfvikm)hh)jOWvcKLJlsasliGKFehiHeilhxKyEmdBG0YaKvcK87sRtqBG6Ksk(PRh9Y8OEmnbiTGaY6azfaPfbYG7Z1gOoPKIF66rVm8J4a5(oqYVlTobTbQtkP4NUE0lZJ6X0eG0IazDGesGmJVaYkaY9DGSsGKvSumSiXNiPe8HBBeZbY9DGKvSumnsitNjiERik)J88PZurEE8HlsmI5azfazvajZaYxSXY9zOrtJ8uOWhxITsq8Q7x4BWoyt4ci33bYYKz7Qh1JPjajtaPMPWb3NRPW8J9dfX(CQtHwdnjLrkm2bBcxuHOW8FC8NGcZkwkgbtAPi5ZpoXiMtHdUpxtHzJNfxkI95uNcTgqmkJuySd2eUOcrH5)44pbfMvSumSiXNiPe8HBBwNGgi33bYYKz7Qh1JPjajtajeOWb3NRPWXZJgv5IjcsDk0Ay5ugPWyhSjCrfIcZ)XXFck8l2y5(m0qoXu5(muH6S4tmyhSjCbK77a5l2y5(m00iHmDMG4TIO8pYZNotf55XhUiXGDWMWffo4(Cnf2Jx5FKtDk0AEtkJuySd2eUOcrH5)44pbf(fBSCFgAAKqMotq8wru(h55tNPI884dxKyWoyt4IchCFUMcxEeHY0zk)JCQtDkmpHbdiLrk01PmsHdUpxtHdsoYD1vuUnQemPffg7GnHlQquNcTgugPWyhSjCrfIchCFUMcZgplUue7ZPW8FC8NGcZkwkMYJnuSYiMdKvbKSILIP8ydfRmpQhttasM0cKz8ffMBfpHkp(m0juORtDk0AMYifg7GnHlQquy(po(tqHZ4lG0ccizflfdlgexXtyWaAEupMMaKwei30ObeOWb3NRPW6IjFi2NtDk0wiLrkm2bBcxuHOW8FC8NGc)InwUpdnKtmvUpdvOol(ed2bBcxazvaPhVY)i38OEmnbizciZ4lGSkGKFxADcAtjfpAEupMMaKmbKz8ffo4(Cnf2Jx5FKtDk0qGYifg7GnHlQquy(po(tqH94v(h5gXCGSkG8fBSCFgAiNyQCFgQqDw8jgSd2eUOWb3NRPWLu8i1PqxDugPWyhSjCrfIcZ)XXFckC54IeGesGKhex9yg2ajtaz54IeJEyjkCW95Ak8cd3wXTdO(Ho1PqRjPmsHdUpxtHfmPLIKp)4ekm2bBcxuHOofAigLrkm2bBcxuHOWb3NRPWSXZIlfX(Ckm)hh)jOWfXus9i3o(mu5JocKmbKz8fqwfqYVlTobTHfj(ejLGpCBZJ6X0eGCFhi53LwNG2WIeFIKsWhUT5r9yAcqYeqwxdGesGmJVaYQaspsy7gchBxDffB6ULb7GnHlkm3kEcvE8zOtOqxN6uOTCkJu4G7Z1uywK4tKuc(WTPWyhSjCrfI6uORVjLrkCW95Ak8JKRdF6mv8)jGcJDWMWfviQtHUEDkJuySd2eUOcrH5)44pbfMvSumbjh5U6kk3gvcM0YiMdK77azzYSD1J6X0eGKjGSoeOWb3NRPWep0ZXfsDk011GYifo4(CnfUKcRWLIyFofg7GnHlQquNcDDntzKchCFUMcd1jLue7ZPWyhSjCrfI6uORBHugPWb3NRPWC7rpWpue7ZPWyhSjCrfI6uORdbkJu4G7Z1uy20DlInUOWyhSjCrfI6uORxDugPWb3NRPWHsx8x4RUII)Nacfg7GnHlQquNcDDnjLrkm2bBcxuHOW8FC8NGcZkwkMYJnuSY8OEmnbiTiqIwc5IoQ8rhPWb3NRPWSX)rgsDk01HyugPWyhSjCrfIcZ)XXFckC54IeG0Iaj)ioqcjqgCFU2OlM8HyFUHFeNchCFUMcd1jLu8txp6f1Pqx3YPmsHXoyt4IkefM)JJ)euywXsXWIeFIKsWhUTzDcAGCFhiltMTREupMMaKmbKqGchCFUMcZgzQRO8F4qLqDk0ASjLrkCW95Ak8AEuXIbXPWyhSjCrfI6uO1OoLrkm2bBcxuHOWb3NRPWSXZIlfX(Ckm)hh)jOWE8zOB8rhv(PwdcKmbKwofMBfpHkp(m0juORtDk0AObLrkm2bBcxuHOW8FC8NGcxoUiX4JoQ8tPhwcizciZ4lG0YaKAqHdUpxtH5h7hkI95uNcTgAMYifg7GnHlQquy(po(tqHFXgl3NHgYjMk3NHkuNfFIb7GnHlGCFhiFXgl3NHMgjKPZeeVveL)rE(0zQipp(WfjgSd2eUOWb3NRPWE8k)JCQtHwdlKYifg7GnHlQquy(po(tqHFXgl3NHMgjKPZeeVveL)rE(0zQipp(WfjgSd2eUOWb3NRPWLhrOmDMY)iN6uO1acugPWb3NRPWLJlsWLkGc(JJkwm0PWyhSjCrfI6uO1O6OmsHdUpxtHZf)Py10zk2uqCkm2bBcxuHOofAn0KugPWb3NRPW8R5y7F44svsHosHXoyt4Ike1PqRbeJYifo4(CnfMnD3sDfLBJkSrDROWyhSjCrfI6uO1WYPmsHXoyt4IkefM)JJ)euywXsX8ihQjKquL75Ormhi33bswXsX8ihQjKquL75OIFITJVH4bhQajtaz9nPWb3NRPWUnQeB2tSxQY9CK6uN6uygWNmxtHwJn1yZ611qZuybX3tNrOWquvpnrOHiHgIydajqYOncKJE(9oqwUhi3UWsiM8Ta5JAQ484cijNocKHOF6HJlGKBhDgsmGAvBAei1yda5gVMb8DCbKBFXgl3NHgMVfi9di3(InwUpdnm3GDWMW1wGSY6wQcdOw1Mgbsn2aqUXRzaFhxa52xSXY9zOH5Bbs)aYTVyJL7ZqdZnyhSjCTfiRSULQWaQvTPrGuJnaKB8AgW3XfqULF9sCCdZ3cK(bKB5xVeh3WCd2bBcxBbYkRBPkmGAvBAei1KBai341mGVJlGCRhjSDdZ3cK(bKB9iHTByUb7GnHRTazL1TufgqTQnncKAYnaKB8AgW3XfqU1)PHk6gMB43LwNGElq6hqULFxADcAdZ3cKvw3svya1a1GOQEAIqdrcneXgasGKrBeih987DGSCpqUn)r(PZg(wG8rnvCECbKKthbYq0p9WXfqYTJodjgqTQnncKw4gaYnEnd474ci3(InwUpdnmFlq6hqU9fBSCFgAyUb7GnHRTaz4aPL1cunGSY6wQcdOw1MgbslCda5gVMb8DCbKBFXgl3NHgMVfi9di3(InwUpdnm3GDWMW1wGSY6wQcdOw1MgbsiSbGCJxZa(oUaYTEKW2nmFlq6hqU1Je2UH5gSd2eU2cKvw3svya1Q20iqcHnaKB8AgW3XfqU9fBSCFgAy(wG0pGC7l2y5(m0WCd2bBcxBbYWbslRfOAazL1TufgqnqniQQNMi0qKqdrSbGeiz0gbYrp)Ehil3dKB5lYwG8rnvCECbKKthbYq0p9WXfqYTJodjgqTQnncKAEda5gVMb8DCbKB9iHTBy(wG0pGCRhjSDdZnyhSjCTfiRSULQWaQvTPrG0c3aqUXRzaFhxa5wpsy7gMVfi9di36rcB3WCd2bBcxBbYkRBPkmGAGAquvpnrOHiHgIydajqYOncKJE(9oqwUhi3s8Ta5JAQ484cijNocKHOF6HJlGKBhDgsmGAvBAei1yda5gVMb8DCbKBZr3WCt13ymBbs)aYTvFJXSfiRudlvHbuRAtJaPM3aqUXRzaFhxa52xSXY9zOH5Bbs)aYTVyJL7ZqdZnyhSjCTfiRSULQWaQvTPrG0c3aqUXRzaFhxa52xSXY9zOH5Bbs)aYTVyJL7ZqdZnyhSjCTfidhiTSwGQbKvw3svya1Q20iqA5Bai341mGVJlGCRhjSDdZ3cK(bKB9iHTByUb7GnHRTazL1TufgqTQnncKAuDBai341mGVJlGC7l2y5(m0W8TaPFa52xSXY9zOH5gSd2eU2cKvw3svya1Q20iqQHLVbGCJxZa(oUaYTVyJL7ZqdZ3cK(bKBFXgl3NHgMBWoyt4AlqgoqAzTavdiRSULQWaQvTPrGudlFda5gVMb8DCbKBFXgl3NHgMVfi9di3(InwUpdnm3GDWMW1wGSY6wQcdOw1MgbsnV5gaYnEnd474ci3(InwUpdnmFlq6hqU9fBSCFgAyUb7GnHRTaz4aPL1cunGSY6wQcdOgOgev1tteAisOHi2aqcKmAJa5ONFVdKL7bYT8egmGBbYh1uX5XfqsoDeidr)0dhxaj3o6mKya1Q20iqQXgaYnEnd474ci3MJUH5MQVXy2cK(bKBR(gJzlqwPgwQcdOw1MgbsnVbGCJxZa(oUaYT5OByUP6BmMTaPFa52QVXy2cKvw3svya1Q20iqAHBai341mGVJlGC7l2y5(m0W8TaPFa52xSXY9zOH5gSd2eU2cKvw3svya1Q20iqcHnaKB8AgW3XfqU9fBSCFgAy(wG0pGC7l2y5(m0WCd2bBcxBbYWbslRfOAazL1TufgqTQnncKqSnaKB8AgW3XfqU1Je2UH5Bbs)aYTEKW2nm3GDWMW1wGmCG0YAbQgqwzDlvHbuRAtJazDn5gaYnEnd474ci3MJUH5MQVXy2cK(bKBR(gJzlqwzDlvHbuRAtJaPgAEda5gVMb8DCbKBFXgl3NHgMVfi9di3(InwUpdnm3GDWMW1wGmCG0YAbQgqwzDlvHbuRAtJaPgAEda5gVMb8DCbKBFXgl3NHgMVfi9di3(InwUpdnm3GDWMW1wGSY6wQcdOw1MgbsnSWnaKB8AgW3XfqU9fBSCFgAy(wG0pGC7l2y5(m0WCd2bBcxBbYWbslRfOAazL1Tufgqnqnis987DCbKqaidUpxdKPH4edOgfo)VYKqkSMaqkegehiTGfehFRasi6ITJpOMMaqc9XaQZIpqQHMTgi1ytn2eudul4(CnXK)i)0zdhsTcte11VwLJoOwW95AIj)r(PZgoKAfwKGQXrDR7qh1gqHyhFquLRD1vu5Na8b1cUpxtm5pYpD2WHuRWcUpTyaNw9i56O5iOwW95AIj)r(PZgoKAf2Jx5FKBD(J8G4kF0rT1nqW6PO9fBSCFgAiNyQCFgQqDw8j77VyJL7ZqtJeY0zcI3kIY)ipF6mvKNhF4IeqTG7Z1et(J8tNnCi1kmls8jskbF42wN)ipiUYhDuBDdeSEkAzMhjSDdHJTRUIInD3QkM9InwUpdnKtmvUpdvOol(eqTG7Z1et(J8tNnCi1kCMy8RjA1vubuW)CBqTG7Z1et(J8tNnCi1kSoQFVvQROsI8zPwpg6eqTG7Z1et(J8tNnCi1kSibvJJ6wJLcYDvh6OwUv805)1dxXMcIB9u0YSpMLczaB3mndIPg)GnHg0sdXjvvP)tdv0n1n2brXVlTobnK(pnur3OHXoik(DP1jOzsJ9DutfN8CCzyi(jytOAAhBY4wPYMSGHl5QJWNuk8PZupgC)(ka1cUpxtm5pYpD2WHuRWLJlsWLkGc(JJkwm0TEkAz2hZsHmGTBMMbXuJFWMqdAPH4eqnnbGS6TG4IeNaKUncKlXp85AGm6fqYVlTobnqEfGS6rYrUdKxbiDBeiHOM0ciJEbKwW)rpsajezt8P5obizTciDBeixIF4Z1a5vaYObsX2oioUasiIncrdifyJnq62OvBFeifj4ciZFKF6SHBasHqEisqGS6rYrUdKxbiDBeiHOM0ciFCjYrcqcrSriAajRvaPgBUPoXAG0ThcqoeGSUrZajb5xVigqTG7Z1et(J8tNnCi1kCqYrURUIYTrLGjTSo)rEqCLp6O26gnB9u0YSak4poAY)rpsQPj(0CNyWoyt4QkMHec2C0Gec2CuDfLBJQYXfjtNPMFig9aIFFvvIAQ4KNJltafID8brvU2vxrLFcWFFNzOMko554YWTINo)VE4k2uq8ka10eaYQ3cIlsCcq62iqUe)WNRbYOxaj)U06e0a5vasHqIprciHO(WTbYOxaje9akiqEfGutmYqGK1kG0TrGCj(HpxdKxbiJgifB7G44ciHi2ienGuGn2aPBJwT9rGuKGlGm)r(PZgUbul4(CnXK)i)0zdhsTcZIeFIKsWhUT15pYdIR8rh1w3abRNI2ak4poAY)rpsQPj(0CNyWoyt4QkMHec2C0Gec2CuDfLBJQYXfjtNPMFig9aIFFvvIAQ4KNJltafID8brvU2vxrLFcWFFNzOMko554YWTINo)VE4k2uq8ka1a1cUpxtGuRW8tSD8ve7Zb10easgTaq0SaBaiz0EiaPGjLaYgXfqsoDeifCpuTgijtZrGKFITJVIyFoqYTroujaz5EGmasEqCJXaQfCFUMaPwH5Ny74Ri2NBDAAuXxA18MwpfTVyJL7ZqdbZTfHcrL)hpf6HpxVVtoXe70ltpwfeLFxIOYVHC9(EL8RxIJBEKb8jrsDfv5ExSXQy2l2y5(m0qWCBrOqu5)XtHE4Z1vaQfCFUMaPwHfjOACuNaQfCFUMaPwH9pAnvCsduMotrSphul4(CnbsTclsq14OoX6POn)rguz8LPUji5i3vxr52OsWKw77LjZ2vpQhttysJnb1cUpxtGuRWIeunoQBDh6O2ake74dIQCTRUIk)eGV1trl)U06e0MGKJCxDfLBJkbtAzEupMMOYercHP6qOQYKz7Qh1JPjwS(MGAb3NRjqQvyrcQgh1TUdDuBqSziAKO(ak3R43hjRNI2fYkwkMpGY9k(9rsTqwXsXiMxvLmd1uXjphxMake74dIQCTRUIk)eG)(U)tdv0nbui2Xhev5AxDfv(jaFd)U06e0Mh1JPjweIvD77iHGnhnSP7wQROCBuHnQBLrpG43xrvvM)idQm(Yu3eKCK7QROCBujysR9DMHAQ4KNJld3kE68)6HRytbXRIvSumbjh5U6kk3gvcM0Y8OEmnXIwEfvvjZqcbBoA4xVWMGlvAky5EoA0di(977SILIjtm(1eT6kQak4FUTrmVIQQ0JpdDJngj32KZDM0me23zgsiyZrd)6f2eCPstbl3ZrJEaXVFFNzEKW2nqDsj8vtt8P5Ef77vUqwXsX8buUxXVpsQfYkwkM1jO33ltMTREupMMWKgvxfvvMmBx9OEmnXIvQHfAzQKFxADcAd3kE68)6HRytbXnpQhttG0czQmz2U6r9yAsfvaQfCFUMaPwHfjOACu3ASuqUR6qh1YTINo)VE4k2uqCRNIwwXsXWIeFIKsWhUTzDc699YKz7Qh1JPjmbbqTG7Z1ei1kmpsjvW95AvAiU1DOJA5lcOwW95AcKAfMhPKk4(CTkne36o0rTe36POn4(WaQWg1hKWKgGAb3NRjqQvyEKsQG7Z1Q0qCR7qh1YtyWaA9u0gCFyavyJ6dsSyDqnqTG7Z1edFr0gnhj(hjfpsjRNIw(DP1jOnSiXNiPe8HBBEupMMyrnVjOwW95AIHViqQv4Y8iB6UL1trl)U06e0gwK4tKuc(WTnpQhttSOM3eul4(CnXWxei1kml(e8H60zwpfTvYkwkgbtAPi5ZpoXiMVVZm(Xa2r7MEYSDvjWQyflftqYrURUIYTrLGjTmI5vXkwkgwK4tKuc(WTnI5vuvLLjZ2vpQhttSi)U06e0gw8j4d1PZmlXp85AixIF4Z177v6XNHUXgJKBBY5otAgc77mZJe2UbQtkHVAAIpn3ROI99YKz7Qh1JPjmvxZGAb3NRjg(IaPwHzt3TufX3kRNI2kzflfJGjTuK85hNyeZ33zg)ya7ODtpz2UQeyvSILIji5i3vxr52OsWKwgX8Qyflfdls8jskbF42gX8kQQYYKz7Qh1JPjwKFxADcAdB6ULQi(wzwIF4Z1qUe)WNR33R0JpdDJngj32KZDM0me23zMhjSDduNucF10eFAUxrf77LjZ2vpQhttyQE1bQfCFUMy4lcKAfonz2orbXfxz6y7GAb3NRjg(IaPwHZpFU26POLvSumbjh5U6kk3gvcM0YiMVVxMmBx9OEmnHjnQoqTG7Z1edFrGuRWcUpTyaNw9i56O5O1trBL5pYGkJVm1nbjh5U6kk3gvcM0AFNFxADcAtqYrURUIYTrLGjTmpQhttykJV23ltMTREupMMWKgBwX(oZqcbBoAyyiZ1QROYXVGCFU2Op99GAb3NRjg(IaPwHZeJFnrRUIkGc(NBB9u0YVlTobTji5i3vxr52OsWKwMh1JPjmvFZ99YKz7Qh1JPjwKFxADcAixIF4Z177LjZ2vpQhttysZBcQfCFUMy4lcKAf(N88eQMwrYdocQfCFUMy4lcKAfwh1V3k1vujr(SuRhdDcOwW95AIHViqQv4hJ8PZuLuOJeRNIwp(m0n2yKCBto3TieBZ9Dp(m0n2yKCBto3zsRgBUV7XNHUXhDu5NkN7kn20IAEtqnqTG7Z1edpHbdO2GKJCxDfLBJkbtAbQfCFUMy4jmyaHuRWSXZIlfX(CR5wXtOYJpdDI26wpfT5OB0JPnSILIP8ydfRmI5vLJUrpM2WkwkMYJnuSY8OEmnHjTz8fOwW95AIHNWGbesTcRlM8HyFU1trBgFzbLJUrpM2WkwkgwmiUINWGb08OEmnXIBA0acGAb3NRjgEcdgqi1kShVY)i36PO9fBSCFgAiNyQCFgQqDw8jv5XR8pYnpQhttykJVQIFxADcAtjfpAEupMMWugFbQfCFUMy4jmyaHuRWLu8O1trRhVY)i3iMx1l2y5(m0qoXu5(muH6S4ta1cUpxtm8egmGqQv4fgUTIBhq9dDRNI2YXfjqYdIREmdBMkhxKy0dlbQfCFUMy4jmyaHuRWcM0srYNFCcOwW95AIHNWGbesTcZgplUue7ZTMBfpHkp(m0jARB9u0wetj1JC74ZqLp6itz8vv87sRtqByrIprsj4d328OEmnzFNFxADcAdls8jskbF42Mh1JPjmvxdiZ4RQ8iHTBiCSD1vuSP7wGAb3NRjgEcdgqi1kmls8jskbF42GAb3NRjgEcdgqi1k8JKRdF6mv8)jaul4(CnXWtyWacPwHjEONJl06POLvSumbjh5U6kk3gvcM0YiMVVxMmBx9OEmnHP6qaul4(CnXWtyWacPwHlPWkCPi2NdQfCFUMy4jmyaHuRWqDsjfX(CqTG7Z1edpHbdiKAfMBp6b(HIyFoOwW95AIHNWGbesTcZMUBrSXfOwW95AIHNWGbesTchkDXFHV6kk(FciGAb3NRjgEcdgqi1kmB8FKHwpfT5OB0JPnSILIP8ydfRmpQhttSiAjKl6OYhDeul4(CnXWtyWacPwHH6Ksk(PRh9Y6POTCCrIf5hXHm4(CTrxm5dX(Cd)ioOwW95AIHNWGbesTcZgzQRO8F4qLy9u0YkwkgwK4tKuc(WTnRtqVVxMmBx9OEmnHjiaQfCFUMy4jmyaHuRWR5rflgehul4(CnXWtyWacPwHzJNfxkI95wZTINqLhFg6eT1TEkA94Zq34JoQ8tTgKjlhul4(CnXWtyWacPwH5h7hkI95wpfTLJlsm(OJk)u6HLykJVSmAaQfCFUMy4jmyaHuRWE8k)JCRNI2xSXY9zOHCIPY9zOc1zXNSV)InwUpdnnsitNjiERik)J88PZurEE8Hlsa1cUpxtm8egmGqQv4YJiuMot5FKB9u0(InwUpdnnsitNjiERik)J88PZurEE8Hlsa1cUpxtm8egmGqQv4YXfj4sfqb)Xrflg6GAb3NRjgEcdgqi1kCU4pfRMotXMcIdQfCFUMy4jmyaHuRW8R5y7F44svsHocQfCFUMy4jmyaHuRWSP7wQROCBuHnQBfOwW95AIHNWGbesTc72OsSzpXEPk3ZrRNIwwXsX8ihQjKquL75OrmFFNvSumpYHAcjev5EoQ4Ny74BiEWHkt13eudul4(CnXqCTbjh5U6kk3gvcM0cul4(CnXqCi1kmB8S4srSp36POnhDJEmTHvSumLhBOyLrmVQC0n6X0gwXsXuESHIvMh1JPjmPnJVa1cUpxtmehsTc7XR8pYTEkAFXgl3NHgYjMk3NHkuNfFsvE8k)JCZJ6X0eMY4RQ43LwNG2usXJMh1JPjmLXxGAb3NRjgIdPwHlP4rRNIwpEL)rUrmVQxSXY9zOHCIPY9zOc1zXNaQfCFUMyioKAfMnD3IyJlqTG7Z1edXHuRWcM0srYNFCcOwW95AIH4qQv4skScxkI95GAb3NRjgIdPwHH6KskI95wpfTSILIPKcRWNO0JhQMh1JPjmbH9Dp(m0n2yKCBto3zsRgBcQfCFUMyioKAfMnEwCPi2NB9u0wj)U06e0gbtAPi5ZpoX8OEmnXIfXus9i3o(mu5JoUVZm(Xa2r7MEYSDvjWkQQs(DP1jOnSiXNiPe8HBBEupMMWuDnSmC74ZqIQ8b3NRJeKz8vvEKW2neo2U6kk20DR99IykPEKBhFgQ8rhzkJVQIFxADcAdls8jskbF42Mh1JPjvSV7XNHUXhDu5NAnitwoOwW95AIH4qQv4fgUTIBhq9dDRNI2YXfjqYdIREmdBMkhxKy0dlbQfCFUMyioKAfM4HEoUqRNIwwXsXeKCK7QROCBujyslJy((EzYSD1J6X0eMQdbqTG7Z1edXHuRW8R5y7F44svsHoA9u0woUibYYXfjMhZW2YKXxmvoUiXOhwQkwXsXWIeFIKsWhUTzDc6QQKzRZn8R5y7F44svsHoQyf)28OEmnPkMfCFU2WVMJT)HJlvjf6OzAvjnz2Ef77fXus9i3o(mu5JoYugFTVxMmBx9OEmnHjiaQfCFUMyioKAfou6I)cF1vu8)eqa1cUpxtmehsTc)i56WNotf)FcSEkAzflfdls8jskbF42gX899YKz7Qh1JPjmvFtqTG7Z1edXHuRWSiXNiPe8HBB9u0YVlTobTrWKwks(8JtmpQhttSyDiSVZm(Xa2r7MEYSDvjW99YKz7Qh1JPjmvhcGAb3NRjgIdPwH52JEGFOi2NdQfCFUMyioKAfUCCrcUubuWFCuXIHU1trlRyPyyrIprsj4d32Sob9(EzYSD1J6X0eMGaOwW95AIH4qQvy3gvIn7j2lv5EoA9u0YkwkMh5qnHeIQCphnI577SILI5routiHOk3Zrf)eBhFdXdouzQ(M77LjZ2vpQhttyccGAb3NRjgIdPwHFKCD4tNPI)pbwpfTSILIHfj(ejLGpCBJy((EzYSD1J6X0eMQVjOwW95AIH4qQvywK4tKuc(WTTEkA53LwNG2iyslfjF(XjMh1JPjwSoe23zg)ya7ODtpz2UQe4(EzYSD1J6X0eMQdbqTG7Z1edXHuRWC7rpWpue7Zb1cUpxtmehsTcZMUBPUIYTrf2OUvwpfTSILIji5i3vxr52OsWKwMh1JPjwS(MqMXx77LjZ2vpQhttyQ(MqMXxGAb3NRjgIdPwHH6Ksk(PRh9cul4(CnXqCi1kmBKPUIY)HdvI1trlRyPyyrIprsj4d32Sob9(EzYSD1J6X0eMGaOwW95AIH4qQv418OIfdIdQfCFUMyioKAfMFSFOi2NB9u0wz54Ieli(rCilhxKyEmdBltL87sRtqBG6Ksk(PRh9Y8OEmnXcQEfwm4(CTbQtkP4NUE0ld)i((o)U06e0gOoPKIF66rVmpQhttSyDiZ4Rk23RKvSumSiXNiPe8HBBeZ33zflftJeY0zcI3kIY)ipF6mvKNhF4IeJyEfvXSxSXY9zOrtJ8uOWhxITsq8Q7x4VVxMmBx9OEmnHjndQfCFUMyioKAfMnEwCPi2NB9u0YkwkgbtAPi5ZpoXiMdQfCFUMyioKAfoEE0OkxmrqRNIwwXsXWIeFIKsWhUTzDc699YKz7Qh1JPjmbbqTG7Z1edXHuRWE8k)JCRNI2xSXY9zOHCIPY9zOc1zXNSV)InwUpdnnsitNjiERik)J88PZurEE8Hlsa1cUpxtmehsTcxEeHY0zk)JCRNI2xSXY9zOPrcz6mbXBfr5FKNpDMkYZJpCrcfMKJCk0AabntDQtPa]] )

end
