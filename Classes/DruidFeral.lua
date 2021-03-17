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

        if action == "primal_wrath" then
            local fresh = max( 0, active_enemies - active_dot[ aura ] )
            local dotted = max( 0, active_enemies - fresh )
    
            if remains == 0 then
                fresh = max( 0, fresh - 1 )
            else
                dotted = max( 0, dotted - 1 )
            end

            -- Current target's ticks are based on actual values.
            local total = potential_ticks - remaining_ticks

            -- Fresh enemies just get the application value.
            total = total + fresh * app_ticks

            -- Other dotted enemies could have a different duration for other reasons.
            -- Especially SbT.
            local pw_remains = min( fight_remains, max( state.action.primal_wrath.lastCast + class.abilities.primal_wrath.max_apply_duration - query_time, tick_time ) )

            if remains > pw_remains then
                local pw_ticks = ( pmult and t.pmultiplier or 1 ) * pw_remains / tick_time
                local pw_duration = max( 0, min( pw_remains + class.abilities.primal_wrath.apply_duration, 1.3 * class.abilities.primal_wrath.max_apply_duration, fight_remains ) )
                local pw_potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( pw_duration, fight_remains ) / tick_time

                total = total + dotted * ( pw_potential_ticks - pw_ticks )
            else
                -- Just assume they're the same.
                total = total + dotted * ( potential_ticks - remaining_ticks )
            end

            return max( 0, total )

        elseif action == "thrash" then
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
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", 0.3 )
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
                return talent.balance_affinity.enabled and settings.owlweave_cat or false
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif k == "primal_wrath" then return class.abilities.primal_wrath
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


        rip_and_tear = {
            id = 203242,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function ()
                return 60 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
            end,
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


    spec:RegisterPack( "Feral", 20210317, [[dWubtbqiccpcIQUKGKAtqKpjOkJIu0PifwLGuVIGAwkf3Iav7sOFriggHKJjkwMGYZGOmncsxJazBee9niQ04iKkNJuQyDKsvZJuk3ds2hPKdskvQfkiEOGetKqkAJeOWhfuvAKKsL0jHOIwPO0mjqPBcrf2jKYpfKKHsGIwkHu1tvXuHu9vbvfJvqv1Er6VImyvDyQwmuEmjtwLUmQnRKplQgTaNwYQjKcVgcMnr3wPA3G(nWWjvhNuQelxXZrmDkxhQ2oe67eQXlOY5vkTEcP08jG9l10mu0PNRBmfTWevyzefYYGCJzeDitOHHCPhBRotp6UcbpNPhOVZ0JGbpUKE09TsGFPOtpea(Oy6jWmDI2lIi5LfGJfvGDri1oU0TcavJVmri1Use6bdVKgYjKIrpx3ykAHjQWYikKLb5gfLOtOidzHrpoUfag65u7Hc9eu3ldPy0ZLjk6rWGhx2VO5Gx3olYHpQG(ZGC30FyIkSmD2oRGbpUSFTBbtbB)kh2VljG(X4(xaC4TF36pWmDI2lIi5fXI5LfGJfvGDrc)ou06JlIqk60ocPs0PD0oc5sq(sXcsXzYiOR7iZfLO76RvNTZgkbomNjAFNvW7)o41ncelfZoICs5gQm9RcyfcK(nq)3bVUrGyPy2rKtk3IDwbV)qbarKhR)qqVFDaqMgMaWhf3Vb6xSxw)C40hMqkamspYIyek60dMeaUMlbqcfDkAzOOtpm0XK8Lgc9OMY4PC6rZ(fI(TsHqbZ7xab6xZ(hEnmjWXKC)i1VopKIym0s74sR0Lfp9Rv)xGfhhboQVJlTsxw80Vg9lGa9Rz)UYke5eMLSPYZ5H0pQ(dRFK6xNhsrmgAPDCPv6YIN(1Q)lWIJJah13XLwPllE6xJ(fqG(1SFxzfICcZs2u558q6hv)H1ps9p8AysGJj5(1OFn6hP(XWxRiMLghboEbIH9Ju)3bVUXXrGJwPqGKY9cY3eaMgEnmjOFTq1Fy0JRScaPNXrGPh1wLKtMp5SrOOLHAu0cJIo9WqhtYxAi0JAkJNYPNHxdtcCmj3ps9JHVwrmlTdaWvnC8cedPhxzfasp7aaCvdNuUrpQTkjNmFYzJqrld1OOHmk60ddDmjFPHqpQPmEkNEgEnmjWXKC)i1pg(AfXSKfmojiEbIH9Ju)3bVUrlyCsqs5w0kfcKuUxq(MaW0WRHjb9Rv)A2Vq7x4(j6SuMmFYzJeTGXjbjLB9h6(fA)A0Vi9Rz)z6x4(3DIXZ2eIUeN7xJ(f8(va4fVSO5eJtlWKWKaWnYqhtYx6XvwbG0JfmojiPCJEuBvsoz(KZgHIwgQrrtOu0Phg6ys(sdHEutz8uo9GHVwrmlHn4MltePtcIxGyi94kRaq6bBWnxMisNeqnkAcIIo9WqhtYxAi0JAkJNYPhm81kIzjI4sNJxGyy)i1prNLYK5toBKirCPZjLB9Rv)zOhxzfaspeXLoNuUrnkAcjfD6HHoMKV0qOh1ugpLtpy4RveZsKGHVXlqmKECLvai9qcg(snkAixk60ddDmjFPHqpQPmEkNEWWxRiMLiIlDoEbIH0JRScaPhI4sNtk3OgfnrhfD6HHoMKV0qOh1ugpLtpy4RveZswW4KG4figspUYkaKESGXjbjLBuJA0ZQGfjGhk6u0YqrNEyOJj5lne6rnLXt50dg(AfjoIEoNgGpXH39cs6xB9Jm6XvwbG0dXr0Z50a8HAu0cJIo9WqhtYxAi0JAkJNYPhn7)o41nQp1UltIh3cIwPqGKY9cY3eaMgEnmjOFT6hz9h6(1SFIolLjZNC2ir9P2Dzs84wq)c3FM(1OFK6NOZszY8jNnsuFQDxMepUf0Vw9NPFn6xab6NOZszY8jNnsuFQDxMepUf0Vw9Rz)iRFH7pt)HUFZLm0IehJhdaSGidDmjF7xd6XvwbG0J(u7UmjEClGAu0qgfD6HHoMKV0qOh1ugpLtpdVgMe4ysUFK6)o41noLE0kfcKuUxq(MaW0WRHjb9Rv)i6t5ysooLEYkfcK(rQFn7xZ(XWxROv58qsl8zBexVFbeOFfaiVaXWOv58qsl8zBC4DVGK(1QFb1Vg9Ju)A2pg(AfXKaW1CjasI469lGa9le9BUKHwetcaxZLaijYqhtY3(1OFK6)cS4u6r9DCPv6YIN(1gQ(15HueJHwAhxALUS4PFbeOFHOFZLm0IehJhdaSGidDmjF7xd6XvwbG0Zu60JARsYjZNC2iu0YqnkAcLIo9WqhtYxAi0JAkJNYPhm81ksCe9ConaFIdV7fK0V26xZ(vGDmqshuqJ0VW9NPFn6p09lK9h6(fvez0JRScaPhIJONZPb4d1OOjik60ddDmjFPHqp7E4smKN8Tu0YqpUYkaKEw8aufaNKWkJPh1wLKtMp5SrOOLHAu0esk60ddDmjFPHqpQPmEkNEWWxRigjvqvexVFK63CjdTibGltGvYc40cmmXIm0XK8LECLvai9S4bOkaojHvgtpQTkjNmFYzJqrld1Og9G5shQyk6u0YqrNEyOJj5lne6rnLXt50dg(AfzLS0jCIaK(eVaXW(rQFm81kYkzPt4Keh6t8ced7hP(1S)HxdtcCmj3Vac0VM97kRqKtmK3lM0Vw9NPFK63vwHiNUalsWHRA4(1w)UYke5ed59Ij9Rr)AqpUYkaKEi4Wvnm1OOfgfD6HHoMKV0qOh1ugpLtpy4RvKvYsNWjcq6tC4DVGK(1QFLtSKv7C)ciq)y4RvKvYsNWjjo0N4W7Ebj9Rv)kNyjR2z6XvwbG0dX8HGp5m1OOHmk60ddDmjFPHqpQPmEkNEWWxRiRKLoHtsCOpXH39cs6xR(voXswTZ9lGa9tasFsSsw6eUFT6xu0JRScaPhI5ZQgMAu0ekfD6HHoMKV0qOh1ugpLtpy4RvKvYsNWjcq6tC4DVGK(1QFLtSKv7C)ciq)sCOpjwjlDc3Vw9lk6XvwbG0J4XTaQrn65YlhxAu0POLHIo9WqhtYxAi0JRScaPNbhMCLvaysweJEutz8uo9GHVwXDaaIqbtlWShX17hP(fI(VdEDJaXsXSJiNuUrpYIyjOVZ0dMlDOIPgfTWOOtpm0XK8Lgc9CzIAkDRaq6r7kWcF6puaqebiW0JRScaPhLlLjxzfaMKfXOh1ugpLtp3bVUrGyPy2rKtk3OhzrSe03z6biwkMDezQrrdzu0Phg6ys(sdHEUmrnLUvai9iyoaXY(fhWqgrE6xhqifMKPhxzfasp6dqSKAu0ekfD6HHoMKV0qOh1ugpLtpy4Rvu5wAbM94figspUYkaKESkNhsAHpBPgfnbrrNEyOJj5lne6rnLXt50dg(AfvULwGzpEbIH0JRScaPhLBPfy2PgfnHKIo9WqhtYxAi0ZLjQP0TcaPNqfK7NeaS(jg7slGECLvai9m4WKRScatYIy0JAkJNYPhm81ksc8lq8olVrC9(fqG(XWxRO(aelJ460JSiwc67m9qm2Lwa1OOHCPOtpUYkaKEiiGlLjmNeqpm0XK8Lgc1OOj6OOtpm0XK8Lgc94kRaq6r5szYvwbGjzrm6rwelb9DMEuaG8cedPgfnTdfD6HHoMKV0qOh1ugpLtp3bVUr9P2Dzs84wq0kfcKuUxq(MaW0WRHjb9RfQ(dtu9Ju)kWogiPdkOr6xlu9hg94kRaq6rFQDxMepUfqnkAzeffD6HHoMKV0qOhxzfaspdom5kRaWKSig9OMY4PC6rb2XajDqbns)AHQFn7xq9l49JOpLJj54cGpk9ewzC)AqpYIyjOVZ0ZQGfjGhQrrltgk60ddDmjFPHqpxMOMs3kaKEqoWLwj45QB)eJDPfqpUYkaKEuUuMCLvaysweJEutz8uo9GHVwrmsQGQiUE)ciq)y4RvKGFVmm57y4KGiUo9ilILG(otpeJDPfqnkAzcJIo9WqhtYxAi0JRScaPhXEz0dHv0JM9Rz)zYiO(f8(ddz9h6(XWxRybv(aDRaWecfmpbwjlGtIg4WCjhX17xJ(f8(1SFgYt(2OcFggA9lC)ilkO(dD)mKN8TXHZzy)c3VM9lur1FO7hdFTIkj7JYjwbZJ469Rr)A0Vg9ls)mKN8TXHZzi9CzIAkDRaq6b9aU)DaX6NdNodjfIC)HGE)QTkj3VMOhmmjO)tWW3(pIlDUFfGy9NjJG6NH8KVDt)7ocC)e8H7xm3VYH9V7iW9BbU1Fb7xO9NlbyUKOb9OMY4PC6XCjdTiMeaUMlbqsKHoMKV9Ju)y4RvetcaxZLaijEbIH9Ju)UYke5eMLSPYZ5H0pQ(ff1OOLbzu0Phg6ys(sdHEUmrnLUvai94kRaqs8YlhxAcJseDaqMgMaWhfVPwOmxYqlIjbGR5saKezOJj5lsy4RvetcaxZLaijEbIHiPjd5jFRWilkOqZqEY3ghoNHcRPqfvOXWxROsY(OCIvW8iUUgAOnnZKrqcEyil0y4RvSGkFGUvaycHcMNaRKfWjrdCyUKJ46AGKRScroHzjBQ8CEiOef94kRaq6zWHjxzfaMKfXOh1ugpLtpMlzOfXKaW1CjasIm0XK8TFK6hdFTIysa4AUeajXlqmKEKfXsqFNPhmjaCnxcGeQrrlJqPOtpm0XK8Lgc9OMY4PC6bdFTIUohUK(Wx3adjPghXcMhX1PhxzfasplEaQcGtsyLX0JARsYjZNC2iu0YqnkAzeefD6HHoMKV0qOhxzfasp6aGmnmbGpkMEUmrnLUvai9Go4c0((nMy9BbfPFXLf0)oy4(9lI8q4(jSHRt6xtjNZWRpft20Fo7ZM(nxYqJOr)gO)DhbUFc(W9BbU1VfuK(jMVL0V3)vN0Fbvd7eMEwGjb5Wzu0YqnkAzesk60ddDmjFPHqpQPmEkNE0S)HxdtcCmj3Vac0VopKIym0s74sR0Lfp9Rv)xGfhhboQVJlTsxw80Vg9Ju)3bVUXXrGJwPqGKY9cY3eaMgEnmjOFT6NOZszY8jNnsKiU05KYT(dD)H1VG3Fy0JRScaPNXrGPh1wLKtMp5SrOOLHAu0YGCPOtpm0XK8Lgc9OMY4PC6z41WKahtY9Ju)3bVUXDaaUQHtk3IwPqGKY9cY3eaMgEnmjOFT6NOZszY8jNnsKiU05KYT(dD)H1VG3Fy0JRScaPNDaaUQHtk3Oh1wLKtMp5SrOOLHAu0Yi6OOtpm0XK8Lgc9SatcYHZOOLHECLvai9OdaY0Wea(OyQrrlJ2HIo9WqhtYxAi0JAkJNYPNHxdtcCmj3ps9Fh86gTGXjbjLBrRuiqs5Eb5BcatdVgMe0Vw9Rz)cTFH7NOZszY8jNns0cgNeKuU1FO7xO9Rr)I0VM9NPFH7F3jgpBti6sCUFn6xW7xbGx8YIMtmoTatctca3idDmjFPhxzfaspwW4KGKYn6rTvj5K5toBekAzOgfTWeffD6HHoMKV0qONfysqoCgfTm0JRScaPhDaqMgMaWhftnkAHLHIo9WqhtYxAi0JAkJNYPhn7F86MyezOf97Lely)A1VM9NPFH7F3dxsf4tot6xW7xf4totsRXvwbGUSFn6p09pSkWNCoz1o3Vg9Ju)A2prNLYK5toBKi2GBUmrKojO)q3VRScaJydU5Yer6KG4139CUFr63vwbGrSb3CzIiDsqubiw)A0Vw9Rz)UYkamscg(gV(UNZ9ls)UYkamscg(gvaI1Vg0JRScaPhSb3CzIiDsa1OOfwyu0Phg6ys(sdHEutz8uo9q0zPmz(KZgjsex6Cs5w)A1FM(fUFm81kIrsfufX17p09hg94kRaq6HiU05KYnQrrlmKrrNEyOJj5lne6rnLXt50drNLYK5toBKOfmojiPCRFT6hz0JRScaPhlyCsqs5g1OOfMqPOtpm0XK8Lgc9OMY4PC6bdFTIkj7JYjwbZJ460JRScaPhsWWxQrrlmbrrNEyOJj5lne6rnLXt50dg(AfXiPcQI469Ju)3bVUXXrGJwPqGKY9cY3eaMgEnmjOFT6pm6XvwbG0Z4iW0JARsYjZNC2iu0YqnkAHjKu0Phg6ys(sdHECLvai9OCPm5kRaWKSig9ilILG(otpRsk5HAuJE0hwb2XCJIofTmu0Phg6ys(sdHEa60dHn6XvwbG0dI(uoMKPheDjotpIIEq0Ne03z6zbWhLEcRmMAu0cJIo9WqhtYxAi0dqNEiSrpUYkaKEq0NYXKm9GOlXz6ru0dI(KG(otpRsk5HEUmrnLUvai9Ccg(2pQ(f1M(rdafCc01jbaRFrVJa3pQ(ZSP)d01jbaRFrVJa3pQ(dBt)cwKZ(r1pY20)rCPZ9JQFHsnkAiJIo9WqhtYxAi0dqNEiSrpUYkaKEq0NYXKm9GOlXz6b5spi6tc67m9mLEYkfce65Ye1u6wbG0Zr5sUFXLf0FGtmosnkAcLIo94kRaq6bHcEh(Mi61ugHEyOJj5lneQrrtqu0PhxzfaspyaZK8nTK(w(kUG5jdeUcspm0XK8Lgc1OOjKu0Phg6ys(sdHEutz8uo9GHVwXDaaIqbtlWShVaXq6XvwbG0J(aelPgfnKlfD6HHoMKV0qOh1ugpLtpy4RvChaGiuW0cm7XlqmKECLvai9OClTaZo1Og9SkPKhk6u0YqrNEyOJj5lne6rnLXt50dI(uoMKJRsk5PFu9NPFK6F41WKahtY9Ju)xGfhhboQVJlTsxw80V2q1VopKIym0s74sR0Lfp0JRScaPNXrGPh1wLKtMp5SrOOLHAu0cJIo9WqhtYxAi0JAkJNYPhe9PCmjhxLuYt)O6pm6XvwbG0Z4iWuJIgYOOtpm0XK8Lgc9OMY4PC6brFkhtYXvjL80pQ(rg94kRaq6zhaGRA4KYnQrrtOu0Phg6ys(sdHEutz8uo9GOpLJj54QKsE6hv)cLECLvai9qex6Cs5g1OOjik60JRScaPhsWWx6HHoMKV0qOg1OhIXU0cOOtrldfD6HHoMKV0qONfysqoCgfTm0JRScaPhDaqMgMaWhftnkAHrrNEyOJj5lne6XvwbG0Z4iW0JARsYjZNC2iu0YqpxMOMs3kaKEe9ocC)qMVK(haEEGCB)csuH6(bR(lJ0VKH5wq)U1V3)EbRD89(nq)e8r3jK(jbdFj9F1z6rnLXt50JM9FbwCCe4O(oU0kDzXt)AR)mrb1Vac0)WRHjboMK7xJ(rQ)7Gx344iWrRuiqs5Eb5BcatdVgMe0Vw9hw)ciq)y4RveJKkOko8Uxqs)AR)muJIgYOOtpm0XK8Lgc94kRaq6bBWnxMisNeqpxMOMs3kaKEczWnx2)r6KG(ls)ySz80Vf4W(jg7slO)tWW3(DRFK1V5toBe6rnLXt50drNLYK5toBKi2GBUmrKojOFT6pmQrrtOu0Phg6ys(sdHEwGjb5Wzu0YqpUYkaKE0bazAycaFum1OOjik60ddDmjFPHqpUYkaKEibdFPNltutPBfaspNGHV9Vat)lNy80FOiy2Fod5XTca30VfuK(LfK7Vi9hWoILCB)MlzOjso7JikaIm0Hw)xwNHxgAB6NOxq42(nxYqJ0py6xvJsY9l5CgE9z7M(bt)qwnajyUK(1hEXt)qG1Vb6pWNB)KGHV97sz)wa3Vv7m9OMY4PC6rb2XajDqbns)ARFH2ps9t0zPmz(KZgjAbJtcsk36xB9liQrn6rbaYlqmKIofTmu0Phg6ys(sdHEutz8uo9Oa7yGKoOGgPFT1pY6hP(nFYzlA1oNmq6wC)A1pYLECLvai9S4XLP1Wqr7w6rTvj5K5toBekAzOgfTWOOtpm0XK8Lgc94kRaq6bJhcpiqpxMOMs3kaKEqpujAgQ0((rJ5B)gOFYwOQFXLf0V4Yc6FCeziaN0)AyOODB)Idyy)I5(hCy)RHHI2Tyo8UPFW0VBs2jw)QawHq)1Q)Yi9lgmwq)LrpQPmEkNEuGDmqshuqJ0VwO6hzuJIgYOOtpm0XK8Lgc9OMY4PC6rb2XajDqbns)AHQFKrpUYkaKEkOYhOBfasnkAcLIo9WqhtYxAi0JRScaPhRY5HKw4Zw65Ye1u6wbG0d6Z2(D4TFiW6xStmUF0fm6NH8KVDt)y4w)UKa6x0aNy9Jt4(lR)fy6x0Ydc97WB)fu5dKqpQPmEkNEyip5BJxEvQY6xR(fQO6xab6hdFTIyKubvrC9(fqG(1SFZLm0I6dFDdmrg6ys(2ps9tcaJXelz2TFT1pY6xdQrrtqu0Phg6ys(sdHECLvai9qc8lq8olV0ZLjQP0TcaPhKJkpW6hJ7x8aG59BG(XjC)NDwE7ha7x07iW9xW(rKNT9JipB7hwQaUFsz4Uvaizt)y4w)iYZ2(hFy5w6rnLXt50dg(AfTkNhsAHpBJ469Ju)y4RveJKkOkEbIH9Ju)kWogiPdkOr6xB9l0(rQ)lWIJJah13XLwPllE6xB9NjkK9Ju)mKN8T9Rv)cvuuJIMqsrNEyOJj5lne6rnLXt50dg(AfTkNhsAHpBJ469lGa9JHVwrmsQGQiUo94kRaq6bJhcpiuWCQrrd5srNEyOJj5lne6rnLXt50dg(AfXiPcQI460JRScaPhDGvai1OOj6OOtpm0XK8Lgc9OMY4PC6bdFTIyKubvrC9(fqG(xvEGLgE3liPFT1FyzOhxzfaspJJidb4K0AyOODl1OOPDOOtpm0XK8Lgc94kRaq6rbGicqGtwaNi61ugHEUmrnLUvai9GEOs0muP99hkbScH(3baicfS)aGjUFhE7Ny4Rv)YcbUFlOiB63H3(39TyC)ySz80VcSJ5w)dV7fS)HjBHk6rnLXt50JM9FbwCk94W7Ebj9Rv)cTFK6xb2XajDqbns)ARFK1ps9FbwCCe4OvkekyE)i1pd5jFB8YRsvw)AHQ)Wev)A0Vac0)QYdS0W7Ebj9RT(fe1OOLruu0Phg6ys(sdHECLvai9W76aX8KWaWl9CzIAkDRaq6b5W3IX9Bb8W9tca4YB)yC)7GH7xbG3YkaK0pa2VfW9RaWlEz0JAkJNYPhm81kAvopK0cF2gX17xab6xZ(va4fVS4Lz9KlLCE5qfhzOJj5B)AqnkAzYqrNEyOJj5lne6rnLXt50JcSJbs6GcAK(r1VG6hP(fI(Val6xx3ke5erSp7PRV75C0kfcfmNECLvai94xx3ke5erSp70JARsYjZNC2iu0YqnkAzcJIo94kRaq6bNWPY4Dc9WqhtYxAiuJA0dqSum7iYu0POLHIo9WqhtYxAi0JAkJNYPhm81kgW(yjWkzbCsCjVrCD6XvwbG0dX8HGp5m1OOfgfD6HHoMKV0qOhxzfaspeC4QgMEKfKtQl9i0qNRUuJIgYOOtpm0XK8Lgc9OMY4PC6bdFTI7aaeHcMwGzpIR3ps9Rz)doKxGjNJk34TCsHpfiYqhtY3(fqG(hCiVatohVJJNhyjWkDzwpTakCsKHoMKV9Rr)i1prNLYK5toBKOfmojiPCRFT1Fy0JRScaPNDaaUQHPhzb5K6spcn05Ql1OOjuk60ddDmjFPHqpQPmEkNEyip5B7xB9Jmr1ps9FbwCk94W7Ebj9Rv)cnkO(rQFn7xbaYlqmmAvopK0cF2ghE3liPFTq1Vqgfu)ciq)doKxGjNJk34TCsHpfiYqhtY3(1OFK6hdFTIkj7JYjwbZJeZvi0V26pt)i1Vq0pg(AfDDoCj9HVUbgssnoIfmpIR3ps9le9JHVwrmjaCL4elIR3ps9le9JHVwrmsQGQiUE)i1VM9Raa5figgvaiIae4KfWjIEnLrIdV7fK0Vw9lKrb1Vac0Vq0VcGidDOfHvEGLwo3Vg0JRScaPNa2hlbwjlGtIl5LAu0eefD6HHoMKV0qOh1ugpLtpmKN8T9RT(rMO6hP(ValoLEC4DVGK(1QFHgfu)i1VM9Raa5figgTkNhsAHpBJdV7fK0VwO6xiJcQFbeO)bhYlWKZrLB8woPWNcezOJj5B)A0ps9JHVwrLK9r5eRG5rI5ke6xB9NPFK6xi6hdFTIUohUK(Wx3adjPghXcMhX17hP(fI(XWxRiMeaUsCIfX17hP(fI(XWxRigjvqvexVFK6xZ(vaG8cedJkaeracCYc4erVMYiXH39cs6xR(fYOG6xab6xi6xbqKHo0IWkpWslN7xd6XvwbG0ZoaarOGPfy2Pg1Og9GipKcaPOfMOclJOYGSm0JyFGfmNqpHpA3IE0qorl8v77VF0d4(RDDWy9Vat)H3LxoU0cV(hw7cEn8TFcyN73XnWUB8TFvGdZzsSZkyli3FgTJ23FOaGiYJX3(p1EO0pzl08W1FOUFd0VGf37)wiwKca7hOZJBGPFnfrJ(1mt40i2zfSfK7pSmAF)HcaIipgF7)u7Hs)KTqZdx)H6(nq)cwCV)BHyrkaSFGopUbM(1uen6xZWcNgXoBNn8r7w0JgYjAHVAF)9JEa3FTRdgR)fy6p8WKaW1CjascV(hw7cEn8TFcyN73XnWUB8TFvGdZzsSZkyli3pY0((dfaerEm(2)P2dL(jBHMhU(d19BG(fS4E)3cXIuay)aDECdm9RPiA0VMzcNgXoBNn8r7w0JgYjAHVAF)9JEa3FTRdgR)fy6p8aILIzhro86FyTl41W3(jGDUFh3a7UX3(vbomNjXoRGTGC)it77puaqe5X4B)H3Gd5fyY5y4p863a9hEdoKxGjNJH)idDmjFdV(1mSWPrSZkyli3Vq1((dfaerEm(2F4n4qEbMCog(dV(nq)H3Gd5fyY5y4pYqhtY3WRFnZeonIDwbBb5(fK23FOaGiYJX3(dVbhYlWKZXWF41Vb6p8gCiVatohd)rg6ys(gE9RzMWPrSZ2zro31bJX3(1o97kRaW(LfXiXol9OpGvjz6b5r((fm4XL9lAo41TZI8iF)ih(Oc6pdYDt)HjQWY0z7SipY3VGbpUSFTBbtbB)kh2VljG(X4(xaC4TF36pWmDI2lIi5fXI5LfGJfvGDrc)ou06JlIqk60ocPs0PD0oc5sq(sXcsXzYiOR7iZfLO76RvNTZI8iF)HsGdZzI23zrEKVFbV)7Gx3iqSum7iYjLBOY0VkGviq63a9Fh86gbILIzhroPCl2zrEKVFbV)qbarKhR)qqVFDaqMgMaWhf3Vb6xSxw)C40hMqkam2z7SUYkaKe1hwb2XCtyuIGOpLJj5nqFNrTa4JspHvgVbrxIZOevNf57)em8TFu9lQn9Jgak4eORtcaw)IEhbUFu9Nzt)hORtcaw)IEhbUFu9h2M(fSiN9JQFKTP)J4sN7hv)cTZ6kRaqsuFyfyhZnHrjcI(uoMK3a9Dg1QKsE2GOlXzuIQZI89FuUK7xCzb9h4eJJDwxzfasI6dRa7yUjmkrq0NYXK8gOVZOMspzLcbYgeDjoJc52zDLvaijQpScSJ5MWOebHcEh(Mi61ugPZ6kRaqsuFyfyhZnHrjcgWmjFtlPVLVIlyEYaHRGDwxzfasI6dRa7yUjmkr0hGy5MAHcdFTI7aaeHcMwGzpEbIHDwxzfasI6dRa7yUjmkruULwGzFtTqHHVwXDaaIqbtlWShVaXWoBN1vwbGeudom5kRaWKSi2gOVZOWCPdv8MAHcdFTI7aaeHcMwGzpIRJKqCh86gbILIzhroPCRZI89RDfyHp9hkaiIae4oRRScajcJseLlLjxzfaMKfX2a9DgfqSum7iYBQfQ7Gx3iqSum7iYjLBDwKVFbZbiw2V4agYiYt)6acPWKCN1vwbGeHrjI(ael7SUYkaKimkrSkNhsAHpB3uluy4Rvu5wAbM94fig2zDLvairyuIOClTaZ(MAHcdFTIk3slWShVaXWolY3FOcY9tcaw)eJDPf0zDLvairyuIm4WKRScatYIyBG(oJIySlTGn1cfg(Afjb(fiENL3iUUacGHVwr9biwgX17SUYkaKimkriiGlLjmNe0zDLvairyuIOCPm5kRaWKSi2gOVZOuaG8ced7SUYkaKimkr0NA3LjXJBbBQfQ7Gx3O(u7UmjECliALcbsk3liFtayA41WKaTqfMOqsb2XajDqbnIwOcRZ6kRaqIWOezWHjxzfaMKfX2a9Dg1QGfjGNn1cLcSJbs6GcAeTqPPGeCe9PCmjhxa8rPNWkJ1OZI89JCGlTsWZv3(jg7slOZ6kRaqIWOer5szYvwbGjzrSnqFNrrm2LwWMAHcdFTIyKubvrCDbeadFTIe87LHjFhdNeeX17SiF)OhW9Vdiw)C40ziPqK7pe07xTvj5(1e9GHjb9Fcg(2)rCPZ9RaeR)mzeu)mKN8TB6F3rG7NGpC)I5(voS)DhbUFlWT(ly)cT)CjaZLen6SUYkaKimkre7LTHWkuAQzMmcsWddzHgdFTIfu5d0TcatiuW8eyLSaojAGdZLCexxdbxtgYt(2OcFggAcJSOGcnd5jFBC4CgkSMcvuHgdFTIkj7JYjwbZJ46AOHgIWqEY3ghoNHBQfkZLm0Iysa4AUeajrg6ys(Ieg(AfXKaW1CjasIxGyisUYke5eMLSPYZ5HGsuDwKVFxzfasegLi6aGmnmbGpkEtTqzUKHwetcaxZLaijYqhtYxKWWxRiMeaUMlbqs8cedrstgYt(wHrwuqHMH8KVnoCodfwtHkQqJHVwrLK9r5eRG5rCDn0qBAMjJGe8WqwOXWxRybv(aDRaWecfmpbwjlGtIg4WCjhX11ajxzfICcZs2u558qqjQoRRScajcJsKbhMCLvaysweBd03zuysa4AUeajBQfkZLm0Iysa4AUeajrg6ys(Ieg(AfXKaW1CjasIxGyyN1vwbGeHrjYIhGQa4Kewz8g1wLKtMp5SrqLztTqHHVwrxNdxsF4RBGHKuJJybZJ46DwKVF0bxG23VXeRFlOi9lUSG(3bd3VFrKhc3pHnCDs)Ak5CgE9PyYM(ZzF20V5sgAen63a9V7iW9tWhUFlWT(TGI0pX8TK(9(V6K(lOAyNWDwxzfasegLi6aGmnmbGpkEZcmjihodvMoRRScajcJsKXrG3O2QKCY8jNncQmBQfknhEnmjWXKSacOZdPigdT0oU0kDzXJwxGfhhboQVJlTsxw8Obs3bVUXXrGJwPqGKY9cY3eaMgEnmjqlIolLjZNC2irI4sNtk3cDycEyDwxzfasegLi7aaCvdNuUTrTvj5K5toBeuz2uludVgMe4ysgP7Gx34oaax1WjLBrRuiqs5Eb5BcatdVgMeOfrNLYK5toBKirCPZjLBHombpSoRRScajcJseDaqMgMaWhfVzbMeKdNHktN1vwbGeHrjIfmojiPCBJARsYjZNC2iOYSPwOgEnmjWXKms3bVUrlyCsqs5w0kfcKuUxq(MaW0WRHjbAPPqfMOZszY8jNns0cgNeKuUfAHQrOwZmcV7eJNTjeDjoRHGRaWlEzrZjgNwGjHjbGBKHoMKVDwxzfasegLi6aGmnmbGpkEZcmjihodvMoRRScajcJseSb3CzIiDsWMAHsZXRBIrKHw0VxsSGAPzgH39WLub(KZebxf4totsRXvwbGUuJqpSkWNCoz1oRbsAs0zPmz(KZgjIn4MltePtccTRScaJydU5Yer6KG4139Cou7kRaWi2GBUmrKojiQaetdT00vwbGrsWW34139Cou7kRaWijy4BubiMgDwxzfasegLieXLoNuUTPwOi6SuMmFYzJejIlDoPCtRmcJHVwrmsQGQiUEOdRZ6kRaqIWOeXcgNeKuUTPwOi6SuMmFYzJeTGXjbjLBAHSoRRScajcJsesWW3n1cfg(Afvs2hLtScMhX17SUYkaKimkrghbEJARsYjZNC2iOYSPwOWWxRigjvqvexhP7Gx344iWrRuiqs5Eb5BcatdVgMeOvyDwxzfasegLikxktUYkamjlITb67mQvjL80z7SUYkaKeXKaW1Cjasqnoc8g1wLKtMp5SrqLztTqPPqyLcHcMlGaAo8AysGJjzK05HueJHwAhxALUS4rRlWIJJah13XLwPllE0qab00vwHiNWSKnvEopeuHHKopKIym0s74sR0LfpADbwCCe4O(oU0kDzXJgciGMUYke5eMLSPYZ5HGkmKgEnmjWXKSgAGeg(AfXS04iWXlqmeP7Gx344iWrRuiqs5Eb5BcatdVgMeOfQW6SUYkaKeXKaW1CjasegLisCOpPcs0RXTca3O2QKCY8jNncQmBQfQHxdtcCmjJeg(AfXS0oaax1WXlqmSZ6kRaqsetcaxZLairyuIybJtcsk32O2QKCY8jNncQmBQfQHxdtcCmjJeg(AfXSKfmojiEbIHiDh86gTGXjbjLBrRuiqs5Eb5BcatdVgMeOLMcvyIolLjZNC2irlyCsqs5wOfQgHAnZi8UtmE2Mq0L4SgcUcaV4LfnNyCAbMeMeaUrg6ys(2zDLvaijIjbGR5saKimkrWgCZLjI0jbBQfkm81kIzjSb3CzIiDsq8ced7SUYkaKeXKaW1CjasegLieXLoNuUTPwOWWxRiMLiIlDoEbIHir0zPmz(KZgjsex6Cs5Mwz6SUYkaKeXKaW1CjasegLiKGHVBQfkm81kIzjsWW34fig2zDLvaijIjbGR5saKimkriIlDoPCBtTqHHVwrmlrex6C8ced7SUYkaKeXKaW1CjasegLiwW4KGKYTn1cfg(AfXSKfmojiEbIHD2oRRScajrfaiVaXqulECzAnmu0UDJARsYjZNC2iOYSPwOuGDmqshuqJOnKHK5toBrR25Kbs3I1c52zr((rpujAgQ0((rJ5B)gOFYwOQFXLf0V4Yc6FCeziaN0)AyOODB)Idyy)I5(hCy)RHHI2Tyo8UPFW0VBs2jw)QawHq)1Q)Yi9lgmwq)L1zDLvaijQaa5figkmkrW4HWdcBQfkfyhdK0bf0iAHczDwxzfasIkaqEbIHcJsKcQ8b6wbGBQfkfyhdK0bf0iAHczDwKVF0NT97WB)qG1VyNyC)Oly0pd5jF7M(XWT(Djb0VOboX6hNW9xw)lW0VOLhe63H3(lOYhiPZ6kRaqsubaYlqmuyuIyvopK0cF2UPwOyip5BJxEvQY0sOIsabWWxRigjvqvexxab00CjdTO(Wx3atKHoMKVircaJXelz2vBitJolY3pYrLhy9JX9lEaW8(nq)4eU)ZolV9dG9l6De4(ly)iYZ2(rKNT9dlva3pPmC3kaKSPFmCRFe5zB)JpSCBN1vwbGKOcaKxGyOWOeHe4xG4DwE3uluy4Rv0QCEiPf(SnIRJeg(AfXiPcQIxGyiskWogiPdkOr0Mqr6cS44iWr9DCPv6YIhTLjkKiXqEY3QLqfvN1vwbGKOcaKxGyOWOebJhcpiuW8n1cfg(AfTkNhsAHpBJ46ciag(AfXiPcQI46DwxzfasIkaqEbIHcJseDGva4MAHcdFTIyKubvrC9oRRScajrfaiVaXqHrjY4iYqaojTggkA3UPwOWWxRigjvqvexxabwvEGLgE3lirBHLPZI89JEOs0muP99hkbScH(3baicfS)aGjUFhE7Ny4Rv)YcbUFlOiB63H3(39TyC)ySz80VcSJ5w)dV7fS)HjBHQoRRScajrfaiVaXqHrjIcareGaNSaor0RPmYMAHsZlWItPhhE3lirlHIKcSJbs6GcAeTHmKUaloocC0kfcfmhjgYt(24LxLQmTqfMO0qabwvEGLgE3lirBcQZI89JC4BX4(TaE4(jbaC5TFmU)DWW9RaWBzfas6ha73c4(va4fVSoRRScajrfaiVaXqHrjcVRdeZtcdaVBQfkm81kAvopK0cF2gX1fqanva4fVS4Lz9KlLCE5qfhzOJj5RgDwxzfasIkaqEbIHcJse)66wHiNiI9zFJARsYjZNC2iOYSPwOuGDmqshuqJGsqijexGf9RRBfICIi2N90139CoALcHcM3zDLvaijQaa5figkmkrWjCQmEN0z7SUYkaKexLuYdQXrG3O2QKCY8jNncQmBQfke9PCmjhxLuYdQmin8AysGJjzKUaloocCuFhxALUS4rBO05HueJHwAhxALUS4PZ6kRaqsCvsjpcJsKXrG3ului6t5ysoUkPKhuH1zDLvaijUkPKhHrjIeh6tQGe9ACRaWn1cfI(uoMKJRsk5bfY6SUYkaKexLuYJWOeHiU05n1cfI(uoMKJRsk5bLq7SUYkaKexLuYJWOeHem8TZ2zDLvaijUkyrc4bfXr0Z50a8ztTqHHVwrIJONZPb4tC4DVGeTHSoRRScajXvblsapcJse9P2Dzs84wWMAHsZ7Gx3O(u7UmjECliALcbsk3liFtayA41WKaTqwO1KOZszY8jNnsuFQDxMepUfiCgnqIOZszY8jNnsuFQDxMepUfOvgneqaIolLjZNC2ir9P2Dzs84wGwAImHZeAZLm0IehJhdaSGidDmjF1OZ6kRaqsCvWIeWJWOezk9nQTkjNmFYzJGkZMAHA41WKahtYiDh86gNspALcbsk3liFtayA41WKaTq0NYXKCCk9KvkeiiPPMy4Rv0QCEiPf(SnIRlGakaqEbIHrRY5HKw4Z24W7EbjAjinqstm81kIjbGR5saKeX1fqaHWCjdTiMeaUMlbqsKHoMKVAG0fyXP0J674sR0LfpAdLopKIym0s74sR0LfpciGqyUKHwK4y8yaGfezOJj5RgDwxzfasIRcwKaEegLiehrpNtdWNn1cfg(AfjoIEoNgGpXH39cs0MMkWogiPdkOreoJgHwidTOIiRZ6kRaqsCvWIeWJWOezXdqvaCscRmEZUhUed5jFlQmBuBvsoz(KZgbvMoRRScajXvblsapcJsKfpavbWjjSY4nQTkjNmFYzJGkZMAHcdFTIyKubvrCDKmxYqlsa4YeyLSaoTadtSidDmjF7SDwxzfasIaXsXSJiJIy(qWNCEtTqHHVwXa2hlbwjlGtIl5nIR3zDLvaijcelfZoISWOeHGdx1WBKfKtQlkHg6C1TZ6kRaqseiwkMDezHrjYoaax1WBKfKtQlkHg6C1DtTqHHVwXDaaIqbtlWShX1rsZbhYlWKZrLB8woPWNciGadoKxGjNJ3XXZdSeyLUmRNwafordKi6SuMmFYzJeTGXjbjLBAlSoRRScajrGyPy2rKfgLibSpwcSswaNexY7MAHIH8KVvBituiDbwCk94W7EbjAj0OGqstfaiVaXWOv58qsl8zBC4DVGeTqjKrbjGadoKxGjNJk34TCsHpfqdKWWxROsY(OCIvW8iXCfcAldscbg(AfDDoCj9HVUbgssnoIfmpIRJKqGHVwrmjaCL4elIRJKqGHVwrmsQGQiUosAQaa5figgvaiIae4KfWjIEnLrIdV7fKOLqgfKaciekaIm0Hwew5bwA5SgDwxzfasIaXsXSJilmkr2baicfmTaZ(MAHIH8KVvBituiDbwCk94W7EbjAj0OGqstfaiVaXWOv58qsl8zBC4DVGeTqjKrbjGadoKxGjNJk34TCsHpfqdKWWxROsY(OCIvW8iXCfcAldscbg(AfDDoCj9HVUbgssnoIfmpIRJKqGHVwrmjaCL4elIRJKqGHVwrmsQGQiUosAQaa5figgvaiIae4KfWjIEnLrIdV7fKOLqgfKaciekaIm0Hwew5bwA5SgD2oRRScajrIXU0cqPdaY0Wea(O4nlWKGC4muz6SiF)IEhbUFiZxs)dappqUTFbjQqD)Gv)Lr6xYWClOF3637FVG1o(E)gOFc(O7es)KGHVK(V6CN1vwbGKiXyxAbcJsKXrG3O2QKCY8jNncQmBQfknValoocCuFhxALUS4rBzIcsabgEnmjWXKSgiDh86ghhboALcbsk3liFtayA41WKaTctabWWxRigjvqvC4DVGeTLPZI89hYGBUS)J0jb9xK(XyZ4PFlWH9tm2Lwq)NGHV97w)iRFZNC2iDwxzfasIeJDPfimkrWgCZLjI0jbBQfkIolLjZNC2irSb3CzIiDsGwH1zDLvaijsm2LwGWOerhaKPHja8rXBwGjb5WzOY0zr((pbdF7FbM(xoX4P)qrWS)CgYJBfaUPFlOi9lli3Fr6pGDel52(nxYqtKC2hruaezOdT(VSodVm020prVGWT9BUKHgPFW0VQgLK7xY5m86Z2n9dM(HSAasWCj9Rp8IN(HaRFd0FGp3(jbdF73LY(TaUFR25oRRScajrIXU0cegLiKGHVBQfkfyhdK0bf0iAtOir0zPmz(KZgjAbJtcsk30MG6SDwxzfasIyU0HkgfbhUQH3uluy4RvKvYsNWjcq6t8cedrcdFTISsw6eojXH(eVaXqK0C41WKahtYciGMUYke5ed59IjALbjxzfIC6cSibhUQH1MRScroXqEVyIgA0zDLvaijI5shQyHrjcX8HGp58MAHcdFTISsw6eorasFIdV7fKOLYjwYQDwabWWxRiRKLoHtsCOpXH39cs0s5elz1o3zDLvaijI5shQyHrjcX8zvdVPwOWWxRiRKLoHtsCOpXH39cs0s5elz1olGaeG0NeRKLoH1suDwxzfasIyU0HkwyuIiEClytTqHHVwrwjlDcNiaPpXH39cs0s5elz1olGasCOpjwjlDcRLOOhIoROOLruiJAuJsb]] )


end
