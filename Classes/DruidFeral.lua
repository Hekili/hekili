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


    spec:RegisterPack( "Feral", 20210102, [[dS0Nebqisf9iiIUeebSjPuFskuvJsk4uKQAvivXRqsnlLWTGi0Ue8lKOHHeCmjQLrQ0ZivyAKQ4AqK2gsO(gPkLXjfkNdjeRJuLQ5Huv3tjTpKKdcrGwisLhkfQmrsvcBeIG(OuOkDsKQuTsPOzIesDtsvI2PkYprQszOKQKSusvs9uPAQQO(ksiPgRuOk2RQ(RqdgvhMYIvQhJYKvPltSzj9zimAjCArRgjK41sjZMKBRc7g43GgoPCCKqswUINJy6uDDiTDjY3rkJxkKZdrTEKQK5ReTFO(l)N)(1C5pPlf0TmfktbDdLPq5gthuKV7iRjFxZyTmeY3b2H8DKqzm131mKvq7(N)obIom57fURr07usjI0lq3bg8GssEGQmpHa2yvNssEWO87B0u507GF)9R5YFsxkOBzkuMc6gktHYnMoq63jAc7pvMc647f59kGF)9RqyFhjXCKqzmfMRxmO5f3ejX8Mga1gKXCDxG56sbDlJBIBIKyosOmMcZrcQxrrJ5mdG5MIaX8TG5vik4I5MJ5fURr07usjIK4bePxGUdm4bLnEma9YgJskUXOiumRXOiuekUIuRYeKYKYLr61mDyuOXUwTIBIKyEJRWaiem)oO5naPPOjwjjYmFTmMZkewlcM7qm)oO5naPPOjwjjYmp8DTbwtL8DKeZrcLXuyUEXGMxCtKeZBAauBqgZ1DbMRlf0TmUjUjsI5iHYykmhjOEffnMZmaMBkceZ3cMxHOGlMBoMx4UgrVtjLisIhqKEb6oWGhu24Xa0lBmkP4gJIqXSgJIqrO4ksTktqktkxgPxZ0HrHg7A1kUjsI5nUcdGqW87GM3aKMIMyLKiZ81YyoRqyTiyUdX87GM3aKMIMyLKiZ8aUjUPX8ecibTryWJT5uVszjBsBRKfa7qwRq0HPf3PllkzkuzLc4MijM3lg5I5RyofwG5NGaKibyAKcOJ561wlbZxX8YlW8oW0ifqhZ1RTwcMVI56UaZPOP3X8vmxhlW8oTutW8vmxp4MgZtiGe0gHbp2Mt9kLLSjTTswaSdzTMkLmlkzkuzLc4MijM3zMsWCAPxG5fgXLaUPX8ecibTryWJT5uVszjBsBRKfa7qwNul6jRfzrjtHkR6nCtJ5jeqcAJWGhBZPELYs2K2wjla2HS6fJrkIEYArwuYuOYAzCtJ5jeqcAJWGhBZPELYwj4oYns0YjDcUPX8ecibTryWJT5uVs5g6UsUXQYqwU0saIOdBucWnnMNqajOncdESnN6vk1gin1ISUUrR1WbecALGyfohHlKga30yEcbKG2im4X2CQxPKzEScNJfzDDJwRHdie0kbXkCocxinaUjUPX8eciRdkiAmpHGOkj(cGDiRBtzaMSiRRB0AnCaHGwjiwHZravRToVdAEdqAkAIvsImZXnnMNqaH6vkjTqvQ42if4MgZtiGq9kLmtPIgZtiiQsIVayhYkKMIMyLKfzD9oO5naPPOjwjjYmh3ejXC9QbstH50keGusgmxdsi5wj4MgZtiGq9kLAdKMc30yEcbeQxP0teYqIv0b5fzDDJwRbM5XkCocxinaUPX8eciuVsjZ8yfohlY66gTwdmZJv4CeUqAaCtKeZP3acMtkGoMtCXuEbUPX8eciuVs5GcIgZtiiQsIVayhYkXft5flY66gTwdKc7cPDiQBavB5YnATg0ginvavd30yEcbeQxPKzkv0yEcbrvs8fa7qwzqO6cPbWnnMNqaH6vkhuq0yEcbrvs8fa7qwRjijfYSiRRm4Xgg1GjWjuT2asrILSjTTscvi6W0I70f9XnrsmxVev5jseb7I5exmLxGBAmpHac1RuYmLkAmpHGOkj(cGDiRexmLxSiRRB0AnSjXeWcOAlxUrR1ab9Efq0o2OKIaQgUjsI5Nlem)asCmxAKMaizjbZP7mMZqMPemVHZfJqkW8EXixmVtl1emNbjoMxUmsXCbidcKxG5hwlbZjOJG50emNzam)WAjyUxyoMNamxpyocfCBkI(4MgZtiGq9kLAqOkocbIomzrwxDtjapSvq41nfeqccW2k52EJwRHTccVUPGas4cPbA3GaKbbYuRJasPhbidcKdJGqau3GEOa9SrR1atj2WmINaebun91N(nuUmsrI6Qd6zJwRHeWSbyEcbXwjarewJEHePOGcqOKaQM(TnMNLK42J(KiqidzLc4MgZtiGq9kLdkiAmpHGOkj(cGDiRBfeEDtbbKfzD1nLa8WwbHx3uqajiaBRKB7nATg2ki86McciHlKga30yEcbeQxPSkdKLqusCNUSGHmtjr3geItwlViRRB0AnyAsJIAJCnhoKiBSsjaravd30yEcbeQxPudcvXriq0HjlQWjcKg5RLXnnMNqaH6vkhRLSGHmtjr3geItwlViRRnmsDesHTvYYLAYqsIlapEGQ8utLYq1f6HXAjbTduLNAQug9BFh08ggRLe8K1IeryjqUriiosDesbvenrPIUnieNei0snjYmNE0fjQlUPX8eciuVs5becQ5irM5lyiZus0TbH4K1YlY66i1rif2wjTVdAEdhqiOMJezMh8K1IeryjqUriiosDesbvenrPIUnieNei0snjYmNE0fjQlUPX8eciuVsPgeQIJqGOdtwuHteinYxlJBAmpHac1Ru6fJrkImZxWqMPKOBdcXjRLxK11rQJqkSTsAFh08g8IXifrM5bpzTirewcKBecIJuhHuqvjBsBRKGxmgPi6jRfPTo3O1AytIjGfq1WnnMNqaH6vk1GqvCeceDyYIkCIaPr(AzCtJ5jeqOELY9G6MksugPyrwxByS8gLscWd29scjGQgkt9H1OiRWgecbjYkSbHqI1XyEcbMsF6zewHniKONhI(TBGOjkv0TbH4KWEqDtfjkJuqpgZtiiShu3urIYifHRDyieKagZtiiShu3urIYifbgK46tvdgZtiiqkg5gU2HHqqcympHGaPyKBGbjU(4MgZtiGq9kLeAPMezMViRRenrPIUnieNei0snjYmNQYuVrR1WMetalGQrp6IBAmpHac1Ruskg5UiRRB0AnWuInmJ4jaravd30yEcbeQxPCSwYcgYmLeDBqiozT8ISUUrR1WMetalGQ1(oO5nmwlj4jRfjIWsGCJqqCK6iKcQ0f30yEcbeQxPKzkv0yEcbrvs8fa7qwRPsjdUjUPX8eciHTccVUPGaY6yTKfmKzkj62GqCYA5fzDTbD6jRvcqSCzdJuhHuyBL0wtgssCb4XduLNAQugQUqpmwljODGQ8utLYO)YLnympljXTh9jrGqgYQUT1KHKexaE8av5PMkLHQl0dJ1scAhOkp1uPm6VCzdgZZssC7rFseiKHSQB7rQJqkSTs0x)2B0AnS94yTKWfsd0(oO5nmwlj4jRfjIWsGCJqqCK6iKcQw1f30yEcbKWwbHx3uqaH6vkvOaBIjGOLJ5jeSGHmtjr3geItwlViRRJuhHuyBL0EJwRHThpGqqnhjCH0a4MgZtiGe2ki86McciuVsPxmgPiYmFbdzMsIUnieNSwErwxhPocPW2kP9gTwdBp6fJrkcxinq77GM3GxmgPiYmp4jRfjIWsGCJqqCK6iKcQkztABLe8IXifrpzTi4MgZtiGe2ki86McciuVs5EqDtfjkJuSiRRB0AnS94EqDtfjkJueUqAaCtJ5jeqcBfeEDtbbeQxPKql1KiZ8fzDDJwRHThj0snjCH0aTjAIsfDBqiojqOLAsKzovLXnnMNqajSvq41nfeqOELssXi3fzDDJwRHThjfJCdxinaUPX8eciHTccVUPGac1RusOLAsKz(ISUUrR1W2JeAPMeUqAaCtJ5jeqcBfeEDtbbeQxP0lgJuezMViRRB0AnS9OxmgPiCH0a4M4MgZtiGeyqO6cPbwRYyQyDea9c5fzDLbp2WOgmboH(6a3ejX8Z0B6f0B6Dm)Kixm3HyobzadZPLEbMtl9cmFSscaIsW86ia6fYyoTcbG50emFqbyEDea9c5TbUlWC4G5MReJ4yoRqyTW8SI5PtWCAWXlW80XnnMNqajWGq1fsdq9kLBziY0ArwxzWJnmQbtGtOAvh4MgZtiGeyqO6cPbOELYeWSbyEcblY6kdESHrnycCcvR6a3ejX8ZdYyUbUyoa6yonJ4cM7qiMFGYkW8ZiHyUaKbbYlW8nQJ5MIaXCkkOehZrjcMNoMxHdMtVKPfMBGlMNaMnacUPX8ecibgeQUqAaQxP0teYqIv0b5fzDvaYGa5WvQjlDQ0dfwUCJwRHnjMawavB5YgCtjapOnY1C4eeGTvYTDjBsBRKaPaoUq8O7x6Rd9XnrsmxVmru4y(wWCAdeGaZDiMJsemVFiQlMdbyUET1sW8eG5LKbzmVKmiJ5GKviyojDuZtiGSaZ3OoMxsgKX8XgrHmUPX8ecibgeQUqAaQxPKuyxiTdrDxK11nATg8eHmKyfDqoGQ1EJwRHnjMaw4cPbAZGhByudMaNqF90(c9WyTKG2bQYtnvkd9lhO42cqgeitLEOaUPX8ecibgeQUqAaQxPCldrMwjaXISUUrR1GNiKHeROdYbuTLl3O1AytIjGfq1WnnMNqajWGq1fsdq9kLAqpHGfzDDJwRHnjMawavd30yEcbKadcvxina1RuowjbarjX6ia6fYlY66gTwdBsmbSaQ2YL1erHhh5WsaH(6wg3ejX8Z0B6f0B6DmVXviSwy(becALamVa60WCdCXCIJwRyUkBjyUxKKfyUbUy(HH8wW8T4UmyodESnhZh5WsaMpcbzad30yEcbKadcvxina1RuYGGsWws0lKirlN0jlY6AdxOhMulmYHLacv6PndESHrnycCc91r7l0dJ1scEYALaeTfGmiqoCLAYsNQvDPG(lxwtefECKdlbe6JuCtKeZ1lnK3cM7fYiyoPaIQUy(wW8d4iyodcUPNqabZHam3lemNbbx00XnnMNqajWGq1fsdq9kLYHgKMmXneCxK11nATg8eHmKyfDqoGQTCzdmi4IME4kIw0ukbrAaMeeGTvYvFCtJ5jeqcmiuDH0auVsPDnnpljrcnBowWqMPKOBdcXjRLxK1vg8ydJAWe4KvK2wNxOhSRP5zjjsOzZr8Ahgcj4jRvcqGBAmpHasGbHQlKgG6vkrjsmD5GGBIBAmpHasOMkLmRJ1swWqMPKOBdcXjRLxK11s2K2wjHAQuYSwU9i1rif2wjTVqpmwljODGQ8utLYq)vnzijXfGhpqvEQPszWnnMNqajutLsgQxPCSwYISUwYM02kjutLsMvDXnnMNqajutLsgQxPuHcSjMaIwoMNqWISUwYM02kjutLsMvDGBAmpHasOMkLmuVsjHwQjlY6AjBsBRKqnvkzw1dUPX8eciHAQuYq9kLKIrU4M4MgZtiGeQjijfYSsSsgcjoqBwK11nATgiwjdHehOnHlKgy5YnATgiwjdHehOnHroSeqOFdm4Xgg1GjWj0dftDz9Phke0bUjsI56LwlbZjOJG5oeZPxYaXCVqW8s2K2wjyobI5e4HG5q1fZlzkubZVqqJVJ5c4I5OAyUkbiKjbiWnnMNqajutqskKH6vklztABLSayhY6wiECsTfLmfQSsHfzD1nLa8G2KhMksBmViiaBRKlUjsI5gZtiGeQjijfYq9kLmKzQeGiwYM02kzbWoK1Tq84KAlGARhwJwuYuOY6DqZBysTGNSwKiclbYncbXrQJqkwK1v3ucWdAtEyQiTX8IGaSTsU4MgZtiGeQjijfYq9kLAtEyQiTX8IfzDLOjkv0TbH4KG2KhMksBmVGkDXnnMNqajutqskKH6vkNuBbdzMsIUnieNSiRRJuhHuyBL0(oO5nmPwWtwlseHLa5gHG4i1rifuvYM02kjmPw0twls7gAyJwRbpridjwrhKdOAlxYGq1fsde8eHmKyfDqomYHLacviv)2nSrR1WwbHx3uqajGQTCPoDtjapSvq41nfeqccW2k5QF7l0dtQf0oqvEQPszO)QMmKK4cWJhOkp1uPmlxQt3ucWdeBlJdHErqa2wjx9XnnMNqajutqskKH6vkRYazjeLe3PlloSgffGmiqET8cgYmLeDBqiozTmUjUPX8ecibinfnXkjRe3gc6GqwK11nATgkeB8iSg9cjslv3aQgUPX8ecibinfnXkjuVsjbfuZrwK1vDQnsPic2nuoqqb1CK26uBKsreSBq3abfuZrWnnMNqajaPPOjwjH6vkleB8iSg9cjslv3fzDvaYGaz6Rhk0UHl0dtQfg5WsaHk9eq6YLm4Xgg1GjWj0hP63MbHQlKgi4jcziXk6GCyKdlbeQwP4asBVrR1atj2WmINaebIBSw0VCBDUrR1GPjnkQnY1C4qISXkLaebuT26CJwRHTccVkuIhq1A3WgTwdBsmbSWihwciuH0Ll15gTwdBsmbSaQM(TBqNmiuDH0abgeuc2sIEHejA5KojGQTCPozWscWaEaKik8y1e9XnnMNqajaPPOjwjH6vkpGqqReeRW5yrwxfGmiqM(6HcTB4c9WKAHroSeqOspbKUCjdESHrnycCc9rQ(TzqO6cPbcEIqgsSIoihg5WsaHQvkoG02B0AnWuInmJ4jarG4gRf9l3wNB0AnyAsJIAJCnhoKiBSsjaravRTo3O1AyRGWRcL4buT2nSrR1WMetalmYHLacviD5sDUrR1WMetalGQPF7g0jdcvxinqGbbLGTKOxirIwoPtcOAlxQtgSKamGhajIcpwnrFCtCtJ5jeqcexmLxSQbHQ4iei6WKfv4ebsJ81Y4MgZtiGeiUykVG6vkhRLSGHmtjr3geItwlViRRnCHEySwsq7av5PMkLH(LdiD5YrQJqkSTs0V9DqZBySwsWtwlseHLa5gHG4i1rifuPlUPX8ecibIlMYlOELsniufhHarhMSOcNiqAKVwg30yEcbKaXft5fuVsPxmgPiYmFbdzMsIUnieNSwErwxhPocPW2kP9DqZBWlgJuezMh8K1IeryjqUriiosDesbvLSjTTscEXyKIONSwK2enrPIUnieNe8IXifrM5uPdCtKeZPBqDtH5DLrkW8KG5BXDzWCVWayoXft5fyEVyKlMBoMRdm3TbH4eCtJ5jeqcexmLxq9kL7b1nvKOmsXISUs0eLk62GqCsypOUPIeLrkOsxCtJ5jeqcexmLxq9kLAqOkocbIomzrforG0iFTmUjsI59IrUyEfoyE1iUmyEJtVcZriazmpHGfyEsW87bcmxbjemVchmNOLaaYyoqydeZ3OP6sWnnMNqajqCXuEb1Ruskg5IBIBAmpHasyBkdWKvckOMJSiRRB0AnimvQrKibQSjCH0aT3O1AqyQuJirfkWMWfsd0UHrQJqkSTswUSbJ5zjjka5ifcvLBBmpljXl0deuqnhH(gZZssuaYrke91h30yEcbKW2ugGjuVsjXTHGoiKfzDDJwRbHPsnIejqLnHroSeqOIzep65HSC5gTwdctLAejQqb2eg5WsaHkMr8ONhcUPX8eciHTPmatOELsIBtnhzrwx3O1AqyQuJirfkWMWihwciuXmIh98qwUKav2efMk1icvua30yEcbKW2ugGjuVsjTX8IfzDDJwRbHPsnIejqLnHroSeqOIzep65HSCPcfytuyQuJiurHVxsgscb)jDPGUuOSU62yFNMnGeGG8DkQrcQxFIE)uJx9oMJ5Nlempp0GJJ5v4G5n(xPAOkVXhZhHIk0CKlMtGhcMBOo8WC5I5ScdGqibCtk6eiyUUuqVJ5noiOKmUCX8EE04WCcYa3AeMJeaZDiMtrJAy(nlLKecWCOMmMdhmVbk1hZBq3gPFa3e3KE)qdoUCXCkcMBmpHamxLeNeWn)Ukjo5p)9AQuY8N)tL)ZFxa2wj3NUVBmpHGVpwl57SjDzs77LSjTTsc1uPKbZxX8YyEBmFK6iKcBRemVnMFHEySwsq7av5PMkLbZP)kMRjdjjUa84bQYtnvkZ3ziZus0TbH4K)u53)t6(N)UaSTsUpDFNnPltAFVKnPTvsOMkLmy(kMR73nMNqW3hRL8(Fsh)5VlaBRK7t33zt6YK23lztABLeQPsjdMVI5647gZti47hqiOMJezM)(Fsp)5VlaBRK7t33zt6YK23lztABLeQPsjdMVI5657gZti47eAPMezM)(FcP)5VBmpHGVtkg5(DbyBLCF6E)9VxtqskK5p)Nk)N)UaSTsUpDFNnPltAFFJwRbIvYqiXbAt4cPbW8LlX8nATgiwjdHehOnHroSeqWC6J5nG5m4Xgg1GjWjyo9G5umMtnMxgZ1hZPhmNcbD8DJ5je8DIvYqiXbAZ7)jD)ZFxa2wj3NUVd1(or8VBmpHGVxYM02k57LmfQ8Dk8D2KUmP9D3ucWdAtEyQiTX8IGaSTsUFVKnrGDiFFlepoP27)jD8N)UaSTsUpDFNnPltAFNOjkv0TbH4KG2KhMksBmVaZPcZ197gZti47AtEyQiTX8I3)t65p)DbyBLCF6(oBsxM0((i1rif2wjyEBm)oO5nmPwWtwlseHLa5gHG4i1rifyovyEjBsBRKWKArpzTiyEBmVbmVbmFJwRbpridjwrhKdOAy(YLyodcvxinqWteYqIv0b5WihwciyovyosXC9X82yEdy(gTwdBfeEDtbbKaQgMVCjMRtm3nLa8WwbHx3uqajiaBRKlMRpM3gZVqpmPwq7av5PMkLbZP)kMRjdjjUa84bQYtnvkdMVCjMRtm3nLa8aX2Y4qOxeeGTvYfZ1)7gZti47tQ9(FcP)5VlaBRK7t33pSgffGmiq(7L)UX8ec(EvgilHOK4oD57mKzkj62GqCYFQ87V)9TPmat(Z)PY)5VlaBRK7t33zt6YK233O1AqyQuJircuzt4cPbW82y(gTwdctLAejQqb2eUqAamVnM3aMpsDesHTvcMVCjM3aMBmpljrbihPqWCQW8YyEBm3yEwsIxOhiOGAocMtFm3yEwsIcqosHG56J56)DJ5je8DckOMJ8(Fs3)83fGTvY9P77SjDzs77B0AnimvQrKibQSjmYHLacMtfMZmIh98qW8LlX8nATgeMk1isuHcSjmYHLacMtfMZmIh98q(UX8ec(oXTHGoiK3)t64p)DbyBLCF6(oBsxM0((gTwdctLAejQqb2eg5WsabZPcZzgXJEEiy(YLyobQSjkmvQremNkmNcF3yEcbFN42uZrE)pPN)83fGTvY9P77SjDzs77B0AnimvQrKibQSjmYHLacMtfMZmIh98qW8LlXCfkWMOWuPgrWCQWCk8DJ5je8DAJ5fV)(3Vs1qv(F(pv(p)DbyBLCF6(oBsxM0((gTwdhqiOvcIv4Ceq1W82yUoX87GM3aKMIMyLKiZ8VBmpHGVpOGOX8ecIQK4FxLepcSd57BtzaM8(Fs3)83nMNqW3jTqvQ42ifFxa2wj3NU3)t64p)DbyBLCF6(oBsxM0((DqZBastrtSssKz(3nMNqW3zMsfnMNqquLe)7QK4rGDiFhstrtSsY7)j98N)UX8ec(U2aPP(UaSTsUpDV)Nq6F(7cW2k5(09D2KUmP99nATgyMhRW5iCH0aF3yEcbF3teYqIv0b53)tu8F(7cW2k5(09D2KUmP99nATgyMhRW5iCH0aF3yEcbFNzEScNJ3)t6T)83fGTvY9P77SjDzs77B0AnqkSlK2HOUbunmF5smFJwRbTbstfq1(UX8ec((GcIgZtiiQsI)Dvs8iWoKVtCXuEX7)Pg7p)DbyBLCF6(UX8ec(oZuQOX8ecIQK4FxLepcSd57miuDH0aV)NOi)5VlaBRK7t33zt6YK23zWJnmQbtGtWCQwX8gWCKI5irmVKnPTvsOcrhMwCNUG56)DJ5je89bfenMNqquLe)7QK4rGDiFVMGKuiZ7)PYu4p)DbyBLCF6(oBsxM0((gTwdBsmbSaQgMVCjMVrR1ab9Efq0o2OKIaQ23nMNqW3zMsfnMNqquLe)7QK4rGDiFN4IP8I3)tLl)N)UaSTsUpDFNnPltAF3nLa8WwbHx3uqajiaBRKlM3gZ3O1AyRGWRBkiGeUqAamVnM3aMlazqGmMtnMRJasXC6bZfGmiqomccbG5uJ5nG56Hcyo9G5B0AnWuInmJ4jaravdZ1hZ1hZPpM3aMxUmsXCKiMRRoWC6bZ3O1AibmBaMNqqSvcqeH1OxirkkOaekjGQH56J5TXCJ5zjjU9OpjceYqW8vmNcF3yEcbFxdcvXriq0HjV)NkR7F(7cW2k5(09D2KUmP9D3ucWdBfeEDtbbKGaSTsUyEBmFJwRHTccVUPGas4cPb(UX8ec((GcIgZtiiQsI)Dvs8iWoKVVvq41nfeqE)pvwh)5VlaBRK7t33nMNqW3RYazjeLe3PlFNnPltAFFJwRbttAuuBKR5WHezJvkbicOAFNHmtjr3geIt(tLF)pvwp)5VlaBRK7t33RWjcKg5)PYF3yEcbFxdcvXriq0HjV)NkJ0)83fGTvY9P77gZti47J1s(oBsxM0(Edy(i1rif2wjy(YLyUMmKK4cWJhOkp1uPmyovy(f6HXAjbTduLNAQugmxFmVnMFh08ggRLe8K1IeryjqUriiosDesbMtfMt0eLk62GqCsGql1KiZCmNEWCDXCKiMR73ziZus0TbH4K)u53)tLP4)83fGTvY9P77gZti47hqiOMJezM)D2KUmP99rQJqkSTsW82y(DqZB4acb1CKiZ8GNSwKiclbYncbXrQJqkWCQWCIMOur3geItceAPMezMJ50dMRlMJeXCD)odzMsIUnieN8Nk)(FQSE7p)DbyBLCF6(EforG0i)pv(7gZti47AqOkocbIom59)u5g7p)DbyBLCF6(UX8ec(UxmgPiYm)7SjDzs77JuhHuyBLG5TX87GM3GxmgPiYmp4jRfjIWsGCJqqCK6iKcmNkmVKnPTvsWlgJue9K1IG5TXCDI5B0AnSjXeWcOAFNHmtjr3geIt(tLF)pvMI8N)UaSTsUpDFVcNiqAK)Nk)DJ5je8DniufhHarhM8(Fsxk8N)UaSTsUpDFNnPltAFVbmFS8gLscWd29scjaZPcZBaZlJ5uJ5hwJIScBqiemhjI5ScBqiKyDmMNqGPWC9XC6bZhHvydcj65HG56J5TX8gWCIMOur3geItc7b1nvKOmsbMtpyUX8ecc7b1nvKOmsr4AhgcbZPeZnMNqqypOUPIeLrkcmiXXC9XCQW8gWCJ5jeeifJCdx7WqiyoLyUX8eccKIrUbgK4yU(F3yEcbFFpOUPIeLrkE)pPB5)83fGTvY9P77SjDzs77enrPIUnieNei0snjYmhZPcZlJ5uJ5B0AnSjXeWcOAyo9G56(DJ5je8DcTutImZF)pPRU)5VlaBRK7t33zt6YK233O1AGPeBygXtaIaQ23nMNqW3jfJCF)pPRo(ZFxa2wj3NUVBmpHGVpwl57SjDzs77B0AnSjXeWcOAyEBm)oO5nmwlj4jRfjIWsGCJqqCK6iKcmNkmx3VZqMPKOBdcXj)PYV)N0vp)5VlaBRK7t33nMNqW3zMsfnMNqquLe)7QK4rGDiFVMkLmV)(31gHbp2M)N)tL)ZFxa2wj3NUVd1(or8VBmpHGVxYM02k57LmfQ8Dk89s2eb2H89keDyAXD6Y7)jD)ZFxa2wj3NUVd1(or8VBmpHGVxYM02k57LmfQ8Dk89s2eb2H89AQuY8(Fsh)5VlaBRK7t33HAFNi(3nMNqW3lztABL89sMcv(UE77LSjcSd57tQf9K1I8(Fsp)5VlaBRK7t33HAFNi(3nMNqW3lztABL89sMcv(E5VxYMiWoKV7fJrkIEYArE)pH0)83nMNqW3BLG7i3irlN0jFxa2wj3NU3)tu8F(7gZti47BO7k5gRkdz5slbiIoSrj47cW2k5(09(FsV9N)UaSTsUpDFNnPltAFFJwRHdie0kbXkCocxinW3nMNqW31gin17)Pg7p)DbyBLCF6(oBsxM0((gTwdhqiOvcIv4CeUqAGVBmpHGVZmpwHZX7V)9TccVUPGaYF(pv(p)DbyBLCF6(UX8ec((yTKVZM0LjTV3aMRtm3twReGaZxUeZBaZhPocPW2kbZBJ5AYqsIlapEGQ8utLYG5uH5xOhgRLe0oqvEQPszWC9X8LlX8gWCJ5zjjU9OpjceYqW8vmxxmVnMRjdjjUa84bQYtnvkdMtfMFHEySwsq7av5PMkLbZ1hZxUeZBaZnMNLK42J(KiqidbZxXCDX82y(i1rif2wjyU(yU(yEBmFJwRHThhRLeUqAamVnMFh08ggRLe8K1IeryjqUriiosDesbMt1kMR73ziZus0TbH4K)u53)t6(N)UaSTsUpDF3yEcbF)acb1CKiZ8VZM0LjTVpsDesHTvcM3gZ3O1Ay7XdieuZrcxinW3ziZus0TbH4K)u53)t64p)DbyBLCF6(UX8ec(UxmgPiYm)7SjDzs77JuhHuyBLG5TX8nATg2E0lgJueUqAamVnMFh08g8IXifrM5bpzTirewcKBecIJuhHuG5uH5LSjTTscEXyKIONSwKVZqMPKOBdcXj)PYV)N0ZF(7cW2k5(09D2KUmP99nATg2ECpOUPIeLrkcxinW3nMNqW33dQBQirzKI3)ti9p)DbyBLCF6(oBsxM0((gTwdBpsOLAs4cPbW82yortuQOBdcXjbcTutImZXCQW8YF3yEcbFNql1KiZ83)tu8F(7cW2k5(09D2KUmP99nATg2EKumYnCH0aF3yEcbFNumY99)KE7p)DbyBLCF6(oBsxM0((gTwdBpsOLAs4cPb(UX8ec(oHwQjrM5V)NAS)83fGTvY9P77SjDzs77B0AnS9OxmgPiCH0aF3yEcbF3lgJuezM)(7FN4IP8I)8FQ8F(7cW2k5(099kCIaPr(FQ83nMNqW31GqvCeceDyY7)jD)ZFxa2wj3NUVBmpHGVpwl57SjDzs77nG5xOhgRLe0oqvEQPszWC6J5LdifZxUeZhPocPW2kbZ1hZBJ53bnVHXAjbpzTirewcKBecIJuhHuG5uH56(DgYmLeDBqio5pv(9)Ko(ZFxa2wj3NUVxHteinY)tL)UX8ec(UgeQIJqGOdtE)pPN)83fGTvY9P77gZti47EXyKIiZ8VZM0LjTVpsDesHTvcM3gZVdAEdEXyKIiZ8GNSwKiclbYncbXrQJqkWCQW8s2K2wjbVymsr0twlcM3gZjAIsfDBqioj4fJrkImZXCQWCD8DgYmLeDBqio5pv(9)es)ZFxa2wj3NUVZM0LjTVt0eLk62GqCsypOUPIeLrkWCQWCD)UX8ec((EqDtfjkJu8(FII)ZFxa2wj3NUVxHteinY)tL)UX8ec(UgeQIJqGOdtE)pP3(ZF3yEcbFNumY97cW2k5(09(7FNbHQlKg4p)Nk)N)UaSTsUpDFNnPltAFNbp2WOgmbobZPpMRJVBmpHGVxLXuX6ia6fYV)N09p)DbyBLCF6(oBsxM0(odESHrnycCcMt1kMRJVBmpHGVVLHitR3)t64p)DbyBLCF6(oBsxM0(odESHrnycCcMt1kMRJVBmpHGVNaMnaZti49)KE(ZFxa2wj3NUVZM0LjTVlazqGC4k1KLoMtfMRhkG5lxI5B0AnSjXeWcOAy(YLyEdyUBkb4bTrUMdNGaSTsUyEBmVKnPTvsGuahxiE09lMtFmxhyU(F3yEcbF3teYqIv0b53)ti9p)DbyBLCF6(oBsxM0((gTwdEIqgsSIoihq1W82y(gTwdBsmbSWfsdG5TXCg8ydJAWe4emN(yUEW82y(f6HXAjbTduLNAQugmN(yE5afJ5TXCbidcKXCQWC9qHVBmpHGVtkSlK2HOUV)NO4)83fGTvY9P77SjDzs77B0An4jcziXk6GCavdZxUeZ3O1AytIjGfq1(UX8ec((wgImTsaI3)t6T)83fGTvY9P77SjDzs77B0AnSjXeWcOAF3yEcbFxd6je8(FQX(ZFxa2wj3NUVZM0LjTVVrR1WMetalGQH5lxI51erHhh5WsabZPpMRB5VBmpHGVpwjbarjX6ia6fYV)NOi)5VlaBRK7t33zt6YK23BaZVqpmPwyKdlbemNkmxpyEBmNbp2WOgmbobZPpMRdmVnMFHEySwsWtwReGaZBJ5cqgeihUsnzPJ5uTI56sbmxFmF5smVMik84ihwciyo9XCK(DJ5je8Dgeuc2sIEHejA5Ko59)uzk8N)UaSTsUpDFNnPltAFFJwRbpridjwrhKdOAy(YLyEdyodcUOPhUIOfnLsqKgGjbbyBLCXC9)UX8ec(UCObPjtCdb33)tLl)N)UaSTsUpDF3yEcbF3UMMNLKiHMnhFNnPltAFNbp2WOgmbobZxXCKI5TXCDI5xOhSRP5zjjsOzZr8Ahgcj4jRvcq8DgYmLeDBqio5pv(9)uzD)ZF3yEcbFhLiX0LdY3fGTvY9P793)oKMIMyLK)8FQ8F(7cW2k5(09D2KUmP99nATgkeB8iSg9cjslv3aQ23nMNqW3jUne0bH8(Fs3)83fGTvY9P77SjDzs776eZ1gPueb7gkhiOGAocM3gZ1jMRnsPic2nOBGGcQ5iF3yEcbFNGcQ5iV)N0XF(7cW2k5(09D2KUmP9DbidcKXC6J56HcyEBmVbm)c9WKAHroSeqWCQWC9eqkMVCjMZGhByudMaNG50hZrkMRpM3gZzqO6cPbcEIqgsSIoihg5WsabZPAfZP4asX82y(gTwdmLydZiEcqeiUXAH50hZlJ5TXCDI5B0AnyAsJIAJCnhoKiBSsjaravdZBJ56eZ3O1AyRGWRcL4bunmVnM3aMVrR1WMetalmYHLacMtfMJumF5smxNy(gTwdBsmbSaQgMRpM3gZBaZ1jMZGq1fsdeyqqjylj6fsKOLt6KaQgMVCjMRtmNbljad4bqIOWJvtWC9)UX8ec(EHyJhH1OxirAP6((Fsp)5VlaBRK7t33zt6YK23fGmiqgZPpMRhkG5TX8gW8l0dtQfg5WsabZPcZ1taPy(YLyodESHrnycCcMtFmhPyU(yEBmNbHQlKgi4jcziXk6GCyKdlbemNQvmNIdifZBJ5B0AnWuInmJ4jarG4gRfMtFmVmM3gZ1jMVrR1GPjnkQnY1C4qISXkLaebunmVnMRtmFJwRHTccVkuIhq1W82yEdy(gTwdBsmbSWihwciyovyosX8LlXCDI5B0AnSjXeWcOAyU(yEBmVbmxNyodcvxinqGbbLGTKOxirIwoPtcOAy(YLyUoXCgSKamGhajIcpwnbZ1)7gZti47hqiOvcIv4C8(7V)Dd1lGZ375rJ793)ha]] )


end
