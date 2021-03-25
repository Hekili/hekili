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

        if active_dot.resonating_arrow > 0 then
            applyBuff( "resonating_arrow", max( debuff.resonating_arrow.remains, action.resonating_arrow.lastCast + buff.resonating_arrow.duration ) )
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
                    setCooldown( "kill_command", 0 )
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
                applyBuff( "resonating_arrow" )
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


    spec:RegisterPack( "Beast Mastery", 20210314, [[dWuwvbqisIEKQIKnrs5tqWOOu5uuQAvKeIxHk1SeKULGIDHYVeunmkfDmbAzqONjannbLCnvf2geL8nbqghjbCobLQ1PQOMNa6Esj7dvIdcrLfkiEOuQAIKeOlkaQpssOgjeLkNuayLqKzkLk3KKqANKK(PGszOquQAPqukpfvnvsQ(kevnwujDwvfP2lf)vObR0HLSys8ysnzrUmYMLQpRQA0uYPbwnjb9AvLMTOUTQy3Q8BfdxkoUQIy5GEoutN46qA7sP8DvPXtPW5PuA9qumFuX(PAtqJ6g(ujKrveTjIbTzadgwmedAte)iaz4fBBidFtP)w)KH)QhYWhcvyXxv0cle0wdFtzBEQKrDdpEqHAYWBjsd(ZHh(pqSqvy65jCm4bnxcyonS6s4yWJoCdVckilbWzum8PsiJQiAtedAZagmSyig0Mi(rqdFHkwd0WZdEAVH3cKs0zum8jcRn8Hqfw8vfTWcbT1xKDONqqhjv0cQT8nyyfQViAtedA4ZaSGnQB4tuVqZIrDJQbnQB4lTaMZWRh0tiyeBnIHNUsjtjtigXOkIg1n80vkzkzcXWxAbmNHxGG7ljbn8jcRHGgbmNHpa6(kwKVceCFjXxRc7B57CHbft(QG27H6l22t7lq89fiw(IC4gsl(oDFflYxKhKtmFdGUVY74BbjF1ZtdjG733(a9T8f5WnKw8D6(kwKVipiN8fB7Pd1xum5Ryr(If4C)e035cdkM8L6DslmFdGUV157CHbft(QG27(cW(cPkzRVkOIV1nIfb9flW5(jOVZfgum5RcAV77liN9TY4XxfYxivjB9vXwFflYxb8q(IC4gsl(oDFflYxKhKt(QNhc7RsP)6707(QNjNM3luFrXKVaXxq3xXI8fBvqk5Rab3xs8vptonVNVVZHG4l4ec2ji57lqS8vSiFrB0Zd4(9f5WnKw8D6(kwKVipiN8fB7Pz(gaDFRZ35cdkM8vbT39vpO5KVkKVOyk5BDjFXciN9vppKVkL(RV9b6B5BhvqHKVihUH0IVt3xXI8f5b5uO(IIjFbcZ3aO7B57nxyuq7DFNlmOyYxa2xivjBd1xum5lq8f09fi((ohcIVGtiyNGKVVaXY3MrOtav235cdkM8vbT3X(kqBb3VVY4lYHBiT4709vSiFrEqo5l22t77a9f09vSiFhXIG(kqW9LeFb4dbX368DUWGIPq9fG9T89MlmkO9UVZfgum57lqS8T8np3pb9vptonVxO(oqFb4dbXxivjBz(gaDFflY3o43s8fG99Fa3VVY4lDjFvO(ajFTDqH(EKneFroCdPfFNUVIf5lYdYPq9vfIIfFXsbfFrXG73xbcUVKG9vgFFQVKVyui5Ryr267pj(IIPeZWRHaHGGYWlqW9LeMeKzv4ikMIkO9UVQ5RD(QG27Sc3qAjo9OyrXxqoXqB8vnFTZxv6Rab3xsycImRchrXuubT39LdhFfi4(sctqKPNjNM3JbPNcCyF5WXxbcUVKWKGm9m508ESekSeWC(YLw(kqW9LeMGitptonVhlHclbmNV27lho(QG27Sc3qAjo9OyrXxqoXsZ75RA(ANVceCFjHjiYSkCeftrf0E3x18vGG7ljmbrMEMCAEpwcfwcyoF5slFfi4(sctcY0ZKtZ7XsOWsaZ5RA(kqW9LeMGitptonVhdspf4W(ggF)W3a9vptonVhRWnKwItpkwu8fKtmi9uGd7RA(QNjNM3Jv4gslXPhflk(cYjgKEkWH9Ll(IOn9LdhFfi4(sctcY0ZKtZ7XsOWsaZ5By89dFd0x9m508ESc3qAjo9OyrXxqoXG0tboSV27lho(kf8NeMaEOOmXeG8nqF1ZKtZ7XkCdPL40JIffFb5edspf4W(AVVC44Rk9vGG7ljmjiZQWrumfvq7DFvZx78vGG7ljmbrMvHJOykQG27(QMV25RcAVZkCdPL40JIffFb5elnVNVC44Rab3xsycIm9m508Emi9uGd7lx89dFT3x181oF1ZKtZ7XkCdPL40JIffFb5edspf4W(YfFr0M(YHJVceCFjHjiY0ZKtZ7XG0tboSVHX3p8Ll(QNjNM3Jv4gslXPhflk(cYjgKEkWH91EF5WXxv6Rab3xsycImRchrXuubT39vnFTZxv6Rab3xsycImRch1ZKtZ75lho(kqW9LeMGitptonVhlHclbmNVCPLVceCFjHjbz6zYP59yjuyjG58LdhFfi4(sctqKPNjNM3JbPNcCyFT3x7nIr1aAu3WtxPKPKjedVgcecckdVab3xsycImRchrXuubT39vnFTZxf0ENv4gslXPhflk(cYjgAJVQ5RD(QsFfi4(sctcYSkCeftrf0E3xoC8vGG7ljmjitptonVhdspf4W(YHJVceCFjHjiY0ZKtZ7XsOWsaZ5lxA5Rab3xsysqMEMCAEpwcfwcyoFT3xoC8vbT3zfUH0sC6rXIIVGCILM3Zx181oFfi4(sctcYSkCeftrf0E3x18vGG7ljmjitptonVhlHclbmNVCPLVceCFjHjiY0ZKtZ7XsOWsaZ5RA(kqW9LeMeKPNjNM3JbPNcCyFdJVF4BG(QNjNM3Jv4gslXPhflk(cYjgKEkWH9vnF1ZKtZ7XkCdPL40JIffFb5edspf4W(YfFr0M(YHJVceCFjHjiY0ZKtZ7XsOWsaZ5By89dFd0x9m508ESc3qAjo9OyrXxqoXG0tboSV27lho(kf8NeMaEOOmXeG8nqF1ZKtZ7XkCdPL40JIffFb5edspf4W(AVVC44Rk9vGG7ljmbrMvHJOykQG27(QMV25Rab3xsysqMvHJOykQG27(QMV25RcAVZkCdPL40JIffFb5elnVNVC44Rab3xsysqMEMCAEpgKEkWH9Ll((HV27RA(ANV6zYP59yfUH0sC6rXIIVGCIbPNcCyF5IViAtF5WXxbcUVKWKGm9m508Emi9uGd7By89dF5IV6zYP59yfUH0sC6rXIIVGCIbPNcCyFT3xoC8vL(kqW9LeMeKzv4ikMIkO9UVQ5RD(QsFfi4(sctcYSkCuptonVNVC44Rab3xsysqMEMCAEpwcfwcyoF5slFfi4(sctqKPNjNM3JLqHLaMZxoC8vGG7ljmjitptonVhdspf4W(AVV2B4lTaMZWlqW9LeenIr1WYOUHNUsjtjtig(eH1qqJaMZWxAbmhMLOEHMfUBfokMIaHEWg(slG5m8cSUpbfKbid4(JyRrmIr1pmQB4PRuYuYeIHxdbcbbLHVbsTf)1jwqwHBiTeNEuSO4liN8LdhF7GFljcPNcCyFd0xeTPHV0cyodpkMIaHEWgXOkYYOUHNUsjtjtig(slG5m86kNJLwaZfZaSy4ZaSeV6Hm86e2igvdqg1n80vkzkzcXWRHaHGGYWxAb0gfPJEae23a9frdFPfWCgEDLZXslG5Izawm8zawIx9qgESyeJQQag1n80vkzkzcXWRHaHGGYWxAb0gfPJEae2xU4BqdFPfWCgEDLZXslG5Izawm8zawIx9qgEDMQ2iJyedFdK0ZJsjg1nQg0OUHV0cyodpg95zUydjgE6kLmLmHyeJQiAu3WxAbmNHxzejtPypx2sPxW9hLXgGZWtxPKPKjeJyunGg1n80vkzkzcXWF1dz4lKbBvWch7ZjXPhBMxcA4lTaMZWxid2QGfo2NtItp2mVe0igvdlJ6gE6kLmLmHy4BGKUWsuapKHpi7ddFPfWCgEPGrbwngEneieeugEi6r9b(tm8GM7d8NI0JcbXm6kLmL8LdhFHOh1h4pXocJb3)BbTfhfy10aU)y10uWsqXm6kLmLmIr1pmQB4PRuYuYeIHVbs6clrb8qg(GSpm8LwaZz4viSaQC8fwILHxdbcbbLHxL(kvMoHH10jXPhvYZKy0vkzk5RA(QsFHOh1h4pXWdAUpWFkspkeeZORuYuYigvrwg1n80vkzkzcXW3ajDHLOaEidFqwan8jcRHGgbmNHh5sQquSG9vSiFtOWsaZ5BDjF1ZKtZ75709f5WnKw8D6(kwKVipiN8TUKVi7HGNk7BaCybCAb7RIT(kwKVjuyjG58D6(wNVONvHfk5RkU9QG((ArNVIfzlcqYxumL8Tbs65rPeMVHq6cft(IC4gsl(oDFflYxKhKt(cPeQMW(QIBVkOVk26lI20Mp4q9vSayFbyFdYcOVyspxcZm8LwaZz4lCdPL40JIffFb5KHxdbcbbLHxL(widbbcXAGGNkhbhwaNwWm6kLmL8vnFvPVegtNMyegtNMItpkwuSpAum4(JaiaZEkv4a9vnFTZx6tqbnnuIvid2QGfo2NtItp2mVe0xoC8vL(sFckOPHsmTT68iW5a6OsUWIV2BeJQbiJ6gE6kLmLmHy4BGKUWsuapKHpi7ddFIWAiOraZz4rUKkeflyFflY3ekSeWC(wxYx9m508E(oDFdHWcOY(I8WsS8TUKVi7kKH8D6(ISv)KVk26Ryr(MqHLaMZ3P7BD(IEwfwOKVQ42Rc67RfD(kwKTiajFrXuY3giPNhLsyg(slG5m8kewavo(clXYWRHaHGGYWxidbbcXAGGNkhbhwaNwWm6kLmL8vnFvPVegtNMyegtNMItpkwuSpAum4(JaiaZEkv4a9vnFTZx6tqbnnuIvid2QGfo2NtItp2mVe0xoC8vL(sFckOPHsmTT68iW5a6OsUWIV2BeJy41jSrDJQbnQB4PRuYuYeIHxdbcbbLHxptonVhtHWcOYXxyjwmi9uGd7lx8nG20WxAbmNHVonHfyLJ6kNnIrvenQB4PRuYuYeIHxdbcbbLHxptonVhtHWcOYXxyjwmi9uGd7lx8nG20WxAbmNHVdGKsEMKrmQgqJ6gE6kLmLmHy41qGqqqz4TZxf0EN9cYPiUbabcMH24lho(QsF1tB0vNWoWVLe7f5RA(QG27Sc3qAjo9OyrXxqoXqB8vnFvq7DMcHfqLJVWsSyOn(AVVQ5RD(2b)wsespf4W(YfF1ZKtZ7XuiiMGFb3plHclbmNVC7BcfwcyoF5WXx78vk4pjmlQYIfRrl(gOVb8dF5WXxv6Ruz6e2xqotWi4Wc40cJUsjtjFT3x79LdhF7GFljcPNcCyFd03Gb0WxAbmNHxHGyc(fC)gXOAyzu3WtxPKPKjedVgcecckdVD(QG27SxqofXnaiqWm0gF5WXxv6REAJU6e2b(TKyViFvZxf0ENv4gslXPhflk(cYjgAJVQ5RcAVZuiSaQC8fwIfdTXx79vnFTZ3o43sIq6Pah2xU4REMCAEpMsEMuSJcTLLqHLaMZxU9nHclbmNVC44RD(kf8NeMfvzXI1OfFd03a(HVC44Rk9vQmDc7liNjyeCybCAHrxPKPKV27R9(YHJVDWVLeH0tboSVb6BqKLHV0cyodVsEMuSJcT1igv)WOUHV0cyodFg8Bj4Oken9)qNy4PRuYuYeIrmQISmQB4PRuYuYeIHxdbcbbLHxbT3zfUH0sC6rXIIVGCIH24lho(2b)wsespf4W(gOViISm8LwaZz4BgbmNrmIHhlg1nQg0OUHV0cyodFHBiTeNEuSO4liNm80vkzkzcXigvr0OUHNUsjtjtigEneieeugEf0EN1H0Hm2YqB8vnFvq7DwhshYyldspf4W(gylF)1jdFPfWCgELcQqPi2AeJyunGg1n80vkzkzcXWRHaHGGYWdrpQpWFIHh0CFG)uKEuiiMrxPKPKVQ5RuWOaRggKEkWH9nqF)1jFvZx9m508ESEUGedspf4W(gOV)6KHV0cyodVuWOaRgJyunSmQB4PRuYuYeIHV0cyodFpxqYWRHaHGGYWlfmkWQHH24RA(crpQpWFIHh0CFG)uKEuiiMrxPKPKHpdokQtgEe)Wigv)WOUHV0cyodVsEMe2IsgE6kLmLmHyeJQilJ6g(slG5m8VGCkIBaqGGn80vkzkzcXigvdqg1n8LwaZz475YwkfXwJy4PRuYuYeIrmQQcyu3WxAbmNH)liNJyRrm80vkzkzcXigvd7g1n80vkzkzcXWRHaHGGYWRNjNM3JPqybu54lSelgKEkWH9nqFdIOVQi(QTk4pHJDyPfWCv2xU99xN8vnFLktNWWA6K40Jk5zsm6kLmL8LdhF7O5CesARc(trb8q(gOV)6KVQ5REMCAEpMcHfqLJVWsSyq6Pah2xoC8vk4pjmb8qrzIja5BG(g2n8LwaZz4vkOcLIyRrmIr1G20OUHNUsjtjtigEneieeug((OrX(YTV6clri9tNVb6BF0Oy2tzddFPfWCg(evIvuBvFH1JrmQgmOrDdpDLsMsMqm8AiqiiOm8kO9oRWnKwItpkwu8fKtm0gF5WX3o43sIq6Pah23a9n4hg(slG5m8yPEAOezeJQbr0OUHV0cyodFfFqHjcgNEudNxSHNUsjtjtigXOAWaAu3WtxPKPKjedVgcecckdVcAVZuiSaQC8fwIfdTXxoC8Td(TKiKEkWH9nqFdAtdFPfWCgEiHNReW9hliCEnIr1GHLrDdpDLsMsMqm8AiqiiOm86zYP59yVGCkIBaqGGzq6Pah2xU4BWp8LdhFvPV6Pn6Qtyh43sI9I8LdhF7GFljcPNcCyFd03GFy4lTaMZWRqybu54lSelJyun4hg1n8LwaZz41wGNIGveBnIHNUsjtjtigXOAqKLrDdpDLsMsMqm8AiqiiOm8kO9otHWcOYXxyjwm0gF5WX3o43sIq6Pah23a9nOnn8LwaZz4HeEUsa3FSGW51igvdgGmQB4PRuYuYeIHxdbcbbLHxptonVh7fKtrCdacemdspf4W(YfFd(HVC44Rk9vpTrxDc7a)wsSxKVC44Bh8Bjri9uGd7BG(g8ddFPfWCgEfclGkhFHLyzeJQbvbmQB4lTaMZWRTapfbRi2AedpDLsMsMqmIr1GHDJ6g(slG5m8Fb5Cuppp1Lm80vkzkzcXigvr0Mg1n80vkzkzcXWRHaHGGYWRG27mfclGkhFHLyXsZ75lho(2b)wsespf4W(gOVFy4lTaMZWRu)XPhfiq)fBeJQig0OUHV0cyodFcaPOcvyXWtxPKPKjeJyufrenQB4PRuYuYeIHxdbcbbLH3oF7Jgf7By8vpyXxU9TpAumds)05RkIV25REMCAEp2xqoh1ZZtDjgKEkWH9nm(g0x79Ll(wAbmh7liNJ655PUetpyXxoC8vptonVh7liNJ655PUedspf4W(YfFd6l3((Rt(AVVC44RD(QG27mfclGkhFHLyXqB8LdhFvq7D2rym4(FlOT4OaRMgW9hRMMcwckMH24R9(QMVQ0xi6r9b(tSpPAYvKGuc9IVfmoWebz0vkzk5lho(2b)wsespf4W(gOVb0WxAbmNHxpkWkITgXigvrmGg1n80vkzkzcXWRHaHGGYWRG27SxqofXnaiqWm0gdFPfWCgELcQqPi2AeJyufXWYOUHNUsjtjtigEneieeugEf0ENPqybu54lSelwAEpF5WX3o43sIq6Pah23a99ddFPfWCg(cQRJInOzmzeJQi(HrDdpDLsMsMqm8AiqiiOm8q0J6d8Ny4bn3h4pfPhfcIz0vkzk5lho(crpQpWFIDegdU)3cAlokWQPbC)XQPPGLGIz0vkzkz4lTaMZWlfmkWQXigvrezzu3WtxPKPKjedVgcecckdpe9O(a)j2rym4(FlOT4OaRMgW9hRMMcwckMrxPKPKHV0cyodFhseYaU)OaRgJyufXaKrDdpDLsMsMqm8AiqiiOm825BF0OyF523(OrXmi9tNVC7BWp81EFd03(OrXSNYgg(slG5m8fuxhfLbcPtmIrm86mvTrg1nQg0OUHV0cyodFHBiTeNEuSO4liNm80vkzkzcXigvr0OUHNUsjtjtig(slG5m8kfuHsrS1igEneieeugEf0EN1H0Hm2YqB8vnFvq7DwhshYyldspf4W(gylF)1jdV2wDMIsb)jbBunOrmQgqJ6gE6kLmLmHy41qGqqqz4)1jFdJVkO9otHkSe1zQAJyq6Pah2xU4Rnzi(HHV0cyod)dAwayRrmIr1WYOUHNUsjtjtigEneieeugEi6r9b(tm8GM7d8NI0JcbXm6kLmL8vnFLcgfy1WG0tboSVb67Vo5RA(QNjNM3J1ZfKyq6Pah23a99xNm8LwaZz4Lcgfy1yeJQFyu3WtxPKPKjedFPfWCg(EUGKHxdbcbbLHxkyuGvddTXx18fIEuFG)edpO5(a)Pi9OqqmJUsjtjdFgCuuNm8i(HrmQISmQB4PRuYuYeIHxdbcbbLHVpAuSVC7RUWses)05BG(2hnkM9u2WWxAbmNHprLyf1w1xy9yeJQbiJ6g(slG5m8VGCkIBaqGGn80vkzkzcXigvvbmQB4PRuYuYeIHV0cyodVsbvOueBnIHxdbcbbLHVJMZriPTk4pffWd5BG((Rt(QMV6zYP59ykewavo(clXIbPNcCyF5WXx9m508EmfclGkhFHLyXG0tboSVb6Bqe9LBF)1jFvZxPY0jmSMojo9OsEMeJUsjtjdV2wDMIsb)jbBunOrmQg2nQB4lTaMZWRqybu54lSeldpDLsMsMqmIr1G20OUHV0cyodpKWZvc4(JfeoVgE6kLmLmHyeJQbdAu3WtxPKPKjedVgcecckdVcAVZkCdPL40JIffFb5edTXxoC8Td(TKiKEkWH9nqFd(HHV0cyodpwQNgkrgXOAqenQB4lTaMZW3ZLTukITgXWtxPKPKjeJyunyanQB4lTaMZW)fKZrS1igE6kLmLmHyeJQbdlJ6g(slG5m8AlWtrWkITgXWtxPKPKjeJyun4hg1n8LwaZz4vYZKWwuYWtxPKPKjeJyuniYYOUHV0cyodFfFqHjcgNEudNxSHNUsjtjtigXOAWaKrDdpDLsMsMqm8AiqiiOm8kO9oRdPdzSLbPNcCyF5IVKninQqrb8qg(slG5m8kfew)KrmQgufWOUHNUsjtjtigEneieeug((OrX(YfF1dw8LBFlTaMJ9GMfa2AeMEWIHV0cyod)xqoh1ZZtDjJyunyy3OUHNUsjtjtigEneieeugEf0ENPqybu54lSelwAEpF5WX3o43sIq6Pah23a99ddFPfWCgEL6po9Oab6VyJyufrBAu3WxAbmNHpbGuuHkSy4PRuYuYeIrmQIyqJ6gE6kLmLmHy4lTaMZWRuqfkfXwJy41qGqqqz4Lc(tctapuuMycq(gOVHDdV2wDMIsb)jbBunOrmQIiIg1n80vkzkzcXWRHaHGGYW3hnkMjGhkkt8PSHVb67Vo5RkIViA4lTaMZWRhfyfXwJyeJQigqJ6gE6kLmLmHy41qGqqqz4HOh1h4pXWdAUpWFkspkeeZORuYuYxoC8fIEuFG)e7imgC)Vf0wCuGvtd4(JvttblbfZORuYuYWxAbmNHxkyuGvJrmQIyyzu3WtxPKPKjedVgcecckdpe9O(a)j2rym4(FlOT4OaRMgW9hRMMcwckMrxPKPKHV0cyodFhseYaU)OaRgJyufXpmQB4PRuYuYeIHxdbcbbLH3oF7Jgf7l3(2hnkMbPF68LBFdOn91EFd03(OrXSNYgg(slG5m8fuxhfLbcPtmIrmIHVncIbZzufrBIyqBgqBgGm8Vf8a3p2WJ8ihYMQbGQQ4p7RVQBr(cEAgO4BFG(IqI6fAwqWxi9jOaiL8fppKVfQmpLqjF1w19tyMJu7ah5lIF232pxBeuOKViiqW9LewqgxrWxz8fbbcUVKWKGmUIGV2HSSH9mhP2boYxe)SVTFU2iOqjFrqGG7ljmezCfbFLXxeei4(sctqKXve81UGb0g2ZCKAh4iFd4N9T9Z1gbfk5lcceCFjHfKXve8vgFrqGG7ljmjiJRi4RDbdOnSN5i1oWr(gWp7B7NRnckuYxeei4(scdrgxrWxz8fbbcUVKWeezCfbFTdzzd7zososipYHSPAaOQk(Z(6R6wKVGNMbk(2hOVi0aj98Oucc(cPpbfaPKV45H8TqL5Pek5R2QUFcZCKAh4iFdRp7B7NRnckuYxeGOh1h4pX4kc(kJViarpQpWFIXvgDLsMsi4Bj(gGdBTZx7cAd7zosTdCKVH1N9T9Z1gbfk5lcq0J6d8NyCfbFLXxeGOh1h4pX4kJUsjtje81UG2WEMJu7ah57hF232pxBeuOKViivMoHXve8vgFrqQmDcJRm6kLmLqWx7cAd7zosTdCKVF8zFB)CTrqHs(Iae9O(a)jgxrWxz8fbi6r9b(tmUYORuYucbFlX3aCyRD(AxqBypZrYrc5roKnvdavvXF2xFv3I8f80mqX3(a9fbDcJGVq6tqbqk5lEEiFluzEkHs(QTQ7NWmhP2boY3a(zFB)CTrqHs(IGuz6egxrWxz8fbPY0jmUYORuYucbFTlOnSN5i1oWr(gwF232pxBeuOKViivMoHXve8vgFrqQmDcJRm6kLmLqWx7cAd7zososipYHSPAaOQk(Z(6R6wKVGNMbk(2hOViGfe8fsFckasjFXZd5BHkZtjuYxTvD)eM5i1oWr(I4N9T9Z1gbfk5lcnKW4k7tZyme8vgFr4tZyme81oeTH9mhP2boY3a(zFB)CTrqHs(Iae9O(a)jgxrWxz8fbi6r9b(tmUYORuYucbFTlOnSN5i1oWr(gwF232pxBeuOKViarpQpWFIXve8vgFraIEuFG)eJRm6kLmLqW3s8nah2ANV2f0g2ZCKAh4iFd7F232pxBeuOKViivMoHXve8vgFrqQmDcJRm6kLmLqWx7cAd7zosTdCKViI4N9T9Z1gbfk5lcq0J6d8NyCfbFLXxeGOh1h4pX4kJUsjtje81UG2WEMJu7ah5lIF8zFB)CTrqHs(Iae9O(a)jgxrWxz8fbi6r9b(tmUYORuYucbFlX3aCyRD(AxqBypZrQDGJ8fXp(SVTFU2iOqjFraIEuFG)eJRi4Rm(Iae9O(a)jgxz0vkzkHGV2f0g2ZCKAh4iFrez9zFB)CTrqHs(Iae9O(a)jgxrWxz8fbi6r9b(tmUYORuYucbFlX3aCyRD(AxqBypZrYrc5roKnvdavvXF2xFv3I8f80mqX3(a9fbDMQ2ie8fsFckasjFXZd5BHkZtjuYxTvD)eM5i1oWr(I4N9T9Z1gbfk5lcnKW4k7tZyme8vgFr4tZyme81oeTH9mhP2boY3a(zFB)CTrqHs(IqdjmUY(0mgdbFLXxe(0mgdbFTlOnSN5i1oWr(gwF232pxBeuOKViarpQpWFIXve8vgFraIEuFG)eJRm6kLmLqWx7cAd7zosTdCKVF8zFB)CTrqHs(Iae9O(a)jgxrWxz8fbi6r9b(tmUYORuYucbFlX3aCyRD(AxqBypZrQDGJ8vf4Z(2(5AJGcL8fbPY0jmUIGVY4lcsLPtyCLrxPKPec(wIVb4Ww781UG2WEMJu7ah5BWa0N9T9Z1gbfk5lcnKW4k7tZyme8vgFr4tZyme81UG2WEMJu7ah5lIb8Z(2(5AJGcL8fbi6r9b(tmUIGVY4lcq0J6d8NyCLrxPKPec(wIVb4Ww781UG2WEMJu7ah5lIb8Z(2(5AJGcL8fbi6r9b(tmUIGVY4lcq0J6d8NyCLrxPKPec(AxqBypZrQDGJ8fXW6Z(2(5AJGcL8fbi6r9b(tmUIGVY4lcq0J6d8NyCLrxPKPec(wIVb4Ww781UG2WEMJKJua80mqHs((HVLwaZ5BgGfmZrYWJBiTrve)iGg(g40bzYW)P(u(gcvyXxv0cle0wFr2HEcbDK(uFkFvrlO2Y3GHvO(IOnrmOJKJuPfWCywdK0ZJsjTWOppZfBiXrQ0cyomRbs65rPeUBfUYisMsXEUSLsVG7pkJnaNJuPfWCywdK0ZJsjC3kCumfbc9e6vpuRczWwfSWX(CsC6XM5LGosLwaZHznqsppkLWDRWLcgfy1eAdK0fwIc4HAfK9rOGEli6r9b(tm8GM7d8NI0JcbXC4arpQpWFIDegdU)3cAlokWQPbC)XQPPGLGIDKkTaMdZAGKEEukH7wHRqybu54lSeRqBGKUWsuapuRGSpcf0BPsPY0jmSMojo9OsEMKAQeIEuFG)edpO5(a)Pi9OqqSJ0NYxKlPcrXc2xXI8nHclbmNV1L8vptonVNVt3xKd3qAX3P7Ryr(I8GCY36s(IShcEQSVbWHfWPfSVk26Ryr(MqHLaMZ3P7BD(IEwfwOKVQ42Rc67RfD(kwKTiajFrXuY3giPNhLsy(gcPlum5lYHBiT4709vSiFrEqo5lKsOAc7RkU9QG(QyRViAtB(Gd1xXcG9fG9nilG(Ij9CjmZrQ0cyomRbs65rPeUBfEHBiTeNEuSO4liNcTbs6clrb8qTcYcyOGElvwidbbcXAGGNkhbhwaNwWm6kLmLutLegtNMyegtNMItpkwuSpAum4(JaiaZEkv4avZo6tqbnnuIvid2QGfo2NtItp2mVeKdhvsFckOPHsmTT68iW5a6OsUWI9osFkFrUKkeflyFflY3ekSeWC(wxYx9m508E(oDFdHWcOY(I8WsS8TUKVi7kKH8D6(ISv)KVk26Ryr(MqHLaMZ3P7BD(IEwfwOKVQ42Rc67RfD(kwKTiajFrXuY3giPNhLsyosLwaZHznqsppkLWDRWviSaQC8fwIvOnqsxyjkGhQvq2hHc6TkKHGaHynqWtLJGdlGtlygDLsMsQPscJPttmcJPttXPhflk2hnkgC)raeGzpLkCGQzh9jOGMgkXkKbBvWch7ZjXPhBMxcYHJkPpbf00qjM2wDEe4CaDujxyXEhjhPslG5WC3kC9GEcbJyRrCK(u(gaDFflYxbcUVK4RvH9T8DUWGIjFvq79q9fB7P9fi((celFroCdPfFNUVIf5lYdYjMVbq3x5D8TGKV65PHeW97BFG(w(IC4gsl(oDFflYxKhKt(IT90H6lkM8vSiFXcCUFc67CHbft(s9oPfMVbq3368DUWGIjFvq7DFbyFHuLS1xfuX36gXIG(If4C)e035cdkM8vbT399fKZ(wz84Rc5lKQKT(QyRVIf5RaEiFroCdPfFNUVIf5lYdYjF1ZdH9vP0F9D6DF1ZKtZ7fQVOyYxG4lO7Ryr(ITkiL8vGG7lj(QNjNM3Z335qq8fCcb7eK89fiw(kwKVOn65bC)(IC4gsl(oDFflYxKhKt(IT90mFdGUV157CHbft(QG27(Qh0CYxfYxumL8TUKVybKZ(QNhYxLs)13(a9T8TJkOqYxKd3qAX3P7Ryr(I8GCkuFrXKVaH5Ba09T89MlmkO9UVZfgum5la7lKQKTH6lkM8fi(c6(ceFFNdbXxWjeStqY3xGy5BZi0jGk77CHbft(QG27yFfOTG73xz8f5WnKw8D6(kwKVipiN8fB7P9DG(c6(kwKVJyrqFfi4(sIVa8HG4BD(oxyqXuO(cW(w(EZfgf0E335cdkM89fiw(w(MN7NG(QNjNM3luFhOVa8HG4lKQKTmFdGUVIf5Bh8Bj(cW((pG73xz8LUKVkuFGKV2oOqFpYgIVihUH0IVt3xXI8f5b5uO(QcrXIVyPGIVOyW97Rab3xsW(kJVp1xYxmkK8vSiB99NeFrXuI5ivAbmhM7wHlqW9LKGHc6Tei4(scliZQWrumfvq7D1StbT3zfUH0sC6rXIIVGCIH2OMDQuGG7ljmezwfoIIPOcAVZHJab3xsyiY0ZKtZ7XG0tbomhoceCFjHfKPNjNM3JLqHLaMJlTei4(scdrMEMCAEpwcfwcyo75WrbT3zfUH0sC6rXIIVGCILM3tn7ei4(scdrMvHJOykQG27QjqW9LegIm9m508ESekSeWCCPLab3xsybz6zYP59yjuyjG5utGG7ljmez6zYP59yq6PahomFeOEMCAEpwHBiTeNEuSO4liNyq6Pahwn9m508ESc3qAjo9OyrXxqoXG0tbomxq0MC4iqW9LewqMEMCAEpwcfwcyUW8rG6zYP59yfUH0sC6rXIIVGCIbPNcCy75Wrk4pjmb8qrzIjafOEMCAEpwHBiTeNEuSO4liNyq6Pah2EoCuPab3xsybzwfoIIPOcAVRMDceCFjHHiZQWrumfvq7D1StbT3zfUH0sC6rXIIVGCILM3JdhbcUVKWqKPNjNM3JbPNcCyU8H9QzNEMCAEpwHBiTeNEuSO4liNyq6PahMliAtoCei4(scdrMEMCAEpgKEkWHdZhCrptonVhRWnKwItpkwu8fKtmi9uGdBphoQuGG7ljmezwfoIIPOcAVRMDQuGG7ljmezwfoQNjNM3JdhbcUVKWqKPNjNM3JLqHLaMJlTei4(sclitptonVhlHclbmhhoceCFjHHitptonVhdspf4W2BVJuPfWCyUBfUab3xsqmuqVLab3xsyiYSkCeftrf0Exn7uq7DwHBiTeNEuSO4liNyOnQzNkfi4(scliZQWrumfvq7DoCei4(sclitptonVhdspf4WC4iqW9LegIm9m508ESekSeWCCPLab3xsybz6zYP59yjuyjG5SNdhf0ENv4gslXPhflk(cYjwAEp1StGG7ljSGmRchrXuubT3vtGG7ljSGm9m508ESekSeWCCPLab3xsyiY0ZKtZ7XsOWsaZPMab3xsybz6zYP59yq6PahomFeOEMCAEpwHBiTeNEuSO4liNyq6Pahwn9m508ESc3qAjo9OyrXxqoXG0tbomxq0MC4iqW9LegIm9m508ESekSeWCH5Ja1ZKtZ7XkCdPL40JIffFb5edspf4W2ZHJuWFsyc4HIYetakq9m508ESc3qAjo9OyrXxqoXG0tboS9C4OsbcUVKWqKzv4ikMIkO9UA2jqW9LewqMvHJOykQG27QzNcAVZkCdPL40JIffFb5elnVhhoceCFjHfKPNjNM3JbPNcCyU8H9QzNEMCAEpwHBiTeNEuSO4liNyq6PahMliAtoCei4(sclitptonVhdspf4WH5dUONjNM3Jv4gslXPhflk(cYjgKEkWHTNdhvkqW9LewqMvHJOykQG27QzNkfi4(scliZQWr9m508EC4iqW9LewqMEMCAEpwcfwcyoU0sGG7ljmez6zYP59yjuyjG54WrGG7ljSGm9m508Emi9uGdBV9osFkFlTaMdZDRWrXuei0d2rQ0cyom3TcxG19jOGmaza3FeBnIJuPfWCyUBfokMIaHEWHc6TAGuBXFDIfKv4gslXPhflk(cYjoC6GFljcPNcC4ar0MosLwaZH5Uv46kNJLwaZfZaSe6vpulDc7ivAbmhM7wHRRCowAbmxmdWsOx9qTWsOGERslG2OiD0dGWbIOJuPfWCyUBfUUY5yPfWCXmalHE1d1sNPQnkuqVvPfqBuKo6bqyUe0rYrQ0cyomtNWTQttybw5OUY5qb9w6zYP59ykewavo(clXIbPNcCyUeqB6ivAbmhMPtyUBfEhajL8mPqb9w6zYP59ykewavo(clXIbPNcCyUeqB6ivAbmhMPtyUBfUcbXe8l4(df0BzNcAVZEb5ue3aGabZqB4WrL6Pn6Qtyh43sI9IutbT3zfUH0sC6rXIIVGCIH2OMcAVZuiSaQC8fwIfdTXE1SRd(TKiKEkWH5IEMCAEpMcbXe8l4(zjuyjG54oHclbmhho2jf8NeMfvzXI1OLad4hC4OsPY0jSVGCMGrWHfWPf7TNdNo43sIq6PahoWGb0rQ0cyomtNWC3kCL8mPyhfABOGEl7uq7D2liNI4gaeiygAdhoQupTrxDc7a)wsSxKAkO9oRWnKwItpkwu8fKtm0g1uq7DMcHfqLJVWsSyOn2RMDDWVLeH0tbomx0ZKtZ7XuYZKIDuOTSekSeWCCNqHLaMJdh7Kc(tcZIQSyXA0sGb8doCuPuz6e2xqotWi4Wc40I92ZHth8Bjri9uGdhyqKLJuPfWCyMoH5Uv4zWVLGJQq00)dDIJuPfWCyMoH5Uv4nJaMluqVLcAVZkCdPL40JIffFb5edTHdNo43sIq6PahoqerwososLwaZHz6mvTrTkCdPL40JIffFb5KJuPfWCyMotvBe3TcxPGkukITgjuTT6mfLc(tcUvWqb9wnKWEkWXuq7DwhshYyldTrTgsypf4ykO9oRdPdzSLbPNcC4aB9RtosLwaZHz6mvTrC3k8h0SaWwJekO36xNctdjSNcCmf0ENPqfwI6mvTrmi9uGdZfBYq8dhPslG5WmDMQ2iUBfUuWOaRMqb9wq0J6d8Ny4bn3h4pfPhfcIvtkyuGvddspf4Wb(RtQPNjNM3J1ZfKyq6PahoWFDYrQ0cyomtNPQnI7wH3ZfKcndokQtTq8Jqb9wsbJcSAyOnQbrpQpWFIHh0CFG)uKEuii2rQ0cyomtNPQnI7wHNOsSIAR6lSEcf0B1hnkMBDHLiK(PlW(OrXSNYgosLwaZHz6mvTrC3k8xqofXnaiqWosLwaZHz6mvTrC3kCLcQqPi2AKq12QZuuk4pj4wbdf0B1rZ5iK0wf8NIc4Hc8xNutptonVhtHWcOYXxyjwmi9uGdZHJEMCAEpMcHfqLJVWsSyq6PahoWGiY9VoPMuz6egwtNeNEujptYrQ0cyomtNPQnI7wHRqybu54lSelhPslG5WmDMQ2iUBfoKWZvc4(JfeoVosLwaZHz6mvTrC3kCSupnuIcf0BPG27Sc3qAjo9OyrXxqoXqB4WPd(TKiKEkWHdm4hosLwaZHz6mvTrC3k8EUSLsrS1iosLwaZHz6mvTrC3k8VGCoITgXrQ0cyomtNPQnI7wHRTapfbRi2AehPslG5WmDMQ2iUBfUsEMe2IsosLwaZHz6mvTrC3k8k(Gctemo9OgoVyhPslG5WmDMQ2iUBfUsbH1pfkO3QHe2tboMcAVZ6q6qgBzq6PahMlKninQqrb8qosLwaZHz6mvTrC3k8VGCoQNNN6sHc6T6JgfZf9GfUlTaMJ9GMfa2AeMEWIJuPfWCyMotvBe3TcxP(JtpkqG(louqVLcAVZuiSaQC8fwIflnVhhoDWVLeH0tboCGF4ivAbmhMPZu1gXDRWtaifvOclosLwaZHz6mvTrC3kCLcQqPi2AKq12QZuuk4pj4wbdf0Bjf8NeMaEOOmXeGcmS7ivAbmhMPZu1gXDRW1JcSIyRrcf0B1hnkMjGhkkt8PSrG)6KkcIosLwaZHz6mvTrC3kCPGrbwnHc6TGOh1h4pXWdAUpWFkspkeeZHde9O(a)j2rym4(FlOT4OaRMgW9hRMMcwck2rQ0cyomtNPQnI7wH3HeHmG7pkWQjuqVfe9O(a)j2rym4(FlOT4OaRMgW9hRMMcwck2rQ0cyomtNPQnI7wHxqDDuugiKojuqVLD9rJI5UpAumds)0XDaTP9b2hnkM9u2WrYrQ0cyomdlTkCdPL40JIffFb5KJuPfWCygw4Uv4kfuHsrS1iHc6TAiH9uGJPG27SoKoKXwgAJAnKWEkWXuq7DwhshYyldspf4Wb26xNCKkTaMdZWc3TcxkyuGvtOGEli6r9b(tm8GM7d8NI0JcbXQjfmkWQHbPNcC4a)1j10ZKtZ7X65csmi9uGdh4Vo5ivAbmhMHfUBfEpxqk0m4OOo1cXpcf0BjfmkWQHH2Oge9O(a)jgEqZ9b(tr6rHGyhPslG5WmSWDRWvYZKWwuYrQ0cyomdlC3k8xqofXnaiqWosLwaZHzyH7wH3ZLTukITgXrQ0cyomdlC3k8VGCoITgXrQ0cyomdlC3kCLcQqPi2AKqb9w6zYP59ykewavo(clXIbPNcC4adIOkI2QG)eo2HLwaZvzU)1j1KktNWWA6K40Jk5zsC40rZ5iK0wf8NIc4Hc8xNutptonVhtHWcOYXxyjwmi9uGdZHJuWFsyc4HIYetakWWUJuPfWCygw4Uv4jQeRO2Q(cRNqb9w9rJI5wxyjcPF6cSpAum7PSHJuPfWCygw4Uv4yPEAOefkO3sbT3zfUH0sC6rXIIVGCIH2WHth8Bjri9uGdhyWpCKkTaMdZWc3TcVIpOWebJtpQHZl2rQ0cyomdlC3kCiHNReW9hliCEdf0BPG27mfclGkhFHLyXqB4WPd(TKiKEkWHdmOnDKkTaMdZWc3TcxHWcOYXxyjwHc6T0ZKtZ7XEb5ue3aGabZG0tbomxc(bhoQupTrxDc7a)wsSxehoDWVLeH0tboCGb)WrQ0cyomdlC3kCTf4PiyfXwJ4ivAbmhMHfUBfoKWZvc4(JfeoVHc6Tuq7DMcHfqLJVWsSyOnC40b)wsespf4Wbg0MosLwaZHzyH7wHRqybu54lSeRqb9w6zYP59yVGCkIBaqGGzq6PahMlb)GdhvQN2ORoHDGFlj2lIdNo43sIq6PahoWGF4ivAbmhMHfUBfU2c8ueSIyRrCKkTaMdZWc3Tc)liNJ655PUKJuPfWCygw4Uv4k1FC6rbc0FXHc6Tuq7DMcHfqLJVWsSyP594WPd(TKiKEkWHd8dhPslG5WmSWDRWtaifvOclosLwaZHzyH7wHRhfyfXwJekO3YU(OrXHrpyH7(OrXmi9tNkID6zYP59yFb5Cuppp1Lyq6PahombTNlLwaZX(cY5OEEEQlX0dw4WrptonVh7liNJ655PUedspf4WCji3)6K9C4yNcAVZuiSaQC8fwIfdTHdhf0ENDegdU)3cAlokWQPbC)XQPPGLGIzOn2RMkHOh1h4pX(KQjxrcsj0l(wW4ateKdNo43sIq6PahoWa6ivAbmhMHfUBfUsbvOueBnsOGElf0EN9cYPiUbabcMH24ivAbmhMHfUBfEb11rXg0mMcf0BPG27mfclGkhFHLyXsZ7XHth8Bjri9uGdh4hosLwaZHzyH7wHlfmkWQjuqVfe9O(a)jgEqZ9b(tr6rHGyoCGOh1h4pXocJb3)BbTfhfy10aU)y10uWsqXosLwaZHzyH7wH3HeHmG7pkWQjuqVfe9O(a)j2rym4(FlOT4OaRMgW9hRMMcwck2rQ0cyomdlC3k8cQRJIYaH0jHc6TSRpAum39rJIzq6NoUd(H9b2hnkM9u2WigXya]] )

end
