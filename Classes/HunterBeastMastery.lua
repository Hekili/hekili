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


    spec:RegisterPack( "Beast Mastery", 20201216, [[dW0B)aqisL6rsqQnPuYNefJsPWPukAvsqvVcumlsvULsLWUi5xOunmsbhtcTmuINrk00KG4AkLABKk03KGIXjbLoNsL06iv08ifDpsP9PuPoiPcSquspKuvnrLkrxeuf9rsLuJucs4KKkOvkkntukDtjiPDQu1pbvHHkbjAPsqLNcYubL(kPs0yvQ4SKkj7fYFfzWO6WuTyu8yIMSKUmYMvYNfy0s0PLA1KkHxJsXSf62IQDR43QA4c64GQ0Yv55qnDkxNGTdQ8Dcz8GQ68sG1tQkZNqTFGrfrWIGQUrO9SObw0qrwkQJknSRAqhzbbzfesiOqxYgpGqqJNtiiwjhBaEHQJn6kabf6feFVIGfbHFHtsiOsZcX6KD2dARuGrj)C2XDUq0T(h55lJDCNlzhbXi0rthoigeu1ncTNfnWIgkYsrDuPHDvd6yXDfb5cw5FiiOox)iOYUwPbXGGQewIGk0aoRKJnaVq1XgDfa4fkegJoq2cnGVljjLZqhGxuJ6b4SObw0ack2ydJGfbvPLleneSO9frWIGCP1)GGKVWy0LWLVHGOXzIufXkYq7zbblcIgNjsveRiixA9pii5lmgDjC5Bii51gDTJGoHHw)fqkmfwkOpCk8Ez0ZDR)rrJZePkGlwmGJFHitpv10f44K9FeNc)g)JIgNjsvaxSyaFdax(tvOn1rWrh2JPFLw)zcdPOXzIufW3cW1nGFcdT(lGuykSuqF4u49YON7w)JIgNjsvaFteuShkjRiinQbKH2RreSiixA9piibmLAJYXiiACMivrSIm0(cbblcYLw)dcYoFGxHo26RNGeU8neenotKQiwrgA)2iyrq04mrQIyfbjV2ORDeu4rWLcKvvrLJdjPL(vYkPKOowbCXIb8vhuAPJY9EWaUMaolAab5sR)bbjGPuBuogzO96icweenotKQiwrqU06FqqspgtU06FsXgBiOyJT045ecswXidTVWGGfbrJZePkIveK8AJU2rqU0A4OenuEtyaxtaNfeKlT(heK0JXKlT(NuSXgck2ylnEoHGWgYq7lSiyrq04mrQIyfbjV2ORDeKlTgokrdL3egW3nGxeb5sR)bbj9ym5sR)jfBSHGIn2sJNtiizKC4iKHmeu4rYpNXneSO9frWIGCP1)GGWc55)KcjdbrJZePkIvKH2ZccweKlT(heeZBwKQPv0lGQI6jizp87bbrJZePkIvKH2RreSiiACMivrSIGgpNqqU(WL(5406hl9Ru4lIoeKlT(heKRpCPFooT(Xs)kf(IOdzO9fccweenotKQiwrqHhjDSLSoNqqfvBJGCP1)GGm)s25Hii51gDTJGoHHw)fqk8lex)fqjkNHoSIgNjsvaxSya)egA9xaPgcJ7jqKFfGt25HH9eK8Wq)CtaROXzIufzO9BJGfbrJZePkIveu4rshBjRZjeur12iixA9piigcBThtIo3krqYRn6AhbPBa38inMclPXs)kXe)VQOXzIufW3cW1nGFcdT(lGu4xiU(lGsuodDyfnotKQidTxhrWIGOXzIufXkcYLw)dcswGm(29tltmrhBii51gDTJG0nGFExteC0yQEGtio05mrsrWVXggW3cW3aWTRh2qMQOQ0Xj5)X6lAaCyaC76HnKPyrv64K8)y9fnaUMaolaUyXaobVcDyivvW5x7mrk1JrdUTcsbDGd3hT0JLDm6wpbPJCP9hGVjcIwlsAPXZjeKSaz8T7NwMyIo2qgAFHbblcIgNjsveRiOWJKo2swNtiOIknIGCP1)GGCCijT0VswjLe1XkcsETrx7iiDd4U(ORnsfEDUht9GTEKgwrJZePkGVfGRBaNWyAKKIWyAKu6xjRKsRxkG7ji1xJv5UU4paFlaFdaNGxHomKQkxF4s)CCA9JL(vk8frhGlwmGRBaNGxHomKQkzbY4B3pTmXeDSb4BIm0(clcweenotKQiwrqHhjDSLSoNqqfvBJGCP1)GGyiS1Emj6CRebjV2ORDeKRp6AJuHxN7XupyRhPHv04mrQc4Bb46gWjmMgjPimMgjL(vYkP06Lc4Ecs91yvURl(dW3cW3aWj4vOddPQY1hU0phNw)yPFLcFr0b4Ifd46gWj4vOddPQswGm(29tltmrhBa(MidziizfJGfTVicweenotKQiwrqYRn6Ahbj)pwFrJIHWw7XKOZTs1r5EpyaF3aUg1acYLw)dcYhjHTZJjPhJidTNfeSiiACMivrSIGKxB01ocs(FS(IgfdHT2JjrNBLQJY9EWa(UbCnQbeKlT(he0QpIj(FfzO9AeblcIgNjsveRii51gDTJG2aWzewlLOowt4W(AdRecbCXIbCDd4YhoA8XuthuAPLta(waoJWAPCCijT0VswjLe1XQsieW3cWzewlfdHT2JjrNBLkHqaFtaFlaFdaF1bLw6OCVhmGVBax(FS(IgfdDy6ytpbQQW5w)dGddGxfo36FaCXIb8naCZVaYuLKhTsvO0aCnbCnUnGlwmGRBa38inMInDmsxQhS1J0u04mrQc4Bc4Bc4Ifd4RoO0shL79GbCnb8IAeb5sR)bbXqhMo20taYq7leeSiiACMivrSIGKxB01ocAdaNryTuI6ynHd7RnSsieWflgW1nGlF4OXhtnDqPLwob4Bb4mcRLYXHK0s)kzLusuhRkHqaFlaNryTume2ApMeDUvQecb8nb8Ta8na8vhuAPJY9EWa(UbC5)X6lAumX)RPLWvGQkCU1)a4Wa4vHZT(haxSyaFda38lGmvj5rRufknaxtaxJBd4Ifd46gWnpsJPythJ0L6bB9infnotKQa(Ma(MaUyXa(QdkT0r5EpyaxtaVOoIGCP1)GGyI)xtlHRaKH2VncweKlT(heuSdknCsxiudYPXqq04mrQIyfzO96icweenotKQiwrqYRn6AhbXiSwkhhssl9RKvsjrDSQecbCXIb8vhuAPJY9EWaUMaol6icYLw)dck8T(hKHmee2qWI2xeblcYLw)dcYXHK0s)kzLusuhRiiACMivrSIm0EwqWIGOXzIufXkcsETrx7iigH1sToA0xbkHqaFlaNryTuRJg9vG6OCVhmGRPwapqwrqU06Fqqm(Xq1eU8nKH2RreSiiACMivrSIGKxB01oc6egA9xaPWVqC9xaLOCg6WkACMivb8TaCZVKDEO6OCVhmGRjGhiRa(waU8)y9fnQv0psDuU3dgW1eWdKveKlT(heK5xYopezO9fccweenotKQiwrqU06FqqROFecsETrx7iiZVKDEOsieW3cWpHHw)fqk8lex)fqjkNHoSIgNjsveuShkjRiiw2gzO9BJGfb5sR)bbXe)VIlPkcIgNjsveRidTxhrWIGCP1)GGe1XAch2xByeenotKQiwrgAFHbblcYLw)dcAf9cOAcx(gcIgNjsveRidTVWIGfbrJZePkIveK8AJU2rqmcRLAf9cOdNY9JnQJY9EWaUMa(2aUyXaU5xazQsYJwPkuAaUMAbCw0acYLw)dcInDmMWLVHm0(DfblcIgNjsveRii51gDTJGK)hRVOrXqyR9ys05wP6OCVhmGRjGxKfaVWd4Ys)ciCADU06F8iGddGhiRa(waU5rAmfwsJL(vIj(FvrJZePkGlwmGVeIX0rYs)cOK15eGRjGhiRa(waU8)y9fnkgcBThtIo3kvhL79GbCXIbCZVaYuwNtj7t1MaCnb8Dfb5sR)bbX4hdvt4Y3qgAFrnGGfbrJZePkIveK8AJU2rqRxkGbCyaCPJT0rb0a4Ac4RxkGv5o8rqU06FqqvYTYKS0zZ55idTVyreSiiACMivrSIGKxB01ocIryTuooKKw6xjRKsI6yvjec4Ifd4RoO0shL79GbCnb8IBJGCP1)GGWMNhsvczO9fzbblcYLw)dcYt5cxLU0VsY7fHrq04mrQIyfzO9f1icweenotKQiwrqYRn6AhbXiSwkgcBThtIo3kvcHaUyXa(QdkT0r5EpyaxtaVOgqqU06FqqhH)XTEcs(DViKH2xSqqWIGOXzIufXkcsETrx7ii5)X6lAuI6ynHd7RnS6OCVhmGVBaV42aUyXaUUbC5dhn(yQPdkT0YjaxSyaF1bLw6OCVhmGRjGxCBeKlT(heedHT2JjrNBLidTV42iyrqU06FqqYYo3PZt4Y3qq04mrQIyfzO9f1reSiiACMivrSIGKxB01ocIryTume2ApMeDUvQecbCXIb8vhuAPJY9EWaUMaErnGGCP1)GGoc)JB9eK87EridTVyHbblcIgNjsveRii51gDTJGK)hRVOrjQJ1eoSV2WQJY9EWa(Ub8IBd4Ifd46gWLpC04JPMoO0slNaCXIb8vhuAPJY9EWaUMaEXTrqU06Fqqme2ApMeDUvIm0(IfweSiixA9piizzN705jC5BiiACMivrSIm0(I7kcweKlT(heeB6ymj)8CFQiiACMivrSIm0Ew0acweenotKQiwrqYRn6AhbXiSwkgcBThtIo3kv1x0a4Ifd4RoO0shL79GbCnb8TrqU06FqqmEq6xj7AjBWidTNLIiyrqU06Fqq1(Oed5ydbrJZePkIvKH2Zcliyrq04mrQIyfbjV2ORDe0ga(6LcyaFxa4YhBaoma(6Lcy1rb0a4fEaFdax(FS(IgfB6ymj)8CFQQJY9EWa(UaWlc4Bc47gWDP1)OythJj5NN7tvjFSb4Ifd4Y)J1x0OythJj5NN7tvDuU3dgW3nGxeWHbWdKvaFtaxSyaFdaNryTume2ApMeDUvQecbCXIbCgH1sneg3tGi)kaNSZdd7ji5HH(5Mawjec4Bc4Bb46gWpHHw)fqk41dJEIoQkmjr(L(RsNIgNjsvaxSyaF1bLw6OCVhmGRjGRreKlT(heK8zopHlFdzO9SOreSiiACMivrSIGKxB01ocIryTuI6ynHd7RnSsieb5sR)bbX4hdvt4Y3qgAplfccweenotKQiwrqYRn6AhbXiSwkgcBThtIo3kv1x0a4Ifd4RoO0shL79GbCnb8TrqU06Fqq(j9HsHcrmHm0Ew2gblcIgNjsveRii51gDTJGoHHw)fqk8lex)fqjkNHoSIgNjsvaxSya)egA9xaPgcJ7jqKFfGt25HH9eK8Wq)CtaROXzIufb5sR)bbz(LSZdrgApl6icweenotKQiwrqYRn6AhbDcdT(lGudHX9eiYVcWj78WWEcsEyOFUjGv04mrQIGCP1)GGwhr6RNGKDEiYqgcsgjhocblAFreSiixA9piihhssl9RKvsjrDSIGOXzIufXkYq7zbblcIgNjsveRiixA9piig)yOAcx(gcsETrx7iigH1sToA0xbkHqaFlaNryTuRJg9vG6OCVhmGRPwapqwrqYcKrkz(fqggTViYq71icweenotKQiwrqYRn6AhbfiRa(UaWzewlfd5yljJKdhPok37bd47gW1GILTrqU06Fqq5crRXLVHm0(cbblcIgNjsveRii51gDTJGoHHw)fqk8lex)fqjkNHoSIgNjsvaFla38lzNhQok37bd4Ac4bYkGVfGl)pwFrJAf9JuhL79GbCnb8azfb5sR)bbz(LSZdrgA)2iyrq04mrQIyfb5sR)bbTI(rii51gDTJGm)s25HkHqaFla)egA9xaPWVqC9xaLOCg6WkACMivrqXEOKSIGyzBKH2RJiyrq04mrQIyfbjV2ORDe06Lcyahgax6ylDuanaUMa(6LcyvUdFeKlT(heuLCRmjlD2CEoYq7lmiyrqU06FqqI6ynHd7RnmcIgNjsveRidTVWIGfbrJZePkIveKlT(heeJFmunHlFdbjV2ORDe0sigthjl9lGswNtaUMaEGSc4Bb4Y)J1x0OyiS1Emj6CRuDuU3dgWflgWL)hRVOrXqyR9ys05wP6OCVhmGRjGxKfahgapqwb8TaCZJ0ykSKgl9Ret8)QIgNjsveKSazKsMFbKHr7lIm0(DfblcYLw)dcIHWw7XKOZTseenotKQiwrgAFrnGGfb5sR)bbDe(h36ji539Iqq04mrQIyfzO9flIGfbrJZePkIveK8AJU2rqmcRLYXHK0s)kzLusuhRkHqaxSyaF1bLw6OCVhmGRjGxCBeKlT(hee288qQsidTViliyrqU06FqqROxavt4Y3qq04mrQIyfzO9f1icweKlT(heeB6ymHlFdbrJZePkIvKH2xSqqWIGCP1)GGKLDUtNNWLVHGOXzIufXkYq7lUncweKlT(heet8)kUKQiiACMivrSIm0(I6icweKlT(heKNYfUkDPFLK3lcJGOXzIufXkYq7lwyqWIGOXzIufXkcsETrx7iigH1sToA0xbQJY9EWa(UbCc(KuWOK15ecYLw)dcIXVZdiKH2xSWIGfbrJZePkIveK8AJU2rqRxkGb8Dd4YhBaomaUlT(hvUq0AC5Bk5JneKlT(heeB6ymj)8CFQidTV4UIGfbrJZePkIveK8AJU2rqmcRLIHWw7XKOZTsv9fnaUyXa(QdkT0r5EpyaxtaFBeKlT(heeJhK(vYUwYgmYq7zrdiyrqU06Fqq1(Oed5ydbrJZePkIvKH2ZsreSiiACMivrSIGCP1)GGy8JHQjC5Bii51gDTJGm)citzDoLSpvBcW1eW3veKSazKsMFbKHr7lIm0EwybblcIgNjsveRii51gDTJGwVuaRSoNs2NYD4d4Ac4bYkGx4bCwqqU06FqqYN58eU8nKH2ZIgrWIGOXzIufXkcsETrx7iOtyO1FbKc)cX1FbuIYzOdROXzIufWflgWpHHw)fqQHW4Ece5xb4KDEyypbjpm0p3eWkACMivrqU06FqqMFj78qKH2ZsHGGfbrJZePkIveK8AJU2rqNWqR)ci1qyCpbI8RaCYopmSNGKhg6NBcyfnotKQiixA9piO1rK(6jizNhImKHmeeC0H7Fq7zrdSOHISuuJiir(n9eGrq6sDqHBVoCVUwNaoGdBjb4DE4FgGV(dWZuPLleTma(rWRqFufWXFob4UG95Urvaxw6taHvGSSThcWzrNaU()bo6mQc4zoHHw)fqQDYa42d4zoHHw)fqQDu04mrQMbW3Oi83ubYY2EiaNfDc46)h4OZOkGN5egA9xaP2jdGBpGN5egA9xaP2rrJZePAgaFJIWFtfilB7HaCw0jGR)FGJoJQaEg5pvH2u7KbWThWZi)Pk0MAhfnotKQza8nkc)nvGSSThcWzrNaU()bo6mQc4zWVqKPNQANmaU9aEg8lez6PQ2rrJZePAgaFJIWFtfiliRUuhu42Rd3RR1jGd4WwsaENh(Nb4R)a8mHhj)Cg3Ya4hbVc9rvah)5eG7c2N7gvbCzPpbewbYY2EiaVq0jGR)FGJoJQaEMtyO1FbKANmaU9aEMtyO1FbKAhfnotKQzaC3aC4j8GTa(gfH)Mkqw22db4fIobC9)dC0zufWZCcdT(lGu7KbWThWZCcdT(lGu7OOXzIundGVrr4VPcKLT9qa(26eW1)pWrNrvapJ5rAm1ozaC7b8mMhPXu7OOXzIundGVrr4VPcKLT9qa(26eW1)pWrNrvapZjm06VasTtga3EapZjm06VasTJIgNjs1maUBao8eEWwaFJIWFtfiliRUuhu42Rd3RR1jGd4WwsaENh(Nb4R)a8mYkodGFe8k0hvbC8NtaUlyFUBufWLL(eqyfilB7HaCnQtax))ahDgvb8mMhPXu7KbWThWZyEKgtTJIgNjs1ma(gfH)Mkqw22db4fIobC9)dC0zufWZyEKgtTtga3EapJ5rAm1okACMivZa4Bue(BQazbz1L6Gc3ED4EDTobCah2scW78W)maF9hGNbBza8JGxH(OkGJ)CcWDb7ZDJQaUS0NacRazzBpeGZIobC9)dC0zufWZesMAhLUsPuzaC7b8m6kLsLbW3Gf4VPcKLT9qaUg1jGR)FGJoJQaEMtyO1FbKANmaU9aEMtyO1FbKAhfnotKQza8nkc)nvGSSThcWleDc46)h4OZOkGN5egA9xaP2jdGBpGN5egA9xaP2rrJZePAga3nahEcpylGVrr4VPcKLT9qa(UQtax))ahDgvb8mMhPXu7KbWThWZyEKgtTJIgNjs1ma(gfH)Mkqw22db4SWIobC9)dC0zufWZCcdT(lGu7KbWThWZCcdT(lGu7OOXzIundGVrr4VPcKLT9qaolBRtax))ahDgvb8mNWqR)ci1ozaC7b8mNWqR)ci1okACMivZa4Ub4Wt4bBb8nkc)nvGSSThcWzzBDc46)h4OZOkGN5egA9xaP2jdGBpGN5egA9xaP2rrJZePAgaFJIWFtfilB7HaCw0rDc46)h4OZOkGN5egA9xaP2jdGBpGN5egA9xaP2rrJZePAga3nahEcpylGVrr4VPcKfKvxQdkC71H7116eWbCyljaVZd)Za81FaEgzKC4Oma(rWRqFufWXFob4UG95Urvaxw6taHvGSSThcWzrNaU()bo6mQc4zcjtTJsxPuQmaU9aEgDLsPYa4BWc83ubYY2EiaxJ6eW1)pWrNrvaptizQDu6kLsLbWThWZORukvgaFJIWFtfilB7Ha8crNaU()bo6mQc4zoHHw)fqQDYa42d4zoHHw)fqQDu04mrQMbW3Oi83ubYY2EiaFBDc46)h4OZOkGN5egA9xaP2jdGBpGN5egA9xaP2rrJZePAga3nahEcpylGVrr4VPcKLT9qaEHvNaU()bo6mQc4zmpsJP2jdGBpGNX8inMAhfnotKQzaC3aC4j8GTa(gfH)Mkqw22db4flm6eW1)pWrNrvaptizQDu6kLsLbWThWZORukvgaFJIWFtfilB7HaCw0OobC9)dC0zufWZCcdT(lGu7KbWThWZCcdT(lGu7OOXzIundG7gGdpHhSfW3Oi83ubYY2EiaNfnQtax))ahDgvb8mNWqR)ci1ozaC7b8mNWqR)ci1okACMivZa4Bue(BQazzBpeGZsHOtax))ahDgvb8mNWqR)ci1ozaC7b8mNWqR)ci1okACMivZa4Ub4Wt4bBb8nkc)nvGSGS6W8W)mQc4Bd4U06Fa8yJnScKfbfE)QJecQqd4Sso2a8cvhB0vaGxOqym6azl0a(UKKuodDaErnQhGZIgyrdGSGSU06FWQWJKFoJBAXc55)KcjdK1Lw)dwfEK8ZzCdgTSZ8MfPAAf9cOQOEcs2d)EazDP1)GvHhj)Cg3Grl7cyk1gLR345KwxF4s)CCA9JL(vk8frhiRlT(hSk8i5NZ4gmAz38lzNhQx4rshBjRZjTfvBRxV0EcdT(lGu4xiU(lGsuodDyXIpHHw)fqQHW4Ece5xb4KDEyypbjpm0p3eWGSU06FWQWJKFoJBWOLDgcBThtIo3k1l8iPJTK15K2IQT1RxA1T5rAmfwsJL(vIj(FDlDFcdT(lGu4xiU(lGsuodDyqwxA9pyv4rYpNXny0YUaMsTr56rRfjT045KwzbY4B3pTmXeDSPxV0Q7Z7AIGJgt1dCcXHoNjskc(n2WBTHD9WgYufvLooj)pwFrdm21dBitXIQ0Xj5)X6lA0KfXIj4vOddPQco)ANjsPEmAWTvqkOdC4(OLESSJr36jiDKlT)2eKTqd46GQUqaBya3kjaVkCU1)a4(ubC5)X6lAa8Fb46aCijna)xaUvsaUUSJva3NkGxO86Cpc46WbB9inmGZuaGBLeGxfo36Fa8Fb4(a4ctPJnQc46A9VlbCrL0a4wjvqMJaCbmvb8WJKFoJBkaNvs6cycW1b4qsAa(VaCRKaCDzhRa(rvbjHbCDT(3LaotbaolAqd5y9aCRSXaEJb8Iknc4ys(tfRazDP1)GvHhj)Cg3Grl7ooKKw6xjRKsI6yvVWJKo2swNtAlQ0OE9sRUD9rxBKk86CpM6bB9inSIgNjs1T0nHX0ijfHX0iP0VswjLwVua3tqQVgRYDDXFBTbbVcDyivvU(WL(5406hl9Ru4lIoXI1nbVcDyivvYcKX3UFAzIj6yBtq2cnGRdQ6cbSHbCRKa8QW5w)dG7tfWL)hRVObW)fGZkHT2JaUU8CReW9Pc4fkC9ra(Va8cNhqaotbaUvsaEv4CR)bW)fG7dGlmLo2OkGRR1)UeWfvsdGBLubzocWfWufWdps(5mUPazDP1)GvHhj)Cg3Grl7me2ApMeDUvQx4rshBjRZjTfvBRxV066JU2iv415Em1d26rAyfnotKQBPBcJPrskcJPrsPFLSskTEPaUNGuFnwL76I)2AdcEf6WqQQC9Hl9ZXP1pw6xPWxeDIfRBcEf6WqQQKfiJVD)0Yet0X2MGSGSU06FWWOLD5lmgDjC5BGSfAahw4XUeEOtah2Ygd4I6yeWhIQao(Zjax0FSrpah3JKaC5lmgDjC5BaUSKKSbd4R)aChWLo2ukfiRlT(hmmAzx(cJrxcx(MEXEOKSQvJAqVEP9egA9xaPWuyPG(WPW7Lrp3T(hXIXVqKPNQA6cCCY(pItHFJ)rS4nK)ufAtDeC0H9y6xP1FMWqBP7tyO1FbKctHLc6dNcVxg9C36F2eK1Lw)dggTSlGPuBuogK1Lw)dggTSBNpWRqhB91tqcx(giRlT(hmmAzxatP2OCSE9sB4rWLcKvvrLJdjPL(vYkPKOowflE1bLw6OCVhSMSObqwxA9pyy0YU0JXKlT(NuSXMEJNtALvmiRlT(hmmAzx6XyYLw)tk2ytVXZjTytVEP1LwdhLOHYBcRjlGSU06FWWOLDPhJjxA9pPyJn9gpN0kJKdhPxV06sRHJs0q5nH3DrqwqwxA9pyLSI16JKW25XK0Jr96Lw5)X6lAume2ApMeDUvQok37bVBnQbqwxA9pyLSIHrl7R(iM4)v96Lw5)X6lAume2ApMeDUvQok37bVBnQbqwxA9pyLSIHrl7m0HPJn9eOxV0UbJWAPe1XAch2xByLqOyX6w(WrJpMA6GslTCAlgH1s54qsAPFLSskjQJvLq4wmcRLIHWw7XKOZTsLq4MBTXQdkT0r5Ep4Dl)pwFrJIHomDSPNavv4CR)bMQW5w)JyXBy(fqMQK8OvQcLMMACBXI1T5rAmfB6yKUupyRhPT5MIfV6GslDuU3dwZIAeK1Lw)dwjRyy0Yot8)AAjCfOxV0UbJWAPe1XAch2xByLqOyX6w(WrJpMA6GslTCAlgH1s54qsAPFLSskjQJvLq4wmcRLIHWw7XKOZTsLq4MBTXQdkT0r5Ep4Dl)pwFrJIj(FnTeUcuvHZT(hyQcNB9pIfVH5xazQsYJwPkuAAQXTflw3MhPXuSPJr6s9GTEK2MBkw8QdkT0r5EpynlQJGSU06FWkzfdJw2JDqPHt6cHAqongiRlT(hSswXWOL9W36F0RxAzewlLJdjPL(vYkPKOowvcHIfV6GslDuU3dwtw0rqwqwxA9pyLmsoCKwhhssl9RKvsjrDScY6sR)bRKrYHJGrl7m(Xq1eU8n9KfiJuY8lGmS2I61lTHKPY9EumcRLAD0OVcucHBfsMk37rXiSwQ1rJ(kqDuU3dwtTbYkiRlT(hSsgjhocgTSNleTgx(ME9sBGSUlcjtL79Oyewlfd5yljJKdhPok37bVBnOyzBqwxA9pyLmsoCemAz38lzNhQxV0EcdT(lGu4xiU(lGsuodD4Tm)s25HQJY9EWAgiRBj)pwFrJAf9JuhL79G1mqwbzDP1)GvYi5WrWOL9v0psVypusw1YY261lTMFj78qLq4wNWqR)cif(fIR)cOeLZqhgK1Lw)dwjJKdhbJw2RKBLjzPZMZZ1RxAxVuadJ0Xw6OaA0C9sbSk3HpiRlT(hSsgjhocgTSlQJ1eoSV2WGSU06FWkzKC4iy0YoJFmunHlFtpzbYiLm)cidRTOE9s7sigthjl9lGswNtAgiRBj)pwFrJIHWw7XKOZTs1r5EpyXIL)hRVOrXqyR9ys05wP6OCVhSMfzbMazDlZJ0ykSKgl9Ret8)kiRlT(hSsgjhocgTSZqyR9ys05wjiRlT(hSsgjhocgTSFe(h36ji539IazDP1)GvYi5WrWOLDS55HuL0RxAzewlLJdjPL(vYkPKOowvcHIfV6GslDuU3dwZIBdY6sR)bRKrYHJGrl7ROxavt4Y3azDP1)GvYi5WrWOLD20Xycx(giRlT(hSsgjhocgTSll7CNopHlFdK1Lw)dwjJKdhbJw2zI)xXLufK1Lw)dwjJKdhbJw29uUWvPl9RK8EryqwxA9pyLmsoCemAzNXVZdi96L2qYu5EpkgH1sToA0xbQJY9EW7MGpjfmkzDobY6sR)bRKrYHJGrl7SPJXK8ZZ9PQxV0UEPaE3YhBW4sR)rLleTgx(Ms(ydK1Lw)dwjJKdhbJw2z8G0Vs21s2G1RxAzewlfdHT2JjrNBLQ6lAelE1bLw6OCVhSMBdY6sR)bRKrYHJGrl71(Oed5ydK1Lw)dwjJKdhbJw2z8JHQjC5B6jlqgPK5xazyTf1RxAn)citzDoLSpvBsZDfK1Lw)dwjJKdhbJw2LpZ5jC5B61lTRxkGvwNtj7t5o81mqwl8SaY6sR)bRKrYHJGrl7MFj78q96L2tyO1FbKc)cX1FbuIYzOdlw8jm06Vasneg3tGi)kaNSZdd7ji5HH(5MagK1Lw)dwjJKdhbJw2xhr6RNGKDEOE9s7jm06Vasneg3tGi)kaNSZdd7ji5HH(5MagKfK1Lw)dwHnTooKKw6xjRKsI6yfK1Lw)dwHny0YoJFmunHlFtVEPnKmvU3JIryTuRJg9vGsiCRqYu5EpkgH1sToA0xbQJY9EWAQnqwbzDP1)GvydgTSB(LSZd1RxApHHw)fqk8lex)fqjkNHo8wMFj78q1r5EpyndK1TK)hRVOrTI(rQJY9EWAgiRGSU06FWkSbJw2xr)i9I9qjzvllBRxV0A(LSZdvcHBDcdT(lGu4xiU(lGsuodDyqwxA9pyf2Grl7mX)R4sQcY6sR)bRWgmAzxuhRjCyFTHbzDP1)GvydgTSVIEbunHlFdK1Lw)dwHny0YoB6ymHlFtVEPLryTuROxaD4uUFSrDuU3dwZTfl28lGmvj5rRufknn1YIgazDP1)GvydgTSZ4hdvt4Y30RxAL)hRVOrXqyR9ys05wP6OCVhSMfzPWll9lGWP15sR)XJWeiRBzEKgtHL0yPFLyI)xflEjeJPJKL(fqjRZjndK1TK)hRVOrXqyR9ys05wP6OCVhSyXMFbKPSoNs2NQnP5UcY6sR)bRWgmAzVsUvMKLoBopxVEPD9sbmmshBPJcOrZ1lfWQCh(GSU06FWkSbJw2XMNhsvsVEPLryTuooKKw6xjRKsI6yvjekw8QdkT0r5EpynlUniRlT(hScBWOLDpLlCv6s)kjVxegK1Lw)dwHny0Y(r4FCRNGKF3lsVEPLryTume2ApMeDUvQecflE1bLw6OCVhSMf1aiRlT(hScBWOLDgcBThtIo3k1RxAL)hRVOrjQJ1eoSV2WQJY9EW7U42IfRB5dhn(yQPdkT0YjXIxDqPLok37bRzXTbzDP1)GvydgTSll7CNopHlFdK1Lw)dwHny0Y(r4FCRNGKF3lsVEPLryTume2ApMeDUvQecflE1bLw6OCVhSMf1aiRlT(hScBWOLDgcBThtIo3k1RxAL)hRVOrjQJ1eoSV2WQJY9EW7U42IfRB5dhn(yQPdkT0YjXIxDqPLok37bRzXTbzDP1)GvydgTSll7CNopHlFdK1Lw)dwHny0YoB6ymj)8CFQGSU06FWkSbJw2z8G0Vs21s2G1RxAzewlfdHT2JjrNBLQ6lAelE1bLw6OCVhSMBdY6sR)bRWgmAzV2hLyihBGSU06FWkSbJw2LpZ5jC5B61lTBSEPaExiFSbZ6Lcy1rb0u43q(FS(IgfB6ymj)8CFQQJY9EW7IIBUBxA9pk20Xys(55(uvYhBIfl)pwFrJInDmMKFEUpv1r5Ep4DxeMazDtXI3GryTume2ApMeDUvQecflMryTudHX9eiYVcWj78WWEcsEyOFUjGvcHBULUpHHw)fqk41dJEIoQkmjr(L(RsNyXRoO0shL79G1uJGSU06FWkSbJw2z8JHQjC5B61lTmcRLsuhRjCyFTHvcHGSU06FWkSbJw29t6dLcfIysVEPLryTume2ApMeDUvQQVOrS4vhuAPJY9EWAUniRlT(hScBWOLDZVKDEOE9s7jm06VasHFH46Vakr5m0Hfl(egA9xaPgcJ7jqKFfGt25HH9eK8Wq)CtadY6sR)bRWgmAzFDePVEcs25H61lTNWqR)ci1qyCpbI8RaCYopmSNGKhg6NBcyeeoKKO9SSTgrgYqia]] )

end
