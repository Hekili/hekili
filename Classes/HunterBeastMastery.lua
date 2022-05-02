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
                local app = state.buff.aspect_of_the_wild.applied
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
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

                return app + floor( ( t - app ) / 2 ) * 2
            end,

            interval = 2,
            value = 5,
        },

        death_chakram = {
            resource = "focus",
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
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
        survival_tactics = 3599, -- 202746
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
            max_stack = 1,
            copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
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


    local ExpireNesingwarysTrappingApparatus = setfenv( function()
        focus.regen = focus.regen * 0.5
        forecastResources( "focus" )
    end, state )


    spec:RegisterHook( "reset_precast", function()
        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
        end

        if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
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

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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


    -- Tier 28
    spec:RegisterGear( "tier28", 188861, 188860, 188859, 188858, 188856 )
    spec:RegisterSetBonuses( "tier28_2pc", 364492, "tier28_4pc", 363665 )
    -- 2-Set - Killing Frenzy - Your Kill Command critical strike chance is increased by 15% for each stack of Frenzy your pet has.
    -- 4-Set - Killing Frenzy - Kill Command critical hits increase the damage and cooldown reduction of your next Cobra Shot by 40%.
    spec:RegisterAura( "killing_frenzy", {
        id = 363760,
        duration = 8,
        max_stack = 1
    } )


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
                else
                    setCooldown( "kill_command", cooldown.kill_command.remains - ( buff.killing_frenzy.up and 1.4 or 1 ) )
                    removeBuff( "killing_frenzy" )
                end
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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                return true
            end,

            disabled = function()
                if settings.check_pet_range and Hekili:PetBasedTargetDetectionIsReady( true ) and not Hekili:TargetIsNearPet( "target" ) then return true, "not in-range of pet" end
            end,

            handler = function ()
                removeBuff( "flamewakers_cobra_sting" )

                if conduit.ferocious_appetite.enabled and stat.crit >= 100 then
                    reduceCooldown( "aspect_of_the_wild", conduit.ferocious_appetite.mod / 10 )
                end

                if set_bonus.tier28_4pc > 0 and stat.crit + ( buff.frenzy.stack * 0.15 ) >= 100 then
                    applyBuff( "killing_frenzy" )
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
                if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                    applyDebuff( "target", "pouch_of_razor_fragments" )
                    removeBuff( "flayers_mark" )
                end
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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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

            toggle = "interrupts",

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
                if legendary.pact_of_the_soulstalkers.enabled then applyBuff( "pact_of_the_soulstalkers" ) end
            end,

            toggle = "essences",

            auras = {
                resonating_arrow = {
                    id = 308498,
                    duration = 10,
                    max_stack = 1,
                },
                pact_of_the_soulstalkers = {
                    id = 356263,
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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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
                },
                pouch_of_razor_fragments = {
                    id = 356620,
                    duration = 6,
                    max_stack = 1,
                }
            }
        },


        -- Wailing Arrow (Sylvanas Legendary)
        wailing_arrow = {
            id = 355589,
            cast = 1.9,
            cooldown = 60,
            gcd = "spell",

            spend = 15,
            spendType = "focus",

            toggle = "cooldowns",

            startsCombat = true,

            handler = function ()
                interrupt()
                applyDebuff( "target", "wailing_arrow" )
            end,

            auras = {
                wailing_arrow = {
                    id = 355589,
                    duration = 5,
                    max_stack = 1,
                }
            }
        },
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

    spec:RegisterSetting( "check_pet_range", true, {
        name = "Check Pet Range for |T132176:0|t Kill Command",
        desc = function ()
            return "If checked, the addon will not recommend |T132176:0|t Kill Command if your pet is not in range of your target.\n\n" ..
                "Requires |c" .. ( state.settings.petbased and "FF00FF00" or "FFFF0000" ) .. "Pet-Based Target Detection"
        end,
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Beast Mastery", 20220315, [[d8eb)bqiQepsuL4sQsu2evQpbvzuqLofuXQevP6vujnliIBPkHDb8likdtufhJkSmrLNrqLPbrIRPkLTbrsFtuvPXjQsQZbrvTois9ocQQQ5rf19KO2hvK)rqvLdcrvyHqv5HquzIquf5IIQu(ibvXijOQkNKGQ0kjiZuuvUjevj7uvs)uuvXqHOk1sjOQ8ujmvvP6RIQKmwckNvvIQ9QQ(lvnyqhMYIj0JfzYeDzuBgjFgsgns1PLA1quf1RjWSL0Tvf7w43QmCKYXvLilxXZrmDsxhkBhs9DimEOQ68sK1lQQA(IY(v6VJ)7)cPP8)1C5jxU8iCoEd4iVop538Gu)fAjA8VGMLeyO4Fryp8VaFSr0fI8YikpL(f0Ss1ZK)3)fKdBs8VGUQ0iinYqgQwPJjcs3dYi9dw10(I0yukYi9tcz)crSUQcVXx8xinL)VMlp5YLhHZXBah515j)MNC)cdtPFZVOOFqUFb9wk54l(lKmj9lWhBeDHiVmIYtPfk8hwO8ScH8YMe9f64nKSWC5jxUvOviKJUfOycsVc9Ifk8XVGdtSYleF2iYYfwq)0fk8mwIxiYBE6tcwHEXcZRSU2bQfwq)0fIrtAkta)IAtuY)9FHKPmSQ(F))QJ)7)clP9f)I0HfkpEc9t)fCyIvw(X3x)VM7)(VGdtSYYp((fws7l(f6yXlH11o)7aLNq)0FHKjPPPP9f)cHNBHgD2Kl0c5cFFS4LW6AN)8cFf5nYTqo4NMjizHi4fkVapDHYBHk9MSqQBwiTQvIhYcf5KHr4f2kEYfkYluVBHeA2ZtPfAHCHi4fMSapDHdBYUwAHVpw8slKqJtnvNwOigffb8lstR802VWLfQ2GIvqt80QwjE(6)vH7)(VGdtSYYp((fPPvEA7xKo0CyHceuAAlwO7fMURkpebWi04K6pkVsN9i6Qem8J1bzHUxy6UQ8qeGHjxyAhO82mhcWWpwhKfMLTqxwy6qZHfkqqPPTyHUxy6UQ8qeaJqJtQ)O8kD2JORsWWpwhKFbrNoP)xD8lSK2x8lswT6TK2x4Rnr)f1MO(WE4FHoDiGvYx)VIu(V)l4WeRS8JVFHL0(IFrYQvVL0(cFTj6VO2e1h2d)lssYx)V(2)9FbhMyLLF89lstR802VWsAJM9CWpntwOZlm3VGOtN0)Ro(fws7l(fjRw9ws7l81MO)IAtuFyp8VGOF9)ks9)(VGdtSYYp((fPPvEA7xyjTrZEo4NMjl0Pf64xq0Pt6)vh)clP9f)IKvRElP9f(At0FrTjQpSh(xKQSHM)6x)f0goDpIM(F))QJ)7)clP9f)cc2ZZfEAS(l4WeRS8JVV(Fn3)9FHL0(IFH4PALLEQQvILi6aLxp83XVGdtSYYp((6)vH7)(VWsAFXVGQYe6PXO0FbhMyLLF891)RiL)7)comXkl)47xqB4KruV2p8VWb4TFHL0(IFHAJxhJ2VinTYtB)IblyQBqXaYHvPUbf75hrEiaomXklxyw2chSGPUbfdcMq6afcBkr86y0O1bkVrJMnMIraCyIvw(1)RV9F)xWHjwz5hF)cAdNmI61(H)foaV9lSK2x8lezI2w1JymL(VinTYtB)cxwOAvouajXH6pkVy9ojGdtSYYf6EHUSWblyQBqXaYHvPUbf75hrEiaomXkl)6x)f60Hawj)3)V64)(VGdtSYYp((fhTFbH1FHL0(IFbABAtSY)c0wfJ)fIyuuGHjxyAhO82mhcagTfMLTqrmkkGrOXj1FuELo7r0vjaJ2VaTn(WE4FbPuK8y0(6)1C)3)fCyIvw(X3V4O9liS(lSK2x8lqBtBIv(xG2Qy8ViDO5WcfiO00wSq3lueJIcmm5ct7aL3M5qaWOTq3lueJIcyeACs9hLxPZEeDvcWOTWSSf6YcthAoSqbcknTfl09cfXOOagHgNu)r5v6ShrxLamA)c024d7H)feDUaLNuksEmAF9)QW9F)xWHjwz5hF)IJ2VGWAt9lSK2x8lqBtBIv(xG2gFyp8VGOZfO8KsrYp8J1b5xKMw5PTFHigffWi04K6pkVsN9i6QeipeXVaTvXypxj8ViDxvEicGrOXj1FuELo7r0vjy4hRdIhfgti)c0wfJ)fP7QYdragMCHPDGYBZCiad)yDqwOZc)wy6UQ8qeaJqJtQ)O8kD2JORsWWpwhepkmMq(6)vKY)9FbhMyLLF89loA)ccRn1VWsAFXVaTnTjw5FbAB8H9W)cIoxGYtkfj)WpwhKFrAALN2(fIyuuaJqJtQ)O8kD2JORsagTFbARIXEUs4Fr6UQ8qeaJqJtQ)O8kD2JORsWWpwhepkmMq(fOTkg)ls3vLhIamm5ct7aL3M5qag(X6G81)RV9F)xWHjwz5hF)IJ2VGWAt9lSK2x8lqBtBIv(xG2gFyp8VGuks(HFSoi)I00kpT9lshAoSqbcknTf)c0wfJ9CLW)I0Dv5HiagHgNu)r5v6ShrxLGHFSoiEuymH8lqBvm(xKURkpebyyYfM2bkVnZHam8J1bzHoj8BHP7QYdramcnoP(JYR0zpIUkbd)yDq8OWyc5R)xrQ)3)fCyIvw(X3VWsAFXVqNoeWQJFrAALN2(f4UqCxOoDiGvG6aq3iEmc7fXOOwyw2cthAoSqbcknTfl09c1PdbScuha6gXNURkpeXcXzHUxiUleTnTjwzarNlq5jLIKhJ2cDVqCxOllmDO5WcfiO00wSq3l0LfQthcyfO5a0nIhJWErmkQfMLTW0HMdluGGstBXcDVqxwOoDiGvGMdq3i(0Dv5Hiwyw2c1PdbSc0CG0Dv5Hiad)yDqwyw2c1PdbScuha6gXJryVigf1cDVqCxOlluNoeWkqZbOBepgH9IyuulmlBH60HawbQdq6UQ8qeaj2yAFXcDQ8c1PdbSc0CG0Dv5HiasSX0(IfIZcZYwOoDiGvG6aq3i(0Dv5HiwO7f6Yc1PdbSc0Ca6gXJryVigf1cDVqD6qaRa1biDxvEicGeBmTVyHovEH60HawbAoq6UQ8qeaj2yAFXcXzHzzl0LfI2M2eRmGOZfO8KsrYJrBHUxiUl0LfQthcyfO5a0nIhJWErmkQf6EH4UqD6qaRa1biDxvEicGeBmTVyHVyHVTqNxiABAtSYasPi5h(X6GSWSSfI2M2eRmGuks(HFSoil0PfQthcyfOoaP7QYdraKyJP9flezlm3cXzHzzluNoeWkqZbOBepgH9Iyuul09cXDH60HawbQdaDJ4XiSxeJIAHUxOoDiGvG6aKURkpebqInM2xSqNkVqD6qaRanhiDxvEicGeBmTVyHUxiUluNoeWkqDas3vLhIaiXgt7lw4lw4Bl05fI2M2eRmGuks(HFSoilmlBHOTPnXkdiLIKF4hRdYcDAH60HawbQdq6UQ8qeaj2yAFXcr2cZTqCwyw2cXDHUSqD6qaRa1bGUr8ye2lIrrTWSSfQthcyfO5aP7QYdraKyJP9fl0PYluNoeWkqDas3vLhIaiXgt7lwiol09cXDH60HawbAoq6UQ8qeGHnzPf6EH60HawbAoq6UQ8qeaj2yAFXcFXcFBHoTq020MyLbKsrYp8J1bzHUxiABAtSYasPi5h(X6GSqNxOoDiGvGMdKURkpebqInM2xSqKTWClmlBHUSqD6qaRanhiDxvEicWWMS0cDVqCxOoDiGvGMdKURkpeby4hRdYcFXcFBHoVq020MyLbeDUaLNuks(HFSoil09crBtBIvgq05cuEsPi5h(X6GSqNwyU8Sq3le3fQthcyfOoaP7QYdraKyJP9fl8fl8Tf68crBtBIvgqkfj)WpwhKfMLTqD6qaRanhiDxvEicWWpwhKf(If(2cDEHOTPnXkdiLIKF4hRdYcDVqD6qaRanhiDxvEicGeBmTVyHVyHoYZcDDHOTPnXkdiLIKF4hRdYcDEHOTPnXkdi6CbkpPuK8d)yDqwyw2crBtBIvgqkfj)WpwhKf60c1PdbScuhG0Dv5HiasSX0(IfISfMBHzzleTnTjwzaPuK8y0wiolmlBH60HawbAoq6UQ8qeGHFSoil8fl8Tf60crBtBIvgq05cuEsPi5h(X6GSq3le3fQthcyfOoaP7QYdraKyJP9fl8fl8Tf68crBtBIvgq05cuEsPi5h(X6GSWSSfQthcyfOoaP7QYdraKyJP9fl05fs1OOR(HFSoil09crBtBIvgq05cuEsPi5h(X6GSqxxOoDiGvG6aKURkpebqInM2xSqNwivJIU6h(X6GSWSSf6Yc1PdbScuha6gXJryVigf1cDVqCxiABAtSYasPi5h(X6GSqNwOoDiGvG6aKURkpebqInM2xSqKTWClmlBHOTPnXkdiLIKhJ2cXzH4SqCwioleNfIZcZYwOAdkwbA)WE98YMxOZleTnTjwzaPuK8d)yDqwiolmlBHUSqD6qaRa1bGUr8ye2lIrrTq3l0LfMo0CyHceuAAlwO7fI7c1PdbSc0Ca6gXJryVigf1cDVqCxiUl0LfI2M2eRmGuksEmAlmlBH60HawbAoq6UQ8qeGHFSoil0Pf(2cXzHUxiUleTnTjwzaPuK8d)yDqwOtlmxEwyw2c1PdbSc0CG0Dv5Hiad)yDqw4lw4Bl0PfI2M2eRmGuks(HFSoileNfIZcZYwOlluNoeWkqZbOBepgH9Iyuul09cXDHUSqD6qaRanhGUr8P7QYdrSWSSfQthcyfO5aP7QYdrag(X6GSWSSfQthcyfO5aP7QYdraKyJP9fl0PYluNoeWkqDas3vLhIaiXgt7lwioleNfIZcDVqCxOlluNoeWkqDaAcizj6S)O8w6LW6HLEDyJGnmzHzzl0sAJM9CWpntwOZlm3cDVqrmkkGLEjSEyPhHfsagTfMLTqlPnA2Zb)0mzHoTqhl09cDzHIyuual9sy9WspclKamAleNFbPEk5xOthcy1Xx)VMF)V)l4WeRS8JVFHL0(IFHoDiG1C)I00kpT9lWDH4UqD6qaRanhGUr8ye2lIrrTWSSfMo0CyHceuAAlwO7fQthcyfO5a0nIpDxvEiIfIZcDVqCxiABAtSYaIoxGYtkfjpgTf6EH4Uqxwy6qZHfkqqPPTyHUxOlluNoeWkqDaOBepgH9IyuulmlBHPdnhwOabLM2If6EHUSqD6qaRa1bGUr8P7QYdrSWSSfQthcyfOoaP7QYdrag(X6GSWSSfQthcyfO5a0nIhJWErmkQf6EH4UqxwOoDiGvG6aq3iEmc7fXOOwyw2c1PdbSc0CG0Dv5HiasSX0(If6u5fQthcyfOoaP7QYdraKyJP9fleNfMLTqD6qaRanhGUr8P7QYdrSq3l0LfQthcyfOoa0nIhJWErmkQf6EH60HawbAoq6UQ8qeaj2yAFXcDQ8c1PdbScuhG0Dv5HiasSX0(IfIZcZYwOlleTnTjwzarNlq5jLIKhJ2cDVqCxOlluNoeWkqDaOBepgH9Iyuul09cXDH60HawbAoq6UQ8qeaj2yAFXcFXcFBHoVq020MyLbKsrYp8J1bzHzzleTnTjwzaPuK8d)yDqwOtluNoeWkqZbs3vLhIaiXgt7lwiYwyUfIZcZYwOoDiGvG6aq3iEmc7fXOOwO7fI7c1PdbSc0Ca6gXJryVigf1cDVqD6qaRanhiDxvEicGeBmTVyHovEH60HawbQdq6UQ8qeaj2yAFXcDVqCxOoDiGvGMdKURkpebqInM2xSWxSW3wOZleTnTjwzaPuK8d)yDqwyw2crBtBIvgqkfj)WpwhKf60c1PdbSc0CG0Dv5HiasSX0(IfISfMBH4SWSSfI7cDzH60HawbAoaDJ4XiSxeJIAHzzluNoeWkqDas3vLhIaiXgt7lwOtLxOoDiGvGMdKURkpebqInM2xSqCwO7fI7c1PdbScuhG0Dv5HiadBYsl09c1PdbScuhG0Dv5HiasSX0(If(If(2cDAHOTPnXkdiLIKF4hRdYcDVq020MyLbKsrYp8J1bzHoVqD6qaRa1biDxvEicGeBmTVyHiBH5wyw2cDzH60HawbQdq6UQ8qeGHnzPf6EH4UqD6qaRa1biDxvEicWWpwhKf(If(2cDEHOTPnXkdi6CbkpPuK8d)yDqwO7fI2M2eRmGOZfO8KsrYp8J1bzHoTWC5zHUxiUluNoeWkqZbs3vLhIaiXgt7lw4lw4Bl05fI2M2eRmGuks(HFSoilmlBH60HawbQdq6UQ8qeGHFSoil8fl8Tf68crBtBIvgqkfj)WpwhKf6EH60HawbQdq6UQ8qeaj2yAFXcFXcDKNf66crBtBIvgqkfj)WpwhKf68crBtBIvgq05cuEsPi5h(X6GSWSSfI2M2eRmGuks(HFSoil0PfQthcyfO5aP7QYdraKyJP9flezlm3cZYwiABAtSYasPi5XOTqCwyw2c1PdbScuhG0Dv5Hiad)yDqw4lw4Bl0PfI2M2eRmGOZfO8KsrYp8J1bzHUxiUluNoeWkqZbs3vLhIaiXgt7lw4lw4Bl05fI2M2eRmGOZfO8KsrYp8J1bzHzzluNoeWkqZbs3vLhIaiXgt7lwOZlKQrrx9d)yDqwO7fI2M2eRmGOZfO8KsrYp8J1bzHUUqD6qaRanhiDxvEicGeBmTVyHoTqQgfD1p8J1bzHzzl0LfQthcyfO5a0nIhJWErmkQf6EH4Uq020MyLbKsrYp8J1bzHoTqD6qaRanhiDxvEicGeBmTVyHiBH5wyw2crBtBIvgqkfjpgTfIZcXzH4SqCwioleNfMLTq1guSc0(H965LnVqNxiABAtSYasPi5h(X6GSqCwyw2cDzH60HawbAoaDJ4XiSxeJIAHUxOllmDO5WcfiO00wSq3le3fQthcyfOoa0nIhJWErmkQf6EH4UqCxOlleTnTjwzaPuK8y0wyw2c1PdbScuhG0Dv5Hiad)yDqwOtl8TfIZcDVqCxiABAtSYasPi5h(X6GSqNwyU8SWSSfQthcyfOoaP7QYdrag(X6GSWxSW3wOtleTnTjwzaPuK8d)yDqwioleNfMLTqxwOoDiGvG6aq3iEmc7fXOOwO7fI7cDzH60HawbQdaDJ4t3vLhIyHzzluNoeWkqDas3vLhIam8J1bzHzzluNoeWkqDas3vLhIaiXgt7lwOtLxOoDiGvGMdKURkpebqInM2xSqCwioleNf6EH4UqxwOoDiGvGMd0eqYs0z)r5T0lH1dl96WgbByYcZYwOL0gn75GFAMSqNxyUf6EHIyuual9sy9WspclKamAlmlBHwsB0SNd(PzYcDAHowO7f6YcfXOOaw6LW6HLEewiby0wio)cs9uYVqNoeWAUV(1Frss(V)F1X)9FbhMyLLF89lstR802ViDxvEicGit02QEeJP0bd)yDqwOtlu4YZVWsAFXVWIet0XQ(KvRF9)AU)7)comXkl)47xKMw5PTFr6UQ8qearMOTv9igtPdg(X6GSqNwOWLNFHL0(IFbvpSy9o5x)VkC)3)fCyIvw(X3VinTYtB)cCxOigffarxLEcTEALaWOTWSSf6YcthAoSqbrJIU6PmEHUxOigffWi04K6pkVsN9i6QeGrBHUxOigffqKjABvpIXu6amAleNf6EH4UqQgfD1p8J1bzHoTW0Dv5HiaI8q4rqhOasSX0(If66cLyJP9flmlBH4Uq1guScOZwvPdOL0f68cfU3wyw2cDzHQv5qbc6ALhFheTJKc4WeRSCH4SqCwyw2cfpczHUxivJIU6h(X6GSqNxOdH7xyjTV4xiYdHhbDG6R)xrk)3)fCyIvw(X3VinTYtB)cCxOigffarxLEcTEALaWOTWSSf6YcthAoSqbrJIU6PmEHUxOigffWi04K6pkVsN9i6QeGrBHUxOigffqKjABvpIXu6amAleNf6EH4UqQgfD1p8J1bzHoTW0Dv5HiaI17KEkSPeqInM2xSqxxOeBmTVyHzzle3fQ2GIvaD2QkDaTKUqNxOW92cZYwOlluTkhkqqxR847GODKuahMyLLleNfIZcZYwO4ril09cPAu0v)WpwhKf68cDGu)fws7l(fI17KEkSP0x)V(2)9FHL0(IFrTrrxjEKNXKOE4q)fCyIvw(X3x)VIu)V)l4WeRS8JVFrAALN2(fIyuuaJqJtQ)O8kD2JORsagTfMLTqXJqwO7fs1OOR(HFSoil05fMdP(lSK2x8lODAFXx)6VGO)3)V64)(VGdtSYYp((fPPvEA7x4YchRLEgnhkWKscGXFtuYcZYwOllCSw6z0COatkjamAl09cXDHJ1spJMdfysjbiXgt7lwORlCSw6z0COatkjGowOZlmxEwyw2cXDHJ1spJMdfysjbKoSqxy5f6yHUxy6qZHfkqqPPTyH4SqCwyw2chRLEgnhkWKscaJ2cDVWXAPNrZHcmPKag(X6GSqNwOdK)VWsAFXVWi04K6pkVsN9i6Q8R)xZ9F)xWHjwz5hF)I00kpT9leXOOaudh5FjagTf6EHIyuuaQHJ8Vey4hRdYcDU8crLKl01fkAJil9e6N6rnwI904Pp5cZYwOigffarxLEcTEALaWOTq3lmr3gumXtnws7lS6cDAHoaiLf6EHdwWu3GIbuJH6HdL4pkVsN9CvYJ3cTYdbWHjwz5VWsAFXVq0grw6j0p9R)xfU)7)comXkl)47xKMw5PTFXGfm1nOya5WQu3GI98JipeahMyLLl09cvB86y0ad)yDqwOZlevsUq3lmDxvEicav1ggm8J1bzHoVquj5VWsAFXVqTXRJr7R)xrk)3)fCyIvw(X3VWsAFXVGQAd)lstR802VqTXRJrdGrBHUx4Gfm1nOya5WQu3GI98JipeahMyLL)IAhSpj)f5E7R)xF7)(VWsAFXVqSENKqNL)comXkl)47R)xrQ)3)fCyIvw(X3VinTYtB)cxw4yT0ZO5qbMusam(BIswyw2cDzHJ1spJMdfysjbGrBHUx4yT0ZO5qbMusasSX0(If66chRLEgnhkWKscOJf68cZLNfMLTWXAPNrZHcmPKaWOTq3lCSw6z0COatkjGHFSoil0Pf6a5)lSK2x8lq0vPNqRNwjF9)A(9)(VWsAFXVGQALyPNq)0FbhMyLLF891)R51)3)fws7l(fc6A1tOF6VGdtSYYp((6)vK))9FbhMyLLF89lstR802VqeJIcqnCK)Lad)yDqwOtlKXpNWu2R9dVq3le3fMURkpebyyYfM2bkVnZHam8J1bzHoVquj5cDVqCxOlluTkhkGXpT6rA0SNq)uahMyLLlmlBHIyuuaX6DYkgrby0wiolmlBHUSW0HMdluGGstBXcXzHzzluTbfRaTFyVEEzZl05f(2VWsAFXVaH11oq5TzoeF9)QJ88F)xWHjwz5hF)I00kpT9ls3vLhIaiYeTTQhXykDWWpwhKf68cDKBH59fMOBdkM4PglP9fwDHUUquj5cDVq1QCOasId1FuEX6DsahMyLLlmlBHuy1QF4eDBqXETF4f68crLKl09ct3vLhIaiYeTTQhXykDWWpwhKfMLTq1guSc0(H965LnVqNxiY)xyjTV4xiAJil9e6N(1)RoC8F)xWHjwz5hF)I00kpT9lOUegzHUUWKru)WO4yHoVqQlHrapg()fws7l(fs2u6(eDtWypF9)QJC)3)fCyIvw(X3VinTYtB)crmkkGrOXj1FuELo7r0vjaJ2cZYwOAdkwbA)WE98YMxOZl0XB)clP9f)cIAp0yj)1)RoeU)7)clP9f)cZ)GnsE8hLpnhcYVGdtSYYp((6)vhiL)7)comXkl)47xKMw5PTFbUlueJIciYeTTQhXykDagTfMLTq1guSc0(H965LnVqNxOJ8SqCwO7fI7cDzHJ1spJMdfysjbW4VjkzHzzl0Lfowl9mAouGjLeagTf6EH4UWXAPNrZHcmPKaKyJP9fl01fowl9mAouGjLeqhl05fMlplmlBHJ1spJMdfysjbKoSqxy5f6yH4SWSSfowl9mAouGjLeagTf6EHJ1spJMdfysjbm8J1bzHoTqhi)fIZVWsAFXVyyYfM2bkVnZH4R)xD82)9FbhMyLLF89lstR802Va3fMURkpebarxLEcTEALag(X6GSqNwOJ3wyw2cthAoSqbcknTfl09cXDHP7QYdragMCHPDGYBZCiad)yDqwOZl8TfMLTW0Dv5HiadtUW0oq5TzoeGHFSoil0PfMlpleNfMLTq1guSc0(H965LnVqNxOJ3wyw2cXDHUSW0HMdluq0OOREkJxO7f6YcthAoSqbcknTfleNfIZcDVqCxOllCSw6z0COatkjag)nrjlmlBHUSWXAPNrZHcmPKaWOTq3le3fowl9mAouGjLeGeBmTVyHUUWXAPNrZHcmPKa6yHoVWC5zHzzlCSw6z0COatkjG0Hf6clVqhleNfMLTWXAPNrZHcmPKaWOTq3lCSw6z0COatkjGHFSoil0Pf6a5VqC(fws7l(fImrBR6rmMs)R)xDGu)V)lSK2x8ls07hJhZtOF6VGdtSYYp((6)vh53)7)clP9f)cbDT6t3ZJfYFbhMyLLF891)RoYR)V)l4WeRS8JVFrAALN2(fIyuuarMOTv9igtPdKhIyHzzlu8iKf6EHunk6QF4hRdYcDEHV9lSK2x8lenu(JYRtNeq(6)vhi))7)clP9f)czpSxKnI(l4WeRS8JVV(FnxE(V)l4WeRS8JVFrAALN2(f4UqQlHrw4lwy6i6cDDHuxcJaggfhlmVVqCxy6UQ8qeabDT6t3ZJfsWWpwhKf(If6yH4SqNwOL0(cGGUw9P75XcjiDeDHzzlmDxvEicGGUw9P75Xcjy4hRdYcDAHowORlevsUqCwyw2cXDHIyuuarMOTv9igtPdWOTWSSfkIrrbcMq6afcBkr86y0O1bkVrJMnMIray0wiol09cDzHdwWu3GIbVKrRAEEyjw4ryJ)gjpaomXklxyw2cfpczHUxivJIU6h(X6GSqNxOW9lSK2x8lsN4yEc9t)6)1Co(V)l4WeRS8JVFrAALN2(fIyuuaeDv6j06PvcaJ2cZYwyIUnOyINASK2xy1f60cDaYTq3lmDHeRvGy9ozLvTduaomXkl)fws7l(fI2iYspH(PF9)AUC)3)fCyIvw(X3VinTYtB)crmkkGit02QEeJP0bYdrSWSSfkEeYcDVqQgfD1p8J1bzHoVW3(fws7l(f2KSG90WQe(R)xZjC)3)fCyIvw(X3VinTYtB)IblyQBqXaYHvPUbf75hrEiaomXklxyw2chSGPUbfdcMq6afcBkr86y0O1bkVrJMnMIraCyIvw(lSK2x8luB86y0(6)1CiL)7)comXkl)47xKMw5PTFXGfm1nOyqWeshOqytjIxhJgToq5nA0SXumcGdtSYYFHL0(IFb1WC(3bkVogTV(Fn3B)3)fCyIvw(X3VinTYtB)cCxi1LWil01fsDjmcyyuCSqxxOJ3wiol05fsDjmc4XW)VWsAFXVWMKfSxVz4q)6x)fPkBO5)7)xD8F)xWHjwz5hF)I00kpT9lCzHJ1spJMdfysjbW4VjkzHzzlCSw6z0COatkjGHFSoil0PYl0rEwyw2cTK2Ozph8tZKf6u5fowl9mAouGjLeq6WcDH59fM7xyjTV4xyeACs9hLxPZEeDv(1)R5(V)l4WeRS8JVFHL0(IFHOnIS0tOF6VinTYtB)crmkka1Wr(xcGrBHUxOigffGA4i)lbg(X6GSqNlVquj5cDDHI2iYspH(PEuJLypnE6tUWSSfkIrrbq0vPNqRNwjamAl09ct0Tbft8uJL0(cRUqNwOdaszHUx4Gfm1nOya1yOE4qj(JYR0zpxL84TqR8qaCyIvw(lsLsv2R2GIvY)vhF9)QW9F)xWHjwz5hF)I00kpT9lqLKl8flueJIciYgr9PkBOzWWpwhKf60cZdi3B)clP9f)IhSQ2e6N(1)RiL)7)comXkl)47xKMw5PTFXGfm1nOyaTdlr3Fu(XY)B8uJH6HdLa4WeRSCHUxOigffGQAL4H4FSraaJ2VWsAFXVqqxREc9t)6)13(V)l4WeRS8JVFrAALN2(fdwWu3GIb0oSeD)r5hl)VXtngQhoucGdtSYYFHL0(IFbv1kXspH(PF9)ks9)(VGdtSYYp((fPPvEA7xmybtDdkgqoSk1nOyp)iYdbWHjwz5cDVq1gVognWWpwhKf68crLKl09ct3vLhIaqvTHbd)yDqwOZlevs(lSK2x8luB86y0(6)187)9FbhMyLLF89lstR802VqTXRJrdGrBHUx4Gfm1nOya5WQu3GI98JipeahMyLL)clP9f)cQQn8x)VMx)F)xWHjwz5hF)I00kpT9lOUegzHUUWKru)WO4yHoVqQlHrapg()fws7l(fs2u6(eDtWypF9)kY))(VGdtSYYp((fPPvEA7x4YchRLEgnhkWKscGXFtuYcZYw4yT0ZO5qbMusad)yDqwOtLxOJ8SWSSfAjTrZEo4NMjl0PYlCSw6z0COatkjG0Hf6cZ7lm3VWsAFXVarxLEcTEAL81)RoYZ)9FbhMyLLF89lSK2x8leTrKLEc9t)fPPvEA7xqHvR(Ht0Tbf71(HxOZlevsUq3lmDxvEicGit02QEeJP0bd)yDqwyw2ct3vLhIaiYeTTQhXykDWWpwhKf68cDKBHUUquj5cDVq1QCOasId1FuEX6DsahMyLL)IuPuL9QnOyL8F1Xx)V6WX)9FbhMyLLF89lstR802VWLfowl9mAouGjLeaJ)MOKfMLTWXAPNrZHcmPKag(X6GSqNkVW3wyw2cTK2Ozph8tZKf6u5fowl9mAouGjLeq6WcDH59fM7xyjTV4xiYeTTQhXyk9V(F1rU)7)comXkl)47xKMw5PTFHllCSw6z0COatkjag)nrjlmlBHJ1spJMdfysjbm8J1bzHovEHVTWSSfAjTrZEo4NMjl0PYlCSw6z0COatkjG0Hf6cZ7lm3VWsAFXVyyYfM2bkVnZH4R)xDiC)3)fCyIvw(X3VinTYtB)crmkkGrOXj1FuELo7r0vjaJ2cZYwO4ril09cPAu0v)WpwhKf68cD82VWsAFXVGO2dnwYF9)QdKY)9FbhMyLLF89lstR802VqeJIcqnCK)Lad)yDqwOtlKXpNWu2R9d)lSK2x8lqyDTduEBMdXx)V64T)7)clP9f)cQQvILEc9t)fCyIvw(X3x)V6aP(F)xyjTV4xiORvpH(P)comXkl)47R)xDKF)V)lSK2x8ls07hJhZtOF6VGdtSYYp((6)vh51)3)fws7l(fI17Ke6S8xWHjwz5hFF9)QdK))9FHL0(IFH5FWgjp(JYNMdb5xWHjwz5hFF9)AU88F)xWHjwz5hF)I00kpT9leXOOaudh5FjWWpwhKf60cz8ZjmL9A)W)clP9f)crBgdf)1)R5C8F)xWHjwz5hF)I00kpT9lOUegzHoTW0r0f66cTK2xaEWQAtOFkiDe9xyjTV4xiORvF6EESq(1)R5Y9F)xWHjwz5hF)I00kpT9leXOOaImrBR6rmMshipeXcZYwO4ril09cPAu0v)WpwhKf68cF7xyjTV4xiAO8hLxNojG81)R5eU)7)clP9f)czpSxKnI(l4WeRS8JVV(Fnhs5)(VGdtSYYp((fws7l(fI2iYspH(P)I00kpT9luBqXkq7h2RNx28cDEHi)fMLTWeDBqXep1yjTVWQl0Pf6aKBHUxy6cjwRaX6DYkRAhOaCyIvw(lsLsv2R2GIvY)vhF9)AU3(V)l4WeRS8JVFrAALN2(fuxcJa0(H965Fm8VqNxiQKCH59fM7xyjTV4xKoXX8e6N(1)R5qQ)3)fCyIvw(X3VinTYtB)IblyQBqXaYHvPUbf75hrEiaomXklxyw2chSGPUbfdcMq6afcBkr86y0O1bkVrJMnMIraCyIvw(lSK2x8luB86y0(6)1C53)7)comXkl)47xKMw5PTFXGfm1nOyqWeshOqytjIxhJgToq5nA0SXumcGdtSYYFHL0(IFb1WC(3bkVogTV(FnxE9)9FbhMyLLF89lstR802Va3fsDjmYcDDHuxcJaggfhl01fkC5zH4SqNxi1LWiGhd))clP9f)cBswWE9MHd9RF9R)c08q6l(VMlp5YLhHlpV9lqyt0bkYViVc5HW3RcVVk8G0lCHVtNxy)q7gDHu3Sq8OnC6EenfVfo8lH1dlxi5E4fAy69yklxyIUfOycyfkFDWlePG0le5UanpklxiEdwWu3GIbcdVfQ3cXBWcM6gumqyaomXklXBHMUW8w(jFlexh4hhWku(6GxisbPxiYDbAEuwUq8gSGPUbfdegEluVfI3Gfm1nOyGWaCyIvwI3cX1b(XbScLVo4f(gsVqK7c08OSCH4PwLdfim8wOElep1QCOaHb4WeRSeVfIRd8JdyfkFDWl8nKEHi3fO5rz5cXBWcM6gumqy4Tq9wiEdwWu3GIbcdWHjwzjEl00fM3Yp5BH46a)4awHwHYRqEi89QW7Rcpi9cx4705f2p0Urxi1nlepD6qaRe8w4WVewpSCHK7HxOHP3JPSCHj6wGIjGvO81bVqKksVqK7c08OSCHf9dYTqsPqn8VWx2c1BH5dZwOSr3K(IfE04X0BwiUidNfI7B4hhWku(6GxisfPxiYDbAEuwUq80PdbScCaegEluVfINoDiGvG6aim8wiU5qk4hhWku(6GxisfPxiYDbAEuwUq80PdbScYbegEluVfINoDiGvGMdim8wiU5qQ4hhWku(6Gxy(fPxiYDbAEuwUWI(b5wiPuOg(x4lBH6TW8Hzlu2OBsFXcpA8y6nlexKHZcX9n8JdyfkFDWlm)I0le5UanpklxiE60HawboacdVfQ3cXtNoeWkqDaegEle3Civ8JdyfkFDWlm)I0le5UanpklxiE60Hawb5acdVfQ3cXtNoeWkqZbegEle3Cif8JdyfAfkVc5HW3RcVVk8G0lCHVtNxy)q7gDHu3Sq8sscElC4xcRhwUqY9Wl0W07XuwUWeDlqXeWku(6GxOWH0le5UanpklxiEQv5qbcdVfQ3cXtTkhkqyaomXklXBH46a)4awHYxh8crki9crUlqZJYYfINAvouGWWBH6Tq8uRYHcegGdtSYs8wiUoWpoGvOvO8kKhcFVk8(QWdsVWf(oDEH9dTB0fsDZcXJO4TWHFjSEy5cj3dVqdtVhtz5ct0TaftaRq5RdEH5q6fICxGMhLLleVblyQBqXaHH3c1BH4nybtDdkgimahMyLL4TqtxyEl)KVfIRd8JdyfkFDWlmhsVqK7c08OSCH4rJvGWaVCaaG3c1BH49YbaaEle3C4hhWku(6GxOWH0le5UanpklxiEdwWu3GIbcdVfQ3cXBWcM6gumqyaomXklXBH46a)4awHYxh8crki9crUlqZJYYfI3Gfm1nOyGWWBH6Tq8gSGPUbfdegGdtSYs8wOPlmVLFY3cX1b(XbScLVo4fI8r6fICxGMhLLlep1QCOaHH3c1BH4PwLdfimahMyLL4TqCDGFCaRq5RdEHiFKEHi3fO5rz5cXJgRaHbE5aaaVfQ3cX7Ldaa8wiUoWpoGvO81bVqh5bPxiYDbAEuwUq8uRYHcegEluVfINAvouGWaCyIvwI3cX1b(XbScLVo4fMlpi9crUlqZJYYfI3Gfm1nOyGWWBH6Tq8gSGPUbfdegGdtSYs8wiUoWpoGvO81bVWCoq6fICxGMhLLleV0fsSwbcdVfQ3cXlDHeRvGWaCyIvwI3cnDH5T8t(wiUoWpoGvO81bVWCchsVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfA6cZB5N8TqCDGFCaRq5RdEH5eoKEHi3fO5rz5cXBWcM6gumqy4Tq9wiEdwWu3GIbcdWHjwzjElexh4hhWku(6GxyoKcsVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfA6cZB5N8TqCDGFCaRqRq5vipe(Ev49vHhKEHl8D68c7hA3OlK6MfIxQYgAgVfo8lH1dlxi5E4fAy69yklxyIUfOycyfkFDWlmhsVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfA6cZB5N8TqCDGFCaRq5RdEH5q6fICxGMhLLlepASceg4Ldaa8wOEleVxoaaWBH4Md)4awHYxh8cfoKEHi3fO5rz5cXJgRaHbE5aaaVfQ3cX7Ldaa8wiUoWpoGvO81bVqKcsVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfIRd8JdyfkFDWl8nKEHi3fO5rz5cXBWcM6gumqy4Tq9wiEdwWu3GIbcdWHjwzjEl00fM3Yp5BH46a)4awHYxh8crQi9crUlqZJYYfI3Gfm1nOyGWWBH6Tq8gSGPUbfdegGdtSYs8wiUoWpoGvO81bVW8lsVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfA6cZB5N8TqCDGFCaRq5RdEHoYdsVqK7c08OSCH4PwLdfim8wOElep1QCOaHb4WeRSeVfA6cZB5N8TqCDGFCaRq5RdEHoqki9crUlqZJYYfIhnwbcd8YbaaEluVfI3lhaa4TqCDGFCaRq5RdEH5YdsVqK7c08OSCH4rJvGWaVCaaG3c1BH49YbaaElexh4hhWku(6GxyoKcsVqK7c08OSCH4LUqI1kqy4Tq9wiEPlKyTcegGdtSYs8wOPlmVLFY3cX1b(XbScLVo4fMdPI0le5UanpklxiEdwWu3GIbcdVfQ3cXBWcM6gumqyaomXklXBHMUW8w(jFlexh4hhWku(6GxyoKksVqK7c08OSCH4nybtDdkgim8wOEleVblyQBqXaHb4WeRSeVfIRd8JdyfkFDWlmx(fPxiYDbAEuwUq8gSGPUbfdegEluVfI3Gfm1nOyGWaCyIvwI3cnDH5T8t(wiUoWpoGvOviH3hA3OSCHi1fAjTVyH1MOeWk0VGqJt)xZ9MW9lOnhvx5FrEjVSq8XgrxiYlJO8uAHc)HfkpRq5L8YcrEztI(cD8gswyU8Kl3k0kuEjVSqKJUfOycsVcLxYll8flu4JFbhMyLxi(SrKLlSG(Plu4zSeVqK380NeScLxYll8flmVY6AhOwyb9txignPPmbScTczjTVGaOnC6EenTmb755cpnwxHSK2xqa0goDpIM6AzKjEQwzPNQALyjIoq51d)DSczjTVGaOnC6Een11YiJQYe6PXO0vilP9feaTHt3JOPUwgzQnEDmAiH2WjJOETF4YoaVHKMQ8Gfm1nOya5WQu3GI98JipKSSblyQBqXGGjKoqHWMseVognADGYB0OzJPyKvilP9feaTHt3JOPUwgzImrBR6rmMshj0goze1R9dx2b4nK0uLDrTkhkGK4q9hLxSEN0TldwWu3GIbKdRsDdk2ZpI8qwHwHSK2xqCTmYshwO84j0pDfkVSqHNBHgD2Kl0c5cFFS4LW6AN)8cFf5nYTqo4NMjc)Vqe8cLxGNUq5TqLEtwi1nlKw1kXdzHICYWi8cBfp5cf5fQ3Tqcn75P0cTqUqe8ctwGNUWHnzxlTW3hlEPfsOXPMQtlueJIIawHSK2xqCTmY0XIxcRRD(3bkpH(PiPPk7IAdkwbnXtRAL4zfkVKxwiYtC1kTqkl1bQfw6WMfkpmrDHyH21fw6WwiDdnVqAy6cf(yYfM2bQfI8yMdXcLhIajl8Mf2uluPZlmDxvEiIf2KfQ3TW6fOwOEluYvR0cPSuhOwyPdBwiYthMOcwOWl1cJl4fEuluPZeEHPlKT2xqwOn8cnXkVq9w4dRlerR07yHkDEHoYZcjC6cjzHvMryLqYcv68cj9ZcPSetwyPdBwiYthMOUqdtVht7KvRLaRq5L8YcTK2xqCTmYcgb1Hfs)WKRIMrstvMCyvXoKGGrqDyH0pm5QOz34kIrrbgMCHPDGYBZCiay0YYs3vLhIamm5ct7aL3M5qag(X6G4KJ8KLP2GIvG2pSxpVSzNDGuXzfYsAFbX1Yilz1Q3sAFHV2efjH9WL1PdbSsqcrNoPLDGKMQC6qZHfkqqPPTWD6UQ8qeaJqJtQ)O8kD2JORsWWpwhe3P7QYdragMCHPDGYBZCiad)yDqYYCjDO5WcfiO00w4oDxvEicGrOXj1FuELo7r0vjy4hRdYkKL0(cIRLrwYQvVL0(cFTjksc7HlNKKvilP9fexlJSKvRElP9f(AtuKe2dxMOiHOtN0Yoqstv2sAJM9CWpntCo3kKL0(cIRLrwYQvVL0(cFTjksc7HlNQSHMrcrNoPLDGKMQSL0gn75GFAM4KJvOvilP9feqsskBrIj6yvFYQvK0uLt3vLhIaiYeTTQhXykDWWpwheNeU8SczjTVGassIRLrgvpSy9ojsAQYP7QYdraezI2w1JymLoy4hRdItcxEwHSK2xqajjX1YitKhcpc6afsAQY4kIrrbq0vPNqRNwjamAzzUKo0CyHcIgfD1tzSBrmkkGrOXj1FuELo7r0vjaJMBrmkkGit02QEeJP0by0WXnUunk6QF4hRdItP7QYdrae5HWJGoqbKyJP9fUkXgt7lYYWvTbfRa6Svv6aAj1zH7TSmxuRYHce01kp(oiAhjfhCYYepcXnvJIU6h(X6G4SdHBfYsAFbbKKexlJmX6Dspf2ucjnvzCfXOOai6Q0tO1tReagTSmxshAoSqbrJIU6Pm2TigffWi04K6pkVsN9i6QeGrZTigffqKjABvpIXu6amA44gxQgfD1p8J1bXP0Dv5HiaI17KEkSPeqInM2x4QeBmTVildx1guScOZwvPdOLuNfU3YYCrTkhkqqxR847GODKuCWjlt8ie3unk6QF4hRdIZoqQRqws7liGKK4AzKvBu0vIh5zmjQho0vilP9feqssCTmYODAFbsAQYIyuuaJqJtQ)O8kD2JORsagTSmXJqCt1OOR(HFSoioNdPUcTczjTVGasv2qZLncnoP(JYR0zpIUkrstv2LXAPNrZHcmPKay83eLKLnwl9mAouGjLeWWpwheNk7ipzzwsB0SNd(PzItLhRLEgnhkWKsciDyHM3ZTczjTVGasv2qZUwgzI2iYspH(PijvkvzVAdkwjLDGKMQmnwbpwharmkka1Wr(xcGrZnnwbpwharmkka1Wr(xcm8J1bX5YOssxfTrKLEc9t9OglXEA80NmlteJIcGORspHwpTsay0CNOBdkM4PglP9fw1jhaKI7blyQBqXaQXq9WHs8hLxPZEUk5XBHw5HSczjTVGasv2qZUwgzpyvTj0pfjnvzuj5lOXk4X6aiIrrbezJO(uLn0my4hRdIt5bK7TvilP9feqQYgA21YitqxREc9trstvEWcM6gumG2HLO7pk)y5)nEQXq9WHsClIrrbOQwjEi(hBeaWOTczjTVGasv2qZUwgzuvRel9e6NIKMQ8Gfm1nOyaTdlr3Fu(XY)B8uJH6HdLSczjTVGasv2qZUwgzQnEDmAiPPkpybtDdkgqoSk1nOyp)iYdXTAJxhJgy4hRdIZOss3P7QYdraOQ2WGHFSoioJkjxHSK2xqaPkBOzxlJmQQnmsAQYQnEDmAamAUhSGPUbfdihwL6guSNFe5HSczjTVGasv2qZUwgzs2u6(eDtWypiPPktDjmIRjJO(HrXHZuxcJaEm8VczjTVGasv2qZUwgzi6Q0tO1tReK0uLDzSw6z0COatkjag)nrjzzJ1spJMdfysjbm8J1bXPYoYtwML0gn75GFAM4u5XAPNrZHcmPKashwO59CRqws7liGuLn0SRLrMOnIS0tOFkssLsv2R2GIvszhiPPktHvR(Ht0Tbf71(HDgvs6oDxvEicGit02QEeJP0bd)yDqYYs3vLhIaiYeTTQhXykDWWpwheNDKZvujPB1QCOasId1FuEX6DYvilP9feqQYgA21YitKjABvpIXu6iPPk7YyT0ZO5qbMusam(BIsYYgRLEgnhkWKscy4hRdItLFllZsAJM9CWpntCQ8yT0ZO5qbMusaPdl08EUvilP9feqQYgA21YiByYfM2bkVnZHajnvzxgRLEgnhkWKscGXFtusw2yT0ZO5qbMusad)yDqCQ8BzzwsB0SNd(PzItLhRLEgnhkWKsciDyHM3ZTczjTVGasv2qZUwgze1EOXsgjnvzrmkkGrOXj1FuELo7r0vjaJwwM4riUPAu0v)WpwheND82kKL0(ccivzdn7AzKHW6AhO82mhcK0uLPXk4X6aiIrrbOgoY)sGHFSoioX4Ntyk71(HxHSK2xqaPkBOzxlJmQQvILEc9txHSK2xqaPkBOzxlJmbDT6j0pDfYsAFbbKQSHMDTmYs07hJhZtOF6kKL0(ccivzdn7AzKjwVtsOZYvilP9feqQYgA21YiZ8pyJKh)r5tZHGSczjTVGasv2qZUwgzI2mgkgjnvzAScESoaIyuuaQHJ8Vey4hRdItm(5eMYETF4vilP9feqQYgA21YitqxR(098yHejnvzQlHrCkDe1vlP9fGhSQ2e6NcshrxHSK2xqaPkBOzxlJmrdL)O860jbeK0uLfXOOaImrBR6rmMshiperwM4riUPAu0v)WpwheNFBfYsAFbbKQSHMDTmYK9WEr2i6kKL0(ccivzdn7AzKjAJil9e6NIKuPuL9QnOyLu2bsAQYQnOyfO9d71ZlB2zKFwwIUnOyINASK2xyvNCaY5oDHeRvGy9ozLvTduRqws7liGuLn0SRLrw6ehZtOFksAQYuxcJa0(H965Fm87mQKmVNBfYsAFbbKQSHMDTmYuB86y0qstvEWcM6gumGCyvQBqXE(rKhsw2Gfm1nOyqWeshOqytjIxhJgToq5nA0SXumYkKL0(ccivzdn7AzKrnmN)DGYRJrdjnv5blyQBqXGGjKoqHWMseVognADGYB0OzJPyKvilP9feqQYgA21YiZMKfSxVz4qrstvgxQlHrCL6syeWWO4WvHlp44m1LWiGhd)RqRqws7liaIw2i04K6pkVsN9i6QejnvzxgRLEgnhkWKscGXFtuswMlJ1spJMdfysjbGrZnUJ1spJMdfysjbiXgt7lCDSw6z0COatkjGoCoxEYYWDSw6z0COatkjG0HfAzhUthAoSqbcknTf4Gtw2yT0ZO5qbMusay0Cpwl9mAouGjLeWWpwheNCG8xHSK2xqae11Yit0grw6j0pfjnvzAScESoaIyuuaQHJ8VeaJMBAScESoaIyuuaQHJ8Vey4hRdIZLrLKUkAJil9e6N6rnwI904PpzwMigffarxLEcTEALaWO5or3gumXtnws7lSQtoaif3dwWu3GIbuJH6HdL4pkVsN9CvYJ3cTYdzfYsAFbbquxlJm1gVognK0uLhSGPUbfdihwL6guSNFe5H4wTXRJrdm8J1bXzujP70Dv5HiauvByWWpwheNrLKRqws7liaI6AzKrvTHrsTd2NKLZ9gsAQYQnEDmAamAUhSGPUbfdihwL6guSNFe5HSczjTVGaiQRLrMy9ojHolxHSK2xqae11YidrxLEcTEALGKMQSlJ1spJMdfysjbW4VjkjlZLXAPNrZHcmPKaWO5ESw6z0COatkjaj2yAFHRJ1spJMdfysjb0HZ5Ytw2yT0ZO5qbMusay0Cpwl9mAouGjLeWWpwheNCG8xHSK2xqae11YiJQALyPNq)0vilP9fearDTmYe01QNq)0vilP9fearDTmYqyDTduEBMdbsAQY0yf8yDaeXOOaudh5FjWWpwheNy8ZjmL9A)WUXnDxvEicWWKlmTduEBMdby4hRdIZOss346IAvouaJFA1J0OzpH(PzzIyuuaX6DYkgrby0WjlZL0HMdluGGstBbozzQnOyfO9d71ZlB253wHSK2xqae11Yit0grw6j0pfjnv50Dv5HiaImrBR6rmMshm8J1bXzh5Y7j62GIjEQXsAFHvDfvs6wTkhkGK4q9hLxSENmlJcRw9dNOBdk2R9d7mQK0D6UQ8qearMOTv9igtPdg(X6GKLP2GIvG2pSxpVSzNr(Rqws7liaI6AzKjztP7t0nbJ9GKMQm1LWiUMmI6hgfhotDjmc4XW)kKL0(ccGOUwgze1EOXsgjnvzrmkkGrOXj1FuELo7r0vjaJwwMAdkwbA)WE98YMD2XBRqws7liaI6AzKz(hSrYJ)O8P5qqwHSK2xqae11YiByYfM2bkVnZHajnvzCfXOOaImrBR6rmMshGrlltTbfRaTFyVEEzZo7ip44gxxgRLEgnhkWKscGXFtuswMlJ1spJMdfysjbGrZnUJ1spJMdfysjbiXgt7lCDSw6z0COatkjGoCoxEYYgRLEgnhkWKsciDyHw2bozzJ1spJMdfysjbGrZ9yT0ZO5qbMusad)yDqCYbYhNvilP9fearDTmYezI2w1JymLosAQY4MURkpebarxLEcTEALag(X6G4KJ3YYshAoSqbcknTfUXnDxvEicWWKlmTduEBMdby4hRdIZVLLLURkpebyyYfM2bkVnZHam8J1bXPC5bNSm1guSc0(H965Ln7SJ3YYW1L0HMdluq0OOREkJD7s6qZHfkqqPPTahCCJRlJ1spJMdfysjbW4VjkjlZLXAPNrZHcmPKaWO5g3XAPNrZHcmPKaKyJP9fUowl9mAouGjLeqhoNlpzzJ1spJMdfysjbKoSql7aNSSXAPNrZHcmPKaWO5ESw6z0COatkjGHFSoio5a5JZkKL0(ccGOUwgzj69JXJ5j0pDfYsAFbbquxlJmbDT6t3ZJfYvilP9fearDTmYenu(JYRtNeqqstvweJIciYeTTQhXykDG8qezzIhH4MQrrx9d)yDqC(TvilP9fearDTmYK9WEr2i6kKL0(ccGOUwgzPtCmpH(PiPPkJl1LWiViDe1vQlHradJIJ8oUP7QYdrae01QpDppwibd)yDqEHdCCYsAFbqqxR(098yHeKoIMLLURkpebqqxR(098yHem8J1bXjhUIkjXjldxrmkkGit02QEeJP0by0YYeXOOabtiDGcHnLiEDmA06aL3OrZgtXiamA442LblyQBqXGxYOvnppSel8iSXFJKNSmXJqCt1OOR(HFSoiolCRqws7liaI6AzKjAJil9e6NIKMQSigffarxLEcTEALaWOLLLOBdkM4PglP9fw1jhGCUtxiXAfiwVtwzv7a1kKL0(ccGOUwgz2KSG90WQegjnvzrmkkGit02QEeJP0bYdrKLjEeIBQgfD1p8J1bX53wHSK2xqae11YitTXRJrdjnv5blyQBqXaYHvPUbf75hrEizzdwWu3GIbbtiDGcHnLiEDmA06aL3OrZgtXiRqws7liaI6AzKrnmN)DGYRJrdjnv5blyQBqXGGjKoqHWMseVognADGYB0OzJPyKvilP9fearDTmYSjzb71BgouK0uLXL6syexPUegbmmkoC1XB44m1LWiGhd)RqRqws7liaD6qaRKYOTPnXkJKWE4YKsrYJrdjOTkgxweJIcmm5ct7aL3M5qaWOLLjIrrbmcnoP(JYR0zpIUkby0wHSK2xqa60HawjUwgzOTPnXkJKWE4YeDUaLNuksEmAibTvX4YPdnhwOabLM2c3IyuuGHjxyAhO82mhcagn3IyuuaJqJtQ)O8kD2JORsagTSmxshAoSqbcknTfUfXOOagHgNu)r5v6ShrxLamARqws7liaD6qaRexlJm020MyLrsypCzIoxGYtkfj)WpwheKC0ktyTPqs6czR9fLthAoSqbcknTfibTvX4YP7QYdragMCHPDGYBZCiad)yDqCw4x6UQ8qeaJqJtQ)O8kD2JORsWWpwhepkmMqqcARIXEUs4YP7QYdramcnoP(JYR0zpIUkbd)yDq8OWycbjnvzrmkkGrOXj1FuELo7r0vjqEiIvilP9feGoDiGvIRLrgABAtSYijShUmrNlq5jLIKF4hRdcsoALjS2uijDHS1(IYPdnhwOabLM2cKG2QyC50Dv5HiadtUW0oq5TzoeGHFSoiibTvXypxjC50Dv5HiagHgNu)r5v6ShrxLGHFSoiEuymHGKMQSigffWi04K6pkVsN9i6QeGrBfYsAFbbOthcyL4AzKH2M2eRmsc7Hltkfj)WpwheKC0ktyTPqs6czR9fLthAoSqbcknTfibTvX4YP7QYdragMCHPDGYBZCiad)yDqCs4x6UQ8qeaJqJtQ)O8kD2JORsWWpwhepkmMqqcARIXEUs4YP7QYdramcnoP(JYR0zpIUkbd)yDq8OWyczfYsAFbbOthcyL4AzKHryFR8dbjK6PKY60HawDGKMQmU4Qthcyf4aq3iEmc7fXOOYYshAoSqbcknTfU1PdbScCaOBeF6UQ8qe44gx020MyLbeDUaLNuksEmAUX1L0HMdluGGstBHBx0PdbScYbOBepgH9IyuuzzPdnhwOabLM2c3UOthcyfKdq3i(0Dv5HiYY0PdbScYbs3vLhIam8J1bjltNoeWkWbGUr8ye2lIrr5gxx0PdbScYbOBepgH9Iyuuzz60HawboaP7QYdraKyJP9fovwNoeWkihiDxvEicGeBmTVaNSmD6qaRaha6gXNURkpeHBx0PdbScYbOBepgH9IyuuU1PdbScCas3vLhIaiXgt7lCQSoDiGvqoq6UQ8qeaj2yAFbozzUG2M2eRmGOZfO8KsrYJrZnUUOthcyfKdq3iEmc7fXOOCJRoDiGvGdq6UQ8qeaj2yAFXlEZz020MyLbKsrYp8J1bjldTnTjwzaPuK8d)yDqCsNoeWkWbiDxvEicGeBmTV4LLdNSmD6qaRGCa6gXJryVigfLBC1PdbScCaOBepgH9IyuuU1PdbScCas3vLhIaiXgt7lCQSoDiGvqoq6UQ8qeaj2yAFHBC1PdbScCas3vLhIaiXgt7lEXBoJ2M2eRmGuks(HFSoizzOTPnXkdiLIKF4hRdIt60HawboaP7QYdraKyJP9fVSC4KLHRl60Hawboa0nIhJWErmkQSmD6qaRGCG0Dv5HiasSX0(cNkRthcyf4aKURkpebqInM2xGJBC1PdbScYbs3vLhIamSjl5wNoeWkihiDxvEicGeBmTV4fV5eABAtSYasPi5h(X6G4gTnTjwzaPuK8d)yDqCwNoeWkihiDxvEicGeBmTV4LLllZfD6qaRGCG0Dv5HiadBYsUXvNoeWkihiDxvEicWWpwhKx8MZOTPnXkdi6CbkpPuK8d)yDqCJ2M2eRmGOZfO8KsrYp8J1bXPC5XnU60HawboaP7QYdraKyJP9fV4nNrBtBIvgqkfj)WpwhKSmD6qaRGCG0Dv5Hiad)yDqEXBoJ2M2eRmGuks(HFSoiU1PdbScYbs3vLhIaiXgt7lEHJ84kABAtSYasPi5h(X6G4mABAtSYaIoxGYtkfj)WpwhKSm020MyLbKsrYp8J1bXjD6qaRahG0Dv5HiasSX0(IxwUSm020MyLbKsrYJrdNSmD6qaRGCG0Dv5Hiad)yDqEXBoH2M2eRmGOZfO8KsrYp8J1bXnU60HawboaP7QYdraKyJP9fV4nNrBtBIvgq05cuEsPi5h(X6GKLPthcyf4aKURkpebqInM2x4mvJIU6h(X6G4gTnTjwzarNlq5jLIKF4hRdIR60HawboaP7QYdraKyJP9for1OOR(HFSoizzUOthcyf4aq3iEmc7fXOOCJlABAtSYasPi5h(X6G4KoDiGvGdq6UQ8qeaj2yAFXllxwgABAtSYasPi5XOHdo4Gdo4KLP2GIvG2pSxpVSzNrBtBIvgqkfj)WpwheCYYCrNoeWkWbGUr8ye2lIrr52L0HMdluGGstBHBC1PdbScYbOBepgH9IyuuUXfxxqBtBIvgqkfjpgTSmD6qaRGCG0Dv5Hiad)yDqC6nCCJlABAtSYasPi5h(X6G4uU8KLPthcyfKdKURkpeby4hRdYlEZj020MyLbKsrYp8J1bbhCYYCrNoeWkihGUr8ye2lIrr5gxx0PdbScYbOBeF6UQ8qezz60Hawb5aP7QYdrag(X6GKLPthcyfKdKURkpebqInM2x4uzD6qaRahG0Dv5HiasSX0(cCWbh346IoDiGvGdqtajlrN9hL3sVewpS0RdBeSHjzzwsB0SNd(PzIZ5ClIrrbS0lH1dl9iSqcWOLLzjTrZEo4NMjo5WTlIyuual9sy9WspclKamA4SczjTVGa0PdbSsCTmYWiSVv(HGes9uszD6qaR5qstvgxC1PdbScYbOBepgH9IyuuzzPdnhwOabLM2c360Hawb5a0nIpDxvEicCCJlABAtSYaIoxGYtkfjpgn346s6qZHfkqqPPTWTl60Hawboa0nIhJWErmkQSS0HMdluGGstBHBx0PdbScCaOBeF6UQ8qezz60HawboaP7QYdrag(X6GKLPthcyfKdq3iEmc7fXOOCJRl60Hawboa0nIhJWErmkQSmD6qaRGCG0Dv5HiasSX0(cNkRthcyf4aKURkpebqInM2xGtwMoDiGvqoaDJ4t3vLhIWTl60Hawboa0nIhJWErmkk360Hawb5aP7QYdraKyJP9fovwNoeWkWbiDxvEicGeBmTVaNSmxqBtBIvgq05cuEsPi5XO5gxx0PdbScCaOBepgH9IyuuUXvNoeWkihiDxvEicGeBmTV4fV5mABAtSYasPi5h(X6GKLH2M2eRmGuks(HFSoioPthcyfKdKURkpebqInM2x8YYHtwMoDiGvGdaDJ4XiSxeJIYnU60Hawb5a0nIhJWErmkk360Hawb5aP7QYdraKyJP9fovwNoeWkWbiDxvEicGeBmTVWnU60Hawb5aP7QYdraKyJP9fV4nNrBtBIvgqkfj)WpwhKSm020MyLbKsrYp8J1bXjD6qaRGCG0Dv5HiasSX0(IxwoCYYW1fD6qaRGCa6gXJryVigfvwMoDiGvGdq6UQ8qeaj2yAFHtL1PdbScYbs3vLhIaiXgt7lWXnU60HawboaP7QYdrag2KLCRthcyf4aKURkpebqInM2x8I3CcTnTjwzaPuK8d)yDqCJ2M2eRmGuks(HFSoioRthcyf4aKURkpebqInM2x8YYLL5IoDiGvGdq6UQ8qeGHnzj34Qthcyf4aKURkpeby4hRdYlEZz020MyLbeDUaLNuks(HFSoiUrBtBIvgq05cuEsPi5h(X6G4uU84gxD6qaRGCG0Dv5HiasSX0(Ix8MZOTPnXkdiLIKF4hRdswMoDiGvGdq6UQ8qeGHFSoiV4nNrBtBIvgqkfj)Wpwhe360HawboaP7QYdraKyJP9fVWrECfTnTjwzaPuK8d)yDqCgTnTjwzarNlq5jLIKF4hRdswgABAtSYasPi5h(X6G4KoDiGvqoq6UQ8qeaj2yAFXllxwgABAtSYasPi5XOHtwMoDiGvGdq6UQ8qeGHFSoiV4nNqBtBIvgq05cuEsPi5h(X6G4gxD6qaRGCG0Dv5HiasSX0(Ix8MZOTPnXkdi6CbkpPuK8d)yDqYY0PdbScYbs3vLhIaiXgt7lCMQrrx9d)yDqCJ2M2eRmGOZfO8KsrYp8J1bXvD6qaRGCG0Dv5HiasSX0(cNOAu0v)WpwhKSmx0PdbScYbOBepgH9IyuuUXfTnTjwzaPuK8d)yDqCsNoeWkihiDxvEicGeBmTV4LLlldTnTjwzaPuK8y0WbhCWbhCYYuBqXkq7h2RNx2SZOTPnXkdiLIKF4hRdcozzUOthcyfKdq3iEmc7fXOOC7s6qZHfkqqPPTWnU60Hawboa0nIhJWErmkk34IRlOTPnXkdiLIKhJwwMoDiGvGdq6UQ8qeGHFSoio9goUXfTnTjwzaPuK8d)yDqCkxEYY0PdbScCas3vLhIam8J1b5fV5eABAtSYasPi5h(X6GGdozzUOthcyf4aq3iEmc7fXOOCJRl60Hawboa0nIpDxvEiISmD6qaRahG0Dv5Hiad)yDqYY0PdbScCas3vLhIaiXgt7lCQSoDiGvqoq6UQ8qeaj2yAFbo4GJBCDrNoeWkihOjGKLOZ(JYBPxcRhw61Hnc2WKSmlPnA2Zb)0mX5CUfXOOaw6LW6HLEewiby0YYSK2Ozph8tZeNC42frmkkGLEjSEyPhHfsagnC(6x)Fa]] )

end
