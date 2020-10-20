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
        spec:RegisterPack( "Beast Mastery", 20201019.9, [[dKKfNaqibIEebI2KGYNuj1OieDkcHvjOQ8kbzweQULGQQDr0VuIgMsfhtalJq5zkvAAkHY1ujzBei9nbcgNaPCocuwNGQmpvI7PsTpcWbjGkluPQhsGWhjGQgjbQ0jjqvRKszMkHQBsaL2Pi5NcKQwkbu8ujMQi1xjqfJvGqNvGK9k1FfAWI6WuTyO8yitwsxg1MvXNvkJweNwXQfivETsWSP42q1Ub(TQgUs64eqwoONJy6KUoLSDcPVtqJxjKZlqTEbvMpLQ9J0DGoDxQUYDkX2rSDcStGDL7iyb2zXc0fn4vUlRoAbFJ7cWX5USNDIsZcSorzyWDz1d28ETt3fYBbrCxsuDLeElxUnAIfMe94ljdULX15biOF0LKbhTSlywJrf8GgRlvx5oLy7i2ob2jWUYDeSa7SBqRlULM8WUugCbrxsMALbnwxQmb1fbjnVNDIsZcSorzyW0SGRfqzi1MGKMd6r6JXqAoWUItZITJy7qTrTjiP5fNfLn0SaO5R2r2fZqusNUlv(4wgTt3Pc0P7IJ05bDb9waLHrsYRDHboMHR9(w7uI1P7IJ05bDrHoqGSgZeUbSfjjV2fg4ygU27BTtTBNUlmWXmCT33feCugoExwHSOXnuvgq6KvgPX)e1eokCmvA2UDA(mBjAeY4(ai08fAwSD6IJ05bDXIWXrzCsRDQfRt3fg4ygU277IJ05bDb5gt0r68GOziAxmdrJahN7cQsATtDvNUlmWXmCT33feCugoExCKoIYrgW4dtO5l0SyDXr68GUGCJj6iDEq0meTlMHOrGJZDHOT2Pe0oDxyGJz4AVVli4OmC8U4iDeLJmGXhMqZcGMd0fhPZd6cYnMOJ05brZq0UygIgboo3fKHDr5wBTlRqg94yU2P7ub60DXr68GUqSWXFqCL1UWahZW1EFRDkX60DHboMHR9(UGGJYWX7c0cWNhUXsYBzopCJJmogdjswGSM1vU2fhPZd6I6WOc91w7u72P7cdCmdx79DzfYiNOrDW5UeqUBxCKopOlozLrA8prnHJchtT1o1I1P7cdCmdx79DzfYiNOrDW5UeqEvxCKopOlymrh3efcDnPli4OmC8UeK0S6ggOscIbA8prmZ)vjdCmdxP5WO5GKMHwa(8WnwsElZ5HBCKXXyirYcK1SUY1wBTlOkPt3Pc0P7cdCmdx79DbbhLHJ3f0)M6leiXyIoUjke6AIeY4(ai0SaO5D3PlosNh0fhGyIcDte5gtRDkX60DHboMHR9(UGGJYWX7c6Ft9fcKymrh3efcDnrczCFaeAwa08U70fhPZd6YzGmM5)ARDQD70DHboMHR9(UGGJYWX7cM15iDYkJ04FIAchfoMQ0ALMdJMfjnFMTenczCFaeAwa0m6Ft9fcKymKWWfgWMSAbDDEanhIMRwqxNhqZ2TtZIKMvhUXQmHDJMixrknFHM39kA2UDAoiPz1nmqLlmgddJdGOdaPsg4ygUsZIGMfbnB3onFMTenczCFaeA(cnhy3U4iDEqxWyiHHlmGTw7ulwNUlmWXmCT33feCugoExWSohPtwzKg)tut4OWXuLwR0Cy0SiP5ZSLOriJ7dGqZcGMr)BQVqGeZ8FnESGblRwqxNhqZHO5Qf015b0SD70SiPz1HBSkty3OjYvKsZxO5DVIMTBNMdsAwDddu5cJXWW4ai6aqQKboMHR0SiOzrqZ2TtZNzlrJqg3haHMVqZbe0U4iDEqxWm)xJhlyWT2PUQt3fg4ygU277ccokdhVlywNJ8azq4cwATsZHrZywNJ8azq4cwczCFaeAwa08gQkX9frZ2TtZbjnJzDoYdKbHlyP1AxCKopOlMzlrjXGoR6god0w7ucANUlmWXmCT33feCugoExWSohjgt0XnrHqxtKwR0Cy0mM15iDYkJ04FIAchfoMQ0ALMdJMvhUXQmHDJMixrknFHM39kA2UDAwK0SiPz0diw4oMHLRVopi(NOfadovdxJhlyW0SD70m6belChZWslagCQgUgpwWGPzrqZHrZNzlrJqg3haHMVqZcAaA2UDA(mBjAeY4(ai08fAwmbLMfrxCKopOlRVopO1w7cr70DQaD6UWahZW1EFxqWrz44DbZ6CKhidcxWsRvAomAgZ6CKhidcxWsiJ7dGqZxUP5nuLMTBNMpwgteYOehUXrDWzA(cnVHQ0Cy0m6Ft9fcKymrh3efcDnrczCFaeA2UDAg9VP(cbsmMOJBIcHUMiHmUpacnFHMdignhIM3qvAomAwDddujbXan(NiM5)QKboMHRDXr68GUG5qmUgjjV2ANsSoDxyGJz4AVVli4OmC8UaTa85HBSK8wMZd34iJJXqIKfiRzDLR0Cy0S6WOc9vjKX9bqO5l08gQsZHrZO)n1xiqEmoKLqg3haHMVqZBOAxCKopOlQdJk0xBTtTBNUlmWXmCT33feCugoExuhgvOVkTw7IJ05bD5yCi3ANAX60DXr68GUiCm1izDGJs6cdCmdx79T2PUQt3fhPZd6YcJXejjV2fg4ygU27BTtjOD6U4iDEqxogpyUgjjV2fg4ygU27BTtfe60DHboMHR9(UGGJYWX7Y5rweAoenJCIgH8gdO5l085rwejUVOU4iDEqxQSRjruIVa0XBTtf060DXr68GUGz(Vss4AxyGJz4AVV1oLG1P7IJ05bDXjRmsJ)jQjCu4yQDHboMHR9(w7ub2Pt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQab60DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkGyD6U4iDEqxWyIoUjke6AsxyGJz4AVV1ovGD70DXr68GUazYdCDaBrhcFHDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOllmgte944oO2fg4ygU27BTtfqq70DHboMHR9(UGGJYWX7cM15iXyIoUjke6AIS(cb0SD708z2s0iKX9bqO5l08vDXr68GUG5BX)ev4GwG0ANkqqOt3fhPZd6sDGCeJDI2fg4ygU27BTtfiO1P7cdCmdx79DbbhLHJ3LZSLOriJ7dGqZxOzbRlosNh0fmhIX1ij51w7ubeSoDxCKopOlyoe6BCxyGJz4AVV1oLy70P7cdCmdx79DbbhLHJ3frsZNhzrO5WpnJEIsZHO5ZJSisiVXaAo8rZIKMr)BQVqGCHXyIOhh3bvjKX9bqO5WpnhGMfbnlaA2r68a5cJXerpoUdQs0tuA2UDAg9VP(cbYfgJjIECChuLqg3haHMfanhGMdrZBOknhgnJ(3uFHajgt0XnrHqxtKqg3hajUzXecnlaA(8ilIuhCoQFe3xenlcAomAg9VP(cbYfgJjIECChuLqg3haHMfanhGMTBNMpZwIgHmUpacnFHM3TlosNh0f0Jb9ij51wBTlid7IYD6ovGoDxyGJz4AVVlosNh0fmhIX1ij51UGGJYWX7cM15ipqgeUGLwR0Cy0mM15ipqgeUGLqg3haHMVCtZBOAxqbJmCuD4gRKovGw7uI1P7cdCmdx79DbbhLHJ3fmRZrIXorJid7IYsiJ7dGqZxO5DKIDfnhIM3q1U4iDEqxWTm6qsET1o1UD6UWahZW1EFxqWrz44DbAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP5WOz1Hrf6RsiJ7dGqZxO5nuLMdJMr)BQVqG8yCilHmUpacnFHM3q1U4iDEqxuhgvOV2ANAX60DHboMHR9(UGGJYWX7I6WOc9vP1AxCKopOlhJd5w7ux1P7cdCmdx79DbbhLHJ3LZJSi0CiAg5enc5ngqZxO5ZJSisCFrDXr68GUuzxtIOeFbOJ3ANsq70DXr68GUiCm1izDGJs6cdCmdx79T2PccD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LJLXeHmkXHBCuhCMMVqZBOknhgnJ(3uFHajgt0XnrHqxtKqg3haHMTBNMr)BQVqGeJj64MOqORjsiJ7dGqZxO5aIrZHO5nuLMdJMv3WavsqmqJ)jIz(VkzGJz4AxqbJmCuD4gRKovGw7ubToDxCKopOlozLrA8prnHJchtTlmWXmCT33ANsW60DXr68GUGXeDCtui01KUWahZW1EFRDQa70P7IJ05bDbYKh46a2Ioe(c7cdCmdx79T2PceOt3fg4ygU277ccokdhVlywNJ0jRmsJ)jQjCu4yQsRvA2UDA(mBjAeY4(ai08fAoWvDXr68GUquhFLRCRDQaI1P7IJ05bD5y8G5AKK8AxyGJz4AVV1ovGD70DXr68GUSWymrsYRDHboMHR9(w7ubwSoDxCKopOlOKb3zOhjjV2fg4ygU27BTtf4QoDxCKopOlyM)RKeU2fg4ygU27BTtfqq70DXr68GU4rClyLHX)erWxiPlmWXmCT33ANkqqOt3fg4ygU277ccokdhVlywNJ8azq4cwczCFaeAwa0mVigzPCuhCUlosNh0fmhc9nU1ovGGwNUlmWXmCT33feCugoExopYIqZcGMrprP5q0SJ05bsClJoKKxLONODXr68GUSWymr0JJ7GARDQacwNUlmWXmCT33feCugoExWSohjgt0XnrHqxtK1xiGMTBNMpZwIgHmUpacnFHMVQlosNh0fmFl(NOch0cKw7uITtNUlosNh0L6a5ig7eTlmWXmCT33ANsSaD6UWahZW1EFxCKopOlyoeJRrsYRDbbhLHJ3LZSLOriJ7dGqZxOzbRlOGrgoQoCJvsNkqRDkXeRt3fg4ygU277ccokdhVlNhzrK6GZr9J4(IO5l08gQsZHpAwSU4iDEqxCiYbCKK8ART2AxeLHK5bDkX2rSDcStaXKcwxe6qWa2iDrWrGtGjLGpLaF4rZ0C6eMMh81hQ085H081Ok5AAgYcK1a5kntECMMDl9XDLR0mkXbBmrsTT4dGP5RcpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYDxKiKuBuBcocCcmPe8Pe4dpAMMtNW08GV(qLMppKMVMOxtZqwGSgixPzYJZ0SBPpURCLMrjoyJjsQTfFamnhi8OzbXdeLHkxP5RxzvgeLbLukVMM1NMVoOKs510SifBrIqsTrTj4iWjWKsWNsGp8OzAoDctZd(6dvA(8qA(AKHDr5RPzilqwdKR0m5XzA2T0h3vUsZOehSXej12IpaMMdeE0SG4bIYqLR081RSkdIYGskLxtZ6tZxhusP8AAwKITiriP2w8bW0SyHhnliEGOmu5knF9kRYGOmOKs510S(081bLukVMMfzGfjcj12IpaMMdeecpAwq8arzOYvA(6vwLbrzqjLYRPz9P5RdkPuEnnlYalsesQnQnbp(6dvUsZxrZosNhqZMHOej1wxwH)zmCxeK08E2jknlW6eLHbtZcUwaLHuBcsAoOhPpgdP5a7konl2oITd1g1MGKMxCwu2qZcGMVAhj1g1MJ05be5kKrpoMRHUxsSWXFqCLvQnhPZdiYviJECmxdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2CKopGixHm6XXCn09sNSYin(NOMWrHJPk(kKrorJ6GZ3bK7sT5iDEarUcz0JJ5AO7Lymrh3efcDnr8viJCIg1bNVdiVs85ChKQByGkjigOX)eXm)xLmWXmCnSGeAb4Zd3yj5TmNhUXrghJHejlqwZ6kxP2O2CKopGe6Ej6TakdJKKxP2CKopGe6EPcDGaznMjCdylssELAZr68asO7LweookJteFo3Rqw04gQkdiDYkJ04FIAchfoMQD7NzlrJqg3ha5Iy7qT5iDEaj09sKBmrhPZdIMHOIdCC(gvjuBosNhqcDVe5gt0r68GOziQ4ahNVjQ4Z52r6ikhzaJpm5IyuBosNhqcDVe5gt0r68GOziQ4ahNVrg2fLfFo3oshr5idy8Hjcia1g1MJ05bejQscDV0biMOq3erUXi(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxEgiJz(Vk(CUr)BQVqGeJj64MOqORjsiJ7dGiGD3HAZr68aIevjHUxIXqcdxyaBIpNBmRZr6KvgPX)e1eokCmvP1AyI8mBjAeY4(aica9VP(cbsmgsy4cdytwTGUopiu1c668a72fP6WnwLjSB0e5ksVS7v2ThKQByGkxymgggharhasLmWXmCveIWU9ZSLOriJ7dGCjWUuBosNhqKOkj09smZ)14XcgS4Z5gZ6CKozLrA8prnHJchtvATgMipZwIgHmUpaIaq)BQVqGeZ8FnESGblRwqxNheQAbDDEGD7IuD4gRYe2nAICfPx29k72ds1nmqLlmgddJdGOdaPsg4ygUkcry3(z2s0iKX9bqUeqqP2CKopGirvsO7LMzlrjXGoR6goduXNZ9kRsCFasmRZrEGmiCblTwdBLvjUpajM15ipqgeUGLqg3haraBOQe3xKD7b5kRsCFasmRZrEGmiCblTwP2CKopGirvsO7LRVopq85CJzDosmMOJBIcHUMiTwddZ6CKozLrA8prnHJchtvATgM6WnwLjSB0e5ksVS7v2TlsrIEaXc3XmSC915bX)eTayWPA4A8ybd2UD0diw4oMHLwam4unCnESGblIWoZwIgHmUpaYfbnGD7NzlrJqg3ha5IycQiO2O2CKopGirg2fLdDVeZHyCnssEvCuWidhvhUXk5oG4Z5ELvjUpajM15ipqgeUGLwRHTYQe3hGeZ6CKhidcxWsiJ7dGC5EdvP2CKopGirg2fLdDVe3YOdj5vXNZ9kRsCFasmRZrIXorJid7IYsiJ7dGCzhPyxfAdvP2CKopGirg2fLdDVuDyuH(Q4Z5gAb4Zd3yj5TmNhUXrghJHejlqwZ6kxdtDyuH(QeY4(aix2q1Wq)BQVqG8yCilHmUpaYLnuLAZr68aIezyxuo09YJXHS4Z5wDyuH(Q0ALAZr68aIezyxuo09Yk7AseL4laDCXNZ95rwKqiNOriVXGlNhzrK4(IO2CKopGirg2fLdDVu4yQrY6ahLqT5iDEarImSlkh6EjMdX4AKK8Q4OGrgoQoCJvYDaXNZ9XYyIqgL4WnoQdoFzdvdd9VP(cbsmMOJBIcHUMiHmUpaID7O)n1xiqIXeDCtui01ejKX9bqUeqSqBOAyQByGkjigOX)eXm)xLmWXmCLAZr68aIezyxuo09sNSYin(NOMWrHJPsT5iDEarImSlkh6Ejgt0XnrHqxtO2CKopGirg2fLdDVeYKh46a2Ioe(cP2CKopGirg2fLdDVKOo(kxzXNZnM15iDYkJ04FIAchfoMQ0A1U9ZSLOriJ7dGCjWvuBosNhqKid7IYHUxEmEWCnssELAZr68aIezyxuo09YfgJjssELAZr68aIezyxuo09suYG7m0JKKxP2CKopGirg2fLdDVeZ8FLKWvQnhPZdisKHDr5q3l9iUfSYW4FIi4lKqT5iDEarImSlkh6EjMdH(gl(CUxzvI7dqIzDoYdKbHlyjKX9bqeaVigzPCuhCMAZr68aIezyxuo09YfgJjIECChufFo3Nhzrea6jAihPZdK4wgDijVkrprP2CKopGirg2fLdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKid7IYHUxwhihXyNOuBosNhqKid7IYHUxI5qmUgjjVkokyKHJQd3yLChq85CFMTenczCFaKlcg1MJ05bejYWUOCO7Loe5aossEv85CFEKfrQdoh1pI7l6YgQg(eJAJAZr68aIKOHUxI5qmUgjjVk(CUxzvI7dqIzDoYdKbHlyP1AyRSkX9biXSoh5bYGWfSeY4(aixU3qv72pwgteYOehUXrDW5lBOAyO)n1xiqIXeDCtui01ejKX9bqSBh9VP(cbsmMOJBIcHUMiHmUpaYLaIfAdvdtDddujbXan(NiM5)QKboMHRuBosNhqKen09s1Hrf6RIpNBOfGppCJLK3YCE4ghzCmgsKSaznRRCnm1Hrf6RsiJ7dGCzdvdd9VP(cbYJXHSeY4(aix2qvQnhPZdisIg6E5X4qw85CRomQqFvATsT5iDEars0q3lfoMAKSoWrjuBosNhqKen09YfgJjssELAZr68aIKOHUxEmEWCnssELAZr68aIKOHUxwzxtIOeFbOJl(CUppYIec5enc5ngC58ilIe3xe1MJ05bejrdDVeZ8FLKWvQnhPZdisIg6EPtwzKg)tut4OWXuP2CKopGijAO7Le1Xx5kl(CUXSohPtwzKg)tut4OWXuLwR2TFMTenczCFaKlbUIAZr68aIKOHUx6rClyLHX)erWxiHAZr68aIKOHUxIXeDCtui01eQnhPZdisIg6EjKjpW1bSfDi8fsT5iDEars0q3lrjdUZqpssELAZr68aIKOHUxUWymr0JJ7Gk1MJ05bejrdDVeZ3I)jQWbTar85CJzDosmMOJBIcHUMiRVqGD7NzlrJqg3ha5YvuBosNhqKen09Y6a5ig7eLAZr68aIKOHUxI5qmUgjjVk(CUpZwIgHmUpaYfbJAZr68aIKOHUxI5qOVXuBosNhqKen09s0Jb9ij5vXNZTippYIe(rprdDEKfrc5nge(ej6Ft9fcKlmgte944oOkHmUpas4pGieGJ05bYfgJjIECChuLONO2TJ(3uFHa5cJXerpoUdQsiJ7dGiGaH2q1Wq)BQVqGeJj64MOqORjsiJ7dGe3SycraNhzrK6GZr9J4(IeryO)n1xiqUWymr0JJ7GQeY4(aiciGD7NzlrJqg3ha5YUDHSYOoLyxTBRT2na]] )
    else
        spec:RegisterPack( "Beast Mastery", 20201019.1, [[dS05fbqisqpsePSjsKprcmkLeNsjQvPkPYRuLAwkb3svsAxK6xIqdtjPJjjTmrupteX0ucPRPkX2OqQVPecJtejNJcjRtjvAEkf3tsSpLihuePAHuOEOQKYevLe5JkHsJuvsOtQeIwPsPzsHi3uvsu7Ke6NQscmuvjbTuvjv9uKmvsuFvjumwke1zvcv7LO)c1GjCyQwSQ6XGMSOUmQnlXNvQgnjDAPwTsQ41kPmBkDBKA3k(TkdxsDCkewoKNJy6cxNI2Ui47QIXRKQopf06PaZxK2pWYQsLLuzpyPIjVAYRwD1QgLo5KtsYjBusQWWAwsv7W18DwsnonlPmMDsaeVYojyKHsQA3q75zPYskYzIGSKsnIAY6MyI7DOA(1WJorstBA9OVbI8sKiPPHjkP(MTnwKJ8lPYEWsftE1KxT6QvnkDYjNKKRAusk3mupKKIQPFnjLANZ8i)sQmtGsQKgqym7KaiELDsWidbIxrZjyeyBsdiEfaJ7ZiGOQrTaqK8QjVkylyBsdimsCcSfi2ubiEzvTKY2KGivwsL5IBAdPYsfRkvws5WOVrsbpZjyeMOEHKIh)B5S0yzivmzPYskhg9nsQa5Jry222GE2Xe1lKu84FlNLgldPIjrQSKIh)B5S0yjfe1bJAxsvJ4eW7WSUQ2j1mmWxbhQm(PTzGinfik9UAGrmT3dbi2aejVQKYHrFJKYKW4oyAImKkUOsLLu84FlNLglPCy03iPCdiQoYj4Ynb(k467HrskiQdg1UKcENnFpJ2j1mmWxbhQm(PTznIP9Ei4DtMqaInar1xacLaIsVRgyet79qaILaIQRkPgNMLuUbevh5eC5MaFfC99Wiziv8fPYskE8VLZsJLuom6BKuornbFycg5gCim8qUvsbrDWO2Luz(BwkAKBWHWWd5wCM)MLI2SgiuciwbiuiqWgHzxxZzTBar1robxUjWxbxFpmcistbc4D289mA3aIQJCcUCtGVcU(EyKgX0EpeGyjGiPmAGinfiycHhiR)27Y4RGdvgZdtBOM2xNdbeldekbeRae1iob8omRRQDsndd8vWHkJFABgistbcfceSry211CwdneAVaDtdXFRtcGqjG4BwkANuZWaFfCOY4N2M1iM27HaelbegfqSmqOeqScqOqGGjeEGSgEtMhcNX2UWLdbznTVohcistbIVzPO3nDuU9bFfSBaJUqvBwdeldekbeRaeHJ25qRYUnu11Wai2aej5fGinfiuiqWecpqwdVjZdHZyBx4YHGSM2xNdbePPaHcbIWT8e61ARLr4EirpWqZJ)TCgiwgistbIvaIm)nlfnYn4qy4HCloZFZsrNVNbistbIsVRgyet79qaInarYgnqSmqOequ6D1aJyAVhcqSeqScqK8IceVoGyfGaENnFpJgAi0Eb6MgI)wNeAet79qaI3aXIceBaIsVRgyet79qaILbILLuJtZskNOMGpmbJCdoegEi3kdPIgTuzjfp(3YzPXskhg9nskOHq7fOBAi(BDsiPGOoyu7sQVzPO)mjA3IFqEOQZ3ZaePParP3vdmIP9EiaXgG4fjfxkmmWJtZskOHq7fOBAi(BDsidPIlcPYskE8VLZsJLuom6BKuq3AXom6BW2MeskBtc840SKcMjYqQysjvwsXJ)TCwASKcI6GrTlPCy0jWyEy6MjaXgGizjLdJ(gjf0TwSdJ(gSTjHKY2KaponlPiHmKkAusLLu84FlNLglPGOoyu7skhgDcmMhMUzcqSequvs5WOVrsbDRf7WOVbBBsiPSnjWJtZskOL9eyzidjvnIHh93dPYsfRkvws5WOVrsrmPPVbxZHKIh)B5S0yzivmzPYskE8VLZsJLuJtZsk3aIQJCcUCtGVcU(EyKKYHrFJKYnGO6iNGl3e4RGRVhgjdPIjrQSKYHrFJK65q2CcCpyetUXhilP4X)wolnwgsfxuPYskhg9nsQDthLBFWxb7gWOluLu84FlNLgldPIVivws5WOVrsrZ0hYq8vWwtyNXze70ejfp(3YzPXYqQOrlvwsXJ)TCwASKYHrFJKcAi0Eb6MgI)wNeskiQdg1UKsHabY7mMtGNq3tcM2Hr(3YAE9njiaHsaXkarG6zno0v1QobdVZMVNbiEdebQN14qNSw1jy4D289maXgGizGinfiyJWSRR5Sobh1(3Y4EcEiDyiEV39eoBGpcSTwp6zhJyhghciwwsXLcdd840SKcAi0Eb6MgI)wNeYqQ4IqQSKIh)B5S0yjfe1bJAxsPqGa5DgZjWtO7jbt7Wi)BznV(MeejLdJ(gjv5GMeoJDdyuhm(ZoTmKkMusLLu84FlNLglPQrm0jboAAwsvvNejLdJ(gjLtQzyGVcouz8tBZskiQdg1UKsHaHBaJ6G11OM2T4EirpWGO5X)wodekbekeiycHhiRzcHhiJVcouzC5GMKE2XnQjAAFDoeqOeqScqWgHzxxZzTBar1robxUjWxbxFpmcistbcfceSry211CwdneAVaDtdXFRtcGyzziv0OKklP4X)wolnwsvJyOtcC00SKQQ(fjLdJ(gj1Njr7w8dYdvjfe1bJAxs5gWOoyDnQPDlUhs0dmiAE8VLZaHsaHcbcMq4bYAMq4bY4RGdvgxoOjPNDCJAIM2xNdbekbeRaeSry211Cw7gquDKtWLBc8vW13dJaI0uGqHabBeMDDnN1qdH2lq30q836KaiwwgYqsbZePYsfRkvwsXJ)TCwASKcI6GrTlPG3zZ3ZO)mjA3IFqEOQrmT3dbiwcisYQskhg9nskFGmjqUfdDRvgsftwQSKIh)B5S0yjfe1bJAxsbVZMVNr)zs0Uf)G8qvJyAVhcqSeqKKvLuom6BKuLgXF7DzzivmjsLLu84FlNLglPGOoyu7sQVzPODsndd8vWHkJFABwBwdekbeRaeLExnWiM27HaelbeW7S57z0Fgry0A9SRZMip6BaI3ar2e5rFdqKMceRaeHJ25qRYUnu11Wai2aej5fGinfiuiqeULNqVwBTmc3dj6bgAE8VLZaXYaXYarAkqu6D1aJyAVhcqSbiQMejLdJ(gj1NregTwp7YqQ4IkvwsXJ)TCwASKcI6GrTlP(MLI2j1mmWxbhQm(PTzTznqOeqScqu6D1aJyAVhcqSeqaVZMVNr)T3LXftKH6SjYJ(gG4nqKnrE03aePPaXkar4ODo0QSBdvDnmaInarsEbistbcfceHB5j0R1wlJW9qIEGHMh)B5mqSmqSmqKMceLExnWiM27HaeBaIQgTKYHrFJK6BVlJlMidLHuXxKklP4X)wolnwsbrDWO2LuFZsrxq8yGHAZAGqjG4Bwk6cIhdmuJyAVhcqSeqSdZAAF9arAkqOqG4Bwk6cIhdmuBwlPCy03iPS9UAqWRJzENMNqgsfnAPYskE8VLZsJLuquhmQDj13Su0FMeTBXpipu1M1aHsaX3Su0oPMHb(k4qLXpTnRnRbcLaIWr7COvz3gQ6AyaeBaIK8cqKMceRaeRaeWBiM0(3Y66l6BWxbBoFuNTCgxmrgcePPab8gIjT)TS2C(OoB5mUyImeiwgiucik9UAGrmT3dbi2aegDvGinfik9UAGrmT3dbi2aejB0aXYskhg9nsQ6l6BKHuXfHuzjfp(3YzPXskiQdg1UKAfGOgXjG3HzDvTtQzyGVcouz8tBZarAkqaVZMVNr7KAgg4RGdvg)02SgX0EpeGydqSdZarAkqu6D1aJyAVhcqSbisEvGyzGinfiuiqWecpqwNqt6BWxbxZOcdJ(gnDphss5WOVrs9CiBobUhmIj34dKLHuXKsQSKIh)B5S0yjfe1bJAxsbVZMVNr7KAgg4RGdvg)02SgX0EpeGydquDvGinfik9UAGrmT3dbiwciCy03GH3zZ3ZaeVbISjYJ(gGinfik9UAGrmT3dbi2aejzvjLdJ(gj1UPJYTp4RGDdy0fQYqQOrjvws5WOVrsH66AlJ7btQDilP4X)wolnwgsfRUQuzjLdJ(gjfntFidXxbBnHDgNrSttKu84FlNLgldPIvRkvwsXJ)TCwASKcI6GrTlPchTZHwLDBOQRHbqSeqKuRcePPar4ODo0QSBdvDnmaInvaIKxfistbIWr7COJMMXXHRHbo5vbILaIKSQKYHrFJKcXEDp74I1PzImKHKIesLLkwvQSKYHrFJKAT2AXe1lKu84FlNLgldPIjlvws5WOVrs9T3LjQCwsXJ)TCwASmKkMePYskE8VLZsJLuquhmQDj13Su0fepgyO2Sgiuci(MLIUG4Xad1iM27HaeBaIDygistbc4D289m6ptI2T4hKhQAet79qacLaIvaIIP1Irmu1r7moAAgi2ae7WmqKMceUbmQdwxJAA3I7He9adIMh)B5mqOeqaVZMVNr7KAgg4RGdvg)02SgX0EpeGydqSdZaXYarAkqaVZMVNr)zs0Uf)G8qvJyAVhcqSbiQMmq8gi2HzGqjGiClpHMa5jWxb)T3L184FlNLuom6BKuFh95mMOEHmKkUOsLLu84FlNLglPGOoyu7sQYbnjaXBGOCqtIgX78aeVoGyhMbInar5GMenTVEGqjG4Bwk6ptI2T4hKhQ689maHsaXkaHcbI8fA4nqEcKhCgxSonJ)MOrJyAVhcqOeqOqGWHrFJgEdKNa5bNXfRtZ6EWfBVRgaXYarAkqumTwmIHQoANXrtZaXgGyhMbI0uGO07QbgX0EpeGydq8IKYHrFJKcEdKNa5bNXfRtZYqQ4lsLLu84FlNLglPGOoyu7sQVzPODsndd8vWHkJFABwNVNbiuciwbiG3zZ3ZO)o6Zzmr9cnu1r7mbi2aevbI0uGqHaHBaJ6G11OM2T4EirpWGO5X)wodellPCy03iPCsndd8vWHkJFABwgsfnAPYskE8VLZsJLuquhmQDj13Su0oPMHb(k4qLXpTnRnRbcLaIVzPO)mjA3IFqEOQnRbI0uGO07QbgX0EpeGydqu9fjLdJ(gjfjC6AoZYqQ4IqQSKYHrFJKYX0MOmJWxbdr3drsXJ)TCwASmKkMusLLu84FlNLglPGOoyu7sQVzPO)mjA3IFqEOQZ3ZaePParP3vdmIP9EiaXgG4fjLdJ(gjv5GMeoJDdyuhm(ZoTmKkAusLLu84FlNLglPGOoyu7sQVzPOrmCnlti4YHGS2SgistbIVzPOrmCnlti4YHGmgEMtWinjC4AaXgGO6QarAkqu6D1aJyAVhcqSbiErs5WOVrsfQm2C(N5KXLdbzzivS6QsLLu84FlNLglPGOoyu7sQWT8eAcKNaFf83ExwZJ)TCgistbIWT8e6By8thQ4qLX1oCnnp(3YzGqjG4Bwk6ptI2T4hKhQAet79qaInaXomdePPaX3Su0FMeTBXpipu157zacLac4D289mANuZWaFfCOY4N2M1iM27HaelbevFbistbIsVRgyet79qaInar1xaI3aXomlPCy03iP(mjA3IFqEOkdPIvRkvwsXJ)TCwASKcI6GrTlPCdyuhSo7dKXxbNzpu1iFwdiwciQcekbeFZsrN9bY4RGZShQAet79qaInaXomlPCy03iP(o6Zzmr9czivSAYsLLu84FlNLglPGOoyu7sQVzPODsndd8vWHkJFABwJyAVhcqSequDvG4nqSdZarAkqu6D1aJyAVhcqSbiQUkq8gi2HzjLdJ(gj13ExgFfCOYyEyAdLHuXQjrQSKYHrFJKAT2AXWJM2NSKIh)B5S0yzivS6IkvwsXJ)TCwASKcI6GrTlP(MLI(ZKODl(b5HQoFpdqKMceLExnWiM27HaeBaIxKuom6BKuFFhFfCGA4AezivS6lsLLuom6BKuq1M2zKJjQxiP4X)wolnwgsfRA0sLLuom6BKu5gX4p7KqsXJ)TCwASmKkwDrivwsXJ)TCwASKcI6GrTlPc3YtOVHXpDOIdvgx7W1084FlNbcLacOQJ2zcUGCy034wGyjGOQ(fGinfiGQoANj4cYHrFJBbILaIQ6Kcistbc4D289mANuZWaFfCOY4N2M1iM27HaeBaIVzPOliEmWqD2e5rFdq8QaXomdekbeUbmQdwxJAA3I7He9adIMh)B5mqKMceLExnWiM27HaeBacJss5WOVrs9D0NZyI6fYqQy1KsQSKIh)B5S0yjfe1bJAxs9nlf9Njr7w8dYdvD(EgGinfik9UAGrmT3dbi2aejLKYHrFJKQ2e1fd7zh)TojKHuXQgLuzjLdJ(gj13riFNLu84FlNLgldPIjVQuzjfp(3YzPXskiQdg1UKAfGOCqtcq8Qab8ibq8gikh0KOr8opaXRdiwbiG3zZ3ZOxRTwm8OP9jRrmT3dbiEvGOkqSmqSeq4WOVrVwBTy4rt7twdpsaePPab8oB(Eg9AT1IHhnTpznIP9EiaXsarvG4nqSdZaHsab8oB(Eg9Njr7w8dYdvnIP9Ei4DtMqaILaIYbnj6OPzCCyAF9arAkq8nlfnntFidXxbBnHDgNrStt0M1aXYaHsab8oB(Eg9AT1IHhnTpznIP9EiaXsarvGinfik9UAGrmT3dbi2aejrs5WOVrsbVpYXe1lKHuXKRkvwsXJ)TCwASKcI6GrTlP(MLIUG4Xad1ztKh9naXRce7WmqSequmTwmIHQoANXrtZskhg9nsQVJ(CgtuVqgYqsbTSNalvwQyvPYskE8VLZsJLuom6BKuFh95mMOEHKcI6GrTlP(MLIUG4Xad1M1aHsaX3Su0fepgyOgX0EpeGytfGyhM10(6bI0uGaENnFpJ(ZKODl(b5HQgX0EpeGydqunzG4nqSdZaHsar4wEcnbYtGVc(BVlR5X)wolPGgcTmoC0ohePIvLHuXKLklP4X)wolnwsbrDWO2Lu7WSM2xpq8QaX3Su0F2jbgAzpbwJyAVhcqSeqSQo5xKuom6BKu0M2OjQxidPIjrQSKIh)B5S0yjLdJ(gj13rFoJjQxiPGOoyu7sQIP1Irmu1r7moAAgi2ae7WSM2xpqOeqaVZMVNr)zs0Uf)G8qvJyAVhIKcAi0Y4Wr7CqKkwvgsfxuPYskhg9nskNuZWaFfCOY4N2MLu84FlNLgldPIVivwsXJ)TCwASKcI6GrTlP(MLI2j1mmWxbhQm(PTzTznqOeq8nlf9Njr7w8dYdvTznqKMceLExnWiM27HaeBaIQViPCy03iPiHtxZzwgsfnAPYskE8VLZsJLuquhmQDjv4wEcnbYtGVc(BVlR5X)wodePPab8oB(EgTtQzyGVcouz8tBZAet79qW7MmHaelbejVkqKMceHB5j03W4NouXHkJRD4AAE8VLZarAkqu6D1aJyAVhcqSbiQ(IKYHrFJK6ZKODl(b5HQmKkUiKklPCy03iPGQnTZihtuVqsXJ)TCwASmKkMusLLuom6BKuoM2eLze(kyi6EiskE8VLZsJLHurJsQSKYHrFJK67iKVZskE8VLZsJLHuXQRkvwsXJ)TCwASKcI6GrTlPCy0jWyEy6MjaXgGyrbI0uGqHaHBaJ6G1iVUZyeBppR5X)wolPCy03iPwRTwm8OP9jldPIvRkvws5WOVrsLBeJ)Stcjfp(3YzPXYqQy1KLklP4X)wolnws5WOVrs9D0NZyI6fskiQdg1UK6Bwk6cIhdmuNVNbiuciwbiGQoANj4cYHrFJBbILaIQ6KcistbIVzPO)mjA3IFqEOQnRbILbI0uGaENnFpJ2j1mmWxbhQm(PTznIP9EiaXgG4Bwk6cIhdmuNnrE03aeVkqSdZaHsaHBaJ6G11OM2T4EirpWGO5X)wodePPabu1r7mbxqom6BClqSequvVOarAkqu6D1aJyAVhcqSbimkjf0qOLXHJ25GivSQmKkwnjsLLuom6BKuLdAs4m2nGrDW4p70skE8VLZsJLHuXQlQuzjLdJ(gjvTjQlg2Zo(BDsiP4X)wolnwgsfR(IuzjLdJ(gjf8gipbYdoJlwNMLu84FlNLgldPIvnAPYskhg9nsQV9Um(k4qLX8W0gkP4X)wolnwgsfRUiKklP4X)wolnwsbrDWO2LuFZsrJy4AwMqWLdbzTznqKMceFZsrJy4AwMqWLdbzm8mNGrAs4W1aInar1vLuom6BKuHkJnN)zozC5qqwgsfRMusLLu84FlNLglPGOoyu7sk3ag1bRrEDNXi2EEwZJ)TCgiuciCy0jWyEy6MjaXsarYskhg9nskAtB0e1lKHuXQgLuzjfp(3YzPXskiQdg1UKcENnFpJET2AXWJM2NSgX0EpeGyjGOCqtIoAAghhM2xpqOeqScq4WOtGX8W0ntaInarsaI0uGqHaHBaJ6G1iVUZyeBppR5X)wodellPCy03iPG3h5yI6fYqgYqsLaJi9nsftE1KxT6QvnADvj1JJME2jsQfts)1R4IuXf76ceaHYQmq001hkaIYHacfK5IBAdfaei2imBeNbcYrZaHBghThCgiGQ(SZenyRrQhgiEzDbIx7MeyuWzGqbbQN14qBK1W7S57zuaqehqOa4D289mAJScaIvQU(L1GTGTlMK(RxXfPIl21fiacLvzGOPRpuaeLdbekaMjkaiqSry2iodeKJMbc3moAp4mqav9zNjAWwJupmq8Y6ceV2njWOGZaHcQ5qBK1lUwRvaqehqOGfxR1kaiwjjRFznyly7IjP)6vCrQ4IDDbcGqzvgiA66dfar5qaHciHcaceBeMnIZab5OzGWnJJ2dodeqvF2zIgS1i1ddejzDbIx7MeyuWzGqb1COnY6fxR1kaiIdiuWIR1AfaeRK86xwd2AK6HbIQlI1fiETBsGrbNbcfuZH2iRxCTwRaGioGqblUwRvaqSs11VSgS1i1ddejxDDbIx7MeyuWzGqb1COnY6fxR1kaiIdiuWIR1AfaeRuD9lRbBbBxmj9xVIlsfxSRlqaekRYartxFOaikhciua0YEcScaceBeMnIZab5OzGWnJJ2dodeqvF2zIgS1i1ddevxxG41UjbgfCgiuqnhAJSEX1ATcaI4acfS4ATwbaXkjV(L1GTgPEyGi51fiETBsGrbNbcfuZH2iRxCTwRaGioGqblUwRvaqSs11VSgS1i1ddevtEDbIx7MeyuWzGqb1COnY6fxR1kaiIdiuWIR1AfaeRK86xwd2c2UiPRpuWzG4fGWHrFdqyBsq0GTsQA0vAllPsAaHXStcG4v2jbJmeiEfnNGrGTjnG4vamUpJaIQg1carYRM8QGTGTjnGWiXjWwGytfG4Lv1GTGTom6Bi6Aedp6VhVRKiXKM(gCnhGTom6Bi6Aedp6VhVRKOjHXDW0lmonxXnGO6iNGl3e4RGRVhgb26WOVHORrm8O)E8UsIphYMtG7bJyYn(azWwhg9neDnIHh93J3vsC30r52h8vWUbm6cvWwhg9neDnIHh93J3vsKMPpKH4RGTMWoJZi2PjGTom6Bi6Aedp6VhVRKOjHXDW0lWLcdd840CfOHq7fOBAi(BDsSqxQOqK3zmNapHUNemTdJ8VL186BsquALa1ZACORQvDcgENnFpZ7a1ZACOtwR6em8oB(EMnjNMYgHzxxZzDcoQ9VLX9e8q6Wq8EV7jC2aFeyBTE0ZogXomo0YGTom6Bi6Aedp6VhVRKy5GMeoJDdyuhm(Zo9cDPIcrENXCc8e6EsW0omY)wwZRVjbbSnPbej986ysccqeQmqKnrE03ae(Kbc4D289maXvaIKoPMHbqCfGiuzGyX02mq4tgiEfIAA3celYHe9adcq8neicvgiYMip6BaIRae(aeMJQtcodel2x7vciEu5bicv2qfGyGWKWzGOgXWJ(7HgimMHUjHbIKoPMHbqCfGiuzGyX02mqG4SjKjaXI91ELaIVHarYRUknzbGiuBcq0eGOQojabHH3KjAWwhg9neDnIHh93J3vs0j1mmWxbhQm(PT5fQrm0jboAAUsvDswOlvuOBaJ6G11OM2T4EirpWGO5X)woRKczcHhiRzcHhiJVcouzC5GMKE2XnQjAAFDoKsRWgHzxxZzTBar1robxUjWxbxFpmknvHSry211CwdneAVaDtdXFRtILbBtAarspVoMKGaeHkdeztKh9naHpzGaENnFpdqCfGWyMeTBbIfdYdvGWNmq8k6gWaXvaIxVVZaX3qGiuzGiBI8OVbiUcq4dqyoQoj4mqSyFTxjG4rLhGiuzdvaIbctcNbIAedp6VhAWwhg9neDnIHh93J3vs8ZKODl(b5H6c1ig6KahnnxPQ(Lf6sf3ag1bRRrnTBX9qIEGbrZJ)TCwjfYecpqwZecpqgFfCOY4Ybnj9SJBut00(6CiLwHncZUUMZA3aIQJCcUCtGVcU(EyuAQczJWSRR5SgAi0Eb6MgI)wNeld2c26WOVH8UsIWZCcgHjQxa26WOVH8UsIbYhJWSTTb9SJjQxa26WOVH8UsIMeg3bttwOlvQrCc4Dywxv7KAgg4RGdvg)02CAAP3vdmIP9EiBsEvWwhg9nK3vs0KW4oy6fgNMR4gquDKtWLBc8vW13dJwOlvG3zZ3ZODsndd8vWHkJFABwJyAVhcE3KjKnvFrPsVRgyet79qwQ6QGTom6BiVRKOjHXDW0lmonxXjQj4dtWi3GdHHhYTl0Lkz(BwkAKBWHWWd5wCM)MLI2SwPvuiBeMDDnN1Ubevh5eC5MaFfC99WO00a1ZACODdiQoYj4Ynb(k467HrA4D289mAet79qwkPm60uMq4bY6V9Um(k4qLX8W0gQP915qlR0k1iob8omRRQDsndd8vWHkJFABonvHSry211CwdneAVaDtdXFRtcL(MLI2j1mmWxbhQm(PTznIP9EilzulR0kkKjeEGSgEtMhcNX2UWLdbznTVohkn9Bwk6DthLBFWxb7gWOlu1M1lR0kHJ25qRYUnu11WytsEjnvHmHWdK1WBY8q4m22fUCiiRP915qPPkmClpHET2AzeUhs0dm084FlNxonDLm)nlfnYn4qy4HCloZFZsrNVNjnT07QbgX0EpKnjB0lRuP3vdmIP9EilTsYl6RBf4D289mAOHq7fOBAi(BDsOrmT3d59IUP07QbgX0EpKLxgS1HrFd5DLenjmUdMEbUuyyGhNMRaneAVaDtdXFRtIf6sLVzPO)mjA3IFqEOQZ3ZKMw6D1aJyAVhYMxaBDy03qExjrOBTyhg9nyBtIfgNMRaZeWwhg9nK3vse6wl2HrFd22KyHXP5kKyHUuXHrNaJ5HPBMSjzWwhg9nK3vse6wl2HrFd22KyHXP5kql7jWl0Lkom6eympmDZKLQc2c26WOVHOHzsfFGmjqUfdDRDHUubENnFpJ(ZKODl(b5HQgX0EpKLsYQGTom6BiAyM8UsILgXF7D5f6sf4D289m6ptI2T4hKhQAet79qwkjRc26WOVHOHzY7kj(zeHrR1Z(cDPY3Su0oPMHb(k4qLXpTnRnRvALsVRgyet79qwcENnFpJ(ZicJwRNDD2e5rFZ7SjYJ(M00vchTZHwLDBOQRHXMK8sAQcd3YtOxRTwgH7He9adnp(3Y5LxonT07QbgX0EpKnvtcyRdJ(gIgMjVRK43ExgxmrgUqxQ8nlfTtQzyGVcouz8tBZAZALwP07QbgX0EpKLG3zZ3ZO)27Y4IjYqD2e5rFZ7SjYJ(M00vchTZHwLDBOQRHXMK8sAQcd3YtOxRTwgH7He9adnp(3Y5LxonT07QbgX0EpKnvnAWwhg9nenmtExjrBVRge86yM3P5jwOlvQ5qt79O)MLIUG4Xad1M1kvZHM27r)nlfDbXJbgQrmT3dzPDywt7RpnvH1COP9E0FZsrxq8yGHAZAWwhg9nenmtExjX6l6BwOlv(MLI(ZKODl(b5HQ2SwPVzPODsndd8vWHkJFABwBwRu4ODo0QSBdvDnm2KKxstxzf4netA)BzD9f9n4RGnNpQZwoJlMidttH3qmP9VL1MZh1zlNXftKHlRuP3vdmIP9EiBm6QPPLExnWiM27HSjzJEzWwhg9nenmtExjXNdzZjW9Grm5gFG8cDPYk1iob8omRRQDsndd8vWHkJFABonfENnFpJ2j1mmWxbhQm(PTznIP9EiB2H500sVRgyet79q2K8QlNMQqMq4bY6eAsFd(k4Agvyy03OP75qGTom6BiAyM8UsI7Mok3(GVc2nGrxOUqxQaVZMVNr7KAgg4RGdvg)02SgX0EpKnvxnnT07QbgX0EpKLG3zZ3Z8oBI8OVjnT07QbgX0EpKnjzvWwhg9nenmtExjruxxBzCpysTdzWwhg9nenmtExjrAM(qgIVc2Ac7moJyNMa26WOVHOHzY7kjIyVUNDCX60mzHUujC0ohAv2THQUgglLuRMMgoANdTk72qvxdJnvsE100Wr7COJMMXXHRHbo5vxkjRc2c26WOVHOHw2tGFxjXVJ(CgtuVybOHqlJdhTZbPs1f6sLAo00Ep6VzPOliEmWqTzTs1COP9E0FZsrxq8yGHAet79q2uzhM10(6ttH3zZ3ZO)mjA3IFqEOQrmT3dzt1KFVdZkfULNqtG8e4RG)27YAE8VLZGTom6BiAOL9e43vsK20gnr9If6sLDywt7R)vR5qt79O)MLI(ZojWql7jWAet79qwAvDYVa26WOVHOHw2tGFxjXVJ(CgtuVybOHqlJdhTZbPs1f6sLIP1Irmu1r7moAAEZomRP91Re8oB(Eg9Njr7w8dYdvnIP9EiGTom6BiAOL9e43vs0j1mmWxbhQm(PTzWwhg9nen0YEc87kjscNUMZ8cDPY3Su0oPMHb(k4qLXpTnRnRv6Bwk6ptI2T4hKhQAZ600sVRgyet79q2u9fWwhg9nen0YEc87kj(zs0Uf)G8qDHUujClpHMa5jWxb)T3L184FlNttH3zZ3ZODsndd8vWHkJFABwJyAVhcE3KjKLsE100WT8e6By8thQ4qLX1oCnnp(3Y500sVRgyet79q2u9fWwhg9nen0YEc87kjcvBANroMOEbyRdJ(gIgAzpb(DLeDmTjkZi8vWq09qaBDy03q0ql7jWVRK43riFNbBDy03q0ql7jWVRK4AT1IHhnTp5f6sfhgDcmMhMUzYMfnnvHUbmQdwJ86oJrS98SMh)B5myRdJ(gIgAzpb(DLeZnIXF2jbyRdJ(gIgAzpb(DLe)o6Zzmr9IfGgcTmoC0ohKkvxOlvQ5qt79O)MLIUG4Xad157zuAfOQJ2zcUGCy0342LQQtQ00VzPO)mjA3IFqEOQnRxonfENnFpJ2j1mmWxbhQm(PTznIP9EiBQ5qt79O)MLIUG4Xad1ztKh9nV6omRKBaJ6G11OM2T4EirpWGO5X)woNMcvD0otWfKdJ(g3Uuv9IMMw6D1aJyAVhYgJcS1HrFdrdTSNa)UsILdAs4m2nGrDW4p70GTom6BiAOL9e43vsS2e1fd7zh)TojaBDy03q0ql7jWVRKi8gipbYdoJlwNMbBDy03q0ql7jWVRK43ExgFfCOYyEyAdbBDy03q0ql7jWVRKyOYyZ5FMtgxoeKxOlv(MLIgXW1SmHGlhcYAZ600VzPOrmCnlti4YHGmgEMtWinjC4ABQUkyRdJ(gIgAzpb(DLePnTrtuVyHUuXnGrDWAKx3zmITNN184FlNvYHrNaJ5HPBMSuYGTom6BiAOL9e43vseEFKJjQxSqxQaVZMVNrVwBTy4rt7twJyAVhYsLdAs0rtZ44W0(6vAfhgDcmMhMUzYMKKMQq3ag1bRrEDNXi2EEwZJ)TCEzWwWwhg9nenjQSwBTyI6fGTom6BiAs8UsIF7DzIkNbBDy03q0K4DLe)o6Zzmr9If6sLAo00Ep6VzPOliEmWqTzTs1COP9E0FZsrxq8yGHAet79q2SdZPPW7S57z0FMeTBXpipu1iM27HO0kftRfJyOQJ2zC008MDyon1nGrDW6Aut7wCpKOhyq084FlNvcENnFpJ2j1mmWxbhQm(PTznIP9EiB2H5LttH3zZ3ZO)mjA3IFqEOQrmT3dzt1KFVdZkfULNqtG8e4RG)27YAE8VLZGTom6BiAs8UsIWBG8eip4mUyDAEHUuPCqtY7YbnjAeVZZRBhM3uoOjrt7RxPVzPO)mjA3IFqEOQZ3ZO0kkmFHgEdKNa5bNXfRtZ4VjA0iM27HOKcDy03OH3a5jqEWzCX60SUhCX27QXYPPftRfJyOQJ2zC008MDyonT07QbgX0EpKnVa26WOVHOjX7kj6KAgg4RGdvg)028cDPY3Su0oPMHb(k4qLXpTnRZ3ZO0kW7S57z0Fh95mMOEHgQ6ODMSPAAQcDdyuhSUg10Uf3dj6bgenp(3Y5LbBDy03q0K4DLejHtxZzEHUu5BwkANuZWaFfCOY4N2M1M1k9nlf9Njr7w8dYdvTzDAAP3vdmIP9EiBQ(cyRdJ(gIMeVRKOJPnrzgHVcgIUhcyRdJ(gIMeVRKy5GMeoJDdyuhm(Zo9cDPY3Su0FMeTBXpipu157zstl9UAGrmT3dzZlGTom6BiAs8UsIHkJnN)zozC5qqEHUu5BwkAedxZYecUCiiRnRtt)MLIgXW1SmHGlhcYy4zobJ0KWHRTP6QPPLExnWiM27HS5fWwhg9nenjExjXptI2T4hKhQl0LkHB5j0eipb(k4V9USMh)B5CAA4wEc9nm(PdvCOY4AhUMMh)B5SsFZsr)zs0Uf)G8qvJyAVhYMDyon9Bwk6ptI2T4hKhQ689mkbVZMVNr7KAgg4RGdvg)02SgX0EpKLQ(sAAP3vdmIP9EiBQ(Y7DygS1HrFdrtI3vs87OpNXe1lwOlvCdyuhSo7dKXxbNzpu1iFwBPQk9nlfD2hiJVcoZEOQrmT3dzZomd26WOVHOjX7kj(T3LXxbhQmMhM2Wf6sLVzPODsndd8vWHkJFABwJyAVhYsvx99omNMw6D1aJyAVhYMQR(EhMbBDy03q0K4DLexRTwm8OP9jd26WOVHOjX7kj(9D8vWbQHRrwOlv(MLI(ZKODl(b5HQoFptAAP3vdmIP9EiBEbS1HrFdrtI3vseQ20oJCmr9cWwhg9nenjExjXCJy8NDsa26WOVHOjX7kj(D0NZyI6fl0LkHB5j03W4NouXHkJRD4AAE8VLZkbvD0otWfKdJ(g3Uuv9lPPqvhTZeCb5WOVXTlvvNuPPW7S57z0oPMHb(k4qLXpTnRrmT3dztnhAAVh93Su0fepgyOoBI8OV5v3HzLCdyuhSUg10Uf3dj6bgenp(3Y500sVRgyet79q2yuGTom6BiAs8UsI1MOUyyp74V1jXcDPY3Su0FMeTBXpipu157zstl9UAGrmT3dztsb26WOVHOjX7kj(DeY3zWwhg9nenjExjr49roMOEXcDPYkLdAsEv4rI3LdAs0iENNx3kW7S57z0R1wlgE00(K1iM27H8QvxEjhg9n61ARfdpAAFYA4rI0u4D289m61ARfdpAAFYAet79qwQ67Dywj4D289m6ptI2T4hKhQAet79qW7MmHSu5GMeD00moomTV(00VzPOPz6dzi(kyRjSZ4mIDAI2SEzLG3zZ3ZOxRTwm8OP9jRrmT3dzPQPPLExnWiM27HSjjGTom6BiAs8UsIFh95mMOEXcDPsnhAAVh93Su0fepgyOoBI8OV5v3H5LkMwlgXqvhTZ4OPzjfPMHsft(LKidziL]] )
    end


end
