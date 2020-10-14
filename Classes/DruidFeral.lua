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

    spec:RegisterPack( "Feral", 20201014.2, [[dKuHdbqiGK8irGUeqczteHpbKGgfaCka0Qeb8kIOzPiULiLAxu5xqsdte6yqILbK6zIuzAIGUMifBdsv9nrkPXbKuNdsfwhKQO5jsv3trTpIKdksjWcHuEiKQWefPeAJqQiFeib6KajQvQintGeQBcKa2jq8tGePLcPI6PsAQa0xbse7vL)kQbtvhM0Iv4XeMSuDzKnlXNbQrlLoTWQfPe9Aa1Sr1TLIDRQFdA4e1XfPe0Yv65qnDkxhITdiFxenEivPZtKA9qQ08fj7hLpuoaVAxn6ab0jc6erjrusOdf0pr0r6q)RAsltxvwfaRGPR(AdDv0jAv(vLvP5qTFaEvmezf0vBntgJEIkQGdRfz4eWguXrdcxTa(IvlgQ4OrG6vhib3aL)BC1UA0bcOte0jIsIOKqhkOFIOJ0b6RILjXbckjMUR2g9o934QDclUAcY8Ot0QCMpT4IeD20eK5bLkm4GwMhLeoH5bDIGor2u20eK5rpA1hmHrpzttqMpTzE0wet5mFLR4wMhvMVMmKjMVJSXdM5rJwmTaZ8OY8GYVq3xTa(mFuy(Wy(bPgM5RTl1z(U2OGjhBAcY8PnZJotLLWTmpGTRIBz(cCzEqjbVZ8OtCc3U03JhS7QYlSeC6QjiZJorRYz(0Ils0zttqMhuQWGdAzEus4eMh0jc6eztzttqMh9OvFWeg9Knnbz(0M5rBrmLZ8vUIBzEuz(AYqMy(oYgpyMhnAX0cmZJkZdk)cDF1c4Z8rH5dJ5hKAyMV2UuN57AJcMCSPjiZN2mp6mvwc3Y8a2UkUL5lWL5bLe8oZJoXjC7sFpEWo2u2uvyb8Xo5LeWMHAsoJkq6g6GttETHMlqKviNhHrtas5i0CISPjiZxBxQZ8ZmFItyEqGFAJFvg3cnMhDwbMy(zMhLjmF9vzCl0yE0zfyI5NzEqpH5bfdkZ8ZmF6MW81KHmX8ZmFcztvHfWh7KxsaBgQj5mQaPBOdon51gAUeCoTtas5i0mkSPQWc4JDYljGnd1KCgvG0n0bNM8AdnxcoN2jaPCeAoXjrzwrxAdJCjdEpx4eUDPVhpyh96GtD2uvyb8Xo5LeWMHAsoJkq6g6GttETHM3qoBHay8eGuocnNwztvHfWh7KxsaBgQj5mQaPBOdon51gA2Axf3MTqamEcqkhHMb1SPQWc4JDYljGnd1KCgvG0n0bNM8AdnBTRIBZwiagpbiLJqZjojkZk6sByKlzW75cNWTl994b7OxhCQZMQclGp2jVKa2mutYzubo((s9mwo2WWSPQWc4JDYljGnd1KCgv5fMKpjkZdKsX1aHpWXNlWTX1HjF2uvyb8Xo5LeWMHAsoJQqTCbUntIY8aPuCnq4dC85cCBCDyYNnLnvfwaF88I8zvyb8Z8aBtETHMhkxFbnjkZdKsX1aHpWXNlWTXHiZMQclGpwYzuXaJW55HIBztvHfWhl5mQc1Yf42mjkZdKsXjulxGBJRdt(SPQWc4JLCgv5fMKZMMGmpO0NyECl0yESrk3Az(gs0QFiWmVPatmV8gWnmPztvHfWhl5mQlYNvHfWpZdSn51gAgBKYT2jrzEGukoCR2HjBiE3HiNk1aPuCYlmj3HiZMQclGpwYzufkNNvHfWpZdSn51gAwaH8om5ZMQclGpwYzuxKpRclGFMhyBYRn0Cj(a3s7KOmlGndywggVHLAgaPjTbs3qhCYvGiRqopcJaiBAcY8GcGWTiTbl6mp2iLBTmFhsyM)HgBQkSa(yjNrDr(SkSa(zEGTjV2qZyJuU1ojkZdKsXnW54foe5uPgiLIdJ070N1MbcU1HiZMQclGpwYzufWhiiWu2APmwo2WWtIYSPC6n3GdHDt5Wh7OxhCQlXaPuCdoe2nLdFSRdt(PsbQmLtV5gCiSBkh(yh96GtDjeWMbmldJ3WPh0SPjiZdylX8nqSX8e6vMECaeX8ObiZlKwWjMhaa2UeUL5RTl1z(AYqMyEbeBmpkOKgMNEAbl9eMVrbMyEmYsmFsI5f6Z8nkWeZBTQX8XZ8jK5bZHdLJbiBQkSa(yjNrvgc55LWqKvqtIYSPC6n3GdHDt5Wh7OxhCQlXaPuCdoe2nLdFSRdt(saa6PfS0sMoxAsa6PfS0ULatVKaiHjMadKsXj4KUcfBXd2Hidqak1maqbL0K2GoDjWaPuCXl09vlGFg44bNHLS1s50sKhmNCiYaucvybquEyzBdWGPfpNiBQkSa(yjNrDr(SkSa(zEGTjV2qZdoe2nLdF8KOmBkNEZn4qy3uo8Xo61bN6saGbsP4gCiSBkh(yxhM8tLsfwaeLhw22amyAXZGgGSPQWc4JLCg1vbMMiKwWPSPlyYWZOmjkZlvwc3QdoLkLmT4aB0B5geUfY8GwP6qZTkWKtUbHBHmpOLnvfwaFSKZOwOv55Ysp6k9KOmlGndywggVHNtKnvfwaFSKZO2aHFjwkluBIqAbNYMUGjdpJYKOmVuzjCRo4eBQkSa(yjNr1Axf3MfQnjkZlvwc3QdojrFrIUZAxf3MfQ5SqamodwJN6z4NxQSeUvkG0n0bNCw7Q42SfcGXSPQWc4JLCg1XIykpJ5kUDsuMbWaPuCwaMwCUGSs7qKLaaRg9mbe9Mt7DSlEPaaks2OO3SOvxWeoTfT6cMW5YQclGVYbycSKOvxWu2IgcGaucaGLjopB6cMmSBSiMYZyUIBtavyb8DJfXuEgZvCRRRnkycuKkSa(UXIykpJ5kU1jGydGsbavyb8D42L6UU2OGjqrQWc47WTl1Dci2aiBQkSa(yjNrfNmKPSqTjrzgltCE20fmzyhozitzHAsbA2uvyb8XsoJkUDP(KOmpqkfNGt6kuSfpyhImBQkSa(yjNrvOCEwfwa)mpW2KxBO5sW50YMYMQclGp2n4qy3uo8XZRcmnriTGtztxWKHNrzsuMbaOYcbWXdovkaSuzjCRo4KeY0IdSrVLBq4wiZdALQdn3Qato5geUfY8GwacqjgiLIBy5vbMCDyYxI(IeD3QatoleaJZG14PEg(5LklHBLAg0SPQWc4JDdoe2nLdFSKZOYrEDZXJLJvTa(tesl4u20fmz4zuMeL5LklHB1bNKyGukUHLBGWVel56WKpBQkSa(y3GdHDt5Whl5mQw7Q42SqTjcPfCkB6cMm8mktIY8sLLWT6Gtsmqkf3WYw7Q4wxhM8LOVir3zTRIBZc1CwiagNbRXt9m8Zlvwc3kfOMnvfwaFSBWHWUPC4JLCg1XIykpJ5kUDsuMhiLIBy5XIykpJ5kU11HjF2uvyb8XUbhc7MYHpwYzuXjdzkluBsuMhiLIByzCYqMCDyYxcSmX5ztxWKHD4KHmLfQjfkSPQWc4JDdoe2nLdFSKZOIBxQpjkZdKsXnSmUDPURdt(SPQWc4JDdoe2nLdFSKZOItgYuwO2KOmpqkf3WY4KHm56WKpBQkSa(y3GdHDt5Whl5mQw7Q42SqTjrzEGukUHLT2vXTUom5ZMYMQclGp2jGqEhM8Nh0IPfy2uvyb8XobeY7WKVKZOgVq3xTa(SPQWc4JDciK3HjFjNrLAKHjPnpGFNnvfwaFStaH8om5l5mQRce9qeCUS0JUspjkZdKsXnW54foe5uPmLtV5IxO7RwaFh96GtDjeqiVdt(U4f6(QfW3TuJgpwQsaU1Yl1OXJtLcuzkNEZfVq3xTa(o61bN6siGqEhM8DdAX0cSBPgnESuLaCRLxQrJhZMQclGp2jGqEhM8LCgvTRYwaeLXj1TzsuM70aPuCRcm5qKLOtdKsXTHSdrMnnbzEaxPzE97m)dnMpPInI5beDI5PNwWspH5higZRCmK5bdz(cCzE0LwGzE97mF8cDF2uvyb8XobeY7WKVKZOAbyAX5cYk9KOmtpTGL21PsictQ0KMuP6qZTkWKBPYs4wDWPuP6qZTHSBPYs4wDWjjeWMbmldJ3WZcyZaMLHXByxJIEtLcadKsXnW54foezjgiLIBGZXlCl1OXJtpkPdGSPQWc4JDciK3HjFjNrf3QDyYgI3NeL5bsP4SamT4CbzL2HilXaPuCdCoEHRdt(siGndywggVHtFcLOdn3Qato5geUfY8G20JId9LGEAblTujmr2uvyb8XobeY7WKVKZOoOftlWXdEsuMhiLIZcW0IZfKvAhICQudKsXnW54foez2uvyb8XobeY7WKVKZOkdTa(tIY8aPuCdCoEHdrovQbsP4gCiSZrWMdrMnvfwaFStaH8om5l5mQcLZZQWc4N5b2M8Adntym9cInvfwaFStaH8om5l5mQiykhg1m51gAwXTaPpHZRIUWnlGRYNeL5bsP4KxysURdt(saGonqkf3QOlCZc4Q8CNgiLIRdt(Ps1PbsP4eWVJiSaikhpW5onqkfhISeMUGjZzrdLnywwy50Ly6rXLMuPavDAGukob87iclaIYXdCUtdKsXHilba60aPuCRIUWnlGRYZDAGukoSPcGLAg0PjTrjXeOtdKsXn4qypdlzRLY0tns7qKtLY0fmzolAOSbZ9GsFcteGsmqkfNfGPfNliR0ULA04XsHsIaKnvfwaFStaH8om5l5mQiykhg1GNeL5bsP4KxysURdt(saGbsP4SamT4CbzL2HiNkLPlyYCw0qzdM7bLEqNiaztztvHfWh7imMEbnBTW9XtIYSkSaiktp1eewQoHJL6ztxWKHtLA1ONjGO3CAVJDXlvctdBQkSa(yhHX0lijNr1APmYpGiFpxGRGMeL5bsP4wsamNW4CbUcYHiNk1aPuCwaMwCUGSs7qKztvHfWh7imMEbj5mQnudCLodlzoIi65(sAdEsuMhiLIBGZXlCiYSPQWc4JDegtVGKCg1bhc7zyjBTuMEQr6jrzEGukolatloxqwPDiYsiGndywggVHNtdBQkSa(yhHX0lijNrTafiyQNv0L2WO8G0MjrzwfwaeLPNAcclvNWXs9SPlyYWPsbGvJEMaIEZP9o2fVuOJeLGEAblTRtLqeMuZPjraYMQclGp2rym9csYzuLr2OiD8GZdUITjrzwfwaeLPNAcclvNWXs9SPlyYWPsTA0Zeq0BoT3XU4Lc9tKnvfwaFSJWy6fKKZOcgr3EOFgwYk6sl0ANeL5bsP4SamT4CbzL2HiZMQclGp2rym9csYzufWxqVTQr9CHRn0KOmpqkfNfGPfNliR0oez2uvyb8XocJPxqsoJ6gYYCkhFglRcAsuMhiLIZcW0IZfKvAhImBQkSa(yhHX0lijNrnjC5DGO4ZlHHV(cAsuMhiLIZcW0IZfKvAhImBQkSa(yhHX0lijNrDjvoEW5cxBi8eH0coLnDbtgEgLjrz20fmzolAOSbZ9GspkU0KkfaaGPlyYCTKYTwNSWKcuNyQuMUGjZ1sk3ADYcl9ZGorakHPlyYCw0qzdM7bjfOrhamvkay6cMmNfnu2GzzHLbDIsLUeLW0fmzolAOSbZ9GKkHjeGSPSPQWc4JDLGZPDEvGPjcPfCkB6cMm8mktIYmq6g6GtUsW50oJIeDO5wfyYj3GWTqMh0M(zzAXb2O3YniClK5bTSPQWc4JDLGZPvYzuxfyAsuMbs3qhCYvcoN2zqZMQclGp2vcoNwjNrLJ86MJhlhRAb8NeLzG0n0bNCLGZPDoDSPQWc4JDLGZPvYzuXjdzAsuMbs3qhCYvcoN25eYMQclGp2vcoNwjNrf3UuNnLnvfwaFSReFGBPDgRaPGP8c1DsuMxQSeUvhCInnbzEqbuGjMhJSeZBqMhDPfY8wlX8aPBOdoX8yiZJHneZd5DMhiLJqmFh(GcnMN(oZJiZ884btB8GztvHfWh7kXh4wALCgvG0n0bNM8AdnpiSL3qEcqkhHMtCsuMnLtV5K3Or55KRATo61bN6SPjiZRclGp2vIpWT0k5mQcPf84bNbs3qhCAYRn08GWwEd5jq55gf9obiLJqZ9fj6UnKDwiagNbRXt9m8Zlvwc3ojkZMYP3CYB0O8CYvTwh96GtD2uvyb8XUs8bULwjNrvEJgLNtUQ1ojkZ9fj6o5nAuEo5QwRZcbW4mynEQNHFEPYs4wPas3qhCYTHC2cbW4uPWYeNNnDbtg2jVrJYZjx1ALcaPtsusat50BoSoO1GqR1rVo4uhGSPQWc4JDL4dClTsoJ6gYtesl4u20fmz4zuMeLzaaQSqaC8GtLcal1OXJLuaBgWSmmEdNaMYP3CyDqRbHwRJEDWPoatFhzvlGFcKOlDPs1HMBdzNCdc3czEqB6LPfhyJEl3GWTqMh0cqj6ls0DBi7SqamodwJN6z4NxQSeUvkG0n0bNCBiNTqamMnvfwaFSReFGBPvYzuB0OzsuMhiLIlw4Ntl1KyhImBQkSa(yxj(a3sRKZOwOfkcicopcJM0OO3m90cw6zuMiKwWPSPlyYWZOWMYMQclGp2Hns5w78I8zvyb8Z8aBtETHMhCiSBkh(4jrz2uo9MBWHWUPC4JD0Rdo1LyGukUbhc7MYHp21HjF2uvyb8XoSrk3ALCg1vbMMiKwWPSPlyYWZOmjkZDO5wfyYj3GWTqMh0MEuCOVe9fj6UvbMCwiagNbRXt9m8Zlvwc3kfOztvHfWh7WgPCRvYzuT2vXTzHAtIYSIU0gg5sg8EUWjC7sFpEWo61bN6saQ6qZzTRIBZc1CwiaoEWSPQWc4JDyJuU1k5mQJfXuEgZvC7KOmRclGVBSiMYZyUIBDDTrbtsPclGVd3Uu311gfmXMQclGp2Hns5wRKZOItgYuwO2KOmRclGVdNmKPSqnxxBuWKuQWc47WTl1DDTrbtSPQWc4JDyJuU1k5mQ42L6SPSPQWc4JDdLRVGMXiFjwAsuMhiLIJe8qgtzmKRRRdt(smqkfhj4HmMYCKxxxhM8Laalvwc3QdoLkfauHfarz6PMGWsHIeQWcGOChAomYxILsVkSaiktp1eegGaKnvfwaFSBOC9fKKZOInDXilyAsuMhiLIJe8qgtzmKRRBPgnESucfBzlAOuPgiLIJe8qgtzoYRRBPgnESucfBzlAi2uvyb8XUHY1xqsoJk20TelnjkZdKsXrcEiJPmh511TuJgpwkHITSfnuQuyix3mj4HmMKkr2uvyb8XUHY1xqsoJAYvT2jrzEGukosWdzmLXqUUULA04XsjuSLTOHsLIJ86MjbpKXKujEvGOfhW)ab0jc6erjrusOdLRMu3pEW4RckjTa0zqaLbbuq0tMN5bSLy(OrgUgZxGlZdkStffHBGcz(LslejwQZ8yydX8kIbBuJ6mVOvFWe2XMckoEI5rb9rpzE0d4deTg1z(A0GEW8yPFtrVmpOiM3GmpOyeL57bqboGpZdLPvn4Y8aavaY8aa0Oxa6ytztbLBKHRrDMhDW8QWc4Z88aByhB6v5b2WhGxTeCoThGhiOCaEv61bN6hAxvfwa)RUkW0vfBy0g6vbs3qhCYvcoNwMFM5rH5LG57qZTkWKtUbHBHmpOL5t)mZltloWg9wUbHBHmpO9QcPfCkB6cMm8bckNDGa6dWRsVo4u)q7QInmAd9QaPBOdo5kbNtlZpZ8G(QQWc4F1vbMo7ajDhGxLEDWP(H2vfBy0g6vbs3qhCYvcoNwMFM5t3vvHfW)Qnq4xILYc1o7ajHhGxLEDWP(H2vfBy0g6vbs3qhCYvcoNwMFM5t4vvHfW)Q4KHmLfQD2bsAoaVQkSa(xf3Uu)Q0Rdo1p0o7SRwIpWT0EaEGGYb4vPxhCQFODvXggTHE1LklHB1bNUQkSa(xfRaPGP8c19SdeqFaEv61bN6hAxfkFvmzxvfwa)RcKUHo40vbs5i0vt8QInmAd9QMYP3CYB0O8CYvTwh96Gt9RcKU5xBORoiSL3q(SdK0DaEv61bN6hAxvSHrBOxTVir3jVrJYZjx1ADwiagNbRXt9m8Zlvwc3Y8sX8aPBOdo52qoBHaymZNkfZJLjopB6cMmStEJgLNtUQ1Y8sX8aG5thZljZJcZNamVPC6nhwh0AqO16OxhCQZ8a8QQWc4Fv5nAuEo5Qw7zhij8a8Q0Rdo1p0UQkSa(xDd5Rk2WOn0RcaMhuX8wiaoEWmFQumpay(LA04XmVKmVa2mGzzy8gM5taM3uo9MdRdAni0AD0Rdo1zEaY8PN57iRAb8z(eG5t0LoMpvkMVdn3gYo5geUfY8GwMp9mVmT4aB0B5geUfY8GwMhGmVemFFrIUBdzNfcGXzWA8upd)8sLLWTmVumpq6g6GtUnKZwiagFvH0coLnDbtg(abLZoqsZb4vPxhCQFODvXggTHE1bsP4If(50snj2HiFvvyb8VAJgnNDGG(hGxLEDWP(H2vBu0BMEAbl9vr5QQWc4F1cTqrarW5ry0vfsl4u20fmz4deuo7SRsym9c6a8abLdWRsVo4u)q7QInmAd9QQWcGOm9utqyMxkMVt4yPE20fmzyMpvkMF1ONjGO3CAVJDXZ8sX8jmnxvfwa)RATW9XNDGa6dWRsVo4u)q7QInmAd9QdKsXTKayoHX5cCfKdrM5tLI5hiLIZcW0IZfKvAhI8vvHfW)QwlLr(be575cCf0zhiP7a8Q0Rdo1p0UQydJ2qV6aPuCdCoEHdr(QQWc4F1gQbUsNHLmhre9CFjTbF2bscpaVk96Gt9dTRk2WOn0RoqkfNfGPfNliR0oezMxcMxaBgWSmmEdZ8ZmFAUQkSa(xDWHWEgwYwlLPNAK(SdK0CaEv61bN6hAxvSHrBOxvfwaeLPNAccZ8sX8Dchl1ZMUGjdZ8PsX8aG5xn6zci6nN27yx8mVump6irMxcMNEAblTRtLqegZl1mZNMezEaEvvyb8VAbkqWupROlTHr5bPnNDGG(hGxLEDWP(H2vfBy0g6vvHfarz6PMGWmVumFNWXs9SPlyYWmFQum)QrptarV50Eh7IN5LI5r)eVQkSa(xvgzJI0Xdop4k2o7ajTEaEv61bN6hAxvSHrBOxDGukolatloxqwPDiYxvfwa)Rcgr3EOFgwYk6sl0Ap7abuFaEv61bN6hAxvSHrBOxDGukolatloxqwPDiYxvfwa)RkGVGEBvJ65cxBOZoqqhhGxLEDWP(H2vfBy0g6vhiLIZcW0IZfKvAhI8vvHfW)QBilZPC8zSSkOZoqqjXdWRsVo4u)q7QInmAd9QdKsXzbyAX5cYkTdr(QQWc4F1KWL3bIIpVeg(6lOZoqqbLdWRsVo4u)q7QQWc4F1Lu54bNlCTHWxvSHrBOx10fmzolAOSbZ9Gy(0Z8O4sdZNkfZdaMhamVPlyYCTKYTwNSWyEPyEqDImFQumVPlyYCTKYTwNSWy(0pZ8GorMhGmVemVPlyYCw0qzdM7bX8sX8GgDW8aK5tLI5baZB6cMmNfnu2GzzHLbDImVumF6sK5LG5nDbtMZIgkBWCpiMxkMpHjK5b4vfsl4u20fmz4deuo7SRouU(c6a8abLdWRsVo4u)q7QInmAd9QdKsXrcEiJPmgY111HjFMxcMFGukosWdzmL5iVUUom5Z8sW8aG5xQSeUvhCI5tLI5baZRclaIY0tnbHzEPyEuyEjyEvybquUdnhg5lXsmF6zEvybquMEQjimZdqMhGxvfwa)RIr(sS0zhiG(a8Q0Rdo1p0UQydJ2qV6aPuCKGhYykJHCDDl1OXJzEPyEHITSfneZNkfZpqkfhj4HmMYCKxx3snA8yMxkMxOylBrdDvvyb8Vk20fJSGPZoqs3b4vPxhCQFODvXggTHE1bsP4ibpKXuMJ866wQrJhZ8sX8cfBzlAiMpvkMhd56MjbpKXeZlfZN4vvHfW)Qyt3sS0zhij8a8Q0Rdo1p0UQydJ2qV6aPuCKGhYykJHCDDl1OXJzEPyEHITSfneZNkfZZrEDZKGhYyI5LI5t8QQWc4F1KRATND2v7urr42b4bckhGxLEDWP(H2vfBy0g6vhiLIRbcFGJpxGBJdr(QQWc4F1f5ZQWc4N5b2UkpWw(1g6QdLRVGo7ab0hGxvfwa)RIbgHZZdf3Ev61bN6hANDGKUdWRsVo4u)q7QInmAd9QdKsXjulxGBJRdt(xvfwa)RkulxGBZzhij8a8QQWc4Fv5fMKFv61bN6hANDGKMdWRsVo4u)q7QInmAd9QdKsXHB1omzdX7oezMpvkMFGuko5fMK7qKVQkSa(xDr(SkSa(zEGTRYdSLFTHUk2iLBTNDGG(hGxLEDWP(H2vvHfW)QcLZZQWc4N5b2UkpWw(1g6QciK3Hj)ZoqsRhGxLEDWP(H2vfBy0g6vfWMbmldJ3WmVuZmpay(0W8PnZdKUHo4KRarwHCEegX8a8QQWc4F1f5ZQWc4N5b2UkpWw(1g6QL4dClTNDGaQpaVk96Gt9dTRk2WOn0Roqkf3aNJx4qKz(uPy(bsP4Wi9o9zTzGGBDiYxvfwa)RUiFwfwa)mpW2v5b2YV2qxfBKYT2ZoqqhhGxLEDWP(H2vfBy0g6vnLtV5gCiSBkh(yh96GtDMxcMFGukUbhc7MYHp21HjFMpvkMhuX8MYP3Cdoe2nLdFSJEDWPoZlbZlGndywggVHz(0Z8G(QQWc4Fvb8bccmLTwkJLJnm8zhiOK4b4vPxhCQFODvXggTHEvt50BUbhc7MYHp2rVo4uN5LG5hiLIBWHWUPC4JDDyYN5LG5baZtpTGLM5LK5tNlnmFcW80tlyPDlbMEMxsMhamFctK5taMFGukobN0vOylEWoezMhGmpazEPMzEaW8OGsAy(0M5bD6y(eG5hiLIlEHUVAb8Zahp4mSKTwkNwI8G5KdrM5biZlbZRclaIYdlBBagmTyMFM5t8QQWc4FvziKNxcdrwbD2bckOCaEv61bN6hAxvSHrBOx1uo9MBWHWUPC4JD0Rdo1zEjyEaW8dKsXn4qy3uo8XUom5Z8PsX8QWcGO8WY2gGbtlM5NzEqZ8a8QQWc4F1f5ZQWc4N5b2UkpWw(1g6Qdoe2nLdF8zhiOa6dWRsVo4u)q7QQWc4F1vbMUQydJ2qV6sLLWT6GtmFQumVmT4aB0B5geUfY8GwMxkMVdn3Qato5geUfY8G2RkKwWPSPlyYWhiOC2bckP7a8Q0Rdo1p0UQydJ2qVQa2mGzzy8gM5Nz(eVQkSa(xTqRYZLLE0v6ZoqqjHhGxLEDWP(H2vvHfW)Qnq4xILYc1UQydJ2qV6sLLWT6GtxviTGtztxWKHpqq5SdeusZb4vPxhCQFODvXggTHE1LklHB1bNyEjy((IeDN1UkUnluZzHayCgSgp1ZWpVuzjClZlfZdKUHo4KZAxf3MTqam(QQWc4FvRDvCBwO2zhiOG(hGxLEDWP(H2vfBy0g6vbaZpqkfNfGPfNliR0oezMxcMham)QrptarV50Eh7IN5LI5baZJcZljZ3OO3SOvxWeM5tBMx0QlycNlRkSa(kN5biZNam)sIwDbtzlAiMhGmpazEjyEaW8yzIZZMUGjd7glIP8mMR4wMpbyEvyb8DJfXuEgZvCRRRnkyI5rL5vHfW3nwet5zmxXTobeBmpazEPyEaW8QWc47WTl1DDTrbtmpQmVkSa(oC7sDNaInMhGxvfwa)Rowet5zmxXTNDGGsA9a8Q0Rdo1p0UQydJ2qVkwM48SPlyYWoCYqMYc1yEPyEqFvvyb8VkozitzHANDGGcO(a8Q0Rdo1p0UQydJ2qV6aPuCcoPRqXw8GDiYxvfwa)RIBxQF2bckOJdWRsVo4u)q7QQWc4FvHY5zvyb8Z8aBxLhyl)AdD1sW50E2zxvEjbSzO2b4bckhGxLEDWP(H2vHYxft2vvHfW)QaPBOdoDvGuocD1eVkq6MFTHUAbISc58im6SdeqFaEv61bN6hAxfkFvmzxvfwa)RcKUHo40vbs5i0vr5QaPB(1g6QLGZP9SdK0DaEv61bN6hAxfkFvmzxvfwa)RcKUHo40vbs5i0vt8QInmAd9Qk6sByKlzW75cNWTl994b7OxhCQFvG0n)AdD1sW50E2bscpaVk96Gt9dTRcLVkMSRQclG)vbs3qhC6QaPCe6QP1RcKU5xBORUHC2cbW4ZoqsZb4vPxhCQFODvO8vXKDvvyb8Vkq6g6GtxfiLJqxfuFvG0n)AdDvRDvCB2cbW4Zoqq)dWRsVo4u)q7Qq5RIj7QQWc4FvG0n0bNUkqkhHUAIxvSHrBOxvrxAdJCjdEpx4eUDPVhpyh96Gt9RcKU5xBORATRIBZwiagF2bsA9a8QQWc4FvGJVVupJLJnm8vPxhCQFOD2bcO(a8Q0Rdo1p0UQydJ2qV6aPuCnq4dC85cCBCDyY)QQWc4Fv5fMKF2bc64a8Q0Rdo1p0UQydJ2qV6aPuCnq4dC85cCBCDyY)QQWc4FvHA5cCBo7SRIns5w7b4bckhGxLEDWP(H2vfBy0g6vnLtV5gCiSBkh(yh96GtDMxcMFGukUbhc7MYHp21Hj)RQclG)vxKpRclGFMhy7Q8aB5xBORo4qy3uo8XNDGa6dWRsVo4u)q7QQWc4F1vbMUQydJ2qVAhAUvbMCYniClK5bTmF6zEuCOpZlbZ3xKO7wfyYzHayCgSgp1ZWpVuzjClZlfZd6RkKwWPSPlyYWhiOC2bs6oaVk96Gt9dTRk2WOn0RQOlTHrUKbVNlCc3U03JhSJEDWPoZlbZdQy(o0Cw7Q42SqnNfcGJh8vvHfW)Qw7Q42SqTZoqs4b4vPxhCQFODvXggTHEvvyb8DJfXuEgZvCRRRnkyI5LI5vHfW3HBxQ76AJcMUQkSa(xDSiMYZyUIBp7ajnhGxLEDWP(H2vfBy0g6vvHfW3HtgYuwOMRRnkyI5LI5vHfW3HBxQ76AJcMUQkSa(xfNmKPSqTZoqq)dWRQclG)vXTl1Vk96Gt9dTZo7QciK3Hj)dWdeuoaVQkSa(xDqlMwGVk96Gt9dTZoqa9b4vvHfW)QXl09vlG)vPxhCQFOD2bs6oaVQkSa(xLAKHjPnpGF)Q0Rdo1p0o7ajHhGxLEDWP(H2vfBy0g6vhiLIBGZXlCiYmFQumVPC6nx8cDF1c47OxhCQZ8sW8ciK3HjFx8cDF1c47wQrJhZ8sX8LaCRLxQrJhZ8PsX8GkM3uo9MlEHUVAb8D0Rdo1zEjyEbeY7WKVBqlMwGDl1OXJzEPy(saU1Yl1OXJVQkSa(xDvGOhIGZLLE0v6ZoqsZb4vPxhCQFODvXggTHE1onqkf3QatoezMxcMVtdKsXTHSdr(QQWc4FvTRYwaeLXj1T5Sde0)a8Q0Rdo1p0UQydJ2qVk90cwAxNkHimMxkMpnPH5tLI57qZTkWKBPYs4wDWjMpvkMVdn3gYULklHB1bNyEjyEbSzaZYW4nmZpZ8cyZaMLHXByxJIEz(uPyEaW8dKsXnW54foezMxcMFGukUbohVWTuJgpM5tpZJs6yEaEvvyb8VQfGPfNliR0NDGKwpaVk96Gt9dTRk2WOn0RoqkfNfGPfNliR0oezMxcMFGukUbohVW1HjFMxcMxaBgWSmmEdZ8PN5tiZlbZ3HMBvGjNCdc3czEqlZNEMhfh6Z8sW80tlyPzEPy(eM4vvHfW)Q4wTdt2q8(zhiG6dWRsVo4u)q7QInmAd9QdKsXzbyAX5cYkTdrM5tLI5hiLIBGZXlCiYxvfwa)RoOftlWXd(Sde0Xb4vPxhCQFODvXggTHE1bsP4g4C8chImZNkfZpqkf3GdHDoc2CiYxvfwa)RkdTa(NDGGsIhGxLEDWP(H2vvHfW)QcLZZQWc4N5b2UkpWw(1g6QegtVGo7abfuoaVk96Gt9dTRQclG)vvClq6t48QOlCZc4Q8Rk2WOn0RoqkfN8ctYDDyYN5LG5baZ3PbsP4wfDHBwaxLN70aPuCDyYN5tLI570aPuCc43rewaeLJh4CNgiLIdrM5LG5nDbtMZIgkBWSSWYPlrMp9mpkU0W8PsX8GkMVtdKsXjGFhrybquoEGZDAGukoezMxcMhamFNgiLIBv0fUzbCvEUtdKsXHnvamZl1mZd60W8PnZJsImFcW8DAGukUbhc7zyjBTuMEQrAhImZNkfZB6cMmNfnu2G5EqmF6z(eMiZdqMxcMFGukolatloxqwPDl1OXJzEPyEusK5b4vFTHUQIBbsFcNxfDHBwaxLF2bckG(a8Q0Rdo1p0UQydJ2qV6aPuCYlmj31HjFMxcMham)aPuCwaMwCUGSs7qKz(uPyEtxWK5SOHYgm3dI5tpZd6ezEaEvvyb8VkcMYHrn4Zo7Qdoe2nLdF8b4bckhGxLEDWP(H2vvHfW)QRcmDvXggTHEvaW8GkM3cbWXdM5tLI5baZVuzjCRo4eZlbZltloWg9wUbHBHmpOL5LI57qZTkWKtUbHBHmpOL5biZdqMxcMFGukUHLxfyY1HjFMxcMVVir3TkWKZcbW4mynEQNHFEPYs4wMxQzMh0xviTGtztxWKHpqq5SdeqFaEv61bN6hAxvfwa)R2aHFjwklu7QInmAd9Qlvwc3QdoX8sW8dKsXnSCde(LyjxhM8VQqAbNYMUGjdFGGYzhiP7a8Q0Rdo1p0UQkSa(x1Axf3MfQDvXggTHE1LklHB1bNyEjy(bsP4gw2Axf366WKpZlbZ3xKO7S2vXTzHAoleaJZG14PEg(5LklHBzEPyEq9vfsl4u20fmz4deuo7ajHhGxLEDWP(H2vfBy0g6vhiLIBy5XIykpJ5kU11Hj)RQclG)vhlIP8mMR42ZoqsZb4vPxhCQFODvXggTHE1bsP4gwgNmKjxhM8zEjyESmX5ztxWKHD4KHmLfQX8sX8OCvvyb8VkozitzHANDGG(hGxLEDWP(H2vfBy0g6vhiLIByzC7sDxhM8VQkSa(xf3Uu)SdK06b4vPxhCQFODvXggTHE1bsP4gwgNmKjxhM8VQkSa(xfNmKPSqTZoqa1hGxLEDWP(H2vfBy0g6vhiLIByzRDvCRRdt(xvfwa)RATRIBZc1o7SZUQIyTW9Q1Ob94SZUd]] )

    
end
