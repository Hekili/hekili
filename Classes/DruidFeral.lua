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
            duration = function () return mod_circle_dot( 4 + ( combo_points.current * 4 ) ) end,
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

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

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
            elseif k == "delay_berserking" then return settings.delay_berserking
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

    spec:RegisterSetting( "delay_berserking", false, {
        name = "Delay |T135727:0|t Berserking",
        desc = "If checked, the default priority will attempt to adjust the timing of |T135727:0|t Berserking to be consistent with simmed Power Infusion usage.",
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


    spec:RegisterPack( "Feral", 20220514, [[dW05mcqiuv6riO6susqBIs8jvf1Ouv1PuvzvIs8kkPMfc1TuvKDrYVuvyyiGJrPAziQEgQkMgLKUgc02eLsFdbfJdbL6CIsISovLI5HGCpezFOkoickzHQk5HIsXePKaxuusuTrvLs(iLeQtQQuQvIOmtkjYnfLe2jQs)uuszOIsIYsvvQ8uKmvuv9vkjKXsjrTxs9xrgSIdlSyi9ykMmixMyZG6ZQIrlQoTuRwus61IIzJYTvL2Tk)gy4OYXfLuTCLEoutNQRdX2Pu(osz8Is15riRxvPQ5JuTFjRTR5xtbfUO5LCcqo5eGG2TQYoHXobiiHTMYjIt0uCHjt8iAQlEfn13s2GPP4cIyGasZVMcdqwJOPYDNd)nF8Xt75iOkd49dC)IWcVbNzdy)dC)A(qtHI0m)BFAunfu4IMxYja5KtacA3Qk7eg7eGG21ubINdwnfv)MnAQ8gcsonQMcsWgn13s2GvJvWI0qfzzfbr1yNpexd5eGCYlYkYYM84Ee83uK9PAGwKgsbOXOjHnjzcNK9Am5IjdUghud0I0qkangnjSjjt4QISpvt2aoBY618f)1WbaS0kyaYAKACqn0I2RrYo3kyCdUA(NDY)PkY(unewqq10Nl7IW5nktQ5BXeCUzdyVMgUgIai1Kh2KAoGN33tncdl14GAGaQISpvJva4(SxtoGbvt2aoBGmsnWGTMVR5Qb5ycgxdraKpZy1SsWyevZ31CQISpvdfchhy9AGBgt2A(o5zb088AOL3mPgoaG13tnWGTMVyaaKhmWHvfzFQgRiWMPgWvdHfuW5TnPgkAX(wdgHJdSUstXASJ18RPqzaaKhmWH18R51UMFnLCbktG0FPPcJ3GttTrgrtz22LTdn1)A4BnEBY03tn0PxZ)ASRiVMSudNS4g7Y5PxeM3CSw2A4HunqaxTrgrX9IW8MJ1YwZVAOtVM)1egVTjjup5B)8ilUgs1qEnwQzf4vW5bktQ5xn)QXsnOiWWkupTrgrbbODAkdrgMK8yFehR51U218sUMFnLCbktG0FPPcJ3GttXqUyt9H56n8gCAkZ2USDOPwbEfCEGYKASudkcmSc1tVaWb3ROGa0onLHidtsESpIJ18Ax7AE5JMFnLCbktG0FPPcJ3Gtt55BGZtMW1uMTDz7qtTc8k48aLj1yPgueyyfQN88nW5kiaTRgl1aTinKYZ3aNNmHR82KbNEI(eOe4sRaVcoVgEQ5FnwTgRRbZjmwYJ9rCSYZ3aNNmHxtwQXQ18RMpQ5Fn2RX6AEdSllrjBbdrQ5xnFQgd4GqAx5b2LemytOmaasjxGYeinLHidtsESpIJ18Ax7AETQMFnLCbktG0FPPmB7Y2HMcfbgwH6j0fXdwcZcCUccq70uHXBWPPqxepyjmlW5AxZlb18RPKlqzcK(lnLzBx2o0uOiWWkupHP1CIccq7QXsnyoHXsESpIJvyAnNKmHxdp1yxtfgVbNMctR5KKjCTR5nB18RPKlqzcK(lnLzBx2o0uOiWWkupHZxbsbbODAQW4n40u48vG0UMxcJMFnLCbktG0FPPmB7Y2HMcfbgwH6jmTMtuqaANMkmEdonfMwZjjt4AxZlHTMFnLCbktG0FPPmB7Y2HMcfbgwH6jpFdCUccq70uHXBWPP88nW5jt4Ax7Ak4(ACUSA(18AxZVMsUaLjq6V0uWGnDs2DnV21uHXBWPP4aawAfmaznI218sUMFnLCbktG0FPPmB7Y2HMcfbgwHdBXJKwqSQvEJ(W1qOA4JMkmEdonfoSfpsAbXQDnV8rZVMsUaLjq6V0uMTDz7qt9VgOfPHuCB)gSeTn8CL3Mm40t0NaLaxAf4vW51Wtn8PMSuZ)AWCcJL8yFehR42(nyjAB451yDn2R5xnwQbZjmwYJ9rCSIB73GLOTHNxdp1yVMF1qNEnyoHXsESpIJvCB)gSeTn88A4PM)1WNASUg71KLA8GjNRWbQSoa45k5cuMavZpnvy8gCAkUTFdwI2gEU218Avn)Ak5cuMaP)stfgVbNMABonLzBx2o0uRaVcopqzsnwQbArAi12CkVnzWPNOpbkbU0kWRGZRHNASfBhOmrTnxYBtgCnwQ5Fn)Rbfbgw59JS4emYsKcHRg60RHV14TjtFp18Rgl18VgueyyfkdaG8GboScHRg60RHV14btoxHYaaipyGdRKlqzcun)QHo9A4BnEWKZv4avwha8CLCbktGQ5xnwQ5FnyoHXsESpIJvCB)gSeTn88AivJ9AOtVg(wJhm5Cf32VblrBdpxjxGYeOA(vJLA(xty82MKGaUABUAivdbQHo9A82KPVNASuty82MKGaUABUAivJ9AOtVg(wZICcmyFef0gip5EcaNGeHlbdmiyLCbktGQHo9A4BnEWKZv4avwha8CLCbktGQ5NMYqKHjjp2hXXAETRDnVeuZVMsUaLjq6V0uMTDz7qtHIadRWHT4rsliw1kVrF4Aiun)RXaErbjoqFoUgRRXEn)Qjl1KT1KLAiGIpAQW4n40u4Ww8iPfeR218MTA(1uYfOmbs)LM6nYEsozFisZRDnvy8gCAkyzbMgGGtOTlAkdrgMK8yFehR51U218sy08RPKlqzcK(lnvy8gCAkyzbMgGGtOTlAkZ2USDOPqrGHvO4uFgfcxnwQXdMCUcdqyjaCYZLemyfSRKlqzcun0PxJbayqaANYaoBGmsYZLeMR32XQvEJ(W1qOASxJLAmaBYfNRU(j3tWHOPmezysYJ9rCSMx7AxZlHTMFnLCbktG0FPPmB7Y2HMclU33dwb3mMSPvEwanpVgl1GfMy8gCjVFLA4Pg7kcwtwQ5XaPEJSRPcJ3GttTYZcO55Ax7Ak0GfNr08R51UMFnLCbktG0FPPmB7Y2HMcfbgwjgwZHLegWIvbbOD1yPgueyyLyynhwsmKlwfeG2vJLA(xZkWRGZduMudD618VMW4TnjjN82cUgEQXEnwQjmEBtsqaxHro4ELAiunHXBBsso5TfCn)Q5NMkmEdonfg5G7v0UMxY18RPKlqzcK(lnLzBx2o0uOiWWkXWAoSKWawSQvEJ(W1Wtn2jqnwxJjWEY7xPg60RbfbgwjgwZHLed5IvTYB0hUgEQXobQX6Amb2tE)kAQW4n40uypwmY(iAxZlF08RPKlqzcK(lnLzBx2o0uOiWWkXWAoSKyixSQvEJ(W1WtnMa7jVFLAOtVgueyyLyynhwsyalwfeG2vJLAWawSjXWAoSudp1qGAOtVgueyyLyynhwsyalwfeG2vJLAyixSjXWAoSuZNQjmEdofTn8CvFjyw)K71qOASRPcJ3GttH9yH7v0UMxRQ5xtjxGYei9xAkZ2USDOPqrGHvIH1CyjHbSyvR8g9HRHNAmb2tE)k1qNEnOiWWkXWAoSKyixSkiaTRgl1WqUytIH1CyPMpvty8gCkAB45Q(sWS(j3RHNAiGMkmEdonfTn8CTRDnfwCeon)AETR5xtjxGYei9xAkZ2USDOPmaBYfNRoXSagyHQXsnyoHXsESpIJvE(g48Kj8AiunwTgl1yaVOGehOphxdHQHG1yPg(wJ3Mm99uJLA4BnOiWWkuCQpJcHttfgVbNMIHCXM6dZ1B4n40UMxY18RPKlqzcK(lnfmytNKDxZRDnvy8gCAkoaGLwbdqwJODnV8rZVMsUaLjq6V0uMTDz7qt5btoxblBWsWRCFprk5cuMavJLAmaadcq7uWYgSe8k33tKcHRgl1W3AqrGHv4Ww8iPfeRcHRgl1yaVOGehOphxdp1yVgl1abC1gzeL3Mm99uJLA(xdeWvmKl2uFyUEdVbNYBtM(EQHo9A4BnEWKZvmKl2uFyUEdVbNsUaLjq18ttfgVbNMch2IhjTGy1UMxRQ5xtjxGYei9xAkSy0u)R5Fn2TtWA(unKZNAYsnOiWWQ(mXEH3GlLPVNeao55skRICpmrHWvZVA(un)RrozFiszq2voVgRRHpkcwtwQrozFisTYJC1yDn)RXQeOMSudkcmSYWKynb277rHWvZVA(vZVA(Og5K9Hi1kpYPPcJ3GttrlAxtz22LTdnLhm5CfkdaG8GboSsUaLjq1yPgueyyfkdaG8GboSccq7QXsnHXBBsc1t(2ppYIRHuneq7AEjOMFnLCbktG0FPPmB7Y2HMYdMCUcLbaqEWahwjxGYeOASudkcmScLbaqEWahwbbOD1yPM)1yaVOGehOphxdHQHG1qNEnyoHXsESpIJvE(g48Kj8AivJ9A(PPcJ3GttzcglfgVbxI1yxtXASNU4v0uOmaaYdg4WAxZB2Q5xtjxGYei9xAQW4n40uMGXsHXBWLyn21uSg7PlEfnLbayqaAN218sy08RPKlqzcK(lnLzBx2o0ugWlkiXb6ZX1Wtn8Pgl18VgueyyfkdaG8GboScHRg60RHV14btoxHYaaipyGdRKlqzcun)0uyFBJR51UMkmEdonLjySuy8gCjwJDnfRXE6Ixrtb3xJZLv7AxtbjWbcZ18R51UMFnLCbktG0FPPmB7Y2HMcfbgw9caxM(sWG9vHWvJLA4BnqlsdPa0y0KWMKmHRPW(2gxZRDnvy8gCAQf5sHXBWLyn21uSg7PlEfnfAWIZiAxZl5A(1uYfOmbs)LMYSTlBhAkOfPHuaAmAsytsMW1uyFBJR51UMkmEdonLjySuy8gCjwJDnfRXE6IxrtbOXOjHnr7AE5JMFnLCbktG0FPPGeSzBoVbNMkRSfqJvdTC5eBYwdhaJBuMOPcJ3GttXTaAmTR51QA(1uYfOmbs)LMYSTlBhAkueyyLj8emyFvqaANMkmEdonL3pYItWilrAxZlb18RPKlqzcK(lnLzBx2o0uOiWWkt4jyW(QGa0onvy8gCAkt4jyW(QDnVzRMFnLCbktG0FPPGeSzBoVbNMkRDsn4CGxd2LG55AQW4n40ulYLcJ3GlXASRPW(2gxZRDnLzBx2o0uOiWWkCEabO9kmifcxn0PxdkcmSIBb0ykeonfRXE6IxrtHDjyEU218sy08RPcJ3GttHZGWyj0aNRPKlqzcK(lTR5LWwZVMsUaLjq6V0uMTDz7qtfgVTjjiGR2MRgs1qanf2324AETRPcJ3GttzcglfgVbxI1yxtXASNU4v0uyXr40UM3SsA(1uYfOmbs)LMkmEdonLjySuy8gCjwJDnfRXE6IxrtzaageG2PDnV2jGMFnLCbktG0FPPcJ3GttTnNMcsWMT58gCAkEfZcyGf6BQjBcSxdFQbS1y1AmGxuqnCG(8A2Mdxd4Qb33dtQXJ9r8AaioUHKAaW1Gklw2m1a2AGq2(EQbvwSSzQPHRbw2Gvd8k33tunnUgeUAYAFxnbhhJOAIAiOHRMVR5QHwUC1W)3QMgxdcxnXbvdTMXQbdaxnWbJvdagwPPmB7Y2HMYaSjxCU6eZcyGfQgl18Vg(wJhm5CfkdaG8GboSsUaLjq1qNEnOiWWkugaa5bdCyfcxn)QXsnyoHXsESpIJvE(g48Kj8AivJ9ASuZ)AmGxuqId0NJRHNAiVgl1Sc8k48aLj1yPgOfPHuBZP82KbNEI(eOe4sRaVcoVgEQXwSDGYe12CjVnzW1yPM)1W3AqrGHvO4uFgfcxn0PxJbayqaANcfN6ZOq4QHo9A(xdkcmScfN6ZOq4QXsngaGbbODkyzdwcEL77jsHWvZVA(vdD61yaVOGehOphxdPAiynwQbfbgw59JS4emYsKcHRgl1GIadR8(rwCcgzjsTYB0hUgcvJvRXsnqlsdP2Mt5Tjdo9e9jqjWLwbEfCEn8udbR5N218A3UMFnLCbktG0FPPmB7Y2HMYaErbjoqFoUgEivZ)AiynFQgBX2bktuWaK1WLqBxQ5NMc7BBCnV21uHXBWPPwKlfgVbxI1yxtXASNU4v0uW914Cz1UMx7KR5xtjxGYei9xAkZ2USDOPGwKgsXT9BWs02WZvEBYGtprFcucCPvGxbNxdpKQHCcuJLAmGxuqId0NJRHhs1qUMkmEdonf32VblrBdpxtX6tsginfb1UMx78rZVMsUaLjq6V0uqc2SnN3GttLvGW8(tpgOAWUempxtfgVbNMYemwkmEdUeRXUMc7BBCnV21uMTDz7qtHIadRqXP(mkeonfRXE6IxrtHDjyEU218A3QA(1uYfOmbs)LMYSTlBhAkS4EFpyfCZyYMw5zb088ASuJhm5CfkdaG8GboSsUaLjq1yPgueyyfkdaG8GboSccq7QXsnHXBBsc1t(2ppYIRHuneOgl1yxrWAYsnpgi1BK9Aiun)R5Fn)RXUDcwZNQHC(utwQbfbgw1Nj2l8gCPm99KaWjpxszvK7HjkeUA(vZNQ5FnYj7drkdYUY51yDn8rrWAYsnYj7drQvEKRgRR5FnwLa1KLAqrGHvgMeRjWEFpkeUA(vZVA(vZh1iNSpePw5rUA(PPcJ3GttTYZcO55AxZRDcQ5xtjxGYei9xAkibB2MZBWPP4pxQ5fG9AKSZjhUTj18f)1yiYWKA(ZF(k48AOYxbQgkAnNuJbG9ASBNG1iNSperCnVrgPgmYk1qtQXexnVrgPgpp8A6RgRwZddGgm8pnfwmAQ)18Vg72jynFQgY5tnzPgueyyvFMyVWBWLY03tcaN8CjLvrUhMOq4Q5xnFQM)1iNSpePmi7kNxJ11WhfbRjl1iNSpePw5rUASUM)1yvcutwQbfbgwzysSMa799Oq4Q5xn)Q5xnFuJCY(qKALh50uHXBWPPOfTRPmB7Y2HMYdMCUcLbaqEWahwjxGYeOASudkcmScLbaqEWahwbbOD1yPMW4TnjH6jF7NhzX1qQgcODnV2Zwn)Ak5cuMaP)stz22LTdnLhm5CfkdaG8GboSsUaLjq1yPgueyyfkdaG8GboSccq70uHXBWPPwKlfgVbxI1yxtXASNU4v0uOmaaYdg4WAxZRDcJMFnLCbktG0FPPcJ3GttbllW0aeCcTDrtz22LTdnfkcmSk4KSN4wbkCWItMnS13JcHttziYWKKh7J4ynV21UMx7e2A(1uYfOmbs)LMcgSPtYUR51UMkmEdonfhaWsRGbiRr0UMx7zL08RPKlqzcK(lnvy8gCAQnYiAkZ2USDOP(xZkWRGZduMudD61WjlUXUCE6fH5nhRLTgEQbc4QnYikUxeM3CSw2A(vJLAGwKgsTrgr5Tjdo9e9jqjWLwbEfCEn8udMtySKh7J4yfMwZjjt41KLAiVMpvd5AkdrgMK8yFehR51U218sob08RPKlqzcK(lnvy8gCAkgYfBQpmxVH3Gttz22LTdn1)AwbEfCEGYKAOtVgozXn2LZtVimV5yTS1WtnqaxXqUyt9H56n8gCkUxeM3CSw2A(vJLAGwKgsXqUyt9H56n8gCkVnzWPNOpbkbU0kWRGZRHNAWCcJL8yFehRW0AojzcVMSud518PAixtziYWKKh7J4ynV21UMxYTR5xtjxGYei9xAkyWMoj7UMx7AQW4n40uCaalTcgGSgr7AEjNCn)Ak5cuMaP)stfgVbNMYZ3aNNmHRPmB7Y2HMAf4vW5bktQXsnqlsdP88nW5jt4kVnzWPNOpbkbU0kWRGZRHNA(xJvRX6AWCcJL8yFehR88nW5jt41KLASAn)Q5JA(xJ9ASUM3a7YsuYwWqKA(vZNQXaoiK2vEGDjbd2ekdaGuYfOmbQMpvJbytU4C1jMfWalunwQ5Fn8Tgueyyfko1NrHWvdD61G5egl5X(iow55BGZtMWRHNASxZpnLHidtsESpIJ18Ax7AEjNpA(1uYfOmbs)LMcgSPtYUR51UMkmEdonfhaWsRGbiRr0UMxYTQMFnLCbktG0FPPmB7Y2HM6FnB0qjXMCUkGGWQ(QHNA(xJ9ASUM3i7jtESpcUMpvJjp2hbNG3W4n4cwn)Qjl1SIjp2hj59RuZVASuZ)AWCcJL8yFehRqxepyjmlW51KLAcJ3GtHUiEWsywGZvqXB8i18rnHXBWPqxepyjmlW5kda718RgEQ5FnHXBWPW5RaPGI34rQ5JAcJ3GtHZxbszayVMFAQW4n40uOlIhSeMf4CTR5LCcQ5xtjxGYei9xAkZ2USDOPWCcJL8yFehRW0AojzcVgEQXEnwxdkcmScfN6ZOq4Qjl1qUMkmEdonfMwZjjt4AxZl5zRMFnLCbktG0FPPmB7Y2HMcZjmwYJ9rCSYZ3aNNmHxdp1Whnvy8gCAkpFdCEYeU218soHrZVMsUaLjq6V0uMTDz7qtHIadRmmjwtG9(EuiC1yPM)1GIadRWiqqYLIxueCUccq7QXsnOiWWkCEabO9kmifeG2vdD61GIadRqXP(mkeUA(PPcJ3GttHZxbs7AEjNWwZVMsUaLjq6V0uHXBWPPmbJLcJ3GlXASRPyn2tx8kAk4MXKv7AxtXTIb8IgUMFnV218RPKlqzcK(lnfGttHfxtfgVbNMYwSDGYenLTGHiAkcOPSfB6IxrtbdqwdxcTDr7AEjxZVMsUaLjq6V0uaonfwCnvy8gCAkBX2bkt0u2cgIOPSRPGeSzBoVbNMYkqG7tW1qlp8Ac0M1or14GAqWsnbUMOg4MXKvvdv(kq1qQgcqCn8cUpHVGdNd8A(UiJudPAStCnuxWHZbEnFxKrQHunKtCnwPVDnKQHpexdfTMtQHunwvtzl20fVIMcUzmz1UMx(O5xtjxGYei9xAkaNMclUMkmEdonLTy7aLjAkBbdr0uegnLTytx8kAQT5sEBYG1UMxRQ5xtfgVbNMktFqRaLWC92owtjxGYei9xAxZlb18RPcJ3GttHcCNjqjywqKarRVNKdYEFAk5cuMaP)s7AEZwn)Ak5cuMaP)stz22LTdnfgGWq7dsXHGDeMKKfHZBWPKlqzcun0PxdgGWq7dszdWcVzscdy2KZvYfOmbstfgVbNMcMj4CZgWU218sy08RPKlqzcK(lnLzBx2o0uOiWWQxa4Y0xcgSVkiaTttfgVbNMIBb0yAxZlHTMFnLCbktG0FPPmB7Y2HMcfbgw9caxM(sWG9vbbODAQW4n40uMWtWG9v7AEZkP5xtjxGYei9xAkaNMclUMkmEdonLTy7aLjAkBbdr0ueqtbjyZ2CEdonv2eMCPgaCnHjRJ0RavJVsGrwbxdeqW1CaVgSiV14GAOb2m1qK41ehun5bUghudQudwKttzl20fVIMcCjeSK8TVmIRDnV2jGMFnLCbktG0FPPaCAQacstfgVbNMYwSDGYenLTGHiAk7AkZ2USDOP(xJV9LrCLBxLh4ecwsOiWW1yPgF7lJ4k3UYaamiaTtbHSH3GRMF1qNEn(2xgXvUDvJv9HnlIhOmjL1rIZrEtqIT2iAkBXMU4v0uGlHGLKV9LrCTR51UDn)Ak5cuMaP)stb40ubeKMkmEdonLTy7aLjAkBbdr0uKRPmB7Y2HM6Fn(2xgXvo5Q8aNqWscfbgUgl14BFzex5KRmaadcq7uqiB4n4Q5xn0PxJV9LrCLtUQXQ(WMfXduMKY6iX5iVjiXwBenLTytx8kAkWLqWsY3(YiU218ANCn)Ak5cuMaP)stb40uyX1uHXBWPPSfBhOmrtzlyiIMkBTRPSfB6Ixrt9gzp5BFzepLdyqAx7Ak4MXKvZVMx7A(1uYfOmbs)LMkmEdon1gzenLzBx2o0u2ITduMOGBgt2AivJ9ASuZkWRGZduMuJLAGaUAJmII7fH5nhRLTgcrQg7kYRjl1WjlUXUCE6fH5nhRLvtziYWKKh7J4ynV21UMxY18RPKlqzcK(lnLzBx2o0u2ITduMOGBgt2Aivd5AQW4n40uBKr0UMx(O5xtjxGYei9xAkZ2USDOPSfBhOmrb3mMS1qQg(OPcJ3GttXqUyt9H56n8gCAxZRv18RPKlqzcK(lnLzBx2o0u2ITduMOGBgt2AivJv1uHXBWPPW0Aojzcx7AEjOMFnLCbktG0FPPmB7Y2HMcZjmwYJ9rCSctR5KKj8AivJ9ASudFRbfbgwzysSMa799Oq40uHXBWPPW0Aojzcx7AEZwn)Ak5cuMaP)stz22LTdnfkcmScJabjxkErrW5kiaTttfgVbNMcNVcK218sy08RPKlqzcK(lnLzBx2o0uyX9(EWk4MXKnTYZcO551yPgSWeJ3Gl59Rudp1yxrWAYsnpgi1BKDnvy8gCAQvEwanpx7AxtHDjyEUMFnV218RPKlqzcK(lnfmytNKDxZRDnvy8gCAkoaGLwbdqwJODnVKR5xtjxGYei9xAkZ2USDOPqrGHvO4uFgfcxnwQbZjmwYJ9rCSctR5KKj8A4Pg(uJLAwKtGb7JOGx5(EIqJdsjxGYeinvy8gCAkmTMtsMW1UMx(O5xtjxGYei9xAQW4n40uBKr0ugImmj5X(iowZRDnLzBx2o0u)Rbc4QnYikUxeM3CSw2Aiun2veSg60Rzf4vW5bktQ5xnwQbArAi1gzeL3Mm40t0NaLaxAf4vW51WtnKxdD618VgozXn2LZtVimV5yTS1WtnqaxTrgrX9IW8MJ1YwJLAqrGHvO4uFgfcxnwQbZjmwYJ9rCSYZ3aNNmHxdHQHp1yPgdWMCX5QtmlGbwOA(vdD61GIadRqXP(mQvEJ(W1qOASRPGeSzBoVbNM67ImsnNiq4AwaYtoJOAiibScRbaxt74AyY9451eEnrnV91ViV14GAWilxGX1GZxbcxdeNODnVwvZVMsUaLjq6V0uMTDz7qtH5egl5X(iow55BGZtMWRHq1WNASuZkWRGZduMuJLAGwKgsXqUyt9H56n8gCkVnzWPNOpbkbU0kWRGZRHNAiynwQ5FngWlkiXb6ZX1qQgRwdD61abCfd5In1hMR3WBWPw5n6dxdHQHG1qNEn8TgiGRyixSP(WC9gEdoL3Mm99uZpnvy8gCAkgYfBQpmxVH3Gt7AEjOMFnLCbktG0FPPcJ3GttHUiEWsywGZ1uqc2SnN3Gtt91I4bRgkwGZRPX1GkUlBnEEC1GDjyEEnu5Ravt41WNA8yFehRPmB7Y2HMcZjmwYJ9rCScDr8GLWSaNxdp1qU218MTA(1uYfOmbs)LMcgSPtYUR51UMkmEdonfhaWsRGbiRr0UMxcJMFnLCbktG0FPPmB7Y2HMYaErbjoqFoUgcvJvRXsnyoHXsESpIJvE(g48Kj8AiuneutfgVbNMcNVcK21UMYaamiaTtZVMx7A(1uYfOmbs)LMkmEdonvafCEBtsyAX(QPmB7Y2HM6Fn)RHV1abCvafCEBtsyAX(MGI34ruEBY03tn0PxdeWvbuW5TnjHPf7BckEJhrTYB0hUgcvd518Rgl18VgiGRcOGZBBsctl23eu8gpIc7HjtneQg(udD61W3AGaUkGcoVTjjmTyFt5sWuypmzQHNASxZVASudFRbfbgwfqbN32KeMwSVPCjyP(sWS(j3viC1yPg(wdkcmSkGcoVTjjmTyFtqXB8iP(sWS(j3viC18Rgl14X(iUY7xj5Geul1WtneSg60RjmEBtsYjVTGRHNAiVgl1W3AGaUkGcoVTjjmTyFtqXB8ikVnz67Pgl1iNSpevdHQHpeSgl14X(iUY7xj5Geul1WtneutziYWKKh7J4ynV21UMxY18RPKlqzcK(lnLzBx2o0u)RbdqyO9bP4qWoctsYIW5n4uYfOmbQg60RbdqyO9bPSbyH3mjHbmBY5k5cuMavZpnvFUSlcNNAynfgGWq7dszdWcVzscdy2KZ1u95YUiCEQFFfOoCrtzxtfgVbNMcMj4CZgWUMQpx2fHZtpmaAW0u21UMx(O5xtjxGYei9xAQW4n40u(2xgXTRPmB7Y2HM6Fn)RXaamiaTtzaNnqgj55scZ1B7y1kVrF4AiunKxJLA(xdkcmScfN6ZOq4QHo9Amaadcq7uO4uFg1kVrF4A4Pg7eOMF18Rg60RbfGX1yPg4(j3tR8g9HRHq1qobQ5xn0PxZ)Amaadcq7ugWzdKrsEUKWC92owTYB0hUMpvd51Wtn2ITduMOEJSN8TVmINYbmOA(vdD61yl2oqzIcCjeSK8TVmIxdPAiqn0PxZ)ASfBhOmrbUecws(2xgXRHunKxJLA(xJbayqaANYaoBGmsYZLeMR32XQvEJ(W1WtnKtEn0PxdkaJRXsnW9tUNw5n6dxdHQHCcudD614BFzex5KRmaadcq7uR8g9HRHNAiNa18RMFAkmd4ynLV9LrC7AxZRv18RPKlqzcK(lnvy8gCAkF7lJ4KRPmB7Y2HM6Fn)RXaamiaTtzaNnqgj55scZ1B7y1kVrF4AiunKxJLA(xdkcmScfN6ZOq4QHo9Amaadcq7uO4uFg1kVrF4A4Pg7eOMF1yPM)14BFzex52vgaGbbODQvEJ(W1WdPAiVg60RXwSDGYef4siyj5BFzeVgs1qEn)Q5xn0PxdkaJRXsnW9tUNw5n6dxdHQHCcuZVAOtVM)18VgdaWGa0oLbC2azKKNljmxVTJvR8g9HR5t1qEnwxt2sGAYsn)R5Fn(2xgXvUDLbayqaANAL3OpCneQgdaWGa0oLbC2azKKNljmxVTJvR8g9HR5t1qEn)QXsn)RXwSDGYef4siyj5BFzeVgs1yVg60RXwSDGYef4siyj5BFzeVgEivdFQ5xn)Q5xn8uJTy7aLjQ3i7jF7lJ4PCadQMF1qNEn2ITduMOaxcbljF7lJ41qQgcudD618VgBX2bktuGlHGLKV9Lr8AivJ9ASuZ)Amaadcq7ugWzdKrsEUKWC92owTYB0hUgEQHCYRHo9AqbyCnwQbUFY90kVrF4AiunKtGAOtVgF7lJ4k3UYaamiaTtTYB0hUgEQHCcuZVA(PPWmGJ1u(2xgXjx7AEjOMFnLCbktG0FPPGeSzBoVbNMkBcSxd)9JSFgxZ3czjQgubgSsn)bBn97Ra1HZiQMa2L9xnMa799uZ3s2GvZ3AL77jQMgUMVKflBMAACn8M14VgWvJbayqaANstHj6mAkyzdwcEL77jstz22LTdnLbayqaANcfN6ZOq40uHXBWPP8(rwCcgzjs7AEZwn)Ak5cuMaP)stfgVbNMcw2GLGx5(EI0uMTDz7qtzaVOGehOphxdHQHp1yPgp2hXvE)kjhKGAPgEQHWuJLA(xdkcmSch2IhjTGyviC1qNEn8TgpyY5kCylEK0cIvjxGYeOA(vJLA(xdFRXaamiaTt59JS4emYsKcHRg60RXaamiaTtHIt9zuiC18Rg60RbfGX1yPg4(j3tR8g9HRHq1qyxJLAG7NCpTYB0hUgEQHCnLHidtsESpIJ18Ax7AEjmA(1uYfOmbs)LMkmEdonfQSyzZOPGeSzBoVbNMI)SMvqw7BQHxrGQXb1Gj6m1qR98AO1EEnBytoacUg4vUVNOAOLlxn0KAwKRg4vUVNi04GiUgWwt4mjWEnMCXKPMgUM2X1qdSEEnTRPmB7Y2HMkmEBtsqaxTnxn8udbQXsn)RXaamiaTtzaNnqgj55scZ1B7yfcxn0PxJbayqaANYaoBGmsYZLeMR32XQvEJ(W1Wtn8H8AOtVguagxJLAG7NCpTYB0hUgcvd5eOMFAxZlHTMFnLCbktG0FPPmB7Y2HMkmEBtsqaxTnxn8udbQXsn)RXaamiaTtzaNnqgj55scZ1B7yfcxn0PxdkaJRXsnW9tUNw5n6dxdHQHpeOMFAQW4n40u9zI9cVbN218MvsZVMsUaLjq6V0uHXBWPP8(rwCcgzjstbjyZ2CEdonf)lr1ehunhWRHwGDPg()w1iNSperCnOiEnbddQjRIG9AqWsnTxdmyR57LntnXbvtFMypSMYSTlBhAk5K9HifKa3M2RHNASkbQHo9AqrGHvO4uFgfcxn0PxZ)A8GjNR4wbkCWQKlqzcunwQbNdwxWEYDOAiun8PMF1qNEn)RjmEBtsqaxTnxnKQHa1yPgueyyfkdaG8GboScHRMFAxZRDcO5xtjxGYei9xAQW4n40u48acq7vyqAkibB2MZBWPPYk6NCVguPgAl4EQXb1GGLAOEfgunGRMVlYi10xn2KLOASjlr1CTjxQb3os4n4WexdkIxJnzjQMnwHrKMYSTlBhAkueyyL3pYItWilrkeUASudkcmScfN6ZOGa0UASuJb8IcsCG(CCneQgRwJLAqrGHvyeii5sXlkcoxbbOD1yPgiGR2iJO4EryEZXAzRHq1yxLT1yPg5K9HOA4PgRsGASud0I0qQnYikVnzWPNOpbkbU0kWRGZRHNAWCcJL8yFehRW0AojzcVMSud518PAiVgl14X(iUY7xj5Geul1Wtneu7AETBxZVMsUaLjq6V0uMTDz7qtHIadR8(rwCcgzjsHWvdD61GIadRqXP(mkeonvy8gCAkuzXYMPVhTR51o5A(1uYfOmbs)LMYSTlBhAkueyyfko1NrHWvdD61GcW4ASudC)K7PvEJ(W1qOAmaadcq7uO4uFg1kVrF4AOtVguagxJLAG7NCpTYB0hUgcvd5eutfgVbNMId4n40UMx78rZVMsUaLjq6V0uMTDz7qtHIadRqXP(mkeUAOtVg4(j3tR8g9HRHq1qUDnvy8gCAQnSjhabNGx5(EI0UMx7wvZVMsUaLjq6V0uHXBWPPmGZgiJK8CjH56TDSMcsWMT58gCAk(ZAwbzTVPMSjxmzQ5faUm9vtoWPvtCq1GDey4AyDgPgpVXextCq18geHk1GkUlBngWlA41SYB0xnRGj6mAkZ2USDOP(xdeWvBZPw5n6dxdp1y1ASuJb8IcsCG(CCneQgcwJLA(xdeWvBKruEBY03tn0PxdMtySKh7J4yLNVbopzcVgEQXEn)QXsnYj7drkibUnTxdpKQHCcuJLAmaadcq7uO4uFg1kVrF4A4Pg7eOMF1qNEnOamUgl1a3p5EAL3OpCneQgcwdD618Vgueyyfko1NrHWvJLAqrGHvO4uFg1kVrF4A4Pg7KxZpTR51ob18RPKlqzcK(lnvy8gCAk5Ldqt2ek4G0uqc2SnN3GttLveeHk145Yk1GZbimOAqLAEbRuJbCqT3Gdxd4QXZLAmGdcPDnLzBx2o0uOiWWkVFKfNGrwIuiC1qNEn)RXaoiK2vqIWLcgtE64mIsUaLjq18t7AETNTA(1uYfOmbs)LMcsWMT58gCAkR42Mud32GTDIQXb1aUpHGLAOjbh40ux8kAQSkWrUhP3nbjyVpIWjtWyAkZ2USDOPKSosZXjqQSkWrUhP3nbjyVpIWjtWyAQW4n40uzvGJCpsVBcsWEFeHtMGX0UMx7egn)AQW4n40uiyj1U8I1uYfOmbs)L21UMcqJrtcBIMFnV218RPKlqzcK(lnLzBx2o0uOiWWQCjwpbGtEUKO1mifcNMkmEdonf2JfJSpI218sUMFnLCbktG0FPPcJ3GttHro4EfnfRpjzG0uwnlpgiTR5LpA(1uYfOmbs)LMkmEdon1laCW9kAkZ2USDOPqrGHvVaWLPVemyFviC1yPgmNWyjp2hXXkpFdCEYeEneQgYRXsn8TgpyY5kgYfBQpmxVH3GtjxGYeOASuJCY(quneQMSLa1yPg(wdkcmSYWKynb277rHWPPy9jjdKMYQz5XaPDnVwvZVMsUaLjq6V0uMTDz7qtjNSpevdHQHpeOgl1abC12CQvEJ(W1WtnwvrWASuZ)Amaadcq7uE)ilobJSePw5n6dxdpKQjBveSg60RzrobgSpIYeUqKKmiBduYfOmbQMF1yPgueyyLHjXAcS33Jc7HjtneQg71yPg(wdkcmSk4KSN4wbkCWItMnS13JcHRgl1W3AqrGHvOmaaIHGDfcxnwQHV1GIadRqXP(mkeUASuZ)Amaadcq7ugWzdKrsEUKWC92owTYB0hUgEQjBveSg60RHV1ya2KloxD9tUNGdPMF1yPM)1W3AmaBYfNRoXSagyHQHo9Amaadcq7ubuW5TnjHPf7RAL3OpCn8qQgcwdD61abCvafCEBtsyAX(MGI34ruR8g9HRHNAim18ttfgVbNMkxI1ta4KNljAnds7AEjOMFnLCbktG0FPPmB7Y2HMsozFiQgcvdFiqnwQbc4QT5uR8g9HRHNASQIG1yPM)1yaageG2P8(rwCcgzjsTYB0hUgEivJvveSg60RzrobgSpIYeUqKKmiBduYfOmbQMF1yPgueyyLHjXAcS33Jc7HjtneQg71yPg(wdkcmSk4KSN4wbkCWItMnS13JcHRgl1W3AqrGHvOmaaIHGDfcxnwQ5Fn8Tgueyyfko1NrHWvdD61ya2KloxDIzbmWcvJLA8GjNRWHT4rsliwLCbktGQXsnOiWWkuCQpJAL3OpCn8ut2wZVASuZ)Amaadcq7ugWzdKrsEUKWC92owTYB0hUgEQjBveSg60RHV1ya2KloxD9tUNGdPMF1yPM)1W3AmaBYfNRoXSagyHQHo9Amaadcq7ubuW5TnjHPf7RAL3OpCn8qQgcwdD61abCvafCEBtsyAX(MGI34ruR8g9HRHNAim18Rgl1a3p5EAL3OpCn8udHrtfgVbNM6faUm9LGb7R21U21u2Kf3GtZl5eGCYjGvjNWwtrl2RVhSMYkIW6749BZRv83utn8Nl10VCG1RbgS18z4(ACUSFUMvY6i9kq1GbVsnbIdEdxGQXKh3JGvfzwP(KAS63ut2aoBY6cunFErobgSpIYk)5ACqnFErobgSpIYkRKlqzc0NR5V9S)tvKvKzfry9D8(T51k(BQPg(ZLA6xoW61ad2A(mKahim)Z1SswhPxbQgm4vQjqCWB4cunM84EeSQiZk1Nud5K)n1KnGZMSUavdv)Mn1Gj68i71yfwJdQXkHe1a12ACdUAaCYgoyR5)h)Q5V9S)tvKzL6tQHCR(n1KnGZMSUavdv)Mn1Gj68i71yfwJdQXkHe1a12ACdUAaCYgoyR5)h)Q5p5z)NQiRiZkIW6749BZRv83utn8Nl10VCG1RbgS18zUvmGx0W)CnRK1r6vGQbdELAceh8gUavJjpUhbRkYSs9j1yNaFtnzd4SjRlq18zF7lJ4k7kR8NRXb18zF7lJ4k3UYk)5A(ZNS)tvKzL6tQXU9VPMSbC2K1fOA(SV9LrCf5kR8NRXb18zF7lJ4kNCLv(Z18Npz)NQiRiZkIW6749BZRv83utn8Nl10VCG1RbgS18zugaa5bdC4pxZkzDKEfOAWGxPMaXbVHlq1yYJ7rWQImRuFsn85BQjBaNnzDbQgQ(nBQbt05r2RXkSghuJvcjQbQT14gC1a4KnCWwZ)p(vZF7z)NQiRiZkIW6749BZRv83utn8Nl10VCG1RbgS18zSlbZZ)CnRK1r6vGQbdELAceh8gUavJjpUhbRkYSs9j1q(3ut2aoBY6cunFErobgSpIYk)5ACqnFErobgSpIYkRKlqzc0NRj8AYkpRzLQ5V9S)tvKvKzfry9D8(T51k(BQPg(ZLA6xoW61ad2A(SbayqaA3NRzLSosVcunyWRutG4G3WfOAm5X9iyvrMvQpPgY)MAYgWztwxGQ5ZyacdTpiLv(Z14GA(mgGWq7dszLvYfOmb6Z18N8S)tvKzL6tQHpFtnzd4SjRlq18zF7lJ4kYvw5pxJdQ5Z(2xgXvo5kR8NR5V9S)tvKzL6tQXQFtnzd4SjRlq18zF7lJ4k7kR8NRXb18zF7lJ4k3UYk)5A(ZNS)tvKvKzfry9D8(T51k(BQPg(ZLA6xoW61ad2A(mGgJMe2KpxZkzDKEfOAWGxPMaXbVHlq1yYJ7rWQImRuFsnw9BQjBaNnzDbQMpViNad2hrzL)CnoOMpViNad2hrzLvYfOmb6Z183E2)PkYSs9j1qWVPMSbC2K1fOA(8ICcmyFeLv(Z14GA(8ICcmyFeLvwjxGYeOpxZF7z)NQiRi7B)YbwxGQXobQjmEdUAyn2XQImnfMtmAETta(OP4waCZenfHt418TKny1yfSinurgHt41KveevJD(qCnKtaYjViRiJWj8AYM84Ee83uKr4eEnFQgOfPHuaAmAsytsMWjzVgtUyYGRXb1aTinKcqJrtcBsYeUQiJWj8A(unzd4SjRxZx8xdhaWsRGbiRrQXb1qlAVgj7CRGXn4Q5F2j)NQiJWj8A(unewqq10Nl7IW5nktQ5BXeCUzdyVMgUgIai1Kh2KAoGN33tncdl14GAGaQImcNWR5t1yfaUp71Kdyq1KnGZgiJudmyR57AUAqoMGX1qea5ZmwnRemgr18DnNQiJWj8A(unuiCCG1RbUzmzR57KNfqZZRHwEZKA4aawFp1ad2A(IbaqEWahwvKr4eEnFQgRiWMPgWvdHfuW5TnPgkAX(wdgHJdSUQiRilmEdoSIBfd4fnCRj9HTy7aLjeFXRqcgGSgUeA7cX2cgIqIafzeEnwbcCFcUgA5HxtG2S2jQghudcwQjW1e1a3mMSQAOYxbQgs1qaIRHxW9j8fC4CGxZ3fzKAivJDIRH6coCoWR57ImsnKQHCIRXk9TRHun8H4AOO1CsnKQXQfzHXBWHvCRyaVOHBnPpSfBhOmH4lEfsWnJjlX2cgIqYErwy8gCyf3kgWlA4wt6dBX2bkti(IxH02CjVnzWeBlyicjctrwy8gCyf3kgWlA4wt6Jm9bTcucZ1B74ISW4n4WkUvmGx0WTM0hOa3zcucMfejq067j5GS3xrwy8gCyf3kgWlA4wt6dyMGZnBa7e3WKWaegAFqkoeSJWKKSiCEdoLCbktGOthdqyO9bPSbyH3mjHbmBY5k5cuMavKfgVbhwXTIb8IgU1K(GBb0ye3WKqrGHvVaWLPVemyFvqaAxrwy8gCyf3kgWlA4wt6dt4jyW(sCdtcfbgw9caxM(sWG9vbbODfzeEnztyYLAaW1eMSosVcun(kbgzfCnqabxZb8AWI8wJdQHgyZudrIxtCq1Kh4ACqnOsnyrUISW4n4WkUvmGx0WTM0h2ITduMq8fVcjWLqWsY3(YioX2cgIqIafzHXBWHvCRyaVOHBnPpSfBhOmH4lEfsGlHGLKV9LrCIbCKciiIBys)9TVmIRSRYdCcbljueyyl(2xgXv2vgaGbbODkiKn8gC)Ot33(YiUYUQXQ(WMfXduMKY6iX5iVjiXwBeITfmeHK9ISW4n4WkUvmGx0WTM0h2ITduMq8fVcjWLqWsY3(YioXaosbeeXnmP)(2xgXvKRYdCcbljueyyl(2xgXvKRmaadcq7uqiB4n4(rNUV9LrCf5QgR6dBwepqzskRJeNJ8MGeBTri2wWqesKxKfgVbhwXTIb8IgU1K(WwSDGYeIV4vi9gzp5BFzepLdyqeBlyicPS1Erwrwy8gCyslYLcJ3GlXASt8fVcj0GfNrig7BBCs2jUHjHIadREbGltFjyW(Qq4SWxOfPHuaAmAsytsMWlYcJ3GdBnPpmbJLcJ3GlXASt8fVcjangnjSjeJ9Tnoj7e3WKGwKgsbOXOjHnjzcViJWRjRSfqJvdTC5eBYwdhaJBuMuKfgVbh2AsFWTaASISW4n4Wwt6dVFKfNGrwIiUHjHIadRmHNGb7Rccq7kYcJ3GdBnPpmHNGb7lXnmjueyyLj8emyFvqaAxrgHt41egVbh2AsFyl2oqzcXx8kKW5G1fSNChIyBbdri5X(iUY7xj5GeulfzeoHxty8gCyRj9HHidRVNKTy7aLjeFXRqcNdwxWEYDiIbCKE7JyBbdri5X(iUY7xj5GeulfzeEnzTtQbNd8AWUempVilmEdoS1K(yrUuy8gCjwJDIV4viHDjyEoXyFBJtYoXnmjueyyfopGa0EfgKcHJoDueyyf3cOXuiCfzHXBWHTM0h4mimwcnW5fzHXBWHTM0hMGXsHXBWLyn2j(IxHewCeoIX(2gNKDIBysHXBBscc4QT5irGISW4n4Wwt6dtWyPW4n4sSg7eFXRqYaamiaTRiJWRHxXSagyH(MAYMa71WNAaBnwTgd4ffudhOpVMT5W1aUAW99WKA8yFeVgaIJBiPgaCnOYILntnGTgiKTVNAqLflBMAA4AGLny1aVY99evtJRbHRMS23vtWXXiQMOgcA4Q57AUAOLlxn8)TQPX1GWvtCq1qRzSAWaWvdCWy1aGHvfzHXBWHTM0hBZrCdtYaSjxCU6eZcyGfYYF(6btoxHYaaipyGdRKlqzceD6OiWWkugaa5bdCyfc3plyoHXsESpIJvE(g48KjCs2T83aErbjoqFoMhYTSc8k48aLjwGwKgsTnNYBtgC6j6tGsGlTc8k4CESfBhOmrTnxYBtgSL)8ffbgwHIt9zuiC0PBaageG2PqXP(mkeo60)JIadRqXP(mkeolgaGbbODkyzdwcEL77jsHW97hD6gWlkiXb6ZXKiOfueyyL3pYItWilrkeolOiWWkVFKfNGrwIuR8g9HjKvTaTinKABoL3Mm40t0NaLaxAf4vW58qWFfzHXBWHTM0hlYLcJ3GlXASt8fVcj4(ACUSeJ9Tnoj7e3WKmGxuqId0NJ5H0Fc(jBX2bktuWaK1WLqBx(vKfgVbh2AsFWT9BWs02WZjUHjbTinKIB73GLOTHNR82KbNEI(eOe4sRaVcoNhsKtalgWlkiXb6ZX8qICIz9jjdejcwKr41KvGW8(tpgOAWUempVilmEdoS1K(WemwkmEdUeRXoXx8kKWUempNySVTXjzN4gMekcmScfN6ZOq4kYcJ3GdBnPpw5zb08CIBysyX9(EWk4MXKnTYZcO55w8GjNRqzaaKhmWHvYfOmbYckcmScLbaqEWahwbbODwcJ32KeQN8TFEKftIawSRiywEmqQ3i7e6)))2TtWproFYckcmSQptSx4n4sz67jbGtEUKYQi3dtuiC)(0F5K9HiLbzx5CR5JIGzrozFisTYJCw)3QeilOiWWkdtI1eyVVhfc3VF)(qozFisTYJC)kYi8A4pxQ5fG9AKSZjhUTj18f)1yiYWKA(ZF(k48AOYxbQgkAnNuJbG9ASBNG1iNSperCnVrgPgmYk1qtQXexnVrgPgpp8A6RgRwZddGgm8VISW4n4Wwt6dAr7eJfdP))TBNGFIC(KfueyyvFMyVWBWLY03tcaN8CjLvrUhMOq4(9P)Yj7drkdYUY5wZhfbZICY(qKALh5S(VvjqwqrGHvgMeRjWEFpkeUF)(9HCY(qKALh5iUHj5btoxHYaaipyGdRKlqzcKfueyyfkdaG8GboSccq7SegVTjjup5B)8ilMebkYiCcVMW4n4Wwt6doaGLwbdqwJqCdtYdMCUcLbaqEWahwjxGYeilOiWWkugaa5bdCyfeG2z5VCY(qK18rrWSiNSpePw5roR)BvcKfueyyLHjXAcS33JcH73pc93UDc(jY5twqrGHv9zI9cVbxktFpjaCYZLuwf5EyIcH7NLW4TnjH6jF7NhzXKiqrwy8gCyRj9XICPW4n4sSg7eFXRqcLbaqEWahM4gMKhm5CfkdaG8GboSsUaLjqwqrGHvOmaaYdg4WkiaTRilmEdoS1K(awwGPbi4eA7cXgImmj5X(ioMKDIBysOiWWQGtYEIBfOWbloz2WwFpkeUISW4n4Wwt6doaGLwbdqwJqmmytNKDNK9ISW4n4Wwt6JnYieBiYWKKh7J4ys2jUHj9Ff4vW5bktOtNtwCJD580lcZBowllpqaxTrgrX9IW8MJ1Y(Zc0I0qQnYikVnzWPNOpbkbU0kWRGZ5bZjmwYJ9rCSctR5KKj8Sq(NiVilmEdoS1K(GHCXM6dZ1B4n4i2qKHjjp2hXXKStCdt6)kWRGZduMqNoNS4g7Y5PxeM3CSwwEGaUIHCXM6dZ1B4n4uCVimV5yTS)SaTinKIHCXM6dZ1B4n4uEBYGtprFcucCPvGxbNZdMtySKh7J4yfMwZjjt4zH8prErwy8gCyRj9bhaWsRGbiRriggSPtYUtYErwy8gCyRj9HNVbopzcNydrgMK8yFehtYoXnmPvGxbNhOmXc0I0qkpFdCEYeUYBtgC6j6tGsGlTc8k4CE(BvRXCcJL8yFehR88nW5jt4zXQ)Sc)B363a7YsuYwWqKFFYaoiK2vEGDjbd2ekdaGuYfOmb6tgGn5IZvNywadSqw(Zxueyyfko1NrHWrNoMtySKh7J4yLNVbopzcNh7)kYcJ3GdBnPp4aawAfmazncXWGnDs2Ds2lYcJ3GdBnPpqxepyjmlW5e3WK(VrdLeBY5QaccR6JN)2T(nYEYKh7JG)Kjp2hbNG3W4n4c2VSSIjp2hj59R8ZYFmNWyjp2hXXk0fXdwcZcCEwcJ3GtHUiEWsywGZvqXB8iwHHXBWPqxepyjmlW5kda7)45Fy8gCkC(kqkO4nEeRWW4n4u48vGuga2)vKfgVbh2AsFGP1CsYeoXnmjmNWyjp2hXXkmTMtsMW5XU1OiWWkuCQpJcHllKxKfgVbh2AsF45BGZtMWjUHjH5egl5X(iow55BGZtMW5HpfzHXBWHTM0h48vGiUHjHIadRmmjwtG9(EuiCw(JIadRWiqqYLIxueCUccq7SGIadRW5beG2RWGuqaAhD6OiWWkuCQpJcH7xrwy8gCyRj9HjySuy8gCjwJDIV4vib3mMSfzfzHXBWHvOmaaYdg4WK2iJqSHidtsESpIJjzN4gM0F(6TjtFp0P)3UI8SWjlUXUCE6fH5nhRLLhsqaxTrgrX9IW8MJ1Y(Jo9)HXBBsc1t(2ppYIjrULvGxbNhOm53plOiWWkupTrgrbbODfzHXBWHvOmaaYdg4Wwt6dgYfBQpmxVH3GJydrgMK8yFehtYoXnmPvGxbNhOmXckcmSc1tVaWb3ROGa0UISW4n4Wkugaa5bdCyRj9HNVbopzcNydrgMK8yFehtYoXnmPvGxbNhOmXckcmSc1tE(g4CfeG2zbArAiLNVbopzcx5Tjdo9e9jqjWLwbEfCop)TQ1yoHXsESpIJvE(g48Kj8Sy1FwH)TB9BGDzjkzlyiYVpzahes7kpWUKGbBcLbaqk5cuMavKfgVbhwHYaaipyGdBnPpqxepyjmlW5e3WKqrGHvOEcDr8GLWSaNRGa0UISW4n4Wkugaa5bdCyRj9bMwZjjt4e3WKqrGHvOEctR5efeG2zbZjmwYJ9rCSctR5KKjCESxKfgVbhwHYaaipyGdBnPpW5RarCdtcfbgwH6jC(kqkiaTRilmEdoScLbaqEWah2AsFGP1CsYeoXnmjueyyfQNW0AorbbODfzHXBWHvOmaaYdg4Wwt6dpFdCEYeoXnmjueyyfQN88nW5kiaTRiRilmEdoSYaamiaTJuafCEBtsyAX(sSHidtsESpIJjzN4gM0))8fc4Qak482MKW0I9nbfVXJO82KPVh60HaUkGcoVTjjmTyFtqXB8iQvEJ(WeI8Fw(dbCvafCEBtsyAX(MGI34ruypmzieFOtNVqaxfqbN32KeMwSVPCjykShMm8y)Nf(IIadRcOGZBBsctl23uUeSuFjyw)K7keol8ffbgwfqbN32KeMwSVjO4nEKuFjyw)K7keUFw8yFex59RKCqcQfEiiD6HXBBsso5TfmpKBHVqaxfqbN32KeMwSVjO4nEeL3Mm99yrozFiIq8HGw8yFex59RKCqcQfEiyrwy8gCyLbayqaAN1K(aMj4CZgWoXnmP)yacdTpifhc2ryssweoVbhD6yacdTpiLnal8MjjmGzto)hX95YUiCEQFFfOoCHKDI7ZLDr480ddGgms2jUpx2fHZtnmjmaHH2hKYgGfEZKegWSjNxKfgVbhwzaageG2znPpqWsQD5ftmMbCmjF7lJ42jUHj9)VbayqaANYaoBGmsYZLeMR32XQvEJ(WeICl)rrGHvO4uFgfchD6gaGbbODkuCQpJAL3Opmp2jWVF0PJcWylW9tUNw5n6dtiYjWp60)BaageG2PmGZgiJK8CjH56TDSAL3Op8NiNhBX2bktuVr2t(2xgXt5ag0p60TfBhOmrbUecws(2xgXjra60)Bl2oqzIcCjeSK8TVmItICl)naadcq7ugWzdKrsEUKWC92owTYB0hMhYjNoDuagBbUFY90kVrFycrobOt33(YiUICLbayqaANAL3OpmpKtGF)kYcJ3GdRmaadcq7SM0hiyj1U8IjgZaoMKV9LrCYjUHj9)VbayqaANYaoBGmsYZLeMR32XQvEJ(WeICl)rrGHvO4uFgfchD6gaGbbODkuCQpJAL3Opmp2jWpl)9TVmIRSRmaadcq7uR8g9H5He50PBl2oqzIcCjeSK8TVmItI8F)OthfGXwG7NCpTYB0hMqKtGF0P))VbayqaANYaoBGmsYZLeMR32XQvEJ(WFICRZwcKL))9TVmIRSRmaadcq7uR8g9HjKbayqaANYaoBGmsYZLeMR32XQvEJ(WFI8Fw(Bl2oqzIcCjeSK8TVmItYoD62ITduMOaxcbljF7lJ48qIp)(9JhBX2bktuVr2t(2xgXt5ag0p60TfBhOmrbUecws(2xgXjra60)Bl2oqzIcCjeSK8TVmItYUL)gaGbbODkd4SbYijpxsyUEBhRw5n6dZd5KtNokaJTa3p5EAL3OpmHiNa0P7BFzexzxzaageG2Pw5n6dZd5e43VImcVMSjWEn83pY(zCnFlKLOAqfyWk18hS10VVcuhoJOAcyx2F1ycS33tnFlzdwnFRvUVNOAA4A(swSSzQPX1WBwJ)AaxngaGbbODQISW4n4WkdaWGa0oRj9H3pYItWilreJj6mKGLnyj4vUVNiIBysgaGbbODkuCQpJcHRilmEdoSYaamiaTZAsFalBWsWRCFpreBiYWKKh7J4ys2jUHjzaVOGehOphti(yXJ9rCL3VsYbjOw4HWy5pkcmSch2IhjTGyviC0PZxpyY5kCylEK0cIvjxGYeOFw(ZxdaWGa0oL3pYItWilrkeo60naadcq7uO4uFgfc3p60rbySf4(j3tR8g9HjeHTf4(j3tR8g9H5H8ImcVg(ZAwbzTVPgEfbQghudMOZudT2ZRHw751SHn5ai4AGx5(EIQHwUC1qtQzrUAGx5(EIqJdI4AaBnHZKa71yYftMAA4AAhxdnW6510Erwy8gCyLbayqaAN1K(avwSSziUHjfgVTjjiGR2MJhcy5VbayqaANYaoBGmsYZLeMR32Xkeo60naadcq7ugWzdKrsEUKWC92owTYB0hMh(qoD6Oam2cC)K7PvEJ(WeICc8RilmEdoSYaamiaTZAsF0Nj2l8gCe3WKcJ32KeeWvBZXdbS83aamiaTtzaNnqgj55scZ1B7yfchD6Oam2cC)K7PvEJ(WeIpe4xrgHxd)lr1ehunhWRHwGDPg()w1iNSperCnOiEnbddQjRIG9AqWsnTxdmyR57LntnXbvtFMypCrwy8gCyLbayqaAN1K(W7hzXjyKLiIBysYj7drkibUnTZJvjaD6OiWWkuCQpJcHJo9)EWKZvCRafoyvYfOmbYcohSUG9K7qeIp)Ot)Fy82MKGaUABoseWckcmScLbaqEWahwHW9RiJWRjROFY9AqLAOTG7PghudcwQH6vyq1aUA(UiJutF1ytwIQXMSevZ1MCPgC7iH3GdtCnOiEn2KLOA2yfgrfzHXBWHvgaGbbODwt6dCEabO9kmiIBysOiWWkVFKfNGrwIuiCwqrGHvO4uFgfeG2zXaErbjoqFoMqw1ckcmScJabjxkErrW5kiaTZceWvBKruCVimV5yTSeYUkBTiNSpeXJvjGfOfPHuBKruEBYGtprFcucCPvGxbNZdMtySKh7J4yfMwZjjt4zH8prUfp2hXvE)kjhKGAHhcwKfgVbhwzaageG2znPpqLflBM(EiUHjHIadR8(rwCcgzjsHWrNokcmScfN6ZOq4kYcJ3GdRmaadcq7SM0hCaVbhXnmjueyyfko1NrHWrNokaJTa3p5EAL3OpmHmaadcq7uO4uFg1kVrFy60rbySf4(j3tR8g9Hje5eSilmEdoSYaamiaTZAsFSHn5ai4e8k33teXnmjueyyfko1NrHWrNoC)K7PvEJ(WeIC7fzeEn8N1ScYAFtnztUyYuZlaCz6RMCGtRM4GQb7iWW1W6msnEEJjUM4GQ5nicvQbvCx2AmGx0WRzL3OVAwbt0zkYcJ3GdRmaadcq7SM0hgWzdKrsEUKWC92oM4gM0FiGR2MtTYB0hMhRAXaErbjoqFoMqe0YFiGR2iJO82KPVh60XCcJL8yFehR88nW5jt48y)Nf5K9HifKa3M25He5eWIbayqaANcfN6ZOw5n6dZJDc8JoDuagBbUFY90kVrFycrq60)JIadRqXP(mkeolOiWWkuCQpJAL3Opmp2j)xrgHxtwrqeQuJNlRudohGWGQbvQ5fSsngWb1EdoCnGRgpxQXaoiK2lYcJ3GdRmaadcq7SM0hYlhGMSjuWbrCdtcfbgw59JS4emYsKcHJo9)gWbH0UcseUuWyYthNruYfOmb6xrgHxJvCBtQHBBW2or14GAa3NqWsn0KGdCfzHXBWHvgaGbbODwt6deSKAxEj(IxHuwf4i3J07MGeS3hr4KjymIBysswhP54eivwf4i3J07MGeS3hr4KjySISW4n4WkdaWGa0oRj9bcwsTlV4ISISW4n4Wk4MXKL0gzeInezysYJ9rCmj7e3WKSfBhOmrb3mMSKSBzf4vW5bktSabC1gzef3lcZBowllHizxrEw4Kf3yxop9IW8MJ1YwKfgVbhwb3mMSwt6JnYie3WKSfBhOmrb3mMSKiVilmEdoScUzmzTM0hmKl2uFyUEdVbhXnmjBX2bktuWnJjlj(uKfgVbhwb3mMSwt6dmTMtiUHjzl2oqzIcUzmzjz1ISW4n4Wk4MXK1AsFGP1CsYeoXnmjmNWyjp2hXXkmTMtsMWjz3cFrrGHvgMeRjWEFpkeUISW4n4Wk4MXK1AsFGZxbI4gMekcmScJabjxkErrW5kiaTRilmEdoScUzmzTM0hR8SaAEoXnmjS4EFpyfCZyYMw5zb08ClyHjgVbxY7xHh7kcMLhdK6nYErgHt41egVbhwb3mMSwt6dyMGZnBa7e3WKWaegAFqkoeSJWKKSiCEdoLCbktGOthdqyO9bPSbyH3mjHbmBY5k5cuMarCFUSlcNN63xbQdxizN4(Czxeop9WaObJKDI7ZLDr48udtcdqyO9bPSbyH3mjHbmBY5fzfzHXBWHvW914CzjXbaS0kyaYAeIHbB6KS7KSxKfgVbhwb3xJZL1AsFGdBXJKwqSe3WKqrGHv4Ww8iPfeRAL3OpmH4trwy8gCyfCFnoxwRj9b32VblrBdpN4gM0FOfPHuCB)gSeTn8CL3Mm40t0NaLaxAf4vW58WNS8hZjmwYJ9rCSIB73GLOTHNBT9FwWCcJL8yFehR42(nyjAB458y)hD6yoHXsESpIJvCB)gSeTn8CE(ZhRTNfpyY5kCGkRdaEUsUaLjq)kYcJ3GdRG7RX5YAnPp2MJydrgMK8yFehtYoXnmPvGxbNhOmXc0I0qQT5uEBYGtprFcucCPvGxbNZJTy7aLjQT5sEBYGT8)pkcmSY7hzXjyKLifchD681BtM(E(z5pkcmScLbaqEWahwHWrNoF9GjNRqzaaKhmWHvYfOmb6hD681dMCUchOY6aGNRKlqzc0pl)XCcJL8yFehR42(nyjAB45KStNoF9GjNR42(nyjAB45k5cuMa9ZY)W4TnjbbC12CKiaD6EBY03JLW4TnjbbC12CKStNoFxKtGb7JOG2a5j3ta4eKiCjyGbbtNoF9GjNRWbQSoa45k5cuMa9RilmEdoScUVgNlR1K(ah2IhjTGyjUHjHIadRWHT4rsliw1kVrFyc93aErbjoqFo2A7)Ys2MfcO4trwy8gCyfCFnoxwRj9bSSatdqWj02fIFJSNKt2hIizNydrgMK8yFehtYErwy8gCyfCFnoxwRj9bSSatdqWj02fInezysYJ9rCmj7e3WKqrGHvO4uFgfcNfpyY5kmaHLaWjpxsWGvWUsUaLjq0PBaageG2PmGZgiJK8CjH56TDSAL3OpmHSBXaSjxCU66NCpbhsrwy8gCyfCFnoxwRj9XkplGMNtCdtclU33dwb3mMSPvEwanp3cwyIXBWL8(v4XUIGz5XaPEJSxKvKfgVbhwbOXOjHnHe2JfJSpcXnmjueyyvUeRNaWjpxs0AgKcHRilmEdoScqJrtcBI1K(aJCW9keZ6tsgiswnlpgOISW4n4WkangnjSjwt6Jxa4G7viM1NKmqKSAwEmqe3WKqrGHvVaWLPVemyFviCwWCcJL8yFehR88nW5jt4eICl81dMCUIHCXM6dZ1B4n4uYfOmbYICY(qeHYwcyHVOiWWkdtI1eyVVhfcxrwy8gCyfGgJMe2eRj9rUeRNaWjpxs0AgeXnmj5K9HicXhcybc4QT5uR8g9H5XQkcA5VbayqaANY7hzXjyKLi1kVrFyEiLTkcsN(ICcmyFeLjCHijzq2g8ZckcmSYWKynb277rH9WKHq2TWxueyyvWjzpXTcu4GfNmByRVhfcNf(IIadRqzaaedb7keol8ffbgwHIt9zuiCw(BaageG2PmGZgiJK8CjH56TDSAL3OpmpzRIG0PZxdWMCX5QRFY9eCi)S8NVgGn5IZvNywadSq0PBaageG2PcOGZBBsctl2x1kVrFyEirq60HaUkGcoVTjjmTyFtqXB8iQvEJ(W8qy(vKfgVbhwbOXOjHnXAsF8caxM(sWG9L4gMKCY(qeH4dbSabC12CQvEJ(W8yvfbT83aamiaTt59JS4emYsKAL3OpmpKSQIG0PViNad2hrzcxissgKTb)SGIadRmmjwtG9(EuypmziKDl8ffbgwfCs2tCRafoyXjZg267rHWzHVOiWWkugaaXqWUcHZYF(IIadRqXP(mkeo60naBYfNRoXSagyHS4btoxHdBXJKwqSk5cuMazbfbgwHIt9zuR8g9H5jB)z5VbayqaANYaoBGmsYZLeMR32XQvEJ(W8KTkcsNoFnaBYfNRU(j3tWH8ZYF(Aa2KloxDIzbmWcrNUbayqaANkGcoVTjjmTyFvR8g9H5HebPthc4Qak482MKW0I9nbfVXJOw5n6dZdH5Nf4(j3tR8g9H5HWuKvKfgVbhwHfhHJed5In1hMR3WBWrCdtYaSjxCU6eZcyGfYcMtySKh7J4yLNVbopzcNqw1Ib8IcsCG(CmHiOf(6TjtFpw4lkcmScfN6ZOq4kYcJ3GdRWIJWznPp4aawAfmazncXWGnDs2Ds2lYcJ3GdRWIJWznPpWHT4rsliwIBysEWKZvWYgSe8k33tKsUaLjqwmaadcq7uWYgSe8k33tKcHZcFrrGHv4Ww8iPfeRcHZIb8IcsCG(Cmp2TabC1gzeL3Mm99y5peWvmKl2uFyUEdVbNYBtM(EOtNVEWKZvmKl2uFyUEdVbNsUaLjq)kYiCcVMW4n4WkS4iCwt6doaGLwbdqwJqCdtYdMCUcLbaqEWahwjxGYeilOiWWkugaa5bdCyfeG2z5VCY(qK18rrWSiNSpePw5roR)BvcKfueyyLHjXAcS33JcH73pc93UDc(jY5twqrGHv9zI9cVbxktFpjaCYZLuwf5EyIcH7NLW4TnjH6jF7NhzXKiqrwy8gCyfwCeoRj9bTODIXIH0))2TtWproFYckcmSQptSx4n4sz67jbGtEUKYQi3dtuiC)(0F5K9HiLbzx5CR5JIGzrozFisTYJCw)3QeilOiWWkdtI1eyVVhfc3VF)(qozFisTYJCe3WK8GjNRqzaaKhmWHvYfOmbYckcmScLbaqEWahwbbODwcJ32KeQN8TFEKftIafzHXBWHvyXr4SM0hMGXsHXBWLyn2j(IxHekdaG8GbomXnmjpyY5kugaa5bdCyLCbktGSGIadRqzaaKhmWHvqaANL)gWlkiXb6ZXeIG0PJ5egl5X(iow55BGZtMWjz)xrwy8gCyfwCeoRj9HjySuy8gCjwJDIV4vizaageG2vKfgVbhwHfhHZAsFycglfgVbxI1yN4lEfsW914Czjg7BBCs2jUHjzaVOGehOphZdFS8hfbgwHYaaipyGdRq4OtNVEWKZvOmaaYdg4Wk5cuMa9RiRilmEdoSc7sW8CsCaalTcgGSgHyyWMoj7oj7fzHXBWHvyxcMNBnPpW0AojzcN4gMekcmScfN6ZOq4SG5egl5X(iowHP1CsYeop8XYICcmyFef8k33teACqfzeEnFxKrQ5ebcxZcqEYzevdbjGvyna4AAhxdtUhpVMWRjQ5TV(f5Tghudgz5cmUgC(kq4AG4KISW4n4WkSlbZZTM0hBKri2qKHjjp2hXXKStCdt6peWvBKruCVimV5yTSeYUIG0PVc8k48aLj)SaTinKAJmIYBtgC6j6tGsGlTc8k4CEiNo9)CYIBSlNNEryEZXAz5bc4QnYikUxeM3CSwwlOiWWkuCQpJcHZcMtySKh7J4yLNVbopzcNq8XIbytU4C1jMfWal0p60rrGHvO4uFg1kVrFyczVilmEdoSc7sW8CRj9bd5In1hMR3WBWrCdtcZjmwYJ9rCSYZ3aNNmHti(yzf4vW5bktSaTinKIHCXM6dZ1B4n4uEBYGtprFcucCPvGxbNZdbT83aErbjoqFoMKvPthc4kgYfBQpmxVH3GtTYB0hMqeKoD(cbCfd5In1hMR3WBWP82KPVNFfzeEnFTiEWQHIf48AACnOI7YwJNhxnyxcMNxdv(kq1eEn8Pgp2hXXfzHXBWHvyxcMNBnPpqxepyjmlW5e3WKWCcJL8yFehRqxepyjmlW58qErwy8gCyf2LG55wt6doaGLwbdqwJqmmytNKDNK9ISW4n4WkSlbZZTM0h48vGiUHjzaVOGehOphtiRAbZjmwYJ9rCSYZ3aNNmHticwKvKfgVbhwHgS4mcjmYb3RqCdtcfbgwjgwZHLegWIvbbODwqrGHvIH1CyjXqUyvqaANL)RaVcopqzcD6)dJ32KKCYBlyESBjmEBtsqaxHro4EfcfgVTjj5K3wW)(vKfgVbhwHgS4mI1K(a7XIr2hH4gMekcmSsmSMdljmGfRAL3Opmp2jG1Ma7jVFf60rrGHvIH1CyjXqUyvR8g9H5XobS2eyp59RuKfgVbhwHgS4mI1K(a7Xc3RqCdtcfbgwjgwZHLed5IvTYB0hMhtG9K3VcD6OiWWkXWAoSKWawSkiaTZcgWInjgwZHfEiaD6OiWWkXWAoSKWawSkiaTZcd5InjgwZHLpfgVbNI2gEUQVemRFYDczVilmEdoScnyXzeRj9bTn8CIBysOiWWkXWAoSKWawSQvEJ(W8ycSN8(vOthfbgwjgwZHLed5IvbbODwyixSjXWAoS8PW4n4u02WZv9LGz9tUZdb0U21Aa]] )


end
