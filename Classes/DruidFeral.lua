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
        ferocious_wound = 611, -- 236020
        freedom_of_the_herd = 203, -- 213200
        fresh_wound = 612, -- 203224
        high_winds = 5384, -- 200931
        king_of_the_jungle = 602, -- 203052
        leader_of_the_pack = 3751, -- 202626
        malornes_swiftness = 601, -- 236012
        savage_momentum = 820, -- 205673
        strength_of_the_wild = 3053, -- 236019
        thorns = 201, -- 305497
        wicked_claws = 620, -- 203242
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

        local aura = action
        if action == "primal_wrath" then aura = "rip" end

        local duration = class.auras[ aura ].duration * ( action == "primal_wrath" and 0.5 or 1 )
        local app_duration = min( ttd, class.abilities[ action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time

        remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
        duration = max( 0, min( remains + duration, 1.3 * duration, ttd ) )
        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time

        if action == "primal_wrath" and active_enemies > 1 then
            -- Current target's ticks are based on actual values.
            local total = potential_ticks - remaining_ticks
            
            -- Other enemies could have a different remains for other reasons.
            -- Especially SbT.
            local pw_remains = max( state.action.primal_wrath.lastCast + class.abilities.primal_wrath.max_apply_duration - query_time, 0 )

            local fresh = max( 0, active_enemies - active_dot[ aura ] )
            local dotted = max( 0, active_enemies - fresh )

            if remains == 0 then
                fresh = max( 0, fresh - 1 )
            else
                dotted = max( 0, dotted - 1 )
                pw_remains = min( remains, pw_remains )
            end

            local pw_duration = min( pw_remains + class.abilities.primal_wrath.apply_duration, 1.3 * class.abilities.primal_wrath.apply_duration )

            local targets = ns.dumpNameplateInfo()
            for guid, counted in pairs( targets ) do
                if counted then
                    -- Use TTD info for enemies that are counted as targets
                    ttd = min( fight_remains, max( 1, Hekili:GetDeathClockByGUID( guid ) - ( offset + delay ) ) )

                    if dotted > 0 then
                        -- Dotted enemies use remaining ticks from previous primal wrath cast or target remains, whichever is shorter
                        remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( pw_remains, ttd ) / tick_time
                        dotted = dotted - 1
                    else
                        -- Fresh enemies have no remaining_ticks
                        remaining_ticks = 0
                        pw_duration = class.abilities.primal_wrath.apply_duration
                    end

                    potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( pw_duration, ttd ) / tick_time    

                    total = total + potential_ticks - remaining_ticks
                end
            end
            return max( 0, total )

        elseif action == "thrash_cat" then
            local fresh = max( 0, active_enemies - active_dot.thrash_cat )
            local dotted = max( 0, active_enemies - fresh )

            return max( 0, fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks ) )
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
                    return tick_calculator( t, t.key, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, t.key, true )
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
            max_stack = function () return pvptalent.wicked_claws.enabled and 2 or 1 end,
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
        lunar_inspiration = {
            id = 155625,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function() return mod_circle_dot( 2 ) * haste end,
            max_stack = 1,
            copy = "moonfire_cat",

            meta = {
                ticks_gained_on_refresh = function( t )
                    return tick_calculator( t, t.key, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, t.key, true )
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
                    return tick_calculator( t, t.key, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, t.key, true )
                end,
            }
        },
        ravenous_frenzy = {
            id = 323546,
            duration = 20,
            max_stack = 20,
        },
        ravenous_frenzy_sinful_hysteria = {
            id = 355315,
            duration = 5,
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
                    return tick_calculator( t, t.key, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, t.key, true )
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
                    return tick_calculator( t, t.key, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, t.key, true )
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

        high_winds = {
            id = 200931,
            duration = 4,
            max_stack = 1,
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
    local tf_spells = { rake = true, rip = true, thrash_cat = true, lunar_inspiration = true, primal_wrath = true }
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

        elseif spellID == a.lunar_inspiration.id then
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
            copy = "bt_lunar_inspiration"
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
        bt_moonfire = "lunar_inspiration",
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

    local SinfulHysteriaHandler = setfenv( function ()
        applyBuff( "ravenous_frenzy_sinful_hysteria" )
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

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
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
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", 0.3 )
            end

            if a >= 5 then
                applyBuff( "predatory_swiftness" )
            end
        end
    end

    spec:RegisterHook( "spend", comboSpender )



    local combo_generators = {
        brutal_slash      = true,
        feral_frenzy      = true,
        lunar_inspiration = true,
        rake              = true,
        shred             = true,
        swipe_cat         = true,
        thrash_cat        = true
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
                return talent.balance_affinity.enabled and settings.owlweave_cat or false
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif k == "primal_wrath" then return class.abilities.primal_wrath
            elseif k == "lunar_inspiration" then return debuff.lunar_inspiration
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

            toggle = "defensives",

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

            copy = { "berserk_cat", "bs_inc" }
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
                        return 25 * -0.3
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

            spend = function ()
                return 25 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132140,

            form = "cat_form",
            indicator = function ()
                if settings.cycle and target.time_to_die < longest_ttd then return "cycle" end
            end,            

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
                -- Support true/false or 1/0 through this awkward transition.
                if args.max_energy and ( type( args.max_energy ) == 'boolean' or args.max_energy > 0 ) then return 50 * ( buff.incarnation.up and 0.8 or 1 ) end
                return max( 25, min( 50 * ( buff.incarnation.up and 0.8 or 1 ), energy.current ) )
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

            usable = function () return buff.apex_predator.up or buff.apex_predators_craving.up or combo_points.current > 0 end,

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


        lunar_inspiration = {
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

            cycle = "lunar_inspiration",
            aura = "lunar_inspiration",

            handler = function ()
                applyDebuff( "target", "lunar_inspiration" )
                debuff.lunar_inspiration.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
                applyBuff( "bt_moonfire" )
                if will_proc_bloodtalons then proc_bloodtalons() end
            end,

            copy = { 8921, 155625, "moonfire_cat" }
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

            spend = function ()
                return 20 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 1392547,

            apply_duration = function ()
                return mod_circle_dot( 2 + 2 * combo_points.current )
            end,

            max_apply_duration = function ()
                return mod_circle_dot( 12 )
            end,

            ticks_gained_on_refresh = function()
                return tick_calculator( debuff.rip, "primal_wrath", false )
            end,

            ticks_gained_on_refresh_pmultiplier = function()
                return tick_calculator( debuff.rip, "primal_wrath", true )
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
                return mod_circle_dot( 4 + 4 * combo_points.current )
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
                    if legendary.cateye_curio.enabled then return 40 * -0.3 end
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
            cost = function () return max( 1, class.abilities.shred.spend ) end,

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
            cooldown = function () return pvptalent.freedom_of_the_herd.enabled and 60 or 120 end,
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
                    if legendary.cateye_curio.enabled then return 35 * -0.3 end
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
                    if legendary.cateye_curio.enabled then return 40 * -0.3 end
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
            -- texture = 538771,

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
                if not ( buff.moonkin_form.up or buff.treant_form.up ) then unshift() end
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
                },

                kindred_affinity = {
                    id = 357564,
                    duration = 3600,
                    max_stack = 1,
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
            cast = function () return legendary.celestial_spirits.enabled and 2 or 4 end,
            channeled = true,
            cooldown = function () return legendary.celestial_spirits.enabled and 60 or 120 end,
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

                if legendary.sinful_hysteria.enabled then
                    state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
                end        
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


    spec:RegisterPack( "Feral", 20210705, [[dSKJMbqiKQ8iKO6sQkQSjr0Nef0OqsofsQvjvjVsemlePBHiYUO4xIqdJOKJjv1Yef9meHPHuvxtvHTrukFtQs14qIsNtQsP1jkuZdjY9qu7dPYbreLwOufpuvrzIIcOnkkeFuuaojIOyLQQAMeLk3KOuv7ej8trbAOQkQQLIiQEkctLO4RQkQYyLQuSxs(lLgmOdlSyi9ysnzPCzuBwv(SOA0I0PLSArH0RvvA2eUTuz3Q8BGHtKJtuQYYv8COMovxhITlk9DKY4vvKZRQY6rII5tuTFLw1xjJIOfoROitzLzFz17Y6dJSOSFKj97DfH)tIvesH(BKZkIl6yfrgHNqOiKIFcq0uYOiWaKrZkIu3LWzCIjMxEkcQrd6sexDiIWlWPN45jIRoDIkcuKs4KmNcvr0cNvuKPSYSVS6Dz9Hrwu2pYK(kIaXtbJIGO6(mfrA1A8PqvengRvezeEcXcZahKQT))Ji(TWpiDHzkRm7V)3)zeEcXcjz)8LDluh3cdbgSquEHpaY1wy4lm1DjCgNyI5f2n5LNIGA0GUe7nXrzIjsu2OS9wzttz7T9wz79r808hAUF)pArqIqwu2w8E7)9)NLgxoJZ49pjTW2GundGMGghzzRoCY9xOoL1FXl0blSnivZaOjOXrw2Qd3S)jPf(zGllp(c7rMfkbac7WyaYO5f6GfslkFH8NKggJlWz2)K0cjzBTfwNZZGi5fQGxygrW4u9epFH1BH)ailmnYYl8aEAD5lKfyEHoyHnGrrikSJvYOiqfaqZdb4Wkzuu0xjJIGVavWnvpkIq7f4uet8Lve6PCEQqrq1cP3c9s)TU8fkx(cPAH9nzUWETqjEWf25ZTDicVKefplKoYlSbCZeFzJuhIWljrXZcPEHYLVqQwyO9klBrDRpvEop4fsEHzUWKlC43W40avWlK6fs9ctUquK3ZG62j(YMgG2Pi0)0c26XKZowrrFLROitLmkc(cub3u9OicTxGtriqUyS1HLQj8cCkc9uopvOig(nmonqf8ctUquK3ZG62oa4E1WMgG2Pi0)0c26XKZowrrFLROGekzue8fOcUP6rreAVaNIWtNaNA1HRi0t58uHIy43W40avWlm5crrEpdQB90jWPMgG2TWKlSnivZ4PtGtT6WnEP)IT5rDCZco7WVHXPlKUfs1cP)ctyHyjwiSEm5SJnE6e4uRo8f2Rfs)fs9ctCHuTW(lmHf2fyNNF2SHaHxi1lKKwOgCnKYnEGD2(aJfvaandFbQGBkc9pTGTEm5SJvu0x5kkOVsgfbFbQGBQEue6PCEQqrGI8Egu3IoiEiSyrGtnnaTtreAVaNIaDq8qyXIaNQCffFOKrrWxGk4MQhfHEkNNkueOiVNb1TyALeBAaA3ctUqSelewpMC2XgmTsIT6WxiDlSVIi0EbofbMwjXwD4kxrHSPKrrWxGk4MQhfHEkNNkueOiVNb1T40HBMgG2PicTxGtrGthUPCff9UsgfbFbQGBQEue6PCEQqrGI8Egu3IPvsSPbODkIq7f4ueyALeB1HRCffuwLmkc(cub3u9Oi0t58uHIaf59mOU1tNaNAAaANIi0EbofHNobo1Qdx5kxr8QRWP8OKrrrFLmkc(cub3u9OiEGXE8NCff9veH2lWPiKaaHDymaz0SYvuKPsgfbFbQGBQEue6PCEQqrGI8EgCKnYz7aIXmCxuhEHuAHKqreAVaNIahzJC2oGyuUIcsOKrrWxGk4MQhfHEkNNkueuTW2GunJ0uDHWsBcp14L(l2Mh1Xnl4Sd)ggNUq6wijwyVwivlelXcH1JjNDSrAQUqyPnHNUWewy)fs9ctUqSelewpMC2XgPP6cHL2eE6cPBH9xi1luU8fILyHW6XKZo2invxiS0MWtxiDlKQfsIfMWc7VWETqpe85gCGYJdaEQHVavWTfsTIi0EbofH0uDHWsBcpv5kkOVsgfbFbQGBQEueH2lWPiMssrONY5PcfXWVHXPbQGxyYf2gKQzMsY4L(l2Mh1Xnl4Sd)ggNUq6wy2yQavWMPKSEP)IxyYfs1cPAHOiVNXRCEW2hY8ZGiTq5Yxi9wOx6V1LVqQxyYfs1crrEpdQaaAEiah2GiTq5Yxi9wOhc(CdQaaAEiah2WxGk42cPEHYLVq6Tqpe85gCGYJdaEQHVavWTfs9ctUqQwiwIfcRhto7yJ0uDHWsBcpDHKxy)fkx(cP3c9qWNBKMQlewAt4Pg(cub3wi1lm5cPAHH2RSSTbCZuslK8cL1cLlFHEP)wx(ctUWq7vw22aUzkPfsEH9xOC5lKElCqo(bMC20Majp1TGNTXSK9b0iydFbQGBluU8fsVf6HGp3GduECaWtn8fOcUTqQve6FAbB9yYzhROOVYvu8HsgfbFbQGBQEue6PCEQqrGI8EgCKnYz7aIXmCxuhEHuAHuTqnOdfyLa154fMWc7VqQxyVwOSTWETqzziHIi0EbofboYg5SDaXOCffYMsgfbFbQGBQEueDXNS8Xt(pff9veH2lWPiE8a0fabBrlNve6FAbB9yYzhROOVYvu07kzue8fOcUP6rreAVaNI4XdqxaeSfTCwrONY5PcfbkY7zqX260gePfMCHEi4ZnyaIWcEwpLTpWWy3WxGk4MIq)tlyRhto7yff9vUYveOHionRKrrrFLmkc(cub3u9Oi0t58uHIaf59mSwusy2IbIymnaTBHjxikY7zyTOKWSvGCXyAaA3ctUqQw4WVHXPbQGxOC5lKQfgAVYYw(4UIXlKUf2FHjxyO9klBBa3GrUxn8cP0cdTxzzlFCxX4fs9cPwreAVaNIaJCVAyLROitLmkc(cub3u9Oi0t58uHIaf59mSwusy2IbIymd3f1HxiDluhy36vhVq5YxikY7zyTOKWSvGCXygUlQdVq6wOoWU1RowreAVaNIa7XGrMCw5kkiHsgfbFbQGBQEue6PCEQqrGI8EgwlkjmBfixmMH7I6WlKUfQdSB9QJxOC5ledeXyzTOKW8cPBHYsreAVaNIa7X8QHvUIc6RKrrWxGk4MQhfHEkNNkueOiVNH1IscZwmqeJz4UOo8cPBH6a7wV64fkx(cfixmwwlkjmVq6wOSueH2lWPiOnHNQCLRiA8lqeUsgff9vYOi4lqfCt1JIqpLZtfkcuK3Z0ba336SpW0zqKwyYfsVf2gKQza0e04ilB1HRicTxGtrmiNn0EboROWUIquy3ErhRiqdrCAw5kkYujJIGVavWnvpkc9uopvOiAds1maAcACKLT6WveH2lWPi0HqydTxGZkkSRief2Tx0XkcanbnoYYkxrbjuYOi4lqfCt1JIOXy9usEbofXN)aOjwiTu(4S8SqjagxOcwreAVaNIqAa0ekxrb9vYOi4lqfCt1JIqpLZtfkcuK3ZOd3(atNPbODkIq7f4ueELZd2(qMFkxrXhkzue8fOcUP6rrONY5PcfbkY7z0HBFGPZ0a0ofrO9cCkcD42hy6uUIcztjJIGVavWnvpkIgJ1tj5f4uezWJxiof4le7Ci8ufrO9cCkIb5SH2lWzff2ve6PCEQqrGI8EgCA0a06yrZGiTq5YxikY7zKganHbrsrikSBVOJveyNdHNQCff9UsgfrO9cCkc8xeHWIg4ufbFbQGBQEuUIckRsgfbFbQGBQEueH2lWPi0HqydTxGZkkSRief2Tx0XkcnaiAaANYvu0BvYOi4lqfCt1JIi0EbofXuskIgJ1tj5f4ueuW6biatlJx4NfyFHKyHGzH0FHAqhkyHsG68foLeEHGBH46Yf8c9yYzFHaehxnEHG3cr5bZZ3fcMf2qM6YxikpyE(UW6TWhpHyHVHpkZVfw4fIiTWmijFHHKK43cJf(HwAHK8sAH0s5BHYKrwyHxiI0cJRTqALqSqmaCl8fcXcbVNrrONY5PcfHgKLV4CZX6biatBHjxivlKEl0dbFUbvaanpeGdB4lqfCBHYLVquK3ZGkaGMhcWHnislK6fMCHyjwiSEm5SJnE6e4uRo8fsEH9xyYfs1c1GouGvcuNJxiDlmZfMCHd)ggNgOcEHjxyBqQMzkjJx6VyBEuh3SGZo8ByC6cPBHzJPcubBMsY6L(lEHYLVqnOdfyLa154fsEHFSWKlef59mELZd2(qMFgePfMCHOiVNXRCEW2hY8ZmCxuhEHuAHKyHjxyBqQMzkjJx6VyBEuh3SGZo8ByC6cPBHFSqQxyYfs1cP3crrEpdk2wN2GiTq5YxOgaenaTZGIT1PnisluU8fs1crrEpdk2wN2GiTWKludaIgG2zE8ec7B4JY8ZGiTqQxi1kxrrFzPKrrWxGk4MQhfHEkNNkueAqhkWkbQZXlKoYlKQf(XcjPfMnMkqfS5bqgTKfTCEHuRicTxGtrmiNn0EboROWUIquy3ErhRiE1v4uEuUII(9vYOi4lqfCt1JIqpLZtfkI2GunJ0uDHWsBcp14L(l2Mh1Xnl4Sd)ggNUq6iVWmL1ctUqnOdfyLa154fsh5fMPIi0EbofH0uDHWsBcpvriQJT6MI4dLROOFMkzue8fOcUP6rr0ySEkjVaNIq2hr4fjLRBle7Ci8ufrO9cCkcDie2q7f4SIc7kc9uopvOiqrEpdk2wN2GiPief2Tx0XkcSZHWtvUII(KqjJIGVavWnvpkIgJ1tj5f4ueYKYlSdG9fYFsIpCLLxypYSq9pTGxivYKomoDHePd3wibTsIxOgG9f2V)hlKpEY)r6c7IV8cXidVqA8c1XTWU4lVqpn8fw3cP)cZfa0qGPwrGzTIGQfs1c73)JfsslmtsSWETquK3ZuNoMl8cC2V1LBbpRNY2mkYLlydI0cPEHK0cPAH8Xt(pJgzg(8fMWcjH5Jf2RfYhp5)mdNZ3ctyHuTq6lRf2RfII8EgTGJrhyVUCdI0cPEHuVqQxyIlKpEY)zgoNpfrO9cCkcAr5kc9uopvOi8qWNBqfaqZdb4Wg(cub3wyYfII8Eguba08qaoSPbODlm5cdTxzzlQB9PYZ5bVqYluwkxrrF6RKrrWxGk4MQhfrJX6PK8cCkIq7f4WMg)ceHNa5eLaaHDymaz0mP1JShc(CdQaaAEiah2WxGk4wsuK3ZGkaGMhcWHnnaTljv8Xt(VeiH5JEXhp5)mdNZxcurFz1luK3ZOfCm6a71LBqKOMAkrv)(FqszsIEHI8EM60XCHxGZ(TUCl4z9u2MrrUCbBqKOozO9klBrDRpvEopyYYsreAVaNIyqoBO9cCwrHDfHEkNNkueEi4ZnOcaO5HaCydFbQGBlm5crrEpdQaaAEiah20a0ofHOWU9IowrGkaGMhcWHvUII(FOKrrWxGk4MQhfrO9cCkIhpaDbqWw0YzfHEkNNkueOiVNjK4pzLgUfoyWw9ezRl3GiPi0)0c26XKZowrrFLROOVSPKrrWxGk4MQhfXdm2J)KROOVIi0EbofHeaiSdJbiJMvUII(9UsgfbFbQGBQEueH2lWPiM4lRi0t58uHIGQfo8ByCAGk4fkx(cL4bxyNp32Hi8ssu8Sq6wyd4Mj(YgPoeHxsIINfs9ctUW2GunZeFzJx6VyBEuh3SGZo8ByC6cPBHyjwiSEm5SJnyALeB1HVWETWmxijTWmve6FAbB9yYzhROOVYvu0NYQKrrWxGk4MQhfrO9cCkcbYfJToSunHxGtrONY5PcfbvlC43W40avWluU8fkXdUWoFUTdr4LKO4zH0TWgWncKlgBDyPAcVaNrQdr4LKO4zHuVWKlSnivZiqUyS1HLQj8cCgV0FX28OoUzbND43W40fs3cXsSqy9yYzhBW0kj2QdFH9AHzUqsAHzQi0)0c26XKZowrrFLROOFVvjJIGVavWnvpkIhySh)jxrrFfrO9cCkcjaqyhgdqgnRCffzklLmkc(cub3u9OicTxGtr4PtGtT6Wve6PCEQqrm8ByCAGk4fMCHTbPAgpDcCQvhUXl9xSnpQJBwWzh(nmoDH0TqQwi9xyclelXcH1JjNDSXtNaNA1HVWETq6VqQxyIlKQf2FHjSWUa788ZMnei8cPEHK0c1GRHuUXdSZ2hySOcaOz4lqfCBHK0c1GS8fNBowpabyAlm5cPAH0BHOiVNbfBRtBqKwOC5lelXcH1JjNDSXtNaNA1HVq6wy)fsTIq)tlyRhto7yff9vUIIm7RKrrWxGk4MQhfXdm2J)KROOVIi0EbofHeaiSdJbiJMvUIImZujJIGVavWnvpkc9uopvOiOAHtunlNLp3eTg2u3cPBHuTW(lmHf2fFYQtJjNXlKKwOonMCgBFtO9cCHyHuVWETWH1PXKZwV64fs9ctUqQwiwIfcRhto7yd6G4HWIfboDH9AHH2lWzqhepewSiWPMw0f58ctCHH2lWzqhepewSiWPgna7lK6fs3cPAHH2lWzWPd3mTOlY5fM4cdTxGZGthUz0aSVqQveH2lWPiqhepewSiWPkxrrMKqjJIGVavWnvpkc9uopvOiWsSqy9yYzhBW0kj2QdFH0TW(lmHfII8EguSToTbrAH9AHzQicTxGtrGPvsSvhUYvuKj9vYOi4lqfCt1JIqpLZtfkcSelewpMC2XgpDcCQvh(cPBHKqreAVaNIWtNaNA1HRCffz(HsgfbFbQGBQEue6PCEQqrGI8EgTGJrhyVUCdI0ctUqQwikY7zWiTgF2OdfbNAAaA3ctUquK3ZGtJgGwhlAMgG2Tq5YxikY7zqX260gePfsTIi0EbofboD4MYvuKPSPKrrWxGk4MQhfrO9cCkIj(Ykc9uopvOiqrEpdk2wN2GiTWKlSnivZmXx24L(l2Mh1Xnl4Sd)ggNUq6wyMkc9pTGTEm5SJvu0x5kkYS3vYOi4lqfCt1JIi0EbofHoecBO9cCwrHDfHOWU9Iowr8kHGhLRCfH0WAqhA4kzuu0xjJIGVavWnvpkcGKIaZUIi0Ebofr2yQavWkISHaHveYsrKng7fDSI4bqgTKfTCw5kkYujJIGVavWnvpkcGKIaZUIi0Ebofr2yQavWkISHaHve9vengRNsYlWPiishUTqYluwKUqkahjHVqcNc8fsYJV8cjVW(KUqIlKWPaFHK84lVqYlmtsxOSJKzHKxijiDHe0kjEHKxi9vezJXErhRiELqWJYvuqcLmkc(cub3u9Oiaskcm7kIq7f4uezJPcubRiYgcewr07kIgJ1tj5f4uee6qWlKw5PlmnWoBuezJXErhRiMsY6L(lw5kkOVsgfrO9cCkIV11gUzXs1uowrWxGk4MQhLRO4dLmkIq7f4ueOa3fCZ(eXpUrRUCRd(uDkc(cub3u9OCffYMsgfbFbQGBQEue6PCEQqrGbic06AgjeSJiylpisEbodFbQGBluU8fIbic06AMSar4LGTyGilFUHVavWnfrO9cCkINGXP6jEUYvu07kzue8fOcUP6rrONY5PcfbkY7z6aG7BD2hy6mnaTtreAVaNIqAa0ekxrbLvjJIGVavWnvpkc9uopvOiqrEpthaCFRZ(atNPbODkIq7f4ue6WTpW0PCLRiELqWJsgff9vYOi4lqfCt1JIi0EbofXeFzfHEkNNkuezJPcubBELqWZcjVW(lm5ch(nmonqf8ctUWgWnt8LnsDicVKefplKsKxyFtMlSxluIhCHD(CBhIWljrXJIq)tlyRhto7yff9vUIImvYOi4lqfCt1JIqpLZtfkISXubQGnVsi4zHKxyMkIq7f4uet8LvUIcsOKrrWxGk4MQhfHEkNNkuezJPcubBELqWZcjVqsOicTxGtriqUyS1HLQj8cCkxrb9vYOi4lqfCt1JIqpLZtfkISXubQGnVsi4zHKxi9veH2lWPiW0kj2Qdx5kk(qjJIGVavWnvpkc9uopvOiqrEpdgP14ZgDOi4utdq7ueH2lWPiWPd3uUIcztjJIGVavWnvpkc9uopvOiWaebADnJec2reSLhejVaNHVavWTfkx(cXaebADntwGi8sWwmqKLp3WxGk4MIOoNNbrYT1trGbic06AMSar4LGTyGilFUIOoNNbrYTvxh3QWzfrFfrO9cCkINGXP6jEUIOoNNbrYT5caAiue9vUYveyNdHNQKrrrFLmkc(cub3u9OiEGXE8NCff9veH2lWPiKaaHDymaz0SYvuKPsgfbFbQGBQEueH2lWPiM4lRi0)0c26XKZowrrFfHEkNNkueuTWgWnt8LnsDicVKefplKslSV5Jfkx(ch(nmonqf8cPEHjxyBqQMzIVSXl9xSnpQJBwWzh(nmoDH0TWmxOC5lKQfkXdUWoFUTdr4LKO4zH0TWgWnt8LnsDicVKefplm5crrEpdk2wN2GiTWKlelXcH1JjNDSXtNaNA1HVqkTqsSWKludYYxCU5y9aeGPTqQxOC5lef59mOyBDAZWDrD4fsPf2xr0ySEkjVaNIGKhF5fEm3WlCai5PIFl8dz95wi4TWYXluWxUNUWWxySWU6QoKUf6GfIrgPaJxioD4gEHnjw5kkiHsgfbFbQGBQEue6PCEQqrGLyHW6XKZo24PtGtT6WxiLwijwyYfo8ByCAGk4fMCHTbPAgbYfJToSunHxGZ4L(l2Mh1Xnl4Sd)ggNUq6w4hlm5cPAHAqhkWkbQZXlK8cP)cLlFHnGBeixm26Ws1eEboZWDrD4fsPf(XcLlFH0BHnGBeixm26Ws1eEboJx6V1LVqQveH2lWPieixm26Ws1eEboLROG(kzue8fOcUP6rreAVaNIaDq8qyXIaNQiAmwpLKxGtr0ZG4HyHeIaNUWcVqu2DEwONg3cXohcpDHePd3wy4lKel0JjNDSIqpLZtfkcSelewpMC2Xg0bXdHflcC6cPBHzQCffFOKrrWxGk4MQhfXdm2J)KROOVIi0EbofHeaiSdJbiJMvUIcztjJIGVavWnvpkc9uopvOi0GouGvcuNJxiLwi9xyYfILyHW6XKZo24PtGtT6WxiLw4hkIq7f4ue40HBkx5kcnaiAaANsgff9vYOi4lqfCt1JIqrqfv0RbCt0cjVYYwmTy6STOlYzJx6V1LlxEd4MOfsELLTyAX0zBrxKZMH7I6WuktQtsvd4MOfsELLTyAX0zBrxKZgSh6VuIeYLtVgWnrlK8klBX0IPZMYHWG9q)LU(uNKEH2lWzIwi5vw2IPftNnLdHPo7tu5PEs6fAVaNjAHKxzzlMwmD2w0f5SPo7tu5PEs6fAVaNjAHKxzzlMwmDM6SprLN6uN0JjNDJxDS1b2wX09HC5H2RSSLpURymDzMKEnGBIwi5vw2IPftNTfDroB8s)TU8K8Xt(pkrIps6XKZUXRo26aBRy6(qreAVaNIiAHKxzzlMwmDkc9pTGTEm5SJvu0x5kkYujJIGVavWnvpkIq7f4uepEcH9n8rz(Pi0t58uHIqd6qbwjqDoEHuAHKyHjxOhto7gV6yRdSTIxiDlS3xyYfsVfQbardq7mELZd2(qMFgePfkx(cFvEQBhUlQdVqkTqk7ctUWxLN62H7I6WlKUfMPIq)tlyRhto7yff9vUIcsOKrrWxGk4MQhfrO9cCkcuEW88vr0ySEkjVaNIqMmygygmJxifm3wOdwi(3PxiTYtxiTYtx4ez5dGGx4B4JY8BH0s5BH04foi3cFdFuMFOX1iDHGzHHl4a7luNY6VlSElSC8cPbgpDHLRi0t58uHIqd6qbwjqDoEH0rEHKq5kkOVsgfbFbQGBQEue6PCEQqrObDOaReOohVq6iVqsOicTxGtruNoMl8cCkxrXhkzue8fOcUP6rreAVaNIWRCEW2hY8tr0ySEkjVaNIqM53cJRTWd4lKwGDEHYKrwiF8K)J0fII4lmeyWcZOiyFHiyEHLVWhywiLHNVlmU2cRthZHve6PCEQqrWhp5)mn(v6YxiDlK(YAHYLVquK3ZGIT1PnisluU8fs1c9qWNBKgUfoym8fOcUTWKleNcgNXU192cP0cjXcPw5kkKnLmkc(cub3u9OicTxGtrGtJgGwhlAkIgJ1tj5f4ueY(vEQVquEH0gWLVqhSqemVqIow0wi4wijp(YlSUfMLNFlmlp)w4v6uEH4YrcVahM0fII4lmlp)w4edl(Pi0t58uHIaf59mELZd2(qMFgePfMCHOiVNbfBRtBAaA3ctUqnOdfyLa154fsPfs)fMCHOiVNbJ0A8zJoueCQPbODlm5cBa3mXx2i1Hi8ssu8SqkTW(gzBHjxiF8K)BH0Tq6lRfMCHTbPAMj(YgV0FX28OoUzbND43W40fs3cXsSqy9yYzhBW0kj2QdFH9AHzUqsAHzUWKl0JjNDJxDS1b2wXlKUf(HYvu07kzue8fOcUP6rrONY5PcfbkY7z8kNhS9Hm)misluU8fII8EguSToTbrsreAVaNIaLhmpFRlx5kkOSkzue8fOcUP6rrONY5PcfbkY7zqX260gePfkx(crby8ctUWxLN62H7I6WlKsludaIgG2zqX260MH7I6WluU8fIcW4fMCHVkp1Td3f1HxiLwyMFOicTxGtrib8cCkxrrVvjJIGVavWnvpkc9uopvOiqrEpdk2wN2GiTq5Yx4RYtD7WDrD4fsPfMzFfrO9cCkIjYYhabBFdFuMFkxrrFzPKrrWxGk4MQhfrO9cCkcn4Yc(YwpLTyPAkhRiAmwpLKxGtritgmdmdMXl8Zsz93f2ba336wykWPTW4Ale7iV3cf1xEHEAHjDHX1wyx8dLxik7oplud6qdFHd3f1TWHX)oTIqpLZtfkcQwyd4MPKmd3f1HxiDlK(lm5c1GouGvcuNJxiLwijwyYf2aUzIVSXl936YxyYfYhp5)mn(v6YxiDKxyMYAHuVq5YxikaJxyYf(Q8u3oCxuhEHuAHFOCff97RKrrWxGk4MQhfrO9cCkcUtcqJhlk4AkIgJ1tj5f4ueY(XpuEHEkp8cXPaerBHO8c7adVqn4ALxGdVqWTqpLxOgCnKYve6PCEQqrGI8EgVY5bBFiZpdI0cLlFHuTqn4AiLBAmlzdHGZR40SHVavWTfsTYvu0ptLmkc(cub3u9OiAmwpLKxGtrKbuz5fknfyk)3cDWcbhjHG5fsJdjWPiUOJvezuGJC5CnJTXyVUFyRoecfHEkNNkueSShsjjXntgf4ixoxZyBm2R7h2QdHqreAVaNIiJcCKlNRzSng719dB1HqOCff9jHsgfrO9cCkcemBlN7Wkc(cub3u9OCLRia0e04ilRKrrrFLmkc(cub3u9Oi0t58uHIaf59mPCmUf8SEkBPvIMbrsreAVaNIa7XGrMCw5kkYujJIGVavWnvpkIq7f4ueyK7vdRie1XwDtrq)ELRBkxrbjuYOi4lqfCt1JIi0EbofrhaCVAyfHEkNNkueOiVNPdaUV1zFGPZGiTWKlKQfoih)atoB0HZ)yRgzkGHVavWTfkx(chKJFGjNnTjqYtDl4zBmlzFanc2WxGk42cPEHjxiwIfcRhto7yJNobo1QdFHuAHzUWKlKEl0dbFUrGCXyRdlvt4f4m8fOcUPie1XwDtrq)ELRBkxrb9vYOi4lqfCt1JIqpLZtfkc(4j)3cP0cjHSwyYf2aUzkjZWDrD4fs3cPV5JfMCHuTqnaiAaANXRCEW2hY8ZmCxuhEH0rEHYM5Jfkx(chKJFGjNn6W5FSvJmfWWxGk42cPEHjxikY7z0cogDG96Ynyp0FxiLwy)fMCH0BHOiVNjK4pzLgUfoyWw9ezRl3GiTWKlKElef59mOcaOjqWUbrAHjxi9wikY7zqX260gePfMCHuTqnaiAaANrdUSGVS1tzlwQMYXMH7I6WlKUfkBMpwOC5lKEludYYxCU5Q8u3(cEHuVWKlKQfsVfQbz5lo3CSEacW0wOC5ludaIgG2zIwi5vw2IPftNz4UOo8cPJ8c)yHYLVWgWnrlK8klBX0IPZ2IUiNnd3f1HxiDlS3xi1kIq7f4uePCmUf8SEkBPvIMYvu8HsgfbFbQGBQEue6PCEQqrWhp5)wiLwijK1ctUWgWntjzgUlQdVq6wi9nFSWKlKQfQbardq7mELZd2(qMFMH7I6WlKoYlK(MpwOC5lCqo(bMC2OdN)XwnYuadFbQGBlK6fMCHOiVNrl4y0b2Rl3G9q)DHuAH9xyYfsVfII8EMqI)KvA4w4GbB1tKTUCdI0ctUq6TquK3ZGkaGMab7gePfMCHuTq6TquK3ZGIT1PnisluU8fQbz5lo3CSEacW0wyYf6HGp3GJSroBhqmg(cub3wyYfII8EguSToTz4UOo8cPBHY2cPEHjxivludaIgG2z0Gll4lB9u2ILQPCSz4UOo8cPBHYM5Jfkx(cP3c1GS8fNBUkp1TVGxi1lm5cPAH0BHAqw(IZnhRhGamTfkx(c1aGObODMOfsELLTyAX0zgUlQdVq6iVWpwOC5lSbCt0cjVYYwmTy6STOlYzZWDrD4fs3c79fs9ctUqpMC2nE1XwhyBfVq6wyVRicTxGtr0ba336SpW0PCLRCfrwEWf4uuKPSYSVSOVSiHIGwmxD5yfXNhjljNcsgkYaY4fUqzs5fwDsGXx4dmlmdF1v4uEYWfoSShsnCBHyqhVWaXbDHZTfQtJlNXM9VSRoEH0pJx4NbUS84CBHz4GC8dm5SP3KHl0blmdhKJFGjNn9gdFbQGBz4cPQ)NO2S)3)FEKSKCkizOidiJx4cLjLxy1jbgFHpWSWmSXVar4z4chw2dPgUTqmOJxyG4GUW52c1PXLZyZ(x2vhVWmLvgVWpdCz5X52cjQUpBH4FNhFAHFUf6Gfk7qIf2QSfUa3cbs8eoywivjs9cPQ)NO2S)LD1XlmZmZ4f(zGllpo3wir19zle)784tl8ZTqhSqzhsSWwLTWf4wiqINWbZcPkrQxivz(jQn7)9)NhjljNcsgkYaY4fUqzs5fwDsGXx4dmlmdrfaqZdb4Wz4chw2dPgUTqmOJxyG4GUW52c1PXLZyZ(x2vhVqsKXl8ZaxwECUTqIQ7Zwi(35XNw4NBHoyHYoKyHTkBHlWTqGepHdMfsvIuVqQ6)jQn7)9)NhjljNcsgkYaY4fUqzs5fwDsGXx4dmlmdb0e04ilNHlCyzpKA42cXGoEHbId6cNBluNgxoJn7FzxD8cjrgVWpdCz5X52cZWb54hyYztVjdxOdwygoih)atoB6ng(cub3YWfsvMFIAZ(x2vhVq6NXl8ZaxwECUTWmCqo(bMC20BYWf6GfMHdYXpWKZMEJHVavWTmCHu1)tuB2)YU64f(rgVWpdCz5X52cZWb54hyYztVjdxOdwygoih)atoB6ng(cub3YWfsv)prTz)V)jz6KaJZTf2BxyO9cCluuyhB2)kcPb8kbRiOCkFHzeEcXcZahKQT)PCkFH)re)w4hKUWmLvM93)7FkNYxygHNqSqs2pFz3c1XTWqGbleLx4dGCTfg(ctDxcNXjMyEHDtE5PiOgnOlXEtCuMyIeLnkBVv20u2EBVv2EFepn)HM73)JweKiKfLTfV3(F)t5u(c)S04YzCgV)PCkFHK0cBds1maAcACKLT6Wj3FH6uw)fVqhSW2GundGMGghzzRoCZ(NYP8fssl8ZaxwE8f2Jmlucae2HXaKrZl0blKwu(c5pjnmgxGZS)PCkFHK0cjzBTfwNZZGi5fQGxygrW4u9epFH1BH)ailmnYYl8aEAD5lKfyEHoyHnGz)V)dTxGdBKgwd6qdpbYjMnMkqfmPx0XKFaKrlzrlNjnBiqyYYA)t5lKiD42cjVqzr6cPaCKe(cjCkWxijp(YlK8c7t6cjUqcNc8fsYJV8cjVWmjDHYosMfsEHKG0fsqRK4fsEH0F)hAVah2inSg0HgEcKtmBmvGkysVOJj)kHGhsZgceMC)9pLVqcDi4fsR80fMgyNn7)q7f4WgPH1Go0WtGCIzJPcubt6fDm5PKSEP)IjnBiqyY9((p0EboSrAynOdn8eiN436Ad3SyPAkhV)dTxGdBKgwd6qdpbYjIcCxWn7te)4gT6YTo4t1T)dTxGdBKgwd6qdpbYj(emovpXZjTEKXaebADnJec2reSLhejVaNHVavWn5YXaebADntwGi8sWwmqKLp3WxGk42(p0EboSrAynOdn8eiNO0aOjiTEKrrEpthaCFRZ(atNPbOD7)q7f4WgPH1Go0WtGCI6WTpW0rA9iJI8EMoa4(wN9bMotdq72)7)q7f4WKhKZgAVaNvuyN0l6yYOHiontA9iJI8EMoa4(wN9bModIus61gKQza0e04ilB1HV)dTxGdNa5e1HqydTxGZkkSt6fDmzanbnoYYKwpYTbPAganbnoYYwD47FkFHF(dGMyH0s5JZYZcLayCHk49FO9cC4eiNO0aOj2)H2lWHtGCIELZd2(qMFKwpYOiVNrhU9bMotdq72)H2lWHtGCI6WTpW0rA9iJI8EgD42hy6mnaTB)t5lmdE8cXPaFHyNdHNU)dTxGdNa5ehKZgAVaNvuyN0l6yYyNdHNsA9iJI8EgCA0a06yrZGijxokY7zKganHbrA)hAVahobYjI)Iiew0aNU)dTxGdNa5e1HqydTxGZkkSt6fDmznaiAaA3(NYxifSEacW0Y4f(zb2xijwiywi9xOg0HcwOeOoFHtjHxi4wiUUCbVqpMC2xiaXXvJxi4TquEW88DHGzHnKPU8fIYdMNVlSEl8Xtiw4B4JY8BHfEHislmdsYxyijj(TWyHFOLwijVKwiTu(wOmzKfw4fIiTW4AlKwjeleda3cFHqSqW7z2)H2lWHtGCItjrA9iRbz5lo3CSEacW0ssf98qWNBqfaqZdb4Wg(cub3Klhf59mOcaO5HaCydIe1jXsSqy9yYzhB80jWPwD4K7NKknOdfyLa15y6Ym5WVHXPbQGt2gKQzMsY4L(l2Mh1Xnl4Sd)ggNsx2yQavWMPKSEP)ILlxd6qbwjqDoM8hjrrEpJx58GTpK5NbrkjkY7z8kNhS9Hm)md3f1HPejs2gKQzMsY4L(l2Mh1Xnl4Sd)ggNs3huNKk6HI8EguSToTbrsUCnaiAaANbfBRtBqKKlNkuK3ZGIT1Pnisj1aGObODMhpHW(g(Om)misut9(p0EboCcKtCqoBO9cCwrHDsVOJj)QRWP8qA9iRbDOaReOohthzQ(GKYgtfOc28aiJwYIwot9(p0EboCcKtuAQUqyPnHNsA9i3gKQzKMQlewAt4PgV0FX28OoUzbND43W4u6iNPSsQbDOaReOohth5mjvuhB1nYFS)P8fk7Ji8IKY1TfIDoeE6(p0EboCcKtuhcHn0EboROWoPx0XKXohcpL06rgf59mOyBDAdI0(NYxOmP8c7ayFH8NK4dxz5f2Jmlu)tl4fsLmPdJtxir6WTfsqRK4fQbyFH97)Xc5JN8FKUWU4lVqmYWlKgVqDClSl(Yl0tdFH1Tq6VWCbaneyQ3)H2lWHtGCI0IYjfZAYurv)(FqszsIEHI8EM60XCHxGZ(TUCl4z9u2MrrUCbBqKOMKOIpEY)z0iZWNNajmF0l(4j)Nz4C(sGk6lREHI8EgTGJrhyVUCdIe1utDI8Xt(pZW58rA9i7HGp3GkaGMhcWHn8fOcULef59mOcaO5HaCytdq7sgAVYYwu36tLNZdMSS2)u(cdTxGdNa5eLaaHDymaz0mP1JShc(CdQaaAEiah2WxGk4wsuK3ZGkaGMhcWHnnaTljv8Xt(VeiH5JEXhp5)mdNZxcurFz1luK3ZOfCm6a71LBqKOMAkrv)(FqszsIEHI8EM60XCHxGZ(TUCl4z9u2MrrUCbBqKOozO9klBrDRpvEopyYYA)hAVahobYjoiNn0EboROWoPx0XKrfaqZdb4WKwpYEi4ZnOcaO5HaCydFbQGBjrrEpdQaaAEiah20a0U9FO9cC4eiN4JhGUaiylA5mP6FAbB9yYzhtUpP1JmkY7zcj(twPHBHdgSvpr26Ynis7)q7f4Wjqorjaqyhgdqgnt6dm2J)KtU)(p0EboCcKtCIVmP6FAbB9yYzhtUpP1Jmvd)ggNgOcwUCjEWf25ZTDicVKefp01aUzIVSrQdr4LKO4H6KTbPAMj(YgV0FX28OoUzbND43W4u6WsSqy9yYzhBW0kj2QdVxzsszU)dTxGdNa5efixm26Ws1eEbos1)0c26XKZoMCFsRhzQg(nmonqfSC5s8GlSZNB7qeEjjkEORbCJa5IXwhwQMWlWzK6qeEjjkEOozBqQMrGCXyRdlvt4f4mEP)IT5rDCZco7WVHXP0HLyHW6XKZo2GPvsSvhEVYKKYC)hAVahobYjkbac7WyaYOzsFGXE8NCY93)H2lWHtGCIE6e4uRoCs1)0c26XKZoMCFsRh5HFdJtdubNSnivZ4PtGtT6WnEP)IT5rDCZco7WVHXP0rf9talXcH1JjNDSXtNaNA1H3l6t9NJQ(j0fyNNF2SHaHPMK0GRHuUXdSZ2hySOcaOz4lqfCJK0GS8fNBowpabyAjPIEOiVNbfBRtBqKKlhlXcH1JjNDSXtNaNA1HtxFQ3)H2lWHtGCIsaGWomgGmAM0hySh)jNC)9FO9cC4eiNi6G4HWIfboL06rMQjQMLZYNBIwdBQJoQ6Nqx8jRonMCgts60yYzS9nH2lWfcQ71W60yYzRxDm1jPclXcH1JjNDSbDq8qyXIaN2Rq7f4mOdIhclwe4utl6IC(ZfAVaNbDq8qyXIaNA0aStnDufAVaNbNoCZ0IUiN)CH2lWzWPd3mAa2PE)hAVahobYjIPvsSvhoP1JmwIfcRhto7ydMwjXwD401pbuK3ZGIT1Pnis9kZ9FO9cC4eiNONobo1QdN06rglXcH1JjNDSXtNaNA1Hthj2)H2lWHtGCI40HBKwpYOiVNrl4y0b2Rl3GiLKkuK3ZGrAn(Srhkco10a0UKOiVNbNgnaTow0mnaTtUCuK3ZGIT1PnisuV)dTxGdNa5eN4ltQ(NwWwpMC2XK7tA9iJI8EguSToTbrkzBqQMzIVSXl9xSnpQJBwWzh(nmoLUm3)H2lWHtGCI6qiSH2lWzff2j9IoM8RecE2)7)q7f4Wguba08qaom5j(YKQ)PfS1JjNDm5(KwpYurpV0FRlxUCQ6BYSxs8GlSZNB7qeEjjkEOJCd4Mj(YgPoeHxsIIhQLlNQq7vw2I6wFQ8CEWKZm5WVHXPbQGPM6KOiVNb1Tt8LnnaTB)hAVah2GkaGMhcWHtGCIcKlgBDyPAcVahP6FAbB9yYzhtUpP1J8WVHXPbQGtII8Egu32ba3Rg20a0U9FO9cCydQaaAEiahobYj6PtGtT6Wjv)tlyRhto7yY9jTEKh(nmonqfCsuK3ZG6wpDcCQPbODjBds1mE6e4uRoCJx6VyBEuh3SGZo8ByCkDur)eWsSqy9yYzhB80jWPwD49I(u)5OQFcDb255NnBiqyQjjn4AiLB8a7S9bglQaaAg(cub32)H2lWHnOcaO5HaC4eiNi6G4HWIfboL06rgf59mOUfDq8qyXIaNAAaA3(p0EboSbvaanpeGdNa5eX0kj2QdN06rgf59mOUftRKytdq7sILyHW6XKZo2GPvsSvhoD93)H2lWHnOcaO5HaC4eiNioD4gP1JmkY7zqDloD4MPbOD7)q7f4Wguba08qaoCcKtetRKyRoCsRhzuK3ZG6wmTsInnaTB)hAVah2GkaGMhcWHtGCIE6e4uRoCsRhzuK3ZG6wpDcCQPbOD7)9FO9cCyJgaenaTJC0cjVYYwmTy6iv)tlyRhto7yY9jLmvurVgWnrlK8klBX0IPZ2IUiNnEP)wxUC5nGBIwi5vw2IPftNTfDroBgUlQdtPmPojvnGBIwi5vw2IPftNTfDroBWEO)sjsixo9Aa3eTqYRSSftlMoBkhcd2d9x66tDs6fAVaNjAHKxzzlMwmD2uoeM6SprLN6jPxO9cCMOfsELLTyAX0zBrxKZM6SprLN6jPxO9cCMOfsELLTyAX0zQZ(evEQtDspMC2nE1XwhyBft3hYLhAVYYw(4UIX0Lzs61aUjAHKxzzlMwmD2w0f5SXl936YtYhp5)Oej(iPhto7gV6yRdSTIP7J9FO9cCyJgaenaTlbYj(4je23WhL5hP6FAbB9yYzhtUpP1JSg0HcSsG6CmLirspMC2nE1XwhyBftxVNKEAaq0a0oJx58GTpK5NbrsU8xLN62H7I6WuIYM8v5PUD4UOomDzU)P8fktgmdmdMXlKcMBl0ble)70lKw5PlKw5PlCIS8bqWl8n8rz(TqAP8TqA8chKBHVHpkZp04AKUqWSWWfCG9fQtz93fwVfwoEH0aJNUWY3)H2lWHnAaq0a0UeiNikpyE(sA9iRbDOaReOohthzsS)dTxGdB0aGObODjqoX60XCHxGJ06rwd6qbwjqDoMoYKy)t5luM53cJRTWd4lKwGDEHYKrwiF8K)J0fII4lmeyWcZOiyFHiyEHLVWhywiLHNVlmU2cRthZH3)H2lWHnAaq0a0UeiNOx58GTpK5hP1JmF8K)Z04xPlNo6ll5YrrEpdk2wN2GijxovEi4Znsd3chmg(cub3sItbJZy36EJsKG69pLVqz)kp1xikVqAd4YxOdwicMxirhlAleClKKhF5fw3cZYZVfMLNFl8kDkVqC5iHxGdt6crr8fMLNFlCIHf)2)H2lWHnAaq0a0UeiNionAaADSOrA9iJI8EgVY5bBFiZpdIusuK3ZGIT1PnnaTlPg0HcSsG6CmLOFsuK3ZGrAn(Srhkco10a0UKnGBM4lBK6qeEjjkEOuFJSLKpEY)rh9LvY2GunZeFzJx6VyBEuh3SGZo8ByCkDyjwiSEm5SJnyALeB1H3RmjPmt6XKZUXRo26aBRy6(y)hAVah2Obardq7sGCIO8G55BD5KwpYOiVNXRCEW2hY8ZGijxokY7zqX260geP9FO9cCyJgaenaTlbYjkb8cCKwpYOiVNbfBRtBqKKlhfGXjFvEQBhUlQdtjnaiAaANbfBRtBgUlQdlxokaJt(Q8u3oCxuhMsz(X(p0EboSrdaIgG2La5eNilFaeS9n8rz(rA9iJI8EguSToTbrsU8xLN62H7I6WukZ(7FkFHYKbZaZGz8c)Suw)DHDaW9TUfMcCAlmU2cXoY7Tqr9LxONwysxyCTf2f)q5fIYUZZc1Go0Wx4WDrDlCy8VtV)dTxGdB0aGObODjqorn4Yc(YwpLTyPAkhtA9itvd4MPKmd3f1HPJ(j1GouGvcuNJPejs2aUzIVSXl936YtYhp5)mn(v6YPJCMYIA5YrbyCYxLN62H7I6Wu6J9pLVqz)4hkVqpLhEH4uaIOTquEHDGHxOgCTYlWHxi4wONYludUgs57)q7f4WgnaiAaAxcKtK7Ka04XIcUgP1JmkY7z8kNhS9Hm)misYLtLgCnKYnnMLSHqW5vCA2WxGk4g17FkFHzavwEHstbMY)TqhSqWrsiyEH04qcC7)q7f4WgnaiAaAxcKtebZ2Y5osVOJjNrboYLZ1m2gJ96(HT6qiiTEKzzpKssIBMmkWrUCUMX2ySx3pSvhcX(p0EboSrdaIgG2La5erWSTCUdV)3)H2lWHnVsi4H8eFzs1)0c26XKZoMCFsRh5SXubQGnVsi4HC)Kd)ggNgOcozd4Mj(YgPoeHxsIIhkrUVjZEjXdUWoFUTdr4LKO4z)hAVah28kHGNeiN4eFzsRh5SXubQGnVsi4HCM7)q7f4WMxje8Ka5efixm26Ws1eEbosRh5SXubQGnVsi4Hmj2)H2lWHnVsi4jbYjIPvsmP1JC2yQavWMxje8qM(7)q7f4WMxje8Ka5eXPd3iTEKrrEpdgP14ZgDOi4utdq72)H2lWHnVsi4jbYj(emovpXZjTEKXaebADnJec2reSLhejVaNHVavWn5YXaebADntwGi8sWwmqKLp3WxGk4gP158misUT664wfotUpP158misUnxaqdb5(KwNZZGi526rgdqeO11mzbIWlbBXarw(89)(p0EboS5vxHt5HSeaiSdJbiJMj9bg7XFYj3F)hAVah28QRWP8Ka5eXr2iNTdigsRhzuK3ZGJSroBhqmMH7I6WuIe7)q7f4WMxDfoLNeiNO0uDHWsBcpL06rMQ2GunJ0uDHWsBcp14L(l2Mh1Xnl4Sd)ggNshj6fvyjwiSEm5SJnst1fclTj80e6tDsSelewpMC2XgPP6cHL2eEkD9PwUCSelewpMC2XgPP6cHL2eEkDurIe63lpe85gCGYJdaEQHVavWnQ3)H2lWHnV6kCkpjqoXPKiv)tlyRhto7yY9jTEKh(nmonqfCY2GunZusgV0FX28OoUzbND43W4u6YgtfOc2mLK1l9xCsQOcf59mELZd2(qMFgej5YPNx6V1LtDsQqrEpdQaaAEiah2Gijxo98qWNBqfaqZdb4Wg(cub3OwUC65HGp3GduECaWtn8fOcUrDsQWsSqy9yYzhBKMQlewAt4PK7lxo98qWNBKMQlewAt4Pg(cub3OojvH2RSSTbCZusKLLC5EP)wxEYq7vw22aUzkjY9LlNEdYXpWKZM2ei5PUf8SnMLSpGgblxo98qWNBWbkpoa4Pg(cub3OE)hAVah28QRWP8Ka5eXr2iNTdigsRhzuK3ZGJSroBhqmMH7I6WuIknOdfyLa154e6tDVKTEjldj2)H2lWHnV6kCkpjqoXhpaDbqWw0Yzs7Ipz5JN8FK7tQ(NwWwpMC2XK7V)dTxGdBE1v4uEsGCIpEa6cGGTOLZKQ)PfS1JjNDm5(KwpYOiVNbfBRtBqKs6HGp3Gbicl4z9u2(adJDdFbQGB7)9FO9cCydGMGghzzYypgmYKZKwpYOiVNjLJXTGN1tzlTs0mis7)q7f4WganbnoYYjqormY9QHjvuhB1nY0Vx562(p0EboSbqtqJJSCcKtSdaUxnmPI6yRUrM(9kx3iTEKrrEpthaCFRZ(atNbrkjvdYXpWKZgD48p2QrMcix(GC8dm5SPnbsEQBbpBJzj7dOrWuNelXcH1JjNDSXtNaNA1HtPmtsppe85gbYfJToSunHxGZWxGk42(p0EboSbqtqJJSCcKtmLJXTGN1tzlTs0iTEK5JN8FuIeYkzd4MPKmd3f1HPJ(MpssLgaenaTZ4vopy7dz(zgUlQdthzzZ8HC5dYXpWKZgD48p2QrMcqDsuK3ZOfCm6a71LBWEO)sP(jPhkY7zcj(twPHBHdgSvpr26YnisjPhkY7zqfaqtGGDdIus6HI8EguSToTbrkjvAaq0a0oJgCzbFzRNYwSunLJnd3f1HPt2mFixo90GS8fNBUkp1TVGPojv0tdYYxCU5y9aeGPjxUgaenaTZeTqYRSSftlMoZWDrDy6i)HC5nGBIwi5vw2IPftNTfDroBgUlQdtxVt9(p0EboSbqtqJJSCcKtSdaUV1zFGPJ06rMpEY)rjsiRKnGBMsYmCxuhMo6B(ijvAaq0a0oJx58GTpK5Nz4UOomDKPV5d5YhKJFGjNn6W5FSvJmfG6KOiVNrl4y0b2Rl3G9q)Ls9tspuK3Zes8NSsd3chmyREIS1LBqKsspuK3ZGkaGMab7gePKurpuK3ZGIT1PnisYLRbz5lo3CSEacW0s6HGp3GJSroBhqmg(cub3sII8EguSToTz4UOomDYg1jPsdaIgG2z0Gll4lB9u2ILQPCSz4UOomDYM5d5YPNgKLV4CZv5PU9fm1jPIEAqw(IZnhRhGamn5Y1aGObODMOfsELLTyAX0zgUlQdth5pKlVbCt0cjVYYwmTy6STOlYzZWDrDy66DQt6XKZUXRo26aBRy6699)(p0EboSb7Ci8uYsaGWomgGmAM0hySh)jNC)9pLVqsE8Lx4XCdVWbGKNk(TWpK1NBHG3clhVqbF5E6cdFHXc7QR6q6wOdwigzKcmEH40HB4f2K49FO9cCyd25q4PjqoXj(YKQ)PfS1JjNDm5(KwpYu1aUzIVSrQdr4LKO4Hs9nFix(WVHXPbQGPozBqQMzIVSXl9xSnpQJBwWzh(nmoLUmLlNkjEWf25ZTDicVKefp01aUzIVSrQdr4LKO4jjkY7zqX260gePKyjwiSEm5SJnE6e4uRoCkrIKAqw(IZnhRhGamnQLlhf59mOyBDAZWDrDyk1F)hAVah2GDoeEAcKtuGCXyRdlvt4f4iTEKXsSqy9yYzhB80jWPwD4uIejh(nmonqfCY2GunJa5IXwhwQMWlWz8s)fBZJ64MfC2HFdJtP7JKuPbDOaReOohtM(YL3aUrGCXyRdlvt4f4md3f1HP0hYLtVgWncKlgBDyPAcVaNXl936YPE)t5lSNbXdXcjeboDHfEHOS78SqpnUfIDoeE6cjshUTWWxijwOhto749FO9cCyd25q4Pjqor0bXdHflcCkP1JmwIfcRhto7yd6G4HWIfboLUm3)H2lWHnyNdHNMa5eLaaHDymaz0mPpWyp(to5(7)q7f4WgSZHWttGCI40HBKwpYAqhkWkbQZXuI(jXsSqy9yYzhB80jWPwD4u6J9)(p0EboSbneXPzYyK7vdtA9iJI8EgwlkjmBXarmMgG2Lef59mSwusy2kqUymnaTljvd)ggNgOcwUCQcTxzzlFCxXy66Nm0ELLTnGBWi3RgMsH2RSSLpURym1uV)dTxGdBqdrCAobYjI9yWitotA9iJI8EgwlkjmBXarmMH7I6W0PdSB9QJLlhf59mSwusy2kqUymd3f1HPthy36vhV)dTxGdBqdrCAobYjI9yE1WKwpYOiVNH1IscZwbYfJz4UOomD6a7wV6y5YXarmwwlkjmtNS2)H2lWHnOHionNa5ePnHNsA9iJI8EgwlkjmBXarmMH7I6W0PdSB9QJLlxGCXyzTOKWmDYsrGLyTII(YIekx5kf]] )


end
