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


    spec:RegisterPack( "Balance", 20210725.1, [[di1kQfqikPEeePUeejTjs4tqQmkPKtjLAvaQ6vakZcsPBbaAxu8liIHjICmsuldG8mHkMgKQCnikBdqfFdaLXbG4CqKyDaOAEau3JezFcv9pHcv0bfQ0cfk6HqkMOqHCriv1gbGYhbuP0ifkuPtsjrRue1lbuPAMus4MaqLDkuQFcavnuaKoQqHkSuHcLNQuMkLKUkaWwfku1xbujJfaYEPu)vudM4WuTys6XcMmqxgzZs1NHKrRuDAvwnGkfVgqMnPUTiTBj)g0WfYXfky5kEoutxvxxjBhcFNsmEiQoViSEHsMVuSFuBRSTvT3a9NSJnGscqkNeadqiZOmWjjag6HE2BFIiYElYda5Oi7TYtj7Ty6AVcK9wKNqdDqBRAVHHRjq2B7)hHb4ibjQU2RabaXxAWG6(9LQ5GijMU2Raba3Uu0GKuqZ(NQJXz)0KsQU2RazEK)2BQRt)wzzRAVb6pzhBaLeGuojagGqMrzGtsam0tz7nF97WXEB7srJ92(bcsLTQ9giHd2BX01EfiwIrZ6a5KtEPtWcGqgAzbqjbiL5K5KrZUxOimaNtgaYsCbbjqw2GAFyjMKNA4KbGSGMDVqrGS8(GI(81zj4ycZYdzjKiOP87dk6XgozailXyukebbYYQkkqySpjybHpNRQjmlTodzqllrdHiJFFWRbfXcamEwIgcHb)(GxdkQTHtgaYsCrapqwIgk44)kuSaCn(VZY1z5E0Hz53jwSmWcflOFqFryYWjdazbaNdeXcAGfciqel)oXYw0n3JzXzrF)RjwsHdXsxti)u1elTUoljGlw2DWcDpl73ZY9SGV0L(9IGlSoblwUFNLycGpUwLfGXcAinH)Z1Sex9HQsP6rll3JoqwWaDrTnCYaqwaW5arSKcXplORFO2)8qP(vy0XcoqLpheZIhfPtWYdzrfIXS0pu7pMfyPty4KbGSy1H8NfRctjwGDwIP23zjMAFNLyQ9DwCmlol4ikCUMLFUci6nCYaqwaWhrfnS06mKbTSaCn(VJwwaUg)3rllBVp9BO2SK6GelPWHyzi8PpQEwEilKp6JgwcWuv)bG43N3yVPp8JTTQ9gmIkASTQDSv22Q2Bu5QAc0oM2BE4pyzVzz8F3EdKWH5I(dw2Ba0Hco(zbqSaCn(VZIxGS4SS9(GxdkIfyXYMvzXY97Se7d1(ZcaMtS4filXegxRYcCyz79PFdXc83PXYHj7TWCpnNBV1IfkOVimz0RYNCri)zPPHfkOVimzUkJHAFyPPHfkOVimzUkRc)DwAAyHc6lctgVsKlc5plTzrblrdHWOSXY4)olkyXAwIgcHbqglJ)72VDSbKTvT3OYv1eODmT38WFWYEd)(0VHS3cZ90CU9M1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYstdlwZsaIGkVEtDO2)C3jwAAyXAwWrKwNFFqrp2GFF6UwZIsSOmlnnSynlVRP6nL)RHWzvx7vGmu5QAcKLMgwAXcf0xeMmyO2NCri)zPPHfkOVimzUkRxLpS00Wcf0xeMmxLvH)olnnSqb9fHjJxjYfH8NL22B6ROCa0Edz2VDSJJTvT3OYv1eODmT38WFWYEd)(GxdkYElm3tZ52BZQOoCqrgvx7vGYWE2168VFfkSHkxvtGSOGLaebvE9M6qT)5UtSOGfCeP153hu0Jn43NUR1SOelkBVPVIYbq7nKz)2V9gi19L(TTQDSv22Q2BE4pyzVHHAFYQKNAVrLRQjq7yA)2Xgq2w1EJkxvtG2X0Elm3tZ52B)LsSaywAXcGyb4zXd)blJLX)DtWXF(VuIfGXIh(dwg87t)gYeC8N)lLyPT9Mh(dw2BbxRZE4pyL1h(T30h(ZLNs2BWiQOX(TJDCSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEdhrAD(9bf9yd(9P7AnlXZIYSOGLwSynlVRP6n43hnCanu5QAcKLMgwExt1BWpP1(KbNR)gQCvnbYsBwAAybhrAD(9bf9yd(9P7AnlXZcGS3ajCyUO)GL92g9ywIle9zbwSehGXIL73HRNfW56plEbYIL73zz79rdhqw8cKfabmwG)onwomzVHWNC5PK92HZoKSF7yJE2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVHJiTo)(GIESb)(0VHyjEwu2EdKWH5I(dw2BB0JzjOjhbXILDQyz79PFdXsWlw2VNfabmwEFqrpMfl7xyNLdZYqAcHxplD4WYVtSG(b9fHjwEilQelrd1Pziqw8cKfl7xyNL(P10WYdzj443EdHp5Ytj7TdNdAYrq2VDSrMTvT3OYv1eODmT38WFWYEtLgmnaDfk7nqchMl6pyzVbaWelXKgmnaDfkwSC)olOjUiXkRalWHfV)0WcAGfciqelxXcAIlsSYkyVfM7P5C7TwS0IfRzjarqLxVPou7FU7elnnSynlbiudcTuMaSqabIY)oLXr3Cp2SIyPnlkyrD17MGNVkygk1VcZs8SOmYyrblQRE3mocQGlCUpufReMHs9RWSaywqpwuWI1SeGiOYR3GGQFpXWstdlbicQ86niO63tmSOGf1vVBcE(QGzfXIcwux9UzCeubx4CFOkwjmRiwuWslwux9UzCeubx4CFOkwjmdL6xHzbWSOSYSaazbzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYstdlQRE3e88vbZqP(vywamlkRmlnnSOmliHfCeP15Dh)elaMfLnidzS0ML2SOGfubqZqP(vywINLKSF7ydCSTQ9gvUQMaTJP9wyUNMZT3ux9Uj45RcMHs9RWSeplkJmwuWslwSMLzvuhoOid(Q(sN3tGFAo3qLRQjqwAAyrD17MXrqfCHZ9HQyLWmuQFfMfaZIYamwaGSaiwaEwux9UrvdHG6f(nRiwuWI6Q3nJJGk4cN7dvXkHzfXsBwAAyrfIXSOGL(HA)ZdL6xHzbWSaiKzVbs4WCr)bl7nak8zXY97S4SGM4IeRScS87(ZYHl09S4SaqxASpSenWalWHfl7uXYVtS0pu7plhMfxfUEwEilubAV5H)GL9we8pyz)2XgGzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9wGonlTyPfl9d1(Nhk1VcZcaKfLrglaqwcqOgeAPmbpFvWmuQFfML2SGewugGKelTzrjwc0PzPflTyPFO2)8qP(vywaGSOmYybaYsac1GqlLjaleqGO8VtzC0n3JnGRX)dwSaazjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWS0MfKWIYaKKyPnlkyXAwg)aZecQEJdcIneYp8JzPPHLaeQbHwktWZxfmdL6xHzjEwU6PjcQ9NaZ9d1(Nhk1VcZstdlbiudcTuMaSqabIY)oLXr3Cp2muQFfML4z5QNMiO2Fcm3pu7FEOu)kmlaqwuojwAAyXAwcqeu51BQd1(N7ozVbs4WCr)bl7n046Ws7pHzXYo970WYcFfkwqdSqabIyPGwyXYP1S4An0cljGlwEil4)0Awco(z53jwWEkXINcx1ZcSZcAGfciqeWqtCrIvwbwco(X2Bi8jxEkzVfGfciqugKWjQG9BhBaITvT3OYv1eODmT3Gr2By6T38WFWYEdHpNRQj7neUEr2BTyPFO2)8qP(vywINfLrglnnSm(bMjeu9gheeBUIL4zbzjXsBwuWslwAXslwOyyDrreOHsJsmKRZWbS8kqSOGLwSeGqni0szO0Oed56mCalVcKzOu)kmlaMfLbojXstdlbicQ86niO63tmSOGLaeQbHwkdLgLyixNHdy5vGmdL6xHzbWSOmWbGXcWyPflkRmlaplZQOoCqrg8v9LoVNa)0CUHkxvtGS0ML2SOGfRzjaHAqOLYqPrjgY1z4awEfiZqoycwAZstdlumSUOic0GHlTM()ku5zPMGffS0IfRzjarqLxVPou7FU7elnnSeGqni0szWWLwt)FfQ8SutKJd6HmasskBgk1VcZcGzrzLrpwAZstdlTyjaHAqOLYOsdMgGUcLzihmblnnSynlJhiZpqTML2SOGLwS0IfkgwxuebAUchM17QAkhdlV(vAgKqCbIffS0ILaeQbHwkZv4WSExvt5yy51VsZGeIlqMHCWeS00WIh(dwMRWHz9UQMYXWYRFLMbjexGmGh2v1eilTzPnlnnS0IfkgwxuebAW7oi0cbMHJAg2ZpCsP6zrblbiudcTuMhoPu9ey(k8HA)ZXbziloaszZqP(vywAZstdlTyPfli85CvnzGvEHP8pxbe9SOelkZstdli85CvnzGvEHP8pxbe9SOelXHL2SOGLwS8ZvarV5v2mKdMihGqni0sXstdl)Cfq0BELnbiudcTuMHs9RWSeplx90eb1(tG5(HA)ZdL6xHzbaYIYjXsBwAAybHpNRQjdSYlmL)5kGONfLybqSOGLwS8ZvarV5bKzihmroaHAqOLILMgw(5kGO38aYeGqni0szgk1VcZs8SC1tteu7pbM7hQ9ppuQFfMfailkNelTzPPHfe(CUQMmWkVWu(NRaIEwuILKyPnlTzPnlnnSeGiOYR3auI58IL2S00WIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSS3ajCyUO)GL9gaatGS8qwajTNGLFNyzHDuelWolOjUiXkRalw2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyzNkw8IfheKfcbvplhMfxfUEwEilGhzVHWNC5PK9wamhGf49hSSF7yJuSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZAwWWLw9kqZVpNwNXebengQCvnbYstdl9d1(Nhk1VcZs8SaOKsILMgwuHymlkyPFO2)8qP(vywamlaczSamwAXc6Lelaqwux9U53NtRZyIaIgd(9aqSa8SaiwAZstdlQRE387ZP1zmrarJb)EaiwINL4aqybaYslwMvrD4GIm4R6lDEpb(P5CdvUQMazb4zbzS02EdKWH5I(dw2BX495CvnXYctGS8qwajTNGfVsWYpxbe9yw8cKLaiMfl7uXIf)(RqXshoS4flO)kAhoNZs0ad2Bi8jxEkzV97ZP1zmrart2IFV9BhBLtY2Q2Bu5QAc0oM2BGeomx0FWYEdaGjwq)0Oed5AwaWpGLxbIfaLeMcywuPoCiwCwqtCrIvwbwwyYyVvEkzVrPrjgY1z4awEfi7TWCpnNBVfGqni0szcE(QGzOu)kmlaMfaLelkyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywausSOGLwSGWNZv1K53NtRZyIaIMSf)EwAAyrD17MFFoToJjciAm43daXs8SeNKybyS0ILzvuhoOid(Q(sN3tGFAo3qLRQjqwaEwaoS0ML2SOGfubqZqP(vywINLKyPPHfvigZIcw6hQ9ppuQFfMfaZsCay2BE4pyzVrPrjgY1z4awEfi73o2kRSTvT3OYv1eODmT3ajCyUO)GL9gaatSSbxAn9xHILySLAcwaoykGzrL6WHyXzbnXfjwzfyzHjJ9w5PK9ggU0A6)RqLNLAc7TWCpnNBV1ILaeQbHwktWZxfmdL6xHzbWSaCyrblwZsaIGkVEdcQ(9edlkyXAwcqeu51BQd1(N7oXstdlbicQ86n1HA)ZDNyrblbiudcTuMaSqabIY)oLXr3Cp2muQFfMfaZcWHffS0Ife(CUQMmbyHaceLbjCIkWstdlbiudcTuMGNVkygk1VcZcGzb4WsBwAAyjarqLxVbbv)EIHffS0IfRzzwf1HdkYGVQV059e4NMZnu5QAcKffSeGqni0szcE(QGzOu)kmlaMfGdlnnSOU6DZ4iOcUW5(qvSsygk1VcZcGzrz0JfGXslwqglaplumSUOic0Cf(Nv4HdodEiUIYQKwZsBwuWI6Q3nJJGk4cN7dvXkHzfXsBwAAyrfIXSOGL(HA)ZdL6xHzbWSaiKXstdlumSUOic0qPrjgY1z4awEfiwuWsac1GqlLHsJsmKRZWbS8kqMHs9RWSeplXjjwAZIcwqfandL6xHzjEwsYEZd)bl7nmCP10)xHkpl1e2VDSvgq2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVPU6DtWZxfmdL6xHzjEwugzSOGLwSynlZQOoCqrg8v9LoVNa)0CUHkxvtGS00WI6Q3nJJGk4cN7dvXkHzOu)kmlawjwugqSamwAXsCyb4zrD17gvnecQx43SIyPnlaJLwS0IfaclaqwqglaplQRE3OQHqq9c)MvelTzb4zHIH1ffrGMRW)ScpCWzWdXvuwL0AwAZIcwux9UzCeubx4CFOkwjmRiwAZstdlQqmMffS0pu7FEOu)kmlaMfaHmwAAyHIH1ffrGgknkXqUodhWYRaXIcwcqOgeAPmuAuIHCDgoGLxbYmuQFf2EdKWH5I(dw2BXvBXtGzzHjwSYyCeJyXY97SGM4IeRSc2Bi8jxEkzVDXayoalW7pyz)2Xw54yBv7nQCvnbAht7np8hSS3UchM17QAkhdlV(vAgKqCbYElm3tZ52Bi85CvnzUyamhGf49hSyrblOcGMHs9RWSepljzVvEkzVDfomR3v1uogwE9R0miH4cK9BhBLrpBRAVrLRQjq7yAVbs4WCr)bl7naaMyzou7plQuhoelbqS9w5PK9gE3bHwiWmCuZWE(HtkvV9wyUNMZT3AXsac1GqlLj45RcMHCWeSOGfRzjarqLxVPou7FU7elkybHpNRQjZVpNwNXebenzl(9S00WsaIGkVEtDO2)C3jwuWsac1GqlLjaleqGO8VtzC0n3Jnd5GjyrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMHCWeS0ML2SOGfq4BWRQFdz(la0vOyrblTybe(g8tATp5U2hY8xaORqXstdlwZY7AQEd(jT2NCx7dzOYv1eilnnSGJiTo)(GIESb)(0VHyjEwIdlTzrblTybe(MuiS63qM)caDfkwAZIcwAXccFoxvtMdNDiXstdlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGS00WIJ)X15iOfAyjELybPKelnnSOU6DJQgcb1l8BwrS0MffS0ILaeQbHwkJknyAa6kuMHCWeS00WI1SmEGm)a1AwAZstdlQqmMffS0pu7FEOu)kmlaMf0lj7np8hSS3W7oi0cbMHJAg2ZpCsP6TF7yRmYSTQ9gvUQMaTJP9giHdZf9hSS3S6(Hz5WS4Sm(VtdlK2vHJ)elw8eS8qwsDGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSC)olOjUiXkRalEbYcAGfciqelEbYYctS87elaQazbRHplWILailxNfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhBVfM7P5C7TwSGWNZv1Kbw5fMY)Cfq0ZI1kXIYSOGfRz5NRaIEZdiZqoyICac1GqlflnnS0Ife(CUQMmWkVWu(NRaIEwuIfLzPPHfe(CUQMmWkVWu(NRaIEwuIL4WsBwuWslwux9Uj45RcMvelkyPflwZsaIGkVEdcQ(9edlnnSOU6DZ4iOcUW5(qvSsygk1VcZcWyPfliJfGNLzvuhoOid(Q(sN3tGFAo3qLRQjqwAZcGvILFUci6nVYg1vVNbxJ)hSyrblQRE3mocQGlCUpufReMvelnnSOU6DZ4iOcUW5(qvSsKXx1x68Ec8tZ5MvelTzPPHLaeQbHwktWZxfmdL6xHzbySaiwINLFUci6nVYMaeQbHwkd4A8)GflkyXAwux9Uj45RcMvelkyPflwZsaIGkVEtDO2)C3jwAAyXAwq4Z5QAYeGfciqugKWjQalTzrblwZsaIGkVEdqjMZlwAAyjarqLxVPou7FU7elkybHpNRQjtawiGarzqcNOcSOGLaeQbHwktawiGar5FNY4OBUhBwrSOGfRzjaHAqOLYe88vbZkIffS0ILwSOU6Ddf0xeMY6v5JzOu)kmlXZIYjXstdlQRE3qb9fHPmgQ9XmuQFfML4zr5KyPnlkyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazPPHLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelkXcYyPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyrjwaiS0ML2S00WI6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrS0MLMgw6hQ9ppuQFfMfaZcGsILMgwq4Z5QAYaR8ct5FUci6zrjwsIL2SOGfubqZqP(vywINLKS3WA4JT3(5kGOxz7np8hSS3(5kGOxz73o2kdCSTQ9gvUQMaTJP9Mh(dw2B)Cfq0di7TWCpnNBV1Ife(CUQMmWkVWu(NRaIEwSwjwaelkyXAw(5kGO38kBgYbtKdqOgeAPyPPHfe(CUQMmWkVWu(NRaIEwuIfaXIcwAXI6Q3nbpFvWSIyrblTyXAwcqeu51Bqq1VNyyPPHf1vVBghbvWfo3hQIvcZqP(vywaglTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwaSsS8ZvarV5bKrD17zW14)blwuWI6Q3nJJGk4cN7dvXkHzfXstdlQRE3mocQGlCUpufRez8v9LoVNa)0CUzfXsBwAAyjaHAqOLYe88vbZqP(vywaglaIL4z5NRaIEZditac1GqlLbCn(FWIffSynlQRE3e88vbZkIffS0IfRzjarqLxVPou7FU7elnnSynli85CvnzcWcbeikds4evGL2SOGfRzjarqLxVbOeZ5flkyPflwZI6Q3nbpFvWSIyPPHfRzjarqLxVbbv)EIHL2S00WsaIGkVEtDO2)C3jwuWccFoxvtMaSqabIYGeorfyrblbiudcTuMaSqabIY)oLXr3Cp2SIyrblwZsac1GqlLj45RcMvelkyPflTyrD17gkOVimL1RYhZqP(vywINfLtILMgwux9UHc6lctzmu7JzOu)kmlXZIYjXsBwuWI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYstdlTyrD17gvx7vGYWE2168VFfkCU8FnKb)EaiwuIfKXstdlQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daXIsSaqyPnlTzPnlnnSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelnnSOcXywuWs)qT)5Hs9RWSaywausS00WccFoxvtgyLxyk)ZvarplkXssS0MffSGkaAgk1VcZs8SKK9gwdFS92pxbe9aY(TJTYamBRAVrLRQjq7yAVbs4WCr)bl7naaMWS4AnlWFNgwGfllmXY9ukMfyXsa0EZd)bl7TfMY3tPy73o2kdqSTQ9gvUQMaTJP9giHdZf9hSS3Iru4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOoS9Mh(dw2BZQYE4pyL1h(T3W)CH3o2kBVfM7P5C7ne(CUQMmho7qYEtF4pxEkzV5qY(TJTYifBRAVrLRQjq7yAVfM7P5C7TzvuhoOiJQR9kqzyp7AD(3Vcf2qXW6IIiq7n8px4TJTY2BE4pyzVnRk7H)GvwF43EtF4pxEkzVPc93(TJnGsY2Q2Bu5QAc0oM2BE4pyzVnRk7H)GvwF43EtF4pxEkzVHF73(T3uH(BBv7yRSTvT3OYv1eODmT38WFWYEBCeubx4CFOkwjS3ajCyUO)GL9ga2qvSsWIL73zbnXfjwzfS3cZ90CU9M6Q3nbpFvWmuQFfML4zrzKz)2Xgq2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelaMfaclkyrD17gvx7vGYWE2168VFfkC2NGxKb)EaiwamlaewuWslwSMfq4BCqp6peugBXN0mON6OiZFbGUcflkyXAw8WFWY4GE0FiOm2IpPzqp1rrMRYD9HA)zrblTyXAwaHVXb9O)qqzSfFsZ7KRn)fa6kuS00Wci8noOh9hckJT4tAENCTzOu)kmlXZsCyPnlnnSacFJd6r)HGYyl(KMb9uhfzWVhaIfaZsCyrblGW34GE0FiOm2IpPzqp1rrMHs9RWSaywqglkybe(gh0J(dbLXw8jnd6PokY8xaORqXsB7nqchMl6pyzVbaWelXf0J(dbXYMfFszXYovS4plAcJz539If0JLycJRvzb)EaimlEbYYdzzO(q4DwCwaSsaIf87bGyXXSO9NyXXSebX4tvtSahw(lLy5EwWqwUNfFMdbHzb4Mf(zX7pnS4SehGXc(9aqSqip6gcB)2Xoo2w1EJkxvtG2X0EZd)bl7TaSqabIY)oLXr3Cp2EdKWH5I(dw2BaamXcAGfciqelwUFNf0exKyLvGfl7uXseeJpvnXIxGSa)DASCyIfl3VZIZsmHX1QSOU6DwSStflGeorfUcL9wyUNMZT3SMfWzDGMcMdGywuWslwAXccFoxvtMaSqabIYGeorfyrblwZsac1GqlLj45RcMHCWeS00WI6Q3nbpFvWSIyPnlkyPflQRE3O6AVcug2ZUwN)9RqHZL)RHm43daXIsSaqyPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyrjwaiS0MLMgwuHymlkyPFO2)8qP(vywamlkNelTTF7yJE2w1EJkxvtG2X0EZd)bl7T(AsKH9mPxfzVbs4WCr)bl7nami6ZIJz53jw63GFwqfaz5kw(DIfNLycJRvzXYvGqlSahwSC)ol)oXcW9eZ5flQRENf4WIL73zXzbGammfyjUGE0Fiiw2S4tklEbYIf)Ew6WHf0exKyLvGLRZY9SybwplQelRiwCu(vSOsD4qS87elbqwoml9Ro8obAVfM7P5C7TwS0ILwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelXZcWHLMgwux9Ur11EfOmSNDTo)7xHcN9j4fzWVhaIL4zb4WsBwuWslwSMLaebvE9geu97jgwAAyXAwux9UzCeubx4CFOkwjmRiwAZsBwuWslwaN1bAkyoaIzPPHLaeQbHwktWZxfmdL6xHzjEwqwsS00Wslwcqeu51BQd1(N7oXIcwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlXZcYsIL2S0ML2S00WslwaHVXb9O)qqzSfFsZGEQJImdL6xHzjEwaiSOGLaeQbHwktWZxfmdL6xHzjEwuojwuWsaIGkVEtrHbQHdilTzPPHLREAIGA)jWC)qT)5Hs9RWSaywaiSOGfRzjaHAqOLYe88vbZqoycwAAyjarqLxVbOeZ5flkyrD17gGUcCiWmLgbTqtkvVzfXstdlbicQ86niO63tmSOGf1vVBghbvWfo3hQIvcZqP(vywamlifwuWI6Q3nJJGk4cN7dvXkHzfz)2Xgz2w1EJkxvtG2X0EZd)bl7TGxbsNvx9U9wyUNMZT3AXI6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(vywINfaMbzS00WI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(vywINfaMbzS0MffS0ILaeQbHwktWZxfmdL6xHzjEwayS00WslwcqOgeAPmuAe0cnzvybAgk1VcZs8SaWyrblwZI6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrSOGLaebvE9gGsmNxS0ML2SOGfh)JRZrql0Ws8kXsCsYEtD175Ytj7n87JgoG2BGeomx0FWYEdnEfinlBVpA4aYIL73zXzPilSetyCTklQRENfVazbnXfjwzfy5Wf6EwCv46z5HSOsSSWeO9BhBGJTvT3OYv1eODmT38WFWYEd)(GxdkYEdKWH5I(dw2BXOvAelBVp41GIWSy5(DwCwIjmUwLf1vVZI66zPGplw2PILiiuFfkw6WHf0exKyLvGf4WcW9RahcKLTOBUhBVfM7P5C7TwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelXZcGyPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyjEwaelTzrblTyjarqLxVPou7FU7elnnSeGqni0szcE(QGzOu)kmlXZcaJLMgwSMfe(CUQMmbWCawG3FWIffSynlbicQ86naLyoVyPPHLwSeGqni0szO0iOfAYQWc0muQFfML4zbGXIcwSMf1vVBa6kWHaZuAe0cnPu9zQOb1flYSIyrblbicQ86naLyoVyPnlTzrblTyXAwaHVPVMezypt6vrM)caDfkwAAyXAwcqOgeAPmbpFvWmKdMGLMgwSMLaeQbHwktawiGar5FNY4OBUhBgYbtWsB73o2amBRAVrLRQjq7yAV5H)GL9g(9bVguK9giHdZf9hSS3IrR0iw2EFWRbfHzrL6WHybnWcbeiYElm3tZ52BTyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywqglkyXAwaN1bAkyoaIzrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMHs9RWSaywqglTzrbli85CvnzcG5aSaV)GflTzrblwZci8n91Kid7zsVkY8xaORqXIcwcqeu51BQd1(N7oXIcwSMfWzDGMcMdGywuWcf0xeMmxL9kblkyXX)46Ce0cnSeplOxs2VDSbi2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1If1vVBghbvWfo3hQIvcZqP(vywINfKXstdlwZI6Q3nJJGk4cN7dvXkHzfXsBwuWslwux9UbORahcmtPrql0Ks1NPIguxSiZqP(vywamlOcGMuh5S0MffS0If1vVBOG(IWugd1(ygk1VcZs8SGkaAsDKZstdlQRE3qb9fHPSEv(ygk1VcZs8SGkaAsDKZsB7nqchMl6pyzVfJGf6EwaHplGR5kuS87elubYcSZsmMJGk4cZca2qvSsGwwaxZvOybORahcKfkncAHMuQEwGdlxXYVtSOD8ZcQailWolEXc6h0xeMS3q4tU8uYEde(5HIH1nukvp2(TJnsX2Q2Bu5QAc0oM2BE4pyzVHxv)gYElm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwug4WIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBLtY2Q2Bu5QAc0oM2BE4pyzVLcHv)gYElm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwuoogKXIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBLv22Q2Bu5QAc0oM2BE4pyzVHFsR9j31(q2BH5EAo3EBO(q4DxvtSOGL3hu0B(lLYpmdEelXZIYahwagldL6xHzrblEuoStbGyrbli85CvnzaHFEOyyDdLs1JT3cjcAk)(GIESDSv2(TJTYaY2Q2Bu5QAc0oM2BE4pyzV1HtGYWEU8FnK9giHdZf9hSS3aWGXMfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhBLJJTvT3OYv1eODmT38WFWYEJsJGwOjRclq7nqchMl6pyzVH(Prql0WsmHfilw2PIfxfUEwEilu90WIZsrwyjMW4AvwSCfi0clEbYc2rqS0HdlOjUiXkRG9wyUNMZT3AXcf0xeMm6v5tUiK)S00Wcf0xeMmyO2NCri)zPPHfkOVimz8krUiK)S00WI6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(vywINfaMbzS00WI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(vywINfaMbzS00WIJ)X15iOfAyjEwqkjXIcwcqOgeAPmbpFvWmKdMGffSynlGZ6anfmhaXS0MffS0ILaeQbHwktWZxfmdL6xHzjEwItsS00Wsac1GqlLj45RcMHCWeS0MLMgwU6PjcQ9NaZ9d1(Nhk1VcZcGzr5KSF7yRm6zBv7nQCvnbAht7np8hSS36Rjrg2ZKEvK9giHdZf9hSS3aWGOplZHA)zrL6WHyzHVcflOjU2BH5EAo3ElaHAqOLYe88vbZqoycwuWccFoxvtMayoalW7pyXIcwAXIJ)X15iOfAyjEwqkjXIcwSMLaebvE9M6qT)5UtS00WsaIGkVEtDO2)C3jwuWIJ)X15iOfAybWSGEjXsBwuWI1SeGiOYR3GGQFpXWIcwAXI1SeGiOYR3uhQ9p3DILMgwcqOgeAPmbyHaceL)DkJJU5ESzihmblTzrblwZc4SoqtbZbqS9BhBLrMTvT3OYv1eODmT3Gr2By6T38WFWYEdHpNRQj7neUEr2BwZc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrblTyPflo(hxNJGwOHL4zbPKelkyPflQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfXstdlwZsaIGkVEdqjMZlwAZstdlQRE3OQHqq9c)MvelkyrD17gvnecQx43muQFfMfaZI6Q3nbpFvWaUg)pyXsBwAAy5QNMiO2Fcm3pu7FEOu)kmlaMf1vVBcE(QGbCn(FWILMgwcqeu51BQd1(N7oXsBwuWslwSMLaebvE9M6qT)5UtS00WslwC8pUohbTqdlaMf0ljwAAybe(M(AsKH9mPxfz(la0vOyPnlkyPfli85CvnzcWcbeikds4evGLMgwcqOgeAPmbyHaceL)DkJJU5ESzihmblTzPT9giHdZf9hSS3qtCrIvwbwSStfl(ZcsjjGXsCXauwAbhn0cnS87EXc6LelXfdqzXY97SGgyHace1Mfl3VdxplAi(kuS8xkXYvSetnecQx4NfVazrFfXYkIfl3VZcAGfciqelxNL7zXIJzbKWjQabAVHWNC5PK9wamhGf49hSYQq)TF7yRmWX2Q2Bu5QAc0oM2BH5EAo3EdHpNRQjtamhGf49hSYQq)T38WFWYElqAc)NRZU(qvPu92VDSvgGzBv7nQCvnbAht7TWCpnNBVHWNZv1KjaMdWc8(dwzvO)2BE4pyzVDvWNY)dw2VDSvgGyBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9gf0xeMmxL1RYhwaEwaiSGew8WFWYGFF63qgc5uy9u(VuIfGXI1Sqb9fHjZvz9Q8HfGNLwSaCybyS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSa8SehwAZcsyXd)blJLX)DdHCkSEk)xkXcWyjjdGybjSGJiToV74NS3ajCyUO)GL9g6J)l1FcZYo0clPRWolXfdqzXhIfu(veilr0WcMcWc0EdHp5Ytj7nhhbqPzJc2VDSvgPyBv7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9wmALgXY27dEnOimlw2PILFNyPFO2FwomlUkC9S8qwOceTS0hQIvcwomlUkC9S8qwOceTSKaUyXhIf)zbPKeWyjUyaklxXIxSG(b9fHj0YcAIlsSYkWI2XpMfVG)onSaqagMcywGdljGlwSaxAqwGiOj4rSKchILF3lw4gLtIL4IbOSyzNkwsaxSybU0Gf6Ew2EFWRbfXsbTyVfM7P5C7TwSC1tteu7pbM7hQ9ppuQFfMfaZc6XstdlTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcQaOj1rolaplb60S0Ifh)JRZrql0WcsyjojXsBwuWI6Q3nJJGk4cN7dvXkHzfXsBwAZstdlTyXX)46Ce0cnSamwq4Z5QAY44iaknBuGfGNf1vVBOG(IWugd1(ygk1VcZcWybe(M(AsKH9mPxfz(laeopuQFflaplaYGmwINfLvojwAAyXX)46Ce0cnSamwq4Z5QAY44iaknBuGfGNf1vVBOG(IWuwVkFmdL6xHzbySacFtFnjYWEM0RIm)facNhk1VIfGNfazqglXZIYkNelTzrbluqFryYCv2ReSOGLwSynlQRE3e88vbZkILMgwSML31u9g87JgoGgQCvnbYsBwuWslwAXI1SeGqni0szcE(QGzfXstdlbicQ86naLyoVyrblwZsac1GqlLHsJGwOjRclqZkIL2S00WsaIGkVEtDO2)C3jwAZIcwAXI1SeGiOYR3GGQFpXWstdlwZI6Q3nbpFvWSIyPPHfh)JRZrql0Ws8SGusIL2S00WslwExt1BWVpA4aAOYv1eilkyrD17MGNVkywrSOGLwSOU6Dd(9rdhqd(9aqSaywIdlnnS44FCDocAHgwINfKssS0ML2S00WI6Q3nbpFvWSIyrblwZI6Q3nJJGk4cN7dvXkHzfXIcwSML31u9g87JgoGgQCvnbA)2XgqjzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSyfRYhwq)G(IWelEbYc2rqSeJRR7adaBP1SaGdclw6WHf0exKyLvWElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfc5uy9u(VuILMgwAXsy3hueMfLybqSOGLHc7(GIY)LsSaywqglTzPPHLWUpOimlkXsCyPnlkyXJYHDkaK9BhBaPSTvT3OYv1eODmT3cZ90CU9wlwux9UHc6lctz9Q8XmuQFfML4zHqofwpL)lLyrblTyjaHAqOLYe88vbZqP(vywINfKLelnnSeGqni0szcWcbeik)7ughDZ9yZqP(vywINfKLelTzPPHLwSe29bfHzrjwaelkyzOWUpOO8FPelaMfKXsBwAAyjS7dkcZIsSehwAZIcw8OCyNcazV5H)GL92UR75uiSSF7ydiazBv7nQCvnbAht7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKtH1t5)sjwuWslwcqOgeAPmbpFvWmuQFfML4zbzjXstdlbiudcTuMaSqabIY)oLXr3Cp2muQFfML4zbzjXsBwAAyPflHDFqrywuIfaXIcwgkS7dkk)xkXcGzbzS0MLMgwc7(GIWSOelXHL2SOGfpkh2Paq2BE4pyzV1xADofcl73o2ako2w1EJkxvtG2X0EdKWH5I(dw2Baxq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF7ydi0Z2Q2Bu5QAc0oM2BE4pyzVHFF63q2BGeomx0FWYEdaGjw2EF63qS8qwIgyGLnO2hwq)G(IWelWHfl7uXYvSalDcwSIv5dlOFqFryIfVazzHjwaUGOplrdmGz56SCflwXQ8Hf0pOVimzVfM7P5C7nkOVimzUkRxLpS00Wcf0xeMmyO2NCri)zPPHfkOVimz8krUiK)S00WI6Q3nw8zo4KH9mPxfzwrSOGf1vVBOG(IWuwVkFmRiwAAyPflQRE3e88vbZqP(vywamlE4pyzSm(VBiKtH1t5)sjwuWI6Q3nbpFvWSIyPT9BhBaHmBRAV5H)GL9MLX)D7nQCvnbAht73o2ac4yBv7nQCvnbAht7np8hSS3MvL9WFWkRp8BVPp8NlpLS36Uw)7ZY(TF7nhs2w1o2kBBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9wlwux9U5VuYcCQm4qEQ6vG0ygk1VcZcGzbva0K6iNfGXssgLzPPHf1vVB(lLSaNkdoKNQEfinMHs9RWSayw8WFWYGFF63qgc5uy9u(VuIfGXssgLzrblTyHc6lctMRY6v5dlnnSqb9fHjdgQ9jxeYFwAAyHc6lctgVsKlc5plTzPnlkyrD17M)sjlWPYGd5PQxbsJzfXIcwMvrD4GIm)LswGtLbhYtvVcKgdvUQMaT3ajCyUO)GL9gACDyP9NWSyzN(DAy53jwIrd5Pb)d70WI6Q3zXYP1S0DTMfyVZIL73VILFNyPiK)SeC8BVHWNC5PK9g4qEA2YP15UR1zyVB)2Xgq2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVznluqFryYCvgd1(WIcwAXcoI0687dk6Xg87t)gIL4zbzSOGL31u9gmCPZWE(3PChoe(nu5QAcKLMgwWrKwNFFqrp2GFF63qSeplamwABVbs4WCr)bl7n046Ws7pHzXYo970WY27dEnOiwomlwGZVZsWX)vOybIGgw2EF63qSCflwXQ8Hf0pOVimzVHWNC5PK92HQGdLXVp41GISF7yhhBRAVrLRQjq7yAV5H)GL9wawiGar5FNY4OBUhBVbs4WCr)bl7naaMybnWcbeiIfl7uXI)SOjmMLF3lwqwsSexmaLfVazrFfXYkIfl3VZcAIlsSYkyVfM7P5C7nRzbCwhOPG5aiMffS0ILwSGWNZv1KjaleqGOmiHtubwuWI1SeGqni0szcE(QGzihmblnnSOU6DtWZxfmRiwAZIcwAXI6Q3nuqFrykRxLpMHs9RWSeplahwAAyrD17gkOVimLXqTpMHs9RWSeplahwAZIcwAXI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYstdlQRE3O6AVcug2ZUwN)9RqHZL)RHm43daXs8SehwAAyrD17gvx7vGYWE2168VFfkC2NGxKb)EaiwINL4WsBwAAyrfIXSOGL(HA)ZdL6xHzbWSOCsSOGfRzjaHAqOLYe88vbZqoycwAB)2Xg9STQ9gvUQMaTJP9Mh(dw2BJJGk4cN7dvXkH9giHdZf9hSS3aayIfaSHQyLGfl3VZcAIlsSYkyVfM7P5C7n1vVBcE(QGzOu)kmlXZIYiZ(TJnYSTQ9gvUQMaTJP9Mh(dw2B4v1VHS3cjcAk)(GIESDSv2Elm3tZ52BTyzO(q4DxvtS00WI6Q3nuqFrykJHAFmdL6xHzbWSehwuWcf0xeMmxLXqTpSOGLHs9RWSaywug9yrblVRP6ny4sNH98Vt5oCi8BOYv1eilTzrblVpOO38xkLFyg8iwINfLrpwaGSGJiTo)(GIEmlaJLHs9RWSOGLwSqb9fHjZvzVsWstdldL6xHzbWSGkaAsDKZsB7nqchMl6pyzVbaWelBRQFdXYvSe5fiLEbwGflEL43Vcfl)U)SOpeeMfLrpmfWS4filAcJzXY97SKchIL3hu0JzXlqw8NLFNyHkqwGDwCw2GAFyb9d6lctS4plkJESGPaMf4WIMWywgk1V6kuS4ywEilf8zz3rCfkwEild1hcVZc4AUcflwXQ8Hf0pOVimz)2Xg4yBv7nQCvnbAht7np8hSS3WRQFdzVbs4WCr)bl7naaMyzBv9BiwEil7ocIfNfuAOQRz5HSSWelwzmoIr2BH5EAo3EdHpNRQjZfdG5aSaV)GflkyjaHAqOLYCfomR3v1uogwE9R0miH4cKzihmblkyHIH1ffrGMRWHz9UQMYXWYRFLMbjexGSF7ydWSTQ9gvUQMaTJP9wyUNMZT3SML31u9g8tATpzW56VHkxvtGSOGLwSOU6Dd(9P7ATzO(q4DxvtSOGLwSGJiTo)(GIESb)(0DTMfaZsCyPPHfRzzwf1HdkY8xkzbovgCipv9kqAmu5QAcKL2S00WY7AQEdgU0zyp)7uUdhc)gQCvnbYIcwux9UHc6lctzmu7JzOu)kmlaML4WIcwOG(IWK5QmgQ9HffSOU6Dd(9P7ATzOu)kmlaMfaglkybhrAD(9bf9yd(9P7AnlXRelOhlTzrblTyXAwMvrD4GIm6ebFCCURj6VcvgL(sJWKHkxvtGS00WYFPelivwqpKXs8SOU6Dd(9P7ATzOu)kmlaJfaXsBwuWY7dk6n)Ls5hMbpIL4zbz2BE4pyzVHFF6UwB)2XgGyBv7nQCvnbAht7np8hSS3WVpDxRT3ajCyUO)GL9gW197SS9Kw7dlXO56pllmXcSyjaYILDQyzO(q4DxvtSOUEwW)P1SyXVNLoCyXkse8XXSenWalEbYciSq3ZYctSOsD4qSGMye2WY2FAnllmXIk1HdXcAGfciqel4Rcel)U)Sy50AwIgyGfVG)onSS9(0DT2Elm3tZ52BVRP6n4N0AFYGZ1FdvUQMazrblQRE3GFF6UwBgQpeE3v1elkyPflwZYSkQdhuKrNi4JJZDnr)vOYO0xAeMmu5QAcKLMgw(lLybPYc6HmwINf0JL2SOGL3hu0B(lLYpmdEelXZsCSF7yJuSTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEd46(DwIrd5PQxbsdllmXY27t31AwEilaruelRiw(DIf1vVZIAcwCngYYcFfkw2EF6UwZcSybzSGPaSaXSahw0egZYqP(vxHYElm3tZ52BZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGSOGfCeP153hu0Jn43NUR1SeVsSehwuWslwSMf1vVB(lLSaNkdoKNQEfinMvelkyrD17g87t31AZq9HW7UQMyPPHLwSGWNZv1KbCipnB506C316mS3zrblTyrD17g87t31AZqP(vywamlXHLMgwWrKwNFFqrp2GFF6UwZs8SaiwuWY7AQEd(jT2Nm4C93qLRQjqwuWI6Q3n43NUR1MHs9RWSaywqglTzPnlTTF7yRCs2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV54FCDocAHgwINfassSaazPflkNelaplQRE38xkzbovgCipv9kqAm43daXsBwaGS0If1vVBWVpDxRndL6xHzb4zjoSGewWrKwN3D8tSa8SynlVRP6n4N0AFYGZ1FdvUQMazPnlaqwAXsac1GqlLb)(0DT2muQFfMfGNL4WcsybhrADE3XpXcWZY7AQEd(jT2Nm4C93qLRQjqwAZcaKLwSacFtFnjYWEM0RImdL6xHzb4zbzS0MffS0If1vVBWVpDxRnRiwAAyjaHAqOLYGFF6UwBgk1VcZsB7nqchMl6pyzVHgxhwA)jmlw2PFNgwCw2EFWRbfXYctSy50Awc(ctSS9(0DTMLhYs31AwG9oAzXlqwwyILT3h8AqrS8qwaIOiwIrd5PQxbsdl43daXYkYEdHp5Ytj7n87t316Sfy95UR1zyVB)2XwzLTTQ9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYEdaGjw2EFWRbfXIL73zjgnKNQEfinS8qwaIOiwwrS87elQRENfl3VdxplAi(kuSS9(0DTMLv0FPelEbYYctSS9(GxdkIfyXc6bmwIjmUwLf87bGWSSQ)0SGES8(GIES9wyUNMZT3q4Z5QAYaoKNMTCADU7ADg27SOGfe(CUQMm43NUR1zlW6ZDxRZWENffSynli85CvnzoufCOm(9bVguelnnS0If1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGyjEwIdlnnSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpaelXZsCyPnlkybhrAD(9bf9yd(9P7AnlaMf0JffSGWNZv1Kb)(0DToBbwFU7ADg272VDSvgq2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVznl)fa6kuSOGfRzXd)blJd6r)HGYyl(KMb9uhfzUk31hQ9NLMgwaHVXb9O)qqzSfFsZGEQJIm43daXcGzjoSOGfq4BCqp6peugBXN0mON6OiZqP(vywamlXXEdKWH5I(dw2BaamXc2IpPSGHS87(Zsc4Ifu0ZsQJCwwr)LsSOMGLf(kuSCploMfT)eloMLiigFQAIfyXIMWyw(DVyjoSGFpaeMf4WcWnl8ZILDQyjoaJf87bGWSqip6gY(TJTYXX2Q2Bu5QAc0oM2BE4pyzVLcHv)gYElKiOP87dk6X2Xwz7TWCpnNBVnuFi8URQjwuWY7dk6n)Ls5hMbpIL4zPflTyrz0JfGXslwWrKwNFFqrp2GFF63qSa8SaiwaEwux9UHc6lctz9Q8XSIyPnlTzbySmuQFfML2SGewAXIYSamwExt1BElxLtHWcBOYv1eilTzrblTyjaHAqOLYe88vbZqoycwuWI1SaoRd0uWCaeZIcwAXccFoxvtMaSqabIYGeorfyPPHLaeQbHwktawiGar5FNY4OBUhBgYbtWstdlwZsaIGkVEtDO2)C3jwAZstdl4isRZVpOOhBWVp9BiwamlTyPflahwaGS0If1vVBOG(IWuwVkFmRiwaEwaelTzPnlaplTyrzwaglVRP6nVLRYPqyHnu5QAcKL2S0MffSynluqFryYGHAFYfH8NLMgwAXcf0xeMmxLXqTpS00WslwOG(IWK5QSk83zPPHfkOVimzUkRxLpS0MffSynlVRP6ny4sNH98Vt5oCi8BOYv1eilnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IyjELybqiljwAZIcwAXcoI0687dk6Xg87t)gIfaZIYjXcWZslwuMfGXY7AQEZB5QCkewydvUQMazPnlTzrblo(hxNJGwOHL4zbzjXcaKf1vVBWVpDxRndL6xHzb4zb4WsBwuWslwSMf1vVBa6kWHaZuAe0cnPu9zQOb1flYSIyPPHfkOVimzUkJHAFyPPHfRzjarqLxVbOeZ5flTzrblwZI6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwr2BGeomx0FWYElgJ6dH3zbahew9BiwUolOjUiXkRalhMLHCWeOLLFNgIfFiw0egZYV7fliJL3hu0Jz5kwSIv5dlOFqFryIfl3VZYg8bWqllAcJz539IfLtIf4VtJLdtSCflELGf0pOVimXcCyzfXYdzbzS8(GIEmlQuhoelolwXQ8Hf0pOVimzyjgbl09SmuFi8olGR5kuSaC)kWHazb9tJGwOjLQNLvPjmMLRyzdQ9Hf0pOVimz)2Xwz0Z2Q2Bu5QAc0oM2BE4pyzV1HtGYWEU8FnK9giHdZf9hSS3aayIfamySzbwSeazXY97W1ZsWJIUcL9wyUNMZT38OCyNcaz)2XwzKzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M1SaoRd0uWCaeZIcwq4Z5QAYeaZbybE)blwuWslwAXI6Q3n43NUR1MvelnnS8UMQ3GFsR9jdox)nu5QAcKLMgwcqeu51BQd1(N7oXsBwuWslwSMf1vVBWqn(VazwrSOGfRzrD17MGNVkywrSOGLwSynlVRP6n91Kid7zsVkYqLRQjqwAAyrD17MGNVkyaxJ)hSyjEwcqOgeAPm91Kid7zsVkYmuQFfMfGXcaHL2SOGfe(CUQMm)(CADgteq0KT43ZIcwAXI1SeGiOYR3uhQ9p3DILMgwcqOgeAPmbyHaceL)DkJJU5ESzfXIcwAXI6Q3n43NUR1MHs9RWSaywaelnnSynlVRP6n4N0AFYGZ1FdvUQMazPnlTzrblVpOO38xkLFyg8iwINf1vVBcE(QGbCn(FWIfGNLKmamwAZstdlQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWIL22Bi8jxEkzVfaZbybE)bRSdj73o2kdCSTQ9gvUQMaTJP9Mh(dw2Bbst4)CD21hQkLQ3EdKWH5I(dw2BaamXcAIlsSYkWcSyjaYYQ0egZIxGSOVIy5EwwrSy5(DwqdSqabIS3cZ90CU9gcFoxvtMayoalW7pyLDiz)2XwzaMTvT3OYv1eODmT3cZ90CU9gcFoxvtMayoalW7pyLDizV5H)GL92vbFk)pyz)2XwzaITvT3OYv1eODmT38WFWYEJsJGwOjRclq7nqchMl6pyzVbaWelOFAe0cnSetybYcSyjaYIL73zz79P7AnlRiw8cKfSJGyPdhwaOln2hw8cKf0exKyLvWElm3tZ52Bx90eb1(tG5(HA)ZdL6xHzbWSOmYyPPHLwSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaiKLelnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IyjELybqiljwAZIcwux9Ub)(0DT2SIyrblTyjaHAqOLYe88vbZqP(vywINfKLelnnSaoRd0uWCaeZsB73o2kJuSTQ9gvUQMaTJP9Mh(dw2B4N0AFYDTpK9wirqt53hu0JTJTY2BH5EAo3EBO(q4DxvtSOGL)sP8dZGhXs8SOmYyrbl4isRZVpOOhBWVp9BiwamlOhlkyXJYHDkaelkyPflQRE3e88vbZqP(vywINfLtILMgwSMf1vVBcE(QGzfXsB7nqchMl6pyzVfJr9HW7S01(qSalwwrS8qwIdlVpOOhZIL73HRNf0exKyLvGfv6kuS4QW1ZYdzHqE0nelEbYsbFwGiOj4rrxHY(TJnGsY2Q2Bu5QAc0oM2BE4pyzV1xtImSNj9Qi7nqchMl6pyzVbaWelayq0NLRZYv4dKyXlwq)G(IWelEbYI(kIL7zzfXIL73zXzbGU0yFyjAGbw8cKL4c6r)HGyzZIpP2BH5EAo3EJc6lctMRYELGffS4r5WofaIffSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaiKLelkyPflGW34GE0FiOm2IpPzqp1rrM)caDfkwAAyXAwcqeu51BkkmqnCazPPHfCeP153hu0JzjEwaelTzrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcsHfailTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsBwuWslwSMLaeQbHwktWZxfmRiwAAyrD17MFFoToJjciAm43daXcGzrzKXIcw6hQ9ppuQFfMfaZcGskjwuWs)qT)5Hs9RWSeplkNusS00WI1SGHlT6vGMFFoToJjciAmu5QAcKL2SOGLwSGHlT6vGMFFoToJjciAmu5QAcKLMgwcqOgeAPmbpFvWmuQFfML4zjojXsB73o2aszBRAVrLRQjq7yAV5H)GL9g(9P7AT9giHdZf9hSS3aayIfNLT3NUR1SaGVOFNLObgyzvAcJzz79P7AnlhMfxpKdMGLvelWHLeWfl(qS4QW1ZYdzbIGMGhXsCXau7TWCpnNBVPU6DdSOFhNJOjqr)blZkIffS0If1vVBWVpDxRnd1hcV7QAILMgwC8pUohbTqdlXZcsjjwAB)2XgqaY2Q2Bu5QAc0oM2BE4pyzVHFF6UwBVbs4WCr)bl7Ty0knIL4IbOSOsD4qSGgyHaceXIL73zz79P7AnlEbYYVtflBVp41GIS3cZ90CU9waIGkVEtDO2)C3jwuWI1S8UMQ3GFsR9jdox)nu5QAcKffS0Ife(CUQMmbyHaceLbjCIkWstdlbiudcTuMGNVkywrS00WI6Q3nbpFvWSIyPnlkyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywqfanPoYzb4zjqNMLwS44FCDocAHgwqcliljwAZIcwux9Ub)(0DT2muQFfMfaZc6XIcwSMfWzDGMcMdGy73o2ako2w1EJkxvtG2X0Elm3tZ52BbicQ86n1HA)ZDNyrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMvelnnSOU6DtWZxfmRiwAZIcwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlaMfGdlkyrD17g87t31AZkIffSqb9fHjZvzVsWIcwSMfe(CUQMmhQcoug)(GxdkIffSynlGZ6anfmhaX2BE4pyzVHFFWRbfz)2XgqONTvT3OYv1eODmT38WFWYEd)(GxdkYEdKWH5I(dw2BaamXY27dEnOiwSC)olEXca(I(DwIgyGf4WY1zjbCHoqwGiOj4rSexmaLfl3VZsc4AyPiK)SeC8ByjUAmKfWvAelXfdqzXFw(DIfQazb2z53jwIXt1VNyyrD17SCDw2EF6UwZIf4sdwO7zP7AnlWENf4Wsc4IfFiwGflaIL3hu0JT3cZ90CU9M6Q3nWI(DCoOjFYio8blZkILMgwAXI1SGFF63qgpkh2PaqSOGfRzbHpNRQjZHQGdLXVp41GIyPPHLwSOU6DtWZxfmdL6xHzbWSGmwuWI6Q3nbpFvWSIyPPHLwS0If1vVBcE(QGzOu)kmlaMfubqtQJCwaEwc0PzPflo(hxNJGwOHfKWsCsIL2SOGf1vVBcE(QGzfXstdlQRE3mocQGlCUpufRez8v9LoVNa)0CUzOu)kmlaMfubqtQJCwaEwc0PzPflo(hxNJGwOHfKWsCsIL2SOGf1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIyPnlkyjarqLxVbbv)EIHL2S0MffS0IfCeP153hu0Jn43NUR1SaywIdlnnSGWNZv1Kb)(0DToBbwFU7ADg27S0ML2SOGfRzbHpNRQjZHQGdLXVp41GIyrblTyXAwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazPPHfCeP153hu0Jn43NUR1SaywIdlTTF7ydiKzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSSb1(Wc6h0xeMyXlqwWocIfaSLwZcaoiSyPdhwqtCrIvwb7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiNcRNY)LsS00Wslwc7(GIWSOelaIffSmuy3huu(VuIfaZcYyPnlnnSe29bfHzrjwIdlTzrblEuoStbGSF7ydiGJTvT3OYv1eODmT3cZ90CU9wlwux9UHc6lctzmu7JzOu)kmlXZcHCkSEk)xkXstdlTyjS7dkcZIsSaiwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS0MffS4r5WofaIffS0If1vVBghbvWfo3hQIvcZqP(vywamliJffSOU6DZ4iOcUW5(qvSsywrSOGfRzzwf1HdkYGVQV059e4NMZnu5QAcKLMgwSMf1vVBghbvWfo3hQIvcZkIL22BE4pyzVT76Eofcl73o2acGzBv7nQCvnbAht7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiNcRNY)LsSOGLwSeGqni0szcE(QGzOu)kmlXZcYsILMgwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlXZcYsIL2S00Wslwc7(GIWSOelaIffSmuy3huu(VuIfaZcYyPnlnnSe29bfHzrjwIdlTzrblEuoStbGyrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcYyrblQRE3mocQGlCUpufReMvelkyXAwMvrD4GIm4R6lDEpb(P5CdvUQMazPPHfRzrD17MXrqfCHZ9HQyLWSIyPT9Mh(dw2B9LwNtHWY(TJnGai2w1EJkxvtG2X0EdKWH5I(dw2BaamXcWfe9zbwSGMyK9Mh(dw2Bw8zo4KH9mPxfz)2XgqifBRAVrLRQjq7yAVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3WrKwNFFqrp2GFF63qSeplOhlaJLUgchwAXsQJFAsKr46fXcWZIYjLeliHfaLelTzbyS01q4Wslwux9Ub)(GxdkktPrql0Ks1NXqTpg87bGybjSGES02EdKWH5I(dw2BOX1HL2FcZILD63PHLhYYctSS9(0VHy5kw2GAFyXY(f2z5WS4pliJL3hu0JbMYS0HdlecAsWcGscPYsQJFAsWcCyb9yz79bVguelOFAe0cnPu9SGFpae2EdHp5Ytj7n87t)gkFvgd1(y)2XoojzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MYSGewWrKwN3D8tSaywaelaqwAXssgaXcWZslwWrKwNFFqrp2GFF63qSaazrzwAZcWZslwuMfGXY7AQEdgU0zyp)7uUdhc)gQCvnbYcWZIYgKXsBwAZcWyjjJYiJfGNf1vVBghbvWfo3hQIvcZqP(vy7nqchMl6pyzVHgxhwA)jmlw2PFNgwEilaxJ)7SaUMRqXca2qvSsyVHWNC5PK9MLX)98v5(qvSsy)2XookBBv7nQCvnbAht7np8hSS3Sm(VBVbs4WCr)bl7naaMyb4A8FNLRyzdQ9Hf0pOVimXcCy56Suqw2EF63qSy50Aw63ZYvpKf0exKyLvGfVsKchYElm3tZ52BTyHc6lctg9Q8jxeYFwAAyHc6lctgVsKlc5plkybHpNRQjZHZbn5iiwAZIcwAXY7dk6n)Ls5hMbpIL4zb9yPPHfkOVimz0RYN8vzaXstdl9d1(Nhk1VcZcGzr5KyPnlnnSOU6Ddf0xeMYyO2hZqP(vywamlE4pyzWVp9BidHCkSEk)xkXIcwux9UHc6lctzmu7JzfXstdluqFryYCvgd1(WIcwSMfe(CUQMm43N(nu(QmgQ9HLMgwux9Uj45RcMHs9RWSayw8WFWYGFF63qgc5uy9u(VuIffSynli85CvnzoCoOjhbXIcwux9Uj45RcMHs9RWSaywiKtH1t5)sjwuWI6Q3nbpFvWSIyPPHf1vVBghbvWfo3hQIvcZkIffSGWNZv1KXY4)E(QCFOkwjyPPHfRzbHpNRQjZHZbn5iiwuWI6Q3nbpFvWmuQFfML4zHqofwpL)lLSF7yhhazBv7nQCvnbAht7nqchMl6pyzVbaWelBVp9BiwUolxXIvSkFyb9d6lctOLLRyzdQ9Hf0pOVimXcSyb9aglVpOOhZcCy5HSenWalBqTpSG(b9fHj7np8hSS3WVp9Bi73o2Xjo2w1EJkxvtG2X0EdKWH5I(dw2BayUw)7ZYEZd)bl7Tzvzp8hSY6d)2B6d)5Ytj7TUR1)(SSF73ER7A9VplBRAhBLTTQ9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYEB79bVguelD4WskebLs1ZYQ0egZYcFfkwIjmUw1Elm3tZ52BwZYSkQdhuKr11EfOmSNDTo)7xHcBOyyDrreO9BhBazBv7nQCvnbAht7np8hSS3WRQFdzVfse0u(9bf9y7yRS9wyUNMZT3aHVjfcR(nKzOu)kmlXZYqP(vywaEwaeGybjSOmaXEdKWH5I(dw2BOXXpl)oXci8zXY97S87elPq8ZYFPelpKfheKLv9NMLFNyj1rolGRX)dwSCyw2V3WY2Q63qSmuQFfML0L(Vi9rGS8qws9pSZskew9BiwaxJ)hSSF7yhhBRAV5H)GL9wkew9Bi7nQCvnbAht73(T3WVTvTJTY2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVbaWelBVp41GIy5HSaerrSSIy53jwIrd5PQxbsdlQRENLRZY9SybU0GSqip6gIfvQdhIL(vhE)kuS87elfH8NLGJFwGdlpKfWvAelQuhoelObwiGar2BH5EAo3EBwf1HdkY8xkzbovgCipv9kqAmu5QAcKffS0IfkOVimzUk7vcwuWI1S0ILwSOU6DZFPKf4uzWH8u1RaPXmuQFfML4zXd)blJLX)DdHCkSEk)xkXcWyjjJYSOGLwSqb9fHjZvzv4VZstdluqFryYCvgd1(WstdluqFryYOxLp5Iq(ZsBwAAyrD17M)sjlWPYGd5PQxbsJzOu)kmlXZIh(dwg87t)gYqiNcRNY)LsSamwsYOmlkyPfluqFryYCvwVkFyPPHfkOVimzWqTp5Iq(ZstdluqFryY4vICri)zPnlTzPPHfRzrD17M)sjlWPYGd5PQxbsJzfXsBwAAyPflQRE3e88vbZkILMgwq4Z5QAYeGfciqugKWjQalTzrblbiudcTuMaSqabIY)oLXr3Cp2mKdMGffSeGiOYR3uhQ9p3DIL2SOGLwSynlbicQ86naLyoVyPPHLaeQbHwkdLgbTqtwfwGMHs9RWSeplaewAZIcwAXI6Q3nbpFvWSIyPPHfRzjaHAqOLYe88vbZqoycwAB)2Xgq2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVznlGW34GE0FiOm2IpPzqp1rrM)caDfkwuWI1S4H)GLXb9O)qqzSfFsZGEQJImxL76d1(ZIcwAXI1SacFJd6r)HGYyl(KM3jxB(la0vOyPPHfq4BCqp6peugBXN08o5AZqP(vywINfKXsBwAAybe(gh0J(dbLXw8jnd6PokYGFpaelaML4WIcwaHVXb9O)qqzSfFsZGEQJImdL6xHzbWSehwuWci8noOh9hckJT4tAg0tDuK5VaqxHYEdKWH5I(dw2BaamXsCb9O)qqSSzXNuwSStfl)onelhMLcYIh(dbXc2IpPOLfhZI2FIfhZseeJpvnXcSybBXNuwSC)olaIf4WsNSqdl43daHzboSalwCwIdWybBXNuwWqw(D)z53jwkYclyl(KYIpZHGWSaCZc)S49Ngw(D)zbBXNuwiKhDdHTF7yhhBRAVrLRQjq7yAV5H)GL9wawiGar5FNY4OBUhBVbs4WCr)bl7naaMWSGgyHaceXY1zbnXfjwzfy5WSSIyboSKaUyXhIfqcNOcxHIf0exKyLvGfl3VZcAGfciqelEbYsc4IfFiwujn0clOxsSexma1Elm3tZ52BwZc4SoqtbZbqmlkyPflTybHpNRQjtawiGarzqcNOcSOGfRzjaHAqOLYe88vbZqoycwuWI1SmRI6WbfzIMlfoGNRZ(e86c5OLg7JHkxvtGS00WI6Q3nbpFvWSIyPnlkyXX)46Ce0cnSayLyb9sIffS0If1vVBOG(IWuwVkFmdL6xHzjEwuojwAAyrD17gkOVimLXqTpMHs9RWSeplkNelTzPPHfvigZIcw6hQ9ppuQFfMfaZIYjXIcwSMLaeQbHwktWZxfmd5GjyPT9BhB0Z2Q2Bu5QAc0oM2BWi7nm92BE4pyzVHWNZv1K9gcxVi7TwSOU6DZ4iOcUW5(qvSsygk1VcZs8SGmwAAyXAwux9UzCeubx4CFOkwjmRiwAZIcwSMf1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIyrblTyrD17gGUcCiWmLgbTqtkvFMkAqDXImdL6xHzbWSGkaAsDKZsBwuWslwux9UHc6lctzmu7JzOu)kmlXZcQaOj1rolnnSOU6Ddf0xeMY6v5JzOu)kmlXZcQaOj1rolnnS0IfRzrD17gkOVimL1RYhZkILMgwSMf1vVBOG(IWugd1(ywrS0MffSynlVRP6nyOg)xGmu5QAcKL22BGeomx0FWYEdnWc8(dwS0HdlUwZci8XS87(ZsQdeHzbVgILFNsWIpuHUNLH6dH3jqwSStflXyocQGlmlaydvXkbl7oMfnHXS87EXcYybtbmldL6xDfkwGdl)oXcqjMZlwux9olhMfxfUEwEilDxRzb27Sahw8kblOFqFryILdZIRcxplpKfc5r3q2Bi8jxEkzVbc)8qXW6gkLQhB)2Xgz2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1IfRzrD17gkOVimLXqTpMvelkyXAwux9UHc6lctz9Q8XSIyPnlnnS8UMQ3GHA8FbYqLRQjq7nqchMl6pyzVHgybE)blw(D)zjStbGWSCDwsaxS4dXcC94dKyHc6lctS8qwGLoblGWNLFNgIf4WYHQGdXYVFywSC)olBqn(VazVHWNC5PK9gi8ZW1Jpqktb9fHj73o2ahBRAVrLRQjq7yAV5H)GL9wkew9Bi7TWCpnNBVnuFi8URQjwuWslwux9UHc6lctzmu7JzOu)kmlXZYqP(vywAAyrD17gkOVimL1RYhZqP(vywINLHs9RWS00WccFoxvtgq4NHRhFGuMc6lctS0MffSmuFi8URQjwuWY7dk6n)Ls5hMbpIL4zrzaXIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBaMTvT3OYv1eODmT38WFWYEdVQ(nK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmlnnSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywAAybHpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmGyrblEuoStbGyrbli85CvnzaHFEOyyDdLs1JT3cjcAk)(GIESDSv2(TJnaX2Q2Bu5QAc0oM2BE4pyzVHFsR9j31(q2BH5EAo3EBO(q4DxvtSOGLwSOU6Ddf0xeMYyO2hZqP(vywINLHs9RWS00WI6Q3nuqFrykRxLpMHs9RWSepldL6xHzPPHfe(CUQMmGWpdxp(aPmf0xeMyPnlkyzO(q4DxvtSOGL3hu0B(lLYpmdEelXZIYahwuWIhLd7uaiwuWccFoxvtgq4Nhkgw3qPu9y7TqIGMYVpOOhBhBLTF7yJuSTQ9gvUQMaTJP9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7naaMybadgBwGflbqwSC)oC9Se8OORqzVfM7P5C7npkh2Paq2VDSvojBRAVrLRQjq7yAV5H)GL9gLgbTqtwfwG2BGeomx0FWYEdaGjwaUFf4qGSSfDZ9ywSC)olELGfnSqXcvWfQDw0o(VcflOFqFryIfVaz5NeS8qw0xrSCplRiwSC)ola0Lg7dlEbYcAIlsSYkyVfM7P5C7TwS0If1vVBOG(IWugd1(ygk1VcZs8SOCsS00WI6Q3nuqFrykRxLpMHs9RWSeplkNelTzrblbiudcTuMGNVkygk1VcZs8SeNKyrblTyrD17MO5sHd456SpbVUqoAPX(yq46fXcGzbqOxsS00WI1SmRI6WbfzIMlfoGNRZ(e86c5OLg7JHIH1ffrGS0ML2S00WI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIL4vIfabWsILMgwcqOgeAPmbpFvWmKdMGffS44FCDocAHgwINfKss2VDSvwzBRAVrLRQjq7yAVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3SMfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcwAXslwcqOgeAPmuAuIHCDgoGLxbYmuQFfMfaZIYahaglaJLwSOSYSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWcfdRlkIanuAuIHCDgoGLxbIL2S00WIJ)X15iOfAyjELybPKelkyPflwZY7AQEtFnjYWEM0RImu5QAcKLMgwux9Uj45RcgW14)blwINLaeQbHwktFnjYWEM0RImdL6xHzbySaqyPnlkybHpNRQjZVpNwNXebenzl(9SOGLwSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelnnSynlbicQ86naLyoVyPnlky59bf9M)sP8dZGhXs8SOU6DtWZxfmGRX)dwSa8SKKbGXstdlQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWILMgwcqeu51BQd1(N7oXstdlQRE3OQHqq9c)MvelkyrD17gvnecQx43muQFfMfaZI6Q3nbpFvWaUg)pyXcWyPflifwaEwMvrD4GImrZLchWZ1zFcEDHC0sJ9XqXW6IIiqwAZsBwuWI1SOU6DtWZxfmRiwuWslwSMLaebvE9M6qT)5UtS00Wsac1GqlLjaleqGO8VtzC0n3JnRiwAAyrfIXSOGL(HA)ZdL6xHzbWSeGqni0szcWcbeik)7ughDZ9yZqP(vywaglahwAAyPFO2)8qP(vywqQSOmajjwamlQRE3e88vbd4A8)GflTT3ajCyUO)GL9gaatSGM4IeRScSy5(DwqdSqabIqcW9RahcKLTOBUhZIxGSacl09SarqJL5EIfa6sJ9Hf4WILDQyjMAieuVWplwGlnileYJUHyrL6WHybnXfjwzfyHqE0ne2EdHp5Ytj7TayoalW7pyLXV9BhBLbKTvT3OYv1eODmT38WFWYEBCeubx4CFOkwjS3ajCyUO)GL9gaatS87elX4P63tmSy5(DwCwqtCrIvwbw(D)z5Wf6Ew6dmLfa6sJ9XElm3tZ52BQRE3e88vbZqP(vywINfLrglnnSOU6DtWZxfmGRX)dwSaywItsSOGfe(CUQMmbWCawG3FWkJF73o2khhBRAVrLRQjq7yAVfM7P5C7ne(CUQMmbWCawG3FWkJFwuWslwSMf1vVBcE(QGbCn(FWIL4zjojXstdlwZsaIGkVEdcQ(9edlTzPPHf1vVBghbvWfo3hQIvcZkIffSOU6DZ4iOcUW5(qvSsygk1VcZcGzbPWcWyjalW19MOHchMYU(qvPu9M)sPmcxViwaglTyXAwux9UrvdHG6f(nRiwuWI1S8UMQ3GFF0Wb0qLRQjqwABV5H)GL9wG0e(pxND9HQsP6TF7yRm6zBv7nQCvnbAht7TWCpnNBVHWNZv1KjaMdWc8(dwz8BV5H)GL92vbFk)pyz)2XwzKzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M1SeGqni0szcE(QGzihmblnnSynli85CvnzcWcbeikds4evGffSeGiOYR3uhQ9p3DILMgwaN1bAkyoaIT3ajCyUO)GL9wmEFoxvtSSWeilWIfx903FeMLF3FwS41ZYdzrLyb7iiqw6WHf0exKyLvGfmKLF3Fw(Dkbl(q1ZIfh)eila3SWplQuhoel)oLAVHWNC5PK9g2rq5oCYbpFvW(TJTYahBRAVrLRQjq7yAV5H)GL9wFnjYWEM0RIS3ajCyUO)GL9gaatywaWGOplxNLRyXlwq)G(IWelEbYYphHz5HSOVIy5EwwrSy5(DwaOln2h0YcAIlsSYkWIxGSexqp6peelBw8j1Elm3tZ52BuqFryYCv2ReSOGfpkh2PaqSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaHEjXIcwAXci8noOh9hckJT4tAg0tDuK5VaqxHILMgwSMLaebvE9MIcdudhqwAZIcwq4Z5QAYGDeuUdNCWZxfyrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcsHfailTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsB73o2kdWSTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEdaGjwaWx0VZY27t31AwIgyaZY1zz79P7AnlhUq3ZYkYElm3tZ52BQRE3al63X5iAcu0FWYSIyrblQRE3GFF6UwBgQpeE3v1K9BhBLbi2w1EJkxvtG2X0Elm3tZ52BQRE3GFF0Wb0muQFfMfaZcYyrblTyrD17gkOVimLXqTpMHs9RWSepliJLMgwux9UHc6lctz9Q8XmuQFfML4zbzS0MffS44FCDocAHgwINfKss2BE4pyzVf8kq6S6Q3T3ux9EU8uYEd)(OHdO9BhBLrk2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVfJwPrywIlgGYIk1HdXcAGfciqell8vOy53jwqdSqabIyjalW7pyXYdzjStbGy56SGgyHaceXYHzXd)Y16eS4QW1ZYdzrLyj443Elm3tZ52BbicQ86n1HA)ZDNyrbli85CvnzcWcbeikds4evGffSeGqni0szcWcbeik)7ughDZ9yZqP(vywamliJffSynlGZ6anfmhaXSOGfkOVimzUk7vcwuWIJ)X15iOfAyjEwqVKSF7ydOKSTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEdaGjw2EF6UwZIL73zz7jT2hwIrZ1Fw8cKLcYY27JgoGOLfl7uXsbzz79P7AnlhMLveAzjbCXIpelxXIvSkFyb9d6lctS0HdlaeGHPaMf4WYdzjAGbwaOln2hwSStflUkebXcsjjwIlgGYcCyXbJ8)qqSGT4tkl7oMfacWWuaZYqP(vxHIf4WYHz5kw66d1(Byj2WNy539NLvbsdl)oXc2tjwcWc8(dwywUhDywaJWSu06hxZYdzz79P7AnlGR5kuSeJ5iOcUWSaGnufReOLfl7uXsc4cDGSG)tRzHkqwwrSy5(DwqkjbmhhXshoS87elAh)SGsdvDn2yVfM7P5C7T31u9g8tATpzW56VHkxvtGSOGfRz5DnvVb)(OHdOHkxvtGSOGf1vVBWVpDxRnd1hcV7QAIffS0If1vVBOG(IWuwVkFmdL6xHzjEwaiSOGfkOVimzUkRxLpSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaHSKyPPHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelXRelaczjXIcwC8pUohbTqdlXZcsjjwAAybe(gh0J(dbLXw8jnd6PokYmuQFfML4zbGWstdlE4pyzCqp6peugBXN0mON6OiZv5U(qT)S0MffSeGqni0szcE(QGzOu)kmlXZIYjz)2XgqkBBv7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9gaatSS9(GxdkIfa8f97SenWaMfVazbCLgXsCXauwSStflOjUiXkRalWHLFNyjgpv)EIHf1vVZYHzXvHRNLhYs31AwG9olWHLeWf6azj4rSexma1Elm3tZ52BQRE3al63X5GM8jJ4WhSmRiwAAyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwAAyrD17MGNVkywrSOGLwSOU6DZ4iOcUW5(qvSsygk1VcZcGzbva0K6iNfGNLaDAwAXIJ)X15iOfAybjSeNKyPnlaJL4WcWZY7AQEtrwYPqyzOYv1eilkyXAwMvrD4GIm4R6lDEpb(P5CdvUQMazrblQRE3mocQGlCUpufReMvelnnSOU6DtWZxfmdL6xHzbWSGkaAsDKZcWZsGonlTyXX)46Ce0cnSGewItsS0MLMgwux9UzCeubx4CFOkwjY4R6lDEpb(P5CZkILMgwAXI6Q3nJJGk4cN7dvXkHzOu)kmlaMfp8hSm43N(nKHqofwpL)lLyrbl4isRZ7o(jwamljzqpwAAyrD17MXrqfCHZ9HQyLWmuQFfMfaZIh(dwglJ)7gc5uy9u(VuILMgwq4Z5QAYCXayoalW7pyXIcwcqOgeAPmxHdZ6DvnLJHLx)kndsiUazgYbtWIcwOyyDrreO5kCywVRQPCmS86xPzqcXfiwAZIcwux9UzCeubx4CFOkwjmRiwAAyXAwux9UzCeubx4CFOkwjmRiwuWI1SeGqni0szghbvWfo3hQIvcZqoycwAAyXAwcqeu51Bqq1VNyyPnlnnS44FCDocAHgwINfKssSOGfkOVimzUk7vc73o2acq2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVz1jblpKLuhiILFNyrLWplWolBVpA4aYIAcwWVha6kuSCplRiwIH1fasNGLRyXReSG(b9fHjwuxpla0Lg7dlhUEwCv46z5HSOsSenWqGaT3cZ90CU927AQEd(9rdhqdvUQMazrblwZYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPflQRE3GFF0Wb0SIyPPHfh)JRZrql0Ws8SGusIL2SOGf1vVBWVpA4aAWVhaIfaZsCyrblTyrD17gkOVimLXqTpMvelnnSOU6Ddf0xeMY6v5JzfXsBwuWI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIfaZcGayjXIcwAXsac1GqlLj45RcMHs9RWSeplkNelnnSynli85CvnzcWcbeikds4evGffSeGiOYR3uhQ9p3DIL22VDSbuCSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEJc6lctMRY6v5dlaplaewqclE4pyzWVp9BidHCkSEk)xkXcWyXAwOG(IWK5QSEv(WcWZslwaoSamwExt1BWWLod75FNYD4q43qLRQjqwaEwIdlTzbjS4H)GLXY4)UHqofwpL)lLybySKKb9qgliHfCeP15Dh)elaJLKmiJfGNL31u9MY)1q4SQR9kqgQCvnbAVbs4WCr)bl7n0h)xQ)eMLDOfwsxHDwIlgGYIpelO8RiqwIOHfmfGfO9gcFYLNs2BoocGsZgfSF7ydi0Z2Q2Bu5QAc0oM2BE4pyzVHFFWRbfzVbs4WCr)bl7Ty0knILT3h8AqrSCflolamGHPalBqTpSG(b9fHj0YciSq3ZIMEwUNLObgybGU0yFyP1V7plhMLDVa1eilQjyHUFNgw(DILT3NUR1SOVIyboS87elXfdqJhPKel6Riw6WHLT3h8AqrTrllGWcDplqe0yzUNyXlwaWx0VZs0adS4filA6z53jwCvicIf9vel7EbQjw2EF0Wb0Elm3tZ52BwZYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPflQRE3enxkCapxN9j41fYrln2hdcxViwamlacGLelnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaiKLelky5DnvVb)Kw7tgCU(BOYv1eilTzrblTyHc6lctMRYyO2hwuWIJ)X15iOfAybySGWNZv1KXXrauA2OalaplQRE3qb9fHPmgQ9XmuQFfMfGXci8n91Kid7zsVkY8xaiCEOu)kwaEwaKbzSeplaKKyPPHfkOVimzUkRxLpSOGfh)JRZrql0WcWybHpNRQjJJJaO0SrbwaEwux9UHc6lctz9Q8XmuQFfMfGXci8n91Kid7zsVkY8xaiCEOu)kwaEwaKbzSepliLKyPnlkyXAwux9Ubw0VJZr0eOO)GLzfXIcwSML31u9g87JgoGgQCvnbYIcwAXsac1GqlLj45RcMHs9RWSeplamwAAybdxA1Ran)(CADgteq0yOYv1eilkyrD17MFFoToJjciAm43daXcGzjoXHfailTyzwf1HdkYGVQV059e4NMZnu5QAcKfGNfKXsBwuWs)qT)5Hs9RWSeplkNusSOGL(HA)ZdL6xHzbWSaOKsIL2SOGLwSeGqni0sza6kWHaZ4OBUhBgk1VcZs8SaWyPPHfRzjarqLxVbOeZ5flTTF7ydiKzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSyfRYhwq)G(IWelEbYc2rqSeJRR7adaBP1SaGdclw6WHf0exKyLvGfVazb4(vGdbYc6NgbTqtkvV9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelnnS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGmwAZstdlHDFqrywuIL4WsBwuWIhLd7uaiwuWccFoxvtgSJGYD4KdE(QG9BhBabCSTQ9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelkyXAwcqeu51BakXCEXstdlTyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwuWsaIGkVEdqjMZlwAZstdlTyjS7dkcZIsSaiwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS00WI6Q3nbpFvWSIyPnlkyXJYHDkaelkybHpNRQjd2rq5oCYbpFvGffS0If1vVBghbvWfo3hQIvcZqP(vywamlTybzSaazbqSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsB7np8hSS32DDpNcHL9BhBabWSTQ9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelkyXAwcqeu51BakXCEXstdlTyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwuWsaIGkVEdqjMZlwAZstdlTyjS7dkcZIsSaiwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS00WI6Q3nbpFvWSIyPnlkyXJYHDkaelkybHpNRQjd2rq5oCYbpFvGffS0If1vVBghbvWfo3hQIvcZqP(vywamliJffSOU6DZ4iOcUW5(qvSsywrSOGfRzzwf1HdkYGVQV059e4NMZnu5QAcKLMgwSMf1vVBghbvWfo3hQIvcZkIL22BE4pyzV1xADofcl73o2acGyBv7nQCvnbAht7nqchMl6pyzVbaWelaxq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF7ydiKITvT3OYv1eODmT38WFWYEd)(0VHS3ajCyUO)GL9gaatSS9(0VHy5HSenWalBqTpSG(b9fHj0YcAIlsSYkWYUJzrtyml)LsS87EXIZcW14)oleYPW6jw0u)zboSalDcwSIv5dlOFqFryILdZYkYElm3tZ52BuqFryYCvwVkFyPPHfkOVimzWqTp5Iq(ZstdluqFryY4vICri)zPPHLwSOU6DJfFMdozypt6vrMvelnnSGJiToV74NybWSKKb9qglkyXAwcqeu51Bqq1VNyyPPHfCeP15Dh)elaMLKmOhlkyjarqLxVbbv)EIHL2SOGf1vVBOG(IWuwVkFmRiwAAyPflQRE3e88vbZqP(vywamlE4pyzSm(VBiKtH1t5)sjwuWI6Q3nbpFvWSIyPT9Bh74KKTvT3OYv1eODmT3ajCyUO)GL9gaatSaCn(VZc83PXYHjwSSFHDwomlxXYgu7dlOFqFrycTSGM4IeRScSahwEilrdmWIvSkFyb9d6lct2BE4pyzVzz8F3(TJDCu22Q2Bu5QAc0oM2BGeomx0FWYEdaZ16FFw2BE4pyzVnRk7H)GvwF43EtF4pxEkzV1DT(3NL9B)2BrdfGPQ(BBv7yRSTvT38WFWYEdORahcmJJU5ES9gvUQMaTJP9BhBazBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9ws2BGeomx0FWYEZQ7eli85CvnXYHzbtplpKLKyXY97SuqwWV)SalwwyILFUci6XOLfLzXYovS87el9BWplWIy5WSalwwycTSaiwUol)oXcMcWcKLdZIxGSehwUolQWFNfFi7ne(KlpLS3GvEHP8pxbe92VDSJJTvT3OYv1eODmT3Gr2BoiO9Mh(dw2Bi85CvnzVHW1lYEtz7TWCpnNBV9ZvarV5v2S748ctz1vVZIcw(5kGO38kBcqOgeAPmGRX)dwSOGfRz5NRaIEZRS5WMhMszypNcl8pWfohGf(Nv4pyHT3q4tU8uYEdw5fMY)Cfq0B)2Xg9STQ9gvUQMaTJP9gmYEZbbT38WFWYEdHpNRQj7neUEr2BaYElm3tZ52B)Cfq0BEaz2DCEHPS6Q3zrbl)Cfq0BEazcqOgeAPmGRX)dwSOGfRz5NRaIEZdiZHnpmLYWEofw4FGlCoal8pRWFWcBVHWNC5PK9gSYlmL)5kGO3(TJnYSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHWNC5PK9gSYlmL)5kGO3Elm3tZ52BumSUOic0CfomR3v1uogwE9R0miH4celnnSqXW6IIiqdLgLyixNHdy5vGyPPHfkgwxuebAWWLwt)FfQ8SutyVbs4WCr)bl7nRUtyILFUci6XS4dXsbFw81dt9)cUwNGfq6PWtGS4ywGfllmXc(9NLFUci6XgwyzJEwq4Z5QAILhYc6XIJz53PeS4AmKLIiqwWru4Cnl7EbQVcLXEdHRxK9g6z)2Xg4yBv7np8hSS3sHWcORYD4KAVrLRQjq7yA)2XgGzBv7nQCvnbAht7np8hSS3Sm(VBVfM7P5C7TwSqb9fHjJEv(Klc5plnnSqb9fHjZvzmu7dlnnSqb9fHjZvzv4VZstdluqFryY4vICri)zPT9M(kkhaT3uoj73(TF7ne0GpyzhBaLeGuojagGqM9MfFQRqHT3aUIBmwSTYydClaNfwS6oXYLgbNNLoCybDWiQObDSmumSUHazbdtjw81dt9NazjS7fkcB4KTIRiwaeaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4KTIRiwIdaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4K5KbUIBmwSTYydClaNfwS6oXYLgbNNLoCybDGu3x6hDSmumSUHazbdtjw81dt9NazjS7fkcB4KTIRiwqgaNf0ale08eilBxkAybNOEh5SGuz5HSyflNfWdXHpyXcmIg)HdlTqsBwAPmYBB4KTIRiwqgaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4KTIRiwaoaCwqdSqqZtGSGUzvuhoOidacDS8qwq3SkQdhuKbazOYv1ei6yPLYiVTHt2kUIybGbWzbnWcbnpbYY2LIgwWjQ3rolivwEilwXYzb8qC4dwSaJOXF4WslK0MLwac5TnCYwXvelaeaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjBfxrSaqa4SGgyHGMNazbD)Cfq0Bu2aGqhlpKf09ZvarV5v2aGqhlTaeYBB4KTIRiwaiaCwqdSqqZtGSGUFUci6naYaGqhlpKf09ZvarV5bKbaHowAbiK32WjBfxrSGua4SGgyHGMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrEBdNSvCfXIYjbWzbnWcbnpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJ82gozR4kIfLvgGZcAGfcAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTug5TnCYwXvelkdiaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjBfxrSOm6bWzbnWcbnpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJ82gozR4kIfLrgaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAbiK32WjBfxrSOmYa4SGgyHGMNazbD)Cfq0Bu2aGqhlpKf09ZvarV5v2aGqhlTaeYBB4KTIRiwugzaCwqdSqqZtGSGUFUci6naYaGqhlpKf09ZvarV5bKbaHowAPmYBB4KTIRiwug4aWzbnWcbnpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwac5TnCYwXvelkdCa4SGgyHGMNazbD)Cfq0Bu2aGqhlpKf09ZvarV5v2aGqhlTug5TnCYwXvelkdCa4SGgyHGMNazbD)Cfq0BaKbaHowEilO7NRaIEZdidacDS0cqiVTHtMtg4kUXyX2kJnWTaCwyXQ7elxAeCEw6WHf0fnuaMQ6p6yzOyyDdbYcgMsS4RhM6pbYsy3lue2WjBfxrSehaolObwiO5jqwq3pxbe9gLnai0XYdzbD)Cfq0BELnai0XsR4G82gozR4kIf0dGZcAGfcAEcKf09ZvarVbqgae6y5HSGUFUci6npGmai0XsR4G82gozozGR4gJfBRm2a3cWzHfRUtSCPrW5zPdhwqNdj0XYqXW6gcKfmmLyXxpm1FcKLWUxOiSHt2kUIyrzaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS4plOpaERGLwkJ82gozR4kIL4aWzbnWcbnpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJ82gozR4kIfagaNf0ale08eilBxkAybNOEh5SGurQS8qwSILZskeCPxywGr04pCyPfsTnlTug5TnCYwXvelamaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0cqiVTHt2kUIybGaWzbnWcbnpbYY2LIgwWjQ3rolivKklpKfRy5SKcbx6fMfyen(dhwAHuBZslLrEBdNSvCfXcabGZcAGfcAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTug5TnCYwXvelifaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjBfxrSOCsaCwqdSqqZtGSSDPOHfCI6DKZcsLLhYIvSCwapeh(GflWiA8hoS0cjTzPfGqEBdNSvCfXIYXbGZcAGfcAEcKLTlfnSGtuVJCwqQS8qwSILZc4H4WhSybgrJ)WHLwiPnlTug5TnCYwXvelakjaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjBfxrSaiabWzbnWcbnpbYY2LIgwWjQ3rolivwEilwXYzb8qC4dwSaJOXF4WslK0MLwkJ82gozR4kIfaHEaCwqdSqqZtGSSDPOHfCI6DKZcsLLhYIvSCwapeh(GflWiA8hoS0cjTzPfGqEBdNSvCfXcGqpaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjBfxrSaiGdaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4KTIRiwaeadGZcAGfcAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTug5TnCYwXvelacPaWzbnWcbnpbYY2LIgwWjQ3rolivwEilwXYzb8qC4dwSaJOXF4WslK0MLwac5TnCYwXvelXjjaolObwiO5jqw2Uu0Wcor9oYzbPYYdzXkwolGhIdFWIfyen(dhwAHK2S0szK32WjZjdCf3ySyBLXg4waolSy1DILlncoplD4Wc66Uw)7ZcDSmumSUHazbdtjw81dt9NazjS7fkcB4KTIRiwaeaNf0ale08eilBxkAybNOEh5SGuz5HSyflNfWdXHpyXcmIg)HdlTqsBwAPmYBB4K5KbUIBmwSTYydClaNfwS6oXYLgbNNLoCybD4hDSmumSUHazbdtjw81dt9NazjS7fkcB4KTIRiwugGZcAGfcAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTug5TnCYwXvelXbGZcAGfcAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTug5TnCYwXvelkRmaNf0ale08eilBxkAybNOEh5SGurQS8qwSILZskeCPxywGr04pCyPfsTnlTug5TnCYwXvelkRmaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4KTIRiwug4aWzbnWcbnpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJ82gozR4kIfaPmaNf0ale08eilBxkAybNOEh5SGuz5HSyflNfWdXHpyXcmIg)HdlTqsBwAbiK32WjBfxrSaiLb4SGgyHGMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrEBdNSvCfXcGaeaNf0ale08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYBB4KTIRiwauCa4SGgyHGMNazz7srdl4e17iNfKklpKfRy5SaEio8blwGr04pCyPfsAZsR4G82gozR4kIfaHEaCwqdSqqZtGSGUzvuhoOidacDS8qwq3SkQdhuKbazOYv1ei6yPfGqEBdNSvCfXcGaoaCwqdSqqZtGSGUzvuhoOidacDS8qwq3SkQdhuKbazOYv1ei6yPLYiVTHt2kUIybqamaolObwiO5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK32WjZjdCf3ySyBLXg4waolSy1DILlncoplD4Wc6uH(Jowgkgw3qGSGHPel(6HP(tGSe29cfHnCYwXvelkdqa4SGgyHGMNazz7srdl4e17iNfKklpKfRy5SaEio8blwGr04pCyPfsAZsR4G82gozR4kIfLrkaCwqdSqqZtGSSDPOHfCI6DKZcsLLhYIvSCwapeh(GflWiA8hoS0cjTzPLYiVTHtMt2ktJGZtGSaWyXd)blw0h(Xgoz7TOb2pnzVH0inlX01EfiwIrZ6a5KrAKMLKx6eSaiKHwwausaszozozKgPzbn7EHIWaCozKgPzbaYsCbbjqw2GAFyjMKNA4KrAKMfailOz3lueilVpOOpFDwcoMWS8qwcjcAk)(GIESHtgPrAwaGSeJrPqeeilRQOaHX(KGfe(CUQMWS06mKbTSeneIm(9bVguelaW4zjAieg87dEnOO2gozKgPzbaYsCrapqwIgk44)kuSaCn(VZY1z5E0Hz53jwSmWcflOFqFryYWjJ0inlaqwaW5arSGgyHaceXYVtSSfDZ9ywCw03)AILu4qS01eYpvnXsRRZsc4ILDhSq3ZY(9SCpl4lDPFVi4cRtWIL73zjMa4JRvzbySGgst4)CnlXvFOQuQE0YY9OdKfmqxuBdNmsJ0SaazbaNdeXske)SGU(HA)ZdL6xHrhl4av(CqmlEuKoblpKfvigZs)qT)ywGLoHHtgPrAwaGSy1H8NfRctjwGDwIP23zjMAFNLyQ9DwCmlol4ikCUMLFUci6nCYinsZcaKfa8rurdlTodzqllaxJ)7OLfGRX)D0YY27t)gQnlPoiXskCiwgcF6JQNLhYc5J(OHLamv1Fai(95nCYCYinsZsCRc((tGSetx7vGyjUauRGLGxSOsS0HRcKf)zz))imahjir11Efiai(sdgu3VVunhejX01Efia42LIgKKcA2)uDmo7NMus11EfiZJ8NtMt2d)blSjAOamv1FLa6kWHaZ4OBUhZjJ0Sy1DIfe(CUQMy5WSGPNLhYssSy5(Dwkil43FwGfllmXYpxbe9y0YIYSyzNkw(DIL(n4NfyrSCywGfllmHwwaelxNLFNybtbybYYHzXlqwIdlxNfv4VZIpeNSh(dwyt0qbyQQ)atjKGWNZv1eAlpLucw5fMY)Cfq0JweUErkLeNSh(dwyt0qbyQQ)atjKGWNZv1eAlpLucw5fMY)Cfq0JwyKsoiiAr46fPKYO96k9ZvarVrzZUJZlmLvx9UIFUci6nkBcqOgeAPmGRX)dwkS(NRaIEJYMdBEykLH9CkSW)ax4Caw4FwH)GfMt2d)blSjAOamv1FGPesq4Z5QAcTLNskbR8ct5FUci6rlmsjheeTiC9IucqO96k9ZvarVbqMDhNxykRU6Df)Cfq0BaKjaHAqOLYaUg)pyPW6FUci6naYCyZdtPmSNtHf(h4cNdWc)Zk8hSWCYinlwDNWel)Cfq0JzXhILc(S4RhM6)fCToblG0tHNazXXSalwwyIf87pl)Cfq0JnSWYg9SGWNZv1elpKf0JfhZYVtjyX1yilfrGSGJOW5Aw29cuFfkdNSh(dwyt0qbyQQ)atjKGWNZv1eAlpLucw5fMY)Cfq0JwyKsy6rlcxViLqp0EDLOyyDrreO5kCywVRQPCmS86xPzqcXfOMgkgwxuebAO0Oed56mCalVcutdfdRlkIany4sRP)VcvEwQj4K9WFWcBIgkatv9hykHKuiSa6QChoPCYE4pyHnrdfGPQ(dmLqILX)D0QVIYbqLuoj0EDLArb9fHjJEv(Klc5Ftdf0xeMmxLXqTpnnuqFryYCvwf(7nnuqFryY4vICri)BZjZjJ0Saqhk44NfaXcW14)olEbYIZY27dEnOiwGflBwLfl3VZsSpu7playoXIxGSetyCTklWHLT3N(nelWFNglhM4K9WFWcBGrurdWucjwg)3r71vQff0xeMm6v5tUiK)nnuqFryYCvgd1(00qb9fHjZvzv4V30qb9fHjJxjYfH8VTIOHqyu2yz8FxH1rdHWaiJLX)Dozp8hSWgyev0amLqc(9PFdHw9vuoaQeYq71vY6zvuhoOiJQR9kqzyp7AD(3VcfUPX6aebvE9M6qT)5UtnnwJJiTo)(GIESb)(0DTwjLBAS(DnvVP8FneoR6AVcKHkxvtGnnTOG(IWKbd1(Klc5Ftdf0xeMmxL1RYNMgkOVimzUkRc)9MgkOVimz8krUiK)T5K9WFWcBGrurdWucj43h8AqrOvFfLdGkHm0EDLMvrD4GImQU2RaLH9SR15F)kuyfbicQ86n1HA)ZDNuGJiTo)(GIESb)(0DTwjL5K5KrAKMf0h5uy9eilecAsWYFPel)oXIhE4WYHzXr4N2v1KHt2d)blSsyO2NSk5PCYE4pyHbMsij4AD2d)bRS(WpAlpLucgrfnO96k9xkb4wac49WFWYyz8F3eC8N)lLaMh(dwg87t)gYeC8N)lLAZjJ0SSrpML4crFwGflXbySy5(D46zbCU(ZIxGSy5(Dw2EF0WbKfVazbqaJf4VtJLdtCYE4pyHbMsibHpNRQj0wEkP0HZoKqlcxViLWrKwNFFqrp2GFF6UwhVYkAz97AQEd(9rdhqdvUQMaBAExt1BWpP1(KbNR)gQCvnb2UPbhrAD(9bf9yd(9P7AD8aItgPzzJEmlbn5iiwSStflBVp9BiwcEXY(9SaiGXY7dk6XSyz)c7SCywgsti86zPdhw(DIf0pOVimXYdzrLyjAOondbYIxGSyz)c7S0pTMgwEilbh)CYE4pyHbMsibHpNRQj0wEkP0HZbn5ii0IW1lsjCeP153hu0Jn43N(nu8kZjJ0SaaWelXKgmnaDfkwSC)olOjUiXkRalWHfV)0WcAGfciqelxXcAIlsSYkWj7H)GfgykHevAW0a0vOq71vQvlRdqeu51BQd1(N7o10yDac1GqlLjaleqGO8VtzC0n3JnRO2kux9Uj45RcMHs9RWXRmYuOU6DZ4iOcUW5(qvSsygk1Vcdy0tH1bicQ86niO63tmnnbicQ86niO63tmkux9Uj45RcMvKc1vVBghbvWfo3hQIvcZksrl1vVBghbvWfo3hQIvcZqP(vyaRSYaqKb8ZQOoCqrg8v9LoVNa)0CEtJ6Q3nbpFvWmuQFfgWkRCtJYivCeP15Dh)eGv2GmK1UTcubqZqP(v44tItgPzbGcFwSC)ololOjUiXkRal)U)SC4cDplola0Lg7dlrdmWcCyXYovS87el9d1(ZYHzXvHRNLhYcvGCYE4pyHbMsijc(hSq71vsD17MGNVkygk1VchVYitrlRNvrD4GIm4R6lDEpb(P58Mg1vVBghbvWfo3hQIvcZqP(vyaRmadaciGxD17gvnecQx43SIuOU6DZ4iOcUW5(qvSsywrTBAuHySI(HA)ZdL6xHbmGqgNmsZcACDyP9NWSyzN(DAyzHVcflObwiGarSuqlSy50AwCTgAHLeWflpKf8FAnlbh)S87elypLyXtHR6zb2zbnWcbeicyOjUiXkRalbh)yozp8hSWatjKGWNZv1eAlpLukaleqGOmiHtub0IW1lsPaD6wT6hQ9ppuQFfgaQmYaGbiudcTuMGNVkygk1Vc3gPQmajP2kfOt3Qv)qT)5Hs9RWaqLrgamaHAqOLYeGfciqu(3Pmo6M7XgW14)blayac1GqlLjaleqGO8VtzC0n3JndL6xHBJuvgGKuBfwp(bMjeu9gheeBiKF4h30eGqni0szcE(QGzOu)kC8x90eb1(tG5(HA)ZdL6xHBAcqOgeAPmbyHaceL)DkJJU5ESzOu)kC8x90eb1(tG5(HA)ZdL6xHbGkNutJ1bicQ86n1HA)ZDN4KrAwaaycKLhYciP9eS87ellSJIyb2zbnXfjwzfyXYovSSWxHIfq4svtSalwwyIfVazjAieu9SSWokIfl7uXIxS4GGSqiO6z5WS4QW1ZYdzb8iozp8hSWatjKGWNZv1eAlpLukaMdWc8(dwOfHRxKsT6hQ9ppuQFfoELrwtZ4hyMqq1BCqqS5Q4rwsTv0QvlkgwxuebAO0Oed56mCalVcKIwbiudcTugknkXqUodhWYRazgk1VcdyLboj10eGiOYR3GGQFpXOiaHAqOLYqPrjgY1z4awEfiZqP(vyaRmWbGbSwkRmWpRI6WbfzWx1x68Ec8tZ5TBRW6aeQbHwkdLgLyixNHdy5vGmd5GjA30qXW6IIiqdgU0A6)RqLNLAcfTSoarqLxVPou7FU7uttac1GqlLbdxAn9)vOYZsnrooOhYaijPSzOu)kmGvwz0RDttRaeQbHwkJknyAa6kuMHCWennwpEGm)a162kA1IIH1ffrGMRWHz9UQMYXWYRFLMbjexGu0kaHAqOLYCfomR3v1uogwE9R0miH4cKzihmrtJh(dwMRWHz9UQMYXWYRFLMbjexGmGh2v1ey72nnTOyyDrreObV7GqleygoQzyp)WjLQxrac1GqlL5HtkvpbMVcFO2)CCqgYIdGu2muQFfUDttRwi85CvnzGvEHP8pxbe9kPCtdcFoxvtgyLxyk)ZvarVsXPTIw)Cfq0Bu2mKdMihGqni0s108ZvarVrztac1GqlLzOu)kC8x90eb1(tG5(HA)ZdL6xHbGkNu7Mge(CUQMmWkVWu(NRaIELaKIw)Cfq0BaKzihmroaHAqOLQP5NRaIEdGmbiudcTuMHs9RWXF1tteu7pbM7hQ9ppuQFfgaQCsTBAq4Z5QAYaR8ct5FUci6vkP2TB30eGiOYR3auI58QDtJkeJv0pu7FEOu)kmGvx9Uj45RcgW14)blozKMLy8(CUQMyzHjqwEilGK2tWIxjy5NRaIEmlEbYsaeZILDQyXIF)vOyPdhw8If0FfTdNZzjAGbozp8hSWatjKGWNZv1eAlpLu63NtRZyIaIMSf)E0IW1lsjRXWLw9kqZVpNwNXebengQCvnb200pu7FEOu)kC8akPKAAuHySI(HA)ZdL6xHbmGqgWAHEjbavx9U53NtRZyIaIgd(9aqapGA30OU6DZVpNwNXebeng87bGIpoaeayRzvuhoOid(Q(sN3tGFAoh4rwBozKMfaaMyb9tJsmKRzba)awEfiwausykGzrL6WHyXzbnXfjwzfyzHjdNSh(dwyGPeswykFpLI2YtjLO0Oed56mCalVceAVUsbiudcTuMGNVkygk1VcdyaLKIaeQbHwktawiGar5FNY4OBUhBgk1VcdyaLKIwi85Cvnz(9506mMiGOjBXVVPrD17MFFoToJjciAm43dafFCscyTMvrD4GIm4R6lDEpb(P5CGh40UTcubqZqP(v44tQPrfIXk6hQ9ppuQFfgWXbGXjJ0SaaWelBWLwt)vOyjgBPMGfGdMcywuPoCiwCwqtCrIvwbwwyYWj7H)GfgykHKfMY3tPOT8usjmCP10)xHkpl1eO96k1kaHAqOLYe88vbZqP(vyadCuyDaIGkVEdcQ(9eJcRdqeu51BQd1(N7o10eGiOYR3uhQ9p3Dsrac1GqlLjaleqGO8VtzC0n3JndL6xHbmWrrle(CUQMmbyHaceLbjCIk00eGqni0szcE(QGzOu)kmGboTBAcqeu51Bqq1VNyu0Y6zvuhoOid(Q(sN3tGFAoxrac1GqlLj45RcMHs9RWag400OU6DZ4iOcUW5(qvSsygk1VcdyLrpG1czapfdRlkIanxH)zfE4GZGhIROSkP1TvOU6DZ4iOcUW5(qvSsywrTBAuHySI(HA)ZdL6xHbmGqwtdfdRlkIanuAuIHCDgoGLxbsrac1GqlLHsJsmKRZWbS8kqMHs9RWXhNKARava0muQFfo(K4KrAwIR2INaZYctSyLX4igXIL73zbnXfjwzf4K9WFWcdmLqccFoxvtOT8usPlgaZbybE)bl0IW1lsj1vVBcE(QGzOu)kC8kJmfTSEwf1HdkYGVQV059e4NMZBAux9UzCeubx4CFOkwjmdL6xHbSskdiG1koaV6Q3nQAieuVWVzf1gyTAbqaGid4vx9UrvdHG6f(nRO2apfdRlkIanxH)zfE4GZGhIROSkP1TvOU6DZ4iOcUW5(qvSsywrTBAuHySI(HA)ZdL6xHbmGqwtdfdRlkIanuAuIHCDgoGLxbsrac1GqlLHsJsmKRZWbS8kqMHs9RWCYE4pyHbMsizHP89ukAlpLu6kCywVRQPCmS86xPzqcXfi0EDLq4Z5QAYCXayoalW7pyPava0muQFfo(K4KrAwaayIL5qT)SOsD4qSeaXCYE4pyHbMsizHP89ukAlpLucV7GqleygoQzyp)WjLQhTxxPwbiudcTuMGNVkygYbtOW6aebvE9M6qT)5Utkq4Z5QAY87ZP1zmrart2IFFttaIGkVEtDO2)C3jfbiudcTuMaSqabIY)oLXr3Cp2mKdMqrle(CUQMmbyHaceLbjCIk00eGqni0szcE(QGzihmr72kaHVbVQ(nK5VaqxHsrlq4BWpP1(K7AFiZFbGUcvtJ1VRP6n4N0AFYDTpKHkxvtGnn4isRZVpOOhBWVp9BO4JtBfTaHVjfcR(nK5VaqxHQTIwi85CvnzoC2HutZSkQdhuKr11EfOmSNDTo)7xHc3044FCDocAHM4vcPKutJ6Q3nQAieuVWVzf1wrRaeQbHwkJknyAa6kuMHCWennwpEGm)a162nnQqmwr)qT)5Hs9RWag9sItgPzXQ7hMLdZIZY4)onSqAxfo(tSyXtWYdzj1bIyX1AwGfllmXc(9NLFUci6XS8qwujw0xrGSSIyXY97SGM4IeRScS4filObwiGarS4fillmXYVtSaOcKfSg(SalwcGSCDwuH)ol)Cfq0JzXhIfyXYctSGF)z5NRaIEmNSh(dwyGPeswykFpLIrlwdFSs)Cfq0RmAVUsTq4Z5QAYaR8ct5FUci6TwjLvy9pxbe9gazgYbtKdqOgeAPAAAHWNZv1Kbw5fMY)Cfq0RKYnni85CvnzGvEHP8pxbe9kfN2kAPU6DtWZxfmRifTSoarqLxVbbv)EIPPrD17MXrqfCHZ9HQyLWmuQFfgyTqgWpRI6WbfzWx1x68Ec8tZ5TbSs)Cfq0Bu2OU69m4A8)GLc1vVBghbvWfo3hQIvcZkQPrD17MXrqfCHZ9HQyLiJVQV059e4NMZnRO2nnbiudcTuMGNVkygk1Vcdmaf)pxbe9gLnbiudcTugW14)blfwRU6DtWZxfmRifTSoarqLxVPou7FU7utJ1i85CvnzcWcbeikds4evOTcRdqeu51BakXCE10eGiOYR3uhQ9p3DsbcFoxvtMaSqabIYGeorfueGqni0szcWcbeik)7ughDZ9yZksH1biudcTuMGNVkywrkA1sD17gkOVimL1RYhZqP(v44voPMg1vVBOG(IWugd1(ygk1VchVYj1wH1ZQOoCqrgvx7vGYWE2168VFfkCttl1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGucznnQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daPeaPD7Mg1vVBa6kWHaZuAe0cnPu9zQOb1flYSIA300pu7FEOu)kmGbusnni85CvnzGvEHP8pxbe9kLuBfOcGMHs9RWXNeNSh(dwyGPeswykFpLIrlwdFSs)Cfq0di0EDLAHWNZv1Kbw5fMY)Cfq0BTsasH1)Cfq0Bu2mKdMihGqni0s10GWNZv1Kbw5fMY)Cfq0ReGu0sD17MGNVkywrkAzDaIGkVEdcQ(9ettJ6Q3nJJGk4cN7dvXkHzOu)kmWAHmGFwf1HdkYGVQV059e4NMZBdyL(5kGO3aiJ6Q3ZGRX)dwkux9UzCeubx4CFOkwjmROMg1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIA30eGqni0szcE(QGzOu)kmWau8)Cfq0BaKjaHAqOLYaUg)pyPWA1vVBcE(QGzfPOL1bicQ86n1HA)ZDNAASgHpNRQjtawiGarzqcNOcTvyDaIGkVEdqjMZlfTSwD17MGNVkywrnnwhGiOYR3GGQFpX0UPjarqLxVPou7FU7Kce(CUQMmbyHaceLbjCIkOiaHAqOLYeGfciqu(3Pmo6M7XMvKcRdqOgeAPmbpFvWSIu0QL6Q3nuqFrykRxLpMHs9RWXRCsnnQRE3qb9fHPmgQ9XmuQFfoELtQTcRNvrD4GImQU2RaLH9SR15F)ku4MMwQRE3O6AVcug2ZUwN)9RqHZL)RHm43daPeYAAux9Ur11EfOmSNDTo)7xHcN9j4fzWVhasjas72TBAux9UbORahcmtPrql0Ks1NPIguxSiZkQPrfIXk6hQ9ppuQFfgWakPMge(CUQMmWkVWu(NRaIELsQTcubqZqP(v44tItgPzbaGjmlUwZc83PHfyXYctSCpLIzbwSea5K9WFWcdmLqYct57PumNmsZsmIchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1H5K9WFWcdmLqYSQSh(dwz9HF0wEkPKdj0I)5cVskJ2RRecFoxvtMdNDiXj7H)GfgykHKzvzp8hSY6d)OT8usjvO)Of)ZfELugTxxPzvuhoOiJQR9kqzyp7AD(3Vcf2qXW6IIiqozp8hSWatjKmRk7H)GvwF4hTLNskHFozozKMf046Ws7pHzXYo970WYVtSeJgYtd(h2PHf1vVZILtRzP7AnlWENfl3VFfl)oXsri)zj44Nt2d)blSXHKsi85CvnH2YtjLahYtZwoTo3DTod7D0IW1lsPwQRE38xkzbovgCipv9kqAmdL6xHbmQaOj1roWsYOCtJ6Q3n)LswGtLbhYtvVcKgZqP(vya7H)GLb)(0VHmeYPW6P8FPeWsYOSIwuqFryYCvwVkFAAOG(IWKbd1(Klc5Ftdf0xeMmELixeY)2TvOU6DZFPKf4uzWH8u1RaPXSIumRI6Wbfz(lLSaNkdoKNQEfinCYinlOX1HL2FcZILD63PHLT3h8AqrSCywSaNFNLGJ)RqXcebnSS9(0VHy5kwSIv5dlOFqFryIt2d)blSXHeWucji85CvnH2YtjLoufCOm(9bVgueAr46fPK1uqFryYCvgd1(OOfoI0687dk6Xg87t)gkEKP4DnvVbdx6mSN)Dk3HdHFdvUQMaBAWrKwNFFqrp2GFF63qXdWAZjJ0SaaWelObwiGarSyzNkw8NfnHXS87EXcYsIL4IbOS4fil6RiwwrSy5(DwqtCrIvwbozp8hSWghsatjKeGfciqu(3Pmo6M7XO96kzn4SoqtbZbqSIwTq4Z5QAYeGfciqugKWjQGcRdqOgeAPmbpFvWmKdMOPrD17MGNVkywrTv0sD17gkOVimL1RYhZqP(v44bonnQRE3qb9fHPmgQ9XmuQFfoEGtBfTSEwf1HdkYO6AVcug2ZUwN)9RqHBAux9Ur11EfOmSNDTo)7xHcNl)xdzWVhak(400OU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpau8XPDtJkeJv0pu7FEOu)kmGvojfwhGqni0szcE(QGzihmrBozKMfaaMybaBOkwjyXY97SGM4IeRScCYE4pyHnoKaMsizCeubx4CFOkwjq71vsD17MGNVkygk1VchVYiJtgPzbaGjw2wv)gILRyjYlqk9cSalw8kXVFfkw(D)zrFiimlkJEykGzXlqw0egZIL73zjfoelVpOOhZIxGS4pl)oXcvGSa7S4SSb1(Wc6h0xeMyXFwug9ybtbmlWHfnHXSmuQF1vOyXXS8qwk4ZYUJ4kuS8qwgQpeENfW1CfkwSIv5dlOFqFryIt2d)blSXHeWucj4v1VHqBirqt53hu0Jvsz0EDLAnuFi8URQPMg1vVBOG(IWugd1(ygk1Vcd44OGc6lctMRYyO2hfdL6xHbSYONI31u9gmCPZWE(3PChoe(nu5QAcSTI3hu0B(lLYpmdEu8kJEaqCeP153hu0Jb2qP(vyfTOG(IWK5QSxjAAgk1VcdyubqtQJ82CYinlaamXY2Q63qS8qw2DeelolO0qvxZYdzzHjwSYyCeJ4K9WFWcBCibmLqcEv9Bi0EDLq4Z5QAYCXayoalW7pyPiaHAqOLYCfomR3v1uogwE9R0miH4cKzihmHckgwxuebAUchM17QAkhdlV(vAgKqCbIt2d)blSXHeWucj43NUR1O96kz97AQEd(jT2Nm4C93qLRQjqfTux9Ub)(0DT2muFi8URQjfTWrKwNFFqrp2GFF6Uwd4400y9SkQdhuK5VuYcCQm4qEQ6vG00UP5DnvVbdx6mSN)Dk3HdHFdvUQMavOU6Ddf0xeMYyO2hZqP(vyahhfuqFryYCvgd1(OqD17g87t31AZqP(vyadWuGJiTo)(GIESb)(0DToELqV2kAz9SkQdhuKrNi4JJZDnr)vOYO0xAeMAA(lLqQiv0dzXRU6Dd(9P7ATzOu)kmWauBfVpOO38xkLFyg8O4rgNmsZcW197SS9Kw7dlXO56pllmXcSyjaYILDQyzO(q4DxvtSOUEwW)P1SyXVNLoCyXkse8XXSenWalEbYciSq3ZYctSOsD4qSGMye2WY2FAnllmXIk1HdXcAGfciqel4Rcel)U)Sy50AwIgyGfVG)onSS9(0DTMt2d)blSXHeWucj43NUR1O96k9UMQ3GFsR9jdox)nu5QAcuH6Q3n43NUR1MH6dH3DvnPOL1ZQOoCqrgDIGpoo31e9xHkJsFPryQP5VucPIurpKfp61wX7dk6n)Ls5hMbpk(4WjJ0SaCD)olXOH8u1RaPHLfMyz79P7AnlpKfGikILvel)oXI6Q3zrnblUgdzzHVcflBVpDxRzbwSGmwWuawGywGdlAcJzzOu)QRqXj7H)Gf24qcykHe87t31A0EDLMvrD4GIm)LswGtLbhYtvVcKgf4isRZVpOOhBWVpDxRJxP4OOL1QRE38xkzbovgCipv9kqAmRifQRE3GFF6UwBgQpeE3v1uttle(CUQMmGd5PzlNwN7UwNH9UIwQRE3GFF6UwBgk1Vcd4400GJiTo)(GIESb)(0DToEaP4DnvVb)Kw7tgCU(BOYv1eOc1vVBWVpDxRndL6xHbmYA3UnNmsZcACDyP9NWSyzN(DAyXzz79bVguellmXILtRzj4lmXY27t31AwEilDxRzb27OLfVazzHjw2EFWRbfXYdzbiIIyjgnKNQEfinSGFpaelRiozp8hSWghsatjKGWNZv1eAlpLuc)(0DToBbwFU7ADg27OfHRxKso(hxNJGwOjEassaWwkNeWRU6DZFPKf4uzWH8u1RaPXGFpauBayl1vVBWVpDxRndL6xHb(4GuXrKwN3D8taV1VRP6n4N0AFYGZ1FdvUQMaBdaBfGqni0szWVpDxRndL6xHb(4GuXrKwN3D8ta)7AQEd(jT2Nm4C93qLRQjW2aWwGW30xtImSNj9QiZqP(vyGhzTv0sD17g87t31AZkQPjaHAqOLYGFF6UwBgk1Vc3MtgPzbaGjw2EFWRbfXIL73zjgnKNQEfinS8qwaIOiwwrS87elQRENfl3VdxplAi(kuSS9(0DTMLv0FPelEbYYctSS9(GxdkIfyXc6bmwIjmUwLf87bGWSSQ)0SGES8(GIEmNSh(dwyJdjGPesWVp41GIq71vcHpNRQjd4qEA2YP15UR1zyVRaHpNRQjd(9P7AD2cS(C316mS3vyncFoxvtMdvbhkJFFWRbf100sD17gvx7vGYWE2168VFfkCU8FnKb)EaO4JttJ6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqXhN2kWrKwNFFqrp2GFF6Uwdy0tbcFoxvtg87t316Sfy95UR1zyVZjJ0SaaWelyl(KYcgYYV7pljGlwqrplPoYzzf9xkXIAcww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz539IL4Wc(9aqywGdla3SWplw2PIL4amwWVhacZcH8OBiozp8hSWghsatjK4GE0FiOm2IpPOnKiOP87dk6XkPmAVUsw)xaORqPWAp8hSmoOh9hckJT4tAg0tDuK5QCxFO2)Mgq4BCqp6peugBXN0mON6Oid(9aqaookaHVXb9O)qqzSfFsZGEQJImdL6xHbCC4KrAwIXO(q4DwaWbHv)gILRZcAIlsSYkWYHzzihmbAz53PHyXhIfnHXS87EXcYy59bf9ywUIfRyv(Wc6h0xeMyXY97SSbFam0YIMWyw(DVyr5Kyb(70y5WelxXIxjyb9d6lctSahwwrS8qwqglVpOOhZIk1HdXIZIvSkFyb9d6lctgwIrWcDpld1hcVZc4AUcfla3VcCiqwq)0iOfAsP6zzvAcJz5kw2GAFyb9d6lctCYE4pyHnoKaMsijfcR(neAdjcAk)(GIESskJ2RR0q9HW7UQMu8(GIEZFPu(HzWJIVvlLrpG1chrAD(9bf9yd(9PFdb8ac4vx9UHc6lctz9Q8XSIA3gydL6xHBJuBPmWExt1BElxLtHWcBOYv1eyBfTcqOgeAPmbpFvWmKdMqH1GZ6anfmhaXkAHWNZv1KjaleqGOmiHtuHMMaeQbHwktawiGar5FNY4OBUhBgYbt00yDaIGkVEtDO2)C3P2nn4isRZVpOOhBWVp9Bia3QfWba2sD17gkOVimL1RYhZkc4bu72aFlLb27AQEZB5QCkewydvUQMaB3wH1uqFryYGHAFYfH8VPPff0xeMmxLXqTpnnTOG(IWK5QSk83BAOG(IWK5QSEv(0wH1VRP6ny4sNH98Vt5oCi8BOYv1eytJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaeYsQTIw4isRZVpOOhBWVp9BiaRCsaFlLb27AQEZB5QCkewydvUQMaB3wHJ)X15iOfAIhzjbavx9Ub)(0DT2muQFfg4boTv0YA1vVBa6kWHaZuAe0cnPu9zQOb1flYSIAAOG(IWK5QmgQ9PPX6aebvE9gGsmNxTvyT6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwrCYinlaamXcagm2SalwcGSy5(D46zj4rrxHIt2d)blSXHeWucjD4eOmSNl)xdH2RRKhLd7uaiozp8hSWghsatjKGWNZv1eAlpLukaMdWc8(dwzhsOfHRxKswdoRd0uWCaeRaHpNRQjtamhGf49hSu0QL6Q3n43NUR1MvutZ7AQEd(jT2Nm4C93qLRQjWMMaebvE9M6qT)5UtTv0YA1vVBWqn(VazwrkSwD17MGNVkywrkAz97AQEtFnjYWEM0RImu5QAcSPrD17MGNVkyaxJ)hSIpaHAqOLY0xtImSNj9QiZqP(vyGbqARaHpNRQjZVpNwNXebenzl(9kAzDaIGkVEtDO2)C3PMMaeQbHwktawiGar5FNY4OBUhBwrkAPU6Dd(9P7ATzOu)kmGbutJ1VRP6n4N0AFYGZ1FdvUQMaB3wX7dk6n)Ls5hMbpkE1vVBcE(QGbCn(FWc4tYaWA30OcXyf9d1(Nhk1Vcdy1vVBcE(QGbCn(FWQnNmsZcaatSGM4IeRScSalwcGSSknHXS4fil6RiwUNLvelwUFNf0aleqGiozp8hSWghsatjKeinH)Z1zxFOQuQE0EDLq4Z5QAYeaZbybE)bRSdjozp8hSWghsatjKCvWNY)dwO96kHWNZv1KjaMdWc8(dwzhsCYinlaamXc6NgbTqdlXewGSalwcGSy5(Dw2EF6UwZYkIfVazb7iiw6WHfa6sJ9HfVazbnXfjwzf4K9WFWcBCibmLqcLgbTqtwfwGO96kD1tteu7pbM7hQ9ppuQFfgWkJSMMwQRE3enxkCapxN9j41fYrln2hdcxViadiKLutJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaeYsQTc1vVBWVpDxRnRifTcqOgeAPmbpFvWmuQFfoEKLutd4SoqtbZbqCBozKMLymQpeENLU2hIfyXYkILhYsCy59bf9ywSC)oC9SGM4IeRScSOsxHIfxfUEwEileYJUHyXlqwk4Zcebnbpk6kuCYE4pyHnoKaMsib)Kw7tUR9HqBirqt53hu0Jvsz0EDLgQpeE3v1KI)sP8dZGhfVYitboI0687dk6Xg87t)gcWONcpkh2PaqkAPU6DtWZxfmdL6xHJx5KAASwD17MGNVkywrT5KrAwaayIfami6ZY1z5k8bsS4flOFqFryIfVazrFfXY9SSIyXY97S4SaqxASpSenWalEbYsCb9O)qqSSzXNuozp8hSWghsatjK0xtImSNj9Qi0EDLOG(IWK5QSxju4r5WofasH6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lcWaczjPOfi8noOh9hckJT4tAg0tDuK5VaqxHQPX6aebvE9MIcdudhWMgCeP153hu0JJhqTv0sD17MXrqfCHZ9HQyLWmuQFfgWifaylKb8ZQOoCqrg8v9LoVNa)0CEBfQRE3mocQGlCUpufReMvutJ1QRE3mocQGlCUpufReMvuBfTSoaHAqOLYe88vbZkQPrD17MFFoToJjciAm43dabyLrMI(HA)ZdL6xHbmGskjf9d1(Nhk1VchVYjLutJ1y4sREfO53NtRZyIaIgdvUQMaBROfgU0QxbA(9506mMiGOXqLRQjWMMaeQbHwktWZxfmdL6xHJpoj1MtgPzbaGjwCw2EF6UwZca(I(DwIgyGLvPjmMLT3NUR1SCywC9qoycwwrSahwsaxS4dXIRcxplpKficAcEelXfdq5K9WFWcBCibmLqc(9P7AnAVUsQRE3al63X5iAcu0FWYSIu0sD17g87t31AZq9HW7UQMAAC8pUohbTqt8iLKAZjJ0SeJwPrSexmaLfvQdhIf0aleqGiwSC)olBVpDxRzXlqw(DQyz79bVgueNSh(dwyJdjGPesWVpDxRr71vkarqLxVPou7FU7KcRFxt1BWpP1(KbNR)gQCvnbQOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWSIAAux9Uj45RcMvuBfbiudcTuMaSqabIY)oLXr3Cp2muQFfgWOcGMuh5aFGoDlh)JRZrql0GurwsTvOU6Dd(9P7ATzOu)kmGrpfwdoRd0uWCaeZj7H)Gf24qcykHe87dEnOi0EDLcqeu51BQd1(N7oPOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWSIAAux9Uj45RcMvuBfbiudcTuMaSqabIY)oLXr3Cp2muQFfgWahfQRE3GFF6UwBwrkOG(IWK5QSxjuyncFoxvtMdvbhkJFFWRbfPWAWzDGMcMdGyozKMfaaMyz79bVguelwUFNfVybaFr)olrdmWcCy56SKaUqhilqe0e8iwIlgGYIL73zjbCnSueYFwco(nSexngYc4knIL4IbOS4pl)oXcvGSa7S87elX4P63tmSOU6DwUolBVpDxRzXcCPbl09S0DTMfyVZcCyjbCXIpelWIfaXY7dk6XCYE4pyHnoKaMsib)(GxdkcTxxj1vVBGf974Cqt(KrC4dwMvuttlRXVp9BiJhLd7uaifwJWNZv1K5qvWHY43h8AqrnnTux9Uj45RcMHs9RWagzkux9Uj45RcMvuttRwQRE3e88vbZqP(vyaJkaAsDKd8b60TC8pUohbTqdsnoj1wH6Q3nbpFvWSIAAux9UzCeubx4CFOkwjY4R6lDEpb(P5CZqP(vyaJkaAsDKd8b60TC8pUohbTqdsnoj1wH6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwrTveGiOYR3GGQFpX0UTIw4isRZVpOOhBWVpDxRbCCAAq4Z5QAYGFF6UwNTaRp3DTod792TvyncFoxvtMdvbhkJFFWRbfPOL1ZQOoCqrM)sjlWPYGd5PQxbsttdoI0687dk6Xg87t31AahN2CYinlaamXcaoiSWSCflBqTpSG(b9fHjw8cKfSJGybaBP1SaGdclw6WHf0exKyLvGt2d)blSXHeWucjfzjNcHfAVUsTux9UHc6lctzmu7JzOu)kC8eYPW6P8FPuttRWUpOiSsasXqHDFqr5)sjaJS2nnHDFqryLItBfEuoStbG4K9WFWcBCibmLqYUR75uiSq71vQL6Q3nuqFrykJHAFmdL6xHJNqofwpL)lLAAAf29bfHvcqkgkS7dkk)xkbyK1UPjS7dkcRuCARWJYHDkaKIwQRE3mocQGlCUpufReMHs9RWagzkux9UzCeubx4CFOkwjmRifwpRI6WbfzWx1x68Ec8tZ5nnwRU6DZ4iOcUW5(qvSsywrT5K9WFWcBCibmLqsFP15uiSq71vQL6Q3nuqFrykJHAFmdL6xHJNqofwpL)lLu0kaHAqOLYe88vbZqP(v44rwsnnbiudcTuMaSqabIY)oLXr3Cp2muQFfoEKLu7MMwHDFqryLaKIHc7(GIY)LsagzTBAc7(GIWkfN2k8OCyNcaPOL6Q3nJJGk4cN7dvXkHzOu)kmGrMc1vVBghbvWfo3hQIvcZksH1ZQOoCqrg8v9LoVNa)0CEtJ1QRE3mocQGlCUpufReMvuBozKMfaaMyb4cI(SalwqtmIt2d)blSXHeWucjw8zo4KH9mPxfXjJ0SGgxhwA)jmlw2PFNgwEillmXY27t)gILRyzdQ9Hfl7xyNLdZI)SGmwEFqrpgykZshoSqiOjblakjKklPo(PjblWHf0JLT3h8AqrSG(Prql0Ks1Zc(9aqyozp8hSWghsatjKGWNZv1eAlpLuc)(0VHYxLXqTpOfHRxKs4isRZVpOOhBWVp9BO4rpG11q40k1XpnjYiC9IaELtkjKkGsQnW6AiCAPU6Dd(9bVguuMsJGwOjLQpJHAFm43daHurV2CYinlOX1HL2FcZILD63PHLhYcW14)olGR5kuSaGnufReCYE4pyHnoKaMsibHpNRQj0wEkPKLX)98v5(qvSsGweUErkPmsfhrADE3XpbyabaBLKbqaFlCeP153hu0Jn43N(neau52aFlLb27AQEdgU0zyp)7uUdhc)gQCvnbc8kBqw72aljJYid4vx9UzCeubx4CFOkwjmdL6xH5KrAwaayIfGRX)DwUILnO2hwq)G(IWelWHLRZsbzz79PFdXILtRzPFplx9qwqtCrIvwbw8krkCiozp8hSWghsatjKyz8FhTxxPwuqFryYOxLp5Iq(30qb9fHjJxjYfH8xbcFoxvtMdNdAYrqTv069bf9M)sP8dZGhfp610qb9fHjJEv(KVkdOMM(HA)ZdL6xHbSYj1UPrD17gkOVimLXqTpMHs9RWa2d)bld(9PFdziKtH1t5)sjfQRE3qb9fHPmgQ9XSIAAOG(IWK5QmgQ9rH1i85CvnzWVp9BO8vzmu7ttJ6Q3nbpFvWmuQFfgWE4pyzWVp9BidHCkSEk)xkPWAe(CUQMmhoh0KJGuOU6DtWZxfmdL6xHbmHCkSEk)xkPqD17MGNVkywrnnQRE3mocQGlCUpufReMvKce(CUQMmwg)3ZxL7dvXkrtJ1i85CvnzoCoOjhbPqD17MGNVkygk1VchpHCkSEk)xkXjJ0SaaWelBVp9BiwUolxXIvSkFyb9d6lctOLLRyzdQ9Hf0pOVimXcSyb9aglVpOOhZcCy5HSenWalBqTpSG(b9fHjozp8hSWghsatjKGFF63qCYinlayUw)7ZIt2d)blSXHeWucjZQYE4pyL1h(rB5PKsDxR)9zXjZjJ0SaGnufReSy5(DwqtCrIvwbozp8hSWgvO)knocQGlCUpufReO96kPU6DtWZxfmdL6xHJxzKXjJ0SaaWelXf0J(dbXYMfFszXYovS4plAcJz539If0JLycJRvzb)EaimlEbYYdzzO(q4DwCwaSsaIf87bGyXXSO9NyXXSebX4tvtSahw(lLy5EwWqwUNfFMdbHzb4Mf(zX7pnS4SehGXc(9aqSqip6gcZj7H)Gf2Oc9hykHeh0J(dbLXw8jfTHebnLFFqrpwjLr71vsD17gvx7vGYWE2168VFfkCU8FnKb)EaiadquOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpaeGbikAzni8noOh9hckJT4tAg0tDuK5VaqxHsH1E4pyzCqp6peugBXN0mON6OiZv5U(qT)kAzni8noOh9hckJT4tAENCT5VaqxHQPbe(gh0J(dbLXw8jnVtU2muQFfo(40UPbe(gh0J(dbLXw8jnd6PokYGFpaeGJJcq4BCqp6peugBXN0mON6OiZqP(vyaJmfGW34GE0FiOm2IpPzqp1rrM)caDfQ2CYinlaamXcAGfciqelwUFNf0exKyLvGfl7uXseeJpvnXIxGSa)DASCyIfl3VZIZsmHX1QSOU6DwSStflGeorfUcfNSh(dwyJk0FGPescWcbeik)7ughDZ9y0EDLSgCwhOPG5aiwrRwi85CvnzcWcbeikds4evqH1biudcTuMGNVkygYbt00OU6DtWZxfmRO2kAPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaKsaKMg1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGucG0UPrfIXk6hQ9ppuQFfgWkNuBozKMfami6ZIJz53jw63GFwqfaz5kw(DIfNLycJRvzXYvGqlSahwSC)ol)oXcW9eZ5flQRENf4WIL73zXzbGammfyjUGE0Fiiw2S4tklEbYIf)Ew6WHf0exKyLvGLRZY9SybwplQelRiwCu(vSOsD4qS87elbqwoml9Ro8obYj7H)Gf2Oc9hykHK(AsKH9mPxfH2RRuRwTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhakEGttJ6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqXdCAROL1bicQ86niO63tmnnwRU6DZ4iOcUW5(qvSsywrTBROf4SoqtbZbqCttac1GqlLj45RcMHs9RWXJSKAAAfGiOYR3uhQ9p3Dsrac1GqlLjaleqGO8VtzC0n3JndL6xHJhzj1UD7MMwGW34GE0FiOm2IpPzqp1rrMHs9RWXdqueGqni0szcE(QGzOu)kC8kNKIaebvE9MIcdudhW2nnx90eb1(tG5(HA)ZdL6xHbmarH1biudcTuMGNVkygYbt00eGiOYR3auI58sH6Q3naDf4qGzkncAHMuQEZkQPjarqLxVbbv)EIrH6Q3nJJGk4cN7dvXkHzOu)kmGrkkux9UzCeubx4CFOkwjmRiozKMf04vG0SS9(OHdilwUFNfNLISWsmHX1QSOU6Dw8cKf0exKyLvGLdxO7zXvHRNLhYIkXYctGCYE4pyHnQq)bMsij4vG0z1vVJ2YtjLWVpA4aI2RRul1vVBuDTxbkd7zxRZ)(vOW5Y)1qMHs9RWXdWmiRPrD17gvx7vGYWE2168VFfkC2NGxKzOu)kC8amdYAROvac1GqlLj45RcMHs9RWXdWAAAfGqni0szO0iOfAYQWc0muQFfoEaMcRvx9UbORahcmtPrql0Ks1NPIguxSiZksraIGkVEdqjMZR2Tv44FCDocAHM4vkojXjJ0SeJwPrSS9(GxdkcZIL73zXzjMW4Avwux9olQRNLc(SyzNkwIGq9vOyPdhwqtCrIvwbwGdla3VcCiqw2IU5EmNSh(dwyJk0FGPesWVp41GIq71vQL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9aqXdOMg1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGIhqTv0karqLxVPou7FU7uttac1GqlLj45RcMHs9RWXdWAASgHpNRQjtamhGf49hSuyDaIGkVEdqjMZRMMwbiudcTugkncAHMSkSandL6xHJhGPWA1vVBa6kWHaZuAe0cnPu9zQOb1flYSIueGiOYR3auI58QDBfTSge(M(AsKH9mPxfz(la0vOAASoaHAqOLYe88vbZqoyIMgRdqOgeAPmbyHaceL)DkJJU5ESzihmrBozKMLy0knILT3h8AqrywuPoCiwqdSqabI4K9WFWcBuH(dmLqc(9bVgueAVUsTcqOgeAPmbyHaceL)DkJJU5ESzOu)kmGrMcRbN1bAkyoaIv0cHpNRQjtawiGarzqcNOcnnbiudcTuMGNVkygk1VcdyK1wbcFoxvtMayoalW7py1wH1GW30xtImSNj9QiZFbGUcLIaebvE9M6qT)5UtkSgCwhOPG5aiwbf0xeMmxL9kHch)JRZrql0ep6LeNmsZsmcwO7zbe(SaUMRqXYVtSqfilWolXyocQGlmlaydvXkbAzbCnxHIfGUcCiqwO0iOfAsP6zboSCfl)oXI2XplOcGSa7S4flOFqFryIt2d)blSrf6pWucji85CvnH2YtjLaHFEOyyDdLs1JrlcxViLAPU6DZ4iOcUW5(qvSsygk1VchpYAASwD17MXrqfCHZ9HQyLWSIAROL6Q3naDf4qGzkncAHMuQ(mv0G6Ifzgk1VcdyubqtQJ82kAPU6Ddf0xeMYyO2hZqP(v44rfanPoYBAux9UHc6lctz9Q8XmuQFfoEubqtQJ82CYE4pyHnQq)bMsibVQ(neAdjcAk)(GIESskJ2RR0q9HW7UQMu8(GIEZFPu(HzWJIxzGJcpkh2Paqkq4Z5QAYac)8qXW6gkLQhZj7H)Gf2Oc9hykHKuiS63qOnKiOP87dk6XkPmAVUsd1hcV7QAsX7dk6n)Ls5hMbpkELJJbzk8OCyNcaPaHpNRQjdi8ZdfdRBOuQEmNSh(dwyJk0FGPesWpP1(K7AFi0gse0u(9bf9yLugTxxPH6dH3DvnP49bf9M)sP8dZGhfVYahGnuQFfwHhLd7uaifi85CvnzaHFEOyyDdLs1J5KrAwaWGXMfyXsaKfl3Vdxplbpk6kuCYE4pyHnQq)bMsiPdNaLH9C5)Ai0EDL8OCyNcaXjJ0SG(Prql0WsmHfilw2PIfxfUEwEilu90WIZsrwyjMW4AvwSCfi0clEbYc2rqS0HdlOjUiXkRaNSh(dwyJk0FGPesO0iOfAYQWceTxxPwuqFryYOxLp5Iq(30qb9fHjdgQ9jxeY)MgkOVimz8krUiK)nnQRE3O6AVcug2ZUwN)9RqHZL)RHmdL6xHJhGzqwtJ6Q3nQU2RaLH9SR15F)ku4SpbViZqP(v44bygK1044FCDocAHM4rkjPiaHAqOLYe88vbZqoycfwdoRd0uWCae3wrRaeQbHwktWZxfmdL6xHJpoj10eGqni0szcE(QGzihmr7MMREAIGA)jWC)qT)5Hs9RWaw5K4KrAwaWGOplZHA)zrL6WHyzHVcflOjUCYE4pyHnQq)bMsiPVMezypt6vrO96kfGqni0szcE(QGzihmHce(CUQMmbWCawG3FWsrlh)JRZrql0epsjjfwhGiOYR3uhQ9p3DQPjarqLxVPou7FU7Kch)JRZrql0ay0lP2kSoarqLxVbbv)EIrrlRdqeu51BQd1(N7o10eGqni0szcWcbeik)7ughDZ9yZqoyI2kSgCwhOPG5aiMtgPzbnXfjwzfyXYovS4pliLKaglXfdqzPfC0ql0WYV7flOxsSexmaLfl3VZcAGfciquBwSC)oC9SOH4RqXYFPelxXsm1qiOEHFw8cKf9velRiwSC)olObwiGarSCDwUNfloMfqcNOceiNSh(dwyJk0FGPesq4Z5QAcTLNskfaZbybE)bRSk0F0IW1lsjRbN1bAkyoaIvGWNZv1KjaMdWc8(dwkA1YX)46Ce0cnXJussrl1vVBa6kWHaZuAe0cnPu9zQOb1flYSIAASoarqLxVbOeZ5v7Mg1vVBu1qiOEHFZksH6Q3nQAieuVWVzOu)kmGvx9Uj45RcgW14)bR2nnx90eb1(tG5(HA)ZdL6xHbS6Q3nbpFvWaUg)py10eGiOYR3uhQ9p3DQTIwwhGiOYR3uhQ9p3DQPPLJ)X15iOfAam6Lutdi8n91Kid7zsVkY8xaORq1wrle(CUQMmbyHaceLbjCIk00eGqni0szcWcbeik)7ughDZ9yZqoyI2T5K9WFWcBuH(dmLqsG0e(pxND9HQsP6r71vcHpNRQjtamhGf49hSYQq)5K9WFWcBuH(dmLqYvbFk)pyH2RRecFoxvtMayoalW7pyLvH(ZjJ0SG(4)s9NWSSdTWs6kSZsCXauw8HybLFfbYsenSGPaSa5K9WFWcBuH(dmLqccFoxvtOT8usjhhbqPzJcOfHRxKsuqFryYCvwVkFaEacs1d)bld(9PFdziKtH1t5)sjGznf0xeMmxL1RYhGVfWbyVRP6ny4sNH98Vt5oCi8BOYv1eiWhN2ivp8hSmwg)3neYPW6P8FPeWsYaiKkoI068UJFItgPzjgTsJyz79bVgueMfl7uXYVtS0pu7plhMfxfUEwEilubIww6dvXkblhMfxfUEwEilubIwwsaxS4dXI)SGuscySexmaLLRyXlwq)G(IWeAzbnXfjwzfyr74hZIxWFNgwaiadtbmlWHLeWflwGlnilqe0e8iwsHdXYV7flCJYjXsCXauwSStfljGlwSaxAWcDplBVp41GIyPGw4K9WFWcBuH(dmLqc(9bVgueAVUsTU6PjcQ9NaZ9d1(Nhk1Vcdy0RPPL6Q3nJJGk4cN7dvXkHzOu)kmGrfanPoYb(aD6wo(hxNJGwObPgNKARqD17MXrqfCHZ9HQyLWSIA3UPPLJ)X15iOfAagcFoxvtghhbqPzJcaV6Q3nuqFrykJHAFmdL6xHbgi8n91Kid7zsVkY8xaiCEOu)kGhqgKfVYkNutJJ)X15iOfAagcFoxvtghhbqPzJcaV6Q3nuqFrykRxLpMHs9RWade(M(AsKH9mPxfz(laeopuQFfWdidYIxzLtQTckOVimzUk7vcfTSwD17MGNVkywrnnw)UMQ3GFF0Wb0qLRQjW2kA1Y6aeQbHwktWZxfmROMMaebvE9gGsmNxkSoaHAqOLYqPrql0KvHfOzf1UPjarqLxVPou7FU7uBfTSoarqLxVbbv)EIPPXA1vVBcE(QGzf1044FCDocAHM4rkj1UPP17AQEd(9rdhqdvUQMavOU6DtWZxfmRifTux9Ub)(OHdOb)EaiahNMgh)JRZrql0epsjP2TBAux9Uj45RcMvKcRvx9UzCeubx4CFOkwjmRifw)UMQ3GFF0Wb0qLRQjqozKMfaaMybahewywUIfRyv(Wc6h0xeMyXlqwWocILyCDDhyaylTMfaCqyXshoSGM4IeRScCYE4pyHnQq)bMsiPil5uiSq71vQL6Q3nuqFrykRxLpMHs9RWXtiNcRNY)LsnnTc7(GIWkbifdf29bfL)lLamYA30e29bfHvkoTv4r5WofaIt2d)blSrf6pWucj7UUNtHWcTxxPwQRE3qb9fHPSEv(ygk1VchpHCkSEk)xkPOvac1GqlLj45RcMHs9RWXJSKAAcqOgeAPmbyHaceL)DkJJU5ESzOu)kC8ilP2nnTc7(GIWkbifdf29bfL)lLamYA30e29bfHvkoTv4r5WofaIt2d)blSrf6pWucj9LwNtHWcTxxPwQRE3qb9fHPSEv(ygk1VchpHCkSEk)xkPOvac1GqlLj45RcMHs9RWXJSKAAcqOgeAPmbyHaceL)DkJJU5ESzOu)kC8ilP2nnTc7(GIWkbifdf29bfL)lLamYA30e29bfHvkoTv4r5WofaItgPzb4cI(SalwcGCYE4pyHnQq)bMsiXIpZbNmSNj9QiozKMfaaMyz79PFdXYdzjAGbw2GAFyb9d6lctSahwSStflxXcS0jyXkwLpSG(b9fHjw8cKLfMyb4cI(SenWaMLRZYvSyfRYhwq)G(IWeNSh(dwyJk0FGPesWVp9Bi0EDLOG(IWK5QSEv(00qb9fHjdgQ9jxeY)MgkOVimz8krUiK)nnQRE3yXN5Gtg2ZKEvKzfPqD17gkOVimL1RYhZkQPPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKtH1t5)sjfQRE3e88vbZkQnNSh(dwyJk0FGPesSm(VZj7H)Gf2Oc9hykHKzvzp8hSY6d)OT8usPUR1)(S4K5KrAw2EFWRbfXshoSKcrqPu9SSknHXSSWxHILycJRv5K9WFWcB6Uw)7Zsj87dEnOi0EDLSEwf1HdkYO6AVcug2ZUwN)9RqHnumSUOicKtgPzbno(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYzbCn(FWILdZY(9gw2wv)gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQFdXc4A8)GfNSh(dwyt316FFwatjKGxv)gcTHebnLFFqrpwjLr71vce(MuiS63qMHs9RWXpuQFfg4beGqQkdq4K9WFWcB6Uw)7ZcykHKuiS63qCYCYinlaamXY27dEnOiwEilaruelRiw(DILy0qEQ6vG0WI6Q3z56SCplwGlnileYJUHyrL6WHyPF1H3Vcfl)oXsri)zj44Nf4WYdzbCLgXIk1HdXcAGfciqeNSh(dwyd(vc)(GxdkcTxxPzvuhoOiZFPKf4uzWH8u1RaPrrlkOVimzUk7vcfw3QL6Q3n)LswGtLbhYtvVcKgZqP(v449WFWYyz8F3qiNcRNY)LsaljJYkArb9fHjZvzv4V30qb9fHjZvzmu7ttdf0xeMm6v5tUiK)TBAux9U5VuYcCQm4qEQ6vG0ygk1VchVh(dwg87t)gYqiNcRNY)LsaljJYkArb9fHjZvz9Q8PPHc6lctgmu7tUiK)nnuqFryY4vICri)B3UPXA1vVB(lLSaNkdoKNQEfinMvu7MMwQRE3e88vbZkQPbHpNRQjtawiGarzqcNOcTveGqni0szcWcbeik)7ughDZ9yZqoycfbicQ86n1HA)ZDNAROL1bicQ86naLyoVAAcqOgeAPmuAe0cnzvybAgk1VchpaPTIwQRE3e88vbZkQPX6aeQbHwktWZxfmd5GjAZjJ0SaaWelXf0J(dbXYMfFszXYovS870qSCywkilE4peelyl(KIwwCmlA)jwCmlrqm(u1elWIfSfFszXY97SaiwGdlDYcnSGFpaeMf4WcSyXzjoaJfSfFszbdz539NLFNyPilSGT4tkl(mhccZcWnl8ZI3FAy539NfSfFszHqE0neMt2d)blSb)atjK4GE0FiOm2IpPOnKiOP87dk6XkPmAVUswdcFJd6r)HGYyl(KMb9uhfz(la0vOuyTh(dwgh0J(dbLXw8jnd6PokYCvURpu7VIwwdcFJd6r)HGYyl(KM3jxB(la0vOAAaHVXb9O)qqzSfFsZ7KRndL6xHJhzTBAaHVXb9O)qqzSfFsZGEQJIm43dab44Oae(gh0J(dbLXw8jnd6PokYmuQFfgWXrbi8noOh9hckJT4tAg0tDuK5VaqxHItgPzbaGjmlObwiGarSCDwqtCrIvwbwomlRiwGdljGlw8HybKWjQWvOybnXfjwzfyXY97SGgyHaceXIxGSKaUyXhIfvsdTWc6LelXfdq5K9WFWcBWpWucjbyHaceL)DkJJU5EmAVUswdoRd0uWCaeROvle(CUQMmbyHaceLbjCIkOW6aeQbHwktWZxfmd5Gjuy9SkQdhuKjAUu4aEUo7tWRlKJwASpnnQRE3e88vbZkQTch)JRZrql0ayLqVKu0sD17gkOVimL1RYhZqP(v44voPMg1vVBOG(IWugd1(ygk1VchVYj1UPrfIXk6hQ9ppuQFfgWkNKcRdqOgeAPmbpFvWmKdMOnNmsZcAGf49hSyPdhwCTMfq4Jz539NLuhicZcEnel)oLGfFOcDpld1hcVtGSyzNkwIXCeubxywaWgQIvcw2DmlAcJz539IfKXcMcywgk1V6kuSahw(DIfGsmNxSOU6DwomlUkC9S8qw6UwZcS3zboS4vcwq)G(IWelhMfxfUEwEileYJUH4K9WFWcBWpWucji85CvnH2YtjLaHFEOyyDdLs1JrlcxViLAPU6DZ4iOcUW5(qvSsygk1VchpYAASwD17MXrqfCHZ9HQyLWSIARWA1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIu0sD17gGUcCiWmLgbTqtkvFMkAqDXImdL6xHbmQaOj1rEBfTux9UHc6lctzmu7JzOu)kC8OcGMuh5nnQRE3qb9fHPSEv(ygk1VchpQaOj1rEttlRvx9UHc6lctz9Q8XSIAASwD17gkOVimLXqTpMvuBfw)UMQ3GHA8FbYqLRQjW2CYinlObwG3FWILF3Fwc7uaimlxNLeWfl(qSaxp(ajwOG(IWelpKfyPtWci8z53PHyboSCOk4qS87hMfl3VZYguJ)lqCYE4pyHn4hykHee(CUQMqB5PKsGWpdxp(aPmf0xeMqlcxViLAzT6Q3nuqFrykJHAFmRifwRU6Ddf0xeMY6v5Jzf1UP5DnvVbd14)cKHkxvtGCYE4pyHn4hykHKuiS63qOnKiOP87dk6XkPmAVUsd1hcV7QAsrl1vVBOG(IWugd1(ygk1Vch)qP(v4Mg1vVBOG(IWuwVkFmdL6xHJFOu)kCtdcFoxvtgq4NHRhFGuMc6lctTvmuFi8URQjfVpOO38xkLFyg8O4vgqk8OCyNcaPaHpNRQjdi8ZdfdRBOuQEmNSh(dwyd(bMsibVQ(neAdjcAk)(GIESskJ2RR0q9HW7UQMu0sD17gkOVimLXqTpMHs9RWXpuQFfUPrD17gkOVimL1RYhZqP(v44hk1Vc30GWNZv1Kbe(z46XhiLPG(IWuBfd1hcV7QAsX7dk6n)Ls5hMbpkELbKcpkh2Paqkq4Z5QAYac)8qXW6gkLQhZj7H)Gf2GFGPesWpP1(K7AFi0gse0u(9bf9yLugTxxPH6dH3DvnPOL6Q3nuqFrykJHAFmdL6xHJFOu)kCtJ6Q3nuqFrykRxLpMHs9RWXpuQFfUPbHpNRQjdi8ZW1Jpqktb9fHP2kgQpeE3v1KI3hu0B(lLYpmdEu8kdCu4r5WofasbcFoxvtgq4Nhkgw3qPu9yozKMfaaMybadgBwGflbqwSC)oC9Se8OORqXj7H)Gf2GFGPes6Wjqzypx(VgcTxxjpkh2PaqCYinlaamXcW9RahcKLTOBUhZIL73zXReSOHfkwOcUqTZI2X)vOyb9d6lctS4fil)KGLhYI(kIL7zzfXIL73zbGU0yFyXlqwqtCrIvwbozp8hSWg8dmLqcLgbTqtwfwGO96k1QL6Q3nuqFrykJHAFmdL6xHJx5KAAux9UHc6lctz9Q8XmuQFfoELtQTIaeQbHwktWZxfmdL6xHJpojPOL6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lcWac9sQPX6zvuhoOit0CPWb8CD2NGxxihT0yFmumSUOicSD7Mg1vVBIMlfoGNRZ(e86c5OLg7JbHRxu8kbiawsnnbiudcTuMGNVkygYbtOWX)46Ce0cnXJusItgPzbaGjwqtCrIvwbwSC)olObwiGarib4(vGdbYYw0n3JzXlqwaHf6EwGiOXYCpXcaDPX(WcCyXYovSetnecQx4NflWLgKfc5r3qSOsD4qSGM4IeRScSqip6gcZj7H)Gf2GFGPesq4Z5QAcTLNskfaZbybE)bRm(rlcxViLSgCwhOPG5aiwbcFoxvtMayoalW7pyPOvRaeQbHwkdLgLyixNHdy5vGmdL6xHbSYahagWAPSYa)SkQdhuKbFvFPZ7jWpnN3wbfdRlkIanuAuIHCDgoGLxbQDtJJ)X15iOfAIxjKsskAz97AQEtFnjYWEM0RImu5QAcSPrD17MGNVkyaxJ)hSIpaHAqOLY0xtImSNj9QiZqP(vyGbqARaHpNRQjZVpNwNXebenzl(9kAPU6DdqxboeyMsJGwOjLQptfnOUyrMvutJ1bicQ86naLyoVAR49bf9M)sP8dZGhfV6Q3nbpFvWaUg)pyb8jzaynnQqmwr)qT)5Hs9RWawD17MGNVkyaxJ)hSAAcqeu51BQd1(N7o10OU6DJQgcb1l8Bwrkux9UrvdHG6f(ndL6xHbS6Q3nbpFvWaUg)pybSwifGFwf1HdkYenxkCapxN9j41fYrln2hdfdRlkIaB3wH1QRE3e88vbZksrlRdqeu51BQd1(N7o10eGqni0szcWcbeik)7ughDZ9yZkQPrfIXk6hQ9ppuQFfgWbiudcTuMaSqabIY)oLXr3Cp2muQFfgyaNMM(HA)ZdL6xHrQivLbijby1vVBcE(QGbCn(FWQnNmsZcaatS87elX4P63tmSy5(DwCwqtCrIvwbw(D)z5Wf6Ew6dmLfa6sJ9Ht2d)blSb)atjKmocQGlCUpufReO96kPU6DtWZxfmdL6xHJxzK10OU6DtWZxfmGRX)dwaoojPaHpNRQjtamhGf49hSY4Nt2d)blSb)atjKeinH)Z1zxFOQuQE0EDLq4Z5QAYeaZbybE)bRm(v0YA1vVBcE(QGbCn(FWk(4KutJ1bicQ86niO63tmTBAux9UzCeubx4CFOkwjmRifQRE3mocQGlCUpufReMHs9RWagPaSaSax3BIgkCyk76dvLs1B(lLYiC9IawlRvx9UrvdHG6f(nRifw)UMQ3GFF0Wb0qLRQjW2CYE4pyHn4hykHKRc(u(FWcTxxje(CUQMmbWCawG3FWkJFozKMLy8(CUQMyzHjqwGflU6PV)iml)U)SyXRNLhYIkXc2rqGS0HdlOjUiXkRalyil)U)S87ucw8HQNflo(jqwaUzHFwuPoCiw(DkLt2d)blSb)atjKGWNZv1eAlpLuc7iOCho5GNVkGweUErkzDac1GqlLj45RcMHCWennwJWNZv1KjaleqGOmiHtubfbicQ86n1HA)ZDNAAaN1bAkyoaI5KrAwaaycZcage9z56SCflEXc6h0xeMyXlqw(5imlpKf9vel3ZYkIfl3VZcaDPX(GwwqtCrIvwbw8cKL4c6r)HGyzZIpPCYE4pyHn4hykHK(AsKH9mPxfH2RRef0xeMmxL9kHcpkh2Paqkux9UjAUu4aEUo7tWRlKJwASpgeUEragqOxskAbcFJd6r)HGYyl(KMb9uhfz(la0vOAASoarqLxVPOWa1WbSTce(CUQMmyhbL7Wjh88vbfTux9UzCeubx4CFOkwjmdL6xHbmsba2cza)SkQdhuKbFvFPZ7jWpnN3wH6Q3nJJGk4cN7dvXkHzf10yT6Q3nJJGk4cN7dvXkHzf1MtgPzbaGjwaWx0VZY27t31AwIgyaZY1zz79P7AnlhUq3ZYkIt2d)blSb)atjKGFF6UwJ2RRK6Q3nWI(DCoIMaf9hSmRifQRE3GFF6UwBgQpeE3v1eNSh(dwyd(bMsij4vG0z1vVJ2YtjLWVpA4aI2RRK6Q3n43hnCandL6xHbmYu0sD17gkOVimLXqTpMHs9RWXJSMg1vVBOG(IWuwVkFmdL6xHJhzTv44FCDocAHM4rkjXjJ0SeJwPrywIlgGYIk1HdXcAGfciqell8vOy53jwqdSqabIyjalW7pyXYdzjStbGy56SGgyHaceXYHzXd)Y16eS4QW1ZYdzrLyj44Nt2d)blSb)atjKGFFWRbfH2RRuaIGkVEtDO2)C3jfi85CvnzcWcbeikds4evqrac1GqlLjaleqGO8VtzC0n3JndL6xHbmYuyn4SoqtbZbqSckOVimzUk7vcfo(hxNJGwOjE0ljozKMfaaMyz79P7AnlwUFNLTN0AFyjgnx)zXlqwkilBVpA4aIwwSStflfKLT3NUR1SCywwrOLLeWfl(qSCflwXQ8Hf0pOVimXshoSaqagMcywGdlpKLObgybGU0yFyXYovS4QqeeliLKyjUyaklWHfhmY)dbXc2IpPSS7ywaiadtbmldL6xDfkwGdlhMLRyPRpu7VHLydFILF3FwwfinS87elypLyjalW7pyHz5E0HzbmcZsrRFCnlpKLT3NUR1SaUMRqXsmMJGk4cZca2qvSsGwwSStfljGl0bYc(pTMfQazzfXIL73zbPKeWCCelD4WYVtSOD8Zcknu11ydNSh(dwyd(bMsib)(0DTgTxxP31u9g8tATpzW56VHkxvtGkS(DnvVb)(OHdOHkxvtGkux9Ub)(0DT2muFi8URQjfTux9UHc6lctz9Q8XmuQFfoEaIckOVimzUkRxLpkux9UjAUu4aEUo7tWRlKJwASpgeUEragqilPMg1vVBIMlfoGNRZ(e86c5OLg7JbHRxu8kbiKLKch)JRZrql0epsjPMgq4BCqp6peugBXN0mON6OiZqP(v44binnE4pyzCqp6peugBXN0mON6OiZv5U(qT)TveGqni0szcE(QGzOu)kC8kNeNmsZcaatSS9(GxdkIfa8f97SenWaMfVazbCLgXsCXauwSStflOjUiXkRalWHLFNyjgpv)EIHf1vVZYHzXvHRNLhYs31AwG9olWHLeWf6azj4rSexmaLt2d)blSb)atjKGFFWRbfH2RRK6Q3nWI(DCoOjFYio8blZkQPrD17gGUcCiWmLgbTqtkvFMkAqDXImROMg1vVBcE(QGzfPOL6Q3nJJGk4cN7dvXkHzOu)kmGrfanPoYb(aD6wo(hxNJGwObPgNKAdS4a8VRP6nfzjNcHLHkxvtGkSEwf1HdkYGVQV059e4NMZvOU6DZ4iOcUW5(qvSsywrnnQRE3e88vbZqP(vyaJkaAsDKd8b60TC8pUohbTqdsnoj1UPrD17MXrqfCHZ9HQyLiJVQV059e4NMZnROMMwQRE3mocQGlCUpufReMHs9RWa2d)bld(9PFdziKtH1t5)sjf4isRZ7o(jaNKb9AAux9UzCeubx4CFOkwjmdL6xHbSh(dwglJ)7gc5uy9u(VuQPbHpNRQjZfdG5aSaV)GLIaeQbHwkZv4WSExvt5yy51VsZGeIlqMHCWekOyyDrreO5kCywVRQPCmS86xPzqcXfO2kux9UzCeubx4CFOkwjmROMgRvx9UzCeubx4CFOkwjmRifwhGqni0szghbvWfo3hQIvcZqoyIMgRdqeu51Bqq1VNyA3044FCDocAHM4rkjPGc6lctMRYELGtgPzXQtcwEilPoqel)oXIkHFwGDw2EF0WbKf1eSGFpa0vOy5EwwrSedRlaKoblxXIxjyb9d6lctSOUEwaOln2hwoC9S4QW1ZYdzrLyjAGHabYj7H)Gf2GFGPesWVp41GIq71v6DnvVb)(OHdOHkxvtGkSEwf1HdkY8xkzbovgCipv9kqAu0sD17g87JgoGMvutJJ)X15iOfAIhPKuBfQRE3GFF0Wb0GFpaeGJJIwQRE3qb9fHPmgQ9XSIAAux9UHc6lctz9Q8XSIARqD17MO5sHd456SpbVUqoAPX(yq46fbyabWssrRaeQbHwktWZxfmdL6xHJx5KAASgHpNRQjtawiGarzqcNOckcqeu51BQd1(N7o1MtgPzb9X)L6pHzzhAHL0vyNL4IbOS4dXck)kcKLiAybtbybYj7H)Gf2GFGPesq4Z5QAcTLNsk54iaknBuaTiC9IuIc6lctMRY6v5dWdqqQE4pyzWVp9BidHCkSEk)xkbmRPG(IWK5QSEv(a8Taoa7DnvVbdx6mSN)Dk3HdHFdvUQMab(40gP6H)GLXY4)UHqofwpL)lLawsg0dzivCeP15Dh)eWsYGmG)DnvVP8FneoR6AVcKHkxvtGCYinlXOvAelBVp41GIy5kwCwayadtbw2GAFyb9d6lctOLfqyHUNfn9SCplrdmWcaDPX(WsRF3Fwoml7EbQjqwutWcD)onS87elBVpDxRzrFfXcCy53jwIlgGgpsjjw0xrS0HdlBVp41GIAJwwaHf6EwGiOXYCpXIxSaGVOFNLObgyXlqw00ZYVtS4Qqeel6Riw29cutSS9(OHdiNSh(dwyd(bMsib)(GxdkcTxxjRNvrD4GIm)LswGtLbhYtvVcKgfTux9UjAUu4aEUo7tWRlKJwASpgeUEragqaSKAAux9UjAUu4aEUo7tWRlKJwASpgeUEragqiljfVRP6n4N0AFYGZ1FdvUQMaBROff0xeMmxLXqTpkC8pUohbTqdWq4Z5QAY44iaknBua4vx9UHc6lctzmu7JzOu)kmWaHVPVMezypt6vrM)caHZdL6xb8aYGS4bij10qb9fHjZvz9Q8rHJ)X15iOfAagcFoxvtghhbqPzJcaV6Q3nuqFrykRxLpMHs9RWade(M(AsKH9mPxfz(laeopuQFfWdidYIhPKuBfwRU6DdSOFhNJOjqr)blZksH1VRP6n43hnCanu5QAcurRaeQbHwktWZxfmdL6xHJhG10GHlT6vGMFFoToJjciAmu5QAcuH6Q3n)(CADgteq0yWVhacWXjoaWwZQOoCqrg8v9LoVNa)0CoWJS2k6hQ9ppuQFfoELtkjf9d1(Nhk1VcdyaLusTv0kaHAqOLYa0vGdbMXr3Cp2muQFfoEawtJ1bicQ86naLyoVAZjJ0SaaWela4GWcZYvSyfRYhwq)G(IWelEbYc2rqSeJRR7adaBP1SaGdclw6WHf0exKyLvGfVazb4(vGdbYc6NgbTqtkvpNSh(dwyd(bMsiPil5uiSq71vQL6Q3nuqFrykRxLpMHs9RWXtiNcRNY)LsnnTc7(GIWkbifdf29bfL)lLamYA30e29bfHvkoTv4r5WofasbcFoxvtgSJGYD4KdE(QaNSh(dwyd(bMsiz319CkewO96k1sD17gkOVimL1RYhZqP(v44jKtH1t5)sjfwhGiOYR3auI58QPPL6Q3naDf4qGzkncAHMuQ(mv0G6Ifzwrkcqeu51BakXCE1UPPvy3huewjaPyOWUpOO8FPeGrw7MMWUpOiSsXPPrD17MGNVkywrTv4r5WofasbcFoxvtgSJGYD4KdE(QGIwQRE3mocQGlCUpufReMHs9RWaUfYaGac4NvrD4GIm4R6lDEpb(P582kux9UzCeubx4CFOkwjmROMgRvx9UzCeubx4CFOkwjmRO2CYE4pyHn4hykHK(sRZPqyH2RRul1vVBOG(IWuwVkFmdL6xHJNqofwpL)lLuyDaIGkVEdqjMZRMMwQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfPiarqLxVbOeZ5v7MMwHDFqryLaKIHc7(GIY)LsagzTBAc7(GIWkfNMg1vVBcE(QGzf1wHhLd7uaifi85CvnzWock3Hto45RckAPU6DZ4iOcUW5(qvSsygk1VcdyKPqD17MXrqfCHZ9HQyLWSIuy9SkQdhuKbFvFPZ7jWpnN30yT6Q3nJJGk4cN7dvXkHzf1MtgPzbaGjwaUGOplWILaiNSh(dwyd(bMsiXIpZbNmSNj9QiozKMfaaMyz79PFdXYdzjAGbw2GAFyb9d6lctOLf0exKyLvGLDhZIMWyw(lLy539IfNfGRX)DwiKtH1tSOP(ZcCybw6eSyfRYhwq)G(IWelhMLveNSh(dwyd(bMsib)(0VHq71vIc6lctMRY6v5ttdf0xeMmyO2NCri)BAOG(IWKXRe5Iq(300sD17gl(mhCYWEM0RImROMgCeP15Dh)eGtYGEitH1bicQ86niO63tmnn4isRZ7o(jaNKb9ueGiOYR3GGQFpX0wH6Q3nuqFrykRxLpMvuttl1vVBcE(QGzOu)kmG9WFWYyz8F3qiNcRNY)Lskux9Uj45RcMvuBozKMfaaMyb4A8FNf4VtJLdtSyz)c7SCywUILnO2hwq)G(IWeAzbnXfjwzfyboS8qwIgyGfRyv(Wc6h0xeM4K9WFWcBWpWucjwg)35KrAwaWCT(3NfNSh(dwyd(bMsizwv2d)bRS(WpAlpLuQ7A9Vpl7nCefSJTYjbi73(TTb]] )

end