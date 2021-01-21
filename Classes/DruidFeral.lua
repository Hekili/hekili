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

            spend = function ()
                return 25 * ( buff.incarnation.up and 0.8 or 1 ), "energy"
            end,
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
                if args.max_energy and args.max_energy > 0 then return 50 * ( buff.incarnation.up and 0.8 or 1 ) end
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


    spec:RegisterPack( "Feral", 20210121, [[dSuOebqisf9iiIUKusfBsj8jPKsnkPeNIuvRcPeVcj1SKsDlic2LGFHeggsKJjrwgPspdPutJufxdI02qIQVrQsmoicDoKsY6ivPAEKkCpL0(qsoOusLwisXdLskMiPkjBukPQpkLusNePKQvkfntKOOBsQsQDQI8tKskdLuLILsQsPNkvtvf1xrIc1yLskXEv1FfAWO6WuwSs9yuMSkDzInlPpdHrlHtlA1irbVwkmBsUTkSBGFdA4KYXrIcz5kEoIPt11H02LO(os14LsY5HOwpsuA(kr7hQ)s)5VFnx(t6sjDlrPs6wkucP0UKU0(7oYAY31mwddH8DGDiFV1lJP(UMHScA3)83jq0HjFVWDnIENckqKEb6oWGhuqYduL5jeWgR6uqYdgfFFJMkNwh87VFnx(t6sjDlrPs6wkucP0UujK43nuVaoFVNhTMVxK3Ra(93VcH9DKeZB9YykmxVAqZlUjsI5nnaQniJ56wQnMRlL0TeUjUjsI5TEzmfM36Q3qzI5mdG5MIaX8TG5vik4I5MJ5fURr07uqbIK4bePxGUdm4bfTwmaL1gJckhjsROCgsKwrRO8ksTktqktkvcPxZOTrjK41QvCtKeZBnfgaHG53bnVbiDfDXklrM5RLWCwHWAqWChI53bnVbiDfDXklrM5HVRsIt(ZFFRGWRBkiG8N)tL(ZFxa2wj3NMVBmpHGVpwd57SjDzs77TG56eZ9K1ibiW8LlX8wW8rQJqkSTsW8fyUMmKK4cWJhOkp1uPmyovy(f6HXAibTduLNAQugmxFmF5smVfm3yEwwIBp6tIaHmemFfZ1fZxG5AYqsIlapEGQ8utLYG5uH5xOhgRHe0oqvEQPszWC9X8LlX8wWCJ5zzjU9OpjceYqW8vmxxmFbMpsDesHTvcMRpMRpMVaZ3O1Ay7XXAiHlKoaZxG53bnVHXAibpznirewcKBecIJuhHuG5uTI56(DgYmLeDBqio5pv69)KU)5VlaBRK7tZ3nMNqW3pGqqnhjYm)7SjDzs77JuhHuyBLG5lW8nATg2E8acb1CKWfsh8DgYmLeDBqio5pv69)eT)ZFxa2wj3NMVBmpHGV7fJrkImZ)oBsxM0((i1rif2wjy(cmFJwRHTh9IXifHlKoaZxG53bnVbVymsrKzEWtwdseHLa5gHG4i1rifyovyEzBsBRKGxmgPi6jRb57mKzkj62GqCYFQ07)j98N)UaSTsUpnFNnPltAFFJwRHTh3dQBQirzKIWfsh8DJ5je899G6MksugP49)es)ZFxa2wj3NMVZM0LjTVVrR1W2Je6PMeUq6amFbMt0eLk62GqCsGqp1KiZCmNkmV03nMNqW3j0tnjYm)9)eL)N)UaSTsUpnFNnPltAFFJwRHThjfJCdxiDW3nMNqW3jfJCF)pPx(ZFxa2wj3NMVZM0LjTVVrR1W2Je6PMeUq6GVBmpHGVtONAsKz(7)jK4F(7cW2k5(08D2KUmP99nATg2E0lgJueUq6GVBmpHGV7fJrkImZF)9VxtqskK5p)Nk9N)UaSTsUpnFNnPltAFFJwRbIv2qiXbAt4cPdW8LlX8nATgiwzdHehOnHroSeqWCDG5TG5m4Xgg1GjWjyoTG5uoMtnMxcZ1hZPfmNsbA)DJ5je8DIv2qiXbAZ7)jD)ZFxa2wj3NMVd1(or8VBmpHGVx2M02k57LnfQ8Dk9D2KUmP9D3ucWdAtEyQi9X8IGaSTsUFVSnrGDiFFlepoP27)jA)N)UaSTsUpnFNnPltAFNOjkv0TbH4KG2KhMksFmVaZPcZ197gZti47AtEyQi9X8I3)t65p)DbyBLCFA(oBsxM0((i1rif2wjy(cm)oO5nmPwWtwdseHLa5gHG4i1rifyovyEzBsBRKWKArpzniy(cmVfmVfmFJwRbpridjwrhKdOAy(YLyodcvxiDqWteYqIv0b5WihwciyovyosXC9X8fyEly(gTwdBfeEDtbbKaQgMVCjMRtm3nLa8WwbHx3uqajiaBRKlMRpMVaZVqpmPwq7av5PMkLbZ1XkMRjdjjUa84bQYtnvkdMVCjMRtm3nLa8aX2Y4qOxeeGTvYfZ1)7gZti47tQ9(FcP)5VlaBRK7tZ3pSwffGmiq(pv67gZti47vzGSeIsI70LVZqMPKOBdcXj)PsV)(33MYam5p)Nk9N)UaSTsUpnFNnPltAFFJwRbHPsnIejqLnHlKoaZxG5B0AnimvQrKOcfyt4cPdW8fyEly(i1rif2wjy(YLyElyUX8SSefGCKcbZPcZlH5lWCJ5zzjEHEGGcQ5iyUoWCJ5zzjka5ifcMRpMR)3nMNqW3jOGAoY7)jD)ZFxa2wj3NMVZM0LjTVVrR1GWuPgrIeOYMWihwciyovyoZiE0ZdbZxUeZ3O1AqyQuJirfkWMWihwciyovyoZiE0Zd57gZti47e3gc6GqE)pr7)83fGTvY9P57SjDzs77B0AnimvQrKOcfytyKdlbemNkmNzep65HG5lxI5eOYMOWuPgrWCQWCk9DJ5je8DIBtnh59)KE(ZFxa2wj3NMVZM0LjTVVrR1GWuPgrIeOYMWihwciyovyoZiE0ZdbZxUeZvOaBIctLAebZPcZP03nMNqW3PpMx8(7F)kvdv5)5)uP)83fGTvY9P57SjDzs77B0AnCaHGgjiwHZravdZxG56eZVdAEdq6k6IvwImZ)UX8ec((GcIgZtiiQsI)Dvs8iWoKVVnLbyY7)jD)ZF3yEcbFN0avPIBJu8DbyBLCFAE)pr7)83fGTvY9P57SjDzs773bnVbiDfDXklrM5F3yEcbFNzkv0yEcbrvs8VRsIhb2H8DiDfDXklV)N0ZF(7gZti47AdKU67cW2k5(08(FcP)5VlaBRK7tZ3zt6YK233O1AGzEScNJWfsh8DJ5je8DpridjwrhKF)pr5)5VlaBRK7tZ3zt6YK233O1AGzEScNJWfsh8DJ5je8DM5XkCoE)pPx(ZFxa2wj3NMVZM0LjTVVrR1aPWUq6hI6gq1W8LlX8nATg0giDvav77gZti47dkiAmpHGOkj(3vjXJa7q(oXft5fV)NqI)5VlaBRK7tZ3nMNqW3zMsfnMNqquLe)7QK4rGDiFNbHQlKo49)eT6p)DbyBLCFA(oBsxM0(odESHrnycCcMt1kM3cMJumhjG5LTjTTscvi6W0I70fmx)VBmpHGVpOGOX8ecIQK4FxLepcSd571eKKczE)pvIs)5VlaBRK7tZ3zt6YK233O1AytIjGfq1W8LlX8nATgiO3RaI2XgLueq1(UX8ec(oZuQOX8ecIQK4FxLepcSd57exmLx8(FQuP)83fGTvY9P57SjDzs77UPeGh2ki86MccibbyBLCX8fy(gTwdBfeEDtbbKWfshG5lW8wWCbidcKXCQXCAhqkMtlyUaKbbYHrqiamNAmVfmxpucZPfmFJwRbMsSHzepbicOAyU(yU(yUoW8wW8sLqkMJeWCDPnMtly(gTwdjGzdW8ecInsaIiSg9cjszafGqjbunmxFmFbMBmpllXTh9jrGqgcMVI5u67gZti47AqOkocbIom59)ujD)ZFxa2wj3NMVZM0LjTV7MsaEyRGWRBkiGeeGTvYfZxG5B0AnSvq41nfeqcxiDW3nMNqW3huq0yEcbrvs8VRsIhb2H89TccVUPGaY7)Ps0(p)DbyBLCFA(UX8ec(EvgilHOK4oD57SjDzs77B0AnyAsRIAJCnhoKiBSYjarav77mKzkj62GqCYFQ07)Ps65p)DbyBLCFA(EforG0k)pv67gZti47AqOkocbIom59)ujK(N)UaSTsUpnF3yEcbFFSgY3zt6YK23BbZhPocPW2kbZxUeZ1KHKexaE8av5PMkLbZPcZVqpmwdjODGQ8utLYG56J5lW87GM3WynKGNSgKiclbYncbXrQJqkWCQWCIMOur3geItce6PMezMJ50cMRlMJeWCD)odzMsIUnieN8Nk9(FQeL)N)UaSTsUpnF3yEcbF)acb1CKiZ8VZM0LjTVpsDesHTvcMVaZVdAEdhqiOMJezMh8K1GeryjqUriiosDesbMtfMt0eLk62GqCsGqp1KiZCmNwWCDXCKaMR73ziZus0TbH4K)uP3)tL0l)5VlaBRK7tZ3RWjcKw5)PsF3yEcbFxdcvXriq0HjV)NkHe)ZFxa2wj3NMVBmpHGV7fJrkImZ)oBsxM0((i1rif2wjy(cm)oO5n4fJrkImZdEYAqIiSei3ieehPocPaZPcZlBtABLe8IXifrpzniy(cmxNy(gTwdBsmbSaQ23ziZus0TbH4K)uP3)tLOv)5VlaBRK7tZ3RWjcKw5)PsF3yEcbFxdcvXriq0HjV)N0Ls)5VlaBRK7tZ3zt6YK23BbZhlVrPSa8GDVKqcWCQW8wW8syo1y(H1QiRWgecbZrcyoRWgecjwhJ5jeykmxFmNwW8ryf2GqIEEiyU(y(cmVfmNOjkv0TbH4KWEqDtfjkJuG50cMBmpHGWEqDtfjkJueU2HHqWCkWCJ5jee2dQBQirzKIadsCmxFmNkmVfm3yEcbbsXi3W1omecMtbMBmpHGaPyKBGbjoMR)3nMNqW33dQBQirzKI3)t6w6p)DbyBLCFA(oBsxM0(ortuQOBdcXjbc9utImZXCQW8syo1y(gTwdBsmbSaQgMtlyUUF3yEcbFNqp1KiZ83)t6Q7F(7cW2k5(08D2KUmP99nATgykXgMr8eGiGQ9DJ5je8DsXi33)t6s7)83fGTvY9P57gZti47J1q(oBsxM0((gTwdBsmbSaQgMVaZVdAEdJ1qcEYAqIiSei3ieehPocPaZPcZ197mKzkj62GqCYFQ07)jD1ZF(7cW2k5(08DJ5je8DMPurJ5jeevjX)UkjEeyhY3RPsjZ7V)DTryWJT5)5)uP)83fGTvY9P57qTVte)7gZti47LTjTTs(EztHkFNsFVSnrGDiFVcrhMwCNU8(Fs3)83fGTvY9P57qTVte)7gZti47LTjTTs(EztHkFNsFVSnrGDiFVMkLmV)NO9F(7cW2k5(08DO23jI)DJ5je89Y2K2wjFVSPqLVRx(EzBIa7q((KArpzniV)N0ZF(7cW2k5(08DO23jI)DJ5je89Y2K2wjFVSPqLVx67LTjcSd57EXyKIONSgK3)ti9p)DJ5je89gj4oYns0YjDY3fGTvY9P59)eL)N)UX8ec((g6UsUXQYqwU0taIOdBvc(UaSTsUpnV)N0l)5VlaBRK7tZ3zt6YK233O1A4acbnsqScNJWfsh8DJ5je8DTbsx9(Fcj(N)UaSTsUpnFNnPltAFFJwRHdie0ibXkCocxiDW3nMNqW3zMhRW5493)Envkz(Z)Ps)5VlaBRK7tZ3nMNqW3hRH8D2KUmP99Y2K2wjHAQuYG5RyEjmFbMpsDesHTvcMVaZVqpmwdjODGQ8utLYG56yfZ1KHKexaE8av5PMkL57mKzkj62GqCYFQ07)jD)ZFxa2wj3NMVZM0LjTVx2M02kjutLsgmFfZ197gZti47J1qE)pr7)83fGTvY9P57SjDzs77LTjTTsc1uPKbZxXCA)DJ5je89dieuZrImZF)pPN)83fGTvY9P57SjDzs77LTjTTsc1uPKbZxXC98DJ5je8Dc9utImZF)pH0)83nMNqW3jfJC)UaSTsUpnV)(3jUykV4p)Nk9N)UaSTsUpnFVcNiqAL)Nk9DJ5je8DniufhHarhM8(Fs3)83fGTvY9P57gZti47J1q(oBsxM0(Ely(f6HXAibTduLNAQugmxhyEPasX8LlX8rQJqkSTsWC9X8fy(DqZBySgsWtwdseHLa5gHG4i1rifyovyUUFNHmtjr3geIt(tLE)pr7)83fGTvY9P57v4ebsR8)uPVBmpHGVRbHQ4iei6WK3)t65p)DbyBLCFA(UX8ec(UxmgPiYm)7SjDzs77JuhHuyBLG5lW87GM3GxmgPiYmp4jRbjIWsGCJqqCK6iKcmNkmVSnPTvsWlgJue9K1GG5lWCIMOur3geItcEXyKIiZCmNkmN2FNHmtjr3geIt(tLE)pH0)83fGTvY9P57SjDzs77enrPIUnieNe2dQBQirzKcmNkmx3VBmpHGVVhu3urIYifV)NO8)83fGTvY9P57v4ebsR8)uPVBmpHGVRbHQ4iei6WK3)t6L)83nMNqW3jfJC)UaSTsUpnV)(3zqO6cPd(Z)Ps)5VlaBRK7tZ3zt6YK23zWJnmQbtGtWCDG50(7gZti47vzmvSocGYI87)jD)ZFxa2wj3NMVZM0LjTVZGhByudMaNG5uTI50(7gZti47BziY049)eT)ZFxa2wj3NMVZM0LjTVZGhByudMaNG5uTI50(7gZti47jGzdW8ecE)pPN)83fGTvY9P57SjDzs77cqgeihUsnzPJ5uH56Hsy(YLy(gTwdBsmbSaQgMVCjM3cM7MsaEqBKR5WjiaBRKlMVaZlBtABLeifWXfIhD)I56aZPnMR)3nMNqW39eHmKyfDq(9)es)ZFxa2wj3NMVZM0LjTVVrR1GNiKHeROdYbunmFbMVrR1WMetalCH0by(cmNbp2WOgmbobZ1bMRhmFbMFHEySgsq7av5PMkLbZ1bMxkq5y(cmxaYGazmNkmxpu67gZti47Kc7cPFiQ77)jk)p)DbyBLCFA(oBsxM0((gTwdEIqgsSIoihq1W8LlX8nATg2KycybuTVBmpHGVVLHitJeG49)KE5p)DbyBLCFA(oBsxM0((gTwdBsmbSaQ23nMNqW31GEcbV)NqI)5VlaBRK7tZ3zt6YK233O1AytIjGfq1W8LlX8AIOWJJCyjGG56aZ1T03nMNqW3hRSaGOKyDeaLf53)t0Q)83fGTvY9P57SjDzs77TG5xOhMulmYHLacMtfMRhmFbMZGhByudMaNG56aZPnMVaZVqpmwdj4jRrcqG5lWCbidcKdxPMS0XCQwXCDPeMRpMVCjMxtefECKdlbemxhyos)UX8ec(odckdBirVqIeTCsN8(FQeL(ZFxa2wj3NMVZM0LjTVVrR1GNiKHeROdYbunmF5smVfmNbbx00dxr0IMsjisdWKGaSTsUyU(F3yEcbFxo0G0LjUHG77)PsL(ZFxa2wj3NMVBmpHGVBxtZZYsKq3MJVZM0LjTVZGhByudMaNG5RyosX8fyUoX8l0d2108SSej0T5iETddHe8K1ibi(odzMsIUnieN8Nk9(FQKU)5VBmpHGVJsKy6Yb57cW2k5(08(7FhsxrxSYYF(pv6p)DbyBLCFA(oBsxM0((gTwdfInEewJEHePNQBav77gZti47e3gc6GqE)pP7F(7cW2k5(08D2KUmP9DDI5AJuoIGDdLceuqnhbZxG56eZ1gPCeb7g0nqqb1CKVBmpHGVtqb1CK3)t0(p)DbyBLCFA(oBsxM0(UaKbbYyUoWC9qjmFbM3cMFHEysTWihwciyovyUEcifZxUeZzWJnmQbtGtWCDG5ifZ1hZxG5miuDH0bbpridjwrhKdJCyjGG5uTI5uEaPy(cmFJwRbMsSHzepbice3ynWCDG5LW8fyUoX8nATgmnPvrTrUMdhsKnw5eGiGQH5lWCDI5B0AnSvq4vHs8aQgMVaZBbZ3O1AytIjGfg5WsabZPcZrkMVCjMRtmFJwRHnjMawavdZ1hZxG5TG56eZzqO6cPdcmiOmSHe9cjs0YjDsavdZxUeZ1jMZGLfGb8airu4XQjyU(F3yEcbFVqSXJWA0lKi9uDF)pPN)83fGTvY9P57SjDzs77cqgeiJ56aZ1dLW8fyEly(f6Hj1cJCyjGG5uH56jGumF5smNbp2WOgmbobZ1bMJumxFmFbMZGq1fshe8eHmKyfDqomYHLacMt1kMt5bKI5lW8nATgykXgMr8eGiqCJ1aZ1bMxcZxG56eZ3O1AW0Kwf1g5AoCir2yLtaIaQgMVaZ1jMVrR1WwbHxfkXdOAy(cmVfmFJwRHnjMawyKdlbemNkmhPy(YLyUoX8nATg2KycybunmxFmFbM3cMRtmNbHQlKoiWGGYWgs0lKirlN0jbunmF5smxNyodwwagWdGerHhRMG56)DJ5je89die0ibXkCoE)93)Ezzije8N0Ls6wIsLkPx(oDBajab57ug36Q3EIw)uRv9oMJ5Nlempp0GJJ5v4G5T2xPAOkV1gZhHYi0CKlMtGhcMBOo8WC5I5ScdGqibCtkZeiyUUusVJ5TgiOSmUCX8EE0AWCcYa3AfM36G5oeZPmrnm)MLtscbyoutgZHdM3cf6J5TOBR0pGBIBsRFObhxUyoTcZnMNqaMRsItc4MFNOjS)ujkr7VRnWAQKVJKyERxgtH56vdAEXnrsmVPbqTbzmx3sTXCDPKULWnXnrsmV1lJPW8wx9gktmNzam3ueiMVfmVcrbxm3CmVWDnIENckqKepGi9c0DGbpOO1IbOS2yuq5irAfLZqI0kAfLxrQvzcszsPsi9AgTnkHeVwTIBIKyERPWaiem)oO5naPROlwzjYmFTeMZkewdcM7qm)oO5naPROlwzjYmpGBIBAmpHasqBeg8yBo1Ruu2M02kPnWoK1keDyAXD6s7YMcvwPeUjsI59IrUy(kMtP2y(jiajqaMgPa6yUER1qW8vmVuBmVdmnsb0XC9wRHG5RyUUTXCktADmFfZPDBmVtp1emFfZ1dUPX8ecibTryWJT5uVsrzBsBRK2a7qwRPsjt7YMcvwPeUjsI5DMPemNE6fyEHrCjGBAmpHasqBeg8yBo1Ruu2M02kPnWoK1j1IEYAqAx2uOYQEb30yEcbKG2im4X2CQxPOSnPTvsBGDiREXyKIONSgK2LnfQSwc30yEcbKG2im4X2CQxPOrcUJCJeTCsNGBAmpHasqBeg8yBo1RuSHURKBSQmKLl9eGi6WwLaCtJ5jeqcAJWGhBZPELcTbsx1oRRB0AnCaHGgjiwHZr4cPdWnnMNqajOncdESnN6vkyMhRW5ODwx3O1A4acbnsqScNJWfshGBIBAmpHaY6GcIgZtiiQsI3gyhY62ugGjTZ66gTwdhqiOrcIv4Ceq1wOZ7GM3aKUIUyLLiZCCtJ5jeqOELcsduLkUnsbUPX8eciuVsbZuQOX8ecIQK4Tb2HScPROlwzPDwxVdAEdq6k6IvwImZXnrsmxVzG0vyo9cbiLLbZ1GesUvcUPX8eciuVsH2aPRWnnMNqaH6vk8eHmKyfDqUDwx3O1AGzEScNJWfshGBAmpHac1RuWmpwHZr7SUUrR1aZ8yfohHlKoa3ejXCAnGG5KcOJ5exmLxGBAmpHac1RumOGOX8ecIQK4Tb2HSsCXuEr7SUUrR1aPWUq6hI6gq1wUCJwRbTbsxfq1WnnMNqaH6vkyMsfnMNqquLeVnWoKvgeQUq6aCtJ5jeqOELIbfenMNqquLeVnWoK1AcssHmTZ6kdESHrnycCcvRTGuKqzBsBRKqfIomT4oDrFCtKeZ1RrvEIeqWUyoXft5f4MgZtiGq9kfmtPIgZtiiQsI3gyhYkXft5fTZ66gTwdBsmbSaQ2YLB0AnqqVxbeTJnkPiGQHBIKy(5cbZpGehZLwPjaswwWCAoJ5mKzkbZB5CXiKcmVxmYfZ70tnbZzqIJ5LkHumxaYGa52y(H1qWCc6iyoDbZzgaZpSgcM7fMJ5jaZ1dMJqb3MIOpUPX8eciuVsHgeQIJqGOdtAN1v3ucWdBfeEDtbbKGaSTsUl2O1AyRGWRBkiGeUq6GfTiazqGm10oGuAraYGa5Wiiea1TOhkrlB0AnWuInmJ4jaravtF91rlLkHuKGU0Mw2O1AibmBaMNqqSrcqeH1OxirkdOaekjGQP)cJ5zzjU9OpjceYqwPeUPX8eciuVsXGcIgZtiiQsI3gyhY6wbHx3uqaPDwxDtjapSvq41nfeqccW2k5UyJwRHTccVUPGas4cPdWnnMNqaH6vkQYazjeLe3PlTziZus0TbH4K1sTZ66gTwdMM0QO2ixZHdjYgRCcqeq1WnnMNqaH6vk0GqvCeceDys7kCIaPv(AjCtJ5jeqOELIXAiTziZus0TbH4K1sTZ6AlJuhHuyBLSCPMmKK4cWJhOkp1uPmuDHEySgsq7av5PMkLr)f3bnVHXAibpznirewcKBecIJuhHuqfrtuQOBdcXjbc9utImZPfDrc6IBAmpHac1RuCaHGAosKzEBgYmLeDBqiozTu7SUosDesHTvYI7GM3WbecQ5irM5bpznirewcKBecIJuhHuqfrtuQOBdcXjbc9utImZPfDrc6IBAmpHac1RuObHQ4iei6WK2v4ebsR81s4MgZtiGq9kfEXyKIiZ82mKzkj62GqCYAP2zDDK6iKcBRKf3bnVbVymsrKzEWtwdseHLa5gHG4i1rifuv2M02kj4fJrkIEYAqwOZnATg2KycybunCtJ5jeqOELcniufhHarhM0UcNiqALVwc30yEcbeQxPypOUPIeLrkAN11wglVrPSa8GDVKqcOQLsuFyTkYkSbHqqcScBqiKyDmMNqGP0NwgHvydcj65HO)IwiAIsfDBqiojShu3urIYif0IX8ecc7b1nvKOmsr4AhgcP1XyEcbH9G6MksugPiWGexFQAXyEcbbsXi3W1omesRJX8eccKIrUbgK46JBAmpHac1RuqONAsKzE7SUs0eLk62GqCsGqp1KiZCQkr9gTwdBsmbSaQgTOlUPX8eciuVsbPyKB7SUUrR1atj2WmINaebunCtJ5jeqOELIXAiTziZus0TbH4K1sTZ66gTwdBsmbSaQ2I7GM3WynKGNSgKiclbYncbXrQJqkOsxCtJ5jeqOELcMPurJ5jeevjXBdSdzTMkLm4M4MgZtiGe2ki86McciRJ1qAZqMPKOBdcXjRLAN11w0PNSgjaXYLTmsDesHTvYcnzijXfGhpqvEQPszO6c9WynKG2bQYtnvkJ(lx2IX8SSe3E0NebcziR6UqtgssCb4XduLNAQugQUqpmwdjODGQ8utLYO)YLTympllXTh9jrGqgYQUlgPocPW2krF9xSrR1W2JJ1qcxiDWI7GM3WynKGNSgKiclbYncbXrQJqkOAvxCtJ5jeqcBfeEDtbbeQxPqHcSjMaIwoMNqqBgYmLeDBqiozTu7SUosDesHTvYInATg2E8acb1CKWfshGBAmpHasyRGWRBkiGq9kfEXyKIiZ82mKzkj62GqCYAP2zDDK6iKcBRKfB0AnS9OxmgPiCH0blUdAEdEXyKIiZ8GNSgKiclbYncbXrQJqkOQSnPTvsWlgJue9K1GGBAmpHasyRGWRBkiGq9kf7b1nvKOmsr7SUUrR1W2J7b1nvKOmsr4cPdWnnMNqajSvq41nfeqOELcc9utImZBN11nATg2EKqp1KWfshSGOjkv0TbH4KaHEQjrM5uvc30yEcbKWwbHx3uqaH6vkifJCBN11nATg2EKumYnCH0b4MgZtiGe2ki86McciuVsbHEQjrM5TZ66gTwdBpsONAs4cPdWnnMNqajSvq41nfeqOELcVymsrKzE7SUUrR1W2JEXyKIWfshGBIBAmpHasGbHQlKoyTkJPI1rauwKBN1vg8ydJAWe4eDqBCtKeZptRPxrRP3X8tICXChI5eKbmmNE6fyo90lW8XklaikbZRJaOSiJ50leaMtxW8bfG51rauwK3g42gZHdMBUsmIJ5ScH1aZZkMNobZPdhVaZth30yEcbKadcvxiDa1RuSLHitJ2zDLbp2WOgmboHQvAJBAmpHasGbHQlKoG6vksaZgG5je0oRRm4Xgg1GjWjuTsBCtKeZppiJ5g4I5aOJ50nIlyUdHy(bkRaZp36XCbidcKBJ5BuhZnfbI5ugqjoMJsempDmVchmNYktdm3axmpbmBaeCtJ5jeqcmiuDH0buVsHNiKHeROdYTZ6QaKbbYHRutw6uPhkTC5gTwdBsmbSaQ2YLT4MsaEqBKR5WjiaBRK7IY2K2wjbsbCCH4r3V6G26JBIKyUEDIOWX8TG50hiabM7qmhLiyE)quxmhcWC9wRHG5jaZlldYyEzzqgZbjRqWCs6OMNqaPnMVrDmVSmiJ5JnIczCtJ5jeqcmiuDH0buVsbPWUq6hI62oRRB0An4jcziXk6GCavBXgTwdBsmbSWfshSGbp2WOgmborh6zXf6HXAibTduLNAQugDukq5leGmiqMk9qjCtJ5jeqcmiuDH0buVsXwgImnsaI2zDDJwRbpridjwrhKdOAlxUrR1WMetalGQHBAmpHasGbHQlKoG6vk0GEcbTZ66gTwdBsmbSaQgUPX8ecibgeQUq6aQxPySYcaIsI1rauwKBN11nATg2KycybuTLlRjIcpoYHLaIo0TeUjsI5NP10RO107yERPqynW8die0ibyEb0PJ5g4I5ehTwXCv2qWCVijTXCdCX8dd5TG5BXDzWCg8yBoMpYHLamFecYagUPX8ecibgeQUq6aQxPGbbLHnKOxirIwoPtAN11wUqpmPwyKdlbeQ0Zcg8ydJAWe4eDq7fxOhgRHe8K1ibiwiazqGC4k1KLovR6sj9xUSMik84ihwci6aP4MijMRxBiVfm3lKrWCsbevDX8TG5hWrWCgeCtpHacMdbyUxiyodcUOPJBAmpHasGbHQlKoG6vkKdniDzIBi42oRRB0An4jcziXk6GCavB5YwyqWfn9WveTOPucI0amjiaBRKR(4MgZtiGeyqO6cPdOELc7AAEwwIe62C0MHmtjr3geItwl1oRRm4Xgg1GjWjRiDHoVqpyxtZZYsKq3MJ41omesWtwJeGa30yEcbKadcvxiDa1RuGsKy6Ybb3e30yEcbKqnvkzwhRH0MHmtjr3geItwl1oRRLTjTTsc1uPKzT0IrQJqkSTswCHEySgsq7av5PMkLrhRAYqsIlapEGQ8utLYGBAmpHasOMkLmuVsXynK2zDTSnPTvsOMkLmR6IBAmpHasOMkLmuVsHcfytmbeTCmpHG2zDTSnPTvsOMkLmR0g30yEcbKqnvkzOELcc9utAN11Y2K2wjHAQuYSQhCtJ5jeqc1uPKH6vkifJCXnXnnMNqajutqskKzLyLnesCG20oRRB0AnqSYgcjoqBcxiDWYLB0AnqSYgcjoqBcJCyjGOJwyWJnmQbtGtOfkN6s6tlukqBCtKeZ1RTgcMtqhbZDiMtzLbI5EHG5LTjTTsWCceZjWdbZHQlMx2uOcMFHGwBhZfWfZr1WCvcqitcqGBAmpHasOMGKuid1Ruu2M02kPnWoK1Tq84KATlBkuzLsTZ6QBkb4bTjpmvK(yErqa2wjxCtKeZnMNqajutqskKH6vkyiZujarSSnPTvsBGDiRBH4Xj1Ad1wpSw1USPqL17GM3WKAbpznirewcKBecIJuhHu0oRRUPeGh0M8Wur6J5fbbyBLCXnnMNqajutqskKH6vk0M8Wur6J5fTZ6krtuQOBdcXjbTjpmvK(yEbv6IBAmpHasOMGKuid1RumPwBgYmLeDBqioPDwxhPocPW2kzXDqZBysTGNSgKiclbYncbXrQJqkOQSnPTvsysTONSgKfT0YgTwdEIqgsSIoihq1wUKbHQlKoi4jcziXk6GCyKdlbeQqQ(lAzJwRHTccVUPGasavB5sD6MsaEyRGWRBkiGeeGTvYv)fxOhMulODGQ8utLYOJvnzijXfGhpqvEQPszwUuNUPeGhi2wghc9IGaSTsU6JBAmpHasOMGKuid1RuuLbYsikjUtxAFyTkkazqG8AP2mKzkj62GqCYAjCtCtJ5jeqcq6k6IvwwjUne0bH0oRRB0Anui24ryn6fsKEQUbunCtJ5jeqcq6k6IvwOELcckOMJ0oRR6uBKYreSBOuGGcQ5il0P2iLJiy3GUbckOMJGBAmpHasasxrxSYc1Ruui24ryn6fsKEQUTZ6QaKbbY6qpuArlxOhMulmYHLacv6jG0LlzWJnmQbtGt0bs1FbdcvxiDqWteYqIv0b5WihwciuTs5bKUyJwRbMsSHzepbice3yn0rPf6CJwRbttAvuBKR5WHezJvobicOAl05gTwdBfeEvOepGQTOLnATg2KycyHroSeqOcPlxQZnATg2Kycybun9x0IozqO6cPdcmiOmSHe9cjs0YjDsavB5sDYGLfGb8airu4XQj6JBAmpHasasxrxSYc1RuCaHGgjiwHZr7SUkazqGSo0dLw0Yf6Hj1cJCyjGqLEciD5sg8ydJAWe4eDGu9xWGq1fshe8eHmKyfDqomYHLacvRuEaPl2O1AGPeBygXtaIaXnwdDuAHo3O1AW0Kwf1g5AoCir2yLtaIaQ2cDUrR1WwbHxfkXdOAlAzJwRHnjMawyKdlbeQq6YL6CJwRHnjMawavt)fTOtgeQUq6GadckdBirVqIeTCsNeq1wUuNmyzbyapasefESAI(4M4MgZtiGeiUykVyvdcvXriq0HjTRWjcKw5RLWnnMNqajqCXuEb1RumwdPndzMsIUnieNSwQDwxB5c9WynKG2bQYtnvkJokfq6YLJuhHuyBLO)I7GM3WynKGNSgKiclbYncbXrQJqkOsxCtJ5jeqcexmLxq9kfAqOkocbIomPDforG0kFTeUPX8ecibIlMYlOELcVymsrKzEBgYmLeDBqiozTu7SUosDesHTvYI7GM3GxmgPiYmp4jRbjIWsGCJqqCK6iKcQkBtABLe8IXifrpzniliAIsfDBqioj4fJrkImZPI24MijMtZG6McZ7kJuG5jbZ3I7YG5EHbWCIlMYlW8EXixm3CmN2yUBdcXj4MgZtiGeiUykVG6vk2dQBQirzKI2zDLOjkv0TbH4KWEqDtfjkJuqLU4MgZtiGeiUykVG6vk0GqvCeceDys7kCIaPv(AjCtKeZ7fJCX8kCW8QrCzW8wJEdMJqaYyEcbTX8KG53deyUcsiyEfoyorlbaKXCGWgiMVrt1LGBAmpHasG4IP8cQxPGumYf3e30yEcbKW2ugGjReuqnhPDwx3O1AqyQuJircuzt4cPdwSrR1GWuPgrIkuGnHlKoyrlJuhHuyBLSCzlgZZYsuaYrkeQkTWyEwwIxOhiOGAoIomMNLLOaKJui6RpUPX8eciHTPmatOELcIBdbDqiTZ66gTwdctLAejsGkBcJCyjGqfZiE0Zdz5YnATgeMk1isuHcSjmYHLacvmJ4rppeCtJ5jeqcBtzaMq9kfe3MAos7SUUrR1GWuPgrIkuGnHroSeqOIzep65HSCjbQSjkmvQreQOeUPX8eciHTPmatOELc6J5fTZ66gTwdctLAejsGkBcJCyjGqfZiE0Zdz5sfkWMOWuPgrOIsV)()]] )


end
