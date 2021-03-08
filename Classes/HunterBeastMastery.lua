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


    local tar_trap_targets = {}

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


    local trapUnits = { "target", "focus" }
    local trappableClassifications = {
        rare = true,
        elite = true,
        normal = true,
        trivial = true,
        minus = true
    }

    for i = 1, 5 do
        trapUnits[ #trapUnits + 1 ] = "boss" .. i
    end

    for i = 1, 40 do
        trapUnits[ #trapUnits + 1 ] = "nameplate" .. i
    end

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if subtype == "SPELL_CAST_SUCCESS" and sourceGUID == GUID and spellID == 187698 and legendary.soulforge_embers.enabled then
            -- Capture all boss/elite targets present at this time as valid trapped targets.
            table.wipe( tar_trap_targets )
            
            for _, unit in ipairs( trapUnits ) do
                if UnitExists( unit ) and UnitCanAttack( "player", unit ) and not trappableClassifications[ UnitClassification( unit ) ] then
                    tar_trap_targets[ UnitGUID( unit ) ] = true
                end
            end
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


    spec:RegisterPack( "Beast Mastery", 20210307, [[dW01vbqisIEKQsfBIKYNGGrjGoLaSkscXRqLAwcKBjbSlu(Le0WiPYXeKLbHEgLQmnvLQUMeQTbrjFJsvLXrsaNtvj06uvkZJsP7jO2hQeheIkluG6HQkPjssGUiLQQ(ijHAKquQCskvLvcrMPeOBssiTtss)uvjyOquQAPqukpfvnvkfFfIQglQKoRQsL2lf)vObR4WsTys8ysnzrUmYML0NvvnAk50aRMKGETQIzlQBRk2Tk)wPHlrhxvjA5GEoutN46qA7siFxvA8Ku15Puz9qumFuX(PAtiJng(ulKrvevhIHuN9uN9JHiIf)9Hcz4f7kjdFzR)0)KH)6hYWhm1yXhv0gle0odFzBxE7KXgdpErHAYWBjsj(Bfw4pqSqvy69Pqm4bn3cypnSRsHyWJUqdVckil23zum8PwiJQiQoedPo7Po7hdrel2EHSNHVrfRfA45bpF1WBbsj6mkg(eH1g(GPgl(OI2yHG25dYo0tiOJKkAd1w(ekiFquDigYWNbybBSXWNOAJMfJngvdzSXW3AbSNHxVONqWi2AfdpDTsMsMGnIrven2y4PRvYuYeSHV1cypdVab3hscz4tewdbLcypdV9v9rSiFei4(qIpwn2N2N9kakM8rbTwdYhSDN2hG4ZlqS8b5WLKw8zR(iwKpipiNy(yFvFK31Ngs(O3Nssa3Vp1f6t7dYHljT4Zw9rSiFqEqo5d2UthKpOyYhXI8blW9(jOp7vaum5dvRKwy(yFvF6ZN9kakM8rbTw9bG9bsDYoFuqfF6Bflc6dwG79tqF2RaOyYhf0A1Nxqo7tNXRpkKpqQt25JID(iwKpc4H8b5WLKw8zR(iwKpipiN8rVpe2hLw)XNTw9rVBoTVxq(GIjFaIpGQpIf5d2QHuYhbcUpK4JE3CAFpFE3dbXhWjeSsqYNxGy5Jyr(GwQ3hW97dYHljT4Zw9rSiFqEqo5d2UtZ8X(Q(0Np7vaum5JcAT6JErZjFuiFqXuYN(s(Gfqo7JEFiFuA9hFQl0N2NkQGcjFqoCjPfF2QpIf5dYdYPG8bft(aeMp2x1N2NBVcOGwR(SxbqXKpaSpqQt2fKpOyYhG4dO6dq85DpeeFaNqWkbjFEbILpLRqNa6Sp7vaum5JcATI9rG2bUFFK1hKdxsAXNT6Jyr(G8GCYhSDN2Nf6dO6Jyr(SIfb9rGG7dj(aWhcIp95ZEfaftb5da7t7ZTxbuqRvF2RaOyYNxGy5t7tEVFc6JE3CAFVG8zH(aWhcIpqQt2X8X(Q(iwKpvWVL4da7Z)cUFFK1h6s(Oq1fs(y3Ic95i1l(GC4ssl(SvFelYhKhKtb5Jkefl(GLgk(GIb3VpceCFib7JS(80FiFWOqYhXISZNFs8bftjMHxdbcbbTHxGG7djmjeZQXrumfvqRvFuZNa9rbTwznUK0sCRrXIIVGCIHw6JA(eOpQ0hbcUpKWeezwnoIIPOcAT6dho(iqW9HeMGitVBoTVhdspn4W(WHJpceCFiHjHy6DZP99yjuylG98HlH9rGG7djmbrME3CAFpwcf2cypFcWhoC8rbTwznUK0sCRrXIIVGCIL23Zh18jqFei4(qctqKz14ikMIkO1QpQ5Jab3hsycIm9U50(ESekSfWE(WLW(iqW9HeMeIP3nN23JLqHTa2Zh18rGG7djmbrME3CAFpgKEAWH9Pa(uSp26JE3CAFpwJljTe3AuSO4liNyq6Pbh2h18rVBoTVhRXLKwIBnkwu8fKtmi90Gd7dx8br15dho(iqW9HeMeIP3nN23JLqHTa2ZNc4tX(yRp6DZP99ynUK0sCRrXIIVGCIbPNgCyFcWhoC8rA4pjmb8qrzJja5JT(O3nN23J14sslXTgflk(cYjgKEAWH9jaF4WXhv6Jab3hsysiMvJJOykQGwR(OMpb6Jab3hsycImRghrXuubTw9rnFc0hf0AL14sslXTgflk(cYjwAFpF4WXhbcUpKWeez6DZP99yq6Pbh2hU4tX(eGpQ5tG(O3nN23J14sslXTgflk(cYjgKEAWH9Hl(GO68HdhFei4(qctqKP3nN23JbPNgCyFkGpf7dx8rVBoTVhRXLKwIBnkwu8fKtmi90Gd7ta(WHJpQ0hbcUpKWeezwnoIIPOcAT6JA(eOpQ0hbcUpKWeezwnoQ3nN23ZhoC8rGG7djmbrME3CAFpwcf2cypF4syFei4(qctcX07Mt77XsOWwa75dho(iqW9HeMGitVBoTVhdspn4W(eGpbyeJQ2ZyJHNUwjtjtWgEneiee0gEbcUpKWeezwnoIIPOcAT6JA(eOpkO1kRXLKwIBnkwu8fKtm0sFuZNa9rL(iqW9HeMeIz14ikMIkO1QpC44Jab3hsysiME3CAFpgKEAWH9HdhFei4(qctqKP3nN23JLqHTa2ZhUe2hbcUpKWKqm9U50(ESekSfWE(eGpC44JcATYACjPL4wJIffFb5elTVNpQ5tG(iqW9HeMeIz14ikMIkO1QpQ5Jab3hsysiME3CAFpwcf2cypF4syFei4(qctqKP3nN23JLqHTa2Zh18rGG7djmjetVBoTVhdspn4W(uaFk2hB9rVBoTVhRXLKwIBnkwu8fKtmi90Gd7JA(O3nN23J14sslXTgflk(cYjgKEAWH9Hl(GO68HdhFei4(qctqKP3nN23JLqHTa2ZNc4tX(yRp6DZP99ynUK0sCRrXIIVGCIbPNgCyFcWhoC8rA4pjmb8qrzJja5JT(O3nN23J14sslXTgflk(cYjgKEAWH9jaF4WXhv6Jab3hsycImRghrXuubTw9rnFc0hbcUpKWKqmRghrXuubTw9rnFc0hf0AL14sslXTgflk(cYjwAFpF4WXhbcUpKWKqm9U50(Emi90Gd7dx8PyFcWh18jqF07Mt77XACjPL4wJIffFb5edspn4W(WfFquD(WHJpceCFiHjHy6DZP99yq6Pbh2Nc4tX(WfF07Mt77XACjPL4wJIffFb5edspn4W(eGpC44Jk9rGG7djmjeZQXrumfvqRvFuZNa9rL(iqW9HeMeIz14OE3CAFpF4WXhbcUpKWKqm9U50(ESekSfWE(WLW(iqW9HeMGitVBoTVhlHcBbSNpC44Jab3hsysiME3CAFpgKEAWH9jaFcWW3AbSNHxGG7djiAeJQFVXgdpDTsMsMGn8jcRHGsbSNHV1cypmlr1gnlChUqumfbc9Gn8Twa7z4fyFFjkidqgW9hXwRyeJQfBSXWtxRKPKjydVgceccAdFjKkk(RtSqSgxsAjU1OyrXxqo5dho(ub)wsespn4W(yRpiQodFRfWEgEumfbc9GnIrvKLXgdpDTsMsMGn8Twa7z41DohBTa2lMbyXWNbyjE9dz41jSrmQA)m2y4PRvYuYeSHxdbcbbTHV1cOiksh9aiSp26dIg(wlG9m86oNJTwa7fZaSy4ZaSeV(Hm8yXigvvbm2y4PRvYuYeSHxdbcbbTHV1cOiksh9aiSpCXNqg(wlG9m86oNJTwa7fZaSy4ZaSeV(Hm86m1frgXig(siP3hLwm2yunKXgdFRfWEgEm6ZZEXssm801kzkzc2igvr0yJHV1cypdVYksMsXAUTJsVG7pkR6bNHNUwjtjtWgXOQ9m2y4PRvYuYeSH)6hYW3id2QHnow3tIBnwUVe0W3AbSNHVrgSvdBCSUNe3ASCFjOrmQ(9gBm801kzkzc2WxcjDJLOaEidFiwXg(wlG9m8sdJcSln8AiqiiOn8q0JQl8Ny4fnxx4pfPhfcIz01kzk5dho(arpQUWFIDegdU)3gAhokWUSeC)XUSSHTGIz01kzkzeJQfBSXWtxRKPKjydFjK0nwIc4Hm8HyfB4BTa2ZWRqyb054lSfldVgceccAdVk9r6mDcdRPtIBnQK3nXORvYuYh18rL(arpQUWFIHx0CDH)uKEuiiMrxRKPKrmQISm2y4PRvYuYeSHVes6glrb8qg(qm7z4tewdbLcypdpYLuHOyb7Jyr(KqHTa2ZN(s(O3nN23ZNT6dYHljT4Zw9rSiFqEqo5tFjFq2dbpD2h77Wc40c2hf78rSiFsOWwa75Zw9PpFqpRgluYhv8xvb951IoFelYoeGKpOyk5tjK07JslmFcM0nkM8b5WLKw8zR(iwKpipiN8bsjunH9rf)vvqFuSZhevN6EWb5JybW(aW(eIzpFWKEVeMz4BTa2ZW34sslXTgflk(cYjdVgceccAdVk9PrgcceIvcbpDocoSaoTGz01kzk5JA(OsFimMonXimMonf3AuSOyD1OyW9hbqaM90QWf6JA(eOp0xIcklPeRrgSvdBCSUNe3ASCFjOpC44Jk9H(suqzjLyA705vG7b0rLCJfFcWigvTFgBm801kzkzc2WxcjDJLOaEidFiwXg(eH1qqPa2ZWJCjvikwW(iwKpjuylG98PVKp6DZP998zR(emHfqN9b5HTy5tFjFq21id5Zw9bzR)jFuSZhXI8jHcBbSNpB1N(8b9SASqjFuXFvf0Nxl68rSi7qas(GIPKpLqsVpkTWm8Twa7z4viSa6C8f2ILHxdbcbbTHVrgcceIvcbpDocoSaoTGz01kzk5JA(OsFimMonXimMonf3AuSOyD1OyW9hbqaM90QWf6JA(eOp0xIcklPeRrgSvdBCSUNe3ASCFjOpC44Jk9H(suqzjLyA705vG7b0rLCJfFcWigXWRtyJngvdzSXWtxRKPKjydVgceccAdVE3CAFpMcHfqNJVWwSyq6Pbh2hU4J9uNHV1cypdFFAclWoh1DoBeJQiASXWtxRKPKjydVgceccAdVE3CAFpMcHfqNJVWwSyq6Pbh2hU4J9uNHV1cypdFfajL8UjJyu1EgBm801kzkzc2WRHaHGG2WhOpkO1k7fKtrCjacemdT0hoC8rL(O3IORpHDGFljwBYh18rbTwznUK0sCRrXIIVGCIHw6JA(OGwRmfclGohFHTyXql9jaFuZNa9Pc(TKiKEAWH9Hl(O3nN23JPqqmb)aUFwcf2cypF42NekSfWE(WHJpb6J0WFsywuNflwPw8XwFSxX(WHJpQ0hPZ0jSpGCMGrWHfWPfgDTsMs(eGpb4dho(ub)wsespn4W(yRpHSNHV1cypdVcbXe8d4(nIr1V3yJHNUwjtjtWgEneiee0g(a9rbTwzVGCkIlbqGGzOL(WHJpQ0h9weD9jSd8BjXAt(OMpkO1kRXLKwIBnkwu8fKtm0sFuZhf0ALPqyb054lSflgAPpb4JA(eOpvWVLeH0tdoSpCXh9U50(EmL8UPyffAhlHcBbSNpC7tcf2cypF4WXNa9rA4pjmlQZIfRul(yRp2RyF4WXhv6J0z6e2hqotWi4Wc40cJUwjtjFcWNa8HdhFQGFljcPNgCyFS1NqildFRfWEgEL8UPyffANrmQwSXgdFRfWEg(m43sWrviA6)HoXWtxRKPKjyJyufzzSXWtxRKPKjydVgceccAdVcATYACjPL4wJIffFb5edT0hoC8Pc(TKiKEAWH9XwFqezz4BTa2ZWxUcypJyedpwm2yunKXgdFRfWEg(gxsAjU1OyrXxqoz4PRvYuYeSrmQIOXgdpDTsMsMGn8AiqiiOn8kO1kRcPdzSJHw6JA(OGwRSkKoKXogKEAWH9X2W(8Rtg(wlG9m8knuHsrS1kgXOQ9m2y4PRvYuYeSHxdbcbbTHhIEuDH)edVO56c)Pi9OqqmJUwjtjFuZhPHrb2Lmi90Gd7JT(8Rt(OMp6DZP99y1CdjgKEAWH9XwF(1jdFRfWEgEPHrb2LgXO63BSXWtxRKPKjydFRfWEg(AUHKHxdbcbbTHxAyuGDjdT0h18bIEuDH)edVO56c)Pi9OqqmJUwjtjdFgCuuNm8iwSrmQwSXgdFRfWEgEL8UjSfLm801kzkzc2igvrwgBm8Twa7z4Fb5uexcGabB4PRvYuYeSrmQA)m2y4BTa2ZWxZTDukITwXWtxRKPKjyJyuvfWyJHNUwjtjtWgEneiee0gEf0ALvZTDeehFA4hgKEAWH9XwFk2hoC8rA4pjmlQZIfRul(yByFquDg(wlG9m8Fa5CeBTIrmQ(fn2y4PRvYuYeSHxdbcbbTHxVBoTVhtHWcOZXxylwmi90Gd7JT(ecrFur8rB1WFchRWwlG96SpC7ZVo5JA(iDMoHH10jXTgvY7My01kzk5dho(urZ5iK0wn8NIc4H8XwF(1jFuZh9U50(EmfclGohFHTyXG0tdoSpC44J0WFsyc4HIYgtaYhB95lA4BTa2ZWR0qfkfXwRyeJQHuNXgdpDTsMsMGn8AiqiiOn81vJI9HBF0nwIq6NoFS1N6QrXSNw9g(wlG9m8jQfRO2Q)a7hJyunuiJngE6ALmLmbB41qGqqqB4vqRvwJljTe3AuSO4liNyOL(WHJpvWVLeH0tdoSp26tOIn8Twa7z4Xs)usjYigvdHOXgdFRfWEg(o(GctemU1OgUVydpDTsMsMGnIr1q2ZyJHNUwjtjtWgEneiee0gEf0ALPqyb054lSflgAPpC44tf8Bjri90Gd7JT(esDg(wlG9m8qcVxlG7p2q4(AeJQH(EJngE6ALmLmbB41qGqqqB417Mt77XEb5uexcGabZG0tdoSpCXNqf7dho(OsF0Br01NWoWVLeRn5dho(ub)wsespn4W(yRpHk2W3AbSNHxHWcOZXxylwgXOAOIn2y4BTa2ZWRTapnb7i2AfdpDTsMsMGnIr1qilJngE6ALmLmbB41qGqqqB4vqRvMcHfqNJVWwSyOL(WHJpvWVLeH0tdoSp26ti1z4BTa2ZWdj8ETaU)ydH7RrmQgY(zSXWtxRKPKjydVgceccAdVE3CAFp2liNI4saeiygKEAWH9Hl(eQyF4WXhv6JElIU(e2b(TKyTjF4WXNk43sIq6Pbh2hB9juXg(wlG9m8kewaDo(cBXYigvdPcySXW3AbSNHxBbEAc2rS1kgE6ALmLmbBeJQH(IgBm8Twa7z4)aY5OEFE6lz4PRvYuYeSrmQIO6m2y4PRvYuYeSHxdbcbbTHxbTwzkewaDo(cBXIL23ZhoC8Pc(TKiKEAWH9XwFk2W3AbSNHxP)JBnkqG(d2igvrmKXgdFRfWEg(easrfQXIHNUwjtjtWgXOkIiASXWtxRKPKjydVgceccAdFG(uxnk2Nc4JEXIpC7tD1OygK(PZhveFc0h9U50(ESpGCoQ3NN(smi90Gd7tb8jKpb4dx8P1cyp2hqoh17ZtFjMEXIpC44JE3CAFp2hqoh17ZtFjgKEAWH9Hl(eYhU95xN8jaF4WXNa9rbTwzkewaDo(cBXIHw6dho(OGwRSJWyW9)2q7Wrb2LLG7p2LLnSfumdT0Na8rnFuPpq0JQl8NyFzxM7ibPe6fFByCHjcYORvYuYhoC8Pc(TKiKEAWH9XwFSNHV1cypdVEvGDeBTIrmQIO9m2y4PRvYuYeSHxdbcbbTHxbTwzVGCkIlbqGGzOLg(wlG9m8knuHsrS1kgXOkIFVXgdpDTsMsMGn8AiqiiOn8kO1ktHWcOZXxylwS0(E(WHJpvWVLeH0tdoSp26tXg(wlG9m8nu3hflrZyYigvrSyJngE6ALmLmbB41qGqqqB4HOhvx4pXWlAUUWFkspkeeZORvYuYhoC8bIEuDH)e7imgC)Vn0oCuGDzj4(JDzzdBbfZORvYuYW3AbSNHxAyuGDPrmQIiYYyJHNUwjtjtWgEneiee0gEi6r1f(tSJWyW9)2q7Wrb2LLG7p2LLnSfumJUwjtjdFRfWEg(kKiKbC)rb2LgXOkI2pJngE6ALmLmbB41qGqqqB4d0N6QrX(WTp1vJIzq6NoF42Nqf7ta(yRp1vJIzpT6n8Twa7z4BOUpkklesNyeJy41zQlIm2yunKXgdFRfWEg(gxsAjU1OyrXxqoz4PRvYuYeSrmQIOXgdpDTsMsMGn8Twa7z4vAOcLIyRvm8AiqiiOn8kO1kRcPdzSJHw6JA(OGwRSkKoKXogKEAWH9X2W(8RtgETD6mfLg(tc2OAiJyu1EgBm801kzkzc2WRHaHGG2W)Rt(uaFuqRvMc1yjQZuxeXG0tdoSpCXh1XqSydFRfWEg(h0SaWwRyeJQFVXgdpDTsMsMGn8AiqiiOn8q0JQl8Ny4fnxx4pfPhfcIz01kzk5JA(inmkWUKbPNgCyFS1NFDYh18rVBoTVhRMBiXG0tdoSp26ZVoz4BTa2ZWlnmkWU0igvl2yJHNUwjtjtWg(wlG9m81CdjdVgceccAdV0WOa7sgAPpQ5de9O6c)jgErZ1f(tr6rHGygDTsMsg(m4OOoz4rSyJyufzzSXWtxRKPKjydVgceccAdFD1OyF42hDJLiK(PZhB9PUAum7PvVHV1cypdFIAXkQT6pW(XigvTFgBm8Twa7z4Fb5uexcGabB4PRvYuYeSrmQQcySXWtxRKPKjydFRfWEgELgQqPi2AfdVgceccAdFfnNJqsB1WFkkGhYhB95xN8rnF07Mt77XuiSa6C8f2Ifdspn4W(WHJp6DZP99ykewaDo(cBXIbPNgCyFS1Nqi6d3(8Rt(OMpsNPtyynDsCRrL8UjgDTsMsgETD6mfLg(tc2OAiJyu9lASXW3AbSNHxHWcOZXxylwgE6ALmLmbBeJQHuNXgdFRfWEgEiH3RfW9hBiCFn801kzkzc2igvdfYyJHNUwjtjtWgEneiee0gEf0AL14sslXTgflk(cYjgAPpC44tf8Bjri90Gd7JT(eQydFRfWEgES0pLuImIr1qiASXW3AbSNHVMB7OueBTIHNUwjtjtWgXOAi7zSXW3AbSNH)diNJyRvm801kzkzc2igvd99gBm8Twa7z41wGNMGDeBTIHNUwjtjtWgXOAOIn2y4BTa2ZWRK3nHTOKHNUwjtjtWgXOAiKLXgdFRfWEg(o(GctemU1OgUVydpDTsMsMGnIr1q2pJngE6ALmLmbB41qGqqqB4vqRvwfshYyhdspn4W(WfFi1tAuHIc4Hm8Twa7z4vAiS)jJyunKkGXgdpDTsMsMGn8AiqiiOn81vJI9Hl(OxS4d3(0AbSh7bnlaS1km9IfdFRfWEg(pGCoQ3NN(sgXOAOVOXgdpDTsMsMGn8AiqiiOn8kO1ktHWcOZXxylwS0(E(WHJpvWVLeH0tdoSp26tXg(wlG9m8k9FCRrbc0FWgXOkIQZyJHV1cypdFcaPOc1yXWtxRKPKjyJyufXqgBm801kzkzc2W3AbSNHxPHkukITwXWRHaHGG2Wln8NeMaEOOSXeG8XwF(IgETD6mfLg(tc2OAiJyufren2y4PRvYuYeSHxdbcbbTHVUAumtapuu24tREFS1NFDYhveFq0W3AbSNHxVkWoITwXigvr0EgBm801kzkzc2WRHaHGG2WdrpQUWFIHx0CDH)uKEuiiMrxRKPKpC44de9O6c)j2rym4(FBOD4Oa7YsW9h7YYg2ckMrxRKPKHV1cypdV0WOa7sJyufXV3yJHNUwjtjtWgEneiee0gEi6r1f(tSJWyW9)2q7Wrb2LLG7p2LLnSfumJUwjtjdFRfWEg(kKiKbC)rb2LgXOkIfBSXWtxRKPKjydVgceccAdFG(uxnk2hU9PUAumds)05d3(yp15ta(yRp1vJIzpT6n8Twa7z4BOUpkklesNyeJyedFreed2ZOkIQdXqQdr1HOH)THh4(XgEKh5q2u1(uvf)nF8XglYhWt5cfFQl0hesuTrZcc(aPVefaPKp49H8PrL9Pfk5J2QVFcZCKki4iFq8B(819kIGcL8bbbcUpKWcX4kc(iRpiiqW9HeMeIXve8jqKL6dG5ivqWr(G4385R7vebfk5dcceCFiHHiJRi4JS(GGab3hsycImUIGpbgYEQpaMJubbh5J9(MpFDVIiOqjFqqGG7djSqmUIGpY6dcceCFiHjHyCfbFcmK9uFamhPccoYh79nF(6EfrqHs(GGab3hsyiY4kc(iRpiiqW9HeMGiJRi4tGil1haZrYrc5roKnvTpvvXFZhFSXI8b8uUqXN6c9bHsiP3hLwqWhi9LOaiL8bVpKpnQSpTqjF0w99tyMJubbh5Z3)nF(6EfrqHs(Gae9O6c)jgxrWhz9bbi6r1f(tmUYORvYucbFAXh7)xOG(eyi1haZrQGGJ857)MpFDVIiOqjFqaIEuDH)eJRi4JS(Gae9O6c)jgxz01kzkHGpbgs9bWCKki4iFk(B(819kIGcL8bbPZ0jmUIGpY6dcsNPtyCLrxRKPec(eyi1haZrQGGJ8P4V5Zx3RickuYheGOhvx4pX4kc(iRpiarpQUWFIXvgDTsMsi4tl(y))cf0NadP(ayososipYHSPQ9PQk(B(4JnwKpGNYfk(uxOpiOtye8bsFjkasjFW7d5tJk7tluYhTvF)eM5ivqWr(yVV5Zx3RickuYheKotNW4kc(iRpiiDMoHXvgDTsMsi4tGHuFamhPccoYNV)B(819kIGcL8bbPZ0jmUIGpY6dcsNPtyCLrxRKPec(eyi1haZrYrc5roKnvTpvvXFZhFSXI8b8uUqXN6c9bbSGGpq6lrbqk5dEFiFAuzFAHs(OT67NWmhPccoYhe)MpFDVIiOqjFqOKegxzFxgJHGpY6dcFxgJHGpbIO6dG5ivqWr(yVV5Zx3RickuYheGOhvx4pX4kc(iRpiarpQUWFIXvgDTsMsi4tGHuFamhPccoYNV)B(819kIGcL8bbi6r1f(tmUIGpY6dcq0JQl8NyCLrxRKPec(0Ip2)Vqb9jWqQpaMJubbh5Zx8B(819kIGcL8bbPZ0jmUIGpY6dcsNPtyCLrxRKPec(eyi1haZrQGGJ8bre)MpFDVIiOqjFqaIEuDH)eJRi4JS(Gae9O6c)jgxz01kzkHGpbgs9bWCKki4iFqS4V5Zx3RickuYheGOhvx4pX4kc(iRpiarpQUWFIXvgDTsMsi4tl(y))cf0NadP(ayosfeCKpiw8385R7vebfk5dcq0JQl8NyCfbFK1heGOhvx4pX4kJUwjtje8jWqQpaMJubbh5dIiRV5Zx3RickuYheGOhvx4pX4kc(iRpiarpQUWFIXvgDTsMsi4tl(y))cf0NadP(ayososipYHSPQ9PQk(B(4JnwKpGNYfk(uxOpiOZuxeHGpq6lrbqk5dEFiFAuzFAHs(OT67NWmhPccoYhe)MpFDVIiOqjFqOKegxzFxgJHGpY6dcFxgJHGpbIO6dG5ivqWr(yVV5Zx3RickuYhekjHXv23LXyi4JS(GW3LXyi4tGHuFamhPccoYNV)B(819kIGcL8bbi6r1f(tmUIGpY6dcq0JQl8NyCLrxRKPec(eyi1haZrQGGJ8P4V5Zx3RickuYheGOhvx4pX4kc(iRpiarpQUWFIXvgDTsMsi4tl(y))cf0NadP(ayosfeCKpQaFZNVUxreuOKpiiDMoHXve8rwFqq6mDcJRm6ALmLqWNw8X()fkOpbgs9bWCKki4iFcz)(MpFDVIiOqjFqOKegxzFxgJHGpY6dcFxgJHGpbgs9bWCKki4iFq0EFZNVUxreuOKpiarpQUWFIXve8rwFqaIEuDH)eJRm6ALmLqWNw8X()fkOpbgs9bWCKki4iFq0EFZNVUxreuOKpiarpQUWFIXve8rwFqaIEuDH)eJRm6ALmLqWNadP(ayosfeCKpi(9FZNVUxreuOKpiarpQUWFIXve8rwFqaIEuDH)eJRm6ALmLqWNw8X()fkOpbgs9bWCKCKSVNYfkuYNI9P1cypFYaSGzosgECjPnQIyX2ZWxc3kitg(VZ3XNGPgl(OI2yHG25dYo0tiOJ03574JkAd1w(ekiFquDigYrYrQ1cypmRes69rPLWy0NN9ILK4i1AbShMvcj9(O0c3HluzfjtPyn32rPxW9hLv9GZrQ1cypmRes69rPfUdxikMIaHEc66hkCJmyRg24yDpjU1y5(sqhPwlG9WSsiP3hLw4oCHsdJcSldQes6glrb8qHdXkoiqnme9O6c)jgErZ1f(tr6rHGyoCGOhvx4pXocJb3)BdTdhfyxwcU)yxw2WwqXosTwa7HzLqsVpkTWD4cviSa6C8f2IvqLqs3yjkGhkCiwXbbQHvP0z6egwtNe3AujVBsnvcrpQUWFIHx0CDH)uKEuii2r674dYLuHOyb7Jyr(KqHTa2ZN(s(O3nN23ZNT6dYHljT4Zw9rSiFqEqo5tFjFq2dbpD2h77Wc40c2hf78rSiFsOWwa75Zw9PpFqpRgluYhv8xvb951IoFelYoeGKpOyk5tjK07JslmFcM0nkM8b5WLKw8zR(iwKpipiN8bsjunH9rf)vvqFuSZhevN6EWb5JybW(aW(eIzpFWKEVeM5i1AbShMvcj9(O0c3HlSXLKwIBnkwu8fKtbvcjDJLOaEOWHy2liqnSkBKHGaHyLqWtNJGdlGtlygDTsMsQPscJPttmcJPttXTgflkwxnkgC)raeGzpTkCHQfi9LOGYskXAKbB1WghR7jXTgl3xcYHJkPVefuwsjM2oDEf4EaDuj3yjahPVJpixsfIIfSpIf5tcf2cypF6l5JE3CAFpF2Qpbtyb0zFqEylw(0xYhKDnYq(SvFq26FYhf78rSiFsOWwa75Zw9PpFqpRgluYhv8xvb951IoFelYoeGKpOyk5tjK07JslmhPwlG9WSsiP3hLw4oCHkewaDo(cBXkOsiPBSefWdfoeR4Ga1WnYqqGqSsi4PZrWHfWPfmJUwjtj1ujHX0PjgHX0PP4wJIffRRgfdU)iacWSNwfUq1cK(suqzjLynYGTAyJJ19K4wJL7lb5WrL0xIcklPetBNoVcCpGoQKBSeGJKJuRfWEyUdxOErpHGrS1kosFhFSVQpIf5Jab3hs8XQX(0(SxbqXKpkO1Aq(GT70(aeFEbILpihUK0IpB1hXI8b5b5eZh7R6J8U(0qYh9(usc4(9PUqFAFqoCjPfF2QpIf5dYdYjFW2D6G8bft(iwKpybU3pb9zVcGIjFOAL0cZh7R6tF(SxbqXKpkO1QpaSpqQt25JcQ4tFRyrqFWcCVFc6ZEfaft(OGwR(8cYzF6mE9rH8bsDYoFuSZhXI8rapKpihUK0IpB1hXI8b5b5Kp69HW(O06p(S1Qp6DZP99cYhum5dq8bu9rSiFWwnKs(iqW9HeF07Mt775Z7Eii(aoHGvcs(8celFelYh0s9(aUFFqoCjPfF2QpIf5dYdYjFW2DAMp2x1N(8zVcGIjFuqRvF0lAo5Jc5dkMs(0xYhSaYzF07d5JsR)4tDH(0(urfui5dYHljT4Zw9rSiFqEqofKpOyYhGW8X(Q(0(C7vaf0A1N9kakM8bG9bsDYUG8bft(aeFavFaIpV7HG4d4ecwji5ZlqS8PCf6eqN9zVcGIjFuqRvSpc0oW97JS(GC4ssl(SvFelYhKhKt(GT70(SqFavFelYNvSiOpceCFiXha(qq8PpF2RaOykiFayFAFU9kGcAT6ZEfaft(8celFAFY79tqF07Mt77fKpl0ha(qq8bsDYoMp2x1hXI8Pc(TeFayF(xW97JS(qxYhfQUqYh7wuOphPEXhKdxsAXNT6Jyr(G8GCkiFuHOyXhS0qXhum4(9rGG7djyFK1NN(d5dgfs(iwKD(8tIpOykXCKATa2dZD4cfi4(qsOGa1WceCFiHfIz14ikMIkO1QAbQGwRSgxsAjU1OyrXxqoXqlvlqvkqW9HegImRghrXuubTw5WrGG7djmez6DZP99yq6PbhMdhbcUpKWcX07Mt77XsOWwa7XLWceCFiHHitVBoTVhlHcBbSxaC4OGwRSgxsAjU1OyrXxqoXs77PwGceCFiHHiZQXrumfvqRv1ei4(qcdrME3CAFpwcf2cypUewGG7djSqm9U50(ESekSfWEQjqW9HegIm9U50(Emi90GdxGITvVBoTVhRXLKwIBnkwu8fKtmi90GdRME3CAFpwJljTe3AuSO4liNyq6PbhMliQooCei4(qcletVBoTVhlHcBbSxbk2w9U50(ESgxsAjU1OyrXxqoXG0tdoCaC4in8NeMaEOOSXeGSvVBoTVhRXLKwIBnkwu8fKtmi90GdhahoQuGG7djSqmRghrXuubTwvlqbcUpKWqKz14ikMIkO1QAbQGwRSgxsAjU1OyrXxqoXs77XHJab3hsyiY07Mt77XG0tdomxkoa1cuVBoTVhRXLKwIBnkwu8fKtmi90GdZfevhhoceCFiHHitVBoTVhdspn4WfOyUO3nN23J14sslXTgflk(cYjgKEAWHdGdhvkqW9HegImRghrXuubTwvlqvkqW9HegImRgh17Mt77XHJab3hsyiY07Mt77XsOWwa7XLWceCFiHfIP3nN23JLqHTa2JdhbcUpKWqKP3nN23JbPNgC4acWrQ1cypm3HluGG7djigeOgwGG7djmezwnoIIPOcATQwGkO1kRXLKwIBnkwu8fKtm0s1cuLceCFiHfIz14ikMIkO1khoceCFiHfIP3nN23JbPNgCyoCei4(qcdrME3CAFpwcf2cypUewGG7djSqm9U50(ESekSfWEbWHJcATYACjPL4wJIffFb5elTVNAbkqW9HewiMvJJOykQGwRQjqW9HewiME3CAFpwcf2cypUewGG7djmez6DZP99yjuylG9utGG7djSqm9U50(Emi90GdxGITvVBoTVhRXLKwIBnkwu8fKtmi90GdRME3CAFpwJljTe3AuSO4liNyq6PbhMliQooCei4(qcdrME3CAFpwcf2cyVcuST6DZP99ynUK0sCRrXIIVGCIbPNgC4a4WrA4pjmb8qrzJjazRE3CAFpwJljTe3AuSO4liNyq6PbhoaoCuPab3hsyiYSACeftrf0AvTafi4(qcleZQXrumfvqRv1cubTwznUK0sCRrXIIVGCIL23JdhbcUpKWcX07Mt77XG0tdomxkoa1cuVBoTVhRXLKwIBnkwu8fKtmi90GdZfevhhoceCFiHfIP3nN23JbPNgC4cumx07Mt77XACjPL4wJIffFb5edspn4WbWHJkfi4(qcleZQXrumfvqRv1cuLceCFiHfIz14OE3CAFpoCei4(qcletVBoTVhlHcBbShxclqW9HegIm9U50(ESekSfWEC4iqW9HewiME3CAFpgKEAWHdiahPVJpTwa7H5oCHOykce6b7i1AbShM7WfkW((suqgGmG7pITwXrQ1cypm3HleftrGqp4Ga1WLqQO4VoXcXACjPL4wJIffFb5ehovWVLeH0tdoSTiQohPwlG9WChUqDNZXwlG9Izawc66hkSoHDKATa2dZD4c1DohBTa2lMbyjORFOWyjiqnCRfqruKo6bqyBr0rQ1cypm3Hlu35CS1cyVygGLGU(HcRZuxefeOgU1cOiksh9aimxc5i5i1AbShMPt4W9PjSa7Cu35CqGAy9U50(EmfclGohFHTyXG0tdomxSN6CKATa2dZ0jm3HlScGKsE3uqGAy9U50(EmfclGohFHTyXG0tdomxSN6CKATa2dZ0jm3HluHGyc(bC)bbQHdubTwzVGCkIlbqGGzOLC4Os9weD9jSd8BjXAtQPGwRSgxsAjU1OyrXxqoXqlvtbTwzkewaDo(cBXIHwgGAbwb)wsespn4WCrVBoTVhtHGyc(bC)SekSfWECNqHTa2JdNaLg(tcZI6SyXk1IT2RyoCuP0z6e2hqotWi4Wc40sabWHtf8Bjri90GdBBi75i1AbShMPtyUdxOsE3uSIcTliqnCGkO1k7fKtrCjacemdTKdhvQ3IORpHDGFljwBsnf0AL14sslXTgflk(cYjgAPAkO1ktHWcOZXxylwm0YaulWk43sIq6PbhMl6DZP99yk5DtXkk0owcf2cypUtOWwa7XHtGsd)jHzrDwSyLAXw7vmhoQu6mDc7diNjyeCybCAjGa4WPc(TKiKEAWHTneYYrQ1cypmtNWChUWm43sWrviA6)HoXrQ1cypmtNWChUWYva7feOgwbTwznUK0sCRrXIIVGCIHwYHtf8Bjri90GdBlIilhjhPwlG9WmDM6IOWnUK0sCRrXIIVGCYrQ1cypmtNPUiI7WfQ0qfkfXwReK2oDMIsd)jbhouqGA4ssypn4ykO1kRcPdzSJHwQwjjSNgCmf0ALvH0Hm2XG0tdoSTH)1jhPwlG9WmDM6IiUdx4dAwayRvccud)RtfOKe2tdoMcATYuOglrDM6IigKEAWH5I6yiwSJuRfWEyMotDre3HluAyuGDzqGAyi6r1f(tm8IMRl8NI0JcbXQjnmkWUKbPNgCyB)1j107Mt77XQ5gsmi90GdB7Vo5i1AbShMPZuxeXD4cR5gsbLbhf1PWiwCqGAyPHrb2Lm0s1GOhvx4pXWlAUUWFkspkee7i1AbShMPZuxeXD4ctulwrTv)b2pbbQHRRgfZTUXses)0zBD1Oy2tREhPwlG9WmDM6IiUdx4liNI4saeiyhPwlG9WmDM6IiUdxOsdvOueBTsqA70zkkn8NeC4qbbQHRO5CesARg(trb8q2(RtQP3nN23JPqyb054lSflgKEAWH5WrVBoTVhtHWcOZXxylwmi90GdBBie5(xNut6mDcdRPtIBnQK3n5i1AbShMPZuxeXD4cviSa6C8f2ILJuRfWEyMotDre3Hles49AbC)Xgc3xhPwlG9WmDM6IiUdxiw6NskrbbQHvqRvwJljTe3AuSO4liNyOLC4ub)wsespn4W2gQyhPwlG9WmDM6IiUdxyn32rPi2AfhPwlG9WmDM6IiUdx4hqohXwR4i1AbShMPZuxeXD4c1wGNMGDeBTIJuRfWEyMotDre3HlujVBcBrjhPwlG9WmDM6IiUdxyhFqHjcg3Aud3xSJuRfWEyMotDre3HluPHW(Nccudxsc7PbhtbTwzviDiJDmi90GdZfs9KgvOOaEihPwlG9WmDM6IiUdx4hqoh17ZtFPGa1W1vJI5IEXc3Twa7XEqZcaBTctVyXrQ1cypmtNPUiI7WfQ0)XTgfiq)bheOgwbTwzkewaDo(cBXIL23JdNk43sIq6Pbh22IDKATa2dZ0zQlI4oCHjaKIkuJfhPwlG9WmDM6IiUdxOsdvOueBTsqA70zkkn8NeC4qbbQHLg(tctapuu2ycq2(fDKATa2dZ0zQlI4oCH6vb2rS1kbbQHRRgfZeWdfLn(0Q32FDsfbrhPwlG9WmDM6IiUdxO0WOa7YGa1Wq0JQl8Ny4fnxx4pfPhfcI5WbIEuDH)e7imgC)Vn0oCuGDzj4(JDzzdBbf7i1AbShMPZuxeXD4cRqIqgW9hfyxgeOggIEuDH)e7imgC)Vn0oCuGDzj4(JDzzdBbf7i1AbShMPZuxeXD4cBOUpkklesNeeOgoW6QrXCxxnkMbPF642EQlaBRRgfZEA17i5i1AbShMHLWnUK0sCRrXIIVGCYrQ1cypmdlChUqLgQqPi2ALGa1WLKWEAWXuqRvwfshYyhdTuTssypn4ykO1kRcPdzSJbPNgCyBd)RtosTwa7HzyH7WfknmkWUmiqnme9O6c)jgErZ1f(tr6rHGy1KggfyxYG0tdoST)6KA6DZP99y1CdjgKEAWHT9xNCKATa2dZWc3HlSMBifugCuuNcJyXbbQHLggfyxYqlvdIEuDH)edVO56c)Pi9OqqSJuRfWEygw4oCHk5Dtylk5i1AbShMHfUdx4liNI4saeiyhPwlG9WmSWD4cR52okfXwR4i1AbShMHfUdx4hqohXwReeOgwbTwz1CBhbXXNg(HbPNgCyBlMdhPH)KWSOolwSsTyByevNJuRfWEygw4oCHknuHsrS1kbbQH17Mt77XuiSa6C8f2Ifdspn4W2gcrveTvd)jCScBTa2RZC)RtQjDMoHH10jXTgvY7M4WPIMZriPTA4pffWdz7VoPME3CAFpMcHfqNJVWwSyq6PbhMdhPH)KWeWdfLnMaKTFrhPwlG9WmSWD4ctulwrTv)b2pbbQHRRgfZTUXses)0zBD1Oy2tREhPwlG9WmSWD4cXs)usjkiqnScATYACjPL4wJIffFb5edTKdNk43sIq6Pbh22qf7i1AbShMHfUdxyhFqHjcg3Aud3xSJuRfWEygw4oCHqcVxlG7p2q4(geOgwbTwzkewaDo(cBXIHwYHtf8Bjri90GdBBi15i1AbShMHfUdxOcHfqNJVWwSccudR3nN23J9cYPiUeabcMbPNgCyUeQyoCuPElIU(e2b(TKyTjoCQGFljcPNgCyBdvSJuRfWEygw4oCHAlWttWoITwXrQ1cypmdlChUqiH3RfW9hBiCFdcudRGwRmfclGohFHTyXql5WPc(TKiKEAWHTnK6CKATa2dZWc3HluHWcOZXxylwbbQH17Mt77XEb5uexcGabZG0tdomxcvmhoQuVfrxFc7a)wsS2ehovWVLeH0tdoSTHk2rQ1cypmdlChUqTf4PjyhXwR4i1AbShMHfUdx4hqoh17ZtFjhPwlG9WmSWD4cv6)4wJceO)GdcudRGwRmfclGohFHTyXs77XHtf8Bjri90GdBBXosTwa7HzyH7WfMaqkQqnwCKATa2dZWc3HluVkWoITwjiqnCG1vJIlGEXc31vJIzq6NovKa17Mt77X(aY5OEFE6lXG0tdoCbcfaxATa2J9bKZr9(80xIPxSWHJE3CAFp2hqoh17ZtFjgKEAWH5siU)1Pa4Wjqf0ALPqyb054lSflgAjhokO1k7imgC)Vn0oCuGDzj4(JDzzdBbfZqldqnvcrpQUWFI9LDzUJeKsOx8THXfMiihovWVLeH0tdoST2ZrQ1cypmdlChUqLgQqPi2ALGa1WkO1k7fKtrCjacemdT0rQ1cypmdlChUWgQ7JILOzmfeOgwbTwzkewaDo(cBXIL23JdNk43sIq6Pbh22IDKATa2dZWc3HluAyuGDzqGAyi6r1f(tm8IMRl8NI0JcbXC4arpQUWFIDegdU)3gAhokWUSeC)XUSSHTGIDKATa2dZWc3HlScjcza3FuGDzqGAyi6r1f(tSJWyW9)2q7Wrb2LLG7p2LLnSfuSJuRfWEygw4oCHnu3hfLfcPtccudhyD1OyURRgfZG0pDChQ4aSTUAum7PvVrmIXa]] )

end
