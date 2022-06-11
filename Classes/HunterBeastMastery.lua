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
    end, false )


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


    spec:RegisterPack( "Beast Mastery", 20220611, [[Hekili:D31EZTTrs(plQ2kWerk0KqpCCosU1EoxTx8LZ3wRsv3(xIecCOiotcWfpKmtXcF2VEg8AMb98aKu25UuPSTag0tpD3t3)6EEOhg)WV9W9l9Zip8jVrEEJUB84HJVD0n3EZd3NTFh5H735h8z)NG)rK)w4p)p9t(C6w)O01H7OVC)My)LuIKgNNean4pvSyDw2U0F6TV9PWS15pomiE7Btd3MVXplmokiXFvg9NdE7d3)yE4MSFj6HhfyIR9U7H79ZZwhN8W93hU9dpC)6WLljLTJKgiYgfl(3ZJYijfFeEAW6IfE3Df8haLk(yXh)WA)ONiP)uXh)HIfFI8YQ48OLfl(7K04nptkweMwSikoRyHFXITKaO1HbflYwdVYF5Y4OIfb(rV9LWnBG37hbIIHmsbeyFuazztZ2LegNeMTVyXlW4UybLXlw8x(B)Az7)vc0h)h7tcbMUyXs2xZ6NWKIfF4NHNLgVLKfULKo8H73eMMLsfRzjHbFoDDm7N(etDrI8FCdz5d)RpCFa0HeGKq783qIYgMMr8xUF(Q4G80HvnSyHdmmJMVAt4tRZy)0J5Rwj22eYw)qkNnPyXTG0pGQRaTAzBOmWdzG6rz)NKhrwfNasNDX5bRNhVAEI)VhNmFvI)tBbwtKDymWQn(7jjPZ3ckZH57A71pds7M(86ZqF2sAwFUSH43OK4dafF8ZWRaP6NzQngJhehVzz8lrGalnocSOJEAUFss8lcsWNcGH5HdflUaNk8poIQvMVYNu(fyph(IbCDnymcJGDHaVMI3TgA6SIfxpQyHBzJZ8bry2qQP38S45ldjmInEKeTupINv2AGnPI5NjZjrKTHKQEI1rLdbyCN4hUCo5zQXkmXb0qFHAQx2vYVJVdEVAbQBR6DzCoOkNN5VJQDV1cthWV1g2)Aoz7JG1OGzkiAMNL4VRRuM3uaSPsiYnPLNQjcLJUtZe4QUkFhJ6M5qbJ6ec1PrezoTN9UL2xVJ2x1nH8LDBItP6gMPphpaT8h5BjVjJu7EVsU3cJeojxPLqLllroRv8t12m3epUjoE5M80mMOXvTDq)Swz0ponLXrRyt2u4e8f)Wnn0HkhgpsVBJkw454nBi7v6yOA8x1kHXTQPKEN15sDMSoT7NfaHlHygFpeqvyIMS4LjwuhEIPi7OsO6tCLzBhvkEyK3J3m9rGemCjcwOJvhTaZp8GktmLCM9MtUADFZ6fbNXT9q1hqL5R3Nitgsqs8M4KLgny94SyZsYj1H4gRoghNpM8KNOJngsdbxGd6Jqq3mZwl(wN0T9KBRyIb5PItA7aW2K8fsqEg8HHuKOnwI(7at2vHGhq6OvTp)b9H(L8mdBeaxG9jKK9ZRMoad3rCtfzKDxcjimLuryQ8QIg5ayMekYsQl8sApHIQmnR6NUKZVqfhwQ(AmssjzZFmocWPLfss8(X53SlqokbyOqYsPGGaqLZZJEe8z9zQQ65WNc3WjPBfD(q3xHf6(G9bmDc1XtkfPjvyQoCftYWyD2ajH8ejInUkHtU1)lCbLj(zRNdcGpN4VLr33zL)tJMBIcaCtydMK2(9FnmD)r9Up5jER5fITxfcIkv0m6GpnJPRk74HT69HLVsoMCW6WT(KeFKqYkq41oOGe9YcBC(OgYW5IXLziWg8MwUryKWsHrDSBghbgRqaW9eMiwrkjEJ5Je5pFBEYsscDQh4S(fzutEcXT4tarQDAY0HScMmSM(gUCZij7aL18u6me8jWEQ993pHS1tlV1ky6c2iE2atpIKMc94l(j7tz4K3X6)D78t8ZYrWeZJ62tTFStOhavc53PTPPBu7wt0TUOP1J(pX8AZY0Nrh1ocO5c8yy0YH7a8W5G(MKKVJP14JzRR3wTbEkRimSU6982M8z7lyBMrDIVYh0AnvHOzcwmR4lOg0wi1tj7wN)7PZ3LehSXFRV4yHf7REihfU3h0mGzi084Wu5gYSrJwMhMbwKpdjk5VHkxH(jd6obbKOJFTSGRQHAt2wxpcRmfTqX8J(N5qce)EDWLYAyLeURSb)1yyM3AqWd)fTYu)wZhaqd(0F7dqWJsxBxvS4f4rlJJEtg9VOvpIw9kyuuSyxzTuaDpjWhWSuSim7nlP)i0SyOTP783UDFvFqPtGpJojqphUzFv)sBh4rEfTgyuRiATOAvBx0KzsiiUy9iwruAKx(GpZYFyoTGwMqJ34HPX0TXZIDvErLNhD0USwBZlRUjmhm6Zu3Nifpq9OIJablt1NMps0QRPt8Gj)0WLw2nPznj4BvVaoM96FVWv7rMlaAW64Tp631jWJXzzatmVm42lmNIXFjmcZHaIJiXwztb)mxteE))YgO0bsn87hUhYMVfQAB9J0lohR1Atv29y2v6Tn4WM1NochR2e5S45saOxwTZyeQXPlc0AfCLlkKTPmZtSOqm7o6KkTf)EawEto6YT3bdFsZisnX6KcVdEk)UDLogZV3fj2DDcGAY7F81Q1eMKbDP27ebZtNBrsOPrQpGooxRXHEvjOnn2UJJvOLbC(Q8K96Ds8vGv8JciGZuaFb1)jMhMxD259CosH8hzch9Ex0bkKTYqPZ)FYxYw3e9odqNDmaTyTLEcyigaeoBYwpCxqwPFO2sMPRMw3DwTTfD(TlM93mxmPz69WyA51gqx)pYZZFky5WXd58G1YNQxUnUe5fAuzs(IvzQZOTTsagY5cBP8QFxB2T2gkwHgXU8eRleUMA578hSfjtNNHBp(QYZwrdu4hADQC6lwKwxfMjhRxFDwDS6xODfRSRaIDDUorBPwTvlI86w3GYVzzEclLswjwKFzyuJ3qmZd6Rb7W7ATdv0V6wTNXQwUhgkwZ23EC4JfwCWmPvouDPTuxfWtRoYJ47Et1HtZYt1dFwoFRx(sdAlTRBPAaC1Xx4kWn3QZPP63MCo2JLS8SpTAS(Pv3O41vlYZu(5hhX8o9t7AvtOlLQb8T9yPufGpOArQoQs)xLoz35eQStUazLS8ORKf9L4RXvZ0ijdto5h3keRoIjMqXSVN6Hw)G189I5T3uatYQv5mpf(rGmEUFqazdiPZIt65Yn1SXDu2i(aWCVNNvVwh6q9lJQvlAgUM2bzLY4tWUQGb8qFBWENq83sR663I1NMnI6JIKFcU4Y8PoZkLlZRI1)Zr9kuxMxHd60E(TAxN1htZAZ(nG98tc8JiTmN6vgzGIQTyHZVZ5QRZnVKwBawLqxtKNF0zZIiUlpo(mR4kEGfTEInBDfZjvXxXc0IK16YIFoE10ELWs)2GzW7wTygorO4J0IjWiAkL7XNETm7Tw(O16K(cfBAfw4T64LTBtMZ5eie4ehdKeXrh2UY4y3Vpy6o0kQJVI8g2(b6QseFSqf1HsDnIuxiiT1v3cViFdIT2t4BYaiBcpXEbX)PneG9IJOR7ForO6BC(ZXaGOmkVNHAL3DJV0y)zZMYqtaCnBJKZBplfBwZEnHB7Ruzf3D7Tc9CT7zotvl2Il2VEAIZuR3aPzA3Fi9AkGJLqJ))utto6za))5DdtZgfazvdI3XGkZLGQpWTps36wp7VjNykfE5iYmcuVW)7JcMNVRPa(9QB79sOGJnqrjg0Y2zjX0PcTCVStQkUpCfo)JrOQzFCdpJZtN8N1uD45pb)Cn5Mt2KYttvnwRrnsn8)AmoptdHC0ZqJTdGJIZbpPVIAijR2MvCGB01cUMn)EC3mmREZWSXdx7NohGloNk2uN4M0huZVCiDRLFdfNMWbew1w)OM0EwYlD)Mw2H5NV9LC6kUcpRC03IzxhpX95TLNQjPm6gLgJdABHlkx0ogmiwCoBCWf2O10XhdmXk)adY)e((HBkvjxO4vZmr73YNLK9C5zxy(hk5GKodB6T(rJW4fT)C7mKfMNbOnefRODtPazMYrTJY3mXePFBZ266ct8OYbrvFHO26gstIzXAWSYfh9CzP0xEwMznQAOPbCPonG(H7PBn3LcCl7Ofd)zMyXJuvOA0QNqt6ufmJwmxAIMZ6qtzlE8GBVs6fP)VmDl0J)PcgW1QbG6fg0qaGbsr7QzDJ2tZygbiOCWMGBKAMC75IkiWhsNpyqhFGaxPsD22(W0Hb(bRj00G9d(N5q(00kss8tZtiTwRmW6nV)fFin4QfgnDdDlB3IHfz)YiHZ1tdoxBXwQuIEgX5AlM7UFJcf8yZkytgqVsafq4I2XGbXIXavwZb9dNlUFt9SIPGUwgrudEg8Kg0WLNDH5FOKdFDsttnkbeCUAWqCQ4Cner(ct8OYbXxfCUhTLsF5zL4CvPA(6GZ1qwkMX5QE43xCU2QkmIZfLqNioxC)sgX5IhC7vsV8AGZfzaybox8aawHZfZE64X5AP1Pf4CnxoUtdg0XhiqfoxVZnoxVhQoUy0J(lfCl3Lj3l(jrHrpbn()(V83)0V8P)6pvSOyXVrVK3c3UlojR6u0(MSMJ84BOhn2YoT8QzRyHFEw8w)m6dckVv5gw8XFnmcE1yGGFioc6A2RFt1cM9paQKfZ9Z1lmf88bJ)IBZ37j99TlJydj4EKkQC9XsfFqa8V9F9RsK72JLCcu5UJLk4m17prj94rNkbU5CtaRLiIK58OEg)UtD4ita75dpEY8JNiF4D0YdCdnVZSHRN8aSz1RBix7t6oil(ObxxvxqdVPx(Top(DEDOs9L5qdnAEGTu4mlHBo)79tgFM9kFeUFSZ9UfesRJD7)EJs60EkIp1WVhThz7KSwtorhRN6OAS88HEtaztxBiG3PgRulb63uAfrk7nxCMuOYK5OgmNACYoe4ihmNmqmzcCC8H3PINZ7yMM5PJahJATdAJEZfhnCf98XrnyELH6uLXxpZrtAKvE)CdjxNr3bKFxjF9R5(flwg(Cykl)14DL7PsG1ElKf7GB1f(RkZ2XC6S20N)hm91nw89EiFVx13Fh33)UZ7WPtAawmC0WownCUPsD)lmTl9ZUREBhxSGDfOdVMED9eVkKU9Y(t)PIf4387vVPZT)o95T3a80F6mElWxrUEDtWx9n952GNookfkPdBGGE503Q6sxcV1T70v83xFo8VkC10w)eYN)F8VTDpdFf)vR00XJOutCBypB8HdxivHoNlQ8UvEYGW7K29HExIo5ANbgi6HdsFINlE)WTTFr4EVdhgi1rhoi0rUoIFYupofiqF(Brovp)QQlxUPxpssFGCx1D4GMRipg7Q8sXZ5c9KgerG9Q13qD)lFtUH64fIDVT9OYVlKV16eK7sxbAxr3aRtRdXq)CzdRMcDkVLtD4QIk(gCfX2xj1kDw8ZeGJbrOFaqSIf7JZtOI28hbjdyWeUH9SIfR9P(X2LNv6vRSZbVo0EN(bVebUfP6HWvvo2ARfmvhXubBIPFd1z9sSU9NPD7WIf)YkQ3sQx)4sILYix0YqMqfuHjuhNpUHusSTuVDuFH0drhRVPlFukH(jqR3qiV4V)QQxLgUL1V0saZ1TnH2dPkS9vUsBvJrvo1NNu6tNQ4ANxi9sNbSQkJSV3pCWOoC24rhoiSYktgFNRztQGLPMBe83LxtFthJ5MZmbARGTgcnJ3N0qGXM2ErFrB9a5DcUJk5LJK5Sl4Wb)JLovOoDpUPU8(wRoaVu9H8HK11rUhoCGEOjDKukx31xT6XH43(URDfKp0WTn3)yujuxoq584zxpcN)UtUleVxXE16MMlmSZup8E5oq66eRB3WC7i9rLxhxySu1Sv(lsfAm3eXRvSjEJCrzpV7ob7akkHwonnBQe8GQq)8hitNb4xfyL9j2b8CYTaJ35LuHKRkpv0x2nyIlpRcY0M71lPNZbyJoBxw4mWOpWjWOZfdix3z18ZGRFgxpGDKYPuNZoeRjGTiU2E8TGm7c8Jm(HdDpZ2YIm21vvPMT5o2YXgaXP2JI2r(MZIoGBbciCJzrFLuNiELdj9sEHvLYvX05sPS8KnDsVoVGo3u1HS)YUNGEykAxvqy0S7O6seAR4O0pB87LrZpBSI5(J6QERVJQKNtWF7srLCSzHx2EOjN0EGjf)Yox8uYQe(7HPsaLwm9c0dvoxe13vQmEVHiZeTahdQa7wjEx(JBrhiCH8amqfZ2(y8PNEVQgyJXnWUb5XS8TMoUFwEygEssSYSaBIJHIXSJFZsrA3RPHw5QW58gjz2wZfEnWfy3cpqcJixydv2vcQv5XMuWp5rH6zmodSlMY3ttK3Id5mM9MRBtM4TpS1RA3RbPjxlp(ApbZm7Cop48hMBe5hivRbLYFVgv(mU70ixNgad1hLAlI2YY4O7mCmfUfYo5bTGLflTjeRJUJokh7GFHzm5whe758DY(nBVab(A2T1b7yQ4ojCOzQikdYxafTxXjngNDUxGCXsYH7zwJkJbq3yRaNKUhbOSs0)izYrN3XBNdM9D8r(A6Z372ZdOIrwdQqoijxPjfUIkkt9wP9uNeLpCO79Ud1R4LnLu9unc5ctykGsl)152Zzg)nNdW0OZgNnsUsOZgRpCIM8JCWYZsDMr6DRBCgYz2FR24IYbDz(3ypuZ9stJVK2Wig9QJ6ASs5nJEZUCz53353)pADAFMOQWf9c2KiURqgNUBB4znB5urYwDhVGuamztXJWeXrj8GVHMowyziCdRyQ2mPIRDKqvvLV1vCmsi(lgDUYQ0wZsBkVsZVkJ1vqfmIZxqeXe0v97p4YEq63tXkinxML2rCf0XqTzmAzwMw)36kZ0Dokl3mJCpDEL0u1R7tbD4suttXXee4V21Sr2kbCXuV8EE3EmvAsGGQkgKqJ41tQAYFmlsbluS(6uimmqRxrtVi(BK3QzksltmMLR2IwyFTcMIwdIV3tLL5XukbfKQksOQPaCPeHxAIJEPYWt1alpcUgwLlgEErgqKlAoiewxraBBYSYweHUDZyTMetfUVjX5x9zsOgq(uBrKRo7wKupAs74s0sfFYjJOkc4XujwnQDRuV9cnN62EUniA(nLjhqnXIHuPxKXG7yecULPco7Av6j7sXWcgrSdNCJnG3kb)s4(L1QQPuQRoVk8BkArFssXg1PzbJfwU3EQaDm879uvsl(F5NEoiyVYkrsXD6zNiQNvMLcBlbnT(KzwTJnkpOOxXUu60eOw27zxctJ4lsAHBCHQEW6vYUR76ojfCI8uLn4vX7MYUsaVQzpajZLn8UjmL)zLlxz5953vT39Ftn1uZgrFlgIN0iWov0RdJp7mQBqhf0JVCygzB6vSt2B9EWRe6ZGSMnKm)rDUBzYfBxnFaiFuCrMGUZrB28Y67lPgw3zqsenpNtSYg)TVtCGqJgROxB)G2fZQQExZMI0t1V0vUVQBHQbOZj0txOw8QOZgOP3(HBNGE(3pCa9XZ0qQVZZLxFOIfolYHVQJPwbR8ucnCyl7Jqw3w(x(s)Zrdn)HBNHocCqF6enu678OqOvXc4mhJOcY2UUVD09YzEJos9ML8dpJOtmoE0L4smDC)rz9i)rSQZOB0mtR01APhg7R5BNiKLVwL4L6MYkqgolmzpWNhjj7)qRJek9DvZqD3MiQ8Jn4cz2qN(C2TUQgS0DOLLgc8JbxH5TAJR1VGK92fMRRdVJr9xYiaxZWxjF9I42h8jEI4tmHzaxACC4tmHfsQHDf9DV4xuhR88hUrUVQBHQbOoVNM6jlWNi7oqtVDSXYrJ51bNgglCwKdFvhtVcaArJ0iIpbne0rHprH)(luYc4m35fFsV0BwYpy4tWeJVk4tuGcud(eSrJL4tmj90Hpb5Bpg8jytzvHpr2d85rsEc4t8SfFISFmD4t6QpTeFIbdbv4tuM39XeKS3UWeWNy6sqtj(KhUNEkiP)2p6g2LE2d)Vp]] )

end
