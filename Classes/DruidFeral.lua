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


    spec:RegisterPack( "Feral", 20201228, [[dSKMebqisv8iOeDjOeWMKQ6tsuPAusuofPQwfsj9kKuZsjClOeAxc(fuQHHe5ysvwgPspdPutJurxdkPTHuIVrQsmojQ4CirvRJuLQ5rQW9us7dj5GqjqleP4HsujtekbTrKOWhrIIYjjvjzLsLMjsuQBsQsQDQI8tKOKHsQsXsjvP0tLYuvr9vKOOASsuPyVQ6VcnyuDyklwPEmktwLUmXML0NHIrlHtlA1irrETuXSj52QWUb(nOHtkhxIkLwUINJy6uDDOA7sKVJunEjQ68iH1JevMVs0(H837p)TR5YFsxkPlL6PRULtOxpSQtDI1V5uOjFtZyDmmY3a2H8nkdzm130mkuq7(N)gbIpm5BfURr07yJnM0lW3bg8aBsEGRmpHa2yvhBsEWW(BB8u56vGF)TR5YFsxkPlL6PRULtOxpARtA)nIMW(t9OeT)wrEVc43F7ke23WseNYqgtH4yHdEErDXsehluyYXwgex3YzbIRlL0LsOUOUyjItziJPqCSG6nu2ioZaiUPiqeFliEfIdUiU5iEH7Ae9o2yJjjEat6f47adEGD5gdq5SXWMwkhkpTWkhkpLNwQy1QmbRmPxpSEnJ2gLkNRvROUyjIxUkmagbXVdEEdq6k6IvsImZx7H4ScH1HG4oeXVdEEdq6k6IvsImZdFtBG1ujFdlrCkdzmfIJfo45f1flrCSqHjhBzqCDlNfiUUusxkH6I6ILioLHmMcXXcQ3qzJ4mdG4MIar8TG4vio4I4MJ4fURr07yJnMK4bmPxGVdm4b2LBmaLZgdBAPCO80cRCO8uEAPIvRYeSYKE9W61mABuQCUwTI6ILiE5QWayee)o45naPROlwjjYmFThIZkewhcI7qe)o45naPROlwjjYmpG6I6AmpHasqBeg8yBo1RyxYM02kzbWoK1keFyAXD6YIsMcxwPeQlwI4TIrUi(kItPfi(jialsaMgPa6iUER1rq8veV3ceVbmnsb0rC9wRJG4RiUUlqCkB9keFfXP9ceVrp1eeFfX1jQRX8ecibTryWJT5uVIDjBsBRKfa7qwRPsjZIsMcxwPeQlwI4nMPeeNE6fiEHrCjG6AmpHasqBeg8yBo1RyxYM02kzbWoK1j1IEY6qwuYu4YQEb11yEcbKG2im4X2CQxXUKnPTvYcGDiREXyKIONSoKfLmfUS2d11yEcbKG2im4X2CQxXUtcUJCJeTCsNG6AmpHasqBeg8yBo1RyVHURKBSQmkKl9eGj6WYNauxJ5jeqcAJWGhBZPEfBTbsxTiRRB8AnCaHGojiwHZr4cPdqDnMNqajOncdESnN6vSzMhRW5yrwx341A4acbDsqScNJWfshG6I6AmpHaY6GdIgZtiiQsIVayhY62ugGjlY66gVwdhqiOtcIv4CeW16RN7GN3aKUIUyLKiZCuxJ5jeqOEfBshCLkUnsbQRX8eciuVInZuQOX8ecIQK4la2HScPROlwjzrwxVdEEdq6k6IvsImZrDXsexVzG0vio9cbiLKbX1GesUvcQRX8eciuVIT2aPRqDnMNqaH6vS9eJmKyfFOyrwx341AGzEScNJWfshG6AmpHac1RyZmpwHZXISUUXR1aZ8yfohHlKoa1flrCklGG4KcOJ4exmLxG6AmpHac1Ryp4GOX8ecIQK4la2HSsCXuEXISUUXR1aPWUq6hI6gW1wUCJxRbTbsxfW1qDnMNqaH6vSzMsfnMNqquLeFbWoKvgeQUq6auxJ5jeqOEf7bhenMNqquLeFbWoK1AcssHmlY6kdESHrnycCcvRLHvSyjBsBRKqfIpmT4oDrFuxSeX1RXvEIfXWUioXft5fOUgZtiGq9k2mtPIgZtiiQsIVayhYkXft5flY66gVwdBsmbSaU2YLB8AnqWVxbeTJnoPiGRH6ILi(5cbXpGehXLYRjaswsqCAoJ4mkykbXl7CXiKceVvmYfXB0tnbXzqIJ496HvexaYGHIfi(H1rqCc(iioDbXzgaXpSocI7fMJ4jaX1jIJrb3MIOpQRX8eciuVITgeQIJqG4dtwK1v3ucWdBfeEDtbbKGaSTsU9341AyRGWRBkiGeUq6G(LjazWqb10oGvAvaYGHIWiyea1LPtkrRB8AnWuInmJ4jataxtF91rz96HvSOU0Mw341AibmBaMNqqStcWeH1Oxirkt4amkjGRPFFJ5zjjU9OpjgmYqwPeQRX8eciuVI9GdIgZtiiQsIVayhY6wbHx3uqazrwxDtjapSvq41nfeqccW2k52FJxRHTccVUPGas4cPdqDnMNqaH6vSRYazjeNe3PllyuWus0TbJ4K1ElY66gVwdMMu(O2ixZHdjYgRucWeW1qDnMNqaH6vS1GqvCeceFyYIkCIaP8(ApuxJ5jeqOEf7X6ilyuWus0TbJ4K1ElY6AzJuhHuyBLSCPMmKK4cWJh4kp1uPmuDHEySosq7ax5PMkLr)(3bpVHX6ibpzDirmwcKBecIJuhHuqfrtuQOBdgXjbc9utImZPvDXI6I6AmpHac1RyFaHGAosKz(cgfmLeDBWiozT3ISUosDesHTvs)7GN3WbecQ5ibpzDirmwcKBecIJuhHuqfrtuQOBdgXjbc9utImZPvDXI6I6AmpHac1RyRbHQ4iei(WKfv4ebs591EOUgZtiGq9k2EXyKIiZ8fmkykj62GrCYAVfzDDK6iKcBRK(3bpVbVymsrKzEWtwhseJLa5gHG4i1rifuvYM02kj4fJrkIEY6q6RNnETg2KycybCnuxJ5jeqOEfBniufhHaXhMSOcNiqkVV2d11yEcbeQxXEp4UPIeLrkwK11YglVrPKa8GDVKqcOQSEuFyLpYkSbJqWIScBWiKyDmMNqGP0NwhHvydgj65HOF)YiAIsfDBWiojShC3urIYif0QX8ecc7b3nvKOmsr4AhggblGX8ecc7b3nvKOmsrGbjU(uvMX8eccKIrUHRDyyeSagZtiiqkg5gyqIRpQRX8eciuVInHEQjrM5lY6krtuQOBdgXjbc9utImZPQh1B8AnSjXeWc4A0QUOUgZtiGq9k2KIrUlY66gVwdmLydZiEcWeW1qDnMNqaH6vShRJSGrbtjr3gmItw7TiRRB8AnSjXeWc4A9VdEEdJ1rcEY6qIySei3ieehPocPGkDrDnMNqaH6vSzMsfnMNqquLeFbWoK1AQuYG6I6AmpHasyRGWRBkiGSowhzbJcMsIUnyeNS2BrwxltpEY6Kamlxw2i1rif2wj91KHKexaE8ax5PMkLHQl0dJ1rcAh4kp1uPm6VCzzgZZssC7rFsmyKHSQBFnzijXfGhpWvEQPszO6c9WyDKG2bUYtnvkJ(lxwMX8SKe3E0NedgziR62FK6iKcBRe91V)gVwdBpowhjCH0b9VdEEdJ1rcEY6qIySei3ieehPocPGQvDrDnMNqajSvq41nfeqOEfBfoWMyciA5yEcblyuWus0TbJ4K1ElY66i1rif2wj9341Ay7XdieuZrcxiDaQRX8eciHTccVUPGac1Ry7fJrkImZxWOGPKOBdgXjR9wK11rQJqkSTs6VXR1W2JEXyKIWfsh0)o45n4fJrkImZdEY6qIySei3ieehPocPGQs2K2wjbVymsr0twhcQRX8eciHTccVUPGac1RyVhC3urIYiflY66gVwdBpUhC3urIYifHlKoa11yEcbKWwbHx3uqaH6vSj0tnjYmFrwx341Ay7rc9utcxiDqFIMOur3gmItce6PMezMtvpuxJ5jeqcBfeEDtbbeQxXMumYDrwx341Ay7rsXi3WfshG6AmpHasyRGWRBkiGq9k2e6PMezMViRRB8AnS9iHEQjHlKoa11yEcbKWwbHx3uqaH6vS9IXifrM5lY66gVwdBp6fJrkcxiDaQlQRX8ecibgeQUq6G1QmMkwhbq5OyrwxzWJnmQbtGt0bTrDXse)mLfwiLLEhXpjYfXDiItOaWqC6PxG40tVaXhRKaG4eeVocGYrbItVqaioDbXhCaIxhbq5OyBG7cehoiU5kXioIZkewhepRiE6eeNoC8cepDuxJ5jeqcmiuDH0buVI9wgImDwK1vg8ydJAWe4eQwPnQRX8ecibgeQUq6aQxXobmBaMNqWISUYGhByudMaNq1kTrDXse)8qbIBGlIdGoIt3iUG4oeI4h4Sce)mLbIlazWqXceFJ7iUPiqeNYeoXrCCIG4PJ4v4G4uoz6G4g4I4jGzdGG6AmpHasGbHQlKoG6vS9eJmKyfFOyrwxfGmyOiCLAYsNkDsPLl341AytIjGfW1wUSm3ucWdAJCnhobbyBLC7xYM02kjqkGJlep6(vh0wFuxSeX1RtmfoIVfeN(abyqChI44ebXBhI6I4qaIR3ADeepbiEjzOaXljdfioizfcItsh38ecilq8nUJ4LKHceFSruuG6AmpHasGbHQlKoG6vSjf2fs)qu3fzDDJxRbpXidjwXhkc4A9341AytIjGfUq6G(m4Xgg1GjWj6qN9VqpmwhjODGR8utLYOJEbAPVaKbdfuPtkH6AmpHasGbHQlKoG6vS3YqKPtcWSiRRB8An4jgziXk(qraxB5YnETg2KycybCnuxJ5jeqcmiuDH0buVITg0tiyrwx341AytIjGfW1qDnMNqajWGq1fshq9k2JvsaqCsSocGYrXISUUXR1WMetalGRTCznXu4XroSeq0HU9qDXse)mLfwiLLEhXlxfcRdIFaHGojaXlGoDe3axeN441kIRYocI7fjzbIBGlIFyuSfeFlUldIZGhBZr8roSeG4JqOaWqDnMNqajWGq1fshq9k2miOeSJe9cjs0YjDYISUw2f6Hj1cJCyjGqLo7ZGhByudMaNOdA3)c9WyDKGNSojatFbidgkcxPMS0PAvxkP)YL1etHhh5Wsarhyf1flrC9AJITG4EHmcItkG4QlIVfe)aocIZGGB6jeqqCiaX9cbXzqWfpDuxJ5jeqcmiuDH0buVITCObPltCdb3fzDDJxRbpXidjwXhkc4AlxwgdcU4PhUIOfnLsWKgGjbbyBLC1h11yEcbKadcvxiDa1RyBxtZZssKq3MJfmkykj62GrCYAVfzDLbp2WOgmbozfR91Zf6b7AAEwsIe62CeV2HHrcEY6KamOUgZtiGeyqO6cPdOEfBCIetxoiOUOUgZtiGeQPsjZ6yDKfmkykj62GrCYAVfzDTKnPTvsOMkLmR96psDesHTvs)l0dJ1rcAh4kp1uPm6yvtgssCb4XdCLNAQuguxJ5jeqc1uPKH6vShRJSiRRLSjTTsc1uPKzvxuxJ5jeqc1uPKH6vSv4aBIjGOLJ5jeSiRRLSjTTsc1uPKzL2OUgZtiGeQPsjd1RytONAYISUwYM02kjutLsMvDI6AmpHasOMkLmuVInPyKlQlQRX8eciHAcssHmReRKHrId0MfzDDJxRbIvYWiXbAt4cPdwUCJxRbIvYWiXbAtyKdlbeDugdESHrnycCcTslu3tFALsbAJ6ILiUET1rqCc(iiUdrCkNmqe3leeVKnPTvcItGiobEiiouDr8sMcxq8leuU7iUaUioUgIRsagzsaguxJ5jeqc1eKKczOEf7s2K2wjla2HSUfIhNuBrjtHlRuArwxDtjapOn5HPI0hZlccW2k5I6ILiUX8eciHAcssHmuVInJcMkbyILSjTTswaSdzDlepoP2cO26Hv(fLmfUSEh88gMul4jRdjIXsGCJqqCK6iKIfzD1nLa8G2KhMksFmViiaBRKlQRX8eciHAcssHmuVIT2KhMksFmVyrwxjAIsfDBWiojOn5HPI0hZlOsxuxJ5jeqc1eKKczOEf7j1wWOGPKOBdgXjlY66i1rif2wj9VdEEdtQf8K1HeXyjqUriiosDesbvLSjTTsctQf9K1H0VSY241AWtmYqIv8HIaU2YLmiuDH0bbpXidjwXhkcJCyjGqfw1VFzB8AnSvq41nfeqc4AlxQh3ucWdBfeEDtbbKGaSTsU63)c9WKAbTdCLNAQugDSQjdjjUa84bUYtnvkZYL6XnLa8aX2Y4qOxeeGTvYvFuxJ5jeqc1eKKczOEf7QmqwcXjXD6YIdR8rbidgkw7TGrbtjr3gmItw7H6I6AmpHasasxrxSsYkXTHGpyKfzDDJxRHcXgpcRrVqI0t1nGRH6AmpHasasxrxSsc1RytWb1CKfzDvpAJukIHDd9ceCqnhPVE0gPued7g0nqWb1CeuxJ5jeqcq6k6IvsOEf7cXgpcRrVqI0t1DrwxfGmyOqh6Ks9l7c9WKAHroSeqOsNbSUCjdESHrnycCIoWQ(9zqO6cPdcEIrgsSIpueg5WsaHQvAjG1(B8AnWuInmJ4jatG4gRJo61xpB8AnyAs5JAJCnhoKiBSsjataxRVE241AyRGWRcN4bCT(LTXR1WMetalmYHLacvyD5s9SXR1WMetalGRPF)Y0ddcvxiDqGbbLGDKOxirIwoPtc4AlxQhgSKamGhajMcpwnrFuxJ5jeqcq6k6IvsOEf7die0jbXkCowK1vbidgk0HoPu)YUqpmPwyKdlbeQ0zaRlxYGhByudMaNOdSQFFgeQUq6GGNyKHeR4dfHroSeqOALwcyT)gVwdmLydZiEcWeiUX6OJE91ZgVwdMMu(O2ixZHdjYgRucWeW16RNnETg2ki8QWjEaxRFzB8AnSjXeWcJCyjGqfwxUupB8AnSjXeWc4A63Vm9WGq1fsheyqqjyhj6fsKOLt6KaU2YL6Hbljad4bqIPWJvt0h1f11yEcbKaXft5fRAqOkocbIpmzrforGuEFThQRX8ecibIlMYlOEf7X6ilyuWus0TbJ4K1ElY6AzxOhgRJe0oWvEQPsz0rVawxUCK6iKcBRe97Fh88ggRJe8K1HeXyjqUriiosDesbv6I6AmpHasG4IP8cQxXwdcvXriq8HjlQWjcKY7R9qDnMNqajqCXuEb1Ry7fJrkImZxWOGPKOBdgXjR9wK11rQJqkSTs6Fh88g8IXifrM5bpzDirmwcKBecIJuhHuqvjBsBRKGxmgPi6jRdPprtuQOBdgXjbVymsrKzov0g1flrCAgC3uiEtzKcepji(wCxge3lmaItCXuEbI3kg5I4MJ40gXDBWiob11yEcbKaXft5fuVI9EWDtfjkJuSiRRenrPIUnyeNe2dUBQirzKcQ0f11yEcbKaXft5fuVITgeQIJqG4dtwuHteiL3x7H6ILiERyKlIxHdIxnIldIxU0BqCmcqgZtiybINee)EGbXvqcbXRWbXjAjaqbIde2ar8nEQUeuxJ5jeqcexmLxq9k2KIrUOUOUgZtiGe2MYamzLGdQ5ilY66gVwdctLAejsGkBcxiDq)nETgeMk1isuHdSjCH0b9lBK6iKcBRKLllZyEwsIcqosHqvV(gZZss8c9abhuZr0HX8SKefGCKcrF9rDnMNqajSnLbyc1RytCBi4dgzrwx341AqyQuJircuztyKdlbeQygXJEEilxUXR1GWuPgrIkCGnHroSeqOIzep65HG6AmpHasyBkdWeQxXM42uZrwK11nETgeMk1isuHdSjmYHLacvmJ4rppKLljqLnrHPsnIqfLqDnMNqajSnLbyc1RytFmVyrwx341AqyQuJircuztyKdlbeQygXJEEilxQWb2efMk1icvu6BLKHKqWFsxkPlL6PRU6LVr3gqcWq(gL5yb1BpPxDIYm9oIJ4Nleepp0GJJ4v4G4L7xPA4kVChXhPClEoYfXjWdbXnChEyUCrCwHbWiKaQlLDceexxkP3r8YfeusgxUiElpkxioHcGBLhXXcG4oeXPSXne)MLsscbioutgZHdIxg26J4LPB51pG6I6QxDObhxUioLhXnMNqaIRsItcOUFtLeN8N)wnvkz(Z)PE)5VjaBRK7tZ3yt6YK23kztABLeQPsjdIVI49q8(i(i1rif2wjiEFe)c9WyDKG2bUYtnvkdIRJvextgssCb4XdCLNAQuMVzmpHGVnwh5Bmkykj62GrCYFQ37)jD)ZFta2wj3NMVXM0LjTVvYM02kjutLsgeFfX19BgZti4BJ1rE)pr7)83eGTvY9P5BSjDzs7BLSjTTsc1uPKbXxrCA)nJ5je8TdieuZrImZF)pPZ)83eGTvY9P5BSjDzs7BLSjTTsc1uPKbXxrCD(nJ5je8nc9utImZF)pH1)83mMNqW3ifJC)MaSTsUpnV)(3QjijfY8N)t9(ZFta2wj3NMVXM0LjTVTXR1aXkzyK4aTjCH0bi(YLi(gVwdeRKHrId0MWihwciiUoq8YqCg8ydJAWe4eeNwrCAbXPgX7H46J40kItPaT)MX8ec(gXkzyK4aT59)KU)5VjaBRK7tZ3GAFJi(3mMNqW3kztABL8TsMcx(gL(wjBIa7q(2wiECsTVXM0LjTV5MsaEqBYdtfPpMxeeGTvY99)eT)ZFta2wj3NMVXM0LjTVr0eLk62GrCsqBYdtfPpMxG4uH46(nJ5je8nTjpmvK(yEX7)jD(N)MaSTsUpnFJnPltAFBK6iKcBReeVpIFh88gMul4jRdjIXsGCJqqCK6iKceNkeVKnPTvsysTONSoeeVpIxgIxgIVXR1GNyKHeR4dfbCneF5seNbHQlKoi4jgziXk(qryKdlbeeNkehRiU(iEFeVmeFJxRHTccVUPGasaxdXxUeX1dI7MsaEyRGWRBkiGeeGTvYfX1hX7J4xOhMulODGR8utLYG46yfX1KHKexaE8ax5PMkLbXxUeX1dI7MsaEGyBzCi0lccW2k5I46)nJ5je8Tj1E)pH1)83eGTvY9P5Bhw5Jcqgmu8TEFZyEcbFRkdKLqCsCNU8ngfmLeDBWio5p1793)22ugGj)5)uV)83eGTvY9P5BSjDzs7BB8AnimvQrKibQSjCH0biEFeFJxRbHPsnIev4aBcxiDaI3hXldXhPocPW2kbXxUeXldXnMNLKOaKJuiioviEpeVpIBmpljXl0deCqnhbX1bIBmpljrbihPqqC9rC9)MX8ec(gbhuZrE)pP7F(BcW2k5(08n2KUmP9TnETgeMk1isKav2eg5WsabXPcXzgXJEEii(YLi(gVwdctLAejQWb2eg5WsabXPcXzgXJEEiFZyEcbFJ42qWhmY7)jA)N)MaSTsUpnFJnPltAFBJxRbHPsnIev4aBcJCyjGG4uH4mJ4rppeeF5seNav2efMk1icItfItPVzmpHGVrCBQ5iV)N05F(BcW2k5(08n2KUmP9TnETgeMk1isKav2eg5WsabXPcXzgXJEEii(YLiUchytuyQuJiiovioL(MX8ec(g9X8I3F)BxPA4k)p)N69N)MaSTsUpnFZyEcbFBWbrJ5jeevjX)gBsxM0(2gVwdhqiOtcIv4CeW1q8(iUEq87GN3aKUIUyLKiZ8VPsIhb2H8TTPmatE)pP7F(BgZti4BKo4kvCBKIVjaBRK7tZ7)jA)N)MaSTsUpnFZyEcbFJzkv0yEcbrvs8VXM0LjTVDh88gG0v0fRKezM)nvs8iWoKVbPROlwj59)Ko)ZFZyEcbFtBG0vFta2wj3NM3)ty9p)nbyBLCFA(gBsxM0(2gVwdmZJv4CeUq6GVzmpHGV5jgziXk(qX7)jA5p)nbyBLCFA(gBsxM0(2gVwdmZJv4CeUq6GVzmpHGVXmpwHZX7)j9YF(BcW2k5(08nJ5je8TbhenMNqquLe)BSjDzs7BB8AnqkSlK(HOUbCneF5seFJxRbTbsxfW1(MkjEeyhY3iUykV49)u58N)MaSTsUpnFZyEcbFJzkv0yEcbrvs8VPsIhb2H8ngeQUq6G3)tu()83eGTvY9P5BgZti4BdoiAmpHGOkj(3yt6YK23yWJnmQbtGtqCQwr8YqCSI4yreVKnPTvsOcXhMwCNUG46)nvs8iWoKVvtqskK59)upk9N)MaSTsUpnFZyEcbFJzkv0yEcbrvs8VXM0LjTVTXR1WMetalGRH4lxI4B8AnqWVxbeTJnoPiGR9nvs8iWoKVrCXuEX7)PE9(ZFta2wj3NMVXM0LjTV5MsaEyRGWRBkiGeeGTvYfX7J4B8AnSvq41nfeqcxiDaI3hXldXfGmyOaXPgXPDaRioTI4cqgmuegbJaqCQr8YqCDsjeNwr8nETgykXgMr8eGjGRH46J46J46aXldX71dRioweX1L2ioTI4B8AnKaMnaZtii2jbyIWA0lKiLjCagLeW1qC9r8(iUX8SKe3E0Nedgzii(kItPVzmpHGVPbHQ4iei(WK3)t909p)nbyBLCFA(MX8ec(2GdIgZtiiQsI)n2KUmP9n3ucWdBfeEDtbbKGaSTsUiEFeFJxRHTccVUPGas4cPd(MkjEeyhY32ki86McciV)N6r7)83eGTvY9P5BSjDzs7BB8AnyAs5JAJCnhoKiBSsjatax7BgZti4BvzGSeItI70LVXOGPKOBdgXj)PEV)N6PZ)83eGTvY9P5Bv4ebs59)uVVzmpHGVPbHQ4iei(WK3)t9W6F(BcW2k5(08n2KUmP9TYq8rQJqkSTsq8LlrCnzijXfGhpWvEQPszqCQq8l0dJ1rcAh4kp1uPmiU(iEFe)o45nmwhj4jRdjIXsGCJqqCK6iKceNkeNOjkv0TbJ4KaHEQjrM5ioTI46I4yrex3VzmpHGVnwh5Bmkykj62GrCYFQ37)PE0YF(BcW2k5(08n2KUmP9TrQJqkSTsq8(i(DWZB4acb1CKGNSoKiglbYncbXrQJqkqCQqCIMOur3gmItce6PMezMJ40kIRlIJfrCD)MX8ec(2becQ5irM5FJrbtjr3gmIt(t9E)p1tV8N)MaSTsUpnFRcNiqkV)N69nJ5je8nniufhHaXhM8(FQx58N)MaSTsUpnFJnPltAFBK6iKcBReeVpIFh88g8IXifrM5bpzDirmwcKBecIJuhHuG4uH4LSjTTscEXyKIONSoeeVpIRheFJxRHnjMawax7BgZti4BEXyKIiZ8VXOGPKOBdgXj)PEV)N6r5)ZFta2wj3NMVvHteiL3)t9(MX8ec(MgeQIJqG4dtE)pPlL(ZFta2wj3NMVXM0LjTVvgIpwEJsjb4b7EjHeG4uH4LH49qCQr8dR8rwHnyecIJfrCwHnyesSogZtiWuiU(ioTI4JWkSbJe98qqC9r8(iEziortuQOBdgXjH9G7MksugPaXPve3yEcbH9G7MksugPiCTddJG4yJ4gZtiiShC3urIYifbgK4iU(ioviEziUX8eccKIrUHRDyyeehBe3yEcbbsXi3adsCex)VzmpHGVThC3urIYifV)N0T3F(BcW2k5(08n2KUmP9nIMOur3gmItce6PMezMJ4uH49qCQr8nETg2KycybCneNwrCD)MX8ec(gHEQjrM5V)N0v3)83eGTvY9P5BSjDzs7BB8AnWuInmJ4jatax7BgZti4BKIrUV)N0L2)5VjaBRK7tZ3yt6YK23241AytIjGfW1q8(i(DWZBySosWtwhseJLa5gHG4i1rifioviUUFZyEcbFBSoY3yuWus0TbJ4K)uV3)t6QZ)83eGTvY9P5BgZti4BmtPIgZtiiQsI)nvs8iWoKVvtLsM3F)BAJWGhBZ)Z)PE)5VjaBRK7tZ3GAFJi(3mMNqW3kztABL8TsMcx(gL(wjBIa7q(wfIpmT4oD59)KU)5VjaBRK7tZ3GAFJi(3mMNqW3kztABL8TsMcx(gL(wjBIa7q(wnvkzE)pr7)83eGTvY9P5BqTVre)BgZti4BLSjTTs(wjtHlFtV8Ts2eb2H8Tj1IEY6qE)pPZ)83eGTvY9P5BqTVre)BgZti4BLSjTTs(wjtHlFR33kzteyhY38IXifrpzDiV)NW6F(BgZti4BDsWDKBKOLt6KVjaBRK7tZ7)jA5p)nJ5je8Tn0DLCJvLrHCPNamrhw(e8nbyBLCFAE)pPx(ZFta2wj3NMVXM0LjTVTXR1Wbec6KGyfohHlKo4BgZti4BAdKU69)u58N)MaSTsUpnFJnPltAFBJxRHdie0jbXkCocxiDW3mMNqW3yMhRW5493)2wbHx3uqa5p)N69N)MaSTsUpnFJnPltAFRmexpiUNSojadIVCjIxgIpsDesHTvcI3hX1KHKexaE8ax5PMkLbXPcXVqpmwhjODGR8utLYG46J4lxI4LH4gZZssC7rFsmyKHG4RiUUiEFextgssCb4XdCLNAQugeNke)c9WyDKG2bUYtnvkdIRpIVCjIxgIBmpljXTh9jXGrgcIVI46I49r8rQJqkSTsqC9rC9r8(i(gVwdBpowhjCH0biEFe)o45nmwhj4jRdjIXsGCJqqCK6iKceNQvex3VzmpHGVnwh5Bmkykj62GrCYFQ37)jD)ZFta2wj3NMVXM0LjTVnsDesHTvcI3hX341Ay7XdieuZrcxiDW3mMNqW3oGqqnhjYm)Bmkykj62GrCYFQ37)jA)N)MaSTsUpnFJnPltAFBK6iKcBReeVpIVXR1W2JEXyKIWfshG49r87GN3GxmgPiYmp4jRdjIXsGCJqqCK6iKceNkeVKnPTvsWlgJue9K1H8nJ5je8nVymsrKz(3yuWus0TbJ4K)uV3)t68p)nbyBLCFA(gBsxM0(2gVwdBpUhC3urIYifHlKo4BgZti4B7b3nvKOmsX7)jS(N)MaSTsUpnFJnPltAFBJxRHThj0tnjCH0biEFeNOjkv0TbJ4KaHEQjrM5ioviEVVzmpHGVrONAsKz(7)jA5p)nbyBLCFA(gBsxM0(2gVwdBpskg5gUq6GVzmpHGVrkg5((FsV8N)MaSTsUpnFJnPltAFBJxRHThj0tnjCH0bFZyEcbFJqp1KiZ83)tLZF(BcW2k5(08n2KUmP9TnETg2E0lgJueUq6GVzmpHGV5fJrkImZF)9VrCXuEXF(p17p)nbyBLCFA(wforGuE)p17BgZti4BAqOkocbIpm59)KU)5VjaBRK7tZ3yt6YK23kdXVqpmwhjODGR8utLYG46aX7fWkIVCjIpsDesHTvcIRpI3hXVdEEdJ1rcEY6qIySei3ieehPocPaXPcX19BgZti4BJ1r(gJcMsIUnyeN8N69(FI2)5VjaBRK7tZ3QWjcKY7)PEFZyEcbFtdcvXriq8HjV)N05F(BcW2k5(08n2KUmP9TrQJqkSTsq8(i(DWZBWlgJuezMh8K1HeXyjqUriiosDesbItfIxYM02kj4fJrkIEY6qq8(iortuQOBdgXjbVymsrKzoItfIt7VzmpHGV5fJrkImZ)gJcMsIUnyeN8N69(FcR)5VjaBRK7tZ3yt6YK23iAIsfDBWiojShC3urIYifioviUUFZyEcbFBp4UPIeLrkE)prl)5VjaBRK7tZ3QWjcKY7)PEFZyEcbFtdcvXriq8HjV)N0l)5VzmpHGVrkg5(nbyBLCFAE)9VXGq1fsh8N)t9(ZFta2wj3NMVXM0LjTVXGhByudMaNG46aXP93mMNqW3QYyQyDeaLJI3)t6(N)MaSTsUpnFJnPltAFJbp2WOgmbobXPAfXP93mMNqW32YqKPZ7)jA)N)MaSTsUpnFJnPltAFJbp2WOgmbobXPAfXP93mMNqW3saZgG5je8(FsN)5VjaBRK7tZ3yt6YK23eGmyOiCLAYshXPcX1jLq8Llr8nETg2KycybCneF5seVme3nLa8G2ixZHtqa2wjxeVpIxYM02kjqkGJlep6(fX1bItBex)VzmpHGV5jgziXk(qX7)jS(N)MaSTsUpnFJnPltAFBJxRbpXidjwXhkc4AiEFeFJxRHnjMaw4cPdq8(iodESHrnycCcIRdexNiEFe)c9WyDKG2bUYtnvkdIRdeVxGwq8(iUaKbdfioviUoP03mMNqW3if2fs)qu33)t0YF(BcW2k5(08n2KUmP9TnETg8eJmKyfFOiGRH4lxI4B8AnSjXeWc4AFZyEcbFBldrMojaZ7)j9YF(BcW2k5(08n2KUmP9TnETg2KycybCTVzmpHGVPb9ecE)pvo)5VjaBRK7tZ3yt6YK23241AytIjGfW1q8Llr8AIPWJJCyjGG46aX1T33mMNqW3gRKaG4KyDeaLJI3)tu()83eGTvY9P5BSjDzs7BLH4xOhMulmYHLacItfIRteVpIZGhByudMaNG46aXPnI3hXVqpmwhj4jRtcWG49rCbidgkcxPMS0rCQwrCDPeIRpIVCjIxtmfECKdlbeexhiow)MX8ec(gdckb7irVqIeTCsN8(FQhL(ZFta2wj3NMVXM0LjTVTXR1GNyKHeR4dfbCneF5seVmeNbbx80dxr0IMsjysdWKGaSTsUiU(FZyEcbFto0G0LjUHG77)PE9(ZFta2wj3NMVXM0LjTVXGhByudMaNG4Riowr8(iUEq8l0d2108SKej0T5iETddJe8K1jby(MX8ec(MDnnpljrcDBo(gJcMsIUnyeN8N69(FQNU)5VzmpHGVHtKy6Yb5BcW2k5(08(7FdsxrxSsYF(p17p)nbyBLCFA(gBsxM0(2gVwdfInEewJEHePNQBax7BgZti4Be3gc(GrE)pP7F(BcW2k5(08n2KUmP9n9G4AJukIHDd9ceCqnhbX7J46bX1gPued7g0nqWb1CKVzmpHGVrWb1CK3)t0(p)nbyBLCFA(gBsxM0(MaKbdfiUoqCDsjeVpIxgIFHEysTWihwciioviUodyfXxUeXzWJnmQbtGtqCDG4yfX1hX7J4miuDH0bbpXidjwXhkcJCyjGG4uTI40saRiEFeFJxRbMsSHzepbyce3yDqCDG49q8(iUEq8nETgmnP8rTrUMdhsKnwPeGjGRH49rC9G4B8AnSvq4vHt8aUgI3hXldX341AytIjGfg5WsabXPcXXkIVCjIRheFJxRHnjMawaxdX1hX7J4LH46bXzqO6cPdcmiOeSJe9cjs0YjDsaxdXxUeX1dIZGLeGb8aiXu4XQjiU(FZyEcbFRqSXJWA0lKi9uDF)pPZ)83eGTvY9P5BSjDzs7BcqgmuG46aX1jLq8(iEzi(f6Hj1cJCyjGG4uH46mGveF5seNbp2WOgmbobX1bIJvexFeVpIZGq1fshe8eJmKyfFOimYHLacIt1kItlbSI49r8nETgykXgMr8eGjqCJ1bX1bI3dX7J46bX341AW0KYh1g5AoCir2yLsaMaUgI3hX1dIVXR1WwbHxfoXd4AiEFeVmeFJxRHnjMawyKdlbeeNkehRi(YLiUEq8nETg2KycybCnexFeVpIxgIRheNbHQlKoiWGGsWos0lKirlN0jbCneF5sexpiodwsagWdGetHhRMG46)nJ5je8Tdie0jbXkCoE)93)MH7fW5BT8OC9(7)d]] )


end
