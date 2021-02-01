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

        if active_dot[ t.key ] > 0 then
            -- If our current target isn't debuffed, let's assume that other targets have 1 tick remaining.
            if remains == 0 then remains = tick_time end
            remaining_ticks = ( pmult and t.pmultiplier or 1 ) * min( remains, ttd ) / tick_time
            duration = max( 0, min( remains + duration, 1.3 * class.auras[ aura ].duration, ttd ) )
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


    spec:RegisterPack( "Feral", 20210131, [[dWuYqbqicKEKurDjbrAtGKpjvqJIuPtrQYQaP4vekZsQ0TKkKDjLFrqggHkhtqTmbPNbs10iOCncuBJaX3eeyCcI4CccADcIAEeQ6EGY(ivCqbHyHKQ6HsfyIeuHncsj(ibvjJKGQuNeKsALkfZeKsDtcQIDcQ8tbHAOeurlLGQ6PQyQGQ(QGqASsfk7fP)k0Gv1HPAXq5XKmzv6YO2Ss(Ss1Of40IwTuHkVgeMnr3wQA3q(nWWjLJlvOQLR45iMoLRdvBhe9Dcz8sf58kLwpbvA(eW(LmnmfE656gtHluXfAyXfg6HBHgo0qdhcOhBRgtpAUccFNPhK3Z0d0cpUKE08TsGFPWtpea(Oy6jWmnsilKq7PfGJ1uGEHizpU0TeGuJVmHizVsi6bdpLg0kIIrpx3ykCHkUqdlUWqpCluXfAiiubHECClam0Zj77a6jiVxgrXONltu0tN7C9ql84Y6fog88wB6CNRFJJW9zB9qpC36dvCHgU2uB6CNRhAHhxwFiIWj0UELJQ3Leq9yC9lao6wVB1hyMgjKfsO9KyT90cWXAkqVqDmhjC9XfsqcjHqbrfscHHqbzjyFPybR4WHf81DO7IlKC91Q205oxFhe4ODU(7GN3gqKue7qYrLBWcxVkGvqqQ3a1Fh882aIKIyhsoQCRrpYKyek80dMeaUMlbicfEkCHPWtpmYXK8LQp9OM04jD6r36f06TubrI2RxabQx36hEnmjWXKC9qvVgpKKymYI94sl1Kjp1Rt9xG1ghcUP1JlTutM8uVE1lGa1RB9UYsi5iMfTj335HupS6dTEOQxJhssmgzXECPLAYKN61P(lWAJdb306XLwQjtEQxV6fqG61TExzjKCeZI2K778qQhw9Hwpu1p8AysGJj561RE9QhQ6XWxRgMfhhcUDbIq1dv93bpVTXHGBwQGGe39eX3iafhEnmjOEDGvFO0JRSeGONXHGPh1wLKJMp7SrOWfMAu4cLcp9WihtYxQ(0JAsJN0PNHxdtcCmjxpu1JHVwnml2daOvoC7ceHOhxzjarp9aaALdhvUrpQTkjhnF2zJqHlm1OWbDk80dJCmjFP6tpQjnEsNEgEnmjWXKC9qvpg(A1WSOfmojODbIq1dv93bpVnlyCsqu5wZsfeK4UNi(gbO4WRHjb1Rt96wVWQxS6jASugnF2zJ0SGXjbrLB1dn1lS61REHQx36dxVy137eJNTriDjoxVE13r1RaOlEAnZjghxGjIjbGBJroMKV0JRSeGOhlyCsqu5g9O2QKC08zNncfUWuJcNWOWtpmYXK8LQp9OM04jD6bdFTAyweBWnxgjsNe0Uari6Xvwcq0d2GBUmsKojGAu4emfE6HroMKVu9Ph1KgpPtpy4RvdZIerPg3UarO6HQEIglLrZND2inIOuJJk3QxN6dtpUYsaIEiIsnoQCJAu4eek80dJCmjFP6tpQjnEsNEWWxRgMfjbdFBxGie94klbi6Hem8LAu4cbu4Phg5ys(s1NEutA8Ko9GHVwnmlseLAC7ceHOhxzjarperPghvUrnkCHek80dJCmjFP6tpQjnEsNEWWxRgMfTGXjbTlqeIECLLae9ybJtcIk3Og1ONvIssapu4PWfMcp9WihtYxQ(0JAsJN0Phm81QrCi9DooaFAd37jIuV4Rh60JRSeGOhIdPVZXb4d1OWfkfE6HroMKVu9Ph1KgpPtp6w)DWZBtBYExgfnUf0SubbjU7jIVrako8Aysq96up0RhAQx36jASugnF2zJ00MS3LrrJBb1lw9HRxV6HQEIglLrZND2inTj7Dzu04wq96uF461REbeOEIglLrZND2inTj7Dzu04wq96uVU1d96fR(W1dn1BUKrwJ4y8yaGf0yKJj5B96rpUYsaIE0MS3LrrJBbuJch0PWtpmYXK8LQp9OM04jD6z41WKahtY1dv93bpVTj1AwQGGe39eX3iafhEnmjOEDQhsFshtYTj1IwQGGupu1RB96wpg(A1SCNhsCHpBB4A1lGa1Raa5fic1SCNhsCHpBBd37jIuVo1l461REOQx36XWxRgMeaUMlbisdxREbeOEbTEZLmYAysa4AUeGing5ys(wVE1dv9xG1MuRP1JlTutM8uV4HvVgpKKymYI94sl1Kjp1lGa1lO1BUKrwJ4y8yaGf0yKJj5B96rpUYsaIEMuJEuBvsoA(SZgHcxyQrHtyu4Phg5ys(s1NEutA8Ko9GHVwnIdPVZXb4tB4EprK6fF96wVc0JbIAGezK6fR(W1Rx9qt9cs9qt9IRbD6Xvwcq0dXH0354a8HAu4emfE6HroMKVu9PNEVtrgXZ(wkCHPhxzjarplEaQeGtIyPX0JARsYrZND2iu4ctnkCccfE6HroMKVu9Ph1KgpPtpy4RvdJetKQHRvpu1BUKrwJaWLrWkAbCCbgMyng5ys(spUYsaIEw8aujaNeXsJPh1wLKJMp7SrOWfMAuJEWCPJumfEkCHPWtpmYXK8LQp9OM04jD6bdFTASsMAeosasFAxGiu9qvpg(A1yLm1iCuIJ8PDbIq1dv96w)WRHjboMKRxabQx36DLLqYrgX9jtQxN6dxpu17klHKJxG1i4OvoC9IVExzjKCKrCFYK61RE9OhxzjarpeC0khMAu4cLcp9WihtYxQ(0JAsJN0Phm81QXkzQr4ibi9PnCVNis96uVYjw0YEUEbeOEm81QXkzQr4Oeh5tB4EprK61PELtSOL9m94klbi6Hy(qWNDMAu4GofE6HroMKVu9Ph1KgpPtpy4RvJvYuJWrjoYN2W9EIi1Rt9kNyrl756fqG6jaPprwjtncxVo1lo6Xvwcq0dX8zLdtnkCcJcp9WihtYxQ(0JAsJN0Phm81QXkzQr4ibi9PnCVNis96uVYjw0YEUEbeOEjoYNiRKPgHRxN6fh94klbi6r04wa1Og9C5LJlnk8u4ctHNEyKJj5lvF6Xvwcq0ZGJIUYsakktIrpQjnEsNEWWxRwpaGGirXfy6B4A1dv9cA93bpVnGiPi2HKJk3OhzsSiY7z6bZLosXuJcxOu4Phg5ys(s1NEUmrnPMLae9i8gyHO13baeKaiy6Xvwcq0JYLYORSeGIYKy0JAsJN0PN7GN3gqKue7qYrLB0Jmjwe59m9aejfXoKm1OWbDk80dJCmjFP6tpxMOMuZsaIEeohGiz9Icyedjp1RbiKetY0JRSeGOhTbissnkCcJcp9WihtYxQ(0JAsJN0Phm81QPClUatF7ceHOhxzjarpwUZdjUWNTuJcNGPWtpmYXK8LQp9OM04jD6bdFTAk3IlW03Uari6Xvwcq0JYT4cm9uJcNGqHNEyKJj5lvF65Ye1KAwcq0tigX1tcaw9eJDPfqpUYsaIEgCu0vwcqrzsm6rnPXt60dg(A1ib(fiQNL3gUw9ciq9y4RvtBaIKnCn6rMelI8EMEig7slGAu4cbu4PhxzjarpeiWLYiMtcOhg5ys(s1NAu4cju4Phg5ys(s1NECLLae9OCPm6klbOOmjg9itIfrEptpkaqEbIquJcxiKcp9WihtYxQ(0JAsJN0PN7GN3M2K9UmkAClOzPccsC3teFJauC41WKG61bw9HkU6HQEfOhde1ajYi1RdS6dLECLLae9OnzVlJIg3cOgfUWIJcp9WihtYxQ(0JRSeGONbhfDLLauuMeJEutA8Ko9Oa9yGOgirgPEDGvVU1l467O6H0N0XKCBbWhLwelnUE9OhzsSiY7z6zLOKeWd1OWfomfE6HroMKVu9PNltutQzjarpcp4sl7OD1TEIXU0cOhxzjarpkxkJUYsakktIrpQjnEsNEWWxRggjMivdxREbeOEm81QrWVxgf9EmCsqdxJEKjXIiVNPhIXU0cOgfUWHsHNEyKJj5lvF6rnPXt60J5sgznmjaCnxcqKgJCmjFRhQ6XWxRgMeaUMlbis7ceHQhQ61TEgXZ(26fREO3eC9qt9mIN9TTH3zu9IvVU1lmXvp0upg(A1us2hLtSeT3W1QxV61REXxVU1hoSGRVJQpuOxp0upg(A1sKYhKBjafHir7rWkAbCSJdhTl5gUw96vpu17klHKJyw0MCFNhs9WQxC0JRSeGOhnaqghMaWhftpxMOMuZsaIEGpGRVhqS65oPXiscjxV(WxVARsY1Rl8bdtcQ)em8T(JOuJRxbiw9Hdl46zep7B7wFVdbxpbF46fX1RCu99oeC9wGB1NO6fw97saMlj6rnkCHHofE6HroMKVu9Phxzjarpdok6klbOOmjg9OM04jD6XCjJSgMeaUMlbisJroMKV1dv9y4RvdtcaxZLaePDbIq0Jmjwe59m9GjbGR5saIqnkCHfgfE6HroMKVu9Ph1KgpPtpy4RvZ14of1g(6gyir14qMO9gUg94klbi6zXdqLaCselnMEuBvsoA(SZgHcxyQrHlSGPWtpmYXK8LQp9SateXDYOWfMECLLae9ObaY4Wea(Oy65Ye1KAwcq0d8GliKR3yIvVfKK6fLwq99GHR3VqYdHRNWgUgPEDL8oJU(KmPB97SpDR3CjJmIE1BG67Di46j4dxVf4w9wqsQNy(ws9E9xns9jsnStyQrHlSGqHNEyKJj5lvF6rnPXt60JU1p8AysGJj56fqG614HKeJrwShxAPMm5PEDQ)cS24qWnTECPLAYKN61REOQ)o45TnoeCZsfeK4UNi(gbO4WRHjb1Rt9enwkJMp7SrAerPghvUvp0uFO13r1hk94klbi6zCiy6rTvj5O5ZoBekCHPgfUWHak80dJCmjFP6tpQjnEsNEgEnmjWXKC9qv)DWZBRhaqRC4OYTMLkiiXDpr8ncqXHxdtcQxN6jASugnF2zJ0iIsnoQCREOP(qRVJQpu6Xvwcq0tpaGw5WrLB0JARsYrZND2iu4ctnkCHdju4Phg5ys(s1NEwGjI4ozu4ctpUYsaIE0aazCycaFum1OWfoesHNEyKJj5lvF6rnPXt60ZWRHjboMKRhQ6VdEEBwW4KGOYTMLkiiXDpr8ncqXHxdtcQxN61TEHvVy1t0yPmA(SZgPzbJtcIk3QhAQxy1Rx9cvVU1hUEXQV3jgpBJq6sCUE9QVJQxbqx80AMtmoUatetca3gJCmjFPhxzjarpwW4KGOYn6rTvj5O5ZoBekCHPgfUqfhfE6HroMKVu9PNfyIiUtgfUW0JRSeGOhnaqghMaWhftnkCHgMcp9WihtYxQ(0JAsJN0PhDRF88gzizK187L0su96uVU1hUEXQV37uuf4ZotQVJQxf4ZotIRXvwcqUSE9QhAQFyvGp7C0YEUE9QhQ61TEIglLrZND2inSb3CzKiDsq9qt9UYsaQHn4MlJePtcAxV3356fQExzja1WgCZLrI0jbnfGy1Rx96uVU17klbOgjy4B769(oxVq17klbOgjy4Btbiw96rpUYsaIEWgCZLrI0jbuJcxOHsHNEyKJj5lvF6rnPXt60drJLYO5ZoBKgruQXrLB1Rt9HRxS6XWxRggjMivdxREOP(qPhxzjarperPghvUrnkCHcDk80dJCmjFP6tpQjnEsNEiASugnF2zJ0SGXjbrLB1Rt9qNECLLae9ybJtcIk3OgfUqfgfE6HroMKVu9Ph1KgpPtpy4RvtjzFuoXs0EdxJECLLae9qcg(snkCHkyk80dJCmjFP6tpQjnEsNEWWxRggjMivdxREOQ)o45TnoeCZsfeK4UNi(gbO4WRHjb1Rt9HspUYsaIEghcMEuBvsoA(SZgHcxyQrHlubHcp9WihtYxQ(0JRSeGOhLlLrxzjafLjXOhzsSiY7z6zLsjpuJA0J2WkqpMBu4PWfMcp9WihtYxQ(0dqJEiSrpUYsaIEG0N0XKm9aPlXz6rC0dK(erEptpla(O0IyPXuJcxOu4Phg5ys(s1NEaA0dHn6Xvwcq0dK(KoMKPhiDjotpIJEG0NiY7z6zLsjp0ZLjQj1SeGONtWW36HvV46wpCauhrqUgjay1l8Di46HvF4U1FqUgjay1l8Di46HvFODRhAdTwpS6HE36pIsnUEy1lmQrHd6u4Phg5ys(s1NEaA0dHn6Xvwcq0dK(KoMKPhiDjotpHa6bsFIiVNPNj1IwQGGqpxMOMuZsaIEokxY1lkTG6dCIXnQrHtyu4PhxzjarpqKO7W3irlN0i0dJCmjFP6tnkCcMcp94klbi6bdyMKVXL03YxrjApAGoLi6HroMKVu9PgfobHcp9WihtYxQ(0JAsJN0Phm81Q1daiisuCbM(2ficrpUYsaIE0gGij1OWfcOWtpmYXK8LQp9OM04jD6bdFTA9aacIefxGPVDbIq0JRSeGOhLBXfy6Pg1ONvkL8qHNcxyk80dJCmjFP6tpQjnEsNEG0N0XKCBLsjp1dR(W1dv9dVgMe4ysUEOQ)cS24qWnTECPLAYKN6fpS614HKeJrwShxAPMm5HECLLae9moem9O2QKC08zNncfUWuJcxOu4Phg5ys(s1NEutA8Ko9aPpPJj52kLsEQhw9HspUYsaIEghcMAu4GofE6HroMKVu9Ph1KgpPtpq6t6ysUTsPKN6Hvp0Phxzjarp9aaALdhvUrnkCcJcp9WihtYxQ(0JAsJN0Phi9jDmj3wPuYt9WQxy0JRSeGOhIOuJJk3OgfobtHNECLLae9qcg(spmYXK8LQp1Og9qm2LwafEkCHPWtpmYXK8LQp9SateXDYOWfMECLLae9ObaY4Wea(OyQrHluk80dJCmjFP6tpUYsaIEghcMEuBvsoA(SZgHcxy65Ye1KAwcq0JW3HGRhX8Lu)aW3dKBRxWIlKwpyvFAK6LmA3cQ3T6967tu2J3xVbQNGpAoHupjy4lP(RgtpQjnEsNE0T(lWAJdb306XLwQjtEQx81hUj46fqG6hEnmjWXKC96vpu1Fh882ghcUzPccsC3teFJauC41WKG61P(qRxabQhdFTAyKyIuTH79erQx81hMAu4GofE6HroMKVu9Ph1KgpPtpenwkJMp7SrAydU5Yir6KG61P(qPhxzjarpydU5Yir6Ka65Ye1KAwcq0J(dU5Y6psNeuFsQhJnJN6TahvpXyxAb1Fcg(wVB1d96nF2zJqnkCcJcp9WihtYxQ(0Zcmre3jJcxy6Xvwcq0JgaiJdta4JIPgfobtHNEyKJj5lvF6rnPXt60Jc0JbIAGezK6fF9cREOQNOXsz08zNnsZcgNeevUvV4RxW0JRSeGOhsWWx65Ye1KAwcq0Zjy4B9lWu)Yjgp13bcN1VZiEClbOU1BbjPEzI46ts9bSdzk3wV5sgzcTZ(iKcajJCKv)L1y0Lrw36jAjcTTEZLmYi1dM6v5OKC9sENrxF22TEWupIvdqcMlPETHx8upcy1BG6d85wpjy4B9UuwVfW1BzptnQrpkaqEbIqu4PWfMcp9WihtYxQ(0JAsJN0PhfOhde1ajYi1l(6HE9qvV5ZoBnl75ObI3KRxN6db0JRSeGONfpUmUggjC3spQTkjhnF2zJqHlm1OWfkfE6HroMKVu9Ph1KgpPtpkqpgiQbsKrQxhy1dD6Xvwcq0dgpeEGGEUmrnPMLae9aFiw4iehY1dhZ36nq9KTiv9IslOErPfu)4qYiaoP(1WiH726ffWO6fX1p4O6xdJeUBXC0TB9GPE3KStS6vbScI6Zv9PrQxeySG6tJAu4GofE6HroMKVu9Ph1KgpPtpkqpgiQbsKrQxhy1dD6Xvwcq0tIu(GClbiQrHtyu4Phg5ys(s1NEutA8Ko9WiE232U8kvPvVo1lmXvVacupg(A1WiXePA4A1lGa1RB9MlzK10g(6gyAmYXK8TEOQNeagJjw0SB9IVEOxVE0JRSeGOhl35Hex4Zw65Ye1KAwcq0d8Z26D0TEeWQxKtmUE4HwQNr8SVTB9y4w9UKaQVJdNy1Jt46tR(fyQx4Yde17OB9js5dIqnkCcMcp9WihtYxQ(0JAsJN0Phm81Qz5opK4cF22W1QhQ6XWxRggjMiv7ceHQhQ6vGEmqudKiJuV4Rxy1dv9xG1ghcUP1JlTutM8uV4RpCtqQhQ6zep7BRxN6fM4OhxzjarpKa)ce1ZYl9CzIAsnlbi6r4j3dS6X46fna0E9gOECcx)PNL36bO6f(oeC9jQEi5zB9qYZ26rPkGRNKgUBjar6wpgUvpK8ST(XhwULAu4eek80dJCmjFP6tpQjnEsNEWWxRML78qIl8zBdxREbeOEm81QHrIjs1W1Ohxzjarpy8q4bIeTtnkCHak80dJCmjFP6tpQjnEsNEWWxRggjMivdxJECLLae9ObSeGOgfUqcfE6HroMKVu9Ph1KgpPtpy4RvdJetKQHRvVacu)k3dS4W9EIi1l(6dnm94klbi6zCizeaNexdJeUBPgfUqifE6HroMKVu9Ph1KgpPtp6w)fyTj1Ad37jIuVo1lS6HQEfOhde1ajYi1l(6HE9qv)fyTXHGBwQGir71dv9mIN9TTlVsvA1RdS6dvC1Rx9ciq9RCpWId37jIuV4RxW0JRSeGOhfabjacoAbCKOLtAe65Ye1KAwcq0d8HyHJqCixFheWkiQVhaqqKO6daMO6D0TEIHVw1lti46TGK0TEhDRV33IX1JXMXt9kqpMB1pCVNO6hMSfPOgfUWIJcp9WihtYxQ(0JAsJN0Phm81Qz5opK4cF22W1QxabQx36va0fpT2LzTOlL8E6if3yKJj5B96rpUYsaIE4EnGiEIya0LEUmrnPMLae9i84BX46TaE46jbaC5TEmU(EWW1RaOBAjarQhGQ3c46va0fpnQrHlCyk80dJCmjFP6tpQjnEsNEuGEmqudKiJupS6fC9qvVGw)fyn)6AwcjhjI8PpE9EFNBwQGir70JRSeGOh)6AwcjhjI8PNEuBvsoA(SZgHcxyQrHlCOu4Phxzjarp4eoMg3tOhg5ys(s1NAuJEaIKIyhsMcpfUWu4Phg5ys(s1NEutA8Ko9GHVwTa2hlcwrlGJIs5THRrpUYsaIEiMpe8zNPgfUqPWtpmYXK8LQp94klbi6HGJw5W0JmrCuDPhHbn7Ql1OWbDk80dJCmjFP6tpQjnEsNEWWxRwpaGGirXfy6B4A1dv96w)GJ4fy25MYnElhv4tcAmYXK8TEbeO(bhXlWSZT7447bweSIxM1IlGcN0yKJj5B96vpu1t0yPmA(SZgPzbJtcIk3Qx81hk94klbi6PhaqRCy6rMioQU0JWGMD1LAu4egfE6HroMKVu9Ph1KgpPtpmIN9T1l(6HU4QhQ6VaRnPwB4EprK61PEH1eC9qvVU1Raa5fic1SCNhsCHpBBd37jIuVoWQxqAcUEbeO(bhXlWSZnLB8woQWNe0yKJj5B96vpu1JHVwnLK9r5elr7nI5kiQx81hUEOQxqRhdFTAUg3PO2Wx3adjQghYeT3W1QhQ6f06XWxRgMeaUsCI1W1QhQ6f06XWxRggjMivdxREOQx36vaG8ceHAkacsaeC0c4irlN0iTH79erQxN6fKMGRxabQxqRxbGKroYAOCpWIlNRxp6Xvwcq0ta7JfbROfWrrP8snkCcMcp9WihtYxQ(0JAsJN0PhgXZ(26fF9qxC1dv9xG1MuRnCVNis96uVWAcUEOQx36vaG8ceHAwUZdjUWNTTH79erQxhy1linbxVacu)GJ4fy25MYnElhv4tcAmYXK8TE9QhQ6XWxRMsY(OCILO9gXCfe1l(6dxpu1lO1JHVwnxJ7uuB4RBGHevJdzI2B4A1dv9cA9y4RvdtcaxjoXA4A1dv9cA9y4RvdJetKQHRvpu1RB9kaqEbIqnfabjacoAbCKOLtAK2W9EIi1Rt9cstW1lGa1lO1RaqYihznuUhyXLZ1Rh94klbi6PhaqqKO4cm9uJAuJEGKhscqu4cvCHgwCHdvy0JiFqjANqpHOHicF4GwHt4vixF9WhW1N9AGXQFbM67WlVCCP1H1pChpEo8TEcONR3XnqVB8TEvGJ2zsR2aTtexF4qyixFhaqqYJX36pzFhupzlY8ovFiTEdup0g3R)MqMKeGQhOXJBGPEDfsV61nCN0RvBG2jIRp0WHC9DaabjpgFR)K9Dq9KTiZ7u9H06nq9qBCV(BczssaQEGgpUbM61vi9Qx3q7KETAtTjener4dh0kCcVc56Rh(aU(Sxdmw9lWuFhIjbGR5saI0H1pChpEo8TEcONR3XnqVB8TEvGJ2zsR2aTtexp0d567aacsEm(w)j77G6jBrM3P6dP1BG6H24E93eYKKau9anECdm1RRq6vVUH7KETAtTjener4dh0kCcVc56Rh(aU(Sxdmw9lWuFhcejfXoKChw)WD845W36jGEUEh3a9UX36vboANjTAd0orC9qpKRVdaii5X4B9D4GJ4fy25whRdR3a13HdoIxGzNBDSgJCmjF7W61n0oPxR2aTtexVWc567aacsEm(wFho4iEbMDU1X6W6nq9D4GJ4fy25whRXihtY3oSEDd3j9A1gODI46fCixFhaqqYJX367WbhXlWSZTowhwVbQVdhCeVaZo36yng5ys(2H1RB4oPxR2uBGw71aJX36dH17klbO6LjXiTAd9q0yffUWId60J2awPKPNo356Hw4XL1lCm45T205ox)ghH7Z26HE4U1hQ4cnCTP205oxp0cpUS(qeHtOD9khvVljG6X46xaC0TE3QpWmnsilKq7jXA7PfGJ1uGEH6yos46JlKGescHcIkKecdHcYsW(sXcwXHdl4R7q3fxi56RvTPZDU(oiWr7C93bpVnGiPi2HKJk3GfUEvaRGGuVbQ)o45TbejfXoKCu5wR2uBCLLaePPnSc0J5MyWecsFshtYDrEpdBbWhLwelnUlKUeNHjUAtNR)em8TEy1lUU1dha1reKRrcaw9cFhcUEy1hUB9hKRrcaw9cFhcUEy1hA36H2qR1dREO3T(JOuJRhw9cR24klbistByfOhZnXGjeK(KoMK7I8Eg2kLsE6cPlXzyIR2056pkxY1lkTG6dCIXTAJRSeGinTHvGEm3edMqq6t6ysUlY7zytQfTubbPlKUeNHfcQnUYsaI00gwb6XCtmycbrIUdFJeTCsJuBCLLaePPnSc0J5MyWecdyMKVXL03YxrjApAGoLOAJRSeGinTHvGEm3edMqAdqKSBUGHHVwTEaabrIIlW03UarOAJRSeGinTHvGEm3edMqk3IlW03nxWWWxRwpaGGirXfy6BxGiuTP24klbicSbhfDLLauuMeRlY7zyyU0rkUBUGHHVwTEaabrIIlW03W1GsqVdEEBarsrSdjhvUvB6C9cVbwiA9DaabjacU24klbiIyWes5sz0vwcqrzsSUiVNHbejfXoKC3Cb7o45TbejfXoKCu5wTPZ1lCoarY6ffWigsEQxdqijMKRnUYsaIigmH0gGizTXvwcqeXGjKL78qIl8zB3CbddFTAk3IlW03UarOAJRSeGiIbtiLBXfy67Mlyy4Rvt5wCbM(2ficvB6C9Hyexpjay1tm2LwqTXvwcqeXGj0GJIUYsakktI1f59mmIXU0c6Mlyy4RvJe4xGOEwEB4Aciag(A10gGizdxR24klbiIyWeIabUugXCsqTXvwcqeXGjKYLYORSeGIYKyDrEpdtbaYlqeQ24klbiIyWesBYExgfnUf0nxWUdEEBAt27YOOXTGMLkiiXDpr8ncqXHxdtc0bwOIdkfOhde1ajYi6al0AJRSeGiIbtObhfDLLauuMeRlY7zyReLKaE6MlykqpgiQbsKr0bMUcUJG0N0XKCBbWhLwelnwVAtNRx4bxAzhTRU1tm2LwqTXvwcqeXGjKYLYORSeGIYKyDrEpdJySlTGU5cgg(A1WiXePA4Aciag(A1i43lJIEpgojOHRvB6C9WhW13diw9CN0yejHKRxF4RxTvj561f(GHjb1Fcg(w)ruQX1RaeR(WHfC9mIN9TDRV3HGRNGpC9I46voQ(EhcUElWT6tu9cR(DjaZLe9QnUYsaIigmH0aazCycaFuC3CbZCjJSgMeaUMlbisJroMKVqHHVwnmjaCnxcqK2ficbLUmIN9TIb9MGHggXZ(22W7msmDfM4Ggm81QPKSpkNyjAVHRPNEIx3WHfChfk0Hgm81QLiLpi3sakcrI2JGv0c4yhhoAxYnCn9GYvwcjhXSOn5(opeyIR24klbiIyWeAWrrxzjafLjX6I8EggMeaUMlbis3CbZCjJSgMeaUMlbisJroMKVqHHVwnmjaCnxcqK2ficvBCLLaermycT4bOsaojILg3vTvj5O5ZoBeyH7Mlyy4RvZ14of1g(6gyir14qMO9gUwTPZ1dp4cc56nMy1BbjPErPfuFpy469lK8q46jSHRrQxxjVZORpjt6w)o7t36nxYiJOx9gO(EhcUEc(W1BbUvVfKK6jMVLuVx)vJuFIud7eU24klbiIyWesdaKXHja8rXDxGjI4ozWcxBCLLaermycnoeCx1wLKJMp7SrGfUBUGP7WRHjboMKfqanEijXyKf7XLwQjtE05cS24qWnTECPLAYKh9G6o45TnoeCZsfeK4UNi(gbO4WRHjb6q0yPmA(SZgPreLACu5g0eAhfATXvwcqeXGjupaGw5WrLBDvBvsoA(SZgbw4U5c2WRHjboMKH6o45T1daOvoCu5wZsfeK4UNi(gbO4WRHjb6q0yPmA(SZgPreLACu5g0eAhfATXvwcqeXGjKgaiJdta4JI7UateXDYGfU24klbiIyWeYcgNeevU1vTvj5O5ZoBeyH7MlydVgMe4ysgQ7GN3MfmojiQCRzPccsC3teFJauC41WKaD0vyIr0yPmA(SZgPzbJtcIk3GgHPxiv3WI17eJNTriDjoRxhPaOlEAnZjghxGjIjbGBJroMKV1gxzjaredMqAaGmombGpkU7cmre3jdw4AJRSeGiIbtiSb3CzKiDsq3Cbt3XZBKHKrwZVxslr6OByX69ofvb(SZKosf4ZotIRXvwcqUupOzyvGp7C0YEwpO0LOXsz08zNnsdBWnxgjsNeanUYsaQHn4MlJePtcAxV335qQRSeGAydU5Yir6KGMcqm90rxxzja1ibdFBxV335qQRSeGAKGHVnfGy6vBCLLaermycreLACu5w3CbJOXsz08zNnsJik14OYnDclgg(A1WiXePA4AqtO1gxzjaredMqwW4KGOYTU5cgrJLYO5ZoBKMfmojiQCthOxBCLLaermycrcg(2nxWWWxRMsY(OCILO9gUwTXvwcqeXGj04qWDvBvsoA(SZgbw4U5cgg(A1WiXePA4AqDh882ghcUzPccsC3teFJauC41WKaDcT24klbiIyWes5sz0vwcqrzsSUiVNHTsPKNAtTXvwcqKgMeaUMlbicSXHG7Q2QKC08zNncSWDZfmDfulvqKODbeq3HxdtcCmjdLgpKKymYI94sl1Kjp6CbwBCi4MwpU0snzYJEciGUUYsi5iMfTj335HaluO04HKeJrwShxAPMm5rNlWAJdb306XLwQjtE0tab01vwcjhXSOn5(opeyHc1WRHjboMK1tpOWWxRgMfhhcUDbIqqDh882ghcUzPccsC3teFJauC41WKaDGfATXvwcqKgMeaUMlbiIyWesIJ8jMiIwoULaux1wLKJMp7SrGfUBUGn8AysGJjzOWWxRgMf7ba0khUDbIq1gxzjarAysa4AUeGiIbtilyCsqu5wx1wLKJMp7SrGfUBUGn8AysGJjzOWWxRgMfTGXjbTlqecQ7GN3MfmojiQCRzPccsC3teFJauC41WKaD0vyIr0yPmA(SZgPzbJtcIk3GgHPxiv3WI17eJNTriDjoRxhPaOlEAnZjghxGjIjbGBJroMKV1gxzjarAysa4AUeGiIbtiSb3CzKiDsq3CbddFTAyweBWnxgjsNe0UarOAJRSeGinmjaCnxcqeXGjeruQXrLBDZfmm81QHzrIOuJBxGieuenwkJMp7SrAerPghvUPt4AJRSeGinmjaCnxcqeXGjejy4B3CbddFTAywKem8TDbIq1gxzjarAysa4AUeGiIbtiIOuJJk36Mlyy4RvdZIerPg3UarOAJRSeGinmjaCnxcqeXGjKfmojiQCRBUGHHVwnmlAbJtcAxGiuTP24klbistbaYlqec2IhxgxdJeUB7Q2QKC08zNncSWDZfmfOhde1ajYiIh6qz(SZwZYEoAG4nzDcb1Moxp8HyHJqCixpCmFR3a1t2Iu1lkTG6fLwq9JdjJa4K6xdJeUBRxuaJQxex)GJQFnms4UfZr3U1dM6DtYoXQxfWkiQpx1NgPErGXcQpTAJRSeGinfaiVariXGjegpeEGOBUGPa9yGOgirgrhyqV24klbistbaYlqesmycLiLpi3saQBUGPa9yGOgirgrhyqV2056HF2wVJU1Jaw9ICIX1dp0s9mIN9TDRhd3Q3Leq9DC4eRECcxFA1Vat9cxEGOEhDRprkFqKAJRSeGinfaiVariXGjKL78qIl8zB3CbJr8SVTD5vQsthHjobeadFTAyKyIunCnbeqxZLmYAAdFDdmng5ys(cfjamgtSOzxXdD9QnDUEHNCpWQhJRx0aq71BG6XjC9NEwERhGQx47qW1NO6HKNT1djpBRhLQaUEsA4ULaePB9y4w9qYZ26hFy52AJRSeGinfaiVariXGjejWVar9S82nxWWWxRML78qIl8zBdxdkm81QHrIjs1UariOuGEmqudKiJiEHb1fyTXHGBA94sl1KjpIpCtqGIr8SVvhHjUAJRSeGinfaiVariXGjegpeEGir7DZfmm81Qz5opK4cF22W1eqam81QHrIjs1W1QnUYsaI0uaG8ceHedMqAalbOU5cgg(A1WiXePA4A1gxzjarAkaqEbIqIbtOXHKraCsCnms4UTBUGHHVwnmsmrQgUMacSY9aloCVNiI4dnCTPZ1dFiw4iehY13bbScI67baeejQ(aGjQEhDRNy4Rv9YecUElijDR3r3679TyC9ySz8uVc0J5w9d37jQ(HjBrQAJRSeGinfaiVariXGjKcGGeabhTaos0Yjns3Cbt3lWAtQ1gU3terhHbLc0JbIAGezeXdDOUaRnoeCZsfejAhkgXZ(22LxPknDGfQ40tabw5EGfhU3ter8cU2056fE8TyC9wapC9KaaU8wpgxFpy46va0nTeGi1dq1BbC9ka6INwTXvwcqKMcaKxGiKyWeI71aI4jIbq3U5cgg(A1SCNhsCHpBB4AciGUka6INw7YSw0LsEpDKIBmYXK8vVAJRSeGinfaiVariXGjKFDnlHKJer(03vTvj5O5ZoBeyH7MlykqpgiQbsKrGjyOe0lWA(11Sesose5tF869(o3SubrI2RnUYsaI0uaG8ceHedMq4eoMg3tQn1gxzjarARuk5b24qWDvBvsoA(SZgbw4U5cgK(KoMKBRuk5bwyOgEnmjWXKmuxG1ghcUP1JlTutM8iEyA8qsIXil2JlTutM8uBCLLaePTsPKhXGj04qWDZfmi9jDmj3wPuYdSqRnUYsaI0wPuYJyWesIJ8jMiIwoULau3CbdsFshtYTvkL8ad61gxzjarARuk5rmycreLAC3CbdsFshtYTvkL8aty1gxzjarARuk5rmycrcg(wBQnUYsaI0wjkjb8aJ4q67CCa(0nxWWWxRgXH0354a8PnCVNiI4HETXvwcqK2krjjGhXGjK2K9UmkAClOBUGP7DWZBtBYExgfnUf0SubbjU7jIVrako8AysGoqhA0LOXsz08zNnstBYExgfnUfiwy9GIOXsz08zNnstBYExgfnUfOty9eqaIglLrZND2inTj7Dzu04wGo6cDXcdnMlzK1iogpgaybng5ys(QxTXvwcqK2krjjGhXGj0KADvBvsoA(SZgbw4U5c2WRHjboMKH6o45TnPwZsfeK4UNi(gbO4WRHjb6aPpPJj52KArlvqqGsxDXWxRML78qIl8zBdxtabuaG8ceHAwUZdjUWNTTH79er0rW6bLUy4RvdtcaxZLaePHRjGacQ5sgznmjaCnxcqKgJCmjF1dQlWAtQ106XLwQjtEepmnEijXyKf7XLwQjtEeqab1CjJSgXX4XaalOXihtYx9QnUYsaI0wjkjb8igmHioK(ohhGpDZfmm81QrCi9DooaFAd37jIiEDvGEmqudKiJiwy9GgbbAexd61gxzjarAReLKaEedMqlEaQeGtIyPXD79ofzep7BHfURARsYrZND2iWcxBCLLaePTsusc4rmycT4bOsaojILg3vTvj5O5ZoBeyH7Mlyy4RvdJetKQHRbL5sgzncaxgbROfWXfyyI1yKJj5BTP24klbisdiskIDizyeZhc(SZDZfmm81QfW(yrWkAbCuukVnCTAJRSeGinGiPi2HKfdMqeC0khURmrCuDHjmOzxDRnUYsaI0aIKIyhswmyc1daOvoCxzI4O6ctyqZU62nxWWWxRwpaGGirXfy6B4AqP7GJ4fy25MYnElhv4tceqGbhXlWSZT7447bweSIxM1IlGcNOhuenwkJMp7SrAwW4KGOYnXhATXvwcqKgqKue7qYIbtOa2hlcwrlGJIs5TBUGXiE23kEOloOUaRnPwB4EpreDewtWqPRcaKxGiuZYDEiXf(STnCVNiIoWeKMGfqGbhXlWSZnLB8woQWNeOhuy4RvtjzFuoXs0EJyUccXhgkbfdFTAUg3PO2Wx3adjQghYeT3W1GsqXWxRgMeaUsCI1W1GsqXWxRggjMivdxdkDvaG8ceHAkacsaeC0c4irlN0iTH79er0rqAcwabeufasg5iRHY9alUCwVAJRSeGinGiPi2HKfdMq9aacIefxGPVBUGXiE23kEOloOUaRnPwB4EpreDewtWqPRcaKxGiuZYDEiXf(STnCVNiIoWeKMGfqGbhXlWSZnLB8woQWNeOhuy4RvtjzFuoXs0EJyUccXhgkbfdFTAUg3PO2Wx3adjQghYeT3W1GsqXWxRgMeaUsCI1W1GsqXWxRggjMivdxdkDvaG8ceHAkacsaeC0c4irlN0iTH79er0rqAcwabeufasg5iRHY9alUCwVAtTXvwcqKgXyxAbW0aazCycaFuC3fyIiUtgSW1MoxVW3HGRhX8Lu)aW3dKBRxWIlKwpyvFAK6LmA3cQ3T6967tu2J3xVbQNGpAoHupjy4lP(RgxBCLLaePrm2LwGyWeACi4UQTkjhnF2zJalC3Cbt3lWAJdb306XLwQjtEeF4MGfqGHxdtcCmjRhu3bpVTXHGBwQGGe39eX3iafhEnmjqNqfqam81QHrIjs1gU3ter8HRnDUE9hCZL1FKojO(KupgBgp1BboQEIXU0cQ)em8TE3Qh61B(SZgP24klbisJySlTaXGje2GBUmsKojOBUGr0yPmA(SZgPHn4MlJePtc0j0AJRSeGinIXU0cedMqAaGmombGpkU7cmre3jdw4AtNR)em8T(fyQF5eJN67aHZ63zepULau36TGKuVmrC9jP(a2HmLBR3CjJmH2zFesbGKroYQ)YAm6YiRB9eTeH2wV5sgzK6bt9QCusUEjVZORpB7wpyQhXQbibZLuV2WlEQhbS6nq9b(CRNem8TExkR3c46TSNRnUYsaI0ig7slqmycrcg(2nxWuGEmqudKiJiEHbfrJLYO5ZoBKMfmojiQCt8cU2uBCLLaePH5shPyyeC0khUBUGHHVwnwjtnchjaPpTlqeckm81QXkzQr4Oeh5t7ceHGs3HxdtcCmjlGa66klHKJmI7tMOtyOCLLqYXlWAeC0khw8UYsi5iJ4(Kj6PxTXvwcqKgMlDKIfdMqeZhc(SZDZfmm81QXkzQr4ibi9PnCVNiIokNyrl7zbeadFTASsMAeokXr(0gU3terhLtSOL9CTXvwcqKgMlDKIfdMqeZNvoC3CbddFTASsMAeokXr(0gU3terhLtSOL9SacqasFISsMAewhXvBCLLaePH5shPyXGjKOXTGU5cgg(A1yLm1iCKaK(0gU3terhLtSOL9SaciXr(ezLm1iSoIJAuJsb]] )


end
