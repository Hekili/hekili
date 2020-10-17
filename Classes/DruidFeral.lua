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
    
        local duration = t.duration
        local app_duration = min( target.time_to_die, fight_remains, class.abilities[ this_action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time
        
        local ttd = fight_remains
    
        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = max( 0, min( duration, 1.3 * t.duration * ( action == "primal_wrath" and 0.5 or 1 ), ttd ) )
        end
    
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time
    
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
                return max( 0, 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) + buff.scent_of_blood.v1 )
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

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

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

            apply_duration = function () 
                return 2 + 2 * combo_points.current
            end,

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

            damage = function () return 0.46 * stat.attack_power * ( bleeding and 1.2 or 1 ) * ( effective_stealth and ( 1.6 * 1 + stat.crit * ( level > 53 and 2 or 1 ) ) or 1 ) end,

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

            damage = function () return min( 5, active_enemies ) * stat.attack_power * 0.35 * ( bleeding and 1.2 or 1 ) end, -- TODO: Check damage.

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

    spec:RegisterPack( "Feral", 20201016, [[dKuOdbqiGO8irv4sarKnbj9jGi0OaGtbGwLOaVIiAwkIBjQI2ff)cszyIIogqAzaHNjQsttuvUMOqBJiuFtuqghquDoIqADebL5jQQUNIAFejhuuqHfcP6HebvtuuqPnseeFeic6KarQvQintGiQBceb2jK4NarslLii9ujnva6RarI9QYFfzWu6WKwScpMWKLQlJSzj(mqnAP0PfwTOGQxdOMnQUTuSBv9BqdNOoUOGIwUsphQPt11Hy7aY3fLgprioprQ1tey(Ik7hLpqpaVAxD6qbezcImbntqLydOGccjoZm0vDPLPRkRcGvW0vFTHUQecTk)QYQ0CO2paVkgISc6QTUlJLWqdnWH3ImmcydA4ObHREaFXQfhnC0iq7QdKG7G0)nUAxD6qbezcImbntqLydOGccqKrqVkwMehkGMzEVAB070FJR2jS4Q5bZkHqRYz2mSls0ztZdMfKQWHdAzwqL4jmliYeezYMYMMhmReER(GjSegBAEWS5jZI(I4kNzRCf3YSOXS1SHmXSDKnEWml60IPfyMfnMfK(f6(QhWNzJcZgoZoi1XmBTDPoZ21gfmzytZdMnpzwjuQSeULzbSDvClZwGlZcsj4DMvcHt42L(E8GnxvEHLGtxnpywjeAvoZMHDrIoBAEWSGufoCqlZcQepHzbrMGit2u208GzLWB1hmHLWytZdMnpzw0xex5mBLR4wMfnMTMnKjMTJSXdMzrNwmTaZSOXSG0Vq3x9a(mBuy2Wz2bPoMzRTl1z2U2OGjdBAEWS5jZkHsLLWTmlGTRIBz2cCzwqkbVZSsiCc3U03JhSHnLnvfEaFSrEjbSzOUKZObKUHo40KxBO5cezfYPr40eGuocnNjBAEWS12L6m7mZM5eMff4NN4xLXTqNzLqvGjMDMzbDcZwFvg3cDMvcvbMy2zMfetywqYG0m7mZM3jmBnBitm7mZMp2uv4b8Xg5LeWMH6soJgq6g6GttETHMlbNt7eGuocndkBQk8a(yJ8scyZqDjNrdiDdDWPjV2qZLGZPDcqkhHMZCsuMvjG2Wjt2G3tfoHBx67Xd2qVo4uNnvfEaFSrEjbSzOUKZObKUHo40KxBO5nKtEiagpbiLJqZzi2uv4b8Xg5LeWMH6soJgq6g6GttETHM92vXTjpeaJNaKYrOzqoBQk8a(yJ8scyZqDjNrdiDdDWPjV2qZE7Q42KhcGXtas5i0CMtIYSkb0gozYg8EQWjC7sFpEWg61bN6SPQWd4JnYljGnd1LCgnGJVVupHLJnCmBQk8a(yJ8scyZqDjNrtEHz5tIY8aPumnq4dC8PcCBmDy2NnvfEaFSrEjbSzOUKZOjupvGBZKOmpqkftde(ahFQa3gthM9ztztvHhWhpViFsfEa)epW(KxBO5HY1xqtIY8aPumnq4dC8PcCBmiYSPQWd4JLCgnmWiCEAO4w2uv4b8XsoJMq9ubUntIY8aPumc1tf42y6WSpBQk8a(yjNrtEHz5SP5bZcs9jMf3cDMf7KY9wMTHeT6hcmZ6kWeZkVbCdxA2uv4b8XsoJ2I8jv4b8t8a7tETHMXoPCVDsuMhiLIb3QDy2gI3niY5YnqkfJ8cZYniYSPQWd4JLCgnHY5jv4b8t8a7tETHMfqiVdZ(SPQWd4JLCgTf5tQWd4N4b2N8AdnxIpWT0ojkZcyZaMKHX7yPMbqgZtG0n0bNmfiYkKtJWjaYMMhmlibiCpYtWIoZIDs5ElZ2HeMzFOZMQcpGpwYz0wKpPcpGFIhyFYRn0m2jL7TtIY8aPumdCkEHbroxUbsPyWi9o9jTzGGBniYSPQWd4JLCgnb8bccmL8wkHLJnC8KOm7kNE3m4qy3vo8Xg61bN6OoqkfZGdHDx5WhB6WSFUCGmx507Mbhc7UYHp2qVo4uhvbSzatYW4DC(bbBAEWSa2smBde7mljrKPhharml6aYScPfCIzbaGTlHBz2A7sDMTMnKjMvaXoZckOzKzPNwWspHzBuGjMfJSeZMLywH(mBJcmXSER6mB8mB(ywWC4q5yaYMQcpGpwYz0KHqEAjmezf0KOm7kNE3m4qy3vo8Xg61bN6OoqkfZGdHDx5WhB6WSpQaGEAblTK51KXmGEAblTzjW0ljaYxMzWaPumcoPRqXE8GniYaeGsndaqbnJ5jiYBgmqkft8cDF1d4NaoEWjyj5Tukdh5bZjdImarvfEaeLgEY3amyAXZzYMQcpGpwYz0wKpPcpGFIhyFYRn08GdHDx5WhpjkZUYP3ndoe2DLdFSHEDWPoQayGukMbhc7UYHp20Hz)C5uHharPHN8nadMw8miaiBQk8a(yjNrBvGPjcPfCk56cMC8mOtIY8sLLWT6Gt5YjtloWo9EQbH7HmpOvQo0nRcmzKBq4EiZdAztvHhWhl5mAfAvEQS0lbspjkZcyZaMKHX745mztvHhWhl5mAnq4xILsc1NiKwWPKRlyYXZGojkZlvwc3QdoXMQcpGpwYz082vXTjH6tIY8sLLWT6GtO2xKOB82vXTjH6gpeaJtG14PEc(PLklHBLciDdDWjJ3UkUn5HaymBQk8a(yjNrBSiUYtyUIBNeLzamqkfJhGPfNkiR0gezubWQrprarVB0EhBIxkaaQKnQejjA1fmHZtrRUGjCQSQWd4RCaMbljA1fmL8OHaiarfayzIZtUUGjhBglIR8eMR42mqfEaFZyrCLNWCf3A6AJcMajPcpGVzSiUYtyUIBnci2bOuaqfEaFdUDPUPRnkycKKk8a(gC7sDJaIDaYMQcpGpwYz0WzdzkjuFsuMXYeNNCDbto2GZgYusOUuGGnvfEaFSKZOHBxQpjkZdKsXi4KUcf7Xd2GiZMQcpGpwYz0ekNNuHhWpXdSp51gAUeCoTSPSPQWd4Jndoe2DLdF88Qattesl4uY1fm54zqNeLzaaY8qaC8GZLdalvwc3QdoHQmT4a707PgeUhY8GwP6q3SkWKrUbH7HmpOfGae1bsPygEAvGjthM9rTVir3SkWKXdbW4eynEQNGFAPYs4wPMbbBQk8a(yZGdHDx5Whl5mACKx3u8y5yvpG)eH0coLCDbtoEg0jrzEPYs4wDWjuhiLIz4Pgi8lXsMom7ZMQcpGp2m4qy3vo8XsoJM3UkUnjuFIqAbNsUUGjhpd6KOmVuzjCRo4eQdKsXm8K3UkU10HzFu7ls0nE7Q42KqDJhcGXjWA8upb)0sLLWTsbYztvHhWhBgCiS7kh(yjNrBSiUYtyUIBNeL5bsPygEASiUYtyUIBnDy2NnvfEaFSzWHWURC4JLCgnC2qMsc1NeL5bsPygEcNnKjthM9rfltCEY1fm5ydoBitjH6sbkBQk8a(yZGdHDx5Whl5mA42L6tIY8aPumdpHBxQB6WSpBQk8a(yZGdHDx5Whl5mA4SHmLeQpjkZdKsXm8eoBitMom7ZMQcpGp2m4qy3vo8XsoJM3UkUnjuFsuMhiLIz4jVDvCRPdZ(SPSPQWd4JnciK3Hz)5bTyAbMnvfEaFSraH8om7l5mAXl09vpGpBQk8a(yJac5Dy2xYz0OgzywAtd43ztvHhWhBeqiVdZ(soJ2QarpebNkl9sG0tIY8aPumdCkEHbroxox507M4f6(QhW3qVo4uhvbeY7WSVjEHUV6b8nl1OXJLQeGB90snA84C5azUYP3nXl09vpGVHEDWPoQciK3HzFZGwmTaBwQrJhlvja36PLA04XSPQWd4JnciK3HzFjNrt7QSharjCwDBMeL5onqkfZQatgezu70aPumBiBqKztZdMfWvAMv)oZ(qNzZQyNywaLqyw6PfS0ty2bIZSkhdzwWqMTaxMvcOfyMv)oZgVq3NnvfEaFSraH8om7l5mAEaMwCQGSspjkZ0tlyPnDQeIWLkJzmxUo0nRcmzwQSeUvhCkxUo0nBiBwQSeUvhCcvbSzatYW4D8Sa2mGjzy8o20OsKC5aWaPumdCkEHbrg1bsPyg4u8cZsnA848dAEbiBQk8a(yJac5Dy2xYz0WTAhMTH49jrzEGukgpatlovqwPniYOoqkfZaNIxy6WSpQcyZaMKHX748Npu7q3SkWKrUbH7HmpOn)GAKyuPNwWslv(YKnvfEaFSraH8om7l5mAdAX0cC8GNeL5bsPy8amT4ubzL2GiNl3aPumdCkEHbrMnvfEaFSraH8om7l5mAYqpG)KOmpqkfZaNIxyqKZLBGukMbhc7CeSBqKztvHhWhBeqiVdZ(soJMq58Kk8a(jEG9jV2qZegtVGytvHhWhBeqiVdZ(soJgcMsHtntETHMvClq6t40QsaCtc4Q8jrzEGukg5fMLB6WSpQaOtdKsXSQea3KaUkp1PbsPy6WSFUCDAGukgb87icpaIsXdCQtdKsXGiJQRlyYnE0qjhMKfEkVzMFqnzmxoqwNgiLIra)oIWdGOu8aN60aPumiYOcGonqkfZQsaCtc4Q8uNgiLIb7QayPMbrgZtqZmd60aPumdoe2tWsYBPe9uJ0ge5C5CDbtUXJgk5WupO8NVmbiQdKsX4byAXPcYkTzPgnESuGMjaztvHhWhBeqiVdZ(soJgcMsHtn4jrzEGukg5fMLB6WSpQayGukgpatlovqwPniY5Y56cMCJhnuYHPEq5hezcq2u2uv4b8XgcJPxqZElCF8KOmRcpaIs0tnbHLQt4yPEY1fm54C5wn6jci6DJ27yt8sLVmYMQcpGp2qym9csYz08wkH8diY3tf4kOjrzEGukMLeaZjmovGRGmiY5YnqkfJhGPfNkiR0gez2uv4b8XgcJPxqsoJwd1axPtWsIJiIEQVK2GNeL5bsPyg4u8cdImBQk8a(ydHX0lijNrBWHWEcwsElLONAKEsuMhiLIXdW0ItfKvAdImQcyZaMKHX745mYMQcpGp2qym9csYz0kqbcM6jvcOnCkniTzsuMvHharj6PMGWs1jCSup56cMCCUCay1ONiGO3nAVJnXlLentuPNwWsB6ujeHl1CgZeGSPQWd4JnegtVGKCgnzKnkshp40GRyFsuMvHharj6PMGWs1jCSup56cMCCUCRg9ebe9Ur7DSjEPK4mztvHhWhBimMEbj5mAGr0Th6NGLKkb0c92jrzEGukgpatlovqwPniYSPQWd4JnegtVGKCgnb8f07R6upv4AdnjkZdKsX4byAXPcYkTbrMnvfEaFSHWy6fKKZOTHSmNsXNWYQGMeL5bsPy8amT4ubzL2GiZMQcpGp2qym9csYz0YcxEhik(0sy4RVGMeL5bsPy8amT4ubzL2GiZMQcpGp2qym9csYz0wsLJhCQW1gcpriTGtjxxWKJNbDsuMDDbtUXJgk5WupO8dQjJ5Ybaa46cMCtlPCV1ilCPa5zMlNRlyYnTKY9wJSWZ)miYeGO66cMCJhnuYHPEqsbcjkaZLdaUUGj34rdLCysw4jqKPu5ntuDDbtUXJgk5WupiPYx(aiBkBQk8a(ytj4CANxfyAIqAbNsUUGjhpd6KOmdKUHo4KPeCoTZGI6sLLWT6GtO2HUzvGjJCdc3dzEqB(NLPfhyNEp1GW9qMh0YMQcpGp2ucoNwjNrBvGPjrzgiDdDWjtj4CANbbBQk8a(ytj4CALCgnoYRBkESCSQhWFsuMbs3qhCYucoN258YMQcpGp2ucoNwjNrdNnKPjrzgiDdDWjtj4CANZhBQk8a(ytj4CALCgnC7sD2u2uv4b8XMs8bUL2zScKcMslu3jrzEPYs4wDWj208GzbjqbMywmYsmRdzwjGwiZ6TeZcKUHo4eZIHmlg2qmlK3zwGuocXSD4ds0zw67mlImZYJhmTXdMnvfEaFSPeFGBPvYz0as3qhCAYRn08GWEAd5jaPCeAoZjrz2vo9UrEJgLNYUQ3AOxhCQZMMhmRk8a(ytj(a3sRKZOjKwWJhCciDdDWPjV2qZdc7PnKNaLNBujYeGuocn3xKOB2q24HayCcSgp1tWpTuzjC7KOm7kNE3iVrJYtzx1Bn0Rdo1ztvHhWhBkXh4wALCgn5nAuEk7QE7KOm3xKOBK3Or5PSR6TgpeaJtG14PEc(PLklHBLciDdDWjZgYjpeaJZLdltCEY1fm5yJ8gnkpLDvVvkaKxjbndCLtVBW6Gwhc9wd96GtDaYMQcpGp2uIpWT0k5mABipriTGtjxxWKJNbDsuMbaiZdbWXdoxoaSuJgpwsbSzatYW4DCg4kNE3G1bToe6Tg61bN6am)DKv9a(zqMM8Mlxh6MnKnYniCpK5bT5xMwCGD69udc3dzEqlarTVir3SHSXdbW4eynEQNGFAPYs4wPas3qhCYSHCYdbWy2uv4b8XMs8bULwjNrRrJMjrzEGukMyHFkdxZIniYSPQWd4JnL4dClTsoJwHwOiGi40iCAsJkrs0tlyPNbDIqAbNsUUGjhpdkBkBQk8a(yd2jL7TZlYNuHhWpXdSp51gAEWHWURC4JNeLzx507Mbhc7UYHp2qVo4uh1bsPygCiS7kh(ythM9ztvHhWhBWoPCVvYz0wfyAIqAbNsUUGjhpd6KOm3HUzvGjJCdc3dzEqB(b1iXO2xKOBwfyY4HayCcSgp1tWpTuzjCRuGGnvfEaFSb7KY9wjNrZBxf3MeQpjkZQeqB4KjBW7PcNWTl994bBOxhCQJkiRdDJ3UkUnju34Ha44bZMQcpGp2GDs5ERKZOnwex5jmxXTtIYSk8a(MXI4kpH5kU101gfmjLk8a(gC7sDtxBuWeBQk8a(yd2jL7TsoJgoBitjH6tIYSk8a(gC2qMsc1nDTrbtsPcpGVb3Uu301gfmXMQcpGp2GDs5ERKZOHBxQZMYMQcpGp2muU(cAgJ8LyPjrzEGukgsWdzmLWqUUMom7J6aPumKGhYykXrEDnDy2hvaSuzjCRo4uUCaqfEaeLONAcclfOOQcpaIsDOBWiFjwk)QWdGOe9utqyacq2uv4b8XMHY1xqsoJg21fJSGPjrzEGukgsWdzmLWqUUMLA04XsjuSN8OHYLBGukgsWdzmL4iVUMLA04XsjuSN8OHytvHhWhBgkxFbj5mAyx3sS0KOmpqkfdj4HmMsCKxxZsnA8yPek2tE0q5YHHCDtKGhYysQmztvHhWhBgkxFbj5mAzx1BNeL5bsPyibpKXucd56AwQrJhlLqXEYJgkxooYRBIe8qgtsL5vbIwCa)dfqKjiYe0mbnFM8E1S6(XdgFvqkzyiHIcinkGekHXSmlGTeZgnYW1z2cCzwqIDQOiChKiZUugMiXsDMfdBiMvrCyJ6uNzfT6dMWg2uqYXtmlOsSegZkHdFGO1PoZwJgjCMfl97QeHzbjXSoKzbjJOmBpakWb8zwOmTQdxMfaObqMfaGqIaqdBkBkiDJmCDQZSsuMvfEaFMLhyhBytVkpWo(a8QLGZP9a8qb0dWRsVo4u)q)QQWd4F1vbMUQydN2qVkq6g6GtMsW50YSZmlOmlQm7sLLWT6GtmlQmBh6MvbMmYniCpK5bTmB(NzwzAXb2P3tniCpK5bTxviTGtjxxWKJpua98dfqCaEv61bN6h6xvSHtBOxfiDdDWjtj4CAz2zMfexvfEa)RUkW05hk59a8Q0Rdo1p0VQydN2qVkq6g6GtMsW50YSZmBEVQk8a(xTbc)sSusO(5hk57a8Q0Rdo1p0VQydN2qVkq6g6GtMsW50YSZmB(UQk8a(xfNnKPKq9ZpuY4b4vvHhW)Q42L6xLEDWP(H(5NF1s8bUL2dWdfqpaVk96Gt9d9Rk2WPn0RUuzjCRo40vvHhW)QyfifmLwOUNFOaIdWRsVo4u)q)Qq5RIj)QQWd4FvG0n0bNUkqkhHUAMxvSHtBOx1vo9UrEJgLNYUQ3AOxhCQFvG0n9AdD1bH90gYNFOK3dWRsVo4u)q)QInCAd9Q9fj6g5nAuEk7QERXdbW4eynEQNGFAPYs4wMvkMfiDdDWjZgYjpeaJz2C5ywSmX5jxxWKJnYB0O8u2v9wMvkMfamBEzwjzwqz2mGzDLtVBW6Gwhc9wd96GtDMfGxvfEa)RkVrJYtzx1Bp)qjFhGxLEDWP(H(vvHhW)QBiFvXgoTHEvaWSGmM1dbWXdMzZLJzbaZUuJgpMzLKzfWMbmjdJ3XmBgWSUYP3nyDqRdHERHEDWPoZcqMn)mBhzvpGpZMbmBMM8YS5YXSDOB2q2i3GW9qMh0YS5NzLPfhyNEp1GW9qMh0YSaKzrLz7ls0nBiB8qamobwJN6j4NwQSeULzLIzbs3qhCYSHCYdbW4RkKwWPKRlyYXhkGE(HsgpaVk96Gt9d9Rk2WPn0RoqkftSWpLHRzXge5RQcpG)vB0O58dfj(a8Q0Rdo1p0VAJkrs0tlyPVkOxvfEa)RwOfkciconcNUQqAbNsUUGjhFOa65NFvcJPxqhGhkGEaEv61bN6h6xvSHtBOxvfEaeLONAccZSsXSDchl1tUUGjhZS5YXSRg9ebe9Ur7DSjEMvkMnFz8QQWd4FvVfUp(8dfqCaEv61bN6h6xvSHtBOxDGukMLeaZjmovGRGmiYmBUCm7aPumEaMwCQGSsBqKVQk8a(x1BPeYpGiFpvGRGo)qjVhGxLEDWP(H(vfB40g6vhiLIzGtXlmiYxvfEa)R2qnWv6eSK4iION6lPn4ZpuY3b4vPxhCQFOFvXgoTHE1bsPy8amT4ubzL2GiZSOYScyZaMKHX7yMDMzZ4vvHhW)Qdoe2tWsYBPe9uJ0NFOKXdWRsVo4u)q)QInCAd9QQWdGOe9utqyMvkMTt4yPEY1fm5yMnxoMfam7QrprarVB0EhBINzLIzLOzYSOYS0tlyPnDQeIWzwPMz2mMjZcWRQcpG)vlqbcM6jvcOnCkniT58dfj(a8Q0Rdo1p0VQydN2qVQk8aikrp1eeMzLIz7eowQNCDbtoMzZLJzxn6jci6DJ27yt8mRumReN5vvHhW)QYiBuKoEWPbxX(5hkzOdWRsVo4u)q)QInCAd9QdKsX4byAXPcYkTbr(QQWd4FvWi62d9tWssLaAHE75hkG8dWRsVo4u)q)QInCAd9QdKsX4byAXPcYkTbr(QQWd4Fvb8f07R6upv4AdD(HIe9a8Q0Rdo1p0VQydN2qV6aPumEaMwCQGSsBqKVQk8a(xDdzzoLIpHLvbD(HcOzEaEv61bN6h6xvSHtBOxDGukgpatlovqwPniYxvfEa)RMfU8oqu8PLWWxFbD(HcOGEaEv61bN6h6xvfEa)RUKkhp4uHRne(QInCAd9QUUGj34rdLCyQheZMFMfutgz2C5ywaWSaGzDDbtUPLuU3AKfoZkfZcYZKzZLJzDDbtUPLuU3AKfoZM)zMfezYSaKzrLzDDbtUXJgk5WupiMvkMfesuMfGmBUCmlaywxxWKB8OHsomjl8eiYKzLIzZBMmlQmRRlyYnE0qjhM6bXSsXS5lFmlaVQqAbNsUUGjhFOa65NF1HY1xqhGhkGEaEv61bN6h6xvSHtBOxDGukgsWdzmLWqUUMom7ZSOYSdKsXqcEiJPeh5110HzFMfvMfam7sLLWT6GtmBUCmlaywv4bquIEQjimZkfZckZIkZQcpaIsDOBWiFjwIzZpZQcpaIs0tnbHzwaYSa8QQWd4FvmYxILo)qbehGxLEDWP(H(vfB40g6vhiLIHe8qgtjmKRRzPgnEmZkfZkuSN8OHy2C5y2bsPyibpKXuIJ86AwQrJhZSsXScf7jpAORQcpG)vXUUyKfmD(HsEpaVk96Gt9d9Rk2WPn0Roqkfdj4HmMsCKxxZsnA8yMvkMvOyp5rdXS5YXSyix3ej4HmMywPy2mVQk8a(xf76wILo)qjFhGxLEDWP(H(vfB40g6vhiLIHe8qgtjmKRRzPgnEmZkfZkuSN8OHy2C5ywoYRBIe8qgtmRumBMxvfEa)RMDvV98ZVANkkc3papua9a8Q0Rdo1p0VQydN2qV6aPumnq4dC8PcCBmiYxvfEa)RUiFsfEa)epW(v5b2tV2qxDOC9f05hkG4a8QQWd4FvmWiCEAO42RsVo4u)q)8dL8EaEv61bN6h6xvSHtBOxDGukgH6PcCBmDy2)QQWd4FvH6PcCBo)qjFhGxvfEa)RkVWS8RsVo4u)q)8dLmEaEv61bN6h6xvSHtBOxDGukgCR2HzBiE3GiZS5YXSdKsXiVWSCdI8vvHhW)QlYNuHhWpXdSFvEG90Rn0vXoPCV98dfj(a8Q0Rdo1p0VQk8a(xvOCEsfEa)epW(v5b2tV2qxvaH8om7F(Hsg6a8Q0Rdo1p0VQydN2qVQa2mGjzy8oMzLAMzbaZMrMnpzwG0n0bNmfiYkKtJWjMfGxvfEa)RUiFsfEa)epW(v5b2tV2qxTeFGBP98dfq(b4vPxhCQFOFvXgoTHE1bsPyg4u8cdImZMlhZoqkfdgP3PpPndeCRbr(QQWd4F1f5tQWd4N4b2VkpWE61g6QyNuU3E(HIe9a8Q0Rdo1p0VQydN2qVQRC6DZGdHDx5WhBOxhCQZSOYSdKsXm4qy3vo8XMom7ZS5YXSGmM1vo9UzWHWURC4Jn0Rdo1zwuzwbSzatYW4DmZMFMfexvfEa)RkGpqqGPK3sjSCSHJp)qb0mpaVk96Gt9d9Rk2WPn0R6kNE3m4qy3vo8Xg61bN6mlQm7aPumdoe2DLdFSPdZ(mlQmlayw6PfS0mRKmBEnzKzZaMLEAblTzjW0ZSsYSaGzZxMmBgWSdKsXi4KUcf7Xd2GiZSaKzbiZk1mZcaMfuqZiZMNmliYlZMbm7aPumXl09vpGFc44bNGLK3sPmCKhmNmiYmlazwuzwv4bquA4jFdWGPfZSZmBMxvfEa)RkdH80syiYkOZpuaf0dWRsVo4u)q)QInCAd9QUYP3ndoe2DLdFSHEDWPoZIkZcaMDGukMbhc7UYHp20HzFMnxoMvfEaeLgEY3amyAXm7mZccMfGxvfEa)RUiFsfEa)epW(v5b2tV2qxDWHWURC4Jp)qbuqCaEv61bN6h6xvfEa)RUkW0vfB40g6vxQSeUvhCIzZLJzLPfhyNEp1GW9qMh0YSsXSDOBwfyYi3GW9qMh0EvH0coLCDbto(qb0ZpuanVhGxLEDWP(H(vfB40g6vfWMbmjdJ3Xm7mZM5vvHhW)QfAvEQS0lbsF(HcO57a8Q0Rdo1p0VQk8a(xTbc)sSusO(vfB40g6vxQSeUvhC6QcPfCk56cMC8HcONFOaAgpaVk96Gt9d9Rk2WPn0RUuzjCRo4eZIkZ2xKOB82vXTjH6gpeaJtG14PEc(PLklHBzwPywG0n0bNmE7Q42KhcGXxvfEa)R6TRIBtc1p)qbuj(a8Q0Rdo1p0VQydN2qVkay2bsPy8amT4ubzL2GiZSOYSaGzxn6jci6DJ27yt8mRumlaywqzwjz2gvIKeT6cMWmBEYSIwDbt4uzvHhWx5mlaz2mGzxs0Qlyk5rdXSaKzbiZIkZcaMfltCEY1fm5yZyrCLNWCf3YSzaZQcpGVzSiUYtyUIBnDTrbtmlAmRk8a(MXI4kpH5kU1iGyNzbiZkfZcaMvfEaFdUDPUPRnkyIzrJzvHhW3GBxQBeqSZSa8QQWd4F1XI4kpH5kU98dfqZqhGxLEDWP(H(vfB40g6vXYeNNCDbto2GZgYusOoZkfZcIRQcpG)vXzdzkju)8dfqb5hGxLEDWP(H(vfB40g6vhiLIrWjDfk2JhSbr(QQWd4FvC7s9ZpuavIEaEv61bN6h6xvfEa)RkuopPcpGFIhy)Q8a7PxBORwcoN2Zp)QYljGnd1papua9a8Q0Rdo1p0Vku(QyYVQk8a(xfiDdDWPRcKYrORM5vbs30Rn0vlqKviNgHtNFOaIdWRsVo4u)q)Qq5RIj)QQWd4FvG0n0bNUkqkhHUkOxfiDtV2qxTeCoTNFOK3dWRsVo4u)q)Qq5RIj)QQWd4FvG0n0bNUkqkhHUAMxvSHtBOxvLaAdNmzdEpv4eUDPVhpyd96Gt9RcKUPxBORwcoN2ZpuY3b4vPxhCQFOFvO8vXKFvv4b8Vkq6g6GtxfiLJqxndDvG0n9AdD1nKtEiagF(HsgpaVk96Gt9d9RcLVkM8RQcpG)vbs3qhC6QaPCe6QG8RcKUPxBOR6TRIBtEiagF(HIeFaEv61bN6h6xfkFvm5xvfEa)RcKUHo40vbs5i0vZ8QInCAd9QQeqB4KjBW7PcNWTl994bBOxhCQFvG0n9AdDvVDvCBYdbW4ZpuYqhGxvfEa)RcC89L6jSCSHJVk96Gt9d9Zpua5hGxLEDWP(H(vfB40g6vhiLIPbcFGJpvGBJPdZ(xvfEa)RkVWS8ZpuKOhGxLEDWP(H(vfB40g6vhiLIPbcFGJpvGBJPdZ(xvfEa)RkupvGBZ5NFvStk3Bpapua9a8Q0Rdo1p0VQydN2qVQRC6DZGdHDx5WhBOxhCQZSOYSdKsXm4qy3vo8XMom7Fvv4b8V6I8jv4b8t8a7xLhyp9AdD1bhc7UYHp(8dfqCaEv61bN6h6xvfEa)RUkW0vfB40g6v7q3SkWKrUbH7HmpOLzZpZcQrIzwuz2(IeDZQatgpeaJtG14PEc(PLklHBzwPywqCvH0coLCDbto(qb0ZpuY7b4vPxhCQFOFvXgoTHEvvcOnCYKn49uHt42L(E8Gn0Rdo1zwuzwqgZ2HUXBxf3MeQB8qaC8GVQk8a(x1Bxf3MeQF(Hs(oaVk96Gt9d9Rk2WPn0RQcpGVzSiUYtyUIBnDTrbtmRumRk8a(gC7sDtxBuW0vvHhW)QJfXvEcZvC75hkz8a8Q0Rdo1p0VQydN2qVQk8a(gC2qMsc1nDTrbtmRumRk8a(gC7sDtxBuW0vvHhW)Q4SHmLeQF(HIeFaEvv4b8VkUDP(vPxhCQFOF(5xvaH8om7FaEOa6b4vvHhW)QdAX0c8vPxhCQFOF(HcioaVQk8a(xnEHUV6b8Vk96Gt9d9ZpuY7b4vvHhW)QuJmmlTPb87xLEDWP(H(5hk57a8Q0Rdo1p0VQydN2qV6aPumdCkEHbrMzZLJzDLtVBIxO7REaFd96GtDMfvMvaH8om7BIxO7REaFZsnA8yMvkMTeGB90snA8yMnxoMfKXSUYP3nXl09vpGVHEDWPoZIkZkGqEhM9ndAX0cSzPgnEmZkfZwcWTEAPgnE8vvHhW)QRce9qeCQS0lbsF(HsgpaVk96Gt9d9Rk2WPn0R2PbsPywfyYGiZSOYSDAGukMnKniYxvfEa)RQDv2dGOeoRUnNFOiXhGxLEDWP(H(vfB40g6vPNwWsB6ujeHZSsXSzmJmBUCmBh6MvbMmlvwc3QdoXS5YXSDOB2q2SuzjCRo4eZIkZkGndysggVJz2zMvaBgWKmmEhBAujcZMlhZcaMDGukMbofVWGiZSOYSdKsXmWP4fMLA04XmB(zwqZlZcWRQcpG)v9amT4ubzL(8dLm0b4vPxhCQFOFvXgoTHE1bsPy8amT4ubzL2GiZSOYSdKsXmWP4fMom7ZSOYScyZaMKHX7yMn)mB(ywuz2o0nRcmzKBq4EiZdAz28ZSGAKyMfvMLEAblnZkfZMVmVQk8a(xf3QDy2gI3p)qbKFaEv61bN6h6xvSHtBOxDGukgpatlovqwPniYmBUCm7aPumdCkEHbr(QQWd4F1bTyAboEWNFOirpaVk96Gt9d9Rk2WPn0RoqkfZaNIxyqKz2C5y2bsPygCiSZrWUbr(QQWd4FvzOhW)8dfqZ8a8Q0Rdo1p0VQk8a(xvOCEsfEa)epW(v5b2tV2qxLWy6f05hkGc6b4vPxhCQFOFvv4b8VQIBbsFcNwvcGBsaxLFvXgoTHE1bsPyKxywUPdZ(mlQmlay2onqkfZQsaCtc4Q8uNgiLIPdZ(mBUCmBNgiLIra)oIWdGOu8aN60aPumiYmlQmRRlyYnE0qjhMKfEkVzYS5Nzb1KrMnxoMfKXSDAGukgb87icpaIsXdCQtdKsXGiZSOYSaGz70aPumRkbWnjGRYtDAGukgSRcGzwPMzwqKrMnpzwqZKzZaMTtdKsXm4qypbljVLs0tnsBqKz2C5ywxxWKB8OHsom1dIzZpZMVmzwaYSOYSdKsX4byAXPcYkTzPgnEmZkfZcAMmlaV6Rn0vvClq6t40QsaCtc4Q8ZpuafehGxLEDWP(H(vfB40g6vhiLIrEHz5Mom7ZSOYSaGzhiLIXdW0ItfKvAdImZMlhZ66cMCJhnuYHPEqmB(zwqKjZcWRQcpG)vrWukCQbF(5xDWHWURC4Jpapua9a8Q0Rdo1p0VQk8a(xDvGPRk2WPn0RcaMfKXSEiaoEWmBUCmlay2LklHB1bNywuzwzAXb2P3tniCpK5bTmRumBh6MvbMmYniCpK5bTmlazwaYSOYSdKsXm80QatMom7ZSOYS9fj6MvbMmEiagNaRXt9e8tlvwc3YSsnZSG4QcPfCk56cMC8HcONFOaIdWRsVo4u)q)QQWd4F1gi8lXsjH6xvSHtBOxDPYs4wDWjMfvMDGukMHNAGWVelz6WS)vfsl4uY1fm54dfqp)qjVhGxLEDWP(H(vvHhW)QE7Q42Kq9Rk2WPn0RUuzjCRo4eZIkZoqkfZWtE7Q4wthM9zwuz2(IeDJ3UkUnju34HayCcSgp1tWpTuzjClZkfZcYVQqAbNsUUGjhFOa65hk57a8Q0Rdo1p0VQydN2qV6aPumdpnwex5jmxXTMom7Fvv4b8V6yrCLNWCf3E(HsgpaVk96Gt9d9Rk2WPn0RoqkfZWt4SHmz6WSpZIkZILjop56cMCSbNnKPKqDMvkMf0RQcpG)vXzdzkju)8dfj(a8Q0Rdo1p0VQydN2qV6aPumdpHBxQB6WS)vvHhW)Q42L6NFOKHoaVk96Gt9d9Rk2WPn0RoqkfZWt4SHmz6WS)vvHhW)Q4SHmLeQF(Hci)a8Q0Rdo1p0VQydN2qV6aPumdp5TRIBnDy2)QQWd4FvVDvCBsO(5NF(vveVfUxTgns4NF(D]] )

    
end
