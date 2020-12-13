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


    spec:RegisterPack( "Beast Mastery", 20201213, [[dWej)aqisL6rsqYMuk1NevnkLIoLsjRscQ6vGIzrQYTuQuSls(fkvdJuWXKqldLYZavzAKkPRPuyBsq5Bsq04KGuNdLewhPIMhPO7rkTpLk5GOKOfIs8qsv1evQu6IKkWhjvcJuccCssfYkfvMjPq3uccTtLQ(PsLQHkbbTujOYtbzQGsFLujASkvCwsfQ9c5VcnyuDyQwmkEmrtwsxgzZk5ZcmAj60sTAsf0Rbv1Sf52IYUv8BvnCbDCusA5Q8COMoLRtW2bv(oHmEusDEjW6jvL5tO2pWOIiyrqv3i0E20aBAOiBfHNQi80WgWtxrqwbHeck0LW3die04zecIfYXgGxi6yJUcqqHEbP3Riyrq4x4KecQ0SqSozN9G2kfyuYpJDCNjKCR)rE(Yyh3zs2rqmcDY0rdIbbvDJq7ztdSPHISveEQIWtdBap4HGCbR8peeuNPFeuzxR0GyqqvclrqfkaNfYXgGxi6yJUca8cbcJrhixHcW3TKKYyOdWlcp9aC20aBAabLASHrWIGQ0Yfsgcw0(IiyrqU06FqqYxym6I4Y3qq04mjQIybzO9SHGfbrJZKOkIfeKlT(heK8fgJUiU8neK8AJU2rqNWqR)cifMclf0hogEVm5zU1)OOXzsufWflgWXVqIPNQA6cCC0(pHJHFJ)bWflgW3eWL)ufAtDeC0H9u8xX1FMWqkACMevb8TbCDd4NWqR)cifMclf0hogEVm5zU1)OOXzsufW3cbL6HIYkccEAazO9WdblcYLw)dcsatX2OmmcIgNjrvelidTxxrWIGCP1)GGSZhwvOtT(6jiIlFdbrJZKOkIfKH2VbcweenotIQiwqqYRn6AhbfEeCXazvvu54qsAXFfTskkQtvaxSyaF1bLw8OmVhmGRjGZMgqqU06Fqqcyk2gLHrgAFHHGfbrJZKOkIfeKlT(heK0tPOlT(NyQXgck1yloEgHGKvmYq7lKiyrq04mjQIybbjV2ORDeKlTgoksdL1egW1eWzdb5sR)bbj9uk6sR)jMASHGsn2IJNriiSHm0(cncweenotIQiwqqYRn6Ahb5sRHJI0qznHb8Db4frqU06FqqspLIU06FIPgBiOuJT44zecsMihoczidbfEK8ZyCdblAFreSiixA9piiSqw2pXqYqq04mjQIybzO9SHGfb5sR)bbX8MLOACL8cOQOEcI2Z6Eqq04mjQIybzO9WdblcIgNjrveliOXZieKRpCPFooU(XI)kg(IOdb5sR)bb56dx6NJJRFS4VIHVi6qgAVUIGfbrJZKOkIfeu4rshBrRZieur1giixA9piiZVODEicsETrx7iOtyO1FbKc)cP1FbuKYyOdROXzsufWflgWpHHw)fqQHW4Ece5xb4ODEyypbrpm0p3eWkACMevrgA)giyrq04mjQIybbfEK0Xw06mcbvuTbcYLw)dcIHWw7POOZTseK8AJU2rq6gWnprJPWsAS4VImP)RkACMevb8TbCDd4NWqR)cif(fsR)cOiLXqhwrJZKOkYq7lmeSiiACMevrSGGCP1)GGKfitVD)0YitYXgcsETrx7iiDd4N31ibhnMQh4esdDotIueRBSHb8Tb8nbC76b(KPkQkDCu(FQ(Igahga3UEGpzk2uLook)pvFrdGRjGZgGlwmGtSQqhgsvfC(1otII9y0GBRGyqh4W9jl(yzNsU1tq8ixA)b4BHGO1IKwC8mcbjlqME7(PLrMKJnKH2xirWIGOXzsufXcck8iPJTO1zecQOcEiixA9piihhssl(ROvsrrDQIGKxB01ocs3aURp6AJuHxN5PypyRhPHv04mjQc4Bd46gWjmMgjPimMgjf)v0kP46Lc4EcI91yvMRd)dW3gW3eWjwvOddPQY1hU0phhx)yXFfdFr0b4Ifd46gWjwvOddPQswGm929tlJmjhBa(widTVqJGfbrJZKOkIfeu4rshBrRZieur1giixA9piigcBTNIIo3krqYRn6Ahb56JU2iv41zEk2d26rAyfnotIQa(2aUUbCcJPrskcJPrsXFfTskUEPaUNGyFnwL56W)a8Tb8nbCIvf6WqQQC9Hl9ZXX1pw8xXWxeDaUyXaUUbCIvf6WqQQKfitVD)0YitYXgGVfYqgcswXiyr7lIGfbrJZKOkIfeK8AJU2rqY)t1x0OyiS1Ekk6CRuDuM3dgW3fGdpnGGCP1)GG8rsy78uu6PeYq7zdblcIgNjrvelii51gDTJGK)NQVOrXqyR9uu05wP6OmVhmGVlahEAab5sR)bbT6Jys)xrgAp8qWIGOXzsufXccsETrx7iOnbCgH1sjQt1ioSV2WkHqaxSyax3aU8HJgFm10bLwC5eGVnGZiSwkhhssl(ROvsrrDQQecb8TbCgH1sXqyR9uu05wPsieW3cW3gW3eWxDqPfpkZ7bd47cWL)NQVOrXqhMo43tGQkCU1)a4Wa4vHZT(haxSyaFta38lGmvj5jRufknaxtahEBa4Ifd46gWnprJPGFNs0f7bB9infnotIQa(wa(waUyXa(QdkT4rzEpyaxtaVi8qqU06Fqqm0HPd(9eGm0EDfblcIgNjrvelii51gDTJG2eWzewlLOovJ4W(AdRecbCXIbCDd4YhoA8XuthuAXLta(2aoJWAPCCijT4VIwjff1PQsieW3gWzewlfdHT2trrNBLkHqaFlaFBaFtaF1bLw8OmVhmGVlax(FQ(Igft6)ACjCfOQcNB9paomaEv4CR)bWflgW3eWn)citvsEYkvHsdW1eWH3gaUyXaUUbCZt0yk43PeDXEWwpstrJZKOkGVfGVfGlwmGV6GslEuM3dgW1eWlwyiixA9piiM0)14s4kazO9BGGfb5sR)bbL6Gsdh1Hc1GmAmeenotIQiwqgAFHHGfbrJZKOkIfeK8AJU2rqmcRLYXHK0I)kALuuuNQkHqaxSyaF1bLw8OmVhmGRjGZwHHGCP1)GGcFR)bzidbHneSO9frWIGCP1)GGCCijT4VIwjff1PkcIgNjrvelidTNneSiiACMevrSGGKxB01ocIryTuRJg9vGsieW3gWzewl16OrFfOokZ7bd4AQfWdKveKlT(heeJFmunIlFdzO9WdblcIgNjrvelii51gDTJGoHHw)fqk8lKw)fqrkJHoSIgNjrvaFBa38lANhQokZ7bd4Ac4bYkGVnGl)pvFrJAL8JuhL59GbCnb8azfb5sR)bbz(fTZdrgAVUIGfbrJZKOkIfeKlT(he0k5hHGKxB01ocY8lANhQecb8Tb8tyO1FbKc)cP1FbuKYyOdROXzsufbL6HIYkcITnqgA)giyrqU06FqqmP)R4sQIGOXzsufXcYq7lmeSiixA9piirDQgXH91ggbrJZKOkIfKH2xirWIGCP1)GGwjVaQgXLVHGOXzsufXcYq7l0iyrq04mjQIybbjV2ORDeeJWAPwjVa6WXm)GV6OmVhmGRjGVbGlwmGB(fqMQK8KvQcLgGRPwaNnnGGCP1)GGGFNsrC5BidTNvGGfbrJZKOkIfeK8AJU2rqY)t1x0OyiS1Ekk6CRuDuM3dgW1eWlYgGx4bCzPFbeoUoxA9pEcWHbWdKvaFBa38enMclPXI)kYK(VQOXzsufWflgWxcPu8izPFbu06mcW1eWdKvaFBax(FQ(IgfdHT2trrNBLQJY8EWaUyXaU5xazkRZOO9XAtaUMaoRab5sR)bbX4hdvJ4Y3qgAFrnGGfbrJZKOkIfeK8AJU2rqRxkGbCyaCPJT4rb0a4Ac4RxkGvzoRrqU06FqqvYTYOS0H)5zidTVyreSiiACMevrSGGKxB01ocIryTuooKKw8xrRKII6uvjec4Ifd4RoO0IhL59GbCnb8IBGGCP1)GGWMNfsvczO9fzdblcYLw)dcYJzcxLU4VIY7fHrq04mjQIybzO9fHhcweenotIQiwqqYRn6AhbXiSwkgcBTNIIo3kvcHaUyXa(QdkT4rzEpyaxtaVOgqqU06FqqhH)XTEcI(DViKH2xuxrWIGOXzsufXccsETrx7ii5)P6lAuI6unId7RnS6OmVhmGVlaV4gaUyXaUUbC5dhn(yQPdkT4YjaxSyaF1bLw8OmVhmGRjGxCdeKlT(heedHT2trrNBLidTV4giyrqU06FqqYYoZPZJ4Y3qq04mjQIybzO9flmeSiiACMevrSGGKxB01ocIryTume2ApffDUvQecbCXIb8vhuAXJY8EWaUMaErnGGCP1)GGoc)JB9ee97EridTVyHeblcIgNjrvelii51gDTJGK)NQVOrjQt1ioSV2WQJY8EWa(Ua8IBa4Ifd46gWLpC04JPMoO0IlNaCXIb8vhuAXJY8EWaUMaEXnqqU06Fqqme2ApffDUvIm0(IfAeSiixA9piizzN505rC5BiiACMevrSGm0(ISceSiixA9pii43Puu(zz(urq04mjQIybzO9SPbeSiiACMevrSGGKxB01ocIryTume2ApffDUvQQVObWflgWxDqPfpkZ7bd4Ac4BGGCP1)GGy8G4VI21s4JrgApBfrWIGCP1)GGQ9rrgYXgcIgNjrvelidTNn2qWIGOXzsufXccsETrx7iOnb81lfWa(UbWLp2aCya81lfWQJcObWl8a(MaU8)u9fnk43Puu(zz(uvhL59Gb8DdGxeW3cW3fG7sR)rb)oLIYplZNQs(ydWflgWL)NQVOrb)oLIYplZNQ6OmVhmGVlaViGddGhiRa(waUyXa(MaoJWAPyiS1Ekk6CRujec4Ifd4mcRLAimUNar(vaoANhg2tq0dd9ZnbSsieW3cW3gW1nGFcdT(lGuSQhM8iDuvyII8l(xLofnotIQaUyXa(QdkT4rzEpyaxtahEiixA9pii5ZCEex(gYq7zdEiyrq04mjQIybbjV2ORDeeJWAPe1PAeh2xByLqicYLw)dcIXpgQgXLVHm0E20veSiiACMevrSGGKxB01ocIryTume2ApffDUvQQVObWflgWxDqPfpkZ7bd4Ac4BGGCP1)GG8t6dfdfsyczO9STbcweenotIQiwqqYRn6AhbDcdT(lGu4xiT(lGIugdDyfnotIQaUyXa(jm06Vasneg3tGi)kahTZdd7ji6HH(5MawrJZKOkcYLw)dcY8lANhIm0E2kmeSiiACMevrSGGKxB01oc6egA9xaPgcJ7jqKFfGJ25HH9ee9Wq)CtaROXzsufb5sR)bbToI0xpbr78qKHmeKmroCecw0(IiyrqU06FqqooKKw8xrRKII6ufbrJZKOkIfKH2ZgcweenotIQiwqqU06Fqqm(Xq1iU8neK8AJU2rqmcRLAD0OVcucHa(2aoJWAPwhn6Ra1rzEpyaxtTaEGSIGKfitu08lGmmAFrKH2dpeSiiACMevrSGGKxB01ockqwb8DdGZiSwkgYXwuMihosDuM3dgW3fGRbfBBGGCP1)GGYeswJlFdzO96kcweenotIQiwqqYRn6AhbDcdT(lGu4xiT(lGIugdDyfnotIQa(2aU5x0opuDuM3dgW1eWdKvaFBax(FQ(Ig1k5hPokZ7bd4Ac4bYkcYLw)dcY8lANhIm0(nqWIGOXzsufXccYLw)dcAL8JqqYRn6Ahbz(fTZdvcHa(2a(jm06VasHFH06Vakszm0Hv04mjQIGs9qrzfbX2gidTVWqWIGOXzsufXccsETrx7iO1lfWaomaU0Xw8OaAaCnb81lfWQmN1iixA9piOk5wzuw6W)8mKH2xirWIGCP1)GGe1PAeh2xByeenotIQiwqgAFHgblcIgNjrveliixA9piig)yOAex(gcsETrx7iOLqkfpsw6xafToJaCnb8azfW3gWL)NQVOrXqyR9uu05wP6OmVhmGlwmGl)pvFrJIHWw7POOZTs1rzEpyaxtaViBaomaEGSc4Bd4MNOXuyjnw8xrM0)vfnotIQiizbYefn)cidJ2xezO9SceSiixA9piigcBTNIIo3krq04mjQIybzO9f1acweKlT(he0r4FCRNGOF3lcbrJZKOkIfKH2xSicweenotIQiwqqYRn6AhbXiSwkhhssl(ROvsrrDQQecbCXIb8vhuAXJY8EWaUMaEXnqqU06FqqyZZcPkHm0(ISHGfb5sR)bbTsEbunIlFdbrJZKOkIfKH2xeEiyrqU06FqqWVtPiU8neenotIQiwqgAFrDfblcYLw)dcsw2zoDEex(gcIgNjrvelidTV4giyrqU06FqqmP)R4sQIGOXzsufXcYq7lwyiyrqU06FqqEmt4Q0f)vuEVimcIgNjrvelidTVyHeblcIgNjrvelii51gDTJGyewl16OrFfOokZ7bd47cWjwtsbJIwNriixA9piig)opGqgAFXcncweenotIQiwqqYRn6AhbTEPagW3fGlFSb4Wa4U06FuzcjRXLVPKp2qqU06FqqWVtPO8ZY8PIm0(ISceSiiACMevrSGGKxB01ocIryTume2ApffDUvQQVObWflgWxDqPfpkZ7bd4Ac4BGGCP1)GGy8G4VI21s4JrgApBAablcYLw)dcQ2hfzihBiiACMevrSGm0E2kIGfbrJZKOkIfeKlT(heeJFmunIlFdbjV2ORDeK5xazkRZOO9XAtaUMaoRabjlqMOO5xazy0(IidTNn2qWIGOXzsufXccsETrx7iO1lfWkRZOO9XmN1aUMaEGSc4fEaNneKlT(heK8zopIlFdzO9SbpeSiiACMevrSGGKxB01oc6egA9xaPWVqA9xafPmg6WkACMevbCXIb8tyO1FbKAimUNar(vaoANhg2tq0dd9ZnbSIgNjrveKlT(heK5x0opezO9SPRiyrq04mjQIybbjV2ORDe0jm06Vasneg3tGi)kahTZdd7ji6HH(5MawrJZKOkcYLw)dcADePVEcI25HidzidbbhD4(h0E20aBAOiBAGvGGe530tagbPlzLfU96O96cDc4aoSLeG3zH)za(6papFLwUqYYd4hXQc9rvah)zeG7c2N5gvbCzPpbewbYPXEiaNnDc46)h4OZOkGN)egA9xaP2jpGBpGN)egA9xaP2rrJZKOAEaFZISElfiNg7HaC20jGR)FGJoJQaE(tyO1FbKAN8aU9aE(tyO1FbKAhfnotIQ5b8nlY6TuGCAShcWztNaU()bo6mQc45L)ufAtTtEa3EapV8NQqBQDu04mjQMhW3SiR3sbYbYPlzLfU96O96cDc4aoSLeG3zH)za(6papF4rYpJXT8a(rSQqFufWXFgb4UG9zUrvaxw6taHvGCAShcW1vDc46)h4OZOkGN)egA9xaP2jpGBpGN)egA9xaP2rrJZKOAEa3naxhS7AeW3SiR3sbYPXEiaxx1jGR)FGJoJQaE(tyO1FbKAN8aU9aE(tyO1FbKAhfnotIQ5b8nlY6TuGCAShcW3qNaU()bo6mQc45nprJP2jpGBpGN38enMAhfnotIQ5b8nlY6TuGCAShcW3qNaU()bo6mQc45pHHw)fqQDYd42d45pHHw)fqQDu04mjQMhWDdW1b7Ugb8nlY6TuGCGC6swzHBVoAVUqNaoGdBjb4Dw4FgGV(dWZlR48a(rSQqFufWXFgb4UG9zUrvaxw6taHvGCAShcWHNobC9)dC0zufWZBEIgtTtEa3EapV5jAm1okACMevZd4BwK1BPa50ypeGRR6eW1)pWrNrvapV5jAm1o5bC7b88MNOXu7OOXzsunpGVzrwVLcKdKtxYklC71r71f6eWbCyljaVZc)Za81FaEESLhWpIvf6JQao(Zia3fSpZnQc4YsFciScKtJ9qaoB6eW1)pWrNrvapFizQDu6yLsLhWThWZRJvkvEaFt2y9wkqon2db4WtNaU()bo6mQc45pHHw)fqQDYd42d45pHHw)fqQDu04mjQMhW3SiR3sbYPXEiaxx1jGR)FGJoJQaE(tyO1FbKAN8aU9aE(tyO1FbKAhfnotIQ5bC3aCDWURraFZISElfiNg7HaCwHobC9)dC0zufWZBEIgtTtEa3EapV5jAm1okACMevZd4BwK1BPa50ypeGZgB6eW1)pWrNrvap)jm06VasTtEa3Eap)jm06VasTJIgNjr18a(Mfz9wkqon2db4STHobC9)dC0zufWZFcdT(lGu7KhWThWZFcdT(lGu7OOXzsunpG7gGRd2Dnc4BwK1BPa50ypeGZ2g6eW1)pWrNrvap)jm06VasTtEa3Eap)jm06VasTJIgNjr18a(Mfz9wkqon2db4Svy6eW1)pWrNrvap)jm06VasTtEa3Eap)jm06VasTJIgNjr18aUBaUoy31iGVzrwVLcKdKtxYklC71r71f6eWbCyljaVZc)Za81FaEEzIC4O8a(rSQqFufWXFgb4UG9zUrvaxw6taHvGCAShcWztNaU()bo6mQc45djtTJshRuQ8aU9aEEDSsPYd4BYgR3sbYPXEiahE6eW1)pWrNrvapFizQDu6yLsLhWThWZRJvkvEaFZISElfiNg7HaCDvNaU()bo6mQc45pHHw)fqQDYd42d45pHHw)fqQDu04mjQMhW3SiR3sbYPXEiaFdDc46)h4OZOkGN)egA9xaP2jpGBpGN)egA9xaP2rrJZKOAEa3naxhS7AeW3SiR3sbYPXEiaVqRtax))ahDgvb88MNOXu7KhWThWZBEIgtTJIgNjr18aUBaUoy31iGVzrwVLcKtJ9qaEXcPobC9)dC0zufWZhsMAhLowPu5bC7b886yLsLhW3SiR3sbYPXEiaNn4Ptax))ahDgvb88NWqR)ci1o5bC7b88NWqR)ci1okACMevZd4Ub46GDxJa(Mfz9wkqon2db4SbpDc46)h4OZOkGN)egA9xaP2jpGBpGN)egA9xaP2rrJZKOAEaFZISElfiNg7HaC20vDc46)h4OZOkGN)egA9xaP2jpGBpGN)egA9xaP2rrJZKOAEa3naxhS7AeW3SiR3sbYbYPJYc)ZOkGVbG7sR)bWtn2Wkqoeu49RoriOcfGZc5ydWleDSrxbaEHaHXOdKRqb47wsszm0b4fHNEaoBAGnnaYbY5sR)bRcps(zmUPflKL9tmKmqoxA9pyv4rYpJXny0YoZBwIQXvYlGQI6jiApR7bKZLw)dwfEK8ZyCdgTSlGPyBuMEJNrAD9Hl9ZXX1pw8xXWxeDGCU06FWQWJKFgJBWOLDZVODEOEHhjDSfToJ0wuTHE9s7jm06VasHFH06Vakszm0Hfl(egA9xaPgcJ7jqKFfGJ25HH9ee9Wq)CtadY5sR)bRcps(zmUbJw2ziS1Ekk6CRuVWJKo2IwNrAlQ2qVEPv3MNOXuyjnw8xrM0)1T19jm06VasHFH06Vakszm0Hb5CP1)GvHhj)mg3Grl7cyk2gLPhTwK0IJNrALfitVD)0YitYXME9sRUpVRrcoAmvpWjKg6CMePiw3ydV9M21d8jtvuv64O8)u9fnWyxpWNmfBQshhL)NQVOrt2elMyvHomKQk48RDMef7XOb3wbXGoWH7tw8XYoLCRNG4rU0(BlqUcfGZkR6qbSHbCRKa8QW5w)dG7tfWL)NQVObW)fGZkXHK0a8Fb4wjb46YovbCFQaEHWRZ8eGRJgS1J0WaotbaUvsaEv4CR)bW)fG7dGlmLo2OkGRl0)UfWfvsdGBLub5pcWfWufWdps(zmUPaCwiPlGjaNvIdjPb4)cWTscW1LDQc4hvfKegW1f6F3c4mfa4SPbnKH1dWTYgd4ngWlQGhGJj5pvScKZLw)dwfEK8ZyCdgTS74qsAXFfTskkQtv9cps6ylADgPTOcE61lT621hDTrQWRZ8uShS1J0WkACMev3w3egtJKuegtJKI)kALuC9sbCpbX(ASkZ1H)T9MeRk0HHuv56dx6NJJRFS4VIHVi6elw3eRk0HHuvjlqME7(PLrMKJTTa5kuaoRSQdfWggWTscWRcNB9paUpvax(FQ(Iga)xaole2Apb46YZTsa3NkGxiW1hb4)cWlCEab4mfa4wjb4vHZT(ha)xaUpaUWu6yJQaUUq)7waxujnaUvsfK)iaxatvap8i5NX4McKZLw)dwfEK8ZyCdgTSZqyR9uu05wPEHhjDSfToJ0wuTHE9sRRp6AJuHxN5PypyRhPHv04mjQUTUjmMgjPimMgjf)v0kP46Lc4EcI91yvMRd)B7njwvOddPQY1hU0phhx)yXFfdFr0jwSUjwvOddPQswGm929tlJmjhBBbYbY5sR)bdJw2LVWy0fXLVbYvOaCy39D7URtah2Ygd4I6ucWhIQao(Ziax0FWxpah3JKaC5lmgDrC5BaUSKKWhd4R)aChWLo2ukfiNlT(hmmAzx(cJrxex(MEPEOOSQfEAqVEP9egA9xaPWuyPG(WXW7LjpZT(hXIXVqIPNQA6cCC0(pHJHFJ)rS4nL)ufAtDeC0H9u8xX1FMWqBR7tyO1FbKctHLc6dhdVxM8m36F2cKZLw)dggTSlGPyBuggKZLw)dggTSBNpSQqNA91tqex(giNlT(hmmAzxatX2OmSE9sB4rWfdKvvrLJdjPf)v0kPOOovflE1bLw8OmVhSMSPbqoxA9pyy0YU0tPOlT(NyQXMEJNrALvmiNlT(hmmAzx6Pu0Lw)tm1ytVXZiTytVEP1LwdhfPHYAcRjBGCU06FWWOLDPNsrxA9pXuJn9gpJ0ktKdhPxV06sRHJI0qznH3vrqoqoxA9pyLSI16JKW25PO0tj96Lw5)P6lAume2ApffDUvQokZ7bVl4PbqoxA9pyLSIHrl7R(iM0)v96Lw5)P6lAume2ApffDUvQokZ7bVl4PbqoxA9pyLSIHrl7m0HPd(9eOxV0UjJWAPe1PAeh2xByLqOyX6w(WrJpMA6GslUCABgH1s54qsAXFfTskkQtvLq42mcRLIHWw7POOZTsLq4wBV5QdkT4rzEp4Dj)pvFrJIHomDWVNavv4CR)bMQW5w)JyXBA(fqMQK8KvQcLMMWBdXI1T5jAmf87uIUypyRhPT1wIfV6GslEuM3dwZIWdKZLw)dwjRyy0Yot6)ACjCfOxV0UjJWAPe1PAeh2xByLqOyX6w(WrJpMA6GslUCABgH1s54qsAXFfTskkQtvLq42mcRLIHWw7POOZTsLq4wBV5QdkT4rzEp4Dj)pvFrJIj9FnUeUcuvHZT(hyQcNB9pIfVP5xazQsYtwPkuAAcVnelw3MNOXuWVtj6I9GTEK2wBjw8QdkT4rzEpynlwyGCU06FWkzfdJw2tDqPHJ6qHAqgngiNlT(hSswXWOL9W36F0RxAzewlLJdjPf)v0kPOOovvcHIfV6GslEuM3dwt2kmqoqoxA9pyLmroCKwhhssl(ROvsrrDQcY5sR)bRKjYHJGrl7m(Xq1iU8n9Kfitu08lGmS2I61lTHKPY8EumcRLAD0OVcucHBhsMkZ7rXiSwQ1rJ(kqDuM3dwtTbYkiNlT(hSsMihocgTSNjKSgx(ME9sBGSUBcjtL59Oyewlfd5ylktKdhPokZ7bVlnOyBdqoxA9pyLmroCemAz38lANhQxV0EcdT(lGu4xiT(lGIugdD4Tn)I25HQJY8EWAgiRBl)pvFrJAL8JuhL59G1mqwb5CP1)GvYe5WrWOL9vYpsVupuuw1Y2g61lTMFr78qLq42NWqR)cif(fsR)cOiLXqhgKZLw)dwjtKdhbJw2RKBLrzPd)ZZ0RxAxVuadJ0Xw8OaA0C9sbSkZzniNlT(hSsMihocgTSlQt1ioSV2WGCU06FWkzIC4iy0YoJFmunIlFtpzbYefn)cidRTOE9s7siLIhjl9lGIwNrAgiRBl)pvFrJIHWw7POOZTs1rzEpyXIL)NQVOrXqyR9uu05wP6OmVhSMfzdMazDBZt0ykSKgl(Rit6)kiNlT(hSsMihocgTSZqyR9uu05wjiNlT(hSsMihocgTSFe(h36ji639Ia5CP1)GvYe5WrWOLDS5zHuL0RxAzewlLJdjPf)v0kPOOovvcHIfV6GslEuM3dwZIBaY5sR)bRKjYHJGrl7RKxavJ4Y3a5CP1)GvYe5WrWOLD43Puex(giNlT(hSsMihocgTSll7mNopIlFdKZLw)dwjtKdhbJw2zs)xXLufKZLw)dwjtKdhbJw29yMWvPl(RO8EryqoxA9pyLmroCemAzNXVZdi96L2qYuzEpkgH1sToA0xbQJY8EW7IynjfmkADgbY5sR)bRKjYHJGrl7WVtPO8ZY8PQxV0UEPaExYhBW4sR)rLjKSgx(Ms(ydKZLw)dwjtKdhbJw2z8G4VI21s4J1RxAzewlfdHT2trrNBLQ6lAelE1bLw8OmVhSMBaY5sR)bRKjYHJGrl71(Oid5ydKZLw)dwjtKdhbJw2z8JHQrC5B6jlqMOO5xazyTf1RxAn)citzDgfTpwBstwbiNlT(hSsMihocgTSlFMZJ4Y30RxAxVuaRSoJI2hZCwRzGSw4zdKZLw)dwjtKdhbJw2n)I25H61lTNWqR)cif(fsR)cOiLXqhwS4tyO1FbKAimUNar(vaoANhg2tq0dd9ZnbmiNlT(hSsMihocgTSVoI0xpbr78q96L2tyO1FbKAimUNar(vaoANhg2tq0dd9ZnbmihiNlT(hScBADCijT4VIwjff1PkiNlT(hScBWOLDg)yOAex(ME9sBizQmVhfJWAPwhn6RaLq42HKPY8EumcRLAD0OVcuhL59G1uBGScY5sR)bRWgmAz38lANhQxV0EcdT(lGu4xiT(lGIugdD4Tn)I25HQJY8EWAgiRBl)pvFrJAL8JuhL59G1mqwb5CP1)GvydgTSVs(r6L6HIYQw22qVEP18lANhQec3(egA9xaPWVqA9xafPmg6WGCU06FWkSbJw2zs)xXLufKZLw)dwHny0YUOovJ4W(AddY5sR)bRWgmAzFL8cOAex(giNlT(hScBWOLD43Puex(ME9slJWAPwjVa6WXm)GV6OmVhSMBiwS5xazQsYtwPkuAAQLnnaY5sR)bRWgmAzNXpgQgXLVPxV0k)pvFrJIHWw7POOZTs1rzEpynlYwHxw6xaHJRZLw)JNGjqw328enMclPXI)kYK(Vkw8siLIhjl9lGIwNrAgiRBl)pvFrJIHWw7POOZTs1rzEpyXIn)citzDgfTpwBstwbiNlT(hScBWOL9k5wzuw6W)8m96L21lfWWiDSfpkGgnxVuaRYCwdY5sR)bRWgmAzhBEwivj96LwgH1s54qsAXFfTskkQtvLqOyXRoO0IhL59G1S4gGCU06FWkSbJw29yMWvPl(RO8EryqoxA9pyf2Grl7hH)XTEcI(DVi96LwgH1sXqyR9uu05wPsiuS4vhuAXJY8EWAwudGCU06FWkSbJw2ziS1Ekk6CRuVEPv(FQ(IgLOovJ4W(AdRokZ7bVRIBiwSULpC04JPMoO0IlNelE1bLw8OmVhSMf3aKZLw)dwHny0YUSSZC68iU8nqoxA9pyf2Grl7hH)XTEcI(DVi96LwgH1sXqyR9uu05wPsiuS4vhuAXJY8EWAwudGCU06FWkSbJw2ziS1Ekk6CRuVEPv(FQ(IgLOovJ4W(AdRokZ7bVRIBiwSULpC04JPMoO0IlNelE1bLw8OmVhSMf3aKZLw)dwHny0YUSSZC68iU8nqoxA9pyf2Grl7WVtPO8ZY8PcY5sR)bRWgmAzNXdI)kAxlHpwVEPLryTume2ApffDUvQQVOrS4vhuAXJY8EWAUbiNlT(hScBWOL9AFuKHCSbY5sR)bRWgmAzx(mNhXLVPxV0U56Lc4DJ8XgmRxkGvhfqtHFt5)P6lAuWVtPO8ZY8PQokZ7bVBkU1UCP1)OGFNsr5NL5tvjFSjwS8)u9fnk43Puu(zz(uvhL59G3vrycK1TelEtgH1sXqyR9uu05wPsiuSygH1sneg3tGi)kahTZdd7ji6HH(5MawjeU126(egA9xaPyvpm5r6OQWef5x8VkDIfV6GslEuM3dwt4bY5sR)bRWgmAzNXpgQgXLVPxV0YiSwkrDQgXH91gwjecY5sR)bRWgmAz3pPpumuiHj96LwgH1sXqyR9uu05wPQ(IgXIxDqPfpkZ7bR5gGCU06FWkSbJw2n)I25H61lTNWqR)cif(fsR)cOiLXqhwS4tyO1FbKAimUNar(vaoANhg2tq0dd9ZnbmiNlT(hScBWOL91rK(6jiANhQxV0EcdT(lGudHX9eiYVcWr78WWEcIEyOFUjGrq4qsI2Z2gWdzidHa]] )

end
