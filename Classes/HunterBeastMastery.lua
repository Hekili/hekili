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


    spec:RegisterPack( "Beast Mastery", 20210502, [[d0uPzbqisqpsvrYMiH(KQsJIsYPOKAvOsQ8kuPMLG0Tua2fk)sbAycGJjqldc9mbOPPQiUMQcBdIs9nikX4ibkNtqrwNQI6DKavnpb09uq7dIQdIkjluq8qfqtevsvxKsK8rujLrkOO6KckSsiYmfu6Mckk7Ke1pPePgkjqLLcrj9usAQucFLeWyrL4SQksTxk(RidwQdlzXOQhtQjl0Lr2SQ8zvvJMsDAGvtcKxdbZwu3wr2Tk)wPHRqhNselh0ZHA6exhsBxq13vuJNsuNNez9qumFuX(PAtqJfg1yjKrzedaIbdWhbarwWpcyaq8dJQO0izuhlnc1pzuVAImQHqfw8omRWcbvYOowkL3kASWOIxuOMmQ2ImI)8Gd(deBuEMENgedMqZLa2tdRNmigmPh0OYJcYsyCgEJASeYOmIbaXGb4JaGil4hbmaig0OwOI9cnQQGPbAuTbXiDgEJAKWAJAiuHfVdZkSqqL8omh9ec6ifMvk5nIH6nIbaXGg1malyJfg1i9k0SySWOCqJfg1slG9mQ6f9ecMW2RyuPR4Zu0eIrmkJOXcJkDfFMIMqmQLwa7zufyDwckidqgW9NW2RyuJewdbJcypJkxB9USPk6DDrVTawNLGcYaKH8wzfCd0B6OjaHd17zY74EFfVJR3Ina79BHEpMlLii2BEsxOyYBG8n6np5TSR34XAAsjVRl69m5TUUVI3qQIGSsEBbSolXB8iPbpG2BE03dZmQAiqiiOmQk0BPG)KWa40yUuIGgXOCanwyuPR4Zu0eIrT0cypJQabhcKe0OgjSgcgfWEg1W45TytElqWHajEBxyVlV3BaOyYBE03luVXkDAVbI3ZaX2BUcpsAX795TytERaGCK5Dy88wMxVli5TENgjbC)E)wO3L3CfEK0I37ZBXM8wba5O3yLoDOEJIjVfBYBSa37NGEV3aqXK307rAH5Dy88UoV3BaOyYBE03ZBa2BivrL8Mhv8UUvSjO3ybU3pb9EVbGIjV5rFpVNb5S3vgVEZtEdPkQK38k5TytElGjYBUcpsAX795TytERaGC0B9oryV5lncEVVN36DZXD(c1Bum5nq8g88wSjVX2fKIElqWHajER3nh35Z759(kEdoHGpcsEpdeBVfBYB0r9obUFV5k8iPfV3N3In5TcaYrVXkDAM3HXZ768EVbGIjV5rFpV1lAo6np5nkMIExx0BSaYzV17e5nFPrW73c9U8(HkOqYBUcpsAX795TytERaGCmuVrXK3aH5Dy88U8(2Ba8OVN37naum5na7nKQOsH6nkM8giEdEEdeVN37R4n4ec(ii59mqS9ECf6eqL9EVbGIjV5rFpS3cujW97TSEZv4rslEVpVfBYBfaKJEJv60EVqVbpVfBY7vSjO3ceCiqI3a89v8UoV3BaOykuVbyVlVV9gap6759EdaftEpdeBVlVZ79tqV17MJ78fQ3l0Ba((kEdPkQeZ7W45TytE)a)2I3aS3)l4(9wwVPl6np9wi5Tslk07JSS4nxHhjT49(8wSjVvaqogQ3kiuS4nwkO4nkgC)ElqWHajyVL17PcbYBmkK8wSjL8(NeVrXuKzu1qGqqqzufi4qGeMeKzx4ekMs8OVN3k6TvEZJ(EScpsAjTVKytPzqoYqh9wrVTYBf6TabhcKWeez2foHIPep675nhoElqWHajmbrME3CCNpgKMkWH9MdhVfi4qGeMeKP3nh35JfrHLa2ZBKp0BbcoeiHjiY07MJ78XIOWsa75T1EZHJ38OVhRWJKws7lj2uAgKJS4oFERO3w5TabhcKWeez2foHIPep675TIElqWHajmbrME3CCNpwefwcypVr(qVfi4qGeMeKP3nh35JfrHLa2ZBf9wGGdbsycIm9U54oFminvGd79a8(dVd0B9U54oFScpsAjTVKytPzqoYG0uboS3k6TE3CCNpwHhjTK2xsSP0mihzqAQah2BK7nIbWBoC8wGGdbsysqME3CCNpwefwcypVhG3F4DGER3nh35Jv4rslP9LeBkndYrgKMkWH92AV5WXBPG)KWeWeLKnfbK3b6TE3CCNpwHhjTK2xsSP0mihzqAQah2BR9MdhVvO3ceCiqctcYSlCcftjE03ZBf92kVfi4qGeMGiZUWjumL4rFpVv0BR8Mh99yfEK0sAFjXMsZGCKf35ZBoC8wGGdbsycIm9U54oFminvGd7nY9(dVT2Bf92kV17MJ78Xk8iPL0(sInLMb5idstf4WEJCVrmaEZHJ3ceCiqctqKP3nh35JbPPcCyVhG3F4nY9wVBoUZhRWJKws7lj2uAgKJminvGd7T1EZHJ3k0BbcoeiHjiYSlCcftjE03ZBf92kVvO3ceCiqctqKzx4KE3CCNpV5WXBbcoeiHjiY07MJ78XIOWsa75nYh6TabhcKWKGm9U54oFSikSeWEEZHJ3ceCiqctqKP3nh35JbPPcCyVT2BRnIr5pXyHrLUIptrtigvneieeugvbcoeiHjiYSlCcftjE03ZBf92kV5rFpwHhjTK2xsSP0mihzOJERO3w5Tc9wGGdbsysqMDHtOykXJ(EEZHJ3ceCiqctcY07MJ78XG0uboS3C44TabhcKWeez6DZXD(yruyjG98g5d9wGGdbsysqME3CCNpwefwcypVT2BoC8Mh99yfEK0sAFjXMsZGCKf35ZBf92kVfi4qGeMeKzx4ekMs8OVN3k6TabhcKWKGm9U54oFSikSeWEEJ8HElqWHajmbrME3CCNpwefwcypVv0BbcoeiHjbz6DZXD(yqAQah27b49hEhO36DZXD(yfEK0sAFjXMsZGCKbPPcCyVv0B9U54oFScpsAjTVKytPzqoYG0uboS3i3BedG3C44TabhcKWeez6DZXD(yruyjG98EaE)H3b6TE3CCNpwHhjTK2xsSP0mihzqAQah2BR9MdhVLc(tctatus2ueqEhO36DZXD(yfEK0sAFjXMsZGCKbPPcCyVT2BoC8wHElqWHajmbrMDHtOykXJ(EERO3w5TabhcKWKGm7cNqXuIh998wrVTYBE03Jv4rslP9LeBkndYrwCNpV5WXBbcoeiHjbz6DZXD(yqAQah2BK79hEBT3k6TvER3nh35Jv4rslP9LeBkndYrgKMkWH9g5EJya8MdhVfi4qGeMeKP3nh35JbPPcCyVhG3F4nY9wVBoUZhRWJKws7lj2uAgKJminvGd7T1EZHJ3k0BbcoeiHjbz2foHIPep675TIEBL3k0BbcoeiHjbz2foP3nh35ZBoC8wGGdbsysqME3CCNpwefwcypVr(qVfi4qGeMGitVBoUZhlIclbSN3C44TabhcKWKGm9U54oFminvGd7T1EBTrT0cypJQabhcKGOrmk)HXcJkDfFMIMqmQrcRHGrbSNrT0cypmlsVcnlCpCqumLacnHnQLwa7zufyDwckidqgW9NW2RyeJYiBJfgv6k(mfnHyu1qGqqqzuhHu4PFDKfKv4rslP9LeBkndYrV5WX7h43wsqAQah27a9gXayulTa2ZOIIPeqOjSrmkJSySWOsxXNPOjeJAPfWEgvDLZPslG9szawmQzawsxnrgvDeBeJYkyglmQ0v8zkAcXOQHaHGGYOwAbeoLOJMae27a9grJAPfWEgvDLZPslG9szawmQzawsxnrgvSyeJYHjJfgv6k(mfnHyu1qGqqqzulTacNs0rtac7nY9oOrT0cypJQUY5uPfWEPmalg1malPRMiJQotv4KrmIrDes6DIVeJfgLdASWOwAbSNrfJonTxAKeJkDfFMIMqmIrzenwyulTa2ZOYVIKPy6LlLO4m4(tYAzWzuPR4Zu0eIrmkhqJfgv6k(mfnHyuVAImQfYGTlyHtV9K0(sJ7mbnQLwa7zulKbBxWcNE7jP9Lg3zcAeJYFIXcJkDfFMIMqmQJqsxyjjGjYOgK9HrT0cypJQuWKaRrJQgcecckJke9O3c)jgErZVf(tjAINGygDfFMIEZHJ3q0JEl8NyhHXG7FUGkHtcSghb3FQghlyjOygDfFMIgXO8hglmQ0v8zkAcXOocjDHLKaMiJAq2hg1slG9mQ8ewavondlX2OQHaHGGYOQqVLktNWWA6K0(s85DJm6k(mf9wrVvO3q0JEl8Ny4fn)w4pLOjEcIz0v8zkAeJYiBJfgv6k(mfnHyuhHKUWssatKrnilGg1iH1qWOa2ZOYvrfekwWEl2K3ruyjG98UUO36DZXD(8EFEZv4rslEVpVfBYBfaKJExx0BfCqWuL9omoSaoTG9MxjVfBY7ikSeWEEVpVRZB0ZUWcf9MRnqUEVNTPZBXMu6lK8gftrVhHKEN4lH5DiKUqXK3CfEK0I37ZBXM8wba5O3qkIQjS3CTbY17nVsEJyacWeouVfBa2Ba27GSa6nM07fXmJAPfWEg1cpsAjTVKytPzqoAu1qGqqqzuvO3fYqqGqSriyQYjWHfWPfmJUIptrVv0Bf6nHX0PjgHX0PP0(sInLERgfdU)eacWSPsbTqVv0BR8MSeuW4ifzfYGTlyHtV9K0(sJ7mb9MdhVvO3KLGcghPitRKoVcCpGoXNlS4T1gXOmYIXcJkDfFMIMqmQJqsxyjjGjYOgK9HrnsynemkG9mQCvubHIfS3In5DefwcypVRl6TE3CCNpV3N3HqybuzVvayj2Exx07W8cziV3N3iR1p5nVsEl2K3ruyjG98EFExN3ONDHfk6nxBGC9EpBtN3InP0xi5nkMIEpcj9oXxcZOwAbSNrLNWcOYPzyj2gvneieeug1cziiqi2iemv5e4Wc40cMrxXNPO3k6Tc9MWy60eJWy60uAFjXMsVvJIb3Fcaby2uPGwO3k6TvEtwckyCKISczW2fSWP3EsAFPXDMGEZHJ3k0BYsqbJJuKPvsNxbUhqN4Zfw82AJyeJQoInwyuoOXcJkDfFMIMqmQAiqiiOmQ6DZXD(y8ewavondlXMbPPcCyVrU3bmag1slG9mQ1PjSaRCsx5SrmkJOXcJkDfFMIMqmQAiqiiOmQ6DZXD(y8ewavondlXMbPPcCyVrU3bmag1slG9mQpaK4Z7gnIr5aASWOsxXNPOjeJQgcecckJQvEZJ(ESzqoMWJaiqWm0rV5WXBf6TEdNU6e2b(TL0RiVv0BE03Jv4rslP9LeBkndYrg6O3k6np67X4jSaQCAgwIndD0BR9wrVTY7h43wsqAQah2BK7TE3CCNpgpbXeebW9ZIOWsa75n3EhrHLa2ZBoC82kVLc(tcZMQSyZg1I3b6Da)WBoC8wHElvMoHHaiNjycCybCAHrxXNPO3w7T1EZHJ3pWVTKG0uboS3b6DWaAulTa2ZOYtqmbraC)gXO8NySWOsxXNPOjeJQgcecckJQvEZJ(ESzqoMWJaiqWm0rV5WXBf6TEdNU6e2b(TL0RiVv0BE03Jv4rslP9LeBkndYrg6O3k6np67X4jSaQCAgwIndD0BR9wrVTY7h43wsqAQah2BK7TE3CCNpgFE3y6HcvIfrHLa2ZBU9oIclbSN3C44TvElf8NeMnvzXMnQfVd07a(H3C44Tc9wQmDcdbqotWe4Wc40cJUIptrVT2BR9MdhVFGFBjbPPcCyVd07GiBJAPfWEgv(8UX0dfQKrmk)HXcJAPfWEg1m43wWjfeA8FIoXOsxXNPOjeJyugzBSWOsxXNPOjeJQgcecckJkp67Xk8iPL0(sInLMb5idD0BoC8(b(TLeKMkWH9oqVrezBulTa2ZOoUcypJyeJkwmwyuoOXcJAPfWEg1cpsAjTVKytPzqoAuPR4Zu0eIrmkJOXcJkDfFMIMqmQAiqiiOmQ8OVh7bPdzuIHo6TIEZJ(EShKoKrjgKMkWH9oWHE)RJg1slG9mQ8fKNIjS9kgXOCanwyuPR4Zu0eIrvdbcbbLrfIE0BH)edVO53c)PenXtqmJUIptrVv0BPGjbwJminvGd7DGE)RJERO36DZXD(yVCbjgKMkWH9oqV)1rJAPfWEgvPGjbwJgXO8NySWOsxXNPOjeJAPfWEg1xUGKrvdbcbbLrvkysG1idD0Bf9gIE0BH)edVO53c)PenXtqmJUIptrJAgCushnQi(Hrmk)HXcJAPfWEgv(8UrSnfnQ0v8zkAcXigLr2glmQLwa7zuNb5ycpcGabBuPR4Zu0eIrmkJSySWOwAbSNr9LlLOycBVIrLUIptrtigXOScMXcJAPfWEgvea5CcBVIrLUIptrtigXOCyYyHrLUIptrtigvneieeugv9U54oFmEclGkNMHLyZG0uboS3b6Dqe9MRZBTDb)jC6blTa2RYEZT3)6O3k6Tuz6egwtNK2xIpVBKrxXNPO3C449dnNtqsBxWFkjGjY7a9(xh9wrV17MJ78X4jSaQCAgwIndstf4WEZHJ3sb)jHjGjkjBkciVd07WKrT0cypJkFb5PycBVIrmkhmaglmQ0v8zkAcXOQHaHGGYO(wnk2BU9wxyjbPF68oqVFRgfZMklBulTa2ZOgPsStA7cbynzeJYbdASWOsxXNPOjeJQgcecckJkp67Xk8iPL0(sInLMb5idD0BoC8(b(TLeKMkWH9oqVd(HrT0cypJkwQPrksgXOCqenwyulTa2ZOwPjuyKGP9L0WDgBuPR4Zu0eIrmkhmGglmQ0v8zkAcXOQHaHGGYOYJ(EmEclGkNMHLyZqh9MdhVFGFBjbPPcCyVd07GbWOwAbSNrfs49kbC)Pcc3zJyuo4NySWOsxXNPOjeJQgcecckJQE3CCNp2miht4raeiygKMkWH9g5Eh8dV5WXBf6TEdNU6e2b(TL0RiV5WX7h43wsqAQah27a9o4hg1slG9mQ8ewavondlX2igLd(HXcJAPfWEgvTnyQiyLW2RyuPR4Zu0eIrmkhezBSWOsxXNPOjeJQgcecckJkp67X4jSaQCAgwIndD0BoC8(b(TLeKMkWH9oqVdgaJAPfWEgviH3ReW9NkiCNnIr5GilglmQ0v8zkAcXOQHaHGGYOQ3nh35JndYXeEeabcMbPPcCyVrU3b)WBoC8wVHtxDcdbLGG68wrVTYB9U54oFmiH3ReW9NkiCNzqAQah27a9(dV5WXB9U54oFmiH3ReW9NkiCNzqAQah2BK7nIbWBR9MdhVLc(tctatus2ueqEhO3b)WBoC82kVvO36nC6Qtyh43wsVI8wrVvO36nC6QtyiOeeuN3wBulTa2ZOYtybu50mSeBJyuoOcMXcJAPfWEgvTnyQiyLW2RyuPR4Zu0eIrmkhmmzSWOwAbSNrfbqoN070uDrJkDfFMIMqmIrzedGXcJkDfFMIMqmQAiqiiOmQ8OVhJNWcOYPzyj2S4oFEZHJ3pWVTKG0uboS3b69hg1slG9mQ81FAFjbc0iGnIrzedASWOwAbSNrncGuINkSyuPR4Zu0eIrmkJiIglmQ0v8zkAcXOQHaHGGYOAL3VvJI9EaERxS4n3E)wnkMbPF68MRZBR8wVBoUZhdbqoN070uDrgKMkWH9EaEh0BR9g5ExAbShdbqoN070uDrMEXI3C44TE3CCNpgcGCoP3PP6IminvGd7nY9oO3C79Vo6T1EZHJ3w5np67X4jSaQCAgwIndD0BoC8Mh99yhHXG7FUGkHtcSghb3FQghlyjOyg6O3w7TIERqVHOh9w4pXSKAmxjcsr0lnxW0cJeKrxXNPO3C449d8BljinvGd7DGEhqJAPfWEgv9YdRe2EfJyugXaASWOsxXNPOjeJQgcecckJkp67XMb5ycpcGabZqh9MdhV12f8NWPhS0cyVk7nY9oidrVv0B9EruGW4Z7gZKiG7NrxXNPOrT0cypJkFb5PycBVIrmkJ4NySWOsxXNPOjeJQgcecckJkp67X4jSaQCAgwInlUZN3C449d8BljinvGd7DGE)HrT0cypJAb11rPr0mMmIrze)WyHrLUIptrtigvneieeugvi6rVf(tm8IMFl8Ns0epbXm6k(mf9MdhVHOh9w4pXocJb3)CbvcNeynocU)unowWsqXm6k(mfnQLwa7zuLcMeynAeJYiISnwyuPR4Zu0eIrvdbcbbLrfIE0BH)e7imgC)ZfujCsG14i4(t14yblbfZOR4Zu0OwAbSNr9bjcza3FsG1OrmkJiYIXcJkDfFMIMqmQAiqiiOmQw59B1OyV5273QrXmi9tN3C7DWp82AVd073QrXSPYYg1slG9mQfuxhLKfcPtmIrmQ6mvHtglmkh0yHrT0cypJAHhjTK2xsSP0mihnQ0v8zkAcXigLr0yHrLUIptrtig1slG9mQ8fKNIjS9kgvneieeugvE03J9G0HmkXqh9wrV5rFp2dshYOedstf4WEh4qV)1rJQwjDMssb)jbBuoOrmkhqJfgv6k(mfnHyu1qGqqqzu)1rVhG38OVhJNkSK0zQcNyqAQah2BK7Dayi(HrT0cypJ6eAway7vmIr5pXyHrLUIptrtigvneieeugvi6rVf(tm8IMFl8Ns0epbXm6k(mf9wrVLcMeynYG0uboS3b69Vo6TIER3nh35J9YfKyqAQah27a9(xhnQLwa7zuLcMeynAeJYFySWOsxXNPOjeJAPfWEg1xUGKrvdbcbbLrvkysG1idD0Bf9gIE0BH)edVO53c)PenXtqmJUIptrJAgCushnQi(HrmkJSnwyuPR4Zu0eIrvdbcbbLr9TAuS3C7TUWscs)05DGE)wnkMnvw2OwAbSNrnsLyN02fcWAYigLrwmwyulTa2ZOodYXeEeabc2OsxXNPOjeJyuwbZyHrLUIptrtig1slG9mQ8fKNIjS9kgvneieeug1hAoNGK2UG)usatK3b69Vo6TIER3nh35JXtybu50mSeBgKMkWH9MdhV17MJ78X4jSaQCAgwIndstf4WEhO3br0BU9(xh9wrVLktNWWA6K0(s85DJm6k(mfnQAL0zkjf8NeSr5GgXOCyYyHrT0cypJkpHfqLtZWsSnQ0v8zkAcXigLdgaJfg1slG9mQqcVxjG7pvq4oBuPR4Zu0eIrmkhmOXcJkDfFMIMqmQAiqiiOmQ8OVhRWJKws7lj2uAgKJm0rV5WX7h43wsqAQah27a9o4hg1slG9mQyPMgPizeJYbr0yHrT0cypJ6lxkrXe2EfJkDfFMIMqmIr5Gb0yHrT0cypJkcGCoHTxXOsxXNPOjeJyuo4NySWOwAbSNrvBdMkcwjS9kgv6k(mfnHyeJYb)WyHrT0cypJkFE3i2MIgv6k(mfnHyeJYbr2glmQLwa7zuR0ekmsW0(sA4oJnQ0v8zkAcXigLdISySWOsxXNPOjeJQgcecckJkp67XEq6qgLyqAQah2BK7nzzsJkusatKrT0cypJkFbH1pzeJYbvWmwyuPR4Zu0eIrvdbcbbLr9TAuS3i3B9IfV527slG9ytOzbGTxHPxSyulTa2ZOIaiNt6DAQUOrmkhmmzSWOsxXNPOjeJQgcecckJkp67X4jSaQCAgwInlUZN3C449d8BljinvGd7DGE)HrT0cypJkF9N2xsGancyJyugXaySWOwAbSNrncGuINkSyuPR4Zu0eIrmkJyqJfgv6k(mfnHyulTa2ZOYxqEkMW2Ryu1qGqqqzuLc(tctatus2ueqEhO3HjV5WXBTDb)jC6blTa2RYEJCVdYq0Bf9wVxefim(8UXmjc4(z0v8zkAu1kPZusk4pjyJYbnIrzer0yHrLUIptrtigvneieeug13QrXmbmrjzttLL9oqV)1rV568grJAPfWEgv9YdRe2EfJyugXaASWOsxXNPOjeJQgcecckJke9O3c)jgErZVf(tjAINGygDfFMIEZHJ3q0JEl8NyhHXG7FUGkHtcSghb3FQghlyjOygDfFMIg1slG9mQsbtcSgnIrze)eJfgv6k(mfnHyu1qGqqqzuHOh9w4pXocJb3)CbvcNeynocU)unowWsqXm6k(mfnQLwa7zuFqIqgW9NeynAeJYi(HXcJkDfFMIMqmQAiqiiOmQw59B1OyV5273QrXmi9tN3C7DadG3w7DGE)wnkMnvw2OwAbSNrTG66OKSqiDIrmIrmQHtqmypJYigaedgGag8tmQZf8a3p2OQaCfYQYHHYCTp7T3wytEdMgxO49BHE)nsVcnlF9gswckasrVX7e5DHk7uju0BTDD)eM5ifwWrEhWp79a3lCcku07VceCiqcliJlF9wwV)kqWHajmjiJlF92kKTLTM5ifwWrEhWp79a3lCcku07VceCiqcdrgx(6TSE)vGGdbsycImU81BRcgqlBnZrkSGJ8(t(S3dCVWjOqrV)kqWHajSGmU81Bz9(RabhcKWKGmU81BRcgqlBnZrkSGJ8(t(S3dCVWjOqrV)kqWHajmezC5R3Y69xbcoeiHjiY4YxVTczBzRzososkaxHSQCyOmx7ZE7Tf2K3GPXfkE)wO3FhHKEN4l5R3qYsqbqk6nENiVluzNkHIERTR7NWmhPWcoY7p5ZEpW9cNGcf9(le9O3c)jgx(6TSE)fIE0BH)eJlm6k(mf)6DjEBPS0H1BRcAzRzosHfCK3FYN9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(1BRcAzRzosHfCK3F8zVh4EHtqHIE)vQmDcJlF9wwV)kvMoHXfgDfFMIF92QGw2AMJuybh59hF27bUx4euOO3FHOh9w4pX4YxVL17Vq0JEl8NyCHrxXNP4xVlXBlLLoSEBvqlBnZrYrsb4kKvLddL5AF2BVTWM8gmnUqX73c9(RoI)6nKSeuaKIEJ3jY7cv2PsOO3A76(jmZrkSGJ8oGF27bUx4euOO3FLktNW4YxVL17VsLPtyCHrxXNP4xVTkOLTM5ifwWrE)jF27bUx4euOO3FLktNW4YxVL17VsLPtyCHrxXNP4xVTkOLTM5i5iPaCfYQYHHYCTp7T3wytEdMgxO49BHE)flF9gswckasrVX7e5DHk7uju0BTDD)eM5ifwWrEJ4N9EG7fobfk693rsyCH9Pzm2xVL17VFAgJ91BRq0YwZCKcl4iVd4N9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(1BRcAzRzosHfCK3FYN9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(17s82szPdR3wf0YwZCKcl4iVdtF27bUx4euOO3FLktNW4YxVL17VsLPtyCHrxXNP4xVTkOLTM5ifwWrEJiIF27bUx4euOO3FHOh9w4pX4YxVL17Vq0JEl8NyCHrxXNP4xVTkOLTM5ifwWrEJya)S3dCVWjOqrV)Q3lIcegx(6TSE)vVxefimUWOR4Zu8R3L4TLYshwVTkOLTM5ifwWrEJ4hF27bUx4euOO3FHOh9w4pX4YxVL17Vq0JEl8NyCHrxXNP4xVlXBlLLoSEBvqlBnZrkSGJ8gXp(S3dCVWjOqrV)crp6TWFIXLVElR3FHOh9w4pX4cJUIptXVEBvqlBnZrkSGJ8grK9N9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(17s82szPdR3wf0YwZCKCKuaUczv5WqzU2N92BlSjVbtJlu8(TqV)QZufo91BizjOaif9gVtK3fQStLqrV1219tyMJuybh5nIF27bUx4euOO3FhjHXf2NMXyF9wwV)(Pzm2xVTcrlBnZrkSGJ8oGF27bUx4euOO3FhjHXf2NMXyF9wwV)(Pzm2xVTkOLTM5ifwWrE)jF27bUx4euOO3FHOh9w4pX4YxVL17Vq0JEl8NyCHrxXNP4xVTkOLTM5ifwWrE)XN9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(17s82szPdR3wf0YwZCKcl4iVvW(S3dCVWjOqrV)kvMoHXLVElR3FLktNW4cJUIptXVExI3wklDy92QGw2AMJuybh5DqKLp79a3lCcku07VJKW4c7tZySVElR3F)0mg7R3wf0YwZCKcl4iVrm4N9EG7fobfk69x9EruGW4YxVL17V69IOaHXfgDfFMIF9UeVTuw6W6TvbTS1mhPWcoYBed4N9EG7fobfk69xi6rVf(tmU81Bz9(le9O3c)jgxy0v8zk(17s82szPdR3wf0YwZCKcl4iVrmGF27bUx4euOO3FHOh9w4pX4YxVL17Vq0JEl8NyCHrxXNP4xVTkOLTM5ifwWrEJ4N8zVh4EHtqHIE)fIE0BH)eJlF9wwV)crp6TWFIXfgDfFMIF9UeVTuw6W6TvbTS1mhjhPWyACHcf9(dVlTa2Z7malyMJKrDeUpqMmQFQpL3Hqfw8omRWcbvY7WC0tiOJ0N6t5DywPK3igQ3igaed6i5ivAbShMncj9oXxYqm600EPrsCKkTa2dZgHKEN4lH7HdYVIKPy6LlLO4m4(tYAzW5ivAbShMncj9oXxc3dheftjGqtHE1enSqgSDblC6TNK2xACNjOJuPfWEy2iK07eFjCpCqPGjbwJHocjDHLKaMOHbzFek4neIE0BH)edVO53c)PenXtqmhoq0JEl8NyhHXG7FUGkHtcSghb3FQghlyjOyhPslG9WSriP3j(s4E4G8ewavondlXo0riPlSKeWenmi7JqbVHkuQmDcdRPts7lXN3nQOcHOh9w4pXWlA(TWFkrt8ee7i9P8MRIkiuSG9wSjVJOWsa75DDrV17MJ7859(8MRWJKw8EFEl2K3kaih9UUO3k4GGPk7DyCybCAb7nVsEl2K3ruyjG98EFExN3ONDHfk6nxBGC9EpBtN3InP0xi5nkMIEpcj9oXxcZ7qiDHIjV5k8iPfV3N3In5TcaYrVHuevtyV5AdKR3BEL8gXaeGjCOEl2aS3aS3bzb0BmP3lIzosLwa7HzJqsVt8LW9Wbl8iPL0(sInLMb5yOJqsxyjjGjAyqwadf8gQWcziiqi2iemv5e4Wc40cMrxXNPOIkKWy60eJWy60uAFjXMsVvJIb3Fcaby2uPGwOIwrwckyCKISczW2fSWP3EsAFPXDMGC4OqYsqbJJuKPvsNxbUhqN4ZfwS2r6t5nxfvqOyb7TytEhrHLa2Z76IER3nh35Z795Diewav2BfawIT31f9omVqgY795nYA9tEZRK3In5DefwcypV3N315n6zxyHIEZ1gixV3Z205Tytk9fsEJIPO3JqsVt8LWCKkTa2dZgHKEN4lH7HdYtybu50mSe7qhHKUWssat0WGSpcf8gwidbbcXgHGPkNahwaNwWm6k(mfvuHegtNMyegtNMs7lj2u6TAum4(taiaZMkf0cv0kYsqbJJuKvid2UGfo92ts7lnUZeKdhfswckyCKImTs68kW9a6eFUWI1ososLwa7H5E4G6f9ecMW2R4i9P8MRTEx2uf9UUO3waRZsqbzaYqERScUb6nD0eGWk49EM8oU3xX746TydWE)wO3J5sjcI9MN0fkM8giFJEZtEl76nESMMuY76IEptERR7R4nKQiiRK3waRZs8gpsAWdO9Mh99WmhPslG9WCpCqbwNLGcYaKbC)jS9kHcEdvOuWFsyaCAmxkrqhPpL3HXZBXM8wGGdbs82UWExEV3aqXK38OVxOEJv60EdeVNbIT3CfEK0I37ZBXM8wba5iZ7W45TmVExqYB9onsc4(9(TqVlV5k8iPfV3N3In5TcaYrVXkD6q9gftEl2K3ybU3pb9EVbGIjVP3J0cZ7W45DDEV3aqXK38OVN3aS3qQIk5npQ4DDRytqVXcCVFc69EdaftEZJ(EEpdYzVRmE9MN8gsvujV5vYBXM8watK3CfEK0I37ZBXM8wba5O36DIWEZxAe8EFpV17MJ78fQ3OyYBG4n45TytEJTlif9wGGdbs8wVBoUZN3Z79v8gCcbFeK8Egi2El2K3OJ6DcC)EZv4rslEVpVfBYBfaKJEJv60mVdJN3159EdaftEZJ(EERx0C0BEYBumf9UUO3ybKZER3jYB(sJG3Vf6D59dvqHK3CfEK0I37ZBXM8wba5yOEJIjVbcZ7W45D59T3a4rFpV3BaOyYBa2BivrLc1Bum5nq8g88giEpV3xXBWje8rqY7zGy794k0jGk79EdaftEZJ(EyVfOsG73Bz9MRWJKw8EFEl2K3kaih9gR0P9EHEdEEl2K3RytqVfi4qGeVb47R4DDEV3aqXuOEdWExEF7naE03Z79gakM8Egi2ExEN37NGER3nh35luVxO3a89v8gsvujM3HXZBXM8(b(TfVbyV)xW97TSEtx0BE6TqYBLwuO3hzzXBUcpsAX795TytERaGCmuVvqOyXBSuqXBum4(9wGGdbsWElR3tfcK3yui5Tytk59pjEJIPiZrQ0cypm3dhuGGdbscgk4nuGGdbsybz2foHIPep67POv8OVhRWJKws7lj2uAgKJm0rfTsHceCiqcdrMDHtOykXJ(EC4iqWHajmez6DZXD(yqAQahMdhbcoeiHfKP3nh35JfrHLa2d5dfi4qGegIm9U54oFSikSeWEwZHdp67Xk8iPL0(sInLMb5ilUZNIwjqWHajmez2foHIPep67POabhcKWqKP3nh35JfrHLa2d5dfi4qGewqME3CCNpwefwcypffi4qGegIm9U54oFminvGdpGpcuVBoUZhRWJKws7lj2uAgKJminvGdROE3CCNpwHhjTK2xsSP0mihzqAQahg5igaoCei4qGewqME3CCNpwefwcyVb8rG6DZXD(yfEK0sAFjXMsZGCKbPPcCyR5Wrk4pjmbmrjztrafOE3CCNpwHhjTK2xsSP0mihzqAQah2AoCuOabhcKWcYSlCcftjE03trRei4qGegIm7cNqXuIh99u0kE03Jv4rslP9LeBkndYrwCNpoCei4qGegIm9U54oFminvGdJ8pSwrR07MJ78Xk8iPL0(sInLMb5idstf4WihXaWHJabhcKWqKP3nh35JbPPcC4b8bY17MJ78Xk8iPL0(sInLMb5idstf4WwZHJcfi4qGegIm7cNqXuIh99u0kfkqWHajmez2foP3nh35JdhbcoeiHHitVBoUZhlIclbShYhkqWHajSGm9U54oFSikSeWEC4iqWHajmez6DZXD(yqAQah2ARDKkTa2dZ9Wbfi4qGeedf8gkqWHajmez2foHIPep67POv8OVhRWJKws7lj2uAgKJm0rfTsHceCiqcliZUWjumL4rFpoCei4qGewqME3CCNpgKMkWH5WrGGdbsyiY07MJ78XIOWsa7H8HceCiqclitVBoUZhlIclbSN1C4WJ(EScpsAjTVKytPzqoYI78POvceCiqcliZUWjumL4rFpffi4qGewqME3CCNpwefwcypKpuGGdbsyiY07MJ78XIOWsa7POabhcKWcY07MJ78XG0ubo8a(iq9U54oFScpsAjTVKytPzqoYG0uboSI6DZXD(yfEK0sAFjXMsZGCKbPPcCyKJya4WrGGdbsyiY07MJ78XIOWsa7nGpcuVBoUZhRWJKws7lj2uAgKJminvGdBnhosb)jHjGjkjBkcOa17MJ78Xk8iPL0(sInLMb5idstf4WwZHJcfi4qGegIm7cNqXuIh99u0kbcoeiHfKzx4ekMs8OVNIwXJ(EScpsAjTVKytPzqoYI78XHJabhcKWcY07MJ78XG0ubomY)WAfTsVBoUZhRWJKws7lj2uAgKJminvGdJCedahoceCiqclitVBoUZhdstf4Wd4dKR3nh35Jv4rslP9LeBkndYrgKMkWHTMdhfkqWHajSGm7cNqXuIh99u0kfkqWHajSGm7cN07MJ78XHJabhcKWcY07MJ78XIOWsa7H8HceCiqcdrME3CCNpwefwcypoCei4qGewqME3CCNpgKMkWHT2AhPpL3Lwa7H5E4GOykbeAc7ivAbShM7HdkW6SeuqgGmG7pHTxXrQ0cypm3dheftjGqt4qbVHJqk80VoYcYk8iPL0(sInLMb5ihopWVTKG0uboCGigahPslG9WCpCqDLZPslG9szawc9QjAOoIDKkTa2dZ9Wb1voNkTa2lLbyj0RMOHyjuWByPfq4uIoAcq4ar0rQ0cypm3dhux5CQ0cyVugGLqVAIgQZufofk4nS0ciCkrhnbimYd6i5ivAbShMPJ4H1PjSaRCsx5COG3q9U54oFmEclGkNMHLyZG0ubomYdyaCKkTa2dZ0rm3dh8bGeFE3yOG3q9U54oFmEclGkNMHLyZG0ubomYdyaCKkTa2dZ0rm3dhKNGycIa4(df8gAfp67XMb5ycpcGabZqh5WrH6nC6Qtyh43wsVIuKh99yfEK0sAFjXMsZGCKHoQip67X4jSaQCAgwIndD0AfT6b(TLeKMkWHrUE3CCNpgpbXeebW9ZIOWsa7XDefwcypoCSsk4pjmBQYInBulbgWp4WrHsLPtyiaYzcMahwaNwS2AoCEGFBjbPPcC4adgqhPslG9WmDeZ9Wb5Z7gtpuOsHcEdTIh99yZGCmHhbqGGzOJC4Oq9goD1jSd8BlPxrkYJ(EScpsAjTVKytPzqoYqhvKh99y8ewavondlXMHoATIw9a)2scstf4WixVBoUZhJpVBm9qHkXIOWsa7XDefwcypoCSsk4pjmBQYInBulbgWp4WrHsLPtyiaYzcMahwaNwS2AoCEGFBjbPPcC4adISDKkTa2dZ0rm3dhmd(TfCsbHg)NOtCKkTa2dZ0rm3dhCCfWEHcEd5rFpwHhjTK2xsSP0mihzOJC48a)2scstf4WbIiY2rYrQ0cypmtNPkCAyHhjTK2xsSP0mihDKkTa2dZ0zQcN4E4G8fKNIjS9kHQvsNPKuWFsWddgk4nCKe2ubogp67XEq6qgLyOJkoscBQahJh99ypiDiJsminvGdh4WFD0rQ0cypmtNPkCI7HdoHMfa2ELqbVH)64agjHnvGJXJ(EmEQWssNPkCIbPPcCyKhagIF4ivAbShMPZufoX9WbLcMeyngk4neIE0BH)edVO53c)PenXtqSIsbtcSgzqAQahoWFDur9U54oFSxUGedstf4Wb(RJosLwa7Hz6mvHtCpCWxUGuOzWrjDCiIFek4nukysG1idDuri6rVf(tm8IMFl8Ns0epbXosLwa7Hz6mvHtCpCWivIDsBxiaRPqbVHVvJI5wxyjbPF6c8TAumBQSSJuPfWEyMotv4e3dhCgKJj8iaceSJuPfWEyMotv4e3dhKVG8umHTxjuTs6mLKc(tcEyWqbVHp0CobjTDb)PKaMOa)1rf17MJ78X4jSaQCAgwIndstf4WC4O3nh35JXtybu50mSeBgKMkWHdmiIC)RJkkvMoHH10jP9L4Z7gDKkTa2dZ0zQcN4E4G8ewavondlX2rQ0cypmtNPkCI7Hdcj8ELaU)ubH7SJuPfWEyMotv4e3dhel10ifPqbVH8OVhRWJKws7lj2uAgKJm0roCEGFBjbPPcC4ad(HJuPfWEyMotv4e3dh8LlLOycBVIJuPfWEyMotv4e3dhebqoNW2R4ivAbShMPZufoX9Wb12GPIGvcBVIJuPfWEyMotv4e3dhKpVBeBtrhPslG9WmDMQWjUhoyLMqHrcM2xsd3zSJuPfWEyMotv4e3dhKVGW6Ncf8goscBQahJh99ypiDiJsminvGdJCYYKgvOKaMihPslG9WmDMQWjUhoicGCoP3PP6IHcEdFRgfJC9IfUlTa2JnHMfa2EfMEXIJuPfWEyMotv4e3dhKV(t7ljqGgbCOG3qE03JXtybu50mSeBwCNpoCEGFBjbPPcC4a)WrQ0cypmtNPkCI7HdgbqkXtfwCKkTa2dZ0zQcN4E4G8fKNIjS9kHQvsNPKuWFsWddgk4nuk4pjmbmrjztrafyyIdhTDb)jC6blTa2RYipidrf17frbcJpVBmtIaUFhPslG9WmDMQWjUhoOE5HvcBVsOG3W3QrXmbmrjzttLLd8xh56q0rQ0cypmtNPkCI7HdkfmjWAmuWBie9O3c)jgErZVf(tjAINGyoCGOh9w4pXocJb3)CbvcNeynocU)unowWsqXosLwa7Hz6mvHtCpCWhKiKbC)jbwJHcEdHOh9w4pXocJb3)CbvcNeynocU)unowWsqXosLwa7Hz6mvHtCpCWcQRJsYcH0jHcEdT6TAum3VvJIzq6NoUdyaSoW3QrXSPYYososLwa7HzyzyHhjTK2xsSP0mihDKkTa2dZWc3dhKVG8umHTxjuWB4ijSPcCmE03J9G0HmkXqhvCKe2ubogp67XEq6qgLyqAQahoWH)6OJuPfWEygw4E4GsbtcSgdf8gcrp6TWFIHx08BH)uIM4jiwrPGjbwJminvGdh4VoQOE3CCNp2lxqIbPPcC4a)1rhPslG9WmSW9WbF5csHMbhL0XHi(rOG3qPGjbwJm0rfHOh9w4pXWlA(TWFkrt8ee7ivAbShMHfUhoiFE3i2MIosLwa7HzyH7HdodYXeEeabc2rQ0cypmdlCpCWxUuIIjS9kosLwa7HzyH7HdIaiNty7vCKkTa2dZWc3dhKVG8umHTxjuWBOE3CCNpgpHfqLtZWsSzqAQahoWGiY1PTl4pHtpyPfWEvM7FDurPY0jmSMojTVeFE3ihop0CobjTDb)PKaMOa)1rf17MJ78X4jSaQCAgwIndstf4WC4if8NeMaMOKSPiGcmm5ivAbShMHfUhoyKkXoPTleG1uOG3W3QrXCRlSKG0pDb(wnkMnvw2rQ0cypmdlCpCqSutJuKcf8gYJ(EScpsAjTVKytPzqoYqh5W5b(TLeKMkWHdm4hosLwa7HzyH7HdwPjuyKGP9L0WDg7ivAbShMHfUhoiKW7vc4(tfeUZHcEd5rFpgpHfqLtZWsSzOJC48a)2scstf4WbgmaosLwa7HzyH7HdYtybu50mSe7qbVH6DZXD(yZGCmHhbqGGzqAQahg5b)GdhfQ3WPRoHDGFBj9kIdNh43wsqAQahoWGF4ivAbShMHfUhoO2gmveSsy7vCKkTa2dZWc3dhes49kbC)Pcc35qbVH8OVhJNWcOYPzyj2m0roCEGFBjbPPcC4adgahPslG9WmSW9Wb5jSaQCAgwIDOG3q9U54oFSzqoMWJaiqWminvGdJ8GFWHJEdNU6egckbb1POv6DZXD(yqcVxjG7pvq4oZG0uboCGFWHJE3CCNpgKW7vc4(tfeUZminvGdJCedG1C4if8NeMaMOKSPiGcm4hC4yLc1B40vNWoWVTKEfPOc1B40vNWqqjiOoRDKkTa2dZWc3dhuBdMkcwjS9kosLwa7HzyH7HdIaiNt6DAQUOJuPfWEygw4E4G81FAFjbc0iGdf8gYJ(EmEclGkNMHLyZI78XHZd8BljinvGdh4hosLwa7HzyH7HdgbqkXtfwCKkTa2dZWc3dhuV8WkHTxjuWBOvVvJIhGEXc3VvJIzq6NoUoR07MJ78XqaKZj9onvxKbPPcC4be0AKxAbShdbqoN070uDrMEXcho6DZXD(yiaY5KENMQlYG0ubomYdY9VoAnhowXJ(EmEclGkNMHLyZqh5WHh99yhHXG7FUGkHtcSghb3FQghlyjOyg6O1kQqi6rVf(tmlPgZvIGue9sZfmTWib5W5b(TLeKMkWHdmGosLwa7HzyH7HdYxqEkMW2Rek4nKh99yZGCmHhbqGGzOJC4OTl4pHtpyPfWEvg5bziQOEVikqy85DJzseW97ivAbShMHfUhoyb11rPr0mMcf8gYJ(EmEclGkNMHLyZI78XHZd8BljinvGdh4hosLwa7HzyH7HdkfmjWAmuWBie9O3c)jgErZVf(tjAINGyoCGOh9w4pXocJb3)CbvcNeynocU)unowWsqXosLwa7HzyH7Hd(GeHmG7pjWAmuWBie9O3c)j2rym4(NlOs4KaRXrW9NQXXcwck2rQ0cypmdlCpCWcQRJsYcH0jHcEdT6TAum3VvJIzq6NoUd(H1b(wnkMnvw2OIhjTrze)iGgXigda]] )

end
