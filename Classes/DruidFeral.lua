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
                end

                applyBuff( "bt_thrash" )
                if will_proc_bloodtalons then proc_bloodtalons() end
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

    spec:RegisterPack( "Feral", 20201020, [[dWKjgbqiav1Jau5saQInraFsqqJsQItjvQvbPsVIGmlPQULGK2fP(fKYWiKogK0YauEMGuttQexdsvBtqOVjikJtQsCobjwNGO6DcIqZtQKUha7JG6GsvQQfsGEOuLktuqKSrPkP(OGiYjLQuALsfZeqv6McIO2jK4NsvQYqLQKKLkvP4PszQaXxLQKySsvsQ9QQ)k0Gj5WuwSIEmrtwHlJAZs8zGA0sQtlA1cIuVginBKUTKSBv(nOHlWXfeblxPNd10P66qSDa57eQXliW5jeRhsfZxqTFe)O(G8TH58JcWefyIIQOatunQHc67cW(Mlsa)TatcQbM)2zv83618A0VfyIqH24b5ByiYk5Vv7EaoKJgAGtVgzQLWk0Wzfc18eEY1koA4SsI23Mij17T3p)2WC(rbyIcmrrvuGjQg1qb9Db1q5B4aw(OGQOH(B15yW3p)2GXYVbCevVMxJsuHulsoiDaoIQ3t6WjVefWeTprbmrbMOKoKoahr17QTdmJd5KoahrfQeLGlIBuIQrnCnrHgr1eNbmrnq28atucYlMxqjk0iQE7jT9mpHhrLfIkDIAYMJjQw9YdIAyvgywt6aCevOsu9gUSmUMOaPEnCnrvGlr1RK0br1RPmUE5BKhynPdWruHkrfsbVqOtulhSqXuIkpIscRMMhsKO8AE5qiMOoirfaZZ1FlyHLKYFd4iQEnVgLOcPwKCq6aCevVN0HtEjkGjAFIcyIcmrjDiDaoIQ3vBhyghYjDaoIkujkbxe3OevJA4AIcnIQjodyIAGS5bMOeKxmVGsuOru92tA7zEcpIklev6e1KnhtuT6Lhe1WQmWSM0b4iQqLO6nCzzCnrbs9A4AIQaxIQxjPdIQxtzC9Y3ipWAshGJOcvIkKcEHqNOwoyHIPevEeLewnnpKir518YHqmrDqIkaMNRjDiDaoIQxZRrjQE)EvaVeL0oIYOyirnzIQarUbrzorv7EaoKJgAGtSRbNEnYulHvO1R2o0XwdTqSxcLqu2lHsOeIf0BfjJEjJkQOFywOnr7LHvkKoKoM0t4H1bllHvtZfcaAazBAtk3)SkgqbISYG4mDUpqgfHbikPdWruT6LhefaIs0(efkWluXNfGRHor1BmqzIcarHAFIQDwaUg6evVXaLjkaefW6tuaV9wIcarf6(evtCgWefaIQlKoM0t4H1bllHvtZfcaAazBAtk3)SkgqjPuE7dKrryaOs6yspHhwhSSewnnxiaObKTPnPC)ZQyaLKs5TpqgfHbiA)SaWqhEtN1It6iwOmUE5BKhynF2KYdshGJOAsJYeL40RjQAd7SM0XKEcpSoyzjSAAUqaqdiBtBs5(NvXa2mi6PeuCFGmkcdiKb8uByNjDmPNWdRdwwcRMMlea0aY20MuU)zvmaVEnCD0tjO4(azuegqVq6yspHhwhSSewnnxiaObKTPnPC)ZQyaE9A46ONsqX9bYOimar7Nfag6WB6SwCshXcLX1lFJ8aR5ZMuEq6yspHhwhSSewnnxiaObAEJLhrCqUPJjDmPNWdRdwwcRMMlea0cwOyA)SayIuk6ki8anVybUv6bu8r6yspHhwhSSewnnxiaOjnpwGBv)SayIuk6ki8anVybUv6bu8r6q6yspHhgWICrt6j8I0e79pRIbmnQDsUFwamrkfDfeEGMxSa3knsaPJj9eEyHaGggueknonCnPdWrucAu7KmrjMnGYdmrLhqm2tWMNWJ0XKEcpmaP5XcCR6NfatKsrlnpwGBLEafFKoahr1RAHIPeL4A(yG4LOcGyCoPmPdWruM0t4HfcaAblumL0b4iQEVJjkCn0jkSZg1RjDmPNWdlea0wKlAspHxKMyV)zvmaSZg1R7NfatKsrJRTbuCfthAKGWHNiLIoyHIPAKasht6j8WcbanPrPrt6j8I0e79pRIbiHq6ak(iDmPNWdlea0wKlAspHxKMyV)zvmGsEjUM3(zbGewnHXayEowya9G(qfiBtBszDbISYG4mDUBshGJOcjJq9mublhef2zJ61KoM0t4HfcaAlYfnPNWlstS3)Skga2zJ619ZcGjsPON4yEsnsq4WtKsrJrgd(Iw1ebxRrciDmPNWdlea0KWdiiOC0R5ioi30X9Zca3O856jfchUrHhwZNnP8qGjsPONuiC4gfEy9ak(chg47gLpxpPq4Wnk8WA(SjLhciHvtymaMNJ7kWiDaoIcKAMOQGyNO4qqaF4eiMOeeeIskIKYevpGuVmUMOA1lpiQM4mGjkje7efQOIEIIpEblsFIQYaLjkmYYeLyMOK2ruvgOmr51Mtu5ruDHOatHtJI7M0XKEcpSqaqlacPXLXqKvY9Zca3O856jfchUrHhwZNnP8qGjsPONuiC4gfEy9ak(eOh(4fSicfAn6rx(4fSi6LbZNq90frr3jsPOLu2wPH98aRrc6UBHb0dQOI(qfyHgDNiLIopPTN5j8IGMh4iSe9AogsJCGPSgjOBbmPNaXXPh9nbdMxmarjDmPNWdlea0wKlAspHxKMyV)zvmGjfchUrHhUFwa4gLpxpPq4Wnk8WA(SjLhc0ZePu0tkeoCJcpSEafFHdBspbIJtp6BcgmVyaaRBsht6j8WcbaT1aL7lfrs5OBly2XaqTFwaSCzzCTnPC4Wb8ItSZNhRqOEgqtEfEaD9AGY6GkeQNb0Kxsht6j8WcbaTcVgnww(qhr6Nfasy1egdG55yaIs6yspHhwiaOvbHxjxoknVVuejLJUTGzhda1(zbWYLLX12KYKoM0t4HfcaAE9A46O08(zbWYLLX12KYcmwKCO961W1rP5ApLGIJGT84reEXLllJRfgiBtBszTxVgUo6PeumPJj9eEyHaG2CrCJgXudx3pla6zIukApbZlowqwr0ibc0ZA5iYaXNRTXaRZt4EqvOkleeL12cMXHQS2wWmowwt6j8mA3O7YYABbZrpR4U7wGEWbmLgDBbZowpxe3Orm1W1ORj9eE65I4gnIPgUwpSkdmd8yspHNEUiUrJyQHR1si27w4EmPNWtJRxEOhwLbMbEmPNWtJRxEOLqS3nPJj9eEyHaGgwCgWrP59ZcaCatPr3wWSJ1yXzahLMlmWiDmPNWdlea0W1lp6NfatKsrlPSTsd75bwJeq6yspHhwiaOjnknAspHxKMyV)zvmGssP8s6q6yspHhwpPq4Wnk8WawduUVuejLJUTGzhda1(zbqpaFpLGMh4WH7z5YY4ABszbc4fNyNppwHq9mGM8k8a661aL1bviupdOjVD3TatKsrp94AGY6bu8jWyrYHEnqzTNsqXrWwE8icV4YLLX1cdayKoM0t4H1tkeoCJcpSqaqJIC2gZdhKR5j86lfrs5OBly2XaqTFwaSCzzCTnPSatKsrp9yfeELCz9ak(iDmPNWdRNuiC4gfEyHaGMxVgUoknVVuejLJUTGzhda1(zbWYLLX12KYcmrkf90JE9A4A9ak(eySi5q71RHRJsZ1EkbfhbB5XJi8IlxwgxlCVq6yspHhwpPq4Wnk8WcbaT5I4gnIPgUUFwamrkf90JZfXnAetnCTEafFKoM0t4H1tkeoCJcpSqaqdlod4O08(zbWePu0tpIfNbSEafFcGdykn62cMDSglod4O0CHrL0XKEcpSEsHWHBu4HfcaA46Lh9ZcGjsPONEexV8qpGIpsht6j8W6jfchUrHhwiaOHfNbCuAE)SayIuk6PhXIZawpGIpsht6j8W6jfchUrHhwiaO51RHRJsZ7NfatKsrp9OxVgUwpGIpshsht6j8WAjeshqXhGjVyEbL0XKEcpSwcH0bu8jea0YtA7zEcpsht6j8WAjeshqXNqaqJRcGI5noH3G0XKEcpSwcH0bu8jea0wdi(Gi4yz5dDePFwamrkf9ehZtQrcch2nkFUopPTN5j808ztkpeqcH0bu8PZtA7zEcp9YvwEyHlj4ApUCLLhoCyGVBu(CDEsBpZt4P5ZMuEiGecPdO4tp5fZlO6LRS8WcxsW1EC5klpmPJj9eEyTecPdO4tiaOzdlWtG4iwSTv9ZcGbprkf9AGYAKabg8ePu0BgOrciDaoIcKveIYUbrDqNOeByNjkq61efF8cwK(e1eXjkJIHefyirvGlrHo8ckrz3GOYtA7r6yspHhwlHq6ak(ecaAEcMxCSGSI0pla4JxWIOhCjLPlm6rF4WdORxduwVCzzCTnPC4WdOR3mqVCzzCTnPSasy1egdG55yasy1egdG55yDLfcchUNjsPON4yEsnsGatKsrpXX8K6LRS8WDf1q3nPJj9eEyTecPdO4tiaOHRTbuCfth9ZcGjsPO9emV4ybzfrJeiWePu0tCmpPEafFciHvtymaMNJ7AxeyaD9AGY6GkeQNb0K3UIQoefGpEblIWDrusht6j8WAjeshqXNqaqBYlMxqZdC)SayIukApbZlowqwr0ibHdprkf9ehZtQrciDmPNWdRLqiDafFcbaTaONWRFwamrkf9ehZtQrcchEIuk6jfchueSRrciDmPNWdRLqiDafFcbanPrPrt6j8I0e79pRIbWymFsM0XKEcpSwcH0bu8jea0qWCmDUQ)zvmadxdKDmoUg6a3OeUgTFwamrkfDWcft1dO4tGEg8ePu0RHoWnkHRrJdEIuk6bu8fo8GNiLIwcVbI0tG4yEGgh8ePu0ibc42cMDTNvC0HXaPhdTODfvn6dhg4p4jsPOLWBGi9eioMhOXbprkfnsGa9m4jsPOxdDGBucxJgh8ePu0y3KGkmaGH(qfvrr3bprkf9KcHJiSe9AoYhxjIgjiCy3wWSR9SIJomosURDr0UfyIukApbZlowqwr0lxz5Hfgvr7M0XKEcpSwcH0bu8jea0qWCmDUc3plaMiLIoyHIP6bu8jqptKsr7jyEXXcYkIgjiCy3wWSR9SIJomosURat0UjDiDmPNWdRzmMpjdWRH7H7NfaM0tG4iFCvYyHhmoxEeDBbZooC41YrKbIpxBJbwNNWDb9KoM0t4H1mgZNKfcaAEnhrUje5gXcCLC)SayIuk6LLGszmowGRK1ibHdprkfTNG5fhliRiAKasht6j8WAgJ5tYcbaTkUcUIeHLifrMJ4yzRc3plaMiLIEIJ5j1ibKoM0t4H1mgZNKfcaAtkeoIWs0R5iFCLi9ZcGjsPO9emV4ybzfrJeiGewnHXayEoga6jDmPNWdRzmMpjlea0kqjcMhrdD4nDoozRQFwayspbIJ8XvjJfEW4C5r0Tfm74WH7zTCezG4Z12yG15jCOiQa8Xlyr0dUKY0fga6fTBsht6j8WAgJ5tYcbaTaKnlIKh44KAyVFwayspbIJ8XvjJfEW4C5r0Tfm74WHxlhrgi(CTngyDEchIIs6yspHhwZymFswiaObgX2rAxewIg6Wl0R7NfatKsr7jyEXXcYkIgjG0XKEcpSMXy(KSqaqtcpjF(AopIfQvX9ZcGjsPO9emV4ybzfrJeq6yspHhwZymFswiaOTzqaLJ5fXbMK7NfatKsr7jyEXXcYkIgjG0XKEcpSMXy(KSqaqtmCPdG48IlJHNDsUFwamrkfTNG5fhliRiAKasht6j8WAgJ5tYcbaTLTG8ahluRIX9LIiPC0Tfm7yaO2plaCBbZU2Zko6W4i5UIQg9Hd3tpUTGzxxZg1R1bsx4Er0WHDBbZUUMnQxRdKExbamr7wa3wWSR9SIJomoswyGfkDhoCpUTGzx7zfhDymq6rGjQWHwubCBbZU2Zko6W4izH7sx6M0H0XKEcpSUKukVawduUVuejLJUTGzhda1(zbaq2M2KY6ssP8cavbwUSmU2MuwGb01RbkRdQqOEgqtE7kGaEXj25ZJviupdOjVKoM0t4H1LKs5viaOTgOC)SaaiBtBszDjPuEbamsht6j8W6ssP8kea0OiNTX8Wb5AEcV(zbaq2M2KY6ssP8ci0KoM0t4H1LKs5viaOHfNbC)SaaiBtBszDjPuEb0fsht6j8W6ssP8kea0W1lpiDiDmPNWdRl5L4AEbGnGmWCCH22plaMiLIgBazG54cTvpGIVWHNiLIgBazG54cTvVCLLhUR9iHvtymaMNJrx0leQDJUIQdnPdWruHKnqzIcJSmr5qIcD4fsuEntuazBAtktuyirHHvmrbPdIciJIWe1aEHqNO4BquibefnpW8Mhysht6j8W6sEjUMxHaGgq2M2KY9pRIbmzSh3mOpqgfHbiA)SaWnkFUoyZkJgfVMxR5ZMuEq6aCeLj9eEyDjVexZRqaqtkIKMh4iq2M2KY9pRIbmzSh3mOpmaqLfc6dKrryaJfjh6nd0EkbfhbB5XJi8Ilxwgx3plaCJYNRd2SYOrXR51A(SjLhKoM0t4H1L8sCnVcbaTGnRmAu8AED)SaySi5qhSzLrJIxZR1EkbfhbB5XJi8Ilxwgxlmq2M2KY6ndIEkbfhomoGP0OBly2X6GnRmAu8AETW9eAHqfDDJYNRX2Kxhc9AnF2KYJUjDmPNWdRl5L4AEfcaABg0xkIKYr3wWSJbGA)SaOhGVNsqZdC4W9SCLLhwijSAcJbW8Cm66gLpxJTjVoe61A(SjLhD31bYAEcp0vuDOdhEaD9Mb6GkeQNb0K3UgWloXoFEScH6zan5TBbglso0BgO9uckoc2YJhr4fxUSmUwyGSnTjL1Bge9uckM0XKEcpSUKxIR5viaOvzzv)SayIuk6CHxmK2eJ1ibKoM0t4H1L8sCnVcbaTcVqzcrWXz6C)klee5JxWIaa1(srKuo62cMDmaujDiDaoIQ3yGYe1X8atulebCnveIc9Ic8quWcrLoMOO8b2RjkZjkJOQYlRqQikhsuyKnWWyIcxV8atuJaM0XKEcpSg7Sr9AalYfnPNWlstS3)SkgWKcHd3OWd3plaCJYNRNuiC4gfEynF2KYdbMiLIEsHWHBu4H1dO4J0XKEcpSg7Sr9AHaG2AGY9LIiPC0Tfm7yaO2plagqxVgOSoOcH6zan5TROQdrbglso0RbkR9uckoc2YJhr4fxUSmUwyGr6yspHhwJD2OETqaqZRxdxhLM3plam0H30zT4KoIfkJRx(g5bwZNnP8qaG)a6AVEnCDuAU2tjO5bM0XKEcpSg7Sr9AHaG2CrCJgXudx3plamPNWtpxe3Orm1W16HvzGzHnPNWtJRxEOhwLbMjDmPNWdRXoBuVwiaOHfNbCuAE)SaWKEcpnwCgWrP56HvzGzHnPNWtJRxEOhwLbMjDmPNWdRXoBuVwiaOHRxEq6q6yspHhwpnQDsgag5k5Y9ZcGjsPOzjndWCedP2QhqXNatKsrZsAgG5if5SvpGIpb6z5YY4ABs5WH7XKEceh5JRsglmQcyspbIJdORXixjxURM0tG4iFCvY4U7M0XKEcpSEAu7KSqaqd72IrwWC)SayIukAwsZamhXqQT6LRS8WclnSh9SIdhEIukAwsZamhPiNT6LRS8WclnSh9SIjDmPNWdRNg1ojlea0WUTLC5(zbWePu0SKMbyosroB1lxz5HfwAyp6zfhomgsTnYsAgGzHfL0XKEcpSEAu7KSqaqt8AED)SayIukAwsZamhXqQT6LRS8WclnSh9SIdhMIC2gzjndWSWI(nG4fNW7rbyIcmrrvuudLVj22lpW4V1R073BqP3IsiPqorruGuZevwfaxNOkWLOcHdUyiupesulhsajxEquyyftugIdRmNheLS2oWmwt6a8MhtuOI(qor17Ghq868GOAzvVJOWICUfcikGhIYHefWlIruJeOeNWJOGb8AoCjQEqRBIQhGfc6wt6q60R073BqP3IsiPqorruGuZevwfaxNOkWLOcHbllHvtZdHe1YHeqYLhefgwXeLH4WkZ5brjRTdmJ1KoaV5Xevxc5evVdEaXRZdIQLv9oIclY5wiGOaEikhsuaVigrnsGsCcpIcgWR5WLO6bTUjQEqne0TM0H0P3wfaxNhevOquM0t4ru0e7ynPZ3Oj2XpiFRKukVpipkO(G8n(SjLhVGFZKEcVVTgO83KB68M23aY20MuwxskLxIcarHkrjarTCzzCTnPmrjarnGUEnqzDqfc1ZaAYlr1vaevaV4e785XkeQNb0K3Vjfrs5OBly2XpkO((JcWEq(gF2KYJxWVj305nTVbKTPnPSUKukVefaIcyFZKEcVVTgO87pkH(b5B8ztkpEb)MCtN30(gq2M2KY6ssP8suaiQq)nt6j8(wfeELC5O083Fu6YdY34ZMuE8c(n5MoVP9nGSnTjL1LKs5LOaquD5BM0t49nS4mGJsZF)rb9piFZKEcVVHRxE8n(SjLhVGV)(3k5L4AEFqEuq9b5B8ztkpEb)MCtN30(2ePu0ydidmhxOT6bu8ruHdtutKsrJnGmWCCH2QxUYYdtuDLO6HOKWQjmgaZZXef6suONOeIOqLO6MOqxIsuDO)Mj9eEFdBazG54cT99hfG9G8n(SjLhVGFdg8nm7FZKEcVVbKTPnP83aYOi83e9BYnDEt7BUr5Z1bBwz0O418AnF2KYJVbKTXZQ4VnzSh3m49hLq)G8n(SjLhVGFtUPZBAFBSi5qhSzLrJIxZR1EkbfhbB5XJi8IlxwgxtuctuazBAtkR3mi6PeumrfomrHdykn62cMDSoyZkJgfVMxtuctu9quHMOeIOqLOqxIYnkFUgBtEDi0R18ztkpiQU)Mj9eEFlyZkJgfVMx)(JsxEq(gF2KYJxWVzspH332m4BYnDEt7B9quaFIYtjO5bMOchMO6HOwUYYdtucrusy1egdG55yIcDjk3O85ASn51HqVwZNnP8GO6MO6krnqwZt4ruOlrjQo0ev4We1a66nd0bviupdOjVevxjQaEXj25ZJviupdOjVev3eLae1yrYHEZaTNsqXrWwE8icV4YLLX1eLWefq2M2KY6ndIEkbf)nPiskhDBbZo(rb13Fuq)dY34ZMuE8c(n5MoVP9TjsPOZfEXqAtmwJe8nt6j8(wLLvV)OeIpiFJpBs5Xl43QSqqKpEblY3q9BM0t49TcVqzcrWXz683KIiPC0Tfm74hfuF)9VXymFs(b5rb1hKVXNnP84f8BYnDEt7BM0tG4iFCvYyIsyIAW4C5r0Tfm7yIkCyIATCezG4Z12yG15ructuDb9FZKEcVV51W9WV)OaShKVXNnP84f8BYnDEt7BtKsrVSeukJXXcCLSgjGOchMOMiLI2tW8IJfKvensW3mPNW7BEnhrUje5gXcCL87pkH(b5B8ztkpEb)MCtN30(2ePu0tCmpPgj4BM0t49TkUcUIeHLifrMJ4yzRc)(JsxEq(gF2KYJxWVj305nTVnrkfTNG5fhliRiAKaIsaIscRMWyamphtuaik0)nt6j8(2KcHJiSe9AoYhxjY7pkO)b5B8ztkpEb)MCtN30(Mj9eioYhxLmMOeMOgmoxEeDBbZoMOchMO6HOwlhrgi(CTngyDEeLWevOikrjarXhVGfrp4sktNOegarHErjQU)Mj9eEFRaLiyEen0H3054KTQ3FucXhKVXNnP84f8BYnDEt7BM0tG4iFCvYyIsyIAW4C5r0Tfm7yIkCyIATCezG4Z12yG15ructuHOOFZKEcVVfGSzrK8ahNud7V)OeYEq(gF2KYJxWVj305nTVnrkfTNG5fhliRiAKGVzspH33aJy7iTlclrdD4f61V)O0lpiFJpBs5Xl43KB68M23MiLI2tW8IJfKvensW3mPNW7Bs4j5ZxZ5rSqTk(9hLq5b5B8ztkpEb)MCtN30(2ePu0EcMxCSGSIOrc(Mj9eEFBZGakhZlIdmj)(JcQI(G8n(SjLhVGFtUPZBAFBIukApbZlowqwr0ibFZKEcVVjgU0bqCEXLXWZoj)(JcQO(G8n(SjLhVGFZKEcVVTSfKh4yHAvm(BYnDEt7BUTGzx7zfhDyCKmr1vIcvn6jQWHjQEiQEik3wWSRRzJ616aPtuctu9IOev4WeLBly211Sr9ADG0jQUcGOaMOev3eLaeLBly21EwXrhghjtuctualuiQUjQWHjQEik3wWSR9SIJomgi9iWeLOeMOcTOeLaeLBly21EwXrhghjtuctuDPlev3FtkIKYr3wWSJFuq993)20O2j5hKhfuFq(gF2KYJxWVj305nTVnrkfnlPzaMJyi1w9ak(ikbiQjsPOzjndWCKIC2QhqXhrjar1drTCzzCTnPmrfomr1drzspbIJ8XvjJjkHjkujkbikt6jqCCaDng5k5Yevxjkt6jqCKpUkzmr1nr193mPNW7ByKRKl)(JcWEq(gF2KYJxWVj305nTVnrkfnlPzaMJyi1w9YvwEyIsyIsAyp6zftuHdtutKsrZsAgG5if5SvVCLLhMOeMOKg2JEwXFZKEcVVHDBXily(9hLq)G8n(SjLhVGFtUPZBAFBIukAwsZamhPiNT6LRS8WeLWeL0WE0ZkMOchMOWqQTrwsZamtuctuI(nt6j8(g2TTKl)(JsxEq(gF2KYJxWVj305nTVnrkfnlPzaMJyi1w9YvwEyIsyIsAyp6zftuHdtuuKZ2ilPzaMjkHjkr)Mj9eEFt8AE97V)TbxmeQ)G8OG6dY34ZMuE8c(n5MoVP9TjsPORGWd08If4wPrc(Mj9eEFBrUOj9eErAI9VrtShpRI)20O2j53Fua2dY3mPNW7ByqrO040W1FJpBs5Xl47pkH(b5B8ztkpEb)MCtN30(2ePu0sZJf4wPhqX33mPNW7BsZJf4w9(JsxEq(gF2KYJxWVj305nTVnrkfnU2gqXvmDOrciQWHjQjsPOdwOyQgj4BM0t49Tf5IM0t4fPj2)gnXE8Sk(ByNnQx)(Jc6Fq(gF2KYJxWVzspH33KgLgnPNWlstS)nAI94zv83KqiDafFV)OeIpiFJpBs5Xl43KB68M23KWQjmgaZZXeLWaiQEik0tuHkrbKTPnPSUarwzqCMotuD)nt6j8(2ICrt6j8I0e7FJMypEwf)TsEjUM33FuczpiFJpBs5Xl43KB68M23MiLIEIJ5j1ibev4We1ePu0yKXGVOvnrW1AKGVzspH33wKlAspHxKMy)B0e7XZQ4VHD2OE97pk9YdY34ZMuE8c(n5MoVP9n3O856jfchUrHhwZNnP8GOeGOMiLIEsHWHBu4H1dO4JOchMOa(eLBu(C9KcHd3OWdR5ZMuEqucqusy1egdG55yIQRefW(Mj9eEFtcpGGGYrVMJ4GCth)(JsO8G8n(SjLhVGFtUPZBAFZnkFUEsHWHBu4H18ztkpikbiQjsPONuiC4gfEy9ak(ikbiQEik(4fSieLqevO1ONOqxIIpEblIEzW8rucru9quDruIcDjQjsPOLu2wPH98aRrciQUjQUjkHbqu9quOIk6jQqLOawOjk0LOMiLIopPTN5j8IGMh4iSe9AogsJCGPSgjGO6MOeGOmPNaXXPh9nbdMxmrbGOe9BM0t49TaiKgxgdrwj)(JcQI(G8n(SjLhVGFtUPZBAFZnkFUEsHWHBu4H18ztkpikbiQEiQjsPONuiC4gfEy9ak(iQWHjkt6jqCC6rFtWG5ftuaikGruD)nt6j8(2ICrt6j8I0e7FJMypEwf)TjfchUrHh(9hfur9b5B8ztkpEb)Mj9eEFBnq5Vj305nTVTCzzCTnPmrfomrfWloXoFEScH6zan5LOeMOgqxVgOSoOcH6zan59BsrKuo62cMD8JcQV)OGkWEq(gF2KYJxWVj305nTVjHvtymaMNJjkaeLOFZKEcVVv41OXYYh6iY7pkOg6hKVXNnP84f8BM0t49Tki8k5YrP5FtUPZBAFB5YY4ABs5Vjfrs5OBly2XpkO((JcQD5b5B8ztkpEb)MCtN30(2YLLX12KYeLae1yrYH2RxdxhLMR9uckoc2YJhr4fxUSmUMOeMOaY20Muw71RHRJEkbf)nt6j8(MxVgUokn)9hfur)dY34ZMuE8c(n5MoVP9TEiQjsPO9emV4ybzfrJequcqu9quRLJideFU2gdSopIsyIQhIcvIsiIQYcbrzTTGzmrfQeLS2wWmowwt6j8mkr1nrHUe1YYABbZrpRyIQBIQBIsaIQhIchWuA0Tfm7y9CrCJgXudxtuOlrzspHNEUiUrJyQHR1dRYaZefAeLj9eE65I4gnIPgUwlHyNO6MOeMO6HOmPNWtJRxEOhwLbMjk0ikt6j8046LhAje7ev3FZKEcVVnxe3Orm1W1V)OGAi(G8n(SjLhVGFtUPZBAFdhWuA0Tfm7ynwCgWrP5eLWefW(Mj9eEFdlod4O083FuqnK9G8n(SjLhVGFtUPZBAFBIukAjLTvAyppWAKGVzspH33W1lpE)rb1E5b5B8ztkpEb)Mj9eEFtAuA0KEcVinX(3Oj2JNvXFRKukVV)(3cwwcRMM)G8OG6dY34ZMuE8c(nyW3WS)nt6j8(gq2M2KYFdiJIWFt0VbKTXZQ4VvGiRmiotNF)rbypiFJpBs5Xl43GbFdZ(3mPNW7BazBAtk)nGmkc)nu)gq2gpRI)wjPuEF)rj0piFJpBs5Xl43GbFdZ(3mPNW7BazBAtk)nGmkc)nr)MCtN30(MHo8MoRfN0rSqzC9Y3ipWA(SjLhFdiBJNvXFRKukVV)O0LhKVXNnP84f8BWGVHz)BM0t49nGSnTjL)gqgfH)wiJOqJOQnSZFdiBJNvXFBZGONsqXV)OG(hKVXNnP84f8BWGVHz)BM0t49nGSnTjL)gqgfH)wV8nGSnEwf)nVEnCD0tjO43FucXhKVXNnP84f8BWGVHz)BM0t49nGSnTjL)gqgfH)MOFtUPZBAFZqhEtN1It6iwOmUE5BKhynF2KYJVbKTXZQ4V51RHRJEkbf)(Jsi7b5BM0t49nqZBS8iIdYnD834ZMuE8c((JsV8G8n(SjLhVGFtUPZBAFBIuk6ki8anVybUv6bu89nt6j8(wWcftF)rjuEq(gF2KYJxWVj305nTVnrkfDfeEGMxSa3k9ak((Mj9eEFtAESa3Q3F)ByNnQx)G8OG6dY34ZMuE8c(n5MoVP9n3O856jfchUrHhwZNnP8GOeGOMiLIEsHWHBu4H1dO47BM0t49Tf5IM0t4fPj2)gnXE8Sk(BtkeoCJcp87pka7b5B8ztkpEb)Mj9eEFBnq5Vj305nTVnGUEnqzDqfc1ZaAYlr1vIcvDisucquJfjh61aL1EkbfhbB5XJi8Ilxwgxtuctua7BsrKuo62cMD8JcQV)Oe6hKVXNnP84f8BYnDEt7Bg6WB6SwCshXcLX1lFJ8aR5ZMuEqucquaFIAaDTxVgUoknx7Pe08a)nt6j8(MxVgUokn)9hLU8G8n(SjLhVGFtUPZBAFZKEcp9CrCJgXudxRhwLbMjkHjkt6j8046Lh6HvzG5VzspH33MlIB0iMA463Fuq)dY34ZMuE8c(n5MoVP9nt6j80yXzahLMRhwLbMjkHjkt6j8046Lh6HvzG5VzspH33WIZaokn)9hLq8b5BM0t49nC9YJVXNnP84f893)MecPdO47b5rb1hKVzspH33M8I5f0VXNnP84f89hfG9G8nt6j8(wEsBpZt49n(SjLhVGV)Oe6hKVzspH334QaOyEJt4n(gF2KYJxW3Fu6YdY34ZMuE8c(n5MoVP9TjsPON4yEsnsarfomr5gLpxNN02Z8eEA(SjLheLaeLecPdO4tNN02Z8eE6LRS8WeLWevjbx7XLRS8Wev4WefWNOCJYNRZtA7zEcpnF2KYdIsaIscH0bu8PN8I5fu9YvwEyIsyIQKGR94YvwE4VzspH33wdi(Gi4yz5dDe59hf0)G8n(SjLhVGFtUPZBAFBWtKsrVgOSgjGOeGOg8ePu0BgOrc(Mj9eEFZgwGNaXrSyBRE)rjeFq(gF2KYJxWVj305nTVXhVGfrp4sktNOeMOqp6jQWHjQb01RbkRxUSmU2MuMOchMOgqxVzGE5YY4ABszIsaIscRMWyamphtuaikjSAcJbW8CSUYcbev4Wevpe1ePu0tCmpPgjGOeGOMiLIEIJ5j1lxz5HjQUsuOgAIQ7VzspH338emV4ybzf59hLq2dY34ZMuE8c(n5MoVP9TjsPO9emV4ybzfrJequcqutKsrpXX8K6bu8rucqusy1egdG55yIQRevxikbiQb01RbkRdQqOEgqtEjQUsuOQdrIsaIIpEblcrjmr1fr)Mj9eEFdxBdO4kMoE)rPxEq(gF2KYJxWVj305nTVnrkfTNG5fhliRiAKaIkCyIAIuk6joMNuJe8nt6j8(2KxmVGMh43FucLhKVXNnP84f8BYnDEt7BtKsrpXX8KAKaIkCyIAIuk6jfchueSRrc(Mj9eEFla6j8E)rbvrFq(gF2KYJxWVzspH33KgLgnPNWlstS)nAI94zv83ymMpj)(JcQO(G8n(SjLhVGFZKEcVVz4AGSJXX1qh4gLW1OFtUPZBAFBIuk6GfkMQhqXhrjar1drn4jsPOxdDGBucxJgh8ePu0dO4JOchMOg8ePu0s4nqKEcehZd04GNiLIgjGOeGOCBbZU2Zko6WyG0JHwuIQRefQA0tuHdtuaFIAWtKsrlH3ar6jqCmpqJdEIukAKaIsaIQhIAWtKsrVg6a3OeUgno4jsPOXUjbLOegarbm0tuHkrHQOef6sudEIuk6jfchryj61CKpUsensarfomr52cMDTNvC0HXrYevxjQUikr1nrjarnrkfTNG5fhliRi6LRS8WeLWefQIsuD)TZQ4Vz4AGSJXX1qh4gLW1OV)OGkWEq(gF2KYJxWVj305nTVnrkfDWcft1dO4JOeGO6HOMiLI2tW8IJfKvensarfomr52cMDTNvC0HXrYevxjkGjkr193mPNW7BiyoMoxHF)9VnPq4Wnk8WpipkO(G8n(SjLhVGFZKEcVVTgO83KB68M236HOa(eLNsqZdmrfomr1drTCzzCTnPmrjarfWloXoFEScH6zan5LOeMOgqxVgOSoOcH6zan5LO6MO6MOeGOMiLIE6X1aL1dO4JOeGOglso0RbkR9uckoc2YJhr4fxUSmUMOegarbSVjfrs5OBly2XpkO((JcWEq(gF2KYJxWVzspH33QGWRKlhLM)n5MoVP9TLllJRTjLjkbiQjsPONESccVsUSEafFFtkIKYr3wWSJFuq99hLq)G8n(SjLhVGFZKEcVV51RHRJsZ)MCtN30(2YLLX12KYeLae1ePu0tp61RHR1dO4JOeGOglso0E9A46O0CTNsqXrWwE8icV4YLLX1eLWevV8nPiskhDBbZo(rb13Fu6YdY34ZMuE8c(n5MoVP9TjsPONECUiUrJyQHR1dO47BM0t49T5I4gnIPgU(9hf0)G8n(SjLhVGFtUPZBAFBIuk6PhXIZawpGIpIsaIchWuA0Tfm7ynwCgWrP5eLWefQFZKEcVVHfNbCuA(7pkH4dY34ZMuE8c(n5MoVP9TjsPONEexV8qpGIVVzspH33W1lpE)rjK9G8n(SjLhVGFtUPZBAFBIuk6PhXIZawpGIVVzspH33WIZaokn)9hLE5b5B8ztkpEb)MCtN30(2ePu0tp61RHR1dO47BM0t49nVEnCDuA(7V)(3meVgUFRLv9U3F)Fa]] )

    
end
