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


    spec:RegisterPack( "Feral", 20210801, [[dS0Z1bqiKqpcvkDjeHQnjcFcvQmkKOtHKSkfjELiYSqKUfeu7IIFjIAyOk1XueltrQNHemnuLCniW2ej4BiczCOsvohQuW6uKK5Hi6EiQ9HQ4GqqyHIKEOIKAIOsvzJOsrFevQQojQuOvcrntrc5MIer7ej1pfjudfrO0sHG0tryQOs(kIqXyHGO9sYFP0GbDyHfdPhtQjRWLj2mGplQgTOCAjRwKi9Ai0Sr52kQDRYVv1WrQJlsewUsphQPt11bA7IuFhvmEebNhISErIA(OQ2VuRMO4srmcxuupnVNEcV5E8EIzskm9eeGafHJeTOiOdnIrUOiUywueCtzdMIGoqI9XqXLIa)GRwuezUtJNQKtoV8mquJ(NtgxZGSWR)0Ba4jJRzDYkcuWI5CJNcvrmcxuupnVNEcV5E8EIzskm9eeqbfra6z)QiiQ5PwrKvJHCkufXqWAfb3u2G1qUVfSgnYieG5GyVHtiTHtZ7PN0i3iZnLnyneHGeBkQH64AyWWFdrLgc8G3OHH3Wm3PXtvYjNxy3KxEgiQr)ZjJqgxkhBKCkW94gsbn3JBGBifaqqaOfeOLjtqWicke8M7ncaGg5g5PolUCbpvnYiCdhlynmphghjslwD4KN0qDMOre3q)B4ybRH55W4irAXQd30iJWnCQ)lTSEdtLRgs)pZUc(bxT0q)BiNO8gkKa9kyC9NPrgHBicXy0W6CzxqAVqzsd5MmbNP3aWByb0qKEWgMfPLgEVNvxEdfgwAO)nC8MgzeUHCF)XDEdZE2OHt9FPFeLgc8BdrOfDdbpMGXnePhK7ySgUsWyi1qeArBueSc7yfxkcu2)dpy)HvCPOEIIlfHCbktgQuveH2R)ueBGOOi0B5YwHIGYgsXg6LgX6YBiF(nKYgoXmDdNsdPLfxyxo3odY8IMvY2qEi3WX7Mnqum0ZGmVOzLSnKQgYNFdPSHH2R0If1T(w55YIBi5goDdt0WvawbNfOmPHu1qQAyIgIccayqD7gikMXZ5ueAK0mX6XMlowr9eLROEAfxkc5cuMmuPQicTx)PiyGxS26W01gE9NIqVLlBfkIvawbNfOmPHjAikiaGb1TZ)Fa1kMXZ5ueAK0mX6XMlowr9eLROMckUueYfOmzOsvreAV(tr4zBGZS6Wve6TCzRqrScWk4SaLjnmrdrbbamOU1Z2aNzgpNRHjA4ybRHXZ2aNz1HB8sJi2Mh1jd7F2vawbN1qEAiLnKxnmPgIPfgZ6XMlo24zBGZS6WB4uAiVAivnm5gszdN0WKA4CGDzrYMoyGsdPQHiCd1)nal34b2flWVwu2)dJCbktgkcnsAMy9yZfhROEIYvuZlfxkc5cuMmuPQi0B5YwHIafeaWG6w0f0dMfZcCMz8CofrO96pfb6c6bZIzbot5kQrGIlfHCbktgQuve6TCzRqrGccayqDlMtrlMXZ5AyIgIPfgZ6XMlo2G5u0IvhEd5PHtueH2R)ueyofTy1HRCf1PGIlfHCbktgQuve6TCzRqrGccayqDloBLHz8CofrO96pfboBLHYvutIuCPiKlqzYqLQIqVLlBfkcuqaadQBXCkAXmEoNIi0E9NIaZPOfRoCLROM7P4srixGYKHkvfHElx2kueOGaagu36zBGZmJNZPicTx)Pi8SnWzwD4kx5kcG6kCMSkUuuprXLIqUaLjdvQkcGFTNqcUI6jkIq71Fkc6)z2vWp4QfLROEAfxkc5cuMmuPQi0B5YwHIafeaWGJ0rUy3pwZkZrD4gsYgsbfrO96pfbosh5ID)yvUIAkO4srixGYKHkvfHElx2kueu2WXcwdd9wZbZYzdpZ4LgrSnpQtg2)SRaScoRH80qk0WP0qkBiMwymRhBU4yd9wZbZYzdpRHj1WjnKQgMOHyAHXSES5IJn0BnhmlNn8SgYtdN0qQAiF(netlmM1JnxCSHER5Gz5SHN1qEAiLnKcnmPgoPHtPHEWKZn4avw)FpZixGYKrdPsreAV(trqV1CWSC2WZuUIAEP4srixGYKHkvfrO96pfXw0kc9wUSvOiwbyfCwGYKgMOHJfSgMTOnEPreBZJ6KH9p7kaRGZAipnmDSvGYeZw0wV0iIByIgszdPSHOGaagVYLfBbaxKmG0nKp)gsXg6LgX6YBivnmrdPSHOGaagu2)dpy)HnG0nKp)gsXg6bto3GY(F4b7pSrUaLjJgsvd5ZVHuSHEWKZn4avw)FpZixGYKrdPQHjAiLnetlmM1JnxCSHER5Gz5SHN1qYnCsd5ZVHuSHEWKZn0BnhmlNn8mJCbktgnKQgMOHu2Wq7vAXoE3SfDdj3qE3q(8BOxAeRlVHjAyO9kTyhVB2IUHKB4KgYNFdPydxWta(nxmJnaZZC7dyhIqBbEni2ixGYKrd5ZVHuSHEWKZn4avw)FpZixGYKrdPsrOrsZeRhBU4yf1tuUIAeO4srixGYKHkvfHElx2kueOGaagCKoYf7(XAwzoQd3qs2qkBO(NrFl9xNJBysnCsdPQHtPHPqdNsd5THckIq71FkcCKoYf7(XQCf1PGIlfHCbktgQuveZbjyLt2CKuuprreAV(trai7RRheBrlxueAK0mX6XMlowr9eLROMeP4srixGYKHkvfrO96pfbGSVUEqSfTCrrO3YLTcfbkiaGbfBRtBaPByIg6bto3GFqM9bSEMyb(vWUrUaLjJgYNFd1)ZgpNZO)l9JOy9mXIPRTCSzL5OoCdjzdN0Wenu)PLlo3CvEMBbcrrOrsZeRhBU4yf1tuUYveyXbPvCPOEIIlfHCbktgQuve6TCzRqrO)0YfNBorVp73rdt0qmTWywp2CXXgpBdCMvhEdjzd5vdt0q9pJ(w6Voh3qs2qe0WenKIn0lnI1L3WenKInefeaWGIT1PnG0kIq71Fkcg4fRTomDTHx)PCf1tR4srixGYKHkvfbWV2tibxr9efrO96pfb9)m7k4hC1IYvutbfxkc5cuMmuPQi0B5YwHIWdMCUbq2Gzbw5szKmYfOmz0Wenu)pB8CodGSbZcSYLYizaPByIgsXgIccayWr6ixS7hRbKUHjAO(NrFl9xNJBipnCsdt0WX7MnqumEPrSU8gMOHu2WX7gg4fRTomDTHx)z8sJyD5nKp)gsXg6bto3WaVyT1HPRn86pJCbktgnKkfrO96pfbosh5ID)yvUIAEP4srixGYKHkvfHElx2kueEWKZnOS)hEW(dBKlqzYOHjAikiaGbL9)Wd2FyZ45CnmrdPSHYjBosnmPgsbdcA4uAOCYMJKzLC5AysnKYgYlE3WP0quqaaJMjXQdSxxUbKUHu1qQAijBiLnCYee0qeUHttHgoLgIccayQth7fE9NfX6YTpG1ZeBkf8YzIbKUHu1Wenm0ELwSOU13kpxwCdj3qERicTx)PiO)Nzxb)GRwuUIAeO4srixGYKHkvfHElx2kueEWKZnOS)hEW(dBKlqzYOHjAikiaGbL9)Wd2FyZ45CnmrdPSH6Fg9T0FDoUHKSHiOH853qmTWywp2CXXgpBdCMvhEdj3WjnKkfrO96pfHoymBO96plRWUIGvy3EXSOiqz)p8G9hw5kQtbfxkc5cuMmuPQicTx)Pi0bJzdTx)zzf2veSc72lMffH(F245CkxrnjsXLIqUaLjdvQkc9wUSvOi0)m6BP)6CCd5PHuOHjAiLnefeaWGY(F4b7pSbKUH853qk2qpyY5gu2)dpy)HnYfOmz0qQueH2R)ue6GXSH2R)SSc7kcwHD7fZIIaOUcNjRYvUIanyXPffxkQNO4srixGYKHkvfHElx2kueOGaagrZkASyXplwZ45CnmrdrbbamIMv0yXYaVynJNZ1WenKYgUcWk4SaLjnKp)gszddTxPfRCYCj4gYtdN0Wenm0ELwSJ3nyWdOwPHKSHH2R0IvozUeCdPQHuPicTx)PiWGhqTIYvupTIlfHCbktgQuve6TCzRqrGccayenROXIf)SynRmh1HBipnCcVBysnuhy361S0q(8BikiaGr0SIglwg4fRzL5OoCd5PHt4DdtQH6a7wVMffrO96pfb2JfdU5IYvutbfxkc5cuMmuPQi0B5YwHIafeaWiAwrJfld8I1SYCuhUH80qDGDRxZsd5ZVHOGaagrZkASyXplwZ45CnmrdXplwROzfnwAipnK3nKp)gIccayenROXIf)SynJNZ1WenKbEXAfnROXsdr4ggAV(ZWzdpZuNfGv5zEdjzdNOicTx)PiWESa1kkxrnVuCPiKlqzYqLQIqVLlBfkcuqaaJOzfnwS4NfRzL5OoCd5PH6a7wVMLgYNFdrbbamIMv0yXYaVynJNZ1WenKbEXAfnROXsdr4ggAV(ZWzdpZuNfGv5zEd5PH8wreAV(trWzdpt5kxrmeGaK5kUuuprXLIqUaLjdvQkc9wUSvOiqbbamZ)FiwNf43zdiDdt0qk2WXcwdZZHXrI0IvhUIi0E9NIybpBO96plRWUIGvy3EXSOiqdwCAr5kQNwXLIqUaLjdvQkc9wUSvOiglynmphghjslwD4kIq71FkcDWy2q71FwwHDfbRWU9Izrr8CyCKiTOCf1uqXLIqUaLjdvQkIHG1Br71FkcsS7ZH1qozYjPLTH0pgxOmrreAV(trqVphMYvuZlfxkc5cuMmuPQi0B5YwHIafeaWOd3c87Sz8CofrO96pfHx5YITaGlskxrncuCPiKlqzYqLQIqVLlBfkcuqaaJoClWVZMXZ5ueH2R)ue6WTa)oRCf1PGIlfHCbktgQuvedbR3I2R)ueP4tAio79gIDjyEMIi0E9NIybpBO96plRWUIqVLlBfkcuqaadolgpNzHnmG0nKp)gIccayO3NdZasRiyf2TxmlkcSlbZZuUIAsKIlfrO96pfbgrqgZIg4mfHCbktgQuvUIAUNIlfHCbktgQuve6TCzRqreAVsl2X7MTOBi5gYBfrO96pfHoymBO96plRWUIGvy3EXSOiWIdsRCf1CdkUueYfOmzOsvreAV(trOdgZgAV(ZYkSRiyf2Txmlkc9)SXZ5uUI6j8wXLIqUaLjdvQkIq71FkITOvedbR3I2R)ueul69z)oMQgo1b2BifA4VnKxnu)ZOFdP)68gUfnUH)1qCD5mPHES5I3Wh0X1qA4d0quzXYIyd)THdWTU8gIklwweByb0qazdwdbw5szKAyHBiiDdtXi0gg00mKAy0qeOPBicTOBiNm5AixCZgw4gcs3W4gnKtXyne))1qGGXA4dayue6TCzRqrO)0YfNBorVp73rdt0qkBifBOhm5Cdk7)HhS)Wg5cuMmAiF(nefeaWGY(F4b7pSbKUHu1WenetlmM1JnxCSXZ2aNz1H3qYnCsdt0qkBO(NrFl9xNJBipnC6gMOHRaScolqzsdt0WXcwdZw0gV0iIT5rDYW(NDfGvWznKNgMo2kqzIzlARxAeXnmrdPSHuSHOGaaguSToTbKUH853q9)SXZ5mOyBDAdiDd5ZVHu2quqaadk2wN2as3Wenu)pB8CodGSbZcSYLYizaPBivnKQgYNFd1)m6BP)6CCdj3qe0WenefeaW4vUSyla4IKbKUHjAikiaGXRCzXwaWfjZkZrD4gsYgYRgMOHJfSgMTOnEPreBZJ6KH9p7kaRGZAipnebnKkLROEYefxkc5cuMmuPQi0B5YwHIq)ZOVL(RZXnKhYnKYgIGgIWnmDSvGYedWdUAAlA5sdPsreAV(trSGNn0E9NLvyxrWkSBVywuea1v4mzvUI6jtR4srixGYKHkvfHElx2kueJfSgg6TMdMLZgEMXlnIyBEuNmS)zxbyfCwd5HCdNM3nmrd1)m6BP)6CCd5HCdNwreAV(trqV1CWSC2WZueS6eREOiqGYvupHckUueYfOmzOsvrmeSElAV(trKscY8cHZ1JgIDjyEMIi0E9NIqhmMn0E9NLvyxrO3YLTcfbkiaGbfBRtBaPveSc72lMffb2LG5zkxr9eEP4srixGYKHkvfXqW6TO96pfbxzsdNFS3qHeOLdxPLgMkxnuJKMjnKsUYwbN1qISvgnKGtrlnu)yVHtMGGgkNS5irAdNdeLgIbxPHCKgQJRHZbIsd9SWByDnKxnmN9ObdtLIalAfbLnKYgozccAic3WPPqdNsdrbbam1PJ9cV(ZIyD52hW6zInLcE5mXas3qQAic3qkBOCYMJKrdURCEdtQHuWGGgoLgkNS5izwjxUgMudPSH8I3nCknefeaWOzsS6a71LBaPBivnKQgsvdtUHYjBosMvYLtreAV(trWjkxrO3YLTcfHhm5Cdk7)HhS)Wg5cuMmAyIgIccayqz)p8G9h2mEoxdt0Wq7vAXI6wFR8CzXnKCd5TYvupbbkUueYfOmzOsvrmeSElAV(treAV(dBgcqaY8KiNm9)m7k4hC1cPfazpyY5gu2)dpy)HnYfOmzKafeaWGY(F4b7pSz8CUeukNS5iLefmiykYjBosMvYLljk5fVNckiaGrZKy1b2Rl3astfvKKYjtqacpnfMckiaGPoDSx41FweRl3(awptSPuWlNjgqAQseAVslwu36BLNllMmVveH2R)uel4zdTx)zzf2ve6TCzRqr4bto3GY(F4b7pSrUaLjJgMOHOGaagu2)dpy)HnJNZPiyf2Txmlkcu2)dpy)HvUI6jPGIlfHCbktgQuveH2R)ueaY(66bXw0YffHElx2kueOGaaMGwibl9kJW)fB1BKUUCdiTIqJKMjwp2CXXkQNOCf1tirkUueYfOmzOsvra8R9esWvuprreAV(trq)pZUc(bxTOCf1t4EkUueYfOmzOsvreAV(trSbIIIqVLlBfkckB4kaRGZcuM0q(8BiTS4c7Y52zqMx0Ss2gYtdhVB2arXqpdY8IMvY2qQAyIgowWAy2arX4LgrSnpQtg2)SRaScoRH80qmTWywp2CXXgmNIwS6WB4uA40neHB40kcnsAMy9yZfhROEIYvupHBqXLIqUaLjdvQkIq71Fkcg4fRTomDTHx)Pi0B5YwHIGYgUcWk4SaLjnKp)gsllUWUCUDgK5fnRKTH80WX7gg4fRTomDTHx)zONbzErZkzBivnmrdhlynmmWlwBDy6AdV(Z4LgrSnpQtg2)SRaScoRH80qmTWywp2CXXgmNIwS6WB4uA40neHB40kcnsAMy9yZfhROEIYvupnVvCPiKlqzYqLQIa4x7jKGROEIIi0E9NIG(FMDf8dUAr5kQNEIIlfHCbktgQuveH2R)ueE2g4mRoCfHElx2kueRaScolqzsdt0WXcwdJNTboZQd34LgrSnpQtg2)SRaScoRH80qkBiVAysnetlmM1JnxCSXZ2aNz1H3WP0qE1qQAyYnKYgoPHj1W5a7YIKnDWaLgsvdr4gQ)BawUXdSlwGFTOS)hg5cuMmAic3q9NwU4CZj69z)oAyIgszdPydrbbamOyBDAdiDd5ZVHyAHXSES5IJnE2g4mRo8gYtdN0qQueAK0mX6XMlowr9eLROE6PvCPiKlqzYqLQIa4x7jKGROEIIi0E9NIG(FMDf8dUAr5kQNMckUueYfOmzOsvrO3YLTcfbLnCJAyL0Y5MymWM6AipnKYgoPHj1W5GeS6SyZfCdr4gQZInxWwGn0E9xWAivnCknCfDwS5I1RzPHu1WenKYgIPfgZ6XMlo2GUGEWSywGZA4uAyO96pd6c6bZIzboZmI5ixAyYnm0E9NbDb9GzXSaNz0p2BivnKNgszddTx)zWzRmmJyoYLgMCddTx)zWzRmm6h7nKkfrO96pfb6c6bZIzbot5kQNMxkUueYfOmzOsvrO3YLTcfbMwymRhBU4ydMtrlwD4nKNgoPHj1quqaadk2wN2as3WP0WPveH2R)ueyofTy1HRCf1tJafxkc5cuMmuPQi0B5YwHIatlmM1JnxCSXZ2aNz1H3qEAifueH2R)ueE2g4mRoCLROE6uqXLIqUaLjdvQkc9wUSvOiqbbamAMeRoWED5gq6gMOHu2quqaadgCmKZgZOG4mZ45Cnmrdrbbam4Sy8CMf2WmEoxd5ZVHOGaaguSToTbKUHuPicTx)PiWzRmuUI6PjrkUueYfOmzOsvreAV(trSbIIIqVLlBfkcuqaadk2wN2as3WenCSG1WSbIIXlnIyBEuNmS)zxbyfCwd5PHtRi0iPzI1JnxCSI6jkxr90Cpfxkc5cuMmuPQicTx)Pi0bJzdTx)zzf2veSc72lMffbqXyYQCLRiOxr)ZOHR4sr9efxkc5cuMmuPQiEAfbwCfrO96pfr6yRaLjkI0bduue8wrKow7fZIIa4bxnTfTCr5kQNwXLIqUaLjdvQkINwrGfxreAV(trKo2kqzIIiDWaffXefXqW6TO96pfbr2kJgsUH8M0gs9Fim(cAC27neHgiknKCdNqAdjUGgN9EdrObIsdj3WPjTHPiUXgsUHuG0gsWPOLgsUH8srKow7fZIIaOymzvUIAkO4srixGYKHkvfXtRiWIRicTx)PishBfOmrrKoyGIIGePigcwVfTx)Pii0btAiNYZAywGDXOishR9IzrrSfT1lnIyLROMxkUueH2R)ueiw3yLHftxB5yfHCbktgQuvUIAeO4sreAV(trG(UZKHfGfijdo1LB9NeQtrixGYKHkvLROofuCPiKlqzYqLQIqVLlBfkc8dYqRByObXoitSYcs71Fg5cuMmAiF(ne)Gm06gM0pl8Ijw8ZslNBKlqzYqreAV(traWeCMEdax5kQjrkUueYfOmzOsvrO3YLTcfbkiaGz()dX6Sa)oBgpNtreAV(trqVphMYvuZ9uCPiKlqzYqLQIqVLlBfkcuqaaZ8)hI1zb(D2mEoNIi0E9NIqhUf43zLRCfbqXyYQ4sr9efxkc5cuMmuPQicTx)Pi2arrrO3YLTcfr6yRaLjgGIXKTHKB4KgMOHRaScolqzsdt0WX7Mnqum0ZGmVOzLSnKKKB4eZ0nCknKwwCHD5C7miZlAwjRIqJKMjwp2CXXkQNOCf1tR4srixGYKHkvfHElx2kuePJTcuMyakgt2gsUHtRicTx)Pi2arr5kQPGIlfHCbktgQuve6TCzRqrKo2kqzIbOymzBi5gsbfrO96pfbd8I1whMU2WR)uUIAEP4srixGYKHkvfHElx2kuePJTcuMyakgt2gsUH8sreAV(trG5u0IvhUYvuJafxkc5cuMmuPQi0B5YwHIafeaWGbhd5SXmkioZmEoNIi0E9NIaNTYq5kQtbfxkc5cuMmuPQi0B5YwHIa)Gm06ggAqSdYeRSG0E9NrUaLjJgYNFdXpidTUHj9ZcVyIf)S0Y5g5cuMmue15YUG0UTaue4hKHw3WK(zHxmXIFwA5CfrDUSliTBR5zzuHlkIjkIq71FkcaMGZ0Ba4kI6CzxqA3MZE0GPiMOCLRiWUemptXLI6jkUueYfOmzOsvra8R9esWvuprreAV(trq)pZUc(bxTOCf1tR4srixGYKHkvfrO96pfXgikkcnsAMy9yZfhROEIIqVLlBfkckB44DZgikg6zqMx0Ss2gsYgoXGGgYNFdxbyfCwGYKgsvdt0WXcwdZgikgV0iIT5rDYW(NDfGvWznKNgoDd5ZVHu2qAzXf2LZTZGmVOzLSnKNgoE3SbIIHEgK5fnRKTHjAikiaGbfBRtBaPByIgIPfgZ6XMlo24zBGZS6WBijBifAyIgQ)0YfNBorVp73rdPQH853quqaadk2wN2SYCuhUHKSHtuedbR3I2R)uei0arPHNidCd3hmpJHudraVjXB4d0WYXnKjxUN1WWBy0W56QzW5g6FdXGlDGXneNTYa3WbTOCf1uqXLIqUaLjdvQkc9wUSvOiW0cJz9yZfhB8SnWzwD4nKKnKcnmrdxbyfCwGYKgMOHJfSggg4fRTomDTHx)z8sJi2Mh1jd7F2vawbN1qEAicAyIgszd1)m6BP)6CCdj3qE1q(8B44Ddd8I1whMU2WR)mRmh1HBijBicAiF(nKInC8UHbEXARdtxB41FgV0iwxEdPsreAV(trWaVyT1HPRn86pLROMxkUueYfOmzOsvreAV(trGUGEWSywGZuedbR3I2R)uePUGEWAiblWznSWnevCx2g6zX1qSlbZZAir2kJggEdPqd9yZfhRi0B5YwHIatlmM1JnxCSbDb9GzXSaN1qEA40kxrncuCPiKlqzYqLQIa4x7jKGROEIIi0E9NIG(FMDf8dUAr5kQtbfxkc5cuMmuPQi0B5YwHIq)ZOVL(RZXnKKnKxnmrdX0cJz9yZfhB8SnWzwD4nKKnebkIq71FkcC2kdLRCfH(F245CkUuuprXLIqUaLjdvQkcfbLusXX7Mye0ELwSyoXoBhXCKlgV0iwxoF(J3nXiO9kTyXCID2oI5ixmRmh1Hj50uLGYX7Mye0ELwSyoXoBhXCKlgShAejjf4ZNIJ3nXiO9kTyXCID2MjbZG9qJiptOkbfdTx)zIrq7vAXI5e7SntcMPolaRYZ8eum0E9NjgbTxPflMtSZ2rmh5IPolaRYZ8eum0E9NjgbTxPflMtSZM6SaSkpZPkHhBU4gVMfR)2rj8Ga(8dTxPfRCYCjyEMobfhVBIrq7vAXI5e7SDeZrUy8sJyD5jKt2CKijfqqcp2CXnEnlw)TJs4bbkIq71FkIye0ELwSyoXoRi0iPzI1JnxCSI6jkxr90kUueYfOmzOsvrO3YLTcfbLne)Gm06ggAqSdYeRSG0E9NrUaLjJgYNFdXpidTUHj9ZcVyIf)S0Y5g5cuMmAivkI6CzxqA3wakc8dYqRBys)SWlMyXplTCUIOox2fK2T18SmQWffXefrO96pfbatWz6naCfrDUSliTBZzpAWuetuUIAkO4srixGYKHkvfXqW6TO96pfXuhyVHCv5YYD4gYnbxKAiQa8R0qk)TH18SmQWzi1WaWLLQgQdSxxEd5MYgSgYnx5szKAyb0WuLfllInSWnK6umxn8VgQ)NnEoNrrGr60kcazdMfyLlLrsrO3YLTcfH(F245CguSToTbKwreAV(tr4vUSyla4IKYvuZlfxkc5cuMmuPQicTx)PiaKnywGvUugjfHElx2kue6Fg9T0FDoUHKSHuOHjAOhBU4gVMfR)2rjnKNgsIAyIgszdrbbam4iDKl29J1as3q(8BifBOhm5Cdosh5ID)ynYfOmz0qQAyIgszdPyd1)ZgpNZ4vUSyla4IKbKUH853q9)SXZ5mOyBDAdiDdPQH853qGkpZTRmh1HBijBi3RHjAiqLN52vMJ6WnKNgoTIqJKMjwp2CXXkQNOCf1iqXLIqUaLjdvQkIq71FkcuzXYIOIyiy9w0E9NIGRum3xkEQAi1ImAO)neJ0PBiNYZAiNYZA4gPL7bXneyLlLrQHCYKRHCKgUGxdbw5szKqJBqAd)THHZKa7nuNjAeByb0WYXnKZVEwdlxrO3YLTcfH(NrFl9xNJBipKBifuUI6uqXLIqUaLjdvQkc9wUSvOi0)m6BP)6CCd5HCdPGIi0E9NIOoDSx41FkxrnjsXLIqUaLjdvQkIq71FkcVYLfBbaxKuedbR3I2R)ueCTi1W4gn8EVHCcSlnKlUzdLt2CKiTHOGEddg(Bykfe7neelnS8gc8BdtzzrSHXnAyD6ypSIqVLlBfkc5KnhjZqakD5nKNgYlE3q(8BikiaGbfBRtBaPBiF(nKYg6bto3qVYi8FnYfOmz0WeneN9Rly36(OHKSHuOHuPCf1Cpfxkc5cuMmuPQicTx)PiWzX45mlSHIyiy9w0E9NIiLSYZ8gIknKZ(xEd9VHGyPHeZcB0W)AicnquAyDnmTSi1W0YIudVsNjnexoy41FysBikO3W0YIud3yfgskc9wUSvOiqbbamELll2caUizaPByIgIccayqX260MXZ5AyIgQ)z03s)154gsYgYRgMOHOGaagm4yiNnMrbXzMXZ5AyIgoE3SbIIHEgK5fnRKTHKSHtmPqdt0q5KnhPgYtd5fVByIgowWAy2arX4LgrSnpQtg2)SRaScoRH80qmTWywp2CXXgmNIwS6WB4uA40neHB40nmrd9yZf341Sy93okPH80qeOCf1CdkUueYfOmzOsvrO3YLTcfbkiaGXRCzXwaWfjdiDd5ZVHOGaaguSToTbKwreAV(trGklwweRlx5kQNWBfxkc5cuMmuPQi0B5YwHIafeaWGIT1PnG0nKp)gI(yCdt0qGkpZTRmh1HBijBO(F245CguSToTzL5OoCd5ZVHOpg3WeneOYZC7kZrD4gsYgoncueH2R)ue0Vx)PCf1tMO4srixGYKHkvfHElx2kueOGaaguSToTbKUH853qGkpZTRmh1HBijB40tueH2R)ueBKwUheBbw5szKuUI6jtR4srixGYKHkvfrO96pfH(V0pII1ZelMU2YXkIHG1Br71FkcUsXCFP4PQHtDMOrSHZ)FiwxdZENtdJB0qSdca0qwHO0qpRWK2W4gnCoqcvAiQ4USnu)ZOH3WvMJ6A4kyKoTIqVLlBfkckBiLnC8UzlAZkZrD4gYtd5vd5ZVHavEMBxzoQd3qs2W0XwbktmBrB9sJiUHjA44DZw0gV0iA9AwAivnmrd1)m6BP)6CCdjzdrqdt0qkB44DZgikgV0iwxEd5ZVHyAHXSES5IJnE2g4mRo8gYtdN0qQAyIgkNS5izgcqPlVH8qUHtZ7gsvd5ZVHOpg3WeneOYZC7kZrD4gsYgIaLROEcfuCPiKlqzYqLQIi0E9NIqMPFoYAr)BOigcwVfTx)PisjdKqLg6zYkneN9GSrdrLgo)R0q9FJYR)Wn8Vg6zsd1)nalxrO3YLTcfbkiaGXRCzXwaWfjdiDd5ZVHu2q9FdWYndrOTbJj5vCAXixGYKrdPs5kQNWlfxkc5cuMmuPQigcwVfTx)Pi4(R0sdP363YrQH(3W)qyqS0qosq)NI4IzrrKsFh8YLAx7qWEDiHT6GXue6TCzRqriPeGfnTmmP03bVCP21oeSxhsyRoymfrO96pfrk9DWlxQDTdb71He2Qdgt5kQNGafxkIq71FkcqSylxMXkc5cuMmuPQCLRiEomosKwuCPOEIIlfHCbktgQuve6TCzRqrGccayYKyD7dy9mXYPyddiTIi0E9NIa7XIb3Cr5kQNwXLIqUaLjdvQkIq71Fkcm4buROiy1jw9qrWRPKRhkxrnfuCPiKlqzYqLQIi0E9NIy()dOwrrO3YLTcfbkiaGz()dX6Sa)oBaPByIgIPfgZ6XMlo24zBGZS6WBijB40nmrdPyd9GjNByGxS26W01gE9NrUaLjdfbRoXQhkcEnLC9q5kQ5LIlfHCbktgQuve6TCzRqriNS5i1qs2qkW7gMOHJ3nBrBwzoQd3qEAiVmiOHjAiLnu)pB8CoJx5YITaGlsMvMJ6WnKhYnmfmiOH853Wf8eGFZfJoCbjXQb36nYfOmz0qQAyIgIccay0mjwDG96Ynyp0i2qs2WjnmrdPydrbbambTqcw6vgH)l2Q3iDD5gq6gMOHuSHOGaagu2)dgi2nG0nmrdPydrbbamOyBDAdiDdt0qkBO(F245Cg9FPFefRNjwmDTLJnRmh1HBipnmfmiOH853qk2q9NwU4CZv5zUfiKgsvdt0qkBifBO(tlxCU5e9(SFhnKp)gQ)NnEoNjgbTxPflMtSZMvMJ6WnKhYnebnKp)goE3eJG2R0IfZj2z7iMJCXSYCuhUH80qsudPsreAV(trKjX62hW6zILtXgkxrncuCPiKlqzYqLQIqVLlBfkc5KnhPgsYgsbE3WenC8UzlAZkZrD4gYtd5LbbnmrdPSH6)zJNZz8kxwSfaCrYSYCuhUH8qUH8YGGgYNFdxWta(nxm6WfKeRgCR3ixGYKrdPQHjAikiaGrZKy1b2Rl3G9qJydjzdN0WenKInefeaWe0cjyPxze(VyREJ01LBaPByIgsXgIccayqz)pyGy3as3WenKYgsXgIccayqX260gq6gYNFd1FA5IZnNO3N97OHjAOhm5Cdosh5ID)ynYfOmz0WenefeaWGIT1PnRmh1HBipnmfAivnmrdPSH6)zJNZz0)L(ruSEMyX01wo2SYCuhUH80WuWGGgYNFdPyd1FA5IZnxLN5wGqAivnmrdPSHuSH6pTCX5Mt07Z(D0q(8BO(F245CMye0ELwSyoXoBwzoQd3qEi3qe0q(8B44DtmcAVslwmNyNTJyoYfZkZrD4gYtdjrnKQgMOHavEMBxzoQd3qEAijsreAV(trm))HyDwGFNvUYvUIiTS46pf1tZ7PNWBs00uqrWj2RUCSIGedcbcLAUrQ5(NQg2qUYKgwZ0)6ne43gYDa1v4mz5UgUskbyTYOH4FwAya6)C4YOH6S4YfSProfvN0qEnvnCQ)lTSUmAi3TGNa8BUyqi5Ug6Fd5Uf8eGFZfdcPrUaLjdURHuoHeOY0i3itIbHaHsn3i1C)tvdBixzsdRz6F9gc8Bd5UHaeGmN7A4kPeG1kJgI)zPHbO)ZHlJgQZIlxWMg5uuDsdNEYu1WP(V0Y6YOHe18u3qmsNhKqdjXBO)nmfbgnCuPlC9xdFAzd)3gszYu1qkNqcuzAKtr1jnCAkmvnCQ)lTSUmAirnp1neJ05bj0qs8g6FdtrGrdhv6cx)1WNw2W)THuMmvnKYPjbQmnYnYKyqiqOuZnsn3)u1WgYvM0WAM(xVHa)2qUdL9)Wd2FyURHRKsawRmAi(NLggG(phUmAOolUCbBAKtr1jnKctvdN6)slRlJgsuZtDdXiDEqcnKeVH(3Wuey0WrLUW1Fn8PLn8FBiLjtvdPCcjqLPrUrMedcbcLAUrQ5(NQg2qUYKgwZ0)6ne43gYD6)zJNZXDnCLucWALrdX)S0Wa0)5WLrd1zXLlytJCkQoPHtpvnCQ)lTSUmAi3HFqgADddcj31q)Bi3HFqgADddcPrUaLjdURHuonjqLPrUrMedcbcLAUrQ5(NQg2qUYKgwZ0)6ne43gYDphghjslCxdxjLaSwz0q8plnma9FoCz0qDwC5c20iNIQtAiVMQgo1)LwwxgnK7wWta(nxmiKCxd9VHC3cEcWV5IbH0ixGYKb31qkNqcuzAKtr1jnebtvdN6)slRlJgYDl4ja)MlgesURH(3qUBbpb43CXGqAKlqzYG7AiLtibQmnYnYCJZ0)6YOHt4DddTx)1qwHDSPrwrqVpqXefb3YTnKBkBWAi33cwJgzULBBicbyoi2B4esB408E6jnYnYCl32qUPSbRHieKytrnuhxddg(BiQ0qGh8gnm8gM5onEQso58c7M8YZarn6FozeY4s5yJKtbUh3qkO5ECdCdPaaccaTGaTmzccgrqHG3CVraa0i3iZTCBdN6S4Yf8u1iZTCBdr4gowWAyEomosKwS6WjpPH6mrJiUH(3WXcwdZZHXrI0IvhUPrMB52gIWnCQ)lTSEdtLRgs)pZUc(bxT0q)BiNO8gkKa9kyC9NPrMB52gIWneHymAyDUSliTxOmPHCtMGZ0Ba4nSaAispydZI0sdV3ZQlVHcdln0)goEtJm3YTneHBi33FCN3WSNnA4u)x6hrPHa)2qeAr3qWJjyCdr6b5ogRHRemgsneHw0Mg5g5q71Fyd9k6Fgn8KiNC6yRaLjKEXSqg4bxnTfTCH00bduiZ7gzUTHezRmAi5gYBsBi1)HW4lOXzV3qeAGO0qYnCcPnK4cAC27neHgiknKCdNM0gMI4gBi5gsbsBibNIwAi5gYRg5q71Fyd9k6Fgn8KiNC6yRaLjKEXSqgOymzjnDWafYtAK52gsOdM0qoLN1WSa7IPro0E9h2qVI(NrdpjYjNo2kqzcPxmlK3I26LgrmPPdgOqMe1ihAV(dBOxr)ZOHNe5KrSUXkdlMU2YXnYH2R)Wg6v0)mA4jroz03DMmSaSajzWPUCR)KqDnYH2R)Wg6v0)mA4jrozaMGZ0Ba4KwaKXpidTUHHge7GmXkliTx)zKlqzYGpF8dYqRBys)SWlMyXplTCUrUaLjJg5q71Fyd9k6Fgn8KiNm9(CyKwaKrbbamZ)FiwNf43zZ45CnYH2R)Wg6v0)mA4jrozD4wGFNjTaiJccayM))qSolWVZMXZ5AKBKdTx)HjVGNn0E9NLvyN0lMfYObloTqAbqgfeaWm))HyDwGFNnG0jO4ybRH55W4irAXQdVro0E9hojYjRdgZgAV(ZYkSt6fZc5NdJJePfslaYJfSgMNdJJePfRo8gzUTHKy3NdRHCYKtslBdPFmUqzsJCO96pCsKtMEFoSg5q71F4KiNSx5YITaGlsKwaKrbbam6WTa)oBgpNRro0E9hojYjRd3c87mPfazuqaaJoClWVZMXZ5AK52gMIpPH4S3Bi2LG5znYH2R)Wjro5f8SH2R)SSc7KEXSqg7sW8mslaYOGaagCwmEoZcByaP5ZhfeaWqVphMbKUro0E9hojYjJreKXSOboRro0E9hojYjRdgZgAV(ZYkSt6fZczS4G0KwaKdTxPf74DZw0K5DJCO96pCsKtwhmMn0E9NLvyN0lMfY6)zJNZ1iZTnKArVp73Xu1WPoWEdPqd)TH8QH6Fg9Bi9xN3WTOXn8VgIRlNjn0Jnx8g(GoUgsdFGgIklwweB4VnCaU1L3quzXYIydlGgciBWAiWkxkJudlCdbPBykgH2WGMMHudJgIanDdrOfDd5Kjxd5IB2Wc3qq6gg3OHCkgRH4)VgcemwdFaatJCO96pCsKtElAslaY6pTCX5Mt07Z(DKGsk6bto3GY(F4b7pSrUaLjd(8rbbamOS)hEW(dBaPPkbMwymRhBU4yJNTboZQdN8KeuQ)z03s)15yEMoXkaRGZcuMKySG1WSfTXlnIyBEuNmS)zxbyfCgpPJTcuMy2I26LgrCckPikiaGbfBRtBaP5Zx)pB8Codk2wN2asZNpLOGaaguSToTbKoH(F245CgazdMfyLlLrYastfv85R)z03s)15yYiibkiaGXRCzXwaWfjdiDcuqaaJx5YITaGlsMvMJ6WKKxjglynmBrB8sJi2Mh1jd7F2vawbNXdcOQro0E9hojYjVGNn0E9NLvyN0lMfYa1v4mzjTaiR)z03s)15yEitjcq40Xwbktmap4QPTOLlu1ihAV(dNe5KP3AoywoB4zKwaKhlynm0BnhmlNn8mJxAeX28Oozy)ZUcWk4mEipnVtO)z03s)15yEipnPS6eREqgbnYCBdtjbzEHW56rdXUempRro0E9hojYjRdgZgAV(ZYkSt6fZczSlbZZiTaiJccayqX260gq6gzUTHCLjnC(XEdfsGwoCLwAyQC1qnsAM0qk5kBfCwdjYwz0qcofT0q9J9gozccAOCYMJePnCoquAigCLgYrAOoUgohikn0ZcVH11qE1WC2JgmmvnYH2R)Wjrozor5KIfnzkPCYeeGWttHPGccayQth7fE9NfX6YTpG1ZeBkf8YzIbKMkeMs5KnhjJgCx58KOGbbtrozZrYSsUCjrjV49uqbbamAMeRoWED5gqAQOIQKLt2CKmRKlhPfazpyY5gu2)dpy)HnYfOmzKafeaWGY(F4b7pSz8CUeH2R0If1T(w55YIjZ7gzUTHH2R)Wjroz6)z2vWp4QfslaYEWKZnOS)hEW(dBKlqzYibkiaGbL9)Wd2FyZ45CjOuozZrkjkyqWuKt2CKmRKlxsuYlEpfuqaaJMjXQdSxxUbKMkQijLtMGaeEAkmfuqaatD6yVWR)SiwxU9bSEMytPGxotmG0uLi0ELwSOU13kpxwmzE3ihAV(dNe5KxWZgAV(ZYkSt6fZczu2)dpy)HjTai7bto3GY(F4b7pSrUaLjJeOGaagu2)dpy)HnJNZ1ihAV(dNe5KbK911dITOLlKQrsZeRhBU4yYtiTaiJccaycAHeS0Rmc)xSvVr66YnG0nYH2R)Wjroz6)z2vWp4Qfsb(1Ecj4KN0ihAV(dNe5K3arHunsAMy9yZfhtEcPfazkxbyfCwGYe(8PLfxyxo3odY8IMvYYZ4DZgikg6zqMx0SswQsmwWAy2arX4LgrSnpQtg2)SRaScoJhmTWywp2CXXgmNIwS6WNY0i80nYH2R)Wjrozg4fRTomDTHx)rQgjntSES5IJjpH0cGmLRaScolqzcF(0YIlSlNBNbzErZkz5z8UHbEXARdtxB41Fg6zqMx0SswQsmwWAyyGxS26W01gE9NXlnIyBEuNmS)zxbyfCgpyAHXSES5IJnyofTy1HpLPr4PBKdTx)HtICY0)ZSRGFWvlKc8R9esWjpPro0E9hojYj7zBGZS6WjvJKMjwp2CXXKNqAbqEfGvWzbktsmwWAy8SnWzwD4gV0iIT5rDYW(NDfGvWz8qjVsctlmM1JnxCSXZ2aNz1HpfErfjoLtsAoWUSizthmqHkew)3aSCJhyxSa)Arz)pmYfOmzGW6pTCX5Mt07Z(DKGskIccayqX260gqA(8X0cJz9yZfhB8SnWzwD48mHQg5q71F4KiNm9)m7k4hC1cPa)ApHeCYtAKdTx)HtICYOlOhmlMf4mslaYuUrnSsA5CtmgytD8q5KKMdsWQZInxWiSol2CbBb2q71FbJQPSIol2CX61SqvckX0cJz9yZfhBqxqpywmlWztj0E9NbDb9GzXSaNzgXCKlK4H2R)mOlOhmlMf4mJ(Xov8qzO96pdoBLHzeZrUqIhAV(ZGZwzy0p2PQro0E9hojYjJ5u0IvhoPfazmTWywp2CXXgmNIwS6W5zssOGaaguSToTbKEkt3ihAV(dNe5K9SnWzwD4KwaKX0cJz9yZfhB8SnWzwD48qHg5q71F4KiNmoBLbPfazuqaaJMjXQdSxxUbKobLOGaagm4yiNnMrbXzMXZ5sGccayWzX45mlSHz8Co(8rbbamOyBDAdinvnYH2R)Wjro5nquivJKMjwp2CXXKNqAbqgfeaWGIT1PnG0jglynmBGOy8sJi2Mh1jd7F2vawbNXZ0nYH2R)WjrozDWy2q71FwwHDsVywidumMSnYnYH2R)Wgu2)dpy)HjVbIcPAK0mX6XMloM8eslaYusrV0iwxoF(uoXm9uOLfxyxo3odY8IMvYYd5X7Mnqum0ZGmVOzLSuXNpLH2R0If1T(w55YIjpDIvawbNfOmHkQsGccayqD7gikMXZ5AKdTx)HnOS)hEW(dNe5KzGxS26W01gE9hPAK0mX6XMloM8eslaYRaScolqzscuqaadQBN))aQvmJNZ1ihAV(dBqz)p8G9hojYj7zBGZS6WjvJKMjwp2CXXKNqAbqEfGvWzbktsGccayqDRNTboZmEoxIXcwdJNTboZQd34LgrSnpQtg2)SRaScoJhk5vsyAHXSES5IJnE2g4mRo8PWlQiXPCssZb2LfjB6GbkuHW6)gGLB8a7If4xlk7)HrUaLjJg5q71Fydk7)HhS)Wjroz0f0dMfZcCgPfazuqaadQBrxqpywmlWzMXZ5AKdTx)HnOS)hEW(dNe5KXCkAXQdN0cGmkiaGb1TyofTygpNlbMwymRhBU4ydMtrlwD48mPro0E9h2GY(F4b7pCsKtgNTYG0cGmkiaGb1T4SvgMXZ5AKdTx)HnOS)hEW(dNe5KXCkAXQdN0cGmkiaGb1TyofTygpNRro0E9h2GY(F4b7pCsKt2Z2aNz1HtAbqgfeaWG6wpBdCMz8CUg5g5q71FyJ(F245CKJrq7vAXI5e7mPAK0mX6XMloM8esjtjLuC8UjgbTxPflMtSZ2rmh5IXlnI1LZN)4DtmcAVslwmNyNTJyoYfZkZrDysonvjOC8UjgbTxPflMtSZ2rmh5Ib7Hgrssb(8P44DtmcAVslwmNyNTzsWmyp0iYZeQsqXq71FMye0ELwSyoXoBZKGzQZcWQ8mpbfdTx)zIrq7vAXI5e7SDeZrUyQZcWQ8mpbfdTx)zIrq7vAXI5e7SPolaRYZCQs4XMlUXRzX6VDucpiGp)q7vAXkNmxcMNPtqXX7Mye0ELwSyoXoBhXCKlgV0iwxEc5KnhjssbeKWJnxCJxZI1F7OeEqqJCO96pSr)pB8CUKiNmatWz6naCslaYuIFqgADddni2bzIvwqAV(JpF8dYqRBys)SWlMyXplTCovKwNl7cs72AEwgv4c5jKwNl7cs72C2JgmYtiTox2fK2Tfaz8dYqRBys)SWlMyXplTCEJm32WPoWEd5QYLL7WnKBcUi1qub4xPHu(BdR5zzuHZqQHbGllvnuhyVU8gYnLnynKBUYLYi1WcOHPklwweByHBi1PyUA4Fnu)pB8CotJCO96pSr)pB8CUKiNSx5YITaGlsKIr60KbKnywGvUugjslaY6)zJNZzqX260gq6g5q71FyJ(F245CjrozazdMfyLlLrIunsAMy9yZfhtEcPfaz9pJ(w6VohtskKWJnxCJxZI1F7OeEirjOefeaWGJ0rUy3pwdinF(u0dMCUbhPJCXUFSg5cuMmOkbLuu)pB8CoJx5YITaGlsgqA(81)ZgpNZGIT1PnG0uXNpqLN52vMJ6WKK7LaOYZC7kZrDyEMUrMBBixPyUVu8u1qQfz0q)BigPt3qoLN1qoLN1Wnsl3dIBiWkxkJud5Kjxd5inCbVgcSYLYiHg3G0g(BddNjb2BOot0i2WcOHLJBiNF9SgwEJCO96pSr)pB8CUKiNmQSyzrK0cGS(NrFl9xNJ5HmfAKdTx)Hn6)zJNZLe5KRth7fE9hPfaz9pJ(w6VohZdzk0iZTnKRfPgg3OH37nKtGDPHCXnBOCYMJePnef0ByWWFdtPGyVHGyPHL3qGFBykllInmUrdRth7HBKdTx)Hn6)zJNZLe5K9kxwSfaCrI0cGSCYMJKziaLUCE4fV5ZhfeaWGIT1PnG085tPhm5Cd9kJW)1ixGYKrcC2VUGDR7dssbQAK52gMsw5zEdrLgYz)lVH(3qqS0qIzHnA4FneHgiknSUgMwwKAyAzrQHxPZKgIlhm86pmPnef0ByAzrQHBScdPg5q71FyJ(F245CjrozCwmEoZcBqAbqgfeaW4vUSyla4IKbKobkiaGbfBRtBgpNlH(NrFl9xNJjjVsGccayWGJHC2ygfeNzgpNlX4DZgikg6zqMx0SswsoXKcjKt2CK4Hx8oXybRHzdefJxAeX28Oozy)ZUcWk4mEW0cJz9yZfhBWCkAXQdFktJWtNWJnxCJxZI1F7OeEqqJCO96pSr)pB8CUKiNmQSyzrSUCslaYOGaagVYLfBbaxKmG085JccayqX260gq6g5q71FyJ(F245Cjroz63R)iTaiJccayqX260gqA(8rFmobqLN52vMJ6WKu)pB8Codk2wN2SYCuhMpF0hJtau5zUDL5OomjNgbnYH2R)Wg9)SXZ5sICYBKwUheBbw5szKiTaiJccayqX260gqA(8bQ8m3UYCuhMKtpPrMBBixPyUVu8u1WPot0i2W5)peRRHzVZPHXnAi2bbaAiRquAONvysByCJgohiHknevCx2gQ)z0WB4kZrDnCfmsNUro0E9h2O)NnEoxsKtw)x6hrX6zIftxB5yslaYus54DZw0MvMJ6W8Wl(8bQ8m3UYCuhMKPJTcuMy2I26LgrCIX7MTOnEPr061Sqvc9pJ(w6VohtseKGYX7MnqumEPrSUC(8X0cJz9yZfhB8SnWzwD48mHQeYjBosMHau6Y5H808Mk(8rFmobqLN52vMJ6WKebnYCBdtjdKqLg6zYkneN9GSrdrLgo)R0q9FJYR)Wn8Vg6zsd1)nalVro0E9h2O)NnEoxsKtwMPFoYAr)BqAbqgfeaW4vUSyla4IKbKMpFk1)nal3meH2gmMKxXPfJCbktgu1iZTnK7VslnKERFlhPg6Fd)dHbXsd5ib9FnYH2R)Wg9)SXZ5sICYGyXwUmt6fZc5u67GxUu7Ahc2RdjSvhmgPfazjLaSOPLHjL(o4Ll1U2HG96qcB1bJ1ihAV(dB0)ZgpNljYjdIfB5YmUrUro0E9h2aumMSK3arHunsAMy9yZfhtEcPfa50XwbktmafJjl5jjwbyfCwGYKeJ3nBGOyONbzErZkzjj5jMPNcTS4c7Y52zqMx0Ss2g5q71FydqXyYMe5K3arH0cGC6yRaLjgGIXKL80nYH2R)WgGIXKnjYjZaVyT1HPRn86pslaYPJTcuMyakgtwYuOro0E9h2aumMSjrozmNIwiTaiNo2kqzIbOymzjZRg5q71FydqXyYMe5KXzRmiTaiJccayWGJHC2ygfeNzgpNRro0E9h2aumMSjrozaMGZ0Ba4KwaKXpidTUHHge7GmXkliTx)zKlqzYGpF8dYqRBys)SWlMyXplTCUrUaLjdsRZLDbPDBnplJkCH8esRZLDbPDBo7rdg5jKwNl7cs72cGm(bzO1nmPFw4ftS4NLwoVrUro0E9h2auxHZKLm9)m7k4hC1cPa)ApHeCYtAKdTx)Hna1v4mztICY4iDKl29JL0cGmkiaGbhPJCXUFSMvMJ6WKKcnYH2R)WgG6kCMSjroz6TMdMLZgEgPfazkhlynm0BnhmlNn8mJxAeX28Oozy)ZUcWk4mEOWuOetlmM1JnxCSHER5Gz5SHNL0eQsGPfgZ6XMlo2qV1CWSC2WZ4zcv85JPfgZ6XMlo2qV1CWSC2WZ4HskK0KP4bto3Gduz9)9mJCbktgu1ihAV(dBaQRWzYMe5K3IMunsAMy9yZfhtEcPfa5vawbNfOmjXybRHzlAJxAeX28Oozy)ZUcWk4mEshBfOmXSfT1lnI4eusjkiaGXRCzXwaWfjdinF(u0lnI1LtvckrbbamOS)hEW(dBaP5ZNIEWKZnOS)hEW(dBKlqzYGk(8POhm5CdoqL1)3ZmYfOmzqvckX0cJz9yZfhBO3AoywoB4zKNWNpf9GjNBO3AoywoB4zg5cuMmOkbLH2R0ID8UzlAY8MpFV0iwxEIq7vAXoE3Sfn5j85tXf8eGFZfZydW8m3(a2Hi0wGxdI5ZNIEWKZn4avw)FpZixGYKbvnYH2R)WgG6kCMSjrozCKoYf7(XsAbqgfeaWGJ0rUy3pwZkZrDyssP(NrFl9xNJtAcvtjfMcVnuOro0E9h2auxHZKnjYjdi7RRheBrlxiDoibRCYMJe5jKQrsZeRhBU4yYtAKdTx)Hna1v4mztICYaY(66bXw0Yfs1iPzI1JnxCm5jKwaKrbbamOyBDAdiDcpyY5g8dYSpG1ZelWVc2nYfOmzWNV(F245Cg9FPFefRNjwmDTLJnRmh1Hj5Ke6pTCX5MRYZClqinYnYH2R)WMNdJJePfYypwm4MlKwaKrbbamzsSU9bSEMy5uSHbKUro0E9h28CyCKiTKe5KXGhqTcPS6eREqMxtjxpAKdTx)Hnphghjsljro55)pGAfsz1jw9GmVMsUEqAbqgfeaWm))HyDwGFNnG0jW0cJz9yZfhB8SnWzwD4KC6eu0dMCUHbEXARdtxB41Fg5cuMmAKdTx)Hnphghjsljro5mjw3(awptSCk2G0cGSCYMJejPaVtmE3SfTzL5Oomp8YGGeuQ)NnEoNXRCzXwaWfjZkZrDyEiNcgeWN)cEcWV5IrhUGKy1GB9uLafeaWOzsS6a71LBWEOrKKtsqruqaatqlKGLELr4)IT6nsxxUbKobfrbbamOS)hmqSBaPtqruqaadk2wN2asNGs9)SXZ5m6)s)ikwptSy6AlhBwzoQdZtkyqaF(uu)PLlo3CvEMBbcHQeusr9NwU4CZj69z)o4Zx)pB8CotmcAVslwmNyNnRmh1H5Hmc4ZF8UjgbTxPflMtSZ2rmh5IzL5OompKiQAKdTx)Hnphghjsljro55)peRZc87mPfaz5KnhjssbENy8UzlAZkZrDyE4LbbjOu)pB8CoJx5YITaGlsMvMJ6W8qMxgeWN)cEcWV5IrhUGKy1GB9uLafeaWOzsS6a71LBWEOrKKtsqruqaatqlKGLELr4)IT6nsxxUbKobfrbbamOS)hmqSBaPtqjfrbbamOyBDAdinF(6pTCX5Mt07Z(DKWdMCUbhPJCXUFSg5cuMmsGccayqX260MvMJ6W8KcuLGs9)SXZ5m6)s)ikwptSy6AlhBwzoQdZtkyqaF(uu)PLlo3CvEMBbcHQeusr9NwU4CZj69z)o4Zx)pB8CotmcAVslwmNyNnRmh1H5Hmc4ZF8UjgbTxPflMtSZ2rmh5IzL5OompKiQsau5zUDL5OompKOg5g5q71FydwCqAYmWlwBDy6AdV(J0cGS(tlxCU5e9(SFhjW0cJz9yZfhB8SnWzwD4KKxj0)m6BP)6Cmjrqck6LgX6Ytqruqaadk2wN2as3ihAV(dBWIdsNe5KP)Nzxb)GRwif4x7jKGtEsJCO96pSbloiDsKtghPJCXUFSKwaK9GjNBaKnywGvUugjJCbktgj0)ZgpNZaiBWSaRCPmsgq6euefeaWGJ0rUy3pwdiDc9pJ(w6VohZZKeJ3nBGOy8sJyD5jOC8UHbEXARdtxB41FgV0iwxoF(u0dMCUHbEXARdtxB41Fg5cuMmOQro0E9h2GfhKojYjt)pZUc(bxTqAbq2dMCUbL9)Wd2FyJCbktgjqbbamOS)hEW(dBgpNlbLYjBosjrbdcMICYMJKzLC5sIsEX7PGccay0mjwDG96YnG0urfjPCYeeGWttHPGccayQth7fE9NfX6YTpG1ZeBkf8YzIbKMQeH2R0If1T(w55YIjZ7g5q71FydwCq6KiNSoymBO96plRWoPxmlKrz)p8G9hM0cGShm5Cdk7)HhS)Wg5cuMmsGccayqz)p8G9h2mEoxck1)m6BP)6CmjraF(yAHXSES5IJnE2g4mRoCYtOQro0E9h2GfhKojYjRdgZgAV(ZYkSt6fZcz9)SXZ5AKdTx)HnyXbPtICY6GXSH2R)SSc7KEXSqgOUcNjlPfaz9pJ(w6VohZdfsqjkiaGbL9)Wd2FydinF(u0dMCUbL9)Wd2FyJCbktgu1i3ihAV(dBWUempJm9)m7k4hC1cPa)ApHeCYtAK52gIqdeLgEImWnCFW8mgsneb8MeVHpqdlh3qMC5EwddVHrdNRRMbNBO)nedU0bg3qC2kdCdh0sJCO96pSb7sW8SKiN8gikKQrsZeRhBU4yYtiTait54DZgikg6zqMx0SswsoXGa(8xbyfCwGYeQsmwWAy2arX4LgrSnpQtg2)SRaScoJNP5ZNsAzXf2LZTZGmVOzLS8mE3SbIIHEgK5fnRKnbkiaGbfBRtBaPtGPfgZ6XMlo24zBGZS6WjjfsO)0YfNBorVp73bv85JccayqX260MvMJ6WKCsJCO96pSb7sW8SKiNmd8I1whMU2WR)iTaiJPfgZ6XMlo24zBGZS6WjjfsScWk4SaLjjglynmmWlwBDy6AdV(Z4LgrSnpQtg2)SRaScoJheKGs9pJ(w6VohtMx85pE3WaVyT1HPRn86pZkZrDysIa(8P44Ddd8I1whMU2WR)mEPrSUCQAK52gM6c6bRHeSaN1Wc3quXDzBONfxdXUempRHezRmAy4nKcn0JnxCCJCO96pSb7sW8SKiNm6c6bZIzboJ0cGmMwymRhBU4yd6c6bZIzboJNPBKdTx)HnyxcMNLe5KP)Nzxb)GRwif4x7jKGtEsJCO96pSb7sW8SKiNmoBLbPfaz9pJ(w6VohtsELatlmM1JnxCSXZ2aNz1Htse0i3ihAV(dBqdwCAHmg8aQviTaiJccayenROXIf)SynJNZLafeaWiAwrJfld8I1mEoxckxbyfCwGYe(8Pm0ELwSYjZLG5zsIq7vAXoE3GbpGAfsgAVslw5K5sWurvJCO96pSbnyXPLKiNm2JfdU5cPfazuqaaJOzfnwS4NfRzL5Oompt4Ds6a7wVMf(8rbbamIMv0yXYaVynRmh1H5zcVtshy361S0ihAV(dBqdwCAjjYjJ9ybQviTaiJccayenROXILbEXAwzoQdZJoWU1RzHpFuqaaJOzfnwS4NfRz8CUe4NfRv0SIgl8WB(8rbbamIMv0yXIFwSMXZ5sWaVyTIMv0ybHdTx)z4SHNzQZcWQ8mNKtAKdTx)HnObloTKe5K5SHNrAbqgfeaWiAwrJfl(zXAwzoQdZJoWU1RzHpFuqaaJOzfnwSmWlwZ45CjyGxSwrZkASGWH2R)mC2WZm1zbyvEMZdVveyArROEcVPGYvUsb]] )


end
