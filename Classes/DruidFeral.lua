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
            max_stack = 3,
            meta = {
                stack = function( t ) return t.down and dot.adaptive_swarm_hot.up and max( 0, dot.adaptive_swarm_hot.count - 1 ) or t.count end,
            },
            copy = "adaptive_swarm_damage"
        },
        adaptive_swarm_hot = {
            id = 325748,
            duration = function () return mod_circle_hot( 12 ) end,
            max_stack = 3,
            meta = {
                stack = function( t ) return t.down and dot.adaptive_swarm_dot.up and max( 0, dot.adaptive_swarm_dot.count - 1 ) or t.count end,
            },
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
            id = 33786,
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
            id = 305497,
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
        },
        bt_triggers = {
            alias = { "bt_brutal_slash", "bt_moonfire", "bt_rake", "bt_shred", "bt_swipe", "bt_thrash" },
            aliasMode = "longest",
            aliasType = "buff",
            duration = 4,
        },        
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
        else state:RunHandler( "wild_growth" ) end
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364416, "tier28_4pc", 363498 )
    -- 2-Set - Heart of the Lion - Each combo point spent reduces the cooldown of Incarnation: King of the Jungle / Berserk by 0.5 sec.
    -- 4-Set - Sickle of the Lion - Entering Berserk causes you to strike all nearby enemies, dealing (320.2% of Attack power) Bleed damage over 10 sec. Deals reduced damage beyond 8 targets.


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

            if set_bonus.tier28_2pc > 0 then
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", a * 0.5 )
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
        return buff.bt_triggers.stack
    end )

    --[[ spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end

        local count = 0
        for bt_buff, bt_ability in pairs( bt_auras ) do
            if buff[ bt_buff ].up then
                count = count + 1
            end
        end

        if count > 2 then return true end
    end )

    spec:RegisterStateFunction( "proc_bloodtalons", function()
        for aura in pairs( bt_auras ) do
            removeBuff( aura )
        end

        applyBuff( "bloodtalons", nil, 2 )
        last_bloodtalons = query_time
    end ) ]]

    spec:RegisterStateFunction( "check_bloodtalons", function ()
        if buff.bt_triggers.stack > 2 then
            removeBuff( "bt_triggers" )
            applyBuff( "bloodtalons", nil, 2 )
        end
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
        return debuff.rake.up or debuff.rip.up or debuff.thrash_bear.up or debuff.thrash_cat.up or debuff.feral_frenzy.up or debuff.sickle_of_the_lion.up
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


    -- Tier 28
    -- 2-Set - Heart of the Lion - Each combo point spent reduces the cooldown of Incarnation: King of the Jungle / Berserk by 0.5 sec.
    -- 4-Set - Sickle of the Lion - Entering Berserk causes you to strike all nearby enemies, dealing (700%320.2% of Attack power) Bleed damage over 10 sec. Deals reduced damage beyond 8 targets.
    spec:RegisterAura( "sickle_of_the_lion", {
        id = 363830,
        duration = 10,
        max_stack = 1
    } )


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
                if set_bonus.tier28_4pc > 0 then
                    applyDebuff( "target", "sickle_of_the_lion" )
                    active_dot.sickle_of_the_lion = max( 1, active_enemies )
                end
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
                check_bloodtalons()
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
                check_bloodtalons()
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
                check_bloodtalons()

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
                check_bloodtalons()

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
                check_bloodtalons()

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
                check_bloodtalons()
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


    spec:RegisterPack( "Feral", 20220222, [[dSuE0bqiev9isICjqLuBse(KiQmkKKtHeTkLiEfjPzbQ6wkr1UO4xIKgMikhtjSmrKNHKY0ijCnqfBtjk9nKuPXHKQY5ijkzDiPI5HOY9qK9rI6GGkjwOiXdvIutejvvBejv5JIOQ6KKefRerzMkrs3uevLDIe(jjr1qjjk1sbvINIWujr(kOssJvjs0Er1FP0GboSWIH0Jj1KvQltSzq(SOA0IYPLSAruLxdkMnk3wjTBv(TQgosDCLiHLR45qnDQUoeBxK67KW4bvQZdkTELOy(Ku7xQ5l4kXj2HlCkskzjLuYskPKmjTGAjLe14eoS0cNGo0We5cN4IvHtq9KjyCc6aw2hBUsCc8JmAHtK5onM6KAQ5LNHGA0)AQ4AfHfE9NEcipvCTQtLtGIumxL54OCID4cNIKswsjLSKskjtslOwsluzXjcep7hobrTU0CISAVLJJYj2cwZjOEYeSgq9pi1UjJ6jOdsmW2GKsc(gKuYskPMSMSLolUCbtDAYwEd2dsTnVcMcjslwD4Kw0aDMOHb3a)BWEqQT5vWuirAXQd30KT8gS0)LwgVbPOudO)Nzhb)iJwAG)nqruEde4MEemU(Z0KT8gaxzVBqDUmdcTxOmPbupMGZ0ta5nOGAaSpsdYI0sdU3ZQlVbcdlnW)gSFtt2YBa1)FjN3GSNTBWs)x6hgPbq)0a4sr3aKJjyCdG9rsogRbJemgSnaUu0gobRWoMReNaL9)2d2FyUsCkwWvItixGYKnpforO96poXeWiCc9uUmvWjOQbKVbEPHPU8gOwDdOQblmj1GL0aAzWf2LZTRimVOzLmnqzsny)Uzcyed9kcZlAwjtdOSbQv3aQAqO9kTyrDRpvEUm4gqQbj1GenyeOrWzbktAaLnGYgKObOiqqgu3obmIz)kooHgwntSEm5IJ5uSG7CksIReNqUaLjBEkCIq71FCcgYfJTomDnHx)Xj0t5YubNyeOrWzbktAqIgGIabzqD76)hunIz)kooHgwntSEm5IJ5uSG7CkOgxjoHCbkt28u4eH2R)4eE2e4mRoCoHEkxMk4eJancolqzsds0aueiidQB9SjWzM9R4AqIgShKAB8SjWzwD4gV0WGT5rDY2(NDeOrWznq5gqvdurduTbyAHXSEm5IJnE2e4mRo8gSKgOIgqzdsTbu1Gfnq1gSgyxgyTPdgI0akBWYBG(Vns5gpWUyH(XIY(FBKlqzYMtOHvZeRhtU4yofl4oNcvWvItixGYKnpfoHEkxMk4eOiqqgu3IoiEWSywGZm7xXXjcTx)XjqhepywmlWzCNtbC4kXjKlqzYMNcNqpLltfCcueiidQBXkkAXSFfxds0amTWywpMCXXgSIIwS6WBGYnybNi0E9hNaROOfRoCUZPyz5kXjKlqzYMNcNqpLltfCcueiidQBXzJSn7xXXjcTx)XjWzJS5oNcQlxjoHCbkt28u4e6PCzQGtGIabzqDlwrrlM9R44eH2R)4eyffTy1HZDofuFCL4eYfOmzZtHtONYLPcobkceKb1TE2e4mZ(vCCIq71FCcpBcCMvho35oNaQUcNjdxjofl4kXjKlqzYMNcNa6h7jWTZPybNi0E9hNG(FMDe8JmAH7CksIReNqUaLjBEkCc9uUmvWjqrGGm4iDKl25JXmYAuhUbKRbuJteAV(JtGJ0rUyNpgUZPGACL4eYfOmzZtHtONYLPcobvnypi12qp1AWSkMWZmEPHbBZJ6KT9p7iqJGZAGYnGAnyjnGQgGPfgZ6XKlo2qp1AWSkMWZAGQnyrdOSbjAaMwymRhtU4yd9uRbZQycpRbk3GfnGYgOwDdW0cJz9yYfhBONAnywft4znq5gqvdOwduTblAWsAGhm5CdoqLX)3ZmYfOmz3ak5eH2R)4e0tTgmRIj8mUZPqfCL4eYfOmzZtHteAV(JtmfnNqpLltfCIrGgbNfOmPbjAWEqQTzkAJxAyW28OozB)Zoc0i4SgOCdshtfOmXmfT1lnm4gKObu1aQAakceKXRCzWwiKbwdcDduRUbKVbEPHPU8gqzds0aQAakceKbL9)2d2FydcDduRUbKVbEWKZnOS)3EW(dBKlqzYUbu2a1QBa5BGhm5CdoqLX)3ZmYfOmz3akBqIgqvdW0cJz9yYfhBONAnywft4znGudw0a1QBa5BGhm5Cd9uRbZQycpZixGYKDdOSbjAavni0ELwS73ntr3asniznqT6g4LgM6YBqIgeAVsl297MPOBaPgSObQv3aY3Gb5eOFYfZEcK8m3(q2Ti0wOxJGnYfOmz3a1QBa5BGhm5CdoqLX)3ZmYfOmz3ak5eAy1mX6XKloMtXcUZPaoCL4eYfOmzZtHtONYLPcobkceKbhPJCXoFmMrwJ6WnGCnGQgO)v03s)154gOAdw0akBWsAWY2GL0GKzOgNi0E9hNahPJCXoFmCNtXYYvItixGYKnpfoXAa3w5Kjhwofl4eH2R)4eqY866rWw0YfoHgwntSEm5IJ5uSG7CkOUCL4eYfOmzZtHteAV(JtajZRRhbBrlx4e6PCzQGtGIabzqX260ge6gKObEWKZn4hHzFiRNjwOFeSBKlqzYUbQv3a9)S9R4m6)s)WiwptSy6AkhBgznQd3aY1Gfnird0FA5IZnxLN5wOq4eAy1mX6XKloMtXcUZDobwCeAUsCkwWvItixGYKnpfoHEkxMk4e6pTCX5Mt0ZZ(z3GenatlmM1JjxCSXZMaNz1H3aY1av0Genq)ROVL(RZXnGCnaonirdiFd8sdtD5nirdiFdqrGGmOyBDAdcnNi0E9hNGHCXyRdtxt41FCNtrsCL4eYfOmzZtHta9J9e425uSGteAV(Jtq)pZoc(rgTWDofuJReNqUaLjBEkCc9uUmvWj8GjNBGKjywOrULbwJCbkt2nird0)Z2VIZajtWSqJCldSge6gKObKVbOiqqgCKoYf78XyqOBqIgO)v03s)154gOCdw0Geny)UzcyeJxAyQlVbjAavny)UHHCXyRdtxt41FgV0WuxEduRUbKVbEWKZnmKlgBDy6AcV(ZixGYKDdOKteAV(JtGJ0rUyNpgUZPqfCL4eYfOmzZtHtONYLPcoHhm5Cdk7)ThS)Wg5cuMSBqIgGIabzqz)V9G9h2SFfxds0aQAGCYKdBduTbuZaNgSKgiNm5WAgjxUgOAdOQbQiznyjnafbcYOzsm6a71LBqOBaLnGYgqUgqvdwSaony5nijQ1GL0aueiitD6yUWR)SWuxU9HSEMytEixotmi0nGYgKObH2R0If1T(u55YGBaPgKmorO96pob9)m7i4hz0c35uahUsCc5cuMS5PWj0t5YubNWdMCUbL9)2d2FyJCbkt2nirdqrGGmOS)3EW(dB2VIRbjAavnq)ROVL(RZXnGCnaonqT6gGPfgZ6XKlo24ztGZS6WBaPgSObuYjW(uANtXcorO96poHoymBO96plRWoNGvy3EXQWjqz)V9G9hM7CkwwUsCc5cuMS5PWjcTx)Xj0bJzdTx)zzf25eSc72lwfoH(F2(vCCNtb1LReNqUaLjBEkCc9uUmvWj0)k6BP)6CCduUbuRbjAavnafbcYGY(F7b7pSbHUbQv3aY3apyY5gu2)Bpy)HnYfOmz3ak5eyFkTZPybNi0E9hNqhmMn0E9NLvyNtWkSBVyv4eq1v4mz4o35eObloTWvItXcUsCc5cuMS5PWj0t5YubNafbcYiAwrJfl(zXy2VIRbjAakceKr0SIglwgYfJz)kUgKObu1GrGgbNfOmPbQv3aQAqO9kTyLtwlb3aLBWIgKObH2R0ID)UbJCq1inGCni0ELwSYjRLGBaLnGsorO96pobg5GQr4oNIK4kXjKlqzYMNcNqpLltfCcueiiJOzfnwS4NfJzK1OoCduUblswduTb6a7wVwLgOwDdqrGGmIMv0yXYqUymJSg1HBGYnyrYAGQnqhy361QWjcTx)XjWEmyKjx4oNcQXvItixGYKnpfoHEkxMk4eOiqqgrZkASyzixmMrwJ6Wnq5gOdSB9AvAGA1nafbcYiAwrJfl(zXy2VIRbjAa(zXyfnROXsduUbjRbQv3aueiiJOzfnwS4NfJz)kUgKObmKlgROzfnwAWYBqO96pJIj8mtDwiwLN5nGCnybNi0E9hNa7XavJWDofQGReNqUaLjBEkCc9uUmvWjqrGGmIMv0yXIFwmMrwJ6Wnq5gOdSB9AvAGA1nafbcYiAwrJfld5IXSFfxds0agYfJv0SIglny5ni0E9NrXeEMPoleRYZ8gOCdsgNi0E9hNqXeEg35oNylqbcZ5kXPybxjoHCbkt28u4e6PCzQGtGIabzw))GPol0pRge6gKObKVb7bP2MxbtHePfRoCob2Ns7CkwWjcTx)XjgKZgAV(ZYkSZjyf2TxSkCc0GfNw4oNIK4kXjKlqzYMNcNqpLltfCI9GuBZRGPqI0IvhoNa7tPDofl4eH2R)4e6GXSH2R)SSc7CcwHD7fRcN4vWuirAH7CkOgxjoHCbkt28u4eBbRNI2R)4eQSNxbRbkYKtsltdOFmUqzcNi0E9hNGEEfmUZPqfCL4eYfOmzZtHtONYLPcobkceKrhUf6NvZ(vCCIq71FCcVYLbBHqgy5oNc4WvItixGYKnpfoHEkxMk4eOiqqgD4wOFwn7xXXjcTx)Xj0HBH(zL7CkwwUsCc5cuMS5PWj2cwpfTx)Xju5N0aC27na7sW8morO96poXGC2q71FwwHDob2Ns7CkwWj0t5YubNafbcYGZI9RyvyBdcDduRUbOiqqg65vWmi0CcwHD7fRcNa7sW8mUZPG6YvIteAV(JtGHbHXSOboJtixGYKnpfUZPG6JReNqUaLjBEkCc9uUmvWjcTxPf7(DZu0nGudsgNa7tPDofl4eH2R)4e6GXSH2R)SSc7CcwHD7fRcNalocn35uOYIReNqUaLjBEkCIq71FCcDWy2q71FwwHDobRWU9IvHtO)NTFfh35uSizCL4eYfOmzZtHteAV(JtmfnNyly9u0E9hNGcrpp7Nn1PblDG9gqTg8tdurd0)k63a6VoVbtrJBWFnaxxotAGhtU4n4rCCTLg8qnavgSmW0GFAWgzQlVbOYGLbMguqnasMG1aOrULb2gu4gGq3avoCPbbnnd2genaoA6gaxk6gOitUgOe1RbfUbi0niUDduumwdW)FnakySg8qqgoHEkxMk4e6pTCX5Mt0ZZ(z3GenGQgq(g4bto3GY(F7b7pSrUaLj7gOwDdqrGGmOS)3EW(dBqOBaLnirdW0cJz9yYfhB8SjWzwD4nGudw0GenGQgO)v03s)154gOCdsQbjAWiqJGZcuM0Genypi12mfTXlnmyBEuNST)zhbAeCwduUbPJPcuMyMI26LggCds0aQAa5BakceKbfBRtBqOBGA1nq)pB)kodk2wN2Gq3a1QBavnafbcYGIT1Pni0nird0)Z2VIZajtWSqJCldSge6gqzdOSbQv3a9VI(w6Voh3asnaonirdqrGGmELld2cHmWAqOBqIgGIabz8kxgSfczG1mYAuhUbKRbQObjAWEqQTzkAJxAyW28OozB)Zoc0i4SgOCdGtdOK7CkwSGReNqUaLjBEkCc9uUmvWj0)k6BP)6CCduMudOQbWPblVbPJPcuMyGEKrtBrlxAaLCcSpL25uSGteAV(JtmiNn0E9NLvyNtWkSBVyv4eq1v4mz4oNIfjXvItixGYKnpfoHEkxMk4e7bP2g6PwdMvXeEMXlnmyBEuNST)zhbAeCwduMudskznird0)k6BP)6CCduMudsIteAV(Jtqp1AWSkMWZ4eS6eREZjGd35uSGACL4eYfOmzZtHtSfSEkAV(JtK8HW8A556DdWUempJteAV(JtOdgZgAV(ZYkSZjW(uANtXcoHEkxMk4eOiqqguSToTbHMtWkSBVyv4eyxcMNXDoflubxjoHCbkt28u4eBbRNI2R)4ekLjny9XEde4MwoCLwAqkk1anSAM0aQukBeCwdiYgz3acffT0a9J9gSybCAGCYKdl8nynGrAagzKgOqAGoUgSgWinWZcVb11av0GC2JgmmLCcSO5eu1aQAWIfWPblVbjrTgSKgGIabzQthZfE9NfM6YTpK1ZeBYd5YzIbHUbu2GL3aQAGCYKdRrJmJCEduTbuZaNgSKgiNm5WAgjxUgOAdOQbQiznyjnafbcYOzsm6a71LBqOBaLnGYgqzdsTbYjtoSMrYLJteAV(JtOikNtONYLPcoHhm5Cdk7)ThS)Wg5cuMSBqIgGIabzqz)V9G9h2SFfxds0Gq7vAXI6wFQ8CzWnGudsg35uSaoCL4eYfOmzZtHtSfSEkAV(JteAV(dB2cuGWCvjLk9)m7i4hz0c8fejpyY5gu2)Bpy)HnYfOmzNafbcYGY(F7b7pSz)kUeujNm5WQk1mWzjYjtoSMrYLtvQurYwckceKrZKy0b2Rl3GqtjLKJQflGZYtIAlbfbcYuNoMl86plm1LBFiRNj2KhYLZedcnLjcTxPflQB9PYZLbtkzCIq71FCIb5SH2R)SSc7CcSpL25uSGtONYLPcoHhm5Cdk7)ThS)Wg5cuMSBqIgGIabzqz)V9G9h2SFfhNGvy3EXQWjqz)V9G9hM7CkwSSCL4eYfOmzZtHteAV(JtajZRRhbBrlx4e6PCzQGtGIabzcAbUT0JSd)hSvpr66Yni0CcnSAMy9yYfhZPyb35uSG6YvItixGYKnpfob0p2tGBNtXcorO96pob9)m7i4hz0c35uSG6JReNqUaLjBEkCIq71FCIjGr4e6PCzQGtqvdgbAeCwGYKgOwDdOLbxyxo3UIW8IMvY0aLBW(DZeWig6veMx0SsMgqzds0G9GuBZeWigV0WGT5rDY2(NDeOrWznq5gGPfgZ6XKlo2Gvu0IvhEdwsdsQblVbjXj0WQzI1JjxCmNIfCNtXcvwCL4eYfOmzZtHteAV(JtWqUyS1HPRj86poHEkxMk4eu1GrGgbNfOmPbQv3aAzWf2LZTRimVOzLmnq5gSF3WqUyS1HPRj86pd9kcZlAwjtdOSbjAWEqQTHHCXyRdtxt41FgV0WGT5rDY2(NDeOrWznq5gGPfgZ6XKlo2Gvu0IvhEdwsdsQblVbjXj0WQzI1JjxCmNIfCNtrsjJReNqUaLjBEkCcOFSNa3oNIfCIq71FCc6)z2rWpYOfUZPiPfCL4eYfOmzZtHteAV(Jt4ztGZS6W5e6PCzQGtmc0i4SaLjnird2dsTnE2e4mRoCJxAyW28OozB)Zoc0i4SgOCdOQbQObQ2amTWywpMCXXgpBcCMvhEdwsdurdOSbP2aQAWIgOAdwdSldS20bdrAaLny5nq)3gPCJhyxSq)yrz)VnYfOmz3GL3a9NwU4CZj65z)SBqIgqvdiFdqrGGmOyBDAdcDduRUbyAHXSEm5IJnE2e4mRo8gOCdw0ak5eAy1mX6XKloMtXcUZPiPK4kXjKlqzYMNcNa6h7jWTZPybNi0E9hNG(FMDe8JmAH7CksIACL4eYfOmzZtHtONYLPcobvnyIABL0Y5MyVXM6AGYnGQgSObQ2G1aUT6SyYfCdwEd0zXKlyl0eAV(lynGYgSKgmIolMCX61Q0akBqIgqvdW0cJz9yYfhBqhepywmlWznyjni0E9NbDq8GzXSaNz2XAKlni1geAV(ZGoiEWSywGZm6h7nGYgOCdOQbH2R)m4Sr2MDSg5sdsTbH2R)m4Sr2g9J9gqjNi0E9hNaDq8GzXSaNXDofjPcUsCc5cuMS5PWj0t5YubNatlmM1JjxCSbROOfRo8gOCdw0avBakceKbfBRtBqOBWsAqsCIq71FCcSIIwS6W5oNIKGdxjoHCbkt28u4e6PCzQGtGPfgZ6XKlo24ztGZS6WBGYnGACIq71FCcpBcCMvho35uK0YYvItixGYKnpfoHEkxMk4eOiqqgntIrhyVUCdcDds0aQAakceKbJS3YzJvueCMz)kUgKObOiqqgCwSFfRcBB2VIRbQv3aueiidk2wN2Gq3ak5eH2R)4e4Sr2CNtrsuxUsCc5cuMS5PWjcTx)XjMagHtONYLPcobkceKbfBRtBqOBqIgShKABMagX4LggSnpQt22)SJancoRbk3GK4eAy1mX6XKloMtXcUZPijQpUsCc5cuMS5PWjcTx)Xj0bJzdTx)zzf25eSc72lwfobuXyYWDUZjOhr)ROHZvItXcUsCc5cuMS5PWjEAobwCorO96por6yQaLjCI0bdr4ejJtKog7fRcNa6rgnTfTCH7CksIReNqUaLjBEkCINMtGfNteAV(JtKoMkqzcNiDWqeoXcoXwW6PO96pobr2i7gqQbjd(gqXFlhFbno79gaxcyKgqQblGVbexqJZEVbWLagPbKAqsW3GLQktdi1aQbFdiuu0sdi1avWjshJ9IvHtavmMmCNtb14kXjKlqzYMNcN4P5eyX5eH2R)4ePJPcuMWjshmeHtqD5ePJXEXQWjMI26Lggm35uOcUsCIq71FCcyQBpY2IPRPCmNqUaLjBEkCNtbC4kXjcTx)XjqF3zY2cXcyLTI6YT(d31XjKlqzYMNc35uSSCL4eYfOmzZtHtONYLPcob(ryO1Tn0iyhHjwzqO96pJCbkt2nqT6gGFegADBt6NfEXel(zPLZnYfOmzZjcTx)XjGycotpbKZDofuxUsCc5cuMS5PWj0t5YubNafbcYS()btDwOFwn7xXXjcTx)XjONxbJ7CkO(4kXjKlqzYMNcNqpLltfCcueiiZ6)hm1zH(z1SFfhNi0E9hNqhUf6NvUZDobuXyYWvItXcUsCc5cuMS5PWjcTx)XjMagHtONYLPcor6yQaLjgOIXKPbKAWIgKObJancolqzsds0G97MjGrm0RimVOzLmnGCKAWctsnyjnGwgCHD5C7kcZlAwjdNqdRMjwpMCXXCkwWDofjXvItixGYKnpfoHEkxMk4ePJPcuMyGkgtMgqQbjXjcTx)XjMagH7CkOgxjoHCbkt28u4e6PCzQGtKoMkqzIbQymzAaPgqnorO96pobd5IXwhMUMWR)4oNcvWvItixGYKnpfoHEkxMk4ePJPcuMyGkgtMgqQbQGteAV(JtGvu0Ivho35uahUsCc5cuMS5PWj0t5YubNafbcYGr2B5SXkkcoZSFfhNi0E9hNaNnYM7CkwwUsCc5cuMS5PWj0t5YubNa)im062gAeSJWeRmi0E9NrUaLj7gOwDdWpcdTUTj9ZcVyIf)S0Y5g5cuMS5e15Ymi0UTG4e4hHHw32K(zHxmXIFwA5CorDUmdcTBR1vzxHlCIfCIq71FCciMGZ0ta5CI6CzgeA3MZE0GXjwWDUZjWUempJReNIfCL4eYfOmzZtHta9J9e425uSGteAV(Jtq)pZoc(rgTWDofjXvItixGYKnpforO96poXeWiCcnSAMy9yYfhZPybNqpLltfCcQAW(DZeWig6veMx0SsMgqUgSWaNgOwDdgbAeCwGYKgqzds0G9GuBZeWigV0WGT5rDY2(NDeOrWznq5gKuduRUbu1aAzWf2LZTRimVOzLmnq5gSF3mbmIHEfH5fnRKPbjAakceKbfBRtBqOBqIgGPfgZ6XKlo24ztGZS6WBa5Aa1AqIgO)0YfNBorpp7NDdOSbQv3aueiidk2wN2mYAuhUbKRbl4eBbRNI2R)4eWLagPbNiBCdMhjpJbBdGtYGRBWd1GYXnGjxUN1GWBq0G16QvK1g4FdWidDGXnaNnYg3GnTWDofuJReNqUaLjBEkCc9uUmvWjW0cJz9yYfhB8SjWzwD4nGCnGAnirdgbAeCwGYKgKOb7bP2ggYfJTomDnHx)z8sdd2Mh1jB7F2rGgbN1aLBaCAqIgqvd0)k6BP)6CCdi1av0a1QBW(Ddd5IXwhMUMWR)mJSg1HBa5AaCAGA1nG8ny)UHHCXyRdtxt41FgV0WuxEdOKteAV(JtWqUyS1HPRj86pUZPqfCL4eYfOmzZtHteAV(JtGoiEWSywGZ4eBbRNI2R)4ePmiEWAablWznOWnavCxMg4zX1aSlbZZAar2i7geEdOwd8yYfhZj0t5YubNatlmM1JjxCSbDq8GzXSaN1aLBqsCNtbC4kXjKlqzYMNcNa6h7jWTZPybNi0E9hNG(FMDe8JmAH7CkwwUsCc5cuMS5PWj0t5YubNq)ROVL(RZXnGCnqfnirdW0cJz9yYfhB8SjWzwD4nGCnaoCIq71FCcC2iBUZDoH(F2(vCCL4uSGReNqUaLjBEkCIq71FCIyh0ELwSyfXSYj0t5YubNGQgqvdiFd2VBIDq7vAXIveZQDhRrUy8sdtD5nqT6gSF3e7G2R0IfRiMv7owJCXmYAuhUbKRbj1akBqIgqvd2VBIDq7vAXIveZQDhRrUyWEOHPbKRbuRbQv3aY3G97Myh0ELwSyfXSAZKGzWEOHPbk3GfnGYgKObKVbH2R)mXoO9kTyXkIz1MjbZuNfIv5zEds0aY3Gq71FMyh0ELwSyfXSA3XAKlM6SqSkpZBqIgq(geAV(Ze7G2R0IfRiMvtDwiwLN5nGYgKObEm5IB8AvS(B3L0aLBaCAGA1ni0ELwSYjRLGBGYniPgKObKVb73nXoO9kTyXkIz1UJ1ixmEPHPU8gKObYjtoSnGCnGAWPbjAGhtU4gVwfR)2Djnq5gahoHgwntSEm5IJ5uSG7CksIReNqUaLjBEkCITG1tr71FCILoWEduQYLj5WnG6HmW2aub6hPbu9tdQ1vzxHZGTbbKldLnqhyVU8gq9KjynG6nYTmW2GcQbPidwgyAqHBafQCLAWFnq)pB)kodNad7P5eqYeml0i3YalNqpLltfCc9)S9R4mOyBDAdcnNi0E9hNWRCzWwiKbwUZPGACL4eYfOmzZtHteAV(JtajtWSqJCldSCc9uUmvWj0)k6BP)6CCdixdOwds0apMCXnETkw)T7sAGYnG62GenGQgGIabzWr6ixSZhJbHUbQv3aY3apyY5gCKoYf78XyKlqzYUbu2GenGQgq(gO)NTFfNXRCzWwiKbwdcDduRUb6)z7xXzqX260ge6gqzduRUbqvEMBhznQd3aY1aQVgKObqvEMBhznQd3aLBqsCcnSAMy9yYfhZPyb35uOcUsCc5cuMS5PWjcTx)XjqLbldmCITG1tr71FCcLu5u)QCQtdOqKDd8VbyypDduuEwduuEwdMiTCpcUbqJCldSnqrMCnqH0Gb5Aa0i3YalACB4BWpniCMeyVb6mrdtdkOguoUbk(XZAq5Cc9uUmvWj0)k6BP)6CCduMudOg35uahUsCc5cuMS5PWj0t5YubNq)ROVL(RZXnqzsnGACIq71FCI60XCHx)XDofllxjoHCbkt28u4eH2R)4eELld2cHmWYj2cwpfTx)XjuAGTbXTBW9EdueyxAGsuVgiNm5WcFdqr8gem83GKhc2BacwAq5na6NgSmYatdIB3G60XCyoHEkxMk4eYjtoSMTav6YBGYnqfjRbQv3aueiidk2wN2Gq3a1QBavnWdMCUHEKD4)yKlqzYUbjAao7hxWU19DdixdOwdOK7CkOUCL4eYfOmzZtHteAV(JtGZI9RyvyBoXwW6PO96porYxLN5navAGI5V8g4FdqWsdiwf2Ub)1a4saJ0G6AqAzGTbPLb2gCLotAaUCKWR)WW3aueVbPLb2gmXimy5e6PCzQGtGIabz8kxgSfczG1Gq3GenafbcYGIT1Pn7xX1Genq)ROVL(RZXnGCnqfnirdqrGGmyK9woBSIIGZm7xX1Geny)Uzcyed9kcZlAwjtdixdwyw2gKObYjtoSnq5gOIK1Genypi12mbmIXlnmyBEuNST)zhbAeCwduUbyAHXSEm5IJnyffTy1H3GL0GKAWYBqsnird8yYf341Qy93UlPbk3a4WDofuFCL4eYfOmzZtHtONYLPcobkceKXRCzWwiKbwdcDduRUbOiqqguSToTbHMteAV(JtGkdwgyQlN7CkuzXvItixGYKnpfoHEkxMk4eOiqqguSToTbHUbQv3a0hJBqIgav5zUDK1OoCdixd0)Z2VIZGIT1PnJSg1HBGA1na9X4gKObqvEMBhznQd3aY1GKGdNi0E9hNG(96pUZPyrY4kXjKlqzYMNcNqpLltfCcueiidk2wN2Gq3a1QBauLN52rwJ6WnGCniPfCIq71FCIjsl3JGTqJCldSCNtXIfCL4eYfOmzZtHteAV(JtO)l9dJy9mXIPRPCmNyly9u0E9hNqjvo1VkN60GLot0W0G1)pyQRbzVRObXTBa2rGGAaRGrAGNvy4BqC7gSgWIknavCxMgO)v0WBWiRrDnyemSNMtONYLPcobvnGQgSF3mfTzK1OoCduUbQObQv3aOkpZTJSg1HBa5Aq6yQaLjMPOTEPHb3Geny)UzkAJxAySETknGYgKOb6Ff9T0FDoUbKRbWPbjAavny)UzcyeJxAyQlVbQv3amTWywpMCXXgpBcCMvhEduUblAaLnirdKtMCynBbQ0L3aLj1GKswdOSbQv3a0hJBqIgav5zUDK1OoCdixdGd35uSijUsCc5cuMS5PWjcTx)XjKv6xHmw0)2CITG1tr71FCIKVawuPbEMmsdWzpcB3auPbR)inq)3U86pCd(RbEM0a9FBKY5e6PCzQGtGIabz8kxgSfczG1Gq3a1QBavnq)3gPCZweABWysEfNwmYfOmz3ak5oNIfuJReNqUaLjBEkCITG1tr71FCIK)kT0a6P(PCyBG)n4VLJGLgOqc6)4exSkCIK37ixUuZy3c2RdwSvhmgNqpLltfCczPaPOPLTj59oYLl1m2TG96GfB1bJXjcTx)XjsEVJC5snJDlyVoyXwDWyCNtXcvWvIteAV(JtGGfB5YkMtixGYKnpfUZDoXRGPqI0cxjofl4kXjKlqzYMNcNqpLltfCcueiitMeJBFiRNjwffBBqO5eH2R)4eypgmYKlCNtrsCL4eYfOmzZtHteAV(JtGroOAeobRoXQ3CcvSKC9M7CkOgxjoHCbkt28u4eH2R)4eR)Fq1iCc9uUmvWjqrGGmR)FWuNf6NvdcDds0amTWywpMCXXgpBcCMvhEdixdsQbjAa5BGhm5Cdd5IXwhMUMWR)mYfOmzZjy1jw9MtOILKR3CNtHk4kXjKlqzYMNcNqpLltfCc5Kjh2gqUgqTK1Geny)UzkAZiRrD4gOCduHbonirdOQb6)z7xXz8kxgSfczG1mYAuhUbktQblRbonqT6gmiNa9tUy0HlWkwnYuVrUaLj7gqzds0aueiiJMjXOdSxxUb7HgMgqUgSObjAa5BakceKjOf42spYo8FWw9ePRl3Gq3GenG8nafbcYGY(FZqWUbHUbjAa5BakceKbfBRtBqOBqIgqvd0)Z2VIZO)l9dJy9mXIPRPCSzK1OoCduUblRbonqT6gq(gO)0YfNBUkpZTqH0akBqIgqvdiFd0FA5IZnNONN9ZUbQv3a9)S9R4mXoO9kTyXkIz1mYAuhUbktQbWPbQv3G97Myh0ELwSyfXSA3XAKlMrwJ6Wnq5gqDBaLCIq71FCImjg3(qwptSkk2M7CkGdxjoHCbkt28u4e6PCzQGtiNm5W2aY1aQLSgKOb73ntrBgznQd3aLBGkmWPbjAavnq)pB)koJx5YGTqidSMrwJ6Wnqzsnqfg40a1QBWGCc0p5IrhUaRy1it9g5cuMSBaLnirdqrGGmAMeJoWED5gShAyAa5AWIgKObKVbOiqqMGwGBl9i7W)bB1tKUUCdcDds0aY3aueiidk7)ndb7ge6gKObu1aY3aueiidk2wN2Gq3a1QBG(tlxCU5e98SF2nird8GjNBWr6ixSZhJrUaLj7gKObOiqqguSToTzK1OoCduUblBdOSbjAavnq)pB)koJ(V0pmI1ZelMUMYXMrwJ6Wnq5gSSg40a1QBa5BG(tlxCU5Q8m3cfsdOSbjAavnG8nq)PLlo3CIEE2p7gOwDd0)Z2VIZe7G2R0IfRiMvZiRrD4gOmPgaNgOwDd2VBIDq7vAXIveZQDhRrUygznQd3aLBa1Tbu2GenaQYZC7iRrD4gOCdOUCIq71FCI1)pyQZc9Zk35o35ePLbx)XPiPKLusjlPKsItOiMRUCmNaUkCf4cfQmuK8tDAqduktAqTs)J3aOFAqYbvxHZKj5AWilfi1i7gG)vPbbI)RHl7gOZIlxWMMSLADsdub1Pbl9FPLXLDdsUb5eOFYfZszY1a)BqYniNa9tUywknYfOmzNCnGQfWnLMMSMm4QWvGluOYqrYp1PbnqPmPb1k9pEdG(Pbj3wGceMNCnyKLcKAKDdW)Q0GaX)1WLDd0zXLlytt2sToPbjTG60GL(V0Y4YUbe16s3amSNhWDdGRBG)nyPIenyxPlC9xdEAzc)NgqvQu2aQwa3uAAYwQ1jnijQrDAWs)xAzCz3aIADPBag2Zd4UbW1nW)gSurIgSR0fU(RbpTmH)tdOkvkBavjb3uAAYAYGRcxbUqHkdfj)uNg0aLYKguR0)4na6NgKCOS)3EW(dNCnyKLcKAKDdW)Q0GaX)1WLDd0zXLlytt2sToPbuJ60GL(V0Y4YUbe16s3amSNhWDdGRBG)nyPIenyxPlC9xdEAzc)NgqvQu2aQwa3uAAYAYGRcxbUqHkdfj)uNg0aLYKguR0)4na6NgKCVcMcjsljxdgzPaPgz3a8Vkniq8FnCz3aDwC5c20KTuRtAGkOonyP)lTmUSBqYniNa9tUywktUg4FdsUb5eOFYfZsPrUaLj7KRbuTaUP00KTuRtAaCOonyP)lTmUSBqYniNa9tUywktUg4FdsUb5eOFYfZsPrUaLj7KRbuTaUP00K1KPYSs)Jl7gSizni0E9xdyf2XMMmob98qft4eQKk1aQNmbRbu)dsTBYujvQbupbDqIb2gKusW3GKswsj1K1KPsQudw6S4Yfm1PjtLuPgS8gShKABEfmfsKwS6WjTOb6mrddUb(3G9GuBZRGPqI0IvhUPjtLuPgS8gS0)LwgVbPOudO)Nzhb)iJwAG)nqruEde4MEemU(Z0KPsQudwEdGRS3nOoxMbH2luM0aQhtWz6jG8guqna2hPbzrAPb37z1L3aHHLg4Fd2VPjtLuPgS8gq9)xY5ni7z7gS0)L(HrAa0pnaUu0na5ycg3ayFKKJXAWibJbBdGlfTPjRjl0E9h2qpI(xrdxvsPMoMkqzc8xSkKGEKrtBrlxGpDWqesjRjtLAar2i7gqQbjd(gqXFlhFbno79gaxcyKgqQblGVbexqJZEVbWLagPbKAqsW3GLQktdi1aQbFdiuu0sdi1av0KfAV(dBOhr)ROHRkPuthtfOmb(lwfsqfJjd8PdgIqArtwO96pSHEe9VIgUQKsnDmvGYe4VyvinfT1lnmy4thmeHe1Tjl0E9h2qpI(xrdxvsPctD7r2wmDnLJBYcTx)Hn0JO)v0WvLuQOV7mzBHybSYwrD5w)H76AYcTx)Hn0JO)v0WvLuQqmbNPNaYHVGiHFegADBdnc2ryIvgeAV(ZixGYKTA14hHHw32K(zHxmXIFwA5CJCbkt2nzH2R)Wg6r0)kA4Qskv65vWGVGiHIabzw))GPol0pRM9R4AYcTx)Hn0JO)v0WvLuQ6WTq)ScFbrcfbcYS()btDwOFwn7xX1K1KfAV(dtAqoBO96plRWo8xSkKqdwCAbESpL2jTa(cIekceKz9)dM6Sq)SAqOtq(9GuBZRGPqI0IvhEtwO96pSQKsvhmMn0E9NLvyh(lwfsVcMcjslWJ9P0oPfWxqK2dsTnVcMcjslwD4nzQuduzpVcwduKjNKwMgq)yCHYKMSq71FyvjLk98kynzH2R)WQskvVYLbBHqgyHVGiHIabz0HBH(z1SFfxtwO96pSQKsvhUf6Nv4lisOiqqgD4wOFwn7xX1KPsnqLFsdWzV3aSlbZZAYcTx)HvLuQdYzdTx)zzf2H)IvHe2LG5zWJ9P0oPfWxqKqrGGm4Sy)kwf22GqRwnkceKHEEfmdcDtwO96pSQKsfddcJzrdCwtwO96pSQKsvhmMn0E9NLvyh(lwfsyXrOHh7tPDslGVGifAVsl297MPOjLSMSq71FyvjLQoymBO96plRWo8xSkK0)Z2VIRjtLAafIEE2pBQtdw6a7nGAn4NgOIgO)v0Vb0FDEdMIg3G)AaUUCM0apMCXBWJ44Aln4HAaQmyzGPb)0GnYuxEdqLbldmnOGAaKmbRbqJCldSnOWnaHUbQC4sdcAAgSniAaC00naUu0nqrMCnqjQxdkCdqOBqC7gOOySgG))AauWyn4HGmnzH2R)WQsk1POHVGiP)0YfNBorpp7NDcQiVhm5Cdk7)ThS)Wg5cuMSvRgfbcYGY(F7b7pSbHMYeyAHXSEm5IJnE2e4mRoCslsqL(xrFl9xNJvoPeJancolqzsI9GuBZu0gV0WGT5rDY2(NDeOrWzkNoMkqzIzkARxAyWjOI8OiqqguSToTbHwTA9)S9R4mOyBDAdcTA1uHIabzqX260ge6e6)z7xXzGKjywOrULbwdcnLuQwT(xrFl9xNJjbNeOiqqgVYLbBHqgyni0jqrGGmELld2cHmWAgznQdtovKypi12mfTXlnmyBEuNST)zhbAeCMYWHYMSq71FyvjL6GC2q71FwwHD4VyvibvxHZKbESpL2jTa(cIK(xrFl9xNJvMevWz5PJPcuMyGEKrtBrlxOSjl0E9hwvsPsp1AWSkMWZGVGiThKABONAnywft4zgV0WGT5rDY2(NDeOrWzktkPKLq)ROVL(RZXktkj4z1jw9MeCAYuPgK8HW8A556DdWUempRjl0E9hwvsPQdgZgAV(ZYkSd)fRcjSlbZZGh7tPDslGVGiHIabzqX260ge6MmvQbkLjny9XEde4MwoCLwAqkk1anSAM0aQukBeCwdiYgz3acffT0a9J9gSybCAGCYKdl8nynGrAagzKgOqAGoUgSgWinWZcVb11av0GC2JgmmLnzH2R)WQskvfr5WJfnjQOAXc4S8KO2sqrGGm1PJ5cV(ZctD52hY6zIn5HC5mXGqt5YPsozYH1OrMroxvQzGZsKtMCynJKlNQuPIKTeueiiJMjXOdSxxUbHMskPmv5KjhwZi5YbFbrYdMCUbL9)2d2FyJCbkt2jqrGGmOS)3EW(dB2VIlrO9kTyrDRpvEUmysjRjtLAqO96pSQKsL(FMDe8JmAb(cIKhm5Cdk7)ThS)Wg5cuMStGIabzqz)V9G9h2SFfxcQKtMCyvLAg4Se5KjhwZi5YPkvQizlbfbcYOzsm6a71LBqOPKsYr1IfWz5jrTLGIabzQthZfE9NfM6YTpK1ZeBYd5YzIbHMYeH2R0If1T(u55YGjLSMSq71FyvjL6GC2q71FwwHD4VyviHY(F7b7pm8yFkTtAb8fejpyY5gu2)Bpy)HnYfOmzNafbcYGY(F7b7pSz)kUMSq71FyvjLkKmVUEeSfTCbEnSAMy9yYfhtAb8fejueiitqlWTLEKD4)GT6jsxxUbHUjl0E9hwvsPs)pZoc(rgTap0p2tGBN0IMSq71FyvjL6eWiWRHvZeRhtU4yslGVGir1iqJGZcuMOwnTm4c7Y52veMx0SsgL3VBMagXqVIW8IMvYqzI9GuBZeWigV0WGT5rDY2(NDeOrWzkJPfgZ6XKlo2Gvu0Ivh(ssA5j1KfAV(dRkPuzixm26W01eE9h8Ay1mX6XKloM0c4lisunc0i4SaLjQvtldUWUCUDfH5fnRKr597ggYfJTomDnHx)zOxryErZkzOmXEqQTHHCXyRdtxt41FgV0WGT5rDY2(NDeOrWzkJPfgZ6XKlo2Gvu0Ivh(ssA5j1KfAV(dRkPuP)Nzhb)iJwGh6h7jWTtArtwO96pSQKs1ZMaNz1HdVgwntSEm5IJjTa(cI0iqJGZcuMKypi124ztGZS6WnEPHbBZJ6KT9p7iqJGZuMkvOkMwymRhtU4yJNnboZQdFjQGs4AQwO6AGDzG1MoyicLlx)3gPCJhyxSq)yrz)VnYfOmzVC9NwU4CZj65z)Stqf5rrGGmOyBDAdcTA1yAHXSEm5IJnE2e4mRoCLxqztwO96pSQKsL(FMDe8JmAbEOFSNa3oPfnzH2R)WQskv0bXdMfZcCg8fejQMO2wjTCUj2BSPoLPAHQRbCB1zXKl4LRZIjxWwOj0E9xWOCjJOZIjxSETkuMGkmTWywpMCXXg0bXdMfZcC2scTx)zqhepywmlWzMDSg5cCDO96pd6G4bZIzboZOFStPYufAV(ZGZgzB2XAKlW1H2R)m4Sr2g9JDkBYcTx)HvLuQyffTy1HdFbrctlmM1JjxCSbROOfRoCLxOkkceKbfBRtBqOxssnzH2R)WQskvpBcCMvho8fejmTWywpMCXXgpBcCMvhUYuRjl0E9hwvsPIZgzdFbrcfbcYOzsm6a71LBqOtqfkceKbJS3YzJvueCMz)kUeOiqqgCwSFfRcBB2VItTAueiidk2wN2GqtztwO96pSQKsDcye41WQzI1JjxCmPfWxqKqrGGmOyBDAdcDI9GuBZeWigV0WGT5rDY2(NDeOrWzkNutwO96pSQKsvhmMn0E9NLvyh(lwfsqfJjttwtwO96pSbL9)2d2FystaJaVgwntSEm5IJjTa(cIevK3lnm1LRwnvlmjTeAzWf2LZTRimVOzLmktA)Uzcyed9kcZlAwjdLQvtvO9kTyrDRpvEUmysjLyeOrWzbktOKYeOiqqgu3obmIz)kUMSq71Fydk7)ThS)WQskvgYfJTomDnHx)bVgwntSEm5IJjTa(cI0iqJGZcuMKafbcYG621)pOAeZ(vCnzH2R)Wgu2)Bpy)HvLuQE2e4mRoC41WQzI1JjxCmPfWxqKgbAeCwGYKeOiqqgu36ztGZm7xXLypi124ztGZS6WnEPHbBZJ6KT9p7iqJGZuMkvOkMwymRhtU4yJNnboZQdFjQGs4AQwO6AGDzG1MoyicLlx)3gPCJhyxSq)yrz)VnYfOmz3KfAV(dBqz)V9G9hwvsPIoiEWSywGZGVGiHIabzqDl6G4bZIzboZSFfxtwO96pSbL9)2d2FyvjLkwrrlwD4WxqKqrGGmOUfROOfZ(vCjW0cJz9yYfhBWkkAXQdx5fnzH2R)Wgu2)Bpy)HvLuQ4Sr2WxqKqrGGmOUfNnY2SFfxtwO96pSbL9)2d2FyvjLkwrrlwD4WxqKqrGGmOUfROOfZ(vCnzH2R)Wgu2)Bpy)HvLuQE2e4mRoC4lisOiqqgu36ztGZm7xX1K1KfAV(dB0)Z2VIJuSdAVslwSIywHxdRMjwpMCXXKwaFbrIkQi)(DtSdAVslwSIywT7ynYfJxAyQlxT697Myh0ELwSyfXSA3XAKlMrwJ6WKljktq1(DtSdAVslwSIywT7ynYfd2dnmKJAQvt(97Myh0ELwSyfXSAZKGzWEOHr5fuMG8H2R)mXoO9kTyXkIz1MjbZuNfIv5zEcYhAV(Ze7G2R0IfRiMv7owJCXuNfIv5zEcYhAV(Ze7G2R0IfRiMvtDwiwLN5uMWJjxCJxRI1F7UeLHJA1H2R0IvozTeSYjLG873nXoO9kTyXkIz1UJ1ixmEPHPU8eYjtoSKJAWjHhtU4gVwfR)2DjkdNMmvsLAqO96pSr)pB)kovjLketWz6jGC4lisuHFegADBdnc2ryIvgeAV(tTA8JWqRBBs)SWlMyXplTCoLWxNlZGq72ADv2v4cPfWxNlZGq72C2JgmslGVoxMbH2Tfej8JWqRBBs)SWlMyXplTCEtMk1GLoWEduQYLj5WnG6HmW2aub6hPbu9tdQ1vzxHZGTbbKldLnqhyVU8gq9KjynG6nYTmW2GcQbPidwgyAqHBafQCLAWFnq)pB)kottwO96pSr)pB)kovjLQx5YGTqidSWJH90KGKjywOrULbw4lis6)z7xXzqX260ge6MSq71FyJ(F2(vCQskvizcMfAKBzGfEnSAMy9yYfhtAb8fej9VI(w6VohtoQLWJjxCJxRI1F7UeLPUjOcfbcYGJ0rUyNpgdcTA1K3dMCUbhPJCXoFmg5cuMSPmbvKx)pB)koJx5YGTqidSgeA1Q1)Z2VIZGIT1Pni0uQwnuLN52rwJ6WKJ6lbuLN52rwJ6WkNutMk1aLu5u)QCQtdOqKDd8VbyypDduuEwduuEwdMiTCpcUbqJCldSnqrMCnqH0Gb5Aa0i3YalACB4BWpniCMeyVb6mrdtdkOguoUbk(XZAq5nzH2R)Wg9)S9R4uLuQOYGLbg4lis6Ff9T0FDowzsuRjl0E9h2O)NTFfNQKsToDmx41FWxqK0)k6BP)6CSYKOwtMk1aLgyBqC7gCV3afb2LgOe1RbYjtoSW3aueVbbd)ni5HG9gGGLguEdG(PblJmW0G42nOoDmhUjl0E9h2O)NTFfNQKs1RCzWwiKbw4lisYjtoSMTav6YvwfjtTAueiidk2wN2GqRwnvEWKZn0JSd)hJCbkt2jWz)4c2TUVjh1OSjtLAqYxLN5navAGI5V8g4FdqWsdiwf2Ub)1a4saJ0G6AqAzGTbPLb2gCLotAaUCKWR)WW3aueVbPLb2gmXimyBYcTx)Hn6)z7xXPkPuXzX(vSkSn8fejueiiJx5YGTqidSge6eOiqqguSToTz)kUe6Ff9T0FDoMCQibkceKbJS3YzJvueCMz)kUe73ntaJyOxryErZkzi3cZYMqozYHvzvKSe7bP2MjGrmEPHbBZJ6KT9p7iqJGZugtlmM1JjxCSbROOfRo8LK0YtkHhtU4gVwfR)2DjkdNMSq71FyJ(F2(vCQskvuzWYatD5WxqKqrGGmELld2cHmWAqOvRgfbcYGIT1Pni0nzH2R)Wg9)S9R4uLuQ0Vx)bFbrcfbcYGIT1Pni0QvJ(yCcOkpZTJSg1HjN(F2(vCguSToTzK1OoSA1OpgNaQYZC7iRrDyYLeCAYcTx)Hn6)z7xXPkPuNiTCpc2cnYTmWcFbrcfbcYGIT1Pni0Qvdv5zUDK1Oom5sArtMk1aLu5u)QCQtdw6mrdtdw))GPUgK9UIge3UbyhbcQbScgPbEwHHVbXTBWAalQ0auXDzAG(xrdVbJSg11GrWWE6MSq71FyJ(F2(vCQskv9FPFyeRNjwmDnLJHVGirfv73ntrBgznQdRSkuRgQYZC7iRrDyYLoMkqzIzkARxAyWj2VBMI24LggRxRcLj0)k6BP)6Cm5GtcQ2VBMagX4LgM6YvRgtlmM1JjxCSXZMaNz1HR8cktiNm5WA2cuPlxzsjLmkvRg9X4eqvEMBhznQdto40KPsni5lGfvAGNjJ0aC2JW2navAW6psd0)TlV(d3G)AGNjnq)3gP8MSq71FyJ(F2(vCQskvzL(viJf9Vn8fejueiiJx5YGTqidSgeA1QPs)3gPCZweABWysEfNwmYfOmztztMk1GK)kT0a6P(PCyBG)n4VLJGLgOqc6)AYcTx)Hn6)z7xXPkPurWITCzf(lwfsjV3rUCPMXUfSxhSyRoym4lisYsbsrtlBtY7DKlxQzSBb71bl2QdgRjl0E9h2O)NTFfNQKsfbl2YLvCtwtwO96pSbQymzinbmc8Ay1mX6XKloM0c4lisPJPcuMyGkgtgslsmc0i4SaLjj2VBMagXqVIW8IMvYqoslmjTeAzWf2LZTRimVOzLmnzH2R)WgOIXKrvsPobmc8feP0XubktmqfJjdPKAYcTx)HnqfJjJQKsLHCXyRdtxt41FWxqKshtfOmXavmMmKOwtwO96pSbQymzuLuQyffTaFbrkDmvGYeduXyYqsfnzH2R)WgOIXKrvsPIZgzdFbrcfbcYGr2B5SXkkcoZSFfxtwO96pSbQymzuLuQqmbNPNaYHVGiHFegADBdnc2ryIvgeAV(ZixGYKTA14hHHw32K(zHxmXIFwA5CJCbkt2WxNlZGq72ADv2v4cPfWxNlZGq72C2JgmslGVoxMbH2Tfej8JWqRBBs)SWlMyXplTCEtwtwO96pSbQUcNjdj6)z2rWpYOf4H(XEcC7Kw0KfAV(dBGQRWzYOkPuXr6ixSZhd8fejueiidosh5ID(ymJSg1Hjh1AYcTx)Hnq1v4mzuLuQ0tTgmRIj8m4lisuThKABONAnywft4zgV0WGT5rDY2(NDeOrWzktTLqfMwymRhtU4yd9uRbZQycpt1fuMatlmM1JjxCSHEQ1GzvmHNP8ckvRgtlmM1JjxCSHEQ1GzvmHNPmvut1flXdMCUbhOY4)7zg5cuMSPSjl0E9h2avxHZKrvsPofn8Ay1mX6XKloM0c4lisJancolqzsI9GuBZu0gV0WGT5rDY2(NDeOrWzkNoMkqzIzkARxAyWjOIkueiiJx5YGTqidSgeA1QjVxAyQlNYeuHIabzqz)V9G9h2GqRwn59GjNBqz)V9G9h2ixGYKnLQvtEpyY5gCGkJ)VNzKlqzYMYeuHPfgZ6XKlo2qp1AWSkMWZiTqTAY7bto3qp1AWSkMWZmYfOmztzcQcTxPf7(DZu0KsMA1EPHPU8eH2R0ID)UzkAsluRM8dYjq)KlM9ei5zU9HSBrOTqVgbRwn59GjNBWbQm()EMrUaLjBkBYcTx)Hnq1v4mzuLuQ4iDKl25Jb(cIekceKbhPJCXoFmMrwJ6WKJk9VI(w6VohR6ckxYYUKKzOwtwO96pSbQUcNjJQKsfsMxxpc2IwUa)Aa3w5KjhwslGxdRMjwpMCXXKw0KfAV(dBGQRWzYOkPuHK511JGTOLlWRHvZeRhtU4yslGVGiHIabzqX260ge6eEWKZn4hHzFiRNjwOFeSBKlqzYwTA9)S9R4m6)s)WiwptSy6AkhBgznQdtUfj0FA5IZnxLN5wOqAYAYcTx)HnVcMcjslKWEmyKjxGVGiHIabzYKyC7dz9mXQOyBdcDtwO96pS5vWuirArvsPIroOAe4z1jw9MKkwsUE3KfAV(dBEfmfsKwuLuQR)Fq1iWZQtS6njvSKC9g(cIekceKz9)dM6Sq)SAqOtGPfgZ6XKlo24ztGZS6WjxsjiVhm5Cdd5IXwhMUMWR)mYfOmz3KfAV(dBEfmfsKwuLuQzsmU9HSEMyvuSn8fej5KjhwYrTKLy)UzkAZiRrDyLvHbojOs)pB)koJx5YGTqidSMrwJ6WktAznWrT6b5eOFYfJoCbwXQrM6PmbkceKrZKy0b2Rl3G9qdd5wKG8OiqqMGwGBl9i7W)bB1tKUUCdcDcYJIabzqz)Vziy3GqNG8OiqqguSToTbHobv6)z7xXz0)L(HrSEMyX01uo2mYAuhw5L1ah1QjV(tlxCU5Q8m3cfcLjOI86pTCX5Mt0ZZ(zRwT(F2(vCMyh0ELwSyfXSAgznQdRmj4Ow9(DtSdAVslwSIywT7ynYfZiRrDyLPUu2KfAV(dBEfmfsKwuLuQR)FWuNf6Nv4lisYjtoSKJAjlX(DZu0MrwJ6WkRcdCsqL(F2(vCgVYLbBHqgynJSg1HvMKkmWrT6b5eOFYfJoCbwXQrM6PmbkceKrZKy0b2Rl3G9qdd5wKG8OiqqMGwGBl9i7W)bB1tKUUCdcDcYJIabzqz)Vziy3GqNGkYJIabzqX260geA1Q1FA5IZnNONN9ZoHhm5Cdosh5ID(ymYfOmzNafbcYGIT1PnJSg1HvEzPmbv6)z7xXz0)L(HrSEMyX01uo2mYAuhw5L1ah1QjV(tlxCU5Q8m3cfcLjOI86pTCX5Mt0ZZ(zRwT(F2(vCMyh0ELwSyfXSAgznQdRmj4Ow9(DtSdAVslwSIywT7ynYfZiRrDyLPUuMaQYZC7iRrDyLPUnznzH2R)WgS4i0Kyixm26W01eE9h8fej9NwU4CZj65z)StGPfgZ6XKlo24ztGZS6WjNksO)v03s)15yYbNeK3lnm1LNG8OiqqguSToTbHUjl0E9h2GfhHwvsPs)pZoc(rgTap0p2tGBN0IMSq71FydwCeAvjLkosh5ID(yGVGi5bto3ajtWSqJCldSg5cuMStO)NTFfNbsMGzHg5wgyni0jipkceKbhPJCXoFmge6e6Ff9T0FDow5fj2VBMagX4LgM6Ytq1(Ddd5IXwhMUMWR)mEPHPUC1QjVhm5Cdd5IXwhMUMWR)mYfOmztztwO96pSblocTQKsL(FMDe8JmAb(cIKhm5Cdk7)ThS)Wg5cuMStGIabzqz)V9G9h2SFfxcQKtMCyvLAg4Se5KjhwZi5YPkvQizlbfbcYOzsm6a71LBqOPKsYr1IfWz5jrTLGIabzQthZfE9NfM6YTpK1ZeBYd5YzIbHMYeH2R0If1T(u55YGjLSMSq71FydwCeAvjLQoymBO96plRWo8xSkKqz)V9G9hgESpL2jTa(cIKhm5Cdk7)ThS)Wg5cuMStGIabzqz)V9G9h2SFfxcQ0)k6BP)6Cm5GJA1yAHXSEm5IJnE2e4mRoCslOSjl0E9h2GfhHwvsPQdgZgAV(ZYkSd)fRcj9)S9R4AYcTx)HnyXrOvLuQ6GXSH2R)SSc7WFXQqcQUcNjd8yFkTtAb8fej9VI(w6VohRm1sqfkceKbL9)2d2FydcTA1K3dMCUbL9)2d2FyJCbkt2u2K1KfAV(dBWUempJe9)m7i4hz0c8q)ypbUDslAYuPgaxcyKgCISXnyEK8mgSnaojdUUbpudkh3aMC5EwdcVbrdwRRwrwBG)naJm0bg3aC2iBCd20stwO96pSb7sW8mvjL6eWiWRHvZeRhtU4yslGVGir1(DZeWig6veMx0SsgYTWah1QhbAeCwGYektShKABMagX4LggSnpQt22)SJancot5KuRMkAzWf2LZTRimVOzLmkVF3mbmIHEfH5fnRKjbkceKbfBRtBqOtGPfgZ6XKlo24ztGZS6Wjh1sO)0YfNBorpp7NnLQvJIabzqX260MrwJ6WKBrtwO96pSb7sW8mvjLkd5IXwhMUMWR)GVGiHPfgZ6XKlo24ztGZS6Wjh1smc0i4SaLjj2dsTnmKlgBDy6AcV(Z4LggSnpQt22)SJancotz4KGk9VI(w6VohtsfQvVF3WqUyS1HPRj86pZiRrDyYbh1Qj)(Ddd5IXwhMUMWR)mEPHPUCkBYuPgKYG4bRbeSaN1Gc3auXDzAGNfxdWUempRbezJSBq4nGAnWJjxCCtwO96pSb7sW8mvjLk6G4bZIzbod(cIeMwymRhtU4yd6G4bZIzbot5KAYcTx)HnyxcMNPkPuP)Nzhb)iJwGh6h7jWTtArtwO96pSb7sW8mvjLkoBKn8fej9VI(w6VohtovKatlmM1JjxCSXZMaNz1Hto40K1KfAV(dBqdwCAHeg5GQrGVGiHIabzenROXIf)Sym7xXLafbcYiAwrJfld5IXSFfxcQgbAeCwGYe1QPk0ELwSYjRLGvErIq7vAXUF3GroOAeYfAVslw5K1sWusztwO96pSbnyXPfvjLk2JbJm5c8fejueiiJOzfnwS4NfJzK1OoSYlsMQ6a7wVwf1QrrGGmIMv0yXYqUymJSg1HvErYuvhy361Q0KfAV(dBqdwCArvsPI9yGQrGVGiHIabzenROXILHCXygznQdRSoWU1RvrTAueiiJOzfnwS4NfJz)kUe4NfJv0SIglkNm1QrrGGmIMv0yXIFwmM9R4sWqUySIMv0yz5H2R)mkMWZm1zHyvEMtUfnzH2R)Wg0GfNwuLuQkMWZGVGiHIabzenROXIf)SymJSg1Hvwhy361QOwnkceKr0SIglwgYfJz)kUemKlgROzfnwwEO96pJIj8mtDwiwLN5kNmobMw0CkwKmQXDUZ5a]] )


end
