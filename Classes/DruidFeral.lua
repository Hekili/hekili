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


    spec:RegisterPack( "Feral", 20210713, [[dS0ZNbqiIcpcjPUeIiztusFsuqJIiCkIOvjvKxrjmlePBbbSlk(fLOHruYXKkTmPcpdryAefDniOTrukFtQOACeLQohrPY6efQ5HK4EiQ9rKCqerPfkk6HiIyIIcWgffsFuuGCserXkHOMjss6MIcODIK6NIcXqrePAPijXtryQeP(kIiLXkvuAVK8xrgmWHfwmKEmPMSuUmQnRkFwunAk1PLSAPIIxdHMnHBlvTBv(nOHJuhxuGA5k9COMovxxvTDrPVJeJhc05HiRhrunFIQ9RyvxL0kIw4SI6oKvhDLvN3Legzj7KPS6kBkchjAwrqhAeJCwrCrpRiYO8gcfbDGKagnL0kcm8VAwry7onoJT0Y8YT)OgnS3sC1)fHxWtVXZTex9AlveO)s4KmNcvr0cNvu3HS6ORS68UKWilzhjKDYu2PiIVBdxfbr1tsue2vRXNcvr0ySwrKr5nedidy)vBqg5VaPb0LeKoGoKvhDhKhKZO8gIbqYssNQoaDCdiey4aq5b8G)RnGWhGT704m2slZlSBYl3(JA0WEl7SXrYJnSu2K9Yoztl7LDYoz7HW4PzeQ5UDrylcseYs23I3BqEqMKyhxoJZ4bzeyaT9xndKIGchz5KoCYDhG2M1iIhGdhqB)vZaPiOWrwoPd3miJadGKaVS86ditPhanekslJH)vZdWHdGsu(ayeKEzmUGNzqgbgajBRnG6CE3pTxOcEazubJT1B88buVbGe8pa7ilpGd621LpawG5b4Wb0GgfHOWowjTIavaHnpeWdRKwrDxL0kc(cub3uzQicTxWtrSbISIqVLZBfkcjgGmgGxAeRlFaYLpajgqxthdOtdGMxCHD(8u)x4fTO4DasrEanOB2ar2q3)fErlkEhGKdqU8biXacTxz5eQN8TYZ5fpaYdOJbyDal)wgBhOcEasoajhG1bG(FpdQN2ar20GuofHgjTGtES5SJvu3v5kQ7qjTIGVavWnvMkIq7f8ueI)fBQomDTHxWtrO3Y5TcfXYVLX2bQGhG1bG(FpdQN6HW7vlBAqkNIqJKwWjp2C2XkQ7QCf1KqjTIGVavWnvMkIq7f8ueU9gy7KoCfHElN3kuel)wgBhOcEawha6)9mOEYT3aBBAqk3aSoG2(RMXT3aBN0HB8sJioLh1XTe8sl)wgBpaPgGedqMdWIbGPzHi5XMZo242BGTt6WhqNgGmhGKdWYbiXa6oalgqFGDErkLneFEasoaeyaA41(LB8a7C6b3eQacBg(cub3ueAK0co5XMZowrDxLROwMkPve8fOcUPYurO3Y5Tcfb6)9mOEcD)EisyrGTnniLtreAVGNIaD)EisyrGTvUIAeQKwrWxGk4MktfHElN3kueO)3ZG6jmLIMnniLBawhaMMfIKhBo7ydMsrZjD4dqQb0vreAVGNIatPO5KoCLROw2usRi4lqfCtLPIqVLZBfkc0)7zq9e2E5MPbPCkIq7f8uey7LBkxrDNRKwrWxGk4MktfHElN3kueO)3ZG6jmLIMnniLtreAVGNIatPO5KoCLROw2RKwrWxGk4MktfHElN3kueO)3ZG6j3EdSTPbPCkIq7f8ueU9gy7KoCLRCfXRUcBZRsAf1DvsRi4lqfCtLPI4b30XiOROURIi0EbpfbnekslJH)vZkxrDhkPve8fOcUPYurO3Y5Tcfb6)9m4iBKZPfgRz5(Oo8aOYaiHIi0EbpfboYg5CAHXQCf1KqjTIGVavWnvMkc9woVvOiKyaT9xnd9w9Hirzd324LgrCkpQJBj4Lw(Tm2EasnasmGonajgaMMfIKhBo7yd9w9Hirzd3EawmGUdqYbyDayAwisES5SJn0B1hIeLnC7bi1a6oajhGC5datZcrYJnNDSHER(qKOSHBpaPgGedGedWIb0DaDAaEi4Zn4aLxhcDBdFbQGBdqsfrO9cEkc6T6drIYgUTYvultL0kc(cub3uzQicTxWtrSfTIqVLZBfkILFlJTdubpaRdOT)Qz2I24LgrCkpQJBj4Lw(Tm2EasnGSXwbQGnBrN8sJiEawhGedqIbG(FpJx58ItV)IK5tpa5YhGmgGxAeRlFasoaRdqIbG(FpdQacBEiGh28PhGC5dqgdWdbFUbvaHnpeWdB4lqfCBasoa5YhGmgGhc(Cdoq51Hq32WxGk42aKCawhGedatZcrYJnNDSHER(qKOSHBpaYdO7aKlFaYyaEi4Zn0B1hIeLnCBdFbQGBdqYbyDasmGq7vwo1GUzl6bqEaYAaYLpaV0iwx(aSoGq7vwo1GUzl6bqEaDhGC5dqgdy)h)GBoBAB8ZT9e8LAmtNEq9hB4lqfCBaYLpazmape85gCGYRdHUTHVavWTbiPIqJKwWjp2C2XkQ7QCf1iujTIGVavWnvMkc9woVvOiq)VNbhzJCoTWynl3h1HhavgGedqd7rHjAyDoEawmGUdqYb0PbiBdOtdqwgsOicTxWtrGJSroNwySkxrTSPKwrWxGk4MktfrFGGj(4nhjf1DveH2l4PiE8c1f8JtOLZkcnsAbN8yZzhROURYvu35kPve8fOcUPYureAVGNI4XluxWpoHwoRi0B58wHIa9)EguCQoT5tpaRdWdbFUbd)Ie8LCBo9GlJDdFbQGBkcnsAbN8yZzhROURYvUIaneXPzL0kQ7QKwrWxGk4MktfHElN3kueO)3ZWArrJ5egkI10GuUbyDaO)3ZWArrJ5K4FXAAqk3aSoajgWYVLX2bQGhGC5dqIbeAVYYj(4(IXdqQb0DawhqO9klNAq3G)3RwEauzaH2RSCIpUVy8aKCasQicTxWtrG)3Rww5kQ7qjTIGVavWnvMkc9woVvOiq)VNH1IIgZjmueRz5(Oo8aKAaDL1aSya6a7jV65bix(aq)VNH1IIgZjX)I1SCFuhEasnGUYAawmaDG9Kx9SIi0Ebpfb2Jf)3Cw5kQjHsAfbFbQGBQmve6TCERqrG(FpdRffnMtI)fRz5(Oo8aKAa6a7jV65bix(aq)VNH1IIgZjmueRPbPCdW6aWqrSjwlkAmpaPgGSgGC5da9)EgwlkAmNWqrSMgKYnaRdq8VytSwu0yEaiWacTxWZqzd32ux6jQCBFauzaDveH2l4PiWESVAzLROwMkPve8fOcUPYurO3Y5Tcfb6)9mSwu0yoHHIynl3h1HhGudqhyp5vppa5Yha6)9mSwu0yoj(xSMgKYnaRdq8VytSwu0yEaiWacTxWZqzd32ux6jQCBFasnazPicTxWtrqzd3w5kxr04x8fUsAf1DvsRi4lqfCtLPIqVLZBfkc0)7z6HWdX6sp42B(0dW6aKXaA7VAgifbfoYYjD4kIq7f8ue7)sH2l4Lef2veIc7Pl6zfbAiItZkxrDhkPve8fOcUPYurO3Y5TcfrB)vZaPiOWrwoPdxreAVGNIqhcrk0EbVKOWUIquypDrpRiGueu4ilRCf1KqjTIGVavWnvMkIgJ1Br7f8ueK0xifXaOyZhNL3bqdX4cvWkIq7f8ue0lKIq5kQLPsAfbFbQGBQmve6TCERqrG(FpJo80dU9MgKYPicTxWtr4voV407ViPCf1iujTIGVavWnvMkc9woVvOiq)VNrhE6b3Etds5ueH2l4Pi0HNEWTx5kQLnL0kc(cub3uzQiAmwVfTxWtrKroEayBOpaSZHWTveH2l4Pi2)LcTxWljkSRi0B58wHIa9)EgSD0Gu6zrZ8PhGC5da9)Eg6fsry(0kcrH90f9SIa7CiCBLROUZvsRicTxWtrGr8lej0aBRi4lqfCtLPYvul7vsRi4lqfCtLPIi0EbpfHoeIuO9cEjrHDfHOWE6IEwrOHqrds5uUIAzNsAfbFbQGBQmveH2l4Pi2Iwr0ySElAVGNIGAwVqbCBz8aijb2hajgaChGmhGg2JchanSoFaBrJha8gaUUCbpap2C2ha874QXda(gakVyErCaWDaT)wx(aq5fZlIdOEd4XBigWB5JKJ0ak8a(0diJqvgqqtlqAaXaqOMEauLIEauS5BasNrhqHhWNEaX1gaLsigagcVb8cHyaW3ZOi0B58wHIqdZYxCU5y9cfWTnaRdqIbiJb4HGp3GkGWMhc4Hn8fOcUna5Yha6)9mOciS5HaEyZNEasoaRdatZcrYJnNDSXT3aBN0HpaYdO7aSoajgGg2Jct0W6C8aKAaDmaRdy53Yy7avWdW6aA7VAMTOnEPreNYJ64wcEPLFlJThGudiBSvGkyZw0jV0iIhGC5dqd7rHjAyDoEaKhachG1bG(FpJx58ItV)IK5tpaRda9)EgVY5fNE)fjZY9rD4bqLbqIbyDaT9xnZw0gV0iIt5rDClbV0YVLX2dqQbGWbi5aSoajgGmga6)9mO4uDAZNEaYLpanekAqkNbfNQtB(0dqU8biXaq)VNbfNQtB(0dW6a0qOObPCMhVHi9w(i5iz(0dqYbiPYvu3vwkPve8fOcUPYurO3Y5TcfHg2Jct0W6C8aKI8aKyaiCaiWaYgBfOc28G)vtNqlNhGKkIq7f8ue7)sH2l4Lef2veIc7Pl6zfXRUcBZRYvu3TRsAfbFbQGBQmve6TCERqr02F1m0B1hIeLnCBJxAeXP8OoULGxA53Yy7bif5b0HSgG1bOH9OWenSohpaPipGoueH2l4PiO3QpejkB42kcrDCs3ueiu5kQ72HsAfbFbQGBQmvengR3I2l4PiYa)cVqGCDBayNdHBRicTxWtrOdHifAVGxsuyxrO3Y5Tcfb6)9mO4uDAZNwrikSNUONveyNdHBRCf1DjHsAfbFbQGBQmvengR3I2l4PiK2Mhqpe7dGrqA(WvwEazk9a0iPf8aKqA7LX2dGWE52aiOu08a0qSpGUDr4a4J3CKiDa9bI8aW)LhafEa64gqFGipa3o8bu3aK5aYfq0qGLurGzTIqIbiXa62fHdabgqhKyaDAaO)3ZuNo2l8cEjeRlpbFj3MtDM)LlyZNEasoaeyasma(4nhjJ(VlF(aSyaKWGWb0PbWhV5izwoNVbyXaKyaYuwdOtda9)EgTGJvhyVUCZNEasoajhGKdWYbWhV5izwoNpfrO9cEkckr5kc9woVvOi8qWNBqfqyZdb8Wg(cub3gG1bG(FpdQacBEiGh20GuUbyDaH2RSCc1t(w558Iha5bilLROURmvsRi4lqfCtLPIOXy9w0EbpfrO9cEytJFXx4wq2sAiuKwgd)RMjTEK9qWNBqfqyZdb8Wg(cub3SI(FpdQacBEiGh20GuoRsWhV5izbjmiSt8XBosMLZ5ZcjKPS6e6)9mAbhRoWED5MpTKssfj62fHiqhKOtO)3ZuNo2l8cEjeRlpbFj3MtDM)LlyZNwsRH2RSCc1t(w558IjllfrO9cEkI9FPq7f8sIc7kc9woVvOi8qWNBqfqyZdb8Wg(cub3gG1bG(FpdQacBEiGh20GuofHOWE6IEwrGkGWMhc4HvUI6UiujTIGVavWnvMkIq7f8uepEH6c(Xj0YzfHElN3kueO)3Ze0mcMOxUfoCXj9gzRl38PveAK0co5XMZowrDxLROURSPKwrWxGk4MktfXdUPJrqxrDxfrO9cEkcAiuKwgd)RMvUI6UDUsAfbFbQGBQmveH2l4Pi2arwrO3Y5TcfHedy53Yy7avWdqU8bqZlUWoFEQ)l8Iwu8oaPgqd6MnqKn09FHx0II3bi5aSoG2(RMzdezJxAeXP8OoULGxA53Yy7bi1aW0SqK8yZzhBWukAoPdFaDAaDmaeyaDOi0iPfCYJnNDSI6UkxrDxzVsAfbFbQGBQmveH2l4Pie)l2uDy6AdVGNIqVLZBfkcjgWYVLX2bQGhGC5dGMxCHD(8u)x4fTO4DasnGg0nI)fBQomDTHxWZq3)fErlkEhGKdW6aA7VAgX)InvhMU2Wl4z8sJioLh1XTe8sl)wgBpaPgaMMfIKhBo7ydMsrZjD4dOtdOJbGadOdfHgjTGtES5SJvu3v5kQ7k7usRi4lqfCtLPI4b30XiOROURIi0EbpfbnekslJH)vZkxrDhYsjTIGVavWnvMkIq7f8ueU9gy7KoCfHElN3kuel)wgBhOcEawhqB)vZ42BGTt6WnEPreNYJ64wcEPLFlJThGudqIbiZbyXaW0SqK8yZzhBC7nW2jD4dOtdqMdqYby5aKyaDhGfdOpWoViLYgIppajhacman8A)YnEGDo9GBcvaHndFbQGBdabgGgMLV4CZX6fkGBBawhGedqgda9)EguCQoT5tpa5YhaMMfIKhBo7yJBVb2oPdFasnGUdqsfHgjTGtES5SJvu3v5kQ7ORsAfbFbQGBQmvep4MogbDf1DveH2l4PiOHqrAzm8VAw5kQ7OdL0kc(cub3uzQi0B58wHIqIbSr1sCw(Ct0AytDdqQbiXa6oalgqFGGjTDS5mEaiWa02XMZ40BdTxWledqYb0PbSS2o2Co5vppajhG1biXaW0SqK8yZzhBq3VhIewey7b0PbeAVGNbD)EisyrGTnTOpY5by5acTxWZGUFpejSiW2gne7dqYbi1aKyaH2l4zW2l3mTOpY5by5acTxWZGTxUz0qSpajveH2l4Piq3VhIeweyBLROUdsOKwrWxGk4MktfHElN3kueyAwisES5SJnykfnN0HpaPgq3byXaq)VNbfNQtB(0dOtdOdfrO9cEkcmLIMt6WvUI6oKPsAfbFbQGBQmve6TCERqrGPzHi5XMZo242BGTt6WhGudGekIq7f8ueU9gy7KoCLROUdeQKwrWxGk4MktfHElN3kueO)3ZOfCS6a71LB(0dW6aKyaO)3ZG)TgFPOh9JTnniLBawha6)9my7ObP0ZIMPbPCdqU8bG(FpdkovN28PhGKkIq7f8uey7LBkxrDhYMsAfbFbQGBQmveH2l4Pi2arwrO3Y5Tcfb6)9mO4uDAZNEawhqB)vZSbISXlnI4uEuh3sWlT8BzS9aKAaDOi0iPfCYJnNDSI6UkxrDhDUsAfbFbQGBQmveH2l4Pi0HqKcTxWljkSRief2tx0ZkIxje8QCLRiOxwd7rdxjTI6UkPve8fOcUPYuraPvey2veH2l4PiYgBfOcwrKneFwrilfr2ytx0ZkIh8VA6eA5SYvu3HsAfbFbQGBQmveqAfbMDfrO9cEkISXwbQGvezdXNveDvengR3I2l4PiiSxUnaYdqwKoaQHhcGVGgBd9bqvce5bqEaDjDaexqJTH(aOkbI8aipGoiDauvsMbqEaKG0bqqPO5bqEaYurKn20f9SI4vcbVkxrnjusRi4lqfCtLPIasRiWSRicTxWtrKn2kqfSIiBi(SIOZvengR3I2l4Pii0HGhaLYThGDGD2OiYgB6IEwrSfDYlnIyLROwMkPveH2l4PiqSU2YTeMU2YXkc(cub3uzQCf1iujTIi0Ebpfbk0Db3sprGe3OuxEYHiyDkc(cub3uzQCf1YMsAfbFbQGBQmve6TCERqrGHFbADnd9h7FbN49t7f8m8fOcUna5Yhag(fO11mzHIWlbNWqrw(CdFbQGBkIq7f8uepbJT1B8CLROUZvsRi4lqfCtLPIqVLZBfkc0)7z6HWdX6sp42BAqkNIi0Ebpfb9cPiuUIAzVsAfbFbQGBQmve6TCERqrG(FptpeEiwx6b3Etds5ueH2l4Pi0HNEWTx5kxr8kHGxL0kQ7QKwrWxGk4MktfrO9cEkInqKve6TCERqrKn2kqfS5vcbVdG8a6oaRdy53Yy7avWdW6aAq3SbISHU)l8Iwu8oaQqEaDnDmGonaAEXf25Zt9FHx0IIxfHgjTGtES5SJvu3v5kQ7qjTIGVavWnvMkc9woVvOiYgBfOc28kHG3bqEaDOicTxWtrSbISYvutcL0kc(cub3uzQi0B58wHIiBSvGkyZRecEha5bqcfrO9cEkcX)InvhMU2Wl4PCf1YujTIGVavWnvMkc9woVvOiYgBfOc28kHG3bqEaYureAVGNIatPO5KoCLROgHkPve8fOcUPYurO3Y5Tcfb6)9m4FRXxk6r)yBtds5ueH2l4PiW2l3uUIAztjTIGVavWnvMkc9woVvOiWWVaTUMH(J9VGt8(P9cEg(cub3gGC5dad)c06AMSqr4LGtyOilFUHVavWnfrDoV7N2t1trGHFbADntwOi8sWjmuKLpxruNZ7(P9u13ZTkCwr0vreAVGNI4jySTEJNRiQZ5D)0EkxardHIORYvUIa7CiCBL0kQ7QKwrWxGk4MktfXdUPJrqxrDxfrO9cEkcAiuKwgd)RMvUI6ousRi4lqfCtLPIi0EbpfXgiYkcnsAbN8yZzhROURIqVLZBfkcjgqd6MnqKn09FHx0II3bqLb01GWbix(aw(Tm2oqf8aKCawhqB)vZSbISXlnI4uEuh3sWlT8BzS9aKAaDma5YhGedGMxCHD(8u)x4fTO4DasnGg0nBGiBO7)cVOffVdW6aq)VNbfNQtB(0dW6aW0SqK8yZzhBC7nW2jD4dGkdGedW6a0WS8fNBowVqbCBdqYbix(aq)VNbfNQtBwUpQdpaQmGUkIgJ1Br7f8ueuLarEahZn8aw4p3wG0aqOSiPga8nGYXdqWxUBpGWhqmG(6Q(F)aC4aW)LoW4bGTxUHhqJMvUIAsOKwrWxGk4MktfHElN3kueyAwisES5SJnU9gy7Ko8bqLbqIbyDal)wgBhOcEawhqB)vZi(xSP6W01gEbpJxAeXP8OoULGxA53Yy7bi1aq4aSoajgGg2Jct0W6C8aipazoa5Yhqd6gX)InvhMU2Wl4zwUpQdpaQmaeoa5YhGmgqd6gX)InvhMU2Wl4z8sJyD5dqsfrO9cEkcX)InvhMU2Wl4PCf1YujTIGVavWnvMkIq7f8ueO73drclcSTIOXy9w0EbpfrM73dXaieb2EafEaOS78oa3oUbGDoeU9aiSxUnGWhajgGhBo7yfHElN3kueyAwisES5SJnO73drclcS9aKAaDOCf1iujTIGVavWnvMkIhCthJGUI6UkIq7f8ue0qOiTmg(xnRCf1YMsAfbFbQGBQmve6TCERqrOH9OWenSohpaQmazoaRdatZcrYJnNDSXT3aBN0HpaQmaeQicTxWtrGTxUPCLRi0qOObPCkPvu3vjTIGVavWnvMkcfHesiJg0nrlO9klNWuITp1I(iNnEPrSUC5YBq3eTG2RSCctj2(ul6JC2SCFuhMkDiPvjAq3eTG2RSCctj2(ul6JC2G9qJiviHC5YObDt0cAVYYjmLy7t2Cimyp0ikvxjTkJq7f8mrlO9klNWuITpzZHWux6jQCB3QmcTxWZeTG2RSCctj2(ul6JC2ux6jQCB3QmcTxWZeTG2RSCctj2EtDPNOYTDjT6XMZUXREo5WuRyPqOC5H2RSCIpUVySuDyvgnOBIwq7vwoHPeBFQf9roB8sJyD5w5J3CKOcjqOvp2C2nE1ZjhMAflfcveH2l4PiIwq7vwoHPeBVIqJKwWjp2C2XkQ7QCf1DOKwrWxGk4MktfrO9cEkIhVHi9w(i5iPi0B58wHIqd7rHjAyDoEauzaKyawhGhBo7gV65KdtTIhGudOZhG1biJbOHqrds5mELZlo9(lsMp9aKlFaVk32tl3h1HhavgGSFawhWRYT90Y9rD4bi1a6qrOrsl4KhBo7yf1DvUIAsOKwrWxGk4MktfrO9cEkcuEX8IOIOXy9w0EbpfH0zKmGmsgpaQzUnahoamsNEauk3Eauk3EaBKLp4hpG3YhjhPbqXMVbqHhW(Vb8w(i5iHgxJ0ba3beUGdSpaTnRrCa1BaLJhaf462dOCfHElN3kueAypkmrdRZXdqkYdGekxrTmvsRi4lqfCtLPIqVLZBfkcnShfMOH154bif5bqcfrO9cEkI60XEHxWt5kQrOsAfbFbQGBQmveH2l4Pi8kNxC69xKuengR3I2l4PiKErAaX1gWb9bqjWopaPZOdGpEZrI0bG(9becmCaDMp2hWhZdO8b8G7ai58I4aIRnG60XEyfHElN3kue8XBosMg)kD5dqQbitzna5Yha6)9mO4uDAZNEaYLpajgGhc(Cd9YTWHRHVavWTbyDayB46m2tU3gavgajgGKkxrTSPKwrWxGk4MktfrO9cEkcSD0Gu6zrtr0ySElAVGNIidSYT9bGYdGYcV8b4Wb8X8ai6zrBaWBauLarEa1nGS8I0aYYlsd4kTnpaC5)Wl4HjDaOFFaz5fPbSXYcKue6TCERqrG(FpJx58ItV)IK5tpaRda9)EguCQoTPbPCdW6a0WEuyIgwNJhavgGmhG1bG(Fpd(3A8LIE0p220GuUbyDanOB2ar2q3)fErlkEhavgqxJSnaRdGpEZrAasnazkRbyDaT9xnZgiYgV0iIt5rDClbV0YVLX2dqQbGPzHi5XMZo2GPu0Csh(a60a6yaiWa6yawhGhBo7gV65KdtTIhGudaHkxrDNRKwrWxGk4MktfHElN3kueO)3Z4voV407Viz(0dqU8bG(FpdkovN28PveH2l4Piq5fZlI1LRCf1YEL0kc(cub3uzQi0B58wHIa9)EguCQoT5tpa5YhakeJhG1b8QCBpTCFuhEauzaAiu0GuodkovN2SCFuhEaYLpauigpaRd4v52EA5(Oo8aOYa6aHkIq7f8ue0qVGNYvul7usRi4lqfCtLPIqVLZBfkc0)7zqXP60Mp9aKlFaVk32tl3h1HhavgqhDveH2l4Pi2ilFWpo9w(i5iPCf1DLLsAfbFbQGBQmveH2l4Pi0Wllero52CctxB5yfrJX6TO9cEkcPZizazKmEaKeBwJ4a6HWdX6gGn0PmG4Ada7)3BaIcrEaUDHjDaX1gqFGekpau2DEhGg2Jg(awUpQBalJr60kc9woVvOiKyanOB2I2SCFuhEasnazoaRdqd7rHjAyDoEauzaKyawhqd6MnqKnEPrSU8byDa8XBosMg)kD5dqkYdOdznajhGC5dafIXdW6aEvUTNwUpQdpaQmaeQCf1D7QKwrWxGk4MktfrO9cEkcUNgsH3ek8AkIgJ1Br7f8uezGbsO8aCBE5bGTHFrBaO8a6Hlpan8ALxWdpa4na3MhGgETF5kc9woVvOiq)VNXRCEXP3FrY8PhGC5dqIbOHx7xUPXmDkecoVItZg(cub3gGKkxrD3ousRi4lqfCtLPIOXy9w0EbpfrguLLha9wWTCKgGdha8qGpMhafoOHNI4IEwr0zG()Y5A3uJXEDiHt6qiue6TCERqrWzW)IMMBMod0)xox7MAm2RdjCshcHIi0EbpfrNb6)lNRDtng71HeoPdHq5kQ7scL0kIq7f8ueFmNkN7Xkc(cub3uzQCLRiGueu4ilRKwrDxL0kc(cub3uzQi0B58wHIa9)EgBowpbFj3MtukrZ8PveH2l4PiWES4)MZkxrDhkPve8fOcUPYureAVGNIa)VxTSIquhN0nfHm7uUUPCf1KqjTIGVavWnvMkIq7f8ue9q49QLve6TCERqrG(FptpeEiwx6b3EZNEawhGedy)h)GBoB0HZiXj9FlOHVavWTbix(a2)Xp4MZM2g)CBpbFPgZ0Phu)Xg(cub3gGKdW6aW0SqK8yZzhBC7nW2jD4dGkdOJbyDaYyaEi4ZnI)fBQomDTHxWZWxGk4MIquhN0nfHm7uUUPCf1YujTIGVavWnvMkc9woVvOi4J3CKgavgajK1aSoGg0nBrBwUpQdpaPgGmniCawhGedqdHIgKYz8kNxC69xKml3h1HhGuKhGSzq4aKlFa7)4hCZzJoCgjoP)Bbn8fOcUnajhG1bG(FpJwWXQdSxxUb7HgXbqLb0DawhGmga6)9mbnJGj6LBHdxCsVr26YnF6byDaYyaO)3ZGkGWM4JDZNEawhGmga6)9mO4uDAZNEawhGedqdHIgKYz0Wllero52CctxB5yZY9rD4bi1aKndchGC5dqgdqdZYxCU5QCBp9cEasoaRdqIbiJbOHz5lo3CSEHc42gGC5dqdHIgKYzIwq7vwoHPeBVz5(Oo8aKI8aq4aKlFanOBIwq7vwoHPeBFQf9roBwUpQdpaPgqNpajveH2l4PiS5y9e8LCBorPenLROgHkPve8fOcUPYurO3Y5TcfbF8MJ0aOYaiHSgG1b0GUzlAZY9rD4bi1aKPbHdW6aKyaAiu0GuoJx58ItV)IKz5(Oo8aKI8aKPbHdqU8bS)JFWnNn6WzK4K(Vf0WxGk42aKCawha6)9mAbhRoWED5gShAehavgq3byDaYyaO)3Ze0mcMOxUfoCXj9gzRl38PhG1biJbG(FpdQacBIp2nF6byDasmazma0)7zqXP60Mp9aKlFaAyw(IZnhRxOaUTbyDaEi4Zn4iBKZPfgRHVavWTbyDaO)3ZGIt1Pnl3h1HhGudq2gGKdW6aKyaAiu0GuoJgEzHiYj3Mty6AlhBwUpQdpaPgGSzq4aKlFaYyaAyw(IZnxLB7PxWdqYbyDasmazmanmlFX5MJ1lua32aKlFaAiu0Guot0cAVYYjmLy7nl3h1HhGuKhachGC5dObDt0cAVYYjmLy7tTOpYzZY9rD4bi1a68bi5aSoap2C2nE1ZjhMAfpaPgqNRicTxWtr0dHhI1LEWTx5kx5kIS8Il4POUdz1rxz15D7qrqj2RUCSIGKgjlvHAsgQZGY4bmaPT5bu90W1hWdUdidF1vyBEZWbSCg8VwUnamSNhq8DyF4CBaA74YzSzqMQwhpazMXdGKaVS86CBaz4(p(b3C20zZWb4WbKH7)4hCZztN1WxGk4wgoaj6IGsAgKhKjPrYsvOMKH6mOmEadqABEavpnC9b8G7aYWg)IVWZWbSCg8VwUnamSNhq8DyF4CBaA74YzSzqMQwhpGoKvgpasc8YYRZTbqu9KKbGr68abhaj1aC4aOQ)yaTkBHl4nainVHd3biHLsoaj6IGsAgKPQ1XdOJoY4bqsGxwEDUnaIQNKmamsNhi4aiPgGdhav9hdOvzlCbVbaP5nC4oajSuYbirhiOKMb5bzsAKSufQjzOodkJhWaK2Mhq1tdxFap4oGmevaHnpeWdNHdy5m4FTCBayyppG47W(W52a02XLZyZGmvToEaKiJhajbEz5152aiQEsYaWiDEGGdGKAaoCau1FmGwLTWf8gaKM3WH7aKWsjhGeDrqjndYdYK0izPkutYqDgugpGbiTnpGQNgU(aEWDaziKIGchz5mCalNb)RLBdad75beFh2ho3gG2oUCgBgKPQ1XdGez8aijWllVo3gqgU)JFWnNnD2mCaoCaz4(p(b3C20zn8fOcULHdqIoqqjndYu164biZmEaKe4LLxNBdid3)Xp4MZMoBgoahoGmC)h)GBoB6Sg(cub3YWbirxeusZGmvToEaimJhajbEz5152aYW9F8dU5SPZMHdWHdid3)Xp4MZMoRHVavWTmCas0fbL0mipitY0tdxNBdq2nGq7f8gGOWo2miRiW0SwrDxzrcfb9cFLGveunvpGmkVHyaza7VAdYunvpaK)cKgqxsq6a6qwD0DqEqMQP6bKr5nedGKLKovDa64gqiWWbGYd4b)xBaHpaB3PXzSLwMxy3KxU9h1OH9w2zJJKhByPSj7LDYMw2l7KDY2dHXtZiuZD7IWweKiKLSVfV3G8Gmvt1dGKyhxoJZ4bzQMQhacmG2(RMbsrqHJSCsho5UdqBZAeXdWHdOT)QzGueu4ilN0HBgKPAQEaiWaijWllV(aYu6bqdHI0Yy4F18aC4aOeLpagbPxgJl4zgKPAQEaiWaizBTbuNZ7(P9cvWdiJkySTEJNpG6naKG)byhz5bCq3UU8bWcmpahoGg0mipihAVGh2qVSg2JgUfKTmBSvGkysVONj)G)vtNqlNjnBi(mzznit1dGWE52aipazr6aOgEia(cASn0havjqKha5b0L0bqCbn2g6dGQeiYdG8a6G0bqvjzga5bqcshabLIMha5biZb5q7f8Wg6L1WE0WTGSLzJTcubt6f9m5xje8sA2q8zYDhKP6bqOdbpakLBpa7a7Szqo0EbpSHEznShnCliBz2yRavWKErptEl6KxAeXKMneFMCNpihAVGh2qVSg2JgUfKTeX6Al3sy6AlhpihAVGh2qVSg2JgUfKTef6UGBPNiqIBuQlp5qeSUb5q7f8Wg6L1WE0WTGSLpbJT1B8CsRhzm8lqRRzO)y)l4eVFAVGNHVavWn5YXWVaTUMjlueEj4egkYYNB4lqfCBqo0EbpSHEznShnCliBj9cPiiTEKr)VNPhcpeRl9GBVPbPCdYH2l4Hn0lRH9OHBbzl1HNEWTN06rg9)EMEi8qSU0dU9MgKYnipihAVGhM8(VuO9cEjrHDsVONjJgI40mP1Jm6)9m9q4HyDPhC7nFARYOT)QzGueu4ilN0HpihAVGh2cYwQdHifAVGxsuyN0l6zYqkckCKLjTEKB7VAgifbfoYYjD4dYu9aiPVqkIbqXMpolVdGgIXfQGhKdTxWdBbzlPxifXGCO9cEyliBPx58ItV)IeP1Jm6)9m6Wtp42BAqk3GCO9cEyliBPo80dU9KwpYO)3ZOdp9GBVPbPCdYu9aYihpaSn0ha25q42dYH2l4HTGSL7)sH2l4Lef2j9IEMm25q42KwpYO)3ZGTJgKsplAMpTC5O)3ZqVqkcZNEqo0EbpSfKTeJ4xisOb2Eqo0EbpSfKTuhcrk0EbVKOWoPx0ZK1qOObPCdYu9aOM1lua3wgpassG9bqIba3biZbOH9OWbqdRZhWw04baVbGRlxWdWJnN9ba)oUA8aGVbGYlMxehaChq7V1LpauEX8I4aQ3aE8gIb8w(i5inGcpGp9aYiuLbe00cKgqmaeQPhavPOhafB(gG0z0bu4b8PhqCTbqPeIbGHWBaVqiga89mdYH2l4HTGSLBrtA9iRHz5lo3CSEHc42SkHm8qWNBqfqyZdb8Wg(cub3Klh9)Egube28qapS5tlPvmnlejp2C2Xg3EdSDsho5UwLqd7rHjAyDowQoSU8BzSDGkyRT9xnZw0gV0iIt5rDClbV0YVLX2sLn2kqfSzl6KxAeXYLRH9OWenSohtgHwr)VNXRCEXP3FrY8PTI(FpJx58ItV)IKz5(OomviH12(RMzlAJxAeXP8OoULGxA53YyBPqOKwLqgO)3ZGIt1PnFA5Y1qOObPCguCQoT5tlxUeO)3ZGIt1PnFARAiu0GuoZJ3qKElFKCKmFAjLCqo0EbpSfKTC)xk0EbVKOWoPx0ZKF1vyBEjTEK1WEuyIgwNJLISeiebYgBfOc28G)vtNqlNLCqo0EbpSfKTKER(qKOSHBtA9i32F1m0B1hIeLnCBJxAeXP8OoULGxA53YyBPi3HSSQH9OWenSohlf5oivuhN0nYiCqMQhqg4x4fcKRBda7CiC7b5q7f8Wwq2sDiePq7f8sIc7KErptg7CiCBsRhz0)7zqXP60Mp9GmvpaPT5b0dX(ayeKMpCLLhqMspansAbpajK2EzS9aiSxUnackfnpane7dOBxeoa(4nhjshqFGipa8F5bqHhGoUb0hiYdWTdFa1nazoGCbeneyjhKdTxWdBbzlPeLtkM1KLqIUDric0bj6e6)9m1PJ9cVGxcX6YtWxYT5uN5F5c28PLebKGpEZrYO)7YNBbjmiSt8XBosMLZ5ZcjKPS6e6)9mAbhRoWED5MpTKskPL8XBosMLZ5J06r2dbFUbvaHnpeWdB4lqfCZk6)9mOciS5HaEytds5SgAVYYjup5BLNZlMSSgKP6beAVGh2cYwsdHI0Yy4F1mP1JShc(CdQacBEiGh2WxGk4Mv0)7zqfqyZdb8WMgKYzvc(4nhjliHbHDIpEZrYSCoFwiHmLvNq)VNrl4y1b2Rl38PLusQir3Uieb6GeDc9)EM60XEHxWlHyD5j4l52CQZ8VCbB(0sAn0ELLtOEY3kpNxmzznihAVGh2cYwU)lfAVGxsuyN0l6zYOciS5HaEysRhzpe85gube28qapSHVavWnRO)3ZGkGWMhc4HnniLBqo0EbpSfKT8XluxWpoHwotQgjTGtES5SJj3L06rg9)EMGMrWe9YTWHloP3iBD5Mp9GCO9cEyliBjnekslJH)vZK(GB6ye0j3Dqo0EbpSfKTCdezs1iPfCYJnNDm5UKwpYsS8BzSDGky5YP5fxyNpp1)fErlkELQbDZgiYg6(VWlArXRKwB7VAMnqKnEPreNYJ64wcEPLFlJTLctZcrYJnNDSbtPO5Ko8o1bc0XGCO9cEyliBP4FXMQdtxB4f8ivJKwWjp2C2XK7sA9ilXYVLX2bQGLlNMxCHD(8u)x4fTO4vQg0nI)fBQomDTHxWZq3)fErlkEL0AB)vZi(xSP6W01gEbpJxAeXP8OoULGxA53YyBPW0SqK8yZzhBWukAoPdVtDGaDmihAVGh2cYwsdHI0Yy4F1mPp4MogbDYDhKdTxWdBbzlD7nW2jD4KQrsl4KhBo7yYDjTEKx(Tm2oqfS12(RMXT3aBN0HB8sJioLh1XTe8sl)wgBlLeY0cmnlejp2C2Xg3EdSDshENKPKKus01I(a78IukBi(SKiGgETF5gpWoNEWnHkGWMHVavWneqdZYxCU5y9cfWTzvczG(FpdkovN28PLlhtZcrYJnNDSXT3aBN0HlvxjhKdTxWdBbzlPHqrAzm8VAM0hCthJGo5UdYH2l4HTGSLO73drclcSnP1JSeBuTeNLp3eTg2uNus01I(abtA7yZzmcOTJnNXP3gAVGxiKStlRTJnNtE1ZsAvcmnlejp2C2Xg097HiHfb2UtH2l4zq3VhIeweyBtl6JCMKk0Ebpd6(9qKWIaBB0qSlPuseAVGNbBVCZ0I(iNjPcTxWZGTxUz0qSl5GCO9cEyliBjMsrZjD4KwpYyAwisES5SJnykfnN0Hlvxlq)VNbfNQtB(0DQJb5q7f8Wwq2s3EdSDshoP1JmMMfIKhBo7yJBVb2oPdxksmihAVGh2cYwITxUrA9iJ(FpJwWXQdSxxU5tBvc0)7zW)wJVu0J(X2MgKYzf9)EgSD0Gu6zrZ0Guo5Yr)VNbfNQtB(0soihAVGh2cYwUbImPAK0co5XMZoMCxsRhz0)7zqXP60MpT12(RMzdezJxAeXP8OoULGxA53YyBP6yqo0EbpSfKTuhcrk0EbVKOWoPx0ZKFLqW7G8GCO9cEydQacBEiGhM8giYKQrsl4KhBo7yYDjTEKLqgEPrSUC5YLORPJorZlUWoFEQ)l8Iwu8kf5g0nBGiBO7)cVOffVskxUeH2RSCc1t(w558Ij3H1LFlJTdublPKwr)VNb1tBGiBAqk3GCO9cEydQacBEiGh2cYwk(xSP6W01gEbps1iPfCYJnNDm5UKwpYl)wgBhOc2k6)9mOEQhcVxTSPbPCdYH2l4HnOciS5HaEyliBPBVb2oPdNunsAbN8yZzhtUlP1J8YVLX2bQGTI(FpdQNC7nW2MgKYzTT)QzC7nW2jD4gV0iIt5rDClbV0YVLX2sjHmTatZcrYJnNDSXT3aBN0H3jzkjjLeDTOpWoViLYgIpljcOHx7xUXdSZPhCtOciSz4lqfCBqo0EbpSbvaHnpeWdBbzlr3VhIeweyBsRhz0)7zq9e6(9qKWIaBBAqk3GCO9cEydQacBEiGh2cYwIPu0CshoP1Jm6)9mOEctPOztds5SIPzHi5XMZo2GPu0CshUuDhKdTxWdBqfqyZdb8Wwq2sS9YnsRhz0)7zq9e2E5MPbPCdYH2l4HnOciS5HaEyliBjMsrZjD4KwpYO)3ZG6jmLIMnniLBqo0EbpSbvaHnpeWdBbzlD7nW2jD4KwpYO)3ZG6j3EdSTPbPCdYdYH2l4HnAiu0GuoYrlO9klNWuITNunsAbN8yZzhtUlPKLqcz0GUjAbTxz5eMsS9Pw0h5SXlnI1LlxEd6MOf0ELLtykX2NArFKZML7J6WuPdjTkrd6MOf0ELLtykX2NArFKZgShAePcjKlxgnOBIwq7vwoHPeBFYMdHb7HgrP6kPvzeAVGNjAbTxz5eMsS9jBoeM6sprLB7wLrO9cEMOf0ELLtykX2NArFKZM6sprLB7wLrO9cEMOf0ELLtykX2BQl9evUTlPvp2C2nE1ZjhMAflfcLlp0ELLt8X9fJLQdRYObDt0cAVYYjmLy7tTOpYzJxAeRl3kF8MJevibcT6XMZUXREo5WuRyPq4GCO9cEyJgcfniLZcYw(4neP3Yhjhjs1iPfCYJnNDm5UKwpYAypkmrdRZXuHew9yZz34vpNCyQvSuDUvzOHqrds5mELZlo9(lsMpTC5Vk32tl3h1HPIS36RYT90Y9rDyP6yqMQhG0zKmGmsgpaQzUnahoamsNEauk3Eauk3EaBKLp4hpG3YhjhPbqXMVbqHhW(Vb8w(i5iHgxJ0ba3beUGdSpaTnRrCa1BaLJhaf462dO8b5q7f8WgnekAqkNfKTeLxmVisA9iRH9OWenSohlfzsmihAVGh2OHqrds5SGSL1PJ9cVGhP1JSg2Jct0W6CSuKjXGmvpaPxKgqCTbCqFaucSZdq6m6a4J3CKiDaOFFaHadhqN5J9b8X8akFap4oasoVioG4AdOoDShEqo0EbpSrdHIgKYzbzl9kNxC69xKiTEK5J3CKmn(v6YLsMYsUC0)7zqXP60MpTC5s4HGp3qVClC4A4lqfCZk2gUoJ9K7nQqcjhKP6bKbw52(aq5bqzHx(aC4a(yEae9SOna4naQsGipG6gqwErAaz5fPbCL2MhaU8F4f8WKoa0VpGS8I0a2yzbsdYH2l4HnAiu0GuoliBj2oAqk9SOrA9iJ(FpJx58ItV)IK5tBf9)EguCQoTPbPCw1WEuyIgwNJPImTI(Fpd(3A8LIE0p220GuoRnOB2ar2q3)fErlkEPsxJSzLpEZrskzklRT9xnZgiYgV0iIt5rDClbV0YVLX2sHPzHi5XMZo2GPu0CshEN6ab6WQhBo7gV65KdtTILcHdYH2l4HnAiu0GuoliBjkVyErSUCsRhz0)7z8kNxC69xKmFA5Yr)VNbfNQtB(0dYH2l4HnAiu0GuoliBjn0l4rA9iJ(FpdkovN28PLlhfIXwFvUTNwUpQdtfnekAqkNbfNQtBwUpQdlxokeJT(QCBpTCFuhMkDGWb5q7f8WgnekAqkNfKTCJS8b)40B5JKJeP1Jm6)9mO4uDAZNwU8xLB7PL7J6WuPJUdYu9aKoJKbKrY4bqsSznIdOhcpeRBa2qNYaIRnaS)FVbike5b42fM0bexBa9bsO8aqz35DaAypA4dy5(OUbSmgPtpihAVGh2OHqrds5SGSLA4LfIiNCBoHPRTCmP1JSenOB2I2SCFuhwkzAvd7rHjAyDoMkKWAd6MnqKnEPrSUCR8XBosMg)kD5srUdzjPC5Oqm26RYT90Y9rDyQGWbzQEazGbsO8aCBE5bGTHFrBaO8a6Hlpan8ALxWdpa4na3MhGgETF5dYH2l4HnAiu0GuoliBj3tdPWBcfEnsRhz0)7z8kNxC69xKmFA5YLqdV2VCtJz6uieCEfNMn8fOcUj5GmvpGmOklpa6TGB5inahoa4HaFmpakCqdVb5q7f8WgnekAqkNfKT8J5u5CpPx0ZK7mq)F5CTBQXyVoKWjDieKwpYCg8VOP5MPZa9)LZ1UPgJ96qcN0HqmihAVGh2OHqrds5SGSLFmNkN7XdYdYH2l4HnVsi4L8giYKQrsl4KhBo7yYDjTEKZgBfOc28kHGxYDTU8BzSDGkyRnOB2ar2q3)fErlkEPc5UMo6enV4c785P(VWlArX7GCO9cEyZRecETGSLBGitA9iNn2kqfS5vcbVK7yqo0EbpS5vcbVwq2sX)InvhMU2Wl4rA9iNn2kqfS5vcbVKjXGCO9cEyZRecETGSLykfntA9iNn2kqfS5vcbVKL5GCO9cEyZRecETGSLy7LBKwpYO)3ZG)TgFPOh9JTnniLBqo0EbpS5vcbVwq2YNGX26nEoP1Jmg(fO11m0FS)fCI3pTxWZWxGk4MC5y4xGwxZKfkcVeCcdfz5Zn8fOcUrADoV7N2tvFp3QWzYDjToN39t7PCbeneK7sADoV7N2t1Jmg(fO11mzHIWlbNWqrw(8b5b5q7f8WMxDf2MxY0qOiTmg(xnt6dUPJrqNC3b5q7f8WMxDf2MxliBjoYg5CAHXsA9iJ(FpdoYg5CAHXAwUpQdtfsmihAVGh28QRW28AbzlP3QpejkB42KwpYs02F1m0B1hIeLnCBJxAeXP8OoULGxA53YyBPirNKatZcrYJnNDSHER(qKOSHBBrxjTIPzHi5XMZo2qVvFisu2WTLQRKYLJPzHi5XMZo2qVvFisu2WTLscsyr3o5HGp3GduEDi0Tn8fOcUj5GCO9cEyZRUcBZRfKTClAs1iPfCYJnNDm5UKwpYl)wgBhOc2AB)vZSfTXlnI4uEuh3sWlT8BzSTuzJTcubB2Io5LgrSvjKa9)EgVY5fNE)fjZNwUCz4LgX6YL0QeO)3ZGkGWMhc4HnFA5YLHhc(CdQacBEiGh2WxGk4MKYLldpe85gCGYRdHUTHVavWnjTkbMMfIKhBo7yd9w9Hirzd3MCx5YLHhc(Cd9w9Hirzd32WxGk4MKwLi0ELLtnOB2IMSSKl3lnI1LBn0ELLtnOB2IMCx5YLX(p(b3C2024NB7j4l1yMo9G6pwUCz4HGp3GduEDi0Tn8fOcUj5GCO9cEyZRUcBZRfKTehzJCoTWyjTEKr)VNbhzJCoTWynl3h1HPIeAypkmrdRZXw0vYojBDswgsmihAVGh28QRW28AbzlF8c1f8JtOLZK2hiyIpEZrICxs1iPfCYJnNDm5UdYH2l4HnV6kSnVwq2YhVqDb)4eA5mPAK0co5XMZoMCxsRhz0)7zqXP60MpTvpe85gm8lsWxYT50dUm2n8fOcUnipihAVGh2aPiOWrwMm2Jf)3CM06rg9)EgBowpbFj3MtukrZ8PhKdTxWdBGueu4ilBbzlX)7vltQOooPBKLzNY1Tb5q7f8WgifbfoYYwq2YEi8E1YKkQJt6gzz2PCDJ06rg9)EMEi8qSU0dU9MpTvj2)Xp4MZgD4msCs)3ckx((p(b3C2024NB7j4l1yMo9G6pwsRyAwisES5SJnU9gy7KoCQ0Hvz4HGp3i(xSP6W01gEbpdFbQGBdYH2l4HnqkckCKLTGSL2CSEc(sUnNOuIgP1JmF8MJeviHSS2GUzlAZY9rDyPKPbHwLqdHIgKYz8kNxC69xKml3h1HLISSzqOC57)4hCZzJoCgjoP)BbL0k6)9mAbhRoWED5gShAePsxRYa9)EMGMrWe9YTWHloP3iBD5MpTvzG(FpdQacBIp2nFARYa9)EguCQoT5tBvcnekAqkNrdVSqe5KBZjmDTLJnl3h1HLs2miuUCzOHz5lo3CvUTNEblPvjKHgMLV4CZX6fkGBtUCnekAqkNjAbTxz5eMsS9ML7J6WsrgHYL3GUjAbTxz5eMsS9Pw0h5Sz5(OoSuDUKdYH2l4HnqkckCKLTGSL9q4HyDPhC7jTEK5J3CKOcjKL1g0nBrBwUpQdlLmni0QeAiu0GuoJx58ItV)IKz5(OoSuKLPbHYLV)JFWnNn6WzK4K(VfusRO)3ZOfCS6a71LBWEOrKkDTkd0)7zcAgbt0l3chU4KEJS1LB(0wLb6)9mOciSj(y38PTkHmq)VNbfNQtB(0YLRHz5lo3CSEHc42S6HGp3GJSroNwySg(cub3SI(FpdkovN2SCFuhwkztsRsOHqrds5mA4LfIiNCBoHPRTCSz5(OoSuYMbHYLldnmlFX5MRYT90lyjTkHm0WS8fNBowVqbCBYLRHqrds5mrlO9klNWuIT3SCFuhwkYiuU8g0nrlO9klNWuITp1I(iNnl3h1HLQZL0QhBo7gV65KdtTILQZhKhKdTxWdBWohc3MmnekslJH)vZK(GB6ye0j3DqMQhavjqKhWXCdpGf(ZTfinaeklsQbaFdOC8ae8L72di8bedOVUQ)3pahoa8FPdmEay7LB4b0O5b5q7f8WgSZHWTTGSLBGitQgjTGtES5SJj3L06rwIg0nBGiBO7)cVOffVuPRbHYLV8BzSDGkyjT22F1mBGiB8sJioLh1XTe8sl)wgBlvhYLlbnV4c785P(VWlArXRunOB2ar2q3)fErlkETI(FpdkovN28PTIPzHi5XMZo242BGTt6WPcjSQHz5lo3CSEHc42KuUC0)7zqXP60ML7J6WuP7GCO9cEyd25q42wq2sX)InvhMU2Wl4rA9iJPzHi5XMZo242BGTt6WPcjSU8BzSDGkyRT9xnJ4FXMQdtxB4f8mEPreNYJ64wcEPLFlJTLcHwLqd7rHjAyDoMSmLlVbDJ4FXMQdtxB4f8ml3h1HPccLlxgnOBe)l2uDy6AdVGNXlnI1Ll5GmvpGm3VhIbqicS9ak8aqz35DaUDCda7CiC7bqyVCBaHpasmap2C2XdYH2l4HnyNdHBBbzlr3VhIeweyBsRhzmnlejp2C2Xg097HiHfb2wQogKdTxWdBWohc32cYwsdHI0Yy4F1mPp4MogbDYDhKdTxWdBWohc32cYwITxUrA9iRH9OWenSohtfzAftZcrYJnNDSXT3aBN0HtfeoipihAVGh2GgI40mz8)E1YKwpYO)3ZWArrJ5egkI10GuoRO)3ZWArrJ5K4FXAAqkNvjw(Tm2oqfSC5seAVYYj(4(IXs11AO9klNAq3G)3RwMkH2RSCIpUVySKsoihAVGh2GgI40SfKTe7XI)BotA9iJ(FpdRffnMtyOiwZY9rDyP6kll0b2tE1ZYLJ(FpdRffnMtI)fRz5(OoSuDLLf6a7jV65b5q7f8Wg0qeNMTGSLyp2xTmP1Jm6)9mSwu0yoj(xSML7J6WsPdSN8QNLlh9)EgwlkAmNWqrSMgKYzfdfXMyTOOXSuYsUC0)7zyTOOXCcdfXAAqkNvX)InXArrJzei0EbpdLnCBtDPNOYTDQ0Dqo0EbpSbneXPzliBjLnCBsRhz0)7zyTOOXCcdfXAwUpQdlLoWEYREwUC0)7zyTOOXCs8VynniLZQ4FXMyTOOXmceAVGNHYgUTPU0tu52UuYs5kxPaa]] )


end
