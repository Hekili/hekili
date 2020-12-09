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
            duration = 30,
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

    spec:RegisterHook( "reset_precast", function()
        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end
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

        potion = "spectral_agility",

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


    spec:RegisterPack( "Beast Mastery", 20201209, [[dWuitbqiuu9ickytss9jLsJssYPKeTkkrYRuQAwusUfbf1UO4xKcdtPOJjPAzKIEgLGPrjIRPuX2KeY3iOIXPuP6CeuADkfmpuO7rkTpkrDqjHYcjipuPqtKGcDrkrQpQujmsLkP4KscvRuszMscUPsLuTta1pjOsdvPskTuckYtbAQOGVQujzSOOCwLkr7fYFjzWeDyHfJspgvtwjxgzZs8zrz0uQtRy1kvkVgqA2ICBs1UL63QmCr1XjOQLRQNd10P66eA7OiFNaJNsOZtj16beZhG9dAuDediWv4ecyn3uZnRR5McRztH1cwIfQJaDRZjeyEWbAKriWo0jeOquGDOCxpWo9wJaZdRtxSqmGaXN4ZjeOT754nOHgzJBlYA4NUg4rxmf(Cn)JIRbE05AGazfNKxXBelcCfoHawZn1CZ6AUPWA2uyTGLybeyi623Jabh9nIaTN1IAelcCryocuyakfIcSdL76b2P3AOCxJy70dRjmaLcJeN0zPhkfwRGsn3uZnrGPb7yediWfvcXKJyabCDediWG7Z1iq(j2o9kS95iqQd2eTqcHCeWAIyabsDWMOfsieyW95Aei)eBNEf2(Cei)hN(jqGVytL7ZidMYTfbcwL)hpf6HpxBOoyt0ckbaakXNyID6LPhRdSYVlHv53GVgkbaakRck5xVeh38et0JJK6kQY9UytgQd2eTGYQHsMdLVytL7ZidMYTfbcwL)hpf6HpxBOoyt0ckRebMMMu8fc0cBICeWwaXacm4(CncuetQXjDmcK6GnrlKqihbSLGyabgCFUgb6F0cV4KgGmDMcBFocK6GnrlKqihb8oigqGuhSjAHecbY)XPFcey(tmPY4ltDtGZjURUIYTjLGjTGsaaGYYKz7QN0JPXqjJqPMBIadUpxJafXKACshJCeWveIbei1bBIwiHqGb3NRrGbqW2Xhyv5AxDfv(jGEei)hN(jqG87sRtqBcCoXD1vuUnPemPL5j9yASktKWyOKrOS(oqz1qzzYSD1t6X0yO0Yqz9nrGDOtiWaiy74dSQCTRUIk)eqpYralCqmGaPoyt0cjecm4(CncmW2mfnHvFaK7v87JecK)Jt)eiWfXkwkMpaY9k(9rsTiwXsXiMdLvdLvbLmhkjHxCYZPLjac2o(aRkx7QROYpb0dLaaaL87sRtqBcGGTJpWQY1U6kQ8ta9MN0JPXqPLHYDVIGsaaGscJPMtg20Dl1vuUnPOM0T2Oh729qzLqz1qzvqz(tmPY4ltDtGZjURUIYTjLGjTGsaaGsMdLKWlo550YWTMNo)VE4k2uGDOSAOKvSumboN4U6kk3MucM0Y8KEmngkTmukSqzLqz1qzvqjZHscJPMtg(1lQX0sLMcvUNtg9y3UhkbaakzflftMy8RjA1vubqO)CBJyouwjuwnuwfu6XNrUXMIKBBY5ouYiuAHDGsaaGsMdLegtnNm8RxuJPLknfQCpNm6XUDpucaauYCO0Je1UbOtkrVAASpn3nuhSjAbLvcLaaaLvbLlIvSumFaK7v87JKArSILIzDcAOeaaOSmz2U6j9yAmuYiuQzfbLvcLvdLLjZ2vpPhtJHsldLvbLAAjqPLckRck53LwNG2WTMNo)VE4k2uGDZt6X0yOCpuAjqjJqzzYSD1t6X0yOSsOSseyh6ecmW2mfnHvFaK7v87JeYraV7igqGuhSjAHecbgCFUgbYTMNo)VE4k2uGDei)hN(jqGSILIHLW(ejLGpCBZ6e0qjaaqzzYSD1t6X0yOKrOCheivke3vDOtiqU1805)1dxXMcSJCeWclIbei1bBIwiHqGb3NRrG8iLub3NRvPb7iW0GDvh6ecKVWihbC9nrmGaPoyt0cjecK)Jt)eiWG7dtKIAsFimuYiuQjcm4(CncKhPKk4(CTknyhbMgSR6qNqGyh5iGRxhXacK6GnrlKqiq(po9tGadUpmrkQj9HWqPLHY6iWG7Z1iqEKsQG7Z1Q0GDeyAWUQdDcbYtuWeHCKJaZFIF6SHJyabCDediWG7Z1iqSOU(1QCYrGuhSjAHec5iG1eXacK6GnrlKqiWo0jeyaeSD8bwvU2vxrLFcOhbgCFUgbgabBhFGvLRD1vu5Na6rocylGyabgCFUgbk4(0IjAA1t4RJMtiqQd2eTqcHCeWwcIbei1bBIwiHqG5pXdSR8rNqG1n7GadUpxJa94v(h5iq(po9tGaFXMk3Nrg8jMk3NrksNLESH6GnrlOeaaO8fBQCFgzAcJNotq8wJv(h55tNPI884dxeBOoyt0c5iG3bXacK6GnrlKqiW8N4b2v(OtiW6MDqGb3NRrGSe2NiPe8HBJa5)40pbcK5qPhjQDdMtTRUIInD3YqDWMOfuwnuYCO8fBQCFgzWNyQCFgPiDw6XgQd2eTqoc4kcXacm4(Cncmtm(1eT6kQai0FUncK6GnrlKqihbSWbXacm4(CncuN0V3A1vujr(SuRNcDmcK6GnrlKqihb8UJyabsDWMOfsieyW95Aei3AE68)6HRytb2rG8FC6NabYCO8JzPiMO2ntZKyQPpytKHS4GDmuwnuwfu6)0aLCtDJDGv87sRtqdL7Hs)NgOKB00yhyf)U06e0qjJqPMqjaaqjj8ItEoTmmf)eSjsnTtnECRvztwW0LC1H5tkf(0zQNcUFpuwjcKkfI7Qo0jei3AE68)6HRytb2rocyHfXacK6GnrlKqiq(po9tGazou(XSuetu7MPzsm10hSjYqwCWogbgCFUgbwoUiMwQai0poPyPqh5iGRVjIbei1bBIwiHqG5pXdSR8rNqG1nwabgCFUgbg4CI7QROCBsjyslei)hN(jqGmhkdGq)4Kj)h9iPMg7tZDSH6GnrlOSAOK5qjHXuZjdHXuZj1vuUnPkhxepDMA(bB0JD7EOSAOSkOKeEXjpNwMaiy74dSQCTRUIk)eqpucaauYCOKeEXjpNwgU1805)1dxXMcSdLvICeW1RJyabsDWMOfsiey(t8a7kF0jeyDZoiWG7Z1iqwc7tKuc(WTrG8FC6NabgaH(Xjt(p6rsnn2NM7yd1bBIwqz1qjZHscJPMtgcJPMtQROCBsvoUiE6m18d2Oh729qz1qzvqjj8ItEoTmbqW2Xhyv5AxDfv(jGEOeaaOK5qjj8ItEoTmCR5PZ)RhUInfyhkRe5ihbYxyediGRJyabsDWMOfsiei)hN(jqG87sRtqByjSprsj4d328KEmngkTmuAHnrGb3NRrGrZjS)rsXJuc5iG1eXacK6GnrlKqiq(po9tGa53LwNG2WsyFIKsWhUT5j9yAmuAzO0cBIadUpxJalZtSP7wihbSfqmGaPoyt0cjecK)Jt)eiWQGswXsXiyslfoF(XXgXCOeaaOK5qj)yI6ODtpz2UQeeuwnuYkwkMaNtCxDfLBtkbtAzeZHYQHswXsXWsyFIKsWhUTrmhkRekRgkRckltMTREspMgdLwgk53LwNG2WspMEGoDMzj(HpxdL7HYL4h(Cnucaauwfu6XNrUXMIKBBY5ouYiuAHDGsaaGsMdLEKO2naDsj6vtJ9P5UH6GnrlOSsOSsOeaaOSmz2U6j9yAmuYiuw3ciWG7Z1iqw6X0d0PZqocylbXacK6GnrlKqiq(po9tGaRckzflfJGjTu485hhBeZHsaaGsMdL8JjQJ2n9Kz7Qsqqz1qjRyPycCoXD1vuUnPemPLrmhkRgkzflfdlH9jskbF42gXCOSsOSAOSkOSmz2U6j9yAmuAzOKFxADcAdB6ULQi(wBwIF4Z1q5EOCj(HpxdLaaaLvbLE8zKBSPi52MCUdLmcLwyhOeaaOK5qPhjQDdqNuIE10yFAUBOoyt0ckRekRekbaakltMTREspMgdLmcL1RieyW95AeiB6ULQi(wJCeW7GyabgCFUgbMMmBhR2nXvMo1ocK6GnrlKqihbCfHyabsDWMOfsiei)hN(jqGSILIjW5e3vxr52KsWKwgXCOeaaOSmz2U6j9yAmuYiuQzfHadUpxJaZpFUg5iGfoigqGuhSjAHecbY)XPFceyvqz(tmPY4ltDtGZjURUIYTjLGjTGsaaGs(DP1jOnboN4U6kk3MucM0Y8KEmngkzekZ4lOeaaOSmz2U6j9yAmuYiuQ5MqzLqjaaqjZHscJPMtgMg8CT6kQC6le3NRn6tFpcm4(CncuW9Pft00QNWxhnNqoc4DhXacK6GnrlKqiq(po9tGa53LwNG2e4CI7QROCBsjyslZt6X0yOKrOS(MqjaaqzzYSD1t6X0yO0YqzW95Af)U06e0q5EOCj(HpxdLaaaLLjZ2vpPhtJHsgHslSjcm4(Cncmtm(1eT6kQai0FUnYralSigqGb3NRrG)KNNi10kCEWjei1bBIwiHqoc46BIyabgCFUgbQt63BT6kQKiFwQ1tHogbsDWMOfsiKJaUEDediqQd2eTqcHa5)40pbc0JpJCJnfj32KZDO0Yq5UVjucaau6XNrUXMIKBBY5ouYOwOuZnHsaaGsp(mYn(Otk)u5CxP5MqPLHslSjcm4(Cnc8PiF6mvjf6eg5ihbIDediGRJyabgCFUgbg4CI7QROCBsjyslei1bBIwiHqocynrmGaPoyt0cjecK)Jt)eiqwXsXuEQbI1gXCOSAOKvSumLNAGyT5j9yAmuYOwOmJVqGb3NRrGSXZslf2(CKJa2cigqGuhSjAHecbY)XPFce4l2u5(mYGpXu5(msr6S0JnuhSjAbLvdLE8k)JCZt6X0yOKrOmJVGYQHs(DP1jOnLu8K5j9yAmuYiuMXxiWG7Z1iqpEL)roYraBjigqGuhSjAHecbgCFUgbwsXtiq(po9tGa94v(h5gXCOSAO8fBQCFgzWNyQCFgPiDw6XgQd2eTqGPPjfFHa1ChKJaEhediWG7Z1iq20DlSnTqGuhSjAHec5iGRiediWG7Z1iqbtAPW5ZpogbsDWMOfsiKJaw4GyabgCFUgbwsH10sHTphbsDWMOfsiKJaE3rmGaPoyt0cjecK)Jt)eiqwXsXusH10Jv6XduZt6X0yOKrOChOeaaO0JpJCJnfj32KZDOKrTqPMBIadUpxJab6KskS95ihbSWIyabsDWMOfsiei)hN(jqG87sRtqByjSprsj4d328KEmngkzekRRjuAPGsUD8zewv(G7Z1rck3dLz8fuwnu6rIA3G5u7QROyt3TmuhSjAbLaaaLfXus9e3o(ms5JobLmcLz8fuwnuYVlTobTHLW(ejLGpCBZt6X0yOeaaO0JpJCJp6KYp1AiOKrOuyrGb3NRrGSXZslf2(CKJaU(MigqGuhSjAHecbY)XPFcey54IyOCpuYdSREkJAOKrOSCCrSrpSicm4(CncCrHBR42bq)qh5iGRxhXacK6GnrlKqiq(po9tGazflftGZjURUIYTjLGjTmI5qjaaqzzYSD1t6X0yOKrOS(oiWG7Z1iqSh650Iqoc46AIyabsDWMOfsiei)hN(jqGLJlIHY9qz54IyZtzudLwkOmJVGsgHYYXfXg9WIqz1qjRyPyyjSprsj4d32SobnuwnuwfuYCOCDUHFnNA)dNwQsk0jfR43MN0JPXqz1qjZHYG7Z1g(1CQ9pCAPkPqNmtRkPjZ2HYkHsaaGYIykPEIBhFgP8rNGsgHYm(ckbaakltMTREspMgdLmcL7GadUpxJa5xZP2)WPLQKcDc5iGRBbediWG7Z1iWqPl(l6vxrX)tagbsDWMOfsiKJaUULGyabsDWMOfsiei)hN(jqGSILIHLW(ejLGpCBJyoucaauwMmBx9KEmngkzekRVjcm4(Cnc8j81HpDMk()eGCeW13bXacK6GnrlKqiq(po9tGa53LwNG2iyslfoF(XXMN0JPXqPLHY67aLaaaLmhk5htuhTB6jZ2vLGGsaaGYYKz7QN0JPXqjJqz9DqGb3NRrGSe2NiPe8HBJCeW1RiediWG7Z1iqU9Oh0hkS95iqQd2eTqcHCeW1foigqGuhSjAHecbY)XPFceiRyPyyjSprsj4d32SobnucaauwMmBx9KEmngkzek3bbgCFUgbwoUiMwQai0poPyPqh5iGRV7igqGuhSjAHecbY)XPFceiRyPyEId0eHXQY9CYiMdLaaaLSILI5joqtegRk3Zjf)eBNEd2doqHsgHY6BcLaaaLLjZ2vpPhtJHsgHYDqGb3NRrGUnPeB2tSxQY9Cc5iGRlSigqGuhSjAHecbY)XPFceiRyPyyjSprsj4d32iMdLaaaLLjZ2vpPhtJHsgHY6BIadUpxJaFcFD4tNPI)pbihbSMBIyabsDWMOfsiei)hN(jqG87sRtqBemPLcNp)4yZt6X0yO0Yqz9DGsaaGsMdL8JjQJ2n9Kz7QsqqjaaqzzYSD1t6X0yOKrOS(oiWG7Z1iqwc7tKuc(WTrocynRJyabgCFUgbYTh9G(qHTphbsDWMOfsiKJawtnrmGaPoyt0cjecK)Jt)eiqwXsXe4CI7QROCBsjyslZt6X0yO0Yqz9nHY9qzgFbLaaaLLjZ2vpPhtJHsgHY6BcL7HYm(cbgCFUgbYMUBPUIYTjf1KU1ihbSMwaXacm4(CnceOtkP4NUE0lei1bBIwiHqocynTeediqQd2eTqcHa5)40pbcKvSumSe2NiPe8HBBwNGgkbaakltMTREspMgdLmcL7GadUpxJazJm1vu(pCGIrocyn3bXacm4(CncCnpPyPa7iqQd2eTqcHCeWAwrigqGuhSjAHecbY)XPFceyvqz54IyOuygk5h2HY9qz54IyZtzudLwkOSkOKFxADcAdqNusXpD9OxMN0JPXqPWmuwhkRekTmugCFU2a0jLu8txp6LHFyhkbaak53LwNG2a0jLu8txp6L5j9yAmuAzOSouUhkZ4lOSsOeaaOSkOKvSumSe2NiPe8HBBeZHsaaGswXsX0egpDMG4TgR8pYZNotf55XhUi2iMdLvcLvdLmhkFXMk3NrgHpYtHIEAj2kbXRUFrVH6GnrlOeaaOSmz2U6j9yAmuYiuAbeyW95Aei)y)qHTph5iG1u4GyabsDWMOfsiei)hN(jqGSILIrWKwkC(8JJnI5iWG7Z1iq24zPLcBFoYraR5UJyabsDWMOfsiei)hN(jqGSILIHLW(ejLGpCBZ6e0qjaaqzzYSD1t6X0yOKrOCheyW95Aey88OjvUyctihbSMclIbei1bBIwiHqG8FC6Nab(InvUpJm4tmvUpJuKol9yd1bBIwqjaaq5l2u5(mY0egpDMG4TgR8pYZNotf55XhUi2qDWMOfcm4(Cnc0Jx5FKJCeWwytediqQd2eTqcHa5)40pbc8fBQCFgzAcJNotq8wJv(h55tNPI884dxeBOoyt0cbgCFUgbwEIaY0zk)JCKJCeiprbteIbeW1rmGadUpxJadCoXD1vuUnPemPfcK6GnrlKqihbSMigqGuhSjAHecbgCFUgbYgplTuy7ZrG8FC6NabYkwkMYtnqS2iMdLvdLSILIP8udeRnpPhtJHsg1cLz8fcKBnprkp(mYXiGRJCeWwaXacK6GnrlKqiq(po9tGaZ4lOuygkzflfdlfyxXtuWezEspMgdLwgk30O5oiWG7Z1iqDXKpy7ZrocylbXacK6GnrlKqiq(po9tGaFXMk3Nrg8jMk3NrksNLESH6GnrlOSAO0Jx5FKBEspMgdLmcLz8fuwnuYVlTobTPKINmpPhtJHsgHYm(cbgCFUgb6XR8pYroc4DqmGaPoyt0cjecm4(CncSKINqG8FC6Nab6XR8pYnI5qz1q5l2u5(mYGpXu5(msr6S0JnuhSjAHatttk(cbQ5oihbCfHyabsDWMOfsiei)hN(jqGLJlIHY9qjpWU6PmQHsgHYYXfXg9WIiWG7Z1iWffUTIBha9dDKJaw4GyabgCFUgbkyslfoF(XXiqQd2eTqcHCeW7oIbei1bBIwiHqGb3NRrGSXZslf2(Cei)hN(jqGfXus9e3o(ms5JobLmcLz8fuwnuYVlTobTHLW(ejLGpCBZt6X0yOeaaOKFxADcAdlH9jskbF42MN0JPXqjJqzDnHY9qzgFbLvdLEKO2nyo1U6kk20Dld1bBIwiqU18eP84ZihJaUoYralSigqGb3NRrGSe2NiPe8HBJaPoyt0cjeYraxFtediWG7Z1iWNWxh(0zQ4)tacK6GnrlKqihbC96igqGuhSjAHecbY)XPFceiRyPycCoXD1vuUnPemPLrmhkbaakltMTREspMgdLmcL13bbgCFUgbI9qpNweYraxxtediWG7Z1iWskSMwkS95iqQd2eTqcHCeW1TaIbeyW95AeiqNusHTphbsDWMOfsiKJaUULGyabgCFUgbYTh9G(qHTphbsDWMOfsiKJaU(oigqGb3NRrGSP7wyBAHaPoyt0cjeYraxVIqmGadUpxJadLU4VOxDff)pbyei1bBIwiHqoc46chediqQd2eTqcHa5)40pbcKvSumLNAGyT5j9yAmuAzOKSiXfDs5JoHadUpxJazJ)Jmc5iGRV7igqGuhSjAHecbY)XPFcey54IyO0Yqj)WouUhkdUpxB0ft(GTp3WpSJadUpxJab6Ksk(PRh9c5iGRlSigqGuhSjAHecbY)XPFceiRyPyyjSprsj4d32SobnucaauwMmBx9KEmngkzek3bbgCFUgbYgzQRO8F4afJCeWAUjIbeyW95Ae4AEsXsb2rGuhSjAHec5iG1SoIbei1bBIwiHqGb3NRrGSXZslf2(Cei)hN(jqGE8zKB8rNu(PwdbLmcLclcKBnprkp(mYXiGRJCeWAQjIbei1bBIwiHqG8FC6NabwoUi24JoP8tPhwekzekZ4lO0sbLAIadUpxJa5h7hkS95ihbSMwaXacK6GnrlKqiq(po9tGaFXMk3Nrg8jMk3NrksNLESH6GnrlOeaaO8fBQCFgzAcJNotq8wJv(h55tNPI884dxeBOoyt0cbgCFUgb6XR8pYrocynTeediqQd2eTqcHa5)40pbc8fBQCFgzAcJNotq8wJv(h55tNPI884dxeBOoyt0cbgCFUgbwEIaY0zk)JCKJawZDqmGadUpxJalhxetlvae6hNuSuOJaPoyt0cjeYraRzfHyabgCFUgbMl(tX6PZuSPa7iqQd2eTqcHCeWAkCqmGadUpxJa5xZP2)WPLQKcDcbsDWMOfsiKJawZDhXacm4(CncKnD3sDfLBtkQjDRrGuhSjAHec5iG1uyrmGaPoyt0cjecK)Jt)eiqwXsX8ehOjcJvL75KrmhkbaakzflfZtCGMimwvUNtk(j2o9gShCGcLmcL13ebgCFUgb62KsSzpXEPk3ZjKJCKJazIE8Cncyn3uZnRR5M7GafeFpDggbURQyctaxXbExSbOekzWMGYrp)Ehkl3dLBxujet(wO8jHxCEAbL4tNGYq0p9WPfuYTJoJWgyTkmnbLAUbOCJxZe9oTGYTVytL7ZidZ2cL(bLBFXMk3NrgMzOoyt0AluwvDlwPbwRcttqPMBak341mrVtlOC7l2u5(mYWSTqPFq52xSPY9zKHzgQd2eT2cLvv3IvAG1QW0euQ5gGYnEnt070ck3YVEjoUHzBHs)GYT8RxIJByMH6GnrRTqzv1TyLgyTkmnbLcNnaLB8AMO3PfuU1Je1UHzBHs)GYTEKO2nmZqDWMO1wOSQ6wSsdSwfMMGsHZgGYnEnt070ck36)0aLCdZm87sRtqVfk9dk3YVlTobTHzBHYQQBXknWAWA7QkMWeWvCG3fBakHsgSjOC0ZV3HYY9q528N4NoB4BHYNeEX5PfuIpDckdr)0dNwqj3o6mcBG1QW0euAjBak341mrVtlOC7l2u5(mYWSTqPFq52xSPY9zKHzgQd2eT2cLHdLwAHBfGYQQBXknWAvyAckTKnaLB8AMO3PfuU9fBQCFgzy2wO0pOC7l2u5(mYWmd1bBIwBHYQQBXknWAvyAck3zdq5gVMj6DAbLB9irTBy2wO0pOCRhjQDdZmuhSjATfkRQUfR0aRvHPjOCNnaLB8AMO3PfuU9fBQCFgzy2wO0pOC7l2u5(mYWmd1bBIwBHYWHslTWTcqzv1TyLgynyTDvftyc4koW7InaLqjd2euo6537qz5EOClFH3cLpj8IZtlOeF6eugI(PhoTGsUD0ze2aRvHPjO0cBak341mrVtlOCRhjQDdZ2cL(bLB9irTByMH6GnrRTqzv1TyLgyTkmnbLwYgGYnEnt070ck36rIA3WSTqPFq5wpsu7gMzOoyt0AluwvDlwPbwdwBxvXeMaUId8UydqjuYGnbLJE(9ouwUhk3I9Tq5tcV480ckXNobLHOF6HtlOKBhDgHnWAvyAck1Cdq5gVMj6DAbLBZj3WmZU0ymBHs)GYT7sJXSfkRstlwPbwRcttqPf2auUXRzIENwq52xSPY9zKHzBHs)GYTVytL7ZidZmuhSjATfkRQUfR0aRvHPjO0s2auUXRzIENwq52xSPY9zKHzBHs)GYTVytL7ZidZmuhSjATfkdhkT0c3kaLvv3IvAG1QW0eukSBak341mrVtlOCRhjQDdZ2cL(bLB9irTByMH6GnrRTqzv1TyLgyTkmnbLAwrBak341mrVtlOC7l2u5(mYWSTqPFq52xSPY9zKHzgQd2eT2cLvv3IvAG1QW0euQPWUbOCJxZe9oTGYTVytL7ZidZ2cL(bLBFXMk3NrgMzOoyt0AlugouAPfUvakRQUfR0aRvHPjOutHDdq5gVMj6DAbLBFXMk3NrgMTfk9dk3(InvUpJmmZqDWMO1wOSQ6wSsdSwfMMGslS5gGYnEnt070ck3(InvUpJmmBlu6huU9fBQCFgzyMH6GnrRTqz4qPLw4wbOSQ6wSsdSgS2UQIjmbCfh4DXgGsOKbBckh987DOSCpuULNOGjAlu(KWlopTGs8Ptqzi6NE40ck52rNrydSwfMMGsn3auUXRzIENwq52CYnmZSlngZwO0pOC7U0ymBHYQ00IvAG1QW0euAHnaLB8AMO3PfuUnNCdZm7sJXSfk9dk3UlngZwOSQ6wSsdSwfMMGslzdq5gVMj6DAbLBFXMk3NrgMTfk9dk3(InvUpJmmZqDWMO1wOSQ6wSsdSwfMMGYD2auUXRzIENwq52xSPY9zKHzBHs)GYTVytL7ZidZmuhSjATfkdhkT0c3kaLvv3IvAG1QW0euU7Bak341mrVtlOCRhjQDdZ2cL(bLB9irTByMH6GnrRTqz4qPLw4wbOSQ6wSsdSwfMMGY6cNnaLB8AMO3PfuUnNCdZm7sJXSfk9dk3UlngZwOSQ6wSsdSwfMMGsnTWgGYnEnt070ck3(InvUpJmmBlu6huU9fBQCFgzyMH6GnrRTqz4qPLw4wbOSQ6wSsdSwfMMGsnTWgGYnEnt070ck3(InvUpJmmBlu6huU9fBQCFgzyMH6GnrRTqzv1TyLgyTkmnbLAAjBak341mrVtlOC7l2u5(mYWSTqPFq52xSPY9zKHzgQd2eT2cLHdLwAHBfGYQQBXknWAWAvC987DAbL7aLb3NRHY0GDSbwdbIZjocyn3XciW8)ktIqGcdqPquGDOCxpWo9wdL7AeBNEynHbOuyK4Kol9qPWAfuQ5MAUjSgSwW95ASj)j(PZg(ETAGf11VwLtoSwW95ASj)j(PZg(ETAiIj14KUvDOtAdGGTJpWQY1U6kQ8ta9WAb3NRXM8N4NoB471QHG7tlMOPvpHVoAobRfCFUgBYFIF6SHVxRgE8k)JCRYFIhyx5JoPTUzhRMI2xSPY9zKbFIPY9zKI0zPhdaWl2u5(mY0egpDMG4TgR8pYZNotf55XhUigwl4(Cn2K)e)0zdFVwnyjSprsj4d32Q8N4b2v(OtARB2XQPOL5EKO2nyo1U6kk20DRQz(l2u5(mYGpXu5(msr6S0JH1cUpxJn5pXpD2W3RvJmX4xt0QROcGq)52WAb3NRXM8N4NoB471QHoPFV1QROsI8zPwpf6yyTG7Z1yt(t8tNn89A1qetQXjDROsH4UQdDsl3AE68)6HRytb2TAkAz(hZsrmrTBMMjXutFWMidzXb74QRY)Pbk5M6g7aR43LwNGEV)tduYnAASdSIFxADcAg1eaas4fN8CAzyk(jytKAANA84wRYMSGPl5QdZNuk8PZupfC)(kH1cUpxJn5pXpD2W3RvJYXfX0sfaH(Xjflf6wnfTm)JzPiMO2ntZKyQPpytKHS4GDmSMWauwXw7Mi2XqPBtq5s8dFUgkJEbL87sRtqdLxbkRy4CI7q5vGs3MGYD1Kwqz0lOCx7p6rckR4n2NM7yOK1AO0TjOCj(HpxdLxbkJgkfB7a70ck3fBuyekfytnu62K1BFckfX0ckZFIF6SHBGsHiEiIjOSIHZjUdLxbkDBck3vtAbLpTe5egk3fBuyekzTgk1CZn1XwbLU9GHYbdL1nwakXe)6f2aRfCFUgBYFIF6SHVxRgboN4U6kk3MucM0YQ8N4b2v(OtARBSGvtrlZdGq)4Kj)h9iPMg7tZDSH6GnrRQzoHXuZjdHXuZj1vuUnPkhxepDMA(bB0JD7(QRIeEXjpNwMaiy74dSQCTRUIk)eqpaamNeEXjpNwgU1805)1dxXMcSxjSMWauwXw7Mi2XqPBtq5s8dFUgkJEbL87sRtqdLxbkfIW(ejOCx9HBdLrVGYDnbqiO8kqPWuKrqjR1qPBtq5s8dFUgkVcugnuk22b2PfuUl2OWiukWMAO0TjR3(eukIPfuM)e)0zd3aRfCFUgBYFIF6SHVxRgSe2NiPe8HBBv(t8a7kF0jT1n7y1u0gaH(Xjt(p6rsnn2NM7yd1bBIwvZCcJPMtgcJPMtQROCBsvoUiE6m18d2Oh729vxfj8ItEoTmbqW2Xhyv5AxDfv(jGEaayoj8ItEoTmCR5PZ)RhUInfyVsynyTG7Z149A1GFITtVcBFoSMWauYGWvyu4UbOKb7bdLcMuckBIwqj(0jOuW9a1kOepnNGs(j2o9kS95qj3M4afdLL7HYak5b2ngdSwW95A8ETAWpX2PxHTp3Q00KIV0AHnTAkAFXMk3NrgmLBlceSk)pEk0dFUgaa8jMyNEz6X6aR87syv(n4RbaOk(1lXXnpXe94iPUIQCVl2u1m)fBQCFgzWuUTiqWQ8)4Pqp856kH1cUpxJ3RvdrmPgN0XWAb3NRX71QH)rl8ItAaY0zkS95WAb3NRX71QHiMuJt6yRMI28NysLXxM6MaNtCxDfLBtkbtAbaqzYSD1t6X0yg1CtyTG7Z149A1qetQXjDR6qN0gabBhFGvLRD1vu5Na6TAkA53LwNG2e4CI7QROCBsjyslZt6X0yvMiHXmwFNQltMTREspMgB56BcRfCFUgVxRgIysnoPBvh6K2aBZu0ew9bqUxXVpswnfTlIvSumFaK7v87JKArSILIrmV6Qyoj8ItEoTmbqW2Xhyv5AxDfv(jGEaa8FAGsUjac2o(aRkx7QROYpb0B43LwNG28KEmn2Y7EfbaaHXuZjdB6UL6kk3Muut6wB0JD7(kRUQ8NysLXxM6MaNtCxDfLBtkbtAbaaZjHxCYZPLHBnpD(F9WvSPa7vZkwkMaNtCxDfLBtkbtAzEspMgBzHTYQRI5egtnNm8RxuJPLknfQCpNm6XUDpaaSILIjtm(1eT6kQai0FUTrmVYQRYJpJCJnfj32KZDgTWoaaWCcJPMtg(1lQX0sLMcvUNtg9y3UhaaM7rIA3a0jLOxnn2NM7vcaqvlIvSumFaK7v87JKArSILIzDcAaaktMTREspMgZOMvuLvxMmBx9KEmn2YvPPLyPQIFxADcAd3AE68)6HRytb2npPhtJ3BjmwMmBx9KEmnUYkH1cUpxJ3RvdrmPgN0TIkfI7Qo0jTCR5PZ)RhUInfy3QPOLvSumSe2NiPe8HBBwNGgaGYKz7QN0JPXmUdSwW95A8ETAWJusfCFUwLgSBvh6Kw(cdRfCFUgVxRg8iLub3NRvPb7w1HoPf7wnfTb3hMif1K(qyg1ewl4(CnEVwn4rkPcUpxRsd2TQdDslprbtKvtrBW9HjsrnPpe2Y1H1G1cUpxJn8fwB0Cc7FKu8iLSAkA53LwNG2WsyFIKsWhUT5j9yASLTWMWAb3NRXg(cVxRgL5j20DlRMIw(DP1jOnSe2NiPe8HBBEspMgBzlSjSwW95ASHVW71Qbl9y6b60zwnfTvXkwkgbtAPW5Zpo2iMdaaZ5htuhTB6jZ2vLGQMvSumboN4U6kk3MucM0YiMxnRyPyyjSprsj4d32iMxz1vvMmBx9KEmn2Y87sRtqByPhtpqNoZSe)WNR3Ve)WNRbaOkp(mYn2uKCBto3z0c7aaaZ9irTBa6Ks0RMg7tZ9kReaGYKz7QN0JPXmw3cWAb3NRXg(cVxRgSP7wQI4BTvtrBvSILIrWKwkC(8JJnI5aaWC(Xe1r7MEYSDvjOQzflftGZjURUIYTjLGjTmI5vZkwkgwc7tKuc(WTnI5vwDvLjZ2vpPhtJTm)U06e0g20Dlvr8T2Se)WNR3Ve)WNRbaOkp(mYn2uKCBto3z0c7aaaZ9irTBa6Ks0RMg7tZ9kReaGYKz7QN0JPXmwVIG1cUpxJn8fEVwnstMTJv7M4ktNAhwl4(Cn2Wx49A1i)85ARMIwwXsXe4CI7QROCBsjyslJyoaaLjZ2vpPhtJzuZkcwl4(Cn2Wx49A1qW9Pft00QNWxhnNSAkARk)jMuz8LPUjW5e3vxr52KsWKwaaWVlTobTjW5e3vxr52KsWKwMN0JPXmMXxaauMmBx9KEmnMrn3SsaayoHXuZjdtdEUwDfvo9fI7Z1g9PVhwl4(Cn2Wx49A1itm(1eT6kQai0FUTvtrl)U06e0MaNtCxDfLBtkbtAzEspMgZy9nbaOmz2U6j9yASL53LwNGE)s8dFUgaGYKz7QN0JPXmAHnH1cUpxJn8fEVwn(jpprQPv48GtWAb3NRXg(cVxRg6K(9wRUIkjYNLA9uOJH1cUpxJn8fEVwnEkYNotvsHoHTAkA94Zi3ytrYTn5C3Y7(Maa4XNrUXMIKBBY5oJA1Ctaa84Zi34JoP8tLZDLMBAzlSjSgSwW95ASHNOGjsBGZjURUIYTjLGjTG1cUpxJn8efmr71QbB8S0sHTp3kU18eP84ZihRTUvtrBo5g9yAdRyPykp1aXAJyE15KB0JPnSILIP8udeRnpPhtJzuBgFbRfCFUgB4jkyI2RvdDXKpy7ZTAkAZ4lH5CYn6X0gwXsXWsb2v8efmrMN0JPXwEtJM7aRfCFUgB4jkyI2RvdpEL)rUvtr7l2u5(mYGpXu5(msr6S0JR2Jx5FKBEspMgZygFvn)U06e0MskEY8KEmnMXm(cwl4(Cn2WtuWeTxRgLu8KvPPjfFPvZDSAkA94v(h5gX8QFXMk3Nrg8jMk3NrksNLEmSwW95ASHNOGjAVwnwu42kUDa0p0TAkAlhxeVNhyx9ug1mwoUi2Ohwewl4(Cn2WtuWeTxRgcM0sHZNFCmSwW95ASHNOGjAVwnyJNLwkS95wXTMNiLhFg5yT1TAkAlIPK6jUD8zKYhDIXm(QA(DP1jOnSe2NiPe8HBBEspMgdaa)U06e0gwc7tKuc(WTnpPhtJzSUM7Z4RQ9irTBWCQD1vuSP7wWAb3NRXgEIcMO9A1GLW(ejLGpCByTG7Z1ydprbt0ETA8e(6WNotf)FcG1cUpxJn8efmr71Qb2d9CArwnfTSILIjW5e3vxr52KsWKwgXCaaktMTREspMgZy9DG1cUpxJn8efmr71Qrjfwtlf2(CyTG7Z1ydprbt0ETAa0jLuy7ZH1cUpxJn8efmr71Qb3E0d6df2(CyTG7Z1ydprbt0ETAWMUBHTPfSwW95ASHNOGjAVwncLU4VOxDff)pbyyTG7Z1ydprbt0ETAWg)hzKvtrBo5g9yAdRyPykp1aXAZt6X0yltwK4IoP8rNG1cUpxJn8efmr71QbqNusXpD9OxwnfTLJlITm)W((G7Z1gDXKpy7Zn8d7WAb3NRXgEIcMO9A1GnYuxr5)Wbk2QPOLvSumSe2NiPe8HBBwNGgaGYKz7QN0JPXmUdSwW95ASHNOGjAVwnwZtkwkWoSwW95ASHNOGjAVwnyJNLwkS95wXTMNiLhFg5yT1TAkA94Zi34JoP8tTgIrHfwl4(Cn2WtuWeTxRg8J9df2(CRMI2YXfXgF0jLFk9WImMXxwknH1cUpxJn8efmr71QHhVY)i3QPO9fBQCFgzWNyQCFgPiDw6Xaa8InvUpJmnHXtNjiERXk)J88PZurEE8HlIH1cUpxJn8efmr71Qr5jcitNP8pYTAkAFXMk3NrMMW4PZeeV1yL)rE(0zQipp(WfXWAb3NRXgEIcMO9A1OCCrmTubqOFCsXsHoSwW95ASHNOGjAVwnYf)Py90zk2uGDyTG7Z1ydprbt0ETAWVMtT)Htlvjf6eSwW95ASHNOGjAVwnyt3Tuxr52KIAs3AyTG7Z1ydprbt0ETA42KsSzpXEPk3ZjRMIwwXsX8ehOjcJvL75KrmhaawXsX8ehOjcJvL75KIFITtVb7bhOmwFtynyTG7Z1yd21g4CI7QROCBsjyslyTG7Z1yd23Rvd24zPLcBFUvtrBo5g9yAdRyPykp1aXAJyE15KB0JPnSILIP8udeRnpPhtJzuBgFbRfCFUgBW(ETA4XR8pYTAkAFXMk3Nrg8jMk3NrksNLEC1E8k)JCZt6X0ygZ4RQ53LwNG2usXtMN0JPXmMXxWAb3NRXgSVxRgLu8KvPPjfFPvZDSAkA94v(h5gX8QFXMk3Nrg8jMk3NrksNLEmSwW95ASb771QbB6Uf2MwWAb3NRXgSVxRgcM0sHZNFCmSwW95ASb771Qrjfwtlf2(CyTG7Z1yd23RvdGoPKcBFUvtrlRyPykPWA6Xk94bQ5j9yAmJ7aaGhFg5gBksUTjN7mQvZnH1cUpxJnyFVwnyJNLwkS95wnfT87sRtqByjSprsj4d328KEmnMX6AAP42XNryv5dUpxhP9z8v1EKO2nyo1U6kk20DlaakIPK6jUD8zKYhDIXm(QA(DP1jOnSe2NiPe8HBBEspMgdaGhFg5gF0jLFQ1qmkSWAb3NRXgSVxRglkCBf3oa6h6wnfTLJlI3ZdSREkJAglhxeB0dlcRfCFUgBW(ETAG9qpNwKvtrlRyPycCoXD1vuUnPemPLrmhaGYKz7QN0JPXmwFhyTG7Z1yd23Rvd(1CQ9pCAPkPqNSAkAlhxeVVCCrS5PmQTuz8fJLJlIn6HfRMvSumSe2NiPe8HBBwNGU6Qy(6Cd)Ao1(hoTuLuOtkwXVnpPhtJRM5b3NRn8R5u7F40svsHozMwvstMTxjaafXus9e3o(ms5JoXygFbaqzYSD1t6X0yg3bwl4(Cn2G99A1iu6I)IE1vu8)eGH1cUpxJnyFVwnEcFD4tNPI)pbwnfTSILIHLW(ejLGpCBJyoaaLjZ2vpPhtJzS(MWAb3NRXgSVxRgSe2NiPe8HBB1u0YVlTobTrWKwkC(8JJnpPhtJTC9DaaG58JjQJ2n9Kz7QsqaauMmBx9KEmnMX67aRfCFUgBW(ETAWTh9G(qHTphwl4(Cn2G99A1OCCrmTubqOFCsXsHUvtrlRyPyyjSprsj4d32SobnaaLjZ2vpPhtJzChyTG7Z1yd23Rvd3MuIn7j2lv5Eoz1u0YkwkMN4anrySQCpNmI5aaWkwkMN4anrySQCpNu8tSD6nyp4aLX6BcaqzYSD1t6X0yg3bwl4(Cn2G99A14j81HpDMk()ey1u0Ykwkgwc7tKuc(WTnI5aauMmBx9KEmnMX6BcRfCFUgBW(ETAWsyFIKsWhUTvtrl)U06e0gbtAPW5Zpo28KEmn2Y13baaMZpMOoA30tMTRkbbaqzYSD1t6X0ygRVdSwW95ASb771Qb3E0d6df2(CyTG7Z1yd23Rvd20Dl1vuUnPOM0T2QPOLvSumboN4U6kk3MucM0Y8KEmn2Y13CFgFbaqzYSD1t6X0ygRV5(m(cwl4(Cn2G99A1aOtkP4NUE0lyTG7Z1yd23Rvd2itDfL)dhOyRMIwwXsXWsyFIKsWhUTzDcAaaktMTREspMgZ4oWAb3NRXgSVxRgR5jflfyhwl4(Cn2G99A1GFSFOW2NB1u0wv54IyHz(H99LJlInpLrTLQk(DP1jOnaDsjf)01JEzEspMglmxVslhCFU2a0jLu8txp6LHFyhaa(DP1jOnaDsjf)01JEzEspMgB567Z4RkbaOkwXsXWsyFIKsWhUTrmhaawXsX0egpDMG4TgR8pYZNotf55XhUi2iMxz1m)fBQCFgze(ipfk6PLyReeV6(f9aauMmBx9KEmnMrlaRfCFUgBW(ETAWgplTuy7ZTAkAzflfJGjTu485hhBeZH1cUpxJnyFVwnINhnPYftyYQPOLvSumSe2NiPe8HBBwNGgaGYKz7QN0JPXmUdSwW95ASb771QHhVY)i3QPO9fBQCFgzWNyQCFgPiDw6Xaa8InvUpJmnHXtNjiERXk)J88PZurEE8HlIH1cUpxJnyFVwnkpraz6mL)rUvtr7l2u5(mY0egpDMG4TgR8pYZNotf55XhUig5ihHa]] )

end
