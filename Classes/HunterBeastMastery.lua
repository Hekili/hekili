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


    spec:RegisterPack( "Beast Mastery", 20211123, [[d8uMacqiHupsiPCjjuvBsI8jevJcr5uiuRscv5vcLMLQuULQKAxG(feYWKq5ycXYeQEgcPMgcbxdcABqG8niqzCcjrNJaH1Hq07qiHAEsi3tIAFcf)Jar5Gcjvlec1dHaMibICrjuPpkKKgjbIQtIqIwjbmtvj5MiKq2PQe)ucvmuesWsrijpvuMQQu9viq1yfsCwHKWEvv)vKbdCyklMqpwWKj6YO2ms9zi1OrKtRy1iKuVMGMTKUTQy3u9BvgoKCCecTCPEoutN01rY2rW3HOXtG68sW6jqA(IQ9R0)i)3)zst5)lXlw8irIeNOHXJteIq0cIFMwaf)ZqzbHgA(N52d)ZqmByDbefzyL7c)muwH6zY)7)m8r1b(NrsvuyIeric9OKOeHH7br45HQA6CEOnAfr45jGOFMi1uvIs)l(ZKMY)xIxS4rIejordJhNieHOjc)mJsjD9plBEqGFgPrkz)l(ZKmo8ZqmByDbefzyL7clqqoLRCVc8YrGFe5Ebri63wq8IfpYkWkacqYC0mMixbE9ciQ4xZUjw5fGyRfz5cYiD6cIQTf4fquG75KWFwDWk()(ptY0gvv)V)FjY)9FMf058Fw4OCL7eM0P)m2nXkl)i(R)xI)F)NXUjwz5hX)mlOZ5)mTnNisn1rqhhDct60FMKXHEqPZ5)SO6TaJeBYfyUCbV3MtePM6iO8cEHOacSa25NHXVTaK8cKNtUUa5TaL0Gxa91lav1kWnEbICWOW8cgLC5ce5fO3Tamk75PWcmxUaK8ccMtUUGMn5ulSG3BZjIlaJIdd9ewGifnng(Zc9OCp2pl6fOwJMv4GtOQwbU)6)fI()(pJDtSYYpI)zHEuUh7NfocSBUcfwOhZxqPfeURkpKo0WO4GMo6KsItiNQe28JnoEbLwq4UQ8q6WMXNB64Otw3hsyZp244fKNVGOxq4iWU5kuyHEmFbLwq4UQ8q6qdJIdA6OtkjoHCQsyZp244Fgw7jO)xI8ZSGoN)ZcwTMSGoNNQdw)z1bRj3E4FM2JlKv8x)Vqe(V)Zy3eRS8J4FMf058FwWQ1Kf058uDW6pRoyn52d)Zcs8x)VGW)7)m2nXkl)i(Nf6r5ESFMf0HaNyNFggVGIwq8Fgw7jO)xI8ZSGoN)ZcwTMSGoNNQdw)z1bRj3E4Fgw)6)fe0)9Fg7MyLLFe)Zc9OCp2pZc6qGtSZpdJxqmliYpdR9e0)lr(zwqNZ)zbRwtwqNZt1bR)S6G1KBp8pluzJa)1V(Zq1C4Een9)()Li)3)zwqNZ)zyQNNZtOy9NXUjwz5hXF9)s8)7)mlOZ5)mXt1klt0vRalroo6KEcE8Fg7MyLLFe)1)le9)9FMf058FgDLXKcTrR)m2nXkl)i(R)xic)3)zSBIvw(r8pZTh(NzckMK1gorFUMo6eQdj3)mlOZ5)mtqXKS2Wj6Z10rNqDi5(R)xq4)9Fg7MyLLFe)Zq1CWWAsNh(NfbIWFMf058FMADsBd1pl0JY9y)SMYz6RrZq8rvPVgnN4hrUXq2nXklxqE(cAkNPVgndDgJhhnsRlGtABOqno6KHcL1MsHHSBIvw(1)liO)7)m2nXkl)i(NHQ5GH1Kop8plceH)mlOZ5)mrgRJvtiBtj9Zc9OCp2pl6fOwLDfIdSRPJojwVtcz3eRSCbLwq0lOPCM(A0meFuv6RrZj(rKBmKDtSYYV(Fbb7)(pJDtSYYpI)zOAoyynPZd)ZIaj6FMKXHEqPZ5)SOUKOMcR4fOK4fiPAtNZxG5YfeURkpK(co6fe1XO4GUGJEbkjEbi4tvUaZLlGOqppwDbeLowhpO4fiwybkjEbsQ2058fC0lW8fq5KmSYYfevrabPfGKe7lqjXfiV5fqHz5cq1C4EenfUaeZbJcZliQJrXbDbh9cus8cqWNQCbnlPcmEbrveqqAbIfwq8IvSh8Blqjn4fm4febs0laZHZLy4pZc6C(pZWO4GMo6KsItiNQ8Nf6r5ESFw0lWeuUhLHO65XQPXX64bfdz3eRSCbLwq0lGXy2dmKXy2dC6OtkjorFbk84Ottpy4JruF9ckTaYwatePguOyj0eumjRnCI(CnD0juhsUxqE(cIEbmrKAqHILWqHq90(8jKeRgwxaXF9)su5)9Fg7MyLLFe)Zq1CWWAsNh(NfbIWFMKXHEqPZ5)SOUKOMcR4fOK4fiPAtNZxG5YfeURkpK(co6fGygRJvxacEBkPfyUCbcYnbLxWrVaIkdnVaXclqjXlqs1MoNVGJEbMVakNKHvwUGOkciiTaKKyFbkjUa5nVakmlxaQMd3JOPWFMf058FMiJ1XQjKTPK(zHEuUh7Nzck3JYqu98y104yD8GIHSBIvwUGsli6fWym7bgYym7boD0jLeNOVafEC0PPhm8XiQVEbLwazlGjIudkuSeAckMK1gorFUMo6eQdj3lipFbrVaMisnOqXsyOqOEAF(esIvdRlG4V(1FM2JlKv8)9)lr(V)Zy3eRS8J4F2H6NHz9NzbDo)NrW6XeR8pJGvP4FMifnnSz85Moo6K19HesHAb55lqKIMgAyuCqthDsjXjKtvcPq9ZiyDYTh(NHl4HefQV(Fj()9Fg7MyLLFe)Zou)mmR)mlOZ5)mcwpMyL)zeSkf)Zchb2nxHcl0J5lO0cePOPHnJp30XrNSUpKqkulO0cePOPHggfh00rNusCc5uLqkulipFbrVGWrGDZvOWc9y(ckTarkAAOHrXbnD0jLeNqovjKc1pJG1j3E4Fgw7ZrNWf8qIc1x)Vq0)3)zSBIvw(r8p7q9ZWSo0)mlOZ5)mcwpMyL)zeSo52d)ZWAFo6eUGhsn)yJJ)zHEuUh7NjsrtdnmkoOPJoPK4eYPkHYdP)ZiyvkoXvm)Zc3vLhshAyuCqthDsjXjKtvcB(Xgh)Ziyvk(NfURkpKoSz85Moo6K19He28JnoEbfjiBbH7QYdPdnmkoOPJoPK4eYPkHn)yJJ)6)fIW)9Fg7MyLLFe)Zou)mmRd9pZc6C(pJG1Jjw5FgbRtU9W)mS2NJoHl4HuZp244FwOhL7X(zIu00qdJIdA6OtkjoHCQsifQFgbRsXjUI5Fw4UQ8q6qdJIdA6OtkjoHCQsyZp244FgbRsX)SWDv5H0HnJp30XrNSUpKWMFSXXF9)cc)V)Zy3eRS8J4F2H6NHzDO)zwqNZ)zeSEmXk)ZiyDYTh(NHl4HuZp244FwOhL7X(zHJa7MRqHf6X8FgbRsXjUI5Fw4UQ8q6qdJIdA6OtkjoHCQsyZp244FgbRsX)SWDv5H0HnJp30XrNSUpKWMFSXXligbzliCxvEiDOHrXbnD0jLeNqovjS5hBC8x)VGG(V)Zy3eRS8J4FMf058FM2JlK1i)Sqpk3J9ZiBbApUqwHAeijdNOWCsKIMEb55liCey3CfkSqpMVGslq7XfYkuJajz4u4UQ8q6lG4fuAbKTacwpMyLHyTphDcxWdjkulO0ciBbrVGWrGDZvOWc9y(ckTGOxG2JlKvOghsYWjkmNePOPxqE(cchb2nxHcl0J5lO0cIEbApUqwHACijdNc3vLhsFb55lq7XfYkuJdd3vLhsh28JnoEb55lq7XfYkuJajz4efMtIu00lO0ciBbrVaThxiRqnoKKHtuyojsrtVG88fO94czfQrGH7QYdPdLuTPZ5liMYlq7XfYkuJdd3vLhshkPAtNZxaXlipFbApUqwHAeijdNc3vLhsFbLwq0lq7XfYkuJdjz4efMtIu00lO0c0ECHSc1iWWDv5H0HsQ2058fet5fO94czfQXHH7QYdPdLuTPZ5lG4fKNVGOxabRhtSYqS2NJoHl4HefQfuAbKTGOxG2JlKvOghsYWjkmNePOPxqPfq2c0ECHSc1iWWDv5H0HsQ2058f86fGWfu0ciy9yIvgIl4HuZp244fKNVacwpMyLH4cEi18JnoEbXSaThxiRqncmCxvEiDOKQnDoFbiAbXxaXlipFbApUqwHACijdNOWCsKIMEbLwazlq7XfYkuJajz4efMtIu00lO0c0ECHSc1iWWDv5H0HsQ2058fet5fO94czfQXHH7QYdPdLuTPZ5lO0ciBbApUqwHAey4UQ8q6qjvB6C(cE9cq4ckAbeSEmXkdXf8qQ5hBC8cYZxabRhtSYqCbpKA(XghVGywG2JlKvOgbgURkpKous1MoNVaeTG4lG4fKNVaYwq0lq7XfYkuJajz4efMtIu00lipFbApUqwHACy4UQ8q6qjvB6C(cIP8c0ECHSc1iWWDv5H0HsQ2058fq8ckTaYwG2JlKvOghgURkpKoSztwybLwG2JlKvOghgURkpKous1MoNVGxVaeUGywabRhtSYqCbpKA(XghVGslGG1JjwziUGhsn)yJJxqrlq7XfYkuJdd3vLhshkPAtNZxaIwq8fKNVGOxG2JlKvOghgURkpKoSztwybLwazlq7XfYkuJdd3vLhsh28JnoEbVEbiCbfTacwpMyLHyTphDcxWdPMFSXXlO0ciy9yIvgI1(C0jCbpKA(XghVGywq8ITGslGSfO94czfQrGH7QYdPdLuTPZ5l41laHlOOfqW6XeRmexWdPMFSXXlipFbApUqwHACy4UQ8q6WMFSXXl41laHlOOfqW6XeRmexWdPMFSXXlO0c0ECHSc14WWDv5H0HsQ2058f86fePyli2fqW6XeRmexWdPMFSXXlOOfqW6XeRmeR95Ot4cEi18JnoEb55lGG1JjwziUGhsn)yJJxqmlq7XfYkuJad3vLhshkPAtNZxaIwq8fKNVacwpMyLH4cEirHAbeVG88fO94czfQXHH7QYdPdB(XghVGxVaeUGywabRhtSYqS2NJoHl4HuZp244fuAbKTaThxiRqncmCxvEiDOKQnDoFbVEbiCbfTacwpMyLHyTphDcxWdPMFSXXlipFbrVaThxiRqncKKHtuyojsrtVGslGSfqW6XeRmexWdPMFSXXliMfO94czfQrGH7QYdPdLuTPZ5larli(cYZxabRhtSYqCbpKOqTaIxaXlG4fq8ciEbeVG88fOwJMvOopCsVKC4fu0ciy9yIvgIl4HuZp244fq8cYZxq0lq7XfYkuJajz4efMtIu00lO0cIEbHJa7MRqHf6X8fuAbKTaThxiRqnoKKHtuyojsrtVGslGSfq2cIEbeSEmXkdXf8qIc1cYZxG2JlKvOghgURkpKoS5hBC8cIzbiCbeVGslGSfqW6XeRmexWdPMFSXXliMfeVylipFbApUqwHACy4UQ8q6WMFSXXl41laHliMfqW6XeRmexWdPMFSXXlG4fq8cYZxq0lq7XfYkuJdjz4efMtIu00lO0ciBbrVaThxiRqnoKKHtH7QYdPVG88fO94czfQXHH7QYdPdB(XghVG88fO94czfQXHH7QYdPdLuTPZ5liMYlq7XfYkuJad3vLhshkPAtNZxaXlG4FgUEk(NP94cznYx)VGG9F)NXUjwz5hX)mlOZ5)mThxiRX)zHEuUh7Nr2c0ECHSc14qsgorH5Kifn9cYZxq4iWU5kuyHEmFbLwG2JlKvOghsYWPWDv5H0xaXlO0ciBbeSEmXkdXAFo6eUGhsuOwqPfq2cIEbHJa7MRqHf6X8fuAbrVaThxiRqncKKHtuyojsrtVG88feocSBUcfwOhZxqPfe9c0ECHSc1iqsgofURkpK(cYZxG2JlKvOgbgURkpKoS5hBC8cYZxG2JlKvOghsYWjkmNePOPxqPfq2cIEbApUqwHAeijdNOWCsKIMEb55lq7XfYkuJdd3vLhshkPAtNZxqmLxG2JlKvOgbgURkpKous1MoNVaIxqE(c0ECHSc14qsgofURkpK(ckTGOxG2JlKvOgbsYWjkmNePOPxqPfO94czfQXHH7QYdPdLuTPZ5liMYlq7XfYkuJad3vLhshkPAtNZxaXlipFbrVacwpMyLHyTphDcxWdjkulO0ciBbrVaThxiRqncKKHtuyojsrtVGslGSfO94czfQXHH7QYdPdLuTPZ5l41laHlOOfqW6XeRmexWdPMFSXXlipFbeSEmXkdXf8qQ5hBC8cIzbApUqwHACy4UQ8q6qjvB6C(cq0cIVaIxqE(c0ECHSc1iqsgorH5Kifn9ckTaYwG2JlKvOghsYWjkmNePOPxqPfO94czfQXHH7QYdPdLuTPZ5liMYlq7XfYkuJad3vLhshkPAtNZxqPfq2c0ECHSc14WWDv5H0HsQ2058f86fGWfu0ciy9yIvgIl4HuZp244fKNVacwpMyLH4cEi18JnoEbXSaThxiRqnomCxvEiDOKQnDoFbiAbXxaXlipFbKTGOxG2JlKvOghsYWjkmNePOPxqE(c0ECHSc1iWWDv5H0HsQ2058fet5fO94czfQXHH7QYdPdLuTPZ5lG4fuAbKTaThxiRqncmCxvEiDyZMSWckTaThxiRqncmCxvEiDOKQnDoFbVEbiCbXSacwpMyLH4cEi18JnoEbLwabRhtSYqCbpKA(XghVGIwG2JlKvOgbgURkpKous1MoNVaeTG4lipFbrVaThxiRqncmCxvEiDyZMSWckTaYwG2JlKvOgbgURkpKoS5hBC8cE9cq4ckAbeSEmXkdXAFo6eUGhsn)yJJxqPfqW6XeRmeR95Ot4cEi18JnoEbXSG4fBbLwazlq7XfYkuJdd3vLhshkPAtNZxWRxacxqrlGG1JjwziUGhsn)yJJxqE(c0ECHSc1iWWDv5H0Hn)yJJxWRxacxqrlGG1JjwziUGhsn)yJJxqPfO94czfQrGH7QYdPdLuTPZ5l41lisXwqSlGG1JjwziUGhsn)yJJxqrlGG1Jjwziw7ZrNWf8qQ5hBC8cYZxabRhtSYqCbpKA(XghVGywG2JlKvOghgURkpKous1MoNVaeTG4lipFbeSEmXkdXf8qIc1ciEb55lq7XfYkuJad3vLhsh28JnoEbVEbiCbXSacwpMyLHyTphDcxWdPMFSXXlO0ciBbApUqwHACy4UQ8q6qjvB6C(cE9cq4ckAbeSEmXkdXAFo6eUGhsn)yJJxqE(cIEbApUqwHACijdNOWCsKIMEbLwazlGG1JjwziUGhsn)yJJxqmlq7XfYkuJdd3vLhshkPAtNZxaIwq8fKNVacwpMyLH4cEirHAbeVaIxaXlG4fq8ciEb55lqTgnRqDE4KEj5WlOOfqW6XeRmexWdPMFSXXlG4fKNVGOxG2JlKvOghsYWjkmNePOPxqPfe9cchb2nxHcl0J5lO0ciBbApUqwHAeijdNOWCsKIMEbLwazlGSfe9ciy9yIvgIl4HefQfKNVaThxiRqncmCxvEiDyZp244feZcq4ciEbLwazlGG1JjwziUGhsn)yJJxqmliEXwqE(c0ECHSc1iWWDv5H0Hn)yJJxWRxacxqmlGG1JjwziUGhsn)yJJxaXlG4fKNVGOxG2JlKvOgbsYWjkmNePOPxqPfq2cIEbApUqwHAeijdNc3vLhsFb55lq7XfYkuJad3vLhsh28JnoEb55lq7XfYkuJad3vLhshkPAtNZxqmLxG2JlKvOghgURkpKous1MoNVaIxaX)mC9u8pt7XfYA8V(1FwqI)V)FjY)9Fg7MyLLFe)Zc9OCp2plCxvEiDOiJ1XQjKTPKGn)yJJxqmlGOl2pZc6C(pZ8aJ12QPGvRF9)s8)7)m2nXkl)i(Nf6r5ESFw4UQ8q6qrgRJvtiBtjbB(XghVGywarxSFMf058Fg90Sy9o5x)Vq0)3)zSBIvw(r8pl0JY9y)mYwGifnne5uLjmQPhfdPqTG88fe9cchb2nxH(GMKMOnEbLwGifnn0WO4GMo6KsItiNQesHAbLwGifnnuKX6y1eY2usqkulG4fuAbKTa6bnjn18JnoEbXSGWDv5H0HICJ5w44OHsQ2058fe7cKuTPZ5lipFbKTa1A0ScjXwvjbrf0fu0ciAeUG88fe9cuRYUcfo1k3PXX64bfYUjwz5ciEbeVG88fiEy8ckTa6bnjn18JnoEbfTGie9pZc6C(ptKBm3chh9x)Vqe(V)Zy3eRS8J4FwOhL7X(zKTarkAAiYPktyutpkgsHAb55li6feocSBUc9bnjnrB8ckTarkAAOHrXbnD0jLeNqovjKc1ckTarkAAOiJ1XQjKTPKGuOwaXlO0ciBb0dAsAQ5hBC8cIzbH7QYdPdfR3jt0uDbOKQnDoFbXUajvB6C(cYZxazlqTgnRqsSvvsqubDbfTaIgHlipFbrVa1QSRqHtTYDACSoEqHSBIvwUaIxaXlipFbIhgVGslGEqtstn)yJJxqrlicc6NzbDo)NjwVtMOP6cF9)cc)V)ZSGoN)ZQdAskorutjr)WU(Zy3eRS8J4V(Fbb9F)NXUjwz5hX)Sqpk3J9ZePOPHggfh00rNusCc5uLqkulipFb0dAsAQ5hBC8ckAbXrq)mlOZ5)muNoN)1V(ZW6)9)lr(V)Zy3eRS8J4FwOhL7X(zrVG2gzIjWUcnPedzbpyfVG88fe9cABKjMa7k0KsmKc1ckTaYwqBJmXeyxHMuIHsQ2058fe7cABKjMa7k0KsmC8fu0cIxSfKNVaYwqBJmXeyxHMuIHHJY1fuEbrwqPfeocSBUcfwOhZxaXlG4fKNVG2gzIjWUcnPedPqTGslOTrMycSRqtkXWMFSXXliMferq8ZSGoN)ZmmkoOPJoPK4eYPk)6)L4)3)zSBIvw(r8pl0JY9y)mrkAAiDZUGwasHAbLwGifnnKUzxqlaB(XghVGIkVa0b5cIDbIwlYYeM0Pj0Tf4ekUNtUG88fisrtdrovzcJA6rXqkulO0ccKSgnJt0Tf05CRUGywqeirybLwqt5m91OziDBOFyxXPJoPK4exLCNmxRCJHSBIvw(ZSGoN)ZeTwKLjmPt)6)fI()(pJDtSYYpI)zHEuUh7N1uotFnAgIpQk91O5e)iYngYUjwz5ckTa16K2gkyZp244fu0cqhKlO0cc3vLhshsxTMHn)yJJxqrlaDq(ZSGoN)ZuRtABO(6)fIW)9Fg7MyLLFe)ZSGoN)ZORwZ)Sqpk3J9ZuRtABOGuOwqPf0uotFnAgIpQk91O5e)iYngYUjwz5pRooNcYFwCe(1)li8)(pZc6C(ptSENetIL)m2nXkl)i(R)xqq)3)zSBIvw(r8pl0JY9y)SOxqBJmXeyxHMuIHSGhSIxqE(cIEbTnYetGDfAsjgsHAbLwqBJmXeyxHMuIHsQ2058fe7cABKjMa7k0KsmC8fu0cIxSfKNVG2gzIjWUcnPedPqTGslOTrMycSRqtkXWMFSXXliMferq8ZSGoN)ZqovzcJA6rXF9)cc2)9FMf058FgD1kWYeM0P)m2nXkl)i(R)xIk)V)ZSGoN)Zeo1Act60Fg7MyLLFe)1)lcI)7)m2nXkl)i(Nf6r5ESFw4UQ8q6WMXNB64Otw3hsyZp244fu0cqhKlO0ciBbrVa1QSRqwWOQhEiWjmPtHSBIvwUG88fisrtdfR3jRuyfsHAbeVG88fe9cchb2nxHcl0J5lipFbH7QYdPdBgFUPJJozDFiHn)yJJxqE(cuRrZkuNhoPxso8ckAbi8NzbDo)NH0M64Otw3hYV(FjsX(V)Zy3eRS8J4FwOhL7X(zH7QYdPdfzSownHSnLeS5hBC8ckAbrIVGI3ccKSgnJt0Tf05CRUGyxa6GCbLwGAv2vioWUMo6Ky9ojKDtSYYfKNVaAQAn1CGK1O5Kop8ckAbOdYfuAbH7QYdPdfzSownHSnLeS5hBC8cYZxGAnAwH68Wj9sYHxqrlqq8ZSGoN)ZeTwKLjmPt)6)Lir(V)Zy3eRS8J4FwOhL7X(z0xGcVGyxqWWAQz0SVGIwa9fOWWhtW)mlOZ5)mjBkPuGKjSTNV(Fjs8)7)m2nXkl)i(Nf6r5ESFMifnn0WO4GMo6KsItiNQesHAb55lqTgnRqDE4KEj5WlOOfebH)mlOZ5)mSApOyj)1)lri6)7)mlOZ5)ml9q1sUthDk0hs8pJDtSYYpI)6)LieH)7)m2nXkl)i(Nf6r5ESFgzlqKIMgkYyDSAczBkjifQfKNVa1A0Sc15Ht6LKdVGIwqKITaIxqPfq2cIEbTnYetGDfAsjgYcEWkEb55li6f02itmb2vOjLyifQfuAbKTG2gzIjWUcnPedLuTPZ5li2f02itmb2vOjLy44lOOfeVylipFbTnYetGDfAsjggokxxq5fezbeVG88f02itmb2vOjLyifQfuAbTnYetGDfAsjg28JnoEbXSGicIfq8pZc6C(pRz85Moo6K19H8R)xIGW)7)m2nXkl)i(Nf6r5ESFgzliCxvEiDiYPktyutpkg28JnoEbXSGiiCb55liCey3CfkSqpMVGslGSfeURkpKoSz85Moo6K19He28JnoEbfTaeUG88feURkpKoSz85Moo6K19He28JnoEbXSG4fBbeVG88fOwJMvOopCsVKC4fu0cIGWfKNVaYwq0liCey3Cf6dAsAI24fuAbrVGWrGDZvOWc9y(ciEbeVGslGSfe9cABKjMa7k0KsmKf8Gv8cYZxq0lOTrMycSRqtkXqkulO0ciBbTnYetGDfAsjgkPAtNZxqSlOTrMycSRqtkXWXxqrliEXwqE(cABKjMa7k0KsmmCuUUGYliYciEb55lOTrMycSRqtkXqkulO0cABKjMa7k0KsmS5hBC8cIzbreelG4FMf058FMiJ1XQjKTPK(6)LiiO)7)mlOZ5)SaP5X42sysN(Zy3eRS8J4V(Fjcc2)9FMf058FMWPwtH75XC5pJDtSYYpI)6)LirL)3)zSBIvw(r8pl0JY9y)mrkAAOiJ1XQjKTPKGYdPVG88fiEy8ckTa6bnjn18JnoEbfTae(ZSGoN)Zen0PJoP9eeI)6)LicI)7)mlOZ5)m50CsKnS(Zy3eRS8J4V(FjEX(V)Zy3eRS8J4FwOhL7X(zKTa6lqHxWRxq4W6cIDb0xGcdBgn7lO4TaYwq4UQ8q6qHtTMc3ZJ5syZp244f86fezbeVGywGf05COWPwtH75XCjmCyDb55liCxvEiDOWPwtH75XCjS5hBC8cIzbrwqSlaDqUaIxqE(ciBbIu00qrgRJvtiBtjbPqTG88fisrtdDgJhhnsRlGtABOqno6KHcL1MsHHuOwaXlO0cIEbnLZ0xJMHerdv1sCZskpH0601sUHSBIvwUG88fiEy8ckTa6bnjn18JnoEbfTaI(NzbDo)NfoX2sysN(1)lXJ8F)NXUjwz5hX)Sqpk3J9ZePOPHiNQmHrn9OyifQfKNVGajRrZ4eDBbDo3QliMfebgFbLwq4Cj1OqX6DYkR64OHSBIvw(ZSGoN)ZeTwKLjmPt)6)L4X)V)Zy3eRS8J4FwOhL7X(zIu00qrgRJvtiBtjbLhsFb55lq8W4fuAb0dAsAQ5hBC8ckAbi8NzbDo)NzDWCoHIQI5V(Fjor)F)NXUjwz5hX)Sqpk3J9ZAkNPVgndXhvL(A0CIFe5gdz3eRSCb55lOPCM(A0m0zmEC0iTUaoPTHc14OtgkuwBkfgYUjwz5pZc6C(ptToPTH6R)xIte(V)Zy3eRS8J4FwOhL7X(znLZ0xJMHoJXJJgP1fWjTnuOghDYqHYAtPWq2nXkl)zwqNZ)z0nZc64OtABO(6)L4i8)(pJDtSYYpI)zHEuUh7Nr2cOVafEbXUa6lqHHnJM9fe7cIGWfq8ckAb0xGcdFmb)ZSGoN)ZSoyoN0RB21V(1FwOYgb()()Li)3)zSBIvw(r8pl0JY9y)SOxqBJmXeyxHMuIHSGhSIxqE(cABKjMa7k0KsmS5hBC8cIP8cIuSfKNValOdboXo)mmEbXuEbTnYetGDfAsjggokxxqXBbX)zwqNZ)zggfh00rNusCc5uLF9)s8)7)m2nXkl)i(NzbDo)NjATiltysN(Zc9OCp2ptKIMgs3SlOfGuOwqPfisrtdPB2f0cWMFSXXlOOYlaDqUGyxGO1ISmHjDAcDBboHI75KlipFbIu00qKtvMWOMEumKc1ckTGajRrZ4eDBbDo3QliMfebsewqPf0uotFnAgs3g6h2vC6OtkjoXvj3jZ1k3yi7MyLL)SqHqLtQ1Ozf)FjYx)Vq0)3)zSBIvw(r8pl0JY9y)m0b5cE9cePOPHISH1uOYgbg28JnoEbXSGIbJJWFMf058F2dvvhmPt)6)fIW)9Fg7MyLLFe)Zc9OCp2pRPCM(A0me1rfiLo6uBc61j62q)WUIHSBIvwUGslqKIMgsxTcCJtpwlesH6NzbDo)NjCQ1eM0PF9)cc)V)Zy3eRS8J4FwOhL7X(znLZ0xJMHOoQaP0rNAtqVor3g6h2vmKDtSYYFMf058FgD1kWYeM0PF9)cc6)(pJDtSYYpI)zHEuUh7N1uotFnAgIpQk91O5e)iYngYUjwz5ckTa16K2gkyZp244fu0cqhKlO0cc3vLhshsxTMHn)yJJxqrlaDq(ZSGoN)ZuRtABO(6)feS)7)m2nXkl)i(Nf6r5ESFMADsBdfKc1ckTGMYz6RrZq8rvPVgnN4hrUXq2nXkl)zwqNZ)z0vR5V(FjQ8)(pJDtSYYpI)zHEuUh7NrFbk8cIDbbdRPMrZ(ckAb0xGcdFmb)ZSGoN)ZKSPKsbsMW2E(6)fbX)9Fg7MyLLFe)Zc9OCp2pl6f02itmb2vOjLyil4bR4fKNVG2gzIjWUcnPedB(XghVGykVGifBb55lWc6qGtSZpdJxqmLxqBJmXeyxHMuIHHJY1fu8wq8FMf058FgYPktyutpk(R)xIuS)7)m2nXkl)i(NzbDo)NjATiltysN(Zc9OCp2pJMQwtnhiznAoPZdVGIwa6GCbLwq4UQ8q6qrgRJvtiBtjbB(XghVG88feURkpKouKX6y1eY2usWMFSXXlOOfej(cIDbOdYfuAbQvzxH4a7A6OtI17Kq2nXkl)zHcHkNuRrZk()sKV(FjsK)7)m2nXkl)i(Nf6r5ESFw0lOTrMycSRqtkXqwWdwXlipFbTnYetGDfAsjg28JnoEbXuEbiCb55lWc6qGtSZpdJxqmLxqBJmXeyxHMuIHHJY1fu8wq8FMf058FMiJ1XQjKTPK(6)LiX)V)Zy3eRS8J4FwOhL7X(zrVG2gzIjWUcnPedzbpyfVG88f02itmb2vOjLyyZp244fet5fGWfKNValOdboXo)mmEbXuEbTnYetGDfAsjggokxxqXBbX)zwqNZ)znJp30XrNSUpKF9)seI()(pJDtSYYpI)zHEuUh7NjsrtdnmkoOPJoPK4eYPkHuOwqE(cepmEbLwa9GMKMA(XghVGIwqee(ZSGoN)ZWQ9GIL8x)VeHi8F)NzbDo)NH0M64Otw3hYFg7MyLLFe)1)lrq4)9FMf058FgD1kWYeM0P)m2nXkl)i(R)xIGG(V)ZSGoN)Zeo1Act60Fg7MyLLFe)1)lrqW(V)ZSGoN)ZcKMhJBlHjD6pJDtSYYpI)6)LirL)3)zwqNZ)zI17KysS8NXUjwz5hXF9)sebX)9FMf058FMLEOAj3PJof6dj(NXUjwz5hXF9)s8I9F)NXUjwz5hX)Sqpk3J9ZePOPH0n7cAbyZp244feZcybZbkLt68W)mlOZ5)mrRBdn)1)lXJ8F)NXUjwz5hX)Sqpk3J9ZOVafEbXSGWH1fe7cSGoNdFOQ6GjDkmCy9NzbDo)NjCQ1u4EEmx(1)lXJ)F)NXUjwz5hX)Sqpk3J9ZePOPHImwhRMq2MsckpK(cYZxG4HXlO0cOh0K0uZp244fu0cq4pZc6C(pt0qNo6K2tqi(R)xIt0)3)zwqNZ)zYP5KiBy9NXUjwz5hXF9)sCIW)9Fg7MyLLFe)ZSGoN)ZeTwKLjmPt)zHEuUh7NPwJMvOopCsVKC4fu0ceelipFbbswJMXj62c6CUvxqmlicm(ckTGW5sQrHI17Kvw1Xrdz3eRS8NfkeQCsTgnR4)lr(6)L4i8)(pJDtSYYpI)zHEuUh7NrFbkmuNhoPx6Xe8ckAbOdYfu8wq8FMf058Fw4eBlHjD6x)Vehb9F)NXUjwz5hX)Sqpk3J9ZAkNPVgndXhvL(A0CIFe5gdz3eRSCb55lOPCM(A0m0zmEC0iTUaoPTHc14OtgkuwBkfgYUjwz5pZc6C(ptToPTH6R)xIJG9F)NXUjwz5hX)Sqpk3J9ZAkNPVgndDgJhhnsRlGtABOqno6KHcL1MsHHSBIvw(ZSGoN)ZOBMf0XrN02q91)lXJk)V)Zy3eRS8J4FwOhL7X(zKTa6lqHxqSlG(cuyyZOzFbXUaIUylG4fu0cOVafg(yc(NzbDo)NzDWCoPx3SRF9RF9NrGB8C()L4flEKIfvwmIWpdP1(4OX)me8Oor1leLVevjYfSG3jXlyEqDTUa6Rxa5OAoCpIMs(cAMisnnlxa(E4fyu69yklxqGK5OzmCf4vJZlaHe5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxGPlO4wCE1cilIGjgUc8QX5fGqICbiW5e4wz5ciVPCM(A0mmkKVa9wa5nLZ0xJMHrbYUjwzj5lGSicMy4kWRgNxacIixacCobUvwUaYvRYUcJc5lqVfqUAv2vyuGSBIvws(cilIGjgUc8QX5fGGiYfGaNtGBLLlG8MYz6RrZWOq(c0BbK3uotFnAggfi7MyLLKVatxqXT48QfqwebtmCfyfabpQtu9cr5lrvICbl4Ds8cMhuxRlG(6fqU2JlKvm5lOzIi10SCb47HxGrP3JPSCbbsMJMXWvGxnoVaeerUae4CcCRSCbzZdcSaCbxnbVGI)c0BbVIYwGCim458fCO420RxaziI4fqgcfmXWvGxnoVaeerUae4CcCRSCbKR94czfgbgfYxGElGCThxiRqncmkKVaYIhrWedxbE148cqqe5cqGZjWTYYfqU2JlKvyCyuiFb6TaY1ECHSc14WOq(cilocsWedxbE148cqWiYfGaNtGBLLliBEqGfGl4Qj4fu8xGEl4vu2cKdHbpNVGdf3ME9cidreVaYqOGjgUc8QX5fGGrKlaboNa3klxa5ApUqwHrGrH8fO3cix7XfYkuJaJc5lGS4iibtmCf4vJZlabJixacCobUvwUaY1ECHScJdJc5lqVfqU2JlKvOghgfYxazXJiyIHRaRai4rDIQxikFjQsKlybVtIxW8G6ADb0xVaYdsm5lOzIi10SCb47HxGrP3JPSCbbsMJMXWvGxnoVaIMixacCobUvwUaYvRYUcJc5lqVfqUAv2vyuGSBIvws(cilIGjgUc8QX5fqeiYfGaNtGBLLlGC1QSRWOq(c0BbKRwLDfgfi7MyLLKVaYIiyIHRaRai4rDIQxikFjQsKlybVtIxW8G6ADb0xVaYXk5lOzIi10SCb47HxGrP3JPSCbbsMJMXWvGxnoVG4e5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxGPlO4wCE1cilIGjgUc8QX5feNixacCobUvwUaYrXkmkWOcies(c0BbKhvaHqYxazXfmXWvGxnoVaIMixacCobUvwUaYBkNPVgndJc5lqVfqEt5m91OzyuGSBIvws(cilIGjgUc8QX5fqeiYfGaNtGBLLlG8MYz6RrZWOq(c0BbK3uotFnAggfi7MyLLKVatxqXT48QfqwebtmCf4vJZlqqqKlaboNa3klxa5QvzxHrH8fO3cixTk7kmkq2nXkljFbKfrWedxbE148cIumICbiW5e4wz5cixTk7kmkKVa9wa5QvzxHrbYUjwzj5lGSicMy4kWRgNxq8IrKlaboNa3klxa5nLZ0xJMHrH8fO3ciVPCM(A0mmkq2nXkljFbKfrWedxbE148cIhHixacCobUvwUaYdNlPgfgfYxGElG8W5sQrHrbYUjwzj5lW0fuCloVAbKfrWedxbE148cIt0e5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxGPlO4wCE1cilIGjgUc8QX5feNOjYfGaNtGBLLlG8MYz6RrZWOq(c0BbK3uotFnAggfi7MyLLKVaYIiyIHRaVACEbXjce5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxGPlO4wCE1cilIGjgUcScGGh1jQEHO8LOkrUGf8ojEbZdQR1fqF9cipuzJat(cAMisnnlxa(E4fyu69yklxqGK5OzmCf4vJZliorUae4CcCRSCbK3uotFnAggfYxGElG8MYz6RrZWOaz3eRSK8fy6ckUfNxTaYIiyIHRaVACEbXjYfGaNtGBLLlGCuScJcmQacHKVa9wa5rfqiK8fqwCbtmCf4vJZlGOjYfGaNtGBLLlGCuScJcmQacHKVa9wa5rfqiK8fqwebtmCf4vJZlGiqKlaboNa3klxa5nLZ0xJMHrH8fO3ciVPCM(A0mmkq2nXkljFbKfrWedxbE148cqirUae4CcCRSCbK3uotFnAggfYxGElG8MYz6RrZWOaz3eRSK8fy6ckUfNxTaYIiyIHRaVACEbiiICbiW5e4wz5ciVPCM(A0mmkKVa9wa5nLZ0xJMHrbYUjwzj5lGSicMy4kWRgNxacgrUae4CcCRSCbK3uotFnAggfYxGElG8MYz6RrZWOaz3eRSK8fy6ckUfNxTaYIiyIHRaVACEbrkgrUae4CcCRSCbKRwLDfgfYxGElGC1QSRWOaz3eRSK8fy6ckUfNxTaYIiyIHRaVACEbXlgrUae4CcCRSCbKJIvyuGrfqiK8fO3cipQacHKVaYIiyIHRaVACEbXjce5cqGZjWTYYfqE4Cj1OWOq(c0BbKhoxsnkmkq2nXkljFbMUGIBX5vlGSicMy4kWRgNxqCeerUae4CcCRSCbK3uotFnAggfYxGElG8MYz6RrZWOaz3eRSK8fy6ckUfNxTaYIiyIHRaVACEbXrqe5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxazremXWvGxnoVG4iye5cqGZjWTYYfqEt5m91OzyuiFb6TaYBkNPVgndJcKDtSYsYxGPlO4wCE1cilIGjgUcScqu(G6ALLlabTalOZ5lOoyfdxb(zyuC4)sCes0)mu9rpv(Nf1IAlaXSH1fquKHvUlSab5uUY9kqulQTGxoc8Ji3licr)2cIxS4rwbwbIArTfGaKmhnJjYvGOwuBbVEbev8Rz3eR8cqS1ISCbzKoDbr12c8cikW9Cs4kWkGf05CmevZH7r00YyQNNZtOyDfWc6CogIQ5W9iAASLrK4PALLj6QvGLihhDspbp(kGf05CmevZH7r00ylJi6kJjfAJwxbSGoNJHOAoCpIMgBzerH50O8ZBU9WLnbftYAdNOpxthDc1HK7valOZ5yiQMd3JOPXwgrQ1jTnuVHQ5GH1KopC5iqe(2qxUPCM(A0meFuv6RrZj(rKBCEEt5m91OzOZy84OrADbCsBdfQXrNmuOS2uk8kGf05CmevZH7r00ylJirgRJvtiBtj9gQMdgwt68WLJar4BdD5OvRYUcXb210rNeR3jlfDt5m91Ozi(OQ0xJMt8Ji34vGO2cI6sIAkSIxGsIxGKQnDoFbMlxq4UQ8q6l4OxquhJId6co6fOK4fGGpv5cmxUaIc98y1fqu6yD8GIxGyHfOK4fiPAtNZxWrVaZxaLtYWklxqufbeKwassSVaLexG8MxafMLlavZH7r0u4cqmhmkmVGOogfh0fC0lqjXlabFQYf0SKkW4fevrabPfiwybXlwXEWVTaL0GxWGxqeirVamhoxIHRawqNZXqunhUhrtJTmImmkoOPJoPK4eYPkFdvZbdRjDE4YrGe9BdD5OnbL7rziQEESAACSoEqXq2nXkllfnJXShyiJXSh40rNusCI(cu4XrNMEWWhJO(6sKXerQbfkwcnbftYAdNOpxthDc1HK788OzIi1GcflHHcH6P95tijwnSs8kquBbrDjrnfwXlqjXlqs1MoNVaZLliCxvEi9fC0laXmwhRUae82uslWC5ceKBckVGJEbevgAEbIfwGsIxGKQnDoFbh9cmFbuojdRSCbrveqqAbijX(cusCbYBEbuywUaunhUhrtHRawqNZXqunhUhrtJTmIezSownHSnL0BOAoyynPZdxoceHVn0LnbL7rziQEESAACSoEqXq2nXkllfnJXShyiJXSh40rNusCI(cu4XrNMEWWhJO(6sKXerQbfkwcnbftYAdNOpxthDc1HK788OzIi1GcflHHcH6P95tijwnSs8kWkGf05CCSLru4OCL7eM0PRarTfevVfyKytUaZLl492CIi1uhbLxWlefqGfWo)mmMO4fGKxG8CY1fiVfOKg8cOVEbOQwbUXlqKdgfMxWOKlxGiVa9UfGrzppfwG5YfGKxqWCY1f0SjNAHf8EBorCbyuCyONWcePOPXWvalOZ54ylJiTnNisn1rqhhDct603g6YrRwJMv4GtOQwbUxbIArTfiiXvRWcOTW4OxqHJQxG8Oe1fq56uxqHJAbKmc8cqrPlGOIXNB64OxquV7d5cKhs)TfC9cg6fOK4feURkpK(cg8c07wq9C0lqVfi5Qvyb0wyC0lOWr1lqq6Oev4cikPxGFoVGJEbkjgZliCUC05C8cSMxGjw5fO3cEyDbihL04lqjXlisXwaMdNlXlOYmsRWBlqjXlapplG2cmEbfoQEbcshLOUaJsVhtNGvRfGRarTO2cSGoNJJTmICgj9r5YuZ4RsGFBOlJpQQ44sOZiPpkxMAgFvcCjYePOPHnJp30XrNSUpKqku55H7QYdPdBgFUPJJozDFiHn)yJJJjsXYZvRrZkuNhoPxsoCrrqqeVcybDohhBzefSAnzbDopvhS(MBpCzThxiR43WApbTCK3g6YHJa7MRqHf6X8sH7QYdPdnmkoOPJoPK4eYPkHn)yJJlfURkpKoSz85Moo6K19He28Jnoopp6WrGDZvOWc9yEPWDv5H0Hggfh00rNusCc5uLWMFSXXRawqNZXXwgrbRwtwqNZt1bRV52dxoiXRawqNZXXwgrbRwtwqNZt1bRV52dxgRVH1EcA5iVn0LTGoe4e78ZW4IIVcybDohhBzefSAnzbDopvhS(MBpC5qLnc8ByTNGwoYBdDzlOdboXo)mmoMiRaRawqNZXWGex28aJ12QPGvRVn0Ld3vLhshkYyDSAczBkjyZp244yi6ITcybDohddsCSLre90Sy9o5BdD5WDv5H0HImwhRMq2Msc28JnoogIUyRawqNZXWGehBzejYnMBHJJ(THUmzIu00qKtvMWOMEumKcvEE0HJa7MRqFqtst0gxsKIMgAyuCqthDsjXjKtvcPqvsKIMgkYyDSAczBkjifkIlrg9GMKMA(Xghht4UQ8q6qrUXClCC0qjvB6CESsQ20588CYuRrZkKeBvLeevqlIOryEE0QvzxHcNAL704yD8GsmX55IhgxIEqtstn)yJJlkcrVcybDohddsCSLrKy9ozIMQl82qxMmrkAAiYPktyutpkgsHkpp6WrGDZvOpOjPjAJljsrtdnmkoOPJoPK4eYPkHuOkjsrtdfzSownHSnLeKcfXLiJEqtstn)yJJJjCxvEiDOy9ozIMQlaLuTPZ5XkPAtNZZZjtTgnRqsSvvsqubTiIgH55rRwLDfkCQvUtJJ1XdkXeNNlEyCj6bnjn18JnoUOiiOvalOZ5yyqIJTmIQdAskorutjr)WUUcybDohddsCSLreQtNZFBOllsrtdnmkoOPJoPK4eYPkHuOYZPh0K0uZp244IIJGwbwbSGoNJHHkBe4Yggfh00rNusCc5uLVn0LJUTrMycSRqtkXqwWdwX55TnYetGDfAsjg28JnooMYrkwEUf0HaNyNFgght52gzIjWUcnPeddhLRfV4RawqNZXWqLncCSLrKO1ISmHjD6BHcHkNuRrZkUCK3g6YOyf(yJdfPOPH0n7cAbifQsOyf(yJdfPOPH0n7cAbyZp244IkJoiJv0ArwMWKonHUTaNqX9CY8CrkAAiYPktyutpkgsHQuGK1OzCIUTGoNB1yIajcLAkNPVgndPBd9d7koD0jLeN4QK7K5ALB8kGf05CmmuzJahBze9qv1bt603g6YOdYxJIv4JnouKIMgkYgwtHkBeyyZp244ykgmocxbSGoNJHHkBe4ylJiHtTMWKo9THUCt5m91OziQJkqkD0P2e0Rt0TH(HDfxsKIMgsxTcCJtpwlesHAfWc6CoggQSrGJTmIORwbwMWKo9THUCt5m91OziQJkqkD0P2e0Rt0TH(HDfVcybDohddv2iWXwgrQ1jTnuVn0LBkNPVgndXhvL(A0CIFe5gxsToPTHc28JnoUi0bzPWDv5H0H0vRzyZp244IqhKRawqNZXWqLncCSLreD1A(THUSADsBdfKcvPMYz6RrZq8rvPVgnN4hrUXRawqNZXWqLncCSLrKKnLukqYe22ZBdDz6lqHJnyyn1mA2lI(cuy4Jj4valOZ5yyOYgbo2Yic5uLjmQPhf)2qxo62gzIjWUcnPedzbpyfNN32itmb2vOjLyyZp244ykhPy55wqhcCID(zyCmLBBKjMa7k0KsmmCuUw8IVcybDohddv2iWXwgrIwlYYeM0PVfkeQCsTgnR4YrEBOlttvRPMdKSgnN05HlcDqwkCxvEiDOiJ1XQjKTPKGn)yJJZZd3vLhshkYyDSAczBkjyZp244IIepw0bzj1QSRqCGDnD0jX6DYvalOZ5yyOYgbo2YisKX6y1eY2usVn0LJUTrMycSRqtkXqwWdwX55TnYetGDfAsjg28JnooMYimp3c6qGtSZpdJJPCBJmXeyxHMuIHHJY1Ix8valOZ5yyOYgbo2YiQz85Moo6K19H8THUC0TnYetGDfAsjgYcEWkopVTrMycSRqtkXWMFSXXXugH55wqhcCID(zyCmLBBKjMa7k0KsmmCuUw8IVcybDohddv2iWXwgry1EqXs(THUSifnn0WO4GMo6KsItiNQesHkpx8W4s0dAsAQ5hBCCrrq4kGf05CmmuzJahBzeH0M64Otw3hYvalOZ5yyOYgbo2YiIUAfyzct60valOZ5yyOYgbo2Yis4uRjmPtxbSGoNJHHkBe4ylJOaP5X42sysNUcybDohddv2iWXwgrI17KysSCfWc6CoggQSrGJTmIS0dvl5oD0PqFiXRawqNZXWqLncCSLrKO1THMFBOlJIv4JnouKIMgs3SlOfGn)yJJJHfmhOuoPZdVcybDohddv2iWXwgrcNAnfUNhZLVn0LPVafoMWH1yTGoNdFOQ6GjDkmCyDfWc6CoggQSrGJTmIen0PJoP9eeIFBOllsrtdfzSownHSnLeuEi98CXdJlrpOjPPMFSXXfHWvalOZ5yyOYgbo2YisonNezdRRawqNZXWqLncCSLrKO1ISmHjD6BHcHkNuRrZkUCK3g6YQ1OzfQZdN0ljhUibrEEGK1OzCIUTGoNB1yIaJxkCUKAuOy9ozLvDC0RawqNZXWqLncCSLru4eBlHjD6BdDz6lqHH68Wj9spMGlcDqw8IVcybDohddv2iWXwgrQ1jTnuVn0LBkNPVgndXhvL(A0CIFe5gNN3uotFnAg6mgpoAKwxaN02qHAC0jdfkRnLcVcybDohddv2iWXwgr0nZc64OtABOEBOl3uotFnAg6mgpoAKwxaN02qHAC0jdfkRnLcVcybDohddv2iWXwgrwhmNt61n76BdDzYOVafow6lqHHnJM9yj6IrCr0xGcdFmbVcScybDohdXAzdJIdA6OtkjoHCQY3g6Yr32itmb2vOjLyil4bR488OBBKjMa7k0KsmKcvjYABKjMa7k0Ksmus1MoNhBBJmXeyxHMuIHJxu8ILNtwBJmXeyxHMuIHHJY1YrkfocSBUcfwOhZjM4882gzIjWUcnPedPqvQTrMycSRqtkXWMFSXXXerqScybDohdXASLrKO1ISmHjD6BdDzuScFSXHIu00q6MDbTaKcvjuScFSXHIu00q6MDbTaS5hBCCrLrhKXkATiltysNMq3wGtO4EozEUifnne5uLjmQPhfdPqvkqYA0mor3wqNZTAmrGeHsnLZ0xJMH0TH(HDfNo6KsItCvYDYCTYnEfWc6CogI1ylJi16K2gQ3g6YnLZ0xJMH4JQsFnAoXpICJlPwN02qbB(Xghxe6GSu4UQ8q6q6Q1mS5hBCCrOdYvalOZ5yiwJTmIORwZVvhNtbz54i8THUSADsBdfKcvPMYz6RrZq8rvPVgnN4hrUXRawqNZXqSgBzejwVtIjXYvalOZ5yiwJTmIqovzcJA6rXVn0LJUTrMycSRqtkXqwWdwX55r32itmb2vOjLyifQsTnYetGDfAsjgkPAtNZJTTrMycSRqtkXWXlkEXYZBBKjMa7k0KsmKcvP2gzIjWUcnPedB(XghhtebXkGf05CmeRXwgr0vRaltysNUcybDohdXASLrKWPwtysNUcybDohdXASLresBQJJozDFiFBOlhURkpKoSz85Moo6K19He28JnoUi0bzjYIwTk7kKfmQ6HhcCct608CrkAAOy9ozLcRqkueNNhD4iWU5kuyHEmpppCxvEiDyZ4ZnDC0jR7djS5hBCCEUAnAwH68Wj9sYHlcHRawqNZXqSgBzejATiltysN(2qxoCxvEiDOiJ1XQjKTPKGn)yJJlks8IxGK1OzCIUTGoNB1yrhKLuRYUcXb210rNeR3jZZPPQ1uZbswJMt68WfHoilfURkpKouKX6y1eY2usWMFSXX55Q1OzfQZdN0ljhUibXkGf05CmeRXwgrs2usPajtyBpVn0LPVafo2GH1uZOzVi6lqHHpMGxbSGoNJHyn2YicR2dkwYVn0LfPOPHggfh00rNusCc5uLqku55Q1OzfQZdN0ljhUOiiCfWc6CogI1ylJil9q1sUthDk0hs8kGf05CmeRXwgrnJp30XrNSUpKVn0LjtKIMgkYyDSAczBkjifQ8C1A0Sc15Ht6LKdxuKIrCjYIUTrMycSRqtkXqwWdwX55r32itmb2vOjLyifQsK12itmb2vOjLyOKQnDop22gzIjWUcnPedhVO4flpVTrMycSRqtkXWWr5A5ieNN32itmb2vOjLyifQsTnYetGDfAsjg28JnooMiccIxbSGoNJHyn2YisKX6y1eY2usVn0LjlCxvEiDiYPktyutpkg28JnooMiimppCey3CfkSqpMxISWDv5H0HnJp30XrNSUpKWMFSXXfHW88WDv5H0HnJp30XrNSUpKWMFSXXXeVyeNNRwJMvOopCsVKC4IIGW8CYIoCey3Cf6dAsAI24srhocSBUcfwOhZjM4sKfDBJmXeyxHMuIHSGhSIZZJUTrMycSRqtkXqkuLiRTrMycSRqtkXqjvB6CESTnYetGDfAsjgoErXlwEEBJmXeyxHMuIHHJY1YriopVTrMycSRqtkXqkuLABKjMa7k0KsmS5hBCCmreeeVcybDohdXASLruG08yCBjmPtxbSGoNJHyn2Yis4uRPW98yUCfWc6CogI1ylJirdD6OtApbH43g6YIu00qrgRJvtiBtjbLhsppx8W4s0dAsAQ5hBCCriCfWc6CogI1ylJi50CsKnSUcybDohdXASLru4eBlHjD6BdDzYOVaf(1HdRXsFbkmSz0Sx8ilCxvEiDOWPwtH75XCjS5hBC8RJqCmwqNZHcNAnfUNhZLWWH188WDv5H0HcNAnfUNhZLWMFSXXXejw0bjX55KjsrtdfzSownHSnLeKcvEUifnn0zmEC0iTUaoPTHc14OtgkuwBkfgsHI4sr3uotFnAgsenuvlXnlP8esRtxl5opx8W4s0dAsAQ5hBCCre9kGf05CmeRXwgrIwlYYeM0PVn0LfPOPHiNQmHrn9OyifQ88ajRrZ4eDBbDo3QXebgVu4Cj1OqX6DYkR64OxbSGoNJHyn2YiY6G5CcfvfZVn0LfPOPHImwhRMq2MsckpKEEU4HXLOh0K0uZp244Iq4kGf05CmeRXwgrQ1jTnuVn0LBkNPVgndXhvL(A0CIFe5gNN3uotFnAg6mgpoAKwxaN02qHAC0jdfkRnLcVcybDohdXASLreDZSGoo6K2gQ3g6YnLZ0xJMHoJXJJgP1fWjTnuOghDYqHYAtPWRawqNZXqSgBzezDWCoPx3SRVn0LjJ(cu4yPVafg2mA2JnccjUi6lqHHpMGxbwbSGoNJHApUqwXLjy9yIv(n3E4Y4cEirH6ncwLIllsrtdBgFUPJJozDFiHuOYZfPOPHggfh00rNusCc5uLqkuRawqNZXqThxiR4ylJicwpMyLFZThUmw7ZrNWf8qIc1BeSkfxoCey3CfkSqpMxsKIMg2m(CthhDY6(qcPqvsKIMgAyuCqthDsjXjKtvcPqLNhD4iWU5kuyHEmVKifnn0WO4GMo6KsItiNQesHAfWc6CogQ94czfhBzerW6XeR8BU9WLXAFo6eUGhsn)yJJF7qvgZ6q)w4C5OZ5Ldhb2nxHcl0J5VrWQuC5WDv5H0HnJp30XrNSUpKWMFSXXfjilCxvEiDOHrXbnD0jLeNqovjS5hBC8BeSkfN4kMlhURkpKo0WO4GMo6KsItiNQe28Jno(THUSifnn0WO4GMo6KsItiNQekpK(kGf05Cmu7XfYko2YiIG1Jjw53C7HlJ1(C0jCbpKA(Xgh)2HQmM1H(TW5YrNZlhocSBUcfwOhZFJGvP4YH7QYdPdBgFUPJJozDFiHn)yJJFJGvP4exXC5WDv5H0Hggfh00rNusCc5uLWMFSXXVn0LfPOPHggfh00rNusCc5uLqkuRawqNZXqThxiR4ylJicwpMyLFZThUmUGhsn)yJJF7qvgZ6q)w4C5OZ5Ldhb2nxHcl0J5VrWQuC5WDv5H0HnJp30XrNSUpKWMFSXXXiilCxvEiDOHrXbnD0jLeNqovjS5hBC8BeSkfN4kMlhURkpKo0WO4GMo6KsItiNQe28JnoEfWc6CogQ94czfhBzerH50O8d(nC9uCzThxiRrEBOltM2JlKvyeijdNOWCsKIMoppCey3CfkSqpMxs7XfYkmcKKHtH7QYdPtCjYiy9yIvgI1(C0jCbpKOqvISOdhb2nxHcl0J5LIw7XfYkmoKKHtuyojsrtNNhocSBUcfwOhZlfT2JlKvyCijdNc3vLhsppx7XfYkmomCxvEiDyZp2448CThxiRWiqsgorH5KifnDjYIw7XfYkmoKKHtuyojsrtNNR94czfgbgURkpKous1MoNhtzThxiRW4WWDv5H0HsQ205CIZZ1ECHScJajz4u4UQ8q6LIw7XfYkmoKKHtuyojsrtxs7XfYkmcmCxvEiDOKQnDopMYApUqwHXHH7QYdPdLuTPZ5eNNhnbRhtSYqS2NJoHl4HefQsKfT2JlKvyCijdNOWCsKIMUezApUqwHrGH7QYdPdLuTPZ5VgHfrW6XeRmexWdPMFSXX55eSEmXkdXf8qQ5hBCCmApUqwHrGH7QYdPdLuTPZ5f)4eNNR94czfghsYWjkmNePOPlrM2JlKvyeijdNOWCsKIMUK2JlKvyey4UQ8q6qjvB6CEmL1ECHScJdd3vLhshkPAtNZlrM2JlKvyey4UQ8q6qjvB6C(RryreSEmXkdXf8qQ5hBCCEobRhtSYqCbpKA(XghhJ2JlKvyey4UQ8q6qjvB6CEXpoX55KfT2JlKvyeijdNOWCsKIMopx7XfYkmomCxvEiDOKQnDopMYApUqwHrGH7QYdPdLuTPZ5exImThxiRW4WWDv5H0HnBYcL0ECHScJdd3vLhshkPAtNZFncJHG1JjwziUGhsn)yJJlrW6XeRmexWdPMFSXXfP94czfghgURkpKous1MoNx8JNNhT2JlKvyCy4UQ8q6WMnzHsKP94czfghgURkpKoS5hBC8RryreSEmXkdXAFo6eUGhsn)yJJlrW6XeRmeR95Ot4cEi18JnooM4fRezApUqwHrGH7QYdPdLuTPZ5VgHfrW6XeRmexWdPMFSXX55ApUqwHXHH7QYdPdB(Xgh)AewebRhtSYqCbpKA(Xghxs7XfYkmomCxvEiDOKQnDo)1rkwSeSEmXkdXf8qQ5hBCCreSEmXkdXAFo6eUGhsn)yJJZZjy9yIvgIl4HuZp244y0ECHScJad3vLhshkPAtNZl(XZZjy9yIvgIl4HefkIZZ1ECHScJdd3vLhsh28Jno(1imgcwpMyLHyTphDcxWdPMFSXXLit7XfYkmcmCxvEiDOKQnDo)1iSicwpMyLHyTphDcxWdPMFSXX55rR94czfgbsYWjkmNePOPlrgbRhtSYqCbpKA(XghhJ2JlKvyey4UQ8q6qjvB6CEXpEEobRhtSYqCbpKOqrmXetmXeNNRwJMvOopCsVKC4Iiy9yIvgIl4HuZp24yIZZJw7XfYkmcKKHtuyojsrtxk6WrGDZvOWc9yEjY0ECHScJdjz4efMtIu00LiJSOjy9yIvgIl4HefQ8CThxiRW4WWDv5H0Hn)yJJJbHexImcwpMyLH4cEi18JnooM4flpx7XfYkmomCxvEiDyZp244xJWyiy9yIvgIl4HuZp24yIjoppAThxiRW4qsgorH5KifnDjYIw7XfYkmoKKHtH7QYdPNNR94czfghgURkpKoS5hBCCEU2JlKvyCy4UQ8q6qjvB6CEmL1ECHScJad3vLhshkPAtNZjM4valOZ5yO2JlKvCSLrefMtJYp43W1tXL1ECHSg)THUmzApUqwHXHKmCIcZjrkA688WrGDZvOWc9yEjThxiRW4qsgofURkpKoXLiJG1Jjwziw7ZrNWf8qIcvjYIoCey3CfkSqpMxkAThxiRWiqsgorH5KifnDEE4iWU5kuyHEmVu0ApUqwHrGKmCkCxvEi98CThxiRWiWWDv5H0Hn)yJJZZ1ECHScJdjz4efMtIu00LilAThxiRWiqsgorH5KifnDEU2JlKvyCy4UQ8q6qjvB6CEmL1ECHScJad3vLhshkPAtNZjopx7XfYkmoKKHtH7QYdPxkAThxiRWiqsgorH5KifnDjThxiRW4WWDv5H0HsQ2058ykR94czfgbgURkpKous1MoNtCEE0eSEmXkdXAFo6eUGhsuOkrw0ApUqwHrGKmCIcZjrkA6sKP94czfghgURkpKous1MoN)AewebRhtSYqCbpKA(XghNNtW6XeRmexWdPMFSXXXO94czfghgURkpKous1MoNx8JtCEU2JlKvyeijdNOWCsKIMUezApUqwHXHKmCIcZjrkA6sApUqwHXHH7QYdPdLuTPZ5Xuw7XfYkmcmCxvEiDOKQnDoVezApUqwHXHH7QYdPdLuTPZ5VgHfrW6XeRmexWdPMFSXX55eSEmXkdXf8qQ5hBCCmApUqwHXHH7QYdPdLuTPZ5f)4eNNtw0ApUqwHXHKmCIcZjrkA68CThxiRWiWWDv5H0HsQ2058ykR94czfghgURkpKous1MoNtCjY0ECHScJad3vLhsh2Sjlus7XfYkmcmCxvEiDOKQnDo)1imgcwpMyLH4cEi18JnoUebRhtSYqCbpKA(XghxK2JlKvyey4UQ8q6qjvB6CEXpEEE0ApUqwHrGH7QYdPdB2KfkrM2JlKvyey4UQ8q6WMFSXXVgHfrW6XeRmeR95Ot4cEi18JnoUebRhtSYqS2NJoHl4HuZp244yIxSsKP94czfghgURkpKous1MoN)AewebRhtSYqCbpKA(XghNNR94czfgbgURkpKoS5hBC8RryreSEmXkdXf8qQ5hBCCjThxiRWiWWDv5H0HsQ2058xhPyXsW6XeRmexWdPMFSXXfrW6XeRmeR95Ot4cEi18JnoopNG1JjwziUGhsn)yJJJr7XfYkmomCxvEiDOKQnDoV4hppNG1JjwziUGhsuOiopx7XfYkmcmCxvEiDyZp244xJWyiy9yIvgI1(C0jCbpKA(XghxImThxiRW4WWDv5H0HsQ2058xJWIiy9yIvgI1(C0jCbpKA(XghNNhT2JlKvyCijdNOWCsKIMUezeSEmXkdXf8qQ5hBCCmApUqwHXHH7QYdPdLuTPZ5f)455eSEmXkdXf8qIcfXetmXetCEUAnAwH68Wj9sYHlIG1JjwziUGhsn)yJJjoppAThxiRW4qsgorH5KifnDPOdhb2nxHcl0J5Lit7XfYkmcKKHtuyojsrtxImYIMG1JjwziUGhsuOYZ1ECHScJad3vLhsh28JnoogesCjYiy9yIvgIl4HuZp244yIxS8CThxiRWiWWDv5H0Hn)yJJFncJHG1JjwziUGhsn)yJJjM488O1ECHScJajz4efMtIu00LilAThxiRWiqsgofURkpKEEU2JlKvyey4UQ8q6WMFSXX55ApUqwHrGH7QYdPdLuTPZ5Xuw7XfYkmomCxvEiDOKQnDoNyI)6x)F]] )

end
