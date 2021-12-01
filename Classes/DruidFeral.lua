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
        return active_bt_triggers > 1
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

                if will_proc_bloodtalons then proc_bloodtalons()
                else applyBuff( "bt_brutal_slash" ) end
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


    spec:RegisterPack( "Feral", 20211123, [[dS082bqiKOEejkDjejLnjcFseHrHK6uijRsukVIK0SavDlqrTlQ8lrudtKIJjswMOKNHezAKO6AGcBtejFJefgNiI6CGIW6eLkZdrQ7HO2hjXbrKuTqrQEOOu1efreBKef9rrePtIijTseXmfrk3uKs0orc)uePAOisIwkOi9ueMkjYxrKeglOiAVO6Vu1GboSWIH0Jj1Kv0Lj2miFwbJwuDAjRwKs61GsZgLBRq7wLFRQHJuhxKsy5k9COMoLRdX2ffFNegpIeNhuz9IuQ5tsTFPMNIReNygMWPiR0KvQuPYIsUSsbdycyKuCcdoAHtqhAyJbHtCXOWjuMYgmobDah7Jjxjob(rwTWjYnJgNDjN8qz5iOo9pMmUgryHv)P3aYsgxJ6K5eOifZivpokNygMWPiR0KvQuPYIsUSsbdycyKfNiqS8F5ee1y2ZjYR5uookNykynNqzkBWAqsYIuZMek(mYiQSnifLGVbzLMSs1K0KOmLnynGuNuzsRb64AqWWFdqLga9i3SbH1GCZOXzxYjpuyZnuwocQt)JjdtgxAhBKCsLKHjskDsgMaMiPGGraPfyOLuPGXmckfPjjpdiOMKMKSppUbbNDnjWCdMlsnDVcMcjYiEDyKt1aDUOHf3a7BWCrQP7vWuirgXRdZ1KaZni7)lJSwdsxPgq)pZVc(rwT0a7BGIOSgiKc9kyC9NRjbMBaP(C2G6mzxeARqzsduMmbNR3aYAqb1a4EKgKhzKgCVLx3qdegwAG9ny(UMeyUbjj)LewdYF2Sbz)FzEyLga9BdGPfDdqoMGXnaUhjjySgSsWyW1ayAr74eScByUsCcu2)tly)H5kXPifxjoHCbktM805eH2Q)4eBaRWj0BzYwbNG6gq5gyLg26gAGA1nG6gKYLvdYwdOLfxytoZpIWSIMvY2avi3G5BUnGvC0JimROzLSnGQgOwDdOUbH2QmIh182wddYIBa5gKvds0GvGwbNhOmPbu1aQAqIgGIab5qn)gWkU5R44eA40mXBXoigMtrkUXPilUsCc5cuMm5PZjcTv)XjyixS(6W01gw9hNqVLjBfCIvGwbNhOmPbjAakceKd18J)Fq1kU5R44eA40mXBXoigMtrkUXPGsCL4eYfOmzYtNteAR(Jty5BGZ96W4e6TmzRGtSc0k48aLjnirdqrGGCOM3Y3aN7MVIRbjAWCrQPZY3aN71H5Ssdl2pe1jt)F(vGwbN3avAa1nq5nq1gGPfgZBXoig2z5BGZ96WAq2AGYBavni5gqDds1avBWyGnzHZNjyisdOQbWCd0)nrkZzb2ep0VEu2)tNCbktMCcnCAM4TyhedZPif34uOCUsCc5cuMm5PZj0BzYwbNafbcYHAE0fXcMhZcCUB(koorOT6pob6IybZJzboNBCkGbxjoHCbktM805e6TmzRGtGIab5qnpwrrlU5R4AqIgGPfgZBXoig2Hvu0IxhwduPbP4eH2Q)4eyffT41HXnofjfxjoHCbktM805e6TmzRGtGIab5qnpoFLPB(koorOT6poboFLj34uOm4kXjKlqzYKNoNqVLjBfCcueiihQ5XkkAXnFfhNi0w9hNaROOfVomUXPijZvItixGYKjpDoHElt2k4eOiqqouZB5BGZDZxXXjcTv)XjS8nW5EDyCJBCcO6kCUSCL4uKIReNqUaLjtE6CcOF9NqkgNIuCIqB1FCc6)z(vWpYQfUXPilUsCc5cuMm5PZj0BzYwbNafbcYHJmXG43pw3kJrD4gq6gqjorOT6poboYedIF)y5gNckXvItixGYKjpDoHElt2k4eu3G5Iuth9wJbZRydl3zLgwSFiQtM()8RaTcoVbQ0ak1GS1aQBaMwymVf7Gyyh9wJbZRydlVbQ2GunGQgKObyAHX8wSdIHD0BngmVInS8gOsds1aQAGA1natlmM3IDqmSJERXG5vSHL3avAa1nGsnq1gKQbzRbwWKZC4avw7Fl3jxGYKzdOIteAR(JtqV1yW8k2WY5gNcLZvItixGYKjpDorOT6poXw0Cc9wMSvWjwbAfCEGYKgKObZfPMUTODwPHf7hI6KP)p)kqRGZBGknitSvGYe3w0ER0WIBqIgqDdOUbOiqqoRgKf7Hqw4Ci0nqT6gq5gyLg26gAavnirdOUbOiqqou2)tly)HDi0nqT6gq5gybtoZHY(FAb7pStUaLjZgqvduRUbuUbwWKZC4avw7Fl3jxGYKzdOQbjAa1natlmM3IDqmSJERXG5vSHL3aYnivduRUbuUbwWKZC0BngmVInSCNCbktMnGQgKObu3GqBvgXpFZTfDdi3G00a1QBGvAyRBObjAqOTkJ4NV52IUbKBqQgOwDdOCdwKtG(DqCZnqgYn)d5NIq7HEnc2jxGYKzduRUbuUbwWKZC4avw7Fl3jxGYKzdOItOHtZeVf7GyyofP4gNcyWvItixGYKjpDoHElt2k4eOiqqoCKjge)(X6wzmQd3as3aQBG(hrFp9xNHBGQnivdOQbzRbjvdYwdsJJsCIqB1FCcCKjge)(XYnofjfxjoHCbktM805eJbP4Lt2b44uKIteAR(Jtaj7RRhb7rlt4eA40mXBXoigMtrkUXPqzWvItixGYKjpDorOT6pobKSVUEeShTmHtO3YKTcobkceKdf7Rt7qOBqIgybtoZHFeM)H8wU4H(vWMtUaLjZgOwDd0)ZMVIZP)lZdR4TCXJPRTmSBLXOoCdiDds1Genq)zKloZD1qU5HcHtOHtZeVf7GyyofP4g34eyXqO5kXPifxjoHCbktM805e6TmzRGtO)mYfN5orVp73zds0amTWyEl2bXWolFdCUxhwdiDduEds0a9pI(E6Vod3as3ay0GenGYnWknS1n0GenGYnafbcYHI91PDi0CIqB1FCcgYfRVomDTHv)XnofzXvItixGYKjpDob0V(tifJtrkorOT6pob9)m)k4hz1c34uqjUsCc5cuMm5PZj0BzYwbNWcMCMds2G5Hw5sB4CYfOmz2Genq)pB(kohKSbZdTYL2W5qOBqIgq5gGIab5WrMyq87hRdHUbjAG(hrFp9xNHBGknivds0G5BUnGvCwPHTUHgKObu3G5BogYfRVomDTHv)5SsdBDdnqT6gq5gybtoZXqUy91HPRnS6pNCbktMnGkorOT6poboYedIF)y5gNcLZvItixGYKjpDoHElt2k4ewWKZCOS)NwW(d7KlqzYSbjAakceKdL9)0c2Fy38vCnirdOUbYj7aCnq1gqjhmAq2AGCYoaNBLb5AGQnG6gO800GS1aueiiNMjXQdSv3GdHUbu1aQAaPBa1nivky0ayUbzrPgKTgGIab5Qth7fw9Nh26g8pK3YfFAf5gyIdHUbu1Geni0wLr8OM32AyqwCdi3G0WjcTv)XjO)N5xb)iRw4gNcyWvItixGYKjpDoHElt2k4ewWKZCOS)NwW(d7KlqzYSbjAakceKdL9)0c2Fy38vCnirdOUb6Fe990FDgUbKUbWObQv3amTWyEl2bXWolFdCUxhwdi3GunGkob22sBCksXjcTv)Xj0bJ5dTv)5zf24eScB(lgfobk7)PfS)WCJtrsXvItixGYKjpDorOT6poHoymFOT6ppRWgNGvyZFXOWj0)ZMVIJBCkugCL4eYfOmzYtNtO3YKTcoH(hrFp9xNHBGknGsnirdOUbOiqqou2)tly)HDi0nqT6gq5gybtoZHY(FAb7pStUaLjZgqfNaBBPnofP4eH2Q)4e6GX8H2Q)8ScBCcwHn)fJcNaQUcNll34gNanyXPfUsCksXvItixGYKjpDoHElt2k4eOiqqorZkAS4Xplw38vCnirdqrGGCIMv0yXZqUyDZxX1GenG6gSc0k48aLjnqT6gqDdcTvzeVCYyj4gOsds1Geni0wLr8Z3CyKdQwPbKUbH2QmIxozSeCdOQbuXjcTv)XjWihuTc34uKfxjoHCbktM805e6TmzRGtGIab5enROXIh)SyDRmg1HBGknivAAGQnqhyZB1O0a1QBakceKt0SIglEgYfRBLXOoCduPbPstduTb6aBERgforOT6pob2IfJSdc34uqjUsCc5cuMm5PZj0BzYwbNafbcYjAwrJfpd5I1TYyuhUbQ0aDGnVvJsduRUbOiqqorZkAS4Xplw38vCnirdWplwVOzfnwAGkninnqT6gGIab5enROXIh)SyDZxX1GenGHCX6fnROXsdG5geAR(ZPydl3vNhIvd5wdiDdsXjcTv)XjWwSq1kCJtHY5kXjKlqzYKNoNqVLjBfCcueiiNOzfnw84NfRBLXOoCduPb6aBERgLgOwDdqrGGCIMv0yXZqUyDZxX1GenGHCX6fnROXsdG5geAR(ZPydl3vNhIvd5wduPbPHteAR(JtOydlNBCJtmfOaHzCL4uKIReNqUaLjtE6Cc9wMSvWjqrGGCJ)FWwNh63rhcDds0ak3G5Iut3RGPqImIxhgNaBBPnofP4eH2Q)4elY5dTv)5zf24eScB(lgfobAWItlCJtrwCL4eYfOmzYtNtO3YKTcoXCrQP7vWuirgXRdJtGTT0gNIuCIqB1FCcDWy(qB1FEwHnobRWM)IrHt8kykKiJWnofuIReNqUaLjtE6CIPG1BrB1FCcsL7RG1af5YjzKTb0pgxOmHteAR(JtqVVcg34uOCUsCc5cuMm5PZj0BzYwbNafbcYPdZd97OB(koorOT6poHvdYI9qilCCJtbm4kXjKlqzYKNoNqVLjBfCcueiiNomp0VJU5R44eH2Q)4e6W8q)oYnofjfxjoHCbktM805etbR3I2Q)4ej9tAao)TgGnjywoNi0w9hNyroFOT6ppRWgNaBBPnofP4e6TmzRGtGIab5W5X8vmkSPdHUbQv3aueiih9(kyoeAobRWM)IrHtGnjywo34uOm4kXjcTv)XjWWIWyE0aNZjKlqzYKNo34uKK5kXjKlqzYKNoNqVLjBfCIqBvgXpFZTfDdi3G0WjW2wAJtrkorOT6poHoymFOT6ppRWgNGvyZFXOWjWIHqZnofWeCL4eYfOmzYtNteAR(JtOdgZhAR(ZZkSXjyf28xmkCc9)S5R44gNIuPHReNqUaLjtE6CIqB1FCITO5etbR3I2Q)4eui69z)oZUgK9b2AaLAWVnq5nq)JOFdO)6SgSfnUb)1aCDdmPbwSdI1GhXW1uAWd1auzXYcBd(TbtKTUHgGklwwyBqb1aizdwdGw5sB4AqHBacDds6W0ge00m4Aq0ayOPBamTOBGIC5AGskZgu4gGq3G4MnqrXyna))1aOGXAWdb54e6TmzRGtO)mYfN5orVp73zds0aQBaLBGfm5mhk7)PfS)Wo5cuMmBGA1nafbcYHY(FAb7pSdHUbu1GenatlmM3IDqmSZY3aN71H1aYnivds0aQBG(hrFp9xNHBGkniRgKObRaTcopqzsds0G5Iut3w0oR0WI9drDY0)NFfOvW5nqLgKj2kqzIBlAVvAyXnirdOUbuUbOiqqouSVoTdHUbQv3a9)S5R4COyFDAhcDduRUbu3aueiihk2xN2Hq3Genq)pB(kohKSbZdTYL2W5qOBavnGQgOwDd0)i67P)6mCdi3ay0GenafbcYz1GSypeYcNdHUbjAakceKZQbzXEiKfo3kJrD4gq6gO8gKObZfPMUTODwPHf7hI6KP)p)kqRGZBGknagnGkUXPivkUsCc5cuMm5PZj0BzYwbNq)JOVN(RZWnqfYnG6gaJgaZnitSvGYeh0JSAApAzsdOItGTT0gNIuCIqB1FCIf58H2Q)8ScBCcwHn)fJcNaQUcNll34uKklUsCc5cuMm5PZj0BzYwbNyUi10rV1yW8k2WYDwPHf7hI6KP)p)kqRGZBGkKBqwPPbjAG(hrFp9xNHBGkKBqwCIqB1FCc6TgdMxXgwoNGvN41tobm4gNIuuIReNqUaLjtE6CIPG1BrB1FCI0seMvW8GE2aSjbZY5eH2Q)4e6GX8H2Q)8ScBCcSTL24uKItO3YKTcobkceKdf7Rt7qO5eScB(lgfob2KGz5CJtrkLZvItixGYKjpDoXuW6TOT6poHs5sdgFS1aHuOLdxzKgKUsnqdNMjnGALYxbN3aI8vMnGqrrlnq)yRbPsbJgiNSdWbFdgdyLgGrwPbkKgOJRbJbSsdS8WAqDnq5nyG9ObdtfNalAob1nG6gKkfmAam3GSOudYwdqrGGC1PJ9cR(ZdBDd(hYB5IpTICdmXHq3aQAam3aQBGCYoaNtJSRCwduTbuYbJgKTgiNSdW5wzqUgOAdOUbkpnniBnafbcYPzsS6aB1n4qOBavnGQgqvdsUbYj7aCUvgKJteAR(JtOikJtO3YKTcoHfm5mhk7)PfS)Wo5cuMmBqIgGIab5qz)pTG9h2nFfxds0GqBvgXJAEBRHbzXnGCdsd34uKcgCL4eYfOmzYtNtmfSElAR(JteAR(d7McuGWmvjNm9)m)k4hz1c8fezlyYzou2)tly)HDYfOmzMafbcYHY(FAb7pSB(kUeulNSdWPkLCWiBYj7aCUvgKtvQvEAYgkceKtZKy1b2QBWHqtfvKM6uPGbmNfLYgkceKRoDSxy1FEyRBW)qElx8PvKBGjoeAQseARYiEuZBBnmilMCA4eH2Q)4elY5dTv)5zf24eyBlTXPifNqVLjBfCclyYzou2)tly)HDYfOmz2GenafbcYHY(FAb7pSB(koobRWM)IrHtGY(FAb7pm34uKkP4kXjKlqzYKNoNi0w9hNas2xxpc2JwMWj0BzYwbNafbcYf0cP4Pxzg2VyVEJm1n4qO5eA40mXBXoigMtrkUXPiLYGReNqUaLjtE6CcOF9NqkgNIuCIqB1FCc6)z(vWpYQfUXPivsMReNqUaLjtE6CIqB1FCInGv4e6TmzRGtqDdwbAfCEGYKgOwDdOLfxytoZpIWSIMvY2avAW8n3gWko6reMv0Ss2gqvds0G5Iut3gWkoR0WI9drDY0)NFfOvW5nqLgGPfgZBXoig2Hvu0IxhwdYwdYQbWCdYItOHtZeVf7GyyofP4gNIuWeCL4eYfOmzYtNteAR(JtWqUy91HPRnS6poHElt2k4eu3GvGwbNhOmPbQv3aAzXf2KZ8JimROzLSnqLgmFZXqUy91HPRnS6ph9icZkAwjBdOQbjAWCrQPJHCX6RdtxBy1FoR0WI9drDY0)NFfOvW5nqLgGPfgZBXoig2Hvu0IxhwdYwdYQbWCdYItOHtZeVf7GyyofP4gNISsdxjoHCbktM805eq)6pHumofP4eH2Q)4e0)Z8RGFKvlCJtrwP4kXjKlqzYKNoNi0w9hNWY3aN71HXj0BzYwbNyfOvW5bktAqIgmxKA6S8nW5EDyoR0WI9drDY0)NFfOvW5nqLgqDduEduTbyAHX8wSdIHDw(g4CVoSgKTgO8gqvdsUbu3Gunq1gmgytw48zcgI0aQAam3a9FtKYCwGnXd9RhL9)0jxGYKzdG5gO)mYfN5orVp73zds0aQBaLBakceKdf7Rt7qOBGA1natlmM3IDqmSZY3aN71H1avAqQgqfNqdNMjEl2bXWCksXnofzLfxjoHCbktM805eq)6pHumofP4eH2Q)4e0)Z8RGFKvlCJtrwuIReNqUaLjtE6Cc9wMSvWjOUbButVKroZfZj2vxduPbu3Gunq1gmgKIxNh7GGBam3aDESdc2dTH2Q)cwdOQbzRbROZJDq8wnknGQgKObu3amTWyEl2bXWo0fXcMhZcCEdYwdcTv)5qxelyEmlW5UzmgdsdsUbH2Q)COlIfmpMf4CN(XwdOQbQ0aQBqOT6phoFLPBgJXG0GKBqOT6phoFLPt)yRbuXjcTv)XjqxelyEmlW5CJtrwkNReNqUaLjtE6Cc9wMSvWjW0cJ5Tyhed7WkkAXRdRbQ0Gunq1gGIab5qX(60oe6gKTgKfNi0w9hNaROOfVomUXPilyWvItixGYKjpDoHElt2k4eyAHX8wSdIHDw(g4CVoSgOsdOeNi0w9hNWY3aN71HXnofzLuCL4eYfOmzYtNtO3YKTcobkceKtZKy1b2QBWHq3GenG6gGIab5WiZPC(yefbN7MVIRbjAakceKdNhZxXOWMU5R4AGA1nafbcYHI91PDi0nGkorOT6poboFLj34uKLYGReNqUaLjtE6CIqB1FCInGv4e6TmzRGtGIab5qX(60oe6gKObZfPMUnGvCwPHf7hI6KP)p)kqRGZBGkniloHgont8wSdIH5uKIBCkYkjZvItixGYKjpDorOT6poHoymFOT6ppRWgNGvyZFXOWjGkgtwUXnob9k6FenmUsCksXvItixGYKjpDoXtZjWIXjcTv)XjYeBfOmHtKjyicNinCImX6Vyu4eqpYQP9OLjCJtrwCL4eYfOmzYtNt80CcSyCIqB1FCImXwbkt4ezcgIWjsXjMcwVfTv)XjiYxz2aYninW3ak(dMXxqJZFRbW0awPbKBqk4BaXf0483AamnGvAa5gKf8niPrQ2aYnGsW3acffT0aYnq5CImX6Vyu4eqfJjl34uqjUsCc5cuMm5PZjEAobwmorOT6porMyRaLjCImbdr4ekdoXuW6TOT6pobHoysduuwEdYdSjoorMy9xmkCITO9wPHfZnofkNReNi0w9hNa26MRm9y6AldZjKlqzYKNo34uadUsCIqB1FCc03mMm9qSaozQOUbV9KsDCc5cuMm5PZnofjfxjoHCbktM805e6TmzRGtGFegADthnc2qyIxweAR(ZjxGYKzduRUb4hHHw30L5zHvmXJFwg5mNCbktMCIqB1FCciMGZ1BazCJtHYGReNqUaLjtE6Cc9wMSvWjqrGGCJ)FWwNh63r38vCCIqB1FCc69vW4gNIKmxjoHCbktM805e6TmzRGtGIab5g))GTop0VJU5R44eH2Q)4e6W8q)oYnUXjGkgtwUsCksXvItixGYKjpDorOT6poXgWkCc9wMSvWjYeBfOmXbvmMSnGCds1GenyfOvW5bktAqIgmFZTbSIJEeHzfnRKTbKMCds5YQbzRb0YIlSjN5hrywrZkz5eA40mXBXoigMtrkUXPilUsCc5cuMm5PZj0BzYwbNitSvGYehuXyY2aYnilorOT6poXgWkCJtbL4kXjKlqzYKNoNqVLjBfCImXwbktCqfJjBdi3akXjcTv)XjyixS(6W01gw9h34uOCUsCc5cuMm5PZj0BzYwbNitSvGYehuXyY2aYnq5CIqB1FCcSIIw86W4gNcyWvItixGYKjpDoHElt2k4eOiqqomYCkNpgrrW5U5R44eH2Q)4e48vMCJtrsXvItixGYKjpDoHElt2k4e4hHHw30rJGneM4LfH2Q)CYfOmz2a1QBa(ryO1nDzEwyft84NLroZjxGYKjNOot2fH28feNa)im06MUmplSIjE8ZYiNXjQZKDrOnFnokZkmHtKIteAR(JtaXeCUEdiJtuNj7IqB(b2JgmorkUXnob2KGz5CL4uKIReNqUaLjtE6CcOF9NqkgNIuCIqB1FCc6)z(vWpYQfUXPilUsCc5cuMm5PZjcTv)Xj2awHtOHtZeVf7GyyofP4e6TmzRGtqDdMV52awXrpIWSIMvY2as3Guoy0a1QBWkqRGZduM0aQAqIgmxKA62awXzLgwSFiQtM()8RaTcoVbQ0GSAGA1nG6gqllUWMCMFeHzfnRKTbQ0G5BUnGvC0JimROzLSnirdqrGGCOyFDAhcDds0amTWyEl2bXWolFdCUxhwdiDdOuds0a9NrU4m3j69z)oBavnqT6gGIab5qX(60UvgJ6WnG0nifNyky9w0w9hNaMgWkn4ezIBW(id5m4AamsdPwdEOgugUbm5gS8gewdIgmwxnIm2a7BagzPdmUb48vM4gmPfUXPGsCL4eYfOmzYtNtO3YKTcobMwymVf7GyyNLVbo3RdRbKUbuQbjAWkqRGZduM0GenyUi10XqUy91HPRnS6pNvAyX(HOoz6)ZVc0k48gOsdGrds0aQBG(hrFp9xNHBa5gO8gOwDdMV5yixS(6W01gw9NBLXOoCdiDdGrduRUbuUbZ3CmKlwFDy6AdR(ZzLg26gAavCIqB1FCcgYfRVomDTHv)XnofkNReNqUaLjtE6CIqB1FCc0fXcMhZcCoNyky9w0w9hNi9fXcwdiyboVbfUbOIzY2alpUgGnjywEdiYxz2GWAaLAGf7GyyoHElt2k4eyAHX8wSdIHDOlIfmpMf48gOsdYIBCkGbxjoHCbktM805eq)6pHumofP4eH2Q)4e0)Z8RGFKvlCJtrsXvItixGYKjpDoHElt2k4e6Fe990FDgUbKUbkVbjAaMwymVf7GyyNLVbo3RdRbKUbWGteAR(JtGZxzYnUXj0)ZMVIJReNIuCL4eYfOmzYtNteAR(JteZG2QmIhRi2roHElt2k4eu3aQBaLBW8nxmdARYiESIyh9ZymgeNvAyRBObQv3G5BUyg0wLr8yfXo6NXymiUvgJ6WnG0niRgqvds0aQBW8nxmdARYiESIyh9Zymgeh2cnSnG0nGsnqT6gq5gmFZfZG2QmIhRi2rFUemh2cnSnqLgKQbu1GenGYni0w9NlMbTvzepwrSJ(CjyU68qSAi3AqIgq5geAR(ZfZG2QmIhRi2r)mgJbXvNhIvd5wds0ak3GqB1FUyg0wLr8yfXo6QZdXQHCRbu1GenWIDqmNvJI3E)SKgOsdGrduRUbH2QmIxozSeCduPbz1GenGYny(MlMbTvzepwrSJ(zmgdIZknS1n0GenqozhGRbKUbucgnirdSyheZz1O4T3plPbQ0ayWj0WPzI3IDqmmNIuCJtrwCL4eYfOmzYtNtO3YKTcob1na)im06MoAeSHWeVSi0w9NtUaLjZgOwDdWpcdTUPlZZcRyIh)SmYzo5cuMmBavCI6mzxeAZxqCc8JWqRB6Y8SWkM4XplJCgNOot2fH2814OmRWeorkorOT6pobetW56nGmorDMSlcT5hypAW4eP4gNckXvItixGYKjpDoXuW6TOT6por2hyRbkvdYMe4gOmrw4AaQa9R0aQ)Tb14OmRWyW1GaYKLQgOdSv3qduMYgSgOmx5sB4Aqb1G0LfllSnOWnGIKUsn4VgO)NnFfNJtGH70CcizdMhALlTHJtO3YKTcoH(F28vCouSVoTdHMteAR(Jty1GSypeYch34uOCUsCc5cuMm5PZjcTv)XjGKnyEOvU0gooHElt2k4e6Fe990FDgUbKUbuQbjAGf7GyoRgfV9(zjnqLgOmAqIgqDdqrGGC4itmi(9J1Hq3a1QBaLBGfm5mhoYedIF)yDYfOmz2aQAqIgqDdOCd0)ZMVIZz1GSypeYcNdHUbQv3a9)S5R4COyFDAhcDdOQbQv3aOAi38Rmg1HBaPBqsUbjAaunKB(vgJ6WnqLgKfNqdNMjEl2bXWCksXnofWGReNqUaLjtE6CIqB1FCcuzXYclNyky9w0w9hNqPKEsssp7AafImBG9nad3PBGIYYBGIYYBWgzK7rWnaALlTHRbkYLRbkKgSixdGw5sB4qJBcFd(TbHXKaBnqNlAyBqb1GYWnqXVwEdkJtO3YKTcoH(hrFp9xNHBGkKBaL4gNIKIReNqUaLjtE6Cc9wMSvWj0)i67P)6mCduHCdOeNi0w9hNOoDSxy1FCJtHYGReNqUaLjtE6CIqB1FCcRgKf7Hqw44etbR3I2Q)4ekTW1G4Mn4ERbkcSjnqjLzdKt2b4GVbOiwdcg(BqAfbBnablnOSga9BdsBzHTbXnBqD6ypmNqVLjBfCc5KDao3uGkDznqLgO800a1QBakceKdf7Rt7qOBGA1nG6gybtoZrVYmSFDYfOmz2GenaN)RjyZB2SbKUbuQbuXnofjzUsCc5cuMm5PZjcTv)XjW5X8vmkSjNyky9w0w9hNiTSgYTgGknqX(3qdSVbiyPbeJcB2G)AamnGvAqDniJSW1GmYcxdUsNlnaxgsy1Fy4BakI1GmYcxd2yfgCCc9wMSvWjqrGGCwnil2dHSW5qOBqIgGIab5qX(60U5R4AqIgO)r03t)1z4gq6gO8gKObOiqqomYCkNpgrrW5U5R4AqIgmFZTbSIJEeHzfnRKTbKUbPCjvds0a5KDaUgOsduEAAqIgmxKA62awXzLgwSFiQtM()8RaTcoVbQ0amTWyEl2bXWoSIIw86WAq2AqwnaMBqwnirdSyheZz1O4T3plPbQ0ayWnofWeCL4eYfOmzYtNtO3YKTcobkceKZQbzXEiKfohcDduRUbOiqqouSVoTdHMteAR(JtGklwwyRBGBCksLgUsCc5cuMm5PZj0BzYwbNafbcYHI91PDi0nqT6gG(yCds0aOAi38Rmg1HBaPBG(F28vCouSVoTBLXOoCduRUbOpg3GenaQgYn)kJrD4gq6gKfm4eH2Q)4e0Vv)XnofPsXvItixGYKjpDoHElt2k4eOiqqouSVoTdHUbQv3aOAi38Rmg1HBaPBqwP4eH2Q)4eBKrUhb7Hw5sB44gNIuzXvItixGYKjpDorOT6poH(VmpSI3YfpMU2YWCIPG1BrB1FCcLs6jjj9SRbzFUOHTbJ)FWwxdYFtrdIB2aSHab1awbR0alVWW3G4MnymGdvAaQyMSnq)JOH1GvgJ6AWky4onNqVLjBfCcQBa1ny(MBlA3kJrD4gOsduEduRUbq1qU5xzmQd3as3GmXwbktCBr7TsdlUbjAW8n3w0oR0W6TAuAavnird0)i67P)6mCdiDdGrds0aQBW8n3gWkoR0Ww3qduRUbyAHX8wSdIHDw(g4CVoSgOsds1aQAqIgiNSdW5McuPlRbQqUbzLMgqvduRUbOpg3GenaQgYn)kJrD4gq6gadUXPifL4kXjKlqzYKNoNi0w9hNqgPFfY6r)BYjMcwVfTv)Xjsld4qLgy5YknaN)iSzdqLgm(R0a9FZYQ)Wn4Vgy5sd0)nrkJtO3YKTcobkceKZQbzXEiKfohcDduRUbu3a9FtKYCtrO9bJjdvCAXjxGYKzdOIBCksPCUsCc5cuMm5PZjMcwVfTv)XjssRmsdO363YGRb23G)GzeS0afsq)hN4IrHtKwFd5gKAx)uWwDWH96GX4e6TmzRGtiPfifnTmDP13qUbP21pfSvhCyVoymorOT6porA9nKBqQD9tbB1bh2RdgJBCksbdUsCIqB1FCceS4ltgXCc5cuMm5PZnUXjEfmfsKr4kXPifxjoHCbktM805e6TmzRGtGIab5YLyn)d5TCXROythcnNi0w9hNaBXIr2bHBCkYIReNqUaLjtE6CIqB1FCcmYbvRWjy1jE9KtO8SnONCJtbL4kXjKlqzYKNoNi0w9hNy8)dQwHtO3YKTcobkceKB8)d268q)o6qOBqIgGPfgZBXoig2z5BGZ96WAaPBqwnirdOCdSGjN5yixS(6W01gw9NtUaLjtobRoXRNCcLNTb9KBCkuoxjoHCbktM805e6TmzRGtiNSdW1as3akLMgKObZ3CBr7wzmQd3avAGYDWObjAa1nq)pB(koNvdYI9qilCUvgJ6WnqfYniPCWObQv3Gf5eOFheNomboXRr26DYfOmz2aQAqIgGIab50mjwDGT6gCyl0W2as3GunirdOCdqrGGCbTqkE6vMH9l2R3itDdoe6gKObuUbOiqqou2)tgc2Ci0nirdOCdqrGGCOyFDAhcDds0aQBG(F28vCo9FzEyfVLlEmDTLHDRmg1HBGkniPCWObQv3ak3a9NrU4m3vd5MhkKgqvds0aQBaLBG(ZixCM7e9(SFNnqT6gO)NnFfNlMbTvzepwrSJUvgJ6WnqfYnagnqT6gmFZfZG2QmIhRi2r)mgJbXTYyuhUbQ0aLrdOIteAR(JtKlXA(hYB5IxrXMCJtbm4kXjKlqzYKNoNqVLjBfCc5KDaUgq6gqP00Geny(MBlA3kJrD4gOsduUdgnirdOUb6)zZxX5SAqwShczHZTYyuhUbQqUbk3bJgOwDdwKtG(DqC6We4eVgzR3jxGYKzdOQbjAakceKtZKy1b2QBWHTqdBdiDds1GenGYnafbcYf0cP4Pxzg2VyVEJm1n4qOBqIgq5gGIab5qz)pziyZHq3GenG6gq5gGIab5qX(60oe6gOwDd0Fg5IZCNO3N97SbjAGfm5mhoYedIF)yDYfOmz2GenafbcYHI91PDRmg1HBGkniPAavnirdOUb6)zZxX50)L5Hv8wU4X01wg2TYyuhUbQ0GKYbJgOwDdOCd0Fg5IZCxnKBEOqAavnirdOUbuUb6pJCXzUt07Z(D2a1QBG(F28vCUyg0wLr8yfXo6wzmQd3avi3ay0a1QBW8nxmdARYiESIyh9Zymge3kJrD4gOsdugnGQgKObq1qU5xzmQd3avAGYGteAR(Jtm()bBDEOFh5g34gNiJS46pofzLMSsLMKCwkNtOi2RUbmNGubPomLcsvkssZUg0aLYLguJ0)Ana63gKeq1v4CztIgSsAbsTYSb4FuAqGy)yyYSb684geSRjjPvN0aLNDni7)lJSMmBqsSiNa97G4GjtIgyFdsIf5eOFhehmPtUaLjZKObuNIuOY1K0KqQGuhMsbPkfjPzxdAGs5sdQr6FTga9BdsIPafimljAWkPfi1kZgG)rPbbI9JHjZgOZJBqWUMKKwDsdYkv21GS)VmYAYSbe1y23amCNfKsdi1AG9niPHenywzkC9xdEAzd73gqDYu1aQtrku5AssA1jnilkLDni7)lJSMmBarnM9nad3zbP0asTgyFdsAirdMvMcx)1GNw2W(TbuNmvnG6SifQCnjnjKki1HPuqQsrsA21GgOuU0GAK(xRbq)2GKaL9)0c2F4KObRKwGuRmBa(hLgei2pgMmBGopUbb7AssA1jnGszxdY()YiRjZgquJzFdWWDwqknGuRb23GKgs0GzLPW1Fn4PLnSFBa1jtvdOofPqLRjPjHubPomLcsvkssZUg0aLYLguJ0)Ana63gKe6)zZxXLenyL0cKALzdW)O0GaX(XWKzd05XniyxtssRoPbzLDni7)lJSMmBqsGFegADthmzs0a7BqsGFegADthmPtUaLjZKObuNfPqLRjPjHubPomLcsvkssZUg0aLYLguJ0)Ana63gKeVcMcjYijrdwjTaPwz2a8pkniqSFmmz2aDECdc21KK0QtAGYZUgK9)LrwtMnijwKtG(DqCWKjrdSVbjXICc0VdIdM0jxGYKzs0aQtrku5AssA1jnagzxdY()YiRjZgKelYjq)oioyYKOb23GKyrob63bXbt6KlqzYmjAa1PifQCnjnjKQJ0)AYSbPstdcTv)1awHnSRjHtqVpuXeoHYQSnqzkBWAqsYIuZMeLvzBafFgzev2gKIsW3GSstwPAsAsuwLTbktzdwdi1jvM0AGoUgem83auPbqpYnBqyni3mAC2LCYdf2CdLLJG60)yYWKXL2XgjNujzyIKsNKHjGjskiyeqAbgAjvkymJGsrAsYZacQjPjrzv2gK95Xni4SRjrzv2gaZnyUi109kykKiJ41Hrovd05IgwCdSVbZfPMUxbtHezeVomxtIYQSnaMBq2)xgzTgKUsnG(FMFf8JSAPb23afrznqif6vW46pxtIYQSnaMBaP(C2G6mzxeARqzsduMmbNR3aYAqb1a4EKgKhzKgCVLx3qdegwAG9ny(UMeLvzBam3GKK)scRb5pB2GS)VmpSsdG(TbW0IUbihtW4ga3JKemwdwjym4AamTODnjnjH2Q)Wo6v0)iAyQso5mXwbktG)IrHm0JSAApAzc8zcgIqonnjkBdiYxz2aYninW3ak(dMXxqJZFRbW0awPbKBqk4BaXf0483AamnGvAa5gKf8niPrQ2aYnGsW3acffT0aYnq5njH2Q)Wo6v0)iAyQso5mXwbktG)IrHmuXyYcFMGHiKt1KOSnGqhmPbkklVb5b2extsOT6pSJEf9pIgMQKtotSvGYe4VyuiVfT3knSy4ZemeHSYOjj0w9h2rVI(hrdtvYjdBDZvMEmDTLHBscTv)HD0RO)r0WuLCYOVzmz6HybCYurDdE7jL6AscTv)HD0RO)r0WuLCYqmbNR3aYGVGiJFegADthnc2qyIxweAR(ZjxGYKPA14hHHw30L5zHvmXJFwg5mNCbktMnjH2Q)Wo6v0)iAyQsoz69vWGVGiJIab5g))GTop0VJU5R4AscTv)HD0RO)r0WuLCY6W8q)ocFbrgfbcYn()bBDEOFhDZxX1K0KeAR(dtEroFOT6ppRWg8xmkKrdwCAbESTL2iNc(cImkceKB8)d268q)o6qOtq55Iut3RGPqImIxhwtsOT6pSQKtwhmMp0w9NNvyd(lgfYVcMcjYiWJTT0g5uWxqKNlsnDVcMcjYiEDynjkBdivUVcwduKlNKr2gq)yCHYKMKqB1FyvjNm9(kynjH2Q)WQsozRgKf7Hqw4GVGiJIab50H5H(D0nFfxtsOT6pSQKtwhMh63r4liYOiqqoDyEOFhDZxX1KOSniPFsdW5V1aSjbZYBscTv)HvLCYlY5dTv)5zf2G)IrHm2KGz5WJTT0g5uWxqKrrGGC48y(kgf20HqRwnkceKJEFfmhcDtsOT6pSQKtgdlcJ5rdCEtsOT6pSQKtwhmMp0w9NNvyd(lgfYyXqOHhBBPnYPGVGihARYi(5BUTOjNMMKqB1FyvjNSoymFOT6ppRWg8xmkK1)ZMVIRjrzBafIEF2VZSRbzFGTgqPg8BduEd0)i63a6VoRbBrJBWFnax3atAGf7Gyn4rmCnLg8qnavwSSW2GFBWezRBObOYILf2guqnas2G1aOvU0gUgu4gGq3GKomTbbnndUgenagA6gatl6gOixUgOKYSbfUbi0niUzduumwdW)FnakySg8qqUMKqB1FyvjN8w0WxqK1Fg5IZCNO3N97mb1u2cMCMdL9)0c2FyNCbktMQvJIab5qz)pTG9h2HqtvcmTWyEl2bXWolFdCUxhg5ujOw)JOVN(RZWQKvIvGwbNhOmjXCrQPBlANvAyX(HOoz6)ZVc0k4CvYeBfOmXTfT3knS4eutzueiihk2xN2HqRwT(F28vCouSVoTdHwTAQrrGGCOyFDAhcDc9)S5R4CqYgmp0kxAdNdHMkQuRw)JOVN(RZWKHrcueiiNvdYI9qilCoe6eOiqqoRgKf7Hqw4CRmg1HjTYtmxKA62I2zLgwSFiQtM()8RaTcoxfyqvtsOT6pSQKtEroFOT6ppRWg8xmkKHQRW5Ycp22sBKtbFbrw)JOVN(RZWQqMAyaZzITcuM4GEKvt7rltOQjj0w9hwvYjtV1yW8k2WYHVGipxKA6O3AmyEfBy5oR0WI9drDY0)NFfOvW5QqoR0Kq)JOVN(RZWQqol4z1jE9KmmAsu2gKwIWScMh0ZgGnjywEtsOT6pSQKtwhmMp0w9NNvyd(lgfYytcMLdp22sBKtbFbrgfbcYHI91PDi0njkBdukxAW4JTgiKcTC4kJ0G0vQbA40mPbuRu(k48gqKVYSbekkAPb6hBnivky0a5KDao4BWyaR0amYknqH0aDCnymGvAGLhwdQRbkVbdShnyyQAscTv)HvLCYkIYGhlAYutDQuWaMZIszdfbcYvNo2lS6ppS1n4FiVLl(0kYnWehcnvWm1Yj7aConYUYzQsjhmYMCYoaNBLb5uLALNMSHIab50mjwDGT6gCi0urfvjlNSdW5wzqo4liYwWKZCOS)NwW(d7KlqzYmbkceKdL9)0c2Fy38vCjcTvzepQ5TTggKftonnjkBdcTv)HvLCY0)Z8RGFKvlWxqKTGjN5qz)pTG9h2jxGYKzcueiihk7)PfS)WU5R4sqTCYoaNQuYbJSjNSdW5wzqovPw5PjBOiqqontIvhyRUbhcnvurAQtLcgWCwukBOiqqU60XEHv)5HTUb)d5TCXNwrUbM4qOPkrOTkJ4rnVT1WGSyYPPjj0w9hwvYjViNp0w9NNvyd(lgfYOS)NwW(ddp22sBKtbFbr2cMCMdL9)0c2FyNCbktMjqrGGCOS)NwW(d7MVIRjj0w9hwvYjdj7RRhb7rltGxdNMjEl2bXWKtbFbrgfbcYf0cP4Pxzg2VyVEJm1n4qOBscTv)HvLCY0)Z8RGFKvlWd9R)esXiNQjj0w9hwvYjVbSc8A40mXBXoigMCk4liYuVc0k48aLjQvtllUWMCMFeHzfnRKvL5BUnGvC0JimROzLSuLyUi10TbSIZknSy)quNm9)5xbAfCUkyAHX8wSdIHDyffT41HLTSG5SAscTv)HvLCYmKlwFDy6AdR(dEnCAM4Tyhedtof8fezQxbAfCEGYe1QPLfxytoZpIWSIMvYQY8nhd5I1xhMU2WQ)C0JimROzLSuLyUi10XqUy91HPRnS6pNvAyX(HOoz6)ZVc0k4CvW0cJ5Tyhed7WkkAXRdlBzbZz1KeAR(dRk5KP)N5xb)iRwGh6x)jKIrovtsOT6pSQKt2Y3aN71HbVgont8wSdIHjNc(cI8kqRGZduMKyUi10z5BGZ96WCwPHf7hI6KP)p)kqRGZvHALRkMwymVf7GyyNLVbo3RdlBkNksnQtP6yGnzHZNjyicvWS(VjszolWM4H(1JY(F6KlqzYeM1Fg5IZCNO3N97mb1ugfbcYHI91PDi0QvJPfgZBXoig2z5BGZ96WujfvnjH2Q)WQsoz6)z(vWpYQf4H(1FcPyKt1KeAR(dRk5KrxelyEmlW5WxqKPEJA6LmYzUyoXU6uH6uQogKIxNh7GGHzDESdc2dTH2Q)cgvzBfDESdI3QrHQeuJPfgZBXoig2HUiwW8ywGZZwOT6ph6IybZJzbo3nJXyqi1cTv)5qxelyEmlW5o9JnQuH6qB1FoC(kt3mgJbHul0w9NdNVY0PFSrvtsOT6pSQKtgROOfVom4liYyAHX8wSdIHDyffT41HPskvrrGGCOyFDAhcD2YQjj0w9hwvYjB5BGZ96WGVGiJPfgZBXoig2z5BGZ96WuHsnjH2Q)WQsozC(kt4liYOiqqontIvhyRUbhcDcQrrGGCyK5uoFmIIGZDZxXLafbcYHZJ5Ryuyt38vCQvJIab5qX(60oeAQAscTv)HvLCYBaRaVgont8wSdIHjNc(cImkceKdf7Rt7qOtmxKA62awXzLgwSFiQtM()8RaTcoxLSAscTv)HvLCY6GX8H2Q)8ScBWFXOqgQymzBsAscTv)HDOS)NwW(dtEdyf41WPzI3IDqmm5uWxqKPMYwPHTUb1QPoLlRSrllUWMCMFeHzfnRKvfYZ3CBaR4OhrywrZkzPsTAQdTvzepQ5TTggKftoReRaTcopqzcvuLafbcYHA(nGvCZxX1KeAR(d7qz)pTG9hwvYjZqUy91HPRnS6p41WPzI3IDqmm5uWxqKxbAfCEGYKeOiqqouZp()bvR4MVIRjj0w9h2HY(FAb7pSQKt2Y3aN71HbVgont8wSdIHjNc(cI8kqRGZduMKafbcYHAElFdCUB(kUeZfPMolFdCUxhMZknSy)quNm9)5xbAfCUkuRCvX0cJ5Tyhed7S8nW5EDyzt5urQrDkvhdSjlC(mbdrOcM1)nrkZzb2ep0VEu2)tNCbktMnjH2Q)Wou2)tly)HvLCYOlIfmpMf4C4liYOiqqouZJUiwW8ywGZDZxX1KeAR(d7qz)pTG9hwvYjJvu0Ixhg8fezueiihQ5XkkAXnFfxcmTWyEl2bXWoSIIw86WujvtsOT6pSdL9)0c2FyvjNmoFLj8fezueiihQ5X5RmDZxX1KeAR(d7qz)pTG9hwvYjJvu0Ixhg8fezueiihQ5XkkAXnFfxtsOT6pSdL9)0c2FyvjNSLVbo3Rdd(cImkceKd18w(g4C38vCnjnjH2Q)Wo9)S5R4ihZG2QmIhRi2r41WPzI3IDqmm5uWxqKPMAkpFZfZG2QmIhRi2r)mgJbXzLg26guRE(MlMbTvzepwrSJ(zmgdIBLXOomPZIQeupFZfZG2QmIhRi2r)mgJbXHTqdlPPKA1uE(MlMbTvzepwrSJ(CjyoSfAyvjfvjOCOT6pxmdARYiESIyh95sWC15Hy1qULGYH2Q)CXmOTkJ4XkID0pJXyqC15Hy1qULGYH2Q)CXmOTkJ4XkID0vNhIvd5gvjSyheZz1O4T3plrfyOwDOTkJ4LtglbRswjO88nxmdARYiESIyh9ZymgeNvAyRBiHCYoahPPemsyXoiMZQrXBVFwIkWOjj0w9h2P)NnFfNQKtgIj4C9gqg8fezQXpcdTUPJgbBimXllcTv)Pwn(ryO1nDzEwyft84NLroJk4RZKDrOnFnokZkmHCk4RZKDrOn)a7rdg5uWxNj7IqB(cIm(ryO1nDzEwyft84NLroRjrzBq2hyRbkvdYMe4gOmrw4AaQa9R0aQ)Tb14OmRWyW1GaYKLQgOdSv3qduMYgSgOmx5sB4Aqb1G0LfllSnOWnGIKUsn4VgO)NnFfNRjj0w9h2P)NnFfNQKt2QbzXEiKfo4XWDAYqYgmp0kxAdh8fez9)S5R4COyFDAhcDtsOT6pSt)pB(kovjNmKSbZdTYL2WbVgont8wSdIHjNc(cIS(hrFp9xNHjnLsyXoiMZQrXBVFwIkkJeuJIab5WrMyq87hRdHwTAkBbtoZHJmXG43pwNCbktMuLGAkR)NnFfNZQbzXEiKfohcTA16)zZxX5qX(60oeAQuRgQgYn)kJrDysNKtavd5MFLXOoSkz1KOSnqPKEsssp7AafImBG9nad3PBGIYYBGIYYBWgzK7rWnaALlTHRbkYLRbkKgSixdGw5sB4qJBcFd(TbHXKaBnqNlAyBqb1GYWnqXVwEdkRjj0w9h2P)NnFfNQKtgvwSSWcFbrw)JOVN(RZWQqMsnjH2Q)Wo9)S5R4uLCY1PJ9cR(d(cIS(hrFp9xNHvHmLAsu2gO0cxdIB2G7TgOiWM0aLuMnqozhGd(gGIyniy4VbPveS1aeS0GYAa0VniTLf2ge3Sb1PJ9WnjH2Q)Wo9)S5R4uLCYwnil2dHSWbFbrwozhGZnfOsxMkkpnQvJIab5qX(60oeA1QP2cMCMJELzy)6KlqzYmbo)xtWM3SjPPevnjkBdslRHCRbOsduS)n0a7BacwAaXOWMn4VgatdyLguxdYilCniJSW1GR05sdWLHew9hg(gGIyniJSW1GnwHbxtsOT6pSt)pB(kovjNmopMVIrHnHVGiJIab5SAqwShczHZHqNafbcYHI91PDZxXLq)JOVN(RZWKw5jqrGGCyK5uoFmIIGZDZxXLy(MBdyfh9icZkAwjlPt5sQeYj7aCQO80KyUi10TbSIZknSy)quNm9)5xbAfCUkyAHX8wSdIHDyffT41HLTSG5SsyXoiMZQrXBVFwIkWOjj0w9h2P)NnFfNQKtgvwSSWw3a8fezueiiNvdYI9qilCoeA1QrrGGCOyFDAhcDtsOT6pSt)pB(kovjNm9B1FWxqKrrGGCOyFDAhcTA1OpgNaQgYn)kJrDysR)NnFfNdf7Rt7wzmQdRwn6JXjGQHCZVYyuhM0zbJMKqB1FyN(F28vCQso5nYi3JG9qRCPnCWxqKrrGGCOyFDAhcTA1q1qU5xzmQdt6Ss1KOSnqPKEsssp7Aq2NlAyBW4)hS11G83u0G4MnaBiqqnGvWknWYlm8niUzdgd4qLgGkMjBd0)iAynyLXOUgScgUt3KeAR(d70)ZMVItvYjR)lZdR4TCXJPRTmm8fezQPE(MBlA3kJrDyvuUA1q1qU5xzmQdt6mXwbktCBr7TsdloX8n3w0oR0W6TAuOkH(hrFp9xNHjnmsq98n3gWkoR0Ww3GA1yAHX8wSdIHDw(g4CVomvsrvc5KDao3uGkDzQqoR0qLA1OpgNaQgYn)kJrDysdJMeLTbPLbCOsdSCzLgGZFe2SbOsdg)vAG(Vzz1F4g8xdSCPb6)MiL1KeAR(d70)ZMVItvYjlJ0Vcz9O)nHVGiJIab5SAqwShczHZHqRwn16)MiL5MIq7dgtgQ40ItUaLjtQAsu2gKKwzKgqV1VLbxdSVb)bZiyPbkKG(VMKqB1FyN(F28vCQsozeS4ltgH)IrHCA9nKBqQD9tbB1bh2Rdgd(cISKwGu00Y0LwFd5gKAx)uWwDWH96GXAscTv)HD6)zZxXPk5KrWIVmze3K0KeAR(d7GkgtwYBaRaVgont8wSdIHjNc(cICMyRaLjoOIXKLCQeRaTcopqzsI5BUnGvC0JimROzLSKMCkxwzJwwCHn5m)icZkAwjBtsOT6pSdQymzvLCYBaRaFbrotSvGYehuXyYsoRMKqB1FyhuXyYQk5KzixS(6W01gw9h8fe5mXwbktCqfJjlzk1KeAR(d7GkgtwvjNmwrrlWxqKZeBfOmXbvmMSKvEtsOT6pSdQymzvLCY48vMWxqKrrGGCyK5uoFmIIGZDZxX1KeAR(d7GkgtwvjNmetW56nGm4liY4hHHw30rJGneM4LfH2Q)CYfOmzQwn(ryO1nDzEwyft84NLroZjxGYKj81zYUi0MVghLzfMqof81zYUi0MFG9ObJCk4RZKDrOnFbrg)im06MUmplSIjE8ZYiN1K0KeAR(d7GQRW5YsM(FMFf8JSAbEOF9Nqkg5unjH2Q)WoO6kCUSQsozCKjge)(XcFbrgfbcYHJmXG43pw3kJrDystPMKqB1FyhuDfoxwvjNm9wJbZRydlh(cIm1ZfPMo6TgdMxXgwUZknSy)quNm9)5xbAfCUkukBuJPfgZBXoig2rV1yW8k2WYvnfvjW0cJ5Tyhed7O3AmyEfBy5QKIk1QX0cJ5Tyhed7O3AmyEfBy5QqnLunv2SGjN5WbQS2)wUtUaLjtQAscTv)HDq1v4CzvLCYBrdVgont8wSdIHjNc(cI8kqRGZduMKyUi10TfTZknSy)quNm9)5xbAfCUkzITcuM42I2BLgwCcQPgfbcYz1GSypeYcNdHwTAkBLg26gOkb1Oiqqou2)tly)HDi0QvtzlyYzou2)tly)HDYfOmzsLA1u2cMCMdhOYA)B5o5cuMmPkb1yAHX8wSdIHD0BngmVInSCYPuRMYwWKZC0BngmVInSCNCbktMuLG6qBvgXpFZTfn50OwTvAyRBirOTkJ4NV52IMCk1QP8ICc0VdIBUbYqU5Fi)ueAp0RrWQvtzlyYzoCGkR9VL7KlqzYKQMKqB1FyhuDfoxwvjNmoYedIF)yHVGiJIab5WrMyq87hRBLXOomPPw)JOVN(RZWQMIQSLuzlnok1KeAR(d7GQRW5YQk5KHK911JG9OLjWpgKIxozhGJCk41WPzI3IDqmm5unjH2Q)WoO6kCUSQsozizFD9iypAzc8A40mXBXoigMCk4liYOiqqouSVoTdHoHfm5mh(ry(hYB5Ih6xbBo5cuMmvRw)pB(koN(VmpSI3YfpMU2YWUvgJ6WKovc9NrU4m3vd5MhkKMKMKqB1Fy3RGPqImczSflgzhe4liYOiqqUCjwZ)qElx8kk20Hq3KeAR(d7EfmfsKruLCYyKdQwbEwDIxpjR8SnONnjH2Q)WUxbtHezevjN84)huTc8S6eVEsw5zBqpHVGiJIab5g))GTop0VJoe6eyAHX8wSdIHDw(g4CVomsNvckBbtoZXqUy91HPRnS6pNCbktMnjH2Q)WUxbtHezevjNCUeR5FiVLlEffBcFbrwozhGJ0uknjMV52I2TYyuhwfL7GrcQ1)ZMVIZz1GSypeYcNBLXOoSkKtkhmuRErob63bXPdtGt8AKTEQsGIab50mjwDGT6gCyl0Ws6ujOmkceKlOfsXtVYmSFXE9gzQBWHqNGYOiqqou2)tgc2Ci0jOmkceKdf7Rt7qOtqT(F28vCo9FzEyfVLlEmDTLHDRmg1HvjPCWqTAkR)mYfN5UAi38qHqvcQPS(ZixCM7e9(SFNQvR)NnFfNlMbTvzepwrSJUvgJ6WQqggQvpFZfZG2QmIhRi2r)mgJbXTYyuhwfLbvnjH2Q)WUxbtHezevjN84)hS15H(De(cISCYoahPPuAsmFZTfTBLXOoSkk3bJeuR)NnFfNZQbzXEiKfo3kJrDyviRChmuRErob63bXPdtGt8AKTEQsGIab50mjwDGT6gCyl0Ws6ujOmkceKlOfsXtVYmSFXE9gzQBWHqNGYOiqqou2)tgc2Ci0jOMYOiqqouSVoTdHwTA9NrU4m3j69z)otybtoZHJmXG43pwNCbktMjqrGGCOyFDA3kJrDyvskQsqT(F28vCo9FzEyfVLlEmDTLHDRmg1HvjPCWqTAkR)mYfN5UAi38qHqvcQPS(ZixCM7e9(SFNQvR)NnFfNlMbTvzepwrSJUvgJ6WQqggQvpFZfZG2QmIhRi2r)mgJbXTYyuhwfLbvjGQHCZVYyuhwfLrtstsOT6pSdlgcnzgYfRVomDTHv)bFbrw)zKloZDIEF2VZeyAHX8wSdIHDw(g4CVomsR8e6Fe990FDgM0WibLTsdBDdjOmkceKdf7Rt7qOBscTv)HDyXqOvLCY0)Z8RGFKvlWd9R)esXiNQjj0w9h2HfdHwvYjJJmXG43pw4liYwWKZCqYgmp0kxAdNtUaLjZe6)zZxX5GKnyEOvU0gohcDckJIab5WrMyq87hRdHoH(hrFp9xNHvjvI5BUnGvCwPHTUHeupFZXqUy91HPRnS6pNvAyRBqTAkBbtoZXqUy91HPRnS6pNCbktMu1KeAR(d7WIHqRk5KP)N5xb)iRwGVGiBbtoZHY(FAb7pStUaLjZeOiqqou2)tly)HDZxXLGA5KDaovPKdgztozhGZTYGCQsTYtt2qrGGCAMeRoWwDdoeAQOI0uNkfmG5SOu2qrGGC1PJ9cR(ZdBDd(hYB5IpTICdmXHqtvIqBvgXJAEBRHbzXKtttsOT6pSdlgcTQKtwhmMp0w9NNvyd(lgfYOS)NwW(ddp22sBKtbFbr2cMCMdL9)0c2FyNCbktMjqrGGCOS)NwW(d7MVIlb16Fe990FDgM0WqTAmTWyEl2bXWolFdCUxhg5uu1KeAR(d7WIHqRk5K1bJ5dTv)5zf2G)IrHS(F28vCnjH2Q)WoSyi0QsozDWy(qB1FEwHn4VyuidvxHZLfESTL2iNc(cIS(hrFp9xNHvHsjOgfbcYHY(FAb7pSdHwTAkBbtoZHY(FAb7pStUaLjtQAsAscTv)HDytcMLtM(FMFf8JSAbEOF9Nqkg5unjkBdGPbSsdorM4gSpYqodUgaJ0qQ1GhQbLHBatUblVbH1GObJ1vJiJnW(gGrw6aJBaoFLjUbtAPjj0w9h2HnjywUQKtEdyf41WPzI3IDqmm5uWxqKPE(MBdyfh9icZkAwjlPt5GHA1RaTcopqzcvjMlsnDBaR4Ssdl2pe1jt)F(vGwbNRswQvtnTS4cBYz(reMv0SswvMV52awXrpIWSIMvYMafbcYHI91PDi0jW0cJ5Tyhed7S8nW5EDyKMsj0Fg5IZCNO3N97Kk1QrrGGCOyFDA3kJrDysNQjj0w9h2HnjywUQKtMHCX6RdtxBy1FWxqKX0cJ5Tyhed7S8nW5EDyKMsjwbAfCEGYKeZfPMogYfRVomDTHv)5Ssdl2pe1jt)F(vGwbNRcmsqT(hrFp9xNHjRC1QNV5yixS(6W01gw9NBLXOomPHHA1uE(MJHCX6RdtxBy1FoR0Ww3avnjkBdsFrSG1acwGZBqHBaQyMSnWYJRbytcML3aI8vMniSgqPgyXoigUjj0w9h2HnjywUQKtgDrSG5XSaNdFbrgtlmM3IDqmSdDrSG5XSaNRswnjH2Q)WoSjbZYvLCY0)Z8RGFKvlWd9R)esXiNQjj0w9h2HnjywUQKtgNVYe(cIS(hrFp9xNHjTYtGPfgZBXoig2z5BGZ96WinmAsAscTv)HDObloTqgJCq1kWxqKrrGGCIMv0yXJFwSU5R4sGIab5enROXINHCX6MVIlb1RaTcopqzIA1uhARYiE5KXsWQKkrOTkJ4NV5WihuTcPdTvzeVCYyjyQOQjj0w9h2HgS40IQKtgBXIr2bb(cImkceKt0SIglE8ZI1TYyuhwLuPrvDGnVvJIA1OiqqorZkAS4zixSUvgJ6WQKknQQdS5TAuAscTv)HDObloTOk5KXwSq1kWxqKrrGGCIMv0yXZqUyDRmg1HvrhyZB1OOwnkceKt0SIglE8ZI1nFfxc8ZI1lAwrJfvsJA1OiqqorZkAS4Xplw38vCjyixSErZkASaZH2Q)Ck2WYD15Hy1qUr6unjH2Q)Wo0GfNwuLCYk2WYHVGiJIab5enROXIh)SyDRmg1HvrhyZB1OOwnkceKt0SIglEgYfRB(kUemKlwVOzfnwG5qB1FofBy5U68qSAi3ujnCcmTO5uKknuIBCJZba]] )


end
