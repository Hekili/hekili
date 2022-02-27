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


    spec:RegisterPack( "Beast Mastery", 20220226, [[da1I6bqibvpIGQ6skjv2KOYNGsgfu0PGcRsIqELGYSus1TKi1Ua(feYWKi5ycyzc0ZiOY0GsHRPKY2uskFdkfzCkjv15GsjRdcY7iOkvZtq6Esu7tq8pOukDqLKQSqiupecQjkrOQlkrqBekLI(iukQrcLsHtcLs1kjiZuIOBkrOYovs8tjcmucQswkbvXtLWuHaFvIqzSeuoRssQ9Qu)vKbd6WuwmHESqtMOlJAZi5ZqQrJuDAfRMGQuEnbMTKUTsSBQ(TkdhPCCLKKLl1ZrmDsxhQ2oK8DiA8qP68IQwVssmFrz)Q6DGnc2fst59kblvWGLkyWvdemOWfCnSXUqZtJ3f0SOadnVlCBH3fiMnI(WsCgr5o)UGMLVEMCJGDb5W7iVlORknccHieHEu64IG4TGiYSGxnDop2gLIiYSer0UqeFQk2UVf3fst59kblvWGLkyWvdemOWfCTDHHR0VExumli8UG(iLSVf3fsMe3fiMnI(WsCgr5o)dX2a3vUFHW2KfBCRZ)WGRT(ddwQGbFHEHqy6MJMji0luPFOWdxA2nXk)qeBTilFyb9tFi2CBr(HcV4Eoj4fQ0pSeZM64OFyb9tFionPPmbSlQdrjBeSlKmLHx1nc2ReyJGDHf158Dr8WDL7eH(P7c2nXkl3iER7vcUrWUGDtSYYnI3fwuNZ3fAB(QcFQZQmo6eH(P7cjtI9qtNZ3fyZ3dn6SjFO5YhIG28vf(uNvHF4kcVq4hYoVmmz9hIKFO8CS0hkVhQ0hYdPU(H0QwEUjpuKJgoHF4OyjFOi)q9UhsOzll5FO5YhIKFy0CS0h2SjNA(hIG28v1dj044qnXhkItrra7Iypk3JTlc)HQ1OzfmKeTQLN7TUxr42iyxWUjwz5gX7Iypk3JTlIhk2nxbcY3J5pm3dJ3vLhshyeACuthvsPZjKtvcAEXgN8WCpmExvEiDqZKZnDC0jR7djO5fBCYdZYEy4pmEOy3CfiiFpM)WCpmExvEiDGrOXrnDujLoNqovjO5fBCYUGO9e19kb2fwuNZ3frRwtwuNZt1HO7I6q0KBl8Uq7XfWkzR7vWgBeSly3eRSCJ4DHf158Dr0Q1Kf158uDi6UOoen52cVlIsYw3RS2gb7c2nXkl3iExe7r5ESDHf1bfNyNxgM8WqFyWDbr7jQ7vcSlSOoNVlIwTMSOoNNQdr3f1HOj3w4Dbr36ELvBJGDb7MyLLBeVlI9OCp2UWI6GItSZldtEyipmWUGO9e19kb2fwuNZ3frRwtwuNZt1HO7I6q0KBl8UiwzdfV1TUlO1C8wenDJG9kb2iyxyrDoFxqWxwoprJ1Db7MyLLBeV19kb3iyxyrDoFxiEQwzzIQA5zjYXrN0d7JVly3eRSCJ4TUxr42iyxyrDoFxqvzc9yBu6UGDtSYYnI36EfSXgb7c2nXkl3iExqR5Or0Kol8UiayTDHf158DHADsBJ2Ui2JY9y7Ig3zQRrZaYHxPUgnN4frUja2nXklFyw2dBCNPUgndCMqghnsRZtsAB0Ono6KrJM1MItaSBIvwU19kRTrWUGDtSYYnI3f0AoAenPZcVlcawBxyrDoFxiYeDSAczBk9DrShL7X2fH)q1QSRasKDnDujX6Dsa7MyLLpm3dd)HnUZuxJMbKdVsDnAoXlICtaSBIvwU1TUlIv2qXBeSxjWgb7c2nXkl3iExe7r5ESDr4pSTrMyuSRatkjag7drjpml7HTnYeJIDfysjb08Ino5HHu(Hbk1dZYEOf1bfNyNxgM8Wqk)W2gzIrXUcmPKaIhURpSe9WG7clQZ57cJqJJA6OskDoHCQYTUxj4gb7c2nXkl3iExyrDoFxiATilte6NUlI9OCp2UqeNIcq1SVk5b40EyUhkItrbOA2xL8GMxSXjpm0YpeDu(WWEOO1ISmrOFAcDBrorJ75Kpml7HI4uuaKtvMi0MEucaN2dZ9WiDRrZKevBrDo3QpmKhgaGnEyUh24otDnAgq1g6f2vs6OskDoXvj3jZ1k3ea7MyLL7Iy(yLtQ1OzLSxjWw3RiCBeSly3eRSCJ4DrShL7X2fOJYhw6hkItrbezJOPyLnumO5fBCYdd5HLceCTDHf158DXcEvhc9t36EfSXgb7c2nXkl3iExe7r5ESDrJ7m11OzaTdpspDuP2wLRtuTHEHDLay3eRS8H5EOioffGQA55MKwSwaaN2UWI6C(UqWuRjc9t36EL12iyxWUjwz5gX7Iypk3JTlACNPUgndOD4r6PJk12QCDIQn0lSRea7MyLL7clQZ57cQQLNLjc9t36ELvBJGDb7MyLLBeVlI9OCp2UOXDM6A0mGC4vQRrZjErKBcGDtSYYhM7HQ1jTnAGMxSXjpm0hIokFyUhgVRkpKoGQAndAEXgN8WqFi6OCxyrDoFxOwN02OT19kytBeSly3eRSCJ4DrShL7X2fQ1jTnAaCApm3dBCNPUgndihEL6A0CIxe5May3eRSCxyrDoFxqvTM36ELv)nc2fSBIvwUr8Ui2JY9y7cQlItEyypmAen1mA2FyOpK6I4eWIH9DHf158DHKnLEks3e02Yw3RGT2iyxWUjwz5gX7Iypk3JTlc)HTnYeJIDfysjbWyFik5HzzpSTrMyuSRatkjGMxSXjpmKYpmqPEyw2dTOoO4e78YWKhgs5h22itmk2vGjLeq8WD9HLOhgCxyrDoFxGCQYeH20Js26ELaLAJGDb7MyLLBeVlSOoNVleTwKLjc9t3fXEuUhBxqHxRPMJ0TgnN0zHFyOpeDu(WCpmExvEiDGit0XQjKTP0bnVyJtEyw2dJ3vLhshiYeDSAczBkDqZl24Khg6dde8HH9q0r5dZ9q1QSRasKDnDujX6Dsa7MyLL7Iy(yLtQ1OzLSxjWw3ReiWgb7c2nXkl3iExe7r5ESDr4pSTrMyuSRatkjag7drjpml7HTnYeJIDfysjb08Ino5HHu(HR9WSShArDqXj25LHjpmKYpSTrMyuSRatkjG4H76dlrpm4UWI6C(UqKj6y1eY2u6BDVsGGBeSly3eRSCJ4DrShL7X2fH)W2gzIrXUcmPKaySpeL8WSSh22itmk2vGjLeqZl24Khgs5hU2dZYEOf1bfNyNxgM8Wqk)W2gzIrXUcmPKaIhURpSe9WG7clQZ57IMjNB64Otw3hYTUxjGWTrWUGDtSYYnI3fXEuUhBxiItrbmcnoQPJkP05eYPkb40Eyw2dfpc5H5Ei1GMUMAEXgN8WqFyG12fwuNZ3fe1wOXsER7vcGn2iyxWUjwz5gX7Iypk3JTleXPOaun7RsEqZl24KhgYdzSZrCLt6SW7clQZ57cK2uhhDY6(qU19kbwBJGDHf158Dbv1YZYeH(P7c2nXkl3iER7vcSABeSlSOoNVlem1AIq)0Db7MyLLBeV19kbWM2iyxyrDoFxePplg3wIq)0Db7MyLLBeV19kbw93iyxyrDoFxiwVtsOZYDb7MyLLBeV19kbWwBeSlSOoNVlS0cEl5oDuPyFij7c2nXkl3iER7vcwQnc2fSBIvwUr8Ui2JY9y7crCkkavZ(QKh08Ino5HH8qg7Cex5Kol8UWI6C(Uq062qZBDVsWaBeSly3eRSCJ4DrShL7X2fuxeN8WqEy8i6dd7HwuNZbl4vDi0pfepIUlSOoNVlem1AkEllMl36ELGb3iyxWUjwz5gX7Iypk3JTleXPOaImrhRMq2MshipK(dZYEO4ripm3dPg001uZl24Khg6dxBxyrDoFxiAOthvs7jkGS19kbfUnc2fwuNZ3fYP5KiBeDxWUjwz5gXBDVsqSXgb7c2nXkl3iExyrDoFxiATilte6NUlI9OCp2UqTgnRaDw4KEj5Wpm0hITEyw2dJ0TgntsuTf15CR(WqEyaqWhM7HXZL4JceR3jRSQJJgWUjwz5UiMpw5KAnAwj7vcS19kbxBJGDb7MyLLBeVlI9OCp2UG6I4eGolCsV0IH9hg6drhLpSe9WG7clQZ57I4j2wIq)0TUxj4QTrWUGDtSYYnI3fXEuUhBx04otDnAgqo8k11O5eViYnbWUjwz5dZYEyJ7m11OzGZeY4OrADEssBJgTXrNmA0S2uCcGDtSYYDHf158DHADsBJ2w3ReeBAJGDb7MyLLBeVlI9OCp2UOXDM6A0mWzczC0iTopjPTrJ24OtgnAwBkobWUjwz5UWI6C(UGQzEvghDsBJ2w3ReC1FJGDb7MyLLBeVlI9OCp2UaZhsDrCYdd7HuxeNaAgn7pmShkCL6Hy8WqFi1fXjGfd77clQZ57cRJMZj96MDDRBDxeLKnc2ReyJGDb7MyLLBeVlI9OCp2UiExvEiDGit0XQjKTP0bnVyJtEyipu4k1UWI6C(UW8it02QPOvRBDVsWnc2fSBIvwUr8Ui2JY9y7I4Dv5H0bImrhRMq2Msh08Ino5HH8qHRu7clQZ57cQPzX6DYTUxr42iyxWUjwz5gX7Iypk3JTlW8HI4uuaKtvMi0MEucaN2dZYEy4pmEOy3Cf4dA6AIY4hM7HI4uuaJqJJA6OskDoHCQsaoThM7HI4uuarMOJvtiBtPdWP9qmEyUhI5dPg001uZl24KhgYdJ3vLhshiYnHBbJJgiXBtNZFyypuI3MoN)WSShI5dvRrZkGoBvLoGwuFyOpu4w7Hzzpm8hQwLDfiyQvUtJt0XJkGDtSYYhIXdX4Hzzpu8iKhM7HudA6AQ5fBCYdd9HbeUDHf158DHi3eUfmo6TUxbBSrWUGDtSYYnI3fXEuUhBxG5dfXPOaiNQmrOn9OeaoThML9WWFy8qXU5kWh001eLXpm3dfXPOagHgh10rLu6Cc5uLaCApm3dfXPOaImrhRMq2MshGt7Hy8WCpeZhsnOPRPMxSXjpmKhgVRkpKoqSENmrH35bs82058hg2dL4TPZ5pml7Hy(q1A0ScOZwvPdOf1hg6dfU1Eyw2dd)HQvzxbcMAL704eD8Ocy3eRS8Hy8qmEyw2dfpc5H5Ei1GMUMAEXgN8WqFyGvBxyrDoFxiwVtMOW78BDVYABeSlSOoNVlQdA6kjj8gUe9c76UGDtSYYnI36ELvBJGDb7MyLLBeVlI9OCp2UqeNIcyeACuthvsPZjKtvcWP9WSShkEeYdZ9qQbnDn18Ino5HH(WGR2UWI6C(UG2PZ5BDR7cIUrWELaBeSly3eRSCJ4DrShL7X2fH)W2gzIrXUcmPKaySpeL8WSShg(dBBKjgf7kWKscaN2dZ9qmFyBJmXOyxbMusas82058hg2dBBKjgf7kWKscy8hg6ddwQhML9qmFyBJmXOyxbMusaXd31hw(HbEyUhgpuSBUceKVhZFigpeJhML9W2gzIrXUcmPKaWP9WCpSTrMyuSRatkjGMxSXjpmKhgaBTlSOoNVlmcnoQPJkP05eYPk36ELGBeSly3eRSCJ4DrShL7X2fI4uuaQM9vjpaN2dZ9qrCkkavZ(QKh08Ino5HHw(HOJYhg2dfTwKLjc9ttOBlYjACpN8HzzpueNIcGCQYeH20Jsa40EyUhgPBnAMKOAlQZ5w9HH8WaaSXdZ9Wg3zQRrZaQ2qVWUsshvsPZjUk5ozUw5May3eRSCxyrDoFxiATilte6NU19kc3gb7c2nXkl3iExe7r5ESDrJ7m11Oza5WRuxJMt8Ii3ea7MyLLpm3dvRtAB0anVyJtEyOpeDu(WCpmExvEiDav1Ag08Ino5HH(q0r5UWI6C(UqToPTrBR7vWgBeSly3eRSCJ4DHf158Dbv1AExe7r5ESDHADsBJgaN2dZ9Wg3zQRrZaYHxPUgnN4frUja2nXkl3f1X5uuUlcU2w3RS2gb7clQZ57cX6DscDwUly3eRSCJ4TUxz12iyxWUjwz5gX7Iypk3JTlc)HTnYeJIDfysjbWyFik5Hzzpm8h22itmk2vGjLeaoThM7HTnYeJIDfysjbiXBtNZFyypSTrMyuSRatkjGXFyOpmyPEyw2dBBKjgf7kWKscaN2dZ9W2gzIrXUcmPKaAEXgN8WqEyaS1UWI6C(Ua5uLjcTPhLS19kytBeSlSOoNVlOQwEwMi0pDxWUjwz5gXBDVYQ)gb7clQZ57cbtTMi0pDxWUjwz5gXBDVc2AJGDb7MyLLBeVlI9OCp2UqeNIcq1SVk5bnVyJtEyipKXohXvoPZc)WCpeZhgVRkpKoOzY5Moo6K19He08Ino5HH(q0r5dZ9qmFy4puTk7kGXoT6rguCIq)ua7MyLLpml7HI4uuaX6DYkorb40Eigpml7HH)W4HIDZvGG89y(dX4HzzpuTgnRaDw4KEj5Wpm0hU2UWI6C(UaPn1XrNSUpKBDVsGsTrWUGDtSYYnI3fXEuUhBxeVRkpKoqKj6y1eY2u6GMxSXjpm0hgi4dlrpms3A0mjr1wuNZT6dd7HOJYhM7HQvzxbKi7A6OsI17Ka2nXklFyw2dPWR1uZr6wJMt6SWpm0hIokFyUhgVRkpKoqKj6y1eY2u6GMxSXjpml7HQ1OzfOZcN0ljh(HH(qS1UWI6C(Uq0ArwMi0pDR7vceyJGDb7MyLLBeVlI9OCp2UG6I4Khg2dJgrtnJM9hg6dPUiobSyyFxyrDoFxiztPNI0nbTTS19kbcUrWUGDtSYYnI3fXEuUhBxiItrbmcnoQPJkP05eYPkb40Eyw2dvRrZkqNfoPxso8dd9HbwBxyrDoFxquBHgl5TUxjGWTrWUWI6C(UWsl4TK70rLI9HKSly3eRSCJ4TUxja2yJGDb7MyLLBeVlI9OCp2UaZhkItrbezIownHSnLoaN2dZYEOAnAwb6SWj9sYHFyOpmqPEigpm3dX8HH)W2gzIrXUcmPKaySpeL8WSShg(dBBKjgf7kWKscaN2dZ9qmFyBJmXOyxbMusas82058hg2dBBKjgf7kWKscy8hg6ddwQhML9W2gzIrXUcmPKaIhURpS8dd8qmEyw2dBBKjgf7kWKscaN2dZ9W2gzIrXUcmPKaAEXgN8WqEyaS1dXyxyrDoFx0m5CthhDY6(qU19kbwBJGDb7MyLLBeVlI9OCp2UaZhgVRkpKoa5uLjcTPhLaAEXgN8WqEyG1Eyw2dJhk2nxbcY3J5pm3dX8HX7QYdPdAMCUPJJozDFibnVyJtEyOpCThML9W4Dv5H0bnto30XrNSUpKGMxSXjpmKhgSupeJhML9q1A0Sc0zHt6LKd)WqFyG1Eyw2dX8HH)W4HIDZvGpOPRjkJFyUhg(dJhk2nxbcY3J5peJhIXdZ9qmFy4pSTrMyuSRatkjag7drjpml7HH)W2gzIrXUcmPKaWP9WCpeZh22itmk2vGjLeGeVnDo)HH9W2gzIrXUcmPKag)HH(WGL6HzzpSTrMyuSRatkjG4H76dl)WapeJhML9W2gzIrXUcmPKaWP9WCpSTrMyuSRatkjGMxSXjpmKhgaB9qm2fwuNZ3fImrhRMq2MsFR7vcSABeSlSOoNVlI0NfJBlrOF6UGDtSYYnI36ELaytBeSlSOoNVlem1AkEllMl3fSBIvwUr8w3Rey1FJGDb7MyLLBeVlI9OCp2UqeNIciYeDSAczBkDG8q6pml7HIhH8WCpKAqtxtnVyJtEyOpCTDHf158DHOHoDujTNOaYw3ReaBTrWUWI6C(UqonNezJO7c2nXkl3iER7vcwQnc2fSBIvwUr8Ui2JY9y7cmFi1fXjpS0pmEe9HH9qQlItanJM9hwIEiMpmExvEiDGGPwtXBzXCjO5fBCYdl9dd8qmEyip0I6CoqWuRP4TSyUeepI(WSShgVRkpKoqWuRP4TSyUe08Ino5HH8WapmShIokFigpml7Hy(qrCkkGit0XQjKTP0b40Eyw2dfXPOaotiJJgP15jjTnA0ghDYOrZAtXjaCApeJhM7HH)Wg3zQRrZGvLrRAjUzjUNqAD6Aj3a2nXklFyw2dfpc5H5Ei1GMUMAEXgN8WqFOWTlSOoNVlINyBjc9t36ELGb2iyxWUjwz5gX7Iypk3JTleXPOaiNQmrOn9OeaoThML9WiDRrZKevBrDo3QpmKhgae8H5Ey8Cj(OaX6DYkR64ObSBIvwUlSOoNVleTwKLjc9t36ELGb3iyxWUjwz5gX7Iypk3JTleXPOaImrhRMq2MshipK(dZYEO4ripm3dPg001uZl24Khg6dxBxyrDoFxyD0CordVs4TUxjOWTrWUGDtSYYnI3fXEuUhBx04otDnAgqo8k11O5eViYnbWUjwz5dZYEyJ7m11OzGZeY4OrADEssBJgTXrNmA0S2uCcGDtSYYDHf158DHADsBJ2w3ReeBSrWUGDtSYYnI3fXEuUhBx04otDnAg4mHmoAKwNNK02OrBC0jJgnRnfNay3eRSCxyrDoFxq1mVkJJoPTrBR7vcU2gb7c2nXkl3iExe7r5ESDbMpK6I4Khg2dPUiob0mA2FyypmWApeJhg6dPUiobSyyFxyrDoFxyD0CoPx3SRBDR7cThxaRKnc2ReyJGDb7MyLLBeVloA7ccR7clQZ57cuwpMyL3fOSkoVleXPOanto30XrNSUpKaCApml7HI4uuaJqJJA6OskDoHCQsaoTDbkRtUTW7csEpMWPT19kb3iyxWUjwz5gX7IJ2UGW6UWI6C(UaL1Jjw5DbkRIZ7I4HIDZvGG89y(dZ9qrCkkqZKZnDC0jR7djaN2dZ9qrCkkGrOXrnDujLoNqovjaN2dZYEy4pmEOy3CfiiFpM)WCpueNIcyeACuthvsPZjKtvcWPTlqzDYTfExq0(C0jsEpMWPT19kc3gb7c2nXkl3iExC02fewhQDHf158DbkRhtSY7cuwNCBH3feTphDIK3JPMxSXj7Iypk3JTleXPOagHgh10rLu6Cc5uLa5H03fOSkoN4kH3fX7QYdPdmcnoQPJkP05eYPkbnVyJt2fOSkoVlI3vLhsh0m5CthhDY6(qcAEXgN8WqX2(W4Dv5H0bgHgh10rLu6Cc5uLGMxSXjBDVc2yJGDb7MyLLBeVloA7ccRd1UWI6C(UaL1Jjw5DbkRtUTW7cI2NJorY7XuZl24KDrShL7X2fI4uuaJqJJA6OskDoHCQsaoTDbkRIZjUs4Dr8UQ8q6aJqJJA6OskDoHCQsqZl24KDbkRIZ7I4Dv5H0bnto30XrNSUpKGMxSXjBDVYABeSly3eRSCJ4DXrBxqyDO2fwuNZ3fOSEmXkVlqzDYTfExqY7XuZl24KDrShL7X2fXdf7MRab57X8DbkRIZjUs4Dr8UQ8q6aJqJJA6OskDoHCQsqZl24KDbkRIZ7I4Dv5H0bnto30XrNSUpKGMxSXjpmeSTpmExvEiDGrOXrnDujLoNqovjO5fBCYw3RSABeSly3eRSCJ4DHf158DH2JlG1a7Iypk3JTlW8HApUawbAaaDJKWjCseNI6HzzpmEOy3CfiiFpM)WCpu7XfWkqdaOBKu8UQ8q6peJhM7Hy(quwpMyLbeTphDIK3JjCApm3dX8HH)W4HIDZvGG89y(dZ9WWFO2JlGvGgeq3ijCcNeXPOEyw2dJhk2nxbcY3J5pm3dd)HApUawbAqaDJKI3vLhs)Hzzpu7XfWkqdcI3vLhsh08Ino5Hzzpu7XfWkqdaOBKeoHtI4uupm3dX8HH)qThxaRaniGUrs4eojItr9WSShQ94cyfObaX7QYdPdK4TPZ5pmKYpu7XfWkqdcI3vLhshiXBtNZFigpml7HApUawbAaaDJKI3vLhs)H5Ey4pu7XfWkqdcOBKeoHtI4uupm3d1ECbSc0aG4Dv5H0bs82058hgs5hQ94cyfObbX7QYdPdK4TPZ5peJhML9WWFikRhtSYaI2NJorY7XeoThM7Hy(WWFO2JlGvGgeq3ijCcNeXPOEyUhI5d1ECbSc0aG4Dv5H0bs82058hw6hU2dd9HOSEmXkdi59yQ5fBCYdZYEikRhtSYasEpMAEXgN8WqEO2JlGvGgaeVRkpKoqI3MoN)qe9WGpeJhML9qThxaRaniGUrs4eojItr9WCpeZhQ94cyfOba0nscNWjrCkQhM7HApUawbAaq8UQ8q6ajEB6C(ddP8d1ECbSc0GG4Dv5H0bs82058hM7Hy(qThxaRanaiExvEiDGeVnDo)HL(HR9WqFikRhtSYasEpMAEXgN8WSShIY6XeRmGK3JPMxSXjpmKhQ94cyfObaX7QYdPdK4TPZ5perpm4dX4HzzpeZhg(d1ECbSc0aa6gjHt4Kiof1dZYEO2JlGvGgeeVRkpKoqI3MoN)Wqk)qThxaRanaiExvEiDGeVnDo)Hy8WCpeZhQ94cyfObbX7QYdPdA2K5FyUhQ94cyfObbX7QYdPdK4TPZ5pS0pCThgYdrz9yIvgqY7XuZl24KhM7HOSEmXkdi59yQ5fBCYdd9HApUawbAqq8UQ8q6ajEB6C(dr0dd(WSShg(d1ECbSc0GG4Dv5H0bnBY8pm3dX8HApUawbAqq8UQ8q6GMxSXjpS0pCThg6drz9yIvgq0(C0jsEpMAEXgN8WCpeL1Jjwzar7ZrNi59yQ5fBCYdd5Hbl1dZ9qmFO2JlGvGgaeVRkpKoqI3MoN)Ws)W1EyOpeL1JjwzajVhtnVyJtEyw2d1ECbSc0GG4Dv5H0bnVyJtEyPF4Apm0hIY6XeRmGK3JPMxSXjpm3d1ECbSc0GG4Dv5H0bs82058hw6hgOupmShIY6XeRmGK3JPMxSXjpm0hIY6XeRmGO95OtK8Em18Ino5HzzpeL1JjwzajVhtnVyJtEyipu7XfWkqdaI3vLhshiXBtNZFiIEyWhML9quwpMyLbK8EmHt7Hy8WSShQ94cyfObbX7QYdPdAEXgN8Ws)W1EyipeL1Jjwzar7ZrNi59yQ5fBCYdZ9qmFO2JlGvGgaeVRkpKoqI3MoN)Ws)W1EyOpeL1Jjwzar7ZrNi59yQ5fBCYdZYEy4pu7XfWkqdaOBKeoHtI4uupm3dX8HOSEmXkdi59yQ5fBCYdd5HApUawbAaq8UQ8q6ajEB6C(dr0dd(WSShIY6XeRmGK3JjCApeJhIXdX4Hy8qmEigpml7HQ1OzfOZcN0ljh(HH(quwpMyLbK8Em18Ino5Hy8WSShg(d1ECbSc0aa6gjHt4Kiof1dZ9WWFy8qXU5kqq(Em)H5EiMpu7XfWkqdcOBKeoHtI4uupm3dX8Hy(WWFikRhtSYasEpMWP9WSShQ94cyfObbX7QYdPdAEXgN8WqE4ApeJhM7Hy(quwpMyLbK8Em18Ino5HH8WGL6Hzzpu7XfWkqdcI3vLhsh08Ino5HL(HR9WqEikRhtSYasEpMAEXgN8qmEigpml7HH)qThxaRaniGUrs4eojItr9WCpeZhg(d1ECbSc0Ga6gjfVRkpK(dZYEO2JlGvGgeeVRkpKoO5fBCYdZYEO2JlGvGgeeVRkpKoqI3MoN)Wqk)qThxaRanaiExvEiDGeVnDo)Hy8qm2fK6PKDH2JlG1aBDVc20gb7c2nXkl3iExyrDoFxO94cyn4Ui2JY9y7cmFO2JlGvGgeq3ijCcNeXPOEyw2dJhk2nxbcY3J5pm3d1ECbSc0Ga6gjfVRkpK(dX4H5EiMpeL1Jjwzar7ZrNi59ycN2dZ9qmFy4pmEOy3CfiiFpM)WCpm8hQ94cyfOba0nscNWjrCkQhML9W4HIDZvGG89y(dZ9WWFO2JlGvGgaq3iP4Dv5H0Fyw2d1ECbSc0aG4Dv5H0bnVyJtEyw2d1ECbSc0Ga6gjHt4Kiof1dZ9qmFy4pu7XfWkqdaOBKeoHtI4uupml7HApUawbAqq8UQ8q6ajEB6C(ddP8d1ECbSc0aG4Dv5H0bs82058hIXdZYEO2JlGvGgeq3iP4Dv5H0FyUhg(d1ECbSc0aa6gjHt4Kiof1dZ9qThxaRaniiExvEiDGeVnDo)HHu(HApUawbAaq8UQ8q6ajEB6C(dX4Hzzpm8hIY6XeRmGO95OtK8EmHt7H5EiMpm8hQ94cyfOba0nscNWjrCkQhM7Hy(qThxaRaniiExvEiDGeVnDo)HL(HR9WqFikRhtSYasEpMAEXgN8WSShIY6XeRmGK3JPMxSXjpmKhQ94cyfObbX7QYdPdK4TPZ5perpm4dX4Hzzpu7XfWkqdaOBKeoHtI4uupm3dX8HApUawbAqaDJKWjCseNI6H5EO2JlGvGgeeVRkpKoqI3MoN)Wqk)qThxaRanaiExvEiDGeVnDo)H5EiMpu7XfWkqdcI3vLhshiXBtNZFyPF4Apm0hIY6XeRmGK3JPMxSXjpml7HOSEmXkdi59yQ5fBCYdd5HApUawbAqq8UQ8q6ajEB6C(dr0dd(qmEyw2dX8HH)qThxaRaniGUrs4eojItr9WSShQ94cyfObaX7QYdPdK4TPZ5pmKYpu7XfWkqdcI3vLhshiXBtNZFigpm3dX8HApUawbAaq8UQ8q6GMnz(hM7HApUawbAaq8UQ8q6ajEB6C(dl9dx7HH8quwpMyLbK8Em18Ino5H5EikRhtSYasEpMAEXgN8WqFO2JlGvGgaeVRkpKoqI3MoN)qe9WGpml7HH)qThxaRanaiExvEiDqZMm)dZ9qmFO2JlGvGgaeVRkpKoO5fBCYdl9dx7HH(quwpMyLbeTphDIK3JPMxSXjpm3drz9yIvgq0(C0jsEpMAEXgN8WqEyWs9WCpeZhQ94cyfObbX7QYdPdK4TPZ5pS0pCThg6drz9yIvgqY7XuZl24KhML9qThxaRanaiExvEiDqZl24Khw6hU2dd9HOSEmXkdi59yQ5fBCYdZ9qThxaRanaiExvEiDGeVnDo)HL(Hbk1dd7HOSEmXkdi59yQ5fBCYdd9HOSEmXkdiAFo6ejVhtnVyJtEyw2drz9yIvgqY7XuZl24KhgYd1ECbSc0GG4Dv5H0bs82058hIOhg8HzzpeL1JjwzajVht40Eigpml7HApUawbAaq8UQ8q6GMxSXjpS0pCThgYdrz9yIvgq0(C0jsEpMAEXgN8WCpeZhQ94cyfObbX7QYdPdK4TPZ5pS0pCThg6drz9yIvgq0(C0jsEpMAEXgN8WSShg(d1ECbSc0Ga6gjHt4Kiof1dZ9qmFikRhtSYasEpMAEXgN8WqEO2JlGvGgeeVRkpKoqI3MoN)qe9WGpml7HOSEmXkdi59ycN2dX4Hy8qmEigpeJhIXdZYEOAnAwb6SWj9sYHFyOpeL1JjwzajVhtnVyJtEigpml7HH)qThxaRaniGUrs4eojItr9WCpm8hgpuSBUceKVhZFyUhI5d1ECbSc0aa6gjHt4Kiof1dZ9qmFiMpm8hIY6XeRmGK3JjCApml7HApUawbAaq8UQ8q6GMxSXjpmKhU2dX4H5EiMpeL1JjwzajVhtnVyJtEyipmyPEyw2d1ECbSc0aG4Dv5H0bnVyJtEyPF4ApmKhIY6XeRmGK3JPMxSXjpeJhIXdZYEy4pu7XfWkqdaOBKeoHtI4uupm3dX8HH)qThxaRanaGUrsX7QYdP)WSShQ94cyfObaX7QYdPdAEXgN8WSShQ94cyfObaX7QYdPdK4TPZ5pmKYpu7XfWkqdcI3vLhshiXBtNZFigpeJDbPEkzxO94cyn4w36w3fO4MmNVxjyPcgSubdU2UaP1(4Oj7IsSvpHNvW2xbBgHE4draD(HZcTR1hsD9dXIwZXBr0uSEyZRk8Pz5dj3c)qdxVftz5dJ0nhntaVqLCC(Hyde6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwp00hwclbL8Hyga7yaEHk548dXgi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEiMbWogGxOsoo)W1qOhIWNJIBLLpel1QSRaHH1d17HyPwLDfima7MyLLy9qmdGDmaVqLCC(HRHqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6HM(WsyjOKpeZayhdWl0luj2QNWZky7RGnJqp8HiGo)WzH216dPU(HyP94cyLG1dBEvHpnlFi5w4hA46TyklFyKU5Ozc4fQKJZpC1qOhIWNJIBLLpSywq4hsY7QH9hU6EOEpSK42dLdQHmN)WJg3ME9dXery8qmxd7yaEHk548dxne6Hi85O4wz5dXs7XfWkiaqyy9q9EiwApUawbAaGWW6Hygma2Xa8cvYX5hUAi0dr4ZrXTYYhIL2JlGvqqGWW6H69qS0ECbSc0GaHH1dXm4QHDmaVqLCC(Hyti0dr4ZrXTYYhwmli8dj5D1W(dxDpuVhwsC7HYb1qMZF4rJBtV(HyIimEiMRHDmaVqLCC(Hyti0dr4ZrXTYYhIL2JlGvqaGWW6H69qS0ECbSc0aaHH1dXm4QHDmaVqLCC(Hyti0dr4ZrXTYYhIL2JlGvqqGWW6H69qS0ECbSc0GaHH1dXmyaSJb4f6fQeB1t4zfS9vWMrOh(qeqNF4Sq7A9Hux)qSIscwpS5vf(0S8HKBHFOHR3IPS8Hr6MJMjGxOsoo)qHdHEicFokUvw(qSuRYUcegwpuVhILAv2vGWaSBIvwI1dXma2Xa8cvYX5hInqOhIWNJIBLLpel1QSRaHH1d17HyPwLDfima7MyLLy9qmdGDmaVqVqLyREcpRGTVc2mc9WhIa68dNfAxRpK66hIfrX6HnVQWNMLpKCl8dnC9wmLLpms3C0mb8cvYX5hgeHEicFokUvw(qSACNPUgndegwpuVhIvJ7m11OzGWaSBIvwI1dn9HLWsqjFiMbWogGxOsoo)WGi0dr4ZrXTYYhIfnwbcdSQbaawpuVhI1Qgaay9qmdIDmaVqLCC(Hchc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhIzaSJb4fQKJZpeBGqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6HM(WsyjOKpeZayhdWlujhNFi2cHEicFokUvw(qSuRYUcegwpuVhILAv2vGWaSBIvwI1dXma2Xa8cvYX5hITqOhIWNJIBLLpelAScegyvdaaSEOEpeRvnaaW6Hyga7yaEHk548dduke6Hi85O4wz5dXsTk7kqyy9q9EiwQvzxbcdWUjwzjwpeZayhdWlujhNFyWsHqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6Hyga7yaEHk548ddgaHEicFokUvw(qSINlXhfimSEOEpeR45s8rbcdWUjwzjwp00hwclbL8Hyga7yaEHk548ddkCi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEOPpSewck5dXma2Xa8cvYX5hgu4qOhIWNJIBLLpeRg3zQRrZaHH1d17Hy14otDnAgima7MyLLy9qmdGDmaVqLCC(HbXgi0dr4ZrXTYYhIvJ7m11OzGWW6H69qSACNPUgndegGDtSYsSEOPpSewck5dXma2Xa8c9cvIT6j8Sc2(kyZi0dFicOZpCwODT(qQRFiwXkBOySEyZRk8Pz5dj3c)qdxVftz5dJ0nhntaVqLCC(HbrOhIWNJIBLLpeRg3zQRrZaHH1d17Hy14otDnAgima7MyLLy9qtFyjSeuYhIzaSJb4fQKJZpmic9qe(CuCRS8HyrJvGWaRAaaG1d17HyTQbaawpeZGyhdWlujhNFOWHqpeHphf3klFiw0yfimWQgaay9q9EiwRAaaG1dXma2Xa8cvYX5hInqOhIWNJIBLLpeRg3zQRrZaHH1d17Hy14otDnAgima7MyLLy9qmdGDmaVqLCC(HRHqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6HM(WsyjOKpeZayhdWlujhNF4QHqpeHphf3klFiwnUZuxJMbcdRhQ3dXQXDM6A0mqya2nXklX6Hyga7yaEHk548dXMqOhIWNJIBLLpeRg3zQRrZaHH1d17Hy14otDnAgima7MyLLy9qtFyjSeuYhIzaSJb4fQKJZpmqPqOhIWNJIBLLpel1QSRaHH1d17HyPwLDfima7MyLLy9qtFyjSeuYhIzaSJb4fQKJZpma2aHEicFokUvw(qSOXkqyGvnaaW6H69qSw1aaaRhIzaSJb4fQKJZpmyPqOhIWNJIBLLpelAScegyvdaaSEOEpeRvnaaW6Hyga7yaEHk548ddInqOhIWNJIBLLpeR45s8rbcdRhQ3dXkEUeFuGWaSBIvwI1dn9HLWsqjFiMbWogGxOsoo)WGRgc9qe(CuCRS8Hy14otDnAgimSEOEpeRg3zQRrZaHby3eRSeRhA6dlHLGs(qmdGDmaVqLCC(Hbxne6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwpeZayhdWlujhNFyqSje6Hi85O4wz5dXQXDM6A0mqyy9q9EiwnUZuxJMbcdWUjwzjwp00hwclbL8Hyga7yaEHEHW2xODTYYhUAp0I6C(dRdrjGxODbT(OMkVle(c)hIy2i6dlXzeL78peBdCx5(fs4l8Fi2MSyJBD(hgCT1FyWsfm4l0lKWx4)qeMU5Ozcc9cj8f(pS0pu4Hln7MyLFiITwKLpSG(PpeBUTi)qHxCpNe8cj8f(pS0pSeZM64OFyb9tFionPPmb8c9czrDoNaO1C8wenTmbFz58enwFHSOoNta0AoElIMgwzejEQwzzIQA5zjYXrN0d7J)czrDoNaO1C8wennSYiIQYe6X2O0xilQZ5eaTMJ3IOPHvgrQ1jTnARtR5Or0KolC5aG1wFOk34otDnAgqo8k11O5eViYnjlRXDM6A0mWzczC0iTopjPTrJ24OtgnAwBko5fYI6CobqR54TiAAyLrKit0XQjKTP0xNwZrJOjDw4YbaRT(qvoC1QSRasKDnDujX6DYCH34otDnAgqo8k11O5eViYn5f6fYI6CojSYikE4UYDIq)0xiH)dXMVhA0zt(qZLpebT5Rk8PoRc)WveEHWpKDEzyIW7pej)q55yPpuEpuPpKhsD9dPvT8CtEOihnCc)WrXs(qr(H6DpKqZwwY)qZLpej)WO5yPpSzto18pebT5RQhsOXXHAIpueNIIaEHSOoNtcRmI028vf(uNvzC0jc9txFOkhUAnAwbdjrRA55(fs4l8FyjEUA5FiLfhh9dZF49dLhUO(qCxN6dZF4pKUHIFinC9Hcpm5Cthh9dx96(q(q5H0x)Hx)WH6HkD(HX7QYdP)WH8q9Uhwph9d17HsUA5FiLfhh9dZF49dlXF4Ik4Hy7up0pNF4r9qLot4hgpxo6Co5HwZp0eR8d17HlS(qKJsF8hQ05hgOupKWXZLKhwzgPLF9hQ05hsMLhszrM8W8hE)Ws8hUO(qdxVftNOvR5bVqcFH)dTOoNtcRmICgj1H7YuZKRIIxFOkto8Q44sGZiPoCxMAMCvuComfXPOanto30XrNSUpKaCAzzX7QYdPdAMCUPJJozDFibnVyJtcjqPYYuRrZkqNfoPxsoCObwnmEHSOoNtcRmIIwTMSOoNNQdrx3TfUS2JlGvY6eTNOwoW6dv54HIDZvGG89yEU4Dv5H0bgHgh10rLu6Cc5uLGMxSXj5I3vLhsh0m5CthhDY6(qcAEXgNKLfE8qXU5kqq(Empx8UQ8q6aJqJJA6OskDoHCQsqZl24KxilQZ5KWkJOOvRjlQZ5P6q01DBHlhLKxilQZ5KWkJOOvRjlQZ5P6q01DBHlt01jAprTCG1hQYwuhuCIDEzysObFHSOoNtcRmIIwTMSOoNNQdrx3TfUCSYgkEDI2tulhy9HQSf1bfNyNxgMesGxOxilQZ5equskBEKjAB1u0Q11hQYX7QYdPdezIownHSnLoO5fBCsicxPEHSOoNtarjjSYiIAAwSENC9HQC8UQ8q6arMOJvtiBtPdAEXgNeIWvQxilQZ5equscRmIe5MWTGXrV(qvgtrCkkaYPkteAtpkbGtlll84HIDZvGpOPRjkJZjItrbmcnoQPJkP05eYPkb40YjItrbezIownHSnLoaNgg5WKAqtxtnVyJtcjExvEiDGi3eUfmoAGeVnDopmjEB6CEwgMQ1OzfqNTQshqlQHkCRLLfUAv2vGGPw5onorhpQyGrwM4ri5Og001uZl24KqdiCVqwuNZjGOKewzejwVtMOW78RpuLXueNIcGCQYeH20Jsa40YYcpEOy3Cf4dA6AIY4CI4uuaJqJJA6OskDoHCQsaoTCI4uuarMOJvtiBtPdWPHromPg001uZl24KqI3vLhshiwVtMOW78ajEB6CEys82058SmmvRrZkGoBvLoGwudv4wlllC1QSRabtTYDACIoEuXaJSmXJqYrnOPRPMxSXjHgy1EHSOoNtarjjSYiQoOPRKKWB4s0lSRVqwuNZjGOKewzer70581hQYI4uuaJqJJA6OskDoHCQsaoTSmXJqYrnOPRPMxSXjHgC1EHEHSOoNtaXkBO4YgHgh10rLu6Cc5uLRpuLdVTrMyuSRatkjag7drjzzTnYeJIDfysjb08InojKYbkvwMf1bfNyNxgMes52gzIrXUcmPKaIhURLOGVqwuNZjGyLnuCyLrKO1ISmrOF66X8XkNuRrZkPCG1hQY0yfSyJdeXPOaun7RsEaoTC0yfSyJdeXPOaun7RsEqZl24KqlJokdt0ArwMi0pnHUTiNOX9CYSmrCkkaYPkteAtpkbGtlxKU1OzsIQTOoNB1qcaWg5ACNPUgndOAd9c7kjDujLoN4QK7K5ALBYlKf15CciwzdfhwzeTGx1Hq)01hQYOJYstJvWInoqeNIciYgrtXkBOyqZl24Kqkfi4AVqwuNZjGyLnuCyLrKGPwte6NU(qvUXDM6A0mG2HhPNoQuBRY1jQ2qVWUsYjItrbOQwEUjPfRfaWP9czrDoNaIv2qXHvgruvlplte6NU(qvUXDM6A0mG2HhPNoQuBRY1jQ2qVWUsEHSOoNtaXkBO4WkJi16K2gT1hQYnUZuxJMbKdVsDnAoXlICtYPwN02ObAEXgNek6Omx8UQ8q6aQQ1mO5fBCsOOJYxilQZ5eqSYgkoSYiIQAnV(qvwToPTrdGtlxJ7m11Oza5WRuxJMt8Ii3KxilQZ5eqSYgkoSYisYMspfPBcABz9HQm1fXjHfnIMAgn7HsDrCcyXW(lKf15CciwzdfhwzeHCQYeH20JswFOkhEBJmXOyxbMusam2hIsYYABKjgf7kWKscO5fBCsiLduQSmlQdkoXoVmmjKYTnYeJIDfysjbepCxlrbFHSOoNtaXkBO4WkJirRfzzIq)01J5JvoPwJMvs5aRpuLPWR1uZr6wJMt6SWHIokZfVRkpKoqKj6y1eY2u6GMxSXjzzX7QYdPdezIownHSnLoO5fBCsObcgg6OmNAv2vajYUMoQKy9o5lKf15CciwzdfhwzejYeDSAczBk91hQYH32itmk2vGjLeaJ9HOKSS2gzIrXUcmPKaAEXgNes51YYSOoO4e78YWKqk32itmk2vGjLeq8WDTef8fYI6CobeRSHIdRmIAMCUPJJozDFixFOkhEBJmXOyxbMusam2hIsYYABKjgf7kWKscO5fBCsiLxllZI6GItSZldtcPCBJmXOyxbMusaXd31suWxilQZ5eqSYgkoSYiIO2cnwYRpuLfXPOagHgh10rLu6Cc5uLaCAzzIhHKJAqtxtnVyJtcnWAVqwuNZjGyLnuCyLresBQJJozDFixFOktJvWInoqeNIcq1SVk5bnVyJtcHXohXvoPZc)czrDoNaIv2qXHvgruvlplte6N(czrDoNaIv2qXHvgrcMAnrOF6lKf15CciwzdfhwzefPplg3wIq)0xilQZ5eqSYgkoSYisSENKqNLVqwuNZjGyLnuCyLrKLwWBj3PJkf7dj5fYI6CobeRSHIdRmIeTUn086dvzAScwSXbI4uuaQM9vjpO5fBCsim25iUYjDw4xilQZ5eqSYgkoSYisWuRP4TSyUC9HQm1fXjHepIgMf15CWcEvhc9tbXJOVqwuNZjGyLnuCyLrKOHoDujTNOaY6dvzrCkkGit0XQjKTP0bYdPNLjEesoQbnDn18Inoj01EHSOoNtaXkBO4WkJi50CsKnI(czrDoNaIv2qXHvgrIwlYYeH(PRhZhRCsTgnRKYbwFOkRwJMvGolCsVKC4qXwzzr6wJMjjQ2I6CUvdjaiyU45s8rbI17Kvw1Xr)czrDoNaIv2qXHvgrXtSTeH(PRpuLPUiobOZcN0lTyypu0rzjk4lKf15CciwzdfhwzePwN02OT(qvUXDM6A0mGC4vQRrZjErKBswwJ7m11OzGZeY4OrADEssBJgTXrNmA0S2uCYlKf15Cciwzdfhwzer1mVkJJoPTrB9HQCJ7m11OzGZeY4OrADEssBJgTXrNmA0S2uCYlKf15CciwzdfhwzezD0CoPx3SRRpuLXK6I4KWOUiob0mA2dt4kfgHsDrCcyXW(l0lKf15CcGOLncnoQPJkP05eYPkxFOkhEBJmXOyxbMusam2hIsYYcVTrMyuSRatkjaCA5WSTrMyuSRatkjajEB6CEyTnYeJIDfysjbmEOblvwgMTnYeJIDfysjbepCxlhix8qXU5kqq(EmhdmYYABKjgf7kWKscaNwU2gzIrXUcmPKaAEXgNesaS1lKf15CcGOHvgrIwlYYeH(PRpuLPXkyXghiItrbOA2xL8aCA5OXkyXghiItrbOA2xL8GMxSXjHwgDugMO1ISmrOFAcDBrorJ75KzzI4uuaKtvMi0MEucaNwUiDRrZKevBrDo3QHeaGnY14otDnAgq1g6f2vs6OskDoXvj3jZ1k3KxilQZ5eardRmIuRtAB0wFOk34otDnAgqo8k11O5eViYnjNADsBJgO5fBCsOOJYCX7QYdPdOQwZGMxSXjHIokFHSOoNtaenSYiIQAnVEDCofLLdU26dvz16K2gnaoTCnUZuxJMbKdVsDnAoXlICtEHSOoNtaenSYisSENKqNLVqwuNZjaIgwzeHCQYeH20JswFOkhEBJmXOyxbMusam2hIsYYcVTrMyuSRatkjaCA5ABKjgf7kWKscqI3MoNhwBJmXOyxbMusaJhAWsLL12itmk2vGjLeaoTCTnYeJIDfysjb08InojKayRxilQZ5eardRmIOQwEwMi0p9fYI6Cobq0WkJibtTMi0p9fYI6Cobq0WkJiK2uhhDY6(qU(qvMgRGfBCGioffGQzFvYdAEXgNecJDoIRCsNfohMX7QYdPdAMCUPJJozDFibnVyJtcfDuMdZWvRYUcyStREKbfNi0pnlteNIciwVtwXjkaNggzzHhpuSBUceKVhZXiltTgnRaDw4KEj5WHU2lKf15CcGOHvgrIwlYYeH(PRpuLJ3vLhshiYeDSAczBkDqZl24KqdeSefPBnAMKOAlQZ5wnm0rzo1QSRasKDnDujX6DYSmk8An1CKU1O5KolCOOJYCX7QYdPdezIownHSnLoO5fBCswMAnAwb6SWj9sYHdfB9czrDoNaiAyLrKKnLEks3e02Y6dvzQlItclAen1mA2dL6I4eWIH9xilQZ5eardRmIiQTqJL86dvzrCkkGrOXrnDujLoNqovjaNwwMAnAwb6SWj9sYHdnWAVqwuNZjaIgwzezPf8wYD6OsX(qsEHSOoNtaenSYiQzY5Moo6K19HC9HQmMI4uuarMOJvtiBtPdWPLLPwJMvGolCsVKC4qdukmYHz4TnYeJIDfysjbWyFikjll82gzIrXUcmPKaWPLdZ2gzIrXUcmPKaK4TPZ5H12itmk2vGjLeW4HgSuzzTnYeJIDfysjbepCxlhaJSS2gzIrXUcmPKaWPLRTrMyuSRatkjGMxSXjHeaBHXlKf15CcGOHvgrImrhRMq2MsF9HQmMX7QYdPdqovzIqB6rjGMxSXjHeyTSS4HIDZvGG89yEomJ3vLhsh0m5CthhDY6(qcAEXgNe6AzzX7QYdPdAMCUPJJozDFibnVyJtcjyPWiltTgnRaDw4KEj5WHgyTSmmdpEOy3Cf4dA6AIY4CHhpuSBUceKVhZXaJCygEBJmXOyxbMusam2hIsYYcVTrMyuSRatkjaCA5WSTrMyuSRatkjajEB6CEyTnYeJIDfysjbmEOblvwwBJmXOyxbMusaXd31YbWilRTrMyuSRatkjaCA5ABKjgf7kWKscO5fBCsibWwy8czrDoNaiAyLruK(SyCBjc9tFHSOoNtaenSYisWuRP4TSyU8fYI6Cobq0WkJirdD6OsAprbK1hQYI4uuarMOJvtiBtPdKhsplt8iKCudA6AQ5fBCsOR9czrDoNaiAyLrKCAojYgrFHSOoNtaenSYikEITLi0pD9HQmMuxeNu64r0WOUiob0mA2lrygVRkpKoqWuRP4TSyUe08InoP0bWielQZ5abtTMI3YI5sq8iAww8UQ8q6abtTMI3YI5sqZl24Kqceg6OeJSmmfXPOaImrhRMq2MshGtllteNIc4mHmoAKwNNK02OrBC0jJgnRnfNaWPHrUWBCNPUgndwvgTQL4ML4EcP1PRLCNLjEesoQbnDn18InojuH7fYI6Cobq0WkJirRfzzIq)01hQYI4uuaKtvMi0MEucaNwwwKU1OzsIQTOoNB1qcacMlEUeFuGy9ozLvDC0VqwuNZjaIgwzezD0CordVs41hQYI4uuarMOJvtiBtPdKhsplt8iKCudA6AQ5fBCsOR9czrDoNaiAyLrKADsBJ26dv5g3zQRrZaYHxPUgnN4frUjzznUZuxJMbotiJJgP15jjTnA0ghDYOrZAtXjVqwuNZjaIgwzer1mVkJJoPTrB9HQCJ7m11OzGZeY4OrADEssBJgTXrNmA0S2uCYlKf15CcGOHvgrwhnNt61n766dvzmPUiojmQlItanJM9WcSggHsDrCcyXW(l0lKf15Ccq7XfWkPmkRhtSYR72cxMK3JjCARJYQ4CzrCkkqZKZnDC0jR7djaNwwMioffWi04OMoQKsNtiNQeGt7fYI6CobO94cyLewzeHY6XeR86UTWLjAFo6ejVht40whLvX5YXdf7MRab57X8CI4uuGMjNB64Otw3hsaoTCI4uuaJqJJA6OskDoHCQsaoTSSWJhk2nxbcY3J55eXPOagHgh10rLu6Cc5uLaCAVqwuNZjaThxaRKWkJiuwpMyLx3TfUmr7ZrNi59yQ5fBCY6hTYewhQ1JNlhDoVC8qXU5kqq(EmFDuwfNlhVRkpKoOzY5Moo6K19He08InojuSTX7QYdPdmcnoQPJkP05eYPkbnVyJtwhLvX5exjC54Dv5H0bgHgh10rLu6Cc5uLGMxSXjRpuLfXPOagHgh10rLu6Cc5uLa5H0FHSOoNtaApUawjHvgrOSEmXkVUBlCzI2NJorY7XuZl24K1pALjSouRhpxo6CE54HIDZvGG89y(6OSkoxoExvEiDqZKZnDC0jR7djO5fBCY6OSkoN4kHlhVRkpKoWi04OMoQKsNtiNQe08Inoz9HQSioffWi04OMoQKsNtiNQeGt7fYI6CobO94cyLewzeHY6XeR86UTWLj59yQ5fBCY6hTYewhQ1JNlhDoVC8qXU5kqq(EmFDuwfNlhVRkpKoOzY5Moo6K19He08InojeSTX7QYdPdmcnoQPJkP05eYPkbnVyJtwhLvX5exjC54Dv5H0bgHgh10rLu6Cc5uLGMxSXjVqwuNZjaThxaRKWkJiCcNgLxiRtQNskR94cynW6dvzm1ECbSccaOBKeoHtI4uuzzXdf7MRab57X8CApUawbba0nskExvEiDmYHjkRhtSYaI2NJorY7XeoTCygE8qXU5kqq(Empx4ApUawbbb0nscNWjrCkQSS4HIDZvGG89yEUW1ECbScccOBKu8UQ8q6zzApUawbbbX7QYdPdAEXgNKLP94cyfeaq3ijCcNeXPOYHz4ApUawbbb0nscNWjrCkQSmThxaRGaG4Dv5H0bs82058qkR94cyfeeeVRkpKoqI3MoNJrwM2JlGvqaaDJKI3vLhspx4ApUawbbb0nscNWjrCkQCApUawbbaX7QYdPdK4TPZ5Huw7XfWkiiiExvEiDGeVnDohJSSWrz9yIvgq0(C0jsEpMWPLdZW1ECbScccOBKeoHtI4uu5Wu7XfWkiaiExvEiDGeVnDoV0RfkkRhtSYasEpMAEXgNKLHY6XeRmGK3JPMxSXjHO94cyfeaeVRkpKoqI3MoNV6cIrwM2JlGvqqaDJKWjCseNIkhMApUawbba0nscNWjrCkQCApUawbbaX7QYdPdK4TPZ5Huw7XfWkiiiExvEiDGeVnDophMApUawbbaX7QYdPdK4TPZ5LETqrz9yIvgqY7XuZl24KSmuwpMyLbK8Em18InojeThxaRGaG4Dv5H0bs82058vxqmYYWmCThxaRGaa6gjHt4KiofvwM2JlGvqqq8UQ8q6ajEB6CEiL1ECbSccaI3vLhshiXBtNZXihMApUawbbbX7QYdPdA2K5ZP94cyfeeeVRkpKoqI3MoNx61cbL1JjwzajVhtnVyJtYHY6XeRmGK3JPMxSXjHQ94cyfeeeVRkpKoqI3MoNV6cMLfU2JlGvqqq8UQ8q6GMnz(CyQ94cyfeeeVRkpKoO5fBCsPxluuwpMyLbeTphDIK3JPMxSXj5qz9yIvgq0(C0jsEpMAEXgNesWsLdtThxaRGaG4Dv5H0bs82058sVwOOSEmXkdi59yQ5fBCswM2JlGvqqq8UQ8q6GMxSXjLETqrz9yIvgqY7XuZl24KCApUawbbbX7QYdPdK4TPZ5LoqPcdL1JjwzajVhtnVyJtcfL1Jjwzar7ZrNi59yQ5fBCswgkRhtSYasEpMAEXgNeI2JlGvqaq8UQ8q6ajEB6C(QlywgkRhtSYasEpMWPHrwM2JlGvqqq8UQ8q6GMxSXjLETqqz9yIvgq0(C0jsEpMAEXgNKdtThxaRGaG4Dv5H0bs82058sVwOOSEmXkdiAFo6ejVhtnVyJtYYcx7XfWkiaGUrs4eojItrLdtuwpMyLbK8Em18InojeThxaRGaG4Dv5H0bs82058vxWSmuwpMyLbK8EmHtddmWadmWiltTgnRaDw4KEj5WHIY6XeRmGK3JPMxSXjyKLfU2JlGvqaaDJKWjCseNIkx4Xdf7MRab57X8CyQ94cyfeeq3ijCcNeXPOYHjMHJY6XeRmGK3JjCAzzApUawbbbX7QYdPdAEXgNeYAyKdtuwpMyLbK8Em18InojKGLklt7XfWkiiiExvEiDqZl24KsVwiOSEmXkdi59yQ5fBCcgyKLfU2JlGvqqaDJKWjCseNIkhMHR94cyfeeq3iP4Dv5H0ZY0ECbScccI3vLhsh08Inojlt7XfWkiiiExvEiDGeVnDopKYApUawbbaX7QYdPdK4TPZ5yGXlKf15Ccq7XfWkjSYicNWPr5fY6K6PKYApUawdU(qvgtThxaRGGa6gjHt4Kiofvww8qXU5kqq(EmpN2JlGvqqaDJKI3vLhshJCyIY6XeRmGO95OtK8EmHtlhMHhpuSBUceKVhZZfU2JlGvqaaDJKWjCseNIkllEOy3CfiiFpMNlCThxaRGaa6gjfVRkpKEwM2JlGvqaq8UQ8q6GMxSXjzzApUawbbb0nscNWjrCkQCygU2JlGvqaaDJKWjCseNIklt7XfWkiiiExvEiDGeVnDopKYApUawbbaX7QYdPdK4TPZ5yKLP94cyfeeq3iP4Dv5H0ZfU2JlGvqaaDJKWjCseNIkN2JlGvqqq8UQ8q6ajEB6CEiL1ECbSccaI3vLhshiXBtNZXillCuwpMyLbeTphDIK3JjCA5WmCThxaRGaa6gjHt4Kiofvom1ECbScccI3vLhshiXBtNZl9AHIY6XeRmGK3JPMxSXjzzOSEmXkdi59yQ5fBCsiApUawbbbX7QYdPdK4TPZ5RUGyKLP94cyfeaq3ijCcNeXPOYHP2JlGvqqaDJKWjCseNIkN2JlGvqqq8UQ8q6ajEB6CEiL1ECbSccaI3vLhshiXBtNZZHP2JlGvqqq8UQ8q6ajEB6CEPxluuwpMyLbK8Em18InojldL1JjwzajVhtnVyJtcr7XfWkiiiExvEiDGeVnDoF1feJSmmdx7XfWkiiGUrs4eojItrLLP94cyfeaeVRkpKoqI3MoNhszThxaRGGG4Dv5H0bs8205CmYHP2JlGvqaq8UQ8q6GMnz(CApUawbbaX7QYdPdK4TPZ5LETqqz9yIvgqY7XuZl24KCOSEmXkdi59yQ5fBCsOApUawbbaX7QYdPdK4TPZ5RUGzzHR94cyfeaeVRkpKoOztMphMApUawbbaX7QYdPdAEXgNu61cfL1Jjwzar7ZrNi59yQ5fBCsouwpMyLbeTphDIK3JPMxSXjHeSu5Wu7XfWkiiiExvEiDGeVnDoV0RfkkRhtSYasEpMAEXgNKLP94cyfeaeVRkpKoO5fBCsPxluuwpMyLbK8Em18InojN2JlGvqaq8UQ8q6ajEB6CEPduQWqz9yIvgqY7XuZl24Kqrz9yIvgq0(C0jsEpMAEXgNKLHY6XeRmGK3JPMxSXjHO94cyfeeeVRkpKoqI3MoNV6cMLHY6XeRmGK3JjCAyKLP94cyfeaeVRkpKoO5fBCsPxleuwpMyLbeTphDIK3JPMxSXj5Wu7XfWkiiiExvEiDGeVnDoV0RfkkRhtSYaI2NJorY7XuZl24KSSW1ECbScccOBKeoHtI4uu5WeL1JjwzajVhtnVyJtcr7XfWkiiiExvEiDGeVnDoF1fmldL1JjwzajVht40WadmWadmYYuRrZkqNfoPxsoCOOSEmXkdi59yQ5fBCcgzzHR94cyfeeq3ijCcNeXPOYfE8qXU5kqq(EmphMApUawbba0nscNWjrCkQCyIz4OSEmXkdi59ycNwwM2JlGvqaq8UQ8q6GMxSXjHSgg5WeL1JjwzajVhtnVyJtcjyPYY0ECbSccaI3vLhsh08InoP0RfckRhtSYasEpMAEXgNGbgzzHR94cyfeaq3ijCcNeXPOYHz4ApUawbba0nskExvEi9SmThxaRGaG4Dv5H0bnVyJtYY0ECbSccaI3vLhshiXBtNZdPS2JlGvqqq8UQ8q6ajEB6CogySli044ELGRjCBDR7na]] )

end
