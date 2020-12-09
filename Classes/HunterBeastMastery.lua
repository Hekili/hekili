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

            nobuff = function () return settings.avoid_bw_overlap and "bestial_wrath" or nil, "avoid_bw_overlap is checked and bestial_wrath is up" end,

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
            texture = 132139,

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
                applyDebuff( "target", "tar_trap" )
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

            disabled = function ()
                return covenant.night_fae and not IsSpellKnownOrOverridesKnown( 328231 ), "you have not finished your night_fae covenant intro"
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


    spec:RegisterSetting( "barbed_shot_grace_period", 0.5, {
        name = "|T2058007:0|t Barbed Shot Grace Period",
        desc = "If set above zero, the addon (using the default priority or |cFFFFD100barbed_shot_grace_period|r expression) will recommend |T2058007:0|t Barbed Shot up to 1 global cooldown earlier.",
        icon = 2058007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 1,
        step = 0.01,
        width = "full"
    } )

    spec:RegisterSetting( "avoid_bw_overlap", false, {
        name = "Avoid |T132127:0|t Bestial Wrath Overlap",
        desc = "If checked, the addon will not recommend |T132127:0|t Bestial Wrath if the buff is already applied.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Beast Mastery", 20201205, [[dWK8sbqiuu9ikaSjjP(KsLrjj5usIwfLO4vkvnlkPUffGAxK6xeudtPOJjPAzuqpJsW0Oa11ukzBuIQVrbKXPuOoNKqwNsbZdf6EuO9rjYbLeklKG8qLszIua0fPeL(OsHyKkLkXjLeQwPKYmLeCtLsLANGu)KcOgQsPsAPuaYtb1urbFvPuXyrr5Skfs7fYFjzWeDyHfJspgvtwjxgzZs8zrz0uQtRy1kLQEniPzlYTPODl1Vvz4IQJtbYYv1ZHA6uDDcTDuKVtGXtj05PKSEqI5dI9dmQoIbe8kCcbTHBA4M1nCZT01RBWBSfQieSBvoHGZdouJmcb3HjHGfIcSdKB3b2P3keCEyv6IfIbem(eFoHGTDphVbHfoBCBrwn)mfgpMIPWNR5FuCHXJjxyemR4K8kEJyrWRWje0gUPHBw3Wn3sxVUbVXwWYrWHOBFpcgEm3gc2EwlQrSi4fH5iydaGuikWoqUDhyNERaYTlITtpOMbaqAasCYKLEGClRbsd30WnrWPb7yedi4fvcXKJyabDDedi4G7Z1iy(j2o9kS95iyQd2eTqcHCe0gIyabtDWMOfsieCW95Aem)eBNEf2(Cem)hN(jqWVytL7ZinMYTfHcwL)hpfMHpxRPoyt0ciHabiXNyID6LUhRcSYVlHv53GVgiHabiRci5xVehx)et0JJK6kQY9UytAQd2eTaYQbsMdKVytL7ZinMYTfHcwL)hpfMHpxRPoyt0ciRebNMMu8fc2cBICe0waXaco4(CncwetQXjtmcM6GnrlKqihbTbJyabhCFUgb7F0gK4KgOmDMcBFocM6GnrlKqihb9wigqWuhSjAHecbZ)XPFceC(tmPY4lDDDGZjURUIYTjLGjTasiqaYYKz7QNmJPXajJaPHBIGdUpxJGfXKACYeJCe0woIbem1bBIwiHqWb3NRrWbuW2Xhyv5AxDfv(jGEem)hN(jqW87sRtqRdCoXD1vuUnPemPL(jZyASktKWyGKrGS(waz1azzYSD1tMX0yG0saz9nrWDysi4aky74dSQCTRUIk)eqpYrqBGqmGGPoyt0cjeco4(CncoW2mfnHvFaL7v87JecM)Jt)ei4fXkwk6pGY9k(9rsTiwXsrlMdKvdKvbKmhijdsCYZPLoGc2o(aRkx7QROYpb0dKqGaK87sRtqRdOGTJpWQY1U6kQ8ta96NmJPXaPLaYn2YbsiqascJPMtA20Dl1vuUnPOMmTsBgB)9azLaz1azvaz(tmPY4lDDDGZjURUIYTjLGjTasiqasMdKKbjo550sZTINo)VE4k2uGDGSAGKvSu0boN4U6kk3MucM0s)KzmngiTeqwrazLaz1azvajZbscJPMtA(1lQX0sLMcvUNtAZy7VhiHabizflfDMy8RjA1vubuO)CBTyoqwjqwnqwfq6XNrU2MIKBRZ5oqYiqAHTasiqasMdKegtnN08RxuJPLknfQCpN0MX2FpqcbcqYCG0Je1UgQtkrVAASpn31uhSjAbKvcKqGaKvbKlIvSu0FaL7v87JKArSILIEDcAGeceGSmz2U6jZyAmqYiqAOLdKvcKvdKLjZ2vpzgtJbslbKvbKgAWaPLbiRci53LwNGwZTINo)VE4k2uGD9tMX0yGCpqAWajJazzYSD1tMX0yGSsGSseChMecoW2mfnHvFaL7v87JeYrqVXigqWuhSjAHecbhCFUgbZTINo)VE4k2uGDem)hN(jqWSILIMLW(ejLGpCB96e0ajeiazzYSD1tMX0yGKrGClemvke3vDysiyUv805)1dxXMcSJCe0veIbem1bBIwiHqWb3NRrW8iLub3NRvPb7i40GDvhMecMVWihbD9nrmGGPoyt0cjecM)Jt)ei4G7dtKIAYCimqYiqAico4(CncMhPKk4(CTknyhbNgSR6WKqWyh5iORxhXacM6GnrlKqiy(po9tGGdUpmrkQjZHWaPLaY6i4G7Z1iyEKsQG7Z1Q0GDeCAWUQdtcbZtuWeHCKJGZFIFMSHJyabDDedi4G7Z1iySOP51QCYrWuhSjAHec5iOneXacM6GnrlKqi4omjeCafSD8bwvU2vxrLFcOhbhCFUgbhqbBhFGvLRD1vu5Na6rocAlGyabhCFUgbl4(0IjAA1t4RJMtiyQd2eTqcHCe0gmIbem1bBIwiHqW5pXdSR8XKqW11BHGdUpxJG94v(h5iy(po9tGGFXMk3NrA8jMk3NrkYKLESM6GnrlGeceG8fBQCFgPBcJNotq8wHv(h55tNPI884dxeRPoyt0c5iO3cXacM6GnrlKqi48N4b2v(ysi466TqWb3NRrWSe2NiPe8HBJG5)40pbcM5aPhjQDnMtTRUIInD3stDWMOfqwnqYCG8fBQCFgPXNyQCFgPitw6XAQd2eTqocAlhXaco4(Cncotm(1eT6kQak0FUncM6GnrlKqihbTbcXaco4(Cnc2KmV3k1vujr(SuRNctmcM6GnrlKqihb9gJyabtDWMOfsieCW95Aem3kE68)6HRytb2rW8FC6NabZCG8JzPiMO21tZKyQPpytKMS4GDmqwnqwfq6)0qLCDDTDGv87sRtqdK7bs)NgQKRnuBhyf)U06e0ajJaPHajeiajzqItEoT0mf)eSjsnTtnECRuztwW0LC1H5tkf(0zQNcUFpqwjcMkfI7Qomjem3kE68)6HRytb2roc6kcXacM6GnrlKqiy(po9tGGzoq(XSuetu76Pzsm10hSjstwCWogbhCFUgbxoUiMwQak0poPyPWe5iORVjIbem1bBIwiHqW5pXdSR8XKqW11wabhCFUgbh4CI7QROCBsjyslem)hN(jqWmhidOq)4Ko)hZiPMg7tZDSM6GnrlGSAGK5ajHXuZjnHXuZj1vuUnPkhxepDMA(bRnJT)EGSAGSkGKmiXjpNw6aky74dSQCTRUIk)eqpqcbcqYCGKmiXjpNwAUv805)1dxXMcSdKvICe01RJyabtDWMOfsieC(t8a7kFmjeCD9wi4G7Z1iywc7tKuc(WTrW8FC6NabhqH(XjD(pMrsnn2NM7yn1bBIwaz1ajZbscJPMtAcJPMtQROCBsvoUiE6m18dwBgB)9az1azvajzqItEoT0buW2Xhyv5AxDfv(jGEGeceGK5ajzqItEoT0CR4PZ)RhUInfyhiRe5ihbZxyediORJyabtDWMOfsiem)hN(jqW87sRtqRzjSprsj4d3w)KzmngiTeqAHnrWb3NRrWrZjS)rsXJuc5iOneXacM6GnrlKqiy(po9tGG53LwNGwZsyFIKsWhUT(jZyAmqAjG0cBIGdUpxJGlZtSP7wihbTfqmGGPoyt0cjecM)Jt)ei4QaswXsrlyslfoF(XXAXCGeceGK5aj)yI6ODDpz2UQeeqwnqYkwk6aNtCxDfLBtkbtAPfZbYQbswXsrZsyFIKsWhUTwmhiReiRgiRciltMTREYmMgdKwci53LwNGwZspMEOoDMEj(HpxdK7bYL4h(Cnqcbcqwfq6XNrU2MIKBRZ5oqYiqAHTasiqasMdKEKO21qDsj6vtJ9P5UM6GnrlGSsGSsGeceGSmz2U6jZyAmqYiqw3ci4G7Z1iyw6X0d1PZqocAdgXacM6GnrlKqiy(po9tGGRcizflfTGjTu485hhRfZbsiqasMdK8JjQJ219Kz7Qsqaz1ajRyPOdCoXD1vuUnPemPLwmhiRgizflfnlH9jskbF42AXCGSsGSAGSkGSmz2U6jZyAmqAjGKFxADcAnB6ULQi(wPxIF4Z1a5EGCj(HpxdKqGaKvbKE8zKRTPi526CUdKmcKwylGeceGK5aPhjQDnuNuIE10yFAURPoyt0ciReiReiHabiltMTREYmMgdKmcK1TCeCW95AemB6ULQi(wHCe0BHyabhCFUgbNMmBhR2EXvMj1ocM6GnrlKqihbTLJyabtDWMOfsiem)hN(jqWSILIoW5e3vxr52KsWKwAXCGeceGSmz2U6jZyAmqYiqAOLJGdUpxJGZpFUg5iOnqigqWuhSjAHecbZ)XPFceCvaz(tmPY4lDDDGZjURUIYTjLGjTasiqas(DP1jO1boN4U6kk3MucM0s)KzmngizeiZ4lGeceGSmz2U6jZyAmqYiqA4MazLajeiajZbscJPMtAMg8CT6kQC6le3NR1MtFpco4(CncwW9Pft00QNWxhnNqoc6ngXacM6GnrlKqiy(po9tGG53LwNGwh4CI7QROCBsjysl9tMX0yGKrGS(MajeiazzYSD1tMX0yG0sazW95Af)U06e0a5EGCj(HpxdKqGaKLjZ2vpzgtJbsgbslSjco4(Cncotm(1eT6kQak0FUnYrqxrigqWb3NRrW)KNNi10kCEWjem1bBIwiHqoc66BIyabhCFUgbBsM3BL6kQKiFwQ1tHjgbtDWMOfsiKJGUEDediyQd2eTqcHG5)40pbc2JpJCTnfj3wNZDG0sa5gVjqcbcq6XNrU2MIKBRZ5oqYOrG0Wnbsiqasp(mY1(ysk)u5Cxz4MaPLaslSjco4(Cnc(PiF6mvjfMeg5ihbJDediORJyabhCFUgbh4CI7QROCBsjyslem1bBIwiHqocAdrmGGPoyt0cjecM)Jt)eiywXsrxEQHIvAXCGSAGKvSu0LNAOyL(jZyAmqYOrGmJVqWb3NRrWSXZslf2(CKJG2cigqWuhSjAHecbZ)XPFce8l2u5(msJpXu5(msrMS0J1uhSjAbKvdKE8k)JC9tMX0yGKrGmJVaYQbs(DP1jO1Lu8K(jZyAmqYiqMXxi4G7Z1iypEL)roYrqBWigqWuhSjAHecbZ)XPFceShVY)ixlMdKvdKVytL7Zin(etL7ZifzYspwtDWMOfco4(CncUKINqoc6TqmGGdUpxJGzt3TW20cbtDWMOfsiKJG2YrmGGdUpxJGfmPLcNp)4yem1bBIwiHqocAdeIbeCW95AeCjfwrlf2(Cem1bBIwiHqoc6ngXacM6GnrlKqiy(po9tGGzflfDjfwrpwzgpu1pzgtJbsgbYTasiqasp(mY12uKCBDo3bsgncKgUjco4(CncgQtkPW2NJCe0veIbem1bBIwiHqW8FC6NabZVlTobTMLW(ejLGpCB9tMX0yGKrGSUHaPLbi52XNryv5dUpxhjGCpqMXxaz1aPhjQDnMtTRUIInD3stDWMOfqcbcqwetj1tC74ZiLpMeqYiqMXxaz1aj)U06e0Awc7tKuc(WT1pzgtJbsiqasp(mY1(ysk)uRHasgbYkcbhCFUgbZgplTuy7Zroc66BIyabtDWMOfsiem)hN(jqWLJlIbY9ajpWU6PmQbsgbYYXfXAZWIi4G7Z1i4ffUTIBhq9dtKJGUEDediyQd2eTqcHG5)40pbcMvSu0boN4U6kk3MucM0slMdKqGaKLjZ2vpzgtJbsgbY6BHGdUpxJGXEyMtlc5iORBiIbem1bBIwiHqW8FC6NabxoUigi3dKLJlI1pLrnqAzaYm(cizeilhxeRndlcKvdKSILIMLW(ejLGpCB96e0az1azvajZbY15A(1CQ9pCAPkPWKuSIFRFYmMgdKvdKmhidUpxR5xZP2)WPLQKctspTQKMmBhiReiHabilIPK6jUD8zKYhtcizeiZ4lGeceGSmz2U6jZyAmqYiqUfco4(CncMFnNA)dNwQskmjKJGUUfqmGGdUpxJGdLP4VOxDff)pbyem1bBIwiHqoc66gmIbem1bBIwiHqW8FC6NabZkwkAwc7tKuc(WT1I5ajeiazzYSD1tMX0yGKrGS(Mi4G7Z1i4NWxh(0zQ4)taYrqxFlediyQd2eTqcHG5)40pbcMFxADcATGjTu485hhRFYmMgdKwciRVfqcbcqYCGKFmrD0UUNmBxvcciHabiltMTREYmMgdKmcK13cbhCFUgbZsyFIKsWhUnYrqx3YrmGGdUpxJG52JzqFOW2NJGPoyt0cjeYrqx3aHyabtDWMOfsiem)hN(jqWSILIMLW(ejLGpCB96e0ajeiazzYSD1tMX0yGKrGCleCW95AeC54IyAPcOq)4KILctKJGU(gJyabtDWMOfsiem)hN(jqWSILI(joutegRk3ZjTyoqcbcqYkwk6N4qnrySQCpNu8tSD61yp4qfizeiRVjqcbcqwMmBx9Kzmngizei3cbhCFUgb72KsSzpXEPk3ZjKJGUEfHyabtDWMOfsiem)hN(jqWSILIMLW(ejLGpCBTyoqcbcqwMmBx9KzmngizeiRVjco4(Cnc(j81HpDMk()eGCe0gUjIbem1bBIwiHqW8FC6NabZVlTobTwWKwkC(8JJ1pzgtJbslbK13ciHabizoqYpMOoAx3tMTRkbbKqGaKLjZ2vpzgtJbsgbY6BHGdUpxJGzjSprsj4d3g5iOnSoIbeCW95Aem3Emd6df2(Cem1bBIwiHqocAdneXacM6GnrlKqiy(po9tGGzflfDGZjURUIYTjLGjT0pzgtJbslbK13ei3dKz8fqcbcqwMmBx9KzmngizeiRVjqUhiZ4leCW95AemB6UL6kk3MuutMwHCe0gAbedi4G7Z1iyOoPKIFMMrVqWuhSjAHec5iOn0GrmGGPoyt0cjecM)Jt)eiywXsrZsyFIKsWhUTEDcAGeceGSmz2U6jZyAmqYiqUfco4(CncMnYuxr5)WHkg5iOnCledi4G7Z1i418KILcSJGPoyt0cjeYrqBOLJyabtDWMOfsiem)hN(jqWvbKLJlIbsdyGKFyhi3dKLJlI1pLrnqAzaYQas(DP1jO1qDsjf)mnJEPFYmMgdKgWazDGSsG0sazW95AnuNusXptZOxA(HDGeceGKFxADcAnuNusXptZOx6NmJPXaPLaY6a5EGmJVaYkbsiqaYQaswXsrZsyFIKsWhUTwmhiHabizflfDty80zcI3kSY)ipF6mvKNhF4IyTyoqwjqwnqYCG8fBQCFgPnOipfk6PLyReeV6(f9AQd2eTasiqaYYKz7QNmJPXajJaPfqWb3NRrW8J9df2(CKJG2qdeIbem1bBIwiHqW8FC6NabZkwkAbtAPW5ZpowlMJGdUpxJGzJNLwkS95ihbTHBmIbem1bBIwiHqW8FC6NabZkwkAwc7tKuc(WT1RtqdKqGaKLjZ2vpzgtJbsgbYTqWb3NRrWXZJMu5IjmHCe0gwrigqWuhSjAHecbZ)XPFce8l2u5(msJpXu5(msrMS0J1uhSjAbKqGaKVytL7ZiDty80zcI3kSY)ipF6mvKNhF4Iyn1bBIwi4G7Z1iypEL)roYrqBHnrmGGPoyt0cjecM)Jt)ei4xSPY9zKUjmE6mbXBfw5FKNpDMkYZJpCrSM6GnrleCW95AeC5jcktNP8pYroYrW8efmrigqqxhXaco4(CncoW5e3vxr52KsWKwiyQd2eTqcHCe0gIyabtDWMOfsieCW95AemB8S0sHTphbZ)XPFcemRyPOlp1qXkTyoqwnqYkwk6YtnuSs)Kzmngiz0iqMXxiyUv8eP84ZihJGUoYrqBbediyQd2eTqcHG5)40pbcoJVasdyGKvSu0SuGDfprbtK(jZyAmqAjGCtTHBHGdUpxJGnft(GTph5iOnyediyQd2eTqcHG5)40pbc(fBQCFgPXNyQCFgPitw6XAQd2eTaYQbspEL)rU(jZyAmqYiqMXxaz1aj)U06e06skEs)KzmngizeiZ4leCW95AeShVY)ih5iO3cXacM6GnrlKqiy(po9tGG94v(h5AXCGSAG8fBQCFgPXNyQCFgPitw6XAQd2eTqWb3NRrWLu8eYrqB5igqWuhSjAHecbZ)XPFceC54IyGCpqYdSREkJAGKrGSCCrS2mSico4(CncErHBR42bu)We5iOnqigqWb3NRrWcM0sHZNFCmcM6GnrlKqihb9gJyabtDWMOfsieCW95AemB8S0sHTphbZ)XPFceCrmLupXTJpJu(ysajJazgFbKvdK87sRtqRzjSprsj4d3w)KzmngiHabi53LwNGwZsyFIKsWhUT(jZyAmqYiqw3qGCpqMXxaz1aPhjQDnMtTRUIInD3stDWMOfcMBfprkp(mYXiORJCe0veIbeCW95AemlH9jskbF42iyQd2eTqcHCe013eXaco4(Cnc(j81HpDMk()eGGPoyt0cjeYrqxVoIbem1bBIwiHqW8FC6NabZkwk6aNtCxDfLBtkbtAPfZbsiqaYYKz7QNmJPXajJaz9TqWb3NRrWypmZPfHCe01neXaco4(CncUKcROLcBFocM6GnrlKqihbDDlGyabhCFUgbd1jLuy7ZrWuhSjAHec5iORBWigqWb3NRrWC7XmOpuy7ZrWuhSjAHec5iORVfIbeCW95AemB6Uf2MwiyQd2eTqcHCe01TCedi4G7Z1i4qzk(l6vxrX)tagbtDWMOfsiKJGUUbcXacM6GnrlKqiy(po9tGGzflfD5PgkwPFYmMgdKwcijlsCrNu(ysi4G7Z1iy24)iJqoc66BmIbem1bBIwiHqW8FC6NabxoUigiTeqYpSdK7bYG7Z1AtXKpy7Z18d7i4G7Z1iyOoPKIFMMrVqoc66veIbem1bBIwiHqW8FC6NabZkwkAwc7tKuc(WT1RtqdKqGaKLjZ2vpzgtJbsgbYTqWb3NRrWSrM6kk)houXihbTHBIyabhCFUgbVMNuSuGDem1bBIwiHqocAdRJyabtDWMOfsieCW95AemB8S0sHTphbZ)XPFceShFg5AFmjLFQ1qajJazfHG5wXtKYJpJCmc66ihbTHgIyabtDWMOfsiem)hN(jqWLJlI1(ysk)uMHfbsgbYm(ciTmaPHi4G7Z1iy(X(HcBFoYrqBOfqmGGPoyt0cjecM)Jt)ei4xSPY9zKgFIPY9zKImzPhRPoyt0ciHabiFXMk3Nr6MW4PZeeVvyL)rE(0zQipp(WfXAQd2eTqWb3NRrWE8k)JCKJG2qdgXacM6GnrlKqiy(po9tGGFXMk3Nr6MW4PZeeVvyL)rE(0zQipp(WfXAQd2eTqWb3NRrWLNiOmDMY)ih5iOnCledi4G7Z1i4YXfX0sfqH(XjflfMiyQd2eTqcHCe0gA5igqWb3NRrW5I)uSA6mfBkWocM6GnrlKqihbTHgiedi4G7Z1iy(1CQ9pCAPkPWKqWuhSjAHec5iOnCJrmGGdUpxJGzt3Tuxr52KIAY0kem1bBIwiHqocAdRiediyQd2eTqcHG5)40pbcMvSu0pXHAIWyv5EoPfZbsiqaswXsr)ehQjcJvL75KIFITtVg7bhQajJaz9nrWb3NRrWUnPeB2tSxQY9Cc5ih5iyMOhpxJG2WnnCZ61nCleSG47PZWi4TtfZac6ko0BKnaKajd2eqoM537az5EGC3IkHyY3bKpzqIZtlGeFMeqgI(zgoTasUD0zewdQvHPjG0WnaKB7AMO3PfqU7fBQCFgPz2oG0pGC3l2u5(msZmn1bBIw7aYQQBXk1GAvyAcinCda52UMj6DAbK7EXMk3NrAMTdi9di39InvUpJ0mttDWMO1oGSQ6wSsnOwfMMasd3aqUTRzIENwa5o(1lXX1mBhq6hqUJF9sCCnZ0uhSjATdiRQUfRudQvHPjG0aTbGCBxZe9oTaYDEKO21mBhq6hqUZJe1UMzAQd2eT2bKvv3IvQb1QW0eqAG2aqUTRzIENwa5o)NgQKRzMMFxADc6DaPFa5o(DP1jO1mBhqwvDlwPguduB7uXmGGUId9gzdajqYGnbKJz(9oqwUhi3L)e)mzdFhq(KbjopTas8zsazi6Nz40ci52rNrynOwfMMasdEda52UMj6DAbK7EXMk3NrAMTdi9di39InvUpJ0mttDWMO1oGmCG0YAGRaqwvDlwPguRcttaPbVbGCBxZe9oTaYDVytL7ZinZ2bK(bK7EXMk3NrAMPPoyt0AhqwvDlwPguRctta5wBai321mrVtlGCNhjQDnZ2bK(bK78irTRzMM6GnrRDazv1TyLAqTkmnbKBTbGCBxZe9oTaYDVytL7ZinZ2bK(bK7EXMk3NrAMPPoyt0AhqgoqAznWvaiRQUfRudQbQTDQygqqxXHEJSbGeizWMaYXm)Ehil3dK74l8oG8jdsCEAbK4ZKaYq0pZWPfqYTJoJWAqTkmnbKwyda52UMj6DAbK78irTRz2oG0pGCNhjQDnZ0uhSjATdiRQUfRudQvHPjG0G3aqUTRzIENwa5opsu7AMTdi9di35rIAxZmn1bBIw7aYQQBXk1GAGABNkMbe0vCO3iBaibsgSjGCmZV3bYY9a5oSVdiFYGeNNwaj(mjGme9ZmCAbKC7OZiSguRcttaPHBai321mrVtlGCxo5AMP3OATEhq6hqUBJQ16DazvgAXk1GAvyAciTWgaYTDnt070ci39InvUpJ0mBhq6hqU7fBQCFgPzMM6GnrRDazv1TyLAqTkmnbKg8gaYTDnt070ci39InvUpJ0mBhq6hqU7fBQCFgPzMM6GnrRDaz4aPL1axbGSQ6wSsnOwfMMaYkAda52UMj6DAbK78irTRz2oG0pGCNhjQDnZ0uhSjATdiRQUfRudQvHPjG0qlFda52UMj6DAbK7EXMk3NrAMTdi9di39InvUpJ0mttDWMO1oGSQ6wSsnOwfMMasdROnaKB7AMO3PfqU7fBQCFgPz2oG0pGC3l2u5(msZmn1bBIw7aYWbslRbUcazv1TyLAqTkmnbKgwrBai321mrVtlGC3l2u5(msZSDaPFa5UxSPY9zKMzAQd2eT2bKvv3IvQb1QW0eqAHn3aqUTRzIENwa5UxSPY9zKMz7as)aYDVytL7ZinZ0uhSjATdidhiTSg4kaKvv3IvQb1a12ovmdiOR4qVr2aqcKmyta5yMFVdKL7bYD8efmr7aYNmiX5PfqIptcidr)mdNwaj3o6mcRb1QW0eqA4gaYTDnt070ci3LtUMz6nQwR3bK(bK72OATEhqwLHwSsnOwfMMaslSbGCBxZe9oTaYD5KRzMEJQ16DaPFa5UnQwR3bKvv3IvQb1QW0eqAWBai321mrVtlGC3l2u5(msZSDaPFa5UxSPY9zKMzAQd2eT2bKvv3IvQb1QW0eqU1gaYTDnt070ci39InvUpJ0mBhq6hqU7fBQCFgPzMM6GnrRDaz4aPL1axbGSQ6wSsnOwfMMaYnEda52UMj6DAbK78irTRz2oG0pGCNhjQDnZ0uhSjATdidhiTSg4kaKvv3IvQb1QW0eqw3aTbGCBxZe9oTaYD5KRzMEJQ16DaPFa5UnQwR3bKvv3IvQb1QW0eqAOf2aqUTRzIENwa5UxSPY9zKMz7as)aYDVytL7ZinZ0uhSjATdidhiTSg4kaKvv3IvQb1QW0eqAOf2aqUTRzIENwa5UxSPY9zKMz7as)aYDVytL7ZinZ0uhSjATdiRQUfRudQvHPjG0qdEda52UMj6DAbK7EXMk3NrAMTdi9di39InvUpJ0mttDWMO1oGmCG0YAGRaqwvDlwPguduRIBMFVtlGClGm4(CnqMgSJ1GAi48)ktIqWgaaPquGDGC7oWo9wbKBxeBNEqndaG0aK4Kjl9a5wwdKgUPHBcQbQfCFUgRZFIFMSHV3OWyrtZRv5KdQfCFUgRZFIFMSHV3OWIysnozADhMKXaky74dSQCTRUIk)eqpOwW95ASo)j(zYg(EJcl4(0IjAA1t4RJMtGAb3NRX68N4NjB47nkShVY)i368N4b2v(ysgRR3Y6Py8fBQCFgPXNyQCFgPitw6XqG8InvUpJ0nHXtNjiERWk)J88PZurEE8HlIb1cUpxJ15pXpt2W3Buywc7tKuc(WTTo)jEGDLpMKX66TSEkgzUhjQDnMtTRUIInD3QAM)InvUpJ04tmvUpJuKjl9yqTG7Z1yD(t8ZKn89gfotm(1eT6kQak0FUnOwW95ASo)j(zYg(EJcBsM3BL6kQKiFwQ1tHjgul4(CnwN)e)mzdFVrHfXKACY0AQuiUR6WKmYTINo)VE4k2uGDRNIrM)XSuetu76Pzsm10hSjstwCWoU6Q8FAOsUUU2oWk(DP1jO37)0qLCTHA7aR43LwNGMrdHaHmiXjpNwAMIFc2ePM2PgpUvQSjly6sU6W8jLcF6m1tb3VVsqTG7Z1yD(t8ZKn89gfUCCrmTubuOFCsXsHP1tXiZ)ywkIjQD90mjMA6d2ePjloyhdQzaaKvS12lIDmq62eqUe)WNRbYOxaj)U06e0a5vaYkgoN4oqEfG0TjGC7mPfqg9ci3U(JzKaYkEJ9P5ogizTciDBcixIF4Z1a5vaYObsX2oWoTaYnY2mabsb2udKUnz1UNasrmTaY8N4NjB4AGuiIhIyciRy4CI7a5vas3MaYTZKwa5tlroHbYnY2mabswRasd3CttS1aPBpyGCWazDTfasmXVEH1GAb3NRX68N4NjB47nkCGZjURUIYTjLGjTSo)jEGDLpMKX6Aly9umY8ak0poPZ)XmsQPX(0ChRPoyt0QAMtym1Cstym1CsDfLBtQYXfXtNPMFWAZy7VV6QidsCYZPLoGc2o(aRkx7QROYpb0dbcZjdsCYZPLMBfpD(F9WvSPa7vcQzaaKvS12lIDmq62eqUe)WNRbYOxaj)U06e0a5vasHiSprci3oF42az0lGC7safciVcqAafzeqYAfq62eqUe)WNRbYRaKrdKITDGDAbKBKTzacKcSPgiDBYQDpbKIyAbK5pXpt2W1GAb3NRX68N4NjB47nkmlH9jskbF42wN)epWUYhtYyD9wwpfJbuOFCsN)JzKutJ9P5owtDWMOv1mNWyQ5KMWyQ5K6kk3MuLJlINotn)G1MX2FF1vrgK4KNtlDafSD8bwvU2vxrLFcOhceMtgK4KNtln3kE68)6HRytb2Reudul4(CnEVrH5Ny70RW2NdQzaaKmyGnanWBaizWEWaPGjLaYMOfqIptcifCpuTgiXtZjGKFITtVcBFoqYTjouXaz5EGmasEGDTwdQfCFUgV3OW8tSD6vy7ZTonnP4lJwytRNIXxSPY9zKgt52IqbRY)JNcZWNRHabFIj2Px6ESkWk)UewLFd(AiqQIF9sCC9tmrposQROk37InvnZFXMk3NrAmLBlcfSk)pEkmdFUUsqTG7Z149gfwetQXjtmOwW95A8EJc7F0gK4KgOmDMcBFoOwW95A8EJclIj14Kj26Pym)jMuz8LUUoW5e3vxr52KsWKwqGuMmBx9KzmnMrd3eul4(CnEVrHfXKACY06omjJbuW2Xhyv5AxDfv(jGERNIr(DP1jO1boN4U6kk3MucM0s)KzmnwLjsymJ13Q6YKz7QNmJPXwQ(MGAb3NRX7nkSiMuJtMw3HjzmW2mfnHvFaL7v87JK1tX4Iyflf9hq5Ef)(iPweRyPOfZRUkMtgK4KNtlDafSD8bwvU2vxrLFcOhce)NgQKRdOGTJpWQY1U6kQ8ta9A(DP1jO1pzgtJT0gB5qGqym1CsZMUBPUIYTjf1KPvAZy7VVYQRk)jMuz8LUUoW5e3vxr52KsWKwqGWCYGeN8CAP5wXtN)xpCfBkWE1SILIoW5e3vxr52KsWKw6NmJPXwQIQS6QyoHXuZjn)6f1yAPstHk3ZjTzS93dbcRyPOZeJFnrRUIkGc9NBRfZRS6Q84ZixBtrYT15CNrlSfeimNWyQ5KMF9IAmTuPPqL75K2m2(7HaH5EKO21qDsj6vtJ9P5ELqGu1Iyflf9hq5Ef)(iPweRyPOxNGgcKYKz7QNmJPXmAOLxz1LjZ2vpzgtJTuvgAWwMQ43LwNGwZTINo)VE4k2uGD9tMX049gmJLjZ2vpzgtJRSsqTG7Z149gfwetQXjtRPsH4UQdtYi3kE68)6HRytb2TEkgzflfnlH9jskbF4261jOHaPmz2U6jZyAmJBbQfCFUgV3OW8iLub3NRvPb7w3HjzKVWGAb3NRX7nkmpsjvW95AvAWU1DysgXU1tXyW9HjsrnzoeMrdb1cUpxJ3BuyEKsQG7Z1Q0GDR7WKmYtuWez9umgCFyIuutMdHTuDqnqTG7Z1ynFHngnNW(hjfpsjRNIr(DP1jO1Se2NiPe8HBRFYmMgBjlSjOwW95ASMVW7nkCzEInD3Y6PyKFxADcAnlH9jskbF426NmJPXwYcBcQfCFUgR5l8EJcZspMEOoDM1tXyvSILIwWKwkC(8JJ1I5qGWC(Xe1r76EYSDvjOQzflfDGZjURUIYTjLGjT0I5vZkwkAwc7tKuc(WT1I5vwDvLjZ2vpzgtJTe)U06e0Aw6X0d1PZ0lXp8569lXp85AiqQYJpJCTnfj3wNZDgTWwqGWCpsu7AOoPe9QPX(0CVYkHaPmz2U6jZyAmJ1TaOwW95ASMVW7nkmB6ULQi(wz9umwfRyPOfmPLcNp)4yTyoeimNFmrD0UUNmBxvcQAwXsrh4CI7QROCBsjyslTyE1SILIMLW(ejLGpCBTyELvxvzYSD1tMX0ylXVlTobTMnD3sveFR0lXp8569lXp85AiqQYJpJCTnfj3wNZDgTWwqGWCpsu7AOoPe9QPX(0CVYkHaPmz2U6jZyAmJ1TCqTG7Z1ynFH3Bu40Kz7y12lUYmP2b1cUpxJ18fEVrHZpFU26PyKvSu0boN4U6kk3MucM0slMdbszYSD1tMX0ygn0Yb1cUpxJ18fEVrHfCFAXenT6j81rZjRNIXQYFIjvgFPRRdCoXD1vuUnPemPfei87sRtqRdCoXD1vuUnPemPL(jZyAmJz8feiLjZ2vpzgtJz0WnReceMtym1CsZ0GNRvxrLtFH4(CT2C67b1cUpxJ18fEVrHZeJFnrRUIkGc9NBB9umYVlTobToW5e3vxr52KsWKw6NmJPXmwFtiqktMTREYmMgBj(DP1jO3Ve)WNRHaPmz2U6jZyAmJwytqTG7Z1ynFH3Bu4FYZtKAAfop4eOwW95ASMVW7nkSjzEVvQROsI8zPwpfMyqTG7Z1ynFH3Bu4NI8PZuLuysyRNIrp(mY12uKCBDo3T0gVjeiE8zKRTPi526CUZOrd3ecep(mY1(ysk)u5Cxz4MwYcBcQbQfCFUgR5jkyImg4CI7QROCBsjyslqTG7Z1ynprbt0EJcZgplTuy7ZTMBfprkp(mYXgRB9umMtU2mMwZkwk6YtnuSslMxDo5AZyAnRyPOlp1qXk9tMX0ygnMXxGAb3NRXAEIcMO9gf2um5d2(CRNIXm(YaoNCTzmTMvSu0SuGDfprbtK(jZyASL2uB4wGAb3NRXAEIcMO9gf2Jx5FKB9um(InvUpJ04tmvUpJuKjl94Q94v(h56NmJPXmMXxvZVlTobTUKIN0pzgtJzmJVa1cUpxJ18efmr7nkCjfpz9um6XR8pY1I5v)InvUpJ04tmvUpJuKjl9yqTG7Z1ynprbt0EJcVOWTvC7aQFyA9umwoUiEppWU6PmQzSCCrS2mSiOwW95ASMNOGjAVrHfmPLcNp)4yqTG7Z1ynprbt0EJcZgplTuy7ZTMBfprkp(mYXgRB9umwetj1tC74ZiLpMeJz8v187sRtqRzjSprsj4d3w)Kzmngce(DP1jO1Se2NiPe8HBRFYmMgZyDd3NXxv7rIAxJ5u7QROyt3Ta1cUpxJ18efmr7nkmlH9jskbF42GAb3NRXAEIcMO9gf(j81HpDMk()eaQfCFUgR5jkyI2BuyShM50ISEkgzflfDGZjURUIYTjLGjT0I5qGuMmBx9KzmnMX6BbQfCFUgR5jkyI2Bu4skSIwkS95GAb3NRXAEIcMO9gfgQtkPW2NdQfCFUgR5jkyI2BuyU9yg0hkS95GAb3NRXAEIcMO9gfMnD3cBtlqTG7Z1ynprbt0EJchktXFrV6kk(FcWGAb3NRXAEIcMO9gfMn(pYiRNIXCY1MX0AwXsrxEQHIv6NmJPXwISiXfDs5JjbQfCFUgR5jkyI2BuyOoPKIFMMrVSEkglhxeBj(H99b3NR1MIjFW2NR5h2b1cUpxJ18efmr7nkmBKPUIY)HdvS1tXiRyPOzjSprsj4d3wVobneiLjZ2vpzgtJzClqTG7Z1ynprbt0EJcVMNuSuGDqTG7Z1ynprbt0EJcZgplTuy7ZTMBfprkp(mYXgRB9um6XNrU2hts5NAneJveOwW95ASMNOGjAVrH5h7hkS95wpfJLJlI1(ysk)uMHfzmJVSmgcQfCFUgR5jkyI2BuypEL)rU1tX4l2u5(msJpXu5(msrMS0JHa5fBQCFgPBcJNotq8wHv(h55tNPI884dxedQfCFUgR5jkyI2Bu4YteuMot5FKB9um(InvUpJ0nHXtNjiERWk)J88PZurEE8HlIb1cUpxJ18efmr7nkC54IyAPcOq)4KILctqTG7Z1ynprbt0EJcNl(tXQPZuSPa7GAb3NRXAEIcMO9gfMFnNA)dNwQskmjqTG7Z1ynprbt0EJcZMUBPUIYTjf1KPvGAb3NRXAEIcMO9gf2TjLyZEI9svUNtwpfJSILI(joutegRk3ZjTyoeiSILI(joutegRk3Zjf)eBNEn2douzS(MGAGAb3NRXASBmW5e3vxr52KsWKwGAb3NRXASV3OWSXZslf2(CRNIXCY1MX0AwXsrxEQHIvAX8QZjxBgtRzflfD5PgkwPFYmMgZOXm(cul4(CnwJ99gf2Jx5FKB9um(InvUpJ04tmvUpJuKjl94Q94v(h56NmJPXmMXxvZVlTobTUKIN0pzgtJzmJVa1cUpxJ1yFVrHlP4jRNIrpEL)rUwmV6xSPY9zKgFIPY9zKImzPhdQfCFUgRX(EJcZMUBHTPfOwW95ASg77nkSGjTu485hhdQfCFUgRX(EJcxsHv0sHTphul4(CnwJ99gfgQtkPW2NB9umYkwk6skSIESYmEOQFYmMgZ4wqG4XNrU2MIKBRZ5oJgnCtqTG7Z1yn23Buy24zPLcBFU1tXi)U06e0Awc7tKuc(WT1pzgtJzSUHwgUD8zewv(G7Z1rAFgFvThjQDnMtTRUIInD3ccKIykPEIBhFgP8XKymJVQMFxADcAnlH9jskbF426NmJPXqG4XNrU2hts5NAneJveOwW95ASg77nk8Ic3wXTdO(HP1tXy54I498a7QNYOMXYXfXAZWIGAb3NRXASV3OWypmZPfz9umYkwk6aNtCxDfLBtkbtAPfZHaPmz2U6jZyAmJ13cul4(CnwJ99gfMFnNA)dNwQskmjRNIXYXfX7lhxeRFkJAltgFXy54IyTzyXQzflfnlH9jskbF4261jORUkMVoxZVMtT)HtlvjfMKIv8B9tMX04QzEW95An)Ao1(hoTuLuys6PvL0Kz7vcbsrmLupXTJpJu(ysmMXxqGuMmBx9KzmnMXTa1cUpxJ1yFVrHdLP4VOxDff)pbyqTG7Z1yn23Bu4NWxh(0zQ4)tG1tXiRyPOzjSprsj4d3wlMdbszYSD1tMX0ygRVjOwW95ASg77nkmlH9jskbF42wpfJ87sRtqRfmPLcNp)4y9tMX0ylvFliqyo)yI6ODDpz2UQeeeiLjZ2vpzgtJzS(wGAb3NRXASV3OWC7XmOpuy7Zb1cUpxJ1yFVrHlhxetlvaf6hNuSuyA9umYkwkAwc7tKuc(WT1RtqdbszYSD1tMX0yg3cul4(CnwJ99gf2TjLyZEI9svUNtwpfJSILI(joutegRk3ZjTyoeiSILI(joutegRk3Zjf)eBNEn2douzS(MqGuMmBx9KzmnMXTa1cUpxJ1yFVrHFcFD4tNPI)pbwpfJSILIMLW(ejLGpCBTyoeiLjZ2vpzgtJzS(MGAb3NRXASV3OWSe2NiPe8HBB9umYVlTobTwWKwkC(8JJ1pzgtJTu9TGaH58JjQJ219Kz7QsqqGuMmBx9KzmnMX6BbQfCFUgRX(EJcZThZG(qHTphul4(CnwJ99gfMnD3sDfLBtkQjtRSEkgzflfDGZjURUIYTjLGjT0pzgtJTu9n3NXxqGuMmBx9KzmnMX6BUpJVa1cUpxJ1yFVrHH6Ksk(zAg9cul4(CnwJ99gfMnYuxr5)WHk26PyKvSu0Se2NiPe8HBRxNGgcKYKz7QNmJPXmUfOwW95ASg77nk8AEsXsb2b1cUpxJ1yFVrH5h7hkS95wpfJvvoUi2aMFyFF54Iy9tzuBzQIFxADcAnuNusXptZOx6NmJPXgW1R0sb3NR1qDsjf)mnJEP5h2HaHFxADcAnuNusXptZOx6NmJPXwQ((m(QsiqQIvSu0Se2NiPe8HBRfZHaHvSu0nHXtNjiERWk)J88PZurEE8HlI1I5vwnZFXMk3NrAdkYtHIEAj2kbXRUFrpeiLjZ2vpzgtJz0cGAb3NRXASV3OWSXZslf2(CRNIrwXsrlyslfoF(XXAXCqTG7Z1yn23Bu445rtQCXeMSEkgzflfnlH9jskbF4261jOHaPmz2U6jZyAmJBbQfCFUgRX(EJc7XR8pYTEkgFXMk3NrA8jMk3NrkYKLEmeiVytL7ZiDty80zcI3kSY)ipF6mvKNhF4IyqTG7Z1yn23Bu4YteuMot5FKB9um(InvUpJ0nHXtNjiERWk)J88PZurEE8HlIrW4CIJG2WTSaYrocba]] )

end
