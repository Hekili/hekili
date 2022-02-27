-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

-- Conduits
-- [-] fury_of_the_skies
-- [x] precise_alignment
-- [-] stellar_inspiration
-- [-] umbral_intensity

-- Covenants
-- [x] deep_allegiance
-- [-] endless_thirst
-- [-] evolved_swarm
-- [-] conflux_of_elements

-- Endurance
-- [x] tough_as_bark
-- [x] ursine_vigor
-- [-] innate_resolve

-- Finesse
-- [x] born_anew
-- [-] front_of_the_pack
-- [x] born_of_the_wilds
-- [x] tireless_pursuit


if UnitClassBase( "player" ) == "DRUID" then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {
            aura = "fury_of_elune_ap",
            debuff = true,

            last = function ()
                local app = state.debuff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 2,
            value = 1,
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )


    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        heart_of_the_wild = 18577, -- 319454

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        solstice = 21648, -- 343647
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        high_winds = 5383, -- 200931
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        owlkin_adept = 5407, -- 354541
        protector_of_the_grove = 3728, -- 209730
        star_burst = 3058, -- 356517
        thorns = 3731, -- 305497
    } )


    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    local mod_circle_hot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.85 * x ) or x
    end, state )

    local mod_circle_dot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.75 * x ) or x
    end, state )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = function () return 20 + ( conduit.precise_alignment.mod * 0.001 ) end,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse_lunar = {
            id = 48518,
            duration = 15,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 15,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        elunes_wrath = {
            id = 64823,
            duration = 10,
            max_stack = 1
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            tick_time = 0.5,
            max_stack = 1,

            generate = function ( t )
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    t.count = 1
                    t.expires = applied + 8
                    t.applied = applied
                    t.caster = "player"
                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,

            copy = "fury_of_elune"
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        heart_of_the_wild = {
            id = 108291,
            duration = 45,
            max_stack = 1,
            copy = { 108292, 108293, 108294 }
        },
        incarnation = {
            id = 102560,
            duration = function () return 30 + ( conduit.precise_alignment.mod * 0.001 ) end,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
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
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = function () return mod_circle_dot( 22 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        owlkin_frenzy = {
            id = 157228,
            duration = 10,
            max_stack = function () return pvptalent.owlkin_adept.enabled and 2 or 1 end,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solstice = {
            id = 343648,
            duration = 6,
            max_stack = 1,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )

                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = 8,
            max_stack = 1,
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_flare = {
            id = 202347,
            duration = function () return mod_circle_dot( 24 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = function () return mod_circle_dot( 18 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thrash_bear = {
            id = 192090,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 3,
        },
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
        },


        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {},
        --[[
            alias = { "incarnation", "celestial_alignment" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            -- duration = function () return talent.incarnation.enabled and 30 or 20 end,
        }, ]]

        any_form = {
            alias = { "bear_form", "cat_form", "moonkin_form" },
            duration = 3600,
            aliasMode = "first",
            aliasType = "buff",            
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 33786,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        high_winds = {
            id = 200931,
            duration = 4,
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 305497,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        arcanic_pulsar = {
            id = 287790,
            duration = 3600,
            max_stack = 9,
        },

        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },


        -- Legendaries
        balance_of_all_things_arcane = {
            id = 339946,
            duration = 8,
            max_stack = 8
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 8,
            max_stack = 8,
        },

        oath_of_the_elder_druid = {
            id = 338643,
            duration = 60,
            max_stack = 1
        },

        oneths_perception = {
            id = 339800,
            duration = 30,
            max_stack = 1,
        },

        oneths_clear_vision = {
            id = 339797,
            duration = 30,
            max_stack = 1,
        },

        primordial_arcanic_pulsar = {
            id = 338825,
            duration = 3600,
            max_stack = 10,
        },

        timeworn_dreambinder = {
            id = 340049,
            duration = 6,
            max_stack = 2,
        },
    } )


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
        removeBuff( "celestial_guardian" )

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

        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end
    end )

    --[[ This is intended to cause an AP reset on entering an encounter, but it's not working. 
        spec:RegisterHook( "start_combat", function( action )
        if boss and astral_power.current > 50 then
            spend( astral_power.current - 50, "astral_power" )
        end
    end ) ]]

    spec:RegisterHook( "pregain", function( amt, resource, overcap, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt > 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )

    spec:RegisterHook( "prespend", function( amt, resource, clean )
        if buff.memory_of_lucid_dreams.up then
            if amt < 0 and resource == "astral_power" then
                return amt * 2, resource, overcap, true
            end
        end
    end )


    local check_for_ap_overcap = setfenv( function( ability )
        local a = ability or this_action
        if not a then return true end

        a = action[ a ]
        if not a then return true end

        local cost = 0
        if a.spendType == "astral_power" then cost = a.cost end

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 2 ) or 0 ) < astral_power.max
    end, state )

    spec:RegisterStateExpr( "ap_check", function() return check_for_ap_overcap() end )

    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = {
        "force_of_nature", "full_moon", "half_moon", "incarnation", "moonfire", "new_moon", "starfall", "starfire", "starsurge", "sunfire", "wrath"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end


    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID
    end

    state.IsActiveSpell = IsActiveSpell

    local ExpireCelestialAlignment = setfenv( function()
        eclipse.state = "ANY_NEXT"
        eclipse.reset_stacks()
        if buff.eclipse_lunar.down then removeBuff( "starsurge_empowerment_lunar" ) end
        if buff.eclipse_solar.down then removeBuff( "starsurge_empowerment_solar" ) end
        if Hekili.ActiveDebug then Hekili:Debug( "Expire CA_Inc: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseLunar = setfenv( function()
        eclipse.state = "SOLAR_NEXT"
        eclipse.reset_stacks()
        eclipse.wrath_counter = 0
        removeBuff( "starsurge_empowerment_lunar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
        eclipse.starfire_counter = 0
        removeBuff( "starsurge_empowerment_solar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Solar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    spec:RegisterStateTable( "eclipse", setmetatable( {
        -- ANY_NEXT, IN_SOLAR, IN_LUNAR, IN_BOTH, SOLAR_NEXT, LUNAR_NEXT
        state = "ANY_NEXT",
        wrath_counter = 2,
        starfire_counter = 2,

        reset = setfenv( function()
            eclipse.starfire_counter = GetSpellCount( 197628 ) or 0
            eclipse.wrath_counter    = GetSpellCount(   5176 ) or 0

            if buff.eclipse_solar.up and buff.eclipse_lunar.up then
                eclipse.state = "IN_BOTH"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_solar.up then
                eclipse.state = "IN_SOLAR"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_lunar.up then
                eclipse.state = "IN_LUNAR"
                -- eclipse.reset_stacks()
            elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter > 0 then
                eclipse.state = "ANY_NEXT"
            elseif eclipse.starfire_counter == 0 and eclipse.wrath_counter > 0 then
                eclipse.state = "LUNAR_NEXT"
            elseif eclipse.starfire_counter > 0 and eclipse.wrath_counter == 0 then
                eclipse.state = "SOLAR_NEXT"
            elseif eclipse.starfire_count == 0 and eclipse.wrath_counter == 0 and buff.eclipse_lunar.down and buff.eclipse_solar.down then
                eclipse.state = "ANY_NEXT"
                eclipse.reset_stacks()
            end

            if buff.ca_inc.up then
                state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            elseif buff.eclipse_solar.up then
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
            elseif buff.eclipse_lunar.up then
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
            end

            buff.eclipse_solar.empowerTime = 0
            buff.eclipse_lunar.empowerTime = 0

            if buff.eclipse_solar.up and action.starsurge.lastCast > buff.eclipse_solar.applied then buff.eclipse_solar.empowerTime = action.starsurge.lastCast end
            if buff.eclipse_lunar.up and action.starsurge.lastCast > buff.eclipse_lunar.applied then buff.eclipse_lunar.empowerTime = action.starsurge.lastCast end
        end, state ),

        reset_stacks = setfenv( function()
            eclipse.wrath_counter = 2
            eclipse.starfire_counter = 2
        end, state ),

        trigger_both = setfenv( function( duration )
            eclipse.state = "IN_BOTH"
            eclipse.reset_stacks()

            if legendary.balance_of_all_things.enabled then
                applyBuff( "balance_of_all_things_arcane", nil, 8, 8 )
                applyBuff( "balance_of_all_things_nature", nil, 8, 8 )
            end

            if talent.solstice.enabled then applyBuff( "solstice" ) end

            removeBuff( "starsurge_empowerment_lunar" )
            removeBuff( "starsurge_empowerment_solar" )

            applyBuff( "eclipse_lunar", ( duration or class.auras.eclipse_lunar.duration ) + buff.eclipse_lunar.remains )
            if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
            applyBuff( "eclipse_solar", ( duration or class.auras.eclipse_solar.duration ) + buff.eclipse_solar.remains )

            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            state:RemoveAuraExpiration( "eclipse_solar" )
            state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
            state:RemoveAuraExpiration( "eclipse_lunar" )
            state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
        end, state ),

        advance = setfenv( function()
            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Pre): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

            if not ( eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" ) then           
                if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )                
                    state:RemoveAuraExpiration( "eclipse_solar" )
                    state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_SOLAR"
                    eclipse.starfire_counter = 0
                    eclipse.wrath_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end

                if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_lunar", class.auras.eclipse_lunar.duration + buff.eclipse_lunar.remains )
                    if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
                    state:RemoveAuraExpiration( "eclipse_lunar" )
                    state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_LUNAR"
                    eclipse.wrath_counter = 0
                    eclipse.starfire_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end
            end

            if eclipse.state == "IN_SOLAR" then eclipse.state = "LUNAR_NEXT" end
            if eclipse.state == "IN_LUNAR" then eclipse.state = "SOLAR_NEXT" end
            if eclipse.state == "IN_BOTH" then eclipse.state = "ANY_NEXT" end

            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
            
        end, state )
    }, {
        __index = function( t, k )
            -- any_next
            if k == "any_next" then
                return eclipse.state == "ANY_NEXT"
            -- in_any
            elseif k == "in_any" then
                return eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH"
            -- in_solar
            elseif k == "in_solar" then
                return eclipse.state == "IN_SOLAR"
            -- in_lunar
            elseif k == "in_lunar" then
                return eclipse.state == "IN_LUNAR"
            -- in_both
            elseif k == "in_both" then
                return eclipse.state == "IN_BOTH"
            -- solar_next
            elseif k == "solar_next" then
                return eclipse.state == "SOLAR_NEXT"
            -- solar_in
            elseif k == "solar_in" then
                return eclipse.starfire_counter
            -- solar_in_2
            elseif k == "solar_in_2" then
                return eclipse.starfire_counter == 2
            -- solar_in_1
            elseif k == "solar_in_1" then
                return eclipse.starfire_counter == 1
            -- lunar_next
            elseif k == "lunar_next" then
                return eclipse.state == "LUNAR_NEXT"
            -- lunar_in
            elseif k == "lunar_in" then
                return eclipse.wrath_counter
            -- lunar_in_2
            elseif k == "lunar_in_2" then
                return eclipse.wrath_counter == 2
            -- lunar_in_1
            elseif k == "lunar_in_1" then
                return eclipse.wrath_counter == 1
            end
        end
    } ) )

    spec:RegisterStateTable( "druid", setmetatable( {},{ 
        __index = function( t, k )
            if k == "catweave_bear" then return false
            elseif k == "owlweave_bear" then return false
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif rawget( debuff, k ) ~= nil then return debuff[ k ] end
            return false
        end
    } ) )

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
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
            rawset( buff, "ca_inc", buff.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
            rawset( buff, "ca_inc", buff.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 )
        end

        eclipse.reset()

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
        end
    end )


    spec:RegisterHook( "step", function()
        if Hekili.ActiveDebug then Hekili:Debug( "Eclipse State: %s, Wrath: %d, Starfire: %d; Lunar: %.2f, Solar: %.2f\n", eclipse.state or "NOT SET", eclipse.wrath_counter, eclipse.starfire_counter, buff.eclipse_lunar.remains, buff.eclipse_solar.remains ) end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if legendary.primordial_arcanic_pulsar.enabled and resource == "astral_power" and amt > 0 then
            local v1 = ( buff.primordial_arcanic_pulsar.v1 or 0 ) + amt

            if v1 >= 300 then
                applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment", 9 )
                v1 = v1 - 300
            end

            if v1 > 0 then
                applyBuff( "primordial_arcanic_pulsar", nil, max( 1, floor( amt / 30 ) ) )
                buff.primordial_arcanic_pulsar.v1 = v1
            else
                removeBuff( "primordial_arcanic_pulsar" )
            end
        end
    end )


    -- Tier 28
    spec:RegisterGear( "tier28", 188853, 188851, 188849, 188848, 188847 )
    spec:RegisterSetBonuses( "tier28_2pc", 364423, "tier28_4pc", 363497 )
    -- 2-Set - Celestial Pillar - Entering Lunar Eclipse creates a Fury of Elune at 25% effectiveness that follows your current target for 8 sec.
    -- 4-Set - Umbral Infusion - While in an Eclipse, the cost of Starsurge and Starfall is reduced by 20%.

    -- Legion Sets (for now).
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( "solar_solstice", {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } )

    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )


    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return 60 * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
            gcd = "off",

            toggle = "defensives",
            defensive = true,

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

            auras = {
                -- Conduit
                ursine_vigor = {
                    id = 340541,
                    duration = 4,
                    max_stack = 1
                }
            }
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
            end,

            auras = {
                -- Conduit
                tireless_pursuit = {
                    id = 340546,
                    duration = function () return conduit.tireless_pursuit.enabled and conduit.tireless_pursuit.mod or 3 end,
                    max_stack = 1,
                }
            }
        },


        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "celestial_alignment" )
                stat.haste = stat.haste + 0.1

                eclipse.trigger_both( 20 )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
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
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },


        entangling_roots = {
            id = 339,
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,

            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },


        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132925,

            handler = function ()
            end,
        }, ]]


        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",

            ap_check = function() return check_for_ap_overcap( "force_of_nature" ) end,

            handler = function ()
                summonPet( "treants", 10 )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = function () return ( talent.guardian_affinity.enabled and buff.heart_of_the_wild.up ) and 2 or nil end,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },


        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",

            ap_check = function() return check_for_ap_overcap( "full_moon" ) end,

            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },


        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        half_moon = {
            id = 274282,
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",

            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",

            ap_check = function() return check_for_ap_overcap( "half_moon" ) end,

            usable = function () return active_moon == "half_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",
            talent = "heart_of_the_wild",

            startsCombat = true,
            texture = 135879,

            handler = function ()
                applyBuff( "heart_of_the_wild" )

                if talent.feral_affinity.enabled then
                    shift( "cat_form" )
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
            id = 102560,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

            spend = -40,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                shift( "moonkin_form" )

                applyBuff( "incarnation" )
                stat.crit = stat.crit + 0.10
                stat.haste = stat.haste + 0.10

                eclipse.trigger_both( 20 )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = { "incarnation_chosen_of_elune", "Incarnation" },
        },


        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,

            usable = function () return group end,
            handler = function ()
                active_dot.innervate = 1
            end,

            auras = {
                innervate = {
                    id = 29166,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = true,
            texture = 1378702,

            handler = function ()
                applyBuff( "ironfur" )
            end,
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            talent = "feral_affinity",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            usable = function () return combo_points.current > 0, "requires combo points" end,
            handler = function ()
                applyDebuff( "target", "maim" )
                spend( combo_points.current, "combo_points" )
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
            cooldown = function () return 30 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = function () return 50 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
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

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            ap_check = function() return check_for_ap_overcap( "moonfire" ) end,

            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )

                if talent.twin_moons.enabled and active_enemies > 1 then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end
            end,
        },


        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        new_moon = {
            id = 274281,
            cast = 1,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,

            talent = "new_moon",
            bind = "full_moon",

            ap_check = function() return check_for_ap_overcap( "new_moon" ) end,

            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.17,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.11,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 135952,

            handler = function ()
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                gain( 0.3 * health.max, "health" )
            end,
        },


        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
            end,
        },


        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            spend = 0.17,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeBuff( "dispellable_enrage" )
            end,
        },


        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
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


        starfall = {
            id = 191034,
            cast = 0,
            cooldown = function () return talent.stellar_drift.enabled and 12 or 0 end,
            gcd = "spell",

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                end

                applyBuff( "starfall" )
                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
                end

                removeBuff( "oneths_perception" )

                if legendary.timeworn_dreambinder.enabled then
                    addStack( "timeworn_dreambinder", nil, 1 )
                end
            end,
        },


        starfire = {
            id = function () return state.spec.balance and 194153 or 197628 end,
            known = function () return state.spec.balance and IsPlayerSpell( 194153 ) or IsPlayerSpell( 197628 ) end,
            cast = function ()
                if buff.warrior_of_elune.up or buff.elunes_wrath.up or buff.owlkin_frenzy.up then return 0 end
                return haste * ( buff.eclipse_lunar and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 2.25
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -8 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135753,

            ap_check = function() return check_for_ap_overcap( "starfire" ) end,

            talent = function () return ( not state.spec.balance and "balance_affinity" or nil ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if eclipse.state == "ANY_NEXT" or eclipse.state == "SOLAR_NEXT" then
                    eclipse.starfire_counter = eclipse.starfire_counter - 1
                    eclipse.advance()
                end

                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
                end

                if buff.elunes_wrath.up then
                    removeBuff( "elunes_wrath" )
                elseif buff.warrior_of_elune.up then
                    removeStack( "warrior_of_elune" )
                    if buff.warrior_of_elune.down then
                        setCooldown( "warrior_of_elune", 45 )
                    end
                elseif buff.owlkin_frenzy.up then
                    removeStack( "owlkin_frenzy" )
                end

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,

            copy = { 194153, 197628 }
        },


        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                end

                removeBuff( "oneths_clear_vision" )
                removeBuff( "sunblaze" )

                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( "ca_inc", 6 )
                        eclipse.trigger_both( 6 )
                    end
                end

                if legendary.timeworn_dreambinder.enabled then
                    addStack( "timeworn_dreambinder", nil, 1 )
                end
            end,

            auras = {
                starsurge_empowerment_lunar = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment (Lunar)"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = buff.eclipse_lunar.expires - last
                            t.expires = t.applied + t.duration
                            t.count = 1
                            t.caster = "player"
                            return
                        end

                        t.applied = 0
                        t.duration = 0
                        t.expires = 0
                        t.count = 0
                        t.caster = "nobody"
                    end,
                    copy = "starsurge_lunar"
                },

                starsurge_empowerment_solar = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment (Solar)"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = buff.eclipse_solar.expires - last
                            t.expires = t.applied + t.duration
                            t.count = 1
                            t.caster = "player"
                            return
                        end

                        t.applied = 0
                        t.duration = 0
                        t.expires = 0
                        t.count = 0
                        t.caster = "nobody"
                    end,
                    copy = "starsurge_solar"
                }
            }
        },


        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",

            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",

            ap_check = function() return check_for_ap_overcap( "stellar_flare" ) end,

            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },


        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -2,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",

            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,

            readyTime = function()
                return mana[ "time_to_" .. ( 0.12 * mana.max ) ]
            end,

            handler = function ()
                spend( 0.12 * mana.max, "mana" ) -- I want to see AP in mouseovers.
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
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
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },

        --[[ May want to revisit this and split out swipe_cat from swipe_bear.
        swipe_bear = {
            id = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,

            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { "swipe", 106785, 213771 },
            bind = { "swipe", "swipe_bear", "swipe_cat" }
        }, ]]


        thrash_bear = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,

            copy = { "thrash", 106832 },
            bind = { "thrash", "thrash_bear", "thrash_cat" }
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
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


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },


        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132145,

            handler = function ()
                shift( "treant_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "typhoon",

            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },


        ursols_vortex = {
            id = 102793,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "restoration_affinity",

            startsCombat = true,
            texture = 571588,

            handler = function ()
            end,
        },

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
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
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            -- texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
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

            talent = "wild_growth",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },


        wrath = {
            id = 190984,
            known = function () return state.spec.balance and IsPlayerSpell( 190984 ) or IsPlayerSpell( 5176 ) end,
            cast = function () return haste * ( buff.eclipse_solar.up and ( level > 46 and 0.8 or 0.92 ) or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up ) and -9 or -6 end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 535045,

            ap_check = function () return check_for_ap_overcap( "solar_wrath" ) end,

            velocity = 20,

            impact = function ()
                if not state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end
            end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end

                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,

            copy = { "solar_wrath", 5176 }
        },
    } )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageDots = true,
        damageExpiration = 6,

        enhancedRecheck = true,

        potion = "spectral_intellect",

        package = "Balance",
    } )


    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = "full"
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20220227, [[dmfk6fqikLEeIkDjeQYMiL(KsPgLc5ukuRsIKxHaMfIQUfPOSlk(fIsdtIYXifwgLINje10qG6AKISneQQVHqfJtiIZrkQADsempeK7je2Nsr)tIqvnqjcv5GkL0cLOQhIqzIKIkxerfBeHk9reivgjcKQoPevSsLcVuIqLzIOOBkri2Psj(PeH0qrG4OsekAPiqkpfqtvIuxvIkTvjcL(kcKmwef2Rq9xjnyIdt1IjvpwWKb6YqBwrFgrgTs1Pvz1sek8AeYSj52sy3I(nOHtjhxislxQNJ00v11vY2b47uQgpcQZlKwVerZxb7h1XAex6yGG(JXBXMYSXMYSXgIJPmnFzAQSijg4h1cJbA5bICsymW0lWyGL3vEgWyGwEuf0bJlDmqkC1bmg4()w0sGSKv3vEgqnJEfbdP73x6Mds2Y7kpdOMb8kigzlan7FHQe)5PWi0DLNb08e(JbQVo1xozSEmqq)X4Tytz2ytz2ydXXuMMVmcoYeCmqF97WogiWRGyXa3pqqmJ1JbcI0qmWY7kpdilAUEDG8gexuVxEhLfBioKNfBkZgB4n4ni2UNKqAjWBOzSSvqqeKfGqL3SuE0lm8gAgleB3tsiilV3KWVEtwcofPS8qwcrdkS(EtcFQH3qZyHGgwabGGSSYediL6Duwa4956kKYYOZGgYZIvJaQ03B6QjHSOzBYIvJam03B6QjHJn8gAglBfa8azXQXGt)ljXcbv7)ol3KL73MYYVJSyVHjjwiNG6SOOH3qZyPeXjczHyWeaKiKLFhzbO113tzXzrD)RqwkGnYYuHe(0vilJUjlrHlw2DWC7NL97z5EwOxXs9EIWfvfLf73VZs5lr3APzHaSqmuH0)CflBvDKYcmFYZY9BdYcLOZASH3qZyPeXjczPasFw2EEK2)AJf(L0TzHgW07dszXTSurz5HSOdPuwMhP9NYcmvrn8gAglLUr)zP0WcKf4KLYR8DwkVY3zP8kFNfNYIZc1cdNRy57ljcFdVHMXsjQfMyZYOZGgYZcbv7)o5zHGQ9FN8Sa89EEnoMLchezPa2ilnsp1H5ZYdzb9wDyZsawO7VMrFVFdVHMXcX9imlL4UeSrqwiNclODSlW8zjSJbIyzcBwiMMJLf1jHMyGQJ(04shdeAHj2XLoElAex6yGy66kemU8Xa9WFWmgO92)9yGGin0N1FWmgibPXGtFwSHfcQ2)Dw8eKfNfGV30vtczbMSaS0Sy)(Dw2YrA)zH46ilEcYs5HBT0SaBwa(EpVgzb(7yB)OymWqFp2NhdCelyqDwu0OwP31ej8ZYWalyqDwu0CzLcvEZYWalyqDwu0Czvh(7SmmWcguNffnEgTMiHFwgZIwwSAeGrdJ92)Dw0YITSy1iaJng7T)7XF8wSjU0XaX01viyC5Jb6H)Gzmq6798AmgyOVh7ZJbAll9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSmmWITSeGaW0Z3KhP9VoDKLHbwSLfQfQu13Bs4tn037PRuSeblAWYWal2YY7kmFt6)QrAv3vEgqdMUUcbzzyGLrSGb1zrrdfQ8UMiHFwggybdQZIIMlRQv6nlddSGb1zrrZLvD4VZYWalyqDwu04z0AIe(zzCmq1LynagdutXF8wICCPJbIPRRqW4Yhd0d)bZyG03751ymWqFp2NhdCel2YsVsCcBsOr3vEgWkCwDLQ(7xsIAW01viilddSyllbiam98n5rA)RthzzyGfBzHAHkv99Me(ud99E6kflrWIgSmmWITS8UcZ3K(VAKw1DLNb0GPRRqqwgZIwwSLfk(vDyUOM)W2MiPAJvGLHbwgXcguNffnuOY7AIe(zzyGfmOolkAUSQwP3SmmWcguNffnxw1H)olddSGb1zrrJNrRjs4NLXXavxI1aymqnf)XBHGJlDmqmDDfcgx(yGE4pygdK(EtxnjmgyOVh7ZJboILEL4e2KqJUR8mGv4S6kv93VKe1GPRRqqw0YsacatpFtEK2)60rw0Yc1cvQ67nj8Pg6790vkwIGfnyzmlAzXwwO4x1H5IA(dBBIKQnwHyGQlXAamgOMI)4pgiio9L6JlD8w0iU0Xa9WFWmgifQ8UQJErmqmDDfcgx(4pEl2ex6yGy66kemU8Xad99yFEmW)kqwielJyXgwkflE4pyAS3(VBco9R)vGSqaw8WFW0qFVNxJMGt)6FfilJJbs)(cF8w0igOh(dMXadUsv9WFWSQo6hduD0VMEbgdeAHj2XF8wICCPJbIPRRqW4YhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXaPwOsvFVjHp1qFVNUsXYMSOblAzzel2YY7kmFd99wbBqdMUUcbzzyGL3vy(g6JkL3vW(MVbtxxHGSmMLHbwOwOsvFVjHp1qFVNUsXYMSytmqqKg6Z6pygdei(uw2kKCybMSezcWI973HRNfW(MplEcYI973zb47Tc2GS4jil2qawG)o22pkgdeG310lWyGhT6qm(J3cbhx6yGy66kemU8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqQfQu13Bs4tn03751ilBYIgXabrAOpR)GzmqG4tzjOqhaYI9Dmzb4798AKLGNSSFpl2qawEVjHpLf77xyNLJYsJkeGNpltyZYVJSqob1zrrwEil6ilwnoXUrqw8eKf77xyNL5PuyZYdzj40pgiaVRPxGXapAnOqhag)XBrtXLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4Qfgd0QravsbqJgMcimNxJSmmWIvJaQKcGgnm0voVgzzyGfRgbujfanAyOV30vtczzyGfRgbujfanAyOV3txPyzyGfRgbujfanAyMRoAfoROALilddSy1iat7aWeUO1zJzjJYYWal6R50e86LbtJf(LuwIGf91CAcE9YGbC1(FWKLHbwa4956k0C0QdXyGGin0N1FWmgyjwVpxxHS87(Zsyhderz5MSefUyXBKLlzXzHuaKLhYIdaEGS87il07x(FWKf77yJS4S89LeHpl4hy5OSSOiilxYIo(2rmzj40NgdeG310lWyGxwjfaJ)4Tq8JlDmqmDDfcgx(yGE4pygduhBk2eDjPyGGin0N1FWmgy5srwkp2uSj6ssS4pl)oYcMGSaNSqCBmlzuwSVJjl7o9rwoklUoeaYcXVmIh5zXNp2SqmycaseYINGSa)DSTFuKf73VZcX2kzlNmedm03J95XahXYiwSLLaeaME(M8iT)1PJSmmWITSeGqfi0EAcWeaKiS(7yLAD99uZYILHbw6vItytcnbuH0)CvLAD99udMUUcbzzmlAzrFnNMGxVmyASWVKYYMSOHMyrll6R500oamHlAD2ywYOMgl8lPSqiwiyw0YITSeGaW0Z3aaZFpAZYWalbiam98naW83J2SOLf91CAcE9YGzzXIww0xZPPDaycx06SXSKrnllw0YYiw0xZPPDaycx06SXSKrnnw4xszHqrWIg2WIMXcbZsPyPxjoHnj0qVCUu19O0h7Zny66keKLHbw0xZPj41ldMgl8lPSqiw0qdwggyrdwilluluPQ7o9rwielAyi(SmMLXSOLfaEFUUcnxwjfaJ)4TqCIlDmqmDDfcgx(yGH(ESppg4iw0xZPj41ldMgl8lPSSjlAOjw0YYiwSLLEL4e2Kqd9Y5sv3JsFSp3GPRRqqwggyrFnNM2bGjCrRZgZsg10yHFjLfcXIgAEw0YI(AonTdat4IwNnMLmQzzXYywggyrhsPSOLL5rA)Rnw4xszHqSyJMyzmlAzbG3NRRqZLvsbWyGGin0N1FWmgibb(Sy)(DwCwi2wjB5Kbw(D)z5O52ploleKLI6nlwnmWcSzX(oMS87ilZJ0(ZYrzX1HRNLhYcMGXa9WFWmgOf8pyg)XBjsIlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgyapflJyzelZJ0(xBSWVKYIMXIgAIfnJLaeQaH2ttWRxgmnw4xszzmlKLfnIKYyzmlrWsapflJyzelZJ0(xBSWVKYIMXIgAIfnJLaeQaH2ttaMaGeH1FhRuRRVNAaxT)hmzrZyjaHkqO90eGjairy93Xk1667PMgl8lPSmMfYYIgrszSmMfTSyllTFGveaMVXbbPgKWh9PSOLLrSyllbiubcTNMGxVmyA0bJYYWal2YsacvGq7PjataqIqtJoyuwgZYWalbiubcTNMGxVmyASWVKYYMSC5JTfu5pcwNhP9V2yHFjLLHbw6vItytcnbuH0)CvLAD99udMUUcbzrllbiubcTNMGxVmyASWVKYYMSe5YyzyGLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYYMSC5JTfu5pcwNhP9V2yHFjLfnJfnkJLHbwSLLaeaME(M8iT)1PJXabrAOpR)GzmqI5QWs5pszX(o(7yZYIEjjwigmbajczjH2zX(PuS4kf0olrHlwEil0)ukwco9z53rwOEbYIxax5ZcCYcXGjairibi2wjB5Kbwco9PXab4Dn9cmgyaMaGeHvqKgndXF8w08XLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdCelV3KW38xbwFyf8qw2Kfn0elddS0(bwray(gheKAUKLnzrtLXYyw0YYiwgXcgPRZYcbnyHv0gDvf2GPNbKfTSmIfBzjabGPNVbaM)E0MLHbwcqOceApnyHv0gDvf2GPNb00yHFjLfcXIgeFIdleGLrSOjwkfl9kXjSjHg6LZLQUhL(yFUbtxxHGSmMLXSOLfBzjaHkqO90GfwrB0vvydMEgqtJoyuwgZYWalyKUolle0qHlLc))ss1EPhLfTSmIfBzjabGPNVjps7FD6ilddSeGqfi0EAOWLsH)FjPAV0JwJmbRPiPmnmnw4xszHqSOHgemlJzzyGLrSeGqfi0EA0XMInrxsY0OdgLLHbwSLL2dO5BOsXYWalbiam98n5rA)RthzzmlAzzel2YY7kmFZC1rRWzfvReny66keKLHbwcqay65BaG5VhTzrllbiubcTNM5QJwHZkQwjAASWVKYcHyrdnyHaSOjwkfl9kXjSjHg6LZLQUhL(yFUbtxxHGSmmWITSeGaW0Z3aaZFpAZIwwcqOceApnZvhTcNvuTs00yHFjLfcXI(AonbVEzWaUA)pyYcbyrdByPuS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSOzSOHnSmMfTSmILrSGr66SSqqZL0qVExxH1iD55VkQGiGlGSOLLaeQaH2tZL0qVExxH1iD55VkQGiGlGMgDWOSmMLHbwgXcgPRZYcbn0DheAhbRWwVcN1h2fy(SOLLaeQaH2tZd7cmFeSEj9iT)1iRjnfzB0W0yHFjLLXSmmWYiwgXcaVpxxHgywxuS(9LeHplrWIgSmmWcaVpxxHgywxuS(9LeHplrWsKzzmlAzzelFFjr4BEnmn6GrRbiubcTNSmmWY3xse(MxdtacvGq7PPXc)sklBYYLp2wqL)iyDEK2)AJf(Luw0mw0OmwgZYWala8(CDfAGzDrX63xse(Sebl2WIwwgXY3xse(M3gtJoy0AacvGq7jlddS89LeHV5TXeGqfi0EAASWVKYYMSC5JTfu5pcwNhP9V2yHFjLfnJfnkJLXSmmWcaVpxxHgywxuS(9LeHplrWszSmMLXSmogiisd9z9hmJbwUueKLhYciQ8OS87illQtczbozHyBLSLtgyX(oMSSOxsIfq4sxHSatwwuKfpbzXQray(SSOojKf77yYINS4GGSGaW8z5OS46W1ZYdzb8WyGa8UMEbgdmawdWe8(dMXF8w0OS4shdetxxHGXLpgi0kgif)yGE4pygdeG3NRRWyGaC1cJbAllu4sPFjO537tPQuejcBdMUUcbzzyGL5rA)Rnw4xszztwSPSYyzyGfDiLYIwwMhP9V2yHFjLfcXInAIfcWYiwi4YyrZyrFnNMFVpLQsrKiSn03deXsPyXgwgZYWal6R50879PuvkIeHTH(EGiw2KLihjSOzSmILEL4e2Kqd9Y5sv3JsFSp3GPRRqqwkfl2WY4yGGin0N1FWmgyjwVpxxHSSOiilpKfqu5rzXZOS89LeHpLfpbzjaszX(oMSy3V)ssSmHnlEYc5SS2H95Sy1WqmqaExtVaJb(79PuvkIeHD1UFF8hVfn0iU0XaX01viyC5JbcI0qFw)bZyGLlfzHCkSI2ORyPeTbtpdil2ugfduw0XjSrwCwi2wjB5KbwwuKfyZcfYYV7pl3ZI9tPyrDjYYYIf73VZYVJSGjilWjle3gZsgngy6fymqSWkAJUQcBW0Zagdm03J95XadqOceApnbVEzW0yHFjLfcXInLXIwwcqOceApnbycasew)DSsTU(EQPXc)skleIfBkJfTSmIfaEFUUcn)EFkvLIiryxT73ZYWal6R50879PuvkIeHTH(EGiw2KLixgleGLrS0ReNWMeAOxoxQ6Eu6J95gmDDfcYsPyjYSmMLXSOLfaEFUUcnxwjfazzyGfDiLYIwwMhP9V2yHFjLfcXsKjoXa9WFWmgiwyfTrxvHny6zaJ)4TOHnXLogiMUUcbJlFmqqKg6Z6pygdSCPilaHlLc)ljXcbTLEuwi(umqzrhNWgzXzHyBLSLtgyzrrwGnluil)U)SCpl2pLIf1LilllwSF)ol)oYcMGSaNSqCBmlz0yGPxGXaPWLsH)FjPAV0Jgdm03J95XahXsacvGq7Pj41ldMgl8lPSqiwi(SOLfBzjabGPNVbaM)E0MfTSyllbiam98n5rA)RthzzyGLaeaME(M8iT)1PJSOLLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYcHyH4ZIwwgXcaVpxxHMambajcRGinAgyzyGLaeQaH2ttWRxgmnw4xszHqSq8zzmlddSeGaW0Z3aaZFpAZIwwgXITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYIwwcqOceApnbVEzW0yHFjLfcXcXNLHbw0xZPPDaycx06SXSKrnnw4xszHqSOrzSqawgXIMyPuSGr66SSqqZL0VxHh20k4b4sSQJkflJzrll6R500oamHlAD2ywYOMLflJzzyGfDiLYIwwMhP9V2yHFjLfcXInAILHbwWiDDwwiOblSI2ORQWgm9mGSOLLaeQaH2tdwyfTrxvHny6zannw4xszztwSPmwgZIwwa4956k0CzLuaKfTSyllyKUolle0Cjn0R31vynsxE(RIkic4cilddSeGqfi0EAUKg6176kSgPlp)vrfebCb00yHFjLLnzXMYyzyGfDiLYIwwMhP9V2yHFjLfcXInLfd0d)bZyGu4sPW)VKuTx6rJ)4TOrKJlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgO(AonbVEzW0yHFjLLnzrdnXIwwgXITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYWal6R500oamHlAD2ywYOMgl8lPSqOiyrdnz0eleGLrSezJMyPuSOVMtJUccbvl6BwwSmMfcWYiwiyJMyrZyjYgnXsPyrFnNgDfecQw03SSyzmlLIfmsxNLfcAUK(9k8WMwbpaxIvDuPyrll6R500oamHlAD2ywYOMLflJzzyGfDiLYIwwMhP9V2yHFjLfcXInAILHbwWiDDwwiOblSI2ORQWgm9mGSOLLaeQaH2tdwyfTrxvHny6zannw4xsJbcI0qFw)bZyGBvz3JszzrrwkNsm1CSy)(Dwi2wjB5KbwGnl(ZYVJSGjilWjle3gZsgngiaVRPxGXaVifSgGj49hmJ)4TObbhx6yGy66kemU8Xa9WFWmg4L0qVExxH1iD55VkQGiGlGXad99yFEmqaEFUUcnxKcwdWe8(dMSOLfaEFUUcnxwjfaJbMEbgd8sAOxVRRWAKU88xfvqeWfW4pElAOP4shdetxxHGXLpgiisd9z9hmJbwUuKfG7oi0ocYsjARZIooHnYcX2kzlNmedm9cmgiD3bH2rWkS1RWz9HDbMFmWqFp2NhdCelbiubcTNMGxVmyA0bJYIwwSLLaeaME(M8iT)1PJSOLfaEFUUcn)EFkvLIiryxT73ZIwwgXsacvGq7PrhBk2eDjjtJoyuwggyXwwApGMVHkflJzzyGLaeaME(M8iT)1PJSOLLaeQaH2ttaMaGeH1FhRuRRVNAA0bJYIwwgXcaVpxxHMambajcRGinAgyzyGLaeQaH2ttWRxgmn6GrzzmlJzrllGW3qx58A08xGOljXIwwgXci8n0hvkVRtL3O5VarxsILHbwSLL3vy(g6JkL31PYB0GPRRqqwggyHAHkv99Me(ud99EEnYYMSezwgZIwwaHVPacZ51O5VarxsIfTSmIfaEFUUcnhT6qKLHbw6vItytcn6UYZawHZQRu1F)ssudMUUcbzzyGfN(TRQwq7yZYMrWIMVmwggybG3NRRqtaMaGeHvqKgndSmmWI(Aon6kieuTOVzzXYyw0YITSGr66SSqqZL0qVExxH1iD55VkQGiGlGSmmWcgPRZYcbnxsd96DDfwJ0LN)QOcIaUaYIwwcqOceApnxsd96DDfwJ0LN)QOcIaUaAASWVKYYMSe5Yyrll2YI(AonbVEzWSSyzyGfDiLYIwwMhP9V2yHFjLfcXcbxwmqp8hmJbs3DqODeScB9kCwFyxG5h)XBrdIFCPJbIPRRqW4YhdeePH(S(dMXal9(rz5OS4S0(VJnlOY1HT)il29OS8qwkCIqwCLIfyYYIISqF)z57ljcFklpKfDKf1LiilllwSF)oleBRKTCYalEcYcXGjairilEcYYIIS87il2KGSqvWNfyYsaKLBYIo83z57ljcFklEJSatwwuKf67plFFjr4tJbg67X(8yGJybG3NRRqdmRlkw)(sIWNfBJGfnyrll2YY3xse(M3gtJoy0AacvGq7jlddSmIfaEFUUcnWSUOy97ljcFwIGfnyzyGfaEFUUcnWSUOy97ljcFwIGLiZYyw0YYiw0xZPj41ldMLflAzzel2YsacatpFdam)9OnlddSOVMtt7aWeUO1zJzjJAASWVKYcbyzelr2Ojwkfl9kXjSjHg6LZLQUhL(yFUbtxxHGSmMfcfblFFjr4BEnm6R5ScUA)pyYIww0xZPPDaycx06SXSKrnllwggyrFnNM2bGjCrRZgZsgTsVCUu19O0h7ZnllwgZYWalbiubcTNMGxVmyASWVKYcbyXgw2KLVVKi8nVgMaeQaH2td4Q9)GjlAzXww0xZPj41ldMLflAzzel2YsacatpFtEK2)60rwggyXwwa4956k0eGjairyfePrZalJzrll2YsacatpFdrr7ZtwggyjabGPNVjps7FD6ilAzbG3NRRqtaMaGeHvqKgndSOLLaeQaH2ttaMaGeH1FhRuRRVNAwwSOLfBzjaHkqO90e86LbZYIfTSmILrSOVMtdguNffRQv6TPXc)sklBYIgLXYWal6R50Gb1zrXkfQ820yHFjLLnzrJYyzmlAzXww6vItytcn6UYZawHZQRu1F)ssudMUUcbzzyGLrSOVMtJUR8mGv4S6kv93VKeTM(VA0qFpqelrWIMyzyGf91CA0DLNbScNvxPQ)(LKOvVdEIg67bIyjcwIewgZYywggyrFnNgIUeSrWkwybTJDbMFftSjDLenllwgZYWal6qkLfTSmps7FTXc)skleIfBkJLHbwa4956k0aZ6II1VVKi8zjcwkJLXSOLfaEFUUcnxwjfaJbsvWNgd87ljcFnIb6H)GzmWVVKi81i(J3IgeN4shdetxxHGXLpgOh(dMXa)(sIW3MyGH(ESppg4iwa4956k0aZ6II1VVKi8zX2iyXgw0YITS89LeHV51W0OdgTgGqfi0EYYWala8(CDfAGzDrX63xse(Sebl2WIwwgXI(AonbVEzWSSyrllJyXwwcqay65BaG5VhTzzyGf91CAAhaMWfToBmlzutJf(LuwialJyjYgnXsPyPxjoHnj0qVCUu19O0h7Zny66keKLXSqOiy57ljcFZBJrFnNvWv7)btw0YI(AonTdat4IwNnMLmQzzXYWal6R500oamHlAD2ywYOv6LZLQUhL(yFUzzXYywggyjaHkqO90e86LbtJf(Luwial2WYMS89LeHV5TXeGqfi0EAaxT)hmzrll2YI(AonbVEzWSSyrllJyXwwcqay65BYJ0(xNoYYWal2YcaVpxxHMambajcRGinAgyzmlAzXwwcqay65BikAFEYIwwgXITSOVMttWRxgmllwggyXwwcqay65BaG5VhTzzmlddSeGaW0Z3KhP9VoDKfTSaW7Z1vOjataqIWkisJMbw0YsacvGq7PjataqIW6VJvQ113tnllw0YITSeGqfi0EAcE9YGzzXIwwgXYiw0xZPbdQZIIv1k920yHFjLLnzrJYyzyGf91CAWG6SOyLcvEBASWVKYYMSOrzSmMfTSyll9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSmmWYiw0xZPr3vEgWkCwDLQ(7xsIwt)xnAOVhiILiyrtSmmWI(Aon6UYZawHZQRu1F)ss0Q3bprd99arSeblrclJzzmlJzzyGf91CAi6sWgbRyHf0o2fy(vmXM0vs0SSyzyGfDiLYIwwMhP9V2yHFjLfcXInLXYWala8(CDfAGzDrX63xse(SeblLXYyw0YcaVpxxHMlRKcGXaPk4tJb(9LeHVnXF8w0isIlDmqmDDfcgx(yGGin0N1FWmgy5srklUsXc83XMfyYYIISCpwqzbMSeaJb6H)GzmWffR3Jf04pElAO5JlDmqmDDfcgx(yGGin0N1FWmgi5C)o2SqcYYLpKLFhzH(SaBwCiYIh(dMSOo6hd0d)bZyG9kRE4pywvh9Jbs)(cF8w0igyOVh7ZJbcW7Z1vO5OvhIXavh9RPxGXaDig)XBXMYIlDmqmDDfcgx(yGE4pygdSxz1d)bZQ6OFmq1r)A6fymq6h)XFmqRgdWcD)JlD8w0iU0Xa9WFWmgirxc2iyLAD990yGy66kemU8XF8wSjU0XaX01viyC5JbcTIbsXpgOh(dMXab4956kmgiaxTWyGLfdeePH(S(dMXal9oYcaVpxxHSCuwO4ZYdzPmwSF)oljKf67plWKLffz57ljcFk5zrdwSVJjl)oYY8A6ZcmrwoklWKLffjpl2WYnz53rwOyaMGSCuw8eKLiZYnzrh(7S4ngdeG310lWyGWSUOy97ljc)4pElroU0XaX01viyC5JbcTIb6GGXa9WFWmgiaVpxxHXab4QfgduJyGH(ESppg43xse(MxdZUtRlkw1xZjlAz57ljcFZRHjaHkqO90aUA)pyYIwwSLLVVKi8nVgMJAEybwHZAbmPFdx0AaM0VxH)GjngiaVRPxGXaHzDrX63xse(XF8wi44shdetxxHGXLpgi0kgOdcgd0d)bZyGa8(CDfgdeGRwymqBIbg67X(8yGFFjr4BEBm7oTUOyvFnNSOLLVVKi8nVnMaeQaH2td4Q9)GjlAzXww((sIW382yoQ5HfyfoRfWK(nCrRbys)Ef(dM0yGa8UMEbgdeM1ffRFFjr4h)XBrtXLogiMUUcbJlFmqOvmqhemgOh(dMXab4956kmgiaVRPxGXaHzDrX63xse(Xad99yFEmqmsxNLfcAUKg6176kSgPlp)vrfebCbKLHbwWiDDwwiOblSI2ORQWgm9mGSmmWcgPRZYcbnu4sPW)VKuTx6rJbcI0qFw)bZyGLEhPilFFjr4tzXBKLe(S4Rhw4)fCLkklG4JHhbzXPSatwwuKf67plFFjr4tnSWcq8zbG3NRRqwEilemloLLFhJYIROqwsebzHAHHZvSS7jO6ssMyGaC1cJbsWXF8wi(XLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdmYLXsPyzelAWIMXszgByPuSqXVQdZf18h22ejvc2kWY4yGGin0N1FWmgiq8PS87ilaFVPRMeYsasFwMWMfL)yZsWvHLY)dMuwgnHnliH9clfYI9Dmz5HSqFVFwaxfwxsIfDCcBKfIBJzjJYY0vkklW5CCmqaExtVaJbsP1aK(XF8wioXLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdmYLXcbyrJYyPuS0ReNWMeAcOcP)5Qk1667PgmDDfcgdeePH(S(dMXabIpLf)zX((f2zXlGR8zbozzRuccledMaGeHSq3Hlfil6illkcwcSqWLXI973HRNfIHkK(NRybO113tzXtqwICzSy)(DtmqaExtVaJbgGjairy1PwXF8wIK4shd0d)bZyGfqys0L1jSlIbIPRRqW4Yh)XBrZhx6yGy66kemU8Xa9WFWmgO92)9yGH(ESppg4iwWG6SOOrTsVRjs4NLHbwWG6SOO5YkfQ8MLHbwWG6SOO5YQo83zzyGfmOolkA8mAnrc)SmogO6sSgaJbQrzXF8hd0HyCPJ3IgXLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdSxjoHnj08xbAh2zfSrVq)sqSny66keKfTSmIf91CA(RaTd7Sc2OxOFji2Mgl8lPSqiwifanfoHzHaSuMrdwggyrFnNM)kq7WoRGn6f6xcITPXc)skleIfp8hmn03751Objmgwpw)RazHaSuMrdw0YYiwWG6SOO5YQALEZYWalyqDwu0qHkVRjs4NLHbwWG6SOOXZO1ej8ZYywgZIww0xZP5Vc0oSZkyJEH(LGyBwwXabrAOpR)GzmqI5QWs5pszX(o(7yZYVJSO5A0lc(h2XMf91CYI9tPyz6kflW5Kf73VFjl)oYsIe(zj40pgiaVRPxGXabB0lQ2pLQoDLQcNZ4pEl2ex6yGy66kemU8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqBzbdQZIIMlRuOYBw0Yc1cvQ67nj8Pg6798AKLnzH4WIMXY7kmFdfUuv4S(7yDcBK(gmDDfcYsPyXgwialyqDwu0Czvh(7SOLfBzPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzrll2YsVsCcBsObM4VtRbf6DfWrpyAW01viymqqKg6Z6pygdKyUkSu(JuwSVJ)o2Sa89MUAsilhLf7W(3zj40)ssSabGnlaFVNxJSCjlK5k9MfYjOolkgdeG310lWyGhPe2yL(Etxnjm(J3sKJlDmqmDDfcgx(yGE4pygdmataqIW6VJvQ113tJbcI0qFw)bZyGLlfzHyWeaKiKf77yYI)SOqkLLF3tw0uzSSvkbHfpbzrDjYYYIf73VZcX2kzlNmedm03J95XaTLfWEDGMewdGuw0YYiwgXcaVpxxHMambajcRGinAgyrll2YsacvGq7Pj41ldMgDWOSmmWI(AonbVEzWSSyzmlAzzel6R50Gb1zrXQALEBASWVKYYMSOjwggyrFnNgmOolkwPqL3Mgl8lPSSjlAILXSOLLrS40VDv1cAhBwielAQmw0YYiwOwOsvFVjHp1qFVNxJSSjlrMLHbw0xZPj41ldMLflJzzyGfBzPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzzmlAzzel2YY7kmFd9rLY7kyFZ3GPRRqqwggyrFnNg6790vktJf(LuwielAy0elAglLz0elLILEL4e2Kqtavi9pxvPwxFp1GPRRqqwggyrFnNMGxVmyASWVKYcHyrFnNg6790vktJf(LuwialAIfTSOVMttWRxgmllwgZIwwgXITS0ReNWMeA0DLNbScNvxPQ)(LKOgmDDfcYYWal6R50O7kpdyfoRUsv)9ljrRP)Rgn03deXYMSezwggyrFnNgDx5zaRWz1vQ6VFjjA17GNOH(EGiw2KLiZYywggyrhsPSOLL5rA)Rnw4xszHqSOrzSOLLaeQaH2ttWRxgmnw4xszztw0elJJ)4TqWXLogiMUUcbJlFmqp8hmJbsx58AmgyiAqH13Bs4tJ3IgXad99yFEmWrS04Sr6URRqwggyrFnNgmOolkwPqL3Mgl8lPSqiwImlAzbdQZIIMlRuOYBw0YsJf(LuwielAqWSOLL3vy(gkCPQWz93X6e2i9ny66keKLXSOLL3Bs4B(RaRpScEilBYIgemlAgluluPQV3KWNYcbyPXc)sklAzzelyqDwu0Cz1ZOSmmWsJf(LuwielKcGMcNWSmogiisd9z9hmJbwUuKfGRCEnYYLSy5jiwCbwGjlEg93VKel)U)SOoaiLfniykgOS4jilkKszX(97SuaBKL3Bs4tzXtqw8NLFhzbtqwGtwCwacvEZc5euNffzXFw0GGzHIbklWMffsPS0yHF5LKyXPS8qws4ZYUd4ssS8qwAC2iDNfWvFjjwiZv6nlKtqDwum(J3IMIlDmqmDDfcgx(yGE4pygdKUY51ymqqKg6Z6pygdSCPilax58AKLhYYUdazXzHKcQ7kwEillkYs5uIPMlgyOVh7ZJbcW7Z1vO5IuWAaMG3FWKfTSeGqfi0EAUKg6176kSgPlp)vrfebCb00OdgLfTSGr66SSqqZL0qVExxH1iD55VkQGiGlGSOLf3Qg2XarXF8wi(XLogiMUUcbJlFmqp8hmJbsFVNUsfdeePH(S(dMXalXHOflllwa(EpDLIf)zXvkw(RaPSSsfsPSSOxsIfYmAWBNYINGSCplhLfxhUEwEilwnmWcSzrHpl)oYc1cdNRyXd)btwuxISOJkODw29euHSO5A0l0VeeBwGjl2WY7nj8PXad99yFEmqBz5DfMVH(Os5DfSV5BW01viilAzzel2Ycf)QomxuZFyBtKujyRalddSGb1zrrZLvpJYYWaluluPQV3KWNAOV3txPyztwImlJzrllJyrFnNg6790vktJZgP7UUczrllJyHAHkv99Me(ud99E6kfleILiZYWal2YsVsCcBsO5Vc0oSZkyJEH(LGyBW01viilJzzyGL3vy(gkCPQWz93X6e2i9ny66keKfTSOVMtdguNffRuOYBtJf(LuwielrMfTSGb1zrrZLvku5nlAzrFnNg6790vktJf(Luwielehw0Yc1cvQ67nj8Pg6790vkw2mcwiywgZIwwgXITS0ReNWMeAurdE706uH4FjPkj1vyrrdMUUcbzzyGL)kqwiESqWAILnzrFnNg6790vktJf(Luwial2WYyw0YY7nj8n)vG1hwbpKLnzrtXF8wioXLogiMUUcbJlFmqp8hmJbsFVNUsfdeePH(S(dMXajOUFNfGpQuEZIMRV5ZYIISatwcGSyFhtwAC2iD31vil6RNf6Fkfl297zzcBwiZObVDklwnmWINGSacZTFwwuKfDCcBKfIP5Ogwa(NsXYIISOJtyJSqmycaseYc9YaYYV7pl2pLIfRggyXt4VJnlaFVNUsfdm03J95XaFxH5BOpQuExb7B(gmDDfcYIww0xZPH(EpDLY04Sr6URRqw0YYiwSLfk(vDyUOM)W2MiPsWwbwggybdQZIIMlREgLLHbwOwOsvFVjHp1qFVNUsXYMSqWSmMfTSmIfBzPxjoHnj0OIg82P1PcX)ssvsQRWIIgmDDfcYYWal)vGSq8yHG1elBYcbZYyw0YY7nj8n)vG1hwbpKLnzjYXF8wIK4shdetxxHGXLpgOh(dMXaPV3txPIbcI0qFw)bZyGeu3VZIMRrVq)sqSzzrrwa(EpDLILhYcriAXYYILFhzrFnNSOhLfxrHSSOxsIfGV3txPybMSOjwOyaMGuwGnlkKszPXc)Yljfdm03J95Xa7vItytcn)vG2HDwbB0l0VeeBdMUUcbzrlluluPQV3KWNAOV3txPyzZiyjYSOLLrSyll6R508xbAh2zfSrVq)sqSnllw0YI(Aon037PRuMgNns3DDfYYWalJybG3NRRqdyJEr1(Pu1PRuv4CYIwwgXI(Aon037PRuMgl8lPSqiwImlddSqTqLQ(EtcFQH(EpDLILnzXgw0YY7kmFd9rLY7kyFZ3GPRRqqw0YI(Aon037PRuMgl8lPSqiw0elJzzmlJJ)4TO5JlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgOt)2vvlODSzztwIKYyPuSmIfnyrZyHIFvhMlQ5pSTjsQ2yfyPuSuMXgwgZsPyzelAWIMXI(Aon)vG2HDwbB0l0VeeBd99arSukwkZOblJzrZyzel6R50qFVNUszASWVKYsPyjYSqwwOwOsv3D6JSukwSLL3vy(g6JkL3vW(MVbtxxHGSmMfnJLrSeGqfi0EAOV3txPmnw4xszPuSezwilluluPQ7o9rwkflVRW8n0hvkVRG9nFdMUUcbzzmlAglJyrFnNM5QJwHZkQwjAASWVKYsPyrtSmMfTSmIf91CAOV3txPmllwggyjaHkqO90qFVNUszASWVKYY4yGGin0N1FWmgiXCvyP8hPSyFh)DSzXzb47nD1KqwwuKf7NsXsWxuKfGV3txPy5HSmDLIf4CsEw8eKLffzb47nD1KqwEileHOflAUg9c9lbXMf67bIyzzzyjskJLJYYVJS0yKUUgbzzRucclpKLGtFwa(EtxnjKaaFVNUsfdeG310lWyG037PRuv7W8RtxPQW5m(J3IgLfx6yGy66kemU8Xa9WFWmgi99MUAsymqqKg6Z6pygdSCPilaFVPRMeYI973zrZ1OxOFji2S8qwicrlwwwS87il6R5Kf73Vdxplki9ssSa89E6kfllR)kqw8eKLffzb47nD1KqwGjlembyP8WTwAwOVhiIYYk)tXcbZY7nj8PXad99yFEmqaEFUUcnGn6fv7NsvNUsvHZjlAzbG3NRRqd99E6kv1om)60vQkCozrll2YcaVpxxHMJucBSsFVPRMeYYWalJyrFnNgDx5zaRWz1vQ6VFjjAn9F1OH(EGiw2KLiZYWal6R50O7kpdyfoRUsv)9ljrREh8en03deXYMSezwgZIwwOwOsvFVjHp1qFVNUsXcHyHGzrlla8(CDfAOV3txPQ2H5xNUsvHZz8hVfn0iU0XaX01viyC5Jb6H)Gzmqh0T(dawP29UigyiAqH13Bs4tJ3IgXad99yFEmqBz5VarxsIfTSyllE4pyACq36payLA37IkOx4KqZL1P6iT)SmmWci8noOB9haSsT7Drf0lCsOH(EGiwielrMfTSacFJd6w)baRu7Exub9cNeAASWVKYcHyjYXabrAOpR)GzmWYLISqT7Dbluil)U)SefUyHe(Su4eMLL1Ffil6rzzrVKel3ZItzr5pYItzXcsPNUczbMSOqkLLF3twIml03derzb2SuIXI(SyFhtwImbyH(EGikliHTUgJ)4TOHnXLogiMUUcbJlFmqp8hmJbwaH58AmgyiAqH13Bs4tJ3IgXad99yFEmWgNns3DDfYIwwEVjHV5VcS(Wk4HSSjlJyzelAqWSqawgXc1cvQ67nj8Pg6798AKLsXInSukw0xZPbdQZIIv1k92SSyzmlJzHaS0yHFjLLXSqwwgXIgSqawExH5BE7xwlGWKAW01viilJzrllJyXTQHDmqelddSaW7Z1vO5iLWgR03B6QjHSmmWITSGb1zrrZLvpJYYyw0YYiwcqOceApnbVEzW0OdgLfTSGb1zrrZLvpJYIwwSLfWEDGMewdGuw0YYiwa4956k0eGjairyfePrZalddSeGqfi0EAcWeaKiS(7yLAD99utJoyuwggyXwwcqay65BYJ0(xNoYYywggyHAHkv99Me(ud99EEnYcHyzelJyH4ZIMXYiw0xZPbdQZIIv1k92SSyPuSydlJzzmlLILrSObleGL3vy(M3(L1cimPgmDDfcYYywgZIwwSLfmOolkAOqL31ej8ZIwwSLLaeQaH2ttWRxgmn6GrzzyGLrSGb1zrrZLvku5nlddSOVMtdguNffRQv6TzzXIwwSLL3vy(gkCPQWz93X6e2i9ny66keKLHbw0xZPXQVcydEUQ6DWZluTwkQ3gaUAHSSzeSyJMkJLXSOLLrSqTqLQ(EtcFQH(EpVgzHqSOrzSukwgXIgSqawExH5BE7xwlGWKAW01viilJzzmlAzXPF7QQf0o2SSjlAQmw0mw0xZPH(EpDLY0yHFjLLsXcXNLXSOLLrSyllbiam98nefTppzzyGfBzrFnNgIUeSrWkwybTJDbMFftSjDLenllwggybdQZIIMlRuOYBwgZIwwSLf91CAAhaMWfToBmlz0k9Y5sv3JsFSp3SSIbcI0qFw)bZyGe0WzJ0DwkrGWCEnYYnzHyBLSLtgy5OS0OdgL8S87yJS4nYIcPuw(DpzrtS8EtcFklxYczUsVzHCcQZIISy)(DwacFIl5zrHukl)UNSOrzSa)DSTFuKLlzXZOSqob1zrrwGnlllwEilAIL3Bs4tzrhNWgzXzHmxP3Sqob1zrrdlAoyU9ZsJZgP7SaU6ljXsjUlbBeKfYPWcAh7cmFwwPcPuwUKfGqL3Sqob1zrX4pElAe54shdetxxHGXLpgOh(dMXaNWoGv4SM(VAmgiisd9z9hmJbwUuKfIlClSatwcGSy)(D46zj4wwxskgyOVh7ZJb6w1WogiILHbwa4956k0CKsyJv67nD1KW4pElAqWXLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4Qfgd0wwa71bAsynaszrllJybG3NRRqtaSgGj49hmzrllJyrFnNg6790vkZYILHbwExH5BOpQuExb7B(gmDDfcYYWalbiam98n5rA)RthzzmlAzbe(McimNxJM)ceDjjw0YYiwSLf91CAOqf9VaAwwSOLfBzrFnNMGxVmywwSOLLrSyllVRW8nZvhTcNvuTs0GPRRqqwggyrFnNMGxVmyaxT)hmzztwcqOceApnZvhTcNvuTs00yHFjLfcWsKWYyw0YYiwSLfk(vDyUOM)W2MiPAJvGLHbwWG6SOO5YQALEZYWalyqDwu0qHkVRjs4NLXSOLfaEFUUcn)EFkvLIiryxT73ZIwwgXITSeGaW0Z3KhP9VoDKLHbwcqOceApnbycasew)DSsTU(EQPXc)skleIf91CAcE9YGbC1(FWKLsXszgnXYyw0YY7nj8n)vG1hwbpKLnzrFnNMGxVmyaxT)hmzPuSuMH4WYywggyrhsPSOLL5rA)Rnw4xszHqSOVMttWRxgmGR2)dMSqaw0Wgwkfl9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viilJJbcW7A6fymWaynatW7pywDig)XBrdnfx6yGy66kemU8Xa9WFWmgy7aWeUO1zJzjJgdeePH(S(dMXalxkYcXTXSKrzX(97SqSTs2YjdXad99yFEmq91CAcE9YGPXc)sklBYIgAILHbw0xZPj41ldgWv7)btwialAydlLILEL4e2KqJvFfWg8Cv17GNxOATuuVny66keKfcXIneFw0YcaVpxxHMaynatW7pywDig)XBrdIFCPJbIPRRqW4Yhd0d)bZyGbuH0)Cv1vhPSaZpgiisd9z9hmJbwUuKfITvYwozGfyYsaKLvQqkLfpbzrDjYY9SSSyX(97Sqmycasegdm03J95Xab4956k0eaRbycE)bZQdrw0YYiw0xZPj41ldgWv7)btwialAydlLILEL4e2KqJvFfWg8Cv17GNxOATuuVny66keKLnJGfBi(SmmWITSeGaW0Z3aaZFpAZYywggyrFnNM2bGjCrRZgZsg1SSyrll6R500oamHlAD2ywYOMgl8lPSqiw08SqawcWeCDVXQXWrXQRoszbMV5VcScWvlKfcWYiwSLf91CA0vqiOArFZYIfTSyllVRW8n03BfSbny66keKLXXF8w0G4ex6yGy66kemU8Xad99yFEmqaEFUUcnbWAaMG3FWS6qmgOh(dMXaVm4D6)bZ4pElAejXLogiMUUcbJlFmqp8hmJbIfwq7yx1HjymqqKg6Z6pygdSCPilKtHf0o2SuEycYcmzjaYI973zb4790vkwwwS4jiluhaYYe2SqqwkQ3S4jileBRKTCYqmWqFp2NhdCelbiubcTNMGxVmyASWVKYcbyrFnNMGxVmyaxT)hmzHaS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSukw0Wgw2KLaeQaH2tdwybTJDvhMGgWv7)btwialAuglJzzyGf91CAcE9YGPXc)sklBYsKWYWalG96anjSgaPXF8w0qZhx6yGy66kemU8Xa9WFWmgi9rLY76u5ngdmenOW67nj8PXBrJyGH(ESppgyJZgP7UUczrll)vG1hwbpKLnzrdnXIwwOwOsvFVjHp1qFVNxJSqiwiyw0YIBvd7yGiw0YYiw0xZPj41ldMgl8lPSSjlAuglddSyll6R50e86LbZYILXXabrAOpR)GzmqcA4Sr6oltL3ilWKLLflpKLiZY7nj8PSy)(D46zHyBLSLtgyrhVKelUoC9S8qwqcBDnYINGSKWNfiaSdUL1LKI)4TytzXLogiMUUcbJlFmqp8hmJboxD0kCwr1kXyGGin0N1FWmgy5srwiUqYHLBYYL0dezXtwiNG6SOilEcYI6sKL7zzzXI973zXzHGSuuVzXQHbw8eKLTc6w)bazbODVlIbg67X(8yGyqDwu0Cz1ZOSOLLrS4w1WogiILHbwSLLEL4e2KqJvFfWg8Cv17GNxOATuuVny66keKLXSOLLrSOVMtJvFfWg8Cv17GNxOATuuVnaC1czHqSyJMkJLHbw0xZPj41ldMgl8lPSSjlrclJzrllJybe(gh0T(dawP29UOc6foj08xGOljXYWal2YsacatpFtIHgQGnilddSqTqLQ(EtcFklBYInSmMfTSmIf91CAAhaMWfToBmlzutJf(LuwielAEw0mwgXcbZsPyPxjoHnj0qVCUu19O0h7Zny66keKLXSOLf91CAAhaMWfToBmlzuZYILHbwSLf91CAAhaMWfToBmlzuZYILXSOLLrSyllbiubcTNMGxVmywwSmmWI(Aon)EFkvLIiryBOVhiIfcXIgAIfTSmps7FTXc)skleIfBkRmw0YY8iT)1gl8lPSSjlAuwzSmmWITSqHlL(LGMFVpLQsrKiSny66keKLXSOLLrSqHlL(LGMFVpLQsrKiSny66keKLHbwcqOceApnbVEzW0yHFjLLnzjYLXYyw0YY7nj8n)vG1hwbpKLnzrtSmmWIoKszrllZJ0(xBSWVKYcHyrJYI)4TyJgXLogiMUUcbJlFmqp8hmJbsFVNUsfdeePH(S(dMXalxkYIZcW37PRuSuIM4VZIvddSSsfsPSa89E6kflhLfx1OdgLLLflWMLOWflEJS46W1ZYdzbca7GBXYwPeKyGH(ESppgO(AonWe)DA1c7aA9hmnllw0YYiw0xZPH(EpDLY04Sr6URRqwggyXPF7QQf0o2SSjlA(YyzC8hVfBSjU0XaX01viyC5Jb6H)Gzmq6790vQyGGin0N1FWmgOMBvyXYwPeew0XjSrwigmbajczX(97Sa89E6kflEcYYVJjlaFVPRMegdm03J95Xadqay65BYJ0(xNoYIwwSLL3vy(g6JkL3vW(MVbtxxHGSOLLrSaW7Z1vOjataqIWkisJMbwggyjaHkqO90e86LbZYILHbw0xZPj41ldMLflJzrllbiubcTNMambajcR)owPwxFp10yHFjLfcXcPaOPWjmlLILaEkwgXIt)2vvlODSzHSSOPYyzmlAzrFnNg6790vktJf(LuwielemlAzXwwa71bAsynasJ)4TytKJlDmqmDDfcgx(yGH(ESppgyacatpFtEK2)60rw0YYiwa4956k0eGjairyfePrZalddSeGqfi0EAcE9YGzzXYWal6R50e86LbZYILXSOLLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYcHyrtSOLfaEFUUcn037PRuv7W8RtxPQW5KfTSGb1zrrZLvpJYIwwSLfaEFUUcnhPe2yL(EtxnjKfTSyllG96anjSgaPXa9WFWmgi99MUAsy8hVfBi44shdetxxHGXLpgOh(dMXaPV30vtcJbcI0qFw)bZyGLlfzb47nD1KqwSF)olEYsjAI)olwnmWcSz5MSefU2gKfiaSdUflBLsqyX(97SefUAwsKWplbN(gw2QIczbCvyXYwPeew8NLFhzbtqwGtw(DKLsSy(7rBw0xZjl3KfGV3txPyXoCPaZTFwMUsXcCozb2SefUyXBKfyYInS8EtcFAmWqFp2NhduFnNgyI)oTguO3vah9GPzzXYWalJyXwwOV3ZRrJBvd7yGiw0YITSaW7Z1vO5iLWgR03B6QjHSmmWYiw0xZPj41ldMgl8lPSqiw0elAzrFnNMGxVmywwSmmWYiwgXI(AonbVEzW0yHFjLfcXcPaOPWjmlLILaEkwgXIt)2vvlODSzHSSaW7Z1vOHsRbi9zzmlAzrFnNMGxVmywwSmmWI(AonTdat4IwNnMLmALE5CPQ7rPp2NBASWVKYcHyHua0u4eMLsXsapflJyXPF7QQf0o2Sqwwa4956k0qP1aK(SmMfTSOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95MLflJzrllbiam98naW83J2SmMLXSOLLrSqTqLQ(EtcFQH(EpDLIfcXsKzzyGfaEFUUcn037PRuv7W8RtxPQW5KLXSmMfTSylla8(CDfAosjSXk99MUAsilAzzel2YsVsCcBsO5Vc0oSZkyJEH(LGyBW01viilddSqTqLQ(EtcFQH(EpDLIfcXsKzzC8hVfB0uCPJbIPRRqW4Yhd0d)bZyGjAVwaHzmqqKg6Z6pygdSCPilLiqysz5swacvEZc5euNffzXtqwOoaKfI7sPyPebctwMWMfITvYwozigyOVh7ZJboIf91CAWG6SOyLcvEBASWVKYYMSGegdRhR)vGSmmWYiwc7EtcPSebl2WIwwAmS7njS(xbYcHyrtSmMLHbwc7EtcPSeblrMLXSOLf3Qg2XarXF8wSH4hx6yGy66kemU8Xad99yFEmWrSOVMtdguNffRuOYBtJf(Luw2KfKWyy9y9VcKLHbwgXsy3BsiLLiyXgw0YsJHDVjH1)kqwielAILXSmmWsy3BsiLLiyjYSmMfTS4w1WogiIfTSmIf91CAAhaMWfToBmlzutJf(LuwielAIfTSOVMtt7aWeUO1zJzjJAwwSOLfBzPxjoHnj0qVCUu19O0h7Zny66keKLHbwSLf91CAAhaMWfToBmlzuZYILXXa9WFWmg4URM1cimJ)4TydXjU0XaX01viyC5Jbg67X(8yGJyrFnNgmOolkwPqL3Mgl8lPSSjliHXW6X6FfilAzzelbiubcTNMGxVmyASWVKYYMSOPYyzyGLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYYMSOPYyzmlddSmILWU3KqklrWInSOLLgd7EtcR)vGSqiw0elJzzyGLWU3KqklrWsKzzmlAzXTQHDmqelAzzel6R500oamHlAD2ywYOMgl8lPSqiw0elAzrFnNM2bGjCrRZgZsg1SSyrll2YsVsCcBsOHE5CPQ7rPp2NBW01viilddSyll6R500oamHlAD2ywYOMLflJJb6H)GzmW5sPQfqyg)XBXMijU0XaX01viyC5JbcI0qFw)bZyGLlfzHGcsoSatwiMMlgOh(dMXaT7DFWUcNvuTsm(J3InA(4shdetxxHGXLpgi0kgif)yGE4pygdeG3NRRWyGaC1cJbsTqLQ(EtcFQH(EpVgzztwiywialtfe2SmILcN(yhTcWvlKLsXIgLvglKLfBkJLXSqawMkiSzzel6R50qFVPRMewXclODSlW8RuOYBd99arSqwwiywghdeePH(S(dMXajMRclL)iLf774VJnlpKLffzb4798AKLlzbiu5nl23VWolhLf)zrtS8EtcFkb0GLjSzbbGDuwSPmIhlfo9XoklWMfcMfGV30vtczHCkSG2XUaZNf67bIOXab4Dn9cmgi99EEnwVSsHkVJ)4Te5YIlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgOgSqwwOwOsv3D6JSqiwSHfnJLrSuMXgwkflJyHAHkv99Me(ud99EEnYIMXIgSmMLsXYiw0GfcWY7kmFdfUuv4S(7yDcBK(gmDDfcYsPyrdJMyzmlJzHaSuMrdnXsPyrFnNM2bGjCrRZgZsg10yHFjngiisd9z9hmJbsmxfwk)rkl23XFhBwEileuT)7SaU6ljXcXTXSKrJbcW7A6fymq7T)71lRZgZsgn(J3sK1iU0XaX01viyC5Jb6H)Gzmq7T)7XabrAOpR)GzmWYLISqq1(VZYLSaeQ8MfYjOolkYcSz5MSKqwa(EpVgzX(PuSmVNLlFileBRKTCYalEgTa2ymWqFp2NhdCelyqDwu0OwP31ej8ZYWalyqDwu04z0AIe(zrlla8(CDfAoAnOqhaYYyw0YYiwEVjHV5VcS(Wk4HSSjlemlddSGb1zrrJALExVSAdlddSOdPuw0YY8iT)1gl8lPSqiw0OmwgZYWal6R50Gb1zrXkfQ820yHFjLfcXIh(dMg6798A0GegdRhR)vGSOLf91CAWG6SOyLcvEBwwSmmWcguNffnxwPqL3SOLfBzbG3NRRqd99EEnwVSsHkVzzyGf91CAcE9YGPXc)skleIfp8hmn03751Objmgwpw)Razrll2YcaVpxxHMJwdk0bGSOLf91CAcE9YGPXc)skleIfKWyy9y9VcKfTSOVMttWRxgmllwggyrFnNM2bGjCrRZgZsg1SSyrlla8(CDfAS3(VxVSoBmlzuwggyXwwa4956k0C0AqHoaKfTSOVMttWRxgmnw4xszztwqcJH1J1)kW4pElr2M4shdetxxHGXLpgiisd9z9hmJbwUuKfGV3ZRrwUjlxYczUsVzHCcQZIIKNLlzbiu5nlKtqDwuKfyYcbtawEVjHpLfyZYdzXQHbwacvEZc5euNffJb6H)Gzmq6798Am(J3sKJCCPJbIPRRqW4YhdeePH(S(dMXajUUs979kgOh(dMXa7vw9WFWSQo6hduD0VMEbgdC6k1V3R4p(JboDL637vCPJ3IgXLogiMUUcbJlFmqp8hmJbsFVPRMegdeePH(S(dMXab(EtxnjKLjSzPacalW8zzLkKszzrVKelLhU1shdm03J95XaTLLEL4e2KqJUR8mGv4S6kv93VKe1Gr66SSqW4pEl2ex6yGy66kemU8Xa9WFWmgiDLZRXyGHObfwFVjHpnElAedm03J95XabHVPacZ51OPXc)sklBYsJf(Luwkfl2ydlKLfnIKyGGin0N1FWmgiXC6ZYVJSacFwSF)ol)oYsbK(S8xbYYdzXbbzzL)Py53rwkCcZc4Q9)GjlhLL97nSaCLZRrwASWVKYsXs9NL6qqwEilf(h2zPacZ51ilGR2)dMXF8wICCPJb6H)GzmWcimNxJXaX01viyC5J)4pgi9JlD8w0iU0XaX01viyC5Jb6H)Gzmqh0T(dawP29UigyiAqH13Bs4tJ3IgXad99yFEmqBzbe(gh0T(dawP29UOc6foj08xGOljXIwwSLfp8hmnoOB9haSsT7Drf0lCsO5Y6uDK2Fw0YYiwSLfq4BCq36payLA37I6o6kZFbIUKelddSacFJd6w)baRu7Exu3rxzASWVKYYMSOjwgZYWalGW34GU1FaWk1U3fvqVWjHg67bIyHqSezw0Yci8noOB9haSsT7Drf0lCsOPXc)skleILiZIwwaHVXbDR)aGvQDVlQGEHtcn)fi6ssXabrAOpR)GzmWYLISSvq36pailaT7Dbl23XKLFhBKLJYsczXd)bazHA37cYZItzr5pYItzXcsPNUczbMSqT7Dbl2VFNfByb2Smr7yZc99aruwGnlWKfNLitawO29UGfkKLF3Fw(DKLeTZc1U3fS4DFaqklLySOpl(8XMLF3FwO29UGfKWwxJ04pEl2ex6yGy66kemU8Xa9WFWmgyaMaGeH1FhRuRRVNgdeePH(S(dMXalxkszHyWeaKiKLBYcX2kzlNmWYrzzzXcSzjkCXI3ilGinAgUKeleBRKTCYal2VFNfIbtaqIqw8eKLOWflEJSOJkODwi4YiBKlBeXqfs)ZvSa0667PJzzRucclxYIZIgLrawOyGfYjOolkAyzRkkKfqyU9ZIcFw0Cn6f6xcInliHTUgjplUYUhLYYIISCjleBRKTCYal2VFNfcYsr9MfpbzXFw(DKf679ZcCYIZs5HBT0Sy)sqODtmWqFp2Nhd0wwa71bAsynaszrllJyzela8(CDfAcWeaKiScI0OzGfTSyllbiubcTNMGxVmyA0bJYIwwSLLEL4e2KqJvFfWg8Cv17GNxOATuuVny66keKLHbw0xZPj41ldMLflJzrllJyzelo9BxvTG2XMfcfbla8(CDfAcWeaKiS6ulw0YYiw0xZPbdQZIIv1k920yHFjLLnzrJYyzyGf91CAWG6SOyLcvEBASWVKYYMSOrzSmMLHbw0xZPj41ldMgl8lPSSjlAIfTSOVMttWRxgmnw4xszHqrWIg2WYyw0YYiwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggyXww6vItytcnbuH0)CvLAD99udMUUcbzzyGf91CA(RaTd7Sc2OxOFji2Mgl8lPSSjliHXW6X6FfilJzzyGLEL4e2KqJUR8mGv4S6kv93VKe1GPRRqqwgZIwwgXITS0ReNWMeA0DLNbScNvxPQ)(LKOgmDDfcYYWalJyrFnNgDx5zaRWz1vQ6VFjjAn9F1OH(EGiwIGLiHLHbw0xZPr3vEgWkCwDLQ(7xsIw9o4jAOVhiILiyjsyzmlJzzyGfDiLYIwwMhP9V2yHFjLfcXIgLXIwwSLLaeQaH2ttWRxgmn6GrzzC8hVLihx6yGy66kemU8Xa9WFWmgi99MUAsymqqKg6Z6pygdSCPilaFVPRMeYYdzHieTyzzXYVJSO5A0l0VeeBw0xZjl3KL7zXoCPazbjS11il64e2ilZlp6(LKy53rwsKWplbN(SaBwEilGRclw0XjSrwigmbajcJbg67X(8yG9kXjSjHM)kq7WoRGn6f6xcITbtxxHGSOLLrSyllJyzel6R508xbAh2zfSrVq)sqSnnw4xszztw8WFW0yV9F3GegdRhR)vGSqawkZOblAzzelyqDwu0Czvh(7SmmWcguNffnxwPqL3SmmWcguNffnQv6Dnrc)SmMLHbw0xZP5Vc0oSZkyJEH(LGyBASWVKYYMS4H)GPH(EpVgniHXW6X6FfileGLYmAWIwwgXcguNffnxwvR0BwggybdQZIIgku5Dnrc)SmmWcguNffnEgTMiHFwgZYywggyXww0xZP5Vc0oSZkyJEH(LGyBwwSmMLHbwgXI(AonbVEzWSSyzyGfaEFUUcnbycasewbrA0mWYyw0YsacvGq7PjataqIW6VJvQ113tnn6Grzrllbiam98n5rA)RthzrllJyrFnNgmOolkwvR0BtJf(Luw2KfnkJLHbw0xZPbdQZIIvku5TPXc)sklBYIgLXYywgZIwwgXITSeGaW0Z3qu0(8KLHbwcqOceApnyHf0o2vDycAASWVKYYMSejSmo(J3cbhx6yGy66kemU8Xa9WFWmgi99MUAsymqqKg6Z6pygduZTkSyb47nD1Kqkl2VFNLY7kpdilWjlBvPyP07xsIYcSz5HSy1OL3iltyZcXGjairil2VFNLYd3APJbg67X(8yG9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSOLLrSmIf91CA0DLNbScNvxPQ)(LKO10)vJg67bIyztwSHLHbw0xZPr3vEgWkCwDLQ(7xsIw9o4jAOVhiILnzXgwgZIwwcqOceApnbVEzW0yHFjLLnzH4WIwwSLLaeQaH2ttaMaGeH1FhRuRRVNAwwSmmWYiwcqay65BYJ0(xNoYIwwcqOceApnbycasew)DSsTU(EQPXc)skleIfnkJfTSGb1zrrZLvpJYIwwC63UQAbTJnlBYInLXcbyjYLXsPyjaHkqO90e86LbtJoyuwgZY44pElAkU0XaX01viyC5JbcTIbsXpgOh(dMXab4956kmgiaxTWyGJyrFnNM2bGjCrRZgZsg10yHFjLLnzrtSmmWITSOVMtt7aWeUO1zJzjJAwwSmMfTSyll6R500oamHlAD2ywYOv6LZLQUhL(yFUzzXIwwgXI(AoneDjyJGvSWcAh7cm)kMyt6kjAASWVKYcHyHua0u4eMLXSOLLrSOVMtdguNffRuOYBtJf(Luw2KfsbqtHtywggyrFnNgmOolkwvR0BtJf(Luw2KfsbqtHtywggyzel2YI(AonyqDwuSQwP3MLflddSyll6R50Gb1zrXkfQ82SSyzmlAzXwwExH5BOqf9VaAW01viilJJbcI0qFw)bZyGedMG3FWKLjSzXvkwaHpLLF3FwkCIqkl0vJS87yuw8gZTFwAC2iDhbzX(oMSqqZbGjCrzH42ywYOSS7uwuiLYYV7jlAIfkgOS0yHF5LKyb2S87ilKtHf0o2SuEycYI(Aoz5OS46W1ZYdzz6kflW5KfyZINrzHCcQZIISCuwCD46z5HSGe26AmgiaVRPxGXabHFTXiDDnwG5tJ)4Tq8JlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmg4iwSLf91CAWG6SOyLcvEBwwSOLfBzrFnNgmOolkwvR0BZYILXSOLfBz5DfMVHcv0)cObtxxHGSOLfBzPxjoHnj08xbAh2zfSrVq)sqSny66kemgiisd9z9hmJbsmycE)btw(D)zjSJbIOSCtwIcxS4nYcC90dezbdQZIIS8qwGPkklGWNLFhBKfyZYrkHnYYVFuwSF)olaHk6FbmgiaVRPxGXabHFfUE6bIvmOolkg)XBH4ex6yGy66kemU8Xa9WFWmgybeMZRXyGHObfwFVjHpnElAedm03J95XahXI(AonyqDwuSsHkVnnw4xszztwASWVKYYWal6R50Gb1zrXQALEBASWVKYYMS0yHFjLLHbwa4956k0ac)kC90deRyqDwuKLXSOLLgNns3DDfYIwwEVjHV5VcS(Wk4HSSjlAydlAzXTQHDmqelAzbG3NRRqdi8RngPRRXcmFAmqqKg6Z6pygduZbFwCLIL3Bs4tzX(97xYcbXtqS4cSy)(D46zbca7GBzDjjc87ilUoeaYsaMG3FWKg)XBjsIlDmqmDDfcgx(yGE4pygdKUY51ymWqFp2NhdCel6R50Gb1zrXkfQ820yHFjLLnzPXc)sklddSOVMtdguNffRQv6TPXc)sklBYsJf(LuwggybG3NRRqdi8RW1tpqSIb1zrrwgZIwwAC2iD31vilAz59Me(M)kW6dRGhYYMSOHnSOLf3Qg2XarSOLfaEFUUcnGWV2yKUUglW8PXadrdkS(EtcFA8w0i(J3IMpU0XaX01viyC5Jb6H)Gzmq6JkL31PYBmgyOVh7ZJboIf91CAWG6SOyLcvEBASWVKYYMS0yHFjLLHbw0xZPbdQZIIv1k920yHFjLLnzPXc)sklddSaW7Z1vObe(v46PhiwXG6SOilJzrllnoBKU76kKfTS8EtcFZFfy9HvWdzztw0G4ZIwwCRAyhdeXIwwa4956k0ac)AJr66ASaZNgdmenOW67nj8PXBrJ4pElAuwCPJbIPRRqW4YhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXadqay65BaG5VhTzrll2YsVsCcBsOHE5CPQ7rPp2NBW01viilAzXww6vItytcnHRdkScNv1nXQNGvq0)DdMUUcbzrllbiubcTNgDSPyt0LKmn6GrzrllbiubcTNM2bGjCrRZgZsg10OdgLfTSyll6R50e86LbZYIfTSmIfN(TRQwq7yZYMSejehwggyrFnNgDfecQw03SSyzCmqqKg6Z6pygduZbFw6J0(ZIooHnYcXTXSKrz5MSCpl2HlfilUsbTZsu4ILhYsJZgP7SOqkLfWvFjjwiUnMLmklJ(9JYcmvrzz3TSWKYI973HRNfGxoxkwiOpk9X(8XXab4Dn9cmgycR7rPp2NxrVvrRGWp(J3IgAex6yGy66kemU8Xad99yFEmqaEFUUcnjSUhL(yFEf9wfTccFw0YsJf(Luwiel2uwmqp8hmJbwaH58Am(J3Ig2ex6yGy66kemU8Xad99yFEmqaEFUUcnjSUhL(yFEf9wfTccFw0YsJf(LuwielAO5Jb6H)Gzmq6kNxJXF8w0iYXLogiMUUcbJlFmqp8hmJboHDaRWzn9F1ymqqKg6Z6pygdSCPilex4wybMSeazX(97W1ZsWTSUKumWqFp2Nhd0TQHDmqu8hVfni44shdetxxHGXLpgOh(dMXaXclODSR6Wemgiisd9z9hmJbwUuKfYPWcAhBwkpmbzX(97S4zuwuWKelycxK2zr50)ssSqob1zrrw8eKLVJYYdzrDjYY9SSSyX(97SqqwkQ3S4jileBRKTCYqmWqFp2NhdCelbiubcTNMGxVmyASWVKYcbyrFnNMGxVmyaxT)hmzHaS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSukw0Wgw2KLaeQaH2tdwybTJDvhMGgWv7)btwialAuglJzzyGf91CAcE9YGPXc)sklBYsKWYWalG96anjSgaPXF8w0qtXLogiMUUcbJlFmqOvmqk(Xa9WFWmgiaVpxxHXab4Qfgd0PF7QQf0o2SSjlA(YyrZyzel2y0elLIf91CAMRoAfoROALOH(EGiw0mwSHLsXcguNffnxwvR0BwghdeePH(S(dMXabIpLf77yYYwPeewO7WLcKfDKfWvHfcYYdzjHplqayhClwgP5qlmbPSatwiURoklWjlKJALilEcYYVJSqob1zrXXXab4Dn9cmgOtTQGRcR4pElAq8JlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgOTSa2Rd0KWAaKYIwwgXcaVpxxHMaynatW7pyYIwwSLf91CAcE9YGzzXIwwgXITSqXVQdZf18h22ejvBScSmmWcguNffnxwvR0BwggybdQZIIgku5Dnrc)SmMfTSmILrSmIfaEFUUcno1QcUkSyzyGLaeaME(M8iT)1PJSmmWYiwcqay65BikAFEYIwwcqOceApnyHf0o2vDycAA0bJYYywggyPxjoHnj08xbAh2zfSrVq)sqSny66keKLXSOLfq4BORCEnAASWVKYYMSejSOLfq4BkGWCEnAASWVKYYMSO5zrllJybe(g6JkL31PYB00yHFjLLnzrJYyzyGfBz5DfMVH(Os5DDQ8gny66keKLXSOLfaEFUUcn)EFkvLIiryxT73ZIwwEVjHV5VcS(Wk4HSSjl6R50e86Lbd4Q9)GjlLILYmehwggyrFnNgDfecQw03SSyrll6R50ORGqq1I(Mgl8lPSqiw0xZPj41ldgWv7)btwialJyrdByPuS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSmMLXSmmWYiwWiDDwwiOblSI2ORQWgm9mGSOLLaeQaH2tdwyfTrxvHny6zannw4xszHqSObXN4WcbyzelAILsXsVsCcBsOHE5CPQ7rPp2NBW01viilJzzmlJzrllJyXwwcqay65BYJ0(xNoYYWalJyjaHkqO90eGjairy93Xk1667PMgl8lPSqiw0xZPj41ldgWv7)btwill2WIwwSLLEL4e2KqJUR8mGv4S6kv93VKe1GPRRqqwggyjaHkqO90eGjairy93Xk1667PMgDWOSOLfN(TRQwq7yZcHyrtLXYywggyrhsPSOLL5rA)Rnw4xszHqSeGqfi0EAcWeaKiS(7yLAD99utJf(LuwgZYWal6qkLfTSmps7FTXc)skleIf91CAcE9YGbC1(FWKfcWIg2WsPyPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzzCmqqKg6Z6pygdSCPileBRKTCYal2VFNfIbtaqIqYwI7sWgbzbO113tzXtqwaH52plqayBVVhzHGSuuVzb2SyFhtwkVccbvl6ZID4sbYcsyRRrw0XjSrwi2wjB5KbwqcBDnsnSuI4eHSqxnYYdzbZhBwCwiZv6nlKtqDwuKf77yYYIEKswkTnrcl2yfyXtqwCLIfIP5OSy)ukw0XaSazPrhmkluimzbt4I0olGR(ssS87il6R5Kfpbzbe(uw2Dail6iMSqxZ5fomFvuwAC2iDhbnXab4Dn9cmgyaSgGj49hmR0p(J3IgeN4shdetxxHGXLpgOh(dMXaBhaMWfToBmlz0yGGin0N1FWmgy5srwiUnMLmkl2VFNfITvYwozGLvQqkLfIBJzjJYID4sbYIYPplkyscBw(DpzHyBLSLtgipl)oMSSOil64e2ymWqFp2NhduFnNMGxVmyASWVKYYMSOHMyzyGf91CAcE9YGbC1(FWKfcXInehwial9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viilLIfnSHfTSaW7Z1vOjawdWe8(dMv6h)XBrJijU0XaX01viyC5Jbg67X(8yGa8(CDfAcG1ambV)GzL(SOLLrSOVMttWRxgmGR2)dMSSzeSydXHfcWsVsCcBsOXQVcydEUQ6DWZluTwkQ3gmDDfcYsPyrdByzyGfBzjabGPNVbaM)E0MLXSmmWI(AonTdat4IwNnMLmQzzXIww0xZPPDaycx06SXSKrnnw4xszHqSO5zHaSeGj46EJvJHJIvxDKYcmFZFfyfGRwileGLrSyll6R50ORGqq1I(MLflAzXwwExH5BOV3kydAW01viilJJb6H)GzmWaQq6FUQ6QJuwG5h)XBrdnFCPJbIPRRqW4Yhdm03J95Xab4956k0eaRbycE)bZk9Jb6H)GzmWldEN(FWm(J3InLfx6yGy66kemU8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymWaeQaH2ttWRxgmnw4xszztw0OmwggyXwwa4956k0eGjairyfePrZalAzjabGPNVjps7FD6ilddSa2Rd0KWAaKgdeePH(S(dMXalX6956kKLffbzbMS46N6(dPS87(ZIDpFwEil6iluhacYYe2SqSTs2YjdSqHS87(ZYVJrzXBmFwS70hbzPeJf9zrhNWgz53XIyGa8UMEbgdK6aW6e21GxVme)XBXgnIlDmqmDDfcgx(yGE4pygdCU6Ov4SIQvIXabrAOpR)GzmWYLIuwiUqYHLBYYLS4jlKtqDwuKfpbz57dPS8qwuxISCplllwSF)oleKLI6n5zHyBLSLtgiplKtHf0o2SuEycYINGSSvq36pailaT7DrmWqFp2NhdedQZIIMlREgLfTSmIfN(TRQwq7yZcHyrZBdlAgl6R50mxD0kCwr1krd99arSukw0elddSOVMtt7aWeUO1zJzjJAwwSmMfTSmIf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfBi4YyzyGf91CAcE9YGPXc)sklBYsKWYyw0YcaVpxxHgQdaRtyxdE9YalAzzel2YsacatpFtIHgQGnilddSacFJd6w)baRu7Exub9cNeA(lq0LKyzmlAzzel2YsacatpFdam)9OnlddSOVMtt7aWeUO1zJzjJAASWVKYcHyrZZIMXYiwiywkfl9kXjSjHg6LZLQUhL(yFUbtxxHGSmMfTSOVMtt7aWeUO1zJzjJAwwSmmWITSOVMtt7aWeUO1zJzjJAwwSmMfTSmIfBzjabGPNVHOO95jlddSeGqfi0EAWclODSR6We00yHFjLLnzXMYyzmlAz59Me(M)kW6dRGhYYMSOjwggyrhsPSOLL5rA)Rnw4xszHqSOrzXF8wSXM4shdetxxHGXLpgOh(dMXaPV3txPIbcI0qFw)bZyGLlfzPenXFNfGV3txPyXQHbkl3KfGV3txPy5O52pllRyGH(ESppgO(AonWe)DA1c7aA9hmnllw0YI(Aon037PRuMgNns3DDfg)XBXMihx6yGy66kemU8Xa9WFWmgyWZaQQ6R5mgyOVh7ZJbQVMtd99wbBqtJf(LuwielAIfTSmIf91CAWG6SOyLcvEBASWVKYYMSOjwggyrFnNgmOolkwvR0BtJf(Luw2KfnXYyw0YIt)2vvlODSzztw08LfduFnN10lWyG03BfSbJbcI0qFw)bZyGeZZaQyb47Tc2GSCtwUNLDNYIcPuw(DpzrtuwASWV8ssKNLOWflEJS4plA(YialBLsqyXtqw(DKLWQBmFwiNG6SOil7oLfnraklnw4xEjP4pEl2qWXLogiMUUcbJlFmqp8hmJbg8mGQQ(AoJbg67X(8yGVRW8nxg8o9)GPbtxxHGSOLfBz5DfMVjr71cimny66keKfTSuIhlJyzelrUSYyrZyXPF7QQf0o2Sqawi4YyrZyHIFvhMlQ5pSTjsQ2yfyPuSqWLXYywillJyHGzHSSqTqLQU70hzzmlAglbiubcTNMambajcR)owPwxFp10yHFjLLXSqiwkXJLrSmILixwzSOzS40VDv1cAhBw0mw0xZPXQVcydEUQ6DWZluTwkQ3gaUAHSqawi4YyrZyHIFvhMlQ5pSTjsQ2yfyPuSqWLXYywillJyHGzHSSqTqLQU70hzzmlAglbiubcTNMambajcR)owPwxFp10yHFjLLXSOLLaeQaH2ttWRxgmnw4xszztwICzSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfB0Omw0YI(Aonw9vaBWZvvVdEEHQ1sr92aWvlKLnzjYLXIwwcqOceApnbycasew)DSsTU(EQPXc)skleIfcUmw0YY8iT)1gl8lPSSjlbiubcTNMambajcR)owPwxFp10yHFjLfcWcXNfTSmILEL4e2Kqtavi9pxvPwxFp1GPRRqqwggybG3NRRqtaMaGeHvqKgndSmogO(AoRPxGXaT6Ra2GNRQEh88cvRLI6DmqqKg6Z6pygdKyEgqfl)oYcbzPOEZI(Aoz5MS87ilwnmWID4sbMB)SOUezzzXI973z53rwsKWpl)vGSqmycaseYsawGuwGZjlbqdlLE)OSSOlxPIYcmvrzz3TSWKYc4QVKel)oYs5jtt8hVfB0uCPJbIPRRqW4YhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXadqay65BYJ0(xNoYIww6vItytcnw9vaBWZvvVdEEHQ1sr92GPRRqqw0YI(Aonw9vaBWZvvVdEEHQ1sr92aWvlKfcWIt)2vvlODSzHaSezw2mcwICzLXIwwa4956k0eGjairyfePrZalAzjaHkqO90eGjairy93Xk1667PMgl8lPSqiwC63UQAbTJnlKLLixglLIfsbqtHtyw0YITSa2Rd0KWAaKYIwwWG6SOO5YQNrzrllo9BxvTG2XMLnzbG3NRRqtaMaGeHvNAXIwwcqOceApnbVEzW0yHFjLLnzrtXabrAOpR)GzmqG4tzX(oMSqqwkQ3Sq3Hlfil6ilwnmeqqwqVvrz5HSOJS46kKLhYYIISqmycaseYcmzjaHkqO9KLrKdLI5FUsfLfDmalqklFVqwUjlGRcRljXYwPeewsODwSFkflUsbTZsu4ILhYIf2tm8QOSG5JnleKLI6nlEcYYVJjllkYcXGjair44yGa8UMEbgd0QHHQ1sr9UIERIg)XBXgIFCPJbIPRRqW4Yhd0d)bZyG037PRuXabrAOpR)GzmWYLISa89E6kfl2VFNfGpQuEZIMRV5ZcSz5TjsyHGTcS4jiljKfGV3kydsEwSVJjljKfGV3txPy5OSSSyb2S8qwSAyGfcYsr9Mf77yYIRdbGSO5lJLTsjiJGnl)oYc6TkkleKLI6nlwnmWcaVpxxHSCuw(EHJzb2S4Gw(FaqwO29UGLDNYsKqakgOS0yHF5LKyb2SCuwUKLP6iT)Xad99yFEmWrS8UcZ3qFuP8Uc238ny66keKLHbwO4x1H5IA(dBBIKkbBfyzmlAzXwwExH5BOV3kydAW01viilAzrFnNg6790vktJZgP7UUczrll2YsVsCcBsO5Vc0oSZkyJEH(LGyBW01viilAzzel6R50y1xbSbpxv9o45fQwlf1BdaxTqw2mcwSrtLXIwwSLf91CAcE9YGzzXIwwgXcaVpxxHgNAvbxfwSmmWI(AoneDjyJGvSWcAh7cm)kMyt6kjAwwSmmWcaVpxxHgRggQwlf17k6TkklJzzyGLrSeGaW0Z3KyOHkydYIwwExH5BOpQuExb7B(gmDDfcYIwwgXci8noOB9haSsT7Drf0lCsOPXc)sklBYsKWYWalE4pyACq36payLA37IkOx4KqZL1P6iT)SmMLXSmMfTSeGqfi0EAcE9YGPXc)sklBYIgLf)XBXgItCPJbIPRRqW4Yhd0d)bZyG03B6QjHXabrAOpR)Gzmqn3QWIYYwPeew0XjSrwigmbajczzrVKel)oYcXGjairilbycE)btwEilHDmqel3KfIbtaqIqwoklE4xUsfLfxhUEwEil6ilbN(Xad99yFEmqaEFUUcnwnmuTwkQ3v0Bv04pEl2ejXLogiMUUcbJlFmqp8hmJbMO9AbeMXabrAOpR)GzmWYLISuIaHjLf77yYsu4IfVrwCD46z5HK1BKLGBzDjjwc7EtcPS4jilforil0vJS87yuw8gz5sw8KfYjOolkYc9pLILjSzHG(seYsClrIbg67X(8yGUvnSJbIyrllJyjS7njKYseSydlAzPXWU3KW6FfileIfnXYWalHDVjHuwIGLiZY44pEl2O5JlDmqmDDfcgx(yGH(ESppgOBvd7yGiw0YYiwc7EtcPSebl2WIwwAmS7njS(xbYcHyrtSmmWsy3BsiLLiyjYSmMfTSmIf91CAWG6SOyvTsVnnw4xszztwqcJH1J1)kqwggyrFnNgmOolkwPqL3Mgl8lPSSjliHXW6X6FfilJJb6H)GzmWDxnRfqyg)XBjYLfx6yGy66kemU8Xad99yFEmq3Qg2XarSOLLrSe29MeszjcwSHfTS0yy3Bsy9VcKfcXIMyzyGLWU3KqklrWsKzzmlAzzel6R50Gb1zrXQALEBASWVKYYMSGegdRhR)vGSmmWI(AonyqDwuSsHkVnnw4xszztwqcJH1J1)kqwghd0d)bZyGZLsvlGWm(J3sK1iU0XaX01viyC5Jb6H)Gzmq67nD1KWyGGin0N1FWmgy5srwa(EtxnjKLs0e)DwSAyGYINGSaUkSyzRuccl23XKfITvYwozG8Sqofwq7yZs5Hji5z53rwkXI5VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsjiXad99yFEmqmOolkAUS6zuw0YYiw0xZPbM4VtRbf6DfWrpyAwwSmmWI(AoneDjyJGvSWcAh7cm)kMyt6kjAwwSmmWI(AonbVEzWSSyrllJyXwwcqay65BikAFEYYWalbiubcTNgSWcAh7Qombnnw4xszztw0elddSOVMttWRxgmnw4xszHqSqkaAkCcZsPyzQGWMLrS40VDv1cAhBwilla8(CDfAO0AasFwgZYyw0YYiwSLLaeaME(gay(7rBwggyrFnNM2bGjCrRZgZsg10yHFjLfcXcPaOPWjmlLILaEkwgXYiwC63UQAbTJnleGfcUmwkflVRW8nZvhTcNvuTs0GPRRqqwgZczzbG3NRRqdLwdq6ZYywialrMLsXY7kmFtI2RfqyAW01viilAzXww6vItytcn0lNlvDpk9X(CdMUUcbzrll6R500oamHlAD2ywYOMLflddSOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95MLflddSmIf91CAAhaMWfToBmlzutJf(LuwielE4pyAOV3ZRrdsymSES(xbYIwwOwOsv3D6JSqiwkZqWSmmWI(AonTdat4IwNnMLmQPXc)skleIfp8hmn2B)3niHXW6X6FfilddSaW7Z1vO5IuWAaMG3FWKfTSeGqfi0EAUKg6176kSgPlp)vrfebCb00OdgLfTSGr66SSqqZL0qVExxH1iD55VkQGiGlGSmMfTSOVMtt7aWeUO1zJzjJAwwSmmWITSOVMtt7aWeUO1zJzjJAwwSOLfBzjaHkqO900oamHlAD2ywYOMgDWOSmMLHbwa4956k04uRk4QWILHbw0HuklAzzEK2)AJf(LuwielKcGMcNWSukwc4Pyzelo9BxvTG2XMfYYcaVpxxHgkTgG0NLXSmo(J3sKTjU0XaX01viyC5Jb6H)Gzmq67nD1KWyGGin0N1FWmgyP7OS8qwkCIqw(DKfDK(SaNSa89wbBqw0JYc99arxsIL7zzzXsKUUarQOSCjlEgLfYjOolkYI(6zHGSuuVz5O52plUoC9S8qw0rwSAyiGGXad99yFEmW3vy(g67Tc2GgmDDfcYIwwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqw0YYiw0xZPH(ERGnOzzXYWalo9BxvTG2XMLnzrZxglJzrll6R50qFVvWg0qFpqeleILiZIwwgXI(AonyqDwuSsHkVnllwggyrFnNgmOolkwvR0BZYILXSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfBioLXIwwgXsacvGq7Pj41ldMgl8lPSSjlAuglddSylla8(CDfAcWeaKiScI0OzGfTSeGaW0Z3KhP9VoDKLXXF8wICKJlDmqmDDfcgx(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgiguNffnxwvR0BwkflrclKLfp8hmn03751Objmgwpw)RazHaSyllyqDwu0CzvTsVzPuSmIfIpleGL3vy(gkCPQWz93X6e2i9ny66keKLsXsKzzmlKLfp8hmn2B)3niHXW6X6FfileGLYmeSMyHSSqTqLQU70hzHaSuMrtSukwExH5Bs)xnsR6UYZaAW01viymqqKg6Z6pygdKCO)v4pszzhANLIvyNLTsjiS4nYcj)seKflSzHIbycAyPenvrz5DIqklol00TO7WNLjSz53rwcRUX8zHE)Y)dMSqHSyhUuG52pl6ilEiSA)rwMWMfL3KWML)kWz7fingiaVRPxGXaDQfbbBGyi(J3sKj44shdetxxHGXLpgOh(dMXaPV30vtcJbcI0qFw)bZyGAUvHflaFVPRMeYYLS4jlKtqDwuKfNYcfctwCklwqk90viloLffmjXItzjkCXI9tPybtqwwwSy)(DwIKYial23XKfmFSVKel)oYsIe(zHCcQZIIKNfqyU9ZIcFwUNfRggyHGSuuVjplGWC7NfiaST33JS4jlLOj(7Sy1WalEcYIfeQyrhNWgzHyBLSLtgyXtqwiNclODSzP8WemgyOVh7ZJbAll9kXjSjHM)kq7WoRGn6f6xcITbtxxHGSOLLrSOVMtJvFfWg8Cv17GNxOATuuVnaC1czHqSydXPmwggyrFnNgR(kGn45QQ3bpVq1APOEBa4QfYcHyXgnvglAz5DfMVH(Os5DfSV5BW01viilJzrllJybdQZIIMlRuOYBw0YIt)2vvlODSzHaSaW7Z1vOXPweeSbIbwkfl6R50Gb1zrXkfQ820yHFjLfcWci8nZvhTcNvuTs08xGiATXc)swkfl2y0elBYsKuglddSGb1zrrZLv1k9MfTS40VDv1cAhBwiala8(CDfACQfbbBGyGLsXI(AonyqDwuSQwP3Mgl8lPSqawaHVzU6Ov4SIQvIM)cerRnw4xYsPyXgJMyztw08LXYyw0YITSOVMtdmXFNwTWoGw)btZYIfTSyllVRW8n03BfSbny66keKfTSmILaeQaH2ttWRxgmnw4xszztwioSmmWcfUu6xcA(9(uQkfrIW2GPRRqqw0YI(Aon)EFkvLIiryBOVhiIfcXsKJmlAglJyPxjoHnj0qVCUu19O0h7Zny66keKLsXInSmMfTSmps7FTXc)sklBYIgLvglAzzEK2)AJf(Luwiel2uwzSmmWcyVoqtcRbqklJzrllJyXwwcqay65BikAFEYYWalbiubcTNgSWcAh7Qombnnw4xszztwSHLXXF8wISMIlDmqmDDfcgx(yGE4pygdmr71cimJbcI0qFw)bZyGLlfzPebctklxYINrzHCcQZIIS4jiluhaYcb9UAsaI7sPyPebctwMWMfITvYwozGfpbzPe3LGncYc5uybTJDbMVHLTQOqwwuKLTuIWINGSqClryXFw(DKfmbzbozH42ywYOS4jilGWC7Nff(SO5A0l0VeeBwMUsXcCoJbg67X(8yGUvnSJbIyrlla8(CDfAOoaSoHDn41ldSOLLrSOVMtdguNffRQv6TPXc)sklBYcsymSES(xbYYWal6R50Gb1zrXkfQ820yHFjLLnzbjmgwpw)RazzC8hVLit8JlDmqmDDfcgx(yGH(ESppgOBvd7yGiw0YcaVpxxHgQdaRtyxdE9YalAzzel6R50Gb1zrXQALEBASWVKYYMSGegdRhR)vGSmmWI(AonyqDwuSsHkVnnw4xszztwqcJH1J1)kqwgZIwwgXI(AonbVEzWSSyzyGf91CAS6Ra2GNRQEh88cvRLI6TbGRwilekcwSrJYyzmlAzzel2YsacatpFdam)9OnlddSOVMtt7aWeUO1zJzjJAASWVKYcHyzelAIfnJfByPuS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYyw0YI(AonTdat4IwNnMLmQzzXYWal2YI(AonTdat4IwNnMLmQzzXYyw0YYiwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggybjmgwpw)RazHqSOVMtZFfODyNvWg9c9lbX20yHFjLLHbwSLf91CA(RaTd7Sc2OxOFji2MLflJJb6H)GzmWDxnRfqyg)XBjYeN4shdetxxHGXLpgyOVh7ZJb6w1WogiIfTSaW7Z1vOH6aW6e21GxVmWIwwgXI(AonyqDwuSQwP3Mgl8lPSSjliHXW6X6FfilddSOVMtdguNffRuOYBtJf(Luw2KfKWyy9y9VcKLXSOLLrSOVMttWRxgmllwggyrFnNgR(kGn45QQ3bpVq1APOEBa4QfYcHIGfB0OmwgZIwwgXITSeGaW0Z3qu0(8KLHbw0xZPHOlbBeSIfwq7yxG5xXeBsxjrZYILXSOLLrSyllbiam98naW83J2SmmWI(AonTdat4IwNnMLmQPXc)skleIfnXIww0xZPPDaycx06SXSKrnllw0YITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYWal2YI(AonTdat4IwNnMLmQzzXYyw0YYiwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggybjmgwpw)RazHqSOVMtZFfODyNvWg9c9lbX20yHFjLLHbwSLf91CA(RaTd7Sc2OxOFji2MLflJJb6H)GzmW5sPQfqyg)XBjYrsCPJbIPRRqW4YhdeePH(S(dMXalxkYcbfKCybMSeaJb6H)Gzmq7E3hSRWzfvReJ)4TeznFCPJbIPRRqW4Yhd0d)bZyG03751ymqqKg6Z6pygdSCPilaFVNxJS8qwSAyGfGqL3Sqob1zrrYZcX2kzlNmWYUtzrHukl)vGS87EYIZcbv7)oliHXW6rwu48zb2SatvuwiZv6nlKtqDwuKLJYYYYWcb197SuABIewSXkWcMp2S4SaeQ8MfYjOolkYYnzHGSuuVzH(NsXYUtzrHukl)UNSyJgLXc99aruw8eKfITvYwozGfpbzHyWeaKiKLDhaYsbSrw(DpzrdIdLfIP5yPXc)YljzyPCPilUoeaYInAQmIhl7o9rwax9LKyH42ywYOS4jil2yJnepw2D6JSy)(D46zH42ywYOXad99yFEmqmOolkAUSQwP3SOLfBzrFnNM2bGjCrRZgZsg1SSyzyGfmOolkAOqL31ej8ZYWalJybdQZIIgpJwtKWplddSOVMttWRxgmnw4xszHqS4H)GPXE7)Ubjmgwpw)Razrll6R50e86LbZYILXSOLLrSyllu8R6WCrn)HTnrs1gRalddS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfB0Omw0YsacvGq7Pj41ldMgl8lPSSjlAqCyrllJyXwwcqay65BYJ0(xNoYYWalbiubcTNMambajcR)owPwxFp10yHFjLLnzrdIdlJzrllJyXwwApGMVHkflddSeGqfi0EA0XMInrxsY0yHFjLLnzrdIdlJzzmlddSGb1zrrZLvpJYIwwgXI(Aon29UpyxHZkQwjAwwSmmWc1cvQ6UtFKfcXszgcwtSOLLrSyllbiam98naW83J2SmmWITSOVMtt7aWeUO1zJzjJAwwSmMLHbwcqay65BaG5VhTzrlluluPQ7o9rwielLziywgh)XBHGllU0XaX01viyC5JbcI0qFw)bZyGLlfzHGQ9FNf4VJT9JISyF)c7SCuwUKfGqL3Sqob1zrrYZcX2kzlNmWcSz5HSy1WalK5k9MfYjOolkgd0d)bZyG2B)3J)4TqWAex6yGy66kemU8XabrAOpR)GzmqIRRu)EVIb6H)GzmWELvp8hmRQJ(Xavh9RPxGXaNUs979k(J)4pgiaSPhmJ3InLzJnLzJne)yG29oVKengib1wjOTLYzle0vcSWsP3rwUcly)SmHnlBdTWe7TzPXiDDncYcfwGS4Rhw4pcYsy3tsi1WBqMxISytjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJ0GWJn8gK5LilrUeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdY8sKfcUeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdEdcQTsqBlLZwiOReyHLsVJSCfwW(zzcBw2geN(s9BZsJr66AeKfkSazXxpSWFeKLWUNKqQH3GmVezH4xcSqmyca7hbzb4vqmwOrZ3jmlepwEilK5Yzb8aC0dMSaTW2FyZYiYoMLrAq4XgEdY8sKfIFjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJSHWJn8gK5LileNsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwIKsGfIbtay)iilaVcIXcnA(oHzH4XYdzHmxolGhGJEWKfOf2(dBwgr2XSmYgcp2WBqMxISejLaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42Smsdcp2WBqMxISO5lbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzuKj8ydVbzEjYIMVeyHyWea2pcYY2FFjr4B0WqgBZYdzz7VVKi8nVggYyBwgzdHhB4niZlrw08LaledMaW(rqw2(7ljcFJngYyBwEilB)9LeHV5TXqgBZYiBi8ydVbzEjYIgLvcSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYIgAucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYIg2ucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYIgrUeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdY8sKfn0ujWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJ0GWJn8gK5LilAq8lbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKneESH3GmVezrdIFjWcXGjaSFeKLT)(sIW3OHHm2MLhYY2FFjr4BEnmKX2SmYgcp2WBqMxISObXVeyHyWea2pcYY2FFjr4BSXqgBZYdzz7VVKi8nVngYyBwgPbHhB4niZlrw0G4ucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYiBi8ydVbzEjYIgeNsGfIbtay)iilB)9LeHVrddzSnlpKLT)(sIW38AyiJTzzKgeESH3GmVezrdItjWcXGjaSFeKLT)(sIW3yJHm2MLhYY2FFjr4BEBmKX2SmYgcp2WBWBqqTvcABPC2cbDLalSu6DKLRWc2pltyZY2wngGf6(VnlngPRRrqwOWcKfF9Wc)rqwc7EscPgEdY8sKLixcSqmyca7hbzz7VVKi8nAyiJTz5HSS93xse(MxddzSnlJImHhB4niZlrwi4sGfIbtay)iilB)9LeHVXgdzSnlpKLT)(sIW382yiJTzzuKj8ydVbzEjYcXPeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3Mf)zHCkrjtwgPbHhB4n4niO2kbTTuoBHGUsGfwk9oYYvyb7NLjSzzBhIBZsJr66AeKfkSazXxpSWFeKLWUNKqQH3GmVezrJsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwSPeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdY8sKfBkbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzXFwiNsuYKLrAq4XgEdY8sKLixcSqmyca7hbzz73vy(gYyBwEilB)UcZ3qggmDDfcUnlJ0GWJn8gK5LilrUeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrrMWJn8gK5Lile)sGfIbtay)iilaVcIXcnA(oHzH4r8y5HSqMlNLci4sTOSaTW2FyZYiI3ywgPbHhB4niZlrwi(LaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42SmYgcp2WBqMxISqCkbwigmbG9JGSa8kigl0O57eMfIhXJLhYczUCwkGGl1IYc0cB)HnlJiEJzzKgeESH3GmVezH4ucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYsKucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYIMVeyHyWea2pcYcWRGySqJMVtywiES8qwiZLZc4b4OhmzbAHT)WMLrKDmlJSHWJn8gK5LilAytjWcXGjaSFeKfGxbXyHgnFNWSq8y5HSqMlNfWdWrpyYc0cB)HnlJi7ywgPbHhB4niZlrw0GGlbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKgeESH3GmVezrdnvcSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYini8ydVbzEjYIge)sGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrw0iskbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKgeESH3GmVezXMYkbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKneESH3GmVezXgBkbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYini8ydVbzEjYIneCjWcXGjaSFeKfGxbXyHgnFNWSq8y5HSqMlNfWdWrpyYc0cB)HnlJi7ywgzdHhB4niZlrwSHGlbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKgeESH3GmVezXgIFjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJ0GWJn8gK5Lil2qCkbwigmbG9JGSSDVsCcBsOHm2MLhYY29kXjSjHgYWGPRRqWTzzKgeESH3GmVezXgnFjWcXGjaSFeKfGxbXyHgnFNWSq8y5HSqMlNfWdWrpyYc0cB)HnlJi7ywgzdHhB4niZlrwICzLaledMaW(rqwaEfeJfA08DcZcXJLhYczUCwapah9GjlqlS9h2SmISJzzKgeESH3G3GGARe02s5Sfc6kbwyP07ilxHfSFwMWMLTNUs979ABwAmsxxJGSqHfil(6Hf(JGSe29Kesn8gK5Lil2ucSqmyca7hbzb4vqmwOrZ3jmlepwEilK5Yzb8aC0dMSaTW2FyZYiYoMLrAq4XgEdEdcQTsqBlLZwiOReyHLsVJSCfwW(zzcBw2M(BZsJr66AeKfkSazXxpSWFeKLWUNKqQH3GmVezXMsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPjcp2WBqMxISe5sGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwi4sGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwi(LaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42S4plKtjkzYYini8ydVbzEjYIgLvcSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYiBi8ydVbzEjYIgeCjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJ0GWJn8gK5LilAq8lbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYini8ydVbzEjYIge)sGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPjcp2WBqMxISObXPeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdY8sKfnIKsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwSrJsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwSHGlbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYicMWJn8gK5Lil2qWLaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42Smsdcp2WBqMxISyJMkbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYini8ydVbzEjYInAQeyHyWea2pcYY29kXjSjHgYyBwEilB3ReNWMeAiddMUUcb3MLrAq4XgEdY8sKfBi(LaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42Smsdcp2WBqMxISeznkbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYOit4XgEdY8sKLiRrjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJ0GWJn8gK5Lilr2MsGfIbtay)iilB3ReNWMeAiJTz5HSSDVsCcBsOHmmy66keCBwgPbHhB4niZlrwICKlbwigmbG9JGSa8kigl0O57eMfIhlpKfYC5SaEao6btwGwy7pSzzezhZYOit4XgEdY8sKLitWLaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42SmYgcp2WBqMxISezIFjWcXGjaSFeKLT7vItytcnKX2S8qw2UxjoHnj0qggmDDfcUnlJSHWJn8gK5LilrM4ucSqmyca7hbzz7EL4e2KqdzSnlpKLT7vItytcnKHbtxxHGBZYiBi8ydVbzEjYsK18LaledMaW(rqw2UxjoHnj0qgBZYdzz7EL4e2KqdzyW01vi42Smsdcp2WBWBuofwW(rqwi(S4H)GjlQJ(udVrmqRgopfgdKCjxwkVR8mGSO561bYBqUKllexuVxEhLfBioKNfBkZgB4n4nixYLfIT7jjKwc8gKl5YIMXYwbbrqwacvEZs5rVWWBqUKllAgleB3tsiilV3KWVEtwcofPS8qwcrdkS(EtcFQH3GCjxw0mwiOHfqaiilRmXasPEhLfaEFUUcPSm6mOH8Sy1iGk99MUAsilA2MSy1iad99MUAs4ydVb5sUSOzSSvaWdKfRgdo9VKeleuT)7SCtwUFBkl)oYI9gMKyHCcQZIIgEdYLCzrZyPeXjczHyWeaKiKLFhzbO113tzXzrD)RqwkGnYYuHe(0vilJUjlrHlw2DWC7NL97z5EwOxXs9EIWfvfLf73VZs5lr3APzHaSqmuH0)CflBvDKYcmFYZY9BdYcLOZASH3GCjxw0mwkrCIqwkG0NLTNhP9V2yHFjDBwObm9(GuwCllvuwEil6qkLL5rA)PSatvudVb5sUSOzSu6g9NLsdlqwGtwkVY3zP8kFNLYR8DwCklolulmCUILVVKi8n8gKl5YIMXsjQfMyZYOZGgYZcbv7)o5zHGQ9FN8Sa89EEnoMLchezPa2ilnsp1H5ZYdzb9wDyZsawO7VMrFVFdVb5sUSOzSqCpcZsjUlbBeKfYPWcAh7cmFwc7yGiwMWMfIP5yzrDsOH3G3GCjxw2AMW3FeKLY7kpdilBLGqMSe8KfDKLjCLGS4pl7)BrlbYswDx5za1m6vemKUFFPBoizlVR8mGAgWRGyKTa0S)fQs8NNcJq3vEgqZt4N3G3Wd)btQXQXaSq3)ii6sWgbRuRRVNYBqUSu6DKfaEFUUcz5OSqXNLhYszSy)(Dwsil03FwGjllkYY3xse(uYZIgSyFhtw(DKL510NfyISCuwGjllksEwSHLBYYVJSqXambz5OS4jilrMLBYIo83zXBK3Wd)btQXQXaSq3Fcebzb4956kK8PxGraZ6II1VVKi8jpaxTWikJ3Wd)btQXQXaSq3Fcebzb4956kK8PxGraZ6II1VVKi8jp0kcheK8aC1cJqdYFZi((sIW3OHz3P1ffR6R5u73xse(gnmbiubcTNgWv7)btT2(9LeHVrdZrnpSaRWzTaM0VHlAnat63RWFWKYB4H)Gj1y1yawO7pbIGSa8(CDfs(0lWiGzDrX63xse(KhAfHdcsEaUAHryd5VzeFFjr4BSXS706IIv91CQ97ljcFJnMaeQaH2td4Q9)GPwB)(sIW3yJ5OMhwGv4Swat63WfTgGj97v4pys5nixwk9osrw((sIWNYI3ilj8zXxpSW)l4kvuwaXhdpcYItzbMSSOil03Fw((sIWNAyHfG4ZcaVpxxHS8qwiywCkl)ogLfxrHSKicYc1cdNRyz3tq1LKm8gE4pysnwngGf6(tGiilaVpxxHKp9cmcywxuS(9LeHp5Hwr4GGKhGRwyeem5VzeyKUolle0Cjn0R31vynsxE(RIkic4c4WagPRZYcbnyHv0gDvf2GPNbCyaJ01zzHGgkCPu4)xsQ2l9O8gKllaXNYYVJSa89MUAsilbi9zzcBwu(Jnlbxfwk)pyszz0e2SGe2lSuil23XKLhYc99(zbCvyDjjw0XjSrwiUnMLmkltxPOSaNZX8gE4pysnwngGf6(tGiilaVpxxHKp9cmckTgG0N8aC1cJiYLvQrAOzLzSPuu8R6WCrn)HTnrsLGTcJ5nixwaIpLf)zX((f2zXlGR8zbozzRuccledMaGeHSq3Hlfil6illkcwcSqWLXI973HRNfIHkK(NRybO113tzXtqwICzSy)(DdVHh(dMuJvJbyHU)eicYcW7Z1vi5tVaJiataqIWQtTipaxTWiICzeqJYkvVsCcBsOjGkK(NRQuRRVNYB4H)Gj1y1yawO7pbIGSfqys0L1jSl4n8WFWKASAmal09Narqw7T)7KxDjwdGrOrzK)MrmcdQZIIg1k9UMiH)HbmOolkAUSsHkVhgWG6SOO5YQo83hgWG6SOOXZO1ej8pM3G3GCzHG0yWPpl2Wcbv7)olEcYIZcW3B6QjHSatwawAwSF)olB5iT)SqCDKfpbzP8WTwAwGnlaFVNxJSa)DSTFuK3Wd)btQbAHj2eicYAV9FN83mIryqDwu0OwP31ej8pmGb1zrrZLvku59WaguNffnxw1H)(WaguNffnEgTMiH)XATAeGrdJ92)DT2A1iaJng7T)78gE4pysnqlmXMarqw6798AK8QlXAamcnr(BgHT9kXjSjHgDx5zaRWz1vQ6VFjj6WGTbiam98n5rA)RthhgSLAHkv99Me(ud99E6kveAmmy77kmFt6)QrAv3vEgqdMUUcbhggHb1zrrdfQ8UMiH)HbmOolkAUSQwP3ddyqDwu0Czvh(7ddyqDwu04z0AIe(hZB4H)Gj1aTWeBcebzPV3ZRrYRUeRbWi0e5VzeJSTxjoHnj0O7kpdyfoRUsv)9ljrhgSnabGPNVjps7FD64WGTuluPQV3KWNAOV3txPIqJHbBFxH5Bs)xnsR6UYZaAW01vi4yT2sXVQdZf18h22ejvBScddJWG6SOOHcvExtKW)WaguNffnxwvR07HbmOolkAUSQd)9HbmOolkA8mAnrc)J5n8WFWKAGwyInbIGS03B6QjHKxDjwdGrOjYFZig1ReNWMeA0DLNbScNvxPQ)(LKOAdqay65BYJ0(xNoQLAHkv99Me(ud99E6kveAmwRTu8R6WCrn)HTnrs1gRaVbVb5sUSqoegdRhbzbbGDuw(Raz53rw8WdBwokloa)uUUcn8gE4pysJGcvEx1rVG3Wd)btkbIGSbxPQE4pywvh9jF6fyeqlmXM80VVWhHgK)Mr8xbsOr2ukp8hmn2B)3nbN(1)kqc4H)GPH(EpVgnbN(1)kWX8gKllaXNYYwHKdlWKLitawSF)oC9Sa238zXtqwSF)olaFVvWgKfpbzXgcWc83X2(rrEdp8hmPeicYcW7Z1vi5tVaJ4OvhIKhGRwyeuluPQV3KWNAOV3txP2udTJS9DfMVH(ERGnObtxxHGddVRW8n0hvkVRG9nFdMUUcbhpmqTqLQ(EtcFQH(EpDLAtB4nixwaIpLLGcDail23XKfGV3ZRrwcEYY(9Sydby59Me(uwSVFHDwoklnQqaE(SmHnl)oYc5euNffz5HSOJSy14e7gbzXtqwSVFHDwMNsHnlpKLGtFEdp8hmPeicYcW7Z1vi5tVaJ4O1GcDai5b4Qfgb1cvQ67nj8Pg6798ACtn4nixwkX6956kKLF3Fwc7yGikl3KLOWflEJSCjlolKcGS8qwCaWdKLFhzHE)Y)dMSyFhBKfNLVVKi8zb)alhLLffbz5sw0X3oIjlbN(uEdp8hmPeicYcW7Z1vi5tVaJ4YkPai5b4QfgHvJaQKcGgnmfqyoVghgSAeqLua0OHHUY514WGvJaQKcGgnm03B6QjHddwncOskaA0WqFVNUsnmy1iGkPaOrdZC1rRWzfvRehgSAeGPDaycx06SXSKrhg0xZPj41ldMgl8lPrOVMttWRxgmGR2)dMdda8(CDfAoA1HiVb5Ys5srwkp2uSj6ssS4pl)oYcMGSaNSqCBmlzuwSVJjl7o9rwoklUoeaYcXVmIh5zXNp2SqmycaseYINGSa)DSTFuKf73VZcX2kzlNmWB4H)GjLarqwDSPyt0LKi)nJy0iBdqay65BYJ0(xNoomyBacvGq7PjataqIW6VJvQ113tnlRHHEL4e2Kqtavi9pxvPwxFpDSw91CAcE9YGPXc)s6MAOjT6R500oamHlAD2ywYOMgl8lPeIG1ABacatpFdam)9O9WqacatpFdam)9OTw91CAcE9YGzzPvFnNM2bGjCrRZgZsg1SS0osFnNM2bGjCrRZgZsg10yHFjLqrOHnAgbxQEL4e2Kqd9Y5sv3JsFSpFyqFnNMGxVmyASWVKsin0yyqdIh1cvQ6UtFKqAyi(JhRfG3NRRqZLvsbqEdYLfcc8zX(97S4SqSTs2YjdS87(ZYrZTFwCwiilf1BwSAyGfyZI9Dmz53rwMhP9NLJYIRdxplpKfmb5n8WFWKsGiiRf8pys(BgXi91CAcE9YGPXc)s6MAOjTJSTxjoHnj0qVCUu19O0h7Zhg0xZPPDaycx06SXSKrnnw4xsjKgAET6R500oamHlAD2ywYOML14HbDiLQDEK2)AJf(LuczJMgRfG3NRRqZLvsbqEdYLfI5QWs5pszX(o(7yZYIEjjwigmbajczjH2zX(PuS4kf0olrHlwEil0)ukwco9z53rwOEbYIxax5ZcCYcXGjairibi2wjB5Kbwco9P8gE4pysjqeKfG3NRRqYNEbgraMaGeHvqKgndKhGRwyeb8uJgnps7FTXc)sQMPHM0SaeQaH2ttWRxgmnw4xsht80iskBCeb8uJgnps7FTXc)sQMPHM0SaeQaH2ttaMaGeH1FhRuRRVNAaxT)hm1SaeQaH2ttaMaGeH1FhRuRRVNAASWVKoM4PrKu2yT22(bwray(gheKAqcF0NQDKTbiubcTNMGxVmyA0bJomyBacvGq7PjataqIqtJoy0XddbiubcTNMGxVmyASWVKU5Lp2wqL)iyDEK2)AJf(L0HHEL4e2Kqtavi9pxvPwxFpvBacvGq7Pj41ldMgl8lPBg5YggcqOceApnbycasew)DSsTU(EQPXc)s6Mx(yBbv(JG15rA)Rnw4xs1mnkByW2aeaME(M8iT)1PJ8gKllLlfbz5HSaIkpkl)oYYI6KqwGtwi2wjB5KbwSVJjll6LKybeU0vilWKLffzXtqwSAeaMpllQtczX(oMS4jloiiliamFwoklUoC9S8qwapK3Wd)btkbIGSa8(CDfs(0lWicG1ambV)Gj5b4QfgXO3Bs4B(RaRpScE4MAOPHH2pWkcaZ34GGuZLBQPYgRD0imsxNLfcAWcROn6QkSbtpdO2r2gGaW0Z3aaZFpApmeGqfi0EAWcROn6QkSbtpdOPXc)skH0G4tCiWinvQEL4e2Kqd9Y5sv3JsFSpF8yT2gGqfi0EAWcROn6QkSbtpdOPrhm64HbmsxNLfcAOWLsH)FjPAV0JQDKTbiam98n5rA)RthhgcqOceApnu4sPW)VKuTx6rRrMG1uKuMgMgl8lPesdni4XddJcqOceApn6ytXMOljzA0bJomyB7b08nuPggcqay65BYJ0(xNoow7iBFxH5BMRoAfoROALObtxxHGddbiam98naW83J2AdqOceApnZvhTcNvuTs00yHFjLqAObb0uP6vItytcn0lNlvDpk9X(8HbBdqay65BaG5VhT1gGqfi0EAMRoAfoROALOPXc)skH0xZPj41ldgWv7)btcOHnLQxjoHnj0y1xbSbpxv9o45fQwlf1BntdBgRD0imsxNLfcAUKg6176kSgPlp)vrfebCbuBacvGq7P5sAOxVRRWAKU88xfvqeWfqtJoy0XddJWiDDwwiOHU7Gq7iyf26v4S(WUaZxBacvGq7P5HDbMpcwVKEK2)AK1KMISnAyASWVKoEyy0iaEFUUcnWSUOy97ljc)i0yyaG3NRRqdmRlkw)(sIWpIipw7OVVKi8nAyA0bJwdqOceAphg((sIW3OHjaHkqO900yHFjDZlFSTGk)rW68iT)1gl8lPAMgLnEyaG3NRRqdmRlkw)(sIWpcB0o67ljcFJnMgDWO1aeQaH2ZHHVVKi8n2ycqOceApnnw4xs38YhBlOYFeSops7FTXc)sQMPrzJhga4956k0aZ6II1VVKi8JOSXJhZBqUSuI17Z1villkcYYdzbevEuw8mklFFjr4tzXtqwcGuwSVJjl297VKeltyZINSqolRDyFolwnmWB4H)GjLarqwaEFUUcjF6fye)EFkvLIiryxT73tEaUAHrylfUu6xcA(9(uQkfrIW2GPRRqWHH5rA)Rnw4xs30MYkByqhsPANhP9V2yHFjLq2OjcmIGltZ0xZP537tPQuejcBd99arLYMXdd6R50879PuvkIeHTH(EGOnJCKOzJ6vItytcn0lNlvDpk9X(8szZyEdYLLYLISqofwrB0vSuI2GPNbKfBkJIbkl64e2iloleBRKTCYallkYcSzHcz539NL7zX(PuSOUezzzXI973z53rwWeKf4KfIBJzjJYB4H)GjLarq2ffR3JfKp9cmcSWkAJUQcBW0Zas(BgracvGq7Pj41ldMgl8lPeYMY0gGqfi0EAcWeaKiS(7yLAD99utJf(LucztzAhbW7Z1vO537tPQuejc7QD)(Hb91CA(9(uQkfrIW2qFpq0MrUmcmQxjoHnj0qVCUu19O0h7ZlvKhpwlaVpxxHMlRKcGdd6qkv78iT)1gl8lPekYehEdYLLYLISaeUuk8VKele0w6rzH4tXaLfDCcBKfNfITvYwozGLffzb2SqHS87(ZY9Sy)ukwuxISSSyX(97S87ilycYcCYcXTXSKr5n8WFWKsGii7II17XcYNEbgbfUuk8)ljv7LEuYFZigfGqfi0EAcE9YGPXc)skHi(ATnabGPNVbaM)E0wRTbiam98n5rA)Rthhgcqay65BYJ0(xNoQnaHkqO90eGjairy93Xk1667PMgl8lPeI4RDeaVpxxHMambajcRGinAgggcqOceApnbVEzW0yHFjLqe)Xddbiam98naW83J2AhzBVsCcBsOHE5CPQ7rPp2NRnaHkqO90e86LbtJf(Lucr8hg0xZPPDaycx06SXSKrnnw4xsjKgLrGrAQuyKUolle0Cj97v4HnTcEaUeR6OsnwR(AonTdat4IwNnMLmQzznEyqhsPANhP9V2yHFjLq2OPHbmsxNLfcAWcROn6QkSbtpdO2aeQaH2tdwyfTrxvHny6zannw4xs30MYgRfG3NRRqZLvsbqT2Ir66SSqqZL0qVExxH1iD55VkQGiGlGddbiubcTNMlPHE9UUcRr6YZFvubraxannw4xs30MYgg0HuQ25rA)Rnw4xsjKnLXBqUSSvLDpkLLffzPCkXuZXI973zHyBLSLtgyb2S4pl)oYcMGSaNSqCBmlzuEdp8hmPeicYcW7Z1vi5tVaJ4IuWAaMG3FWK8aC1cJqFnNMGxVmyASWVKUPgAs7iB7vItytcn0lNlvDpk9X(8Hb91CAAhaMWfToBmlzutJf(LucfHgAYOjcmkYgnvk91CA0vqiOArFZYAmbgrWgnPzr2OPsPVMtJUccbvl6BwwJlfgPRZYcbnxs)EfEytRGhGlXQoQuA1xZPPDaycx06SXSKrnlRXdd6qkv78iT)1gl8lPeYgnnmGr66SSqqdwyfTrxvHny6za1gGqfi0EAWcROn6QkSbtpdOPXc)skVHh(dMucebzxuSEpwq(0lWiUKg6176kSgPlp)vrfebCbK83mcaEFUUcnxKcwdWe8(dMAb4956k0CzLuaK3GCzPCPila3DqODeKLs0wNfDCcBKfITvYwozG3Wd)btkbIGSlkwVhliF6fye0DheAhbRWwVcN1h2fy(K)MrmkaHkqO90e86LbtJoyuT2gGaW0Z3KhP9VoDulaVpxxHMFVpLQsrKiSR2971okaHkqO90OJnfBIUKKPrhm6WGTThqZ3qLA8WqacatpFtEK2)60rTbiubcTNMambajcR)owPwxFp10Odgv7iaEFUUcnbycasewbrA0mmmeGqfi0EAcE9YGPrhm64XAbHVHUY51O5Varxss7iq4BOpQuExNkVrZFbIUK0WGTVRW8n0hvkVRtL3ObtxxHGdduluPQV3KWNAOV3ZRXnJ8yTGW3uaH58A08xGOljPDeaVpxxHMJwDiom0ReNWMeA0DLNbScNvxPQ)(LKOddo9BxvTG2XEZi08LnmaW7Z1vOjataqIWkisJMHHb91CA0vqiOArFZYASwBXiDDwwiO5sAOxVRRWAKU88xfvqeWfWHbmsxNLfcAUKg6176kSgPlp)vrfebCbuBacvGq7P5sAOxVRRWAKU88xfvqeWfqtJf(L0nJCzATvFnNMGxVmywwdd6qkv78iT)1gl8lPeIGlJ3GCzP07hLLJYIZs7)o2SGkxh2(JSy3JYYdzPWjczXvkwGjllkYc99NLVVKi8PS8qw0rwuxIGSSSyX(97SqSTs2YjdS4jiledMaGeHS4jillkYYVJSytcYcvbFwGjlbqwUjl6WFNLVVKi8PS4nYcmzzrrwOV)S89LeHpL3Wd)btkbIGSlkwVhlOKNQGpnIVVKi81G83mIra8(CDfAGzDrX63xse(2gHgAT97ljcFJnMgDWO1aeQaH2ZHHra8(CDfAGzDrX63xse(rOXWaaVpxxHgywxuS(9LeHFerES2r6R50e86LbZYs7iBdqay65BaG5VhThg0xZPPDaycx06SXSKrnnw4xsjWOiB0uP6vItytcn0lNlvDpk9X(8XekIVVKi8nAy0xZzfC1(FWuR(AonTdat4IwNnMLmQzznmOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95ML14HHaeQaH2ttWRxgmnw4xsjGnB(9LeHVrdtacvGq7PbC1(FWuRT6R50e86LbZYs7iBdqay65BYJ0(xNoomylaVpxxHMambajcRGinAggR12aeaME(gII2NNddbiam98n5rA)Rth1cW7Z1vOjataqIWkisJMbTbiubcTNMambajcR)owPwxFp1SS0ABacvGq7Pj41ldMLL2rJ0xZPbdQZIIv1k920yHFjDtnkByqFnNgmOolkwPqL3Mgl8lPBQrzJ1ABVsCcBsOr3vEgWkCwDLQ(7xsIommsFnNgDx5zaRWz1vQ6VFjjAn9F1OH(EGOi00WG(Aon6UYZawHZQRu1F)ss0Q3bprd99arrejJhpmOVMtdrxc2iyflSG2XUaZVIj2KUsIML14HbDiLQDEK2)AJf(Lucztzdda8(CDfAGzDrX63xse(ru2yTa8(CDfAUSskaYB4H)GjLarq2ffR3JfuYtvWNgX3xse(2q(BgXiaEFUUcnWSUOy97ljcFBJWgT2(9LeHVrdtJoy0AacvGq75WaaVpxxHgywxuS(9LeHFe2ODK(AonbVEzWSS0oY2aeaME(gay(7r7Hb91CAAhaMWfToBmlzutJf(LucmkYgnvQEL4e2Kqd9Y5sv3JsFSpFmHI47ljcFJng91CwbxT)hm1QVMtt7aWeUO1zJzjJAwwdd6R500oamHlAD2ywYOv6LZLQUhL(yFUzznEyiaHkqO90e86LbtJf(LucyZMFFjr4BSXeGqfi0EAaxT)hm1AR(AonbVEzWSS0oY2aeaME(M8iT)1PJdd2cW7Z1vOjataqIWkisJMHXATnabGPNVHOO95P2r2QVMttWRxgmlRHbBdqay65BaG5VhThpmeGaW0Z3KhP9VoDulaVpxxHMambajcRGinAg0gGqfi0EAcWeaKiS(7yLAD99uZYsRTbiubcTNMGxVmywwAhnsFnNgmOolkwvR0BtJf(L0n1OSHb91CAWG6SOyLcvEBASWVKUPgLnwRT9kXjSjHgDx5zaRWz1vQ6VFjj6WWi91CA0DLNbScNvxPQ)(LKO10)vJg67bIIqtdd6R50O7kpdyfoRUsv)9ljrREh8en03defrKmE84Hb91CAi6sWgbRyHf0o2fy(vmXM0vs0SSgg0HuQ25rA)Rnw4xsjKnLnmaW7Z1vObM1ffRFFjr4hrzJ1cW7Z1vO5YkPaiVb5Ys5srklUsXc83XMfyYYIISCpwqzbMSea5n8WFWKsGii7II17XckVb5Yc5C)o2SqcYYLpKLFhzH(SaBwCiYIh(dMSOo6ZB4H)GjLarq2ELvp8hmRQJ(Kp9cmchIKN(9f(i0G83mcaEFUUcnhT6qK3Wd)btkbIGS9kRE4pywvh9jF6fye0N3G3GCzHyUkSu(JuwSVJ)o2S87ilAUg9IG)HDSzrFnNSy)ukwMUsXcCozX(97xYYVJSKiHFwco95n8WFWKACigbaVpxxHKp9cmcWg9IQ9tPQtxPQW5K8aC1cJOxjoHnj08xbAh2zfSrVq)sqS1osFnNM)kq7WoRGn6f6xcITPXc)skHifanfoHjqzgngg0xZP5Vc0oSZkyJEH(LGyBASWVKsip8hmn03751Objmgwpw)Rajqzgn0ocdQZIIMlRQv69WaguNffnuOY7AIe(hgWG6SOOXZO1ej8pESw91CA(RaTd7Sc2OxOFji2MLfVb5YcXCvyP8hPSyFh)DSzb47nD1Kqwokl2H9VZsWP)LKybcaBwa(EpVgz5swiZv6nlKtqDwuK3Wd)btQXHibIGSa8(CDfs(0lWiosjSXk99MUAsi5b4QfgHTyqDwu0CzLcvERLAHkv99Me(ud99EEnUjXrZExH5BOWLQcN1FhRtyJ03GPRRqWszdbWG6SOO5YQo831ABVsCcBsOXQVcydEUQ6DWZluTwkQ3ATTxjoHnj0at83P1Gc9Uc4Ohm5nixwkxkYcXGjairil23XKf)zrHukl)UNSOPYyzRucclEcYI6sKLLfl2VFNfITvYwozG3Wd)btQXHibIGSbycasew)DSsTU(Ek5Vze2c2Rd0KWAaKQD0iaEFUUcnbycasewbrA0mO12aeQaH2ttWRxgmn6Grhg0xZPj41ldML1yTJ0xZPbdQZIIv1k920yHFjDtnnmOVMtdguNffRuOYBtJf(L0n10yTJC63UQAbTJnH0uzAhrTqLQ(EtcFQH(EpVg3mYdd6R50e86LbZYA8WGT9kXjSjHgR(kGn45QQ3bpVq1APOEpw7iBFxH5BOpQuExb7B(dd6R50qFVNUszASWVKsinmAsZkZOPs1ReNWMeAcOcP)5Qk1667Pdd6R50e86LbtJf(LucPVMtd99E6kLPXc)skb0Kw91CAcE9YGzznw7iB7vItytcn6UYZawHZQRu1F)ss0Hb91CA0DLNbScNvxPQ)(LKO10)vJg67bI2mYdd6R50O7kpdyfoRUsv)9ljrREh8en03deTzKhpmOdPuTZJ0(xBSWVKsinktBacvGq7Pj41ldMgl8lPBQPX8gKllLlfzb4kNxJSCjlwEcIfxGfyYINr)9ljXYV7plQdaszrdcMIbklEcYIcPuwSF)olfWgz59Me(uw8eKf)z53rwWeKf4KfNfGqL3Sqob1zrrw8NfniywOyGYcSzrHuklnw4xEjjwCklpKLe(SS7aUKelpKLgNns3zbC1xsIfYCLEZc5euNff5n8WFWKACisGiilDLZRrYhIguy99Me(0i0G83mIrnoBKU76kCyqFnNgmOolkwPqL3Mgl8lPekYAXG6SOO5YkfQ8wBJf(LucPbbR9DfMVHcxQkCw)DSoHnsFdMUUcbhR99Me(M)kW6dRGhUPgeSMrTqLQ(EtcFkbASWVKQDeguNffnxw9m6WqJf(LucrkaAkCcpM3GCzPCPilax58AKLhYYUdazXzHKcQ7kwEillkYs5uIPMJ3Wd)btQXHibIGS0voVgj)nJaG3NRRqZfPG1ambV)GP2aeQaH2tZL0qVExxH1iD55VkQGiGlGMgDWOAXiDDwwiO5sAOxVRRWAKU88xfvqeWfqTUvnSJbI4nixwkXHOflllwa(EpDLIf)zXvkw(RaPSSsfsPSSOxsIfYmAWBNYINGSCplhLfxhUEwEilwnmWcSzrHpl)oYc1cdNRyXd)btwuxISOJkODw29euHSO5A0l0VeeBwGjl2WY7nj8P8gE4pysnoejqeKL(EpDLI83mcBFxH5BOpQuExb7B(gmDDfcQDKTu8R6WCrn)HTnrsLGTcddyqDwu0Cz1ZOdduluPQV3KWNAOV3txP2mYJ1osFnNg6790vktJZgP7UUc1oIAHkv99Me(ud99E6kfHI8WGT9kXjSjHM)kq7WoRGn6f6xcI94HH3vy(gkCPQWz93X6e2i9ny66keuR(AonyqDwuSsHkVnnw4xsjuK1Ib1zrrZLvku5Tw91CAOV3txPmnw4xsjeXrl1cvQ67nj8Pg6790vQnJGGhRDKT9kXjSjHgv0G3oTovi(xsQssDfwuCy4VcK4r8iynTP(Aon037PRuMgl8lPeWMXAFVjHV5VcS(Wk4HBQjEdYLfcQ73zb4JkL3SO56B(SSOilWKLail23XKLgNns3DDfYI(6zH(NsXID)EwMWMfYmAWBNYIvddS4jilGWC7NLffzrhNWgzHyAoQHfG)PuSSOil64e2iledMaGeHSqVmGS87(ZI9tPyXQHbw8e(7yZcW37PRu8gE4pysnoejqeKL(EpDLI83mI3vy(g6JkL3vW(MVbtxxHGA1xZPH(EpDLY04Sr6URRqTJSLIFvhMlQ5pSTjsQeSvyyadQZIIMlREgDyGAHkv99Me(ud99E6k1Me8yTJSTxjoHnj0OIg82P1PcX)ssvsQRWIIdd)vGepIhbRPnj4XAFVjHV5VcS(Wk4HBgzEdYLfcQ73zrZ1OxOFji2SSOilaFVNUsXYdzHieTyzzXYVJSOVMtw0JYIROqww0ljXcW37PRuSatw0elumatqklWMffsPS0yHF5LK4n8WFWKACisGiil99E6kf5Vze9kXjSjHM)kq7WoRGn6f6xcITwQfQu13Bs4tn037PRuBgrK1oYw91CA(RaTd7Sc2OxOFji2MLLw91CAOV3txPmnoBKU76kCyyeaVpxxHgWg9IQ9tPQtxPQW5u7i91CAOV3txPmnw4xsjuKhgOwOsvFVjHp1qFVNUsTPnAFxH5BOpQuExb7B(gmDDfcQvFnNg6790vktJf(LucPPXJhZBqUSqmxfwk)rkl23XFhBwCwa(EtxnjKLffzX(PuSe8ffzb4790vkwEiltxPyboNKNfpbzzrrwa(EtxnjKLhYcriAXIMRrVq)sqSzH(EGiwwwgwIKYy5OS87ilngPRRrqw2kLGWYdzj40NfGV30vtcjaW37PRu8gE4pysnoejqeKfG3NRRqYNEbgb99E6kv1om)60vQkCojpaxTWiC63UQAbTJ9MrszLAKgAgf)QomxuZFyBtKuTXkuQYm2mUuJ0qZ0xZP5Vc0oSZkyJEH(LGyBOVhiQuLz0ySMnsFnNg6790vktJf(L0sfzIh1cvQ6UtFSu2(UcZ3qFuP8Uc238ny66keCSMnkaHkqO90qFVNUszASWVKwQit8OwOsv3D6JL6DfMVH(Os5DfSV5BW01vi4ynBK(AonZvhTcNvuTs00yHFjTuAAS2r6R50qFVNUszwwddbiubcTNg6790vktJf(L0X8gKllLlfzb47nD1KqwSF)olAUg9c9lbXMLhYcriAXYYILFhzrFnNSy)(D46zrbPxsIfGV3txPyzz9xbYINGSSOilaFVPRMeYcmzHGjalLhU1sZc99aruww5FkwiywEVjHpL3Wd)btQXHibIGS03B6QjHK)MraW7Z1vObSrVOA)uQ60vQkCo1cW7Z1vOH(EpDLQAhMFD6kvfoNATfG3NRRqZrkHnwPV30vtchggPVMtJUR8mGv4S6kv93VKeTM(VA0qFpq0MrEyqFnNgDx5zaRWz1vQ6VFjjA17GNOH(EGOnJ8yTuluPQV3KWNAOV3txPiebRfG3NRRqd99E6kv1om)60vQkCo5nixwkxkYc1U3fSqHS87(Zsu4Ifs4ZsHtywww)vGSOhLLf9ssSCploLfL)iloLfliLE6kKfyYIcPuw(DpzjYSqFpqeLfyZsjgl6ZI9DmzjYeGf67bIOSGe26AK3Wd)btQXHibIGSoOB9haSsT7Db5drdkS(EtcFAeAq(BgHT)fi6ssAT1d)btJd6w)baRu7Exub9cNeAUSovhP9Fyae(gh0T(dawP29UOc6foj0qFpqeHISwq4BCq36payLA37IkOx4KqtJf(LucfzEdYLfcA4Sr6olLiqyoVgz5MSqSTs2YjdSCuwA0bJsEw(DSrw8gzrHukl)UNSOjwEVjHpLLlzHmxP3Sqob1zrrwSF)olaHpXL8SOqkLLF3tw0OmwG)o22pkYYLS4zuwiNG6SOilWMLLflpKfnXY7nj8PSOJtyJS4SqMR0BwiNG6SOOHfnhm3(zPXzJ0Dwax9LKyPe3LGncYc5uybTJDbMplRuHuklxYcqOYBwiNG6SOiVHh(dMuJdrcebzlGWCEns(q0GcRV3KWNgHgK)Mr04Sr6URRqTV3KW38xbwFyf8WnhnsdcMaJOwOsvFVjHp1qFVNxJLYMsPVMtdguNffRQv6TzznEmbASWVKoM4nsdc8UcZ382VSwaHj1GPRRqWXAh5w1WogiAyaG3NRRqZrkHnwPV30vtchgSfdQZIIMlREgDS2rbiubcTNMGxVmyA0bJQfdQZIIMlREgvRTG96anjSgaPAhbW7Z1vOjataqIWkisJMHHHaeQaH2ttaMaGeH1FhRuRRVNAA0bJomyBacatpFtEK2)60XXdduluPQV3KWNAOV3ZRrcnAeXxZgPVMtdguNffRQv6TzzvkBgpUuJ0GaVRW8nV9lRfqysny66keC8yT2Ib1zrrdfQ8UMiHFT2gGqfi0EAcE9YGPrhm6WWimOolkAUSsHkVhg0xZPbdQZIIv1k92SS0A77kmFdfUuv4S(7yDcBK(gmDDfcomOVMtJvFfWg8Cv17GNxOATuuVnaC1c3mcB0uzJ1oIAHkv99Me(ud99EEnsinkRuJ0GaVRW8nV9lRfqysny66keC8yTo9BxvTG2XEtnvMMPVMtd99E6kLPXc)sAPi(J1oY2aeaME(gII2NNdd2QVMtdrxc2iyflSG2XUaZVIj2KUsIML1WaguNffnxwPqL3J1AR(AonTdat4IwNnMLmALE5CPQ7rPp2NBww8gKllLlfzH4c3clWKLail2VFhUEwcUL1LK4n8WFWKACisGii7e2bScN10)vJK)Mr4w1WogiAyaG3NRRqZrkHnwPV30vtc5n8WFWKACisGiilaVpxxHKp9cmIaynatW7pywDisEaUAHrylyVoqtcRbqQ2ra8(CDfAcG1ambV)GP2r6R50qFVNUszwwddVRW8n0hvkVRG9nFdMUUcbhgcqay65BYJ0(xNoowli8nfqyoVgn)fi6ssAhzR(AonuOI(xanllT2QVMttWRxgmllTJS9DfMVzU6Ov4SIQvIgmDDfcomOVMttWRxgmGR2)dMBgGqfi0EAMRoAfoROALOPXc)skbIKXAhzlf)QomxuZFyBtKuTXkmmGb1zrrZLv1k9EyadQZIIgku5Dnrc)J1cW7Z1vO537tPQuejc7QD)ETJSnabGPNVjps7FD64WqacvGq7PjataqIW6VJvQ113tnnw4xsjK(AonbVEzWaUA)pywQYmAAS23Bs4B(RaRpScE4M6R50e86Lbd4Q9)GzPkZqCgpmOdPuTZJ0(xBSWVKsi91CAcE9YGbC1(FWKaAytP6vItytcnw9vaBWZvvVdEEHQ1sr9EmVb5Ys5srwiUnMLmkl2VFNfITvYwozG3Wd)btQXHibIGSTdat4IwNnMLmk5Vze6R50e86LbtJf(L0n1qtdd6R50e86Lbd4Q9)Gjb0WMs1ReNWMeAS6Ra2GNRQEh88cvRLI6nHSH4RfG3NRRqtaSgGj49hmRoe5nixwkxkYcX2kzlNmWcmzjaYYkviLYINGSOUez5EwwwSy)(Dwigmbajc5n8WFWKACisGiiBavi9pxvD1rklW8j)nJaG3NRRqtaSgGj49hmRoe1osFnNMGxVmyaxT)hmjGg2uQEL4e2KqJvFfWg8Cv17GNxOATuuV3mcBi(dd2gGaW0Z3aaZFpApEyqFnNM2bGjCrRZgZsg1SS0QVMtt7aWeUO1zJzjJAASWVKsinpbcWeCDVXQXWrXQRoszbMV5VcScWvlKaJSvFnNgDfecQw03SS0A77kmFd99wbBqdMUUcbhZB4H)Gj14qKarq2ldEN(FWK83mcaEFUUcnbWAaMG3FWS6qK3GCzPCPilKtHf0o2SuEycYcmzjaYI973zb4790vkwwwS4jiluhaYYe2SqqwkQ3S4jileBRKTCYaVHh(dMuJdrcebzXclODSR6WeK83mIrbiubcTNMGxVmyASWVKsa91CAcE9YGbC1(FWKa9kXjSjHgR(kGn45QQ3bpVq1APOExknSzZaeQaH2tdwybTJDvhMGgWv7)btcOrzJhg0xZPj41ldMgl8lPBgjddG96anjSgaP8gKlle0WzJ0DwMkVrwGjlllwEilrML3Bs4tzX(97W1ZcX2kzlNmWIoEjjwCD46z5HSGe26AKfpbzjHplqayhClRljXB4H)Gj14qKarqw6JkL31PYBK8HObfwFVjHpncni)nJOXzJ0DxxHA)RaRpScE4MAOjTuluPQV3KWNAOV3ZRrcrWADRAyhdePDK(AonbVEzW0yHFjDtnkByWw91CAcE9YGzznM3GCzPCPilexi5WYnz5s6bIS4jlKtqDwuKfpbzrDjYY9SSSyX(97S4SqqwkQ3Sy1WalEcYYwbDR)aGSa0U3f8gE4pysnoejqeKDU6Ov4SIQvIK)MrGb1zrrZLvpJQDKBvd7yGOHbB7vItytcnw9vaBWZvvVdEEHQ1sr9ES2r6R50y1xbSbpxv9o45fQwlf1BdaxTqczJMkByqFnNMGxVmyASWVKUzKmw7iq4BCq36payLA37IkOx4KqZFbIUK0WGTbiam98njgAOc2GdduluPQV3KWNUPnJ1osFnNM2bGjCrRZgZsg10yHFjLqAEnBebxQEL4e2Kqd9Y5sv3JsFSpFSw91CAAhaMWfToBmlzuZYAyWw91CAAhaMWfToBmlzuZYAS2r2gGqfi0EAcE9YGzznmOVMtZV3NsvPise2g67bIiKgAs78iT)1gl8lPeYMYkt78iT)1gl8lPBQrzLnmylfUu6xcA(9(uQkfrIW2GPRRqWXAhrHlL(LGMFVpLQsrKiSny66keCyiaHkqO90e86LbtJf(L0nJCzJ1(EtcFZFfy9HvWd3utdd6qkv78iT)1gl8lPesJY4nixwkxkYIZcW37PRuSuIM4VZIvddSSsfsPSa89E6kflhLfx1OdgLLLflWMLOWflEJS46W1ZYdzbca7GBXYwPeeEdp8hmPghIeicYsFVNUsr(BgH(AonWe)DA1c7aA9hmnllTJ0xZPH(EpDLY04Sr6URRWHbN(TRQwq7yVPMVSX8gKllAUvHflBLsqyrhNWgzHyWeaKiKf73VZcW37PRuS4jil)oMSa89MUAsiVHh(dMuJdrcebzPV3txPi)nJiabGPNVjps7FD6OwBFxH5BOpQuExb7B(gmDDfcQDeaVpxxHMambajcRGinAgggcqOceApnbVEzWSSgg0xZPj41ldML1yTbiubcTNMambajcR)owPwxFp10yHFjLqKcGMcNWLkGNAKt)2vvlODSjEAQSXA1xZPH(EpDLY0yHFjLqeSwBb71bAsynas5n8WFWKACisGiil99MUAsi5Vzebiam98n5rA)Rth1ocG3NRRqtaMaGeHvqKgndddbiubcTNMGxVmywwdd6R50e86LbZYAS2aeQaH2ttaMaGeH1FhRuRRVNAASWVKsinPfG3NRRqd99E6kv1om)60vQkCo1Ib1zrrZLvpJQ1waEFUUcnhPe2yL(EtxnjuRTG96anjSgaP8gKllLlfzb47nD1KqwSF)olEYsjAI)olwnmWcSz5MSefU2gKfiaSdUflBLsqyX(97SefUAwsKWplbN(gw2QIczbCvyXYwPeew8NLFhzbtqwGtw(DKLsSy(7rBw0xZjl3KfGV3txPyXoCPaZTFwMUsXcCozb2SefUyXBKfyYInS8EtcFkVHh(dMuJdrcebzPV30vtcj)nJqFnNgyI)oTguO3vah9GPzznmmYw6798A04w1WogisRTa8(CDfAosjSXk99MUAs4WWi91CAcE9YGPXc)skH0Kw91CAcE9YGzznmmAK(AonbVEzW0yHFjLqKcGMcNWLkGNAKt)2vvlODSjEa8(CDfAO0Aas)XA1xZPj41ldML1WG(AonTdat4IwNnMLmALE5CPQ7rPp2NBASWVKsisbqtHt4sfWtnYPF7QQf0o2epaEFUUcnuAnaP)yT6R500oamHlAD2ywYOv6LZLQUhL(yFUzznwBacatpFdam)9O94XAhrTqLQ(EtcFQH(EpDLIqrEyaG3NRRqd99E6kv1om)60vQkCohpwRTa8(CDfAosjSXk99MUAsO2r22ReNWMeA(RaTd7Sc2OxOFji2dduluPQV3KWNAOV3txPiuKhZBqUSuUuKLseimPSCjlaHkVzHCcQZIIS4jiluhaYcXDPuSuIaHjltyZcX2kzlNmWB4H)Gj14qKarq2eTxlGWK83mIr6R50Gb1zrXkfQ820yHFjDtKWyy9y9VcCyyuy3BsincB02yy3Bsy9VcKqAA8Wqy3BsinIipwRBvd7yGiEdp8hmPghIeicYU7QzTactYFZigPVMtdguNffRuOYBtJf(L0nrcJH1J1)kWHHrHDVjH0iSrBJHDVjH1)kqcPPXddHDVjH0iI8yTUvnSJbI0osFnNM2bGjCrRZgZsg10yHFjLqAsR(AonTdat4IwNnMLmQzzP12EL4e2Kqd9Y5sv3JsFSpFyWw91CAAhaMWfToBmlzuZYAmVHh(dMuJdrcebzNlLQwaHj5VzeJ0xZPbdQZIIvku5TPXc)s6MiHXW6X6FfO2rbiubcTNMGxVmyASWVKUPMkByiaHkqO90eGjairy93Xk1667PMgl8lPBQPYgpmmkS7njKgHnABmS7njS(xbsinnEyiS7njKgrKhR1TQHDmqK2r6R500oamHlAD2ywYOMgl8lPestA1xZPPDaycx06SXSKrnllT22ReNWMeAOxoxQ6Eu6J95dd2QVMtt7aWeUO1zJzjJAwwJ5nixwkxkYcbfKCybMSqmnhVHh(dMuJdrcebzT7DFWUcNvuTsK3GCzHyUkSu(JuwSVJ)o2S8qwwuKfGV3ZRrwUKfGqL3SyF)c7SCuw8NfnXY7nj8PeqdwMWMfea2rzXMYiESu40h7OSaBwiywa(EtxnjKfYPWcAh7cmFwOVhiIYB4H)Gj14qKarqwaEFUUcjF6fye03751y9YkfQ8M8aC1cJGAHkv99Me(ud99EEnUjbtGPcc7rfo9XoAfGRwyP0OSYiE2u2ycmvqypsFnNg67nD1KWkwybTJDbMFLcvEBOVhiI4rWJ5nixwiMRclL)iLf774VJnlpKfcQ2)Dwax9LKyH42ywYO8gE4pysnoejqeKfG3NRRqYNEbgH92)96L1zJzjJsEaUAHrObXJAHkvD3PpsiB0SrLzSPuJOwOsvFVjHp1qFVNxJAMgJl1iniW7kmFdfUuv4S(7yDcBK(gmDDfcwknmAA8ycuMrdnvk91CAAhaMWfToBmlzutJf(LuEdYLLYLISqq1(VZYLSaeQ8MfYjOolkYcSz5MSKqwa(EpVgzX(PuSmVNLlFileBRKTCYalEgTa2iVHh(dMuJdrcebzT3(Vt(BgXimOolkAuR07AIe(hgWG6SOOXZO1ej8RfG3NRRqZrRbf6aWXAh9EtcFZFfy9HvWd3KGhgWG6SOOrTsVRxwTzyqhsPANhP9V2yHFjLqAu24Hb91CAWG6SOyLcvEBASWVKsip8hmn03751Objmgwpw)Ra1QVMtdguNffRuOYBZYAyadQZIIMlRuOYBT2cW7Z1vOH(EpVgRxwPqL3dd6R50e86LbtJf(Luc5H)GPH(EpVgniHXW6X6FfOwBb4956k0C0AqHoauR(AonbVEzW0yHFjLqiHXW6X6FfOw91CAcE9YGzznmOVMtt7aWeUO1zJzjJAwwAb4956k0yV9FVEzD2ywYOdd2cW7Z1vO5O1GcDaOw91CAcE9YGPXc)s6MiHXW6X6FfiVb5Ys5srwa(EpVgz5MSCjlK5k9MfYjOolksEwUKfGqL3Sqob1zrrwGjlemby59Me(uwGnlpKfRggybiu5nlKtqDwuK3Wd)btQXHibIGS03751iVb5YcX1vQFVx8gE4pysnoejqeKTxz1d)bZQ6Op5tVaJy6k1V3lEdEdYLfGV30vtczzcBwkGaWcmFwwPcPuww0ljXs5HBT08gE4pysntxP(9Efb99MUAsi5Vze22ReNWMeA0DLNbScNvxPQ)(LKOgmsxNLfcYBqUSqmN(S87ilGWNf73VZYVJSuaPpl)vGS8qwCqqww5Fkw(DKLcNWSaUA)pyYYrzz)Edlax58AKLgl8lPSuSu)zPoeKLhYsH)HDwkGWCEnYc4Q9)GjVHh(dMuZ0vQFVxeicYsx58AK8HObfwFVjHpncni)nJae(McimNxJMgl8lPB2yHFjTu2ydXtJiH3Wd)btQz6k1V3lcebzlGWCEnYBWBqUSuUuKLTc6w)bazbODVlyX(oMS87yJSCuwsilE4pailu7ExqEwCklk)rwCklwqk90vilWKfQDVlyX(97SydlWMLjAhBwOVhiIYcSzbMS4SezcWc1U3fSqHS87(ZYVJSKODwO29UGfV7daszPeJf9zXNp2S87(Zc1U3fSGe26AKYB4H)Gj1q)iCq36payLA37cYhIguy99Me(0i0G83mcBbHVXbDR)aGvQDVlQGEHtcn)fi6ssAT1d)btJd6w)baRu7Exub9cNeAUSovhP9x7iBbHVXbDR)aGvQDVlQ7ORm)fi6ssddGW34GU1FaWk1U3f1D0vMgl8lPBQPXddGW34GU1FaWk1U3fvqVWjHg67bIiuK1ccFJd6w)baRu7Exub9cNeAASWVKsOiRfe(gh0T(dawP29UOc6foj08xGOljXBqUSuUuKYcXGjairil3KfITvYwozGLJYYYIfyZsu4IfVrwarA0mCjjwi2wjB5KbwSF)oledMaGeHS4jilrHlw8gzrhvq7SqWLr2ix2iIHkK(NRybO113thZYwPeewUKfNfnkJaSqXalKtqDwu0WYwvuilGWC7Nff(SO5A0l0VeeBwqcBDnsEwCLDpkLLffz5swi2wjB5KbwSF)oleKLI6nlEcYI)S87il037Nf4KfNLYd3APzX(LGq7gEdp8hmPg6tGiiBaMaGeH1FhRuRRVNs(BgHTG96anjSgaPAhncG3NRRqtaMaGeHvqKgndATnaHkqO90e86LbtJoyuT22ReNWMeAS6Ra2GNRQEh88cvRLI69WG(AonbVEzWSSgRD0iN(TRQwq7ytOia4956k0eGjairy1PwAhPVMtdguNffRQv6TPXc)s6MAu2WG(AonyqDwuSsHkVnnw4xs3uJYgpmOVMttWRxgmnw4xs3utA1xZPj41ldMgl8lPekcnSzS2r22ReNWMeA(RaTd7Sc2OxOFji2dd22ReNWMeAcOcP)5Qk1667Pdd6R508xbAh2zfSrVq)sqSnnw4xs3ejmgwpw)Rahpm0ReNWMeA0DLNbScNvxPQ)(LKOJ1oY2EL4e2KqJUR8mGv4S6kv93VKeDyyK(Aon6UYZawHZQRu1F)ss0A6)Qrd99arrejdd6R50O7kpdyfoRUsv)9ljrREh8en03defrKmE8WGoKs1ops7FTXc)skH0OmT2gGqfi0EAcE9YGPrhm6yEdYLLYLISa89MUAsilpKfIq0ILLfl)oYIMRrVq)sqSzrFnNSCtwUNf7WLcKfKWwxJSOJtyJSmV8O7xsILFhzjrc)SeC6ZcSz5HSaUkSyrhNWgzHyWeaKiK3Wd)btQH(eicYsFVPRMes(BgrVsCcBsO5Vc0oSZkyJEH(LGyRDKTJgPVMtZFfODyNvWg9c9lbX20yHFjDtp8hmn2B)3niHXW6X6FfibkZOH2ryqDwu0Czvh(7ddyqDwu0CzLcvEpmGb1zrrJALExtKW)4Hb91CA(RaTd7Sc2OxOFji2Mgl8lPB6H)GPH(EpVgniHXW6X6FfibkZOH2ryqDwu0CzvTsVhgWG6SOOHcvExtKW)WaguNffnEgTMiH)XJhgSvFnNM)kq7WoRGn6f6xcITzznEyyK(AonbVEzWSSgga4956k0eGjairyfePrZWyTbiubcTNMambajcR)owPwxFp10OdgvBacatpFtEK2)60rTJ0xZPbdQZIIv1k920yHFjDtnkByqFnNgmOolkwPqL3Mgl8lPBQrzJhRDKTbiam98nefTpphgcqOceApnyHf0o2vDycAASWVKUzKmM3GCzrZTkSyb47nD1Kqkl2VFNLY7kpdilWjlBvPyP07xsIYcSz5HSy1OL3iltyZcXGjairil2VFNLYd3AP5n8WFWKAOpbIGS03B6QjHK)Mr0ReNWMeA0DLNbScNvxPQ)(LKOAhnsFnNgDx5zaRWz1vQ6VFjjAn9F1OH(EGOnTzyqFnNgDx5zaRWz1vQ6VFjjA17GNOH(EGOnTzS2aeQaH2ttWRxgmnw4xs3K4O12aeQaH2ttaMaGeH1FhRuRRVNAwwddJcqay65BYJ0(xNoQnaHkqO90eGjairy93Xk1667PMgl8lPesJY0Ib1zrrZLvpJQ1PF7QQf0o2BAtzeiYLvQaeQaH2ttWRxgmn6GrhpM3GCzHyWe8(dMSmHnlUsXci8PS87(ZsHteszHUAKLFhJYI3yU9ZsJZgP7iil23XKfcAoamHlkle3gZsgLLDNYIcPuw(DpzrtSqXaLLgl8lVKelWMLFhzHCkSG2XMLYdtqw0xZjlhLfxhUEwEiltxPyboNSaBw8mklKtqDwuKLJYIRdxplpKfKWwxJ8gE4pysn0NarqwaEFUUcjF6fyeGWV2yKUUglW8PKhGRwyeJ0xZPPDaycx06SXSKrnnw4xs3utdd2QVMtt7aWeUO1zJzjJAwwJ1AR(AonTdat4IwNnMLmALE5CPQ7rPp2NBwwAhPVMtdrxc2iyflSG2XUaZVIj2KUsIMgl8lPeIua0u4eES2r6R50Gb1zrXkfQ820yHFjDtsbqtHt4Hb91CAWG6SOyvTsVnnw4xs3Kua0u4eEyyKT6R50Gb1zrXQALEBwwdd2QVMtdguNffRuOYBZYASwBFxH5BOqf9VaAW01vi4yEdYLfIbtW7pyYYV7plHDmqeLLBYsu4IfVrwGRNEGilyqDwuKLhYcmvrzbe(S87yJSaBwosjSrw(9JYI973zbiur)lG8gE4pysn0NarqwaEFUUcjF6fyeGWVcxp9aXkguNffjpaxTWigzR(AonyqDwuSsHkVnllT2QVMtdguNffRQv6TzznwRTVRW8nuOI(xany66keuRT9kXjSjHM)kq7WoRGn6f6xcInVb5YIMd(S4kflV3KWNYI973VKfcINGyXfyX(97W1Zcea2b3Y6sse43rwCDiaKLambV)GjL3Wd)btQH(eicYwaH58AK8HObfwFVjHpncni)nJyK(AonyqDwuSsHkVnnw4xs3SXc)s6WG(AonyqDwuSQwP3Mgl8lPB2yHFjDyaG3NRRqdi8RW1tpqSIb1zrXXABC2iD31vO23Bs4B(RaRpScE4MAyJw3Qg2XarAb4956k0ac)AJr66ASaZNYB4H)Gj1qFcebzPRCEns(q0GcRV3KWNgHgK)MrmsFnNgmOolkwPqL3Mgl8lPB2yHFjDyqFnNgmOolkwvR0BtJf(L0nBSWVKomaW7Z1vObe(v46PhiwXG6SO4yTnoBKU76ku77nj8n)vG1hwbpCtnSrRBvd7yGiTa8(CDfAaHFTXiDDnwG5t5n8WFWKAOpbIGS0hvkVRtL3i5drdkS(EtcFAeAq(BgXi91CAWG6SOyLcvEBASWVKUzJf(L0Hb91CAWG6SOyvTsVnnw4xs3SXc)s6WaaVpxxHgq4xHRNEGyfdQZIIJ124Sr6URRqTV3KW38xbwFyf8Wn1G4R1TQHDmqKwaEFUUcnGWV2yKUUglW8P8gKllAo4ZsFK2Fw0XjSrwiUnMLmkl3KL7zXoCPazXvkODwIcxS8qwAC2iDNffsPSaU6ljXcXTXSKrzz0VFuwGPkkl7ULfMuwSF)oC9Sa8Y5sXcb9rPp2NpM3Wd)btQH(eicYcW7Z1vi5tVaJiH19O0h7ZRO3QOvq4tEaUAHreGaW0Z3aaZFpAR12EL4e2Kqd9Y5sv3JsFSpxRT9kXjSjHMW1bfwHZQ6My1tWki6)U2aeQaH2tJo2uSj6ssMgDWOAdqOceApnTdat4IwNnMLmQPrhmQwB1xZPj41ldMLL2ro9BxvTG2XEZiH4mmOVMtJUccbvl6BwwJ5n8WFWKAOpbIGSfqyoVgj)nJaG3NRRqtcR7rPp2NxrVvrRGWxBJf(Lucztz8gE4pysn0Narqw6kNxJK)MraW7Z1vOjH19O0h7ZRO3QOvq4RTXc)skH0qZZBqUSuUuKfIlClSatwcGSy)(D46zj4wwxsI3Wd)btQH(eicYoHDaRWzn9F1i5VzeUvnSJbI4nixwkxkYc5uybTJnlLhMGSy)(Dw8mklkysIfmHls7SOC6FjjwiNG6SOilEcYY3rz5HSOUez5EwwwSy)(Dwiilf1Bw8eKfITvYwozG3Wd)btQH(eicYIfwq7yx1Hji5VzeJcqOceApnbVEzW0yHFjLa6R50e86Lbd4Q9)Gjb6vItytcnw9vaBWZvvVdEEHQ1sr9UuAyZMbiubcTNgSWcAh7QombnGR2)dMeqJYgpmOVMttWRxgmnw4xs3msgga71bAsynas5nixwaIpLf77yYYwPeewO7WLcKfDKfWvHfcYYdzjHplqayhClwgP5qlmbPSatwiURoklWjlKJALilEcYYVJSqob1zrXX8gE4pysn0NarqwaEFUUcjF6fyeo1QcUkSipaxTWiC63UQAbTJ9MA(Y0Sr2y0uP0xZPzU6Ov4SIQvIg67bI0mBkfguNffnxwvR07X8gKllLlfzHyBLSLtgyX(97Sqmycases2sCxc2iilaTU(EklEcYcim3(zbcaB799ileKLI6nlWMf77yYs5vqiOArFwSdxkqwqcBDnYIooHnYcX2kzlNmWcsyRRrQHLseNiKf6QrwEily(yZIZczUsVzHCcQZIISyFhtww0JuYsPTjsyXgRalEcYIRuSqmnhLf7NsXIogGfiln6GrzHcHjlycxK2zbC1xsILFhzrFnNS4jilGWNYYUdazrhXKf6AoVWH5RIYsJZgP7iOH3Wd)btQH(eicYcW7Z1vi5tVaJiawdWe8(dMv6tEaUAHrylyVoqtcRbqQ2ra8(CDfAcG1ambV)GPwB1xZPj41ldMLL2r2sXVQdZf18h22ejvBScddyqDwu0CzvTsVhgWG6SOOHcvExtKW)yTJgncG3NRRqJtTQGRcRHHaeaME(M8iT)1PJddJcqay65BikAFEQnaHkqO90Gfwq7yx1HjOPrhm64HHEL4e2KqZFfODyNvWg9c9lbXESwq4BORCEnAASWVKUzKOfe(McimNxJMgl8lPBQ51oce(g6JkL31PYB00yHFjDtnkByW23vy(g6JkL31PYB0GPRRqWXAb4956k0879PuvkIeHD1UFV23Bs4B(RaRpScE4M6R50e86Lbd4Q9)GzPkZqCgg0xZPrxbHGQf9nllT6R50ORGqq1I(Mgl8lPesFnNMGxVmyaxT)hmjWinSPu9kXjSjHgR(kGn45QQ3bpVq1APOEpE8WWimsxNLfcAWcROn6QkSbtpdO2aeQaH2tdwyfTrxvHny6zannw4xsjKgeFIdbgPPs1ReNWMeAOxoxQ6Eu6J95Jhpw7iBdqay65BYJ0(xNoommkaHkqO90eGjairy93Xk1667PMgl8lPesFnNMGxVmyaxT)hmjE2O12EL4e2KqJUR8mGv4S6kv93VKeDyiaHkqO90eGjairy93Xk1667PMgDWOAD63UQAbTJnH0uzJhg0HuQ25rA)Rnw4xsjuacvGq7PjataqIW6VJvQ113tnnw4xshpmOdPuTZJ0(xBSWVKsi91CAcE9YGbC1(FWKaAytP6vItytcnw9vaBWZvvVdEEHQ1sr9EmVb5Ys5srwiUnMLmkl2VFNfITvYwozGLvQqkLfIBJzjJYID4sbYIYPplkyscBw(DpzHyBLSLtgipl)oMSSOil64e2iVHh(dMud9jqeKTDaycx06SXSKrj)nJqFnNMGxVmyASWVKUPgAAyqFnNMGxVmyaxT)hmjKnehc0ReNWMeAS6Ra2GNRQEh88cvRLI6DP0WgTa8(CDfAcG1ambV)GzL(8gE4pysn0Narq2aQq6FUQ6QJuwG5t(BgbaVpxxHMaynatW7pywPV2r6R50e86Lbd4Q9)G5MrydXHa9kXjSjHgR(kGn45QQ3bpVq1APOExknSzyW2aeaME(gay(7r7Xdd6R500oamHlAD2ywYOMLLw91CAAhaMWfToBmlzutJf(LucP5jqaMGR7nwngokwD1rklW8n)vGvaUAHeyKT6R50ORGqq1I(MLLwBFxH5BOV3kydAW01vi4yEdp8hmPg6tGii7LbVt)pys(BgbaVpxxHMaynatW7pywPpVb5YsjwVpxxHSSOiilWKfx)u3FiLLF3FwS75ZYdzrhzH6aqqwMWMfITvYwozGfkKLF3Fw(DmklEJ5ZIDN(iilLySOpl64e2il)owWB4H)Gj1qFcebzb4956kK8PxGrqDayDc7AWRxgipaxTWicqOceApnbVEzW0yHFjDtnkByWwaEFUUcnbycasewbrA0mOnabGPNVjps7FD64WayVoqtcRbqkVb5Ys5srklexi5WYnz5sw8KfYjOolkYINGS89HuwEilQlrwUNLLfl2VFNfcYsr9M8SqSTs2YjdKNfYPWcAhBwkpmbzXtqw2kOB9haKfG29UG3Wd)btQH(eicYoxD0kCwr1krYFZiWG6SOO5YQNr1oYPF7QQf0o2esZBJMPVMtZC1rRWzfvRen03devknnmOVMtt7aWeUO1zJzjJAwwJ1osFnNgR(kGn45QQ3bpVq1APOEBa4QfsiBi4Ygg0xZPj41ldMgl8lPBgjJ1cW7Z1vOH6aW6e21GxVmODKTbiam98njgAOc2GddGW34GU1FaWk1U3fvqVWjHM)ceDjPXAhzBacatpFdam)9O9WG(AonTdat4IwNnMLmQPXc)skH08A2icUu9kXjSjHg6LZLQUhL(yF(yT6R500oamHlAD2ywYOML1WGT6R500oamHlAD2ywYOML1yTJSnabGPNVHOO955WqacvGq7PblSG2XUQdtqtJf(L0nTPSXAFVjHV5VcS(Wk4HBQPHbDiLQDEK2)AJf(LucPrz8gKllLlfzPenXFNfGV3txPyXQHbkl3KfGV3txPy5O52plllEdp8hmPg6tGiil99E6kf5Vze6R50at83PvlSdO1FW0SS0QVMtd99E6kLPXzJ0DxxH8gKlleZZaQyb47Tc2GSCtwUNLDNYIcPuw(DpzrtuwASWV8ssKNLOWflEJS4plA(YialBLsqyXtqw(DKLWQBmFwiNG6SOil7oLfnraklnw4xEjjEdp8hmPg6tGiiBWZaQQ6R5K8PxGrqFVvWgK83mc91CAOV3kydAASWVKsinPDK(AonyqDwuSsHkVnnw4xs3utdd6R50Gb1zrXQALEBASWVKUPMgR1PF7QQf0o2BQ5lJ3GCzHyEgqfl)oYcbzPOEZI(Aoz5MS87ilwnmWID4sbMB)SOUezzzXI973z53rwsKWpl)vGSqmycaseYsawGuwGZjlbqdlLE)OSSOlxPIYcmvrzz3TSWKYc4QVKel)oYs5jtdVHh(dMud9jqeKn4zavv91Cs(0lWiS6Ra2GNRQEh88cvRLI6n5VzeVRW8nxg8o9)GPbtxxHGAT9DfMVjr71cimny66keuBjEJgf5YktZC63UQAbTJnbi4Y0mk(vDyUOM)W2MiPAJvOueCzJjEJiyIh1cvQ6UtFCSMfGqfi0EAcWeaKiS(7yLAD99utJf(L0XeQeVrJICzLPzo9BxvTG2XwZ0xZPXQVcydEUQ6DWZluTwkQ3gaUAHeGGltZO4x1H5IA(dBBIKQnwHsrWLnM4nIGjEuluPQ7o9XXAwacvGq7PjataqIW6VJvQ113tnnw4xshRnaHkqO90e86LbtJf(L0nJCzA1xZPXQVcydEUQ6DWZluTwkQ3gaUAHeYgnktR(Aonw9vaBWZvvVdEEHQ1sr92aWvlCZixM2aeQaH2ttaMaGeH1FhRuRRVNAASWVKsicUmTZJ0(xBSWVKUzacvGq7PjataqIW6VJvQ113tnnw4xsjaXx7OEL4e2Kqtavi9pxvPwxFpDyaG3NRRqtaMaGeHvqKgndJ5nixwaIpLf77yYcbzPOEZcDhUuGSOJSy1Wqabzb9wfLLhYIoYIRRqwEillkYcXGjairilWKLaeQaH2twgroukM)5kvuw0XaSaPS89cz5MSaUkSUKelBLsqyjH2zX(PuS4kf0olrHlwEilwypXWRIYcMp2SqqwkQ3S4jil)oMSSOiledMaGeHJ5n8WFWKAOpbIGSa8(CDfs(0lWiSAyOATuuVRO3QOKhGRwyebiam98n5rA)Rth12ReNWMeAS6Ra2GNRQEh88cvRLI6Tw91CAS6Ra2GNRQEh88cvRLI6TbGRwibC63UQAbTJnbI8Mre5YktlaVpxxHMambajcRGinAg0gGqfi0EAcWeaKiS(7yLAD99utJf(Luc50VDv1cAhBIxKlRuKcGMcNWATfSxhOjH1aivlguNffnxw9mQwN(TRQwq7yVjaVpxxHMambajcRo1sBacvGq7Pj41ldMgl8lPBQjEdYLLYLISa89E6kfl2VFNfGpQuEZIMRV5ZcSz5TjsyHGTcS4jiljKfGV3kydsEwSVJjljKfGV3txPy5OSSSyb2S8qwSAyGfcYsr9Mf77yYIRdbGSO5lJLTsjiJGnl)oYc6TkkleKLI6nlwnmWcaVpxxHSCuw(EHJzb2S4Gw(FaqwO29UGLDNYsKqakgOS0yHF5LKyb2SCuwUKLP6iT)8gE4pysn0Narqw6790vkYFZig9UcZ3qFuP8Uc238ny66keCyGIFvhMlQ5pSTjsQeSvySwBFxH5BOV3kydAW01viOw91CAOV3txPmnoBKU76kuRT9kXjSjHM)kq7WoRGn6f6xcIT2r6R50y1xbSbpxv9o45fQwlf1BdaxTWnJWgnvMwB1xZPj41ldMLL2ra8(CDfACQvfCvynmOVMtdrxc2iyflSG2XUaZVIj2KUsIML1WaaVpxxHgRggQwlf17k6Tk64HHrbiam98njgAOc2GAFxH5BOpQuExb7B(gmDDfcQDei8noOB9haSsT7Drf0lCsOPXc)s6MrYWGh(dMgh0T(dawP29UOc6foj0CzDQos7)4XJ1gGqfi0EAcE9YGPXc)s6MAugVb5YIMBvyrzzRuccl64e2iledMaGeHSSOxsILFhzHyWeaKiKLambV)GjlpKLWogiILBYcXGjairilhLfp8lxPIYIRdxplpKfDKLGtFEdp8hmPg6tGiil99MUAsi5Vzea8(CDfASAyOATuuVRO3QO8gKllLlfzPebctkl23XKLOWflEJS46W1ZYdjR3ilb3Y6ssSe29MeszXtqwkCIqwORgz53XOS4nYYLS4jlKtqDwuKf6FkfltyZcb9LiKL4wIWB4H)Gj1qFcebzt0ETactYFZiCRAyhdePDuy3BsincB02yy3Bsy9VcKqAAyiS7njKgrKhZB4H)Gj1qFcebz3D1SwaHj5VzeUvnSJbI0okS7njKgHnABmS7njS(xbsinnme29MesJiYJ1osFnNgmOolkwvR0BtJf(L0nrcJH1J1)kWHb91CAWG6SOyLcvEBASWVKUjsymSES(xboM3Wd)btQH(eicYoxkvTactYFZiCRAyhdePDuy3BsincB02yy3Bsy9VcKqAAyiS7njKgrKhRDK(AonyqDwuSQwP3Mgl8lPBIegdRhR)vGdd6R50Gb1zrXkfQ820yHFjDtKWyy9y9VcCmVb5Ys5srwa(EtxnjKLs0e)DwSAyGYINGSaUkSyzRuccl23XKfITvYwozG8Sqofwq7yZs5Hji5z53rwkXI5VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsji8gE4pysn0Narqw67nD1KqYFZiWG6SOO5YQNr1osFnNgyI)oTguO3vah9GPzznmOVMtdrxc2iyflSG2XUaZVIj2KUsIML1WG(AonbVEzWSS0oY2aeaME(gII2NNddbiubcTNgSWcAh7Qombnnw4xs3utdd6R50e86LbtJf(LucrkaAkCcxQPcc7ro9BxvTG2XM4bW7Z1vOHsRbi9hpw7iBdqay65BaG5VhThg0xZPPDaycx06SXSKrnnw4xsjePaOPWjCPc4PgnYPF7QQf0o2eGGlRuVRW8nZvhTcNvuTs0GPRRqWXepaEFUUcnuAnaP)yce5s9UcZ3KO9AbeMgmDDfcQ12EL4e2Kqd9Y5sv3JsFSpxR(AonTdat4IwNnMLmQzznmOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95ML1WWi91CAAhaMWfToBmlzutJf(Luc5H)GPH(EpVgniHXW6X6FfOwQfQu1DN(iHkZqWdd6R500oamHlAD2ywYOMgl8lPeYd)btJ92)DdsymSES(xbomaW7Z1vO5IuWAaMG3FWuBacvGq7P5sAOxVRRWAKU88xfvqeWfqtJoyuTyKUolle0Cjn0R31vynsxE(RIkic4c4yT6R500oamHlAD2ywYOML1WGT6R500oamHlAD2ywYOMLLwBdqOceApnTdat4IwNnMLmQPrhm64HbaEFUUcno1QcUkSgg0HuQ25rA)Rnw4xsjePaOPWjCPc4Pg50VDv1cAhBIhaVpxxHgkTgG0F8yEdYLLs3rz5HSu4eHS87il6i9zbozb47Tc2GSOhLf67bIUKel3ZYYILiDDbIurz5sw8mklKtqDwuKf91ZcbzPOEZYrZTFwCD46z5HSOJSy1Wqab5n8WFWKAOpbIGS03B6QjHK)Mr8UcZ3qFVvWg0GPRRqqT22ReNWMeA(RaTd7Sc2OxOFji2AhPVMtd99wbBqZYAyWPF7QQf0o2BQ5lBSw91CAOV3kydAOVhiIqrw7i91CAWG6SOyLcvEBwwdd6R50Gb1zrXQALEBwwJ1QVMtJvFfWg8Cv17GNxOATuuVnaC1cjKneNY0okaHkqO90e86LbtJf(L0n1OSHbBb4956k0eGjairyfePrZG2aeaME(M8iT)1PJJ5nixwih6Ff(Juw2H2zPyf2zzRucclEJSqYVebzXcBwOyaMGgwkrtvuwENiKYIZcnDl6o8zzcBw(DKLWQBmFwO3V8)Gjluil2HlfyU9ZIoYIhcR2FKLjSzr5njSz5VcC2Ebs5n8WFWKAOpbIGSa8(CDfs(0lWiCQfbbBGyG8aC1cJadQZIIMlRQv6DPIeINh(dMg6798A0GegdRhR)vGeWwmOolkAUSQwP3LAeXNaVRW8nu4svHZ6VJ1jSr6BW01viyPI8yINh(dMg7T)7gKWyy9y9VcKaLziynr8OwOsv3D6JeOmJMk17kmFt6)QrAv3vEgqdMUUcb5nixw0CRclwa(EtxnjKLlzXtwiNG6SOiloLfkeMS4uwSGu6PRqwCklkysIfNYsu4If7NsXcMGSSSyX(97SejLrawSVJjly(yFjjw(DKLej8Zc5euNffjplGWC7Nff(SCplwnmWcbzPOEtEwaH52plqayBVVhzXtwkrt83zXQHbw8eKfliuXIooHnYcX2kzlNmWINGSqofwq7yZs5HjiVHh(dMud9jqeKL(EtxnjK83mcB7vItytcn)vG2HDwbB0l0VeeBTJ0xZPXQVcydEUQ6DWZluTwkQ3gaUAHeYgItzdd6R50y1xbSbpxv9o45fQwlf1BdaxTqczJMkt77kmFd9rLY7kyFZ3GPRRqWXAhHb1zrrZLvku5TwN(TRQwq7ytaaEFUUcno1IGGnqmuk91CAWG6SOyLcvEBASWVKsaq4BMRoAfoROALO5Var0AJf(LLYgJM2mskByadQZIIMlRQv6TwN(TRQwq7ytaaEFUUcno1IGGnqmuk91CAWG6SOyvTsVnnw4xsjai8nZvhTcNvuTs08xGiATXc)YszJrtBQ5lBSwB1xZPbM4VtRwyhqR)GPzzP123vy(g67Tc2GgmDDfcQDuacvGq7Pj41ldMgl8lPBsCggOWLs)sqZV3NsvPise2gmDDfcQvFnNMFVpLQsrKiSn03derOihznBuVsCcBsOHE5CPQ7rPp2NxkBgRDEK2)AJf(L0n1OSY0ops7FTXc)skHSPSYgga71bAsynashRDKTbiam98nefTpphgcqOceApnyHf0o2vDycAASWVKUPnJ5nixwkxkYsjceMuwUKfpJYc5euNffzXtqwOoaKfc6D1Kae3LsXsjceMSmHnleBRKTCYalEcYsjUlbBeKfYPWcAh7cmFdlBvrHSSOilBPeHfpbzH4wIWI)S87ilycYcCYcXTXSKrzXtqwaH52plk8zrZ1OxOFji2SmDLIf4CYB4H)Gj1qFcebzt0ETactYFZiCRAyhdePfG3NRRqd1bG1jSRbVEzq7i91CAWG6SOyvTsVnnw4xs3ejmgwpw)Rahg0xZPbdQZIIvku5TPXc)s6MiHXW6X6Ff4yEdp8hmPg6tGii7URM1cimj)nJWTQHDmqKwaEFUUcnuhawNWUg86LbTJ0xZPbdQZIIv1k920yHFjDtKWyy9y9VcCyqFnNgmOolkwPqL3Mgl8lPBIegdRhR)vGJ1osFnNMGxVmywwdd6R50y1xbSbpxv9o45fQwlf1BdaxTqcfHnAu2yTJSnabGPNVbaM)E0EyqFnNM2bGjCrRZgZsg10yHFjLqJ0KMztP6vItytcn0lNlvDpk9X(8XA1xZPPDaycx06SXSKrnlRHbB1xZPPDaycx06SXSKrnlRXAhzBVsCcBsO5Vc0oSZkyJEH(LGypmGegdRhR)vGesFnNM)kq7WoRGn6f6xcITPXc)s6WGT6R508xbAh2zfSrVq)sqSnlRX8gE4pysn0Narq25sPQfqys(BgHBvd7yGiTa8(CDfAOoaSoHDn41ldAhPVMtdguNffRQv6TPXc)s6MiHXW6X6Ff4WG(AonyqDwuSsHkVnnw4xs3ejmgwpw)RahRDK(AonbVEzWSSgg0xZPXQVcydEUQ6DWZluTwkQ3gaUAHekcB0OSXAhzBacatpFdrr7ZZHb91CAi6sWgbRyHf0o2fy(vmXM0vs0SSgRDKTbiam98naW83J2dd6R500oamHlAD2ywYOMgl8lPestA1xZPPDaycx06SXSKrnllT22ReNWMeAOxoxQ6Eu6J95dd2QVMtt7aWeUO1zJzjJAwwJ1oY2EL4e2KqZFfODyNvWg9c9lbXEyajmgwpw)RajK(Aon)vG2HDwbB0l0VeeBtJf(L0HbB1xZP5Vc0oSZkyJEH(LGyBwwJ5nixwkxkYcbfKCybMSea5n8WFWKAOpbIGS29UpyxHZkQwjYBqUSuUuKfGV3ZRrwEilwnmWcqOYBwiNG6SOi5zHyBLSLtgyz3PSOqkLL)kqw(DpzXzHGQ9FNfKWyy9ilkC(SaBwGPkklK5k9MfYjOolkYYrzzzzyHG6(DwkTnrcl2yfybZhBwCwacvEZc5euNffz5MSqqwkQ3Sq)tPyz3PSOqkLLF3twSrJYyH(EGiklEcYcX2kzlNmWINGSqmycaseYYUdazPa2il)UNSObXHYcX0CS0yHF5LKmSuUuKfxhcazXgnvgXJLDN(ilGR(ssSqCBmlzuw8eKfBSXgIhl7o9rwSF)oC9SqCBmlzuEdp8hmPg6tGiil99EEns(BgbguNffnxwvR0BT2QVMtt7aWeUO1zJzjJAwwddyqDwu0qHkVRjs4FyyeguNffnEgTMiH)Hb91CAcE9YGPXc)skH8WFW0yV9F3GegdRhR)vGA1xZPj41ldML1yTJSLIFvhMlQ5pSTjsQ2yfgg6vItytcnw9vaBWZvvVdEEHQ1sr9wR(Aonw9vaBWZvvVdEEHQ1sr92aWvlKq2OrzAdqOceApnbVEzW0yHFjDtnioAhzBacatpFtEK2)60XHHaeQaH2ttaMaGeH1FhRuRRVNAASWVKUPgeNXAhzB7b08nuPggcqOceApn6ytXMOljzASWVKUPgeNXJhgWG6SOO5YQNr1osFnNg7E3hSRWzfvRenlRHbQfQu1DN(iHkZqWAs7iBdqay65BaG5VhThgSvFnNM2bGjCrRZgZsg1SSgpmeGaW0Z3aaZFpARLAHkvD3PpsOYme8yEdYLLYLISqq1(VZc83X2(rrwSVFHDwoklxYcqOYBwiNG6SOi5zHyBLSLtgyb2S8qwSAyGfYCLEZc5euNff5n8WFWKAOpbIGS2B)35nixwiUUs979I3Wd)btQH(eicY2RS6H)GzvD0N8PxGrmDL637vmqQfgI3IgLzt8h)XXa]] )
    

end