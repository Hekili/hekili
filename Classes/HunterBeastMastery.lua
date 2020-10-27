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
        spec:RegisterPack( "Beast Mastery", 20201020.9, [[dKKfNaqibIEebI2KGYNuj1OieDkcHvjOQ8kbzweQULGQQDr0VuIgMsfhtalJq5zkvAAkHY1ujzBei9nbcgNaPCocuwNGQmpvI7PsTpcWbjGkluPQhsGWhjGQgjbQ0jjqvRKszMkHQBsaL2Pi5NcKQwkbu8ujMQi1xjqfJvGqNvGK9k1FfAWI6WuTyO8yitwsxg1MvXNvkJweNwXQfivETsWSP42q1Ub(TQgUs64eqwoONJy6KUoLSDcPVtqJxjKZlqTEbvMpLQ9J0DGoDxQUYDkX2rSDcStGDL7iyb2zXc0fn4vUlRoAbFJ7cWX5USNDIsZcSorzyWDz1d28ETt3fYBbrCxsuDLeElxUnAIfMe94ljdULX15biOF0LKbhTSlywJrf8GgRlvx5oLy7i2ob2jWUYDeSa7SBqRlULM8WUugCbrxsMALbnwxQmb1fbjnVNDIsZcSorzyW0SGRfqzi1MGKMd6r6JXqAoWUItZITJy7qTrTjiP5fNfLn0SaO5R2r2fZqusNUlv(4wgTt3Pc0P7IJ05bDb9waLHrsYRDHboMHR9(w7uI1P7IJ05bDrHoqGSgZeUbSfjjV2fg4ygU27BTtTBNUlmWXmCT33feCugoExwHSOXnuvgq6KvgPX)e1eokCmvA2UDA(mBjAeY4(ai08fAwSD6IJ05bDXIWXrzCsRDQfRt3fg4ygU277IJ05bDb5gt0r68GOziAxmdrJahN7cQsATtDvNUlmWXmCT33feCugoExCKoIYrgW4dtO5l0SyDXr68GUGCJj6iDEq0meTlMHOrGJZDHOT2Pe0oDxyGJz4AVVli4OmC8U4iDeLJmGXhMqZcGMd0fhPZd6cYnMOJ05brZq0UygIgboo3fKHDr5wBTlRqg94yU2P7ub60DXr68GUqSWXFqCL1UWahZW1EFRDkX60DHboMHR9(UGGJYWX7c0cWNhUXsYBzopCJJmogdjswGSM1vU2fhPZd6I6WOc91w7u72P7cdCmdx79DzfYiNOrDW5UeqUBxCKopOlozLrA8prnHJchtT1o1I1P7cdCmdx79DzfYiNOrDW5UeqEvxCKopOlymrh3efcDnPli4OmC8UeK0S6ggOscIbA8prmZ)vjdCmdxP5WO5GKMHwa(8WnwsElZ5HBCKXXyirYcK1SUY1wBTlOkPt3Pc0P7cdCmdx79DbbhLHJ3f0)M6leiXyIoUjke6AIeY4(ai0SaO5D3PlosNh0fhGyIcDte5gtRDkX60DHboMHR9(UGGJYWX7c6Ft9fcKymrh3efcDnrczCFaeAwa08U70fhPZd6YzGmM5)ARDQD70DHboMHR9(UGGJYWX7cM15iDYkJ04FIAchfoMQ0ALMdJMfjnFMTenczCFaeAwa0m6Ft9fcKymKWWfgWMSAbDDEanhIMRwqxNhqZ2TtZIKMvhUXQmHDJMixrknFHM39kA2UDAoiPz1nmqLlmgddJdGOdaPsg4ygUsZIGMfbnB3onFMTenczCFaeA(cnhy3U4iDEqxWyiHHlmGTw7ulwNUlmWXmCT33feCugoExWSohPtwzKg)tut4OWXuLwR0Cy0SiP5ZSLOriJ7dGqZcGMr)BQVqGeZ8FnESGblRwqxNhqZHO5Qf015b0SD70SiPz1HBSkty3OjYvKsZxO5DVIMTBNMdsAwDddu5cJXWW4ai6aqQKboMHR0SiOzrqZ2TtZNzlrJqg3haHMVqZbe0U4iDEqxWm)xJhlyWT2PUQt3fg4ygU277ccokdhVlywNJ8azq4cwATsZHrZywNJ8azq4cwczCFaeAwa08gQkX9frZ2TtZbjnJzDoYdKbHlyP1AxCKopOlMzlrjXGoR6god0w7ucANUlmWXmCT33feCugoExWSohjgt0XnrHqxtKwR0Cy0mM15iDYkJ04FIAchfoMQ0ALMdJMvhUXQmHDJMixrknFHM39kA2UDAwK0SiPz0diw4oMHLRVopi(NOfadovdxJhlyW0SD70m6belChZWslagCQgUgpwWGPzrqZHrZNzlrJqg3haHMVqZcAaA2UDA(mBjAeY4(ai08fAwmbLMfrxCKopOlRVopO1w7cr70DQaD6UWahZW1EFxqWrz44DbZ6CKhidcxWsRvAomAgZ6CKhidcxWsiJ7dGqZxUP5nuLMTBNMpwgteYOehUXrDWzA(cnVHQ0Cy0m6Ft9fcKymrh3efcDnrczCFaeA2UDAg9VP(cbsmMOJBIcHUMiHmUpacnFHMdignhIM3qvAomAwDddujbXan(NiM5)QKboMHRDXr68GUG5qmUgjjV2ANsSoDxyGJz4AVVli4OmC8UaTa85HBSK8wMZd34iJJXqIKfiRzDLR0Cy0S6WOc9vjKX9bqO5l08gQsZHrZO)n1xiqEmoKLqg3haHMVqZBOAxCKopOlQdJk0xBTtTBNUlmWXmCT33feCugoExuhgvOVkTw7IJ05bD5yCi3ANAX60DXr68GUiCm1izDGJs6cdCmdx79T2PUQt3fhPZd6YcJXejjV2fg4ygU27BTtjOD6U4iDEqxogpyUgjjV2fg4ygU27BTtfe60DHboMHR9(UGGJYWX7Y5rweAoenJCIgH8gdO5l085rwejUVOU4iDEqxQSRjruIVa0XBTtf060DXr68GUGz(Vss4AxyGJz4AVV1oLG1P7IJ05bDXjRmsJ)jQjCu4yQDHboMHR9(w7ub2Pt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQab60DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkGyD6U4iDEqxWyIoUjke6AsxyGJz4AVV1ovGD70DXr68GUazYdCDaBrhcFHDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOllmgte944oO2fg4ygU27BTtfqq70DHboMHR9(UGGJYWX7cM15iXyIoUjke6AIS(cb0SD708z2s0iKX9bqO5l08vDXr68GUG5BX)ev4GwG0ANkqqOt3fhPZd6sDGCeJDI2fg4ygU27BTtfiO1P7cdCmdx79DbbhLHJ3LZSLOriJ7dGqZxOzbRlosNh0fmhIX1ij51w7ubeSoDxCKopOlyoe6BCxyGJz4AVV1oLy70P7cdCmdx79DbbhLHJ3frsZNhzrO5WpnJEIsZHO5ZJSisiVXaAo8rZIKMr)BQVqGCHXyIOhh3bvjKX9bqO5WpnhGMfbnlaA2r68a5cJXerpoUdQs0tuA2UDAg9VP(cbYfgJjIECChuLqg3haHMfanhGMdrZBOknhgnJ(3uFHajgt0XnrHqxtKqg3hajUzXecnlaA(8ilIuhCoQFe3xenlcAomAg9VP(cbYfgJjIECChuLqg3haHMfanhGMTBNMpZwIgHmUpacnFHM3TlosNh0f0Jb9ij51wBTlid7IYD6ovGoDxyGJz4AVVlosNh0fmhIX1ij51UGGJYWX7cM15ipqgeUGLwR0Cy0mM15ipqgeUGLqg3haHMVCtZBOAxqbJmCuD4gRKovGw7uI1P7cdCmdx79DbbhLHJ3fmRZrIXorJid7IYsiJ7dGqZxO5DKIDfnhIM3q1U4iDEqxWTm6qsET1o1UD6UWahZW1EFxqWrz44DbAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP5WOz1Hrf6RsiJ7dGqZxO5nuLMdJMr)BQVqG8yCilHmUpacnFHM3q1U4iDEqxuhgvOV2ANAX60DHboMHR9(UGGJYWX7I6WOc9vP1AxCKopOlhJd5w7ux1P7cdCmdx79DbbhLHJ3LZJSi0CiAg5enc5ngqZxO5ZJSisCFrDXr68GUuzxtIOeFbOJ3ANsq70DXr68GUiCm1izDGJs6cdCmdx79T2PccD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LJLXeHmkXHBCuhCMMVqZBOknhgnJ(3uFHajgt0XnrHqxtKqg3haHMTBNMr)BQVqGeJj64MOqORjsiJ7dGqZxO5aIrZHO5nuLMdJMv3WavsqmqJ)jIz(VkzGJz4AxqbJmCuD4gRKovGw7ubToDxCKopOlozLrA8prnHJchtTlmWXmCT33ANsW60DXr68GUGXeDCtui01KUWahZW1EFRDQa70P7IJ05bDbYKh46a2Ioe(c7cdCmdx79T2PceOt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQaI1P7IJ05bD5y8G5AKK8AxyGJz4AVV1ovGD70DXr68GUSWymrsYRDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOlyM)RKeU2fg4ygU27BTtfqq70DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkqqOt3fg4ygU277ccokdhVlywNJ8azq4cwczCFaeAwa0mVigzPCuhCUlosNh0fmhc9nU1ovGGwNUlmWXmCT33feCugoExopYIqZcGMrprP5q0SJ05bsClJoKKxLONODXr68GUSWymr0JJ7GARDQacwNUlmWXmCT33feCugoExWSohjgt0XnrHqxtK1xiGMTBNMpZwIgHmUpacnFHMVQlosNh0fmFl(NOch0cKw7uITtNUlosNh0L6a5ig7eTlmWXmCT33ANsSaD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LZSLOriJ7dGqZxOzbRlOGrgoQoCJvsNkqRDkXeRt3fg4ygU277ccokdhVlNhzrK6GZr9J4(IO5l08gQsZHpAwSU4iDEqxCiYbCKK8ART2AxeLHK5bDkX2rSDcStaXKcwxe6qWa2iDrWrGtGjLGpLaF4rZ0C6eMMh81hQ085H081Ok5AAgYcK1a5kntECMMDl9XDLR0mkXbBmrsTT4dGP5RcpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYDxKiKuBuBcocCcmPe8Pe4dpAMMtNW08GV(qLMppKMVMOxtZqwGSgixPzYJZ0SBPpURCLMrjoyJjsQTfFamnhi8OzbXdeLHkxP5RxzvgeLbLukVMM1NMVoOKs510SifBrIqsTrTj4iWjWKsWNsGp8OzAoDctZd(6dvA(8qA(AKHDr5RPzilqwdKR0m5XzA2T0h3vUsZOehSXej12IpaMMdeE0SG4bIYqLR081RSkdIYGskLxtZ6tZxhusP8AAwKITiriP2w8bW0SyHhnliEGOmu5knF9kRYGOmOKs510S(081bLukVMMfzGfjcj12IpaMMdeecpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYalsesQnQnbp(6dvUsZxrZosNhqZMHOej1wxwH)zmCxeK08E2jknlW6eLHbtZcUwaLHuBcsAoOhPpgdP5a7konl2oITd1g1MGKMxCwu2qZcGMVAhj1g1MJ05be5kKrpoMRHUxsSWXFqCLvQnhPZdiYviJECmxdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2CKopGixHm6XXCn09sNSYin(NOMWrHJPk(kKrorJ6GZ3bK7sT5iDEarUcz0JJ5AO7Lymrh3efcDnr8viJCIg1bNVdiVs85ChKQByGkjigOX)eXm)xLmWXmCnSGeAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2O2CKopGe6Ej6TakdJKKxP2CKopGe6EPcDGaznMjCdylssELAZr68asO7LweookJteFo3Rqw04gQkdiDYkJ04FIAchfoMQD7NzlrJqg3ha5Iy7qT5iDEaj09sKBmrhPZdIMHOIdCC(gvjuBosNhqcDVe5gt0r68GOziQ4ahNVjQ4Z52r6ikhzaJpm5IyuBosNhqcDVe5gt0r68GOziQ4ahNVrg2fLfFo3oshr5idy8Hjcia1g1MJ05bejQscDV0biMOq3erUXi(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxEgiJz(Vk(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxIXqcdxyaBIpNBmRZr6KvgPX)e1eokCmvP1AyI8mBjAeY4(aica9VP(cbsmgsy4cdytwTGUopiu1c668a72fP6WnwLjSB0e5ksVS7v2ThKQByGkxymgggharhasLmWXmCveIWU9ZSLOriJ7dGCjWUuBosNhqKOkj09smZ)14XcgS4Z5gZ6CKozLrA8prnHJchtvATgMipZwIgHmUpaIaq)BQVqGeZ8FnESGblRwqxNheQAbDDEGD7IuD4gRYe2nAICfPx29k72ds1nmqLlmgddJdGOdaPsg4ygUkcry3(z2s0iKX9bqUeqqP2CKopGirvsO7LMzlrjXGoR6goduXNZ9kRsCFasmRZrEGmiCblTwdBLvjUpajM15ipqgeUGLqg3haraBOQe3xKD7b5kRsCFasmRZrEGmiCblTwP2CKopGirvsO7LRVopq85CJzDosmMOJBIcHUMiTwddZ6CKozLrA8prnHJchtvATgM6WnwLjSB0e5ksVS7v2TlsrIEaXc3XmSC915bX)eTayWPA4A8ybd2UD0diw4oMHLwam4unCnESGblIWoZwIgHmUpaYfbnGD7NzlrJqg3ha5IycQiO2O2CKopGirg2fLdDVeZHyCnssEvCuWidhvhUXk5oG4Z5ELvjUpajM15ipqgeUGLwRHTYQe3hGeZ6CKhidcxWsiJ7dGC5EdvP2CKopGirg2fLdDVe3YOdj5vXNZ9kRsCFasmRZrIXorJid7IYsiJ7dGCzhPyxfAdvP2CKopGirg2fLdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxdtDyuH(QeY4(aix2q1Wq)BQVqG8yCilHmUpaYLnuLAZr68aIezyxuo09YJXHS4Z5wDyuH(Q0ALAZr68aIezyxuo09Yk7AseL4laDCXNZ95rwKqiNOriVXGlNhzrK4(IO2CKopGirg2fLdDVu4yQrY6ahLqT5iDEarImSlkh6EjMdX4AKK8Q4OGrgoQoCJvYDaXNZ9XYyIqgL4WnoQdoFzdvdd9VP(cbsmMOJBIcHUMiHmUpaID7O)n1xiqIXeDCtui01ejKX9bqUeqSqBOAyQByGkjigOX)eXm)xLmWXmCLAZr68aIezyxuo09sNSYin(NOMWrHJPsT5iDEarImSlkh6Ejgt0XnrHqxtO2CKopGirg2fLdDVeYKh46a2Ioe(cP2CKopGirg2fLdDVKOo(kxzXNZnM15iDYkJ04FIAchfoMQ0A1U9ZSLOriJ7dGCjWvuBosNhqKid7IYHUxEmEWCnssELAZr68aIezyxuo09YfgJjssELAZr68aIezyxuo09suYG7m0JKKxP2CKopGirg2fLdDVeZ8FLKWvQnhPZdisKHDr5q3l9iUfSYW4FIi4lKqT5iDEarImSlkh6EjMdH(gl(CUxzvI7dqIzDoYdKbHlyjKX9bqeaVigzPCuhCMAZr68aIezyxuo09YfgJjIECChufFo3Nhzrea6jAihPZdK4wgDijVkrprP2CKopGirg2fLdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKid7IYHUxwhihXyNOuBosNhqKid7IYHUxI5qmUgjjVkokyKHJQd3yLChq85CFMTenczCFaKlcg1MJ05bejYWUOCO7Loe5aossEv85CFEKfrQdoh1pI7l6YgQg(eJAJAZr68aIKOHUxI5qmUgjjVk(CUxzvI7dqIzDoYdKbHlyP1AyRSkX9biXSoh5bYGWfSeY4(aixU3qv72pwgteYOehUXrDW5lBOAyO)n1xiqIXeDCtui01ejKX9bqSBh9VP(cbsmMOJBIcHUMiHmUpaYLaIfAdvdtDddujbXan(NiM5)QKboMHRuBosNhqKen09s1Hrf6RIpNBOfGppCJLK3YCE4ghzCmgsKSaznRRCnm1Hrf6RsiJ7dGCzdvdd9VP(cbYJXHSeY4(aix2qvQnhPZdisIg6E5X4qw85CRomQqFvATsT5iDEars0q3lfoMAKSoWrjuBosNhqKen09YfgJjssELAZr68aIKOHUxEmEWCnssELAZr68aIKOHUxwzxtIOeFbOJl(CUppYIec5enc5ngC58ilIe3xe1MJ05bejrdDVeZ8FLKWvQnhPZdisIg6EPtwzKg)tut4OWXuP2CKopGijAO7Le1Xx5kl(CUXSohPtwzKg)tut4OWXuLwR2TFMTenczCFaKlbUIAZr68aIKOHUx6rClyLHX)erWxiHAZr68aIKOHUxIXeDCtui01eQnhPZdisIg6EjKjpW1bSfDi8fsT5iDEars0q3lrjdUZqpssELAZr68aIKOHUxUWymr0JJ7Gk1MJ05bejrdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKen09Y6a5ig7eLAZr68aIKOHUxI5qmUgjjVk(CUpZwIgHmUpaYfbJAZr68aIKOHUxI5qOVXuBosNhqKen09s0Jb9ij5vXNZTippYIe(rprdDEKfrc5nge(ej6Ft9fcKlmgte944oOkHmUpas4pGieGJ05bYfgJjIECChuLONO2TJ(3uFHa5cJXerpoUdQsiJ7dGiGaH2q1Wq)BQVqGeJj64MOqORjsiJ7dGe3SycraNhzrK6GZr9J4(IeryO)n1xiqUWymr0JJ7GQeY4(aiciGD7NzlrJqg3ha5YUDHSYOoLyxTBRT2na]] )
    else
        spec:RegisterPack( "Beast Mastery", 20201020.1, [[dSeCgbqisHEKKqSjsrFIuWOuqDkfIvbiPEfGAwki3cqk7IOFjkAykqhtsAzsIEgPIMMcixdqSnjb(McqgNKGoNKqTofaZtrCprP9Pq6GscPfkk8qaPAIasKpQaQgjGe1jvaQvQintsf4MasODsk5NasGHcibTuaj5PO0ujL6RkGYyjvqNvHk2lj)fQbt4WclgOhdzYICzKnlXNvuJMcNwQvRqLETcLztPBJIDRYVvA4sQJtQqlh0Zr10P66u02jv13by8ku15jvz9KknFr1(v1QQkTvSPWjLwvoyLdwDWkhuwTI1zfuPI11RMuS1bASyMuSxWqk2mOG7VaOyWDcQNITo0ZUrsPTILVMqePynCVMpazM5C7gMGs0YKjVzmTH37HGrXZK3mOmvSGMT1hWNcuXMcNuAv5Gvoy1bRCqz1kwNvqvGOydt3yHkw2MbORyn6uIofOInrCKITI8ImOG7VaOyWDcQ3lakBEob)PvKxauaYxqc(IkhCOxu5Gvo4p9NwrEHoG0NSVys2xaKbLkwBZDUsBfBIkHP1vAR0QQsBfBG8EpflAnpNGyUX6kw6cqlLuzOCLwvQ0wXgiV3tX6W40rZ22623mMBSUILUa0sjvgkxPLovARyPlaTusLHIfbBNGDOyRHK(4zuswvg8Ac54TGDdcdOTPxKN)IspB4yiXe9XFXKxu5Gk2a59EkwtoHBNy4kxP1aP0wXsxaAPKkdfBG8EpfBOl3iGbhx2ZXBbxVaiOIfbBNGDOyr7AtlGtg8Ac54TGDdcdOTjjKyI(44ztIZFXKxufiVqZxu6zdhdjMOp(lg9fvhuXEbdPydD5gbm44YEoEl46fabvUslGO0wXsxaAPKkdfBG8EpfBWn0poIJHHUleJwyyvSiy7eSdfBIanlfjm0DHy0cdlorGMLI0S(fA(IHFHgFbPJMDDnLKHUCJagCCzphVfC9cGGVip)fODTPfWjdD5gbm44YEoEl46fabLqIj6J)IrFrfwbVip)feNthIKG2Dt4TGDdcthXONKjg3f(IrEHMVy4xudj9XZOKSQm41eYXBb7gegqBtVip)fA8fKoA211usI0dzxhUxJWG2G7VqZxaAwkYGxtihVfSBqyaTnjHet0h)fJ(Ik(fJ8cnFXWVqJVG4C6qKeTxIooLW2UqLfIijtmUl8f55Va0SuKZMbm1XH3co0LGRBinRFXiVqZxm8l8aotU0GcRBiRr(lM8cDcKxKN)cn(cIZPdrs0Ej64ucB7cvwiIKmX4UWxKN)cn(cpS05YXARLG4(4EFixsxaAP0lg5f55Vy4xKiqZsrcdDxigTWWIteOzPitlG7f55VO0ZgogsmrF8xm5fvwbVyKxO5lk9SHJHet0h)fJ(IHFrLd0laQFXWVaTRnTaojspKDD4EncdAdUlHet0h)fa)Ib6ftErPNnCmKyI(4VyKxmII9cgsXgCd9JJ4yyO7cXOfgwLR0QcuARyPlaTusLHInqEVNIfPhYUoCVgHbTb3vSiy7eSdflOzPibjU3HfdagUHmTaUxKN)IspB4yiXe9XFXKxaeflvkeYXxWqkwKEi76W9Aeg0gCx5kTgqkTvS0fGwkPYqXgiV3tXIcRfhiV3dBBURyTn3XxWqkwuIRCLwvOsBflDbOLsQmuSiy7eSdfBG8wFcthX0e)ftErLk2a59EkwuyT4a59EyBZDfRT5o(cgsXYDLR0QIvARyPlaTusLHIfbBNGDOydK36ty6iMM4Vy0xuvXgiV3tXIcRfhiV3dBBURyTn3XxWqkwKLc9jLRCfBnKqldy4kTvAvvPTInqEVNILBYWShUMCflDbOLsQmuUsRkvARyPlaTusLHI9cgsXg6YncyWXL9C8wW1lacQydK37PydD5gbm44YEoEl46fabvUslDQ0wXgiV3tXcyH2K(uFyiX3loePyPlaTusLHYvAnqkTvSbY79uSZMbm1XH3co0LGRBOyPlaTusLHYvAbeL2k2a59EkwgIzH6H3c2AI6eobPGHRyPlaTusLHYvAvbkTvS0fGwkPYqXgiV3tXI0dzxhUxJWG2G7kweSDc2HIvJVagDct6tNl7tFt7rWa0ssA8n35VqZxm8lCyFJrUSQ0i4y0U20c4EbWVWH9ng5YkLgbhJ21Mwa3lM8IkFrE(liD0SRRPKu)a2bOLW950XBxp8Cph6VwhVCuBTH33mgsbYx4lgrXsLcHC8fmKIfPhYUoCVgHbTb3vUsRbKsBflDbOLsQmuSiy7eSdfRgFbm6eM0Nox2N(M2JGbOLK04BUZvSbY79uSLfzYPeo0LGTtyqkyuUsRkuPTILUa0sjvgk2AiHcUJ9MHuSvL6uXgiV3tXg8Ac54TGDdcdOTjflc2ob7qXQXxe6sW2jznSzclUpU3hY5s6cqlLEHMVqJVG4C6qKK4C6qeEly3GWLfzY7Bg3WMlzIXDHVqZxm8liD0SRRPKm0LBeWGJl754TGRxae8f55VqJVG0rZUUMssKEi76W9Aeg0gC)fJOCLwvSsBflDbOLsQmuS1qcfCh7ndPyRkbIInqEVNIfK4Ehwmay4gkweSDc2HIn0LGTtYAyZewCFCVpKZL0fGwk9cnFHgFbX50HijX50Hi8wWUbHllYK33mUHnxYeJ7cFHMVy4xq6OzxxtjzOl3iGbhx2ZXBbxVai4lYZFHgFbPJMDDnLKi9q21H71imOn4(lgr5kxXIsCL2kTQQ0wXsxaAPKkdflc2ob7qXI21MwaNeK4Ehwmay4gsiXe9XFXOVqNdQydK37PyJdrChgwmkSwLR0QsL2kw6cqlLuzOyrW2jyhkw0U20c4KGe37WIbad3qcjMOp(lg9f6CqfBG8EpfBPHeOD3KYvAPtL2kw6cqlLuzOyrW2jyhkwqZsrg8Ac54TGDdcdOTjPz9l08fd)IspB4yiXe9XFXOVaTRnTaojib5eCS(MLjty49EVa4xKmHH379I88xm8l8aotU0GcRBiRr(lM8cDcKxKN)cn(cpS05YXARLG4(4EFixsxaAP0lg5fJ8I88xu6zdhdjMOp(lM8IQ6uXgiV3tXcsqobhRVzLR0AGuARyPlaTusLHIfbBNGDOybnlfzWRjKJ3c2nimG2MKM1VqZxm8lk9SHJHet0h)fJ(c0U20c4KG2Dt4IjupzYegEV3la(fjty49EVip)fd)cpGZKlnOW6gYAK)IjVqNa5f55VqJVWdlDUCS2AjiUpU3hYL0fGwk9IrEXiVip)fLE2WXqIj6J)IjVOAfOydK37PybT7MWftOEkxPfquARyPlaTusLHIfbBNGDOybnlfzbsNU6jnRFHMVa0SuKfiD6QNesmrF8xm6lMrjjtm(xKN)cn(cqZsrwG0PREsZAfBG8EpfRTNnCoECntZm05kxPvfO0wXsxaAPKkdflc2ob7qXcAwksqI7DyXaGHBinRFHMVa0SuKbVMqoEly3GWaABsAw)cnFHhWzYLguyDdznYFXKxOtG8I88xm8lg(fO94MmbOLK1R37H3c28aHDYsjCXeQ3lYZFbApUjtaAjP5bc7KLs4IjuVxmYl08fLE2WXqIj6J)IjVOcQ(I88xu6zdhdjMOp(lM8IkRGxmIInqEVNITE9EpLR0AaP0wXsxaAPKkdflc2ob7qXo8lQHK(4zuswvg8Ac54TGDdcdOTPxKN)c0U20c4KbVMqoEly3GWaABscjMOp(lM8Izu6f55VO0ZgogsmrF8xm5fvo4lg5f55VqJVG4C6qKu)M37H3cUMGfc59EsM(wOInqEVNIfWcTj9P(WqIVxCis5kTQqL2kw6cqlLuzOyrW2jyhkw0U20c4KbVMqoEly3GWaABscjMOp(lM8IQd(I88xu6zdhdjMOp(lg9fbY79WODTPfW9cGFrYegEV3lYZFrPNnCmKyI(4VyYl05Gk2a59Ek2zZaM64WBbh6sW1nuUsRkwPTInqEVNIf211wc3hMxhisXsxaAPKkdLR0Q6GkTvSbY79uSmeZc1dVfS1e1jCcsbdxXsxaAPKkdLR0QAvL2kw6cqlLuzOyrW2jyhkwpGZKlnOW6gYAK)IrFrfo4lYZFHhWzYLguyDdznYFXKSVOYbFrE(l8aotU0Bgc7lUg54kh8fJ(cDoOInqEVNIfsrDFZ4InyiUYvUIL7kTvAvvPTInqEVNIDS2AXCJ1vS0fGwkPYq5kTQuPTInqEVNIf0UBIBqjflDbOLsQmuUslDQ0wXsxaAPKkdflc2ob7qXcAwkYcKoD1tAw)cnFbOzPilq60vpjKyI(4VyYlMrPxKN)c0U20c4KGe37WIbad3qcjMOp(l08fd)IIP1IHeYiGZe2Bg6ftEXmk9I88xe6sW2jznSzclUpU3hY5s6cqlLEHMVaTRnTaozWRjKJ3c2nimG2MKqIj6J)IjVygLEXiVip)fODTPfWjbjU3HfdagUHesmrF8xm5fvR8fa)Izu6fA(cpS05soIohVfmOD3KKUa0sjfBG8EpflyabPeMBSUYvAnqkTvS0fGwkPYqXIGTtWouSLfzYFbWVOSitUesZ09cG6xmJsVyYlklYKlzIX)cnFbOzPibjU3HfdagUHmTaUxO5lg(fA8fP1LO9q05WWPeUydgcdAcpjKyI(4VqZxOXxeiV3tI2drNddNs4InyizF4ITNn8xmYlYZFrX0AXqczeWzc7nd9IjVygLErE(l8aotU0Bgc7lo10lM8cGOydK37Pyr7HOZHHtjCXgmKYvAbeL2kw6cqlLuzOyrW2jyhkwqZsrg8Ac54TGDdcdOTjzAbCVqZxm8lq7AtlGtcgqqkH5gRlrgbCM4VyYlQ(I88xOXxe6sW2jznSzclUpU3hY5s6cqlLEXik2a59Ek2GxtihVfSBqyaTnPCLwvGsBflDbOLsQmuSiy7eSdflOzPidEnHC8wWUbHb02K0S(fA(cqZsrcsCVdlgamCdPz9lYZFHhWzYLEZqyFXPMEXKxufik2a59EkwUhm1uIuUsRbKsBfBG8EpfBGzmHjcI3cgbxaCflDbOLsQmuUsRkuPTILUa0sjvgkweSDc2HIf0SuKGe37WIbad3qMwa3lYZFHhWzYLEZqyFXPMEXKxaefBG8EpfBzrMCkHdDjy7egKcgLR0QIvARyPlaTusLHIfbBNGDOybnlfjKqJzjohxwiIKM1Vip)fGMLIesOXSeNJllery0AEobLCpqJ9IjVO6GVip)fEaNjx6ndH9fNA6ftEbquSbY79uSUbHnpW18s4YcrKYvAvDqL2kw6cqlLuzOyrW2jyhkwpS05soIohVfmOD3KKUa0sPxKN)cpS05Y9imG2nWUbHRd0ys6cqlLEHMVa0SuKGe37WIbad3qcjMOp(lM8Izu6f55Va0SuKGe37WIbad3qMwa3l08fODTPfWjdEnHC8wWUbHb02KesmrF8xm6lQcKxKN)IspB4yiXe9XFXKxufiVa4xmJsk2a59EkwqI7DyXaGHBOCLwvRQ0wXsxaAPKkdflc2ob7qXg6sW2jzkoeH3corHBiHXn2lg9fvFHMVa0SuKP4qeEl4efUHesmrF8xm5fZOKInqEVNIfmGGucZnwx5kTQwPsBflDbOLsQmuSiy7eSdflOzPidEnHC8wWUbHb02KesmrF8xm6lQo4la(fZO0lYZFrPNnCmKyI(4VyYlQo4la(fZOKInqEVNIf0UBcVfSBqy6ig9uUsRQ6uPTInqEVNIDS2AXOLHjUKILUa0sjvgkxPv1bsPTILUa0sjvgkweSDc2HIf0SuKGe37WIbad3qMwa3lYZFrPNnCmKyI(4VyYlaIInqEVNIfmMXBb7Wgngx5kTQceL2k2a59EkwKrZeemWCJ1vS0fGwkPYq5kTQwbkTvSbY79uSPgsyqk4UILUa0sjvgkxPv1bKsBflDbOLsQmuSiy7eSdfRhw6C5Eegq7gy3GW1bAmjDbOLsVqZxGmc4mXXfyG8EVW(IrFrvjqErE(lqgbCM44cmqEVxyFXOVOQScFrE(lq7AtlGtg8Ac54TGDdcdOTjjKyI(4VyYlanlfzbsNU6jtMWW79Ebq7fZO0l08fHUeSDswdBMWI7J79HCUKUa0sPxKN)IspB4yiXe9XFXKxuXk2a59EkwWacsjm3yDLR0QAfQ0wXsxaAPKkdflc2ob7qXcAwksqI7DyXaGHBitlG7f55VO0ZgogsmrF8xm5fvOInqEVNIT2e2f96BgdAdURCLwvRyL2k2a59EkwWacJzsXsxaAPKkdLR0QYbvARyPlaTusLHIfbBNGDOyh(fLfzYFbq7fOL7Va4xuwKjxcPz6Ebq9lg(fODTPfWjhRTwmAzyIljHet0h)faTxu9fJ8IrFrG8Ep5yT1IrldtCjjA5(lYZFbAxBAbCYXARfJwgM4ssiXe9XFXOVO6la(fZO0l08fODTPfWjbjU3HfdagUHesmrFC8SjX5Vy0xuwKjx6ndH9fZeJ)f55Va0SuKmeZc1dVfS1e1jCcsbdxAw)IrEHMVaTRnTao5yT1IrldtCjjKyI(4Vy0xu9f55VO0ZgogsmrF8xm5f6uXgiV3tXIwqyG5gRRCLwvwvPTILUa0sjvgkweSDc2HIf0SuKfiD6QNmzcdV37faTxmJsVy0xumTwmKqgbCMWEZqk2a59EkwWacsjm3yDLRCflYsH(KsBLwvvARyPlaTusLHInqEVNIfmGGucZnwxXIGTtWouSGMLISaPtx9KM1VqZxaAwkYcKoD1tcjMOp(lMK9fZOKKjg)lYZFbAxBAbCsqI7DyXaGHBiHet0h)ftEr1kFbWVygLEHMVWdlDUKJOZXBbdA3njPlaTusXI0dzjShWzY5kTQQCLwvQ0wXsxaAPKkdflc2ob7qXoJssMy8VaO9cqZsrcsb3Xilf6tsiXe9XFXOVyqzLarXgiV3tXYyA9MBSUYvAPtL2kw6cqlLuzOydK37PybdiiLWCJ1vSiy7eSdfBX0AXqczeWzc7nd9IjVygLKmX4FHMVaTRnTaojiX9oSyaWWnKqIj6JRy9aotoUlkwLR0AGuARydK37PydEnHC8wWUbHb02KILUa0sjvgkxPfquARyPlaTusLHIfbBNGDOybnlfzWRjKJ3c2nimG2MKM1VqZxaAwksqI7DyXaGHBinRFrE(l8aotU0Bgc7lo10lM8IQarXgiV3tXY9GPMsKYvAvbkTvS0fGwkPYqXIGTtWouSEyPZLCeDoElyq7UjjDbOLsVip)fODTPfWjdEnHC8wWUbHb02KesmrFC8SjX5Vy0xu5GVip)fEyPZL7ryaTBGDdcxhOXK0fGwk9I88xu6zdhdjMOp(lM8IQarXgiV3tXcsCVdlgamCdLR0AaP0wXgiV3tXImAMGGbMBSUILUa0sjvgkxPvfQ0wXgiV3tXgygtyIG4TGrWfaxXsxaAPKkdLR0QIvARydK37PybdimMjflDbOLsQmuUsRQdQ0wXsxaAPKkdflc2ob7qXgiV1NW0rmnXFXKxmqVip)fA8fHUeSDscJ6oHHKDJKKUa0sjfBG8Epf7yT1IrldtCjLR0QAvL2k2a59Ek2udjmifCxXsxaAPKkdLR0QALkTvS0fGwkPYqXgiV3tXcgqqkH5gRRyrW2jyhkwqZsrwG0PREY0c4EHMVy4xGmc4mXXfyG8EVW(IrFrvzf(I88xaAwksqI7DyXaGHBinRFXiVip)fODTPfWjdEnHC8wWUbHb02KesmrF8xm5fGMLISaPtx9Kjty49EVaO9Izu6fA(Iqxc2ojRHntyX9X9(qoxsxaAP0lYZFbYiGZehxGbY79c7lg9fvLd0lYZFrPNnCmKyI(4VyYlQyflspKLWEaNjNR0QQYvAvvNkTvSbY79uSLfzYPeo0LGTtyqkyuS0fGwkPYq5kTQoqkTvSbY79uS1MWUOxFZyqBWDflDbOLsQmuUsRQarPTInqEVNIfThIohgoLWfBWqkw6cqlLuzOCLwvRaL2k2a59Ekwq7Uj8wWUbHPJy0tXsxaAPKkdLR0Q6asPTILUa0sjvgkweSDc2HIf0SuKqcnML4CCzHisAw)I88xaAwksiHgZsCoUSqeHrR55euY9an2lM8IQdQydK37PyDdcBEGR5LWLfIiLR0QAfQ0wXsxaAPKkdflc2ob7qXg6sW2jjmQ7egs2nss6cqlLEHMViqERpHPJyAI)IrFrLk2a59EkwgtR3CJ1vUsRQvSsBflDbOLsQmuSiy7eSdflAxBAbCYXARfJwgM4ssiXe9XFXOVOSitU0Bgc7lMjg)l08fd)Ia5T(eMoIPj(lM8cD(I88xOXxe6sW2jjmQ7egs2nss6cqlLEXik2a59Ekw0ccdm3yDLRCLRy1NG8EpLwvoyLdwDWQvSSQIfqaV(M5k2bwffOsRbSwd8b4fVqBd6fnt9c9xuw4l0qIkHP11WlGKoA2qk9c(YqVim9LjCk9cKrCZex(t1b9rVaidWla67PpbDk9cn4W(gJCPouI21MwaNgEHVVqdODTPfWj1HA4fdxD8Ji)P)0bwffOsRbSwd8b4fVqBd6fnt9c9xuw4l0akX1WlGKoA2qk9c(YqVim9LjCk9cKrCZex(t1b9rVaidWla67PpbDk9cnutUuhkhhPuQHx47l0W4iLsn8IH154hr(t)PdSkkqLwdyTg4dWlEH2g0lAM6f6VOSWxObURHxajD0SHu6f8LHEry6lt4u6fiJ4MjU8NQd6JEHohGxa03tFc6u6fAOMCPouoosPudVW3xOHXrkLA4fdx54hr(t1b9rVO6aAaEbqFp9jOtPxOHAYL6q54iLsn8cFFHgghPuQHxmC1XpI8NQd6JErLvhGxa03tFc6u6fAOMCPouoosPudVW3xOHXrkLA4fdxD8Ji)P)0bwffOsRbSwd8b4fVqBd6fnt9c9xuw4l0aYsH(KgEbK0rZgsPxWxg6fHPVmHtPxGmIBM4YFQoOp6fvhGxa03tFc6u6fAOMCPouoosPudVW3xOHXrkLA4fdx54hr(t1b9rVOYb4fa990NGoLEHgQjxQdLJJuk1Wl89fAyCKsPgEXWvh)iYFQoOp6f6CaEbqfXS6tPxW03aOdFbYGqJ9IHV1FrOF02a0sVOVxqmM2W79g5fdxD8Ji)P6G(OxuTYb4fa990NGoLEHgQjxQdLJJuk1Wl89fAyCKsPgEXWvo(rK)0F6aMPEHoLEbqErG8EVxyBUZL)uflVMqkTQei6uXwd3sBjfBf5fzqb3FbqXG7euVxau28Cc(tRiVaOaKVGe8fvo4qVOYbRCWF6pTI8cDaPpzFXKSVaidk)P)0a59ECznKqldy4aNntUjdZE4AY)PbY794YAiHwgWWboBMMCc3oXm0fmu2qxUradoUSNJ3cUEbqWFAG8EpUSgsOLbmCGZMjGfAt6t9HHeFV4q0pnqEVhxwdj0YagoWzZC2mGPoo8wWHUeCDJFAG8EpUSgsOLbmCGZMjdXSq9WBbBnrDcNGuWW)PbY794YAiHwgWWboBMMCc3oXmevkeYXxWqzr6HSRd3RryqBW9H6swncJoHj9PZL9PVP9iyaAjjn(M7Cnh2H9ng5YQsJGJr7AtlGdyh23yKlRuAeCmAxBAbCtQmpN0rZUUMss9dyhGwc3NthVD9WZ9CO)AD8YrT1gEFZyifiFHJ8tdK37XL1qcTmGHdC2mllYKtjCOlbBNWGuWmuxYQry0jmPpDUSp9nThbdqljPX3CN)tRiVOIMgxtUZFHBqVizcdV37fXLEbAxBAbCVylVOIYRjK)IT8c3GEXaRTPxex6fafcBMW(Ib8X9(qo)fG69c3GErYegEV3l2YlI7fMNrWDk9IboqhO0layq3lCdspnaPxyYP0lQHeAzadx(ImiuyYPxur51eYFXwEHBqVyG120lGuYer8xmWb6aLEbOEVOYbhKHp0lCJM)IM)IQsD(coH2lXL)0a59ECznKqldy4aNnZGxtihVfSBqyaTnnunKqb3XEZqzRk15qDjRgdDjy7KSg2mHf3h37d5CjDbOLsAQrIZPdrsIZPdr4TGDdcxwKjVVzCdBUKjg3fQ5WKoA211usg6YncyWXL9C8wW1lacMNRrshn76Akjr6HSRd3RryqBW9r(PvKxurtJRj35VWnOxKmHH379I4sVaTRnTaUxSLxKbX9oSVyGbd34fXLEbq5qx6fB5favXm9cq9EHBqVizcdV37fB5fX9cZZi4oLEXahOdu6famO7fUbPNgG0lm5u6f1qcTmGHl)PbY794YAiHwgWWboBMGe37WIbad3yOAiHcUJ9MHYwvcKH6s2qxc2ojRHntyX9X9(qoxsxaAPKMAK4C6qKK4C6qeEly3GWLfzY7Bg3WMlzIXDHAomPJMDDnLKHUCJagCCzphVfC9cGG55AK0rZUUMssKEi76W9Aeg0gCFKF6pnqEVhh4SzIwZZjiMBS(pnqEVhh4Sz6W40rZ22623mMBS(pnqEVhh4SzAYjC7edFOUKTgs6JNrjzvzWRjKJ3c2nimG2MYZl9SHJHet0hFsLd(tdK37XboBMMCc3oXm0fmu2qxUradoUSNJ3cUEbqWH6sw0U20c4KbVMqoEly3GWaABscjMOpoE2K48jvbIMLE2WXqIj6JpA1b)PbY794aNnttoHBNyg6cgkBWn0poIJHHUleJwyyhQlzteOzPiHHUleJwyyXjc0SuKM1AoSgjD0SRRPKm0LBeWGJl754TGRxaemp3H9ng5YqxUradoUSNJ3cUEbqqjAxBAbCsiXe9XhTcRG8CIZPdrsq7Uj8wWUbHPJy0tYeJ7chrZHRHK(4zuswvg8Ac54TGDdcdOTP8Cns6OzxxtjjspKDD4EncdAdURjOzPidEnHC8wWUbHb02KesmrF8rR4r0CynsCoDisI2lrhNsyBxOYcrKKjg3fMNdAwkYzZaM64WBbh6sW1nKM1JO5WEaNjxAqH1nK1iFIobsEUgjoNoejr7LOJtjSTluzHisYeJ7cZZ1Ohw6C5yT1sqCFCVpKlPlaTuAK88HteOzPiHHUleJwyyXjc0SuKPfWLNx6zdhdjMOp(KkRGr0S0ZgogsmrF8rhUYbcOEy0U20c4Ki9q21H71imOn4UesmrFCGhOjLE2WXqIj6JpYi)0a59ECGZMPjNWTtmdrLcHC8fmuwKEi76W9Aeg0gCFOUKf0SuKGe37WIbad3qMwaxEEPNnCmKyI(4taYpnqEVhh4SzIcRfhiV3dBBUp0fmuwuI)tdK37XboBMOWAXbY79W2M7dDbdLL7d1LSbYB9jmDett8jv(tdK37XboBMOWAXbY79W2M7dDbdLfzPqFAOUKnqERpHPJyAIpA1F6pnqEVhxIs8SXHiUddlgfw7qDjlAxBAbCsqI7DyXaGHBiHet0hFuDo4pnqEVhxIsCGZMzPHeOD30qDjlAxBAbCsqI7DyXaGHBiHet0hFuDo4pnqEVhxIsCGZMjib5eCS(MhQlzbnlfzWRjKJ3c2nimG2MKM1AoCPNnCmKyI(4JI21MwaNeKGCcowFZYKjm8EpGtMWW79YZh2d4m5sdkSUHSg5t0jqYZ1Ohw6C5yT1sqCFCVpKlPlaTuAKrYZl9SHJHet0hFsvD(tdK37XLOeh4SzcA3nHlMq9gQlzbnlfzWRjKJ3c2nimG2MKM1AoCPNnCmKyI(4JI21MwaNe0UBcxmH6jtMWW79aozcdV3lpFypGZKlnOW6gYAKprNajpxJEyPZLJ1wlbX9X9(qUKUa0sPrgjpV0ZgogsmrF8jvRGFAG8EpUeL4aNntBpB4C84AMMzOZhQlzRjxYe9jbnlfzbsNU6jnR1SMCjt0Ne0SuKfiD6QNesmrF8rNrjjtm(8CnwtUKj6tcAwkYcKoD1tAw)tdK37XLOeh4SzwVEV3qDjlOzPibjU3HfdagUH0SwtqZsrg8Ac54TGDdcdOTjPzTMEaNjxAqH1nK1iFIobsE(WdJ2JBYeGwswVEVhElyZde2jlLWftOE55O94MmbOLKMhiStwkHlMq9grZspB4yiXe9XNubvZZl9SHJHet0hFsLvWi)0a59ECjkXboBMawOnPp1hgs89Idrd1LSdxdj9XZOKSQm41eYXBb7gegqBt55ODTPfWjdEnHC8wWUbHb02KesmrF8jZOuEEPNnCmKyI(4tQCWrYZ1iX50HiP(nV3dVfCnbleY79Km9TWFAG8EpUeL4aNnZzZaM64WBbh6sW1ngQlzr7AtlGtg8Ac54TGDdcdOTjjKyI(4tQoyEEPNnCmKyI(4JI21MwahWjty49E55LE2WXqIj6JprNd(tdK37XLOeh4Szc76AlH7dZRde9tdK37XLOeh4SzYqmlup8wWwtuNWjifm8FAG8EpUeL4aNntif19nJl2GH4d1LSEaNjxAqH1nK1iF0kCW8CpGZKlnOW6gYAKpjBLdMN7bCMCP3me2xCnYXvo4O6CWF6pnqEVhxISuOpLfmGGucZnwFiKEilH9aotopB1H6s2AYLmrFsqZsrwG0PREsZAnRjxYe9jbnlfzbsNU6jHet0hFs2zusYeJpphTRnTaojiX9oSyaWWnKqIj6JpPALapJsA6HLoxYr054TGbT7MK0fGwk9tdK37XLilf6taNntgtR3CJ1hQlzNrjjtmEGwn5sMOpjOzPibPG7yKLc9jjKyI(4JoOSsG8tdK37XLilf6taNntWacsjm3y9H8aotoUlzz6BasRlbdiiLWCJ1LqIj6JpuxYwmTwmKqgbCMWEZqtMrjjtmEnr7AtlGtcsCVdlgamCdjKyI(4)0a59ECjYsH(eWzZm41eYXBb7gegqBt)0a59ECjYsH(eWzZK7btnLOH6swqZsrg8Ac54TGDdcdOTjPzTMGMLIeK4Ehwmay4gsZ68CpGZKl9MHW(ItnnPkq(PbY794sKLc9jGZMjiX9oSyaWWngQlz9WsNl5i6C8wWG2Dts6cqlLYZr7AtlGtg8Ac54TGDdcdOTjjKyI(44ztIZhTYbZZ9WsNl3JWaA3a7geUoqJjPlaTukpV0ZgogsmrF8jvbYpnqEVhxISuOpbC2mrgntqWaZnw)NgiV3Jlrwk0NaoBMbMXeMiiElyeCbW)PbY794sKLc9jGZMjyaHXm9tdK37XLilf6taNnZXARfJwgM4sd1LSbYB9jmDett8jduEUgdDjy7Keg1Dcdj7gjjDbOLs)0a59ECjYsH(eWzZm1qcdsb3)PbY794sKLc9jGZMjyabPeMBS(qi9qwc7bCMCE2Qd1LS1KlzI(KGMLISaPtx9KPfWP5WiJaotCCbgiV3lSJwvwH55GMLIeK4Ehwmay4gsZ6rYZr7AtlGtg8Ac54TGDdcdOTjjKyI(4tQjxYe9jbnlfzbsNU6jtMWW79aAZOKMHUeSDswdBMWI7J79HCUKUa0sP8CKraNjoUadK37f2rRkhO88spB4yiXe9XNuX)0a59ECjYsH(eWzZSSitoLWHUeSDcdsbZpnqEVhxISuOpbC2mRnHDrV(MXG2G7)0a59ECjYsH(eWzZeThIohgoLWfBWq)0a59ECjYsH(eWzZe0UBcVfSBqy6ig9(PbY794sKLc9jGZMPBqyZdCnVeUSqenuxYcAwksiHgZsCoUSqejnRZZbnlfjKqJzjohxwiIWO18Cck5EGgBs1b)PbY794sKLc9jGZMjJP1BUX6d1LSHUeSDscJ6oHHKDJKKUa0sjndK36ty6iMM4Jw5pnqEVhxISuOpbC2mrlimWCJ1hQlzr7AtlGtowBTy0YWexscjMOp(OLfzYLEZqyFXmX41C4a5T(eMoIPj(eDMNRXqxc2ojHrDNWqYUrssxaAP0i)0FAG8EpUK7zhRTwm3y9FAG8EpUK7aNntq7UjUbL(PbY794sUdC2mbdiiLWCJ1hQlzRjxYe9jbnlfzbsNU6jnR1SMCjt0Ne0SuKfiD6QNesmrF8jZOuEoAxBAbCsqI7DyXaGHBiHet0hxZHlMwlgsiJaotyVzOjZOuEEOlbBNK1WMjS4(4EFiNlPlaTust0U20c4KbVMqoEly3GWaABscjMOp(KzuAK8C0U20c4KGe37WIbad3qcjMOp(KQvc8mkPPhw6CjhrNJ3cg0UBssxaAP0pnqEVhxYDGZMjApeDomCkHl2GHgQlzllYKdCzrMCjKMPdOEgLMuwKjxYeJxtqZsrcsCVdlgamCdzAbCAoSgtRlr7HOZHHtjCXgmeg0eEsiXe9X1uJbY79KO9q05WWPeUydgs2hUy7zdFK88IP1IHeYiGZe2BgAYmkLN7bCMCP3me2xCQPja5NgiV3Jl5oWzZm41eYXBb7gegqBtd1LSGMLIm41eYXBb7gegqBtY0c40Cy0U20c4KGbeKsyUX6sKraNj(KQ55Am0LGTtYAyZewCFCVpKZL0fGwknYpnqEVhxYDGZMj3dMAkrd1LSGMLIm41eYXBb7gegqBtsZAnbnlfjiX9oSyaWWnKM155EaNjx6ndH9fNAAsvG8tdK37XLCh4SzgygtyIG4TGrWfa)NgiV3Jl5oWzZSSitoLWHUeSDcdsbZqDjlOzPibjU3HfdagUHmTaU8CpGZKl9MHW(Itnnbi)0a59ECj3boBMUbHnpW18s4Ycr0qDjlOzPiHeAmlX54YcrK0Soph0SuKqcnML4CCzHicJwZZjOK7bASjvhmp3d4m5sVziSV4uttaYpnqEVhxYDGZMjiX9oSyaWWngQlz9WsNl5i6C8wWG2Dts6cqlLYZ9WsNl3JWaA3a7geUoqJjPlaTustqZsrcsCVdlgamCdjKyI(4tMrP8CqZsrcsCVdlgamCdzAbCAI21MwaNm41eYXBb7gegqBtsiXe9XhTkqYZl9SHJHet0hFsvGa8mk9tdK37XLCh4SzcgqqkH5gRpuxYg6sW2jzkoeH3corHBiHXn2Ov1e0SuKP4qeEl4efUHesmrF8jZO0pnqEVhxYDGZMjOD3eEly3GW0rm6nuxYcAwkYGxtihVfSBqyaTnjHet0hF0Qdc8mkLNx6zdhdjMOp(KQdc8mk9tdK37XLCh4SzowBTy0YWex6NgiV3Jl5oWzZemMXBb7WgngFOUKf0SuKGe37WIbad3qMwaxEEPNnCmKyI(4taYpnqEVhxYDGZMjYOzccgyUX6)0a59ECj3boBMPgsyqk4(pnqEVhxYDGZMjyabPeMBS(qDjRhw6C5Eegq7gy3GW1bAmjDbOLsAImc4mXXfyG8EVWoAvjqYZrgbCM44cmqEVxyhTQScZZr7AtlGtg8Ac54TGDdcdOTjjKyI(4tQjxYe9jbnlfzbsNU6jtMWW79aAZOKMHUeSDswdBMWI7J79HCUKUa0sP88spB4yiXe9XNuX)0a59ECj3boBM1MWUOxFZyqBW9H6swqZsrcsCVdlgamCdzAbC55LE2WXqIj6JpPc)PbY794sUdC2mbdimMPFAG8EpUK7aNnt0ccdm3y9H6s2HllYKd0ql3bUSitUesZ0bupmAxBAbCYXARfJwgM4ssiXe9XbAvhz0a59EYXARfJwgM4ss0Y98C0U20c4KJ1wlgTmmXLKqIj6JpAvGNrjnr7AtlGtcsCVdlgamCdjKyI(44ztIZhTSitU0Bgc7lMjgFEoOzPiziMfQhElyRjQt4eKcgU0SEenr7AtlGtowBTy0YWexscjMOp(OvZZl9SHJHet0hFIo)PbY794sUdC2mbdiiLWCJ1hQlzRjxYe9jbnlfzbsNU6jtMWW79aAZO0OftRfdjKraNjS3mKYvUsb]] )
    end


end
