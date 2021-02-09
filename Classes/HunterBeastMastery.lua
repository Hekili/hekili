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


    spec:RegisterPack( "Beast Mastery", 20210202, [[d00z9aqiHQ8iqLytsv5tsuJsQOtjvYQKQk5vsvMfjLBjvkAxK6xiLggHOJjrwgsXZiuzAeQY1KkSnHQQVrsKghjrCoPQI1juP5riDps0(KkvhuQuAHGQEijPMOuPWfbvkBuQQu(OuvvJuOQWjjuvTsHYmjj5McvfTtqXpbvQgQuvPAPcvLEkitfu6RsvvglOIZsOQSxi)vKbJ4WuTyK8yIMSuUmQnlPplWOLWPvSAqL0RjjmBrDBHSBL(nWWf0XjjQLRYZHA6uUobBNq57ivJNq48KuTEHkMpjSFvnQecweuZngbdnIKMsIKgrsJUKkr86hXPsqqM6Hmck0LQWdye06rmccE2X2tIpDSXN6iOqx9mWBiyrqyGWjzeuHzH44slTbJviqPLGiAXtKq2TbSYZRgT4jsslcIsyYM4FruiOMBmcgAejnLejnIKgDjvI41pISFqqUGvaoee0ePAeuX0A8IOqqnglrqWf4YtGNDS9K4thB8P(tIpewJVpgCbU8K(nM6e8t9NqJApHgrstjeuEWggblcQXvxiBiyrWucblcYL2aweKeiSgFjCbWqq86uzUHGhziyObblcYL2aweKaMtJXryeeVovMBi4rgcgXHGfb5sBalcYoFvzHjpXz2GeUayiiEDQm3qWJmemIhcweeVovMBi4rqYBm(ghbfESyPaztxs74qwAjqnzfCI(KBprHINuNGclDCKpl(jI(eAejcYL2aweKaMtJXryKHGPdeSiiEDQm3qWJGCPnGfbj9Co5sBaBkpydbLhSLwpIrqYggziyIFeSiiEDQm3qWJGK3y8nocYL2igN4LJgg)erFcniixAdyrqspNtU0gWMYd2qq5bBP1Jyee2qgcgvkcweeVovMBi4rqYBm(ghb5sBeJt8YrdJFs3FsjeKlTbSiiPNZjxAdyt5bBiO8GT06rmcsMzxmgzidbfESeer5gcwemLqWIGCPnGfbHfIIaBkKneeVovMBi4rgcgAqWIGCPnGfbrbmlZTun7QZn6ZgKmGiMfbXRtL5gcEKHGrCiyrq86uzUHGhbTEeJG84Gl8ZXPkyTeOMcb05db5sBalcYJdUWphNQG1sGAkeqNpKHGr8qWIG41PYCdbpck8yPJTKnrmcQKUdeKlTbSiiZVKDEicsEJX34iOty5k4cyngiKRGlGtCefFynVovMBprHINCclxbxaRxgJNnGUFQJt25HHZgK8Wq)CtaR51PYCdziy6ablcIxNkZne8iOWJLo2s2eXiOs6oqqU0gWIGOySnEor)CRabjVX4BCeu8EI5zEnnwYRLa1evgaAAEDQm3EsFpjEp5ewUcUawJbc5k4c4ehrXhwZRtL5gYqWe)iyrq86uzUHGhbfES0XwYMigbvsloeuJXYBcTbSiOUTbxfWg(jwb)KMW52a2N4B7jsai3a03NaQpPBXHS0EcO(eRGFs)n52t8T9K(9BI88te)l2MvA4NqP(tSc(jnHZTbSpbuFIVprylCSXTN0)QUB8e6f8(eRGvV8XpraZTNeESeer5M(jWZsxaZpPBXHS0EcO(eRGFs)n52toUjiz8t6Fv3nEcL6pHgrkYiSApXkg8tg8tkPf3tWSeSnSgb5sBalcYXHS0sGAYk4e9j3qqYBm(ghbfVN4XHVXyD4nrEonl2MvAynVovMBpPVNeVNWymVswZymVsobQjRGtvGuapBqAUbRJC4k4EsFpPZNWQSWegYnThhCHFoovbRLa1uiGoFprHINeVNWQSWegYnTuDzgyhyhzIk7y7jDHmemQueSiiEDQm3qWJGcpw6ylzteJGkP7ab1yS8MqBalcQBBWvbSHFIvWpPjCUnG9j(2EIeaYna99jG6tGNX245N0FNBfpX32tIp84WpbuFs81d4NqP(tSc(jnHZTbSpbuFIVprylCSXTN0)QUB8e6f8(eRGvV8XpraZTNeESeer5Mgb5sBalcIIX245e9ZTceK8gJVXrqEC4BmwhEtKNtZITzLgwZRtL52t67jX7jmgZRK1mgZRKtGAYk4ufifWZgKMBW6ihUcUN03t68jSklmHHCt7Xbx4NJtvWAjqnfcOZ3tuO4jX7jSklmHHCtlvxMb2b2rMOYo2EsxidziizdJGfbtjeSiiEDQm3qWJGK3y8nocsca5gG(QPySnEor)CRqFCKpl(jD)jItKiixAdyrq(kzSDEoj9CgziyObblcIxNkZne8ii5ngFJJGKaqUbOVAkgBJNt0p3k0hh5ZIFs3FI4ejcYL2aweuDoMkdanKHGrCiyrq86uzUHGhbjVX4BCeuNpHsOw10NClHdNBmSwi8jku8K49ejqmE9107euyPQZpPVNqjuRAhhYslbQjRGt0NCtle(K(EcLqTQPySnEor)CRqle(KUEsFpPZNuNGclDCKpl(jD)jsai3a0xnfFy(uXSb6MW52a2N07jnHZTbSprHIN05tm)cytxWE2k0Hs7jI(eX1XtuO4jX7jMN510QyYz(sZITzLMMxNkZTN01t66jku8K6euyPJJ8zXpr0NusCiixAdyrqu8H5tfZgGmemIhcweeVovMBi4rqYBm(ghb15tOeQvn9j3s4W5gdRfcFIcfpjEprceJxFn9obfwQ68t67juc1Q2XHS0sGAYk4e9j30cHpPVNqjuRAkgBJNt0p3k0cHpPRN03t68j1jOWshh5ZIFs3FIeaYna9vtLbGwQkCQRBcNBdyFsVN0eo3gW(efkEsNpX8lGnDb7zRqhkTNi6texhprHINeVNyEMxtRIjN5lnl2MvAAEDQm3EsxpPRNOqXtQtqHLooYNf)erFsP4hb5sBalcIkdaTuv4uhziy6ablcYL2aweuEckmCcUk0cI41qq86uzUHGhziyIFeSiiEDQm3qWJGK3y8nocIsOw1ooKLwcutwbNOp5Mwi8jku8K6euyPJJ8zXpr0Nqt8JGCPnGfbfcSbSidziiSHGfbtjeSiixAdyrqooKLwcutwbNOp5gcIxNkZne8idbdniyrq86uzUHGhbjVX4BCeeLqTQRhVXrDTq4t67juc1QUE8gh11hh5ZIFIOkFsGSHGCPnGfbr5hf3s4cGHmemIdblcIxNkZne8ii5ngFJJGoHLRGlG1yGqUcUaoXru8H186uzU9K(EI5xYopuFCKpl(jI(Kaz7j99ejaKBa6RUM9J1hh5ZIFIOpjq2qqU0gWIGm)s25HidbJ4HGfbXRtL5gcEeKlTbSiOA2pgbjVX4BCeK5xYopule(K(EYjSCfCbSgdeYvWfWjoIIpSMxNkZneuEwojBiiA6aziy6ablcYL2aweevgaA4cUHG41PYCdbpYqWe)iyrqU0gWIGOp5wcho3yyeeVovMBi4rgcgvkcweKlTbSiOA2vNBjCbWqq86uzUHGhziyujiyrq86uzUHGhbjVX4BCeeLqTQRzxD(WPi)uH(4iFw8te9jD8efkEI5xaB6c2ZwHouApruLpHgrIGCPnGfbPIjNt4cGHmem9dcweeVovMBi4rqYBm(ghbjbGCdqF1um2gpNOFUvOpoYNf)erFsjAEs)6jYc)cyCQEU0gW65N07jbY2t67jMN510yjVwcutuzaOP51PYC7jku8KQqoNoww4xaNSjIFIOpjq2EsFprca5gG(QPySnEor)CRqFCKpl(jku8eZVa202eXjdKAd)erFs)GGCPnGfbr5hf3s4cGHmemLejcweeVovMBi4rqYBm(ghbvbsb8t69ePJT0Xb8(erFsfifW6ixeiixAdyrqn2TIKSWvX5ridbtPsiyrq86uzUHGhbjVX4BCeeLqTQDCilTeOMScorFYnTq4tuO4j1jOWshh5ZIFIOpPuhiixAdyrqyZJc5gJmemLObblcYL2aweKNIeUgFjqnjpaDmcIxNkZne8idbtjXHGfbXRtL5gcEeK8gJVXrquc1QMIX245e9ZTcTq4tuO4j1jOWshh5ZIFIOpPKirqU0gWIGogdw3Mni53bOJmemLepeSiiEDQm3qWJGK3y8nocsca5gG(QPp5wcho3yy9Xr(S4N09NuQJNOqXtI3tKaX41xtVtqHLQo)efkEsDckS0Xr(S4Ni6tk1bcYL2aweefJTXZj6NBfidbtPoqWIGCPnGfbjlMiNppHlagcIxNkZne8idbtP4hblcIxNkZne8ii5ngFJJGOeQvnfJTXZj6NBfAHWNOqXtQtqHLooYNf)erFsjrIGCPnGfbDmgSUnBqYVdqhziykPsrWIG41PYCdbpcsEJX34iijaKBa6RM(KBjC4CJH1hh5ZIFs3FsPoEIcfpjEprceJxFn9obfwQ68tuO4j1jOWshh5ZIFIOpPuhiixAdyrqum2gpNOFUvGmemLujiyrqU0gWIGKftKZNNWfadbXRtL5gcEKHGPu)GGfb5sBalcsftoNKGOiFBiiEDQm3qWJmem0iseSiiEDQm3qWJGK3y8nocIsOw1um2gpNOFUvOBa67tuO4j1jOWshh5ZIFIOpPdeKlTbSiikpibQj7gPkWidbdnLqWIGCPnGfb1MJtuSJneeVovMBi4rgcgAObblcIxNkZne8ii5ngFJJG68jvGua)KU5tKaS9KEpPcKcy9Xb8(K(1t68jsai3a0xTkMCojbrr(20hh5ZIFs38jLEsxpP7pXL2awTkMCojbrr(20sa2EIcfprca5gG(QvXKZjjikY3M(4iFw8t6(tk9KEpjq2EsxprHIN05tOeQvnfJTXZj6NBfAHWNOqXtOeQv9Yy8Sb09tDCYopmC2GKhg6NBcyTq4t66j99K49Kty5k4cyTk7HzpXh3e2eD)sGRXNMxNkZTNOqXtQtqHLooYNf)erFI4qqU0gWIGKaQZt4cGHmem0ioeSiiEDQm3qWJGK3y8nocIsOw10NClHdNBmSwieb5sBalcIYpkULWfadziyOr8qWIG41PYCdbpcsEJX34iikHAvtXyB8CI(5wHUbOVprHINuNGclDCKpl(jI(KoqqU0gWIG8t6lNcfYygziyOPdeSiiEDQm3qWJGK3y8noc6ewUcUawJbc5k4c4ehrXhwZRtL52tuO4jNWYvWfW6LX4zdO7N64KDEy4Sbjpm0p3eWAEDQm3qqU0gWIGm)s25HidbdnXpcweeVovMBi4rqYBm(ghbDclxbxaRxgJNnGUFQJt25HHZgK8Wq)CtaR51PYCdb5sBalcQEmhNzds25HidbdnQueSiiEDQm3qWJGK3y8nocQZNubsb8t69KkqkG1hhW7t69KsD8KUEIOpPcKcyDKlceKlTbSii)K(YjdChVgYqgcsMzxmgblcMsiyrqU0gWIGCCilTeOMScorFYneeVovMBi4rgcgAqWIG41PYCdbpcYL2aweeLFuClHlagcsEJX34iikHAvxpEJJ6AHWN03tOeQvD94noQRpoYNf)erv(KazdbjvxM5K5xaByemLqgcgXHGfbXRtL5gcEeK8gJVXrqbY2t6MpHsOw1uSJTKmZUyS(4iFw8t6(tePMMoqqU0gWIGIeY2GlagYqWiEiyrq86uzUHGhbjVX4BCe0jSCfCbSgdeYvWfWjoIIpSMxNkZTN03tm)s25H6JJ8zXpr0NeiBpPVNibGCdqF11SFS(4iFw8te9jbYgcYL2aweK5xYopeziy6ablcIxNkZne8iixAdyrq1SFmcsEJX34iiZVKDEOwi8j99Kty5k4cyngiKRGlGtCefFynVovMBiO8SCs2qq00bYqWe)iyrq86uzUHGhbjVX4BCeufifWpP3tKo2shhW7te9jvGuaRJCrGGCPnGfb1y3ksYcxfNhHmemQueSiixAdyrq0NClHdNBmmcIxNkZne8idbJkbblcIxNkZne8iixAdyrqu(rXTeUayii5ngFJJGQc5C6yzHFbCYMi(jI(Kaz7j99ejaKBa6RMIX245e9ZTc9Xr(S4NOqXtKaqUbOVAkgBJNt0p3k0hh5ZIFIOpPenpP3tcKTN03tmpZRPXsETeOMOYaqtZRtL5gcsQUmZjZVa2WiykHmem9dcweKlTbSiikgBJNt0p3kqq86uzUHGhziykjseSiixAdyrqhJbRBZgK87a0rq86uzUHGhziykvcblcIxNkZne8ii5ngFJJGOeQvTJdzPLa1KvWj6tUPfcFIcfpPobfw64iFw8te9jL6ab5sBalccBEui3yKHGPeniyrqU0gWIGQzxDULWfadbXRtL5gcEKHGPK4qWIGCPnGfbPIjNt4cGHG41PYCdbpYqWus8qWIGCPnGfbjlMiNppHlagcIxNkZne8idbtPoqWIGCPnGfbrLbGgUGBiiEDQm3qWJmemLIFeSiixAdyrqEks4A8La1K8a0XiiEDQm3qWJmemLuPiyrq86uzUHGhbjVX4BCeeLqTQRhVXrD9Xr(S4N09NWIGLcgNSjIrqU0gWIGO878agziykPsqWIG41PYCdbpcsEJX34iOkqkGFs3FIeGTN07jU0gWQJeY2GlaMwcWgcYL2aweKkMCojbrr(2qgcMs9dcweeVovMBi4rqYBm(ghbrjuRAkgBJNt0p3k0na99jku8K6euyPJJ8zXpr0N0bcYL2aweeLhKa1KDJufyKHGHgrIGfb5sBalcQnhNOyhBiiEDQm3qWJmem0ucblcIxNkZne8iixAdyrqu(rXTeUayii5ngFJJGm)cytBteNmqQn8te9j9dcsQUmZjZVa2WiykHmem0qdcweeVovMBi4rqYBm(ghbvbsbS2MiozGuKlINi6tcKTN0VEcniixAdyrqsa15jCbWqgcgAehcweeVovMBi4rqYBm(ghbDclxbxaRXaHCfCbCIJO4dR51PYC7jku8Kty5k4cy9Yy8Sb09tDCYopmC2GKhg6NBcynVovMBiixAdyrqMFj78qKHGHgXdblcIxNkZne8ii5ngFJJGoHLRGlG1lJXZgq3p1Xj78WWzdsEyOFUjG186uzUHGCPnGfbvpMJZSbj78qKHGHMoqWIG41PYCdbpcsEJX34iOoFsfifWpP3tQaPawFCaVpP3teNiFsxpr0NubsbSoYfbcYL2aweKFsF5KbUJxdzidziiX4dpGfbdnIKMsISenLqq09BNnaJG6VUn(cJ4hM(pUp5jWwWpzIcbN9Kk4Es5WJLGik3k)KJvzH542tWGi(jUGbICJBprw4BaJ1Fmvnl)eXlUpr1Gvm(mU9KYNWYvWfWA4u(jg4jLpHLRGlG1WrZRtL5w5N42tGBWDv9KoljIU0Fmvnl)eXlUpr1Gvm(mU9KYNWYvWfWA4u(jg4jLpHLRGlG1WrZRtL5w5N0zjr0L(JPQz5N0rCFIQbRy8zC7jLnpZRPHt5NyGNu28mVMgoAEDQm3k)KoljIU0Fmvnl)KoI7tunyfJpJBpP8jSCfCbSgoLFIbEs5ty5k4cynC086uzUv(jU9e4gCxvpPZsIOl9h7J1FDB8fgXpm9FCFYtGTGFYefco7jvW9KYYgU8towLfMJBpbdI4N4cgiYnU9ezHVbmw)Xu1S8texCFIQbRy8zC7jLnpZRPHt5NyGNu28mVMgoAEDQm3k)KoljIU0Fmvnl)eXlUpr1Gvm(mU9KYMN510WP8tmWtkBEMxtdhnVovMBLFsNLerx6p2hR)624lmIFy6)4(KNaBb)KjkeC2tQG7jLXw5NCSklmh3EcgeXpXfmqKBC7jYcFdyS(JPQz5NqtCFIQbRy8zC7jLdztdhT4tR1LFIbEszXNwRl)KoPreDP)yQAw(jIlUpr1Gvm(mU9KYNWYvWfWA4u(jg4jLpHLRGlG1WrZRtL5w5N0zjr0L(JPQz5NiEX9jQgSIXNXTNu(ewUcUawdNYpXapP8jSCfCbSgoAEDQm3k)e3EcCdURQN0zjr0L(JPQz5N0pX9jQgSIXNXTNu28mVMgoLFIbEszZZ8AA4O51PYCR8t6SKi6s)Xu1S8tOHM4(evdwX4Z42tkFclxbxaRHt5NyGNu(ewUcUawdhnVovMBLFsNLerx6pMQMLFcnDe3NOAWkgFg3Es5ty5k4cynCk)ed8KYNWYvWfWA4O51PYCR8tC7jWn4UQEsNLerx6pMQMLFcnDe3NOAWkgFg3Es5ty5k4cynCk)ed8KYNWYvWfWA4O51PYCR8t6SKi6s)Xu1S8tOj(J7tunyfJpJBpP8jSCfCbSgoLFIbEs5ty5k4cynC086uzUv(jU9e4gCxvpPZsIOl9h7J1FDB8fgXpm9FCFYtGTGFYefco7jvW9KYYm7IXLFYXQSWCC7jyqe)exWarUXTNil8nGX6pMQMLFcnX9jQgSIXNXTNuoKnnC0IpTwx(jg4jLfFATU8t6Kgr0L(JPQz5NiU4(evdwX4Z42tkhYMgoAXNwRl)ed8KYIpTwx(jDwseDP)yQAw(jIxCFIQbRy8zC7jLpHLRGlG1WP8tmWtkFclxbxaRHJMxNkZTYpPZsIOl9htvZYpPJ4(evdwX4Z42tkFclxbxaRHt5NyGNu(ewUcUawdhnVovMBLFIBpbUb3v1t6SKi6s)Xu1S8tujX9jQgSIXNXTNu28mVMgoLFIbEszZZ8AA4O51PYCR8tC7jWn4UQEsNLerx6pMQMLFsjvACFIQbRy8zC7jLdztdhT4tR1LFIbEszXNwRl)KoljIU0Fmvnl)eAexCFIQbRy8zC7jLpHLRGlG1WP8tmWtkFclxbxaRHJMxNkZTYpXTNa3G7Q6jDwseDP)yQAw(j0iU4(evdwX4Z42tkFclxbxaRHt5NyGNu(ewUcUawdhnVovMBLFsNLerx6pMQMLFcnIxCFIQbRy8zC7jLpHLRGlG1WP8tmWtkFclxbxaRHJMxNkZTYpXTNa3G7Q6jDwseDP)yFmXFui4mU9KoEIlTbSpjpydR)yiiCilrWqthIdbfEG6KzeeCbU8e4zhBpj(0XgFQ)K4dH147JbxGlpPFJPob)u)j0O2tOrK0u6J9XCPnGfRdpwcIOCtjwikcSPq2(yU0gWI1HhlbruU1tjTuaZYClvZU6CJ(SbjdiIz)yU0gWI1HhlbruU1tjTcyonghP26rSspo4c)CCQcwlbQPqaD((yU0gWI1HhlbruU1tjTMFj78q1cpw6ylzteRSKUd1MQYty5k4cyngiKRGlGtCefFyfkoHLRGlG1lJXZgq3p1Xj78WWzdsEyOFUjG)yU0gWI1HhlbruU1tjTum2gpNOFUvOw4XshBjBIyLL0DO2uvgpZZ8AASKxlbQjQma06lENWYvWfWAmqixbxaN4ik(WFm4Yt62gCvaB4Nyf8tAcNBdyFIVTNibGCdqFFcO(KUfhYs7jG6tSc(j93KBpX32t63VjYZpr8VyBwPHFcL6pXk4N0eo3gW(eq9j((eHTWXg3Es)R6UXtOxW7tScw9Yh)ebm3Es4XsqeLB6NaplDbm)KUfhYs7jG6tSc(j93KBp54MGKXpP)vD34juQ)eAePiJWQ9eRyWpzWpPKwCpbZsW2W6pMlTbSyD4XsqeLB9usRJdzPLa1KvWj6tUPw4XshBjBIyLL0ItTPQmEEC4BmwhEtKNtZITzLgwZRtL5wFXJXyELSMXyELCcutwbNQaPaE2G0Cdwh5WvW1xNSklmHHCt7Xbx4NJtvWAjqnfcOZNcfXJvzHjmKBAP6YmWoWoYev2XwxFm4Yt62gCvaB4Nyf8tAcNBdyFIVTNibGCdqFFcO(e4zSnE(j935wXt8T9K4dpo8ta1NeF9a(juQ)eRGFst4CBa7ta1N47te2chBC7j9VQ7gpHEbVpXky1lF8teWC7jHhlbruUP)yU0gWI1HhlbruU1tjTum2gpNOFUvOw4XshBjBIyLL0DO2uv6XHVXyD4nrEonl2MvAynVovMB9fpgJ5vYAgJ5vYjqnzfCQcKc4zdsZnyDKdxbxFDYQSWegYnThhCHFoovbRLa1uiGoFkuepwLfMWqUPLQlZa7a7ituzhBD9X(yU0gWI7PKwjqyn(s4cG9XCPnGf3tjTcyonghH)yU0gWI7PKw78vLfM8eNzds4cG9XCPnGf3tjTcyonghHvBQkdpwSuGSPlPDCilTeOMScorFYnfkQtqHLooYNflknI8J5sBalUNsALEoNCPnGnLhSP26rSszd)XCPnGf3tjTspNtU0gWMYd2uB9iwj2uBQkDPnIXjE5OHXIsZhZL2awCpL0k9Co5sBaBkpytT1JyLYm7IXQnvLU0gX4eVC0W4Ux6J9XCPnGfRLnSsFLm2opNKEoR2uvkbGCdqF1um2gpNOFUvOpoYNf3DXjYpMlTbSyTSH7PK26CmvgaAQnvLsai3a0xnfJTXZj6NBf6JJ8zXDxCI8J5sBalwlB4EkPLIpmFQy2a1MQYoPeQvn9j3s4W5gdRfcvOiEsGy86RP3jOWsvN7JsOw1ooKLwcutwbNOp5MwiSpkHAvtXyB8CI(5wHwiSR(6Sobfw64iFwC3LaqUbOVAk(W8PIzd0nHZTbS9AcNBdyvOOtZVa20fSNTcDO0evCDOqr8mpZRPvXKZ8LMfBZkTU6sHI6euyPJJ8zXIwsCFmxAdyXAzd3tjTuzaOLQcN6QnvLDsjuRA6tULWHZngwleQqr8KaX41xtVtqHLQo3hLqTQDCilTeOMScorFYnTqyFuc1QMIX245e9ZTcTqyx91zDckS0Xr(S4UlbGCdqF1uzaOLQcN66MW52a2EnHZTbSku0P5xaB6c2ZwHouAIkUouOiEMN510QyYz(sZITzLwxDPqrDckS0Xr(Syrlf)FmxAdyXAzd3tjT5jOWWj4QqliIx7J5sBalwlB4EkPneydyvBQkPeQvTJdzPLa1KvWj6tUPfcvOOobfw64iFwSO0e)FSpMlTbSyTmZUySshhYslbQjRGt0NC7J5sBalwlZSlg3tjTu(rXTeUayQjvxM5K5xaByLLuBQkdzth5ZQPeQvD94noQRfc7lKnDKpRMsOw11J34OU(4iFwSOkdKTpMlTbSyTmZUyCpL0gjKTbxam1MQYazRBgYMoYNvtjuRAk2XwsMzxmwFCKplU7IutthFmxAdyXAzMDX4EkP18lzNhQ2uvEclxbxaRXaHCfCbCIJO4d3N5xYopuFCKplw0azRpjaKBa6RUM9J1hh5ZIfnq2(yU0gWI1Ym7IX9usBn7hRwEwojBkPPd1MQsZVKDEOwiSVty5k4cyngiKRGlGtCefF4pMlTbSyTmZUyCpL02y3ksYcxfNhP2uvwbsbCpPJT0Xb8kAfifW6ixeFmxAdyXAzMDX4EkPL(KBjC4CJH)yU0gWI1Ym7IX9uslLFuClHlaMAs1Lzoz(fWgwzj1MQYQqoNoww4xaNSjIfnq26tca5gG(QPySnEor)CRqFCKplwHcjaKBa6RMIX245e9ZTc9Xr(SyrlrtVazRpZZ8AASKxlbQjQma0(yU0gWI1Ym7IX9uslfJTXZj6NBfFmxAdyXAzMDX4EkP9ymyDB2GKFhG(hZL2awSwMzxmUNsAXMhfYnwTPQKsOw1ooKLwcutwbNOp5MwiuHI6euyPJJ8zXIwQJpMlTbSyTmZUyCpL0wZU6ClHla2hZL2awSwMzxmUNsAvXKZjCbW(yU0gWI1Ym7IX9usRSyIC(8eUayFmxAdyXAzMDX4EkPLkdanCb3(yU0gWI1Ym7IX9usRNIeUgFjqnjpaD8hZL2awSwMzxmUNsAP878awTPQmKnDKpRMsOw11J34OU(4iFwC3zrWsbJt2eXFmxAdyXAzMDX4EkPvftoNKGOiFBQnvLvGua3DjaB9CPnGvhjKTbxamTeGTpMlTbSyTmZUyCpL0s5bjqnz3ivbwTPQKsOw1um2gpNOFUvOBa6Rcf1jOWshh5ZIfTJpMlTbSyTmZUyCpL02MJtuSJTpMlTbSyTmZUyCpL0s5hf3s4cGPMuDzMtMFbSHvwsTPQ08lGnTnrCYaP2WI2pFmxAdyXAzMDX4EkPvcOopHlaMAtvzfifWABI4KbsrUienq26x08XCPnGfRLz2fJ7PKwZVKDEOAtv5jSCfCbSgdeYvWfWjoIIpScfNWYvWfW6LX4zdO7N64KDEy4Sbjpm0p3eWFmxAdyXAzMDX4EkPTEmhNzds25HQnvLNWYvWfW6LX4zdO7N64KDEy4Sbjpm0p3eWFmxAdyXAzMDX4EkP1pPVCYa3XRP2uv2zfifW9QaPawFCaV9eNi7s0kqkG1rUi(yFmxAdyXASP0XHS0sGAYk4e9j3(yU0gWI1yRNsAP8JIBjCbWuBQkdzth5ZQPeQvD94noQRfc7lKnDKpRMsOw11J34OU(4iFwSOkdKTpMlTbSyn26PKwZVKDEOAtv5jSCfCbSgdeYvWfWjoIIpCFMFj78q9Xr(SyrdKT(KaqUbOV6A2pwFCKplw0az7J5sBalwJTEkPTM9JvlplNKnL00HAtvP5xYopule23jSCfCbSgdeYvWfWjoIIp8hZL2awSgB9uslvgaA4cU9XCPnGfRXwpL0sFYTeoCUXWFmxAdyXAS1tjT1SRo3s4cG9XCPnGfRXwpL0QIjNt4cGP2uvsjuR6A2vNpCkYpvOpoYNflAhkuy(fWMUG9SvOdLMOkPrKFmxAdyXAS1tjTu(rXTeUayQnvLsai3a0xnfJTXZj6NBf6JJ8zXIwIM(LSWVagNQNlTbSEUxGS1N5zEnnwYRLa1evgaAkuufY50XYc)c4KnrSObYwFsai3a0xnfJTXZj6NBf6JJ8zXkuy(fWM2MiozGuByr7NpMlTbSyn26PK2g7wrsw4Q48i1MQYkqkG7jDSLooGxrRaPawh5I4J5sBalwJTEkPfBEui3y1MQskHAv74qwAjqnzfCI(KBAHqfkQtqHLooYNflAPo(yU0gWI1yRNsA9uKW14lbQj5bOJ)yU0gWI1yRNsApgdw3Mni53bOR2uvsjuRAkgBJNt0p3k0cHkuuNGclDCKplw0sI8J5sBalwJTEkPLIX245e9ZTc1MQsjaKBa6RM(KBjC4CJH1hh5ZI7EPouOiEsGy86RP3jOWsvNvOOobfw64iFwSOL64J5sBalwJTEkPvwmroFEcxaSpMlTbSyn26PK2JXG1Tzds(Da6QnvLuc1QMIX245e9ZTcTqOcf1jOWshh5ZIfTKi)yU0gWI1yRNsAPySnEor)CRqTPQuca5gG(QPp5wcho3yy9Xr(S4UxQdfkINeigV(A6DckSu1zfkQtqHLooYNflAPo(yU0gWI1yRNsALftKZNNWfa7J5sBalwJTEkPvftoNKGOiFBFmxAdyXAS1tjTuEqcut2nsvGvBQkPeQvnfJTXZj6NBf6gG(QqrDckS0Xr(Syr74J5sBalwJTEkPTnhNOyhBFmxAdyXAS1tjTsa15jCbWuBQk7ScKc4UPeGTEvGuaRpoG3(vNsai3a0xTkMCojbrr(20hh5ZI7ML6Q7U0gWQvXKZjjikY3MwcWMcfsai3a0xTkMCojbrr(20hh5ZI7EPEbYwxku0jLqTQPySnEor)CRqleQqbLqTQxgJNnGUFQJt25HHZgK8Wq)CtaRfc7QV4DclxbxaRvzpm7j(4MWMO7xcCn(uOOobfw64iFwSOI7J5sBalwJTEkPLYpkULWfatTPQKsOw10NClHdNBmSwi8J5sBalwJTEkP1pPVCkuiJz1MQskHAvtXyB8CI(5wHUbOVkuuNGclDCKplw0o(yU0gWI1yRNsAn)s25HQnvLNWYvWfWAmqixbxaN4ik(WkuCclxbxaRxgJNnGUFQJt25HHZgK8Wq)Cta)XCPnGfRXwpL0wpMJZSbj78q1MQYty5k4cy9Yy8Sb09tDCYopmC2GKhg6NBc4pMlTbSyn26PKw)K(YjdChVMAtvzNvGua3RcKcy9Xb82RuhDjAfifW6ixeidziea]] )

end
