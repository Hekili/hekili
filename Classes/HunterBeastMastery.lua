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


    spec:RegisterPack( "Beast Mastery", 20201123, [[dWKwtbqiuuEebfSjjjFcegLKOtjjSkkrXRarZIsQBrjKSlk(fPWWuk6ysQwgPONrq10OeQRPuY2KKkFJGIgNsPY5OevRtPG5HICpsP9rj4Gssvwib5HkLYevku5IuIsFuPqmsLcvDsLcPvkPmtjPCtkHu2ji1pPeIHsjKQLsqHEkOMkk0xvkuglkQoRKuv7fQ)sYGj6WclgLEmQMSsUmYML4ZIYOPuNwQvRuQ61GKMTi3MuTBf)wLHlQoobLwUQEoKPt11j02rbFNaJNsKZtjz9GeZxPA)aJRJzedVcNWqR5MAUz96AkCt9T0u4BjCmSBvoHHZdouJmcdpHoHHfIcKdKw0cKtVvy48WQ0flmJyy0j(CcdB7EoAdAOrw72ISg(PRbQ1ftH33W)O4AGADUgyywXo5B0bZIHxHtyO1Ctn3SEDnfUP(wAkCl2YXWHOBFpggU13gg2UxlAWSy4fH4yyHbGuikqoqArlqo9wbKB8IJtpOMWaqc9XaPZspqQPWTgi1Ctn3edNAKJWmIHxujetoMrm01XmIHdU33GH5N440Rq2NJHPjyt0cle2XqRjMrmmnbBIwyHWWb37BWW8tCC6vi7ZXW8VD67ad)IdvUpJmik3wekiv(F8uOhEFJHMGnrlGCFhirNyITNLzARcKYVlHu5xJUbi33bYkbs(nlX2npXa9OiPUIQCVloKHMGnrlGSkGKza5lou5(mYGOCBrOGu5)XtHE49ngAc2eTaYkWWPEifFHHf(MyhdTWXmIHdU33GHfrKQDshHHPjyt0cle2XqBXygXWb37BWW(hJWk2Pgk9KPq2NJHPjyt0cle2XqVfMrmmnbBIwyHWW8VD67adN)edQm(Yu3eOCI7QROCBsjOtlGCFhilDMTREsp6bbKmbKAUjgo4EFdgwerQ2jDe2XqxDygXW0eSjAHfcdhCVVbdhqbzhFGuLBC1vu5Na6XW8VD67adZVlTobJjq5e3vxr52KsqNwMN0JEqQmrcHasMaY6BbKvbKLoZ2vpPh9GaslaK13edpHoHHdOGSJpqQYnU6kQ8ta9yhdTWeZigMMGnrlSqy4G79ny4azZqmes9buUxXVpsyy(3o9DGHxeRyPy(ak3R43hj1IyflfJyoqwfqwjqYmGKewXopNwMaki74dKQCJRUIk)eqpqUVdK87sRtWycOGSJpqQYnU6kQ8ta9MN0JEqaPfaYTR6aY9DGKqiA4KHnD3sDfLBtkAiDRm6X2FpqwbqwfqwjqM)edQm(Yu3eOCI7QROCBsjOtlGCFhizgqscRyNNtld3kE68)MMRytbYbYQaswXsXeOCI7QROCBsjOtlZt6rpiG0caPLdKvaKvbKvcKmdijeIgoz43SObrlvQlu5Eoz0JT)EGCFhizflftMy8Rog1vubuO)CBJyoqwbqwfqwjq6XNrUXMIKBBY5oqYeqk8TaY9DGKzajHq0Wjd)MfniAPsDHk3ZjJES93dK77ajZasps04gO2Pe9QEqEpC3qtWMOfqwbqUVdKvcKlIvSumFaL7v87JKArSILIzDcgGCFhilDMTREsp6bbKmbKAwDazfazvazPZSD1t6rpiG0cazLaPMwmqAzaYkbs(DP1jymCR4PZ)BAUInfi38KE0dciHeiTyGKjGS0z2U6j9OheqwbqwbgEcDcdhiBgIHqQpGY9k(9rc7yO3omJyyAc2eTWcHHdU33GH5wXtN)30CfBkqogM)TtFhyywXsXWsiVJKsWhUTzDcgGCFhilDMTREsp6bbKmbKBHHPsH4UAcDcdZTINo)VP5k2uGCSJH2YXmIHPjyt0clego4EFdgMhPKk4EFJk1ihdNAKRMqNWW8fc7yORVjMrmmnbBIwyHWW8VD67adhCVzGu0q6nHasMasnXWb37BWW8iLub37BuPg5y4uJC1e6egg5yhdD96ygXW0eSjAHfcdZ)2PVdmCW9MbsrdP3eciTaqwhdhCVVbdZJusfCVVrLAKJHtnYvtOtyyEIcgiSJDmC(t8tNnCmJyORJzedhCVVbdJe11VrLtogMMGnrlSqyhdTMygXW0eSjAHfcdpHoHHdOGSJpqQYnU6kQ8ta9y4G79ny4aki74dKQCJRUIk)eqp2XqlCmJy4G79nyyb3Nwmq9OEcDtmCcdttWMOfwiSJH2IXmIHPjyt0clego)jEGCL36egUUzlmCW9(gmShVY)ihdZ)2PVdm8lou5(mYGoXu5(msr6S0Jm0eSjAbK77a5lou5(mYmec1tMG4TcP8pYZ7jtf55XhUiYqtWMOf2XqVfMrmmnbBIwyHWW5pXdKR8wNWW1nBHHdU33GHzjK3rsj4d3gdZ)2PVdmmZasps04geNgxDffB6ULHMGnrlGSkGKza5lou5(mYGoXu5(msr6S0Jm0eSjAHDm0vhMrmCW9(gmCMy8Rog1vubuO)CBmmnbBIwyHWogAHjMrmCW9(gmSoPFVvQROsI8EPwpf6immnbBIwyHWog6TdZigMMGnrlSqy4G79nyyUv805)nnxXMcKJH5F703bgMza5h9srmqJB6HbX0qFWMidzPg5iGSkGSsG0)EGk5M6g7aP43LwNGbiHei9VhOsUrtJDGu87sRtWaKmbKAcK77ajjSIDEoTmmeFhSjs1JtdQDRuzDwWWLC1H4DkfEpzQNcUFpqwbgMkfI7Qj0jmm3kE68)MMRytbYXogAlhZigMMGnrlSqyy(3o9DGHzgq(rVued04MEyqmn0hSjYqwQrocdhCVVbdxoUiIwQak03oPyPqh7yORVjMrmmnbBIwyHWW5pXdKR8wNWW1nchdhCVVbdhOCI7QROCBsjOtlmm)BN(oWWmdidOqF7Kj)B9iP6b59WDKHMGnrlGSkGKzajHq0WjdHq0Wj1vuUnPkhxe1tMQ)gz0JT)EGSkGSsGKewXopNwMaki74dKQCJRUIk)eqpqUVdKmdijHvSZZPLHBfpD(FtZvSPa5azfyhdD96ygXW0eSjAHfcdN)epqUYBDcdx3Sfgo4EFdgMLqEhjLGpCBmm)BN(oWWbuOVDYK)TEKu9G8E4oYqtWMOfqwfqYmGKqiA4KHqiA4K6kk3MuLJlI6jt1FJm6X2FpqwfqwjqscRyNNtltafKD8bsvUXvxrLFcOhi33bsMbKKWk2550YWTINo)VP5k2uGCGScSJDmmFHWmIHUoMrmmnbBIwyHWW8VD67adZVlTobJHLqEhjLGpCBZt6rpiG0caPW3edhCVVbdhdNq(hjfpsjSJHwtmJyyAc2eTWcHH5F703bgMFxADcgdlH8oskbF42MN0JEqaPfasHVjgo4EFdgU0pXMUBHDm0chZigMMGnrlSqyy(3o9DGHReizflfJGoTuO8(BhzeZbY9DGKzaj)yGMyCZ0z2UQeeqwfqYkwkMaLtCxDfLBtkbDAzeZbYQaswXsXWsiVJKsWhUTrmhiRaiRciReilDMTREsp6bbKwai53LwNGXWspIEO2tMzj(H33aKqcKlXp8(gGCFhiRei94Zi3ytrYTn5Chizcif(wa5(oqYmG0JenUbQDkrVQhK3d3n0eSjAbKvaKvaK77azPZSD1t6rpiGKjGSUWXWb37BWWS0JOhQ9KHDm0wmMrmmnbBIwyHWW8VD67adxjqYkwkgbDAPq593oYiMdK77ajZas(XanX4MPZSDvjiGSkGKvSumbkN4U6kk3Muc60YiMdKvbKSILIHLqEhjLGpCBJyoqwbqwfqwjqw6mBx9KE0dciTaqYVlTobJHnD3sveFRmlXp8(gGesGCj(H33aK77azLaPhFg5gBksUTjN7ajtaPW3ci33bsMbKEKOXnqTtj6v9G8E4UHMGnrlGScGScGCFhilDMTREsp6bbKmbK1RomCW9(gmmB6ULQi(wHDm0BHzedhCVVbdN6mBhP2EXvMonogMMGnrlSqyhdD1HzedttWMOfwimm)BN(oWWSILIjq5e3vxr52KsqNwgXCGCFhilDMTREsp6bbKmbKAwDy4G79ny48Z7BWogAHjMrmmnbBIwyHWW8VD67adxjqM)edQm(Yu3eOCI7QROCBsjOtlGCFhi53LwNGXeOCI7QROCBsjOtlZt6rpiGKjGmJVaY9DGS0z2U6j9OheqYeqQ5Mazfa5(oqYmGKqiA4KHHg13OUIkN(cX9(gJEp3JHdU33GHfCFAXa1J6j0nXWjSJHE7WmIHPjyt0clegM)TtFhyy(DP1jymbkN4U6kk3Muc60Y8KE0dcizciRVjqUVdKLoZ2vpPh9GaslaKb37Bu87sRtWaKqcKlXp8(gGCFhilDMTREsp6bbKmbKcFtmCW9(gmCMy8Rog1vubuO)CBSJH2YXmIHdU33GH)opprQEuO8GtyyAc2eTWcHDm013eZigo4EFdgwN0V3k1vujrEVuRNcDegMMGnrlSqyhdD96ygXW0eSjAHfcdZ)2PVdmShFg5gBksUTjN7aPfaYTBtGCFhi94Zi3ytrYTn5ChizslqQ5Ma5(oq6XNrUXBDs5NkN7kn3eiTaqk8nXWb37BWWpf59KPkPqNqyh7yyKJzedDDmJy4G79ny4aLtCxDfLBtkbDAHHPjyt0cle2XqRjMrmmnbBIwyHWW8VD67adZkwkMYtduSYiMdKvbKSILIP80afRmpPh9GasM0cKz8fgo4EFdgMnEwAPq2NJDm0chZigMMGnrlSqyy(3o9DGHFXHk3Nrg0jMk3NrksNLEKHMGnrlGSkG0Jx5FKBEsp6bbKmbKz8fqwfqYVlTobJPKINmpPh9GasMaYm(cdhCVVbd7XR8pYXogAlgZigMMGnrlSqyy(3o9DGH94v(h5gXCGSkG8fhQCFgzqNyQCFgPiDw6rgAc2eTWWb37BWWLu8e2XqVfMrmCW9(gmmB6UfYMwyyAc2eTWcHDm0vhMrmCW9(gmSGoTuO8(BhHHPjyt0cle2XqlmXmIHdU33GHlPWkAPq2NJHPjyt0cle2XqVDygXW0eSjAHfcdZ)2PVdmmRyPykPWk6rk94HQ5j9OheqYeqUfqUVdKE8zKBSPi52MCUdKmPfi1CtmCW9(gmmu7usHSph7yOTCmJyyAc2eTWcHH5F703bgUsGKFxADcgJGoTuO8(BhzEsp6bbKwailIPK6jUD8zKYBDci33bsMbK8JbAIXntNz7QsqazfazvazLaj)U06emgwc5DKuc(WTnpPh9GasMaY6AcKwgGKBhFgHuLp4EFtKasibYm(ciRci9irJBqCAC1vuSP7wgAc2eTaY9DGSiMsQN42XNrkV1jGKjGmJVaYQas(DP1jymSeY7iPe8HBBEsp6bbKvaK77aPhFg5gV1jLFQvtajtaPLJHdU33GHzJNLwkK95yhdD9nXmIHPjyt0clegM)TtFhy4YXfrajKajpqU6PmAasMaYYXfrg9Wsy4G79ny4ffUTIBhq9dDSJHUEDmJyyAc2eTWcHH5F703bgMvSumbkN4U6kk3Muc60YiMdK77azPZSD1t6rpiGKjGS(wy4G79nyyKh650IWog66AIzedttWMOfwimm)BN(oWWLJlIasibYYXfrMNYObiTmazgFbKmbKLJlIm6HLaYQaswXsXWsiVJKsWhUTzDcgGSkGSsGKza56Cd)gon(hoTuLuOtkwXFmpPh9GaYQasMbKb37Bm8B404F40svsHoz6rvsDMTdKvaK77azrmLupXTJpJuERtajtazgFbK77azPZSD1t6rpiGKjGClmCW9(gmm)gon(hoTuLuOtyhdDDHJzedhCVVbdhkDXFrV6kk(FcqyyAc2eTWcHDm01TymJyyAc2eTWcHH5F703bgMvSumSeY7iPe8HBBeZbY9DGS0z2U6j9OheqYeqwFtmCW9(gm8tOBcVNmv8)ja7yORVfMrmmnbBIwyHWW8VD67adZVlTobJrqNwkuE)TJmpPh9GaslaK13ci33bsMbK8JbAIXntNz7Qsqa5(oqw6mBx9KE0dcizciRVfgo4EFdgMLqEhjLGpCBSJHUE1HzedhCVVbdZTB9G(qHSphdttWMOfwiSJHUUWeZigMMGnrlSqyy(3o9DGHzflfdlH8oskbF42M1jyaY9DGS0z2U6j9OheqYeqUfgo4EFdgUCCreTubuOVDsXsHo2XqxF7WmIHPjyt0clegM)TtFhyywXsX8ehQjcHuL75Krmhi33bswXsX8ehQjcHuL75KIFIJtVb5bhQajtaz9nbY9DGS0z2U6j9OheqYeqUfgo4EFdg2TjL4WEIZsvUNtyhdDDlhZigMMGnrlSqyy(3o9DGHzflfdlH8oskbF42gXCGCFhilDMTREsp6bbKmbK13edhCVVbd)e6MW7jtf)FcWogAn3eZigMMGnrlSqyy(3o9DGH53LwNGXiOtlfkV)2rMN0JEqaPfaY6BbK77ajZas(XanX4MPZSDvjiGCFhilDMTREsp6bbKmbK13cdhCVVbdZsiVJKsWhUn2XqRzDmJy4G79nyyUDRh0hkK95yyAc2eTWcHDm0AQjMrmmnbBIwyHWW8VD67adZkwkMaLtCxDfLBtkbDAzEsp6bbKwaiRVjqcjqMXxa5(oqw6mBx9KE0dcizciRVjqcjqMXxy4G79nyy20Dl1vuUnPOH0Tc7yO1u4ygXWb37BWWqTtjf)01JzHHPjyt0cle2XqRPfJzedttWMOfwimm)BN(oWWSILIHLqEhjLGpCBZ6ema5(oqw6mBx9KE0dcizci3cdhCVVbdZgzQRO8V5qfHDm0AUfMrmCW9(gm8QFsXsbYXW0eSjAHfc7yO1S6WmIHPjyt0clegM)TtFhy4kbYYXfraPffqYpKdKqcKLJlImpLrdqAzaYkbs(DP1jymqTtjf)01JzzEsp6bbKwuazDGScG0cazW9(gdu7usXpD9ywg(HCGCFhi53LwNGXa1oLu8txpML5j9OheqAbGSoqcjqMXxazfa5(oqwjqYkwkgwc5DKuc(WTnI5a5(oqYkwkMHqOEYeeVviL)rEEpzQipp(WfrgXCGScGSkGKza5lou5(mYiSrEku0tlXrjiE19l6n0eSjAbK77azPZSD1t6rpiGKjGu4y4G79nyy(X(HczFo2XqRPWeZigMMGnrlSqyy(3o9DGHzflfJGoTuO8(BhzeZXWb37BWWSXZslfY(CSJHwZTdZigMMGnrlSqyy(3o9DGHzflfdlH8oskbF42M1jyaY9DGS0z2U6j9OheqYeqUfgo4EFdgoEEmKkxmHiSJHwtlhZigMMGnrlSqyy(3o9DGHFXHk3Nrg0jMk3NrksNLEKHMGnrlGCFhiFXHk3NrMHqOEYeeVviL)rEEpzQipp(WfrgAc2eTWWb37BWWE8k)JCSJHw4BIzedttWMOfwimm)BN(oWWV4qL7ZiZqiupzcI3kKY)ipVNmvKNhF4IidnbBIwy4G79ny4Yteu6jt5FKJDSJH5jkyGWmIHUoMrmCW9(gmCGYjURUIYTjLGoTWW0eSjAHfc7yO1eZigMMGnrlSqy4G79nyy24zPLczFogM)TtFhyywXsXuEAGIvgXCGSkGKvSumLNgOyL5j9OheqYKwGmJVWWCR4js5XNrocdDDSJHw4ygXW0eSjAHfcdZ)2PVdmCgFbKwuajRyPyyPa5kEIcgiZt6rpiG0ca5Mgn3cdhCVVbdRlM8gzFo2XqBXygXW0eSjAHfcdZ)2PVdm8lou5(mYGoXu5(msr6S0Jm0eSjAbKvbKE8k)JCZt6rpiGKjGmJVaYQas(DP1jymLu8K5j9OheqYeqMXxy4G79nyypEL)ro2XqVfMrmmnbBIwyHWW8VD67ad7XR8pYnI5azva5lou5(mYGoXu5(msr6S0Jm0eSjAHHdU33GHlP4jSJHU6WmIHPjyt0clegM)TtFhy4YXfrajKajpqU6PmAasMaYYXfrg9Wsy4G79ny4ffUTIBhq9dDSJHwyIzedhCVVbdlOtlfkV)2ryyAc2eTWcHDm0BhMrmmnbBIwyHWWb37BWWSXZslfY(Cmm)BN(oWWfXus9e3o(ms5TobKmbKz8fqwfqYVlTobJHLqEhjLGpCBZt6rpiGCFhi53LwNGXWsiVJKsWhUT5j9OheqYeqwxtGesGmJVaYQasps04geNgxDffB6ULHMGnrlmm3kEIuE8zKJWqxh7yOTCmJy4G79nyywc5DKuc(WTXW0eSjAHfc7yORVjMrmCW9(gm8tOBcVNmv8)jadttWMOfwiSJHUEDmJyyAc2eTWcHH5F703bgMvSumbkN4U6kk3Muc60YiMdK77azPZSD1t6rpiGKjGS(wy4G79nyyKh650IWog66AIzedhCVVbdxsHv0sHSphdttWMOfwiSJHUUWXmIHdU33GHHANskK95yyAc2eTWcHDm01TymJy4G79nyyUDRh0hkK95yyAc2eTWcHDm013cZigo4EFdgMnD3cztlmmnbBIwyHWog66vhMrmCW9(gmCO0f)f9QRO4)jaHHPjyt0cle2XqxxyIzedttWMOfwimm)BN(oWWSILIP80afRmpPh9GaslaKKLiUOtkV1jmCW9(gmmB8FKryhdD9TdZigMMGnrlSqyy(3o9DGHlhxebKwai5hYbsibYG79ngDXK3i7Zn8d5y4G79nyyO2PKIF66XSWog66woMrmmnbBIwyHWW8VD67adZkwkgwc5DKuc(WTnRtWaK77azPZSD1t6rpiGKjGClmCW9(gmmBKPUIY)Mdve2XqR5MygXWb37BWWR(jflfihdttWMOfwiSJHwZ6ygXW0eSjAHfcdhCVVbdZgplTui7ZXW8VD67ad7XNrUXBDs5NA1eqYeqA5yyUv8eP84ZihHHUo2XqRPMygXW0eSjAHfcdZ)2PVdmC54IiJ36KYpLEyjGKjGmJVasldqQjgo4EFdgMFSFOq2NJDm0AkCmJyyAc2eTWcHH5F703bg(fhQCFgzqNyQCFgPiDw6rgAc2eTaY9DG8fhQCFgzgcH6jtq8wHu(h559KPI884dxezOjyt0cdhCVVbd7XR8pYXogAnTymJyyAc2eTWcHH5F703bg(fhQCFgzgcH6jtq8wHu(h559KPI884dxezOjyt0cdhCVVbdxEIGspzk)JCSJHwZTWmIHdU33GHlhxerlvaf6BNuSuOJHPjyt0cle2XqRz1HzedhCVVbdNl(DXQEYuSPa5yyAc2eTWcHDm0AkmXmIHdU33GH53WPX)WPLQKcDcdttWMOfwiSJHwZTdZigo4EFdgMnD3sDfLBtkAiDRWW0eSjAHfc7yO10YXmIHPjyt0clegM)TtFhyywXsX8ehQjcHuL75Krmhi33bswXsX8ehQjcHuL75KIFIJtVb5bhQajtaz9nXWb37BWWUnPeh2tCwQY9Cc7yh7yygOh13GHwZn1CZ6BQ5MM6yybXp9KHWWBSQNWi0BuO3iBaibsgTjGS1ZV3bYY9ajelQeIjhcG8jHvSFAbKOtNaYq0p9WPfqYTJjJqgqTQ1dbKAUbGCB3Wa9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbBIwqaKvQPLQWaQvTEiGuZnaKB7ggO3Pfqcb)MLy7gMdbq6hqcb)MLy7gMBOjyt0ccGSY6wQcdOw16HasH5gaYTDdd070ciHWJenUH5qaK(bKq4rIg3WCdnbBIwqaKvw3svya1Qwpeqkm3aqUTByGENwaje(3duj3WCd)U06emqaK(bKqWVlTobJH5qaKvw3svya1a12yvpHrO3OqVr2aqcKmAtazRNFVdKL7bsiYFIF6SHdbq(KWk2pTas0Ptazi6NE40ci52XKridOw16HaslEda52UHb6DAbKq8IdvUpJmmhcG0pGeIxCOY9zKH5gAc2eTGaiRSULQWaQvTEiG0I3aqUTByGENwajeV4qL7ZidZHai9diH4fhQCFgzyUHMGnrliaYWbslRfPAazL1TufgqTQ1dbKBTbGCB3Wa9oTasi8irJByoeaPFajeEKOXnm3qtWMOfeazL1TufgqTQ1dbKBTbGCB3Wa9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbBIwqaKHdKwwls1aYkRBPkmGAGABSQNWi0BuO3iBaibsgTjGS1ZV3bYY9aje8fccG8jHvSFAbKOtNaYq0p9WPfqYTJjJqgqTQ1dbKcFda52UHb6DAbKq4rIg3WCias)asi8irJByUHMGnrliaYkRBPkmGAvRhciT4naKB7ggO3PfqcHhjACdZHai9diHWJenUH5gAc2eTGaiRSULQWaQbQTXQEcJqVrHEJSbGeiz0MaYwp)Ehil3dKqGCiaYNewX(PfqIoDcidr)0dNwaj3oMmcza1QwpeqQ5gaYTDdd070ciHiNCdZnvFJXabq6hqcr13ymqaKvQPLQWaQvTEiGu4Bai32nmqVtlGeIxCOY9zKH5qaK(bKq8IdvUpJmm3qtWMOfeazL1TufgqTQ1dbKw8gaYTDdd070ciH4fhQCFgzyoeaPFajeV4qL7ZidZn0eSjAbbqgoqAzTivdiRSULQWaQvTEiG0Y3aqUTByGENwajeEKOXnmhcG0pGecps04gMBOjyt0ccGSY6wQcdOw16HasnRUnaKB7ggO3PfqcXlou5(mYWCias)asiEXHk3NrgMBOjyt0ccGSY6wQcdOw16HasnT8naKB7ggO3PfqcXlou5(mYWCias)asiEXHk3NrgMBOjyt0ccGSY6wQcdOw16HasnT8naKB7ggO3PfqcXlou5(mYWCias)asiEXHk3NrgMBOjyt0ccGmCG0YArQgqwzDlvHbuRA9qaPW3Cda52UHb6DAbKq8IdvUpJmmhcG0pGeIxCOY9zKH5gAc2eTGaidhiTSwKQbKvw3svya1a12yvpHrO3OqVr2aqcKmAtazRNFVdKL7bsi4jkyGGaiFsyf7Nwaj60jGme9tpCAbKC7yYiKbuRA9qaPMBai32nmqVtlGeICYnm3u9ngdeaPFajevFJXabqwPMwQcdOw16HasHVbGCB3Wa9oTasiYj3WCt13ymqaK(bKqu9ngdeazL1TufgqTQ1dbKw8gaYTDdd070ciH4fhQCFgzyoeaPFajeV4qL7ZidZn0eSjAbbqwzDlvHbuRA9qa5wBai32nmqVtlGeIxCOY9zKH5qaK(bKq8IdvUpJmm3qtWMOfeaz4aPL1IunGSY6wQcdOw16HaYTBda52UHb6DAbKq4rIg3WCias)asi8irJByUHMGnrliaYWbslRfPAazL1TufgqTQ1dbK1fMBai32nmqVtlGeICYnm3u9ngdeaPFajevFJXabqwzDlvHbuRA9qaPMcFda52UHb6DAbKq8IdvUpJmmhcG0pGeIxCOY9zKH5gAc2eTGaiRSULQWaQvTEiGutHVbGCB3Wa9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbBIwqaKHdKwwls1aYkRBPkmGAvRhci10I3aqUTByGENwajeV4qL7ZidZHai9diH4fhQCFgzyUHMGnrliaYWbslRfPAazL1TufgqnqTnQE(9oTaYTaYG79nazQroYaQHHZ)R0jcdlmaKcrbYbslAbYP3kGCJxCC6b1egasOpgiDw6bsnfU1aPMBQ5MGAGAb37BqM8N4NoB4qQvdKOU(nQCYb1cU33Gm5pXpD2WHuRgIis1oPB9e6K2aki74dKQCJRUIk)eqpOwW9(gKj)j(PZgoKA1qW9PfdupQNq3edNa1cU33Gm5pXpD2WHuRgE8k)JCRZFIhix5ToPTUzlR7I2xCOY9zKbDIPY9zKI0zPhTV)IdvUpJmdHq9KjiERqk)J88EYurEE8HlIa1cU33Gm5pXpD2WHuRgSeY7iPe8HBBD(t8a5kV1jT1nBzDx0Ymps04geNgxDffB6Uvvm7fhQCFgzqNyQCFgPiDw6rGAb37BqM8N4NoB4qQvJmX4xDmQROcOq)52GAb37BqM8N4NoB4qQvdDs)ERuxrLe59sTEk0rGAb37BqM8N4NoB4qQvdrePAN0TMkfI7Qj0jTCR4PZ)BAUInfi36UOLzF0lfXanUPhgetd9bBImKLAKJQQs)7bQKBQBSdKIFxADcgi9VhOsUrtJDGu87sRtWWKM77KWk2550YWq8DWMivponO2TsL1zbdxYvhI3Pu49KPEk4(9vaQfCVVbzYFIF6SHdPwnkhxerlvaf6BNuSuOBDx0YSp6LIyGg30ddIPH(GnrgYsnYrGAcdaz1BT9IihbKUnbKlXp8(gGmMfqYVlTobdqEfGS6HYjUdKxbiDBci3yDAbKXSasl6FRhjGCJoiVhUJaswRas3MaYL4hEFdqEfGmgGuCSdKtlGCJSTnoGuGnnaPBtwbXtaPiIwaz(t8tNnCdqkeXdrebKvpuoXDG8kaPBta5gRtlG8PLiNqa5gzBBCajRvaPMBUPoYAG0TBeq2iGSUr4ajI43SqgqTG79nit(t8tNnCi1QrGYjURUIYTjLGoTSo)jEGCL36K26gHBDx0YSak03ozY)wpsQEqEpChzOjyt0QkMrienCYqienCsDfLBtQYXfr9KP6Vrg9y7VVQkjHvSZZPLjGcYo(aPk34QROYpb0VVZmsyf78CAz4wXtN)30CfBkqEfGAcdaz1BT9IihbKUnbKlXp8(gGmMfqYVlTobdqEfGuic5DKaYn2hUnqgZci34dOqa5vasHXiJaswRas3MaYL4hEFdqEfGmgGuCSdKtlGCJSTnoGuGnnaPBtwbXtaPiIwaz(t8tNnCdOwW9(gKj)j(PZgoKA1GLqEhjLGpCBRZFIhix5ToPTUzlR7I2ak03ozY)wpsQEqEpChzOjyt0QkMrienCYqienCsDfLBtQYXfr9KP6Vrg9y7VVQkjHvSZZPLjGcYo(aPk34QROYpb0VVZmsyf78CAz4wXtN)30CfBkqEfGAGAb37BqqQvd(joo9kK95GAcdajJwKnolYgasgTBeqkOtjGCiAbKOtNasb3dvRbsupCci5N440Rq2NdKCBIdveqwUhidGKhi3ymGAb37BqqQvd(joo9kK95wN6Hu8LwHVP1Dr7lou5(mYGOCBrOGu5)XtHE49n77OtmX2ZYmTvbs53LqQ8Rr3SVxj)MLy7MNyGEuKuxrvU3fhQkM9IdvUpJmik3wekiv(F8uOhEFtfGAb37BqqQvdrePAN0rGAb37BqqQvd)Jryf7udLEYui7Zb1cU33GGuRgIis1oPJSUlAZFIbvgFzQBcuoXD1vuUnPe0P1(EPZSD1t6rpiM0CtqTG79nii1QHiIuTt6wpHoPnGcYo(aPk34QROYpb0BDx0YVlTobJjq5e3vxr52KsqNwMN0JEqQmrcHyQ(wvv6mBx9KE0dYc13eul4EFdcsTAiIiv7KU1tOtAdKndXqi1hq5Ef)(izDx0UiwXsX8buUxXVpsQfXkwkgX8QQKzKWk2550YeqbzhFGuLBC1vu5Na6339VhOsUjGcYo(aPk34QROYpb0B43LwNGX8KE0dYcBx1TVtienCYWMUBPUIYTjfnKUvg9y7VVIQQm)jguz8LPUjq5e3vxr52KsqNw77mJewXopNwgUv805)nnxXMcKxfRyPycuoXD1vuUnPe0PL5j9OhKfS8kQQsMrienCYWVzrdIwQuxOY9CYOhB)977SILIjtm(vhJ6kQak0FUTrmVIQQ0JpJCJnfj32KZDMe(w77mJqiA4KHFZIgeTuPUqL75Krp2(733zMhjACdu7uIEvpiVhUxX(ELlIvSumFaL7v87JKArSILIzDcM99sNz7QN0JEqmPz1vrvLoZ2vpPh9GSqLAAXwMk53LwNGXWTINo)VP5k2uGCZt6rpiiTyMkDMTREsp6bvrfGAb37BqqQvdrePAN0TMkfI7Qj0jTCR4PZ)BAUInfi36UOLvSumSeY7iPe8HBBwNGzFV0z2U6j9OhetBbQfCVVbbPwn4rkPcU33OsnYTEcDslFHa1cU33GGuRg8iLub37BuPg5wpHoPf5w3fTb3BgifnKEtiM0eul4EFdcsTAWJusfCVVrLAKB9e6KwEIcgiR7I2G7ndKIgsVjKfQdQbQfCVVbz4lK2y4eY)iP4rkzDx0YVlTobJHLqEhjLGpCBZt6rpili8nb1cU33Gm8fcsTAu6Nyt3TSUlA53LwNGXWsiVJKsWhUT5j9OhKfe(MGAb37Bqg(cbPwnyPhrpu7jZ6UOTswXsXiOtlfkV)2rgX89DMXpgOjg3mDMTRkbvfRyPycuoXD1vuUnPe0PLrmVkwXsXWsiVJKsWhUTrmVIQQS0z2U6j9OhKf43LwNGXWspIEO2tMzj(H33a5s8dVVzFVsp(mYn2uKCBto3zs4BTVZmps04gO2Pe9QEqEpCVIk23lDMTREsp6bXuDHdQfCVVbz4leKA1GnD3sveFRSUlARKvSumc60sHY7VDKrmFFNz8JbAIXntNz7QsqvXkwkMaLtCxDfLBtkbDAzeZRIvSumSeY7iPe8HBBeZROQklDMTREsp6bzb(DP1jymSP7wQI4BLzj(H33a5s8dVVzFVsp(mYn2uKCBto3zs4BTVZmps04gO2Pe9QEqEpCVIk23lDMTREsp6bXu9Qdul4EFdYWxii1QrQZSDKA7fxz604GAb37Bqg(cbPwnYpVVX6UOLvSumbkN4U6kk3Muc60YiMVVx6mBx9KE0dIjnRoqTG79nidFHGuRgcUpTyG6r9e6My4K1DrBL5pXGkJVm1nbkN4U6kk3Muc60AFNFxADcgtGYjURUIYTjLGoTmpPh9GykJV23lDMTREsp6bXKMBwX(oZieIgozyOr9nQROYPVqCVVXO3Z9GAb37Bqg(cbPwnYeJF1XOUIkGc9NBBDx0YVlTobJjq5e3vxr52KsqNwMN0JEqmvFZ99sNz7QN0JEqwGFxADcgixIF49n77LoZ2vpPh9Gys4BcQfCVVbz4leKA14788eP6rHYdobQfCVVbz4leKA1qN0V3k1vujrEVuRNcDeOwW9(gKHVqqQvJNI8EYuLuOtiR7Iwp(mYn2uKCBto3TW2T5(UhFg5gBksUTjN7mPvZn3394Zi34ToP8tLZDLMBAbHVjOgOwW9(gKHNOGbsBGYjURUIYTjLGoTa1cU33Gm8efmqqQvd24zPLczFU1CR4js5XNrosBDR7I2CYn6rpgwXsXuEAGIvgX8QYj3Oh9yyflft5PbkwzEsp6bXK2m(cul4EFdYWtuWabPwn0ftEJSp36UOnJVSOYj3Oh9yyflfdlfixXtuWazEsp6bzHnnAUfOwW9(gKHNOGbcsTA4XR8pYTUlAFXHk3Nrg0jMk3NrksNLEuvE8k)JCZt6rpiMY4RQ43LwNGXusXtMN0JEqmLXxGAb37BqgEIcgii1QrjfpzDx06XR8pYnI5v9IdvUpJmOtmvUpJuKol9iqTG79nidprbdeKA1yrHBR42bu)q36UOTCCreK8a5QNYOHPYXfrg9WsGAb37BqgEIcgii1QHGoTuO8(BhbQfCVVbz4jkyGGuRgSXZslfY(CR5wXtKYJpJCK26w3fTfXus9e3o(ms5ToXugFvf)U06emgwc5DKuc(WTnpPh9G2353LwNGXWsiVJKsWhUT5j9Ohet11eYm(Qkps04geNgxDffB6UfOwW9(gKHNOGbcsTAWsiVJKsWhUnOwW9(gKHNOGbcsTA8e6MW7jtf)Fca1cU33Gm8efmqqQvdKh650ISUlAzflftGYjURUIYTjLGoTmI577LoZ2vpPh9GyQ(wGAb37BqgEIcgii1QrjfwrlfY(CqTG79nidprbdeKA1aQDkPq2NdQfCVVbz4jkyGGuRgC7wpOpui7Zb1cU33Gm8efmqqQvd20DlKnTa1cU33Gm8efmqqQvJqPl(l6vxrX)tacul4EFdYWtuWabPwnyJ)JmY6UOnNCJE0JHvSumLNgOyL5j9OhKfilrCrNuERtGAb37BqgEIcgii1Qbu7usXpD9yww3fTLJlISa)qoKb37Bm6IjVr2NB4hYb1cU33Gm8efmqqQvd2itDfL)nhQiR7IwwXsXWsiVJKsWhUTzDcM99sNz7QN0JEqmTfOwW9(gKHNOGbcsTAS6NuSuGCqTG79nidprbdeKA1GnEwAPq2NBn3kEIuE8zKJ0w36UO1JpJCJ36KYp1QjMSCqTG79nidprbdeKA1GFSFOq2NBDx0woUiY4ToP8tPhwIPm(YYOjOwW9(gKHNOGbcsTA4XR8pYTUlAFXHk3Nrg0jMk3NrksNLE0((lou5(mYmec1tMG4TcP8pYZ7jtf55XhUicul4EFdYWtuWabPwnkprqPNmL)rU1Dr7lou5(mYmec1tMG4TcP8pYZ7jtf55XhUicul4EFdYWtuWabPwnkhxerlvaf6BNuSuOdQfCVVbz4jkyGGuRg5IFxSQNmfBkqoOwW9(gKHNOGbcsTAWVHtJ)Htlvjf6eOwW9(gKHNOGbcsTAWMUBPUIYTjfnKUvGAb37BqgEIcgii1QHBtkXH9eNLQCpNSUlAzflfZtCOMiesvUNtgX89DwXsX8ehQjcHuL75KIFIJtVb5bhQmvFtqnqTG79nidY1gOCI7QROCBsjOtlqTG79nidYHuRgSXZslfY(CR7I2CYn6rpgwXsXuEAGIvgX8QYj3Oh9yyflft5PbkwzEsp6bXK2m(cul4EFdYGCi1QHhVY)i36UO9fhQCFgzqNyQCFgPiDw6rv5XR8pYnpPh9GykJVQIFxADcgtjfpzEsp6bXugFbQfCVVbzqoKA1OKINSUlA94v(h5gX8QEXHk3Nrg0jMk3NrksNLEeOwW9(gKb5qQvd20DlKnTa1cU33GmihsTAiOtlfkV)2rGAb37BqgKdPwnkPWkAPq2NdQfCVVbzqoKA1aQDkPq2NBDx0YkwkMskSIEKspEOAEsp6bX0w77E8zKBSPi52MCUZKwn3eul4EFdYGCi1QbB8S0sHSp36UOTs(DP1jymc60sHY7VDK5j9OhKfkIPK6jUD8zKYBDAFNz8JbAIXntNz7QsqvuvL87sRtWyyjK3rsj4d328KE0dIP6AAz42XNriv5dU33ejiZ4RQ8irJBqCAC1vuSP7w77fXus9e3o(ms5ToXugFvf)U06emgwc5DKuc(WTnpPh9GQyF3JpJCJ36KYp1QjMSCqTG79nidYHuRglkCBf3oG6h6w3fTLJlIGKhix9ugnmvoUiYOhwcul4EFdYGCi1QbYd9CArw3fTSILIjq5e3vxr52KsqNwgX899sNz7QN0JEqmvFlqTG79nidYHuRg8B404F40svsHozDx0woUicYYXfrMNYOXYKXxmvoUiYOhwQkwXsXWsiVJKsWhUTzDcMQQKzRZn8B404F40svsHoPyf)X8KE0dQkMfCVVXWVHtJ)Htlvjf6KPhvj1z2Ef77fXus9e3o(ms5ToXugFTVx6mBx9KE0dIPTa1cU33GmihsTAekDXFrV6kk(FcqGAb37BqgKdPwnEcDt49KPI)pbw3fTSILIHLqEhjLGpCBJy((EPZSD1t6rpiMQVjOwW9(gKb5qQvdwc5DKuc(WTTUlA53LwNGXiOtlfkV)2rMN0JEqwO(w77mJFmqtmUz6mBxvcAFV0z2U6j9Ohet13cul4EFdYGCi1Qb3U1d6dfY(CqTG79nidYHuRgLJlIOLkGc9Ttkwk0TUlAzflfdlH8oskbF42M1jy23lDMTREsp6bX0wGAb37BqgKdPwnCBsjoSN4SuL75K1DrlRyPyEId1eHqQY9CYiMVVZkwkMN4qnriKQCpNu8tCC6nip4qLP6BUVx6mBx9KE0dIPTa1cU33GmihsTA8e6MW7jtf)FcSUlAzflfdlH8oskbF42gX899sNz7QN0JEqmvFtqTG79nidYHuRgSeY7iPe8HBBDx0YVlTobJrqNwkuE)TJmpPh9GSq9T23zg)yGMyCZ0z2UQe0(EPZSD1t6rpiMQVfOwW9(gKb5qQvdUDRh0hkK95GAb37BqgKdPwnyt3Tuxr52KIgs3kR7IwwXsXeOCI7QROCBsjOtlZt6rpiluFtiZ4R99sNz7QN0JEqmvFtiZ4lqTG79nidYHuRgqTtjf)01JzbQfCVVbzqoKA1GnYuxr5FZHkY6UOLvSumSeY7iPe8HBBwNGzFV0z2U6j9OhetBbQfCVVbzqoKA1y1pPyPa5GAb37BqgKdPwn4h7hkK95w3fTvwoUiYIIFihYYXfrMNYOXYuj)U06emgO2PKIF66XSmpPh9GSOQxHfcU33yGANsk(PRhZYWpKVVZVlTobJbQDkP4NUEmlZt6rpiluhYm(QI99kzflfdlH8oskbF42gX89DwXsXmec1tMG4TcP8pYZ7jtf55XhUiYiMxrvm7fhQCFgze2ipfk6PL4OeeV6(f977LoZ2vpPh9Gys4GAb37BqgKdPwnyJNLwkK95w3fTSILIrqNwkuE)TJmI5GAb37BqgKdPwnINhdPYftiY6UOLvSumSeY7iPe8HBBwNGzFV0z2U6j9OhetBbQfCVVbzqoKA1WJx5FKBDx0(IdvUpJmOtmvUpJuKol9O99xCOY9zKzieQNmbXBfs5FKN3tMkYZJpCreOwW9(gKb5qQvJYteu6jt5FKBDx0(IdvUpJmdHq9KjiERqk)J88EYurEE8HlIWWOCIJHwZTeo2Xogd]] )

end
