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
            copy = "incarnation_king_of_the_jungle"
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


    spec:RegisterAuras( {
        bt_brutal_slash = {
            duration = 4,
            max_stack = 1,
        },
        bt_moonfire = {
            duration = 4,
            max_stack = 1,            
        },
        bt_rake = {
            duration = 4,
            max_stack = 1
        },
        bt_shred = {
            duration = 4,
            max_stack = 1,
        },
        bt_swipe = {
            duration = 4,
            max_stack = 1,
        },
        bt_thrash = {
            duration = 4,
            max_stack = 1
        }
    } )


    local bt_auras = {
        bt_brutal_slash = "brutal_slash",
        bt_moonfire = "moonfire_cat",
        bt_rake = "rake",
        bt_shred = "shred",
        bt_swipe = "swipe_cat",
        bt_thrash = "thrash_cat"
    }

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

        -- Bloodtalons
        if talent.bloodtalons.enabled then
            for bt_buff, bt_ability in pairs( bt_auras ) do
                local last = action[ bt_ability ].lastCast

                if now - last < 4 then
                    applyBuff( bt_buff )
                    buff[ bt_buff ].applied = last
                    buff[ bt_buff ].expires = last + 4
                end
            end
        end

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

    spec:RegisterStateExpr( "active_bt_triggers", function ()
        if not talent.bloodtalons.enabled then return 0 end

        local btCount = 0

        for k, v in pairs( combo_generators ) do
            if k ~= this_action then
                local lastCast = action[ k ].lastCast

                if lastCast > last_bloodtalons and query_time - lastCast < 4 then
                    btCount = btCount + 1
                end
            end
        end

        return btCount
    end )

    spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end
        if query_time - action[ this_action ].lastCast < 4 then return false end
        return active_bt_triggers == 2
    end )

    spec:RegisterStateFunction( "proc_bloodtalons", function()
        for aura in pairs( bt_auras ) do
            removeBuff( aura )
        end

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

                applyBuff( "bt_brutal_slash" )
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
                applyBuff( "bt_moonfire" )
                if will_proc_bloodtalons then proc_bloodtalons() end
            end,

            copy = { 8921, 155625, "moonfire_cat", "lunar_inspiration" }
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

                applyBuff( "bt_rake" )
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

                applyBuff( "bt_shred" )
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

                applyBuff( "bt_swipe" )
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
                    applyBuff( "bt_thrash" )
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

    spec:RegisterPack( "Feral", 20201013.1, [[dO0)(aqisrXJqLGlbsbTjqvFcKcmkPqNskyvOs0RavMLu0TifKDj4xOIggQuhtf1YaP6zOsAAKQY1ifABKIQVHkHghPaohifToqkK5rkY9uH9rQYbjfOYcrfEiPaXejfuCrsbkTrsbvFKuGuNKuuYkvrMjifQBskqv7uLYpjfuAPKIs9urMQkPVskqXEv6VcnyrDyklwQEmHjd0Lr2mjFgeJguoTKvtQQ8AqYSr52sPDRQFdz4OQJtkqYYv8COMovxhW2vj(oP04jvvDEvQwpiLMpPY(j698EDtGMt7nOZn05(m3N5AGBOj3CrUQXn535PnXBcOmi0MERL2KgongBt82DgYa3RBcJagbTjyUZJHgXjNqkhgqpiqTCIRwaM5f6fJPCoXvRGZn1bkMRz9BFtGMt7nOZn05(m3N5AGBOj3CrUQVnH5jXE7m3CDtWkqq63(MajSytCbzwdNgJjZAygGcuEIliZAyfoQtJmFMRnLzOZn05Et8dsvmAtCbzwdNgJjZAygGcuEIliZAyfoQtJmFMRnLzOZn05wEsEYeEHECGFibQTBoChCEXMY6mQ5BT0Hcbmc(yVCQ5fJbqhClpXfK5eSHaL5dzM7MY8n0RHWVXJHHCzwZ2GIK5dz(Ctzo9gpggYLznBdksMpKzO3uMHgRzjZhYmxBkZjTfpjZhYS(KNmHxOhh4hsGA7Md3bNxSPSoJA(wlDOkgJMMxmgaDCwEYeEHECGFibQTBoChCEXMY6mQ5BT0HQymAAEXya0b3nl1HbT0uof0wmWOIryyd9G1djqV1zeO8Kj8c94a)qcuB3C4o48InL1zuZ3APJP4JEjGc38IXaOdUO8Kj8c94a)qcuB3C4o48InL1zuZ3APdh2yyyrVeqHBEXya0HgqEYeEHECGFibQTBoChCEXMY6mQ5BT0HdBmmSOxcOWnVyma6G7ML6WGwAkNcAlgyuXimSHEW6HeO36mcuEYeEHECGFibQTBoChCcv9GdbgX81uowEYeEHECGFibQTBoChCYpiTSML6OdOuHwe6HQ(OcnTbqK2xEYeEHECGFibQTBoChC6feAWrfWCVzPo6akvOfHEOQpQqtBaeP9HVdOubVGqdoQaM7bqK2xEYeEHECGFibQTBoChCkmpQqtR8K8exqM1Gv)jbGtGYmDHM7YSxTKm7Wiz2eoAK5clZ2fRywNrb5jt4f6XhcZJk002SuhDaLkimpQqtBaeP9LNmHxOhd3bNdWhnHxOpYkS38Tw6OBm7fuZsD4gJEp0nM9ckAkv9LFpqV1zei8DaLk0Iqpu1hvOPnaWlpzcVqpgUdoXqbWyXUHHjpzcVqpgUdo5hKwM8Kj8c9y4o4uymw0eEH(iRWEZ3APdbcXarAF5jt4f6XWDW5a8rt4f6JSc7nFRLou1xyy00SuhcuBhf5r17y9oAuJAOl2uwNrbfcye8XE5udYtMWl0JH7GZb4JMWl0hzf2B(wlDGDYyoSML6OdOuHonyAGkkmpaWRtxhqPc1lS5nVqFaGxNUoGsfWWmqK2wIbga41PRdOubmaii9rRTdGHfa41PRdOub(bPLfa4LNmHxOhd3bNgOX71fkI1AtR8Kj8c9y4o4uG(liOOOdJIy(Akh3SuhcuBhf5r17ynbD5jUGmFfgjZTiSlZK(ZtpUUqYmhxLzXDbJK5gVcBimmzobBiqzoPT4jzwGWUmF(SgLz6PbY9MYCRbfjZyGHKzTKmlSxMBnOiz2HzUmxVmRpzgcd1ngUb5jt4f6XWDWjpcXIdHraJGAwQd3y07HodHaDJHECGERZiq47akvOZqiq3yOhharAF4BKEAGChoUg0ixspnqUhgcc9W1O(4Ml7akvqWiBeg2RhsaGVHg07OXZN1Ogc6CLl7akvOEHnV5f6JqvpKisfDyuu)aEimkaW3a8MWRluS7rFkiqObFWT8Kj8c9y4o4Ca(Oj8c9rwH9MV1shDgcb6gd94ML6Wng9EOZqiq3yOhhO36mce(g7akvOZqiq3yOhharAFD6mHxxOy3J(uqGqd(a6nipzcVqpgUdohdkQP4UGrr3giKJpo3SuhdPgcdZ6msNoEAWf2P3JTamV4zfn6bI8Wyqrb(waMx8SIg5jt4f6XWDWPIgJfvd9q79ML6qGA7OipQEhFWT8Kj8c9y4o4SfHEvnuuyEtXDbJIUnqihFCUzPogsnegM1zK8Kj8c9y4o40HnggwuyEZsDmKAimmRZi5jt4f6XWDWzFaCJfXmddRzPoASdOubVGqdoQaM7baE4BCScmsxO3dgiiouVEnEgUwt)Jcy2aHWAibmBGq4OAmHxO3ynWLdjGzdek6vl1qdW3iMNySOBdeYXH(a4glIzgggxAcVqFOpaUXIyMHHfaTwdcbn0eEH(qFaCJfXmddliqyVb9A0eEH(ag2qGbqR1GqqdnHxOpGHneyqGWEdYtMWl0JH7GtS2INIcZBwQdmpXyr3giKJdyTfpffMRh0LNmHxOhd3bNyydb2SuhDaLkiyKncd71djaWlpzcVqpgUdofgJfnHxOpYkS38Tw6qvmgnnl1b90a5EWRwk6OyRP)A6SoDAg3y07HodHaDJHECGERZiq5j5jt4f6XHodHaDJHE8Xyqrnf3fmk62aHC8X5ML6OrnJxcOQhIoDnoKAimmRZi45PbxyNEp2cW8INv0OhiYdJbff4BbyEXZkAAOb47akvO7XXGIcGiTV8Kj8c94qNHqGUXqpgUdozaVnX6X81yEH(MI7cgfDBGqo(4CZsDmKAimmRZi47akvO7Xwe6v1qbqK2xEYeEHECOZqiq3yOhd3bNoSXWWIcZBkUlyu0Tbc54JZnl1XqQHWWSoJGVdOuHUhDyJHHfarAF5jt4f6XHodHaDJHEmChC2ha3yrmZWWAwQJoGsf6ESpaUXIyMHHfarAF5jt4f6XHodHaDJHEmChCI1w8uuyEZsD0buQq3JyTfpfarAF4X8eJfDBGqooG1w8uuyUENLNmHxOhh6mec0ng6XWDWjg2qGnl1rhqPcDpIHneyaeP9LNmHxOhh6mec0ng6XWDWjwBXtrH5nl1rhqPcDpI1w8uaeP9LNmHxOhh6mec0ng6XWDWPdBmmSOW8ML6OdOuHUhDyJHHfarAF5j5jt4f6XbbcXarA)JonyAGQzPo6akvGFqAzbqK2xEYeEHECqGqmqK2hUdoRxyZBEH(ML6OdOub(bPLfarAF5jUGmFDUlZ2dkZpYLzTg2jz(QgUmtpnqU3uM7aUmBmmsMHGKzfAKzOLgOKz7bLzHnV8Kj8c94GaHyGiTpChC6feAWrfWCVzPoONgi3dGKQeLRNg1OoDn2buQqNgmnqffMha4HVdOuHonyAGkkmpmuRvpwtN5Ad601yhqPc1lS5nVqFaGh(oGsfQxyZBEH(iu1djIurhgf1pGhcJcd1A1J10zU2G8Kj8c94GaHyGiTpChCIHzGiTTedSzPo6akvWli0GJkG5EaGh(oGsf60GPbQOW8ais7dFhqPc1lS5nVqFeQ6HerQOdJI6hWdHrbqK2h(oGsf4hKwwaeP9HxGA7OipQEhRj9bpiYdJbff4BbyEXZkA005GMdp90a5UE6JB5jt4f6XbbcXarAF4o4KA5rAPj2rpyZsD0buQGxqObhvaZ9aaV8Kj8c94GaHyGiTpChC2Pbtdu1dPzPo6akvWli0GJkG5EaGxNUoGsf60GPbQOW8aaVoDDaLkuVWM38c9rOQhsePIomkQFapegfa4LNmHxOhheiedeP9H7GtEKxOVzPo6akvOtdMgOIcZda8601buQq9cBEZl0hHQEirKk6WOO(b8qyuaGxEYeEHECqGqmqK2hUdoh7c9iaCun0dT3BwQd6PbY9aiPkr5AI7a01ixspnqUhAn9xEYeEHECqGqmqK2hUdofgJfnHxOpYkS38Tw6GWy6fK8Kj8c94GaHyGiTpChCcGPy5uBZ3APddd7I9eoog0IMOangRzPo6akvGFqAzbqK2h(gbPoGsfgdArtuGgJfbPoGsfarAFD6aPoGsfeOheq41fkwpurqQdOubaE4DBGqEWRwk6OiVWJCLBnDoOrD60mGuhqPcc0dci86cfRhQii1buQaap8ncsDaLkmg0IMOanglcsDaLkGDtaLEhqxJAOZCZLGuhqPcDgcbgrQOdJI0tT3da86052aH8GxTu0rrWI0K(4Ub47akvWli0GJkG5EyOwRESEN5Ub5jt4f6XbbcXarAF4o4eatXYPwCZsD0buQa)G0YcGiTp8n2buQGxqObhvaZ9aaVoDUnqip4vlfDueSinbDUBqEsEYeEHECGWy6f0HddnpUzPomHxxOi9uBry9ajCney0Tbc5yD6gRaJ0f69GbcId1RN(0O8Kj8c94aHX0li4o40HrrGVJaEWOcncQzPo6akvyibumcJJk0iOaaVoDDaLk4feAWrfWCpaWlpzcVqpoqym9ccUdoBPw0CpIurgGOaJGdzT4ML6OdOuHonyAGkkmpaWRtxhqPc1lS5nVqFeQ6HerQOdJI6hWdHrbaE5jt4f6XbcJPxqWDWzNHqGrKk6WOi9u79ML6OdOubVGqdoQaM7baE4fO2okYJQ3XhAuEYeEHECGWy6feChCQqcambgnOLMYPyNS2ML6WeEDHI0tTfH1dKW1qGr3giKJ1PRXXkWiDHEpyGG4q96bn5gE6PbY9aiPkr56DOrUBqEYeEHECGWy6feChCYdmL6E9qIDMH9ML6WeEDHI0tTfH1dKW1qGr3giKJ1PBScmsxO3dgiiouVEAo3YtMWl0JdegtVGG7Gtia2aw2hrQObT0GCynl1rhqPcEbHgCubm3da8YtMWl0JdegtVGG7Gtb6f07J5eyuXSwQzPo6akvWli0GJkG5EaGxEYeEHECGWy6feChCofppJI1hX8MGAwQJoGsf8ccn4OcyUha4LNmHxOhhimMEbb3bNArdd8cvFCim6Txqnl1rhqPcEbHgCubm3da8YtMWl0JdegtVGG7GZHm(6HevmRLWnf3fmk62aHCCZsD42aH8GxTu0rrWI005Gg1PRXgDBGqEagzmhwGx46Pb4wNo3giKhGrgZHf4fUMoGo3naVBdeYdE1srhfblspOdnBqNUgDBGqEWRwk6OiVWJqNB94k3W72aH8GxTu0rrWI0tF6Rb5j5jt4f6XbvXy0CmguutXDbJIUnqihFCUzPoUytzDgfufJrZXz4brEymOOaFlaZlEwrJMo4PbxyNEp2cW8INv0a)qQHWWSoJKNmHxOhhufJrdChCoguuZsDCXMY6mkOkgJMdOd)qQHWWSoJKNmHxOhhufJrdChCYaEBI1J5RX8c9nl1XfBkRZOGQymAo4k8dPgcdZ6msEYeEHECqvmgnWDWjwBXtnl1XfBkRZOGQymAo0N8Kj8c94GQymAG7GtmSHaLNKNmHxOhhu1xyy0CGTlgekoiBAwQJHudHHzDgjpXfKzn4nOizgdmKm7izgAPbjZomsMVytzDgjZyKmJrTKmJyGY8fJbqYmi6Hg4Ym9GYmaVmZQhcn1drEYeEHECqvFHHrdChCEXMY6mQ5BT0rNWECk(MxmgaDWDZsD4gJEpWpvRXIAhZHfO36mcuEIliZMWl0JdQ6lmmAG7GtXDbREiXl2uwNrnFRLo6e2JtX3eXF0A6FZlgdGoahGcmmfFWlbu4ieREcmI(4qQHWWAwQd3y07b(PAnwu7yoSa9wNrGYtMWl0JdQ6lmmAG7Gt(PAnwu7yoSMI7cgfDBGqo(4CZsDG5jgl62aHCCGFQwJf1oMdtVg5kCN5s3y07bS1PXrihwGERZiWgKNmHxOhhu1xyy0a3bNtX3uCxWOOBdeYXhNBwQJg1mEjGQEi6014qTw9y4eO2okYJQ3XCPBm69a2604iKdlqV1zeydAceymVqpxYDGR60bI8Wu8b(waMx8SIgnXtdUWo9ESfG5fpROPb4hsnegM1zK8Kj8c94GQ(cdJg4o4S1Q2ML6OdOuHAqFu)mT4aaV8Kj8c94GQ(cdJg4o4urdsuiaCSxo1S10)i90a5(X5MI7cgfDBGqo(4S8K8Kj8c94a2jJ5WogGpAcVqFKvyV5BT0rNHqGUXqpUzPoCJrVh6mec0ng6Xb6ToJaHVdOuHodHaDJHECaeP9LNmHxOhhWozmhgChCoguutXDbJIUnqihFCUzPoarEymOOaFlaZlEwrJMoh0C5jt4f6XbStgZHb3bNyydbkpjpzcVqpo0nM9c6ad8QAOML6OdOubsWkEmfXiMnbqK2h(oGsfibR4XuKb82earAF4BCi1qyywNr601Oj86cfPNAlcR3z4nHxxOiiYdyGxvdPjt41fksp1weUHgKNmHxOhh6gZEbb3bNy3gmWaHAwQJoGsfibR4XueJy2egQ1QhRNWWE0RwsNUoGsfibR4XuKb82egQ1QhRNWWE0RwsEYeEHECOBm7feChCIDBu1qnl1rhqPcKGv8ykYaEBcd1A1J1tyyp6vlPthgXSjscwXJj94wEYeEHECOBm7feChCQDmhwZsD0buQajyfpMIyeZMWqTw9y9eg2JE1s60XaEBIKGv8yspU30fAWf63BqNBOZ9zUpZ1nP1MVEi4nPbJgCA230SUPbn0izwMVcJK5QLhnUmRqJmdnaKugaZHgiZdPbfqneOmJrTKmBaoQ1CcuMfWShcHdYtqJRNK5ZAo0izwdc6VqJtGYCQA1GiZ47VB6VmdnuMDKmdngWKzW6sHl0lZiEAmhnYCJC2Gm3i01)gcYtYtAwT8OXjqzgAkZMWl0lZSc74G80Myf2X71nPkgJM96E78EDt0BDgbUCSjt4f630yqrBsmLttzB6InL1zuqvmgnY8HmFwMHxMbrEymOOaFlaZlEwrJmRPdzMNgCHD69ylaZlEwrJmdVmpKAimmRZOnjUlyu0Tbc5492513BqFVUj6ToJaxo2KykNMY20fBkRZOGQymAK5dzg6Ym8Y8qQHWWSoJ2Kj8c9BAmOO13BCDVUj6ToJaxo2KykNMY20fBkRZOGQymAK5dzMRYm8Y8qQHWWSoJ2Kj8c9BQfHEvnuuy(67n9Tx3e9wNrGlhBsmLttzB6InL1zuqvmgnY8HmRVnzcVq)MWAlEkkmF99Mg3RBYeEH(nHHne4MO36mcC5y913KQ(cdJM96E78EDt0BDgbUCSjXuonLTPHudHHzDgTjt4f63e2UyqO4GSz99g03RBIERZiWLJnH43eM8nzcVq)MUytzDgTPlgdG2e3BsmLttzBYng9EGFQwJf1oMdlqV1ze4MUyt8TwAtDc7XP4xFVX196MO36mcC5ytMWl0Vj(PAnwu7yoSnjMYPPSnH5jgl62aHCCGFQwJf1oMdtM1tMBuM5QmdNmFwM5sz2ng9EaBDACeYHfO36mcuMBytI7cgfDBGqoEVDE99M(2RBIERZiWLJnzcVq)MMIFtIPCAkBtnkZAgz2lbu1drM1PtMBuMhQ1QhlZWjZcuBhf5r17yzMlLz3y07bS1PXrihwGERZiqzUbzwtYmiWyEHEzMlLzUdCvM1PtMbrEyk(aFlaZlEwrJmRjzMNgCHD69ylaZlEwrJm3GmdVmpKAimmRZOnjUlyu0Tbc5492513BACVUj6ToJaxo2KykNMY2uhqPc1G(O(zAXba(nzcVq)MATQD99MMVx3e9wNrGlhBQ10)i90a5(MoVjt4f63KIgKOqa4yVCAtI7cgfDBGqoEVDE913eHX0lO96E78EDt0BDgbUCSjXuonLTjt41fksp1wewM1tMbjCney0Tbc5yzwNozEScmsxO3dgiiouVmRNmRpnUjt4f63KddnpE99g03RBIERZiWLJnjMYPPSn1buQWqcOyeghvOrqbaEzwNozUdOubVGqdoQaM7ba(nzcVq)MCyue47iGhmQqJGwFVX196MO36mcC5ytIPCAkBtDaLk0PbtdurH5baEzwNozUdOuH6f28MxOpcv9qIiv0Hrr9d4HWOaa)MmHxOFtTulAUhrQidquGrWHSw867n9Tx3e9wNrGlhBsmLttzBQdOubVGqdoQaM7baEzgEzwGA7OipQEhlZhYSg3Kj8c9BQZqiWisfDyuKEQ9(67nnUx3e9wNrGlhBsmLttzBYeEDHI0tTfHLz9KzqcxdbgDBGqowM1PtMBuMhRaJ0f69GbcId1lZ6jZqtULz4Lz6PbY9aiPkr5YSEhYSg5wMBytMWl0VjfsaGjWObT0uof7K1U(EtZ3RBIERZiWLJnjMYPPSnzcVUqr6P2IWYSEYmiHRHaJUnqihlZ60jZJvGr6c9EWabXH6Lz9KznN7nzcVq)M4bMsDVEiXoZW(67nU4EDt0BDgbUCSjXuonLTPoGsf8ccn4OcyUha43Kj8c9BccGnGL9rKkAqlnih267nnWEDt0BDgbUCSjXuonLTPoGsf8ccn4OcyUha43Kj8c9BsGEb9(yobgvmRLwFVbn3RBIERZiWLJnjMYPPSn1buQGxqObhvaZ9aa)MmHxOFttXZZOy9rmVjO13BN5EVUj6ToJaxo2KykNMY2uhqPcEbHgCubm3da8BYeEH(nPfnmWlu9XHWO3EbT(E78596MO36mcC5ytIPCAkBtUnqip4vlfDueSizwtY85GgLzD6K5gL5gLz3giKhGrgZHf4fUmRNmRb4wM1PtMDBGqEagzmhwGx4YSMoKzOZTm3GmdVm72aH8GxTu0rrWIKz9KzOdnL5gKzD6K5gLz3giKh8QLIokYl8i05wM1tM5k3Ym8YSBdeYdE1srhfblsM1tM1N(K5g2Kj8c9BAiJVEirfZAj86RVPUXSxq7192596MO36mcC5ytIPCAkBtDaLkqcwXJPigXSjaI0(Ym8YChqPcKGv8ykYaEBcGiTVmdVm3OmpKAimmRZizwNozUrz2eEDHI0tTfHLz9K5ZYm8YSj86cfbrEad8QAizwtYSj86cfPNAlclZniZnSjt4f63eg4v1qRV3G(EDt0BDgbUCSjXuonLTPoGsfibR4XueJy2egQ1QhlZ6jZcd7rVAjzwNozUdOubsWkEmfzaVnHHAT6XYSEYSWWE0RwAtMWl0VjSBdgyGqRV346EDt0BDgbUCSjXuonLTPoGsfibR4XuKb82egQ1QhlZ6jZcd7rVAjzwNozgJy2ejbR4XKmRNmZ9MmHxOFty3gvn067n9Tx3e9wNrGlhBsmLttzBQdOubsWkEmfXiMnHHAT6XYSEYSWWE0RwsM1PtMzaVnrsWkEmjZ6jZCVjt4f63K2XCyRV(MajLbW896E78EDt0BDgbUCSjXuonLTPoGsfeMhvOPnaI0(BYeEH(njmpQqt767nOVx3e9wNrGlhBsmLttzBYng9EOBm7fu0uQ6l)EGERZiqzgEzUdOuHwe6HQ(OcnTba(nzcVq)MgGpAcVqFKvyFtSc7X3APn1nM9cA99gx3RBYeEH(nHHcGXIDddBt0BDgbUCS(EtF71nzcVq)M4hKw2MO36mcC5y99Mg3RBIERZiWLJnzcVq)MegJfnHxOpYkSVjwH94BT0MeiedeP9xFVP571nrV1ze4YXMet50u2MeO2okYJQ3XYSEhYCJYSgLznKmFXMY6mkOqaJGp2lNK5g2Kj8c9BAa(Oj8c9rwH9nXkShFRL2KQ(cdJM13BCX96MO36mcC5ytIPCAkBtDaLk0PbtdurH5baEzwNozUdOuH6f28MxOpaWlZ60jZDaLkGHzGiTTedmaWlZ60jZDaLkGbabPpATDamSaaVmRtNm3buQa)G0Yca8BYeEH(nnaF0eEH(iRW(Myf2JV1sBc7KXCyRV30a71nzcVq)MmqJ3RlueR1M2nrV1ze4YX67nO5EDt0BDgbUCSjXuonLTjbQTJI8O6DSmRjzg6BYeEH(njq)feuu0HrrmFnLJxFVDM796MO36mcC5ytIPCAkBtUXO3dDgcb6gd94a9wNrGYm8YChqPcDgcb6gd94ais7lZWlZnkZ0tdK7YmCYmxdAuM5szMEAGCpmee6Lz4K5gLz9XTmZLYChqPccgzJWWE9qca8YCdYCdYSEhYCJY85ZAuM1qYm05QmZLYChqPc1lS5nVqFeQ6HerQOdJI6hWdHrbaEzUbzgEz2eEDHIDp6tbbcnyz(qM5EtMWl0VjEeIfhcJagbT(E78596MO36mcC5ytIPCAkBtUXO3dDgcb6gd94a9wNrGYm8YCJYChqPcDgcb6gd94ais7lZ60jZMWRluS7rFkiqOblZhYm0L5g2Kj8c9BAa(Oj8c9rwH9nXkShFRL2uNHqGUXqpE992zOVx3e9wNrGlhBYeEH(nngu0Met50u2MgsnegM1zKmRtNmZtdUWo9ESfG5fpROrM1tMbrEymOOaFlaZlEwrZMe3fmk62aHC8E7867TZCDVUj6ToJaxo2KykNMY2Ka12rrEu9owMpKzU3Kj8c9BsrJXIQHEO9(67TZ6BVUj6ToJaxo2Kj8c9BQfHEvnuuy(Met50u2MgsnegM1z0Me3fmk62aHC8E7867TZACVUj6ToJaxo2KykNMY20qQHWWSoJ2Kj8c9BYHnggwuy(67TZA(EDt0BDgbUCSjXuonLTPgL5oGsf8ccn4OcyUha4Lz4L5gL5XkWiDHEpyGG4q9YSEYCJY8zzgozU10)OaMnqiSmRHKzbmBGq4OAmHxO3yYCdYmxkZdjGzdek6vljZniZniZWlZnkZyEIXIUnqihh6dGBSiMzyyYmxkZMWl0h6dGBSiMzyybqR1GqYmNYSj8c9H(a4glIzggwqGWUm3GmRNm3OmBcVqFadBiWaO1AqizMtz2eEH(ag2qGbbc7YCdBYeEH(n1ha3yrmZWWwFVDMlUx3e9wNrGlhBsmLttzBcZtmw0Tbc54awBXtrH5YSEYm03Kj8c9BcRT4POW813BN1a71nrV1ze4YXMet50u2M6akvqWiBeg2RhsaGFtMWl0VjmSHaxFVDgAUx3e9wNrGlhBsmLttzBIEAGCp4vlfDuS10FzwtY8zzwNozwZiZUXO3dDgcb6gd94a9wNrGBYeEH(njmglAcVqFKvyFtSc7X3APnPkgJM1xFt8djqTDZ3R7TZ71nrV1ze4YXMq8Bct(MmHxOFtxSPSoJ20fJbqBI7nDXM4BT0MuiGrWh7LtRV3G(EDt0BDgbUCSje)MWKVjt4f630fBkRZOnDXya0MoVPl2eFRL2KQymAwFVX196MO36mcC5yti(nHjFtMWl0VPl2uwNrB6IXaOnX9Met50u2MmOLMYPG2IbgvmcdBOhSEib6ToJa30fBIV1sBsvmgnRV303EDt0BDgbUCSje)MWKVjt4f630fBkRZOnDXya0M4IB6InX3APnnfF0lbu413BACVUj6ToJaxo2eIFtyY3Kj8c9B6InL1z0MUymaAtAGnDXM4BT0MCyJHHf9safE99MMVx3e9wNrGlhBcXVjm5BYeEH(nDXMY6mAtxmgaTjU3KykNMY2KbT0uof0wmWOIryyd9G1djqV1ze4MUyt8TwAtoSXWWIEjGcV(EJlUx3Kj8c9BcQ6bhcmI5RPC8MO36mcC5y99MgyVUj6ToJaxo2KykNMY2uhqPcTi0dv9rfAAdGiT)MmHxOFt8dslB99g0CVUj6ToJaxo2KykNMY2uhqPcTi0dv9rfAAdGiTVmdVm3buQGxqObhvaZ9ais7Vjt4f63KxqObhvaZ913BN5EVUjt4f63KW8OcnTBIERZiWLJ1xFtyNmMdBVU3oVx3e9wNrGlhBsmLttzBYng9EOZqiq3yOhhO36mcuMHxM7akvOZqiq3yOhharA)nzcVq)MgGpAcVqFKvyFtSc7X3APn1zieOBm0JxFVb996MO36mcC5ytMWl0VPXGI2KykNMY2eiYdJbff4BbyEXZkAKznjZNdA(Me3fmk62aHC8E7867nUUx3Kj8c9BcdBiWnrV1ze4YX6RVjbcXarA)96E78EDt0BDgbUCSjXuonLTPoGsf4hKwwaeP93Kj8c9BQtdMgOwFVb996MO36mcC5ytIPCAkBtDaLkWpiTSais7Vjt4f63u9cBEZl0V(EJR71nrV1ze4YXMet50u2MONgi3dGKQeLlZ6jZAuJYSoDYCJYChqPcDAW0avuyEaGxMHxM7akvOtdMgOIcZdd1A1JLznjZN5Qm3GmRtNm3Om3buQq9cBEZl0ha4Lz4L5oGsfQxyZBEH(iu1djIurhgf1pGhcJcd1A1JLznjZN5Qm3WMmHxOFtEbHgCubm3xFVPV96MO36mcC5ytIPCAkBtDaLk4feAWrfWCpaWlZWlZDaLk0PbtdurH5bqK2xMHxM7akvOEHnV5f6JqvpKisfDyuu)aEimkaI0(Ym8YChqPc8dsllaI0(Ym8YSa12rrEu9owM1KmRpzgEzge5HXGIc8TamV4zfnYSMK5ZbnxMHxMPNgi3Lz9Kz9X9MmHxOFtyygisBlXaxFVPX96MO36mcC5ytIPCAkBtDaLk4feAWrfWCpaWVjt4f63e1YJ0stSJEW13BA(EDt0BDgbUCSjXuonLTPoGsf8ccn4OcyUha4LzD6K5oGsf60GPbQOW8aaVmRtNm3buQq9cBEZl0hHQEirKk6WOO(b8qyuaGFtMWl0VPonyAGQEiRV34I71nrV1ze4YXMet50u2M6akvOtdMgOIcZda8YSoDYChqPc1lS5nVqFeQ6HerQOdJI6hWdHrba(nzcVq)M4rEH(13BAG96MO36mcC5ytIPCAkBt0tdK7bqsvIYLznjZChGUgLzUuMPNgi3dTM(Vjt4f630yxOhbGJQHEO9(67nO5EDt0BDgbUCSjt4f63KWySOj8c9rwH9nXkShFRL2eHX0lO13BN5EVUj6ToJaxo2Kj8c9BYWWUypHJJbTOjkqJX2KykNMY2uhqPc8dsllaI0(Ym8YCJYmi1buQWyqlAIc0ySii1buQais7lZ60jZGuhqPcc0dci86cfRhQii1buQaaVmdVm72aH8GxTu0rrEHh5k3YSMK5ZbnkZ60jZAgzgK6akvqGEqaHxxOy9qfbPoGsfa4Lz4L5gLzqQdOuHXGw0efOXyrqQdOubSBcOKz9oKzORrzwdjZN5wM5szgK6akvOZqiWisfDyuKEQ9EaGxM1PtMDBGqEWRwk6OiyrYSMKz9XTm3GmdVm3buQGxqObhvaZ9WqTw9yzwpz(m3YCdB6TwAtgg2f7jCCmOfnrbAm267TZN3RBIERZiWLJnjMYPPSn1buQa)G0YcGiTVmdVm3Om3buQGxqObhvaZ9aaVmRtNm72aH8GxTu0rrWIKznjZqNBzUHnzcVq)MaWuSCQfV(6BQZqiq3yOhVx3BN3RBIERZiWLJnzcVq)MgdkAtIPCAkBtnkZAgz2lbu1drM1PtMBuMhsnegM1zKmdVmZtdUWo9ESfG5fpROrM1tMbrEymOOaFlaZlEwrJm3Gm3GmdVm3buQq3JJbffarA)njUlyu0Tbc5492513BqFVUj6ToJaxo2Kj8c9BQfHEvnuuy(Met50u2MgsnegM1zKmdVm3buQq3JTi0RQHcGiT)Me3fmk62aHC8E7867nUUx3e9wNrGlhBYeEH(n5WgddlkmFtIPCAkBtdPgcdZ6msMHxM7akvO7rh2yyybqK2FtI7cgfDBGqoEVDE99M(2RBIERZiWLJnjMYPPSn1buQq3J9bWnweZmmSais7Vjt4f63uFaCJfXmddB99Mg3RBIERZiWLJnjMYPPSn1buQq3JyTfpfarAFzgEzgZtmw0Tbc54awBXtrH5YSEY85nzcVq)MWAlEkkmF99MMVx3e9wNrGlhBsmLttzBQdOuHUhXWgcmaI0(BYeEH(nHHne467nU4EDt0BDgbUCSjXuonLTPoGsf6EeRT4Pais7Vjt4f63ewBXtrH5RV30a71nrV1ze4YXMet50u2M6akvO7rh2yyybqK2FtMWl0Vjh2yyyrH5RV(6BYaCyOztPQvdY6RVl]] )

    
end
