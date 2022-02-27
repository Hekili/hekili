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


    spec:RegisterPack( "Feral", 20220226, [[dSuaYbqiKGhHqXLqOK2Ki8jrKmkKuNcjzvkP4vOknlqLBPKQ2fv(LiXWerCmLKLjI6ziHMgQcxduY2usP(gcLACOkQCoekbRduknpeQUhc2hQuhuePQfks6HkPstevrYgrveFueP4KOksTseYmvsjDtufvTtKOFIQOmuekHwkOu8uenvujFfHs0yfrQSxs(lvnyGdlSyiEmPMSsDzIndYNfvJwuoTKvRKs8AqvZgLBRe7wLFRQHJuhxeP0Yv8COMoLRdPTls9DuX4bLQZdkwVsQy(OQ2VuRwP4srUdtuuMCsso5KKCYRTl5vWII8GhksdgArrshA4JCrrEXIOi5jYemfjDad7JTIlfj(rhTOiZmJgdBtjL8YYqrC6FjfCTGYcR(tpbKLcUw0POirqlMXtFkef5omrrzYjj5KtsYjV2UKxblkYJKvKbQL9JIKSwwxfzwT3YPquKBbRvK8ezcwd4Pg0A3eXteKbngyAqYWcUgKCsso5MOMO1nlUCbdBBIwFd2dATDphghjslEDyew1aDMOHh3a7BWEqRT75W4irAXRdZ1eT(gSU)LwgRbPYvdO)N5hb)OJwAG9nGtuwdeyNEemU(Z1eT(gK0V3nOotMbL2keM0aEctWz6jGSguqnaMhTbzrAPb3Bz1L3aHHLgyFd2VRjA9nGN6VKYAq2Z2nyD)l9dV0aOFAaSPOBa6XemUbW8OjfJ1GrcgdMgaBkANIKvydR4srIW(FBb7pSIlfLRuCPiLlqyYwLQIm0w9NICc4ffPEktMkuKu3ak0aR0WxxEd4ZVbu3GvUKBWAAaTm4cBYz(fuMv0SsMgWnHgSFZnb8IJEbLzfnRKPbu1a(8Ba1ni0wLw8iM3MkpxgCdi0GKBqIgmc0i4SaHjnGQgqvds0aeuiihI5NaEXTFoNIudJMjElMCXWkkxPmfLjR4srkxGWKTkvfzOT6pfjd9IXxhMUMWQ)uK6PmzQqroc0i4SaHjnirdqqHGCiMF5)dQgXTFoNIudJMjElMCXWkkxPmfLuuXLIuUaHjBvQkYqB1FkslBcCMxhMIupLjtfkYrGgbNfimPbjAackeKdX8w2e4m3(5Cnird2dATDw2e4mVomNvA4X(8Ooz7)Zpc0i4SgWDdOUb8Ob82amTWyElMCXWolBcCMxhwdwtd4rdOQbP0aQBWQgWBdwcSjdm(0bdvAavny9nq)3gTmNfyt8q)4ry)VDYfimzRi1WOzI3IjxmSIYvktrjpuCPiLlqyYwLQIupLjtfkseuiihI5rgulyEmlWzU9Z5uKH2Q)uKidQfmpMf4mLPOewkUuKYfimzRsvrQNYKPcfjckeKdX8yofT42pNRbjAaMwymVftUyyhMtrlEDynG7gSsrgAR(trI5u0IxhMYuuU2kUuKYfimzRsvrQNYKPcfjckeKdX84Sr2U9Z5uKH2Q)uK4Sr2ktrjXwXLIuUaHjBvQks9uMmvOirqHGCiMhZPOf3(5CkYqB1FksmNIw86WuMIsEofxks5ceMSvPQi1tzYuHIebfcYHyElBcCMB)CofzOT6pfPLnboZRdtzktrcvxHZKrXLIYvkUuKYfimzRsvrc9J)ey3uuUsrgAR(trs)pZpc(rhTOmfLjR4srkxGWKTkvfPEktMkuKiOqqoCKoYf)8X4gzjQd3aI3akQidTv)PiXr6ix8ZhJYuusrfxks5ceMSvPQi1tzYuHIK6gSh0A7ONAjyEotyzoR0WJ95rDY2)NFeOrWznG7gqXgSMgqDdW0cJ5TyYfd7ONAjyEotyznG3gSQbu1GenatlmM3IjxmSJEQLG55mHL1aUBWQgqvd4ZVbyAHX8wm5IHD0tTempNjSSgWDdOUbuSb82GvnynnWcMCMdhiYy)Bzo5ceMSBavkYqB1Fks6PwcMNZewMYuuYdfxks5ceMSvPQidTv)PiNIwrQNYKPcf5iqJGZceM0GenypO12nfTZkn8yFEuNS9)5hbAeCwd4UbPJPceM4MI2BLgECds0aQBa1nabfcYzvUmype6aJdLUb853ak0aR0WxxEdOQbjAa1nabfcYHW(FBb7pSdLUb853ak0alyYzoe2)Bly)HDYfimz3aQAaF(nGcnWcMCMdhiYy)Bzo5ceMSBavnirdOUbyAHX8wm5IHD0tTempNjSSgqObRAaF(nGcnWcMCMJEQLG55mHL5KlqyYUbu1GenG6geARsl(9BUPOBaHgKKgWNFdSsdFD5nirdcTvPf)(n3u0nGqdw1a(8BafAWGEc0p5IBpbAEM5Fi)weAp0RrXo5ceMSBaF(nGcnWcMCMdhiYy)Bzo5ceMSBavksnmAM4TyYfdROCLYuuclfxks5ceMSvPQi1tzYuHIebfcYHJ0rU4Npg3ilrD4gq8gqDd0)cY7P)6mCd4TbRAavnynnyTBWAAqsCuurgAR(trIJ0rU4NpgLPOCTvCPiLlqyYwLQICjGDVCYKdJIYvkYqB1FksizED9OypszIIudJMjElMCXWkkxPmfLeBfxks5ceMSvPQidTv)PiHK511JI9iLjks9uMmvOirqHGCiyFDAhkDds0alyYzo8JY8pK3Yep0pc2CYfimz3a(8BG(F2(5Co9FPF4fVLjEmDnLHDJSe1HBaXBWQgKOb6pTCXzURYZmpuiksnmAM4TyYfdROCLYuMIelgkTIlfLRuCPiLlqyYwLQIupLjtfks9NwU4m3j65z)SBqIgGPfgZBXKlg2zztGZ86WAaXBapAqIgO)fK3t)1z4gq8gaRgKObuObwPHVU8gKObuObiOqqoeSVoTdLwrgAR(trYqVy81HPRjS6pLPOmzfxks5ceMSvPQiH(XFcSBkkxPidTv)PiP)N5hb)OJwuMIskQ4srkxGWKTkvfPEktMkuKwWKZCqYemp0i36aJtUaHj7gKOb6)z7NZ5GKjyEOrU1bghkDds0ak0aeuiihosh5IF(yCO0nird0)cY7P)6mCd4UbRAqIgSFZnb8IZkn81L3GenG6gSFZXqVy81HPRjS6pNvA4RlVb853ak0alyYzog6fJVomDnHv)5KlqyYUbuPidTv)PiXr6ix8ZhJYuuYdfxks5ceMSvPQi1tzYuHI0cMCMdH9)2c2FyNCbct2nirdqqHGCiS)3wW(d72pNRbjAa1nqozYHPb82ak6GvdwtdKtMCyCJKlxd4Tbu3aEKKgSMgGGcb50mjgDGT6YDO0nGQgqvdiEdOUbRwbRgS(gKmfBWAAackeKRoDmxy1FE4Rl3)qElt8Rf0lNjou6gqvds0GqBvAXJyEBQ8CzWnGqdsIIm0w9NIK(FMFe8JoArzkkHLIlfPCbct2QuvK6PmzQqrAbtoZHW(FBb7pStUaHj7gKObiOqqoe2)Bly)HD7NZ1GenG6gO)fK3t)1z4gq8gaRgWNFdW0cJ5TyYfd7SSjWzEDynGqdw1aQuKH2Q)uK6GX8H2Q)8ScBkswHn)flIIeH9)2c2FyLPOCTvCPiLlqyYwLQIm0w9NIuhmMp0w9NNvytrYkS5VyruK6)z7NZPmfLeBfxks5ceMSvPQi1tzYuHIu)liVN(RZWnG7gqXgKObu3aeuiihc7)TfS)Wou6gWNFdOqdSGjN5qy)VTG9h2jxGWKDdOsrITP0MIYvkYqB1FksDWy(qB1FEwHnfjRWM)IfrrcvxHZKrzktrIeS40IIlfLRuCPiLlqyYwLQIupLjtfkseuiiNOzfnw84NfJB)CUgKObiOqqorZkAS4zOxmU9Z5AqIgqDdgbAeCwGWKgWNFdOUbH2Q0IxozPeCd4UbRAqIgeARsl(9Bom6bvJ0aI3GqBvAXlNSucUbu1aQuKH2Q)uKy0dQgrzkktwXLIuUaHjBvQks9uMmvOirqHGCIMv0yXJFwmUrwI6WnG7gSkjnG3gOdS5TArAaF(nabfcYjAwrJfpd9IXnYsuhUbC3GvjPb82aDGnVvlIIm0w9NIeBXGrNCrzkkPOIlfPCbct2QuvK6PmzQqrIGcb5enROXINHEX4gzjQd3aUBGoWM3QfPb853aeuiiNOzfnw84NfJB)CUgKOb4NfJx0SIglnG7gKKgWNFdqqHGCIMv0yXJFwmU9Z5AqIgWqVy8IMv0yPbRVbH2Q)CCMWYC15HyvEM1aI3GvkYqB1FksSfdunIYuuYdfxks5ceMSvPQi1tzYuHIebfcYjAwrJfp(zX4gzjQd3aUBGoWM3QfPb853aeuiiNOzfnw8m0lg3(5CnirdyOxmErZkAS0G13GqB1FootyzU68qSkpZAa3nijkYqB1FksotyzktzkYTafOmtXLIYvkUuKYfimzRsvrQNYKPcfjckeKB5)d(68q)S4qPBqIgqHgSh0A7EomosKw86WuKyBkTPOCLIm0w9NICqpFOT6ppRWMIKvyZFXIOircwCArzkktwXLIuUaHjBvQks9uMmvOi3dATDphghjslEDyksSnL2uuUsrgAR(trQdgZhAR(ZZkSPizf28xSikYNdJJePfLPOKIkUuKYfimzRsvrUfSEkAR(trsS48CynGtMCsAzAa9JXfctuKH2Q)uK0ZZHPmfL8qXLIuUaHjBvQks9uMmvOirqHGC6W8q)S42pNtrgAR(trAvUmype6aJYuuclfxks5ceMSvPQi1tzYuHIebfcYPdZd9ZIB)CofzOT6pfPomp0plktr5AR4srkxGWKTkvf5wW6POT6pfjp7KgGZERbytcMLPidTv)Pih0ZhAR(ZZkSPiX2uAtr5kfPEktMkuKiOqqoCwSFolcB7qPBaF(nabfcYrpphMdLwrYkS5VyruKytcMLPmfLeBfxkYqB1Fksm8OmMhjWzks5ceMSvPQmfL8CkUuKYfimzRsvrQNYKPcfzOTkT43V5MIUbeAqsuKyBkTPOCLIm0w9NIuhmMp0w9NNvytrYkS5VyruKyXqPvMIsIfuCPiLlqyYwLQIm0w9NIuhmMp0w9NNvytrYkS5VyruK6)z7NZPmfLRsIIlfPCbct2QuvKH2Q)uKtrRi3cwpfTv)PiPu0ZZ(zdBBW6gyRbuSb)0aE0a9VG8nG(RZAWu04g8xdW1LZKgyXKlwdEudxBPbpudqKbld8n4NgSrN6YBaImyzGVbfudGKjynaAKBDGPbfUbO0nGNbBAqqtZGPbrdGLMUbWMIUbCYKRbCXtAqHBakDdIB3aofJ1a8)xdGcgRbpeKtrQNYKPcfP(tlxCM7e98SF2nirdOUbuObwWKZCiS)3wW(d7KlqyYUb853aeuiihc7)TfS)Wou6gqvds0amTWyElMCXWolBcCMxhwdi0GvnirdOUb6Fb590FDgUbC3GKBqIgmc0i4SaHjnird2dATDtr7Ssdp2Nh1jB)F(rGgbN1aUBq6yQaHjUPO9wPHh3GenG6gqHgGGcb5qW(60ou6gWNFd0)Z2pNZHG91PDO0nGp)gqDdqqHGCiyFDAhkDds0a9)S9Z5CqYemp0i36aJdLUbu1aQAaF(nq)liVN(RZWnGqdGvds0aeuiiNv5YG9qOdmou6gKObiOqqoRYLb7HqhyCJSe1HBaXBapAqIgSh0A7MI2zLgESppQt2()8JancoRbC3ay1aQuMIYvRuCPiLlqyYwLQIupLjtfks9VG8E6Vod3aUj0aQBaSAW6Bq6yQaHjoOhD00EKYKgqLIeBtPnfLRuKH2Q)uKd65dTv)5zf2uKScB(lwefjuDfotgLPOCvYkUuKYfimzRsvrQNYKPcf5EqRTJEQLG55mHL5Ssdp2Nh1jB)F(rGgbN1aUj0GKtsds0a9VG8E6Vod3aUj0GKvKH2Q)uK0tTempNjSmfjRoXR3ksyPmfLROOIlfPCbct2QuvKBbRNI2Q)uK88OmRwFUE3aSjbZYuKH2Q)uK6GX8H2Q)8ScBksSnL2uuUsrQNYKPcfjckeKdb7Rt7qPvKScB(lwefj2KGzzktr5kEO4srkxGWKTkvf5wW6POT6pfjxzsdwES1ab2PLdxPLgKkxnqdJMjnGAUYgbN1aYSr2nGKtrlnq)yRbRwbRgiNm5Waxdwc4LgGrhPbCKgOJRblb8sdSSWAqDnGhniN9ibdtLIelAfj1nG6gSAfSAW6BqYuSbRPbiOqqU60XCHv)5HVUC)d5TmXVwqVCM4qPBavny9nG6giNm5W40OZiN1aEBafDWQbRPbYjtomUrYLRb82aQBapssdwtdqqHGCAMeJoWwD5ou6gqvdOQbu1GuAGCYKdJBKC5uKH2Q)uKCIYuK6PmzQqrAbtoZHW(FBb7pStUaHj7gKObiOqqoe2)Bly)HD7NZ1Geni0wLw8iM3MkpxgCdi0GKOmfLRGLIlfPCbct2QuvK6PmzQqrAbtoZHW(FBb7pStUaHj7gKObiOqqoe2)Bly)HD7NZPidTv)Pih0ZhAR(ZZkSPizf28xSikse2)Bly)HvMIYvRTIlfPCbct2QuvKH2Q)uKqY866rXEKYefPEktMkuKiOqqUGwGDp9i7W(b71tKUUChkTIudJMjElMCXWkkxPmfLRi2kUuKYfimzRsvrc9J)ey3uuUsrgAR(trs)pZpc(rhTOmfLR45uCPiLlqyYwLQIm0w9NICc4ffPEktMkuKu3GrGgbNfimPb853aAzWf2KZ8lOmROzLmnG7gSFZnb8IJEbLzfnRKPbu1GenypO12nb8IZkn8yFEuNS9)5hbAeCwd4UbyAHX8wm5IHDyofT41H1G10GKBW6BqYksnmAM4TyYfdROCLYuuUIybfxks5ceMSvPQidTv)PizOxm(6W01ew9NIupLjtfksQBWiqJGZceM0a(8BaTm4cBYz(fuMv0SsMgWDd2V5yOxm(6W01ew9NJEbLzfnRKPbu1GenypO12XqVy81HPRjS6pNvA4X(8Ooz7)Zpc0i4SgWDdW0cJ5TyYfd7WCkAXRdRbRPbj3G13GKvKAy0mXBXKlgwr5kLPOm5KO4srkxGWKTkvfj0p(tGDtr5kfzOT6pfj9)m)i4hD0IYuuM8kfxks5ceMSvPQidTv)PiTSjWzEDyks9uMmvOihbAeCwGWKgKOb7bT2olBcCMxhMZkn8yFEuNS9)5hbAeCwd4Ubu3aE0aEBaMwymVftUyyNLnboZRdRbRPb8Obu1GuAa1nyvd4Tblb2KbgF6GHknGQgS(gO)BJwMZcSjEOF8iS)3o5ceMSBW6BG(tlxCM7e98SF2nirdOUbuObiOqqoeSVoTdLUb853amTWyElMCXWolBcCMxhwd4UbRAavksnmAM4TyYfdROCLYuuMCYkUuKYfimzRsvrc9J)ey3uuUsrgAR(trs)pZpc(rhTOmfLjtrfxks5ceMSvPQi1tzYuHIK6gmrT9sA5mxS3yxDnG7gqDdw1aEBWsa7EDwm5cUbRVb6SyYfShAcTv)fSgqvdwtdgrNftU4TArAavnirdOUbyAHX8wm5IHDidQfmpMf4SgSMgeAR(ZHmOwW8ywGZC7yjYLgKsdcTv)5qgulyEmlWzo9JTgqvd4Ubu3GqB1FoC2iB3owICPbP0GqB1FoC2iBN(XwdOsrgAR(trImOwW8ywGZuMIYK5HIlfPCbct2QuvK6PmzQqrIPfgZBXKlg2H5u0Ixhwd4UbRAaVnabfcYHG91PDO0nynnizfzOT6pfjMtrlEDyktrzYWsXLIuUaHjBvQks9uMmvOiX0cJ5TyYfd7SSjWzEDynG7gqrfzOT6pfPLnboZRdtzkktETvCPiLlqyYwLQIupLjtfkseuiiNMjXOdSvxUdLUbjAa1nabfcYHr3B58XcckoZTFoxds0aeuiihol2pNfHTD7NZ1a(8BackeKdb7Rt7qPBavkYqB1FksC2iBLPOmzITIlfPCbct2QuvKH2Q)uK6GX8H2Q)8ScBkswHn)flIIeQymzuMYuK0JO)fKWuCPOCLIlfPCbct2QuvKpTIelMIm0w9NImDmvGWefz6GHkkYKOithJ)Ifrrc9OJM2JuMOmfLjR4srkxGWKTkvf5tRiXIPidTv)PithtfimrrMoyOIICLICly9u0w9NIKmBKDdi0GKaxdO8V1JVGgN9wdGnb8sdi0GvW1aYlOXzV1aytaV0acniz4AWALNUbeAafHRbKCkAPbeAapuKPJXFXIOiHkgtgLPOKIkUuKYfimzRsvr(0ksSykYqB1FkY0XubctuKPdgQOij2kY0X4VyruKtr7Tsdpwzkk5HIlfzOT6pfj81Thz7X01ugwrkxGWKTkvLPOewkUuKH2Q)uKiVzmz7HybmYMtD5E7H96uKYfimzRsvzkkxBfxks5ceMSvPQi1tzYuHIe)OmK62oAuSHYeVmO0w9NtUaHj7gWNFdWpkdPUTl9ZcRyIh)S0Yzo5ceMSvKH2Q)uKqmbNPNaYuMIsITIlfPCbct2QuvK6PmzQqrIGcb5w()GVop0plU9Z5uKH2Q)uK0ZZHPmfL8CkUuKYfimzRsvrQNYKPcfjckeKB5)d(68q)S42pNtrgAR(trQdZd9ZIYuMIeQymzuCPOCLIlfPCbct2QuvKH2Q)uKtaVOi1tzYuHImDmvGWehuXyY0acnyvds0GrGgbNfimPbjAW(n3eWlo6fuMv0SsMgqCcnyLl5gSMgqldUWMCMFbLzfnRKrrQHrZeVftUyyfLRuMIYKvCPiLlqyYwLQIupLjtfkY0XubctCqfJjtdi0GKvKH2Q)uKtaVOmfLuuXLIuUaHjBvQks9uMmvOithtfimXbvmMmnGqdOOIm0w9NIKHEX4Rdtxty1FktrjpuCPiLlqyYwLQIupLjtfkY0XubctCqfJjtdi0aEOidTv)PiXCkAXRdtzkkHLIlfPCbct2QuvK6PmzQqrIGcb5WO7TC(ybbfN52pNtrgAR(trIZgzRmLPiXMemltXLIYvkUuKYfimzRsvrc9J)ey3uuUsrgAR(trs)pZpc(rhTOmfLjR4srkxGWKTkvfzOT6pf5eWlksnmAM4TyYfdROCLIupLjtfksQBW(n3eWlo6fuMv0SsMgq8gSYbRgWNFdgbAeCwGWKgqvds0G9GwB3eWloR0WJ95rDY2)NFeOrWznG7gKCd4ZVbu3aAzWf2KZ8lOmROzLmnG7gSFZnb8IJEbLzfnRKPbjAackeKdb7Rt7qPBqIgGPfgZBXKlg2zztGZ86WAaXBafBqIgO)0YfN5orpp7NDdOQb853aeuiihc2xN2nYsuhUbeVbRuKBbRNI2Q)uKWMaEPbNiBCdMhnpJbtdGvsiwBWd1GYWnGjxUL1GWAq0GL6Qf0LgyFdWOdDGXnaNnYg3GnTOmfLuuXLIuUaHjBvQks9uMmvOiX0cJ5TyYfd7SSjWzEDynG4nGInirdgbAeCwGWKgKOb7bT2og6fJVomDnHv)5Ssdp2Nh1jB)F(rGgbN1aUBaSAqIgqDd0)cY7P)6mCdi0aE0a(8BW(nhd9IXxhMUMWQ)CJSe1HBaXBaSAaF(nGcny)MJHEX4Rdtxty1FoR0WxxEdOsrgAR(trYqVy81HPRjS6pLPOKhkUuKYfimzRsvrgAR(trImOwW8ywGZuKBbRNI2Q)uKPoOwWAajlWznOWnarmtMgyzX1aSjbZYAaz2i7gewdOydSyYfdRi1tzYuHIetlmM3IjxmSdzqTG5XSaN1aUBqYktrjSuCPiLlqyYwLQIe6h)jWUPOCLIm0w9NIK(FMFe8JoArzkkxBfxks5ceMSvPQi1tzYuHIu)liVN(RZWnG4nGhnirdW0cJ5TyYfd7SSjWzEDynG4nawkYqB1FksC2iBLPmfP(F2(5CkUuuUsXLIuUaHjBvQkYqB1FkYyh0wLw8yoXSOi1tzYuHIK6gqDdOqd2V5IDqBvAXJ5eZIFhlrU4SsdFD5nGp)gSFZf7G2Q0IhZjMf)owICXnYsuhUbeVbj3aQAqIgqDd2V5IDqBvAXJ5eZIFhlrU4WwOHVbeVbuSb853ak0G9BUyh0wLw8yoXS4ZKG5WwOHVbC3GvnGQgKObuObH2Q)CXoOTkT4XCIzXNjbZvNhIv5zwds0ak0GqB1FUyh0wLw8yoXS43XsKlU68qSkpZAqIgqHgeAR(Zf7G2Q0IhZjMfxDEiwLNznGQgKObwm5I5SAr8273L0aUBaSAaF(ni0wLw8YjlLGBa3ni5gKObuOb73CXoOTkT4XCIzXVJLixCwPHVU8gKObYjtomnG4nGIWQbjAGftUyoRweV9(DjnG7galfPggnt8wm5IHvuUszkktwXLIuUaHjBvQkYTG1trB1FkY1nWwd4QYLjPWnGNGoW0aeb6hPbu)tdQLfzxHXGPbbKjdvnqhyRU8gWtKjynGNmYToW0GcQbPkdwg4BqHBaL8mUAWFnq)pB)CoNIedZPvKqYemp0i36aJIupLjtfks9)S9Z5CiyFDAhkTIm0w9NI0QCzWEi0bgLPOKIkUuKYfimzRsvrgAR(trcjtW8qJCRdmks9uMmvOi1)cY7P)6mCdiEdOyds0alMCXCwTiE797sAa3nGy3GenG6gGGcb5Wr6ix8ZhJdLUb853ak0alyYzoCKoYf)8X4KlqyYUbu1GenG6gqHgO)NTFoNZQCzWEi0bghkDd4ZVb6)z7NZ5qW(60ou6gqvd4ZVbipg3GenaQYZm)ilrD4gq8gWZ1GenaQYZm)ilrD4gWDdswrQHrZeVftUyyfLRuMIsEO4srkxGWKTkvfzOT6pfjImyzGxrUfSEkAR(trYfpJNINbBBaLISBG9nadZPBaNYYAaNYYAWePL7rXnaAKBDGPbCYKRbCKgmOxdGg5whyqIBdxd(PbHXKaBnqNjA4Bqb1GYWnGZpwwdktrQNYKPcfP(xqEp9xNHBa3eAafvMIsyP4srkxGWKTkvfPEktMkuK6Fb590FDgUbCtObuurgAR(trwNoMlS6pLPOCTvCPiLlqyYwLQIm0w9NI0QCzWEi0bgf5wW6POT6pfjxdmniUDdU3AaNaBsd4IN0a5Kjhg4AacQ1GGH)gSwqXwdqXsdkRbq)0G1rg4BqC7guNoMdRi1tzYuHIuozYHXTfOsxwd4Ub8ijnGp)gGGcb5qW(60ou6gWNFdOUbwWKZC0JSd7hNCbct2nirdWz)yc28MTBaXBafBavktrjXwXLIuUaHjBvQkYqB1FksCwSFolcBRi3cwpfTv)Pi55R8mRbisd4m)L3a7BakwAa5IW2n4VgaBc4LguxdsldmniTmW0GR0zsdWLHgw9hgUgGGAniTmW0GjgHbJIupLjtfkseuiiNv5YG9qOdmou6gKObiOqqoeSVoTB)CUgKOb6Fb590FDgUbeVb8ObjAackeKdJU3Y5JfeuCMB)CUgKOb73CtaV4OxqzwrZkzAaXBWk3A3GenqozYHPbC3aEKKgKOb7bT2UjGxCwPHh7ZJ6KT)p)iqJGZAa3natlmM3IjxmSdZPOfVoSgSMgKCdwFdsUbjAGftUyoRweV9(DjnG7galLPOKNtXLIuUaHjBvQks9uMmvOirqHGCwLld2dHoW4qPBaF(nabfcYHG91PDO0kYqB1FksezWYaFD5ktrjXckUuKYfimzRsvrQNYKPcfjckeKdb7Rt7qPBaF(na5X4gKObqvEM5hzjQd3aI3a9)S9Z5CiyFDA3ilrD4gWNFdqEmUbjAauLNz(rwI6WnG4nizyPidTv)PiPFR(tzkkxLefxks5ceMSvPQi1tzYuHIebfcYHG91PDO0nGp)gav5zMFKLOoCdiEdsELIm0w9NICI0Y9Oyp0i36aJYuuUALIlfPCbct2QuvKH2Q)uK6)s)WlElt8y6AkdRi3cwpfTv)Pi5INXtXZGTnyDZen8ny5)d(6Aq2BCAqC7gGnuiOgWk4LgyzfgUge3UblbmisdqeZKPb6FbjSgmYsuxdgbdZPvK6PmzQqrsDd2V5MI2nYsuhUbC3aE0Genq)liVN(RZWnG4nawnirdOUb73CtaV4SsdFD5nGp)gGPfgZBXKlg2zztGZ86WAa3nyvdOQbjAGCYKdJBlqLUSgWnHgKCsAavnGp)gG8yCds0aOkpZ8JSe1HBaXBaSuMIYvjR4srkxGWKTkvfzOT6pfPSq)CKXJ83wrUfSEkAR(trYZhWGinWYKrAao7rz7gGiny5hPb6)2Lv)HBWFnWYKgO)BJwMIupLjtfkseuiiNv5YG9qOdmou6gWNFdOUb6)2OL52Iq7dgtYR40ItUaHj7gqLYuuUIIkUuKYfimzRsvrUfSEkAR(trM0uPLgqp1pLbtdSVb)TEuS0aosq)NI8IfrrUwEd9YLAg)wWwDWG96GXuK6PmzQqrkjTOfnTSDRL3qVCPMXVfSvhmyVoymfzOT6pf5A5n0lxQz8BbB1bd2RdgtzkkxXdfxkYqB1FksuS4ltwWks5ceMSvPQmLPiFomosKwuCPOCLIlfPCbct2QuvK6PmzQqrIGcb5YKym)d5TmXZPyBhkTIm0w9NIeBXGrNCrzkktwXLIuUaHjBvQkYqB1Fksm6bvJOiz1jE9wrYJ1KR3ktrjfvCPiLlqyYwLQIm0w9NIC5)dQgrrQNYKPcfjckeKB5)d(68q)S4qPBqIgGPfgZBXKlg2zztGZ86WAaXBqYnirdOqdSGjN5yOxm(6W01ew9NtUaHjBfjRoXR3ksESMC9wzkk5HIlfPCbct2QuvK6PmzQqrkNm5W0aI3akMKgKOb73Ctr7gzjQd3aUBapCWQbjAa1nq)pB)CoNv5YG9qOdmUrwI6WnGBcnyTDWQb853Gb9eOFYfNombgXRrN6DYfimz3aQAqIgGGcb50mjgDGT6YDyl0W3aI3GvnirdOqdqqHGCbTa7E6r2H9d2RNiDD5ou6gKObuObiOqqoe2)Bgk2CO0nirdOqdqqHGCiyFDAhkDds0aQBG(F2(5Co9FPF4fVLjEmDnLHDJSe1HBa3nyTDWQb853ak0a9NwU4m3v5zMhkKgqvds0aQBafAG(tlxCM7e98SF2nGp)gO)NTFoNl2bTvPfpMtmlUrwI6WnGBcnawnGp)gSFZf7G2Q0IhZjMf)owICXnYsuhUbC3aIDdOsrgAR(trMjXy(hYBzINtX2ktrjSuCPiLlqyYwLQIupLjtfks5KjhMgq8gqXK0Geny)MBkA3ilrD4gWDd4HdwnirdOUb6)z7NZ5SkxgShcDGXnYsuhUbCtOb8WbRgWNFdg0tG(jxC6WeyeVgDQ3jxGWKDdOQbjAackeKtZKy0b2Ql3HTqdFdiEdw1GenGcnabfcYf0cS7Phzh2pyVEI01L7qPBqIgqHgGGcb5qy)VzOyZHs3GenG6gqHgGGcb5qW(60ou6gWNFd0FA5IZCNONN9ZUbjAGfm5mhosh5IF(yCYfimz3GenabfcYHG91PDJSe1HBa3nyTBavnirdOUb6)z7NZ50)L(Hx8wM4X01ug2nYsuhUbC3G12bRgWNFdOqd0FA5IZCxLNzEOqAavnirdOUbuOb6pTCXzUt0ZZ(z3a(8BG(F2(5CUyh0wLw8yoXS4gzjQd3aUj0ay1a(8BW(nxSdARslEmNyw87yjYf3ilrD4gWDdi2nGQgKObqvEM5hzjQd3aUBaXwrgAR(trU8)bFDEOFwuMYuMImTm46pfLjNKKtojjNCYksoXC1LJvKelt6HnuYttzsdSTbnGRmPb1c9pwdG(PbjfuDfotMKQbJK0IwJSBa(xKgeO2VeMSBGolUCb7AIwR1jnGhW2gSU)Lwgt2niPg0tG(jxCjDjvdSVbj1GEc0p5IlPZjxGWKDs1aQxb7u5AIAIiwM0dBOKNMYKgyBdAaxzsdQf6FSga9tdsQTafOmlPAWijTO1i7gG)fPbbQ9lHj7gOZIlxWUMO1ADsdsEfSTbR7FPLXKDdiRL1TbyyolG9gqS2a7BWAfnAWUsx46Vg80Ye2pnG6uOQbuVc2PY1eTwRtAqYue22G19V0YyYUbK1Y62ammNfWEdiwBG9nyTIgnyxPlC9xdEAzc7NgqDku1aQtg2PY1e1erSmPh2qjpnLjnW2g0aUYKgul0)yna6NgKuiS)3wW(dNunyKKw0AKDdW)I0Ga1(LWKDd0zXLlyxt0AToPbue22G19V0YyYUbK1Y62ammNfWEdiwBG9nyTIgnyxPlC9xdEAzc7NgqDku1aQxb7u5AIAIiwM0dBOKNMYKgyBdAaxzsdQf6FSga9tdsQNdJJePLKQbJK0IwJSBa(xKgeO2VeMSBGolUCb7AIwR1jnGhW2gSU)Lwgt2niPg0tG(jxCjDjvdSVbj1GEc0p5IlPZjxGWKDs1aQxb7u5AIwR1jnawW2gSU)Lwgt2niPg0tG(jxCjDjvdSVbj1GEc0p5IlPZjxGWKDs1aQxb7u5AIAI4PxO)XKDdwLKgeAR(RbScByxtKIKEEOIjksIHyAaprMG1aEQbT2nredX0aEIGmOXatdsgwW1GKtsYj3e1ermetdw3S4YfmSTjIyiMgS(gSh0A7EomosKw86WiSQb6mrdpUb23G9GwB3ZHXrI0IxhMRjIyiMgS(gSU)LwgRbPYvdO)N5hb)OJwAG9nGtuwdeyNEemU(Z1ermetdwFds637guNjZGsBfctAapHj4m9eqwdkOgaZJ2GSiT0G7TS6YBGWWsdSVb731ermetdwFd4P(lPSgK9SDdw3)s)Wlna6NgaBk6gGEmbJBampAsXynyKGXGPbWMI21e1efAR(d7Ohr)liHXlHushtfimbUlwecqp6OP9iLjWLoyOcHK0ermnGmBKDdi0GKaxdO8V1JVGgN9wdGnb8sdi0GvW1aYlOXzV1aytaV0acniz4AWALNUbeAafHRbKCkAPbeAapAIcTv)HD0JO)fKW4LqkPJPceMa3flcbOIXKbU0bdviSQjk0w9h2rpI(xqcJxcPKoMkqycCxSieMI2BLgEmCPdgQqGy3efAR(d7Ohr)liHXlHuGVU9iBpMUMYWnrH2Q)Wo6r0)csy8sifK3mMS9qSagzZPUCV9WEDnrH2Q)Wo6r0)csy8sifiMGZ0tazWvqeWpkdPUTJgfBOmXldkTv)5KlqyYMpF8JYqQB7s)SWkM4XplTCMtUaHj7MOqB1Fyh9i6FbjmEjKc98CyWvqeqqHGCl)FWxNh6Nf3(5CnrH2Q)Wo6r0)csy8sifDyEOFwGRGiGGcb5w()GVop0plU9Z5AIAIcTv)HjmONp0w9NNvydUlwecibloTah2MsBewbxbrabfcYT8)bFDEOFwCO0jOWEqRT75W4irAXRdRjk0w9hMxcPOdgZhAR(ZZkSb3flcHNdJJePf4W2uAJWk4kic7bT2UNdJJePfVoSMiIPbelophwd4KjNKwMgq)yCHWKMOqB1FyEjKc98CynrH2Q)W8sifRYLb7HqhyGRGiGGcb50H5H(zXTFoxtuOT6pmVesrhMh6Nf4kiciOqqoDyEOFwC7NZ1ermetdcTv)H5LqkPJPceMa3flcbC2pMGnVzB4shmuHGftUyoRweV9(DjnredX0GqB1FyEjKIggnRUCF6yQaHjWDXIqaN9JjyZB2gUNMWsDWLoyOcblMCXCwTiE797sAIiMgWZoPb4S3Aa2KGzznrH2Q)W8siLb98H2Q)8ScBWDXIqaBsWSm4W2uAJWk4kiciOqqoCwSFolcB7qP5ZhbfcYrpphMdLUjk0w9hMxcPGHhLX8iboRjk0w9hMxcPOdgZhAR(ZZkSb3flcbSyO0WHTP0gHvWvqecTvPf)(n3u0esstuOT6pmVesrhmMp0w9NNvydUlwec6)z7NZ1ermnGsrpp7NnSTbRBGTgqXg8td4rd0)cY3a6VoRbtrJBWFnaxxotAGftUyn4rnCTLg8qnargSmW3GFAWgDQlVbiYGLb(guqnasMG1aOrU1bMgu4gGs3aEgSPbbnndMgenawA6gaBk6gWjtUgWfpPbfUbO0niUDd4umwdW)FnakySg8qqUMOqB1FyEjKYu0Wvqe0FA5IZCNONN9Zob1uWcMCMdH9)2c2FyNCbct285JGcb5qy)VTG9h2HstvcmTWyElMCXWolBcCMxhgHvjOw)liVN(RZWCNCIrGgbNfimjXEqRTBkANvA4X(8Ooz7)Zpc0i4mUthtfimXnfT3kn84eutbeuiihc2xN2HsZNV(F2(5CoeSVoTdLMpFQrqHGCiyFDAhkDc9)S9Z5CqYemp0i36aJdLMkQ4Zx)liVN(RZWeGvceuiiNv5YG9qOdmou6eiOqqoRYLb7HqhyCJSe1HjopsSh0A7MI2zLgESppQt2()8JancoJByrvtuOT6pmVeszqpFOT6ppRWgCxSieGQRWzYah2MsBewbxbrq)liVN(RZWCtGAyT(0XubctCqp6OP9iLju1efAR(dZlHuONAjyEotyzWvqe2dATD0tTempNjSmNvA4X(8Ooz7)Zpc0i4mUjKCssO)fK3t)1zyUjKmCS6eVEtawnretd45rzwT(C9UbytcML1efAR(dZlHu0bJ5dTv)5zf2G7IfHa2KGzzWHTP0gHvWvqeqqHGCiyFDAhkDteX0aUYKgS8yRbcStlhUslnivUAGggntAa1CLncoRbKzJSBajNIwAG(XwdwTcwnqozYHbUgSeWlnaJosd4inqhxdwc4LgyzH1G6AapAqo7rcgMQMOqB1FyEjKcNOm4WIMa1uVAfSwFYuCniOqqU60XCHv)5HVUC)d5TmXVwqVCM4qPPA9ulNm5W40OZiNXlfDWAnYjtomUrYLJxQ5rswdckeKtZKy0b2Ql3HstfvuLICYKdJBKC5GRGiybtoZHW(FBb7pStUaHj7eiOqqoe2)Bly)HD7NZLi0wLw8iM3MkpxgmHK0ermetdcTv)H5Lqk0)Z8JGF0rlWvqeSGjN5qy)VTG9h2jxGWKDceuiihc7)TfS)WU9Z5sqTCYKddVu0bR1iNm5W4gjxoEPMhjzniOqqontIrhyRUChknvurCQxTcwRpzkUgeuiixD6yUWQ)8WxxU)H8wM4xlOxotCO0uLi0wLw8iM3MkpxgmHK0efAR(dZlHug0ZhAR(ZZkSb3flcbe2)Bly)HHRGiybtoZHW(FBb7pStUaHj7eiOqqoe2)Bly)HD7NZ1efAR(dZlHuGK511JI9iLjWPHrZeVftUyycRGRGiGGcb5cAb290JSd7hSxpr66YDO0nrH2Q)W8sif6)z(rWp6Of4G(XFcSBew1efAR(dZlHuMaEbonmAM4TyYfdtyfCfebQhbAeCwGWe(8PLbxytoZVGYSIMvYW9(n3eWlo6fuMv0SsgQsSh0A7MaEXzLgESppQt2()8JancoJBmTWyElMCXWomNIw86WwtYRp5MOqB1FyEjKcd9IXxhMUMWQ)GtdJMjElMCXWewbxbrG6rGgbNfimHpFAzWf2KZ8lOmROzLmCVFZXqVy81HPRjS6ph9ckZkAwjdvj2dATDm0lgFDy6AcR(ZzLgESppQt2()8JancoJBmTWyElMCXWomNIw86WwtYRp5MOqB1FyEjKc9)m)i4hD0cCq)4pb2ncRAIcTv)H5Lqkw2e4mVom40WOzI3IjxmmHvWvqegbAeCwGWKe7bT2olBcCMxhMZkn8yFEuNS9)5hbAeCg3uZdEX0cJ5TyYfd7SSjWzEDyRHhurSs9kExcSjdm(0bdvOA96)2OL5SaBIh6hpc7)TtUaHj71R)0YfN5orpp7NDcQPackeKdb7Rt7qP5ZhtlmM3IjxmSZYMaN51HX9kQAIcTv)H5Lqk0)Z8JGF0rlWb9J)ey3iSQjk0w9hMxcPGmOwW8ywGZGRGiq9e12lPLZCXEJD1Xn1R4DjGDVolMCbVEDwm5c2dnH2Q)cgvRzeDwm5I3QfHQeuJPfgZBXKlg2HmOwW8ywGZwtOT6phYGAbZJzboZTJLixiwdTv)5qgulyEmlWzo9JnQ4M6qB1FoC2iB3owICHyn0w9NdNnY2PFSrvtuOT6pmVesbZPOfVom4kicyAHX8wm5IHDyofT41HX9kErqHGCiyFDAhk9AsUjk0w9hMxcPyztGZ86WGRGiGPfgZBXKlg2zztGZ86W4MInrH2Q)W8sifC2iB4kiciOqqontIrhyRUChkDcQrqHGCy09woFSGGIZC7NZLabfcYHZI9ZzryB3(5C85JGcb5qW(60ouAQAIcTv)H5Lqk6GX8H2Q)8ScBWDXIqaQymzAIAIcTv)HDiS)3wW(dtyc4f40WOzI3IjxmmHvWvqeOMcwPHVUC(8PELl51qldUWMCMFbLzfnRKHBc73CtaV4OxqzwrZkzOIpFQdTvPfpI5TPYZLbti5eJancolqycvuLabfcYHy(jGxC7NZ1efAR(d7qy)VTG9hMxcPWqVy81HPRjS6p40WOzI3IjxmmHvWvqegbAeCwGWKeiOqqoeZV8)bvJ42pNRjk0w9h2HW(FBb7pmVesXYMaN51HbNggnt8wm5IHjScUcIWiqJGZceMKabfcYHyElBcCMB)CUe7bT2olBcCMxhMZkn8yFEuNS9)5hbAeCg3uZdEX0cJ5TyYfd7SSjWzEDyRHhurSs9kExcSjdm(0bdvOA96)2OL5SaBIh6hpc7)TtUaHj7MOqB1Fyhc7)TfS)W8sifKb1cMhZcCgCfebeuiihI5rgulyEmlWzU9Z5AIcTv)HDiS)3wW(dZlHuWCkAXRddUcIackeKdX8yofT42pNlbMwymVftUyyhMtrlEDyCVQjk0w9h2HW(FBb7pmVesbNnYgUcIackeKdX84Sr2U9Z5AIcTv)HDiS)3wW(dZlHuWCkAXRddUcIackeKdX8yofT42pNRjk0w9h2HW(FBb7pmVesXYMaN51HbxbrabfcYHyElBcCMB)CUMOMOqB1FyN(F2(5CeIDqBvAXJ5eZcCAy0mXBXKlgMWk4kicutnf2V5IDqBvAXJ5eZIFhlrU4SsdFD585VFZf7G2Q0IhZjMf)owICXnYsuhM4jtvcQ3V5IDqBvAXJ5eZIFhlrU4WwOHN4uKpFkSFZf7G2Q0IhZjMfFMemh2cn8CVIQeui0w9Nl2bTvPfpMtml(mjyU68qSkpZsqHqB1FUyh0wLw8yoXS43XsKlU68qSkpZsqHqB1FUyh0wLw8yoXS4QZdXQ8mJQewm5I5SAr8273LWnS4Zp0wLw8YjlLG5o5euy)Ml2bTvPfpMtml(DSe5IZkn81LNqozYHH4uewjSyYfZz1I4T3VlHBy1ermetdcTv)HD6)z7NZXlHuGycotpbKbxbrGA8JYqQB7OrXgkt8YGsB1F85JFugsDBx6NfwXep(zPLZOcU6mzguAZxllYUctiScU6mzguAZNZEKGryfC1zYmO0MVGiGFugsDBx6NfwXep(zPLZAIiMgSUb2AaxvUmjfUb8e0bMgGiq)inG6FAqTSi7kmgmniGmzOQb6aB1L3aEImbRb8KrU1bMguqnivzWYaFdkCdOKNXvd(Rb6)z7NZ5AIcTv)HD6)z7NZXlHuSkxgShcDGbommNMaKmbZdnYToWaxbrq)pB)Cohc2xN2Hs3efAR(d70)Z2pNJxcPajtW8qJCRdmWPHrZeVftUyycRGRGiO)fK3t)1zyItXewm5I5SAr8273LWnXob1iOqqoCKoYf)8X4qP5ZNcwWKZC4iDKl(5JXjxGWKnvjOMc6)z7NZ5SkxgShcDGXHsZNV(F2(5CoeSVoTdLMk(8rEmobuLNz(rwI6WeNNlbuLNz(rwI6WCNCteX0aU4z8u8myBdOuKDdSVbyyoDd4uwwd4uwwdMiTCpkUbqJCRdmnGtMCnGJ0Gb9Aa0i36adsCB4AWpnimMeyRb6mrdFdkOgugUbC(XYAqznrH2Q)Wo9)S9Z54LqkiYGLbE4kic6Fb590FDgMBcuSjk0w9h2P)NTFohVesPoDmxy1FWvqe0)cY7P)6mm3eOyteX0aUgyAqC7gCV1aob2KgWfpPbYjtomW1aeuRbbd)nyTGITgGILguwdG(PbRJmW3G42nOoDmhUjk0w9h2P)NTFohVesXQCzWEi0bg4kicYjtomUTav6Y4MhjHpFeuiihc2xN2HsZNp1wWKZC0JSd7hNCbct2jWz)yc28MTjofPQjIyAapFLNznarAaN5V8gyFdqXsdixe2Ub)1aytaV0G6AqAzGPbPLbMgCLotAaUm0WQ)WW1aeuRbPLbMgmXimyAIcTv)HD6)z7NZXlHuWzX(5SiSnCfebeuiiNv5YG9qOdmou6eiOqqoeSVoTB)CUe6Fb590FDgM48ibckeKdJU3Y5JfeuCMB)CUe73CtaV4OxqzwrZkzi(k3ANqozYHHBEKKe7bT2UjGxCwPHh7ZJ6KT)p)iqJGZ4gtlmM3IjxmSdZPOfVoS1K86toHftUyoRweV9(DjCdRMOqB1FyN(F2(5C8sifezWYaFD5WvqeqqHGCwLld2dHoW4qP5ZhbfcYHG91PDO0nrH2Q)Wo9)S9Z54Lqk0Vv)bxbrabfcYHG91PDO085J8yCcOkpZ8JSe1HjU(F2(5CoeSVoTBKLOomF(ipgNaQYZm)ilrDyINmSAIcTv)HD6)z7NZXlHuMiTCpk2dnYToWaxbrabfcYHG91PDO085dv5zMFKLOomXtEvteX0aU4z8u8myBdw3mrdFdw()GVUgK9gNge3UbydfcQbScEPbwwHHRbXTBWsadI0aeXmzAG(xqcRbJSe11GrWWC6MOqB1FyN(F2(5C8sif9FPF4fVLjEmDnLHHRGiq9(n3u0UrwI6WCZJe6Fb590FDgM4Wkb173CtaV4SsdFD585JPfgZBXKlg2zztGZ86W4EfvjKtMCyCBbQ0LXnHKtcv85J8yCcOkpZ8JSe1HjoSAIiMgWZhWGinWYKrAao7rz7gGiny5hPb6)2Lv)HBWFnWYKgO)BJwwtuOT6pSt)pB)CoEjKISq)CKXJ83gUcIackeKZQCzWEi0bghknF(uR)BJwMBlcTpymjVItlo5ceMSPQjIyAqstLwAa9u)ugmnW(g836rXsd4ib9FnrH2Q)Wo9)S9Z54LqkOyXxMSa3flcH1YBOxUuZ43c2QdgSxhmgCfebjPfTOPLTBT8g6Ll1m(TGT6Gb71bJ1efAR(d70)Z2pNJxcPGIfFzYcUjQjk0w9h2bvmMmeMaEbonmAM4TyYfdtyfCfeH0XubctCqfJjdHvjgbAeCwGWKe73CtaV4OxqzwrZkzioHvUKxdTm4cBYz(fuMv0SsMMOqB1FyhuXyYWlHuMaEbUcIq6yQaHjoOIXKHqYnrH2Q)WoOIXKHxcPWqVy81HPRjS6p4kicPJPceM4GkgtgcuSjk0w9h2bvmMm8sifmNIwGRGiKoMkqyIdQymziWJMOqB1FyhuXyYWlHuWzJSHRGiGGcb5WO7TC(ybbfN52pNRjIyiMgeAR(d7GkgtgEjKcetWz6jGm4kic4hLHu32rJInuM4LbL2Q)CYfimzZNp(rzi1TDPFwyft84NLwoZjxGWKnC1zYmO0MVwwKDfMqyfC1zYmO0MpN9ibJWk4QZKzqPnFbra)OmK62U0plSIjE8ZslN1e1efAR(d7GQRWzYqG(FMFe8JoAboOF8Na7gHvnrH2Q)WoO6kCMm8sifCKoYf)8XaxbrabfcYHJ0rU4Npg3ilrDyItXMOqB1FyhuDfotgEjKc9ulbZZzcldUcIa17bT2o6PwcMNZewMZkn8yFEuNS9)5hbAeCg3uCnuJPfgZBXKlg2rp1sW8CMWY4DfvjW0cJ5TyYfd7ONAjyEotyzCVIk(8X0cJ5TyYfd7ONAjyEotyzCtnf5D1ASGjN5WbIm2)wMtUaHjBQAIcTv)HDq1v4mz4LqktrdNggnt8wm5IHjScUcIWiqJGZceMKypO12nfTZkn8yFEuNS9)5hbAeCg3PJPceM4MI2BLgECcQPgbfcYzvUmype6aJdLMpFkyLg(6YPkb1iOqqoe2)Bly)HDO085tblyYzoe2)Bly)HDYfimztfF(uWcMCMdhiYy)Bzo5ceMSPkb1yAHX8wm5IHD0tTempNjSmcR4ZNcwWKZC0tTempNjSmNCbct2uLG6qBvAXVFZnfnHKWNVvA4RlprOTkT43V5MIMWk(8PWGEc0p5IBpbAEM5Fi)weAp0RrX85tblyYzoCGiJ9VL5KlqyYMQMOqB1FyhuDfotgEjKcosh5IF(yGRGiGGcb5Wr6ix8ZhJBKLOomXPw)liVN(RZW8UIQ1S2Rjjok2efAR(d7GQRWzYWlHuGK511JI9iLjWTeWUxozYHHWk40WOzI3IjxmmHvnrH2Q)WoO6kCMm8sifizED9OypszcCAy0mXBXKlgMWk4kiciOqqoeSVoTdLoHfm5mh(rz(hYBzIh6hbBo5ceMS5Zx)pB)CoN(V0p8I3YepMUMYWUrwI6WeFvc9NwU4m3v5zMhkKMOMOqB1Fy3ZHXrI0cbSfdgDYf4kiciOqqUmjgZ)qElt8Ck22Hs3efAR(d7EomosKw4Lqky0dQgbowDIxVjWJ1KR3nrH2Q)WUNdJJePfEjKYY)huncCS6eVEtGhRjxVHRGiGGcb5w()GVop0plou6eyAHX8wm5IHDw2e4mVomINCckybtoZXqVy81HPRjS6pNCbct2nrH2Q)WUNdJJePfEjKsMeJ5FiVLjEofBdxbrqozYHH4umjj2V5MI2nYsuhMBE4GvcQ1)Z2pNZzvUmype6aJBKLOom3ewBhS4ZFqpb6NCXPdtGr8A0PEQsGGcb50mjgDGT6YDyl0Wt8vjOackeKlOfy3tpYoSFWE9ePRl3HsNGciOqqoe2)Bgk2CO0jOackeKdb7Rt7qPtqT(F2(5Co9FPF4fVLjEmDnLHDJSe1H5ETDWIpFkO)0YfN5UkpZ8qHqvcQPG(tlxCM7e98SF285R)NTFoNl2bTvPfpMtmlUrwI6WCtaw85VFZf7G2Q0IhZjMf)owICXnYsuhMBInvnrH2Q)WUNdJJePfEjKYY)h815H(zbUcIGCYKddXPyssSFZnfTBKLOom38WbReuR)NTFoNZQCzWEi0bg3ilrDyUjWdhS4ZFqpb6NCXPdtGr8A0PEQsGGcb50mjgDGT6YDyl0Wt8vjOackeKlOfy3tpYoSFWE9ePRl3HsNGciOqqoe2)Bgk2CO0jOMciOqqoeSVoTdLMpF9NwU4m3j65z)StybtoZHJ0rU4NpgNCbct2jqqHGCiyFDA3ilrDyUxBQsqT(F2(5Co9FPF4fVLjEmDnLHDJSe1H5ETDWIpFkO)0YfN5UkpZ8qHqvcQPG(tlxCM7e98SF285R)NTFoNl2bTvPfpMtmlUrwI6WCtaw85VFZf7G2Q0IhZjMf)owICXnYsuhMBInvjGQ8mZpYsuhMBIDtutuOT6pSdlgknbg6fJVomDnHv)bxbrq)PLloZDIEE2p7eyAHX8wm5IHDw2e4mVomIZJe6Fb590FDgM4WkbfSsdFD5jOackeKdb7Rt7qPBIcTv)HDyXqP5Lqk0)Z8JGF0rlWb9J)ey3iSQjk0w9h2HfdLMxcPGJ0rU4Npg4kicwWKZCqYemp0i36aJtUaHj7e6)z7NZ5GKjyEOrU1bghkDckGGcb5Wr6ix8ZhJdLoH(xqEp9xNH5EvI9BUjGxCwPHVU8euVFZXqVy81HPRjS6pNvA4RlNpFkybtoZXqVy81HPRjS6pNCbct2u1efAR(d7WIHsZlHuO)N5hb)OJwGRGiybtoZHW(FBb7pStUaHj7eiOqqoe2)Bly)HD7NZLGA5KjhgEPOdwRrozYHXnsUC8snpsYAqqHGCAMeJoWwD5ouAQOI4uVAfSwFYuCniOqqU60XCHv)5HVUC)d5TmXVwqVCM4qPPkrOTkT4rmVnvEUmycjPjk0w9h2HfdLMxcPOdgZhAR(ZZkSb3flcbe2)Bly)HHRGiybtoZHW(FBb7pStUaHj7eiOqqoe2)Bly)HD7NZLGA9VG8E6VodtCyXNpMwymVftUyyNLnboZRdJWkQAIcTv)HDyXqP5Lqk6GX8H2Q)8ScBWDXIqq)pB)CUMOqB1FyhwmuAEjKIoymFOT6ppRWgCxSieGQRWzYah2MsBewbxbrq)liVN(RZWCtXeuJGcb5qy)VTG9h2HsZNpfSGjN5qy)VTG9h2jxGWKnvnrnrH2Q)WoSjbZYiq)pZpc(rhTah0p(tGDJWQMiIPbWMaEPbNiBCdMhnpJbtdGvsiwBWd1GYWnGjxUL1GWAq0GL6Qf0LgyFdWOdDGXnaNnYg3GnT0efAR(d7WMemlJxcPmb8cCAy0mXBXKlgMWk4kicuVFZnb8IJEbLzfnRKH4RCWIp)rGgbNfimHQe7bT2UjGxCwPHh7ZJ6KT)p)iqJGZ4oz(8PMwgCHn5m)ckZkAwjd373CtaV4OxqzwrZkzsGGcb5qW(60ou6eyAHX8wm5IHDw2e4mVomItXe6pTCXzUt0ZZ(ztfF(iOqqoeSVoTBKLOomXx1efAR(d7WMemlJxcPWqVy81HPRjS6p4kicyAHX8wm5IHDw2e4mVomItXeJancolqysI9GwBhd9IXxhMUMWQ)CwPHh7ZJ6KT)p)iqJGZ4gwjOw)liVN(RZWe4bF(73Cm0lgFDy6AcR(ZnYsuhM4WIpFkSFZXqVy81HPRjS6pNvA4RlNQMiIPbPoOwWAajlWznOWnarmtMgyzX1aSjbZYAaz2i7gewdOydSyYfd3efAR(d7WMemlJxcPGmOwW8ywGZGRGiGPfgZBXKlg2HmOwW8ywGZ4o5MOqB1Fyh2KGzz8sif6)z(rWp6Of4G(XFcSBew1efAR(d7WMemlJxcPGZgzdxbrq)liVN(RZWeNhjW0cJ5TyYfd7SSjWzEDyehwnrnrH2Q)WoKGfNwiGrpOAe4kiciOqqorZkAS4Xplg3(5CjqqHGCIMv0yXZqVyC7NZLG6rGgbNfimHpFQdTvPfVCYsjyUxLi0wLw873Cy0dQgH4H2Q0IxozPemvu1efAR(d7qcwCAHxcPGTyWOtUaxbrabfcYjAwrJfp(zX4gzjQdZ9QKWRoWM3QfHpFeuiiNOzfnw8m0lg3ilrDyUxLeE1b28wTinrH2Q)WoKGfNw4LqkylgOAe4kiciOqqorZkAS4zOxmUrwI6WCRdS5TAr4ZhbfcYjAwrJfp(zX42pNlb(zX4fnROXc3jHpFeuiiNOzfnw84NfJB)CUem0lgVOzfnwwFOT6phNjSmxDEiwLNzeFvtuOT6pSdjyXPfEjKcNjSm4kiciOqqorZkAS4Xplg3ilrDyU1b28wTi85JGcb5enROXINHEX42pNlbd9IXlAwrJL1hAR(ZXzclZvNhIv5zg3jrrIPfTIYvjHIktzkf]] )


end
