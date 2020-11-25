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
        local ttd = min( fight_remains, target.time_to_die )
    
        local duration = t.duration * ( action == "primal_wrath" and 0.5 or 1 )
        local app_duration = min( ttd, class.abilities[ this_action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time
        
        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = action ~= "primal_wrath" and max( 0, min( duration, 1.3 * t.duration * 1, ttd ) ) or duration
        end
    
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time
    
        Hekili:Debug( "%s %.2f %.2f %.2f %.2f", action, remains, app_duration, app_ticks, potential_ticks )

        if action == "thrash_cat" then
            return max( 0, active_enemies - active_dot.thrash_cat ) * app_ticks + min( active_enemies, active_dot.thrash_cat ) * ( potential_ticks - remaining_ticks )
        elseif action == "primal_wrath" then
            return max( 0, active_enemies - active_dot.rip ) * app_ticks + min( active_enemies, active_dot.rip ) * ( potential_ticks - remaining_ticks )
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
                return calculate_damage( 0.175, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
            end,
            tick_dmg = function ()
                return calculate_damage( 0.175, true ) * ( buff.clearcasting.up and class.auras.clearcasting.multiplier or 1)
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
            texture = 3528283,

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

    spec:RegisterPack( "Feral", 20201123.1, [[dWeaibqicbEKQQ4sQksTjc4tek0OKQ0PKQyvQkQxrqMLQKBrOk7Iu)cKAyckhtvQLPQWZienncvUMQQABec9ncbnocfDobvzDek4DeQkzEekDpvX(iOoOGk0cjqpuvr0ejuv1gfurFKqvPoPGQQvkPAMQkc3KqvHDQQ0pvvKOHQQiPLkOQ8uPmvvv(QGkySeQkAVa)vObtYHPSyf9yIMScxg1ML4ZGy0sLtlA1eQQ8AqYSr62sYUv53qgUahxvrclxPNd10P66GA7sv9Dbz8cQ05jKwVQQ08Lu2pIbVb)aTH5m47hH9ryVF)Hi1V))97perqZfnGbTatcLbHbTZQyqlCYRrbTatukYgGFGggbVsg06CpalgGgAiP3bp1suf04ScMAEIo5AfhACwjHg0MWj1d)hycAdZzW3pc7JWE)(drQF))73F8pOHdyj477WejO1LJbFGjOnySe0(drfo51OeL4)cNds9)quFr95QjVe1hI8fr9ryFegPoP(FiQpzNDqySyGu)peL4rucUWUrjQg1WDef0evlugWe1aEZdcrjiVyEHIOGMOc)N02Z8eDevwiQ0jQjBoMOADlpiQHvzqyIQ3GLfV)fxpAs9)quIhrf(4YY4oI6x3A4oIQGwIkCiPdIkCszC3Y3ipiAs9)quIhrj(JoXOtulhSOquIkpIsIQMMl(IO8oEzXiMOoerfGYZ1K6K6)HOcN8AuIkC8t9tqus7ikJIre1KjQcc(geL5evN7byXa0qdjXUgs6DWtTevbT4t7(RTg0IOygEIOumdVWtel)Bfj)VKF)()HzI0ctmhwPaAblQKug0(drfo51OeL4)cNds9)quFr95QjVe1hI8fr9ryFegPoP(FiQpzNDqySyGu)peL4rucUWUrjQg1WDef0evlugWe1aEZdcrjiVyEHIOGMOc)N02Z8eDevwiQ0jQjBoMOADlpiQHvzqyIQ3GLfV)fxpAs9)quIhrf(4YY4oI6x3A4oIQGwIkCiPdIkCszC3Y3ipiAs9)quIhrj(JoXOtulhSOquIkpIsIQMMl(IO8oEzXiMOoerfGYZ1K6K6)HOcN8AuIkC8t9tqus7ikJIre1KjQcc(geL5evN7byXa0qdjXUgs6DWtTevbT4t7(RTg0IOygEIOumdVWtel)Bfj)VKF)()HzI0ctmhwPqQtQBsprhwhSSevnnxOhO7BBAtk)6Sk(PGGxzqCMo)QVrH5NWi1)dr16wEqupevyViQVOt8WNfG7qorf(mOyI6HOE)IOANfG7qorf(mOyI6HO(4fr9jc)e1drjYxevlugWe1drjosDt6j6W6GLLOQP5c9aDFBtBs5xNvXpLKs59vFJcZpVj1nPNOdRdwwIQMMl0d09TnTjLFDwf)uskL3x9nkm)e2RS8y)L30zDOKoIfkJ7w(g5brZNnP8Gu)pevtAuMOcLEhr1zyN1K6M0t0H1bllrvtZf6b6(2M2KYVoRIF2mi6Pek8R(gfMFeHF6od7mPUj9eDyDWYsu10CHEGUVTPnP8RZQ4hVBnCx0tju4x9nkm)iMK6M0t0H1bllrvtZf6b6(2M2KYVoRIF8U1WDrpLqHF13OW8tyVYYJ9xEtN1Hs6iwOmUB5BKhenF2KYdsDt6j6W6GLLOQP5c9anu5nwEeXb5MoMu3KEIoSoyzjQAAUqpqhSOq0xz5zcxk6ke6GkVybTv6bk0rQBsprhwhSSevnnxOhOLMhlOT6vwEMWLIUcHoOYlwqBLEGcDK6K6M0t0HFw4lAsprxKMy)1zv8Z0O2j5xz5zcxk6ke6GkVybTvA4asDt6j6Wc9angkyknonChP(FikbnQDsMOcXw)8Gqu51NXEcX8eDK6M0t0HFKMhlOT6vwEMWLIwAESG2k9af6i1)dr9PUOquIkuhFCFEjQaegNtktQ)hIYKEIoSqpqhSOqus9)quFkpMOWDiNOWoBuVJu3KEIoSqpqVWx0KEIUinX(RZQ4hSZg17ELLNjCPOXD2afQIPdnCqTAt4srhSOqunCaPUj9eDyHEGwAuA0KEIUinX(RZQ4hjcrhOqhPUj9eDyHEGEHVOj9eDrAI9xNvXpL8sChVVYYJevnrXauEow4NE)x86BBAtkRli4vgeNPZ9qQ)hIs8bm1tXdICquyNnQ3rQBsprhwOhOx4lAsprxKMy)1zv8d2zJ6DVYYZeUu0tCmpPgoOwTjCPOXWJbFrRAcJ70WbK6M0t0Hf6bAj66JGIJEhhXb5Mo(vwECJYNRNueA4gfDynF2KYdbMWLIEsrOHBu0H1duORwnrGBu(C9KIqd3OOdR5ZMuEiGevnrXauEowSFqQ)hI6xhtuviStuC4gWho7ZeLG)ikPOsktu9(RBzChr16wEquTqzatuse2jQ3V)NO4JxiI(IOQmOyIcdVmrfIjkPDevLbftuEN5evEeL4ikiu00O4Ei1nPNOdl0d0bienUmgbVs(vwECJYNRNueA4gfDynF2KYdbMWLIEsrOHBu0H1duOtGE5JxiIkKi1))z(4fIO6LHWNq9kUW(8eUu0skBR0WEEq0Wb90Jy7997)fVpe5NNWLIopPTN5j6IqLhKiQe9ook(bFqOSgoOhbmPN9540J(MqGWl(jmsDt6j6Wc9a9cFrt6j6I0e7VoRIFMueA4gfD4xz5XnkFUEsrOHBu0H18ztkpeO3jCPONueA4gfDy9af6QvZKE2NJtp6BcbcV4Np6Hu3KEIoSqpqhGq04Yye8k5xf0gpoC9N3K6M0t0Hf6b61GIFjfvs5OBle2XpVFLLNLllJ7SjLRvlGxCID(8yfm1ZaAYRWdKRxdkwhubt9mGM8sQBsprhwOhOl8A0yz57VI(klpsu1efdq554NWi1nPNOdl0d0vi0vYLJsZFjfvs5OBle2XpVFLLNLllJ7SjLj1nPNOdl0d0bienUmgbVs(vbTXJdx)5nPUj9eDyHEG27wd3fLM)klplxwg3ztklWyHZH27wd3fLMR9ucfocXYJhr0fxUSmUt4(2M2KYAVBnCx0tjuysDt6j6Wc9a9CHDJgXud39klp9oHlfTNq4fhlWROA4ab6DTCe5(85ABmW68eU33cvzHBu2zleglEYoBHW4yznPNOZO985LLD2cHJEwX90Ja9Idykn62cHDSEUWUrJyQH7(Sj9eD65c7gnIPgUtpSkdc)PnPNOtpxy3Orm1WDAjc79iCVM0t0PXDlp0dRYGWFAt6j604ULhAjc79qQBsprhwOhOXHYaokn)vwEWbmLgDBHWowJdLbCuAUWFqQBsprhwOhOXDlpELLNjCPOLu2wPH98GOHdi1nPNOdl0d0sJsJM0t0fPj2FDwf)uskLxsDsDt6j6W6jfHgUrrh(znO4xsrLuo62cHD8Z7xz5PxrGNsOYdsTA9UCzzCNnPSab8ItSZNhRGPEgqtEfEGC9AqX6GkyQNb0K3E6rGjCPONECnOy9af6eySW5qVguS2tju4ielpEerxC5YY4oHF(Gu3KEIoSEsrOHBu0Hf6bAk8zBmpCqUMNO7LuujLJUTqyh)8(vwEwUSmUZMuwGjCPONEScHUsUSEGcDK6M0t0H1tkcnCJIoSqpq7DRH7IsZFjfvs5OBle2XpVFLLNLllJ7SjLfycxk6Ph9U1WD6bk0jWyHZH27wd3fLMR9ucfocXYJhr0fxUSmUtyXKu3KEIoSEsrOHBu0Hf6b65c7gnIPgU7vwEMWLIE6X5c7gnIPgUtpqHosDt6j6W6jfHgUrrhwOhOXHYaokn)vwEMWLIE6rCOmG1duOtaCatPr3wiSJ14qzahLMl8BsDt6j6W6jfHgUrrhwOhOXDlpELLNjCPONEe3T8qpqHosDt6j6W6jfHgUrrhwOhOXHYaokn)vwEMWLIE6rCOmG1duOJu3KEIoSEsrOHBu0Hf6bAVBnCxuA(RS8mHlf90JE3A4o9af6i1j1nPNOdRLieDGcDptEX8cfPUj9eDyTeHOduOtOhOZtA7zEIosDt6j6WAjcrhOqNqpqZvbOq8gNOBqQBsprhwlri6af6e6b616ZhcghllF)v0xz5zcxk6joMNudhuRMBu(CDEsBpZt0P5ZMuEiGeHOduOtNN02Z8eD6LRS8WcxsiDEC5klpCTAIa3O8568K2EMNOtZNnP8qajcrhOqNEYlMxO0lxz5HfUKq684YvwEysDt6j6WAjcrhOqNqpqBdlWZ(CehY2Qxz5zWt4srVguSgoqGbpHlf9MbA4as9)qu)wrjk7ge1HCIkKHDMO(fojk(4fIOViQjStugfJikiiIQGwI6V8cfrz3GOYtA7rQBsprhwlri6af6e6bApHWlowGxrFLLh(4fIO6bxsz6c)))1QnqUEnOy9YLLXD2KY1QnqUEZa9YLLXD2KYcirvtumaLNJFKOQjkgGYZX6klCRvR3jCPON4yEsnCGat4srpXX8K6LRS8WI9Ti7Hu3KEIoSwIq0bk0j0d04oBGcvX0XRS8mHlfTNq4fhlWROA4abMWLIEIJ5j1duOtajQAIIbO8CSyfNadKRxdkwhubt9mGM8k23Arua(4fIOclUWi1nPNOdRLieDGcDc9a9KxmVqLhKxz5zcxkApHWlowGxr1Wb1QnHlf9ehZtQHdi1nPNOdRLieDGcDc9aDaYt09klpt4srpXX8KA4GA1MWLIEsrObfg7A4asDt6j6WAjcrhOqNqpqlnknAsprxKMy)1zv8dJX8jzsDt6j6WAjcrhOqNqpqdJ5y6C1RZQ4hd313oghx7VOnkrRrFLLNjCPOdwuiQEGcDc07GNWLIET)I2OeTgno4jCPOhOqxTAdEcxkAj6gWsp7ZX8Gko4jCPOHdeWTfc7ApR4OJIbspkYWe7B9)1Qjcg8eUu0s0nGLE2NJ5bvCWt4srdhiqVdEcxk61(lAJs0A04GNWLIg7MekHF(4FX7DyFEWt4srpPi0iIkrVJJ8XvIQHdQvZTfc7ApR4OJIJKfR4cRhbMWLI2ti8IJf4vu9YvwEyHFhwpK6M0t0H1seIoqHoHEGggZX05k8RS8mHlfDWIcr1duOtGENWLI2ti8IJf4vunCqTAUTqyx7zfhDuCKSy)iSEi1j1nPNOdRzmMpj)4DO9WVYYJj9Sph5JRsgl8GX5YJOBle2X1QTwoICF(CTngyDEclU)j1nPNOdRzmMpjl0d0EhhHVjc(gXcAL8RS8mHlf9YsOOmghlOvYA4GA1MWLI2ti8IJf4vunCaPUj9eDynJX8jzHEGUIRqROrujsHL5iow2QWVYYZeUu0tCmpPgoGu3KEIoSMXy(KSqpqpPi0iIkrVJJ8XvI(klpt4sr7jeEXXc8kQgoqajQAIIbO8C8Z)K6M0t0H1mgZNKf6b6cscJ5r0(lVPZXjBvVYYJj9Sph5JRsgl8GX5YJOBle2X1Q17A5iY95Z12yG15jC4fMa8Xler1dUKY0f(5)W6Hu3KEIoSMXy(KSqpqhaVzr08GeNud7VYYJj9Sph5JRsgl8GX5YJOBle2X1QTwoICF(CTngyDEclIHrQBsprhwZymFswOhOHaB7iTlIkr7V8I8Uxz5zcxkApHWlowGxr1WbK6M0t0H1mgZNKf6bAj6K85R58iwOwf)klpt4sr7jeEXXc8kQgoGu3KEIoSMXy(KSqpqVzqaLJ5fXbMKFLLNjCPO9ecV4ybEfvdhqQBsprhwZymFswOhOdHw6OpNxCzm6StYVYYZeUu0EcHxCSaVIQHdi1nPNOdRzmMpjl0d0lBb5bjwOwfJFjfvs5OBle2XpVFLLh3wiSR9SIJokoswSV1)xRwV962cHDDhBuVthiDHfZWQvZTfc76o2OENoq6I95JW6ra3wiSR9SIJokosw4pcVEQvRx3wiSR9SIJokgi94hHjSidta3wiSR9SIJokoswyXjUEi1j1nPNOdRljLY7ZAqXVKIkPC0Tfc74N3VYYtFBtBszDjPuEFElWYLLXD2KYcmqUEnOyDqfm1ZaAYRyFc4fNyNppwbt9mGM8sQBsprhwxskLxHEGEnO4xz5PVTPnPSUKukVpFqQBsprhwxskLxHEGMcF2gZdhKR5j6ELLN(2M2KY6ssP8(issDt6j6W6ssP8k0d04qza)klp9TnTjL1LKs59rCK6M0t0H1LKs5vOhOXDlpi1j1nPNOdRl5L4oEFWwFdchxKTVYYZeUu0yRVbHJlYw9af6QvBcxkAS13GWXfzRE5klpSy7vIQMOyakph)5)f6DpFomTij1)drj(WGIjkm8YeLJiQ)YlIO8oMO6BBAtktuyerHrvmrHOdIQVrHzIAGoXOtu8nik4aIIMheEZdcPUj9eDyDjVe3XRqpq3320Mu(1zv8ZKXECZGx9nkm)e2RS84gLpxhSzLrJHwZ708ztkpi1)drzsprhwxYlXD8k0d0srL08Ge7BBAtk)6Sk(zYypUzWluWtLfUV6Buy(zSW5qVzG2tju4ielpEerxC5YY4Uxz5XnkFUoyZkJgdTM3P5ZMuEqQBsprhwxYlXD8k0d0bBwz0yO18Uxz5zSW5qhSzLrJHwZ70EkHchHy5XJi6Ilxwg3jCFBtBsz9MbrpLqHRvdhWuA0Tfc7yDWMvgngAnVt4EfPqV)SBu(Cn2M86iK3P5ZMuE0dPUj9eDyDjVe3XRqpqVzWlPOskhDBHWo(59RS80RiWtju5bPwTExUYYdlKevnrXauEo(ZUr5Z1yBYRJqENMpBs5rpIDaVMNO7ZHPfzTAdKR3mqhubt9mGM8k2aEXj25ZJvWupdOjV9iWyHZHEZaTNsOWriwE8iIU4YLLXDc3320MuwVzq0tjuysDt6j6W6sEjUJxHEGUYYQxz5zcxk6Crxu8ZcH1WbK6M0t0H1L8sChVc9aDHxKmrW44mD(vLfUr(4fIOpVFjfvs5OBle2XpVj1j1)drf(mOyI6yEGjQfbdPJkkr9FyFAIcviQ0XefLpiEhrzorzevvEzfCfr5iIcdVbggtu4ULhyIAeWK6M0t0H1yNnQ39SWx0KEIUinX(RZQ4NjfHgUrrh(vwECJYNRNueA4gfDynF2KYdbMWLIEsrOHBu0H1duOJu3KEIoSg7Sr9oHEGEnO4xsrLuo62cHD8Z7xz5zGC9AqX6GkyQNb0KxX(wlIcmw4COxdkw7PekCeILhpIOlUCzzCNWFqQBsprhwJD2OENqpq7DRH7IsZFLLh7V8MoRdL0rSqzC3Y3ipiA(SjLhcicgix7DRH7IsZ1EkHkpiK6M0t0H1yNnQ3j0d0Zf2nAetnC3RS8q5(mvS)lobWbmLgDBHWowpxy3Orm1WDF2KEIo9CHDJgXud3PhwLbHf2KEIonUB5HEyvgeMu3KEIoSg7Sr9oHEGghkd4O08xz5HY9zQy)xCcGdykn62cHDSghkd4O08pBsprNghkd4O0C9WQmiSWM0t0PXDlp0dRYGWK6M0t0H1yNnQ3j0d04ULhK6K6M0t0H1tJANKFWWxjx(vwEMWLIML0maZrmIAREGcDcmHlfnlPzaMJu4Zw9af6eO3LllJ7SjLRvRxt6zFoYhxLmw43cysp7ZXbY1y4RKllwt6zFoYhxLmUNEi1nPNOdRNg1ojl0d0y3wm8cHFLLNjCPOzjndWCeJO2QxUYYdlS0WE0ZkUwTjCPOzjndWCKcF2QxUYYdlS0WE0ZkMu3KEIoSEAu7KSqpqJDBl5YVYYZeUu0SKMbyosHpB1lxz5HfwAyp6zfxRggrTnYsAgGzHdJu3KEIoSEAu7KSqpqhAnV7vwEMWLIML0maZrmIARE5klpSWsd7rpR4A1OWNTrwsZamlCyGwFEXj6aF)iSpc797pejOfY2lpiyqlCiCm89n8)v8TyGOiQFDmrLvbO1jQcAjkX4Glgm1fJe1YFkGZLhefgvXeLb7OkZ5brj7SdcJ1K6FI8yI6TiumquFs01NxNhevlR(Kefw0ZTWLO(0eLJiQpbSruJSFIt0ruOaEnhTevVq3dr17hHBpAsDs9WHWXW33W)xX3IbIIO(1XevwfGwNOkOLOeJbllrvtZfJe1YFkGZLhefgvXeLb7OkZ5brj7SdcJ1K6FI8yIsCIbI6tIU(868GOAz1NKOWIEUfUe1NMOCer9jGnIAK9tCIoIcfWR5OLO6f6EiQEFhU9Oj1j1d)vbO15brfEeLj9eDefnXowtQdAgS3HwqRLvFsqJMyhd(bALKs5f8d89n4hOXNnP8aiiOzsprhOTgumOj305nnqRVTPnPSUKukVe1dr9MOeGOwUSmUZMuMOeGOgixVguSoOcM6zan5LOe7drfWloXoFEScM6zan5f0KIkPC0Tfc7yW33ah89dWpqJpBs5bqqqtUPZBAGwFBtBszDjPuEjQhI6dqZKEIoqBnOyGd(ksWpqJpBs5bqqqtUPZBAGwFBtBszDjPuEjQhIsKGMj9eDGwfcDLC5O0CGd(koWpqJpBs5bqqqtUPZBAGwFBtBszDjPuEjQhIsCGMj9eDGgougWrP5ah89FWpqZKEIoqd3T8a04ZMuEaee4ah0k5L4oEb)aFFd(bA8ztkpaccAYnDEtd0MWLIgB9niCCr2QhOqhrvRgrnHlfn26Bq44ISvVCLLhMOelr1lrjrvtumaLNJjQptu)tucruVjQEiQptuHPfjOzsprhOHT(geoUiBbo47hGFGgF2KYdGGGgka0WSdAM0t0bA9TnTjLbT(gfMbTWan5MoVPbAUr5Z1bBwz0yO18onF2KYdqRVTXZQyqBYypUzaWbFfj4hOXNnP8aiiOj305nnqBSW5qhSzLrJHwZ70EkHchHy5XJi6Ilxwg3ructu9TnTjL1Bge9ucfMOQvJOWbmLgDBHWowhSzLrJHwZ7ikHjQEjkrsucruVjQptuUr5Z1yBYRJqENMpBs5br1dOzsprhOfSzLrJHwZ7ao4R4a)an(SjLhabbnt6j6aTndan5MoVPbA9suIaIYtju5bHOQvJO6LOwUYYdtucrusu1efdq55yI6ZeLBu(Cn2M86iK3P5ZMuEqu9quILOgWR5j6iQptuHPfjrvRgrnqUEZaDqfm1ZaAYlrjwIkGxCID(8yfm1ZaAYlr1drjarnw4CO3mq7PekCeILhpIOlUCzzChrjmr1320MuwVzq0tjuyqtkQKYr3wiSJbFFdCW3)b)an(SjLhabbn5MoVPbAt4srNl6IIFwiSgoa0mPNOd0QSSc4GVIi4hOXNnP8aiiOvzHBKpEHikO9g0mPNOd0k8IKjcghNPZGMuujLJUTqyhd((g4ah0ymMpjd(b((g8d04ZMuEaee0KB68MgOzsp7Zr(4QKXeLWe1GX5YJOBle2XevTAe1A5iY95Z12yG15ructuI7FqZKEIoqZ7q7Hbo47hGFGgF2KYdGGGMCtN30aTjCPOxwcfLX4ybTswdhqu1Qrut4sr7jeEXXc8kQgoa0mPNOd08oocFte8nIf0kzGd(ksWpqJpBs5bqqqtUPZBAG2eUu0tCmpPgoa0mPNOd0Q4k0kAevIuyzoIJLTkmWbFfh4hOXNnP8aiiOj305nnqBcxkApHWlowGxr1WbeLaeLevnrXauEoMOEiQ)bnt6j6aTjfHgruj6DCKpUsuGd((p4hOXNnP8aiiOj305nnqZKE2NJ8XvjJjkHjQbJZLhr3wiSJjQA1iQEjQ1YrK7ZNRTXaRZJOeMOcVWikbik(4fIO6bxsz6eLWpe1)Hru9aAM0t0bAfKegZJO9xEtNJt2Qao4Ric(bA8ztkpaccAYnDEtd0mPN95iFCvYyIsyIAW4C5r0Tfc7yIQwnIATCe5(85ABmW68ikHjkrmmqZKEIoqlaEZIO5bjoPg2bo4Rie8d04ZMuEaee0KB68MgOnHlfTNq4fhlWROA4aqZKEIoqdcSTJ0UiQeT)YlY7ao4Ryc(bA8ztkpaccAYnDEtd0MWLI2ti8IJf4vunCaOzsprhOjrNKpFnNhXc1QyGd(gEGFGgF2KYdGGGMCtN30aTjCPO9ecV4ybEfvdhaAM0t0bABgeq5yErCGjzGd((omWpqJpBs5bqqqtUPZBAG2eUu0EcHxCSaVIQHdant6j6aTqOLo6Z5fxgJo7KmWbFF)g8d04ZMuEaee0mPNOd0w2cYdsSqTkgdAYnDEtd0CBHWU2Zko6O4izIsSe1B9)evTAevVevVeLBle21DSr9oDG0jkHjkXmmIQwnIYTfc76o2OENoq6eLyFiQpcJO6HOeGOCBHWU2Zko6O4izIsyI6JWJO6HOQvJO6LOCBHWU2Zko6OyG0JFegrjmrjYWikbik3wiSR9SIJokosMOeMOeN4iQEanPOskhDBHWog89nWboOnnQDsg8d89n4hOXNnP8aiiOj305nnqBcxkAwsZamhXiQT6bk0rucqut4srZsAgG5if(SvpqHoIsaIQxIA5YY4oBszIQwnIQxIYKE2NJ8XvjJjkHjQ3eLaeLj9SphhixJHVsUmrjwIYKE2NJ8XvjJjQEiQEant6j6anm8vYLbo47hGFGgF2KYdGGGMCtN30aTjCPOzjndWCeJO2QxUYYdtuctusd7rpRyIQwnIAcxkAwsZamhPWNT6LRS8WeLWeL0WE0Zkg0mPNOd0WUTy4fcdCWxrc(bA8ztkpaccAYnDEtd0MWLIML0maZrk8zRE5klpmrjmrjnSh9SIjQA1ikmIABKL0maZeLWevyGMj9eDGg2TTKldCWxXb(bA8ztkpaccAYnDEtd0MWLIML0maZrmIARE5klpmrjmrjnSh9SIjQA1ikk8zBKL0maZeLWevyGMj9eDGwO18oGdCqBWfdM6GFGVVb)an(SjLhabbn5MoVPbAt4srxHqhu5flOTsdhaAM0t0bAl8fnPNOlstSdA0e7XZQyqBAu7KmWbF)a8d0mPNOd0WqbtPXPH7an(SjLhabbo4Rib)an(SjLhabbn5MoVPbAt4srlnpwqBLEGcDGMj9eDGM08ybTvah8vCGFGgF2KYdGGGMCtN30aTjCPOXD2afQIPdnCarvRgrnHlfDWIcr1WbGMj9eDG2cFrt6j6I0e7GgnXE8Skg0WoBuVd4GV)d(bA8ztkpaccAM0t0bAsJsJM0t0fPj2bnAI94zvmOjri6af6ao4Ric(bA8ztkpaccAYnDEtd0KOQjkgGYZXeLWpevVe1)eL4ru9TnTjL1fe8kdIZ0zIQhqZKEIoqBHVOj9eDrAIDqJMypEwfdAL8sChVah8vec(bA8ztkpaccAYnDEtd0MWLIEIJ5j1WbevTAe1eUu0y4XGVOvnHXDA4aqZKEIoqBHVOj9eDrAIDqJMypEwfdAyNnQ3bCWxXe8d04ZMuEaee0KB68MgO5gLpxpPi0Wnk6WA(SjLheLae1eUu0tkcnCJIoSEGcDevTAeLiGOCJYNRNueA4gfDynF2KYdIsaIsIQMOyakphtuILO(a0mPNOd0KORpcko6DCehKB6yGd(gEGFGgF2KYdGGGMCtN30an3O856jfHgUrrhwZNnP8GOeGOMWLIEsrOHBu0H1duOJOeGO6LO4JxiIsucruIu)pr9zIIpEHiQEzi8rucru9suIlmI6Ze1eUu0skBR0WEEq0WbevpevpeLyjQEjQ3V)NOepI6drsuFMOMWLIopPTN5j6IqLhKiQe9ook(bFqOSgoGO6HOeGOmPN9540J(MqGWlMOEiQWant6j6aTaeIgxgJGxjdCW33Hb(bA8ztkpaccAYnDEtd0CJYNRNueA4gfDynF2KYdIsaIQxIAcxk6jfHgUrrhwpqHoIQwnIYKE2NJtp6BcbcVyI6HO(GO6b0mPNOd0w4lAsprxKMyh0Oj2JNvXG2KIqd3OOddCW33Vb)an(SjLhabbTcAJhhUo47BqZKEIoqlaHOXLXi4vYah899hGFGgF2KYdGGGMj9eDG2AqXGMCtN30aTLllJ7SjLjQA1iQaEXj25ZJvWupdOjVeLWe1a561GI1bvWupdOjVGMuujLJUTqyhd((g4GVVfj4hOXNnP8aiiOj305nnqtIQMOyakphtupevyGMj9eDGwHxJgllF)vuGd((wCGFGgF2KYdGGGMj9eDGwfcDLC5O0CqtUPZBAG2YLLXD2KYGMuujLJUTqyhd((g4GVV)h8d04ZMuEaee0kOnEC46GVVbnt6j6aTaeIgxgJGxjdCW33Ii4hOXNnP8aiiOj305nnqB5YY4oBszIsaIASW5q7DRH7IsZ1EkHchHy5XJi6Ilxwg3ructu9TnTjL1E3A4UONsOWGMj9eDGM3TgUlknh4GVVfHGFGgF2KYdGGGMCtN30aTEjQjCPO9ecV4ybEfvdhqucqu9suRLJi3NpxBJbwNhrjmr1lr9MOeIOQSWnk7SfcJjkXJOKD2cHXXYAsprNrjQEiQptull7Sfch9SIjQEiQEikbiQEjkCatPr3wiSJ1Zf2nAetnChr9zIYKEIo9CHDJgXud3PhwLbHjkOjkt6j60Zf2nAetnCNwIWor1drjmr1lrzsprNg3T8qpSkdctuqtuM0t0PXDlp0se2jQEant6j6aT5c7gnIPgUd4GVVftWpqJpBs5bqqqtUPZBAGgoGP0OBle2XACOmGJsZjkHjQpant6j6anCOmGJsZbo477Wd8d04ZMuEaee0KB68MgOnHlfTKY2knSNhenCaOzsprhOH7wEaCW3pcd8d04ZMuEaee0mPNOd0KgLgnPNOlstSdA0e7XZQyqRKukVah4GwWYsu10CWpW33GFGgF2KYdGGGgka0WSdAM0t0bA9TnTjLbT(gfMbTWaT(2gpRIbTccELbXz6mWbF)a8d04ZMuEaee0qbGgMDqZKEIoqRVTPnPmO13OWmO9g06BB8Skg0kjLYlWbFfj4hOXNnP8aiiOHcanm7GMj9eDGwFBtBszqRVrHzqlmqtUPZBAGM9xEtN1Hs6iwOmUB5BKhenF2KYdqRVTXZQyqRKukVah8vCGFGgF2KYdGGGgka0WSdAM0t0bA9TnTjLbT(gfMbnrirbnr1zyNbT(2gpRIbTndIEkHcdCW3)b)an(SjLhabbnuaOHzh0mPNOd06BBAtkdA9nkmdAIjO1324zvmO5DRH7IEkHcdCWxre8d04ZMuEaee0qbGgMDqZKEIoqRVTPnPmO13OWmOfgOj305nnqZ(lVPZ6qjDelug3T8nYdIMpBs5bO1324zvmO5DRH7IEkHcdCWxri4hOzsprhObvEJLhrCqUPJbn(SjLhabbo4Ryc(bA8ztkpaccAYnDEtd0MWLIUcHoOYlwqBLEGcDGMj9eDGwWIcrbo4B4b(bA8ztkpaccAYnDEtd0MWLIUcHoOYlwqBLEGcDGMj9eDGM08ybTvah4Gg2zJ6DGFGVVb)an(SjLhabbn5MoVPbAUr5Z1tkcnCJIoSMpBs5brjarnHlf9KIqd3OOdRhOqhOzsprhOTWx0KEIUinXoOrtShpRIbTjfHgUrrhg4GVFa(bA8ztkpaccAM0t0bARbfdAYnDEtd0gixVguSoOcM6zan5LOelr9wlIeLae1yHZHEnOyTNsOWriwE8iIU4YLLXDeLWe1hGMuujLJUTqyhd((g4GVIe8d04ZMuEaee0KB68MgOz)L30zDOKoIfkJ7w(g5brZNnP8GOeGOebe1a5AVBnCxuAU2tju5bb0mPNOd08U1WDrP5ah8vCGFGgF2KYdGGGMCtN30ank3NPeLyjQ)fhrjarHdykn62cHDSEUWUrJyQH7iQptuM0t0PNlSB0iMA4o9WQmimrjmrzsprNg3T8qpSkdcdAM0t0bAZf2nAetnChWbF)h8d04ZMuEaee0KB68MgOr5(mLOelr9V4ikbikCatPr3wiSJ14qzahLMtuFMOmPNOtJdLbCuAUEyvgeMOeMOmPNOtJ7wEOhwLbHbnt6j6anCOmGJsZbo4Ric(bAM0t0bA4ULhGgF2KYdGGah4GMeHOduOd8d89n4hOzsprhOn5fZluGgF2KYdGGah89dWpqZKEIoqlpPTN5j6an(SjLhabbo4Rib)ant6j6anUkafI34eDdqJpBs5bqqGd(koWpqJpBs5bqqqtUPZBAG2eUu0tCmpPgoGOQvJOCJYNRZtA7zEIonF2KYdIsaIsIq0bk0PZtA7zEIo9YvwEyIsyIQKq684YvwEyIQwnIsequUr5Z15jT9mprNMpBs5brjarjri6af60tEX8cLE5klpmrjmrvsiDEC5klpmOzsprhOTwF(qW4yz57VIcCW3)b)an(SjLhabbn5MoVPbAdEcxk61GI1WbeLae1GNWLIEZanCaOzsprhOzdlWZ(CehY2kGd(kIGFGgF2KYdGGGMCtN30an(4fIO6bxsz6eLWe1))tu1QrudKRxdkwVCzzCNnPmrvRgrnqUEZa9YLLXD2KYeLaeLevnrXauEoMOEikjQAIIbO8CSUYcxIQwnIQxIAcxk6joMNudhqucqut4srpXX8K6LRS8WeLyjQ3IKO6b0mPNOd08ecV4ybEff4GVIqWpqJpBs5bqqqtUPZBAG2eUu0EcHxCSaVIQHdikbiQjCPON4yEs9af6ikbikjQAIIbO8CmrjwIsCeLae1a561GI1bvWupdOjVeLyjQ3ArKOeGO4JxiIsuctuIlmqZKEIoqd3zduOkMoao4Ryc(bA8ztkpaccAYnDEtd0MWLI2ti8IJf4vunCarvRgrnHlf9ehZtQHdant6j6aTjVyEHkpiah8n8a)an(SjLhabbn5MoVPbAt4srpXX8KA4aIQwnIAcxk6jfHguySRHdant6j6aTaKNOd4GVVdd8d04ZMuEaee0mPNOd0KgLgnPNOlstSdA0e7XZQyqJXy(KmWbFF)g8d04ZMuEaee0mPNOd0mCxF7yCCT)I2OeTgf0KB68MgOnHlfDWIcr1duOJOeGO6LOg8eUu0R9x0gLO1OXbpHlf9af6iQA1iQbpHlfTeDdyPN95yEqfh8eUu0WbeLaeLBle21EwXrhfdKEuKHruILOER)NOQvJOebe1GNWLIwIUbS0Z(CmpOIdEcxkA4aIsaIQxIAWt4srV2FrBuIwJgh8eUu0y3Kqruc)quF8prjEe17WiQptudEcxk6jfHgruj6DCKpUsunCarvRgr52cHDTNvC0rXrYeLyjkXfgr1drjarnHlfTNq4fhlWRO6LRS8WeLWe17WiQEaTZQyqZWD9TJXX1(lAJs0AuGd(((dWpqJpBs5bqqqtUPZBAG2eUu0blkevpqHoIsaIQxIAcxkApHWlowGxr1WbevTAeLBle21EwXrhfhjtuILO(imIQhqZKEIoqdgZX05kmWboOnPi0Wnk6WGFGVVb)an(SjLhabbnt6j6aT1GIbn5MoVPbA9suIaIYtju5bHOQvJO6LOwUSmUZMuMOeGOc4fNyNppwbt9mGM8suctudKRxdkwhubt9mGM8su9qu9qucqut4srp94AqX6bk0rucquJfoh61GI1EkHchHy5XJi6Ilxwg3ruc)quFaAsrLuo62cHDm47BGd((b4hOXNnP8aiiOzsprhOvHqxjxoknh0KB68MgOTCzzCNnPmrjarnHlf90Jvi0vYL1duOd0KIkPC0Tfc7yW33ah8vKGFGgF2KYdGGGMj9eDGM3TgUlknh0KB68MgOTCzzCNnPmrjarnHlf90JE3A4o9af6ikbiQXcNdT3TgUlknx7PekCeILhpIOlUCzzChrjmrjMGMuujLJUTqyhd((g4GVId8d04ZMuEaee0KB68MgOnHlf90JZf2nAetnCNEGcDGMj9eDG2CHDJgXud3bCW3)b)an(SjLhabbn5MoVPbAt4srp9iougW6bk0rucqu4aMsJUTqyhRXHYaoknNOeMOEdAM0t0bA4qzahLMdCWxre8d04ZMuEaee0KB68MgOnHlf90J4ULh6bk0bAM0t0bA4ULhah8vec(bA8ztkpaccAYnDEtd0MWLIE6rCOmG1duOd0mPNOd0WHYaoknh4GVIj4hOXNnP8aiiOj305nnqBcxk6Ph9U1WD6bk0bAM0t0bAE3A4UO0CGdCGdCGda]] )

    
end
