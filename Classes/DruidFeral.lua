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


    spec:RegisterPack( "Feral", 20210321, [[dW0BCbqiIQ8iiP6sIkP2Ki6tqsyuivDkKkRsurVIO0SGe3csk7sWViQmmIIoMkXYebptLutdjvxtLKTruv(gKKACefY5evswNOcMhsk3dsTpKWbfviTqrOhkQetKOQInsuq(irvLmsIQk1jjkqRuLYmjku3esIANir)uuHAOefGLsuv1tHyQijFvuHySqsK9s4VcnyqhMYIr4XKAYk6YO2Sk(SOmAr60swnrb1RvOMnj3wb7wv)gy4e54efqlxQNd10P66iA7kKVJugVOsDEvQwpKKmFrv7xPfxeujqMMZcktqMjCrMxNWLqcY8QRPUmsG43LybIKPhBzSa5TbwGidXTPeis2DfWMcQeiyazRzbsQ7s4Cqo5YkpLKiObdYHRbsL5f41TDC5W1GwobcbzPCzWxqiqMMZcktqMjCrMxNWLqcY8QRVGQfigPNcAbcsnKlcK0Ao5xqiqMmwlqKH42ulu(PjR5Edv2AD6ct4cklmbzMWL92EtgIBtTWCuzaY4fQTFHMcdwibVWdG8Nl08fM6UeohKtUSc7HSYtjjcAWGCOs2JQS2Kt(Kr5k5tlJYv5k57CLD08vA(YLRMMDTjtz00oN92ElxsTpJX5WEd1w4SjRzaqtrJTrCuBo6lluNY6X4f6GfoBYAga0u0yBeh1Mh2BO2cZfWpIBFHjs1cLaavSzmGS18cDWcPzLVqo3snJXf4dcevHDSGkbcHcaMUPapwqLGYlcQei8BekEksuGyAVaVaPTXSar3LZDzce6xO8wOx6X1NTW85xi9lS5tZ4uJqXlm5cL4gxyNFpoqQ8ssvCVqkw4e4H2gZbPbsLxsQI7fs3cZNFH0Vqt71ios4rVRSmUXle9ctyHjxOe34c787XbsLxsQI7fsXcNap02yoinqQ8ssvCVq6wy(8lK(fAAVgXrcp6DLLXnEHOxyclm5cB(0mo1iu8cPBH0TWKlKG8CceESTXCycO9lm5cNnzndTnMdEPhJJzw98mc(yZNMXPlKc0lmbbI(UwXr36m2XckViCbLjiOsGWVrO4PirbIP9c8cef5BDSESu1MxGxGO7Y5UmbsZNMXPgHIxyYfsqEobcpoaa)PAomb0EbI(UwXr36m2XckViCbLxlOsGWVrO4PirbIP9c8cepTnCAuBUar3LZDzcKMpnJtncfVWKlKG8CceE0tBdNgMaA)ctUWztwZGN2gonQnp4LEmoMz1ZZi4JnFAgNUqkwi9lK6lu2fILyLk6wNXoo4PTHtJAZxyoxi1xiDluUfs)cVSqzx4GHDUVhhzksEH0TquBHAWpjlp4g254b0rcfamd8BekEkq031ko6wNXowq5fHlOK6cQei8BekEksuGO7Y5Umbcb55ei8irt6MkIvgonmb0EbIP9c8ceIM0nveRmCQWfuELGkbc)gHINIefi6UCUltGqqEobcpIPvsCycO9lm5cXsSsfDRZyhhW0kjoQnFHuSWlcet7f4fiyALeh1MlCbLYNGkbc)gHINIefi6UCUltGqqEobcpItBEgMaAVaX0EbEbcoT5PWfuIQfujq43iu8uKOar3LZDzcecYZjq4rmTsIdtaTxGyAVaVabtRK4O2CHlOugjOsGWVrO4PirbIUlN7YeieKNtGWJEAB40Weq7fiM2lWlq802WPrT5cx4cKt9foLBbvckViOsGWVrO4PirbIUlN7YeieKNtaBJSmo2aRdnpy1Jxi1w41cet7f4fiyBKLXXgyTWfuMGGkbc)gHINIefi6UCUltGq)cNnzndsDnyQiT280Gx6X4yMvppJGp28PzC6cPyHxVWCUq6xiwIvQOBDg74GuxdMksRnpDHYUWllKUfMCHyjwPIU1zSJdsDnyQiT280fsXcVSq6wy(8lelXkv0ToJDCqQRbtfP1MNUqkwi9l86fk7cVSWCUq3u87bSrWTdaEAGFJqXZfsNaX0EbEbIuxdMksRnpv4ckVwqLaHFJqXtrIcet7f4fiDjjq0D5CxMaP5tZ4uJqXlm5cNnzndDjf8spghZS65ze8XMpnJtxiflCK1LrO4qxsrV0JXlm5cPFH0VqcYZj4vg344HSVhiLwy(8ludaQjG2h8kJBC8q23dnpy1Jxifl8Qfs3ctUq6xib55eiuaW0nf4XbsPfMp)cL3cDtXVhiuaW0nf4Xb(ncfpxiDlm5cNap0LuqAGu5LKQ4EHud9cL4gxyNFpoqQ8ssvCVW85xO8wOBk(9a2i42bapnWVrO45cPtGOVRvC0ToJDSGYlcxqj1fujq43iu8uKOar3LZDzcecYZjGTrwghBG1HMhS6XlKAlK(fQbdeGOeOEhVqzx4Lfs3cZ5cLVfMZfkZW1cet7f4fiyBKLXXgyTWfuELGkbc)gHINIefidwUJ8ZD2DbLxeiM2lWlqoCd0fGehjkNfi67AfhDRZyhlO8IWfukFcQei8BekEksuGyAVaVa5WnqxasCKOCwGO7Y5Umbcb55eiWX61bsPfMCHUP43dyaPkcorpLJhqZypWVrO4ParFxR4OBDg7ybLxeUWfieMYEnlOsq5fbvce(ncfpfjkq0D5CxMaHG8CcSwvsyoIbkRdtaTFHjxib55eyTQKWCur(whMaA)ctUq6xyZNMXPgHIxy(8lK(fAAVgXr(5HIXlKIfEzHjxOP9AehNapGj)t18cP2cnTxJ4i)8qX4fs3cPtGyAVaVabt(NQzHlOmbbvce(ncfpfjkq0D5CxMaHG8CcSwvsyoIbkRdnpy1JxifluByp61aVW85xib55eyTQKWCur(whAEWQhVqkwO2WE0RbwGyAVaVab7wJj7mw4ckVwqLaHFJqXtrIceDxo3LjqiipNaRvLeMJkY36qZdw94fsXc1g2JEnWlmF(fIbkRJSwvsyEHuSqzkqmTxGxGGDRpvZcxqj1fujq43iu8uKOar3LZDzcecYZjWAvjH5igOSo08GvpEHuSqTH9Oxd8cZNFHkY36iRvLeMxifluMcet7f4fi0AZtfUWfit(yKkxqLGYlcQei8BekEksuGO7Y5Umbcb55egaGFC9XdOhcKslm5cL3cNnzndaAkASnIJAZfiM2lWlqAYpAAVaFuvyxGOkShFBGfieMYEnlCbLjiOsGWVrO4PirbYKX6UK8c8ce53aphzH5c4hbgZcet7f4fiAtPIM2lWhvf2fi6UCUltGmBYAga0u0yBeh1Mlquf2JVnWceanfn2gXcxq51cQei8BekEksuGmzSUljVaVargqdOPwiTu(5rCVqjagxekwGyAVaVarQb0ucxqj1fujq43iu8uKOar3LZDzcecYZjOnpEa9qycO9cet7f4fiELXnoEi77cxq5vcQei8BekEksuGO7Y5Umbcb55e0MhpGEimb0EbIP9c8ceT5XdOheUGs5tqLaHFJqXtrIcKjJ1Dj5f4fi54Nxiof4le7SP8ubIP9c8cKM8JM2lWhvf2fi6UCUltGqqEobCQnb0gy1mqkTW85xib55eKAanvGusGOkShFBGfiyNnLNkCbLOAbvcet7f4fi4XKkvKWWPce(ncfpfjkCbLYibvce(ncfpfjkqmTxGxGOnLkAAVaFuvyxGOkShFBGfiAaqnb0EHlOmxjOsGWVrO4PirbYKX6UK8c8cekzDduGEMdlmxmSVWRxiOxi1xOgmqawOeOEFHDjHxi4xiU(mfVq36m2xiG0X1Kxi4SqcUXCpEHGEHtYU(SfsWnM7XlSol8WTPw4P5hvDFHfEHKsbbIUlN7YeiAWi(T3dpRBGc0ZfMCHyjwPIU1zSJdEAB40O28fIEHxwyYfQbdeGOeOEhVqkwyclm5cB(0mo1iu8ctUWztwZqxsbV0JXXmREEgbFS5tZ40fsXchzDzeko0Lu0l9y8ctUq6xO8wib55eiWX61bsPfMp)c1aGAcO9bcCSEDGuAH5ZVq6xib55eiWX61bsPfMCHAaqnb0(WHBtfpn)OQ7bsPfs3cPtGyAVaVaPljHlO8Imfujq43iu8uKOar3LZDzcenyGaeLa174fsb6fs)cVAHO2chzDzekoCaKTwksuoVq6eiM2lWlqAYpAAVaFuvyxGOkShFBGfiN6lCk3cxq5LlcQei8BekEksuGO7Y5UmbYSjRzqQRbtfP1MNg8spghZS65ze8XMpnJtxifOxycYCHjxOgmqaIsG6D8cPa9ctqGyAVaVarQRbtfP1MNkqu1Zr9uGCLWfuEjbbvce(ncfpfjkqMmw3LKxGxGGktQ8c1Y0ZfID2uEQaX0EbEbI2uQOP9c8rvHDbIUlN7YeieKNtGahRxhiLwy(8lKG8CcyY5K)OnqqItdKscevH94BdSab7SP8uHlO8Y1cQei8BekEksuGmzSUljVaVaHQuEHdaSVqo3s8JRr8ctKQfQVRv8cPNQ0MXPlejT55crOvs8c1aSVWlxUAH8ZD2Duw4GnMxiMS5fsJxO2(foyJ5f6PMVW6xi1xyMcqykmDcemRfi0Vq6x4LlxTquBHjC9cZ5cjipNq9ARFZlWhhxFweCIEkhLHj)mfhiLwiDle1wi9lKFUZUh0KDZVVqzx41HRwyoxi)CNDp0Cg)lu2fs)cPUmxyoxib55e0k2ATH96ZcKslKUfs3cPBHYTq(5o7EO5m(fiM2lWlqOzLlq0D5CxMaXnf)EGqbat3uGhh43iu8CHjxib55eiuaW0nf4XHjG2VWKl00EnIJeE07klJB8crVqzkCbLxOUGkbc)gHINIefitgR7sYlWlqmTxGhhM8XivUSOLtcauXMXaYwZOuh0UP43dekay6Mc84a)gHINjjipNaHcaMUPapomb0(K0Zp3z3L96Wv5KFUZUhAoJFzPN6YmNeKNtqRyR1g2RplqkrhDuJ(lxUc1s46CsqEoH61w)MxGpoU(Si4e9uokdt(zkoqkrxst71ios4rVRSmUXOLPaX0EbEbst(rt7f4JQc7ceDxo3LjqCtXVhiuaW0nf4Xb(ncfpxyYfsqEobcfamDtbECycO9cevH94BdSaHqbat3uGhlCbLxUsqLaHFJqXtrIcet7f4fihUb6cqIJeLZceDxo3LjqiipNGjX5ok180CqJJ62gvFwGusGOVRvC0ToJDSGYlcxq5f5tqLaHFJqXtrIcet7f4fisaGk2mgq2AwGmzSUljVaVaHkWeKdl0zSVqpTWlKw5PlCa08cT5iUX8cXStkHxi9koJ)P1fJrzHzS1OSq3u87y6wOdw4GnMxiMS5f6PMVqpTWle72D8cTfoLWlSEDZgMfihqhFo3UGYlcxq5fuTGkbc)gHINIefiM2lWlqABmlq0D5CxMaH(f28PzCQrO4fMp)cL4gxyNFpoqQ8ssvCVqkw4e4H2gZbPbsLxsQI7fs3ctUWztwZqBJ5Gx6X4yMvppJGp28PzC6cPyHyjwPIU1zSJdyALeh1MVWCUWewiQTWeei67AfhDRZyhlO8IWfuErgjOsGWVrO4PirbIP9c8cef5BDSESu1MxGxGO7Y5UmbsZNMXPgHIxyYfoBYAguKV1X6XsvBEb(Gx6X4yMvppJGp28PzC6cPyHyjwPIU1zSJdyALeh1MVWCUWewiQTWeei67AfhDRZyhlO8IWfuEjxjOsGWVrO4PirbYb0XNZTlO8IaX0EbEbIeaOInJbKTMfUGYeKPGkbc)gHINIefiM2lWlq802WPrT5ceDxo3LjqA(0mo1iu8ctUWztwZGN2gonQnp4LEmoMz1ZZi4JnFAgNUqkwi9lK6lu2fILyLk6wNXoo4PTHtJAZxyoxi1xiDluUfs)cVSqzx4GHDUVhhzksEH0TquBHAWpjlp4g254b0rcfamd8BekEUquBHAWi(T3dpRBGc0tbI(UwXr36m2XckViCbLjCrqLaHFJqXtrIcKdOJpNBxq5fbIP9c8cejaqfBgdiBnlCbLjKGGkbc)gHINIefi6UCUltGq)cBRMrEe)EWMtCO(fsXcPFHxwOSlCWYDuNADgJxiQTqDQ1zmoEAt7f4n1cPBH5CHnRtToJJEnWlKUfMCH0VqSeRur36m2XbIM0nveRmC6cZ5cnTxGpq0KUPIyLHtdtBWY4fk3cnTxGpq0KUPIyLHtdAa2xiDlKIfs)cnTxGpGtBEgM2GLXluUfAAVaFaN28mObyFH0jqmTxGxGq0KUPIyLHtfUGYeUwqLaHFJqXtrIceDxo3LjqWsSsfDRZyhhW0kjoQnFHuSWllu2fsqEobcCSEDGuAH5CHjiqmTxGxGGPvsCuBUWfuMa1fujq43iu8uKOar3LZDzceSeRur36m2XbpTnCAuB(cPyHxlqmTxGxG4PTHtJAZfUGYeUsqLaHFJqXtrIceDxo3LjqiipNGwXwRnSxFwGusGyAVaVabN28u4cktq(eujq43iu8uKOaX0EbEbsBJzbIUlN7YeieKNtGahRxhiLwyYfoBYAgABmh8spghZS65ze8XMpnJtxiflmbbI(UwXr36m2XckViCbLjGQfujq43iu8uKOaX0EbEbI2uQOP9c8rvHDbIQWE8TbwGCkLIBHlCbIuZAWaH5cQeuErqLaHFJqXtrIceGKabZUaX0EbEbYiRlJqXcKrMIKfiYuGmY64BdSa5aiBTuKOCw4cktqqLaHFJqXtrIceGKabZUaX0EbEbYiRlJqXcKrMIKfiYuGmzSUljVaVabjT55crVqzIYcPe8Og(njCkWxO83gZle9cVGYcrEtcNc8fk)TX8crVWeqzHYyzWfIEHxJYcrOvs8crVqQlqgzD8TbwGCkLIBHlO8Abvce(ncfpfjkqascem7cet7f4fiJSUmcflqgzkswGGQfitgR7sYlWlqq0MIxiTYtxyQHDoiqgzD8TbwG0Lu0l9ySWfusDbvcet7f4fiJRF28mILQUCSaHFJqXtrIcxq5vcQeiM2lWlqiaUR4z8OS78Kw9zrhK76fi8BekEksu4ckLpbvce(ncfpfjkq0D5CxMaHG8CcdaWpU(4b0dHjG2lqmTxGxGi1aAkHlOevlOsGWVrO4PirbIUlN7YeieKNtyaa(X1hpGEimb0EbIP9c8ceT5XdOheUWfiNsP4wqLGYlcQei8BekEksuGyAVaVaPTXSar3LZDzcKrwxgHIdNsP4EHOx4LfMCHnFAgNAekEHjx4e4H2gZbPbsLxsQI7fsn0luIBCHD(94aPYljvXTarFxR4OBDg7ybLxeUGYeeujq43iu8uKOar3LZDzcKrwxgHIdNsP4EHOxyccet7f4fiTnMfUGYRfujq43iu8uKOar3LZDzcKrwxgHIdNsP4EHOx41cet7f4fikY36y9yPQnVaVWfusDbvce(ncfpfjkq0D5CxMazK1LrO4WPukUxi6fsDbIP9c8cemTsIJAZfUGYReujqmTxGxGGtBEkq43iu8uKOWfUab7SP8ubvckViOsGWVrO4PirbYb0XNZTlO8IaX0EbEbIeaOInJbKTMfUGYeeujq43iu8uKOaX0EbEbsBJzbI(UwXr36m2XckViq0D5CxMaH(fobEOTXCqAGu5LKQ4EHuBHxcxTW85xyZNMXPgHIxiDlm5cNnzndTnMdEPhJJzw98mc(yZNMXPlKIfMWcZNFHeKNtGahRxhAEWQhVqQTWlcKjJ1Dj5f4fiYFBmVWN5jEHnGmlvDFHxjZC9cbNfwoEHk(Z80fA(cTfouFnqoSqhSqmzlzy8cXPnpXlCkXcxq51cQei8BekEksuGO7Y5UmbcwIvQOBDg74GN2gonQnFHuBHxVWKlS5tZ4uJqXlm5cNnzndkY36y9yPQnVaFWl9yCmZQNNrWhB(0moDHuSWRwyYfs)c1GbcqucuVJxi6fs9fMp)cNapOiFRJ1JLQ28c8HMhS6XlKAl8QfMp)cL3cNapOiFRJ1JLQ28c8bV0JRpBH0jqmTxGxGOiFRJ1JLQ28c8cxqj1fujq43iu8uKOaX0EbEbcrt6MkIvgovGmzSUljVaVajXM0n1crugoDHfEHeS7CVqp1(fID2uE6crsBEUqZx41l0ToJDSar3LZDzceSeRur36m2XbIM0nveRmC6cPyHjiCbLxjOsGWVrO4PirbYb0XNZTlO8IaX0EbEbIeaOInJbKTMfUGs5tqLaHFJqXtrIceDxo3Ljq0GbcqucuVJxi1wi1xyYfILyLk6wNXoo4PTHtJAZxi1w4vcet7f4fi40MNcx4cenaOMaAVGkbLxeujq43iu8uKOarGqp9YBc8GnnjVgXrmnRhItBWY4Gx6X1NLp)e4bBAsEnIJyAwpeN2GLXHMhS6Xulb6ss)e4bBAsEnIJyAwpeN2GLXbSB6Xu7685L3e4bBAsEnIJyAwpetztfWUPhtXf6skpt7f4d20K8AehX0SEiMYMkuF8OQSupP8mTxGpyttYRrCetZ6H40gSmouF8OQSupP8mTxGpyttYRrCetZ6Hq9XJQYsD6s6wNXEWRbo6G4SykUkFEt71ioYppumMIeskVjWd20K8AehX0SEioTblJdEPhxFws(5o7o1U(QKU1zSh8AGJoiolMIReiM2lWlqSPj51ioIPz9GarFxR4OBDg7ybLxeUGYeeujq43iu8uKOar3LZDzcenyGaeLa174fsTfE9ctUq36m2dEnWrheNfVqkwiQEHjxO8wOgautaTp4vg344HSVhiLwy(8l8uzPES5bRE8cP2cLrlm5cpvwQhBEWQhVqkwyccet7f4fihUnv808JQUlCbLxlOsGWVrO4PirbIP9c8cecUXCpwGmzSUljVaVaHQCS8toohwiLmpxOdwi((RxiTYtxiTYtxyBJ4hqIx4P5hvDFH0s5FH04f2K)cpn)OQ7e2przHGEHMRyd7luNY6XlSolSC8cPbApDHLlq0D5CxMardgiarjq9oEHuGEHxlCbLuxqLaHFJqXtrIceDxo3Ljq0GbcqucuVJxifOx41cet7f4fi1RT(nVaVWfuELGkbc)gHINIefiM2lWlq8kJBC8q23fitgR7sYlWlqOQVVq7Nl8b(cPzyNxivYqlKFUZUJYcji9fAkmyHYWKyFHKyEHLVWdOxiQI7Xl0(5cRxB9Jfi6UCUltGWp3z3dt(u6YxiflK6YCH5ZVqcYZjqGJ1RdKslmF(fs)cDtXVhKAEAoOd8BekEUWKleNcANXE095cP2cVEH0jCbLYNGkbc)gHINIefiM2lWlqWP2eqBGvtbYKX6UK8c8ceu5kl1xibVqAn4ZwOdwijMxiYaRMle8lu(BJ5fw)chX99foI77l8lDkVqC5KMxGhJYcji9foI77lSTMv3fi6UCUltGqqEobVY4ghpK99aP0ctUqcYZjqGJ1RdtaTFHjxOgmqaIsG6D8cP2cP(ctUWjWdTnMdsdKkVKuf3lKAl8sq(wyYfYp3z3xiflK6YCHjx4SjRzOTXCWl9yCmZQNNrWhB(0moDHuSqSeRur36m2XbmTsIJAZxyoxycle1wyclm5cDRZyp41ahDqCw8cPyHxjCbLOAbvce(ncfpfjkq0D5CxMaHG8CcELXnoEi77bsPfMp)cjipNabowVoqkjqmTxGxGqWnM7X1NjCbLYibvce(ncfpfjkq0D5CxMaHG8Cce4y96aPKaX0EbEbIeWlWlCbL5kbvce(ncfpfjkq0D5CxMaHG8Cce4y96aP0cZNFHNkl1Jnpy1Jxi1wycxeiM2lWlqABe)asC808JQUlCbLxKPGkbc)gHINIefiM2lWlq0GFeymh9uoILQUCSazYyDxsEbEbcv5y5NCCoSWCjL1Jx4aa8JRFHPaN2cTFUqStEoluvJ5f6PfgLfA)CHd2DcEHeS7CVqnyGW8f28Gv)cBgF)1ceDxo3LjqOFHtGh6sk08GvpEHuSqQVWKludgiarjq9oEHuBHxVWKlCc8qBJ5Gx6X1NTWKlKFUZUhM8P0LVqkqVWeK5cPBH5ZVqcagVWKl8uzPES5bRE8cP2cVs4ckVCrqLaHFJqXtrIcet7f4fi8GeGg3rcWpfitgR7sYlWlqqLT7e8c9uU5fItbKQ5cj4foaAEHAWplVapEHGFHEkVqn4NKLlq0D5CxMaHG8CcELXnoEi77bsPfMp)cPFHAWpjlpmzwkAkfNv2R5a)gHINlKoHlO8sccQeiM2lWlqiXCSCEalq43iu8uKOWfUabqtrJTrSGkbLxeujq43iu8uKOar3LZDzcecYZjKYw7rWj6PCKwPMbsjbIP9c8ceSBnMSZyHlOmbbvce(ncfpfjkqmTxGxGGj)t1Sarvph1tbc1ZzMEkCbLxlOsGWVrO4PirbIP9c8cKba4pvZceDxo3LjqiipNWaa8JRpEa9qGuAHjxi9lSjF(a6moOnNVZrnzxGa)gHINlmF(f2KpFaDghMTrML6rWjozwkEaAsCGFJqXZfs3ctUqSeRur36m2XbpTnCAuB(cP2ctyHjxO8wOBk(9GI8TowpwQAZlWh43iu8uGOQNJ6PaH65mtpfUGsQlOsGWVrO4PirbIUlN7Yei8ZD29fsTfETmxyYfobEOlPqZdw94fsXcPE4QfMCH0VqnaOMaAFWRmUXXdzFp08GvpEHuGEHYx4QfMp)cBYNpGoJdAZ57Cut2fiWVrO45cPBHjxib55e0k2ATH96Zcy30Jxi1w4LfMCHYBHeKNtWK4ChLAEAoOXrDBJQplqkTWKluElKG8CcekayQiXEGuAHjxO8wib55eiWX61bsPfMCH0VqnaOMaAFqd(rGXC0t5iwQ6YXHMhS6XlKIfkFHRwy(8luEludgXV9E4RSupEmEH0TWKlK(fkVfQbJ43Ep8SUbkqpxy(8ludaQjG2hSPj51ioIPz9qO5bRE8cPa9cVAH5ZVWjWd20K8AehX0SEioTblJdnpy1JxiflevVq6eiM2lWlqszR9i4e9uosRutHlO8kbvce(ncfpfjkq0D5CxMaHFUZUVqQTWRL5ctUWjWdDjfAEWQhVqkwi1dxTWKlK(fQba1eq7dELXnoEi77HMhS6XlKc0lK6HRwy(8lSjF(a6moOnNVZrnzxGa)gHINlKUfMCHeKNtqRyR1g2RplGDtpEHuBHxwyYfkVfsqEobtIZDuQ5P5Ggh1TnQ(SaP0ctUq5TqcYZjqOaGPIe7bsPfMCHYBHeKNtGahRxhiLwyYfs)c1aGAcO9bn4hbgZrpLJyPQlhhAEWQhVqkwO8fUAH5ZVq5Tqnye)27HVYs94X4fs3ctUq6xO8wOgmIF79WZ6gOa9CH5ZVqnaOMaAFWMMKxJ4iMM1dHMhS6XlKc0l8QfMp)cNapyttYRrCetZ6H40gSmo08GvpEHuSqu9cPtGyAVaVazaa(X1hpGEq4cx4cKrCJlWlOmbzMWfzE9fuTaHM1F9zybsosoQ8NszqkLFLdlCHuLYlSgKaTVWdOxiQyYhJu5OIf2SmqYQ55cXGbEHgPdgmNNluNAFgJd7nzC98ctqM5WcZfWpIBNNlePgYLfIV)UL7fMRxOdwOmM0w4Sgv4c8leiXT5GEH0lhDlK(l5MUWEtgxpVWesihwyUa(rC78CHi1qUSq893TCVWC9cDWcLXK2cN1OcxGFHajUnh0lKE5OBH0NqUPlS32B5i5OYFkLbPu(voSWfsvkVWAqc0(cpGEHOccfamDtbEmQyHnldKSAEUqmyGxOr6GbZ55c1P2NX4WEtgxpVWRZHfMlGFe3opxisnKlleF)Dl3lmxVqhSqzmPTWznQWf4xiqIBZb9cPxo6wi9xYnDH92Elhjhv(tPmiLYVYHfUqQs5fwdsG2x4b0levaOPOX2igvSWMLbswnpxigmWl0iDWG58CH6u7ZyCyVjJRNx415WcZfWpIBNNlev0KpFaDghqLqfl0blev0KpFaDghqLc8BekEIkwi9jKB6c7nzC98cPEoSWCb8J4255crfn5ZhqNXbujuXcDWcrfn5ZhqNXbuPa)gHINOIfs)LCtxyVjJRNx4v5WcZfWpIBNNlev0KpFaDghqLqfl0blev0KpFaDghqLc8BekEIkwi9xYnDH92EtgCqc0opxyUAHM2lWVqvHDCyVjqWsSwq5fzETarQbNsXceuh1xOme3MAHYpnzn3BOoQVquzR1PlmHlOSWeKzcx2B7nuh1xOme3MAH5OYaKXluB)cnfgSqcEHha5pxO5lm1DjCoiNCzf2dzLNsse0Gb5qLShvzTjN8jJYvYNwgLRYvY35k7O5R08Llxnn7AtMYOPDo7T9gQJ6lmxsTpJX5WEd1r9fIAlC2K1maOPOX2ioQnh9LfQtz9y8cDWcNnzndaAkASnIJAZd7nuh1xiQTWCb8J42xyIuTqjaqfBgdiBnVqhSqAw5lKZTuZyCb(WEBVzAVapoi1SgmqyUSOLBK1LrOyuEBGrFaKTwksuoJYitrYOL5Ed1xisAZZfIEHYeLfsj4rn8Bs4uGVq5VnMxi6fEbLfI8Meof4lu(BJ5fIEHjGYcLXYGle9cVgLfIqRK4fIEHuFVzAVapoi1SgmqyUSOLBK1LrOyuEBGrFkLIBugzksgTm3BO(cr0MIxiTYtxyQHDoS3mTxGhhKAwdgimxw0YnY6YiumkVnWO7sk6LEmgLrMIKrJQ3BM2lWJdsnRbdeMllA5gx)S5zelvD549MP9c84GuZAWaH5YIwocG7kEgpk7opPvFw0b5U(9MP9c84GuZAWaH5YIwoPgqtHsDqtqEoHba4hxF8a6HWeq73BM2lWJdsnRbdeMllA50MhpGEaL6GMG8CcdaWpU(4b0dHjG2V32BM2lWJr3KF00Eb(OQWokVnWOjmL9AgL6GMG8CcdaWpU(4b0dbsPKYB2K1maOPOX2ioQnFVH6lu(nWZrwyUa(rGX8EZ0EbESSOLtBkv00Eb(OQWokVnWOb0u0yBeJsDqpBYAga0u0yBeh1MV3q9fkdOb0ulKwk)8iUxOeaJlcfV3mTxGhllA5KAan1EZ0EbESSOLZRmUXXdzFhL6GMG8CcAZJhqpeMaA)EZ0EbESSOLtBE8a6buQdAcYZjOnpEa9qycO97nuFH54Nxiof4le7SP809MP9c8yzrlxt(rt7f4JQc7O82aJg7SP8uuQdAcYZjGtTjG2aRMbsP85jipNGudOPcKs7nt7f4XYIwo8ysLksy409MP9c8yzrlN2uQOP9c8rvHDuEBGrRba1eq73BO(cPK1nqb6zoSWCXW(cVEHGEHuFHAWabyHsG69f2LeEHGFH46Zu8cDRZyFHashxtEHGZcj4gZ94fc6foj76Zwib3yUhVW6SWd3MAHNMFu19fw4fskf2BM2lWJLfTCDjHIBDg7X6GwdgXV9E4zDduGEMelXkv0ToJDCWtBdNg1MJ(ssnyGaeLa17yksizZNMXPgHItoBYAg6sk4LEmoMz1ZZi4JnFAgNsXiRlJqXHUKIEPhJtsV8iipNabowVoqkLpVgautaTpqGJ1RdKs5Ztpb55eiWX61bsPKAaqnb0(WHBtfpn)OQ7bsj6OBVzAVapww0Y1KF00Eb(OQWokVnWOp1x4uUrPoO1GbcqucuVJPan9xHAJSUmcfhoaYwlfjkNPBVzAVapww0Yj11GPI0AZtrPoONnzndsDnyQiT280Gx6X4yMvppJGp28PzCkfOtqMj1GbcqucuVJPaDcOOQNJ6j6R2BO(crLjvEHAz65cXoBkpDVzAVapww0YPnLkAAVaFuvyhL3gy0yNnLNIsDqtqEobcCSEDGukFEcYZjGjNt(J2abjonqkT3q9fsvkVWba2xiNBj(X1iEHjs1c131kEH0tvAZ40fIK28CHi0kjEHAa2x4LlxTq(5o7oklCWgZlet28cPXluB)chSX8c9uZxy9lK6lmtbimfMU9MP9c8yzrlhnRCuWSgn90F5YvOwcxNtcYZjuV2638c8XX1NfbNONYrzyYptXbsj6qn65N7S7bnz387YED4QCYp3z3dnNXVS0tDzMtcYZjOvS1Ad71NfiLOJo6KJFUZUhAoJFuQdA3u87bcfamDtbECGFJqXZKeKNtGqbat3uGhhMaAFst71ios4rVRSmUXOL5Ed1xOP9c8yzrlNeaOInJbKTMrPoODtXVhiuaW0nf4Xb(ncfptsqEobcfamDtbECycO9jPNFUZUl71HRYj)CNDp0Cg)Ysp1LzojipNGwXwRnSxFwGuIo6Og9xUCfQLW15KG8Cc1RT(nVaFCC9zrWj6PCugM8ZuCGuIUKM2RrCKWJExzzCJrlZ9MP9c8yzrlxt(rt7f4JQc7O82aJMqbat3uGhJsDq7MIFpqOaGPBkWJd8BekEMKG8Ccekay6Mc84Weq73BM2lWJLfTChUb6cqIJeLZOOVRvC0ToJDm6lOuh0eKNtWK4ChLAEAoOXrDBJQplqkT3q9fsfycYHf6m2xONw4fsR80foaAEH2Ce3yEHy2jLWlKEfNX)06IXOSWm2AuwOBk(DmDl0blCWgZlet28c9uZxONw4fID7oEH2cNs4fwVUzdZ7nt7f4XYIwojaqfBgdiBnJYb0XNZTJ(YEZ0EbESSOLRTXmk67AfhDRZyhJ(ck1bn9nFAgNAekoFEjUXf253JdKkVKuf3umbEOTXCqAGu5LKQ4MUKZMSMH2gZbV0JXXmREEgbFS5tZ4ukWsSsfDRZyhhW0kjoQnpNjGAjS3mTxGhllA5uKV1X6XsvBEbEu031ko6wNXog9fuQd6MpnJtncfNC2K1mOiFRJ1JLQ28c8bV0JXXmREEgbFS5tZ4ukWsSsfDRZyhhW0kjoQnpNjGAjS3mTxGhllA5KaavSzmGS1mkhqhFo3o6l7nt7f4XYIwopTnCAuBok67AfhDRZyhJ(ck1bDZNMXPgHItoBYAg802WPrT5bV0JXXmREEgbFS5tZ4ukON6YILyLk6wNXoo4PTHtJAZZj1Plxt)fzhmSZ994itrY0HAAWpjlp4g254b0rcfamd8BekEIAAWi(T3dpRBGc0Z9MP9c8yzrlNeaOInJbKTMr5a64Z52rFzVzAVapww0Yr0KUPIyLHtrPoOPVTAg5r87bBoXH6PG(lYoy5oQtToJXOMo16mghpTP9c8MIUC2So16mo61atxs6XsSsfDRZyhhiAs3urSYWP500Eb(art6MkIvgonmTblJZ1M2lWhiAs3urSYWPbna70rb9M2lWhWPnpdtBWY4CTP9c8bCAZZGgGD62BM2lWJLfTCyALeh1MJsDqJLyLk6wNXooGPvsCuBofxKLG8Cce4y96aPuotyVzAVapww0Y5PTHtJAZrPoOXsSsfDRZyhh802WPrT5uC9EZ0EbESSOLdN28eL6GMG8CcAfBT2WE9zbsP9MP9c8yzrlxBJzu031ko6wNXog9fuQdAcYZjqGJ1RdKsjNnzndTnMdEPhJJzw98mc(yZNMXPuKWEZ0EbESSOLtBkv00Eb(OQWokVnWOpLsX9EBVzAVapoqOaGPBkWJr32ygf9DTIJU1zSJrFbL6GME55LEC9z5ZtFZNMXPgHItkXnUWo)ECGu5LKQ4MIjWdTnMdsdKkVKuf30Lpp9M2RrCKWJExzzCJrNqsjUXf253JdKkVKuf3umbEOTXCqAGu5LKQ4MU85P30EnIJeE07klJBm6es28PzCQrOy6Oljb55ei8yBJ5Weq7toBYAgABmh8spghZS65ze8XMpnJtPaDc7nt7f4XbcfamDtbESSOLtr(whRhlvT5f4rrFxR4OBDg7y0xqPoOB(0mo1iuCscYZjq4Xba4pvZHjG2V3mTxGhhiuaW0nf4XYIwopTnCAuBok67AfhDRZyhJ(ck1bDZNMXPgHItsqEobcp6PTHtdtaTp5SjRzWtBdNg1Mh8spghZS65ze8XMpnJtPGEQllwIvQOBDg74GN2gonQnpNuNUCn9xKDWWo33JJmfjthQPb)KS8GByNJhqhjuaWmWVrO45EZ0EbECGqbat3uGhllA5iAs3urSYWPOuh0eKNtGWJenPBQiwz40Weq73BM2lWJdekay6Mc8yzrlhMwjXrT5Ouh0eKNtGWJyALehMaAFsSeRur36m2XbmTsIJAZP4YEZ0EbECGqbat3uGhllA5WPnprPoOjipNaHhXPnpdtaTFVzAVapoqOaGPBkWJLfTCyALeh1MJsDqtqEobcpIPvsCycO97nt7f4XbcfamDtbESSOLZtBdNg1MJsDqtqEobcp6PTHtdtaTFVT3mTxGhh0aGAcO9OTPj51ioIPz9ak67AfhDRZyhJ(ckOPNE5nbEWMMKxJ4iMM1dXPnyzCWl946ZYNFc8GnnjVgXrmnRhItBWY4qZdw9yQLaDjPFc8GnnjVgXrmnRhItBWY4a2n9yQDD(8YBc8GnnjVgXrmnRhIPSPcy30JP4cDjLNP9c8bBAsEnIJyAwpetztfQpEuvwQNuEM2lWhSPj51ioIPz9qCAdwghQpEuvwQNuEM2lWhSPj51ioIPz9qO(4rvzPoDjDRZyp41ahDqCwmfxLpVP9Aeh5NhkgtrcjL3e4bBAsEnIJyAwpeN2GLXbV0JRplj)CNDNAxFvs36m2dEnWrheNftXv7nt7f4XbnaOMaAVSOL7WTPINMFu1DuQdAnyGaeLa17yQDDs36m2dEnWrheNftbQoP80aGAcO9bVY4ghpK99aPu(8Nkl1Jnpy1JPMmk5PYs9yZdw9yksyVH6lKQCS8toohwiLmpxOdwi((RxiTYtxiTYtxyBJ4hqIx4P5hvDFH0s5FH04f2K)cpn)OQ7e2przHGEHMRyd7luNY6XlSolSC8cPbApDHLV3mTxGhh0aGAcO9YIwocUXCpgL6Gwdgiarjq9oMc0xV3mTxGhh0aGAcO9YIwU61w)MxGhL6Gwdgiarjq9oMc0xV3q9fsvFFH2px4d8fsZWoVqQKHwi)CNDhLfsq6l0uyWcLHjX(cjX8clFHhqVquf3JxO9ZfwV26hV3mTxGhh0aGAcO9YIwoVY4ghpK9DuQdA(5o7EyYNsxofuxM5ZtqEobcCSEDGukFE6DtXVhKAEAoOd8BekEMeNcANXE09j1UMU9gQVqu5kl1xibVqAn4ZwOdwijMxiYaRMle8lu(BJ5fw)chX99foI77l8lDkVqC5KMxGhJYcji9foI77lSTMv33BM2lWJdAaqnb0Ezrlho1MaAdSAIsDqtqEobVY4ghpK99aPuscYZjqGJ1RdtaTpPgmqaIsG6Dm1OEYjWdTnMdsdKkVKuf3u7sq(sYp3z3PG6Ym5SjRzOTXCWl9yCmZQNNrWhB(0moLcSeRur36m2XbmTsIJAZZzcOwcjDRZyp41ahDqCwmfxT3mTxGhh0aGAcO9YIwocUXCpU(muQdAcYZj4vg344HSVhiLYNNG8Cce4y96aP0EZ0EbECqdaQjG2llA5KaEbEuQdAcYZjqGJ1RdKs7nt7f4XbnaOMaAVSOLRTr8diXXtZpQ6ok1bnb55eiWX61bsP85pvwQhBEWQhtTeUS3q9fsvow(jhNdlmxsz94foaa)46xykWPTq7Nle7KNZcv1yEHEAHrzH2px4GDNGxib7o3ludgimFHnpy1VWMX3F9EZ0EbECqdaQjG2llA50GFeymh9uoILQUCmk1bn9tGh6sk08GvpMcQNudgiarjq9oMAxNCc8qBJ5Gx6X1NLKFUZUhM8P0Ltb6eKjD5ZtaW4KNkl1Jnpy1JP2v7nuFHOY2DcEHEk38cXPas1CHe8chanVqn4NLxGhVqWVqpLxOg8tYY3BM2lWJdAaqnb0EzrlhpibOXDKa8tuQdAcYZj4vg344HSVhiLYNNEn4NKLhMmlfnLIZk71CGFJqXt62BM2lWJdAaqnb0EzrlhjMJLZd492EZ0EbEC4ukf3OBBmJI(UwXr36m2XOVGsDqpY6YiuC4ukf3OVKS5tZ4uJqXjNap02yoinqQ8ssvCtn0sCJlSZVhhivEjPkU3BM2lWJdNsP4ww0Y12ygL6GEK1LrO4WPukUrNWEZ0EbEC4ukf3YIwof5BDSESu1MxGhL6GEK1LrO4WPukUrF9EZ0EbEC4ukf3YIwomTsIrPoOhzDzekoCkLIB0uFVzAVapoCkLIBzrlhoT55EBVzAVapoCQVWPCJgBJSmo2aRrPoOjipNa2gzzCSbwhAEWQhtTR3BM2lWJdN6lCk3YIwoPUgmvKwBEkk1bn9ZMSMbPUgmvKwBEAWl9yCmZQNNrWhB(0moLIRZj9yjwPIU1zSJdsDnyQiT28uzVqxsSeRur36m2XbPUgmvKwBEkfxOlFESeRur36m2XbPUgmvKwBEkf0FTSxYPBk(9a2i42bapnWVrO4jD7nt7f4XHt9foLBzrlxxsOOVRvC0ToJDm6lOuh0nFAgNAeko5SjRzOlPGx6X4yMvppJGp28PzCkfJSUmcfh6sk6LEmoj90tqEobVY4ghpK99aPu(8Aaqnb0(GxzCJJhY(EO5bREmfxrxs6jipNaHcaMUPapoqkLpV8CtXVhiuaW0nf4Xb(ncfpPl5e4HUKcsdKkVKuf3udTe34c787XbsLxsQI785LNBk(9a2i42bapnWVrO4jD7nt7f4XHt9foLBzrlh2gzzCSbwJsDqtqEobSnYY4ydSo08GvpMA0RbdeGOeOEhl7f6YP8LtzgUEVzAVapoCQVWPCllA5oCd0fGehjkNrzWYDKFUZUJ(ck67AfhDRZyhJ(YEZ0EbEC4uFHt5ww0YD4gOlajosuoJI(UwXr36m2XOVGsDqtqEobcCSEDGukPBk(9agqQIGt0t54b0m2d8BekEU32BM2lWJdaAkASnIrJDRXKDgJsDqtqEoHu2ApcorpLJ0k1mqkT3mTxGhha0u0yBellA5WK)PAgfv9Cuprt9CMPN7nt7f4Xbanfn2gXYIwUba4pvZOOQNJ6jAQNZm9eL6GMG8CcdaWpU(4b0dbsPK03KpFaDgh0MZ35OMSlq(8n5ZhqNXHzBKzPEeCItMLIhGMetxsSeRur36m2XbpTnCAuBo1siP8CtXVhuKV1X6XsvBEb(a)gHIN7nt7f4Xbanfn2gXYIwUu2ApcorpLJ0k1eL6GMFUZUtTRLzYjWdDjfAEWQhtb1dxLKEnaOMaAFWRmUXXdzFp08GvpMc0Yx4Q85BYNpGoJdAZ57Cut2fGUKeKNtqRyR1g2RplGDtpMAxskpcYZjysCUJsnpnh04OUTr1NfiLskpcYZjqOaGPIe7bsPKYJG8Cce4y96aPus61aGAcO9bn4hbgZrpLJyPQlhhAEWQhtH8fUkFE5PbJ43Ep8vwQhpgtxs6LNgmIF79WZ6gOa9mFEnaOMaAFWMMKxJ4iMM1dHMhS6XuG(Q85NapyttYRrCetZ6H40gSmo08GvpMcunD7nt7f4Xbanfn2gXYIwUba4hxF8a6buQdA(5o7o1UwMjNap0LuO5bREmfupCvs61aGAcO9bVY4ghpK99qZdw9ykqt9Wv5Z3KpFaDgh0MZ35OMSlaDjjipNGwXwRnSxFwa7MEm1UKuEeKNtWK4ChLAEAoOXrDBJQplqkLuEeKNtGqbatfj2dKsjLhb55eiWX61bsPK0Rba1eq7dAWpcmMJEkhXsvxoo08GvpMc5lCv(8YtdgXV9E4RSupEmMUK0lpnye)27HN1nqb6z(8Aaqnb0(GnnjVgXrmnRhcnpy1JPa9v5ZpbEWMMKxJ4iMM1dXPnyzCO5bREmfOA62B7nt7f4XbSZMYtrlbaQyZyazRzuoGo(CUD0x2BO(cL)2yEHpZt8cBazwQ6(cVsM56fcolSC8cv8N5Pl08fAlCO(AGCyHoyHyYwYW4fItBEIx4uI3BM2lWJdyNnLNklA5ABmJI(UwXr36m2XOVGsDqt)e4H2gZbPbsLxsQIBQDjCv(8nFAgNAekMUKZMSMH2gZbV0JXXmREEgbFS5tZ4uksiFEcYZjqGJ1Rdnpy1JP2L9MP9c84a2zt5PYIwof5BDSESu1MxGhL6GglXkv0ToJDCWtBdNg1MtTRt28PzCQrO4KZMSMbf5BDSESu1MxGp4LEmoMz1ZZi4JnFAgNsXvjPxdgiarjq9ogn1ZNFc8GI8TowpwQAZlWhAEWQhtTRYNxEtGhuKV1X6XsvBEb(Gx6X1Nr3Ed1xyInPBQfIOmC6cl8cjy35EHEQ9le7SP80fIK28CHMVWRxOBDg749MP9c84a2zt5PYIwoIM0nveRmCkk1bnwIvQOBDg74art6MkIvgoLIe2BM2lWJdyNnLNklA5KaavSzmGS1mkhqhFo3o6l7nt7f4XbSZMYtLfTC40MNOuh0AWabikbQ3XuJ6jXsSsfDRZyhh802WPrT5u7Q92EZ0EbECGWu2Rz0yY)unJsDqtqEobwRkjmhXaL1HjG2NKG8CcSwvsyoQiFRdtaTpj9nFAgNAekoFE6nTxJ4i)8qXykUK00EnIJtGhWK)PAMAM2RrCKFEOymD0T3mTxGhhimL9Aww0YHDRXKDgJsDqtqEobwRkjmhXaL1HMhS6XuOnSh9AGZNNG8CcSwvsyoQiFRdnpy1JPqByp61aV3mTxGhhimL9Aww0YHDRpvZOuh0eKNtG1QscZrf5BDO5bREmfAd7rVg485XaL1rwRkjmtHm3BM2lWJdeMYEnllA5O1MNIsDqtqEobwRkjmhXaL1HMhS6XuOnSh9AGZNxr(whzTQKWmfYu4cxia]] )


end
