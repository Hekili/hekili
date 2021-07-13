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
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireCelestialAlignment, buff.nesingwarys_apparatus.expires )
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


    spec:RegisterPack( "Beast Mastery", 20210713, [[d8un6bqibQhbsjDjqkXMubFcHAuiLofsXQeiPELOIzPIQBbsXUG8lqsdtujhtaltu1ZqizAie11aj2MOs13eiX4iOQ6CiKQ1Hq4DeufAEIsDpvO9jk5FeuL6GcKQfcs1dvr0eriLUOOsXhfvknscQIojcPyLeKzQIWnjOkyNQO8tbszOeuLSubsYtf0uvr6RGukJvG4Seuv2Rk9xHgmWHPSyc9yIMSixg1Mr0NbLrdQoTsRgKs1RrQMTe3ws2nv)wQHJGJJqKLR45qnDsxhjBNaFheJNGY5ffRNGkZxsTFv9nW90ByYu(Ew(CLpqUckbikuUe(dKNidLBOMHaFdjys6gm(g6wfFdHoBy9bcpyyLNm3qcwMsBP7P3qCtns(gcxvcyIaQqf2QWPerYUcQ4TIQy62UCmsfQ4Tsc1BOi1wuIg)kEdtMY3ZYNR8bYvqjarHYLWFG8efr)gAuk8EUHHB1jVHW3uI9R4nmXy5ne6SH1hi8GHvEY8aHNuUYZlKquLmpiarD(dYNR8bUHLfR47P3WetAuf9E69Sa3tVHMu32VHYMYvEIy4TEdz3elC6c9REpl)90Bi7MyHtxOFdnPUTFd1XCIe1wwHBDyrm8wVHjglNLGUTFdZT9dm4SLEG5PhC6yorIAlRWXp4mHxN8bSZvlJp)bq4hKANy9bP(bk8f)aYEEaHILHh8dezPrH5hSkXPhiYpq7(bycwvvMhyE6bq4hinNy9bdBPTK5bNoMtKEaMalxYv(arkssm6gkNv5zTByWpqTbgROfhjuSm8C17ze190Bi7MyHtxOFdLZQ8S2nu2cy3CfrpZSM)Gdpq2Dj1qCKHjWsn2KrfohHSLeA4kBD8do8az3LudXrdJB301HfTzAiOHRS1XpOU(bb)azlGDZve9mZA(do8az3LudXrgMal1ytgv4CeYwsOHRS1X3qtQB73qPvkrtQB7XYI1ByzXA0Tk(gQZ60zfF17ze57P3q2nXcNUq)gAsDB)gkTsjAsDBpwwSEdllwJUvX3qzcF17zq5E6nKDtSWPl0VHYzvEw7gAsDfWr25QLXpi7hK)gAsDB)gkTsjAsDBpwwSEdllwJUvX3qSE17z5(90Bi7MyHtxOFdLZQ8S2n0K6kGJSZvlJFqwpiWn0K62(nuALs0K62ESSy9gwwSgDRIVHYcBc4RE1BiHHLDLOP3tVNf4E6n0K62(netvv1EKaR3q2nXcNUq)Q3ZYFp9gAsDB)gk2Qw4uKSyz4eK1Hf1wyRFdz3elC6c9REpJOUNEdnPUTFdjlmgUCms9gYUjw40f6x9Egr(E6nKDtSWPl0VHUvX3qt4WWTXWrY21ytgj0q45gAsDB)gAchgUngos2UgBYiHgcpx9EguUNEdz3elC6c9BiHHLgwJ6wX3WaiOCdnPUTFdvBI6yeUHYzvEw7gouot2dmgHBQczpW4ixjYdgXUjw40dQRFWq5mzpWyKZy86WGytgCuhJaH1HfnceSXukmIDtSWPREpl3VNEdz3elC6c9BiHHLgwJ6wX3WaiOCdnPUTFdfzSUwjczmf(nuoRYZA3WGFGAf2vewYUgBYOyP7eIDtSWPhC4bb)GHYzYEGXiCtvi7bgh5krEWi2nXcNU69SGY90Bi7MyHtxOFdjmS0WAu3k(ggaru3WeJLZsq32VHb9e0ofwXpqHZpirnMUT)aZtpq2Dj1q8h0KpiOJjWs9bn5du48dG22s6bMNEGWRzRSYdiACSUUuXpqmZdu48dsuJPB7pOjFG5pGYHByLtpi3EsI2habo7pqHZziE4hqH50dimSSRenf9aOZsJcZpiOJjWs9bn5du48dG22s6bdNOKm(b52ts0(aXmpiFUYvf(8hOWx8dw8dcGiQhGzz7jm6gAsDB)gAycSuJnzuHZriBjDdLZQ8S2nm4hychpRYicZwzL46yDDPIrSBIfo9Gdpi4hWym7sgXym7so2KrfohjBjfEDyXDwmQYG275bhEaTpGjsulbcCczchgUngos2UgBYiHgcppOU(bb)aMirTeiWjKmJS060(kJIfdRpGMREpt4)E6nKDtSWPl0VHegwAynQBfFddGGYnmXy5Se0T9ByqpbTtHv8du48dsuJPB7pW80dKDxsne)bn5dGoJ11kpaABmf(dmp9aHNMWXpOjFqqLbJFGyMhOW5hKOgt32Fqt(aZFaLd3WkNEqU9KeTpacC2FGcNZq8WpGcZPhqyyzxjAk6gAsDB)gkYyDTseYyk8BOCwLN1UHMWXZQmIWSvwjUowxxQye7MyHtp4Wdc(bmgZUKrmgZUKJnzuHZrYwsHxhwCNfJQmO9EEWHhq7dyIe1sGaNqMWHHBJHJKTRXMmsOHWZdQRFqWpGjsulbcCcjZilToTVYOyXW6dO5Qx9gkt47P3ZcCp9gYUjw40f63q5SkpRDdLDxsnehjYyDTseYykC0Wv264hK1diQCDdnPUTFdnxYyDSsuALYvVNL)E6nKDtSWPl0VHYzvEw7gk7UKAiosKX6ALiKXu4OHRS1XpiRhqu56gAsDB)gsUdlw6oD17ze190Bi7MyHtxOFdLZQ8S2nK2hisrsIGSLuetyNvXikcpOU(bb)azlGDZvKVWGRrsJFWHhisrsImmbwQXMmQW5iKTKqueEWHhisrsIezSUwjczmfoIIWdO5bhEaTpGCHbxJdxzRJFqwpq2Dj1qCKipyEOVomuIAmDB)b58Ge1y62(dQRFaTpqTbgRi4Svu4ics9bz)aIckpOU(bb)a1kSRi6BPWtCDSUUurSBIfo9aAEanpOU(bIng)GdpGCHbxJdxzRJFq2piarDdnPUTFdf5bZd91HD17ze57P3q2nXcNUq)gkNv5zTBiTpqKIKebzlPiMWoRIrueEqD9dc(bYwa7MRiFHbxJKg)GdpqKIKezycSuJnzuHZriBjHOi8GdpqKIKejYyDTseYykCefHhqZdo8aAFa5cdUghUYwh)GSEGS7sQH4iXs3Pij1KbLOgt32FqopirnMUT)G66hq7duBGXkcoBffoIGuFq2pGOGYdQRFqWpqTc7kI(wk8exhRRlve7MyHtpGMhqZdQRFGyJXp4WdixyW14Wv264hK9dcK73qtQB73qXs3Pij1K5Q3ZGY90BOj1T9ByzHbxXrODQeSk21Bi7MyHtxOF17z5(90Bi7MyHtxOFdLZQ8S2nuKIKezycSuJnzuHZriBjHOi8G66hqUWGRXHRS1Xpi7hKp3VHMu32VHeADB)Qx9gQZ60zfFp9EwG7P3q2nXcNUq)g2eUHywVHMu32VHcSznXcFdfyfk(gksrsIgg3UPRdlAZ0qqueEqD9dePijrgMal1ytgv4CeYwsikc3qb2eDRIVH4mUmsr4Q3ZYFp9gYUjw40f63WMWneZ6n0K62(nuGnRjw4BOaRqX3qzlGDZve9mZA(do8arkss0W42nDDyrBMgcIIWdo8arkssKHjWsn2KrfohHSLeIIWdQRFqWpq2cy3CfrpZSM)GdpqKIKezycSuJnzuHZriBjHOiCdfyt0Tk(gI1PDyrCgxgPiC17ze190Bi7MyHtxOFdBc3qmRl5n0K62(nuGnRjw4BOaBIUvX3qSoTdlIZ4Y4Wv264BOCwLN1UHIuKKidtGLASjJkCoczljuQH43qbwHIJCbZ3qz3LudXrgMal1ytgv4CeYwsOHRS1X3qbwHIVHYUlPgIJgg3UPRdlAZ0qqdxzRJFq2cVFGS7sQH4idtGLASjJkCoczlj0Wv264REpJiFp9gYUjw40f63WMWneZ6sEdnPUTFdfyZAIf(gkWMOBv8neRt7WI4mUmoCLTo(gkNv5zTBOifjjYWeyPgBYOcNJq2scrr4gkWkuCKly(gk7UKAioYWeyPgBYOcNJq2scnCLTo(gkWku8nu2Dj1qC0W42nDDyrBMgcA4kBD8vVNbL7P3q2nXcNUq)g2eUHywxYBOj1T9BOaBwtSW3qb2eDRIVH4mUmoCLTo(gkNv5zTBOSfWU5kIEMzn)gkWkuCKly(gk7UKAioYWeyPgBYOcNJq2scnCLTo(gkWku8nu2Dj1qC0W42nDDyrBMgcA4kBD8dYs49dKDxsnehzycSuJnzuHZriBjHgUYwhF17z5(90Bi7MyHtxOFdnPUTFd1zD6Sg4gkNv5zTBiTpqN1PZksdGGB4ifMJIuKKpOU(bYwa7MRi6zM18hC4b6SoDwrAaeCdhLDxsne)b08GdpG2hiWM1elmcRt7WI4mUmsr4bhEaTpi4hiBbSBUIONzwZFWHhe8d0zD6SI08i4gosH5Oifj5dQRFGSfWU5kIEMzn)bhEqWpqN1PZksZJGB4OS7sQH4pOU(b6SoDwrAEKS7sQH4OHRS1XpOU(b6SoDwrAaeCdhPWCuKIK8bhEaTpi4hOZ60zfP5rWnCKcZrrksYhux)aDwNoRinas2Dj1qCuIAmDB)bzD8b6SoDwrAEKS7sQH4Oe1y62(dO5b11pqN1PZksdGGB4OS7sQH4p4Wdc(b6SoDwrAEeCdhPWCuKIK8bhEGoRtNvKgaj7UKAiokrnMUT)GSo(aDwNoRinps2Dj1qCuIAmDB)b08G66he8deyZAIfgH1PDyrCgxgPi8GdpG2he8d0zD6SI08i4gosH5Oifj5do8aAFGoRtNvKgaj7UKAiokrnMUT)aO5bq5bz)ab2SMyHr4mUmoCLTo(b11pqGnRjwyeoJlJdxzRJFqwpqN1PZksdGKDxsnehLOgt32FauFq(hqZdQRFGoRtNvKMhb3WrkmhfPijFWHhq7d0zD6SI0ai4gosH5Oifj5do8aDwNoRinas2Dj1qCuIAmDB)bzD8b6SoDwrAEKS7sQH4Oe1y62(do8aAFGoRtNvKgaj7UKAiokrnMUT)aO5bq5bz)ab2SMyHr4mUmoCLTo(b11pqGnRjwyeoJlJdxzRJFqwpqN1PZksdGKDxsnehLOgt32FauFq(hqZdQRFaTpi4hOZ60zfPbqWnCKcZrrksYhux)aDwNoRinps2Dj1qCuIAmDB)bzD8b6SoDwrAaKS7sQH4Oe1y62(dO5bhEaTpqN1PZksZJKDxsnehnSLY8GdpqN1PZksZJKDxsnehLOgt32Fa08aO8GSEGaBwtSWiCgxghUYwh)GdpqGnRjwyeoJlJdxzRJFq2pqN1PZksZJKDxsnehLOgt32FauFq(hux)GGFGoRtNvKMhj7UKAioAylL5bhEaTpqN1PZksZJKDxsnehnCLTo(bqZdGYdY(bcSznXcJW60oSioJlJdxzRJFWHhiWM1elmcRt7WI4mUmoCLTo(bz9G856bhEaTpqN1PZksdGKDxsnehLOgt32Fa08aO8GSFGaBwtSWiCgxghUYwh)G66hOZ60zfP5rYUlPgIJgUYwh)aO5bq5bz)ab2SMyHr4mUmoCLTo(bhEGoRtNvKMhj7UKAiokrnMUT)aO5bbY1dY5bcSznXcJWzCzC4kBD8dY(bcSznXcJW60oSioJlJdxzRJFqD9deyZAIfgHZ4Y4Wv264hK1d0zD6SI0aiz3LudXrjQX0T9ha1hK)b11pqGnRjwyeoJlJueEanpOU(b6SoDwrAEKS7sQH4OHRS1XpaAEauEqwpqGnRjwyewN2HfXzCzC4kBD8do8aAFGoRtNvKgaj7UKAiokrnMUT)aO5bq5bz)ab2SMyHryDAhweNXLXHRS1XpOU(bb)aDwNoRinacUHJuyoksrs(GdpG2hiWM1elmcNXLXHRS1XpiRhOZ60zfPbqYUlPgIJsuJPB7paQpi)dQRFGaBwtSWiCgxgPi8aAEanpGMhqZdO5b08G66hO2aJvKUvCu7yA5hK9deyZAIfgHZ4Y4Wv264hqZdQRFqWpqN1PZksdGGB4ifMJIuKKp4Wdc(bYwa7MRi6zM18hC4b0(aDwNoRinpcUHJuyoksrs(GdpG2hq7dc(bcSznXcJWzCzKIWdQRFGoRtNvKMhj7UKAioA4kBD8dY6bq5b08GdpG2hiWM1elmcNXLXHRS1XpiRhKpxpOU(b6SoDwrAEKS7sQH4OHRS1XpaAEauEqwpqGnRjwyeoJlJdxzRJFanpGMhux)GGFGoRtNvKMhb3WrkmhfPijFWHhq7dc(b6SoDwrAEeCdhLDxsne)b11pqN1PZksZJKDxsnehnCLTo(b11pqN1PZksZJKDxsnehLOgt32FqwhFGoRtNvKgaj7UKAiokrnMUT)aAEan3qCPv8nuN1PZAGREplOCp9gYUjw40f63qtQB73qDwNoR5VHYzvEw7gs7d0zD6SI08i4gosH5Oifj5dQRFGSfWU5kIEMzn)bhEGoRtNvKMhb3Wrz3LudXFanp4WdO9bcSznXcJW60oSioJlJueEWHhq7dc(bYwa7MRi6zM18hC4bb)aDwNoRinacUHJuyoksrs(G66hiBbSBUIONzwZFWHhe8d0zD6SI0ai4gok7UKAi(dQRFGoRtNvKgaj7UKAioA4kBD8dQRFGoRtNvKMhb3WrkmhfPijFWHhq7dc(b6SoDwrAaeCdhPWCuKIK8b11pqN1PZksZJKDxsnehLOgt32FqwhFGoRtNvKgaj7UKAiokrnMUT)aAEqD9d0zD6SI08i4gok7UKAi(do8GGFGoRtNvKgab3WrkmhfPijFWHhOZ60zfP5rYUlPgIJsuJPB7piRJpqN1PZksdGKDxsnehLOgt32FanpOU(bb)ab2SMyHryDAhweNXLrkcp4WdO9bb)aDwNoRinacUHJuyoksrs(GdpG2hOZ60zfP5rYUlPgIJsuJPB7paAEauEq2pqGnRjwyeoJlJdxzRJFqD9deyZAIfgHZ4Y4Wv264hK1d0zD6SI08iz3LudXrjQX0T9ha1hK)b08G66hOZ60zfPbqWnCKcZrrksYhC4b0(aDwNoRinpcUHJuyoksrs(GdpqN1PZksZJKDxsnehLOgt32FqwhFGoRtNvKgaj7UKAiokrnMUT)GdpG2hOZ60zfP5rYUlPgIJsuJPB7paAEauEq2pqGnRjwyeoJlJdxzRJFqD9deyZAIfgHZ4Y4Wv264hK1d0zD6SI08iz3LudXrjQX0T9ha1hK)b08G66hq7dc(b6SoDwrAEeCdhPWCuKIK8b11pqN1PZksdGKDxsnehLOgt32FqwhFGoRtNvKMhj7UKAiokrnMUT)aAEWHhq7d0zD6SI0aiz3LudXrdBPmp4Wd0zD6SI0aiz3LudXrjQX0T9hanpakpiRhiWM1elmcNXLXHRS1Xp4WdeyZAIfgHZ4Y4Wv264hK9d0zD6SI0aiz3LudXrjQX0T9ha1hK)b11pi4hOZ60zfPbqYUlPgIJg2szEWHhq7d0zD6SI0aiz3LudXrdxzRJFa08aO8GSFGaBwtSWiSoTdlIZ4Y4Wv264hC4bcSznXcJW60oSioJlJdxzRJFqwpiFUEWHhq7d0zD6SI08iz3LudXrjQX0T9hanpakpi7hiWM1elmcNXLXHRS1XpOU(b6SoDwrAaKS7sQH4OHRS1XpaAEauEq2pqGnRjwyeoJlJdxzRJFWHhOZ60zfPbqYUlPgIJsuJPB7paAEqGC9GCEGaBwtSWiCgxghUYwh)GSFGaBwtSWiSoTdlIZ4Y4Wv264hux)ab2SMyHr4mUmoCLTo(bz9aDwNoRinps2Dj1qCuIAmDB)bq9b5FqD9deyZAIfgHZ4YifHhqZdQRFGoRtNvKgaj7UKAioA4kBD8dGMhaLhK1deyZAIfgH1PDyrCgxghUYwh)GdpG2hOZ60zfP5rYUlPgIJsuJPB7paAEauEq2pqGnRjwyewN2HfXzCzC4kBD8dQRFqWpqN1PZksZJGB4ifMJIuKKp4WdO9bcSznXcJWzCzC4kBD8dY6b6SoDwrAEKS7sQH4Oe1y62(dG6dY)G66hiWM1elmcNXLrkcpGMhqZdO5b08aAEanpOU(bQnWyfPBfh1oMw(bz)ab2SMyHr4mUmoCLTo(b08G66he8d0zD6SI08i4gosH5Oifj5do8GGFGSfWU5kIEMzn)bhEaTpqN1PZksdGGB4ifMJIuKKp4WdO9b0(GGFGaBwtSWiCgxgPi8G66hOZ60zfPbqYUlPgIJgUYwh)GSEauEanp4WdO9bcSznXcJWzCzC4kBD8dY6b5Z1dQRFGoRtNvKgaj7UKAioA4kBD8dGMhaLhK1deyZAIfgHZ4Y4Wv264hqZdO5b11pi4hOZ60zfPbqWnCKcZrrksYhC4b0(GGFGoRtNvKgab3Wrz3LudXFqD9d0zD6SI0aiz3LudXrdxzRJFqD9d0zD6SI0aiz3LudXrjQX0T9hK1XhOZ60zfP5rYUlPgIJsuJPB7pGMhqZnexAfFd1zD6SM)Qx9gI17P3ZcCp9gYUjw40f63q5SkpRDdd(bJTPilGDfzPegXcBXk(b11pySnfzbSRilLWOHRS1XpiRheGOFdnPUTFdnmbwQXMmQW5iKTKU69S83tVHSBIfoDH(nuoRYZA3qrksse5WUWLbrr4bhEGifjjICyx4YGgUYwh)GSp(ayY0dQRFGifjjcYwsrmHDwfJOi8Gdpqc3gymosoMu32TYdY6bbqe5hC4bdLZK9aJrKJbRIDfhBYOcNJCjXt0CTWdgXUjw40n0K62(nu0grofXWB9Q3ZiQ7P3q2nXcNUq)gkNv5zTB4q5mzpWyeUPkK9aJJCLipye7MyHtp4WduBI6yeqdxzRJFq2paMm9Gdpq2Dj1qCezXggnCLTo(bz)ayY0n0K62(nuTjQJr4Q3ZiY3tVHSBIfoDH(n0K62(nKSydFdLZQ8S2nuTjQJrarr4bhEWq5mzpWyeUPkK9aJJCLipye7MyHt3WY6CuMUH5HYvVNbL7P3qtQB73qXs3jmCoDdz3elC6c9REpl3VNEdz3elC6c9BOCwLN1UHb)GX2uKfWUISucJyHTyf)G66hm2MISa2vKLsy0Wv264hK1dcq0VHMu32VHq2skIjSZQ4REplOCp9gAsDB)gswSmCkIH36nKDtSWPl0V69mH)7P3qtQB73q6BPeXWB9gYUjw40f6x9Egr)E6nKDtSWPl0VHYzvEw7gk7UKAioAyC7MUoSOntdbnCLTo(bz)ayY0do8aAFqWpqTc7kIfgHsJxbCedVve7MyHtpOU(bIuKKiXs3PcfwrueEanpOU(bb)azlGDZve9mZA(dQRFGS7sQH4OHXTB66WI2mne0Wv264hux)a1gySI0TIJAhtl)GSFauUHMu32VHqSTSoSOntd5Q3ZcKR7P3q2nXcNUq)gkNv5zTBOS7sQH4irgRRvIqgtHJgUYwh)GSFqG8piO(bs42aJXrYXK62UvEqopaMm9GdpqTc7kclzxJnzuS0DcXUjw40dQRFajvPehwc3gyCu3k(bz)ayY0do8az3LudXrImwxReHmMchnCLTo(b11pqTbgRiDR4O2X0Ypi7hq0VHMu32VHI2iYPigERx9EwGa3tVHSBIfoDH(nuoRYZA3qYwsHFqopqAynomm2Fq2pGSLuyuLjSBOj1T9ByInfEuc3Opw1vVNfi)90Bi7MyHtxOFdLZQ8S2nuKIKezycSuJnzuHZriBjHOi8G66hO2aJvKUvCu7yA5hK9dcaLBOj1T9BiwTkcCIV69Sae190BOj1T9BOfROMepXMmkNgc(gYUjw40f6x9EwaI890Bi7MyHtxOFdLZQ8S2nK2hisrsIezSUwjczmfoIIWdQRFGAdmwr6wXrTJPLFq2piqUEanp4WdO9bb)GX2uKfWUISucJyHTyf)G66hm2MISa2vKLsy0Wv264hK1dcq0Fan3qtQB73WHXTB66WI2mnKREplauUNEdz3elC6c9BOCwLN1UH0(az3LudXrq2skIjSZQy0Wv264hK1dcaLhux)azlGDZve9mZA(do8aAFGS7sQH4OHXTB66WI2mne0Wv264hK9dGYdQRFGS7sQH4OHXTB66WI2mne0Wv264hK1dYNRhqZdQRFGAdmwr6wXrTJPLFq2piauEqD9dO9bb)azlGDZvKVWGRrsJFWHhe8dKTa2nxr0ZmR5pGMhqZdo8aAFqWpySnfzbSRilLWiwylwXpOU(bJTPilGDfzPegnCLTo(bz9Gae9hqZn0K62(nuKX6ALiKXu4x9EwGC)E6n0K62(nucFRmESigER3q2nXcNUq)Q3ZceuUNEdnPUTFdPVLsu2vvMNUHSBIfoDH(vVNfq4)E6nKDtSWPl0VHYzvEw7gksrsIezSUwjczmfok1q8hux)aXgJFWHhqUWGRXHRS1Xpi7haLBOj1T9BOObl2KrDwjD8vVNfGOFp9gAsDB)gM2HJISH1Bi7MyHtxOF17z5Z190Bi7MyHtxOFdLZQ8S2nK2hq2sk8dGMhiBS(GCEazlPWOHHX(dcQFaTpq2Dj1qCe9TuIYUQY8eA4kBD8dGMhe4b08GSEGj1TDe9TuIYUQY8es2y9b11pq2Dj1qCe9TuIYUQY8eA4kBD8dY6bbEqopaMm9aAEqD9dO9bIuKKirgRRvIqgtHJOi8G66hisrsICgJxhgeBYGJ6yeiSoSOrGGnMsHrueEanp4Wdc(bdLZK9aJrejJqXI8WjkpcXMypjEqSBIfo9G66hi2y8do8aYfgCnoCLTo(bz)aI6gAsDB)gkBXXIy4TE17z5dCp9gYUjw40f63q5SkpRDdfPijrq2skIjSZQyefHhux)ajCBGX4i5ysDB3kpiRheaL)bhEGS9e1QiXs3PcR66WqSBIfoDdnPUTFdfTrKtrm8wV69S85VNEdz3elC6c9BOCwLN1UHIuKKirgRRvIqgtHJsne)b11pqSX4hC4bKlm4AC4kBD8dY(bq5gAsDB)gAJ0CosGQG5REplprDp9gYUjw40f63q5SkpRDdhkNj7bgJWnvHShyCKRe5bJy3elC6b11pyOCMShymYzmEDyqSjdoQJrGW6WIgbc2ykfgXUjw40n0K62(nuTjQJr4Q3ZYtKVNEdz3elC6c9BOCwLN1UHdLZK9aJroJXRddInzWrDmcewhw0iqWgtPWi2nXcNUHMu32VHKdZc36WI6yeU69S8q5E6nKDtSWPl0VHYzvEw7gs7diBjf(b58aYwsHrddJ9hKZdcaLhqZdY(bKTKcJQmHDdnPUTFdTrAoh1Eg21RE1BOSWMa(E69Sa3tVHSBIfoDH(nuoRYZA3WGFWyBkYcyxrwkHrSWwSIFqD9dgBtrwa7kYsjmA4kBD8dY64dcKRBOj1T9BOHjWsn2KrfohHSL0vVNL)E6nKDtSWPl0VHMu32VHI2iYPigER3q5SkpRDdfPijrKd7cxgefHhC4bIuKKiYHDHldA4kBD8dY(4dGjtpOU(bIuKKiiBjfXe2zvmIIWdo8ajCBGX4i5ysDB3kpiRhearKFWHhmuot2dmgrogSk2vCSjJkCoYLeprZ1cpye7MyHt3qzgzHJQnWyfFplWvVNru3tVHSBIfoDH(nuoRYZA3qyY0dGMhisrsIezdRrzHnbmA4kBD8dY6b5cLhk3qtQB73WkQIUy4TE17ze57P3q2nXcNUq)gkNv5zTB4q5mzpWyeHMscp2KXXeUEIKJbRIDfJy3elC6bhEGifjjISyz4bhRSHoIIWn0K62(nK(wkrm8wV69mOCp9gYUjw40f63q5SkpRDdhkNj7bgJi0us4XMmoMW1tKCmyvSRye7MyHt3qtQB73qYILHtrm8wV69SC)E6nKDtSWPl0VHYzvEw7gouot2dmgHBQczpW4ixjYdgXUjw40do8a1MOogb0Wv264hK9dGjtp4WdKDxsnehrwSHrdxzRJFq2paMmDdnPUTFdvBI6yeU69SGY90Bi7MyHtxOFdLZQ8S2nuTjQJrarr4bhEWq5mzpWyeUPkK9aJJCLipye7MyHt3qtQB73qYIn8vVNj8Fp9gYUjw40f63q5SkpRDdjBjf(b58aPH14WWy)bz)aYwsHrvMWUHMu32VHj2u4rjCJ(yvx9Egr)E6nKDtSWPl0VHYzvEw7gg8dgBtrwa7kYsjmIf2Iv8dQRFWyBkYcyxrwkHrdxzRJFqwhFqGCDdnPUTFdHSLuetyNvXx9EwGCDp9gYUjw40f63qtQB73qrBe5uedV1BOCwLN1UHKuLsCyjCBGXrDR4hK9dGjtp4WdKDxsnehjYyDTseYykC0Wv264hux)az3LudXrImwxReHmMchnCLTo(bz)Ga5FqopaMm9GdpqTc7kclzxJnzuS0DcXUjw40nuMrw4OAdmwX3ZcC17zbcCp9gYUjw40f63q5SkpRDdd(bJTPilGDfzPegXcBXk(b11pySnfzbSRilLWOHRS1XpiRJpak3qtQB73qrgRRvIqgtHF17zbYFp9gYUjw40f63q5SkpRDdd(bJTPilGDfzPegXcBXk(b11pySnfzbSRilLWOHRS1XpiRJpak3qtQB73WHXTB66WI2mnKREplarDp9gYUjw40f63q5SkpRDdfPijrgMal1ytgv4CeYwsikcpOU(bIng)GdpGCHbxJdxzRJFq2piauUHMu32VHy1QiWj(Q3ZcqKVNEdnPUTFdHyBzDyrBMgYnKDtSWPl0V69Saq5E6n0K62(nKSyz4uedV1Bi7MyHtxOF17zbY97P3qtQB73q6BPeXWB9gYUjw40f6x9EwGGY90BOj1T9BOe(wz8yrm8wVHSBIfoDH(vVNfq4)E6n0K62(nuS0DcdNt3q2nXcNUq)Q3Zcq0VNEdnPUTFdTyf1K4j2Kr50qW3q2nXcNUq)Q3ZYNR7P3q2nXcNUq)gkNv5zTBOifjjICyx4YGgUYwh)GSEalmwsPCu3k(gAsDB)gkAZyW4REplFG7P3q2nXcNUq)gkNv5zTBizlPWpiRhiBS(GCEGj1TDufvrxm8wrYgR3qtQB73q6BPeLDvL5PREplF(7P3q2nXcNUq)gkNv5zTBOifjjsKX6ALiKXu4OudXFqD9deBm(bhEa5cdUghUYwh)GSFauUHMu32VHIgSytg1zL0Xx9EwEI6E6n0K62(nmTdhfzdR3q2nXcNUq)Q3ZYtKVNEdz3elC6c9BOj1T9BOOnICkIH36nuoRYZA3q1gySI0TIJAhtl)GSFar)b11pqc3gymosoMu32TYdY6bbq5FWHhiBprTksS0DQWQUome7MyHt3qzgzHJQnWyfFplWvVNLhk3tVHSBIfoDH(nuoRYZA3qYwsHr6wXrTJvMWEq2paMm9GG6hK)gAsDB)gkBXXIy4TE17z5Z97P3q2nXcNUq)gkNv5zTB4q5mzpWyeUPkK9aJJCLipye7MyHtpOU(bdLZK9aJroJXRddInzWrDmcewhw0iqWgtPWi2nXcNUHMu32VHQnrDmcx9Ew(GY90Bi7MyHtxOFdLZQ8S2nCOCMShymYzmEDyqSjdoQJrGW6WIgbc2ykfgXUjw40n0K62(nKCyw4whwuhJWvVNLx4)E6nKDtSWPl0VHYzvEw7gs7diBjf(b58aYwsHrddJ9hKZdiQC9aAEq2pGSLuyuLjSBOj1T9BOnsZ5O2ZWUE1RE1BOaEWB73ZYNR8bYvqjxbUHqSXxhg(gcTf0dQoJO5SClr8GhCkC(bBfHE0hq2ZdiMWWYUs0uIFWWejQD40dWDf)aJs7kt50dKWnhgJrVqNyD(bqHiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFauiIhCY2fWJYPhq8q5mzpWyuqi(bA)aIhkNj7bgJccIDtSWjIFaTbegnOxOtSo)GCNiEWjBxapkNEaXQvyxrbH4hO9diwTc7kkii2nXcNi(b0gqy0GEHoX68dYDI4bNSDb8OC6bepuot2dmgfeIFG2pG4HYzYEGXOGGy3elCI4hy6dYnbTt8aAdimAqVqVqqBb9GQZiAol3sep4bNcNFWwrOh9bK98aI1zD6SIj(bdtKO2Htpa3v8dmkTRmLtpqc3Cymg9cDI15hK7eXdoz7c4r50dc3Qt(aCgxnH9aOLhO9dobL9G0kyXB7pOjWJP98aAHknpGwOimAqVqNyD(b5or8Gt2UaEuo9aI1zD6SIcGccXpq7hqSoRtNvKgafeIFaT5dimAqVqNyD(b5or8Gt2UaEuo9aI1zD6SIYJccXpq7hqSoRtNvKMhfeIFaT5ZDHrd6f6eRZpiOqep4KTlGhLtpiCRo5dWzC1e2dGwEG2p4eu2dsRGfVT)GMapM2ZdOfQ08aAHIWOb9cDI15heuiIhCY2fWJYPhqSoRtNvuauqi(bA)aI1zD6SI0aOGq8dOnFUlmAqVqNyD(bbfI4bNSDb8OC6beRZ60zfLhfeIFG2pGyDwNoRinpkie)aAZhqy0GEHEHG2c6bvNr0CwULiEWdofo)GTIqp6di75beltyIFWWejQD40dWDf)aJs7kt50dKWnhgJrVqNyD(befr8Gt2UaEuo9aIvRWUIccXpq7hqSAf2vuqqSBIfor8dOnGWOb9cDI15hqKjIhCY2fWJYPhqSAf2vuqi(bA)aIvRWUIccIDtSWjIFaTbegnOxOxiOTGEq1zenNLBjIh8GtHZpyRi0J(aYEEaXyL4hmmrIAho9aCxXpWO0UYuo9ajCZHXy0l0jwNFqEI4bNSDb8OC6bepuot2dmgfeIFG2pG4HYzYEGXOGGy3elCI4hy6dYnbTt8aAdimAqVqNyD(b5jIhCY2fWJYPhqmbwrbbj8HqiIFG2pGyHpecr8dOnVWOb9cDI15hqueXdoz7c4r50diEOCMShymkie)aTFaXdLZK9aJrbbXUjw4eXpG2acJg0l0jwNFarMiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFarNiEWjBxapkNEaXQvyxrbH4hO9diwTc7kkii2nXcNi(b0gqy0GEHoX68dcKlI4bNSDb8OC6beRwHDffeIFG2pGy1kSROGGy3elCI4hqBaHrd6f6eRZpiFUiIhCY2fWJYPhq8q5mzpWyuqi(bA)aIhkNj7bgJccIDtSWjIFaTbegnOxOtSo)G8biIhCY2fWJYPhqSS9e1QOGq8d0(belBprTkkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFqEIIiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFqEIIiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(b0gqy0GEHoX68dYtKjIhCY2fWJYPhq8q5mzpWyuqi(bA)aIhkNj7bgJccIDtSWjIFGPpi3e0oXdOnGWOb9c9cbTf0dQoJO5SClr8GhCkC(bBfHE0hq2Zdiwwytat8dgMirTdNEaUR4hyuAxzkNEGeU5Wym6f6eRZpipr8Gt2UaEuo9aIhkNj7bgJccXpq7hq8q5mzpWyuqqSBIfor8dm9b5MG2jEaTbegnOxOtSo)G8eXdoz7c4r50diMaROGGe(qieXpq7hqSWhcHi(b0Mxy0GEHoX68dikI4bNSDb8OC6betGvuqqcFieI4hO9diw4dHqe)aAdimAqVqNyD(bezI4bNSDb8OC6bepuot2dmgfeIFG2pG4HYzYEGXOGGy3elCI4hqBaHrd6f6eRZpakeXdoz7c4r50diEOCMShymkie)aTFaXdLZK9aJrbbXUjw4eXpW0hKBcAN4b0gqy0GEHoX68dYDI4bNSDb8OC6bepuot2dmgfeIFG2pG4HYzYEGXOGGy3elCI4hqBaHrd6f6eRZpiOqep4KTlGhLtpG4HYzYEGXOGq8d0(bepuot2dmgfee7MyHte)atFqUjODIhqBaHrd6f6eRZpiqUiIhCY2fWJYPhqSAf2vuqi(bA)aIvRWUIccIDtSWjIFGPpi3e0oXdOnGWOb9cDI15hKpxeXdoz7c4r50diMaROGGe(qieXpq7hqSWhcHi(b0gqy0GEHoX68dYtKjIhCY2fWJYPhqSS9e1QOGq8d0(belBprTkkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFq(CNiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(bM(GCtq7epG2acJg0l0jwNFq(CNiEWjBxapkNEaXdLZK9aJrbH4hO9diEOCMShymkii2nXcNi(b0gqy0GEHoX68dYhuiIhCY2fWJYPhq8q5mzpWyuqi(bA)aIhkNj7bgJccIDtSWjIFGPpi3e0oXdOnGWOb9c9cDkC(betH54QCfM4hysDB)bqm8d8wFazt5PhS(du4l(bBfHEu0lertfHEuo9GC)bMu32FqzXkg9cDdXey59S8qHOUHeMMCl8neAfA9bqNnS(aHhmSYtMhi8KYvEEHGwHwFGquLmpiarD(dYNR8bEHEHmPUTJregw2vIMEetvv1EKaRVqMu32Xicdl7krtZ5iufBvlCkswSmCcY6WIAlS1FHmPUTJregw2vIMMZrOswymC5yK6lKj1TDmIWWYUs00CocvkmhxLRo3Tk(OjCy42y4iz7ASjJeAi88czsDBhJimSSRennNJqvTjQJr4CcdlnSg1TIpgabLZxYJdLZK9aJr4MQq2dmoYvI8GRRhkNj7bgJCgJxhgeBYGJ6yeiSoSOrGGnMsHFHmPUTJregw2vIMMZrOkYyDTseYyk8ZjmS0WAu3k(yaeuoFjpgSAf2vewYUgBYOyP70HGhkNj7bgJWnvHShyCKRe5b)cbT(GGEcANcR4hOW5hKOgt32FG5Phi7UKAi(dAYhe0XeyP(GM8bkC(bqBBj9aZtpq41Svw5benowxxQ4hiM5bkC(bjQX0T9h0KpW8hq5WnSYPhKBpjr7dGaN9hOW5mep8dOWC6begw2vIMIEa0zPrH5he0XeyP(GM8bkC(bqBBj9GHtusg)GC7jjAFGyMhKpx5QcF(du4l(bl(bbqe1dWSS9eg9czsDBhJimSSRennNJq1WeyPgBYOcNJq2s6CcdlnSg1TIpgaruNVKhd2eoEwLreMTYkX1X66sfJy3elC6qWmgZUKrmgZUKJnzuHZrYwsHxhwCNfJQmO9EoqltKOwce4eYeomCBmCKSDn2KrcneEQRdMjsulbcCcjZilToTVYOyXWknVqqRpiONG2PWk(bkC(bjQX0T9hyE6bYUlPgI)GM8bqNX6ALhaTnMc)bMNEGWtt44h0KpiOYGXpqmZdu48dsuJPB7pOjFG5pGYHByLtpi3EsI2habo7pqHZziE4hqH50dimSSRenf9czsDBhJimSSRennNJqvKX6ALiKXu4NtyyPH1OUv8XaiOC(sE0eoEwLreMTYkX1X66sfJy3elC6qWmgZUKrmgZUKJnzuHZrYwsHxhwCNfJQmO9EoqltKOwce4eYeomCBmCKSDn2KrcneEQRdMjsulbcCcjZilToTVYOyXWknVqVqMu32X5CeQYMYvEIy4T(cbT(GCB)adoBPhyE6bNoMtKO2YkC8dot41jFa7C1YyHhFae(bP2jwFqQFGcFXpGSNhqOyz4b)arwAuy(bRsC6bI8d0UFaMGvvL5bMNEae(bsZjwFWWwAlzEWPJ5ePhGjWYLCLpqKIKeJEHmPUTJZ5iu1XCIe1wwHBDyrm8wpFjpgSAdmwrlosOyz45fcAfA9beTCXY8astUoShKPPMhKAkr9buUULhKPPEaCta)acu6dcQyC7MUoShe0NPH8GudXp)b98GL8bkC(bYUlPgI)Gf)aT7huAh2d0(bjUyzEaPjxh2dY0uZdiABkrf9aIgYh4TZpOjFGcNX8dKTNwDBh)aB4hyIf(bA)GkwFaKvHV(du48dcKRhGzz7j8dkmdXYC(du48dWB1dinjJFqMMAEarBtjQpWO0UY0vALsg0le0k06dmPUTJZ5iuDgczt5P4W4UiGpFjpIBQI46jKZqiBkpfhg3fb8bAfPijrdJB301HfTzAiikc11YUlPgIJgg3UPRdlAZ0qqdxzRJZkqUQRvBGXks3koQDmTC2bYDAEHmPUTJZ5iuLwPenPUThllwp3Tk(OoRtNv85l5rzlGDZve9mZA(bz3LudXrgMal1ytgv4CeYwsOHRS1XhKDxsnehnmUDtxhw0MPHGgUYwhxxhSSfWU5kIEMzn)GS7sQH4idtGLASjJkCoczlj0Wv264xitQB74CocvPvkrtQB7XYI1ZDRIpkt4xitQB74CocvPvkrtQB7XYI1ZDRIpI1ZxYJMuxbCKDUAzC25FHmPUTJZ5iuLwPenPUThllwp3Tk(OSWMa(8L8Oj1vahzNRwgNvGxOxitQB7yKmHpAUKX6yLO0kLZxYJYUlPgIJezSUwjczmfoA4kBDCwevUEHmPUTJrYeoNJqLChwS0D68L8OS7sQH4irgRRvIqgtHJgUYwhNfrLRxitQB7yKmHZ5iuf5bZd91HD(sEKwrksseKTKIyc7SkgrrOUoyzlGDZvKVWGRrsJpisrsImmbwQXMmQW5iKTKqueoisrsIezSUwjczmfoIIanhOLCHbxJdxzRJZs2Dj1qCKipyEOVomuIAmDBpNe1y62EDnTQnWyfbNTIchrqQztuqPUoy1kSRi6BPWtCDSUUuPHM6AXgJpqUWGRXHRS1XzhGOEHmPUTJrYeoNJqvS0DkssnzoFjpsRifjjcYwsrmHDwfJOiuxhSSfWU5kYxyW1iPXhePijrgMal1ytgv4CeYwsikchePijrImwxReHmMchrrGMd0sUWGRXHRS1Xzj7UKAiosS0DkssnzqjQX0T9CsuJPB7110Q2aJveC2kkCebPMnrbL66GvRWUIOVLcpX1X66sLgAQRfBm(a5cdUghUYwhNDGC)fYK62ogjt4Coc1YcdUIJq7ujyvSRVqMu32XizcNZrOsO1T9ZxYJIuKKidtGLASjJkCoczljefH6AYfgCnoCLToo785(l0lKj1TDmswytaF0WeyPgBYOcNJq2s68L8yWJTPilGDfzPegXcBXkUUESnfzbSRilLWOHRS1XzDmqUEHmPUTJrYcBc4CocvrBe5uedV1ZLzKfoQ2aJv8XaNVKhjWkQYwhjsrsIih2fUmikchiWkQYwhjsrsIih2fUmOHRS1XzFeMmvxlsrsIGSLuetyNvXikchKWTbgJJKJj1TDRKvaer(Wq5mzpWye5yWQyxXXMmQW5ixs8enxl8GFHmPUTJrYcBc4Coc1kQIUy4TE(sEeMmbneyfvzRJePijrISH1OSWMagnCLTooRCHYdLxitQB7yKSWMaoNJqL(wkrm8wpFjpouot2dmgrOPKWJnzCmHRNi5yWQyxXhePijrKfldp4yLn0rueEHmPUTJrYcBc4CocvYILHtrm8wpFjpouot2dmgrOPKWJnzCmHRNi5yWQyxXVqMu32XizHnbCohHQAtuhJW5l5XHYzYEGXiCtvi7bgh5krEWhuBI6yeqdxzRJZgMmDq2Dj1qCezXggnCLTooByY0lKj1TDmswytaNZrOswSHpFjpQ2e1XiGOiCyOCMShymc3ufYEGXrUsKh8lKj1TDmswytaNZrOMytHhLWn6JvD(sEKSLu4CKgwJddJ9SjBjfgvzc7fYK62ogjlSjGZ5iuHSLuetyNvXNVKhdESnfzbSRilLWiwylwX11JTPilGDfzPegnCLTooRJbY1lKj1TDmswytaNZrOkAJiNIy4TEUmJSWr1gySIpg48L8ijvPehwc3gyCu3koByY0bz3LudXrImwxReHmMchnCLToUUw2Dj1qCKiJ11kriJPWrdxzRJZoq(CGjthuRWUIWs21ytgflDNEHmPUTJrYcBc4CocvrgRRvIqgtHF(sEm4X2uKfWUISucJyHTyfxxp2MISa2vKLsy0Wv264SocLxitQB7yKSWMaoNJqDyC7MUoSOntd58L8yWJTPilGDfzPegXcBXkUUESnfzbSRilLWOHRS1XzDekVqMu32XizHnbCohHkwTkcCIpFjpksrsImmbwQXMmQW5iKTKqueQRfBm(a5cdUghUYwhNDaO8czsDBhJKf2eW5CeQqSTSoSOntd5fYK62ogjlSjGZ5iujlwgofXWB9fYK62ogjlSjGZ5iuPVLsedV1xitQB7yKSWMaoNJqvcFRmESigERVqMu32XizHnbCohHQyP7egoNEHmPUTJrYcBc4CocvlwrnjEInzuone8lKj1TDmswytaNZrOkAZyW4ZxYJeyfvzRJePijrKd7cxg0Wv264SyHXskLJ6wXVqMu32XizHnbCohHk9TuIYUQY805l5rYwsHZs2ynhtQB7OkQIUy4TIKnwFHmPUTJrYcBc4CocvrdwSjJ6Ss64ZxYJIuKKirgRRvIqgtHJsneVUwSX4dKlm4AC4kBDC2q5fYK62ogjlSjGZ5iut7Wrr2W6lKj1TDmswytaNZrOkAJiNIy4TEUmJSWr1gySIpg48L8OAdmwr6wXrTJPLZMOxxlHBdmghjhtQB7wjRaO8hKTNOwfjw6ovyvxh2lKj1TDmswytaNZrOkBXXIy4TE(sEKSLuyKUvCu7yLjSSHjtb15FHmPUTJrYcBc4Cocv1MOogHZxYJdLZK9aJr4MQq2dmoYvI8GRRhkNj7bgJCgJxhgeBYGJ6yeiSoSOrGGnMsHFHmPUTJrYcBc4CocvYHzHBDyrDmcNVKhhkNj7bgJCgJxhgeBYGJ6yeiSoSOrGGnMsHFHmPUTJrYcBc4CocvBKMZrTNHD98L8iTKTKcNdzlPWOHHXEoevUOjBYwsHrvMWEHEHmPUTJry9OHjWsn2KrfohHSL05l5XGhBtrwa7kYsjmIf2IvCD9yBkYcyxrwkHrdxzRJZkar)fYK62ogH1CocvrBe5uedV1ZxYJeyfvzRJePijrKd7cxgefHdeyfvzRJePijrKd7cxg0Wv264SpctMQRfPijrq2skIjSZQyefHds42aJXrYXK62UvYkaIiFyOCMShymICmyvSR4ytgv4CKljEIMRfEWVqMu32XiSMZrOQ2e1XiC(sECOCMShymc3ufYEGXrUsKh8b1MOogb0Wv264SHjthKDxsnehrwSHrdxzRJZgMm9czsDBhJWAohHkzXg(8Y6CuMoMhkNVKhvBI6yequeomuot2dmgHBQczpW4ixjYd(fYK62ogH1CocvXs3jmCo9czsDBhJWAohHkKTKIyc7Sk(8L8yWJTPilGDfzPegXcBXkUUESnfzbSRilLWOHRS1XzfGO)czsDBhJWAohHkzXYWPigERVqMu32XiSMZrOsFlLigERVqMu32XiSMZrOcX2Y6WI2mnKZxYJYUlPgIJgg3UPRdlAZ0qqdxzRJZgMmDG2GvRWUIyHrO04vahXWBTUwKIKejw6ovOWkIIan11blBbSBUIONzwZRRLDxsnehnmUDtxhw0MPHGgUYwhxxR2aJvKUvCu7yA5SHYlKj1TDmcR5CeQI2iYPigERNVKhLDxsnehjYyDTseYykC0Wv264SdKpOwc3gymosoMu32TsoWKPdQvyxryj7ASjJILUt11KuLsCyjCBGXrDR4SHjthKDxsnehjYyDTseYykC0Wv2646A1gySI0TIJAhtlNnr)fYK62ogH1Coc1eBk8OeUrFSQZxYJKTKcNJ0WACyySNnzlPWOktyVqMu32XiSMZrOIvRIaN4ZxYJIuKKidtGLASjJkCoczljefH6A1gySI0TIJAhtlNDaO8czsDBhJWAohHQfROMepXMmkNgc(fYK62ogH1Coc1HXTB66WI2mnKZxYJ0ksrsIezSUwjczmfoIIqDTAdmwr6wXrTJPLZoqUO5aTbp2MISa2vKLsyelSfR466X2uKfWUISucJgUYwhNvaIonVqMu32XiSMZrOkYyDTseYyk8ZxYJ0k7UKAiocYwsrmHDwfJgUYwhNvaOuxlBbSBUIONzwZpqRS7sQH4OHXTB66WI2mne0Wv264SHsDTS7sQH4OHXTB66WI2mne0Wv264SYNlAQRvBGXks3koQDmTC2bGsDnTblBbSBUI8fgCnsA8HGLTa2nxr0ZmR50qZbAdESnfzbSRilLWiwylwX11JTPilGDfzPegnCLTooRaeDAEHmPUTJrynNJqvcFRmESigERVqMu32XiSMZrOsFlLOSRQmp9czsDBhJWAohHQObl2KrDwjD85l5rrkssKiJ11kriJPWrPgIxxl2y8bYfgCnoCLTooBO8czsDBhJWAohHAAhokYgwFHmPUTJrynNJqv2IJfXWB98L8iTKTKcdnYgR5q2skmAyyShutRS7sQH4i6BPeLDvL5j0Wv26yOjanzzsDBhrFlLOSRQmpHKnwRRLDxsnehrFlLOSRQmpHgUYwhNvGCGjt0uxtRifjjsKX6ALiKXu4ikc11IuKKiNX41HbXMm4OogbcRdlAeiyJPuyefbAoe8q5mzpWyerYiuSipCIYJqSj2tIN6AXgJpqUWGRXHRS1XztuVqMu32XiSMZrOkAJiNIy4TE(sEuKIKebzlPiMWoRIrueQRLWTbgJJKJj1TDRKvau(dY2tuRIelDNkSQRd7fYK62ogH1CocvBKMZrcufmF(sEuKIKejYyDTseYykCuQH411IngFGCHbxJdxzRJZgkVqMu32XiSMZrOQ2e1XiC(sECOCMShymc3ufYEGXrUsKhCD9q5mzpWyKZy86WGytgCuhJaH1HfnceSXuk8lKj1TDmcR5CeQKdZc36WI6yeoFjpouot2dmg5mgVomi2Kbh1XiqyDyrJabBmLc)czsDBhJWAohHQnsZ5O2ZWUE(sEKwYwsHZHSLuy0WWypNaqHMSjBjfgvzc7f6fYK62ogPZ60zfFuGnRjw4ZDRIpIZ4YifHZfyfk(OifjjAyC7MUoSOntdbrrOUwKIKezycSuJnzuHZriBjHOi8czsDBhJ0zD6SIZ5iufyZAIf(C3Q4JyDAhweNXLrkcNlWku8rzlGDZve9mZA(brkss0W42nDDyrBMgcIIWbrkssKHjWsn2KrfohHSLeIIqDDWYwa7MRi6zM18dIuKKidtGLASjJkCoczljefHxitQB7yKoRtNvCohHQaBwtSWN7wfFeRt7WI4mUmoCLTo(8MWrmRl55Y2tRUTFu2cy3CfrpZSMFUaRqXhLDxsnehnmUDtxhw0MPHGgUYwhNTWBz3LudXrgMal1ytgv4CeYwsOHRS1XNlWkuCKly(OS7sQH4idtGLASjJkCoczlj0Wv264ZxYJIuKKidtGLASjJkCoczljuQH4VqMu32XiDwNoR4Cocvb2SMyHp3Tk(iwN2HfXzCzC4kBD85nHJywxYZLTNwDB)OSfWU5kIEMzn)CbwHIpk7UKAioAyC7MUoSOntdbnCLTo(CbwHIJCbZhLDxsnehzycSuJnzuHZriBjHgUYwhF(sEuKIKezycSuJnzuHZriBjHOi8czsDBhJ0zD6SIZ5iufyZAIf(C3Q4J4mUmoCLTo(8MWrmRl55Y2tRUTFu2cy3CfrpZSMFUaRqXhLDxsnehnmUDtxhw0MPHGgUYwhNLWBz3LudXrgMal1ytgv4CeYwsOHRS1XNlWkuCKly(OS7sQH4idtGLASjJkCoczlj0Wv264xitQB7yKoRtNvCohHkfMJRYv4ZXLwXh1zD6Sg48L8iT6SoDwrbqWnCKcZrrksY6AzlGDZve9mZA(bDwNoROai4gok7UKAionhOvGnRjwyewN2HfXzCzKIWbAdw2cy3CfrpZSMFiyDwNoRO8i4gosH5OifjzDTSfWU5kIEMzn)qW6SoDwr5rWnCu2Dj1q86ADwNoRO8iz3LudXrdxzRJRR1zD6SIcGGB4ifMJIuKKhOnyDwNoRO8i4gosH5OifjzDToRtNvuaKS7sQH4Oe1y62Ewh1zD6SIYJKDxsnehLOgt32PPUwN1PZkkacUHJYUlPgIFiyDwNoRO8i4gosH5Oifj5bDwNoROaiz3LudXrjQX0T9SoQZ60zfLhj7UKAiokrnMUTttDDWcSznXcJW60oSioJlJueoqBW6SoDwr5rWnCKcZrrksYd0QZ60zffaj7UKAiokrnMUTdnqjBb2SMyHr4mUmoCLToUUwGnRjwyeoJlJdxzRJZsN1PZkkas2Dj1qCuIAmDBhAjpn116SoDwr5rWnCKcZrrksYd0QZ60zffab3WrkmhfPijpOZ60zffaj7UKAiokrnMUTN1rDwNoRO8iz3LudXrjQX0T9d0QZ60zffaj7UKAiokrnMUTdnqjBb2SMyHr4mUmoCLToUUwGnRjwyeoJlJdxzRJZsN1PZkkas2Dj1qCuIAmDBhAjpn110gSoRtNvuaeCdhPWCuKIKSUwN1PZkkps2Dj1qCuIAmDBpRJ6SoDwrbqYUlPgIJsuJPB70CGwDwNoRO8iz3LudXrdBPmh0zD6SIYJKDxsnehLOgt32HgOKLaBwtSWiCgxghUYwhFqGnRjwyeoJlJdxzRJZwN1PZkkps2Dj1qCuIAmDBhAjFDDW6SoDwr5rYUlPgIJg2szoqRoRtNvuEKS7sQH4OHRS1XqduYwGnRjwyewN2HfXzCzC4kBD8bb2SMyHryDAhweNXLXHRS1XzLpxhOvN1PZkkas2Dj1qCuIAmDBhAGs2cSznXcJWzCzC4kBDCDToRtNvuEKS7sQH4OHRS1XqduYwGnRjwyeoJlJdxzRJpOZ60zfLhj7UKAiokrnMUTdnbYvocSznXcJWzCzC4kBDC2cSznXcJW60oSioJlJdxzRJRRfyZAIfgHZ4Y4Wv264S0zD6SIcGKDxsnehLOgt32HwYxxlWM1elmcNXLrkc0uxRZ60zfLhj7UKAioA4kBDm0aLSeyZAIfgH1PDyrCgxghUYwhFGwDwNoROaiz3LudXrjQX0TDObkzlWM1elmcRt7WI4mUmoCLToUUoyDwNoROai4gosH5Oifj5bAfyZAIfgHZ4Y4Wv264S0zD6SIcGKDxsnehLOgt32HwYxxlWM1elmcNXLrkc0qdn0qdn11QnWyfPBfh1oMwoBb2SMyHr4mUmoCLToMM66G1zD6SIcGGB4ifMJIuKKhcw2cy3CfrpZSMFGwDwNoRO8i4gosH5Oifj5bAPnyb2SMyHr4mUmsrOUwN1PZkkps2Dj1qC0Wv264SGcnhOvGnRjwyeoJlJdxzRJZkFUQR1zD6SIYJKDxsnehnCLTogAGswcSznXcJWzCzC4kBDmn0uxhSoRtNvuEeCdhPWCuKIK8aTbRZ60zfLhb3Wrz3LudXRR1zD6SIYJKDxsnehnCLToUUwN1PZkkps2Dj1qCuIAmDBpRJ6SoDwrbqYUlPgIJsuJPB70qZlKj1TDmsN1PZkoNJqLcZXv5k854sR4J6SoDwZF(sEKwDwNoRO8i4gosH5OifjzDTSfWU5kIEMzn)GoRtNvuEeCdhLDxsneNMd0kWM1elmcRt7WI4mUmsr4aTblBbSBUIONzwZpeSoRtNvuaeCdhPWCuKIKSUw2cy3CfrpZSMFiyDwNoROai4gok7UKAiEDToRtNvuaKS7sQH4OHRS1X116SoDwr5rWnCKcZrrksYd0gSoRtNvuaeCdhPWCuKIKSUwN1PZkkps2Dj1qCuIAmDBpRJ6SoDwrbqYUlPgIJsuJPB70uxRZ60zfLhb3Wrz3LudXpeSoRtNvuaeCdhPWCuKIK8GoRtNvuEKS7sQH4Oe1y62Ewh1zD6SIcGKDxsnehLOgt32PPUoyb2SMyHryDAhweNXLrkchOnyDwNoROai4gosH5Oifj5bA1zD6SIYJKDxsnehLOgt32HgOKTaBwtSWiCgxghUYwhxxlWM1elmcNXLXHRS1XzPZ60zfLhj7UKAiokrnMUTdTKNM6ADwNoROai4gosH5Oifj5bA1zD6SIYJGB4ifMJIuKKh0zD6SIYJKDxsnehLOgt32Z6OoRtNvuaKS7sQH4Oe1y62(bA1zD6SIYJKDxsnehLOgt32HgOKTaBwtSWiCgxghUYwhxxlWM1elmcNXLXHRS1XzPZ60zfLhj7UKAiokrnMUTdTKNM6AAdwN1PZkkpcUHJuyoksrswxRZ60zffaj7UKAiokrnMUTN1rDwNoRO8iz3LudXrjQX0TDAoqRoRtNvuaKS7sQH4OHTuMd6SoDwrbqYUlPgIJsuJPB7qduYsGnRjwyeoJlJdxzRJpiWM1elmcNXLXHRS1XzRZ60zffaj7UKAiokrnMUTdTKVUoyDwNoROaiz3LudXrdBPmhOvN1PZkkas2Dj1qC0Wv26yObkzlWM1elmcRt7WI4mUmoCLTo(GaBwtSWiSoTdlIZ4Y4Wv264SYNRd0QZ60zfLhj7UKAiokrnMUTdnqjBb2SMyHr4mUmoCLToUUwN1PZkkas2Dj1qC0Wv26yObkzlWM1elmcNXLXHRS1Xh0zD6SIcGKDxsnehLOgt32HMa5khb2SMyHr4mUmoCLTooBb2SMyHryDAhweNXLXHRS1X11cSznXcJWzCzC4kBDCw6SoDwr5rYUlPgIJsuJPB7ql5RRfyZAIfgHZ4YifbAQR1zD6SIcGKDxsnehnCLTogAGswcSznXcJW60oSioJlJdxzRJpqRoRtNvuEKS7sQH4Oe1y62o0aLSfyZAIfgH1PDyrCgxghUYwhxxhSoRtNvuEeCdhPWCuKIK8aTcSznXcJWzCzC4kBDCw6SoDwr5rYUlPgIJsuJPB7ql5RRfyZAIfgHZ4YifbAOHgAOHM6A1gySI0TIJAhtlNTaBwtSWiCgxghUYwhttDDW6SoDwr5rWnCKcZrrksYdblBbSBUIONzwZpqRoRtNvuaeCdhPWCuKIK8aT0gSaBwtSWiCgxgPiuxRZ60zffaj7UKAioA4kBDCwqHMd0kWM1elmcNXLXHRS1XzLpx116SoDwrbqYUlPgIJgUYwhdnqjlb2SMyHr4mUmoCLToMgAQRdwN1PZkkacUHJuyoksrsEG2G1zD6SIcGGB4OS7sQH4116SoDwrbqYUlPgIJgUYwhxxRZ60zffaj7UKAiokrnMUTN1rDwNoRO8iz3LudXrjQX0TDAO5Qx9Eb]] )

end
