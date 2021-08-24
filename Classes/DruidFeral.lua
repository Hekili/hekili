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
            dot = "buff",
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
                if active_enemies > 1 and settings.cycle and target.time_to_die < longest_ttd then return "cycle" end
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
                if active_enemies > 1 and settings.cycle and talent.sabertooth.enabled and dot.rip.down and active_dot.rip > 0 then return "cycle" end
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
                if state.spec.feral and active_enemies > 1 and target.time_to_die < longest_ttd then return "cycle" end
            end,

            handler = function ()
                applyDebuff( "target", "adaptive_swarm_dot", nil, 3 )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            copy = { "adaptive_swarm_damage", "adaptive_swarm_heal", 325733, 325748 },
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


    spec:RegisterPack( "Feral", 20210824, [[dS0o2bqiKqpcvIUeIqztIWNqvsJcj6uijRsrKxjImlePBbb1UO4xIOggQsDmfPLPi8mKGPHkPRbb2MibFdvcghQs4Cqq06ueL5Hi6EiQ9HQ4GqqyHIKEOIOAIOkr2iQe6JOkrDseHQvcrntrc5MIer7ej1pfjudfri1sHG0tryQOs9veHKXIie7LK)sPbdCyHfdPhtQjRWLj2miFwunAr50swTir61qOzJYTvu7wLFRQHJuhxKiSCLEoutNQRdQTls9DuX4reCEiY6fjQ5JQA)sTAQIBfXiCrr9e8EIP8Mxmbxntri5AkW7PkchjArrqhAeJCrrCXSOi4IYgmfbDGe7JHIBfb(HxTOiYCNgpzjNCE5zWOg9pNmUMHzHx)P3aYtgxZ6KveOWfZjXpfQIyeUOOEcEpXuEZlMGRMPiKCfbuycfra7z)QiiQ5jxrKvJHCkufXqWAfbxu2G1aEPfUgnYieW5WyVbtqbsBWe8EIPnYnYCrzdwdqiirNIAGoUgem83auPbqp8nAq4niZDA8KLCY5f2n5LNbJA0)CYKiXLYXgjNc8ceYuqZlqiritbieeqAbbAz6uemIGcbV5fJacQrUrEYZIlxWtwJmc3GXcxdZZHXrI0Ivho5PnqNjAeXnW)gmw4AyEomosKwS6WnnYiCdM8)slR3Gu5Ub0)ZSRGF4vlnW)gWjkVbcjqVcgx)zAKr4gGqmgnOox2fM2luM0aUitWz6nG8guqnaPhUbzrAPb37z1L3aHHLg4FdgVPrgHBaV0F8Q3GSNnAWK)x6hrPbq)2aeAr3a4JjyCdq6H5vgRbRemgsnaHw0gfbRWowXTIaL9)Wd2Fyf3kQNQ4wrixGYKHkvfrO96pfXgikkc9wUSvOiOSbuSbEPrSU8gWNFdOSbtnt0Gj1aAzXf2LZTZWmVOzLSnGhYny8Uzdefd9mmZlAwjBdOQb853akBqO9kTyrDRVvEUS4gqUbt0GenyfOvWzbktAavnGQgKObOWqqgu3UbIIz8CofHgjntSES5IJvupv5kQNqXTIqUaLjdvQkIq71Fkcg8fRTomDTHx)Pi0B5YwHIyfOvWzbktAqIgGcdbzqD78)huTIz8CofHgjntSES5IJvupv5kQPGIBfHCbktgQuveH2R)ueE2g4mRoCfHElx2kueRaTcolqzsds0auyiidQB9SnWzMXZ5AqIgmw4Ay8SnWzwD4gV0iIT5rDYW(NDfOvWznGNgqzd4AdsQbyAHXSES5IJnE2g4mRo8gmPgW1gqvdsUbu2GPniPgmhyxwKSPdgS0aQAac3a9Fd4YnEGDXc9RfL9)WixGYKHIqJKMjwp2CXXkQNQCf1CvXTIqUaLjdvQkc9wUSvOiqHHGmOUfDH9GzXSaNzgpNtreAV(trGUWEWSywGZuUIAeO4wrixGYKHkvfHElx2kueOWqqgu3I5u0Iz8CUgKObyAHXSES5IJnyofTy1H3aEAWufrO96pfbMtrlwD4kxrDkO4wrixGYKHkvfHElx2kueOWqqgu3IZwzygpNtreAV(trGZwzOCf1Cbf3kc5cuMmuPQi0B5YwHIafgcYG6wmNIwmJNZPicTx)PiWCkAXQdx5kQ5fkUveYfOmzOsvrO3YLTcfbkmeKb1TE2g4mZ45CkIq71FkcpBdCMvhUYvUIaQUcNjRIBf1tvCRiKlqzYqLQIa6x7jKGROEQIi0E9NIG(FMDf8dVAr5kQNqXTIqUaLjdvQkc9wUSvOiqHHGm4iDKl29J1SYCuhUbKSbuqreAV(trGJ0rUy3pwLROMckUveYfOmzOsvrO3YLTcfbLnySW1WqV1CWSC2WZmEPreBZJ6KH9p7kqRGZAapnGcnysnGYgGPfgZ6XMlo2qV1CWSC2WZAqsnyAdOQbjAaMwymRhBU4yd9wZbZYzdpRb80GPnGQgWNFdW0cJz9yZfhBO3AoywoB4znGNgqzdOqdsQbtBWKAGhm5CdoqL1)3ZmYfOmz0aQueH2R)ue0BnhmlNn8mLROMRkUveYfOmzOsvreAV(trSfTIqVLlBfkIvGwbNfOmPbjAWyHRHzlAJxAeX28Oozy)ZUc0k4SgWtdshBfOmXSfT1lnI4gKObu2akBakmeKXRCzXwi4fjdmDd4ZVbuSbEPrSU8gqvds0akBakmeKbL9)Wd2FydmDd4ZVbuSbEWKZnOS)hEW(dBKlqzYObu1a(8BafBGhm5CdoqL1)3ZmYfOmz0aQAqIgqzdW0cJz9yZfhBO3AoywoB4znGCdM2a(8BafBGhm5Cd9wZbZYzdpZixGYKrdOQbjAaLni0ELwSJ3nBr3aYnG3nGp)g4LgX6YBqIgeAVsl2X7MTOBa5gmTb853ak2Gf(eOFZfZyd48m3(q2Hi0wOxdJnYfOmz0a(8BafBGhm5CdoqL1)3ZmYfOmz0aQueAK0mX6XMlowr9uLROgbkUveYfOmzOsvrO3YLTcfbkmeKbhPJCXUFSMvMJ6WnGKnGYgO)z03s)154gKudM2aQAWKAqk0Gj1aEBOGIi0E9NIahPJCXUFSkxrDkO4wrixGYKHkvfXCqcw5Knhjf1tveH2R)ueqY(66HXw0YffHgjntSES5IJvupv5kQ5ckUveYfOmzOsvreAV(traj7RRhgBrlxue6TCzRqrGcdbzqX260gy6gKObEWKZn4hMzFiRNjwOFfSBKlqzYOb853a9)SXZ5m6)s)ikwptSy6AlhBwzoQd3as2GPnird0FA5IZnxLN5wOqueAK0mX6XMlowr9uLRCfbAWItlkUvupvXTIqUaLjdvQkc9wUSvOiqHHGmIMv0yXIFwSMXZ5AqIgGcdbzenROXILbFXAgpNRbjAaLnyfOvWzbktAaF(nGYgeAVslw5K5sWnGNgmTbjAqO9kTyhVBWWhuTsdizdcTxPfRCYCj4gqvdOsreAV(trGHpOAfLROEcf3kc5cuMmuPQi0B5YwHIafgcYiAwrJfl(zXAwzoQd3aEAWuE3GKAGoWU1RzPb853auyiiJOzfnwSm4lwZkZrD4gWtdMY7gKud0b2TEnlkIq71FkcShlgEZfLROMckUveYfOmzOsvrO3YLTcfbkmeKr0SIglwg8fRzL5OoCd4Pb6a7wVMLgWNFdqHHGmIMv0yXIFwSMXZ5AqIgGFwSwrZkAS0aEAaVBaF(nafgcYiAwrJfl(zXAgpNRbjAad(I1kAwrJLgGWni0E9NHZgEMPoleRYZ8gqYgmvreAV(trG9yHQvuUIAUQ4wrixGYKHkvfHElx2kueOWqqgrZkASyXplwZkZrD4gWtd0b2TEnlnGp)gGcdbzenROXILbFXAgpNRbjAad(I1kAwrJLgGWni0E9NHZgEMPoleRYZ8gWtd4TIi0E9NIGZgEMYvUIalomTIBf1tvCRiKlqzYqLQIqVLlBfkc9NwU4CZj69z)oAqIgGPfgZ6XMlo24zBGZS6WBajBaxBqIgO)z03s)154gqYgGGgKObuSbEPrSU8gKObuSbOWqqguSToTbMwreAV(trWGVyT1HPRn86pLROEcf3kc5cuMmuPQiG(1Ecj4kQNQicTx)PiO)Nzxb)WRwuUIAkO4wrixGYKHkvfHElx2kueEWKZnqYgml0kxkJKrUaLjJgKOb6)zJNZzGKnywOvUugjdmDds0ak2auyiidosh5ID)ynW0nird0)m6BP)6CCd4PbtBqIgmE3SbIIXlnI1L3GenGYgmE3WGVyT1HPRn86pJxAeRlVb853ak2apyY5gg8fRTomDTHx)zKlqzYObuPicTx)PiWr6ixS7hRYvuZvf3kc5cuMmuPQi0B5YwHIWdMCUbL9)Wd2FyJCbktgnirdqHHGmOS)hEW(dBgpNRbjAaLnqozZrQbj1akyqqdMudKt2CKmRKlxdsQbu2aUY7gmPgGcdbz0mjwDG96YnW0nGQgqvdizdOSbtNIGgGWnyck0Gj1auyiitD6yVWR)SiwxU9HSEMytPWxotmW0nGQgKObH2R0If1T(w55YIBa5gWBfrO96pfb9)m7k4hE1IYvuJaf3kc5cuMmuPQi0B5YwHIWdMCUbL9)Wd2FyJCbktgnirdqHHGmOS)hEW(dBgpNRbjAaLnq)ZOVL(RZXnGKnabnGp)gGPfgZ6XMlo24zBGZS6WBa5gmTbuPicTx)Pi0bJzdTx)zzf2veSc72lMffbk7)HhS)WkxrDkO4wrixGYKHkvfrO96pfHoymBO96plRWUIGvy3EXSOi0)ZgpNt5kQ5ckUveYfOmzOsvrO3YLTcfH(NrFl9xNJBapnGcnirdOSbOWqqgu2)dpy)HnW0nGp)gqXg4bto3GY(F4b7pSrUaLjJgqLIi0E9NIqhmMn0E9NLvyxrWkSBVywueq1v4mzvUYvedbkGzUIBf1tvCRiKlqzYqLQIqVLlBfkcuyiiZ8)hI1zH(D2at3GenGInySW1W8CyCKiTy1HRicTx)Piw4ZgAV(ZYkSRiyf2Txmlkc0GfNwuUI6juCRiKlqzYqLQIqVLlBfkIXcxdZZHXrI0IvhUIi0E9NIqhmMn0E9NLvyxrWkSBVywuephghjslkxrnfuCRiKlqzYqLQIyiy9w0E9NIGe9(CynGtMCsAzBa9JXfktueH2R)ue07ZHPCf1CvXTIqUaLjdvQkc9wUSvOiqHHGm6WTq)oBgpNtreAV(tr4vUSyle8IKYvuJaf3kc5cuMmuPQi0B5YwHIafgcYOd3c97Sz8CofrO96pfHoCl0VZkxrDkO4wrixGYKHkvfXqW6TO96pfrk(KgGZEVbyxcMNPicTx)Piw4ZgAV(ZYkSRi0B5YwHIafgcYGZIXZzwyddmDd4ZVbOWqqg695WmW0kcwHD7fZIIa7sW8mLROMlO4wreAV(trGreMXSObotrixGYKHkvLROMxO4wrixGYKHkvfHElx2kueH2R0ID8Uzl6gqUb8wreAV(trOdgZgAV(ZYkSRiyf2TxmlkcS4W0kxrncPIBfHCbktgQuveH2R)ue6GXSH2R)SSc7kcwHD7fZIIq)pB8CoLROEkVvCRiKlqzYqLQIi0E9NIylAfXqW6TO96pfb1IEF2VJjRbtEG9gqHg8Bd4Ad0)m63a6VoVbBrJBWFnaxxotAGhBU4n4HDCnKg8qnavwSSi2GFBWaERlVbOYILfXguqnas2G1aOvUugPgu4gat3GumcTbbnndPgenabA6gGql6gWjtUgWnxSbfUbW0niUrd4umwdW)FnakySg8qqgfHElx2kue6pTCX5Mt07Z(D0GenGYgqXg4bto3GY(F4b7pSrUaLjJgWNFdqHHGmOS)hEW(dBGPBavnirdW0cJz9yZfhB8SnWzwD4nGCdM2GenGYgO)z03s)154gWtdMObjAWkqRGZcuM0GenySW1WSfTXlnIyBEuNmS)zxbAfCwd4PbPJTcuMy2I26LgrCds0akBafBakmeKbfBRtBGPBaF(nq)pB8Codk2wN2at3a(8BaLnafgcYGIT1PnW0nird0)ZgpNZajBWSqRCPmsgy6gqvdOQb853a9pJ(w6Voh3aYnabnirdqHHGmELll2cbVizGPBqIgGcdbz8kxwSfcErYSYCuhUbKSbCTbjAWyHRHzlAJxAeX28Oozy)ZUc0k4SgWtdqqdOs5kQNovXTIqUaLjdvQkc9wUSvOi0)m6BP)6CCd4HCdOSbiObiCdshBfOmXa9WRM2IwU0aQueH2R)uel8zdTx)zzf2veSc72lMffbuDfotwLROE6ekUveYfOmzOsvrO3YLTcfXyHRHHER5Gz5SHNz8sJi2Mh1jd7F2vGwbN1aEi3Gj4Dds0a9pJ(w6Voh3aEi3GjueH2R)ue0BnhmlNn8mfbRoXQhkceOCf1tPGIBfHCbktgQuvedbR3I2R)uePKWmVq4C9ObyxcMNPicTx)Pi0bJzdTx)zzf2ve6TCzRqrGcdbzqX260gyAfbRWU9IzrrGDjyEMYvupLRkUveYfOmzOsvrmeSElAV(trWDM0G5h7nqibA5WvAPbPYDd0iPzsdOK7SvWznGiBLrdi4u0sd0p2BW0PiObYjBosK2G5arPby4vAahPb64AWCGO0apl8guxd4AdYzpAWWuPiWIwrqzdOSbtNIGgGWnyck0Gj1auyiitD6yVWR)SiwxU9HSEMytPWxotmW0nGQgGWnGYgiNS5iz0W7kN3GKAafmiObtQbYjBosMvYLRbj1akBax5DdMudqHHGmAMeRoWED5gy6gqvdOQbu1GKBGCYMJKzLC5ueH2R)ueCIYve6TCzRqr4bto3GY(F4b7pSrUaLjJgKObOWqqgu2)dpy)HnJNZ1Geni0ELwSOU13kpxwCdi3aERCf1trGIBfHCbktgQuvedbR3I2R)ueH2R)WMHafWmpjYjt)pZUc(HxTqAbr2dMCUbL9)Wd2FyJCbktgjqHHGmOS)hEW(dBgpNlbLYjBosjrbdcMKCYMJKzLC5sIsUY7jHcdbz0mjwDG96YnW0urfjPC6ueGWtqHjHcdbzQth7fE9NfX6YTpK1ZeBkf(YzIbMMQeH2R0If1T(w55YIjZBfrO96pfXcF2q71FwwHDfHElx2kueEWKZnOS)hEW(dBKlqzYObjAakmeKbL9)Wd2FyZ45CkcwHD7fZIIaL9)Wd2FyLROEAkO4wrixGYKHkvfrO96pfbKSVUEySfTCrrO3YLTcfbkmeKjOfsWsVYi8FXw9gPRl3atRi0iPzI1JnxCSI6Pkxr9uUGIBfHCbktgQuveq)ApHeCf1tveH2R)ue0)ZSRGF4vlkxr9uEHIBfHCbktgQuveH2R)ueBGOOi0B5YwHIGYgSc0k4SaLjnGp)gqllUWUCUDgM5fnRKTb80GX7Mnqum0ZWmVOzLSnGQgKObJfUgMnqumEPreBZJ6KH9p7kqRGZAapnatlmM1JnxCSbZPOfRo8gmPgmrdq4gmHIqJKMjwp2CXXkQNQCf1trivCRiKlqzYqLQIi0E9NIGbFXARdtxB41Fkc9wUSvOiOSbRaTcolqzsd4ZVb0YIlSlNBNHzErZkzBapny8UHbFXARdtxB41Fg6zyMx0Ss2gqvds0GXcxddd(I1whMU2WR)mEPreBZJ6KH9p7kqRGZAapnatlmM1JnxCSbZPOfRo8gmPgmrdq4gmHIqJKMjwp2CXXkQNQCf1tWBf3kc5cuMmuPQiG(1Ecj4kQNQicTx)PiO)Nzxb)WRwuUI6jMQ4wrixGYKHkvfrO96pfHNTboZQdxrO3YLTcfXkqRGZcuM0GenySW1W4zBGZS6WnEPreBZJ6KH9p7kqRGZAapnGYgW1gKudW0cJz9yZfhB8SnWzwD4nysnGRnGQgKCdOSbtBqsnyoWUSizthmyPbu1aeUb6)gWLB8a7If6xlk7)HrUaLjJgGWnq)PLlo3CIEF2VJgKObu2ak2auyiidk2wN2at3a(8BaMwymRhBU4yJNTboZQdVb80GPnGkfHgjntSES5IJvupv5kQNycf3kc5cuMmuPQiG(1Ecj4kQNQicTx)PiO)Nzxb)WRwuUI6jOGIBfHCbktgQuve6TCzRqrqzd2OgwjTCUjgdSPUgWtdOSbtBqsnyoibRol2Cb3aeUb6SyZfSfAdTx)fSgqvdMudwrNfBUy9AwAavnirdOSbyAHXSES5IJnOlShmlMf4SgmPgeAV(ZGUWEWSywGZmJyoYLgKCdcTx)zqxypywmlWzg9J9gqvd4Pbu2Gq71FgC2kdZiMJCPbj3Gq71FgC2kdJ(XEdOsreAV(trGUWEWSywGZuUI6j4QIBfHCbktgQuve6TCzRqrGPfgZ6XMlo2G5u0IvhEd4PbtBqsnafgcYGIT1PnW0nysnycfrO96pfbMtrlwD4kxr9eiqXTIqUaLjdvQkc9wUSvOiW0cJz9yZfhB8SnWzwD4nGNgqbfrO96pfHNTboZQdx5kQNifuCRiKlqzYqLQIqVLlBfkcuyiiJMjXQdSxxUbMUbjAaLnafgcYGHhd5SXmkmoZmEoxds0auyiidolgpNzHnmJNZ1a(8BakmeKbfBRtBGPBavkIq71FkcC2kdLROEcUGIBfHCbktgQuveH2R)ueBGOOi0B5YwHIafgcYGIT1PnW0nirdglCnmBGOy8sJi2Mh1jd7F2vGwbN1aEAWekcnsAMy9yZfhROEQYvupbVqXTIqUaLjdvQkIq71FkcDWy2q71FwwHDfbRWU9IzrravmMSkx5kc6v0)mA4kUvupvXTIqUaLjdvQkINwrGfxreAV(trKo2kqzIIiDWGffbVvePJ1EXSOiGE4vtBrlxuUI6juCRiKlqzYqLQI4PveyXveH2R)uePJTcuMOishmyrrmvrmeSElAV(trqKTYObKBaVjTbu)hcJVGgN9EdqObIsdi3GPK2aIlOXzV3aeAGO0aYnycsBqkIeVbKBafiTbeCkAPbKBaxvePJ1EXSOiGkgtwLROMckUveYfOmzOsvr80kcS4kIq71FkI0XwbktuePdgSOi4ckIHG1Br71FkccDWKgWP8SgKfyxmkI0XAVywueBrB9sJiw5kQ5QIBfrO96pfbI1nwzyX01wowrixGYKHkvLROgbkUveH2R)ueOV7mzyHybsYGtD5w)jH6ueYfOmzOsv5kQtbf3kc5cuMmuPQi0B5YwHIa)Wm06ggAySdZeRSW0E9NrUaLjJgWNFdWpmdTUHj9ZcVyIf)S0Y5g5cuMmueH2R)ueqmbNP3aYvUIAUGIBfHCbktgQuve6TCzRqrGcdbzM))qSol0VZMXZ5ueH2R)ue07ZHPCf18cf3kc5cuMmuPQi0B5YwHIafgcYm))HyDwOFNnJNZPicTx)Pi0HBH(Dw5kxravmMSkUvupvXTIqUaLjdvQkIq71FkInquue6TCzRqrKo2kqzIbQymzBa5gmTbjAWkqRGZcuM0Geny8Uzdefd9mmZlAwjBdij5gm1mrdMudOLfxyxo3odZ8IMvYQi0iPzI1JnxCSI6Pkxr9ekUveYfOmzOsvrO3YLTcfr6yRaLjgOIXKTbKBWekIq71FkInquuUIAkO4wrixGYKHkvfHElx2kuePJTcuMyGkgt2gqUbuqreAV(trWGVyT1HPRn86pLROMRkUveYfOmzOsvrO3YLTcfr6yRaLjgOIXKTbKBaxveH2R)ueyofTy1HRCf1iqXTIqUaLjdvQkc9wUSvOiqHHGmy4XqoBmJcJZmJNZPicTx)PiWzRmuUI6uqXTIqUaLjdvQkc9wUSvOiWpmdTUHHgg7WmXklmTx)zKlqzYOb853a8dZqRBys)SWlMyXplTCUrUaLjdfrDUSlmTBlifb(HzO1nmPFw4ftS4NLwoxruNl7ct72AEwgv4IIyQIi0E9NIaIj4m9gqUIOox2fM2T5ShnykIPkx5kcSlbZZuCROEQIBfHCbktgQuveq)ApHeCf1tveH2R)ue0)ZSRGF4vlkxr9ekUveYfOmzOsvreAV(trSbIIIqJKMjwp2CXXkQNQi0B5YwHIGYgmE3SbIIHEgM5fnRKTbKSbtniOb853GvGwbNfOmPbu1GenySW1WSbIIXlnIyBEuNmS)zxbAfCwd4Pbt0a(8BaLnGwwCHD5C7mmZlAwjBd4PbJ3nBGOyONHzErZkzBqIgGcdbzqX260gy6gKObyAHXSES5IJnE2g4mRo8gqYgqHgKOb6pTCX5Mt07Z(D0aQAaF(nafgcYGIT1PnRmh1HBajBWufXqW6TO96pfbcnquAWjYa3G9HZZyi1aeWBsSg8qnOCCdyYL7zni8genyUUAgEUb(3am8shyCdWzRmWnyqlkxrnfuCRiKlqzYqLQIqVLlBfkcmTWywp2CXXgpBdCMvhEdizdOqds0GvGwbNfOmPbjAWyHRHHbFXARdtxB41FgV0iIT5rDYW(NDfOvWznGNgGGgKObu2a9pJ(w6Voh3aYnGRnGp)gmE3WGVyT1HPRn86pZkZrD4gqYgGGgWNFdOydgVByWxS26W01gE9NXlnI1L3aQueH2R)uem4lwBDy6AdV(t5kQ5QIBfHCbktgQuveH2R)ueOlShmlMf4mfXqW6TO96pfrQlShSgqWcCwdkCdqf3LTbEwCna7sW8SgqKTYObH3ak0ap2CXXkc9wUSvOiW0cJz9yZfhBqxypywmlWznGNgmHYvuJaf3kc5cuMmuPQiG(1Ecj4kQNQicTx)PiO)Nzxb)WRwuUI6uqXTIqUaLjdvQkc9wUSvOi0)m6BP)6CCdizd4Ads0amTWywp2CXXgpBdCMvhEdizdqGIi0E9NIaNTYq5kxrO)NnEoNIBf1tvCRiKlqzYqLQIi0E9NIigbTxPflMtSZkc9wUSvOiOSbu2ak2GX7Mye0ELwSyoXoBhXCKlgV0iwxEd4ZVbJ3nXiO9kTyXCID2oI5ixmRmh1HBajBWenGQgKObu2GX7Mye0ELwSyoXoBhXCKlgShAeBajBafAaF(nGIny8UjgbTxPflMtSZ2mjygShAeBapnyAdOQbjAafBqO96ptmcAVslwmNyNTzsWm1zHyvEM3GenGIni0E9NjgbTxPflMtSZ2rmh5IPoleRYZ8gKObuSbH2R)mXiO9kTyXCID2uNfIv5zEdOQbjAGhBU4gVMfR)2rjnGNgGGgWNFdcTxPfRCYCj4gWtdMObjAafBW4DtmcAVslwmNyNTJyoYfJxAeRlVbjAGCYMJudizdOacAqIg4XMlUXRzX6VDusd4PbiqrOrsZeRhBU4yf1tvUI6juCRiKlqzYqLQIqVLlBfkckBa(HzO1nm0WyhMjwzHP96pJCbktgnGp)gGFygADdt6NfEXel(zPLZnYfOmz0aQue15YUW0UTGue4hMHw3WK(zHxmXIFwA5CfrDUSlmTBR5zzuHlkIPkIq71FkciMGZ0Ba5kI6CzxyA3MZE0GPiMQCf1uqXTIqUaLjdvQkIHG1Br71FkIjpWEd4UYLLxXnGlcVi1aub6xPbu(BdQ5zzuHZqQbbKllvnqhyVU8gWfLnynGlUYLYi1GcQbPklwweBqHBa1PyUBWFnq)pB8CoJIaJ0PveqYgml0kxkJKIqVLlBfkc9)SXZ5mOyBDAdmTIi0E9NIWRCzXwi4fjLROMRkUveYfOmzOsvreAV(trajBWSqRCPmskc9wUSvOi0)m6BP)6CCdizdOqds0ap2CXnEnlw)TJsAapnGl0GenGYgGcdbzWr6ixS7hRbMUb853ak2apyY5gCKoYf7(XAKlqzYObu1GenGYgqXgO)NnEoNXRCzXwi4fjdmDd4ZVb6)zJNZzqX260gy6gqvd4ZVbqvEMBxzoQd3as2aErds0aOkpZTRmh1HBapnycfHgjntSES5IJvupv5kQrGIBfHCbktgQuveH2R)ueOYILfrfXqW6TO96pfb3PyEPu8K1aQfz0a)BagPt3aoLN1aoLN1Gnsl3dJBa0kxkJud4Kjxd4inyHVgaTYLYiHg3G0g8BdcNjb2BGot0i2GcQbLJBaNF9SguUIqVLlBfkc9pJ(w6Voh3aEi3akOCf1PGIBfHCbktgQuve6TCzRqrO)z03s)154gWd5gqbfrO96pfrD6yVWR)uUIAUGIBfHCbktgQuveH2R)ueELll2cbViPigcwVfTx)Pi4ErQbXnAW9Ed4eyxAa3CXgiNS5irAdqH9gem83Gukm2BamwAq5na63gKYYIydIB0G60XEyfHElx2kueYjBosMHav6YBapnGR8Ub853auyiidk2wN2at3a(8BaLnWdMCUHELr4)AKlqzYObjAao7xxWU19rdizdOqdOs5kQ5fkUveYfOmzOsvreAV(trGZIXZzwydfXqW6TO96pfrkzLN5navAaN9V8g4FdGXsdiMf2Ob)1aeAGO0G6AqAzrQbPLfPgCLotAaUC4WR)WK2auyVbPLfPgSXkmKue6TCzRqrGcdbz8kxwSfcErYat3GenafgcYGIT1PnJNZ1Genq)ZOVL(RZXnGKnGRnirdqHHGmy4XqoBmJcJZmJNZ1Geny8Uzdefd9mmZlAwjBdizdMAsHgKObYjBosnGNgWvE3GenySW1WSbIIXlnIyBEuNmS)zxbAfCwd4PbyAHXSES5IJnyofTy1H3Gj1GjAac3GjAqIg4XMlUXRzX6VDusd4Pbiq5kQrivCRiKlqzYqLQIqVLlBfkcuyiiJx5YITqWlsgy6gWNFdqHHGmOyBDAdmTIi0E9NIavwSSiwxUYvupL3kUveYfOmzOsvrO3YLTcfbkmeKbfBRtBGPBaF(na9X4gKObqvEMBxzoQd3as2a9)SXZ5mOyBDAZkZrD4gWNFdqFmUbjAauLN52vMJ6WnGKnyceOicTx)PiOFV(t5kQNovXTIqUaLjdvQkc9wUSvOiqHHGmOyBDAdmDd4ZVbqvEMBxzoQd3as2GjMQicTx)Pi2iTCpm2cTYLYiPCf1tNqXTIqUaLjdvQkIq71Fkc9FPFefRNjwmDTLJvedbR3I2R)ueCNI5LsXtwdM8mrJydM))qSUgK9oNge3ObyhgcQbScrPbEwHjTbXnAWCGeQ0auXDzBG(NrdVbRmh11GvWiDAfHElx2kueu2akBW4DZw0MvMJ6WnGNgW1gWNFdGQ8m3UYCuhUbKSbPJTcuMy2I26LgrCds0GX7MTOnEPr061S0aQAqIgO)z03s)154gqYgGGgKObu2GX7MnqumEPrSU8gWNFdW0cJz9yZfhB8SnWzwD4nGNgmTbu1GenqozZrYmeOsxEd4HCdMG3nGQgWNFdqFmUbjAauLN52vMJ6WnGKnabkxr9ukO4wrixGYKHkvfrO96pfHmt)CK1I(3qrmeSElAV(trKsgiHknWZKvAao7HzJgGkny(xPb6)gLx)HBWFnWZKgO)BaxUIqVLlBfkcuyiiJx5YITqWlsgy6gWNFdOSb6)gWLBgIqBdgtYR40IrUaLjJgqLYvupLRkUveYfOmzOsvrmeSElAV(trWlxPLgqV1VLJud8Vb)HWWyPbCKG(pfXfZIIiL(o8Ll1U2HG96qcB1bJPi0B5YwHIqsjGlAAzysPVdF5sTRDiyVoKWwDWykIq71FkIu67WxUu7Ahc2RdjSvhmMYvupfbkUveH2R)ueWyXwUmJveYfOmzOsv5kxr8CyCKiTO4wr9uf3kc5cuMmuPQi0B5YwHIafgcYKjX62hY6zILtXggyAfrO96pfb2JfdV5IYvupHIBfHCbktgQuveH2R)uey4dQwrrWQtS6HIGRtkxpuUIAkO4wrixGYKHkvfrO96pfX8)huTIIqVLlBfkcuyiiZ8)hI1zH(D2at3GenatlmM1JnxCSXZ2aNz1H3as2GjAqIgqXg4bto3WGVyT1HPRn86pJCbktgkcwDIvpueCDs56HYvuZvf3kc5cuMmuPQi0B5YwHIqozZrQbKSbuG3nirdgVB2I2SYCuhUb80aUAqqds0akBG(F245CgVYLfBHGxKmRmh1HBapKBqkyqqd4ZVbl8jq)MlgD4csIvdV1BKlqzYObu1GenafgcYOzsS6a71LBWEOrSbKSbtBqIgqXgGcdbzcAHeS0Rmc)xSvVr66YnW0nirdOydqHHGmOS)hmySBGPBqIgqXgGcdbzqX260gy6gKObu2a9)SXZ5m6)s)ikwptSy6AlhBwzoQd3aEAqkyqqd4ZVbuSb6pTCX5MRYZCluinGQgKObu2ak2a9NwU4CZj69z)oAaF(nq)pB8CotmcAVslwmNyNnRmh1HBapKBacAaF(ny8UjgbTxPflMtSZ2rmh5IzL5OoCd4PbCHgqLIi0E9NIitI1TpK1ZelNInuUIAeO4wrixGYKHkvfHElx2kueYjBosnGKnGc8UbjAW4DZw0MvMJ6WnGNgWvdcAqIgqzd0)ZgpNZ4vUSyle8IKzL5OoCd4HCd4QbbnGp)gSWNa9BUy0Hlijwn8wVrUaLjJgqvds0auyiiJMjXQdSxxUb7HgXgqYgmTbjAafBakmeKjOfsWsVYi8FXw9gPRl3at3GenGInafgcYGY(FWGXUbMUbjAaLnGInafgcYGIT1PnW0nGp)gO)0YfNBorVp73rds0apyY5gCKoYf7(XAKlqzYObjAakmeKbfBRtBwzoQd3aEAqk0aQAqIgqzd0)ZgpNZO)l9JOy9mXIPRTCSzL5OoCd4PbPGbbnGp)gqXgO)0YfNBUkpZTqH0aQAqIgqzdOyd0FA5IZnNO3N97Ob853a9)SXZ5mXiO9kTyXCID2SYCuhUb8qUbiOb853GX7Mye0ELwSyoXoBhXCKlMvMJ6WnGNgWfAavnirdGQ8m3UYCuhUb80aUGIi0E9NIy()dX6Sq)oRCLRCfrAzX1FkQNG3tmL38cEpvrWj2RUCSIGefcbcLAsCQ5LNSg0aUZKguZ0)6na63gWRq1v4mz51gSskbCTYOb4FwAqa7)C4YOb6S4YfSProfvN0aUoznyY)lTSUmAaVUWNa9BUyir41g4Fd41f(eOFZfdjIrUaLjdETbuoLeOY0i3itIcHaHsnjo18YtwdAa3zsdQz6F9ga9Bd41HafWmNxBWkPeW1kJgG)zPbbS)ZHlJgOZIlxWMg5uuDsdMy6K1Gj)V0Y6YObe18K3amsNhKqdiXAG)nifbhnyuPlC9xdEAzd)3gqzYu1akNscuzAKtr1jnyckmznyY)lTSUmAarnp5naJ05bj0asSg4FdsrWrdgv6cx)1GNw2W)TbuMmvnGYjibQmnYnYKOqiqOutItnV8K1GgWDM0GAM(xVbq)2aEfL9)Wd2FyETbRKsaxRmAa(NLgeW(phUmAGolUCbBAKtr1jnGctwdM8)slRlJgquZtEdWiDEqcnGeRb(3GueC0GrLUW1Fn4PLn8FBaLjtvdOCkjqLPrUrMefcbcLAsCQ5LNSg0aUZKguZ0)6na63gWR6)zJNZXRnyLuc4ALrdW)S0Ga2)5WLrd0zXLlytJCkQoPbtmznyY)lTSUmAaVIFygADddjcV2a)BaVIFygADddjIrUaLjdETbuobjqLPrUrMefcbcLAsCQ5LNSg0aUZKguZ0)6na63gWRphghjsl8AdwjLaUwz0a8plniG9FoCz0aDwC5c20iNIQtAaxNSgm5)LwwxgnGxx4tG(nxmKi8Ad8Vb86cFc0V5IHeXixGYKbV2akNscuzAKtr1jnabtwdM8)slRlJgWRl8jq)MlgseETb(3aEDHpb63CXqIyKlqzYGxBaLtjbQmnYnYK4Z0)6YObt5DdcTx)1awHDSPrwrGPfTI6P8Mckc69HkMOi4sUSbCrzdwd4Lw4A0iZLCzdqiGZHXEdMGcK2Gj49etBKBK5sUSbCrzdwdqiirNIAGoUgem83auPbqp8nAq4niZDA8KLCY5f2n5LNbJA0)CYKiXLYXgjNc8ceYuqZlqiritbieeqAbbAz6uemIGcbV5fJacQrUrMl5Ygm5zXLl4jRrMl5YgGWnySW1W8CyCKiTy1HtEAd0zIgrCd8VbJfUgMNdJJePfRoCtJmxYLnaHBWK)xAz9gKk3nG(FMDf8dVAPb(3aor5nqib6vW46ptJmxYLnaHBacXy0G6CzxyAVqzsd4ImbNP3aYBqb1aKE4gKfPLgCVNvxEdegwAG)ny8MgzUKlBac3aEP)4vVbzpB0Gj)V0pIsdG(Tbi0IUbWhtW4gG0dZRmwdwjymKAacTOnnYnYH2R)Wg6v0)mA4jro50Xwbkti9IzHm0dVAAlA5cPPdgSqM3nYCzdiYwz0aYnG3K2aQ)dHXxqJZEVbi0arPbKBWusBaXf04S3BacnquAa5gmbPnifrI3aYnGcK2acofT0aYnGRnYH2R)Wg6v0)mA4jro50Xwbkti9IzHmuXyYsA6GblKN2iZLnGqhmPbCkpRbzb2ftJCO96pSHEf9pJgEsKtoDSvGYesVywiVfT1lnIysthmyHmxOro0E9h2qVI(NrdpjYjJyDJvgwmDTLJBKdTx)Hn0RO)z0WtICYOV7mzyHybsYGtD5w)jH6AKdTx)Hn0RO)z0WtICYqmbNP3aYjTGiJFygADddnm2HzIvwyAV(ZixGYKbF(4hMHw3WK(zHxmXIFwA5CJCbktgnYH2R)Wg6v0)mA4jroz695WiTGiJcdbzM))qSol0VZMXZ5AKdTx)Hn0RO)z0WtICY6WTq)otAbrgfgcYm))HyDwOFNnJNZ1i3ihAV(dtEHpBO96plRWoPxmlKrdwCAH0cImkmeKz()dX6Sq)oBGPtqXXcxdZZHXrI0IvhEJCO96pCsKtwhmMn0E9NLvyN0lMfYphghjslKwqKhlCnmphghjslwD4nYCzdirVphwd4KjNKw2gq)yCHYKg5q71F4KiNm9(CynYH2R)WjrozVYLfBHGxKiTGiJcdbz0HBH(D2mEoxJCO96pCsKtwhUf63zsliYOWqqgD4wOFNnJNZ1iZLnifFsdWzV3aSlbZZAKdTx)HtICYl8zdTx)zzf2j9IzHm2LG5zKwqKrHHGm4Sy8CMf2WatZNpkmeKHEFomdmDJCO96pCsKtgJimJzrdCwJCO96pCsKtwhmMn0E9NLvyN0lMfYyXHPjTGihAVsl2X7MTOjZ7g5q71F4KiNSoymBO96plRWoPxmlK1)ZgpNRrMlBa1IEF2VJjRbtEG9gqHg8Bd4Ad0)m63a6VoVbBrJBWFnaxxotAGhBU4n4HDCnKg8qnavwSSi2GFBWaERlVbOYILfXguqnas2G1aOvUugPgu4gat3GumcTbbnndPgenabA6gGql6gWjtUgWnxSbfUbW0niUrd4umwdW)FnakySg8qqMg5q71F4KiN8w0KwqK1FA5IZnNO3N97ibLu0dMCUbL9)Wd2FyJCbktg85Jcdbzqz)p8G9h2attvcmTWywp2CXXgpBdCMvho5PjOu)ZOVL(RZX8mrIvGwbNfOmjXyHRHzlAJxAeX28Oozy)ZUc0k4mEshBfOmXSfT1lnI4eusruyiidk2wN2atZNV(F245CguSToTbMMpFkrHHGmOyBDAdmDc9)SXZ5mqYgml0kxkJKbMMkQ4Zx)ZOVL(RZXKrqcuyiiJx5YITqWlsgy6eOWqqgVYLfBHGxKmRmh1Hjjxtmw4Ay2I24LgrSnpQtg2)SRaTcoJheqvJCO96pCsKtEHpBO96plRWoPxmlKHQRWzYsAbrw)ZOVL(RZX8qMseGWPJTcuMyGE4vtBrlxOQro0E9hojYjtV1CWSC2WZiTGipw4AyO3AoywoB4zgV0iIT5rDYW(NDfOvWz8qEcENq)ZOVL(RZX8qEcsz1jw9GmcAK5YgKscZ8cHZ1JgGDjyEwJCO96pCsKtwhmMn0E9NLvyN0lMfYyxcMNrAbrgfgcYGIT1PnW0nYCzd4otAW8J9giKaTC4kT0Gu5UbAK0mPbuYD2k4SgqKTYObeCkAPb6h7ny6ue0a5KnhjsBWCGO0am8knGJ0aDCnyoquAGNfEdQRbCTb5ShnyyQAKdTx)HtICYCIYjflAYus50PiaHNGctcfgcYuNo2l86plI1LBFiRNj2uk8LZedmnvimLYjBosgn8UY5jrbdcMKCYMJKzLC5sIsUY7jHcdbz0mjwDG96YnW0urfvjlNS5izwjxosliYEWKZnOS)hEW(dBKlqzYibkmeKbL9)Wd2FyZ45CjcTxPflQB9TYZLftM3nYCzdcTx)HtICY0)ZSRGF4vlKwqK9GjNBqz)p8G9h2ixGYKrcuyiidk7)HhS)WMXZ5sqPCYMJusuWGGjjNS5izwjxUKOKR8EsOWqqgntIvhyVUCdmnvurskNofbi8euysOWqqM60XEHx)zrSUC7dz9mXMsHVCMyGPPkrO9kTyrDRVvEUSyY8Uro0E9hojYjVWNn0E9NLvyN0lMfYOS)hEW(dtAbr2dMCUbL9)Wd2FyJCbktgjqHHGmOS)hEW(dBgpNRro0E9hojYjdj7RRhgBrlxivJKMjwp2CXXKNsAbrgfgcYe0cjyPxze(VyREJ01LBGPBKdTx)HtICY0)ZSRGF4vlKc9R9esWjpTro0E9hojYjVbIcPAK0mX6XMloM8usliYuUc0k4SaLj85tllUWUCUDgM5fnRKLNX7Mnqum0ZWmVOzLSuLySW1WSbIIXlnIyBEuNmS)zxbAfCgpyAHXSES5IJnyofTy1HpPjq4jAKdTx)HtICYm4lwBDy6AdV(JunsAMy9yZfhtEkPfezkxbAfCwGYe(8PLfxyxo3odZ8IMvYYZ4Ddd(I1whMU2WR)m0ZWmVOzLSuLySW1WWGVyT1HPRn86pJxAeX28Oozy)ZUc0k4mEW0cJz9yZfhBWCkAXQdFstGWt0ihAV(dNe5KP)Nzxb)WRwif6x7jKGtEAJCO96pCsKt2Z2aNz1HtQgjntSES5IJjpL0cI8kqRGZcuMKySW1W4zBGZS6WnEPreBZJ6KH9p7kqRGZ4HsUMeMwymRhBU4yJNTboZQdFsCLksmkNM0CGDzrYMoyWcviS(VbC5gpWUyH(1IY(FyKlqzYaH1FA5IZnNO3N97ibLuefgcYGIT1PnW085JPfgZ6XMlo24zBGZS6W5zkvnYH2R)Wjroz6)z2vWp8QfsH(1Ecj4KN2ihAV(dNe5KrxypywmlWzKwqKPCJAyL0Y5MymWM64HYPjnhKGvNfBUGryDwS5c2cTH2R)cgvtAfDwS5I1RzHQeuIPfgZ6XMlo2GUWEWSywGZMuO96pd6c7bZIzboZmI5ixiXcTx)zqxypywmlWzg9JDQ4HYq71FgC2kdZiMJCHel0E9NbNTYWOFStvJCO96pCsKtgZPOfRoCsliYyAHXSES5IJnyofTy1HZZ0KqHHGmOyBDAdm9KMOro0E9hojYj7zBGZS6WjTGiJPfgZ6XMlo24zBGZS6W5HcnYH2R)WjrozC2kdsliYOWqqgntIvhyVUCdmDckrHHGmy4XqoBmJcJZmJNZLafgcYGZIXZzwydZ45C85JcdbzqX260gyAQAKdTx)HtICYBGOqQgjntSES5IJjpL0cImkmeKbfBRtBGPtmw4Ay2arX4LgrSnpQtg2)SRaTcoJNjAKdTx)HtICY6GXSH2R)SSc7KEXSqgQymzBKBKdTx)HnOS)hEW(dtEdefs1iPzI1JnxCm5PKwqKPKIEPrSUC(8PCQzIjrllUWUCUDgM5fnRKLhYJ3nBGOyONHzErZkzPIpFkdTxPflQB9TYZLftEIeRaTcolqzcvuLafgcYG62nqumJNZ1ihAV(dBqz)p8G9hojYjZGVyT1HPRn86ps1iPzI1JnxCm5PKwqKxbAfCwGYKeOWqqgu3o))bvRygpNRro0E9h2GY(F4b7pCsKt2Z2aNz1HtQgjntSES5IJjpL0cI8kqRGZcuMKafgcYG6wpBdCMz8CUeJfUggpBdCMvhUXlnIyBEuNmS)zxbAfCgpuY1KW0cJz9yZfhB8SnWzwD4tIRurIr50KMdSlls20bdwOcH1)nGl34b2fl0Vwu2)dJCbktgnYH2R)Wgu2)dpy)HtICYOlShmlMf4msliYOWqqgu3IUWEWSywGZmJNZ1ihAV(dBqz)p8G9hojYjJ5u0IvhoPfezuyiidQBXCkAXmEoxcmTWywp2CXXgmNIwS6W5zAJCO96pSbL9)Wd2F4KiNmoBLbPfezuyiidQBXzRmmJNZ1ihAV(dBqz)p8G9hojYjJ5u0IvhoPfezuyiidQBXCkAXmEoxJCO96pSbL9)Wd2F4KiNSNTboZQdN0cImkmeKb1TE2g4mZ45CnYnYH2R)Wg9)SXZ5ihJG2R0IfZj2zs1iPzI1JnxCm5PKwqKPKskoE3eJG2R0IfZj2z7iMJCX4LgX6Y5ZF8UjgbTxPflMtSZ2rmh5IzL5OomjNGQeuoE3eJG2R0IfZj2z7iMJCXG9qJijPaF(uC8UjgbTxPflMtSZ2mjygShAe5zkvjOyO96ptmcAVslwmNyNTzsWm1zHyvEMNGIH2R)mXiO9kTyXCID2oI5ixm1zHyvEMNGIH2R)mXiO9kTyXCID2uNfIv5zovj8yZf341Sy93okHheWNFO9kTyLtMlbZZejO44DtmcAVslwmNyNTJyoYfJxAeRlpHCYMJejPacs4XMlUXRzX6VDucpiOro0E9h2O)NnEoxsKtgIj4m9gqoPfezkXpmdTUHHgg7WmXklmTx)XNp(HzO1nmPFw4ftS4NLwoNksRZLDHPDBnplJkCH8usRZLDHPDBo7rdg5PKwNl7ct72cIm(HzO1nmPFw4ftS4NLwoVrMlBWKhyVbCx5YYR4gWfHxKAaQa9R0ak)Tb18SmQWzi1GaYLLQgOdSxxEd4IYgSgWfx5szKAqb1GuLfllInOWnG6um3n4VgO)NnEoNPro0E9h2O)NnEoxsKt2RCzXwi4fjsXiDAYqYgml0kxkJePfez9)SXZ5mOyBDAdmDJCO96pSr)pB8CUKiNmKSbZcTYLYirQgjntSES5IJjpL0cIS(NrFl9xNJjjfs4XMlUXRzX6VDucpCHeuIcdbzWr6ixS7hRbMMpFk6bto3GJ0rUy3pwJCbktguLGskQ)NnEoNXRCzXwi4fjdmnF(6)zJNZzqX260gyAQ4ZhQYZC7kZrDysYlsav5zUDL5Oompt0iZLnG7umVukEYAa1ImAG)naJ0PBaNYZAaNYZAWgPL7HXnaALlLrQbCYKRbCKgSWxdGw5szKqJBqAd(TbHZKa7nqNjAeBqb1GYXnGZVEwdkVro0E9h2O)NnEoxsKtgvwSSisAbrw)ZOVL(RZX8qMcnYH2R)Wg9)SXZ5sICY1PJ9cV(J0cIS(NrFl9xNJ5HmfAK5YgW9IudIB0G79gWjWU0aU5InqozZrI0gGc7niy4VbPuyS3ayS0GYBa0VniLLfXge3Ob1PJ9WnYH2R)Wg9)SXZ5sICYELll2cbVirAbrwozZrYmeOsxopCL385JcdbzqX260gyA(8P0dMCUHELr4)AKlqzYibo7xxWU19bjPavnYCzdsjR8mVbOsd4S)L3a)BamwAaXSWgn4VgGqdeLguxdsllsniTSi1GR0zsdWLdhE9hM0gGc7niTSi1GnwHHuJCO96pSr)pB8CUKiNmolgpNzHniTGiJcdbz8kxwSfcErYatNafgcYGIT1PnJNZLq)ZOVL(RZXKKRjqHHGmy4XqoBmJcJZmJNZLy8Uzdefd9mmZlAwjljNAsHeYjBos8WvENySW1WSbIIXlnIyBEuNmS)zxbAfCgpyAHXSES5IJnyofTy1HpPjq4js4XMlUXRzX6VDucpiOro0E9h2O)NnEoxsKtgvwSSiwxoPfezuyiiJx5YITqWlsgyA(8rHHGmOyBDAdmDJCO96pSr)pB8CUKiNm971FKwqKrHHGmOyBDAdmnF(OpgNaQYZC7kZrDysQ)NnEoNbfBRtBwzoQdZNp6JXjGQ8m3UYCuhMKtGGg5q71FyJ(F245Cjro5nsl3dJTqRCPmsKwqKrHHGmOyBDAdmnF(qvEMBxzoQdtYjM2iZLnG7umVukEYAWKNjAeBW8)hI11GS350G4gna7WqqnGviknWZkmPniUrdMdKqLgGkUlBd0)mA4nyL5OUgScgPt3ihAV(dB0)ZgpNljYjR)l9JOy9mXIPRTCmPfezkPC8UzlAZkZrDyE4kF(qvEMBxzoQdtY0XwbktmBrB9sJioX4DZw0gV0iA9AwOkH(NrFl9xNJjjcsq54DZgikgV0iwxoF(yAHXSES5IJnE2g4mRoCEMsvc5KnhjZqGkD58qEcEtfF(OpgNaQYZC7kZrDysIGgzUSbPKbsOsd8mzLgGZEy2ObOsdM)vAG(Vr51F4g8xd8mPb6)gWL3ihAV(dB0)ZgpNljYjlZ0phzTO)niTGiJcdbz8kxwSfcErYatZNpL6)gWLBgIqBdgtYR40IrUaLjdQAK5YgWlxPLgqV1VLJud8Vb)HWWyPbCKG(Vg5q71FyJ(F245CjrozySylxMj9IzHCk9D4lxQDTdb71He2QdgJ0cISKsax00YWKsFh(YLAx7qWEDiHT6GXAKdTx)Hn6)zJNZLe5KHXITCzg3i3ihAV(dBGkgtwYBGOqQgjntSES5IJjpL0cIC6yRaLjgOIXKL80eRaTcolqzsIX7Mnqum0ZWmVOzLSKK8uZetIwwCHD5C7mmZlAwjBJCO96pSbQymztICYBGOqAbroDSvGYeduXyYsEIg5q71FyduXyYMe5KzWxS26W01gE9hPfe50XwbktmqfJjlzk0ihAV(dBGkgt2KiNmMtrlKwqKthBfOmXavmMSK5AJCO96pSbQymztICY4SvgKwqKrHHGmy4XqoBmJcJZmJNZ1ihAV(dBGkgt2KiNmetWz6nGCsliY4hMHw3WqdJDyMyLfM2R)mYfOmzWNp(HzO1nmPFw4ftS4NLwo3ixGYKbP15YUW0UTMNLrfUqEkP15YUW0UnN9ObJ8usRZLDHPDBbrg)Wm06gM0pl8Ijw8ZslN3i3ihAV(dBGQRWzYsM(FMDf8dVAHuOFTNqco5PnYH2R)WgO6kCMSjrozCKoYf7(XsAbrgfgcYGJ0rUy3pwZkZrDyssHg5q71FyduDfot2KiNm9wZbZYzdpJ0cImLJfUgg6TMdMLZgEMXlnIyBEuNmS)zxbAfCgpuysuIPfgZ6XMlo2qV1CWSC2WZsAkvjW0cJz9yZfhBO3AoywoB4z8mLk(8X0cJz9yZfhBO3AoywoB4z8qjfsA6K8GjNBWbQS()EMrUaLjdQAKdTx)Hnq1v4mztICYBrtQgjntSES5IJjpL0cI8kqRGZcuMKySW1WSfTXlnIyBEuNmS)zxbAfCgpPJTcuMy2I26LgrCckPefgcY4vUSyle8IKbMMpFk6LgX6YPkbLOWqqgu2)dpy)HnW085trpyY5gu2)dpy)HnYfOmzqfF(u0dMCUbhOY6)7zg5cuMmOkbLyAHXSES5IJn0BnhmlNn8mYt5ZNIEWKZn0BnhmlNn8mJCbktguLGYq7vAXoE3SfnzEZNVxAeRlprO9kTyhVB2IM8u(8P4cFc0V5IzSbCEMBFi7qeAl0RHX85trpyY5gCGkR)VNzKlqzYGQg5q71FyduDfot2KiNmosh5ID)yjTGiJcdbzWr6ixS7hRzL5OomjPu)ZOVL(RZXjnLQjLctI3gk0ihAV(dBGQRWzYMe5KHK911dJTOLlKohKGvozZrI8us1iPzI1JnxCm5PnYH2R)WgO6kCMSjrozizFD9WylA5cPAK0mX6XMloM8usliYOWqqguSToTbMoHhm5Cd(Hz2hY6zIf6xb7g5cuMm4Zx)pB8CoJ(V0pII1ZelMU2YXMvMJ6WKCAc9NwU4CZv5zUfkKg5g5q71FyZZHXrI0czShlgEZfsliYOWqqMmjw3(qwptSCk2Wat3ihAV(dBEomosKwsICYy4dQwHuwDIvpiZ1jLRhnYH2R)WMNdJJePLKiN88)huTcPS6eREqMRtkxpiTGiJcdbzM))qSol0VZgy6eyAHXSES5IJnE2g4mRoCsorck6bto3WGVyT1HPRn86pJCbktgnYH2R)WMNdJJePLKiNCMeRBFiRNjwofBqAbrwozZrIKuG3jgVB2I2SYCuhMhUAqqck1)ZgpNZ4vUSyle8IKzL5OompKtbdc4ZFHpb63CXOdxqsSA4TEQsGcdbz0mjwDG96Ynyp0isYPjOikmeKjOfsWsVYi8FXw9gPRl3atNGIOWqqgu2)dgm2nW0jOikmeKbfBRtBGPtqP(F245Cg9FPFefRNjwmDTLJnRmh1H5jfmiGpFkQ)0YfNBUkpZTqHqvckPO(tlxCU5e9(SFh85R)NnEoNjgbTxPflMtSZMvMJ6W8qgb85pE3eJG2R0IfZj2z7iMJCXSYCuhMhUavnYH2R)WMNdJJePLKiN88)hI1zH(DM0cISCYMJejPaVtmE3SfTzL5OompC1GGeuQ)NnEoNXRCzXwi4fjZkZrDyEiZvdc4ZFHpb63CXOdxqsSA4TEQsGcdbz0mjwDG96Ynyp0isYPjOikmeKjOfsWsVYi8FXw9gPRl3atNGIOWqqgu2)dgm2nW0jOKIOWqqguSToTbMMpF9NwU4CZj69z)os4bto3GJ0rUy3pwJCbktgjqHHGmOyBDAZkZrDyEsbQsqP(F245Cg9FPFefRNjwmDTLJnRmh1H5jfmiGpFkQ)0YfNBUkpZTqHqvckPO(tlxCU5e9(SFh85R)NnEoNjgbTxPflMtSZMvMJ6W8qgb85pE3eJG2R0IfZj2z7iMJCXSYCuhMhUavjGQ8m3UYCuhMhUqJCJCO96pSblomnzg8fRTomDTHx)rAbrw)PLlo3CIEF2VJeyAHXSES5IJnE2g4mRoCsY1e6Fg9T0FDoMKiibf9sJyD5jOikmeKbfBRtBGPBKdTx)HnyXHPtICY0)ZSRGF4vlKc9R9esWjpTro0E9h2GfhMojYjJJ0rUy3pwsliYEWKZnqYgml0kxkJKrUaLjJe6)zJNZzGKnywOvUugjdmDckIcdbzWr6ixS7hRbMoH(NrFl9xNJ5zAIX7MnqumEPrSU8euoE3WGVyT1HPRn86pJxAeRlNpFk6bto3WGVyT1HPRn86pJCbktgu1ihAV(dBWIdtNe5KP)Nzxb)WRwiTGi7bto3GY(F4b7pSrUaLjJeOWqqgu2)dpy)HnJNZLGs5KnhPKOGbbtsozZrYSsUCjrjx59KqHHGmAMeRoWED5gyAQOIKuoDkcq4jOWKqHHGm1PJ9cV(ZIyD52hY6zInLcF5mXattvIq7vAXI6wFR8CzXK5DJCO96pSblomDsKtwhmMn0E9NLvyN0lMfYOS)hEW(dtAbr2dMCUbL9)Wd2FyJCbktgjqHHGmOS)hEW(dBgpNlbL6Fg9T0FDoMKiGpFmTWywp2CXXgpBdCMvho5Pu1ihAV(dBWIdtNe5K1bJzdTx)zzf2j9IzHS(F245CnYH2R)WgS4W0jrozDWy2q71FwwHDsVywidvxHZKL0cIS(NrFl9xNJ5HcjOefgcYGY(F4b7pSbMMpFk6bto3GY(F4b7pSrUaLjdQAKBKdTx)HnyxcMNrM(FMDf8dVAHuOFTNqco5PnYCzdqObIsdorg4gSpCEgdPgGaEtI1GhQbLJBatUCpRbH3GObZ1vZWZnW)gGHx6aJBaoBLbUbdAPro0E9h2GDjyEwsKtEdefs1iPzI1JnxCm5PKwqKPC8Uzdefd9mmZlAwjljNAqaF(RaTcolqzcvjglCnmBGOy8sJi2Mh1jd7F2vGwbNXZe85tjTS4c7Y52zyMx0SswEgVB2arXqpdZ8IMvYMafgcYGIT1PnW0jW0cJz9yZfhB8SnWzwD4KKcj0FA5IZnNO3N97Gk(8rHHGmOyBDAZkZrDysoTro0E9h2GDjyEwsKtMbFXARdtxB41FKwqKX0cJz9yZfhB8SnWzwD4KKcjwbAfCwGYKeJfUggg8fRTomDTHx)z8sJi2Mh1jd7F2vGwbNXdcsqP(NrFl9xNJjZv(8hVByWxS26W01gE9NzL5OomjraF(uC8UHbFXARdtxB41FgV0iwxovnYCzdsDH9G1acwGZAqHBaQ4USnWZIRbyxcMN1aISvgni8gqHg4XMloUro0E9h2GDjyEwsKtgDH9GzXSaNrAbrgtlmM1JnxCSbDH9GzXSaNXZenYH2R)WgSlbZZsICY0)ZSRGF4vlKc9R9esWjpTro0E9h2GDjyEwsKtgNTYG0cIS(NrFl9xNJjjxtGPfgZ6XMlo24zBGZS6WjjcAKBKdTx)HnObloTqgdFq1kKwqKrHHGmIMv0yXIFwSMXZ5sGcdbzenROXILbFXAgpNlbLRaTcolqzcF(ugAVslw5K5sW8mnrO9kTyhVBWWhuTcjdTxPfRCYCjyQOQro0E9h2GgS40ssKtg7XIH3CH0cImkmeKr0SIglw8ZI1SYCuhMNP8ojDGDRxZcF(OWqqgrZkASyzWxSMvMJ6W8mL3jPdSB9AwAKdTx)HnObloTKe5KXESq1kKwqKrHHGmIMv0yXYGVynRmh1H5rhy361SWNpkmeKr0SIglw8ZI1mEoxc8ZI1kAwrJfE4nF(OWqqgrZkASyXplwZ45CjyWxSwrZkASGWH2R)mC2WZm1zHyvEMtYPnYH2R)Wg0GfNwsICYC2WZiTGiJcdbzenROXIf)SynRmh1H5rhy361SWNpkmeKr0SIglwg8fRz8CUem4lwROzfnwq4q71FgoB4zM6SqSkpZ5H3kx5kfa]] )


end
