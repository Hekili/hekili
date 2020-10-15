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

    spec:RegisterPack( "Feral", 20201014.3, [[dK0XdbqiaQ8irHCjakYMGK(eafAuaOtbqwfru9kIKzPiULOk1UOYVGugMOOJbjwga8mrv10efCnrvSnrvY3efQghavDoIi16iIIMNOQCpf1(ichuuOGfcP6HerHjkku0gjIeFeGc6KauQvQintakQBcqb2jq6NauslLis6PsAQaYxbOe7vL)kYGPQdtAXk8yctwQUmYML4Za1OLsNwy1IcLEnqmBuUTuSBv9BqdNOoUOqHwUsphQPt56qSDa13fLgpru68ePwpreZxuz)O6dLdOR2vJoqbqMaituYeLm4aqMzaaaqsFvtAz6QYQaefmD1xBORkPqRYUQSkndQ9dORIHiRGUARzYyjt0qdCyTidNa2GgoAqyQfWxSAXqdhnc0U6ajygG9FJR2vJoqbqMaituYeLm4aqMaiVYeLRILjXbkkzM)R2g9o934QDclUAgX9sk0QmUpJ5IeD(0mI7bSkm4GwUhLmmH7bqMait(u(0mI7LmA1hmHLm5tZiUpV5E0xetzCFLP4wUhnUVMnKjUVJSXdM7rNwmTGW9OX9a2Vq3xTa(CFu4(W4(bPgM7RTl15(U2OGjhFAgX95n3lPsLLWTCpqTRIB5(cC5EalbRZ9skmc3U03JhS7QYlSem6Qze3lPqRY4(mMls05tZiUhWQWGdA5EuYWeUhazcGm5t5tZiUxYOvFWewYKpnJ4(8M7rFrmLX9vMIB5E04(A2qM4(oYgpyUhDAX0cc3Jg3dy)cDF1c4Z9rH7dJ7hKAyUV2UuN77AJcMC8Pze3N3CVKkvwc3Y9a1UkUL7lWL7bSeSo3lPWiC7sFpEWo(u(uvyb8Xo5LeWMHAsnJgW6g6GrtETHMlqKviNgHrtawzi0CM8Pze3xBxQZ9ZCFMt4EqHFEJFvg3cnUxsvbH4(zUhLjCF9vzCl04EjvfeI7N5EamH7bmdyZ9ZCF(NW91SHmX9ZCFg4tvHfWh7KxsaBgQj1mAaRBOdgn51gAUemgTtawzi0mk8PQWc4JDYljGnd1KAgnG1n0bJM8AdnxcgJ2jaRmeAoZjrzwLeAdJCzdwpvyeUDPVhpyh96GrD(uvyb8Xo5LeWMHAsnJgW6g6GrtETHM3qozHae8eGvgcnNX5tvHfWh7KxsaBgQj1mAaRBOdgn51gA2Axf3MSqacEcWkdHMb88PQWc4JDYljGnd1KAgnG1n0bJM8AdnBTRIBtwiabpbyLHqZzojkZQKqByKlBW6PcJWTl994b7OxhmQZNQclGp2jVKa2mutQz0aj((s9ewo2WW8PQWc4JDYljGnd1KAgn5fMLnjkZdKsX1aHpiXNkWTX1HzF(uvyb8Xo5LeWMHAsnJMqTubUntIY8aPuCnq4ds8PcCBCDy2NpLpvfwaF88I8jvyb8tSaBtETHMhktFbnjkZdKsX1aHpiXNkWTXHiZNQclGpwQz0WGGWyPHIB5tvHfWhl1mAc1sf42mjkZdKsXjulvGBJRdZ(8PQWc4JLAgn5fMLXNMrCpG1N4ECl04ESrkZA5(gs0QFiWCVPGqCV8gWnmP5tvHfWhl1mAlYNuHfWpXcSn51gAgBKYS2jrzEGukoCR2HzBiw3HiNl3aPuCYlmlZHiZNQclGpwQz0ekJLuHfWpXcSn51gAwaHSom7ZNQclGpwQz0wKpPclGFIfyBYRn0Cj(a3s7KOmlGndysggVHLygG5jVbw3qhmYvGiRqoncJaeFAgX9agGWSiVbl6Cp2iLzTCFhsyU)HgFQkSa(yPMrBr(KkSa(jwGTjV2qZyJuM1ojkZdKsXnWP4foe5C5giLIdJ070N0MbcU1HiZNQclGpwQz0eWhyiiuYAPewo2WWtIYSPm6n3GbHDtzWh7OxhmQJ6aPuCdge2nLbFSRdZ(5Yb4mLrV5gmiSBkd(yh96GrDufWMbmjdJ3W5da8Pze3dulX9nqSX9KKvMECamX9Ode3lKwWiUhGa1UeUL7RTl15(A2qM4EbeBCpkOKhUNEAbl9eUVrbH4EmYsCFwI7f6Z9nkie3BTQX9XZ9zG7bZGdLHbeFQkSa(yPMrtgczPLWqKvqtIYSPm6n3GbHDtzWh7OxhmQJ6aPuCdge2nLbFSRdZ(Ocq6PfS0sLFxEKC6PfS0ULatVuamdzk5dKsXjyKUcfBXd2HidiajXmarbL8K3ai)s(aPuCXl09vlGFcK4bNGLK1sPmwKhmJCiYacvvybWuAyjBdWGPfpNjFQkSa(yPMrBr(KkSa(jwGTjV2qZdge2nLbF8KOmBkJEZnyqy3ug8Xo61bJ6OcWbsP4gmiSBkd(yxhM9ZLtfwamLgwY2amyAXZaaq8PQWc4JLAgTvbHMiKwWOKPlyYWZOmjkZlvwc3QdgLlNmT4aB0BPgeMfYSGwj6qZTkiKtUbHzHmlOLpvfwaFSuZOvOvzPYsVKi9KOmlGndysggVHNZKpvfwaFSuZO1aHFjwkjuBIqAbJsMUGjdpJYKOmVuzjCRoyeFQkSa(yPMrZAxf3MeQnjkZlvwc3QdgHAFrIUZAxf3MeQ5SqacobwJN6j4NwQSeUvcG1n0bJCw7Q42KfcqW8PQWc4JLAgTXIyklHzkUDsuMb4aPuCwaMwCQGSs7qKrfGRg9ebm9Mt7DSlEjaiks1Os2KOvxWeoVfT6cMWPYQclGVYaKKVKOvxWuYIgcqacvaILjglz6cMmSBSiMYsyMIBLCvyb8DJfXuwcZuCRRRnkycWKkSa(UXIyklHzkU1jGydqsaqvyb8D42L6UU2OGjatQWc47WTl1Dci2aeFQkSa(yPMrdNnKPKqTjrzgltmwY0fmzyhoBitjHAsaa(uvyb8XsnJgUDP(KOmpqkfNGr6kuSfpyhImFQkSa(yPMrtOmwsfwa)elW2KxBO5sWy0YNYNQclGp2nyqy3ug8XZRccnriTGrjtxWKHNrzsuMbiGZcbiXdoxoaUuzjCRoyeQY0IdSrVLAqywiZcALOdn3QGqo5geMfYSGwabiuhiLIByPvbHCDy2h1(IeD3QGqoleGGtG14PEc(PLklHBLyga8PQWc4JDdge2nLbFSuZOXqEDtXJLJvTa(teslyuY0fmz4zuMeL5LklHB1bJqDGukUHLAGWVel56WSpFQkSa(y3GbHDtzWhl1mAw7Q42KqTjcPfmkz6cMm8mktIY8sLLWT6GrOoqkf3Wsw7Q4wxhM9rTVir3zTRIBtc1CwiabNaRXt9e8tlvwc3kbGNpvfwaFSBWGWUPm4JLAgTXIyklHzkUDsuMhiLIByPXIyklHzkU11HzF(uvyb8XUbdc7MYGpwQz0WzdzkjuBsuMhiLIByjC2qMCDy2hvSmXyjtxWKHD4SHmLeQjbk8PQWc4JDdge2nLbFSuZOHBxQpjkZdKsXnSeUDPURdZ(8PQWc4JDdge2nLbFSuZOHZgYusO2KOmpqkf3Ws4SHm56WSpFQkSa(y3GbHDtzWhl1mAw7Q42KqTjrzEGukUHLS2vXTUom7ZNYNQclGp2jGqwhM9Nh0IPfe(uvyb8XobeY6WSVuZOfVq3xTa(8PQWc4JDciK1HzFPMrJAKHzPnnGFNpvfwaFStaHSom7l1mARcm9qeCQS0ljspjkZdKsXnWP4foe5C5mLrV5IxO7RwaFh96GrDufqiRdZ(U4f6(QfW3TuJgpwIsaU1sl1OXJZLdWzkJEZfVq3xTa(o61bJ6OkGqwhM9DdAX0cIBPgnESeLaCRLwQrJhZNQclGp2jGqwhM9LAgnTRYwamLWz1TzsuM70aPuCRcc5qKrTtdKsXTHSdrMpnJ4EGwP5E97C)dnUpRInI7bssH7PNwWspH7hig3RmmK7bd5(cC5EjHwq4E97CF8cDF(uvyb8XobeY6WSVuZOzbyAXPcYk9KOmtpTGL21PsictI8KNC56qZTkiKBPYs4wDWOC56qZTHSBPYs4wDWiufWMbmjdJ3WZcyZaMKHXByxJkzZLdGdKsXnWP4foezuhiLIBGtXlCl1OXJZhk5hq8PQWc4JDciK1HzFPMrd3QDy2gI1NeL5bsP4SamT4ubzL2HiJ6aPuCdCkEHRdZ(OkGndysggVHZxgqTdn3QGqo5geMfYSG28HIlVqLEAblTezit(uvyb8XobeY6WSVuZOnOftliXdEsuMhiLIZcW0ItfKvAhICUCdKsXnWP4foez(uvyb8XobeY6WSVuZOjdTa(tIY8aPuCdCkEHdroxUbsP4gmiSZqWMdrMpvfwaFStaHSom7l1mAcLXsQWc4Nyb2M8Adntym9cIpvfwaFStaHSom7l1mAiykfg1m51gAwXTaRpHtRkjWnjGRYMeL5bsP4KxywMRdZ(OcWonqkf3QscCtc4QSuNgiLIRdZ(5Y1PbsP4eWVJiSaykfpiPonqkfhImQMUGjZzrdLmyswyP8Nz(qXLNC5aCDAGukob87iclaMsXdsQtdKsXHiJka70aPuCRkjWnjGRYsDAGukoSPcqKyga5jVrjtjVtdKsXnyqypbljRLs0tns7qKZLZ0fmzolAOKbt9GYxgYeqOoqkfNfGPfNkiR0ULA04XsGsMaIpvfwaFStaHSom7l1mAiykfg1GNeL5bsP4KxywMRdZ(OcWbsP4SamT4ubzL2HiNlNPlyYCw0qjdM6bLpaKjG4t5tvHfWh7imMEbnBTW9XtIYSkSaykrp1eewIoHJL6jtxWKHZLB1ONiGP3CAVJDXlrgYdFQkSa(yhHX0liPMrZAPeYpGiFpvGRGMeL5bsP4wsacJW4ubUcYHiNl3aPuCwaMwCQGSs7qK5tvHfWh7imMEbj1mAnudCLobljgIi6P(sAdEsuMhiLIBGtXlCiY8PQWc4JDegtVGKAgTbdc7jyjzTuIEQr6jrzEGukolatlovqwPDiYOkGndysggVHNZdFQkSa(yhHX0liPMrRafiyQNujH2WO0G0MjrzwfwamLONAcclrNWXs9KPlyYW5YbWvJEIaMEZP9o2fVes6mrLEAblTRtLqeMeZ5jtaXNQclGp2rym9csQz0Kr2OiD8GtdMITjrzwfwamLONAcclrNWXs9KPlyYW5YTA0teW0BoT3XU4LiVYKpvfwaFSJWy6fKuZObgr3EOFcwsQKql0ANeL5bsP4SamT4ubzL2HiZNQclGp2rym9csQz0eWxqVTQr9uHPn0KOmpqkfNfGPfNkiR0oez(uvyb8XocJPxqsnJ2gYYmkfFclRcAsuMhiLIZcW0ItfKvAhImFQkSa(yhHX0liPMrllCzDGP4tlHHV(cAsuMhiLIZcW0ItfKvAhImFQkSa(yhHX0liPMrBjvoEWPctBi8eH0cgLmDbtgEgLjrz20fmzolAOKbt9GYhkU8KlhabOPlyYCTKYSwNSWKaWNzUCMUGjZ1skZADYclFZaitaHQPlyYCw0qjdM6bjbaK0akxoaA6cMmNfnuYGjzHLaqMsK)mr10fmzolAOKbt9GKidzaq8P8PQWc4JDLGXODEvqOjcPfmkz6cMm8mktIYmW6g6GrUsWy0oJcQDO5wfeYj3GWSqMf0MVzzAXb2O3snimlKzbT8PQWc4JDLGXOvQz0wfeAsuMbw3qhmYvcgJ2zaWNQclGp2vcgJwPMrJH86MIhlhRAb8NeLzG1n0bJCLGXODo)8PQWc4JDLGXOvQz0WzdzAsuMbw3qhmYvcgJ25mWNQclGp2vcgJwPMrd3UuNpLpvfwaFSReFGBPDgRaRGP0c1DsuMxQSeUvhmIpnJ4EaduqiUhJSe3BqUxsOfY9wlX9aRBOdgX9yi3JHne3dzDUhyLHqCFh(agnUN(o3JiZ9S4btB8G5tvHfWh7kXh4wALAgnG1n0bJM8AdnpiSL2qEcWkdHMZCsuMnLrV5K3OrzPSRATo61bJ68Pze3RclGp2vIpWT0k1mAcPfS4bNaw3qhmAYRn08GWwAd5jq55gvYobyLHqZ9fj6UnKDwiabNaRXt9e8tlvwc3ojkZMYO3CYB0OSu2vTwh96GrD(uvyb8XUs8bULwPMrtEJgLLYUQ1ojkZyzIXsMUGjd7K3OrzPSRATsGcQ9fj6o5nAuwk7QwRZcbi4eynEQNGFAPYs4wjaw3qhmYTHCYcbi4C5WYeJLmDbtg2jVrJYszx1ALaG5xkuKCtz0BoSoO1GqR1rVoyuhq8PQWc4JDL4dClTsnJ2gYteslyuY0fmz4zuMeLzac4Sqas8GZLdGl1OXJLsaBgWKmmEdl5MYO3CyDqRbHwRJEDWOoGYxhzvlGVKNPl)5Y1HMBdzNCdcZczwqB(KPfhyJEl1GWSqMf0ciu7ls0DBi7SqacobwJN6j4NwQSeUvcG1n0bJCBiNSqacMpvfwaFSReFGBPvQz0A0OzsuMhiLIlw4NYy1SyhImFQkSa(yxj(a3sRuZOvOfkciconcJM0Os2e90cw6zuMiKwWOKPlyYWZOWNYNQclGp2Hnszw78I8jvyb8tSaBtETHMhmiSBkd(4jrz2ug9MBWGWUPm4JD0Rdg1rDGukUbdc7MYGp21HzF(uvyb8XoSrkZALAgTvbHMiKwWOKPlyYWZOmjkZDO5wfeYj3GWSqMf0MpuC5fQ9fj6UvbHCwiabNaRXt9e8tlvwc3kba4tvHfWh7WgPmRvQz0S2vXTjHAtIYSkj0gg5YgSEQWiC7sFpEWo61bJ6Oc46qZzTRIBtc1CwiajEW8PQWc4JDyJuM1k1mAJfXuwcZuC7KOmRclGVBSiMYsyMIBDDTrbtsOclGVd3Uu311gfmXNQclGp2HnszwRuZOHZgYusO2KOmRclGVdNnKPKqnxxBuWKeQWc47WTl1DDTrbt8PQWc4JDyJuM1k1mA42L68P8PQWc4JDdLPVGMXiFjwAsuMhiLIJeSqgtjmKPRRdZ(OoqkfhjyHmMsmKxxxhM9rfGlvwc3QdgLlhavHfatj6PMGWsGcQQWcGPuhAomYxILYNkSaykrp1eegqaIpvfwaFSBOm9fKuZOHnDXilyAsuMhiLIJeSqgtjmKPRBPgnESecfBjlAOC5giLIJeSqgtjgYRRBPgnESecfBjlAi(uvyb8XUHY0xqsnJg20TelnjkZdKsXrcwiJPed511TuJgpwcHITKfnuUCyit3ejyHmMKit(uvyb8XUHY0xqsnJw2vT2jrzEGukosWczmLWqMUULA04XsiuSLSOHYLJH86MiblKXKezEvGPfhW)afazcGmrjtuYGdaxnRUF8GXxfWsgdsQGcydkGHsMCp3dulX9rJmCnUVaxUhWyNkkcZamY9lLXisSuN7XWgI7ved2Og15ErR(GjSJpfWC8e3JsEjzY9sgWhyAnQZ91OrYG7Xs)Mkz5EatCVb5EaZik33dGdCaFUhktRAWL7biAaI7biaKSaYXNYNcy3idxJ6CVKM7vHfWN7zb2Wo(0RQiwlCVAnAKmUklWg(a6QLGXO9a6afLdORsVoyu)q)QQWc4F1vbHUQydJ2qVkW6g6GrUsWy0Y9ZCpkCpQCFhAUvbHCYnimlKzbTCF(M5EzAXb2O3snimlKzbTxviTGrjtxWKHpqr5SduaCaDv61bJ6h6xvSHrBOxfyDdDWixjymA5(zUhaxvfwa)RUki0zhO5)a6Q0Rdg1p0VQydJ2qVkW6g6GrUsWy0Y9ZCF(VQkSa(xTbc)sSusO2zhOz4a6Q0Rdg1p0VQydJ2qVkW6g6GrUsWy0Y9ZCFgUQkSa(xfNnKPKqTZoqZZb0vvHfW)Q42L6xLEDWO(H(zND1s8bUL2dOduuoGUk96Gr9d9Rk2WOn0RUuzjCRoy0vvHfW)QyfyfmLwOUNDGcGdORsVoyu)q)Qq5RIj7QQWc4FvG1n0bJUkWkdHUAMxvSHrBOx1ug9MtEJgLLYUQ16OxhmQFvG1n9AdD1bHT0gYNDGM)dORsVoyu)q)QInmAd9QyzIXsMUGjd7K3OrzPSRATCVeCpkCpQCFFrIUtEJgLLYUQ16SqacobwJN6j4NwQSeUL7LG7bw3qhmYTHCYcbiyUpxoUhltmwY0fmzyN8gnklLDvRL7LG7bi3NFUxkUhfUxY5Etz0BoSoO1GqR1rVoyuN7b0vvHfW)QYB0OSu2vT2ZoqZWb0vPxhmQFOFvvyb8V6gYxvSHrBOxfGCpGJ7Tqas8G5(C54EaY9l1OXJ5EP4EbSzatYW4nm3l5CVPm6nhwh0AqO16OxhmQZ9aI7Zh33rw1c4Z9so3NPl)CFUCCFhAUnKDYnimlKzbTCF(4EzAXb2O3snimlKzbTCpG4Eu5((IeD3gYoleGGtG14PEc(PLklHB5Ej4EG1n0bJCBiNSqac(QcPfmkz6cMm8bkkNDGMNdORsVoyu)q)QInmAd9QdKsXfl8tzSAwSdr(QQWc4F1gnAo7anVoGUk96Gr9d9R2Os2e90cw6RIYvvHfW)QfAHIaIGtJWORkKwWOKPlyYWhOOC2zxLWy6f0b0bkkhqxLEDWO(H(vfBy0g6vvHfatj6PMGWCVeCFNWXs9KPlyYWCFUCC)QrpratV50Eh7IN7LG7ZqEUQkSa(x1AH7Jp7afahqxLEDWO(H(vfBy0g6vhiLIBjbimcJtf4kihIm3Nlh3pqkfNfGPfNkiR0oe5RQclG)vTwkH8diY3tf4kOZoqZ)b0vPxhmQFOFvXggTHE1bsP4g4u8chI8vvHfW)QnudCLobljgIi6P(sAd(Sd0mCaDv61bJ6h6xvSHrBOxDGukolatlovqwPDiYCpQCVa2mGjzy8gM7N5(8Cvvyb8V6GbH9eSKSwkrp1i9zhO55a6Q0Rdg1p0VQydJ2qVQkSaykrp1eeM7LG77eowQNmDbtgM7ZLJ7bi3VA0teW0BoT3XU45Ej4EjDMCpQCp90cwAxNkHimUxIzUppzY9a6QQWc4F1cuGGPEsLeAdJsdsBo7anVoGUk96Gr9d9Rk2WOn0RQclaMs0tnbH5Ej4(oHJL6jtxWKH5(C54(vJEIaMEZP9o2fp3lb3NxzEvvyb8VQmYgfPJhCAWuSD2bAg)a6Q0Rdg1p0VQydJ2qV6aPuCwaMwCQGSs7qKVQkSa(xfmIU9q)eSKujHwO1E2bkG)a6Q0Rdg1p0VQydJ2qV6aPuCwaMwCQGSs7qKVQkSa(xvaFb92Qg1tfM2qNDGkPpGUk96Gr9d9Rk2WOn0RoqkfNfGPfNkiR0oe5RQclG)v3qwMrP4tyzvqNDGIsMhqxLEDWO(H(vfBy0g6vhiLIZcW0ItfKvAhI8vvHfW)QzHlRdmfFAjm81xqNDGIckhqxLEDWO(H(vvHfW)QlPYXdovyAdHVQydJ2qVQPlyYCw0qjdM6bX95J7rXLhUpxoUhGCpa5EtxWK5AjLzTozHX9sW9a(m5(C54EtxWK5AjLzTozHX95BM7bqMCpG4Eu5EtxWK5SOHsgm1dI7LG7bGKM7be3Nlh3dqU30fmzolAOKbtYclbGm5Ej4(8Nj3Jk3B6cMmNfnuYGPEqCVeCFgYa3dORkKwWOKPlyYWhOOC2zxDOm9f0b0bkkhqxLEDWO(H(vfBy0g6vhiLIJeSqgtjmKPRRdZ(CpQC)aPuCKGfYykXqEDDDy2N7rL7bi3VuzjCRoye3Nlh3dqUxfwamLONAccZ9sW9OW9OY9QWcGPuhAomYxIL4(8X9QWcGPe9utqyUhqCpGUQkSa(xfJ8LyPZoqbWb0vPxhmQFOFvXggTHE1bsP4iblKXucdz66wQrJhZ9sW9cfBjlAiUpxoUFGukosWczmLyiVUULA04XCVeCVqXwYIg6QQWc4FvSPlgzbtNDGM)dORsVoyu)q)QInmAd9QdKsXrcwiJPed511TuJgpM7LG7fk2sw0qCFUCCpgY0nrcwiJjUxcUpZRQclG)vXMULyPZoqZWb0vPxhmQFOFvXggTHE1bsP4iblKXucdz66wQrJhZ9sW9cfBjlAiUpxoUNH86MiblKXe3lb3N5vvHfW)Qzx1Ap7SR2PIIWSdOduuoGUk96Gr9d9Rk2WOn0Roqkfxde(GeFQa3ghI8vvHfW)QlYNuHfWpXcSDvwGT0Rn0vhktFbD2bkaoGUQkSa(xfdccJLgkU9Q0Rdg1p0p7an)hqxLEDWO(H(vfBy0g6vhiLItOwQa3gxhM9VQkSa(xvOwQa3MZoqZWb0vvHfW)QYlml7Q0Rdg1p0p7anphqxLEDWO(H(vfBy0g6vhiLId3QDy2gI1DiYCFUCC)aPuCYlmlZHiFvvyb8V6I8jvyb8tSaBxLfyl9AdDvSrkZAp7anVoGUk96Gr9d9RQclG)vfkJLuHfWpXcSDvwGT0Rn0vfqiRdZ(NDGMXpGUk96Gr9d9Rk2WOn0RkGndysggVH5EjM5EaY95H7ZBUhyDdDWixbISc50imI7b0vvHfW)QlYNuHfWpXcSDvwGT0Rn0vlXh4wAp7afWFaDv61bJ6h6xvSHrBOxDGukUbofVWHiZ95YX9dKsXHr6D6tAZab36qKVQkSa(xDr(KkSa(jwGTRYcSLETHUk2iLzTNDGkPpGUk96Gr9d9Rk2WOn0RAkJEZnyqy3ug8Xo61bJ6CpQC)aPuCdge2nLbFSRdZ(CFUCCpGJ7nLrV5gmiSBkd(yh96GrDUhvUxaBgWKmmEdZ95J7bWvvHfW)Qc4dmeekzTuclhBy4ZoqrjZdORsVoyu)q)QInmAd9QMYO3Cdge2nLbFSJEDWOo3Jk3pqkf3GbHDtzWh76WSp3Jk3dqUNEAbln3lf3NFxE4EjN7PNwWs7wcm9CVuCpa5(mKj3l5C)aPuCcgPRqXw8GDiYCpG4EaX9smZ9aK7rbL8W95n3dG8Z9so3pqkfx8cDF1c4NajEWjyjzTukJf5bZihIm3diUhvUxfwamLgwY2amyAXC)m3N5vvHfW)QYqilTegISc6Sduuq5a6Q0Rdg1p0VQydJ2qVQPm6n3GbHDtzWh7OxhmQZ9OY9aK7hiLIBWGWUPm4JDDy2N7ZLJ7vHfatPHLSnadMwm3pZ9aG7b0vvHfW)QlYNuHfWpXcSDvwGT0Rn0vhmiSBkd(4ZoqrbahqxLEDWO(H(vvHfW)QRccDvXggTHE1LklHB1bJ4(C54EzAXb2O3snimlKzbTCVeCFhAUvbHCYnimlKzbTxviTGrjtxWKHpqr5SduuY)b0vPxhmQFOFvXggTHEvbSzatYW4nm3pZ9zEvvyb8VAHwLLkl9sI0NDGIsgoGUk96Gr9d9RQclG)vBGWVelLeQDvXggTHE1LklHB1bJUQqAbJsMUGjdFGIYzhOOKNdORsVoyu)q)QInmAd9Qlvwc3QdgX9OY99fj6oRDvCBsOMZcbi4eynEQNGFAPYs4wUxcUhyDdDWiN1UkUnzHae8vvHfW)Qw7Q42KqTZoqrjVoGUk96Gr9d9Rk2WOn0RcqUFGukolatlovqwPDiYCpQCpa5(vJEIaMEZP9o2fp3lb3dqUhfUxkUVrLSjrRUGjm3N3CVOvxWeovwvyb8vg3diUxY5(LeT6cMsw0qCpG4EaX9OY9aK7XYeJLmDbtg2nwetzjmtXTCVKZ9QWc47glIPSeMP4wxxBuWe3Jg3RclGVBSiMYsyMIBDci24EaX9sW9aK7vHfW3HBxQ76AJcM4E04Evyb8D42L6obeBCpGUQkSa(xDSiMYsyMIBp7afLm(b0vPxhmQFOFvXggTHEvSmXyjtxWKHD4SHmLeQX9sW9a4QQWc4FvC2qMsc1o7affa)b0vPxhmQFOFvXggTHE1bsP4emsxHIT4b7qKVQkSa(xf3Uu)SduuK0hqxLEDWO(H(vvHfW)QcLXsQWc4Nyb2UklWw61g6QLGXO9SZUQ8scyZqTdOduuoGUk96Gr9d9RcLVkMSRQclG)vbw3qhm6QaRme6QzEvG1n9AdD1cezfYPry0zhOa4a6Q0Rdg1p0Vku(QyYUQkSa(xfyDdDWORcSYqORIYvbw30Rn0vlbJr7zhO5)a6Q0Rdg1p0Vku(QyYUQkSa(xfyDdDWORcSYqORM5vfBy0g6vvjH2Wix2G1tfgHBx67Xd2rVoyu)QaRB61g6QLGXO9Sd0mCaDv61bJ6h6xfkFvmzxvfwa)RcSUHoy0vbwzi0vZ4xfyDtV2qxDd5KfcqWNDGMNdORsVoyu)q)Qq5RIj7QQWc4FvG1n0bJUkWkdHUkG)QaRB61g6Qw7Q42KfcqWNDGMxhqxLEDWO(H(vHYxft2vvHfW)QaRBOdgDvGvgcD1mVQydJ2qVQkj0gg5YgSEQWiC7sFpEWo61bJ6xfyDtV2qx1Axf3MSqac(Sd0m(b0vvHfW)QGeFFPEclhBy4RsVoyu)q)Sdua)b0vPxhmQFOFvXggTHE1bsP4AGWhK4tf4246WS)vvHfW)QYlml7Sduj9b0vPxhmQFOFvXggTHE1bsP4AGWhK4tf4246WS)vvHfW)Qc1sf42C2zxfBKYS2dOduuoGUk96Gr9d9Rk2WOn0RAkJEZnyqy3ug8Xo61bJ6CpQC)aPuCdge2nLbFSRdZ(xvfwa)RUiFsfwa)elW2vzb2sV2qxDWGWUPm4Jp7afahqxLEDWO(H(vvHfW)QRccDvXggTHE1o0CRcc5KBqywiZcA5(8X9O4YlUhvUVVir3TkiKZcbi4eynEQNGFAPYs4wUxcUhaxviTGrjtxWKHpqr5Sd08FaDv61bJ6h6xvSHrBOxvLeAdJCzdwpvyeUDPVhpyh96GrDUhvUhWX9DO5S2vXTjHAoleGep4RQclG)vT2vXTjHANDGMHdORsVoyu)q)QInmAd9QQWc47glIPSeMP4wxxBuWe3lb3RclGVd3Uu311gfmDvvyb8V6yrmLLWmf3E2bAEoGUk96Gr9d9Rk2WOn0RQclGVdNnKPKqnxxBuWe3lb3RclGVd3Uu311gfmDvvyb8VkoBitjHANDGMxhqxvfwa)RIBxQFv61bJ6h6ND2vfqiRdZ(hqhOOCaDvvyb8V6GwmTGCv61bJ6h6NDGcGdORQclG)vJxO7Rwa)RsVoyu)q)Sd08FaDvvyb8Vk1idZsBAa)(vPxhmQFOF2bAgoGUk96Gr9d9Rk2WOn0Roqkf3aNIx4qK5(C54Etz0BU4f6(QfW3rVoyuN7rL7fqiRdZ(U4f6(QfW3TuJgpM7LG7lb4wlTuJgpM7ZLJ7bCCVPm6nx8cDF1c47OxhmQZ9OY9ciK1HzF3GwmTG4wQrJhZ9sW9LaCRLwQrJhFvvyb8V6QatpebNkl9sI0NDGMNdORsVoyu)q)QInmAd9QDAGukUvbHCiYCpQCFNgiLIBdzhI8vvHfW)QAxLTaykHZQBZzhO51b0vPxhmQFOFvXggTHEv6PfS0UovcryCVeCFEYd3Nlh33HMBvqi3sLLWT6GrCFUCCFhAUnKDlvwc3QdgX9OY9cyZaMKHXByUFM7fWMbmjdJ3WUgvYY95YX9aK7hiLIBGtXlCiYCpQC)aPuCdCkEHBPgnEm3NpUhL8Z9a6QQWc4FvlatlovqwPp7anJFaDv61bJ6h6xvSHrBOxDGukolatlovqwPDiYCpQC)aPuCdCkEHRdZ(CpQCVa2mGjzy8gM7Zh3NbUhvUVdn3QGqo5geMfYSGwUpFCpkU8I7rL7PNwWsZ9sW9ziZRQclG)vXTAhMTHy9Zoqb8hqxLEDWO(H(vfBy0g6vhiLIZcW0ItfKvAhIm3Nlh3pqkf3aNIx4qKVQkSa(xDqlMwqIh8zhOs6dORsVoyu)q)QInmAd9QdKsXnWP4foezUpxoUFGukUbdc7meS5qKVQkSa(xvgAb8p7afLmpGUk96Gr9d9RQclG)vfkJLuHfWpXcSDvwGT0Rn0vjmMEbD2bkkOCaDv61bJ6h6xvfwa)RQ4wG1NWPvLe4MeWvzxvSHrBOxDGuko5fML56WSp3Jk3dqUVtdKsXTQKa3KaUkl1PbsP46WSp3Nlh33PbsP4eWVJiSaykfpiPonqkfhIm3Jk3B6cMmNfnuYGjzHLYFMCF(4EuC5H7ZLJ7bCCFNgiLIta)oIWcGPu8GK60aPuCiYCpQCpa5(onqkf3QscCtc4QSuNgiLIdBQaeUxIzUha5H7ZBUhLm5EjN770aPuCdge2tWsYAPe9uJ0oezUpxoU30fmzolAOKbt9G4(8X9zitUhqCpQC)aPuCwaMwCQGSs7wQrJhZ9sW9OKj3dOR(AdDvf3cS(eoTQKa3KaUk7SduuaWb0vPxhmQFOFvXggTHE1bsP4KxywMRdZ(CpQCpa5(bsP4SamT4ubzL2HiZ95YX9MUGjZzrdLmyQhe3NpUhazY9a6QQWc4FvemLcJAWND2vhmiSBkd(4dOduuoGUk96Gr9d9RQclG)vxfe6QInmAd9QaK7bCCVfcqIhm3Nlh3dqUFPYs4wDWiUhvUxMwCGn6TudcZczwql3lb33HMBvqiNCdcZczwql3diUhqCpQC)aPuCdlTkiKRdZ(CpQCFFrIUBvqiNfcqWjWA8upb)0sLLWTCVeZCpaUQqAbJsMUGjdFGIYzhOa4a6Q0Rdg1p0VQkSa(xTbc)sSusO2vfBy0g6vxQSeUvhmI7rL7hiLIByPgi8lXsUom7FvH0cgLmDbtg(afLZoqZ)b0vPxhmQFOFvvyb8VQ1UkUnju7QInmAd9Qlvwc3QdgX9OY9dKsXnSK1UkU11HzFUhvUVVir3zTRIBtc1CwiabNaRXt9e8tlvwc3Y9sW9a(RkKwWOKPlyYWhOOC2bAgoGUk96Gr9d9Rk2WOn0Roqkf3WsJfXuwcZuCRRdZ(xvfwa)RowetzjmtXTNDGMNdORsVoyu)q)QInmAd9QdKsXnSeoBitUom7Z9OY9yzIXsMUGjd7WzdzkjuJ7LG7r5QQWc4FvC2qMsc1o7anVoGUk96Gr9d9Rk2WOn0Roqkf3Ws42L6Uom7Fvvyb8VkUDP(zhOz8dORsVoyu)q)QInmAd9QdKsXnSeoBitUom7Fvvyb8VkoBitjHANDGc4pGUk96Gr9d9Rk2WOn0Roqkf3Wsw7Q4wxhM9VQkSa(x1Axf3MeQD2zND2z3b]] )

    
end
