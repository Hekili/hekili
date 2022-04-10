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


    spec:RegisterPack( "Feral", 20220408, [[dSKtkcqiuv6riOCjkLcBIs8jeGrPQYPuv1Qes8kkfZcHClHuTls(LQcdtvPoMqSmevpdvftJsjxdbABcj13qqvJtvjLZPQKkwNQsY8qqUhISpufhebuwOQIEOQsyIukLSrHK0hPuk6KiGQvIOmtkLQUPQsQANOk9tvLOgQQsQ0sra5PizQOQ6RukLASukv2lP(RGbRYHfTyi9ykMmixMyZG6ZQIrluNwQvlKeVMs1Sr52Qs7wXVbgoQCCvLilxPNd10P66qSDkPVJugVqkNhHA9iOY8rQ2VK1r08RPGsx08s(3Kt(3267VMICYji5KRPCI5enfxASNpIMAYxrtfvLnzAkUKygiH08RPWaK1iAQy35WF1hF80EmcQYaE)a3ViS0BWy2e2)a3VMp0uOinZjWhnQMckDrZl5Fto5FBRV)AkYjNGriiF0ujIhdwnfv)(fAQ4gcsgnQMcsWgnvuv2KvNT1I0qfzeyCBZQ7RruDK)n5KxKvK9fX58i4VQil61bTinKcqJrtsRsWKoPi1zIfJDCDoOoOfPHuaAmAsAvcM0vfzrVUVamwL1R7t(RJdayHvWaK1i15G6OLTxNenUvW4gm19lAK)xvKf96iWGGQRhx2fHZBuMuxuLj4yZMWEDnCDedqQloTk1napUNN6egwQZb1bbufzrVoBlWqaEDXaguDFbyScSl1bd26iqnxDidtW46igGqamwDRKmgX1rGAovrw0RJcHJdSEDWnJjBDei5zb0846Of3mPooaG1ZtDWGTUpzaaKNmWGvfzrVoBBWAVoWuhbguY5TvPokA5(whgHJdSUstXASJ18RPqzaaKNmWG18R5nIMFnLmjktG0FQPsJ3GrtTPDrtz22LTtn1V64BDEBS3ZtD0Px3V6IOiVUOuhNS4g7Y4HxeM3CSw264HuDqaxTPDrX9IW8MJ1Yw3)6OtVUF1LgVTkbup4B)8ilUos1rEDwQBf4vWXjktQ7FD)RZsDOiWWkupSPDrbbOnAkdXgMe8CFehR5nI218sUMFnLmjktG0FQPsJ3GrtXqMCd9G56n9gmAkZ2USDQPwbEfCCIYK6SuhkcmSc1dVaWa3ROGa0gnLHydtcEUpIJ18gr7AE5JMFnLmjktG0FQPsJ3Grt5XBIJdM01uMTDz7utTc8k44eLj1zPoueyyfQh84nXXkiaTPol1bTinKYJ3ehhmPR82yhhEYEeOaycRaVcoUoEQ7xD2QoBQdZjmwWZ9rCSYJ3ehhmPxxuQZw19VUpQ7xDrQZM6EtSllXbRjdrQ7FDrVodyGqAx5j2LamydOmaasjtIYeinLHydtcEUpIJ18gr7AETLMFnLmjktG0FQPmB7Y2PMcfbgwH6b0fXtwaZsCSccqB0uPXBWOPqxepzbmlXXAxZlb18RPKjrzcK(tnLzBx2o1uOiWWkupGP1CIccqBQZsDyoHXcEUpIJvyAnNemPxhp1frtLgVbJMctR5KGjDTR5nQ18RPKjrzcK(tnLzBx2o1uOiWWkupGJxbsbbOnAQ04ny0u44vG0UMxcVMFnLmjktG0FQPmB7Y2PMcfbgwH6bmTMtuqaAJMknEdgnfMwZjbt6AxZ7xtZVMsMeLjq6p1uMTDz7utHIadRq9GhVjowbbOnAQ04ny0uE8M44GjDTRDnfCpnowwn)AEJO5xtjtIYei9NAkyWggjAUM3iAQ04ny0uCaalScgGSgr7AEjxZVMsMeLjq6p1uMTDz7utHIadRWP18rclix1kVzp46iuD8rtLgVbJMcNwZhjSGC1UMx(O5xtjtIYei9NAkZ2USDQP(vh0I0qkUTFtwG2MESYBJDC4j7rGcGjSc8k4464Po(uxuQ7xDyoHXcEUpIJvCB)MSaTn946SPUi19Vol1H5egl45(iowXT9BYc020JRJN6Iu3)6OtVomNWybp3hXXkUTFtwG2MECD8u3V64tD2uxK6IsDEYKXv4evwha8yLmjktGQ7VMknEdgnf32VjlqBtpw7AETLMFnLmjktG0FQPsJ3GrtTnNMYSTlBNAQvGxbhNOmPol1bTinKABoL3g74Wt2Jafatyf4vWX1XtDwZTtuMO2Ml4TXoUol19RUF1HIadR8(rwCagzjwHWvhD61X3682yVNN6(xNL6(vhkcmScLbaqEYadwHWvhD61X368KjJRqzaaKNmWGvYKOmbQU)1rNED8TopzY4kCIkRdaESsMeLjq19Vol19RomNWybp3hXXkUTFtwG2MECDKQlsD0PxhFRZtMmUIB73KfOTPhRKjrzcuD)RZsD)QlnEBvcqaxTnxDKQ776OtVoVn275Pol1LgVTkbiGR2MRos1fPo60RJV1TiJad2hrbTjYtShaWbir4cWadcwjtIYeO6OtVo(wNNmzCforL1bapwjtIYeO6(RPmeBysWZ9rCSM3iAxZlb18RPKjrzcK(tnLzBx2o1uOiWWkCAnFKWcYvTYB2dUocv3V6mGxuqGd0JJRZM6Iu3)6IsDrDDrPUVv8rtLgVbJMcNwZhjSGC1UM3OwZVMsMeLjq6p1uVz0cYi7dXAEJOPsJ3GrtbllW0aeCaTDrtzi2WKGN7J4ynVr0UMxcVMFnLmjktG0FQPsJ3GrtbllW0aeCaTDrtz22LTtnfkcmScfh6XOq4QZsDEYKXvyaclaGdESeGbRGDLmjktGQJo96maadcqBugWyfyxcESeWC92owTYB2dUocvxK6SuNbyvMCC10pXEaofnLHydtcEUpIJ18gr7AE)AA(1uYKOmbs)PMYSTlBNAkS4EppyfCZyYgw5zb0846SuhwyIXBWe8(vQJN6IOiyDrPUhdK6nJMMknEdgn1kplGMhRDTRPqtwogrZVM3iA(1uYKOmbs)PMYSTlBNAkueyyLyynhwcyalxfeG2uNL6qrGHvIH1CyjWqMCvqaAtDwQ7xDRaVcoorzsD0Px3V6sJ3wLGmYBl464PUi1zPU04TvjabCfgzG7vQJq1LgVTkbzK3wW19VU)AQ04ny0uyKbUxr7AEjxZVMsMeLjq6p1uMTDz7utHIadRedR5Wsady5Qw5n7bxhp1f576SPotI9G3VsD0PxhkcmSsmSMdlbgYKRAL3ShCD8uxKVRZM6mj2dE)kAQ04ny0uypxmY(iAxZlF08RPKjrzcK(tnLzBx2o1uOiWWkXWAoSeyitUQvEZEW1XtDMe7bVFL6OtVoueyyLyynhwcyalxfeG2uNL6WawUbXWAoSuhp19DD0PxhkcmSsmSMdlbmGLRccqBQZsDmKj3GyynhwQl61LgVbJI2MESQNamRFI96iuDr0uPXBWOPWEUW9kAxZRT08RPKjrzcK(tnLzBx2o1uOiWWkXWAoSeWawUQvEZEW1XtDMe7bVFL6OtVoueyyLyynhwcmKjxfeG2uNL6yitUbXWAoSux0RlnEdgfTn9yvpbyw)e71XtDFRPsJ3GrtrBtpw7AxtHfhHtZVM3iA(1uYKOmbs)PMYSTlBNAkdWQm54QrmlGbwO6SuhMtySGN7J4yLhVjooysVocvNTQZsDgWlkiWb6XX1rO6iyDwQJV15TXEpp1zPo(whkcmScfh6XOq40uPXBWOPyitUHEWC9MEdgTR5LCn)AkzsuMaP)utbd2WirZ18grtLgVbJMIdayHvWaK1iAxZlF08RPKjrzcK(tnLzBx2o1uEYKXvWYMSa8kdHJyLmjktGQZsDgaGbbOnkyztwaELHWrScHRol1X36qrGHv40A(iHfKRcHRol1zaVOGahOhhxhp1fPol1bbC1M2fL3g798uNL6(vheWvmKj3qpyUEtVbJYBJ9EEQJo964BDEYKXvmKj3qpyUEtVbJsMeLjq19xtLgVbJMcNwZhjSGC1UMxBP5xtjtIYei9NAkSy0u)Q7xDrIqW6IEDKZN6IsDOiWWQEm5oP3GjyVNNaao4XsiQGmpmrHWv3)6IED)QtgzFiwzq2vgVoBQJpkcwxuQtgzFiwTYJm1ztD)QZwFxxuQdfbgwzysUMe798Oq4Q7FD)R7FDFuNmY(qSALhz0uPXBWOPOLTRPmB7Y2PMYtMmUcLbaqEYadwjtIYeO6SuhkcmScLbaqEYadwbbOn1zPU04TvjG6bF7NhzX1rQUV1UMxcQ5xtjtIYei9NAkZ2USDQP8KjJRqzaaKNmWGvYKOmbQol1HIadRqzaaKNmWGvqaAtDwQ7xDgWlkiWb6XX1rO6iyD0PxhMtySGN7J4yLhVjooysVos1fPU)AQ04ny0uMKXcPXBWeyn21uSg7HjFfnfkdaG8KbgS218g1A(1uYKOmbs)PMknEdgnLjzSqA8gmbwJDnfRXEyYxrtzaageG2ODnVeEn)AkzsuMaP)utz22LTtnLb8IccCGECCD8uhFQZsD)QdfbgwHYaaipzGbRq4QJo964BDEYKXvOmaaYtgyWkzsuMav3Fnf2324AEJOPsJ3GrtzsglKgVbtG1yxtXAShM8v0uW904yz1U21uqcCIWCn)AEJO5xtjtIYei9NAkZ2USDQPqrGHvVaWyVNamyFviC1zPo(wh0I0qkangnjTkbt6AkSVTX18grtLgVbJMArMqA8gmbwJDnfRXEyYxrtHMSCmI218sUMFnLmjktG0FQPmB7Y2PMcArAifGgJMKwLGjDnf2324AEJOPsJ3GrtzsglKgVbtG1yxtXAShM8v0uaAmAsAv0UMx(O5xtjtIYei9NAkibB2MZBWOP(6UaAS6OflJyv264ayCJYenvA8gmAkUfqJPDnV2sZVMsMeLjq6p1uMTDz7utHIadRmPhGb7RccqB0uPXBWOP8(rwCagzjw7AEjOMFnLmjktG0FQPmB7Y2PMcfbgwzspad2xfeG2OPsJ3Grtzspad2xTR5nQ18RPKjrzcK(tnfKGnBZ5ny0uF5rQdhd86WUKmpwtLgVbJMArMqA8gmbwJDnf2324AEJOPmB7Y2PMcfbgwHJtiaTxHbPq4QJo96qrGHvClGgtHWPPyn2dt(kAkSljZJ1UMxcVMFnvA8gmAkSDeglGM4ynLmjktG0FQDnVFnn)AkzsuMaP)utz22LTtnvA82QeGaUABU6iv33AkSVTX18grtLgVbJMYKmwinEdMaRXUMI1ypm5ROPWIJWPDnVFD08RPKjrzcK(tnvA8gmAktYyH04nycSg7AkwJ9WKVIMYaamiaTr7AEJ8TMFnLmjktG0FQPsJ3GrtTnNMcsWMT58gmAkEfZcyGf6RQ7lsSxhFQdS1zR6mGxuqDCGE862MdxhyQd3ZdtQZZ9r86aioUHK6aW1Hklww71b26Gq2EEQdvwSS2RRHRdw2Kvh8kdHJ46ACDiC19Ljq1LCCmIRlRJGgU6iqnxD0ILPo(JQ1146q4QlhO6O1mwDyayQdozS6aWWknLzBx2o1ugGvzYXvJywadSq1zPUF1X368KjJRqzaaKNmWGvYKOmbQo60RdfbgwHYaaipzGbRq4Q7FDwQdZjmwWZ9rCSYJ3ehhmPxhP6IuNL6(vNb8IccCGECCD8uh51zPUvGxbhNOmPol1bTinKABoL3g74Wt2Jafatyf4vWX1XtDwZTtuMO2Ml4TXoUol19Ro(whkcmScfh6XOq4QJo96maadcqBuO4qpgfcxD0Px3V6qrGHvO4qpgfcxDwQZaamiaTrblBYcWRmeoIviC19VU)1rNEDgWlkiWb6XX1rQocwNL6qrGHvE)iloaJSeRq4QZsDOiWWkVFKfhGrwIvR8M9GRJq1zR6Suh0I0qQT5uEBSJdpzpcuamHvGxbhxhp1rW6(RDnVrIO5xtjtIYei9NAkZ2USDQPmGxuqGd0JJRJhs19Rocwx0RZAUDIYefmaznCb02L6(RPW(2gxZBenvA8gmAQfzcPXBWeyn21uSg7HjFfnfCpnowwTR5nc5A(1uYKOmbs)PMYSTlBNAkOfPHuCB)MSaTn9yL3g74Wt2Jafatyf4vWX1XdP6i)76SuNb8IccCGECCD8qQoY1uPXBWOP42(nzbAB6XAkwpsWaPPiO218gHpA(1uYKOmbs)PMcsWMT58gmAQVEeM3r)Xavh2LK5XAQ04ny0uMKXcPXBWeyn21uyFBJR5nIMYSTlBNAkueyyfko0JrHWPPyn2dt(kAkSljZJ1UM3i2sZVMsMeLjq6p1uMTDz7utHf375bRGBgt2WkplGMhxNL68KjJRqzaaKNmWGvYKOmbQol1HIadRqzaaKNmWGvqaAtDwQlnEBvcOEW3(5rwCDKQ776SuxefbRlk19yGuVz0QJq19RUF19RUiriyDrVoY5tDrPoueyyvpMCN0BWeS3Ztaah8yjevqMhMOq4Q7FDrVUF1jJSpeRmi7kJxNn1XhfbRlk1jJSpeRw5rM6SPUF1zRVRlk1HIadRmmjxtI9EEuiC19VU)19VUpQtgzFiwTYJm19xtLgVbJMALNfqZJ1UM3ieuZVMsMeLjq6p1uqc2SnN3GrtXFSu3la71jrJtgCBvQ7t(RZqSHj19J)4vWX1rfVcuDu0AoPoda71fjcbRtgzFiMO6Et7sDyKvQJMuNjN6Et7sDEC611tD2QUhganz4)AkSy0u)Q7xDrIqW6IEDKZN6IsDOiWWQEm5oP3GjyVNNaao4XsiQGmpmrHWv3)6IED)QtgzFiwzq2vgVoBQJpkcwxuQtgzFiwTYJm1ztD)QZwFxxuQdfbgwzysUMe798Oq4Q7FD)R7FDFuNmY(qSALhz0uPXBWOPOLTRPmB7Y2PMYtMmUcLbaqEYadwjtIYeO6SuhkcmScLbaqEYadwbbOn1zPU04TvjG6bF7NhzX1rQUV1UM3irTMFnLmjktG0FQPmB7Y2PMYtMmUcLbaqEYadwjtIYeO6SuhkcmScLbaqEYadwbbOnAQ04ny0ulYesJ3GjWASRPyn2dt(kAkugaa5jdmyTR5ncHxZVMsMeLjq6p1uPXBWOPGLfyAacoG2UOPmB7Y2PMcfbgwLCs0cCRaLoyXbZMw75rHWPPmeBysWZ9rCSM3iAxZBKVMMFnLmjktG0FQPGbByKO5AEJOPsJ3GrtXbaSWkyaYAeTR5nYxhn)AkzsuMaP)utLgVbJMAt7IMYSTlBNAQF1Tc8k44eLj1rNEDCYIBSlJhEryEZXAzRJN6GaUAt7II7fH5nhRLTU)1zPoOfPHuBAxuEBSJdpzpcuamHvGxbhxhp1H5egl45(iowHP1CsWKEDrPoYRl61rUMYqSHjbp3hXXAEJODnVK)TMFnLmjktG0FQPsJ3GrtXqMCd9G56n9gmAkZ2USDQP(v3kWRGJtuMuhD61XjlUXUmE4fH5nhRLToEQdc4kgYKBOhmxVP3GrX9IW8MJ1Yw3)6Suh0I0qkgYKBOhmxVP3Gr5TXoo8K9iqbWewbEfCCD8uhMtySGN7J4yfMwZjbt61fL6iVUOxh5AkdXgMe8CFehR5nI218sEen)AkzsuMaP)utbd2WirZ18grtLgVbJMIdayHvWaK1iAxZl5KR5xtjtIYei9NAQ04ny0uE8M44GjDnLzBx2o1uRaVcoorzsDwQdArAiLhVjooysx5TXoo8K9iqbWewbEfCCD8u3V6SvD2uhMtySGN7J4yLhVjooysVUOuNTQ7FDFu3V6IuNn19MyxwIdwtgIu3)6IEDgWaH0UYtSlbyWgqzaaKsMeLjq1f96maRYKJRgXSagyHQZsD)QJV1HIadRqXHEmkeU6OtVomNWybp3hXXkpEtCCWKED8uxK6(RPmeBysWZ9rCSM3iAxZl58rZVMsMeLjq6p1uWGnms0CnVr0uPXBWOP4aawyfmaznI218sUT08RPKjrzcK(tnLzBx2o1u)QBZgkiwLXvjeew1tD8u3V6IuNn19MrlyIZ9rW1f96mX5(i4a8MgVbtYQ7FDrPUvmX5(ibVFL6(xNL6(vhMtySGN7J4yf6I4jlGzjoUUOuxA8gmk0fXtwaZsCSckFZhPUpQlnEdgf6I4jlGzjowzayVU)1XtD)QlnEdgfoEfifu(MpsDFuxA8gmkC8kqkda719xtLgVbJMcDr8KfWSehRDnVKtqn)AkzsuMaP)utz22LTtnfMtySGN7J4yfMwZjbt61XtDrQZM6qrGHvO4qpgfcxDrPoY1uPXBWOPW0Aojysx7AEjpQ18RPKjrzcK(tnLzBx2o1uyoHXcEUpIJvE8M44Gj964Po(OPsJ3Grt5XBIJdM01UMxYj8A(1uYKOmbs)PMYSTlBNAkueyyLHj5AsS3ZJcHRol19RoueyyfgbcsMq(IIGJvqaAtDwQdfbgwHJtiaTxHbPGa0M6OtVoueyyfko0JrHWv3FnvA8gmAkC8kqAxZl5Fnn)AkzsuMaP)utLgVbJMYKmwinEdMaRXUMI1ypm5ROPGBgtwTRDnf3kgWlA6A(18grZVMsMeLjq6p1uaonfwCnvA8gmAkR52jkt0uwtgIOP(wtzn3WKVIMcgGSgUaA7I218sUMFnLmjktG0FQPaCAkS4AQ04ny0uwZTtuMOPSMmertfrtbjyZ2CEdgnfv8kq1rQUVjQoEbt0XtYHJbEDeO0UuhP6IquDutYHJbEDeO0UuhP6iNO6S9e41rQo(quDu0AoPos1zlnL1Cdt(kAk4MXKv7AE5JMFnLmjktG0FQPaCAkS4AQ04ny0uwZTtuMOPSMmertr41uwZnm5ROP2Ml4TXow7AETLMFnvA8gmAk79aTcuaZ1B7ynLmjktG0FQDnVeuZVMknEdgnfkWDMafGzjXceTEEcoiA9OPKjrzcK(tTR5nQ18RPKjrzcK(tnLzBx2o1uyacdThifhc2rysqweoVbJsMeLjq1rNEDyacdThiLval9MjbmGzvgxjtIYeinvA8gmAkyMGJnBc7AxZlHxZVMsMeLjq6p1uMTDz7utHIadREbGXEpbyW(QGa0gnvA8gmAkUfqJPDnVFnn)AkzsuMaP)utz22LTtnfkcmS6fag79eGb7RccqB0uPXBWOPmPhGb7R218(1rZVMsMeLjq6p1uaonfwCnvA8gmAkR52jkt0uwtgIOP(wtbjyZ2CEdgn1xKMyPoaCDP5lH0RavNVsIrwbxheqW1naVoSiV15G6Obw71rS41LduDXjUohuhQuhwKrtzn3WKVIMcmbeSe8Th7IRDnVr(wZVMsMeLjq6p1uaonvcbPPsJ3Grtzn3orzIMYAYqenvenLzBx2o1u)QZ3ESlUYJOItCablbuey46SuNV9yxCLhrzaageG2OGq20BWu3)6OtVoF7XU4kpIQXQEWMfXtuMe(si54iVbiXABenL1Cdt(kAkWeqWsW3ESlU218gjIMFnLmjktG0FQPaCAQecstLgVbJMYAUDIYenL1KHiAkY1uMTDz7ut9RoF7XU4kNCvCIdiyjGIadxNL68Th7IRCYvgaGbbOnkiKn9gm19Vo60RZ3ESlUYjx1yvpyZI4jktcFjKCCK3aKyTnIMYAUHjFfnfyciyj4Bp2fx7AEJqUMFnLmjktG0FQPaCAkS4AQ04ny0uwZTtuMOPSMmertf1r0uwZnm5ROPEZOf8Th7IhIbmiTRDnfCZyYQ5xZBen)AkzsuMaP)utLgVbJMAt7IMYSTlBNAkR52jktuWnJjBDKQlsDwQBf4vWXjktQZsDqaxTPDrX9IW8MJ1YwhHivxef51fL64Kf3yxgp8IW8MJ1YQPmeBysWZ9rCSM3iAxZl5A(1uYKOmbs)PMYSTlBNAkR52jktuWnJjBDKQJCnvA8gmAQnTlAxZlF08RPKjrzcK(tnLzBx2o1uwZTtuMOGBgt26ivhF0uPXBWOPyitUHEWC9MEdgTR51wA(1uYKOmbs)PMYSTlBNAkR52jktuWnJjBDKQZwAQ04ny0uyAnNemPRDnVeuZVMsMeLjq6p1uMTDz7utHIadRWiqqYeYxueCSccqB0uPXBWOPWXRaPDnVrTMFnLmjktG0FQPmB7Y2PMclU3Zdwb3mMSHvEwanpUol1HfMy8gmbVFL64PUikcwxuQ7XaPEZOPPsJ3GrtTYZcO5XAx7AkSljZJ18R5nIMFnLmjktG0FQPGbByKO5AEJOPsJ3GrtXbaSWkyaYAeTR5LCn)AkzsuMaP)utLgVbJMAt7IMYqSHjbp3hXXAEJOPmB7Y2PM6xDqaxTPDrX9IW8MJ1YwhHQlIIG1rNEDRaVcoorzsD)RZsDqlsdP20UO82yhhEYEeOaycRaVcoUoEQJ86OtVUF1XjlUXUmE4fH5nhRLToEQdc4QnTlkUxeM3CSw26SuhkcmScfh6XOq4QZsDyoHXcEUpIJvE8M44Gj96iuD8Pol1zawLjhxnIzbmWcv3)6OtVoueyyfko0JrTYB2dUocvxenfKGnBZ5ny0ueO0Uu3iceUUfG8eZiUoc(TTrDa46AhxhtMhpUU0RlR7TN(f5Tohuhgz5smUoC8kq46G4eTR5LpA(1uYKOmbs)PMYSTlBNAkmNWybp3hXXkpEtCCWKEDeQo(uNL6wbEfCCIYK6Suh0I0qkgYKBOhmxVP3Gr5TXoo8K9iqbWewbEfCCD8uhbRZsD)QZaErbboqpoUos1zR6OtVoiGRyitUHEWC9MEdg1kVzp46iuDeSo60RJV1bbCfdzYn0dMR30BWO82yVNN6(RPsJ3GrtXqMCd9G56n9gmAxZRT08RPKjrzcK(tnvA8gmAk0fXtwaZsCSMcsWMT58gmAQpxepz1rXsCCDnUouXDzRZJZPoSljZJRJkEfO6sVo(uNN7J4ynLzBx2o1uyoHXcEUpIJvOlINSaML4464PoY1UMxcQ5xtjtIYei9NAkyWggjAUM3iAQ04ny0uCaalScgGSgr7AEJAn)AkzsuMaP)utz22LTtnLb8IccCGECCDeQoBvNL6WCcJf8CFehR84nXXbt61rO6iOMknEdgnfoEfiTRDnLbayqaAJMFnVr08RPKjrzcK(tnvA8gmAQek582QeW0Y9vtz22LTtn1V6(vhFRdc4Qek582QeW0Y9naLV5JO82yVNN6OtVoiGRsOKZBRsatl33au(MpIAL3ShCDeQoYR7FDwQ7xDqaxLqjN3wLaMwUVbO8nFef2tJ96iuD8Po60RJV1bbCvcLCEBvcyA5(gILKPWEASxhp1fPU)1zPo(whkcmSkHsoVTkbmTCFdXsYc9eGz9tSRq4QZsD8ToueyyvcLCEBvcyA5(gGY38rc9eGz9tSRq4Q7FDwQZZ9rCL3VsWbbOwQJN6iyD0PxxA82QeKrEBbxhp1rEDwQJV1bbCvcLCEBvcyA5(gGY38ruEBS3ZtDwQtgzFiUocvhFiyDwQZZ9rCL3VsWbbOwQJN6iOMYqSHjbp3hXXAEJODnVKR5xtjtIYei9NAkZ2USDQP(vhgGWq7bsXHGDeMeKfHZBWOKjrzcuD0PxhgGWq7bszfWsVzsadywLXvYKOmbQU)AQECzxeop0WAkmaHH2dKYkGLEZKagWSkJRP6XLDr48q)(kqD6IMkIMknEdgnfmtWXMnHDnvpUSlcNhEya0KPPIODnV8rZVMsMeLjq6p1uPXBWOP8Th7Ihrtz22LTtn1V6(vNbayqaAJYagRa7sWJLaMR32XQvEZEW1rO6iVol19Roueyyfko0JrHWvhD61zaageG2OqXHEmQvEZEW1XtDr(UU)19Vo60RdfGX1zPo4(j2dR8M9GRJq1r(319Vo60R7xDgaGbbOnkdyScSlbpwcyUEBhRw5n7bxx0RJ864PoR52jktuVz0c(2JDXdXaguD)RJo96SMBNOmrbMacwc(2JDXRJuDFxhD619RoR52jktuGjGGLGV9yx86ivh51zPUF1zaageG2OmGXkWUe8yjG56TDSAL3ShCD8uh5KxhD61HcW46SuhC)e7HvEZEW1rO6i)76OtVoF7XU4kNCLbayqaAJAL3ShCD8uh5Fx3)6(RPWmGJ1u(2JDXJODnV2sZVMsMeLjq6p1uPXBWOP8Th7ItUMYSTlBNAQF19RodaWGa0gLbmwb2LGhlbmxVTJvR8M9GRJq1rEDwQ7xDOiWWkuCOhJcHRo60RZaamiaTrHId9yuR8M9GRJN6I8DD)RZsD)QZ3ESlUYJOmaadcqBuR8M9GRJhs1rED0PxN1C7eLjkWeqWsW3ESlEDKQJ86(x3)6OtVouagxNL6G7NypSYB2dUocvh5Fx3)6OtVUF19RodaWGa0gLbmwb2LGhlbmxVTJvR8M9GRl61rED2uxu)DDrPUF19RoF7XU4kpIYaamiaTrTYB2dUocvNbayqaAJYagRa7sWJLaMR32XQvEZEW1f96iVU)1zPUF1zn3orzIcmbeSe8Th7IxhP6IuhD61zn3orzIcmbeSe8Th7IxhpKQJp19VU)19VoEQZAUDIYe1BgTGV9yx8qmGbv3)6OtVoR52jktuGjGGLGV9yx86iv331rNED)QZAUDIYefyciyj4Bp2fVos1fPol19RodaWGa0gLbmwb2LGhlbmxVTJvR8M9GRJN6iN86OtVouagxNL6G7NypSYB2dUocvh5FxhD615Bp2fx5rugaGbbOnQvEZEW1XtDK)DD)R7VMcZaowt5Bp2fNCTR5LGA(1uYKOmbs)PMcsWMT58gmAQViXED83pYsa46IQilX1HkWGvQ7hyRRFFfOoDgX1LWUS)RZKyVNN6IQYMS6IQRmeoIRRHR7tzXYAVUgxhVFz(Rdm1zaageG2O0uyIhJMcw2KfGxziCeRPmB7Y2PMYaamiaTrHId9yuiCAQ04ny0uE)iloaJSeRDnVrTMFnLmjktG0FQPsJ3GrtblBYcWRmeoI1uMTDz7utzaVOGahOhhxhHQJp1zPop3hXvE)kbheGAPoEQJWxNL6(vhkcmScNwZhjSGCviC1rNED8TopzY4kCAnFKWcYvjtIYeO6(xNL6(vhFRZaamiaTr59JS4amYsScHRo60RZaamiaTrHId9yuiC19Vo60RdfGX1zPo4(j2dR8M9GRJq191QZsDW9tShw5n7bxhp1rUMYqSHjbp3hXXAEJODnVeEn)AkzsuMaP)utLgVbJMcvwSS21uqc2SnN3GrtX)x226l)v1XRiq15G6WepM6O1ECD0ApUUnTkdabxh8kdHJ46OfltD0K6wKPo4vgchXO5aruDGTU0zsI96mXIXEDnCDTJRJgy946Axtz22LTtnvA82QeGaUABU64PUVRZsD)QZaamiaTrzaJvGDj4XsaZ1B7yfcxD0PxNbayqaAJYagRa7sWJLaMR32XQvEZEW1XtD8H86OtVouagxNL6G7NypSYB2dUocvh5Fx3FTR59RP5xtjtIYei9NAkZ2USDQPsJ3wLaeWvBZvhp19DDwQ7xDgaGbbOnkdyScSlbpwcyUEBhRq4QJo96qbyCDwQdUFI9WkVzp46iuD8576(RPsJ3Grt1Jj3j9gmAxZ7xhn)AkzsuMaP)utLgVbJMY7hzXbyKLynfKGnBZ5ny0u8Vexxoq1naVoAj2L64pQwNmY(qmr1HI41LmmOUOcc2Rdbl11EDWGTocNS2RlhO66XK7G1uMTDz7utjJSpeRGe420ED8uNT(Uo60RdfbgwHId9yuiC1rNED)QZtMmUIBfO0bRsMeLjq1zPoCmyDb7b3HQJq1XN6(xhD619RU04TvjabC12C1rQUVRZsDOiWWkugaa5jdmyfcxD)1UM3iFR5xtjtIYei9NAQ04ny0u44ecq7vyqAkibB2MZBWOP(67NyVouPoAlyEQZb1HGL6OEfguDGPocuAxQRN6SklX1zvwIRBAtSuhUDK0BWGjQoueVoRYsCDBUcJynLzBx2o1uOiWWkVFKfhGrwIviC1zPoueyyfko0JrbbOn1zPod4ffe4a9446iuD2Qol1HIadRWiqqYeYxueCSccqBQZsDqaxTPDrX9IW8MJ1YwhHQlIkQRZsDYi7dX1XtD2676Suh0I0qQnTlkVn2XHNShbkaMWkWRGJRJN6WCcJf8CFehRW0AojysVUOuh51f96iVol155(iUY7xj4Gaul1XtDeu7AEJerZVMsMeLjq6p1uMTDz7utHIadR8(rwCagzjwHWvhD61HIadRqXHEmkeonvA8gmAkuzXYAVNhTR5nc5A(1uYKOmbs)PMYSTlBNAkueyyfko0JrHWvhD61HcW46SuhC)e7HvEZEW1rO6maadcqBuO4qpg1kVzp46OtVouagxNL6G7NypSYB2dUocvh5eutLgVbJMId4ny0UM3i8rZVMsMeLjq6p1uMTDz7utHIadRqXHEmkeU6OtVo4(j2dR8M9GRJq1rEenvA8gmAQnTkdabhGxziCeRDnVrSLMFnLmjktG0FQPsJ3GrtzaJvGDj4XsaZ1B7ynfKGnBZ5ny0u8)LTT(YFvDFrSySx3lam27PUyGtRUCGQd7iWW1XA7sDECJjQUCGQ7njgvQdvCx26mGx00RBL3SN6wbt8y0uMTDz7ut9RoiGR2MtTYB2dUoEQZw1zPod4ffe4a9446iuDeSol19RoiGR20UO82yVNN6OtVomNWybp3hXXkpEtCCWKED8uxK6(xNL6Kr2hIvqcCBAVoEivh5FxNL6maadcqBuO4qpg1kVzp464PUiFx3)6OtVouagxNL6G7NypSYB2dUocvhbRJo96(vhkcmScfh6XOq4QZsDOiWWkuCOhJAL3ShCD8uxeYR7V218gHGA(1uYKOmbs)PMknEdgnL8YbOjBafmqAkibB2MZBWOP(6tIrL68yzL6WXaeguDOsDVGvQZagO2BWGRdm15XsDgWaH0UMYSTlBNAkueyyL3pYIdWilXkeU6OtVUF1zades7kir4cjJjpDogrjtIYeO6(RDnVrIAn)AkzsuMaP)utbjyZ2CEdgnLTzBvQJBBW2oX15G6at0rWsD0KKdmAQjFfnvub4iZJ07gGeS3dX4GjzmnLzBx2o1uYxcP54eivub4iZJ07gGeS3dX4GjzmnvA8gmAQOcWrMhP3najyVhIXbtYyAxZBecVMFnvA8gmAkeSeAxEXAkzsuMaP)u7AxtbOXOjPvrZVM3iA(1uYKOmbs)PMYSTlBNAkueyyvSKRhaWbpwc0AgKcHttLgVbJMc75Ir2hr7AEjxZVMsMeLjq6p1uPXBWOPWidCVIMI1JemqAkBfLhdK218Yhn)AkzsuMaP)utLgVbJM6fag4EfnLzBx2o1uOiWWQxayS3tagSVkeU6SuhMtySGN7J4yLhVjooysVocvh51zPo(wNNmzCfdzYn0dMR30BWOKjrzcuDwQtgzFiUocvxu)DDwQJV1HIadRmmjxtI9EEuiCAkwpsWaPPSvuEmqAxZRT08RPKjrzcK(tnLzBx2o1uYi7dX1rO64Z31zPoiGR2MtTYB2dUoEQZwkcwNL6(vNbayqaAJY7hzXbyKLy1kVzp464HuDrTIG1rNEDlYiWG9ruM0fILGbzBGsMeLjq19Vol1HIadRmmjxtI9EEuypn2RJq1fPol1X36qrGHvjNeTa3kqPdwCWSP1EEuiC1zPo(whkcmScLbaqmeSRq4QZsD8Toueyyfko0JrHWvNL6(vNbayqaAJYagRa7sWJLaMR32XQvEZEW1XtDrTIG1rNED8TodWQm54QPFI9aCk19Vol19Ro(wNbyvMCC1iMfWaluD0PxNbayqaAJkHsoVTkbmTCFvR8M9GRJhs1rW6OtVoiGRsOKZBRsatl33au(MpIAL3ShCD8uhHVU)AQ04ny0uXsUEaah8yjqRzqAxZlb18RPKjrzcK(tnLzBx2o1uYi7dX1rO64Z31zPoiGR2MtTYB2dUoEQZwkcwNL6(vNbayqaAJY7hzXbyKLy1kVzp464HuD2srW6OtVUfzeyW(ikt6cXsWGSnqjtIYeO6(xNL6qrGHvgMKRjXEppkSNg71rO6IuNL64BDOiWWQKtIwGBfO0bloy20AppkeU6SuhFRdfbgwHYaaigc2viC1zPUF1X36qrGHvO4qpgfcxD0PxNbyvMCC1iMfWaluDwQZtMmUcNwZhjSGCvYKOmbQol1HIadRqXHEmQvEZEW1XtDrDD)RZsD)QZaamiaTrzaJvGDj4XsaZ1B7y1kVzp464PUOwrW6OtVo(wNbyvMCC10pXEaoL6(xNL6(vhFRZaSktoUAeZcyGfQo60RZaamiaTrLqjN3wLaMwUVQvEZEW1XdP6iyD0PxheWvjuY5TvjGPL7BakFZhrTYB2dUoEQJWx3)6SuhC)e7HvEZEW1XtDeEnvA8gmAQxayS3tagSVAx7AxtzvwCdgnVK)n5K)nFiNGAkA5o98G1u22eyeiEjW5128RQRo(JL66xoW61bd26ia4EACSSeqDR8Lq6vGQddEL6seh8MUavNjoNhbRkYS99i1zRVQUVamwL1fO6iGfzeyW(ikBhbuNdQJawKrGb7JOSDkzsuMara19ls0(RkYkYSTjWiq8sGZRT5xvxD8hl11VCG1RdgS1raqcCIWCcOUv(si9kq1HbVsDjIdEtxGQZeNZJGvfz2(EK6iN8VQUVamwL1fO6O63VOomXJNrRoBJ6CqD2EKSoO2AJBWuhGt20bBD)(4FD)IeT)QImBFpsDKBRVQUVamwL1fO6O63VOomXJNrRoBJ6CqD2EKSoO2AJBWuhGt20bBD)(4FD)ipA)vfzfz22eyeiEjW5128RQRo(JL66xoW61bd26iaUvmGx00jG6w5lH0Ravhg8k1Lio4nDbQotCopcwvKz77rQlY3FvDFbySkRlq1ra(2JDXvru2ocOohuhb4Bp2fx5ru2ocOUF8jA)vfz2(EK6Ie5RQ7laJvzDbQocW3ESlUICLTJaQZb1ra(2JDXvo5kBhbu3p(eT)QISImBBcmceVe48AB(v1vh)XsD9lhy96GbBDeakdaG8Kbgmbu3kFjKEfO6WGxPUeXbVPlq1zIZ5rWQImBFpsD85RQ7laJvzDbQoQ(9lQdt84z0QZ2OohuNThjRdQT24gm1b4KnDWw3Vp(x3Vir7VQiRiZ2MaJaXlboV2MFvD1XFSux)YbwVoyWwhbyaageG2qa1TYxcPxbQom4vQlrCWB6cuDM4CEeSQiZ23Juh5FvDFbySkRlq1rayacdThiLTJaQZb1rayacdThiLTtjtIYeicOUFKhT)QImBFpsD85RQ7laJvzDbQocW3ESlUICLTJaQZb1ra(2JDXvo5kBhbu3Vir7VQiZ23JuNT(Q6(cWyvwxGQJa8Th7IRIOSDeqDoOocW3ESlUYJOSDeqD)4t0(RkYkYSTjWiq8sGZRT5xvxD8hl11VCG1RdgS1raaAmAsAviG6w5lH0Ravhg8k1Lio4nDbQotCopcwvKz77rQZwFvDFbySkRlq1ralYiWG9ru2ocOohuhbSiJad2hrz7uYKOmbIaQ7xKO9xvKz77rQJGFvDFbySkRlq1ralYiWG9ru2ocOohuhbSiJad2hrz7uYKOmbIaQ7xKO9xvKvKrG)YbwxGQlY31LgVbtDSg7yvrMMcZjgnVr(MpAkUfa3mrtryewDrvztwD2wlsdvKryewDeyCBZQ7RruDK)n5KxKvKryewDFrCopc(RkYimcRUOxh0I0qkangnjTkbt6KIuNjwm2X15G6GwKgsbOXOjPvjysxvKryewDrVUVamwL1R7t(RJdayHvWaK1i15G6OLTxNenUvW4gm19lAK)xvKryewDrVocmiO66XLDr48gLj1fvzco2SjSxxdxhXaK6ItRsDdWJ75PoHHL6CqDqavrgHry1f96STadb41fdyq19fGXkWUuhmyRJa1C1HmmbJRJyacbWy1TsYyexhbQ5ufzegHvx0RJcHJdSEDWnJjBDei5zb0846Of3mPooaG1ZtDWGTUpzaaKNmWGvfzegHvx0RZ2gS2Rdm1rGbLCEBvQJIwUV1Hr44aRRkYkYsJ3GbR4wXaErt3gsFyn3orzcrt(kKGbiRHlG2UqK1KHiK(UiJWQJkEfO6iv33evhVGj64j5WXaVocuAxQJuDriQoQj5WXaVocuAxQJuDKtuD2Ec86ivhFiQokAnNuhP6SvrwA8gmyf3kgWlA62q6dR52jktiAYxHeCZyYsK1KHiKIuKLgVbdwXTIb8IMUnK(WAUDIYeIM8viTnxWBJDmrwtgIqIWxKLgVbdwXTIb8IMUnK(WEpqRafWC92oUilnEdgSIBfd4fnDBi9bkWDMafGzjXceTEEcoiA9uKLgVbdwXTIb8IMUnK(aMj4yZMWornmjmaHH2dKIdb7imjilcN3GrjtIYei60XaegApqkRaw6ntcyaZQmUsMeLjqfzPXBWGvCRyaVOPBdPp4wangrnmjueyy1lam27jad2xfeG2uKLgVbdwXTIb8IMUnK(WKEagSVe1WKqrGHvVaWyVNamyFvqaAtrgHv3xKMyPoaCDP5lH0RavNVsIrwbxheqW1naVoSiV15G6Obw71rS41LduDXjUohuhQuhwKPilnEdgSIBfd4fnDBi9H1C7eLjen5RqcmbeSe8Th7ItK1KHiK(UilnEdgSIBfd4fnDBi9H1C7eLjen5RqcmbeSe8Th7IteGJucbrudt6NV9yxCvevCIdiyjGIadBX3ESlUkIYaamiaTrbHSP3G5pD6(2JDXvrunw1d2SiEIYKWxcjhh5najwBJqK1KHiKIuKLgVbdwXTIb8IMUnK(WAUDIYeIM8vibMacwc(2JDXjcWrkHGiQHj9Z3ESlUICvCIdiyjGIadBX3ESlUICLbayqaAJccztVbZF609Th7IRix1yvpyZI4jktcFjKCCK3aKyTncrwtgIqI8IS04nyWkUvmGx00TH0hwZTtuMq0KVcP3mAbF7XU4HyadIiRjdrif1rkYkYsJ3GbtArMqA8gmbwJDIM8viHMSCmcryFBJtkcrnmjueyy1lam27jad2xfcNf(cTinKcqJrtsRsWKErwA8gmyBi9HjzSqA8gmbwJDIM8vibOXOjPvHiSVTXjfHOgMe0I0qkangnjTkbt6fzewDFDxanwD0ILrSkBDCamUrzsrwA8gmyBi9b3cOXkYsJ3GbBdPp8(rwCagzjMOgMekcmSYKEagSVkiaTPilnEdgSnK(WKEagSVe1WKqrGHvM0dWG9vbbOnfzegHvxA8gmyBi9H1C7eLjen5RqchdwxWEWDiISMmeHKN7J4kVFLGdcqTuKryewDPXBWGTH0hgInSEEcwZTtuMq0KVcjCmyDb7b3HicWr6ThISMmeHKN7J4kVFLGdcqTuKry19LhPoCmWRd7sY84IS04nyW2q6JfzcPXBWeyn2jAYxHe2LK5XeH9TnoPie1WKqrGHv44ecq7vyqkeo60rrGHvClGgtHWvKLgVbd2gsFGTJWyb0ehxKLgVbd2gsFysglKgVbtG1yNOjFfsyXr4ic7BBCsriQHjLgVTkbiGR2MJ03fzPXBWGTH0hMKXcPXBWeyn2jAYxHKbayqaAtrgHvhVIzbmWc9v19fj2RJp1b26SvDgWlkOooqpEDBZHRdm1H75Hj155(iEDaeh3qsDa46qLflR96aBDqiBpp1Hklww711W1blBYQdELHWrCDnUoeU6(YeO6soogX1L1rqdxDeOMRoAXYuh)r16ACDiC1LduD0AgRomam1bNmwDayyvrwA8gmyBi9X2Ce1WKmaRYKJRgXSagyHS8JVEYKXvOmaaYtgyWkzsuMarNokcmScLbaqEYadwHW93cMtySGN7J4yLhVjooysNuel)mGxuqGd0JJ5HClRaVcoorzIfOfPHuBZP82yhhEYEeOaycRaVcoMhR52jktuBZf82yhB5hFrrGHvO4qpgfchD6gaGbbOnkuCOhJcHJo9FOiWWkuCOhJcHZIbayqaAJcw2KfGxziCeRq4()NoDd4ffe4a94yse0ckcmSY7hzXbyKLyfcNfueyyL3pYIdWilXQvEZEWeYwwGwKgsTnNYBJDC4j7rGcGjSc8k4yEi4)IS04nyW2q6JfzcPXBWeyn2jAYxHeCpnowwIW(2gNueIAysgWlkiWb6XX8q6hbJU1C7eLjkyaYA4cOTl)lYsJ3GbBdPp42(nzbAB6Xe1WKGwKgsXT9BYc020JvEBSJdpzpcuamHvGxbhZdjY)2Ib8IccCGECmpKiNiwpsWarIGfzewDF9imVJ(JbQoSljZJlYsJ3GbBdPpmjJfsJ3GjWASt0KVcjSljZJjc7BBCsriQHjHIadRqXHEmkeUIS04nyW2q6JvEwanpMOgMewCVNhScUzmzdR8SaAESfpzY4kugaa5jdmyLmjktGSGIadRqzaaKNmWGvqaAJL04TvjG6bF7NhzXK(2sefbJYJbs9MrJq)(9lsecgDY5tuqrGHv9yYDsVbtWEppbaCWJLqubzEyIcH7F0)jJSpeRmi7kJBdFuemkYi7dXQvEKXMF267OGIadRmmjxtI9EEuiC))))dzK9Hy1kpY8ViJWQJ)yPUxa2RtIgNm42Qu3N8xNHydtQ7h)XRGJRJkEfO6OO1CsDga2RlsecwNmY(qmr19M2L6WiRuhnPoto19M2L6840RRN6SvDpmaAYW)lYsJ3GbBdPpOLTtewmK(9lsecgDY5tuqrGHv9yYDsVbtWEppbaCWJLqubzEyIcH7F0)jJSpeRmi7kJBdFuemkYi7dXQvEKXMF267OGIadRmmjxtI9EEuiC))))dzK9Hy1kpYqudtYtMmUcLbaqEYadwjtIYeilOiWWkugaa5jdmyfeG2yjnEBvcOEW3(5rwmPVlYimcRU04nyW2q6doaGfwbdqwJqudtYtMmUcLbaqEYadwjtIYeilOiWWkugaa5jdmyfeG2y5NmY(qSn8rrWOiJSpeRw5rgB(zRVJckcmSYWKCnj275rHW9)pH(fjcbJo58jkOiWWQEm5oP3GjyVNNaao4XsiQGmpmrHW93sA82Qeq9GV9ZJSysFxKLgVbd2gsFSitinEdMaRXort(kKqzaaKNmWGjQHj5jtgxHYaaipzGbRKjrzcKfueyyfkdaG8KbgSccqBkYsJ3GbBdPpGLfyAacoG2UqKHydtcEUpIJjfHOgMekcmSk5KOf4wbkDWIdMnT2ZJcHRilnEdgSnK(GdayHvWaK1iebd2WirZjfPilnEdgSnK(yt7crgInmj45(ioMueIAys)wbEfCCIYe605Kf3yxgp8IW8MJ1YYdeWvBAxuCVimV5yTS)TaTinKAt7IYBJDC4j7rGcGjSc8k4yEWCcJf8CFehRW0AojyspkKhDYlYsJ3GbBdPpyitUHEWC9MEdgImeBysWZ9rCmPie1WK(Tc8k44eLj0PZjlUXUmE4fH5nhRLLhiGRyitUHEWC9MEdgf3lcZBowl7FlqlsdPyitUHEWC9MEdgL3g74Wt2Jafatyf4vWX8G5egl45(iowHP1CsWKEuip6KxKLgVbd2gsFWbaSWkyaYAeIGbByKO5KIuKLgVbd2gsF4XBIJdM0jYqSHjbp3hXXKIqudtAf4vWXjktSaTinKYJ3ehhmPR82yhhEYEeOaycRaVcoMNF2YgmNWybp3hXXkpEtCCWKEuS1FBJFrS5nXUSehSMme5F0nGbcPDLNyxcWGnGYaaiLmjktGIUbyvMCC1iMfWalKLF8ffbgwHId9yuiC0PJ5egl45(iow5XBIJdM05jY)IS04nyW2q6doaGfwbdqwJqemydJenNuKIS04nyW2q6d0fXtwaZsCmrnmPFB2qbXQmUkHGWQE45xeBEZOfmX5(i4OBIZ9rWb4nnEdMK9pkRyIZ9rcE)k)T8dZjmwWZ9rCScDr8KfWSehhL04nyuOlINSaML4yfu(MpITrA8gmk0fXtwaZsCSYaW(FE(LgVbJchVcKckFZhX2inEdgfoEfiLbG9)fzPXBWGTH0hyAnNemPtudtcZjmwWZ9rCSctR5KGjDEIydkcmScfh6XOq4Ic5fzPXBWGTH0hE8M44GjDIAysyoHXcEUpIJvE8M44GjDE4trwA8gmyBi9boEfiIAysOiWWkdtY1KyVNhfcNLFOiWWkmceKmH8ffbhRGa0glOiWWkCCcbO9kmifeG2qNokcmScfh6XOq4(xKLgVbd2gsFysglKgVbtG1yNOjFfsWnJjBrwrwA8gmyfkdaG8KbgmPnTlezi2WKGN7J4ysriQHj9JVEBS3ZdD6)IOipkCYIBSlJhEryEZXAz5HeeWvBAxuCVimV5yTS)Pt)xA82Qeq9GV9ZJSysKBzf4vWXjkt()3ckcmSc1dBAxuqaAtrwA8gmyfkdaG8KbgSnK(GHm5g6bZ1B6nyiYqSHjbp3hXXKIqudtAf4vWXjktSGIadRq9WlamW9kkiaTPilnEdgScLbaqEYad2gsF4XBIJdM0jYqSHjbp3hXXKIqudtAf4vWXjktSGIadRq9GhVjowbbOnwGwKgs5XBIJdM0vEBSJdpzpcuamHvGxbhZZpBzdMtySGN7J4yLhVjooyspk26VTXVi28MyxwIdwtgI8p6gWaH0UYtSlbyWgqzaaKsMeLjqfzPXBWGvOmaaYtgyW2q6d0fXtwaZsCmrnmjueyyfQhqxepzbmlXXkiaTPilnEdgScLbaqEYad2gsFGP1CsWKornmjueyyfQhW0AorbbOnwWCcJf8CFehRW0AojysNNifzPXBWGvOmaaYtgyW2q6dC8kqe1WKqrGHvOEahVcKccqBkYsJ3GbRqzaaKNmWGTH0hyAnNemPtudtcfbgwH6bmTMtuqaAtrwA8gmyfkdaG8KbgSnK(WJ3ehhmPtudtcfbgwH6bpEtCSccqBkYkYsJ3GbRmaadcqBiLqjN3wLaMwUVezi2WKGN7J4ysriQHj97hFHaUkHsoVTkbmTCFdq5B(ikVn275HoDiGRsOKZBRsatl33au(MpIAL3ShmHi)VLFqaxLqjN3wLaMwUVbO8nFef2tJDcXh605leWvjuY5TvjGPL7BiwsMc7PXopr(BHVOiWWQek582QeW0Y9neljl0taM1pXUcHZcFrrGHvjuY5TvjGPL7BakFZhj0taM1pXUcH7Vfp3hXvE)kbheGAHhcsNEA82QeKrEBbZd5w4leWvjuY5TvjGPL7BakFZhr5TXEppwKr2hIjeFiOfp3hXvE)kbheGAHhcwKLgVbdwzaageG2ydPpGzco2SjStudt6hgGWq7bsXHGDeMeKfHZBWqNogGWq7bszfWsVzsadywLX)tupUSlcNh63xbQtxifHOECzxeop8WaOjJueI6XLDr48qdtcdqyO9aPScyP3mjGbmRY4fzPXBWGvgaGbbOn2q6deSeAxEXeHzahtY3ESlEeIAys)(zaageG2OmGXkWUe8yjG56TDSAL3ShmHi3Ypueyyfko0JrHWrNUbayqaAJcfh6XOw5n7bZtKV))NoDuagBbUFI9WkVzpycr(3)Pt)NbayqaAJYagRa7sWJLaMR32XQvEZEWrNCESMBNOmr9Mrl4Bp2fpedyq)Pt3AUDIYefyciyj4Bp2fN030P)ZAUDIYefyciyj4Bp2fNe5w(zaageG2OmGXkWUe8yjG56TDSAL3ShmpKtoD6Oam2cC)e7HvEZEWeI8VPt33ESlUICLbayqaAJAL3ShmpK)9))fzPXBWGvgaGbbOn2q6deSeAxEXeHzahtY3ESlo5e1WK(9ZaamiaTrzaJvGDj4XsaZ1B7y1kVzpycrULFOiWWkuCOhJcHJoDdaWGa0gfko0JrTYB2dMNiF)3YpF7XU4QikdaWGa0g1kVzpyEiroD6wZTtuMOatablbF7XU4Ki))F60rbySf4(j2dR8M9Gje5F)No9F)maadcqBugWyfyxcESeWC92owTYB2do6KBtu)Du(9Z3ESlUkIYaamiaTrTYB2dMqgaGbbOnkdyScSlbpwcyUEBhRw5n7bhDY)B5N1C7eLjkWeqWsW3ESloPi0PBn3orzIcmbeSe8Th7IZdj(8))FESMBNOmr9Mrl4Bp2fpedyq)Pt3AUDIYefyciyj4Bp2fN030P)ZAUDIYefyciyj4Bp2fNuel)maadcqBugWyfyxcESeWC92owTYB2dMhYjNoDuagBbUFI9WkVzpycr(30P7Bp2fxfrzaageG2Ow5n7bZd5F))FrgHv3xKyVo(7hzjaCDrvKL46qfyWk19dS11VVcuNoJ46syx2)1zsS3ZtDrvztwDr1vgchX11W19PSyzTxxJRJ3Vm)1bM6maadcqBufzPXBWGvgaGbbOn2q6dVFKfhGrwIjct8yiblBYcWRmeoIjQHjzaageG2OqXHEmkeUIS04nyWkdaWGa0gBi9bSSjlaVYq4iMidXgMe8CFehtkcrnmjd4ffe4a94ycXhlEUpIR8(vcoia1cpeEl)qrGHv40A(iHfKRcHJoD(6jtgxHtR5JewqUkzsuMa93Yp(AaageG2O8(rwCagzjwHWrNUbayqaAJcfh6XOq4(tNokaJTa3pXEyL3ShmH(AwG7NypSYB2dMhYlYiS64)lBB9L)Q64veO6CqDyIhtD0ApUoAThx3MwLbGGRdELHWrCD0ILPoAsDlYuh8kdHJy0CGiQoWwx6mjXEDMyXyVUgUU2X1rdSECDTxKLgVbdwzaageG2ydPpqLflRDIAysPXBRsac4QT545Bl)maadcqBugWyfyxcESeWC92owHWrNUbayqaAJYagRa7sWJLaMR32XQvEZEW8WhYPthfGXwG7NypSYB2dMqK)9)IS04nyWkdaWGa0gBi9rpMCN0BWqudtknEBvcqaxTnhpFB5NbayqaAJYagRa7sWJLaMR32Xkeo60rbySf4(j2dR8M9GjeF((FrgHvh)lX1LduDdWRJwIDPo(JQ1jJSpetuDOiEDjddQlQGG96qWsDTxhmyRJWjR96YbQUEm5o4IS04nyWkdaWGa0gBi9H3pYIdWilXe1WKKr2hIvqcCBANhB9nD6OiWWkuCOhJcHJo9FEYKXvCRaLoyvYKOmbYcogSUG9G7qeIp)Pt)xA82QeGaUABosFBbfbgwHYaaipzGbRq4(xKry1913pXEDOsD0wW8uNdQdbl1r9kmO6atDeO0Uuxp1zvwIRZQSex30MyPoC7iP3GbtuDOiEDwLL462CfgXfzPXBWGvgaGbbOn2q6dCCcbO9kmiIAysOiWWkVFKfhGrwIviCwqrGHvO4qpgfeG2yXaErbboqpoMq2YckcmScJabjtiFrrWXkiaTXceWvBAxuCVimV5yTSekIkQTiJSpeZJT(2c0I0qQnTlkVn2XHNShbkaMWkWRGJ5bZjmwWZ9rCSctR5KGj9OqE0j3IN7J4kVFLGdcqTWdblYsJ3GbRmaadcqBSH0hOYIL1Eppe1WKqrGHvE)iloaJSeRq4OthfbgwHId9yuiCfzPXBWGvgaGbbOn2q6doG3GHOgMekcmScfh6XOq4OthfGXwG7NypSYB2dMqgaGbbOnkuCOhJAL3ShmD6Oam2cC)e7HvEZEWeICcwKLgVbdwzaageG2ydPp20QmaeCaELHWrmrnmjueyyfko0JrHWrNoC)e7HvEZEWeI8ifzewD8)LTT(YFvDFrSySx3lam27PUyGtRUCGQd7iWW1XA7sDECJjQUCGQ7njgvQdvCx26mGx00RBL3SN6wbt8ykYsJ3GbRmaadcqBSH0hgWyfyxcESeWC92oMOgM0piGR2MtTYB2dMhBzXaErbboqpoMqe0YpiGR20UO82yVNh60XCcJf8CFehR84nXXbt68e5VfzK9HyfKa3M25He5FBXaamiaTrHId9yuR8M9G5jY3)PthfGXwG7NypSYB2dMqeKo9FOiWWkuCOhJcHZckcmScfh6XOw5n7bZteY)xKry191NeJk15XYk1HJbimO6qL6EbRuNbmqT3GbxhyQZJL6mGbcP9IS04nyWkdaWGa0gBi9H8YbOjBafmqe1WKqrGHvE)iloaJSeRq4Ot)NbmqiTRGeHlKmM805yeLmjktG(xKry1zB2wL642gSTtCDoOoWeDeSuhnj5atrwA8gmyLbayqaAJnK(ablH2LxIM8vifvaoY8i9Ubib79qmoysgJOgMK8LqAoobsfvaoY8i9Ubib79qmoysgRilnEdgSYaamiaTXgsFGGLq7YlUiRilnEdgScUzmzjTPDHidXgMe8CFehtkcrnmjR52jktuWnJjlPiwwbEfCCIYelqaxTPDrX9IW8MJ1YsisruKhfozXn2LXdVimV5yTSfzPXBWGvWnJjRnK(yt7crnmjR52jktuWnJjljYlYsJ3GbRGBgtwBi9bdzYn0dMR30BWqudtYAUDIYefCZyYsIpfzPXBWGvWnJjRnK(atR5eIAyswZTtuMOGBgtws2QilnEdgScUzmzTH0h44vGiQHjHIadRWiqqYeYxueCSccqBkYsJ3GbRGBgtwBi9XkplGMhtudtclU3Zdwb3mMSHvEwanp2cwyIXBWe8(v4jIIGr5XaPEZOvKryewDPXBWGvWnJjRnK(aMj4yZMWornmjmaHH2dKIdb7imjilcN3GrjtIYei60XaegApqkRaw6ntcyaZQmUsMeLjqe1Jl7IW5H(9vG60fsriQhx2fHZdpmaAYifHOECzxeop0WKWaegApqkRaw6ntcyaZQmErwrwA8gmyfCpnowwsCaalScgGSgHiyWggjAoPifzPXBWGvW904yzTH0h40A(iHfKlrnmjueyyfoTMpsyb5Qw5n7bti(uKLgVbdwb3tJJL1gsFWT9BYc020JjQHj9dArAif32VjlqBtpw5TXoo8K9iqbWewbEfCmp8jk)WCcJf8CFehR42(nzbAB6X2e5VfmNWybp3hXXkUTFtwG2MEmpr(tNoMtySGN7J4yf32VjlqBtpMNF8XMirXtMmUcNOY6aGhRKjrzc0)IS04nyWk4EACSS2q6JT5iYqSHjbp3hXXKIqudtAf4vWXjktSaTinKABoL3g74Wt2Jafatyf4vWX8yn3orzIABUG3g7yl)(HIadR8(rwCagzjwHWrNoF92yVNN)w(HIadRqzaaKNmWGviC0PZxpzY4kugaa5jdmyLmjktG(tNoF9KjJRWjQSoa4XkzsuMa93YpmNWybp3hXXkUTFtwG2MEmPi0PZxpzY4kUTFtwG2MESsMeLjq)T8lnEBvcqaxTnhPVPt3BJ9EESKgVTkbiGR2MJue6057ImcmyFef0MipXEaahGeHladmiy605RNmzCforL1bapwjtIYeO)fzPXBWGvW904yzTH0h40A(iHfKlrnmjueyyfoTMpsyb5Qw5n7btOFgWlkiWb6XX2e5FuI6O8TIpfzPXBWGvW904yzTH0hWYcmnabhqBxi6nJwqgzFiMueImeBysWZ9rCmPifzPXBWGvW904yzTH0hWYcmnabhqBxiYqSHjbp3hXXKIqudtcfbgwHId9yuiCw8KjJRWaewaah8yjadwb7kzsuMarNUbayqaAJYagRa7sWJLaMR32XQvEZEWekIfdWQm54QPFI9aCkfzPXBWGvW904yzTH0hR8SaAEmrnmjS4EppyfCZyYgw5zb08ylyHjgVbtW7xHNikcgLhdK6nJwrwrwA8gmyfGgJMKwfsypxmY(ie1WKqrGHvXsUEaah8yjqRzqkeUIS04nyWkangnjTk2q6dmYa3RqeRhjyGizRO8yGkYsJ3GbRa0y0K0QydPpEbGbUxHiwpsWarYwr5Xarudtcfbgw9caJ9EcWG9vHWzbZjmwWZ9rCSYJ3ehhmPtiYTWxpzY4kgYKBOhmxVP3GrjtIYeilYi7dXekQ)2cFrrGHvgMKRjXEppkeUIS04nyWkangnjTk2q6JyjxpaGdESeO1miIAysYi7dXeIpFBbc4QT5uR8M9G5XwkcA5NbayqaAJY7hzXbyKLy1kVzpyEif1kcsN(ImcmyFeLjDHyjyq2g83ckcmSYWKCnj275rH90yNqrSWxueyyvYjrlWTcu6GfhmBATNhfcNf(IIadRqzaaedb7keol8ffbgwHId9yuiCw(zaageG2OmGXkWUe8yjG56TDSAL3ShmprTIG0PZxdWQm54QPFI9aCk)T8JVgGvzYXvJywadSq0PBaageG2OsOKZBRsatl3x1kVzpyEirq60HaUkHsoVTkbmTCFdq5B(iQvEZEW8q4)xKLgVbdwbOXOjPvXgsF8caJ9EcWG9LOgMKmY(qmH4Z3wGaUABo1kVzpyESLIGw(zaageG2O8(rwCagzjwTYB2dMhs2srq60xKrGb7JOmPlelbdY2G)wqrGHvgMKRjXEppkSNg7ekIf(IIadRsojAbUvGshS4GztR98Oq4SWxueyyfkdaGyiyxHWz5hFrrGHvO4qpgfchD6gGvzYXvJywadSqw8KjJRWP18rclixLmjktGSGIadRqXHEmQvEZEW8e1)T8ZaamiaTrzaJvGDj4XsaZ1B7y1kVzpyEIAfbPtNVgGvzYXvt)e7b4u(B5hFnaRYKJRgXSagyHOt3aamiaTrLqjN3wLaMwUVQvEZEW8qIG0PdbCvcLCEBvcyA5(gGY38ruR8M9G5HW)3cC)e7HvEZEW8q4lYkYsJ3GbRWIJWrIHm5g6bZ1B6nyiQHjzawLjhxnIzbmWczbZjmwWZ9rCSYJ3ehhmPtiBzXaErbboqpoMqe0cF92yVNhl8ffbgwHId9yuiCfzPXBWGvyXr4SH0hCaalScgGSgHiyWggjAoPifzPXBWGvyXr4SH0h40A(iHfKlrnmjpzY4kyztwaELHWrSsMeLjqwmaadcqBuWYMSa8kdHJyfcNf(IIadRWP18rclixfcNfd4ffe4a94yEIybc4QnTlkVn275XYpiGRyitUHEWC9MEdgL3g798qNoF9KjJRyitUHEWC9MEdgLmjktG(xKryewDPXBWGvyXr4SH0hCaalScgGSgHOgMKNmzCfkdaG8KbgSsMeLjqwqrGHvOmaaYtgyWkiaTXYpzK9HyB4JIGrrgzFiwTYJm28ZwFhfueyyLHj5AsS3ZJcH7)Fc9lsecgDY5tuqrGHv9yYDsVbtWEppbaCWJLqubzEyIcH7VL04TvjG6bF7NhzXK(UilnEdgSclocNnK(Gw2oryXq63Viriy0jNprbfbgw1Jj3j9gmb798eaWbpwcrfK5HjkeU)r)NmY(qSYGSRmUn8rrWOiJSpeRw5rgB(zRVJckcmSYWKCnj275rHW9)))pKr2hIvR8idrnmjpzY4kugaa5jdmyLmjktGSGIadRqzaaKNmWGvqaAJL04TvjG6bF7NhzXK(UilnEdgSclocNnK(WKmwinEdMaRXort(kKqzaaKNmWGjQHj5jtgxHYaaipzGbRKjrzcKfueyyfkdaG8KbgSccqBS8ZaErbboqpoMqeKoDmNWybp3hXXkpEtCCWKoPi)lYsJ3GbRWIJWzdPpmjJfsJ3GjWASt0KVcjdaWGa0MIS04nyWkS4iC2q6dtYyH04nycSg7en5RqcUNghllryFBJtkcrnmjd4ffe4a94yE4JLFOiWWkugaa5jdmyfchD681tMmUcLbaqEYadwjtIYeO)fzfzPXBWGvyxsMhtIdayHvWaK1iebd2WirZjfPiJWQJaL2L6grGW1TaKNygX1rWVTnQdaxx746yY84X1LEDzDV90ViV15G6WilxIX1HJxbcxheNuKLgVbdwHDjzESnK(yt7crgInmj45(ioMueIAys)GaUAt7II7fH5nhRLLqrueKo9vGxbhNOm5VfOfPHuBAxuEBSJdpzpcuamHvGxbhZd50P)JtwCJDz8WlcZBowllpqaxTPDrX9IW8MJ1YAbfbgwHId9yuiCwWCcJf8CFehR84nXXbt6eIpwmaRYKJRgXSagyH(tNokcmScfh6XOw5n7btOifzPXBWGvyxsMhBdPpyitUHEWC9MEdgIAysyoHXcEUpIJvE8M44GjDcXhlRaVcoorzIfOfPHumKj3qpyUEtVbJYBJDC4j7rGcGjSc8k4yEiOLFgWlkiWb6XXKSfD6qaxXqMCd9G56n9gmQvEZEWeIG0PZxiGRyitUHEWC9MEdgL3g7988ViJWQ7ZfXtwDuSehxxJRdvCx2684CQd7sY846OIxbQU0RJp155(ioUilnEdgSc7sY8yBi9b6I4jlGzjoMOgMeMtySGN7J4yf6I4jlGzjoMhYlYsJ3GbRWUKmp2gsFWbaSWkyaYAeIGbByKO5KIuKLgVbdwHDjzESnK(ahVcernmjd4ffe4a94yczllyoHXcEUpIJvE8M44GjDcrWISIS04nyWk0KLJriHrg4EfIAysOiWWkXWAoSeWawUkiaTXckcmSsmSMdlbgYKRccqBS8Bf4vWXjktOt)xA82QeKrEBbZtelPXBRsac4kmYa3RqO04TvjiJ82c())IS04nyWk0KLJrSH0hypxmY(ie1WKqrGHvIH1CyjGbSCvR8M9G5jY32ysSh8(vOthfbgwjgwZHLadzYvTYB2dMNiFBJjXEW7xPilnEdgScnz5yeBi9b2ZfUxHOgMekcmSsmSMdlbgYKRAL3ShmpMe7bVFf60rrGHvIH1CyjGbSCvqaAJfmGLBqmSMdl88nD6OiWWkXWAoSeWawUkiaTXcdzYnigwZHLONgVbJI2MESQNamRFIDcfPilnEdgScnz5yeBi9bTn9yIAysOiWWkXWAoSeWawUQvEZEW8ysSh8(vOthfbgwjgwZHLadzYvbbOnwyitUbXWAoSe904nyu020Jv9eGz9tSZZ3Ax7An]] )


end
