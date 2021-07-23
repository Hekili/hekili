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

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
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
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },

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
            id = 209753,
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
            id = 236696,
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
            elseif debuff[ k ] ~= nil then return debuff[ k ]
            end
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
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
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

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) end,
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

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) end,
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
            id = 236696,
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


    spec:RegisterPack( "Balance", 20210723, [[difSMfqikjpcIsxcII2ej8jivgLuLtjv1Qau1RauMfKs3caQDrXVGigMiYXirTmaYZeQyAqQY1GuSnau(gaQghaIZbOI1bOsZdG6EKi7tOQ)brHuhuOuluOWdHOAIcLWfHuvBeaIpkuIWifkr0jPKsRue1lHOqntkP4MaqYofQ0pbGudfaPJcrHKLkuI6PkvtLsQUQqjTvHsK(kefmwaq7Ls9xrnyIdt1IjPhlyYaDzKnlLpdjJwPCAvwnefIxdiZMu3wQSBj)g0WfYXbawUINd10v11vY2HW3PeJhI05fH1lu08fP9JABLTTU9oO)KDCbusas5Ka4akogLbyObGHEam79prezVh5bGCuK9E5DK9EmCTxbYEpYtOHoOT1T3XW1ei79T)JWaxKGevx7vGaW4RlyqD)2s1CqKedx7vGaW7xhYrshOz770iJUDAsjvx7vGmpsF7D11PFRTSvT3b9NSJlGscqkNeahqXXOmadnam0dn27(63GJ9((1HC79TdeKkBv7DqchS3JHR9kqSelM1bYjN8sNGfaPmAzbqjbiL5K5Kr(MxOimWLtgaZsSbbjqw2HAFyjgK3z4KbWSG8nVqrGS8(GI(81yj4ycZYdzjKiOP87dk6XgozamlXYuhebbYYQkkqySpjybHpNRQjml9odzqllrdHiJFFWRbfXcaoEwIgcHb)(GxdkQVHtgaZsSrapqwIgk44)kuSGmm(VXY1y5E0Hz53iwSmWcflOFqFryYWjdGzbaLdeXcYHfciqel)gXYE0n3JzXzrF)Rjw6GdXstti9u1el9UgljGlw2CWcDplB3ZY9SGVUL(9IGlSoblwUFJLyaGo2wNfGXcYjnH)Z1SeB9HQ6O6rll3JoqwWaDr9nCYaywaq5arS0bXplORDO2(8qD(vy0XcoqLpheZIhfPtWYdzrfIXS0ouBpMfyPty4KbWSy9H8NfRd7iwGnwIH23yjgAFJLyO9nwCmlol4ikCUMLFUci6n276d)yBRBVdsnFPFBRBhxLTTU9Uh(dw27yO2NSk5D27u5QAc0og2VDCbKT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr274isRZVpOOhBWVpnxRzjEwuMffS0JfRy5DnvVb)(OHdOHkxvtGSKMYY7AQEd(jT2Nm4CT3qLRQjqw6ZsAkl4isRZVpOOhBWVpnxRzjEwaK9oiHdZf9hSS33PhZsSHOplWIL4amwSC)gC9Saox7zXlqwSC)gl7VpA4aYIxGSaiGXc83OXYHj7De(KlVJS3pC2HK9Bh34yBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9ooI0687dk6Xg87t7gIL4zrz7DqchMl6pyzVVtpMLGMCeelw2OIL93N2nelbVyz7EwaeWy59bf9ywSSDHnwomldPjeE9S0Gdl)gXc6h0xeMy5HSOsSenuJMHazXlqwSSDHnwANwtdlpKLGJF7De(KlVJS3pCoOjhbz)2Xf9STU9ovUQMaTJH9Uh(dw27Q0GPbORqzVds4WCr)bl79yftSedAW0a0vOyXY9BSG8yJeRTcSahw82tdlihwiGarSCflip2iXARG9EyUNMZT37XspwSILaebvE9M6qT95MtSKMYIvSeGqni0szcWcbeik)BughDZ9yZkIL(SOGf1vRzcE(QGzOo)kmlXZIYOHffSOUAnZ4iOcUW52qvmtygQZVcZcGzb9yrblwXsaIGkVEdcQ(TedlPPSeGiOYR3GGQFlXWIcwuxTMj45RcMvelkyrD1AMXrqfCHZTHQyMWSIyrbl9yrD1AMXrqfCHZTHQyMWmuNFfMfaZIYkZcaMf0WcWZYSkQbhuKbFvBPZBjWpnNBOYv1eilPPSOUAntWZxfmd15xHzbWSOSYSKMYIYSGewWrKwN3C8tSaywu2Gg0WsFw6ZIcwqfand15xHzjEwsY(TJlASTU9ovUQMaTJH9EyUNMZT3vxTMj45RcMH68RWSeplkJgwuWspwSILzvudoOid(Q2sN3sGFAo3qLRQjqwstzrD1AMXrqfCHZTHQyMWmuNFfMfaZIYaCwaWSaiwaEwuxTMrvdHG6f(nRiwuWI6Q1mJJGk4cNBdvXmHzfXsFwstzrfIXSOGL2HA7Zd15xHzbWSai0yVds4WCr)bl7Dak8zXY9BS4SG8yJeRTcS8B(ZYHl09S4SaqxASpSenWalWHflBuXYVrS0ouBplhMfxfUEwEilubAV7H)GL9Ee8pyz)2XfGzBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9EGonl9yPhlTd12NhQZVcZcaMfLrdlaywcqOgeAPmbpFvWmuNFfML(SGewugGKel9zrjwc0PzPhl9yPDO2(8qD(vywaWSOmAybaZsac1GqlLjaleqGO8VrzC0n3JnGRX)dwSaGzjaHAqOLYeGfciqu(3Omo6M7XMH68RWS0NfKWIYaKKyPplkyXkwg)aZecQEJdcInesp8JzjnLLaeQbHwktWZxfmd15xHzjEwU6PjcQ9NaZTd12NhQZVcZsAklbiudcTuMaSqabIY)gLXr3Cp2muNFfML4z5QNMiO2Fcm3ouBFEOo)kmlaywuojwstzXkwcqeu51BQd12NBozVds4WCr)bl7DK76Ws7pHzXYg9B0WYcFfkwqoSqabIyPGwyXYP1S4An0cljGlwEil4)0Awco(z53iwWEhXI3bx1ZcSXcYHfciqeWqESrI1wbwco(X27i8jxEhzVhGfciqugKWjQG9BhxaUT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr279yPDO2(8qD(vywINfLrdlPPSm(bMjeu9gheeBUIL4zbnjXsFwuWspw6XspwiaW6IIiqd1fLyixNHdy5vGyrbl9yPhlbiudcTugQlkXqUodhWYRazgQZVcZcGzrzawsSKMYsaIGkVEdcQ(TedlkyjaHAqOLYqDrjgY1z4awEfiZqD(vywamlkdWa4Samw6XIYkZcWZYSkQbhuKbFvBPZBjWpnNBOYv1eil9zPplkyXkwcqOgeAPmuxuIHCDgoGLxbYmKdMGL(S0NL0uw6XcbawxuebAWWLwt)FfQ8SutWIcw6XIvSeGiOYR3uhQTp3CIL0uwcqOgeAPmy4sRP)VcvEwQjYXb9qdajjLnd15xHzbWSOSYOhl9zPplPPS0JLaeQbHwkJknyAa6kuMHCWeSKMYIvSmEGm)a1Aw6ZIcw6XspwiaW6IIiqZv4WSExvtzaWYRF1LbjexGyrblbiudcTuMRWHz9UQMYaGLx)QldsiUazgYbtWsFwstzPhleayDrreObV5GqleygoQzyl)WPJQNffSeGqni0szE40r1tG5RWhQTphh0GM4aiLnd15xHzPplPPS0JLESGWNZv1Kbw5fMY)Cfq0ZIsSOmlPPSGWNZv1Kbw5fMY)Cfq0ZIsSehw6ZIcw6XYpxbe9MxzZqoyICac1GqlflPPS8ZvarV5v2eGqni0szgQZVcZs8SC1tteu7pbMBhQTppuNFfMfamlkNel9zjnLfe(CUQMmWkVWu(NRaIEwuIfaXIcw6XYpxbe9MhqMHCWe5aeQbHwkwstz5NRaIEZditac1GqlLzOo)kmlXZYvpnrqT)eyUDO2(8qD(vywaWSOCsS0NL0uwq4Z5QAYaR8ct5FUci6zrjwsIL(S0NL(SKMYsaIGkVEdqjMZlw6ZsAklQqmMffS0ouBFEOo)kmlaMf1vRzcE(QGbCn(FWYEhKWH5I(dw27XkMaz5HSasApbl)gXYc7OiwGnwqESrI1wbwSSrfll8vOybeUu1elWILfMyXlqwIgcbvpllSJIyXYgvS4floiilecQEwomlUkC9S8qwapYEhHp5Y7i79ayoalW7pyz)2XfGyBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9UvSGHlT6vGMFBoToJjciAmu5QAcKL0uwAhQTppuNFfML4zbqjLelPPSOcXywuWs7qT95H68RWSaywaeAybyS0Jf0ljwaWSOUAnZVnNwNXebeng87bGyb4zbqS0NL0uwuxTM53MtRZyIaIgd(9aqSeplXbGWcaMLESmRIAWbfzWx1w68wc8tZ5gQCvnbYcWZcAyPV9oiHdZf9hSS3JL6Z5QAILfMaz5HSasApblELGLFUci6XS4filbqmlw2OIfl(9xHILgCyXlwq)v0gCoNLObgS3r4tU8oYE)3MtRZyIaIMSf)E73oUahBRBVtLRQjq7yyVds4WCr)bl79yftSG(DrjgY1SaGEalVcelakjmfWSOsn4qS4SG8yJeRTcSSWKXEV8oYEN6IsmKRZWbS8kq27H5EAo3EpaHAqOLYe88vbZqD(vywamlakjwuWsac1GqlLjaleqGO8VrzC0n3Jnd15xHzbWSaOKyrbl9ybHpNRQjZVnNwNXebenzl(9SKMYI6Q1m)2CADgteq0yWVhaIL4zjojXcWyPhlZQOgCqrg8vTLoVLa)0CUHkxvtGSa8SaWyPpl9zrblOcGMH68RWSepljXsAklQqmMffS0ouBFEOo)kmlaML4aWT39WFWYEN6IsmKRZWbS8kq2VDCvojBRBVtLRQjq7yyVds4WCr)bl79yftSSdxAn9xHILy5LAcwayykGzrLAWHyXzb5XgjwBfyzHjJ9E5DK9ogU0A6)RqLNLAc79WCpnNBV3JLaeQbHwktWZxfmd15xHzbWSaWyrblwXsaIGkVEdcQ(TedlkyXkwcqeu51BQd12NBoXsAklbicQ86n1HA7ZnNyrblbiudcTuMaSqabIY)gLXr3Cp2muNFfMfaZcaJffS0Jfe(CUQMmbyHaceLbjCIkWsAklbiudcTuMGNVkygQZVcZcGzbGXsFwstzjarqLxVbbv)wIHffS0JfRyzwf1GdkYGVQT05Te4NMZnu5QAcKffSeGqni0szcE(QGzOo)kmlaMfaglPPSOUAnZ4iOcUW52qvmtygQZVcZcGzrz0JfGXspwqdlapleayDrreO5k8pRWdhCg8qCfLvjTML(SOGf1vRzghbvWfo3gQIzcZkIL(SKMYIkeJzrblTd12NhQZVcZcGzbqOHL(SOGfubqZqD(vywINLKS39WFWYEhdxAn9)vOYZsnH9BhxLv22627u5QAc0og27Wi7Dm927E4pyzVJWNZv1K9ocxVi7D1vRzcE(QGzOo)kmlXZIYOHffS0JfRyzwf1GdkYGVQT05Te4NMZnu5QAcKL0uwuxTMzCeubx4CBOkMjmd15xHzbWkXIYaIfGXspwIdlaplQRwZOQHqq9c)Mvel9zbyS0JLESaqybaZcAyb4zrD1AgvnecQx43SIyPplapleayDrreO5k8pRWdhCg8qCfLvjTML(SOGf1vRzghbvWfo3gQIzcZkIL(SKMYIkeJzrblTd12NhQZVcZcGzbqOXEhKWH5I(dw27XwBXtGzzHjwSwKrflyXY9BSG8yJeRTc27i8jxEhzVFaaWCawG3FWY(TJRYaY2627u5QAc0og27E4pyzVFfomR3v1ugaS86xDzqcXfi79WCpnNBVJWNZv1K5aaG5aSaV)Gflkybva0muNFfML4zjj79Y7i79RWHz9UQMYaGLx)QldsiUaz)2Xv54yBD7DQCvnbAhd7DqchMl6pyzVhRyIL5qT9SOsn4qSeaX27L3r274nheAHaZWrndB5hoDu927H5EAo3EVhlbiudcTuMGNVkygYbtWIcwSILaebvE9M6qT95MtSOGfe(CUQMm)2CADgteq0KT43ZsAklbicQ86n1HA7ZnNyrblbiudcTuMaSqabIY)gLXr3Cp2mKdMGffS0Jfe(CUQMmbyHaceLbjCIkWsAklbiudcTuMGNVkygYbtWsFw6ZIcwaHVbVQ2nK5VaqxHIffS0Jfq4BWpP1(KBAFiZFbGUcflPPSyflVRP6n4N0AFYnTpKHkxvtGSKMYcoI0687dk6Xg87t7gIL4zjoS0NffS0Jfq4B6GWQDdz(la0vOyPplkyPhli85CvnzoC2HelPPSmRIAWbfzuDTxbkdBzxRZ)2vOWgQCvnbYsAklo(hxNJGwOHL4vIfGtsSKMYI6Q1mQAieuVWVzfXsFwuWspwcqOgeAPmQ0GPbORqzgYbtWsAklwXY4bY8duRzPplPPSOcXywuWs7qT95H68RWSaywqVKS39WFWYEhV5GqleygoQzyl)WPJQ3(TJRYONT1T3PYv1eODmS3bjCyUO)GL9U13omlhMfNLX)nAyH0UkC8NyXINGLhYsNdeXIR1SalwwyIf87pl)Cfq0Jz5HSOsSOVIazzfXIL73yb5XgjwBfyXlqwqoSqabIyXlqwwyILFJybqfilyn8zbwSeaz5ASOc)nw(5kGOhZIpelWILfMyb)(ZYpxbe9y79WCpnNBV3Jfe(CUQMmWkVWu(NRaIEwuIfaXIcwSILFUci6npGmd5GjYbiudcTuSKMYspwq4Z5QAYaR8ct5FUci6zrjwuML0uwq4Z5QAYaR8ct5FUci6zrjwIdl9zrbl9yrD1AMGNVkywrSOGLESyflbicQ86niO63smSKMYI6Q1mJJGk4cNBdvXmHzOo)kmlaJLESGgwaEwMvrn4GIm4RAlDElb(P5CdvUQMazPplawjw(5kGO38kBuxTwgCn(FWIffSOUAnZ4iOcUW52qvmtywrSKMYI6Q1mJJGk4cNBdvXmrgFvBPZBjWpnNBwrS0NL0uwcqOgeAPmbpFvWmuNFfMfGXcGyjEw(5kGO38kBcqOgeAPmGRX)dwSOGfRyrD1AMGNVkywrSOGLESyflbicQ86n1HA7ZnNyjnLfRybHpNRQjtawiGarzqcNOcS0NffSyflbicQ86naLyoVyjnLLaebvE9M6qT95MtSOGfe(CUQMmbyHaceLbjCIkWIcwcqOgeAPmbyHaceL)nkJJU5ESzfXIcwSILaeQbHwktWZxfmRiwuWspw6XI6Q1muqFrykRxLpMH68RWSeplkNelPPSOUAndf0xeMYyO2hZqD(vywINfLtIL(SOGfRyzwf1GdkYO6AVcug2YUwN)TRqHnu5QAcKL0uw6XI6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqSOelOHL0uwuxTMr11EfOmSLDTo)BxHcN9j4fzWVhaIfLybGWsFw6ZsAklQRwZa0vGdbMPUiOfA6O6ZurdQlMKzfXsFwstzrfIXSOGL2HA7Zd15xHzbWSaOKyjnLfe(CUQMmWkVWu(NRaIEwuILKyPplkybva0muNFfML4zjj7DSg(y79FUci6v2E3d)bl79FUci6v2(TJRYOX2627u5QAc0og27E4pyzV)ZvarpGS3dZ90CU9Epwq4Z5QAYaR8ct5FUci6zXkLybqSOGfRy5NRaIEZRSzihmroaHAqOLIL0uwq4Z5QAYaR8ct5FUci6zrjwaelkyPhlQRwZe88vbZkIffS0JfRyjarqLxVbbv)wIHL0uwuxTMzCeubx4CBOkMjmd15xHzbyS0Jf0WcWZYSkQbhuKbFvBPZBjWpnNBOYv1eil9zbWkXYpxbe9Mhqg1vRLbxJ)hSyrblQRwZmocQGlCUnufZeMvelPPSOUAnZ4iOcUW52qvmtKXx1w68wc8tZ5Mvel9zjnLLaeQbHwktWZxfmd15xHzbySaiwINLFUci6npGmbiudcTugW14)blwuWIvSOUAntWZxfmRiwuWspwSILaebvE9M6qT95MtSKMYIvSGWNZv1KjaleqGOmiHtubw6ZIcwSILaebvE9gGsmNxSOGLESyflQRwZe88vbZkIL0uwSILaebvE9geu9Bjgw6ZsAklbicQ86n1HA7ZnNyrbli85CvnzcWcbeikds4evGffSeGqni0szcWcbeik)BughDZ9yZkIffSyflbiudcTuMGNVkywrSOGLES0Jf1vRzOG(IWuwVkFmd15xHzjEwuojwstzrD1AgkOVimLXqTpMH68RWSeplkNel9zrblwXYSkQbhuKr11EfOmSLDTo)BxHcBOYv1eilPPS0Jf1vRzuDTxbkdBzxRZ)2vOW5Y)1qg87bGyrjwqdlPPSOUAnJQR9kqzyl7AD(3Ucfo7tWlYGFpaelkXcaHL(S0NL(SKMYI6Q1maDf4qGzQlcAHMoQ(mv0G6IjzwrSKMYIkeJzrblTd12NhQZVcZcGzbqjXsAkli85CvnzGvEHP8pxbe9SOeljXsFwuWcQaOzOo)kmlXZss27yn8X27)Cfq0di73oUkdWSTU9ovUQMaTJH9oiHdZf9hSS3JvmHzX1AwG)gnSalwwyIL7PomlWILaO9Uh(dw27lmLVN6W2VDCvgGBBD7DQCvnbAhd7DqchMl6pyzVhlOWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDy7Dp8hSS3NvL9WFWkRp8BVJ)5cVDCv2Epm3tZ527i85CvnzoC2HK9U(WFU8oYE3HK9BhxLbi2w3ENkxvtG2XWEpm3tZ527ZQOgCqrgvx7vGYWw2168VDfkSHaaRlkIaT3X)CH3oUkBV7H)GL9(SQSh(dwz9HF7D9H)C5DK9Uk0F73oUkdCSTU9ovUQMaTJH9Uh(dw27ZQYE4pyL1h(T31h(ZL3r2743(TF7DvO)2w3oUkBBD7DQCvnbAhd7Dp8hSS3hhbvWfo3gQIzc7DqchMl6pyzVdGmufZeSy5(nwqESrI1wb79WCpnNBVRUAntWZxfmd15xHzjEwugn2VDCbKT1T3PYv1eODmS39WFWYE3b9O)qqzSfF6S3djcAk)(GIESDCv2Epm3tZ527QRwZO6AVcug2YUwN)TRqHZL)RHm43daXcGzbGWIcwuxTMr11EfOmSLDTo)BxHcN9j4fzWVhaIfaZcaHffS0JfRybe(gh0J(dbLXw8Pld6DokY8xaORqXIcwSIfp8hSmoOh9hckJT4txg07CuK5QCtFO2EwuWspwSIfq4BCqp6peugBXNU8g5AZFbGUcflPPSacFJd6r)HGYyl(0L3ixBgQZVcZs8Sehw6ZsAklGW34GE0FiOm2IpDzqVZrrg87bGybWSehwuWci8noOh9hckJT4txg07CuKzOo)kmlaMf0WIcwaHVXb9O)qqzSfF6YGENJIm)fa6kuS03EhKWH5I(dw27XkMyj2GE0Fiiw2T4thlw2OIf)zrtyml)MxSGESedySTol43daHzXlqwEild1gcVXIZcGvcqSGFpaeloMfT)eloMLiigFQAIf4WYFDel3ZcgYY9S4ZCiimliJSWplE7PHfNL4amwWVhaIfcPr3qy73oUXX2627u5QAc0og27E4pyzVhGfciqu(3Omo6M7X27Geomx0FWYEpwXelihwiGarSy5(nwqESrI1wbwSSrflrqm(u1elEbYc83OXYHjwSC)glolXagBRZI6Q1yXYgvSas4ev4ku27H5EAo3E3kwaN1bAkyoaIzrbl9yPhli85CvnzcWcbeikds4evGffSyflbiudcTuMGNVkygYbtWsAklQRwZe88vbZkIL(SOGLESOUAnJQR9kqzyl7AD(3Ucfox(VgYGFpaelkXcaHL0uwuxTMr11EfOmSLDTo)BxHcN9j4fzWVhaIfLybGWsFwstzrfIXSOGL2HA7Zd15xHzbWSOCsS03(TJl6zBD7DQCvnbAhd7Dp8hSS3BRjrg2YKEvK9oiHdZf9hSS3bqGOploMLFJyPDd(zbvaKLRy53iwCwIbm2wNflxbcTWcCyXY9BS8BeliJtmNxSOUAnwGdlwUFJfNfacWWuGLyd6r)HGyz3IpDS4filw87zPbhwqESrI1wbwUgl3ZIfy9SOsSSIyXr5xXIk1GdXYVrSeaz5WS0U6WBeO9EyUNMZT37Xspw6XI6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqSeplamwstzrD1Agvx7vGYWw2168VDfkC2NGxKb)EaiwINfagl9zrbl9yXkwcqeu51Bqq1VLyyjnLfRyrD1AMXrqfCHZTHQyMWSIyPpl9zrbl9ybCwhOPG5aiML0uwcqOgeAPmbpFvWmuNFfML4zbnjXsAkl9yjarqLxVPouBFU5elkyjaHAqOLYeGfciqu(3Omo6M7XMH68RWSeplOjjw6ZsFw6ZsAkl9ybe(gh0J(dbLXw8Pld6DokYmuNFfML4zbGWIcwcqOgeAPmbpFvWmuNFfML4zr5KyrblbicQ86nffgOgoGS0NL0uwU6PjcQ9NaZTd12NhQZVcZcGzbGWIcwSILaeQbHwktWZxfmd5GjyjnLLaebvE9gGsmNxSOGf1vRza6kWHaZuxe0cnDu9MvelPPSeGiOYR3GGQFlXWIcwuxTMzCeubx4CBOkMjmd15xHzbWSaCyrblQRwZmocQGlCUnufZeMvK9Bhx0yBD7DQCvnbAhd7Dp8hSS3dEfiDwD1A27H5EAo3EVhlQRwZO6AVcug2YUwN)TRqHZL)RHmd15xHzjEwa4g0WsAklQRwZO6AVcug2YUwN)TRqHZ(e8Imd15xHzjEwa4g0WsFwuWspwcqOgeAPmbpFvWmuNFfML4zbGZsAkl9yjaHAqOLYqDrql0KvHfOzOo)kmlXZcaNffSyflQRwZa0vGdbMPUiOfA6O6ZurdQlMKzfXIcwcqeu51BakXCEXsFw6ZIcwC8pUohbTqdlXRelXjj7D1vRLlVJS3XVpA4aAVds4WCr)bl7DK7vG0SS)(OHdilwUFJfNLISWsmGX26SOUAnw8cKfKhBKyTvGLdxO7zXvHRNLhYIkXYctG2VDCby2w3ENkxvtG2XWE3d)bl7D87dEnOi7DqchMl6pyzVhlwDrSS)(GxdkcZIL73yXzjgWyBDwuxTglQRNLc(SyzJkwIGq9vOyPbhwqESrI1wbwGdliJVcCiqw2JU5ES9EyUNMZT37XI6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqSeplaIL0uwuxTMr11EfOmSLDTo)BxHcN9j4fzWVhaIL4zbqS0NffS0JLaebvE9M6qT95MtSKMYsac1GqlLj45RcMH68RWSeplaCwstzXkwq4Z5QAYeaZbybE)blwuWIvSeGiOYR3auI58IL0uw6Xsac1GqlLH6IGwOjRclqZqD(vywINfaolkyXkwuxTMbORahcmtDrql00r1NPIguxmjZkIffSeGiOYR3auI58IL(S0NffS0JfRybe(M2AsKHTmPxfz(la0vOyjnLfRyjaHAqOLYe88vbZqoycwstzXkwcqOgeAPmbyHaceL)nkJJU5ESzihmbl9TF74cWTTU9ovUQMaTJH9Uh(dw2743h8Aqr27Geomx0FWYEpwS6Iyz)9bVgueMfvQbhIfKdleqGi79WCpnNBV3JLaeQbHwktawiGar5FJY4OBUhBgQZVcZcGzbnSOGfRybCwhOPG5aiMffS0Jfe(CUQMmbyHaceLbjCIkWsAklbiudcTuMGNVkygQZVcZcGzbnS0NffSGWNZv1KjaMdWc8(dwS0NffSyflGW30wtImSLj9QiZFbGUcflkyjarqLxVPouBFU5elkyXkwaN1bAkyoaIzrbluqFryYCv2ReSOGfh)JRZrql0Ws8SGEjz)2XfGyBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9EpwuxTMzCeubx4CBOkMjmd15xHzjEwqdlPPSyflQRwZmocQGlCUnufZeMvel9zrbl9yrD1AgGUcCiWm1fbTqthvFMkAqDXKmd15xHzbWSGkaA6CKYsFwuWspwuxTMHc6lctzmu7JzOo)kmlXZcQaOPZrklPPSOUAndf0xeMY6v5JzOo)kmlXZcQaOPZrkl9T3bjCyUO)GL9ESawO7zbe(SaUMRqXYVrSqfilWglXYocQGlmlaidvXmbAzbCnxHIfGUcCiqwOUiOfA6O6zboSCfl)gXI2XplOcGSaBS4flOFqFryYEhHp5Y7i7Dq4NhcaSUH6O6X2VDCbo2w3ENkxvtG2XWE3d)bl7D8QA3q27H5EAo3EFO2q4nxvtSOGL3hu0B(RJYpmdEelXZIYamwuWIhLdBuaiwuWccFoxvtgq4NhcaSUH6O6X27HebnLFFqrp2oUkB)2Xv5KSTU9ovUQMaTJH9Uh(dw27Dqy1UHS3dZ90CU9(qTHWBUQMyrblVpOO38xhLFyg8iwINfLJJbnSOGfpkh2OaqSOGfe(CUQMmGWppeayDd1r1JT3djcAk)(GIESDCv2(TJRYkBBD7DQCvnbAhd7Dp8hSS3XpP1(KBAFi79WCpnNBVpuBi8MRQjwuWY7dk6n)1r5hMbpIL4zrzaglaJLH68RWSOGfpkh2OaqSOGfe(CUQMmGWppeayDd1r1JT3djcAk)(GIESDCv2(TJRYaY2627u5QAc0og27E4pyzV3GtGYWwU8FnK9oiHdZf9hSS3bqGXLfyXsaKfl3Vbxplbpk6ku27H5EAo3E3JYHnkaK9BhxLJJT1T3PYv1eODmS39WFWYEN6IGwOjRclq7DqchMl6pyzVJ(Drql0WsmGfilw2OIfxfUEwEilu90WIZsrwyjgWyBDwSCfi0clEbYc2rqS0Gdlip2iXARG9EyUNMZT37Xcf0xeMm6v5tUiK(SKMYcf0xeMmyO2NCri9zjnLfkOVimz8krUiK(SKMYI6Q1mQU2RaLHTSR15F7ku4C5)AiZqD(vywINfaUbnSKMYI6Q1mQU2RaLHTSR15F7ku4SpbViZqD(vywINfaUbnSKMYIJ)X15iOfAyjEwaojXIcwcqOgeAPmbpFvWmKdMGffSyflGZ6anfmhaXS0NffS0JLaeQbHwktWZxfmd15xHzjEwItsSKMYsac1GqlLj45RcMHCWeS0NL0uwU6PjcQ9NaZTd12NhQZVcZcGzr5KSF74Qm6zBD7DQCvnbAhd7Dp8hSS3BRjrg2YKEvK9oiHdZf9hSS3bqGOplZHA7zrLAWHyzHVcflip227H5EAo3EpaHAqOLYe88vbZqoycwuWccFoxvtMayoalW7pyXIcw6XIJ)X15iOfAyjEwaojXIcwSILaebvE9M6qT95MtSKMYsaIGkVEtDO2(CZjwuWIJ)X15iOfAybWSGEjXsFwuWIvSeGiOYR3GGQFlXWIcw6XIvSeGiOYR3uhQTp3CIL0uwcqOgeAPmbyHaceL)nkJJU5ESzihmbl9zrblwXc4SoqtbZbqS9BhxLrJT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr27wXc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrbl9yPhlo(hxNJGwOHL4zb4KelkyPhlQRwZa0vGdbMPUiOfA6O6ZurdQlMKzfXsAklwXsaIGkVEdqjMZlw6ZsAklQRwZOQHqq9c)MvelkyrD1AgvnecQx43muNFfMfaZI6Q1mbpFvWaUg)pyXsFwstz5QNMiO2Fcm3ouBFEOo)kmlaMf1vRzcE(QGbCn(FWIL0uwcqeu51BQd12NBoXsFwuWspwSILaebvE9M6qT95MtSKMYspwC8pUohbTqdlaMf0ljwstzbe(M2AsKHTmPxfz(la0vOyPplkyPhli85CvnzcWcbeikds4evGL0uwcqOgeAPmbyHaceL)nkJJU5ESzihmbl9zPV9oiHdZf9hSS3rESrI1wbwSSrfl(ZcWjjGXsSXauw6bhn0cnS8BEXc6LelXgdqzXY9BSGCyHace1Nfl3VbxplAi(kuS8xhXYvSednecQx4NfVazrFfXYkIfl3VXcYHfciqelxJL7zXIJzbKWjQabAVJWNC5DK9EamhGf49hSYQq)TF74QmaZ2627u5QAc0og27H5EAo3EhHpNRQjtamhGf49hSYQq)T39WFWYEpqAc)NRZU(qvDu92VDCvgGBBD7DQCvnbAhd79WCpnNBVJWNZv1KjaMdWc8(dwzvO)27E4pyzVFvWNY)dw2VDCvgGyBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9of0xeMmxL1RYhwaEwaiSGew8WFWYGFFA3qgcPuy9u(VoIfGXIvSqb9fHjZvz9Q8HfGNLESaWybyS8UMQ3GHlDg2Y)gLBWHWVHkxvtGSa8Sehw6ZcsyXd)blJLX)ndHukSEk)xhXcWyjjdGybjSGJiToV54NS3bjCyUO)GL9o6J)RZFcZYg0clDRWglXgdqzXhIfu(veilr0WcMcWc0EhHp5Y7i7DhhbqPzNc2VDCvg4yBD7DQCvnbAhd7Dp8hSS3XVp41GIS3bjCyUO)GL9ESy1fXY(7dEnOimlw2OILFJyPDO2EwomlUkC9S8qwOceTS0gQIzcwomlUkC9S8qwOceTSKaUyXhIf)zb4KeWyj2yaklxXIxSG(b9fHj0YcYJnsS2kWI2XpMfVG)gnSaqagMcywGdljGlwSaxAqwGiOj4rS0bhILFZlw4uLtILyJbOSyzJkwsaxSybU0Gf6Ew2FFWRbfXsbTyVhM7P5C79ESC1tteu7pbMBhQTppuNFfMfaZc6XsAkl9yrD1AMXrqfCHZTHQyMWmuNFfMfaZcQaOPZrklaplb60S0Jfh)JRZrql0WcsyjojXsFwuWI6Q1mJJGk4cNBdvXmHzfXsFw6ZsAkl9yXX)46Ce0cnSamwq4Z5QAY44iakn7uGfGNf1vRzOG(IWugd1(ygQZVcZcWybe(M2AsKHTmPxfz(laeopuNFflaplaYGgwINfLvojwstzXX)46Ce0cnSamwq4Z5QAY44iakn7uGfGNf1vRzOG(IWuwVkFmd15xHzbySacFtBnjYWwM0RIm)facNhQZVIfGNfazqdlXZIYkNel9zrbluqFryYCv2ReSOGLESyflQRwZe88vbZkIL0uwSIL31u9g87JgoGgQCvnbYsFwuWspw6XIvSeGqni0szcE(QGzfXsAklbicQ86naLyoVyrblwXsac1GqlLH6IGwOjRclqZkIL(SKMYsaIGkVEtDO2(CZjw6ZIcw6XIvSeGiOYR3GGQFlXWsAklwXI6Q1mbpFvWSIyjnLfh)JRZrql0Ws8SaCsIL(SKMYspwExt1BWVpA4aAOYv1eilkyrD1AMGNVkywrSOGLESOUAnd(9rdhqd(9aqSaywIdlPPS44FCDocAHgwINfGtsS0NL(SKMYI6Q1mbpFvWSIyrblwXI6Q1mJJGk4cNBdvXmHzfXIcwSIL31u9g87JgoGgQCvnbA)2XfqjzBD7DQCvnbAhd7Dp8hSS3lYsUdcl7DqchMl6pyzVhRyIfauqyHz5kwSMv5dlOFqFryIfVazb7iiwIL01nGbGS0AwaqbHfln4WcYJnsS2kyVhM7P5C79ESOUAndf0xeMY6v5JzOo)kmlXZcHukSEk)xhXsAkl9yjS5dkcZIsSaiwuWYqHnFqr5)6iwamlOHL(SKMYsyZhueMfLyjoS0NffS4r5WgfaY(TJlGu22627u5QAc0og27H5EAo3EVhlQRwZqb9fHPSEv(ygQZVcZs8SqiLcRNY)1rSOGLESeGqni0szcE(QGzOo)kmlXZcAsIL0uwcqOgeAPmbyHaceL)nkJJU5ESzOo)kmlXZcAsIL(SKMYspwcB(GIWSOelaIffSmuyZhuu(VoIfaZcAyPplPPSe28bfHzrjwIdl9zrblEuoSrbGS39WFWYEFZ1TChew2VDCbeGSTU9ovUQMaTJH9EyUNMZT37XI6Q1muqFrykRxLpMH68RWSeplesPW6P8FDelkyPhlbiudcTuMGNVkygQZVcZs8SGMKyjnLLaeQbHwktawiGar5FJY4OBUhBgQZVcZs8SGMKyPplPPS0JLWMpOimlkXcGyrbldf28bfL)RJybWSGgw6ZsAklHnFqrywuIL4WsFwuWIhLdBuai7Dp8hSS3BlTo3bHL9BhxafhBRBVtLRQjq7yyVds4WCr)bl7DKbi6ZcSyjaAV7H)GL9UfFMdozylt6vr2VDCbe6zBD7DQCvnbAhd7Dp8hSS3XVpTBi7DqchMl6pyzVhRyIL93N2nelpKLObgyzhQ9Hf0pOVimXcCyXYgvSCflWsNGfRzv(Wc6h0xeMyXlqwwyIfKbi6Zs0adywUglxXI1SkFyb9d6lct27H5EAo3ENc6lctMRY6v5dlPPSqb9fHjdgQ9jxesFwstzHc6lctgVsKlcPplPPSOUAnJfFMdozylt6vrMvelkyrD1AgkOVimL1RYhZkIL0uw6XI6Q1mbpFvWmuNFfMfaZIh(dwglJ)BgcPuy9u(VoIffSOUAntWZxfmRiw6B)2XfqOX2627E4pyzVBz8FZENkxvtG2XW(TJlGay2w3ENkxvtG2XWE3d)bl79zvzp8hSY6d)276d)5Y7i79MR1)2SSF73E3HKT1TJRY2w3ENkxvtG2XWEhgzVJP3E3d)bl7De(CUQMS3r46fzV3Jf1vRz(RJSaNkdoK3PEfinMH68RWSaywqfanDoszbySKKrzwstzrD1AM)6ilWPYGd5DQxbsJzOo)kmlaMfp8hSm43N2nKHqkfwpL)RJybySKKrzwuWspwOG(IWK5QSEv(WsAkluqFryYGHAFYfH0NL0uwOG(IWKXRe5Iq6ZsFw6ZIcwuxTM5VoYcCQm4qEN6vG0ywrSOGLzvudoOiZFDKf4uzWH8o1RaPXqLRQjq7DqchMl6pyzVJCxhwA)jmlw2OFJgw(nILyXqExW)WgnSOUAnwSCAnlnxRzb2ASy5(TRy53iwkcPplbh)27i8jxEhzVdoK3LTCADU5ADg2A2VDCbKT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr27wXcf0xeMmxLXqTpSOGLESGJiTo)(GIESb)(0UHyjEwqdlky5DnvVbdx6mSL)nk3GdHFdvUQMazjnLfCeP153hu0Jn43N2nelXZcaNL(27Geomx0FWYEh5UoS0(tywSSr)gnSS)(GxdkILdZIf48BSeC8FfkwGiOHL93N2nelxXI1SkFyb9d6lct27i8jxEhzVFOk4qz87dEnOi73oUXX2627u5QAc0og27E4pyzVhGfciqu(3Omo6M7X27Geomx0FWYEpwXelihwiGarSyzJkw8NfnHXS8BEXcAsILyJbOS4fil6RiwwrSy5(nwqESrI1wb79WCpnNBVBflGZ6anfmhaXSOGLES0Jfe(CUQMmbyHaceLbjCIkWIcwSILaeQbHwktWZxfmd5GjyjnLf1vRzcE(QGzfXsFwuWspwuxTMHc6lctz9Q8XmuNFfML4zbGXsAklQRwZqb9fHPmgQ9XmuNFfML4zbGXsFwuWspwSILzvudoOiJQR9kqzyl7AD(3Ucf2qLRQjqwstzrD1Agvx7vGYWw2168VDfkCU8FnKb)EaiwINL4WsAklQRwZO6AVcug2YUwN)TRqHZ(e8Im43daXs8Sehw6ZsAklQqmMffS0ouBFEOo)kmlaMfLtIffSyflbiudcTuMGNVkygYbtWsF73oUONT1T3PYv1eODmS39WFWYEFCeubx4CBOkMjS3bjCyUO)GL9ESIjwaqgQIzcwSC)glip2iXARG9EyUNMZT3vxTMj45RcMH68RWSeplkJg73oUOX2627u5QAc0og27E4pyzVJxv7gYEpKiOP87dk6X2Xvz79WCpnNBV3JLHAdH3CvnXsAklQRwZqb9fHPmgQ9XmuNFfMfaZsCyrbluqFryYCvgd1(WIcwgQZVcZcGzrz0JffS8UMQ3GHlDg2Y)gLBWHWVHkxvtGS0NffS8(GIEZFDu(HzWJyjEwug9ybaZcoI0687dk6XSamwgQZVcZIcw6Xcf0xeMmxL9kblPPSmuNFfMfaZcQaOPZrkl9T3bjCyUO)GL9ESIjw2xv7gILRyjYlqQ7cSalw8kXVDfkw(n)zrFiimlkJEykGzXlqw0egZIL73yPdoelVpOOhZIxGS4pl)gXcvGSaBS4SSd1(Wc6h0xeMyXFwug9ybtbmlWHfnHXSmuNF1vOyXXS8qwk4ZYMJ4kuS8qwgQneEJfW1CfkwSMv5dlOFqFryY(TJlaZ2627u5QAc0og27E4pyzVJxv7gYEhKWH5I(dw27XkMyzFvTBiwEilBocIfNfuAOQRz5HSSWelwlYOIf27H5EAo3EhHpNRQjZbaaZbybE)blwuWsac1GqlL5kCywVRQPmay51V6YGeIlqMHCWeSOGfcaSUOic0CfomR3v1ugaS86xDzqcXfi73oUaCBRBVtLRQjq7yyVhM7P5C7DRy5DnvVb)Kw7tgCU2BOYv1eilkyPhlQRwZGFFAUwBgQneEZv1elkyPhl4isRZVpOOhBWVpnxRzbWSehwstzXkwMvrn4GIm)1rwGtLbhY7uVcKgdvUQMazPplPPS8UMQ3GHlDg2Y)gLBWHWVHkxvtGSOGf1vRzOG(IWugd1(ygQZVcZcGzjoSOGfkOVimzUkJHAFyrblQRwZGFFAUwBgQZVcZcGzbGZIcwWrKwNFFqrp2GFFAUwZs8kXc6XsFwuWspwSILzvudoOiJorWhhNBAI(RqLrPVUimzOYv1eilPPS8xhXcYKf0dnSeplQRwZGFFAUwBgQZVcZcWybqS0NffS8(GIEZFDu(HzWJyjEwqJ9Uh(dw2743NMR12VDCbi2w3ENkxvtG2XWE3d)bl7D87tZ1A7DqchMl6pyzVJmC)gl7pP1(WsSyU2ZYctSalwcGSyzJkwgQneEZv1elQRNf8FAnlw87zPbhwSMebFCmlrdmWIxGSacl09SSWelQudoelipwGnSS)NwZYctSOsn4qSGCyHaceXc(QaXYV5plwoTMLObgyXl4Vrdl7VpnxRT3dZ90CU9(7AQEd(jT2Nm4CT3qLRQjqwuWI6Q1m43NMR1MHAdH3CvnXIcw6XIvSmRIAWbfz0jc(44Ctt0FfQmk91fHjdvUQMazjnLL)6iwqMSGEOHL4zb9yPplky59bf9M)6O8dZGhXs8Seh73oUahBRBVtLRQjq7yyV7H)GL9o(9P5AT9oiHdZf9hSS3rgUFJLyXqEN6vG0WYctSS)(0CTMLhYcqefXYkILFJyrD1ASOMGfxJHSSWxHIL93NMR1SalwqdlykalqmlWHfnHXSmuNF1vOS3dZ90CU9(SkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkybhrAD(9bf9yd(9P5AnlXRelXHffS0JfRyrD1AM)6ilWPYGd5DQxbsJzfXIcwuxTMb)(0CT2muBi8MRQjwstzPhli85CvnzahY7YwoTo3CTodBnwuWspwuxTMb)(0CT2muNFfMfaZsCyjnLfCeP153hu0Jn43NMR1SeplaIffS8UMQ3GFsR9jdox7nu5QAcKffSOUAnd(9P5ATzOo)kmlaMf0WsFw6ZsF73oUkNKT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr27o(hxNJGwOHL4zbGKelayw6XIYjXcWZI6Q1m)1rwGtLbhY7uVcKgd(9aqS0Nfaml9yrD1Ag87tZ1AZqD(vywaEwIdliHfCeP15nh)elaplwXY7AQEd(jT2Nm4CT3qLRQjqw6ZcaMLESeGqni0szWVpnxRnd15xHzb4zjoSGewWrKwN3C8tSa8S8UMQ3GFsR9jdox7nu5QAcKL(SaGzPhlGW30wtImSLj9QiZqD(vywaEwqdl9zrbl9yrD1Ag87tZ1AZkIL0uwcqOgeAPm43NMR1MH68RWS03EhKWH5I(dw27i31HL2FcZILn63OHfNL93h8AqrSSWelwoTMLGVWel7VpnxRz5HS0CTMfyRHww8cKLfMyz)9bVguelpKfGikILyXqEN6vG0Wc(9aqSSIS3r4tU8oYEh)(0CToBbwFU5ADg2A2VDCvwzBRBVtLRQjq7yyV7H)GL9o(9bVguK9oiHdZf9hSS3JvmXY(7dEnOiwSC)glXIH8o1RaPHLhYcqefXYkILFJyrD1ASy5(n46zrdXxHIL93NMR1SSI(RJyXlqwwyIL93h8AqrSalwqpGXsmGX26SGFpaeMLv9NMf0JL3hu0JT3dZ90CU9ocFoxvtgWH8USLtRZnxRZWwJffSGWNZv1Kb)(0CToBbwFU5ADg2ASOGfRybHpNRQjZHQGdLXVp41GIyjnLLESOUAnJQR9kqzyl7AD(3Ucfox(VgYGFpaelXZsCyjnLf1vRzuDTxbkdBzxRZ)2vOWzFcErg87bGyjEwIdl9zrbl4isRZVpOOhBWVpnxRzbWSGESOGfe(CUQMm43NMR1zlW6ZnxRZWwZ(TJRYaY2627u5QAc0og27E4pyzV7GE0FiOm2IpD27HebnLFFqrp2oUkBVhM7P5C7DRy5VaqxHIffSyflE4pyzCqp6peugBXNUmO35OiZv5M(qT9SKMYci8noOh9hckJT4txg07CuKb)EaiwamlXHffSacFJd6r)HGYyl(0Lb9ohfzgQZVcZcGzjo27Geomx0FWYEpwXelyl(0XcgYYV5pljGlwqrplDoszzf9xhXIAcww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz538IL4Wc(9aqywGdliJSWplw2OIL4amwWVhacZcH0OBi73oUkhhBRBVtLRQjq7yyV7H)GL9EhewTBi79qIGMYVpOOhBhxLT3dZ90CU9(qTHWBUQMyrblVpOO38xhLFyg8iwINLES0JfLrpwagl9ybhrAD(9bf9yd(9PDdXcWZcGyb4zrD1AgkOVimL1RYhZkIL(S0NfGXYqD(vyw6ZcsyPhlkZcWy5DnvV5TCvUdclSHkxvtGS0NffS0JLaeQbHwktWZxfmd5GjyrblwXc4SoqtbZbqmlkyPhli85CvnzcWcbeikds4evGL0uwcqOgeAPmbyHaceL)nkJJU5ESzihmblPPSyflbicQ86n1HA7ZnNyPplPPSGJiTo)(GIESb)(0UHybWS0JLESaWybaZspwuxTMHc6lctz9Q8XSIyb4zbqS0NL(Sa8S0JfLzbyS8UMQ38wUk3bHf2qLRQjqw6ZsFwuWIvSqb9fHjdgQ9jxesFwstzPhluqFryYCvgd1(WsAkl9yHc6lctMRYQWFJL0uwOG(IWK5QSEv(WsFwuWIvS8UMQ3GHlDg2Y)gLBWHWVHkxvtGSKMYI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lIL4vIfaHMKyPplkyPhl4isRZVpOOhBWVpTBiwamlkNelapl9yrzwaglVRP6nVLRYDqyHnu5QAcKL(S0NffS44FCDocAHgwINf0KelaywuxTMb)(0CT2muNFfMfGNfagl9zrbl9yXkwuxTMbORahcmtDrql00r1NPIguxmjZkIL0uwOG(IWK5QmgQ9HL0uwSILaebvE9gGsmNxS0NffSyflQRwZmocQGlCUnufZez8vTLoVLa)0CUzfzVds4WCr)bl79yzQneEJfauqy1UHy5ASG8yJeRTcSCywgYbtGww(nAiw8Hyrtyml)MxSGgwEFqrpMLRyXAwLpSG(b9fHjwSC)gl7WhabTSOjmMLFZlwuojwG)gnwomXYvS4vcwq)G(IWelWHLvelpKf0WY7dk6XSOsn4qS4SynRYhwq)G(IWKHLybSq3ZYqTHWBSaUMRqXcY4RahcKf0VlcAHMoQEwwLMWywUILDO2hwq)G(IWK9BhxLrpBRBVtLRQjq7yyV7H)GL9EdobkdB5Y)1q27Geomx0FWYEpwXelaiW4YcSyjaYIL73GRNLGhfDfk79WCpnNBV7r5WgfaY(TJRYOX2627u5QAc0og27Wi7Dm927E4pyzVJWNZv1K9ocxVi7DRybCwhOPG5aiMffSGWNZv1KjaMdWc8(dwSOGLES0Jf1vRzWVpnxRnRiwstz5DnvVb)Kw7tgCU2BOYv1eilPPSeGiOYR3uhQTp3CIL(SOGLESyflQRwZGHA8FbYSIyrblwXI6Q1mbpFvWSIyrbl9yXkwExt1BARjrg2YKEvKHkxvtGSKMYI6Q1mbpFvWaUg)pyXs8SeGqni0szARjrg2YKEvKzOo)kmlaJfacl9zrbli85Cvnz(T506mMiGOjBXVNffS0JfRyjarqLxVPouBFU5elPPSeGqni0szcWcbeik)BughDZ9yZkIffS0Jf1vRzWVpnxRnd15xHzbWSaiwstzXkwExt1BWpP1(KbNR9gQCvnbYsFw6ZIcwEFqrV5Vok)Wm4rSeplQRwZe88vbd4A8)Gflapljza4S0NL0uwuHymlkyPDO2(8qD(vywamlQRwZe88vbd4A8)Gfl9T3r4tU8oYEpaMdWc8(dwzhs2VDCvgGzBD7DQCvnbAhd7Dp8hSS3dKMW)56SRpuvhvV9oiHdZf9hSS3JvmXcYJnsS2kWcSyjaYYQ0egZIxGSOVIy5EwwrSy5(nwqoSqabIS3dZ90CU9ocFoxvtMayoalW7pyLDiz)2XvzaUT1T3PYv1eODmS3dZ90CU9ocFoxvtMayoalW7pyLDizV7H)GL9(vbFk)pyz)2XvzaIT1T3PYv1eODmS39WFWYEN6IGwOjRclq7DqchMl6pyzVhRyIf0VlcAHgwIbSazbwSeazXY9BSS)(0CTMLvelEbYc2rqS0Gdla0Lg7dlEbYcYJnsS2kyVhM7P5C79REAIGA)jWC7qT95H68RWSaywugnSKMYspwuxTMjAUo4aEUo7tWRlKJwASpgeUErSaywaeAsIL0uwuxTMjAUo4aEUo7tWRlKJwASpgeUErSeVsSai0Kel9zrblQRwZGFFAUwBwrSOGLESeGqni0szcE(QGzOo)kmlXZcAsIL0uwaN1bAkyoaIzPV9BhxLbo2w3ENkxvtG2XWE3d)bl7D8tATp5M2hYEpKiOP87dk6X2Xvz79WCpnNBVpuBi8MRQjwuWYFDu(HzWJyjEwugnSOGfCeP153hu0Jn43N2nelaMf0JffS4r5WgfaIffS0Jf1vRzcE(QGzOo)kmlXZIYjXsAklwXI6Q1mbpFvWSIyPV9oiHdZf9hSS3JLP2q4nwAAFiwGflRiwEilXHL3hu0JzXY9BW1ZcYJnsS2kWIkDfkwCv46z5HSqin6gIfVazPGplqe0e8OORqz)2XfqjzBD7DQCvnbAhd7Dp8hSS3BRjrg2YKEvK9oiHdZf9hSS3JvmXcace9z5ASCf(ajw8If0pOVimXIxGSOVIy5EwwrSy5(nwCwaOln2hwIgyGfVazj2GE0Fiiw2T4tN9EyUNMZT3PG(IWK5QSxjyrblEuoSrbGyrblQRwZenxhCapxN9j41fYrln2hdcxViwamlacnjXIcw6Xci8noOh9hckJT4txg07CuK5VaqxHIL0uwSILaebvE9MIcdudhqwstzbhrAD(9bf9ywINfaXsFwuWspwuxTMzCeubx4CBOkMjmd15xHzbWSaCybaZspwqdlaplZQOgCqrg8vTLoVLa)0CUHkxvtGS0NffSOUAnZ4iOcUW52qvmtywrSKMYIvSOUAnZ4iOcUW52qvmtywrS0NffS0JfRyjaHAqOLYe88vbZkIL0uwuxTM53MtRZyIaIgd(9aqSaywugnSOGL2HA7Zd15xHzbWSaOKsIffS0ouBFEOo)kmlXZIYjLelPPSyfly4sREfO53MtRZyIaIgdvUQMazPplkyPhly4sREfO53MtRZyIaIgdvUQMazjnLLaeQbHwktWZxfmd15xHzjEwItsS03(TJlGu22627u5QAc0og27E4pyzVJFFAUwBVds4WCr)bl79yftS4SS)(0CTMfa0f9BSenWalRstyml7VpnxRz5WS46HCWeSSIyboSKaUyXhIfxfUEwEilqe0e8iwIngGAVhM7P5C7D1vRzGf9B4Cenbk6pyzwrSOGLESOUAnd(9P5ATzO2q4nxvtSKMYIJ)X15iOfAyjEwaojXsF73oUacq2w3ENkxvtG2XWE3d)bl7D87tZ1A7DqchMl6pyzVhlwDrSeBmaLfvQbhIfKdleqGiwSC)gl7VpnxRzXlqw(nQyz)9bVguK9EyUNMZT3dqeu51BQd12NBoXIcwSIL31u9g8tATpzW5AVHkxvtGSOGLESGWNZv1KjaleqGOmiHtubwstzjaHAqOLYe88vbZkIL0uwuxTMj45RcMvel9zrblbiudcTuMaSqabIY)gLXr3Cp2muNFfMfaZcQaOPZrklaplb60S0Jfh)JRZrql0WcsybnjXsFwuWI6Q1m43NMR1MH68RWSaywqpwuWIvSaoRd0uWCaeB)2XfqXX2627u5QAc0og27H5EAo3EparqLxVPouBFU5elkyPhli85CvnzcWcbeikds4evGL0uwcqOgeAPmbpFvWSIyjnLf1vRzcE(QGzfXsFwuWsac1GqlLjaleqGO8VrzC0n3Jnd15xHzbWSaWyrblQRwZGFFAUwBwrSOGfkOVimzUk7vcwuWIvSGWNZv1K5qvWHY43h8AqrSOGfRybCwhOPG5ai2E3d)bl7D87dEnOi73oUac9STU9ovUQMaTJH9Uh(dw2743h8Aqr27Geomx0FWYEpwXel7Vp41GIyXY9BS4flaOl63yjAGbwGdlxJLeWf6azbIGMGhXsSXauwSC)gljGRHLIq6ZsWXVHLyRXqwaxDrSeBmaLf)z53iwOcKfyJLFJyjwkv)wIHf1vRXY1yz)9P5AnlwGlnyHUNLMR1SaBnwGdljGlw8HybwSaiwEFqrp2Epm3tZ527QRwZal63W5GM8jJ4WhSmRiwstzPhlwXc(9PDdz8OCyJcaXIcwSIfe(CUQMmhQcoug)(GxdkIL0uw6XI6Q1mbpFvWmuNFfMfaZcAyrblQRwZe88vbZkIL0uw6XspwuxTMj45RcMH68RWSaywqfanDoszb4zjqNMLES44FCDocAHgwqclXjjw6ZIcwuxTMj45RcMvelPPSOUAnZ4iOcUW52qvmtKXx1w68wc8tZ5MH68RWSaywqfanDoszb4zjqNMLES44FCDocAHgwqclXjjw6ZIcwuxTMzCeubx4CBOkMjY4RAlDElb(P5CZkIL(SOGLaebvE9geu9Bjgw6ZsFwuWspwWrKwNFFqrp2GFFAUwZcGzjoSKMYccFoxvtg87tZ16Sfy95MR1zyRXsFw6ZIcwSIfe(CUQMmhQcoug)(GxdkIffS0JfRyzwf1GdkY8xhzbovgCiVt9kqAmu5QAcKL0uwWrKwNFFqrp2GFFAUwZcGzjoS03(TJlGqJT1T3PYv1eODmS39WFWYEVil5oiSS3bjCyUO)GL9ESIjwaqbHfMLRyzhQ9Hf0pOVimXIxGSGDeelailTMfauqyXsdoSG8yJeRTc27H5EAo3EVhlQRwZqb9fHPmgQ9XmuNFfML4zHqkfwpL)RJyjnLLESe28bfHzrjwaelkyzOWMpOO8FDelaMf0WsFwstzjS5dkcZIsSehw6ZIcw8OCyJcaz)2XfqamBRBVtLRQjq7yyVhM7P5C79ESOUAndf0xeMYyO2hZqD(vywINfcPuy9u(VoIL0uw6XsyZhueMfLybqSOGLHcB(GIY)1rSaywqdl9zjnLLWMpOimlkXsCyPplkyXJYHnkaelkyPhlQRwZmocQGlCUnufZeMH68RWSaywqdlkyrD1AMXrqfCHZTHQyMWSIyrblwXYSkQbhuKbFvBPZBjWpnNBOYv1eilPPSyflQRwZmocQGlCUnufZeMvel9T39WFWYEFZ1TChew2VDCbea32627u5QAc0og27H5EAo3EVhlQRwZqb9fHPmgQ9XmuNFfML4zHqkfwpL)RJyrbl9yjaHAqOLYe88vbZqD(vywINf0KelPPSeGqni0szcWcbeik)BughDZ9yZqD(vywINf0Kel9zjnLLESe28bfHzrjwaelkyzOWMpOO8FDelaMf0WsFwstzjS5dkcZIsSehw6ZIcw8OCyJcaXIcw6XI6Q1mJJGk4cNBdvXmHzOo)kmlaMf0WIcwuxTMzCeubx4CBOkMjmRiwuWIvSmRIAWbfzWx1w68wc8tZ5gQCvnbYsAklwXI6Q1mJJGk4cNBdvXmHzfXsF7Dp8hSS3BlTo3bHL9BhxabqSTU9ovUQMaTJH9oiHdZf9hSS3JvmXcYae9zbwSG8yH9Uh(dw27w8zo4KHTmPxfz)2XfqahBRBVtLRQjq7yyVdJS3X0BV7H)GL9ocFoxvt27iC9IS3XrKwNFFqrp2GFFA3qSeplOhlaJLMgchw6XsNJFAsKr46fXcWZIYjLeliHfaLel9zbyS00q4WspwuxTMb)(GxdkktDrql00r1NXqTpg87bGybjSGES03EhKWH5I(dw27i31HL2FcZILn63OHLhYYctSS)(0UHy5kw2HAFyXY2f2y5WS4plOHL3hu0JbMYS0GdlecAsWcGsczYsNJFAsWcCyb9yz)9bVguelOFxe0cnDu9SGFpae2EhHp5Y7i7D87t7gkFvgd1(y)2XnojzBD7DQCvnbAhd7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9UYSGewWrKwN3C8tSaywaelayw6XssgaXcWZspwWrKwNFFqrp2GFFA3qSaGzrzw6ZcWZspwuMfGXY7AQEdgU0zyl)BuUbhc)gQCvnbYcWZIYg0WsFw6ZcWyjjJYOHfGNf1vRzghbvWfo3gQIzcZqD(vy7DqchMl6pyzVJCxhwA)jmlw2OFJgwEilidJ)BSaUMRqXcaYqvmtyVJWNC5DK9ULX)T8v52qvmty)2XnokBBD7DQCvnbAhd7Dp8hSS3Tm(VzVds4WCr)bl79yftSGmm(VXYvSSd1(Wc6h0xeMyboSCnwkil7VpTBiwSCAnlT7z5QhYcYJnsS2kWIxj6GdzVhM7P5C79ESqb9fHjJEv(KlcPplPPSqb9fHjJxjYfH0NffSGWNZv1K5W5GMCeel9zrbl9y59bf9M)6O8dZGhXs8SGESKMYcf0xeMm6v5t(QmGyjnLL2HA7Zd15xHzbWSOCsS0NL0uwuxTMHc6lctzmu7JzOo)kmlaMfp8hSm43N2nKHqkfwpL)RJyrblQRwZqb9fHPmgQ9XSIyjnLfkOVimzUkJHAFyrblwXccFoxvtg87t7gkFvgd1(WsAklQRwZe88vbZqD(vywamlE4pyzWVpTBidHukSEk)xhXIcwSIfe(CUQMmhoh0KJGyrblQRwZe88vbZqD(vywamlesPW6P8FDelkyrD1AMGNVkywrSKMYI6Q1mJJGk4cNBdvXmHzfXIcwq4Z5QAYyz8FlFvUnufZeSKMYIvSGWNZv1K5W5GMCeelkyrD1AMGNVkygQZVcZs8SqiLcRNY)1r2VDCJdGSTU9ovUQMaTJH9oiHdZf9hSS3JvmXY(7t7gILRXYvSynRYhwq)G(IWeAz5kw2HAFyb9d6lctSalwqpGXY7dk6XSahwEilrdmWYou7dlOFqFryYE3d)bl7D87t7gY(TJBCIJT1T3PYv1eODmS3bjCyUO)GL9oaIR1)2SS39WFWYEFwv2d)bRS(WV9U(WFU8oYEV5A9Vnl73(T3BUw)BZY262XvzBRBVtLRQjq7yyV7H)GL9o(9bVguK9oiHdZf9hSS33FFWRbfXsdoS0brqDu9SSknHXSSWxHILyaJT1T3dZ90CU9UvSmRIAWbfzuDTxbkdBzxRZ)2vOWgcaSUOic0(TJlGSTU9ovUQMaTJH9Uh(dw274v1UHS3djcAk)(GIESDCv2Epm3tZ527GW30bHv7gYmuNFfML4zzOo)kmlaplacqSGewugGyVds4WCr)bl7DK74NLFJybe(Sy5(nw(nILoi(z5VoILhYIdcYYQ(tZYVrS05iLfW14)blwomlB3ByzFvTBiwgQZVcZs3s)xK(iqwEilD(h2yPdcR2nelGRX)dw2VDCJJT1T39WFWYEVdcR2nK9ovUQMaTJH9B)2743262XvzBRBVtLRQjq7yyV7H)GL9o(9bVguK9oiHdZf9hSS3JvmXY(7dEnOiwEilaruelRiw(nILyXqEN6vG0WI6Q1y5ASCplwGlnilesJUHyrLAWHyPD1H3Ucfl)gXsri9zj44Nf4WYdzbC1fXIk1GdXcYHfciqK9EyUNMZT3Nvrn4GIm)1rwGtLbhY7uVcKgdvUQMazrbl9yHc6lctMRYELGffSyfl9yPhlQRwZ8xhzbovgCiVt9kqAmd15xHzjEw8WFWYyz8FZqiLcRNY)1rSamwsYOmlkyPhluqFryYCvwf(BSKMYcf0xeMmxLXqTpSKMYcf0xeMm6v5tUiK(S0NL0uwuxTM5VoYcCQm4qEN6vG0ygQZVcZs8S4H)GLb)(0UHmesPW6P8FDelaJLKmkZIcw6Xcf0xeMmxL1RYhwstzHc6lctgmu7tUiK(SKMYcf0xeMmELixesFw6ZsFwstzXkwuxTM5VoYcCQm4qEN6vG0ywrS0NL0uw6XI6Q1mbpFvWSIyjnLfe(CUQMmbyHaceLbjCIkWsFwuWsac1GqlLjaleqGO8VrzC0n3Jnd5GjyrblbicQ86n1HA7ZnNyPplkyPhlwXsaIGkVEdqjMZlwstzjaHAqOLYqDrql0KvHfOzOo)kmlXZcaHL(SOGLESOUAntWZxfmRiwstzXkwcqOgeAPmbpFvWmKdMGL(2VDCbKT1T3PYv1eODmS39WFWYE3b9O)qqzSfF6S3djcAk)(GIESDCv2Epm3tZ527wXci8noOh9hckJT4txg07CuK5VaqxHIffSyflE4pyzCqp6peugBXNUmO35OiZv5M(qT9SOGLESyflGW34GE0FiOm2IpD5nY1M)caDfkwstzbe(gh0J(dbLXw8PlVrU2muNFfML4zbnS0NL0uwaHVXb9O)qqzSfF6YGENJIm43daXcGzjoSOGfq4BCqp6peugBXNUmO35OiZqD(vywamlXHffSacFJd6r)HGYyl(0Lb9ohfz(la0vOS3bjCyUO)GL9ESIjwInOh9hcILDl(0XILnQy53OHy5WSuqw8WFiiwWw8PdTS4yw0(tS4ywIGy8PQjwGflyl(0XIL73ybqSahwAKfAyb)EaimlWHfyXIZsCaglyl(0XcgYYV5pl)gXsrwybBXNow8zoeeMfKrw4NfV90WYV5plyl(0XcH0OBiS9Bh34yBD7DQCvnbAhd7Dp8hSS3dWcbeik)BughDZ9y7DqchMl6pyzVhRycZcYHfciqelxJfKhBKyTvGLdZYkIf4Wsc4IfFiwajCIkCfkwqESrI1wbwSC)glihwiGarS4filjGlw8HyrL0qlSGEjXsSXau79WCpnNBVBflGZ6anfmhaXSOGLES0Jfe(CUQMmbyHaceLbjCIkWIcwSILaeQbHwktWZxfmd5GjyrblwXYSkQbhuKjAUo4aEUo7tWRlKJwASpgQCvnbYsAklQRwZe88vbZkIL(SOGfh)JRZrql0WcGvIf0ljwuWspwuxTMHc6lctz9Q8XmuNFfML4zr5KyjnLf1vRzOG(IWugd1(ygQZVcZs8SOCsS0NL0uwuHymlkyPDO2(8qD(vywamlkNelkyXkwcqOgeAPmbpFvWmKdMGL(2VDCrpBRBVtLRQjq7yyVdJS3X0BV7H)GL9ocFoxvt27iC9IS37XI6Q1mJJGk4cNBdvXmHzOo)kmlXZcAyjnLfRyrD1AMXrqfCHZTHQyMWSIyPplkyXkwuxTMzCeubx4CBOkMjY4RAlDElb(P5CZkIffS0Jf1vRza6kWHaZuxe0cnDu9zQOb1ftYmuNFfMfaZcQaOPZrkl9zrbl9yrD1AgkOVimLXqTpMH68RWSeplOcGMohPSKMYI6Q1muqFrykRxLpMH68RWSeplOcGMohPSKMYspwSIf1vRzOG(IWuwVkFmRiwstzXkwuxTMHc6lctzmu7JzfXsFwuWIvS8UMQ3GHA8FbYqLRQjqw6BVds4WCr)bl7DKdlW7pyXsdoS4AnlGWhZYV5plDoqeMf8Aiw(nkbl(qf6EwgQneEJazXYgvSel7iOcUWSaGmufZeSS5yw0egZYV5flOHfmfWSmuNF1vOyboS8BelaLyoVyrD1ASCywCv46z5HS0CTMfyRXcCyXReSG(b9fHjwomlUkC9S8qwiKgDdzVJWNC5DK9oi8Zdbaw3qDu9y73oUOX2627u5QAc0og27Wi7Dm927E4pyzVJWNZv1K9ocxVi79ESyflQRwZqb9fHPmgQ9XSIyrblwXI6Q1muqFrykRxLpMvel9zjnLL31u9gmuJ)lqgQCvnbAVds4WCr)bl7DKdlW7pyXYV5plHnkaeMLRXsc4IfFiwGRhFGeluqFryILhYcS0jybe(S8B0qSahwoufCiw(TdZIL73yzhQX)fi7De(KlVJS3bHFgUE8bszkOVimz)2XfGzBD7DQCvnbAhd7Dp8hSS37GWQDdzVhM7P5C79HAdH3CvnXIcw6XI6Q1muqFrykJHAFmd15xHzjEwgQZVcZsAklQRwZqb9fHPSEv(ygQZVcZs8SmuNFfML0uwq4Z5QAYac)mC94dKYuqFryIL(SOGLHAdH3CvnXIcwEFqrV5Vok)Wm4rSeplkdiwuWIhLdBuaiwuWccFoxvtgq4NhcaSUH6O6X27HebnLFFqrp2oUkB)2XfGBBD7DQCvnbAhd7Dp8hSS3XRQDdzVhM7P5C79HAdH3CvnXIcw6XI6Q1muqFrykJHAFmd15xHzjEwgQZVcZsAklQRwZqb9fHPSEv(ygQZVcZs8SmuNFfML0uwq4Z5QAYac)mC94dKYuqFryIL(SOGLHAdH3CvnXIcwEFqrV5Vok)Wm4rSeplkdiwuWIhLdBuaiwuWccFoxvtgq4NhcaSUH6O6X27HebnLFFqrp2oUkB)2XfGyBD7DQCvnbAhd7Dp8hSS3XpP1(KBAFi79WCpnNBVpuBi8MRQjwuWspwuxTMHc6lctzmu7JzOo)kmlXZYqD(vywstzrD1AgkOVimL1RYhZqD(vywINLH68RWSKMYccFoxvtgq4NHRhFGuMc6lctS0NffSmuBi8MRQjwuWY7dk6n)1r5hMbpIL4zrzaglkyXJYHnkaelkybHpNRQjdi8Zdbaw3qDu9y79qIGMYVpOOhBhxLTF74cCSTU9ovUQMaTJH9Uh(dw27n4eOmSLl)xdzVds4WCr)bl79yftSaGaJllWILailwUFdUEwcEu0vOS3dZ90CU9UhLdBuai73oUkNKT1T3PYv1eODmS39WFWYEN6IGwOjRclq7DqchMl6pyzVhRyIfKXxboeil7r3CpMfl3VXIxjyrdluSqfCHAJfTJ)RqXc6h0xeMyXlqw(jblpKf9vel3ZYkIfl3VXcaDPX(WIxGSG8yJeRTc27H5EAo3EVhl9yrD1AgkOVimLXqTpMH68RWSeplkNelPPSOUAndf0xeMY6v5JzOo)kmlXZIYjXsFwuWsac1GqlLj45RcMH68RWSeplXjjwuWspwuxTMjAUo4aEUo7tWRlKJwASpgeUErSaywae6LelPPSyflZQOgCqrMO56Gd456SpbVUqoAPX(yiaW6IIiqw6ZsFwstzrD1AMO56Gd456SpbVUqoAPX(yq46fXs8kXcGa4jXsAklbiudcTuMGNVkygYbtWIcwC8pUohbTqdlXZcWjj73oUkRST1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr27wXc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrbl9yPhlbiudcTugQlkXqUodhWYRazgQZVcZcGzrzagaNfGXspwuwzwaEwMvrn4GIm4RAlDElb(P5CdvUQMazPplkyHaaRlkIanuxuIHCDgoGLxbIL(SKMYIJ)X15iOfAyjELyb4KelkyPhlwXY7AQEtBnjYWwM0RImu5QAcKL0uwuxTMj45RcgW14)blwINLaeQbHwktBnjYWwM0RImd15xHzbySaqyPplkybHpNRQjZVnNwNXebenzl(9SOGLESOUAndqxboeyM6IGwOPJQptfnOUysMvelPPSyflbicQ86naLyoVyPplky59bf9M)6O8dZGhXs8SOUAntWZxfmGRX)dwSa8SKKbGZsAklQqmMffS0ouBFEOo)kmlaMf1vRzcE(QGbCn(FWIL0uwcqeu51BQd12NBoXsAklQRwZOQHqq9c)MvelkyrD1AgvnecQx43muNFfMfaZI6Q1mbpFvWaUg)pyXcWyPhlahwaEwMvrn4GImrZ1bhWZ1zFcEDHC0sJ9XqaG1ffrGS0NL(SOGfRyrD1AMGNVkywrSOGLESyflbicQ86n1HA7ZnNyjnLLaeQbHwktawiGar5FJY4OBUhBwrSKMYIkeJzrblTd12NhQZVcZcGzjaHAqOLYeGfciqu(3Omo6M7XMH68RWSamwaySKMYs7qT95H68RWSGmzrzassSaywuxTMj45RcgW14)blw6BVds4WCr)bl79yftSG8yJeRTcSy5(nwqoSqabIqcY4RahcKL9OBUhZIxGSacl09SarqJL5EIfa6sJ9Hf4WILnQyjgAieuVWplwGlnilesJUHyrLAWHyb5XgjwBfyHqA0ne2EhHp5Y7i79ayoalW7pyLXV9BhxLbKT1T3PYv1eODmS39WFWYEFCeubx4CBOkMjS3bjCyUO)GL9ESIjw(nILyPu9BjgwSC)glolip2iXARal)M)SC4cDplTb2XcaDPX(yVhM7P5C7D1vRzcE(QGzOo)kmlXZIYOHL0uwuxTMj45RcgW14)blwamlXjjwuWccFoxvtMayoalW7pyLXV9BhxLJJT1T3PYv1eODmS3dZ90CU9ocFoxvtMayoalW7pyLXplkyPhlwXI6Q1mbpFvWaUg)pyXs8SeNKyjnLfRyjarqLxVbbv)wIHL(SKMYI6Q1mJJGk4cNBdvXmHzfXIcwuxTMzCeubx4CBOkMjmd15xHzbWSaCybySeGf46Et0qHdtzxFOQoQEZFDugHRxelaJLESyflQRwZOQHqq9c)MvelkyXkwExt1BWVpA4aAOYv1eil9T39WFWYEpqAc)NRZU(qvDu92VDCvg9STU9ovUQMaTJH9EyUNMZT3r4Z5QAYeaZbybE)bRm(T39WFWYE)QGpL)hSSF74QmASTU9ovUQMaTJH9omYEhtV9Uh(dw27i85CvnzVJW1lYE3kwcqOgeAPmbpFvWmKdMGL0uwSIfe(CUQMmbyHaceLbjCIkWIcwcqeu51BQd12NBoXsAklGZ6anfmhaX27Geomx0FWYEpwQpNRQjwwycKfyXIRE67pcZYV5plw86z5HSOsSGDeeiln4WcYJnsS2kWcgYYV5pl)gLGfFO6zXIJFcKfKrw4NfvQbhILFJ6S3r4tU8oYEh7iOCdo5GNVky)2XvzaMT1T3PYv1eODmS39WFWYEVTMezylt6vr27Geomx0FWYEpwXeMfaei6ZY1y5kw8If0pOVimXIxGS8ZrywEil6RiwUNLvelwUFJfa6sJ9bTSG8yJeRTcS4filXg0J(dbXYUfF6S3dZ90CU9of0xeMmxL9kblkyXJYHnkaelkyrD1AMO56Gd456SpbVUqoAPX(yq46fXcGzbqOxsSOGLESacFJd6r)HGYyl(0Lb9ohfz(la0vOyjnLfRyjarqLxVPOWa1WbKL(SOGfe(CUQMmyhbLBWjh88vbwuWspwuxTMzCeubx4CBOkMjmd15xHzbWSaCybaZspwqdlaplZQOgCqrg8vTLoVLa)0CUHkxvtGS0NffSOUAnZ4iOcUW52qvmtywrSKMYIvSOUAnZ4iOcUW52qvmtywrS03(TJRYaCBRBVtLRQjq7yyV7H)GL9o(9P5AT9oiHdZf9hSS3JvmXca6I(nw2FFAUwZs0adywUgl7VpnxRz5Wf6Ewwr27H5EAo3ExD1Agyr)gohrtGI(dwMvelkyrD1Ag87tZ1AZqTHWBUQMSF74QmaX2627u5QAc0og27H5EAo3ExD1Ag87JgoGMH68RWSaywqdlkyPhlQRwZqb9fHPmgQ9XmuNFfML4zbnSKMYI6Q1muqFrykRxLpMH68RWSeplOHL(SOGfh)JRZrql0Ws8SaCsYE3d)bl79GxbsNvxTM9U6Q1YL3r2743hnCaTF74QmWX2627u5QAc0og27E4pyzVJFFWRbfzVds4WCr)bl79yXQlcZsSXauwuPgCiwqoSqabIyzHVcfl)gXcYHfciqelbybE)blwEilHnkaelxJfKdleqGiwomlE4xUwNGfxfUEwEilQelbh)27H5EAo3EparqLxVPouBFU5elkybHpNRQjtawiGarzqcNOcSOGLaeQbHwktawiGar5FJY4OBUhBgQZVcZcGzbnSOGfRybCwhOPG5aiMffSqb9fHjZvzVsWIcwC8pUohbTqdlXZc6LK9BhxaLKT1T3PYv1eODmS39WFWYEh)(0CT2EhKWH5I(dw27XkMyz)9P5AnlwUFJL9N0AFyjwmx7zXlqwkil7VpA4aIwwSSrflfKL93NMR1SCywwrOLLeWfl(qSCflwZQ8Hf0pOVimXsdoSaqagMcywGdlpKLObgybGU0yFyXYgvS4QqeelaNKyj2yaklWHfhmY)dbXc2IpDSS5ywaiadtbmld15xDfkwGdlhMLRyPPpuBVHL4cFILFZFwwfinS8BelyVJyjalW7pyHz5E0HzbmcZsrRFCnlpKL93NMR1SaUMRqXsSSJGk4cZcaYqvmtGwwSSrfljGl0bYc(pTMfQazzfXIL73yb4KeWCCeln4WYVrSOD8Zcknu11yJ9EyUNMZT3Fxt1BWpP1(KbNR9gQCvnbYIcwSIL31u9g87JgoGgQCvnbYIcwuxTMb)(0CT2muBi8MRQjwuWspwuxTMHc6lctz9Q8XmuNFfML4zbGWIcwOG(IWK5QSEv(WIcwuxTMjAUo4aEUo7tWRlKJwASpgeUErSaywaeAsIL0uwuxTMjAUo4aEUo7tWRlKJwASpgeUErSeVsSai0KelkyXX)46Ce0cnSeplaNKyjnLfq4BCqp6peugBXNUmO35OiZqD(vywINfaclPPS4H)GLXb9O)qqzSfF6YGENJImxLB6d12ZsFwuWsac1GqlLj45RcMH68RWSeplkNK9BhxaPST1T3PYv1eODmS39WFWYEh)(GxdkYEhKWH5I(dw27XkMyz)9bVguelaOl63yjAGbmlEbYc4QlILyJbOSyzJkwqESrI1wbwGdl)gXsSuQ(TedlQRwJLdZIRcxplpKLMR1SaBnwGdljGl0bYsWJyj2yaQ9EyUNMZT3vxTMbw0VHZbn5tgXHpyzwrSKMYI6Q1maDf4qGzQlcAHMoQ(mv0G6IjzwrSKMYI6Q1mbpFvWSIyrbl9yrD1AMXrqfCHZTHQyMWmuNFfMfaZcQaOPZrklaplb60S0Jfh)JRZrql0WcsyjojXsFwaglXHfGNL31u9MISK7GWYqLRQjqwuWIvSmRIAWbfzWx1w68wc8tZ5gQCvnbYIcwuxTMzCeubx4CBOkMjmRiwstzrD1AMGNVkygQZVcZcGzbva005iLfGNLaDAw6XIJ)X15iOfAybjSeNKyPplPPSOUAnZ4iOcUW52qvmtKXx1w68wc8tZ5MvelPPS0Jf1vRzghbvWfo3gQIzcZqD(vywamlE4pyzWVpTBidHukSEk)xhXIcwWrKwN3C8tSaywsYGESKMYI6Q1mJJGk4cNBdvXmHzOo)kmlaMfp8hSmwg)3mesPW6P8FDelPPSGWNZv1K5aaG5aSaV)GflkyjaHAqOLYCfomR3v1ugaS86xDzqcXfiZqoycwuWcbawxuebAUchM17QAkdawE9RUmiH4cel9zrblQRwZmocQGlCUnufZeMvelPPSyflQRwZmocQGlCUnufZeMvelkyXkwcqOgeAPmJJGk4cNBdvXmHzihmblPPSyflbicQ86niO63smS0NL0uwC8pUohbTqdlXZcWjjwuWcf0xeMmxL9kH9BhxabiBRBVtLRQjq7yyV7H)GL9o(9bVguK9oiHdZf9hSS3T(KGLhYsNdeXYVrSOs4NfyJL93hnCazrnbl43daDfkwUNLvelaG1fasNGLRyXReSG(b9fHjwuxpla0Lg7dlhUEwCv46z5HSOsSenWqGaT3dZ90CU9(7AQEd(9rdhqdvUQMazrblwXYSkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkyPhlQRwZGFF0Wb0SIyjnLfh)JRZrql0Ws8SaCsIL(SOGf1vRzWVpA4aAWVhaIfaZsCyrbl9yrD1AgkOVimLXqTpMvelPPSOUAndf0xeMY6v5JzfXsFwuWI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lIfaZcGa4jXIcw6Xsac1GqlLj45RcMH68RWSeplkNelPPSyfli85CvnzcWcbeikds4evGffSeGiOYR3uhQTp3CIL(2VDCbuCSTU9ovUQMaTJH9omYEhtV9Uh(dw27i85CvnzVJW1lYENc6lctMRY6v5dlaplaewqclE4pyzWVpTBidHukSEk)xhXcWyXkwOG(IWK5QSEv(WcWZspwaySamwExt1BWWLodB5FJYn4q43qLRQjqwaEwIdl9zbjS4H)GLXY4)MHqkfwpL)RJybySKKb9qdliHfCeP15nh)elaJLKmOHfGNL31u9MY)1q4SQR9kqgQCvnbAVds4WCr)bl7D0h)xN)eMLnOfw6wHnwIngGYIpelO8RiqwIOHfmfGfO9ocFYL3r27oocGsZofSF74ci0Z2627u5QAc0og27E4pyzVJFFWRbfzVds4WCr)bl79yXQlIL93h8AqrSCflolaCGHPal7qTpSG(b9fHj0YciSq3ZIMEwUNLObgybGU0yFyP3V5plhMLnVa1eilQjyHUFJgw(nIL93NMR1SOVIyboS8BelXgdqJh4Kel6RiwAWHL93h8Aqr9rllGWcDplqe0yzUNyXlwaqx0VXs0adS4filA6z53iwCvicIf9velBEbQjw2FF0Wb0Epm3tZ527wXYSkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkyPhlQRwZenxhCapxN9j41fYrln2hdcxViwamlacGNelPPSOUAnt0CDWb8CD2NGxxihT0yFmiC9IybWSai0Kelky5DnvVb)Kw7tgCU2BOYv1eil9zrbl9yHc6lctMRYyO2hwuWIJ)X15iOfAybySGWNZv1KXXrauA2PalaplQRwZqb9fHPmgQ9XmuNFfMfGXci8nT1KidBzsVkY8xaiCEOo)kwaEwaKbnSeplaKKyjnLfkOVimzUkRxLpSOGfh)JRZrql0WcWybHpNRQjJJJaO0StbwaEwuxTMHc6lctz9Q8XmuNFfMfGXci8nT1KidBzsVkY8xaiCEOo)kwaEwaKbnSeplaNKyPplkyXkwuxTMbw0VHZr0eOO)GLzfXIcwSIL31u9g87JgoGgQCvnbYIcw6Xsac1GqlLj45RcMH68RWSeplaCwstzbdxA1Ran)2CADgteq0yOYv1eilkyrD1AMFBoToJjciAm43daXcGzjoXHfaml9yzwf1GdkYGVQT05Te4NMZnu5QAcKfGNf0WsFwuWs7qT95H68RWSeplkNusSOGL2HA7Zd15xHzbWSaOKsIL(SOGLESeGqni0sza6kWHaZ4OBUhBgQZVcZs8SaWzjnLfRyjarqLxVbOeZ5fl9TF74ci0yBD7DQCvnbAhd7Dp8hSS3lYsUdcl7DqchMl6pyzVhRyIfauqyHz5kwSMv5dlOFqFryIfVazb7iiwIL01nGbGS0AwaqbHfln4WcYJnsS2kWIxGSGm(kWHazb97IGwOPJQ3Epm3tZ5279yrD1AgkOVimL1RYhZqD(vywINfcPuy9u(VoIL0uw6XsyZhueMfLybqSOGLHcB(GIY)1rSaywqdl9zjnLLWMpOimlkXsCyPplkyXJYHnkaelkybHpNRQjd2rq5gCYbpFvW(TJlGay2w3ENkxvtG2XWEpm3tZ5279yrD1AgkOVimL1RYhZqD(vywINfcPuy9u(VoIffSyflbicQ86naLyoVyjnLLESOUAndqxboeyM6IGwOPJQptfnOUysMvelkyjarqLxVbOeZ5fl9zjnLLESe28bfHzrjwaelkyzOWMpOO8FDelaMf0WsFwstzjS5dkcZIsSehwstzrD1AMGNVkywrS0NffS4r5WgfaIffSGWNZv1Kb7iOCdo5GNVkWIcw6XI6Q1mJJGk4cNBdvXmHzOo)kmlaMLESGgwaWSaiwaEwMvrn4GIm4RAlDElb(P5CdvUQMazPplkyrD1AMXrqfCHZTHQyMWSIyjnLfRyrD1AMXrqfCHZTHQyMWSIyPV9Uh(dw27BUUL7GWY(TJlGa42w3ENkxvtG2XWEpm3tZ5279yrD1AgkOVimL1RYhZqD(vywINfcPuy9u(VoIffSyflbicQ86naLyoVyjnLLESOUAndqxboeyM6IGwOPJQptfnOUysMvelkyjarqLxVbOeZ5fl9zjnLLESe28bfHzrjwaelkyzOWMpOO8FDelaMf0WsFwstzjS5dkcZIsSehwstzrD1AMGNVkywrS0NffS4r5WgfaIffSGWNZv1Kb7iOCdo5GNVkWIcw6XI6Q1mJJGk4cNBdvXmHzOo)kmlaMf0WIcwuxTMzCeubx4CBOkMjmRiwuWIvSmRIAWbfzWx1w68wc8tZ5gQCvnbYsAklwXI6Q1mJJGk4cNBdvXmHzfXsF7Dp8hSS3BlTo3bHL9BhxabqSTU9ovUQMaTJH9oiHdZf9hSS3JvmXcYae9zbwSeaT39WFWYE3IpZbNmSLj9Qi73oUac4yBD7DQCvnbAhd7Dp8hSS3XVpTBi7DqchMl6pyzVhRyIL93N2nelpKLObgyzhQ9Hf0pOVimHwwqESrI1wbw2CmlAcJz5VoILFZlwCwqgg)3yHqkfwpXIMAplWHfyPtWI1SkFyb9d6lctSCywwr27H5EAo3ENc6lctMRY6v5dlPPSqb9fHjdgQ9jxesFwstzHc6lctgVsKlcPplPPS0Jf1vRzS4ZCWjdBzsVkYSIyjnLfCeP15nh)elaMLKmOhAyrblwXsaIGkVEdcQ(TedlPPSGJiToV54NybWSKKb9yrblbicQ86niO63smS0NffSOUAndf0xeMY6v5JzfXsAkl9yrD1AMGNVkygQZVcZcGzXd)blJLX)ndHukSEk)xhXIcwuxTMj45RcMvel9TF74gNKSTU9ovUQMaTJH9oiHdZf9hSS3JvmXcYW4)glWFJglhMyXY2f2y5WSCfl7qTpSG(b9fHj0YcYJnsS2kWcCy5HSenWalwZQ8Hf0pOVimzV7H)GL9ULX)n73oUXrzBRBVtLRQjq7yyVds4WCr)bl7DaexR)TzzV7H)GL9(SQSh(dwz9HF7D9H)C5DK9EZ16FBw2V9BVhnua2P6VT1TJRY2w3E3d)bl7DGUcCiWmo6M7X27u5QAc0og2VDCbKT1T3PYv1eODmS3Hr27y6T39WFWYEhHpNRQj7DeUEr27jzVds4WCr)bl7DRVrSGWNZv1elhMfm9S8qwsIfl3VXsbzb)(ZcSyzHjw(5kGOhJwwuMflBuXYVrS0Ub)SalILdZcSyzHj0YcGy5AS8BelykalqwomlEbYsCy5ASOc)nw8HS3r4tU8oYEhw5fMY)Cfq0B)2Xno2w3ENkxvtG2XWEhgzV7GG27E4pyzVJWNZv1K9ocxVi7DLT3dZ90CU9(pxbe9MxzZMJZlmLvxTglky5NRaIEZRSjaHAqOLYaUg)pyXIcwSILFUci6nVYMdBEyhLHTChSW)ax4Caw4FwH)Gf2EhHp5Y7i7DyLxyk)ZvarV9Bhx0Z2627u5QAc0og27Wi7Dhe0E3d)bl7De(CUQMS3r46fzVdi79WCpnNBV)ZvarV5bKzZX5fMYQRwJffS8ZvarV5bKjaHAqOLYaUg)pyXIcwSILFUci6npGmh28WokdB5oyH)bUW5aSW)Sc)blS9ocFYL3r27WkVWu(NRaIE73oUOX2627u5QAc0og27Wi7Dhe0E3d)bl7De(CUQMS3r4tU8oYEhw5fMY)Cfq0BVhM7P5C7DcaSUOic0CfomR3v1ugaS86xDzqcXfiwstzHaaRlkIanuxuIHCDgoGLxbIL0uwiaW6IIiqdgU0A6)RqLNLAc7DqchMl6pyzVB9nctS8ZvarpMfFiwk4ZIV(o)VGR1jybKEk8eiloMfyXYctSGF)z5NRaIESHLyRT4jWS4GGxHIfLzPJ8cZYVrjyXYP1S4AlEcmlQelrd1OziqwUcKIOcKQNfyJfSg(27iC9IS3v2(TJlaZ2627E4pyzV3bHfqxLBWPZENkxvtG2XW(TJla32627u5QAc0og27E4pyzVBz8FZExFfLdG27kNK9EyUNMZT37Xcf0xeMm6v5tUiK(SKMYcf0xeMmxLXqTpSKMYcf0xeMmxLvH)glPPSqb9fHjJxjYfH0NL(27Geomx0FWYEhGouWXplaIfKHX)nw8cKfNL93h8AqrSalw2TolwUFJL4EO2EwaqCIfVazjgWyBDwGdl7VpTBiwG)gnwomz)2XfGyBD7DQCvnbAhd79WCpnNBV3JfkOVimz0RYNCri9zjnLfkOVimzUkJHAFyjnLfkOVimzUkRc)nwstzHc6lctgVsKlcPpl9zrblrdHWOSXY4)glkyXkwIgcHbqglJ)B27E4pyzVBz8FZ(TJlWX2627u5QAc0og27H5EAo3E3kwMvrn4GImQU2RaLHTSR15F7kuydvUQMazjnLfRyjarqLxVPouBFU5elPPSyfl4isRZVpOOhBWVpnxRzrjwuML0uwSIL31u9MY)1q4SQR9kqgQCvnbYsAkl9yHc6lctgmu7tUiK(SKMYcf0xeMmxL1RYhwstzHc6lctMRYQWFJL0uwOG(IWKXRe5Iq6ZsF7Dp8hSS3XVpTBi73oUkNKT1T3PYv1eODmS3dZ90CU9(SkQbhuKr11EfOmSLDTo)BxHcBOYv1eilkyjarqLxVPouBFU5elkybhrAD(9bf9yd(9P5AnlkXIY27E4pyzVJFFWRbfz)2V9BVJGg8bl74cOKaKYjbWvg4yVBXN6kuy7DKHyhlhxRnUXsaCzHfRVrSCDrW5zPbhwqhi18L(rhldbaw3qGSGHDel(6HD(tGSe28cfHnCYwZvelOhWLfKdle08eil7xhYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)Hdl9qsFw6Pms7B4KTMRiwqpGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSGgGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSaWaUSGCyHGMNazz)6qol4e17iLfKjlpKfRz5SaEio8blwGr04pCyPhs6ZspaH0(gozR5kIfaoWLfKdle08eilOBwf1GdkYaarhlpKf0nRIAWbfzaGgQCvnbIow6Pms7B4KTMRiwa4axwqoSqqZtGSGUFUci6nkBaGOJLhYc6(5kGO38kBaGOJLEacP9nCYwZvelaCGllihwiO5jqwq3pxbe9gazaGOJLhYc6(5kGO38aYaarhl9aes7B4KTMRiwaiaxwqoSqqZtGSGUzvudoOidaeDS8qwq3SkQbhuKbaAOYv1ei6yPNYiTVHt2AUIyb4aCzb5WcbnpbYc6Mvrn4GImaq0XYdzbDZQOgCqrgaOHkxvtGOJLEkJ0(gozR5kIfLtc4YcYHfcAEcKf0nRIAWbfzaGOJLhYc6Mvrn4GImaqdvUQMarhl9ugP9nCYwZvelkRmWLfKdle08eilOBwf1GdkYaarhlpKf0nRIAWbfzaGgQCvnbIow6Pms7B4KTMRiwuooaxwqoSqqZtGSGUzvudoOidaeDS8qwq3SkQbhuKbaAOYv1ei6yPNYiTVHt2AUIyrz0d4YcYHfcAEcKf0nRIAWbfzaGOJLhYc6Mvrn4GImaqdvUQMarhl9aes7B4KTMRiwug9aUSGCyHGMNazbD)Cfq0Bu2aarhlpKf09ZvarV5v2aarhl9aes7B4KTMRiwug9aUSGCyHGMNazbD)Cfq0BaKbaIowEilO7NRaIEZdidaeDS0tzK23WjBnxrSOmAaUSGCyHGMNazbDZQOgCqrgai6y5HSGUzvudoOida0qLRQjq0XspaH0(gozR5kIfLrdWLfKdle08eilO7NRaIEJYgai6y5HSGUFUci6nVYgai6yPNYiTVHt2AUIyrz0aCzb5WcbnpbYc6(5kGO3aidaeDS8qwq3pxbe9Mhqgai6yPhGqAFdNmNmYqSJLJR1g3yjaUSWI13iwUUi48S0GdlOlAOaSt1F0XYqaG1neilyyhXIVEyN)eilHnVqrydNS1CfXsCaUSGCyHGMNazbD)Cfq0Bu2aarhlpKf09ZvarV5v2aarhl9Ids7B4KTMRiwqpGllihwiO5jqwq3pxbe9gazaGOJLhYc6(5kGO38aYaarhl9Ids7B4KTMRiwaoaxwqoSqqZtGSGUzvudoOidaeDS8qwq3SkQbhuKbaAOYv1ei6yPNYiTVHt2AUIyr5KaUSGCyHGMNazbDZQOgCqrgai6y5HSGUzvudoOida0qLRQjq0XspLrAFdNmNmYqSJLJR1g3yjaUSWI13iwUUi48S0GdlOZHe6yziaW6gcKfmSJyXxpSZFcKLWMxOiSHt2AUIyrzGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS4plOpaARHLEkJ0(gozR5kIL4aCzb5WcbnpbYc6Mvrn4GImaq0XYdzbDZQOgCqrgaOHkxvtGOJLEkJ0(gozR5kIfaoWLfKdle08eil7xhYzbNOEhPSGmrMS8qwSMLZsheCPxywGr04pCyPhYSpl9ugP9nCYwZvelaCGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0dqiTVHt2AUIybGaCzb5WcbnpbYY(1HCwWjQ3rklitKjlpKfRz5S0bbx6fMfyen(dhw6Hm7ZspLrAFdNS1CfXcab4YcYHfcAEcKf0nRIAWbfzaGOJLhYc6Mvrn4GImaqdvUQMarhl9ugP9nCYwZvelahGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSOCsaxwqoSqqZtGSSFDiNfCI6DKYcYKLhYI1SCwapeh(GflWiA8hoS0dj9zPhGqAFdNS1CfXIYXb4YcYHfcAEcKL9Rd5SGtuVJuwqMS8qwSMLZc4H4WhSybgrJ)WHLEiPpl9ugP9nCYwZvelakjGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSaiabCzb5WcbnpbYY(1HCwWjQ3rklitwEilwZYzb8qC4dwSaJOXF4WspK0NLEkJ0(gozR5kIfaHEaxwqoSqqZtGSSFDiNfCI6DKYcYKLhYI1SCwapeh(GflWiA8hoS0dj9zPhGqAFdNS1CfXcGqpGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSaiagWLfKdle08eilOBwf1GdkYaarhlpKf0nRIAWbfzaGgQCvnbIow6Pms7B4KTMRiwaeah4YcYHfcAEcKf0nRIAWbfzaGOJLhYc6Mvrn4GImaqdvUQMarhl9ugP9nCYwZvelac4aCzb5WcbnpbYY(1HCwWjQ3rklitwEilwZYzb8qC4dwSaJOXF4WspK0NLEacP9nCYwZvelXjjGllihwiO5jqw2VoKZcor9oszbzYYdzXAwolGhIdFWIfyen(dhw6HK(S0tzK23WjZjJme7y54ATXnwcGllSy9nILRlcopln4Wc6AUw)BZcDSmeayDdbYcg2rS4Rh25pbYsyZlue2WjBnxrSaiGllihwiO5jqw2VoKZcor9oszbzYYdzXAwolGhIdFWIfyen(dhw6HK(S0tzK23WjZjJme7y54ATXnwcGllSy9nILRlcopln4Wc6Wp6yziaW6gcKfmSJyXxpSZFcKLWMxOiSHt2AUIyrzGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSehGllihwiO5jqwq3SkQbhuKbaIowEilOBwf1GdkYaanu5QAceDS0tzK23WjBnxrSOSYaxwqoSqqZtGSSFDiNfCI6DKYcYezYYdzXAwolDqWLEHzbgrJ)WHLEiZ(S0tzK23WjBnxrSOSYaxwqoSqqZtGSGUzvudoOidaeDS8qwq3SkQbhuKbaAOYv1ei6yPNYiTVHt2AUIyrzagWLfKdle08eilOBwf1GdkYaarhlpKf0nRIAWbfzaGgQCvnbIow6Pms7B4KTMRiwaKYaxwqoSqqZtGSSFDiNfCI6DKYcYKLhYI1SCwapeh(GflWiA8hoS0dj9zPhGqAFdNS1CfXcGug4YcYHfcAEcKf0nRIAWbfzaGOJLhYc6Mvrn4GImaqdvUQMarhl9ugP9nCYwZvelacqaxwqoSqqZtGSGUzvudoOidaeDS8qwq3SkQbhuKbaAOYv1ei6yPNYiTVHt2AUIybqXb4YcYHfcAEcKL9Rd5SGtuVJuwqMS8qwSMLZc4H4WhSybgrJ)WHLEiPpl9Ids7B4KTMRiwae6bCzb5WcbnpbYc6Mvrn4GImaq0XYdzbDZQOgCqrgaOHkxvtGOJLEacP9nCYwZvelacGbCzb5WcbnpbYc6Mvrn4GImaq0XYdzbDZQOgCqrgaOHkxvtGOJLEkJ0(gozR5kIfabWbUSGCyHGMNazbDZQOgCqrgai6y5HSGUzvudoOida0qLRQjq0XspLrAFdNmNmYqSJLJR1g3yjaUSWI13iwUUi48S0GdlOtf6p6yziaW6gcKfmSJyXxpSZFcKLWMxOiSHt2AUIyrzacWLfKdle08eil7xhYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)Hdl9qsFw6fhK23WjBnxrSOmWb4YcYHfcAEcKL9Rd5SGtuVJuwqMS8qwSMLZc4H4WhSybgrJ)WHLEiPpl9ugP9nCYCYwBxeCEcKfaglE4pyXI(Wp2WjBVJJOGDCvojazVhnW2Pj7DKfzzjgU2RaXsSywhiNmYISSK8sNGfaPmAzbqjbiL5K5KrwKLfKV5fkcdC5KrwKLfamlXgeKazzhQ9HLyqENHtgzrwwaWSG8nVqrGS8(GI(81yj4ycZYdzjKiOP87dk6XgozKfzzbaZsSm1brqGSSQIceg7tcwq4Z5QAcZsVZqg0Ys0qiY43h8AqrSaGJNLOHqyWVp41GI6B4KrwKLfamlXgb8azjAOGJ)RqXcYW4)glxJL7rhMLFJyXYaluSG(b9fHjdNmYISSaGzbaLdeXcYHfciqel)gXYE0n3JzXzrF)Rjw6GdXstti9u1el9UgljGlw2CWcDplB3ZY9SGVUL(9IGlSoblwUFJLyaGo2wNfGXcYjnH)Z1SeB9HQ6O6rll3JoqwWaDr9nCYilYYcaMfauoqelDq8Zc6AhQTppuNFfgDSGdu5ZbXS4rr6eS8qwuHymlTd12Jzbw6egozKfzzbaZI1hYFwSoSJyb2yjgAFJLyO9nwIH23yXXS4SGJOW5Aw(5kGO3WjZjJSillXUk47pbYsmCTxbILydqTgwcEXIkXsdUkqw8NLT)JWaxKGevx7vGaW4RlyqD)2s1CqKedx7vGaW7xhYrshOz770iJUDAsjvx7vGmpsFozozp8hSWMOHcWov)vcORahcmJJU5EmNmYYI13iwq4Z5QAILdZcMEwEiljXIL73yPGSGF)zbwSSWel)Cfq0JrllkZILnQy53iwA3GFwGfXYHzbwSSWeAzbqSCnw(nIfmfGfilhMfVazjoSCnwuH)gl(qCYE4pyHnrdfGDQ(dmLqccFoxvtOT8osjyLxyk)ZvarpAr46fPusCYE4pyHnrdfGDQ(dmLqccFoxvtOT8osjyLxyk)ZvarpAHrk5GGOfHRxKskJ2RP0pxbe9gLnBooVWuwD1Ak(5kGO3OSjaHAqOLYaUg)pyPWQFUci6nkBoS5HDug2YDWc)dCHZbyH)zf(dwyozp8hSWMOHcWov)bMsibHpNRQj0wEhPeSYlmL)5kGOhTWiLCqq0IW1lsjaH2RP0pxbe9gaz2CCEHPS6Q1u8ZvarVbqMaeQbHwkd4A8)GLcR(5kGO3aiZHnpSJYWwUdw4FGlCoal8pRWFWcZjJSSy9nctS8ZvarpMfFiwk4ZIV(o)VGR1jybKEk8eiloMfyXYctSGF)z5NRaIESHLyRT4jWS4GGxHIfLzPJ8cZYVrjyXYP1S4AlEcmlQelrd1OziqwUcKIOcKQNfyJfSg(CYE4pyHnrdfGDQ(dmLqccFoxvtOT8osjyLxyk)ZvarpAHrk5GGOfHRxKskJ2RPebawxuebAUchM17QAkdawE9RUmiH4cuAkbawxuebAOUOed56mCalVcuAkbawxuebAWWLwt)FfQ8SutWj7H)Gf2enua2P6pWucjDqyb0v5gC64KrwwaOdfC8ZcGybzy8FJfVazXzz)9bVguelWILDRZIL73yjUhQTNfaeNyXlqwIbm2wNf4WY(7t7gIf4VrJLdtCYE4pyHnrdfGDQ(dmLqILX)n0QVIYbqLuoj0EnL6rb9fHjJEv(KlcPFAkf0xeMmxLXqTpPPuqFryYCvwf(BPPuqFryY4vICri97Zj7H)Gf2enua2P6pWucjwg)3q71uQhf0xeMm6v5tUiK(PPuqFryYCvgd1(KMsb9fHjZvzv4VLMsb9fHjJxjYfH0VVIOHqyu2yz8FtHvrdHWaiJLX)nozp8hSWMOHcWov)bMsib)(0UHq71uYQzvudoOiJQR9kqzyl7AD(3Ucfon1QaebvE9M6qT95MtPPwHJiTo)(GIESb)(0CTwjLttT6DnvVP8FneoR6AVcKHkxvtGPP9OG(IWKbd1(KlcPFAkf0xeMmxL1RYN0ukOVimzUkRc)T0ukOVimz8krUiK(95K9WFWcBIgka7u9hykHe87dEnOi0EnLMvrn4GImQU2RaLHTSR15F7kuyfbicQ86n1HA7ZnNuGJiTo)(GIESb)(0CTwjL5K5KrwKLf0hPuy9eilecAsWYFDel)gXIhE4WYHzXr4N2v1KHt2d)blSsyO2NSk5DCYill70Jzj2q0NfyXsCaglwUFdUEwaNR9S4filwUFJL93hnCazXlqwaeWyb(B0y5WeNSh(dwyGPesq4Z5QAcTL3rkD4Sdj0IW1lsjCeP153hu0Jn43NMR1XRSIEw9UMQ3GFF0Wb0qLRQjW0031u9g8tATpzW5AVHkxvtG9ttXrKwNFFqrp2GFFAUwhpG4Krww2PhZsqtocIflBuXY(7t7gILGxSSDplacyS8(GIEmlw2UWglhMLH0ecVEwAWHLFJyb9d6lctS8qwujwIgQrZqGS4filw2UWglTtRPHLhYsWXpNSh(dwyGPesq4Z5QAcTL3rkD4CqtoccTiC9IuchrAD(9bf9yd(9PDdfVYCYillXkMyjg0GPbORqXIL73yb5XgjwBfyboS4TNgwqoSqabIy5kwqESrI1wbozp8hSWatjKOsdMgGUcfAVMs96zvaIGkVEtDO2(CZP0uRcqOgeAPmbyHaceL)nkJJU5ESzf1xH6Q1mbpFvWmuNFfoELrJc1vRzghbvWfo3gQIzcZqD(vyaJEkSkarqLxVbbv)wIjnnarqLxVbbv)wIrH6Q1mbpFvWSIuOUAnZ4iOcUW52qvmtywrk6PUAnZ4iOcUW52qvmtygQZVcdyLvgaJgGFwf1GdkYGVQT05Te4NMZttvxTMj45RcMH68RWawzLttvgzIJiToV54NaSYg0GM(9vGkaAgQZVchFsCYillau4ZIL73yXzb5XgjwBfy538NLdxO7zXzbGU0yFyjAGbwGdlw2OILFJyPDO2EwomlUkC9S8qwOcKt2d)blmWucjrW)GfAVMsQRwZe88vbZqD(v44vgnk6z1SkQbhuKbFvBPZBjWpnNNMQUAnZ4iOcUW52qvmtygQZVcdyLb4ayab8QRwZOQHqq9c)MvKc1vRzghbvWfo3gQIzcZkQFAQkeJv0ouBFEOo)kmGbeA4KrwwqURdlT)eMflB0Vrdll8vOyb5WcbeiILcAHflNwZIR1qlSKaUy5HSG)tRzj44NLFJyb7DelEhCvplWglihwiGarad5XgjwBfyj44hZj7H)GfgykHee(CUQMqB5DKsbyHaceLbjCIkGweUErkfOt3Rx7qT95H68RWayLrdaoaHAqOLYe88vbZqD(v4(itLbij1xPaD6E9AhQTppuNFfgaRmAaWbiudcTuMaSqabIY)gLXr3Cp2aUg)pybGdqOgeAPmbyHaceL)nkJJU5ESzOo)kCFKPYaKK6RWQXpWmHGQ34GGydH0d)400aeQbHwktWZxfmd15xHJ)QNMiO2Fcm3ouBFEOo)kCAAac1GqlLjaleqGO8VrzC0n3Jnd15xHJ)QNMiO2Fcm3ouBFEOo)kmaw5KstTkarqLxVPouBFU5eNmYYsSIjqwEilGK2tWYVrSSWokIfyJfKhBKyTvGflBuXYcFfkwaHlvnXcSyzHjw8cKLOHqq1ZYc7OiwSSrflEXIdcYcHGQNLdZIRcxplpKfWJ4K9WFWcdmLqccFoxvtOT8osPayoalW7pyHweUErk1RDO2(8qD(v44vgnPPJFGzcbvVXbbXMRIhnj1xrVE9iaW6IIiqd1fLyixNHdy5vGu0Rxac1GqlLH6IsmKRZWbS8kqMH68RWawzawsPPbicQ86niO63smkcqOgeAPmuxuIHCDgoGLxbYmuNFfgWkdWa4aRNYkd8ZQOgCqrg8vTLoVLa)0CE)(kSkaHAqOLYqDrjgY1z4awEfiZqoyI(9tt7raG1ffrGgmCP10)xHkpl1ek6zvaIGkVEtDO2(CZP00aeQbHwkdgU0A6)RqLNLAICCqp0aqsszZqD(vyaRSYOx)(PP9cqOgeAPmQ0GPbORqzgYbtKMA14bY8duR7ROxpcaSUOic0CfomR3v1ugaS86xDzqcXfifbiudcTuMRWHz9UQMYaGLx)QldsiUazgYbt0pnThbawxuebAWBoi0cbMHJAg2YpC6O6veGqni0szE40r1tG5RWhQTphh0GM4aiLnd15xH7NM2RhcFoxvtgyLxyk)ZvarVskNMIWNZv1Kbw5fMY)Cfq0RuC6RO3pxbe9gLnd5GjYbiudcTuPP)Cfq0Bu2eGqni0szgQZVch)vpnrqT)eyUDO2(8qD(vyaSYj1pnfHpNRQjdSYlmL)5kGOxjaPO3pxbe9gazgYbtKdqOgeAPst)5kGO3aitac1GqlLzOo)kC8x90eb1(tG52HA7Zd15xHbWkNu)0ue(CUQMmWkVWu(NRaIELsQF)(PPbicQ86naLyoV6NMQcXyfTd12NhQZVcdy1vRzcE(QGbCn(FWItgzzjwQpNRQjwwycKLhYciP9eS4vcw(5kGOhZIxGSeaXSyzJkwS43FfkwAWHfVyb9xrBW5CwIgyGt2d)blmWucji85CvnH2Y7iL(T506mMiGOjBXVhTiC9IuYkmCPvVc08BZP1zmrarJHkxvtGPPTd12NhQZVchpGskP0uvigRODO2(8qD(vyadi0aSEOxsay1vRz(T506mMiGOXGFpaeWdO(PPQRwZ8BZP1zmrarJb)EaO4Jdaba3Bwf1GdkYGVQT05Te4NMZbE00NtgzzjwXelOFxuIHCnlaOhWYRaXcGsctbmlQudoelolip2iXARallmz4K9WFWcdmLqYct57Po0wEhPe1fLyixNHdy5vGq71ukaHAqOLYe88vbZqD(vyadOKueGqni0szcWcbeik)BughDZ9yZqD(vyadOKu0dHpNRQjZVnNwNXebenzl(9PPQRwZ8BZP1zmrarJb)EaO4JtsaR3SkQbhuKbFvBPZBjWpnNd8aS(9vGkaAgQZVchFsPPQqmwr7qT95H68RWaooaCozKLLyftSSdxAn9xHILy5LAcwayykGzrLAWHyXzb5XgjwBfyzHjdNSh(dwyGPeswykFp1H2Y7iLWWLwt)FfQ8SutG2RPuVaeQbHwktWZxfmd15xHbmatHvbicQ86niO63smkSkarqLxVPouBFU5uAAaIGkVEtDO2(CZjfbiudcTuMaSqabIY)gLXr3Cp2muNFfgWamf9q4Z5QAYeGfciqugKWjQqAAac1GqlLj45RcMH68RWagG1pnnarqLxVbbv)wIrrpRMvrn4GIm4RAlDElb(P5CfbiudcTuMGNVkygQZVcdyawAQ6Q1mJJGk4cNBdvXmHzOo)kmGvg9awp0a8eayDrreO5k8pRWdhCg8qCfLvjTUVc1vRzghbvWfo3gQIzcZkQFAQkeJv0ouBFEOo)kmGbeA6Rava0muNFfo(K4KrwwIT2INaZYctSyTiJkwWIL73yb5XgjwBf4K9WFWcdmLqccFoxvtOT8osPdaaMdWc8(dwOfHRxKsQRwZe88vbZqD(v44vgnk6z1SkQbhuKbFvBPZBjWpnNNMQUAnZ4iOcUW52qvmtygQZVcdyLugqaRxCaE1vRzu1qiOEHFZkQpW61dGaGrdWRUAnJQgcb1l8Bwr9bEcaSUOic0Cf(Nv4HdodEiUIYQKw3xH6Q1mJJGk4cNBdvXmHzf1pnvfIXkAhQTppuNFfgWacnCYE4pyHbMsizHP89uhAlVJu6kCywVRQPmay51V6YGeIlqO9AkHWNZv1K5aaG5aSaV)GLcubqZqD(v44tItgzzjwXelZHA7zrLAWHyjaI5K9WFWcdmLqYct57Po0wEhPeEZbHwiWmCuZWw(HthvpAVMs9cqOgeAPmbpFvWmKdMqHvbicQ86n1HA7ZnNuGWNZv1K53MtRZyIaIMSf)(00aebvE9M6qT95MtkcqOgeAPmbyHaceL)nkJJU5ESzihmHIEi85CvnzcWcbeikds4evinnaHAqOLYe88vbZqoyI(9vacFdEvTBiZFbGUcLIEGW3GFsR9j30(qM)caDfQ0uRExt1BWpP1(KBAFidvUQMattXrKwNFFqrp2GFFA3qXhN(k6bcFthewTBiZFbGUcvFf9q4Z5QAYC4SdP00zvudoOiJQR9kqzyl7AD(3Ucfon1X)46Ce0cnXReWjP0u1vRzu1qiOEHFZkQVIEbiudcTugvAW0a0vOmd5GjstTA8az(bQ19ttvHySI2HA7Zd15xHbm6LeNmYYI13omlhMfNLX)nAyH0UkC8NyXINGLhYsNdeXIR1SalwwyIf87pl)Cfq0Jz5HSOsSOVIazzfXIL73yb5XgjwBfyXlqwqoSqabIyXlqwwyILFJybqfilyn8zbwSeaz5ASOc)nw(5kGOhZIpelWILfMyb)(ZYpxbe9yozp8hSWatjKSWu(EQdJwSg(yL(5kGOxz0EnL6HWNZv1Kbw5fMY)Cfq0ReGuy1pxbe9gazgYbtKdqOgeAPst7HWNZv1Kbw5fMY)Cfq0RKYPPi85CvnzGvEHP8pxbe9kfN(k6PUAntWZxfmRif9SkarqLxVbbv)wIjnvD1AMXrqfCHZTHQyMWmuNFfgy9qdWpRIAWbfzWx1w68wc8tZ59bSs)Cfq0Bu2OUATm4A8)GLc1vRzghbvWfo3gQIzcZkknvD1AMXrqfCHZTHQyMiJVQT05Te4NMZnRO(PPbiudcTuMGNVkygQZVcdmaf)pxbe9gLnbiudcTugW14)blfwPUAntWZxfmRif9SkarqLxVPouBFU5uAQvi85CvnzcWcbeikds4evOVcRcqeu51BakXCELMgGiOYR3uhQTp3CsbcFoxvtMaSqabIYGeorfueGqni0szcWcbeik)BughDZ9yZksHvbiudcTuMGNVkywrk61tD1AgkOVimL1RYhZqD(v44voP0u1vRzOG(IWugd1(ygQZVchVYj1xHvZQOgCqrgvx7vGYWw2168VDfkCAAp1vRzuDTxbkdBzxRZ)2vOW5Y)1qg87bGucnPPQRwZO6AVcug2YUwN)TRqHZ(e8Im43daPeaPF)0u1vRza6kWHaZuxe0cnDu9zQOb1ftYSI6NMQcXyfTd12NhQZVcdyaLuAkcFoxvtgyLxyk)ZvarVsj1xbQaOzOo)kC8jXj7H)GfgykHKfMY3tDy0I1WhR0pxbe9acTxtPEi85CvnzGvEHP8pxbe9wPeGuy1pxbe9gLnd5GjYbiudcTuPPi85CvnzGvEHP8pxbe9kbif9uxTMj45RcMvKIEwfGiOYR3GGQFlXKMQUAnZ4iOcUW52qvmtygQZVcdSEOb4Nvrn4GIm4RAlDElb(P58(awPFUci6naYOUATm4A8)GLc1vRzghbvWfo3gQIzcZkknvD1AMXrqfCHZTHQyMiJVQT05Te4NMZnRO(PPbiudcTuMGNVkygQZVcdmaf)pxbe9gazcqOgeAPmGRX)dwkSsD1AMGNVkywrk6zvaIGkVEtDO2(CZP0uRq4Z5QAYeGfciqugKWjQqFfwfGiOYR3auI58srpRuxTMj45RcMvuAQvbicQ86niO63sm9ttdqeu51BQd12NBoPaHpNRQjtawiGarzqcNOckcqOgeAPmbyHaceL)nkJJU5ESzfPWQaeQbHwktWZxfmRif96PUAndf0xeMY6v5JzOo)kC8kNuAQ6Q1muqFrykJHAFmd15xHJx5K6RWQzvudoOiJQR9kqzyl7AD(3UcfonTN6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqkHM0u1vRzuDTxbkdBzxRZ)2vOWzFcErg87bGucG0VF)0u1vRza6kWHaZuxe0cnDu9zQOb1ftYSIstvHySI2HA7Zd15xHbmGsknfHpNRQjdSYlmL)5kGOxPK6Rava0muNFfo(K4KrwwIvmHzX1AwG)gnSalwwyIL7PomlWILaiNSh(dwyGPeswykFp1H5KrwwIfu4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOomNSh(dwyGPesMvL9WFWkRp8J2Y7iLCiHw8px4vsz0EnLq4Z5QAYC4Sdjozp8hSWatjKmRk7H)GvwF4hTL3rkPc9hT4FUWRKYO9AknRIAWbfzuDTxbkdBzxRZ)2vOWgcaSUOicKt2d)blmWucjZQYE4pyL1h(rB5DKs4NtMtgzzb5UoS0(tywSSr)gnS8BelXIH8UG)HnAyrD1ASy50AwAUwZcS1yXY9BxXYVrSuesFwco(5K9WFWcBCiPecFoxvtOT8osjWH8USLtRZnxRZWwdTiC9IuQN6Q1m)1rwGtLbhY7uVcKgZqD(vyaJkaA6CKcSKmkNMQUAnZFDKf4uzWH8o1RaPXmuNFfgWE4pyzWVpTBidHukSEk)xhbSKmkROhf0xeMmxL1RYN0ukOVimzWqTp5Iq6NMsb9fHjJxjYfH0VFFfQRwZ8xhzbovgCiVt9kqAmRifZQOgCqrM)6ilWPYGd5DQxbsdNmYYcYDDyP9NWSyzJ(nAyz)9bVguelhMflW53yj44)kuSarqdl7VpTBiwUIfRzv(Wc6h0xeM4K9WFWcBCibmLqccFoxvtOT8osPdvbhkJFFWRbfHweUErkzff0xeMmxLXqTpk6HJiTo)(GIESb)(0UHIhnkExt1BWWLodB5FJYn4q43qLRQjW0uCeP153hu0Jn43N2nu8a8(CYillXkMyb5WcbeiIflBuXI)SOjmMLFZlwqtsSeBmaLfVazrFfXYkIfl3VXcYJnsS2kWj7H)Gf24qcykHKaSqabIY)gLXr3CpgTxtjRaN1bAkyoaIv0RhcFoxvtMaSqabIYGeorfuyvac1GqlLj45RcMHCWePPQRwZe88vbZkQVIEQRwZqb9fHPSEv(ygQZVchpalnvD1AgkOVimLXqTpMH68RWXdW6RONvZQOgCqrgvx7vGYWw2168VDfkCAQ6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqXhN0u1vRzuDTxbkdBzxRZ)2vOWzFcErg87bGIpo9ttvHySI2HA7Zd15xHbSYjPWQaeQbHwktWZxfmd5Gj6ZjJSSeRyIfaKHQyMGfl3VXcYJnsS2kWj7H)Gf24qcykHKXrqfCHZTHQyMaTxtj1vRzcE(QGzOo)kC8kJgozKLLyftSSVQ2nelxXsKxGu3fybwS4vIF7kuS8B(ZI(qqywug9WuaZIxGSOjmMfl3VXshCiwEFqrpMfVazXFw(nIfQazb2yXzzhQ9Hf0pOVimXI)SOm6XcMcywGdlAcJzzOo)QRqXIJz5HSuWNLnhXvOy5HSmuBi8glGR5kuSynRYhwq)G(IWeNSh(dwyJdjGPesWRQDdH2qIGMYVpOOhRKYO9Ak1BO2q4nxvtPPQRwZqb9fHPmgQ9XmuNFfgWXrbf0xeMmxLXqTpkgQZVcdyLrpfVRP6ny4sNHT8Vr5gCi8BOYv1eyFfVpOO38xhLFyg8O4vg9aW4isRZVpOOhdSH68RWk6rb9fHjZvzVsKMouNFfgWOcGMohP95KrwwIvmXY(QA3qS8qw2CeelolO0qvxZYdzzHjwSwKrfl4K9WFWcBCibmLqcEvTBi0EnLq4Z5QAYCaaWCawG3FWsrac1GqlL5kCywVRQPmay51V6YGeIlqMHCWekiaW6IIiqZv4WSExvtzaWYRF1LbjexG4K9WFWcBCibmLqc(9P5AnAVMsw9UMQ3GFsR9jdox7nu5QAcurp1vRzWVpnxRnd1gcV5QAsrpCeP153hu0Jn43NMR1aooPPwnRIAWbfz(RJSaNkdoK3PEfin9ttFxt1BWWLodB5FJYn4q43qLRQjqfQRwZqb9fHPmgQ9XmuNFfgWXrbf0xeMmxLXqTpkuxTMb)(0CT2muNFfgWaCf4isRZVpOOhBWVpnxRJxj0RVIEwnRIAWbfz0jc(44Ctt0FfQmk91fHP00)6iKjYe9qt8QRwZGFFAUwBgQZVcdma1xX7dk6n)1r5hMbpkE0WjJSSGmC)gl7pP1(WsSyU2ZYctSalwcGSyzJkwgQneEZv1elQRNf8FAnlw87zPbhwSMebFCmlrdmWIxGSacl09SSWelQudoelipwGnSS)NwZYctSOsn4qSGCyHaceXc(QaXYV5plwoTMLObgyXl4Vrdl7VpnxR5K9WFWcBCibmLqc(9P5AnAVMsVRP6n4N0AFYGZ1EdvUQMavOUAnd(9P5ATzO2q4nxvtk6z1SkQbhuKrNi4JJZnnr)vOYO0xxeMst)RJqMit0dnXJE9v8(GIEZFDu(HzWJIpoCYillid3VXsSyiVt9kqAyzHjw2FFAUwZYdzbiIIyzfXYVrSOUAnwutWIRXqww4RqXY(7tZ1AwGflOHfmfGfiMf4WIMWywgQZV6kuCYE4pyHnoKaMsib)(0CTgTxtPzvudoOiZFDKf4uzWH8o1RaPrboI0687dk6Xg87tZ164vkok6zL6Q1m)1rwGtLbhY7uVcKgZksH6Q1m43NMR1MHAdH3CvnLM2dHpNRQjd4qEx2YP15MR1zyRPON6Q1m43NMR1MH68RWaooPP4isRZVpOOhBWVpnxRJhqkExt1BWpP1(KbNR9gQCvnbQqD1Ag87tZ1AZqD(vyaJM(97ZjJSSGCxhwA)jmlw2OFJgwCw2FFWRbfXYctSy50Awc(ctSS)(0CTMLhYsZ1AwGTgAzXlqwwyIL93h8AqrS8qwaIOiwIfd5DQxbsdl43daXYkIt2d)blSXHeWucji85CvnH2Y7iLWVpnxRZwG1NBUwNHTgAr46fPKJ)X15iOfAIhGKeaUNYjb8QRwZ8xhzbovgCiVt9kqAm43da1ha3tD1Ag87tZ1AZqD(vyGpoitCeP15nh)eWB17AQEd(jT2Nm4CT3qLRQjW(a4EbiudcTug87tZ1AZqD(vyGpoitCeP15nh)eW)UMQ3GFsR9jdox7nu5QAcSpaUhi8nT1KidBzsVkYmuNFfg4rtFf9uxTMb)(0CT2SIstdqOgeAPm43NMR1MH68RW95KrwwIvmXY(7dEnOiwSC)glXIH8o1RaPHLhYcqefXYkILFJyrD1ASy5(n46zrdXxHIL93NMR1SSI(RJyXlqwwyIL93h8AqrSalwqpGXsmGX26SGFpaeMLv9NMf0JL3hu0J5K9WFWcBCibmLqc(9bVgueAVMsi85CvnzahY7YwoTo3CTodBnfi85CvnzWVpnxRZwG1NBUwNHTMcRq4Z5QAYCOk4qz87dEnOO00EQRwZO6AVcug2YUwN)TRqHZL)RHm43dafFCstvxTMr11EfOmSLDTo)BxHcN9j4fzWVhak(40xboI0687dk6Xg87tZ1AaJEkq4Z5QAYGFFAUwNTaRp3CTodBnozKLLyftSGT4thlyil)M)SKaUybf9S05iLLv0FDelQjyzHVcfl3ZIJzr7pXIJzjcIXNQMybwSOjmMLFZlwIdl43daHzboSGmYc)SyzJkwIdWyb)EaimlesJUH4K9WFWcBCibmLqId6r)HGYyl(0H2qIGMYVpOOhRKYO9Akz1FbGUcLcR8WFWY4GE0FiOm2IpDzqVZrrMRYn9HA7ttbHVXb9O)qqzSfF6YGENJIm43dab44Oae(gh0J(dbLXw8Pld6DokYmuNFfgWXHtgzzjwMAdH3ybafewTBiwUglip2iXARalhMLHCWeOLLFJgIfFiw0egZYV5flOHL3hu0Jz5kwSMv5dlOFqFryIfl3VXYo8bqqllAcJz538IfLtIf4VrJLdtSCflELGf0pOVimXcCyzfXYdzbnS8(GIEmlQudoelolwZQ8Hf0pOVimzyjwal09SmuBi8glGR5kuSGm(kWHazb97IGwOPJQNLvPjmMLRyzhQ9Hf0pOVimXj7H)Gf24qcykHKoiSA3qOnKiOP87dk6XkPmAVMsd1gcV5QAsX7dk6n)1r5hMbpk(E9ug9awpCeP153hu0Jn43N2neWdiGxD1AgkOVimL1RYhZkQFFGnuNFfUpYSNYa7DnvV5TCvUdclSHkxvtG9v0laHAqOLYe88vbZqoycfwboRd0uWCaeROhcFoxvtMaSqabIYGeorfstdqOgeAPmbyHaceL)nkJJU5ESzihmrAQvbicQ86n1HA7ZnN6NMIJiTo)(GIESb)(0UHaCVEamaCp1vRzOG(IWuwVkFmRiGhq97d89ugyVRP6nVLRYDqyHnu5QAcSFFfwrb9fHjdgQ9jxes)00EuqFryYCvgd1(KM2Jc6lctMRYQWFlnLc6lctMRY6v5tFfw9UMQ3GHlDg2Y)gLBWHWVHkxvtGPPQRwZenxhCapxN9j41fYrln2hdcxVO4vcqOjP(k6HJiTo)(GIESb)(0UHaSYjb89ugyVRP6nVLRYDqyHnu5QAcSFFfo(hxNJGwOjE0KeawD1Ag87tZ1AZqD(vyGhG1xrpRuxTMbORahcmtDrql00r1NPIguxmjZkknLc6lctMRYyO2N0uRcqeu51BakXCE1xHvQRwZmocQGlCUnufZez8vTLoVLa)0CUzfXjJSSeRyIfaeyCzbwSeazXY9BW1ZsWJIUcfNSh(dwyJdjGPesAWjqzylx(VgcTxtjpkh2OaqCYE4pyHnoKaMsibHpNRQj0wEhPuamhGf49hSYoKqlcxViLScCwhOPG5aiwbcFoxvtMayoalW7pyPOxp1vRzWVpnxRnRO0031u9g8tATpzW5AVHkxvtGPPbicQ86n1HA7ZnN6RONvQRwZGHA8FbYSIuyL6Q1mbpFvWSIu0ZQ31u9M2AsKHTmPxfzOYv1eyAQ6Q1mbpFvWaUg)pyfFac1GqlLPTMezylt6vrMH68RWadG0xbcFoxvtMFBoToJjciAYw87v0ZQaebvE9M6qT95MtPPbiudcTuMaSqabIY)gLXr3Cp2SIu0tD1Ag87tZ1AZqD(vyadO0uRExt1BWpP1(KbNR9gQCvnb2VVI3hu0B(RJYpmdEu8QRwZe88vbd4A8)GfWNKbG3pnvfIXkAhQTppuNFfgWQRwZe88vbd4A8)GvFozKLLyftSG8yJeRTcSalwcGSSknHXS4fil6RiwUNLvelwUFJfKdleqGiozp8hSWghsatjKeinH)Z1zxFOQoQE0EnLq4Z5QAYeaZbybE)bRSdjozp8hSWghsatjKCvWNY)dwO9AkHWNZv1KjaMdWc8(dwzhsCYillXkMyb97IGwOHLyalqwGflbqwSC)gl7VpnxRzzfXIxGSGDeeln4WcaDPX(WIxGSG8yJeRTcCYE4pyHnoKaMsiH6IGwOjRclq0EnLU6PjcQ9NaZTd12NhQZVcdyLrtAAp1vRzIMRdoGNRZ(e86c5OLg7JbHRxeGbeAsknvD1AMO56Gd456SpbVUqoAPX(yq46ffVsacnj1xH6Q1m43NMR1MvKIEbiudcTuMGNVkygQZVchpAsknfCwhOPG5aiUpNmYYsSm1gcVXst7dXcSyzfXYdzjoS8(GIEmlwUFdUEwqESrI1wbwuPRqXIRcxplpKfcPr3qS4filf8zbIGMGhfDfkozp8hSWghsatjKGFsR9j30(qOnKiOP87dk6XkPmAVMsd1gcV5QAsXFDu(HzWJIxz0OahrAD(9bf9yd(9PDdby0tHhLdBuaif9uxTMj45RcMH68RWXRCsPPwPUAntWZxfmRO(CYillXkMybabI(SCnwUcFGelEXc6h0xeMyXlqw0xrSCplRiwSC)glola0Lg7dlrdmWIxGSeBqp6peel7w8PJt2d)blSXHeWucjT1KidBzsVkcTxtjkOVimzUk7vcfEuoSrbGuOUAnt0CDWb8CD2NGxxihT0yFmiC9IamGqtsk6bcFJd6r)HGYyl(0Lb9ohfz(la0vOstTkarqLxVPOWa1WbmnfhrAD(9bf944buFf9uxTMzCeubx4CBOkMjmd15xHbmWba3dna)SkQbhuKbFvBPZBjWpnN3xH6Q1mJJGk4cNBdvXmHzfLMAL6Q1mJJGk4cNBdvXmHzf1xrpRcqOgeAPmbpFvWSIstvxTM53MtRZyIaIgd(9aqawz0OODO2(8qD(vyadOKssr7qT95H68RWXRCsjLMAfgU0QxbA(T506mMiGOXqLRQjW(k6HHlT6vGMFBoToJjciAmu5QAcmnnaHAqOLYe88vbZqD(v44Jts95KrwwIvmXIZY(7tZ1Awaqx0VXs0adSSknHXSS)(0CTMLdZIRhYbtWYkIf4Wsc4IfFiwCv46z5HSarqtWJyj2yakNSh(dwyJdjGPesWVpnxRr71usD1Agyr)gohrtGI(dwMvKIEQRwZGFFAUwBgQneEZv1uAQJ)X15iOfAIh4KuFozKLLyXQlILyJbOSOsn4qSGCyHaceXIL73yz)9P5AnlEbYYVrfl7Vp41GI4K9WFWcBCibmLqc(9P5AnAVMsbicQ86n1HA7ZnNuy17AQEd(jT2Nm4CT3qLRQjqf9q4Z5QAYeGfciqugKWjQqAAac1GqlLj45RcMvuAQ6Q1mbpFvWSI6RiaHAqOLYeGfciqu(3Omo6M7XMH68RWagva005if4d0P754FCDocAHgKjAsQVc1vRzWVpnxRnd15xHbm6PWkWzDGMcMdGyozp8hSWghsatjKGFFWRbfH2RPuaIGkVEtDO2(CZjf9q4Z5QAYeGfciqugKWjQqAAac1GqlLj45RcMvuAQ6Q1mbpFvWSI6RiaHAqOLYeGfciqu(3Omo6M7XMH68RWagGPqD1Ag87tZ1AZksbf0xeMmxL9kHcRq4Z5QAYCOk4qz87dEnOifwboRd0uWCaeZjJSSeRyIL93h8AqrSy5(nw8Ifa0f9BSenWalWHLRXsc4cDGSarqtWJyj2yaklwUFJLeW1Wsri9zj443WsS1yilGRUiwIngGYI)S8BelubYcSXYVrSelLQFlXWI6Q1y5ASS)(0CTMflWLgSq3ZsZ1AwGTglWHLeWfl(qSalwaelVpOOhZj7H)Gf24qcykHe87dEnOi0EnLuxTMbw0VHZbn5tgXHpyzwrPP9Sc)(0UHmEuoSrbGuyfcFoxvtMdvbhkJFFWRbfLM2tD1AMGNVkygQZVcdy0OqD1AMGNVkywrPP96PUAntWZxfmd15xHbmQaOPZrkWhOt3ZX)46Ce0cniZ4KuFfQRwZe88vbZkknvD1AMXrqfCHZTHQyMiJVQT05Te4NMZnd15xHbmQaOPZrkWhOt3ZX)46Ce0cniZ4KuFfQRwZmocQGlCUnufZez8vTLoVLa)0CUzf1xraIGkVEdcQ(Tet)(k6HJiTo)(GIESb)(0CTgWXjnfHpNRQjd(9P5AD2cS(CZ16mS163xHvi85CvnzoufCOm(9bVguKIEwnRIAWbfz(RJSaNkdoK3PEfinPP4isRZVpOOhBWVpnxRbCC6ZjJSSeRyIfauqyHz5kw2HAFyb9d6lctS4filyhbXcaYsRzbafewS0Gdlip2iXARaNSh(dwyJdjGPeskYsUdcl0EnL6PUAndf0xeMYyO2hZqD(v44jKsH1t5)6O00EHnFqryLaKIHcB(GIY)1ragn9ttdB(GIWkfN(k8OCyJcaXj7H)Gf24qcykHKnx3YDqyH2RPup1vRzOG(IWugd1(ygQZVchpHukSEk)xhLM2lS5dkcReGumuyZhuu(VocWOPFAAyZhuewP40xHhLdBuaif9uxTMzCeubx4CBOkMjmd15xHbmAuOUAnZ4iOcUW52qvmtywrkSAwf1GdkYGVQT05Te4NMZttTsD1AMXrqfCHZTHQyMWSI6Zj7H)Gf24qcykHK2sRZDqyH2RPup1vRzOG(IWugd1(ygQZVchpHukSEk)xhPOxac1GqlLj45RcMH68RWXJMKstdqOgeAPmbyHaceL)nkJJU5ESzOo)kC8OjP(PP9cB(GIWkbifdf28bfL)RJamA6NMg28bfHvko9v4r5Wgfasrp1vRzghbvWfo3gQIzcZqD(vyaJgfQRwZmocQGlCUnufZeMvKcRMvrn4GIm4RAlDElb(P580uRuxTMzCeubx4CBOkMjmRO(CYillXkMybzaI(SalwqESGt2d)blSXHeWucjw8zo4KHTmPxfXjJSSGCxhwA)jmlw2OFJgwEillmXY(7t7gILRyzhQ9HflBxyJLdZI)SGgwEFqrpgykZsdoSqiOjblakjKjlDo(PjblWHf0JL93h8AqrSG(Drql00r1Zc(9aqyozp8hSWghsatjKGWNZv1eAlVJuc)(0UHYxLXqTpOfHRxKs4isRZVpOOhBWVpTBO4rpG10q40RZXpnjYiC9IaELtkjKjGsQpWAAiC6PUAnd(9bVguuM6IGwOPJQpJHAFm43daHmrV(CYilli31HL2FcZILn63OHLhYcYW4)glGR5kuSaGmufZeCYE4pyHnoKaMsibHpNRQj0wEhPKLX)T8v52qvmtGweUErkPmYehrADEZXpbyabG7LKbqaFpCeP153hu0Jn43N2neaw5(aFpLb27AQEdgU0zyl)BuUbhc)gQCvnbc8kBqt)(aljJYOb4vxTMzCeubx4CBOkMjmd15xH5KrwwIvmXcYW4)glxXYou7dlOFqFryIf4WY1yPGSS)(0UHyXYP1S0UNLREilip2iXARalELOdoeNSh(dwyJdjGPesSm(VH2RPupkOVimz0RYNCri9ttPG(IWKXRe5Iq6RaHpNRQjZHZbn5iO(k69(GIEZFDu(HzWJIh9stPG(IWKrVkFYxLbuAA7qT95H68RWaw5K6NMQUAndf0xeMYyO2hZqD(vya7H)GLb)(0UHmesPW6P8FDKc1vRzOG(IWugd1(ywrPPuqFryYCvgd1(OWke(CUQMm43N2nu(QmgQ9jnvD1AMGNVkygQZVcdyp8hSm43N2nKHqkfwpL)RJuyfcFoxvtMdNdAYrqkuxTMj45RcMH68RWaMqkfwpL)RJuOUAntWZxfmRO0u1vRzghbvWfo3gQIzcZksbcFoxvtglJ)B5RYTHQyMin1ke(CUQMmhoh0KJGuOUAntWZxfmd15xHJNqkfwpL)RJ4KrwwIvmXY(7t7gILRXYvSynRYhwq)G(IWeAz5kw2HAFyb9d6lctSalwqpGXY7dk6XSahwEilrdmWYou7dlOFqFryIt2d)blSXHeWucj43N2neNmYYcaIR1)2S4K9WFWcBCibmLqYSQSh(dwz9HF0wEhPuZ16FBwCYCYillaidvXmblwUFJfKhBKyTvGt2d)blSrf6VsJJGk4cNBdvXmbAVMsQRwZe88vbZqD(v44vgnCYillXkMyj2GE0Fiiw2T4thlw2OIf)zrtyml)MxSGESedySTol43daHzXlqwEild1gcVXIZcGvcqSGFpaeloMfT)eloMLiigFQAIf4WYFDel3ZcgYY9S4ZCiimliJSWplE7PHfNL4amwWVhaIfcPr3qyozp8hSWgvO)atjK4GE0FiOm2IpDOnKiOP87dk6XkPmAVMsQRwZO6AVcug2YUwN)TRqHZL)RHm43dabyaIc1vRzuDTxbkdBzxRZ)2vOWzFcErg87bGamarrpRaHVXb9O)qqzSfF6YGENJIm)fa6kukSYd)blJd6r)HGYyl(0Lb9ohfzUk30hQTxrpRaHVXb9O)qqzSfF6YBKRn)fa6kuPPGW34GE0FiOm2IpD5nY1MH68RWXhN(PPGW34GE0FiOm2IpDzqVZrrg87bGaCCuacFJd6r)HGYyl(0Lb9ohfzgQZVcdy0Oae(gh0J(dbLXw8Pld6DokY8xaORq1NtgzzjwXelihwiGarSy5(nwqESrI1wbwSSrflrqm(u1elEbYc83OXYHjwSC)glolXagBRZI6Q1yXYgvSas4ev4kuCYE4pyHnQq)bMsijaleqGO8VrzC0n3Jr71uYkWzDGMcMdGyf96HWNZv1KjaleqGOmiHtubfwfGqni0szcE(QGzihmrAQ6Q1mbpFvWSI6RON6Q1mQU2RaLHTSR15F7ku4C5)Aid(9aqkbqstvxTMr11EfOmSLDTo)BxHcN9j4fzWVhasjas)0uvigRODO2(8qD(vyaRCs95KrwwaqGOploMLFJyPDd(zbvaKLRy53iwCwIbm2wNflxbcTWcCyXY9BS8BeliJtmNxSOUAnwGdlwUFJfNfacWWuGLyd6r)HGyz3IpDS4filw87zPbhwqESrI1wbwUgl3ZIfy9SOsSSIyXr5xXIk1GdXYVrSeaz5WS0U6WBeiNSh(dwyJk0FGPesARjrg2YKEveAVMs961tD1Agvx7vGYWw2168VDfkCU8FnKb)EaO4byPPQRwZO6AVcug2YUwN)TRqHZ(e8Im43dafpaRVIEwfGiOYR3GGQFlXKMAL6Q1mJJGk4cNBdvXmHzf1VVIEGZ6anfmhaXPPbiudcTuMGNVkygQZVchpAsknTxaIGkVEtDO2(CZjfbiudcTuMaSqabIY)gLXr3Cp2muNFfoE0Ku)(9tt7bcFJd6r)HGYyl(0Lb9ohfzgQZVchparrac1GqlLj45RcMH68RWXRCskcqeu51BkkmqnCa7NME1tteu7pbMBhQTppuNFfgWaefwfGqni0szcE(QGzihmrAAaIGkVEdqjMZlfQRwZa0vGdbMPUiOfA6O6nRO00aebvE9geu9BjgfQRwZmocQGlCUnufZeMH68RWag4OqD1AMXrqfCHZTHQyMWSI4KrwwqUxbsZY(7JgoGSy5(nwCwkYclXagBRZI6Q1yXlqwqESrI1wbwoCHUNfxfUEwEilQellmbYj7H)Gf2Oc9hykHKGxbsNvxTgAlVJuc)(OHdiAVMs9uxTMr11EfOmSLDTo)BxHcNl)xdzgQZVchpa3GM0u1vRzuDTxbkdBzxRZ)2vOWzFcErMH68RWXdWnOPVIEbiudcTuMGNVkygQZVchpapnTxac1GqlLH6IGwOjRclqZqD(v44b4kSsD1AgGUcCiWm1fbTqthvFMkAqDXKmRifbicQ86naLyoV63xHJ)X15iOfAIxP4KeNmYYsSy1fXY(7dEnOimlwUFJfNLyaJT1zrD1ASOUEwk4ZILnQyjcc1xHILgCyb5XgjwBfyboSGm(kWHazzp6M7XCYE4pyHnQq)bMsib)(GxdkcTxtPEQRwZO6AVcug2YUwN)TRqHZL)RHm43dafpGstvxTMr11EfOmSLDTo)BxHcN9j4fzWVhakEa1xrVaebvE9M6qT95MtPPbiudcTuMGNVkygQZVchpapn1ke(CUQMmbWCawG3FWsHvbicQ86naLyoVst7fGqni0szOUiOfAYQWc0muNFfoEaUcRuxTMbORahcmtDrql00r1NPIguxmjZksraIGkVEdqjMZR(9v0Zkq4BARjrg2YKEvK5VaqxHkn1QaeQbHwktWZxfmd5GjstTkaHAqOLYeGfciqu(3Omo6M7XMHCWe95KrwwIfRUiw2FFWRbfHzrLAWHyb5WcbeiIt2d)blSrf6pWucj43h8AqrO9Ak1laHAqOLYeGfciqu(3Omo6M7XMH68RWagnkScCwhOPG5aiwrpe(CUQMmbyHaceLbjCIkKMgGqni0szcE(QGzOo)kmGrtFfi85CvnzcG5aSaV)GvFfwbcFtBnjYWwM0RIm)fa6kukcqeu51BQd12NBoPWkWzDGMcMdGyfuqFryYCv2RekC8pUohbTqt8OxsCYillXcyHUNfq4Zc4AUcfl)gXcvGSaBSel7iOcUWSaGmufZeOLfW1Cfkwa6kWHazH6IGwOPJQNf4WYvS8BelAh)SGkaYcSXIxSG(b9fHjozp8hSWgvO)atjKGWNZv1eAlVJuce(5HaaRBOoQEmAr46fPup1vRzghbvWfo3gQIzcZqD(v44rtAQvQRwZmocQGlCUnufZeMvuFf9uxTMbORahcmtDrql00r1NPIguxmjZqD(vyaJkaA6CK2xrp1vRzOG(IWugd1(ygQZVchpQaOPZrAAQ6Q1muqFrykRxLpMH68RWXJkaA6CK2Nt2d)blSrf6pWucj4v1UHqBirqt53hu0Jvsz0EnLgQneEZv1KI3hu0B(RJYpmdEu8kdWu4r5WgfasbcFoxvtgq4NhcaSUH6O6XCYE4pyHnQq)bMsiPdcR2neAdjcAk)(GIESskJ2RP0qTHWBUQMu8(GIEZFDu(HzWJIx54yqJcpkh2Oaqkq4Z5QAYac)8qaG1nuhvpMt2d)blSrf6pWucj4N0AFYnTpeAdjcAk)(GIESskJ2RP0qTHWBUQMu8(GIEZFDu(HzWJIxzagWgQZVcRWJYHnkaKce(CUQMmGWppeayDd1r1J5KrwwaqGXLfyXsaKfl3Vbxplbpk6kuCYE4pyHnQq)bMsiPbNaLHTC5)Ai0EnL8OCyJcaXjJSSG(Drql0WsmGfilw2OIfxfUEwEilu90WIZsrwyjgWyBDwSCfi0clEbYc2rqS0Gdlip2iXARaNSh(dwyJk0FGPesOUiOfAYQWceTxtPEuqFryYOxLp5Iq6NMsb9fHjdgQ9jxes)0ukOVimz8krUiK(PPQRwZO6AVcug2YUwN)TRqHZL)RHmd15xHJhGBqtAQ6Q1mQU2RaLHTSR15F7ku4SpbViZqD(v44b4g0KM64FCDocAHM4bojPiaHAqOLYe88vbZqoycfwboRd0uWCae3xrVaeQbHwktWZxfmd15xHJpojLMgGqni0szcE(QGzihmr)00REAIGA)jWC7qT95H68RWaw5K4KrwwaqGOplZHA7zrLAWHyzHVcflip2CYE4pyHnQq)bMsiPTMezylt6vrO9AkfGqni0szcE(QGzihmHce(CUQMmbWCawG3FWsrph)JRZrql0epWjjfwfGiOYR3uhQTp3CknnarqLxVPouBFU5Kch)JRZrql0ay0lP(kSkarqLxVbbv)wIrrpRcqeu51BQd12NBoLMgGqni0szcWcbeik)BughDZ9yZqoyI(kScCwhOPG5aiMtgzzb5XgjwBfyXYgvS4plaNKaglXgdqzPhC0ql0WYV5flOxsSeBmaLfl3VXcYHfciquFwSC)gC9SOH4RqXYFDelxXsm0qiOEHFw8cKf9velRiwSC)glihwiGarSCnwUNfloMfqcNOceiNSh(dwyJk0FGPesq4Z5QAcTL3rkfaZbybE)bRSk0F0IW1lsjRaN1bAkyoaIvGWNZv1KjaMdWc8(dwk61ZX)46Ce0cnXdCssrp1vRza6kWHaZuxe0cnDu9zQOb1ftYSIstTkarqLxVbOeZ5v)0u1vRzu1qiOEHFZksH6Q1mQAieuVWVzOo)kmGvxTMj45RcgW14)bR(PPx90eb1(tG52HA7Zd15xHbS6Q1mbpFvWaUg)pyLMgGiOYR3uhQTp3CQVIEwfGiOYR3uhQTp3CknTNJ)X15iOfAam6LuAki8nT1KidBzsVkY8xaORq1xrpe(CUQMmbyHaceLbjCIkKMgGqni0szcWcbeik)BughDZ9yZqoyI(95K9WFWcBuH(dmLqsG0e(pxND9HQ6O6r71ucHpNRQjtamhGf49hSYQq)5K9WFWcBuH(dmLqYvbFk)pyH2RPecFoxvtMayoalW7pyLvH(ZjJSSG(4)68NWSSbTWs3kSXsSXauw8HybLFfbYsenSGPaSa5K9WFWcBuH(dmLqccFoxvtOT8osjhhbqPzNcOfHRxKsuqFryYCvwVkFaEacY0d)bld(9PDdziKsH1t5)6iGzff0xeMmxL1RYhGVhadyVRP6ny4sNHT8Vr5gCi8BOYv1eiWhN(itp8hSmwg)3mesPW6P8FDeWsYaiKjoI068MJFItgzzjwS6Iyz)9bVgueMflBuXYVrS0ouBplhMfxfUEwEilubIwwAdvXmblhMfxfUEwEilubIwwsaxS4dXI)SaCscySeBmaLLRyXlwq)G(IWeAzb5XgjwBfyr74hZIxWFJgwaiadtbmlWHLeWflwGlnilqe0e8iw6GdXYV5flCQYjXsSXauwSSrfljGlwSaxAWcDpl7Vp41GIyPGw4K9WFWcBuH(dmLqc(9bVgueAVMs9U6PjcQ9NaZTd12NhQZVcdy0lnTN6Q1mJJGk4cNBdvXmHzOo)kmGrfanDosb(aD6Eo(hxNJGwObzgNK6RqD1AMXrqfCHZTHQyMWSI63pnTNJ)X15iOfAagcFoxvtghhbqPzNcaV6Q1muqFrykJHAFmd15xHbgi8nT1KidBzsVkY8xaiCEOo)kGhqg0eVYkNuAQJ)X15iOfAagcFoxvtghhbqPzNcaV6Q1muqFrykRxLpMH68RWade(M2AsKHTmPxfz(laeopuNFfWdidAIxzLtQVckOVimzUk7vcf9SsD1AMGNVkywrPPw9UMQ3GFF0Wb0qLRQjW(k61ZQaeQbHwktWZxfmRO00aebvE9gGsmNxkSkaHAqOLYqDrql0KvHfOzf1pnnarqLxVPouBFU5uFf9SkarqLxVbbv)wIjn1k1vRzcE(QGzfLM64FCDocAHM4boj1pnT37AQEd(9rdhqdvUQMavOUAntWZxfmRif9uxTMb)(OHdOb)EaiahN0uh)JRZrql0epWjP(9ttvxTMj45RcMvKcRuxTMzCeubx4CBOkMjmRifw9UMQ3GFF0Wb0qLRQjqozKLLyftSaGcclmlxXI1SkFyb9d6lctS4filyhbXsSKUUbmaKLwZcakiSyPbhwqESrI1wbozp8hSWgvO)atjKuKLChewO9Ak1tD1AgkOVimL1RYhZqD(v44jKsH1t5)6O00EHnFqryLaKIHcB(GIY)1ragn9ttdB(GIWkfN(k8OCyJcaXj7H)Gf2Oc9hykHKnx3YDqyH2RPup1vRzOG(IWuwVkFmd15xHJNqkfwpL)RJu0laHAqOLYe88vbZqD(v44rtsPPbiudcTuMaSqabIY)gLXr3Cp2muNFfoE0Ku)00EHnFqryLaKIHcB(GIY)1ragn9ttdB(GIWkfN(k8OCyJcaXj7H)Gf2Oc9hykHK2sRZDqyH2RPup1vRzOG(IWuwVkFmd15xHJNqkfwpL)RJu0laHAqOLYe88vbZqD(v44rtsPPbiudcTuMaSqabIY)gLXr3Cp2muNFfoE0Ku)00EHnFqryLaKIHcB(GIY)1ragn9ttdB(GIWkfN(k8OCyJcaXjJSSGmarFwGflbqozp8hSWgvO)atjKyXN5Gtg2YKEveNmYYsSIjw2FFA3qS8qwIgyGLDO2hwq)G(IWelWHflBuXYvSalDcwSMv5dlOFqFryIfVazzHjwqgGOplrdmGz5ASCflwZQ8Hf0pOVimXj7H)Gf2Oc9hykHe87t7gcTxtjkOVimzUkRxLpPPuqFryYGHAFYfH0pnLc6lctgVsKlcPFAQ6Q1mw8zo4KHTmPxfzwrkuxTMHc6lctz9Q8XSIst7PUAntWZxfmd15xHbSh(dwglJ)BgcPuy9u(VosH6Q1mbpFvWSI6Zj7H)Gf2Oc9hykHelJ)BCYE4pyHnQq)bMsizwv2d)bRS(WpAlVJuQ5A9VnlozozKLL93h8AqrS0GdlDqeuhvplRstymll8vOyjgWyBDozp8hSWMMR1)2Suc)(GxdkcTxtjRMvrn4GImQU2RaLHTSR15F7kuydbawxuebYjJSSGCh)S8BelGWNfl3VXYVrS0bXpl)1rS8qwCqqww1FAw(nILohPSaUg)pyXYHzz7Edl7RQDdXYqD(vyw6w6)I0hbYYdzPZ)WglDqy1UHybCn(FWIt2d)blSP5A9VnlGPesWRQDdH2qIGMYVpOOhRKYO9AkbcFthewTBiZqD(v44hQZVcd8acqitLbiCYE4pyHnnxR)TzbmLqshewTBiozozKLLyftSS)(GxdkILhYcqefXYkILFJyjwmK3PEfinSOUAnwUgl3ZIf4sdYcH0OBiwuPgCiwAxD4TRqXYVrSuesFwco(zboS8qwaxDrSOsn4qSGCyHaceXj7H)Gf2GFLWVp41GIq71uAwf1GdkY8xhzbovgCiVt9kqAu0Jc6lctMRYELqHv96PUAnZFDKf4uzWH8o1RaPXmuNFfoEp8hSmwg)3mesPW6P8FDeWsYOSIEuqFryYCvwf(BPPuqFryYCvgd1(KMsb9fHjJEv(KlcPF)0u1vRz(RJSaNkdoK3PEfinMH68RWX7H)GLb)(0UHmesPW6P8FDeWsYOSIEuqFryYCvwVkFstPG(IWKbd1(KlcPFAkf0xeMmELixes)(9ttTsD1AM)6ilWPYGd5DQxbsJzf1pnTN6Q1mbpFvWSIstr4Z5QAYeGfciqugKWjQqFfbiudcTuMaSqabIY)gLXr3Cp2mKdMqraIGkVEtDO2(CZP(k6zvaIGkVEdqjMZR00aeQbHwkd1fbTqtwfwGMH68RWXdq6RON6Q1mbpFvWSIstTkaHAqOLYe88vbZqoyI(CYillXkMyj2GE0Fiiw2T4thlw2OILFJgILdZsbzXd)HGybBXNo0YIJzr7pXIJzjcIXNQMybwSGT4thlwUFJfaXcCyPrwOHf87bGWSahwGflolXbySGT4thlyil)M)S8BelfzHfSfF6yXN5qqywqgzHFw82tdl)M)SGT4thlesJUHWCYE4pyHn4hykHeh0J(dbLXw8PdTHebnLFFqrpwjLr71uYkq4BCqp6peugBXNUmO35OiZFbGUcLcR8WFWY4GE0FiOm2IpDzqVZrrMRYn9HA7v0Zkq4BCqp6peugBXNU8g5AZFbGUcvAki8noOh9hckJT4txEJCTzOo)kC8OPFAki8noOh9hckJT4txg07CuKb)EaiahhfGW34GE0FiOm2IpDzqVZrrMH68RWaookaHVXb9O)qqzSfF6YGENJIm)fa6kuCYillXkMWSGCyHaceXY1yb5XgjwBfy5WSSIyboSKaUyXhIfqcNOcxHIfKhBKyTvGfl3VXcYHfciqelEbYsc4IfFiwujn0clOxsSeBmaLt2d)blSb)atjKeGfciqu(3Omo6M7XO9Akzf4SoqtbZbqSIE9q4Z5QAYeGfciqugKWjQGcRcqOgeAPmbpFvWmKdMqHvZQOgCqrMO56Gd456SpbVUqoAPX(KMQUAntWZxfmRO(kC8pUohbTqdGvc9ssrp1vRzOG(IWuwVkFmd15xHJx5KstvxTMHc6lctzmu7JzOo)kC8kNu)0uvigRODO2(8qD(vyaRCskSkaHAqOLYe88vbZqoyI(CYillihwG3FWILgCyX1AwaHpMLFZFw6CGiml41qS8Bucw8Hk09SmuBi8gbYILnQyjw2rqfCHzbazOkMjyzZXSOjmMLFZlwqdlykGzzOo)QRqXcCy53iwakXCEXI6Q1y5WS4QW1ZYdzP5AnlWwJf4WIxjyb9d6lctSCywCv46z5HSqin6gIt2d)blSb)atjKGWNZv1eAlVJuce(5HaaRBOoQEmAr46fPup1vRzghbvWfo3gQIzcZqD(v44rtAQvQRwZmocQGlCUnufZeMvuFfwPUAnZ4iOcUW52qvmtKXx1w68wc8tZ5MvKIEQRwZa0vGdbMPUiOfA6O6ZurdQlMKzOo)kmGrfanDos7RON6Q1muqFrykJHAFmd15xHJhva005innvD1AgkOVimL1RYhZqD(v44rfanDostt7zL6Q1muqFrykRxLpMvuAQvQRwZqb9fHPmgQ9XSI6RWQ31u9gmuJ)lqgQCvnb2Ntgzzb5Wc8(dwS8B(ZsyJcaHz5ASKaUyXhIf46XhiXcf0xeMy5HSalDcwaHpl)gnelWHLdvbhILF7WSy5(nw2HA8FbIt2d)blSb)atjKGWNZv1eAlVJuce(z46XhiLPG(IWeAr46fPupRuxTMHc6lctzmu7JzfPWk1vRzOG(IWuwVkFmRO(PPVRP6nyOg)xGmu5QAcKt2d)blSb)atjK0bHv7gcTHebnLFFqrpwjLr71uAO2q4nxvtk6PUAndf0xeMYyO2hZqD(v44hQZVcNMQUAndf0xeMY6v5JzOo)kC8d15xHttr4Z5QAYac)mC94dKYuqFryQVIHAdH3CvnP49bf9M)6O8dZGhfVYasHhLdBuaifi85CvnzaHFEiaW6gQJQhZj7H)Gf2GFGPesWRQDdH2qIGMYVpOOhRKYO9AknuBi8MRQjf9uxTMHc6lctzmu7JzOo)kC8d15xHttvxTMHc6lctz9Q8XmuNFfo(H68RWPPi85CvnzaHFgUE8bszkOVim1xXqTHWBUQMu8(GIEZFDu(HzWJIxzaPWJYHnkaKce(CUQMmGWppeayDd1r1J5K9WFWcBWpWucj4N0AFYnTpeAdjcAk)(GIESskJ2RP0qTHWBUQMu0tD1AgkOVimLXqTpMH68RWXpuNFfonvD1AgkOVimL1RYhZqD(v44hQZVcNMIWNZv1Kbe(z46XhiLPG(IWuFfd1gcV5QAsX7dk6n)1r5hMbpkELbyk8OCyJcaPaHpNRQjdi8Zdbaw3qDu9yozKLLyftSaGaJllWILailwUFdUEwcEu0vO4K9WFWcBWpWucjn4eOmSLl)xdH2RPKhLdBuaiozKLLyftSGm(kWHazzp6M7XSy5(nw8kblAyHIfQGluBSOD8Ffkwq)G(IWelEbYYpjy5HSOVIy5EwwrSy5(nwaOln2hw8cKfKhBKyTvGt2d)blSb)atjKqDrql0KvHfiAVMs96PUAndf0xeMYyO2hZqD(v44voP0u1vRzOG(IWuwVkFmd15xHJx5K6RiaHAqOLYe88vbZqD(v44Jtsk6PUAnt0CDWb8CD2NGxxihT0yFmiC9IamGqVKstTAwf1GdkYenxhCapxN9j41fYrln2hdbawxueb2VFAQ6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lkELaeapP00aeQbHwktWZxfmd5Gju44FCDocAHM4bojXjJSSeRyIfKhBKyTvGfl3VXcYHfciqesqgFf4qGSShDZ9yw8cKfqyHUNficASm3tSaqxASpSahwSSrflXqdHG6f(zXcCPbzHqA0nelQudoelip2iXARalesJUHWCYE4pyHn4hykHee(CUQMqB5DKsbWCawG3FWkJF0IW1lsjRaN1bAkyoaIvGWNZv1KjaMdWc8(dwk61laHAqOLYqDrjgY1z4awEfiZqD(vyaRmadGdSEkRmWpRIAWbfzWx1w68wc8tZ59vqaG1ffrGgQlkXqUodhWYRa1pn1X)46Ce0cnXReWjjf9S6DnvVPTMezylt6vrgQCvnbMMQUAntWZxfmGRX)dwXhGqni0szARjrg2YKEvKzOo)kmWai9vGWNZv1K53MtRZyIaIMSf)Ef9uxTMbORahcmtDrql00r1NPIguxmjZkkn1QaebvE9gGsmNx9v8(GIEZFDu(HzWJIxD1AMGNVkyaxJ)hSa(Kma80uvigRODO2(8qD(vyaRUAntWZxfmGRX)dwPPbicQ86n1HA7ZnNstvxTMrvdHG6f(nRifQRwZOQHqq9c)MH68RWawD1AMGNVkyaxJ)hSawpGdWpRIAWbfzIMRdoGNRZ(e86c5OLg7JHaaRlkIa73xHvQRwZe88vbZksrpRcqeu51BQd12NBoLMgGqni0szcWcbeik)BughDZ9yZkknvfIXkAhQTppuNFfgWbiudcTuMaSqabIY)gLXr3Cp2muNFfgyaS002HA7Zd15xHrMitLbijby1vRzcE(QGbCn(FWQpNmYYsSIjw(nILyPu9BjgwSC)glolip2iXARal)M)SC4cDplTb2XcaDPX(Wj7H)Gf2GFGPesghbvWfo3gQIzc0EnLuxTMj45RcMH68RWXRmAstvxTMj45RcgW14)blahNKuGWNZv1KjaMdWc8(dwz8Zj7H)Gf2GFGPescKMW)56SRpuvhvpAVMsi85CvnzcG5aSaV)Gvg)k6zL6Q1mbpFvWaUg)pyfFCskn1QaebvE9geu9BjM(PPQRwZmocQGlCUnufZeMvKc1vRzghbvWfo3gQIzcZqD(vyadCawawGR7nrdfomLD9HQ6O6n)1rzeUEraRNvQRwZOQHqq9c)MvKcRExt1BWVpA4aAOYv1eyFozp8hSWg8dmLqYvbFk)pyH2RPecFoxvtMayoalW7pyLXpNmYYsSuFoxvtSSWeilWIfx903FeMLFZFwS41ZYdzrLyb7iiqwAWHfKhBKyTvGfmKLFZFw(nkbl(q1ZIfh)eiliJSWplQudoel)g1Xj7H)Gf2GFGPesq4Z5QAcTL3rkHDeuUbNCWZxfqlcxViLSkaHAqOLYe88vbZqoyI0uRq4Z5QAYeGfciqugKWjQGIaebvE9M6qT95MtPPGZ6anfmhaXCYillXkMWSaGarFwUglxXIxSG(b9fHjw8cKLFocZYdzrFfXY9SSIyXY9BSaqxASpOLfKhBKyTvGfVazj2GE0Fiiw2T4thNSh(dwyd(bMsiPTMezylt6vrO9Akrb9fHjZvzVsOWJYHnkaKc1vRzIMRdoGNRZ(e86c5OLg7JbHRxeGbe6LKIEGW34GE0FiOm2IpDzqVZrrM)caDfQ0uRcqeu51BkkmqnCa7RaHpNRQjd2rq5gCYbpFvqrp1vRzghbvWfo3gQIzcZqD(vyadCaW9qdWpRIAWbfzWx1w68wc8tZ59vOUAnZ4iOcUW52qvmtywrPPwPUAnZ4iOcUW52qvmtywr95KrwwIvmXca6I(nw2FFAUwZs0adywUgl7VpnxRz5Wf6EwwrCYE4pyHn4hykHe87tZ1A0EnLuxTMbw0VHZr0eOO)GLzfPqD1Ag87tZ1AZqTHWBUQM4K9WFWcBWpWucjbVcKoRUAn0wEhPe(9rdhq0EnLuxTMb)(OHdOzOo)kmGrJIEQRwZqb9fHPmgQ9XmuNFfoE0KMQUAndf0xeMY6v5JzOo)kC8OPVch)JRZrql0epWjjozKLLyXQlcZsSXauwuPgCiwqoSqabIyzHVcfl)gXcYHfciqelbybE)blwEilHnkaelxJfKdleqGiwomlE4xUwNGfxfUEwEilQelbh)CYE4pyHn4hykHe87dEnOi0EnLcqeu51BQd12NBoPaHpNRQjtawiGarzqcNOckcqOgeAPmbyHaceL)nkJJU5ESzOo)kmGrJcRaN1bAkyoaIvqb9fHjZvzVsOWX)46Ce0cnXJEjXjJSSeRyIL93NMR1Sy5(nw2FsR9HLyXCTNfVazPGSS)(OHdiAzXYgvSuqw2FFAUwZYHzzfHwwsaxS4dXYvSynRYhwq)G(IWeln4WcabyykGzboS8qwIgyGfa6sJ9HflBuXIRcrqSaCsILyJbOSahwCWi)peelyl(0XYMJzbGammfWSmuNF1vOyboSCywUILM(qT9gwIl8jw(n)zzvG0WYVrSG9oILaSaV)GfML7rhMfWimlfT(X1S8qw2FFAUwZc4AUcflXYocQGlmlaidvXmbAzXYgvSKaUqhil4)0AwOcKLvelwUFJfGtsaZXrS0Gdl)gXI2XplO0qvxJnCYE4pyHn4hykHe87tZ1A0EnLExt1BWpP1(KbNR9gQCvnbQWQ31u9g87JgoGgQCvnbQqD1Ag87tZ1AZqTHWBUQMu0tD1AgkOVimL1RYhZqD(v44bikOG(IWK5QSEv(OqD1AMO56Gd456SpbVUqoAPX(yq46fbyaHMKstvxTMjAUo4aEUo7tWRlKJwASpgeUErXReGqtskC8pUohbTqt8aNKstbHVXb9O)qqzSfF6YGENJImd15xHJhGKM6H)GLXb9O)qqzSfF6YGENJImxLB6d123xrac1GqlLj45RcMH68RWXRCsCYillXkMyz)9bVguelaOl63yjAGbmlEbYc4QlILyJbOSyzJkwqESrI1wbwGdl)gXsSuQ(TedlQRwJLdZIRcxplpKLMR1SaBnwGdljGl0bYsWJyj2yakNSh(dwyd(bMsib)(GxdkcTxtj1vRzGf9B4Cqt(KrC4dwMvuAQ6Q1maDf4qGzQlcAHMoQ(mv0G6IjzwrPPQRwZe88vbZksrp1vRzghbvWfo3gQIzcZqD(vyaJkaA6CKc8b609C8pUohbTqdYmoj1hyXb4Fxt1BkYsUdcldvUQMavy1SkQbhuKbFvBPZBjWpnNRqD1AMXrqfCHZTHQyMWSIstvxTMj45RcMH68RWagva005if4d0P754FCDocAHgKzCsQFAQ6Q1mJJGk4cNBdvXmrgFvBPZBjWpnNBwrPP9uxTMzCeubx4CBOkMjmd15xHbSh(dwg87t7gYqiLcRNY)1rkWrKwN3C8taojd6LMQUAnZ4iOcUW52qvmtygQZVcdyp8hSmwg)3mesPW6P8FDuAkcFoxvtMdaaMdWc8(dwkcqOgeAPmxHdZ6DvnLbalV(vxgKqCbYmKdMqbbawxuebAUchM17QAkdawE9RUmiH4cuFfQRwZmocQGlCUnufZeMvuAQvQRwZmocQGlCUnufZeMvKcRcqOgeAPmJJGk4cNBdvXmHzihmrAQvbicQ86niO63sm9ttD8pUohbTqt8aNKuqb9fHjZvzVsWjJSSy9jblpKLohiILFJyrLWplWgl7VpA4aYIAcwWVha6kuSCplRiwaaRlaKoblxXIxjyb9d6lctSOUEwaOln2hwoC9S4QW1ZYdzrLyjAGHabYj7H)Gf2GFGPesWVp41GIq71u6DnvVb)(OHdOHkxvtGkSAwf1GdkY8xhzbovgCiVt9kqAu0tD1Ag87JgoGMvuAQJ)X15iOfAIh4KuFfQRwZGFF0Wb0GFpaeGJJIEQRwZqb9fHPmgQ9XSIstvxTMHc6lctz9Q8XSI6RqD1AMO56Gd456SpbVUqoAPX(yq46fbyabWtsrVaeQbHwktWZxfmd15xHJx5KstTcHpNRQjtawiGarzqcNOckcqeu51BQd12NBo1Ntgzzb9X)15pHzzdAHLUvyJLyJbOS4dXck)kcKLiAybtbybYj7H)Gf2GFGPesq4Z5QAcTL3rk54iakn7uaTiC9IuIc6lctMRY6v5dWdqqME4pyzWVpTBidHukSEk)xhbmROG(IWK5QSEv(a89aya7DnvVbdx6mSL)nk3GdHFdvUQMab(40hz6H)GLXY4)MHqkfwpL)RJawsg0dnitCeP15nh)eWsYGgG)DnvVP8FneoR6AVcKHkxvtGCYillXIvxel7Vp41GIy5kwCwa4adtbw2HAFyb9d6lctOLfqyHUNfn9SCplrdmWcaDPX(WsVFZFwomlBEbQjqwutWcD)gnS8Bel7VpnxRzrFfXcCy53iwIngGgpWjjw0xrS0Gdl7Vp41GI6JwwaHf6EwGiOXYCpXIxSaGUOFJLObgyXlqw00ZYVrS4Qqeel6Riw28cutSS)(OHdiNSh(dwyd(bMsib)(GxdkcTxtjRMvrn4GIm)1rwGtLbhY7uVcKgf9uxTMjAUo4aEUo7tWRlKJwASpgeUEragqa8KstvxTMjAUo4aEUo7tWRlKJwASpgeUEragqOjjfVRP6n4N0AFYGZ1EdvUQMa7ROhf0xeMmxLXqTpkC8pUohbTqdWq4Z5QAY44iakn7ua4vxTMHc6lctzmu7JzOo)kmWaHVPTMezylt6vrM)caHZd15xb8aYGM4bijLMsb9fHjZvz9Q8rHJ)X15iOfAagcFoxvtghhbqPzNcaV6Q1muqFrykRxLpMH68RWade(M2AsKHTmPxfz(laeopuNFfWdidAIh4KuFfwPUAndSOFdNJOjqr)blZksHvVRP6n43hnCanu5QAcurVaeQbHwktWZxfmd15xHJhGNMIHlT6vGMFBoToJjciAmu5QAcuH6Q1m)2CADgteq0yWVhacWXjoa4EZQOgCqrg8vTLoVLa)0CoWJM(kAhQTppuNFfoELtkjfTd12NhQZVcdyaLus9v0laHAqOLYa0vGdbMXr3Cp2muNFfoEaEAQvbicQ86naLyoV6ZjJSSeRyIfauqyHz5kwSMv5dlOFqFryIfVazb7iiwIL01nGbGS0AwaqbHfln4WcYJnsS2kWIxGSGm(kWHazb97IGwOPJQNt2d)blSb)atjKuKLChewO9Ak1tD1AgkOVimL1RYhZqD(v44jKsH1t5)6O00EHnFqryLaKIHcB(GIY)1ragn9ttdB(GIWkfN(k8OCyJcaPaHpNRQjd2rq5gCYbpFvGt2d)blSb)atjKS56wUdcl0EnL6PUAndf0xeMY6v5JzOo)kC8esPW6P8FDKcRcqeu51BakXCELM2tD1AgGUcCiWm1fbTqthvFMkAqDXKmRifbicQ86naLyoV6NM2lS5dkcReGumuyZhuu(VocWOPFAAyZhuewP4KMQUAntWZxfmRO(k8OCyJcaPaHpNRQjd2rq5gCYbpFvqrp1vRzghbvWfo3gQIzcZqD(vya3dnayab8ZQOgCqrg8vTLoVLa)0CEFfQRwZmocQGlCUnufZeMvuAQvQRwZmocQGlCUnufZeMvuFozp8hSWg8dmLqsBP15oiSq71uQN6Q1muqFrykRxLpMH68RWXtiLcRNY)1rkSkarqLxVbOeZ5vAAp1vRza6kWHaZuxe0cnDu9zQOb1ftYSIueGiOYR3auI58QFAAVWMpOiSsasXqHnFqr5)6iaJM(PPHnFqryLItAQ6Q1mbpFvWSI6RWJYHnkaKce(CUQMmyhbLBWjh88vbf9uxTMzCeubx4CBOkMjmd15xHbmAuOUAnZ4iOcUW52qvmtywrkSAwf1GdkYGVQT05Te4NMZttTsD1AMXrqfCHZTHQyMWSI6ZjJSSeRyIfKbi6ZcSyjaYj7H)Gf2GFGPesS4ZCWjdBzsVkItgzzjwXel7VpTBiwEilrdmWYou7dlOFqFrycTSG8yJeRTcSS5yw0egZYFDel)MxS4SGmm(VXcHukSEIfn1EwGdlWsNGfRzv(Wc6h0xeMy5WSSI4K9WFWcBWpWucj43N2neAVMsuqFryYCvwVkFstPG(IWKbd1(KlcPFAkf0xeMmELixes)00EQRwZyXN5Gtg2YKEvKzfLMIJiToV54NaCsg0dnkSkarqLxVbbv)wIjnfhrADEZXpb4KmONIaebvE9geu9BjM(kuxTMHc6lctz9Q8XSIst7PUAntWZxfmd15xHbSh(dwglJ)BgcPuy9u(VosH6Q1mbpFvWSI6ZjJSSeRyIfKHX)nwG)gnwomXILTlSXYHz5kw2HAFyb9d6lctOLfKhBKyTvGf4WYdzjAGbwSMv5dlOFqFryIt2d)blSb)atjKyz8FJtgzzbaX16FBwCYE4pyHn4hykHKzvzp8hSY6d)OT8osPMR1)2SSF732g]] )

end