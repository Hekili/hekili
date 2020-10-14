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
            duration = max( 0, min( duration, 1.3 * t.duration, ttd ) )
        end
    
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time
    
        if action == "thrash_cat" then
            return max( 0, active_enemies - active_dot.thrash_cat ) * ( pmult and persistent_multiplier or 1 ) * app_ticks + active_dot.thrash_cat * ( remaining_ticks - potential_ticks )
        elseif action == "primal_wrath" then
            return max( 0, active_enemies - active_dot.rip ) * ( pmult and persistent_multiplier or 1 ) * app_ticks + active_dot.rip * ( remaining_ticks - potential_ticks )
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

    spec:RegisterPack( "Feral", 20201014, [[dKumdbqiIK4rIc5saPiBIi6taPqJcaDkayvej1RicZsrClrf1UOYVavgMOOJbOwgqYZevY0efCnrf2MOI8nrHY4asLZrKiRdiv18evQ7PO2hOQdsKKWcbLEirIQjsKK0gbsv(iqkOtcKsTsfPzcKs6MaPa7eu8tGuulLir5PsAQaYxbsj2Rk)vKbtvhM0Iv4XeMSuDzKnlXNbQrlfNwy1ejPEnqmBuUTuA3Q63qgorDCIKeTCLEoutNY1bz7a03fLgVOq15jsTEIeMVOQ9JQpGpGUAxn6GbuzcQmbotGZGdyqbmWzqkDvtAz6QYQaefmD1xBPRc6rRYUQSkndP9dORIrqRGUAJzYyqF4GdCynqdNa1choAHyQfOxSAXGdhTc4U6akygO9FJR2vJoyavMGktGZe4m4aguadCgYXvXYK4Gb4mZ1vBIEN(BC1oHfxnJ4EqpAvg3lvDHIoFAgX9GMfgAql3dCgMW9GktqLjFkFAgX9s5n6dMWG(8Pze3NZCpSlKPmUVYuCd3dh3xZgYe33H24bZ9WslMwq4E44Eq7xO7RwGEUpkCFyC)GudZ91ML6CFxBvWKJpnJ4(CM7LYOYs4gUhOMvXnCFbTCpOLG15EqpgHBw67Xd2Dv5fvcgD1mI7b9OvzCVu1fk68Pze3dAwyObTCpWzyc3dQmbvM8P8Pze3lL3Opycd6ZNMrCFoZ9WUqMY4(ktXnCpCCFnBitCFhAJhm3dlTyAbH7HJ7bTFHUVAb65(OW9HX9dsnm3xBwQZ9DTvbto(0mI7ZzUxkJklHB4EGAwf3W9f0Y9GwcwN7b9yeUzPVhpyhFkFQkSa9yN8scu7qnjMHdqDdDWOjV2sZfe0kKtJWOjaQmiAot(0mI7Rnl15(zUpZjCpmOpNXVkJBqg3lLPGqC)m3d8eUV(QmUbzCVuMccX9ZCpOMW9GwbT5(zUpxt4(A2qM4(zUpd8PQWc0JDYljqTd1Kygoa1n0bJM8AlnxcgJ2jaQmiAgy(uvyb6Xo5LeO2HAsmdhG6g6GrtETLMlbJr7eavgenN5KOmRsbTHrUSbRNkmc3S03JhSJEDWOoFQkSa9yN8scu7qnjMHdqDdDWOjV2sZBiNSqacEcGkdIMZy8PQWc0JDYljqTd1Kygoa1n0bJM8AlnBnRIBswiabpbqLbrZGo(uvyb6Xo5LeO2HAsmdhG6g6GrtETLMTMvXnjleGGNaOYGO5mNeLzvkOnmYLny9uHr4ML(E8GD0Rdg15tvHfOh7KxsGAhQjXmCGeFFPEclhByy(uvyb6Xo5LeO2HAsmdN8IYYMeL5buP4ArOhK4tf0266OSpFQkSa9yN8scu7qnjMHtOwQG22jrzEavkUwe6bj(ubTTUok7ZNYNQclqpEEH(KkSa9jwGTjV2sZdLPVGMeL5buP4ArOhK4tf026GK5tvHfOhlXmCyqGyS0qXn8PQWc0JLygoHAPcABNeL5buP4eQLkOT11rzF(uvyb6XsmdN8IYY4tZiUh08tCpUbzCp2iLznCFljA0peyU3uqiUxEd0gM08PQWc0JLygUf6tQWc0Nyb2M8AlnJnszwZKOmpGkfhUr7OSTeR7GKZNFavko5fLL5GK5tvHfOhlXmCcLXsQWc0Nyb2M8AlnlqiwhL95tvHfOhlXmCl0NuHfOpXcSn51wAUeFGBODsuMfO2bkjJI3WWpdWCKZaQBOdg5kiOviNgHraGpnJ4EqdGywKZGfDUhBKYSgUVJim3)iJpvfwGESeZWTqFsfwG(elW2KxBPzSrkZAMeL5buP4g4u8chKC(8dOsXHH6D6tA7ac34GK5tvHfOhlXmCc0dicekznuclhBy4jrz2ug9MBWqOUPm0JD0Rdg1LCavkUbdH6MYqp21rz)85LkMYO3Cdgc1nLHESJEDWOUKcu7aLKrXB4Cdk(0mI7bQH4(we24EkJltpoaK4EybI7fslye3dqGAwc3W91ML6CFnBitCVaHnUhyGZb3tpTGLEc33QGqCpgAjUplX9c95(wfeI7Tg14(45(mW9GzOHYWaGpvfwGESeZWjJqS0sye0kOjrz2ug9MBWqOUPm0JD0Rdg1LCavkUbdH6MYqp21rzFjbi90cwAjYLlhsn90cwA3sGPxcaMHmL6buP4emsxHIT4b7GKbaaGFgGadCoYzqLlPEavkU4f6(QfOpbs8GtOsYAOKun0dMroizaiPkSaqknSKTbyW0INZKpvfwGESeZWTqFsfwG(elW2KxBP5bdH6MYqpEsuMnLrV5gmeQBkd9yh96GrDjb4aQuCdgc1nLHESRJY(5ZRclaKsdlzBagmT4zqba(uvyb6Xsmd3QGqteslyuY0fmz4zGNeL5LklHB0bJYNxMwCGn6TuleZczwql8DK5wfeYj3cXSqMf0YNQclqpwIz4k0QSuzPxkKEsuMfO2bkjJI3WZzYNQclqpwIz4ArOVelLeQnriTGrjtxWKHNbEsuMxQSeUrhmIpvfwGESeZWznRIBsc1MeL5LklHB0bJKSVqr3znRIBsc1CwiabNaRXt9e6tlvwc3apG6g6GroRzvCtYcbiy(uvyb6Xsmd3yHmLLWmf3mjkZaCavkolatlovGwPDqYscWvJEIaKEZP9o2fp8aeyjA1mEs0OlycNZIgDbt4uzvHfOxzaqQxs0OlykzrlbaaijaXYeJLmDbtg2nwitzjmtXnsTkSa9UXczklHzkUX11wfmbAsfwGE3yHmLLWmf34eiSba4bOkSa9oCZsDxxBvWeOjvyb6D4ML6obcBaGpvfwGESeZWHZgYusO2KOmJLjglz6cMmSdNnKPKqn4bfFQkSa9yjMHd3SuFsuMhqLItWiDfk2IhSdsMpvfwGESeZWjuglPclqFIfyBYRT0CjymA5t5tvHfOh7gmeQBkd945vbHMiKwWOKPlyYWZapjkZauQyHaK4bNppaxQSeUrhmsszAXb2O3sTqmlKzbTW3rMBvqiNCleZczwqlaaGKdOsXnS0QGqUok7lzFHIUBvqiNfcqWjWA8upH(0sLLWnWpdk(uvyb6XUbdH6MYqpwIz4yqVUP4XYXQwG(jcPfmkz6cMm8mWtIY8sLLWn6GrsoGkf3WsTi0xILCDu2NpvfwGESBWqOUPm0JLygoRzvCtsO2eH0cgLmDbtgEg4jrzEPYs4gDWijhqLIByjRzvCJRJY(s2xOO7SMvXnjHAoleGGtG14PEc9PLklHBGh0XNQclqp2nyiu3ug6Xsmd3yHmLLWmf3mjkZdOsXnS0yHmLLWmf346OSpFQkSa9y3GHqDtzOhlXmC4SHmLeQnjkZdOsXnSeoBitUok7ljwMySKPlyYWoC2qMsc1Ghy(uvyb6XUbdH6MYqpwIz4Wnl1NeL5buP4gwc3Su31rzF(uvyb6XUbdH6MYqpwIz4WzdzkjuBsuMhqLIByjC2qMCDu2NpvfwGESBWqOUPm0JLygoRzvCtsO2KOmpGkf3WswZQ4gxhL95t5tvHfOh7eieRJY(ZdAX0ccFQkSa9yNaHyDu2xIz4IxO7RwGE(uvyb6XobcX6OSVeZWrTYOS0MgOVZNQclqp2jqiwhL9LygUvbKEeeovw6LcPNeL5buP4g4u8chKC(8MYO3CXl09vlqVJEDWOUKceI1rzFx8cDF1c07wQvJhdFja3yPLA14X5ZlvmLrV5IxO7RwGEh96GrDjfieRJY(UbTyAbXTuRgpg(saUXsl1QXJ5tvHfOh7eieRJY(smdN2vzlaKs4S62ojkZDAavkUvbHCqYs2PbuP42q2bjZNMrCpqR0CV(DU)rg3NvXgX9ab6X90tlyPNW9diJ7vggX9GrCFbTCVuqliCV(DUpEHUpFQkSa9yNaHyDu2xIz4SamT4ubALEsuMPNwWs76ujeHbFoYr(8aCavkUbofVWbjl5aQuCdCkEHBPwnECUboxaGpvfwGEStGqSok7lXmC4gTJY2sS(KOmpGkfNfGPfNkqR0oizjhqLIBGtXlCDu2xsbQDGsYO4nCUZGKDK5wfeYj3cXSqMf0MBGD5KK0tlyPHpdzYNQclqp2jqiwhL9LygUbTyAbjEWtIY8aQuCwaMwCQaTs7GKZNFavkUbofVWbjZNQclqp2jqiwhL9LygozKfOFsuMhqLIBGtXlCqY5ZpGkf3GHqDge2CqY8PQWc0JDceI1rzFjMHtOmwsfwG(elW2KxBPzcJPxq8PQWc0JDceI1rzFjMHdctPWO2jV2sZkUbq9jCAvPaTjbAv2KOmpGkfN8IYYCDu2xsa2PbuP4wvkqBsGwLL60aQuCDu2pF(onGkfNa9DiHfasP4bj1PbuP4GKL00fmzolAPKHsYclLRmZnWUCKpVuPtdOsXjqFhsybGukEqsDAavkoizjbyNgqLIBvPaTjbAvwQtdOsXHnvac8ZGkh5mWzk1DAavkUbdH6jujznuIEQvAhKC(8MUGjZzrlLmuQhuUZqMaqYbuP4SamT4ubAL2TuRgpgEGZea8PQWc0JDceI1rzFjMHdctPWOw8KOmpGkfN8IYYCDu2xsaoGkfNfGPfNkqR0oi585nDbtMZIwkzOupOCdQmbaFkFQkSa9yhHX0lOzRbTpEsuMvHfasj6P2GWW3jCSupz6cMmC(8Rg9ebi9Mt7DSlE4Zqo4tvHfOh7imMEbjXmCwdLG(bc67PcAf0KOmpGkf3scqyegNkOvqoi585hqLIZcW0ItfOvAhKmFQkSa9yhHX0lijMHRLArR0jujXGerp1xsBXtIY8aQuCdCkEHdsMpvfwGESJWy6fKeZWnyiupHkjRHs0tTspjkZdOsXzbyAXPc0kTdswsbQDGsYO4n8Co4tvHfOh7imMEbjXmCfKact9Kkf0ggLgK2ojkZQWcaPe9uBqy47eowQNmDbtgoFEaUA0teG0BoT3XU4HxkLPK0tlyPDDQeIWGFohzca(uvyb6XocJPxqsmdNm0gfPJhCAWuSnjkZQWcaPe9uBqy47eowQNmDbtgoF(vJEIaKEZP9o2fp85uM8PQWc0JDegtVGKygoWq62d9tOssLcArwZKOmpGkfNfGPfNkqR0oiz(uvyb6XocJPxqsmdNa9c6TvnQNkmTLMeL5buP4SamT4ubAL2bjZNQclqp2rym9csIz42qwMrP4tyzvqtIY8aQuCwaMwCQaTs7GK5tvHfOh7imMEbjXmCzrlRdifFAjm61xqtIY8aQuCwaMwCQaTs7GK5tvHfOh7imMEbjXmClPYXdovyAlHNiKwWOKPlyYWZapjkZMUGjZzrlLmuQhuUb2LJ85bianDbtMRHuM14Kfg8GUmZN30fmzUgszwJtwy5EguzcajnDbtMZIwkzOupi4bLuca5ZdqtxWK5SOLsgkjlSeOYe(CLPKMUGjZzrlLmuQhe8zidaGpLpvfwGESRemgTZRccnriTGrjtxWKHNbEsuMbu3qhmYvcgJ2zGLSJm3QGqo5wiMfYSG2CpltloWg9wQfIzHmlOLpvfwGESRemgTsmd3QGqtIYmG6g6GrUsWy0odk(uvyb6XUsWy0kXmCmOx3u8y5yvlq)KOmdOUHoyKRemgTZ5IpvfwGESRemgTsmdhoBittIYmG6g6GrUsWy0oNb(uvyb6XUsWy0kXmC4ML68P8PQWc0JDL4dCdTZyfqfmLwKUtIY8sLLWn6Gr8Pze3dAGccX9yOL4EdX9sbTiU3AiUhqDdDWiUhJ4EmQL4EeRZ9aQmiI77Oh0OX9035EizUNfpyAJhmFQkSa9yxj(a3qReZWbOUHoy0KxBP5bHT0gYtauzq0CMtIYSPm6nN8gTklLDvRXrVoyuNpnJ4Evyb6XUs8bUHwjMHtiTGfp4eG6g6GrtETLMhe2sBipbjp3Qz8jaQmiAUVqr3THSZcbi4eynEQNqFAPYs4Mjrz2ug9MtEJwLLYUQ14OxhmQZNQclqp2vIpWn0kXmCYB0QSu2vTMjrzUVqr3jVrRYszx1ACwiabNaRXt9e6tlvwc3apG6g6GrUnKtwiabNppwMySKPlyYWo5nAvwk7Qwd8amxsaSuBkJEZH1bTgczno61bJ6aGpvfwGESReFGBOvIz42qEIqAbJsMUGjdpd8KOmdqPIfcqIhC(8aCPwnESecu7aLKrXByP2ug9MdRdAneYAC0Rdg1bqU7qRAb6L6mD5kF(oYCBi7KBHywiZcAZTmT4aB0BPwiMfYSGwaizFHIUBdzNfcqWjWA8upH(0sLLWnWdOUHoyKBd5KfcqW8PQWc0JDL4dCdTsmdxRgTtIY8aQuCXI(KuTMf7GK5tvHfOh7kXh4gALygUcTirGGWPry0KwnJNONwWspd8eH0cgLmDbtgEgy(u(uvyb6XoSrkZAMxOpPclqFIfyBYRT08GHqDtzOhpjkZMYO3Cdgc1nLHESJEDWOUKdOsXnyiu3ug6XUok7ZNQclqp2HnszwJeZWTki0eH0cgLmDbtgEg4jrzUJm3QGqo5wiMfYSG2CdSlNKSVqr3TkiKZcbi4eynEQNqFAPYs4g4bfFQkSa9yh2iLznsmdN1SkUjjuBsuMvPG2Wix2G1tfgHBw67Xd2rVoyuxY(cfDN1SkUjjuZzHaeCcSgp1tOpTuzjCd8aQBOdg5SMvXnjleGG5tvHfOh7WgPmRrIz4glKPSeMP4MjrzwfwGE3yHmLLWmf346ARcMGxfwGEhUzPURRTkyIpvfwGESdBKYSgjMHdNnKPKqTjrzwfwGEhoBitjHAUU2QGj4vHfO3HBwQ76AlyIpvfwGESdBKYSgjMHd3SuNpLpvfwGESBOm9f0mg6lXstIY8aQuCKGfYykHrmDDDu2xYbuP4iblKXuIb9666OSVKaCPYs4gDWO85bOkSaqkrp1gegEGLufwaiL6iZHH(sSuUvHfasj6P2GWaaa8PQWc0JDdLPVGKygoSPlgAbttIY8aQuCKGfYykHrmDDl1QXJHxOylzrlLp)aQuCKGfYykXGEDDl1QXJHxOylzrlXNQclqp2nuM(csIz4WMULyPjrzEavkosWczmLyqVUULA14XWluSLSOLYNhJy6MiblKXe8zYNQclqp2nuM(csIz4YUQ1mjkZdOsXrcwiJPegX01TuRgpgEHITKfTu(8mOx3ejyHmMGpZRciT4a9hmGktqLjWzcCUCG6Qz19Jhm(QGwKQqkdgqByane0N75EGAiUpALrRX9f0Y9Gg7urHygOrUFjPkHIL6Cpg1sCVczOw1Oo3lA0hmHD8PGwJN4EGZjqFUxkh9asRrDUVgTs5Cpw630mo3dAI7ne3dAfs5(EayGd0Z9izAvdTCpaHdaCpabvghao(u(uq7wz0AuN7LsCVkSa9CplWg2XNEvwGn8b0vlbJr7b0bdWhqxLEDWO(b7vvHfO)QRccDvXggTHEva1n0bJCLGXOL7N5EG5Ej5(oYCRcc5KBHywiZcA5(CpZ9Y0IdSrVLAHywiZcAVQqAbJsMUGjdFWa8zhmG6a6Q0Rdg1pyVQydJ2qVkG6g6GrUsWy0Y9ZCpOUQkSa9xDvqOZoyY1b0vPxhmQFWEvXggTHEva1n0bJCLGXOL7N5(CDvvyb6VAlc9LyPKqTZoyYWb0vPxhmQFWEvXggTHEva1n0bJCLGXOL7N5(mCvvyb6VkoBitjHANDWKJdORQclq)vXnl1Vk96Gr9d2Zo7QL4dCdThqhmaFaDv61bJ6hSxvSHrBOxDPYs4gDWORQclq)vXkGkykTiDp7GbuhqxLEDWO(b7vrYxft2vvHfO)QaQBOdgDvavgeD1mVQydJ2qVQPm6nN8gTklLDvRXrVoyu)QaQB61w6QdcBPnKp7GjxhqxLEDWO(b7vfBy0g6v7lu0DYB0QSu2vTgNfcqWjWA8upH(0sLLWnCp8CpG6g6GrUnKtwiabZ95ZZ9yzIXsMUGjd7K3OvzPSRAnCp8Cpa5(CX9sW9aZ9sn3BkJEZH1bTgczno61bJ6CpaUQkSa9xvEJwLLYUQ1C2btgoGUk96Gr9d2RQclq)v3q(QInmAd9QaK7LkCVfcqIhm3Npp3dqUFPwnEm3lb3lqTdusgfVH5EPM7nLrV5W6GwdHSgh96GrDUhaCFU5(o0QwGEUxQ5(mD5I7ZNN77iZTHStUfIzHmlOL7Zn3ltloWg9wQfIzHmlOL7ba3lj33xOO72q2zHaeCcSgp1tOpTuzjCd3dp3dOUHoyKBd5KfcqWxviTGrjtxWKHpya(SdMCCaDv61bJ6hSxvSHrBOxDavkUyrFsQwZIDqYxvfwG(R2Qr7zhm50b0vPxhmQFWE1wnJNONwWsFvGVQkSa9xTqlseiiCAegDvH0cgLmDbtg(Gb4Zo7QegtVGoGoya(a6Q0Rdg1pyVQydJ2qVQkSaqkrp1geM7HN77eowQNmDbtgM7ZNN7xn6jcq6nN27yx8Cp8CFgYXvvHfO)QwdAF8zhmG6a6Q0Rdg1pyVQydJ2qV6aQuCljaHryCQGwb5GK5(855(buP4SamT4ubAL2bjFvvyb6VQ1qjOFGG(EQGwbD2btUoGUk96Gr9d2Rk2WOn0RoGkf3aNIx4GKVQkSa9xTLArR0jujXGerp1xsBXNDWKHdORsVoyu)G9QInmAd9QdOsXzbyAXPc0kTdsM7LK7fO2bkjJI3WC)m3NJRQclq)vhmeQNqLK1qj6PwPp7GjhhqxLEDWO(b7vfBy0g6vvHfasj6P2GWCp8CFNWXs9KPlyYWCF(8Cpa5(vJEIaKEZP9o2fp3dp3lLYK7LK7PNwWs76ujeHX9WpZ95itUhaxvfwG(Rwqcim1tQuqByuAqA7zhm50b0vPxhmQFWEvXggTHEvvybGuIEQnim3dp33jCSupz6cMmm3Npp3VA0teG0BoT3XU45E45(CkZRQclq)vLH2OiD8GtdMITZoyYyhqxLEDWO(b7vfBy0g6vhqLIZcW0ItfOvAhK8vvHfO)QGH0Th6NqLKkf0ISMZoyaDhqxLEDWO(b7vfBy0g6vhqLIZcW0ItfOvAhK8vvHfO)Qc0lO3w1OEQW0w6SdgP0b0vPxhmQFWEvXggTHE1buP4SamT4ubAL2bjFvvyb6V6gYYmkfFclRc6SdgGZ8a6Q0Rdg1pyVQydJ2qV6aQuCwaMwCQaTs7GKVQkSa9xnlAzDaP4tlHrV(c6SdgGb(a6Q0Rdg1pyVQkSa9xDjvoEWPctBj8vfBy0g6vnDbtMZIwkzOupiUp3CpWUCW95ZZ9aK7bi3B6cMmxdPmRXjlmUhEUh0Lj3Npp3B6cMmxdPmRXjlmUp3ZCpOYK7ba3lj3B6cMmNfTuYqPEqCp8CpOKsCpa4(855EaY9MUGjZzrlLmuswyjqLj3dp3NRm5Ej5EtxWK5SOLsgk1dI7HN7Zqg4EaCvH0cgLmDbtg(Gb4Zo7QdLPVGoGoya(a6Q0Rdg1pyVQydJ2qV6aQuCKGfYykHrmDDDu2N7LK7hqLIJeSqgtjg0RRRJY(CVKCpa5(LklHB0bJ4(855EaY9QWcaPe9uBqyUhEUhyUxsUxfwaiL6iZHH(sSe3NBUxfwaiLONAdcZ9aG7bWvvHfO)QyOVelD2bdOoGUk96Gr9d2Rk2WOn0RoGkfhjyHmMsyetx3sTA8yUhEUxOylzrlX95ZZ9dOsXrcwiJPed611TuRgpM7HN7fk2sw0sxvfwG(RInDXqly6SdMCDaDv61bJ6hSxvSHrBOxDavkosWczmLyqVUULA14XCp8CVqXwYIwI7ZNN7XiMUjsWczmX9WZ9zEvvyb6Vk20TelD2btgoGUk96Gr9d2Rk2WOn0RoGkfhjyHmMsyetx3sTA8yUhEUxOylzrlX95ZZ9mOx3ejyHmM4E45(mVQkSa9xn7QwZzND1ovuiMDaDWa8b0vPxhmQFWEvXggTHE1buP4ArOhK4tf026GKVQkSa9xDH(KkSa9jwGTRYcSLETLU6qz6lOZoya1b0vvHfO)QyqGyS0qXnxLEDWO(b7zhm56a6Q0Rdg1pyVQydJ2qV6aQuCc1sf0266OS)vvHfO)Qc1sf02E2btgoGUQkSa9xvErzzxLEDWO(b7zhm54a6Q0Rdg1pyVQydJ2qV6aQuC4gTJY2sSUdsM7ZNN7hqLItErzzoi5RQclq)vxOpPclqFIfy7QSaBPxBPRInszwZzhm50b0vPxhmQFWEvvyb6VQqzSKkSa9jwGTRYcSLETLUQaHyDu2)SdMm2b0vPxhmQFWEvXggTHEvbQDGsYO4nm3d)m3dqUphCFoZ9aQBOdg5kiOviNgHrCpaUQkSa9xDH(KkSa9jwGTRYcSLETLUAj(a3q7zhmGUdORsVoyu)G9QInmAd9QdOsXnWP4foizUpFEUFavkomuVtFsBhq4ghK8vvHfO)Ql0NuHfOpXcSDvwGT0RT0vXgPmR5SdgP0b0vPxhmQFWEvXggTHEvtz0BUbdH6MYqp2rVoyuN7LK7hqLIBWqOUPm0JDDu2N7ZNN7LkCVPm6n3GHqDtzOh7OxhmQZ9sY9cu7aLKrXByUp3CpOUQkSa9xvGEarGqjRHsy5yddF2bdWzEaDv61bJ6hSxvSHrBOx1ug9MBWqOUPm0JD0Rdg15Ej5(buP4gmeQBkd9yxhL95Ej5EaY90tlyP5Ej4(C5Yb3l1Cp90cwA3sGPN7LG7bi3NHm5EPM7hqLItWiDfk2IhSdsM7ba3daUh(zUhGCpWaNdUpN5EqLlUxQ5(buP4IxO7RwG(eiXdoHkjRHss1qpyg5GK5EaW9sY9QWcaP0Ws2gGbtlM7N5(mVQkSa9xvgHyPLWiOvqNDWamWhqxLEDWO(b7vfBy0g6vnLrV5gmeQBkd9yh96GrDUxsUhGC)aQuCdgc1nLHESRJY(CF(8CVkSaqknSKTbyW0I5(zUhuCpaUQkSa9xDH(KkSa9jwGTRYcSLETLU6GHqDtzOhF2bdWG6a6Q0Rdg1pyVQkSa9xDvqORk2WOn0RUuzjCJoye3Npp3ltloWg9wQfIzHmlOL7HN77iZTkiKtUfIzHmlO9QcPfmkz6cMm8bdWNDWaCUoGUk96Gr9d2Rk2WOn0RkqTdusgfVH5(zUpZRQclq)vl0QSuzPxkK(SdgGZWb0vPxhmQFWEvvyb6VAlc9LyPKqTRk2WOn0RUuzjCJoy0vfslyuY0fmz4dgGp7Gb4CCaDv61bJ6hSxvSHrBOxDPYs4gDWiUxsUVVqr3znRIBsc1CwiabNaRXt9e6tlvwc3W9WZ9aQBOdg5SMvXnjleGGVQkSa9x1Awf3KeQD2bdW50b0vPxhmQFWEvXggTHEvaY9dOsXzbyAXPc0kTdsM7LK7bi3VA0teG0BoT3XU45E45EaY9aZ9sW9TAgpjA0fmH5(CM7fn6cMWPYQclqVY4EaW9sn3VKOrxWuYIwI7ba3daUxsUhGCpwMySKPlyYWUXczklHzkUH7LAUxfwGE3yHmLLWmf346ARcM4E44Evyb6DJfYuwcZuCJtGWg3daUhEUhGCVkSa9oCZsDxxBvWe3dh3RclqVd3Su3jqyJ7bWvvHfO)QJfYuwcZuCZzhmaNXoGUk96Gr9d2Rk2WOn0RILjglz6cMmSdNnKPKqnUhEUhuxvfwG(RIZgYusO2zhmad6oGUk96Gr9d2Rk2WOn0RoGkfNGr6kuSfpyhK8vvHfO)Q4ML6NDWaSu6a6Q0Rdg1pyVQkSa9xvOmwsfwG(elW2vzb2sV2sxTemgTND2vLxsGAhQDaDWa8b0vPxhmQFWEvK8vXKDvvyb6VkG6g6GrxfqLbrxnZRcOUPxBPRwqqRqoncJo7GbuhqxLEDWO(b7vrYxft2vvHfO)QaQBOdgDvavgeDvGVkG6METLUAjymAp7GjxhqxLEDWO(b7vrYxft2vvHfO)QaQBOdgDvavgeD1mVQydJ2qVQkf0gg5YgSEQWiCZsFpEWo61bJ6xfqDtV2sxTemgTNDWKHdORsVoyu)G9Qi5RIj7QQWc0Fva1n0bJUkGkdIUAg7QaQB61w6QBiNSqac(SdMCCaDv61bJ6hSxfjFvmzxvfwG(RcOUHoy0vbuzq0vbDxfqDtV2sx1Awf3KSqac(SdMC6a6Q0Rdg1pyVks(QyYUQkSa9xfqDdDWORcOYGORM5vfBy0g6vvPG2Wix2G1tfgHBw67Xd2rVoyu)QaQB61w6QwZQ4MKfcqWNDWKXoGUQkSa9xfK47l1ty5yddFv61bJ6hSNDWa6oGUk96Gr9d2Rk2WOn0RoGkfxlc9GeFQG2wxhL9VQkSa9xvErzzNDWiLoGUk96Gr9d2Rk2WOn0RoGkfxlc9GeFQG2wxhL9VQkSa9xvOwQG22Zo7QyJuM1CaDWa8b0vPxhmQFWEvXggTHEvtz0BUbdH6MYqp2rVoyuN7LK7hqLIBWqOUPm0JDDu2)QQWc0F1f6tQWc0Nyb2UklWw61w6Qdgc1nLHE8zhmG6a6Q0Rdg1pyVQkSa9xDvqORk2WOn0R2rMBvqiNCleZczwql3NBUhyxoX9sY99fk6UvbHCwiabNaRXt9e6tlvwc3W9WZ9G6QcPfmkz6cMm8bdWNDWKRdORsVoyu)G9QInmAd9QQuqByKlBW6PcJWnl994b7OxhmQZ9sY99fk6oRzvCtsOMZcbi4eynEQNqFAPYs4gUhEUhqDdDWiN1SkUjzHae8vvHfO)QwZQ4MKqTZoyYWb0vPxhmQFWEvXggTHEvvyb6DJfYuwcZuCJRRTkyI7HN7vHfO3HBwQ76ARcMUQkSa9xDSqMYsyMIBo7GjhhqxLEDWO(b7vfBy0g6vvHfO3HZgYusOMRRTkyI7HN7vHfO3HBwQ76Aly6QQWc0FvC2qMsc1o7GjNoGUQkSa9xf3Su)Q0Rdg1pyp7SRkqiwhL9pGoya(a6QQWc0F1bTyAb5Q0Rdg1pyp7GbuhqxvfwG(RgVq3xTa9xLEDWO(b7zhm56a6QQWc0FvQvgLL20a99RsVoyu)G9SdMmCaDv61bJ6hSxvSHrBOxDavkUbofVWbjZ95ZZ9MYO3CXl09vlqVJEDWOo3lj3lqiwhL9DXl09vlqVBPwnEm3dp3xcWnwAPwnEm3Npp3lv4Etz0BU4f6(QfO3rVoyuN7LK7fieRJY(UbTyAbXTuRgpM7HN7lb4glTuRgp(QQWc0F1vbKEeeovw6LcPp7GjhhqxLEDWO(b7vfBy0g6v70aQuCRcc5GK5Ej5(onGkf3gYoi5RQclq)v1UkBbGucNv32ZoyYPdORsVoyu)G9QInmAd9Q0tlyPDDQeIW4E45(CKdUpFEUhGC)aQuCdCkEHdsM7LK7hqLIBGtXlCl1QXJ5(CZ9aNlUhaxvfwG(RAbyAXPc0k9zhmzSdORsVoyu)G9QInmAd9QdOsXzbyAXPc0kTdsM7LK7hqLIBGtXlCDu2N7LK7fO2bkjJI3WCFU5(mW9sY9DK5wfeYj3cXSqMf0Y95M7b2LtCVKCp90cwAUhEUpdzEvvyb6VkUr7OSTeRF2bdO7a6Q0Rdg1pyVQydJ2qV6aQuCwaMwCQaTs7GK5(855(buP4g4u8chK8vvHfO)QdAX0cs8Gp7GrkDaDv61bJ6hSxvSHrBOxDavkUbofVWbjZ95ZZ9dOsXnyiuNbHnhK8vvHfO)QYilq)zhmaN5b0vPxhmQFWEvvyb6VQqzSKkSa9jwGTRYcSLETLUkHX0lOZoyag4dORsVoyu)G9QQWc0Fvf3aO(eoTQuG2KaTk7QInmAd9QdOsXjVOSmxhL95Ej5EaY9DAavkUvLc0MeOvzPonGkfxhL95(855(onGkfNa9DiHfasP4bj1PbuP4GK5Ej5EtxWK5SOLsgkjlSuUYK7Zn3dSlhCF(8CVuH770aQuCc03HewaiLIhKuNgqLIdsM7LK7bi33PbuP4wvkqBsGwLL60aQuCytfGW9WpZ9GkhCFoZ9aNj3l1CFNgqLIBWqOEcvswdLONAL2bjZ95ZZ9MUGjZzrlLmuQhe3NBUpdzY9aG7LK7hqLIZcW0ItfOvA3sTA8yUhEUh4m5EaC1xBPRQ4ga1NWPvLc0MeOvzNDWamOoGUk96Gr9d2Rk2WOn0RoGkfN8IYYCDu2N7LK7bi3pGkfNfGPfNkqR0oizUpFEU30fmzolAPKHs9G4(CZ9GktUhaxvfwG(RcHPuyul(SZU6GHqDtzOhFaDWa8b0vPxhmQFWEvvyb6V6QGqxvSHrBOxfGCVuH7Tqas8G5(855EaY9lvwc3OdgX9sY9Y0IdSrVLAHywiZcA5E45(oYCRcc5KBHywiZcA5EaW9aG7LK7hqLIByPvbHCDu2N7LK77lu0DRcc5SqacobwJN6j0NwQSeUH7HFM7b1vfslyuY0fmz4dgGp7GbuhqxLEDWO(b7vvHfO)QTi0xILsc1UQydJ2qV6sLLWn6GrCVKC)aQuCdl1IqFjwY1rz)RkKwWOKPlyYWhmaF2btUoGUk96Gr9d2RQclq)vTMvXnjHAxvSHrBOxDPYs4gDWiUxsUFavkUHLSMvXnUok7Z9sY99fk6oRzvCtsOMZcbi4eynEQNqFAPYs4gUhEUh0DvH0cgLmDbtg(Gb4ZoyYWb0vPxhmQFWEvXggTHE1buP4gwASqMYsyMIBCDu2)QQWc0F1XczklHzkU5SdMCCaDv61bJ6hSxvSHrBOxDavkUHLWzdzY1rzFUxsUhltmwY0fmzyhoBitjHACp8CpWxvfwG(RIZgYusO2zhm50b0vPxhmQFWEvXggTHE1buP4gwc3Su31rz)RQclq)vXnl1p7GjJDaDv61bJ6hSxvSHrBOxDavkUHLWzdzY1rz)RQclq)vXzdzkju7Sdgq3b0vPxhmQFWEvXggTHE1buP4gwYAwf346OS)vvHfO)QwZQ4MKqTZo7SRQqwdAVAnALYp7S7a]] )

    
end
