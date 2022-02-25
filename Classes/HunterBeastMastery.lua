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


    spec:RegisterPack( "Beast Mastery", 20220225, [[da1D6bqijIhrqLUKsIytIQ(euYOGIofuyvcQsVsqzwqGBjrQDb8liKHjOYXeWYeKNrqvttjrDnLu2guk8nLePXbLI05GsjRdcY7iOIQ5jqDpjQ9jq(hbvKdcLIyHqOEieutuqvvUOGQYgHsPWhHsrnscQOCsOuQwjbzMsKCtbvv1ovs6NcQIHcLsPLsqfEQeMQsQ(QGQkJLGYzvsO2Rs9xrgmOdtzXe6XcnzIUmQnJKpdPgns1PvSAOuk61ey2s62kXUP63QmCKYXvsilxQNJy6KUouTDi57q04Hs15fvwVscMVOSFv9oWE9DH0uEVAOWfku4cfAnq4c3AyJWTs3fAoA8UGMffyO5DHBl8UaXSr0hg(3ik352f0SC1ZK713fKdVJ8UGUQ0iieIqe6rPJlcI3cIiZcE1058yBukIiZser7cr8PQy7(wCxinL3RgkCHcfUqHwBxy4k9R3ffZccVlOpsj7BXDHKjXDbIzJOpm8VruUZ9qHZWDL7xiSnyXg36Cpm0kJGhgkCHc9c9cHW0nhntqOxOs)qHdU0SBIv(Hi2Arw(Wc6N(qS52I8dX2Y9CsWluPFy4Nn1Xr)Wc6N(qCAstzcyxuhIs2RVlKmLHx1967vdSxFxyrDoFxepCx5orOF6UGDtSYYnI36E1q713fSBIvwUr8Ui2JY9y7IsEOAnAwbdjrRA54ExyrDoFxOT5Ri8PoRW4Ote6NUlKmj2dnDoFxGnFp0OZM8HMlF46T5Ri8PoRa)WvX2IWpKDEzyccEis(HYZXsFO8EOsFipK66hsRA54M8qroA4e(HJIL8HI8d17EiHMTSK7HMlFis(HrZXsFyZMCQ5E46T5ROhsOXXHAIpueNIIa26EvHFV(UGDtSYYnI3fXEuUhBxepuSBUceKRhZFy(hgVRkpKoWi04OMoQKsNtiNQe08Ino5H5Fy8UQ8q6GMjNB64Otw3hsqZl24KhML9WsEy8qXU5kqqUEm)H5Fy8UQ8q6aJqJJA6OskDoHCQsqZl24KDbr7jQ7vdSlSOoNVlIwTMSOoNNQdr3f1HOj3w4DH2JlGvYw3RUY713fSBIvwUr8UWI6C(UiA1AYI6CEQoeDxuhIMCBH3frjzR7vxBV(UGDtSYYnI3fXEuUhBxyrDqXj25LHjpm4hgAxq0EI6E1a7clQZ57IOvRjlQZ5P6q0DrDiAYTfExq0TUxfBSxFxWUjwz5gX7Iypk3JTlSOoO4e78YWKhg0ddSliAprDVAGDHf158Dr0Q1Kf158uDi6UOoen52cVlIv2qXBDR7cAnhVfrt3RVxnWE9DHf158DbbFz58enw3fSBIvwUr8w3RgAV(UWI6C(Uq8uTYYev1YXsKJJoPh2hFxWUjwz5gXBDVQWVxFxyrDoFxqvzc9yBu6UGDtSYYnI36E1vEV(UGDtSYYnI3f0AoAenPZcVlcawBxyrDoFxOwN02OTlI9OCp2UOXDM6A0mGC4vQRrZjErKBcGDtSYYhML9Wg3zQRrZaNjKXrJ06CKK2gnAJJoz0OzTP4ea7MyLLBDV6A713fSBIvwUr8UGwZrJOjDw4DraWA7clQZ57crMOJvtiBtPVlI9OCp2UOKhQwLDfqISRPJkjwVtcy3eRS8H5FyjpSXDM6A0mGC4vQRrZjErKBcGDtSYYTU1DrSYgkEV(E1a713fSBIvwUr8Ui2JY9y7IsEyBJmXOyxbMusam2hIsEyw2dBBKjgf7kWKscO5fBCYddQ8ddeUhML9qlQdkoXoVmm5Hbv(HTnYeJIDfysjbepCxFy49HH2fwuNZ3fgHgh10rLu6Cc5uLBDVAO967c2nXkl3iExyrDoFxiATilte6NUlI9OCp2UqeNIcq1SVc5a40Ey(hkItrbOA2xHCGMxSXjpm4YpeDu(WWEOO1ISmrOFAcDBrorJ75Kpml7HI4uuaKtvMi0MEucaN2dZ)WiDRrZKevBrDo3QpmOhgaSYpm)dBCNPUgndOAd9c7kjDujLoN4QK7K5ALBcGDtSYYDrmxSYj1A0Ss2RgyR7vf(967c2nXkl3iExe7r5ESDb6O8HL(HI4uuar2iAkwzdfdAEXgN8WGEy4aHwBxyrDoFxSGx1Hq)0TUxDL3RVly3eRSCJ4DrShL7X2fnUZuxJMb0o8i90rLABfUor1g6f2vcGDtSYYhM)HI4uuaQQLJBsAXAbaCA7clQZ57cbtTMi0pDR7vxBV(UGDtSYYnI3fXEuUhBx04otDnAgq7WJ0thvQTv46evBOxyxja2nXkl3fwuNZ3fuvlhlte6NU19QyJ967c2nXkl3iExe7r5ESDrJ7m11Oza5WRuxJMt8Ii3ea7MyLLpm)dvRtAB0anVyJtEyWpeDu(W8pmExvEiDav1Ag08Ino5Hb)q0r5UWI6C(UqToPTrBR7vxP713fSBIvwUr8Ui2JY9y7c16K2gnaoThM)HnUZuxJMbKdVsDnAoXlICtaSBIvwUlSOoNVlOQwZBDVk20967c2nXkl3iExe7r5ESDb1fXjpmShgnIMAgn7pm4hsDrCcyXW(UWI6C(UqYMspfPBcABzR7vXw713fSBIvwUr8Ui2JY9y7IsEyBJmXOyxbMusam2hIsEyw2dBBKjgf7kWKscO5fBCYddQ8ddeUhML9qlQdkoXoVmm5Hbv(HTnYeJIDfysjbepCxFy49HH2fwuNZ3fiNQmrOn9OKTUxnq42RVly3eRSCJ4DHf158DHO1ISmrOF6Ui2JY9y7ck8An1CKU1O5Kol8dd(HOJYhM)HX7QYdPdezIownHSnLoO5fBCYdZYEy8UQ8q6arMOJvtiBtPdAEXgN8WGFyGqpmShIokFy(hQwLDfqISRPJkjwVtcy3eRSCxeZfRCsTgnRK9Qb26E1ab2RVly3eRSCJ4DrShL7X2fL8W2gzIrXUcmPKaySpeL8WSSh22itmk2vGjLeqZl24Khgu5hU2dZYEOf1bfNyNxgM8WGk)W2gzIrXUcmPKaIhURpm8(Wq7clQZ57crMOJvtiBtPV19QbcTxFxWUjwz5gX7Iypk3JTlk5HTnYeJIDfysjbWyFik5HzzpSTrMyuSRatkjGMxSXjpmOYpCThML9qlQdkoXoVmm5Hbv(HTnYeJIDfysjbepCxFy49HH2fwuNZ3fnto30XrNSUpKBDVAaHFV(UGDtSYYnI3fXEuUhBxiItrbmcnoQPJkP05eYPkb40Eyw2dfpc5H5Fi1GMUMAEXgN8WGFyG12fwuNZ3fe1wOXsER7vdSY713fSBIvwUr8Ui2JY9y7crCkkavZ(kKd08Ino5Hb9qg7Cex5Kol8UWI6C(UaPn1XrNSUpKBDVAG12RVlSOoNVlOQwowMi0pDxWUjwz5gXBDVAaSXE9DHf158DHGPwte6NUly3eRSCJ4TUxnWkDV(UWI6C(UisFwmUTeH(P7c2nXkl3iER7vdGnDV(UWI6C(UqSENKqNL7c2nXkl3iER7vdGT2RVlSOoNVlS0cEl5oDuPyFij7c2nXkl3iER7vdfU967c2nXkl3iExe7r5ESDHioffGQzFfYbAEXgN8WGEiJDoIRCsNfExyrDoFxiADBO5TUxnuG967c2nXkl3iExe7r5ESDb1fXjpmOhgpI(WWEOf15CWcEvhc9tbXJO7clQZ57cbtTMI3YI5YTUxnuO967c2nXkl3iExe7r5ESDHioffqKj6y1eY2u6a5H0Fyw2dfpc5H5Fi1GMUMAEXgN8WGF4A7clQZ57crdD6OsAprbKTUxnKWVxFxyrDoFxiNMtISr0Db7MyLLBeV19QHw5967c2nXkl3iExyrDoFxiATilte6NUlI9OCp2UqTgnRaDw4KEj5Wpm4hITEyw2dJ0TgntsuTf15CR(WGEyaqOhM)HXZL4JceR3jRSQJJgWUjwz5UiMlw5KAnAwj7vdS19QHwBV(UGDtSYYnI3fXEuUhBxqDrCcqNfoPxAXW(dd(HOJYhgEFyODHf158Dr8eBlrOF6w3RgcBSxFxWUjwz5gX7Iypk3JTlACNPUgndihEL6A0CIxe5May3eRS8HzzpSXDM6A0mWzczC0iTohjPTrJ24OtgnAwBkobWUjwz5UWI6C(UqToPTrBR7vdTs3RVly3eRSCJ4DrShL7X2fnUZuxJMbotiJJgP15ijTnA0ghDYOrZAtXja2nXkl3fwuNZ3funZRW4OtAB026E1qyt3RVly3eRSCJ4DrShL7X2fy(qQlItEyypK6I4eqZOz)HH9qHpCpeJhg8dPUiobSyyFxyrDoFxyD0CoPx3SRBDR7cThxaRK967vdSxFxWUjwz5gX7IJ2UGW6UWI6C(UaL1Jjw5DbkRIZ7crCkkqZKZnDC0jR7djaN2dZYEOioffWi04OMoQKsNtiNQeGtBxGY6KBl8UGKZJjCABDVAO967c2nXkl3iExC02few3fwuNZ3fOSEmXkVlqzvCExepuSBUceKRhZFy(hkItrbAMCUPJJozDFib40Ey(hkItrbmcnoQPJkP05eYPkb40Eyw2dl5HXdf7MRab56X8hM)HI4uuaJqJJA6OskDoHCQsaoTDbkRtUTW7cI2NJorY5XeoTTUxv43RVly3eRSCJ4DXrBxqyDO2fwuNZ3fOSEmXkVlqzDYTfExq0(C0jsopMAEXgNSlI9OCp2UqeNIcyeACuthvsPZjKtvcKhsFxGYQ4CIReExeVRkpKoWi04OMoQKsNtiNQe08InozxGYQ48UiExvEiDqZKZnDC0jR7djO5fBCYddw40dJ3vLhshyeACuthvsPZjKtvcAEXgNS19QR8E9Db7MyLLBeVloA7ccRd1UWI6C(UaL1Jjw5DbkRtUTW7cI2NJorY5XuZl24KDrShL7X2fI4uuaJqJJA6OskDoHCQsaoTDbkRIZjUs4Dr8UQ8q6aJqJJA6OskDoHCQsqZl24KDbkRIZ7I4Dv5H0bnto30XrNSUpKGMxSXjBDV6A713fSBIvwUr8U4OTliSou7clQZ57cuwpMyL3fOSo52cVli58yQ5fBCYUi2JY9y7I4HIDZvGGC9y(UaLvX5exj8UiExvEiDGrOXrnDujLoNqovjO5fBCYUaLvX5Dr8UQ8q6GMjNB64Otw3hsqZl24KhgKWPhgVRkpKoWi04OMoQKsNtiNQe08InozR7vXg713fSBIvwUr8UGupLSl0ECbSgyxyrDoFxO94cynWUi2JY9y7cmFO2JlGvGgaq3ijCcNeXPOEyw2dJhk2nxbcY1J5pm)d1ECbSc0aa6gjfVRkpK(dX4H5FiMpeL1Jjwzar7ZrNi58ycN2dZ)qmFyjpmEOy3CfiixpM)W8pSKhQ94cyfOHa0nscNWjrCkQhML9W4HIDZvGGC9y(dZ)WsEO2JlGvGgcq3iP4Dv5H0Fyw2d1ECbSc0qG4Dv5H0bnVyJtEyw2d1ECbSc0aa6gjHt4Kiof1dZ)qmFyjpu7XfWkqdbOBKeoHtI4uupml7HApUawbAaq8UQ8q6ajEB6C(ddQ8d1ECbSc0qG4Dv5H0bs82058hIXdZYEO2JlGvGgaq3iP4Dv5H0Fy(hwYd1ECbSc0qa6gjHt4Kiof1dZ)qThxaRanaiExvEiDGeVnDo)Hbv(HApUawbAiq8UQ8q6ajEB6C(dX4HzzpSKhIY6XeRmGO95OtKCEmHt7H5FiMpSKhQ94cyfOHa0nscNWjrCkQhM)Hy(qThxaRanaiExvEiDGeVnDo)HL(HR9WGFikRhtSYasopMAEXgN8WSShIY6XeRmGKZJPMxSXjpmOhQ94cyfObaX7QYdPdK4TPZ5perpm0dX4Hzzpu7XfWkqdbOBKeoHtI4uupm)dX8HApUawbAaaDJKWjCseNI6H5FO2JlGvGgaeVRkpKoqI3MoN)WGk)qThxaRaneiExvEiDGeVnDo)H5FiMpu7XfWkqdaI3vLhshiXBtNZFyPF4Apm4hIY6XeRmGKZJPMxSXjpml7HOSEmXkdi58yQ5fBCYdd6HApUawbAaq8UQ8q6ajEB6C(dr0dd9qmEyw2dX8HL8qThxaRanaGUrs4eojItr9WSShQ94cyfOHaX7QYdPdK4TPZ5pmOYpu7XfWkqdaI3vLhshiXBtNZFigpm)dX8HApUawbAiq8UQ8q6GMnzUhM)HApUawbAiq8UQ8q6ajEB6C(dl9dx7Hb9quwpMyLbKCEm18Ino5H5FikRhtSYasopMAEXgN8WGFO2JlGvGgceVRkpKoqI3MoN)qe9Wqpml7HL8qThxaRaneiExvEiDqZMm3dZ)qmFO2JlGvGgceVRkpKoO5fBCYdl9dx7Hb)quwpMyLbeTphDIKZJPMxSXjpm)drz9yIvgq0(C0jsopMAEXgN8WGEyOW9W8peZhQ94cyfObaX7QYdPdK4TPZ5pS0pCThg8drz9yIvgqY5XuZl24KhML9qThxaRaneiExvEiDqZl24Khw6hU2dd(HOSEmXkdi58yQ5fBCYdZ)qThxaRaneiExvEiDGeVnDo)HL(Hbc3dd7HOSEmXkdi58yQ5fBCYdd(HOSEmXkdiAFo6ejNhtnVyJtEyw2drz9yIvgqY5XuZl24Khg0d1ECbSc0aG4Dv5H0bs82058hIOhg6HzzpeL1JjwzajNht40Eigpml7HApUawbAiq8UQ8q6GMxSXjpS0pCThg0drz9yIvgq0(C0jsopMAEXgN8W8peZhQ94cyfObaX7QYdPdK4TPZ5pS0pCThg8drz9yIvgq0(C0jsopMAEXgN8WSShwYd1ECbSc0aa6gjHt4Kiof1dZ)qmFikRhtSYasopMAEXgN8WGEO2JlGvGgaeVRkpKoqI3MoN)qe9Wqpml7HOSEmXkdi58ycN2dX4Hy8qmEigpeJhIXdZYEOAnAwb6SWj9sYHFyWpeL1JjwzajNhtnVyJtEigpml7HL8qThxaRanaGUrs4eojItr9W8pSKhgpuSBUceKRhZFy(hI5d1ECbSc0qa6gjHt4Kiof1dZ)qmFiMpSKhIY6XeRmGKZJjCApml7HApUawbAiq8UQ8q6GMxSXjpmOhU2dX4H5FiMpeL1JjwzajNhtnVyJtEyqpmu4Eyw2d1ECbSc0qG4Dv5H0bnVyJtEyPF4ApmOhIY6XeRmGKZJPMxSXjpeJhIXdZYEyjpu7XfWkqdbOBKeoHtI4uupm)dX8HL8qThxaRaneGUrsX7QYdP)WSShQ94cyfOHaX7QYdPdAEXgN8WSShQ94cyfOHaX7QYdPdK4TPZ5pmOYpu7XfWkqdaI3vLhshiXBtNZFigpeJTUxDLUxFxWUjwz5gX7cs9uYUq7XfWAODHf158DH2JlG1q7Iypk3JTlW8HApUawbAiaDJKWjCseNI6HzzpmEOy3CfiixpM)W8pu7XfWkqdbOBKu8UQ8q6peJhM)Hy(quwpMyLbeTphDIKZJjCApm)dX8HL8W4HIDZvGGC9y(dZ)WsEO2JlGvGgaq3ijCcNeXPOEyw2dJhk2nxbcY1J5pm)dl5HApUawbAaaDJKI3vLhs)Hzzpu7XfWkqdaI3vLhsh08Ino5Hzzpu7XfWkqdbOBKeoHtI4uupm)dX8HL8qThxaRanaGUrs4eojItr9WSShQ94cyfOHaX7QYdPdK4TPZ5pmOYpu7XfWkqdaI3vLhshiXBtNZFigpml7HApUawbAiaDJKI3vLhs)H5Fyjpu7XfWkqdaOBKeoHtI4uupm)d1ECbSc0qG4Dv5H0bs82058hgu5hQ94cyfObaX7QYdPdK4TPZ5peJhML9WsEikRhtSYaI2NJorY5XeoThM)Hy(WsEO2JlGvGgaq3ijCcNeXPOEy(hI5d1ECbSc0qG4Dv5H0bs82058hw6hU2dd(HOSEmXkdi58yQ5fBCYdZYEikRhtSYasopMAEXgN8WGEO2JlGvGgceVRkpKoqI3MoN)qe9WqpeJhML9qThxaRanaGUrs4eojItr9W8peZhQ94cyfOHa0nscNWjrCkQhM)HApUawbAiq8UQ8q6ajEB6C(ddQ8d1ECbSc0aG4Dv5H0bs82058hM)Hy(qThxaRaneiExvEiDGeVnDo)HL(HR9WGFikRhtSYasopMAEXgN8WSShIY6XeRmGKZJPMxSXjpmOhQ94cyfOHaX7QYdPdK4TPZ5perpm0dX4HzzpeZhwYd1ECbSc0qa6gjHt4Kiof1dZYEO2JlGvGgaeVRkpKoqI3MoN)WGk)qThxaRaneiExvEiDGeVnDo)Hy8W8peZhQ94cyfObaX7QYdPdA2K5Ey(hQ94cyfObaX7QYdPdK4TPZ5pS0pCThg0drz9yIvgqY5XuZl24KhM)HOSEmXkdi58yQ5fBCYdd(HApUawbAaq8UQ8q6ajEB6C(dr0dd9WSShwYd1ECbSc0aG4Dv5H0bnBYCpm)dX8HApUawbAaq8UQ8q6GMxSXjpS0pCThg8drz9yIvgq0(C0jsopMAEXgN8W8peL1Jjwzar7ZrNi58yQ5fBCYdd6HHc3dZ)qmFO2JlGvGgceVRkpKoqI3MoN)Ws)W1EyWpeL1JjwzajNhtnVyJtEyw2d1ECbSc0aG4Dv5H0bnVyJtEyPF4Apm4hIY6XeRmGKZJPMxSXjpm)d1ECbSc0aG4Dv5H0bs82058hw6hgiCpmShIY6XeRmGKZJPMxSXjpm4hIY6XeRmGO95OtKCEm18Ino5HzzpeL1JjwzajNhtnVyJtEyqpu7XfWkqdbI3vLhshiXBtNZFiIEyOhML9quwpMyLbKCEmHt7Hy8WSShQ94cyfObaX7QYdPdAEXgN8Ws)W1EyqpeL1Jjwzar7ZrNi58yQ5fBCYdZ)qmFO2JlGvGgceVRkpKoqI3MoN)Ws)W1EyWpeL1Jjwzar7ZrNi58yQ5fBCYdZYEyjpu7XfWkqdbOBKeoHtI4uupm)dX8HOSEmXkdi58yQ5fBCYdd6HApUawbAiq8UQ8q6ajEB6C(dr0dd9WSShIY6XeRmGKZJjCApeJhIXdX4Hy8qmEigpml7HQ1OzfOZcN0ljh(Hb)quwpMyLbKCEm18Ino5Hy8WSShwYd1ECbSc0qa6gjHt4Kiof1dZ)WsEy8qXU5kqqUEm)H5FiMpu7XfWkqdaOBKeoHtI4uupm)dX8Hy(WsEikRhtSYasopMWP9WSShQ94cyfObaX7QYdPdAEXgN8WGE4ApeJhM)Hy(quwpMyLbKCEm18Ino5Hb9WqH7Hzzpu7XfWkqdaI3vLhsh08Ino5HL(HR9WGEikRhtSYasopMAEXgN8qmEigpml7HL8qThxaRanaGUrs4eojItr9W8peZhwYd1ECbSc0aa6gjfVRkpK(dZYEO2JlGvGgaeVRkpKoO5fBCYdZYEO2JlGvGgaeVRkpKoqI3MoN)WGk)qThxaRaneiExvEiDGeVnDo)Hy8qm26w3feDV(E1a713fSBIvwUr8Ui2JY9y7IsEyBJmXOyxbMusam2hIsEyw2dl5HTnYeJIDfysjbGt7H5FiMpSTrMyuSRatkjajEB6C(dd7HTnYeJIDfysjbm(dd(HHc3dZYEiMpSTrMyuSRatkjG4H76dl)Wapm)dJhk2nxbcY1J5peJhIXdZYEyBJmXOyxbMusa40Ey(h22itmk2vGjLeqZl24Khg0ddGT2fwuNZ3fgHgh10rLu6Cc5uLBDVAO967c2nXkl3iExe7r5ESDHioffGQzFfYbWP9W8pueNIcq1SVc5anVyJtEyWLFi6O8HH9qrRfzzIq)0e62ICIg3ZjFyw2dfXPOaiNQmrOn9OeaoThM)Hr6wJMjjQ2I6CUvFyqpmayLFy(h24otDnAgq1g6f2vs6OskDoXvj3jZ1k3ea7MyLL7clQZ57crRfzzIq)0TUxv43RVly3eRSCJ4DrShL7X2fnUZuxJMbKdVsDnAoXlICtaSBIvw(W8puToPTrd08Ino5Hb)q0r5dZ)W4Dv5H0buvRzqZl24Khg8drhL7clQZ57c16K2gTTUxDL3RVly3eRSCJ4DHf158Dbv1AExe7r5ESDHADsBJgaN2dZ)Wg3zQRrZaYHxPUgnN4frUja2nXkl3f1X5uuUlcT2w3RU2E9DHf158DHy9ojHol3fSBIvwUr8w3RIn2RVly3eRSCJ4DrShL7X2fL8W2gzIrXUcmPKaySpeL8WSShwYdBBKjgf7kWKscaN2dZ)W2gzIrXUcmPKaK4TPZ5pmSh22itmk2vGjLeW4pm4hgkCpml7HTnYeJIDfysjbGt7H5FyBJmXOyxbMusanVyJtEyqpma2AxyrDoFxGCQYeH20Js26E1v6E9DHf158Dbv1YXYeH(P7c2nXkl3iER7vXMUxFxyrDoFxiyQ1eH(P7c2nXkl3iER7vXw713fSBIvwUr8Ui2JY9y7crCkkavZ(kKd08Ino5Hb9qg7Cex5Kol8dZ)qmFy8UQ8q6GMjNB64Otw3hsqZl24Khg8drhLpm)dX8HL8q1QSRag70QhzqXjc9tbSBIvw(WSShkItrbeR3jR4efGt7Hy8WSShwYdJhk2nxbcY1J5peJhML9q1A0Sc0zHt6LKd)WGF4A7clQZ57cK2uhhDY6(qU19Qbc3E9Db7MyLLBeVlI9OCp2UiExvEiDGit0XQjKTP0bnVyJtEyWpmqOhgEFyKU1OzsIQTOoNB1hg2drhLpm)dvRYUcir210rLeR3jbSBIvw(WSShsHxRPMJ0TgnN0zHFyWpeDu(W8pmExvEiDGit0XQjKTP0bnVyJtEyw2dvRrZkqNfoPxso8dd(HyRDHf158DHO1ISmrOF6w3RgiWE9Db7MyLLBeVlI9OCp2UG6I4Khg2dJgrtnJM9hg8dPUiobSyyFxyrDoFxiztPNI0nbTTS19QbcTxFxWUjwz5gX7Iypk3JTleXPOagHgh10rLu6Cc5uLaCApml7HQ1OzfOZcN0ljh(Hb)WaRTlSOoNVliQTqJL8w3Rgq43RVlSOoNVlS0cEl5oDuPyFij7c2nXkl3iER7vdSY713fSBIvwUr8Ui2JY9y7cmFOioffqKj6y1eY2u6aCApml7HQ1OzfOZcN0ljh(Hb)WaH7Hy8W8peZhwYdBBKjgf7kWKscGX(quYdZYEyjpSTrMyuSRatkjaCApm)dX8HTnYeJIDfysjbiXBtNZFyypSTrMyuSRatkjGXFyWpmu4Eyw2dBBKjgf7kWKsciE4U(WYpmWdX4HzzpSTrMyuSRatkjaCApm)dBBKjgf7kWKscO5fBCYdd6HbWwpeJDHf158DrZKZnDC0jR7d5w3RgyT967c2nXkl3iExe7r5ESDbMpmExvEiDaYPkteAtpkb08Ino5Hb9WaR9WSShgpuSBUceKRhZFy(hI5dJ3vLhsh0m5CthhDY6(qcAEXgN8WGF4Apml7HX7QYdPdAMCUPJJozDFibnVyJtEyqpmu4Eigpml7HQ1OzfOZcN0ljh(Hb)WaR9WSShI5dl5HXdf7MRaFqtxtug)W8pSKhgpuSBUceKRhZFigpeJhM)Hy(WsEyBJmXOyxbMusam2hIsEyw2dl5HTnYeJIDfysjbGt7H5FiMpSTrMyuSRatkjajEB6C(dd7HTnYeJIDfysjbm(dd(HHc3dZYEyBJmXOyxbMusaXd31hw(HbEigpml7HTnYeJIDfysjbGt7H5FyBJmXOyxbMusanVyJtEyqpma26HySlSOoNVlezIownHSnL(w3RgaBSxFxyrDoFxePplg3wIq)0Db7MyLLBeV19QbwP713fwuNZ3fcMAnfVLfZL7c2nXkl3iER7vdGnDV(UGDtSYYnI3fXEuUhBxiItrbezIownHSnLoqEi9hML9qXJqEy(hsnOPRPMxSXjpm4hU2UWI6C(Uq0qNoQK2tuazR7vdGT2RVlSOoNVlKtZjr2i6UGDtSYYnI36E1qHBV(UGDtSYYnI3fXEuUhBxG5dPUio5HL(HXJOpmShsDrCcOz0S)WW7dX8HX7QYdPdem1AkEllMlbnVyJtEyPFyGhIXdd6HwuNZbcMAnfVLfZLG4r0hML9W4Dv5H0bcMAnfVLfZLGMxSXjpmOhg4HH9q0r5dX4HzzpeZhkItrbezIownHSnLoaN2dZYEOioffWzczC0iTohjPTrJ24OtgnAwBkobGt7Hy8W8pSKh24otDnAgSImAvlXnlX9esRtxl5gWUjwz5dZYEO4ripm)dPg001uZl24Khg8df(DHf158Dr8eBlrOF6w3RgkWE9Db7MyLLBeVlI9OCp2UqeNIcGCQYeH20Jsa40Eyw2dJ0TgntsuTf15CR(WGEyaqOhM)HXZL4JceR3jRSQJJgWUjwz5UWI6C(Uq0ArwMi0pDR7vdfAV(UGDtSYYnI3fXEuUhBxiItrbezIownHSnLoqEi9hML9qXJqEy(hsnOPRPMxSXjpm4hU2UWI6C(UW6O5CIgELWBDVAiHFV(UGDtSYYnI3fXEuUhBx04otDnAgqo8k11O5eViYnbWUjwz5dZYEyJ7m11OzGZeY4OrADossBJgTXrNmA0S2uCcGDtSYYDHf158DHADsBJ2w3RgAL3RVly3eRSCJ4DrShL7X2fnUZuxJMbotiJJgP15ijTnA0ghDYOrZAtXja2nXkl3fwuNZ3funZRW4OtAB026E1qRTxFxWUjwz5gX7Iypk3JTlW8HuxeN8WWEi1fXjGMrZ(dd7Hbw7Hy8WGFi1fXjGfd77clQZ57cRJMZj96MDDRBDxeLK967vdSxFxWUjwz5gX7Iypk3JTlI3vLhshiYeDSAczBkDqZl24Khg0df(WTlSOoNVlmpYeTTAkA16w3RgAV(UGDtSYYnI3fXEuUhBxeVRkpKoqKj6y1eY2u6GMxSXjpmOhk8HBxyrDoFxqnnlwVtU19Qc)E9Db7MyLLBeVlI9OCp2UaZhkItrbqovzIqB6rjaCApml7HL8W4HIDZvGpOPRjkJFy(hkItrbmcnoQPJkP05eYPkb40Ey(hkItrbezIownHSnLoaN2dX4H5FiMpKAqtxtnVyJtEyqpmExvEiDGi3eUfmoAGeVnDo)HH9qjEB6C(dZYEiMpuTgnRa6Svv6aAr9Hb)qHFThML9WsEOAv2vGGPw5onorhpQa2nXklFigpeJhML9qXJqEy(hsnOPRPMxSXjpm4hgq43fwuNZ3fICt4wW4O36E1vEV(UGDtSYYnI3fXEuUhBxG5dfXPOaiNQmrOn9OeaoThML9WsEy8qXU5kWh001eLXpm)dfXPOagHgh10rLu6Cc5uLaCApm)dfXPOaImrhRMq2MshGt7Hy8W8peZhsnOPRPMxSXjpmOhgVRkpKoqSENmrH35as82058hg2dL4TPZ5pml7Hy(q1A0ScOZwvPdOf1hg8df(1Eyw2dl5HQvzxbcMAL704eD8Ocy3eRS8Hy8qmEyw2dfpc5H5Fi1GMUMAEXgN8WGFyaSXUWI6C(UqSENmrH3526E112RVlSOoNVlQdA6kjHTjUe9c76UGDtSYYnI36EvSXE9Db7MyLLBeVlI9OCp2UqeNIcyeACuthvsPZjKtvcWP9WSShsnOPRPMxSXjpm4hgcBSlSOoNVlOD6C(w36w3fO4MmNVxnu4cfkCHcT2UaP1(4Oj7IWpSjchRITVk2mc9WhUoD(HZcTR1hsD9dXIwZXBr0uSEyZRi8Pz5dj3c)qdxVftz5dJ0nhntaVqLAC(HRmc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhA6ddFHNs9qmdGDmaVqLAC(HRmc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhIzaSJb4fQuJZpCne6Hi85O4wz5dXsTk7kqyy9q9EiwQvzxbcdWUjwzjwpeZayhdWluPgNF4Ai0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEOPpm8fEk1dXma2Xa8c9cf(Hnr4yvS9vXMrOh(W1PZpCwODT(qQRFiwApUawjy9WMxr4tZYhsUf(HgUElMYYhgPBoAMaEHk148dXgi0dr4ZrXTYYhwmli8dj5C1W(dxjpuVhwkC7HYb1qMZF4rJBtV(HyIimEiMRHDmaVqLAC(Hyde6Hi85O4wz5dXs7XfWkiaqyy9q9EiwApUawbAaGWW6Hygka2Xa8cvQX5hInqOhIWNJIBLLpelThxaRGqaHH1d17HyP94cyfOHacdRhIziSb2Xa8cvQX5hUsrOhIWNJIBLLpSywq4hsY5QH9hUsEOEpSu42dLdQHmN)WJg3ME9dXery8qmxd7yaEHk148dxPi0dr4ZrXTYYhIL2JlGvqaGWW6H69qS0ECbSc0aaHH1dXme2a7yaEHk148dxPi0dr4ZrXTYYhIL2JlGvqiGWW6H69qS0ECbSc0qaHH1dXmuaSJb4f6fk8dBIWXQy7RInJqp8HRtNF4Sq7A9Hux)qSIscwpS5ve(0S8HKBHFOHR3IPS8Hr6MJMjGxOsno)qHhHEicFokUvw(qSuRYUcegwpuVhILAv2vGWaSBIvwI1dXma2Xa8cvQX5hUYi0dr4ZrXTYYhILAv2vGWW6H69qSuRYUcegGDtSYsSEiMbWogGxOxOWpSjchRITVk2mc9WhUoD(HZcTR1hsD9dXIOy9WMxr4tZYhsUf(HgUElMYYhgPBoAMaEHk148ddHqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6HM(WWx4PupeZayhdWluPgNFyie6Hi85O4wz5dXIgRaHbwXaaaRhQ3dXAfdaaSEiMHWogGxOsno)qHhHEicFokUvw(qSACNPUgndegwpuVhIvJ7m11OzGWaSBIvwI1dXma2Xa8cvQX5hUYi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEOPpm8fEk1dXma2Xa8cvQX5hITqOhIWNJIBLLpel1QSRaHH1d17HyPwLDfima7MyLLy9qmdGDmaVqLAC(Hyle6Hi85O4wz5dXIgRaHbwXaaaRhQ3dXAfdaaSEiMbWogGxOsno)WaHdHEicFokUvw(qSuRYUcegwpuVhILAv2vGWaSBIvwI1dXma2Xa8cvQX5hgkCi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEiMbWogGxOsno)WqbqOhIWNJIBLLpeR45s8rbcdRhQ3dXkEUeFuGWaSBIvwI1dn9HHVWtPEiMbWogGxOsno)Wqcpc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhA6ddFHNs9qmdGDmaVqLAC(HHeEe6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwpeZayhdWluPgNFyOvgHEicFokUvw(qSACNPUgndegwpuVhIvJ7m11OzGWaSBIvwI1dn9HHVWtPEiMbWogGxOxOWpSjchRITVk2mc9WhUoD(HZcTR1hsD9dXkwzdfJ1dBEfHpnlFi5w4hA46TyklFyKU5Ozc4fQuJZpmec9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhA6ddFHNs9qmdGDmaVqLAC(HHqOhIWNJIBLLpelAScegyfdaaSEOEpeRvmaaW6Hygc7yaEHk148dfEe6Hi85O4wz5dXIgRaHbwXaaaRhQ3dXAfdaaSEiMbWogGxOsno)WvgHEicFokUvw(qSACNPUgndegwpuVhIvJ7m11OzGWaSBIvwI1dXma2Xa8cvQX5hUgc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhA6ddFHNs9qmdGDmaVqLAC(Hyde6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwpeZayhdWluPgNF4kfHEicFokUvw(qSACNPUgndegwpuVhIvJ7m11OzGWaSBIvwI1dn9HHVWtPEiMbWogGxOsno)WaHdHEicFokUvw(qSuRYUcegwpuVhILAv2vGWaSBIvwI1dn9HHVWtPEiMbWogGxOsno)WaRmc9qe(CuCRS8HyrJvGWaRyaaG1d17HyTIbaawpeZayhdWluPgNFyOWHqpeHphf3klFiw0yfimWkgaay9q9EiwRyaaG1dXma2Xa8cvQX5hgALrOhIWNJIBLLpeR45s8rbcdRhQ3dXkEUeFuGWaSBIvwI1dn9HHVWtPEiMbWogGxOsno)Wqyde6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwp00hg(cpL6Hyga7yaEHk148ddHnqOhIWNJIBLLpeRg3zQRrZaHH1d17Hy14otDnAgima7MyLLy9qmdGDmaVqLAC(HHwPi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEOPpm8fEk1dXma2Xa8c9cHTVq7ALLpeB8qlQZ5pSoeLaEH2f06JAQ8Uq4kCFiIzJOpm8VruUZ9qHZWDL7xiHRW9HyBWInU15EyOvgbpmu4cf6f6fs4kCFict3C0mbHEHeUc3hw6hkCWLMDtSYpeXwlYYhwq)0hIn3wKFi2wUNtcEHeUc3hw6hg(ztDC0pSG(PpeNM0uMaEHEHSOoNta0AoElIMwMGVSCEIgRVqwuNZjaAnhVfrtdRmIepvRSmrvTCSe54Ot6H9XFHSOoNta0AoElIMgwzervzc9yBu6lKf15CcGwZXBr00WkJi16K2gneqR5Or0KolC5aG1qWqvUXDM6A0mGC4vQRrZjErKBswwJ7m11OzGZeY4OrADossBJgTXrNmA0S2uCYlKf15CcGwZXBr00WkJirMOJvtiBtPJaAnhnIM0zHlhaSgcgQYLOwLDfqISRPJkjwVtMVKg3zQRrZaYHxPUgnN4frUjVqVqwuNZjHvgrXd3vUte6N(cjCFi289qJoBYhAU8HR3MVIWN6Sc8dxfBlc)q25LHjcN)qK8dLNJL(q59qL(qEi11pKw1YXn5HIC0Wj8dhfl5df5hQ39qcnBzj3dnx(qK8dJMJL(WMn5uZ9W1BZxrpKqJJd1eFOioffb8czrDoNewzePT5Ri8PoRW4Ote6NIGHQCjQ1OzfmKeTQLJ7xiHRW9HH)4QL7HuwCC0pm3H3puE4I6dXDDQpm3H)q6gk(H0W1hkCWKZnDC0peBs3hYhkpKocE41pCOEOsNFy8UQ8q6pCipuV7H1Zr)q9EOKRwUhszXXr)WChE)WWFhUOcEi2o1d9Z5hEupuPZe(HXZLJoNtEO18dnXk)q9E4cRpe5O0h)HkD(Hbc3djC8Cj5HvMrA5qWdv68djZYdPSitEyUdVFy4VdxuFOHR3IPt0Q1CGxiHRW9HwuNZjHvgroJK6WDzQzYvrXiyOkto8Q44sGZiPoCxMAMCvuCEmfXPOanto30XrNSUpKaCAzzX7QYdPdAMCUPJJozDFibnVyJtckq4YYuRrZkqNfoPxsoCWbWgy8czrDoNewzefTAnzrDopvhIIa3w4YApUawjiGO9e1YbqWqvoEOy3CfiixpMNpExvEiDGrOXrnDujLoNqovjO5fBCs(4Dv5H0bnto30XrNSUpKGMxSXjzzLepuSBUceKRhZZhVRkpKoWi04OMoQKsNtiNQe08Ino5fYI6CojSYikA1AYI6CEQoefbUTWLJsYlKf15CsyLru0Q1Kf158uDikcCBHltueq0EIA5aiyOkBrDqXj25LHjbh6fYI6CojSYikA1AYI6CEQoefbUTWLJv2qXiGO9e1YbqWqv2I6GItSZldtckWl0lKf15CcikjLnpYeTTAkA1kcgQYX7QYdPdezIownHSnLoO5fBCsqcF4EHSOoNtarjjSYiIAAwSENebdv54Dv5H0bImrhRMq2Msh08InojiHpCVqwuNZjGOKewzejYnHBbJJgbdvzmfXPOaiNQmrOn9OeaoTSSsIhk2nxb(GMUMOmoVioffWi04OMoQKsNtiNQeGtlVioffqKj6y1eY2u6aCAyKhtQbnDn18InojO4Dv5H0bICt4wW4Obs82058WK4TPZ5zzyQwJMvaD2QkDaTOgSWVwwwjQvzxbcMAL704eD8OIbgzzIhHKNAqtxtnVyJtcoGW)czrDoNaIssyLrKy9ozIcVZHGHQmMI4uuaKtvMi0MEucaNwwwjXdf7MRaFqtxtugNxeNIcyeACuthvsPZjKtvcWPLxeNIciYeDSAczBkDaonmYJj1GMUMAEXgNeu8UQ8q6aX6DYefENdiXBtNZdtI3MoNNLHPAnAwb0zRQ0b0IAWc)AzzLOwLDfiyQvUtJt0XJkgyKLjEesEQbnDn18Inoj4ayJxilQZ5equscRmIQdA6kjHTjUe9c76lKf15CcikjHvgr0oDohbdvzrCkkGrOXrnDujLoNqovjaNwwg1GMUMAEXgNeCiSXl0lKf15Cciwzdfx2i04OMoQKsNtiNQebdv5sABKjgf7kWKscGX(quswwBJmXOyxbMusanVyJtcQCGWLLzrDqXj25LHjbvUTrMyuSRatkjG4H7A4n0lKf15CciwzdfhwzejATilte6NIGyUyLtQ1OzLuoacgQY0yfSyJdeXPOaun7RqoaoT80yfSyJdeXPOaun7RqoqZl24KGlJokdt0ArwMi0pnHUTiNOX9CYSmrCkkaYPkteAtpkbGtlFKU1OzsIQTOoNB1Gcaw58nUZuxJMbuTHEHDLKoQKsNtCvYDYCTYn5fYI6CobeRSHIdRmIwWR6qOFkcgQYOJYstJvWInoqeNIciYgrtXkBOyqZl24KGchi0AVqwuNZjGyLnuCyLrKGPwte6NIGHQCJ7m11OzaTdpspDuP2wHRtuTHEHDLKxeNIcqvTCCtslwlaGt7fYI6CobeRSHIdRmIOQwowMi0pfbdv5g3zQRrZaAhEKE6OsTTcxNOAd9c7k5fYI6CobeRSHIdRmIuRtAB0qWqvUXDM6A0mGC4vQRrZjErKBsE16K2gnqZl24KGrhL5J3vLhshqvTMbnVyJtcgDu(czrDoNaIv2qXHvgruvRzemuLvRtAB0a40Y34otDnAgqo8k11O5eViYn5fYI6CobeRSHIdRmIKSP0tr6MG2wqWqvM6I4KWIgrtnJM9GPUiobSyy)fYI6CobeRSHIdRmIqovzIqB6rjiyOkxsBJmXOyxbMusam2hIsYYABKjgf7kWKscO5fBCsqLdeUSmlQdkoXoVmmjOYTnYeJIDfysjbepCxdVHEHSOoNtaXkBO4WkJirRfzzIq)ueeZfRCsTgnRKYbqWqvMcVwtnhPBnAoPZchm6OmF8UQ8q6arMOJvtiBtPdAEXgNKLfVRkpKoqKj6y1eY2u6GMxSXjbhiuyOJY8QvzxbKi7A6OsI17KVqwuNZjGyLnuCyLrKit0XQjKTP0rWqvUK2gzIrXUcmPKaySpeLKL12itmk2vGjLeqZl24KGkVwwMf1bfNyNxgMeu52gzIrXUcmPKaIhURH3qVqwuNZjGyLnuCyLruZKZnDC0jR7djcgQYL02itmk2vGjLeaJ9HOKSS2gzIrXUcmPKaAEXgNeu51YYSOoO4e78YWKGk32itmk2vGjLeq8WDn8g6fYI6CobeRSHIdRmIiQTqJLmcgQYI4uuaJqJJA6OskDoHCQsaoTSmXJqYtnOPRPMxSXjbhyTxilQZ5eqSYgkoSYicPn1XrNSUpKiyOktJvWInoqeNIcq1SVc5anVyJtcIXohXvoPZc)czrDoNaIv2qXHvgruvlhlte6N(czrDoNaIv2qXHvgrcMAnrOF6lKf15CciwzdfhwzefPplg3wIq)0xilQZ5eqSYgkoSYisSENKqNLVqwuNZjGyLnuCyLrKLwWBj3PJkf7dj5fYI6CobeRSHIdRmIeTUn0mcgQY0yfSyJdeXPOaun7RqoqZl24KGySZrCLt6SWVqwuNZjGyLnuCyLrKGPwtXBzXCjcgQYuxeNeu8iAywuNZbl4vDi0pfepI(czrDoNaIv2qXHvgrIg60rL0EIciiyOklItrbezIownHSnLoqEi9SmXJqYtnOPRPMxSXjbV2lKf15CciwzdfhwzejNMtISr0xilQZ5eqSYgkoSYis0ArwMi0pfbXCXkNuRrZkPCaemuLvRrZkqNfoPxsoCWyRSSiDRrZKevBrDo3QbfaekF8Cj(OaX6DYkR64OFHSOoNtaXkBO4WkJO4j2wIq)uemuLPUiobOZcN0lTyypy0rz4n0lKf15CciwzdfhwzePwN02OHGHQCJ7m11Oza5WRuxJMt8Ii3KSSg3zQRrZaNjKXrJ06CKK2gnAJJoz0OzTP4KxilQZ5eqSYgkoSYiIQzEfghDsBJgcgQYnUZuxJMbotiJJgP15ijTnA0ghDYOrZAtXjVqwuNZjGyLnuCyLrK1rZ5KEDZUIGHQmMuxeNeg1fXjGMrZEycF4WiyQlItalg2FHEHSOoNtaeTSrOXrnDujLoNqovjcgQYL02itmk2vGjLeaJ9HOKSSsABKjgf7kWKscaNwEmBBKjgf7kWKscqI3MoNhwBJmXOyxbMusaJhCOWLLHzBJmXOyxbMusaXd31YbYhpuSBUceKRhZXaJSS2gzIrXUcmPKaWPLVTrMyuSRatkjGMxSXjbfaB9czrDoNaiAyLrKO1ISmrOFkcgQY0yfSyJdeXPOaun7RqoaoT80yfSyJdeXPOaun7RqoqZl24KGlJokdt0ArwMi0pnHUTiNOX9CYSmrCkkaYPkteAtpkbGtlFKU1OzsIQTOoNB1Gcaw58nUZuxJMbuTHEHDLKoQKsNtCvYDYCTYn5fYI6Cobq0WkJi16K2gnemuLBCNPUgndihEL6A0CIxe5MKxToPTrd08Inojy0rz(4Dv5H0buvRzqZl24KGrhLVqwuNZjaIgwzervTMrqDCofLLdTgcgQYQ1jTnAaCA5BCNPUgndihEL6A0CIxe5M8czrDoNaiAyLrKy9ojHolFHSOoNtaenSYic5uLjcTPhLGGHQCjTnYeJIDfysjbWyFikjlRK2gzIrXUcmPKaWPLVTrMyuSRatkjajEB6CEyTnYeJIDfysjbmEWHcxwwBJmXOyxbMusa40Y32itmk2vGjLeqZl24KGcGTEHSOoNtaenSYiIQA5yzIq)0xilQZ5eardRmIem1AIq)0xilQZ5eardRmIqAtDC0jR7djcgQY0yfSyJdeXPOaun7RqoqZl24KGySZrCLt6SW5XmExvEiDqZKZnDC0jR7djO5fBCsWOJY8ywIAv2vaJDA1JmO4eH(PzzI4uuaX6DYkorb40WilRK4HIDZvGGC9yogzzQ1OzfOZcN0ljho41EHSOoNtaenSYis0ArwMi0pfbdv54Dv5H0bImrhRMq2Msh08Inoj4aHcVr6wJMjjQ2I6CUvddDuMxTk7kGezxthvsSENmlJcVwtnhPBnAoPZchm6OmF8UQ8q6arMOJvtiBtPdAEXgNKLPwJMvGolCsVKC4GXwVqwuNZjaIgwzejztPNI0nbTTGGHQm1fXjHfnIMAgn7btDrCcyXW(lKf15CcGOHvgre1wOXsgbdvzrCkkGrOXrnDujLoNqovjaNwwMAnAwb6SWj9sYHdoWAVqwuNZjaIgwzezPf8wYD6OsX(qsEHSOoNtaenSYiQzY5Moo6K19HebdvzmfXPOaImrhRMq2MshGtlltTgnRaDw4KEj5WbhiCyKhZsABKjgf7kWKscGX(quswwjTnYeJIDfysjbGtlpMTnYeJIDfysjbiXBtNZdRTrMyuSRatkjGXdou4YYABKjgf7kWKsciE4UwoagzzTnYeJIDfysjbGtlFBJmXOyxbMusanVyJtcka2cJxilQZ5eardRmIezIownHSnLocgQYygVRkpKoa5uLjcTPhLaAEXgNeuG1YYIhk2nxbcY1J55XmExvEiDqZKZnDC0jR7djO5fBCsWRLLfVRkpKoOzY5Moo6K19He08InojOqHdJSm1A0Sc0zHt6LKdhCG1YYWSK4HIDZvGpOPRjkJZxs8qXU5kqqUEmhdmYJzjTnYeJIDfysjbWyFikjlRK2gzIrXUcmPKaWPLhZ2gzIrXUcmPKaK4TPZ5H12itmk2vGjLeW4bhkCzzTnYeJIDfysjbepCxlhaJSS2gzIrXUcmPKaWPLVTrMyuSRatkjGMxSXjbfaBHXlKf15CcGOHvgrr6ZIXTLi0p9fYI6Cobq0WkJibtTMI3YI5YxilQZ5eardRmIen0PJkP9efqqWqvweNIciYeDSAczBkDG8q6zzIhHKNAqtxtnVyJtcETxilQZ5eardRmIKtZjr2i6lKf15CcGOHvgrXtSTeH(PiyOkJj1fXjLoEenmQlItanJM9WlMX7QYdPdem1AkEllMlbnVyJtkDamcYI6CoqWuRP4TSyUeepIMLfVRkpKoqWuRP4TSyUe08InojOaHHokXildtrCkkGit0XQjKTP0b40YYeXPOaotiJJgP15ijTnA0ghDYOrZAtXjaCAyKVKg3zQRrZGvKrRAjUzjUNqAD6Aj3zzIhHKNAqtxtnVyJtcw4FHSOoNtaenSYis0ArwMi0pfbdvzrCkkaYPkteAtpkbGtllls3A0mjr1wuNZTAqbaHYhpxIpkqSENSYQoo6xilQZ5eardRmISoAoNOHxjmcgQYI4uuarMOJvtiBtPdKhsplt8iK8udA6AQ5fBCsWR9czrDoNaiAyLrKADsBJgcgQYnUZuxJMbKdVsDnAoXlICtYYACNPUgndCMqghnsRZrsAB0Ono6KrJM1MItEHSOoNtaenSYiIQzEfghDsBJgcgQYnUZuxJMbotiJJgP15ijTnA0ghDYOrZAtXjVqwuNZjaIgwzezD0CoPx3SRiyOkJj1fXjHrDrCcOz0ShwG1WiyQlItalg2FHEHSOoNtaApUawjLrz9yIvgbUTWLj58ycNgcqzvCUSioffOzY5Moo6K19HeGtllteNIcyeACuthvsPZjKtvcWP9czrDoNa0ECbSscRmIqz9yIvgbUTWLjAFo6ejNht40qakRIZLJhk2nxbcY1J55fXPOanto30XrNSUpKaCA5fXPOagHgh10rLu6Cc5uLaCAzzLepuSBUceKRhZZlItrbmcnoQPJkP05eYPkb40EHSOoNtaApUawjHvgrOSEmXkJa3w4YeTphDIKZJPMxSXji4OvMW6qHG45YrNZlhpuSBUceKRhZrakRIZLJ3vLhsh0m5CthhDY6(qcAEXgNeSWP4Dv5H0bgHgh10rLu6Cc5uLGMxSXjiaLvX5exjC54Dv5H0bgHgh10rLu6Cc5uLGMxSXjiyOklItrbmcnoQPJkP05eYPkbYdP)czrDoNa0ECbSscRmIqz9yIvgbUTWLjAFo6ejNhtnVyJtqWrRmH1HcbXZLJoNxoEOy3CfiixpMJauwfNlhVRkpKoOzY5Moo6K19He08InobbOSkoN4kHlhVRkpKoWi04OMoQKsNtiNQe08InobbdvzrCkkGrOXrnDujLoNqovjaN2lKf15Ccq7XfWkjSYicL1Jjwze42cxMKZJPMxSXji4OvMW6qHG45YrNZlhpuSBUceKRhZrakRIZLJ3vLhsh0m5CthhDY6(qcAEXgNeKWP4Dv5H0bgHgh10rLu6Cc5uLGMxSXjiaLvX5exjC54Dv5H0bgHgh10rLu6Cc5uLGMxSXjVqwuNZjaThxaRKWkJiCcNgLxiiGupLuw7XfWAaemuLXu7XfWkiaGUrs4eojItrLLfpuSBUceKRhZZR94cyfeaq3iP4Dv5H0XipMOSEmXkdiAFo6ejNht40YJzjXdf7MRab56X88LO94cyfecq3ijCcNeXPOYYIhk2nxbcY1J55lr7XfWkieGUrsX7QYdPNLP94cyfeceVRkpKoO5fBCswM2JlGvqaaDJKWjCseNIkpMLO94cyfecq3ijCcNeXPOYY0ECbSccaI3vLhshiXBtNZdQS2JlGvqiq8UQ8q6ajEB6CogzzApUawbba0nskExvEi98LO94cyfecq3ijCcNeXPOYR94cyfeaeVRkpKoqI3MoNhuzThxaRGqG4Dv5H0bs8205CmYYkbL1Jjwzar7ZrNi58ycNwEmlr7XfWkieGUrs4eojItrLhtThxaRGaG4Dv5H0bs82058sVwWOSEmXkdi58yQ5fBCswgkRhtSYasopMAEXgNeK2JlGvqaq8UQ8q6ajEB6C(kjegzzApUawbHa0nscNWjrCkQ8yQ94cyfeaq3ijCcNeXPOYR94cyfeaeVRkpKoqI3MoNhuzThxaRGqG4Dv5H0bs820588yQ94cyfeaeVRkpKoqI3MoNx61cgL1JjwzajNhtnVyJtYYqz9yIvgqY5XuZl24KG0ECbSccaI3vLhshiXBtNZxjHWildZs0ECbSccaOBKeoHtI4uuzzApUawbHaX7QYdPdK4TPZ5bvw7XfWkiaiExvEiDGeVnDohJ8yQ94cyfeceVRkpKoOztMlV2JlGvqiq8UQ8q6ajEB6CEPxliuwpMyLbKCEm18InojpkRhtSYasopMAEXgNeS2JlGvqiq8UQ8q6ajEB6C(kjuwwjApUawbHaX7QYdPdA2K5YJP2JlGvqiq8UQ8q6GMxSXjLETGrz9yIvgq0(C0jsopMAEXgNKhL1Jjwzar7ZrNi58yQ5fBCsqHcxEm1ECbSccaI3vLhshiXBtNZl9AbJY6XeRmGKZJPMxSXjzzApUawbHaX7QYdPdAEXgNu61cgL1JjwzajNhtnVyJtYR94cyfeceVRkpKoqI3MoNx6aHlmuwpMyLbKCEm18InojyuwpMyLbeTphDIKZJPMxSXjzzOSEmXkdi58yQ5fBCsqApUawbbaX7QYdPdK4TPZ5RKqzzOSEmXkdi58ycNggzzApUawbHaX7QYdPdAEXgNu61ccL1Jjwzar7ZrNi58yQ5fBCsEm1ECbSccaI3vLhshiXBtNZl9AbJY6XeRmGO95OtKCEm18InojlReThxaRGaa6gjHt4KiofvEmrz9yIvgqY5XuZl24KG0ECbSccaI3vLhshiXBtNZxjHYYqz9yIvgqY5XeonmWadmWaJSm1A0Sc0zHt6LKdhmkRhtSYasopMAEXgNGrwwjApUawbba0nscNWjrCkQ8LepuSBUceKRhZZJP2JlGvqiaDJKWjCseNIkpMywckRhtSYasopMWPLLP94cyfeceVRkpKoO5fBCsqRHrEmrz9yIvgqY5XuZl24KGcfUSmThxaRGqG4Dv5H0bnVyJtk9AbHY6XeRmGKZJPMxSXjyGrwwjApUawbHa0nscNWjrCkQ8ywI2JlGvqiaDJKI3vLhsplt7XfWkieiExvEiDqZl24KSmThxaRGqG4Dv5H0bs82058GkR94cyfeaeVRkpKoqI3MoNJbgVqwuNZjaThxaRKWkJiCcNgLxiiGupLuw7XfWAiemuLXu7XfWkieGUrs4eojItrLLfpuSBUceKRhZZR94cyfecq3iP4Dv5H0XipMOSEmXkdiAFo6ejNht40YJzjXdf7MRab56X88LO94cyfeaq3ijCcNeXPOYYIhk2nxbcY1J55lr7XfWkiaGUrsX7QYdPNLP94cyfeaeVRkpKoO5fBCswM2JlGvqiaDJKWjCseNIkpMLO94cyfeaq3ijCcNeXPOYY0ECbSccbI3vLhshiXBtNZdQS2JlGvqaq8UQ8q6ajEB6CogzzApUawbHa0nskExvEi98LO94cyfeaq3ijCcNeXPOYR94cyfeceVRkpKoqI3MoNhuzThxaRGaG4Dv5H0bs8205CmYYkbL1Jjwzar7ZrNi58ycNwEmlr7XfWkiaGUrs4eojItrLhtThxaRGqG4Dv5H0bs82058sVwWOSEmXkdi58yQ5fBCswgkRhtSYasopMAEXgNeK2JlGvqiq8UQ8q6ajEB6C(kjegzzApUawbba0nscNWjrCkQ8yQ94cyfecq3ijCcNeXPOYR94cyfeceVRkpKoqI3MoNhuzThxaRGaG4Dv5H0bs820588yQ94cyfeceVRkpKoqI3MoNx61cgL1JjwzajNhtnVyJtYYqz9yIvgqY5XuZl24KG0ECbSccbI3vLhshiXBtNZxjHWildZs0ECbSccbOBKeoHtI4uuzzApUawbbaX7QYdPdK4TPZ5bvw7XfWkieiExvEiDGeVnDohJ8yQ94cyfeaeVRkpKoOztMlV2JlGvqaq8UQ8q6ajEB6CEPxliuwpMyLbKCEm18InojpkRhtSYasopMAEXgNeS2JlGvqaq8UQ8q6ajEB6C(kjuwwjApUawbbaX7QYdPdA2K5YJP2JlGvqaq8UQ8q6GMxSXjLETGrz9yIvgq0(C0jsopMAEXgNKhL1Jjwzar7ZrNi58yQ5fBCsqHcxEm1ECbSccbI3vLhshiXBtNZl9AbJY6XeRmGKZJPMxSXjzzApUawbbaX7QYdPdAEXgNu61cgL1JjwzajNhtnVyJtYR94cyfeaeVRkpKoqI3MoNx6aHlmuwpMyLbKCEm18InojyuwpMyLbeTphDIKZJPMxSXjzzOSEmXkdi58yQ5fBCsqApUawbHaX7QYdPdK4TPZ5RKqzzOSEmXkdi58ycNggzzApUawbbaX7QYdPdAEXgNu61ccL1Jjwzar7ZrNi58yQ5fBCsEm1ECbSccbI3vLhshiXBtNZl9AbJY6XeRmGO95OtKCEm18InojlReThxaRGqa6gjHt4KiofvEmrz9yIvgqY5XuZl24KG0ECbSccbI3vLhshiXBtNZxjHYYqz9yIvgqY5XeonmWadmWaJSm1A0Sc0zHt6LKdhmkRhtSYasopMAEXgNGrwwjApUawbHa0nscNWjrCkQ8LepuSBUceKRhZZJP2JlGvqaaDJKWjCseNIkpMywckRhtSYasopMWPLLP94cyfeaeVRkpKoO5fBCsqRHrEmrz9yIvgqY5XuZl24KGcfUSmThxaRGaG4Dv5H0bnVyJtk9AbHY6XeRmGKZJPMxSXjyGrwwjApUawbba0nscNWjrCkQ8ywI2JlGvqaaDJKI3vLhsplt7XfWkiaiExvEiDqZl24KSmThxaRGaG4Dv5H0bs82058GkR94cyfeceVRkpKoqI3MoNJbg7ccnoUxn0Ac)w36Ed]] )

end
