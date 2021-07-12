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

        eclipse.reset()

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
            cast = function () return legendary.celestial_spirits.enabled and 3 or 4 end,
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


    spec:RegisterPack( "Feral", 20210712, [[dS0ZNbqiIcpcjPUeIiztusFsuKgfr4uerRsQiVIO0SqKULQISlk(fLOHrj4ysLwMOWZqeMgrrxtvHTrjKVjvunoKK05KkkwNOOAEijUhIAFejheruAHsfEiIiMOOi0gfffFuueCserXkvv1mPek3KsOQDIK6NIIOHIis1srevpfHPsK6RiIugRurP9sYFfzWahwyXq6XKAYs5YO2SQ8zr1OPuNwYQffLETQkZMWTLQ2Tk)g0WrQJtjuz5k9COMovxhITlk9DKy8QkQZRQ06rsI5tuTFfR6QKwr0cNvuNHfYORf68Uzy62z6sIpKPIW)sZkc6q)lYzfXf9SIiZWBiue0XxbmAkPveyiYQzfHT704m3slZl3gb1OH9wIREer4f80B8ClXvV2sfbksjCsMtHQiAHZkQZWcz01cDE3mmDPQzqvjbvvreiUnCveevpjrryxTgFkufrJXAfrMH3qmGmXfPAZ))iIVdOBgKoGmSqgDN)Z)mdVHyaKSK0Tydqh3acbgoauEapiY1gq4dW2DACMBPL5f2n5LBJGA0WEl7SXrvInS0IOQDglstv7mDgl69r808hAUB3pArqIWcu1w8EZ)5pjXoUCgN5Z)pnG2IundKIGchz5KoCYDhG2M1)WdWHdOTivZaPiOWrwoPd3m))0aijWllV(a6q6bqdHI0YyiYQ5b4WbqjkFa8NPxgJl4zM)FAaKST2aQZ5DrO9cvWdiZiySTEJNpG6nGVqKbyhz5bCq3UU8bWcmpahoGg0Oief2XkPveOciS5HaEyL0kQ7QKwrWxGk4MQdfrO9cEkIn(Xkc9woVvOiKyaYyaEP)vx(aKlFasmGUMmgqNganV4c785PEeHx0II3bif5b0GUzJFSHUhr4fTO4Dasoa5YhGedi0ELLtOEY3kpNx8aipGmgG1bS8BzSDGk4bi5aKCawhakY7zq90g)ytds5ue6VAbN8yZzhROURYvuNHsAfbFbQGBQoueH2l4PieixSP6W01gEbpfHElN3kuel)wgBhOcEawhakY7zq9upeEVAztds5ue6VAbN8yZzhROURYvutcL0kc(cub3uDOicTxWtr42BGTt6Wve6TCERqrS8BzSDGk4byDaOiVNb1tU9gyBtds5gG1b0wKQzC7nW2jD4gV0)WP8OoULGxA53Yy7bi1aKyaYCaYoamnlejp2C2Xg3EdSDsh(a60aK5aKCawoajgq3bi7a6dSZ73u2qGWdqYb8PbOHxdPCJhyNtp4MqfqyZWxGk4MIq)vl4KhBo7yf1DvUIAzQKwrWxGk4MQdfHElN3kueOiVNb1tOlIhIeweyBtds5ueH2l4PiqxepejSiW2kxr9hkPve8fOcUP6qrO3Y5TcfbkY7zq9eMsrZMgKYnaRdatZcrYJnNDSbtPO5Ko8bi1a6QicTxWtrGPu0CshUYvuBrkPve8fOcUP6qrO3Y5TcfbkY7zq9e2E5MPbPCkIq7f8uey7LBkxrDNRKwrWxGk4MQdfHElN3kueOiVNb1tykfnBAqkNIi0EbpfbMsrZjD4kxrnvvjTIGVavWnvhkc9woVvOiqrEpdQNC7nW2MgKYPicTxWtr42BGTt6WvUYveV6kSnVkPvu3vjTIGVavWnvhkIhCth)zxrDxfrO9cEkcAiuKwgdrwnRCf1zOKwrWxGk4MQdfHElN3kueOiVNbhzJCoTWynl3h1HhavgajueH2l4PiWr2iNtlmwLROMekPve8fOcUP6qrO3Y5TcfHedOTivZqVvFisu2WTnEP)Ht5rDClbV0YVLX2dqQbqIb0PbiXaW0SqK8yZzhBO3QpejkB42dq2b0DasoaRdatZcrYJnNDSHER(qKOSHBpaPgq3bi5aKlFayAwisES5SJn0B1hIeLnC7bi1aKyaKyaYoGUdOtdWdbFUbhO86qOBB4lqfCBasQicTxWtrqVvFisu2WTvUIAzQKwrWxGk4MQdfrO9cEkITOve6TCERqrS8BzSDGk4byDaTfPAMTOnEP)Ht5rDClbV0YVLX2dqQbKn2kqfSzl6Kx6F4byDasmajgakY7z8kNxC6HSFni0dqU8biJb4L(xD5dqYbyDasmauK3ZGkGWMhc4Hni0dqU8biJb4HGp3GkGWMhc4Hn8fOcUnajhGC5dqgdWdbFUbhO86qOBB4lqfCBasoaRdqIbGPzHi5XMZo2qVvFisu2WTha5b0DaYLpazmape85g6T6drIYgUTHVavWTbi5aSoajgqO9klNAq3Sf9aipalma5YhGx6F1LpaRdi0ELLtnOB2IEaKhq3bix(aKXawKJFWnNnTnqYT9e8LAmtNEqnc2WxGk42aKlFaYyaEi4Zn4aLxhcDBdFbQGBdqsfH(RwWjp2C2XkQ7QCf1FOKwrWxGk4MQdfHElN3kueOiVNbhzJCoTWynl3h1HhavgGedqd7rHjAyDoEaYoGUdqYb0PbyrdOtdWcgsOicTxWtrGJSroNwySkxrTfPKwrWxGk4MQdfrF85eF8M)vrDxfrO9cEkIhVqDbrWj0YzfH(RwWjp2C2XkQ7QCf1DUsAfbFbQGBQoueH2l4PiE8c1febNqlNve6TCERqrGI8EguCQoTbHEawhGhc(CdgIisWxYT50dUm2n8fOcUPi0F1co5XMZowrDxLRCfbAiItZkPvu3vjTIGVavWnvhkc9woVvOiqrEpdRffnMtyOiwtds5gG1bGI8EgwlkAmNeixSMgKYnaRdqIbS8BzSDGk4bix(aKyaH2RSCIpUVy8aKAaDhG1beAVYYPg0nyK7vlpaQmGq7vwoXh3xmEasoajveH2l4PiWi3Rww5kQZqjTIGVavWnvhkc9woVvOiqrEpdRffnMtyOiwZY9rD4bi1a6AHbi7a0b2tE1ZdqU8bGI8EgwlkAmNeixSML7J6WdqQb01cdq2bOdSN8QNveH2l4PiWESyKnNvUIAsOKwrWxGk4MQdfHElN3kueOiVNH1IIgZjbYfRz5(Oo8aKAa6a7jV65bix(aqrEpdRffnMtyOiwtds5gG1bGHIytSwu0yEasnalma5YhakY7zyTOOXCcdfXAAqk3aSoabYfBI1IIgZd4tdi0EbpdLnCBtDPNOYT9bqLb0vreAVGNIa7X(QLvUIAzQKwrWxGk4MQdfHElN3kueOiVNH1IIgZjmueRz5(Oo8aKAa6a7jV65bix(aqrEpdRffnMtcKlwtds5gG1biqUytSwu0yEaFAaH2l4zOSHBBQl9evUTpaPgGfueH2l4PiOSHBRCLRiA8lqeUsAf1DvsRi4lqfCt1HIqVLZBfkcuK3Z0dH3V6sp42BqOhG1biJb0wKQzGueu4ilN0HRicTxWtrSixk0EbVKOWUIquypDrpRiqdrCAw5kQZqjTIGVavWnvhkc9woVvOiAls1mqkckCKLt6WveH2l4Pi0HqKcTxWljkSRief2tx0ZkcifbfoYYkxrnjusRi4lqfCt1HIOXy9w0Ebpfbj9fsrmak28Xz5Da0qmUqfSIi0Ebpfb9cPiuUIAzQKwrWxGk4MQdfHElN3kueOiVNjUVPhC7nniLtreAVGNIWRCEXPhY(v5kQ)qjTIGVavWnvhkc9woVvOiqrEptCFtp42BAqkNIi0EbpfHo80dU9kxrTfPKwrWxGk4MQdfrJX6TO9cEkIm5XdaBd9bGDoeUTIi0EbpfXICPq7f8sIc7kc9woVvOiqrEpd2oAqk9SOzqOhGC5daf59m0lKIWGqRief2tx0ZkcSZHWTvUI6oxjTIi0Ebpfb(hIqKqdSTIGVavWnvhkxrnvvjTIGVavWnvhkIq7f8ue6qisH2l4Lef2veIc7Pl6zfHgcfniLt5kQ7mkPve8fOcUP6qr0ySElAVGNIGAwVqbCBz(aijb2hajgaChGmhGg2JchanSoFaBrJha8gaUUCbpap2C2haeXXvJha8nauEX8(BaWDanKTU8bGYlM3FdOEd4XBigWB5JQ8DafEai0ditsYhqqtl(oGyaFOPhajVOhafB(gG0zMbu4bGqpG4AdGsjedadH3aEHqma47zue6TCERqrOHz5lo3CSEHc42gG1biXaKXa8qWNBqfqyZdb8Wg(cub3gGC5daf59mOciS5HaEydc9aKCawhaMMfIKhBo7yJBVb2oPdFaKhq3byDasmanShfMOH154bi1aYyawhWYVLX2bQGhG1b0wKQz2I24L(hoLh1XTe8sl)wgBpaPgq2yRavWMTOtEP)HhGC5dqd7rHjAyDoEaKhWhdW6aqrEpJx58ItpK9RbHEawhakY7z8kNxC6HSFnl3h1HhavgajgG1b0wKQz2I24L(hoLh1XTe8sl)wgBpaPgWhdqYbyDasmazmauK3ZGIt1Pni0dqU8bOHqrds5mO4uDAdc9aKlFasmauK3ZGIt1Pni0dW6a0qOObPCMhVHi9w(OkFni0dqYbiPIi0EbpfXw0kxrDxlOKwrWxGk4MQdfHElN3kueAypkmrdRZXdqkYdqIb8Xa(0aYgBfOc28GiRMoHwopajveH2l4PiwKlfAVGxsuyxrikSNUONveV6kSnVkxrD3UkPve8fOcUP6qrO3Y5TcfrBrQMHER(qKOSHBB8s)dNYJ64wcEPLFlJThGuKhqgwyawhGg2Jct0W6C8aKI8aYqreAVGNIGER(qKOSHBRie1XjDtr8HYvu3ndL0kc(cub3uDOiAmwVfTxWtryXJi86t562aWohc3wreAVGNIqhcrk0EbVKOWUIqVLZBfkcuK3ZGIt1Pni0kcrH90f9SIa7CiCBLROUljusRi4lqfCt1HIOXy9w0EbpfH028a6HyFa8NP5dxz5b0H0dq)vl4biH02lJThaH9YTbqqPO5bOHyFaD7(Xa4J38VKoG(4hpamYYdGcpaDCdOp(XdWTdFa1nazoGCbeneyjveywRiKyasmGUD)yaFAazqIb0PbGI8EM60XEHxWl9RU8e8LCBoLzrUCbBqOhGKd4tdqIbWhV5FnAKD5ZhGSdGeMpgqNgaF8M)1SCoFdq2biXaKPfgqNgakY7z0cowDG96Yni0dqYbi5aKCawoa(4n)Rz5C(ueH2l4PiOeLRi0B58wHIWdbFUbvaHnpeWdB4lqfCBawhakY7zqfqyZdb8WMgKYnaRdi0ELLtOEY3kpNx8aipalOCf1DLPsAfbFbQGBQouengR3I2l4PicTxWdBA8lqeUSKTKgcfPLXqKvZKwpYEi4ZnOciS5HaEydFbQGBwrrEpdQacBEiGh20GuoRsWhV5FLLeMp6eF8M)1SCoFYkHmTqNqrEpJwWXQdSxxUbHwsjPIeD7(XNYGeDcf59m1PJ9cVGx6xD5j4l52CkZIC5c2GqlP1q7vwoH6jFR8CEXKTGIi0EbpfXICPq7f8sIc7kc9woVvOi8qWNBqfqyZdb8Wg(cub3gG1bGI8Egube28qapSPbPCkcrH90f9SIavaHnpeWdRCf1D)qjTIGVavWnvhkIq7f8uepEH6cIGtOLZkc9woVvOiqrEptqZForVClC4It6nYwxUbHwrO)QfCYJnNDSI6UkxrDxlsjTIGVavWnvhkIhCth)zxrDxfrO9cEkcAiuKwgdrwnRCf1D7CL0kc(cub3uDOicTxWtrSXpwrO3Y5TcfHedy53Yy7avWdqU8bqZlUWoFEQhr4fTO4DasnGg0nB8Jn09icVOffVdqYbyDaTfPAMn(XgV0)WP8OoULGxA53Yy7bi1aW0SqK8yZzhBWukAoPdFaDAazmGpnGmue6VAbN8yZzhROURYvu3LQQKwrWxGk4MQdfrO9cEkcbYfBQomDTHxWtrO3Y5TcfHedy53Yy7avWdqU8bqZlUWoFEQhr4fTO4DasnGg0ncKl2uDy6AdVGNHUhr4fTO4DasoaRdOTivZiqUyt1HPRn8cEgV0)WP8OoULGxA53Yy7bi1aW0SqK8yZzhBWukAoPdFaDAazmGpnGmue6VAbN8yZzhROURYvu3TZOKwrWxGk4MQdfXdUPJ)SROURIi0EbpfbnekslJHiRMvUI6mSGsAfbFbQGBQoueH2l4PiC7nW2jD4kc9woVvOiw(Tm2oqf8aSoG2IunJBVb2oPd34L(hoLh1XTe8sl)wgBpaPgGedqMdq2bGPzHi5XMZo242BGTt6WhqNgGmhGKdWYbiXa6oazhqFGDE)MYgceEasoGpnan8AiLB8a7C6b3eQacBg(cub3gWNgGgMLV4CZX6fkGBBawhGedqgdaf59mO4uDAdc9aKlFayAwisES5SJnU9gy7Ko8bi1a6oajve6VAbN8yZzhROURYvuNrxL0kc(cub3uDOiEWnD8NDf1DveH2l4PiOHqrAzmez1SYvuNrgkPve8fOcUP6qrO3Y5TcfHedyJQL4S85MO1WM6gGudqIb0DaYoG(4ZjTDS5mEaFAaA7yZzC6TH2l4fIbi5a60awwBhBoN8QNhGKdW6aKyayAwisES5SJnOlIhIewey7b0PbeAVGNbDr8qKWIaBBArFKZdWYbeAVGNbDr8qKWIaBB0qSpajhGudqIbeAVGNbBVCZ0I(iNhGLdi0Ebpd2E5MrdX(aKureAVGNIaDr8qKWIaBRCf1zqcL0kc(cub3uDOi0B58wHIatZcrYJnNDSbtPO5Ko8bi1a6oazhakY7zqXP60ge6b0PbKHIi0EbpfbMsrZjD4kxrDgYujTIGVavWnvhkc9woVvOiW0SqK8yZzhBC7nW2jD4dqQbqcfrO9cEkc3EdSDshUYvuNXhkPve8fOcUP6qrO3Y5TcfbkY7z0cowDG96Yni0dW6aKyaOiVNbJ0A8LIEueSTPbPCdW6aqrEpd2oAqk9SOzAqk3aKlFaOiVNbfNQtBqOhGKkIq7f8uey7LBkxrDgwKsAfbFbQGBQoueH2l4Pi24hRi0B58wHIaf59mO4uDAdc9aSoG2IunZg)yJx6F4uEuh3sWlT8BzS9aKAazOi0F1co5XMZowrDxLROoJoxjTIGVavWnvhkIq7f8ue6qisH2l4Lef2veIc7Pl6zfXRecEvUYve0lRH9OHRKwrDxL0kc(cub3uDOiG0kcm7kIq7f8uezJTcubRiYgcewrybfr2ytx0ZkIhez10j0YzLROodL0kc(cub3uDOiG0kcm7kIq7f8uezJTcubRiYgcewr0vr0ySElAVGNIGWE52aipalq6aOgEFcFbn2g6dGKh)4bqEaDjDaexqJTH(ai5XpEaKhqgKoalgjZaipasq6aiOu08aipazQiYgB6IEwr8kHGxLROMekPve8fOcUP6qraPvey2veH2l4PiYgBfOcwrKneiSIOZvengR3I2l4Pii0HGhaLYThGDGD2OiYgB6IEwrSfDYl9pSYvultL0kIq7f8ue)QRTClHPRTCSIGVavWnvhkxr9hkPveH2l4PiqHUl4w6jIVCJsD5jh(56ue8fOcUP6q5kQTiL0kc(cub3uDOi0B58wHIadreO11m0iyhrWjErO9cEg(cub3gGC5dadreO11mzHIWlbNWqrw(CdFbQGBkIq7f8uepbJT1B8CLROUZvsRi4lqfCt1HIqVLZBfkcuK3Z0dH3V6sp42BAqkNIi0Ebpfb9cPiuUIAQQsAfbFbQGBQoue6TCERqrGI8EMEi8(vx6b3Etds5ueH2l4Pi0HNEWTx5kxr8kHGxL0kQ7QKwrWxGk4MQdfrO9cEkIn(Xkc9woVvOiYgBfOc28kHG3bqEaDhG1bS8BzSDGk4byDanOB24hBO7reErlkEhavipGUMmgqNganV4c785PEeHx0IIxfH(RwWjp2C2XkQ7QCf1zOKwrWxGk4MQdfHElN3kuezJTcubBELqW7aipGmueH2l4Pi24hRCf1KqjTIGVavWnvhkc9woVvOiYgBfOc28kHG3bqEaKqreAVGNIqGCXMQdtxB4f8uUIAzQKwrWxGk4MQdfHElN3kuezJTcubBELqW7aipazQicTxWtrGPu0CshUYvu)HsAfbFbQGBQoue6TCERqrGI8EgmsRXxk6rrW2MgKYPicTxWtrGTxUPCf1wKsAfbFbQGBQoue6TCERqrGHic06AgAeSJi4eVi0EbpdFbQGBdqU8bGHic06AMSqr4LGtyOilFUHVavWnfrDoVlcTNQNIadreO11mzHIWlbNWqrw(CfrDoVlcTNQ(EUvHZkIUkIq7f8uepbJT1B8CfrDoVlcTNYfq0qOi6QCLRiWohc3wjTI6UkPve8fOcUP6qr8GB64p7kQ7QicTxWtrqdHI0YyiYQzLROodL0kc(cub3uDOicTxWtrSXpwrO)QfCYJnNDSI6Ukc9woVvOiKyanOB24hBO7reErlkEhavgqxZhdqU8bS8BzSDGk4bi5aSoG2IunZg)yJx6F4uEuh3sWlT8BzS9aKAazma5YhGedGMxCHD(8upIWlArX7aKAanOB24hBO7reErlkEhG1bGI8EguCQoTbHEawhaMMfIKhBo7yJBVb2oPdFauzaKyawhGgMLV4CZX6fkGBBasoa5YhakY7zqXP60ML7J6WdGkdORIOXy9w0Ebpfbjp(Xd4yUHhWcrYTfFhWhwGKAaW3akhpabF5U9acFaXa6RR6r6hGdhagzPdmEay7LB4b0OzLROMekPve8fOcUP6qrO3Y5TcfbMMfIKhBo7yJBVb2oPdFauzaKyawhWYVLX2bQGhG1b0wKQzeixSP6W01gEbpJx6F4uEuh3sWlT8BzS9aKAaFmaRdqIbOH9OWenSohpaYdqMdqU8b0GUrGCXMQdtxB4f8ml3h1HhavgWhdqU8biJb0GUrGCXMQdtxB4f8mEP)vx(aKureAVGNIqGCXMQdtxB4f8uUIAzQKwrWxGk4MQdfrJX6TO9cEkIowepedGqey7bu4bGYUZ7aC74ga25q42dGWE52acFaKyaES5SJve6TCERqrGPzHi5XMZo2GUiEisyrGThGudidfrO9cEkc0fXdrclcSTYvu)HsAfbFbQGBQouep4Mo(ZUI6UkIq7f8ue0qOiTmgISAw5kQTiL0kc(cub3uDOi0B58wHIqd7rHjAyDoEauzaYCawhaMMfIKhBo7yJBVb2oPdFauzaFOicTxWtrGTxUPCLRi0qOObPCkPvu3vjTIGVavWnvhkcfHesiJg0nrlO9klNWuITp1I(iNnEP)vxUC5nOBIwq7vwoHPeBFQf9roBwUpQdtLmK0QenOBIwq7vwoHPeBFQf9roBWEO)rfsixUmAq3eTG2RSCctj2(Knhcd2d9pP6kPvzeAVGNjAbTxz5eMsS9jBoeM6sprLB7wLrO9cEMOf0ELLtykX2NArFKZM6sprLB7wLrO9cEMOf0ELLtykX2BQl9evUTlPvp2C2nE1ZjhMAfl1hYLhAVYYj(4(IXsLHvz0GUjAbTxz5eMsS9Pw0h5SXl9V6YTYhV5FPcj(WQhBo7gV65KdtTIL6dfrO9cEkIOf0ELLtykX2Ri0F1co5XMZowrDxLROodL0kc(cub3uDOicTxWtr84neP3Yhv5RIqVLZBfkcnShfMOH154bqLbqIbyDaES5SB8QNtom1kEasnGoFawhGmgGgcfniLZ4voV40dz)AqOhGC5d4v52EA5(Oo8aOYaOQdW6aEvUTNwUpQdpaPgqgkc9xTGtES5SJvu3v5kQjHsAfbFbQGBQouengR3I2l4PiKotMjMjZ8bqnZTb4WbG)E6bqPC7bqPC7bSrw(Gi4b8w(OkFhafB(gafEalYnG3Yhv5lACnshaChq4coW(a02S(3aQ3akhpakW1Thq5kc9woVvOi0WEuyIgwNJhGuKhajueH2l4Piq5fZ7pLROwMkPve8fOcUP6qrO3Y5TcfHg2Jct0W6C8aKI8aiHIi0EbpfrD6yVWl4PCf1FOKwrWxGk4MQdfrJX6TO9cEkcP3VdiU2aoOpakb25biDMza8XB(xshakIpGqGHdiZIG9bGG5bu(aEWDaufE)nG4AdOoDShwrO3Y5TcfbF8M)104xPlFasnazAHbix(aqrEpdkovN2Gqpa5YhGedWdbFUHE5w4W1WxGk42aSoaSnCDg7j3BdGkdGedqsfrO9cEkcVY5fNEi7xLRO2IusRi4lqfCt1HIOXy9w0EbpfHfFLB7daLhaLfE5dWHdabZdGONfTbaVbqYJF8aQBaz597aYY73bCL2MhaUCKWl4HjDaOi(aYY73bSXYIVkc9woVvOiqrEpJx58ItpK9RbHEawhakY7zqXP60MgKYnaRdqd7rHjAyDoEauzaYCawhakY7zWiTgFPOhfbBBAqk3aSoGg0nB8Jn09icVOffVdGkdORXIgG1bWhV5FhGudqMwyawhqBrQMzJFSXl9pCkpQJBj4Lw(Tm2Easnamnlejp2C2XgmLIMt6WhqNgqgd4tdiJbyDaES5SB8QNtom1kEasnGpueH2l4PiW2rdsPNfnLROUZvsRi4lqfCt1HIqVLZBfkcuK3Z4voV40dz)AqOhGC5daf59mO4uDAdcTIi0EbpfbkVyE)vxUYvutvvsRi4lqfCt1HIqVLZBfkcuK3ZGIt1Pni0dqU8bGcX4byDaVk32tl3h1HhavgGgcfniLZGIt1Pnl3h1HhGC5dafIXdW6aEvUTNwUpQdpaQmGm(qreAVGNIGg6f8uUI6oJsAfbFbQGBQoue6TCERqrGI8EguCQoTbHEaYLpGxLB7PL7J6WdGkdiJUkIq7f8ueBKLpico9w(OkFvUI6UwqjTIGVavWnvhkIgJ1Br7f8uesNjZeZKz(aij2S(3a6HW7xDdWg6ugqCTbGDK3BaI6hpa3UWKoG4AdOp(IYdaLDN3bOH9OHpGL7J6gWY4VNwrO3Y5TcfHedObDZw0ML7J6WdqQbiZbyDaAypkmrdRZXdGkdGedW6aAq3SXp24L(xD5dW6a4J38VMg)kD5dqkYdidlmajhGC5dafIXdW6aEvUTNwUpQdpaQmGpueH2l4Pi0Wll8hNCBoHPRTCSYvu3TRsAfbFbQGBQouengR3I2l4PiS4JVO8aCBE5bGTHiI2aq5b0dxEaA41kVGhEaWBaUnpan8AiLRi0B58wHIaf59mELZlo9q2Vge6bix(aKyaA41qk30yMofcbNxXPzdFbQGBdqsfrO9cEkcUNgsH3ek8AkxrD3musRi4lqfCt1HIOXy9w0EbpfrMqLLha9wWT8VdWHdaEFcbZdGch0WtrCrpRiYSqh5Y5A3uJXEDFXjDiekc9woVvOiyloKIMMBMml0rUCU2n1ySx3xCshcHIi0EbpfrMf6ixox7MAm2R7loPdHq5kQ7scL0kIq7f8ueiyovo3Jve8fOcUP6q5kxraPiOWrwwjTI6UkPve8fOcUP6qrO3Y5TcfbkY7zS5y9e8LCBorPendcTIi0Ebpfb2JfJS5SYvuNHsAfbFbQGBQoueH2l4PiWi3RwwriQJt6MIqMDkx3uUIAsOKwrWxGk4MQdfrO9cEkIEi8E1Ykc9woVvOiqrEptpeE)Ql9GBVbHEawhGedyro(b3C2OdN)YjnYwqdFbQGBdqU8bSih)GBoBABGKB7j4l1yMo9GAeSHVavWTbi5aSoamnlejp2C2Xg3EdSDsh(aOYaYyawhGmgGhc(CJa5InvhMU2Wl4z4lqfCtriQJt6MIqMDkx3uUIAzQKwrWxGk4MQdfHElN3kue8XB(3bqLbqclmaRdObDZw0ML7J6WdqQbitZhdW6aKyaAiu0GuoJx58ItpK9Rz5(Oo8aKI8aSiZhdqU8bSih)GBoB0HZF5KgzlOHVavWTbi5aSoauK3ZOfCS6a71LBWEO)naQmGUdW6aKXaqrEptqZForVClC4It6nYwxUbHEawhGmgakY7zqfqytGGDdc9aSoazmauK3ZGIt1Pni0dW6aKyaAiu0GuoJgEzH)4KBZjmDTLJnl3h1HhGudWImFma5YhGmgGgMLV4CZv52E6f8aKCawhGedqgdqdZYxCU5y9cfWTna5YhGgcfniLZeTG2RSCctj2EZY9rD4bif5b8XaKlFanOBIwq7vwoHPeBFQf9roBwUpQdpaPgqNpajveH2l4PiS5y9e8LCBorPenLRO(dL0kc(cub3uDOi0B58wHIGpEZ)oaQmasyHbyDanOB2I2SCFuhEasnazA(yawhGedqdHIgKYz8kNxC6HSFnl3h1HhGuKhGmnFma5YhWIC8dU5Srho)LtAKTGg(cub3gGKdW6aqrEpJwWXQdSxxUb7H(3aOYa6oaRdqgdaf59mbn)5e9YTWHloP3iBD5ge6byDaYyaOiVNbvaHnbc2ni0dW6aKyaYyaOiVNbfNQtBqOhGC5dqdZYxCU5y9cfWTnaRdWdbFUbhzJCoTWyn8fOcUnaRdaf59mO4uDAZY9rD4bi1aSObi5aSoajgGgcfniLZOHxw4po52CctxB5yZY9rD4bi1aSiZhdqU8biJbOHz5lo3CvUTNEbpajhG1biXaKXa0WS8fNBowVqbCBdqU8bOHqrds5mrlO9klNWuIT3SCFuhEasrEaFma5Yhqd6MOf0ELLtykX2NArFKZML7J6WdqQb05dqYbyDaES5SB8QNtom1kEasnGoxreAVGNIOhcVF1LEWTx5kx5kIS8Il4POodlKrxl05w4dfbLyV6YXkcsAKSKCQjzOotiZhWaK2Mhq1tdxFap4oGm9vxHT5nthWYwCi1YTbGH98aceh2ho3gG2oUCgBM)wS64biZmFaKe4LLxNBditxKJFWnNnD2mDaoCaz6IC8dU5SPZA4lqfClthGeD)SKM5)8NKgjljNAsgQZeY8bmaPT5bu90W1hWdUditB8lqeEMoGLT4qQLBdad75beioSpCUnaTDC5m2m)Ty1XdidlK5dGKaVS86CBaevpjza4VNhFEaKudWHdWIHedOvzlCbVbaP5nC4oajSuYbir3plPz(BXQJhqgzK5dGKaVS86CBaevpjza4VNhFEaKudWHdWIHedOvzlCbVbaP5nC4oajSuYbirgFwsZ8F(tsJKLKtnjd1zcz(agG028aQEA46d4b3bKPOciS5HaE4mDalBXHul3gag2ZdiqCyF4CBaA74YzSz(BXQJhajY8bqsGxwEDUnaIQNKma83ZJppasQb4WbyXqIb0QSfUG3aG08goChGewk5aKO7NL0m)N)K0izj5utYqDMqMpGbiTnpGQNgU(aEWDazkKIGchz5mDalBXHul3gag2ZdiqCyF4CBaA74YzSz(BXQJhajY8bqsGxwEDUnGmDro(b3C20zZ0b4WbKPlYXp4MZMoRHVavWTmDasKXNL0m)Ty1XdqMz(aijWllVo3gqMUih)GBoB6Sz6aC4aY0f54hCZztN1WxGk4wMoaj6(zjnZFlwD8a(iZhajbEz5152aY0f54hCZztNnthGdhqMUih)GBoB6Sg(cub3Y0bir3plPz(p)jz6PHRZTb0zgqO9cEdquyhBM)kc6f(kbRiOAQEazgEdXaYexKQn)PAQEa)reFhq3miDazyHm6o)N)unvpGmdVHyaKSK0Tydqh3acbgoauEapiY1gq4dW2DACMBPL5f2n5LBJGA0WEl7SXrvInS0IOQDglstv7mDgl69r808hAUB3pArqIWcu1w8EZ)5pvt1dGKyhxoJZ85pvt1d4tdOTivZaPiOWrwoPdNC3bOTz9p8aC4aAls1mqkckCKLt6WnZFQMQhWNgajbEz51hqhspaAiuKwgdrwnpahoakr5dG)m9YyCbpZ8NQP6b8PbqY2AdOoN3fH2lubpGmJGX26nE(aQ3a(crgGDKLhWbD76YhalW8aC4aAqZ8F(hAVGh2qVSg2JgUSKTmBSvGkysVONj)GiRMoHwotA2qGWKTW8NQhaH9YTbqEawG0bqn8(e(cASn0hajp(XdG8a6s6aiUGgBd9bqYJF8aipGmiDawmsMbqEaKG0bqqPO5bqEaYC(hAVGh2qVSg2JgUSKTmBSvGkysVONj)kHGxsZgceMC35pvpacDi4bqPC7byhyNnZ)q7f8Wg6L1WE0WLLSLzJTcubt6f9m5TOtEP)HjnBiqyYD(8p0EbpSHEznShnCzjB5V6Al3sy6Alhp)dTxWdBOxwd7rdxwYwIcDxWT0teF5gL6Yto8Z1n)dTxWdBOxwd7rdxwYw(em2wVXZjTEKXqebADndnc2reCIxeAVGNHVavWn5YXqebADntwOi8sWjmuKLp3WxGk428p0EbpSHEznShnCzjBj9cPiiTEKrrEptpeE)Ql9GBVPbPCZ)q7f8Wg6L1WE0WLLSL6Wtp42tA9iJI8EMEi8(vx6b3Etds5M)Z)q7f8WKxKlfAVGxsuyN0l6zYOHiontA9iJI8EMEi8(vx6b3EdcTvz0wKQzGueu4ilN0Hp)dTxWdllzl1HqKcTxWljkSt6f9mzifbfoYYKwpYTfPAgifbfoYYjD4ZFQEaK0xifXaOyZhNL3bqdX4cvWZ)q7f8WYs2s6fsrm)dTxWdllzl9kNxC6HSFjTEKrrEptCFtp42BAqk38p0EbpSSKTuhE6b3EsRhzuK3Ze330dU9MgKYn)P6bKjpEayBOpaSZHWTN)H2l4HLLSLlYLcTxWljkSt6f9mzSZHWTjTEKrrEpd2oAqk9SOzqOLlhf59m0lKIWGqp)dTxWdllzlX)qeIeAGTN)H2l4HLLSL6qisH2l4Lef2j9IEMSgcfniLB(t1dGAwVqbCBz(aijb2hajgaChGmhGg2JchanSoFaBrJha8gaUUCbpap2C2haeXXvJha8nauEX8(BaWDanKTU8bGYlM3FdOEd4XBigWB5JQ8DafEai0ditsYhqqtl(oGyaFOPhajVOhafB(gG0zMbu4bGqpG4AdGsjedadH3aEHqma47zM)H2l4HLLSLBrtA9iRHz5lo3CSEHc42SkHm8qWNBqfqyZdb8Wg(cub3Klhf59mOciS5HaEydcTKwX0SqK8yZzhBC7nW2jD4K7AvcnShfMOH15yPYW6YVLX2bQGT2wKQz2I24L(hoLh1XTe8sl)wgBlv2yRavWMTOtEP)HLlxd7rHjAyDoM8hwrrEpJx58ItpK9RbH2kkY7z8kNxC6HSFnl3h1HPcjS2wKQz2I24L(hoLh1XTe8sl)wgBl1hsAvczGI8EguCQoTbHwUCnekAqkNbfNQtBqOLlxcuK3ZGIt1Pni0w1qOObPCMhVHi9w(OkFni0sk58p0EbpSSKTCrUuO9cEjrHDsVONj)QRW28sA9iRH9OWenSohlfzj(4tzJTcubBEqKvtNqlNLC(hAVGhwwYwsVvFisu2WTjTEKBls1m0B1hIeLnCBJx6F4uEuh3sWlT8BzSTuKZWcw1WEuyIgwNJLICgKkQJt6g5pM)u9aS4reE9PCDBayNdHBp)dTxWdllzl1HqKcTxWljkSt6f9mzSZHWTjTEKrrEpdkovN2Gqp)P6biTnpGEi2ha)zA(WvwEaDi9a0F1cEasiT9Yy7bqyVCBaeukAEaAi2hq3UFma(4n)lPdOp(XdaJS8aOWdqh3a6JF8aC7WhqDdqMdixardbwY5FO9cEyzjBjLOCsXSMSes0T7hFkds0juK3ZuNo2l8cEPF1LNGVKBZPmlYLlydcTKFsc(4n)RrJSlFUSKW8rN4J38VMLZ5twjKPf6ekY7z0cowDG96Yni0skPKwYhV5FnlNZhP1JShc(CdQacBEiGh2WxGk4MvuK3ZGkGWMhc4HnniLZAO9klNq9KVvEoVyYwy(t1di0EbpSSKTKgcfPLXqKvZKwpYEi4ZnOciS5HaEydFbQGBwrrEpdQacBEiGh20GuoRsWhV5FLLeMp6eF8M)1SCoFYkHmTqNqrEpJwWXQdSxxUbHwsjPIeD7(XNYGeDcf59m1PJ9cVGx6xD5j4l52CkZIC5c2GqlP1q7vwoH6jFR8CEXKTW8p0EbpSSKTCrUuO9cEjrHDsVONjJkGWMhc4HjTEK9qWNBqfqyZdb8Wg(cub3SII8Egube28qapSPbPCZ)q7f8WYs2YhVqDbrWj0Yzs1F1co5XMZoMCxsRhzuK3Ze08Nt0l3chU4KEJS1LBqON)H2l4HLLSL0qOiTmgISAM0hCth)zNC35FO9cEyzjB5g)ys1F1co5XMZoMCxsRhzjw(Tm2oqfSC508IlSZNN6reErlkELQbDZg)ydDpIWlArXRKwBls1mB8JnEP)Ht5rDClbV0YVLX2sHPzHi5XMZo2GPu0CshENY4tzm)dTxWdllzlfixSP6W01gEbps1F1co5XMZoMCxsRhzjw(Tm2oqfSC508IlSZNN6reErlkELQbDJa5InvhMU2Wl4zO7reErlkEL0ABrQMrGCXMQdtxB4f8mEP)Ht5rDClbV0YVLX2sHPzHi5XMZo2GPu0CshENY4tzm)dTxWdllzlPHqrAzmez1mPp4Mo(Zo5UZ)q7f8WYs2s3EdSDshoP6VAbN8yZzhtUlP1J8YVLX2bQGT2wKQzC7nW2jD4gV0)WP8OoULGxA53YyBPKqMYIPzHi5XMZo242BGTt6W7KmLKKsIUY2hyN3VPSHaHL8tA41qk34b250dUjube2m8fOcU9jnmlFX5MJ1lua3MvjKbkY7zqXP60geA5YX0SqK8yZzhBC7nW2jD4s1vY5FO9cEyzjBjnekslJHiRMj9b30XF2j3D(hAVGhwwYwIUiEisyrGTjTEKLyJQL4S85MO1WM6KsIUY2hFoPTJnNXFsBhBoJtVn0EbVqizNwwBhBoN8QNL0QeyAwisES5SJnOlIhIewey7ofAVGNbDr8qKWIaBBArFKZKuH2l4zqxepejSiW2gne7skLeH2l4zW2l3mTOpYzsQq7f8my7LBgne7so)dTxWdllzlXukAoPdN06rgtZcrYJnNDSbtPO5KoCP6klkY7zqXP60ge6oLX8p0EbpSSKT0T3aBN0HtA9iJPzHi5XMZo242BGTt6WLIeZ)q7f8WYs2sS9YnsRhzuK3ZOfCS6a71LBqOTkbkY7zWiTgFPOhfbBBAqkNvuK3ZGTJgKsplAMgKYjxokY7zqXP60geAjN)H2l4HLLSLB8Jjv)vl4KhBo7yYDjTEKrrEpdkovN2GqBTTivZSXp24L(hoLh1XTe8sl)wgBlvgZ)q7f8WYs2sDiePq7f8sIc7KErpt(vcbVZ)5FO9cEydQacBEiGhM8g)ys1F1co5XMZoMCxsRhzjKHx6F1LlxUeDnz0jAEXf25Zt9icVOffVsrUbDZg)ydDpIWlArXRKYLlrO9klNq9KVvEoVyYzyD53Yy7avWskPvuK3ZG6Pn(XMgKYn)dTxWdBqfqyZdb8WYs2sbYfBQomDTHxWJu9xTGtES5SJj3L06rE53Yy7avWwrrEpdQN6HW7vlBAqk38p0EbpSbvaHnpeWdllzlD7nW2jD4KQ)QfCYJnNDm5UKwpYl)wgBhOc2kkY7zq9KBVb220GuoRTfPAg3EdSDshUXl9pCkpQJBj4Lw(Tm2wkjKPSyAwisES5SJnU9gy7Ko8ojtjjPKORS9b259BkBiqyj)KgEnKYnEGDo9GBcvaHndFbQGBZ)q7f8Wgube28qapSSKTeDr8qKWIaBtA9iJI8EgupHUiEisyrGTnniLB(hAVGh2GkGWMhc4HLLSLykfnN0HtA9iJI8EgupHPu0SPbPCwX0SqK8yZzhBWukAoPdxQUZ)q7f8Wgube28qapSSKTeBVCJ06rgf59mOEcBVCZ0GuU5FO9cEydQacBEiGhwwYwIPu0CshoP1JmkY7zq9eMsrZMgKYn)dTxWdBqfqyZdb8WYs2s3EdSDshoP1JmkY7zq9KBVb220GuU5)8p0EbpSrdHIgKYroAbTxz5eMsS9KQ)QfCYJnNDm5UKswcjKrd6MOf0ELLtykX2NArFKZgV0)QlxU8g0nrlO9klNWuITp1I(iNnl3h1HPsgsAvIg0nrlO9klNWuITp1I(iNnyp0)OcjKlxgnOBIwq7vwoHPeBFYMdHb7H(NuDL0QmcTxWZeTG2RSCctj2(KnhctDPNOYTDRYi0Ebpt0cAVYYjmLy7tTOpYztDPNOYTDRYi0Ebpt0cAVYYjmLy7n1LEIk32L0QhBo7gV65KdtTIL6d5YdTxz5eFCFXyPYWQmAq3eTG2RSCctj2(ul6JC24L(xD5w5J38VuHeFy1JnNDJx9CYHPwXs9X8p0EbpSrdHIgKYjlzlF8gI0B5JQ8Lu9xTGtES5SJj3L06rwd7rHjAyDoMkKWQhBo7gV65KdtTILQZTkdnekAqkNXRCEXPhY(1Gqlx(RYT90Y9rDyQqvT(QCBpTCFuhwQmM)u9aKotMjMjZ8bqnZTb4WbG)E6bqPC7bqPC7bSrw(Gi4b8w(OkFhafB(gafEalYnG3Yhv5lACnshaChq4coW(a02S(3aQ3akhpakW1Thq5Z)q7f8WgnekAqkNSKTeLxmV)iTEK1WEuyIgwNJLImjM)H2l4HnAiu0GuozjBzD6yVWl4rA9iRH9OWenSohlfzsm)P6bi9(DaX1gWb9bqjWopaPZmdGpEZ)s6aqr8becmCazweSpaempGYhWdUdGQW7VbexBa1PJ9WZ)q7f8WgnekAqkNSKT0RCEXPhY(L06rMpEZ)AA8R0LlLmTGC5OiVNbfNQtBqOLlxcpe85g6LBHdxdFbQGBwX2W1zSNCVrfsi58NQhGfFLB7daLhaLfE5dWHdabZdGONfTbaVbqYJF8aQBaz597aYY73bCL2MhaUCKWl4HjDaOi(aYY73bSXYIVZ)q7f8WgnekAqkNSKTeBhniLEw0iTEKrrEpJx58ItpK9RbH2kkY7zqXP60MgKYzvd7rHjAyDoMkY0kkY7zWiTgFPOhfbBBAqkN1g0nB8Jn09icVOffVuPRXISYhV5FLsMwWABrQMzJFSXl9pCkpQJBj4Lw(Tm2wkmnlejp2C2XgmLIMt6W7ugFkdRES5SB8QNtom1kwQpM)H2l4HnAiu0GuozjBjkVyE)vxoP1JmkY7z8kNxC6HSFni0YLJI8EguCQoTbHE(hAVGh2OHqrds5KLSL0qVGhP1JmkY7zqXP60geA5YrHyS1xLB7PL7J6WurdHIgKYzqXP60ML7J6WYLJcXyRVk32tl3h1HPsgFm)dTxWdB0qOObPCYs2YnYYhebNElFuLVKwpYOiVNbfNQtBqOLl)v52EA5(OomvYO78NQhG0zYmXmzMpasInR)nGEi8(v3aSHoLbexBayh59gGO(XdWTlmPdiU2a6JVO8aqz35DaAypA4dy5(OUbSm(7PN)H2l4HnAiu0GuozjBPgEzH)4KBZjmDTLJjTEKLObDZw0ML7J6WsjtRAypkmrdRZXuHewBq3SXp24L(xD5w5J38VMg)kD5srodliPC5Oqm26RYT90Y9rDyQ8X8NQhGfF8fLhGBZlpaSner0gakpGE4YdqdVw5f8WdaEdWT5bOHxdP85FO9cEyJgcfniLtwYwY90qk8MqHxJ06rgf59mELZlo9q2VgeA5YLqdVgs5MgZ0Pqi48konB4lqfCtY5pvpGmHklpa6TGB5FhGdha8(ecMhafoOH38p0EbpSrdHIgKYjlzlrWCQCUN0l6zYzwOJC5CTBQXyVUV4KoecsRhz2IdPOP5MjZcDKlNRDtng719fN0Hqm)dTxWdB0qOObPCYs2semNkN7XZ)5FO9cEyZRecEjVXpMu9xTGtES5SJj3L06roBSvGkyZRecEj316YVLX2bQGT2GUzJFSHUhr4fTO4LkK7AYOt08IlSZNN6reErlkEN)H2l4HnVsi4vwYwUXpM06roBSvGkyZRecEjNX8p0EbpS5vcbVYs2sbYfBQomDTHxWJ06roBSvGkyZRecEjtI5FO9cEyZRecELLSLykfntA9iNn2kqfS5vcbVKL58p0EbpS5vcbVYs2sS9YnsRhzuK3ZGrAn(srpkc220GuU5FO9cEyZRecELLSLpbJT1B8CsRhzmerGwxZqJGDebN4fH2l4z4lqfCtUCmerGwxZKfkcVeCcdfz5Zn8fOcUrADoVlcTNQ(EUvHZK7sADoVlcTNYfq0qqUlP158Ui0EQEKXqebADntwOi8sWjmuKLpF(p)dTxWdBE1vyBEjtdHI0YyiYQzsFWnD8NDYDN)H2l4HnV6kSnVYs2sCKnY50cJL06rgf59m4iBKZPfgRz5(OomviX8p0EbpS5vxHT5vwYwsVvFisu2WTjTEKLOTivZqVvFisu2WTnEP)Ht5rDClbV0YVLX2srIojbMMfIKhBo7yd9w9Hirzd3w2UsAftZcrYJnNDSHER(qKOSHBlvxjLlhtZcrYJnNDSHER(qKOSHBlLeKq2UDYdbFUbhO86qOBB4lqfCtY5FO9cEyZRUcBZRSKTClAs1F1co5XMZoMCxsRh5LFlJTdubBTTivZSfTXl9pCkpQJBj4Lw(Tm2wQSXwbQGnBrN8s)dBvcjqrEpJx58ItpK9RbHwUCz4L(xD5sAvcuK3ZGkGWMhc4Hni0YLldpe85gube28qapSHVavWnjLlxgEi4Zn4aLxhcDBdFbQGBsAvcmnlejp2C2Xg6T6drIYgUn5UYLldpe85g6T6drIYgUTHVavWnjTkrO9klNAq3SfnzlixUx6F1LBn0ELLtnOB2IMCx5YLXIC8dU5SPTbsUTNGVuJz60dQrWYLldpe85gCGYRdHUTHVavWnjN)H2l4HnV6kSnVYs2sCKnY50cJL06rgf59m4iBKZPfgRz5(OomvKqd7rHjAyDow2Us2jlQtwWqI5FO9cEyZRUcBZRSKT8XluxqeCcTCM0(4Zj(4n)l5UKQ)QfCYJnNDm5UZ)q7f8WMxDf2MxzjB5JxOUGi4eA5mP6VAbN8yZzhtUlP1JmkY7zqXP60geAREi4ZnyiIibFj3Mtp4Yy3WxGk428F(hAVGh2aPiOWrwMm2JfJS5mP1JmkY7zS5y9e8LCBorPendc98p0EbpSbsrqHJSSSKTeJCVAzsf1XjDJSm7uUUn)dTxWdBGueu4illlzl7HW7vltQOooPBKLzNY1nsRhzuK3Z0dH3V6sp42BqOTkXIC8dU5Srho)LtAKTGYLVih)GBoBABGKB7j4l1yMo9GAeSKwX0SqK8yZzhBC7nW2jD4ujdRYWdbFUrGCXMQdtxB4f8m8fOcUn)dTxWdBGueu4illlzlT5y9e8LCBorPensRhz(4n)lviHfS2GUzlAZY9rDyPKP5dRsOHqrds5mELZlo9q2VML7J6Wsr2ImFix(IC8dU5Srho)LtAKTGsAff59mAbhRoWED5gSh6FuPRvzGI8EMGM)CIE5w4WfN0BKTUCdcTvzGI8Egube2eiy3GqBvgOiVNbfNQtBqOTkHgcfniLZOHxw4po52CctxB5yZY9rDyPSiZhYLldnmlFX5MRYT90lyjTkHm0WS8fNBowVqbCBYLRHqrds5mrlO9klNWuIT3SCFuhwkYFixEd6MOf0ELLtykX2NArFKZML7J6Ws15so)dTxWdBGueu4illlzl7HW7xDPhC7jTEK5J38VuHewWAd6MTOnl3h1HLsMMpSkHgcfniLZ4voV40dz)AwUpQdlfzzA(qU8f54hCZzJoC(lN0iBbL0kkY7z0cowDG96Ynyp0)OsxRYaf59mbn)5e9YTWHloP3iBD5geARYaf59mOciSjqWUbH2QeYaf59mO4uDAdcTC5Ayw(IZnhRxOaUnREi4Zn4iBKZPfgRHVavWnROiVNbfNQtBwUpQdlLfjPvj0qOObPCgn8Yc)Xj3Mty6AlhBwUpQdlLfz(qUCzOHz5lo3CvUTNEblPvjKHgMLV4CZX6fkGBtUCnekAqkNjAbTxz5eMsS9ML7J6Wsr(d5YBq3eTG2RSCctj2(ul6JC2SCFuhwQoxsRES5SB8QNtom1kwQoF(p)dTxWdBWohc3MmnekslJHiRMj9b30XF2j3D(t1dGKh)4bCm3WdyHi52IVd4dlqsna4BaLJhGGVC3EaHpGya91v9i9dWHdaJS0bgpaS9Yn8aA088p0EbpSb7CiCBzjB5g)ys1F1co5XMZoMCxsRhzjAq3SXp2q3Ji8Iwu8sLUMpKlF53Yy7avWsATTivZSXp24L(hoLh1XTe8sl)wgBlvgYLlbnV4c785PEeHx0IIxPAq3SXp2q3Ji8Iwu8Aff59mO4uDAdcTvmnlejp2C2Xg3EdSDshoviHvnmlFX5MJ1lua3MKYLJI8EguCQoTz5(Oomv6o)dTxWdBWohc3wwYwkqUyt1HPRn8cEKwpYyAwisES5SJnU9gy7KoCQqcRl)wgBhOc2ABrQMrGCXMQdtxB4f8mEP)Ht5rDClbV0YVLX2s9Hvj0WEuyIgwNJjlt5YBq3iqUyt1HPRn8cEML7J6Wu5d5YLrd6gbYfBQomDTHxWZ4L(xD5so)P6b0XI4HyaeIaBpGcpau2DEhGBh3aWohc3Eae2l3gq4dGedWJnND88p0EbpSb7CiCBzjBj6I4HiHfb2M06rgtZcrYJnNDSbDr8qKWIaBlvgZ)q7f8WgSZHWTLLSL0qOiTmgISAM0hCth)zNC35FO9cEyd25q42Ys2sS9YnsRhznShfMOH15yQitRyAwisES5SJnU9gy7KoCQ8X8F(hAVGh2GgI40mzmY9QLjTEKrrEpdRffnMtyOiwtds5SII8EgwlkAmNeixSMgKYzvILFlJTdublxUeH2RSCIpUVySuDTgAVYYPg0nyK7vltLq7vwoXh3xmwsjN)H2l4HnOHionllzlXESyKnNjTEKrrEpdRffnMtyOiwZY9rDyP6Abz1b2tE1ZYLJI8EgwlkAmNeixSML7J6Ws11cYQdSN8QNN)H2l4HnOHionllzlXESVAzsRhzuK3ZWArrJ5Ka5I1SCFuhwkDG9Kx9SC5OiVNH1IIgZjmueRPbPCwXqrSjwlkAmlLfKlhf59mSwu0yoHHIynniLZQa5InXArrJ5pfAVGNHYgUTPU0tu52ov6o)dTxWdBqdrCAwwYwszd3M06rgf59mSwu0yoHHIynl3h1HLshyp5vplxokY7zyTOOXCsGCXAAqkNvbYfBI1IIgZFk0EbpdLnCBtDPNOYTDPSGIatZAf1DTajuUYvk]] )


end
