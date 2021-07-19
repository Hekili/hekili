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


    spec:RegisterPack( "Beast Mastery", 20210715, [[d80R)bqiHupsvIYLKGQ2Ke6tiPgfc1PqiRsiP8kjWSGiUfeP2fOFbrzysqoMqSmjYZqsQPHKextvQ2MQe5BcjPXjKeohssADij8ocQsAEcLUNe1(ek(hbvfhuckwievpeIKjsqvCrjO0hLGkJKGQuNejrzLeKzQkHBsqvIDQkPFkKunucQkTucQQEQOAQQs5RQsunwHeNvijAVQQ)kYGbomLftOhlyYeDzuBgP(mcgnsCAPwnsIQxtGzlPBRk2nv)wLHdjhhjrwUINd10jDDeTDi13HW4jOCEHQ1tqL5lk7xP)r(V9ZLMY)xlvOsrkuuncvfgHQFpQGQq1)Cnok(NJYccmc8p3Th(NJC2W6ceEXWkpX)5OS41ZK)3(54JCc8pNIQOWubYqgHwPqkcd3dYW9dz10(8Wy0kYW9taz)CrYUQuz(x8NlnL)VwQqLIuOOAeQkmcv)Eubvhv)5gPs5MFEE)Gu)CkTuY(x8NlzC4NJC2W6ceEXWkpXxGWBsx5zfsiYA8fe5DKSGsfQuKFETXk()2pxY0gzv)V9FnY)TFUf0(8FE4iDLNeMYP)C2nXkl)i)R)xl9F7NZUjwz5h5)ClO95)CDmNkr21w4ANqct50FUKXHPrP95)8c3TaJcBYfyUCbVnMtLi7AlC8cEv4lsTa25NMXizbi4fipNADbYBbkLgVa6BwaQQfNh8ce5GrI5f0k1YfiYlqVBbyu2Zt8fyUCbi4femNADbdBYUgFbVnMtLwagfhA6oSarsAAm8NhMw5PTFE0lqTHaRWgNqvT4881)Ru9)TFo7MyLLFK)ZdtR802ppCOz3Cfki(0MVGIliCxvEiCOHrXbnD0jLcNq0vjC4hRD8ckUGWDv5HWHdJp302jKSzoeWHFS2XlilBbrVGWHMDZvOG4tB(ckUGWDv5HWHggfh00rNukCcrxLWHFS2X)ClO95)8GvRjlO95PAJ1FETXAYTh(NRt7cyf)1)RuL)B)C2nXkl)i)NBbTp)NhSAnzbTppvBS(ZRnwtU9W)8Ge)1)RV)F7NZUjwz5h5)8W0kpT9ZTG2O5e78tZ4fe7ck9ZTG2N)ZdwTMSG2NNQnw)51gRj3E4Fow)6)1x6)2pNDtSYYpY)5HPvEA7NBbTrZj25NMXliMfe5NBbTp)NhSAnzbTppvBS(ZRnwtU9W)8qLn08x)6ph1WH7r00)B)xJ8F7NBbTp)NJjFEopHI1Fo7MyLLFK)1)RL(V9ZTG2N)ZfpvRSmrxT4Ser7es6jS2)5SBIvw(r(x)Vs1)3(5wq7Z)50vgtjmgT(Zz3eRS8J8V(FLQ8F7NZUjwz5h5)C3E4FUjCyk2y4e95A6OtOoe88ZTG2N)ZnHdtXgdNOpxthDc1HGNV(F99)B)C2nXkl)i)NJA4GH1K2p8ppc89FUf0(8FUAtshd1ppmTYtB)8H0z6BiWq8rwPVHaN4hrEWq2nXklxqw2cgsNPVHadDgJBNacBIJt6yOq1oHKHcLnMsIHSBIvw(1)RV0)TFo7MyLLFK)ZrnCWWAs7h(Nhb((p3cAF(pxKXAB1eIXuk)8W0kpT9ZJEbQvzxH4a7A6OtI17Kq2nXklxqXfe9cgsNPVHadXhzL(gcCIFe5bdz3eRS8R)xJQ)3(5SBIvw(r(ph1WbdRjTF4FEeiv)ZLmomnkTp)NxyKu5KyfVaLcVaj5yAF(cmxUGWDv5HWxWrVGcdgfh0fC0lqPWl4L3v5cmxUaHVt)y1fqL5yT9GIxGy8fOu4fijht7ZxWrVaZxaPtXWklxqHdPeEwackSVaLchN6HxajMLla1WH7r0u4cqohmsmVGcdgfh0fC0lqPWl4L3v5cgwsgy8ckCiLWZceJVGsfQqpyKSaLsJxqJxqeivVamhoxIH)ClO95)CdJIdA6OtkfoHORYFEyALN2(5rVat44PvgIA6hRMAhRThumKDtSYYfuCbrVagJzpWqgJzpWPJoPu4e9fiXTti1tJHpgv(nlO4ciEbmvISrHILqt4WuSXWj6Z10rNqDi4zbzzli6fWujYgfkwcdXd1tNZ7qsSAyDbe91)Rrf)3(5SBIvw(r(ph1WbdRjTF4FEe47)CjJdtJs7Z)5fgjvojwXlqPWlqsoM2NVaZLliCxvEi8fC0la5mwBRUGx(ykLfyUCbcVnHJxWrVaHFJaVaX4lqPWlqsoM2NVGJEbMVasNIHvwUGchsj8SaeuyFbkfoo1dVasmlxaQHd3JOPWFUf0(8FUiJ12QjeJPu(5HPvEA7NBchpTYqut)y1u7yT9GIHSBIvwUGIli6fWym7bgYym7boD0jLcNOVajUDcPEAm8XOYVzbfxaXlGPsKnkuSeAchMIngorFUMo6eQdbplilBbrVaMkr2OqXsyiEOE6CEhsIvdRlGOV(1FEOYgA()2)1i)3(5SBIvw(r(ppmTYtB)8OxWyTmXOzxHMuIHSWASIxqw2cgRLjgn7k0KsmC4hRD8cIP8cIuOfKLTalOnAoXo)0mEbXuEbJ1YeJMDfAsjggosxxquBbL(5wq7Z)5ggfh00rNukCcrxLF9)AP)B)C2nXkl)i)NBbTp)NlAJiltykN(ZdtR802pxKKMgspSlCXHKOwqXfisstdPh2fU4WHFS2Xli2YlGqqUGSSfisstdr0vzcJQNwXqsulO4ccuSHaJt0Jf0(CRUGywqeivzbfxWq6m9neyi9yeEyxXPJoPu4exL8KmxR8GHSBIvw(ZdXdvoP2qGv8)1iF9)kv)F7NZUjwz5h5)8W0kpT9ZjeKlaPxGijnnuKnSMcv2qZWHFS2XliMfuiyP3)5wq7Z)5pKvTXuo9R)xPk)3(5SBIvw(r(ppmTYtB)8H0z6BiWquhzGs6OtJjC3KOhJWd7kgYUjwz5ckUarsAAiD1IZdo9yJaijQFUf0(8FUGUwtykN(1)RV)F7NZUjwz5h5)8W0kpT9ZhsNPVHadrDKbkPJonMWDtIEmcpSRyi7MyLL)ClO95)C6QfNLjmLt)6)1x6)2pNDtSYYpY)5HPvEA7NpKotFdbgIpYk9ne4e)iYdgYUjwz5ckUa1MKogk4Wpw74fe7cieKlO4cc3vLhchsxTHHd)yTJxqSlGqq(ZTG2N)ZvBs6yO(6)1O6)TFo7MyLLFK)ZdtR802pxTjPJHcsIAbfxWq6m9neyi(iR03qGt8Jipyi7MyLL)ClO95)C6Qn8x)Vgv8F7NZUjwz5h5)8W0kpT9ZPVajEbfSGGH10WeyFbXUa6lqIHpMW(5wq7Z)5s2ukPaftWypF9)kv9)2pNDtSYYpY)5HPvEA7Nh9cgRLjgn7k0KsmKfwJv8cYYwWyTmXOzxHMuIHd)yTJxqmLxqKcTGSSfybTrZj25NMXliMYlySwMy0SRqtkXWWr66cIAlO0p3cAF(phrxLjmQEAf)1)Rrk0)TFo7MyLLFK)ZTG2N)ZfTrKLjmLt)5HPvEA7NttwRPHduSHaN0(HxqSlGqqUGIliCxvEiCOiJ12QjeJPuGd)yTJxqw2cc3vLhchkYyTTAcXykf4Wpw74fe7cIuAbfSacb5ckUa1QSRqCGDnD0jX6Dsi7MyLL)8q8qLtQneyf)FnYx)VgjY)TFo7MyLLFK)ZdtR802pp6fmwltmA2vOjLyilSgR4fKLTGXAzIrZUcnPedh(XAhVGykVG3xqw2cSG2O5e78tZ4fet5fmwltmA2vOjLyy4iDDbrTfu6NBbTp)NlYyTTAcXykLV(FnsP)B)C2nXkl)i)NhMw5PTFE0lySwMy0SRqtkXqwynwXlilBbJ1YeJMDfAsjgo8J1oEbXuEbVVGSSfybTrZj25NMXliMYlySwMy0SRqtkXWWr66cIAlO0p3cAF(pFy85M2oHKnZH4R)xJq1)3(5SBIvw(r(ppmTYtB)CrsAAOHrXbnD0jLcNq0vjKe1cYYwG4HXlO4cOBcu00Wpw74fe7cI8(p3cAF(phR2dkwYF9)AeQY)TFUf0(8FocRRTtizZCi(5SBIvw(r(x)Vg59)B)ClO95)C6QfNLjmLt)5SBIvw(r(x)Vg5L(V9ZTG2N)Zf01Act50Fo7MyLLFK)1)RrIQ)3(5wq7Z)5bk9JXJLWuo9NZUjwz5h5F9)AKOI)B)ClO95)CX6Dsmfw(Zz3eRS8J8V(Fncv9)2p3cAF(p3spKJKN0rNcZHa)Zz3eRS8J8V(FTuH(V9Zz3eRS8J8FEyALN2(5IK00q6HDHloC4hRD8cIzbSW4aPYjTF4FUf0(8FUOnJrG)6)1sr(V9Zz3eRS8J8FEyALN2(50xGeVGywq4W6ckybwq7ZHpKvTXuofgoS(ZTG2N)Zf01AkCppMl)6)1sL(V9Zz3eRS8J8FEyALN2(5IK00qrgRTvtigtPaLhcFbzzlq8W4fuCb0nbkAA4hRD8cIDbV)ZTG2N)ZfncPJoPtheG)6)1su9)TFUf0(8FUShojYgw)5SBIvw(r(x)VwIQ8F7NZUjwz5h5)ClO95)CrBezzct50FEyALN2(5QneyfQ9dN0ljBEbXUaQ6cYYwqGIneyCIESG2NB1feZcIalTGIliCUKSvOy9ozLvTDcq2nXkl)5H4HkNuBiWk()AKV(FT07)3(5SBIvw(r(ppmTYtB)C6lqIHA)Wj9spMWwqSlGqqUGO2ck9ZTG2N)ZdN4yjmLt)6)1sV0)TFo7MyLLFK)ZdtR802pFiDM(gcmeFKv6BiWj(rKhmKDtSYYfKLTGH0z6BiWqNX42jGWM44KogkuTtizOqzJPKyi7MyLL)ClO95)C1MKogQV(FTuu9)2pNDtSYYpY)5HPvEA7NpKotFdbg6mg3obe2ehN0XqHQDcjdfkBmLedz3eRS8NBbTp)NtpmlCTtiPJH6R)xlfv8F7NZUjwz5h5)8W0kpT9ZjEb0xGeVGcwa9fiXWHjW(ckybuDHwarli2fqFbsm8Xe2p3cAF(p3MG5CsVzyx)6x)5bj()2)1i)3(5SBIvw(r(ppmTYtB)8WDv5HWHImwBRMqmMsbo8J1oEbXSaQUq)ClO95)CZdmwhRMcwT(1)RL(V9Zz3eRS8J8FEyALN2(5H7QYdHdfzS2wnHymLcC4hRD8cIzbuDH(5wq7Z)509WI17KF9)kv)F7NZUjwz5h5)8W0kpT9ZjEbIK00qeDvMWO6PvmKe1cYYwq0liCOz3Cf6nbkAI24fuCbIK00qdJIdA6OtkfoHORsijQfuCbIK00qrgRTvtigtPajrTaIwqXfq8cOBcu00Wpw74feZcc3vLhchkYdMhbTtakjht7ZxqblqsoM2NVGSSfq8cuBiWkKcBvLcevqxqSlGQFFbzzli6fOwLDfkORvEsTJ12dkKDtSYYfq0ciAbzzlq8W4fuCb0nbkAA4hRD8cIDbrO6FUf0(8FUipyEe0oHV(FLQ8F7NZUjwz5h5)8W0kpT9ZjEbIK00qeDvMWO6PvmKe1cYYwq0liCOz3Cf6nbkAI24fuCbIK00qdJIdA6OtkfoHORsijQfuCbIK00qrgRTvtigtPajrTaIwqXfq8cOBcu00Wpw74feZcc3vLhchkwVtMOjN4qj5yAF(ckybsYX0(8fKLTaIxGAdbwHuyRQuGOc6cIDbu97lilBbrVa1QSRqbDTYtQDS2EqHSBIvwUaIwarlilBbIhgVGIlGUjqrtd)yTJxqSliYl9ZTG2N)ZfR3jt0Kt8V(F99)B)ClO95)8AtGIItu5KscpSR)C2nXkl)i)R)xFP)B)C2nXkl)i)NhMw5PTFUijnn0WO4GMo6KsHti6QesIAbzzlGUjqrtd)yTJxqSlO0l9ZTG2N)ZrDAF(x)6phR)3(Vg5)2pNDtSYYpY)5HPvEA7Nh9cgRLjgn7k0KsmKfwJv8cYYwq0lySwMy0SRqtkXqsulO4ciEbJ1YeJMDfAsjgkjht7ZxqblySwMy0SRqtkXW2xqSlOuHwqw2ciEbJ1YeJMDfAsjggosxxq5fezbfxq4qZU5kuq8PnFbeTaIwqw2cgRLjgn7k0KsmKe1ckUGXAzIrZUcnPedh(XAhVGywqeQ6p3cAF(p3WO4GMo6KsHti6Q8R)xl9F7NZUjwz5h5)8W0kpT9ZfjPPH0d7cxCijQfuCbIK00q6HDHloC4hRD8cIT8cieKlilBbIK00qeDvMWO6PvmKe1ckUGafBiW4e9ybTp3QliMfebsvwqXfmKotFdbgspgHh2vC6OtkfoXvjpjZ1kpyi7MyLL)ClO95)CrBezzct50V(FLQ)V9Zz3eRS8J8FEyALN2(5dPZ03qGH4JSsFdboXpI8GHSBIvwUGIlqTjPJHco8J1oEbXUacb5ckUGWDv5HWH0vBy4Wpw74fe7cieK)ClO95)C1MKogQV(FLQ8F7NZUjwz5h5)ClO95)C6Qn8ppmTYtB)C1MKogkijQfuCbdPZ03qGH4JSsFdboXpI8GHSBIvw(ZRTZPG8Nx69V(F99)B)ClO95)CX6Dsmfw(Zz3eRS8J8V(F9L(V9Zz3eRS8J8FEyALN2(5rVGXAzIrZUcnPedzH1yfVGSSfe9cgRLjgn7k0KsmKe1ckUGXAzIrZUcnPedLKJP95lOGfmwltmA2vOjLyy7li2fuQqlilBbJ1YeJMDfAsjgsIAbfxWyTmXOzxHMuIHd)yTJxqmlicv9NBbTp)NJORYegvpTI)6)1O6)TFUf0(8FoD1IZYeMYP)C2nXkl)i)R)xJk(V9ZTG2N)Zf01Act50Fo7MyLLFK)1)Ru1)B)C2nXkl)i)NhMw5PTFE4UQ8q4WHXNBA7es2mhc4Wpw74fe7cieKlO4ciEbrVa1QSRqwyOQhUrZjmLtHSBIvwUGSSfisstdfR3jRKyfsIAbeTGSSfe9cchA2nxHcIpT5lilBbH7QYdHdhgFUPTtizZCiGd)yTJxqw2cuBiWku7hoPxs28cIDbV)ZTG2N)ZryDTDcjBMdXx)VgPq)3(5SBIvw(r(ppmTYtB)8WDv5HWHImwBRMqmMsbo8J1oEbXUGiLwquBbbk2qGXj6XcAFUvxqblGqqUGIlqTk7kehyxthDsSENeYUjwz5cYYwanzTMgoqXgcCs7hEbXUacb5ckUGWDv5HWHImwBRMqmMsbo8J1oEbzzlqTHaRqTF4KEjzZli2fqv)5wq7Z)5I2iYYeMYPF9)AKi)3(5SBIvw(r(ppmTYtB)C6lqIxqbliyynnmb2xqSlG(cKy4JjSFUf0(8FUKnLskqXem2Zx)VgP0)TFo7MyLLFK)ZdtR802pxKKMgAyuCqthDsPWjeDvcjrTGSSfO2qGvO2pCsVKS5fe7cI8(p3cAF(phR2dkwYF9)AeQ()2p3cAF(p3spKJKN0rNcZHa)Zz3eRS8J8V(Fncv5)2pNDtSYYpY)5HPvEA7Nt8cejPPHImwBRMqmMsbsIAbzzlqTHaRqTF4KEjzZli2fePqlGOfuCbeVGOxWyTmXOzxHMuIHSWASIxqw2cIEbJ1YeJMDfAsjgsIAbfxaXlySwMy0SRqtkXqj5yAF(ckybJ1YeJMDfAsjg2(cIDbLk0cYYwWyTmXOzxHMuIHHJ01fuEbrwarlilBbJ1YeJMDfAsjgsIAbfxWyTmXOzxHMuIHd)yTJxqmlicvDbe9ZTG2N)ZhgFUPTtizZCi(6)1iV)F7NZUjwz5h5)8W0kpT9ZjEbH7QYdHdr0vzcJQNwXWHFS2XliMfe59fKLTGWHMDZvOG4tB(ckUaIxq4UQ8q4WHXNBA7es2mhc4Wpw74fe7cEFbzzliCxvEiC4W4ZnTDcjBMdbC4hRD8cIzbLk0ciAbzzlqTHaRqTF4KEjzZli2fe59fKLTaIxq0liCOz3Cf6nbkAI24fuCbrVGWHMDZvOG4tB(ciAbeTGIlG4fe9cgRLjgn7k0KsmKfwJv8cYYwq0lySwMy0SRqtkXqsulO4ciEbJ1YeJMDfAsjgkjht7ZxqblySwMy0SRqtkXW2xqSlOuHwqw2cgRLjgn7k0KsmmCKUUGYliYciAbzzlySwMy0SRqtkXqsulO4cgRLjgn7k0KsmC4hRD8cIzbrOQlGOFUf0(8FUiJ12QjeJPu(6)1iV0)TFUf0(8FEGs)y8yjmLt)5SBIvw(r(x)VgjQ(F7NBbTp)NlOR1u4EEmx(Zz3eRS8J8V(FnsuX)TFo7MyLLFK)ZdtR802pxKKMgkYyTTAcXykfO8q4lilBbIhgVGIlGUjqrtd)yTJxqSl49FUf0(8FUOriD0jD6Ga8x)VgHQ(F7NBbTp)Nl7HtISH1Fo7MyLLFK)1)RLk0)TFo7MyLLFK)ZdtR802pN4fqFbs8cq6feoSUGcwa9fiXWHjW(cIAlG4feURkpeouqxRPW98yUeo8J1oEbi9cISaIwqmlWcAFouqxRPW98yUegoSUGSSfeURkpeouqxRPW98yUeo8J1oEbXSGilOGfqiixarlilBbeVarsAAOiJ12QjeJPuGKOwqw2cejPPHoJXTtaHnXXjDmuOANqYqHYgtjXqsulGOfuCbrVGH0z6BiWqQKHQAjEyjPNqyt6gjpq2nXklxqw2cepmEbfxaDtGIMg(XAhVGyxav)ZTG2N)ZdN4yjmLt)6)1sr(V9Zz3eRS8J8FEyALN2(5IK00qeDvMWO6PvmKe1cYYwqGIneyCIESG2NB1feZcIalTGIliCUKSvOy9ozLvTDcq2nXkl)5wq7Z)5I2iYYeMYPF9)APs)3(5SBIvw(r(ppmTYtB)CrsAAOiJ12QjeJPuGYdHVGSSfiEy8ckUa6Mafnn8J1oEbXUG3)5wq7Z)52emNtOiRy(R)xlr1)3(5SBIvw(r(ppmTYtB)8H0z6BiWq8rwPVHaN4hrEWq2nXklxqw2cgsNPVHadDgJBNacBIJt6yOq1oHKHcLnMsIHSBIvw(ZTG2N)ZvBs6yO(6)1suL)B)C2nXkl)i)NhMw5PTF(q6m9neyOZyC7eqytCCshdfQ2jKmuOSXusmKDtSYYFUf0(8Fo9WSW1oHKogQV(FT07)3(5SBIvw(r(ppmTYtB)CIxa9fiXlOGfqFbsmCycSVGcwqK3xarli2fqFbsm8Xe2p3cAF(p3MG5CsVzyx)6x)560UawX)3(Vg5)2pNDtSYYpY)5hQFoM1FUf0(8FoABAtSY)C0wLK)5IK00WHXNBA7es2mhcijQfKLTarsAAOHrXbnD0jLcNq0vjKe1phTnj3E4FooUhsKO(6)1s)3(5SBIvw(r(p)q9ZXS(ZTG2N)ZrBtBIv(NJ2QK8ppCOz3Cfki(0MVGIlqKKMgom(CtBNqYM5qajrTGIlqKKMgAyuCqthDsPWjeDvcjrTGSSfe9cchA2nxHcIpT5lO4cejPPHggfh00rNukCcrxLqsu)C02KC7H)5yDoNqch3djsuF9)kv)F7NZUjwz5h5)8d1phZAt)ZTG2N)ZrBtBIv(NJ2MKBp8phRZ5es44Ein8J1o(NhMw5PTFUijnn0WO4GMo6KsHti6Qekpe(phTvj5exX8ppCxvEiCOHrXbnD0jLcNq0vjC4hRD8phTvj5FE4UQ8q4WHXNBA7es2mhc4Wpw74feRWNfeURkpeo0WO4GMo6KsHti6Qeo8J1o(R)xPk)3(5SBIvw(r(p)q9ZXS20)ClO95)C020MyL)5OTj52d)ZX6CoHeoUhsd)yTJ)5HPvEA7NlsstdnmkoOPJoPu4eIUkHKO(5OTkjN4kM)5H7QYdHdnmkoOPJoPu4eIUkHd)yTJ)5OTkj)Zd3vLhchom(CtBNqYM5qah(XAh)1)RV)F7NZUjwz5h5)8d1phZAt)ZTG2N)ZrBtBIv(NJ2MKBp8phh3dPHFS2X)8W0kpT9ZdhA2nxHcIpT5)C0wLKtCfZ)8WDv5HWHggfh00rNukCcrxLWHFS2X)C0wLK)5H7QYdHdhgFUPTtizZCiGd)yTJxqmcFwq4UQ8q4qdJIdA6OtkfoHORs4Wpw74V(F9L(V9Zz3eRS8J8FUf0(8FUoTlG1i)8W0kpT9ZjEb60UawHAeifdNiXCsKKMEbzzliCOz3Cfki(0MVGIlqN2fWkuJaPy4u4UQ8q4lGOfuCbeVa020MyLHyDoNqch3djsulO4ciEbrVGWHMDZvOG4tB(ckUGOxGoTlGvOwcsXWjsmNejPPxqw2cchA2nxHcIpT5lO4cIEb60UawHAjifdNc3vLhcFbzzlqN2fWkulbd3vLhcho8J1oEbzzlqN2fWkuJaPy4ejMtIK00lO4ciEbrVaDAxaRqTeKIHtKyojsstVGSSfOt7cyfQrGH7QYdHdLKJP95liMYlqN2fWkulbd3vLhchkjht7ZxarlilBb60UawHAeifdNc3vLhcFbfxq0lqN2fWkulbPy4ejMtIK00lO4c0PDbSc1iWWDv5HWHsYX0(8fet5fOt7cyfQLGH7QYdHdLKJP95lGOfKLTGOxaABAtSYqSoNtiHJ7HejQfuCbeVGOxGoTlGvOwcsXWjsmNejPPxqXfq8c0PDbSc1iWWDv5HWHsYX0(8fG0l49fe7cqBtBIvgIJ7H0Wpw74fKLTa020MyLH44Ein8J1oEbXSaDAxaRqncmCxvEiCOKCmTpFbiBbLwarlilBb60UawHAjifdNiXCsKKMEbfxaXlqN2fWkuJaPy4ejMtIK00lO4c0PDbSc1iWWDv5HWHsYX0(8fet5fOt7cyfQLGH7QYdHdLKJP95lO4ciEb60UawHAey4UQ8q4qj5yAF(cq6f8(cIDbOTPnXkdXX9qA4hRD8cYYwaABAtSYqCCpKg(XAhVGywGoTlGvOgbgURkpeousoM2NVaKTGslGOfKLTaIxq0lqN2fWkuJaPy4ejMtIK00lilBb60UawHAjy4UQ8q4qj5yAF(cIP8c0PDbSc1iWWDv5HWHsYX0(8fq0ckUaIxGoTlGvOwcgURkpeoCytgFbfxGoTlGvOwcgURkpeousoM2NVaKEbVVGywaABAtSYqCCpKg(XAhVGIlaTnTjwzioUhsd)yTJxqSlqN2fWkulbd3vLhchkjht7ZxaYwqPfKLTGOxGoTlGvOwcgURkpeoCytgFbfxaXlqN2fWkulbd3vLhcho8J1oEbi9cEFbXUa020MyLHyDoNqch3dPHFS2XlO4cqBtBIvgI15CcjCCpKg(XAhVGywqPcTGIlG4fOt7cyfQrGH7QYdHdLKJP95laPxW7li2fG2M2eRmeh3dPHFS2XlilBb60UawHAjy4UQ8q4WHFS2XlaPxW7li2fG2M2eRmeh3dPHFS2XlO4c0PDbSc1sWWDv5HWHsYX0(8fG0lisHwqblaTnTjwzioUhsd)yTJxqSlaTnTjwziwNZjKWX9qA4hRD8cYYwaABAtSYqCCpKg(XAhVGywGoTlGvOgbgURkpeousoM2NVaKTGslilBbOTPnXkdXX9qIe1ciAbzzlqN2fWkulbd3vLhcho8J1oEbi9cEFbXSa020MyLHyDoNqch3dPHFS2XlO4ciEb60UawHAey4UQ8q4qj5yAF(cq6f8(cIDbOTPnXkdX6CoHeoUhsd)yTJxqw2cIEb60UawHAeifdNiXCsKKMEbfxaXlaTnTjwzioUhsd)yTJxqmlqN2fWkuJad3vLhchkjht7ZxaYwqPfKLTa020MyLH44EirIAbeTaIwarlGOfq0ciAbzzlqTHaRqTF4KEjzZli2fG2M2eRmeh3dPHFS2XlGOfKLTGOxGoTlGvOgbsXWjsmNejPPxqXfe9cchA2nxHcIpT5lO4ciEb60UawHAjifdNiXCsKKMEbfxaXlG4fe9cqBtBIvgIJ7HejQfKLTaDAxaRqTemCxvEiC4Wpw74feZcEFbeTGIlG4fG2M2eRmeh3dPHFS2XliMfuQqlilBb60UawHAjy4UQ8q4WHFS2XlaPxW7liMfG2M2eRmeh3dPHFS2XlGOfq0cYYwq0lqN2fWkulbPy4ejMtIK00lO4ciEbrVaDAxaRqTeKIHtH7QYdHVGSSfOt7cyfQLGH7QYdHdh(XAhVGSSfOt7cyfQLGH7QYdHdLKJP95liMYlqN2fWkuJad3vLhchkjht7ZxarlGOFoUEk(NRt7cynYx)Vgv)V9Zz3eRS8J8FUf0(8FUoTlG1s)8W0kpT9ZjEb60UawHAjifdNiXCsKKMEbzzliCOz3Cfki(0MVGIlqN2fWkulbPy4u4UQ8q4lGOfuCbeVa020MyLHyDoNqch3djsulO4ciEbrVGWHMDZvOG4tB(ckUGOxGoTlGvOgbsXWjsmNejPPxqw2cchA2nxHcIpT5lO4cIEb60UawHAeifdNc3vLhcFbzzlqN2fWkuJad3vLhcho8J1oEbzzlqN2fWkulbPy4ejMtIK00lO4ciEbrVaDAxaRqncKIHtKyojsstVGSSfOt7cyfQLGH7QYdHdLKJP95liMYlqN2fWkuJad3vLhchkjht7ZxarlilBb60UawHAjifdNc3vLhcFbfxq0lqN2fWkuJaPy4ejMtIK00lO4c0PDbSc1sWWDv5HWHsYX0(8fet5fOt7cyfQrGH7QYdHdLKJP95lGOfKLTGOxaABAtSYqSoNtiHJ7HejQfuCbeVGOxGoTlGvOgbsXWjsmNejPPxqXfq8c0PDbSc1sWWDv5HWHsYX0(8fG0l49fe7cqBtBIvgIJ7H0Wpw74fKLTa020MyLH44Ein8J1oEbXSaDAxaRqTemCxvEiCOKCmTpFbiBbLwarlilBb60UawHAeifdNiXCsKKMEbfxaXlqN2fWkulbPy4ejMtIK00lO4c0PDbSc1sWWDv5HWHsYX0(8fet5fOt7cyfQrGH7QYdHdLKJP95lO4ciEb60UawHAjy4UQ8q4qj5yAF(cq6f8(cIDbOTPnXkdXX9qA4hRD8cYYwaABAtSYqCCpKg(XAhVGywGoTlGvOwcgURkpeousoM2NVaKTGslGOfKLTaIxq0lqN2fWkulbPy4ejMtIK00lilBb60UawHAey4UQ8q4qj5yAF(cIP8c0PDbSc1sWWDv5HWHsYX0(8fq0ckUaIxGoTlGvOgbgURkpeoCytgFbfxGoTlGvOgbgURkpeousoM2NVaKEbVVGywaABAtSYqCCpKg(XAhVGIlaTnTjwzioUhsd)yTJxqSlqN2fWkuJad3vLhchkjht7ZxaYwqPfKLTGOxGoTlGvOgbgURkpeoCytgFbfxaXlqN2fWkuJad3vLhcho8J1oEbi9cEFbXUa020MyLHyDoNqch3dPHFS2XlO4cqBtBIvgI15CcjCCpKg(XAhVGywqPcTGIlG4fOt7cyfQLGH7QYdHdLKJP95laPxW7li2fG2M2eRmeh3dPHFS2XlilBb60UawHAey4UQ8q4WHFS2XlaPxW7li2fG2M2eRmeh3dPHFS2XlO4c0PDbSc1iWWDv5HWHsYX0(8fG0lisHwqblaTnTjwzioUhsd)yTJxqSlaTnTjwziwNZjKWX9qA4hRD8cYYwaABAtSYqCCpKg(XAhVGywGoTlGvOwcgURkpeousoM2NVaKTGslilBbOTPnXkdXX9qIe1ciAbzzlqN2fWkuJad3vLhcho8J1oEbi9cEFbXSa020MyLHyDoNqch3dPHFS2XlO4ciEb60UawHAjy4UQ8q4qj5yAF(cq6f8(cIDbOTPnXkdX6CoHeoUhsd)yTJxqw2cIEb60UawHAjifdNiXCsKKMEbfxaXlaTnTjwzioUhsd)yTJxqmlqN2fWkulbd3vLhchkjht7ZxaYwqPfKLTa020MyLH44EirIAbeTaIwarlGOfq0ciAbzzlqTHaRqTF4KEjzZli2fG2M2eRmeh3dPHFS2XlGOfKLTGOxGoTlGvOwcsXWjsmNejPPxqXfe9cchA2nxHcIpT5lO4ciEb60UawHAeifdNiXCsKKMEbfxaXlG4fe9cqBtBIvgIJ7HejQfKLTaDAxaRqncmCxvEiC4Wpw74feZcEFbeTGIlG4fG2M2eRmeh3dPHFS2XliMfuQqlilBb60UawHAey4UQ8q4WHFS2XlaPxW7liMfG2M2eRmeh3dPHFS2XlGOfq0cYYwq0lqN2fWkuJaPy4ejMtIK00lO4ciEbrVaDAxaRqncKIHtH7QYdHVGSSfOt7cyfQrGH7QYdHdh(XAhVGSSfOt7cyfQrGH7QYdHdLKJP95liMYlqN2fWkulbd3vLhchkjht7ZxarlGOFoUEk(NRt7cyT0x)6x)5O5b3N)FTuHkfPqr1iu9phHnE7eW)8xEHr4)vQSxlCuXcwWBu4f0pOUrxa9nlGAudhUhrtPEbdtLi7HLlaFp8cms9EmLLliqXCcmgUc9I25f8ovSaK6C08OSCbupKotFdbggfQxGElG6H0z6BiWWOaz3eRSK6fy6ckSr9xSaIJimIGRqVODEbVtflaPohnpklxa1dPZ03qGHrH6fO3cOEiDM(gcmmkq2nXklPEbehryebxHEr78cEjQybi15O5rz5cOwTk7kmkuVa9wa1QvzxHrbYUjwzj1lG4icJi4k0lANxWlrflaPohnpklxa1dPZ03qGHrH6fO3cOEiDM(gcmmkq2nXklPEbMUGcBu)flG4icJi4k0k0lVWi8)kv2RfoQybl4nk8c6hu3OlG(MfqToTlGvm1lyyQezpSCb47HxGrQ3JPSCbbkMtGXWvOx0oVGxIkwasDoAEuwUG8(bPwaoURMWwqHFb6TGxqAlq2OBCF(cou8y6nlGyKr0ci(DHreCf6fTZl4LOIfGuNJMhLLlGADAxaRWiWOq9c0BbuRt7cyfQrGrH6fqCPicJi4k0lANxWlrflaPohnpklxa160UawHLGrH6fO3cOwN2fWkulbJc1lG4sVKWicUc9I25fevPIfGuNJMhLLliVFqQfGJ7QjSfu4xGEl4fK2cKn6g3NVGdfpMEZcigzeTaIFxyebxHEr78cIQuXcqQZrZJYYfqToTlGvyeyuOEb6TaQ1PDbSc1iWOq9ciU0ljmIGRqVODEbrvQybi15O5rz5cOwN2fWkSemkuVa9wa160UawHAjyuOEbexkIWicUcTc9Ylmc)VsL9AHJkwWcEJcVG(b1n6cOVzbuhKyQxWWujYEy5cW3dVaJuVhtz5ccumNaJHRqVODEbunvSaK6C08OSCbuRwLDfgfQxGElGA1QSRWOaz3eRSK6fqCeHreCf6fTZlGQqflaPohnpklxa1QvzxHrH6fO3cOwTk7kmkq2nXklPEbehryebxHwHE5fgH)xPYETWrflybVrHxq)G6gDb03SaQXk1lyyQezpSCb47HxGrQ3JPSCbbkMtGXWvOx0oVGsuXcqQZrZJYYfq9q6m9neyyuOEb6TaQhsNPVHadJcKDtSYsQxGPlOWg1FXcioIWicUc9I25fuIkwasDoAEuwUaQrXkmkWOsies9c0BbuhvcHqQxaXLegrWvOx0oVaQMkwasDoAEuwUaQhsNPVHadJc1lqVfq9q6m9neyyuGSBIvws9cioIWicUc9I25fqvOIfGuNJMhLLlG6H0z6BiWWOq9c0BbupKotFdbggfi7MyLLuVatxqHnQ)IfqCeHreCf6fTZlGQsflaPohnpklxa1QvzxHrH6fO3cOwTk7kmkq2nXklPEbehryebxHEr78cIuiQybi15O5rz5cOwTk7kmkuVa9wa1QvzxHrbYUjwzj1lG4icJi4k0lANxqPcrflaPohnpklxa1dPZ03qGHrH6fO3cOEiDM(gcmmkq2nXklPEbehryebxHEr78ckfHkwasDoAEuwUaQdNljBfgfQxGElG6W5sYwHrbYUjwzj1lW0fuyJ6VybehryebxHEr78ckr1uXcqQZrZJYYfq9q6m9neyyuOEb6TaQhsNPVHadJcKDtSYsQxGPlOWg1FXcioIWicUc9I25fuIQPIfGuNJMhLLlG6H0z6BiWWOq9c0BbupKotFdbggfi7MyLLuVaIJimIGRqVODEbLOkuXcqQZrZJYYfq9q6m9neyyuOEb6TaQhsNPVHadJcKDtSYsQxGPlOWg1FXcioIWicUcTc9Ylmc)VsL9AHJkwWcEJcVG(b1n6cOVzbuhQSHMPEbdtLi7HLlaFp8cms9EmLLliqXCcmgUc9I25fuIkwasDoAEuwUaQhsNPVHadJc1lqVfq9q6m9neyyuGSBIvws9cmDbf2O(lwaXregrWvOx0oVGsuXcqQZrZJYYfqnkwHrbgvcHqQxGElG6Osies9ciUKWicUc9I25fq1uXcqQZrZJYYfqnkwHrbgvcHqQxGElG6Osies9cioIWicUc9I25fqvOIfGuNJMhLLlG6H0z6BiWWOq9c0BbupKotFdbggfi7MyLLuVaIJimIGRqVODEbVtflaPohnpklxa1dPZ03qGHrH6fO3cOEiDM(gcmmkq2nXklPEbMUGcBu)flG4icJi4k0lANxWlrflaPohnpklxa1dPZ03qGHrH6fO3cOEiDM(gcmmkq2nXklPEbehryebxHEr78cIQuXcqQZrZJYYfq9q6m9neyyuOEb6TaQhsNPVHadJcKDtSYsQxGPlOWg1FXcioIWicUc9I25fePquXcqQZrZJYYfqTAv2vyuOEb6TaQvRYUcJcKDtSYsQxGPlOWg1FXcioIWicUc9I25fuQquXcqQZrZJYYfqnkwHrbgvcHqQxGElG6Osies9cioIWicUc9I25fuIQqflaPohnpklxa1HZLKTcJc1lqVfqD4CjzRWOaz3eRSK6fy6ckSr9xSaIJimIGRqVODEbLEjQybi15O5rz5cOEiDM(gcmmkuVa9wa1dPZ03qGHrbYUjwzj1lW0fuyJ6VybehryebxHEr78ck9suXcqQZrZJYYfq9q6m9neyyuOEb6TaQhsNPVHadJcKDtSYsQxaXregrWvOx0oVGsrvQybi15O5rz5cOEiDM(gcmmkuVa9wa1dPZ03qGHrbYUjwzj1lW0fuyJ6VybehryebxHwHEJcVaQjXCQv(bt9cSG2NVaegEb(PlG(iD5cAFbkLgVG(b1nkCfIk7b1nklxWlTalO95lO2yfdxH(5OMJUR8p)L9YwaYzdRlq4fdR8eFbcVjDLNvOx2lBbcrwJVGiVJKfuQqLIScTczbTphdrnC4EenTmM8558ekwxHSG2NJHOgoCpIMwqzKjEQwzzIUAXzjI2jK0tyTVczbTphdrnC4EenTGYiJUYykHXO1vilO95yiQHd3JOPfugzKyo1k)Ge3E4YMWHPyJHt0NRPJoH6qWZkKf0(Cme1WH7r00ckJm1MKogkKGA4GH1K2pC5iW3rstxEiDM(gcmeFKv6BiWj(rKhCw2q6m9neyOZyC7eqytCCshdfQ2jKmuOSXus8kKf0(Cme1WH7r00ckJmrgRTvtigtPGeudhmSM0(Hlhb(osA6YrRwLDfIdSRPJojwVtwm6H0z6BiWq8rwPVHaN4hrEWRqVSfuyKu5KyfVaLcVaj5yAF(cmxUGWDv5HWxWrVGcdgfh0fC0lqPWl4L3v5cmxUaHVt)y1fqL5yT9GIxGy8fOu4fijht7ZxWrVaZxaPtXWklxqHdPeEwackSVaLchN6HxajMLla1WH7r0u4cqohmsmVGcdgfh0fC0lqPWl4L3v5cgwsgy8ckCiLWZceJVGsfQqpyKSaLsJxqJxqeivVamhoxIHRqwq7ZXqudhUhrtlOmYmmkoOPJoPu4eIUkrcQHdgwtA)WLJaPAK00LJ2eoEALHOM(XQP2XA7bfdz3eRSSy0mgZEGHmgZEGthDsPWj6lqIBNqQNgdFmQ8BksmtLiBuOyj0eomfBmCI(CnD0juhcEYYIMPsKnkuSegIhQNoN3HKy1WkrRqVSfuyKu5KyfVaLcVaj5yAF(cmxUGWDv5HWxWrVaKZyTT6cE5JPuwG5Yfi82eoEbh9ce(nc8ceJVaLcVaj5yAF(co6fy(ciDkgwz5ckCiLWZcqqH9fOu44up8ciXSCbOgoCpIMcxHSG2NJHOgoCpIMwqzKjYyTTAcXykfKGA4GH1K2pC5iW3rstx2eoEALHOM(XQP2XA7bfdz3eRSSy0mgZEGHmgZEGthDsPWj6lqIBNqQNgdFmQ8BksmtLiBuOyj0eomfBmCI(CnD0juhcEYYIMPsKnkuSegIhQNoN3HKy1WkrRqRqwq7ZXfugzHJ0vEsykNUc9YwqH7wGrHn5cmxUG3gZPsKDTfoEbVk8fPwa78tZyHxxacEbYZPwxG8wGsPXlG(MfGQAX5bVaroyKyEbTsTCbI8c07wagL98eFbMlxacEbbZPwxWWMSRXxWBJ5uPfGrXHMUdlqKKMgdxHSG2NJlOmY0XCQezxBHRDcjmLtrstxoA1gcScBCcv1IZZk0l7LTaHhUAXxaTfANWcIFKZcKhPOUasx76cIFKlGIHMxaksDbc)m(CtBNWckmZCiwG8q4izb3SGMEbkfEbH7QYdHVGgVa9UfupNWc0BbsUAXxaTfANWcIFKZceEosrfUaQm6f4NZl4OxGsHX8ccNlBTphVaB4fyIvEb6TGhwxaIwP0(cuk8cIuOfG5W5s8cQmJWIJKfOu4fG7NfqBbgVG4h5SaHNJuuxGrQ3JPDWQ14WvOx2lBbwq7ZXfugzoJG(iDzAy8vrZiPPlJpYQy7sOZiOpsxMggFv0CrIfjPPHdJp302jKSzoeqsuzzH7QYdHdhgFUPTtizZCiGd)yTJJjsHYYuBiWku7hoPxs2CSrEjIwHSG2NJlOmYcwTMSG2NNQnwrIBpCzDAxaRyK00LdhA2nxHcIpT5fd3vLhchAyuCqthDsPWjeDvch(XAhxmCxvEiC4W4ZnTDcjBMdbC4hRDCww0Hdn7MRqbXN28IH7QYdHdnmkoOPJoPu4eIUkHd)yTJxHSG2NJlOmYcwTMSG2NNQnwrIBpC5GeVczbTphxqzKfSAnzbTppvBSIe3E4YyfjnDzlOnAoXo)0mo2sRqwq7ZXfugzbRwtwq7Zt1gRiXThUCOYgAgjnDzlOnAoXo)0moMiRqRqwq7ZXWGex28aJ1XQPGvRiPPlhURkpeouKXAB1eIXukWHFS2XXq1fAfYcAFoggK4ckJm6EyX6DsK00Ld3vLhchkYyTTAcXykf4Wpw74yO6cTczbTphddsCbLrMipyEe0obK00LjwKKMgIORYegvpTIHKOYYIoCOz3Cf6nbkAI24IIK00qdJIdA6OtkfoHORsijQIIK00qrgRTvtigtPajrrurIPBcu00Wpw74yc3vLhchkYdMhbTtakjht7ZlqsoM2NNLrSAdbwHuyRQuGOcASu97zzrRwLDfkORvEsTJ12dkreLLjEyCr6Mafnn8J1oo2iu9kKf0(CmmiXfugzI17KjAYjosA6Yelsstdr0vzcJQNwXqsuzzrho0SBUc9MafnrBCrrsAAOHrXbnD0jLcNq0vjKevrrsAAOiJ12QjeJPuGKOiQiX0nbkAA4hRDCmH7QYdHdfR3jt0KtCOKCmTpVaj5yAFEwgXQneyfsHTQsbIkOXs1VNLfTAv2vOGUw5j1owBpOeruwM4HXfPBcu00Wpw74yJ8sRqwq7ZXWGexqzKvBcuuCIkNus4HDDfYcAFoggK4ckJmuN2NJKMUSijnn0WO4GMo6KsHti6QesIklJUjqrtd)yTJJT0lTcTczbTphddv2qZLnmkoOPJoPu4eIUkrstxo6XAzIrZUcnPedzH1yfNLnwltmA2vOjLy4Wpw74ykhPqzzwqB0CID(PzCmLhRLjgn7k0KsmmCKUg1kTczbTphddv2qZfugzI2iYYeMYPijepu5KAdbwXLJGKMUmkwHpw7qrsAAi9WUWfhsIQikwHpw7qrsAAi9WUWfho8J1oo2YecYSmrsAAiIUktyu90kgsIQyGIneyCIESG2NB1yIaPkfhsNPVHadPhJWd7koD0jLcN4QKNK5ALh8kKf0(CmmuzdnxqzK9qw1gt5uK00LjeKinkwHpw7qrsAAOiBynfQSHMHd)yTJJPqWsVVczbTphddv2qZfugzc6AnHPCksA6YdPZ03qGHOoYaL0rNgt4UjrpgHh2vCrrsAAiD1IZdo9yJaijQvilO95yyOYgAUGYiJUAXzzct5uK00LhsNPVHadrDKbkPJonMWDtIEmcpSR4vilO95yyOYgAUGYitTjPJHcjnD5H0z6BiWq8rwPVHaN4hrEWfvBs6yOGd)yTJJLqqwmCxvEiCiD1ggo8J1oowcb5kKf0(CmmuzdnxqzKrxTHrstxwTjPJHcsIQ4q6m9neyi(iR03qGt8Jip4vilO95yyOYgAUGYitYMsjfOycg7bjnDz6lqIliyynnmb2JL(cKy4JjSvilO95yyOYgAUGYidrxLjmQEAfJKMUC0J1YeJMDfAsjgYcRXkolBSwMy0SRqtkXWHFS2XXuosHYYSG2O5e78tZ4ykpwltmA2vOjLyy4iDnQvAfYcAFoggQSHMlOmYeTrKLjmLtrsiEOYj1gcSIlhbjnDzAYAnnCGIne4K2pCSecYIH7QYdHdfzS2wnHymLcC4hRDCww4UQ8q4qrgRTvtigtPah(XAhhBKsfqiilQwLDfIdSRPJojwVtUczbTphddv2qZfugzImwBRMqmMsbjnD5OhRLjgn7k0KsmKfwJvCw2yTmXOzxHMuIHd)yTJJP87zzwqB0CID(PzCmLhRLjgn7k0KsmmCKUg1kTczbTphddv2qZfugzdJp302jKSzoeiPPlh9yTmXOzxHMuIHSWASIZYgRLjgn7k0KsmC4hRDCmLFplZcAJMtSZpnJJP8yTmXOzxHMuIHHJ01OwPvilO95yyOYgAUGYidR2dkwYiPPllsstdnmkoOPJoPu4eIUkHKOYYepmUiDtGIMg(XAhhBK3xHSG2NJHHkBO5ckJmewxBNqYM5qSczbTphddv2qZfugz0vloltykNUczbTphddv2qZfugzc6AnHPC6kKf0(CmmuzdnxqzKfO0pgpwct50vilO95yyOYgAUGYitSENetHLRqwq7ZXWqLn0CbLrMLEihjpPJofMdbEfYcAFoggQSHMlOmYeTzmcmsA6YOyf(yTdfjPPH0d7cxC4Wpw74yyHXbsLtA)WRqwq7ZXWqLn0CbLrMGUwtH75XCjsA6Y0xGeht4WAbwq7ZHpKvTXuofgoSUczbTphddv2qZfugzIgH0rN0PdcWiPPllsstdfzS2wnHymLcuEi8SmXdJls3eOOPHFS2XX((kKf0(CmmuzdnxqzKj7HtISH1vilO95yyOYgAUGYit0grwMWuofjH4HkNuBiWkUCeK00LvBiWku7hoPxs2CSu1SSafBiW4e9ybTp3QXebwQy4CjzRqX6DYkRA7ewHSG2NJHHkBO5ckJSWjowct5uK00LPVajgQ9dN0l9yclwcbzuR0kKf0(CmmuzdnxqzKP2K0XqHKMU8q6m9neyi(iR03qGt8Jip4SSH0z6BiWqNX42jGWM44KogkuTtizOqzJPK4vilO95yyOYgAUGYiJEyw4ANqshdfsA6YdPZ03qGHoJXTtaHnXXjDmuOANqYqHYgtjXRqwq7ZXWqLn0CbLrMnbZ5KEZWUIKMUmX0xGexa9fiXWHjWEbuDHikw6lqIHpMWwHwHSG2NJHyTSHrXbnD0jLcNq0vjsA6YrpwltmA2vOjLyilSgR4SSOhRLjgn7k0KsmKevrIhRLjgn7k0KsmusoM2NxWyTmXOzxHMuIHThBPcLLr8yTmXOzxHMuIHHJ01Yrkgo0SBUcfeFAZjIOSSXAzIrZUcnPedjrvCSwMy0SRqtkXWHFS2XXeHQUczbTphdXAbLrMOnISmHPCksA6YOyf(yTdfjPPH0d7cxCijQIOyf(yTdfjPPH0d7cxC4Wpw74yltiiZYejPPHi6QmHr1tRyijQIbk2qGXj6XcAFUvJjcKQuCiDM(gcmKEmcpSR40rNukCIRsEsMRvEWRqwq7ZXqSwqzKP2K0XqHKMU8q6m9neyi(iR03qGt8Jip4IQnjDmuWHFS2XXsiilgURkpeoKUAddh(XAhhlHGCfYcAFogI1ckJm6QnmsQTZPGSCP3rstxwTjPJHcsIQ4q6m9neyi(iR03qGt8Jip4vilO95yiwlOmYeR3jXuy5kKf0(CmeRfugzi6QmHr1tRyK00LJESwMy0SRqtkXqwynwXzzrpwltmA2vOjLyijQIJ1YeJMDfAsjgkjht7ZlySwMy0SRqtkXW2JTuHYYgRLjgn7k0KsmKevXXAzIrZUcnPedh(XAhhteQ6kKf0(CmeRfugz0vloltykNUczbTphdXAbLrMGUwtykNUczbTphdXAbLrgcRRTtizZCiqstxoCxvEiC4W4ZnTDcjBMdbC4hRDCSecYIehTAv2vilmu1d3O5eMYPzzIK00qX6DYkjwHKOikll6WHMDZvOG4tBEww4UQ8q4WHXNBA7es2mhc4Wpw74Sm1gcSc1(Ht6LKnh77Rqwq7ZXqSwqzKjAJiltykNIKMUC4UQ8q4qrgRTvtigtPah(XAhhBKsrTafBiW4e9ybTp3QfqiilQwLDfIdSRPJojwVtMLrtwRPHduSHaN0(HJLqqwmCxvEiCOiJ12QjeJPuGd)yTJZYuBiWku7hoPxs2CSu1vilO95yiwlOmYKSPusbkMGXEqstxM(cK4ccgwtdtG9yPVajg(ycBfYcAFogI1ckJmSApOyjJKMUSijnn0WO4GMo6KsHti6QesIkltTHaRqTF4KEjzZXg59vilO95yiwlOmYS0d5i5jD0PWCiWRqwq7ZXqSwqzKnm(CtBNqYM5qGKMUmXIK00qrgRTvtigtPajrLLP2qGvO2pCsVKS5yJuiIksC0J1YeJMDfAsjgYcRXkoll6XAzIrZUcnPedjrvK4XAzIrZUcnPedLKJP95fmwltmA2vOjLyy7XwQqzzJ1YeJMDfAsjggosxlhHOSSXAzIrZUcnPedjrvCSwMy0SRqtkXWHFS2XXeHQs0kKf0(CmeRfugzImwBRMqmMsbjnDzId3vLhchIORYegvpTIHd)yTJJjY7zzHdn7MRqbXN28IehURkpeoCy85M2oHKnZHao8J1oo23ZYc3vLhchom(CtBNqYM5qah(XAhhtPcruwMAdbwHA)Wj9sYMJnY7zzehD4qZU5k0Bcu0eTXfJoCOz3Cfki(0Mterfjo6XAzIrZUcnPedzH1yfNLf9yTmXOzxHMuIHKOks8yTmXOzxHMuIHsYX0(8cgRLjgn7k0KsmS9ylvOSSXAzIrZUcnPeddhPRLJquw2yTmXOzxHMuIHKOkowltmA2vOjLy4Wpw74yIqvjAfYcAFogI1ckJSaL(X4XsykNUczbTphdXAbLrMGUwtH75XC5kKf0(CmeRfugzIgH0rN0PdcWiPPllsstdfzS2wnHymLcuEi8SmXdJls3eOOPHFS2XX((kKf0(CmeRfugzYE4KiByDfYcAFogI1ckJSWjowct5uK00LjM(cKyKoCyTa6lqIHdtG9OgXH7QYdHdf01AkCppMlHd)yTJr6iefJf0(COGUwtH75XCjmCynllCxvEiCOGUwtH75XCjC4hRDCmrkGqqsuwgXIK00qrgRTvtigtPajrLLjsstdDgJBNacBIJt6yOq1oHKHcLnMsIHKOiQy0dPZ03qGHujdv1s8WsspHWM0nsEYYepmUiDtGIMg(XAhhlvVczbTphdXAbLrMOnISmHPCksA6YIK00qeDvMWO6PvmKevwwGIneyCIESG2NB1yIalvmCUKSvOy9ozLvTDcRqwq7ZXqSwqzKztWCoHISIzK00LfjPPHImwBRMqmMsbkpeEwM4HXfPBcu00Wpw74yFFfYcAFogI1ckJm1MKogkK00LhsNPVHadXhzL(gcCIFe5bNLnKotFdbg6mg3obe2ehN0XqHQDcjdfkBmLeVczbTphdXAbLrg9WSW1oHKogkK00LhsNPVHadDgJBNacBIJt6yOq1oHKHcLnMsIxHSG2NJHyTGYiZMG5CsVzyxrstxMy6lqIlG(cKy4WeyVGiVtuS0xGedFmHTcTczbTphd1PDbSIlJ2M2eRmsC7HlJJ7HejkKG2QKCzrsAA4W4ZnTDcjBMdbKevwMijnn0WO4GMo6KsHti6QesIAfYcAFogQt7cyfxqzKH2M2eRmsC7HlJ15CcjCCpKirHe0wLKlho0SBUcfeFAZlksstdhgFUPTtizZCiGKOkksstdnmkoOPJoPu4eIUkHKOYYIoCOz3Cfki(0MxuKKMgAyuCqthDsPWjeDvcjrTczbTphd1PDbSIlOmYqBtBIvgjU9WLX6CoHeoUhsd)yTJrYHQmM1MgjHZLT2NxoCOz3Cfki(0MJe0wLKlhURkpeoCy85M2oHKnZHao8J1oowHpH7QYdHdnmkoOPJoPu4eIUkHd)yTJrcARsYjUI5YH7QYdHdnmkoOPJoPu4eIUkHd)yTJrstxwKKMgAyuCqthDsPWjeDvcLhcFfYcAFogQt7cyfxqzKH2M2eRmsC7HlJ15CcjCCpKg(XAhJKdvzmRnnscNlBTpVC4qZU5kuq8PnhjOTkjxoCxvEiC4W4ZnTDcjBMdbC4hRDmsqBvsoXvmxoCxvEiCOHrXbnD0jLcNq0vjC4hRDmsA6YIK00qdJIdA6OtkfoHORsijQvilO95yOoTlGvCbLrgABAtSYiXThUmoUhsd)yTJrYHQmM1MgjHZLT2NxoCOz3Cfki(0MJe0wLKlhURkpeoCy85M2oHKnZHao8J1oogHpH7QYdHdnmkoOPJoPu4eIUkHd)yTJrcARsYjUI5YH7QYdHdnmkoOPJoPu4eIUkHd)yTJxHSG2NJH60UawXfugzKyo1k)GrcUEkUSoTlG1iiPPltSoTlGvyeifdNiXCsKKMollCOz3Cfki(0MxuN2fWkmcKIHtH7QYdHturIrBtBIvgI15CcjCCpKirvK4OdhA2nxHcIpT5fJwN2fWkSeKIHtKyojsstNLfo0SBUcfeFAZlgToTlGvyjifdNc3vLhcpltN2fWkSemCxvEiC4Wpw74SmDAxaRWiqkgorI5KijnDrIJwN2fWkSeKIHtKyojsstNLPt7cyfgbgURkpeousoM2NhtzDAxaRWsWWDv5HWHsYX0(CIYY0PDbScJaPy4u4UQ8q4fJwN2fWkSeKIHtKyojsstxuN2fWkmcmCxvEiCOKCmTppMY60UawHLGH7QYdHdLKJP95eLLfnABAtSYqSoNtiHJ7HejQIehToTlGvyjifdNiXCsKKMUiX60UawHrGH7QYdHdLKJP95i97XI2M2eRmeh3dPHFS2XzzOTPnXkdXX9qA4hRDCm60UawHrGH7QYdHdLKJP95f(seLLPt7cyfwcsXWjsmNejPPlsSoTlGvyeifdNiXCsKKMUOoTlGvyey4UQ8q4qj5yAFEmL1PDbSclbd3vLhchkjht7ZlsSoTlGvyey4UQ8q4qj5yAFos)ESOTPnXkdXX9qA4hRDCwgABAtSYqCCpKg(XAhhJoTlGvyey4UQ8q4qj5yAFEHVerzzehToTlGvyeifdNiXCsKKMoltN2fWkSemCxvEiCOKCmTppMY60UawHrGH7QYdHdLKJP95evKyDAxaRWsWWDv5HWHdBY4f1PDbSclbd3vLhchkjht7Zr63JbTnTjwzioUhsd)yTJlI2M2eRmeh3dPHFS2XXQt7cyfwcgURkpeousoM2Nx4lLLfToTlGvyjy4UQ8q4WHnz8IeRt7cyfwcgURkpeoC4hRDms)ESOTPnXkdX6CoHeoUhsd)yTJlI2M2eRmeRZ5es44Ein8J1ooMsfQiX60UawHrGH7QYdHdLKJP95i97XI2M2eRmeh3dPHFS2Xzz60UawHLGH7QYdHdh(XAhJ0VhlABAtSYqCCpKg(XAhxuN2fWkSemCxvEiCOKCmTphPJuOcqBtBIvgIJ7H0Wpw74yrBtBIvgI15CcjCCpKg(XAhNLH2M2eRmeh3dPHFS2XXOt7cyfgbgURkpeousoM2Nx4lLLH2M2eRmeh3djsueLLPt7cyfwcgURkpeoC4hRDms)EmOTPnXkdX6CoHeoUhsd)yTJlsSoTlGvyey4UQ8q4qj5yAFos)ESOTPnXkdX6CoHeoUhsd)yTJZYIwN2fWkmcKIHtKyojsstxKy020MyLH44Ein8J1oogDAxaRWiWWDv5HWHsYX0(8cFPSm020MyLH44EirIIiIiIiIikltTHaRqTF4KEjzZXI2M2eRmeh3dPHFS2XeLLfToTlGvyeifdNiXCsKKMUy0Hdn7MRqbXN28IeRt7cyfwcsXWjsmNejPPlsmXrJ2M2eRmeh3djsuzz60UawHLGH7QYdHdh(XAhhZ7evKy020MyLH44Ein8J1ooMsfkltN2fWkSemCxvEiC4Wpw7yK(9yqBtBIvgIJ7H0Wpw7yIikllADAxaRWsqkgorI5KijnDrIJwN2fWkSeKIHtH7QYdHNLPt7cyfwcgURkpeoC4hRDCwMoTlGvyjy4UQ8q4qj5yAFEmL1PDbScJad3vLhchkjht7ZjIOvilO95yOoTlGvCbLrgjMtTYpyKGRNIlRt7cyTesA6YeRt7cyfwcsXWjsmNejPPZYchA2nxHcIpT5f1PDbSclbPy4u4UQ8q4evKy020MyLHyDoNqch3djsufjo6WHMDZvOG4tBEXO1PDbScJaPy4ejMtIK00zzHdn7MRqbXN28IrRt7cyfgbsXWPWDv5HWZY0PDbScJad3vLhcho8J1ooltN2fWkSeKIHtKyojsstxK4O1PDbScJaPy4ejMtIK00zz60UawHLGH7QYdHdLKJP95XuwN2fWkmcmCxvEiCOKCmTpNOSmDAxaRWsqkgofURkpeEXO1PDbScJaPy4ejMtIK00f1PDbSclbd3vLhchkjht7ZJPSoTlGvyey4UQ8q4qj5yAForzzrJ2M2eRmeRZ5es44EirIQiXrRt7cyfgbsXWjsmNejPPlsSoTlGvyjy4UQ8q4qj5yAFos)ESOTPnXkdXX9qA4hRDCwgABAtSYqCCpKg(XAhhJoTlGvyjy4UQ8q4qj5yAFEHVerzz60UawHrGumCIeZjrsA6IeRt7cyfwcsXWjsmNejPPlQt7cyfwcgURkpeousoM2NhtzDAxaRWiWWDv5HWHsYX0(8IeRt7cyfwcgURkpeousoM2NJ0VhlABAtSYqCCpKg(XAhNLH2M2eRmeh3dPHFS2XXOt7cyfwcgURkpeousoM2Nx4lruwgXrRt7cyfwcsXWjsmNejPPZY0PDbScJad3vLhchkjht7ZJPSoTlGvyjy4UQ8q4qj5yAForfjwN2fWkmcmCxvEiC4WMmErDAxaRWiWWDv5HWHsYX0(CK(9yqBtBIvgIJ7H0Wpw74IOTPnXkdXX9qA4hRDCS60UawHrGH7QYdHdLKJP95f(szzrRt7cyfgbgURkpeoCytgViX60UawHrGH7QYdHdh(XAhJ0VhlABAtSYqSoNtiHJ7H0Wpw74IOTPnXkdX6CoHeoUhsd)yTJJPuHksSoTlGvyjy4UQ8q4qj5yAFos)ESOTPnXkdXX9qA4hRDCwMoTlGvyey4UQ8q4WHFS2Xi97XI2M2eRmeh3dPHFS2Xf1PDbScJad3vLhchkjht7Zr6ifQa020MyLH44Ein8J1oow020MyLHyDoNqch3dPHFS2XzzOTPnXkdXX9qA4hRDCm60UawHLGH7QYdHdLKJP95f(szzOTPnXkdXX9qIefrzz60UawHrGH7QYdHdh(XAhJ0VhdABAtSYqSoNtiHJ7H0Wpw74IeRt7cyfwcgURkpeousoM2NJ0VhlABAtSYqSoNtiHJ7H0Wpw74SSO1PDbSclbPy4ejMtIK00fjgTnTjwzioUhsd)yTJJrN2fWkSemCxvEiCOKCmTpVWxkldTnTjwzioUhsKOiIiIiIiIYYuBiWku7hoPxs2CSOTPnXkdXX9qA4hRDmrzzrRt7cyfwcsXWjsmNejPPlgD4qZU5kuq8PnViX60UawHrGumCIeZjrsA6IetC0OTPnXkdXX9qIevwMoTlGvyey4UQ8q4WHFS2XX8orfjgTnTjwzioUhsd)yTJJPuHYY0PDbScJad3vLhcho8J1ogPFpg020MyLH44Ein8J1oMiIYYIwN2fWkmcKIHtKyojsstxK4O1PDbScJaPy4u4UQ8q4zz60UawHrGH7QYdHdh(XAhNLPt7cyfgbgURkpeousoM2NhtzDAxaRWsWWDv5HWHsYX0(CIi6NJrXH)RLENQ)6x)Fa]] )

end
