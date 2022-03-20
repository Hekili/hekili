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


    spec:RegisterPack( "Feral", 20220227, [[dS0bZbqiKepcHWLqisBse(Kisgfs0PqcRsjIxHQ0SavULsuTlQ8lrIHjI4ykHLjI6zijnnuPCnqP2Msu8nLO04qLQ4CierRdHOMhcP7HG9HQ4GIivTqrspeuctevQKnIkv8reIWjrLk1krOMPsK0nfrQStKu)evQQHIkvPwkOe9uenvujFfvQsgRsKO9sYFPQbdCyHfdPhtQjRuxMyZG8zr1OfLtlz1IiLxdQA2OCBL0Uv53QA4i1XvIewUINd10PCDi2Ui13rfJhusNhuSELi18rvTFPwTqXLIChMOOo5KKCYjj5Kxw3IKtcS5grsfPbdTOiPdn8rUOiVyvuKChzcMIKoGH9XwXLIe)iJwuKzMrJjYPKsEzziOo9VMcUwryHv)PNaYsbxR6uuKOifZ4UpfQIChMOOo5KKCYjj5Kxw3IKtcS5g3JImqSSFuKK1kSqrMv7TCkuf5wWAfj3rMG1aURbP2nXChbDqIbMgK8YcxdsojjNCtCtmSilUCbtKBIxEd2dsTDphghjslEDyew0aDMOHh3a7BWEqQT75W4irAXRdZ1eV8gal(lTmwdsLRgq)pZpc(rgT0a7BaNOSgiWk9iyC9xdOewtMcxt8YBqs)E3G6mzgeARqzsd4ombNPNaYAqb1ayEKgKfPLgCVLvxEdegwAG9ny)UM4L3aUR)skRbzpB3ayXFPF4Lga9tdGLfDdqoMGXnaMhjPySgmsWyW0ayzr7uKScByfxksu2)Bly)HvCPOEHIlfPCbkt2QuvKH2Q)uKtaVOi1tzYuHIKYgqLgyLg(6YBaF(nGYgSWLCdwsdOLbxytoZVIWSIMvY0aEi0G9BUjGxC0RimROzLmnGIgWNFdOSbH2Q0Ih182u55YGBaHgKCds0GrGgbNfOmPbu0akAqIgGIab5qn)eWlU9Z5uKAy0mXBXKlgwr9cLPOozfxks5cuMSvPQidTv)Pizixm(6W01ew9NIupLjtfkYrGgbNfOmPbjAakceKd18R)Fq1iU9Z5uKAy0mXBXKlgwr9cLPOMQkUuKYfOmzRsvrgAR(trAztGZ86WuK6PmzQqroc0i4SaLjnirdqrGGCOM3YMaN52pNRbjAWEqQTZYMaN51H5Ssdp2Nh1jB)F(rGgbN1aEAaLnGBnG3gGPfgZBXKlg2zztGZ86WAWsAa3AafniLgqzdw0aEBWAGnzGXNoyisdOOblVb6)2iL5SaBIh6hpk7)TtUaLjBfPggnt8wm5IHvuVqzkQ5MIlfPCbkt2QuvK6PmzQqrIIab5qnp6GybZJzboZTFoNIm0w9NIeDqSG5XSaNPmf1WwXLIuUaLjBvQks9uMmvOirrGGCOMhZPOf3(5CnirdW0cJ5TyYfd7WCkAXRdRb80GfkYqB1FksmNIw86WuMI6LrXLIuUaLjBvQks9uMmvOirrGGCOMhNnY2TFoNIm0w9NIeNnYwzkQxwfxks5cuMSvPQi1tzYuHIefbcYHAEmNIwC7NZPidTv)PiXCkAXRdtzkQ5EuCPiLlqzYwLQIupLjtfksueiihQ5TSjWzU9Z5uKH2Q)uKw2e4mVomLPmfjuDfotgfxkQxO4srkxGYKTkvfj0p(tGvtr9cfzOT6pfj9)m)i4hz0IYuuNSIlfPCbkt2QuvK6PmzQqrIIab5Wr6ix8ZhJBK1OoCdiAdOQIm0w9NIehPJCXpFmktrnvvCPiLlqzYwLQIupLjtfkskBWEqQTJEQ1G55mHL5Ssdp2Nh1jB)F(rGgbN1aEAavBWsAaLnatlmM3IjxmSJEQ1G55mHL1aEBWIgqrds0amTWyElMCXWo6PwdMNZewwd4PblAafnGp)gGPfgZBXKlg2rp1AW8CMWYAapnGYgq1gWBdw0GL0alyYzoCGkJ9VL5KlqzYUbuOidTv)PiPNAnyEotyzktrn3uCPiLlqzYwLQIm0w9NICkAfPEktMkuKJancolqzsds0G9GuB3u0oR0WJ95rDY2)NFeOrWznGNgKoMkqzIBkAVvA4XnirdOSbu2aueiiNv5YG9qidmoe6gWNFdOsdSsdFD5nGIgKObu2aueiihk7)TfS)Woe6gWNFdOsdSGjN5qz)VTG9h2jxGYKDdOOb853aQ0alyYzoCGkJ9VL5KlqzYUbu0GenGYgGPfgZBXKlg2rp1AW8CMWYAaHgSOb853aQ0alyYzo6PwdMNZewMtUaLj7gqrds0akBqOTkT43V5MIUbeAqsAaF(nWkn81L3Geni0wLw873Ctr3acnyrd4ZVbuPbdYjq)KlU9ei5zM)H8BrO9qVgb7KlqzYUb853aQ0alyYzoCGkJ9VL5KlqzYUbuOi1WOzI3IjxmSI6fktrnSvCPiLlqzYwLQIupLjtfksueiihosh5IF(yCJSg1HBarBaLnq)ROVN(RZWnG3gSObu0GL0GLPblPbjXrvfzOT6pfjosh5IF(yuMI6LrXLIuUaLjBvQkY1aw9YjtomkQxOidTv)PiHK511JG9OLjksnmAM4TyYfdROEHYuuVSkUuKYfOmzRsvrgAR(trcjZRRhb7rltuK6PmzQqrIIab5qX(60oe6gKObwWKZC4hH5FiVLjEOFeS5KlqzYUb853a9)S9Z5C6)s)WlElt8y6Akd7gznQd3aI2Gfnird0FA5IZCxLNzEOquKAy0mXBXKlgwr9cLPmfjAWItlkUuuVqXLIuUaLjBvQks9uMmvOirrGGCIMv0yXJFwmU9Z5AqIgGIab5enROXINHCX42pNRbjAaLnyeOrWzbktAaF(nGYgeARslE5K1sWnGNgSObjAqOTkT43V5WihunsdiAdcTvPfVCYAj4gqrdOqrgAR(trIroOAeLPOozfxks5cuMSvPQi1tzYuHIefbcYjAwrJfp(zX4gznQd3aEAWIK0aEBGoWM3QvPb853aueiiNOzfnw8mKlg3iRrD4gWtdwKKgWBd0b28wTkkYqB1FksSfdgzYfLPOMQkUuKYfOmzRsvrQNYKPcfjkceKt0SIglEgYfJBK1OoCd4Pb6aBERwLgWNFdqrGGCIMv0yXJFwmU9Z5AqIgGFwmErZkAS0aEAqsAaF(nafbcYjAwrJfp(zX42pNRbjAad5IXlAwrJLgS8geAR(ZXzclZvNhIv5zwdiAdwOidTv)PiXwmq1iktrn3uCPiLlqzYwLQIupLjtfksueiiNOzfnw84NfJBK1OoCd4Pb6aBERwLgWNFdqrGGCIMv0yXZqUyC7NZ1GenGHCX4fnROXsdwEdcTv)54mHL5QZdXQ8mRb80GKOidTv)Pi5mHLPmLPiXIHqR4sr9cfxks5cuMSvPQi1tzYuHIu)PLloZDIEE2p7gKObyAHX8wm5IHDw2e4mVoSgq0gWTgKOb6Ff990FDgUbeTbWUbjAavAGvA4RlVbjAavAakceKdf7Rt7qOvKH2Q)uKmKlgFDy6AcR(tzkQtwXLIuUaLjBvQksOF8NaRMI6fkYqB1Fks6)z(rWpYOfLPOMQkUuKYfOmzRsvrQNYKPcfPfm5mhKmbZdnYT0W4KlqzYUbjAG(F2(5CoizcMhAKBPHXHq3GenGknafbcYHJ0rU4NpghcDds0a9VI(E6Vod3aEAWIgKOb73CtaV4SsdFD5nirdOSb73CmKlgFDy6AcR(ZzLg(6YBaF(nGknWcMCMJHCX4Rdtxty1Fo5cuMSBafkYqB1FksCKoYf)8XOmf1CtXLIuUaLjBvQksSOvKu2akBWIfWUblVbjt1gSKgGIab5QthZfw9Nh(6Y9pK3YeFsd5YzIdHUbu0GL3akBGCYKdJtJmJCwd4Tbu1b7gSKgiNm5W4gjxUgWBdOSbCljnyjnafbcYPzsm6aB1L7qOBafnGIgqrdsPbYjtomUrYLtrgAR(trYjktrQNYKPcfPfm5mhk7)TfS)Wo5cuMSBqIgGIab5qz)VTG9h2TFoxds0GqBvAXJAEBQ8CzWnGqdsIYuudBfxks5cuMSvPQi1tzYuHI0cMCMdL9)2c2FyNCbkt2nirdqrGGCOS)3wW(d72pNRbjAaLnq)ROVN(RZWnGOna2nGp)gGPfgZBXKlg2zztGZ86WAaHgSObuOidTv)Pi1bJ5dTv)5zf2uKScB(lwffjk7)TfS)Wktr9YO4srkxGYKTkvfzOT6pfPoymFOT6ppRWMIKvyZFXQOi1)Z2pNtzkQxwfxks5cuMSvPQi1tzYuHIu)ROVN(RZWnGNgq1gKObu2aueiihk7)TfS)Woe6gWNFdOsdSGjN5qz)VTG9h2jxGYKDdOqrITP0MI6fkYqB1FksDWy(qB1FEwHnfjRWM)IvrrcvxHZKrzktrUfOaHzkUuuVqXLIuUaLjBvQks9uMmvOirrGGCR)FWxNh6NvhcDds0aQ0G9GuB3ZHXrI0IxhMIeBtPnf1luKH2Q)uKdY5dTv)5zf2uKScB(lwffjAWItlktrDYkUuKYfOmzRsvrQNYKPcf5EqQT75W4irAXRdtrITP0MI6fkYqB1FksDWy(qB1FEwHnfjRWM)Ivrr(CyCKiTOmf1uvXLIuUaLjBvQkYTG1trB1FksU3ZZH1aozYjPLPb0pgxOmrrgAR(trspphMYuuZnfxks5cuMSvPQi1tzYuHIefbcYPdZd9ZQB)CofzOT6pfPv5YG9qidmktrnSvCPiLlqzYwLQIupLjtfksueiiNomp0pRU9Z5uKH2Q)uK6W8q)SQmf1lJIlfPCbkt2QuvKBbRNI2Q)uKC)tAao7TgGnjywMIm0w9NICqoFOT6ppRWMIeBtPnf1luK6PmzQqrIIab5WzX(5SkSTdHUb853aueiih98CyoeAfjRWM)IvrrInjywMYuuVSkUuKH2Q)uKy4rympAGZuKYfOmzRsvzkQ5EuCPiLlqzYwLQIupLjtfkYqBvAXVFZnfDdi0GKOiX2uAtr9cfzOT6pfPoymFOT6ppRWMIKvyZFXQOiXIHqRmf1ejvCPiLlqzYwLQIm0w9NIuhmMp0w9NNvytrYkS5VyvuK6)z7NZPmf1lsIIlfPCbkt2QuvKH2Q)uKtrRi3cwpfTv)PiPw0ZZ(ztKBaSiWwdOAd(PbCRb6Ff9Ba9xN1GPOXn4VgGRlNjnWIjxSg8igU2sdEOgGkdwg4BWpnyJm1L3auzWYaFdkOgajtWAa0i3sdtdkCdqOBa3hw2GGMMbtdIgaBnDdGLfDd4Kjxd4I70Gc3ae6ge3UbCkgRb4)VgafmwdEiiNIupLjtfks9NwU4m3j65z)SBqIgqzdOsdSGjN5qz)VTG9h2jxGYKDd4ZVbOiqqou2)Bly)HDi0nGIgKObyAHX8wm5IHDw2e4mVoSgqOblAqIgqzd0)k67P)6mCd4Pbj3GenyeOrWzbktAqIgShKA7MI2zLgESppQt2()8JancoRb80G0XubktCtr7TsdpUbjAaLnGknafbcYHI91PDi0nGp)gO)NTFoNdf7Rt7qOBaF(nGYgGIab5qX(60oe6gKOb6)z7NZ5GKjyEOrULgghcDdOObu0a(8BG(xrFp9xNHBaHga7gKObOiqqoRYLb7HqgyCi0nirdqrGGCwLld2dHmW4gznQd3aI2aU1Genypi12nfTZkn8yFEuNS9)5hbAeCwd4PbWUbuOmf1lwO4srkxGYKTkvfPEktMkuK6Ff990FDgUb8qObu2ay3GL3G0XubktCqpYOP9OLjnGcfj2MsBkQxOidTv)PihKZhAR(ZZkSPizf28xSkksO6kCMmktr9IKvCPiLlqzYwLQIupLjtfkY9GuBh9uRbZZzclZzLgESppQt2()8JancoRb8qObjNKgKOb6Ff990FDgUb8qObjRidTv)PiPNAnyEotyzkswDIxVvKWwzkQxqvfxks5cuMSvPQi3cwpfTv)Pit6qywT8C9UbytcMLPidTv)Pi1bJ5dTv)5zf2uKyBkTPOEHIupLjtfksueiihk2xN2HqRizf28xSkksSjbZYuMI6fCtXLIuUaLjBvQkYTG1trB1FksUYKgS(yRbcSslhUslnivUAGggntAaLCLncoRbKzJSBajNIwAG(XwdwSa2nqozYHbUgSgWlnaJmsd4inqhxdwd4LgyzH1G6Aa3Aqo7rdgMcfjw0kskBaLnyXcy3GL3GKPAdwsdqrGGC1PJ5cR(ZdFD5(hYBzIpPHC5mXHq3akAWYBaLnqozYHXPrMroRb82aQ6GDdwsdKtMCyCJKlxd4Tbu2aULKgSKgGIab50mjgDGT6YDi0nGIgqrdOObP0a5Kjhg3i5YPidTv)Pi5eLPi1tzYuHI0cMCMdL9)2c2FyNCbkt2nirdqrGGCOS)3wW(d72pNRbjAqOTkT4rnVnvEUm4gqObjrzkQxaBfxks5cuMSvPQi1tzYuHI0cMCMdL9)2c2FyNCbkt2nirdqrGGCOS)3wW(d72pNtrgAR(troiNp0w9NNvytrYkS5VyvuKOS)3wW(dRmf1lwgfxks5cuMSvPQidTv)PiHK511JG9OLjks9uMmvOirrGGCbTaRE6r2H9d2RNiDD5oeAfPggnt8wm5IHvuVqzkQxSSkUuKYfOmzRsvrc9J)ey1uuVqrgAR(trs)pZpc(rgTOmf1l4EuCPiLlqzYwLQIm0w9NICc4ffPEktMkuKu2GrGgbNfOmPb853aAzWf2KZ8RimROzLmnGNgSFZnb8IJEfHzfnRKPbu0Genypi12nb8IZkn8yFEuNS9)5hbAeCwd4PbyAHX8wm5IHDyofT41H1GL0GKBWYBqYksnmAM4TyYfdROEHYuuVGiPIlfPCbkt2QuvKH2Q)uKmKlgFDy6AcR(trQNYKPcfjLnyeOrWzbktAaF(nGwgCHn5m)kcZkAwjtd4Pb73CmKlgFDy6AcR(ZrVIWSIMvY0akAqIgShKA7yixm(6W01ew9NZkn8yFEuNS9)5hbAeCwd4PbyAHX8wm5IHDyofT41H1GL0GKBWYBqYksnmAM4TyYfdROEHYuuNCsuCPiLlqzYwLQIe6h)jWQPOEHIm0w9NIK(FMFe8JmArzkQtEHIlfPCbkt2QuvKH2Q)uKw2e4mVomfPEktMkuKJancolqzsds0G9GuBNLnboZRdZzLgESppQt2()8JancoRb80akBa3AaVnatlmM3IjxmSZYMaN51H1GL0aU1akAqknGYgSOb82G1aBYaJpDWqKgqrdwEd0)TrkZzb2ep0pEu2)BNCbkt2ny5nq)PLloZDIEE2p7gKObu2aQ0aueiihk2xN2Hq3a(8BaMwymVftUyyNLnboZRdRb80GfnGcfPggnt8wm5IHvuVqzkQtozfxks5cuMSvPQiH(XFcSAkQxOidTv)PiP)N5hb)iJwuMI6KPQIlfPCbkt2QuvK6PmzQqrszdMO2EjTCMl2BSRUgWtdOSblAaVnynGvVolMCb3GL3aDwm5c2dnH2Q)cwdOOblPbJOZIjx8wTknGIgKObu2amTWyElMCXWo0bXcMhZcCwdwsdcTv)5qhelyEmlWzUDSg5sdsPbH2Q)COdIfmpMf4mN(XwdOOb80akBqOT6phoBKTBhRrU0GuAqOT6phoBKTt)yRbuOidTv)PirhelyEmlWzktrDYCtXLIuUaLjBvQks9uMmvOiX0cJ5TyYfd7WCkAXRdRb80GfnG3gGIab5qX(60oe6gSKgKSIm0w9NIeZPOfVomLPOozyR4srkxGYKTkvfPEktMkuKyAHX8wm5IHDw2e4mVoSgWtdOQIm0w9NI0YMaN51HPmf1jVmkUuKYfOmzRsvrQNYKPcfjkceKtZKy0b2Ql3Hq3GenGYgGIab5Wi7TC(yffbN52pNRbjAakceKdNf7NZQW2U9Z5AaF(nafbcYHI91PDi0nGcfzOT6pfjoBKTYuuN8YQ4srkxGYKTkvfzOT6pfPoymFOT6ppRWMIKvyZFXQOiHkgtgLPmfj9i6FfnmfxkQxO4srkxGYKTkvf5tRiXIPidTv)PithtfOmrrMoyiIImjkY0X4VyvuKqpYOP9OLjktrDYkUuKYfOmzRsvr(0ksSykYqB1FkY0XubktuKPdgIOixOi3cwpfTv)PijZgz3acnijW1aQ)B54lOXzV1ayzaV0acnybCnG8cAC2BnawgWlnGqdsgUgSu5UBaHgqv4AajNIwAaHgWnfz6y8xSkksOIXKrzkQPQIlfPCbkt2QuvKpTIelMIm0w9NImDmvGYefz6GHikYLvrMog)fRIICkAVvA4Xktrn3uCPidTv)PiHVU9iBpMUMYWks5cuMSvPQmf1WwXLIm0w9NIe9nJjBpelGr2CQl3BpSwNIuUaLjBvQktr9YO4srkxGYKTkvfPEktMkuK4hHHw32rJGneM4LbH2Q)CYfOmz3a(8Ba(ryO1TDPFwyft84NLwoZjxGYKTIm0w9NIeIj4m9eqMYuuVSkUuKYfOmzRsvrQNYKPcfjkceKB9)d(68q)S62pNtrgAR(trspphMYuuZ9O4srkxGYKTkvfPEktMkuKOiqqU1)p4RZd9ZQB)CofzOT6pfPomp0pRktzksOIXKrXLI6fkUuKYfOmzRsvrgAR(trob8IIupLjtfkY0XubktCqfJjtdi0GfnirdgbAeCwGYKgKOb73CtaV4OxrywrZkzAarj0GfUKBWsAaTm4cBYz(veMv0SsgfPggnt8wm5IHvuVqzkQtwXLIuUaLjBvQks9uMmvOithtfOmXbvmMmnGqdswrgAR(trob8IYuutvfxks5cuMSvPQi1tzYuHImDmvGYehuXyY0acnGQkYqB1FksgYfJVomDnHv)Pmf1CtXLIuUaLjBvQks9uMmvOithtfOmXbvmMmnGqd4MIm0w9NIeZPOfVomLPOg2kUuKYfOmzRsvrQNYKPcfjkceKdJS3Y5JvueCMB)CofzOT6pfjoBKTYuMIeBsWSmfxkQxO4srkxGYKTkvfj0p(tGvtr9cfzOT6pfj9)m)i4hz0IYuuNSIlfPCbkt2QuvKH2Q)uKtaVOi1WOzI3IjxmSI6fks9uMmvOiPSb73CtaV4OxrywrZkzAarBWchSBaF(nyeOrWzbktAafnird2dsTDtaV4Ssdp2Nh1jB)F(rGgbN1aEAqYnGp)gqzdOLbxytoZVIWSIMvY0aEAW(n3eWlo6veMv0SsMgKObOiqqouSVoTdHUbjAaMwymVftUyyNLnboZRdRbeTbuTbjAG(tlxCM7e98SF2nGIgWNFdqrGGCOyFDA3iRrD4gq0gSqrUfSEkAR(trcld4LgCISXnyEK8mgmna2jHiTbpudkd3aMC5wwdcRbrdwRRwrwBG9naJm0bg3aC2iBCd20IYuutvfxks5cuMSvPQi1tzYuHIetlmM3IjxmSZYMaN51H1aI2aQ2GenyeOrWzbktAqIgShKA7yixm(6W01ew9NZkn8yFEuNS9)5hbAeCwd4PbWUbjAaLnq)ROVN(RZWnGqd4wd4ZVb73CmKlgFDy6AcR(ZnYAuhUbeTbWUb853aQ0G9BogYfJVomDnHv)5SsdFD5nGcfzOT6pfjd5IXxhMUMWQ)uMIAUP4srkxGYKTkvfzOT6pfj6GybZJzbotrUfSEkAR(trM6GybRbKSaN1Gc3auXmzAGLfxdWMemlRbKzJSBqynGQnWIjxmSIupLjtfksmTWyElMCXWo0bXcMhZcCwd4PbjRmf1WwXLIuUaLjBvQksOF8NaRMI6fkYqB1Fks6)z(rWpYOfLPOEzuCPiLlqzYwLQIupLjtfks9VI(E6Vod3aI2aU1GenatlmM3IjxmSZYMaN51H1aI2ayRidTv)PiXzJSvMYuK6)z7NZP4sr9cfxks5cuMSvPQidTv)PiJDqBvAXJ5eZQIupLjtfkskBaLnGkny)Ml2bTvPfpMtmR(DSg5IZkn81L3a(8BW(nxSdARslEmNyw97ynYf3iRrD4gq0gKCdOObjAaLny)Ml2bTvPfpMtmR(DSg5IdBHg(gq0gq1gWNFdOsd2V5IDqBvAXJ5eZQptcMdBHg(gWtdw0akAqIgqLgeAR(Zf7G2Q0IhZjMvFMemxDEiwLNznirdOsdcTv)5IDqBvAXJ5eZQFhRrU4QZdXQ8mRbjAavAqOT6pxSdARslEmNywD15HyvEM1akAqIgyXKlMZQvXBVFxsd4PbWUb853GqBvAXlNSwcUb80GKBqIgqLgSFZf7G2Q0IhZjMv)owJCXzLg(6YBqIgiNm5W0aI2aQc7gKObwm5I5SAv8273L0aEAaSvKAy0mXBXKlgwr9cLPOozfxks5cuMSvPQi3cwpfTv)PiHfb2AaxvUmjfUbChKbMgGkq)inGYFAqTUk7kmgmniGmzOOb6aB1L3aUJmbRbCNrULgMguqnivzWYaFdkCdOM7Zvd(Rb6)z7NZ5uKyyoTIesMG5Hg5wAyuK6PmzQqrQ)NTFoNdf7Rt7qOvKH2Q)uKwLld2dHmWOmf1uvXLIuUaLjBvQkYqB1FksizcMhAKBPHrrQNYKPcfP(xrFp9xNHBarBavBqIgyXKlMZQvXBVFxsd4PblBds0akBakceKdhPJCXpFmoe6gWNFdOsdSGjN5Wr6ix8ZhJtUaLj7gqrds0akBavAG(F2(5CoRYLb7HqgyCi0nGp)gO)NTFoNdf7Rt7qOBafnGp)gG(yCds0aOkpZ8JSg1HBarBa3tds0aOkpZ8JSg1HBapnizfPggnt8wm5IHvuVqzkQ5MIlfPCbkt2QuvKH2Q)uKOYGLbEf5wW6POT6pfjxCFUlUprUbulYUb23ammNUbCklRbCklRbtKwUhb3aOrULgMgWjtUgWrAWGCnaAKBPHbnUnCn4NgegtcS1aDMOHVbfudkd3ao)yznOmfPEktMkuK6Ff990FDgUb8qObuvzkQHTIlfPCbkt2QuvK6PmzQqrQ)v03t)1z4gWdHgqvfzOT6pfzD6yUWQ)uMI6LrXLIuUaLjBvQkYqB1FksRYLb7HqgyuKBbRNI2Q)uKCnW0G42n4ERbCcSjnGlUtdKtMCyGRbOiwdcg(BqsdbBnablnOSga9tdwAzGVbXTBqD6yoSIupLjtfks5Kjhg3wGkDznGNgWTK0a(8BakceKdf7Rt7qOBaF(nGYgybtoZrpYoSFCYfOmz3GenaN9JjyZB2UbeTbuTbuOmf1lRIlfPCbkt2QuvKH2Q)uK4Sy)Cwf2wrUfSEkAR(trM0v5zwdqLgWz(lVb23aeS0aYvHTBWFnawgWlnOUgKwgyAqAzGPbxPZKgGldjS6pmCnafXAqAzGPbtmcdgfPEktMkuKOiqqoRYLb7HqgyCi0nirdqrGGCOyFDA3(5Cnird0)k67P)6mCdiAd4wds0aueiihgzVLZhROi4m3(5Cnird2V5MaEXrVIWSIMvY0aI2GfULPbjAGCYKdtd4PbCljnird2dsTDtaV4Ssdp2Nh1jB)F(rGgbN1aEAaMwymVftUyyhMtrlEDynyjni5gS8gKCds0alMCXCwTkE797sAapna2ktrn3JIlfPCbkt2QuvK6PmzQqrIIab5SkxgShczGXHq3a(8BakceKdf7Rt7qOvKH2Q)uKOYGLb(6YvMIAIKkUuKYfOmzRsvrQNYKPcfjkceKdf7Rt7qOBaF(na9X4gKObqvEM5hznQd3aI2a9)S9Z5COyFDA3iRrD4gWNFdqFmUbjAauLNz(rwJ6WnGOnizyRidTv)PiPFR(tzkQxKefxks5cuMSvPQi1tzYuHIefbcYHI91PDi0nGp)gav5zMFK1OoCdiAdsEHIm0w9NICI0Y9iyp0i3sdJYuuVyHIlfPCbkt2QuvKH2Q)uK6)s)WlElt8y6AkdRi3cwpfTv)Pi5I7ZDX9jYnawKjA4BW6)h811GS340G42naBiqqnGvWlnWYkmCniUDdwdyqLgGkMjtd0)kAynyK1OUgmcgMtRi1tzYuHIKYgSFZnfTBK1OoCd4PbCRbjAG(xrFp9xNHBarBaSBqIgqzd2V5MaEXzLg(6YBaF(natlmM3IjxmSZYMaN51H1aEAWIgqrds0a5Kjhg3wGkDznGhcni5K0akAaF(na9X4gKObqvEM5hznQd3aI2ayRmf1lswXLIuUaLjBvQkYqB1FkszL(5iJh9VTICly9u0w9NImPlGbvAGLjJ0aC2JW2navAW6psd0)TlR(d3G)AGLjnq)3gPmfPEktMkuKOiqqoRYLb7HqgyCi0nGp)gqzd0)TrkZTfH2hmMKxXPfNCbkt2nGcLPOEbvvCPiLlqzYwLQICly9u0w9NIKirLwAa9u)ugmnW(g83YrWsd4ib9FkYlwffzs7nKlxQz8BbB1bd2RdgtrQNYKPcfPSuGu00Y2L0Ed5YLAg)wWwDWG96GXuKH2Q)uKjT3qUCPMXVfSvhmyVoymLPOEb3uCPidTv)PirWIVmzfRiLlqzYwLQYuMI85W4irArXLI6fkUuKYfOmzRsvrQNYKPcfjkceKltIX8pK3YepNITDi0kYqB1FksSfdgzYfLPOozfxks5cuMSvPQidTv)PiXihunIIKvN41Bfj3wsUERmf1uvXLIuUaLjBvQkYqB1FkY1)pOAefPEktMkuKOiqqU1)p4RZd9ZQdHUbjAaMwymVftUyyNLnboZRdRbeTbj3GenGknWcMCMJHCX4Rdtxty1Fo5cuMSvKS6eVERi52sY1BLPOMBkUuKYfOmzRsvrQNYKPcfPCYKdtdiAdOAsAqIgSFZnfTBK1OoCd4PbCZb7gKObu2a9)S9Z5CwLld2dHmW4gznQd3aEi0GLXb7gWNFdgKtG(jxC6WeyeVgzQ3jxGYKDdOObjAakceKtZKy0b2Ql3HTqdFdiAdw0GenGknafbcYf0cS6Phzh2pyVEI01L7qOBqIgqLgGIab5qz)VziyZHq3GenGknafbcYHI91PDi0nirdOSb6)z7NZ50)L(Hx8wM4X01ug2nYAuhUb80GLXb7gWNFdOsd0FA5IZCxLNzEOqAafnirdOSbuPb6pTCXzUt0ZZ(z3a(8BG(F2(5CUyh0wLw8yoXS6gznQd3aEi0ay3a(8BW(nxSdARslEmNyw97ynYf3iRrD4gWtdw2gqHIm0w9NImtIX8pK3YepNITvMIAyR4srkxGYKTkvfPEktMkuKYjtomnGOnGQjPbjAW(n3u0UrwJ6WnGNgWnhSBqIgqzd0)Z2pNZzvUmypeYaJBK1OoCd4Hqd4Md2nGp)gmiNa9tU40HjWiEnYuVtUaLj7gqrds0aueiiNMjXOdSvxUdBHg(gq0gSObjAavAakceKlOfy1tpYoSFWE9ePRl3Hq3GenGknafbcYHY(FZqWMdHUbjAaLnGknafbcYHI91PDi0nGp)gO)0YfN5orpp7NDds0alyYzoCKoYf)8X4KlqzYUbjAakceKdf7Rt7gznQd3aEAWY0akAqIgqzd0)Z2pNZP)l9dV4TmXJPRPmSBK1OoCd4PblJd2nGp)gqLgO)0YfN5UkpZ8qH0akAqIgqzdOsd0FA5IZCNONN9ZUb853a9)S9Z5CXoOTkT4XCIz1nYAuhUb8qObWUb853G9BUyh0wLw8yoXS63XAKlUrwJ6WnGNgSSnGIgKObqvEM5hznQd3aEAWYQidTv)Pix))GVop0pRktzktrMwgC9NI6KtsYjNKKtEzuKCI5QlhRi5EL0dlPM7MAIee5g0aUYKguR0)yna6NgKuq1v4mzsQgmYsbsnYUb4FvAqGy)AyYUb6S4YfSRjEPwN0aUrKBaS4V0YyYUbj1GCc0p5IBPmPAG9niPgKtG(jxClLo5cuMStQgq5cyLcxtCtm3RKEyj1C3utKGi3GgWvM0GAL(hRbq)0GKAlqbcZsQgmYsbsnYUb4FvAqGy)AyYUb6S4YfSRjEPwN0GKxqKBaS4V0YyYUbK1kSObyyolG1gqK2a7BWsfjAWUsx46Vg80Ye2pnGYuOObuUawPW1eVuRtAqYuLi3ayXFPLXKDdiRvyrdWWCwaRnGiTb23GLks0GDLUW1Fn4PLjSFAaLPqrdOmzyLcxtCtm3RKEyj1C3utKGi3GgWvM0GAL(hRbq)0GKcL9)2c2F4KQbJSuGuJSBa(xLgei2VgMSBGolUCb7AIxQ1jnGQe5gal(lTmMSBazTclAagMZcyTbePnW(gSurIgSR0fU(RbpTmH9tdOmfkAaLlGvkCnXnXCVs6HLuZDtnrcICdAaxzsdQv6FSga9tdsQNdJJePLKQbJSuGuJSBa(xLgei2VgMSBGolUCb7AIxQ1jnGBe5gal(lTmMSBqsniNa9tU4wktQgyFdsQb5eOFYf3sPtUaLj7KQbuUawPW1eVuRtAaSjYnaw8xAzmz3GKAqob6NCXTuMunW(gKudYjq)KlULsNCbkt2jvdOCbSsHRjUjM7EL(ht2nyrsAqOT6VgWkSHDnXksmTOvuVijuvrsppuXefjrqenG7itWAa31Gu7MyIGiAa3rqhKyGPbjVSW1GKtsYj3e3eteerdGfzXLlyICtmrqeny5nypi129CyCKiT41Hryrd0zIgECdSVb7bP2UNdJJePfVomxtmrqeny5naw8xAzSgKkxnG(FMFe8JmAPb23aorznqGv6rW46VgqjSMmfUMyIGiAWYBqs)E3G6mzgeARqzsd4ombNPNaYAqb1ayEKgKfPLgCVLvxEdegwAG9ny)UMyIGiAWYBa31FjL1GSNTBaS4V0p8sdG(PbWYIUbihtW4gaZJKumwdgjymyAaSSODnXnXH2Q)Wo6r0)kAy8siL0XubktG7IvHa0JmAApAzcCPdgIqijnXerdiZgz3acnijW1aQ)B54lOXzV1ayzaV0acnybCnG8cAC2BnawgWlnGqdsgUgSu5UBaHgqv4AajNIwAaHgWTM4qB1Fyh9i6FfnmEjKs6yQaLjWDXQqaQymzGlDWqeclAIdTv)HD0JO)v0W4LqkPJPcuMa3fRcHPO9wPHhdx6GHiew2M4qB1Fyh9i6FfnmEjKc81Thz7X01ugUjo0w9h2rpI(xrdJxcPG(MXKThIfWiBo1L7ThwRRjo0w9h2rpI(xrdJxcPaXeCMEcidUcIa(ryO1TD0iydHjEzqOT6pNCbkt285JFegADBx6NfwXep(zPLZCYfOmz3ehAR(d7Ohr)ROHXlHuONNddUcIakceKB9)d(68q)S62pNRjo0w9h2rpI(xrdJxcPOdZd9ZkCfebueii36)h815H(z1TFoxtCtCOT6pmHb58H2Q)8ScBWDXQqanyXPf4W2uAJWc4kicOiqqU1)p4RZd9ZQdHobv2dsTDphghjslEDynXH2Q)W8sifDWy(qB1FEwHn4Uyvi8CyCKiTah2MsBewaxbrypi129CyCKiT41H1etenG798CynGtMCsAzAa9JXfktAIdTv)H5Lqk0ZZH1ehAR(dZlHuSkxgShczGbUcIakceKthMh6Nv3(5CnXH2Q)W8sifDyEOFwHRGiGIab50H5H(z1TFoxtmrqeni0w9hMxcPKoMkqzcCxSkeWz)yc28MTHlDWqecwm5I5SAv8273L0eteerdcTv)H5LqkAy0S6Y9PJPcuMa3fRcbC2pMGnVzB4EAcR1bx6GHieSyYfZz1Q4T3VlPjMiAa3)KgGZERbytcML1ehAR(dZlHugKZhAR(ZZkSb3fRcbSjbZYGdBtPnclGRGiGIab5WzX(5SkSTdHMpFueiih98Cyoe6M4qB1FyEjKcgEegZJg4SM4qB1FyEjKIoymFOT6ppRWgCxSkeWIHqdh2MsBewaxbri0wLw873CtrtijnXH2Q)W8sifDWy(qB1FEwHn4UyviO)NTFoxtmr0aQf98SF2e5galcS1aQ2GFAa3AG(xr)gq)1znykACd(Rb46YzsdSyYfRbpIHRT0GhQbOYGLb(g8td2itD5navgSmW3GcQbqYeSganYT0W0Gc3ae6gW9HLniOPzW0GObWwt3ayzr3aozY1aU4onOWnaHUbXTBaNIXAa()RbqbJ1GhcY1ehAR(dZlHuMIgUcIG(tlxCM7e98SF2jOKkwWKZCOS)3wW(d7KlqzYMpFueiihk7)TfS)WoeAksGPfgZBXKlg2zztGZ86WiSibL6Ff990FDgMNKtmc0i4SaLjj2dsTDtr7Ssdp2Nh1jB)F(rGgbNXt6yQaLjUPO9wPHhNGsQGIab5qX(60oeA(81)Z2pNZHI91PDi085tjkceKdf7Rt7qOtO)NTFoNdsMG5Hg5wAyCi0uqbF(6Ff990FDgMaStGIab5SkxgShczGXHqNafbcYzvUmypeYaJBK1Oomr5wI9GuB3u0oR0WJ95rDY2)NFeOrWz8aBkAIdTv)H5LqkdY5dTv)5zf2G7IvHauDfotg4W2uAJWc4kic6Ff990FDgMhcuc7LNoMkqzId6rgnThTmHIM4qB1FyEjKc9uRbZZzcldUcIWEqQTJEQ1G55mHL5Ssdp2Nh1jB)F(rGgbNXdHKtsc9VI(E6VodZdHKHJvN41BcWUjMiAqshcZQLNR3naBsWSSM4qB1FyEjKIoymFOT6ppRWgCxSkeWMemldoSnL2iSaUcIakceKdf7Rt7qOBIjIgWvM0G1hBnqGvA5WvAPbPYvd0WOzsdOKRSrWznGmBKDdi5u0sd0p2AWIfWUbYjtomW1G1aEPbyKrAahPb64AWAaV0allSguxd4wdYzpAWWu0ehAR(dZlHu4eLbhw0eOKYflG9YtMQlbfbcYvNoMlS6pp81L7FiVLj(KgYLZehcnflNs5KjhgNgzg5mEPQd2lrozYHXnsUC8sj3sYsqrGGCAMeJoWwD5oeAkOGIuKtMCyCJKlhCfeblyYzou2)Bly)HDYfOmzNafbcYHY(FBb7pSB)CUeH2Q0Ih182u55YGjKKMyIGiAqOT6pmVesH(FMFe8JmAbUcIGfm5mhk7)TfS)Wo5cuMStGIab5qz)VTG9h2TFoxckLtMCy4LQoyVe5Kjhg3i5YXlLCljlbfbcYPzsm6aB1L7qOPGcIs5IfWE5jt1LGIab5QthZfw9Nh(6Y9pK3YeFsd5YzIdHMIeH2Q0Ih182u55YGjKKM4qB1FyEjKYGC(qB1FEwHn4UyviGY(FBb7pmCfeblyYzou2)Bly)HDYfOmzNafbcYHY(FBb7pSB)CUM4qB1FyEjKcKmVUEeShTmbonmAM4TyYfdtybCfebueiixqlWQNEKDy)G96jsxxUdHUjo0w9hMxcPq)pZpc(rgTah0p(tGvJWIM4qB1FyEjKYeWlWPHrZeVftUyyclGRGiq5iqJGZcuMWNpTm4cBYz(veMv0SsgE2V5MaEXrVIWSIMvYqrI9GuB3eWloR0WJ95rDY2)NFeOrWz8GPfgZBXKlg2H5u0Ixh2ssE5j3ehAR(dZlHuyixm(6W01ew9hCAy0mXBXKlgMWc4kicuoc0i4SaLj85tldUWMCMFfHzfnRKHN9BogYfJVomDnHv)5OxrywrZkzOiXEqQTJHCX4Rdtxty1FoR0WJ95rDY2)NFeOrWz8GPfgZBXKlg2H5u0Ixh2ssE5j3ehAR(dZlHuO)N5hb)iJwGd6h)jWQryrtCOT6pmVesXYMaN51HbNggnt8wm5IHjSaUcIWiqJGZcuMKypi12zztGZ86WCwPHh7ZJ6KT)p)iqJGZ4HsUXlMwymVftUyyNLnboZRdBjCJcIukxW7AGnzGXNoyicflx)3gPmNfyt8q)4rz)VDYfOmzVC9NwU4m3j65z)StqjvqrGGCOyFDAhcnF(yAHX8wm5IHDw2e4mVomEwqrtCOT6pmVesH(FMFe8JmAboOF8NaRgHfnXH2Q)W8sif0bXcMhZcCgCfebkNO2EjTCMl2BSRoEOCbVRbS61zXKl4LRZIjxWEOj0w9xWOyjJOZIjx8wTkuKGsmTWyElMCXWo0bXcMhZcC2scTv)5qhelyEmlWzUDSg5crAOT6ph6GybZJzboZPFSrbpugAR(ZHZgz72XAKlePH2Q)C4Sr2o9JnkAIdTv)H5LqkyofT41HbxbratlmM3IjxmSdZPOfVomEwWlkceKdf7Rt7qOxsYnXH2Q)W8siflBcCMxhgCfebmTWyElMCXWolBcCMxhgpuTjo0w9hMxcPGZgzdxbrafbcYPzsm6aB1L7qOtqjkceKdJS3Y5JvueCMB)CUeOiqqoCwSFoRcB72pNJpFueiihk2xN2HqtrtCOT6pmVesrhmMp0w9NNvydUlwfcqfJjttCtCOT6pSdL9)2c2FyctaVaNggnt8wm5IHjSaUcIaLuXkn81LZNpLlCjVeAzWf2KZ8RimROzLm8qy)MBc4fh9kcZkAwjdf85tzOTkT4rnVnvEUmycjNyeOrWzbktOGIeOiqqouZpb8IB)CUM4qB1Fyhk7)TfS)W8sifgYfJVomDnHv)bNggnt8wm5IHjSaUcIWiqJGZcuMKafbcYHA(1)pOAe3(5CnXH2Q)Wou2)Bly)H5Lqkw2e4mVom40WOzI3IjxmmHfWvqegbAeCwGYKeOiqqouZBztGZC7NZLypi12zztGZ86WCwPHh7ZJ6KT)p)iqJGZ4HsUXlMwymVftUyyNLnboZRdBjCJcIukxW7AGnzGXNoyicflx)3gPmNfyt8q)4rz)VDYfOmz3ehAR(d7qz)VTG9hMxcPGoiwW8ywGZGRGiGIab5qnp6GybZJzboZTFoxtCOT6pSdL9)2c2FyEjKcMtrlEDyWvqeqrGGCOMhZPOf3(5CjW0cJ5TyYfd7WCkAXRdJNfnXH2Q)Wou2)Bly)H5Lqk4Sr2WvqeqrGGCOMhNnY2TFoxtCOT6pSdL9)2c2FyEjKcMtrlEDyWvqeqrGGCOMhZPOf3(5CnXH2Q)Wou2)Bly)H5Lqkw2e4mVom4kicOiqqouZBztGZC7NZ1e3ehAR(d70)Z2pNJqSdARslEmNywHtdJMjElMCXWewaxbrGskPY(nxSdARslEmNyw97ynYfNvA4RlNp)9BUyh0wLw8yoXS63XAKlUrwJ6Wenzksq5(nxSdARslEmNyw97ynYfh2cn8eLQ85tL9BUyh0wLw8yoXS6ZKG5WwOHNNfuKGkH2Q)CXoOTkT4XCIz1NjbZvNhIv5zwcQeAR(Zf7G2Q0IhZjMv)owJCXvNhIv5zwcQeAR(Zf7G2Q0IhZjMvxDEiwLNzuKWIjxmNvRI3E)UeEGnF(H2Q0IxozTempjNGk73CXoOTkT4XCIz1VJ1ixCwPHVU8eYjtomeLQWoHftUyoRwfV9(Dj8a7MyIGiAqOT6pSt)pB)CoEjKcetWz6jGm4kicuIFegADBhnc2qyIxgeAR(JpF8JWqRB7s)SWkM4XplTCgfWvNjZGqB(ADv2vycHfWvNjZGqB(C2JgmclGRotMbH28feb8JWqRB7s)SWkM4XplTCwtmr0ayrGTgWvLltsHBa3bzGPbOc0psdO8NguRRYUcJbtdcitgkAGoWwD5nG7itWAa3zKBPHPbfudsvgSmW3Gc3aQ5(C1G)AG(F2(5CUM4qB1FyN(F2(5C8sifRYLb7HqgyGddZPjajtW8qJClnmWvqe0)Z2pNZHI91PDi0nXH2Q)Wo9)S9Z54LqkqYemp0i3sddCAy0mXBXKlgMWc4kic6Ff990FDgMOunHftUyoRwfV9(Dj8SSjOefbcYHJ0rU4NpghcnF(uXcMCMdhPJCXpFmo5cuMSPibLur)pB)CoNv5YG9qidmoeA(81)Z2pNZHI91PDi0uWNp6JXjGQ8mZpYAuhMOCpjGQ8mZpYAuhMNKBIjIgWf3N7I7tKBa1ISBG9nadZPBaNYYAaNYYAWePL7rWnaAKBPHPbCYKRbCKgmixdGg5wAyqJBdxd(PbHXKaBnqNjA4Bqb1GYWnGZpwwdkRjo0w9h2P)NTFohVesbvgSmWdxbrq)ROVN(RZW8qGQnXH2Q)Wo9)S9Z54Lqk1PJ5cR(dUcIG(xrFp9xNH5HavBIjIgW1atdIB3G7TgWjWM0aU4onqozYHbUgGIyniy4VbjneS1aeS0GYAa0pnyPLb(ge3Ub1PJ5WnXH2Q)Wo9)S9Z54LqkwLld2dHmWaxbrqozYHXTfOsxgpClj85JIab5qX(60oeA(8P0cMCMJEKDy)4KlqzYobo7htWM3SnrPkfnXerds6Q8mRbOsd4m)L3a7BacwAa5QW2n4Vgald4LguxdsldmniTmW0GR0zsdWLHew9hgUgGIyniTmW0GjgHbttCOT6pSt)pB)CoEjKcol2pNvHTHRGiGIab5SkxgShczGXHqNafbcYHI91PD7NZLq)ROVN(RZWeLBjqrGGCyK9woFSIIGZC7NZLy)MBc4fh9kcZkAwjdrx4wMeYjtom8WTKKypi12nb8IZkn8yFEuNS9)5hbAeCgpyAHX8wm5IHDyofT41HTKKxEYjSyYfZz1Q4T3VlHhy3ehAR(d70)Z2pNJxcPGkdwg4RlhUcIakceKZQCzWEiKbghcnF(OiqqouSVoTdHUjo0w9h2P)NTFohVesH(T6p4kicOiqqouSVoTdHMpF0hJtav5zMFK1Oomr1)Z2pNZHI91PDJSg1H5Zh9X4eqvEM5hznQdt0KHDtCOT6pSt)pB)CoEjKYePL7rWEOrULgg4kicOiqqouSVoTdHMpFOkpZ8JSg1HjAYlAIjIgWf3N7I7tKBaSit0W3G1)p4RRbzVXPbXTBa2qGGAaRGxAGLvy4AqC7gSgWGknavmtMgO)v0WAWiRrDnyemmNUjo0w9h2P)NTFohVesr)x6hEXBzIhtxtzy4kicuUFZnfTBK1OompClH(xrFp9xNHjkStq5(n3eWloR0WxxoF(yAHX8wm5IHDw2e4mVomEwqrc5Kjhg3wGkDz8qi5KqbF(OpgNaQYZm)iRrDyIc7MyIObjDbmOsdSmzKgGZEe2UbOsdw)rAG(VDz1F4g8xdSmPb6)2iL1ehAR(d70)Z2pNJxcPiR0phz8O)THRGiGIab5SkxgShczGXHqZNpL6)2iL52Iq7dgtYR40ItUaLjBkAIjIgqKOslnGEQFkdMgyFd(B5iyPbCKG(VM4qB1FyN(F2(5C8sifeS4ltwH7IvHqs7nKlxQz8BbB1bd2RdgdUcIGSuGu00Y2L0Ed5YLAg)wWwDWG96GXAIdTv)HD6)z7NZXlHuqWIVmzf3e3ehAR(d7GkgtgctaVaNggnt8wm5IHjSaUcIq6yQaLjoOIXKHWIeJancolqzsI9BUjGxC0RimROzLmeLWcxYlHwgCHn5m)kcZkAwjttCOT6pSdQymz4LqktaVaxbriDmvGYehuXyYqi5M4qB1FyhuXyYWlHuyixm(6W01ew9hCfeH0XubktCqfJjdbQ2ehAR(d7GkgtgEjKcMtrlWvqeshtfOmXbvmMme4wtCOT6pSdQymz4Lqk4Sr2WvqeqrGGCyK9woFSIIGZC7NZ1eteerdcTv)HDqfJjdVesbIj4m9eqgCfeb8JWqRB7OrWgct8YGqB1Fo5cuMS5Zh)im062U0plSIjE8ZslN5KlqzYgU6mzgeAZxRRYUctiSaU6mzgeAZNZE0GrybC1zYmi0MVGiGFegADBx6NfwXep(zPLZAIBIdTv)HDq1v4mziq)pZpc(rgTah0p(tGvJWIM4qB1FyhuDfotgEjKcosh5IF(yGRGiGIab5Wr6ix8ZhJBK1OomrPAtCOT6pSdQUcNjdVesHEQ1G55mHLbxbrGY9GuBh9uRbZZzclZzLgESppQt2()8JancoJhQUekX0cJ5TyYfd7ONAnyEotyz8UGIeyAHX8wm5IHD0tTgmpNjSmEwqbF(yAHX8wm5IHD0tTgmpNjSmEOKQ8UyjwWKZC4avg7FlZjxGYKnfnXH2Q)WoO6kCMm8siLPOHtdJMjElMCXWewaxbryeOrWzbktsShKA7MI2zLgESppQt2()8JancoJN0XubktCtr7TsdpobLuIIab5SkxgShczGXHqZNpvSsdFD5uKGsueiihk7)TfS)WoeA(8PIfm5mhk7)TfS)Wo5cuMSPGpFQybtoZHduzS)TmNCbkt2uKGsmTWyElMCXWo6PwdMNZewgHf85tflyYzo6PwdMNZewMtUaLjBksqzOTkT43V5MIMqs4Z3kn81LNi0wLw873CtrtybF(uzqob6NCXTNajpZ8pKFlcTh61iy(8PIfm5mhoqLX(3YCYfOmztrtCOT6pSdQUcNjdVesbhPJCXpFmWvqeqrGGC4iDKl(5JXnYAuhMOuQ)v03t)1zyExqXswMLKehvBIdTv)HDq1v4mz4LqkqY866rWE0Ye4wdy1lNm5WqybCAy0mXBXKlgMWIM4qB1FyhuDfotgEjKcKmVUEeShTmbonmAM4TyYfdtybCfebueiihk2xN2HqNWcMCMd)im)d5TmXd9JGnNCbkt285R)NTFoNt)x6hEXBzIhtxtzy3iRrDyIUiH(tlxCM7Q8mZdfstCtCOT6pS75W4irAHa2IbJm5cCfebueiixMeJ5FiVLjEofB7qOBIdTv)HDphghjsl8sifmYbvJahRoXR3e42sY17M4qB1Fy3ZHXrI0cVesz9)dQgbowDIxVjWTLKR3WvqeqrGGCR)FWxNh6NvhcDcmTWyElMCXWolBcCMxhgrtobvSGjN5yixm(6W01ew9NtUaLj7M4qB1Fy3ZHXrI0cVesjtIX8pK3YepNITHRGiiNm5WquQMKe73Ctr7gznQdZd3CWobL6)z7NZ5SkxgShczGXnYAuhMhclJd285piNa9tU40HjWiEnYupfjqrGGCAMeJoWwD5oSfA4j6IeubfbcYf0cS6Phzh2pyVEI01L7qOtqfueiihk7)ndbBoe6eubfbcYHI91PDi0jOu)pB)CoN(V0p8I3YepMUMYWUrwJ6W8SmoyZNpv0FA5IZCxLNzEOqOibLur)PLloZDIEE2pB(81)Z2pNZf7G2Q0IhZjMv3iRrDyEiaB(83V5IDqBvAXJ5eZQFhRrU4gznQdZZYsrtCOT6pS75W4irAHxcPS()bFDEOFwHRGiiNm5WquQMKe73Ctr7gznQdZd3CWobL6)z7NZ5SkxgShczGXnYAuhMhcCZbB(8hKtG(jxC6WeyeVgzQNIeOiqqontIrhyRUCh2cn8eDrcQGIab5cAbw90JSd7hSxpr66YDi0jOckceKdL9)MHGnhcDckPckceKdf7Rt7qO5Zx)PLloZDIEE2p7ewWKZC4iDKl(5JXjxGYKDcueiihk2xN2nYAuhMNLHIeuQ)NTFoNt)x6hEXBzIhtxtzy3iRrDyEwghS5ZNk6pTCXzURYZmpuiuKGsQO)0YfN5orpp7NnF(6)z7NZ5IDqBvAXJ5eZQBK1OompeGnF(73CXoOTkT4XCIz1VJ1ixCJSg1H5zzPibuLNz(rwJ6W8SSnXnXH2Q)WoSyi0eyixm(6W01ew9hCfeb9NwU4m3j65z)StGPfgZBXKlg2zztGZ86Wik3sO)v03t)1zyIc7euXkn81LNGkOiqqouSVoTdHUjo0w9h2HfdHMxcPq)pZpc(rgTah0p(tGvJWIM4qB1FyhwmeAEjKcosh5IF(yGRGiybtoZbjtW8qJClnmo5cuMStO)NTFoNdsMG5Hg5wAyCi0jOckceKdhPJCXpFmoe6e6Ff990FDgMNfj2V5MaEXzLg(6Ytq5(nhd5IXxhMUMWQ)CwPHVUC(8PIfm5mhd5IXxhMUMWQ)CYfOmztrtmrqeni0w9h2HfdHMxcPq)pZpc(rgTaxbrWcMCMdL9)2c2FyNCbkt2jqrGGCOS)3wW(d72pNlbLYjtom8svhSxICYKdJBKC54LsULKLGIab50mjgDGT6YDi0uqbrPCXcyV8KP6sqrGGC1PJ5cR(ZdFD5(hYBzIpPHC5mXHqtrIqBvAXJAEBQ8CzWesstCOT6pSdlgcnVesHtugCyrtGskxSa2lpzQUeueiixD6yUWQ)8WxxU)H8wM4tAixotCi0uSCkLtMCyCAKzKZ4LQoyVe5Kjhg3i5YXlLCljlbfbcYPzsm6aB1L7qOPGcksrozYHXnsUCWvqeSGjN5qz)VTG9h2jxGYKDcueiihk7)TfS)WU9Z5seARslEuZBtLNldMqsAIdTv)HDyXqO5Lqk6GX8H2Q)8ScBWDXQqaL9)2c2Fy4kicwWKZCOS)3wW(d7KlqzYobkceKdL9)2c2Fy3(5CjOu)ROVN(RZWef285JPfgZBXKlg2zztGZ86WiSGIM4qB1FyhwmeAEjKIoymFOT6ppRWgCxSke0)Z2pNRjo0w9h2HfdHMxcPOdgZhAR(ZZkSb3fRcbO6kCMmWHTP0gHfWvqe0)k67P)6mmpunbLOiqqou2)Bly)HDi085tflyYzou2)Bly)HDYfOmztrtCtCOT6pSdBsWSmc0)Z8JGFKrlWb9J)ey1iSOjMiAaSmGxAWjYg3G5rYZyW0ayNeI0g8qnOmCdyYLBzniSgenyTUAfzTb23amYqhyCdWzJSXnytlnXH2Q)WoSjbZY4LqktaVaNggnt8wm5IHjSaUcIaL73CtaV4OxrywrZkzi6chS5ZFeOrWzbktOiXEqQTBc4fNvA4X(8Ooz7)Zpc0i4mEsMpFkPLbxytoZVIWSIMvYWZ(n3eWlo6veMv0SsMeOiqqouSVoTdHobMwymVftUyyNLnboZRdJOunH(tlxCM7e98SF2uWNpkceKdf7Rt7gznQdt0fnXH2Q)WoSjbZY4LqkmKlgFDy6AcR(dUcIaMwymVftUyyNLnboZRdJOunXiqJGZcuMKypi12XqUy81HPRjS6pNvA4X(8Ooz7)Zpc0i4mEGDck1)k67P)6mmbUXN)(nhd5IXxhMUMWQ)CJSg1HjkS5ZNk73CmKlgFDy6AcR(ZzLg(6YPOjMiAqQdIfSgqYcCwdkCdqfZKPbwwCnaBsWSSgqMnYUbH1aQ2alMCXWnXH2Q)WoSjbZY4LqkOdIfmpMf4m4kicyAHX8wm5IHDOdIfmpMf4mEsUjo0w9h2HnjywgVesH(FMFe8JmAboOF8NaRgHfnXH2Q)WoSjbZY4Lqk4Sr2Wvqe0)k67P)6mmr5wcmTWyElMCXWolBcCMxhgrHDtCtCOT6pSdnyXPfcyKdQgbUcIakceKt0SIglE8ZIXTFoxcueiiNOzfnw8mKlg3(5CjOCeOrWzbkt4ZNYqBvAXlNSwcMNfjcTvPf)(nhg5GQriAOTkT4LtwlbtbfnXH2Q)Wo0GfNw4LqkylgmYKlWvqeqrGGCIMv0yXJFwmUrwJ6W8Sij8QdS5TAv4ZhfbcYjAwrJfpd5IXnYAuhMNfjHxDGnVvRstCOT6pSdnyXPfEjKc2IbQgbUcIakceKt0SIglEgYfJBK1Oomp6aBERwf(8rrGGCIMv0yXJFwmU9Z5sGFwmErZkASWts4ZhfbcYjAwrJfp(zX42pNlbd5IXlAwrJLLhAR(ZXzclZvNhIv5zgrx0ehAR(d7qdwCAHxcPWzcldUcIakceKt0SIglE8ZIXnYAuhMhDGnVvRcF(OiqqorZkAS4zixmU9Z5sWqUy8IMv0yz5H2Q)CCMWYC15HyvEMXtsuMYuk]] )


end
