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

            usable = function ()
                if not pet.alive then return false, "requires a living pet" end
                if settings.check_pet_range and Hekili:PetBasedTargetDetectionIsReady( true ) and not Hekili:TargetIsNearPet( "target" ) then return false, "not in-range of pet" end
                return true
            end,

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


    spec:RegisterPack( "Beast Mastery", 20210804, [[d8KrZcqirKhPkvYLejKnjQ8jvjgfuPtHaRsKq9ke0Seb3svs2Lk)scmmjOoMOQLjHEMeetteIUMQu2MQuvFtecghIaCorizDIe8orivAEIKUhIAFIO(hIa6GsqYcfH6HicnrvPsDreb1hLGuJuesvNuecTsOIzIiYnfHuXorK6Nic0qvLk0sfHuEku1urK8vebzSQsQZQkvWEj4Vu1Gr6WuwmHEmvMmrxg1Mb1NbXObPtl1QvLk61i0SL0TLODl8Bfdxv54QsvwUsphy6KUou2UQQVRkgVirNxKA9iIA(IY(HSqEbsjGxAklq6IfUy(ctcOWjYlF(IVv89fWRP)yb8FMJObHfWhwjlGpXSbuenrhdO8Mwa)NLUoMuGuc4bd26yb8qv9dKcfuaKwHIjEUPSaqxIvnTNWTgSwaOlDfiGxeRRAIyiikGxAklq6IfUy(ctcOWjYlF(IVvSOaEdtHoRaE8DjjkGhAlLCiikGxYaNa(eZgqr0eDmGYBAenrpwO8IWPqHbbdOiAImbeTyHlMhHdchseQfqyqkGW5viAIg)komXkJOj2wrwIO4HokIwOxZXi67iV9ipeoiCmN2taUVLDtPOPKbyLLt4)yfHJ50EcW9TSBkfnLqYfioQwzPhUAPz5thq86KYoq4yoTNaCFl7MsrtjKCbWvga1TgSIWXCApb4(w2nLIMsi5cWaSVvUmHWkzYgjdGARb8WtO(b2)np8IWXCApb4(w2nLIMsi5cuB96AFj8TSZaQx7sMC(7TeAyYlwWWZcHpWGvHNfc75srEbzzlwWWZcHVGbGoG8yBAGxx77RdiE77ZwtXaiCmN2taUVLDtPOPesUargOTv9pRPqt4BzNbuV2Lm583Bj0WKtsTkh6bCCO(b2lwNrMlPfly4zHWhyWQWZcH9CPiVaeofk57edOaevHYiQeBnTNarTqIOUzQY5jq0bgrluGp2Pi6aJOkugrjH6QerTqIOVJBxAvenrmaAhofGOIPrufkJOsS10EceDGrulquSaQbuwIOfAs8DJOpq5arvOC6xwgrXaSer)w2nLIMEiAIzNHbyeTqb(yNIOdmIQqzeLeQRseDzjMJbiAHMeF3iQyAeTyHlCjibevH2aeTbiA(Rqqua7MqcoeoMt7ja33YUPu0ucjxGb(yN6hyVcL9pDvMW3YodOETlzY5VcjHgMCsgjZBR89TDPv9Da0oCk44WeRSmxsmaWHJpga4WX(b2Rqzp84WaDaX3BdUs7DoBoC53dR)(y5zKmaQTgWdpH6hy)38WBwws87H1FFS8CPD1r3jANxSAaLaeofk57edOaevHYiQeBnTNarTqIOUzQY5jq0bgrtmd02Qikj0Akue1cjIMO3izgrhyenrZGWiQyAevHYiQeBnTNarhye1ceflGAaLLiAHMeF3i6duoqufkN(LLrumalr0VLDtPOPhchZP9eG7Bz3ukAkHKlqKbABv)ZAk0e(w2za1RDjto)9wcnmzJK5Tv((2U0Q(oaAhofCCyIvwMljga4WXhdaC4y)a7vOShECyGoG47TbxP9oNnhU87H1FFS8msga1wd4HNq9dS)BE4nllj(9W6VpwEU0U6O7eTZlwnGsacheoMt7jaesUa3GfkVEa0rr4uOhe1GYMerTqIOKAT49W6AtYmIs63rser5GlBgKOlI(WiQCIxuevoiQcTbik8Si6x1sZlarfzNHbyeT1xKiQiJO6mik4ZkltJOwir0hgrDw8IIOlBYUMgrj1AX7HOGp21WTdrfXGHbhchZP9eacjxGUw8EyDTj5oG4bqhnHgMCsQTqy9AG)RAP5fHZ7MRwAef2CDabrtpylIkhmrfrXcTRiA6bdrHA)mI(HPiAIgdMW0oGGOfQDNhevoprci6SiAdJOkugrDZuLZtGOnar1zq06eqquDqujxT0ikS56acIMEWwe9DpyI6HOjIWiAmbJOdmIQqzaJOUjKT2taquBze1eRmIQdIwYkI(0k0oqufkJO5lmIcy3esaIwz(XsNaIQqzef0LikS5yaIMEWwe9DpyIkIAy6uAA7SAn9HWXCApbGqYfe8d8Gfs)YGP(Zj0WKbdwvSd5f8d8Gfs)YGP(Z5Wvedg(wgmHPDaXB7oph2xwMBMQCEIBzWeM2beVT78ClxADasoFHZYuBHW6PDj71XlBo18VpbiCmN2taiKCboRw9Mt7j81gOjewjtw3oiYkiHgMSB(5Wc9iMEBlY5MPkNN4mWh7u)a7vOS)PRYB5sRdqo3mv58e3YGjmTdiEB355wU06aKLLKB(5Wc9iMEBlY5MPkNN4mWh7u)a7vOS)PRYB5sRdachZP9eacjxGZQvV50EcFTbAcHvYKDsachZP9eacjxGZQvV50EcFTbAcHvYKbAcnmzZP9p75GlBgKAreoMt7jaesUaNvREZP9e(Ad0ecRKj7QS9Zj0WKnN2)SNdUSzqY5r4GWXCApb4CsazlCmqxR6DwTMqdt2ntvopXjYaTTQ)znf6TCP1bi5cPWiCmN2taoNeqi5cG7LfRZitOHj7MPkNN4ezG2w1)SMc9wU06aKCHuyeoMt7jaNtciKCbI8c4LyhqsOHjJRigm890vPh81BRGd7lllj38ZHf6fneOQh24CIyWWNb(yN6hyVcL9pDvEyF5eXGHprgOTv9pRPqpSpcYHlCdbQ6xU06aKSBMQCEItKxaVe7aYjXwt7jiuITM2tKLHRAlewpOSvvO3NttTqElllj1QCOhXUw513bq7WPeqqwM4aa5GBiqv)YLwhGuZxiiCmN2taoNeqi5ceRZi9WyB6eAyY4kIbdFpDv6bF92k4W(YYsYn)CyHErdbQ6HnoNigm8zGp2P(b2Rqz)txLh2xormy4tKbABv)ZAk0d7JGC4c3qGQ(LlToaj7MPkNN4eRZi9WyB6tITM2tqOeBnTNildx1wiSEqzRQqVpNMAH8wwwsQv5qpIDTYRVdG2HtjGGSmXbaYb3qGQ(LlToaPM)9r4yoTNaCojGqYfuBiqvG)DIjHuYHIWXCApb4CsaHKl4B0EIeAyYIyWWNb(yN6hyVcL9pDvEyFzzWneOQF5sRdqQfFFeoiCmN2taoxLTFMSb(yN6hyVcL9pDvMqdtoP1APN)5qptkbhNYgOGSS1APN)5qptkb3YLwhGKjNVWzzMt7F2Zbx2mizYR1sp)ZHEMuco3GfAkUichZP9eGZvz7NjKCbI2kYspa6Oj4s7QSxTfcRaY5tOHj)X6vADCIyWWh8YbjN(W(Y9X6vADCIyWWh8YbjN(wU06aKkziojHI2kYspa6OEiR5y)hV9iZYeXGHVNUk9GVEBfCyF5CqTfcd8WR50EcRMC(lrMBXcgEwi8bVgKsouGFG9ku2ZvjVEl0kVaeoMt7jaNRY2pti5ckXQAdGoAcnmzio5R(y9kToormy4tKnG6Dv2(5B5sRdqYf(k(gchZP9eGZvz7NjKCbe7A1dGoAcnm5fly4zHW33G5G6hy)AK8SE41GuYHcYjIbdFWvlnVaFPTepSpeoMt7jaNRY2pti5cGRwAw6bqhnHgM8Ifm8Sq47BWCq9dSFnsEwp8Aqk5qbiCmN2taoxLTFMqYfO2611(sOHjVybdple(adwfEwiSNlf5fKtT1RR9DlxADasfItMZntvopXbxTLVLlToaPcXjr4yoTNaCUkB)mHKlaUAlNqdtwT1RR9DyF5wSGHNfcFGbRcple2ZLI8cq4yoTNaCUkB)mHKlqYMc17GAexRmHgMm84Wae6mG6xgchPcpomWvAPeHJ50EcW5QS9ZesUGNUk9GVEBfKqdtoP1APN)5qptkbhNYgOGSS1APN)5qptkb3YLwhGKjNVWzzMt7F2Zbx2mizYR1sp)ZHEMuco3GfAkUichZP9eGZvz7NjKCbI2kYspa6Oj4s7QSxTfcRaY5tOHjdJvR(LDqTfc71UKtfItMZntvopXjYaTTQ)znf6TCP1bilZntvopXjYaTTQ)znf6TCP1bi18fjeItMtTkh6bCCO(b2lwNrIWXCApb4Cv2(zcjxGid02Q(N1uOj0WKtATw65Fo0ZKsWXPSbkilBTw65Fo0ZKsWTCP1bizYVLLzoT)zphCzZGKjVwl98ph6zsj4CdwOP4IiCmN2taoxLTFMqYfSmyct7aI32DEsOHjN0AT0Z)CONjLGJtzduqw2AT0Z)CONjLGB5sRdqYKFllZCA)ZEo4YMbjtETw65Fo0ZKsW5gSqtXfr4yoTNaCUkB)mHKlaOw5hl5eAyYIyWWNb(yN6hyVcL9pDvEyFzzIdaKdUHav9lxADasn)BiCmN2taoxLTFMqYf8yDTdiEB35bHJ50EcW5QS9ZesUa4QLMLEa0rr4yoTNaCUkB)mHKlGyxREa0rr4yoTNaCUkB)mHKlWbTlnEnpa6OiCmN2taoxLTFMqYfiwNrcGYseoMt7jaNRY2pti5cmFj2k51pWE3opaeoMt7jaNRY2pti5ceTDniCcnm5pwVsRJtedg(Gxoi503YLwhGK5uYomL9AxYiCmN2taoxLTFMqYfqSRvVBklTqMqdtgECyGKDdqj0CApXvIv1gaD0ZnafHJ50EcW5QS9ZesUardIFG962oIGeAyYIyWWNid02Q(N1uONCEISmXbaYb3qGQ(LlToaP(gchZP9eGZvz7NjKCbYEzViBafHJ50EcW5QS9ZesUarBfzPhaD0eCPDv2R2cHva58j0WKvBHW6PDj71XlBo1evwMdQTqyGhEnN2ty1KZFfZ5MqI16jwNrwzv7acchZP9eGZvz7NjKCbUrCnpa6Oj0WKHhhg40UK964lTuMkeNmfxeHJ50EcW5QS9ZesUa1wVU2xcnm5fly4zHWhyWQWZcH9CPiVGSSfly4zHWxWaqhqESnnWRR991beV99zRPyaeoMt7jaNRY2pti5cGxMj5oG411(sOHjVybdple(cga6aYJTPbEDTVVoG4TVpBnfdGWXCApb4Cv2(zcjxGTolyVo7YHMqdtgx4XHbieECyGBziCqyHuycsfECyGR0sjcheoMt7jahqjBGp2P(b2Rqz)txLj0WKtATw65Fo0ZKsWXPSbkillP1APN)5qptkbh2xoCxRLE(Nd9mPeCsS10EccxRLE(Nd9mPeCDKAXcNLH7AT0Z)CONjLGZnyHsoFo38ZHf6rm92wqabzzR1sp)ZHEMucoSVCR1sp)ZHEMucULlToajNprHWXCApb4akHKlq0wrw6bqhnHgM8hRxP1XjIbdFWlhKC6d7l3hRxP1XjIbdFWlhKC6B5sRdqQKH4KekARil9aOJ6HSMJ9F82Jmltedg(E6Q0d(6TvWH9LZb1wimWdVMt7jSAY5VezUfly4zHWh8Aqk5qb(b2RqzpxL86TqR8cq4yoTNaCaLqYfO2611(sOHjVybdple(adwfEwiSNlf5fKtT1RR9DlxADasfItMZntvopXbxTLVLlToaPcXjr4yoTNaCaLqYfaxTLtO2b7DsYfFlHgMSARxx77W(YTybdple(adwfEwiSNlf5fGWXCApb4akHKlqSoJeaLLiCmN2taoGsi5cE6Q0d(6Tvqcnm5KwRLE(Nd9mPeCCkBGcYYsATw65Fo0ZKsWH9LBTw65Fo0ZKsWjXwt7jiCTw65Fo0ZKsW1rQflCw2AT0Z)CONjLGd7l3AT0Z)CONjLGB5sRdqY5tuiCmN2taoGsi5cGRwAw6bqhfHJ50EcWbucjxaXUw9aOJIWXCApb4akHKl4X6Ahq82UZtcnmz3mv58e3YGjmTdiEB355wU06aKkeNmhUjPwLd94u(vhq)ZEa0rZYeXGHpX6mYkgqpSpcYYsYn)CyHEetVTfzzUzQY5jULbtyAhq82UZZTCP1biltTfcRN2LSxhVS5uFdHJ50EcWbucjxGOTIS0dGoAcnmz3mv58eNid02Q(N1uO3YLwhGuZxmf7GAleg4HxZP9ewLqiozo1QCOhWXH6hyVyDgzwgmwT6x2b1wiSx7soviozo3mv58eNid02Q(N1uO3YLwhGSm1wiSEAxYED8YMtnrHWXCApb4akHKlqYMc17GAexRmHgMm84Wae6mG6xgchPcpomWvAPeHJ50EcWbucjxaqTYpwYj0WKfXGHpd8Xo1pWEfk7F6Q8W(YYuBHW6PDj71XlBo18VHWXCApb4akHKlW8LyRKx)a7D78aq4yoTNaCaLqYfSmyct7aI32DEsOHjJRigm8jYaTTQ)znf6H9LLP2cH1t7s2RJx2CQ5lmb5WnP1APN)5qptkbhNYgOGSSKwRLE(Nd9mPeCyF5WDTw65Fo0ZKsWjXwt7jiCTw65Fo0ZKsW1rQflCw2AT0Z)CONjLGZnyHsopbzzR1sp)ZHEMucoSVCR1sp)ZHEMucULlToajNprrachZP9eGdOesUargOTv9pRPqtOHjJRBMQCEI7PRsp4R3wb3YLwhGKZ)wwMB(5Wc9iMEBlYHRBMQCEIBzWeM2beVT78ClxADas9TSm3mv58e3YGjmTdiEB355wU06aKCXctqwMAlewpTlzVoEzZPM)TSmCtYn)CyHErdbQ6HnoxsU5Ndl0Jy6TTGacYHBsR1sp)ZHEMucooLnqbzzjTwl98ph6zsj4W(YH7AT0Z)CONjLGtITM2tq4AT0Z)CONjLGRJulw4SS1APN)5qptkbNBWcLCEcYYwRLE(Nd9mPeCyF5wRLE(Nd9mPeClxADasoFIIaeoMt7jahqjKCboODPXR5bqhfHJ50EcWbucjxaXUw9UPS0cjchZP9eGdOesUardIFG962oIGeAyYIyWWNid02Q(N1uONCEISmXbaYb3qGQ(LlToaP(gchZP9eGdOesUazVSxKnGIWXCApb4akHKlWnIR5bqhnHgMmUWJdd8k3aucHhhg4wgchPyCDZuLZtCe7A17MYslK3YLwhGxLNGKnN2tCe7A17MYslKNBaAwMBMQCEIJyxRE3uwAH8wU06aKCEcH4KeKLHRigm8jYaTTQ)znf6H9LLjIbdFbdaDa5X20aVU23xhq823NTMIboSpcYL0Ifm8Sq479SVQ55LLyH)Xw)SsEZYehaihCdbQ6xU06aKAHGWXCApb4akHKlq0wrw6bqhnHgMSigm890vPh81BRGd7llZb1wimWdVMt7jSAY5VI5CtiXA9eRZiRSQDabHJ50EcWbucjxGToly)hwfWj0WKfXGHprgOTv9pRPqp58ezzIdaKdUHav9lxADas9neoMt7jahqjKCbQTEDTVeAyYlwWWZcHpWGvHNfc75srEbzzlwWWZcHVGbGoG8yBAGxx77RdiE77ZwtXaiCmN2taoGsi5cGxMj5oG411(sOHjVybdple(cga6aYJTPbEDTVVoG4TVpBnfdGWXCApb4akHKlWwNfSxND5qtOHjJl84WaecpomWTmeoim)BeKk84WaxPLseoiCmN2taoD7GiRaY)22MyLtiSsMmiD48yFj8BvmMSigm8Tmyct7aI32DEoSVSmrmy4ZaFSt9dSxHY(NUkpSpeoMt7jaNUDqKvaHKl4322eRCcHvYKb6obepiD48yFj8BvmMSB(5Wc9iMEBlYjIbdFldMW0oG4TDNNd7lNigm8zGp2P(b2Rqz)txLh2xwwsU5Ndl0Jy6TTiNigm8zGp2P(b2Rqz)txLh2hchZP9eGt3oiYkGqYf8BBBIvoHWkzYaDNaIhKoC(LlToajmFKbS2Wj4Mq2Apbz38ZHf6rm92wKWVvXyYUzQY5jULbtyAhq82UZZTCP1bivsGUzQY5jod8Xo1pWEfk7F6Q8wU06aKWVvXypxbmz3mv58eNb(yN6hyVcL9pDvElxADasOHjlIbdFg4JDQFG9ku2)0v5jNNaHJ50EcWPBhezfqi5c(TTnXkNqyLmzGUtaXdsho)YLwhGeMpYawB4eCtiBTNGSB(5Wc9iMEBls43Qymz3mv58e3YGjmTdiEB355wU06aKWVvXypxbmz3mv58eNb(yN6hyVcL9pDvElxADasOHjlIbdFg4JDQFG9ku2)0v5H9HWXCApb40TdISciKCb)22MyLtiSsMmiD48lxADasy(idyTHtWnHS1EcYU5Ndl0Jy6TTiHFRIXKDZuLZtCldMW0oG4TDNNB5sRdqYKaDZuLZtCg4JDQFG9ku2)0v5TCP1biHFRIXEUcyYUzQY5jod8Xo1pWEfk7F6Q8wU06aGWXCApb40TdISciKCbya23kxcsauhfqw3oiYA(eAyY4QBhez9YFqnGhdWErmy4Sm38ZHf6rm92wKt3oiY6L)GAaVBMQCEccYH7VTTjw5dO7eq8G0HZJ9Ld3KCZphwOhX0BBrUK0TdISEfpOgWJbyVigmCwMB(5Wc9iMEBlYLKUDqK1R4b1aE3mv58ezz62brwVINBMQCEIB5sRdqwMUDqK1l)b1aEma7fXGHZHBs62brwVIhud4XaSxedgolt3oiY6L)CZuLZtCsS10EIKjRBhez9kEUzQY5joj2AApbbzz62brwV8hud4DZuLZtKljD7GiRxXdQb8ya2lIbdNt3oiY6L)CZuLZtCsS10EIKjRBhez9kEUzQY5joj2AApbbzzj9BBBIv(a6obepiD48yF5WnjD7GiRxXdQb8ya2lIbdNdxD7GiRx(ZntvopXjXwt7jE1BP(BBBIv(aPdNF5sRdqw2VTTjw5dKoC(LlToajRBhez9YFUzQY5joj2AAprkQibzz62brwVIhud4XaSxedgohU62brwV8hud4XaSxedgoNUDqK1l)5MPkNN4KyRP9ejtw3oiY6v8CZuLZtCsS10EIC4QBhez9YFUzQY5joj2AApXREl1FBBtSYhiD48lxADaYY(TTnXkFG0HZVCP1bizD7GiRx(ZntvopXjXwt7jsrfjild3K0TdISE5pOgWJbyVigmCwMUDqK1R45MPkNN4KyRP9ejtw3oiY6L)CZuLZtCsS10EccYHRUDqK1R45MPkNN4w2KPZPBhez9kEUzQY5joj2AApXREl5FBBtSYhiD48lxADaY9BBBIv(aPdNF5sRdqQ62brwVINBMQCEItITM2tKIkMLLKUDqK1R45MPkNN4w2KPZHRUDqK1R45MPkNN4wU06a8Q3s9322eR8b0DciEq6W5xU06aK7322eR8b0DciEq6W5xU06aKCXcNdxD7GiRx(ZntvopXjXwt7jE1BP(BBBIv(aPdNF5sRdqwMUDqK1R45MPkNN4wU06a8Q3s9322eR8bsho)YLwhGC62brwVINBMQCEItITM2t8Q8fMWFBBtSYhiD48lxADas9322eR8b0DciEq6W5xU06aKL9BBBIv(aPdNF5sRdqY62brwV8NBMQCEItITM2tKIkML9BBBIv(aPdNh7JGSmD7GiRxXZntvopXTCP1b4vVL8VTTjw5dO7eq8G0HZVCP1bihU62brwV8NBMQCEItITM2t8Q3s9322eR8b0DciEq6W5xU06aKLLKUDqK1l)b1aEma7fXGHZH7VTTjw5dKoC(LlToajRBhez9YFUzQY5joj2AAprkQyw2VTTjw5dKoCESpciGaciGGSm1wiSEAxYED8YMt9322eR8bsho)YLwhacYYss3oiY6L)GAapgG9IyWW5sYn)CyHEetVTf5Wv3oiY6v8GAapgG9IyWW5Wf3K(TTnXkFG0HZJ9LLPBhez9kEUzQY5jULlToaj)gb5W9322eR8bsho)YLwhGKlw4SmD7GiRxXZntvopXTCP1b4vVL8VTTjw5dKoC(LlToaeqqwws62brwVIhud4XaSxedgohUjPBhez9kEqnG3ntvoprwMUDqK1R45MPkNN4wU06aKLPBhez9kEUzQY5joj2AAprYK1TdISE5p3mv58eNeBnTNGacq4yoTNaC62brwbesUama7BLlbjaQJciRBhezTycnmzC1TdISEfpOgWJbyVigmCwMB(5Wc9iMEBlYPBhez9kEqnG3ntvopbb5W9322eR8b0DciEq6W5X(YHBsU5Ndl0Jy6TTixs62brwV8hud4XaSxedgolZn)CyHEetVTf5ss3oiY6L)GAaVBMQCEISmD7GiRx(ZntvopXTCP1bilt3oiY6v8GAapgG9IyWW5WnjD7GiRx(dQb8ya2lIbdNLPBhez9kEUzQY5joj2AAprYK1TdISE5p3mv58eNeBnTNGGSmD7GiRxXdQb8UzQY5jYLKUDqK1l)b1aEma7fXGHZPBhez9kEUzQY5joj2AAprYK1TdISE5p3mv58eNeBnTNGGSSK(TTnXkFaDNaIhKoCESVC4MKUDqK1l)b1aEma7fXGHZHRUDqK1R45MPkNN4KyRP9eV6Tu)TTnXkFG0HZVCP1bil7322eR8bsho)YLwhGK1TdISEfp3mv58eNeBnTNifvKGSmD7GiRx(dQb8ya2lIbdNdxD7GiRxXdQb8ya2lIbdNt3oiY6v8CZuLZtCsS10EIKjRBhez9YFUzQY5joj2AAproC1TdISEfp3mv58eNeBnTN4vVL6VTTjw5dKoC(LlToazz)22MyLpq6W5xU06aKSUDqK1R45MPkNN4KyRP9ePOIeKLHBs62brwVIhud4XaSxedgolt3oiY6L)CZuLZtCsS10EIKjRBhez9kEUzQY5joj2AApbb5Wv3oiY6L)CZuLZtClBY050TdISE5p3mv58eNeBnTN4vVL8VTTjw5dKoC(LlToa5(TTnXkFG0HZVCP1bivD7GiRx(ZntvopXjXwt7jsrfZYss3oiY6L)CZuLZtClBY05Wv3oiY6L)CZuLZtClxADaE1BP(BBBIv(a6obepiD48lxADaY9BBBIv(a6obepiD48lxADasUyHZHRUDqK1R45MPkNN4KyRP9eV6Tu)TTnXkFG0HZVCP1bilt3oiY6L)CZuLZtClxADaE1BP(BBBIv(aPdNF5sRdqoD7GiRx(ZntvopXjXwt7jEv(ct4VTTjw5dKoC(LlToaP(BBBIv(a6obepiD48lxADaYY(TTnXkFG0HZVCP1bizD7GiRxXZntvopXjXwt7jsrfZY(TTnXkFG0HZJ9rqwMUDqK1l)5MPkNN4wU06a8Q3s(322eR8b0DciEq6W5xU06aKdxD7GiRxXZntvopXjXwt7jE1BP(BBBIv(a6obepiD48lxADaYYss3oiY6v8GAapgG9IyWW5W9322eR8bsho)YLwhGK1TdISEfp3mv58eNeBnTNifvml7322eR8bshop2hbeqabeqqwMAlewpTlzVoEzZP(BBBIv(aPdNF5sRdabzzjPBhez9kEqnGhdWErmy4Cj5MFoSqpIP32IC4QBhez9YFqnGhdWErmy4C4IBs)22MyLpq6W5X(YY0TdISE5p3mv58e3YLwhGKFJGC4(BBBIv(aPdNF5sRdqYflCwMUDqK1l)5MPkNN4wU06a8Q3s(322eR8bsho)YLwhaciilljD7GiRx(dQb8ya2lIbdNd3K0TdISE5pOgW7MPkNNilt3oiY6L)CZuLZtClxADaYY0TdISE5p3mv58eNeBnTNizY62brwVINBMQCEItITM2tqabc4RnqbcKsaVKHnSQkqkbsNxGuc4nN2tiG3nyHYRhaDub8CyIvwkKybvG0ffiLaEomXklfsSaEZP9ec411I3dRRnj3bepa6Oc4LmWT9N2tiGVqpiQbLnjIAHerj1AX7H11MKzeL0VJKiIYbx2mibe9Hru5eVOiQCqufAdqu4zr0VQLMxaIkYoddWiARVirurgr1zquWNvwMgrTqIOpmI6S4ffrx2KDnnIsQ1I3drbFSRHBhIkIbddob8UTvEBtaFsiQAlewVg4)QwAEfubsxicKsaphMyLLcjwaVBBL32eW7MFoSqpIP32cenhI6MPkNN4mWh7u)a7vOS)PRYB5sRdaIMdrDZuLZtCldMW0oG4TDNNB5sRdaIMLHOjHOU5Ndl0Jy6TTarZHOUzQY5jod8Xo1pWEfk7F6Q8wU06aiG3CApHaENvREZP9e(Adub81gO(Wkzb862brwbcQaPtKcKsaphMyLLcjwaV50Ecb8oRw9Mt7j81gOc4Rnq9HvYc4DsGGkq63eiLaEomXklfsSaE32kVTjG3CA)ZEo4YMbiAQiArb8Mt7jeW7SA1BoTNWxBGkGV2a1hwjlGhOcQaPFFbsjGNdtSYsHelG3TTYBBc4nN2)SNdUSzaIMmIMxaV50Ecb8oRw9Mt7j81gOc4Rnq9HvYc4Dv2(zbvqfW)TSBkfnvGucKoVaPeWBoTNqapaRSCc)hRc45WeRSuiXcQaPlkqkb8Mt7jeWloQwzPhUAPz5thq86KYoeWZHjwzPqIfubsxicKsaV50Ecb8Wvga1TgSkGNdtSYsHelOcKorkqkb8CyIvwkKyb8HvYc4nsga1wd4HNq9dS)BE4vaV50Ecb8gjdGARb8WtO(b2)np8kOcK(nbsjGNdtSYsHelG)BzNbuV2LSa(83Bc4nN2tiGxT1RR9jG3TTYBBc4xSGHNfcFGbRcple2ZLI8coomXklr0SmeDXcgEwi8fma0bKhBtd86AFFDaXBFF2Akg44WeRSuqfi97lqkb8CyIvwkKyb8Fl7mG61UKfWN)EtaV50Ecb8ImqBR6FwtHkG3TTYBBc4tcrvRYHEahhQFG9I1zKhhMyLLiAoenjeDXcgEwi8bgSk8SqypxkYl44WeRSuqfiDIGaPeWZHjwzPqIfW)TSZaQx7swaF(RqeWlzGB7pTNqaFHs(oXakarvOmIkXwt7jqulKiQBMQCEceDGr0cf4JDkIoWiQcLrusOUkrulKi6742LwfrtedG2HtbiQyAevHYiQeBnTNarhye1ceflGAaLLiAHMeF3i6duoqufkN(LLrumalr0VLDtPOPhIMy2zyagrluGp2Pi6aJOkugrjH6QerxwI5yaIwOjX3nIkMgrlw4cxcsarvOnarBaIM)keefWUjKGtaV50Ecb8g4JDQFG9ku2)0vPaE32kVTjGpje1izEBLVVTlTQVdG2HtbhhMyLLiAoenjeLbaoC8Xaaho2pWEfk7HhhgOdi(EBWvAVZzr0CikUik)Ey93hlpJKbqT1aE4ju)a7)MhEr0SmenjeLFpS(7JLNlTRo6or78IvdOikbcQaPjbiqkb8CyIvwkKyb8Fl7mG61UKfWN)EtaVKbUT)0Ecb8fk57edOaevHYiQeBnTNarTqIOUzQY5jq0bgrtmd02Qikj0Akue1cjIMO3izgrhyenrZGWiQyAevHYiQeBnTNarhye1ceflGAaLLiAHMeF3i6duoqufkN(LLrumalr0VLDtPOPNaEZP9ec4fzG2w1)SMcvaVBBL32eWBKmVTY332Lw13bq7WPGJdtSYsenhIMeIYaaho(yaGdh7hyVcL9WJdd0beFVn4kT35SiAoefxeLFpS(7JLNrYaO2Aap8eQFG9FZdViAwgIMeIYVhw)9XYZL2vhDNODEXQbueLabvqfWRBhezfiqkbsNxGuc45WeRSuiXc4Npb8awfWBoTNqa)VTTjwzb8)wfJfWlIbdFldMW0oG4TDNNd7drZYqurmy4ZaFSt9dSxHY(NUkpSpb8)26dRKfWdshop2NGkq6IcKsaphMyLLcjwa)8jGhWQaEZP9ec4)TTnXklG)3QySaE38ZHf6rm92wGO5qurmy4BzWeM2beVT78CyFiAoevedg(mWh7u)a7vOS)PRYd7drZYq0Kqu38ZHf6rm92wGO5qurmy4ZaFSt9dSxHY(NUkpSpb8)26dRKfWd0DciEq6W5X(eubsxicKsaphMyLLcjwa)8jGhWAdlG3CApHa(FBBtSYc4)T1hwjlGhO7eq8G0HZVCP1bqaVBBL32eWlIbdFg4JDQFG9ku2)0v5jNNqa)VvXypxbSaE3mv58eNb(yN6hyVcL9pDvElxADaeW)BvmwaVBMQCEIBzWeM2beVT78ClxADaq0ujbIOUzQY5jod8Xo1pWEfk7F6Q8wU06aiOcKorkqkb8CyIvwkKyb8ZNaEaRnSaEZP9ec4)TTnXklG)3wFyLSaEGUtaXdsho)YLwhab8UTvEBtaVigm8zGp2P(b2Rqz)txLh2Na(FRIXEUcyb8UzQY5jod8Xo1pWEfk7F6Q8wU06aiG)3QySaE3mv58e3YGjmTdiEB355wU06aiOcK(nbsjGNdtSYsHelGF(eWdyTHfWBoTNqa)VTTjwzb8)26dRKfWdsho)YLwhab8UTvEBtaVB(5Wc9iMEBleW)Bvm2ZvalG3ntvopXzGp2P(b2Rqz)txL3YLwhab8)wfJfW7MPkNN4wgmHPDaXB7op3YLwhaenzsGiQBMQCEIZaFSt9dSxHY(NUkVLlToacQaPFFbsjGNdtSYsHelG3CApHaED7GiR5fW72w5Tnb84IO62brwpn)b1aEma7fXGHr0Sme1n)CyHEetVTfiAoev3oiY6P5pOgW7MPkNNarjarZHO4IO)22MyLpGUtaXdshop2hIMdrXfrtcrDZphwOhX0BBbIMdrtcr1TdISEAXdQb8ya2lIbdJOzziQB(5Wc9iMEBlq0CiAsiQUDqK1tlEqnG3ntvopbIMLHO62brwpT45MPkNN4wU06aGOzziQUDqK1tZFqnGhdWErmyyenhIIlIMeIQBhez90Ihud4XaSxedggrZYquD7GiRNM)CZuLZtCsS10EcenzYiQUDqK1tlEUzQY5joj2AApbIsaIMLHO62brwpn)b1aE3mv58eiAoenjev3oiY6PfpOgWJbyVigmmIMdr1TdISEA(ZntvopXjXwt7jq0KjJO62brwpT45MPkNN4KyRP9eikbiAwgIMeI(BBBIv(a6obepiD48yFiAoefxenjev3oiY6PfpOgWJbyVigmmIMdrXfr1TdISEA(ZntvopXjXwt7jq0xHOVHOPIO)22MyLpq6W5xU06aGOzzi6VTTjw5dKoC(LlToaiAYiQUDqK1tZFUzQY5joj2AApbIwaIwerjarZYquD7GiRNw8GAapgG9IyWWiAoefxev3oiY6P5pOgWJbyVigmmIMdr1TdISEA(ZntvopXjXwt7jq0KjJO62brwpT45MPkNN4KyRP9eiAoefxev3oiY6P5p3mv58eNeBnTNarFfI(gIMkI(BBBIv(aPdNF5sRdaIMLHO)22MyLpq6W5xU06aGOjJO62brwpn)5MPkNN4KyRP9eiAbiAreLaenldrXfrtcr1TdISEA(dQb8ya2lIbdJOzziQUDqK1tlEUzQY5joj2AApbIMmzev3oiY6P5p3mv58eNeBnTNarjarZHO4IO62brwpT45MPkNN4w2KPr0CiQUDqK1tlEUzQY5joj2AApbI(ke9nenze9322eR8bsho)YLwhaenhI(BBBIv(aPdNF5sRdaIMkIQBhez90INBMQCEItITM2tGOfGOfr0Smenjev3oiY6Pfp3mv58e3YMmnIMdrXfr1TdISEAXZntvopXTCP1barFfI(gIMkI(BBBIv(a6obepiD48lxADaq0Ci6VTTjw5dO7eq8G0HZVCP1bartgrlwyenhIIlIQBhez908NBMQCEItITM2tGOVcrFdrtfr)TTnXkFG0HZVCP1barZYquD7GiRNw8CZuLZtClxADaq0xHOVHOPIO)22MyLpq6W5xU06aGO5quD7GiRNw8CZuLZtCsS10Ece9viA(cJOeIO)22MyLpq6W5xU06aGOPIO)22MyLpGUtaXdsho)YLwhaenldr)TTnXkFG0HZVCP1bartgr1TdISEA(ZntvopXjXwt7jq0cq0IiAwgI(BBBIv(aPdNh7drjarZYquD7GiRNw8CZuLZtClxADaq0xHOVHOjJO)22MyLpGUtaXdsho)YLwhaenhIIlIQBhez908NBMQCEItITM2tGOVcrFdrtfr)TTnXkFaDNaIhKoC(LlToaiAwgIMeIQBhez908hud4XaSxedggrZHO4IO)22MyLpq6W5xU06aGOjJO62brwpn)5MPkNN4KyRP9eiAbiArenldr)TTnXkFG0HZJ9HOeGOeGOeGOeGOeGOeGOzziQAlewpTlzVoEzZiAQi6VTTjw5dKoC(LlToaikbiAwgIMeIQBhez908hud4XaSxedggrZHOjHOU5Ndl0Jy6TTarZHO4IO62brwpT4b1aEma7fXGHr0CikUikUiAsi6VTTjw5dKoCESpenldr1TdISEAXZntvopXTCP1bartgrFdrjarZHO4IO)22MyLpq6W5xU06aGOjJOflmIMLHO62brwpT45MPkNN4wU06aGOVcrFdrtgr)TTnXkFG0HZVCP1barjarjarZYq0KquD7GiRNw8GAapgG9IyWWiAoefxenjev3oiY6PfpOgW7MPkNNarZYquD7GiRNw8CZuLZtClxADaq0Smev3oiY6Pfp3mv58eNeBnTNartMmIQBhez908NBMQCEItITM2tGOeGOeiGhuhfiGx3oiYAEbvG0jccKsaphMyLLcjwaV50Ecb862brwlkG3TTYBBc4Xfr1TdISEAXdQb8ya2lIbdJOzziQB(5Wc9iMEBlq0CiQUDqK1tlEqnG3ntvopbIsaIMdrXfr)TTnXkFaDNaIhKoCESpenhIIlIMeI6MFoSqpIP32cenhIMeIQBhez908hud4XaSxedggrZYqu38ZHf6rm92wGO5q0KquD7GiRNM)GAaVBMQCEcenldr1TdISEA(ZntvopXTCP1barZYquD7GiRNw8GAapgG9IyWWiAoefxenjev3oiY6P5pOgWJbyVigmmIMLHO62brwpT45MPkNN4KyRP9eiAYKruD7GiRNM)CZuLZtCsS10EceLaenldr1TdISEAXdQb8UzQY5jq0CiAsiQUDqK1tZFqnGhdWErmyyenhIQBhez90INBMQCEItITM2tGOjtgr1TdISEA(ZntvopXjXwt7jqucq0Smenje9322eR8b0DciEq6W5X(q0CikUiAsiQUDqK1tZFqnGhdWErmyyenhIIlIQBhez90INBMQCEItITM2tGOVcrFdrtfr)TTnXkFG0HZVCP1barZYq0FBBtSYhiD48lxADaq0KruD7GiRNw8CZuLZtCsS10EceTaeTiIsaIMLHO62brwpn)b1aEma7fXGHr0CikUiQUDqK1tlEqnGhdWErmyyenhIQBhez90INBMQCEItITM2tGOjtgr1TdISEA(ZntvopXjXwt7jq0CikUiQUDqK1tlEUzQY5joj2AApbI(ke9nenve9322eR8bsho)YLwhaenldr)TTnXkFG0HZVCP1bartgr1TdISEAXZntvopXjXwt7jq0cq0IikbiAwgIIlIMeIQBhez90Ihud4XaSxedggrZYquD7GiRNM)CZuLZtCsS10EcenzYiQUDqK1tlEUzQY5joj2AApbIsaIMdrXfr1TdISEA(ZntvopXTSjtJO5quD7GiRNM)CZuLZtCsS10Ece9vi6BiAYi6VTTjw5dKoC(LlToaiAoe9322eR8bsho)YLwhaenvev3oiY6P5p3mv58eNeBnTNarlarlIOzziAsiQUDqK1tZFUzQY5jULnzAenhIIlIQBhez908NBMQCEIB5sRdaI(ke9nenve9322eR8b0DciEq6W5xU06aGO5q0FBBtSYhq3jG4bPdNF5sRdaIMmIwSWiAoefxev3oiY6Pfp3mv58eNeBnTNarFfI(gIMkI(BBBIv(aPdNF5sRdaIMLHO62brwpn)5MPkNN4wU06aGOVcrFdrtfr)TTnXkFG0HZVCP1barZHO62brwpn)5MPkNN4KyRP9ei6Rq08fgrjer)TTnXkFG0HZVCP1bartfr)TTnXkFaDNaIhKoC(LlToaiAwgI(BBBIv(aPdNF5sRdaIMmIQBhez90INBMQCEItITM2tGOfGOfr0Sme9322eR8bshop2hIsaIMLHO62brwpn)5MPkNN4wU06aGOVcrFdrtgr)TTnXkFaDNaIhKoC(LlToaiAoefxev3oiY6Pfp3mv58eNeBnTNarFfI(gIMkI(BBBIv(a6obepiD48lxADaq0Smenjev3oiY6PfpOgWJbyVigmmIMdrXfr)TTnXkFG0HZVCP1bartgr1TdISEAXZntvopXjXwt7jq0cq0IiAwgI(BBBIv(aPdNh7drjarjarjarjarjarjarZYqu1wiSEAxYED8YMr0ur0FBBtSYhiD48lxADaqucq0Smenjev3oiY6PfpOgWJbyVigmmIMdrtcrDZphwOhX0BBbIMdrXfr1TdISEA(dQb8ya2lIbdJO5quCruCr0Kq0FBBtSYhiD48yFiAwgIQBhez908NBMQCEIB5sRdaIMmI(gIsaIMdrXfr)TTnXkFG0HZVCP1bartgrlwyenldr1TdISEA(ZntvopXTCP1barFfI(gIMmI(BBBIv(aPdNF5sRdaIsaIsaIMLHOjHO62brwpn)b1aEma7fXGHr0CikUiAsiQUDqK1tZFqnG3ntvopbIMLHO62brwpn)5MPkNN4wU06aGOzziQUDqK1tZFUzQY5joj2AApbIMmzev3oiY6Pfp3mv58eNeBnTNarjarjqapOokqaVUDqK1IcQGkG3jbcKsG05fiLaEomXklfsSaE32kVTjG3ntvopXjYaTTQ)znf6TCP1bartgrlKclG3CApHaElCmqxR6DwTkOcKUOaPeWZHjwzPqIfW72w5Tnb8UzQY5jorgOTv9pRPqVLlToaiAYiAHuyb8Mt7jeWd3llwNrkOcKUqeiLaEomXklfsSaE32kVTjGhxevedg(E6Q0d(6TvWH9HOzziAsiQB(5Wc9Igcu1dBmIMdrfXGHpd8Xo1pWEfk7F6Q8W(q0CiQigm8jYaTTQ)znf6H9HOeGO5quCru4gcu1VCP1bartgrDZuLZtCI8c4Lyhqoj2AApbIsiIkXwt7jq0SmefxevTfcRhu2Qk07ZPiAQiAH8gIMLHOjHOQv5qpIDTYRVdG2HtpomXklrucqucq0SmevCaaenhIc3qGQ(LlToaiAQiA(craV50Ecb8I8c4LyhqeubsNifiLaEomXklfsSaE32kVTjGhxevedg(E6Q0d(6TvWH9HOzziAsiQB(5Wc9Igcu1dBmIMdrfXGHpd8Xo1pWEfk7F6Q8W(q0CiQigm8jYaTTQ)znf6H9HOeGO5quCru4gcu1VCP1bartgrDZuLZtCI1zKEySn9jXwt7jqucruj2AApbIMLHO4IOQTqy9GYwvHEFofrtfrlK3q0SmenjevTkh6rSRvE9Da0oC6XHjwzjIsaIsaIMLHOIdaGO5qu4gcu1VCP1bartfrZ)(c4nN2tiGxSoJ0dJTPfubs)MaPeWBoTNqaFTHavb(3jMesjhQaEomXklfsSGkq63xGuc45WeRSuiXc4DBR82MaErmy4ZaFSt9dSxHY(NUkpSpenldrHBiqv)YLwhaenveT47lG3CApHa(Vr7jeubvapqfiLaPZlqkb8CyIvwkKyb8UTvEBtaFsi6AT0Z)CONjLGJtzduaIMLHOjHOR1sp)ZHEMucoSpenhIIlIUwl98ph6zsj4KyRP9eikHi6AT0Z)CONjLGRdenveTyHr0SmefxeDTw65Fo0ZKsW5gSqruYiAEenhI6MFoSqpIP32ceLaeLaenldrxRLE(Nd9mPeCyFiAoeDTw65Fo0ZKsWTCP1bartgrZNOeWBoTNqaVb(yN6hyVcL9pDvkOcKUOaPeWZHjwzPqIfW72w5Tnb8IyWWh8YbjN(W(q0CiQigm8bVCqYPVLlToaiAQKruiojIsiIkARil9aOJ6HSMJ9F82JerZYqurmy47PRsp4R3wbh2hIMdrDqTfcd8WR50EcRIOjJO5VejIMdrxSGHNfcFWRbPKdf4hyVcL9CvYR3cTYl44WeRSuaV50Ecb8I2kYspa6OcQaPlebsjGNdtSYsHelG3TTYBBc4xSGHNfcFGbRcple2ZLI8coomXklr0CiQARxx77wU06aGOPIOqCsenhI6MPkNN4GR2Y3YLwhaenvefItkG3CApHaE1wVU2NGkq6ePaPeWZHjwzPqIfWBoTNqapC1wwaVBBL32eWR2611(oSpenhIUybdple(adwfEwiSNlf5fCCyIvwkGV2b7Dsb8fFtqfi9BcKsaV50Ecb8I1zKaOSuaphMyLLcjwqfi97lqkb8CyIvwkKyb8UTvEBtaFsi6AT0Z)CONjLGJtzduaIMLHOjHOR1sp)ZHEMucoSpenhIUwl98ph6zsj4KyRP9eikHi6AT0Z)CONjLGRdenveTyHr0SmeDTw65Fo0ZKsWH9HO5q01APN)5qptkb3YLwhaenzenFIsaV50Ecb8pDv6bF92kqqfiDIGaPeWBoTNqapC1sZspa6Oc45WeRSuiXcQaPjbiqkb8Mt7jeWtSRvpa6Oc45WeRSuiXcQaPtucKsaphMyLLcjwaVBBL32eW7MPkNN4wgmHPDaXB7op3YLwhaenvefItIO5quCr0Kqu1QCOhNYV6a6F2dGo6XHjwzjIMLHOIyWWNyDgzfdOh2hIsaIMLHOjHOU5Ndl0Jy6TTarZYqu3mv58e3YGjmTdiEB355wU06aGOzziQAlewpTlzVoEzZiAQi6Bc4nN2tiG)X6Ahq82UZJGkq68fwGuc45WeRSuiXc4DBR82MaE3mv58eNid02Q(N1uO3YLwhaenvenFrenfJOoO2cHbE41CApHvrucruiojIMdrvRYHEahhQFG9I1zKhhMyLLiAwgIcJvR(LDqTfc71UKr0uruiojIMdrDZuLZtCImqBR6FwtHElxADaq0SmevTfcRN2LSxhVSzenvenrjG3CApHaErBfzPhaDubvG05Zlqkb8CyIvwkKyb8UTvEBtap84WaikHiQZaQFziCGOPIOWJddCLwkfWBoTNqaVKnfQ3b1iUwPGkq68ffiLaEomXklfsSaE32kVTjGxedg(mWh7u)a7vOS)PRYd7drZYqu1wiSEAxYED8YMr0ur08VjG3CApHaEGALFSKfubsNVqeiLaEZP9ec4nFj2k51pWE3opab8CyIvwkKybvG05tKcKsaphMyLLcjwaVBBL32eWJlIkIbdFImqBR6FwtHEyFiAwgIQ2cH1t7s2RJx2mIMkIMVWikbiAoefxenjeDTw65Fo0ZKsWXPSbkarZYq0Kq01APN)5qptkbh2hIMdrXfrxRLE(Nd9mPeCsS10EceLqeDTw65Fo0ZKsW1bIMkIwSWiAwgIUwl98ph6zsj4CdwOikzenpIsaIMLHOR1sp)ZHEMucoSpenhIUwl98ph6zsj4wU06aGOjJO5tuikbc4nN2tiGFzWeM2beVT78iOcKo)BcKsaphMyLLcjwaVBBL32eWJlI6MPkNN4E6Q0d(6TvWTCP1bartgrZ)gIMLHOU5Ndl0Jy6TTarZHO4IOUzQY5jULbtyAhq82UZZTCP1bartfrFdrZYqu3mv58e3YGjmTdiEB355wU06aGOjJOflmIsaIMLHOQTqy90UK964LnJOPIO5FdrZYquCr0Kqu38ZHf6fneOQh2yenhIMeI6MFoSqpIP32ceLaeLaenhIIlIMeIUwl98ph6zsj44u2afGOzziAsi6AT0Z)CONjLGd7drZHO4IOR1sp)ZHEMucoj2AApbIsiIUwl98ph6zsj46artfrlwyenldrxRLE(Nd9mPeCUblueLmIMhrjarZYq01APN)5qptkbh2hIMdrxRLE(Nd9mPeClxADaq0Kr08jkeLab8Mt7jeWlYaTTQ)znfQGkq68VVaPeWBoTNqaVdAxA8AEa0rfWZHjwzPqIfubsNprqGuc4nN2tiGNyxRE3uwAHuaphMyLLcjwqfiDEsacKsaphMyLLcjwaVBBL32eWlIbdFImqBR6FwtHEY5jq0SmevCaaenhIc3qGQ(LlToaiAQi6Bc4nN2tiGx0G4hyVUTJiqqfiD(eLaPeWBoTNqaVSx2lYgqfWZHjwzPqIfubsxSWcKsaphMyLLcjwaVBBL32eWJlIcpomaI(ke1nafrjerHhhg4wgchiAkgrXfrDZuLZtCe7A17MYslK3YLwhae9viAEeLaenze1CApXrSRvVBklTqEUbOiAwgI6MPkNN4i21Q3nLLwiVLlToaiAYiAEeLqefItIOeGOzzikUiQigm8jYaTTQ)znf6H9HOzziQigm8fma0bKhBtd86AFFDaXBFF2Akg4W(qucq0CiAsi6Ifm8Sq479SVQ55LLyH)Xw)SsEpomXklr0SmevCaaenhIc3qGQ(LlToaiAQiAHiG3CApHaE3iUMhaDubvG0fZlqkb8CyIvwkKyb8UTvEBtaVigm890vPh81BRGd7drZYquhuBHWap8AoTNWQiAYiA(RiIMdrDtiXA9eRZiRSQDa54WeRSuaV50Ecb8I2kYspa6OcQaPlwuGuc45WeRSuiXc4DBR82MaErmy4tKbABv)ZAk0topbIMLHOIdaGO5qu4gcu1VCP1bartfrFtaV50Ecb826SG9FyvalOcKUyHiqkb8CyIvwkKyb8UTvEBta)Ifm8Sq4dmyv4zHWEUuKxWXHjwzjIMLHOlwWWZcHVGbGoG8yBAGxx77RdiE77ZwtXahhMyLLc4nN2tiGxT1RR9jOcKUyIuGuc45WeRSuiXc4DBR82Ma(fly4zHWxWaqhqESnnWRR991beV99zRPyGJdtSYsb8Mt7jeWdVmtYDaXRR9jOcKU4BcKsaphMyLLcjwaVBBL32eWJlIcpomaIsiIcpomWTmeoqucr08VHOeGOPIOWJddCLwkfWBoTNqaVTolyVo7YHkOcQaExLTFwGucKoVaPeWZHjwzPqIfW72w5Tnb8jHOR1sp)ZHEMucooLnqbiAwgIUwl98ph6zsj4wU06aGOjtgrZxyenldrnN2)SNdUSzaIMmzeDTw65Fo0ZKsW5gSqr0umIwuaV50Ecb8g4JDQFG9ku2)0vPGkq6IcKsaphMyLLcjwaV50Ecb8I2kYspa6Oc4DBR82MaErmy4dE5GKtFyFiAoevedg(Gxoi503YLwhaenvYikeNerjerfTvKLEa0r9qwZX(pE7rIOzziQigm890vPh81BRGd7drZHOoO2cHbE41CApHvr0Kr08xIerZHOlwWWZcHp41GuYHc8dSxHYEUk51BHw5fCCyIvwkG3L2vzVAlewbcKoVGkq6crGuc45WeRSuiXc4DBR82MaEiojI(kevedg(ezdOExLTF(wU06aGOjJOf(k(MaEZP9ec4lXQAdGoQGkq6ePaPeWZHjwzPqIfW72w5Tnb8lwWWZcHVVbZb1pW(1i5z9WRbPKdfCCyIvwIO5qurmy4dUAP5f4lTL4H9jG3CApHaEIDT6bqhvqfi9BcKsaphMyLLcjwaVBBL32eWVybdple((gmhu)a7xJKN1dVgKsouWXHjwzPaEZP9ec4HRwAw6bqhvqfi97lqkb8CyIvwkKyb8UTvEBta)Ifm8Sq4dmyv4zHWEUuKxWXHjwzjIMdrvB96AF3YLwhaenvefItIO5qu3mv58ehC1w(wU06aGOPIOqCsb8Mt7jeWR2611(eubsNiiqkb8CyIvwkKyb8UTvEBtaVARxx77W(q0Ci6Ifm8Sq4dmyv4zHWEUuKxWXHjwzPaEZP9ec4HR2YcQaPjbiqkb8CyIvwkKyb8UTvEBtap84WaikHiQZaQFziCGOPIOWJddCLwkfWBoTNqaVKnfQ3b1iUwPGkq6eLaPeWZHjwzPqIfW72w5Tnb8jHOR1sp)ZHEMucooLnqbiAwgIUwl98ph6zsj4wU06aGOjtgrZxyenldrnN2)SNdUSzaIMmzeDTw65Fo0ZKsW5gSqr0umIwuaV50Ecb8pDv6bF92kqqfiD(clqkb8CyIvwkKyb8Mt7jeWlARil9aOJkG3TTYBBc4HXQv)YoO2cH9AxYiAQikeNerZHOUzQY5jorgOTv9pRPqVLlToaiAwgI6MPkNN4ezG2w1)SMc9wU06aGOPIO5lIOeIOqCsenhIQwLd9aoou)a7fRZipomXklfW7s7QSxTfcRabsNxqfiD(8cKsaphMyLLcjwaVBBL32eWNeIUwl98ph6zsj44u2afGOzzi6AT0Z)CONjLGB5sRdaIMmze9nenldrnN2)SNdUSzaIMmzeDTw65Fo0ZKsW5gSqr0umIwuaV50Ecb8ImqBR6FwtHkOcKoFrbsjGNdtSYsHelG3TTYBBc4tcrxRLE(Nd9mPeCCkBGcq0SmeDTw65Fo0ZKsWTCP1bartMmI(gIMLHOMt7F2Zbx2martMmIUwl98ph6zsj4CdwOiAkgrlkG3CApHa(LbtyAhq82UZJGkq68fIaPeWZHjwzPqIfW72w5Tnb8IyWWNb(yN6hyVcL9pDvEyFiAwgIkoaaIMdrHBiqv)YLwhaenven)Bc4nN2tiGhOw5hlzbvG05tKcKsaV50Ecb8pwx7aI32DEeWZHjwzPqIfubsN)nbsjG3CApHaE4QLMLEa0rfWZHjwzPqIfubsN)9fiLaEZP9ec4j21QhaDub8CyIvwkKybvG05teeiLaEZP9ec4Dq7sJxZdGoQaEomXklfsSGkq68KaeiLaEZP9ec4fRZibqzPaEomXklfsSGkq68jkbsjG3CApHaEZxITsE9dS3TZdqaphMyLLcjwqfiDXclqkb8CyIvwkKyb8UTvEBtaVigm8bVCqYPVLlToaiAYikNs2HPSx7swaV50Ecb8I2UgewqfiDX8cKsaphMyLLcjwaVBBL32eWdpomaIMmI6gGIOeIOMt7jUsSQ2aOJEUbOc4nN2tiGNyxRE3uwAHuqfiDXIcKsaphMyLLcjwaVBBL32eWlIbdFImqBR6FwtHEY5jq0SmevCaaenhIc3qGQ(LlToaiAQi6Bc4nN2tiGx0G4hyVUTJiqqfiDXcrGuc4nN2tiGx2l7fzdOc45WeRSuiXcQaPlMifiLaEomXklfsSaEZP9ec4fTvKLEa0rfW72w5Tnb8QTqy90UK964LnJOPIOjkenldrDqTfcd8WR50EcRIOjJO5VIiAoe1nHeR1tSoJSYQ2bKJdtSYsb8U0Uk7vBHWkqG05fubsx8nbsjGNdtSYsHelG3TTYBBc4Hhhg40UK964lTuIOPIOqCsenfJOffWBoTNqaVBexZdGoQGkq6IVVaPeWZHjwzPqIfW72w5Tnb8lwWWZcHpWGvHNfc75srEbhhMyLLiAwgIUybdple(cga6aYJTPbEDTVVoG4TVpBnfdCCyIvwkG3CApHaE1wVU2NGkq6IjccKsaphMyLLcjwaVBBL32eWVybdple(cga6aYJTPbEDTVVoG4TVpBnfdCCyIvwkG3CApHaE4LzsUdiEDTpbvG0fjbiqkb8CyIvwkKyb8UTvEBtapUik84WaikHik84Wa3Yq4arjerlKcJOeGOPIOWJddCLwkfWBoTNqaVTolyVo7YHkOcQGkG)NxqpHaPlw4I5lCIq(3eW)yB0beGaEsOcvIgPtejDHofqueLuqzeTl)Mvru4zr0x(w2nLIM(cIU87H1llruWuYiQHPtPPSerDqTacdoeoKuhmI(wkGOK4e)8QSerFzXcgEwi896xquDq0xwSGHNfcFV(4WeRS8fe1ueLeMeKKquCZNscoeoKuhmI(wkGOK4e)8QSerFzXcgEwi896xquDq0xwSGHNfcFV(4WeRS8fef38PKGdHdj1bJOVFkGOK4e)8QSerFrTkh696xquDq0xuRYHEV(4WeRS8fef38PKGdHdj1bJOVFkGOK4e)8QSerFzXcgEwi896xquDq0xwSGHNfcFV(4WeRS8fe1ueLeMeKKquCZNscoeoiCiHkujAKorK0f6uarrusbLr0U8BwfrHNfrFr3oiYk4feD53dRxwIOGPKrudtNstzjI6GAbegCiCiPoye99tbeLeN4NxLLik(UKeruq6qTuIOPievheLKWmev2)nONarNpEnDwef3ciarX9TusWHWHK6Gr03pfqusCIFEvwIOVOBhez9YFV(fevhe9fD7GiRNM)E9likUfZNscoeoKuhmI((PaIsIt8ZRYse9fD7GiRxX71VGO6GOVOBhez90I3RFbrXT47NscoeoKuhmIMiKcikjoXpVklru8DjjIOG0HAPertriQoikjHziQS)BqpbIoF8A6SikUfqaII7BPKGdHdj1bJOjcPaIsIt8ZRYse9fD7GiRx(71VGO6GOVOBhez9083RFbrXT47NscoeoKuhmIMiKcikjoXpVklr0x0TdISEfVx)cIQdI(IUDqK1tlEV(fef3I5tjbhcheoKqfQensNis6cDkGOikPGYiAx(nRIOWZIOV4KGxq0LFpSEzjIcMsgrnmDknLLiQdQfqyWHWHK6Gr0cjfqusCIFEvwIOVOwLd9E9liQoi6lQv5qVxFCyIvw(cIIB(usWHWHK6Gr0ezkGOK4e)8QSerFrTkh696xquDq0xuRYHEV(4WeRS8fef38PKGdHdchsOcvIgPtejDHofqueLuqzeTl)Mvru4zr0xa6li6YVhwVSerbtjJOgMoLMYse1b1cim4q4qsDWiAXuarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5liQPikjmjijHO4MpLeCiCiPoyeTykGOK4e)8QSerF5J17137WD3liQoi6lVd3DVGO4wmLeCiCiPoyeTqsbeLeN4NxLLi6llwWWZcHVx)cIQdI(YIfm8Sq471hhMyLLVGO4MpLeCiCiPoyenrMcikjoXpVklr0xwSGHNfcFV(fevhe9Lfly4zHW3RpomXklFbrnfrjHjbjjef38PKGdHdj1bJOjQuarjXj(5vzjI(IAvo071VGO6GOVOwLd9E9XHjwz5likU5tjbhchsQdgrZx4uarjXj(5vzjI(IAvo071VGO6GOVOwLd9E9XHjwz5likU5tjbhchsQdgrlw4uarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5likU5tjbhchsQdgrlMpfqusCIFEvwIOV4MqI1696xquDq0xCtiXA9E9XHjwz5liQPikjmjijHO4MpLeCiCiPoyeTyHKcikjoXpVklr0xwSGHNfcFV(fevhe9Lfly4zHW3RpomXklFbrnfrjHjbjjef38PKGdHdj1bJOflKuarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5likU5tjbhchsQdgrlMitbeLeN4NxLLi6llwWWZcHVx)cIQdI(YIfm8Sq471hhMyLLVGOMIOKWKGKeIIB(usWHWbHdjuHkrJ0jIKUqNcikIskOmI2LFZQik8Si6lUkB)8li6YVhwVSerbtjJOgMoLMYse1b1cim4q4qsDWiAXuarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5liQPikjmjijHO4MpLeCiCiPoyeTykGOK4e)8QSerF5J17137WD3liQoi6lVd3DVGO4wmLeCiCiPoyeTqsbeLeN4NxLLi6lFSEV(EhU7Ebr1brF5D4U7fef38PKGdHdj1bJOjYuarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5likU5tjbhchsQdgrFlfqusCIFEvwIOVSybdple(E9liQoi6llwWWZcHVxFCyIvw(cIAkIsctcssikU5tjbhchsQdgrF)uarjXj(5vzjI(YIfm8Sq471VGO6GOVSybdple(E9XHjwz5likU5tjbhchsQdgrtesbeLeN4NxLLi6llwWWZcHVx)cIQdI(YIfm8Sq471hhMyLLVGOMIOKWKGKeIIB(usWHWHK6Gr08fofqusCIFEvwIOVOwLd9E9liQoi6lQv5qVxFCyIvw(cIAkIsctcssikU5tjbhchsQdgrlw4uarjXj(5vzjI(YhR3RV3H7UxquDq0xEhU7EbrXnFkj4q4qsDWiAXezkGOK4e)8QSerFXnHeR171VGO6GOV4MqI1696JdtSYYxqutrusysqscrXnFkj4q4qsDWiAX3pfqusCIFEvwIOVSybdple(E9liQoi6llwWWZcHVxFCyIvw(cIAkIsctcssikU5tjbhchsQdgrl((PaIsIt8ZRYse9Lfly4zHW3RFbr1brFzXcgEwi896JdtSYYxquCZNscoeoKuhmIwmrifqusCIFEvwIOVSybdple(E9liQoi6llwWWZcHVxFCyIvw(cIAkIsctcssikU5tjbhcheojILFZQSerFFe1CApbIwBGcoeoc4bFStG0fFRqeW)TdCxzb8VR3fIMy2akIMOJbuEtJOj6XcLxeoVR3fIwOWGGbuenrMaIwSWfZJWbHZ76DHOKiulGWGuaHZ76DHOVcrt04xXHjwzenX2kYsefp0rr0c9AogrFh5Th5HWbHJ50EcW9TSBkfnLmaRSCc)hRiCmN2taUVLDtPOPesUaXr1kl9WvlnlF6aIxNu2bchZP9eG7Bz3ukAkHKlaUYaOU1GveoMt7ja33YUPu0ucjxagG9TYLjewjt2izauBnGhEc1pW(V5HxeoMt7ja33YUPu0ucjxGARxx7lHVLDgq9AxYKZFVLqdtEXcgEwi8bgSk8SqypxkYlilBXcgEwi8fma0bKhBtd86AFFDaXBFF2AkgaHJ50EcW9TSBkfnLqYfiYaTTQ)znfAcFl7mG61UKjN)ElHgMCsQv5qpGJd1pWEX6mYCjTybdple(adwfEwiSNlf5fGW5DHOfk57edOaevHYiQeBnTNarTqIOUzQY5jq0bgrluGp2Pi6aJOkugrjH6QerTqIOVJBxAvenrmaAhofGOIPrufkJOsS10EceDGrulquSaQbuwIOfAs8DJOpq5arvOC6xwgrXaSer)w2nLIMEiAIzNHbyeTqb(yNIOdmIQqzeLeQRseDzjMJbiAHMeF3iQyAeTyHlCjibevH2aeTbiA(Rqqua7MqcoeoMt7ja33YUPu0ucjxGb(yN6hyVcL9pDvMW3YodOETlzY5VcjHgMCsgjZBR89TDPv9Da0oCk44WeRSmxsmaWHJpga4WX(b2Rqzp84WaDaX3BdUs7DoBoC53dR)(y5zKmaQTgWdpH6hy)38WBwws87H1FFS8CPD1r3jANxSAaLaeoVleTqjFNyafGOkugrLyRP9eiQfse1ntvopbIoWiAIzG2wfrjHwtHIOwir0e9gjZi6aJOjAgegrftJOkugrLyRP9ei6aJOwGOybudOSerl0K47grFGYbIQq50VSmIIbyjI(TSBkfn9q4yoTNaCFl7MsrtjKCbImqBR6FwtHMW3YodOETlzY5V3sOHjBKmVTY332Lw13bq7WPGJdtSYYCjXaaho(yaGdh7hyVcL9WJdd0beFVn4kT35S5WLFpS(7JLNrYaO2Aap8eQFG9FZdVzzjXVhw)9XYZL2vhDNODEXQbucq4GWXCApbGqYf4gSq51dGokcN3fIwOhe1GYMerTqIOKAT49W6AtYmIs63rser5GlBgKOlI(WiQCIxuevoiQcTbik8Si6x1sZlarfzNHbyeT1xKiQiJO6mik4ZkltJOwir0hgrDw8IIOlBYUMgrj1AX7HOGp21WTdrfXGHbhchZP9eacjxGUw8EyDTj5oG4bqhnHgMCsQTqy9AG)RAP5fHZ76DHOVBUAPruyZ1been9GTiQCWevefl0UIOPhmefQ9Zi6hMIOjAmyct7acIwO2DEqu58ejGOZIOnmIQqze1ntvopbI2aevNbrRtabr1brLC1sJOWMRdiiA6bBr039GjQhIMicJOXemIoWiQcLbmI6Mq2ApbarTLrutSYiQoiAjRi6tRq7arvOmIMVWikGDtibiAL5hlDciQcLruqxIOWMJbiA6bBr039GjQiQHPtPPTZQ10hcN317crnN2taiKCbb)apyH0VmyQ)CcnmzWGvf7qEb)apyH0VmyQ)CoCfXGHVLbtyAhq82UZZH9LL5MPkNN4wgmHPDaXB7op3YLwhGKZx4Sm1wiSEAxYED8YMtn)7tachZP9eacjxGZQvV50EcFTbAcHvYK1TdIScsOHj7MFoSqpIP32ICUzQY5jod8Xo1pWEfk7F6Q8wU06aKZntvopXTmyct7aI32DEULlToazzj5MFoSqpIP32ICUzQY5jod8Xo1pWEfk7F6Q8wU06aGWXCApbGqYf4SA1BoTNWxBGMqyLmzNeGWXCApbGqYf4SA1BoTNWxBGMqyLmzGMqdt2CA)ZEo4YMbPweHJ50EcaHKlWz1Q3CApHV2anHWkzYUkB)CcnmzZP9p75GlBgKCEeoiCmN2taoNeq2chd01QENvRj0WKDZuLZtCImqBR6FwtHElxADasUqkmchZP9eGZjbesUa4EzX6mYeAyYUzQY5jorgOTv9pRPqVLlToajxifgHJ50EcW5KacjxGiVaEj2bKeAyY4kIbdFpDv6bF92k4W(YYsYn)CyHErdbQ6HnoNigm8zGp2P(b2Rqz)txLh2xormy4tKbABv)ZAk0d7JGC4c3qGQ(LlToaj7MPkNN4e5fWlXoGCsS10EccLyRP9ezz4Q2cH1dkBvf6950ulK3YYssTkh6rSRvE9Da0oCkbeKLjoaqo4gcu1VCP1bi18fcchZP9eGZjbesUaX6mspm2MoHgMmUIyWW3txLEWxVTcoSVSSKCZphwOx0qGQEyJZjIbdFg4JDQFG9ku2)0v5H9Ltedg(ezG2w1)SMc9W(iihUWneOQF5sRdqYUzQY5joX6mspm2M(KyRP9eekXwt7jYYWvTfcRhu2Qk07ZPPwiVLLLKAvo0JyxR867aOD4uciiltCaGCWneOQF5sRdqQ5FFeoMt7jaNtciKCb1gcuf4FNysiLCOiCmN2taoNeqi5c(gTNiHgMSigm8zGp2P(b2Rqz)txLh2xwgCdbQ6xU06aKAX3hHdchZP9eGZvz7NjBGp2P(b2Rqz)txLj0WKtATw65Fo0ZKsWXPSbkilBTw65Fo0ZKsWTCP1bizY5lCwM50(N9CWLndsM8AT0Z)CONjLGZnyHMIlIWXCApb4Cv2(zcjxGOTIS0dGoAcU0Uk7vBHWkGC(eAyYFSELwhNigm8bVCqYPpSVCFSELwhNigm8bVCqYPVLlToaPsgItsOOTIS0dGoQhYAo2)XBpYSmrmy47PRsp4R3wbh2xohuBHWap8AoTNWQjN)sK5wSGHNfcFWRbPKdf4hyVcL9CvYR3cTYlaHJ50EcW5QS9ZesUGsSQ2aOJMqdtgIt(QpwVsRJtedg(ezdOExLTF(wU06aKCHVIVHWXCApb4Cv2(zcjxaXUw9aOJMqdtEXcgEwi89nyoO(b2VgjpRhEniLCOGCIyWWhC1sZlWxAlXd7dHJ50EcW5QS9ZesUa4QLMLEa0rtOHjVybdple((gmhu)a7xJKN1dVgKsouachZP9eGZvz7NjKCbQTEDTVeAyYlwWWZcHpWGvHNfc75srEb5uB96AF3YLwhGuH4K5CZuLZtCWvB5B5sRdqQqCseoMt7jaNRY2pti5cGR2Yj0WKvB96AFh2xUfly4zHWhyWQWZcH9CPiVaeoMt7jaNRY2pti5cKSPq9oOgX1ktOHjdpomaHodO(LHWrQWJddCLwkr4yoTNaCUkB)mHKl4PRsp4R3wbj0WKtATw65Fo0ZKsWXPSbkilBTw65Fo0ZKsWTCP1bizY5lCwM50(N9CWLndsM8AT0Z)CONjLGZnyHMIlIWXCApb4Cv2(zcjxGOTIS0dGoAcU0Uk7vBHWkGC(eAyYWy1QFzhuBHWETl5uH4K5CZuLZtCImqBR6FwtHElxADaYYCZuLZtCImqBR6FwtHElxADasnFrcH4K5uRYHEahhQFG9I1zKiCmN2taoxLTFMqYfiYaTTQ)znfAcnm5KwRLE(Nd9mPeCCkBGcYYwRLE(Nd9mPeClxADasM8BzzMt7F2Zbx2mizYR1sp)ZHEMuco3GfAkUichZP9eGZvz7NjKCbldMW0oG4TDNNeAyYjTwl98ph6zsj44u2afKLTwl98ph6zsj4wU06aKm53YYmN2)SNdUSzqYKxRLE(Nd9mPeCUbl0uCreoMt7jaNRY2pti5caQv(XsoHgMSigm8zGp2P(b2Rqz)txLh2xwM4aa5GBiqv)YLwhGuZ)gchZP9eGZvz7NjKCbpwx7aI32DEq4yoTNaCUkB)mHKlaUAPzPhaDueoMt7jaNRY2pti5ci21QhaDueoMt7jaNRY2pti5cCq7sJxZdGokchZP9eGZvz7NjKCbI1zKaOSeHJ50EcW5QS9ZesUaZxITsE9dS3TZdaHJ50EcW5QS9ZesUarBxdcNqdt(J1R064eXGHp4Ldso9TCP1bizoLSdtzV2LmchZP9eGZvz7NjKCbe7A17MYslKj0WKHhhgiz3aucnN2tCLyvTbqh9Cdqr4yoTNaCUkB)mHKlq0G4hyVUTJiiHgMSigm8jYaTTQ)znf6jNNiltCaGCWneOQF5sRdqQVHWXCApb4Cv2(zcjxGSx2lYgqr4yoTNaCUkB)mHKlq0wrw6bqhnbxAxL9QTqyfqoFcnmz1wiSEAxYED8YMtnrLL5GAleg4HxZP9ewn58xXCUjKyTEI1zKvw1oGGWXCApb4Cv2(zcjxGBexZdGoAcnmz4XHboTlzVo(slLPcXjtXfr4yoTNaCUkB)mHKlqT1RR9LqdtEXcgEwi8bgSk8SqypxkYlilBXcgEwi8fma0bKhBtd86AFFDaXBFF2AkgaHJ50EcW5QS9ZesUa4LzsUdiEDTVeAyYlwWWZcHVGbGoG8yBAGxx77RdiE77ZwtXaiCmN2taoxLTFMqYfyRZc2RZUCOj0WKXfECyacHhhg4wgchewifMGuHhhg4kTuIWbHJ50EcWbuYg4JDQFG9ku2)0vzcnm5KwRLE(Nd9mPeCCkBGcYYsATw65Fo0ZKsWH9Ld31APN)5qptkbNeBnTNGW1APN)5qptkbxhPwSWzz4Uwl98ph6zsj4CdwOKZNZn)CyHEetVTfeqqw2AT0Z)CONjLGd7l3AT0Z)CONjLGB5sRdqY5tuiCmN2taoGsi5ceTvKLEa0rtOHj)X6vADCIyWWh8YbjN(W(Y9X6vADCIyWWh8YbjN(wU06aKkziojHI2kYspa6OEiR5y)hV9iZYeXGHVNUk9GVEBfCyF5CqTfcd8WR50EcRMC(lrMBXcgEwi8bVgKsouGFG9ku2ZvjVEl0kVaeoMt7jahqjKCbQTEDTVeAyYlwWWZcHpWGvHNfc75srEb5uB96AF3YLwhGuH4K5CZuLZtCWvB5B5sRdqQqCseoMt7jahqjKCbWvB5eQDWENKCX3sOHjR2611(oSVClwWWZcHpWGvHNfc75srEbiCmN2taoGsi5ceRZibqzjchZP9eGdOesUGNUk9GVEBfKqdtoP1APN)5qptkbhNYgOGSSKwRLE(Nd9mPeCyF5wRLE(Nd9mPeCsS10EccxRLE(Nd9mPeCDKAXcNLTwl98ph6zsj4W(YTwl98ph6zsj4wU06aKC(efchZP9eGdOesUa4QLMLEa0rr4yoTNaCaLqYfqSRvpa6OiCmN2taoGsi5cESU2beVT78Kqdt2ntvopXTmyct7aI32DEULlToaPcXjZHBsQv5qpoLF1b0)ShaD0Smrmy4tSoJSIb0d7JGSSKCZphwOhX0BBrwMBMQCEIBzWeM2beVT78ClxADaYYuBHW6PDj71XlBo13q4yoTNaCaLqYfiARil9aOJMqdt2ntvopXjYaTTQ)znf6TCP1bi18ftXoO2cHbE41CApHvjeItMtTkh6bCCO(b2lwNrMLbJvR(LDqTfc71UKtfItMZntvopXjYaTTQ)znf6TCP1biltTfcRN2LSxhVS5utuiCmN2taoGsi5cKSPq9oOgX1ktOHjdpomaHodO(LHWrQWJddCLwkr4yoTNaCaLqYfauR8JLCcnmzrmy4ZaFSt9dSxHY(NUkpSVSm1wiSEAxYED8YMtn)BiCmN2taoGsi5cmFj2k51pWE3opaeoMt7jahqjKCbldMW0oG4TDNNeAyY4kIbdFImqBR6FwtHEyFzzQTqy90UK964LnNA(ctqoCtATw65Fo0ZKsWXPSbkillP1APN)5qptkbh2xoCxRLE(Nd9mPeCsS10EccxRLE(Nd9mPeCDKAXcNLTwl98ph6zsj4CdwOKZtqw2AT0Z)CONjLGd7l3AT0Z)CONjLGB5sRdqY5tueGWXCApb4akHKlqKbABv)ZAk0eAyY46MPkNN4E6Q0d(6TvWTCP1bi58VLL5MFoSqpIP32IC46MPkNN4wgmHPDaXB7op3YLwhGuFllZntvopXTmyct7aI32DEULlToajxSWeKLP2cH1t7s2RJx2CQ5Flld3KCZphwOx0qGQEyJZLKB(5Wc9iMEBliGGC4M0AT0Z)CONjLGJtzduqwwsR1sp)ZHEMucoSVC4Uwl98ph6zsj4KyRP9eeUwl98ph6zsj46i1IfolBTw65Fo0ZKsW5gSqjNNGSS1APN)5qptkbh2xU1APN)5qptkb3YLwhGKZNOiaHJ50EcWbucjxGdAxA8AEa0rr4yoTNaCaLqYfqSRvVBklTqIWXCApb4akHKlq0G4hyVUTJiiHgMSigm8jYaTTQ)znf6jNNiltCaGCWneOQF5sRdqQVHWXCApb4akHKlq2l7fzdOiCmN2taoGsi5cCJ4AEa0rtOHjJl84WaVYnaLq4XHbULHWrkgx3mv58ehXUw9UPS0c5TCP1b4v5jizZP9ehXUw9UPS0c55gGML5MPkNN4i21Q3nLLwiVLlToajNNqiojbzz4kIbdFImqBR6FwtHEyFzzIyWWxWaqhqESnnWRR991beV99zRPyGd7JGCjTybdple(Ep7RAEEzjw4FS1pRK3SmXbaYb3qGQ(LlToaPwiiCmN2taoGsi5ceTvKLEa0rtOHjlIbdFpDv6bF92k4W(YYCqTfcd8WR50EcRMC(Ryo3esSwpX6mYkRAhqq4yoTNaCaLqYfyRZc2)HvbCcnmzrmy4tKbABv)ZAk0toprwM4aa5GBiqv)YLwhGuFdHJ50EcWbucjxGARxx7lHgM8Ifm8Sq4dmyv4zHWEUuKxqw2Ifm8Sq4lyaOdip2Mg411((6aI3((S1umachZP9eGdOesUa4LzsUdiEDTVeAyYlwWWZcHVGbGoG8yBAGxx77RdiE77ZwtXaiCmN2taoGsi5cS1zb71zxo0eAyY4cpomaHWJddCldHdcZ)gbPcpomWvAPeHdchZP9eGt3oiYkG8VTTjw5ecRKjdshop2xc)wfJjlIbdFldMW0oG4TDNNd7lltedg(mWh7u)a7vOS)PRYd7dHJ50EcWPBhezfqi5c(TTnXkNqyLmzGUtaXdshop2xc)wfJj7MFoSqpIP32ICIyWW3YGjmTdiEB355W(YjIbdFg4JDQFG9ku2)0v5H9LLLKB(5Wc9iMEBlYjIbdFg4JDQFG9ku2)0v5H9HWXCApb40TdISciKCb)22MyLtiSsMmq3jG4bPdNF5sRdqcZhzaRnCcUjKT2tq2n)CyHEetVTfj8BvmMSBMQCEIBzWeM2beVT78ClxADasLeOBMQCEIZaFSt9dSxHY(NUkVLlToaj8Bvm2Zvat2ntvopXzGp2P(b2Rqz)txL3YLwhGeAyYIyWWNb(yN6hyVcL9pDvEY5jq4yoTNaC62brwbesUGFBBtSYjewjtgO7eq8G0HZVCP1biH5JmG1gob3eYw7ji7MFoSqpIP32Ie(Tkgt2ntvopXTmyct7aI32DEULlToaj8Bvm2Zvat2ntvopXzGp2P(b2Rqz)txL3YLwhGeAyYIyWWNb(yN6hyVcL9pDvEyFiCmN2taoD7GiRacjxWVTTjw5ecRKjdsho)YLwhGeMpYawB4eCtiBTNGSB(5Wc9iMEBls43Qymz3mv58e3YGjmTdiEB355wU06aKmjq3mv58eNb(yN6hyVcL9pDvElxADas43QySNRaMSBMQCEIZaFSt9dSxHY(NUkVLlToaiCmN2taoD7GiRacjxagG9TYLGea1rbK1TdISMpHgMmU62brwV8hud4XaSxedgolZn)CyHEetVTf50TdISE5pOgW7MPkNNGGC4(BBBIv(a6obepiD48yF5Wnj38ZHf6rm92wKljD7GiRxXdQb8ya2lIbdNL5MFoSqpIP32ICjPBhez9kEqnG3ntvoprwMUDqK1R45MPkNN4wU06aKLPBhez9YFqnGhdWErmy4C4MKUDqK1R4b1aEma7fXGHZY0TdISE5p3mv58eNeBnTNizY62brwVINBMQCEItITM2tqqwMUDqK1l)b1aE3mv58e5ss3oiY6v8GAapgG9IyWW50TdISE5p3mv58eNeBnTNizY62brwVINBMQCEItITM2tqqwws)22MyLpGUtaXdshop2xoCts3oiY6v8GAapgG9IyWW5Wv3oiY6L)CZuLZtCsS10EIx9wQ)22MyLpq6W5xU06aKL9BBBIv(aPdNF5sRdqY62brwV8NBMQCEItITM2tKIksqwMUDqK1R4b1aEma7fXGHZHRUDqK1l)b1aEma7fXGHZPBhez9YFUzQY5joj2AAprYK1TdISEfp3mv58eNeBnTNihU62brwV8NBMQCEItITM2t8Q3s9322eR8bsho)YLwhGSSFBBtSYhiD48lxADasw3oiY6L)CZuLZtCsS10EIuurcYYWnjD7GiRx(dQb8ya2lIbdNLPBhez9kEUzQY5joj2AAprYK1TdISE5p3mv58eNeBnTNGGC4QBhez9kEUzQY5jULnz6C62brwVINBMQCEItITM2t8Q3s(322eR8bsho)YLwhGC)22MyLpq6W5xU06aKQUDqK1R45MPkNN4KyRP9ePOIzzjPBhez9kEUzQY5jULnz6C4QBhez9kEUzQY5jULlToaV6Tu)TTnXkFaDNaIhKoC(LlToa5(TTnXkFaDNaIhKoC(LlToajxSW5Wv3oiY6L)CZuLZtCsS10EIx9wQ)22MyLpq6W5xU06aKLPBhez9kEUzQY5jULlToaV6Tu)TTnXkFG0HZVCP1biNUDqK1R45MPkNN4KyRP9eVkFHj8322eR8bsho)YLwhGu)TTnXkFaDNaIhKoC(LlToazz)22MyLpq6W5xU06aKSUDqK1l)5MPkNN4KyRP9ePOIzz)22MyLpq6W5X(iilt3oiY6v8CZuLZtClxADaE1Bj)BBBIv(a6obepiD48lxADaYHRUDqK1l)5MPkNN4KyRP9eV6Tu)TTnXkFaDNaIhKoC(LlToazzjPBhez9YFqnGhdWErmy4C4(BBBIv(aPdNF5sRdqY62brwV8NBMQCEItITM2tKIkML9BBBIv(aPdNh7JaciGaciiltTfcRN2LSxhVS5u)TTnXkFG0HZVCP1bGGSSK0TdISE5pOgWJbyVigmCUKCZphwOhX0BBroC1TdISEfpOgWJbyVigmCoCXnPFBBtSYhiD48yFzz62brwVINBMQCEIB5sRdqYVrqoC)TTnXkFG0HZVCP1bi5Ifolt3oiY6v8CZuLZtClxADaE1Bj)BBBIv(aPdNF5sRdabeKLLKUDqK1R4b1aEma7fXGHZHBs62brwVIhud4DZuLZtKLPBhez9kEUzQY5jULlToazz62brwVINBMQCEItITM2tKmzD7GiRx(ZntvopXjXwt7jiGaeoMt7jaNUDqKvaHKladW(w5sqcG6OaY62brwlMqdtgxD7GiRxXdQb8ya2lIbdNL5MFoSqpIP32IC62brwVIhud4DZuLZtqqoC)TTnXkFaDNaIhKoCESVC4MKB(5Wc9iMEBlYLKUDqK1l)b1aEma7fXGHZYCZphwOhX0BBrUK0TdISE5pOgW7MPkNNilt3oiY6L)CZuLZtClxADaYY0TdISEfpOgWJbyVigmCoCts3oiY6L)GAapgG9IyWWzz62brwVINBMQCEItITM2tKmzD7GiRx(ZntvopXjXwt7jiilt3oiY6v8GAaVBMQCEICjPBhez9YFqnGhdWErmy4C62brwVINBMQCEItITM2tKmzD7GiRx(ZntvopXjXwt7jiillPFBBtSYhq3jG4bPdNh7lhUjPBhez9YFqnGhdWErmy4C4QBhez9kEUzQY5joj2AApXREl1FBBtSYhiD48lxADaYY(TTnXkFG0HZVCP1bizD7GiRxXZntvopXjXwt7jsrfjilt3oiY6L)GAapgG9IyWW5Wv3oiY6v8GAapgG9IyWW50TdISEfp3mv58eNeBnTNizY62brwV8NBMQCEItITM2tKdxD7GiRxXZntvopXjXwt7jE1BP(BBBIv(aPdNF5sRdqw2VTTjw5dKoC(LlToajRBhez9kEUzQY5joj2AAprkQibzz4MKUDqK1R4b1aEma7fXGHZY0TdISE5p3mv58eNeBnTNizY62brwVINBMQCEItITM2tqqoC1TdISE5p3mv58e3YMmDoD7GiRx(ZntvopXjXwt7jE1Bj)BBBIv(aPdNF5sRdqUFBBtSYhiD48lxADasv3oiY6L)CZuLZtCsS10EIuuXSSK0TdISE5p3mv58e3YMmDoC1TdISE5p3mv58e3YLwhGx9wQ)22MyLpGUtaXdsho)YLwhGC)22MyLpGUtaXdsho)YLwhGKlw4C4QBhez9kEUzQY5joj2AApXREl1FBBtSYhiD48lxADaYY0TdISE5p3mv58e3YLwhGx9wQ)22MyLpq6W5xU06aKt3oiY6L)CZuLZtCsS10EIxLVWe(BBBIv(aPdNF5sRdqQ)22MyLpGUtaXdsho)YLwhGSSFBBtSYhiD48lxADasw3oiY6v8CZuLZtCsS10EIuuXSSFBBtSYhiD48yFeKLPBhez9YFUzQY5jULlToaV6TK)TTnXkFaDNaIhKoC(LlToa5Wv3oiY6v8CZuLZtCsS10EIx9wQ)22MyLpGUtaXdsho)YLwhGSSK0TdISEfpOgWJbyVigmCoC)TTnXkFG0HZVCP1bizD7GiRxXZntvopXjXwt7jsrfZY(TTnXkFG0HZJ9rabeqabeKLP2cH1t7s2RJx2CQ)22MyLpq6W5xU06aqqwws62brwVIhud4XaSxedgoxsU5Ndl0Jy6TTihU62brwV8hud4XaSxedgohU4M0VTTjw5dKoCESVSmD7GiRx(ZntvopXTCP1bi53iihU)22MyLpq6W5xU06aKCXcNLPBhez9YFUzQY5jULlToaV6TK)TTnXkFG0HZVCP1bGacYYss3oiY6L)GAapgG9IyWW5WnjD7GiRx(dQb8UzQY5jYY0TdISE5p3mv58e3YLwhGSmD7GiRx(ZntvopXjXwt7jsMSUDqK1R45MPkNN4KyRP9eeqGGkOcca]] )

end
