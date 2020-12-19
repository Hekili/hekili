-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID


-- Conduits
-- [x] carnivorous_instinct
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
        heart_of_the_wild = 18577, -- 319454

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
        strength_of_the_wild = 3053, -- 236019
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
        local tick_time = t.tick_time / haste
        local ttd = min( fight_remains, target.time_to_die )

        local aura = action
        if action == "primal_wrath" then aura = "rip" end
    
        local duration = class.auras[ aura ].duration * ( action == "primal_wrath" and 0.5 or 1 )
        local app_duration = min( ttd, class.abilities[ this_action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time
        
        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = max( 0, min( remains + duration, 1.3 * t.duration * 1, ttd ) )
        end
    
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time
    
        if action == "thrash_cat" then
            local fresh = max( 0, active_enemies - active_dot.thrash_cat )
            local dotted = max( 0, active_enemies - fresh )

            return fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks )
        elseif action == "primal_wrath" then
            local fresh = max( 0, active_enemies - active_dot.rip )
            local dotted = max( 0, active_enemies - fresh )

            return fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks )
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
            multiplier = 1.3,
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
            multiplier = function() return talent.moment_of_clarity.enabled and 1.15 or 1 end,
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
        primal_wrath = {
            id = 285381,
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
            multiplier = 1.6,
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
            multiplier = 1.15,
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
            multiplier = function() return 1.15 + state.conduit.carnivorous_instinct.mod * 0.01 end,
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


        any_form = {
            alias = { "bear_form", "cat_form", "moonkin_form" },
            duration = 3600,
            aliasMode = "first",
            aliasType = "buff",            
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

    local stealth_dropped = 0

    local function calculate_pmultiplier( spellID )
        local a = class.auras
        local tigers_fury = FindUnitBuffByID( "player", a.tigers_fury.id, "PLAYER" ) and a.tigers_fury.multiplier or 1
        local bloodtalons = FindUnitBuffByID( "player", a.bloodtalons.id, "PLAYER" ) and a.bloodtalons.multiplier or 1
        local clearcasting = FindUnitBuffByID( "player", a.clearcasting.id, "PLAYER" ) and a.clearcasting.multiplier or 1
        local prowling = ( GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", a.incarnation.id, "PLAYER" ) or FindUnitBuffByID( "player", a.berserk.id, "PLAYER" ) ) and a.prowl.multiplier or 1

        if spellID == a.rake.id then
            return 1 * tigers_fury * prowling

        elseif spellID == a.rip.id or spellID == a.primal_wrath.id then
            return 1 * bloodtalons * tigers_fury

        elseif spellID == a.thrash_cat.id then
            return 1 * tigers_fury * clearcasting

        elseif spellID == a.moonfire_cat.id then
            return 1 * tigers_fury

        end

        return 1
    end

    spec:RegisterStateExpr( "persistent_multiplier", function( act )
        local mult = 1

        act = act or this_action

        if not act then return mult end

        local a = class.auras
        if tf_spells[ act ] and buff.tigers_fury.up then mult = mult * a.tigers_fury.multiplier end
        if bt_spells[ act ] and buff.bloodtalons.up then mult = mult * a.bloodtalons.multiplier end
        if mc_spells[ act ] and buff.clearcasting.up then mult = mult * a.clearcasting.multiplier end
        if pr_spells[ act ] and ( effective_stealth or state.query_time - stealth_dropped < 0.2 ) then mult = mult * a.prowl.multiplier end

        return mult
    end )


    local snapshots = {
        [155722] = true,
        [1079]   = true,
        [285381] = true,
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
                    ns.saveDebuffModifier( spellID, calculate_pmultiplier( spellID ) )
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
        return eclipse.wrath_counter
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return eclipse.starfire_counter
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


    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandle( "wild_growth" ) end
    end, state )


    spec:RegisterHook( "reset_precast", function ()
        if buff.cat_form.down then
            energy.regen = 10 + ( stat.haste * 10 )
        end
        debuff.rip.pmultiplier = nil
        debuff.rake.pmultiplier = nil
        debuff.thrash_cat.pmultiplier = nil

        eclipse.reset() -- from Balance.

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

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end
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
            elseif k == "owlweave_cat" then
                return talent.balance_affinity.enabled and settings.owlweave_cat
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif debuff[ k ] ~= nil then return debuff[ k ]
            end
        end
    } ) )


    spec:RegisterStateExpr( "bleeding", function ()
        return debuff.rake.up or debuff.rip.up or debuff.thrash_cat.up or debuff.feral_frenzy.up
    end )

    spec:RegisterStateExpr( "effective_stealth", function () -- TODO: Test sudden_ambush soulbind conduit
        return buff.prowl.up or buff.berserk.up or buff.incarnation.up or buff.shadowmeld.up or buff.sudden_ambush.up
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

    local function calculate_damage( coefficient, masteryFlag, armorFlag, critChanceMult )
        local feralAura = 1.29
        local armor = armorFlag and 0.7 or 1
        local crit = min( ( 1 + state.stat.crit * 0.01 * ( critChanceMult or 1 ) ), 2 )
        local vers = 1 + state.stat.versatility_atk_mod
        local mastery = masteryFlag and ( 1 + state.stat.mastery_value * 0.01 ) or 1
        local tf = state.buff.tigers_fury.up and class.auras.tigers_fury.multiplier or 1
        local sr = state.buff.savage_roar.up and class.auras.savage_roar.multiplier or 1

        return coefficient * state.stat.attack_power * crit * vers * mastery * feralAura * armor * tf * sr
    end

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

            damage = function ()
                return calculate_damage( 0.69, false, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1 )
            end,

            max_targets = 5,

            -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
            cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

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

            pvptalent = "strength_of_the_wild",
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
            
            damage = function ()
                return calculate_damage( 0.075 * 5, true, true ) 
            end,
            tick_damage = function ()
                return calculate_damage( 0.15 * 5, true ) 
            end,
            tick_dmg = function ()
                return calculate_damage( 0.15 * 5, true ) 
            end,

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
            damage = function () -- TODO: Taste For Blood soulbind conduit
                return calculate_damage( 0.9828 * 2 , true, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1) * ( talent.sabertooth.enabled and 1.2 or 1 ) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 )
            end,
            -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
            cost = function () return max( 1, class.abilities.ferocious_bite.spend ) end,

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
            
            talent = "heart_of_the_wild",

            handler = function ()
                applyBuff( "heart_of_the_wild" )

                if talent.balance_affinity.enabled then
                    shift( "moonkin_form" )
                elseif talent.guardian_affinity.enabled then
                    shift( "bear_form" )
                elseif talent.restoration_affinity.enabled then
                    unshift()
                end
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

            damage = function ()
                return calculate_damage( 0.15 )
            end,
            tick_damage = function ()
                return calculate_damage( 0.15 )
            end,
            tick_dmg = function ()
                return calculate_damage( 0.15 )
            end,

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
                return calculate_damage( 0.18225, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 )
            end,
            tick_damage = function ()
                return calculate_damage( 0.15561, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 )
            end,
            tick_dmg = function ()
                return calculate_damage( 0.15561, true ) * ( effective_stealth and class.auras.prowl.multiplier or 1 )
            end,

            -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
            cost = function () return max( 1, class.abilities.rake.spend ) end,            

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

            tick_damage = function ()
                return calculate_damage( 0.14, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 )
            end,
            tick_dmg = function ()
                return calculate_damage( 0.14, true ) * ( buff.bloodtalons.up and class.auras.bloodtalons.multiplier or 1) * ( talent.soul_of_the_forest.enabled and 1.05 or 1 )
            end,

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

            damage = function ()
                return calculate_damage( 0.46, false, true, ( effective_stealth and 2 or 1 ) ) * ( effective_stealth and class.auras.prowl.multiplier or 1 ) * ( bleeding and 1.2 or 1 ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,

            -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
            cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

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


        --[[ starfire = {
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
        }, ]]


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
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end
                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
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

            damage = function ()
                return calculate_damage( 0.35, false, true ) * ( bleeding and 1.2 or 1 ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,

            max_targets = 5,

            -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
            cost = function () return max( 1, class.abilities.swipe_cat.spend ) end,            

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

            damage = function ()
                return calculate_damage( 0.055, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,
            tick_damage = function ()
                return calculate_damage( 0.035, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,
            tick_dmg = function ()
                return calculate_damage( 0.035, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,

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


        --[[ wrath = {
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
        }, ]]


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
                    shared = "player",
                },
                -- From Damager
                kindred_empowerment_partner = {
                    id = 327022,
                    duration = 10,
                    max_stack = 1,
                    dot = "buff",
                    shared = "player",
                },
                kindred_focus = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                    shared = "player",
                },
                kindred_focus_partner = {
                    id = 327071,
                    duration = 10,
                    max_stack = 1,
                    dot = "buff",                    
                    shared = "player",
                },
                -- Tank
                kindred_protection = {
                    id = 327037,
                    duration = 10,
                    max_stack = 1,
                    shared = "player",
                },
                kindred_protection_partner = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                    dot = "buff",
                    shared = "player",
                },
                kindred_spirits = {
                    id = 326967,
                    duration = 3600,
                    max_stack = 1,
                    shared = "player",
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

                kindred_empowerment_energize = {
                    alias = { "kindred_empowerment", "kindred_focus", "kindred_protection", "lone_empowerment" },
                    aliasMode = "first",
                    aliasType = "buff",
                    duration = 10,
                }
            }
        },

        empower_bond = {
            id = 326647,
            known = function () return covenant.kyrian and ( buff.lone_spirit.up or buff.kindred_spirits.up ) end,
            cast = 0,
            cooldown = function () return 60 * ( 1 - ( conduit.deep_allegiance.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = false,

            usable = function ()
                return buff.lone_spirit.up or buff.kindred_spirits.up, "requires kindred_spirits/lone_spirit"
            end,

            toggle = function () return role.tank and "defensives" or "essences" end,

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

            -- For Feral, we want to put Adaptive Swarm on the highest health enemy.
            indicator = function ()
                if state.spec.feral and target.time_to_die < longest_ttd then return "cycle" end
            end,

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

            disabled = function ()
                return covenant.night_fae and not IsSpellKnownOrOverridesKnown( 323764 ), "you have not finished your night_fae covenant intro"
            end,

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


    spec:RegisterSetting( "owlweave_cat", false, {
        name = "|T136036:0|t Attempt Owlweaving (Experimental)",
        desc = function()
            local affinity
            
            if state.talent.balance_affinity.enabled then
                affinity = "|cFF00FF00" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            else
                affinity = "|cFFFF0000" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            end

            return "If checked, the addon will swap to Moonkin Form based on the default priority.\n\nRequires " .. affinity .. "."
        end,
        type = "toggle",
        width = "full"
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 3,

        potion = "spectral_agility",

        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20201213, [[dW0gcbqiub9iLcDjLcWMuj9juLqJsPOtPuYQqf4vOsMLKQBrQuTlb)ckAyOICmjLLrQYZqfAAOI6AKQABKkX3ukiJJuPCouLK1rQK6DOkPsZdvPUNs1(ivCqLsfTqufpuPuPjQuG2Osb1hvkG6KOkPSsjXmvkv1njvsANQu9tuLGHsQKyPkLQ8ujMku4ROkPQXQuazVG(RqdgLdtzXk5XKmzvCzInlLpdLgTu50IwTsPcVwsA2iDBPQDd8BvnCs54OkPILR45iMovxhQ2UkLVJQA8kLY5rLA9OkrZxLy)qgwdIbSCmxG31Jt6XPA6vJJHA6PpN1NJWIZTMalAMQQHvGfG1lWYgwgJclAg303oqmGfYJpkbw6CxJORXetSP3HVcQVhts2JtnpFGASMJjj7vycll8K68Aa4cwoMlW76Xj94un9QXXqn90xpyHOjk49ACIJWsxEocaUGLJquWYgrSnSmgfX2GdEEqv2iITbfL0VKbXQXX6iMECspoHQGQSreB72zaScrxJQSret3rmEgC3OiwHAKoedteRWp1ee7GpjalIXJmezQIyyIy8AaLnaZZhGyzdXshXwI5eeR0nYbXowVHvqSn1gr31NZBfqv2iIP7i22tAJq6qmm6gJ0HyTFqmE9j9GyByQq6gbCsa2aQYgrmDhX2GpGx0rSr0MNpfXsaIP((L586IyENmcVibXapIP9jWdOkOkBeX2WYyueB7uxz7JykdGygL8i2sqS2JdoiM5iwN7AeDnMyInjEaB6D4RG67XCdKb4L2yyQl6gVsxu6gVIxPln9TMs0xj1QP)XmoACs3owRblAZ3sQalBeX2WYyueBdo45bvzJi2guus)sgeRghRJy6Xj94eQcQYgrSnSmgfX2o1v2(iMYaiMrjpITeeR94GdIzoI15UgrxJjMytIhWMEh(kO(Em3azaEPngM6IUXR0fLUXR4v6stFRPe9vsTA6FmJJgN0TJ1AOkOkMYZhqcAJO((L5CTJ5nBsBrL6aRx2Bp(O0IR0L63mkUSZjuLnIyLUroi2oIXP6i29hO7eGPr6EhX2EwvbX2rSA1rScW0iDVJyBpRQGy7iME1rSTpVgITJyCSoIv4NAcITJyCgvXuE(asqBe13VmNRDmVztAlQuhy9YElPuzQFZO4YoNqv2iIvugvqm(P3HyDgXLaQIP88bKG2iQVFzox7yEZM0wuPoW6L9j1IEQQsQFZO4Y(gcvXuE(asqBe13VmNRDmVztAlQuhy9YU3ngPl6PQkP(nJIl76gQIP88bKG2iQVFzox7yEZM0wuPoW6LDVBmsx0tvvs9Bgfx2RvpB7UrfGhw0)pUrFajiaBrLZLlQhCWtp4gXLy7N4I()jiaBrLdQIP88bKG2iQVFzox7ywnbNrorIwoPtqvmLNpGe0gr99lZ5AhZ17ovoXg14wo8ta2O)BlbOkMYZhqcAJO((L5CTJP288P1Z2(cV1c9)dQMGy7N(W55dqvmLNpGe0gr99lZ5AhtL5X2p91Z2(cV1c9)dQMGy7N(W55dqvqvmLNpGSp4GOP88brAs86aRx2xg1akPE22x4TwO)Fq1eeB)0hW1UYHNbppHNpLVy3KOYCuft55diCTJjPkoLgxgPdvXuE(acx7ysCBi4dwPE22x4TwOtSXJFl6DsKFspbCnuft55diCTJjbh0YrQNTDouBKBrSQtOwGGdA5iOkMYZhq4AhtpXkdj2WhURNT9fERfuMhB)0hopFaQIP88beU2XuzES9tF9STVWBTGY8y7N(W55dqv2iIPRmpFkIXVtaYnzqmTNqYfvqvmLNpGW1oMAZZNwpB7yNhx7YL1tiOkMYZhq4AhZoXgp(TO3jr(j9upB7cqgSCZBoZPRN3dJvvcJ0BjGOdNd6FDZZ7Hj1cJ0BjGOdNd6F5I67xFu7tGt4T(BDv9p988bbpXkdj2WhUdJ0BjGOZoNd6FDH3AbfvSrzepbyde3uv5DTRC4cV1cMMSTO2ihZ)HevJDlbyd4Ax5q1)0ZZheup42xvIENejA5KojGRD9m45j88P8f7MevMVxdvXuE(acx7y2)pOAcITF6RNTDbidwU5nN501Z7HXQkHr6Teq0HZb9VU559WKAHr6Teq0HZb9VCr99RpQ9jWj8w)TUQ(NEE(GGNyLHeB4d3Hr6Teq0zNZb9VUWBTGIk2OmINaSbIBQQ8U2voCH3Abtt2wuBKJ5)qIQXULaSbCTRCO6F655dcQhC7RkrVtIeTCsNeW1UEg88eE(u(IDtIkZ3RHQSreJxaiigP7DeJ4Ir9ouft55diCTJ5GdIMYZhePjXRdSEzN4Ir9U6zBFH3AbsNDE(9c9eW1UCzH3AbT55td4AOkMYZhq4AhtLrPrt55dI0K41bwVSR(NEE(auft55diCTJ5GdIMYZhePjXRdSEzVLGK0jt9STR((1h1(e4eD23uFD)MnPTOsO94JslUsx2cvzJiMUko1tDhR6GyexmQ3HQykpFaHRDmvgLgnLNpistIxhy9YoXfJ6D1Z2(cV1clsmbQaU2Lll8wlqWphbeT(foPlGRHQSredJobX6FIJyY20eajVjigpyGykUvubX2eJUriDiwPBKdIv4NAcIPEIJy1QPpIjazWYDDeR3QkigbFeeJVGykdGy9wvbX8oZrSeGyCgXWs)LrjBHQykpFaHRDm1(NghH84JsQNTD3OcWdl6)h3OpGeeGTOY56cV1cl6)h3OpGeopFW1nfGmy5Mlog0NdeGmy5omcwbW1MCMtCWcV1ckQyJYiEcWgW12AlEVzTA6R76XroyH3AHeOSbyE(Gy1eGn(TO3jXTdCawQeW126QP88MexE0Nelwzi7CcvXuE(acx7yo4GOP88brAs86aRx2x0)pUrFaPE22DJkapSO)FCJ(asqa2IkNRl8wlSO)FCJ(as488bOkMYZhq4AhZMmVkFCsCLUuxXTIkr3gSIt2RvpB7l8wlyAY2IAJCm)hsun2TeGnGRDDto0nQa8WI()Xn6dibbylQCUCzH3AHf9)JB0hqc4ABHQykpFaHRDmBYy0yBeaVK76zBx99RpQ9jWj8MJOkMYZhq4AhtT)PXrip(OK6TFIazB(Enuft55diCTJ5yvL6kUvuj62GvCYET6zBFZrAJq6SfvUCrtgssCb4XECQNA0ugDoVhgRQe06XPEQrtz266zWZtySQsWtvvseRLa5eFqCK2iKoDiAcLgDBWkojq4NAsuzohONURhQIP88beU2XS)FqlhjQmVUIBfvIUnyfNSxRE22hPncPZwu56zWZtO)Fqlhj4PQkjI1sGCIpiosBesNoenHsJUnyfNei8tnjQmNd0t31dvXuE(acx7yQ9pnoc5XhLuV9teiBZ3RHQykpFaHRDmxdUB0iHAKU6zBFZXYtuUjapyNdjKaD2Sgx922IQoBWkeDx1zdwHeBJP88bgDloyevNnyLON9Ywx3KOjuA0TbR4KWAWDJgjuJ0XbMYZhewdUB0iHAKUWX6nSYgGP88bH1G7gnsOgPlOEIVLoBAkpFqG0nYjCSEdRSbykpFqG0nYjOEIVfQIP88beU2XKWp1KOY86zBNOjuA0TbR4KaHFQjrL56uJRfERfwKycubCnoqpuft55diCTJjPBKt9STVWBTGIk2OmINaSbCnuft55diCTJ5yvL6kUvuj62GvCYET6zBFH3AHfjMavax76zWZtySQsWtvvseRLa5eFqCK2iKoD0dvXuE(acx7yQmknAkpFqKMeVoW6L9wsPYGQGQykpFajSO)FCJ(aY(yvL6kUvuj62GvCYET6zBFto0tv1eG9YLnhPncPZwu5QMmKK4cWJ94up1OPm6CEpmwvjO1Jt9uJMYS1wxx4Twy5XXQkHZZhC9m45jmwvj4PQkjI1sGCIpiosBesNo76HQykpFajSO)FCJ(acx7ysXb2etarlhZZhuxXTIkr3gSIt2RvpB7J0gH0zlQCDH3AHLh7)h0YrcNNpavXuE(asyr))4g9beU2X07gJ0fvMxxXTIkr3gSIt2RvpB7J0gH0zlQCDH3AHLh9UXiDHZZhC9m45j4DJr6IkZdEQQsIyTeiN4dIJ0gH0PJUHQykpFajSO)FCJ(acx7yUgC3Orc1iD1Z2(cV1clpUgC3Orc1iDHZZhGQykpFajSO)FCJ(acx7ys4NAsuzE9STVWBTWYJe(PMeopFWvIMqPr3gSItce(PMevMRtnuft55diHf9)JB0hq4Ahts3iN6zBFH3AHLhjDJCcNNpavXuE(asyr))4g9beU2XKWp1KOY86zBFH3AHLhj8tnjCE(auft55diHf9)JB0hq4AhtVBmsxuzE9STVWBTWYJE3yKUW55dqvqv2iIHbVWgKxqxJy3f5Gy(JyeUbkeJF6Dig)07qSXUjGhNGyTra8sUrm(DcaX4li2GdqS2iaEj3ldCQJy)GyMtfJ4iMQtuvrSSHyPtqm()4Diw6OkMYZhqcQ)PNNpyFjdrMQ1Z2U67xFu7tGt0zNJOkMYZhqcQ)PNNpGRDmtGYgG55dQNTD13V(O2NaNOZohrv2iIHXWnIzGdIbEhX4Bexqmm2WiMaKbl31rSfUJygL8i22boXrmCIGyPJyTFqmEPmvrmdCqSeOSbqqvmLNpGeu)tppFax7y6jwziXg(WD9STlazWYD4iTuLUo6R)Lll8wlSiXeOc4AxUSPBub4bTroM)tqa2IkNRKUFCH4r3p8MJBHQSretxnX25i2sqm(ZdWIy(Jy4ebXk9c9GypaX2EwvbXsaIDtgUrSBYWnIbsvNGyK0XnpFaPoITWDe7MmCJyJncLBuft55dib1)0ZZhW1oMKo7887f6PE22x4TwWtSYqIn8H7aU21fERfwKycuHZZhCv99RpQ9jWj8MZxpVhgRQe06XPEQrtz4DTGUCvaYGLBD4mNqvmLNpGeu)tppFax7yUKHit1eGTE22x4TwWtSYqIn8H7aU2Lll8wlSiXeOc4AOkMYZhqcQ)PNNpGRDm1EpFq9STVWBTWIetGkGRHQykpFajO(NEE(aU2XCSBc4XjX2iaEj31Z2(cV1clsmbQaU2LlTeBNhhP3saH36vdvzJigg8cBqEbDnITD7evveR)Fq1eGyDVZhXmWbXioERHy0SQGyExsQJyg4Gy9g3lbXwI7YGyQVFzoInsVLaeBec3afQIP88bKG6F655d4Aht1dU9vLO3jrIwoPtQNT9npVhMulmsVLaIoC(Q67xFu7tGt4nhVEEpmwvj4PQAcWU1LlTeBNhhP3saH36JQSretx14EjiM3jJGyKUhNEqSLGy9)iiM6bN0ZhqqShGyENGyQhCWthvXuE(asq9p988bCTJP0R98LjUEWPE22x4TwWtSYqIn8H7aU2LlBQEWbp9WreTOrPc20akjiaBrLZwOkMYZhqcQ)PNNpGRDmTJP55njs4BtFDf3kQeDBWkozVw9STR((1h1(e4KD9VYHN3d2X088Mej8TPpESEdRe8uvnbyrvmLNpGeu)tppFax7yItKy6spbvbvXuE(asOLuQm7JvvQR4wrLOBdwXj71QNT9B2K2IkHwsPYSx76iTriD2IkxpVhgRQe06XPEQrtz49UMmKK4cWJ94up1OPmOkMYZhqcTKsLHRDmhRQupB73SjTfvcTKsLzxpuft55diHwsPYW1oMuCGnXeq0YX88b1Z2(nBsBrLqlPuz25iQIP88bKqlPuz4Ahtc)utQNT9B2K2IkHwsPYSZzuft55diHwsPYW1oMKUroOkOkMYZhqcTeKKoz2j2ndReN3M6zBFH3AbIDZWkX5TjCE(Glxw4TwGy3mSsCEBcJ0BjGW7nvF)6JAFcCchOlCvBloGtboIQSretx1QkigbFeeZFeJxkZJyENGy3SjTfvqmYJyKVxqSNEqSBgfxqSZd4fDetahedxdXOjaRmjalQIP88bKqlbjPtgU2X8MnPTOsDG1l7lH4Xj1QFZO4YoNQNTD3OcWdAt2B0i)X8UGaSfvoOkBeXmLNpGeAjijDYW1oMkUv0eGnEZM0wuPoW6L9Lq84KA1FT9EBB1VzuCz)m45jmPwWtvvseRLa5eFqCK2iKU6zB3nQa8G2K9gnYFmVliaBrLdQIP88bKqlbjPtgU2XuBYEJg5pM3vpB7NbppbTj7nAK)yExWtvvseRLa5eFqCK2iKoDUztAlQeMul6PQk5YfIMqPr3gSItcAt2B0i)X8oD2KJCvJdCJkapqSLm()Exqa2IkNTqvmLNpGeAjijDYW1oMtQvxXTIkr3gSItQNT9rAJq6SfvUEg88eMul4PQkjI1sGCIpiosBesNo3SjTfvctQf9uvLCDZnx4TwWtSYqIn8H7aU2LlQ)PNNpi4jwziXg(WDyKElbeD0FRRBUWBTWI()Xn6dibCTlx4q3OcWdl6)h3OpGeeGTOYzRRN3dtQf06XPEQrtz49UMmKK4cWJ94up1OPmxUWHUrfGhi2sg)FVliaBrLZwOkMYZhqcTeKKoz4AhZMmVkFCsCLUuV32wuaYGL79A1vCROs0TbR4K9AOkOkBeX2EwvbXaICii284y7OCJy6ZPnae7Biw6eeJkaSEhIzoIziwFcYE8EeZFeJGpAgHGyKUroee7OjOkMYZhqcexmQ3Tp4GOP88brAs86aRx2x0)pUrFaPE22DJkapSO)FCJ(asqa2IkNRl8wlSO)FCJ(as488bOkMYZhqcexmQ3X1oMA)tJJqE8rj1B)ebY289AOkMYZhqcexmQ3X1oMJvvQR4wrLOBdwXj71QNT9npVhgRQe06XPEQrtz4DTG(xUmsBesNTOYwxpdEEcJvvcEQQsIyTeiN4dIJ0gH0PJEOkBeX4zWDJIyfQr6qSKGylXDzqmVZaigXfJ6DiwPBKdIzoIXreZTbR4euft55dibIlg174AhZ1G7gnsOgPRE22jAcLgDBWkojSgC3Orc1iD6OhQIP88bKaXfJ6DCTJP2)04iKhFus92prGSnFVgQYgrSs3iheR9dI1mIldITD1vqmScqgZZhGQykpFajqCXOEhx7ys6g5GQGQykpFajSmQbuYobh0YrQNT9fERfefn1isK8uBcNNp46cV1cIIMAejsXb2eopFW1nhPncPZwu5YLnnLN3KOaK(ui6u7QP88MepVhi4GwocVnLN3KOaK(uiBTfQIP88bKWYOgqjCTJjXTHGpyL6zBFH3AbrrtnIejp1MWi9wci6OmIh9SxUCzH3AbrrtnIeP4aBcJ0BjGOJYiE0ZEbvXuE(asyzudOeU2XK420YrQNT9fERfefn1isKIdSjmsVLaIokJ4rp7Llxip1MOOOPgr0HtOkMYZhqclJAaLW1oM8hZ7QNT9fERfefn1isK8uBcJ0BjGOJYiE0ZE5YfkoWMOOOPgr0HtWYnzi5dG31Jt6XPA6vJJWcFBajalbw41VDU9UZRDFdSUgXqmm6eel71(XrS2pigV4rAgo15frSr41bph5GyKVxqmd3)EZLdIP6mawHeqv2(jqqm90txJyB3hCtgxoiwj73UigHBGBBdX2aqm)rSTpUHyN8wsYhGyVMmM)dITjMBHyBQ322kGQGQWR1R9Jlhet3qmt55dqmAsCsavbwmCV7hyPK9BxyHMeNaXawAjLkded49AqmGfbylQCG8alMYZhalJvvGf1KUmPbl3SjTfvcTKsLbX2rSAi2veBK2iKoBrfe7kIDEpmwvjO1Jt9uJMYGy8EhX0KHKexaEShN6PgnLbwuCROs0TbR4e49AqhExpigWIaSfvoqEGf1KUmPbl3SjTfvcTKsLbX2rm9Gft55dGLXQkqhENJqmGfbylQCG8alQjDzsdwUztAlQeAjLkdITJyCewmLNpaw6)h0YrIkZHo8oNHyalcWwu5a5bwut6YKgSCZM0wuj0skvgeBhX4mSykpFaSq4NAsuzo0H31hIbSykpFaSq6g5alcWwu5a5b6qhwwg1akbIb8EnigWIaSfvoqEGf1KUmPbll8wlikAQrKi5P2eopFaIDfXw4Twqu0uJirkoWMW55dqSRi2Mi2iTriD2Iki2Lli2MiMP88MefG0NcbX0bXQHyxrmt55njEEpqWbTCeeJ3iMP88MefG0NcbX2cX2cwmLNpawi4Gwoc0H31dIbSiaBrLdKhyrnPltAWYcV1cIIMAejsEQnHr6TeqqmDqmLr8ON9cID5cITWBTGOOPgrIuCGnHr6TeqqmDqmLr8ON9cSykpFaSqCBi4dwb6W7CeIbSiaBrLdKhyrnPltAWYcV1cIIMAejsXb2egP3sabX0bXugXJE2li2Llig5P2effn1icIPdIXjyXuE(ayH420YrGo8oNHyalcWwu5a5bwut6YKgSSWBTGOOPgrIKNAtyKElbeethetzep6zVGyxUGyuCGnrrrtnIGy6GyCcwmLNpaw4pM3bDOdlhPz4uhIb8EnigWIaSfvoqEGf1KUmPbll8wl0)pOAcITF6d4Ai2veJdrSZGNNWZNYxSBsuzoSykpFaSm4GOP88brAsCyHMepcSEbwwg1akb6W76bXawmLNpawivXP04YiDWIaSfvoqEGo8ohHyalcWwu5a5bwut6YKgSSWBTqNyJh)w07Ki)KEc4AWIP88bWcXTHGpyfOdVZzigWIaSfvoqEGf1KUmPblCiIPnYTiw1julqWbTCeyXuE(ayHGdA5iqhExFigWIaSfvoqEGf1KUmPbll8wlOmp2(PpCE(ayXuE(ayXtSYqIn8HBOdVRlqmGfbylQCG8alQjDzsdww4TwqzES9tF488bWIP88bWIY8y7NEOdVVHGyalcWwu5a5bwut6YKgSGDECne7YfeB9ecSykpFaSOnpFk0H31nigWIaSfvoqEGf1KUmPblcqgSCJy8gX4mNqSRi259WyvLWi9wciiMoigNd6JyxrSnrSZ7Hj1cJ0BjGGy6GyCoOpID5cIP((1h1(e4eeJ3iM(i2wi2vet9p988bbpXkdj2WhUdJ0BjGGy6SJyCoOpIDfXw4TwqrfBugXta2aXnvveJ3iwne7kIXHi2cV1cMMSTO2ihZ)HevJDlbyd4Ai2veJdrm1)0ZZheup42xvIENejA5KojGRHyxrSZGNNWZNYxSBsuzoITJy1Gft55dGLoXgp(TO3jr(j9aD4DEfedyra2IkhipWIAsxM0GfbidwUrmEJyCMti2ve78EySQsyKElbeetheJZb9rSRi2Mi259WKAHr6TeqqmDqmoh0hXUCbXuF)6JAFcCcIXBetFeBle7kIP(NEE(GGNyLHeB4d3Hr6TeqqmD2rmoh0hXUIyl8wlOOInkJ4jaBG4MQkIXBeRgIDfX4qeBH3Abtt2wuBKJ5)qIQXULaSbCne7kIXHiM6F655dcQhC7RkrVtIeTCsNeW1qSRi2zWZt45t5l2njQmhX2rSAWIP88bWs))GQji2(Ph6W714eedyra2IkhipWIAsxM0GLfERfiD2553l0taxdXUCbXw4TwqBE(0aUgSykpFaSm4GOP88brAsCyHMepcSEbwiUyuVd6W71QbXaweGTOYbYdSykpFaSOmknAkpFqKMehwOjXJaRxGf1)0ZZhaD49A6bXaweGTOYbYdSOM0Ljnyr99RpQ9jWjiMo7i2MiM(iMUJy3SjTfvcThFuAXv6cITfSykpFaSm4GOP88brAsCyHMepcSEbwAjijDYaD49ACeIbSiaBrLdKhyrnPltAWYcV1clsmbQaUgID5cITWBTab)Ceq06x4KUaUgSykpFaSOmknAkpFqKMehwOjXJaRxGfIlg17Go8EnodXaweGTOYbYdSOM0LjnyXnQa8WI()Xn6dibbylQCqSRi2cV1cl6)h3OpGeopFaIDfX2eXeGmy5gX4cX4yqFeJdqmbidwUdJGvaigxi2MigN5eIXbi2cV1ckQyJYiEcWgW1qSTqSTqmEJyBIy1QPpIP7iMECeX4aeBH3AHeOSbyE(Gy1eGn(TO3jXTdCawQeW1qSTqSRiMP88MexE0Nelwzii2oIXjyXuE(ayr7FACeYJpkb6W710hIbSiaBrLdKhyrnPltAWIBub4Hf9)JB0hqccWwu5GyxrSfERfw0)pUrFajCE(ayXuE(ayzWbrt55dI0K4WcnjEey9cSSO)FCJ(ac0H3RPlqmGfbylQCG8alMYZhalnzEv(4K4kDbwut6YKgSSWBTGPjBlQnYX8Fir1y3sa2aUgIDfX2eX4qeZnQa8WI()Xn6dibbylQCqSlxqSfERfw0)pUrFajGRHyBblkUvuj62GvCc8EnOdVxBdbXaweGTOYbYdSOM0Ljnyr99RpQ9jWjigVrmoclMYZhalnzmASncGxYn0H3RPBqmGfbylQCG8alTFIazBo8EnyXuE(ayr7FACeYJpkb6W714vqmGfbylQCG8alMYZhalJvvGf1KUmPblBIyJ0gH0zlQGyxUGyAYqsIlap2Jt9uJMYGy6GyN3dJvvcA94up1OPmi2wi2ve7m45jmwvj4PQkjI1sGCIpiosBeshIPdIr0ekn62GvCsGWp1KOYCeJdqm9qmDhX0dwuCROs0TbR4e49AqhExpobXaweGTOYbYdSykpFaS0)pOLJevMdlQjDzsdwgPncPZwubXUIyNbppH()bTCKGNQQKiwlbYj(G4iTriDiMoigrtO0OBdwXjbc)utIkZrmoaX0dX0DetpyrXTIkr3gSItG3RbD4D9QbXaweGTOYbYdS0(jcKT5W71Gft55dGfT)PXrip(OeOdVRNEqmGfbylQCG8alQjDzsdw2eXglpr5Ma8GDoKqcqmDqSnrSAigxiwVTTOQZgScbX0Det1zdwHeBJP88bgfX2cX4aeBevNnyLON9cITfIDfX2eXiAcLgDBWkojSgC3Orc1iDighGyMYZhewdUB0iHAKUWX6nScIHjIzkpFqyn4UrJeQr6cQN4i2wiMoi2MiMP88bbs3iNWX6nScIHjIzkpFqG0nYjOEIJyBblMYZhalRb3nAKqnsh0H31JJqmGfbylQCG8alQjDzsdwiAcLgDBWkojq4NAsuzoIPdIvdX4cXw4TwyrIjqfW1qmoaX0dwmLNpawi8tnjQmh6W76XzigWIaSfvoqEGf1KUmPbll8wlOOInkJ4jaBaxdwmLNpawiDJCGo8UE6dXaweGTOYbYdSykpFaSmwvbwut6YKgSSWBTWIetGkGRHyxrSZGNNWyvLGNQQKiwlbYj(G4iTriDiMoiMEWIIBfvIUnyfNaVxd6W76PlqmGfbylQCG8alMYZhalkJsJMYZhePjXHfAs8iW6fyPLuQmqh6WI2iQVFzoed49AqmGfbylQCG8alVgSqehwmLNpawUztAlQal3mkUalCcwUztey9cS0E8rPfxPlqhExpigWIaSfvoqEGLxdwiIdlMYZhal3SjTfvGLBgfxGfobl3SjcSEbwAjLkd0H35iedyra2IkhipWYRbleXHft55dGLB2K2IkWYnJIlWYgcwUztey9cSmPw0tvvc0H35medyra2IkhipWYRbleXHft55dGLB2K2IkWYnJIlWIUbl3SjcSEbw8UXiDrpvvjqhExFigWIaSfvoqEGLxdwiIdlMYZhal3SjTfvGLBgfxGLAWIAsxM0Gf3OcWdl6)h3OpGeeGTOYbXUCbXup4GNEWnIlX2pXf9)tqa2Ikhy5MnrG1lWI3ngPl6PQkb6W76cedyXuE(ayPAcoJCIeTCsNalcWwu5a5b6W7BiigWIP88bWY6DNkNyJAClh(jaB0)TLayra2IkhipqhEx3GyalcWwu5a5bwut6YKgSSWBTq))GQji2(PpCE(ayXuE(ayrBE(uOdVZRGyalcWwu5a5bwut6YKgSSWBTq))GQji2(PpCE(ayXuE(ayrzES9tp0HoSSO)FCJ(aced49AqmGfbylQCG8alMYZhalJvvGf1KUmPblBIyCiI5PQAcWIyxUGyBIyJ0gH0zlQGyxrmnzijXfGh7XPEQrtzqmDqSZ7HXQkbTECQNA0ugeBleBle7kITWBTWYJJvvcNNpaXUIyNbppHXQkbpvvjrSwcKt8bXrAJq6qmD2rm9Gff3kQeDBWkobEVg0H31dIbSiaBrLdKhyXuE(ayP)FqlhjQmhwut6YKgSmsBesNTOcIDfXw4Twy5X()bTCKW55dGff3kQeDBWkobEVg0H35iedyra2IkhipWIP88bWI3ngPlQmhwut6YKgSmsBesNTOcIDfXw4Twy5rVBmsx488bi2ve7m45j4DJr6IkZdEQQsIyTeiN4dIJ0gH0Hy6Gy6gSO4wrLOBdwXjW71Go8oNHyalcWwu5a5bwut6YKgSSWBTWYJRb3nAKqnsx488bWIP88bWYAWDJgjuJ0bD4D9HyalcWwu5a5bwut6YKgSSWBTWYJe(PMeopFaIDfXiAcLgDBWkojq4NAsuzoIPdIvdwmLNpawi8tnjQmh6W76cedyra2IkhipWIAsxM0GLfERfwEK0nYjCE(ayXuE(ayH0nYb6W7BiigWIaSfvoqEGf1KUmPbll8wlS8iHFQjHZZhalMYZhale(PMevMdD4DDdIbSiaBrLdKhyrnPltAWYcV1clp6DJr6cNNpawmLNpaw8UXiDrL5qh6WcXfJ6DqmG3RbXaweGTOYbYdSOM0LjnyXnQa8WI()Xn6dibbylQCqSRi2cV1cl6)h3OpGeopFaSykpFaSm4GOP88brAsCyHMepcSEbww0)pUrFab6W76bXaweGTOYbYdS0(jcKT5W71Gft55dGfT)PXrip(OeOdVZrigWIaSfvoqEGft55dGLXQkWIAsxM0GLnrSZ7HXQkbTECQNA0ugeJ3iwTG(i2Lli2iTriD2Iki2wi2ve7m45jmwvj4PQkjI1sGCIpiosBeshIPdIPhSO4wrLOBdwXjW71Go8oNHyalcWwu5a5bwut6YKgSq0ekn62GvCsyn4UrJeQr6qmDqm9Gft55dGL1G7gnsOgPd6W76dXaweGTOYbYdS0(jcKT5W71Gft55dGfT)PXrip(OeOdVRlqmGft55dGfs3ihyra2Ikhipqh6WI6F655dGyaVxdIbSiaBrLdKhyrnPltAWI67xFu7tGtqmD2rmoclMYZhallziYuf6W76bXaweGTOYbYdSOM0Ljnyr99RpQ9jWjiMo7ighHft55dGLeOSbyE(aOdVZrigWIaSfvoqEGf1KUmPblcqgSChoslvPJy6Gy6RpID5cITWBTWIetGkGRHyxUGyBIyUrfGh0g5y(pbbylQCqSRigP7hxiE09dIXBeJJi2wWIP88bWINyLHeB4d3qhENZqmGfbylQCG8alQjDzsdww4TwWtSYqIn8H7aUgIDfXw4TwyrIjqfopFaIDfXuF)6JAFcCcIXBeJZi2ve78EySQsqRhN6PgnLbX4nIvlOli2vetaYGLBetheJZCcwmLNpawiD2553l0d0H31hIbSiaBrLdKhyrnPltAWYcV1cEIvgsSHpChW1qSlxqSfERfwKycubCnyXuE(ayzjdrMQjal0H31figWIaSfvoqEGf1KUmPbll8wlSiXeOc4AWIP88bWI275dGo8(gcIbSiaBrLdKhyrnPltAWYcV1clsmbQaUgID5cI1sSDECKElbeeJ3iME1Gft55dGLXUjGhNeBJa4LCdD4DDdIbSiaBrLdKhyrnPltAWYMi259WKAHr6TeqqmDqmoJyxrm13V(O2NaNGy8gX4iIDfXoVhgRQe8uvnbyrSTqSlxqSwITZJJ0BjGGy8gX0hwmLNpawup42xvIENejA5Kob6W78kigWIaSfvoqEGf1KUmPbll8wl4jwziXg(WDaxdXUCbX2eXup4GNE4iIw0OubBAaLeeGTOYbX2cwmLNpawKETNVmX1doqhEVgNGyalcWwu5a5bwmLNpawSJP55njs4BtpSOM0Ljnyr99RpQ9jWji2oIPpIDfX4qe78EWoMMN3KiHVn9XJ1ByLGNQQjalSO4wrLOBdwXjW71Go8ETAqmGft55dGfCIetx6jWIaSfvoqEGo0HLwcssNmqmG3RbXaweGTOYbYdSOM0LjnyzH3AbIDZWkX5TjCE(ae7YfeBH3AbIDZWkX5TjmsVLacIXBeBtet99RpQ9jWjighGy6cIXfIvdX2cX4aeJtboclMYZhale7MHvIZBd0H31dIbSiaBrLdKhy51GfI4WIP88bWYnBsBrfy5MrXfyHtWIAsxM0Gf3OcWdAt2B0i)X8UGaSfvoWYnBIaRxGLLq84KAqhENJqmGfbylQCG8alQjDzsdwodEEcAt2B0i)X8UGNQQKiwlbYj(G4iTriDiMoi2nBsBrLWKArpvvji2LligrtO0OBdwXjbTj7nAK)yEhIPdITjIXreJleRgIXbiMBub4bITKX)37ccWwu5GyBblMYZhalAt2B0i)X8oOdVZzigWIaSfvoqEGf1KUmPblJ0gH0zlQGyxrSZGNNWKAbpvvjrSwcKt8bXrAJq6qmDqSB2K2IkHj1IEQQsqSRi2Mi2Mi2cV1cEIvgsSHpChW1qSlxqm1)0ZZhe8eRmKydF4omsVLacIPdIPpITfIDfX2eXw4Twyr))4g9bKaUgID5cIXHiMBub4Hf9)JB0hqccWwu5GyBHyxrSZ7Hj1cA94up1OPmigV3rmnzijXfGh7XPEQrtzqSlxqmoeXCJkapqSLm()Exqa2IkheBlyXuE(ayzsnOdVRpedyra2IkhipWsVTTOaKbl3WsnyXuE(ayPjZRYhNexPlWIIBfvIUnyfNaVxd6qh6qh6qia]] )

    
end
