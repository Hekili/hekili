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


    spec:RegisterGear( "tier28", 188861, 188860, 188859, 188858, 188856 )
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


    spec:RegisterPack( "Beast Mastery", 20211227, [[d8eSbcqiQepIks6sQsvAtsKpbv1OGsDkOkRsur5vujnlvjDlvjAxG(feYWev4yuHLjQ6zeqnniu11GG2MQuvFJkszCurcNdkPADqO8oOKKAEIkDpjQ9rf1)OIe5GIkslekXdvLktecv6IIkQ(ivKQrsfjQtcLuALeOzQkHBcLKKDQkLFkQigkusILcLu8urzQqGVQkvXyPI4SqOI9QQ(Ridg4WuwmHEmvnzIUmQnJuFgsnAOYPLA1qjPEnbnBjDBvXUf(TkdhsoousSCfphX0jDDKSDO47q04jaNNk16jGmFjSFL(74JGFM0u()w(CKpFoCKJ8qhofiENMaJ1)zQBu8pdL5fAO5Fwyp8pdlSr0fGvLruEC)ZqzURNj)i4NroQXZ)mCQIIGyicrOBfhLi0FpiI0puvt7l8JrRiI0pEe9ZeP6QI1gFXFM0u()w(CKpFoCKJ8qhofiENwoCk(zgLI7MFww)8UFgUwk54l(ZKmX)ZWcBeDbyvzeLh3lWPmvO8ScI4YE(rKNfK3P96cYNJ8owbxbFholqZeeBf8LlaRHFjhMyLxawSrKLlid3PlWPpMNxawfE6tcxbF5cEpwx7a9cYWD6cOqjnLjWFwTjk5JGFMKPnQQ(rW)nhFe8ZmV2x8Z8hvO8Ki4o9NXHjwz5hlF9)w(pc(zCyIvw(XYpZ8AFXpthlWkuDTfOoqNi4o9NjzIFAuAFXpZPFlWWXMCbwixacglWkuDTfiEbVHv5DlGd(PzYRlajVa5f4RlqElqX1KfqFZcqvn38qwGi7nkcVGwXxUarEb6DlGGYEECValKlajVaVf4Rlyyt2v3labJfyLfqqX(MU9lqKIMMa)z(PvEA7N5YcuBqZkSjjuvZnpF9)Ma)rWpJdtSYYpw(z(PvEA7N5pmCyHcf6EAlwqPf4VRkpKb0iOyVMo6KIJti7Qeo8J1bzbLwG)UQ8qgWHjxyAhOt2mhs4WpwhKfuuSaxwG)WWHfkuO7PTybLwG)UQ8qgqJGI9A6OtkooHSRs4WpwhKFgrN2R)3C8ZmV2x8Z8wTMmV2xKQnr)z1MOPWE4FMoDiKvYx)VH4)i4NXHjwz5hl)mZR9f)mVvRjZR9fPAt0FwTjAkSh(N5LKV(FdHFe8Z4WeRS8JLFMFALN2(zMxBmCId(PzYcYDb5)zeDAV(FZXpZ8AFXpZB1AY8AFrQ2e9NvBIMc7H)ze9R)3E)pc(zCyIvw(XYpZpTYtB)mZRngoXb)0mzboVah)mIoTx)V54NzETV4N5TAnzETVivBI(ZQnrtH9W)mFLnm8x)6pd1W(7r00pc(V54JGFM51(IFgH655Iekw)zCyIvw(XYx)VL)JGFM51(IFM4PALLj6Q5MLi7aDspb0XpJdtSYYpw(6)nb(JGFM51(IFgDLj48JrR)momXkl)y5R)3q8Fe8Z4WeRS8JLFwyp8pZeicoBmsI(cnD0juhsE(zMx7l(zMarWzJrs0xOPJoH6qYZx)VHWpc(zCyIvw(XYpd1WEJOjTF4FMdic)zMx7l(zQnjDmu)m)0kpT9ZgQGPVbndjhvL(g0CIFe5Ha5WeRSCbfflyOcM(g0mmycPd0iTXnjPJHcvhOtgku2ykfbYHjwz5x)V9(Fe8Z4WeRS8JLFgQH9grtA)W)mhqe(ZmV2x8ZezI2wnHCmf3pZpTYtB)mxwGAvouiXZHMo6Ky9ojKdtSYYfuAbUSGHky6BqZqYrvPVbnN4hrEiqomXkl)6)nN2hb)momXkl)y5NHAyVr0K2p8pZbuG)zsM4NgL2x8ZYPsSAkIswGIJxGKAmTVybwixG)UQ8qgl4OxqoLGI96co6fO44f8E6QCbwixawLPFS6cWAdI2Hxjlq09cuC8cKuJP9fl4OxGflGkWzeLLlWP)oe3fGehhlqXXUXF4fqry5cqnS)EenfUaSWEJIWliNsqXEDbh9cuC8cEpDvUGHLuEMSaN(7qCxGO7fKph54H86cuCnzbnzboGc8ciS)cjb(ZmV2x8Zmck2RPJoP44eYUk)z(PvEA7N5YcmbINwziQPFSAQdI2HxjqomXklxqPf4YcycHdpdzcHdpNo6KIJt0NNI0b6upnb(yy13SGsla7fWyfQgfkwcnbIGZgJKOVqthDc1HKNfuuSaxwaJvOAuOyj072xpDUO9jXQr0fG3x)V5u8rWpJdtSYYpw(zOg2BenP9d)ZCar4ptYe)0O0(IFwovIvtruYcuC8cKuJP9flWc5c83vLhYybh9cWct02Ql49mMIBbwixGtztG4fC0laRXqZlq09cuC8cKuJP9fl4OxGflGkWzeLLlWP)oe3fGehhlqXXUXF4fqry5cqnS)Eenf(ZmV2x8ZezI2wnHCmf3pZpTYtB)mtG4PvgIA6hRM6GOD4vcKdtSYYfuAbUSaMq4WZqMq4WZPJoP44e95PiDGo1ttGpgw9nlO0cWEbmwHQrHILqtGi4SXij6l00rNqDi5zbfflWLfWyfQgfkwc9U91tNlAFsSAeDb491V(Z8sYhb)3C8rWpJdtSYYpw(z(PvEA7N5VRkpKbuKjAB1eYXuCWHFSoilW5fiW54NzETV4NzHNj6y1K3Q1V(Fl)hb)momXkl)y5N5Nw5PTFM)UQ8qgqrMOTvtihtXbh(X6GSaNxGaNJFM51(IFgDpSy9o5x)VjWFe8Z4WeRS8JLFMFALN2(zyVarkAAiYUkteu90kbsHAbfflWLf4pmCyHcJgnonrB8ckTarkAAOrqXEnD0jfhNq2vjKc1ckTarkAAOit02QjKJP4GuOwaElO0cWEb0nACAA4hRdYcCEb(7QYdzaf5HWJWoqdLuJP9flW1fiPgt7lwqrXcWEbQnOzfIJTQIdIYRli3fiWiCbfflWLfOwLdfkSRvEsDq0o8kKdtSYYfG3cWBbfflq8iKfuAb0nACAA4hRdYcYDboe4FM51(IFMipeEe2b6V(FdX)rWpJdtSYYpw(z(PvEA7NH9cePOPHi7Qmrq1tReifQfuuSaxwG)WWHfkmA040eTXlO0cePOPHgbf710rNuCCczxLqkulO0cePOPHImrBRMqoMIdsHAb4TGsla7fq3OXPPHFSoilW5f4VRkpKbuSENmrtnUHsQX0(If46cKuJP9flOOybyVa1g0ScXXwvXbr51fK7ceyeUGIIf4YcuRYHcf21kpPoiAhEfYHjwz5cWBb4TGIIfiEeYckTa6gnonn8J1bzb5UahV)pZ8AFXptSENmrtnU)6)ne(rWpZ8AFXpR2OXPKewnLe9dh6pJdtSYYpw(6)T3)JGFghMyLLFS8Z8tR802ptKIMgAeuSxthDsXXjKDvcPqTGIIfq3OXPPHFSoili3fK)9)zMx7l(zOoTV4RF9NPthczL8rW)nhFe8Z4WeRS8JLF2H6Nry9NzETV4NHXM2eR8pdJvP4FMifnnCyYfM2b6KnZHesHAbfflqKIMgAeuSxthDsXXjKDvcPq9ZWytkSh(NrCh(efQV(Fl)hb)momXkl)y5NDO(zew)zMx7l(zySPnXk)ZWyvk(N5pmCyHcf6EAlwqPfisrtdhMCHPDGozZCiHuOwqPfisrtdnck2RPJoP44eYUkHuOwqrXcCzb(ddhwOqHUN2IfuAbIu00qJGI9A6OtkooHSRsifQFggBsH9W)mIoxGorCh(efQV(FtG)i4NXHjwz5hl)Sd1pJWAt)ZmV2x8ZWytBIv(NHXMuyp8pJOZfOte3Hpn8J1b5N5Nw5PTFMifnn0iOyVMo6KIJti7QekpKXpdJvP4exj8pZFxvEidOrqXEnD0jfhNq2vjC4hRdYpdJvP4FM)UQ8qgWHjxyAhOt2mhs4WpwhKfKRtPf4VRkpKb0iOyVMo6KIJti7Qeo8J1b5R)3q8Fe8Z4WeRS8JLF2H6NryTP)zMx7l(zySPnXk)ZWytkSh(Nr05c0jI7WNg(X6G8Z8tR802ptKIMgAeuSxthDsXXjKDvcPq9ZWyvkoXvc)Z83vLhYaAeuSxthDsXXjKDvch(X6G8ZWyvk(N5VRkpKbCyYfM2b6KnZHeo8J1b5R)3q4hb)momXkl)y5NDO(zewB6FM51(IFggBAtSY)mm2Kc7H)ze3Hpn8J1b5N5Nw5PTFM)WWHfkuO7PT4NHXQuCIRe(N5VRkpKb0iOyVMo6KIJti7Qeo8J1b5NHXQu8pZFxvEid4WKlmTd0jBMdjC4hRdYcC2P0c83vLhYaAeuSxthDsXXjKDvch(X6G81)BV)hb)momXkl)y5NzETV4NPthcz1XpZpTYtB)mSxGoDiKvO6aIZijkcNePOPxqrXc8hgoSqHcDpTflO0c0PdHScvhqCgj5VRkpKXcWBbLwa2laJnTjwzirNlqNiUdFIc1ckTaSxGllWFy4Wcfk090wSGslWLfOthczfQ5H4msIIWjrkA6fuuSa)HHdluOq3tBXckTaxwGoDiKvOMhIZij)Dv5HmwqrXc0PdHSc18q)Dv5HmGd)yDqwqrXc0PdHScvhqCgjrr4Kifn9ckTaSxGllqNoeYkuZdXzKefHtIu00lOOyb60HqwHQdO)UQ8qgqj1yAFXcCU8c0PdHSc18q)Dv5HmGsQX0(IfG3ckkwGoDiKvO6aIZij)Dv5HmwqPf4Yc0PdHSc18qCgjrr4Kifn9ckTaD6qiRq1b0FxvEidOKAmTVyboxEb60HqwHAEO)UQ8qgqj1yAFXcWBbfflWLfGXM2eRmKOZfOte3HprHAbLwa2lWLfOthczfQ5H4msIIWjrkA6fuAbyVaD6qiRq1b0FxvEidOKAmTVybVCbiCb5Uam20MyLHe3Hpn8J1bzbfflaJnTjwziXD4td)yDqwGZlqNoeYkuDa93vLhYakPgt7lwaIwq(fG3ckkwGoDiKvOMhIZijkcNePOPxqPfG9c0PdHScvhqCgjrr4Kifn9ckTaD6qiRq1b0FxvEidOKAmTVyboxEb60HqwHAEO)UQ8qgqj1yAFXckTaSxGoDiKvO6a6VRkpKbusnM2xSGxUaeUGCxagBAtSYqI7WNg(X6GSGIIfGXM2eRmK4o8PHFSoilW5fOthczfQoG(7QYdzaLuJP9flarli)cWBbffla7f4Yc0PdHScvhqCgjrr4Kifn9ckkwGoDiKvOMh6VRkpKbusnM2xSaNlVaD6qiRq1b0FxvEidOKAmTVyb4TGsla7fOthczfQ5H(7QYdzah2KUxqPfOthczfQ5H(7QYdzaLuJP9fl4LlaHlW5fGXM2eRmK4o8PHFSoilO0cWytBIvgsCh(0WpwhKfK7c0PdHSc18q)Dv5HmGsQX0(IfGOfKFbfflWLfOthczfQ5H(7QYdzah2KUxqPfG9c0PdHSc18q)Dv5HmGd)yDqwWlxacxqUlaJnTjwzirNlqNiUdFA4hRdYckTam20MyLHeDUaDI4o8PHFSoilW5fKphlO0cWEb60HqwHQdO)UQ8qgqj1yAFXcE5cq4cYDbySPnXkdjUdFA4hRdYckkwGoDiKvOMh6VRkpKbC4hRdYcE5cq4cYDbySPnXkdjUdFA4hRdYckTaD6qiRqnp0FxvEidOKAmTVybVCboYXcCDbySPnXkdjUdFA4hRdYcYDbySPnXkdj6Cb6eXD4td)yDqwqrXcWytBIvgsCh(0WpwhKf48c0PdHScvhq)Dv5HmGsQX0(IfGOfKFbfflaJnTjwziXD4tuOwaElOOyb60HqwHAEO)UQ8qgWHFSoil4LlaHlW5fGXM2eRmKOZfOte3Hpn8J1bzbLwa2lqNoeYkuDa93vLhYakPgt7lwWlxacxqUlaJnTjwzirNlqNiUdFA4hRdYckkwGllqNoeYkuDaXzKefHtIu00lO0cWEbySPnXkdjUdFA4hRdYcCEb60HqwHQdO)UQ8qgqj1yAFXcq0cYVGIIfGXM2eRmK4o8jkulaVfG3cWBb4Ta8waElOOybQnOzfQ9dN0ljBEb5Uam20MyLHe3Hpn8J1bzb4TGIIf4Yc0PdHScvhqCgjrr4Kifn9ckTaxwG)WWHfkuO7PTybLwa2lqNoeYkuZdXzKefHtIu00lO0cWEbyVaxwagBAtSYqI7WNOqTGIIfOthczfQ5H(7QYdzah(X6GSaNxacxaElO0cWEbySPnXkdjUdFA4hRdYcCEb5ZXckkwGoDiKvOMh6VRkpKbC4hRdYcE5cq4cCEbySPnXkdjUdFA4hRdYcWBb4TGIIf4Yc0PdHSc18qCgjrr4Kifn9ckTaSxGllqNoeYkuZdXzKK)UQ8qglOOyb60HqwHAEO)UQ8qgWHFSoilOOyb60HqwHAEO)UQ8qgqj1yAFXcCU8c0PdHScvhq)Dv5HmGsQX0(IfG3cW7NrQNs(z60HqwD81)BoTpc(zCyIvw(XYpZ8AFXptNoeYA(FMFALN2(zyVaD6qiRqnpeNrsueojsrtVGIIf4pmCyHcf6EAlwqPfOthczfQ5H4msYFxvEiJfG3ckTaSxagBAtSYqIoxGorCh(efQfuAbyVaxwG)WWHfkuO7PTybLwGllqNoeYkuDaXzKefHtIu00lOOyb(ddhwOqHUN2IfuAbUSaD6qiRq1beNrs(7QYdzSGIIfOthczfQoG(7QYdzah(X6GSGIIfOthczfQ5H4msIIWjrkA6fuAbyVaxwGoDiKvO6aIZijkcNePOPxqrXc0PdHSc18q)Dv5HmGsQX0(If4C5fOthczfQoG(7QYdzaLuJP9flaVfuuSaD6qiRqnpeNrs(7QYdzSGslWLfOthczfQoG4msIIWjrkA6fuAb60HqwHAEO)UQ8qgqj1yAFXcCU8c0PdHScvhq)Dv5HmGsQX0(IfG3ckkwGllaJnTjwzirNlqNiUdFIc1ckTaSxGllqNoeYkuDaXzKefHtIu00lO0cWEb60HqwHAEO)UQ8qgqj1yAFXcE5cq4cYDbySPnXkdjUdFA4hRdYckkwagBAtSYqI7WNg(X6GSaNxGoDiKvOMh6VRkpKbusnM2xSaeTG8laVfuuSaD6qiRq1beNrsueojsrtVGsla7fOthczfQ5H4msIIWjrkA6fuAb60HqwHAEO)UQ8qgqj1yAFXcCU8c0PdHScvhq)Dv5HmGsQX0(IfuAbyVaD6qiRqnp0FxvEidOKAmTVybVCbiCb5Uam20MyLHe3Hpn8J1bzbfflaJnTjwziXD4td)yDqwGZlqNoeYkuZd93vLhYakPgt7lwaIwq(fG3ckkwa2lWLfOthczfQ5H4msIIWjrkA6fuuSaD6qiRq1b0FxvEidOKAmTVyboxEb60HqwHAEO)UQ8qgqj1yAFXcWBbLwa2lqNoeYkuDa93vLhYaoSjDVGslqNoeYkuDa93vLhYakPgt7lwWlxacxGZlaJnTjwziXD4td)yDqwqPfGXM2eRmK4o8PHFSoili3fOthczfQoG(7QYdzaLuJP9flarli)ckkwGllqNoeYkuDa93vLhYaoSjDVGsla7fOthczfQoG(7QYdzah(X6GSGxUaeUGCxagBAtSYqIoxGorCh(0WpwhKfuAbySPnXkdj6Cb6eXD4td)yDqwGZliFowqPfG9c0PdHSc18q)Dv5HmGsQX0(If8YfGWfK7cWytBIvgsCh(0WpwhKfuuSaD6qiRq1b0FxvEid4WpwhKf8YfGWfK7cWytBIvgsCh(0WpwhKfuAb60HqwHQdO)UQ8qgqj1yAFXcE5cCKJf46cWytBIvgsCh(0WpwhKfK7cWytBIvgs05c0jI7WNg(X6GSGIIfGXM2eRmK4o8PHFSoilW5fOthczfQ5H(7QYdzaLuJP9flarli)ckkwagBAtSYqI7WNOqTa8wqrXc0PdHScvhq)Dv5HmGd)yDqwWlxacxGZlaJnTjwzirNlqNiUdFA4hRdYckTaSxGoDiKvOMh6VRkpKbusnM2xSGxUaeUGCxagBAtSYqIoxGorCh(0WpwhKfuuSaxwGoDiKvOMhIZijkcNePOPxqPfG9cWytBIvgsCh(0WpwhKf48c0PdHSc18q)Dv5HmGsQX0(IfGOfKFbfflaJnTjwziXD4tuOwaElaVfG3cWBb4Ta8wqrXcuBqZku7hoPxs28cYDbySPnXkdjUdFA4hRdYcWBbfflWLfOthczfQ5H4msIIWjrkA6fuAbUSa)HHdluOq3tBXckTaSxGoDiKvO6aIZijkcNePOPxqPfG9cWEbUSam20MyLHe3HprHAbfflqNoeYkuDa93vLhYao8J1bzboVaeUa8wqPfG9cWytBIvgsCh(0WpwhKf48cYNJfuuSaD6qiRq1b0FxvEid4WpwhKf8YfGWf48cWytBIvgsCh(0WpwhKfG3cWBbfflWLfOthczfQoG4msIIWjrkA6fuAbyVaxwGoDiKvO6aIZij)Dv5HmwqrXc0PdHScvhq)Dv5HmGd)yDqwqrXc0PdHScvhq)Dv5HmGsQX0(If4C5fOthczfQ5H(7QYdzaLuJP9flaVfG3pJupL8Z0PdHSM)RF9Nr0pc(V54JGFghMyLLFS8Z8tR802pZLfmwltmgouOjLeilGMOKfuuSaxwWyTmXy4qHMusGuOwqPfG9cgRLjgdhk0KscusnM2xSaxxWyTmXy4qHMusGDSGCxq(CSGIIfG9cgRLjgdhk0Ksc0FuHUGYlWXckTa)HHdluOq3tBXcWBb4TGIIfmwltmgouOjLeifQfuAbJ1YeJHdfAsjbo8J1bzboVahy9FM51(IFMrqXEnD0jfhNq2v5x)VL)JGFghMyLLFS8Z8tR802ptKIMgspCiqUHuOwqPfisrtdPhoei3WHFSoili3YlaTxUaxxGOnISmrWDAc9yEoHIN(KlOOybIu00qKDvMiO6PvcKc1ckTapoBqZKe9yETVWQlW5f4aI4xqPfmubtFdAgspg6hous6OtkooXvjpjl0kpeihMyLL)mZR9f)mrBezzIG70V(FtG)i4NXHjwz5hl)m)0kpT9ZgQGPVbndjhvL(g0CIFe5Ha5WeRSCbLwGAtshdfC4hRdYcYDbO9YfuAb(7QYdzaPR2WWHFSoili3fG2l)zMx7l(zQnjDmuF9)gI)JGFghMyLLFS8ZmV2x8ZOR2W)m)0kpT9ZuBs6yOGuOwqPfmubtFdAgsoQk9nO5e)iYdbYHjwz5pR2bN8YFwEe(1)Bi8JGFM51(IFMy9ojbhl)zCyIvw(XYx)V9(Fe8Z4WeRS8JLFMFALN2(zUSGXAzIXWHcnPKazb0eLSGIIf4YcgRLjgdhk0KscKc1ckTGXAzIXWHcnPKaLuJP9flW1fmwltmgouOjLeyhli3fKphlOOybJ1YeJHdfAsjbsHAbLwWyTmXy4qHMusGd)yDqwGZlWbw)NzETV4NHSRYebvpTs(6)nN2hb)mZR9f)m6Q5MLjcUt)zCyIvw(XYx)V5u8rWpZ8AFXptyxRjcUt)zCyIvw(XYx)VH1)i4NXHjwz5hl)m)0kpT9ZePOPH0dhcKB4WpwhKf48cybWEkLtA)WlO0cWEb(7QYdzahMCHPDGozZCiHd)yDqwqUlaTxUGsla7f4YcuRYHczbGQEKgdNi4ofYHjwz5ckkwGifnnuSENSsruifQfG3ckkwGllWFy4Wcfk090wSa8wqrXcuBqZku7hoPxs28cYDbi8NzETV4NH06AhOt2mhYV(FZro(i4NXHjwz5hl)m)0kpT9Z83vLhYakYeTTAc5yko4WpwhKfK7cCKFb5Sf4XzdAMKOhZR9fwDbUUa0E5ckTa1QCOqINdnD0jX6DsihMyLLlOOyb0u1AAypoBqZjTF4fK7cq7LlO0c83vLhYakYeTTAc5yko4WpwhKfuuSa1g0Sc1(Ht6LKnVGCxaw)NzETV4NjAJilteCN(1)BoC8rWpJdtSYYpw(z(PvEA7NrFEkYcCDbEJOPHrZXcYDb0NNIaFmb8ZmV2x8ZKSP4sECMWXE(6)nh5)i4NXHjwz5hl)m)0kpT9ZePOPHgbf710rNuCCczxLqkulOOybQnOzfQ9dN0ljBEb5Uahi8NzETV4Nru7bfl5V(FZHa)rWpZ8AFXpZspuJKN0rN8ZHK8Z4WeRS8JLV(FZbI)JGFghMyLLFS8Z8tR802pd7fisrtdfzI2wnHCmfhKc1ckkwGAdAwHA)Wj9sYMxqUlWrowaElO0cWEbUSGXAzIXWHcnPKazb0eLSGIIf4YcgRLjgdhk0KscKc1ckTaSxWyTmXy4qHMusGsQX0(If46cgRLjgdhk0KscSJfK7cYNJfuuSGXAzIXWHcnPKa9hvOlO8cCSa8wqrXcgRLjgdhk0KscKc1ckTGXAzIXWHcnPKah(X6GSaNxGdS(cW7NzETV4Nnm5ct7aDYM5q(1)Boq4hb)momXkl)y5N5Nw5PTFg2lWFxvEidiYUkteu90kbo8J1bzboVahiCbfflWFy4Wcfk090wSGsla7f4VRkpKbCyYfM2b6KnZHeo8J1bzb5UaeUGIIf4VRkpKbCyYfM2b6KnZHeo8J1bzboVG85yb4TGIIfO2GMvO2pCsVKS5fK7cCGWfuuSaSxGllWFy4WcfgnACAI24fuAbUSa)HHdluOq3tBXcWBb4TGsla7f4YcgRLjgdhk0KscKfqtuYckkwGllySwMymCOqtkjqkulO0cWEbJ1YeJHdfAsjbkPgt7lwGRlySwMymCOqtkjWowqUliFowqrXcgRLjgdhk0Ksc0FuHUGYlWXcWBbfflySwMymCOqtkjqkulO0cgRLjgdhk0KscC4hRdYcCEboW6laVFM51(IFMit02QjKJP4(6)nhV)hb)mZR9f)mpU(X4XseCN(Z4WeRS8JLV(FZHt7JGFM51(IFMWUwt(75Xc5pJdtSYYpw(6)nhofFe8Z4WeRS8JLFMFALN2(zIu00qrMOTvtihtXbLhYybfflq8iKfuAb0nACAA4hRdYcYDbi8NzETV4NjAOthDsN2lK81)BoW6Fe8ZmV2x8ZK9Wjr2i6pJdtSYYpw(6)T854JGFghMyLLFS8Z8tR802pd7fqFEkYcE5c8hrxGRlG(8ue4WO5yb5SfG9c83vLhYakSR1K)EESqch(X6GSGxUahlaVf48cmV2xaf21AYFppwiH(JOlOOyb(7QYdzaf21AYFppwiHd)yDqwGZlWXcCDbO9YfG3ckkwa2lqKIMgkYeTTAc5ykoifQfuuSarkAAyWeshOrAJBsshdfQoqNmuOSXukcKc1cWBbLwGllyOcM(g0meRyOQwIhwsfjK2KUrYdKdtSYYfuuSaXJqwqPfq3OXPPHFSoili3fiW)mZR9f)m)jowIG70V(FlVJpc(zCyIvw(XYpZpTYtB)mrkAAiYUkteu90kbsHAbfflWJZg0mjrpMx7lS6cCEboG5xqPf4Vqs1kuSENSYQ2bAihMyLL)mZR9f)mrBezzIG70V(FlF(pc(zCyIvw(XYpZpTYtB)mrkAAOit02QjKJP4GYdzSGIIfiEeYckTa6gnonn8J1bzb5Uae(ZmV2x8ZSXBbNqrvj8x)VLxG)i4NXHjwz5hl)m)0kpT9ZgQGPVbndjhvL(g0CIFe5Ha5WeRSCbfflyOcM(g0mmycPd0iTXnjPJHcvhOtgku2ykfbYHjwz5pZ8AFXptTjPJH6R)3YJ4)i4NXHjwz5hl)m)0kpT9ZgQGPVbnddMq6ansBCts6yOq1b6KHcLnMsrGCyIvw(ZmV2x8ZOhMfOoqN0Xq91)B5r4hb)momXkl)y5N5Nw5PTFg2lG(8uKf46cOppfbomAowGRlWbcxaEli3fqFEkc8XeWpZ8AFXpZgVfCsVz4q)6x)z(kBy4pc(V54JGFghMyLLFS8Z8tR802pZLfmwltmgouOjLeilGMOKfuuSGXAzIXWHcnPKah(X6GSaNlVah5ybfflW8AJHtCWpntwGZLxWyTmXy4qHMusG(Jk0fKZwq(FM51(IFMrqXEnD0jfhNq2v5x)VL)JGFghMyLLFS8ZmV2x8ZeTrKLjcUt)z(PvEA7NjsrtdPhoei3qkulO0cePOPH0dhcKB4WpwhKfKB5fG2lxGRlq0grwMi4onHEmpNqXtFYfuuSarkAAiYUkteu90kbsHAbLwGhNnOzsIEmV2xy1f48cCar8lO0cgQGPVbndPhd9dhkjD0jfhN4QKNKfALhcKdtSYYFM3TVYj1g0Ss(V54R)3e4pc(zCyIvw(XYpZpTYtB)m0E5cE5cePOPHISr0KVYgggo8J1bzboVGCaZJWFM51(IF2dvvBcUt)6)ne)hb)momXkl)y5N5Nw5PTF2qfm9nOziQJYJlD0PXeOBs0JH(HdLa5WeRSCbLwGifnnKUAU5HKESriKc1pZ8AFXptyxRjcUt)6)ne(rWpJdtSYYpw(z(PvEA7NnubtFdAgI6O84shDAmb6Me9yOF4qjqomXkl)zMx7l(z0vZnlteCN(1)BV)hb)momXkl)y5N5Nw5PTF2qfm9nOzi5OQ03GMt8JipeihMyLLlO0cuBs6yOGd)yDqwqUlaTxUGslWFxvEidiD1ggo8J1bzb5Ua0E5pZ8AFXptTjPJH6R)3CAFe8Z4WeRS8JLFMFALN2(zQnjDmuqkulO0cgQGPVbndjhvL(g0CIFe5Ha5WeRS8NzETV4NrxTH)6)nNIpc(zCyIvw(XYpZpTYtB)m6ZtrwGRlWBennmAowqUlG(8ue4JjGFM51(IFMKnfxYJZeo2Zx)VH1)i4NXHjwz5hl)m)0kpT9ZCzbJ1YeJHdfAsjbYcOjkzbfflySwMymCOqtkjWHFSoilW5YlWrowqrXcmV2y4eh8tZKf4C5fmwltmgouOjLeO)OcDb5SfK)NzETV4NHSRYebvpTs(6)nh54JGFghMyLLFS8ZmV2x8ZeTrKLjcUt)z(PvEA7NrtvRPH94SbnN0(HxqUlaTxUGslWFxvEidOit02QjKJP4Gd)yDqwqrXc83vLhYakYeTTAc5yko4WpwhKfK7cCKFbUUa0E5ckTa1QCOqINdnD0jX6DsihMyLL)mVBFLtQnOzL8FZXx)V5WXhb)momXkl)y5N5Nw5PTFMllySwMymCOqtkjqwanrjlOOybJ1YeJHdfAsjbo8J1bzboxEbiCbfflW8AJHtCWpntwGZLxWyTmXy4qHMusG(Jk0fKZwq(FM51(IFMit02QjKJP4(6)nh5)i4NXHjwz5hl)m)0kpT9ZCzbJ1YeJHdfAsjbYcOjkzbfflySwMymCOqtkjWHFSoilW5YlaHlOOybMxBmCId(PzYcCU8cgRLjgdhk0Ksc0FuHUGC2cY)ZmV2x8ZgMCHPDGozZCi)6)nhc8hb)momXkl)y5N5Nw5PTFMifnn0iOyVMo6KIJti7QesHAbfflq8iKfuAb0nACAA4hRdYcYDboq4pZ8AFXpJO2dkwYF9)Mde)hb)momXkl)y5N5Nw5PTFMifnnKE4qGCdh(X6GSaNxala2tPCs7h(NzETV4NH06AhOt2mhYV(FZbc)i4NzETV4Nrxn3SmrWD6pJdtSYYpw(6)nhV)hb)mZR9f)mHDTMi4o9NXHjwz5hlF9)MdN2hb)mZR9f)mpU(X4XseCN(Z4WeRS8JLV(FZHtXhb)mZR9f)mX6Dscow(Z4WeRS8JLV(FZbw)JGFM51(IFMLEOgjpPJo5Ndj5NXHjwz5hlF9)w(C8rWpJdtSYYpw(z(PvEA7NjsrtdPhoei3WHFSoilW5fWcG9ukN0(H)zMx7l(zI2mgA(R)3Y74JGFghMyLLFS8Z8tR802pJ(8uKf48c8hrxGRlW8AFb8HQQnb3Pq)r0FM51(IFMWUwt(75Xc5x)VLp)hb)momXkl)y5N5Nw5PTFMifnnuKjAB1eYXuCq5HmwqrXcepczbLwaDJgNMg(X6GSGCxac)zMx7l(zIg60rN0P9cjF9)wEb(JGFM51(IFMShojYgr)zCyIvw(XYx)VLhX)rWpJdtSYYpw(zMx7l(zI2iYYeb3P)m)0kpT9ZuBqZku7hoPxs28cYDby9fuuSapoBqZKe9yETVWQlW5f4aMFbLwG)cjvRqX6DYkRAhOHCyIvw(Z8U9voP2GMvY)nhF9)wEe(rWpJdtSYYpw(z(PvEA7NrFEkcu7hoPx6XeWcYDbO9YfKZwq(FM51(IFM)ehlrWD6x)VL)9)i4NXHjwz5hl)m)0kpT9ZgQGPVbndjhvL(g0CIFe5Ha5WeRSCbfflyOcM(g0mmycPd0iTXnjPJHcvhOtgku2ykfbYHjwz5pZ8AFXptTjPJH6R)3Y70(i4NXHjwz5hl)m)0kpT9ZgQGPVbnddMq6ansBCts6yOq1b6KHcLnMsrGCyIvw(ZmV2x8ZOhMfOoqN0Xq91)B5Dk(i4NXHjwz5hl)m)0kpT9ZWEb0NNISaxxa95PiWHrZXcCDbcCowaEli3fqFEkc8XeWpZ8AFXpZgVfCsVz4q)6x)6pddpK(I)B5ZrEhoCKxG)ziTj6an5N9EYPynVH1(MthXwWcqaoEb9dQB0fqFZcWh1W(7r0u8xWWyfQEy5ci3dVaJsVhtz5c84SantGRGVOdEbieXwW7Uadpklxa(dvW03GMHob)fO3cWFOcM(g0m0jqomXklXFbMUGCEo5flaBhcap4k4l6GxacrSf8UlWWJYYfG)qfm9nOzOtWFb6Ta8hQGPVbndDcKdtSYs8xa2oeaEWvWx0bVG3hXwW7Uadpklxa(Qv5qHob)fO3cWxTkhk0jqomXklXFby7qa4bxbFrh8cEFeBbV7cm8OSCb4pubtFdAg6e8xGEla)Hky6BqZqNa5WeRSe)fy6cY55KxSaSDia8GRGRGVNCkwZByTV50rSfSaeGJxq)G6gDb03Sa81PdHSsWFbdJvO6HLlGCp8cmk9EmLLlWJZc0mbUc(Io4f8(i2cE3fy4rz5cY6N3TaI7qnbSG37c0BbVGYwGSX0K(IfCO4X0Bwa2icVfGncfaEWvWx0bVG3hXwW7Uadpklxa(60HqwHoGob)fO3cWxNoeYkuDaDc(la78oeaEWvWx0bVG3hXwW7Uadpklxa(60HqwH5Hob)fO3cWxNoeYkuZdDc(la78VVaWdUc(Io4f40qSf8UlWWJYYfK1pVBbe3HAcybV3fO3cEbLTazJPj9fl4qXJP3SaSreElaBeka8GRGVOdEboneBbV7cm8OSCb4Rthczf6a6e8xGElaFD6qiRq1b0j4VaSZ)(cap4k4l6GxGtdXwW7Uadpklxa(60HqwH5Hob)fO3cWxNoeYkuZdDc(la78oeaEWvWvW3tofR5nS23C6i2cwacWXlOFqDJUa6Bwa(Ejb)fmmwHQhwUaY9WlWO07XuwUapolqZe4k4l6GxGaJyl4DxGHhLLlaF1QCOqNG)c0Bb4RwLdf6eihMyLL4VaSDia8GRGVOdEbiEeBbV7cm8OSCb4RwLdf6e8xGElaF1QCOqNa5WeRSe)fGTdbGhCfCf89KtXAEdR9nNoITGfGaC8c6hu3OlG(MfGprXFbdJvO6HLlGCp8cmk9EmLLlWJZc0mbUc(Io4fKhXwW7Uadpklxa(dvW03GMHob)fO3cWFOcM(g0m0jqomXklXFbMUGCEo5flaBhcap4k4l6GxqEeBbV7cm8OSCb4JIvOtGioqie)fO3cWhXbcH4VaSZla8GRGVOdEbcmITG3DbgEuwUa8hQGPVbndDc(lqVfG)qfm9nOzOtGCyIvwI)cW2HaWdUc(Io4fG4rSf8UlWWJYYfG)qfm9nOzOtWFb6Ta8hQGPVbndDcKdtSYs8xGPliNNtEXcW2HaWdUc(Io4fG1rSf8UlWWJYYfGVAvouOtWFb6Ta8vRYHcDcKdtSYs8xa2oeaEWvWx0bVaSoITG3DbgEuwUa8rXk0jqehieI)c0Bb4J4aHq8xa2oeaEWvWx0bVah5aXwW7Uadpklxa(Qv5qHob)fO3cWxTkhk0jqomXklXFby7qa4bxbFrh8cYNdeBbV7cm8OSCb4pubtFdAg6e8xGEla)Hky6BqZqNa5WeRSe)fGTdbGhCf8fDWliVdeBbV7cm8OSCb47Vqs1k0j4Va9wa((lKuTcDcKdtSYs8xGPliNNtEXcW2HaWdUc(Io4fKxGrSf8UlWWJYYfG)qfm9nOzOtWFb6Ta8hQGPVbndDcKdtSYs8xGPliNNtEXcW2HaWdUc(Io4fKxGrSf8UlWWJYYfG)qfm9nOzOtWFb6Ta8hQGPVbndDcKdtSYs8xa2oeaEWvWx0bVG8iEeBbV7cm8OSCb4pubtFdAg6e8xGEla)Hky6BqZqNa5WeRSe)fy6cY55KxSaSDia8GRGRGVNCkwZByTV50rSfSaeGJxq)G6gDb03Sa89v2WW4VGHXku9WYfqUhEbgLEpMYYf4XzbAMaxbFrh8cYJyl4DxGHhLLla)Hky6BqZqNG)c0Bb4pubtFdAg6eihMyLL4VatxqopN8IfGTdbGhCf8fDWlipITG3DbgEuwUa8rXk0jqehieI)c0Bb4J4aHq8xa25faEWvWx0bVabgXwW7Uadpklxa(Oyf6eiIdecXFb6Ta8rCGqi(laBhcap4k4l6GxaIhXwW7Uadpklxa(dvW03GMHob)fO3cWFOcM(g0m0jqomXklXFby7qa4bxbFrh8cqiITG3DbgEuwUa8hQGPVbndDc(lqVfG)qfm9nOzOtGCyIvwI)cmDb58CYlwa2oeaEWvWx0bVG3hXwW7Uadpklxa(dvW03GMHob)fO3cWFOcM(g0m0jqomXklXFby7qa4bxbFrh8cCAi2cE3fy4rz5cWFOcM(g0m0j4Va9wa(dvW03GMHobYHjwzj(lW0fKZZjVyby7qa4bxbFrh8cCKdeBbV7cm8OSCb4RwLdf6e8xGElaF1QCOqNa5WeRSe)fy6cY55KxSaSDia8GRGVOdEboq8i2cE3fy4rz5cWhfRqNarCGqi(lqVfGpIdecXFby7qa4bxbFrh8cYNdeBbV7cm8OSCb4JIvOtGioqie)fO3cWhXbcH4VaSDia8GRGVOdEb5r8i2cE3fy4rz5cW3FHKQvOtWFb6Ta89xiPAf6eihMyLL4VatxqopN8IfGTdbGhCf8fDWli)7Jyl4DxGHhLLla)Hky6BqZqNG)c0Bb4pubtFdAg6eihMyLL4VatxqopN8IfGTdbGhCf8fDWli)7Jyl4DxGHhLLla)Hky6BqZqNG)c0Bb4pubtFdAg6eihMyLL4VaSDia8GRGVOdEb5DAi2cE3fy4rz5cWFOcM(g0m0j4Va9wa(dvW03GMHobYHjwzj(lW0fKZZjVyby7qa4bxbxbXAFqDJYYf8(lW8AFXcQnrjWvWFgbf7)VLhHc8pd1C0DL)zovN6cWcBeDbyvzeLh3lWPmvO8Sc6uDQlaXL98JipliVt71fKph5DScUc6uDQl4D4SantqSvqNQtDbVCbyn8l5WeR8cWInISCbz4oDbo9X88cWQWtFs4kOt1PUGxUG3J11oqVGmCNUakustzcCfCf08AFbbIAy)9iAAzc1ZZfjuSUcAETVGarnS)Een11Yis8uTYYeD1CZsKDGoPNa6yf08AFbbIAy)9iAQRLreDLj48JrRRGMx7liqud7VhrtDTmIOiCQv(51WE4YMarWzJrs0xOPJoH6qYZkO51(cce1W(7r0uxlJi1MKogQxrnS3iAs7hUSdicFTPlpubtFdAgsoQk9nO5e)iYdPOyOcM(g0mmycPd0iTXnjPJHcvhOtgku2ykfzf08AFbbIAy)9iAQRLrKit02QjKJP4Ef1WEJOjTF4YoGi81MUSlQv5qHephA6OtI17KLCzOcM(g0mKCuv6BqZj(rKhYkOtDb5ujwnfrjlqXXlqsnM2xSalKlWFxvEiJfC0liNsqXEDbh9cuC8cEpDvUalKlaRY0pwDbyTbr7WRKfi6EbkoEbsQX0(IfC0lWIfqf4mIYYf40FhI7cqIJJfO4y34p8cOiSCbOg2FpIMcxawyVrr4fKtjOyVUGJEbkoEbVNUkxWWskptwGt)DiUlq09cYNJC8qEDbkUMSGMSahqbEbe2FHKaxbnV2xqGOg2FpIM6AzezeuSxthDsXXjKDv(kQH9grtA)WLDaf4xB6YUycepTYqut)y1uheTdVsGCyIvwwYfMq4WZqMq4WZPJoP44e95PiDGo1ttGpgw9nLWMXkunkuSeAcebNngjrFHMo6eQdjpffUWyfQgfkwc9U91tNlAFsSAefVvqN6cYPsSAkIswGIJxGKAmTVybwixG)UQ8qgl4OxawyI2wDbVNXuClWc5cCkBceVGJEbyngAEbIUxGIJxGKAmTVybh9cSybuboJOSCbo93H4UaK44ybko2n(dVakclxaQH93JOPWvqZR9feiQH93JOPUwgrImrBRMqoMI7vud7nIM0(Hl7aIWxB6YMaXtRme10pwn1br7WReihMyLLLCHjeo8mKjeo8C6OtkoorFEkshOt90e4JHvFtjSzScvJcflHMarWzJrs0xOPJoH6qYtrHlmwHQrHILqVBF905I2NeRgrXBfCf08AFbX1YiYFuHYtIG70vqN6cC63cmCSjxGfYfGGXcScvxBbIxWByvE3c4GFAMGv9cqYlqEb(6cK3cuCnzb03SauvZnpKfiYEJIWlOv8LlqKxGE3ciOSNh3lWc5cqYlWBb(6cg2KD19cqWybwzbeuSVPB)cePOPjWvqZR9fexlJiDSaRq11wG6aDIG70xB6YUO2GMvytsOQMBEwbDQo1fG4YvZ9cOnFhOxG7JAwG8Oe1fqfAxxG7JAb4mm8cqrPlaRHjxyAhOxqoDMd5cKhY41fCZcA6fO44f4VRkpKXcAYc07wq9c0lqVfi5Q5Eb0MVd0lW9rnlaX9Oev4cWAPxqCbVGJEbkoMWlWFHS1(cYcSHxGjw5fO3cEyDbiBfxhlqXXlWrowaH9xijlOYmsZ9RlqXXlG0plG28mzbUpQzbiUhLOUaJsVhtBVvRUHRGovN6cmV2xqCTmIcgj9rfY0WKRIHFTPltoQQyhsyWiPpQqMgMCvmCjSfPOPHdtUW0oqNSzoKqkuff(7QYdzahMCHPDGozZCiHd)yDqC2rokkuBqZku7hoPxs2CUoEF8wbnV2xqCTmI8wTMmV2xKQnrFnShUSoDiKvYReDAVw2XRnDz)HHdluOq3tBrj)Dv5HmGgbf710rNuCCczxLWHFSoiL83vLhYaom5ct7aDYM5qch(X6Guu4I)WWHfkuO7PTOK)UQ8qgqJGI9A6OtkooHSRs4WpwhKvqZR9fexlJiVvRjZR9fPAt0xd7Hl7LKvqZR9fexlJiVvRjZR9fPAt0xd7Hlt0xj60ETSJxB6YMxBmCId(PzsU5xbnV2xqCTmI8wTMmV2xKQnrFnShUSVYgg(vIoTxl741MUS51gdN4GFAM4SJvWvqZR9feOxskBHNj6y1K3Q1xB6Y(7QYdzafzI2wnHCmfhC4hRdIZcCowbnV2xqGEjX1YiIUhwSEN81MUS)UQ8qgqrMOTvtihtXbh(X6G4SaNJvqZR9feOxsCTmIe5HWJWoq)AtxgBrkAAiYUkteu90kbsHQOWf)HHdluy0OXPjAJljsrtdnck2RPJoP44eYUkHuOkjsrtdfzI2wnHCmfhKcfELWMUrJttd)yDqC2FxvEidOipeEe2bAOKAmTVWvj1yAFrrb2QnOzfIJTQIdIYR5kWiSOWf1QCOqHDTYtQdI2HxXdVIcXJqkr3OXPPHFSoi56qGxbnV2xqGEjX1YisSENmrtnUFTPlJTifnnezxLjcQEALaPqvu4I)WWHfkmA040eTXLePOPHgbf710rNuCCczxLqkuLePOPHImrBRMqoMIdsHcVsyt3OXPPHFSoio7VRkpKbuSENmrtnUHsQX0(cxLuJP9fffyR2GMvio2QkoikVMRaJWIcxuRYHcf21kpPoiAhEfp8kkepcPeDJgNMg(X6GKRJ3Ff08AFbb6LexlJOAJgNssy1us0pCORGMx7liqVK4AzeH60(IxB6YIu00qJGI9A6OtkooHSRsifQIc6gnonn8J1bj38V)k4kO51(cc0xzddx2iOyVMo6KIJti7Q81MUSlJ1YeJHdfAsjbYcOjkPOySwMymCOqtkjWHFSoiox2rokkmV2y4eh8tZeNlpwltmgouOjLeO)OcnNLFf08AFbb6RSHHDTmIeTrKLjcUtF172x5KAdAwjLD8AtxgfRWhRdOifnnKE4qGCdPqvcfRWhRdOifnnKE4qGCdh(X6GKBz0EPRI2iYYeb3Pj0J55ekE6twuisrtdr2vzIGQNwjqkuL84Sbnts0J51(cR6SdiIV0qfm9nOzi9yOF4qjPJoP44exL8KSqR8qwbnV2xqG(kByyxlJOhQQ2eCN(AtxgTx(suScFSoGIu00qr2iAYxzdddh(X6G4CoG5r4kO51(cc0xzdd7AzejSR1eb3PV20LhQGPVbndrDuECPJonMaDtIEm0pCOKsIu00q6Q5Mhs6XgHqkuRGMx7liqFLnmSRLreD1CZYeb3PV20LhQGPVbndrDuECPJonMaDtIEm0pCOKvqZR9feOVYgg21YisTjPJH61MU8qfm9nOzi5OQ03GMt8JipKsQnjDmuWHFSoi5I2ll5VRkpKbKUAddh(X6GKlAVCf08AFbb6RSHHDTmIOR2WV20LvBs6yOGuOknubtFdAgsoQk9nO5e)iYdzf08AFbb6RSHHDTmIKSP4sECMWXEETPltFEkIREJOPHrZrU0NNIaFmbScAETVGa9v2WWUwgri7Qmrq1tRKxB6YUmwltmgouOjLeilGMOKIIXAzIXWHcnPKah(X6G4Czh5OOW8AJHtCWpntCU8yTmXy4qHMusG(Jk0Cw(vqZR9feOVYgg21Yis0grwMi4o9vVBFLtQnOzLu2XRnDzAQAnnShNnO5K2pCUO9Ys(7QYdzafzI2wnHCmfhC4hRdsrH)UQ8qgqrMOTvtihtXbh(X6GKRJ8UI2llPwLdfs8COPJojwVtUcAETVGa9v2WWUwgrImrBRMqoMI71MUSlJ1YeJHdfAsjbYcOjkPOySwMymCOqtkjWHFSoioxgHffMxBmCId(PzIZLhRLjgdhk0Ksc0FuHMZYVcAETVGa9v2WWUwgrdtUW0oqNSzoKV20LDzSwMymCOqtkjqwanrjffJ1YeJHdfAsjbo8J1bX5YiSOW8AJHtCWpntCU8yTmXy4qHMusG(Jk0Cw(vqZR9feOVYgg21YiIO2dkwYV20LfPOPHgbf710rNuCCczxLqkuffIhHuIUrJttd)yDqY1bcxbnV2xqG(kByyxlJiKwx7aDYM5q(AtxgfRWhRdOifnnKE4qGCdh(X6G4mla2tPCs7hEf08AFbb6RSHHDTmIORMBwMi4oDf08AFbb6RSHHDTmIe21AIG70vqZR9feOVYgg21YiYJRFmESeb3PRGMx7liqFLnmSRLrKy9ojbhlxbnV2xqG(kByyxlJil9qnsEshDYphsYkO51(cc0xzdd7AzejAZyO5xB6YOyf(yDafPOPH0dhcKB4WpwheNzbWEkLtA)WRGMx7liqFLnmSRLrKWUwt(75Xc5RnDz6ZtrC2Fe1vZR9fWhQQ2eCNc9hrxbnV2xqG(kByyxlJirdD6Ot60EHKxB6YIu00qrMOTvtihtXbLhYOOq8iKs0nACAA4hRdsUiCf08AFbb6RSHHDTmIK9Wjr2i6kO51(cc0xzdd7AzejAJilteCN(Q3TVYj1g0Ssk741MUSAdAwHA)Wj9sYMZfRxu4XzdAMKOhZR9fw1zhW8L8xiPAfkwVtwzv7a9kO51(cc0xzdd7Aze5pXXseCN(AtxM(8ueO2pCsV0JjGCr7L5S8RGMx7liqFLnmSRLrKAtshd1RnD5Hky6BqZqYrvPVbnN4hrEiffdvW03GMHbtiDGgPnUjjDmuO6aDYqHYgtPiRGMx7liqFLnmSRLre9WSa1b6KogQxB6YdvW03GMHbtiDGgPnUjjDmuO6aDYqHYgtPiRGMx7liqFLnmSRLrKnEl4KEZWH(AtxgB6ZtrCL(8ue4WO5Wvboh4Ll95PiWhtaRGRGMx7liqIw2iOyVMo6KIJti7Q81MUSlJ1YeJHdfAsjbYcOjkPOWLXAzIXWHcnPKaPqvc7XAzIXWHcnPKaLuJP9fUowltmgouOjLeyh5MphffypwltmgouOjLeO)OcTSJs(ddhwOqHUN2c8WROySwMymCOqtkjqkuLgRLjgdhk0KscC4hRdIZoW6RGMx7liqI6AzejAJilteCN(AtxgfRWhRdOifnnKE4qGCdPqvcfRWhRdOifnnKE4qGCdh(X6GKBz0EPRI2iYYeb3Pj0J55ekE6twuisrtdr2vzIGQNwjqkuL84Sbnts0J51(cR6SdiIV0qfm9nOzi9yOF4qjPJoP44exL8KSqR8qwbnV2xqGe11YisTjPJH61MU8qfm9nOzi5OQ03GMt8JipKsQnjDmuWHFSoi5I2ll5VRkpKbKUAddh(X6GKlAVCf08AFbbsuxlJi6Qn8R1o4KxwopcFTPlR2K0XqbPqvAOcM(g0mKCuv6BqZj(rKhYkO51(ccKOUwgrI17KeCSCf08AFbbsuxlJiKDvMiO6PvYRnDzxgRLjgdhk0KscKfqtusrHlJ1YeJHdfAsjbsHQ0yTmXy4qHMusGsQX0(cxhRLjgdhk0KscSJCZNJIIXAzIXWHcnPKaPqvASwMymCOqtkjWHFSoio7aRVcAETVGajQRLreD1CZYeb3PRGMx7liqI6AzejSR1eb3PRGMx7liqI6AzeH06AhOt2mhYxB6YOyf(yDafPOPH0dhcKB4WpwheNzbWEkLtA)WLW2FxvEid4WKlmTd0jBMdjC4hRdsUO9Ysy7IAvouilau1J0y4eb3PffIu00qX6DYkfrHuOWROWf)HHdluOq3tBbEffQnOzfQ9dN0ljBoxeUcAETVGajQRLrKOnISmrWD6RnDz)Dv5HmGImrBRMqoMIdo8J1bjxh5ZzEC2GMjj6X8AFHvDfTxwsTkhkK45qthDsSENSOGMQwtd7XzdAoP9dNlAVSK)UQ8qgqrMOTvtihtXbh(X6GuuO2GMvO2pCsVKS5CX6RGMx7liqI6AzejztXL84mHJ98AtxM(8uex9grtdJMJCPppfb(ycyf08AFbbsuxlJiIApOyj)AtxwKIMgAeuSxthDsXXjKDvcPqvuO2GMvO2pCsVKS5CDGWvqZR9feirDTmIS0d1i5jD0j)CijRGMx7liqI6Azenm5ct7aDYM5q(AtxgBrkAAOit02QjKJP4GuOkkuBqZku7hoPxs2CUoYbELW2LXAzIXWHcnPKazb0eLuu4YyTmXy4qHMusGuOkH9yTmXy4qHMusGsQX0(cxhRLjgdhk0KscSJCZNJIIXAzIXWHcnPKa9hvOLDGxrXyTmXy4qHMusGuOknwltmgouOjLe4WpwheNDG1XBf08AFbbsuxlJirMOTvtihtX9AtxgB)Dv5HmGi7Qmrq1tRe4WpwheNDGWIc)HHdluOq3tBrjS93vLhYaom5ct7aDYM5qch(X6GKlclk83vLhYaom5ct7aDYM5qch(X6G4C(CGxrHAdAwHA)Wj9sYMZ1bclkW2f)HHdluy0OXPjAJl5I)WWHfkuO7PTap8kHTlJ1YeJHdfAsjbYcOjkPOWLXAzIXWHcnPKaPqvc7XAzIXWHcnPKaLuJP9fUowltmgouOjLeyh5MphffJ1YeJHdfAsjb6pQql7aVIIXAzIXWHcnPKaPqvASwMymCOqtkjWHFSoio7aRJ3kO51(ccKOUwgrEC9JXJLi4oDf08AFbbsuxlJiHDTM83ZJfYvqZR9feirDTmIen0PJoPt7fsETPllsrtdfzI2wnHCmfhuEiJIcXJqkr3OXPPHFSoi5IWvqZR9feirDTmIK9Wjr2i6kO51(ccKOUwgr(tCSeb3PV20LXM(8uKx6pI6k95PiWHrZrodB)Dv5HmGc7An5VNhlKWHFSoiV0bEoBETVakSR1K)EESqc9hrlk83vLhYakSR1K)EESqch(X6G4Sdxr7L4vuGTifnnuKjAB1eYXuCqkuffIu00WGjKoqJ0g3KKogkuDGozOqzJPueifk8k5Yqfm9nOziwXqvTepSKksiTjDJKNIcXJqkr3OXPPHFSoi5kWRGMx7liqI6AzejAJilteCN(AtxwKIMgISRYebvpTsGuOkk84Sbnts0J51(cR6Sdy(s(lKuTcfR3jRSQDGEf08AFbbsuxlJiB8wWjuuvc)AtxwKIMgkYeTTAc5ykoO8qgffIhHuIUrJttd)yDqYfHRGMx7liqI6AzeP2K0Xq9AtxEOcM(g0mKCuv6BqZj(rKhsrXqfm9nOzyWeshOrAJBsshdfQoqNmuOSXukYkO51(ccKOUwgr0dZcuhOt6yOETPlpubtFdAggmH0bAK24MK0XqHQd0jdfkBmLIScAETVGajQRLrKnEl4KEZWH(AtxgB6ZtrCL(8ue4WO5WvhieVCPppfb(ycyfCf08AFbbQthczLugJnTjw5xd7HltCh(efQxXyvkUSifnnCyYfM2b6KnZHesHQOqKIMgAeuSxthDsXXjKDvcPqTcAETVGa1PdHSsCTmIWytBIv(1WE4YeDUaDI4o8jkuVIXQuCz)HHdluOq3tBrjrkAA4WKlmTd0jBMdjKcvjrkAAOrqXEnD0jfhNq2vjKcvrHl(ddhwOqHUN2IsIu00qJGI9A6OtkooHSRsifQvqZR9feOoDiKvIRLregBAtSYVg2dxMOZfOte3Hpn8J1b51dvzcRn9R(lKT2xu2Fy4Wcfk090w8kgRsXL93vLhYaom5ct7aDYM5qch(X6GKRtj)Dv5HmGgbf710rNuCCczxLWHFSoiVIXQuCIReUS)UQ8qgqJGI9A6OtkooHSRs4WpwhKxB6YIu00qJGI9A6OtkooHSRsO8qgRGMx7liqD6qiRexlJim20MyLFnShUmrNlqNiUdFA4hRdYRhQYewB6x9xiBTVOS)WWHfkuO7PT4vmwLIl7VRkpKbCyYfM2b6KnZHeo8J1b5vmwLItCLWL93vLhYaAeuSxthDsXXjKDvch(X6G8AtxwKIMgAeuSxthDsXXjKDvcPqTcAETVGa1PdHSsCTmIWytBIv(1WE4Ye3Hpn8J1b51dvzcRn9R(lKT2xu2Fy4Wcfk090w8kgRsXL93vLhYaom5ct7aDYM5qch(X6G4Stj)Dv5HmGgbf710rNuCCczxLWHFSoiVIXQuCIReUS)UQ8qgqJGI9A6OtkooHSRs4WpwhKvqZR9feOoDiKvIRLrefHtTYpKxj1tjL1PdHS641MUm260HqwHoG4msIIWjrkA6Ic)HHdluOq3tBrjD6qiRqhqCgj5VRkpKbELWgJnTjwzirNlqNiUdFIcvjSDXFy4Wcfk090wuYfD6qiRW8qCgjrr4KifnDrH)WWHfkuO7PTOKl60HqwH5H4msYFxvEiJIcD6qiRW8q)Dv5HmGd)yDqkk0PdHScDaXzKefHtIu00LW2fD6qiRW8qCgjrr4KifnDrHoDiKvOdO)UQ8qgqj1yAFHZL1PdHScZd93vLhYakPgt7lWROqNoeYk0beNrs(7QYdzuYfD6qiRW8qCgjrr4KifnDjD6qiRqhq)Dv5HmGsQX0(cNlRthczfMh6VRkpKbusnM2xGxrHlySPnXkdj6Cb6eXD4tuOkHTl60HqwH5H4msIIWjrkA6syRthczf6a6VRkpKbusnM2x8seMlgBAtSYqI7WNg(X6GuuGXM2eRmK4o8PHFSoioRthczf6a6VRkpKbusnM2x8EZJxrHoDiKvyEioJKOiCsKIMUe260HqwHoG4msIIWjrkA6s60HqwHoG(7QYdzaLuJP9foxwNoeYkmp0FxvEidOKAmTVOe260HqwHoG(7QYdzaLuJP9fVeH5IXM2eRmK4o8PHFSoiffySPnXkdjUdFA4hRdIZ60HqwHoG(7QYdzaLuJP9fV384vuGTl60HqwHoG4msIIWjrkA6IcD6qiRW8q)Dv5HmGsQX0(cNlRthczf6a6VRkpKbusnM2xGxjS1PdHScZd93vLhYaoSjDxsNoeYkmp0FxvEidOKAmTV4Li0zm20MyLHe3Hpn8J1bPegBAtSYqI7WNg(X6GKRoDiKvyEO)UQ8qgqj1yAFX7nFrHl60HqwH5H(7QYdzah2KUlHToDiKvyEO)UQ8qgWHFSoiVeH5IXM2eRmKOZfOte3Hpn8J1bPegBAtSYqIoxGorCh(0WpwheNZNJsyRthczf6a6VRkpKbusnM2x8seMlgBAtSYqI7WNg(X6GuuOthczfMh6VRkpKbC4hRdYlryUySPnXkdjUdFA4hRdsjD6qiRW8q)Dv5HmGsQX0(Ix6ihUIXM2eRmK4o8PHFSoi5IXM2eRmKOZfOte3Hpn8J1bPOaJnTjwziXD4td)yDqCwNoeYk0b0FxvEidOKAmTV49MVOaJnTjwziXD4tuOWROqNoeYkmp0FxvEid4WpwhKxIqNXytBIvgs05c0jI7WNg(X6GucBD6qiRqhq)Dv5HmGsQX0(IxIWCXytBIvgs05c0jI7WNg(X6Guu4IoDiKvOdioJKOiCsKIMUe2ySPnXkdjUdFA4hRdIZ60HqwHoG(7QYdzaLuJP9fV38ffySPnXkdjUdFIcfE4HhE4HxrHAdAwHA)Wj9sYMZfJnTjwziXD4td)yDqWROWfD6qiRqhqCgjrr4KifnDjx8hgoSqHcDpTfLWwNoeYkmpeNrsueojsrtxcBSDbJnTjwziXD4tuOkk0PdHScZd93vLhYao8J1bXzeIxjSXytBIvgsCh(0WpwheNZNJIcD6qiRW8q)Dv5HmGd)yDqEjcDgJnTjwziXD4td)yDqWdVIcx0PdHScZdXzKefHtIu00LW2fD6qiRW8qCgj5VRkpKrrHoDiKvyEO)UQ8qgWHFSoiff60HqwH5H(7QYdzaLuJP9foxwNoeYk0b0FxvEidOKAmTVap8wbnV2xqG60HqwjUwgrueo1k)qELupLuwNoeYA(xB6YyRthczfMhIZijkcNePOPlk8hgoSqHcDpTfL0PdHScZdXzKK)UQ8qg4vcBm20MyLHeDUaDI4o8jkuLW2f)HHdluOq3tBrjx0PdHScDaXzKefHtIu00ff(ddhwOqHUN2IsUOthczf6aIZij)Dv5Hmkk0PdHScDa93vLhYao8J1bPOqNoeYkmpeNrsueojsrtxcBx0PdHScDaXzKefHtIu00ff60HqwH5H(7QYdzaLuJP9foxwNoeYk0b0FxvEidOKAmTVaVIcD6qiRW8qCgj5VRkpKrjx0PdHScDaXzKefHtIu00L0PdHScZd93vLhYakPgt7lCUSoDiKvOdO)UQ8qgqj1yAFbEffUGXM2eRmKOZfOte3HprHQe2UOthczf6aIZijkcNePOPlHToDiKvyEO)UQ8qgqj1yAFXlryUySPnXkdjUdFA4hRdsrbgBAtSYqI7WNg(X6G4SoDiKvyEO)UQ8qgqj1yAFX7npEff60HqwHoG4msIIWjrkA6syRthczfMhIZijkcNePOPlPthczfMh6VRkpKbusnM2x4CzD6qiRqhq)Dv5HmGsQX0(IsyRthczfMh6VRkpKbusnM2x8seMlgBAtSYqI7WNg(X6GuuGXM2eRmK4o8PHFSoioRthczfMh6VRkpKbusnM2x8EZJxrb2UOthczfMhIZijkcNePOPlk0PdHScDa93vLhYakPgt7lCUSoDiKvyEO)UQ8qgqj1yAFbELWwNoeYk0b0FxvEid4WM0DjD6qiRqhq)Dv5HmGsQX0(IxIqNXytBIvgsCh(0WpwhKsySPnXkdjUdFA4hRdsU60HqwHoG(7QYdzaLuJP9fV38ffUOthczf6a6VRkpKbCyt6Ue260HqwHoG(7QYdzah(X6G8seMlgBAtSYqIoxGorCh(0WpwhKsySPnXkdj6Cb6eXD4td)yDqCoFokHToDiKvyEO)UQ8qgqj1yAFXlryUySPnXkdjUdFA4hRdsrHoDiKvOdO)UQ8qgWHFSoiVeH5IXM2eRmK4o8PHFSoiL0PdHScDa93vLhYakPgt7lEPJC4kgBAtSYqI7WNg(X6GKlgBAtSYqIoxGorCh(0WpwhKIcm20MyLHe3Hpn8J1bXzD6qiRW8q)Dv5HmGsQX0(I3B(Icm20MyLHe3HprHcVIcD6qiRqhq)Dv5HmGd)yDqEjcDgJnTjwzirNlqNiUdFA4hRdsjS1PdHScZd93vLhYakPgt7lEjcZfJnTjwzirNlqNiUdFA4hRdsrHl60HqwH5H4msIIWjrkA6syJXM2eRmK4o8PHFSoioRthczfMh6VRkpKbusnM2x8EZxuGXM2eRmK4o8jku4HhE4HhEffQnOzfQ9dN0ljBoxm20MyLHe3Hpn8J1bbVIcx0PdHScZdXzKefHtIu00LCXFy4Wcfk090wucBD6qiRqhqCgjrr4KifnDjSX2fm20MyLHe3HprHQOqNoeYk0b0FxvEid4WpwheNriELWgJnTjwziXD4td)yDqCoFokk0PdHScDa93vLhYao8J1b5Li0zm20MyLHe3Hpn8J1bbp8kkCrNoeYk0beNrsueojsrtxcBx0PdHScDaXzKK)UQ8qgff60HqwHoG(7QYdzah(X6GuuOthczf6a6VRkpKbusnM2x4CzD6qiRW8q)Dv5HmGsQX0(c8W7RF9)b]] )

end
