-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID


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


    Hekili:EmbedAdaptiveSwarm( spec )

    -- Auras
    spec:RegisterAuras( {
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


    local bt_auras = {
        bt_brutal_slash = "brutal_slash",
        bt_moonfire = "lunar_inspiration",
        bt_rake = "rake",
        bt_shred = "shred",
        bt_swipe = "swipe_cat",
        bt_thrash = "thrash_cat"
    }

    local bt_generator = function( t )
        local ab = bt_auras[ t.key ]
        ab = ab and class.abilities[ ab ]
        ab = ab and ab.lastCast

        if ab and ab + 4 > query_time then
            t.count = 1
            t.expires = ab + 4
            t.applied = ab
            t.caster = "player"
            return
        end

        t.count = 0
        t.expires = 0
        t.applied = 0
        t.caster = "nobody"
    end


    spec:RegisterAuras( {
        bt_brutal_slash = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator
        },
        bt_moonfire = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator,
            copy = "bt_lunar_inspiration"
        },
        bt_rake = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator
        },
        bt_shred = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator
        },
        bt_swipe = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator
        },
        bt_thrash = {
            duration = 4,
            max_stack = 1,
            generate = bt_generator
        },
        bt_triggers = {
            alias = { "bt_brutal_slash", "bt_moonfire", "bt_rake", "bt_shred", "bt_swipe", "bt_thrash" },
            aliasMode = "longest",
            aliasType = "buff",
            duration = 4,
        },
    } )



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
        spec.SwarmOnReset()

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
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", a * 0.7 )
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


    local bt_remainingTime = {}

    spec:RegisterStateFunction( "time_to_bt_triggers", function( n )
        if not talent.bloodtalons.enabled or buff.bt_triggers.stack == n then return 0 end
        if buff.bt_triggers.stack < n then return 3600 end

        table.wipe( bt_remainingTime )

        for bt_aura in pairs( bt_auras ) do
            local rem = buff[ bt_aura ].remains
            if rem > 0 then bt_remainingTime[ bt_aura ] = rem end
        end

        table.sort( bt_remainingTime )
        return bt_remainingTime[ n ]
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
                applyBuff( "regrowth" )
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


    spec:RegisterSetting( "filler_regrowth", false, {
        name = "|T136085:0|t Use Regrowth as Filler",
        desc = "If checked, the default priority will recommend |T136085:0|t Regrowth when you use the Bloodtalons talent and would otherwise be pooling Energy to retrigger Bloodtalons.",
        type = "toggle",
        width = "full",
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


    spec:RegisterPack( "Feral", 20220325, [[dSK5cdqisuEevj1LiHI2ej5tKq1OuvCkvuRIevVcQ0SOQClQs1Uq1VirgMQkDmQQwgj4zKqMgvjUMQQABQiLVrvsmoQsjDosOqwhjuAEQQY9uH9HK6GQivSqKKEiscnrQsj2ivPuFufPsNKQuOvQQ0mrsGBsvkyNQi(jvPOHscfQLIKOEQKmvvv8vsOGXIKG2lO(lvgmIdlSyO8ysnzv5YeBwL(SenAjCArRMQK0RPkMnk3wsTBP(TIHJuhxfPQLR0ZHmDkxhKTts9DOQXRIKZdvSEKez(iX(bg2p8pWvVWe4tu4xfu4xfPW)C)E5x))Ri4kdhAbUIo0EIsbUQJAbUYBlBWGROdCyt8G)bUcnqRwGRkmJgPyvsPY0kGW46PwjuwdXclNwVX1ucL1ALGRWGsM5n2WyWvVWe4tu4xfu4xfPW)C)E5x))7hUkGSIzHRQYAQiCvr(EsdJbx9eKgUYBlBWaeVLfkFGVEdXQlaef(3hGOWVkOa4l4lvSi6sbPybF9oG8wO8Xh8m8sOwC6Wo8di6cr7bbi2aiVfkF8bpdVeQfNomo4R3beQ40QL1aeQ(dGqpdZTcAGwTai2ai4J0ae5u0RGq50aYNtPWzo4R3bKtN3dqY2KDHOTeJjaI3MjOc9gxdqYlGGZabifHAbq6XkYUeqegsaeBaK3WbF9oG4TmTIBasXWEacvCA1JhbqUZciu5KgqGAMGqacodKIZyaYkbJHdGqLtAo4R3bKkiA6zna5MmMSacvwk3bVvai4lsMai0ZWYUeqUZciuLnZZc20io4R3befdZ6bqMgqoDEbTLQfaPcFS1accIMEwJd(c(gAlNgXPxrp1yHH7HsQJndmM4RJA54oqRM2HLM4tDWGKJFbFRkw5bihaYV(aKtM27OoOrfJbiu5WJaihaIFFasvh0OIXaeQC4raKdarbFacvG3iGCaikYhGuHpPfa5aq8c4BOTCAeNEf9uJfgUhkPo2mWyIVoQLJBYyY6tDWGKd)GVH2YPrC6v0tnwy4EOK6yZaJj(6Owo2K2zP2dYN6GbjhEfW3qB50io9k6PglmCpuYt2VvEoeDUPHaFdTLtJ40RONASWW9qjSXmM8CxwGJ8WNDPZMtLn4BOTCAeNEf9uJfgUhkDzcQqVX18L3d0aXWY(XPHqgetCYcrB50CPdmM8OqbnqmSSFC1dlSKjo0WulTXLoWyYd8n0wonItVIEQXcd3dLO3bpZxEpWGUxE9mTNSD3zR5VbFd(gAlNgXPxrp1yHH7Hs6WC3zR9L3dmO7Lxpt7jB3D2A(BW3GVuXqxiaYCbKqF6HYvEaITsGGwbbiVrqaspgGGePgqSbqWpRhabhXaKOFasrGaeBaembqqI0GVH2YPrC6v0tnwy4EOK6yZaJj(6OwoM2bHeNTz7rmFQdgKC8l4BOTCAeNEf9uJfgUhkPo2mWyIVoQLJPDqiXzB2EeZ3qFeVNp1bdso(yB2EeJ7NxeihesCyq3RkBZ2JyC)C9mS3GV5pOnSC6ZuOyB2EeJ7NNiE2i9czbgtCNEOOnOA3tuNAb8n0wonItVIEQXcd3dLuhBgymXxh1YX0oiK4SnBpI5BOpI3ZN6GbjhF(yB2EeJRaViqoiK4WGUxv2MThX4kW1ZWEd(M)G2WYPptHITz7rmUc8eXZgPxilWyI70dfTbv7EI6ulNvUcGVH2YPrC6v0tnwy4EOK6yZaJj(6OwoQJt5SnBpI5kg2ZN6GbjhNMFWxW3qB50OJfQDH2YPDSez(6OwoWcw0AXhY2uBh(9L3dmO7Lxpt7jB3D2AoeTkL9wO8Xh8m8sOwC6WaFdTLtJW9qjDWyUqB50owImFDulhdEgEjul(q2MA7WVV8E8wO8Xh8m8sOwC6WaFvmEh8mabFH0IAzbe6bHsmMa(gAlNgH7Hs07GNb(gAlNgH7HswwklYDHwC8L3dmO7LRdZDNTM)g8n4BOTCAeUhkPdZDNT2xEpWGUxUom3D2A(BW3GVH2YPr4EOK6yZaJj(6OwoqfZAcYCM98PoyqYHfBPyClRfNnUxkGVH2YPr4EOKghnl7sN6yZaJj(6OwoqfZAcYCM98n0h1z7tDWGKdl2sX4wwloBCVuaF9MTaiOIXaeKjbZkaFdTLtJW9qPfQDH2YPDSez(6OwoqMemRWhY2uBh(9L3dmO7LJkI3GVwypoenfkyq3lNEh8moen4BOTCAeUhkH8aXyoSava(gAlNgH7Hs6GXCH2YPDSez(6OwoqIbr7dzBQTd)(Y7rOTuT4EJX3K(4xW3qB50iCpushmMl0woTJLiZxh1YHEg2BW3GVNi6DyZ(uSacvmqgGOiazwaXlaIEQXgaHEY2aKnPraY0ack7sMaiwSLIbidKHYNaiZfqWKfjRhazwa5bTzxciyYIK1dGKxa5kBWaK7knvchajracenG4nPYasqtZWbqca5FnnGqLtAabFH0aYpEBajracenGe9dqWNmgGGMPbKBWyaYCVCW3qB50iCpuAtAF59qpQLoAJ3IEh2SpvFuMfmPnogBMNfSPrCPdmM8Oqbd6E5ySzEwWMgXHOpRcrlmMZITume3k2av40HD4x1h9uJno6jBdrTcQw5UcQiWyIQ3cLp(M0Cl1EqUYiB55M2TYDfub1QJndmMW3K2zP2ds1hLHbDVCmKlBnhIMcf9mS3GV5yix2AoenfkFWGUxogYLTMdrRspd7n4B(v2G5UR0ujC4q0NptHIEQXgh9KTHo(xfg09YTSuwK7cT4WHOvHbDVCllLf5Uqlo8vQJSr)5fvVfkF8nP5wQ9GCLr2YZnTBL7kOcQ))m4BOTCAeUhkTqTl0woTJLiZxh1YXn7eviRpKTP2o87lVh6PgBC0t2gI6Jp)7D1XMbgt43bA10oS0KZGVH2YPr4EOe9M1bZHFdRWxEpElu(40Bwhmh(nScULApixzKT8Ct7w5UcQG6df(vLEQXgh9KTHO(qbFSSfN(D8p4R3aeZsVxQFacYKGzfGVH2YPr4EOKoymxOTCAhlrMVoQLdKjbZk8HSn12HFF59ad6E5yix2Aoen4BOTCAeUhkTs5o4TcF59ajMLDjIFtgtw3kL7G3kuzbtAJJXM5zbBAex6aJjpvyq3lhJnZZc20i(BW3QcTLQfhM5SnllLfD8Rk)8)vEP(XRJt93NpF87)FVRGIuog09YZwhBhwoTZt2LU56ScX5vH6sMWHOp79pslBjoCn0UsB4Qi()kxAzlXHVsP04(Xl)QCmO7LRzsS6azzxYHOpF(SsslBjo8vkL(m47pfcGupidqKtrlnkvlacv)bq04OzcG85NIvqfasvXkpaPcFslaIEqgG43))aI0YwIJpaPo8iaccAfabVai6ObK6WJaiwryas2aIxaKs2Gfm0zW3qB50iCpucFKMpKOp(8XV))9Ucks5yq3lpBDSDy50opzx6MRZkeNxfQlzchI(S3)iTSL4W1q7kTHRI4)RCPLTeh(kLsJ7hV8RYXGUxUMjXQdKLDjhI(85ZkjTSL4WxPuAF59WcM0ghJnZZc20iU0bgtEQWGUxogBMNfSPr83GVvfAlvlomZzBwwkl64xW3qB50iCpuIEgMBf0aTAXxEpSGjTXXyZ8SGnnIlDGXKNkmO7LJXM5zbBAe)n4BvFKw2sCWvr8)vU0YwIdFLsPX9Jx(v5yq3lxZKy1bYYUKdrF(8FF87)FVRGIuog09YZwhBhwoTZt2LU56ScX5vH6sMWHOpRk0wQwCyMZ2SSuw0XVGVH2YPr4EO0c1UqB50owImFDulhySzEwWMg5lVhwWK24ySzEwWMgXLoWyYtfg09YXyZ8SGnnI)g8n4BOTCAeUhkDLD05aHCyPj(04OzIZITum0HFF59ad6E5bTCkh9kVWMf50BOo7soen4BOTCAeUhkrpdZTcAGwT47oRRLtzh(bFdTLtJW9qPn8i(04OzIZITum0HFF594Zk3vqfbgtOqHwwuImPnxneZsAwkl1VX4B4r401qmlPzPSNv9wO8X3WJWTu7b5kJSLNBA3k3vqfuJOfgZzXwkgIJWN0IthMYvW7ka(gAlNgH7HsmOowx2i6CdlN2NghntCwSLIHo87lVhFw5UcQiWycfk0YIsKjT5QHywsZszP(ngNb1X6YgrNBy50C6AiML0Su2ZQElu(4mOowx2i6CdlNMBP2dYvgzlp30UvURGkOgrlmMZITumehHpPfNomLRG3va8n0wonc3dLONH5wbnqRw8DN11YPSd)GVH2YPr4EOKvSbQWPdZNghntCwSLIHo87lVhRCxbveymr1BHYh3k2av40HXTu7b5kJSLNBA3k3vqfu)Xl4IOfgZzXwkgIBfBGkC6WuUxoRy(XpU1bYKfhN6GbjN9UE6huAClqM4UZ6WyZ84shym55D9Ow6OnEl6DyZ(u9rzyq3lhd5YwZHOPqbrlmMZITume3k2av40HrT)ZGVH2YPr4EOe9mm3kObA1IV7SUwoLD4h8n0wonc3dLWwilyoelqf(Y7XNnYNtulTXJ3dXZM6p(XTooLtxeBPG8UUi2sb5UBOTC6GDw5ROlITuCwwlNv9brlmMZITumehBHSG5qSavO8qB50CSfYcMdXcub)f1rPOygAlNMJTqwWCiwGk46bzNP(tOTCAoQyLh)f1rPOygAlNMJkw5X1dYod(gAlNgH7Hsi8jT40H5lVhiAHXCwSLIH4i8jT40HrTFCXGUxogYLTMdrRCfaFdTLtJW9qjRyduHthMV8EGOfgZzXwkgIBfBGkC6WOwrGVH2YPr4EOeQyLNV8EGbDVCntIvhil7soeTQpyq3lhb9Es7IAmiub)n4Bvyq3lhveVbFTWE83GVPqbd6E5yix2Aoe9zW3qB50iCpushmMl0woTJLiZxh1YXnzmzbFbFdTLtJ4ySzEwWMgDSHhXNghntCwSLIHo87lVhFuMLApzxsHYh)CfuoTSOezsBUAiML0SuwQpEJX3WJWPRHywsZszptHYNqBPAXHzoBZYszrhkOAL7kOIaJjNpRcd6E5yMBdpc)n4BW3qB50iogBMNfSPr4EOedQJ1LnIo3WYP9PXrZeNfBPyOd)(Y7Xk3vqfbgtuHbDVCmZvptFZv4VbFd(gAlNgXXyZ8SGnnc3dLSInqfoDy(04OzIZITum0HFF59yL7kOIaJjQWGUxoM5SInqf83GVv9wO8XTInqfoDyCl1EqUYiB55M2TYDfub1F8cUiAHXCwSLIH4wXgOcNomL7LZkMF8JBDGmzXXPoyqYzVRN(bLg3cKjU7Som2mpU0bgtEGVH2YPrCm2mplytJW9qjSfYcMdXcuHV8EGbDVCmZHTqwWCiwGk4VbFd(gAlNgXXyZ8SGnnc3dLq4tAXPdZxEpWGUxoM5q4tAH)g8TkeTWyol2sXqCe(KwC6WO2p4BOTCAehJnZZc20iCpucvSYZxEpWGUxoM5qfR84VbFd(gAlNgXXyZ8SGnnc3dLq4tAXPdZxEpWGUxoM5q4tAH)g8n4BOTCAehJnZZc20iCpuYk2av40H5lVhyq3lhZCwXgOc(BW3GVGVH2YPrC9mS3GVpIxqBPAXHWhBTpnoAM4SylfdD43xEp(8rzVX4XlOTuT4q4JT29I6Ou4wQ9KDjfkVX4XlOTuT4q4JT29I6Ou4RuhzJ(tHZQ(8gJhVG2s1IdHp2A3lQJsHJSq75pfrHIYEJXJxqBPAXHWhBTRqcghzH2d1(pRszyq3lpEbTLQfhcFS1UcjyUSDxwwwyCiAvkdd6E5XlOTuT4q4JT29I6OuCz7USSSW4q0NvzXwkg3YAXzJ7Lc1)tHsOTuT4KwQtbrTcQu2BmE8cAlvloe(yRDVOokfULApzxQsAzlX5pf9Vkl2sX4wwloBCVuO(FW3qB50iUEg2BW34EO0LjOc9gxZxEp(Ggigw2poneYGyItwiAlNMcf0aXWY(XvpSWsM4qdtT02zFzBYUq0MlRRLxgMC43x2MSleT5kzdwWo87lBt2fI2C59anqmSSFC1dlSKjo0WulTb(gAlNgX1ZWEd(g3dLGqIlnPg5dXgdDyB2EeZVV8E85JEg2BW3C90QhpIZkehIo30q8vQJSr)PGQpyq3lhd5YwZHOPqrpd7n4BogYLTMVsDKnIA))E(mfk3SSWCRuhzJ(tHFptHYh9mS3GV56PvpEeNvioeDUPH4RuhzJ8UcuRo2mWycVooLZ2S9iMRyyVZuOOo2mWycFAhesC2MThXo(LcLpQJndmMWN2bHeNTz7rSdfu9rpd7n4BUEA1JhXzfIdrNBAi(k1r2iQvqbkuUzzH5wPoYg9Nc)sHITz7rmUcC9mS3GV5RuhzJOwHFpFg8n0wonIRNH9g8nUhkbHexAsnYhIng6W2S9iMc(Y7XNp6zyVbFZ1tRE8ioRqCi6CtdXxPoYg9NcQ(GbDVCmKlBnhIMcf9mS3GV5yix2A(k1r2iQ9)7zvFSnBpIX9Z1ZWEd(MVsDKnI6dfOqrDSzGXe(0oiK4SnBpIDOW5ZuOCZYcZTsDKn6pf(9mfkF(ONH9g8nxpT6XJ4ScXHOZnneFL6iBK3va3t7xL)5JTz7rmUFUEg2BW38vQJSr)PNH9g8nxpT6XJ4ScXHOZnneFL6iBK3v4SQpQJndmMWN2bHeNTz7rSd)uOOo2mWycFAhesC2MThXO(qrNpFMA1XMbgt41XPC2MThXCfd7DMcf1XMbgt4t7GqIZ2S9i2XVuO8rDSzGXe(0oiK4SnBpID4x1h9mS3GV56PvpEeNvioeDUPH4RuhzJOwbfOq5MLfMBL6iB0Fk8lfk2MThX4(56zyVbFZxPoYgrTc)E(m4lvmqgG8twkRIJaeVn0IdGGj3zfa5ZSaswxlVmmgoasCnzpdi6azzxciEBzdgG4TxPPs4ai5fqOQSiz9aijcqoXB(dGmnGONH9g8nh8n0wonIRNH9g8nUhkzzPSi3fAXXhcNwFCLnyU7knvchF59qpd7n4BogYLTMdrd(gAlNgX1ZWEd(g3dLUYgm3DLMkHJpnoAM4SylfdD43xEp0tn24ONSn0FksLfBPyClRfNnUxku7vu9bd6E5OqDukUDILdrtHIYSGjTXrH6OuC7elx6aJjVZQ(Om9mS3GV5wwklYDHwC4q0uOONH9g8nhd5YwZHOptHc2GqQUzzH5wPoYg9N3QQBwwyUvQJSruRa47pEtVfVPIfqorKhGydGGWP1ac(0kae8PvaiBOw6bcbi3vAQeoac(cPbe8cGSqnGCxPPs4Gf9ZhGmlGegtcKbi6cr7bqYlGKgcqWpRvaiPb(gAlNgX1ZWEd(g3dLWKfjRhF59i0wQwCVX4Bst9VQ(ONH9g8nxpT6XJ4ScXHOZnnehIMcf9mS3GV56PvpEeNvioeDUPH4RuhzJOwrkqHc2GqQUzzH5wPoYg9Nc)Eg8n0wonIRNH9g8nUhkLTo2oSCAF59i0wQwCVX4Bst9VQ(ONH9g8nxpT6XJ4ScXHOZnnehIMcfSbHuDZYcZTsDKn6pf97zW3FwCaKOFaspgGGpqMai)4TbePLTehFacgKbibdnaIxfczacesaK0aK7Sacvswpas0pajBDSnc8n0wonIRNH9g8nUhkzzPSi3fAXXxEpKw2sC4p5M60O2l)sHcg09YXqUS1CiAku(ybtAJtVYlSz5shym5PcvmRjiZz27pfDMcLpH2s1I7ngFt6JFvHbDVCm2mplytJ4q0NbF9gYYcdqWeab)oDjGydGaHeaPQwypazAaHkhEeajBarTS4aiQLfhaPtDHaiO0GclNg5dqWGmarTS4aiBScdhW3qB50iUEg2BW34EOeQiEd(AH98L3dmO7LBzPSi3fAXHdrRcd6E5yix2A(BW3Q0tn24ONSn0FErfg09YrqVN0UOgdcvWFd(w1Bm(gEeoDneZsAwk7F(5NMkPLTehQ9YVQElu(4B4r4wQ9GCLr2YZnTBL7kOcQr0cJ5SylfdXr4tAXPdt5k4DfuzXwkg3YAXzJ7Lc1)d(gAlNgX1ZWEd(g3dLWKfjRNSl9L3dmO7LBzPSi3fAXHdrtHcg09YXqUS1CiAW3qB50iUEg2BW34EOe9y50(Y7bg09YXqUS1CiAkuWges1nllm3k1r2O)0ZWEd(MJHCzR5RuhzJOqbBqiv3SSWCRuhzJ(tH)bFdTLtJ46zyVbFJ7HsBOw6bc5UR0ujC8L3dmO7LJHCzR5q0uOCZYcZTsDKn6pf8d((J30BXBQybeQyHO9ai1Z0EYgqkgdpGe9dqqg09ciS0JaiwrI8bir)aK6ahmbqWeZKfq0tnwyaYk1r2aYkiCAn4BOTCAexpd7n4BCpuspT6XJ4ScXHOZnnKV8E85ngFtA(k1r2iQ9Ik9uJno6jBd93)Q(8gJVHhHBP2t2LuOGOfgZzXwkgIBfBGkC6WO2)zvslBjo8NCtDAuFOWVQ0ZWEd(MJHCzR5RuhzJO2)VNPqbBqiv3SSWCRuhzJ(7Fku(GbDVCmKlBnhIwfg09YXqUS18vQJSru7xHZGVEdboycGyfYkacQyGypabtaK6zfarp9lTCAeGmnGyfcGON(bLg4BOTCAexpd7n4BCpusQPh8Y6WM(5lVhyq3l3YszrUl0IdhIMcLp6PFqPXFIq7cgtkZO1cx6aJjVZGVNUPAbqO3C20WbqSbqM27qibqWlb90GVH2YPrC9mS3GVX9qjiK4stQ91rTC4vhdQlLCx3tqw24GC6GX8L3d50dL00YJ7vhdQlLCx3tqw24GC6GXaFdTLtJ46zyVbFJ7HsqiXLMuJaFbFdTLtJ43KXK9ydpIpnoAM4SylfdD43xEpuhBgymHFtgt2d)Qw5UcQiWyIQ3y8n8iC6AiML0Su2)o8Zvq50YIsKjT5QHywsZszbFdTLtJ43KXKf3dL2WJ4lVhQJndmMWVjJj7HcGVH2YPr8BYyYI7HsmOowx2i6CdlN2xEpuhBgymHFtgt2dfb(gAlNgXVjJjlUhkHWN0IV8EOo2mWyc)MmMShEb8n0wonIFtgtwCpucvSYZxEpWGUxoc69K2f1yqOc(BW3GVH2YPr8BYyYI7HsRuUdERWxEpqIzzxI43KXK1Ts5o4TcviHjAlN2zzTqTF()kVu)41XPaFdTLtJ43KXKf3dLUmbvO34A(Y7bAGyyz)40qidIjozHOTCAU0bgtEuOGgigw2pU6HfwYehAyQL24shym55lBt2fI2CzDT8YWKd)(Y2KDHOnxjBWc2HFFzBYUq0MlVhObIHL9JREyHLmXHgMAPnWxW3qB50i(n7evi7b9mm3kObA1IV7SUwoLD4h8n0wonIFZorfYI7HsOqDukUDI1xEpWGUxokuhLIBNy5RuhzJ(trGVH2YPr8B2jQqwCpuIEZ6G5WVHv4lVhFElu(40Bwhmh(nScULApixzKT8Ct7w5UcQGAfP8piAHXCwSLIH40Bwhmh(nScC9FwfIwymNfBPyio9M1bZHFdRGA)NPqbrlmMZITumeNEZ6G5WVHvq9hfHRFLBbtAJJcmzTzScU0bgtENbFdTLtJ43StuHS4EO0M0(04OzIZITum0HFF59yL7kOIaJjQElu(4BsZTu7b5kJSLNBA3k3vqfuRo2mWycFtANLApivF(GbDVCllLf5UqloCiAkuuMLApzxEw1hmO7LJXM5zbBAehIMcfLzbtAJJXM5zbBAex6aJjVZuOOmlysBCuGjRnJvWLoWyY7SQpiAHXCwSLIH40Bwhmh(nSId)uOOmlysBC6nRdMd)gwbx6aJjVZQ(eAlvlU3y8nPp(Lcfl1EYUuvOTuT4EJX3K(WpfkkBHA5oBPWFBavwyU56EIq7UJgcrHIYSGjTXrbMS2mwbx6aJjVZGVH2YPr8B2jQqwCpucfQJsXTtS(Y7bg09YrH6OuC7elFL6iB0FF0tn24ONSneU(pR8tt5)Yve4BOTCAe)MDIkKf3dLUYo6CGqoS0eF1XPCslBjoh(9PXrZeNfBPyOd)GVH2YPr8B2jQqwCpu6k7OZbc5Wst8PXrZeNfBPyOd)(Y7bg09YXqUS1CiAvwWK24ObI5MRZke3DwbzCPdmM8Oqrpd7n4BUEA1JhXzfIdrNBAi(k1r2O)8RspQLoAJ3zzH5UHa(gAlNgXVzNOczX9qPvk3bVv4lVhiXSSlr8BYyY6wPCh8wHkKWeTLt7SSwO2p)FLxQF864uGVGVH2YPr8bpdVeQLdKflcAlfF59ad6E5fsSMBUoRqC4t2Jdrd(gAlNgXh8m8sOwW9qjeuFZv8XYwC63HxuEP(b(gAlNgXh8m8sOwW9qP6z6BUIpw2It)o8IYl1pF59ad6E51Z0EY2DNTMdrRcrlmMZITume3k2av40H9NcQuMfmPnodQJ1LnIo3WYP5shym5PsAzlX5Vt7xvkdd6E5AMeRoqw2LCiAW3qB50i(GNHxc1cUhkviXAU56ScXHpzpF59qAzlX5pf9RQ3y8nP5RuhzJO2l8)v9rpd7n4BULLYICxOfh(k1r2iQpon()uOSqTCNTu46WeCeNgAZ5SkmO7LRzsS6azzxYrwO98NFvkdd6E5bTCkh9kVWMf50BOo7soeTkLHbDVCm2mpgeY4q0Qugg09YXqUS1CiAvF0ZWEd(MRNw94rCwH4q05MgIVsDKnI6tJ)pfkktpQLoAJ3zzH5UHCw1hLPh1shTXBrVdB2hfk6zyVbFZJxqBPAXHWhBnFL6iBe1h)tHYBmE8cAlvloe(yRDVOokf(k1r2iQ9kNbFdTLtJ4dEgEjul4EOu9mTNSD3zR9L3dPLTeN)u0VQEJX3KMVsDKnIAVW)x1h9mS3GV5wwklYDHwC4RuhzJO(Wl8)PqzHA5oBPW1Hj4ion0MZzvyq3lxZKy1bYYUKJSq75p)Qugg09YdA5uo6vEHnlYP3qD2LCiAvkdd6E5ySzEmiKXHOv9rzyq3lhd5YwZHOPqrpQLoAJ3IEh2SpvwWK24OqDukUDILlDGXKNkmO7LJHCzR5RuhzJO(0oR6JEg2BW3C90QhpIZkehIo30q8vQJSruFA8)Pqrz6rT0rB8ollm3nKZQ(Om9Ow6OnEl6DyZ(Oqrpd7n4BE8cAlvloe(yR5RuhzJO(4FkuEJXJxqBPAXHWhBT7f1rPWxPoYgrTx5SQBwwyUvQJSru7vaFbFdTLtJ4iXGOpyqDSUSr05gwoTV8EOh1shTXBrVdB2NkeTWyol2sXqCRyduHth2FErLEQXgh9KTH(7FvkZsTNSlvPmmO7LJHCzR5q0GVH2YPrCKyq04EOe9mm3kObA1IV7SUwoLD4h8n0wonIJedIg3dLqH6OuC7eRV8EybtAJFLnyU7knvchU0bgtEQ0ZWEd(MFLnyU7knvchoeTkLHbDVCuOokf3oXYHOvPNASXrpzBiQ9R6ngFdpc3sTNSlv95ngNb1X6YgrNBy50Cl1EYUKcfLzbtAJZG6yDzJOZnSCAU0bgtENbFdTLtJ4iXGOX9qj6zyUvqd0QfF59WcM0ghJnZZc20iU0bgtEQWGUxogBMNfSPr83GVv9rAzlXbxfX)x5slBjo8vkLg3pE5xLJbDVCntIvhil7soe95Z)9XV))9Ucks5yq3lpBDSDy50opzx6MRZkeNxfQlzchI(SQqBPAXHzoBZYszrh)c(gAlNgXrIbrJ7Hs4J08He9XNp(9)V3vqrkhd6E5zRJTdlN25j7s3CDwH48QqDjt4q0N9(hPLTehUgAxPnCve)FLlTSL4WxPuAC)4LFvog09Y1mjwDGSSl5q0NpFwjPLTeh(kLs7lVhwWK24ySzEwWMgXLoWyYtfg09YXyZ8SGnnI)g8TQqBPAXHzoBZYszrh)c(gAlNgXrIbrJ7Hs6GXCH2YPDSez(6OwoWyZ8SGnnYxEpSGjTXXyZ8SGnnIlDGXKNkmO7LJXM5zbBAe)n4BvF0tn24ONSn0F)tHcIwymNfBPyiUvSbQWPd7W)zW3qB50iosmiACpushmMl0woTJLiZxh1YHEg2BW3GVH2YPrCKyq04EOKoymxOTCAhlrMVoQLJB2jQqwFiBtTD43xEp0tn24ONSne1ks1hmO7LJXM5zbBAehIMcfLzbtAJJXM5zbBAex6aJjVZGVGVH2YPrCKjbZkoONH5wbnqRw8DN11YPSd)GVu5WJaiTipeGSduzbdha5)FvmbK5ciPHaeM0LwbGegGeasD2znunGydGGGw6aHaeuXkpeG8OfW3qB50ioYKGzf4EO0gEeFAC0mXzXwkg6WVV8E85ngFdpcNUgIzjnlL9p)8)PqzL7kOIaJjNv9wO8X3WJWTu7b5kJSLNBA3k3vqfuRafkFOLfLitAZvdXSKMLYs9Bm(gEeoDneZsAwkRkmO7LJHCzR5q0Qq0cJ5SylfdXTInqfoDy)Piv6rT0rB8w07WM9DMcfmO7LJHCzR5RuhzJ(Zp4BOTCAehzsWScCpuIb1X6YgrNBy50(Y7bIwymNfBPyiUvSbQWPd7pfPAL7kOIaJjQElu(4mOowx2i6CdlNMBP2dYvgzlp30UvURGkO(FvF0tn24ONSn0HxOq5ngNb1X6YgrNBy508vQJSr)9pfkk7ngNb1X6YgrNBy50Cl1EYU8m4lvxilyasflqfasIaemXmzbeRiAabzsWScaPQyLhGegGOiaXITume4BOTCAehzsWScCpucBHSG5qSav4lVhiAHXCwSLIH4ylKfmhIfOcQva8n0wonIJmjywbUhkrpdZTcAGwT47oRRLtzh(bFdTLtJ4itcMvG7HsOIvE(Y7HEQXgh9KTH(ZlQq0cJ5SylfdXTInqfoDy)9p4l4BOTCAehlyrRLdeuFZv8L3dmO7LlAwsJehAyXYFd(wfg09YfnlPrIJb1XYFd(w1NvURGkcmMqHYNqBPAXjTuNcIA)QcTLQf3BmocQV5k)fAlvloPL6uqNpd(gAlNgXXcw0Ab3dLqwSiOTu8L3dmO7LlAwsJehAyXYxPoYgrT)FXvhiZzzTqHcg09YfnlPrIJb1XYxPoYgrT)FXvhiZzzTa(gAlNgXXcw0Ab3dLqwS3CfF59ad6E5IML0iXXG6y5RuhzJOwhiZzzTqHcg09YfnlPrIdnSy5VbFRcnSyDIML0iH6FPqbd6E5IML0iXHgwS83GVvXG6yDIML0iX7H2YP543Wk4z7USSSW(Zp4BOTCAehlyrRfCpuc)gwHV8EGbDVCrZsAK4qdlw(k1r2iQ1bYCwwluOGbDVCrZsAK4yqDS83GVvXG6yDIML0iX7H2YP543Wk4z7USSSWO(x4kwIme8pWvySzEwWMgb)d8j(H)bUs6aJjpyQcxfAlNgUAdpcCLEtt2mGR(aikdqSu7j7saHcfa5dG4NRaGOCaHwwuImPnxneZsAwklGq9bG8gJVHhHtxdXSKMLYciNbekuaKpasOTuT4WmNTzzPSia5aquaqubiRCxbveymbqodiNbevacg09YXm3gEe(BW3WvAC0mXzXwkgc(e)Wg8jka)dCL0bgtEWufUk0wonCfdQJ1LnIo3WYPHR0BAYMbC1k3vqfbgtaevacg09YXmx9m9nxH)g8nCLghntCwSLIHGpXpSbFIIG)bUs6aJjpyQcxfAlNgUYk2av40HbxP30Knd4QvURGkcmMaiQaemO7LJzoRydub)n4BarfG8wO8XTInqfoDyCl1EqUYiB55M2TYDfubGqnG8bq8cGGlGGOfgZzXwkgIBfBGkC6WaeLdiEbqodikbiFae)acUasDGmzXXPoyqcGCgq8oGON(bLg3cKjU7Som2mpU0bgtEWvAC0mXzXwkgc(e)Wg8jEb(h4kPdmM8GPkCLEtt2mGRWGUxoM5Wwilyoelqf83GVHRcTLtdxHTqwWCiwGkGn4t(h(h4kPdmM8GPkCLEtt2mGRWGUxoM5q4tAH)g8nGOcqq0cJ5SylfdXr4tAXPddqOgq8dxfAlNgUcHpPfNomyd(Ktd(h4kPdmM8GPkCLEtt2mGRWGUxoM5qfR84VbFdxfAlNgUcvSYd2GpXRa)dCL0bgtEWufUsVPjBgWvyq3lhZCi8jTWFd(gUk0wonCfcFsloDyWg8jERW)axjDGXKhmvHR0BAYMbCfg09YXmNvSbQG)g8nCvOTCA4kRyduHthgSbBWv3StuHSW)aFIF4FGRKoWyYdMQWv3zDTCkd(e)WvH2YPHRONH5wbnqRwGn4tua(h4kPdmM8GPkCLEtt2mGRWGUxokuhLIBNy5RuhzJaK)aefbxfAlNgUcfQJsXTtSWg8jkc(h4kPdmM8GPkCLEtt2mGR(aiVfkFC6nRdMd)gwb3sThKRmYwEUPDRCxbvaiudikcquoG8bqq0cJ5SylfdXP3Soyo8ByfacUaIFa5mGOcqq0cJ5SylfdXP3Soyo8Byfac1aIFa5mGqHcGGOfgZzXwkgItVzDWC43WkaeQbKpaIIaeCbe)aIYbelysBCuGjRnJvWLoWyYdqodxfAlNgUIEZ6G5WVHvaBWN4f4FGRKoWyYdMQWvH2YPHR2KgUsVPjBgWvRCxbveymbqubiVfkF8nP5wQ9GCLr2YZnTBL7kOcaHAarDSzGXe(M0ol1EqaIka5dG8bqWGUxULLYICxOfhoenGqHcGOmaXsTNSlbKZaIka5dGGbDVCm2mplytJ4q0acfkaIYaelysBCm2mplytJ4shym5biNbekuaeLbiwWK24OatwBgRGlDGXKhGCgqubiFaeeTWyol2sXqC6nRdMd)gwbGCai(bekuaeLbiwWK240Bwhmh(nScU0bgtEaYzarfG8bqcTLQf3Bm(M0aYbG8lGqHcGyP2t2LaIkaj0wQwCVX4BsdihaIFaHcfarzaYc1YD2sH)2aQSWCZ19eH2DhneIlDGXKhGqHcGOmaXcM0ghfyYAZyfCPdmM8aKZWvAC0mXzXwkgc(e)Wg8j)d)dCL0bgtEWufUsVPjBgWvyq3lhfQJsXTtS8vQJSraYFaYharp1yJJEY2qacUaIFa5mGOCa50aeLdi)YveCvOTCA4kuOokf3oXcBWNCAW)axjDGXKhmvHRQJt5Kw2sCGpXpCvOTCA4QRSJohiKdlnbUsJJMjol2sXqWN4h2GpXRa)dCL0bgtEWufUk0wonC1v2rNdeYHLMaxP30Knd4kmO7LJHCzR5q0aIkaXcM0ghnqm3CDwH4UZkiJlDGXKhGqHcGONH9g8nxpT6XJ4ScXHOZnneFL6iBeG8hG4hqubi6rT0rB8ollm3ne4knoAM4SylfdbFIFyd(eVv4FGRKoWyYdMQWv6nnzZaUcjMLDjIFtgtw3kL7G3kaevacsyI2YPDwwlac1aIF()aIYbKs9JxhNcUk0wonC1kL7G3kGnydUclyrRf4FGpXp8pWvshym5btv4k9MMSzaxHbDVCrZsAK4qdlw(BW3aIkabd6E5IML0iXXG6y5VbFdiQaKpaYk3vqfbgtaekuaKpasOTuT4KwQtbbiudi(bevasOTuT4EJXrq9nxbq(dqcTLQfN0sDkia5mGCgUk0wonCfcQV5kWg8jka)dCL0bgtEWufUsVPjBgWvyq3lx0SKgjo0WILVsDKncqOgq8)lGGlGOdK5SSwaekuaemO7LlAwsJehdQJLVsDKncqOgq8)lGGlGOdK5SSwGRcTLtdxHSyrqBPaBWNOi4FGRKoWyYdMQWv6nnzZaUcd6E5IML0iXXG6y5RuhzJaeQbeDGmNL1cGqHcGGbDVCrZsAK4qdlw(BW3aIkabnSyDIML0ibqOgq(fqOqbqWGUxUOzjnsCOHfl)n4BarfGWG6yDIML0ibq8oGeAlNMJFdRGNT7YYYcdq(dq8dxfAlNgUczXEZvGn4t8c8pWvshym5btv4k9MMSzaxHbDVCrZsAK4qdlw(k1r2iaHAarhiZzzTaiuOaiyq3lx0SKgjoguhl)n4BarfGWG6yDIML0ibq8oGeAlNMJFdRGNT7YYYcdqOgq(fUk0wonCf(nScyd2GRqIbrd)d8j(H)bUs6aJjpyQcxP30Knd4k9Ow6OnEl6DyZ(aevacIwymNfBPyiUvSbQWPddq(dq8cGOcq0tn24ONSneG8hG8pGOcqugGyP2t2LaIkarzacg09YXqUS1CiA4QqB50WvmOowx2i6CdlNg2Gprb4FGRKoWyYdMQWv3zDTCkd(e)WvH2YPHRONH5wbnqRwGn4tue8pWvshym5btv4k9MMSzaxzbtAJFLnyU7knvchU0bgtEaIkarpd7n4B(v2G5UR0ujC4q0aIkarzacg09YrH6OuC7elhIgqubi6PgBC0t2gcqOgq8diQaK3y8n8iCl1EYUequbiFaK3yCguhRlBeDUHLtZTu7j7saHcfarzaIfmPnodQJ1LnIo3WYP5shym5biNHRcTLtdxHc1rP42jwyd(eVa)dCL0bgtEWufUcjA4QpaYhaXV))beVdikOiar5acg09YZwhBhwoTZt2LU56ScX5vH6sMWHObKZaI3bKpaI0YwIdxdTR0gGGlGOi()aIYbePLTeh(kLsdi4ciFaeV8lGOCabd6E5AMeRoqw2LCiAa5mGCgqodikbislBjo8vkLgUk0wonCf(in4k9MMSzaxzbtAJJXM5zbBAex6aJjparfGGbDVCm2mplytJ4VbFdiQaKqBPAXHzoBZYszraYbG8lSbFY)W)axjDGXKhmvHR0BAYMbCLfmPnogBMNfSPrCPdmM8aevacg09YXyZ8SGnnI)g8nGOcq(ai6PgBC0t2gcq(dq(hqOqbqq0cJ5SylfdXTInqfoDyaYbG4hqodxfAlNgUshmMl0woTJLidUILiZ1rTaxHXM5zbBAeSbFYPb)dCL0bgtEWufUk0wonCLoymxOTCAhlrgCflrMRJAbUspd7n4Byd(eVc8pWvshym5btv4k9MMSzaxPNASXrpzBiaHAarraIka5dGGbDVCm2mplytJ4q0acfkaIYaelysBCm2mplytJ4shym5biNHRq2MAd(e)WvH2YPHR0bJ5cTLt7yjYGRyjYCDulWv3StuHSWgSbx9KBaXm4FGpXp8pWvshym5btv4k9MMSzaxHbDV86zApz7UZwZHObevaIYaK3cLp(GNHxc1IthgCfY2uBWN4hUk0wonC1c1UqB50owIm4kwImxh1cCfwWIwlWg8jka)dCL0bgtEWufUsVPjBgWvVfkF8bpdVeQfNom4kKTP2GpXpCvOTCA4kDWyUqB50owIm4kwImxh1cC1GNHxc1cSbFIIG)bUs6aJjpyQcx9eKEtAlNgUsX4DWZae8fslQLfqOhekXycCvOTCA4k6DWZGn4t8c8pWvshym5btv4k9MMSzaxHbDVCDyU7S183GVHRcTLtdxzzPSi3fAXb2Gp5F4FGRKoWyYdMQWv6nnzZaUcd6E56WC3zR5VbFdxfAlNgUshM7oBnSbFYPb)dCL0bgtEWufU6ji9M0wonCL3SfabvmgGGmjywbCvOTCA4QfQDH2YPDSezWviBtTbFIF4k9MMSzaxHbDVCur8g81c7XHObekuaemO7LtVdEghIgUILiZ1rTaxHmjywbSbFIxb(h4QqB50WvipqmMdlqfWvshym5btvyd(eVv4FGRKoWyYdMQWv6nnzZaUk0wQwCVX4BsdihaYVWviBtTbFIF4QqB50Wv6GXCH2YPDSezWvSezUoQf4kKyq0Wg8jkgb)dCL0bgtEWufUk0wonCLoymxOTCAhlrgCflrMRJAbUspd7n4Byd(e))c)dCL0bgtEWufUk0wonC1M0WvpbP3K2YPHRor07WM9PybeQyGmarraYSaIxae9uJnac9KTbiBsJaKPbeu2LmbqSylfdqgidLpbqMlGGjlswpaYSaYdAZUeqWKfjRhajVaYv2Gbi3vAQeoasIaeiAaXBsLbKGMMHdGeaY)AAaHkN0ac(cPbKF82asIaeiAaj6hGGpzmabntdi3GXaK5E5Wv6nnzZaUspQLoAJ3IEh2SparfG8bqugGybtAJJXM5zbBAex6aJjpaHcfabd6E5ySzEwWMgXHObKZaIkabrlmMZITume3k2av40HbihaIFarfG8bq0tn24ONSneGqnGOaGOcqw5UcQiWycGOcqElu(4BsZTu7b5kJSLNBA3k3vqfac1aI6yZaJj8nPDwQ9GaevaYharzacg09YXqUS1CiAaHcfarpd7n4BogYLTMdrdiuOaiFaemO7LJHCzR5q0aIkarpd7n4B(v2G5UR0ujC4q0aYza5mGqHcGONASXrpzBia5aq(hqubiyq3l3YszrUl0IdhIgqubiyq3l3YszrUl0IdFL6iBeG8hG4farfG8wO8X3KMBP2dYvgzlp30UvURGkaeQbK)bKZWg8j(9d)dCL0bgtEWufUsVPjBgWv6PgBC0t2gcqO(aq(ai)diEhquhBgymHFhOvt7WstaKZWviBtTbFIF4QqB50Wvlu7cTLt7yjYGRyjYCDulWv3StuHSWg8j(va(h4kPdmM8GPkCLEtt2mGRElu(40Bwhmh(nScULApixzKT8Ct7w5UcQaqO(aqu4xarfGONASXrpzBiaH6darb4QqB50Wv0Bwhmh(nSc4kw2It)GR(h2GpXVIG)bUs6aJjpyQcx9eKEtAlNgUYBaIzP3l1pabzsWSc4QqB50Wv6GXCH2YPDSezWviBtTbFIF4k9MMSzaxHbDVCmKlBnhIgUILiZ1rTaxHmjywbSbFIFVa)dCL0bgtEWufUsVPjBgWviXSSlr8BYyY6wPCh8wbGOcqSGjTXXyZ8SGnnIlDGXKhGOcqWGUxogBMNfSPr83GVbevasOTuT4WmNTzzPSia5aq(fqubi(5)dikhqk1pEDCka5pa5dG8bq(ai(9)pG4DarbfbikhqWGUxE26y7WYPDEYU0nxNvioVkuxYeoenGCgq8oG8bqKw2sC4AODL2aeCbefX)hquoGiTSL4WxPuAabxa5dG4LFbeLdiyq3lxZKy1bYYUKdrdiNbKZaYzarjarAzlXHVsP0aYz4QqB50WvRuUdERa2GpX))W)axjDGXKhmvHREcsVjTLtdx9tHai1dYae5u0sJs1cGq1FaenoAMaiF(PyfubGuvSYdqQWN0cGOhKbi(9)pGiTSL44dqQdpcGGGwbqWlaIoAaPo8iaIvegGKnG4faPKnybdDgUcjA4QpaYhaXV))beVdikOiar5acg09YZwhBhwoTZt2LU56ScX5vH6sMWHObKZaI3bKpaI0YwIdxdTR0gGGlGOi()aIYbePLTeh(kLsdi4ciFaeV8lGOCabd6E5AMeRoqw2LCiAa5mGCgqodikbislBjo8vkLgUk0wonCf(in4k9MMSzaxzbtAJJXM5zbBAex6aJjparfGGbDVCm2mplytJ4VbFdiQaKqBPAXHzoBZYszraYbG8lSbFI)td(h4kPdmM8GPkCLEtt2mGRSGjTXXyZ8SGnnIlDGXKhGOcqWGUxogBMNfSPr83GVHRcTLtdxTqTl0woTJLidUILiZ1rTaxHXM5zbBAeSbFIFVc8pWvshym5btv4QqB50WvxzhDoqihwAcCLEtt2mGRWGUxEqlNYrVYlSzro9gQZUKdrdxPXrZeNfBPyi4t8dBWN43Bf(h4kPdmM8GPkC1DwxlNYGpXpCvOTCA4k6zyUvqd0Qfyd(e)kgb)dCL0bgtEWufUk0wonC1gEe4k9MMSzax9bqw5UcQiWycGqHcGqllkrM0MRgIzjnlLfqOgqEJX3WJWPRHywsZszbKZaIka5Tq5JVHhHBP2dYvgzlp30UvURGkaeQbeeTWyol2sXqCe(KwC6WaeLdikaiEhquaUsJJMjol2sXqWN4h2GprHFH)bUs6aJjpyQcxfAlNgUIb1X6YgrNBy50Wv6nnzZaU6dGSYDfurGXeaHcfaHwwuImPnxneZsAwklGqnG8gJZG6yDzJOZnSCAoDneZsAwklGCgqubiVfkFCguhRlBeDUHLtZTu7b5kJSLNBA3k3vqfac1acIwymNfBPyiocFsloDyaIYbefaeVdikaxPXrZeNfBPyi4t8dBWNOGF4FGRKoWyYdMQWv3zDTCkd(e)WvH2YPHRONH5wbnqRwGn4tuqb4FGRKoWyYdMQWvH2YPHRSInqfoDyWv6nnzZaUAL7kOIaJjaIka5Tq5JBfBGkC6W4wQ9GCLr2YZnTBL7kOcaHAa5dG4fabxabrlmMZITume3k2av40Hbikhq8cGCgqucq(ai(beCbK6azYIJtDWGea5mG4Darp9dknUfitC3zDySzECPdmM8aeVdi6rT0rB8w07WM9biQaKpaIYaemO7LJHCzR5q0acfkacIwymNfBPyiUvSbQWPddqOgq8diNHR04OzIZITume8j(Hn4tuqrW)axjDGXKhmvHRUZ6A5ug8j(HRcTLtdxrpdZTcAGwTaBWNOGxG)bUs6aJjpyQcxP30Knd4QpaYg5ZjQL24X7H4zdiudiFae)acUasDCkNUi2sbbiEhq0fXwki3DdTLthma5mGOCazfDrSLIZYAbqodiQaKpacIwymNfBPyio2czbZHybQaquoGeAlNMJTqwWCiwGk4VOokfarjaj0wonhBHSG5qSavW1dYaKZac1aYhaj0wonhvSYJ)I6OuaeLaKqB50CuXkpUEqgGCgUk0wonCf2czbZHybQa2GprH)H)bUs6aJjpyQcxP30Knd4keTWyol2sXqCe(KwC6WaeQbe)acUacg09YXqUS1CiAar5aIcWvH2YPHRq4tAXPdd2GprHtd(h4kPdmM8GPkCLEtt2mGRq0cJ5SylfdXTInqfoDyac1aIIGRcTLtdxzfBGkC6WGn4tuWRa)dCL0bgtEWufUsVPjBgWvyq3lxZKy1bYYUKdrdiQaKpacg09YrqVN0UOgdcvWFd(gqubiyq3lhveVbFTWE83GVbekuaemO7LJHCzR5q0aYz4QqB50WvOIvEWg8jk4Tc)dCL0bgtEWufUk0wonCLoymxOTCAhlrgCflrMRJAbU6MmMSWgSbxrVIEQXcd(h4t8d)dCL0bgtEWufUAOHRqIbxfAlNgUsDSzGXe4k1bdsGR(fUsDSUoQf4Q7aTAAhwAcSbFIcW)axjDGXKhmvHRgA4kKyWvH2YPHRuhBgymbUsDWGe4k)WvpbP3K2YPHRQkw5bihaYV(aKtM27OoOrfJbiu5WJaihaIFFasvh0OIXaeQC4raKdarbFacvG3iGCaikYhGuHpPfa5aq8cCL6yDDulWv3KXKf2GprrW)axjDGXKhmvHRgA4kKyWvH2YPHRuhBgymbUsDWGe4kVcCL6yDDulWvBs7Su7bbBWN4f4FGRcTLtdx5j73kphIo30qWvshym5btvyd(K)H)bUk0wonCf2ygtEUllWrE4ZU0zZPYgUs6aJjpyQcBWNCAW)axjDGXKhmvHR0BAYMbCfAGyyz)40qidIjozHOTCAU0bgtEacfkacAGyyz)4QhwyjtCOHPwAJlDGXKhCvOTCA4Qltqf6nUgSbFIxb(h4kPdmM8GPkCLEtt2mGRWGUxE9mTNSD3zR5VbFdxfAlNgUIEh8myd(eVv4FGRKoWyYdMQWv6nnzZaUcd6E51Z0EY2DNTM)g8nCvOTCA4kDyU7S1Wg8jkgb)dCL0bgtEWufUAOHRqIbxfAlNgUsDSzGXe4k1bdsGR(fU6ji9M0wonCfvm0fcGmxaj0NEOCLhGyReiOvqaYBeeG0JbiirQbeBae8Z6bqWrmaj6hGueiaXgabtaeKinCL6yDDulWvt7GqIZ2S9igSbFI)FH)bUs6aJjpyQcxn0WvX7bxfAlNgUsDSzGXe4k1bdsGR(ai2MThX4MFErGCqiXHbDVaIkaX2S9ig38Z1ZWEd(M)G2WYPbKZacfkaITz7rmU5NNiE2i9czbgtCNEOOnOA3tuNAbUsDSUoQf4QPDqiXzB2Eed2GpXVF4FGRKoWyYdMQWvdnCv8EWvH2YPHRuhBgymbUsDWGe4QpaYhaX2S9ig3uGxeihesCyq3lGOcqSnBpIXnf46zyVbFZFqBy50aYzaHcfaX2S9ig3uGNiE2i9czbgtCNEOOnOA3tuNAbqodikhquaUsDSUoQf4QPDqiXzB2Eed2GpXVcW)axjDGXKhmvHRgA4kKyWvH2YPHRuhBgymbUsDWGe4QtZpCL6yDDulWv1XPC2MThXCfd7bBWgC1nzmzH)b(e)W)axjDGXKhmvHRcTLtdxTHhbUsVPjBgWvQJndmMWVjJjlGCai(bevaYk3vqfbgtaevaYBm(gEeoDneZsAwklG83bG4NRaGOCaHwwuImPnxneZsAwklCLghntCwSLIHGpXpSbFIcW)axjDGXKhmvHR0BAYMbCL6yZaJj8BYyYcihaIcWvH2YPHR2WJaBWNOi4FGRKoWyYdMQWv6nnzZaUsDSzGXe(nzmzbKdarrWvH2YPHRyqDSUSr05gwonSbFIxG)bUs6aJjpyQcxP30Knd4k1XMbgt43KXKfqoaeVaxfAlNgUcHpPfNomyd(K)H)bUs6aJjpyQcxP30Knd4kmO7LJGEpPDrngeQG)g8nCvOTCA4kuXkpyd(Ktd(h4kPdmM8GPkCLEtt2mGRqIzzxI43KXK1Ts5o4TcarfGGeMOTCANL1cGqnG4N)pGOCaPu)41XPGRcTLtdxTs5o4Tcyd2GRqMemRa(h4t8d)dCL0bgtEWufU6oRRLtzWN4hUk0wonCf9mm3kObA1cSbFIcW)axjDGXKhmvHRcTLtdxTHhbUsJJMjol2sXqWN4hUsVPjBgWvFaK3y8n8iC6AiML0Suwa5paXp)FaHcfazL7kOIaJjaYzarfG8wO8X3WJWTu7b5kJSLNBA3k3vqfac1aIcacfkaYhaHwwuImPnxneZsAwklGqnG8gJVHhHtxdXSKMLYciQaemO7LJHCzR5q0aIkabrlmMZITume3k2av40Hbi)bikcqubi6rT0rB8w07WM9biNbekuaemO7LJHCzR5RuhzJaK)ae)WvpbP3K2YPHROYHhbqArEiazhOYcgoaY))QyciZfqsdbimPlTcajmajaK6SZAOAaXgabbT0bcbiOIvEia5rlWg8jkc(h4kPdmM8GPkCLEtt2mGRq0cJ5SylfdXTInqfoDyaYFaIIaevaYk3vqfbgtaevaYBHYhNb1X6YgrNBy50Cl1EqUYiB55M2TYDfubGqnG8pGOcq(ai6PgBC0t2gcqoaeVaiuOaiVX4mOowx2i6CdlNMVsDKncq(dq(hqOqbqugG8gJZG6yDzJOZnSCAULApzxciNHRcTLtdxXG6yDzJOZnSCAyd(eVa)dCL0bgtEWufUk0wonCf2czbZHybQaU6ji9M0wonCfvxilyasflqfasIaemXmzbeRiAabzsWScaPQyLhGegGOiaXITumeCLEtt2mGRq0cJ5SylfdXXwilyoelqfac1aIcWg8j)d)dCL0bgtEWufU6oRRLtzWN4hUk0wonCf9mm3kObA1cSbFYPb)dCL0bgtEWufUsVPjBgWv6PgBC0t2gcq(dq8cGOcqq0cJ5SylfdXTInqfoDyaYFaY)WvH2YPHRqfR8GnydUspd7n4B4FGpXp8pWvshym5btv4QqB50WvXlOTuT4q4JTgUsVPjBgWvFaKpaIYaK3y84f0wQwCi8Xw7ErDukCl1EYUeqOqbqEJXJxqBPAXHWhBT7f1rPWxPoYgbi)bikaiNbevaYha5ngpEbTLQfhcFS1UxuhLchzH2dG8hGOiaHcfarzaYBmE8cAlvloe(yRDfsW4il0EaeQbe)aYzarfGOmabd6E5XlOTuT4q4JT2vibZLT7YYYcJdrdiQaeLbiyq3lpEbTLQfhcFS1UxuhLIlB3LLLfghIgqodiQael2sX4wwloBCVuaeQbK)bekuaKqBPAXjTuNccqOgquaqubikdqEJXJxqBPAXHWhBT7f1rPWTu7j7sarfGiTSL4ai)bik6FarfGyXwkg3YAXzJ7LcGqnG8pCLghntCwSLIHGpXpSbFIcW)axjDGXKhmvHR0BAYMbC1habnqmSSFCAiKbXeNSq0wonx6aJjpaHcfabnqmSSFC1dlSKjo0WulTXLoWyYdqodxLTj7crBU8cxHgigw2pU6HfwYehAyQL2GRY2KDHOnxwxlVmmbUYpCvOTCA4Qltqf6nUgCv2MSleT5kzdwWGR8dBWNOi4FGRKoWyYdMQWvH2YPHRSnBpI5hUsVPjBgWvFaKpaIEg2BW3C90QhpIZkehIo30q8vQJSraYFaIcaIka5dGGbDVCmKlBnhIgqOqbq0ZWEd(MJHCzR5RuhzJaeQbe))ciNbKZacfkaYnllm3k1r2ia5parHFbKZacfkaYharpd7n4BUEA1JhXzfIdrNBAi(k1r2iaX7aIcac1aI6yZaJj864uoBZ2JyUIH9aKZacfkaI6yZaJj8PDqiXzB2EedqoaKFbekuaKpaI6yZaJj8PDqiXzB2EedqoaefaevaYharpd7n4BUEA1JhXzfIdrNBAi(k1r2iaHAarbfaekuaKBwwyUvQJSraYFaIc)ciuOai2MThX4McC9mS3GV5RuhzJaeQbef(fqodiNHRqSXqWv2MThX8dBWN4f4FGRKoWyYdMQWvH2YPHRSnBpIPaCLEtt2mGR(aiFae9mS3GV56PvpEeNvioeDUPH4RuhzJaK)aefaevaYhabd6E5yix2AoenGqHcGONH9g8nhd5YwZxPoYgbiudi()fqodiQaKpaITz7rmU5NRNH9g8nFL6iBeGq9bGOaGqHcGOo2mWycFAhesC2MThXaKdarba5mGCgqOqbqUzzH5wPoYgbi)bik8lGCgqOqbq(aiFae9mS3GV56PvpEeNvioeDUPH4RuhzJaeVdikai4ciN2VaIYbKpaYhaX2S9ig38Z1ZWEd(MVsDKncq(dq0ZWEd(MRNw94rCwH4q05MgIVsDKncq8oGOaGCgqubiFae1XMbgt4t7GqIZ2S9igGCai(bekuae1XMbgt4t7GqIZ2S9igGq9bGOia5mGCgqodiudiQJndmMWRJt5SnBpI5kg2dqodiuOaiQJndmMWN2bHeNTz7rma5aq(fqOqbq(aiQJndmMWN2bHeNTz7rma5aq8diQaKpaIEg2BW3C90QhpIZkehIo30q8vQJSrac1aIckaiuOai3SSWCRuhzJaK)aef(fqOqbqSnBpIXn)C9mS3GV5RuhzJaeQbef(fqodiNHRqSXqWv2MThXua2Gp5F4FGRKoWyYdMQWvpbP3K2YPHROIbYaKFYszvCeG4THwCaem5oRaiFMfqY6A5LHXWbqIRj7zarhil7saXBlBWaeV9knvchajVacvLfjRhajraYjEZFaKPbe9mS3GV5WviCAnC1v2G5UR0ujCGR0BAYMbCLEg2BW3CmKlBnhIgUk0wonCLLLYICxOfhyd(Ktd(h4kPdmM8GPkCvOTCA4QRSbZDxPPs4axP30Knd4k9uJno6jBdbi)bikcqubiwSLIXTSwC24EPaiudiEfarfG8bqWGUxokuhLIBNy5q0acfkaIYaelysBCuOokf3oXYLoWyYdqodiQaKpaIYae9mS3GV5wwklYDHwC4q0acfkaIEg2BW3CmKlBnhIgqodiuOaiydcbiQaKBwwyUvQJSraYFaI3kGOcqUzzH5wPoYgbiudikaxPXrZeNfBPyi4t8dBWN4vG)bUs6aJjpyQcxfAlNgUctwKSEGREcsVjTLtdx9J30BXBQybKte5bi2aiiCAnGGpTcabFAfaYgQLEGqaYDLMkHdGGVqAabVailudi3vAQeoyr)8biZciHXKazaIUq0EaK8ciPHae8ZAfasAWv6nnzZaUk0wQwCVX4Bsdiudi)ciQaKpaIEg2BW3C90QhpIZkehIo30qCiAaHcfarpd7n4BUEA1JhXzfIdrNBAi(k1r2iaHAarrkaiuOaiydcbiQaKBwwyUvQJSraYFaIc)ciNHn4t8wH)bUs6aJjpyQcxP30Knd4QqBPAX9gJVjnGqnG8lGOcq(ai6zyVbFZ1tRE8ioRqCi6CtdXHObekuaeSbHaevaYnllm3k1r2ia5parr)ciNHRcTLtdxLTo2oSCAyd(efJG)bUs6aJjpyQcxfAlNgUYYszrUl0IdC1tq6nPTCA4QFwCaKOFaspgGGpqMai)4TbePLTehFacgKbibdnaIxfczacesaK0aK7Sacvswpas0pajBDSncUsVPjBgWvslBjo8NCtDAac1aIx(fqOqbqWGUxogYLTMdrdiuOaiFaelysBC6vEHnlx6aJjparfGGkM1eK5m7bi)bikcqodiuOaiFaKqBPAX9gJVjnGCai)ciQaemO7LJXM5zbBAehIgqodBWN4)x4FGRKoWyYdMQWvH2YPHRqfXBWxlShC1tq6nPTCA4kVHSSWaembqWVtxci2aiqibqQQf2dqMgqOYHhbqYgqulloaIAzXbq6uxiacknOWYPr(aemidqulloaYgRWWbUsVPjBgWvyq3l3YszrUl0IdhIgqubiyq3lhd5YwZFd(gqubi6PgBC0t2gcq(dq8cGOcqWGUxoc69K2f1yqOc(BW3aIka5ngFdpcNUgIzjnlLfq(dq8ZpnarfGiTSL4aiudiE5xarfG8wO8X3WJWTu7b5kJSLNBA3k3vqfac1acIwymNfBPyiocFsloDyaIYbefaeVdikaiQael2sX4wwloBCVuaeQbK)Hn4t87h(h4kPdmM8GPkCLEtt2mGRWGUxULLYICxOfhoenGqHcGGbDVCmKlBnhIgUk0wonCfMSiz9KDjSbFIFfG)bUs6aJjpyQcxP30Knd4kmO7LJHCzR5q0acfkac2GqaIka5MLfMBL6iBeG8hGONH9g8nhd5YwZxPoYgbiuOaiydcbiQaKBwwyUvQJSraYFaIc)dxfAlNgUIESCAyd(e)kc(h4kPdmM8GPkCLEtt2mGRWGUxogYLTMdrdiuOai3SSWCRuhzJaK)aef8dxfAlNgUAd1spqi3DLMkHdSbFIFVa)dCL0bgtEWufUk0wonCLEA1JhXzfIdrNBAi4QNG0BsB50Wv)4n9w8MkwaHkwiApas9mTNSbKIXWdir)aeKbDVacl9iaIvKiFas0paPoWbtaemXmzbe9uJfgGSsDKnGSccNwdxP30Knd4QpaYBm(M08vQJSrac1aIxaevaIEQXgh9KTHaK)aK)bevaYha5ngFdpc3sTNSlbekuaeeTWyol2sXqCRyduHthgGqnG4hqodiQaePLTeh(tUPonaH6darHFbevaIEg2BW3CmKlBnFL6iBeGqnG4)xa5mGqHcGGnieGOcqUzzH5wPoYgbi)bi)diuOaiFaemO7LJHCzR5q0aIkabd6E5yix2A(k1r2iaHAaXVcaYzyd(e))d)dCL0bgtEWufUk0wonCLutp4L1Hn9dU6ji9M0wonCL3qGdMaiwHScGGkgi2dqWeaPEwbq0t)slNgbitdiwHai6PFqPbxP30Knd4kmO7LBzPSi3fAXHdrdiuOaiFae90pO04prODbJjLz0AHlDGXKhGCg2GpX)Pb)dCL0bgtEWufU6ji9M0wonC1PBQwae6nNnnCaeBaKP9oesae8sqpnCvh1cCLxDmOUuYDDpbzzJdYPdgdUsVPjBgWvYPhkPPLh3Roguxk5UUNGSSXb50bJbxfAlNgUYRoguxk5UUNGSSXb50bJbBWN43Ra)dCvOTCA4kiK4stQrWvshym5btvyd2GRg8m8sOwG)b(e)W)axjDGXKhmvHR0BAYMbCfg09YlKyn3CDwH4WNShhIgUk0wonCfYIfbTLcSbFIcW)axjDGXKhmvHRcTLtdxHG6BUcCflBXPFWvEr5L6hSbFIIG)bUs6aJjpyQcxfAlNgUQEM(MRaxP30Knd4kmO7Lxpt7jB3D2AoenGOcqq0cJ5SylfdXTInqfoDyaYFaIcaIkarzaIfmPnodQJ1LnIo3WYP5shym5biQaePLTeha5pa50(fqubikdqWGUxUMjXQdKLDjhIgUILT40p4kVO8s9d2GpXlW)axjDGXKhmvHR0BAYMbCL0YwIdG8hGOOFbevaYBm(M08vQJSrac1aIx4)diQaKpaIEg2BW3CllLf5Uqlo8vQJSrac1haYPX)hqOqbqwOwUZwkCDycoItdT5WLoWyYdqodiQaemO7LRzsS6azzxYrwO9ai)bi(bevaIYaemO7Lh0YPC0R8cBwKtVH6Sl5q0aIkarzacg09YXyZ8yqiJdrdiQaeLbiyq3lhd5YwZHObevaYharpd7n4BUEA1JhXzfIdrNBAi(k1r2iaHAa504)diuOaikdq0JAPJ24DwwyUBiaYzarfG8bqugGOh1shTXBrVdB2hGqHcGONH9g8npEbTLQfhcFS18vQJSrac1haY)acfkaYBmE8cAlvloe(yRDVOokf(k1r2iaHAaXRaiNHRcTLtdxviXAU56ScXHpzpyd(K)H)bUs6aJjpyQcxP30Knd4kPLTeha5parr)ciQaK3y8nP5RuhzJaeQbeVW)hqubiFae9mS3GV5wwklYDHwC4RuhzJaeQpaeVW)hqOqbqwOwUZwkCDycoItdT5WLoWyYdqodiQaemO7LRzsS6azzxYrwO9ai)bi(bevaIYaemO7Lh0YPC0R8cBwKtVH6Sl5q0aIkarzacg09YXyZ8yqiJdrdiQaKpaIYaemO7LJHCzR5q0acfkaIEulD0gVf9oSzFaIkaXcM0ghfQJsXTtSCPdmM8aevacg09YXqUS18vQJSrac1aYPbiNbevaYharpd7n4BUEA1JhXzfIdrNBAi(k1r2iaHAa504)diuOaikdq0JAPJ24DwwyUBiaYzarfG8bqugGOh1shTXBrVdB2hGqHcGONH9g8npEbTLQfhcFS18vQJSrac1haY)acfkaYBmE8cAlvloe(yRDVOokf(k1r2iaHAaXRaiNbevaYnllm3k1r2iaHAaXRaxfAlNgUQEM2t2U7S1WgSbBWvQLfLtdFIc)QGc)QGcEf4k8X2zxIGRumC6qLpXB8KtxflGai)uiaswtpRbi3zbef)MDIkKvXbKvo9q5kpabn1cGeq2uhM8aeDr0LcId(sfKTaiErXciuXPvlRjparXxOwUZwkCQqfhqSbqu8fQL7SLcNkKlDGXKNIdiF8FQZCWxWxfdNou5t8gp50vXciaYpfcGK10ZAaYDwarXFYnGyMIdiRC6HYvEacAQfajGSPom5bi6IOlfeh8LkiBbquqbflGqfNwTSM8aKQSMkciiCAlofGOyci2aiubqbG8s1jkNgqgAzdBwa5JsNbKp(p1zo4lvq2cGOGxuSacvCA1YAYdqQYAQiGGWPT4uaIIjGydGqfafaYlvNOCAazOLnSzbKpkDgq(OWPoZbFbFvmC6qLpXB8KtxflGai)uiaswtpRbi3zbefNEf9uJfMIdiRC6HYvEacAQfajGSPom5bi6IOlfeh8LkiBbq8)RIfqOItRwwtEaIIBB2EeJ7NtfQ4aInaIIBB2EeJB(5uHkoG8rrN6mh8LkiBbq87xXciuXPvlRjparXTnBpIXvGtfQ4aInaIIBB2EeJBkWPcvCa5JIo1zo4l4RIHthQ8jEJNC6Qybea5NcbqYA6zna5olGO4ySzEwWMgP4aYkNEOCLhGGMAbqciBQdtEaIUi6sbXbFPcYwaefPybeQ40QL1KhGuL1urabHtBXPaeftaXgaHkakaKxQor50aYqlByZciFu6mG8X)PoZbFbFvmC6qLpXB8KtxflGai)uiaswtpRbi3zbefxpd7n4Bfhqw50dLR8ae0ulasaztDyYdq0frxkio4lvq2cGOGIfqOItRwwtEaIIJgigw2povOIdi2aikoAGyyz)4uHCPdmM8uCa5JcN6mh8LkiBbquKIfqOItRwwtEaIIBB2EeJRaNkuXbeBaef32S9ig3uGtfQ4aYh)N6mh8LkiBbq8IIfqOItRwwtEaIIBB2EeJ7NtfQ4aInaIIBB2EeJB(5uHkoG8rrN6mh8f8vXWPdv(eVXtoDvSacG8tHaizn9SgGCNfqu8bpdVeQffhqw50dLR8ae0ulasaztDyYdq0frxkio4lvq2cG4fflGqfNwTSM8aefFHA5oBPWPcvCaXgarXxOwUZwkCQqU0bgtEkoG8X)PoZbFPcYwaK)vSacvCA1YAYdqu8fQL7SLcNkuXbeBaefFHA5oBPWPc5shym5P4aYh)N6mh8f81BSMEwtEaI)FbKqB50aclrgId(cxHOfn8j()vrWv07CtMax51EnG4TLnyaI3YcLpWxV2RbeVHy1faIc)7dqu4xfua8f81R9AaHkweDPGuSGVETxdiEhqElu(4dEgEjuloDyh(beDHO9GaeBaK3cLp(GNHxc1Ithgh81R9AaX7acvCA1YAacv)bqONH5wbnqRwaeBae8rAaICk6vqOCAa5ZPu4mh81R9AaX7aYPZ7bizBYUq0wIXeaXBZeuHEJRbi5fqWzGaKIqTai9yfzxcicdjaInaYB4GVETxdiEhq8wMwXnaPyypaHkoT6XJai3zbeQCsdiqntqiabNbsXzmazLGXWbqOYjnh81R9AaX7asfen9SgGCtgtwaHklL7G3kae8fjtae6zyzxci3zbeQYM5zbBAeh81R9AaX7aIIHz9aitdiNoVG2s1cGuHp2AabbrtpRXbFbFdTLtJ40RONASWW9qj1XMbgt81rTCChOvt7Wst8PoyqYXVGVEnGuvSYdqoaKF9biNmT3rDqJkgdqOYHhbqoae)(aKQoOrfJbiu5WJaihaIc(aeQaVra5aquKpaPcFslaYbG4fW3qB50io9k6PglmCpusDSzGXeFDulh3KXK1N6Gbjh(bFdTLtJ40RONASWW9qj1XMbgt81rTCSjTZsThKp1bdso8kGVH2YPrC6v0tnwy4EOKNSFR8Ci6Ctdb(gAlNgXPxrp1yHH7HsyJzm55USah5Hp7sNnNkBW3qB50io9k6PglmCpu6YeuHEJR5lVhObIHL9JtdHmiM4KfI2YP5shym5rHcAGyyz)4QhwyjtCOHPwAJlDGXKh4BOTCAeNEf9uJfgUhkrVdEMV8EGbDV86zApz7UZwZFd(g8n0wonItVIEQXcd3dL0H5UZw7lVhyq3lVEM2t2U7S183GVbF9AaHkg6cbqMlGe6tpuUYdqSvce0kia5nccq6XaeKi1aInac(z9ai4igGe9dqkceGydGGjacsKg8n0wonItVIEQXcd3dLuhBgymXxh1YX0oiK4SnBpI5tDWGKJFbFdTLtJ40RONASWW9qj1XMbgt81rTCmTdcjoBZ2Jy(g6J498PoyqYXhBZ2JyC)8Ia5GqIdd6EvzB2EeJ7NRNH9g8n)bTHLtFMcfBZ2JyC)8eXZgPxilWyI70dfTbv7EI6ulGVH2YPrC6v0tnwy4EOK6yZaJj(6OwoM2bHeNTz7rmFd9r8E(uhmi54ZhBZ2JyCf4fbYbHehg09QY2S9igxbUEg2BW38h0gwo9zkuSnBpIXvGNiE2i9czbgtCNEOOnOA3tuNA5SYva8n0wonItVIEQXcd3dLuhBgymXxh1YrDCkNTz7rmxXWE(uhmi5408d(c(gAlNgDSqTl0woTJLiZxh1YbwWIwl(q2MA7WVV8EGbDV86zApz7UZwZHOvPS3cLp(GNHxc1Ithg4BOTCAeUhkPdgZfAlN2XsK5RJA5yWZWlHAXhY2uBh(9L3J3cLp(GNHxc1Ithg4RxdikgVdEgGGVqArTSac9GqjgtaFdTLtJW9qj6DWZaFdTLtJW9qjllLf5Uqlo(Y7bg09Y1H5UZwZFd(g8n0wonc3dL0H5UZw7lVhyq3lxhM7oBn)n4BWxV2RbKqB50iCpusDSzGXeFDulhOIznbzoZE(uhmi5WITumUL1IZg3lfWxV2RbKqB50iCpusJJMLDPtDSzGXeFDulhOIznbzoZE(g6J6S9PoyqYHfBPyClRfNnUxkGVEnG4nBbqqfJbiitcMva(gAlNgH7Hslu7cTLt7yjY81rTCGmjywHpKTP2o87lVhyq3lhveVbFTWECiAkuWGUxo9o4zCiAW3qB50iCpuc5bIXCybQa8n0wonc3dL0bJ5cTLt7yjY81rTCGedI2hY2uBh(9L3JqBPAX9gJVj9XVGVH2YPr4EOKoymxOTCAhlrMVoQLd9mS3GVbF9Aa5erVdB2NIfqOIbYaefbiZciEbq0tn2ai0t2gGSjncqMgqqzxYeaXITumazGmu(eazUacMSiz9aiZcipOn7sabtwKSEaK8cixzdgGCxPPs4aijcqGObeVjvgqcAAgoasai)RPbeQCsdi4lKgq(XBdijcqGObKOFac(KXae0mnGCdgdqM7Ld(gAlNgH7HsBs7lVh6rT0rB8w07WM9P6JYSGjTXXyZ8SGnnIlDGXKhfkyq3lhJnZZc20ioe9zviAHXCwSLIH4wXgOcNoSd)Q(ONASXrpzBiQvq1k3vqfbgtu9wO8X3KMBP2dYvgzlp30UvURGkOwDSzGXe(M0ol1EqQ(OmmO7LJHCzR5q0uOONH9g8nhd5YwZHOPq5dg09YXqUS1CiAv6zyVbFZVYgm3DLMkHdhI(8zku0tn24ONSn0X)QWGUxULLYICxOfhoeTkmO7LBzPSi3fAXHVsDKn6pVO6Tq5JVjn3sThKRmYwEUPDRCxbvq9)NbFdTLtJW9qPfQDH2YPDSez(6OwoUzNOcz9HSn12HFF59qp1yJJEY2quF85FVRo2mWyc)oqRM2HLMCg8n0wonc3dLO3Soyo8Byf(Y7XBHYhNEZ6G5WVHvWTu7b5kJSLNBA3k3vqfuFOWVQ0tn24ONSne1hk4JLT40VJ)bF9AaXBaIzP3l1pabzsWScW3qB50iCpushmMl0woTJLiZxh1YbYKGzf(q2MA7WVV8EGbDVCmKlBnhIg8n0wonc3dLwPCh8wHV8EGeZYUeXVjJjRBLYDWBfQSGjTXXyZ8SGnnIlDGXKNkmO7LJXM5zbBAe)n4BvH2s1IdZC2MLLYIo(vLF()kVu)41XP(7ZNp(9)V3vqrkhd6E5zRJTdlN25j7s3CDwH48QqDjt4q0N9(hPLTehUgAxPnCve)FLlTSL4WxPuAC)4LFvog09Y1mjwDGSSl5q0NpFwjPLTeh(kLsFg81RbKFkeaPEqgGiNIwAuQwaeQ(dGOXrZea5ZpfRGkaKQIvEasf(Kwae9GmaXV))bePLTehFasD4raee0kacEbq0rdi1HhbqSIWaKSbeVaiLSblyOZGVH2YPr4EOe(inFirF85JF))7DfuKYXGUxE26y7WYPDEYU0nxNvioVkuxYeoe9zV)rAzlXHRH2vAdxfX)x5slBjo8vkLg3pE5xLJbDVCntIvhil7soe95ZNvsAzlXHVsP0(Y7HfmPnogBMNfSPrCPdmM8uHbDVCm2mplytJ4VbFRk0wQwCyMZ2SSuw0XVGVETxdiH2YPr4EOe9mm3kObA1IV8EybtAJJXM5zbBAex6aJjpvyq3lhJnZZc20i(BW3Q(iTSL4GRI4)RCPLTeh(kLsJ7hV8RYXGUxUMjXQdKLDjhI(85)(43))ExbfPCmO7LNTo2oSCANNSlDZ1zfIZRc1LmHdrFwvOTuT4WmNTzzPSOJFbFdTLtJW9qPfQDH2YPDSez(6OwoWyZ8SGnnYxEpSGjTXXyZ8SGnnIlDGXKNkmO7LJXM5zbBAe)n4BW3qB50iCpu6k7OZbc5Wst8PXrZeNfBPyOd)(Y7bg09YdA5uo6vEHnlYP3qD2LCiAW3qB50iCpuIEgMBf0aTAX3DwxlNYo8d(gAlNgH7HsB4r8PXrZeNfBPyOd)(Y7XNvURGkcmMqHcTSOezsBUAiML0SuwQFJX3WJWPRHywsZszpR6Tq5JVHhHBP2dYvgzlp30UvURGkOgrlmMZITumehHpPfNomLRG3va8n0wonc3dLyqDSUSr05gwoTpnoAM4SylfdD43xEp(SYDfurGXekuOLfLitAZvdXSKMLYs9BmodQJ1LnIo3WYP501qmlPzPSNv9wO8XzqDSUSr05gwon3sThKRmYwEUPDRCxbvqnIwymNfBPyiocFsloDykxbVRa4BOTCAeUhkrpdZTcAGwT47oRRLtzh(bFdTLtJW9qjRyduHthMpnoAM4SylfdD43xEpw5UcQiWyIQ3cLpUvSbQWPdJBP2dYvgzlp30UvURGkO(JxWfrlmMZITume3k2av40HPCVCwX8JFCRdKjloo1bdso7D90pO04wGmXDN1HXM5XLoWyYZ76rT0rB8w07WM9P6JYWGUxogYLTMdrtHcIwymNfBPyiUvSbQWPdJA)NbFdTLtJW9qj6zyUvqd0QfF3zDTCk7Wp4BOTCAeUhkHTqwWCiwGk8L3JpBKpNOwAJhVhINn1F8JBDCkNUi2sb5DDrSLcYD3qB50b7SYxrxeBP4SSwoR6dIwymNfBPyio2czbZHybQq5H2YP5ylKfmhIfOc(lQJsrXm0wonhBHSG5qSavW1dYot9NqB50CuXkp(lQJsrXm0wonhvSYJRhKDg8n0wonc3dLq4tAXPdZxEpq0cJ5SylfdXr4tAXPdJA)4IbDVCmKlBnhIw5ka(gAlNgH7HswXgOcNomF59arlmMZITume3k2av40HrTIaFdTLtJW9qjuXkpF59ad6E5AMeRoqw2LCiAvFWGUxoc69K2f1yqOc(BW3QWGUxoQiEd(AH94VbFtHcg09YXqUS1Ci6ZGVH2YPr4EOKoymxOTCAhlrMVoQLJBYyYc(c(gAlNgXXyZ8SGnn6ydpIpnoAM4SylfdD43xEp(Oml1EYUKcLp(5kOCAzrjYK2C1qmlPzPSuF8gJVHhHtxdXSKMLYEMcLpH2s1IdZC2MLLYIouq1k3vqfbgtoFwfg09YXm3gEe(BW3GVH2YPrCm2mplytJW9qjguhRlBeDUHLt7tJJMjol2sXqh(9L3JvURGkcmMOcd6E5yMREM(MRWFd(g8n0wonIJXM5zbBAeUhkzfBGkC6W8PXrZeNfBPyOd)(Y7Xk3vqfbgtuHbDVCmZzfBGk4VbFR6Tq5JBfBGkC6W4wQ9GCLr2YZnTBL7kOcQ)4fCr0cJ5SylfdXTInqfoDyk3lNvm)4h36azYIJtDWGKZExp9dknUfitC3zDySzECPdmM8aFdTLtJ4ySzEwWMgH7HsylKfmhIfOcF59ad6E5yMdBHSG5qSavWFd(g8n0wonIJXM5zbBAeUhkHWN0IthMV8EGbDVCmZHWN0c)n4BviAHXCwSLIH4i8jT40HrTFW3qB50iogBMNfSPr4EOeQyLNV8EGbDVCmZHkw5XFd(g8n0wonIJXM5zbBAeUhkHWN0IthMV8EGbDVCmZHWN0c)n4BW3qB50iogBMNfSPr4EOKvSbQWPdZxEpWGUxoM5SInqf83GVbFbFdTLtJ46zyVbFFeVG2s1IdHp2AFAC0mXzXwkg6WVV8E85JYEJXJxqBPAXHWhBT7f1rPWTu7j7skuEJXJxqBPAXHWhBT7f1rPWxPoYg9NcNv95ngpEbTLQfhcFS1UxuhLchzH2ZFkIcfL9gJhVG2s1IdHp2AxHemoYcThQ9FwLYWGUxE8cAlvloe(yRDfsWCz7USSSW4q0Qugg09YJxqBPAXHWhBT7f1rP4Y2DzzzHXHOpRYITumUL1IZg3lfQ)NcLqBPAXjTuNcIAfuPS3y84f0wQwCi8Xw7ErDukCl1EYUuL0YwIZFk6FvwSLIXTSwC24EPq9)GVH2YPrC9mS3GVX9qPltqf6nUMV8E8bnqmSSFCAiKbXeNSq0wonfkObIHL9JREyHLmXHgMAPTZ(Y2KDHOnxwxlVmm5WVVSnzxiAZvYgSGD43x2MSleT5Y7bAGyyz)4QhwyjtCOHPwAd8n0wonIRNH9g8nUhkbHexAsnYhIng6W2S9iMFF594Zh9mS3GV56PvpEeNvioeDUPH4RuhzJ(tbvFWGUxogYLTMdrtHIEg2BW3CmKlBnFL6iBe1()98zkuUzzH5wPoYg9Nc)EMcLp6zyVbFZ1tRE8ioRqCi6CtdXxPoYg5DfOwDSzGXeEDCkNTz7rmxXWENPqrDSzGXe(0oiK4SnBpID8lfkFuhBgymHpTdcjoBZ2JyhkO6JEg2BW3C90QhpIZkehIo30q8vQJSruRGcuOCZYcZTsDKn6pf(LcfBZ2JyCf46zyVbFZxPoYgrTc)E(m4BOTCAexpd7n4BCpuccjU0KAKpeBm0HTz7rmf8L3JpF0ZWEd(MRNw94rCwH4q05MgIVsDKn6pfu9bd6E5yix2Aoenfk6zyVbFZXqUS18vQJSru7)3ZQ(yB2EeJ7NRNH9g8nFL6iBe1hkqHI6yZaJj8PDqiXzB2Ee7qHZNPq5MLfMBL6iB0Fk87zku(8rpd7n4BUEA1JhXzfIdrNBAi(k1r2iVRaUN2Vk)ZhBZ2JyC)C9mS3GV5RuhzJ(tpd7n4BUEA1JhXzfIdrNBAi(k1r2iVRWzvFuhBgymHpTdcjoBZ2Jyh(PqrDSzGXe(0oiK4SnBpIr9HIoF(m1QJndmMWRJt5SnBpI5kg27mfkQJndmMWN2bHeNTz7rSJFPq5J6yZaJj8PDqiXzB2Ee7WVQp6zyVbFZ1tRE8ioRqCi6CtdXxPoYgrTckqHYnllm3k1r2O)u4xkuSnBpIX9Z1ZWEd(MVsDKnIAf(98zWxVgqOIbYaKFYszvCeG4THwCaem5oRaiFMfqY6A5LHXWbqIRj7zarhil7saXBlBWaeV9knvchajVacvLfjRhajraYjEZFaKPbe9mS3GV5GVH2YPrC9mS3GVX9qjllLf5Uqlo(q406JRSbZDxPPs44lVh6zyVbFZXqUS1CiAW3qB50iUEg2BW34EO0v2G5UR0ujC8PXrZeNfBPyOd)(Y7HEQXgh9KTH(trQSylfJBzT4SX9sHAVIQpyq3lhfQJsXTtSCiAkuuMfmPnokuhLIBNy5shym5Dw1hLPNH9g8n3YszrUl0IdhIMcf9mS3GV5yix2Aoe9zkuWges1nllm3k1r2O)8wvDZYcZTsDKnIAfaF9Aa5hVP3I3uXciNiYdqSbqq40AabFAfac(0kaKnul9aHaK7knvchabFH0acEbqwOgqUR0ujCWI(5dqMfqcJjbYaeDHO9ai5fqsdbi4N1kaK0aFdTLtJ46zyVbFJ7HsyYIK1JV8EeAlvlU3y8nPP(xvF0ZWEd(MRNw94rCwH4q05MgIdrtHIEg2BW3C90QhpIZkehIo30q8vQJSruRifOqbBqiv3SSWCRuhzJ(tHFpd(gAlNgX1ZWEd(g3dLYwhBhwoTV8EeAlvlU3y8nPP(xvF0ZWEd(MRNw94rCwH4q05MgIdrtHc2GqQUzzH5wPoYg9NI(9m4Rxdi)S4air)aKEmabFGmbq(XBdislBjo(aemidqcgAaeVkeYaeiKaiPbi3zbeQKSEaKOFas26yBe4BOTCAexpd7n4BCpuYYszrUl0IJV8EiTSL4WFYn1PrTx(LcfmO7LJHCzR5q0uO8XcM0gNELxyZYLoWyYtfQywtqMZS3Fk6mfkFcTLQf3Bm(M0h)Qcd6E5ySzEwWMgXHOpd(61aI3qwwyacMai43PlbeBaeiKaiv1c7bitdiu5WJaizdiQLfharTS4aiDQleabLguy50iFacgKbiQLfhazJvy4a(gAlNgX1ZWEd(g3dLqfXBWxlSNV8EGbDVCllLf5UqloCiAvyq3lhd5YwZFd(wLEQXgh9KTH(ZlQWGUxoc69K2f1yqOc(BW3QEJX3WJWPRHywsZsz)Zp)0ujTSL4qTx(v1BHYhFdpc3sThKRmYwEUPDRCxbvqnIwymNfBPyiocFsloDykxbVRGkl2sX4wwloBCVuO(FW3qB50iUEg2BW34EOeMSiz9KDPV8EGbDVCllLf5UqloCiAkuWGUxogYLTMdrd(gAlNgX1ZWEd(g3dLOhlN2xEpWGUxogYLTMdrtHc2GqQUzzH5wPoYg9NEg2BW3CmKlBnFL6iBefkydcP6MLfMBL6iB0Fk8p4BOTCAexpd7n4BCpuAd1spqi3DLMkHJV8EGbDVCmKlBnhIMcLBwwyUvQJSr)PGFWxVgq(XB6T4nvSacvSq0EaK6zApzdifJHhqI(biid6Ebew6raeRir(aKOFasDGdMaiyIzYci6PglmazL6iBazfeoTg8n0wonIRNH9g8nUhkPNw94rCwH4q05MgYxEp(8gJVjnFL6iBe1ErLEQXgh9KTH(7FvFEJX3WJWTu7j7skuq0cJ5SylfdXTInqfoDyu7)SkPLTeh(tUPonQpu4xv6zyVbFZXqUS18vQJSru7)3ZuOGniKQBwwyUvQJSr)9pfkFWGUxogYLTMdrRcd6E5yix2A(k1r2iQ9RWzWxVgq8gcCWeaXkKvaeuXaXEacMai1ZkaIE6xA50iazAaXkearp9dknW3qB50iUEg2BW34EOKutp4L1Hn9ZxEpWGUxULLYICxOfhoenfkF0t)GsJ)eH2fmMuMrRfU0bgtENbF9Aa50nvlac9MZMgoaInaY0EhcjacEjONg8n0wonIRNH9g8nUhkbHexAsTVoQLdV6yqDPK76EcYYghKthmMV8EiNEOKMwECV6yqDPK76EcYYghKthmg4BOTCAexpd7n4BCpuccjU0KAe4l4BOTCAe)MmMShB4r8PXrZeNfBPyOd)(Y7H6yZaJj8BYyYE4x1k3vqfbgtu9gJVHhHtxdXSKMLY(3HFUckNwwuImPnxneZsAwkl4BOTCAe)MmMS4EO0gEeF59qDSzGXe(nzmzpua8n0wonIFtgtwCpuIb1X6YgrNBy50(Y7H6yZaJj8BYyYEOiW3qB50i(nzmzX9qje(Kw8L3d1XMbgt43KXK9WlGVH2YPr8BYyYI7HsOIvE(Y7bg09YrqVN0UOgdcvWFd(g8n0wonIFtgtwCpuALYDWBf(Y7bsml7se)MmMSUvk3bVvOcjmrB50olRfQ9Z)x5L6hVoof4Rx71asOTCAe)MmMS4EO0LjOc9gxZxEpqdedl7hNgczqmXjleTLtZLoWyYJcf0aXWY(XvpSWsM4qdtT0gx6aJjpFzBYUq0MlRRLxgMC43x2MSleT5kzdwWo87lBt2fI2C59anqmSSFC1dlSKjo0WulTb(c(gAlNgXVzNOczpONH5wbnqRw8DN11YPSd)GVH2YPr8B2jQqwCpucfQJsXTtS(Y7bg09YrH6OuC7elFL6iB0Fkc8n0wonIFZorfYI7Hs0Bwhmh(nScF594ZBHYhNEZ6G5WVHvWTu7b5kJSLNBA3k3vqfuRiL)brlmMZITumeNEZ6G5WVHvGR)ZQq0cJ5SylfdXP3Soyo8Byfu7)mfkiAHXCwSLIH40Bwhmh(nScQ)OiC9RClysBCuGjRnJvWLoWyY7m4BOTCAe)MDIkKf3dL2K2NghntCwSLIHo87lVhRCxbveymr1BHYhFtAULApixzKT8Ct7w5UcQGA1XMbgt4Bs7Su7bP6ZhmO7LBzPSi3fAXHdrtHIYSu7j7YZQ(GbDVCm2mplytJ4q0uOOmlysBCm2mplytJ4shym5DMcfLzbtAJJcmzTzScU0bgtENv9brlmMZITumeNEZ6G5WVHvC4NcfLzbtAJtVzDWC43Wk4shym5Dw1NqBPAX9gJVj9XVuOyP2t2LQcTLQf3Bm(M0h(Pqrzlul3zlf(BdOYcZnx3teA3D0qikuuMfmPnokWK1MXk4shym5Dg8n0wonIFZorfYI7HsOqDukUDI1xEpWGUxokuhLIBNy5RuhzJ(7JEQXgh9KTHW1)zLFAk)xUIaFdTLtJ43StuHS4EO0v2rNdeYHLM4RooLtAzlX5WVpnoAM4SylfdD4h8n0wonIFZorfYI7HsxzhDoqihwAIpnoAM4SylfdD43xEpWGUxogYLTMdrRYcM0ghnqm3CDwH4UZkiJlDGXKhfk6zyVbFZ1tRE8ioRqCi6CtdXxPoYg9NFv6rT0rB8ollm3neW3qB50i(n7evilUhkTs5o4TcF59ajMLDjIFtgtw3kL7G3kuHeMOTCANL1c1(5)R8s9JxhNc8f8n0wonIp4z4LqTCGSyrqBP4lVhyq3lVqI1CZ1zfIdFYECiAW3qB50i(GNHxc1cUhkHG6BUIpw2It)o8IYl1pW3qB50i(GNHxc1cUhkvptFZv8XYwC63HxuEP(5lVhyq3lVEM2t2U7S1CiAviAHXCwSLIH4wXgOcNoS)uqLYSGjTXzqDSUSr05gwonx6aJjpvslBjo)DA)Qszyq3lxZKy1bYYUKdrd(gAlNgXh8m8sOwW9qPcjwZnxNvio8j75lVhslBjo)POFv9gJVjnFL6iBe1EH)VQp6zyVbFZTSuwK7cT4WxPoYgr9XPX)NcLfQL7SLcxhMGJ40qBoNvHbDVCntIvhil7soYcTN)8Rszyq3lpOLt5Ox5f2SiNEd1zxYHOvPmmO7LJXM5XGqghIwLYWGUxogYLTMdrR6JEg2BW3C90QhpIZkehIo30q8vQJSruFA8)Pqrz6rT0rB8ollm3nKZQ(Om9Ow6OnEl6DyZ(Oqrpd7n4BE8cAlvloe(yR5RuhzJO(4FkuEJXJxqBPAXHWhBT7f1rPWxPoYgrTx5m4BOTCAeFWZWlHAb3dLQNP9KT7oBTV8EiTSL48NI(v1Bm(M08vQJSru7f()Q(ONH9g8n3YszrUl0IdFL6iBe1hEH)pfklul3zlfUombhXPH2CoRcd6E5AMeRoqw2LCKfAp)5xLYWGUxEqlNYrVYlSzro9gQZUKdrRszyq3lhJnZJbHmoeTQpkdd6E5yix2Aoenfk6rT0rB8w07WM9PYcM0ghfQJsXTtSCPdmM8uHbDVCmKlBnFL6iBe1N2zvF0ZWEd(MRNw94rCwH4q05MgIVsDKnI6tJ)pfkktpQLoAJ3zzH5UHCw1hLPh1shTXBrVdB2hfk6zyVbFZJxqBPAXHWhBnFL6iBe1h)tHYBmE8cAlvloe(yRDVOokf(k1r2iQ9kNvDZYcZTsDKnIAVc4l4BOTCAehjge9bdQJ1LnIo3WYP9L3d9Ow6OnEl6DyZ(uHOfgZzXwkgIBfBGkC6W(ZlQ0tn24ONSn0F)RszwQ9KDPkLHbDVCmKlBnhIg8n0wonIJedIg3dLONH5wbnqRw8DN11YPSd)GVH2YPrCKyq04EOekuhLIBNy9L3dlysB8RSbZDxPPs4WLoWyYtLEg2BW38RSbZDxPPs4WHOvPmmO7LJc1rP42jwoeTk9uJno6jBdrTFvVX4B4r4wQ9KDPQpVX4mOowx2i6CdlNMBP2t2LuOOmlysBCguhRlBeDUHLtZLoWyY7m4Rx71asOTCAehjgenUhkrpdZTcAGwT4lVhwWK24ySzEwWMgXLoWyYtfg09YXyZ8SGnnI)g8TQpslBjo4Qi()kxAzlXHVsP04(Xl)QCmO7LRzsS6azzxYHOpF(Vp(9)V3vqrkhd6E5zRJTdlN25j7s3CDwH48QqDjt4q0NvfAlvlomZzBwwkl64xW3qB50iosmiACpucFKMpKOp(8XV))9Ucks5yq3lpBDSDy50opzx6MRZkeNxfQlzchI(S3)iTSL4W1q7kTHRI4)RCPLTeh(kLsJ7hV8RYXGUxUMjXQdKLDjhI(85ZkjTSL4WxPuAF59WcM0ghJnZZc20iU0bgtEQWGUxogBMNfSPr83GVvfAlvlomZzBwwkl64xW3qB50iosmiACpushmMl0woTJLiZxh1YbgBMNfSPr(Y7HfmPnogBMNfSPrCPdmM8uHbDVCm2mplytJ4VbFR6JEQXgh9KTH(7Fkuq0cJ5SylfdXTInqfoDyh(pd(gAlNgXrIbrJ7Hs6GXCH2YPDSez(6Owo0ZWEd(g8n0wonIJedIg3dL0bJ5cTLt7yjY81rTCCZorfY6dzBQTd)(Y7HEQXgh9KTHOwrQ(GbDVCm2mplytJ4q0uOOmlysBCm2mplytJ4shym5Dg8f8n0wonIJmjywXb9mm3kObA1IV7SUwoLD4h81RbeQC4raKwKhcq2bQSGHdG8)VkMaYCbK0qact6sRaqcdqcaPo7SgQgqSbqqqlDGqacQyLhcqE0c4BOTCAehzsWScCpuAdpIpnoAM4SylfdD43xEp(8gJVHhHtxdXSKMLY(NF()uOSYDfurGXKZQElu(4B4r4wQ9GCLr2YZnTBL7kOcQvGcLp0YIsKjT5QHywsZszP(ngFdpcNUgIzjnlLvfg09YXqUS1CiAviAHXCwSLIH4wXgOcNoS)uKk9Ow6OnEl6DyZ(otHcg09YXqUS18vQJSr)5h8n0wonIJmjywbUhkXG6yDzJOZnSCAF59arlmMZITume3k2av40H9NIuTYDfurGXevVfkFCguhRlBeDUHLtZTu7b5kJSLNBA3k3vqfu)VQp6PgBC0t2g6WluO8gJZG6yDzJOZnSCA(k1r2O)(NcfL9gJZG6yDzJOZnSCAULApzxEg81RbeQUqwWaKkwGkaKebiyIzYciwr0acYKGzfasvXkpajmarraIfBPyiW3qB50ioYKGzf4EOe2czbZHybQWxEpq0cJ5SylfdXXwilyoelqfuRa4BOTCAehzsWScCpuIEgMBf0aTAX3DwxlNYo8d(gAlNgXrMemRa3dLqfR88L3d9uJno6jBd9NxuHOfgZzXwkgIBfBGkC6W(7FWxW3qB50iowWIwlhiO(MR4lVhyq3lx0SKgjo0WIL)g8TkmO7LlAwsJehdQJL)g8TQpRCxbveymHcLpH2s1ItAPofe1(vfAlvlU3yCeuFZv(l0wQwCsl1PGoFg8n0wonIJfSO1cUhkHSyrqBP4lVhyq3lx0SKgjo0WILVsDKnIA))IRoqMZYAHcfmO7LlAwsJehdQJLVsDKnIA))IRoqMZYAb8n0wonIJfSO1cUhkHSyV5k(Y7bg09YfnlPrIJb1XYxPoYgrToqMZYAHcfmO7LlAwsJehAyXYFd(wfAyX6enlPrc1)sHcg09YfnlPrIdnSy5VbFRIb1X6enlPrI3dTLtZXVHvWZ2DzzzH9NFW3qB50iowWIwl4EOe(nScF59ad6E5IML0iXHgwS8vQJSruRdK5SSwOqbd6E5IML0iXXG6y5VbFRIb1X6enlPrI3dTLtZXVHvWZ2DzzzHr9VWgSbdd]] )


end
