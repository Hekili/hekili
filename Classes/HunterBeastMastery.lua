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


    spec:RegisterPack( "Beast Mastery", 20220305, [[d8K08bqiQOEKOk4sQisBsu5tqjJcs5uqQwLOkYROs1SGa3sfHDb8liKHjQshJkSmQKNrqX0evvUMkkBdcsFdcIgheQKZbHQwheuVJGsvnpQuUNe1(OI8piuPoOkIOfcLYdHqzIqOcUOOkQpsqjgjeQqNKGszLeKzkQk3ecv0ovr6NIQqdLGsLLsqj9ujmvvu9vveHXsq1zHGWEvP)kYGbDyklMqpMQMmrxg1MrYNHIrJuDAPwnbLQ8AcmBjDBvy3c)wvdhPCCve1Yv8CetN01HQTdjFhIgpuQoVez9IQQMVOSFL(64E(TqAkFp1vED5kVctEpd4qyeM8l)YVBHwIgFlOzEbgg(we2bFlWgBeDHionIYtPBbnRu9n598Bb5XhpFlORknccJieHPv64Ia)FGisFGxnT)WpgLIisF4r0TqeVRQWwCfVfst57PUYRlx5vyY7zahcJWKF5NRBHHR0)5wu0hi2TGElLCCfVfsM4VfyJnIUqeNgr5P0crCepuEwHqCAJN(cpdbl0vED5AfAfcXOBbgMGWRqNyHcR8j4WeR8cXMnISCHf0FDHclJ55fkSJN(LGvOtSWtcRRDGzHf0FDH40KMYeWTO2eLCp)wizkdVQ3ZVN64E(TW8A)XTW)4HYtIq)1BbhMyLLxSD17PUUNFl4WeRS8ITBH51(JBHowCY4DTZ)oWKi0F9wizIFAAA)XTqy5xOrNn5cTqUWZhloz8U25pVWtf2HylKd(OzccwisEHYpWsxO8xOsVjlK6NfsRAL4HSqr2B4eEHTILCHI8c1)xiHMDCuAHwixisEHElWsx4WMSRLw45JfN8cj0yFt1(fkItrra3c)0kpTDlCEHQnyyf0KeTQvINREpvyUNFl4WeRS8ITBHFALN2Uf(hfhwOabLM2IfMBH()RYhzamcn2RPNkP05eYUkbdFyDqwyUf6)VkFKbyyYhM2bMKnZJem8H1bzHzzl05f6FuCyHceuAAlwyUf6)VkFKbWi0yVMEQKsNti7Qem8H1b5wq0P969uh3cZR9h3cVvRjZR9hPAt0BrTjAkSd(wOthcyLC17P5398BbhMyLLxSDlmV2FCl8wTMmV2FKQnrVf1MOPWo4BHxsU690ZUNFl4WeRS8ITBHFALN2UfMxBuCId(OzYcDBHUUfeDAVEp1XTW8A)XTWB1AY8A)rQ2e9wuBIMc7GVfe9Q3trO3ZVfCyIvwEX2TWpTYtB3cZRnkoXbF0mzHoTqh3cIoTxVN64wyET)4w4TAnzET)ivBIElQnrtHDW3cFLnu8vV6TG2W()q00753tDCp)wyET)4wqWpo(irJ1BbhMyLLxSD17PUUNFlmV2FCleFvRSmrvTsSezhys6J9oUfCyIvwEX2vVNkm3ZVfMx7pUfuvMq3pgLEl4WeRS8ITREpn)UNFl4WeRS8ITBbTH9grtAFW3chGZUfMx7pUfQnjDmA3c)0kpTDlg8GP(bddipEL6hmCIpe5Ha4WeRSCHzzlCWdM6hmmiycPdmiTPejPJrJwhysgnA2ykobWHjwz5vVNE298BbhMyLLxSDlOnS3iAs7d(w4aC2TW8A)XTqKjAB1eYXu63c)0kpTDlCEHQv5qbephA6PsI1)LaomXklxyUf68ch8GP(bddipEL6hmCIpe5Ha4WeRS8Qx9w4LK753tDCp)wWHjwz5fB3c)0kpTDl8)xLpYaiYeTTAc5ykDWWhwhKf60cfM8ElmV2FClSWZeDSAYB16vVN66E(TGdtSYYl2Uf(PvEA7w4)VkFKbqKjAB1eYXu6GHpSoil0Pfkm59wyET)4wq1dlw)xE17PcZ98BbhMyLLxSDl8tR802TaTfkItrbq2vzIqRNwjaCAlmlBHoVq)JIdluq0yORjkJxyUfkItrbmcn2RPNkP05eYUkb40wyUfkItrbezI2wnHCmLoaN2crFH5wiAlKQXqxtdFyDqwOtl0)Fv(idGipeEe0bgGeFmT)yHUVqj(yA)XcZYwiAluTbdRa6Svv6aAEDHUTqH5SfMLTqNxOAvouGGUw5j1br7WRaomXklxi6le9fMLTqXNqwyUfs1yORPHpSoil0Tf6qyUfMx7pUfI8q4rqhyU69087E(TGdtSYYl2Uf(PvEA7wG2cfXPOai7QmrO1tReaoTfMLTqNxO)rXHfkiAm01eLXlm3cfXPOagHg710tLu6CczxLaCAlm3cfXPOaImrBRMqoMshGtBHOVWCleTfs1yORPHpSoil0Pf6)VkFKbqS(VmrHpLas8X0(Jf6(cL4JP9hlmlBHOTq1gmScOZwvPdO51f62cfMZwyw2cDEHQv5qbc6ALNuheTdVc4WeRSCHOVq0xyw2cfFczH5wivJHUMg(W6GSq3wOde6TW8A)XTqS(VmrHpLU690ZUNFlmV2FClQng6kjjShUeZbh6TGdtSYYl2U69ue698BbhMyLLxSDl8tR802TqeNIcyeASxtpvsPZjKDvcWPTWSSfk(eYcZTqQgdDnn8H1bzHUTqxi0BH51(JBbTx7pU6vVf60Hawj3ZVN64E(TGdtSYYl2UfpTBbH1BH51(JBbkBAtSY3cuwfNVfI4uuGHjFyAhys2mpsaoTfMLTqrCkkGrOXEn9ujLoNq2vjaN2TaLnPWo4BbPu4t40U69ux3ZVfCyIvwEX2T4PDliSElmV2FClqztBIv(wGYQ48TW)O4WcfiO00wSWClueNIcmm5dt7atYM5rcWPTWClueNIcyeASxtpvsPZjKDvcWPTWSSf68c9pkoSqbcknTflm3cfXPOagHg710tLu6CczxLaCA3cu2Kc7GVfeD(atIuk8jCAx9EQWCp)wWHjwz5fB3IN2TGWAtDlmV2FClqztBIv(wGYMuyh8TGOZhysKsHpn8H1b5w4Nw5PTBHioffWi0yVMEQKsNti7QeiFKXTaLvX5exj8TW)Fv(idGrOXEn9ujLoNq2vjy4dRdYTaLvX5BH))Q8rgGHjFyAhys2mpsWWhwhKf6gI7f6)VkFKbWi0yVMEQKsNti7Qem8H1b5Q3tZV753comXklVy7w80UfewBQBH51(JBbkBAtSY3cu2Kc7GVfeD(atIuk8PHpSoi3c)0kpTDleXPOagHg710tLu6CczxLaCA3cuwfNtCLW3c))v5JmagHg710tLu6CczxLGHpSoi3cuwfNVf()RYhzagM8HPDGjzZ8ibdFyDqU690ZUNFl4WeRS8ITBXt7wqyTPUfMx7pUfOSPnXkFlqztkSd(wqkf(0WhwhKBHFALN2Uf(hfhwOabLM2IBbkRIZjUs4BH))Q8rgaJqJ9A6PskDoHSRsWWhwhKBbkRIZ3c))v5Jmadt(W0oWKSzEKGHpSoil0je3l0)Fv(idGrOXEn9ujLoNq2vjy4dRdYvVNIqVNFl4WeRS8ITBH51(JBHoDiGvh3c)0kpTDlqBHOTqD6qaRa1bGUrs4eojItrTWSSf6FuCyHceuAAlwyUfQthcyfOoa0nsY)Fv(iJfI(cZTq0wikBAtSYaIoFGjrkf(eoTfMBHOTqNxO)rXHfkqqPPTyH5wOZluNoeWkqDbOBKeoHtI4uulmlBH(hfhwOabLM2IfMBHoVqD6qaRa1fGUrs()RYhzSWSSfQthcyfOUa()RYhzag(W6GSWSSfQthcyfOoa0nscNWjrCkQfMBHOTqNxOoDiGvG6cq3ijCcNeXPOwyw2c1PdbScuha))v5Jmas8X0(Jf6u5fQthcyfOUa()RYhzaK4JP9hle9fMLTqD6qaRa1bGUrs()RYhzSWCl05fQthcyfOUa0nscNWjrCkQfMBH60HawbQdG))Q8rgaj(yA)XcDQ8c1PdbScuxa))v5Jmas8X0(JfI(cZYwOZleLnTjwzarNpWKiLcFcN2cZTq0wOZluNoeWkqDbOBKeoHtI4uulm3crBH60HawbQdG))Q8rgaj(yA)XcpXcpBHUTqu20MyLbKsHpn8H1bzHzzleLnTjwzaPu4tdFyDqwOtluNoeWkqDa8)xLpYaiXht7pwiIwORfI(cZYwOoDiGvG6cq3ijCcNeXPOwyUfI2c1PdbScuha6gjHt4Kiof1cZTqD6qaRa1bW)Fv(idGeFmT)yHovEH60HawbQlG))Q8rgaj(yA)XcZTq0wOoDiGvG6a4)VkFKbqIpM2FSWtSWZwOBleLnTjwzaPu4tdFyDqwyw2crztBIvgqkf(0WhwhKf60c1PdbScuha))v5Jmas8X0(JfIOf6AHOVWSSfI2cDEH60HawbQdaDJKWjCseNIAHzzluNoeWkqDb8)xLpYaiXht7pwOtLxOoDiGvG6a4)VkFKbqIpM2FSq0xyUfI2c1PdbScuxa))v5JmadBYslm3c1PdbScuxa))v5Jmas8X0(JfEIfE2cDAHOSPnXkdiLcFA4dRdYcZTqu20MyLbKsHpn8H1bzHUTqD6qaRa1fW)Fv(idGeFmT)yHiAHUwyw2cDEH60HawbQlG))Q8rgGHnzPfMBHOTqD6qaRa1fW)Fv(idWWhwhKfEIfE2cDBHOSPnXkdi68bMePu4tdFyDqwyUfIYM2eRmGOZhysKsHpn8H1bzHoTqx5DH5wiAluNoeWkqDa8)xLpYaiXht7pw4jw4zl0TfIYM2eRmGuk8PHpSoilmlBH60HawbQlG))Q8rgGHpSoil8el8Sf62crztBIvgqkf(0WhwhKfMBH60HawbQlG))Q8rgaj(yA)XcpXcDK3f6(crztBIvgqkf(0WhwhKf62crztBIvgq05dmjsPWNg(W6GSWSSfIYM2eRmGuk8PHpSoil0PfQthcyfOoa()RYhzaK4JP9hlerl01cZYwikBAtSYasPWNWPTq0xyw2c1PdbScuxa))v5JmadFyDqw4jw4zl0PfIYM2eRmGOZhysKsHpn8H1bzH5wiAluNoeWkqDa8)xLpYaiXht7pw4jw4zl0TfIYM2eRmGOZhysKsHpn8H1bzHzzl05fQthcyfOoa0nscNWjrCkQfMBHOTqu20MyLbKsHpn8H1bzHoTqD6qaRa1bW)Fv(idGeFmT)yHiAHUwyw2crztBIvgqkf(eoTfI(crFHOVq0xi6le9fMLTq1gmSc0(Gt6NKnVq3wikBAtSYasPWNg(W6GSq0xyw2cDEH60HawbQdaDJKWjCseNIAH5wOZl0)O4WcfiO00wSWCleTfQthcyfOUa0nscNWjrCkQfMBHOTq0wOZleLnTjwzaPu4t40wyw2c1PdbScuxa))v5JmadFyDqwOtl8SfI(cZTq0wikBAtSYasPWNg(W6GSqNwOR8UWSSfQthcyfOUa()RYhzag(W6GSWtSWZwOtleLnTjwzaPu4tdFyDqwi6le9fMLTqNxOoDiGvG6cq3ijCcNeXPOwyUfI2cDEH60HawbQlaDJK8)xLpYyHzzluNoeWkqDb8)xLpYam8H1bzHzzluNoeWkqDb8)xLpYaiXht7pwOtLxOoDiGvG6a4)VkFKbqIpM2FSq0xi6le9fMBHOTqNxOoDiGvG6a0eG38050tLm)jJ3dlt6WgbFyYcZYwO51gfN4GpAMSq3wORfMBHI4uuaZFY49WYeslKaCAlmlBHMxBuCId(OzYcDAHowyUf68cfXPOaM)KX7HLjKwib40wi63cs9vYTqNoeWQJREpfH8E(TGdtSYYl2UfMx7pUf60HawDDl8tR802TaTfI2c1PdbScuxa6gjHt4Kiof1cZYwO)rXHfkqqPPTyH5wOoDiGvG6cq3ij))v5Jmwi6lm3crBHOSPnXkdi68bMePu4t40wyUfI2cDEH(hfhwOabLM2IfMBHoVqD6qaRa1bGUrs4eojItrTWSSf6FuCyHceuAAlwyUf68c1PdbScuha6gj5)VkFKXcZYwOoDiGvG6a4)VkFKby4dRdYcZYwOoDiGvG6cq3ijCcNeXPOwyUfI2cDEH60HawbQdaDJKWjCseNIAHzzluNoeWkqDb8)xLpYaiXht7pwOtLxOoDiGvG6a4)VkFKbqIpM2FSq0xyw2c1PdbScuxa6gj5)VkFKXcZTqNxOoDiGvG6aq3ijCcNeXPOwyUfQthcyfOUa()RYhzaK4JP9hl0PYluNoeWkqDa8)xLpYaiXht7pwi6lmlBHoVqu20MyLbeD(atIuk8jCAlm3crBHoVqD6qaRa1bGUrs4eojItrTWCleTfQthcyfOUa()RYhzaK4JP9hl8el8Sf62crztBIvgqkf(0WhwhKfMLTqu20MyLbKsHpn8H1bzHoTqD6qaRa1fW)Fv(idGeFmT)yHiAHUwi6lmlBH60HawbQdaDJKWjCseNIAH5wiAluNoeWkqDbOBKeoHtI4uulm3c1PdbScuxa))v5Jmas8X0(Jf6u5fQthcyfOoa()RYhzaK4JP9hlm3crBH60HawbQlG))Q8rgaj(yA)XcpXcpBHUTqu20MyLbKsHpn8H1bzHzzleLnTjwzaPu4tdFyDqwOtluNoeWkqDb8)xLpYaiXht7pwiIwORfI(cZYwiAl05fQthcyfOUa0nscNWjrCkQfMLTqD6qaRa1bW)Fv(idGeFmT)yHovEH60HawbQlG))Q8rgaj(yA)XcrFH5wiAluNoeWkqDa8)xLpYamSjlTWCluNoeWkqDa8)xLpYaiXht7pw4jw4zl0PfIYM2eRmGuk8PHpSoilm3crztBIvgqkf(0WhwhKf62c1PdbScuha))v5Jmas8X0(JfIOf6AHzzl05fQthcyfOoa()RYhzag2KLwyUfI2c1PdbScuha))v5JmadFyDqw4jw4zl0TfIYM2eRmGOZhysKsHpn8H1bzH5wikBAtSYaIoFGjrkf(0WhwhKf60cDL3fMBHOTqD6qaRa1fW)Fv(idGeFmT)yHNyHNTq3wikBAtSYasPWNg(W6GSWSSfQthcyfOoa()RYhzag(W6GSWtSWZwOBleLnTjwzaPu4tdFyDqwyUfQthcyfOoa()RYhzaK4JP9hl8el0rExO7leLnTjwzaPu4tdFyDqwOBleLnTjwzarNpWKiLcFA4dRdYcZYwikBAtSYasPWNg(W6GSqNwOoDiGvG6c4)VkFKbqIpM2FSqeTqxlmlBHOSPnXkdiLcFcN2crFHzzluNoeWkqDa8)xLpYam8H1bzHNyHNTqNwikBAtSYaIoFGjrkf(0WhwhKfMBHOTqD6qaRa1fW)Fv(idGeFmT)yHNyHNTq3wikBAtSYaIoFGjrkf(0WhwhKfMLTqNxOoDiGvG6cq3ijCcNeXPOwyUfI2crztBIvgqkf(0WhwhKf60c1PdbScuxa))v5Jmas8X0(JfIOf6AHzzleLnTjwzaPu4t40wi6le9fI(crFHOVq0xyw2cvBWWkq7doPFs28cDBHOSPnXkdiLcFA4dRdYcrFHzzl05fQthcyfOUa0nscNWjrCkQfMBHoVq)JIdluGGstBXcZTq0wOoDiGvG6aq3ijCcNeXPOwyUfI2crBHoVqu20MyLbKsHpHtBHzzluNoeWkqDa8)xLpYam8H1bzHoTWZwi6lm3crBHOSPnXkdiLcFA4dRdYcDAHUY7cZYwOoDiGvG6a4)VkFKby4dRdYcpXcpBHoTqu20MyLbKsHpn8H1bzHOVq0xyw2cDEH60HawbQdaDJKWjCseNIAH5wiAl05fQthcyfOoa0nsY)Fv(iJfMLTqD6qaRa1bW)Fv(idWWhwhKfMLTqD6qaRa1bW)Fv(idGeFmT)yHovEH60HawbQlG))Q8rgaj(yA)XcrFHOVq0xyUfI2cDEH60HawbQlqtaEZtNtpvY8NmEpSmPdBe8HjlmlBHMxBuCId(OzYcDBHUwyUfkItrbm)jJ3dltiTqcWPTWSSfAETrXjo4JMjl0Pf6yH5wOZlueNIcy(tgVhwMqAHeGtBHOFli1xj3cD6qaRUU6vVfe9E(9uh3ZVfCyIvwEX2TWpTYtB3cNx4yTmXO4qbMusam2BIswyw2cDEHJ1YeJIdfysjbGtBH5wiAlCSwMyuCOatkjaj(yA)XcDFHJ1YeJIdfysjb0XcDBHUY7cZYwiAlCSwMyuCOatkja)Jh6clVqhlm3c9pkoSqbcknTfle9fI(cZYw4yTmXO4qbMusa40wyUfowltmkouGjLeWWhwhKf60cDG4VfMx7pUfgHg710tLu6CczxLx9EQR753comXklVy7w4Nw5PTBHioffGA4i)lbWPTWClueNIcqnCK)LadFyDqwOBLxigVCHUVqrBezzIq)1eMX8CIgp9lxyw2cfXPOai7QmrO1tReaoTfMBHE62GHjjQX8A)HvxOtl0bi)wyUfo4bt9dggqngMdous6PskDoXvjpjl0kpeahMyLL3cZR9h3crBezzIq)1REpvyUNFl4WeRS8ITBHFALN2UfdEWu)GHbKhVs9dgoXhI8qaCyIvwUWCluTjPJrdm8H1bzHUTqmE5cZTq))v5JmauvByWWhwhKf62cX4L3cZR9h3c1MKogTREpn)UNFl4WeRS8ITBH51(JBbv1g(w4Nw5PTBHAtshJgaN2cZTWbpyQFWWaYJxP(bdN4drEiaomXklVf1o4KxElCD2vVNE298BH51(JBHy9FjHolVfCyIvwEX2vVNIqVNFl4WeRS8ITBHFALN2UfoVWXAzIrXHcmPKayS3eLSWSSf68chRLjgfhkWKscaN2cZTWXAzIrXHcmPKaK4JP9hl09fowltmkouGjLeqhl0Tf6kVlmlBHJ1YeJIdfysjbGtBH5w4yTmXO4qbMusadFyDqwOtl0bI)wyET)4wGSRYeHwpTsU69ueY753cZR9h3cQQvILjc9xVfCyIvwEX2vVNI46E(TW8A)XTqqxRjc9xVfCyIvwEX2vVNI4VNFl4WeRS8ITBHFALN2UfI4uuaQHJ8Vey4dRdYcDAHm2zpUYjTp4fMBHOTq))v5Jmadt(W0oWKSzEKGHpSoil0TfIXlxyUfI2cDEHQv5qbm2PvFsJIte6Vc4WeRSCHzzlueNIciw)xwXjkaN2crFHzzl05f6FuCyHceuAAlwi6lmlBHQnyyfO9bN0pjBEHUTWZUfMx7pUfiTU2bMKnZJ8Q3tDK3753comXklVy7w4Nw5PTBH))Q8rgarMOTvtihtPdg(W6GSq3wOdxlmpTqpDBWWKe1yET)WQl09fIXlxyUfQwLdfq8COPNkjw)xc4WeRSCHzzlKcVwtd7PBdgoP9bVq3wigVCH5wO))Q8rgarMOTvtihtPdg(W6GSWSSfQ2GHvG2hCs)KS5f62cr83cZR9h3crBezzIq)1REp1HJ753comXklVy7w4Nw5PTBb17Xjl09f6nIMggdhl0Tfs9ECc4WW(TW8A)XTqYMsp5PBcg74Q3tD46E(TGdtSYYl2Uf(PvEA7wiItrbmcn2RPNkP05eYUkb40wyw2cvBWWkq7doPFs28cDBHoo7wyET)4wqu7Ggl5REp1HWCp)wyET)4wyPd8rYt6Ps(5rsUfCyIvwEX2vVN6i)UNFl4WeRS8ITBHFALN2UfOTqrCkkGit02QjKJP0b40wyw2cvBWWkq7doPFs28cDBHoY7crFH5wiAl05fowltmkouGjLeaJ9MOKfMLTqNx4yTmXO4qbMusa40wyUfI2chRLjgfhkWKscqIpM2FSq3x4yTmXO4qbMusaDSq3wOR8UWSSfowltmkouGjLeG)XdDHLxOJfI(cZYw4yTmXO4qbMusa40wyUfowltmkouGjLeWWhwhKf60cDG4xi63cZR9h3IHjFyAhys2mpYREp1Xz3ZVfCyIvwEX2TWpTYtB3c0wO))Q8rgaKDvMi06Pvcy4dRdYcDAHooBHzzl0)O4WcfiO00wSWCleTf6)VkFKbyyYhM2bMKnZJem8H1bzHUTWZwyw2c9)xLpYamm5dt7atYM5rcg(W6GSqNwOR8Uq0xyw2cvBWWkq7doPFs28cDBHooBHzzleTf68c9pkoSqbrJHUMOmEH5wOZl0)O4WcfiO00wSq0xi6lm3crBHoVWXAzIrXHcmPKayS3eLSWSSf68chRLjgfhkWKscaN2cZTq0w4yTmXO4qbMusas8X0(Jf6(chRLjgfhkWKscOJf62cDL3fMLTWXAzIrXHcmPKa8pEOlS8cDSq0xyw2chRLjgfhkWKscaN2cZTWXAzIrXHcmPKag(W6GSqNwOde)cr)wyET)4wiYeTTAc5yk9REp1bc9E(TW8A)XTWtVpmESeH(R3comXklVy7Q3tDGqEp)wyET)4wiOR1K)poSqEl4WeRS8ITREp1bIR753comXklVy7w4Nw5PTBHioffqKjAB1eYXu6a5Jmwyw2cfFczH5wivJHUMg(W6GSq3w4z3cZR9h3crdt6Ps60EbKREp1bI)E(TW8A)XTq2dNezJO3comXklVy7Q3tDL3753comXklVy7w4Nw5PTBbAlK694KfEIf6FIUq3xi17XjGHXWXcZtleTf6)VkFKbqqxRj)FCyHem8H1bzHNyHowi6l0PfAET)aiOR1K)poSqc8prxyw2c9)xLpYaiOR1K)poSqcg(W6GSqNwOJf6(cX4Lle9fMLTq0wOioffqKjAB1eYXu6aCAlmlBHI4uuGGjKoWG0MsKKognADGjz0OzJP4eaoTfI(cZTqNx4Ghm1pyyWjB0QwIhwIhjK2K(rYdGdtSYYfMLTqXNqwyUfs1yORPHpSoil0Tfkm3cZR9h3c)lowIq)1REp1LJ753comXklVy7w4Nw5PTBHioffazxLjcTEALaWPTWSSf6PBdgMKOgZR9hwDHoTqhaxlm3c9FiXBfiw)xwzv7adGdtSYYBH51(JBHOnISmrO)6vVN6Y198BbhMyLLxSDl8tR802TqeNIciYeTTAc5ykDG8rglmlBHIpHSWClKQXqxtdFyDqwOBl8SBH51(JBHnEl4en8kHV69uxcZ98BbhMyLLxSDl8tR802TyWdM6hmmG84vQFWWj(qKhcGdtSYYfMLTWbpyQFWWGGjKoWG0MsKKognADGjz0OzJP4eahMyLL3cZR9h3c1MKogTREp1v(Dp)wWHjwz5fB3c)0kpTDlg8GP(bddcMq6adsBkrs6y0O1bMKrJMnMItaCyIvwElmV2FClOgMZ)oWK0XOD17PUo7E(TGdtSYYl2Uf(PvEA7wG2cPEpozHUVqQ3JtadJHJf6(cDC2crFHUTqQ3Jtahg2VfMx7pUf24TGt6pdh6vV6TWxzdfFp)EQJ753comXklVy7w4Nw5PTBHZlCSwMyuCOatkjag7nrjlmlBHJ1YeJIdfysjbm8H1bzHovEHoY7cZYwO51gfN4GpAMSqNkVWXAzIrXHcmPKa8pEOlmpTqx3cZR9h3cJqJ9A6PskDoHSRYREp1198BbhMyLLxSDlmV2FCleTrKLjc9xVf(PvEA7wiItrbOgoY)saCAlm3cfXPOaudh5FjWWhwhKf6w5fIXlxO7lu0grwMi0FnHzmpNOXt)YfMLTqrCkkaYUkteA90kbGtBH5wONUnyysIAmV2Fy1f60cDaYVfMBHdEWu)GHbuJH5GdLKEQKsNtCvYtYcTYdbWHjwz5TWxYx5KAdgwj3tDC17PcZ98BbhMyLLxSDl8tR802TaJxUWtSqrCkkGiBen5RSHIbdFyDqwOtlmVaxNDlmV2FCloWRAtO)6vVNMF3ZVfCyIvwEX2TWpTYtB3IbpyQFWWaApUNE6PsJL))KOgdZbhkbWHjwz5cZTqrCkkav1kXdjDyJaaoTBH51(JBHGUwte6VE17PNDp)wWHjwz5fB3c)0kpTDlg8GP(bddO94E6PNknw()tIAmmhCOeahMyLL3cZR9h3cQQvILjc9xV69ue698BbhMyLLxSDl8tR802TyWdM6hmmG84vQFWWj(qKhcGdtSYYfMBHQnjDmAGHpSoil0TfIXlxyUf6)VkFKbGQAddg(W6GSq3wigV8wyET)4wO2K0XOD17PiK3ZVfCyIvwEX2TWpTYtB3c1MKognaoTfMBHdEWu)GHbKhVs9dgoXhI8qaCyIvwElmV2FClOQ2Wx9EkIR753comXklVy7w4Nw5PTBb17Xjl09f6nIMggdhl0Tfs9ECc4WW(TW8A)XTqYMsp5PBcg74Q3tr83ZVfCyIvwEX2TWpTYtB3cNx4yTmXO4qbMusam2BIswyw2chRLjgfhkWKscy4dRdYcDQ8cDK3fMLTqZRnkoXbF0mzHovEHJ1YeJIdfysjb4F8qxyEAHUUfMx7pUfi7QmrO1tRKREp1rEVNFl4WeRS8ITBH51(JBHOnISmrO)6TWpTYtB3ck8AnnSNUny4K2h8cDBHy8YfMBH()RYhzaezI2wnHCmLoy4dRdYcZYwO))Q8rgarMOTvtihtPdg(W6GSq3wOdxl09fIXlxyUfQwLdfq8COPNkjw)xc4WeRS8w4l5RCsTbdRK7PoU69uhoUNFl4WeRS8ITBHFALN2UfoVWXAzIrXHcmPKayS3eLSWSSfowltmkouGjLeWWhwhKf6u5fE2cZYwO51gfN4GpAMSqNkVWXAzIrXHcmPKa8pEOlmpTqx3cZR9h3crMOTvtihtPF17PoCDp)wWHjwz5fB3c)0kpTDlCEHJ1YeJIdfysjbWyVjkzHzzlCSwMyuCOatkjGHpSoil0PYl8SfMLTqZRnkoXbF0mzHovEHJ1YeJIdfysjb4F8qxyEAHUUfMx7pUfdt(W0oWKSzEKx9EQdH5E(TGdtSYYl2Uf(PvEA7wiItrbmcn2RPNkP05eYUkb40wyw2cfFczH5wivJHUMg(W6GSq3wOJZUfMx7pUfe1oOXs(Q3tDKF3ZVfCyIvwEX2TWpTYtB3crCkka1Wr(xcm8H1bzHoTqg7Shx5K2h8TW8A)XTaP11oWKSzEKx9EQJZUNFlmV2FClOQwjwMi0F9wWHjwz5fBx9EQde698BH51(JBHGUwte6VEl4WeRS8ITREp1bc598BH51(JBHNEFy8yjc9xVfCyIvwEX2vVN6aX198BH51(JBHy9FjHolVfCyIvwEX2vVN6aXFp)wyET)4wyPd8rYt6Ps(5rsUfCyIvwEX2vVN6kV3ZVfCyIvwEX2TWpTYtB3crCkka1Wr(xcm8H1bzHoTqg7Shx5K2h8TW8A)XTq0MXWWx9EQlh3ZVfCyIvwEX2TWpTYtB3cQ3JtwOtl0)eDHUVqZR9hGd8Q2e6Vc8prVfMx7pUfc6An5)JdlKx9EQlx3ZVfCyIvwEX2TWpTYtB3crCkkGit02QjKJP0bYhzSWSSfk(eYcZTqQgdDnn8H1bzHUTWZUfMx7pUfIgM0tL0P9cix9EQlH5E(TW8A)XTq2dNezJO3comXklVy7Q3tDLF3ZVfCyIvwEX2TW8A)XTq0grwMi0F9w4Nw5PTBHAdgwbAFWj9tYMxOBleXVWSSf6PBdgMKOgZR9hwDHoTqhaxlm3c9FiXBfiw)xwzv7adGdtSYYBHVKVYj1gmSsUN64Q3tDD298BbhMyLLxSDl8tR802TG694eG2hCs)0HH9f62cX4LlmpTqx3cZR9h3c)lowIq)1REp1fc9E(TGdtSYYl2Uf(PvEA7wm4bt9dggqE8k1py4eFiYdbWHjwz5cZYw4Ghm1pyyqWeshyqAtjsshJgToWKmA0SXuCcGdtSYYBH51(JBHAtshJ2vVN6cH8E(TGdtSYYl2Uf(PvEA7wm4bt9dggemH0bgK2uIK0XOrRdmjJgnBmfNa4WeRS8wyET)4wqnmN)DGjPJr7Q3tDH46E(TGdtSYYl2Uf(PvEA7wG2cPEpozHUVqQ3JtadJHJf6(cfM8Uq0xOBlK694eWHH9BH51(JBHnEl4K(ZWHE1RE1BbkEi9h3tDLxxUYRlxi0BbsBIoWqUfNeNKcRNkSDQWccVWfEoDEH9bTF0fs9ZcXI2W()q0uSw4WNmEpSCHK)GxOHR)HPSCHE6wGHjGvO81bVW8dHxiI9bkEuwUqSg8GP(bddeowlu)fI1Ghm1pyyGWbCyIvwI1cnDH558y(wiAoWo6GvO81bVW8dHxiI9bkEuwUqSg8GP(bddeowlu)fI1Ghm1pyyGWbCyIvwI1crZb2rhScLVo4fEgcVqe7du8OSCHyPwLdfiCSwO(lel1QCOaHd4WeRSeRfIMdSJoyfkFDWl8meEHi2hO4rz5cXAWdM6hmmq4yTq9xiwdEWu)GHbchWHjwzjwl00fMNZJ5BHO5a7OdwHwHojojfwpvy7uHfeEHl8C68c7dA)OlK6NfILoDiGvcwlC4tgVhwUqYFWl0W1)WuwUqpDlWWeWku(6GxicfHxiI9bkEuwUWI(aXwiPuOg2x4jDH6VW8HBlu2OAs)XcFA8y6pleneH(cr7mSJoyfkFDWleHIWleX(afpklxiw60HawboachRfQ)cXsNoeWkqDaeowlenxUWo6GvO81bVqekcVqe7du8OSCHyPthcyf4ciCSwO(lelD6qaRa1fq4yTq0CHqXo6GvO81bVqeseEHi2hO4rz5cl6deBHKsHAyFHN0fQ)cZhUTqzJQj9hl8PXJP)Sq0qe6leTZWo6GvO81bVqeseEHi2hO4rz5cXsNoeWkWbq4yTq9xiw60HawbQdGWXAHO5cHID0bRq5RdEHiKi8crSpqXJYYfILoDiGvGlGWXAH6VqS0PdbScuxaHJ1crZLlSJoyfAf6K4Kuy9uHTtfwq4fUWZPZlSpO9JUqQFwiwEjbRfo8jJ3dlxi5p4fA46FyklxONUfyycyfkFDWluyq4fIyFGIhLLlel1QCOaHJ1c1FHyPwLdfiCahMyLLyTq0CGD0bRq5RdEH5hcVqe7du8OSCHyPwLdfiCSwO(lel1QCOaHd4WeRSeRfIMdSJoyfAf6K4Kuy9uHTtfwq4fUWZPZlSpO9JUqQFwiwefRfo8jJ3dlxi5p4fA46FyklxONUfyycyfkFDWl0fcVqe7du8OSCHyn4bt9dggiCSwO(leRbpyQFWWaHd4WeRSeRfA6cZZ5X8Tq0CGD0bRq5RdEHUq4fIyFGIhLLlelASceoaHaaayTq9xiwieaaaRfIMlSJoyfkFDWluyq4fIyFGIhLLleRbpyQFWWaHJ1c1FHyn4bt9dggiCahMyLLyTq0CGD0bRq5RdEH5hcVqe7du8OSCHyn4bt9dggiCSwO(leRbpyQFWWaHd4WeRSeRfA6cZZ5X8Tq0CGD0bRq5RdEHiEeEHi2hO4rz5cXsTkhkq4yTq9xiwQv5qbchWHjwzjwlenhyhDWku(6GxiIhHxiI9bkEuwUqSOXkq4aecaaG1c1FHyHqaaaSwiAoWo6GvO81bVqh5fHxiI9bkEuwUqSuRYHceowlu)fILAvouGWbCyIvwI1crZb2rhScLVo4f6kVi8crSpqXJYYfI1Ghm1pyyGWXAH6VqSg8GP(bddeoGdtSYsSwiAoWo6GvO81bVqxoq4fIyFGIhLLlel)hs8wbchRfQ)cXY)HeVvGWbCyIvwI1cnDH558y(wiAoWo6GvO81bVqxcdcVqe7du8OSCHyn4bt9dggiCSwO(leRbpyQFWWaHd4WeRSeRfA6cZZ5X8Tq0CGD0bRq5RdEHUegeEHi2hO4rz5cXAWdM6hmmq4yTq9xiwdEWu)GHbchWHjwzjwlenhyhDWku(6GxOR8dHxiI9bkEuwUqSg8GP(bddeowlu)fI1Ghm1pyyGWbCyIvwI1cnDH558y(wiAoWo6GvOvOtItsH1tf2ovybHx4cpNoVW(G2p6cP(zHy5RSHIXAHdFY49WYfs(dEHgU(hMYYf6PBbgMawHYxh8cDHWleX(afpklxiwdEWu)GHbchRfQ)cXAWdM6hmmq4aomXklXAHMUW8CEmFlenhyhDWku(6GxOleEHi2hO4rz5cXIgRaHdqiaaawlu)fIfcbaaWAHO5c7OdwHYxh8cfgeEHi2hO4rz5cXIgRaHdqiaaawlu)fIfcbaaWAHO5a7OdwHYxh8cZpeEHi2hO4rz5cXAWdM6hmmq4yTq9xiwdEWu)GHbchWHjwzjwlenhyhDWku(6Gx4zi8crSpqXJYYfI1Ghm1pyyGWXAH6VqSg8GP(bddeoGdtSYsSwOPlmpNhZ3crZb2rhScLVo4fIqr4fIyFGIhLLleRbpyQFWWaHJ1c1FHyn4bt9dggiCahMyLLyTq0CGD0bRq5RdEHiKi8crSpqXJYYfI1Ghm1pyyGWXAH6VqSg8GP(bddeoGdtSYsSwOPlmpNhZ3crZb2rhScLVo4f6iVi8crSpqXJYYfILAvouGWXAH6VqSuRYHceoGdtSYsSwOPlmpNhZ3crZb2rhScLVo4f6i)q4fIyFGIhLLlelASceoaHaaayTq9xiwieaaaRfIMdSJoyfkFDWl0vEr4fIyFGIhLLlelASceoaHaaayTq9xiwieaaaRfIMdSJoyfkFDWl0v(HWleX(afpklxiw(pK4Tceowlu)fIL)djERaHd4WeRSeRfA6cZZ5X8Tq0CGD0bRq5RdEHUqOi8crSpqXJYYfI1Ghm1pyyGWXAH6VqSg8GP(bddeoGdtSYsSwOPlmpNhZ3crZb2rhScLVo4f6cHIWleX(afpklxiwdEWu)GHbchRfQ)cXAWdM6hmmq4aomXklXAHO5a7OdwHYxh8cDHqIWleX(afpklxiwdEWu)GHbchRfQ)cXAWdM6hmmq4aomXklXAHMUW8CEmFlenhyhDWk0kKW2bTFuwUqe6cnV2FSWAtucyf6wqOX(7PUotyUf0MNQR8TipKhwi2yJOleXPruEkTqehXdLNvO8qEyHioTXtFHNHGf6kVUCTcTcLhYdleXOBbgMGWRq5H8WcpXcfw5tWHjw5fInBez5clO)6cfwgZZluyhp9lbRq5H8WcpXcpjSU2bMfwq)1fIttAktaRqRqMx7piaAd7)drtltWpo(irJ1viZR9heaTH9)HOPUxgrIVQvwMOQwjwISdmj9XEhRqMx7piaAd7)drtDVmIOQmHUFmkDfY8A)bbqBy)FiAQ7LrKAtshJgcOnS3iAs7dUSdWziOPkp4bt9dggqE8k1py4eFiYdjlBWdM6hmmiycPdmiTPejPJrJwhysgnA2ykozfY8A)bbqBy)FiAQ7LrKit02QjKJP0raTH9grtAFWLDaodbnvzNvRYHciEo00tLeR)lZ58Ghm1pyya5XRu)GHt8HipKvOviZR9he3lJi)Jhkpjc9xxHYdluy5xOrNn5cTqUWZhloz8U25pVWtf2HylKd(OzIW(lejVq5hyPlu(luP3Kfs9ZcPvTs8qwOi7nCcVWwXsUqrEH6)lKqZookTqlKlejVqVfyPlCyt21sl88XItEHeASVPA)cfXPOiGviZR9he3lJiDS4KX7AN)DGjrO)kcAQYoR2GHvqts0QwjEwHYd5HfI4axTslKY8DGzHLE8zHYhxuxiEODDHLE8fs3qXlKgUUqHvM8HPDGzHNKZ8ixO8rgiyH)SWMAHkDEH()RYhzSWMSq9)fw)aZc1FHsUALwiL57aZcl94ZcrC4XfvWcf2Owy8bVWNAHkDMWl0)HS1(dYcTHxOjw5fQ)cpyDHiBLEhluPZl0rExiH9FijlSYmsRecwOsNxiPpwiL5zYcl94ZcrC4Xf1fA46FyA7TATeyfkpKhwO51(dI7LruWiPE8qMgM8vumcAQYKhVk2HeemsQhpKPHjFffNdnrCkkWWKpmTdmjBMhjaNwwM))Q8rgGHjFyAhys2mpsWWhwheNCK3Sm1gmSc0(Gt6NKn7Mdek6RqMx7piUxgrERwtMx7ps1MOiiSdUSoDiGvcci60ETSde0uL9pkoSqbcknTf58)xLpYayeASxtpvsPZjKDvcg(W6GKZ)Fv(idWWKpmTdmjBMhjy4dRdswMZ(hfhwOabLM2IC()RYhzamcn2RPNkP05eYUkbdFyDqwHmV2FqCVmI8wTMmV2FKQnrrqyhCzVKSczET)G4Eze5TAnzET)ivBIIGWo4YefbeDAVw2bcAQYMxBuCId(OzIBUwHmV2FqCVmI8wTMmV2FKQnrrqyhCzFLnumci60ETSde0uLnV2O4eh8rZeNCScTczET)Ga8sszl8mrhRM8wTIGMQS))Q8rgarMOTvtihtPdg(W6G4KWK3viZR9heGxsCVmIO6HfR)lrqtv2)Fv(idGit02QjKJP0bdFyDqCsyY7kK51(dcWljUxgrI8q4rqhyqqtvgnrCkkaYUkteA90kbGtllZz)JIdluq0yORjkJZjItrbmcn2RPNkP05eYUkb40YjItrbezI2wnHCmLoaNg65qJQXqxtdFyDqCY)Fv(idGipeEe0bgGeFmT)WDj(yA)rwgAQnyyfqNTQshqZRUjmNLL5SAvouGGUw5j1br7WROJEwM4ti5OAm010Whwhe3CimRqMx7piaVK4Ezejw)xMOWNsiOPkJMioffazxLjcTEALaWPLL5S)rXHfkiAm01eLX5eXPOagHg710tLu6CczxLaCA5eXPOaImrBRMqoMshGtd9COr1yORPHpSoio5)VkFKbqS(VmrHpLas8X0(d3L4JP9hzzOP2GHvaD2QkDanV6MWCwwMZQv5qbc6ALNuheTdVIo6zzIpHKJQXqxtdFyDqCZbcDfY8A)bb4Le3lJOAJHUssc7HlXCWHUczET)Ga8sI7LreTx7pqqtvweNIcyeASxtpvsPZjKDvcWPLLj(esoQgdDnn8H1bXnxi0vOviZR9heGVYgkUSrOXEn9ujLoNq2vjcAQYopwltmkouGjLeaJ9MOKSSXAzIrXHcmPKag(W6G4uzh5nlZ8AJItCWhntCQ8yTmXO4qbMusa(hp08KRviZR9heGVYgk29Yis0grwMi0Ffb(s(kNuBWWkPSde0uLPXk4W6aiItrbOgoY)saCA5OXk4W6aiItrbOgoY)sGHpSoiUvgJx6UOnISmrO)AcZyEorJN(LzzI4uuaKDvMi06PvcaNwopDBWWKe1yET)WQo5aKF5g8GP(bddOgdZbhkj9ujLoN4QKNKfALhYkK51(dcWxzdf7EzeDGx1Mq)ve0uLX4LNGgRGdRdGioffqKnIM8v2qXGHpSoioLxGRZwHmV2Fqa(kBOy3lJibDTMi0Ffbnv5bpyQFWWaApUNE6PsJL))KOgdZbhkjNioffGQAL4HKoSraaN2kK51(dcWxzdf7EzervTsSmrO)kcAQYdEWu)GHb0ECp90tLgl))jrngMdouYkK51(dcWxzdf7EzeP2K0XOHGMQ8Ghm1pyya5XRu)GHt8HipKCQnjDmAGHpSoiUHXlZ5)VkFKbGQAddg(W6G4ggVCfY8A)bb4RSHIDVmIOQ2WiOPkR2K0XObWPLBWdM6hmmG84vQFWWj(qKhYkK51(dcWxzdf7EzejztPN80nbJDGGMQm17XjU7nIMggdhUr9ECc4WW(kK51(dcWxzdf7EzeHSRYeHwpTsqqtv25XAzIrXHcmPKayS3eLKLnwltmkouGjLeWWhwheNk7iVzzMxBuCId(OzItLhRLjgfhkWKscW)4HMNCTczET)Ga8v2qXUxgrI2iYYeH(RiWxYx5KAdgwjLDGGMQmfETMg2t3gmCs7d2nmEzo))v5JmaImrBRMqoMshm8H1bjlZ)Fv(idGit02QjKJP0bdFyDqCZHl3X4L5uRYHciEo00tLeR)lxHmV2Fqa(kBOy3lJirMOTvtihtPJGMQSZJ1YeJIdfysjbWyVjkjlBSwMyuCOatkjGHpSoiov(SSmZRnkoXbF0mXPYJ1YeJIdfysjb4F8qZtUwHmV2Fqa(kBOy3lJOHjFyAhys2mpse0uLDESwMyuCOatkjag7nrjzzJ1YeJIdfysjbm8H1bXPYNLLzETrXjo4JMjovESwMyuCOatkja)JhAEY1kK51(dcWxzdf7Ezeru7Gglze0uLfXPOagHg710tLu6CczxLaCAzzIpHKJQXqxtdFyDqCZXzRqMx7piaFLnuS7LresRRDGjzZ8irqtvMgRGdRdGioffGA4i)lbg(W6G4eJD2JRCs7dEfY8A)bb4RSHIDVmIOQwjwMi0FDfY8A)bb4RSHIDVmIe01AIq)1viZR9heGVYgk29YiYtVpmESeH(RRqMx7piaFLnuS7LrKy9FjHolxHmV2Fqa(kBOy3lJilDGpsEspvYppsYkK51(dcWxzdf7EzejAZyyye0uLPXk4W6aiItrbOgoY)sGHpSoioXyN94kN0(GxHmV2Fqa(kBOy3lJibDTM8)XHfse0uLPEpoXj)tu3nV2FaoWRAtO)kW)eDfY8A)bb4RSHIDVmIenmPNkPt7fqqqtvweNIciYeTTAc5ykDG8rgzzIpHKJQXqxtdFyDqC7SviZR9heGVYgk29Yis2dNezJORqMx7piaFLnuS7LrKOnISmrO)kc8L8voP2GHvszhiOPkR2GHvG2hCs)KSz3q8zzE62GHjjQX8A)HvDYbWvo)hs8wbI1)Lvw1oWSczET)Ga8v2qXUxgr(xCSeH(RiOPkt9ECcq7doPF6WWUBy8Y8KRviZR9heGVYgk29YisTjPJrdbnv5bpyQFWWaYJxP(bdN4drEizzdEWu)GHbbtiDGbPnLijDmA06atYOrZgtXjRqMx7piaFLnuS7Lre1WC(3bMKogne0uLh8GP(bddcMq6adsBkrs6y0O1bMKrJMnMItwHmV2Fqa(kBOy3lJiB8wWj9NHdfbnvz0OEpoXDQ3JtadJHd3fM8IUBuVhNaomSVcTczET)GaiAzJqJ9A6PskDoHSRse0uLDESwMyuCOatkjag7nrjzzopwltmkouGjLeaoTCOnwltmkouGjLeGeFmT)W9XAzIrXHcmPKa6Wnx5nldTXAzIrXHcmPKa8pEOLDKZ)O4WcfiO00wGo6zzJ1YeJIdfysjbGtl3yTmXO4qbMusadFyDqCYbIFfY8A)bbqu3lJirBezzIq)ve0uLPXk4W6aiItrbOgoY)saCA5OXk4W6aiItrbOgoY)sGHpSoiUvgJx6UOnISmrO)AcZyEorJN(LzzI4uuaKDvMi06PvcaNwopDBWWKe1yET)WQo5aKF5g8GP(bddOgdZbhkj9ujLoN4QKNKfALhYkK51(dcGOUxgrQnjDmAiOPkp4bt9dggqE8k1py4eFiYdjNAtshJgy4dRdIBy8YC()RYhzaOQ2WGHpSoiUHXlxHmV2Fqae19YiIQAdJGAhCYll76me0uLvBs6y0a40Yn4bt9dggqE8k1py4eFiYdzfY8A)bbqu3lJiX6)scDwUczET)GaiQ7LreYUkteA90kbbnvzNhRLjgfhkWKscGXEtuswMZJ1YeJIdfysjbGtl3yTmXO4qbMusas8X0(d3hRLjgfhkWKscOd3CL3SSXAzIrXHcmPKaWPLBSwMyuCOatkjGHpSoio5aXVczET)GaiQ7Lrev1kXYeH(RRqMx7piaI6EzejOR1eH(RRqMx7piaI6EzeH06Ahys2mpse0uLPXk4W6aiItrbOgoY)sGHpSoioXyN94kN0(GZHM))Q8rgGHjFyAhys2mpsWWhwhe3W4L5qZz1QCOag70QpPrXjc9xZYeXPOaI1)LvCIcWPHEwMZ(hfhwOabLM2c0ZYuBWWkq7doPFs2SBNTczET)GaiQ7LrKOnISmrO)kcAQY()RYhzaezI2wnHCmLoy4dRdIBoCLN80TbdtsuJ51(dR6ogVmNAvouaXZHMEQKy9FzwgfETMg2t3gmCs7d2nmEzo))v5JmaImrBRMqoMshm8H1bjltTbdRaTp4K(jzZUH4xHmV2Fqae19YisYMsp5PBcg7abnvzQ3JtC3BennmgoCJ694eWHH9viZR9hearDVmIiQDqJLmcAQYI4uuaJqJ9A6PskDoHSRsaoTSm1gmSc0(Gt6NKn7MJZwHmV2Fqae19YiYsh4JKN0tL8ZJKSczET)GaiQ7Lr0WKpmTdmjBMhjcAQYOjItrbezI2wnHCmLoaNwwMAdgwbAFWj9tYMDZrErphAopwltmkouGjLeaJ9MOKSmNhRLjgfhkWKscaNwo0gRLjgfhkWKscqIpM2F4(yTmXO4qbMusaD4MR8MLnwltmkouGjLeG)XdTSd0ZYgRLjgfhkWKscaNwUXAzIrXHcmPKag(W6G4Kdep6RqMx7piaI6EzejYeTTAc5ykDe0uLrZ)Fv(idaYUkteA90kbm8H1bXjhNLL5FuCyHceuAAlYHM))Q8rgGHjFyAhys2mpsWWhwhe3ollZ)Fv(idWWKpmTdmjBMhjy4dRdItUYl6zzQnyyfO9bN0pjB2nhNLLHMZ(hfhwOGOXqxtugNZz)JIdluGGstBb6ONdnNhRLjgfhkWKscGXEtuswMZJ1YeJIdfysjbGtlhAJ1YeJIdfysjbiXht7pCFSwMyuCOatkjGoCZvEZYgRLjgfhkWKscW)4Hw2b6zzJ1YeJIdfysjbGtl3yTmXO4qbMusadFyDqCYbIh9viZR9hearDVmI807dJhlrO)6kK51(dcGOUxgrc6An5)JdlKRqMx7piaI6EzejAyspvsN2lGGGMQSioffqKjAB1eYXu6a5JmYYeFcjhvJHUMg(W6G42zRqMx7piaI6Ezej7HtISr0viZR9hearDVmI8V4yjc9xrqtvgnQ3JtoH)jQ7uVhNaggdh5j08)xLpYaiOR1K)poSqcg(W6GCchO7K51(dGGUwt()4WcjW)enlZ)Fv(idGGUwt()4Wcjy4dRdItoChJxIEwgAI4uuarMOTvtihtPdWPLLjItrbcMq6adsBkrs6y0O1bMKrJMnMIta40qpNZdEWu)GHbNSrRAjEyjEKqAt6hjpzzIpHKJQXqxtdFyDqCtywHmV2Fqae19Yis0grwMi0FfbnvzrCkkaYUkteA90kbGtllZt3gmmjrnMx7pSQtoaUY5)qI3kqS(VSYQ2bMviZR9hearDVmISXBbNOHxjmcAQYI4uuarMOTvtihtPdKpYilt8jKCung6AA4dRdIBNTczET)GaiQ7LrKAtshJgcAQYdEWu)GHbKhVs9dgoXhI8qYYg8GP(bddcMq6adsBkrs6y0O1bMKrJMnMItwHmV2Fqae19YiIAyo)7atshJgcAQYdEWu)GHbbtiDGbPnLijDmA06atYOrZgtXjRqMx7piaI6EzezJ3coP)mCOiOPkJg17XjUt9ECcyymC4UJZq3nQ3Jtahg2xHwHmV2Fqa60HawjLrztBIvgbHDWLjLcFcNgcqzvCUSioffyyYhM2bMKnZJeGtllteNIcyeASxtpvsPZjKDvcWPTczET)Ga0PdbSsCVmIqztBIvgbHDWLj68bMePu4t40qakRIZL9pkoSqbcknTf5eXPOadt(W0oWKSzEKaCA5eXPOagHg710tLu6CczxLaCAzzo7FuCyHceuAAlYjItrbmcn2RPNkP05eYUkb40wHmV2Fqa60HawjUxgrOSPnXkJGWo4YeD(atIuk8PHpSoii4PvMWAtHa)hYw7pk7FuCyHceuAAlqakRIZL9)xLpYamm5dt7atYM5rcg(W6G4gIB))v5JmagHg710tLu6CczxLGHpSoiiaLvX5exjCz))v5JmagHg710tLu6CczxLGHpSoiiOPklItrbmcn2RPNkP05eYUkbYhzSczET)Ga0PdbSsCVmIqztBIvgbHDWLj68bMePu4tdFyDqqWtRmH1Mcb(pKT2Fu2)O4WcfiO00wGauwfNl7)VkFKbyyYhM2bMKnZJem8H1bbbOSkoN4kHl7)VkFKbWi0yVMEQKsNti7Qem8H1bbbnvzrCkkGrOXEn9ujLoNq2vjaN2kK51(dcqNoeWkX9YicLnTjwzee2bxMuk8PHpSoii4PvMWAtHa)hYw7pk7FuCyHceuAAlqakRIZL9)xLpYamm5dt7atYM5rcg(W6G4eIB))v5JmagHg710tLu6CczxLGHpSoiiaLvX5exjCz))v5JmagHg710tLu6CczxLGHpSoiRqMx7piaD6qaRe3lJiCcNALpiiGuFLuwNoeWQde0uLrdnD6qaRaha6gjHt4KiofvwM)rXHfkqqPPTiNoDiGvGdaDJK8)xLpYa9COHYM2eRmGOZhysKsHpHtlhAo7FuCyHceuAAlY5SoDiGvGlaDJKWjCseNIklZ)O4WcfiO00wKZzD6qaRaxa6gj5)VkFKrwMoDiGvGlG))Q8rgGHpSoizz60Hawboa0nscNWjrCkQCO5SoDiGvGlaDJKWjCseNIkltNoeWkWbW)Fv(idGeFmT)WPY60HawbUa()RYhzaK4JP9hONLPthcyf4aq3ij))v5JmY5SoDiGvGlaDJKWjCseNIkNoDiGvGdG))Q8rgaj(yA)HtL1PdbScCb8)xLpYaiXht7pqplZzu20MyLbeD(atIuk8jCA5qZzD6qaRaxa6gjHt4Kiofvo00PdbScCa8)xLpYaiXht7poXzUHYM2eRmGuk8PHpSoizzOSPnXkdiLcFA4dRdIt60Hawboa()RYhzaK4JP9hNuxONLPthcyf4cq3ijCcNeXPOYHMoDiGvGdaDJKWjCseNIkNoDiGvGdG))Q8rgaj(yA)HtL1PdbScCb8)xLpYaiXht7pYHMoDiGvGdG))Q8rgaj(yA)XjoZnu20MyLbKsHpn8H1bjldLnTjwzaPu4tdFyDqCsNoeWkWbW)Fv(idGeFmT)4K6c9Sm0CwNoeWkWbGUrs4eojItrLLPthcyf4c4)VkFKbqIpM2F4uzD6qaRaha))v5Jmas8X0(d0ZHMoDiGvGlG))Q8rgGHnzPC60HawbUa()RYhzaK4JP9hN4mNqztBIvgqkf(0WhwhKCOSPnXkdiLcFA4dRdIB60HawbUa()RYhzaK4JP9hNuxzzoRthcyf4c4)VkFKbyytwkhA60HawbUa()RYhzag(W6GCIZCdLnTjwzarNpWKiLcFA4dRdsou20MyLbeD(atIuk8PHpSoio5kV5qtNoeWkWbW)Fv(idGeFmT)4eN5gkBAtSYasPWNg(W6GKLPthcyf4c4)VkFKby4dRdYjoZnu20MyLbKsHpn8H1bjNoDiGvGlG))Q8rgaj(yA)XjCKx3rztBIvgqkf(0Whwhe3qztBIvgq05dmjsPWNg(W6GKLHYM2eRmGuk8PHpSoioPthcyf4a4)VkFKbqIpM2FCsDLLHYM2eRmGuk8jCAONLPthcyf4c4)VkFKby4dRdYjoZju20MyLbeD(atIuk8PHpSoi5qtNoeWkWbW)Fv(idGeFmT)4eN5gkBAtSYaIoFGjrkf(0WhwhKSmN1PdbScCaOBKeoHtI4uu5qdLnTjwzaPu4tdFyDqCsNoeWkWbW)Fv(idGeFmT)4K6kldLnTjwzaPu4t40qhD0rhD0ZYuBWWkq7doPFs2SBOSPnXkdiLcFA4dRdc6zzoRthcyf4aq3ijCcNeXPOY5S)rXHfkqqPPTihA60HawbUa0nscNWjrCkQCOHMZOSPnXkdiLcFcNwwMoDiGvGlG))Q8rgGHpSoioDg65qdLnTjwzaPu4tdFyDqCYvEZY0PdbScCb8)xLpYam8H1b5eN5ekBAtSYasPWNg(W6GGo6zzoRthcyf4cq3ijCcNeXPOYHMZ60HawbUa0nsY)Fv(iJSmD6qaRaxa))v5JmadFyDqYY0PdbScCb8)xLpYaiXht7pCQSoDiGvGdG))Q8rgaj(yA)b6OJEo0CwNoeWkWbOjaV5PZPNkz(tgVhwM0Hnc(WKSmZRnkoXbF0mXnx5eXPOaM)KX7HLjKwib40YYmV2O4eh8rZeNCKZzrCkkG5pz8EyzcPfsaon0xHmV2Fqa60HawjUxgr4eo1kFqqaP(kPSoDiGvxiOPkJgA60HawbUa0nscNWjrCkQSm)JIdluGGstBroD6qaRaxa6gj5)VkFKb65qdLnTjwzarNpWKiLcFcNwo0C2)O4WcfiO00wKZzD6qaRaha6gjHt4KiofvwM)rXHfkqqPPTiNZ60Hawboa0nsY)Fv(iJSmD6qaRaha))v5JmadFyDqYY0PdbScCbOBKeoHtI4uu5qZzD6qaRaha6gjHt4KiofvwMoDiGvGlG))Q8rgaj(yA)HtL1PdbScCa8)xLpYaiXht7pqpltNoeWkWfGUrs()RYhzKZzD6qaRaha6gjHt4KiofvoD6qaRaxa))v5Jmas8X0(dNkRthcyf4a4)VkFKbqIpM2FGEwMZOSPnXkdi68bMePu4t40YHMZ60Hawboa0nscNWjrCkQCOPthcyf4c4)VkFKbqIpM2FCIZCdLnTjwzaPu4tdFyDqYYqztBIvgqkf(0WhwheN0PdbScCb8)xLpYaiXht7poPUqpltNoeWkWbGUrs4eojItrLdnD6qaRaxa6gjHt4KiofvoD6qaRaxa))v5Jmas8X0(dNkRthcyf4a4)VkFKbqIpM2FKdnD6qaRaxa))v5Jmas8X0(JtCMBOSPnXkdiLcFA4dRdswgkBAtSYasPWNg(W6G4KoDiGvGlG))Q8rgaj(yA)Xj1f6zzO5SoDiGvGlaDJKWjCseNIkltNoeWkWbW)Fv(idGeFmT)WPY60HawbUa()RYhzaK4JP9hONdnD6qaRaha))v5JmadBYs50PdbScCa8)xLpYaiXht7poXzoHYM2eRmGuk8PHpSoi5qztBIvgqkf(0Whwhe30PdbScCa8)xLpYaiXht7poPUYYCwNoeWkWbW)Fv(idWWMSuo00PdbScCa8)xLpYam8H1b5eN5gkBAtSYaIoFGjrkf(0WhwhKCOSPnXkdi68bMePu4tdFyDqCYvEZHMoDiGvGlG))Q8rgaj(yA)XjoZnu20MyLbKsHpn8H1bjltNoeWkWbW)Fv(idWWhwhKtCMBOSPnXkdiLcFA4dRdsoD6qaRaha))v5Jmas8X0(Jt4iVUJYM2eRmGuk8PHpSoiUHYM2eRmGOZhysKsHpn8H1bjldLnTjwzaPu4tdFyDqCsNoeWkWfW)Fv(idGeFmT)4K6kldLnTjwzaPu4t40qpltNoeWkWbW)Fv(idWWhwhKtCMtOSPnXkdi68bMePu4tdFyDqYHMoDiGvGlG))Q8rgaj(yA)XjoZnu20MyLbeD(atIuk8PHpSoizzoRthcyf4cq3ijCcNeXPOYHgkBAtSYasPWNg(W6G4KoDiGvGlG))Q8rgaj(yA)Xj1vwgkBAtSYasPWNWPHo6OJo6ONLP2GHvG2hCs)KSz3qztBIvgqkf(0Whwhe0ZYCwNoeWkWfGUrs4eojItrLZz)JIdluGGstBro00PdbScCaOBKeoHtI4uu5qdnNrztBIvgqkf(eoTSmD6qaRaha))v5JmadFyDqC6m0ZHgkBAtSYasPWNg(W6G4KR8MLPthcyf4a4)VkFKby4dRdYjoZju20MyLbKsHpn8H1bbD0ZYCwNoeWkWbGUrs4eojItrLdnN1PdbScCaOBKK))Q8rgzz60Hawboa()RYhzag(W6GKLPthcyf4a4)VkFKbqIpM2F4uzD6qaRaxa))v5Jmas8X0(d0rh9CO5SoDiGvGlqtaEZtNtpvY8NmEpSmPdBe8HjzzMxBuCId(OzIBUYjItrbm)jJ3dltiTqcWPLLzETrXjo4JMjo5iNZI4uuaZFY49WYeslKaCAOF1REVa]] )

end
