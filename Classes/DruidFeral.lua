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


    -- Ticks gained on refresh.
    local tick_calculator = setfenv( function( t, action, pmult )
        local remaining_ticks = 0
        local potential_ticks = 0
        local remains = t.remains
        local tick_time = t.tick_time
    
        local duration = t.duration * ( action == "primal_wrath" and 0.5 or 1 )
        local app_duration = min( target.time_to_die, fight_remains, class.abilities[ this_action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time
        
        local ttd = fight_remains
    
        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = action ~= "primal_wrath" and max( 0, min( duration, 1.3 * t.duration * 1, ttd ) ) or duration
        end
    
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time
    
        Hekili:Debug( "%s %.2f %.2f %.2f %.2f", action, remains, app_duration, app_ticks, potential_ticks )

        if action == "thrash_cat" then
            return max( 0, active_enemies - active_dot.thrash_cat ) * app_ticks + active_dot.thrash_cat * ( potential_ticks - remaining_ticks )
        elseif action == "primal_wrath" then
            return max( 0, active_enemies - active_dot.rip ) * app_ticks + active_dot.rip * ( potential_ticks - remaining_ticks )
        end
            
        return max( 0, potential_ticks - remaining_ticks )
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

        -- Alias for Berserk vs. Incarnation
        bs_inc = {
            alias = { "berserk", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
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

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, this_action, false )
                end,
        
                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
                end,
            }            
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
            copy = "lunar_inspiration",

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, this_action, false )
                end,
        
                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
                end,
            }            
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
            copy = "rake_bleed",

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, this_action, false )
                end,
        
                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
                end,
            }
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

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, this_action, false )
                end,
        
                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
                end,
            }
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

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, this_action, false )
                end,
        
                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
                end,
            }
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
            max_stack = 2,
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

    spec:RegisterStateExpr( "persistent_multiplier", function( act )
        local mult = 1

        act = act or this_action

        if not act then return mult end

        if tf_spells[ act ] and buff.tigers_fury.up then mult = mult * snapshot_value.tigers_fury end
        if bt_spells[ act ] and buff.bloodtalons.up then mult = mult * snapshot_value.bloodtalons end
        if mc_spells[ act ] and buff.clearcasting.up then mult = mult * snapshot_value.clearcasting end
        if pr_spells[ act ] and ( buff.incarnation.up or buff.berserk.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * snapshot_value.prowling end

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
            stat.haste = stat.haste + 0.01
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

        if prev_gcd[1].feral_frenzy and now - action.feral_frenzy.lastCast < gcd.execute and combo_points.current < 5 then
            gain( 5, "combo_points" )
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


    spec:RegisterStateTable( "druid", setmetatable( {},{ 
        __index = function( t, k )
            if k == "catweave_bear" then return false
            elseif k == "owlweave_bear" then return false
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif debuff[ k ] ~= nil then return debuff[ k ]
            end
        end
    } ) )


    spec:RegisterStateExpr( "bleeding", function ()
        return debuff.rake.up or debuff.rip.up or debuff.thrash_cat.up or debuff.feral_frenzy.up
    end )

    spec:RegisterStateExpr( "effective_stealth", function ()
        return buff.prowl.up or buff.berserk.up or buff.incarnation.up
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

            copy = "berserk_cat"
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
                return max( 0, 25 * ( buff.incarnation.up and 0.8 or 1 ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132141,

            form = "cat_form",
            talent = "brutal_slash",

            damage = function () return min( 5, active_enemies ) * stat.attack_power * 0.69 end, -- TODO: Check damage.

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
                    local nrg = 50 * ( buff.incarnation.up and 0.8 or 1 )

                    if energy[ "time_to_" .. nrg ] - debuff.rip.remains > 0 then
                        return max( 25, energy.current + ( (debuff.rip.remains - 1 ) * energy.regen ) )
                    end
                end
                return 50 * ( buff.incarnation.up and 0.8 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            indicator = function ()
                if settings.cycle and talent.sabertooth.enabled and dot.rip.down and active_dot.rip > 0 then return "cycle" end
            end,

            -- Use maximum damage.
            damage = function () return 0.9828 * stat.attack_power * 2 end,

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

                if buff.eye_of_fearful_symmetry.up then
                    gain( 2, "combo_points" )
                    removeStack( "eye_of_fearful_symmetry" )
                end

                opener_done = true
            end,

            copy = "ferocious_bite_max"
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

            spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            form = "cat_form",
            usable = function () return combo_points.current > 0 end,

            handler = function ()
                applyDebuff( "target", "maim", combo_points.current )
                spend( combo_points.current, "combo_points" )

                removeBuff( "iron_jaws" )

                if buff.eye_of_fearful_symmetry.up then
                    gain( 2, "combo_points" )
                    removeStack( "eye_of_fearful_symmetry" )
                end

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

            spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
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

            apply_duration = function () 
                return 2 + 2 * combo_points.current
            end,

            usable = function () return combo_points.current > 0, "no combo points" end,
            handler = function ()
                applyDebuff( "target", "rip", mod_circle_dot( 2 + 2 * combo_points.current ) )
                active_dot.rip = active_enemies

                spend( combo_points.current, "combo_points" )
                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then
                    gain( 2, "combo_points" )
                    removeStack( "eye_of_fearful_symmetry" )
                end

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
                return 35 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
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

            spend = function () return 30 * ( buff.incarnation.up and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132152,

            aura = "rip",
            cycle = "rip",
            min_ttd = 9.6,

            form = "cat_form",

            apply_duration = function ()
                return 4 + 4 * combo_points.current
            end,

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

                if buff.eye_of_fearful_symmetry.up then gain( 2, "combo_points" ) end

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

            spend = function () return 25 * ( buff.incarnation.up and 0.8 or 1 ) end,
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

                if buff.eye_of_fearful_symmetry.up then
                    gain( 2, "combo_points" )
                    removeStack( "eye_of_fearful_symmetry" )
                end

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
                return 40 * ( buff.incarnation.up and 0.8 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            damage = function () return 0.46 * stat.attack_power * ( bleeding and 1.2 or 1 ) * ( effective_stealth and ( 1.6 * 1 + 0.01 * stat.crit * ( level > 53 and 2 or 1 ) ) or 1 ) end,

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
                return max( 0, ( 35 * ( buff.incarnation.up and 0.8 or 1 ) ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 134296,

            notalent = "brutal_slash",
            form = "cat_form",

            damage = function () return min( 5, active_enemies ) * stat.attack_power * 0.35 * ( bleeding and 1.2 or 1 ) * ( 1 + stat.crit * 0.01 ) end, -- TODO: Check damage.

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
                return 40 * ( buff.incarnation.up and 0.8 or 1 )
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
                    applyBuff( "eye_of_fearful_symmetry", nil, 2 )
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

    spec:RegisterPack( "Feral", 20201019, [[dOuUebqiaQ6rIaUeqPQnbP6tIa1OaiNsrQvjcXRiIMfaULiu2fL(fKYWePCmGQLbu8mrQAAksCnrqBtKk(MiKmoakohaLwNivY7ebsMNIKUNIAFejhuei1cjcpueQAIIqQ2iav8rGsLoPivQvQiMPiqCtriL2jq6NaLkwkav6PszQaQVkcvAVQ6VIAWuCyslwHhtyYs1Lr2SeFgsgTK60cRweQ41aXSr1TLKDRYVbnCI64IqkwUsphQPt11Hy7aY3frJhOuoprQ1duY8fj7hLFWFG)wxD6bfmPbM0apnWbSwWaEcbmPpHFZLwM(MSkarrrF70k6Bao0Q8VjRsZHA)b(ByiYkOVv7UmoDHgAOcVgzyfWk0Wrfcx9aEIvloA4OsG23gib3t33p(wxD6bfmPbM0apnWbSwWaEcbmGjr9nSmjEqbpT0)T6O3P7hFRtyX3saMbWHwLZmj6ls0ztsaMbSJWHdAzgWbSaWmGjnWKgBcBscWmj(A9qr40fBscWmjgZiXI4kNzACfxZmOXmTKHmXmDKnoumJe0IPfeMbnMjDFcDp1d4XmrHzcNzgK6yMPvVuNz6ALIISSjjaZKymdGlvwcxZmaxVkUMzkWLzsCdENzaC4eUEPRhhklBscWmjgZKOdVeSZmljVWKCMjoMraRgQNGIz8AAPemMzoiZidJZTFtEHLGtFlbygahAvoZKOVirNnjbygWochoOLzahWcaZaM0atASjSjjaZK4R1dfHtxSjjaZKymJelIRCMPXvCnZGgZ0sgYeZ0r24qXmsqlMwqyg0yM09j09upGhZefMjCMzqQJzMw9sDMPRvkkYYMKamtIXmaUuzjCnZaC9Q4AMPaxMjXn4DMbWHt46LUECOSSjjaZKymtIo8sWoZSK8ctYzM4ygbSAOEckMXRPLsWyM5GmJmmo3YMWMOcpGh2kVKawnuxYz0as3qhCcGtRO5cezfY5r4eaaPCeAon2KeGzA1l1zMzMjnaygqHxIHpvgxdDMbWvbHyMzMbCayM2PY4AOZmaUkieZmZmGbaMjbjDZmZmt6bGzAjdzIzMzMPWMOcpGh2kVKawnuxYz0as3qhCcGtRO5sW50caqkhHMbNnrfEapSvEjbSAOUKZObKUHo4eaNwrZLGZPfaGuocnNgarzwblAdNSjdEpx4eUEPRhhklD6GtD2KeGzAcLtmtYWRzMAf7KLnrfEapSvEjbSAOUKZObKUHo4eaNwrZBiN9qacgaGuocnNOa7RvStSjQWd4HTYljGvd1LCgnG0n0bNa40kA2RxfxN9qacgaGuocndyytuHhWdBLxsaRgQl5mAaPBOdobWPv0SxVkUo7HaemaaPCeAonaIYScw0goztg8EUWjC9sxpouw60bN6SjQWd4HTYljGvd1LCgnqIRVupJLJnCmBIk8aEyR8scy1qDjNrtEHj5aeL5bsPyRGWdK4Yf4wz7WKhBIk8aEyR8scy1qDjNrtOEUa3kaIY8aPuSvq4bsC5cCRSDyYJnHnrfEap88ICzv4b8Y8a7aCAfnpuUEccGOmpqkfBfeEGexUa3klImBIk8aEyjNrddccNNhkUMnrfEapSKZOjupxGBfarzEGukwH65cCRSDyYJnjbygv4b8WsoJM8ctYztsaMbSZrmdUg6md2jL71mtfjQ1leyMXvqiMrEd4gU0SjQWd4HLCgTf5YQWd4L5b2b40kAg7KY9AaIY8aPuS4ATdtwr8UfrovQbsPyLxysUfrMnrfEapSKZOjuopRcpGxMhyhGtROzbeY7WKhBIk8aEyjNrBrUSk8aEzEGDaoTIMlXf4AAbikZcy1aMLHX5yPMbuctmG0n0bNSfiYkKZJWPPztsaMjrlc3JedLOZmyNuUxZmDiHzMd6SjQWd4HLCgTf5YQWd4L5b2b40kAg7KY9AaIY8aPuSdCooHfrovQbsPyXi9oDzTAGGRTiYSjQWd4HLCgnb8acccL9AkJLJnCmarz2voDUDWHWURC4HT0Pdo1rFGuk2bhc7UYHh22HjVuPa8UYPZTdoe2DLdpSLoDWPo6cy1aMLHX54Pcg2KeGzaUMyMki2zgcSjthoaIygjaMzesl4eZaiGRxcxZmT6L6mtlzitmJaIDMbCWtiZqhTOKgaMPsbHygmYsmtsIze6XmvkieZ41QZmXXmtHzqXHdLJNMnrfEapSKZOjdH88syiYkiaIYSRC6C7GdHDx5WdBPthCQJ(aPuSdoe2DLdpSTdtEOdi6OfL0sMEBcte6OfL02LqrNKaAkPLidKsXk4KUcf7XHYIip90sndiWbpHjgysFImqkfBCcDp1d4Lbjouzyj71uoXb5qXjlI80ORcpaIYdp7BGcfT450ytuHhWdl5mAlYLvHhWlZdSdWPv08GdHDx5WddquMDLtNBhCiS7khEylD6GtD0b0aPuSdoe2DLdpSTdtEPsPcpaIYdp7BGcfT4zWmnBIk8aEyjNrBvqiaesl4u21ff54zWbikZlvwcxRdoLkLmT4a7055keUhY8GwP6q3UkiKvUcH7HmpOLnrfEapSKZOvOv55YshyjnarzwaRgWSmmohpNgBIk8aEyjNrRccVsSuwOoacPfCk76IIC8m4aeL5LklHR1bNytuHhWdl5mAE9Q46SqDaIY8sLLW16GtO3xKOB96vX1zH6wpeGGZO04OEgE5LklHRLciDdDWjRxVkUo7HaemBIk8aEyjNrBSiUYZyUIRbikZaAGukwpqrloxqwPTiYOdOvJEMaIo3Q9o2gNuacCjRuWwwuRlkcNyIADrr4CzvHhWt5tNiljQ1ffL9OIMEA0bewM48SRlkYX2XI4kpJ5kUoruHhWZowex5zmxX12UwPOiWEv4b8SJfXvEgZvCTvaX(0sbiv4b8S46L62UwPOiWEv4b8S46L6wbe7tZMOcpGhwYz0WjdzkluhGOmJLjop76IICSfNmKPSqDPadBIk8aEyjNrdxVuhGOmpqkfRGt6kuShhklImBIk8aEyjNrtOCEwfEaVmpWoaNwrZLGZPLnHnrfEapSDWHWURC4HNxfecaH0coLDDrroEgCaIYmGa8EiajouPsbOLklHR1bNqxMwCGD68Cfc3dzEqRuDOBxfeYkxHW9qMh0o90Opqkf7WZRccz7WKh69fj62vbHSEiabNrPXr9m8Ylvwcxl1myytuHhWdBhCiS7khEyjNrJJC6MJdlhR6b8aqiTGtzxxuKJNbhGOmVuzjCTo4e6dKsXo8CfeELyjBhM8ytuHhWdBhCiS7khEyjNrZRxfxNfQdGqAbNYUUOihpdoarzEPYs4ADWj0hiLID4zVEvCTTdtEO3xKOB96vX1zH6wpeGGZO04OEgE5LklHRLcWWMOcpGh2o4qy3vo8WsoJ2yrCLNXCfxdquMhiLID45XI4kpJ5kU22Hjp2ev4b8W2bhc7UYHhwYz0WjdzkluhGOmpqkf7WZ4KHmz7WKh6yzIZZUUOihBXjdzkluxkWztuHhWdBhCiS7khEyjNrdxVuhGOmpqkf7WZ46L62om5XMOcpGh2o4qy3vo8WsoJgozitzH6aeL5bsPyhEgNmKjBhM8ytuHhWdBhCiS7khEyjNrZRxfxNfQdquMhiLID4zVEvCTTdtESjSjQWd4HTciK3HjV5bTyAbHnrfEapSvaH8om5j5mAXj09upGhBIk8aEyRac5DyYtYz0OkzysAZd41ztuHhWdBfqiVdtEsoJ2QarhebNllDGL0aeL5bsPyh4CCclICQuUYPZTXj09upGNLoDWPo6ciK3HjpBCcDp1d4zxQsJdlvjqv75LQ04WPsb4DLtNBJtO7PEaplD6GtD0fqiVdtE2bTyAbXUuLghwQsGQ2ZlvPXHztuHhWdBfqiVdtEsoJM2vzpaIY4K6wbquM70aPuSRcczrKrVtdKsXUHSfrMnjbygGxPzg96mZbDMjPIDIzagWHzOJwusdaZmqCMr5yiZGcYmf4YmGfTGWm61zM4e6ESjQWd4HTciK3HjpjNrZdu0IZfKvAaIYmD0IsABNkHiCPsyctLQdD7QGq2LklHR1bNsLQdD7gY2LklHR1bNqxaRgWSmmohplGvdywggNJTvkylvkanqkf7aNJtyrKrFGuk2bohNWUuLghEQGN(PztuHhWdBfqiVdtEsoJgUw7WKveVdquMhiLI1du0IZfKvAlIm6dKsXoW54e2om5HUawnGzzyCoEQtb9o0TRcczLRq4EiZdANk420bD6OfL0snL0ytuHhWdBfqiVdtEsoJ2GwmTGehkaIY8aPuSEGIwCUGSsBrKtLAGuk2bohNWIiZMOcpGh2kGqEhM8KCgnzOhWdGOmpqkf7aNJtyrKtLAGuk2bhc7CeSBrKztuHhWdBfqiVdtEsoJMq58Sk8aEzEGDaoTIMjmMobXMOcpGh2kGqEhM8KCgnemLdNQa40kAwX1aPhHZRcwWnlGRYbikZdKsXkVWKCBhM8qhqDAGuk2vbl4MfWv55onqkfBhM8sLQtdKsXkGxhr4bquooqYDAGukwez0DDrrU1Jkk7WSSWZPpTPcUnHPsb470aPuSc41reEaeLJdKCNgiLIfrgDa1PbsPyxfSGBwaxLN70aPuSyxfGi1mysyIbEAjsNgiLIDWHWEgwYEnLPJQK2IiNkLRlkYTEurzhM7bn1PK20OpqkfRhOOfNliR02LQ04WsbEAtZMOcpGh2kGqEhM8KCgnemLdNQWaeL5bsPyLxysUTdtEOdObsPy9afT4CbzL2IiNkLRlkYTEurzhM7bnvWK20SjSjQWd4HTegtNGM9A4EyaIYSk8aikthvfewQoHJL6zxxuKJtLA1ONjGOZTAVJTXj1usiBIk8aEylHX0jijNrZRPmYnGixpxGRGaikZdKsXUKaeoHX5cCfKfrovQbsPy9afT4CbzL2IiZMOcpGh2symDcsYz0QOk4kDgwYCer0Z9L0kmarzEGuk2bohNWIiZMOcpGh2symDcsYz0gCiSNHLSxtz6OkPbikZdKsX6bkAX5cYkTfrgDbSAaZYW4C8CcztuHhWdBjmMobj5mAfOabt9Scw0goLhKwbquMvHharz6OQGWs1jCSup76IICCQuaA1ONjGOZTAVJTXjfGnn0PJwusB7ujeHl1CctBA2ev4b8WwcJPtqsoJMmYgfPJdvEWvSdquMvHharz6OQGWs1jCSup76IICCQuRg9mbeDUv7DSnoPsN0ytuHhWdBjmMobj5mAOq0Th6LHLScw0c9AaIY8aPuSEGIwCUGSsBrKztuHhWdBjmMobj5mAc4jOZx1PEUW1kcGOmpqkfRhOOfNliR0wez2ev4b8WwcJPtqsoJ2gYYCkhxglRccGOmpqkfRhOOfNliR0wez2ev4b8WwcJPtqsoJws4Y7arXLxcdp9eearzEGukwpqrloxqwPTiYSjQWd4HTegtNGKCgTLu54qLlCTIWaiKwWPSRlkYXZGdquMDDrrU1Jkk7WCpOPcUnHPsbia56IICBnPCV2klCPamPLkLRlkYT1KY9ARSWN6mysBA0DDrrU1Jkk7WCpiPadGD6uPaKRlkYTEurzhMLfEgmPjv6tdDxxuKB9OIYom3dsQPmLPztytuHhWdBlbNt78QGqaiKwWPSRlkYXZGdquMbs3qhCYwcoN2zWrFPYs4ADWj07q3UkiKvUcH7HmpODQZY0IdStNNRq4EiZdAztuHhWdBlbNtRKZOTkiearzgiDdDWjBj4CANbdBIk8aEyBj4CALCgnoYPBooSCSQhWdGOmdKUHo4KTeCoTZPNnrfEapSTeCoTsoJgozitaeLzG0n0bNSLGZPDEkSjQWd4HTLGZPvYz0W1l1ztytuHhWdBlXf4AANXkqkkkVqDbikZlvwcxRdoXMKamtIwfeIzWilXmoKzalAHmJxtmdq6g6GtmdgYmyyfXmqENzas5ieZ0Hxc2zg66mdImZWJdfTXHInrfEapSTexGRPvYz0as3qhCcGtRO5bH98gYaaKYrO50aikZUYPZTYBuP8CYv9AlD6GtD2KeGzuHhWdBlXf4AALCgnH0cECOYaPBOdobWPv08GWEEdzaGYZvkydaGuocn3xKOB3q26HaeCgLgh1ZWlVuzjCnarz2voDUvEJkLNtUQxBPthCQZMOcpGh2wIlW10k5mAYBuP8CYv9AaIYCFrIUvEJkLNtUQxB9qacoJsJJ6z4LxQSeUwkG0n0bNSBiN9qacovkSmX5zxxuKJTYBuP8CYv9APau6Le8eXvoDUfRdADi0RT0Pdo1NMnrfEapSTexGRPvYz02qgaH0coLDDrroEgCaIYmGa8EiajouPsbOLQ04WskGvdywggNJtex505wSoO1HqV2sNo4uF6P2rw1d4LiPztFQuDOB3q2kxHW9qMh0ovzAXb2PZZviCpK5bTtJEFrIUDdzRhcqWzuACupdV8sLLW1sbKUHo4KDd5ShcqWSjQWd4HTL4cCnTsoJwLgvaeL5bsPyJfE5ehnj2IiZMOcpGh2wIlW10k5mAfAHIaIGZJWjaQuWwMoArj9m4aiKwWPSRlkYXZGZMWMOcpGh2IDs5E98ICzv4b8Y8a7aCAfnp4qy3vo8WaeLzx5052bhc7UYHh2sNo4uh9bsPyhCiS7khEyBhM8ytuHhWdBXoPCVwYz0wfecaH0coLDDrroEgCaIYCh62vbHSYviCpK5bTtfCB6GEFrIUDvqiRhcqWzuACupdV8sLLW1sbg2ev4b8WwStk3RLCgnVEvCDwOoarzwblAdNSjdEpx4eUEPRhhklD6GtD0b8DOB96vX1zH6wpeGehk2ev4b8WwStk3RLCgTXI4kpJ5kUgGOmRcpGNDSiUYZyUIRTDTsrrsPcpGNfxVu321kffXMOcpGh2IDs5ETKZOHtgYuwOoarzwfEaplozitzH62UwPOiPuHhWZIRxQB7ALIIytuHhWdBXoPCVwYz0W1l1ztytuHhWdBhkxpbnJrUsSearzEGukwsWdzmLXqUU2om5H(aPuSKGhYykZroDTDyYdDaTuzjCTo4uQuasfEaeLPJQcclf4ORcpaIYDOBXixjwAQQWdGOmDuvq4PNMnrfEapSDOC9eKKZOHDDXilkcGOmpqkflj4HmMYyixx7svACyPek2ZEurPsnqkflj4HmMYCKtx7svACyPek2ZEurSjQWd4HTdLRNGKCgnSRBjwcGOmpqkflj4HmMYCKtx7svACyPek2ZEurPsHHCDZKGhYysQ0ytuHhWdBhkxpbj5mAjx1RbikZdKsXscEiJPmgY11UuLghwkHI9ShvuQuCKt3mj4HmMKkTVbeT4aEpOGjnWKg4PbE68TK6EXHc)Te3e0aUGMUbfSB6IzygGRjMjQKHRZmf4Ymj4ovueUNGzMLs0Gel1zgmSIygfXHvQtDMruRhkcBztsqIJygWty6Izs8WdiADQZmTOkXZmyPpxbBmdypZ4qMjbbrzMEauGd4XmqzAvhUmdGqBAMbqGbSnTLnHnjXnbnGlOPBqb7MUygMb4AIzIkz46mtbUmtcwEjbSAOEcMzwkrdsSuNzWWkIzuehwPo1zgrTEOiSLnjbjoIzMs6Izs8WdiADQZmTOkXZmyPpxbBmdypZ4qMjbbrzMEauGd4XmqzAvhUmdGqBAMbqGd2M2YMWMKURKHRtDMbWYmQWd4Xm8a7ylBY3ueVgUFRfvj(VXdSJFG)wj4CAFGFqb)b(B0Pdo1Fj(Mk8aEFBvqOVj2WPn0VbKUHo4KTeCoTmZmZaoZGoZSuzjCTo4eZGoZ0HUDvqiRCfc3dzEqlZm1zMrMwCGD68Cfc3dzEq73esl4u21ff54huWF)bfmpWFJoDWP(lX3eB40g63as3qhCYwcoNwMzMzaZ3uHhW7BRcc9(dA6FG)gD6Gt9xIVj2WPn0VbKUHo4KTeCoTmZmZK(VPcpG33QGWRelLfQ)(d6uEG)gD6Gt9xIVj2WPn0VbKUHo4KTeCoTmZmZmLVPcpG33Wjdzklu)9h0e(a)nv4b8(gUEP(3OthCQ)s8(7FRexGRP9b(bf8h4VrNo4u)L4BInCAd9BlvwcxRdo9nv4b8(gwbsrr5fQ77pOG5b(B0Pdo1Fj(gu(ByY)Mk8aEFdiDdDWPVbKYrOVL23eB40g63CLtNBL3Os55KR61w60bN6FdiDZNwrFBqypVH87pOP)b(B0Pdo1Fj(MydN2q)wFrIUvEJkLNtUQxB9qacoJsJJ6z4LxQSeUMzKIzas3qhCYUHC2dbiyMjvkMbltCE21ff5yR8gvkpNCvVMzKIzaeZKEMrsMbCMjrygx505wSoO1HqV2sNo4uNzM(BQWd49n5nQuEo5QE97pOt5b(B0Pdo1Fj(Mk8aEFBd5Vj2WPn0VbiMbWZmEiajoumtQumdGyMLQ04WmJKmJawnGzzyCoMzseMXvoDUfRdADi0RT0Pdo1zMPzMPYmDKv9aEmtIWmPztpZKkfZ0HUDdzRCfc3dzEqlZmvMrMwCGD68Cfc3dzEqlZmnZGoZ0xKOB3q26HaeCgLgh1ZWlVuzjCnZifZaKUHo4KDd5ShcqWFtiTGtzxxuKJFqb)9h0e(a)n60bN6VeFtSHtBOFBGuk2yHxoXrtITiYFtfEaVVvPr17pOPZd83OthCQ)s8TkfSLPJwus)nW)Mk8aEFRqlueqeCEeo9nH0coLDDrro(bf83F)BegtNGEGFqb)b(B0Pdo1Fj(MydN2q)Mk8aikthvfeMzKIz6eowQNDDrroMzsLIzwn6zci6CR27yBCmJumZus43uHhW7BEnCp87pOG5b(B0Pdo1Fj(MydN2q)2aPuSljaHtyCUaxbzrKzMuPyMbsPy9afT4CbzL2Ii)nv4b8(MxtzKBarUEUaxb9(dA6FG)gD6Gt9xIVj2WPn0Vnqkf7aNJtyrK)Mk8aEFRIQGR0zyjZrerp3xsRWV)GoLh4VrNo4u)L4BInCAd9BdKsX6bkAX5cYkTfrMzqNzeWQbmldJZXmZmZKWVPcpG33gCiSNHLSxtz6OkPF)bnHpWFJoDWP(lX3eB40g63uHharz6OQGWmJumtNWXs9SRlkYXmtQumdGyMvJEMaIo3Q9o2ghZifZaytJzqNzOJwusB7ujeHZmsnZmjmnMz6VPcpG33kqbcM6zfSOnCkpiT69h005b(B0Pdo1Fj(MydN2q)Mk8aikthvfeMzKIz6eowQNDDrroMzsLIzwn6zci6CR27yBCmJumt6K23uHhW7BYiBuKoou5bxX(7pOjQh4VrNo4u)L4BInCAd9BdKsX6bkAX5cYkTfr(BQWd49nui62d9YWswblAHE97pOaMh4VrNo4u)L4BInCAd9BdKsX6bkAX5cYkTfr(BQWd49nb8e05R6upx4Af9(dkG9b(B0Pdo1Fj(MydN2q)2aPuSEGIwCUGSsBrK)Mk8aEFBdzzoLJlJLvb9(dk4P9a)n60bN6VeFtSHtBOFBGukwpqrloxqwPTiYFtfEaVVLeU8oquC5LWWtpb9(dk4G)a)n60bN6VeFtfEaVVTKkhhQCHRve(BInCAd9BUUOi36rfLDyUheZmvMbCBczMuPygaXmaIzCDrrUTMuUxBLfoZifZaysJzsLIzCDrrUTMuUxBLfoZm1zMbmPXmtZmOZmUUOi36rfLDyUheZifZagalZmnZKkfZaiMX1ff5wpQOSdZYcpdM0ygPyM0NgZGoZ46IICRhvu2H5EqmJumZuMcZm93esl4u21ff54huWF)9VnuUEc6b(bf8h4VrNo4u)L4BInCAd9BdKsXscEiJPmgY112HjpMbDMzGukwsWdzmL5iNU2om5XmOZmaIzwQSeUwhCIzsLIzaeZOcpaIY0rvbHzgPygWzg0zgv4bquUdDlg5kXsmZuzgv4bquMoQkimZmnZm93uHhW7ByKRel9(dkyEG)gD6Gt9xIVj2WPn0Vnqkflj4HmMYyixx7svACyMrkMrOyp7rfXmPsXmdKsXscEiJPmh501UuLghMzKIzek2ZEurFtfEaVVHDDXilk69h00)a)n60bN6VeFtSHtBOFBGukwsWdzmL5iNU2LQ04WmJumJqXE2JkIzsLIzWqUUzsWdzmXmsXmP9nv4b8(g21Tel9(d6uEG)gD6Gt9xIVj2WPn0Vnqkflj4HmMYyixx7svACyMrkMrOyp7rfXmPsXmCKt3mj4HmMygPyM0(Mk8aEFl5QE97V)TovueU)a)Gc(d83OthCQ)s8nXgoTH(TbsPyRGWdK4Yf4wzrK)Mk8aEFBrUSk8aEzEG9VXdSNpTI(2q56jO3FqbZd83uHhW7Byqq488qX1FJoDWP(lX7pOP)b(B0Pdo1Fj(MydN2q)2aPuSc1Zf4wz7WK33uHhW7Bc1Zf4w9(d6uEG)gD6Gt9xIVj2WPn0VnqkflUw7WKveVBrKzMuPyMbsPyLxysUfr(BQWd49Tf5YQWd4L5b2)gpWE(0k6ByNuUx)(dAcFG)gD6Gt9xIVPcpG33ekNNvHhWlZdS)nEG98Pv03eqiVdtEV)GMopWFJoDWP(lX3eB40g63eWQbmldJZXmJuZmdGyMeYmjgZaKUHo4KTarwHCEeoXmt)nv4b8(2ICzv4b8Y8a7FJhypFAf9TsCbUM23FqtupWFJoDWP(lX3eB40g63giLIDGZXjSiYmtQumZaPuSyKENUSwnqW1we5VPcpG33wKlRcpGxMhy)B8a75tROVHDs5E97pOaMh4VrNo4u)L4BInCAd9BUYPZTdoe2DLdpSLoDWPoZGoZmqkf7GdHDx5WdB7WKhZKkfZa4zgx5052bhc7UYHh2sNo4uNzqNzeWQbmldJZXmZuzgW8nv4b8(MaEabbHYEnLXYXgo(9hua7d83OthCQ)s8nXgoTH(nx5052bhc7UYHh2sNo4uNzqNzgiLIDWHWURC4HTDyYJzqNzaeZqhTOKMzKKzsVnHmtIWm0rlkPTlHIoMrsMbqmZusJzseMzGukwbN0vOypouwezMzAMzAMrQzMbqmd4GNqMjXygWKEMjryMbsPyJtO7PEaVmiXHkdlzVMYjoihkozrKzMPzg0zgv4bquE4zFduOOfZmZmtAFtfEaVVjdH88syiYkO3FqbpTh4VrNo4u)L4BInCAd9BUYPZTdoe2DLdpSLoDWPoZGoZaiMzGuk2bhc7UYHh22HjpMjvkMrfEaeLhE23afkAXmZmZagMz6VPcpG33wKlRcpGxMhy)B8a75tROVn4qy3vo8WV)Gco4pWFJoDWP(lX3uHhW7BRcc9nXgoTH(TLklHR1bNyMuPygzAXb2PZZviCpK5bTmJumth62vbHSYviCpK5bTFtiTGtzxxuKJFqb)9huWbZd83OthCQ)s8nXgoTH(nbSAaZYW4CmZmZmP9nv4b8(wHwLNllDGL0V)GcE6FG)gD6Gt9xIVPcpG33QGWRelLfQ)nXgoTH(TLklHR1bN(MqAbNYUUOih)Gc(7pOGpLh4VrNo4u)L4BInCAd9BlvwcxRdoXmOZm9fj6wVEvCDwOU1dbi4mknoQNHxEPYs4AMrkMbiDdDWjRxVkUo7Hae83uHhW7BE9Q46Sq93FqbpHpWFJoDWP(lX3eB40g63aeZmqkfRhOOfNliR0wezMbDMbqmZQrptarNB1EhBJJzKIzaeZaoZijZuPGTSOwxueMzsmMruRlkcNlRk8aEkNzMMzseMzjrTUOOShveZmnZmnZGoZaiMbltCE21ff5y7yrCLNXCfxZmjcZOcpGNDSiUYZyUIRTDTsrrmdAmJk8aE2XI4kpJ5kU2kGyNzMMzKIzaeZOcpGNfxVu321kffXmOXmQWd4zX1l1Tci2zMP)Mk8aEFBSiUYZyUIRF)bf805b(B0Pdo1Fj(MydN2q)gwM48SRlkYXwCYqMYc1zgPygW8nv4b8(gozitzH6V)GcEI6b(B0Pdo1Fj(MydN2q)2aPuScoPRqXECOSiYFtfEaVVHRxQ)(dk4aMh4VrNo4u)L4BQWd49nHY5zv4b8Y8a7FJhypFAf9TsW50((7FtEjbSAO(d8dk4pWFJoDWP(lX3GYFdt(3uHhW7BaPBOdo9nGuoc9T0(gq6MpTI(wbISc58iC69huW8a)n60bN6VeFdk)nm5FtfEaVVbKUHo403as5i03a)BaPB(0k6BLGZP99h00)a)n60bN6VeFdk)nm5FtfEaVVbKUHo403as5i03s7BInCAd9BkyrB4KnzW75cNW1lD94qzPthCQ)nG0nFAf9TsW50((d6uEG)gD6Gt9xIVbL)gM8VPcpG33as3qhC6BaPCe6BjkMbnMPwXo9nG0nFAf9TnKZEiab)(dAcFG)gD6Gt9xIVbL)gM8VPcpG33as3qhC6BaPCe6BaMVbKU5tROV51RIRZEiab)(dA68a)n60bN6VeFdk)nm5FtfEaVVbKUHo403as5i03s7BInCAd9BkyrB4KnzW75cNW1lD94qzPthCQ)nG0nFAf9nVEvCD2dbi43FqtupWFtfEaVVbsC9L6zSCSHJ)gD6Gt9xI3FqbmpWFJoDWP(lX3eB40g63giLITccpqIlxGBLTdtEFtfEaVVjVWK83FqbSpWFJoDWP(lX3eB40g63giLITccpqIlxGBLTdtEFtfEaVVjupxGB17V)nStk3RFGFqb)b(B0Pdo1Fj(MydN2q)MRC6C7GdHDx5WdBPthCQZmOZmdKsXo4qy3vo8W2om59nv4b8(2ICzv4b8Y8a7FJhypFAf9Tbhc7UYHh(9huW8a)n60bN6VeFtfEaVVTki03eB40g636q3UkiKvUcH7HmpOLzMkZaUnDyg0zM(IeD7QGqwpeGGZO04OEgE5LklHRzgPygW8nH0coLDDrro(bf83Fqt)d83OthCQ)s8nXgoTH(nfSOnCYMm49CHt46LUECOS0Pdo1zg0zgapZ0HU1RxfxNfQB9qasCO(Mk8aEFZRxfxNfQ)(d6uEG)gD6Gt9xIVj2WPn0VPcpGNDSiUYZyUIRTDTsrrmJumJk8aEwC9sDBxRuu03uHhW7BJfXvEgZvC97pOj8b(B0Pdo1Fj(MydN2q)Mk8aEwCYqMYc1TDTsrrmJumJk8aEwC9sDBxRuu03uHhW7B4KHmLfQ)(dA68a)nv4b8(gUEP(3OthCQ)s8(7FtaH8om59a)Gc(d83uHhW7BdAX0cY3OthCQ)s8(dkyEG)Mk8aEFloHUN6b8(gD6Gt9xI3Fqt)d83uHhW7BuLmmjT5b86FJoDWP(lX7pOt5b(B0Pdo1Fj(MydN2q)2aPuSdCooHfrMzsLIzCLtNBJtO7PEaplD6GtDMbDMraH8om5zJtO7PEap7svACyMrkMPeOQ98svACyMjvkMbWZmUYPZTXj09upGNLoDWPoZGoZiGqEhM8SdAX0cIDPknomZifZucu1EEPkno83uHhW7BRceDqeCUS0bws)(dAcFG)gD6Gt9xIVj2WPn0V1PbsPyxfeYIiZmOZmDAGuk2nKTiYFtfEaVVPDv2dGOmoPUvV)GMopWFJoDWP(lX3eB40g63OJwusB7ujeHZmsXmjmHmtQumth62vbHSlvwcxRdoXmPsXmDOB3q2UuzjCTo4eZGoZiGvdywggNJzMzMraRgWSmmohBRuWgZKkfZaiMzGuk2bohNWIiZmOZmdKsXoW54e2LQ04WmZuzgWtpZm93uHhW7BEGIwCUGSs)(dAI6b(B0Pdo1Fj(MydN2q)2aPuSEGIwCUGSsBrKzg0zMbsPyh4CCcBhM8yg0zgbSAaZYW4CmZmvMzkmd6mth62vbHSYviCpK5bTmZuzgWTPdZGoZqhTOKMzKIzMsAFtfEaVVHR1omzfX7V)GcyEG)gD6Gt9xIVj2WPn0VnqkfRhOOfNliR0wezMjvkMzGuk2bohNWIi)nv4b8(2GwmTGehQ3FqbSpWFJoDWP(lX3eB40g63giLIDGZXjSiYmtQumZaPuSdoe25iy3Ii)nv4b8(Mm0d49(dk4P9a)n60bN6VeFtfEaVVjuopRcpGxMhy)B8a75tROVrymDc69huWb)b(B0Pdo1Fj(Mk8aEFtX1aPhHZRcwWnlGRY)MydN2q)2aPuSYlmj32HjpMbDMbqmtNgiLIDvWcUzbCvEUtdKsX2HjpMjvkMPtdKsXkGxhr4bquooqYDAGukwezMbDMX1ff5wpQOSdZYcpN(0yMPYmGBtiZKkfZa4zMonqkfRaEDeHhar54aj3PbsPyrKzg0zgaXmDAGuk2vbl4MfWv55onqkfl2vbimJuZmdysiZKymd4PXmjcZ0PbsPyhCiSNHLSxtz6OkPTiYmtQumJRlkYTEurzhM7bXmtLzMsAmZ0md6mZaPuSEGIwCUGSsBxQsJdZmsXmGNgZm93oTI(MIRbspcNxfSGBwaxL)(dk4G5b(B0Pdo1Fj(MydN2q)2aPuSYlmj32HjpMbDMbqmZaPuSEGIwCUGSsBrKzMuPygxxuKB9OIYom3dIzMkZaM0yMP)Mk8aEFdbt5WPk87V)Tbhc7UYHh(b(bf8h4VrNo4u)L4BQWd49TvbH(MydN2q)gGygapZ4HaK4qXmPsXmaIzwQSeUwhCIzqNzKPfhyNopxHW9qMh0YmsXmDOBxfeYkxHW9qMh0YmtZmtZmOZmdKsXo88QGq2om5XmOZm9fj62vbHSEiabNrPXr9m8YlvwcxZmsnZmG5BcPfCk76IIC8dk4V)GcMh4VrNo4u)L4BQWd49Tki8kXszH6FtSHtBOFBPYs4ADWjMbDMzGuk2HNRGWRelz7WK33esl4u21ff54huWF)bn9pWFJoDWP(lX3uHhW7BE9Q46Sq9Vj2WPn0VTuzjCTo4eZGoZmqkf7WZE9Q4ABhM8yg0zM(IeDRxVkUolu36HaeCgLgh1ZWlVuzjCnZifZay(MqAbNYUUOih)Gc(7pOt5b(B0Pdo1Fj(MydN2q)2aPuSdppwex5zmxX12om59nv4b8(2yrCLNXCfx)(dAcFG)gD6Gt9xIVj2WPn0Vnqkf7WZ4KHmz7WKhZGoZGLjop76IICSfNmKPSqDMrkMb8VPcpG33Wjdzklu)9h005b(B0Pdo1Fj(MydN2q)2aPuSdpJRxQB7WK33uHhW7B46L6V)GMOEG)gD6Gt9xIVj2WPn0Vnqkf7WZ4KHmz7WK33uHhW7B4KHmLfQ)(dkG5b(B0Pdo1Fj(MydN2q)2aPuSdp71RIRTDyY7BQWd49nVEvCDwO(7V)(7V)p]] )

    
end
