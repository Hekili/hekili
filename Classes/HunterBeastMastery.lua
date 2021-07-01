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


    spec:RegisterPack( "Beast Mastery", 20210701, [[d8u4Xbqirv9iaf6sIQiBsu5tiLgfc1PqkwfHKQxjkAwkv1TKsPDb5xkvzysP4yc0YeLEgcjtdHuDnPuTnaj(gGcghcH6CieY6qi6DiKsAEIc3tPY(ae)Jqs4GIQGfcO6HaknresXfbKKpkQcnsesPojcbwjHyMasDtesj2PuIFciPgkHKOLsiP8ubnvPK(QOkQXsi1zjKK2Ru9xrgmOdt1Ij4XenzLCzuBgjFgbJgiNwXQriOxJunBHUTuSBk)wYWbQJdOOLRYZHA6KUoI2oH67amErv68cy9esmFLY(v19G9w7Hlx5ElzBt2GTbyOnbrTHiolrrueX9qnayUhc2L0DcCp08gUhcC2X6djAXXkFb6HG9aXYx9w7H4I8KCpeKQGXe5E7ryuqKciz1ShEAiJUoLjpNs3dpnY96HcKtujcSUqpC5k3BjBBYgSnadTjiQneXzjkIIO3dDsfuD9WWPby7HGM1ITUqpCXyzpe4SJ1hs0IJv(c8qI2KMY3lIiKXapm4(pmBBYgShghSI7T2dxmLtg1ER9wc2BTh6sDkRhklst5lHbvApKnxiYRoW7AVLS9w7HS5crE1bEp0L6uwpup3aMKtCeLXiKWGkThUyS8gW6uwpmpwp0bX(6HUTEyRNBatYjoIc)WwevcSpKnUzy8(pea)Wvz0QpCvpubn4hsv3dbh9a8HFOalDsm)WrPD9qb(HAvped2BAc8q3wpea)qPB0Qp8yFnXapS1ZnG5dXGz5qnYhkqsrHr9q5nkFJ3dZ)HQFeyfn4e4OhGVU2BHO6T2dzZfI8Qd8EO8gLVX7HYsmBUPi6bUXThM7HYQIRcGHCmywQPIkPG4eGjUqh34JHFyUhkRkUkag6yCzUogHKFxbaDCJpg(HBBpm)hklXS5MIOh4g3EyUhkRkUkagYXGzPMkQKcItaM4cDCJpgUh6sDkRhk9ym5sDklfhS2dJdwtM3W9q9gJoR4U2BHO3BThYMle5vh49qxQtz9qPhJjxQtzP4G1EyCWAY8gUhkx4U2BP9ER9q2CHiV6aVhkVr5B8EOl1rmNyJBgg)WmEy2EOl1PSEO0JXKl1PSuCWApmoynzEd3dXAx7Tau6T2dzZfI8Qd8EO8gLVX7HUuhXCInUzy8dbYdd2dDPoL1dLEmMCPoLLIdw7HXbRjZB4EOmYUyURDThc(yz1i4AV1Elb7T2dDPoL1dXKnnLLaZApKnxiYRoW7AVLS9w7HUuNY6HcLQrELOIEaEbymcjTY7y9q2CHiV6aVR9wiQER9qxQtz9qQiJbjpNs7HS5crE1bEx7Tq07T2dzZfI8Qd8EO5nCp0ffmi)CCIQmnvujWfa(6HUuNY6HUOGb5NJtuLPPIkbUaWxx7T0EV1EiBUqKxDG3dbFS0XAsNgUhge1Ep0L6uwpu9lPNdUhkVr5B8E4rAmvDeyeUiJu1rGtCJaFyeBUqKxpCB7HhPXu1rGrgJXJraGFbWj9CWGhJqYbd2pxjXi2CHiV6AVfGsV1EiBUqKxDG3dbFS0XAsNgUhge1Ep0L6uwpuGX64XeGZvq9q5nkFJ3dZ)HQhztryjBAQOscXQwi2CHiVEyUhM)dpsJPQJaJWfzKQocCIBe4dJyZfI8QR9wag6T2dzZfI8Qd8Ei4JLowt60W9WGiIQhUyS8gW6uwpmpSicjXk(Hki(HlYZ1PSh626HYQIRcG9WI6H5bmywQpSOEOcIFyEEIRh626HIkVPXJpKiWW6ysf)qHapubXpCrEUoL9WI6HU9qsdKJvE9W8iWs08qaGy7HkioaTh)qsmVEi4JLvJGROhcCw6Ky(H5bmywQpSOEOcIFyEEIRhE8IuY4hMhbwIMhke4HzBtBAW7)qf0GF4GFyqer9qmllBHr9qxQtz9qhdMLAQOskiobyIREO8gLVX7H5)qxu4Bugb(MgpMgdRJjvmInxiYRhM7H5)qgJztYigJztYPIkPG4evjjXJrin3GrnoryDpm3dj(HmWKCadMxixuWG8ZXjQY0urLaxa47HBBpm)hYatYbmyEHKbKXsVYgzsi6y9H001EleX9w7HS5crE1bEpe8XshRjDA4Eyqu79WfJL3awNY6H5HfrijwXpubXpCrEUoL9q3wpuwvCvaShwupe4mwhp(W885kOh626HeTDrHFyr9qrnNa)qHapubXpCrEUoL9WI6HU9qsdKJvE9W8iWs08qaGy7HkioaTh)qsmVEi4JLvJGROEOl1PSEOaJ1XJjaNRG6HYBu(gVh6IcFJYiW304X0yyDmPIrS5crE9WCpm)hYymBsgXymBsovujfeNOkjjEmcP5gmQXjcR7H5EiXpKbMKdyW8c5IcgKFoorvMMkQe4caFpCB7H5)qgysoGbZlKmGmw6v2itcrhRpKMU21EOmYUyU3AVLG9w7HUuNY6Hogml1urLuqCcWex9q2CHiV6aVR9wY2BThYMle5vh49qxQtz9qb)e4vcdQ0EO8gLVX7HcKuuiQJnrjaIe8dZ9qbskke1XMOeaDCJpg(HzS7HeKREOmGmYj1pcSI7TeSR9wiQER9q2CHiV6aVhkVr5B8Eib56HT9HcKuuib2XAsgzxmJoUXhd)qG8W2GY2Ep0L6uwpSHmQdguPDT3crV3ApKnxiYRoW7HYBu(gVhEKgtvhbgHlYivDe4e3iWhgXMle51dZ9q1VKEoy0Xn(y4hMXdjixpm3dLvfxfadrf9Jrh34JHFygpKGC1dDPoL1dv)s65G7AVL27T2dzZfI8Qd8EOl1PSEiv0pUhkVr5B8EO6xsphmIe8dZ9WJ0yQ6iWiCrgPQJaN4gb(Wi2CHiV6HXX4KC1dZ2Ex7Tau6T2dzZfI8Qd8EO8gLVX7HuLKe)WmFO0XA6ycS9WmEivjjXOgpV9qxQtz9Wf7kOKeKt)8MU2BbyO3Ap0L6uwpeWexjm45gf3dzZfI8Qd8U2BHiU3ApKnxiYRoW7HUuNY6Hc(jWReguP9q5nkFJ3dPiJX0Xsq(rGt60WpmJhsqUEyUhkRkUkagsGX64XeGZvqOJB8XWpCB7HYQIRcGHeySoEmb4Cfe64gFm8dZ4HbZ(WmFib56H5EO6r2uewYMMkQKqSQfInxiYREOmGmYj1pcSI7TeSR9wiI6T2dDPoL1dfySoEmb4CfupKnxiYRoW7AVLGTP3Ap0L6uwp8yCzUogHKFxbOhYMle5vh4DT3sWG9w7HS5crE1bEpuEJY349qbskkKJbZsnvujfeNamXfIe8d32EOqHXpm3dPgcG00Xn(y4hMXdd2Ep0L6uwpeREdyEXDT3sWS9w7HUuNY6Ha8jogHKFxbOhYMle5vh4DT3sqIQ3Ap0L6uwpKk6b4vcdQ0EiBUqKxDG31Elbj69w7HUuNY6H0NymHbvApKnxiYRoW7AVLGT3BTh6sDkRhkbnnoFEcdQ0EiBUqKxDG31Elbbk9w7HUuNY6HcXQwyq8QhYMle5vh4DT3sqGHER9qxQtz9qp1qEl(sfvsEfaCpKnxiYRoW7AVLGeX9w7HS5crE1bEpuEJY349qbskke1XMOeaDCJpg(Ha5HCEzjPYjDA4EOl1PSEOGFNtG7AVLGer9w7HS5crE1bEpuEJY349qQssIFiqEOSW6dZ8HUuNYqnKrDWGkfjlS2dDPoL1dPpXyswnnUT6AVLSTP3ApKnxiYRoW7HYBu(gVhkqsrHeySoEmb4CfeAvaShUT9qHcJFyUhsneaPPJB8XWpmJh2Ep0L6uwpuWjKkQKEJKoUR9wYgS3Ap0L6uwpCnhNeyhR9q2CHiV6aVR9wYMT3ApKnxiYRoW7HUuNY6Hc(jWReguP9q5nkFJ3dv)iWksNgoPvAn8dZ4HerpCB7Hsq(rGXjQZL6uMhFiqEyqu2hM7HYYwKJIeIvTISQJraXMle5vpugqg5K6hbwX9wc21ElzjQER9q2CHiV6aVhkVr5B8EivjjXiDA4KwPgpVpmJhsqUEOO(dZ2dDPoL1dLLW5jmOs7AVLSe9ER9q2CHiV6aVhkVr5B8E4rAmvDeyeUiJu1rGtCJaFyeBUqKxpCB7HhPXu1rGrgJXJraGFbWj9CWGhJqYbd2pxjXi2CHiV6HUuNY6HQFj9CWDT3s227T2dzZfI8Qd8EO8gLVX7HhPXu1rGrgJXJraGFbWj9CWGhJqYbd2pxjXi2CHiV6HUuNY6HuhZIYyes65G7AVLSaLER9q2CHiV6aVhkVr5B8EiXpKQKK4hM5dPkjjgDmb2EyMpKOAZdP5Hz8qQssIrnEE7HUuNY6H(jDJtADhBAx7ApuVXOZkU3AVLG9w7HS5crE1bEpSa3dXS2dDPoL1df734crUhk2JKCpuGKIcDmUmxhJqYVRaGib)WTThkqsrHCmywQPIkPG4eGjUqKG7HI9lzEd3dXbmzIeCx7TKT3ApKnxiYRoW7Hf4EiM1EOl1PSEOy)gxiY9qXEKK7HYsmBUPi6bUXThM7HcKuuOJXL56yes(Dfaej4hM7HcKuuihdMLAQOskiobyIlej4hUT9W8FOSeZMBkIEGBC7H5EOajffYXGzPMkQKcItaM4crcUhk2VK5nCpeRxzes4aMmrcUR9wiQER9q2CHiV6aVhwG7HywhQEOl1PSEOy)gxiY9qX(LmVH7Hy9kJqchWKPJB8XW9q5nkFJ3dfiPOqogml1urLuqCcWexOvbW6HI9ijN4iM7HYQIRcGHCmywQPIkPG4eGjUqh34JH7HI9ij3dLvfxfadDmUmxhJqYVRaGoUXhd)Wmev8qzvXvbWqogml1urLuqCcWexOJB8XWDT3crV3ApKnxiYRoW7Hf4EiM1HQh6sDkRhk2VXfICpuSFjZB4EiwVYiKWbmz64gFmCpuEJY349qbskkKJbZsnvujfeNamXfIeCpuShj5ehXCpuwvCvamKJbZsnvujfeNamXf64gFmCpuShj5EOSQ4QayOJXL56yes(Dfa0Xn(y4U2BP9ER9q2CHiV6aVhwG7HywhQEOl1PSEOy)gxiY9qX(LmVH7H4aMmDCJpgUhkVr5B8EOSeZMBkIEGBCRhk2JKCIJyUhkRkUkagYXGzPMkQKcItaM4cDCJpgUhk2JKCpuwvCvam0X4YCDmcj)Uca64gFm8dbIOIhkRkUkagYXGzPMkQKcItaM4cDCJpgUR9wak9w7HS5crE1bEp0L6uwpKeZPr5gCpuEJY349qIFOEJrNvKgebYXjsmNeiPOE422dLLy2Ctr0dCJBpm3d1Bm6SI0GiqoojRkUka2dP5H5EiXpuSFJlezewVYiKWbmzIe8dZ9qIFy(puwIzZnfrpWnU9WCpm)hQ3y0zfPzrGCCIeZjbskQhUT9qzjMn3ue9a342dZ9W8FOEJrNvKMfbYXjzvXvbWE422d1Bm6SI0SizvXvbWqh34JHF422d1Bm6SI0GiqoorI5Kajf1dZ9qIFy(puVXOZksZIa54ejMtcKuupCB7H6ngDwrAqKSQ4QayOf556u2dbYUhQ3y0zfPzrYQIRcGHwKNRtzpKMhUT9q9gJoRinicKJtYQIRcG9WCpm)hQ3y0zfPzrGCCIeZjbskQhM7H6ngDwrAqKSQ4QayOf556u2dbYUhQ3y0zfPzrYQIRcGHwKNRtzpKMhUT9W8FOy)gxiYiSELriHdyYej4hM7He)W8FOEJrNvKMfbYXjsmNeiPOEyUhs8d1Bm6SI0GizvXvbWqlYZ1PSh22h2(dZ4HI9BCHiJWbmz64gFm8d32EOy)gxiYiCatMoUXhd)qG8q9gJoRiniswvCvam0I8CDk7H79WSpKMhUT9q9gJoRinlcKJtKyojqsr9WCpK4hQ3y0zfPbrGCCIeZjbskQhM7H6ngDwrAqKSQ4QayOf556u2dbYUhQ3y0zfPzrYQIRcGHwKNRtzpm3dj(H6ngDwrAqKSQ4QayOf556u2dB7dB)Hz8qX(nUqKr4aMmDCJpg(HBBpuSFJlezeoGjth34JHFiqEOEJrNvKgejRkUkagArEUoL9W9Ey2hsZd32EiXpm)hQ3y0zfPbrGCCIeZjbskQhUT9q9gJoRinlswvCvam0I8CDk7Haz3d1Bm6SI0GizvXvbWqlYZ1PShsZdZ9qIFOEJrNvKMfjRkUkag6yFf4H5EOEJrNvKMfjRkUkagArEUoL9W2(W2FiqEOy)gxiYiCatMoUXhd)WCpuSFJlezeoGjth34JHFygpuVXOZksZIKvfxfadTipxNYE4Epm7d32Ey(puVXOZksZIKvfxfadDSVc8WCpK4hQ3y0zfPzrYQIRcGHoUXhd)W2(W2FygpuSFJlezewVYiKWbmz64gFm8dZ9qX(nUqKry9kJqchWKPJB8XWpeipmBBEyUhs8d1Bm6SI0GizvXvbWqlYZ1PSh22h2(dZ4HI9BCHiJWbmz64gFm8d32EOEJrNvKMfjRkUkag64gFm8dB7dB)Hz8qX(nUqKr4aMmDCJpg(H5EOEJrNvKMfjRkUkagArEUoL9W2(WGT5Hz(qX(nUqKr4aMmDCJpg(Hz8qX(nUqKry9kJqchWKPJB8XWpCB7HI9BCHiJWbmz64gFm8dbYd1Bm6SI0GizvXvbWqlYZ1PShU3dZ(WTThk2VXfImchWKjsWpKMhUT9q9gJoRinlswvCvam0Xn(y4h22h2(dbYdf734crgH1RmcjCatMoUXhd)WCpK4hQ3y0zfPbrYQIRcGHwKNRtzpSTpS9hMXdf734crgH1RmcjCatMoUXhd)WTThM)d1Bm6SI0GiqoorI5Kajf1dZ9qIFOy)gxiYiCatMoUXhd)qG8q9gJoRiniswvCvam0I8CDk7H79WSpCB7HI9BCHiJWbmzIe8dP5H08qAEinpKMhsZd32EO6hbwr60WjTsRHFygpuSFJlezeoGjth34JHFinpCB7H5)q9gJoRinicKJtKyojqsr9WCpm)hklXS5MIOh4g3EyUhs8d1Bm6SI0SiqoorI5Kajf1dZ9qIFiXpm)hk2VXfImchWKjsWpCB7H6ngDwrAwKSQ4QayOJB8XWpeipS9hsZdZ9qIFOy)gxiYiCatMoUXhd)qG8WST5HBBpuVXOZksZIKvfxfadDCJpg(HT9HT)qG8qX(nUqKr4aMmDCJpg(H08qAE422dZ)H6ngDwrAweihNiXCsGKI6H5EiXpm)hQ3y0zfPzrGCCswvCvaShUT9q9gJoRinlswvCvam0Xn(y4hUT9q9gJoRinlswvCvam0I8CDk7Haz3d1Bm6SI0GizvXvbWqlYZ1PShsZdPPhIJLI7H6ngDwd21Elad9w7HS5crE1bEp0L6uwpKeZPr5gCpuEJY349qIFOEJrNvKMfbYXjsmNeiPOE422dLLy2Ctr0dCJBpm3d1Bm6SI0SiqoojRkUka2dP5H5EiXpuSFJlezewVYiKWbmzIe8dZ9qIFy(puwIzZnfrpWnU9WCpm)hQ3y0zfPbrGCCIeZjbskQhUT9qzjMn3ue9a342dZ9W8FOEJrNvKgebYXjzvXvbWE422d1Bm6SI0GizvXvbWqh34JHF422d1Bm6SI0SiqoorI5Kajf1dZ9qIFy(puVXOZksdIa54ejMtcKuupCB7H6ngDwrAwKSQ4QayOf556u2dbYUhQ3y0zfPbrYQIRcGHwKNRtzpKMhUT9q9gJoRinlcKJtYQIRcG9WCpm)hQ3y0zfPbrGCCIeZjbskQhM7H6ngDwrAwKSQ4QayOf556u2dbYUhQ3y0zfPbrYQIRcGHwKNRtzpKMhUT9W8FOy)gxiYiSELriHdyYej4hM7He)W8FOEJrNvKgebYXjsmNeiPOEyUhs8d1Bm6SI0SizvXvbWqlYZ1PSh22h2(dZ4HI9BCHiJWbmz64gFm8d32EOy)gxiYiCatMoUXhd)qG8q9gJoRinlswvCvam0I8CDk7H79WSpKMhUT9q9gJoRinicKJtKyojqsr9WCpK4hQ3y0zfPzrGCCIeZjbskQhM7H6ngDwrAwKSQ4QayOf556u2dbYUhQ3y0zfPbrYQIRcGHwKNRtzpm3dj(H6ngDwrAwKSQ4QayOf556u2dB7dB)Hz8qX(nUqKr4aMmDCJpg(HBBpuSFJlezeoGjth34JHFiqEOEJrNvKMfjRkUkagArEUoL9W9Ey2hsZd32EiXpm)hQ3y0zfPzrGCCIeZjbskQhUT9q9gJoRiniswvCvam0I8CDk7Haz3d1Bm6SI0SizvXvbWqlYZ1PShsZdZ9qIFOEJrNvKgejRkUkag6yFf4H5EOEJrNvKgejRkUkagArEUoL9W2(W2FiqEOy)gxiYiCatMoUXhd)WCpuSFJlezeoGjth34JHFygpuVXOZksdIKvfxfadTipxNYE4Epm7d32Ey(puVXOZksdIKvfxfadDSVc8WCpK4hQ3y0zfPbrYQIRcGHoUXhd)W2(W2FygpuSFJlezewVYiKWbmz64gFm8dZ9qX(nUqKry9kJqchWKPJB8XWpeipmBBEyUhs8d1Bm6SI0SizvXvbWqlYZ1PSh22h2(dZ4HI9BCHiJWbmz64gFm8d32EOEJrNvKgejRkUkag64gFm8dB7dB)Hz8qX(nUqKr4aMmDCJpg(H5EOEJrNvKgejRkUkagArEUoL9W2(WGT5Hz(qX(nUqKr4aMmDCJpg(Hz8qX(nUqKry9kJqchWKPJB8XWpCB7HI9BCHiJWbmz64gFm8dbYd1Bm6SI0SizvXvbWqlYZ1PShU3dZ(WTThk2VXfImchWKjsWpKMhUT9q9gJoRiniswvCvam0Xn(y4h22h2(dbYdf734crgH1RmcjCatMoUXhd)WCpK4hQ3y0zfPzrYQIRcGHwKNRtzpSTpS9hMXdf734crgH1RmcjCatMoUXhd)WTThM)d1Bm6SI0SiqoorI5Kajf1dZ9qIFOy)gxiYiCatMoUXhd)qG8q9gJoRinlswvCvam0I8CDk7H79WSpCB7HI9BCHiJWbmzIe8dP5H08qAEinpKMhsZd32EO6hbwr60WjTsRHFygpuSFJlezeoGjth34JHFinpCB7H5)q9gJoRinlcKJtKyojqsr9WCpm)hklXS5MIOh4g3EyUhs8d1Bm6SI0GiqoorI5Kajf1dZ9qIFiXpm)hk2VXfImchWKjsWpCB7H6ngDwrAqKSQ4QayOJB8XWpeipS9hsZdZ9qIFOy)gxiYiCatMoUXhd)qG8WST5HBBpuVXOZksdIKvfxfadDCJpg(HT9HT)qG8qX(nUqKr4aMmDCJpg(H08qAE422dZ)H6ngDwrAqeihNiXCsGKI6H5EiXpm)hQ3y0zfPbrGCCswvCvaShUT9q9gJoRiniswvCvam0Xn(y4hUT9q9gJoRiniswvCvam0I8CDk7Haz3d1Bm6SI0SizvXvbWqlYZ1PShsZdPPhIJLI7H6ngDwZ21U2dXAV1Elb7T2dDPoL1dDmywQPIkPG4eGjU6HS5crE1bEx7TKT3ApKnxiYRoW7HYBu(gVhkqsrHOo2eLaisWpm3dfiPOquhBIsa0Xn(y4hMXUhsqU6HUuNY6Hc(jWReguPDT3cr1BThYMle5vh49q5nkFJ3dpsJPQJaJWfzKQocCIBe4dJyZfI86H5EO6xsphm64gFm8dZ4HeKRhM7HYQIRcGHOI(XOJB8XWpmJhsqU6HUuNY6HQFj9CWDT3crV3ApKnxiYRoW7HUuNY6Hur)4EO8gLVX7HQFj9CWisWpm3dpsJPQJaJWfzKQocCIBe4dJyZfI8QhghJtYvpmB7DT3s79w7HUuNY6HcXQwyq8QhYMle5vh4DT3cqP3Ap0L6uwpeWexjm45gf3dzZfI8Qd8U2BbyO3Ap0L6uwpKk6b4vcdQ0EiBUqKxDG31EleX9w7HUuNY6H0NymHbvApKnxiYRoW7AVfIOER9q2CHiV6aVhkVr5B8EOSQ4QayOJXL56yes(Dfa0Xn(y4hMXdjixpm3dj(H5)q1JSPioVGJfEeZjmOsrS5crE9WTThkqsrHeIvTIKyfrc(H08WTThM)dLLy2Ctr0dCJBpCB7HYQIRcGHogxMRJri53vaqh34JHF422dfkm(H5Ei1qaKMoUXhd)WmEy79qxQtz9qa(ehJqYVRa01ElbBtV1EiBUqKxDG3dL3O8nEpuwvCvamKaJ1XJjaNRGqh34JHFygpmy2hkQ)qji)iW4e15sDkZJpmZhsqUEyUhQEKnfHLSPPIkjeRAHyZfI86HBBpKImgthlb5hboPtd)WmEib56H5EOSQ4QayibgRJhtaoxbHoUXhd)WTThQ(rGvKonCsR0A4hMXdjI6HUuNY6Hc(jWReguPDT3sWG9w7HS5crE1bEpuEJY349qQssIFyMpu6ynDmb2EygpKQKKyuJN3EOl1PSE4IDfuscYPFEtx7TemBV1EiBUqKxDG3dL3O8nEpuGKIc5yWSutfvsbXjatCHib)WTThkuy8dZ9qQHainDCJpg(Hz8WGT3dDPoL1dXQ3aMxCx7TeKO6T2dDPoL1d9ud5T4lvuj5vaW9q2CHiV6aVR9wcs07T2dzZfI8Qd8EO8gLVX7HcKuuibgRJhtaoxbHib)WTThkuy8dZ9qQHainDCJpg(Hz8WGTPh6sDkRhEmUmxhJqYVRa01ElbBV3ApKnxiYRoW7HYBu(gVhkRkUkagcWexjm45gfJoUXhd)qG8WGT)WTThklXS5MIOh4g3EyUhs8dLvfxfadDmUmxhJqYVRaGoUXhd)WmEy7pCB7HYQIRcGHogxMRJri53vaqh34JHFiqEy228qAE422dv)iWksNgoPvAn8dZ4HbB)HBBpK4hM)dLLy2Ctr2qaKMOC(H5Ey(puwIzZnfrpWnU9qA6HUuNY6HcmwhpMaCUcQR9wccu6T2dDPoL1dLGMgNppHbvApKnxiYRoW7AVLGad9w7HUuNY6H0NymjRMg3w9q2CHiV6aVR9wcse3BThYMle5vh49q5nkFJ3dfiPOqcmwhpMaCUccTka2d32EOqHXpm3dPgcG00Xn(y4hMXdBVh6sDkRhk4esfvsVrsh31ElbjI6T2dDPoL1dxZXjb2XApKnxiYRoW7AVLSTP3ApKnxiYRoW7HYBu(gVhs8dPkjj(HT9HYcRpmZhsvssm6ycS9qr9hs8dLvfxfadrFIXKSAACBHoUXhd)W2(WGpKMhcKh6sDkdrFIXKSAACBHKfwF422dLvfxfadrFIXKSAACBHoUXhd)qG8WGpmZhsqUEinpCB7He)qbskkKaJ1XJjaNRGqKGF422dfiPOqgJXJraGFbWj9CWGhJqYbd2pxjXisWpKMhM7H5)WJ0yQ6iWiGPdo6j(4fPLa4xQUfFi2CHiVE422dfkm(H5Ei1qaKMoUXhd)WmEir1dDPoL1dLLW5jmOs7AVLSb7T2dzZfI8Qd8EO8gLVX7HcKuuiatCLWGNBumIe8d32EOeKFeyCI6CPoL5XhcKhgeL9H5EOSSf5OiHyvRiR6yeqS5crE1dDPoL1df8tGxjmOs7AVLSz7T2dzZfI8Qd8EO8gLVX7HcKuuibgRJhtaoxbHwfa7HBBpuOW4hM7HudbqA64gFm8dZ4HT3dDPoL1d9t6gNatgXCx7TKLO6T2dzZfI8Qd8EO8gLVX7HhPXu1rGr4ImsvhboXnc8HrS5crE9WTThEKgtvhbgzmgpgba(faN0ZbdEmcjhmy)CLeJyZfI8Qh6sDkRhQ(L0Zb31Elzj69w7HS5crE1bEpuEJY349WJ0yQ6iWiJX4XiaWVa4KEoyWJri5Gb7NRKyeBUqKx9qxQtz9qQJzrzmcj9CWDT3s227T2dzZfI8Qd8EO8gLVX7He)qQssIFyMpKQKKy0Xey7Hz(WGT)qAEygpKQKKyuJN3EOl1PSEOFs34Kw3XM21U2dLlCV1Elb7T2dzZfI8Qd8EO8gLVX7HYQIRcGHeySoEmb4Cfe64gFm8dbYdjQ20dDPoL1dDtYy98ys6Xyx7TKT3ApKnxiYRoW7HYBu(gVhkRkUkagsGX64XeGZvqOJB8XWpeipKOAtp0L6uwpKAowiw1QR9wiQER9q2CHiV6aVhkVr5B8EiXpuGKIcbyIReg8CJIrKGF422dZ)HYsmBUPiBiastuo)WCpuGKIc5yWSutfvsbXjatCHib)WCpuGKIcjWyD8ycW5kiej4hsZdZ9qIFi1qaKMoUXhd)qG8qzvXvbWqc8H5J(yeqlYZ1PShM5dxKNRtzpCB7He)q1pcSIaXEubHal1hMXdjQ2F422dZ)HQhztr0NyKV0yyDmPIyZfI86H08qAE422dfkm(H5Ei1qaKMoUXhd)WmEyqIQh6sDkRhkWhMp6JrOR9wi69w7HS5crE1bEpuEJY349qIFOajffcWexjm45gfJib)WTThM)dLLy2Ctr2qaKMOC(H5EOajffYXGzPMkQKcItaM4crc(H5EOajffsGX64XeGZvqisWpKMhM7He)qQHainDCJpg(Ha5HYQIRcGHeIvTsuKxa0I8CDk7Hz(Wf556u2d32EiXpu9JaRiqShvqiWs9Hz8qIQ9hUT9W8FO6r2ue9jg5lngwhtQi2CHiVEinpKMhUT9qHcJFyUhsneaPPJB8XWpmJhgeO0dDPoL1dfIvTsuKxGU2BP9ER9qxQtz9W4qaKIteHKlcnSP9q2CHiV6aVR9wak9w7HS5crE1bEpuEJY349qbskkKJbZsnvujfeNamXfIe8d32Ei1qaKMoUXhd)WmEywGsp0L6uwpeCPtzDTRDThkMp8uwVLSTjBW2auYse1db4NngbCpmpNhe1AHiOL8ir(Wh2ki(Htd460hsv3dPf8XYQrWvAF4XatY541dXvd)qNuRgx51dLGCJaJrVia9y8dBNiFiWwMy(uE9qApsJPQJaJenTpuRhs7rAmvDeyKOrS5crEr7dD9Hava1a9djoyEPb9Ia0JXpSDI8HaBzI5t51dP9inMQocms00(qTEiThPXu1rGrIgXMle5fTpK4G5Lg0lcqpg)qGcr(qGTmX8P86H0QEKnfjAAFOwpKw1JSPirJyZfI8I2hsCW8sd6fbOhJFiqHiFiWwMy(uE9qApsJPQJaJenTpuRhs7rAmvDeyKOrS5crEr7dD9Hava1a9djoyEPb9I8IKNZdIATqe0sEKiF4dBfe)WPbCD6dPQ7H0Q3y0zft7dpgysohVEiUA4h6KA14kVEOeKBeym6fbOhJFiqHiFiWwMy(uE9WWPbyFioGPEEFyE6HA9qGM0F4Aep4PShwG5Z16EiX7rZdjU98sd6fbOhJFiqHiFiWwMy(uE9qA1Bm6SIcIenTpuRhsREJrNvKgejAAFiXzdMxAqVia9y8dbke5db2YeZNYRhsREJrNvuwKOP9HA9qA1Bm6SI0Sirt7djolqjV0GEra6X4hcmqKpeyltmFkVEy40aSpehWupVpmp9qTEiqt6pCnIh8u2dlW85ADpK49O5He3EEPb9Ia0JXpeyGiFiWwMy(uE9qA1Bm6SIcIenTpuRhsREJrNvKgejAAFiXzbk5Lg0lcqpg)qGbI8HaBzI5t51dPvVXOZkkls00(qTEiT6ngDwrAwKOP9HeNnyEPb9I8IKNZdIATqe0sEKiF4dBfe)WPbCD6dPQ7H0kxyAF4XatY541dXvd)qNuRgx51dLGCJaJrVia9y8djkI8HaBzI5t51dPv9iBks00(qTEiTQhztrIgXMle5fTpK4G5Lg0lcqpg)qIor(qGTmX8P86H0QEKnfjAAFOwpKw1JSPirJyZfI8I2hsCW8sd6f5fjpNhe1AHiOL8ir(Wh2ki(Htd460hsv3dPfR0(WJbMKZXRhIRg(HoPwnUYRhkb5gbgJEra6X4hMLiFiWwMy(uE9qAbZks0irvecr7d16H0kQIqiAFiXzZlnOxeGEm(Hefr(qGTmX8P86H0EKgtvhbgjAAFOwpK2J0yQ6iWirJyZfI8I2hsCW8sd6fbOhJFirNiFiWwMy(uE9qApsJPQJaJenTpuRhs7rAmvDeyKOrS5crEr7dD9Hava1a9djoyEPb9Ia0JXpKiIiFiWwMy(uE9qAvpYMIenTpuRhsR6r2uKOrS5crEr7djoyEPb9Ia0JXpmyBiYhcSLjMpLxpKw1JSPirt7d16H0QEKnfjAeBUqKx0(qIdMxAqVia9y8dZ2gI8HaBzI5t51dP9inMQocms00(qTEiThPXu1rGrIgXMle5fTpK4G5Lg0lcqpg)WSbjYhcSLjMpLxpKwzzlYrrIM2hQ1dPvw2ICuKOrS5crEr7dD9Hava1a9djoyEPb9Ia0JXpmlrrKpeyltmFkVEiThPXu1rGrIM2hQ1dP9inMQocms0i2CHiVO9HU(qGkGAG(HehmV0GEra6X4hMLOiYhcSLjMpLxpK2J0yQ6iWirt7d16H0EKgtvhbgjAeBUqKx0(qIdMxAqVia9y8dZs0jYhcSLjMpLxpK2J0yQ6iWirt7d16H0EKgtvhbgjAeBUqKx0(qxFiqfqnq)qIdMxAqViVi558GOwlebTKhjYh(WwbXpCAaxN(qQ6EiTYi7IzAF4XatY541dXvd)qNuRgx51dLGCJaJrVia9y8dZsKpeyltmFkVEiTGzfjAKOkcHO9HA9qAfvrieTpK4S5Lg0lcqpg)qIIiFiWwMy(uE9qAbZks0irvecr7d16H0kQIqiAFiXbZlnOxeGEm(HeDI8HaBzI5t51dP9inMQocms00(qTEiThPXu1rGrIgXMle5fTpK4G5Lg0lcqpg)W2jYhcSLjMpLxpK2J0yQ6iWirt7d16H0EKgtvhbgjAeBUqKx0(qxFiqfqnq)qIdMxAqVia9y8djIjYhcSLjMpLxpKw1JSPirt7d16H0QEKnfjAeBUqKx0(qxFiqfqnq)qIdMxAqVia9y8ddsetKpeyltmFkVEiTGzfjAKOkcHO9HA9qAfvrieTpK4G5Lg0lcqpg)WSzjYhcSLjMpLxpKwzzlYrrIM2hQ1dPvw2ICuKOrS5crEr7dD9Hava1a9djoyEPb9Ia0JXpmlrNiFiWwMy(uE9qApsJPQJaJenTpuRhs7rAmvDeyKOrS5crEr7dD9Hava1a9djoyEPb9Ia0JXpmlrNiFiWwMy(uE9qApsJPQJaJenTpuRhs7rAmvDeyKOrS5crEr7djoyEPb9Ia0JXpmB7e5db2YeZNYRhs7rAmvDeyKOP9HA9qApsJPQJaJenInxiYlAFORpeOcOgOFiXbZlnOxKxeIGgW1P86HaLh6sDk7HXbRy0lspe8vutK7HaJaJpe4SJ1hs0IJv(c8qI2KMY3lcWiW4dfHmg4Hb3)HzBt2GViViUuNYWiWhlRgbx3HjBAklbM1xexQtzye4JLvJGRzUBpHs1iVsurpaVamgHKw5DSxexQtzye4JLvJGRzUBpQiJbjpNsFrCPoLHrGpwwncUM5U9iXCAuUzFZB4DUOGb5NJtuLPPIkbUaW3lIl1Pmmc8XYQrW1m3TN6xsph8(Gpw6ynPtdVliQ99hQDhPXu1rGr4ImsvhboXnc8H32osJPQJaJmgJhJaa)cGt65GbpgHKdgSFUsIFrCPoLHrGpwwncUM5U9eySoEmb4Cf0(Gpw6ynPtdVliQ99hQD5REKnfHLSPPIkjeRALl)J0yQ6iWiCrgPQJaN4gb(WViaJpmpSicjXk(Hki(HlYZ1PSh626HYQIRcG9WI6H5bmywQpSOEOcIFyEEIRh626HIkVPXJpKiWW6ysf)qHapubXpCrEUoL9WI6HU9qsdKJvE9W8iWs08qaGy7HkioaTh)qsmVEi4JLvJGROhcCw6Ky(H5bmywQpSOEOcIFyEEIRhE8IuY4hMhbwIMhke4HzBtBAW7)qf0GF4GFyqer9qmllBHrViUuNYWiWhlRgbxZC3Eogml1urLuqCcWex7d(yPJ1Kon8UGiIA)HAx(UOW3Omc8nnEmngwhtQyeBUqKx5YNXy2KmIXy2KCQOskiorvss8yesZnyuJtewxoIzGj5agmVqUOGb5NJtuLPPIkbUaW32w(mWKCadMxizazS0RSrMeIowP5fby8H5HfrijwXpubXpCrEUoL9q3wpuwvCvaShwupe4mwhp(W885kOh626HeTDrHFyr9qrnNa)qHapubXpCrEUoL9WI6HU9qsdKJvE9W8iWs08qaGy7HkioaTh)qsmVEi4JLvJGROxexQtzye4JLvJGRzUBpbgRJhtaoxbTp4JLowt60W7cIAF)HANlk8nkJaFtJhtJH1XKkgXMle5vU8zmMnjJymMnjNkQKcItuLKepgH0Cdg14eH1LJygysoGbZlKlkyq(54evzAQOsGla8TTLpdmjhWG5fsgqgl9kBKjHOJvAErErCPoLHZC3EYI0u(syqL(Iam(W8y9qhe7Rh626HTEUbmjN4ik8dBrujW(q24MHXeT(qa8dxLrR(Wv9qf0GFivDpeC0dWh(HcS0jX8dhL21df4hQv9qmyVPjWdDB9qa8dLUrR(WJ91ed8Wwp3aMpedMLd1iFOajffg9I4sDkdN5U90ZnGj5ehrzmcjmOs3FO2LV6hbwrdobo6b47fbyey8HenC0d8qkxogHhgOiVhUksb9HKMoXhgOiFiixm)qWK6df1yCzUogHhMhURa8WvbW2)H19WH6Hki(HYQIRcG9Wb)qTQhglJWd16Hlo6bEiLlhJWdduK3djAksbf9qIaQhALXpSOEOcIX8dLLTgDkd)q)4h6cr(HA9WgwFiGrbn2dvq8dd2MhIzzzl8dJmdWdS)dvq8dXtZdPCjJFyGI8EirtrkOp0j1QX1r6Xya0lcWiW4dDPoLHZC3EgdGQiTv6yCffZ7pu7WfzuySfYyaufPTshJROyohXcKuuOJXL56yes(Dfaej4TnzvXvbWqhJlZ1XiK87kaOJB8XWajyB22u)iWksNgoPvAnCgbbk08I4sDkdN5U9KEmMCPoLLIdw338gENEJrNv8(d1ozjMn3ue9a34wozvXvbWqogml1urLuqCcWexOJB8XW5KvfxfadDmUmxhJqYVRaGoUXhdVTLVSeZMBkIEGBClNSQ4QayihdMLAQOskiobyIl0Xn(y4xexQtz4m3TN0JXKl1PSuCW6(M3W7Kl8lIl1PmCM72t6XyYL6uwkoyDFZB4DyD)HANl1rmNyJBggNr2xexQtz4m3TN0JXKl1PSuCW6(M3W7Kr2fZ7pu7CPoI5eBCZWyGe8f5fXL6uggjx4DUjzSEEmj9yC)HANSQ4QayibgRJhtaoxbHoUXhddeIQnViUuNYWi5cN5U9OMJfIvT2FO2jRkUkagsGX64XeGZvqOJB8XWaHOAZlIl1PmmsUWzUBpb(W8rFmc7pu7iwGKIcbyIReg8CJIrKG32YxwIzZnfzdbqAIY5CcKuuihdMLAQOskiobyIlej4CcKuuibgRJhtaoxbHibttoIPgcG00Xn(yyGiRkUkagsGpmF0hJaArEUoLL5I8CDkBBJy1pcSIaXEubHal1miQ232Yx9iBkI(eJ8LgdRJjvAOzBtOW4CudbqA64gFmCgbjQxexQtzyKCHZC3EcXQwjkYlW(d1oIfiPOqaM4kHbp3Oyej4TT8LLy2Ctr2qaKMOCoNajffYXGzPMkQKcItaM4crcoNajffsGX64XeGZvqisW0KJyQHainDCJpggiYQIRcGHeIvTsuKxa0I8CDklZf556u22gXQFeyfbI9OccbwQzquTVTLV6r2ue9jg5lngwhtQ0qZ2MqHX5OgcG00Xn(y4mccuErCPoLHrYfoZD7fhcGuCIiKCrOHn9fXL6uggjx4m3Th4sNY2FO2jqsrHCmywQPIkPG4eGjUqKG32OgcG00Xn(y4mYcuErErCPoLHrYi7I5Dogml1urLuqCcWexViUuNYWizKDXCM72tWpbELWGkDFzazKtQFeyfVl4(d1oWSIA8XqcKuuiQJnrjaIeCoWSIA8XqcKuuiQJnrja64gFmCg7iixViUuNYWizKDXCM72RHmQdguP7pu7iixTfmROgFmKajffsGDSMKr2fZOJB8XWaPnOST)I4sDkdJKr2fZzUBp1VKEo49hQDhPXu1rGr4ImsvhboXnc8HZP(L0ZbJoUXhdNbb5kNSQ4QayiQOFm64gFmCgeKRxexQtzyKmYUyoZD7rf9J3pogNKRDzBF)HAN6xsphmIeCUJ0yQ6iWiCrgPQJaN4gb(WViUuNYWizKDXCM72BXUckjb50pVz)HAhvjjXzkDSMoMaBzqvssmQXZ7lIl1PmmsgzxmN5U9amXvcdEUrXViUuNYWizKDXCM72tWpbELWGkDFzazKtQFeyfVl4(d1okYymDSeKFe4KonCgeKRCYQIRcGHeySoEmb4Cfe64gFm82MSQ4QayibgRJhtaoxbHoUXhdNrWSzsqUYPEKnfHLSPPIkjeRA9I4sDkdJKr2fZzUBpbgRJhtaoxb9I4sDkdJKr2fZzUBVJXL56yes(DfGxexQtzyKmYUyoZD7HvVbmV49hQDcKuuihdMLAQOskiobyIlej4TnHcJZrneaPPJB8XWzeS9xexQtzyKmYUyoZD7bWN4yes(DfGxexQtzyKmYUyoZD7rf9a8kHbv6lIl1PmmsgzxmN5U9OpXycdQ0xexQtzyKmYUyoZD7jbnnoFEcdQ0xexQtzyKmYUyoZD7jeRAHbXRxexQtzyKmYUyoZD75PgYBXxQOsYRaGFrCPoLHrYi7I5m3TNGFNtG3FO2bMvuJpgsGKIcrDSjkbqh34JHbcNxwsQCsNg(fXL6uggjJSlMZC3E0NymjRMg3w7pu7OkjjgiYcRz6sDkd1qg1bdQuKSW6lIl1PmmsgzxmN5U9eCcPIkP3iPJ3FO2jqsrHeySoEmb4CfeAvaSTnHcJZrneaPPJB8XWz0(lIl1PmmsgzxmN5U9wZXjb2X6lIl1PmmsgzxmN5U9e8tGxjmOs3xgqg5K6hbwX7cU)qTt9JaRiDA4KwP1WzqeTTjb5hbgNOoxQtzEeibrzZjlBroksiw1kYQogHxexQtzyKmYUyoZD7jlHZtyqLU)qTJQKKyKonCsRuJN3miixI6zFrCPoLHrYi7I5m3TN6xsph8(d1UJ0yQ6iWiCrgPQJaN4gb(WBBhPXu1rGrgJXJraGFbWj9CWGhJqYbd2pxjXViUuNYWizKDXCM72J6ywugJqsph8(d1UJ0yQ6iWiJX4XiaWVa4KEoyWJri5Gb7NRK4xexQtzyKmYUyoZD75N0noP1DSP7pu7iMQKK4mPkjjgDmb2YKOAdnzqvssmQXZ7lYlIl1PmmcR7CmywQPIkPG4eGjUErCPoLHrynZD7j4NaVsyqLU)qTdmROgFmKajffI6ytucGibNdmROgFmKajffI6ytucGoUXhdNXocY1lIl1PmmcRzUBp1VKEo49hQDhPXu1rGr4ImsvhboXnc8HZP(L0ZbJoUXhdNbb5kNSQ4QayiQOFm64gFmCgeKRxexQtzyewZC3Eur)49JJXj5Ax223FO2P(L0ZbJibN7inMQocmcxKrQ6iWjUrGp8lIl1PmmcRzUBpHyvlmiE9I4sDkdJWAM72dWexjm45gf)I4sDkdJWAM72Jk6b4vcdQ0xexQtzyewZC3E0NymHbv6lIl1PmmcRzUBpa(ehJqYVRaS)qTtwvCvam0X4YCDmcj)Uca64gFmCgeKRCeNV6r2ueNxWXcpI5eguPBBcKuuiHyvRijwrKGPzBlFzjMn3ue9a3422MSQ4QayOJXL56yes(Dfa0Xn(y4TnHcJZrneaPPJB8XWz0(lIl1PmmcRzUBpb)e4vcdQ09hQDYQIRcGHeySoEmb4Cfe64gFmCgbZkQlb5hbgNOoxQtzEmtcYvo1JSPiSKnnvujHyvRTnkYymDSeKFe4KonCgeKRCYQIRcGHeySoEmb4Cfe64gFm82M6hbwr60WjTsRHZGi6fXL6uggH1m3T3IDfuscYPFEZ(d1oQssIZu6ynDmb2YGQKKyuJN3xexQtzyewZC3Ey1BaZlE)HANajffYXGzPMkQKcItaM4crcEBtOW4CudbqA64gFmCgbB)fXL6uggH1m3TNNAiVfFPIkjVca(fXL6uggH1m3T3X4YCDmcj)UcW(d1obskkKaJ1XJjaNRGqKG32ekmoh1qaKMoUXhdNrW28I4sDkdJWAM72tGX64XeGZvq7pu7KvfxfadbyIReg8CJIrh34JHbsW232KLy2Ctr0dCJB5iwwvCvam0X4YCDmcj)Uca64gFmCgTVTjRkUkag6yCzUogHKFxbaDCJpggizBdnBBQFeyfPtdN0kTgoJGTVTrC(YsmBUPiBiastuoNlFzjMn3ue9a34gnViUuNYWiSM5U9KGMgNppHbv6lIl1PmmcRzUBp6tmMKvtJBRxexQtzyewZC3EcoHurL0BK0X7pu7eiPOqcmwhpMaCUccTka22MqHX5OgcG00Xn(y4mA)fXL6uggH1m3T3AoojWowFrCPoLHrynZD7jlHZtyqLU)qTJyQssIBRSWAMuLKeJoMaBI6elRkUkagI(eJjz1042cDCJpgUTbPbiUuNYq0NymjRMg3wizH1TnzvXvbWq0NymjRMg3wOJB8XWajyMeKlA22iwGKIcjWyD8ycW5kiej4TnbskkKXy8yea4xaCsphm4XiKCWG9ZvsmIemn5Y)inMQocmcy6GJEIpErAja(LQBX32MqHX5OgcG00Xn(y4miQxexQtzyewZC3Ec(jWReguP7pu7eiPOqaM4kHbp3Oyej4Tnji)iW4e15sDkZJajikBozzlYrrcXQwrw1Xi8I4sDkdJWAM72ZpPBCcmzeZ7pu7eiPOqcmwhpMaCUccTka22MqHX5OgcG00Xn(y4mA)fXL6uggH1m3TN6xsph8(d1UJ0yQ6iWiCrgPQJaN4gb(WBBhPXu1rGrgJXJraGFbWj9CWGhJqYbd2pxjXViUuNYWiSM5U9OoMfLXiK0ZbV)qT7inMQocmYymEmca8laoPNdg8yesoyW(5kj(fXL6uggH1m3TNFs34Kw3XMU)qTJyQssIZKQKKy0XeylZGTttguLKeJA88(I8I4sDkdJ0Bm6SI3j2VXfI8(M3W7WbmzIe8(I9ijVtGKIcDmUmxhJqYVRaGibVTjqsrHCmywQPIkPG4eGjUqKGFrCPoLHr6ngDwXzUBpX(nUqK338gEhwVYiKWbmzIe8(I9ijVtwIzZnfrpWnULtGKIcDmUmxhJqYVRaGibNtGKIc5yWSutfvsbXjatCHibVTLVSeZMBkIEGBClNajffYXGzPMkQKcItaM4crc(fXL6uggP3y0zfN5U9e734crEFZB4Dy9kJqchWKPJB8XW7xG3HzDO2xw2A0PSDYsmBUPi6bUXT9f7rsENSQ4QayOJXL56yes(Dfa0Xn(y4meviRkUkagYXGzPMkQKcItaM4cDCJpgEFXEKKtCeZ7Kvfxfad5yWSutfvsbXjatCHoUXhdV)qTtGKIc5yWSutfvsbXjatCHwfa7fXL6uggP3y0zfN5U9e734crEFZB4Dy9kJqchWKPJB8XW7xG3HzDO2xw2A0PSDYsmBUPi6bUXT9f7rsENSQ4QayOJXL56yes(Dfa0Xn(y49f7rsoXrmVtwvCvamKJbZsnvujfeNamXf64gFm8(d1obskkKJbZsnvujfeNamXfIe8lIl1PmmsVXOZkoZD7j2VXfI8(M3W7Wbmz64gFm8(f4DywhQ9LLTgDkBNSeZMBkIEGBCBFXEKK3jRkUkag6yCzUogHKFxbaDCJpggiIkKvfxfad5yWSutfvsbXjatCHoUXhdVVypsYjoI5DYQIRcGHCmywQPIkPG4eGjUqh34JHFrCPoLHr6ngDwXzUBpsmNgLBW7JJLI3P3y0zn4(d1oI1Bm6SIcIa54ejMtcKuuBBYsmBUPi6bUXTC6ngDwrbrGCCswvCvamAYrSy)gxiYiSELriHdyYej4CeNVSeZMBkIEGBClx(6ngDwrzrGCCIeZjbskQTnzjMn3ue9a34wU81Bm6SIYIa54KSQ4QayBB6ngDwrzrYQIRcGHoUXhdVTP3y0zffebYXjsmNeiPOYrC(6ngDwrzrGCCIeZjbskQTn9gJoROGizvXvbWqlYZ1PmGStVXOZkklswvCvam0I8CDkJMTn9gJoROGiqoojRkUkawU81Bm6SIYIa54ejMtcKuu50Bm6SIcIKvfxfadTipxNYaYo9gJoROSizvXvbWqlYZ1PmA22YxSFJlezewVYiKWbmzIeCoIZxVXOZkklcKJtKyojqsrLJy9gJoROGizvXvbWqlYZ1PS22EgI9BCHiJWbmz64gFm82My)gxiYiCatMoUXhdde9gJoROGizvXvbWqlYZ1PS8uwA220Bm6SIYIa54ejMtcKuu5iwVXOZkkicKJtKyojqsrLtVXOZkkiswvCvam0I8CDkdi70Bm6SIYIKvfxfadTipxNYYrSEJrNvuqKSQ4QayOf556uwBBpdX(nUqKr4aMmDCJpgEBtSFJlezeoGjth34JHbIEJrNvuqKSQ4QayOf556uwEklnBBeNVEJrNvuqeihNiXCsGKIABtVXOZkklswvCvam0I8CDkdi70Bm6SIcIKvfxfadTipxNYOjhX6ngDwrzrYQIRcGHo2xbYP3y0zfLfjRkUkagArEUoL122bIy)gxiYiCatMoUXhdNtSFJlezeoGjth34JHZqVXOZkklswvCvam0I8CDklpLDBlF9gJoROSizvXvbWqh7Ra5iwVXOZkklswvCvam0Xn(y422EgI9BCHiJW6vgHeoGjth34JHZj2VXfImcRxzes4aMmDCJpggizBtoI1Bm6SIcIKvfxfadTipxNYAB7zi2VXfImchWKPJB8XWBB6ngDwrzrYQIRcGHoUXhd322ZqSFJlezeoGjth34JHZP3y0zfLfjRkUkagArEUoL12GTjtX(nUqKr4aMmDCJpgodX(nUqKry9kJqchWKPJB8XWBBI9BCHiJWbmz64gFmmq0Bm6SIcIKvfxfadTipxNYYtz32e734crgHdyYejyA220Bm6SIYIKvfxfadDCJpgUTTdeX(nUqKry9kJqchWKPJB8XW5iwVXOZkkiswvCvam0I8CDkRTTNHy)gxiYiSELriHdyY0Xn(y4TT81Bm6SIcIa54ejMtcKuu5iwSFJlezeoGjth34JHbIEJrNvuqKSQ4QayOf556uwEk72My)gxiYiCatMibtdn0qdn0STP(rGvKonCsR0A4me734crgHdyY0Xn(yyA22YxVXOZkkicKJtKyojqsrLlFzjMn3ue9a34woI1Bm6SIYIa54ejMtcKuu5iM48f734crgHdyYej4Tn9gJoROSizvXvbWqh34JHbs70KJyX(nUqKr4aMmDCJpggizBZ2MEJrNvuwKSQ4QayOJB8XWTTDGi2VXfImchWKPJB8XW0qZ2w(6ngDwrzrGCCIeZjbskQCeNVEJrNvuweihNKvfxfaBBtVXOZkklswvCvam0Xn(y4Tn9gJoROSizvXvbWqlYZ1PmGStVXOZkkiswvCvam0I8CDkJgAErCPoLHr6ngDwXzUBpsmNgLBW7JJLI3P3y0zn7(d1oI1Bm6SIYIa54ejMtcKuuBBYsmBUPi6bUXTC6ngDwrzrGCCswvCvamAYrSy)gxiYiSELriHdyYej4CeNVSeZMBkIEGBClx(6ngDwrbrGCCIeZjbskQTnzjMn3ue9a34wU81Bm6SIcIa54KSQ4QayBB6ngDwrbrYQIRcGHoUXhdVTP3y0zfLfbYXjsmNeiPOYrC(6ngDwrbrGCCIeZjbskQTn9gJoROSizvXvbWqlYZ1PmGStVXOZkkiswvCvam0I8CDkJMTn9gJoROSiqoojRkUkawU81Bm6SIcIa54ejMtcKuu50Bm6SIYIKvfxfadTipxNYaYo9gJoROGizvXvbWqlYZ1PmA22YxSFJlezewVYiKWbmzIeCoIZxVXOZkkicKJtKyojqsrLJy9gJoROSizvXvbWqlYZ1PS22EgI9BCHiJWbmz64gFm82My)gxiYiCatMoUXhdde9gJoROSizvXvbWqlYZ1PS8uwA220Bm6SIcIa54ejMtcKuu5iwVXOZkklcKJtKyojqsrLtVXOZkklswvCvam0I8CDkdi70Bm6SIcIKvfxfadTipxNYYrSEJrNvuwKSQ4QayOf556uwBBpdX(nUqKr4aMmDCJpgEBtSFJlezeoGjth34JHbIEJrNvuwKSQ4QayOf556uwEklnBBeNVEJrNvuweihNiXCsGKIABtVXOZkkiswvCvam0I8CDkdi70Bm6SIYIKvfxfadTipxNYOjhX6ngDwrbrYQIRcGHo2xbYP3y0zffejRkUkagArEUoL122bIy)gxiYiCatMoUXhdNtSFJlezeoGjth34JHZqVXOZkkiswvCvam0I8CDklpLDBlF9gJoROGizvXvbWqh7Ra5iwVXOZkkiswvCvam0Xn(y422EgI9BCHiJW6vgHeoGjth34JHZj2VXfImcRxzes4aMmDCJpggizBtoI1Bm6SIYIKvfxfadTipxNYAB7zi2VXfImchWKPJB8XWBB6ngDwrbrYQIRcGHoUXhd322ZqSFJlezeoGjth34JHZP3y0zffejRkUkagArEUoL12GTjtX(nUqKr4aMmDCJpgodX(nUqKry9kJqchWKPJB8XWBBI9BCHiJWbmz64gFmmq0Bm6SIYIKvfxfadTipxNYYtz32e734crgHdyYejyA220Bm6SIcIKvfxfadDCJpgUTTdeX(nUqKry9kJqchWKPJB8XW5iwVXOZkklswvCvam0I8CDkRTTNHy)gxiYiSELriHdyY0Xn(y4TT81Bm6SIYIa54ejMtcKuu5iwSFJlezeoGjth34JHbIEJrNvuwKSQ4QayOf556uwEk72My)gxiYiCatMibtdn0qdn0STP(rGvKonCsR0A4me734crgHdyY0Xn(yyA22YxVXOZkklcKJtKyojqsrLlFzjMn3ue9a34woI1Bm6SIcIa54ejMtcKuu5iM48f734crgHdyYej4Tn9gJoROGizvXvbWqh34JHbs70KJyX(nUqKr4aMmDCJpggizBZ2MEJrNvuqKSQ4QayOJB8XWTTDGi2VXfImchWKPJB8XW0qZ2w(6ngDwrbrGCCIeZjbskQCeNVEJrNvuqeihNKvfxfaBBtVXOZkkiswvCvam0Xn(y4Tn9gJoROGizvXvbWqlYZ1PmGStVXOZkklswvCvam0I8CDkJgA6HyWSS3s22jQU21Eha]] )

end
