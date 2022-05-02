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


    spec:RegisterPack( "Feral", 20220428, [[dWe0lcqiIk9ieuUeLcytuIpPQOgLQkNsvvRsi4vuknleYTuvKDrYVuvyyQk1XOuTmevpJOIPrPORHaTnHi9neu14qqfNdbiSoeaZdb5EiY(ikoicqTqvL8qHiMiLcvxebiQnkekFKsHYjrqLwjc1mPui3ebiTtIs)uiedfbiYsra5PizQev9vkfOXsPG2lP(RGbRYHfTyi9ykMmixg1Mb1NvfJwOoTuRwiKETqA2eUTQ0Uv63adNihxiuTCfphQPt11Hy7usFhPmEHOopIY6ra18rQ2VK121YRPGsN1Ys(3Kt(3e8B7kYTB)BcgPAkNmjwtjLMO5dRP28L1urmEsHMskjtasiT8AkmazmSMk2Djmb4JpEApgbvzaVFG7xer6nyntc7FG7xZhAkuKw4eURgvtbLoRLL8VjN8Vj432vKB3(3eKGAQeXJbJMIQFJenvCdbXRgvtbXyJMkIXtkQZgFqAOIycyPPf1roHdr1r(3KtErCrCKeN7dJjafXFQoObPHuaAcACALdM0jzVotmBIIRZb1bninKcqtqJtRCWKUQi(t1fjG1kpEDFjFDsaGimmgGmgUohuhTS964ilnmg3GTUFrM8)QI4pvhbmeuD968misEJk46IycghBMe2RRHRJmasDXPvUUf4X9(uhlWCDoOoiGQi(t1zJd2p71fdeq1fjG1kikxhmyQJa1s1HScgJRJmaYNfI6gofcYQJa1sQI4pvhfIKey86GBHGN6iq8ZaO5X1rlUfCDsaGO3N6GbtDFjaaipfGfRkI)uD2GGjADGTocyOuYBRCDu0Y5TomIKeyCLMs0yhRLxtHkaaipfGfRLxlRDT8AkEtubdP)stLgVbRMAYOSMYmTZtNAQF1j3682eT3N6OtVUF1zxrEDrOojEWn251dVicVLenp1jdP6GaUAYOSs6fr4TKO5PU)1rNED)QlnEBLdOEWN(5HhCDKQJ86Su3WWdJJtubx3)6(xNL6qrGHvOEyYOSccqB1ugYmco458WowlRDTRLLCT8AkEtubdP)stLgVbRMsGS5e6fl1t6ny1uMPDE6utnm8W44evW1zPoueyyfQhEbGfUhwbbOTAkdzgbh8CEyhRL1U21YkhT8AkEtubdP)stLgVbRMYJNehhmPRPmt780PMAy4HXXjQGRZsDOiWWkup4XtIJvqaABDwQdAqAiLhpjooysx5Tjko8K9YqbWgggEyCCDYu3V6SzD2whwIfIGNZd7yLhpjooysVUiuNnR7FDFu3V6SxNT19MyNhYcwtbcx3)6(uDgWcH0UYtSZbyWeqfaaKI3evWqAkdzgbh8CEyhRL1U21YAtT8AkEtubdP)stzM25PtnfkcmSc1dOdINIawK4yfeG2QPsJ3GvtHoiEkcyrIJ1UwwcQLxtXBIkyi9xAkZ0opDQPqrGHvOEatRLyfeG2wNL6WsSqe8CEyhRW0AjoysVozQZUMknEdwnfMwlXbt6AxlBKQLxtXBIkyi9xAkZ0opDQPqrGHvOEahpmKccqB1uPXBWQPWXddPDTSeET8AkEtubdP)stzM25PtnfkcmSc1dyATeRGa0wnvA8gSAkmTwIdM01UwwchT8AkEtubdP)stzM25PtnfkcmSc1dE8K4yfeG2QPsJ3Gvt5XtIJdM01U21uW924yE0YRL1UwEnfVjQGH0FPPGbty5i7AzTRPsJ3GvtjbaIWWyaYyyTRLLCT8AkEtubdP)stzM25PtnfkcmScNwZhomGCud)M9IRJq1jhnvA8gSAkCAnF4WaYr7AzLJwEnfVjQGH0FPPmt780PM6xDqdsdPKM(nfbAt6XkVnrXHNSxgka2WWWdJJRtM6KtDrOUF1HLyHi458Wowjn9Bkc0M0JRZ26Sx3)6SuhwIfIGNZd7yL00VPiqBspUozQZED)RJo96WsSqe8CEyhRKM(nfbAt6X1jtD)Qto1zBD2Rlc15PGxxHtuECaWJv8MOcgQU)AQ04ny1ust)MIaTj9yTRL1MA51u8MOcgs)LMknEdwn10sAkZ0opDQPggEyCCIk46Suh0G0qQPLuEBIIdpzVmuaSHHHhghxNm1znNorfSAAPG3MO46Su3V6(vhkcmSY7hEWbyKHmfIuD0PxNCRZBt0EFQ7FDwQ7xDOiWWkubaa5PaSyfIuD0PxNCRZtbVUcvaaqEkalwXBIkyO6(xhD61j368uWRRWjkpoa4XkEtubdv3)6Su3V6WsSqe8CEyhRKM(nfbAt6X1rQo71rNEDYTopf86kPPFtrG2KESI3evWq19Vol19RU04TvoabC10s1rQUVRJo9682eT3N6SuxA82khGaUAAP6ivN96OtVo5w3GSmmyEyf0KipXEaahGywkadmiyfVjQGHQJo96KBDEk41v4eLhha8yfVjQGHQ7VMYqMrWbpNh2XAzTRDTSeulVMI3evWq6V0uMPDE6utHIadRWP18Hddih1WVzV46iuD)QZaErbbjqVoUoBRZED)Rlc1fP1fH6(wjhnvA8gSAkCAnF4WaYr7AzJuT8AkEtubdP)st9MroWlppKPL1UMknEdwnfmpatdqWb02znLHmJGdEopSJ1YAx7Azj8A51u8MOcgs)LMknEdwnfmpatdqWb02znLzANNo1uOiWWkuCOxJcrQol15PGxxHbiIaao4XCagmm2v8MOcgQo60RZaaciaTvzaRvquo4XCal1t7y1WVzV46iuD2RZsDgGvEZ1vB)e7b4K1ugYmco458WowlRDTRLLWrlVMI3evWq6V0uMPDE6utHz379bRGBHGNWWpdGMhxNL6WSGnEd2G3VCDYuNDfbRlc19yGuVzK1uPXBWQPg(za08yTRDnfAkY1WA51YAxlVMI3evWq6V0uMPDE6utHIadRyJOLWCade5OGa026SuhkcmSInIwcZbbYMJccqBRZsD)QBy4HXXjQGRJo96(vxA82kh4LFBgxNm1zVol1LgVTYbiGRWilCpCDeQU04TvoWl)2mUU)19xtLgVbRMcJSW9WAxll5A51u8MOcgs)LMYmTZtNAkueyyfBeTeMdyGih1WVzV46KPo7FxNT1zsSh8(LRJo96qrGHvSr0syoiq2Cud)M9IRtM6S)DD2wNjXEW7xwtLgVbRMc75GrMhw7AzLJwEnfVjQGH0FPPmt780PMcfbgwXgrlH5GazZrn8B2lUozQZKyp49lxhD61HIadRyJOLWCade5OGa026SuhgiYjWgrlH56KPUVRJo96qrGHvSr0syoGbICuqaABDwQtGS5eyJOLWCDFQU04nyv0M0Jv9gGf9tSxhHQZUMknEdwnf2ZbUhw7AzTPwEnfVjQGH0FPPmt780PMcfbgwXgrlH5agiYrn8B2lUozQZKyp49lxhD61HIadRyJOLWCqGS5OGa026SuNazZjWgrlH56(uDPXBWQOnPhR6nal6NyVozQ7BnvA8gSAkAt6XAx7Akm7isA51YAxlVMI3evWq6V0uMPDE6utzaw5nxxTSzacWavNL6WsSqe8CEyhR84jXXbt61rO6SzDwQZaErbbjqVoUocvhbRZsDYToVnr79Pol1j36qrGHvO4qVgfIKMknEdwnLazZj0lwQN0BWQDTSKRLxtXBIkyi9xAkyWewoYUww7AQ04ny1usaGimmgGmgw7AzLJwEnfVjQGH0FPPmt780PMYtbVUcMNueGhEjWKP4nrfmuDwQZaaciaTvbZtkcWdVeyYuis1zPo5whkcmScNwZhomGCuis1zPod4ffeKa9646KPo71zPoiGRMmkR82eT3N6Su3V6GaUsGS5e6fl1t6nyvEBI27tD0PxNCRZtbVUsGS5e6fl1t6nyv8MOcgQU)AQ04ny1u40A(WHbKJ21YAtT8AkEtubdP)stHzJM6xD)QZUDcw3NQJC5uxeQdfbgw1RjNn9gSHO9(eaWbpMdruK9rWkeP6(x3NQ7xD8YZdzkdYm861zBDYrrW6IqD8YZdzQHF4ToBR7xD2876IqDOiWWkJGZXKyV3hfIuD)R7FD)R7J64LNhYud)WRMknEdwnfTSDnLzANNo1uEk41vOcaaYtbyXkEtubdvNL6qrGHvOcaaYtbyXkiaTTol1LgVTYbup4t)8WdUos19T21YsqT8AkEtubdP)stzM25PtnLNcEDfQaaG8uawSI3evWq1zPoueyyfQaaG8uawSccqBRZsD)QZaErbbjqVoUocvhbRJo96WsSqe8CEyhR84jXXbt61rQo719xtLgVbRMYKcrinEd2GOXUMs0ypS5lRPqfaaKNcWI1Uw2ivlVMI3evWq6V0uPXBWQPmPqesJ3GniASRPen2dB(YAkdaiGa0wTRLLWRLxtXBIkyi9xAkZ0opDQPmGxuqqc0RJRtM6KtDwQ7xDOiWWkubaa5PaSyfIuD0PxNCRZtbVUcvaaqEkalwXBIkyO6(RPW(0gxlRDnvA8gSAktkeH04nydIg7AkrJ9WMVSMcU3ghZJ21UMcIHteHRLxlRDT8AkEtubdP)stzM25PtnfkcmS6fa2O9gGbZRcrQol1j36GgKgsbOjOXPvoysxtH9PnUww7AQ04ny1udYgsJ3GniASRPen2dB(YAk0uKRH1UwwY1YRP4nrfmK(lnLzANNo1uqdsdPa0e040khmPRPW(0gxlRDnvA8gSAktkeH04nydIg7AkrJ9WMVSMcqtqJtRS21YkhT8AkEtubdP)stbXyZ0sEdwnfbKganrD0I5LTYtDsamUrfSMknEdwnL0aOj0UwwBQLxtXBIkyi9xAkZ0opDQPqrGHvM0dWG5vbbOTAQ04ny1uE)WdoaJmKPDTSeulVMI3evWq6V0uMPDE6utHIadRmPhGbZRccqB1uPXBWQPmPhGbZR21YgPA51u8MOcgs)LMcIXMPL8gSAQiYY1HJbEDyNtHhRPsJ3GvtniBinEd2GOXUMc7tBCTS21uMPDE6utHIadRWXjeG2llGuis1rNEDOiWWkPbqtOqK0uIg7HnFznf25u4XAxllHxlVMknEdwnfokIqeqtCSMI3evWq6V0UwwchT8AkEtubdP)stzM25PtnvA82khGaUAAP6iv33AkSpTX1YAxtLgVbRMYKcrinEd2GOXUMs0ypS5lRPWSJiPDTSeqOLxtXBIkyi9xAQ04ny1uMuicPXBWgen21uIg7HnFznLbaeqaAR21YA)BT8AkEtubdP)stLgVbRMAAjnfeJntl5ny1uYYMbiadebOUijXEDYPoWuNnRZaErb1jb61RBAjCDGToCVpcUopNh2RdG44gIRdaxhkpyEIwhyQdcz69PouEW8eTUgUoyEsrDWdVeyYQRX1HivxeHavxkjjiRUSocAKQJa1s1rlM36KpIvxJRdrQUCHQJwle1HbGTo4uiQdadR0uMPDE6utzaw5nxxTSzacWavNL6(vNCRZtbVUcvaaqEkalwXBIkyO6OtVoueyyfQaaG8uawScrQU)1zPoSelebpNh2XkpEsCCWKEDKQZEDwQ7xDgWlkiib61X1jtDKxNL6ggEyCCIk46Suh0G0qQPLuEBIIdpzVmuaSHHHhghxNm1znNorfSAAPG3MO46Su3V6KBDOiWWkuCOxJcrQo60RZaaciaTvHId9Auis1rNED)QdfbgwHId9Auis1zPodaiGa0wfmpPiap8sGjtHiv3)6(xhD61zaVOGGeOxhxhP6iyDwQdfbgw59dp4amYqMcrQol1HIadR8(HhCagzitn8B2lUocvNnRZsDqdsdPMws5Tjko8K9YqbWgggEyCCDYuhbR7V21YA3UwEnfVjQGH0FPPmt780PMYaErbbjqVoUoziv3V6iyDFQoR50jQGvWaKXifqBNR7VMc7tBCTS21uPXBWQPgKnKgVbBq0yxtjASh28L1uW924yE0Uww7KRLxtXBIkyi9xAkZ0opDQPGgKgsjn9Bkc0M0JvEBIIdpzVmuaSHHHhghxNmKQJ8VRZsDgWlkiib61X1jdP6ixtLgVbRMsA63ueOnPhRPe9YbdKMIGAxlRD5OLxtXBIkyi9xAkigBMwYBWQPiGIi8(tpgO6WoNcpwtLgVbRMYKcrinEd2GOXUMc7tBCTS21uMPDE6utHIadRqXHEnkejnLOXEyZxwtHDofES21YA3MA51u8MOcgs)LMYmTZtNAkm7EVpyfCle8eg(za0846SuNNcEDfQaaG8uawSI3evWq1zPoueyyfQaaG8uawSccqBRZsDPXBRCa1d(0pp8GRJuDFxNL6SRiyDrOUhdK6nJCDeQUF19RUF1z3obR7t1rUCQlc1HIadR61KZMEd2q0EFca4GhZHikY(iyfIuD)R7t19RoE55HmLbzgE96STo5OiyDrOoE55Hm1Wp8wNT19RoB(DDrOoueyyLrW5ysS37JcrQU)19VU)19rD8YZdzQHF4TU)AQ04ny1ud)maAES21YANGA51u8MOcgs)LMcIXMPL8gSAk5J56EbyVooYs8IBRCDFjFDgYmcUUFYhpmoUoQ4HHQJIwlX1zayVo72jyD8YZdzev3BgLRdJmCD046m5w3BgLRZJtVUERZM19iaOPa)xtHzJM6xD)QZUDcw3NQJC5uxeQdfbgw1RjNn9gSHO9(eaWbpMdruK9rWkeP6(x3NQ7xD8YZdzkdYm861zBDYrrW6IqD8YZdzQHF4ToBR7xD2876IqDOiWWkJGZXKyV3hfIuD)R7FD)R7J64LNhYud)WRMknEdwnfTSDnLzANNo1uEk41vOcaaYtbyXkEtubdvNL6qrGHvOcaaYtbyXkiaTTol1LgVTYbup4t)8WdUos19T21YAps1YRP4nrfmK(lnLzANNo1uEk41vOcaaYtbyXkEtubdvNL6qrGHvOcaaYtbyXkiaTvtLgVbRMAq2qA8gSbrJDnLOXEyZxwtHkaaipfGfRDTS2j8A51u8MOcgs)LMknEdwnfmpatdqWb02znLzANNo1uOiWWQuIJCqAyO0bdoyM0AVpkejnLHmJGdEopSJ1YAx7AzTt4OLxtXBIkyi9xAkyWewoYUww7AQ04ny1usaGimmgGmgw7AzTtaHwEnfVjQGH0FPPsJ3GvtnzuwtzM25Ptn1V6ggEyCCIk46OtVojEWn251dVicVLenp1jtDqaxnzuwj9Ii8ws08u3)6Suh0G0qQjJYkVnrXHNSxgka2WWWdJJRtM6WsSqe8CEyhRW0AjoysVUiuh519P6ixtziZi4GNZd7yTS21UwwY)wlVMI3evWq6V0uPXBWQPeiBoHEXs9KEdwnLzANNo1u)QBy4HXXjQGRJo96K4b3yNxp8Ii8ws08uNm1bbCLazZj0lwQN0BWQKEreEljAEQ7FDwQdAqAiLazZj0lwQN0BWQ82efhEYEzOaydddpmoUozQdlXcrWZ5HDSctRL4Gj96IqDKx3NQJCnLHmJGdEopSJ1YAx7Azj3UwEnfVjQGH0FPPGbty5i7AzTRPsJ3GvtjbaIWWyaYyyTRLLCY1YRP4nrfmK(lnvA8gSAkpEsCCWKUMYmTZtNAQHHhghNOcUol1bninKYJNehhmPR82efhEYEzOaydddpmoUozQ7xD2SoBRdlXcrWZ5HDSYJNehhmPxxeQZM19VUpQ7xD2RZ26EtSZdzbRPaHR7FDFQodyHqAx5j25amycOcaasXBIkyO6(uDgGvEZ1vlBgGamq1zPUF1j36qrGHvO4qVgfIuD0PxhwIfIGNZd7yLhpjooysVozQZED)1ugYmco458WowlRDTRLLC5OLxtXBIkyi9xAkyWewoYUww7AQ04ny1usaGimmgGmgw7Azj3MA51u8MOcgs)LMYmTZtNAQF1nzdfyR86QeccR6TozQ7xD2RZ26EZihmX58W46(uDM4CEyCaEsJ3Gnf19VUiu3WM4CE4G3VCD)RZsD)QdlXcrWZ5HDScDq8ueWIehxxeQlnEdwf6G4PiGfjowbLV5dx3h1LgVbRcDq8ueWIehRmaSx3)6KPUF1LgVbRchpmKckFZhUUpQlnEdwfoEyiLbG96(RPsJ3GvtHoiEkcyrIJ1UwwYjOwEnfVjQGH0FPPmt780PMclXcrWZ5HDSctRL4Gj96KPo71zBDOiWWkuCOxJcrQUiuh5AQ04ny1uyATehmPRDTSKhPA51u8MOcgs)LMYmTZtNAkSelebpNh2XkpEsCCWKEDYuNC0uPXBWQP84jXXbt6Axll5eET8AkEtubdP)stzM25PtnfkcmSYi4Cmj279rHivNL6(vhkcmScJabXBiFrrWXkiaTTol1HIadRWXjeG2llGuqaABD0PxhkcmScfh61OqKQ7VMknEdwnfoEyiTRLLCchT8AkEtubdP)stLgVbRMYKcrinEd2GOXUMs0ypS5lRPGBHGhTRDnL0WgWlA6A51YAxlVMI3evWq6V0uajnfMDnvA8gSAkR50jQG1uwtbcRP(wtznNWMVSMcgGmgPaA7S21YsUwEnfVjQGH0FPPasAkm7AQ04ny1uwZPtubRPSMcewtzxtbXyZ0sEdwnfv8Wq1rQUVjQozb7NWBkHJbEDeOmkxhP6StuDuBkHJbEDeOmkxhP6iNO6SreU1rQo5quDu0AjUos1ztnL1CcB(YAk4wi4r7AzLJwEnfVjQGH0FPPasAkm7AQ04ny1uwZPtubRPSMcewtr41uwZjS5lRPMwk4Tjkw7AzTPwEnvA8gSAQO9cnmual1t7ynfVjQGH0FPDTSeulVMknEdwnfkWDbdfGfjzmeTEFcoiY9QP4nrfmK(lTRLns1YRP4nrfmK(lnLzANNo1uyaIaTxiLec2reCGhejVbRI3evWq1rNEDyaIaTxiLvGi9wWbmqyLxxXBIkyinvA8gSAkybJJntc7AxllHxlVMI3evWq6V0uMPDE6utHIadREbGnAVbyW8QGa0wnvA8gSAkPbqtODTSeoA51u8MOcgs)LMYmTZtNAkueyy1laSr7nadMxfeG2QPsJ3GvtzspadMxTRLLacT8AkEtubdP)stbK0uy21uPXBWQPSMtNOcwtznfiSM6BnfeJntl5ny1ursAI56aW1LMiospmuD(WjgzyCDqagx3c86Wm)wNdQJgyIwhzSxxUq1fN46CqDOCDyMxnL1CcB(YAkWgqWCWNEJYU21YA)BT8AkEtubdP)stbK0ujeKMknEdwnL1C6evWAkRPaH1u21uMPDE6ut9RoF6nk7k3UkoXbemhqrGHRZsD(0Bu2vUDLbaeqaARcczsVbBD)RJo968P3OSRC7QgR6fBgeprfCiIJKRJ8gGyRTH1uwZjS5lRPaBabZbF6nk7AxlRD7A51u8MOcgs)LMciPPsiinvA8gSAkR50jQG1uwtbcRPixtzM25Ptn1V68P3OSRCYvXjoGG5akcmCDwQZNEJYUYjxzaabeG2QGqM0BWw3)6OtVoF6nk7kNCvJv9IndINOcoeXrY1rEdqS12WAkR5e28L1uGnGG5Gp9gLDTRL1o5A51u8MOcgs)LMciPPWSRPsJ3GvtznNorfSMYAkqynvKAxtznNWMVSM6nJCWNEJYEigiG0U21uWTqWJwETS21YRP4nrfmK(lnvA8gSAQjJYAkZ0opDQPSMtNOcwb3cbp1rQo71zPUHHhghNOcUol1bbC1KrzL0lIWBjrZtDeIuD2vKxxeQtIhCJDE9WlIWBjrZJMYqMrWbpNh2XAzTRDTSKRLxtXBIkyi9xAkZ0opDQPSMtNOcwb3cbp1rQoY1uPXBWQPMmkRDTSYrlVMI3evWq6V0uMPDE6utznNorfScUfcEQJuDYrtLgVbRMsGS5e6fl1t6ny1UwwBQLxtXBIkyi9xAkZ0opDQPSMtNOcwb3cbp1rQoBQPsJ3GvtHP1sCWKU21YsqT8AkEtubdP)stzM25PtnfkcmScJabXBiFrrWXkiaTvtLgVbRMchpmK21YgPA51u8MOcgs)LMYmTZtNAkm7EVpyfCle8eg(za0846SuhMfSXBWg8(LRtM6SRiyDrOUhdK6nJSMknEdwn1WpdGMhRDTRPWoNcpwlVww7A51u8MOcgs)LMcgmHLJSRL1UMknEdwnLeaicdJbiJH1UwwY1YRP4nrfmK(lnLzANNo1uOiWWkuCOxJcrQol1HLyHi458WowHP1sCWKEDYuNCQZsDdYYWG5HvWdVeyYqZfsXBIkyinvA8gSAkmTwIdM01Uww5OLxtXBIkyi9xAQ04ny1utgL1ugYmco458WowlRDnLzANNo1u)Qdc4QjJYkPxeH3sIMN6iuD2veSo60RBy4HXXjQGR7FDwQdAqAi1KrzL3MO4Wt2ldfaByy4HXX1jtDKxhD619RojEWn251dVicVLenp1jtDqaxnzuwj9Ii8ws08uNL6qrGHvO4qVgfIuDwQdlXcrWZ5HDSYJNehhmPxhHQto1zPodWkV56QLndqagO6(xhD61HIadRqXHEnQHFZEX1rO6SRPGySzAjVbRMIaLr56wMHW1naKNybz1rWVTbQdaxx746e8(4X1LEDzDV92ViV15G6WiJuIX1HJhgcxhKeRDTS2ulVMI3evWq6V0uMPDE6utHLyHi458Wow5XtIJdM0RJq1jN6Su3WWdJJtubxNL6GgKgsjq2Cc9IL6j9gSkVnrXHNSxgka2WWWdJJRtM6iyDwQ7xDgWlkiib61X1rQoBwhD61bbCLazZj0lwQN0BWQg(n7fxhHQJG1rNEDYToiGReiBoHEXs9KEdwL3MO9(u3FnvA8gSAkbYMtOxSupP3Gv7AzjOwEnfVjQGH0FPPsJ3GvtHoiEkcyrIJ1uqm2mTK3Gvt91G4POokrIJRRX1HYUZtDECU1HDofECDuXddvx61jN68CEyhRPmt780PMclXcrWZ5HDScDq8ueWIehxNm1rU21YgPA51u8MOcgs)LMcgmHLJSRL1UMknEdwnLeaicdJbiJH1UwwcVwEnfVjQGH0FPPmt780PMYaErbbjqVoUocvNnRZsDyjwicEopSJvE8K44Gj96iuDeutLgVbRMchpmK21UMYaaciaTvlVww7A51u8MOcgs)LMknEdwnvcLsEBLdyA58QPmt780PM6xD)QtU1bbCvcLsEBLdyA58gGY38HvEBI27tD0PxheWvjuk5TvoGPLZBakFZhwn8B2lUocvh519Vol19RoiGRsOuYBRCatlN3au(MpSc7PjADeQo5uhD61j36GaUkHsjVTYbmTCEdXCkuypnrRtM6Sx3)6SuNCRdfbgwLqPK3w5aMwoVHyofHEdWI(j2vis1zPo5whkcmSkHsjVTYbmTCEdq5B(WHEdWI(j2vis19Vol1558WUY7xo4GauZ1jtDeSo60RlnEBLd8YVnJRtM6iVol1j36GaUkHsjVTYbmTCEdq5B(WkVnr79Pol1XlppKvhHQtoeSol1558WUY7xo4GauZ1jtDeutziZi4GNZd7yTS21UwwY1YRP4nrfmK(lnLzANNo1u)QddqeO9cPKqWoIGd8Gi5nyv8MOcgQo60RddqeO9cPSceP3coGbcR86kEtubdv3FnvVopdIKhAynfgGiq7fszfisVfCadew511u968misEOFFzOoDwtzxtLgVbRMcwW4yZKWUMQxNNbrYdpcaAk0u21Uww5OLxtXBIkyi9xAQ04ny1u(0Bu2TRPmt780PM6xD)QZaaciaTvzaRvquo4XCal1t7y1WVzV46iuDKxNL6(vhkcmScfh61OqKQJo96maGacqBvO4qVg1WVzV46KPo7Fx3)6(xhD61HcW46SuhC)e7HHFZEX1rO6i)76(xhD619RodaiGa0wLbSwbr5GhZbSupTJvd)M9IR7t1rEDYuN1C6evWQ3mYbF6nk7HyGaQU)1rNEDwZPtubRaBabZbF6nk71rQUVRJo96(vN1C6evWkWgqWCWNEJYEDKQJ86Su3V6maGacqBvgWAfeLdEmhWs90own8B2lUozQJCYRJo96qbyCDwQdUFI9WWVzV46iuDK)DD0PxNp9gLDLtUYaaciaTvn8B2lUozQJ8VR7FD)1uybWXAkF6nk721UwwBQLxtXBIkyi9xAQ04ny1u(0Bu2jxtzM25Ptn1V6(vNbaeqaARYawRGOCWJ5awQN2XQHFZEX1rO6iVol19Roueyyfko0RrHivhD61zaabeG2QqXHEnQHFZEX1jtD2)UU)1zPUF15tVrzx52vgaqabOTQHFZEX1jdP6iVo60RZAoDIkyfydiyo4tVrzVos1rED)R7FD0PxhkaJRZsDW9tShg(n7fxhHQJ8VR7FD0Px3V6(vNbaeqaARYawRGOCWJ5awQN2XQHFZEX19P6iVoBRls)UUiu3V6(vNp9gLDLBxzaabeG2Qg(n7fxhHQZaaciaTvzaRvquo4XCal1t7y1WVzV46(uDKx3)6Su3V6SMtNOcwb2acMd(0Bu2RJuD2RJo96SMtNOcwb2acMd(0Bu2Rtgs1jN6(x3)6(xNm1znNorfS6nJCWNEJYEigiGQ7FD0PxN1C6evWkWgqWCWNEJYEDKQ776OtVUF1znNorfScSbemh8P3OSxhP6SxNL6(vNbaeqaARYawRGOCWJ5awQN2XQHFZEX1jtDKtED0PxhkaJRZsDW9tShg(n7fxhHQJ8VRJo968P3OSRC7kdaiGa0w1WVzV46KPoY)UU)19xtHfahRP8P3OStU21YsqT8AkEtubdP)stbXyZ0sEdwnvKKyVo57hE(mUUigYqwDOmmy46(bM663xgQtxqwDjSZZ)6mj279PUigpPOUi2WlbMS6A46(IhmprRRX1jBer(6aBDgaqabOTknfMS1OPG5jfb4HxcmzAkZ0opDQPmaGacqBvO4qVgfIKMknEdwnL3p8GdWidzAxlBKQLxtXBIkyi9xAQ04ny1uW8KIa8WlbMmnLzANNo1ugWlkiib61X1rO6KtDwQZZ5HDL3VCWbbOMRtM6i81zPUF1HIadRWP18HddihfIuD0PxNCRZtbVUcNwZhomGCu8MOcgQU)1zPUF1j36maGacqBvE)WdoaJmKPqKQJo96maGacqBvO4qVgfIuD)RJo96qbyCDwQdUFI9WWVzV46iuDeo1zPo4(j2dd)M9IRtM6ixtziZi4GNZd7yTS21UwwcVwEnfVjQGH0FPPsJ3GvtHYdMNOAkigBMwYBWQPKpIyJhria1jlZq15G6WKTM6O1ECD0ApUUjTYlabxh8WlbMS6OfZBD046gKTo4HxcmzO5cruDGPU0fCI96mXSjADnCDTJRJgy846AxtzM25PtnvA82khGaUAAP6KPUVRZsD)QZaaciaTvzaRvquo4XCal1t7yfIuD0PxNbaeqaARYawRGOCWJ5awQN2XQHFZEX1jtDYH86OtVouagxNL6G7Nypm8B2lUocvh5Fx3FTRLLWrlVMI3evWq6V0uMPDE6utLgVTYbiGRMwQozQ776Su3V6maGacqBvgWAfeLdEmhWs90owHivhD61HcW46SuhC)e7HHFZEX1rO6KZ319xtLgVbRMQxtoB6ny1Uwwci0YRP4nrfmK(lnvA8gSAkVF4bhGrgY0uqm2mTK3Gvtj)qwD5cv3c86OLyNRt(iwD8YZdzevhkIxxkWG6IOiyVoemxx71bdM6iW8eTUCHQRxtolwtzM25PtnfV88qMcIHBt71jtD2876OtVoueyyfko0RrHivhD619Ropf86kPHHshmkEtubdvNL6WXGXzShChQocvNCQ7FD0Px3V6sJ3w5aeWvtlvhP6(Uol1HIadRqfaaKNcWIvis19x7AzT)TwEnfVjQGH0FPPsJ3GvtHJtiaTxwaPPGySzAjVbRMIaA)e71HY1rBa7tDoOoemxh1llGQdS1rGYOCD9wNvEiRoR8qwDBBI56WTJKEdwmr1HI41zLhYQBYHfKPPmt780PMcfbgw59dp4amYqMcrQol1HIadRqXHEnkiaTTol1zaVOGGeOxhxhHQZM1zPoueyyfgbcI3q(IIGJvqaABDwQdc4QjJYkPxeH3sIMN6iuD2vrADwQJxEEiRozQZMFxNL6GgKgsnzuw5Tjko8K9YqbWgggEyCCDYuhwIfIGNZd7yfMwlXbt61fH6iVUpvh51zPopNh2vE)YbheGAUozQJGAxlRD7A51u8MOcgs)LMYmTZtNAkueyyL3p8GdWidzkeP6OtVoueyyfko0RrHiPPsJ3GvtHYdMNO9(ODTS2jxlVMI3evWq6V0uMPDE6utHIadRqXHEnkeP6OtVouagxNL6G7Nypm8B2lUocvNbaeqaARcfh61Og(n7fxhD61HcW46SuhC)e7HHFZEX1rO6iNGAQ04ny1usaVbR21YAxoA51u8MOcgs)LMYmTZtNAkueyyfko0RrHivhD61b3pXEy43SxCDeQoYTRPsJ3GvtnPvEbi4a8WlbMmTRL1Un1YRP4nrfmK(lnvA8gSAkdyTcIYbpMdyPEAhRPGySzAjVbRMs(iInEeHauxKeZMO19caB0ERlg40QlxO6WocmCDIokxNh3yIQlxO6EtYq56qz35Pod4fn96g(n7TUHXKTgnLzANNo1u)Qdc4QPLud)M9IRtM6SzDwQZaErbbjqVoUocvhbRZsD)Qdc4QjJYkVnr79Po60RdlXcrWZ5HDSYJNehhmPxNm1zVU)1zPoE55Hmfed3M2Rtgs1r(31zPodaiGa0wfko0Rrn8B2lUozQZ(319Vo60RdfGX1zPo4(j2dd)M9IRJq1rW6OtVUF1HIadRqXHEnkeP6SuhkcmScfh61Og(n7fxNm1zN86(RDTS2jOwEnfVjQGH0FPPsJ3GvtXVsaA8eqblKMcIXMPL8gSAkcOjzOCDEmpCD4yaIaQouUUxWW1zalu7nyX1b268yUodyHqAxtzM25PtnfkcmSY7hEWbyKHmfIuD0Px3V6mGfcPDfeZsHui4NoxdR4nrfmuD)1Uww7rQwEnfVjQGH0FPPGySzAjVbRMYgRTY1jnnyANS6CqDG9tiyUoACkbwn1MVSMkIcCK9H7zcqm27LmCWKcHMYmTZtNAkoIJ0ssmKkIcCK9H7zcqm27LmCWKcHMknEdwnvef4i7d3ZeGyS3lz4GjfcTRL1oHxlVMknEdwnfcMdTZVynfVjQGH0FPDTRPa0e040kRLxlRDT8AkEtubdP)stzM25PtnfkcmSkMZXda4GhZbATasHiPPsJ3GvtH9CWiZdRDTSKRLxtXBIkyi9xAQ04ny1uyKfUhwtj6LdginLnJWJbs7AzLJwEnfVjQGH0FPPsJ3Gvt9calCpSMYmTZtNAkueyy1laSr7nadMxfIuDwQdlXcrWZ5HDSYJNehhmPxhHQJ86SuNCRZtbVUsGS5e6fl1t6nyv8MOcgQol1XlppKvhHQls)Uol1j36qrGHvgbNJjXEVpkejnLOxoyG0u2mcpgiTRL1MA51u8MOcgs)LMYmTZtNAkE55HS6iuDY576SuheWvtlPg(n7fxNm1ztfbRZsD)QZaaciaTv59dp4amYqMA43SxCDYqQUivrW6OtVUbzzyW8Wkt6mzCWGmnqXBIkyO6(xNL6qrGHvgbNJjXEVpkSNMO1rO6SxNL6KBDOiWWQuIJCqAyO0bdoyM0AVpkeP6SuNCRdfbgwHkaaibc2vis1zPo5whkcmScfh61OqKQZsD)QZaaciaTvzaRvquo4XCal1t7y1WVzV46KPUivrW6OtVo5wNbyL3CD12pXEao56(xNL6(vNCRZaSYBUUAzZaeGbQo60RZaaciaTvLqPK3w5aMwoVQHFZEX1jdP6iyD0PxheWvjuk5TvoGPLZBakFZhwn8B2lUozQJWx3FnvA8gSAQyohpaGdEmhO1ciTRLLGA51u8MOcgs)LMYmTZtNAkE55HS6iuDY576SuheWvtlPg(n7fxNm1ztfbRZsD)QZaaciaTv59dp4amYqMA43SxCDYqQoBQiyD0Px3GSmmyEyLjDMmoyqMgO4nrfmuD)RZsDOiWWkJGZXKyV3hf2tt06iuD2RZsDYToueyyvkXroinmu6GbhmtAT3hfIuDwQtU1HIadRqfaaKab7keP6Su3V6KBDOiWWkuCOxJcrQo60RZaSYBUUAzZaeGbQol15PGxxHtR5dhgqokEtubdvNL6qrGHvO4qVg1WVzV46KPUiTU)1zPUF1zaabeG2QmG1kikh8yoGL6PDSA43SxCDYuxKQiyD0PxNCRZaSYBUUA7NypaNCD)RZsD)QtU1zaw5nxxTSzacWavhD61zaabeG2QsOuYBRCatlNx1WVzV46KHuDeSo60Rdc4QekL82khW0Y5naLV5dRg(n7fxNm1r4R7FDwQdUFI9WWVzV46KPocVMknEdwn1laSr7nadMxTRDTRPSYdUbRwwY)MCY)2MFt4OPOLZ27dwtzdsatGKLWvwBmcqD1jFmxx)kbgVoyWu3NH7TXX8856goIJ0ddvhg8Y1Lio4nDgQotCUpmwveBJ6LRZMeG6IeWALhNHQ7ZdYYWG5Hv2WpxNdQ7ZdYYWG5Hv2qfVjQGH(CD)Sh5)QI4IyBqcycKSeUYAJraQRo5J566xjW41bdM6(medNic)Z1nCehPhgQom4LRlrCWB6muDM4CFySQi2g1lxh5KtaQlsaRvECgQoQ(nsQdt26zKRZgOohuNncjRdQT24gS1bK4jDWu3Vp(x3p7r(VQi2g1lxh52KauxKawR84muDu9BKuhMS1ZixNnqDoOoBeswhuBTXnyRdiXt6GPUFF8VUFKh5)QI4IyBqcycKSeUYAJraQRo5J566xjW41bdM6(S0WgWlA6FUUHJ4i9Wq1HbVCDjIdEtNHQZeN7dJvfX2OE56S)nbOUibSw5XzO6(Sp9gLDLDLn8Z15G6(Sp9gLDLBxzd)CD)KtK)RkITr9Y1z3obOUibSw5XzO6(Sp9gLDf5kB4NRZb19zF6nk7kNCLn8Z19tor(VQiUi2gKaMajlHRS2yeG6Qt(yUU(vcmEDWGPUpJkaaipfGf)56goIJ0ddvhg8Y1Lio4nDgQotCUpmwveBJ6LRtoeG6IeWALhNHQJQFJK6WKTEg56SbQZb1zJqY6GARnUbBDajEshm197J)19ZEK)RkIlITbjGjqYs4kRngbOU6KpMRRFLaJxhmyQ7ZyNtHh)56goIJ0ddvhg8Y1Lio4nDgQotCUpmwveBJ6LRJCcqDrcyTYJZq195bzzyW8WkB4NRZb195bzzyW8WkBOI3evWqFUU0RJaYreBuD)Sh5)QI4IyBqcycKSeUYAJraQRo5J566xjW41bdM6(SbaeqaA7NRB4iospmuDyWlxxI4G30zO6mX5(WyvrSnQxUoYja1fjG1kpodv3NXaebAVqkB4NRZb19zmarG2lKYgQ4nrfm0NR7h5r(VQi2g1lxNCia1fjG1kpodv3N9P3OSRixzd)CDoOUp7tVrzx5KRSHFUUF2J8FvrSnQxUoBsaQlsaRvECgQUp7tVrzxzxzd)CDoOUp7tVrzx52v2Wpx3p5e5)QI4IyBqcycKSeUYAJraQRo5J566xjW41bdM6(mGMGgNw5px3WrCKEyO6WGxUUeXbVPZq1zIZ9HXQIyBuVCD2KauxKawR84muDFEqwggmpSYg(56CqDFEqwggmpSYgQ4nrfm0NR7N9i)xveBJ6LRJGeG6IeWALhNHQ7ZdYYWG5Hv2WpxNdQ7ZdYYWG5Hv2qfVjQGH(CD)Sh5)QI4Iyc3xjW4muD2)UU04nyRt0yhRkI1uyj2OL1(3Yrtjna4wWAkcJWQlIXtkQZgFqAOIycJWQJawAArDKt4quDK)n5KxexetyewDrsCUpmMauetyewDFQoObPHuaAcACALdM0jzVotmBIIRZb1bninKcqtqJtRCWKUQiMWiS6(uDrcyTYJx3xYxNeaicdJbiJHRZb1rlBVooYsdJXnyR7xKj)VQiMWiS6(uDeWqq11RZZGi5nQGRlIjyCSzsyVUgUoYai1fNw56wGh37tDSaZ15G6GaQIycJWQ7t1zJd2p71fdeq1fjG1kikxhmyQJa1s1HScgJRJmaYNfI6gofcYQJa1sQIycJWQ7t1rHijbgVo4wi4Poce)maAECD0IBbxNeai69PoyWu3xcaaYtbyXQIycJWQ7t1zdcMO1b26iGHsjVTY1rrlN36WissGXvfXfXPXBWIvsdBaVOPBlPpSMtNOcMOnFzsWaKXifqBNjYAkqysFxety1rfpmuDKQ7BIQtwW(j8Ms4yGxhbkJY1rQo7evh1Ms4yGxhbkJY1rQoYjQoBeHBDKQtoevhfTwIRJuD2SionEdwSsAyd4fnDBj9H1C6evWeT5ltcUfcEiYAkqys2lItJ3GfRKg2aErt3wsFynNorfmrB(YKMwk4TjkMiRPaHjr4lItJ3GfRKg2aErt3wsFeTxOHHcyPEAhxeNgVblwjnSb8IMUTK(af4UGHcWIKmgIwVpbhe5ElItJ3GfRKg2aErt3wsFalyCSzsyNOgMegGiq7fsjHGDebh4brYBWQ4nrfmeD6yaIaTxiLvGi9wWbmqyLxxXBIkyOI404nyXkPHnGx00TL0hsdGMGOgMekcmS6fa2O9gGbZRccqBlItJ3GfRKg2aErt3wsFyspadMxIAysOiWWQxayJ2BagmVkiaTTiMWQlsstmxhaUU0eXr6HHQZhoXidJRdcW46wGxhM536CqD0at06iJ96YfQU4exNdQdLRdZ8weNgVblwjnSb8IMUTK(WAoDIkyI28Ljb2acMd(0Bu2jYAkqysFxeNgVblwjnSb8IMUTK(WAoDIkyI28Ljb2acMd(0Bu2jcirkHGiQHj9ZNEJYUYUkoXbemhqrGHT4tVrzxzxzaabeG2QGqM0BW(NoDF6nk7k7QgR6fBgeprfCiIJKRJ8gGyRTHjYAkqys2lItJ3GfRKg2aErt3wsFynNorfmrB(YKaBabZbF6nk7ebKiLqqe1WK(5tVrzxrUkoXbemhqrGHT4tVrzxrUYaaciaTvbHmP3G9pD6(0Bu2vKRASQxSzq8evWHiosUoYBaIT2gMiRPaHjrErCA8gSyL0WgWlA62s6dR50jQGjAZxM0Bg5Gp9gL9qmqarK1uGWKIu7fXfXPXBWIjniBinEd2GOXorB(YKqtrUgMiSpTXjzNOgMekcmS6fa2O9gGbZRcrYICHgKgsbOjOXPvoysVionEdwSTK(WKcrinEd2GOXorB(YKa0e040kte2N24KStudtcAqAifGMGgNw5Gj9IycRocinaAI6OfZlBLN6KayCJk4I404nyX2s6dPbqtueNgVbl2wsF49dp4amYqgrnmjueyyLj9amyEvqaABrCA8gSyBj9Hj9amyEjQHjHIadRmPhGbZRccqBlIjmcRU04nyX2s6dR50jQGjAZxMeogmoJ9G7qeznfimjpNh2vE)YbheGAUiMWiS6sJ3GfBlPpmKze9(eSMtNOcMOnFzs4yW4m2dUdreqI0BVeznfimjpNh2vE)YbheGAUiMWQlISCD4yGxh25u4XfXPXBWITL0hdYgsJ3GniASt0MVmjSZPWJjc7tBCs2jQHjHIadRWXjeG2llGuis0PJIadRKganHcrQionEdwSTK(ahfricOjoUionEdwSTK(WKcrinEd2GOXorB(YKWSJire2N24KStudtknEBLdqaxnTePVlItJ3GfBlPpmPqesJ3GniASt0MVmjdaiGa02IycRozzZaeGbIauxKKyVo5uhyQZM1zaVOG6Ka961nTeUoWwhU3hbxNNZd71bqCCdX1bGRdLhmprRdm1bHm9(uhkpyEIwxdxhmpPOo4Hxcmz1146qKQlIqGQlLKeKvxwhbns1rGAP6OfZBDYhXQRX1HivxUq1rRfI6WaWwhCke1bGHvfXPXBWITL0htlrudtYaSYBUUAzZaeGbYYp56PGxxHkaaipfGfR4nrfmeD6OiWWkubaa5PaSyfI0FlyjwicEopSJvE8K44GjDs2T8ZaErbbjqVowgYTmm8W44evWwGgKgsnTKYBtuC4j7LHcGnmm8W4yzSMtNOcwnTuWBtuSLFYffbgwHId9Auis0PBaabeG2QqXHEnkej60)HIadRqXHEnkejlgaqabOTkyEsraE4LatMcr6)F60nGxuqqc0RJjrqlOiWWkVF4bhGrgYuiswqrGHvE)WdoaJmKPg(n7ftiBAbAqAi10skVnrXHNSxgka2WWWdJJLHG)lItJ3GfBlPpgKnKgVbBq0yNOnFzsW924yEic7tBCs2jQHjzaVOGGeOxhldPFe8twZPtubRGbiJrkG2o)VionEdwSTK(qA63ueOnPhtudtcAqAiL00VPiqBspw5Tjko8K9YqbWgggEyCSmKi)BlgWlkiib61XYqICIe9Ybdejcwety1rafr49NEmq1HDofECrCA8gSyBj9HjfIqA8gSbrJDI28LjHDofEmryFAJtYornmjueyyfko0RrHiveNgVbl2wsFm8ZaO5Xe1WKWS79(GvWTqWty4NbqZJT4PGxxHkaaipfGfR4nrfmKfueyyfQaaG8uawSccqBTKgVTYbup4t)8WdM03wSRiyeEmqQ3mYe63VF2TtWprUCIakcmSQxtoB6nydr79jaGdEmhIOi7JGvis))0pE55HmLbzgEDBLJIGrGxEEitn8dV2(ZMFhbueyyLrW5ysS37Jcr6)))FWlppKPg(H3)fXewDYhZ19cWEDCKL4f3w56(s(6mKzeCD)KpEyCCDuXddvhfTwIRZaWED2TtW64LNhYiQU3mkxhgz46OX1zYTU3mkxNhNED9wNnR7raqtb(FrCA8gSyBj9bTSDIWSH0VF2TtWprUCIakcmSQxtoB6nydr79jaGdEmhIOi7JGvis))0pE55HmLbzgEDBLJIGrGxEEitn8dV2(ZMFhbueyyLrW5ysS37Jcr6)))FWlppKPg(HxIAysEk41vOcaaYtbyXkEtubdzbfbgwHkaaipfGfRGa0wlPXBRCa1d(0pp8Gj9DrmHry1LgVbl2wsFibaIWWyaYyyIAysEk41vOcaaYtbyXkEtubdzbfbgwHkaaipfGfRGa0wl)4LNhYSvokcgbE55Hm1Wp8A7pB(DeqrGHvgbNJjXEVpkeP))j0p72j4Nixorafbgw1RjNn9gSHO9(eaWbpMdruK9rWkeP)wsJ3w5aQh8PFE4bt67I404nyX2s6JbzdPXBWgen2jAZxMeQaaG8uawmrnmjpf86kubaa5PaSyfVjQGHSGIadRqfaaKNcWIvqaABrCA8gSyBj9bmpatdqWb02zImKzeCWZ5HDmj7e1WKqrGHvPeh5G0WqPdgCWmP1EFuisfXPXBWITL0hsaGimmgGmgMiyWewoYoj7fXPXBWITL0htgLjYqMrWbpNh2XKStudt63WWdJJtubtNUep4g786HxeH3sIMhzGaUAYOSs6fr4TKO55VfObPHutgLvEBIIdpzVmuaSHHHhghldwIfIGNZd7yfMwlXbt6rG8prErCA8gSyBj9HazZj0lwQN0BWsKHmJGdEopSJjzNOgM0VHHhghNOcMoDjEWn251dVicVLenpYabCLazZj0lwQN0BWQKEreEljAE(BbAqAiLazZj0lwQN0BWQ82efhEYEzOaydddpmowgSelebpNh2XkmTwIdM0Ja5FI8I404nyX2s6djaqeggdqgdtemyclhzNK9I404nyX2s6dpEsCCWKorgYmco458WoMKDIAysddpmoorfSfObPHuE8K44GjDL3MO4Wt2ldfaByy4HXXY8ZM2ILyHi458Wow5XtIJdM0JGn)Bd8ZUTVj25HSG1uGW))KbSqiTR8e7CagmbubaaP4nrfm0NmaR8MRRw2mabyGS8tUOiWWkuCOxJcrIoDSelebpNh2XkpEsCCWKUm2)xeNgVbl2wsFibaIWWyaYyyIGbty5i7KSxeNgVbl2wsFGoiEkcyrIJjQHj9BYgkWw51vjeew1Rm)SB7Bg5GjoNhg)jtCopmoapPXBWMI)ryytCopCW7x(VLFyjwicEopSJvOdINIawK44iKgVbRcDq8ueWIehRGY38HTbsJ3GvHoiEkcyrIJvga2)lZV04nyv44HHuq5B(W2aPXBWQWXddPmaS)VionEdwSTK(atRL4GjDIAysyjwicEopSJvyATehmPlJDBrrGHvO4qVgfIueiVionEdwSTK(WJNehhmPtudtclXcrWZ5HDSYJNehhmPlJCkItJ3GfBlPpWXddrudtcfbgwzeCoMe79(OqKS8dfbgwHrGG4nKVOi4yfeG2AbfbgwHJtiaTxwaPGa0w60rrGHvO4qVgfI0)I404nyX2s6dtkeH04nydIg7eT5ltcUfcEkIlItJ3GfRqfaaKNcWIjnzuMidzgbh8CEyhtYornmPFY1Bt0EFOt)NDf5rqIhCJDE9WlIWBjrZJmKGaUAYOSs6fr4TKO55pD6)sJ3w5aQh8PFE4btIClddpmoorf8))wqrGHvOEyYOSccqBlItJ3GfRqfaaKNcWITL0hcKnNqVyPEsVblrgYmco458WoMKDIAysddpmoorfSfueyyfQhEbGfUhwbbOTfXPXBWIvOcaaYtbyX2s6dpEsCCWKorgYmco458WoMKDIAysddpmoorfSfueyyfQh84jXXkiaT1c0G0qkpEsCCWKUYBtuC4j7LHcGnmm8W4yz(ztBXsSqe8CEyhR84jXXbt6rWM)Tb(z323e78qwWAkq4)FYawiK2vEIDoadMaQaaGu8MOcgQionEdwScvaaqEkal2wsFGoiEkcyrIJjQHjHIadRq9a6G4PiGfjowbbOTfXPXBWIvOcaaYtbyX2s6dmTwIdM0jQHjHIadRq9aMwlXkiaT1cwIfIGNZd7yfMwlXbt6YyVionEdwScvaaqEkal2wsFGJhgIOgMekcmSc1d44HHuqaABrCA8gSyfQaaG8uawSTK(atRL4GjDIAysOiWWkupGP1sSccqBlItJ3GfRqfaaKNcWITL0hE8K44GjDIAysOiWWkup4XtIJvqaABrCrCA8gSyLbaeqaAlPekL82khW0Y5Lidzgbh8CEyhtYornmPF)KleWvjuk5TvoGPLZBakFZhw5TjAVp0PdbCvcLsEBLdyA58gGY38Hvd)M9Ije5)T8dc4QekL82khW0Y5naLV5dRWEAIsi5qNUCHaUkHsjVTYbmTCEdXCkuypnrLX(FlYffbgwLqPK3w5aMwoVHyofHEdWI(j2viswKlkcmSkHsjVTYbmTCEdq5B(WHEdWI(j2vis)T458WUY7xo4GauZYqq60tJ3w5aV8BZyzi3ICHaUkHsjVTYbmTCEdq5B(WkVnr79XcV88qgHKdbT458WUY7xo4GauZYqWI404nyXkdaiGa0wBj9bSGXXMjHDIAys)WaebAVqkjeSJi4apisEdw60XaebAVqkRar6TGdyGWkV(FI615zqK8q)(YqD6mj7e1RZZGi5HhbanfKStuVopdIKhAysyaIaTxiLvGi9wWbmqyLxVionEdwSYaaciaT1wsFGG5q78lMiSa4ys(0Bu2Ttudt63pdaiGa0wLbSwbr5GhZbSupTJvd)M9Ije5w(HIadRqXHEnkej60naGacqBvO4qVg1WVzVyzS)9))0PJcWylW9tShg(n7ftiY)(pD6)maGacqBvgWAfeLdEmhWs90own8B2l(tKlJ1C6evWQ3mYbF6nk7HyGa6pD6wZPtubRaBabZbF6nk7K(Mo9FwZPtubRaBabZbF6nk7Ki3YpdaiGa0wLbSwbr5GhZbSupTJvd)M9ILHCYPthfGXwG7Nypm8B2lMqK)nD6(0Bu2vKRmaGacqBvd)M9ILH8V))VionEdwSYaaciaT1wsFGG5q78lMiSa4ys(0Bu2jNOgM0VFgaqabOTkdyTcIYbpMdyPEAhRg(n7ftiYT8dfbgwHId9Auis0PBaabeG2QqXHEnQHFZEXYy)7)w(5tVrzxzxzaabeG2Qg(n7fldjYPt3AoDIkyfydiyo4tVrzNe5))tNokaJTa3pXEy43SxmHi)7)0P)7NbaeqaARYawRGOCWJ5awQN2XQHFZEXFICBJ0VJWVF(0Bu2v2vgaqabOTQHFZEXeYaaciaTvzaRvquo4XCal1t7y1WVzV4pr(Fl)SMtNOcwb2acMd(0Bu2jzNoDR50jQGvGnGG5Gp9gLDzijN)))lJ1C6evWQ3mYbF6nk7HyGa6pD6wZPtubRaBabZbF6nk7K(Mo9FwZPtubRaBabZbF6nk7KSB5NbaeqaARYawRGOCWJ5awQN2XQHFZEXYqo50PJcWylW9tShg(n7ftiY)MoDF6nk7k7kdaiGa0w1WVzVyzi)7))lIjS6IKe71jF)WZNX1fXqgYQdLHbdx3pWux)(YqD6cYQlHDE(xNjXEVp1fX4jf1fXgEjWKvxdx3x8G5jADnUozJiYxhyRZaaciaTvveNgVblwzaabeG2AlPp8(HhCagziJimzRHempPiap8sGjJOgMKbaeqaARcfh61OqKkItJ3GfRmaGacqBTL0hW8KIa8WlbMmImKzeCWZ5HDmj7e1WKmGxuqqc0RJjKCS458WUY7xo4GauZYq4T8dfbgwHtR5dhgqokej60LRNcEDfoTMpCya5O4nrfm0Fl)KRbaeqaARY7hEWbyKHmfIeD6gaqabOTkuCOxJcr6pD6Oam2cC)e7HHFZEXeIWXcC)e7HHFZEXYqErmHvN8reB8icbOozzgQohuhMS1uhT2JRJw7X1nPvEbi46GhEjWKvhTyERJgx3GS1bp8sGjdnxiIQdm1LUGtSxNjMnrRRHRRDCD0aJhxx7fXPXBWIvgaqabOT2s6duEW8eLOgMuA82khGaUAAjz(2YpdaiGa0wLbSwbr5GhZbSupTJvis0PBaabeG2QmG1kikh8yoGL6PDSA43SxSmYHC60rbySf4(j2dd)M9Ije5F)VionEdwSYaaciaT1wsF0RjNn9gSe1WKsJ3w5aeWvtljZ3w(zaabeG2QmG1kikh8yoGL6PDScrIoDuagBbUFI9WWVzVycjNV)xety1j)qwD5cv3c86OLyNRt(iwD8YZdzevhkIxxkWG6IOiyVoemxx71bdM6iW8eTUCHQRxtolUionEdwSYaaciaT1wsF49dp4amYqgrnmjE55Hmfed3M2LXMFtNokcmScfh61OqKOt)NNcEDL0WqPdgfVjQGHSGJbJZyp4oeHKZF60)LgVTYbiGRMwI03wqrGHvOcaaYtbyXkeP)fXewDeq7NyVouUoAdyFQZb1HG56OEzbuDGTocugLRR36SYdz1zLhYQBBtmxhUDK0BWIjQoueVoR8qwDtoSGSI404nyXkdaiGa0wBj9booHa0EzbernmjueyyL3p8GdWidzkejlOiWWkuCOxJccqBTyaVOGGeOxhtiBAbfbgwHrGG4nKVOi4yfeG2Abc4QjJYkPxeH3sIMhczxfPw4LNhYKXMFBbAqAi1KrzL3MO4Wt2ldfaByy4HXXYGLyHi458WowHP1sCWKEei)tKBXZ5HDL3VCWbbOMLHGfXPXBWIvgaqabOT2s6duEW8eT3hIAysOiWWkVF4bhGrgYuis0PJIadRqXHEnkePI404nyXkdaiGa0wBj9HeWBWsudtcfbgwHId9Auis0PJcWylW9tShg(n7ftidaiGa0wfko0Rrn8B2lMoDuagBbUFI9WWVzVycroblItJ3GfRmaGacqBTL0htALxacoap8sGjJOgMekcmScfh61OqKOthUFI9WWVzVycrU9IycRo5Ji24recqDrsmBIw3laSr7TUyGtRUCHQd7iWW1j6OCDECJjQUCHQ7njdLRdLDNN6mGx00RB43S36ggt2AkItJ3GfRmaGacqBTL0hgWAfeLdEmhWs90oMOgM0piGRMwsn8B2lwgBAXaErbbjqVoMqe0YpiGRMmkR82eT3h60XsSqe8CEyhR84jXXbt6Yy)VfE55Hmfed3M2LHe5FBXaaciaTvHId9Aud)M9ILX(3)PthfGXwG7Nypm8B2lMqeKo9FOiWWkuCOxJcrYckcmScfh61Og(n7flJDY)xety1ranjdLRZJ5HRdhdqeq1HY19cgUodyHAVblUoWwNhZ1zales7fXPXBWIvgaqabOT2s6d(vcqJNakyHiQHjHIadR8(HhCagzitHirN(pdyHqAxbXSuifc(PZ1WkEtubd9ViMWQZgRTY1jnnyANS6CqDG9tiyUoACkb2I404nyXkdaiGa0wBj9bcMdTZVeT5ltkIcCK9H7zcqm27LmCWKcbrnmjoIJ0ssmKkIcCK9H7zcqm27LmCWKcrrCA8gSyLbaeqaARTK(abZH25xCrCrCA8gSyfCle8qAYOmrgYmco458WoMKDIAyswZPtubRGBHGhs2Tmm8W44evWwGaUAYOSs6fr4TKO5HqKSRipcs8GBSZRhEreEljAEkItJ3GfRGBHGhBj9XKrzIAyswZPtubRGBHGhsKxeNgVblwb3cbp2s6dbYMtOxSupP3GLOgMK1C6evWk4wi4HKCkItJ3GfRGBHGhBj9bMwlXe1WKSMtNOcwb3cbpKSzrCA8gSyfCle8ylPpWXddrudtcfbgwHrGG4nKVOi4yfeG2weNgVblwb3cbp2s6JHFganpMOgMeMDV3hScUfcEcd)maAESfmlyJ3Gn49llJDfbJWJbs9MrUiMWiS6sJ3GfRGBHGhBj9bSGXXMjHDIAysyaIaTxiLec2reCGhejVbRI3evWq0PJbic0EHuwbI0BbhWaHvEDfVjQGHiQxNNbrYd97ld1PZKStuVopdIKhEea0uqYor968misEOHjHbic0EHuwbI0BbhWaHvE9I4I404nyXk4EBCmpKKaaryymazmmrWGjSCKDs2lItJ3GfRG7TXX8ylPpWP18HddihIAysOiWWkCAnF4WaYrn8B2lMqYPionEdwScU3ghZJTK(qA63ueOnPhtudt6h0G0qkPPFtrG2KESYBtuC4j7LHcGnmm8W4yzKte(HLyHi458Wowjn9Bkc0M0JT1(FlyjwicEopSJvst)MIaTj9yzS)NoDSelebpNh2XkPPFtrG2KESm)KJT2JGNcEDfor5XbapwXBIkyO)fXPXBWIvW924yESL0htlrKHmJGdEopSJjzNOgM0WWdJJtubBbAqAi10skVnrXHNSxgka2WWWdJJLXAoDIky10sbVnrXw(9dfbgw59dp4amYqMcrIoD56TjAVp)T8dfbgwHkaaipfGfRqKOtxUEk41vOcaaYtbyXkEtubd9NoD56PGxxHtuECaWJv8MOcg6VLFyjwicEopSJvst)MIaTj9ys2PtxUEk41vst)MIaTj9yfVjQGH(B5xA82khGaUAAjsFtNU3MO9(yjnEBLdqaxnTej70Pl3bzzyW8WkOjrEI9aaoaXSuagyqW0Plxpf86kCIYJdaESI3evWq)lItJ3GfRG7TXX8ylPpWP18HddihIAysOiWWkCAnF4WaYrn8B2lMq)mGxuqqc0RJT1()iePr4BLCkItJ3GfRG7TXX8ylPpG5byAacoG2ot0Bg5aV88qgj7eziZi4GNZd7ys2lItJ3GfRG7TXX8ylPpG5byAacoG2otKHmJGdEopSJjzNOgMekcmScfh61OqKS4PGxxHbiIaao4XCagmm2v8MOcgIoDdaiGa0wLbSwbr5GhZbSupTJvd)M9IjKDlgGvEZ1vB)e7b4KlItJ3GfRG7TXX8ylPpg(za08yIAysy29EFWk4wi4jm8ZaO5XwWSGnEd2G3VSm2vemcpgi1Bg5I4I404nyXkanbnoTYKWEoyK5HjQHjHIadRI5C8aao4XCGwlGuisfXPXBWIvaAcACALTL0hyKfUhMirVCWarYMr4XaveNgVblwbOjOXPv2wsF8calCpmrIE5GbIKnJWJbIOgMekcmS6fa2O9gGbZRcrYcwIfIGNZd7yLhpjooysNqKBrUEk41vcKnNqVyPEsVbRI3evWqw4LNhYiuK(Tf5IIadRmcohtI9EFuisfXPXBWIvaAcACALTL0hXCoEaah8yoqRfqe1WK4LNhYiKC(2ceWvtlPg(n7flJnve0YpdaiGa0wL3p8GdWidzQHFZEXYqksveKo9bzzyW8Wkt6mzCWGmn4VfueyyLrW5ysS37Jc7PjkHSBrUOiWWQuIJCqAyO0bdoyM0AVpkejlYffbgwHkaaibc2viswKlkcmScfh61OqKS8ZaaciaTvzaRvquo4XCal1t7y1WVzVyzIufbPtxUgGvEZ1vB)e7b4K)B5NCnaR8MRRw2mabyGOt3aaciaTvLqPK3w5aMwoVQHFZEXYqIG0PdbCvcLsEBLdyA58gGY38Hvd)M9ILHW)VionEdwScqtqJtRSTK(4fa2O9gGbZlrnmjE55HmcjNVTabC10sQHFZEXYytfbT8ZaaciaTv59dp4amYqMA43SxSmKSPIG0PpilddMhwzsNjJdgKPb)TGIadRmcohtI9EFuypnrjKDlYffbgwLsCKdsddLoyWbZKw79rHizrUOiWWkubaajqWUcrYYp5IIadRqXHEnkej60naR8MRRw2mabyGS4PGxxHtR5dhgqokEtubdzbfbgwHId9Aud)M9ILjs)B5NbaeqaARYawRGOCWJ5awQN2XQHFZEXYePkcsNUCnaR8MRR2(j2dWj)3Yp5Aaw5nxxTSzacWarNUbaeqaARkHsjVTYbmTCEvd)M9ILHebPthc4QekL82khW0Y5naLV5dRg(n7fldH)Vf4(j2dd)M9ILHWxexeNgVblwHzhrIKazZj0lwQN0BWsudtYaSYBUUAzZaeGbYcwIfIGNZd7yLhpjooysNq20Ib8IccsGEDmHiOf56TjAVpwKlkcmScfh61OqKkItJ3GfRWSJizlPpKaaryymazmmrWGjSCKDs2lItJ3GfRWSJizlPpWP18HddihIAysEk41vW8KIa8WlbMmfVjQGHSyaabeG2QG5jfb4HxcmzkejlYffbgwHtR5dhgqokejlgWlkiib61XYy3ceWvtgLvEBI27JLFqaxjq2Cc9IL6j9gSkVnr79HoD56PGxxjq2Cc9IL6j9gSkEtubd9ViMWiS6sJ3GfRWSJizlPpKaaryymazmmrnmjpf86kubaa5PaSyfVjQGHSGIadRqfaaKNcWIvqaARLF8YZdz2khfbJaV88qMA4hET9Nn)ocOiWWkJGZXKyV3hfI0))e6ND7e8tKlNiGIadR61KZMEd2q0EFca4GhZHikY(iyfI0FlPXBRCa1d(0pp8Gj9DrCA8gSyfMDejBj9bTSDIWSH0VF2TtWprUCIakcmSQxtoB6nydr79jaGdEmhIOi7JGvis))0pE55HmLbzgEDBLJIGrGxEEitn8dV2(ZMFhbueyyLrW5ysS37Jcr6)))FWlppKPg(HxIAysEk41vOcaaYtbyXkEtubdzbfbgwHkaaipfGfRGa0wlPXBRCa1d(0pp8Gj9DrCA8gSyfMDejBj9HjfIqA8gSbrJDI28LjHkaaipfGftudtYtbVUcvaaqEkalwXBIkyilOiWWkubaa5PaSyfeG2A5Nb8IccsGEDmHiiD6yjwicEopSJvE8K44GjDs2)xeNgVblwHzhrYwsFysHiKgVbBq0yNOnFzsgaqabOTfXPXBWIvy2rKSL0hMuicPXBWgen2jAZxMeCVnoMhIW(0gNKDIAysgWlkiib61XYihl)qrGHvOcaaYtbyXkej60LRNcEDfQaaG8uawSI3evWq)lIlItJ3GfRWoNcpMKeaicdJbiJHjcgmHLJStYErCA8gSyf25u4X2s6dmTwIdM0jQHjHIadRqXHEnkejlyjwicEopSJvyATehmPlJCSmilddMhwbp8sGjdnxOIycRocugLRBzgcx3aqEIfKvhb)2gOoaCDTJRtW7Jhxx61L192B)I8wNdQdJmsjgxhoEyiCDqsCrCA8gSyf25u4X2s6JjJYeziZi4GNZd7ys2jQHj9dc4QjJYkPxeH3sIMhczxrq60hgEyCCIk4)wGgKgsnzuw5Tjko8K9YqbWgggEyCSmKtN(pjEWn251dVicVLenpYabC1KrzL0lIWBjrZJfueyyfko0RrHizblXcrWZ5HDSYJNehhmPti5yXaSYBUUAzZaeGb6pD6OiWWkuCOxJA43SxmHSxeNgVblwHDofESTK(qGS5e6fl1t6nyjQHjHLyHi458Wow5XtIJdM0jKCSmm8W44evWwGgKgsjq2Cc9IL6j9gSkVnrXHNSxgka2WWWdJJLHGw(zaVOGGeOxhtYM0PdbCLazZj0lwQN0BWQg(n7fticsNUCHaUsGS5e6fl1t6nyvEBI27Z)IycRUVgepf1rjsCCDnUou2DEQZJZToSZPWJRJkEyO6sVo5uNNZd74I404nyXkSZPWJTL0hOdINIawK4yIAysyjwicEopSJvOdINIawK4yziVionEdwSc7Ck8yBj9HeaicdJbiJHjcgmHLJStYErCA8gSyf25u4X2s6dC8Wqe1WKmGxuqqc0RJjKnTGLyHi458Wow5XtIJdM0jeblIlItJ3GfRqtrUgMegzH7HjQHjHIadRyJOLWCade5OGa0wlOiWWk2iAjmheiBokiaT1YVHHhghNOcMo9FPXBRCGx(TzSm2TKgVTYbiGRWilCpmHsJ3w5aV8BZ4))lItJ3GfRqtrUg2wsFG9CWiZdtudtcfbgwXgrlH5agiYrn8B2lwg7FBRjXEW7xMoDueyyfBeTeMdcKnh1WVzVyzS)TTMe7bVF5I404nyXk0uKRHTL0hyph4EyIAysOiWWk2iAjmheiBoQHFZEXYysSh8(LPthfbgwXgrlH5agiYrbbOTwWarob2iAjmlZ30PJIadRyJOLWCade5OGa0wlcKnNaBeTeM)uA8gSkAt6XQEdWI(j2jK9I404nyXk0uKRHTL0h0M0JjQHjHIadRyJOLWCade5Og(n7flJjXEW7xMoDueyyfBeTeMdcKnhfeG2ArGS5eyJOLW8NsJ3GvrBspw1Baw0pXUmFRDTR1a]] )


end
