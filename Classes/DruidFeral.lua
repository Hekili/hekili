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
        local tick_time = t.tick_time / haste
        local ttd = min( fight_remains, target.time_to_die )


        local aura = action
        if action == "primal_wrath" then aura = "rip" end

        local duration = class.auras[ aura ].duration * ( action == "primal_wrath" and 0.5 or 1 )
        local app_duration = min( ttd, class.abilities[ this_action ].apply_duration or duration )
        local app_ticks = app_duration / tick_time

        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = max( 0, min( remains + duration, 1.3 * t.duration * 1, ttd ) )
        end

        potential_ticks = ( pmult and persistent_multiplier or 1 ) * min( duration, ttd ) / tick_time

        if action == "thrash_cat" then
            local fresh = max( 0, active_enemies - active_dot.thrash_cat )
            local dotted = max( 0, active_enemies - fresh )

            return fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks )
        elseif action == "primal_wrath" then
            local fresh = max( 0, active_enemies - active_dot.rip )
            local dotted = max( 0, active_enemies - fresh )

            return fresh * app_ticks + dotted * ( potential_ticks - remaining_ticks )
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
                    return tick_calculator( t, this_action, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
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
                    return tick_calculator( t, this_action, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
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
                    return tick_calculator( t, this_action, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
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
                    return tick_calculator( t, this_action, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
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
                    return tick_calculator( t, this_action, false )
                end,

                ticks_gained_on_refresh_pmultiplier = function( t )
                    return tick_calculator( t, this_action, true )
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
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", 0.2 )
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
            elseif k == "primal_wrath" then return debuff.rip
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
                        return 25 * -0.25
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

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 132140,

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
                -- going to require 50 energy and then refund it back...
                if talent.sabertooth.enabled and debuff.rip.up then
                    -- Let's make FB available sooner if we need to keep a Rip from falling off.
                    local nrg = 50 * ( buff.incarnation.up and 0.8 or 1 )

                    if energy[ "time_to_" .. nrg ] - debuff.rip.remains > 0 then
                        return max( 25, energy.current + ( (debuff.rip.remains - 1 ) * energy.regen ) )
                    end
                end
                return 50 * ( buff.incarnation.up and 0.8 or 1 )
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

            usable = function () return buff.apex_predator.up or combo_points.current > 0 end,
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

            spend = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 1392547,

            apply_duration = function ()
                return mod_circle_dot( 2 + 2 * combo_points.current )
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

            spend = 60,
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
                    if legendary.cateye_curio.enabled then return -10 end
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
            cost = function () return max( 1, class.abilities.brutal_slash.spend ) end,

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
                    if legendary.cateye_curio.enabled then return 35 * -0.25 end
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
                    if legendary.cateye_curio.enabled then return -10 end
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
            texture = 538771,

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
                unshift()
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


    spec:RegisterPack( "Feral", 20201227, [[dSeSbbqiOi9ivQYLivjztQeFsLkWOiv1PKkzvqr8kuKzjvClvQODj4xOGHbf1XublJuPNHsQPHIQRjvQTHIsFJufACKQOZPsvzDKQuMhkj3tfTpsfhuLQQSquIhsQs1evPQYgvPc9rvQQQojPkOvkjntsvGBsQsyNQu(jkk0qjvjAPOOGNkXuHcFLuLunwsvszVa)vObJQdtzXk5XKmzL6YeBwkFgknAPQtlA1Qub9AjXSr62sQDd63QA4KYXvPQQSCfphX0P66q12vH(ok14vPsNhfA9OOO5RsA)qgCaGbOSnxa30fZ6I5d6QREmG57txMFOBqXzutafntvXWkGc0Qfq5okJrbfnJr6BBagGc5XhLak9URr0BmWa207Xxb1xZajRXPMNpunwZzGK1kgaLfEsD9qiybkBZfWnDXSUy(GU6Qhdy((oWS6QlOq0ef42bmZAqPp3BbcwGYwikq5Ei(DugJI43Vbp3OQ3dXVFIsQxYG46YSDqCDXSUygvfv9Ei(DugJI43F6L6biUYGiUrjpIVeeV94WnIBoI37UgrVXadytIhWMEp(kO(Ag0RzqMPngdmREEFmRspVV7JzBDBnL0TsoCO7TzS2WSEUTwdv9EiUEV3GyfeFp45o8SPSf7OevMFEaXv9IQcbX9hX3dEUdpBkBXokrL5bqrB(wsfq5Ei(DugJI43Vbp3OQ3dXVFIsQxYG46YSDqCDXSUygvfv9Ei(DugJI43F6L6biUYGiUrjpIVeeV94WnIBoI37UgrVXadytIhWMEp(kO(Ag0RzqMPngdmREEFmRspVV7JzBDBnL0TsoCO7TzS2WSEUTwdv9EiUEV3GyfeFp45o8SPSf7OevMFEaXv9IQcbX9hX3dEUdpBkBXokrL5buvuvt55djbTruF9YCMoz4OnPTOshOvlNThFuAXv6sNJgfxoXmQ69q8s)iBe)eXXChe)2dVtc00i9VJ4mdwfbXpr8dDq8c00i9VJ4mdwfbXprCD7G46b6Hi(jIZ6oiEHDQji(jIZCuvt55djbTruF9YCMoz4OnPTOshOvlNTKsLPZrJIlNygv9EiErzubXzNEpI3BexcOQMYZhscAJO(6L5mDYWrBsBrLoqRwoNul6PQcPZrJIlN6ruvt55djbTruF9YCMoz4OnPTOshOvlNE)yK(ONQkKohnkUCQNOQMYZhscAJO(6L5mDYWrBsBrLoqRwo9(Xi9rpvviDoAuC58qNSD6gvGEyr)F7g9HKGaTfv2xVQE4gp9GBexITFIl6)7GaTfv2OQMYZhscAJO(6L5mDYqLeUhzhjA5Kobv1uE(qsqBe1xVmNPtgwV7uzhBuJrzZoHyJ(F3eIQAkpFijOnI6RxMZ0jdAZZM2jBNl8wlu)pSscJTFQd7Nnev1uE(qsqBe1xVmNPtguMhB)u3jBNl8wlu)pSscJTFQd7Nnevfv1uE(qY5GdJMYZhgPjX7aTA5CzudQKoz7CH3AH6)HvsyS9tDax7cMUh8ChE2u2IDuIkZrvnLNpKW0jdKk4uACzKEuvt55djmDYaXTHGpyLoz7CH3AHEXgp(TO3lr2jDhW1qvnLNpKW0jdeCylhPt2oXuTrogXQ2HdbcoSLJGQAkpFiHPtg8eRmKydFySt2ox4TwqzES9tDy)SHOQMYZhsy6KbL5X2p1DY25cV1ckZJTFQd7Nnev9EiUE58SPio7EbkhLbX1Ecjxubv1uE(qctNmOnpBANSDIDECTRxxpHGQAkpFiHPtg6fB843IEVezN0DNSDkqzWYiRyoMVSFpmwfjmsTLqIomp09f93VhMulmsTLqIomp091RQVE9rTpHoHvD31f1)09Zgg8eRmKydFymmsTLqIoNmp09LfERfuuXgLr8eInqCtvHvhUGPl8wlyAYDJAJSn)hsun2XeInGRDbtv)t3pByq9WJFfj69sKOLt6KaU2L9GN7WZMYwSJsuzoQQP88HeMozO(FyLegB)u3jBNcugSmYkMJ5l73dJvrcJuBjKOdZdDFr)97Hj1cJuBjKOdZdDF9Q6RxFu7tOtyv3DDr9pD)SHbpXkdj2WhgdJuBjKOZjZdDFzH3AbfvSrzepHyde3uvy1Hly6cV1cMMC3O2iBZ)HevJDmHyd4AxWu1)09Zggup84xrIEVejA5KojGRDzp45o8SPSf7OevMJQEpeNzekioP)DeN4Ir9Euvt55djmDYWGdJMYZhgPjX7aTA5K4Ir9(oz7CH3AbsVTF21cDhW1UEDH3AbT5ztd4AOQMYZhsy6KbLrPrt55dJ0K4DGwTCQ(NUF2quvt55djmDYWGdJMYZhgPjX7aTA5SLWK0ltNSDQ(61h1(e6eDo1V778OnPTOsO94JslUsx6cv9EiUEbo1Z7eRAJ4exmQ3JQAkpFiHPtgugLgnLNpmstI3bA1YjXfJ69DY25cV1clsmHQaU21Rl8wlqW3BbgT6foPpGRHQEpehJEbXRFIJ4YD1eijpkiolyG4kgvubX1hJ(ri9iEPFKnIxyNAcIREIJ4ho0nIlqzWYyheV2QiiobFeeNTG4kdI41wfbX9EZr8eI4mhXXs)LrjDHQAkpFiHPtg0(NghH84Js6KTt3Oc0dl6)B3OpKeeOTOY(YcV1cl6)B3OpKe2pB4f9fOmyzKjwh6gteOmyzmmcwbYK(mhZyYcV1ckQyJYiEcXgW16QlwP)HdDFN6YAmzH3AHeQSbAE(WyLeIn(TO3lX7qCiwQeW166IP88OexE0NelwziNygv1uE(qctNmm4WOP88HrAs8oqRwox0)3UrFiPt2oDJkqpSO)VDJ(qsqG2Ik7ll8wlSO)VDJ(qsy)SHOQMYZhsy6KHMmVkFCsCLU0rXOIkr3gSItop0jBNl8wlyAYDJAJSn)hsun2XeInGRDrFm1nQa9WI()2n6djbbAlQSVEDH3AHf9)TB0hsc4ADHQAkpFiHPtgAYy0yBeiZKXoz7u91RpQ9j0jSI1OQMYZhsy6KbT)PXrip(OKoTFIq5U(5buvt55djmDYWyvKokgvuj62GvCY5Hoz7u)rAJq6TfvUEvtgssCb6XACQNA0ugD2VhgRIe0QXPEQrtz66YEWZDySksWtvfseRLqzhFyCK2iKEDiAcLgDBWkojqyNAsuzoMO7DQlQQP88HeMozO(FylhjQmVJIrfvIUnyfNCEOt2ohPncP3wu5YEWZDO(Fylhj4PQcjI1sOSJpmosBesVoenHsJUnyfNeiStnjQmht09o1fv1uE(qctNmO9pnoc5XhL0P9tek31ppGQAkpFiHPtgwdUB0iHAK(oz7u)XYDuokqpy7njKqD0)at12DJQEBWkK7u1BdwHeBJP88HgTlmzevVnyLON1sxx0NOjuA0TbR4KWAWDJgjuJ0JjMYZhgwdUB0iHAK(W2QnSIELP88HH1G7gnsOgPpOEI3Lo6BkpFyG0pYoSTAdROxzkpFyG0pYoOEI3fQQP88HeMozGWo1KOY8oz7KOjuA0TbR4KaHDQjrL56CGPfERfwKycvbCnmrxuvt55djmDYaPFKDNSDUWBTGIk2OmINqSbCnuvt55djmDYWyvKokgvuj62GvCY5Hoz7CH3AHfjMqvax7YEWZDySksWtvfseRLqzhFyCK2iKED0fv1uE(qctNmOmknAkpFyKMeVd0QLZwsPYGQIQAkpFijSO)VDJ(qY5yvKokgvuj62GvCY5Hoz7uFm1tvLeI96v9hPncP3wu5IMmKK4c0J14up1OPm6SFpmwfjOvJt9uJMY0vxxw4Twy5XXQiH9ZgEzp45omwfj4PQcjI1sOSJpmosBesVoN6IQAkpFijSO)VDJ(qctNmqXH2etirlhZZh2rXOIkr3gSItop0jBNJ0gH0BlQCzH3AHLhR)h2Yrc7Nnev1uE(qsyr)F7g9HeMozW7hJ0hvM3rXOIkr3gSItop0jBNJ0gH0BlQCzH3AHLh9(Xi9H9ZgEzp45o49Jr6JkZdEQQqIyTek74dJJ0gH0RJEIQAkpFijSO)VDJ(qctNmSgC3Orc1i9DY25cV1clpUgC3Orc1i9H9ZgIQAkpFijSO)VDJ(qctNmqyNAsuzENSDUWBTWYJe2PMe2pB4fIMqPr3gSItce2PMevMRZbuvt55djHf9)TB0hsy6Kbs)i7oz7CH3AHLhj9JSd7Nnev1uE(qsyr)F7g9HeMozGWo1KOY8oz7CH3AHLhjStnjSF2quvt55djHf9)TB0hsy6KbVFmsFuzENSDUWBTWYJE)yK(W(zdrvrvVhIJbZ49JzuVH43ezJ4(J4egHkeND69io707r8XokWhNG4TrGmtgrC29ceXzli(Gdr82iqMjJldU7G4)G4MtfJ4iUQxuvq8SH4PtqC2)49iE6OQMYZhscQ)P7Nn8CjdrMkDY2P6RxFu7tOt05K1OQMYZhscQ)P7NnKPtgsOYgO55d7KTt1xV(O2NqNOZjRrvVhIJXWiIBWnIdFhXzBexqCmUJiUaLblJDq8fUJ4gL8i(DioXrCCIG4PJ4TFqCMPmvqCdUr8eQSbsqvnLNpKeu)t3pBitNm4jwziXg(WyNSDkqzWYyylTuLUoD391Rl8wlSiXeQc4AxVQVBub6bTr2M)tqG2Ik7lK(FCH4r33SI1DHQEpexViX27i(sqC2ZdXI4(J44ebXl1cDJ4peXzgSkcINqe)OmmI4hLHrehMQEbXjPJBE(qsheFH7i(rzyeXhBekJOQMYZhscQ)P7NnKPtgi92(zxl0DNSDUWBTGNyLHeB4dJbCTll8wlSiXeQc7Nn8I6RxFu7tOtyfZVSFpmwfjOvJt9uJMYWQdbM9IaLblJ6WCmJQAkpFijO(NUF2qMozyjdrMkjeBNSDUWBTGNyLHeB4dJbCTRxx4TwyrIjufW1qvnLNpKeu)t3pBitNmO9E(Woz7CH3AHfjMqvaxdv1uE(qsq9pD)SHmDYWyhf4JtITrGmtg7KTZfERfwKycvbCTRxBj2EposTLqcR09aQ69qCmygVFmJ6nexV3lQkiE9)WkjeX7FNnIBWnItC8wdXPzfbX9(K0bXn4gXRngxcIVe3LbXvF9YCeFKAlHi(iegHkuvt55djb1)09ZgY0jdQhE8RirVxIeTCsN0jBN6VFpmPwyKAlHeDy(f1xV(O2NqNWkwFz)EySksWtvLeITRRxBj2EposTLqcR6gv9EiUEHX4sqCVxgbXj9poDJ4lbXR)rqC1d3PNpKG4peX9EbXvpCJNoQQP88HKG6F6(zdz6KbPw7zltC9WDNSDUWBTGNyLHeB4dJbCTRx1x9WnE6HTiArJsfSPbvsqG2Ik7UqvnLNpKeu)t3pBitNmyBtZZJsKW2M6okgvuj62GvCY5Hoz7u91RpQ9j0jNDFbt3VhSTP55rjsyBtDCB1gwj4PQscXIQAkpFijO(NUF2qMozaNiX0LAcQkQQP88HKqlPuzohRI0rXOIkr3gSItop0jBNhTjTfvcTKsL58WLrAJq6TfvUSFpmwfjOvJt9uJMYWQtnzijXfOhRXPEQrtzqvnLNpKeAjLkdtNmmwfPt2opAtAlQeAjLkZPUOQMYZhscTKsLHPtgO4qBIjKOLJ55d7KTZJ2K2IkHwsPYCYAuvt55djHwsPYW0jde2PM0jBNhTjTfvcTKsL5K5OQMYZhscTKsLHPtgi9JSrvrvnLNpKeAjmj9YCsSJgwjoVnDY25cV1ce7OHvIZBty)SHxVUWBTaXoAyL482egP2siHv6R(61h1(e6emHzz6qxycMdSgv9EiUEHvrqCc(iiU)ioZuMhX9EbXpAtAlQG4KhXjFTG4pDJ4hnkUG47hEh4iUa3ioUgIttiwzsiwuvt55djHwctsVmmDYWrBsBrLoqRwoxcXJtQ15OrXLtm3jBNUrfOh0MS2Or2J59bbAlQSrvVhIBkpFij0sys6LHPtgumQOjeB8OnPTOshOvlNlH4Xj168AN12D7C0O4Y5EWZDysTGNQkKiwlHYo(W4iTri9DY2PBub6bTjRnAK9yEFqG2IkBuvt55djHwctsVmmDYG2K1gnYEmVVt2o3dEUdAtwB0i7X8(GNQkKiwlHYo(W4iTri96C0M0wujmPw0tvfY1RenHsJUnyfNe0MS2Or2J596OpRz6aM4gvGEGylz8)9(GaTfv2DHQAkpFij0sys6LHPtgMuRJIrfvIUnyfN0jBNJ0gH0BlQCzp45omPwWtvfseRLqzhFyCK2iKEDoAtAlQeMul6PQc5I(6VWBTGNyLHeB4dJbCTRxv)t3pByWtSYqIn8HXWi1wcj60Dxx0FH3AHf9)TB0hsc4AxVIPUrfOhw0)3UrFijiqBrLDxx2VhMulOvJt9uJMYWQtnzijXfOhRXPEQrtzUEftDJkqpqSLm()EFqG2Ik7UqvnLNpKeAjmj9YW0jdnzEv(4K4kDPtTD3OaLblJNh6OyurLOBdwXjNhqvrvVhIZmyveehkYMG4ZJJTNYiI3nM1Rq8VH4PtqCQaX69iU5iUH41jmRXRrC)rCc(OzecIt6hztq8TMGQAkpFijqCXOE)5GdJMYZhgPjX7aTA5Cr)F7g9HKoz70nQa9WI()2n6djbbAlQSVSWBTWI()2n6djH9ZgIQAkpFijqCXOEptNmO9pnoc5XhL0P9tek31ppGQAkpFijqCXOEptNmmwfPJIrfvIUnyfNCEOt2o1F)EySksqRgN6PgnLHvhcDF96iTri92IkDDzp45omwfj4PQcjI1sOSJpmosBesVo6IQEpeNLb3nkIxOgPhXtcIVe3LbX9EdI4exmQ3J4L(r2iU5ioRrC3gSItqvnLNpKeiUyuVNPtgwdUB0iHAK(oz7KOjuA0TbR4KWAWDJgjuJ0RJUOQMYZhscexmQ3Z0jdA)tJJqE8rjDA)eHYD9ZdOQ3dXl9JSr82piEZiUmiUExVeXXkqzmpFiQQP88HKaXfJ69mDYaPFKnQkQQP88HKWYOgujNeCylhPt2ox4Twqu0uJirYtTjSF2Wll8wlikAQrKifhAty)SHx0FK2iKEBrLRx13uEEuIcuQtHOZHlMYZJsC)EGGdB5iSYuEEuIcuQtH0vxOQMYZhsclJAqLW0jde3gc(Gv6KTZfERfefn1isK8uBcJuBjKOJYiE0ZA561fERfefn1isKIdTjmsTLqIokJ4rpRfuvt55djHLrnOsy6KbIBtlhPt2ox4Twqu0uJirko0MWi1wcj6OmIh9SwUEL8uBIIIMAerhmJQAkpFijSmQbvctNmWEmVVt2ox4Twqu0uJirYtTjmsTLqIokJ4rpRLRxP4qBIIIMAerhmdkhLHKpeCtxmRlMpO7bwdkSTbMqSeqrV(9hZWn9WB3)1BioIJrVG4zT2poI3(bXVd2sZWP(DaIpY9p8CKnIt(AbXnC)Rnx2iUQ3GyfsavvpiHcIRRU6nexV)WJY4YgXlzTEhXjmcD7UiUEfI7pIRhGBi(opMK8Hi(RjJ5)G46ZqxiU(6E3UcOQOQ6H1A)4YgX1te3uE(qeNMeNeqvbfAsCcadqPLuQmama3oaWaueOTOYgWcOOM0Ljnq5OnPTOsOLuQmi(jIFaXVG4J0gH0BlQG4xq897HXQibTACQNA0ugeNvNiUMmKK4c0J14up1OPmGIP88HGYyveqrXOIkr3gSIta3oaCWnDbyakc0wuzdybuut6YKgOC0M0wuj0skvge)eX1fumLNpeugRIaCWnwdWaueOTOYgWcOOM0Ljnq5OnPTOsOLuQmi(jIZAqXuE(qqP(FylhjQmh4GBmhGbOiqBrLnGfqrnPltAGYrBsBrLqlPuzq8teN5GIP88HGcHDQjrL5ahCRBagGIP88HGcPFKnOiqBrLnGfGdCqzzudQeagGBhayakc0wuzdybuut6YKgOSWBTGOOPgrIKNAty)SHi(feFH3AbrrtnIeP4qBc7NneXVG46J4J0gH0BlQG4xVI46J4MYZJsuGsDkeexhe)aIFbXnLNhL4(9abh2YrqCwH4MYZJsuGsDkeeVleVlqXuE(qqHGdB5iahCtxagGIaTfv2awaf1KUmPbkl8wlikAQrKi5P2egP2sibX1bXvgXJEwli(1Ri(cV1cIIMAejsXH2egP2sibX1bXvgXJEwlGIP88HGcXTHGpyfGdUXAagGIaTfv2awaf1KUmPbkl8wlikAQrKifhAtyKAlHeexhexzep6zTG4xVI4KNAtuu0uJiiUoioMbft55dbfIBtlhb4GBmhGbOiqBrLnGfqrnPltAGYcV1cIIMAejsEQnHrQTesqCDqCLr8ON1cIF9kItXH2effn1icIRdIJzqXuE(qqH9yEpWboOSLMHtDagGBhayakc0wuzdybumLNpeugCy0uE(WinjoOOM0LjnqzH3AH6)HvsyS9tDaxdXVG4ykIVh8ChE2u2IDuIkZbfAs8i0QfqzzudQeGdUPladqXuE(qqHubNsJlJ0dkc0wuzdyb4GBSgGbOiqBrLnGfqrnPltAGYcV1c9InE8BrVxISt6oGRbkMYZhcke3gc(Gvao4gZbyakc0wuzdybuut6YKgOGPiU2ihJyv7WHabh2Yraft55dbfcoSLJaCWTUbyakc0wuzdybuut6YKgOSWBTGY8y7N6W(zdbft55dbfpXkdj2Whgbo4gZcWaueOTOYgWcOOM0LjnqzH3AbL5X2p1H9ZgckMYZhckkZJTFQbo4MEeGbOiqBrLnGfqrnPltAGc25X1q8Rxr81tiGIP88HGI28SPahCtpbyakc0wuzdybuut6YKgOiqzWYiIZkeN5ygXVG473dJvrcJuBjKG46G4mp0nIFbX1hX3VhMulmsTLqcIRdIZ8q3i(1RiU6RxFu7tOtqCwH4DJ4DH4xqC1)09Zgg8eRmKydFymmsTLqcIRZjIZ8q3i(feFH3AbfvSrzepHyde3uvqCwH4hq8lioMI4l8wlyAYDJAJSn)hsun2XeInGRH4xqCmfXv)t3pByq9WJFfj69sKOLt6KaUgIFbX3dEUdpBkBXokrL5GIP88HGsVyJh)w07Li7KUbo429bWaueOTOYgWcOOM0LjnqrGYGLreNvioZXmIFbX3VhgRIegP2sibX1bXzEOBe)cIRpIVFpmPwyKAlHeexheN5HUr8RxrC1xV(O2NqNG4ScX7gX7cXVG4Q)P7Nnm4jwziXg(WyyKAlHeexNteN5HUr8li(cV1ckQyJYiEcXgiUPQG4ScXpG4xqCmfXx4TwW0K7g1gzB(pKOASJjeBaxdXVG4ykIR(NUF2WG6Hh)ks07LirlN0jbCne)cIVh8ChE2u2IDuIkZbft55dbL6)HvsyS9tnWb3oGzagGIaTfv2awaft55dbLbhgnLNpmstIdkQjDzsduw4TwG0B7NDTq3bCne)6veFH3AbT5ztd4AGcnjEeA1cOqCXOEpWb3oCaGbOiqBrLnGfqXuE(qqrzuA0uE(WinjoOqtIhHwTakQ)P7Nne4GBh0fGbOiqBrLnGfqXuE(qqzWHrt55dJ0K4GIAsxM0af1xV(O2NqNG46CI46J4DJ43jIF0M0wuj0E8rPfxPliExGcnjEeA1cO0sys6Lb4GBhynadqrG2IkBalGIP88HGIYO0OP88HrAsCqrnPltAGYcV1clsmHQaUgIF9kIVWBTabFVfy0Qx4K(aUgOqtIhHwTakexmQ3dCWTdmhGbOiqBrLnGfqrnPltAGIBub6Hf9)TB0hscc0wuzJ4xq8fERfw0)3UrFijSF2qe)cIRpIlqzWYiIZeIZ6q3ioMG4cugSmggbRarCMqC9rCMJzehtq8fERfuuXgLr8eInGRH4DH4DH4ScX1hXpCOBe)orCDznIJji(cV1cjuzd088HXkjeB8BrVxI3H4qSujGRH4DH4xqCt55rjU8OpjwSYqq8tehZGIP88HGI2)04iKhFucWb3o0nadqrG2IkBalGIP88HGYGdJMYZhgPjXbf1KUmPbkUrfOhw0)3UrFijiqBrLnIFbXx4Twyr)F7g9HKW(zdbfAs8i0Qfqzr)F7g9HeGdUDGzbyakc0wuzdybuut6YKgOSWBTGPj3nQnY28Fir1yhti2aUgIFbX1hXXue3nQa9WI()2n6djbbAlQSr8Rxr8fERfw0)3UrFijGRH4DbkMYZhcknzEv(4K4kDbuumQOs0TbR4eWTdahC7GEeGbOiqBrLnGfqrnPltAGI6RxFu7tOtqCwH4SgumLNpeuAYy0yBeiZKrGdUDqpbyakc0wuzdybuA)eHYDDWTdGIP88HGI2)04iKhFucWb3oCFamafbAlQSbSakQjDzsdu0hXhPncP3wubXVEfX1KHKexGESgN6PgnLbX1bX3VhgRIe0QXPEQrtzq8Uq8li(EWZDySksWtvfseRLqzhFyCK2iKEexheNOjuA0TbR4KaHDQjrL5ioMG46I43jIRlOykpFiOmwfbuumQOs0TbR4eWTdahCtxmdWaueOTOYgWcOOM0LjnqzK2iKEBrfe)cIVh8ChQ)h2YrcEQQqIyTek74dJJ0gH0J46G4enHsJUnyfNeiStnjQmhXXeexxe)orCDbft55dbL6)HTCKOYCqrXOIkr3gSIta3oaCWnDpaWaueOTOYgWcO0(jcL76GBhaft55dbfT)PXrip(OeGdUPRUamafbAlQSbSakQjDzsdu0hXhl3r5Oa9GT3KqcrCDqC9r8diotiETD3OQ3gScbXVtex1BdwHeBJP88HgfX7cXXeeFevVnyLON1cI3fIFbX1hXjAcLgDBWkojSgC3Orc1i9ioMG4MYZhgwdUB0iHAK(W2QnScIZaIBkpFyyn4UrJeQr6dQN4iExiUoiU(iUP88Hbs)i7W2QnScIZaIBkpFyG0pYoOEIJ4DbkMYZhckRb3nAKqnspWb30L1amafbAlQSbSakQjDzsduiAcLgDBWkojqyNAsuzoIRdIFaXzcXx4TwyrIjufW1qCmbX1fumLNpeuiStnjQmh4GB6YCagGIaTfv2awaf1KUmPbkl8wlOOInkJ4jeBaxdumLNpeui9JSbo4MUDdWaueOTOYgWcOOM0LjnqzH3AHfjMqvaxdXVG47bp3HXQibpvvirSwcLD8HXrAJq6rCDqCDbft55dbLXQiGIIrfvIUnyfNaUDa4GB6YSamafbAlQSbSakMYZhckkJsJMYZhgPjXbfAs8i0QfqPLuQmah4GI2iQVEzoadWTdamafbAlQSbSakVgOqehumLNpeuoAtAlQakhnkUakyguoAteA1cO0E8rPfxPlahCtxagGIaTfv2awaLxduiIdkMYZhckhTjTfvaLJgfxafmdkhTjcTAbuAjLkdWb3ynadqrG2IkBalGYRbkeXbft55dbLJ2K2IkGYrJIlGIEeuoAteA1cOmPw0tvfcWb3yoadqrG2IkBalGYRbkeXbft55dbLJ2K2IkGYrJIlGIEckhTjcTAbu8(Xi9rpvviahCRBagGIaTfv2awaLxduiIdkMYZhckhTjTfvaLJgfxaLdGYrBIqRwafVFmsF0tvfcOOM0LjnqXnQa9WI()2n6djbbAlQSr8RxrC1d34PhCJ4sS9tCr)FheOTOYg4GBmladqXuE(qqPsc3JSJeTCsNakc0wuzdyb4GB6ragGIP88HGY6DNk7yJAmkB2jeB0)7MqqrG2IkBalahCtpbyakc0wuzdybuut6YKgOSWBTq9)Wkjm2(PoSF2qqXuE(qqrBE2uGdUDFamafbAlQSbSakQjDzsduw4TwO(FyLegB)uh2pBiOykpFiOOmp2(Pg4ahuAjmj9YaWaC7aadqrG2IkBalGIAsxM0aLfERfi2rdReN3MW(zdr8Rxr8fERfi2rdReN3MWi1wcjioRqC9rC1xV(O2NqNG4ycIZSioti(beVlehtqCmhynOykpFiOqSJgwjoVnahCtxagGIaTfv2awaLxduiIdkMYZhckhTjTfvaLJgfxafmdkhTjcTAbuwcXJtQbkQjDzsduCJkqpOnzTrJShZ7dc0wuzdCWnwdWaueOTOYgWcOOM0Ljnqzp45oOnzTrJShZ7dEQQqIyTek74dJJ0gH0J46G4hTjTfvctQf9uvHG4xVI4enHsJUnyfNe0MS2Or2J59iUoiU(ioRrCMq8dioMG4UrfOhi2sg)FVpiqBrLnI3fOykpFiOOnzTrJShZ7bo4gZbyakc0wuzdybuut6YKgOmsBesVTOcIFbX3dEUdtQf8uvHeXAju2XhghPncPhX1bXpAtAlQeMul6PQcbXVG46J46J4l8wl4jwziXg(WyaxdXVEfXv)t3pByWtSYqIn8HXWi1wcjiUoiE3iExi(fexFeFH3AHf9)TB0hsc4Ai(1RioMI4UrfOhw0)3UrFijiqBrLnI3fIFbX3VhMulOvJt9uJMYG4S6eX1KHKexGESgN6PgnLbXVEfXXue3nQa9aXwY4)79bbAlQSr8Uaft55dbLj1ao4w3amafbAlQSbSak12DJcugSmckhaft55dbLMmVkFCsCLUakkgvuj62GvCc42bGdCqH4Ir9EagGBhayakc0wuzdybumLNpeugCy0uE(WinjoOOM0LjnqXnQa9WI()2n6djbbAlQSr8li(cV1cl6)B3OpKe2pBiOqtIhHwTakl6)B3OpKaCWnDbyakc0wuzdybuA)eHYDDWTdGIP88HGI2)04iKhFucWb3ynadqrG2IkBalGIAsxM0af9r897HXQibTACQNA0ugeNvi(Hq3i(1Ri(iTri92IkiExi(feFp45omwfj4PQcjI1sOSJpmosBespIRdIRlOykpFiOmwfbuumQOs0TbR4eWTdahCJ5amafbAlQSbSakQjDzsduiAcLgDBWkojSgC3Orc1i9iUoiUUGIP88HGYAWDJgjuJ0dCWTUbyakc0wuzdybuA)eHYDDWTdGIP88HGI2)04iKhFucWb3ywagGIP88HGcPFKnOiqBrLnGfGdCqr9pD)SHama3oaWaueOTOYgWcOOM0Ljnqr91RpQ9j0jiUoNioRbft55dbLLmezQaCWnDbyakc0wuzdybuut6YKgOO(61h1(e6eexNteN1GIP88HGscv2anpFiWb3ynadqrG2IkBalGIAsxM0afbkdwgdBPLQ0rCDq8U7gXVEfXx4TwyrIjufW1q8RxrC9rC3Oc0dAJSn)NGaTfv2i(feN0)Jlep6(gXzfIZAeVlqXuE(qqXtSYqIn8HrGdUXCagGIaTfv2awaf1KUmPbkl8wl4jwziXg(WyaxdXVG4l8wlSiXeQc7NneXVG4QVE9rTpHobXzfIZCe)cIVFpmwfjOvJt9uJMYG4ScXpeywe)cIlqzWYiIRdIZCmdkMYZhckKEB)SRf6g4GBDdWaueOTOYgWcOOM0LjnqzH3AbpXkdj2Whgd4Ai(1Ri(cV1clsmHQaUgOykpFiOSKHitLeIf4GBmladqrG2IkBalGIAsxM0aLfERfwKycvbCnqXuE(qqr798HahCtpcWaueOTOYgWcOOM0LjnqzH3AHfjMqvaxdXVEfXBj2EposTLqcIZkex3dGIP88HGYyhf4JtITrGmtgbo4MEcWaueOTOYgWcOOM0LjnqrFeF)EysTWi1wcjiUoioZr8liU6RxFu7tOtqCwH4SgXVG473dJvrcEQQKqSiExi(1RiElX27XrQTesqCwH4DdkMYZhckQhE8RirVxIeTCsNaCWT7dGbOiqBrLnGfqrnPltAGYcV1cEIvgsSHpmgW1q8RxrC9rC1d34Ph2IOfnkvWMgujbbAlQSr8Uaft55dbfPw7zltC9WnWb3oGzagGIaTfv2awaf1KUmPbkQVE9rTpHobXpr8Ur8lioMI473d22088OejSTPoUTAdRe8uvjHybft55dbfBBAEEuIe22udkkgvuj62GvCc42bGdUD4aadqXuE(qqbNiX0LAcOiqBrLnGfGdCqzr)F7g9HeagGBhayakc0wuzdybuut6YKgOOpIJPiUNQkjelIF9kIRpIpsBesVTOcIFbX1KHKexGESgN6PgnLbX1bX3VhgRIe0QXPEQrtzq8Uq8Uq8li(cV1clpowfjSF2qe)cIVh8ChgRIe8uvHeXAju2XhghPncPhX15eX1fumLNpeugRIakkgvuj62GvCc42bGdUPladqrG2IkBalGIAsxM0aLrAJq6Tfvq8li(cV1clpw)pSLJe2pBiOykpFiOu)pSLJevMdkkgvuj62GvCc42bGdUXAagGIaTfv2awaf1KUmPbkJ0gH0BlQG4xq8fERfwE07hJ0h2pBiIFbX3dEUdE)yK(OY8GNQkKiwlHYo(W4iTri9iUoiUEckMYZhckE)yK(OYCqrXOIkr3gSIta3oaCWnMdWaueOTOYgWcOOM0LjnqzH3AHLhxdUB0iHAK(W(zdbft55dbL1G7gnsOgPh4GBDdWaueOTOYgWcOOM0LjnqzH3AHLhjStnjSF2qe)cIt0ekn62GvCsGWo1KOYCexhe)aOykpFiOqyNAsuzoWb3ywagGIaTfv2awaf1KUmPbkl8wlS8iPFKDy)SHGIP88HGcPFKnWb30JamafbAlQSbSakQjDzsduw4Twy5rc7utc7NneumLNpeuiStnjQmh4GB6jadqrG2IkBalGIAsxM0aLfERfwE07hJ0h2pBiOykpFiO49Jr6JkZboWboOy4E)pGsjR17ah4aaa]] )


end
