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
                applyBuff( "primal_rage" )
                applyBuff( "bloodlust" )
                stat.haste = stat.haste + 0.4
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

            -- Let's not recommend Tar Trap if Flare is on CD.
            timeToReady = function () return max( 0, cooldown.flare.remains - gcd.max ) end,

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

            spend = 0,
            spendType = "focus",

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


    spec:RegisterPack( "Beast Mastery", 20210121, [[dWKWabqisv6rcQsBssQpjbJss4usIwLGQQxjPmlsLULKQk7IKFrqggPihtcTmqLNrQW0ivvDnjjBJuv5BKksJJur15iOW6if18ifUhP0(KuLdsqrlKa9qbvMOGQWfjveFKufzKsQQYjjvbRuqMjbv3uqv0obf)usvzOsQQQLkOQ8uqMkO0xjvrnwjvolPk0EH8xrgmQomvlgfpMOjROlJSzf(SaJwIoTsRMur51eqZwOBlQ2Tu)wvdxuoobLwUkphQPt56O02bv9Dcz8eGZlOSEsvz(eQ9dmQicwe00ncbdCAcUIAQiCfvWPj40pnjmqqwyzeckZLc0dieu75ecsqYXgGhE6yJUWqqzEyX3Niyrq4N9KecQ0SmSMfsOG1kzzuYpxi8MZgDB)wE(WecV5sHqqmSB00dnIbbnDJqWaNMGROMkcxrfCAco9tt6CeKZAL)HGG28WHGk35KAedcAsyjck8c4cso2a8WthB0fgGx)X2gDGqHxapK3S(fgGdxrDbC40eCfrqXfByeSiOjnC2OHGfbtreSiixA73ii5Z2gDjC5BiiQDMinrcImemWHGfbrTZePjsqeKlT9BeK8zBJUeU8neK8wJU1rqhBtJ)cifMYkz1hoLDVm65UTFRO2zI0eWflgWXpBKz7PQ3WCCY(pItz)I)wrTZePjGlwmGxbGl)EYUM6i4Pd7X0psJ)m2Muu7mrAc4vd46fWp2Mg)fqkmLvYQpCk7Ez0ZDB)wrTZePjGxjckUnLKteKo0eYqWOdeSiixA73iiwmLwJYXiiQDMinrcImem6pcweKlT9BeKDElSSBC132bjC5BiiQDMinrcImemvHGfbrTZePjsqeK8wJU1rqzhbFkqovfvooJKw6hjRKsI24eWflgWhBqPLok33gd4Aa4WPjeKlT9BeelMsRr5yKHGr)qWIGO2zI0ejicYL2(ncs6XyYL2(DkUydbfxSLApNqqYjgziy0Piyrqu7mrAIeebjV1OBDeKlTfEkrnLVegW1aWHdb5sB)gbj9ym5sB)ofxSHGIl2sTNtiiSHmem6CeSiiQDMinrcIGK3A0TocYL2cpLOMYxcd41dWlIGCPTFJGKEmMCPTFNIl2qqXfBP2ZjeKmso8eYqgck7i5NZ4gcwemfrWIGCPTFJGWS55FNYidbrTZePjsqKHGboeSiixA73iiM3SintJOhgnfTDqYEbSncIANjstKGidbJoqWIGO2zI0ejicQ9Ccb56dx6NJtJVT0pszVi6qqU02VrqU(WL(5404Bl9Ju2lIoKHGr)rWIGO2zI0ejick7iPJTKT5ecQOQkeKlT9BeK5xYopdbjV1OBDe0X204VasHF244Vakr5m0Hvu7mrAc4Ifd4hBtJ)civty82bI8lmCYoplB7GKNL5NBSyf1otKMidbtviyrqu7mrAIeebLDK0XwY2CcbvuvfcYL2(ncIHW26XKOZTseK8wJU1rq6fWnpsTPWsQT0psmX)NkQDMinb8QbC9c4hBtJ)cif(zJJ)cOeLZqhwrTZePjYqWOFiyrqu7mrAIeeb5sB)gbjdtgF7(ELjMOJneK8wJU1rq6fWpFNjcEQn12WZgB6CMiPibSydd4vd4va42TTajtvuv64K8)48f1aEna3UTfizk4uLooj)poFrnGRbGdhGlwmGtcl7MLrtf8(TotKsBBuJxlSuWg4W)rl9y5gJUTDq6ixA)b4vIGOXGKwQ9CcbjdtgF7(ELjMOJnKHGrNIGfbrTZePjsqeu2rshBjBZjeurLoqqU02VrqooJKw6hjRKsI24ebjV1OBDeKEbCxF0TgPYUn3JPTX22sdRO2zI0eWRgW1lGtym1ssrym1sk9JKvsPXlzXBhK2BXQCxN9hGxnGxbGtcl7MLrtLRpCPFoon(2s)iL9IOdWflgW1lGtcl7MLrtLmmz8T77vMyIo2a8krgcgDocwee1otKMibrqzhjDSLSnNqqfvvHGCPTFJGyiSTEmj6CRebjV1OBDeKRp6wJuz3M7X02yBBPHvu7mrAc4vd46fWjmMAjPimMAjL(rYkP04LS4Tds7TyvURZ(dWRgWRaWjHLDZYOPY1hU0phNgFBPFKYEr0b4Ifd46fWjHLDZYOPsgMm(299ktmrhBaELidzii5eJGfbtreSiiQDMinrcIGK3A0Tocs(FC(IAfdHT1JjrNBLQJY9TXaE9aCDOjeKlT9BeK3scBNhtspgrgcg4qWIGO2zI0ejicsERr36ii5)X5lQvme2wpMeDUvQok33gd41dW1HMqqU02VrqJ9iM4)tKHGrhiyrqu7mrAIeebjV1OBDeufaod7yOeTXzcNT3AyfBgGlwmGRxax(WtT3MQ3GslnCcWRgWzyhdLJZiPL(rYkPKOnovSzaE1aod7yOyiSTEmj6CRuXMb4vc4vd4va4JnO0shL7BJb86b4Y)JZxuRyOdtNa3oqnzp32Vb8Aa(K9CB)gWflgWRaWn)citvsE0kvzsdW1aW1rvaUyXaUEbCZJuBkbUXiDPTX22strTZePjGxjGxjGlwmGp2GslDuUVngW1aWlQdeKlT9BeedDy6e42bidbJ(JGfbrTZePjsqeK8wJU1rqva4mSJHs0gNjC2ERHvSzaUyXaUEbC5dp1EBQEdkT0WjaVAaNHDmuooJKw6hjRKsI24uXMb4vd4mSJHIHW26XKOZTsfBgGxjGxnGxbGp2GslDuUVngWRhGl)poFrTIj()mnyVWut2ZT9BaVgGpzp32VbCXIb8kaCZVaYuLKhTsvM0aCnaCDufGlwmGRxa38i1MsGBmsxABSTT0uu7mrAc4vc4vc4Ifd4JnO0shL7BJbCna8I6hcYL2(ncIj()mnyVWqgcMQqWIGCPTFJGIBqPHt6m2zqo1gcIANjstKGidbJ(HGfbrTZePjsqeK8wJU1rqmSJHYXzK0s)izLus0gNk2maxSyaFSbLw6OCFBmGRbGdN(HGCPTFJGYEB)gzidbHneSiykIGfb5sB)gb54msAPFKSskjAJtee1otKMibrgcg4qWIGO2zI0ejicsERr36iig2XqnoQ1xyk2maVAaNHDmuJJA9fM6OCFBmGRHwapqorqU02Vrqm(XqZeU8nKHGrhiyrqu7mrAIeebjV1OBDe0X204VasHF244Vakr5m0Hvu7mrAc4vd4MFj78m1r5(2yaxdapqob8QbC5)X5lQvJOFK6OCFBmGRbGhiNiixA73iiZVKDEgYqWO)iyrqu7mrAIeeb5sB)gbnI(rii5TgDRJGm)s25zk2maVAa)yBA8xaPWpBC8xaLOCg6WkQDMinrqXTPKCIGGRkKHGPkeSiixA73iiM4)tCjnrqu7mrAIeeziy0peSiixA73iirBCMWz7TggbrTZePjsqKHGrNIGfb5sB)gbnIEy0mHlFdbrTZePjsqKHGrNJGfbrTZePjsqeK8wJU1rqmSJHAe9WOdNY9tGQJY9TXaUgaEvaUyXaU5xazQsYJwPktAaUgAbC40ecYL2(ncsGBmMWLVHmemcdeSiiQDMinrcIGK3A0Tocs(FC(IAfdHT1JjrNBLQJY9TXaUgaEr4a8WpGll9lGWPX5sB)2JaEnapqob8QbCZJuBkSKAl9Jet8)PIANjstaxSyaFWgJPJKL(fqjBZjaxdapqob8QbC5)X5lQvme2wpMeDUvQok33gd4Ifd4MFbKPSnNs2NMlb4Aa4cdeKlT9BeeJFm0mHlFdziykQjeSiiQDMinrcIGK3A0TocA8swmGxdWLo2shfqnGRbGpEjlwL7cab5sB)gbnj3ktYsxGNNJmemflIGfbrTZePjsqeK8wJU1rqmSJHYXzK0s)izLus0gNk2maxSyaFSbLw6OCFBmGRbGxSkeKlT9Bee288mAsidbtr4qWIGCPTFJG8uo7nPl9JK8Eryee1otKMibrgcMI6ablcIANjstKGii5TgDRJGyyhdfdHT1JjrNBLk2maxSyaFSbLw6OCFBmGRbGxutiixA73iOJWF722bj)UxeYqWuu)rWIGO2zI0ejicsERr36ii5)X5lQvI24mHZ2BnS6OCFBmGxpaVyvaUyXaUEbC5dp1EBQEdkT0WjaxSyaFSbLw6OCFBmGRbGxSkeKlT9BeedHT1JjrNBLidbtXQqWIGCPTFJGKLBUtNNWLVHGO2zI0ejiYqWuu)qWIGO2zI0ejicsERr36iig2XqXqyB9ys05wPIndWflgWhBqPLok33gd4Aa4f1ecYL2(nc6i83UTDqYV7fHmemf1Piyrqu7mrAIeebjV1OBDeK8)48f1krBCMWz7TgwDuUVngWRhGxSkaxSyaxVaU8HNAVnvVbLwA4eGlwmGp2GslDuUVngW1aWlwfcYL2(ncIHW26XKOZTsKHGPOohblcYL2(ncswU5oDEcx(gcIANjstKGidbtrHbcweKlT9BeKa3ymj)8CVNiiQDMinrcImemWPjeSiiQDMinrcIGK3A0TocIHDmume2wpMeDUvQMVOgWflgWhBqPLok33gd4Aa4vHGCPTFJGy8G0ps2TsbIrgcg4kIGfb5sB)gbn3JsmKJnee1otKMibrgcg4GdblcIANjstKGii5TgDRJGQaWhVKfd41pax(ydWRb4JxYIvhfqnGh(b8kaC5)X5lQvcCJXK8ZZ9EQok33gd41paViGxjGxpa3L2(TsGBmMKFEU3tL8XgGlwmGl)poFrTsGBmMKFEU3t1r5(2yaVEaEraVgGhiNaELaUyXaEfaod7yOyiSTEmj6CRuXMb4Ifd4mSJHQjmE7ar(fgozNNLTDqYZY8ZnwSIndWReWRgW1lGFSnn(lGucRNf9eD0KTtI8l93Kof1otKMaUyXa(ydkT0r5(2yaxdaxhiixA73ii5ZCEcx(gYqWaNoqWIGO2zI0ejicsERr36iig2XqjAJZeoBV1Wk2meKlT9BeeJFm0mHlFdziyGt)rWIGO2zI0ejicsERr36iig2XqXqyB9ys05wPA(IAaxSyaFSbLw6OCFBmGRbGxfcYL2(ncYpP3ukJnIjKHGbUQqWIGO2zI0ejicsERr36iOJTPXFbKc)SXXFbuIYzOdRO2zI0eWflgWp2Mg)fqQMW4Tde5xy4KDEw22bjplZp3yXkQDMinrqU02VrqMFj78mKHGbo9dblcIANjstKGii5TgDRJGo2Mg)fqQMW4Tde5xy4KDEw22bjplZp3yXkQDMinrqU02VrqJJi9TDqYopdziyGtNIGfbrTZePjsqeK8wJU1rqva4JxYIb8Aa(4LSy1rbud41a8Ivb4vc4Aa4JxYIv5UaqqU02Vrq(j9Ms2Fh1gYqgcsgjhEcblcMIiyrqU02VrqooJKw6hjRKsI24ebrTZePjsqKHGboeSiiQDMinrcIGCPTFJGy8JHMjC5Bii5TgDRJGyyhd14OwFHPyZa8QbCg2XqnoQ1xyQJY9TXaUgAb8a5ebjdtgPK5xazyemfrgcgDGGfbrTZePjsqeK8wJU1rqbYjGx)aCg2XqXqo2sYi5WtQJY9TXaE9aCnPGRkeKlT9BeuoB0wC5BidbJ(JGfbrTZePjsqeK8wJU1rqhBtJ)cif(zJJ)cOeLZqhwrTZePjGxnGB(LSZZuhL7BJbCna8a5eWRgWL)hNVOwnI(rQJY9TXaUgaEGCIGCPTFJGm)s25zidbtviyrqu7mrAIeeb5sB)gbnI(rii5TgDRJGm)s25zk2maVAa)yBA8xaPWpBC8xaLOCg6WkQDMinrqXTPKCIGGRkKHGr)qWIGO2zI0ejicsERr36iOXlzXaEnax6ylDua1aUga(4LSyvUlaeKlT9Be0KCRmjlDbEEoYqWOtrWIGCPTFJGeTXzcNT3Ayee1otKMibrgcgDocwee1otKMibrqU02Vrqm(XqZeU8neK8wJU1rqd2ymDKS0VakzBob4Aa4bYjGxnGl)poFrTIHW26XKOZTs1r5(2yaxSyax(FC(IAfdHT1JjrNBLQJY9TXaUgaEr4a8AaEGCc4vd4MhP2uyj1w6hjM4)tf1otKMiizyYiLm)cidJGPiYqWimqWIGCPTFJGyiSTEmj6CRebrTZePjsqKHGPOMqWIGCPTFJGoc)TBBhK87EriiQDMinrcImemflIGfbrTZePjsqeK8wJU1rqmSJHYXzK0s)izLus0gNk2maxSyaFSbLw6OCFBmGRbGxSkeKlT9Bee288mAsidbtr4qWIGCPTFJGgrpmAMWLVHGO2zI0ejiYqWuuhiyrqU02VrqcCJXeU8nee1otKMibrgcMI6pcweKlT9BeKSCZD68eU8nee1otKMibrgcMIvHGfb5sB)gbXe)FIlPjcIANjstKGidbtr9dblcYL2(ncYt5S3KU0psY7fHrqu7mrAIeeziykQtrWIGO2zI0ejicsERr36iig2XqnoQ1xyQJY9TXaE9aCsaKK1OKT5ecYL2(ncIXVZdiKHGPOohblcIANjstKGii5TgDRJGgVKfd41dWLp2a8AaUlT9BvoB0wC5Bk5JneKlT9BeKa3ymj)8CVNidbtrHbcwee1otKMibrqYBn6whbXWogkgcBRhtIo3kvZxud4Ifd4JnO0shL7BJbCna8QqqU02VrqmEq6hj7wPaXidbdCAcblcYL2(ncAUhLyihBiiQDMinrcImemWveblcIANjstKGiixA73iig)yOzcx(gcsERr36iiZVaYu2Mtj7tZLaCnaCHbcsgMmsjZVaYWiykImemWbhcwee1otKMibrqYBn6whbnEjlwzBoLSpL7caW1aWdKtap8d4WHGCPTFJGKpZ5jC5BidbdC6ablcIANjstKGii5TgDRJGo2Mg)fqk8Zgh)fqjkNHoSIANjstaxSya)yBA8xaPAcJ3oqKFHHt25zzBhK8Sm)CJfRO2zI0eb5sB)gbz(LSZZqgcg40FeSiiQDMinrcIGK3A0Toc6yBA8xaPAcJ3oqKFHHt25zzBhK8Sm)CJfRO2zI0eb5sB)gbnoI032bj78mKHGbUQqWIGO2zI0ejicsERr36iOka8XlzXaEnaF8swS6OaQb8AaUo0eGxjGRbGpEjlwL7cab5sB)gb5N0Bkz)DuBidzidbbpD49BemWPj40ur4kQFiir(1BhGrq6zHz4dg9am6jnd4aoSLeGV5z)za(4paVWKgoB0ka4hjSS7rtah)5eG7S2N7gnbCzP3bewbcj8Tjahond4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzbaVIIcOsfiKW3MaC40mGhUVHNoJMaEHJTPXFbKQUcaU9aEHJTPXFbKQof1otKMfa8kkkGkvGqcFBcWHtZaE4(gE6mAc4fKFpzxtvxba3EaVG87j7AQ6uu7mrAwaWROOaQubcj8Tjahond4H7B4PZOjGxa)SrMTNQ6ka42d4fWpBKz7PQof1otKMfa8kkkGkvGqGq6zHz4dg9am6jnd4aoSLeGV5z)za(4paVq2rYpNXTca(rcl7E0eWXFob4oR95Urtaxw6DaHvGqcFBcW1Fnd4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzba3naxNuFchWROOaQubcj8Tjax)1mGhUVHNoJMaEHJTPXFbKQUcaU9aEHJTPXFbKQof1otKMfa8kkkGkvGqcFBcWRsZaE4(gE6mAc4fmpsTPQRaGBpGxW8i1MQof1otKMfa8kkkGkvGqcFBcWRsZaE4(gE6mAc4fo2Mg)fqQ6ka42d4fo2Mg)fqQ6uu7mrAwaWDdW1j1NWb8kkkGkvGqGq6zHz4dg9am6jnd4aoSLeGV5z)za(4paVGCIla4hjSS7rtah)5eG7S2N7gnbCzP3bewbcj8TjaxhAgWd33WtNrtaVG5rQnvDfaC7b8cMhP2u1PO2zI0SaGxrrbuPces4BtaU(RzapCFdpDgnb8cMhP2u1vaWThWlyEKAtvNIANjsZcaEfffqLkqiqi9SWm8bJEag9KMbCah2scW38S)maF8hGxaBfa8Jew29OjGJ)CcWDw7ZDJMaUS07acRaHe(2eGdNMb8W9n80z0eWlKrMQoLEuPufaC7b8c6rLsvaWRaobuPces4BtaUo0mGhUVHNoJMaEHJTPXFbKQUcaU9aEHJTPXFbKQof1otKMfa8kkkGkvGqcFBcW1Fnd4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzba3naxNuFchWROOaQubcj8TjaxyOzapCFdpDgnb8cMhP2u1vaWThWlyEKAtvNIANjsZcaEfffqLkqiHVnb4WbNMb8W9n80z0eWlCSnn(lGu1vaWThWlCSnn(lGu1PO2zI0SaGxrrbuPces4BtaoCvPzapCFdpDgnb8chBtJ)civDfaC7b8chBtJ)civDkQDMinla4Ub46K6t4aEfffqLkqiHVnb4WvLMb8W9n80z0eWlCSnn(lGu1vaWThWlCSnn(lGu1PO2zI0SaGxrrbuPces4BtaoC6NMb8W9n80z0eWlCSnn(lGu1vaWThWlCSnn(lGu1PO2zI0SaG7gGRtQpHd4vuuavQaHaH0ZcZWhm6by0tAgWbCyljaFZZ(Za8XFaEbzKC4Pca(rcl7E0eWXFob4oR95Urtaxw6DaHvGqcFBcWHtZaE4(gE6mAc4fYitvNspQuQcaU9aEb9OsPka4vaNaQubcj8TjaxhAgWd33WtNrtaVqgzQ6u6rLsvaWThWlOhvkvbaVIIcOsfiKW3MaC9xZaE4(gE6mAc4fo2Mg)fqQ6ka42d4fo2Mg)fqQ6uu7mrAwaWROOaQubcj8TjaVknd4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzba3naxNuFchWROOaQubcj8TjaxNRzapCFdpDgnb8cMhP2u1vaWThWlyEKAtvNIANjsZcaUBaUoP(eoGxrrbuPces4BtaErDQMb8W9n80z0eWlKrMQoLEuPufaC7b8c6rLsvaWROOaQubcj8TjahoDOzapCFdpDgnb8chBtJ)civDfaC7b8chBtJ)civDkQDMinla4Ub46K6t4aEfffqLkqiHVnb4WPdnd4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzbaVIIcOsfiKW3MaC40Fnd4H7B4PZOjGx4yBA8xaPQRaGBpGx4yBA8xaPQtrTZePzba3naxNuFchWROOaQubcbcPhYZ(ZOjGxfG7sB)gWJl2WkqieeoJKiyGRkDGGYUFSrcbfEbCbjhBaE4PJn6cdWR)yBJoqOWlGhYBw)cdWHROUaoCAcUIGqGqU02VXQSJKFoJBAXS55FNYideYL2(nwLDK8ZzCRMwHyEZI0mnIEy0u02bj7fW2GqU02VXQSJKFoJB10kelMsRr562EoP11hU0phNgFBPFKYEr0bc5sB)gRYos(5mUvtRqMFj78mDZos6ylzBoPTOQkD3H2JTPXFbKc)SXXFbuIYzOdlw8X204Vas1egVDGi)cdNSZZY2oi5zz(5glgeYL2(nwLDK8ZzCRMwHyiSTEmj6CRu3SJKo2s2MtAlQQs3DOvVMhP2uyj1w6hjM4)ZQ17X204VasHF244Vakr5m0HbHCPTFJvzhj)Cg3QPviwmLwJY1LgdsAP2ZjTYWKX3UVxzIj6yt3DOvVNVZebp1MAB4zJnDotKuKawSHRUc72wGKPkQkDCs(FC(I6A2TTajtbNQ0Xj5)X5lQ1aoXIjHLDZYOPcE)wNjsPTnQXRfwkydC4)OLESCJr32oiDKlT)Qeek8c4cZPoJfBya3kjaFYEUTFd4EpbC5)X5lQb8Fa4ctCgjna)haUvsaUEEJta37jGx)FBUhbC9qJTTLggWzcdWTscWNSNB73a(paCVbC2U0XgnbC9u4cpaCrLud4wjfwHJaCwmnb8SJKFoJBkaxqs6SycWfM4msAa(paCRKaC98gNa(rtwjHbC9u4cpaCMWaC40KMYX6c4w5Ib8fd4fv6aWXK87jwbc5sB)gRYos(5mUvtRqooJKw6hjRKsI24u3SJKo2s2MtAlQ0HU7qRED9r3AKk72CpM2gBBlnSIANjsZQ1lHXuljfHXulP0pswjLgVKfVDqAVfRYDD2FvxbjSSBwgnvU(WL(5404Bl9Ju2lIoXI1ljSSBwgnvYWKX3UVxzIj6yRsqOWlGlmN6mwSHbCRKa8j752(nG79eWL)hNVOgW)bGliHT1JaUE(CReW9Ec41FU(ia)haE4ZdiaNjma3kjaFYEUTFd4)aW9gWz7shB0eW1tHl8aWfvsnGBLuyfocWzX0eWZos(5mUPaHCPTFJvzhj)Cg3QPvigcBRhtIo3k1n7iPJTKT5K2IQQ0DhAD9r3AKk72CpM2gBBlnSIANjsZQ1lHXuljfHXulP0pswjLgVKfVDqAVfRYDD2FvxbjSSBwgnvU(WL(5404Bl9Ju2lIoXI1ljSSBwgnvYWKX3UVxzIj6yRsqiqixA734AAfs(STrxcx(giu4fWHT(cpQpnd4WwUyax0gJaEt0eWXFob4I(tG6c44TLeGlF22OlHlFdWLLKuGyaF8hG7aU0XMsPaHCPTFJRPvi5Z2gDjC5B6g3MsYPwDOjD3H2JTPXFbKctzLS6dNYUxg9C32Vflg)SrMTNQEdZXj7)ioL9l(BXIRq(9KDn1rWth2JPFKg)zSnvTEp2Mg)fqkmLvYQpCk7Ez0ZDB)UsqixA734AAfIftP1OCmiKlT9BCnTczN3cl7gx9TDqcx(giKlT9BCnTcXIP0Auow3DOn7i4tbYPQOYXzK0s)izLus0gNIfp2GslDuUVnwd40eiKlT9BCnTcj9ym5sB)ofxSPB75Kw5edc5sB)gxtRqspgtU02VtXfB62EoPfB6UdTU0w4Pe1u(synGdeYL2(nUMwHKEmMCPTFNIl20T9CsRmso8KU7qRlTfEkrnLVeUEfbHaHCPTFJvYjwR3scBNhtspg1DhAL)hNVOwXqyB9ys05wP6OCFBC90HMaHCPTFJvYjUMwHg7rmX)N6UdTY)JZxuRyiSTEmj6CRuDuUVnUE6qtGqU02VXk5extRqm0HPtGBhO7o0wbd7yOeTXzcNT3AyfBMyX6v(WtT3MQ3GslnCQAg2Xq54msAPFKSskjAJtfBw1mSJHIHW26XKOZTsfBwLvxXydkT0r5(246j)poFrTIHomDcC7a1K9CB)U2K9CB)wS4km)citvsE0kvzstdDuLyX618i1MsGBmsxABSTT0QSsXIhBqPLok33gRrrDac5sB)gRKtCnTcXe)FMgSxy6UdTvWWogkrBCMWz7TgwXMjwSELp8u7TP6nO0sdNQMHDmuooJKw6hjRKsI24uXMvnd7yOyiSTEmj6CRuXMvz1vm2GslDuUVnUEY)JZxuRyI)ptd2lm1K9CB)U2K9CB)wS4km)citvsE0kvzstdDuLyX618i1MsGBmsxABSTT0QSsXIhBqPLok33gRrr9deYL2(nwjN4AAfkUbLgoPZyNb5uBGqU02VXk5extRqzVTFR7o0YWogkhNrsl9JKvsjrBCQyZelESbLw6OCFBSgWPFGqGqU02VXkzKC4jTooJKw6hjRKsI24eeYL2(nwjJKdpvtRqm(XqZeU8nDLHjJuY8lGmS2I6UdTzKPY9TvmSJHACuRVWuSzvNrMk33wXWogQXrT(ctDuUVnwdTbYjiKlT9BSsgjhEQMwHYzJ2IlFt3DOnqoRFzKPY9TvmSJHIHCSLKrYHNuhL7BJRNMuWvfiKlT9BSsgjhEQMwHm)s25z6UdThBtJ)cif(zJJ)cOeLZqhUAZVKDEM6OCFBSgbYz1Y)JZxuRgr)i1r5(2yncKtqixA73yLmso8unTcnI(r6g3MsYPw4Qs3DO18lzNNPyZQ(yBA8xaPWpBC8xaLOCg6WGqU02VXkzKC4PAAfAsUvMKLUappx3DOD8swCnPJT0rbuRX4LSyvUlaqixA73yLmso8unTcjAJZeoBV1WGqU02VXkzKC4PAAfIXpgAMWLVPRmmzKsMFbKH1wu3DODWgJPJKL(fqjBZjncKZQL)hNVOwXqyB9ys05wP6OCFBSyXY)JZxuRyiSTEmj6CRuDuUVnwJIWvlqoR28i1MclP2s)iXe)Fcc5sB)gRKrYHNQPvigcBRhtIo3kbHCPTFJvYi5Wt10k0r4VDB7GKF3lceYL2(nwjJKdpvtRqyZZZOjP7o0YWogkhNrsl9JKvsjrBCQyZelESbLw6OCFBSgfRceYL2(nwjJKdpvtRqJOhgnt4Y3aHCPTFJvYi5Wt10kKa3ymHlFdeYL2(nwjJKdpvtRqYYn3PZt4Y3aHCPTFJvYi5Wt10ket8)jUKMGqU02VXkzKC4PAAfYt5S3KU0psY7fHbHCPTFJvYi5Wt10keJFNhq6UdTzKPY9TvmSJHACuRVWuhL7BJRhjasYAuY2CceYL2(nwjJKdpvtRqcCJXK8ZZ9EQ7o0oEjlUEYhB1CPTFRYzJ2IlFtjFSbc5sB)gRKrYHNQPvigpi9JKDRuGyD3Hwg2XqXqyB9ys05wPA(IAXIhBqPLok33gRrvGqU02VXkzKC4PAAfAUhLyihBGqU02VXkzKC4PAAfIXpgAMWLVPRmmzKsMFbKH1wu3DO18lGmLT5uY(0CjnegGqU02VXkzKC4PAAfs(mNNWLVP7o0oEjlwzBoLSpL7cqJa5m8dhiKlT9BSsgjhEQMwHm)s25z6UdThBtJ)cif(zJJ)cOeLZqhwS4JTPXFbKQjmE7ar(fgozNNLTDqYZY8ZnwmiKlT9BSsgjhEQMwHghr6B7GKDEMU7q7X204Vas1egVDGi)cdNSZZY2oi5zz(5glgeYL2(nwjJKdpvtRq(j9Ms2Fh1MU7qBfJxYIRnEjlwDua110HMQuJXlzXQCxaGqGqU02VXkSP1XzK0s)izLus0gNGqU02VXkSvtRqm(XqZeU8nD3H2mYu5(2kg2XqnoQ1xyk2SQZitL7BRyyhd14OwFHPok33gRH2a5eeYL2(nwHTAAfY8lzNNP7o0ESnn(lGu4Nno(lGsuodD4Qn)s25zQJY9TXAeiNvl)poFrTAe9JuhL7BJ1iqobHCPTFJvyRMwHgr)iDJBtj5ulCvP7o0A(LSZZuSzvFSnn(lGu4Nno(lGsuodDyqixA73yf2QPviM4)tCjnbHCPTFJvyRMwHeTXzcNT3AyqixA73yf2QPvOr0dJMjC5BGqU02VXkSvtRqcCJXeU8nD3Hwg2XqnIEy0Ht5(jq1r5(2ynQsSyZVaYuLKhTsvM00qlCAceYL2(nwHTAAfIXpgAMWLVP7o0k)poFrTIHW26XKOZTs1r5(2ynkcx4xw6xaHtJZL2(ThRfiNvBEKAtHLuBPFKyI)pflEWgJPJKL(fqjBZjncKZQL)hNVOwXqyB9ys05wP6OCFBSyXMFbKPSnNs2NMlPHWaeYL2(nwHTAAfAsUvMKLUappx3DOD8swCnPJT0rbuRX4LSyvUlaqixA73yf2QPviS55z0K0DhAzyhdLJZiPL(rYkPKOnovSzIfp2GslDuUVnwJIvbc5sB)gRWwnTc5PC2Bsx6hj59IWGqU02VXkSvtRqhH)2TTds(DViD3Hwg2XqXqyB9ys05wPIntS4XguAPJY9TXAuutGqU02VXkSvtRqme2wpMeDUvQ7o0k)poFrTs0gNjC2ERHvhL7BJRxXQelwVYhEQ92u9guAPHtIfp2GslDuUVnwJIvbc5sB)gRWwnTcjl3CNopHlFdeYL2(nwHTAAf6i83UTDqYV7fP7o0YWogkgcBRhtIo3kvSzIfp2GslDuUVnwJIAceYL2(nwHTAAfIHW26XKOZTsD3Hw5)X5lQvI24mHZ2BnS6OCFBC9kwLyX6v(WtT3MQ3GslnCsS4XguAPJY9TXAuSkqixA73yf2QPviz5M705jC5BGqU02VXkSvtRqcCJXK8ZZ9Ecc5sB)gRWwnTcX4bPFKSBLceR7o0YWogkgcBRhtIo3kvZxulw8ydkT0r5(2ynQceYL2(nwHTAAfAUhLyihBGqU02VXkSvtRqYN58eU8nD3H2kgVKfx)Kp2QnEjlwDua1H)kK)hNVOwjWngtYpp37P6OCFBC9RyL1ZL2(TsGBmMKFEU3tL8XMyXY)JZxuRe4gJj5NN79uDuUVnUEfRfiNvkwCfmSJHIHW26XKOZTsfBMyXmSJHQjmE7ar(fgozNNLTDqYZY8ZnwSInRYQ17X204VasjSEw0t0rt2ojYV0Ft6elESbLw6OCFBSg6aeYL2(nwHTAAfIXpgAMWLVP7o0YWogkrBCMWz7TgwXMbc5sB)gRWwnTc5N0BkLXgXKU7qld7yOyiSTEmj6CRunFrTyXJnO0shL7BJ1OkqixA73yf2QPviZVKDEMU7q7X204VasHF244Vakr5m0Hfl(yBA8xaPAcJ3oqKFHHt25zzBhK8Sm)CJfdc5sB)gRWwnTcnoI032bj78mD3H2JTPXFbKQjmE7ar(fgozNNLTDqYZY8ZnwmiKlT9BScB10kKFsVPK93rTP7o0wX4LS4AJxYIvhfqDTIvvPgJxYIv5UaqgYqi]] )

end
