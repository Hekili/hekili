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


    spec:RegisterPack( "Beast Mastery", 20210628, [[d0unBbqisipIeQSjeYNKQAuubNIk0QebjVIezwIi3sev7cPFPQKHjcCmrQLbHEMijttQs6AQk12GOW3qOknoPkHZjcI1jvPENiivZtK4EQk2hevheHkluQIhksQjkvj6IKOsFeHQAKquKojjQALqKzkIYnfbPStQi)KevmuikILIqv8usAQur9vsOmwekNfIIAVu1FvXGfoSIfJOhtQjlQlJAZQYNvvnAQ0Pbwnju1RHGzlLBRsTBL(TKHRsoUiOwoONd10jUoK2Ui03LkJNeLZtcwpeLMpc2pL9P9o7vZJWENqmbiMobide7fuetvcsiFNkVQOWf7vVgncZp7v35M9Q9WdwSiH2GfgQGx9AuOvt27SxfxOqn7vDf5c37V(6hiUOKuDD)fgCJ2gbuRgop5lm4w)LxLef0eLF9KE18iS3jetaIPtaYaXEbfXuLGeY3i6vhuXTGEvvWDQ9QUGCMxpPxnZyTxThEWIfj0gSWqfSazk6km0qcj0LTaXErswGycqmTxTbWc27SxnZVbTjEN9oL27SxD0cOwVQUqxHHhSBjEvEhYgN994fVti6D2RY7q24SVhV6OfqTEvboBcJcAaKfS)hSBjE1mJ1qWLaQ1Rs8llgxEYwmB2cNHZMWOGgazzlCczsQTGx(gW4KSOJTixBFXICzH4cWw8kOfxTrbgITGK1dkMTai9ZwqYwivzb(AUVvWIzZw0XwONTVybKNmOPGfodNnHTaFXAWdOTGe99WuVQgcegcgVQISqg4plua(C1gfyOx8oLkVZEvEhYgN994vhTaQ1RkqWIalP9QzgRHGlbuRxv5FwiUSfceSiWIfUd2IXIAtokMTGe99sYcScR2cGyrhqCTG4WxSwSOEwiUSfkgOLPwO8plKUYIbYwOR7lwa7VfVcAXybXHVyTyr9SqCzlumqlBbwHvNKfOy2cXLTalWA)zOf1MCumBb)ESwOwO8plM1IAtokMTGe99SaGTaYtwblirflMTexgAbwG1(ZqlQn5Oy2cs03ZIoqRzX0WLfKSfqEYkybPcwiUSfc4MTG4WxSwSOEwiUSfkgOLTqx3m2cYrJGf17zHUQwU62KSafZwaelaplex2cS7a5SfceSiWIf6QA5QBTOR2(IfGvy4JHSfDaX1cXLTa9sx3G93cIdFXAXI6zH4YwOyGw2cScRMAHY)SywlQn5Oy2cs03ZcDH2YwqYwGI5SfZMTalGwZcDDZwqoAeS4vqlglEOckKTG4WxSwSOEwiUSfkgOLtYcumBbqOwO8plgl2Atoj67zrTjhfZwaWwa5jRqswGIzlaIfGNfaXIUA7lwawHHpgYw0bexlUkHxbmnlQn5Oy2cs03dBHavaS)wiLfeh(I1If1ZcXLTqXaTSfyfwTff0cWZcXLTOexgAHablcSybaV9flM1IAtokMtYca2IXIT2KtI(EwuBYrXSfDaX1IXIwT)m0cDvTC1TjzrbTaG3(IfqEYkqTq5FwiUSfpWVRybaBXFb2FlKYcEZwqYVcYwOqHcTyzLjwqC4lwlwuplex2cfd0YjzHIhflwGLbkwGIb7VfceSiWc2cPS4EqGTaJczlexwbl(zXcumNPEvneimemEvbcweyHkPPUd(GI5dj67zbrw4GfKOVhDWxSwo17iU8Pd0Yu0lliYchSqrwiqWIalubrQ7GpOy(qI(EwqGGfceSiWcvqKQRQLRULc57bSyliqWcbcweyHkPP6QA5QBPzu4iGATa5FSqGGfbwOcIuDvTC1T0mkCeqTw4Ofeiybj67rh8fRLt9oIlF6aTmnxDRfezHdwiqWIalubrQ7GpOy(qI(EwqKfceSiWcvqKQRQLRULMrHJaQ1cK)XcbcweyHkPP6QA5QBPzu4iGATGileiyrGfQGivxvlxDlfY3dyXwKCl(2IuSqxvlxDlDWxSwo17iU8Pd0YuiFpGfBbrwORQLRULo4lwlN6Dex(0bAzkKVhWITa5wGycSGableiyrGfQKMQRQLRULMrHJaQ1IKBX3wKIf6QA5QBPd(I1YPEhXLpDGwMc57bSylC0cceSqg4plubCZhPozaBrkwORQLRULo4lwlN6Dex(0bAzkKVhWITWrliqWcfzHablcSqL0u3bFqX8He99SGilCWcbcweyHkisDh8bfZhs03ZcISWblirFp6GVyTCQ3rC5thOLP5QBTGableiyrGfQGivxvlxDlfY3dyXwGCl(2chTGilCWcDvTC1T0bFXA5uVJ4YNoqltH89awSfi3cetGfeiyHablcSqfeP6QA5QBPq(Eal2IKBX3wGCl0v1Yv3sh8fRLt9oIlF6aTmfY3dyXw4OfeiyHISqGGfbwOcIu3bFqX8He99SGilCWcfzHablcSqfePUd(ORQLRU1cceSqGGfbwOcIuDvTC1T0mkCeqTwG8pwiqWIalujnvxvlxDlnJchbuRfeiyHablcSqfeP6QA5QBPq(Eal2chTWrV4DQx9o7v5DiBC23JxvdbcdbJxvGGfbwOcIu3bFqX8He99SGilCWcs03Jo4lwlN6Dex(0bAzk6LfezHdwOileiyrGfQKM6o4dkMpKOVNfeiyHablcSqL0uDvTC1TuiFpGfBbbcwiqWIalubrQUQwU6wAgfocOwlq(hleiyrGfQKMQRQLRULMrHJaQ1chTGablirFp6GVyTCQ3rC5thOLP5QBTGilCWcbcweyHkPPUd(GI5dj67zbrwiqWIalujnvxvlxDlnJchbuRfi)JfceSiWcvqKQRQLRULMrHJaQ1cISqGGfbwOsAQUQwU6wkKVhWITi5w8TfPyHUQwU6w6GVyTCQ3rC5thOLPq(Eal2cISqxvlxDlDWxSwo17iU8Pd0YuiFpGfBbYTaXeybbcwiqWIalubrQUQwU6wAgfocOwlsUfFBrkwORQLRULo4lwlN6Dex(0bAzkKVhWITWrliqWczG)SqfWnFK6KbSfPyHUQwU6w6GVyTCQ3rC5thOLPq(Eal2chTGabluKfceSiWcvqK6o4dkMpKOVNfezHdwiqWIalujn1DWhumFirFpliYchSGe99Od(I1YPEhXLpDGwMMRU1cceSqGGfbwOsAQUQwU6wkKVhWITa5w8TfoAbrw4Gf6QA5QBPd(I1YPEhXLpDGwMc57bSylqUfiMaliqWcbcweyHkPP6QA5QBPq(Eal2IKBX3wGCl0v1Yv3sh8fRLt9oIlF6aTmfY3dyXw4OfeiyHISqGGfbwOsAQ7GpOy(qI(EwqKfoyHISqGGfbwOsAQ7Gp6QA5QBTGableiyrGfQKMQRQLRULMrHJaQ1cK)XcbcweyHkis1v1Yv3sZOWra1AbbcwiqWIalujnvxvlxDlfY3dyXw4Ofo6vhTaQ1RkqWIali6fVtF7D2RY7q24SVhV6OfqTEv90ANrlGApnaw8Qnawo7CZEvDg7fVtidVZEvEhYgN994v1qGWqW4vhTasKp8Y3agBrkwGOxD0cOwVQEATZOfqTNgalE1galNDUzVkw8I3jIxVZEvEhYgN994v1qGWqW4vhTasKp8Y3agBbYTiTxD0cOwVQEATZOfqTNgalE1galNDUzVQUXtISx8Ix9cY66MCeVZENs7D2RoAbuRxfJEFx75IfVkVdzJZ(E8I3je9o7vhTaQ1RswI04851gf4Chy)psPmW6v5DiBC23Jx8oLkVZEvEhYgN994v35M9QdYIDh4GpVALt9oxvhd9QJwa16vhKf7oWbFE1kN6DUQog6fVt9Q3zVkVdzJZ(E8Qxqwpy5iGB2RMM(TxD0cOwVQmWJaNlVQgcegcgVkeD5xb)zkUqBVc(Zh(MKHykVdzJZwqGGfq0LFf8NPlJXG9VBGkGpcCUUa7)zUUg4iOykVdzJZEX703EN9Q8oKno77XREbz9GLJaUzVAA63E1rlGA9QKmwat70bhX1RQHaHHGXRQilKPXRqXAELt9oKTQYuEhYgNTGiluKfq0LFf8NP4cT9k4pF4BsgIP8oKno7fVtidVZEvEhYgN994vVGSEWYra3SxnnnvE1mJ1qWLaQ1RsCzfpkwWwiUSfzu4iGATy2Sf6QA5QBTOEwqC4lwlwuplex2cfd0YwmB2cKjqW90Sq5xSawTGTGublex2ImkCeqTwuplM1c01DWcNTG4N6EPfDU8AH4Yk0hYwGI5Sfxqwx3KJqTOhwpOy2cIdFXAXI6zH4YwOyGw2ciNr1m2cIFQ7LwqQGfiMGeCJtYcXfGTaGTinnvwGzDTzm1RoAbuRxDWxSwo17iU8Pd0YEvneimemEvfzXGSmeim9ccUN2bSybSAbt5DiBC2cISqrwWymVAMYymVA(uVJ4YNxPrXG9)aGam9Eu8f0cISWbl4egfCDXz6GSy3bo4ZRw5uVZv1XqliqWcfzbNWOGRlot1kOBLaRfOpKTblw4Ox8or86D2RY7q24SVhV6fK1dwoc4M9QPPF7vZmwdbxcOwVkXLv8OybBH4YwKrHJaQ1IzZwORQLRU1I6zrpmwatZcfdoIRfZMTaz6GSSf1ZcIN5NTGublex2ImkCeqTwuplM1c01DWcNTG4N6EPfDU8AH4Yk0hYwGI5Sfxqwx3KJq9QJwa16vjzSaM2PdoIRxvdbcdbJxDqwgceMEbb3t7awSawTGP8oKnoBbrwOilymMxntzmMxnFQ3rC5ZR0OyW(FaqaMEpk(cAbrw4GfCcJcUU4mDqwS7ah85vRCQ35Q6yOfeiyHISGtyuW1fNPAf0TsG1c0hY2GflC0lEXRQZyVZENs7D2RY7q24SVhVQgcegcgVQUQwU6wkjJfW0oDWrCPq(Eal2cKBrQsGxD0cOwV6SAglWPD0tR5fVti6D2RY7q24SVhVQgcegcgVQUQwU6wkjJfW0oDWrCPq(Eal2cKBrQsGxD0cOwV6dazYwvzV4DkvEN9Q8oKno77XRQHaHHGXR6GfKOVhTd0Yh8facemf9YcceSqrwORe5DwHUGFx58g2cISGe99Od(I1YPEhXLpDGwMIEzbrwqI(EusglGPD6GJ4srVSWrliYchS4b(DLdKVhWITa5wORQLRULsYqmdraS)0mkCeqTwOKfzu4iGATGablCWczG)SqD5PjU0lTyrkwKQVTGabluKfY04vOiaAngEalwaRwO8oKnoBHJw4OfeiybzHXwqKfpWVRCG89awSfPyr6u5vhTaQ1RsYqmdraS)EX7uV6D2RY7q24SVhVQgcegcgVQdwqI(E0oqlFWxaiqWu0lliqWcfzHUsK3zf6c(DLZByliYcs03Jo4lwlN6Dex(0bAzk6Lfezbj67rjzSaM2PdoIlf9YchTGilCWIh43voq(Eal2cKBHUQwU6wkzRQ85HcvGMrHJaQ1cLSiJchbuRfeiyHdwid8NfQlpnXLEPflsXIu9TfeiyHISqMgVcfbqRXWdyXcy1cL3HSXzlC0chTGablilm2cIS4b(DLdKVhWITiflsJm8QJwa16vjBvLppuOcEX703EN9QJwa16vBGFxbFu8O5)BEfVkVdzJZ(E8I3jKH3zVkVdzJZ(E8QAiqyiy8QKOVhDWxSwo17iU8Pd0Yu0lliqWIh43voq(Eal2IuSarKHxD0cOwV6vjGA9Ix8QyX7S3P0EN9QJwa16vh8fRLt9oIlF6aTSxL3HSXzFpEX7eIEN9Q8oKno77XRQHaHHGXRsI(E0hKxKvbk6Lfezbj67rFqErwfOq(Eal2Iu(yXVo7vhTaQ1RsoqsoFWUL4fVtPY7SxL3HSXzFpEvneimemEvi6YVc(ZuCH2Ef8Np8njdXuEhYgNTGilKbEe4CrH89awSfPyXVoBbrwORQLRUL(AdKPq(Eal2IuS4xN9QJwa16vLbEe4C5fVt9Q3zVkVdzJZ(E8QJwa16vFTbYEvneimemEvzGhboxu0lliYci6YVc(ZuCH2Ef8Np8njdXuEhYgN9QnWYhD2RI43EX703EN9QJwa16vjBvLXUC2RY7q24SVhV4Dcz4D2RoAbuRxTd0Yh8faceSxL3HSXzFpEX7eXR3zV6OfqTE1xBuGZhSBjEvEhYgN994fVt9cVZE1rlGA9QiaATd2TeVkVdzJZ(E8I3PeI3zVkVdzJZ(E8QAiqyiy8Q6QA5QBPqgx7iG9)mqy1rH89awSfPyXVoBbrw4GfkYczA8kuwzxTcdsKpy3sO8oKnoBbbcwqI(EuYwv5gkwOOxw4OfeiyHISqxjY7ScfbfGGzTGabl0v1Yv3sHmU2ra7)zGWQJc57bSyliqWcYcJTGilEGFx5a57bSylsXIV9QJwa16v7gqdS)NbcRoV4DkDc8o7v5DiBC23JxvdbcdbJxvxvlxDlLKXcyANo4iUuiFpGfBrkwKgrlsOSq7oWFgFEWrlGANMfkzXVoBbrwitJxHI18kN6DiBvLP8oKnoBbbcw8qBTdK1Ud8Npc4MTifl(1zliYcDvTC1TusglGPD6GJ4sH89awSfeiyHmWFwOc4MpsDYa2IuSiH4vhTaQ1RsoqsoFWUL4fVtPt7D2RY7q24SVhVQgcegcgV6R0OyluYc9GLdK)51IuS4vAum9EuMxD0cOwVAMhX9ODheGZTx8oLgrVZEvEhYgN994v1qGWqW4vjrFp6GVyTCQ3rC5thOLPOxwqGGfKfgBbrw8a)UYbY3dyXwKIfP)2RoAbuRxflZ9fNzV4DkDQ8o7vhTaQ1RoNBuyMHN6D0WQd7v5DiBC23Jx8oLUx9o7v5DiBC23JxvdbcdbJxLe99OKmwat70bhXLIEzbbcwqwySfezXd87khiFpGfBrkwKobE1rlGA9Qqgx7iG9)mqy15fVtP)27SxL3HSXzFpEvneimemEvDvTC1T0oqlFWxaiqWuiFpGfBbYTi93wqGGf6krENvOiOaemRfezHdwORQLRULczCTJa2)ZaHvhfY3dyXwKIfFBbbcwORQLRULczCTJa2)ZaHvhfY3dyXwGClqmbw4OfeiyHmWFwOc4MpsDYa2IuSi93wqGGfoyHISqxjY7ScDb)UY5nSfezHISqxjY7ScfbfGGzTWrV6OfqTEvsglGPD6GJ46fVtPrgEN9QJwa16v1UG7HHZb7wIxL3HSXzFpEX7uAIxVZE1rlGA9QiaATJUUVNn7v5DiBC23Jx8oLUx4D2RY7q24SVhVQgcegcgVkj67rjzSaM2PdoIlnxDRfeiybzHXwqKfpWVRCG89awSfPyX3E1rlGA9QKZ)PEhbc0iG9I3P0jeVZE1rlGA9QzaKpK8GfVkVdzJZ(E8I3jetG3zVkVdzJZ(E8QAiqyiy8QoyXR0OylsUf6clwOKfVsJIPq(NxlsOSWbl0v1Yv3sra0AhDDFpBMc57bSylsUfPTWrlqUfJwa1sra0AhDDFpBMQlSybbcwORQLRULIaO1o66(E2mfY3dyXwGClsBHsw8RZw4OfeiyHdwqI(EusglGPD6GJ4srVSGablirFp6Yymy)7gOc4JaNRlW(FMRRbockMIEzHJwqKfkYci6YVc(Z0eEUAZHHCgDpDd8uWmdP8oKnoBbbcwqwySfezXd87khiFpGfBrkwKkV6OfqTEvDrcNd2TeV4DcX0EN9Q8oKno77XRQHaHHGXRsI(E0oqlFWxaiqWu0lliqWcT7a)z85bhTaQDAwGClstr0cISqxBgfiuYwv5glcy)P8oKno7vhTaQ1RsoqsoFWUL4fVtiIO3zVkVdzJZ(E8QAiqyiy8QKOVhLKXcyANo4iU0C1TwqGGfKfgBbrw8a)UYbY3dyXwKIfF7vhTaQ1Roq9S85cTHzV4DcXu5D2RY7q24SVhVQgcegcgVkeD5xb)zkUqBVc(Zh(MKHykVdzJZwqGGfq0LFf8NPlJXG9VBGkGpcCUUa7)zUUg4iOykVdzJZE1rlGA9QYapcCU8I3je7vVZEvEhYgN994v1qGWqW4vHOl)k4ptxgJb7F3avaFe4CDb2)ZCDnWrqXuEhYgN9QJwa16vFqMrwW(Fe4C5fVti(T3zVkVdzJZ(E8QAiqyiy8QoyXR0OyluYIxPrXui)ZRfkzr6VTWrlsXIxPrX07rzE1rlGA9QduplFKcc5v8Ix8Q6gpjYEN9oL27SxD0cOwV6GVyTCQ3rC5thOL9Q8oKno77XlENq07SxL3HSXzFpE1rlGA9QKdKKZhSBjEvneimemEvs03J(G8ISkqrVSGilirFp6dYlYQafY3dyXwKYhl(1zVQwbDJpYa)zb7DkTx8oLkVZEvEhYgN994v1qGWqW4v)1zlsUfKOVhLKhSC0nEsKPq(Eal2cKBrcOi(TxD0cOwV6nAtay3s8I3PE17SxL3HSXzFpEvneimemEvi6YVc(ZuCH2Ef8Np8njdXuEhYgNTGilKbEe4CrH89awSfPyXVoBbrwORQLRUL(AdKPq(Eal2IuS4xN9QJwa16vLbEe4C5fVtF7D2RY7q24SVhV6OfqTE1xBGSxvdbcdbJxvg4rGZff9YcISaIU8RG)mfxOTxb)5dFtYqmL3HSXzVAdS8rN9Qi(Tx8oHm8o7v5DiBC23JxvdbcdbJx9vAuSfkzHEWYbY)8Arkw8knkMEpkZRoAbuRxnZJ4E0UdcW52lENiE9o7vhTaQ1R2bA5d(cabc2RY7q24SVhV4DQx4D2RY7q24SVhV6OfqTEvYbsY5d2TeVQgcegcgV6dT1oqw7oWF(iGB2IuS4xNTGil0v1Yv3sjzSaM2PdoIlfY3dyXwqGGf6QA5QBPKmwat70bhXLc57bSylsXI0iAHsw8RZwqKfY04vOynVYPEhYwvzkVdzJZEvTc6gFKb(Zc27uAV4DkH4D2RoAbuRxLKXcyANo4iUEvEhYgN994fVtPtG3zV6OfqTEviJRDeW(FgiS68Q8oKno77XlENsN27SxL3HSXzFpEvneimemEvs03Jo4lwlN6Dex(0bAzk6LfeiybzHXwqKfpWVRCG89awSfPyr6V9QJwa16vXYCFXz2lENsJO3zV6OfqTE1Ub0a7)zGWQZRY7q24SVhV4DkDQ8o7vhTaQ1R(AJcC(GDlXRY7q24SVhV4DkDV6D2RoAbuRxfbqRDWUL4v5DiBC23Jx8oL(BVZE1rlGA9QAxW9WW5GDlXRY7q24SVhV4DknYW7SxD0cOwVkzRQm2LZEvEhYgN994fVtPjE9o7vhTaQ1RoNBuyMHN6D0WQd7v5DiBC23Jx8oLUx4D2RY7q24SVhVQgcegcgVkj67rFqErwfOq(Eal2cKBbRmwJk8ra3SxD0cOwVk5aHZp7fVtPtiEN9Q8oKno77XRQHaHHGXR(knk2cKBHUWIfkzXOfqT0B0MaWULq1fw8QJwa16vra0AhDDFpB2lENqmbEN9Q8oKno77XRQHaHHGXRsI(EusglGPD6GJ4sZv3AbbcwqwySfezXd87khiFpGfBrkw8TxD0cOwVk58FQ3rGancyV4DcX0EN9QJwa16vZaiFi5blEvEhYgN994fVtiIO3zVkVdzJZ(E8QJwa16vjhijNpy3s8QAiqyiy8QYa)zHkGB(i1jdylsXIeIfeiyH2DG)m(8GJwa1onlqUfPPiAbrwORnJcekzRQCJfbS)uEhYgN9QAf0n(id8NfS3P0EX7eIPY7SxL3HSXzFpEvneimemE1xPrXubCZhPo3JYSifl(1zlsOSarV6OfqTEvDrcNd2TeV4DcXE17SxL3HSXzFpEvneimemEvi6YVc(ZuCH2Ef8Np8njdXuEhYgNTGablGOl)k4ptxgJb7F3avaFe4CDb2)ZCDnWrqXuEhYgN9QJwa16vLbEe4C5fVti(T3zVkVdzJZ(E8QAiqyiy8Qq0LFf8NPlJXG9VBGkGpcCUUa7)zUUg4iOykVdzJZE1rlGA9QpiZily)pcCU8I3jergEN9Q8oKno77XRQHaHHGXR6GfVsJITqjlELgftH8pVwOKfPkbw4OfPyXR0Oy69OmV6OfqTE1bQNLpsbH8kEXlEXRMidXGA9oHycqmDc(obi6v7g4c2FSxvXioIhNuENi(92clC2LTaCFvqXIxbTOFMFdAt6BbKtyuaKZwGRB2IbvQ7r4SfA3z)zm1qkzGLTiv92IuxBImu4Sf9fiyrGfAAkX6BHuw0xGGfbwOsAkX6BHdidL5i1qkzGLTiv92IuxBImu4Sf9fiyrGfkIuI13cPSOVablcSqfePeRVfoKovkZrQHuYalBrV2BlsDTjYqHZw0xGGfbwOPPeRVfszrFbcweyHkPPeRVfoKovkZrQHuYalBrV2BlsDTjYqHZw0xGGfbwOisjwFlKYI(ceSiWcvqKsS(w4aYqzosnKmKumIJ4XjL3jIFVTWcNDzla3xfuS4vql6FbzDDtosFlGCcJcGC2cCDZwmOsDpcNTq7o7pJPgsjdSSf9AVTi11MidfoBrFi6YVc(ZuI13cPSOpeD5xb)zkXO8oKno33IrSq5QCsMfoKwzosnKsgyzl61EBrQRnrgkC2I(q0LFf8NPeRVfszrFi6YVc(ZuIr5DiBCUVfoKwzosnKsgyzl(U3wK6AtKHcNTOVmnEfkX6BHuw0xMgVcLyuEhYgN7BHdPvMJudPKbw2IV7TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(wmIfkxLtYSWH0kZrQHKHKIrCepoP8or87Tfw4SlBb4(QGIfVcArFDg33ciNWOaiNTax3SfdQu3JWzl0UZ(ZyQHuYalBrQ6TfPU2ezOWzl6ltJxHsS(wiLf9LPXRqjgL3HSX5(w4qAL5i1qkzGLTOx7TfPU2ezOWzl6ltJxHsS(wiLf9LPXRqjgL3HSX5(w4qAL5i1qYqsXioIhNuENi(92clC2LTaCFvqXIxbTOpw6BbKtyuaKZwGRB2IbvQ7r4SfA3z)zm1qkzGLTaXEBrQRnrgkC2I(xSqjgfzMsP9Tqkl6JmtP0(w4aIkZrQHuYalBrQ6TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(w4qAL5i1qkzGLTOx7TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(wmIfkxLtYSWH0kZrQHuYalBrcP3wK6AtKHcNTOVmnEfkX6BHuw0xMgVcLyuEhYgN7BHdPvMJudPKbw2I0jO3wK6AtKHcNTOVmnEfkX6BHuw0xMgVcLyuEhYgN7BHdPvMJudPKbw2cetqVTi11MidfoBrFi6YVc(ZuI13cPSOpeD5xb)zkXO8oKno33chsRmhPgsjdSSfiMU3wK6AtKHcNTOVU2mkqOeRVfszrFDTzuGqjgL3HSX5(wmIfkxLtYSWH0kZrQHuYalBbIPQ3wK6AtKHcNTOpeD5xb)zkX6BHuw0hIU8RG)mLyuEhYgN7BXiwOCvojZchsRmhPgsjdSSfiMQEBrQRnrgkC2I(q0LFf8NPeRVfszrFi6YVc(ZuIr5DiBCUVfoKwzosnKsgyzlqSx7TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(wmIfkxLtYSWH0kZrQHKHKIrCepoP8or87Tfw4SlBb4(QGIfVcArFDJNe5(wa5egfa5Sf46MTyqL6EeoBH2D2FgtnKsgyzlqS3wK6AtKHcNTO)fluIrrMPuAFlKYI(iZukTVfoGOYCKAiLmWYwKQEBrQRnrgkC2I(xSqjgfzMsP9Tqkl6JmtP0(w4qAL5i1qkzGLTOx7TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(w4qAL5i1qkzGLT47EBrQRnrgkC2I(q0LFf8NPeRVfszrFi6YVc(ZuIr5DiBCUVfJyHYv5KmlCiTYCKAiLmWYw0l6TfPU2ezOWzl6ltJxHsS(wiLf9LPXRqjgL3HSX5(wmIfkxLtYSWH0kZrQHuYalBr6ErVTi11MidfoBr)lwOeJImtP0(wiLf9rMPuAFlCiTYCKAiLmWYwGiI92IuxBImu4Sf911MrbcLy9Tqkl6RRnJcekXO8oKno33IrSq5QCsMfoKwzosnKsgyzlqSx7TfPU2ezOWzl6drx(vWFMsS(wiLf9HOl)k4ptjgL3HSX5(wmIfkxLtYSWH0kZrQHuYalBbI9AVTi11MidfoBrFi6YVc(ZuI13cPSOpeD5xb)zkXO8oKno33chsRmhPgsjdSSfi(DVTi11MidfoBrFi6YVc(ZuI13cPSOpeD5xb)zkXO8oKno33IrSq5QCsMfoKwzosnKmKC2LTOpkMpaHVX9Ty0cOwl6gSfBjw8k0nBbyTqCbyla3xfuOgsk)9vbfoBX3wmAbuRfnawWudjVk(I1ENq87u5vVG1d0yVQItXzrp8GflsOnyHHkybYu0vyOHKItXzbsOlBbI9IKSaXeGyAdjdPrlGAX0liRRBYr(GrVVR9CXIH0OfqTy6fK11n5ik95lYsKgNpV2OaN7a7)rkLbwdPrlGAX0liRRBYru6ZxOy(ae(oPDU5pdYIDh4GpVALt9oxvhdnKgTaQftVGSUUjhrPpFjd8iW5kPliRhSCeWn)jn97KaVpq0LFf8NP4cT9k4pF4BsgIjqaIU8RG)mDzmgS)Ddub8rGZ1fy)pZ11ahbfBinAbulMEbzDDtoIsF(IKXcyANo4iUjDbz9GLJaU5pPPFNe49rrY04vOynVYPEhYwvzIueeD5xb)zkUqBVc(Zh(MKHydjfNfexwXJIfSfIlBrgfocOwlMnBHUQwU6wlQNfeh(I1If1ZcXLTqXaTSfZMTazceCpnlu(flGvlylivWcXLTiJchbuRf1ZIzTaDDhSWzli(PUxArNlVwiUSc9HSfOyoBXfK11n5iul6H1dkMTG4WxSwSOEwiUSfkgOLTaYzunJTG4N6EPfKkybIjib34KSqCbylaylsttLfywxBgtnKgTaQftVGSUUjhrPpFn4lwlN6Dex(0bA5KUGSEWYra38N00uLe49rrdYYqGW0li4EAhWIfWQfmL3HSXzIueJX8QzkJX8Q5t9oIlFELgfd2)dacW07rXxqICGtyuW1fNPdYIDh4GpVALt9oxvhdjqqrCcJcUU4mvRGUvcSwG(q2gS4OHKIZcIlR4rXc2cXLTiJchbuRfZMTqxvlxDRf1ZIEySaMMfkgCexlMnBbY0bzzlQNfepZpBbPcwiUSfzu4iGATOEwmRfOR7GfoBbXp19sl6C51cXLvOpKTafZzlUGSUUjhHAinAbulMEbzDDtoIsF(IKXcyANo4iUjDbz9GLJaU5pPPFNe49zqwgceMEbb3t7awSawTGP8oKnotKIymMxntzmMxnFQ3rC5ZR0OyW(FaqaMEpk(csKdCcJcUU4mDqwS7ah85vRCQ35Q6yibckItyuW1fNPAf0TsG1c0hY2GfhnKmKgTaQfR0NV0f6km8GDlXqsXzbXVSyC5jBXSzlCgoBcJcAaKLTWjKjP2cE5BaJtOBrhBrU2(If5YcXfGT4vqlUAJcmeBbjRhumBbq6NTGKTqQYc81CFRGfZMTOJTqpBFXcipzqtblCgoBcBb(I1GhqBbj67HPgsJwa1Iv6ZxcC2egf0aily)py3ssc8(OizG)Sqb4ZvBuGHgskofNf9sUnkyXB0G93cfkuOf5cLuSaDfqZcfkulCNezlUqfliEyCTJa2FlioiS6SixDBswuqlaplex2cDvTC1TwaWwivzrR2FlKYIm3gfS4nAW(BHcfk0IEzHskulu(NfBTSf1ZcXLXSf6AZabul2IbYwmKn2cPS4Mfl6aIlyTqCzlsNalWSU2m2IgZDJcjzH4YwGb3w8gnJTqHcfArVSqjflguPUhbONwtbQHKItXzXOfqTyL(81YDVcDZhiJRwICsG3hCH2ibBMUC3Rq38bY4QLitKdKOVhfY4AhbS)NbcRok6fbc6QA5QBPqgx7iG9)mqy1rH89awmYtNaceKb(Zcva38rQtgWPKgz4OHKIZcL)zH4YwiqWIalw4oylglQn5Oy2cs03ljlWkSAlaIfDaX1cIdFXAXI6zH4YwOyGwMAHY)Sq6klgiBHUUVybS)w8kOfJfeh(I1If1ZcXLTqXaTSfyfwDswGIzlex2cSaR9NHwuBYrXSf87XAHAHY)SywlQn5Oy2cs03Zca2cipzfSGevSy2sCzOfybw7pdTO2KJIzlirFpl6aTMftdxwqYwa5jRGfKkyH4YwiGB2cIdFXAXI6zH4YwOyGw2cDDZylihncwuVNf6QA5QBtYcumBbqSa8SqCzlWUdKZwiqWIalwORQLRU1IUA7lwawHHpgYw0bexlex2c0lDDd2Flio8fRflQNfIlBHIbAzlWkSAQfk)ZIzTO2KJIzlirFpl0fAlBbjBbkMZwmB2cSaAnl01nBb5OrWIxbTyS4HkOq2cIdFXAXI6zH4YwOyGwojlqXSfaHAHY)SySyRn5KOVNf1MCumBbaBbKNScjzbkMTaiwaEwael6QTVybyfg(yiBrhqCT4QeEfW0SO2KJIzlirFpSfcubW(BHuwqC4lwlwuplex2cfd0YwGvy1wuqlaplex2IsCzOfceSiWIfa82xSywlQn5Oyojlaylgl2Atoj67zrTjhfZw0bexlglA1(Zql0v1Yv3MKff0caE7lwa5jRa1cL)zH4Yw8a)UIfaSf)fy)Tqkl4nBbj)kiBHcfk0ILvMybXHVyTyr9SqCzlumqlNKfkEuSybwgOybkgS)wiqWIalylKYI7bb2cmkKTqCzfS4NflqXCMAinAbulwPpFjqWIalPtc8(iqWIal00u3bFqX8He99iYbs03Jo4lwlN6Dex(0bAzk6froOibcweyHIi1DWhumFirFpceeiyrGfkIuDvTC1TuiFpGftGGablcSqtt1v1Yv3sZOWra1I8pceSiWcfrQUQwU6wAgfocOwhjqGe99Od(I1YPEhXLpDGwMMRULiheiyrGfkIu3bFqX8He99isGGfbwOis1v1Yv3sZOWra1I8pceSiWcnnvxvlxDlnJchbulrceSiWcfrQUQwU6wkKVhWIt(3PORQLRULo4lwlN6Dex(0bAzkKVhWIjsxvlxDlDWxSwo17iU8Pd0YuiFpGfJCetabcceSiWcnnvxvlxDlnJchbuBY)ofDvTC1T0bFXA5uVJ4YNoqltH89awSJeiid8NfQaU5JuNmGtrxvlxDlDWxSwo17iU8Pd0YuiFpGf7ibcksGGfbwOPPUd(GI5dj67rKdceSiWcfrQ7GpOy(qI(Ee5aj67rh8fRLt9oIlF6aTmnxDlbcceSiWcfrQUQwU6wkKVhWIr(3osKd6QA5QBPd(I1YPEhXLpDGwMc57bSyKJyciqqGGfbwOis1v1Yv3sH89awCY)g56QA5QBPd(I1YPEhXLpDGwMc57bSyhjqqrceSiWcfrQ7GpOy(qI(Ee5GIeiyrGfkIu3bF0v1Yv3sGGablcSqrKQRQLRULMrHJaQf5FeiyrGfAAQUQwU6wAgfocOwceeiyrGfkIuDvTC1TuiFpGf7OJgsJwa1Iv6ZxceSiWcIjbEFeiyrGfkIu3bFqX8He99iYbs03Jo4lwlN6Dex(0bAzk6froOibcweyHMM6o4dkMpKOVhbcceSiWcnnvxvlxDlfY3dyXeiiqWIalueP6QA5QBPzu4iGAr(hbcweyHMMQRQLRULMrHJaQ1rceirFp6GVyTCQ3rC5thOLP5QBjYbbcweyHMM6o4dkMpKOVhrceSiWcnnvxvlxDlnJchbulY)iqWIalueP6QA5QBPzu4iGAjsGGfbwOPP6QA5QBPq(Ealo5FNIUQwU6w6GVyTCQ3rC5thOLPq(EalMiDvTC1T0bFXA5uVJ4YNoqltH89awmYrmbeiiqWIalueP6QA5QBPzu4iGAt(3PORQLRULo4lwlN6Dex(0bAzkKVhWIDKabzG)SqfWnFK6KbCk6QA5QBPd(I1YPEhXLpDGwMc57bSyhjqqrceSiWcfrQ7GpOy(qI(Ee5GablcSqttDh8bfZhs03JihirFp6GVyTCQ3rC5thOLP5QBjqqGGfbwOPP6QA5QBPq(Ealg5F7iroORQLRULo4lwlN6Dex(0bAzkKVhWIroIjGabbcweyHMMQRQLRULc57bS4K)nY1v1Yv3sh8fRLt9oIlF6aTmfY3dyXosGGIeiyrGfAAQ7GpOy(qI(Ee5GIeiyrGfAAQ7Gp6QA5QBjqqGGfbwOPP6QA5QBPzu4iGAr(hbcweyHIivxvlxDlnJchbulbcceSiWcnnvxvlxDlfY3dyXo6OH0OfqTyL(8LEATZOfqTNgaljTZn)rNXgsJwa1Iv6Zx6P1oJwa1EAaSK0o38hSKe49z0cir(WlFdyCkiAinAbulwPpFPNw7mAbu7PbWss7CZF0nEsKtc8(mAbKiF4LVbmg5PnKmKgTaQft1z8Nz1mwGt7ONwljW7JUQwU6wkjJfW0oDWrCPq(Ealg5PkbgsJwa1IP6mwPpF9aqMSvvojW7JUQwU6wkjJfW0oDWrCPq(Ealg5PkbgsJwa1IP6mwPpFrYqmdraS)jbEFCGe99ODGw(GVaqGGPOxeiOiDLiVZk0f87kN3WerI(E0bFXA5uVJ4YNoqltrViIe99OKmwat70bhXLIE5iro8a)UYbY3dyXixxvlxDlLKHygIay)Pzu4iGAvkJchbulbcoid8NfQlpnXLEPLus13eiOizA8kueaTgdpGflGvlo6ibcKfgt0d87khiFpGfNs6uzinAbulMQZyL(8fzRQ85HcvijW7JdKOVhTd0Yh8facemf9IabfPRe5DwHUGFx58gMis03Jo4lwlN6Dex(0bAzk6frKOVhLKXcyANo4iUu0lhjYHh43voq(Ealg56QA5QBPKTQYNhkubAgfocOwLYOWra1sGGdYa)zH6YttCPxAjLu9nbcksMgVcfbqRXWdyXcy1IJosGazHXe9a)UYbY3dyXPKgzyinAbulMQZyL(8vd87k4JIhn)FZRyinAbulMQZyL(81vjGAtc8(qI(E0bFXA5uVJ4YNoqltrViq4b(DLdKVhWItbrKHHKH0OfqTyQUXtI8NbFXA5uVJ4YNoqlBinAbulMQB8KiR0NVihijNpy3sssRGUXhzG)SG)KojW7Zfl07bSus03J(G8ISkqrVi6If69awkj67rFqErwfOq(EaloLp)6SH0OfqTyQUXtISsF(6gTjaSBjjbEF(15KFXc9EalLe99OK8GLJUXtImfY3dyXipbue)2qA0cOwmv34jrwPpFjd8iW5kjW7deD5xb)zkUqBVc(Zh(MKHyIKbEe4CrH89awCk)6mr6QA5QBPV2azkKVhWIt5xNnKgTaQft1nEsKv6ZxV2a5KAGLp68he)ojW7JmWJaNlk6frq0LFf8NP4cT9k4pF4BsgInKgTaQft1nEsKv6ZxzEe3J2Dqao3jbEFELgfRKEWYbY)8MYR0Oy69OmdPrlGAXuDJNezL(8vhOLp4laeiydPrlGAXuDJNezL(8f5aj58b7wssAf0n(id8Nf8N0jbEFEOT2bYA3b(ZhbCZP8RZePRQLRULsYybmTthCexkKVhWIjqqxvlxDlLKXcyANo4iUuiFpGfNsAev6xNjsMgVcfR5vo17q2QkBinAbulMQB8KiR0NVizSaM2PdoIRH0OfqTyQUXtISsF(cY4AhbS)NbcRodPrlGAXuDJNezL(8fwM7loZjbEFirFp6GVyTCQ3rC5thOLPOxeiqwymrpWVRCG89awCkP)2qA0cOwmv34jrwPpF1nGgy)pdewDgsJwa1IP6gpjYk95RxBuGZhSBjgsJwa1IP6gpjYk95leaT2b7wIH0OfqTyQUXtISsF(s7cUhgohSBjgsJwa1IP6gpjYk95lYwvzSlNnKgTaQft1nEsKv6ZxZ5gfMz4PEhnS6WgsJwa1IP6gpjYk95lYbcNFojW7Zfl07bSus03J(G8ISkqH89awmYzLXAuHpc4MnKgTaQft1nEsKv6ZxiaATJUUVNnNe495vAumY1fwuA0cOw6nAtay3sO6clgsJwa1IP6gpjYk95lY5)uVJabAeWjbEFirFpkjJfW0oDWrCP5QBjqGSWyIEGFx5a57bS4u(2qA0cOwmv34jrwPpFLbq(qYdwmKgTaQft1nEsKv6ZxKdKKZhSBjjPvq34JmWFwWFsNe49rg4plubCZhPozaNscHabT7a)z85bhTaQDAipnfrI01MrbcLSvvUXIa2FdPrlGAXuDJNezL(8LUiHZb7wssG3NxPrXubCZhPo3JYs5xNtOq0qA0cOwmv34jrwPpFjd8iW5kjW7deD5xb)zkUqBVc(Zh(MKHyceGOl)k4ptxgJb7F3avaFe4CDb2)ZCDnWrqXgsJwa1IP6gpjYk95RhKzKfS)hboxjbEFGOl)k4ptxgJb7F3avaFe4CDb2)ZCDnWrqXgsJwa1IP6gpjYk95RbQNLpsbH8kjbEFC4vAuSsVsJIPq(NxLsvcCmLxPrX07rzgsgsJwa1IPy5ZGVyTCQ3rC5thOLnKgTaQftXIsF(ICGKC(GDljjW7Zfl07bSus03J(G8ISkqrVi6If69awkj67rFqErwfOq(EaloLp)6SH0OfqTykwu6ZxYapcCUsc8(arx(vWFMIl02RG)8HVjziMizGhboxuiFpGfNYVotKUQwU6w6RnqMc57bS4u(1zdPrlGAXuSO0NVETbYj1alF05pi(DsG3hzGhboxu0lIGOl)k4ptXfA7vWF(W3KmeBinAbulMIfL(8fzRQm2LZgsJwa1IPyrPpF1bA5d(cabc2qA0cOwmflk95RxBuGZhSBjgsJwa1IPyrPpFHaO1oy3smKgTaQftXIsF(QBanW(FgiS6sc8(ORQLRULczCTJa2)ZaHvhfY3dyXP8RZe5GIKPXRqzLD1kmir(GDlHabs03Js2Qk3qXcf9YrceuKUsK3zfkckabZsGGUQwU6wkKX1ocy)pdewDuiFpGftGazHXe9a)UYbY3dyXP8TH0OfqTykwu6ZxKdKKZhSBjjbEF0v1Yv3sjzSaM2PdoIlfY3dyXPKgXekT7a)z85bhTaQDAk9RZejtJxHI18kN6DiBvLjq4H2AhiRDh4pFeWnNYVotKUQwU6wkjJfW0oDWrCPq(EalMabzG)SqfWnFK6KbCkjedPrlGAXuSO0NVY8iUhT7GaCUtc8(8knkwj9GLdK)5nLxPrX07rzgsJwa1IPyrPpFHL5(IZCsG3hs03Jo4lwlN6Dex(0bAzk6fbcKfgt0d87khiFpGfNs6VnKgTaQftXIsF(Ao3OWmdp17OHvh2qA0cOwmflk95liJRDeW(FgiS6sc8(qI(EusglGPD6GJ4srViqGSWyIEGFx5a57bS4usNadPrlGAXuSO0NVizSaM2PdoIBsG3hDvTC1T0oqlFWxaiqWuiFpGfJ80FtGGUsK3zfkckabZsKd6QA5QBPqgx7iG9)mqy1rH89awCkFtGGUQwU6wkKX1ocy)pdewDuiFpGfJCetGJeiid8NfQaU5JuNmGtj93ei4GI0vI8oRqxWVRCEdtKI0vI8oRqrqbiywhnKgTaQftXIsF(s7cUhgohSBjgsJwa1IPyrPpFHaO1o66(E2SH0OfqTykwu6ZxKZ)PEhbc0iGtc8(qI(EusglGPD6GJ4sZv3sGazHXe9a)UYbY3dyXP8TH0OfqTykwu6ZxzaKpK8GfdPrlGAXuSO0NV0fjCoy3ssc8(4WR0O4KRlSO0R0OykK)5nHYbDvTC1TueaT2rx33ZMPq(Ealo5PDe5Jwa1sra0AhDDFpBMQlSqGGUQwU6wkcGw7OR77zZuiFpGfJ80k9RZosGGdKOVhLKXcyANo4iUu0lceirFp6Yymy)7gOc4JaNRlW(FMRRbockMIE5irkcIU8RG)mnHNR2CyiNr3t3apfmZqceilmMOh43voq(EaloLuzinAbulMIfL(8f5aj58b7wssG3hs03J2bA5d(cabcMIErGG2DG)m(8GJwa1onKNMIir6AZOaHs2Qk3yra7VH0OfqTykwu6ZxduplFUqByojW7dj67rjzSaM2PdoIlnxDlbcKfgt0d87khiFpGfNY3gsJwa1IPyrPpFjd8iW5kjW7deD5xb)zkUqBVc(Zh(MKHyceGOl)k4ptxgJb7F3avaFe4CDb2)ZCDnWrqXgsJwa1IPyrPpF9GmJSG9)iW5kjW7deD5xb)z6Yymy)7gOc4JaNRlW(FMRRbock2qA0cOwmflk95RbQNLpsbH8kjbEFC4vAuSsVsJIPq(NxLs)TJP8knkMEpkZlEX7ba]] )

end
