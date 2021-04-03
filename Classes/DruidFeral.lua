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


    spec:RegisterPack( "Feral", 20210403, [[dSeyBbqiIQ8iIICjivWMerFsHeJcPYPqQAvke9kIsZcs5wqQ0Ue8lIkdJOWXujwMi4zQKAAijUMkjBJOQ8nKKY4iQQCofcSofcnpivDpizFirhejj1cfHEOcjnrIIkBejj5JeffDsKKOvQs1mrsQUjrrv7ej8tfcAOijblLOQQNcXurs9vIIcJfsfAVe(Rqdg0HPSyeEmPMSIUmQnRIplkJwKoTKvtuu61kuZMKBRGDRQFdmCICCKKqlxQNd10P66iA7IQ(osz8kK68QuwpKkA(Ik7xPfxeulqMMZcksqgjCrgurgxhUC56eKrcce)MelqKm9ylJfiVnWceQkUnLarYUPa2uqTabdiBnlqsDxcpIYjxw5PKebnyqoCnqQmVaVUTJlhUg0YjqiilLtv(ccbY0CwqrcYiHlYGkY46WLlxNGaXi9uqlqqQHrvGKwZj)ccbYKXAbcvf3MAHYCnzn37u1sDPwycOTWeKrcx277DQkUn1cPQPkq1xO2(fAkmyHe8cpaYFUqZxyQ7s4ruo5YkShYkpLKiObdYHoAp60Ato5t(ncKpT8BemcKVZv2rZxP5lxUAA21MmKFt7C2779rn1(mgpI7D0DHZMSMbanfn2YZrT5OUSqDkRhJxOdw4SjRzaqtrJT8CuBEyVJUlCubFEU9fMi1lucauXMXaYwZl0blKMv(c5rl1mgxGpiquf2XcQfiekay6Mc8yb1ckUiOwGWVrO4PirbIP9c8cK2gZceDxo3LjqOBHYBHEPhxF2cZLBH0TWMpnJtncfVWKluIBCHD(94aPYljvX9cPCHtGhABmhKgivEjPkUxi9lmxUfs3cnTx55iHh9UYY4gVqulmHfMCHsCJlSZVhhivEjPkUxiLlCc8qBJ5G0aPYljvX9cPFH5YTq6wOP9kphj8O3vwg34fIAHjSWKlS5tZ4uJqXlK(fs)ctUqcYZjq4X2gZHjG2VWKlC2K1m02yo4LEmoMz1ZZi4JnFAgNUqkrTWeei6BAfhDRZyhlO4IWfuKGGAbc)gHINIefiM2lWlquKV1X6XsvBEbEbIUlN7YeinFAgNAekEHjxib55ei84aa8NQ5Weq7fi6BAfhDRZyhlO4IWfuCTGAbc)gHINIefiM2lWlq802WPrT5ceDxo3LjqA(0mo1iu8ctUqcYZjq4rpTnCAycO9lm5cNnzndEAB40O28Gx6X4yMvppJGp28PzC6cPCH0TqQSqzxiwIvQOBDg74GN2gonQnFHJCHuzH0Vq5wiDl8YcLDHdg25(wmVPi5fs)cr3fQb)KS8GByNJhqhjuaWmWVrO4ParFtR4OBDg7ybfxeUGcQiOwGWVrO4PirbIUlN7YeieKNtGWJenPBQiwz40Weq7fiM2lWlqiAs3urSYWPcxqXvcQfi8BekEksuGO7Y5Umbcb55ei8iMwjXHjG2VWKlelXkv0ToJDCatRK4O28fs5cViqmTxGxGGPvsCuBUWfuiFcQfi8BekEksuGO7Y5Umbcb55ei8ioT5zycO9cet7f4fi40MNcxqbvtqTaHFJqXtrIceDxo3LjqiipNaHhX0kjomb0EbIP9c8cemTsIJAZfUGc5NGAbc)gHINIefi6UCUltGqqEobcp6PTHtdtaTxGyAVaVaXtBdNg1MlCHlqo1x4uUfulO4IGAbc)gHINIefi6UCUltGqqEobSL3Y4ydSo08GvpEHOFHxlqmTxGxGGT8wghBG1cxqrccQfi8BekEksuGO7Y5UmbcDlC2K1mi11GPI0AZtdEPhJJzw98mc(yZNMXPlKYfE9ch5cPBHyjwPIU1zSJdsDnyQiT280fk7cVSq6xyYfILyLk6wNXooi11GPI0AZtxiLl8YcPFH5YTqSeRur36m2XbPUgmvKwBE6cPCH0TWRxOSl8Ych5cDtXVhWgb3oa4Pb(ncfpxi9cet7f4fisDnyQiT28uHlO4Ab1ce(ncfpfjkqmTxGxG0LKar3LZDzcKMpnJtncfVWKlC2K1m0LuWl9yCmZQNNrWhB(0moDHuUW8wxgHIdDjf9spgVWKlKUfs3cjipNGxzCJJhY(wGuAH5YTqnaOMaAFWRmUXXdzFl08GvpEHuUWRwi9lm5cPBHeKNtGqbat3uGhhiLwyUCluEl0nf)EGqbat3uGhh43iu8CH0VWKlCc8qxsbPbsLxsQI7fIEuluIBCHD(94aPYljvX9cZLBHYBHUP43dyJGBha80a)gHINlKEbI(MwXr36m2XckUiCbfurqTaHFJqXtrIceDxo3LjqiipNa2YBzCSbwhAEWQhVq0Vq6wOgmqaIsG6D8cLDHxwi9lCKlu(w4ixOmcxlqmTxGxGGT8wghBG1cxqXvcQfi8BekEksuGmyJoYp3z3euCrGyAVaVa5WnqxasCKOCwGOVPvC0ToJDSGIlcxqH8jOwGWVrO4PirbIP9c8cKd3aDbiXrIYzbIUlN7YeieKNtGahRxhiLwyYf6MIFpGbKQi4e9uoEanJ9a)gHINce9nTIJU1zSJfuCr4cxGqyk71SGAbfxeulq43iu8uKOar3LZDzcecYZjWAvjH5igOSomb0(fMCHeKNtG1QscZrf5BDycO9lm5cPBHnFAgNAekEH5YTq6wOP9kph5NhkgVqkx4LfMCHM2R8CCc8aM8pvZle9l00ELNJ8ZdfJxi9lKEbIP9c8cem5FQMfUGIeeulq43iu8uKOar3LZDzcecYZjWAvjH5igOSo08GvpEHuUqTH9Oxd8cZLBHeKNtG1QscZrf5BDO5bRE8cPCHAd7rVgybIP9c8ceSBnMSZyHlO4Ab1ce(ncfpfjkq0D5CxMaHG8CcSwvsyoQiFRdnpy1JxiLluByp61aVWC5wigOSoYAvjH5fs5cLHaX0EbEbc2T(unlCbfurqTaHFJqXtrIceDxo3LjqiipNaRvLeMJyGY6qZdw94fs5c1g2JEnWlmxUfQiFRJSwvsyEHuUqziqmTxGxGqRnpv4cxGm5JrQCb1ckUiOwGWVrO4PirbIUlN7YeieKNtyaa(X1hpGEiqkTWKluElC2K1maOPOXwEoQnxGyAVaVaPj)OP9c8rvHDbIQWE8TbwGqyk71SWfuKGGAbc)gHINIefi6UCUltGmBYAga0u0ylph1MlqmTxGxGOnLkAAVaFuvyxGOkShFBGfiaAkASLNfUGIRfulq43iu8uKOazYyDxsEbEbcvHgqtTqAP8Z55EHsamUiuSaX0EbEbIudOPeUGcQiOwGWVrO4PirbIUlN7YeieKNtqBE8a6HWeq7fiM2lWlq8kJBC8q23eUGIReulq43iu8uKOar3LZDzcecYZjOnpEa9qycO9cet7f4fiAZJhqpiCbfYNGAbc)gHINIefitgR7sYlWlqgHpVqCkWxi2zt5Pcet7f4fin5hnTxGpQkSlq0D5CxMaHG8Cc4uBcOnWQzGuAH5YTqcYZji1aAQaPKarvyp(2alqWoBkpv4ckOAcQfiM2lWlqWJjvQiHHtfi8BekEksu4ckKFcQfi8BekEksuGyAVaVarBkv00Eb(OQWUarvyp(2alq0aGAcO9cxqXiqqTaHFJqXtrIcet7f4fiDjjq030ko6wNXowqXfbIUlN7YeiAqE(T3dpRBGc0ZfMCHyjwPIU1zSJdEAB40O28fIAHxwyYfQbdeGOeOEhVqkxyclm5cB(0mo1iu8ctUWztwZqxsbV0JXXmREEgbFS5tZ40fs5cZBDzeko0Lu0l9y8ctUq6wO8wib55eiWX61bsPfMl3c1aGAcO9bcCSEDGuAH5YTq6wib55eiWX61bsPfMCHAaqnb0(WHBtfpn)OZBbsPfs)cPxGmzSUljVaVaHcw3afONJ4chvd7l86fc6fsLfQbdeGfkbQ3xyxs4fc(fIRptXl0ToJ9fciDCn5fcolKGBm3JxiOx4KSRpBHeCJ5E8cRZcpCBQfEA(rN3wyHxiPuq4ckUidb1ce(ncfpfjkq0D5CxMardgiarjq9oEHuIAH0TWRwi6UW8wxgHIdhazRLIeLZlKEbIP9c8cKM8JM2lWhvf2fiQc7X3gybYP(cNYTWfuC5IGAbc)gHINIefi6UCUltGmBYAgK6AWurAT5PbV0JXXmREEgbFS5tZ40fsjQfMGmwyYfQbdeGOeOEhVqkrTWeeiM2lWlqK6AWurAT5Pcev9CupfixjCbfxsqqTaHFJqXtrIcKjJ1Dj5f4fiY8KkVq3m9CHyNnLNkqmTxGxGOnLkAAVaFuvyxGO7Y5Umbcb55eiWX61bsPfMl3cjipNaMCo5pAdeK40aPKarvyp(2alqWoBkpv4ckUCTGAbc)gHINIefitgR7sYlWlqOoLx4aa7lKhTe)4kpVWePEH6BAfVq6OoTzC6crsBEUqeALeVqna7l8YLRwi)CNDdTfoyJ5fIjBEH04fQTFHd2yEHEQ5lS(fsLfMPaeMctVabZAbcDlKUfE5YvleDxycxVWrUqcYZjuV2638c8XX1NfbNONYrzwYptXbsPfs)cr3fs3c5N7SBbnz387lu2fED4QfoYfYp3z3cnNX)cLDH0TqQiJfoYfsqEobTITwByV(SaP0cPFH0Vq6xOClKFUZUfAoJFbIP9c8ceAw5ceDxo3LjqCtXVhiuaW0nf4Xb(ncfpxyYfsqEobcfamDtbECycO9lm5cnTx55iHh9UYY4gVqulugcxqXfQiOwGWVrO4PirbYKX6UK8c8cet7f4XHjFmsLllk5KaavSzmGS1mA1bLBk(9aHcaMUPapoWVrO4zscYZjqOaGPBkWJdtaTpjD8ZD2nzVoC1i5N7SBHMZ4xw6OImgjb55e0k2ATH96ZcKs0tp6P7YLRq3eUEKeKNtOET1V5f4JJRplcorpLJYSKFMIdKs0N00ELNJeE07klJBmkziqmTxGxG0KF00Eb(OQWUar3LZDzce3u87bcfamDtbECGFJqXZfMCHeKNtGqbat3uGhhMaAVarvyp(2alqiuaW0nf4XcxqXLReulq43iu8uKOaX0EbEbYHBGUaK4ir5Sar3LZDzcecYZjys8OJsnpnh04OUT81NfiLei6BAfhDRZyhlO4IWfuCr(eulq43iu8uKOa5a64ZJ2fuCrGyAVaVarcauXMXaYwZcxqXfQMGAbc)gHINIefiM2lWlqABmlq0D5CxMaHUf28PzCQrO4fMl3cL4gxyNFpoqQ8ssvCVqkx4e4H2gZbPbsLxsQI7fs)ctUWztwZqBJ5Gx6X4yMvppJGp28PzC6cPCHyjwPIU1zSJdyALeh1MVWrUWewi6UWeei6BAfhDRZyhlO4IWfuCr(jOwGWVrO4PirbIP9c8cef5BDSESu1MxGxGO7Y5UmbsZNMXPgHIxyYfoBYAguKV1X6XsvBEb(Gx6X4yMvppJGp28PzC6cPCHyjwPIU1zSJdyALeh1MVWrUWewi6UWeei6BAfhDRZyhlO4IWfuCzeiOwGWVrO4PirbYb0XNhTlO4IaX0EbEbIeaOInJbKTMfUGIeKHGAbc)gHINIefiM2lWlq802WPrT5ceDxo3LjqA(0mo1iu8ctUWztwZGN2gonQnp4LEmoMz1ZZi4JnFAgNUqkxiDlKklu2fILyLk6wNXoo4PTHtJAZx4ixivwi9luUfs3cVSqzx4GHDUVfZBksEH0Vq0DHAWpjlp4g254b0rcfamd8BekEUq0DHAqE(T3dpRBGc0tbI(MwXr36m2XckUiCbfjCrqTaHFJqXtrIcKdOJppAxqXfbIP9c8cejaqfBgdiBnlCbfjKGGAbc)gHINIefi6UCUltGq3cBRMrop)EWMtCO(fs5cPBHxwOSlCWgDuNADgJxi6UqDQ1zmoEAt7f4n1cPFHJCHnRtToJJEnWlK(fMCH0TqSeRur36m2XbIM0nveRmC6ch5cnTxGpq0KUPIyLHtdtBWY4fk3cnTxGpq0KUPIyLHtdAa2xi9lKYfs3cnTxGpGtBEgM2GLXluUfAAVaFaN28mObyFH0lqmTxGxGq0KUPIyLHtfUGIeUwqTaHFJqXtrIceDxo3LjqWsSsfDRZyhhW0kjoQnFHuUWllu2fsqEobcCSEDGuAHJCHjiqmTxGxGGPvsCuBUWfuKaveulq43iu8uKOar3LZDzceSeRur36m2XbpTnCAuB(cPCHxlqmTxGxG4PTHtJAZfUGIeUsqTaHFJqXtrIceDxo3LjqiipNGwXwRnSxFwGusGyAVaVabN28u4cksq(eulq43iu8uKOaX0EbEbsBJzbIUlN7YeieKNtGahRxhiLwyYfoBYAgABmh8spghZS65ze8XMpnJtxiLlmbbI(MwXr36m2XckUiCbfjq1eulq43iu8uKOaX0EbEbI2uQOP9c8rvHDbIQWE8TbwGCkLIBHlCbIuZAWaH5cQfuCrqTaHFJqXtrIceGKabZUaX0EbEbsERlJqXcK8MIKfiYqGK364BdSa5aiBTuKOCw4cksqqTaHFJqXtrIceGKabZUaX0EbEbsERlJqXcK8MIKfiYqGmzSUljVaVabjT55crTqzG2cPa8Ol(njCkWxO83gZle1cVG2crEtcNc8fk)TX8crTWeqBHuDQYfIAHxJ2crOvs8crTqQiqYBD8TbwGCkLIBHlO4Ab1ce(ncfpfjkqascem7cet7f4fi5TUmcflqYBkswGq1eitgR7sYlWlqq0MIxiTYtxyQHDoiqYBD8TbwG0Lu0l9ySWfuqfb1cet7f4fiJRF28mILQUCSaHFJqXtrIcxqXvcQfiM2lWlqiaUR4z8OSB8Kw9zrhm66fi8BekEksu4ckKpb1ce(ncfpfjkq0D5CxMaHG8CcdaWpU(4b0dHjG2lqmTxGxGi1aAkHlOGQjOwGWVrO4PirbIUlN7YeieKNtyaa(X1hpGEimb0EbIP9c8ceT5XdOheUWfiNsP4wqTGIlcQfi8BekEksuGyAVaVaPTXSar3LZDzcK8wxgHIdNsP4EHOw4LfMCHnFAgNAekEHjx4e4H2gZbPbsLxsQI7fIEuluIBCHD(94aPYljvXTarFtR4OBDg7ybfxeUGIeeulq43iu8uKOar3LZDzcK8wxgHIdNsP4EHOwyccet7f4fiTnMfUGIRfulq43iu8uKOar3LZDzcK8wxgHIdNsP4EHOw41cet7f4fikY36y9yPQnVaVWfuqfb1ce(ncfpfjkq0D5CxMajV1LrO4WPukUxiQfsfbIP9c8cemTsIJAZfUGIReulqmTxGxGGtBEkq43iu8uKOWfUab7SP8ub1ckUiOwGWVrO4PirbYb0XNhTlO4IaX0EbEbIeaOInJbKTMfUGIeeulq43iu8uKOaX0EbEbsBJzbI(MwXr36m2XckUiq0D5CxMaHUfobEOTXCqAGu5LKQ4EHOFHxcxTWC5wyZNMXPgHIxi9lm5cNnzndTnMdEPhJJzw98mc(yZNMXPlKYfMWcZLBHeKNtGahRxhAEWQhVq0VWlcKjJ1Dj5f4fiYFBmVWN5jEHnGmlvDBHxjd0HfcolSC8cv8N5Pl08fAlCO(AGCyHoyHyYwYW4fItBEIx4uIfUGIRfulq43iu8uKOar3LZDzceSeRur36m2XbpTnCAuB(cr)cVEHjxyZNMXPgHIxyYfoBYAguKV1X6XsvBEb(Gx6X4yMvppJGp28PzC6cPCHxTWKlKUfQbdeGOeOEhVqulKklmxUfobEqr(whRhlvT5f4dnpy1Jxi6x4vlmxUfkVfobEqr(whRhlvT5f4dEPhxF2cPxGyAVaVarr(whRhlvT5f4fUGcQiOwGWVrO4PirbIP9c8ceIM0nveRmCQazYyDxsEbEbsInPBQfIOmC6cl8cjy35EHEQ9le7SP80fIK28CHMVWRxOBDg7ybIUlN7YeiyjwPIU1zSJdenPBQiwz40fs5ctq4ckUsqTaHFJqXtrIcKdOJppAxqXfbIP9c8cejaqfBgdiBnlCbfYNGAbc)gHINIefi6UCUltGObdeGOeOEhVq0VqQSWKlelXkv0ToJDCWtBdNg1MVq0VWReiM2lWlqWPnpfUWfiAaqnb0Eb1ckUiOwGWVrO4PirbIaHo6K3e4bBAsELNJyAwpeN2GLXbV0JRplxUjWd20K8kphX0SEioTblJdnpy1JrFc0NKUjWd20K8kphX0SEioTblJdy30Jr)15YjVjWd20K8kphX0SEiMYMkGDtpMYl0NuEM2lWhSPj5vEoIPz9qmLnvO(4rvzPEs5zAVaFWMMKx55iMM1dXPnyzCO(4rvzPEs5zAVaFWMMKx55iMM1dH6JhvLL60N0ToJ9GxdC0bXzXuEvUCM2R8CKFEOymLjKuEtGhSPj5vEoIPz9qCAdwgh8spU(SK8ZD2n0F9vjDRZyp41ahDqCwmLxjqmTxGxGyttYR8CetZ6bbI(MwXr36m2XckUiCbfjiOwGWVrO4PirbIP9c8cKd3MkEA(rN3ei6UCUltGObdeGOeOEhVq0VWRxyYf6wNXEWRbo6G4S4fs5cPAlm5cL3c1aGAcO9bVY4ghpK9TaP0cZLBHNkl1Jnpy1Jxi6xO8BHjx4PYs9yZdw94fs5ctqGOVPvC0ToJDSGIlcxqX1cQfi8BekEksuGyAVaVaHGBm3JfitgR7sYlWlqOEekZnchXfsbZZf6GfIV96fsR80fsR80f2wE(bK4fEA(rN3wiTu(xinEHn5VWtZp68gH9t0wiOxO5k2W(c1PSE8cRZclhVqAG2txy5ceDxo3Ljq0GbcqucuVJxiLOw41cxqbveulq43iu8uKOar3LZDzcenyGaeLa174fsjQfETaX0EbEbs9ARFZlWlCbfxjOwGWVrO4PirbIP9c8ceVY4ghpK9nbYKX6UK8c8ceQ7Bl0(5cFGVqAg25fsnv1c5N7SBOTqcsFHMcdwOmlj2xijMxy5l8a6fIo5E8cTFUW61w)ybIUlN7Yei8ZD2TWKpLU8fs5cPImwyUClKG8Cce4y96aP0cZLBH0Tq3u87bPMNMd6a)gHINlm5cXPG2zShDFUq0VWRxi9cxqH8jOwGWVrO4PirbIP9c8ceCQnb0gy1uGmzSUljVaVarMVYs9fsWlKwd(Sf6GfsI5fImWQ5cb)cL)2yEH1VW8CFBH55(2c)sNYlexoP5f4XOTqcsFH55(2cBRz1nbIUlN7YeieKNtWRmUXXdzFlqkTWKlKG8Cce4y96Weq7xyYfQbdeGOeOEhVq0VqQSWKlCc8qBJ5G0aPYljvX9cr)cVeKVfMCH8ZD2Tfs5cPImwyYfoBYAgABmh8spghZS65ze8XMpnJtxiLlelXkv0ToJDCatRK4O28foYfMWcr3fMWctUq36m2dEnWrheNfVqkx4vcxqbvtqTaHFJqXtrIceDxo3LjqiipNGxzCJJhY(wGuAH5YTqcYZjqGJ1RdKscet7f4fieCJ5EC9zcxqH8tqTaHFJqXtrIceDxo3LjqiipNabowVoqkjqmTxGxGib8c8cxqXiqqTaHFJqXtrIceDxo3LjqiipNabowVoqkTWC5w4PYs9yZdw94fI(fMWfbIP9c8cK2YZpGehpn)OZBcxqXfziOwGWVrO4PirbIP9c8cen4ZdgZrpLJyPQlhlqMmw3LKxGxGq9iuMBeoIlCutz94foaa)46xykWPTq7Nle7KNZcv1yEHEAHrBH2px4GDJGxib7o3ludgimFHnpy1VWMX3ETar3LZDzce6w4e4HUKcnpy1JxiLlKklm5c1GbcqucuVJxi6x41lm5cNap02yo4LEC9zlm5c5N7SBHjFkD5lKsulmbzSq6xyUClKaGXlm5cpvwQhBEWQhVq0VWReUGIlxeulq43iu8uKOaX0EbEbcpibOXDKa8tbYKX6UK8c8cezE7gbVqpLBEH4uaPAUqcEHdGMxOg8ZYlWJxi4xONYlud(jz5ceDxo3LjqiipNGxzCJJhY(wGuAH5YTq6wOg8tYYdtMLIMsXzL9AoWVrO45cPx4ckUKGGAbIP9c8cesmhlNhWce(ncfpfjkCHlqa0u0ylplOwqXfb1ce(ncfpfjkq0D5CxMaHG8CcPS1EeCIEkhPvQzGusGyAVaVab7wJj7mw4cksqqTaHFJqXtrIcet7f4fiyY)unlqu1Zr9uGqLrMPNcxqX1cQfi8BekEksuGyAVaVazaa(t1Sar3LZDzcecYZjmaa)46JhqpeiLwyYfs3cBYNpGoJdAZ5BCut2fiWVrO45cZLBHn5ZhqNXHzBKzPEeCItMLIhGMeh43iu8CH0VWKlelXkv0ToJDCWtBdNg1MVq0VWewyYfkVf6MIFpOiFRJ1JLQ28c8b(ncfpfiQ65OEkqOYiZ0tHlOGkcQfi8BekEksuGO7Y5Umbc)CNDBHOFHxlJfMCHtGh6sk08GvpEHuUqQeUAHjxiDludaQjG2h8kJBC8q23cnpy1JxiLOwO8fUAH5YTWM85dOZ4G2C(gh1KDbc8BekEUq6xyYfsqEobTITwByV(Sa2n94fI(fEzHjxO8wib55emjE0rPMNMdACu3w(6ZcKslm5cL3cjipNaHcaMksShiLwyYfkVfsqEobcCSEDGuAHjxiDludaQjG2h0Gppymh9uoILQUCCO5bRE8cPCHYx4QfMl3cL3c1G88BVh(kl1JhJxi9lm5cPBHYBHAqE(T3dpRBGc0ZfMl3c1aGAcO9bBAsELNJyAwpeAEWQhVqkrTWRwyUClCc8GnnjVYZrmnRhItBWY4qZdw94fs5cPAlKEbIP9c8cKu2ApcorpLJ0k1u4ckUsqTaHFJqXtrIceDxo3Ljq4N7SBle9l8AzSWKlCc8qxsHMhS6XlKYfsLWvlm5cPBHAaqnb0(GxzCJJhY(wO5bRE8cPe1cPs4QfMl3cBYNpGoJdAZ5BCut2fiWVrO45cPFHjxib55e0k2ATH96Zcy30Jxi6x4LfMCHYBHeKNtWK4rhLAEAoOXrDB5RplqkTWKluElKG8CcekayQiXEGuAHjxO8wib55eiWX61bsPfMCH0TqnaOMaAFqd(8GXC0t5iwQ6YXHMhS6XlKYfkFHRwyUCluEludYZV9E4RSupEmEH0VWKlKUfkVfQb553Ep8SUbkqpxyUCludaQjG2hSPj5vEoIPz9qO5bRE8cPe1cVAH5YTWjWd20K8kphX0SEioTblJdnpy1JxiLlKQTq6fiM2lWlqgaGFC9XdOheUWfUajp34c8cksqgjCrgxNWfbcnR)6ZWcezgu1YFkOkPqM5iUWfsDkVWAqc0(cpGEHJYKpgPYhLf2mvrYQ55cXGbEHgPdgmNNluNAFgJd7DQE98ctqgJ4chvWNNBNNlePgg1fIV9Un6fIoSqhSqQoPTWzLVWf4xiqIBZb9cPto6xiDxgn9H9ovVEEHjKWiUWrf855255crQHrDH4BVBJEHOdl0blKQtAlCw5lCb(fcK42CqVq6KJ(fsxcJM(WEFVlZGQw(tbvjfYmhXfUqQt5fwdsG2x4b0lCuiuaW0nf4XJYcBMQiz18CHyWaVqJ0bdMZZfQtTpJXH9ovVEEHxpIlCubFEUDEUqKAyuxi(272Oxi6WcDWcP6K2cNv(cxGFHajUnh0lKo5OFH0Dz00h277Dzgu1YFkOkPqM5iUWfsDkVWAqc0(cpGEHJcGMIgB55rzHntvKSAEUqmyGxOr6GbZ55c1P2NX4WENQxpVWRhXfoQGpp3opx4O0KpFaDghqhhLf6Gfokn5ZhqNXb0Xa)gHINJYcPlHrtFyVt1RNxivgXfoQGpp3opx4O0KpFaDghqhhLf6Gfokn5ZhqNXb0Xa)gHINJYcP7YOPpS3P61Zl8QrCHJk4ZZTZZfokn5ZhqNXb0XrzHoyHJst(8b0zCaDmWVrO45OSq6UmA6d799ov5GeODEUWrWcnTxGFHQc74WExGi1GtPybImjtlKQIBtTqzUMSM7DzsMwivTuxQfMaAlmbzKWL9(ExMKPfsvXTPwivnvbQ(c12VqtHblKGx4bq(ZfA(ctDxcpIYjxwH9qw5PKebnyqo0r7rNwBYjFYVrG8PLFJGrG8DUYoA(knF5YvtZU2KH8BANZEFVltY0ch1u7Zy8iU3LjzAHO7cNnzndaAkASLNJAZrDzH6uwpgVqhSWztwZaGMIgB55O28WExMKPfIUlCubFEU9fMi1lucauXMXaYwZl0blKMv(c5rl1mgxGpS337M2lWJdsnRbdeMllk5YBDzekgT3gyuhazRLIeLZOL3uKmkzS3LPfIK28CHOwOmqBHuaE0f)Meof4lu(BJ5fIAHxqBHiVjHtb(cL)2yEHOwycOTqQov5crTWRrBHi0kjEHOwiv27M2lWJdsnRbdeMllk5YBDzekgT3gyuNsP4gT8MIKrjJ9UmTqeTP4fsR80fMAyNd7Dt7f4XbPM1GbcZLfLC5TUmcfJ2BdmQUKIEPhJrlVPizuuT9UP9c84GuZAWaH5YIsUX1pBEgXsvxoEVBAVapoi1SgmqyUSOKJa4UINXJYUXtA1NfDWORFVBAVapoi1SgmqyUSOKtQb0uOvhueKNtyaa(X1hpGEimb0(9UP9c84GuZAWaH5YIsoT5XdOhqRoOiipNWaa8JRpEa9qycO9799UP9c8yun5hnTxGpQkSJ2BdmkctzVMrRoOiipNWaa8JRpEa9qGukP8MnzndaAkASLNJAZ37M2lWJLfLCAtPIM2lWhvf2r7TbgfGMIgB5z0QdQztwZaGMIgB55O289UmTqQcnGMAH0s5NZZ9cLayCrO49UP9c8yzrjNudOP27M2lWJLfLCELXnoEi7BOvhueKNtqBE8a6HWeq737M2lWJLfLCAZJhqpGwDqrqEobT5XdOhctaTFVltlCe(8cXPaFHyNnLNU3nTxGhllk5AYpAAVaFuvyhT3gyuyNnLNIwDqrqEobCQnb0gy1mqkLlhb55eKAanvGuAVBAVapwwuYHhtQurcdNU3nTxGhllk50MsfnTxGpQkSJ2BdmknaOMaA)ExMwifSUbkqphXfoQg2x41le0lKkludgialucuVVWUKWle8lexFMIxOBDg7leq64AYleCwib3yUhVqqVWjzxF2cj4gZ94fwNfE42ul808JoVTWcVqsPWE30EbESSOKRlj0030ko6wNXog1f0Qdknip)27HN1nqb6zsSeRur36m2XbpTnCAuBoQlj1GbcqucuVJPmHKnFAgNAeko5SjRzOlPGx6X4yMvppJGp28PzCkL5TUmcfh6sk6LEmojDYJG8Cce4y96aPuUCAaqnb0(abowVoqkLlhDeKNtGahRxhiLsQba1eq7dhUnv808JoVfiLON(9UP9c8yzrjxt(rt7f4JQc7O92aJ6uFHt5gT6Gsdgiarjq9oMsu0Df6M36YiuC4aiBTuKOCM(9UP9c8yzrjNuxdMksRnpfT6GA2K1mi11GPI0AZtdEPhJJzw98mc(yZNMXPuIkbzKudgiarjq9oMsujGMQEoQNOUAVltluMNu5f6MPNle7SP809UP9c8yzrjN2uQOP9c8rvHD0EBGrHD2uEkA1bfb55eiWX61bsPC5iipNaMCo5pAdeK40aP0ExMwi1P8chayFH8OL4hx55fMi1luFtR4fsh1PnJtxisAZZfIqRK4fQbyFHxUC1c5N7SBOTWbBmVqmzZlKgVqT9lCWgZl0tnFH1VqQSWmfGWuy637M2lWJLfLC0SYrdZAu0r3LlxHUjC9ijipNq9ARFZlWhhxFweCIEkhLzj)mfhiLOhDPJFUZUf0KDZVl71HRgj)CNDl0Cg)YshvKXijipNGwXwRnSxFwGuIE6Pxo(5o7wO5m(rRoOCtXVhiuaW0nf4Xb(ncfptsqEobcfamDtbECycO9jnTx55iHh9UYY4gJsg7DzAHM2lWJLfLCsaGk2mgq2AgT6GYnf)EGqbat3uGhh43iu8mjb55eiuaW0nf4XHjG2NKo(5o7MSxhUAK8ZD2TqZz8llDurgJKG8CcAfBT2WE9zbsj6Ph90D5YvOBcxpscYZjuV2638c8XX1NfbNONYrzwYptXbsj6tAAVYZrcp6DLLXngLm27M2lWJLfLCn5hnTxGpQkSJ2BdmkcfamDtbEmA1bLBk(9aHcaMUPapoWVrO4zscYZjqOaGPBkWJdtaTFVBAVapwwuYD4gOlajosuoJM(MwXr36m2XOUGwDqrqEobtIhDuQ5P5Ggh1TLV(SaP0E30EbESSOKtcauXMXaYwZODaD85r7OUS3nTxGhllk5ABmJM(MwXr36m2XOUGwDqrxZNMXPgHIZLtIBCHD(94aPYljvXnLtGhABmhKgivEjPkUPp5SjRzOTXCWl9yCmZQNNrWhB(0moLsSeRur36m2XbmTsIJAZhzcOBc7Dt7f4XYIsof5BDSESu1MxGhn9nTIJU1zSJrDbT6GQ5tZ4uJqXjNnzndkY36y9yPQnVaFWl9yCmZQNNrWhB(0moLsSeRur36m2XbmTsIJAZhzcOBc7Dt7f4XYIsojaqfBgdiBnJ2b0XNhTJ6YE30EbESSOKZtBdNg1MJM(MwXr36m2XOUGwDq18PzCQrO4KZMSMbpTnCAuBEWl9yCmZQNNrWhB(0moLs6OISyjwPIU1zSJdEAB40O28rsf6rhO7ISdg25(wmVPiz6rxn4NKLhCd7C8a6iHcaMb(ncfprxnip)27HN1nqb65E30EbESSOKtcauXMXaYwZODaD85r7OUS3nTxGhllk5iAs3urSYWPOvhu01wnJCE(9GnN4q9us3fzhSrh1PwNXy0vNADgJJN20EbEtr)iBwNADgh9AGPpjDyjwPIU1zSJdenPBQiwz40rAAVaFGOjDtfXkdNgM2GLXOdM2lWhiAs3urSYWPbna70tjDM2lWhWPnpdtBWYy0bt7f4d40MNbna70V3nTxGhllk5W0kjoQnhT6GclXkv0ToJDCatRK4O2CkVilb55eiWX61bsPrMWE30EbESSOKZtBdNg1MJwDqHLyLk6wNXoo4PTHtJAZP869UP9c8yzrjhoT5jA1bfb55e0k2ATH96ZcKs7Dt7f4XYIsU2gZOPVPvC0ToJDmQlOvhueKNtGahRxhiLsoBYAgABmh8spghZS65ze8XMpnJtPmH9UP9c8yzrjN2uQOP9c8rvHD0EBGrDkLI79(E30EbECGqbat3uGhJQTXmA6BAfhDRZyhJ6cA1bfDYZl946ZYLJUMpnJtncfNuIBCHD(94aPYljvXnLtGhABmhKgivEjPkUPpxo6mTx55iHh9UYY4gJkHKsCJlSZVhhivEjPkUPCc8qBJ5G0aPYljvXn95YrNP9kphj8O3vwg3yujKS5tZ4uJqX0tFscYZjq4X2gZHjG2NC2K1m02yo4LEmoMz1ZZi4JnFAgNsjQe27M2lWJdekay6Mc8yzrjNI8TowpwQAZlWJM(MwXr36m2XOUGwDq18PzCQrO4KeKNtGWJdaWFQMdtaTFVBAVapoqOaGPBkWJLfLCEAB40O2C0030ko6wNXog1f0QdQMpnJtncfNKG8CceE0tBdNgMaAFYztwZGN2gonQnp4LEmoMz1ZZi4JnFAgNsjDurwSeRur36m2XbpTnCAuB(iPc9Od0Dr2bd7CFlM3uKm9ORg8tYYdUHDoEaDKqbaZa)gHIN7Dt7f4XbcfamDtbESSOKJOjDtfXkdNIwDqrqEobcps0KUPIyLHtdtaTFVBAVapoqOaGPBkWJLfLCyALeh1MJwDqrqEobcpIPvsCycO9jXsSsfDRZyhhW0kjoQnNYl7Dt7f4XbcfamDtbESSOKdN28eT6GIG8CceEeN28mmb0(9UP9c84aHcaMUPapwwuYHPvsCuBoA1bfb55ei8iMwjXHjG2V3nTxGhhiuaW0nf4XYIsopTnCAuBoA1bfb55ei8ON2gonmb0(9(E30EbECqdaQjG2JYMMKx55iMM1dOPVPvC0ToJDmQlOHIo6K3e4bBAsELNJyAwpeN2GLXbV0JRplxUjWd20K8kphX0SEioTblJdnpy1JrFc0NKUjWd20K8kphX0SEioTblJdy30Jr)15YjVjWd20K8kphX0SEiMYMkGDtpMYl0NuEM2lWhSPj5vEoIPz9qmLnvO(4rvzPEs5zAVaFWMMKx55iMM1dXPnyzCO(4rvzPEs5zAVaFWMMKx55iMM1dH6JhvLL60N0ToJ9GxdC0bXzXuEvUCM2R8CKFEOymLjKuEtGhSPj5vEoIPz9qCAdwgh8spU(SK8ZD2n0F9vjDRZyp41ahDqCwmLxT3nTxGhh0aGAcO9YIsUd3MkEA(rN3qtFtR4OBDg7yuxqRoO0GbcqucuVJr)1jDRZyp41ahDqCwmLuTKYtdaQjG2h8kJBC8q23cKs5YDQSup28Gvpg9YVKNkl1Jnpy1JPmH9UmTqQhHYCJWrCHuW8CHoyH4BVEH0kpDH0kpDHTLNFajEHNMF05TfslL)fsJxyt(l808JoVry)eTfc6fAUInSVqDkRhVW6SWYXlKgO90fw(E30EbECqdaQjG2llk5i4gZ9y0QdknyGaeLa17ykrD9E30EbECqdaQjG2llk5QxB9BEbE0QdknyGaeLa17ykrD9ExMwi19TfA)CHpWxind78cPMQAH8ZD2n0wibPVqtHbluMLe7lKeZlS8fEa9crNCpEH2pxy9ARF8E30EbECqdaQjG2llk58kJBC8q23qRoO4N7SBHjFkD5usfzKlhb55eiWX61bsPC5OZnf)EqQ5P5GoWVrO4zsCkODg7r3NO)A637Y0cL5RSuFHe8cP1GpBHoyHKyEHidSAUqWVq5VnMxy9lmp33wyEUVTWV0P8cXLtAEbEmAlKG0xyEUVTW2AwDBVBAVapoOba1eq7LfLC4uBcOnWQjA1bfb55e8kJBC8q23cKsjjipNabowVomb0(KAWabikbQ3XONkjNap02yoinqQ8ssvCJ(lb5lj)CNDJsQiJKZMSMH2gZbV0JXXmREEgbFS5tZ4ukXsSsfDRZyhhW0kjoQnFKjGUjK0ToJ9GxdC0bXzXuE1E30EbECqdaQjG2llk5i4gZ946ZqRoOiipNGxzCJJhY(wGukxocYZjqGJ1RdKs7Dt7f4XbnaOMaAVSOKtc4f4rRoOiipNabowVoqkT3nTxGhh0aGAcO9YIsU2YZpGehpn)OZBOvhueKNtGahRxhiLYL7uzPES5bREm6t4YExMwi1JqzUr4iUWrnL1Jx4aa8JRFHPaN2cTFUqStEoluvJ5f6PfgTfA)CHd2ncEHeS7CVqnyGW8f28Gv)cBgF717Dt7f4XbnaOMaAVSOKtd(8GXC0t5iwQ6YXOvhu0nbEOlPqZdw9ykPssnyGaeLa17y0FDYjWdTnMdEPhxFws(5o7wyYNsxoLOsqg0NlhbaJtEQSup28Gvpg9xT3LPfkZB3i4f6PCZleNcivZfsWlCa08c1GFwEbE8cb)c9uEHAWpjlFVBAVapoOba1eq7LfLC8GeGg3rcWprRoOiipNGxzCJJhY(wGukxo60GFswEyYSu0ukoRSxZb(ncfpPFVBAVapoOba1eq7LfLCKyowopG377Dt7f4XHtPuCJQTXmA6BAfhDRZyhJ6cA1bvERlJqXHtPuCJ6sYMpnJtncfNCc8qBJ5G0aPYljvXn6rjXnUWo)ECGu5LKQ4EVBAVapoCkLIBzrjxBJz0QdQ8wxgHIdNsP4gvc7Dt7f4XHtPuCllk5uKV1X6XsvBEbE0QdQ8wxgHIdNsP4g117Dt7f4XHtPuCllk5W0kjgT6GkV1LrO4WPukUrrL9UP9c84WPukULfLC40MN799UP9c84WP(cNYnkSL3Y4ydSgT6GIG8CcylVLXXgyDO5bREm6VEVBAVapoCQVWPCllk5K6AWurAT5POvhu0nBYAgK6AWurAT5PbV0JXXmREEgbFS5tZ4ukVEK0HLyLk6wNXooi11GPI0AZtL9c9jXsSsfDRZyhhK6AWurAT5PuEH(C5WsSsfDRZyhhK6AWurAT5Pus31YEzKUP43dyJGBha80a)gHIN0V3nTxGhho1x4uULfLCDjHM(MwXr36m2XOUGwDq18PzCQrO4KZMSMHUKcEPhJJzw98mc(yZNMXPuM36YiuCOlPOx6X4K0rhb55e8kJBC8q23cKs5YPba1eq7dELXnoEi7BHMhS6XuEf9jPJG8Ccekay6Mc84aPuUCYZnf)EGqbat3uGhh43iu8K(KtGh6skinqQ8ssvCJEusCJlSZVhhivEjPkUZLtEUP43dyJGBha80a)gHIN0V3nTxGhho1x4uULfLCylVLXXgynA1bfb55eWwElJJnW6qZdw9y0tNgmqaIsG6DSSxOFKY3iLr469UP9c84WP(cNYTSOK7WnqxasCKOCgTbB0r(5o7gQlOPVPvC0ToJDmQl7Dt7f4XHt9foLBzrj3HBGUaK4ir5mA6BAfhDRZyhJ6cA1bfb55eiWX61bsPKUP43dyaPkcorpLJhqZypWVrO45EFVBAVapoaOPOXwEgf2Tgt2zmA1bfb55eszR9i4e9uosRuZaP0E30EbECaqtrJT8SSOKdt(NQz0u1Zr9efvgzMEU3nTxGhha0u0ylpllk5gaG)unJMQEoQNOOYiZ0t0QdkcYZjmaa)46JhqpeiLssxt(8b0zCqBoFJJAYUa5Y1KpFaDghMTrML6rWjozwkEaAsm9jXsSsfDRZyhh802WPrT5OpHKYZnf)Eqr(whRhlvT5f4d8BekEU3nTxGhha0u0ylpllk5szR9i4e9uosRut0Qdk(5o7g6VwgjNap0LuO5bREmLujCvs60aGAcO9bVY4ghpK9TqZdw9ykrjFHRYLRjF(a6moOnNVXrnzxa6tsqEobTITwByV(Sa2n9y0FjP8iipNGjXJok180CqJJ62YxFwGukP8iipNaHcaMksShiLskpcYZjqGJ1RdKsjPtdaQjG2h0Gppymh9uoILQUCCO5bREmLYx4QC5KNgKNF79WxzPE8ym9jPtEAqE(T3dpRBGc0ZC50aGAcO9bBAsELNJyAwpeAEWQhtjQRYLBc8GnnjVYZrmnRhItBWY4qZdw9ykPA0V3nTxGhha0u0ylpllk5gaGFC9XdOhqRoO4N7SBO)AzKCc8qxsHMhS6XusLWvjPtdaQjG2h8kJBC8q23cnpy1JPefvcxLlxt(8b0zCqBoFJJAYUa0NKG8CcAfBT2WE9zbSB6XO)ss5rqEobtIhDuQ5P5Ggh1TLV(SaPus5rqEobcfamvKypqkLuEeKNtGahRxhiLssNgautaTpObFEWyo6PCelvD54qZdw9ykLVWv5Yjpnip)27HVYs94Xy6tsN80G88BVhEw3afON5YPba1eq7d20K8kphX0SEi08GvpMsuxLl3e4bBAsELNJyAwpeN2GLXHMhS6Xus1OFVV3nTxGhhWoBkpfLeaOInJbKTMr7a64ZJ2rDzVltlu(BJ5f(mpXlSbKzPQBl8kzGoSqWzHLJxOI)mpDHMVqBHd1xdKdl0blet2sggVqCAZt8cNs8E30EbECa7SP8uzrjxBJz0030ko6wNXog1f0Qdk6Map02yoinqQ8ssvCJ(lHRYLR5tZ4uJqX0NC2K1m02yo4LEmoMz1ZZi4JnFAgNszc5YrqEobcCSEDO5bREm6VS3nTxGhhWoBkpvwuYPiFRJ1JLQ28c8OvhuyjwPIU1zSJdEAB40O2C0FDYMpnJtncfNC2K1mOiFRJ1JLQ28c8bV0JXXmREEgbFS5tZ4ukVkjDAWabikbQ3XOOsUCtGhuKV1X6XsvBEb(qZdw9y0FvUCYBc8GI8TowpwQAZlWh8spU(m637Y0ctSjDtTqeLHtxyHxib7o3l0tTFHyNnLNUqK0MNl08fE9cDRZyhV3nTxGhhWoBkpvwuYr0KUPIyLHtrRoOWsSsfDRZyhhiAs3urSYWPuMWE30EbECa7SP8uzrjNeaOInJbKTMr7a64ZJ2rDzVBAVapoGD2uEQSOKdN28eT6Gsdgiarjq9og9ujjwIvQOBDg74GN2gonQnh9xT337M2lWJdeMYEnJct(NQz0QdkcYZjWAvjH5igOSomb0(KeKNtG1QscZrf5BDycO9jPR5tZ4uJqX5YrNP9kph5Nhkgt5LKM2R8CCc8aM8pvZO30ELNJ8ZdfJPN(9UP9c84aHPSxZYIsoSBnMSZy0QdkcYZjWAvjH5igOSo08GvpMsTH9OxdCUCeKNtG1QscZrf5BDO5bREmLAd7rVg49UP9c84aHPSxZYIsoSB9PAgT6GIG8CcSwvsyoQiFRdnpy1JPuByp61aNlhgOSoYAvjHzkLXE30EbECGWu2RzzrjhT28u0QdkcYZjWAvjH5igOSo08GvpMsTH9OxdCUCkY36iRvLeMPugceSeRfuCrgxlCHlea]] )


end
