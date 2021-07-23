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


    spec:RegisterPack( "Feral", 20210723, [[dSuZ0bqiKqpcvkDjeH0MeHpjsOrHeDkKKvjs0RerMfI0TqeSlk(LiQHHQKJPiTmfHNHiAAOs11GaBdvP8niighQsLZbbPwNIOmpKG7HO2hQIdIiuwOiPhQiQMOIiYgrLI(iQsvDseHQvcrntrcCtfru7ej1pfjOHIieTuuPWtryQOs(kIqySqqYEj5VuAWGoSWIH0Jj1Kv4YeBgWNfvJwuoTKvRicVgImBuUTIA3Q8BvnCK64Okvz5k9COMovxhOTls9DuX4HG68qO1RisZhv1(LA1ufxkIr4II6j41et5fczcsAMYBiaHEcsQiCePffbDOrkYffXfZIIGBkBWue0bISpgkUue4hC1IIiZDA8KLCY5LNbIA0)CY4AgKfE9NEdapzCnRtwrGcwmNe)uOkIr4II6j41et5fczcsAMYBiG3XRPkIa0Z(vrquZtUIiRgd5uOkIHG1kcUPSbRHtslynAKrgKHydNGxK2Wj41etBKBK5MYgSgsIrImf0qDCnmy4VHOsdbEWB0WWByM704jl5KZlSBYlpde1O)5KrOIBsJnsM34Di08MM3HqJqZBaiia0cc0Y0PiyebjdEX7gbaqJCJ8KNfxUGNSgzsOHJfSgMNdJJePfRoCYtBOot0iHBO)nCSG1W8CyCKiTy1HBAKjHgo5)LwwVHPYvdP)Nzxb)GRwAO)nKtuEdfeMEfmU(Z0itcnKeBmAyDUSliTxOmPHCtMGZ0Ba4nSaAiIpydZI0sdV3ZQlVHcdln0)goEJIGvyhR4srGY(F4b7pSIlf1tvCPiKlqzYqLQIi0E9NIydKefHElx2kueu2qk2qV0ivxEd5ZVHu2WPMjAykBiTS4c7Y52zqMx0Ss2gYd5goE3SbsIHEgK5fnRKTHu1q(8BiLnm0ELwSOU13kpxwCdj3WjAyIgUcWk4SaLjnKQgsvdt0quqaadQB3ajXmEoNIqJOMjwp2CXXkQNQCf1tO4srixGYKHkvfrO96pfbd8I1whMU2WR)ue6TCzRqrScWk4SaLjnmrdrbbamOUD()dOwXmEoNIqJOMjwp2CXXkQNQCf1KuXLIqUaLjdvQkIq71FkcpBdCMvhUIqVLlBfkIvawbNfOmPHjAikiaGb1TE2g4mZ45CnmrdhlynmE2g4mRoCJxAKW28Oozy)ZUcWk4SgYtdPSHCVHj1qmTWywp2CXXgpBdCMvhEdtzd5EdPQHj3qkB40gMudNdSllI20bduAivnKeAO(Vby5gpWUyb(1IY(FyKlqzYqrOruZeRhBU4yf1tvUIAUR4srixGYKHkvfHElx2kueOGaagu3IUGEWSywGZmJNZPicTx)PiqxqpywmlWzkxrncuCPiKlqzYqLQIqVLlBfkcuqaadQBXCkAXmEoxdt0qmTWywp2CXXgmNIwS6WBipnCQIi0E9NIaZPOfRoCLROM3uCPiKlqzYqLQIqVLlBfkcuqaadQBXzRmmJNZPicTx)PiWzRmuUIAeIIlfHCbktgQuve6TCzRqrGccayqDlMtrlMXZ5ueH2R)ueyofTy1HRCf18ofxkc5cuMmuPQi0B5YwHIafeaWG6wpBdCMz8CofrO96pfHNTboZQdx5kxrauxHZKvXLI6PkUueYfOmzOsvra8R9ee2vupvreAV(trq)pZUc(bxTOCf1tO4srixGYKHkvfHElx2kueOGaagCKoYf7(XAwzoQd3qk0qsQicTx)PiWr6ixS7hRYvutsfxkc5cuMmuPQi0B5YwHIGYgowWAyO3AoywoB4zgV0iHT5rDYW(NDfGvWznKNgsYgMYgszdX0cJz9yZfhBO3AoywoB4znmPgoTHu1WenetlmM1JnxCSHER5Gz5SHN1qEA40gsvd5ZVHyAHXSES5IJn0BnhmlNn8SgYtdPSHKSHj1WPnmLn0dMCUbhOY6)7zg5cuMmAivkIq71Fkc6TMdMLZgEMYvuZDfxkc5cuMmuPQicTx)Pi2IwrO3YLTcfXkaRGZcuM0WenCSG1WSfTXlnsyBEuNmS)zxbyfCwd5PHPJTcuMy2I26LgjCdt0qkBiLnefeaW4vUSyla4IObKUH853qk2qV0ivxEdPQHjAiLnefeaWGY(F4b7pSbKUH853qk2qpyY5gu2)dpy)HnYfOmz0qQAiF(nKIn0dMCUbhOY6)7zg5cuMmAivnmrdPSHyAHXSES5IJn0BnhmlNn8SgsUHtBiF(nKIn0dMCUHER5Gz5SHNzKlqzYOHu1WenKYggAVsl2X7MTOBi5gYRgYNFd9sJuD5nmrddTxPf74DZw0nKCdN2q(8BifB4cEcWV5IzSbyEMBFa7qeAlWRbXg5cuMmAiF(nKIn0dMCUbhOY6)7zg5cuMmAivkcnIAMy9yZfhROEQYvuJafxkc5cuMmuPQi0B5YwHIafeaWGJ0rUy3pwZkZrD4gsHgszd1)m6BP)6CCdtQHtBivnmLnK3AykBiVmKureAV(trGJ0rUy3pwLROM3uCPiKlqzYqLQIyoqyRCYMJOI6PkIq71FkcazFD9GylA5IIqJOMjwp2CXXkQNQCf1iefxkc5cuMmuPQicTx)PiaK911dITOLlkc9wUSvOiqbbamOyBDAdiDdt0qpyY5g8dYSpG1ZelWVc2nYfOmz0q(8BO(F245Cg9FPFKeRNjwmDTLJnRmh1HBifA40gMOH6pTCX5MRYZClqikcnIAMy9yZfhROEQYvUIanyXPffxkQNQ4srixGYKHkvfHElx2kueOGaagrZkASyXplwZ45CnmrdrbbamIMv0yXYaVynJNZ1WenKYgUcWk4SaLjnKp)gszddTxPfRCYCj4gYtdN2Wenm0ELwSJ3nyWdOwPHuOHH2R0IvozUeCdPQHuPicTx)PiWGhqTIYvupHIlfHCbktgQuve6TCzRqrGccayenROXIf)SynRmh1HBipnCkVAysnuhy361S0q(8BikiaGr0SIglwg4fRzL5OoCd5PHt5vdtQH6a7wVMffrO96pfb2JfdU5IYvutsfxkc5cuMmuPQi0B5YwHIafeaWiAwrJfld8I1SYCuhUH80qDGDRxZsd5ZVHOGaagrZkASyXplwZ45CnmrdXplwROzfnwAipnKxnKp)gIccayenROXIf)SynJNZ1WenKbEXAfnROXsdjHggAV(ZWzdpZuNfGv5zEdPqdNQicTx)PiWESa1kkxrn3vCPiKlqzYqLQIqVLlBfkcuqaaJOzfnwS4NfRzL5OoCd5PH6a7wVMLgYNFdrbbamIMv0yXYaVynJNZ1WenKbEXAfnROXsdjHggAV(ZWzdpZuNfGv5zEd5PH8sreAV(trWzdpt5kxrGfhKwXLI6PkUueYfOmzOsvrO3YLTcfH(tlxCU5e9(SFhnmrdX0cJz9yZfhB8SnWzwD4nKcnK7nmrd1)m6BP)6CCdPqdrqdt0qk2qV0ivxEdt0qk2quqaadk2wN2asRicTx)PiyGxS26W01gE9NYvupHIlfHCbktgQuvea)ApbHDf1tveH2R)ue0)ZSRGFWvlkxrnjvCPiKlqzYqLQIqVLlBfkcpyY5gazdMfyLBsr0ixGYKrdt0q9)SXZ5maYgmlWk3KIObKUHjAifBikiaGbhPJCXUFSgq6gMOH6Fg9T0FDoUH80WPnmrdhVB2ajX4LgP6YByIgszdhVByGxS26W01gE9NXlns1L3q(8BifBOhm5Cdd8I1whMU2WR)mYfOmz0qQueH2R)ue4iDKl29Jv5kQ5UIlfHCbktgQuve6TCzRqr4bto3GY(F4b7pSrUaLjJgMOHOGaagu2)dpy)HnJNZ1WenKYgkNS5i2WKAijniOHPSHYjBoIMvYLRHj1qkBi35vdtzdrbbamAMeRoWED5gq6gsvdPQHuOHu2WPtrqdjHgobjBykBikiaGPoDSx41FwKQl3(awptStcWlNjgq6gsvdt0Wq7vAXI6wFR8CzXnKCd5LIi0E9NIG(FMDf8dUAr5kQrGIlfHCbktgQuve6TCzRqr4bto3GY(F4b7pSrUaLjJgMOHOGaagu2)dpy)HnJNZ1WenKYgQ)z03s)154gsHgIGgYNFdX0cJz9yZfhB8SnWzwD4nKCdN2qQueH2R)ue6GXSH2R)SSc7kcwHD7fZIIaL9)Wd2FyLROM3uCPiKlqzYqLQIi0E9NIqhmMn0E9NLvyxrWkSBVywue6)zJNZPCf1iefxkc5cuMmuPQi0B5YwHIq)ZOVL(RZXnKNgsYgMOHu2quqaadk7)HhS)Wgq6gYNFdPyd9GjNBqz)p8G9h2ixGYKrdPsreAV(trOdgZgAV(ZYkSRiyf2TxmlkcG6kCMSkx5kIHaeGmxXLI6PkUueYfOmzOsvrO3YLTcfbkiaGz()dP6Sa)oBaPByIgsXgowWAyEomosKwS6WveH2R)uel4zdTx)zzf2veSc72lMffbAWItlkxr9ekUueYfOmzOsvrO3YLTcfXybRH55W4irAXQdxreAV(trOdgZgAV(ZYkSRiyf2TxmlkINdJJePfLROMKkUueYfOmzOsvrmeSElAV(trqICFoSgYjtojTSnK(X4cLjkIq71Fkc695WuUIAUR4srixGYKHkvfHElx2kueOGaagD4wGFNnJNZPicTx)Pi8kxwSfaCru5kQrGIlfHCbktgQuve6TCzRqrGccay0HBb(D2mEoNIi0E9NIqhUf43zLROM3uCPiKlqzYqLQIyiy9w0E9NIifEsdXzV3qSlbZZueH2R)uel4zdTx)zzf2ve6TCzRqrGccayWzX45mlSHbKUH853quqaad9(CygqAfbRWU9IzrrGDjyEMYvuJquCPicTx)PiWibYyw0aNPiKlqzYqLQYvuZ7uCPiKlqzYqLQIqVLlBfkIq7vAXoE3SfDdj3qEPicTx)Pi0bJzdTx)zzf2veSc72lMffbwCqALROgHwXLIqUaLjdvQkIq71FkcDWy2q71FwwHDfbRWU9IzrrO)NnEoNYvupLxkUueYfOmzOsvreAV(trSfTIyiy9w0E9NIGArVp73XK1WjpWEdjzd)THCVH6Fg9Bi9xN3WTOXn8VgIRlNjn0Jnx8g(GoUgsdFGgIklwwKA4VnCaU1L3quzXYIudlGgciBWAiWk3KIydlCdbPBykKB0WGMMHydJgIanDd5gfDd5Kjxd5IB2Wc3qq6gg3OHCkgRH4)VgcemwdFaaJIqVLlBfkc9NwU4CZj69z)oAyIgszdPyd9GjNBqz)p8G9h2ixGYKrd5ZVHOGaagu2)dpy)HnG0nKQgMOHyAHXSES5IJnE2g4mRo8gsUHtByIgszd1)m6BP)6CCd5PHt0WenCfGvWzbktAyIgowWAy2I24LgjSnpQtg2)SRaScoRH80W0XwbktmBrB9sJeUHjAiLnKInefeaWGIT1PnG0nKp)gQ)NnEoNbfBRtBaPBiF(nKYgIccayqX260gq6gMOH6)zJNZzaKnywGvUjfrdiDdPQHu1q(8BO(NrFl9xNJBi5gIGgMOHOGaagVYLfBbaxenG0nmrdrbbamELll2caUiAwzoQd3qk0qU3WenCSG1WSfTXlnsyBEuNmS)zxbyfCwd5PHiOHuPCf1tNQ4srixGYKHkvfHElx2kue6Fg9T0FDoUH8qUHu2qe0qsOHPJTcuMyaEWvtBrlxAivkIq71FkIf8SH2R)SSc7kcwHD7fZIIaOUcNjRYvupDcfxkc5cuMmuPQi0B5YwHIySG1WqV1CWSC2WZmEPrcBZJ6KH9p7kaRGZAipKB4e8QHjAO(NrFl9xNJBipKB4ekIq71Fkc6TMdMLZgEMIGvNy1dfbcuUI6PKuXLIqUaLjdvQkIHG1Br71FkIjzqMxKqUE0qSlbZZueH2R)ue6GXSH2R)SSc7kc9wUSvOiqbbamOyBDAdiTIGvy3EXSOiWUempt5kQNYDfxkc5cuMmuPQigcwVfTx)Pi4ktA48J9gkimTC4kT0Wu5QHAe1mPHuYv2k4SgsKTYOHeCkAPH6h7nC6ue0q5KnhrsB4CGK0qm4knKJ0qDCnCoqsAONfEdRRHCVH5ShnyyQueyrRiOSHu2WPtrqdjHgobjBykBikiaGPoDSx41FwKQl3(awptStcWlNjgq6gsvdjHgszdLt2CenAWDLZBysnKKge0Wu2q5KnhrZk5Y1WKAiLnK78QHPSHOGaagntIvhyVUCdiDdPQHu1qQAyYnuozZr0SsUCkIq71Fkcor5kc9wUSvOi8GjNBqz)p8G9h2ixGYKrdt0quqaadk7)HhS)WMXZ5AyIggAVslwu36BLNllUHKBiVuUI6PiqXLIqUaLjdvQkIHG1Br71FkIq71FyZqacqMNe5KP)Nzxb)GRwiTai7bto3GY(F4b7pSrUaLjJeOGaagu2)dpy)HnJNZLGs5KnhXKiPbbPuozZr0SsUCjrj35vkrbbamAMeRoWED5gqAQOIcuoDkciHjizkrbbam1PJ9cV(ZIuD52hW6zIDsaE5mXastvIq7vAXI6wFR8CzXK5LIi0E9NIybpBO96plRWUIqVLlBfkcpyY5gu2)dpy)HnYfOmz0WenefeaWGY(F4b7pSz8CofbRWU9IzrrGY(F4b7pSYvupL3uCPiKlqzYqLQIi0E9NIaq2xxpi2IwUOi0B5YwHIafeaWe0ccBPxze(VyREJ01LBaPveAe1mX6XMlowr9uLROEkcrXLIqUaLjdvQkcGFTNGWUI6PkIq71Fkc6)z2vWp4QfLROEkVtXLIqUaLjdvQkIq71FkInqsue6TCzRqrqzdxbyfCwGYKgYNFdPLfxyxo3odY8IMvY2qEA44DZgijg6zqMx0Ss2gsvdt0WXcwdZgijgV0iHT5rDYW(NDfGvWznKNgIPfgZ6XMlo2G5u0IvhEdtzdNOHKqdNqrOruZeRhBU4yf1tvUI6Pi0kUueYfOmzOsvreAV(trWaVyT1HPRn86pfHElx2kueu2WvawbNfOmPH853qAzXf2LZTZGmVOzLSnKNgoE3WaVyT1HPRn86pd9miZlAwjBdPQHjA4ybRHHbEXARdtxB41FgV0iHT5rDYW(NDfGvWznKNgIPfgZ6XMlo2G5u0IvhEdtzdNOHKqdNqrOruZeRhBU4yf1tvUI6j4LIlfHCbktgQuvea)ApbHDf1tveH2R)ue0)ZSRGFWvlkxr9etvCPiKlqzYqLQIi0E9NIWZ2aNz1HRi0B5YwHIyfGvWzbktAyIgowWAy8SnWzwD4gV0iHT5rDYW(NDfGvWznKNgszd5EdtQHyAHXSES5IJnE2g4mRo8gMYgY9gsvdtUHu2WPnmPgohyxweTPdgO0qQAij0q9FdWYnEGDXc8RfL9)WixGYKrdjHgQ)0YfNBorVp73rdt0qkBifBikiaGbfBRtBaPBiF(netlmM1JnxCSXZ2aNz1H3qEA40gsLIqJOMjwp2CXXkQNQCf1tmHIlfHCbktgQuvea)ApbHDf1tveH2R)ue0)ZSRGFWvlkxr9eKuXLIqUaLjdvQkc9wUSvOiOSHBudRKwo3eJb2uxd5PHu2WPnmPgohiSvNfBUGBij0qDwS5c2cSH2R)cwdPQHPSHROZInxSEnlnKQgMOHu2qmTWywp2CXXg0f0dMfZcCwdtzddTx)zqxqpywmlWzMrmh5sdtUHH2R)mOlOhmlMf4mJ(XEdPQH80qkByO96pdoBLHzeZrU0WKByO96pdoBLHr)yVHuPicTx)PiqxqpywmlWzkxr9eCxXLIqUaLjdvQkc9wUSvOiW0cJz9yZfhBWCkAXQdVH80WPnmPgIccayqX260gq6gMYgoHIi0E9NIaZPOfRoCLROEceO4srixGYKHkvfHElx2kueyAHXSES5IJnE2g4mRo8gYtdjPIi0E9NIWZ2aNz1HRCf1tWBkUueYfOmzOsvrO3YLTcfbkiaGrZKy1b2Rl3as3WenKYgIccayWGJHC2ygfeNzgpNRHjAikiaGbNfJNZSWgMXZ5AiF(nefeaWGIT1PnG0nKkfrO96pfboBLHYvupbcrXLIqUaLjdvQkIq71FkInqsue6TCzRqrGccayqX260gq6gMOHJfSgMnqsmEPrcBZJ6KH9p7kaRGZAipnCcfHgrntSES5IJvupv5kQNG3P4srixGYKHkvfrO96pfHoymBO96plRWUIGvy3EXSOiakgtwLRCfb9k6FgnCfxkQNQ4srixGYKHkvfXtRiWIRicTx)PishBfOmrrKoyGIIGxkI0XAVywueap4QPTOLlkxr9ekUueYfOmzOsvr80kcS4kIq71FkI0XwbktuePdgOOiMQigcwVfTx)PiiYwz0qYnKxK2qQ)JeWxqJZEVHCJajPHKB4usBiXf04S3Bi3iqsAi5gobPnmfqI3qYnKKK2qcofT0qYnK7kI0XAVywueafJjRYvutsfxkc5cuMmuPQiEAfbwCfrO96pfr6yRaLjkI0bduueiefXqW6TO96pfbHoysd5uEwdZcSlgfr6yTxmlkITOTEPrcRCf1CxXLIi0E9NIaP6gRmSy6AlhRiKlqzYqLQYvuJafxkIq71Fkc03DMmSaSarzWPUCR)iCDkc5cuMmuPQCf18MIlfHCbktgQuve6TCzRqrGFqgADddni2bzIvwqAV(ZixGYKrd5ZVH4hKHw3WK(zHxmXIFwA5CJCbktgkIq71FkcaMGZ0Ba4kxrncrXLIqUaLjdvQkc9wUSvOiqbbamZ)FivNf43zZ45CkIq71Fkc695WuUIAENIlfHCbktgQuve6TCzRqrGccayM))qQolWVZMXZ5ueH2R)ue6WTa)oRCLRiakgtwfxkQNQ4srixGYKHkvfrO96pfXgijkc9wUSvOishBfOmXaumMSnKCdN2WenCfGvWzbktAyIgoE3SbsIHEgK5fnRKTHuGCdNAMOHPSH0YIlSlNBNbzErZkzveAe1mX6XMlowr9uLROEcfxkc5cuMmuPQi0B5YwHIiDSvGYedqXyY2qYnCcfrO96pfXgijkxrnjvCPiKlqzYqLQIqVLlBfkI0XwbktmafJjBdj3qsQicTx)PiyGxS26W01gE9NYvuZDfxkc5cuMmuPQi0B5YwHIiDSvGYedqXyY2qYnK7kIq71FkcmNIwS6WvUIAeO4srixGYKHkvfHElx2kueOGaagm4yiNnMrbXzMXZ5ueH2R)ue4SvgkxrnVP4srixGYKHkvfHElx2kue4hKHw3WqdIDqMyLfK2R)mYfOmz0q(8Bi(bzO1nmPFw4ftS4NLwo3ixGYKHIOox2fK2TfGIa)Gm06gM0pl8Ijw8ZslNRiQZLDbPDBnplJkCrrmvreAV(traWeCMEdaxruNl7cs72C2JgmfXuLRCfb2LG5zkUuupvXLIqUaLjdvQkcGFTNGWUI6PkIq71Fkc6)z2vWp4QfLROEcfxkc5cuMmuPQicTx)Pi2ajrrOruZeRhBU4yf1tve6TCzRqrqzdhVB2ajXqpdY8IMvY2qk0WPge0q(8B4kaRGZcuM0qQAyIgowWAy2ajX4LgjSnpQtg2)SRaScoRH80WjAiF(nKYgsllUWUCUDgK5fnRKTH80WX7Mnqsm0ZGmVOzLSnmrdrbbamOyBDAdiDdt0qmTWywp2CXXgpBdCMvhEdPqdjzdt0q9NwU4CZj69z)oAivnKp)gIccayqX260MvMJ6WnKcnCQIyiy9w0E9NIGBeijn8ezGB4(G5zmeBic4fjAdFGgwoUHm5Y9SggEdJgoxxndo3q)BigCPdmUH4Svg4goOfLROMKkUueYfOmzOsvrO3YLTcfbMwymRhBU4yJNTboZQdVHuOHKSHjA4kaRGZcuM0WenCSG1WWaVyT1HPRn86pJxAKW28Oozy)ZUcWk4SgYtdrqdt0qkBO(NrFl9xNJBi5gY9gYNFdhVByGxS26W01gE9NzL5OoCdPqdrqd5ZVHuSHJ3nmWlwBDy6AdV(Z4LgP6YBivkIq71Fkcg4fRTomDTHx)PCf1CxXLIqUaLjdvQkIq71Fkc0f0dMfZcCMIyiy9w0E9NIi1f0dwdjyboRHfUHOI7Y2qplUgIDjyEwdjYwz0WWBijBOhBU4yfHElx2kueyAHXSES5IJnOlOhmlMf4SgYtdNq5kQrGIlfHCbktgQuvea)ApbHDf1tveH2R)ue0)ZSRGFWvlkxrnVP4srixGYKHkvfHElx2kue6Fg9T0FDoUHuOHCVHjAiMwymRhBU4yJNTboZQdVHuOHiqreAV(trGZwzOCLRi0)ZgpNtXLI6PkUueYfOmzOsvrOiOKskoE3eJG2R0IfZj2z7iMJCX4LgP6Y5ZF8UjgbTxPflMtSZ2rmh5IzL5OomfMGQeuoE3eJG2R0IfZj2z7iMJCXG9qJefijF(uC8UjgbTxPflMtSZ2mjygShAK4zkvjOyO96ptmcAVslwmNyNTzsWm1zbyvEMNGIH2R)mXiO9kTyXCID2oI5ixm1zbyvEMNGIH2R)mXiO9kTyXCID2uNfGv5zovj8yZf341Sy93okHheWNFO9kTyLtMlbZZejO44DtmcAVslwmNyNTJyoYfJxAKQlpHCYMJifijcs4XMlUXRzX6VDucpiqreAV(treJG2R0IfZj2zfHgrntSES5IJvupv5kQNqXLIqUaLjdvQkc9wUSvOiOSH4hKHw3WqdIDqMyLfK2R)mYfOmz0q(8Bi(bzO1nmPFw4ftS4NLwo3ixGYKrdPsruNl7cs72cqrGFqgADdt6NfEXel(zPLZve15YUG0UTMNLrfUOiMQicTx)PiaycotVbGRiQZLDbPDBo7rdMIyQYvutsfxkc5cuMmuPQigcwVfTx)PiM8a7nKRkx2ue3qUj4IydrfGFLgs5VnSMNLrfodXggaUSu1qDG96YBi3u2G1qU5k3KIydlGgMQSyzrQHfUHuNc5QH)1q9)SXZ5mkcmINwraiBWSaRCtkIkc9wUSvOi0)ZgpNZGIT1PnG0kIq71FkcVYLfBbaxevUIAUR4srixGYKHkvfrO96pfbGSbZcSYnPiQi0B5YwHIq)ZOVL(RZXnKcnKKnmrd9yZf341Sy93okPH80qesdt0qkBikiaGbhPJCXUFSgq6gYNFdPyd9GjNBWr6ixS7hRrUaLjJgsvdt0qkBifBO(F245CgVYLfBbaxenG0nKp)gQ)NnEoNbfBRtBaPBivnKp)gcu5zUDL5OoCdPqd5DnmrdbQ8m3UYCuhUH80WjueAe1mX6XMlowr9uLROgbkUueYfOmzOsvreAV(trGklwwKuedbR3I2R)ueCLcNKsHtwdPwKrd9VHyepDd5uEwd5uEwd3iTCpiUHaRCtkInKtMCnKJ0Wf8AiWk3KIiACdsB4VnmCMeyVH6mrJudlGgwoUHC(1ZAy5kc9wUSvOi0)m6BP)6CCd5HCdjPYvuZBkUueYfOmzOsvrO3YLTcfH(NrFl9xNJBipKBijveH2R)ue1PJ9cV(t5kQrikUueYfOmzOsvreAV(tr4vUSyla4IOIyiy9w0E9NIGRfXgg3OH37nKtGDPHCXnBOCYMJiPnef0ByWWFdNeGyVHGyPHL3qGFB4KklsnmUrdRth7Hve6TCzRqriNS5iAgcqPlVH80qUZRgYNFdrbbamOyBDAdiDd5ZVHu2qpyY5g6vgH)RrUaLjJgMOH4SFDb7w3hnKcnKKnKkLROM3P4srixGYKHkvfrO96pfbolgpNzHnuedbR3I2R)uetYvEM3quPHC2)YBO)neelnKywyJg(xd5gbssdRRHPLfXgMwweB4v6mPH4YbdV(dtAdrb9gMwweB4gRWqurO3YLTcfbkiaGXRCzXwaWfrdiDdt0quqaadk2wN2mEoxdt0q9pJ(w6Voh3qk0qU3WenefeaWGbhd5SXmkioZmEoxdt0WX7Mnqsm0ZGmVOzLSnKcnCQH3AyIgkNS5i2qEAi35vdt0WXcwdZgijgV0iHT5rDYW(NDfGvWznKNgIPfgZ6XMlo2G5u0IvhEdtzdNOHKqdNOHjAOhBU4gVMfR)2rjnKNgIaLROgHwXLIqUaLjdvQkc9wUSvOiqbbamELll2caUiAaPBiF(nefeaWGIT1PnG0kIq71FkcuzXYIuD5kxr9uEP4srixGYKHkvfHElx2kueOGaaguSToTbKUH853q0hJByIgcu5zUDL5OoCdPqd1)ZgpNZGIT1PnRmh1HBiF(ne9X4gMOHavEMBxzoQd3qk0WjqGIi0E9NIG(96pLROE6ufxkc5cuMmuPQi0B5YwHIafeaWGIT1PnG0nKp)gcu5zUDL5OoCdPqdNyQIi0E9NIyJ0Y9GylWk3KIOYvupDcfxkc5cuMmuPQicTx)Pi0)L(rsSEMyX01wowrmeSElAV(trWvkCskfoznCYZensnC()dP6Ay27CAyCJgIDqaGgYkKKg6zfM0gg3OHZbIOsdrf3LTH6Fgn8gUYCuxdxbJ4Pve6TCzRqrqzdhVB2I2SYCuhUH80qU3Wenu)ZOVL(RZXnKcnebnmrdPSHJ3nBGKy8sJuD5nKp)gIPfgZ6XMlo24zBGZS6WBipnCAdPQHjAOCYMJOziaLU8gYd5gobVAivnKp)gI(yCdt0qGkpZTRmh1HBifAicuUI6PKuXLIqUaLjdvQkIq71FkczM(5iRf9VHIyiy9w0E9NIysoqevAONjR0qC2dYgnevA48Vsd1)nkV(d3W)AONjnu)3aSCfHElx2kueOGaagVYLfBbaxenG0nKp)gszd1)nal3meH2gmMKxXPfJCbktgnKkLROEk3vCPiKlqzYqLQIyiy9w0E9NIG3VslnKERFlhXg6Fd)JeaXsd5ib9FkIlMffXK4DWlxQDTdb71Hi2QdgtrO3YLTcfHW7bw00YWmjEh8YLAx7qWEDiIT6GXueH2R)uetI3bVCP21oeSxhIyRoymLROEkcuCPicTx)PiaXITCzgRiKlqzYqLQYvUI45W4irArXLI6PkUueYfOmzOsvrO3YLTcfbkiaGjtI1TpG1ZelNInmG0kIq71FkcShlgCZfLROEcfxkc5cuMmuPQicTx)PiWGhqTIIGvNy1dfb3tzUEOCf1KuXLIqUaLjdvQkIq71FkI5)pGAffHElx2kueOGaaM5)pKQZc87SbKUHjAiMwymRhBU4yJNTboZQdVHuOHt0WenKIn0dMCUHbEXARdtxB41Fg5cuMmueS6eREOi4EkZ1dLROM7kUueYfOmzOsvrO3YLTcfHCYMJydPqdjjVAyIgoE3SfTzL5OoCd5PHC3GGgMOHu2q9)SXZ5mELll2caUiAwzoQd3qEi3qEZGGgYNFdxWta(nxm6WfefRgCR3ixGYKrdPQHjAikiaGrZKy1b2Rl3G9qJudPqdN2WenKInefeaWe0ccBPxze(VyREJ01LBaPByIgsXgIccayqz)pyGy3as3WenKInefeaWGIT1PnG0nmrdPSH6)zJNZz0)L(rsSEMyX01wo2SYCuhUH80qEZGGgYNFdPyd1FA5IZnxLN5wGqAivnmrdPSHuSH6pTCX5Mt07Z(D0q(8BO(F245CMye0ELwSyoXoBwzoQd3qEi3qe0q(8B44DtmcAVslwmNyNTJyoYfZkZrD4gYtdrinKkfrO96pfrMeRBFaRNjwofBOCf1iqXLIqUaLjdvQkc9wUSvOiKt2CeBifAij5vdt0WX7MTOnRmh1HBipnK7ge0WenKYgQ)NnEoNXRCzXwaWfrZkZrD4gYd5gYDdcAiF(nCbpb43CXOdxquSAWTEJCbktgnKQgMOHOGaagntIvhyVUCd2dnsnKcnCAdt0qk2quqaatqliSLELr4)IT6nsxxUbKUHjAifBikiaGbL9)GbIDdiDdt0qkBifBikiaGbfBRtBaPBiF(nu)PLlo3CIEF2VJgMOHEWKZn4iDKl29J1ixGYKrdt0quqaadk2wN2SYCuhUH80qERHu1WenKYgQ)NnEoNr)x6hjX6zIftxB5yZkZrD4gYtd5ndcAiF(nKInu)PLlo3CvEMBbcPHu1WenKYgsXgQ)0YfNBorVp73rd5ZVH6)zJNZzIrq7vAXI5e7SzL5OoCd5HCdrqd5ZVHJ3nXiO9kTyXCID2oI5ixmRmh1HBipneH0qQAyIgcu5zUDL5OoCd5PHiefrO96pfX8)hs1zb(Dw5kx5kI0YIR)uupbVMykVqitjPIGtSxD5yfbjcsmUb1K4uZ7pznSHCLjnSMP)1BiWVnmfbQRWzYMInCfEpWALrdX)S0Wa0)5WLrd1zXLlytJCkOoPHCFYA4K)xAzDz0WuCbpb43CXGqLIn0)gMIl4ja)MlgekJCbktgPydPCkctLPrUrMebjg3GAsCQ59NSg2qUYKgwZ0)6ne43gMIdbiazEk2Wv49aRvgne)Zsddq)NdxgnuNfxUGnnYPG6KgoX0jRHt(FPL1LrdjQ5jVHyeppq4gsI2q)BykamA4Osx46Vg(0Yg(VnKYKPQHuofHPY0iNcQtA4eKCYA4K)xAzDz0qIAEYBigXZdeUHKOn0)gMcaJgoQ0fU(RHpTSH)BdPmzQAiLtGWuzAKBKjrqIXnOMeNAE)jRHnKRmPH1m9VEdb(THPik7)HhS)WPydxH3dSwz0q8plnma9FoCz0qDwC5c20iNcQtAijNSgo5)LwwxgnKOMN8gIr88aHBijAd9VHPaWOHJkDHR)A4tlB4)2qktMQgs5ueMktJCJmjcsmUb1K4uZ7pznSHCLjnSMP)1BiWVnmf1)ZgpNlfB4k8EG1kJgI)zPHbO)ZHlJgQZIlxWMg5uqDsdNyYA4K)xAzDz0Wue)Gm06ggeQuSH(3Wue)Gm06ggekJCbktgPydPCceMktJCJmjcsmUb1K4uZ7pznSHCLjnSMP)1BiWVnmfFomosKwsXgUcVhyTYOH4FwAya6)C4YOH6S4YfSProfuN0qUpznCY)lTSUmAykUGNa8BUyqOsXg6FdtXf8eGFZfdcLrUaLjJuSHuofHPY0iNcQtAicMSgo5)LwwxgnmfxWta(nxmiuPyd9VHP4cEcWV5IbHYixGYKrk2qkNIWuzAKBKjXNP)1LrdNYRggAV(RHSc7ytJSIatlAf1t5fjve07dumrrWTCBd5MYgSgojTG1OrMB52gImidXgobViTHtWRjM2i3iZTCBd5MYgSgsIrImf0qDCnmy4VHOsdbEWB0WWByM704jl5KZlSBYlpde1O)5KrOIBsJnsM34Di08MM3HqJqZBaiia0cc0Y0PiyebjdEX7gbaqJCJm3YTnCYZIlxWtwJm3YTnKeA4ybRH55W4irAXQdN80gQZens4g6FdhlynmphghjslwD4MgzULBBij0Wj)V0Y6nmvUAi9)m7k4hC1sd9VHCIYBOGW0RGX1FMgzULBBij0qsSXOH15YUG0EHYKgYnzcotVbG3WcOHi(Gnmlsln8EpRU8gkmS0q)B44nnYnYH2R)Wg6v0)mA4jro50Xwbkti9IzHmWdUAAlA5cPPdgOqMxnYCBdjYwz0qYnKxK2qQ)JeWxqJZEVHCJajPHKB4usBiXf04S3Bi3iqsAi5gobPnmfqI3qYnKKK2qcofT0qYnK7nYH2R)Wg6v0)mA4jro50Xwbkti9IzHmqXyYsA6GbkKN2iZTnKqhmPHCkpRHzb2ftJCO96pSHEf9pJgEsKtoDSvGYesVywiVfT1lnsysthmqHmcPro0E9h2qVI(NrdpjYjJuDJvgwmDTLJBKdTx)Hn0RO)z0WtICYOV7mzybybIYGtD5w)r46AKdTx)Hn0RO)z0WtICYambNP3aWjTaiJFqgADddni2bzIvwqAV(ZixGYKbF(4hKHw3WK(zHxmXIFwA5CJCbktgnYH2R)Wg6v0)mA4jroz695WiTaiJccayM))qQolWVZMXZ5AKdTx)Hn0RO)z0WtICY6WTa)otAbqgfeaWm))HuDwGFNnJNZ1i3ihAV(dtEbpBO96plRWoPxmlKrdwCAH0cGmkiaGz()dP6Sa)oBaPtqXXcwdZZHXrI0IvhEJCO96pCsKtwhmMn0E9NLvyN0lMfYphghjslKwaKhlynmphghjslwD4nYCBdjrUphwd5KjNKw2gs)yCHYKg5q71F4KiNm9(CynYH2R)WjrozVYLfBbaxejTaiJccay0HBb(D2mEoxJCO96pCsKtwhUf43zslaYOGaagD4wGFNnJNZ1iZTnmfEsdXzV3qSlbZZAKdTx)HtICYl4zdTx)zzf2j9IzHm2LG5zKwaKrbbam4Sy8CMf2WasZNpkiaGHEFomdiDJCO96pCsKtgJeiJzrdCwJCO96pCsKtwhmMn0E9NLvyN0lMfYyXbPjTaihAVsl2X7MTOjZRg5q71F4KiNSoymBO96plRWoPxmlK1)ZgpNRrMBBi1IEF2VJjRHtEG9gsYg(Bd5Ed1)m63q6VoVHBrJB4FnexxotAOhBU4n8bDCnKg(anevwSSi1WFB4aCRlVHOYILfPgwaneq2G1qGvUjfXgw4gcs3Wui3OHbnndXggnebA6gYnk6gYjtUgYf3SHfUHG0nmUrd5umwdX)FneiySg(aaMg5q71F4KiN8w0KwaK1FA5IZnNO3N97ibLu0dMCUbL9)Wd2FyJCbktg85Jccayqz)p8G9h2astvcmTWywp2CXXgpBdCMvho5PjOu)ZOVL(RZX8mrIvawbNfOmjXybRHzlAJxAKW28Oozy)ZUcWk4mEshBfOmXSfT1lns4eusruqaadk2wN2asZNV(F245CguSToTbKMpFkrbbamOyBDAdiDc9)SXZ5maYgmlWk3KIObKMkQ4Zx)ZOVL(RZXKrqcuqaaJx5YITaGlIgq6eOGaagVYLfBbaxenRmh1HPa3tmwWAy2I24LgjSnpQtg2)SRaScoJheqvJCO96pCsKtEbpBO96plRWoPxmlKbQRWzYsAbqw)ZOVL(RZX8qMseqcPJTcuMyaEWvtBrlxOQro0E9hojYjtV1CWSC2WZiTaipwWAyO3AoywoB4zgV0iHT5rDYW(NDfGvWz8qEcELq)ZOVL(RZX8qEcsz1jw9GmcAK52gojdY8IeY1JgIDjyEwJCO96pCsKtwhmMn0E9NLvyN0lMfYyxcMNrAbqgfeaWGIT1PnG0nYCBd5ktA48J9gkimTC4kT0Wu5QHAe1mPHuYv2k4SgsKTYOHeCkAPH6h7nC6ue0q5KnhrsB4CGK0qm4knKJ0qDCnCoqsAONfEdRRHCVH5ShnyyQAKdTx)HtICYCIYjflAYus50PiGeMGKPefeaWuNo2l86pls1LBFaRNj2jb4LZedinvKaLYjBoIgn4UY5jrsdcsPCYMJOzLC5sIsUZRuIccay0mjwDG96YnG0urfvjlNS5iAwjxoslaYEWKZnOS)hEW(dBKlqzYibkiaGbL9)Wd2FyZ45CjcTxPflQB9TYZLftMxnYCBddTx)HtICY0)ZSRGFWvlKwaK9GjNBqz)p8G9h2ixGYKrcuqaadk7)HhS)WMXZ5sqPCYMJysK0GGukNS5iAwjxUKOK78kLOGaagntIvhyVUCdinvurbkNofbKWeKmLOGaaM60XEHx)zrQUC7dy9mXojaVCMyaPPkrO9kTyrDRVvEUSyY8Qro0E9hojYjVGNn0E9NLvyN0lMfYOS)hEW(dtAbq2dMCUbL9)Wd2FyJCbktgjqbbamOS)hEW(dBgpNRro0E9hojYjdi7RRheBrlxivJOMjwp2CXXKNsAbqgfeaWe0ccBPxze(VyREJ01LBaPBKdTx)HtICY0)ZSRGFWvlKc8R9ee2jpTro0E9hojYjVbscPAe1mX6XMloM8uslaYuUcWk4SaLj85tllUWUCUDgK5fnRKLNX7Mnqsm0ZGmVOzLSuLySG1WSbsIXlnsyBEuNmS)zxbyfCgpyAHXSES5IJnyofTy1HNYjiHjAKdTx)HtICYmWlwBDy6AdV(JunIAMy9yZfhtEkPfazkxbyfCwGYe(8PLfxyxo3odY8IMvYYZ4Ddd8I1whMU2WR)m0ZGmVOzLSuLySG1WWaVyT1HPRn86pJxAKW28Oozy)ZUcWk4mEW0cJz9yZfhBWCkAXQdpLtqct0ihAV(dNe5KP)Nzxb)GRwif4x7jiStEAJCO96pCsKt2Z2aNz1HtQgrntSES5IJjpL0cG8kaRGZcuMKySG1W4zBGZS6WnEPrcBZJ6KH9p7kaRGZ4HsUNeMwymRhBU4yJNTboZQdpLCNksukNM0CGDzr0MoyGcvKG(Vby5gpWUyb(1IY(FyKlqzYGe0FA5IZnNO3N97ibLuefeaWGIT1PnG085JPfgZ6XMlo24zBGZS6W5zkvnYH2R)Wjroz6)z2vWp4Qfsb(1Ecc7KN2ihAV(dNe5KrxqpywmlWzKwaKPCJAyL0Y5MymWM64HYPjnhiSvNfBUGjbDwS5c2cSH2R)cgvPCfDwS5I1RzHQeuIPfgZ6XMlo2GUGEWSywGZszO96pd6c6bZIzboZmI5ixirdTx)zqxqpywmlWzg9JDQ4HYq71FgC2kdZiMJCHen0E9NbNTYWOFStvJCO96pCsKtgZPOfRoCslaYyAHXSES5IJnyofTy1HZZ0KqbbamOyBDAdiDkNOro0E9hojYj7zBGZS6WjTaiJPfgZ6XMlo24zBGZS6W5HKnYH2R)WjrozC2kdslaYOGaagntIvhyVUCdiDckrbbamyWXqoBmJcIZmJNZLafeaWGZIXZzwydZ45C85JccayqX260gqAQAKdTx)HtICYBGKqQgrntSES5IJjpL0cGmkiaGbfBRtBaPtmwWAy2ajX4LgjSnpQtg2)SRaScoJNjAKdTx)HtICY6GXSH2R)SSc7KEXSqgOymzBKBKdTx)HnOS)hEW(dtEdKes1iQzI1JnxCm5PKwaKPKIEPrQUC(8PCQzIusllUWUCUDgK5fnRKLhYJ3nBGKyONbzErZkzPIpFkdTxPflQB9TYZLftEIeRaScolqzcvuLafeaWG62nqsmJNZ1ihAV(dBqz)p8G9hojYjZaVyT1HPRn86ps1iQzI1JnxCm5PKwaKxbyfCwGYKeOGaagu3o))buRygpNRro0E9h2GY(F4b7pCsKt2Z2aNz1HtQgrntSES5IJjpL0cG8kaRGZcuMKafeaWG6wpBdCMz8CUeJfSggpBdCMvhUXlnsyBEuNmS)zxbyfCgpuY9KW0cJz9yZfhB8SnWzwD4PK7urIs50KMdSllI20bduOIe0)nal34b2flWVwu2)dJCbktgnYH2R)Wgu2)dpy)HtICYOlOhmlMf4mslaYOGaagu3IUGEWSywGZmJNZ1ihAV(dBqz)p8G9hojYjJ5u0IvhoPfazuqaadQBXCkAXmEoxcmTWywp2CXXgmNIwS6W5zAJCO96pSbL9)Wd2F4KiNmoBLbPfazuqaadQBXzRmmJNZ1ihAV(dBqz)p8G9hojYjJ5u0IvhoPfazuqaadQBXCkAXmEoxJCO96pSbL9)Wd2F4KiNSNTboZQdN0cGmkiaGb1TE2g4mZ45CnYnYH2R)Wg9)SXZ5ihJG2R0IfZj2zs1iQzI1JnxCm5PKsMskP44DtmcAVslwmNyNTJyoYfJxAKQlNp)X7Mye0ELwSyoXoBhXCKlMvMJ6WuycQsq54DtmcAVslwmNyNTJyoYfd2dnsuGK85tXX7Mye0ELwSyoXoBZKGzWEOrINPuLGIH2R)mXiO9kTyXCID2MjbZuNfGv5zEckgAV(ZeJG2R0IfZj2z7iMJCXuNfGv5zEckgAV(ZeJG2R0IfZj2ztDwawLN5uLWJnxCJxZI1F7OeEqaF(H2R0IvozUemptKGIJ3nXiO9kTyXCID2oI5ixmEPrQU8eYjBoIuGKiiHhBU4gVMfR)2rj8GGg5q71FyJ(F245CjrozaMGZ0Ba4KwaKPe)Gm06ggAqSdYeRSG0E9hF(4hKHw3WK(zHxmXIFwA5CQiTox2fK2T18SmQWfYtjTox2fK2T5ShnyKNsADUSliTBlaY4hKHw3WK(zHxmXIFwA58gzUTHtEG9gYvLlBkIBi3eCrSHOcWVsdP83gwZZYOcNHyddaxwQAOoWED5nKBkBWAi3CLBsrSHfqdtvwSSi1Wc3qQtHC1W)AO(F245CMg5q71FyJ(F245CjrozVYLfBbaxejfJ4PjdiBWSaRCtkIKwaK1)ZgpNZGIT1PnG0nYH2R)Wg9)SXZ5sICYaYgmlWk3KIiPAe1mX6XMloM8uslaY6Fg9T0FDoMcKmHhBU4gVMfR)2rj8GqsqjkiaGbhPJCXUFSgqA(8POhm5Cdosh5ID)ynYfOmzqvckPO(F245CgVYLfBbaxenG085R)NnEoNbfBRtBaPPIpFGkpZTRmh1HPaVlbqLN52vMJ6W8mrJm32qUsHtsPWjRHulYOH(3qmINUHCkpRHCkpRHBKwUhe3qGvUjfXgYjtUgYrA4cEneyLBsrenUbPn83ggotcS3qDMOrQHfqdlh3qo)6znS8g5q71FyJ(F245CjrozuzXYIePfaz9pJ(w6VohZdzs2ihAV(dB0)ZgpNljYjxNo2l86pslaY6Fg9T0FDoMhYKSrMBBixlInmUrdV3BiNa7sd5IB2q5KnhrsBikO3WGH)gojaXEdbXsdlVHa)2WjvwKAyCJgwNo2d3ihAV(dB0)ZgpNljYj7vUSyla4IiPfaz5KnhrZqakD58WDEXNpkiaGbfBRtBaP5ZNspyY5g6vgH)RrUaLjJe4SFDb7w3huGKu1iZTnCsUYZ8gIknKZ(xEd9VHGyPHeZcB0W)Ai3iqsAyDnmTSi2W0YIydVsNjnexoy41FysBikO3W0YIyd3yfgInYH2R)Wg9)SXZ5sICY4Sy8CMf2G0cGmkiaGXRCzXwaWfrdiDcuqaadk2wN2mEoxc9pJ(w6VohtbUNafeaWGbhd5SXmkioZmEoxIX7Mnqsm0ZGmVOzLSuyQH3siNS5iYd35vIXcwdZgijgV0iHT5rDYW(NDfGvWz8GPfgZ6XMlo2G5u0IvhEkNGeMiHhBU4gVMfR)2rj8GGg5q71FyJ(F245CjrozuzXYIuD5KwaKrbbamELll2caUiAaP5ZhfeaWGIT1PnG0nYH2R)Wg9)SXZ5sICY0Vx)rAbqgfeaWGIT1PnG085J(yCcGkpZTRmh1HPG(F245CguSToTzL5OomF(OpgNaOYZC7kZrDykmbcAKdTx)Hn6)zJNZLe5K3iTCpi2cSYnPisAbqgfeaWGIT1PnG085du5zUDL5OomfMyAJm32qUsHtsPWjRHtEMOrQHZ)FivxdZENtdJB0qSdca0qwHK0qpRWK2W4gnCoqevAiQ4USnu)ZOH3WvMJ6A4kyepDJCO96pSr)pB8CUKiNS(V0psI1ZelMU2YXKwaKPC8UzlAZkZrDyE4Ec9pJ(w6VohtbeKGYX7MnqsmEPrQUC(8X0cJz9yZfhB8SnWzwD48mLQeYjBoIMHau6Y5H8e8Ik(8rFmobqLN52vMJ6WuabnYCBdNKderLg6zYkneN9GSrdrLgo)R0q9FJYR)Wn8Vg6zsd1)nalVro0E9h2O)NnEoxsKtwMPFoYAr)BqAbqgfeaW4vUSyla4IObKMpFk1)nal3meH2gmMKxXPfJCbktgu1iZTnK3VslnKERFlhXg6Fd)JeaXsd5ib9FnYH2R)Wg9)SXZ5sICYGyXwUmt6fZc5jX7GxUu7Ahc2RdrSvhmgPfazH3dSOPLHzs8o4Ll1U2HG96qeB1bJ1ihAV(dB0)ZgpNljYjdIfB5YmUrUro0E9h2aumMSK3ajHunIAMy9yZfhtEkPfa50XwbktmafJjl5PjwbyfCwGYKeJ3nBGKyONbzErZkzPa5PMjsjTS4c7Y52zqMx0Ss2g5q71FydqXyYMe5K3ajH0cGC6yRaLjgGIXKL8enYH2R)WgGIXKnjYjZaVyT1HPRn86pslaYPJTcuMyakgtwYKSro0E9h2aumMSjrozmNIwiTaiNo2kqzIbOymzjZ9g5q71FydqXyYMe5KXzRmiTaiJccayWGJHC2ygfeNzgpNRro0E9h2aumMSjrozaMGZ0Ba4KwaKXpidTUHHge7GmXkliTx)zKlqzYGpF8dYqRBys)SWlMyXplTCUrUaLjdsRZLDbPDBnplJkCH8usRZLDbPDBo7rdg5PKwNl7cs72cGm(bzO1nmPFw4ftS4NLwoVrUro0E9h2auxHZKLm9)m7k4hC1cPa)ApbHDYtBKdTx)Hna1v4mztICY4iDKl29JL0cGmkiaGbhPJCXUFSMvMJ6WuGKnYH2R)WgG6kCMSjroz6TMdMLZgEgPfazkhlynm0BnhmlNn8mJxAKW28Oozy)ZUcWk4mEizkPetlmM1JnxCSHER5Gz5SHNL0uQsGPfgZ6XMlo2qV1CWSC2WZ4zkv85JPfgZ6XMlo2qV1CWSC2WZ4HssM00u6bto3Gduz9)9mJCbktgu1ihAV(dBaQRWzYMe5K3IMunIAMy9yZfhtEkPfa5vawbNfOmjXybRHzlAJxAKW28Oozy)ZUcWk4mEshBfOmXSfT1lns4eusjkiaGXRCzXwaWfrdinF(u0lns1LtvckrbbamOS)hEW(dBaP5ZNIEWKZnOS)hEW(dBKlqzYGk(8POhm5CdoqL1)3ZmYfOmzqvckX0cJz9yZfhBO3AoywoB4zKNYNpf9GjNBO3AoywoB4zg5cuMmOkbLH2R0ID8UzlAY8IpFV0ivxEIq7vAXoE3Sfn5P85tXf8eGFZfZydW8m3(a2Hi0wGxdI5ZNIEWKZn4avw)FpZixGYKbvnYH2R)WgG6kCMSjrozCKoYf7(XsAbqgfeaWGJ0rUy3pwZkZrDykqP(NrFl9xNJtAkvPK3sjVmKSro0E9h2auxHZKnjYjdi7RRheBrlxiDoqyRCYMJi5PKQruZeRhBU4yYtBKdTx)Hna1v4mztICYaY(66bXw0Yfs1iQzI1JnxCm5PKwaKrbbamOyBDAdiDcpyY5g8dYSpG1ZelWVc2nYfOmzWNV(F245Cg9FPFKeRNjwmDTLJnRmh1HPW0e6pTCX5MRYZClqinYnYnYH2R)WMNdJJePfYypwm4MlKwaKrbbamzsSU9bSEMy5uSHbKUro0E9h28CyCKiTKe5KXGhqTcPS6eREqM7PmxpAKdTx)Hnphghjsljro55)pGAfsz1jw9Gm3tzUEqAbqgfeaWm))HuDwGFNnG0jW0cJz9yZfhB8SnWzwD4uyIeu0dMCUHbEXARdtxB41Fg5cuMmAKdTx)Hnphghjsljro5mjw3(awptSCk2G0cGSCYMJifijVsmE3SfTzL5OompC3GGeuQ)NnEoNXRCzXwaWfrZkZrDyEiZBgeWN)cEcWV5IrhUGOy1GB9uLafeaWOzsS6a71LBWEOrIcttqruqaatqliSLELr4)IT6nsxxUbKobfrbbamOS)hmqSBaPtqruqaadk2wN2asNGs9)SXZ5m6)s)ijwptSy6AlhBwzoQdZdVzqaF(uu)PLlo3CvEMBbcHQeusr9NwU4CZj69z)o4Zx)pB8CotmcAVslwmNyNnRmh1H5Hmc4ZF8UjgbTxPflMtSZ2rmh5IzL5OompieQAKdTx)Hnphghjsljro55)pKQZc87mPfaz5KnhrkqsELy8UzlAZkZrDyE4UbbjOu)pB8CoJx5YITaGlIMvMJ6W8qM7geWN)cEcWV5IrhUGOy1GB9uLafeaWOzsS6a71LBWEOrIcttqruqaatqliSLELr4)IT6nsxxUbKobfrbbamOS)hmqSBaPtqjfrbbamOyBDAdinF(6pTCX5Mt07Z(DKWdMCUbhPJCXUFSg5cuMmsGccayqX260MvMJ6W8WBuLGs9)SXZ5m6)s)ijwptSy6AlhBwzoQdZdVzqaF(uu)PLlo3CvEMBbcHQeusr9NwU4CZj69z)o4Zx)pB8CotmcAVslwmNyNnRmh1H5Hmc4ZF8UjgbTxPflMtSZ2rmh5IzL5OompieQsau5zUDL5OompiKg5g5q71FydwCqAYmWlwBDy6AdV(J0cGS(tlxCU5e9(SFhjW0cJz9yZfhB8SnWzwD4uG7j0)m6BP)6Cmfqqck6LgP6Ytqruqaadk2wN2as3ihAV(dBWIdsNe5KP)Nzxb)GRwif4x7jiStEAJCO96pSbloiDsKtghPJCXUFSKwaK9GjNBaKnywGvUjfrJCbktgj0)ZgpNZaiBWSaRCtkIgq6euefeaWGJ0rUy3pwdiDc9pJ(w6VohZZ0eJ3nBGKy8sJuD5jOC8UHbEXARdtxB41FgV0ivxoF(u0dMCUHbEXARdtxB41Fg5cuMmOQro0E9h2GfhKojYjt)pZUc(bxTqAbq2dMCUbL9)Wd2FyJCbktgjqbbamOS)hEW(dBgpNlbLYjBoIjrsdcsPCYMJOzLC5sIsUZRuIccay0mjwDG96YnG0urffOC6ueqctqYuIccayQth7fE9NfP6YTpG1Ze7Ka8YzIbKMQeH2R0If1T(w55YIjZRg5q71FydwCq6KiNSoymBO96plRWoPxmlKrz)p8G9hM0cGShm5Cdk7)HhS)Wg5cuMmsGccayqz)p8G9h2mEoxck1)m6BP)6CmfqaF(yAHXSES5IJnE2g4mRoCYtPQro0E9h2GfhKojYjRdgZgAV(ZYkSt6fZcz9)SXZ5AKdTx)HnyXbPtICY6GXSH2R)SSc7KEXSqgOUcNjlPfaz9pJ(w6VohZdjtqjkiaGbL9)Wd2FydinF(u0dMCUbL9)Wd2FyJCbktgu1i3ihAV(dBWUempJm9)m7k4hC1cPa)ApbHDYtBK52gYncKKgEImWnCFW8mgIneb8IeTHpqdlh3qMC5EwddVHrdNRRMbNBO)nedU0bg3qC2kdCdh0sJCO96pSb7sW8SKiN8gijKQruZeRhBU4yYtjTait54DZgijg6zqMx0Sswkm1Ga(8xbyfCwGYeQsmwWAy2ajX4LgjSnpQtg2)SRaScoJNj4ZNsAzXf2LZTZGmVOzLS8mE3SbsIHEgK5fnRKnbkiaGbfBRtBaPtGPfgZ6XMlo24zBGZS6WPajtO)0YfNBorVp73bv85JccayqX260MvMJ6WuyAJCO96pSb7sW8SKiNmd8I1whMU2WR)iTaiJPfgZ6XMlo24zBGZS6WPajtScWk4SaLjjglynmmWlwBDy6AdV(Z4LgjSnpQtg2)SRaScoJheKGs9pJ(w6VohtM785pE3WaVyT1HPRn86pZkZrDykGa(8P44Ddd8I1whMU2WR)mEPrQUCQAK52gM6c6bRHeSaN1Wc3quXDzBONfxdXUempRHezRmAy4nKKn0JnxCCJCO96pSb7sW8SKiNm6c6bZIzboJ0cGmMwymRhBU4yd6c6bZIzboJNjAKdTx)HnyxcMNLe5KP)Nzxb)GRwif4x7jiStEAJCO96pSb7sW8SKiNmoBLbPfaz9pJ(w6VohtbUNatlmM1JnxCSXZ2aNz1Htbe0i3ihAV(dBqdwCAHmg8aQviTaiJccayenROXIf)SynJNZLafeaWiAwrJfld8I1mEoxckxbyfCwGYe(8Pm0ELwSYjZLG5zAIq7vAXoE3GbpGAfkeAVslw5K5sWurvJCO96pSbnyXPLKiNm2JfdU5cPfazuqaaJOzfnwS4NfRzL5Oompt5vs6a7wVMf(8rbbamIMv0yXYaVynRmh1H5zkVsshy361S0ihAV(dBqdwCAjjYjJ9ybQviTaiJccayenROXILbEXAwzoQdZJoWU1RzHpFuqaaJOzfnwS4NfRz8CUe4NfRv0SIgl8Wl(8rbbamIMv0yXIFwSMXZ5sWaVyTIMv0yHecTx)z4SHNzQZcWQ8mNctBKdTx)HnObloTKe5K5SHNrAbqgfeaWiAwrJfl(zXAwzoQdZJoWU1RzHpFuqaaJOzfnwSmWlwZ45CjyGxSwrZkASqcH2R)mC2WZm1zbyvEMZdVuUYvka]] )


end
