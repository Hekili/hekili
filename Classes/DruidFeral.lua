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

    spec:RegisterPack( "Feral", 20201126, [[dWKeobqiqapce0LiuvztGOpbcKrjPYPKuAvsQQxrqnlvf3IGODrQFrGgMKIJPkAzsv5zeQmncfxtQQ2giKVrOQmocv5CsQI1rOu9ocLunpcs3tv1(iKoiHsKfsiEibbnrcczJekLpsOevNKGqTsPkZKqj5MGav7eK8tcvvnucc0sjucpvHPcs9vqGYyjuszVa)vObJ0HPSyf9yIMSuUmQnlXNvLgTu50Iwnbb8AvHztYTLKDRYVHmCbooHsuwUsphX0P66GA7Qk9Db14LuLopbSEqOMVGSFOg8eany0mNbq1xn9vZZN9br6AeVAQPFXdmCbcyWiWKpSxgmoRIbdXgVMcmcmbuiRbGgmii4vYGrN7beXUGc(MEh8ulrvcsYkyL5j6KRvCbjzLuqWycNkxi(atWOzodGQVA6RMNp7dI01iE1ut)qeyqcyjaQN1ioWOlBn(atWOXejyaHyQyJxtHPcrlC2W9Gqmfk0xUAYlM2he9bt7RM(Qb3d3dcXuHWo7EzIyh3dcXuHetfzHDtHPdLr6WubX0r4mGX0g8M3lMkcVeEFGPcIPcXN02Z8eDyAwW00X0jBobthDl3W0MvzVmMwxWYcz)IPwnUheIPcjMkwWLLjDyk0DRr6W0cAXuiyPQHPInft6w(A59QX9GqmviXuHi0bb5y6YblkSctZdtLOQP5I1XuVJxgcIGPhctdq55ACpCpietfB8AkmvSKqqXkmvAhMAkcctNmMwqWxdtnht7CpGi2fuW3K46307GNAjQsqXA2bX2AccrIx9arsXREQhiQ0VvKC)s(5Z(BMjoRgXRzLcyeSOsQyWacXuXgVMctfIw4SH7bHykuOVC1KxmTpi6dM2xn9vdUhUheIPcHD29YeXoUheIPcjMkYc7McthkJ0HPcIPJWzaJPn4nVxmveEj8(atfetfIpPTN5j6W0SGPPJPt2CcMo6wUHPnRYEzmTUGLfY(ftTACpietfsmvSGllt6WuO7wJ0HPf0IPqWsvdtfBkM0T81Y7vJ7bHyQqIPcrOdcYX0LdwuyfMMhMkrvtZfRJPEhVmeebtpeMgGYZ14E4EqiMk241uyQyjHGIvyQ0om1ueeMozmTGGVgMAoM25EarSlOGVjX1VP3bp1suLGI1SdIT1eeIeV6bIKIx9upquPFRi5(L8ZN93mtCwnIxZkfCpCpt6j6i6GLLOQP5c)l4xBtBQ4pNvX)fe8kdIZ05pFnfm)xdUheIPJULBy6pMwZhmfk0jKKZciDihtflShmM(JPp)GPJZciDihtflShmM(JP99btfReIX0FmvCFW0r4mGX0Fmvm4EM0t0r0bllrvtZf(xWV2M2uXFoRI)lPsX7NVMcM)Rb3dcX0H0umMgo9omTZioRX9mPNOJOdwwIQMMl8VGFTnTPI)Cwf)Vzq0t5dYNVMcM)fF4EM0t0r0bllrvtZf(xWV2M2uXFoRI)9U1iDrpLpiF(Aky()jUNj9eDeDWYsu10CH)f8rETLBrsqUPtW9mPNOJOdwwIQMMl8VGblkS6tw(NWLIUcHUh5flOTs3qHpCpt6j6i6GLLOQP5c)lO08ybTvFYY)eUu0vi09iVybTv6gk8H7H7zsprh5FHVOj9eDrvs8pNvX)ttzNK)KL)jCPORqO7rEXcAR0Wb4EM0t0re(xqYdyLkonshUNj9eDeH)f0ZxEjXc8kWNS8pHlfT08ybTv6gk8H7zsprhr4FbLMhlOT6tw(NWLIwAESG2kDdf(W9Gqmvi4IcRW0WD8XF5ftdqesovmUheIPM0t0re(xWGffwH7zsprhr4Fbx4lAsprxuLe)Zzv8pXzt5DFYY)eUu0KoRHcxXQMgoiuOjCPOdwuyLgoa3ZKEIoIW)cknLkAsprxuLe)Zzv8VeHunu4d3ZKEIoIW)cUWx0KEIUOkj(NZQ4)sEjPJ3pz5xIQMOyakpNi6FD9lKFTnTPI1fe8kdIZ05AX9GqmfcoSYtH8v2WuIZMY7W9mPNOJi8VGl8fnPNOlQsI)5Sk(N4SP8Upz5Fcxk6jjMNudhek0eUu0e4wJVOvnHjDA4aCpt6j6ic)lOeDFrp4O3XrsqUPt(KLF3u856PcHAUPqhrZNnvCdYjCPONkeQ5McDeDdf(cfcc4MIpxpviuZnf6iA(SPIBqkrvtumaLNteAF4EqiMcDhJPviIJPC9gWhj)YyQiqJPsbKkgtRd6ULjDy6OB5gMocNbmMkrehtF(SFmLpEFf4dMwzpymLaVmMgMXuPDyAL9GXuVZCmnpmvmy6RcnnfPwCpt6j6ic)lyacPIltqWRK)KLF3u856PcHAUPqhrZNnvCdYjCPONkeQ5McDeDdf(GSo(49vaHfNU)6ZhVVcOx(LpHRtm1u)jCPOLk2wPr88E1Wb1wRqR75Z(fY(ex9NWLIopPTN5j6IpY7nIkrVJJcbGVxfRHdQfst65xoo9OV57lVK)AW9mPNOJi8VGl8fnPNOlQsI)5Sk(FQqOMBk0r(KLF3u856PcHAUPqhrZNnvCdY6MWLIEQqOMBk0r0nu4luit65xoo9OV57lVK)(Qf3ZKEIoIW)cw4fjtemjotN)ifqQ4OB7l7K)NFYY)eUu0waxVXGLBMJwsuU238E1WbqwheWnfFUEQqOMBk0r08ztf3cfAcxk6PcHAUPqhrdhulUNj9eDeH)fSWRPILLpiwGpz5xIQMOyakpN8xdUNj9eDeH)fmaHuXLji4vYFkOnEC96)pX9mPNOJi8VGR9G)ifqQ4OB7l7K)NFYY)YLLjD2uXHcfWljjoFEScw5zGk5v0gY1R9G1bvWkpdujVq2w4SPx7bR9u(GeFT84weDXLllt6eLeWkv0T9LDIMeod4O0863Nq2hUNj9eDeH)fScHUsUCuA(hPasfhDBFzN8)8tw(xUSmPZMkgY2cNnDfcDLCzTNYhK4RLh3IOlUCzzsNOKawPIUTVSt0KWzahLMx)(eY(W9mPNOJi8VGbiKkUmbbVs(tbTXJRx))jUNj9eDeH)f07wJ0fLM)jl)lxwM0ztfdzBHZM27wJ0fLMR9u(GeFT84weDXLllt6e9RTPnvS27wJ0f9u(GG7zsprhr4FbNlSBQirzKUpz5VUjCPO98LxsSaVcOHdGSU1YwK)YNRTwJOZt06EkCLvVrzNTVmriLD2(YKyznPNOZu1w)LLD2(YrpR4ARfY6ibSsfDBFzNONlSBQirzKU6BsprNEUWUPIeLr60nRYEzXpt6j60Zf2nvKOmsNwIiETIwNj9eDAs3YnDZQSxw8ZKEIonPB5MwIiET4EM0t0re(xqs4mGJsZ)KLFsaRur32x2jAs4mGJsZf9jUNj9eDeH)fK0TC7tw(NWLIwQyBLgXZ7vdhG7zsprhr4FbLMsfnPNOlQsI)5Sk(VKkfV4E4EM0t0r0tfc1CtHoY)Ap4psbKko62(Yo5)5NS8xheWt5J8EdfQULllt6SPIHmGxssC(8yfSYZavYROnKRx7bRdQGvEgOsERTwiNWLIE6X1EW6gk8bzBHZMEThS2t5ds81YJBr0fxUSmPt0)(W9mPNOJONkeQ5McDeH)fubF2gZJeKR5j6(ifqQ4OB7l7K)NFYY)YLLjD2uXqoHlf90Jvi0vYL1nu4d3ZKEIoIEQqOMBk0re(xqVBnsxuA(hPasfhDBFzN8)8tw(xUSmPZMkgYjCPONE07wJ0PBOWhKTfoBAVBnsxuAU2t5ds81YJBr0fxUSmPtuXd3ZKEIoIEQqOMBk0re(xW5c7MksugP7tw(NWLIE6X5c7MksugPt3qHpCpt6j6i6PcHAUPqhr4FbjHZaokn)tw(NWLIE6rs4mG1nu4dssaRur32x2jAs4mGJsZf9jUNj9eDe9uHqn3uOJi8VGKULBFYY)eUu0tps6wUPBOWhUNj9eDe9uHqn3uOJi8VGKWzahLM)jl)t4srp9ijCgW6gk8H7zsprhrpviuZnf6ic)lO3TgPlkn)tw(NWLIE6rVBnsNUHcF4E4EqiMcT4VqK4VyhtHI5gM6imLiWjX0WP3HPHtVdtx7lFiycMww(GybW0WD8HPHzmDHpmTS8bXcmTR9btrlMAUInIJPYow(atZcMMobtdJwVdtth3ZKEIoIwIqQgk89p5LW7dCpt6j6iAjcPAOWNW)cMN02Z8eD4EqiMc9kaMAxdtpKJPHnIZyk0InmLpEFf4dMoHDm1ueeMkeaM4ykmHX00X0cAXuiM3hyQDnmnpPThb3ZKEIoIwIqQgk8j8VGE(YljwGxb(KLF(49vaDJlPmDr7V)qHQBcxk6jjMNudha5eUu0tsmpPE5klpIqFkUAdfQo3u856GLBMJwnF2uXnijDO1zIhDVjuXvlUNj9eDeTeHunu4t4Fb5QauyEJt01W9mPNOJOLiKQHcFc)l4AF5dbtILLpiwGpz5Fcxk6jjMNudhekKBk(CDEsBpZt0P5ZMkUbPeHunu4tNN02Z8eD6LRS8iIwY3opUCLLhjuiiGBk(CDEsBpZt0P5ZMkUbPeHunu4tp5LW7d9YvwEerl5BNhxUYYJG7zsprhrlrivdf(e(xqRzbE(LJKW2w9jl)nEcxk61EWA4aiB8eUu0BgOHdW9Gqmf6vam1UgMEihtdBeNXuOfBykF8(kWhmDc7yQPiim9fHPf0IPqmVpWu7AyAEsBpCpt6j6iAjcPAOWNW)c65lVKybEf4tw(5J3xb0nUKY0fT)(dfQHC9Apy9YLLjD2uXHc1qUEZa9YLLjD2uXqkrvtumaLNt(LOQjkgGYZj6kREdfQUjCPONKyEsnCaKt4srpjX8K6LRS8ic9P4Qf3ZKEIoIwIqQgk8j8VGKoRHcxXQ2NS8pHlfTNV8sIf4vanCaKt4srpjX8K6gk8bPevnrXauEorOIbYgY1R9G1bvWkpdujVc9PgIGKpEFfquXudUNj9eDeTeHunu4t4FbN8s49rEVFYY)eUu0E(YljwGxb0WbHcnHlf9KeZtQHdW9mPNOJOLiKQHcFc)lyaYt09jl)t4srpjX8KA4GqHMWLIEQqOMcM4A4aCpt6j6iAjcPAOWNW)cknLkAsprxuLe)Zzv8pti8jzCpt6j6iAjcPAOWNW)cct4y6C1NZQ4FJ091oMexdIrBuIwt9jl)t4srhSOWkDdf(GSUgpHlf9AqmAJs0AQyJNWLIUHcFHc14jCPOLORbl98lhZ7rSXt4srdhaPB7l7ApR4OJIbspkUAe6tD)HcbbA8eUu0s01GLE(LJ59i24jCPOHdGSUgpHlf9AqmAJs0AQyJNWLIM4M8HO)91Vq(SM634jCPONkeQfrLO3Xr(4kb0WbHc52(YU2Zko6OylzHkMAQfYjCPO98LxsSaVcOxUYYJi6ZAQf3ZKEIoIwIqQgk8j8VGR9Lpemjww(Gyb(KL)jCPONKyEsnCqOqL8TZJlxz5reAFpX9GqmfAXFHiXFXoMke2XYhyAfcDpYdt7qEym1UgMsC4sbtv5dgt9UK8btTRHPvMatgtNS78IPsu10CmD5klpmDzIaNe3ZKEIoIwIqQgk8j8VGs09f9GJEhhjb5Mo5tw(RRHC9Mb6LRS8iIkgiRBcxkApF5LelWRa6gk8fk0eUu0E(YljwGxb0lxz5reQyQfsjQAIIbO8CYFnq2qU27wJ0fLMR9u(iVxiBixV2dw7P8rEV1gkujF784YvwEeH2pUheIPqWnbMmM6D8YykPdbRAy6KX0k0YyQeDT0t0rWu0HPEhJPs01Gth3ZKEIoIwIqQgk8j8VGpYRTClscYnDYNS8pHlfTNV8sIf4vanCqOq1jrxdoDDJ5GOPu8BANK18ztf3Qf3ZKEIoIwIqQgk8j8VGwZc88lhjHTT6JuaPIJUTVSt(F(jlsu1efdq55K)(Hec0qU2AwGNF5ijSTvXMvzVS2t5J8EX9mPNOJOLiKQHcFc)limHJPZveCpCpt6j6iAMq4tY)EhApYNS8Bsp)Yr(4QKjI2ysUCl62(YojuO1YwK)YNRTwJOZtuX0pUNj9eDenti8jzH)f074i8nrWxlwqRK)KL)jCPOxw(qXesSGwjRHdcfAcxkApF5LelWRaA4aCpt6j6iAMq4tYc)lyfxHwbIOsublZwSTSvr(KL)jCPONKyEsnCaUNj9eDenti8jzH)fCQqOwevIEhh5JRe4tw(NWLI2ZxEjXc8kGgoasjQAIIbO8CYF)4EM0t0r0mHWNKf(xWcsct4w0GyEtNJt2Q(KLFt65xoYhxLmr0gtYLBr32x2jHcv3AzlYF5Z1wRr05jA9udK8X7Ra6gxsz6I(3Fn1I7zsprhrZecFsw4FbdG3SiqEVXPYi(NS8Bsp)Yr(4QKjI2ysUCl62(YojuO1YwK)YNRTwJOZtuiQgCpt6j6iAMq4tYc)l4lSTT0UiQeniMxK39jl)t4sr75lVKybEfqdhG7zsprhrZecFsw4FbLOtYNVMZTyrzv8NS8pHlfTNV8sIf4vanCaUNj9eDenti8jzH)fCZGafhZlscmj)jl)t4sr75lVKybEfqdhG7zsprhrZecFsw4FbdJwv7lNxCzc6StYFYY)eUu0E(YljwGxb0Wb4EM0t0r0mHWNKf(xWLTG8EJfLvXKpsbKko62(Yo5)5NS872(YU2Zko6OylzH(u3FOq1vNB7l76o2uENoq6IkE1ekKB7l76o2uENoq6c9VVAQfs32x21EwXrhfBjlAF1tTHcvNB7l7ApR4OJIbsp2xnIkUAG0T9LDTNvC0rXwYIkgXulUhUNj9eDeDjvkE)x7b)rkGuXr32x2j)p)KL)V2M2uX6sQu8()eYLllt6SPIHSHC9ApyDqfSYZavYRq)d4LKeNppwbR8mqL8I7zsprhrxsLIxH)fCTh8NS8)120MkwxsLI3)(W9mPNOJOlPsXRW)cQGpBJ5rcY18eDFYY)xBtBQyDjvkE)fhUNj9eDeDjvkEf(xqs4mG)KL)V2M2uX6sQu8(lgCpt6j6i6sQu8k8VGKULB4E4EM0t0r0L8sshV)e7R9YXfz7NS8pHlfnX(AVCCr2QBOWxOqt4srtSV2lhxKT6LRS8icTojQAIIbO8Cs9HiHFwB9RrloCpietHGBpymLaVmM6imfI5fHPEhJPFTnTPIXucctjOkgtrQgM(1uWmM2qheKJP81Wu4amvL3lV59I7zsprhrxYljD8k8VGFTnTPI)Cwf)pzIh3m4ZxtbZ)18jl)UP4Z1bBwzQy418onF2uXnCpietnPNOJOl5LKoEf(xqPasvEVXV2M2uXFoRI)NmXJBg8bf8xz17NVMcM)BlC20BgO9u(GeFT84weDXLllt6(KLF3u856GnRmvm8AENMpBQ4gUNj9eDeDjVK0XRW)cgSzLPIHxZ7(KL)2cNnDWMvMkgEnVt7P8bj(A5XTi6IlxwM0j6xBtBQy9MbrpLpiHcrcyLk62(YorhSzLPIHxZ7eToXj8Z67MIpxtSjVoc5DA(SPIB1I7zsprhrxYljD8k8VGBg8rkGuXr32x2j)p)KL)6GaEkFK3BOq1TCLLhryjQAIIbO8Cs9DtXNRj2KxhH8onF2uXTAfAdEnprx9RrlUqHAixVzGoOcw5zGk5vOb8ssIZNhRGvEgOsERfY2cNn9MbApLpiXxlpUfrxC5YYKor)ABAtfR3mi6P8bb3ZKEIoIUKxs64v4Fbl8IKjcMeNPZFQS6nYhVVc8)8JuaPIJUTVSt(FI7H7bHyQyH9GX0J5gbtxe8BNsamT)Ae)WuubttNGPk(E9om1Cm1W0Q8Yk4km1rykbEdmcbtjDl3iyAlGX9mPNOJOjoBkV7FHVOj9eDrvs8pNvX)tfc1CtHoYNS87MIpxpviuZnf6iA(SPIBqoHlf9uHqn3uOJOBOWhUNj9eDenXzt5Dc)l4Ap4psbKko62(Yo5)5NS83qUEThSoOcw5zGk5vOp1qeKTfoB61EWApLpiXxlpUfrxC5YYKor7d3ZKEIoIM4SP8oH)f07wJ0fLM)jl)k(lReA)IbsdI5nDwhovTyrXKULVwEVA(SPIBqcbAix7DRr6IsZ1EkFK3lUNj9eDenXzt5Dc)l4CHDtfjkJ09jl)k(lReA)IbssaRur32x2j65c7MksugPR(M0t0PNlSBQirzKoDZQSxwut6j60KULB6MvzVmUNj9eDenXzt5Dc)lijCgWrP5FYYVI)YkH2VyGKeWkv0T9LDIMeod4O086BsprNMeod4O0CDZQSxwut6j60KULB6MvzVmUNj9eDenXzt5Dc)liPB5gUhUNj9eDe90u2j5Fc8vYL)KL)jCPOzPkdiCKGu2QBOWhKt4srZsvgq4Oc(Sv3qHpiRB5YYKoBQ4qHQZKE(LJ8Xvjte9jKM0ZVCSHCnb(k5Yc1KE(LJ8XvjtQTwCpt6j6i6PPStYc)liXTLaVV8NS8pHlfnlvzaHJeKYw9YvwEerLgXJEwXHcnHlfnlvzaHJk4Zw9YvwEerLgXJEwX4EM0t0r0ttzNKf(xqIBBjx(tw(NWLIMLQmGWrf8zRE5klpIOsJ4rpR4qHiiLTrwQYaclAn4EM0t0r0ttzNKf(xWWR5DFYY)eUu0SuLbeosqkB1lxz5revAep6zfhkKc(SnYsvgqyrRbm(YljrhaQ(QPVAE(SpXPFcgHT9Y7LagqWeljwaLqmuILl2Xumf6ogtZQa06yAbTykeuJlgSYHGW0LfldoxUHPeufJPgSJQmNByQSZUxMOX9eRYJX0N1Jyhtfcr3xEDUHPJSsietjcCUvVyQ4hM6imvSc2W0w(njj6WuuaVMJwmTobRftRRV6TwnUhUNqCvaADUHP1dMAsprhMQsIt04EGHkjobanyusLIxa0aOEcGgm4ZMkUbebmmPNOdmw7bdgYnDEtdm(ABAtfRlPsXlM(JPpXuiX0Lllt6SPIXuiX0gY1R9G1bvWkpdujVyQq)X0aEjjX5ZJvWkpdujVGHuaPIJUTVStaq9e4aO6danyWNnvCdicyi305nnW4RTPnvSUKkfVy6pM2hyysprhyS2dg4aOehaAWGpBQ4gqeWqUPZBAGXxBtBQyDjvkEX0FmvCGHj9eDGrfcDLC5O0CGdGsmaObd(SPIBarad5MoVPbgFTnTPI1LuP4ft)XuXagM0t0bgKWzahLMdCau9dGgmmPNOdmiDl3ad(SPIBaraoWbJsEjPJxa0aOEcGgm4ZMkUbebmKB68MgymHlfnX(AVCCr2QBOWhMgkeMoHlfnX(AVCCr2QxUYYJGPcftRdtLOQjkgGYZjyA9XuictfgtFIP1IP1htRrloWWKEIoWGyFTxoUiBboaQ(aqdg8ztf3aIagOaWGWoyysprhy8120Mkgm(AkygmQbmKB68Mgy4MIpxhSzLPIHxZ708ztf3aJV2gpRIbJjt84MbahaL4aqdg8ztf3aIagYnDEtdmAlC20bBwzQy418oTNYhK4RLh3IOlUCzzshMkkM(120MkwVzq0t5dcMgkeMscyLk62(YorhSzLPIHxZ7WurX06WuXHPcJPpX06JPUP4Z1eBYRJqENMpBQ4gMwlyysprhyeSzLPIHxZ7aoakXaGgm4ZMkUbebmmPNOdm2mamKB68MgyuhMcbWupLpY7ftdfctRdtxUYYJGPcJPsu1efdq55emT(yQBk(CnXM86iK3P5ZMkUHP1IPcftBWR5j6W06JP1OfhMgkeM2qUEZaDqfSYZavYlMkumnGxssC(8yfSYZavYlMwlMcjM2w4SP3mq7P8bj(A5XTi6IlxwM0HPIIPFTnTPI1Bge9u(GagsbKko62(Yoba1tGdGQFa0GbF2uXnGiGrLvVr(49vaW4jyysprhyu4fjtemjotNbdPasfhDBFzNaG6jWboyWecFsganaQNaObd(SPIBarad5MoVPbgM0ZVCKpUkzcMkkM2ysUCl62(YobtdfctxlBr(lFU2AnIopmvumvm9dgM0t0bgEhApcWbq1haAWGpBQ4gqeWqUPZBAGXeUu0llFOycjwqRK1WbyAOqy6eUu0E(YljwGxb0WbGHj9eDGH3Xr4BIGVwSGwjdCauIdanyWNnvCdicyi305nnWycxk6jjMNudhagM0t0bgvCfAfiIkrfSmBX2Ywfb4aOedaAWGpBQ4gqeWqUPZBAGXeUu0E(YljwGxb0WbykKyQevnrXauEobt)X0(bdt6j6aJPcHAruj6DCKpUsaGdGQFa0GbF2uXnGiGHCtN30adt65xoYhxLmbtfftBmjxUfDBFzNGPHcHP1HPRLTi)LpxBTgrNhMkkMwp1GPqIP8X7Ra6gxsz6yQO)yA)1GP1cgM0t0bgfKeMWTObX8MohNSvbCauqeaAWGpBQ4gqeWqUPZBAGHj98lh5JRsMGPIIPnMKl3IUTVStW0qHW01YwK)YNRTwJOZdtfftHOAadt6j6aJa4nlcK3BCQmIdCauIpa0GbF2uXnGiGHCtN30aJjCPO98LxsSaVcOHdadt6j6aJxyBBPDrujAqmViVd4aOepa0GbF2uXnGiGHCtN30aJjCPO98LxsSaVcOHdadt6j6adj6K85R5ClwuwfdCau1daAWGpBQ4gqeWqUPZBAGXeUu0E(YljwGxb0WbGHj9eDGXMbbkoMxKeysg4aOEwdaAWGpBQ4gqeWqUPZBAGXeUu0E(YljwGxb0WbGHj9eDGry0QAF58IltqNDsg4aOE(eanyWNnvCdicyysprhySSfK3BSOSkMagYnDEtdmCBFzx7zfhDuSLmMkum9PUFmnuimTomTom1T9LDDhBkVthiDmvumv8QbtdfctDBFzx3XMY70bshtf6pM2xnyATykKyQB7l7ApR4OJITKXurX0(QhmTwmnuimTom1T9LDTNvC0rXaPh7RgmvumvC1GPqIPUTVSR9SIJok2sgtfftfJyW0AbdPasfhDBFzNaG6jWboymnLDsganaQNaObd(SPIBarad5MoVPbgt4srZsvgq4ibPSv3qHpmfsmDcxkAwQYachvWNT6gk8HPqIP1HPlxwM0ztfJPHcHP1HPM0ZVCKpUkzcMkkM(etHetnPNF5yd5Ac8vYLXuHIPM0ZVCKpUkzcMwlMwlyysprhyqGVsUmWbq1haAWGpBQ4gqeWqUPZBAGXeUu0SuLbeosqkB1lxz5rWurXuPr8ONvmMgkeMoHlfnlvzaHJk4Zw9YvwEemvumvAep6zfdgM0t0bge3wc8(YahaL4aqdg8ztf3aIagYnDEtdmMWLIMLQmGWrf8zRE5klpcMkkMknIh9SIX0qHWucszBKLQmGWyQOyAnGHj9eDGbXTTKldCauIbanyWNnvCdicyi305nnWycxkAwQYachjiLT6LRS8iyQOyQ0iE0ZkgtdfctvWNTrwQYacJPIIP1agM0t0bgHxZ7aoWbJgxmyLdGga1ta0GbF2uXnGiGHCtN30aJjCPORqO7rEXcAR0WbGHj9eDGXcFrt6j6IQK4GHkjE8SkgmMMYojdCau9bGgmmPNOdmipGvQ40iDGbF2uXnGiahaL4aqdg8ztf3aIagYnDEtdmMWLIwAESG2kDdf(adt6j6adpF5LelWRaahaLyaqdg8ztf3aIagYnDEtdmMWLIwAESG2kDdf(adt6j6adP5XcARaoaQ(bqdg8ztf3aIagYnDEtdmMWLIM0znu4kw10WbyAOqy6eUu0blkSsdhagM0t0bgl8fnPNOlQsIdgQK4XZQyWG4SP8oGdGcIaqdg8ztf3aIagM0t0bgstPIM0t0fvjXbdvs84zvmyirivdf(aoakXhaAWGpBQ4gqeWqUPZBAGHevnrXauEobtf9htRdt7htfsm9RTPnvSUGGxzqCMoJP1cgM0t0bgl8fnPNOlQsIdgQK4XZQyWOKxs64f4aOepa0GbF2uXnGiGHCtN30aJjCPONKyEsnCaMgkeMoHlfnbU14lAvtysNgoammPNOdmw4lAsprxuLehmujXJNvXGbXzt5Dahav9aGgm4ZMkUbebmKB68Mgy4MIpxpviuZnf6iA(SPIBykKy6eUu0tfc1CtHoIUHcFyAOqykeatDtXNRNkeQ5McDenF2uXnmfsmvIQMOyakpNGPcft7dmmPNOdmKO7l6bh9ooscYnDcWbq9Sga0GbF2uXnGiGHCtN30ad3u856PcHAUPqhrZNnvCdtHetNWLIEQqOMBk0r0nu4dtHetRdt5J3xbWuHXuXP7htRpMYhVVcOx(LpmvymTomvm1GP1htNWLIwQyBLgXZ7vdhGP1IP1IPcftRdtF(SFmviX0(ehMwFmDcxk68K2EMNOl(iV3iQe9ookea(EvSgoatRftHetnPNF540J(MVV8sW0FmTgWWKEIoWiaHuXLji4vYaha1ZNaObd(SPIBarad5MoVPbgUP4Z1tfc1CtHoIMpBQ4gMcjMwhMoHlf9uHqn3uOJOBOWhMgkeMAsp)YXPh9nFF5LGP)yAFyATGHj9eDGXcFrt6j6IQK4GHkjE8SkgmMkeQ5McDeGdG6zFaObd(SPIBaradt6j6aJcVizIGjXz6myi305nnWycxkAlGR3yWYnZrljkx7BEVA4amfsmTomfcGPUP4Z1tfc1CtHoIMpBQ4gMgkeMoHlf9uHqn3uOJOHdW0AbdPasfhDBFzNaG6jWbq9uCaObd(SPIBarad5MoVPbgsu1efdq55em9htRbmmPNOdmk8AQyz5dIfa4aOEkga0GbF2uXnGiGrbTXJRxha1tWWKEIoWiaHuXLji4vYaha1Z(bqdg8ztf3aIagM0t0bgR9Gbd5MoVPbglxwM0ztfJPHcHPb8ssIZNhRGvEgOsEXurX0gY1R9G1bvWkpdujVykKyABHZMEThS2t5ds81YJBr0fxUSmPdtfftjbSsfDBFzNOjHZaoknhtRpM2hMkKyAFGHuaPIJUTVStaq9e4aOEcraObd(SPIBaradt6j6aJke6k5YrP5GHCtN30aJLllt6SPIXuiX02cNnDfcDLCzTNYhK4RLh3IOlUCzzshMkkMscyLk62(YortcNbCuAoMwFmTpmviX0(adPasfhDBFzNaG6jWbq9u8bGgm4ZMkUbebmkOnEC96aOEcgM0t0bgbiKkUmbbVsg4aOEkEaObd(SPIBarad5MoVPbglxwM0ztfJPqIPTfoBAVBnsxuAU2t5ds81YJBr0fxUSmPdtfft)ABAtfR9U1iDrpLpiGHj9eDGH3TgPlknh4aOEwpaObd(SPIBarad5MoVPbg1HPt4sr75lVKybEfqdhGPqIP1HPRLTi)LpxBTgrNhMkkMwhM(etfgtRS6nk7S9LjyQqIPYoBFzsSSM0t0zkmTwmT(y6YYoBF5ONvmMwlMwlMcjMwhMscyLk62(Yorpxy3urIYiDyA9Xut6j60Zf2nvKOmsNUzv2lJPcIPM0t0PNlSBQirzKoTerCmTwmvumTom1KEIonPB5MUzv2lJPcIPM0t0PjDl30seXX0Abdt6j6aJ5c7MksugPd4aO6Rga0GbF2uXnGiGHCtN30adsaRur32x2jAs4mGJsZXurX0NGHj9eDGbjCgWrP5ahavFpbqdg8ztf3aIagYnDEtdmMWLIwQyBLgXZ7vdhagM0t0bgKULBahavF9bGgm4ZMkUbebmmPNOdmKMsfnPNOlQsIdgQK4XZQyWOKkfVah4GrWYsu10Ca0aOEcGgm4ZMkUbebmqbGbHDWWKEIoW4RTPnvmy81uWmyudy8124zvmyuqWRmiotNboaQ(aqdg8ztf3aIagOaWGWoyysprhy8120Mkgm(AkygmQbm(AB8SkgmkPsXlWbqjoa0GbF2uXnGiGbkamiSdgM0t0bgFTnTPIbJVMcMbdXhy8124zvmySzq0t5dcWbqjga0GbF2uXnGiGbkamiSdgM0t0bgFTnTPIbJVMcMbJNGXxBJNvXGH3TgPl6P8bb4aO6hanyysprhy8iV2YTiji30jGbF2uXnGiahafebGgm4ZMkUbebmKB68MgymHlfDfcDpYlwqBLUHcFGHj9eDGrWIcRaoakXhaAWGpBQ4gqeWqUPZBAGXeUu0vi09iVybTv6gk8bgM0t0bgsZJf0wbCGdgeNnL3bGga1ta0GbF2uXnGiGHCtN30ad3u856PcHAUPqhrZNnvCdtHetNWLIEQqOMBk0r0nu4dmmPNOdmw4lAsprxuLehmujXJNvXGXuHqn3uOJaCau9bGgm4ZMkUbebmmPNOdmw7bdgYnDEtdmAixV2dwhubR8mqL8IPcftFQHimfsmTTWztV2dw7P8bj(A5XTi6IlxwM0HPIIP9bgsbKko62(Yoba1tGdGsCaObd(SPIBarad5MoVPbgk(lRWuHIP9lgmfsm1GyEtN1HtvlwumPB5RL3RMpBQ4gMcjMcbW0gY1E3AKUO0CTNYh59cgM0t0bgE3AKUO0CGdGsmaObd(SPIBarad5MoVPbgk(lRWuHIP9lgmfsmLeWkv0T9LDIEUWUPIeLr6W06JPM0t0PNlSBQirzKoDZQSxgtfftnPNOtt6wUPBwL9YGHj9eDGXCHDtfjkJ0bCau9dGgm4ZMkUbebmKB68MgyO4VSctfkM2VyWuiXusaRur32x2jAs4mGJsZX06JPM0t0PjHZaoknx3Sk7LXurXut6j60KULB6MvzVmyysprhyqcNbCuAoWbqbraObdt6j6ads3YnWGpBQ4gqeGdCWqIqQgk8bGga1ta0GHj9eDGXKxcVpad(SPIBaraoaQ(aqdgM0t0bg5jT9mprhyWNnvCdicWbqjoa0GbF2uXnGiGHCtN30ad(49vaDJlPmDmvumT)(X0qHW06W0jCPONKyEsnCaMcjMoHlf9KeZtQxUYYJGPcftFkomTwmnuimTom1nfFUoy5M5OvZNnvCdtHetjDO1zIhDVHPcftfhMwlyysprhy45lVKybEfa4aOedaAWWKEIoWGRcqH5norxdm4ZMkUbeb4aO6hanyWNnvCdicyi305nnWycxk6jjMNudhGPHcHPUP4Z15jT9mprNMpBQ4gMcjMkrivdf(05jT9mprNE5klpcMkkMwY3opUCLLhbtdfctHayQBk(CDEsBpZt0P5ZMkUHPqIPses1qHp9KxcVp0lxz5rWurX0s(25XLRS8iGHj9eDGXAF5dbtILLpiwaGdGcIaqdg8ztf3aIagYnDEtdmA8eUu0R9G1WbykKyAJNWLIEZanCayysprhyynlWZVCKe22kGdGs8bGgm4ZMkUbebmKB68MgyWhVVcOBCjLPJPIIP93pMgkeM2qUEThSE5YYKoBQymnuimTHC9Mb6Lllt6SPIXuiXujQAIIbO8CcM(JPsu1efdq55eDLvVyAOqyADy6eUu0tsmpPgoatHetNWLIEsI5j1lxz5rWuHIPpfhMwlyysprhy45lVKybEfa4aOepa0GbF2uXnGiGHCtN30aJjCPO98LxsSaVcOHdWuiX0jCPONKyEsDdf(WuiXujQAIIbO8CcMkumvmykKyAd561EW6GkyLNbQKxmvOy6tneHPqIP8X7RayQOyQyQbmmPNOdmiDwdfUIvnGdGQEaqdg8ztf3aIagYnDEtdmMWLI2ZxEjXc8kGgoatdfctNWLIEsI5j1WbGHj9eDGXKxcVpY7f4aOEwdaAWGpBQ4gqeWqUPZBAGXeUu0tsmpPgoatdfctNWLIEQqOMcM4A4aWWKEIoWia5j6aoaQNpbqdg8ztf3aIagM0t0bgstPIM0t0fvjXbdvs84zvmyWecFsg4aOE2haAWGpBQ4gqeWWKEIoWWiDFTJjX1Gy0gLO1uGHCtN30aJjCPOdwuyLUHcFykKyADyAJNWLIEnigTrjAnvSXt4sr3qHpmnuimTXt4srlrxdw65xoM3JyJNWLIgoatHetDBFzx7zfhDumq6rXvdMkum9PUFmnuimfcGPnEcxkAj6AWsp)YX8EeB8eUu0WbykKyADyAJNWLIEnigTrjAnvSXt4srtCt(atf9ht7RFmviX0N1GP1htB8eUu0tfc1IOs074iFCLaA4amnuim1T9LDTNvC0rXwYyQqXuXudMwlMcjMoHlfTNV8sIf4va9YvwEemvum9znyATGXzvmyyKUV2XK4AqmAJs0AkGdG6P4aqdg8ztf3aIagYnDEtdmMWLIEsI5j1WbyAOqyAjF784YvwEemvOyAFpbdt6j6aJ1(YhcMellFqSaaha1tXaGgm4ZMkUbebmKB68MgyuhM2qUEZa9YvwEemvumvmykKyADy6eUu0E(YljwGxb0nu4dtdfctNWLI2ZxEjXc8kGE5klpcMkumvmyATykKyQevnrXauEobt)X0AWuiX0gY1E3AKUO0CTNYh59IPqIPnKRx7bR9u(iVxmTwmnuimTKVDEC5klpcMkumTFWWKEIoWqIUVOhC074iji30jaha1Z(bqdg8ztf3aIagYnDEtdmMWLI2ZxEjXc8kGgoatdfctRdtLORbNUUXCq0uk(nTtYA(SPIByATGHj9eDGXJ8Al3IKGCtNaCaupHia0GbF2uXnGiGHuaPIJUTVStaq9emmPNOdmSMf45xoscBBfyKfjQAIIbO8Ccy0pKqGgY1wZc88lhjHTTk2Sk7L1EkFK3lWbq9u8bGgmmPNOdmGjCmDUIag8ztf3aIaCGdgtfc1CtHocaAaupbqdg8ztf3aIagM0t0bgR9Gbd5MoVPbg1HPqam1t5J8EX0qHW06W0Lllt6SPIXuiX0aEjjX5ZJvWkpdujVyQOyAd561EW6GkyLNbQKxmTwmTwmfsmDcxk6Phx7bRBOWhMcjM2w4SPx7bR9u(GeFT84weDXLllt6Wur)X0(adPasfhDBFzNaG6jWbq1haAWGpBQ4gqeWWKEIoWOcHUsUCuAoyi305nnWy5YYKoBQymfsmDcxk6PhRqORKlRBOWhyifqQ4OB7l7eaupboakXbGgm4ZMkUbebmmPNOdm8U1iDrP5GHCtN30aJLllt6SPIXuiX0jCPONE07wJ0PBOWhMcjM2w4SP9U1iDrP5ApLpiXxlpUfrxC5YYKomvumv8adPasfhDBFzNaG6jWbqjga0GbF2uXnGiGHCtN30aJjCPONECUWUPIeLr60nu4dmmPNOdmMlSBQirzKoGdGQFa0GbF2uXnGiGHCtN30aJjCPONEKeodyDdf(WuiXusaRur32x2jAs4mGJsZXurX0NGHj9eDGbjCgWrP5ahafebGgm4ZMkUbebmKB68MgymHlf90JKULB6gk8bgM0t0bgKULBahaL4danyWNnvCdicyi305nnWycxk6PhjHZaw3qHpWWKEIoWGeod4O0CGdGs8aqdg8ztf3aIagYnDEtdmMWLIE6rVBnsNUHcFGHj9eDGH3TgPlknh4ah4GHb7DOfmgzLqiWboaaa]] )

    
end
