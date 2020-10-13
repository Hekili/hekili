-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID


-- Conduits
-- [-] carnivorous_instinct
-- [-] incessant_hunter
-- [x] sudden_ambush
-- [ ] taste_for_blood


if UnitClassBase( "player" ) == "DRUID" then
    local spec = Hekili:NewSpecialization( 103 )

    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )

    spec:RegisterResource( Enum.PowerType.Rage )
    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        predator = 22363, -- 202021
        sabertooth = 22364, -- 202031
        lunar_inspiration = 22365, -- 155580

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        guardian_affinity = 22158, -- 217615
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 21708, -- 158476
        savage_roar = 18579, -- 52610
        incarnation = 21704, -- 102543

        scent_of_blood = 21714, -- 285564
        brutal_slash = 21711, -- 202028
        primal_wrath = 22370, -- 285381

        moment_of_clarity = 21646, -- 236068
        bloodtalons = 21649, -- 155672
        feral_frenzy = 21653, -- 274837
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        adaptation = 3432, -- 214027
        relentless = 3433, -- 196029
        gladiators_medallion = 3431, -- 208683

        earthen_grasp = 202, -- 236023
        enraged_maim = 604, -- 236026
        ferocious_wound = 611, -- 236020
        freedom_of_the_herd = 203, -- 213200
        fresh_wound = 612, -- 203224
        heart_of_the_wild = 3053, -- 236019
        king_of_the_jungle = 602, -- 203052
        leader_of_the_pack = 3751, -- 202626
        malornes_swiftness = 601, -- 236012
        protector_of_the_grove = 847, -- 209730
        rip_and_tear = 620, -- 203242
        savage_momentum = 820, -- 205673
        thorns = 201, -- 236696
    } )


    local mod_circle_hot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.85 * x ) or x
    end, state )

    local mod_circle_dot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.75 * x ) or x
    end, state )


    -- Auras
    spec:RegisterAuras( {
        adaptive_swarm_dot = {
            id = 325733,
            duration = function () return mod_circle_dot( 12 ) end,
            max_stack = 1,
            copy = "adaptive_swarm_damage"
        },
        adaptive_swarm_hot = {
            id = 325748,
            duration = function () return mod_circle_hot( 12 ) end,
            max_stack = 1,
            copy = "adaptive_swarm_heal"
        },
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        berserk = {
            id = 106951,
            duration = 20,
            max_stack = 1,
            copy = { 279526, "berserk_cat" },
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        bloodtalons = {
            id = 145152,
            max_stack = 2,
            duration = 30,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        clearcasting = {
            id = 135700,
            duration = 15,
            max_stack = function() return talent.moment_of_clarity.enabled and 2 or 1 end,
        },
        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
        },
        --[[ Inherit from Balance to support empowerment.
        eclipse_lunar = {
            id = 48518,
            duration = 10,
            max_stack = 1,
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
            max_stack = 1,
        }, ]]
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
        },
        feline_swiftness = {
            id = 131768,
        },
        feral_frenzy = {
            id = 274837,
            duration = 6,
            max_stack = 1,
        },
        feral_instinct = {
            id = 16949,
        },
        flight_form = {
            id = 276029,
        },
        frenzied_regeneration = {
            id = 22842,
        },
        heart_of_the_wild = {
            id = 108291,
            duration = 45,
            max_stack = 1,
            copy = { 108292, 108293, 108294 }
        },
        hibernate = {
            id = 2637,
            duration = 40,
        },
        incarnation = {
            id = 102543,
            duration = 30,
            max_stack = 1,
        },
        infected_wounds = {
            id = 48484,
            duration = 12,
            type = "Disease",
            max_stack = 1,
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = function () return talent.guardian_affinity.enabled and 2 or 1 end
        },
        jungle_stalker = {
            id = 252071,
            duration = 30,
            max_stack = 1,
        },
        maim = {
            id = 22570,
            duration = 5,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 4,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonfire_cat = {
            id = 155625,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function() return mod_circle_dot( 2 ) * haste end,
            max_stack = 1,
        },
        moonkin_form = {
            id = 197625,
            duration = 3600,
            max_stack = 1,
        },
        omen_of_clarity = {
            id = 16864,
            duration = 16,
            max_stack = function () return talent.moment_of_clarity.enabled and 2 or 1 end,
        },
        predatory_swiftness = {
            id = 69369,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        primal_fury = {
            id = 159286,
        },
        prowl_base = {
            id = 5215,
            duration = 3600,
        },
        prowl_incarnation = {
            id = 102547,
            duration = 3600,
        },
        prowl = {
            alias = { "prowl_base", "prowl_incarnation" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
        },
        rake = {
            id = 155722,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function() return mod_circle_dot( 3 ) * haste end,
        },
        ravenous_frenzy = {
            id = 323546,
            duration = 20,
            max_stack = 20,
        },
        ravenous_frenzy_stun = {
            id = 323557,
            duration = 1,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        rip = {
            id = 1079,
            duration = function () return mod_circle_dot( 24 ) end,
            tick_time = function() return mod_circle_dot( 2 ) * haste end,
        },
        savage_roar = {
            id = 52610,
            duration = 36,
            max_stack = 1,
        },
        scent_of_blood = {
            id = 285646,
            duration = 6,
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
        },
        stampeding_roar = {
            id = 77764,
            duration = 8,
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = function () return mod_circle_dot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        survival_instincts = {
            id = 61336,
            duration = 6,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = function () return mod_circle_dot( 15 ) end,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function() return mod_circle_dot( 3 ) * haste end,
        },
        thick_hide = {
            id = 16931,
        },
        tiger_dash = {
            id = 252216,
            duration = 5,
        },
        tigers_fury = {
            id = 5217,
            duration = function()
                local x = 10 -- Base Duration
                if talent.predator.enabled then return x + 5 end
                return x
            end,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
            duration = 3600,
            max_stack = 1
        },


        -- PvP Talents
        ferocious_wound = {
            id = 236021,
            duration = 30,
            max_stack = 2,
        },

        king_of_the_jungle = {
            id = 203059,
            duration = 24,
            max_stack = 3,
        },

        leader_of_the_pack = {
            id = 202636,
            duration = 3600,
            max_stack = 1,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        iron_jaws = {
            id = 276026,
            duration = 30,
            max_stack = 1,
        },

        jungle_fury = {
            id = 274426,
            duration = function () return talent.predator.enabled and 17 or 12 end,
            max_stack = 1,
        },


        -- Legendaries
        apex_predators_craving = {
            id = 339140,
            duration = 15,
            max_stack = 1,
        },

        eye_of_fearful_symmetry = {
            id = 339142,
            duration = 15,
            max_stack = 1,
        },


        -- Conduits
        sudden_ambush = {
            id = 340698,
            duration = 15,
            max_stack = 1
        }
    } )


    -- Snapshotting
    local tf_spells = { rake = true, rip = true, thrash_cat = true, moonfire_cat = true, primal_wrath = true }
    local bt_spells = { rip = true }
    local mc_spells = { thrash_cat = true }
    local pr_spells = { rake = true }

    local snapshot_value = {
        tigers_fury = 1.15,
        bloodtalons = 1.3,
        clearcasting = 1.15, -- TODO: Only if talented MoC, not used by 8.1 script
        prowling = 1.6
    }

    local stealth_dropped = 0

    local function calculate_multiplier( spellID )
        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, "PLAYER" ) and snapshot_value.tigers_fury or 1
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, "PLAYER" ) and snapshot_value.bloodtalons or 1
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, "PLAYER" ) and state.talent.moment_of_clarity.enabled and snapshot_value.clearcasting or 1
        local prowling = ( GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, "PLAYER" ) or FindUnitBuffByID( "player", class.auras.berserk.id, "PLAYER" ) ) and snapshot_value.prowling or 1

        if spellID == 155722 then
            return 1 * bloodtalons * tigers_fury * prowling

        elseif spellID == 1079 or spellID == 285381 then
            return 1 * bloodtalons * tigers_fury

        elseif spellID == 106830 then
            return 1 * bloodtalons * tigers_fury * clearcasting

        elseif spellID == 155625 then
            return 1 * tigers_fury

        end

        return 1
    end

    spec:RegisterStateExpr( "persistent_multiplier", function ()
        local mult = 1

        if not this_action then return mult end

        if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * snapshot_value.tigers_fury end
        if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * snapshot_value.bloodtalons end
        if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * snapshot_value.clearcasting end
        if pr_spells[ this_action ] and ( buff.incarnation.up or buff.berserk.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * snapshot_value.prowling end

        return mult
    end )


    local snapshots = {
        [155722] = true,
        [1079]   = true,
        [106830] = true,
        [155625] = true
    }


    -- Tweaking for new Feral APL.
    local rip_applied = false

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        rip_applied = false
    end )

    spec:RegisterStateExpr( "opener_done", function ()
        return rip_applied
    end )


    local last_bloodtalons_proc = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
                    stealth_dropped = GetTime()
                end
            elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
                if snapshots[ spellID ] then
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )
                elseif spellID == 145152 then -- Bloodtalons
                    last_bloodtalons_proc = GetTime()
                end
            elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id or spellID == class.abilities.ferocious_bite.id or spellID == class.abilities.maim.id or spellID == class.abilities.savage_roar.id ) then
                rip_applied = true
            end
        end
    end )


    spec:RegisterStateExpr( "last_bloodtalons", function ()
        return last_bloodtalons_proc
    end )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )

        if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    local affinities = {
        bear_form = "guardian_affinity",
        cat_form = "feral_affinity",
        moonkin_form = "balance_affinity",
    }

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent[ affinities[ form ] ].enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end

        if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
            addStack( "ravenous_frenzy", nil, 1 )
        end
    end )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )

    spec:RegisterHook( "reset_precast", function ()
        if buff.cat_form.down then
            energy.regen = 10 + ( stat.haste * 10 )
        end
        debuff.rip.pmultiplier = nil
        debuff.rake.pmultiplier = nil
        debuff.thrash.pmultiplier = nil

        -- Eclipses
        solar_eclipse = buff.eclipse_lunar.up and 2 or GetSpellCount( 197628 )
        lunar_eclipse = buff.eclipse_solar.up and 2 or GetSpellCount( 5176 )

        opener_done = nil
        last_bloodtalons = nil
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
            if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
            else gainChargeTime( "berserk", 0.3 ) end
        end
    end )


    local function comboSpender( a, r )
        if r == "combo_points" and a > 0 then
            if talent.soul_of_the_forest.enabled then
                gain( a * 5, "energy" )
            end

            if buff.berserk.up or buff.incarnation.up and a > 4 then
                gain( level > 57 and 2 or 1, "combo_points" )
            end

            if legendary.frenzyband.enabled then
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", 0.2 )
            end

            if a >= 5 then
                applyBuff( "predatory_swiftness" )
            end
        end
    end

    spec:RegisterHook( "spend", comboSpender )


    local combo_generators = {
        brutal_slash = true,
        feral_frenzy = true,
        moonfire_cat = true,  -- technically only true with lunar_inspiration, but if you press moonfire w/o lunar inspiration you are weird.
        rake         = true,
        shred        = true,
        swipe_cat    = true,
        thrash_cat   = true
    }

    spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end
        if query_time - action[ this_action ].lastCast < 4 then return false end

        local btCount = 0

        for k, v in pairs( combo_generators ) do
            if k ~= this_action then
                local lastCast = action[ k ].lastCast

                if lastCast > last_bloodtalons and query_time - lastCast < 5 then
                    btCount = btCount + 1
                end
            end

            if btCount > 1 then return true end
        end

        return false
    end )

    spec:RegisterStateFunction( "proc_bloodtalons", function()
        applyBuff( "bloodtalons", nil, 2 )
        last_bloodtalons = query_time
    end )


    -- Legendaries.  Ugh.
    spec:RegisterGear( "ailuro_pouncers", 137024 )
    spec:RegisterGear( "behemoth_headdress", 151801 )
    spec:RegisterGear( "chatoyant_signet", 137040 )
    spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
    spec:RegisterGear( "fiery_red_maimers", 144354 )
    spec:RegisterGear( "luffa_wrappings", 137056 )
    spec:RegisterGear( "soul_of_the_archdruid", 151636 )
    spec:RegisterGear( "the_wildshapers_clutch", 137094 )

    -- Legion Sets (for now).
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( "apex_predator", {
            id = 252752,
            duration = 25
         } ) -- T21 Feral 4pc Bonus.

    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )


    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return 60 * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
            gcd = "off",

            toggle = "false",

            startsCombat = false,
            texture = 136097,

            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            handler = function ()
                shift( "bear_form" )
                if conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
            end,
        },


        berserk = {
            id = 106951,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            startsCombat = false,
            texture = 236149,

            notalent = "incarnation",

            toggle = "cooldowns",
            nobuff = "berserk", -- VoP

            handler = function ()
                if buff.cat_form.down then shift( "cat_form" ) end
                applyBuff( "berserk" )
                energy.max = energy.max + 50
            end,
        },


        brutal_slash = {
            id = 202028,
            cast = 0,
            charges = 3,

            cooldown = 8,
            recharge = 8,
            hasteCD = true,

            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then
                        return 25 * -0.25
                    end
                    return 0
                end
                return max( 0, 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132141,

            form = "cat_form",
            talent = "brutal_slash",

            handler = function ()
                gain( 1, "combo_points" )

                if will_proc_bloodtalons then proc_bloodtalons() end
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            essential = true,

            noform = "cat_form",
            handler = function ()
                shift( "cat_form" )
            end,
        },


        cyclone = {
            id = 33786,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "dash" )
            end,
        },


        enraged_maul = {
            id = 236716,
            cast = 0,
            cooldown = 3,
            gcd = "spell",

            pvptalent = "heart_of_the_wild",
            form = "bear_form",

            spend = 40,
            spendType = "rage",

            startsCombat = true,
            texture = 132136,

            handler = function ()
            end,
        },


        entangling_roots = {
            id = 339,
            cast = function ()
                if buff.predatory_swiftness.up then return 0 end
                return 1.7 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
                removeBuff( "predatory_swiftness" )
            end,
        },


        feral_frenzy = {
            id = 274837,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 132140,

            handler = function ()
                gain( 5, "combo_points" )
                applyDebuff( "target", "feral_frenzy" )

                if will_proc_bloodtalons then proc_bloodtalons() end
            end,

            copy = "ashamanes_frenzy"
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.apex_predator.up or buff.apex_predators_craving.up then return 0 end
                -- going to require 50 energy and then refund it back...
                if talent.sabertooth.enabled and debuff.rip.up then
                    -- Let's make FB available sooner if we need to keep a Rip from falling off.
                    local nrg = 50 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )

                    if energy[ "time_to_" .. nrg ] - debuff.rip.remains > 0 then
                        return max( 25, energy.current + ( (debuff.rip.remains - 1 ) * energy.regen ) )
                    end
                end
                return 50 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            indicator = function ()
                if settings.cycle and talent.sabertooth.enabled and dot.rip.down and active_dot.rip > 0 then return "cycle" end
            end,

            usable = function () return buff.apex_predator.up or combo_points.current > 0 end,
            handler = function ()
                if talent.sabertooth.enabled and debuff.rip.up then
                    debuff.rip.expires = debuff.rip.expires + ( 4 * combo_points.current )
                end

                if pvptalent.ferocious_wound.enabled and combo_points.current >= 5 then
                    applyDebuff( "target", "ferocious_wound", nil, min( 2, debuff.ferocious_wound.stack + 1 ) )
                end

                if buff.apex_predator.up or buff.apex_predators_craving.up then
                    applyBuff( "predatory_swiftness" )
                    removeBuff( "apex_predator" )
                    removeBuff( "apex_predators_craving" )
                else
                    spend( min( 5, combo_points.current ), "combo_points" )
                end

                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            cooldown = 36,
            charges = function () return talent.guardian_affinity.enabled and buff.heart_of_the_wild.up and 2 or nil end,
            recharge = function () return talent.guardian_affinity.enabled and buff.heart_of_the_wild.up and 36 or nil end,
            hasteCD = true,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( health.max * 0.05, "health" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",
            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135879,

            handler = function ()
                applyBuff( "heart_of_the_wild" )
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102543,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            startsCombat = false,
            texture = 571586,

            toggle = "cooldowns",
            talent = "incarnation",
            nobuff = "incarnation", -- VoP

            handler = function ()
                if buff.cat_form.down then shift( "cat_form" ) end
                applyBuff( "incarnation" )
                applyBuff( "jungle_stalker" )
                energy.max = energy.max + 50
            end,

            copy = { "incarnation_king_of_the_jungle", "Incarnation" }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 40,
            spendType = "rage",

            startsCombat = false,
            texture = 1378702,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "ironfur", 6 + buff.ironfur.remains )
            end,
        },


        --[[ lunar_strike = {
            id = 197628,
            cast = function() return 2.5 * haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "lunar_empowerment" )
            end,
        }, ]]


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            form = "cat_form",
            usable = function () return combo_points.current > 0 end,

            handler = function ()
                applyDebuff( "target", "maim", combo_points.current )
                spend( combo_points.current, "combo_points" )

                removeBuff( "iron_jaws" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = function () return 30  * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, true_active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = function () return 60 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",
            form = "moonkin_form",

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
            end,
        },


        moonfire_cat = {
            id = 155625,
            known = 8921,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 136096,

            talent = "lunar_inspiration",
            form = "cat_form",

            cycle = "moonfire_cat",
            aura = "moonfire_cat",

            handler = function ()
                applyDebuff( "target", "moonfire_cat" )
                debuff.moonfire_cat.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
                if will_proc_bloodtalons then proc_bloodtalons() end
            end,

            copy = { 8921, 155625, "moonfire_cat" }
        },


        moonkin_form = {
            id = 197625,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        primal_wrath = {
            id = 285381,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            talent = "primal_wrath",
            aura = "rip",

            spend = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 1392547,

            usable = function () return combo_points.current > 0, "no combo points" end,
            handler = function ()
                applyDebuff( "target", "rip", mod_circle_dot( 2 + 2 * combo_points.current ) )
                active_dot.rip = active_enemies

                spend( combo_points.current, "combo_points" )
                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        prowl = {
            id = function () return buff.incarnation.up and 102547 or 5215 end,
            cast = 0,
            cooldown = function ()
                if buff.prowl.up then return 0 end
                return 6
            end,
            gcd = "off",

            startsCombat = false,
            texture = 514640,

            nobuff = "prowl",

            usable = function () return time == 0 or ( boss and buff.jungle_stalker.up ) end,

            handler = function ()
                shift( "cat_form" )
                applyBuff( buff.incarnation.up and "prowl_incarnation" or "prowl_base" )
            end,

            copy = { 5215, 102547 }
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                return 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ), "energy"
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            cycle = "rake",
            min_ttd = 6,

            damage = function ()
                return stat.attack_power * 0.18225
            end,

            tick_damage = function ()
                return stat.attack_power * 0.15561
            end,

            tick_dmg = function ()
                return stat.attack_power * 0.15561
            end,

            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
                debuff.rake.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
                if will_proc_bloodtalons then proc_bloodtalons() end

                removeBuff( "sudden_ambush" )
            end,

            copy = "rake_bleed"
        },


        rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            startsCombat = false,
            texture = 136080,

            handler = function ()
            end,

            auras = {
                -- Conduit
                born_anew = {
                    id = 341448,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        regrowth = {
            id = 8936,
            cast = function ()
                if buff.predatory_swiftness.up then return 0 end
                return 1.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            usable = function ()
                if buff.prowl.up then return false, "prowling" end
                if buff.cat_form.up and time > 0 and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
                return true
            end,

            handler = function ()
                if buff.predatory_swiftness.down then
                    unshift()
                end

                removeBuff( "predatory_swiftness" )
                applyBuff( "regrowth", 12 )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                unshift()
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135952,

            usable = function ()
                return debuff.dispellable_curse.up or debuff.dispellable_poison.up, "requires dispellable curse or poison"
            end,

            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
                removeDebuff( "player", "dispellable_poison" )
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = false,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                health.actual = min( health.max, health.actual + ( 0.3 * health.max ) )
            end,
        },


        revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 132132,

            handler = function ()
            end,
        },


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132152,

            aura = "rip",
            cycle = "rip",
            min_ttd = 9.6,

            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "no combo points" end
                --[[ if settings.hold_bleed_pct > 0 then
                    local limit = settings.hold_bleed_pct * debuff.rip.duration
                    if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
                end ]]
                return true
            end,

            handler = function ()
                spend( combo_points.current, "combo_points" )

                applyDebuff( "target", "rip", mod_circle_dot( min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) ) )
                debuff.rip.pmultiplier = persistent_multiplier

                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        rip_and_tear = {
            id = 203242,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 60,
            spendType = "energy",

            talent = "rip_and_tear",

            startsCombat = true,
            texture = 1029738,

            handler = function ()
                applyDebuff( "target", "rip" )
                applyDebuff( "target", "rake" )
            end,
        },


        savage_roar = {
            id = 52610,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 236167,

            talent = "savage_roar",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                local cost = min( 5, combo_points.current )
                spend( cost, "combo_points" )
                if buff.savage_roar.down then energy.regen = energy.regen * 1.1 end
                applyBuff( "savage_roar", 6 + ( 6 * cost ) )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return -10 end
                    return 0
                end
                return 40 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            handler = function ()
                if level > 53 and ( buff.prowl.up or buff.berserk.up or buff.incarnation.up ) then
                    gain( 2, "combo_points" )
                else
                    gain( 1, "combo_points" )
                end

                removeStack( "clearcasting" )

                if will_proc_bloodtalons then proc_bloodtalons() end
                removeBuff( "sudden_ambush" )
            end,
        },


        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 236946,

            toggle = "interrupts",
            interrupt = true,

            form = function () return buff.bear_form.up and "bear_form" or "cat_form" end,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()

                if pvptalent.savage_momentum.enabled then
                    gainChargeTime( "tigers_fury", 10 )
                    gainChargeTime( "survival_instincts", 10 )
                    gainChargeTime( "stampeding_roar", 10 )
                end
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = false,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
            end,
        },


        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 464343,

            handler = function ()
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )
                end
                applyBuff( "stampeding_roar" )
            end,
        },


        starfire = {
            id = 197628,
            cast = function () return 2.5 * ( buff.eclipse_lunar.up and 0.92 or 1 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            handler = function ()
                if buff.eclipse_lunar.down and solar_eclipse > 0 then
                    solar_eclipse = solar_eclipse - 1
                    if solar_eclipse == 0 then applyBuff( "eclipse_solar" ) end
                end
            end,
        },


        starsurge = {
            id = 197626,
            cast = function () return ( buff.heart_of_the_wild.up and 0 or 2 ) * haste end,
            cooldown = 10,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135730,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                if buff.eclipse_lunar.up then buff.eclipse_lunar.expires = buff.eclipse_lunar.expires + 2 end
                if buff.eclipse_solar.up then buff.eclipse_solar.expires = buff.eclipse_solar.expires + 2 end
            end,
        },


        sunfire = {
            id = 197630,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.12,
            spendType = "mana",

            startsCombat = true,
            texture = 236216,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        survival_instincts = {
            id = 61336,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 236169,

            handler = function ()
                applyBuff( "survival_instincts" )
            end,
        },


        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",

            handler = function ()
                unshift()
            end,
        },


        swipe_cat = {
            id = 106785,
            known = 213764,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return 35 * -0.25 end
                    return 0
                end
                return max( 0, ( 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 134296,

            notalent = "brutal_slash",
            form = "cat_form",

            damage = function () return stat.attack_power * 0.28750 * ( active_dot.thrash_cat > 0 and 1.2 or 1 ) end, -- TODO: Check damage.

            handler = function ()
                gain( 1, "combo_points" )
                if will_proc_bloodtalons then proc_bloodtalons() end
                removeStack( "clearcasting" )
            end,

            copy = { 213764, "swipe" },
            bind = { "swipe_cat", "swipe_bear", "swipe", "brutal_slash" }
        },

        teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            startsCombat = false,
            texture = 135758,

            handler = function ()
            end,
        },


        thorns = {
            id = 305497,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        thrash_cat = {
            id = 106830,
            known = 106832,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return -10 end
                    return 0
                end
                return 40 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 451161,

            aura = "thrash_cat",
            cycle = "thrash_cat",

            form = "cat_form",
            handler = function ()
                applyDebuff( "target", "thrash_cat" )

                active_dot.thrash_cat = max( active_dot.thrash, active_enemies )
                debuff.thrash_cat.pmultiplier = persistent_multiplier

                if talent.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood" )
                    buff.scent_of_blood.v1 = -3 * active_enemies
                end

                removeStack( "clearcasting" )
                if target.within8 then
                    gain( 1, "combo_points" )
                    if will_proc_bloodtalons then proc_bloodtalons() end
                end
            end,

            copy = { "thrash", 106832 },
            bind = { "thrash_cat", "thrash_bear", "thrash" }
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        tigers_fury = {
            id = 5217,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            spend = -50,
            spendType = "energy",

            startsCombat = false,
            texture = 132242,

            usable = function () return buff.tigers_fury.down or energy.deficit > 50 + energy.regen end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tigers_fury" )
                if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end

                if legendary.eye_of_fearful_symmetry.enabled then
                    applyBuff( "eye_of_fearful_symmetry" )
                end
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            handler = function ()
                shift( "travel_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "balance_affinity",

            handler = function ()
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


        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 538771,

            form = "cat_form",

            handler = function ()
                setDistance( 5 )
                -- applyDebuff( "target", "dazed", 3 )
            end,
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "restoration_affinity",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },


        wrath = {
            id = 5176,
            cast = function () return 1.5 * ( buff.eclipse_solar.up and 0.92 or 1 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            handler = function ()
                if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then applyBuff( "eclipse_lunar" ) end
                end
            end,
        },


        -- Covenants (belongs in DruidBalance, really).

        -- Druid - Kyrian    - 326434 - kindred_spirits      (Kindred Spirits)
        --                   - 326647 - empower_bond         (Empower Bond)
        kindred_spirits = {
            id = 326434,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 3565444,

            essential = true,

            usable = function ()
                return buff.lone_spirit.down and buff.kindred_spirits.down, "lone_spirit/kindred_spirits already applied"
            end,

            bind = "empower_bond",

            handler = function ()
                unshift()
                -- Let's just assume.
                applyBuff( "lone_spirit" )
            end,

            auras = {
                -- Damager
                kindred_empowerment = {
                    id = 327139,
                    duration = 10,
                    max_stack = 1,
                    copy = "kindred_empowerment_energize",
                },
                -- From Damager
                kindred_empowerment_partner = {
                    id = 327022,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_focus = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_focus_partner = {
                    id = 327071,
                    duration = 10,
                    max_stack = 1,
                },
                -- Tank
                kindred_protection = {
                    id = 327037,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_protection_partner = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_spirits = {
                    id = 326967,
                    duration = 3600,
                    max_stack = 1,
                },
                lone_spirit = {
                    id = 338041,
                    duration = 3600,
                    max_stack = 1,
                },
                lone_empowerment = {
                    id = 338142,
                    duration = 10,
                    max_stack = 1,
                },                
            }
        },

        empower_bond = {
            id = 326647,
            known = function () return covenant.kyrian and ( buff.lone_spirit.up or buff.kindred_spirits.up ) end,
            cast = 0,
            cooldown = function () return 60 * ( 1 - ( conduit.deep_allegiance.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 3528283,

            usable = function ()
                return buff.lone_spirit.up or buff.kindred_spirits.up, "requires kindred_spirits/lone_spirit"
            end,

            toggle = "essences",

            bind = "kindred_spirits",

            handler = function ()
                if buff.lone_spirit.up then
                    if role.tank then applyBuff( "lone_protection" )
                    elseif role.healer then applyBuff( "lone_meditation" )
                    else applyBuff( "lone_empowerment" ) end
                else
                    if role.tank then
                        applyBuff( "kindred_protection" )
                        applyBuff( "kindred_protection_partner" )
                    elseif role.healer then
                        applyBuff( "kindred_meditation" )
                        applyBuff( "kindred_meditation_partner" )
                    else
                        applyBuff( "kindred_empowerment" )
                        applyBuff( "kindred_empowerment_partner" )
                    end
                end
            end,

            copy = { "lone_empowerment", "lone_meditation", "lone_protection", 326462, 326446, 338142, 338018 }
        },

        -- Druid - Necrolord - 325727 - adaptive_swarm       (Adaptive Swarm)
        adaptive_swarm = {
            id = 325727,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3578197,

            handler = function ()
                applyDebuff( "target", "adaptive_swarm_dot", nil, 325733 )
            end,

            copy = "adaptive_swarm_damage"
        },

        -- Druid - Night Fae - 323764 - convoke_the_spirits  (Convoke the Spirits)
        convoke_the_spirits = {
            id = 323764,
            cast = 4,
            channeled = true,
            cooldown = 120,
            gcd = "spell",

            toggle = "essences",

            startsCombat = true,
            texture = 3636839,

            finish = function ()
                -- Can we safely assume anything is going to happen?
                if state.spec.feral then
                    applyBuff( "tigers_fury" )
                    if target.distance < 8 then
                        gain( 5, "combo_points" )
                    end
                elseif state.spec.guardian then
                elseif state.spec.balance then
                end
            end,
        },

        -- Druid - Venthyr   - 323546 - ravenous_frenzy      (Ravenous Frenzy)
        ravenous_frenzy = {
            id = 323546,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            startsCombat = true,
            texture = 3565718,

            toggle = "essences",

            handler = function ()
                applyBuff( "ravenous_frenzy" )
            end,
        }
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 3,

        potion = "focused_resolve",

        package = "Feral"
    } )

    spec:RegisterSetting( "brutal_charges", 2, {
        name = "Reserve |T132141:0|t Brutal Slash Charges",
        desc = "If set above zero, the addon will hold these Brutal Slash charges for when 3+ enemies have been detected.",
        icon = 132141,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 4,
        step = 0.1,
        width = 1.5
    } )

    spec:RegisterPack( "Feral", 20201012, [[dK08sbqijv5rssLljjvLnjP8jjPknkQuDkjjRsvv5vqrZcOCljvv7Is)cvyysQCmjXYuvLNrLsttvv11OsX2qLGVHkrnoQe5COsK1jPQyEujCpGSpOWbrLqSqurpusvPjkjvvxKkrP2iQesFusQIojvIIvQQ0mPsuzNQkokvIQAPssv4PQYubQ(kvIs2lO)sXGPQdlSyapMOjRuxgzZs8zL0OHsNwXQrLq9AuPMnHBRe7wLFlA4uXXPsuLLl1ZHmDsxhQ2ovsFhv14rL05vvz9ssz(Ok7hLHvGGdF7qj4N)Q7V6QuxL)S)vPoxYnCz4t)5qWNti5owj47Ifc(4IsDiGpN4NiJneC4dL4TKGpSQ6GQpCWX6OyXbSYCHd0SGlcDYt2rr5anlsoGpa8rOUmhea(2HsWp)v3F1vPUk)z)RsDUKBQaFihsc)uPo3cFyN9Moia8TjKe(QoMNlk1HG5R(B8zZ81pZ7YhFKCZ8XTz(Q)P1FSVSVvhZxFXg3kHQpSVvhZx)mVifmFOmpNHiojX(wDmF9Z8CkYCRHipeZFPY8ZIJGwOtPTf(C6Smcc(QoMNlk1HG5R(B8zZ81pZ7YhFKCZ8XTz(Q)P1FSVSVvhZxFXg3kHQpSVvhZx)mVifmFOmpNHiojX(wDmF9Z8CkYCRHipeZFPY8ZIJGwOtPTL9L9T6yEx2CLK4kTzEaQKnX8YCbiuMhGwNdzzEUisj5OiM)YR(Xg9sbxW8HuN8qmFEIFw23QJ5dPo5HSonjZfGqbvebIB23QJ5dPo5HSonjZfGqXeehLm3SVvhZhsDYdzDAsMlaHIjioc81f60qN8yFRoM3Lrz(bX88ZwXY8JY8LSz(qSKiL5jxP(xEeZRjZVeZPXCmVITdew23qQtEiRttYCbiuqCp3UPTb5m9Oi2x23qQtEiRttYCbiumbXHRrpbGGa7IfceoImk2oqybZ1qGtGQJ9nK6KhY60KmxacftqC4A0taiiWUyHaHJiJITdewWCne4eO)aBkGIQr9OKL)i2MIGqyB62ZTAPlae0M9nK6KhY60KmxacftqC4A0taiiWUyHa1JJrhj3iWCne4eixI9nK6KhY60KmxacftqCGJiZO0cyxSqGIQHWgDGmL8utwmojFQzFdPo5HSonjZfGqXeehoDYxa2uabGxk2LmpUNZuYEXUt(h7B1X8VlCqytL57y2mpaEPqBMhPHIyEaQKnX8YCbiuMhGwNdX8XTzENMQFNu15wz(bX878il7B1X8HuN8qwNMK5cqOycId0foiSPAqAOi23qQtEiRttYCbiumbXHtQtESVHuN8qwNMK5cqOycIdaQruZnytbeaEPyxY84Eotj7f7o5FSVHuN8qwNMK5cqOycIdDwPgzk49pWMcia8sXUK5X9CMs2l2DY)QbGxkwDwPgzk49p7o5FSVHuN8qwNMK5cqOycIdzOMs2lGnfqa4LIDjZJ75mLSxS7K)X(Y(wDmVlBUssCL2mp5k1)yEDwiMxXsmFi1Sz(bX8HRXicabzzFdPo5HaH4gximabclytbu9aWlfRtN8fwCNA1daVuSiSXo5VqITf3H9nK6KhctqC04NjK6KNrmifSlwiqaHiojb2uaPHGo1ceI4KKjkL5g9NLUaqq7Aa4LIDjZJ75mLSxS4oSVHuN8qycIdzOMs2lGnfq1daVuSYqnLSxS4oSVHuN8qycIJo4MaBkGaWlfRtN8fwChE8aWlflcBSt(lKyBXDyFdPo5HWeehYqimHuN8mIbPGDXcbsMPyN8pe7Bi1jpeMG4OqDkNehzagLat(tkiJg9kPiqvaBkG2PA7XXQJK75wRTt12JJTPLyoKlCBnn6vsT6Sqgnn7HWOsD1CxdbDQffauRzQyT0facAxf7Bi1jpeMG4OqDkNehzagLat(tkiJg9kPiqvaBkG0qqNArba1AMkwlDbGG21K5cqACY5uegihsimA0RKISk2oqynYqRTt12JJvhj3ZTwBNQThhBtlXCix42AA0RKA1zHmAA2dHXovBpo2MwI5qy6A0taiiBpogDKCJ(xi1jpBpowDKCB0zHyFdPo5HWeehn(zcPo5zedsb7IfcuzUbHLAeytbKmxasJtoNIW4)SVHuN8qycIJyho64kzq8JEH9nK6KhctqCiZZ1KBYOyjdYz6rrGnfqYCbino5CkYf)X(gsDYdHjioKHqycPo5zedsb7Ifc0kDuhA2itKeytbeYHecJg9kPiRITdewJmumQW(gsDYdHjioA8ZesDYZigKc2fleOv6Oo0SrSVSVHuN8qwzMIDY)qGaOgrn3Gnfq0r96pma526Q5UmtXo5FwDwPgzk49pBtlXCimCdpEa4LIvNvQrMcE)ZI7uf7Bi1jpKvMPyN8peMG4qNvQrMcE)dSPaIoQx)z3uzKJIbiUqD84bGxkwDwPgzk49p7o5FSVHuN8qwzMIDY)qycIdAXj5tTbiVnytbeaEPy1zLAKPG3)S4oSVHuN8qwzMIDY)qycIdaQruZ9CRSVHuN8qwzMIDY)qycIJoCLUehzknDv7hytbeDuV(ZUPYih1f1z)Zn)JoQx)zxcUY(gsDYdzLzk2j)dHjiouSzFiWMcOqQJRKHoAziegBcnnTnA0RKI4XRJzBixPtTXEJSZHX)Dd7Bi1jpKvMPyN8peMG4qXsg8diXVTPKTKaBkGaWlfBtsUfeczkzljlUdpEa4LIvNvQrMcE)ZI7W(gsDYdzLzk2j)dHjiowOLS)zYIrGlNTz3uSGaBkGaWlfRoRuJmf8(Nf3PgaEPybOgrn32DY)yFdPo5HSYmf7K)HWeehaIm3MSyuSKHoA5hytbeaEPy1zLAKPG3)S4oSVHuN8qwzMIDY)qycIJc1HWuA6Q2pWMcizUaKgNCofbQo23qQtEiRmtXo5FimbXrjL4iABIQr9OKbGIfWMcOqQJRKHoAziegBcnnTnA0RKI4XZ9oMTHCLo1g7nYohgCP6Qrh1R)SBQmYrXaKBQRk23qQtEiRmtXo5FimbXHdEpLFZTAaebsbBkGcPoUsg6OLHqySj0002OrVskIhVoMTHCLo1g7nYohgCH6yFdPo5HSYmf7K)HWeehR4rVN4mzXevJ6uXc2uabGxkwDwPgzk49plUd7Bi1jpKvMPyN8peMG4qMNKoTdL2MIiwiWMcia8sXQZk1itbV)zXDyFdPo5HSYmf7K)HWeeh944iiZCgKtijWMcia8sXQZk1itbV)zXDyFdPo5HSYmf7K)HWeeh8ZwSDLMZ0ekV4KeytbeaEPy1zLAKPG3)S4oSVHuN8qwzMIDY)qycIJMcN5wnfrSqiWMcin6vsT6Sqgnn7HCrfRB4XZD31Oxj1ILcHI16ivmCP64XtJELulwkekwRJuDbO)QRQAA0RKA1zHmAA2dHXFCPQ4XZDn6vsT6Sqgnnos18xDy426QPrVsQvNfYOPzpeg)))vX(gsDYdzLzk2j)dHjioMtg9f6KhytbeDuV(ddqUTUAUlZuSt(NvNvQrMcE)Z20smhcJkUHhpa8sXQZk1itbV)zXDQI9nK6KhYkZuSt(hctqC4K6KhytbKg9kPwDwiJMM9qUGl4gE8CxNfYOPzpKlQ4s1vZDa8sXcqnIAUT4o84bGxk25KrFHo5zXDQQk23qQtEiRmtXo5FimbXbcBSt(lKyd2uajZfG04KZPix4MA0r96pmafsDYZ2b3KvMiT2ovBhCtwNfCHooIHAx8NTsna8sXQZk1itbV)zXDQ5oaEPybezU1qKhYI7WJx90qqNAbezU1qKhYsxaiODv1CVEAiOtTZjJ(cDYZsxaiOnpEYmf7K)zNtg9f6KNTPLyoegvCPQQvpa8sXoNm6l0jplUd7Bi1jpKvMPyN8peMG4ahrMrPfWUyHafiSUghHmDuTSnYSdbytb0MaWlfBhvlBJm7qy2eaEPy3j)JhVnbGxkwzEBCPoUsM542Sja8sXI7utJELuRolKrtJJunUToxuX6gE8Q3MaWlfRmVnUuhxjZCCB2eaEPyXDQ5(MaWlfBhvlBJm7qy2eaEPyrAi5gdq)5M6VsD)Bta4LIfqK52KfJILm0rl)S4o84PZcz00ShYf)VUQQbGxkwDwPgzk49pBtlXCimQuh7Bi1jpKvMPyN8peMG4ahrMrPfWOsHKQ5IfcK8NuKAN3inaIaPGnfqUth1R)SBQmYrXaeDuV(Z20kD)ZTvvdaVuS6SsnYuW7F2DY)QvVOAupkz5IXVvbzk49plDbGG2SVHuN8qwzMIDY)qycIdCezgLwaJkfsQMlwiqYFsrQDEJ0aicKc2uabGxkwDwPgzk49plUtTOAupkz5IXVvbzk49plDbGG2SVHuN8qwzMIDY)qycIdCezgLwaJkfsQMlwiqr1qyJoqMsEQjlgNKp1Gnfq0r96p7MkJCuma5M6yFdPo5HSYmf7K)HWeeh4iYmkTGaBkGaWlfRoRuJmf8(Nf3HhpDwiJMM9qU4V6yFzFdPo5HSL5gewQrGCYuyAcL4TKaRKT5iUQGQW(gsDYdzlZniSuJWeehOW1yLmDgnytbeaEPyrHRXkz6mA7o5FSVHuN8q2YCdcl1imbXHtMcttOeVLeyLSnhXvfuf23qQtEiBzUbHLAeMG4WPNLqy43HIfm5pPGmA0RKIavbSPac5qcHrJELuK1PNLqy43HIfJk12PA7XX20smhYf)N9nK6KhYwMBqyPgHjioCYuyAcL4TKaRKT5iUQGQW(gsDYdzlZniSuJWeeho9Secd)ouSGj)jfKrJELueOkGnfqihsimA0RKISo9Secd)ouSya6p23qQtEiBzUbHLAeMG4WjtHPjuI3scSs2MJ4QcQc7Bi1jpKTm3GWsnctqC0JdyYFsbz0OxjfbQcytbu90qqNArba1AMkwlDbGG21AQ0ecBaiOAA0RKA1zHmAA2dHXovBpo2MwI5qy6A0taiiBpogDKCJ(xi1jpBpowDKCB0zHyFdPo5HSL5gewQrycIdNmfMMqjEljWkzBoIRkOkSVHuN8q2YCdcl1imbXrpoGj)jfKrJELueOkGnfqAiOtTOaGAntfRLUaqq7AUxpDKCp3kpEnTeZHCbOnEh6K3)QZ62AouJgKsNAwWf64igQXyNQThhRZcUqhhXqDv10Oxj1QZcz00ShcJDQ2ECSnTeZHW01ONaqq2ECm6i5g9p3RG5ovBpowDKCp36)CBv)lK6KNThhRosUn6SqSVHuN8q2YCdcl1imbXHtMcttOeVLeyLSnhXvfuf23qQtEiBzUbHLAeMG4afUgRKPZObBkGaWlflkCnwjtNrBBAjMd5Ik)X(gsDYdzlZniSuJWeehozkmnHs8wsGvY2CexvqvyFdPo5HSL5gewQrycIJLywaBkGaWlf705z4Id(ilUd7Bi1jpKTm3GWsnctqCuOoLtIJmaJsGTeC1qh1R)avbm5pPGmA0RKIavH9L9nK6KhYUsh1HMnctqCa04AimirGWc2uaHCiHWOrVskYc04AimirGWIXMqttBJg9kPOAUxVOAupkz5pITPiie2MU9CRw6cabT5XBNQvX2bcRrgQvhj3ZTwfpEa4LIfqK5wdrEi7o5F14pcHXPtPbqK5wdrEi23qQtEi7kDuhA2imbXHtMcttOeVLeyLSnhXvfuf23qQtEi7kDuhA2imbXHITdewJmuWMci3BQ0ecBaiOAihsimA0RKISk2oqynYqX4VQ4XdaVuSaIm3AiYdz3j)Rg)rimoDknaIm3AiYdX(gsDYdzxPJ6qZgHjioCYuyAcL4TKaRKT5iUQGQW(gsDYdzxPJ6qZgHjiouSDGWAKHc2ua5Ugc6ulssNAYIbqK52sxaiODna8sXIK0PMSyaezUT7K)vvnKdjegn6vsrwfBhiSgzOy4w23qQtEi7kDuhA2imbXHtMcttOeVLeyLSnhXvfuf23qQtEi7kDuhA2imbXbI)4qgzOGnfqa4LIfjPtnzXaiYCBXD4XZ9qQtEwe)XHmYqT7yjwP)HCiHWOrVskYI4poKrgkgUhsDYZ2b3KDhlXkHP7HuN8SDWnzaeeTT6i52SJLyL(NBQQQQ4XdaVuSaIm3AiYdz3j)Rg)rimoDknaIm3AiYdX(gsDYdzxPJ6qZgHjioCYuyAcL4TKaRKT5iUQGQW(gsDYdzxPJ6qZgHjio6GBcm5pPGmA0RKIavbSPaQE6i5EUvE8CVEAiOtTaIm3AiYdzPlae0UwtlXCixSX7qN8(xDw3wvnn6vsT6Sqgnn7HW4)84bGxkwarMBne5HS7K)vJ)iegNoLgarMBne5HyFdPo5HSR0rDOzJWeehozkmnHs8wsGvY2CexvqvyFdPo5HSR0rDOzJWeehDWnbM8Nuqgn6vsrGQa2ua5U7nTeZHCbiUCv1COgniLo1SGl0XrmuJXovBhCtwNfCHooIH6)vN1LCtv10Oxj1QZcz00ShcJ)Z(wDmVlRrXY8UCUmmFnMNtWbJ55tmVmoMhhrm)sMxzAI51K5rHReZZj4mVeB0RecmMpeIK)CRmpoI51K5bivPM5BQ0eclZ3b3e7Bi1jpKDLoQdnBeMG4yjZRmnzKHc2uabGxkwNM2HM9pdI)u0Jqi7o5F1K5cqACY5uKlCdpEa4LIfqK5wdrEi7o5F14pcHXPtPbqK5wdrEi23qQtEi7kDuhA2imbXXsMxzAYidfm5pPGmA0RKIavbSPaQPstiSbGGyFdPo5HSR0rDOzJWeehanUgcdseiSGnfqUxVOAupkz5pITPiie2MU9CRw6cabT5XBNQvX2bcRrgQvhj3ZTwvna8sXQZk1itbV)zXDQ5EhZ2qUsNAJ9gzNdd3RG5sWvJeB0ReQ(LyJELqMshsDYlev9VMKyJELm6SqvXJhaEPybezU1qKhYUt(xn(JqyC6uAaezU1qKhI9nK6KhYUsh1HMnctqC4KPW0ekXBjbwjBZrCvbvH9nK6KhYUsh1HMnctqCOy7aH1idfSPaQPstiSbGGQ5U7Ug9eacYIJiJITdewq)vZ96bGxk25KrFHo5zXD4XlQg1Jsw(JyBkccHTPBp3QLUaqq7QQIhpKdjegn6vsrwfBhiSgzOyuPkE8aWlflGiZTgI8q2DY)QXFecJtNsdGiZTgI8qSVvhZhsDYdzxPJ6qZgHjiouSDGWAKHc2ua1uPje2aqq1Cn6jaeKfhrgfBhiSGQudaVuSsbfTmq6CR2McPwZ96bGxk25KrFHo5zXD4XlQg1Jsw(JyBkccHTPBp3QLUaqq7Q4XdaVuSaIm3AiYdz3j)Rg)rimoDknaIm3AiYdX(gsDYdzxPJ6qZgHjioCYuyAcL4TKaRKT5iUQGQW(gsDYdzxPJ6qZgHjioq8hhYidfSPac5qcHrJELuKfXFCiJmumQWJhaEPybezU1qKhYUt(xn(JqyC6uAaezU1qKhI9nK6KhYUsh1HMnctqCGW20gSPaANQTdUjBtlXCimCpK6KNfHTPTvMifZqQtE2o4MSYeP1pDuV(RQQp6OE9NTPv64XdaVuSsbfTmq6CR2McPYJhaEPybezU1qKhYUt(xn(JqyC6uAaezU1qKhI9L9nK6KhYUsh1HMnYejbYjtHPjuI3scSs2MJ4QcQc7Bi1jpKDLoQdnBKjsctqC0b3eytbutLMqydabvdaVuSaIm3AiYdz3j)Rg)rimoDknaIm3AiYdX(gsDYdzxPJ6qZgzIKWeehozkmnHs8wsGvY2CexvqvyFdPo5HSR0rDOzJmrsycIdfBhiSgzOGnfqU3uPje2aqq84fsDCLm7uTk2oqynYqDri1XvYqhTmeQ67VQQHCiHWOrVskYQy7aH1idfJ)4XtdbDQfjPtnzXaiYCBPlae0UgaEPyrs6utwmaIm32DY)QHCiHWOrVskYQy7aH1idfd3YJx90rY9CR1IQr9OKL)i2MIGqyB62ZTAPlae0Mhpa8sXciYCRHipKDN8VA8hHW40P0aiYCRHipe7Bi1jpKDLoQdnBKjsctqC4KPW0ekXBjbwjBZrCvbvH9nK6KhYUsh1HMnYejHjioaACnegKiqybBkGqoKqy0OxjfzbACnegKiqyXytOPPTrJELuepEa4LIfqK5wdrEi7o5F14pcHXPtPbqK5wdrEi23qQtEi7kDuhA2itKeMG4WjtHPjuI3scSs2MJ4QcQc7Bi1jpKDLoQdnBKjsctqCG4poKrgkytbeaEPyrs6utwmaIm3wChE8aWlflGiZTgI8q2DY)QXFecJtNsdGiZTgI8qSVSVHuN8qwGqeNKaHWVY0eytbeaEPyjPyCqKbLIOT7K)vdaVuSKumoiYiWVOT7K)vZ9MknHWgacIhp3dPoUsg6OLHqyuPwi1XvYSt1IWVY0KlcPoUsg6OLHqvvf7Bi1jpKfieXjjmbXbsJgH3ReytbeaEPyjPyCqKbLIOTnTeZHWqgi1OZcXJhaEPyjPyCqKrGFrBBAjMdHHmqQrNfI9nK6KhYceI4KeMG4aPrxMMaBkGaWlfljfJdImc8lABtlXCimKbsn6Sq84Hsr0gskgheHrDSVHuN8qwGqeNKWeeh87qXc2uabGxkwskghezqPiABtlXCimKbsn6Sq84jWVOnKumoicJ6GpxPgn5b)8xD)vxDU0FUf(4h9n3kc(CzXfP6XhxMpvpRpmpZdowI5NfNSvMVKnZx9Ush1HMnYejv9Y8n5YdFAAZ8OCHy(axZLqPnZlXg3kHSSVUCZrm))RpmF9npxPwPnZ)ML6lZJ(DAWvMV6J51K5D5WdMFpUoOjpMpDOo0SzE35OkM39kCTkl7l7RllUivp(4Y8P6z9H5zEWXsm)S4KTY8LSz(Q3v6Oo0SrvVmFtU8WNM2mpkxiMpW1CjuAZ8sSXTsil7Rl3CeZxHlvFy(6BEUsTsBM)nl1xMh970GRmF1hZRjZ7YHhm)ECDqtEmF6qDOzZ8UZrvmV7v4Avw2x2xxMfNSvAZ8CzMpK6KhZlgKISSVWNyqkcco8Tsh1HMnYejbbh(PceC4JUaqqBiNWxjBZrCvHFQaFHuN8GpNmfMMqjEljOc)8heC4JUaqqBiNWNShL6jGVMknHWgacI5RX8a4LIfqK5wdrEi7o5FmFnMN)iegNoLgarMBne5HGVqQtEWxhCtqf(XTqWHp6cabTHCcFLSnhXvf(Pc8fsDYd(CYuyAcL4TKGk8Z)HGdF0facAd5e(K9Oupb85oZ3uPje2aqqmppEmFi1XvYSt1Qy7aH1idL5DbZhsDCLm0rldHyEoy()y(Qy(AmpYHecJg9kPiRITdewJmuMhdM)pMNhpMxdbDQfjPtnzXaiYCBPlae0M5RX8a4LIfjPtnzXaiYCB3j)J5RX8ihsimA0RKISk2oqynYqzEmyE3Y884X81J51rY9CRmFnMpQg1Jsw(JyBkccHTPBp3QLUaqqBMNhpMhaVuSaIm3AiYdz3j)J5RX88hHW40P0aiYCRHipe8fsDYd(uSDGWAKHcv4h3abh(Olae0gYj8vY2Cexv4NkWxi1jp4ZjtHPjuI3scQWpCbi4WhDbGG2qoHpzpk1taFihsimA0RKISanUgcdseiSmpgm)MqttBJg9kPiMNhpMhaVuSaIm3AiYdz3j)J5RX88hHW40P0aiYCRHipe8fsDYd(aACnegKiqyHk8dxgco8rxaiOnKt4RKT5iUQWpvGVqQtEWNtMcttOeVLeuHFCji4WhDbGG2qoHpzpk1taFa4LIfjPtnzXaiYCBXDyEE8yEa8sXciYCRHipKDN8pMVgZZFecJtNsdGiZTgI8qWxi1jp4dXFCiJmuOcv4BtLaxOqWHFQabh(Olae0gYj8j7rPEc4REmpaEPyD6KVWI7W81y(6X8a4LIfHn2j)fsST4oWxi1jp4dXnUqyacewOc)8heC4JUaqqBiNWNShL6jGpne0PwGqeNKmrPm3O)S0facAZ81yEa8sXUK5X9CMs2lwCh4lK6Kh814NjK6KNrmif(edsnxSqWhqiItsqf(XTqWHp6cabTHCcFYEuQNa(QhZdGxkwzOMs2lwCh4lK6Kh8jd1uYEbQWp)hco8rxaiOnKt4t2Js9eWhaEPyD6KVWI7W884X8a4LIfHn2j)fsST4oWxi1jp4RdUjOc)4gi4WhDbGG2qoHVqQtEWNmecti1jpJyqk8jgKAUyHGpzMIDY)qqf(Hlabh(Olae0gYj8fsDYd(kuNYjXrgGrj4t2Js9eW3ovBpowDKCp3kZxJ53PA7XX20smhI5DbZ7wMVgZRrVsQvNfYOPzpeZJbZxPoMVgZ7oZRHGo1IcaQ1mvSw6cabTz(QGp5pPGmA0RKIGFQav4hUmeC4JUaqqBiNWxi1jp4RqDkNehzagLGpzpk1taFAiOtTOaGAntfRLUaqqBMVgZlZfG04KZPiMhdMh5qcHrJELuKvX2bcRrgkZxJ53PA7XXQJK75wz(Am)ovBpo2MwI5qmVlyE3Y81yEn6vsT6Sqgnn7HyEmy(DQ2ECSnTeZHyEmzExJEcabz7XXOJKBeZ)pMpK6KNThhRosUn6SqWN8Nuqgn6vsrWpvGk8Jlbbh(Olae0gYj8j7rPEc4tMlaPXjNtrmpgm))HVqQtEWxJFMqQtEgXGu4tmi1CXcbFL5gewQrqf(Hlbbh(cPo5bFXoC0XvYG4h9c8rxaiOnKtOc)uPoi4WhDbGG2qoHpzpk1taFYCbino5CkI5DbZ)h8fsDYd(K55AYnzuSKb5m9OiOc)uPceC4JUaqqBiNWNShL6jGpKdjegn6vsrwfBhiSgzOmpgmFf4lK6Kh8jdHWesDYZigKcFIbPMlwi4BLoQdnBKjscQWpv(dco8rxaiOnKt4lK6Kh814NjK6KNrmif(edsnxSqW3kDuhA2iOcv4ZPjzUaekeC4NkqWHVqQtEWh3ZTBABqotpkc(Olae0gYjuHF(dco8rxaiOnKt4lDGpePWxi1jp4Z1ONaqqWNRHaNGV6GpxJ2CXcbF4iYOy7aHfQWpUfco8rxaiOnKt4lDGpePWxi1jp4Z1ONaqqWNRHaNGV)Gpzpk1taFr1OEuYYFeBtrqiSnD75wT0facAdFUgT5Ifc(WrKrX2bcluHF(peC4JUaqqBiNWx6aFisHVqQtEWNRrpbGGGpxdbobFUe85A0Mlwi4RhhJosUrqf(XnqWHp6cabTHCcFxSqWxune2OdKPKNAYIXj5tn8fsDYd(IQHWgDGmL8utwmojFQHk8dxaco8rxaiOnKt4t2Js9eWhaEPyxY84Eotj7f7o5FWxi1jp4ZPt(cOc)WLHGdFHuN8GpNuN8Gp6cabTHCcv4hxcco8rxaiOnKt4t2Js9eWhaEPyxY84Eotj7f7o5FWxi1jp4dGAe1Cdv4hUeeC4JUaqqBiNWNShL6jGpa8sXUK5X9CMs2l2DY)y(AmpaEPy1zLAKPG3)S7K)bFHuN8GpDwPgzk49pOc)uPoi4WhDbGG2qoHpzpk1taFa4LIDjZJ75mLSxS7K)bFHuN8GpzOMs2lqfQW3kDuhA2ii4WpvGGdF0facAd5e(K9Oupb8HCiHWOrVskYc04AimirGWY8yW8BcnnTnA0RKIy(AmV7mF9y(OAupkz5pITPiie2MU9CRw6cabTzEE8y(DQwfBhiSgzOwDKCp3kZxfZZJhZdGxkwarMBne5HS7K)X81yE(JqyC6uAaezU1qKhc(cPo5bFanUgcdseiSqf(5pi4WhDbGG2qoHVs2MJ4Qc)ub(cPo5bFozkmnHs8wsqf(XTqWHp6cabTHCcFYEuQNa(CN5BQ0ecBaiiMVgZJCiHWOrVskYQy7aH1idL5XG5)J5RI55XJ5bWlflGiZTgI8q2DY)y(Amp)rimoDknaIm3AiYdbFHuN8GpfBhiSgzOqf(5)qWHp6cabTHCcFLSnhXvf(Pc8fsDYd(CYuyAcL4TKGk8JBGGdF0facAd5e(K9Oupb85oZRHGo1IK0PMSyaezUT0facAZ81yEa8sXIK0PMSyaezUT7K)X8vX81yEKdjegn6vsrwfBhiSgzOmpgmVBHVqQtEWNITdewJmuOc)WfGGdF0facAd5e(kzBoIRk8tf4lK6Kh85KPW0ekXBjbv4hUmeC4JUaqqBiNWNShL6jGpa8sXIK0PMSyaezUT4omppEmV7mFi1jplI)4qgzO2DSeReZ)pMh5qcHrJELuKfXFCiJmuMhdM3DMpK6KNTdUj7owIvI5XK5DN5dPo5z7GBYaiiAB1rYTzhlXkX8)J5DdZxfZxfZxfZZJhZdGxkwarMBne5HS7K)X81yE(JqyC6uAaezU1qKhc(cPo5bFi(JdzKHcv4hxcco8rxaiOnKt4RKT5iUQWpvGVqQtEWNtMcttOeVLeuHF4sqWHp6cabTHCcFHuN8GVo4MGpzpk1taF1J51rY9CRmppEmV7mF9yEne0PwarMBne5HS0facAZ81y(MwI5qmVly(nEh6KhZ)pMVoRBz(Qy(AmVg9kPwDwiJMM9qmpgm))zEE8yEa8sXciYCRHipKDN8pMVgZZFecJtNsdGiZTgI8qWN8Nuqgn6vsrWpvGk8tL6GGdF0facAd5e(kzBoIRk8tf4lK6Kh85KPW0ekXBjbv4NkvGGdF0facAd5e(cPo5bFDWnbFYEuQNa(CN5DN5BAjMdX8UaeZZLz(Qy(AmVd1ObP0PMfCHooIHAMhdMFNQTdUjRZcUqhhXqnZ)pMVoRl5gMVkMVgZRrVsQvNfYOPzpeZJbZ)F4t(tkiJg9kPi4Nkqf(PYFqWHp6cabTHCcFYEuQNa(aWlfRtt7qZ(NbXFk6riKDN8pMVgZlZfG04KZPiM3fmVByEE8yEa8sXciYCRHipKDN8pMVgZZFecJtNsdGiZTgI8qWxi1jp4BjZRmnzKHcv4NkUfco8rxaiOnKt4lK6Kh8TK5vMMmYqHpzpk1taFnvAcHnaee8j)jfKrJELue8tfOc)u5)qWHp6cabTHCcFYEuQNa(CN5RhZhvJ6rjl)rSnfbHW20TNB1sxaiOnZZJhZVt1Qy7aH1id1QJK75wz(Qy(AmpaEPy1zLAKPG3)S4omFnM3DMVJzBixPtTXEJSZX8yW8UZ8vyEmz(LGRgj2OxjeZx)mVeB0ReYu6qQtEHG5RI5)hZ3KeB0RKrNfI5RI55XJ5bWlflGiZTgI8q2DY)y(Amp)rimoDknaIm3AiYdbFHuN8GpGgxdHbjcewOc)uXnqWHp6cabTHCcFLSnhXvf(Pc8fsDYd(CYuyAcL4TKGk8tfUaeC4JUaqqBiNWNShL6jGVMknHWgacI5RX8UZ8UZ8Ug9eacYIJiJITdewMheZ)hZxJ5DN5RhZdGxk25KrFHo5zXDyEE8y(OAupkz5pITPiie2MU9CRw6cabTz(Qy(QyEE8yEKdjegn6vsrwfBhiSgzOmpgmFfMVkMNhpMhaVuSaIm3AiYdz3j)J5RX88hHW40P0aiYCRHipe8fsDYd(uSDGWAKHcv4NkCzi4WhDbGG2qoHVs2MJ4Qc)ub(cPo5bFozkmnHs8wsqf(PIlbbh(Olae0gYj8j7rPEc4d5qcHrJELuKfXFCiJmuMhdMVcZZJhZdGxkwarMBne5HS7K)X81yE(JqyC6uAaezU1qKhc(cPo5bFi(JdzKHcv4NkCji4WhDbGG2qoHpzpk1taF7uTDWnzBAjMdX8yW8UZ8HuN8SiSnTTYePmpMmFi1jpBhCtwzIuMV(zE6OE9hZxfZZbZth1R)SnTshZZJhZdGxkwPGIwgiDUvBtHuzEE8yEa8sXciYCRHipKDN8pMVgZZFecJtNsdGiZTgI8qWxi1jp4dHTPnuHk8vMBqyPgbbh(PceC4JUaqqBiNWxjBZrCvHFQaFHuN8GpNmfMMqjEljOc)8heC4JUaqqBiNWNShL6jGpa8sXIcxJvY0z02DY)GVqQtEWhkCnwjtNrdv4h3cbh(Olae0gYj8vY2Cexv4NkWxi1jp4ZjtHPjuI3scQWp)hco8rxaiOnKt4lK6Kh850Zsim87qXcFYEuQNa(qoKqy0OxjfzD6zjeg(DOyzEmy(kmFnMFNQThhBtlXCiM3fm))Hp5pPGmA0RKIGFQav4h3abh(Olae0gYj8vY2Cexv4NkWxi1jp4ZjtHPjuI3scQWpCbi4WhDbGG2qoHVqQtEWNtplHWWVdfl8j7rPEc4d5qcHrJELuK1PNLqy43HIL5XaeZ)h8j)jfKrJELue8tfOc)WLHGdF0facAd5e(kzBoIRk8tf4lK6Kh85KPW0ekXBjbv4hxcco8rxaiOnKt4lK6Kh81Jd8j7rPEc4REmVgc6ulkaOwZuXAPlae0M5RX8nvAcHnaeeZxJ51Oxj1QZcz00ShI5XG53PA7XX20smhI5XK5Dn6jaeKThhJosUrm))y(qQtE2ECS6i52OZcbFYFsbz0Oxjfb)ubQWpCji4WhDbGG2qoHVs2MJ4Qc)ub(cPo5bFozkmnHs8wsqf(PsDqWHp6cabTHCcFHuN8GVECGpzpk1taFAiOtTOaGAntfRLUaqqBMVgZ7oZxpMxhj3ZTY884X8nTeZHyExaI534DOtEm))y(6SUL5RX8ouJgKsNAwWf64igQzEmy(DQ2ECSol4cDCed1mFvmFnMxJELuRolKrtZEiMhdMFNQThhBtlXCiMhtM31ONaqq2ECm6i5gX8)J5DN5RW8yY87uT94y1rY9CRm))yE3Y8vX8)J5dPo5z7XXQJKBJole8j)jfKrJELue8tfOc)uPceC4JUaqqBiNWxjBZrCvHFQaFHuN8GpNmfMMqjEljOc)u5pi4WhDbGG2qoHpzpk1taFa4LIffUgRKPZOTnTeZHyExW8v(d(cPo5bFOW1yLmDgnuHFQ4wi4WhDbGG2qoHVs2MJ4Qc)ub(cPo5bFozkmnHs8wsqf(PY)HGdF0facAd5e(K9Oupb8bGxk2PZZWfh8rwCh4lK6Kh8TeZcuHFQ4gi4WhDbGG2qoHVLGRg6OE9h8vb(cPo5bFfQt5K4idWOe8j)jfKrJELue8tfOcv4tMPyN8peeC4NkqWHp6cabTHCcFYEuQNa(OJ61FmpgGyE3whZxJ5DN5Lzk2j)ZQZk1itbV)zBAjMdX8yW8UH55XJ5bWlfRoRuJmf8(Nf3H5Rc(cPo5bFauJOMBOc)8heC4JUaqqBiNWNShL6jGp6OE9NDtLrokZJbiMNluhZZJhZdGxkwDwPgzk49p7o5FWxi1jp4tNvQrMcE)dQWpUfco8rxaiOnKt4t2Js9eWhaEPy1zLAKPG3)S4oWxi1jp4JwCs(uBaYBdv4N)dbh(cPo5bFauJOM75wHp6cabTHCcv4h3abh(Olae0gYj8j7rPEc4JoQx)z3uzKJY8UG5RZ(NBy()X80r96p7sWv4lK6Kh81HR0L4itPPRA)Gk8dxaco8rxaiOnKt4t2Js9eWxi1XvYqhTmeI5XG53eAAAB0OxjfX884X8DmBd5kDQn2BKDoMhdM))Ub(cPo5bFk2SpeuHF4YqWHp6cabTHCcFYEuQNa(aWlfBtsUfeczkzljlUdZZJhZdGxkwDwPgzk49plUd8fsDYd(uSKb)as8BBkzljOc)4sqWHp6cabTHCcFYEuQNa(aWlfRoRuJmf8(Nf3H5RX8a4LIfGAe1CB3j)d(cPo5bFl0s2)mzXiWLZ2SBkwqqf(Hlbbh(Olae0gYj8j7rPEc4daVuS6SsnYuW7FwCh4lK6Kh8biYCBYIrXsg6OLFqf(PsDqWHp6cabTHCcFYEuQNa(K5cqACY5ueZdI5Rd(cPo5bFfQdHP00vTFqf(Psfi4WhDbGG2qoHpzpk1taFHuhxjdD0YqiMhdMFtOPPTrJELueZZJhZ7oZ3XSnKR0P2yVr25yEmyEUuDmFnMNoQx)z3uzKJY8yaI5DtDmFvWxi1jp4RKsCeTnr1OEuYaqXcuHFQ8heC4JUaqqBiNWNShL6jGVqQJRKHoAzieZJbZVj0002OrVskI55XJ57y2gYv6uBS3i7CmpgmpxOo4lK6Kh85G3t53CRgarGuOc)uXTqWHp6cabTHCcFYEuQNa(aWlfRoRuJmf8(Nf3b(cPo5bFR4rVN4mzXevJ6uXcv4Nk)hco8rxaiOnKt4t2Js9eWhaEPy1zLAKPG3)S4oWxi1jp4tMNKoTdL2MIiwiOc)uXnqWHp6cabTHCcFYEuQNa(aWlfRoRuJmf8(Nf3b(cPo5bF944iiZCgKtijOc)uHlabh(Olae0gYj8j7rPEc4daVuS6SsnYuW7FwCh4lK6Kh8XpBX2vAottO8Itsqf(Pcxgco8rxaiOnKt4t2Js9eWNg9kPwDwiJMM9qmVly(kw3W884X8UZ8UZ8A0RKAXsHqXADKkZJbZ7s1X884X8A0RKAXsHqXADKkZ7cqm)F1X8vX81yEn6vsT6Sqgnn7HyEmy()4smFvmppEmV7mVg9kPwDwiJMghPA(RoMhdM3T1X81yEn6vsT6Sqgnn7HyEmy())FMVk4lK6Kh81u4m3QPiIfcbv4NkUeeC4JUaqqBiNWNShL6jGp6OE9hZJbiM3T1X81yE3zEzMIDY)S6SsnYuW7F2MwI5qmpgmFf3W884X8a4LIvNvQrMcE)ZI7W8vbFHuN8GV5KrFHo5bv4NkCji4WhDbGG2qoHpzpk1taFA0RKA1zHmAA2dX8UG55cUH55XJ5DN51zHmAA2dX8UG5R4s1X81yE3zEa8sXcqnIAUT4omppEmpaEPyNtg9f6KNf3H5RI5Rc(cPo5bFoPo5bv4N)Qdco8rxaiOnKt4t2Js9eWNmxasJtoNIyExW8UH5RX80r96pMhdqmFi1jpBhCtwzIuMVgZVt12b3K1zbxOJJyOM5DbZ)NTcZxJ5bWlfRoRuJmf8(Nf3H5RX8UZ8a4LIfqK5wdrEilUdZZJhZxpMxdbDQfqK5wdrEilDbGG2mFvmFnM3DMVEmVgc6u7CYOVqN8S0facAZ884X8Ymf7K)zNtg9f6KNTPLyoeZJbZxXLy(Qy(AmF9yEa8sXoNm6l0jplUd8fsDYd(qyJDYFHeBOc)8xfi4WhDbGG2qoHVqQtEWxGW6ACeY0r1Y2iZoeWNShL6jGVnbGxk2oQw2gz2HWSja8sXUt(hZZJhZVja8sXkZBJl1XvYmh3MnbGxkwChMVgZRrVsQvNfYOPXrQg3whZ7cMVI1nmppEmF9y(nbGxkwzEBCPoUsM542Sja8sXI7W81yE3z(nbGxk2oQw2gz2HWSja8sXI0qYnZJbiM)p3W81pZxPoM)Fm)MaWlflGiZTjlgflzOJw(zXDyEE8yEDwiJMM9qmVly()xhZxfZxJ5bWlfRoRuJmf8(NTPLyoeZJbZxPo47Ifc(cewxJJqMoQw2gz2HaQWp)9heC4JUaqqBiNWxi1jp4t(tksTZBKgarGu4t2Js9eWN7mpDuV(ZUPYihL5XaeZth1R)SnTshZ)pM3TmFvmFnMhaVuS6SsnYuW7F2DY)y(AmF9y(OAupkz5IXVvbzk49plDbGG2WhvkKunxSqWN8NuKAN3inaIaPqf(5p3cbh(Olae0gYj8fsDYd(K)KIu78gPbqeif(K9Oupb8bGxkwDwPgzk49plUdZxJ5JQr9OKLlg)wfKPG3)S0facAdFuPqs1CXcbFYFsrQDEJ0aicKcv4N)(peC4JUaqqBiNWxi1jp4lQgcB0bYuYtnzX4K8Pg(K9Oupb8rh1R)SBQmYrzEmaX8UPo4JkfsQMlwi4lQgcB0bYuYtnzX4K8PgQWp)5gi4WhDbGG2qoHpzpk1taFa4LIvNvQrMcE)ZI7W884X86Sqgnn7HyExW8)vh8fsDYd(WrKzuAbbvOcFaHiojbbh(PceC4JUaqqBiNWNShL6jGpa8sXssX4GidkfrB3j)J5RX8a4LILKIXbrgb(fTDN8pMVgZ7oZ3uPje2aqqmppEmV7mFi1XvYqhTmeI5XG5RW81y(qQJRKzNQfHFLPjM3fmFi1XvYqhTmeI5RI5Rc(cPo5bFi8Rmnbv4N)GGdF0facAd5e(K9Oupb8bGxkwskghezqPiABtlXCiMhdMxgi1OZcX884X8a4LILKIXbrgb(fTTPLyoeZJbZldKA0zHGVqQtEWhsJgH3ReuHFCleC4JUaqqBiNWNShL6jGpa8sXssX4GiJa)I220smhI5XG5Lbsn6SqmppEmpkfrBiPyCqeZJbZxh8fsDYd(qA0LPjOc)8Fi4WhDbGG2qoHpzpk1taFa4LILKIXbrgukI220smhI5XG5Lbsn6SqmppEmVa)I2qsX4GiMhdMVo4lK6Kh8XVdfluHkuHVaxXMn89ML6luHkec]] )


end
