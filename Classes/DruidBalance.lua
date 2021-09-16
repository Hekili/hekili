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


    spec:RegisterPack( "Balance", 20210916, [[di1RtiqiIIhjLsDjOOytqPpjLIrPcoLk0QGc6vsjnlvc3sLOSlc)sLudtkvhJOYYGc9mPennIs6AqvSnOa9nOaghvLQZPsuToIs08uj5EQuTpQk(huuk1bLsyHqr6Hqv1ePQuCrOk1gPQu6JQejYivjsuNKQsSsIQEPkrcZukLCtvIu2juu9tvIunuvI4OqrPKLQsK0trftfkIRsvjTvOOu9vOOKXsuc7fq)vKblCyklgv9yQmzGUmYMf1NHkJwfDALwnuukETkLzJYTLIDl53GgoroouLSCfphY0v11LQTdW3rLgpuvopvvRNOuZNQSFsduoGycqoG2taXCm2ogLR9lxomOqomaEWa4PLa58(LiGCKm3ndhbKtzneqoyQXSYra5iz(zqdeiMaKdc2hhbKZ5)siz51xZBmRC0LH2gNa3(NDEXcVgtnMvo6Y4Sn4)6gqX53WWSDEz0DEJzLJep(EGC47l79LcipqoG2taXCm2ogLR9lxomOqomaEWaYkgbYX6)jCaYHZ2GFGCoxqqQaYdKdiHCa5GPgZkhPHVz6lOkphs6PgEA0qom4fAGX2XOCQ8Q84)0kCeswQYFzA0cqqcudoqMnAGPK1iu5VmnW)Pv4iqnEBWrFAZA4meH04HA487yu6Tbh9iHk)LPXLk1abqGA0RICeczJFnayZA8mcPXHvqIl0qAiaj0BdQp4inUmF0qAiac0BdQp4OJcv(ltJwaaUGAinKZq)w40aZAS)uJnRX(TbPXFsAWDGfonWBhBLqKqL)Y04sZUrAGFybaEJ04pjn4iTZ(inmny7)msJg4qAKze(wEgPXHnRHFyxJtdSAZRX5(ASVgOTPZERiyhX8Rb39p1atV0BbMOrRAGFIrOFnMgTGT4QgQ(l0y)2aQb62kDuOYFzACPz3inAGOxJ2KxCNFAOgBluB0a5OYMfI0WKKy(14HAWdrinYlUZhPbSy(fQ8xMgyYq2RbMaBinGznWuMDQbMYStnWuMDQHH0W0ajrU1yA8Zw3OxOYFzACPlrfnACyfK4cnWSg7pVqdmRX(Zl0GZBtEh6OgngiPrdCingcTSLQxJhQbzdBPrdhSH3(ld928cvEv(wuf8TNa1atnMvosJwCjTLgoR0GN0id7fOg2RX5)siz51xZBmRC0LH2gNa3(NDEXcVgtnMvo6Y4Sn4)6gqX53WWSDEz0DEJzLJep(EvEvEZ9lSqcPHCWgE7VFBlWHatiPD2hPYJjNKgaSznEgPXI0arVgpuJ21G7(NAuqnqV9Aaln6isJF26g9Ol0qon4EsLg)jPrEh0RbSinwKgWsJoIUqdmQXM14pjnqKdwGASinScuJwQXM1Gh(NAydPYBUFHfsinKd2WBFR3VgGnRXZOlkRHUdRuhrPF26g9xaWyD6E7Q8M7xyHesd5Gn82369RbyZA8m6IYAO7Wk1ru6NTUr)fqP7gi4famwNUl3fB((pBDJEHCItdL6ikX3ZzS)S1n6fYjCqideYTeG9X(fwyL5NTUrVqoXIepSHsWCQbwOFGDuYbl0pD3VWcPYBUFHfsinKd2WBFR3VgGnRXZOlkRHUdRuhrPF26g9xaLUBGGxaWyD6ogVyZ3)zRB0lWO40qPoIs89Cg7pBDJEbgfoiKbc5wcW(y)clSY8Zw3OxGrXIepSHsWCQbwOFGDuYbl0pD3VWcPYJjNeI04NTUrpsdBink4RH1FyJ9RZym)Aasp5EcuddPbS0OJinqV9A8Zw3Ohj0qdo0RbaBwJNrA8qnKvnmKg)j5xdJHGAuebQbsICRX040kq2w4eQ8M7xyHesd5Gn82369RbyZA8m6IYAO7Wk1ru6NTUr)fqP7gi4famwNUlRxS57eE1xjjcuSfYn934zucV6w99MeibyDKNhHx9vsIafuJK)HmwcoGLvoYZJWR(kjrGceSZy0)BHlnDE)Q8M7xyHesd5Gn82369RBGW62wPmCAu5n3VWcjKgYbB4TV17xZDS)8c2wuYbExU2VyZ3pqo2kHibRx2KkcFVNh5yReIeBLqqMnEEKJTsisSvIh(NEEKJTsisyL)ur47pQYRYFjd5m0Rbg1aZAS)udRa1W0GZBdQp4inGLgCWen4U)Pgy(I781W3AKgwbQbMcBbMObC0GZBtEhsd4Fsd3frQ8M7xyHeqjQOP17xZDS)8InF)a5yReIeSEztQi89EEKJTsisSvcbz245ro2kHiXwjE4F65ro2kHiHv(tfHV)iwPHaiKtWDS)eRmsdbqGrb3X(tvEZ9lSqcOev0069RrVn5DOlyBrjh4D8CXMVlZ0lkdhCKG3yw5OemNmgl9NBHd55jJdcGkRErT4o)u2ippzqseJLEBWrpsGEBYgJDxoppzEJr1lk77dHs8gZkhjOY4zeON3bYXwjejqqMnPIW375ro2kHiXwjwVSXZJCSvcrITs8W)0ZJCSvcrcR8NkcF)rvEZ9lSqcOev0069RrVnO(GJUGTfLCG3XZfB((0lkdhCKG3yw5OemNmgl9NBHdH1bbqLvVOwCNFkBewKeXyP3gC0JeO3MSXy3LtLxLhVXh56pbQbbGg)A8BdPXFsAyUhoASinma2YmEgju5n3VWcDhbz2K4jRrL3C)cluR3V2zmwYC)cReBr)fL1q3HsurZfB((Vn0vhWigAUFHLG7y)PWzOp9Bd1Q5(fwc0BtEhs4m0N(THoQYZHEKgTaI3AalnAzRAWD)ty)1aC28RHvGAWD)tn482WGdOgwbQbgBvd4Fsd3frQ8M7xyHA9(1aSznEgDrzn09fLmiDbaJ1P7ijIXsVn4OhjqVnzJX8roShK5ngvVa92WGdOGkJNrGEEVXO6fONymBsGZMFbvgpJap65HKigl92GJEKa92KngZhmQYZHEKgogzain4EsLgCEBY7qA4SsJZ91aJTQXBdo6rAW9CDNASingIraS61idhn(tsd82XwjePXd1GN0qAOmndbQHvGAW9CDNAKxgJgnEOgod9Q8M7xyHA9(1aSznEgDrzn09fLCmYaqxaWyD6osIyS0Bdo6rc0BtEhYh5u5XSBZA8msJ)0EnCNK7gsJnRHFyxdBin2sdtdCoqnEOgga4cQXFsAG2VB)cln4EsdPHPXpBDJEnO3PXI0OJiqn2sdE65suPHZqpsL3C)cluR3VgGnRXZOlkRHUVvcNd8cagRt3LgcGObcR8oKNN0qaeOEL3H88KgcGa92G6doYZtAiac0Bt2ymppPHaiY9XFcMteRxKNhFpNfolTLtmuJTf6oFpNfolTLta2h7xy55jneaXyaOc2rP8qLS975bWM14zKyrjdsQ8(kI0atPbrZTTWPb39p1a)T4AFPCAahnS8tJg4hwaG3in2sd83IR9LYPYBUFHfQ17xZtdIMBBH7InF)WbzCqauz1lQf35NYg55jJdczGqULWblaWBu6pPesAN9rIU0rS89Cw4S0woXqn2wiFKdpy575Symaub7OuEOs2(fd1yBHUswXkJdcGkREbaQ(t)JNNdcGkREbaQ(t)dw(EolCwAlNOlHLVNZIXaqfSJs5Hkz7x0LWEGVNZIXaqfSJs5Hkz7xmuJTf6k5K7YWdgo9IYWbhjqBL7S0PF0tZAEE89Cw4S0woXqn2wORKtopp5WmijIXsNg6PRKtGh8C8iwa2SgpJeBLW5av5Ve4Rb39p1W0a)T4AFPCA8N2RXIQ28AyACjDgYgnKgOtd4Ob3tQ04pjnYlUZxJfPHXd7VgpudQav5n3VWc169RLG)cRl28D(EolCwAlNyOgBlKpYHhShKz6fLHdosG2k3zPt)ONM188475Symaub7OuEOs2(fd1yBHUsomWLHrmKVNZcEgecY6Ox0LWY3ZzXyaOc2rP8qLS9l6sh984Hie28I78td1yBHUcJ4rLh)gZ1z2tin4Es)jnA0rBHtd8dlaWBKgfKRgCxgtdJXGC1WpSRXd1a9lJPHZqVg)jPbYAinSgyVEnGznWpSaaVrTI)wCTVuonCg6rQ8M7xyHA9(1aSznEgDrzn0DhSaaVrjqc5VCxaWyD6UJw2Hd5f35NgQX2cDzYHNlZbHmqi3s4S0woXqn2wOJyg5892pE3rl7WH8I78td1yBHUm5WZL5GqgiKBjCWca8gL(tkHK2zFKaSp2VW6YCqideYTeoybaEJs)jLqs7SpsmuJTf6iMroFV9JyLzSfmraO6fgiisq4BrpYZZbHmqi3s4S0woXqn2wiF26PrcYSNat5f35NgQX2c55n9IYWbhjCeJq)ASesAN9ryDqideYTeolTLtmuJTfYNw2UNNdczGqULWblaWBu6pPesAN9rIHASTq(S1tJeKzpbMYlUZpnuJTf6YKRDppzCqauz1lQf35NYgPY7RicuJhQbiXm)A8NKgDKHJ0aM1a)T4AFPCAW9Kkn6OTWPbiSZZinGLgDePHvGAineaQEn6idhPb3tQ0Wknmqqniau9ASinmEy)14HAaUKkV5(fwOwVFnaBwJNrxuwdD3bMCWcC)fwxaWyD6(H8I78td1yBH8ro845n2cMiau9cdeej2Yh80(rShoCGWR(kjrGcQrY)qglbhWYkhH9GdczGqULGAK8pKXsWbSSYrIHASTqxjhgSDppheavw9cau9N(hSoiKbc5wcQrY)qglbhWYkhjgQX2cDLCyqmqRhKtomC6fLHdosG2k3zPt)ONM1oEeRmoiKbc5wcQrY)qglbhWYkhjgYa9F0ZJWR(kjrGceSZy0)BHlnDE)ypiJdcGkRErT4o)u2ippheYaHClbc2zm6)TWLMoV)ulLv847TlNyOgBl0vYjNSE0Z7GdczGqULGNgen32cNyid0VNNmJ5iXpqg7i2dhi8QVsseOylKB6VXZOeE1T67njqcW6iShCqideYTeBHCt)nEgLWRUvFVjbsawhjgYa975zUFHLylKB6VXZOeE1T67njqcW6ib4ImEgbE8ON3bcV6RKebkqNgiKlbMGdFcMtpCAO6X6GqgiKBjE40q1tGPTqlUZp1s8GNwIr5ed1yBHo65D4aaBwJNrcyL6ik9Zw3O)UCEEaSznEgjGvQJO0pBDJ(7T8i2d)S1n6fYjgYa9NCqideYT88(zRB0lKt4GqgiKBjgQX2c5ZwpnsqM9eykV4o)0qn2wOltU2p65bWM14zKawPoIs)S1n6VJrSh(zRB0lWOyid0FYbHmqi3YZ7NTUrVaJcheYaHClXqn2wiF26PrcYSNat5f35NgQX2cDzY1(rppa2SgpJeWk1ru6NTUr)92pE8ONNdcGkREXn)ZA1rppEicHnV4o)0qn2wOR475SWzPTCcW(y)clvEm72SgpJ0OJiqnEOgGeZ8RHv(14NTUrpsdRa1WbI0G7jvAW12FlCAKHJgwPbE3LoHZAAinqNkV5(fwOwVFnaBwJNrxuwdD)pNLXsiIUrtIRT)famwNUldc2z8Bbk(ZzzSeIOB0iOY4zeONxEXD(PHASTq(GX2B3ZJhIqyZlUZpnuJTf6kmINwpiRTFz89Cw8NZYyjer3OrGEZDddX4rpp(Eol(ZzzSeIOB0iqV5U5tl99l7W0lkdhCKaTvUZsN(rpnRHH45OkVVIinW7gj)dzmnU0hWYkhPbgBhroKg8ugoKgMg4Vfx7lLtJoIeQ8M7xyHA9(1DeL2NAUOSg6o1i5FiJLGdyzLJUyZ3DqideYTeolTLtmuJTf6km2owheYaHClHdwaG3O0FsjK0o7Jed1yBHUcJTJ9aaBwJNrI)CwglHi6gnjU2(EE89Cw8NZYyjer3OrGEZDZNw2ERhMErz4GJeOTYDw60p6PznmedE8iwa2SgpJeBLW5a984Hie28I78td1yBHUQLyavEFfrAWb2zm63cNgxQDE)AGbrKdPbpLHdPHPb(BX1(s50OJiHkV5(fwOwVFDhrP9PMlkRHUJGDgJ(FlCPPZ7)InF)GdczGqULWzPTCIHASTqxHbXkJdcGkREbaQ(t)dwzCqauz1lQf35NYg555GaOYQxulUZpLncRdczGqULWblaWBu6pPesAN9rIHASTqxHbXEaGnRXZiHdwaG3OeiH8xoppheYaHClHZsB5ed1yBHUcdE0ZZbbqLvVaav)P)b7bzMErz4GJeOTYDw60p6PznSoiKbc5wcNL2YjgQX2cDfg0ZJVNZIXaqfSJs5Hkz7xmuJTf6k5K1wpGhmKWR(kjrGITq)0DpCqjWfWwuINySJy575Symaub7OuEOs2(fDPJEE8qecBEXD(PHASTqxHr845r4vFLKiqb1i5FiJLGdyzLJW6GqgiKBjOgj)dzSeCalRCKyOgBlKpyS9JybyZA8msSvcNdeRmeE1xjjcuSfYn934zucV6w99MeibyDKNNdczGqULylKB6VXZOeE1T67njqcW6iXqn2wiFWy7EE8qecBEXD(PHASTqxHX2v5BbJR5hPrhrA4ly2Y3Ob39p1a)T4AFPCQ8M7xyHA9(1aSznEgDrzn09fVatoybU)cRlaySoDNVNZcNL2YjgQX2c5JC4b7bzMErz4GJeOTYDw60p6Pznpp(EolgdavWokLhQKTFXqn2wORUlhgfyS1dTed575SGNbHGSo6fDPJTEW3Vm8GH89CwWZGqqwh9IU0rmKWR(kjrGITq)0DpCqjWfWwuINymS89CwmgaQGDukpujB)IU0rppEicHnV4o)0qn2wORWiE88i8QVsseOGAK8pKXsWbSSYryDqideYTeuJK)HmwcoGLvosmuJTfsL3C)cluR3VUJO0(uZfL1q33c5M(B8mkHxDR(EtcKaSo6InFhGnRXZiXIxGjhSa3FHfwa2SgpJeBLW5av59vePXS4oFn4PmCinCGivEZ9lSqTE)6oIs7tnxuwdDhDAGqUeyco8jyo9WPHQ)InF)GdczGqULWzPTCIHmq)yLXbbqLvVOwCNFkBewa2SgpJe)5Smwcr0nAsCT9XEWbHmqi3sWtdIMBBHtmKb63ZtMXCK4hiJD0ZZbbqLvVOwCNFkBewheYaHClHdwaG3O0FsjK0o7JedzG(XEaGnRXZiHdwaG3OeiH8xoppheYaHClHZsB5edzG(pEeli8fOEL3He)6UTfoShaHVa9eJztkZSHe)6UTfoppzEJr1lqpXy2KYmBibvgpJa98qseJLEBWrpsGEBY7q(0YJybHVObcR8oK4x3TTWH9aaBwJNrIfLmi55n9IYWbhj4nMvokbZjJXs)5w4qEEg6hJLKGCPXN7xE7EEaSznEgjCWca8gLajK)Y55X3ZzbpdcbzD0l6shXkdHx9vsIafBHCt)nEgLWRUvFVjbsawh55r4vFLKiqXwi30FJNrj8QB13BsGeG1ryDqideYTeBHCt)nEgLWRUvFVjbsawhjgQX2c5tlBhRm89Cw4S0worxYZJhIqyZlUZpnuJTf6kzTDvEm5CrASinmng7pPrdIz8WXEsdUMFnEOgn2nsdJX0awA0rKgO3En(zRB0J04HAWtAW2Ia1OlPb39p1a)T4AFPCAyfOg4hwaG3inScuJoI04pjnWybQbIbFnGLgoqn2Sg8W)uJF26g9inSH0awA0rKgO3En(zRB0Ju5n3VWc169R7ikTp1GUaXGp6(pBDJE5UyZ3paWM14zKawPoIs)S1n6L5UCyL5NTUrVaJIHmq)jheYaHClpVdaSznEgjGvQJO0pBDJ(7Y55bWM14zKawPoIs)S1n6V3YJypW3ZzHZsB5eDjShKXbbqLvVaav)P)XZJVNZIXaqfSJs5Hkz7xmuJTfQ1d4bdNErz4GJeOTYDw60p6PzTJxD)NTUrVqobFpNtG9X(fwy575Symaub7OuEOs2(fDjpp(EolgdavWokLhQKT)eARCNLo9JEAwt0Lo655GqgiKBjCwAlNyOgBluRy0NF26g9c5eoiKbc5wcW(y)clSYW3ZzHZsB5eDjShKXbbqLvVOwCNFkBKNNmaSznEgjCWca8gLajK)YDeRmoiaQS6f38pRvEEoiaQS6f1I78tzJWcWM14zKWblaWBucKq(lhwheYaHClHdwaG3O0FsjK0o7JeDjSY4GqgiKBjCwAlNOlH9Wb(EolihBLquI1lBed1yBH8rU298475SGCSvcrjeKzJyOgBlKpY1(rSYm9IYWbhj4nMvokbZjJXs)5w4qEEh475SG3yw5OemNmgl9NBHdLk77djqV5UDhpEE89CwWBmRCucMtgJL(ZTWHs24SIeO3C3U77hp65X3ZzXTTahcmrnsqU00q1NOIgCRSjrx6ONhpeHWMxCNFAOgBl0vySDppa2SgpJeWk1ru6NTUr)92pIfGnRXZiXwjCoqvEZ9lSqTE)6oIs7tnOlqm4JU)Zw3OhJxS57hayZA8msaRuhrPF26g9YChJyL5NTUrVqoXqgO)KdczGqULNhaBwJNrcyL6ik9Zw3O)ogXEGVNZcNL2Yj6sypiJdcGkREbaQ(t)JNhFpNfJbGkyhLYdvY2VyOgBluRhWdgo9IYWbhjqBL7S0PF0tZAhV6(pBDJEbgf89Cob2h7xyHLVNZIXaqfSJs5Hkz7x0L88475Symaub7OuEOs2(tOTYDw60p6Pznrx6ONNdczGqULWzPTCIHASTqTIrF(zRB0lWOWbHmqi3sa2h7xyHvg(EolCwAlNOlH9GmoiaQS6f1I78tzJ88KbGnRXZiHdwaG3OeiH8xUJyLXbbqLvV4M)zTc7bz475SWzPTCIUKNNmoiaQS6faO6p9ph98Cqauz1lQf35NYgHfGnRXZiHdwaG3OeiH8xoSoiKbc5wchSaaVrP)KsiPD2hj6syLXbHmqi3s4S0worxc7Hd89Cwqo2kHOeRx2igQX2c5JCT75X3Zzb5yReIsiiZgXqn2wiFKR9JyLz6fLHdosWBmRCucMtgJL(ZTWH88oW3ZzbVXSYrjyozmw6p3chkv23hsGEZD7oE88475SG3yw5OemNmgl9NBHdLSXzfjqV5UD33pE8ONhFpNf32cCiWe1ib5stdvFIkAWTYMeDjppEicHnV4o)0qn2wORWy7EEaSznEgjGvQJO0pBDJ(7TFelaBwJNrITs4CGQ8(kIqAymMgW)KgnGLgDePX(udsdyPHduL3C)cluR3VUJO0(udsL33qUfK0WC)clnyl61G3qeOgWsd0(D7xyDnJWTivEZ9lSqTE)6PxjZ9lSsSf9xuwdD3G0fOFw3FxUl28Da2SgpJelkzqsL3C)cluR3VE6vYC)cReBr)fL1q35H2Fb6N193L7InFF6fLHdosWBmRCucMtgJL(ZTWHeeE1xjjcuL3C)cluR3VE6vYC)cReBr)fL1q3rVkVkp(nMRZSNqAW9K(tA04pjn8ndzno7DN0ObFpN1G7YyAKngtdyoRb39p3sJ)K0Oi89A4m0RYBUFHfsyq6oaBwJNrxuwdDhCiRjXDzSu2ySemNVaGX609d89Cw8BdXfovcCiRHFlqAed1yBHUcNdu0y4R12fY55X3ZzXVnex4ujWHSg(TaPrmuJTf6kZ9lSeO3M8oKGWh56pL(THATDHCypqo2kHiXwjwVSXZJCSvcrceKztQi89EEKJTsisyL)ur47pEelFpNf)2qCHtLahYA43cKgrxc70lkdhCK43gIlCQe4qwd)wG0OYJFJ56m7jKgCpP)Kgn482G6dosJfPbx48NA4m0VfonGaOrdoVn5Din2sJ2Qx2ObE7yReIu5n3VWcjmi169RbyZA8m6IYAO7lUcouc92G6do6cagRt3LHCSvcrITsiiZgShqseJLEBWrpsGEBY7q(GhSVXO6fiyNLG50FsPmCi0lOY4zeONhsIyS0Bdo6rc0BtEhYhmWrvEFfrAGFybaEJ0G7jvAyVgmcH04pTsd80UgTaDjAyfOgSTin6sAWD)tnWFlU2xkNkV5(fwiHbPwVFTdwaG3O0FsjK0o7JUyZ3LbC6lOOGjhic7HdaSznEgjCWca8gLajK)YHvgheYaHClHZsB5edzG(98475SWzPTCIU0rSh475SGCSvcrjwVSrmuJTfYhmONhFpNfKJTsikHGmBed1yBH8bdEe7bzMErz4GJe8gZkhLG5KXyP)ClCipp(Eol4nMvokbZjJXs)5w4qPY((qc0BUB(0spp(Eol4nMvokbZjJXs)5w4qjBCwrc0BUB(0YJEE8qecBEXD(PHASTqxjx7yLXbHmqi3s4S0woXqgO)JQ8(kI0W3oujB)AWD)tnWFlU2xkNkV5(fwiHbPwVF9yaOc2rP8qLS9FXMVZ3ZzHZsB5ed1yBH8ro8OY7Risdo9kVdPXwAizfi1SonGLgw5)p3cNg)P9AWwaesd5Kve5qAyfOgmcH0G7(NA0ahsJ3gC0J0WkqnSxJ)K0GkqnGznmn4az2ObE7yReI0WEnKtw1aroKgWrdgHqAmuJT1w40WqA8qnk4RXPbylCA8qngkpe6udW(SfonAREzJg4TJTsisL3C)clKWGuR3Vg1R8o0fo)ogLEBWrp6UCxS57hgkpe604zKNhFpNfKJTsikHGmBed1yBHUQLyjhBLqKyRecYSb7qn2wORKtwX(gJQxGGDwcMt)jLYWHqVGkJNrGhX(2GJEXVnu6HjWL8roz9YqseJLEBWrpQ1HASTqypqo2kHiXwjR875nuJTf6kCoqrJHVJQ8(kI0GtVY7qA8qnonaKgMg4yqEJPXd1OJin8fmB5Bu5n3VWcjmi169Rr9kVdDXMVdWM14zKyXlWKdwG7VWcRdczGqULylKB6VXZOeE1T67njqcW6iXqgOFSeE1xjjcuSfYn934zucV6w99MeibyDKkV5(fwiHbPwVFn6TjBm2fB(UmVXO6fONymBsGZMFbvgpJaXEGVNZc0Bt2ymXq5HqNgpJWEajrmw6Tbh9ib6TjBm2vT0ZtMPxugo4iXVnex4ujWHSg(TaP5ON3BmQEbc2zjyo9Nukdhc9cQmEgbILVNZcYXwjeLqqMnIHASTqx1sSKJTsisSvcbz2GLVNZc0Bt2ymXqn2wORWayrseJLEBWrpsGEBYgJ5ZDz9i2dYm9IYWbhjy(D2yOuMr0VfUeo22iHipVFBimdMrwXJp89CwGEBYgJjgQX2c1kgpI9Tbh9IFBO0dtGl5dEu5XS2)udopXy2OHVz28RrhrAalnCGAW9Kkngkpe604zKg89xd0VmMgCT91idhnAl)oBmKgsd0PHvGAacR28A0rKg8ugoKg433GeAW5xgtJoI0GNYWH0a)Wca8gPbAlhPXFAVgCxgtdPb60Wk4FsJgCEBYgJPYBUFHfsyqQ17xJEBYgJDXMV)gJQxGEIXSjboB(fuz8mcelFpNfO3MSXyIHYdHonEgH9GmtVOmCWrcMFNngkLze9BHlHJTnsiYZ73gcZGzKv84JSEe7Bdo6f)2qPhMaxYNwQYJzT)Pg(MHSg(TaPrJoI0GZBt2ymnEOg3issJUKg)jPbFpN1G3Vggdb1OJ2cNgCEBYgJPbS0apAGihSarAahnyecPXqn2wBHtL3C)clKWGuR3Vg92Kng7InFF6fLHdos8BdXfovcCiRHFlqAWIKigl92GJEKa92KngZN7Te7bz475S43gIlCQe4qwd)wG0i6sy575Sa92KngtmuEi0PXZipVdaSznEgjahYAsCxglLnglbZzSh475Sa92KngtmuJTf6Qw65HKigl92GJEKa92KngZhmI9ngvVa9eJztcC28lOY4zeiw(EolqVnzJXed1yBHUcphpEuLh)gZ1z2tin4Es)jnAyAW5Tb1hCKgDePb3LX0WzDePbN3MSXyA8qnYgJPbmNVqdRa1OJin482G6dosJhQXnIK0W3mK1WVfinAGEZDtJUKkV5(fwiHbPwVFnaBwJNrxuwdDh92KnglXfwFkBmwcMZxaWyD6UH(XyjjixA8X3B)Yoix7yiFpNf)2qCHtLahYA43cKgb6n3TJx2b(EolqVnzJXed1yBHWWwIzqseJLon0tyOmVXO6fONymBsGZMFbvgpJapEzhCqideYTeO3MSXyIHASTqyylXmijIXsNg6jm8ngvVa9eJztcC28lOY4ze4Xl7ai8f5(4pbZjI1lsmuJTfcdXZrSh475Sa92Kngt0L88CqideYTeO3MSXyIHASTqhv59vePbN3guFWrAWD)tn8ndzn8BbsJgpuJBejPrxsJ)K0GVNZAWD)ty)1GbrBHtdoVnzJX0Ol9BdPHvGA0rKgCEBq9bhPbS0qwBvdmf2cmrd0BUBin61VmnKvnEBWrpsL3C)clKWGuR3Vg92G6do6InFhGnRXZib4qwtI7YyPSXyjyoJfGnRXZib6TjBmwIlS(u2ySemNXkdaBwJNrIfxbhkHEBq9bh55DGVNZcEJzLJsWCYyS0FUfouQSVpKa9M7MpT0ZJVNZcEJzLJsWCYyS0FUfouYgNvKa9M7MpT8iwKeXyP3gC0JeO3MSXyxjRybyZA8msGEBYgJL4cRpLnglbZzvEFfrAG4AtJgiOg)P9A4h21ah9A0y4tJU0VnKg8(1OJ2cNg7RHH0GzpPHH0qcIqlpJ0awAWiesJ)0knAPgO3C3qAahnWSPJEn4EsLgTSvnqV5UH0GWN0oKkV5(fwiHbPwVFTbAs)cGsiU20CHZVJrP3gC0JUl3fB(Um)6UTfoSYyUFHLWanPFbqjexBAsGwJHJeBLYSf3575bcFHbAs)cGsiU20KaTgdhjqV5UDvlXccFHbAs)cGsiU20KaTgdhjgQX2cDvlv5VuP8qOtnU0GWkVdPXM1a)T4AFPCASingYa9FHg)jnKg2qAWiesJ)0knWJgVn4OhPXwA0w9YgnWBhBLqKgC3)udoW33EHgmcH04pTsd5Axd4Fsd3frASLgw5xd82XwjePbC0OlPXd1apA82GJEKg8ugoKgMgTvVSrd82Xwjej0W3aR28AmuEi0PgG9zlCACPylWHa1aVBKGCPPHQxJEXiesJT0GdKzJg4TJTsisL3C)clKWGuR3VUbcR8o0fo)ogLEBWrp6UCxS57dLhcDA8mc7Bdo6f)2qPhMaxYNdhKtwB9asIyS0Bdo6rc0BtEhcdXigY3Zzb5yReIsSEzJOlD8yRd1yBHoIzoixRVXO6fp3TsnqyHeuz8mc8i2doiKbc5wcNL2YjgYa9JvgWPVGIcMCGiShayZA8ms4Gfa4nkbsi)LZZZbHmqi3s4Gfa4nk9NucjTZ(iXqgOFppzCqauz1lQf35NYgD0Zdjrmw6Tbh9ib6TjVdD1HdyWl7aFpNfKJTsikX6LnIUegIXJhXWdY16BmQEXZDRudewibvgpJapEeRmKJTsisGGmBsfHV3Z7a5yReIeBLqqMnEEhihBLqKyRep8p98ihBLqKyReRx2CeRmVXO6fiyNLG50FsPmCi0lOY4zeONhFpNfsZ2ahW1yjBCwTUKuNHSraWyDYN7yepTFe7bKeXyP3gC0JeO3M8o0vY1ogEqUwFJr1lEUBLAGWcjOY4ze4XJyn0pgljb5sJp4P9lJVNZc0Bt2ymXqn2wimedEe7bz475S42wGdbMOgjixAAO6turdUv2KOl55ro2kHiXwjeKzJNNmoiaQS6f38pRvhXkdFpNfJbGkyhLYdvY2FcTvUZsN(rpnRj6sQ8(kI0W3cXCnGLgoqn4U)jS)A4mjPTWPYBUFHfsyqQ17xNHJJsWCQSVp0fB(UjLCNK7MkV5(fwiHbPwVFnaBwJNrxuwdD3bMCWcC)fwjdsxaWyD6UmGtFbffm5arybyZA8ms4atoybU)clShoW3Zzb6TjBmMOl559gJQxGEIXSjboB(fuz8mc0ZZbbqLvVOwCNFkB0rShKHVNZceKH(1rIUewz475SWzPTCIUe2dY8gJQxK7J)emNiwVibvgpJa98475SWzPTCcW(y)clFCqideYTe5(4pbZjI1lsmuJTfQvF)iwa2SgpJe)5Smwcr0nAsCT9XEqgheavw9IAXD(PSrEEoiKbc5wchSaaVrP)KsiPD2hj6sypW3Zzb6TjBmMyOgBl0vy0ZtM3yu9c0tmMnjWzZVGkJNrGhpI9Tbh9IFBO0dtGl5dFpNfolTLta2h7xyHHTlWah984Hie28I78td1yBHUIVNZcNL2Yja7J9lSoQY7Risd83IR9LYPbS0WbQrVyecPHvGAW2I0yFn6sAWD)tnWpSaaVrQ8M7xyHegKA9(1oIrOFnwYylUQHQ)InFhGnRXZiHdm5Gf4(lSsgKu5n3VWcjmi169R3Yztz)cRl28Da2SgpJeoWKdwG7VWkzqsL3xrKg4DJeKlnAGPWcudyPHdudU7FQbN3MSXyA0L0WkqnqgasJmC04s6mKnAyfOg4Vfx7lLtL3C)clKWGuR3VMAKGCPjXdlWl28DEicHDRNgjiZEcmLxCNFAOgBl0vYHhpVd89CwinBdCaxJLSXz16ssDgYgbaJ1PRWiEA3ZJVNZcPzBGd4ASKnoRwxsQZq2iaySo5ZDmIN2pILVNZc0Bt2ymrxc7bheYaHClHZsB5ed1yBH8bpT75bo9fuuWKdeDuL)sLYdHo1iZSH0awA0L04HA0snEBWrpsdU7Fc7Vg4Vfx7lLtdEAlCAy8W(RXd1GWN0oKgwbQrbFnGaOXzssBHtL3C)clKWGuR3Vg9eJztkZSHUW53XO0Bdo6r3L7InFFO8qOtJNry)THspmbUKpYHhSijIXsVn4OhjqVn5DORKvSMuYDsUBypW3ZzHZsB5ed1yBH8rU298KHVNZcNL2Yj6shv59vePHVfI3ASzn2cTGKgwPbE7yReI0WkqnyBrASVgDjn4U)PgMgxsNHSrdPb60WkqnAbOj9lasdoCTPrL3C)clKWGuR3Vo3h)jyorSErxS57KJTsisSvYk)ynPK7KC3WY3ZzH0SnWbCnwYgNvRlj1ziBeamwNUcJ4PDShaHVWanPFbqjexBAsGwJHJe)6UTfoppzCqauz1lkYnqgCa98qseJLEBWrpYhmEe7b(EolgdavWokLhQKTFXqn2wORU8l7aEWWPxugo4ibARCNLo9JEAw7iw(EolgdavWokLhQKTFrxYZtg(EolgdavWokLhQKTFrx6i2dY4GqgiKBjCwAlNOl55X3ZzXFolJLqeDJgb6n3TRKdpyZlUZpnuJTf6km2E7yZlUZpnuJTfYh5AVDppzqWoJFlqXFolJLqeDJgbvgpJapI9ac2z8Bbk(ZzzSeIOB0iOY4zeONNdczGqULWzPTCIHASTq(0Y2pQY7RisdtdoVnzJX04sVO)udPb60OxmcH0GZBt2ymnwKggBid0VgDjnGJg(HDnSH0W4H9xJhQbeanotsJwGUevEZ9lSqcdsTE)A0Bt2ySl28D(EolGf9NOKenos6xyj6sypW3Zzb6TjBmMyO8qOtJNrEEg6hJLKGCPXNlV9JQ8(MEJKgTaDjAWtz4qAGFybaEJ0G7(NAW5TjBmMgwbQXFsLgCEBq9bhPYBUFHfsyqQ17xJEBYgJDXMV7GaOYQxulUZpLncRmVXO6fONymBsGZMFbvgpJaXEaGnRXZiHdwaG3OeiH8xoppheYaHClHZsB5eDjpp(EolCwAlNOlDeRdczGqULWblaWBu6pPesAN9rIHASTqxHZbkAm8HHoAzhm0pgljb5sdMbpTFelFpNfO3MSXyIHASTqxjRyLbC6lOOGjhisL3C)clKWGuR3Vg92G6do6InF3bbqLvVOwCNFkBe2daSznEgjCWca8gLajK)Y555GqgiKBjCwAlNOl55X3ZzHZsB5eDPJyDqideYTeoybaEJs)jLqs7SpsmuJTf6kmiw(EolqVnzJXeDjSKJTsisSvYk)yLbGnRXZiXIRGdLqVnO(GJWkd40xqrbtoqKkVVIin482G6dosdU7FQHvACPx0FQH0aDAahn2Sg(H92aQbeanotsJwGUen4U)Pg(H9rJIW3RHZqVqJwWqqna7nsA0c0LOH9A8NKgubQbmRXFsAGzNQ)0)ObFpN1yZAW5TjBmMgCHDgy1MxJSXyAaZznGJg(HDnSH0awAGrnEBWrpsL3C)clKWGuR3Vg92G6do6InFNVNZcyr)jk5yKnjalAHLOl55Dqg0BtEhsysj3j5UHvga2SgpJelUcouc92G6doYZ7aFpNfolTLtmuJTf6k8GLVNZcNL2Yj6sEEhoW3ZzHZsB5ed1yBHUcNdu0y4ddD0YoyOFmwscYLgmtlB)iw(EolCwAlNOl55X3ZzXyaOc2rP8qLS9NqBL7S0PF0tZAIHASTqxHZbkAm8HHoAzhm0pgljb5sdMPLTFelFpNfJbGkyhLYdvY2FcTvUZsN(rpnRj6shX6GaOYQxaGQ)0)C8i2dijIXsVn4OhjqVnzJXUQLEEaSznEgjqVnzJXsCH1NYgJLG58XJyLbGnRXZiXIRGdLqVnO(GJWEqMPxugo4iXVnex4ujWHSg(TaPXZdjrmw6Tbh9ib6TjBm2vT8OkVVIinU0GWcPXwAWbYSrd82XwjePHvGAGmaKg(2oJPXLgewAKHJg4Vfx7lLtL3C)clKWGuR3VUiUPgiSUyZ3pW3Zzb5yReIsiiZgXqn2wiFi8rU(tPFBipVdUtBWrO7ye7qUtBWrPFBORWZrpp3Pn4i09wEeRjLCNK7MkV5(fwiHbPwVF9PXYPgiSUyZ3pW3Zzb5yReIsiiZgXqn2wiFi8rU(tPFBipVdUtBWrO7ye7qUtBWrPFBORWZrpp3Pn4i09wEeRjLCNK7g2d89CwmgaQGDukpujB)IHASTqxHhS89CwmgaQGDukpujB)IUewzMErz4GJeOTYDw60p6Pznppz475Symaub7OuEOs2(fDPJQ8M7xyHegKA9(15oJLAGW6InF)aFpNfKJTsikHGmBed1yBH8HWh56pL(THWEWbHmqi3s4S0woXqn2wiFWt7EEoiKbc5wchSaaVrP)KsiPD2hjgQX2c5dEA)ON3b3Pn4i0DmIDi3Pn4O0Vn0v45ONN70gCe6ElpI1KsUtYDd7b(EolgdavWokLhQKTFXqn2wORWdw(EolgdavWokLhQKTFrxcRmtVOmCWrc0w5olD6h90SMNNm89CwmgaQGDukpujB)IU0rvEFfrAGzbXBnGLg433OYBUFHfsyqQ17xZ1MzHtcMteRxKkp(nMRZSNqAW9K(tA04HA0rKgCEBY7qASLgCGmB0G756o1yrAyVg4rJ3gC0JAvonYWrdcan(1aJTJz0OXqpn(1aoAiRAW5Tb1hCKg4DJeKlnnu9AGEZDdPYBUFHfsyqQ17xdWM14z0fL1q3rVn5DO0wjeKzZfamwNUJKigl92GJEKa92K3H8rwBnZGW5qJHEA8NaySoHHY1E7ygm2(XwZmiCoW3Zzb6Tb1hCuIAKGCPPHQpHGmBeO3C3WmY6rvE8BmxNzpH0G7j9N0OXd1aZAS)udW(Sfon8TdvY2VkV5(fwiHbPwVFnaBwJNrxuwdDN7y)zARuEOs2(VaGX60D5WmijIXsNg6PRW4LDODbgXWdijIXsVn4OhjqVn5DOltUJy4b5A9ngvVab7SemN(tkLHdHEbvgpJaXq5e454XwBxihEWq(EolgdavWokLhQKTFXqn2wivEFfrAGzn2FQXwAWbYSrd82XwjePbC0yZAuqn482K3H0G7YyAK3xJTEOg4Vfx7lLtdR83ahsL3C)clKWGuR3VM7y)5fB((bYXwjejy9YMur4798ihBLqKWk)PIW3JfGnRXZiXIsogzaOJyp82GJEXVnu6HjWL8rw98ihBLqKG1lBsBLWONxEXD(PHASTqxjx7h98475SGCSvcrjeKzJyOgBl0vM7xyjqVn5DibHpY1Fk9BdHLVNZcYXwjeLqqMnIUKNh5yReIeBLqqMnyLbGnRXZib6TjVdL2kHGmB88475SWzPTCIHASTqxzUFHLa92K3Hee(ix)P0VnewzayZA8msSOKJrgaclFpNfolTLtmuJTf6kcFKR)u63gclFpNfolTLt0L88475Symaub7OuEOs2(fDjSaSznEgj4o2FM2kLhQKTFppzayZA8msSOKJrgaclFpNfolTLtmuJTfYhcFKR)u63gsL3xrKgCEBY7qASzn2sJ2Qx2ObE7yReIUqJT0GdKzJg4TJTsisdyPHS2QgVn4OhPbC04HAinqNgCGmB0aVDSvcrQ8M7xyHegKA9(1O3M8oKkVV1yS)C6Q8M7xyHegKA9(1tVsM7xyLyl6VOSg6E2yS)C6Q8Q8(2Hkz7xdU7FQb(BX1(s5u5n3VWcj4H2FFmaub7OuEOs2(VyZ3575SWzPTCIHASTq(ihEu59vePrlanPFbqAWHRnnAW9KknSxdgHqA8NwPHSQbMcBbMOb6n3nKgwbQXd1yO8qOtnmnU6og1a9M7MggsdM9KggsdjicT8msd4OXVnKg7RbcQX(AyZSaiKgy20rVgw(PrdtJw2QgO3C30GWN0oesL3C)clKGhAFR3V2anPFbqjexBAUW53XO0Bdo6r3L7InFNVNZcEJzLJsWCYyS0FUfouQSVpKa9M72v(ow(Eol4nMvokbZjJXs)5w4qjBCwrc0BUBx57ypidi8fgOj9lakH4Attc0AmCK4x3TTWHvgZ9lSegOj9lakH4Attc0AmCKyRuMT4oFShKbe(cd0K(faLqCTPjDsgt8R72w488aHVWanPFbqjexBAsNKXed1yBH8PLh98aHVWanPFbqjexBAsGwJHJeO3C3UQLybHVWanPFbqjexBAsGwJHJed1yBHUcpybHVWanPFbqjexBAsGwJHJe)6UTfUJQ8(kI0a)Wca8gPb39p1a)T4AFPCAW9KknKGi0YZinScud4Fsd3frAWD)tnmnWuylWen475SgCpPsdqc5VCBHtL3C)clKGhAFR3V2blaWBu6pPesAN9rxS57Yao9fuuWKdeH9Wba2SgpJeoybaEJsGeYF5WkJdczGqULWzPTCIHmq)EE89Cw4S0worx6i2d89CwWBmRCucMtgJL(ZTWHsL99HeO3C3U77EE89CwWBmRCucMtgJL(ZTWHs24SIeO3C3U77h984Hie28I78td1yBHUsU2X6GqgiKBjCwAlNyOgBlKpyGJQ8(wiERHH04pjnY7GEnW5a1yln(tsdtdmf2cmrdUBbc5QbC0G7(NA8NKgxk8pRvAW3ZznGJgC3)udtdFVve50OfGM0Vain4W1MgnScudU2(AKHJg4Vfx7lLtJnRX(AWfwVg8KgDjnmC2wAWtz4qA8NKgoqnwKg5Tw0jbQYBUFHfsWdTV17xN7J)emNiwVOl289dhoW3ZzbVXSYrjyozmw6p3chkv23hsGEZDZhmONhFpNf8gZkhLG5KXyP)ClCOKnoRib6n3nFWGhXEqgheavw9cau9N(hppz475Symaub7OuEOs2(fDPJhXEaC6lOOGjhiYZZbHmqi3s4S0woXqn2wiFWt7EEhCqauz1lQf35NYgH1bHmqi3s4Gfa4nk9NucjTZ(iXqn2wiFWt7hpE0Z7ai8fgOj9lakH4Attc0AmCKyOgBlKp(owheYaHClHZsB5ed1yBH8rU2X6GaOYQxuKBGm4aE0ZBRNgjiZEcmLxCNFAOgBl0v(owzCqideYTeolTLtmKb63ZZbbqLvV4M)zTclFpNf32cCiWe1ib5stdvVOl555GaOYQxaGQ)0)GLVNZIXaqfSJs5Hkz7xmuJTf6QlhlFpNfJbGkyhLYdvY2VOlPYJFRCetdoVnm4aQb39p1W0OiUAGPWwGjAW3ZznScud83IR9LYPXIQ28Ay8W(RXd1GN0OJiqvEZ9lSqcEO9TE)ANvoIL4758fL1q3rVnm4aEXMVFGVNZcEJzLJsWCYyS0FUfouQSVpKyOgBlKpyabE88475SG3yw5OemNmgl9NBHdLSXzfjgQX2c5dgqGNJyp4GqgiKBjCwAlNyOgBlKpyapVdoiKbc5wcQrcYLMepSafd1yBH8bdGvg(EolUTf4qGjQrcYLMgQ(ev0GBLnj6syDqauz1lU5FwRoEeRH(XyjjixA85ElBxL330BK0GZBdQp4iKgC3)udtdmf2cmrd(EoRbF)1OGVgCpPsdjiKTfonYWrd83IR9LYPbC04sXwGdbQbhPD2hPY7(fwibp0(wVFn6Tb1hC0fB((b(Eol4nMvokbZjJXs)5w4qPY((qc0BUB(Grpp(Eol4nMvokbZjJXs)5w4qjBCwrc0BUB(GXJypCqgheavw9IAXD(PSrEEg6hJLKGCPXN7YA7hX6GqgiKBjCwAlNyOgBlKpyappzayZA8ms4atoybU)clSY4GaOYQxCZ)Sw55DWbHmqi3sqnsqU0K4HfOyOgBlKpyaSYW3ZzXTTahcmrnsqU00q1NOIgCRSjrxcRdcGkREXn)ZA1XJypidi8f5(4pbZjI1ls8R72w488KXbHmqi3s4S0woXqgOFppzCqideYTeoybaEJs)jLqs7SpsmKb6)OkVVP3iPbN3guFWrin4PmCinWpSaaVrQ8M7xyHe8q7B9(1O3guFWrxS57hCqideYTeoybaEJs)jLqs7SpsmuJTf6k8GvgWPVGIcMCGiShayZA8ms4Gfa4nkbsi)LZZZbHmqi3s4S0woXqn2wORWZrSaSznEgjCGjhSa3FH1rSYacFrUp(tWCIy9Ie)6UTfoSoiaQS6f1I78tzJWkd40xqrbtoqewYXwjej2kzLFSg6hJLKGCPXhzTDvEFdSAZRbi81aSpBHtJ)K0GkqnGznUunaub7in8TdvY2)fAa2NTWPXTTahcudQrcYLMgQEnGJgBPXFsAWm0RbohOgWSgwPbE7yReIu5n3VWcj4H2369RbyZA8m6IYAO7GWpneE13HAO6rxaWyD6(b(EolgdavWokLhQKTFXqn2wiFWJNNm89CwmgaQGDukpujB)IU0rSh475S42wGdbMOgjixAAO6turdUv2KyOgBl0v4CGIgdFhXEGVNZcYXwjeLqqMnIHASTq(GZbkAm855X3Zzb5yReIsSEzJyOgBlKp4CGIgdFhv5n3VWcj4H2369Rr9kVdDHZVJrP3gC0JUl3fB((q5HqNgpJW(2GJEXVnu6HjWL8romiwtk5oj3nSaSznEgjaHFAi8QVd1q1Ju5n3VWcj4H2369RBGWkVdDHZVJrP3gC0JUl3fB((q5HqNgpJW(2GJEXVnu6HjWL8rUwkWdwtk5oj3nSaSznEgjaHFAi8QVd1q1Ju5n3VWcj4H2369RrpXy2KYmBOlC(Dmk92GJE0D5UyZ3hkpe604ze23gC0l(THspmbUKpYHbBDOgBlewtk5oj3nSaSznEgjaHFAi8QVd1q1Ju59TqmxdyPHdudU7Fc7VgotsAlCQ8M7xyHe8q7B9(1z44OemNk77dDXMVBsj3j5UPYJ3nsqU0ObMclqn4EsLggpS)A8qnO6PrdtJI4QbMcBbMOb3TaHC1WkqnqgasJmC0a)T4AFPCQ8M7xyHe8q7B9(1uJeKlnjEybEXMVFGCSvcrcwVSjve(EppYXwjejqqMnPIW375ro2kHiHv(tfHV3ZJVNZcEJzLJsWCYyS0FUfouQSVpKyOgBlKpyabE88475SG3yw5OemNmgl9NBHdLSXzfjgQX2c5dgqGhppd9JXssqU04ZL3owheYaHClHZsB5edzG(Xkd40xqrbtoq0rShCqideYTeolTLtmuJTfYNw2UNNdczGqULWzPTCIHmq)h984Hie2TEAKGm7jWuEXD(PHASTqxjx7Q8(wiERXS4oFn4PmCin6OTWPb(BHkV5(fwibp0(wVFDUp(tWCIy9IUyZ3DqideYTeolTLtmKb6hlaBwJNrchyYblW9xyH9GH(XyjjixA85YBhRmoiaQS6f1I78tzJ88Cqauz1lQf35NYgH1q)ySKeKlnxjRTFeRmoiaQS6faO6p9pypiJdcGkRErT4o)u2ippheYaHClHdwaG3O0FsjK0o7JedzG(pIvgWPVGIcMCGivE83IR9LYPb3tQ0WEnU82BvJwGUenoahgKlnA8NwPHS2UgTaDjAWD)tnWpSaaVrh1G7(NW(RbdI2cNg)2qASLgykdcbzD0RHvGAW2I0OlPb39p1a)Wca8gPXM1yFn4AinajK)YrGQ8M7xyHe8q7B9(1aSznEgDrzn0DhyYblW9xyL4H2FbaJ1P7Yao9fuuWKdeHfGnRXZiHdm5Gf4(lSWE4GH(XyjjixA85YBh7b(EolUTf4qGjQrcYLMgQ(ev0GBLnj6sEEY4GaOYQxCZ)SwD0ZJVNZcEgecY6Ox0LWY3ZzbpdcbzD0lgQX2cDfFpNfolTLta2h7xyD0ZJhIqy36PrcYSNat5f35NgQX2cDfFpNfolTLta2h7xy555GaOYQxulUZpLn6i2dY4GaOYQxulUZpLnYZ7GH(XyjjixAUswB3Zde(ICF8NG5eX6fj(1DBlChXEaGnRXZiHdwaG3OeiH8xoppheYaHClHdwaG3O0FsjK0o7JedzG(pEuL3C)clKGhAFR3V2rmc9RXsgBXvnu9xS57aSznEgjCGjhSa3FHvIhAVkV5(fwibp0(wVF9woBk7xyDXMVdWM14zKWbMCWcC)fwjEO9Q84n63g7jKgNqUA00DNA0c0LOHnKg4STiqnKOrde5GfOkV5(fwibp0(wVFnaBwJNrxuwdD3qsxcnCi3famwNUto2kHiXwjwVSbd9DmJ5(fwc0BtEhsq4JC9Ns)2qTkd5yReIeBLy9Ygm8agS13yu9ceSZsWC6pPugoe6fuz8mcedB5rmJ5(fwcUJ9NccFKR)u63gQ12fyeZGKiglDAONu59n9gjn482G6docPb3tQ04pjnYlUZxJfPHXd7VgpudQaVqJ8qLS9RXI0W4H9xJhQbvGxOHFyxdBinSxJlV9w1OfOlrJT0WknWBhBLq0fAG)wCTVuonyg6rAyf8pPrdFVve5qAahn8d7AWf2zGAabqJZK0OboKg)PvAOEY1UgTaDjAW9Kkn8d7AWf2zGvBEn482G6dosJcYvL3C)clKGhAFR3Vg92G6do6InF)apeHWU1tJeKzpbMYlUZpnuJTf6kz1Z7aFpNfJbGkyhLYdvY2VyOgBl0v4CGIgdFyOJw2bd9JXssqU0GzAz7hXY3ZzXyaOc2rP8qLS9l6shp65DWq)ySKeKlnTcWM14zKWqsxcnCihgY3Zzb5yReIsiiZgXqn2wOwbHVi3h)jyorSErIFD3qPHASTWqmkWJpYjx7EEg6hJLKGCPPva2SgpJegs6sOHd5Wq(EolihBLquI1lBed1yBHAfe(ICF8NG5eX6fj(1DdLgQX2cdXOap(iNCTFel5yReIeBLSYp2dYW3ZzHZsB5eDjppzEJr1lqVnm4akOY4ze4rShoiJdczGqULWzPTCIUKNNdcGkREXn)ZAfwzCqideYTeuJeKlnjEybk6sh98Cqauz1lQf35NYgDe7bzCqauz1laq1F6F88KHVNZcNL2Yj6sEEg6hJLKGCPXNlV9JEEhEJr1lqVnm4akOY4zeiw(EolCwAlNOlH9aFpNfO3ggCafO3C3UQLEEg6hJLKGCPXNlV9Jh98475SWzPTCIUewz475Symaub7OuEOs2(fDjSY8gJQxGEByWbuqLXZiqvEFfrACPbHfsJT0OT6LnAG3o2kHinScudKbG04szJLB132zmnU0GWsJmC0a)T4AFPCQ8M7xyHe8q7B9(1fXn1aH1fB((b(EolihBLquI1lBed1yBH8HWh56pL(TH88o4oTbhHUJrSd5oTbhL(THUcph98CN2GJq3B5rSMuYDsUBQ8M7xyHe8q7B9(1NglNAGW6InF)aFpNfKJTsikX6LnIHASTq(q4JC9Ns)2qyp4GqgiKBjCwAlNyOgBlKp4PDppheYaHClHdwaG3O0FsjK0o7Jed1yBH8bpTF0Z7G70gCe6ogXoK70gCu63g6k8C0ZZDAdocDVLhXAsj3j5UPYBUFHfsWdTV17xN7mwQbcRl289d89Cwqo2kHOeRx2igQX2c5dHpY1Fk9BdH9GdczGqULWzPTCIHASTq(GN298CqideYTeoybaEJs)jLqs7SpsmuJTfYh80(rpVdUtBWrO7ye7qUtBWrPFBORWZrpp3Pn4i09wEeRjLCNK7MkpMfeV1awA4av5n3VWcj4H2369R5AZSWjbZjI1lsL3xrKgCEBY7qA8qnKgOtdoqMnAG3o2kHinGJgCpPsJT0awm)A0w9YgnWBhBLqKgwbQrhrAGzbXBnKgOdPXM1ylnAREzJg4TJTsisL3C)clKGhAFR3Vg92K3HUyZ3jhBLqKyReRx245ro2kHibcYSjve(EppYXwjejSYFQi89EE89CwW1MzHtcMteRxKOlHLVNZcYXwjeLy9YgrxYZ7aFpNfolTLtmuJTf6kZ9lSeCh7pfe(ix)P0Vnew(EolCwAlNOlDuL3C)clKGhAFR3VM7y)PkV5(fwibp0(wVF90RK5(fwj2I(lkRHUNng7pNUkVkpN3guFWrAKHJgnqaudvVg9IriKgD0w40atHTatu5n3VWcjYgJ9Nt)o6Tb1hC0fB(UmtVOmCWrcEJzLJsWCYyS0FUfoKGWR(kjrGQ843qVg)jPbi81G7(NA8NKgnq0RXVnKgpuddeuJE9ltJ)K0OXWNgG9X(fwASino3xObNEL3H0yOgBlKgnD2VsSLa14HA0yV7uJgiSY7qAa2h7xyPYBUFHfsKng7pNER3Vg1R8o0fo)ogLEBWrp6UCxS57GWx0aHvEhsmuJTfYNHASTqyigXiMroFxL3C)clKiBm2Fo9wVFDdew5DivEvEFfrAW5Tb1hCKgpuJBejPrxsJ)K0W3mK1WVfinAW3Zzn2Sg7RbxyNbQbHpPDin4PmCinYBTOZTWPXFsAue(EnCg61aoA8qna7nsAWtz4qAGFybaEJu5n3VWcjq)D0BdQp4Ol289Pxugo4iXVnex4ujWHSg(TaPb7bYXwjej2kzLFSYC4aFpNf)2qCHtLahYA43cKgXqn2wiFm3VWsWDS)uq4JC9Ns)2qT2UqoShihBLqKyRep8p98ihBLqKyRecYSXZJCSvcrcwVSjve((JEE89Cw8BdXfovcCiRHFlqAed1yBH8XC)clb6TjVdji8rU(tPFBOwBxih2dKJTsisSvI1lB88ihBLqKabz2KkcFVNh5yReIew5pve((Jh98KHVNZIFBiUWPsGdzn8BbsJOlD0Z7aFpNfolTLt0L88ayZA8ms4Gfa4nkbsi)L7iwheYaHClHdwaG3O0FsjK0o7JedzG(X6GaOYQxulUZpLn6i2dY4GaOYQxCZ)Sw555GqgiKBjOgjixAs8WcumuJTfYhF)i2d89Cw4S0worxYZtgheYaHClHZsB5edzG(pQY7RisJwaAs)cG0GdxBA0G7jvA8N0qASinkOgM7xaKgiU20CHggsdM9KggsdjicT8msdyPbIRnnAWD)tnWOgWrJmXLgnqV5UH0aoAalnmnAzRAG4AtJgiOg)P9A8NKgfXvdexBA0WMzbqinWSPJEnS8tJg)P9AG4AtJge(K2HqQ8M7xyHeOV17xBGM0VaOeIRnnx487yu6Tbh9O7YDXMVldi8fgOj9lakH4Attc0AmCK4x3TTWHvgZ9lSegOj9lakH4Attc0AmCKyRuMT4oFShKbe(cd0K(faLqCTPjDsgt8R72w488aHVWanPFbqjexBAsNKXed1yBH8bph98aHVWanPFbqjexBAsGwJHJeO3C3UQLybHVWanPFbqjexBAsGwJHJed1yBHUQLybHVWanPFbqjexBAsGwJHJe)6UTfovEFfrinWpSaaVrASznWFlU2xkNglsJUKgWrd)WUg2qAasi)LBlCAG)wCTVuon4U)Pg4hwaG3inScud)WUg2qAWtmixnK121OfOlrL3C)clKa9TE)AhSaaVrP)KsiPD2hDXMVld40xqrbtoqe2dhayZA8ms4Gfa4nkbsi)LdRmoiKbc5wcNL2YjgYa9JvMPxugo4iH0SnWbCnwYgNvRlj1ziB88475SWzPTCIU0rSg6hJLKGCP5Q7YA7ypW3Zzb5yReIsSEzJyOgBlKpY1UNhFpNfKJTsikHGmBed1yBH8rU2p65XdriS5f35NgQX2cDLCTJvgheYaHClHZsB5edzG(pQYJFybU)clnYWrdJX0ae(in(t71OXUrinq9H04pj)AydvT51yO8qOtcudUNuPXLQbGkyhPHVDOs2(140qAWiesJ)0knWJgiYH0yOgBRTWPbC04pjnU5FwR0GVNZASinmEy)14HAKngtdyoRbC0Wk)AG3o2kHinwKggpS)A8qni8jTdPYBUFHfsG(wVFnaBwJNrxuwdDhe(PHWR(oudvp6cagRt3pW3ZzXyaOc2rP8qLS9lgQX2c5dE88KHVNZIXaqfSJs5Hkz7x0LoIvg(EolgdavWokLhQKT)eARCNLo9JEAwt0LWEGVNZIBBboeyIAKGCPPHQprfn4wztIHASTqxHZbkAm8De7b(EolihBLqucbz2igQX2c5dohOOXWNNhFpNfKJTsikX6LnIHASTq(GZbkAm855Dqg(EolihBLquI1lBeDjppz475SGCSvcrjeKzJOlDeRmVXO6fiid9RJeuz8mc8Okp(Hf4(lS04pTxd3j5UH0yZA4h21Wgsdy)rliPb5yReI04HAalMFnaHVg)jnKgWrJfxbhsJ)CrAWD)tn4azOFDKkV5(fwib6B9(1aSznEgDrzn0Dq4NG9hTGuICSvcrxaWyD6(bz475SGCSvcrjeKzJOlHvg(EolihBLquI1lBeDPJEEVXO6fiid9RJeuz8mcuL3C)clKa9TE)6giSY7qx487yu6Tbh9O7YDXMVpuEi0PXZiSh475SGCSvcrjeKzJyOgBlKpd1yBH88475SGCSvcrjwVSrmuJTfYNHASTqEEaSznEgjaHFc2F0csjYXwjeDe7q5HqNgpJW(2GJEXVnu6HjWL8romI1KsUtYDdlaBwJNrcq4NgcV67qnu9ivEZ9lSqc0369Rr9kVdDHZVJrP3gC0JUl3fB((q5HqNgpJWEGVNZcYXwjeLqqMnIHASTq(muJTfYZJVNZcYXwjeLy9YgXqn2wiFgQX2c55bWM14zKae(jy)rliLihBLq0rSdLhcDA8mc7Bdo6f)2qPhMaxYh5Wiwtk5oj3nSaSznEgjaHFAi8QVd1q1Ju5n3VWcjqFR3Vg9eJztkZSHUW53XO0Bdo6r3L7InFFO8qOtJNrypW3Zzb5yReIsiiZgXqn2wiFgQX2c55X3Zzb5yReIsSEzJyOgBlKpd1yBH88ayZA8msac)eS)OfKsKJTsi6i2HYdHonEgH9Tbh9IFBO0dtGl5JCyqSMuYDsUBybyZA8msac)0q4vFhQHQhPY7RisdFleZ1awA4a1G7(NW(RHZKK2cNkV5(fwib6B9(1z44OemNk77dDXMVBsj3j5UPY7RisJlfBboeOgCK2zFKgC3)udR8Rbdw40Gkyh3Pgmd9BHtd82XwjePHvGA8JFnEOgSTin2xJUKgC3)uJlPZq2OHvGAG)wCTVuovEZ9lSqc0369RPgjixAs8Wc8InF)Wb(EolihBLqucbz2igQX2c5JCT75X3Zzb5yReIsSEzJyOgBlKpY1(rSoiKbc5wcNL2YjgQX2c5tlBh7b(EolKMTboGRXs24SADjPodzJaGX60vyuwB3ZtMPxugo4iH0SnWbCnwYgNvRlj1ziBeeE1xjjc84rpp(EolKMTboGRXs24SADjPodzJaGX6Kp3XigODppheYaHClHZsB5edzG(XAOFmwscYLgFU82v59vePb(BX1(s50G7(NAGFybaEJU(sXwGdbQbhPD2hPHvGAacR28Aabqd3zFsJlPZq2ObC0G7jvAGPmieK1rVgCHDgOge(K2H0GNYWH0a)T4AFPCAq4tAhcPYBUFHfsG(wVFnaBwJNrxuwdD3bMCWcC)fwj0FbaJ1P7Yao9fuuWKdeHfGnRXZiHdm5Gf4(lSWE4GdczGqULGAK8pKXsWbSSYrIHASTqxjhged06b5KddNErz4GJeOTYDw60p6PzTJyj8QVsseOGAK8pKXsWbSSYrh98m0pgljb5sJp3V82XEqM3yu9ICF8NG5eX6fjOY4zeONhFpNfolTLta2h7xy5JdczGqULi3h)jyorSErIHASTqT67hXccFbQx5DiXqn2wiFKdJybHVObcR8oKyOgBlKp(o2dGWxGEIXSjLz2qIHASTq(47EEY8gJQxGEIXSjLz2qcQmEgbEelaBwJNrI)CwglHi6gnjU2(ypW3ZzXTTahcmrnsqU00q1NOIgCRSjrxYZtgheavw9IB(N1QJyFBWrV43gk9We4s(W3ZzHZsB5eG9X(fwyy7cmGNhpeHWMxCNFAOgBl0v89Cw4S0wobyFSFHLNNdcGkRErT4o)u2ipp(Eol4zqiiRJErxclFpNf8mieK1rVyOgBl0v89Cw4S0wobyFSFHvRhUCmC6fLHdosinBdCaxJLSXz16ssDgYgbHx9vsIapEeRm89Cw4S0worxc7bzCqauz1lQf35NYg555GqgiKBjCWca8gL(tkHK2zFKOl55XdriS5f35NgQX2cDLdczGqULWblaWBu6pPesAN9rIHASTqTIb98YlUZpnuJTfcZGzKZ3B)k(EolCwAlNaSp2VW6OkV5(fwib6B9(1aSznEgDrzn0DhyYblW9xyLq)famwNUld40xqrbtoqewa2SgpJeoWKdwG7VWc7HdoiKbc5wcQrY)qglbhWYkhjgQX2cDLCyqmqRhKtomC6fLHdosG2k3zPt)ONM1oILWR(kjrGcQrY)qglbhWYkhD0ZZq)ySKeKln(C)YBh7bzEJr1lY9XFcMteRxKGkJNrGEE89Cw4S0wobyFSFHLpoiKbc5wICF8NG5eX6fjgQX2c1QVFeli8fOEL3Hed1yBH8X3XccFrdew5DiXqn2wiFUCShaHVa9eJztkZSHed1yBH8rU298K5ngvVa9eJztkZSHeuz8mc8iwa2SgpJe)5Smwcr0nAsCT9XEGVNZIBBboeyIAKGCPPHQprfn4wztIUKNNmoiaQS6f38pRvhX(2GJEXVnu6HjWL8HVNZcNL2Yja7J9lSWW2fyappEicHnV4o)0qn2wOR475SWzPTCcW(y)clppheavw9IAXD(PSrEE89CwWZGqqwh9IUew(Eol4zqiiRJEXqn2wOR475SWzPTCcW(y)cRwpC5y40lkdhCKqA2g4aUglzJZQ1LK6mKnccV6RKebE8iwz475SWzPTCIUe2dY4GaOYQxulUZpLnYZZbHmqi3s4Gfa4nk9NucjTZ(irxYZJhIqyZlUZpnuJTf6kheYaHClHdwaG3O0FsjK0o7Jed1yBHAfd65XdriS5f35NgQX2cHzWmY57TFfFpNfolTLta2h7xyDuL3xrKg)jPbMDQ(t)JgC3)udtd83IR9LYPXFAVglQAZRrEGnACjDgYgvEZ9lSqc0369RhdavWokLhQKT)l28D(EolCwAlNyOgBlKpYHhpp(EolCwAlNaSp2VW6QwIrSaSznEgjCGjhSa3FHvc9Q8M7xyHeOV17x7igH(1yjJT4QgQ(l28Da2SgpJeoWKdwG7VWkHESh475SWzPTCcW(y)clFU3sm65jJdcGkREbaQ(t)Zrpp(EolgdavWokLhQKTFrxclFpNfJbGkyhLYdvY2VyOgBl0vxERoyb23xinKBruYylUQHQx8BdLaySo16bz475SGNbHGSo6fDjSY8gJQxGEByWbuqLXZiWJQ8M7xyHeOV17xVLZMY(fwxS57aSznEgjCGjhSa3FHvc9Q8y2TznEgPrhrGAalnm(LT)sin(t71GRvVgpudEsdKbGa1idhnWFlU2xkNgiOg)P9A8NKFnSHQxdUg6jqnWSPJEn4PmCin(tQrL3C)clKa9TE)Aa2SgpJUOSg6oYaqPmCsolTL7cagRt3LXbHmqi3s4S0woXqgOFppzayZA8ms4Gfa4nkbsi)LdRdcGkRErT4o)u2ippWPVGIcMCGivEFfrin8Tq8wJnRXwAyLg4TJTsisdRa14NLqA8qnyBrASVgDjn4U)PgxsNHS5cnWFlU2xkNgwbQrlanPFbqAWHRnnQ8M7xyHeOV17xN7J)emNiwVOl28DYXwjej2kzLFSMuYDsUBy575SqA2g4aUglzJZQ1LK6mKncagRtxHrzTDShaHVWanPFbqjexBAsGwJHJe)6UTfoppzCqauz1lkYnqgCapIfGnRXZibYaqPmCsolTLd7b(EolgdavWokLhQKTFXqn2wORU8l7aEWWPxugo4ibARCNLo9JEAwRvzi8QVsseOyl0pD3dhucCbSfL4jg7iw(EolgdavWokLhQKTFrxYZtg(EolgdavWokLhQKTFrx6OkVVIinU0l6p1GZBt2ymnKgOdPXM1GZBt2ymnwu1MxJUKkV5(fwib6B9(1O3MSXyxS5789Cwal6prjjACK0VWs0LWY3Zzb6TjBmMyO8qOtJNrQ8M7xyHeOV17x7SYrSeFpNVOSg6o6THbhWl28D(EolqVnm4akgQX2cDfEWEGVNZcYXwjeLqqMnIHASTq(Ghpp(EolihBLquI1lBed1yBH8bphXAOFmwscYLgFU82v59n9gjKgTaDjAWtz4qAGFybaEJ0OJ2cNg)jPb(Hfa4nsdhSa3FHLgpud3j5UPXM1a)Wca8gPXI0WCF3ym)Ay8W(RXd1GN0WzOxL3C)clKa9TE)A0BdQp4Ol28Dheavw9IAXD(PSrybyZA8ms4Gfa4nkbsi)LdRdczGqULWblaWBu6pPesAN9rIHASTqxHhSYao9fuuWKdeHLCSvcrITsw5hRH(XyjjixA8rwBxL3xrKgCEBYgJPb39p1GZtmMnA4BMn)AyfOgfudoVnm4aEHgCpPsJcQbN3MSXyASin6sxOHFyxdBin2sJ2Qx2ObE7yReI0idhn89wrKdPbC04HAinqNgxsNHSrdUNuPHXdbqAC5TRrlqxIgWrdduY(faPbIRnnACAin89wrKdPXqn2wBHtd4OXI0ylnYSf35l0aZHpPXFAVg9cKgn(tsdK1qA4Gf4(lSqASFBqAakH0OO(pgtJhQbN3MSXyAa2NTWPXLQbGkyhPHVDOs2(VqdUNuPHFyVnGAG(LX0Gkqn6sAWD)tnU82B1qsAKHJg)jPbZqVg4yqEJHeQ8M7xyHeOV17xJEBYgJDXMV)gJQxGEIXSjboB(fuz8mceRmVXO6fO3ggCafuz8mcelFpNfO3MSXyIHYdHonEgH9aFpNfKJTsikX6LnIHASTq(47yjhBLqKyReRx2GLVNZcPzBGd4ASKnoRwxsQZq2iaySoDfgXt7EE89CwinBdCaxJLSXz16ssDgYgbaJ1jFUJr80owd9JXssqU04ZL3UNhi8fgOj9lakH4Attc0AmCKyOgBlKp(UNN5(fwcd0K(faLqCTPjbAngosSvkZwCN)rSoiKbc5wcNL2YjgQX2c5JCTRY7RisdoVnO(GJ04sVO)udPb6qAyfOgG9gjnAb6s0G7jvAG)wCTVuonGJg)jPbMDQ(t)Jg89CwJfPHXd7VgpuJSXyAaZznGJg(H92aQHZK0OfOlrL3C)clKa9TE)A0BdQp4Ol28D(EolGf9NOKJr2KaSOfwIUKNhFpNf32cCiWe1ib5stdvFIkAWTYMeDjpp(EolCwAlNOlH9aFpNfJbGkyhLYdvY2VyOgBl0v4CGIgdFyOJw2bd9JXssqU0GzAz7hBTLy4BmQErrCtnqyjOY4zeiwzMErz4GJeOTYDw60p6PznS89CwmgaQGDukpujB)IUKNhFpNfolTLtmuJTf6kCoqrJHpm0rl7GH(XyjjixAWmTS9JEE89CwmgaQGDukpujB)j0w5olD6h90SMOl55DGVNZIXaqfSJs5Hkz7xmuJTf6kZ9lSeO3M8oKGWh56pL(THWIKiglDAONUQDHS65X3ZzXyaOc2rP8qLS9lgQX2cDL5(fwcUJ9NccFKR)u63gYZdGnRXZiXIxGjhSa3FHfwheYaHClXwi30FJNrj8QB13BsGeG1rIHmq)yj8QVsseOylKB6VXZOeE1T67njqcW6OJy575Symaub7OuEOs2(fDjppz475Symaub7OuEOs2(fDjSY4GqgiKBjgdavWokLhQKTFXqgOFppzCqauz1laq1F6Fo65zOFmwscYLgFU82Xso2kHiXwjR8RYJjJFnEOgn2nsJ)K0GNqVgWSgCEByWbudE)AGEZDBlCASVgDjnWR(6UX8RXwAyLFnWBhBLqKg89xJlPZq2OXIQxdJh2FnEOg8Kgsd05iqvEZ9lSqc0369RrVnO(GJUyZ3FJr1lqVnm4akOY4zeiwzMErz4GJe)2qCHtLahYA43cKgSh475Sa92WGdOOl55zOFmwscYLgFU82pILVNZc0BddoGc0BUBx1sSh475SGCSvcrjeKzJOl55X3Zzb5yReIsSEzJOlDelFpNfsZ2ahW1yjBCwTUKuNHSraWyD6kmIbAh7bheYaHClHZsB5ed1yBH8rU298KbGnRXZiHdwaG3OeiH8xoSoiaQS6f1I78tzJoQYJ3OFBSNqACc5Qrt3DQrlqxIg2qAGZ2Ia1qIgnqKdwGQ8M7xyHeOV17xdWM14z0fL1q3nK0LqdhYDbaJ1P7KJTsisSvI1lBWqFhZyUFHLa92K3Hee(ix)P0VnuRYqo2kHiXwjwVSbdpGbB9ngvVab7SemN(tkLHdHEbvgpJaXWwEeZyUFHLG7y)PGWh56pL(THATDHSIhmdsIyS0PHEQ12f4bdFJr1lk77dHs8gZkhjOY4zeOkVVP3iPbN3guFWrASLgMgyGwrKtdoqMnAG3o2kHOl0aewT51GrVg7RH0aDACjDgYgno8N2RXI040kqgbQbVFnO9pPrJ)K0GZBt2ymnyBrAahn(tsJwGUeFU821GTfPrgoAW5Tb1hC0Xl0aewT51acGgUZ(KgwPXLEr)Pgsd0PHvGAWOxJ)K0W4HainyBrACAfiJ0GZBddoGQ8M7xyHeOV17xJEBq9bhDXMVlZ0lkdhCK43gIlCQe4qwd)wG0G9aFpNfsZ2ahW1yjBCwTUKuNHSraWyD6kmIbA3ZJVNZcPzBGd4ASKnoRwxsQZq2iaySoDfgXt7yFJr1lqpXy2KaNn)cQmEgbEe7bYXwjej2kHGmBWAOFmwscYLMwbyZA8msyiPlHgoKdd575SGCSvcrjeKzJyOgBluRGWxK7J)emNiwViXVUBO0qn2wyigf4XhFVDppYXwjej2kX6Lnyn0pgljb5stRaSznEgjmK0LqdhYHH89Cwqo2kHOeRx2igQX2c1ki8f5(4pbZjI1ls8R7gknuJTfgIrbE85YB)iwz475Saw0FIss04iPFHLOlHvM3yu9c0BddoGcQmEgbI9GdczGqULWzPTCIHASTq(Gb88qWoJFlqXFolJLqeDJgbvgpJaXY3ZzXFolJLqeDJgb6n3TRAzlVSdtVOmCWrc0w5olD6h90SggINJyZlUZpnuJTfYh5AVDS5f35NgQX2cDfgBVDppWPVGIcMCGOJyp4GqgiKBjUTf4qGjK0o7Jed1yBH8bd45jJdcGkREXn)ZA1rvEFfrACPbHfsJT0OT6LnAG3o2kHinScudKbG04szJLB132zmnU0GWsJmC0a)T4AFPCAyfOgxk2cCiqnW7gjixAAO6v5n3VWcjqFR3VUiUPgiSUyZ3pW3Zzb5yReIsSEzJyOgBlKpe(ix)P0VnKN3b3Pn4i0DmIDi3Pn4O0Vn0v45ONN70gCe6ElpI1KsUtYDdlaBwJNrcKbGsz4KCwAlNkV5(fwib6B9(1NglNAGW6InF)aFpNfKJTsikX6LnIHASTq(q4JC9Ns)2qyLXbbqLvV4M)zTYZ7aFpNf32cCiWe1ib5stdvFIkAWTYMeDjSoiaQS6f38pRvh98o4oTbhHUJrSd5oTbhL(THUcph98CN2GJq3BPNhFpNfolTLt0LoI1KsUtYDdlaBwJNrcKbGsz4KCwAlh2d89CwmgaQGDukpujB)IHASTqxDapxggXWPxugo4ibARCNLo9JEAw7iw(EolgdavWokLhQKTFrxYZtg(EolgdavWokLhQKTFrx6OkV5(fwib6B9(15oJLAGW6InF)aFpNfKJTsikX6LnIHASTq(q4JC9Ns)2qyLXbbqLvV4M)zTYZ7aFpNf32cCiWe1ib5stdvFIkAWTYMeDjSoiaQS6f38pRvh98o4oTbhHUJrSd5oTbhL(THUcph98CN2GJq3BPNhFpNfolTLt0LoI1KsUtYDdlaBwJNrcKbGsz4KCwAlh2d89CwmgaQGDukpujB)IHASTqxHhS89CwmgaQGDukpujB)IUewzMErz4GJeOTYDw60p6Pznppz475Symaub7OuEOs2(fDPJQ8(kI0aZcI3AalnCGQ8M7xyHeOV17xZ1MzHtcMteRxKkVVIin482K3H04HAinqNgCGmB0aVDSvcrxOb(BX1(s5040qAWiesJFBin(tR0W0aZAS)udcFKR)Kgmk)AahnGfZVgTvVSrd82XwjePXI0OlPYBUFHfsG(wVFn6TjVdDXMVto2kHiXwjwVSbRm89CwmgaQGDukpujB)IUKNh5yReIeiiZMur4798ihBLqKWk)PIW375DGVNZcU2mlCsWCIy9IeDjppKeXyPtd90vTlKv8Gvgheavw9cau9N(hppKeXyPtd90vTlKvSoiaQS6faO6p9phXY3Zzb5yReIsSEzJOl55DGVNZcNL2YjgQX2cDL5(fwcUJ9NccFKR)u63gclFpNfolTLt0LoQY7RisdmRX(tnG)jnCxePb3Z1DQXI0yln4az2ObE7yReIUqd83IR9LYPbC04HAinqNgTvVSrd82XwjePYBUFHfsG(wVFn3X(tvEFRXy)50v5n3VWcjqFR3VE6vYC)cReBr)fL1q3ZgJ9Nthih2IEeqmbihOev0aetaI5YbetaYHkJNrGaXuGCm3VWcihUJ9Na5asi3Ss)clGCUKHCg61aJAGzn2FQHvGAyAW5Tb1hCKgWsdoyIgC3)udmFXD(A4BnsdRa1atHTat0aoAW5TjVdPb8pPH7IiGCCZ(0Sgqoh0GCSvcrcwVSjve(En880GCSvcrITsiiZgn880GCSvcrITs8W)udppnihBLqKWk)PIW3RXrnWQH0qaeYj4o2FQbwnKrdPHaiWOG7y)jWhiMJrGycqouz8mceiMcKJ5(fwa5GEBY7qa54M9PznGCKrJPxugo4ibVXSYrjyozmw6p3chsqLXZiqn880qgnCqauz1lQf35NYgPHNNgYObsIyS0Bdo6rc0Bt2ymnURHCA45PHmA8gJQxu23hcL4nMvosqLXZiqn8804GgKJTsisGGmBsfHVxdppnihBLqKyReRx2OHNNgKJTsisSvIh(NA45Pb5yReIew5pve(EnocKdBlk5abYbpaFGyElbIja5qLXZiqGykqoM7xybKd6Tb1hCeqoUzFAwdiNPxugo4ibVXSYrjyozmw6p3chsqLXZiqnWQHdcGkRErT4o)u2inWQbsIyS0Bdo6rc0Bt2ymnURHCa5W2IsoqGCWdWh4dKdiLTo7bIjaXC5aIja5yUFHfqoiiZMepzna5qLXZiqGykWhiMJrGycqouz8mceiMcKJB2NM1aY53gsJR04GgyudmudZ9lSeCh7pfod9PFBinAvdZ9lSeO3M8oKWzOp9BdPXrGCm3VWcihNXyjZ9lSsSf9a5Ww0NkRHaYbkrfnaFGyElbIja5qLXZiqGykqoqjGCq0dKJ5(fwa5aWM14zeqoamwNaYbjrmw6Tbh9ib6TjBmMg(OHCAGvJdAiJgVXO6fO3ggCafuz8mcudppnEJr1lqpXy2KaNn)cQmEgbQXrn880ajrmw6Tbh9ib6TjBmMg(ObgbYbKqUzL(fwa5WHEKgTaI3AalnAzRAWD)ty)1aC28RHvGAWD)tn482WGdOgwbQbgBvd4Fsd3fra5aWMuzneqolkzqc4deZLvGycqouz8mceiMcKducihe9a5yUFHfqoaSznEgbKdaJ1jGCqseJLEBWrpsGEBY7qA4JgYbKdiHCZk9lSaYHd9inCmYaqAW9Kkn482K3H0WzLgN7RbgBvJ3gC0J0G756o1yrAmeJay1RrgoA8NKg4TJTsisJhQbpPH0qzAgcudRa1G756o1iVmgnA8qnCg6bYbGnPYAiGCwuYXidab8bI54biMaKdvgpJabIPa5aLaYbrpqoM7xybKdaBwJNra5aWyDcihPHaiAGWkVdPHNNgsdbqG6vEhsdppnKgcGa92G6dosdppnKgcGa92KngtdppnKgcGi3h)jyorSErA45PbFpNfolTLtmuJTfsJ7AW3ZzHZsB5eG9X(fwA45PH0qaeJbGkyhLYdvY2VgEEAaWM14zKyrjdsa5asi3Ss)clGCWSBZA8msJ)0EnCNK7gsJnRHFyxdBin2sdtdCoqnEOgga4cQXFsAG2VB)cln4EsdPHPXpBDJEnO3PXI0OJiqn2sdE65suPHZqpciha2KkRHaYzReohiWhiMJbbIja5qLXZiqGykqoM7xybKdpniAUTfoGCajKBwPFHfqo(kI0atPbrZTTWPb39p1a)T4AFPCAahnS8tJg4hwaG3in2sd83IR9LYbKJB2NM1aY5Ggh0qgnCqauz1lQf35NYgPHNNgYOHdczGqULWblaWBu6pPesAN9rIUKgh1aRg89Cw4S0woXqn2win8rd5WJgy1GVNZIXaqfSJs5Hkz7xmuJTfsJR0qw1aRgYOHdcGkREbaQ(t)JgEEA4GaOYQxaGQ)0)Obwn475SWzPTCIUKgy1GVNZIXaqfSJs5Hkz7x0L0aRgh0GVNZIXaqfSJs5Hkz7xmuJTfsJR0qo504Y0apAGHAm9IYWbhjqBL7S0PF0tZAcQmEgbQHNNg89Cw4S0woXqn2winUsd5KtdppnKtJR1ajrmw60qpPXvAiNap4rJJACudSAaWM14zKyReohiWhiMJbaIja5qLXZiqGykqoUzFAwdih(EolCwAlNyOgBlKg(OHC4rdSACqdz0y6fLHdosG2k3zPt)ONM1euz8mcudppn475Symaub7OuEOs2(fd1yBH04knKddOXLPbg1ad1GVNZcEgecY6Ox0L0aRg89CwmgaQGDukpujB)IUKgh1WZtdEicPbwnYlUZpnuJTfsJR0aJ4bihqc5Mv6xybKZLaFn4U)PgMg4Vfx7lLtJ)0Enwu1MxdtJlPZq2OH0aDAahn4EsLg)jPrEXD(ASinmEy)14HAqfiqoM7xybKJe8xyb8bI5(oqmbihQmEgbcetbYbkbKdIEGCm3VWciha2SgpJaYbGX6eqooAzACqJdAKxCNFAOgBlKgxMgYHhnUmnCqideYTeolTLtmuJTfsJJACTgY57TRXrnURHJwMgh04Gg5f35NgQX2cPXLPHC4rJltdheYaHClHdwaG3O0FsjK0o7JeG9X(fwACzA4GqgiKBjCWca8gL(tkHK2zFKyOgBlKgh14AnKZ3BxJJAGvdz0ySfmraO6fgiisq4BrpsdppnCqideYTeolTLtmuJTfsdF0yRNgjiZEcmLxCNFAOgBlKgEEAm9IYWbhjCeJq)ASesAN9rcQmEgbQbwnCqideYTeolTLtmuJTfsdF0OLTRHNNgoiKbc5wchSaaVrP)KsiPD2hjgQX2cPHpAS1tJeKzpbMYlUZpnuJTfsJltd5AxdppnKrdheavw9IAXD(PSra5asi3Ss)clGCWVXCDM9esdUN0FsJgD0w40a)Wca8gPrb5Qb3LX0Wymixn8d7A8qnq)YyA4m0RXFsAGSgsdRb2Rxdywd8dlaWBuR4Vfx7lLtdNHEeqoaSjvwdbKJdwaG3OeiH8xoGpqm)YbIja5qLXZiqGykqoqjGCq0dKJ5(fwa5aWM14zeqoamwNaY5Gg5f35NgQX2cPHpAihE0WZtJXwWebGQxyGGiXwA4Jg4PDnoQbwnoOXbnoObHx9vsIafuJK)HmwcoGLvosdSACqdheYaHClb1i5FiJLGdyzLJed1yBH04knKdd2UgEEA4GaOYQxaGQ)0)ObwnCqideYTeuJK)HmwcoGLvosmuJTfsJR0qomigqJw14GgYjNgyOgtVOmCWrc0w5olD6h90SMGkJNrGACuJJAGvdz0WbHmqi3sqns(hYyj4aww5iXqgOFnoQHNNgeE1xjjcuGGDgJ(FlCPPZ7xdSACqdz0WbbqLvVOwCNFkBKgEEA4GqgiKBjqWoJr)VfU0059NAPSIhFVD5ed1yBH04knKtozvJJA45PXbnCqideYTe80GO52w4edzG(1WZtdz0ymhj(bYyACudSACqJdAq4vFLKiqXwi30FJNrj8QB13BsGeG1rAGvJdA4GqgiKBj2c5M(B8mkHxDR(EtcKaSosmKb6xdppnm3VWsSfYn934zucV6w99MeibyDKaCrgpJa14Ogh1WZtJdAq4vFLKiqb60aHCjWeC4tWC6HtdvVgy1WbHmqi3s8WPHQNatBHwCNFQL4bpTeJYjgQX2cPXrn8804Ggh0aGnRXZibSsDeL(zRB0RXDnKtdppnayZA8msaRuhrPF26g9ACxJwQXrnWQXbn(zRB0lE5edzG(toiKbc5wA45PXpBDJEXlNWbHmqi3smuJTfsdF0yRNgjiZEcmLxCNFAOgBlKgxMgY1Ugh1WZtda2SgpJeWk1ru6NTUrVg31aJAGvJdA8Zw3Ox8yumKb6p5GqgiKBPHNNg)S1n6fpgfoiKbc5wIHASTqA4JgB90ibz2tGP8I78td1yBH04Y0qU214OgEEAaWM14zKawPoIs)S1n614UgTRXrnoQXrn880WbbqLvV4M)zTsJJA45PbpeH0aRg5f35NgQX2cPXvAW3ZzHZsB5eG9X(fwa5asi3Ss)clGC8vebQXd1aKyMFn(tsJoYWrAaZAG)wCTVuon4EsLgD0w40ae25zKgWsJoI0WkqnKgcavVgDKHJ0G7jvAyLggiOgeaQEnwKggpS)A8qnaxciha2KkRHaYXbMCWcC)fwaFGyUCTdetaYHkJNrGaXuGCGsa5GOhihZ9lSaYbGnRXZiGCaySobKJmAGGDg)wGI)CwglHi6gncQmEgbQHNNg5f35NgQX2cPHpAGX2Bxdppn4HiKgy1iV4o)0qn2winUsdmIhnAvJdAiRTRXLPbFpNf)5Smwcr0nAeO3C30ad1aJACudppn475S4pNLXsiIUrJa9M7Mg(Orl9DnUmnoOX0lkdhCKaTvUZsN(rpnRjOY4zeOgyOg4rJJa5asi3Ss)clGCWSBZA8msJoIa14HAasmZVgw5xJF26g9inScudhisdUNuPbxB)TWPrgoAyLg4Dx6eoRPH0aDa5aWMuzneqo)5Smwcr0nAsCT9b(aXC5KdiMaKdvgpJabIPa5asi3Ss)clGC8vePbE3i5FiJPXL(aww5inWy7iYH0GNYWH0W0a)T4AFPCA0rKaiNYAiGCOgj)dzSeCalRCeqoUzFAwdihheYaHClHZsB5ed1yBH04knWy7AGvdheYaHClHdwaG3O0FsjK0o7Jed1yBH04knWy7AGvJdAaWM14zK4pNLXsiIUrtIRTVgEEAW3ZzXFolJLqeDJgb6n3nn8rJw2UgTQXbnMErz4GJeOTYDw60p6PznbvgpJa1ad1adQXrnoQbwnayZA8msSvcNdudppn4HiKgy1iV4o)0qn2winUsJwIbaYXC)clGCOgj)dzSeCalRCeWhiMlhgbIja5qLXZiqGykqoGeYnR0VWcihFfrAWb2zm63cNgxQDE)AGbrKdPbpLHdPHPb(BX1(s50OJibqoL1qa5GGDgJ(FlCPPZ7hih3SpnRbKZbnCqideYTeolTLtmuJTfsJR0adQbwnKrdheavw9cau9N(hnWQHmA4GaOYQxulUZpLnsdppnCqauz1lQf35NYgPbwnCqideYTeoybaEJs)jLqs7SpsmuJTfsJR0adQbwnoObaBwJNrchSaaVrjqc5VCA45PHdczGqULWzPTCIHASTqACLgyqnoQHNNgoiaQS6faO6p9pAGvJdAiJgtVOmCWrc0w5olD6h90SMGkJNrGAGvdheYaHClHZsB5ed1yBH04knWGA45PbFpNfJbGkyhLYdvY2VyOgBlKgxPHCYQgTQXbnWJgyOgeE1xjjcuSf6NU7HdkbUa2Is8eJPXrnWQbFpNfJbGkyhLYdvY2VOlPXrn880GhIqAGvJ8I78td1yBH04knWiE0WZtdcV6RKebkOgj)dzSeCalRCKgy1WbHmqi3sqns(hYyj4aww5iXqn2win8rdm2Ugh1aRgaSznEgj2kHZbQbwnKrdcV6RKebk2c5M(B8mkHxDR(EtcKaSosdppnCqideYTeBHCt)nEgLWRUvFVjbsawhjgQX2cPHpAGX21WZtdEicPbwnYlUZpnuJTfsJR0aJTdKJ5(fwa5GGDgJ(FlCPPZ7h4deZLRLaXeGCOY4zeiqmfihOeqoi6bYXC)clGCayZA8mcihagRta5W3ZzHZsB5ed1yBH0WhnKdpAGvJdAiJgtVOmCWrc0w5olD6h90SMGkJNrGA45PbFpNfJbGkyhLYdvY2VyOgBlKgxDxd5WOaJA0Qgh0OLAGHAW3ZzbpdcbzD0l6sACuJw14Gg(UgxMg4rdmud(Eol4zqiiRJErxsJJAGHAq4vFLKiqXwOF6UhoOe4cylkXtmMgy1GVNZIXaqfSJs5Hkz7x0L04OgEEAWdrinWQrEXD(PHASTqACLgyepA45PbHx9vsIafuJK)HmwcoGLvosdSA4GqgiKBjOgj)dzSeCalRCKyOgBleqoGeYnR0VWciNwW4A(rA0rKg(cMT8nAWD)tnWFlU2xkhqoaSjvwdbKZIxGjhSa3FHfWhiMlNScetaYHkJNrGaXuGCm3VWciNTqUP)gpJs4v3QV3KajaRJaYXn7tZAa5aWM14zKyXlWKdwG7VWsdSAaWM14zKyReohiqoL1qa5SfYn934zucV6w99MeibyDeWhiMlhEaIja5qLXZiqGykqoGeYnR0VWcihFfrAmlUZxdEkdhsdhiciNYAiGCqNgiKlbMGdFcMtpCAO6bYXn7tZAa5CqdheYaHClHZsB5edzG(1aRgYOHdcGkRErT4o)u2inWQbaBwJNrI)CwglHi6gnjU2(AGvJdA4GqgiKBj4PbrZTTWjgYa9RHNNgYOXyos8dKX04OgEEA4GaOYQxulUZpLnsdSA4GqgiKBjCWca8gL(tkHK2zFKyid0Vgy14GgaSznEgjCWca8gLajK)YPHNNgoiKbc5wcNL2YjgYa9RXrnoQbwnaHVa1R8oK4x3TTWPbwnoObi8fONymBszMnK4x3TTWPHNNgYOXBmQEb6jgZMuMzdjOY4zeOgEEAGKigl92GJEKa92K3H0WhnAPgh1aRgGWx0aHvEhs8R72w40aRgh0aGnRXZiXIsgK0WZtJPxugo4ibVXSYrjyozmw6p3chsqLXZiqn880Wq)ySKeKlnA4ZDnU821WZtda2SgpJeoybaEJsGeYF50WZtd(Eol4zqiiRJErxsJJAGvdz0GWR(kjrGITqUP)gpJs4v3QV3KajaRJ0WZtdcV6RKebk2c5M(B8mkHxDR(EtcKaSosdSA4GqgiKBj2c5M(B8mkHxDR(EtcKaSosmuJTfsdF0OLTRbwnKrd(EolCwAlNOlPHNNg8qesdSAKxCNFAOgBlKgxPHS2oqoM7xybKd60aHCjWeC4tWC6HtdvpWhiMlhgeiMaKdvgpJabIPa5asi3Ss)clGCWKZfPXI0W0yS)KgniMXdh7jn4A(14HA0y3inmgtdyPrhrAGE714NTUrpsJhQbpPbBlcuJUKgC3)ud83IR9LYPHvGAGFybaEJ0Wkqn6isJ)K0aJfOgig81awA4a1yZAWd)tn(zRB0J0WgsdyPrhrAGE714NTUrpcih3SpnRbKZbnayZA8msaRuhrPF26g9AiZDnKtdSAiJg)S1n6fpgfdzG(toiKbc5wA45PXbnayZA8msaRuhrPF26g9ACxd50WZtda2SgpJeWk1ru6NTUrVg31OLACudSACqd(EolCwAlNOlPbwnoOHmA4GaOYQxaGQ)0)OHNNg89CwmgaQGDukpujB)IHASTqA0Qgh0apAGHAm9IYWbhjqBL7S0PF0tZAcQmEgbQXrnU6Ug)S1n6fVCc(EoNa7J9lS0aRg89CwmgaQGDukpujB)IUKgEEAW3ZzXyaOc2rP8qLS9NqBL7S0PF0tZAIUKgh1WZtdheYaHClHZsB5ed1yBH0OvnWOg(OXpBDJEXlNWbHmqi3sa2h7xyPbwnKrd(EolCwAlNOlPbwnoOHmA4GaOYQxulUZpLnsdppnKrda2SgpJeoybaEJsGeYF504Ogy1qgnCqauz1lU5FwR0WZtdheavw9IAXD(PSrAGvda2SgpJeoybaEJsGeYF50aRgoiKbc5wchSaaVrP)KsiPD2hj6sAGvdz0WbHmqi3s4S0worxsdSACqJdAW3Zzb5yReIsSEzJyOgBlKg(OHCTRHNNg89Cwqo2kHOecYSrmuJTfsdF0qU214Ogy1qgnMErz4GJe8gZkhLG5KXyP)ClCibvgpJa1WZtJdAW3ZzbVXSYrjyozmw6p3chkv23hsGEZDtJ7AGhn880GVNZcEJzLJsWCYyS0FUfouYgNvKa9M7Mg31W314Ogh1WZtd(EolUTf4qGjQrcYLMgQ(ev0GBLnj6sACudppn4HiKgy1iV4o)0qn2winUsdm2UgEEAaWM14zKawPoIs)S1n614UgTRXrnWQbaBwJNrITs4CGa5GyWhbKZpBDJE5aYXC)clGC(zRB0lhWhiMlhgaiMaKdvgpJabIPa5yUFHfqo)S1n6XiqoUzFAwdiNdAaWM14zKawPoIs)S1n61qM7AGrnWQHmA8Zw3Ox8YjgYa9NCqideYT0WZtda2SgpJeWk1ru6NTUrVg31aJAGvJdAW3ZzHZsB5eDjnWQXbnKrdheavw9cau9N(hn880GVNZIXaqfSJs5Hkz7xmuJTfsJw14Gg4rdmuJPxugo4ibARCNLo9JEAwtqLXZiqnoQXv314NTUrV4XOGVNZjW(y)clnWQbFpNfJbGkyhLYdvY2VOlPHNNg89CwmgaQGDukpujB)j0w5olD6h90SMOlPXrn880WbHmqi3s4S0woXqn2winAvdmQHpA8Zw3Ox8yu4GqgiKBja7J9lS0aRgYObFpNfolTLt0L0aRgh0qgnCqauz1lQf35NYgPHNNgYObaBwJNrchSaaVrjqc5VCACudSAiJgoiaQS6f38pRvAGvJdAiJg89Cw4S0worxsdppnKrdheavw9cau9N(hnoQHNNgoiaQS6f1I78tzJ0aRgaSznEgjCWca8gLajK)YPbwnCqideYTeoybaEJs)jLqs7Sps0L0aRgYOHdczGqULWzPTCIUKgy14Ggh0GVNZcYXwjeLy9YgXqn2win8rd5Axdppn475SGCSvcrjeKzJyOgBlKg(OHCTRXrnWQHmAm9IYWbhj4nMvokbZjJXs)5w4qcQmEgbQHNNgh0GVNZcEJzLJsWCYyS0FUfouQSVpKa9M7Mg31apA45PbFpNf8gZkhLG5KXyP)ClCOKnoRib6n3nnURHVRXrnoQXrn880GVNZIBBboeyIAKGCPPHQprfn4wztIUKgEEAWdrinWQrEXD(PHASTqACLgySDn880aGnRXZibSsDeL(zRB0RXDnAxJJAGvda2SgpJeBLW5abYbXGpciNF26g9ye4deZLZ3bIja5qLXZiqGykqoGeYnR0VWcihFfrinmgtd4FsJgWsJoI0yFQbPbS0WbcKJ5(fwa50ruAFQbb8bI5YD5aXeGCOY4zeiqmfihqc5Mv6xybKJVHCliPH5(fwAWw0RbVHiqnGLgO972VW6AgHBra5yUFHfqotVsM7xyLyl6bYb9Z6EGyUCa54M9PznGCayZA8msSOKbjGCyl6tL1qa5yqc4deZXy7aXeGCOY4zeiqmfih3SpnRbKZ0lkdhCKG3yw5OemNmgl9NBHdji8QVsseiqoOFw3deZLdihZ9lSaYz6vYC)cReBrpqoSf9PYAiGC4H2d8bI5yuoGycqouz8mceiMcKJ5(fwa5m9kzUFHvITOhih2I(uzneqoOh4d8bYHhApqmbiMlhqmbihQmEgbcetbYXC)clGCgdavWokLhQKTFGCajKBwPFHfqo(2Hkz7xdU7FQb(BX1(s5aYXn7tZAa5W3ZzHZsB5ed1yBH0WhnKdpaFGyogbIja5qLXZiqGykqoM7xybKJbAs)cGsiU20aKJZVJrP3gC0JaI5YbKJB2NM1aYHVNZcEJzLJsWCYyS0FUfouQSVpKa9M7MgxPHVRbwn475SG3yw5OemNmgl9NBHdLSXzfjqV5UPXvA47AGvJdAiJgGWxyGM0VaOeIRnnjqRXWrIFD32cNgy1qgnm3VWsyGM0VaOeIRnnjqRXWrITsz2I781aRgh0qgnaHVWanPFbqjexBAsNKXe)6UTfon880ae(cd0K(faLqCTPjDsgtmuJTfsdF0OLACudppnaHVWanPFbqjexBAsGwJHJeO3C304knAPgy1ae(cd0K(faLqCTPjbAngosmuJTfsJR0apAGvdq4lmqt6xaucX1MMeO1y4iXVUBBHtJJa5asi3Ss)clGC8vePrlanPFbqAWHRnnAW9KknSxdgHqA8NwPHSQbMcBbMOb6n3nKgwbQXd1yO8qOtnmnU6og1a9M7MggsdM9KggsdjicT8msd4OXVnKg7RbcQX(AyZSaiKgy20rVgw(PrdtJw2QgO3C30GWN0oec4deZBjqmbihQmEgbcetbYXC)clGCCWca8gL(tkHK2zFeqoGeYnR0VWcihFfrAGFybaEJ0G7(NAG)wCTVuon4EsLgsqeA5zKgwbQb8pPH7Iin4U)PgMgykSfyIg89CwdUNuPbiH8xUTWbKJB2NM1aYrgnaN(ckkyYbI0aRgh04GgaSznEgjCWca8gLajK)YPbwnKrdheYaHClHZsB5edzG(1WZtd(EolCwAlNOlPXrnWQXbn475SG3yw5OemNmgl9NBHdLk77djqV5UPXDn8Dn880GVNZcEJzLJsWCYyS0FUfouYgNvKa9M7Mg31W314OgEEAWdrinWQrEXD(PHASTqACLgY1Ugy1WbHmqi3s4S0woXqn2win8rdmGghb(aXCzfiMaKdvgpJabIPa5yUFHfqo5(4pbZjI1lcihqc5Mv6xybKJVfI3Ayin(tsJ8oOxdCoqn2sJ)K0W0atHTat0G7wGqUAahn4U)Pg)jPXLc)ZALg89Cwd4Ob39p1W0W3BfronAbOj9lasdoCTPrdRa1GRTVgz4Ob(BX1(s50yZASVgCH1RbpPrxsddNTLg8ugoKg)jPHduJfPrERfDsGa54M9PznGCoOXbnoObFpNf8gZkhLG5KXyP)ClCOuzFFib6n3nn8rdmOgEEAW3ZzbVXSYrjyozmw6p3chkzJZksGEZDtdF0adQXrnWQXbnKrdheavw9cau9N(hn880qgn475Symaub7OuEOs2(fDjnoQXrnWQXbnaN(ckkyYbI0WZtdheYaHClHZsB5ed1yBH0WhnWt7A45PXbnCqauz1lQf35NYgPbwnCqideYTeoybaEJs)jLqs7SpsmuJTfsdF0apTRXrnoQXrn8804GgGWxyGM0VaOeIRnnjqRXWrIHASTqA4Jg(Ugy1WbHmqi3s4S0woXqn2win8rd5AxdSA4GaOYQxuKBGm4aQXrn880yRNgjiZEcmLxCNFAOgBlKgxPHVRbwnKrdheYaHClHZsB5edzG(1WZtdheavw9IB(N1knWQbFpNf32cCiWe1ib5stdvVOlPHNNgoiaQS6faO6p9pAGvd(EolgdavWokLhQKTFXqn2winUsJlxdSAW3ZzXyaOc2rP8qLS9l6saFGyoEaIja5qLXZiqGykqoM7xybKJZkhXs89Cgih3SpnRbKZbn475SG3yw5OemNmgl9NBHdLk77djgQX2cPHpAGbe4rdppn475SG3yw5OemNmgl9NBHdLSXzfjgQX2cPHpAGbe4rJJAGvJdA4GqgiKBjCwAlNyOgBlKg(ObgqdppnoOHdczGqULGAKGCPjXdlqXqn2win8rdmGgy1qgn475S42wGdbMOgjixAAO6turdUv2KOlPbwnCqauz1lU5FwR04Ogh1aRgg6hJLKGCPrdFURrlBhih(EoNkRHaYb92WGdiqoGeYnR0VWcih8BLJyAW5THbhqn4U)PgMgfXvdmf2cmrd(EoRHvGAG)wCTVuonwu1MxdJh2FnEOg8KgDebc8bI5yqGycqouz8mceiMcKJ5(fwa5GEBq9bhbKdiHCZk9lSaYX30BK0GZBdQp4iKg8ugoKg4hwaG3iGCCZ(0Sgqoh0WbHmqi3s4Gfa4nk9NucjTZ(iXqn2winUsd8ObwnKrdWPVGIcMCGinWQXbnayZA8ms4Gfa4nkbsi)LtdppnCqideYTeolTLtmuJTfsJR0apACudSAaWM14zKWbMCWcC)fwACudSAiJgGWxK7J)emNiwViXVUBBHtdSA4GaOYQxulUZpLnsdSAiJgGtFbffm5arAGvdYXwjej2kzLFnWQHH(XyjjixA0WhnK12b(aXCmaqmbihQmEgbcetbYbkbKdIEGCm3VWciha2SgpJaYbGX6eqoh0GVNZIXaqfSJs5Hkz7xmuJTfsdF0apA45PHmAW3ZzXyaOc2rP8qLS9l6sACudSACqd(EolUTf4qGjQrcYLMgQ(ev0GBLnjgQX2cPXvAGZbkAm8PXrnWQXbn475SGCSvcrjeKzJyOgBlKg(ObohOOXWNgEEAW3Zzb5yReIsSEzJyOgBlKg(ObohOOXWNghbYbKqUzL(fwa54BGvBEnaHVgG9zlCA8NKgubQbmRXLQbGkyhPHVDOs2(VqdW(SfonUTf4qGAqnsqU00q1RbC0yln(tsdMHEnW5a1aM1WknWBhBLqeqoaSjvwdbKdi8tdHx9DOgQEeWhiM77aXeGCOY4zeiqmfihZ9lSaYb1R8oeqoUzFAwdiNHYdHonEgPbwnEBWrV43gk9We4sA4JgYHb1aRgMuYDsUBAGvda2SgpJeGWpneE13HAO6ra5487yu6Tbh9iGyUCaFGy(LdetaYHkJNrGaXuGCm3VWciNgiSY7qa54M9PznGCgkpe604zKgy14Tbh9IFBO0dtGlPHpAixlf4rdSAysj3j5UPbwnayZA8msac)0q4vFhQHQhbKJZVJrP3gC0JaI5Yb8bI5Y1oqmbihQmEgbcetbYXC)clGCqpXy2KYmBiGCCZ(0SgqodLhcDA8msdSA82GJEXVnu6HjWL0WhnKddQrRAmuJTfsdSAysj3j5UPbwnayZA8msac)0q4vFhQHQhbKJZVJrP3gC0JaI5Yb8bI5YjhqmbihQmEgbcetbYXC)clGCYWXrjyov23hcihqc5Mv6xybKJVfI5AalnCGAWD)ty)1WzssBHdih3SpnRbKJjLCNK7gWhiMlhgbIja5qLXZiqGykqoM7xybKd1ib5stIhwGa5asi3Ss)clGCW7gjixA0atHfOgCpPsdJh2FnEOgu90OHPrrC1atHTat0G7wGqUAyfOgidaPrgoAG)wCTVuoGCCZ(0Sgqoh0GCSvcrcwVSjve(En880GCSvcrceKztQi89A45Pb5yReIew5pve(En880GVNZcEJzLJsWCYyS0FUfouQSVpKyOgBlKg(ObgqGhn880GVNZcEJzLJsWCYyS0FUfouYgNvKyOgBlKg(ObgqGhn880Wq)ySKeKlnA4JgxE7AGvdheYaHClHZsB5edzG(1aRgYOb40xqrbtoqKgh1aRgh0WbHmqi3s4S0woXqn2win8rJw2UgEEA4GqgiKBjCwAlNyid0Vgh1WZtdEicPbwn26PrcYSNat5f35NgQX2cPXvAix7aFGyUCTeiMaKdvgpJabIPa5yUFHfqo5(4pbZjI1lcihqc5Mv6xybKJVfI3AmlUZxdEkdhsJoAlCAG)waKJB2NM1aYXbHmqi3s4S0woXqgOFnWQbaBwJNrchyYblW9xyPbwnoOHH(XyjjixA0WhnU821aRgYOHdcGkRErT4o)u2in880WbbqLvVOwCNFkBKgy1Wq)ySKeKlnACLgYA7ACudSAiJgoiaQS6faO6p9pAGvJdAiJgoiaQS6f1I78tzJ0WZtdheYaHClHdwaG3O0FsjK0o7JedzG(14Ogy1qgnaN(ckkyYbIa(aXC5KvGycqouz8mceiMcKducihe9a5yUFHfqoaSznEgbKdaJ1jGCKrdWPVGIcMCGinWQbaBwJNrchyYblW9xyPbwnoOXbnm0pgljb5sJg(OXL3Ugy14Gg89CwCBlWHatuJeKlnnu9jQOb3kBs0L0WZtdz0WbbqLvV4M)zTsJJA45PbFpNf8mieK1rVOlPbwn475SGNbHGSo6fd1yBH04kn475SWzPTCcW(y)clnoQHNNg8qesdSAS1tJeKzpbMYlUZpnuJTfsJR0GVNZcNL2Yja7J9lS0WZtdheavw9IAXD(PSrACudSACqdz0WbbqLvVOwCNFkBKgEEACqdd9JXssqU0OXvAiRTRHNNgGWxK7J)emNiwViXVUBBHtJJAGvJdAaWM14zKWblaWBucKq(lNgEEA4GqgiKBjCWca8gL(tkHK2zFKyid0Vgh14iqoGeYnR0VWcih83IR9LYPb3tQ0WEnU82BvJwGUenoahgKlnA8NwPHS2UgTaDjAWD)tnWpSaaVrh1G7(NW(RbdI2cNg)2qASLgykdcbzD0RHvGAW2I0OlPb39p1a)Wca8gPXM1yFn4AinajK)YrGa5aWMuzneqooWKdwG7VWkXdTh4deZLdpaXeGCOY4zeiqmfih3SpnRbKdaBwJNrchyYblW9xyL4H2dKJ5(fwa54igH(1yjJT4QgQEGpqmxomiqmbihQmEgbcetbYXn7tZAa5aWM14zKWbMCWcC)fwjEO9a5yUFHfqoB5SPSFHfWhiMlhgaiMaKdvgpJabIPa5aLaYbrpqoM7xybKdaBwJNra5aWyDcihYXwjej2kX6LnAGHA47ACTgM7xyjqVn5DibHpY1Fk9BdPrRAiJgKJTsisSvI1lB0ad14GgyqnAvJ3yu9ceSZsWC6pPugoe6fuz8mcudmuJwQXrnUwdZ9lSeCh7pfe(ix)P0VnKgTQr7cmQX1AGKiglDAONaYbKqUzL(fwa5G3OFBSNqACc5Qrt3DQrlqxIg2qAGZ2Ia1qIgnqKdwGa5aWMuzneqogs6sOHd5a(aXC58DGycqouz8mceiMcKJ5(fwa5GEBq9bhbKdiHCZk9lSaYX30BK0GZBdQp4iKgCpPsJ)K0iV4oFnwKggpS)A8qnOc8cnYdvY2VglsdJh2FnEOgubEHg(HDnSH0WEnU82BvJwGUen2sdR0aVDSvcrxOb(BX1(s50GzOhPHvW)Kgn89wrKdPbC0WpSRbxyNbQbeanotsJg4qA8NwPH6jx7A0c0LOb3tQ0WpSRbxyNbwT51GZBdQp4inkixGCCZ(0Sgqoh0GhIqAGvJTEAKGm7jWuEXD(PHASTqACLgYQgEEACqd(EolgdavWokLhQKTFXqn2winUsdCoqrJHpnWqnC0Y04Ggg6hJLKGCPrJR1OLTRXrnWQbFpNfJbGkyhLYdvY2VOlPXrnoQHNNgh0Wq)ySKeKlnA0QgaSznEgjmK0LqdhYPbgQbFpNfKJTsikHGmBed1yBH0OvnaHVi3h)jyorSErIFD3qPHAST0ad1aJc8OHpAiNCTRHNNgg6hJLKGCPrJw1aGnRXZiHHKUeA4qonWqn475SGCSvcrjwVSrmuJTfsJw1ae(ICF8NG5eX6fj(1DdLgQX2sdmudmkWJg(OHCY1Ugh1aRgKJTsisSvYk)AGvJdAiJg89Cw4S0worxsdppnKrJ3yu9c0BddoGcQmEgbQXrnWQXbnoOHmA4GqgiKBjCwAlNOlPHNNgoiaQS6f38pRvAGvdz0WbHmqi3sqnsqU0K4HfOOlPXrn880WbbqLvVOwCNFkBKgh1aRgh0qgnCqauz1laq1F6F0WZtdz0GVNZcNL2Yj6sA45PHH(XyjjixA0WhnU8214OgEEACqJ3yu9c0BddoGcQmEgbQbwn475SWzPTCIUKgy14Gg89CwGEByWbuGEZDtJR0OLA45PHH(XyjjixA0WhnU8214Ogh1WZtd(EolCwAlNOlPbwnKrd(EolgdavWokLhQKTFrxsdSAiJgVXO6fO3ggCafuz8mce4deZL7YbIja5qLXZiqGykqoM7xybKtrCtnqybKdiHCZk9lSaYXxrKgxAqyH0ylnAREzJg4TJTsisdRa1azainUu2y5w9TDgtJlniS0idhnWFlU2xkhqoUzFAwdiNdAW3Zzb5yReIsSEzJyOgBlKg(ObHpY1Fk9BdPHNNgh0WDAdocPXDnWOgy1yi3Pn4O0VnKgxPbE04OgEEA4oTbhH04UgTuJJAGvdtk5oj3nGpqmhJTdetaYHkJNrGaXuGCCZ(0Sgqoh0GVNZcYXwjeLy9YgXqn2win8rdcFKR)u63gsdSACqdheYaHClHZsB5ed1yBH0WhnWt7A45PHdczGqULWblaWBu6pPesAN9rIHASTqA4Jg4PDnoQHNNgh0WDAdocPXDnWOgy1yi3Pn4O0VnKgxPbE04OgEEA4oTbhH04UgTuJJAGvdtk5oj3nGCm3VWciNtJLtnqyb8bI5yuoGycqouz8mceiMcKJB2NM1aY5Gg89Cwqo2kHOeRx2igQX2cPHpAq4JC9Ns)2qAGvJdA4GqgiKBjCwAlNyOgBlKg(ObEAxdppnCqideYTeoybaEJs)jLqs7SpsmuJTfsdF0apTRXrn8804GgUtBWrinURbg1aRgd5oTbhL(TH04knWJgh1WZtd3Pn4iKg31OLACudSAysj3j5UbKJ5(fwa5K7mwQbclGpqmhJyeiMaKdvgpJabIPa5asi3Ss)clGCWSG4TgWsdhiqoM7xybKdxBMfojyorSEraFGyogBjqmbihQmEgbcetbYXC)clGCqVn5DiGCajKBwPFHfqo(kI0GZBtEhsJhQH0aDAWbYSrd82XwjePbC0G7jvASLgWI5xJ2Qx2ObE7yReI0Wkqn6isdmliERH0aDin2SgBPrB1lB0aVDSvcra54M9PznGCihBLqKyReRx2OHNNgKJTsisGGmBsfHVxdppnihBLqKWk)PIW3RHNNg89CwW1MzHtcMteRxKOlPbwn475SGCSvcrjwVSr0L0WZtJdAW3ZzHZsB5ed1yBH04knm3VWsWDS)uq4JC9Ns)2qAGvd(EolCwAlNOlPXrGpqmhJYkqmbihZ9lSaYH7y)jqouz8mceiMc8bI5yepaXeGCOY4zeiqmfihZ9lSaYz6vYC)cReBrpqoSf9PYAiGCYgJ9Nth4d8bYXGeqmbiMlhqmbihQmEgbcetbYbkbKdIEGCm3VWciha2SgpJaYbGX6eqoh0GVNZIFBiUWPsGdzn8BbsJyOgBlKgxPbohOOXWNgTQr7c50WZtd(Eol(TH4cNkboK1WVfinIHASTqACLgM7xyjqVn5DibHpY1Fk9BdPrRA0UqonWQXbnihBLqKyReRx2OHNNgKJTsisGGmBsfHVxdppnihBLqKWk)PIW3RXrnoQbwn475S43gIlCQe4qwd)wG0i6sAGvJPxugo4iXVnex4ujWHSg(TaPrqLXZiqGCajKBwPFHfqo43yUoZEcPb3t6pPrJ)K0W3mK14S3DsJg89CwdUlJPr2ymnG5SgC3)Cln(tsJIW3RHZqpqoaSjvwdbKd4qwtI7YyPSXyjyod8bI5yeiMaKdvgpJabIPa5aLaYbrpqoM7xybKdaBwJNra5aWyDcihz0GCSvcrITsiiZgnWQXbnqseJLEBWrpsGEBY7qA4Jg4rdSA8gJQxGGDwcMt)jLYWHqVGkJNrGA45PbsIyS0Bdo6rc0BtEhsdF0adOXrGCajKBwPFHfqo43yUoZEcPb3t6pPrdoVnO(GJ0yrAWfo)Pgod9BHtdiaA0GZBtEhsJT0OT6LnAG3o2kHiGCaytQSgciNfxbhkHEBq9bhb8bI5TeiMaKdvgpJabIPa5yUFHfqooybaEJs)jLqs7Spcihqc5Mv6xybKJVIinWpSaaVrAW9KknSxdgHqA8NwPbEAxJwGUenScud2wKgDjn4U)Pg4Vfx7lLdih3SpnRbKJmAao9fuuWKdePbwnoOXbnayZA8ms4Gfa4nkbsi)LtdSAiJgoiKbc5wcNL2YjgYa9RHNNg89Cw4S0worxsJJAGvJdAW3Zzb5yReIsSEzJyOgBlKg(Obgudppn475SGCSvcrjeKzJyOgBlKg(ObguJJAGvJdAiJgtVOmCWrcEJzLJsWCYyS0FUfoKGkJNrGA45PbFpNf8gZkhLG5KXyP)ClCOuzFFib6n3nn8rJwQHNNg89CwWBmRCucMtgJL(ZTWHs24SIeO3C30WhnAPgh1WZtdEicPbwnYlUZpnuJTfsJR0qU21aRgYOHdczGqULWzPTCIHmq)ACe4deZLvGycqouz8mceiMcKJ5(fwa5mgaQGDukpujB)a5asi3Ss)clGC8vePHVDOs2(1G7(NAG)wCTVuoGCCZ(0Sgqo89Cw4S0woXqn2win8rd5WdWhiMJhGycqouz8mceiMcKJ5(fwa5G6vEhcihNFhJsVn4OhbeZLdih3SpnRbKZbngkpe604zKgEEAW3Zzb5yReIsiiZgXqn2winUsJwQbwnihBLqKyRecYSrdSAmuJTfsJR0qozvdSA8gJQxGGDwcMt)jLYWHqVGkJNrGACudSA82GJEXVnu6HjWL0WhnKtw14Y0ajrmw6Tbh9inAvJHASTqAGvJdAqo2kHiXwjR8RHNNgd1yBH04knW5afng(04iqoGeYnR0VWcihFfrAWPx5Din2sdjRaPM1PbS0Wk))5w404pTxd2cGqAiNSIihsdRa1GriKgC3)uJg4qA82GJEKgwbQH9A8NKgubQbmRHPbhiZgnWBhBLqKg2RHCYQgiYH0aoAWiesJHAST2cNggsJhQrbFnonaBHtJhQXq5HqNAa2NTWPrB1lB0aVDSvcraFGyogeiMaKdvgpJabIPa5yUFHfqoOEL3HaYbKqUzL(fwa54Risdo9kVdPXd140aqAyAGJb5nMgpuJoI0WxWSLVbih3SpnRbKdaBwJNrIfVatoybU)clnWQHdczGqULylKB6VXZOeE1T67njqcW6iXqgOFnWQbHx9vsIafBHCt)nEgLWRUvFVjbsawhb8bI5yaGycqouz8mceiMcKJB2NM1aYrgnEJr1lqpXy2KaNn)cQmEgbQbwnoObFpNfO3MSXyIHYdHonEgPbwnoObsIyS0Bdo6rc0Bt2ymnUsJwQHNNgYOX0lkdhCK43gIlCQe4qwd)wG0iOY4zeOgh1WZtJ3yu9ceSZsWC6pPugoe6fuz8mcudSAW3Zzb5yReIsiiZgXqn2winUsJwQbwnihBLqKyRecYSrdSAW3Zzb6TjBmMyOgBlKgxPbgqdSAGKigl92GJEKa92KngtdFURHSQXrnWQXbnKrJPxugo4ibZVZgdLYmI(TWLWX2gjejOY4zeOgEEA8BdPbMrdzfpA4Jg89CwGEBYgJjgQX2cPrRAGrnoQbwnEBWrV43gk9We4sA4Jg4bihZ9lSaYb92Kngd4deZ9DGycqouz8mceiMcKJ5(fwa5GEBYgJbKdiHCZk9lSaYbZA)tn48eJzJg(MzZVgDePbS0WbQb3tQ0yO8qOtJNrAW3Fnq)YyAW12xJmC0OT87SXqAinqNgwbQbiSAZRrhrAWtz4qAGFFdsObNFzmn6isdEkdhsd8dlaWBKgOTCKg)P9AWDzmnKgOtdRG)jnAW5TjBmgqoUzFAwdiN3yu9c0tmMnjWzZVGkJNrGAGvd(EolqVnzJXedLhcDA8msdSACqdz0y6fLHdosW87SXqPmJOFlCjCSTrcrcQmEgbQHNNg)2qAGz0qwXJg(OHSQXrnWQXBdo6f)2qPhMaxsdF0OLaFGy(LdetaYHkJNrGaXuGCm3VWcih0Bt2ymGCajKBwPFHfqoyw7FQHVziRHFlqA0OJin482KngtJhQXnIK0OlPXFsAW3Zzn49RHXqqn6OTWPbN3MSXyAalnWJgiYblqKgWrdgHqAmuJT1w4aYXn7tZAa5m9IYWbhj(TH4cNkboK1WVfincQmEgbQbwnqseJLEBWrpsGEBYgJPHp31OLAGvJdAiJg89Cw8BdXfovcCiRHFlqAeDjnWQbFpNfO3MSXyIHYdHonEgPHNNgh0aGnRXZib4qwtI7YyPSXyjyoRbwnoObFpNfO3MSXyIHASTqACLgTudppnqseJLEBWrpsGEBYgJPHpAGrnWQXBmQEb6jgZMe4S5xqLXZiqnWQbFpNfO3MSXyIHASTqACLg4rJJACuJJaFGyUCTdetaYHkJNrGaXuGCGsa5GOhihZ9lSaYbGnRXZiGCaySobKJH(XyjjixA0Whn89214Y04GgY1UgyOg89Cw8BdXfovcCiRHFlqAeO3C304OgxMgh0GVNZc0Bt2ymXqn2winWqnAPgxRbsIyS0PHEsdmudz04ngvVa9eJztcC28lOY4zeOgh14Y04GgoiKbc5wc0Bt2ymXqn2winWqnAPgxRbsIyS0PHEsdmuJ3yu9c0tmMnjWzZVGkJNrGACuJltJdAacFrUp(tWCIy9Ied1yBH0ad1apACudSACqd(EolqVnzJXeDjn880WbHmqi3sGEBYgJjgQX2cPXrGCajKBwPFHfqo43yUoZEcPb3t6pPrdtdoVnO(GJ0OJin4UmMgoRJin482KngtJhQr2ymnG58fAyfOgDePbN3guFWrA8qnUrKKg(MHSg(TaPrd0BUBA0LaYbGnPYAiGCqVnzJXsCH1NYgJLG5mWhiMlNCaXeGCOY4zeiqmfihZ9lSaYb92G6docihqc5Mv6xybKJVIin482G6dosdU7FQHVziRHFlqA04HACJijn6sA8NKg89CwdU7Fc7VgmiAlCAW5TjBmMgDPFBinScuJoI0GZBdQp4inGLgYARAGPWwGjAGEZDdPrV(LPHSQXBdo6ra54M9PznGCayZA8msaoK1K4UmwkBmwcMZAGvda2SgpJeO3MSXyjUW6tzJXsWCwdSAiJgaSznEgjwCfCOe6Tb1hCKgEEACqd(Eol4nMvokbZjJXs)5w4qPY((qc0BUBA4JgTudppn475SG3yw5OemNmgl9NBHdLSXzfjqV5UPHpA0snoQbwnqseJLEBWrpsGEBYgJPXvAiRAGvda2SgpJeO3MSXyjUW6tzJXsWCg4deZLdJaXeGCOY4zeiqmfihZ9lSaYXanPFbqjexBAaYX53XO0Bdo6raXC5aYXn7tZAa5iJg)6UTfonWQHmAyUFHLWanPFbqjexBAsGwJHJeBLYSf35RHNNgGWxyGM0VaOeIRnnjqRXWrc0BUBACLgTudSAacFHbAs)cGsiU20KaTgdhjgQX2cPXvA0sGCajKBwPFHfqo(kI0aX1Mgnqqn(t71WpSRbo61OXWNgDPFBin49RrhTfon2xddPbZEsddPHeeHwEgPbS0GriKg)PvA0snqV5UH0aoAGzth9AW9KknAzRAGEZDdPbHpPDiGpqmxUwcetaYHkJNrGaXuGCm3VWciNgiSY7qa5487yu6Tbh9iGyUCa54M9PznGCgkpe604zKgy14Tbh9IFBO0dtGlPHpACqJdAiNSQrRACqdKeXyP3gC0JeO3M8oKgyOgyudmud(EolihBLquI1lBeDjnoQXrnAvJHASTqACuJR14GgYPrRA8gJQx8C3k1aHfsqLXZiqnoQbwnoOHdczGqULWzPTCIHmq)AGvdz0aC6lOOGjhisdSACqda2SgpJeoybaEJsGeYF50WZtdheYaHClHdwaG3O0FsjK0o7JedzG(1WZtdz0WbbqLvVOwCNFkBKgh1WZtdKeXyP3gC0JeO3M8oKgxPXbnoObguJltJdAW3Zzb5yReIsSEzJOlPbgQbg14Ogh1ad14GgYPrRA8gJQx8C3k1aHfsqLXZiqnoQXrnWQHmAqo2kHibcYSjve(En8804GgKJTsisSvcbz2OHNNgh0GCSvcrITs8W)udppnihBLqKyReRx2OXrnWQHmA8gJQxGGDwcMt)jLYWHqVGkJNrGA45PbFpNfsZ2ahW1yjBCwTUKuNHSraWyDsdFURbgXt7ACudSACqdKeXyP3gC0JeO3M8oKgxPHCTRbgQXbnKtJw14ngvV45UvQbclKGkJNrGACuJJAGvdd9JXssqU0OHpAGN214Y0GVNZc0Bt2ymXqn2winWqnWGACudSACqdz0GVNZIBBboeyIAKGCPPHQprfn4wztIUKgEEAqo2kHiXwjeKzJgEEAiJgoiaQS6f38pRvACudSAiJg89CwmgaQGDukpujB)j0w5olD6h90SMOlbKdiHCZk9lSaY5sLYdHo14sdcR8oKgBwd83IR9LYPXI0yid0)fA8N0qAydPbJqin(tR0apA82GJEKgBPrB1lB0aVDSvcrAWD)tn4aFF7fAWiesJ)0knKRDnG)jnCxePXwAyLFnWBhBLqKgWrJUKgpud8OXBdo6rAWtz4qAyA0w9YgnWBhBLqKqdFdSAZRXq5HqNAa2NTWPXLITahcud8UrcYLMgQEn6fJqin2sdoqMnAG3o2kHiGpqmxozfiMaKdvgpJabIPa5yUFHfqoz44OemNk77dbKdiHCZk9lSaYXxrKg(wiMRbS0WbQb39pH9xdNjjTfoGCCZ(0SgqoMuYDsUBaFGyUC4biMaKdvgpJabIPa5aLaYbrpqoM7xybKdaBwJNra5aWyDcihz0aC6lOOGjhisdSAaWM14zKWbMCWcC)fwAGvJdACqd(EolqVnzJXeDjn8804ngvVa9eJztcC28lOY4zeOgEEA4GaOYQxulUZpLnsJJAGvJdAiJg89CwGGm0Vos0L0aRgYObFpNfolTLt0L0aRgh0qgnEJr1lY9XFcMteRxKGkJNrGA45PbFpNfolTLta2h7xyPHpA4GqgiKBjY9XFcMteRxKyOgBlKgTQHVRXrnWQbaBwJNrI)CwglHi6gnjU2(AGvJdAiJgoiaQS6f1I78tzJ0WZtdheYaHClHdwaG3O0FsjK0o7JeDjnWQXbn475Sa92KngtmuJTfsJR0aJA45PHmA8gJQxGEIXSjboB(fuz8mcuJJACudSA82GJEXVnu6HjWL0Whn475SWzPTCcW(y)clnWqnAxGb04OgEEAWdrinWQrEXD(PHASTqACLg89Cw4S0wobyFSFHLghbYbGnPYAiGCCGjhSa3FHvYGeWhiMlhgeiMaKdvgpJabIPa5yUFHfqooIrOFnwYylUQHQhihqc5Mv6xybKJVIinWFlU2xkNgWsdhOg9IriKgwbQbBlsJ91OlPb39p1a)Wca8gbKJB2NM1aYbGnRXZiHdm5Gf4(lSsgKa(aXC5WaaXeGCOY4zeiqmfih3SpnRbKdaBwJNrchyYblW9xyLmibKJ5(fwa5SLZMY(fwaFGyUC(oqmbihQmEgbcetbYXC)clGCOgjixAs8Wceihqc5Mv6xybKJVIinW7gjixA0atHfOgWsdhOgC3)udoVnzJX0OlPHvGAGmaKgz4OXL0ziB0WkqnWFlU2xkhqoUzFAwdihEicPbwn26PrcYSNat5f35NgQX2cPXvAihE0WZtJdAW3ZzH0SnWbCnwYgNvRlj1ziBeamwN04knWiEAxdppn475SqA2g4aUglzJZQ1LK6mKncagRtA4ZDnWiEAxJJAGvd(EolqVnzJXeDjnWQXbnCqideYTeolTLtmuJTfsdF0apTRHNNgGtFbffm5arACe4deZL7YbIja5qLXZiqGykqoM7xybKd6jgZMuMzdbKJZVJrP3gC0JaI5YbKJB2NM1aYzO8qOtJNrAGvJFBO0dtGlPHpAihE0aRgijIXsVn4OhjqVn5DinUsdzvdSAysj3j5UPbwnoObFpNfolTLtmuJTfsdF0qU21WZtdz0GVNZcNL2Yj6sACeihqc5Mv6xybKZLkLhcDQrMzdPbS0OlPXd1OLA82GJEKgC3)e2FnWFlU2xkNg80w40W4H9xJhQbHpPDinScuJc(AabqJZKK2chWhiMJX2bIja5qLXZiqGykqoM7xybKtUp(tWCIy9IaYbKqUzL(fwa54RisdFleV1yZASfAbjnSsd82XwjePHvGAW2I0yFn6sAWD)tnmnUKodzJgsd0PHvGA0cqt6xaKgC4AtdqoUzFAwdihYXwjej2kzLFnWQHjLCNK7Mgy1GVNZcPzBGd4ASKnoRwxsQZq2iaySoPXvAGr80Ugy14GgGWxyGM0VaOeIRnnjqRXWrIFD32cNgEEAiJgoiaQS6ff5gidoGA45PbsIyS0Bdo6rA4JgyuJJAGvJdAW3ZzXyaOc2rP8qLS9lgQX2cPXvAC5ACzACqd8ObgQX0lkdhCKaTvUZsN(rpnRjOY4zeOgh1aRg89CwmgaQGDukpujB)IUKgEEAiJg89CwmgaQGDukpujB)IUKgh1aRgh0qgnCqideYTeolTLt0L0WZtd(Eol(ZzzSeIOB0iqV5UPXvAihE0aRg5f35NgQX2cPXvAGX2BxdSAKxCNFAOgBlKg(OHCT3UgEEAiJgiyNXVfO4pNLXsiIUrJGkJNrGACudSACqdeSZ43cu8NZYyjer3OrqLXZiqn880WbHmqi3s4S0woXqn2win8rJw2Ughb(aXCmkhqmbihQmEgbcetbYXC)clGCqVnzJXaYbKqUzL(fwa54RisdtdoVnzJX04sVO)udPb60OxmcH0GZBt2ymnwKggBid0VgDjnGJg(HDnSH0W4H9xJhQbeanotsJwGUeGCCZ(0Sgqo89Cwal6prjjACK0VWs0L0aRgh0GVNZc0Bt2ymXq5HqNgpJ0WZtdd9JXssqU0OHpAC5TRXrGpqmhJyeiMaKdvgpJabIPa5yUFHfqoO3MSXya5asi3Ss)clGC8n9gjnAb6s0GNYWH0a)Wca8gPb39p1GZBt2ymnScuJ)Kkn482G6docih3SpnRbKJdcGkRErT4o)u2inWQHmA8gJQxGEIXSjboB(fuz8mcudSACqda2SgpJeoybaEJsGeYF50WZtdheYaHClHZsB5eDjn880GVNZcNL2Yj6sACudSA4GqgiKBjCWca8gL(tkHK2zFKyOgBlKgxPbohOOXWNgyOgoAzACqdd9JXssqU0OX1AGN214Ogy1GVNZc0Bt2ymXqn2winUsdzvdSAiJgGtFbffm5araFGyogBjqmbihQmEgbcetbYXn7tZAa54GaOYQxulUZpLnsdSACqda2SgpJeoybaEJsGeYF50WZtdheYaHClHZsB5eDjn880GVNZcNL2Yj6sACudSA4GqgiKBjCWca8gL(tkHK2zFKyOgBlKgxPbgudSAW3Zzb6TjBmMOlPbwnihBLqKyRKv(1aRgYObaBwJNrIfxbhkHEBq9bhPbwnKrdWPVGIcMCGiGCm3VWcih0BdQp4iGpqmhJYkqmbihQmEgbcetbYXC)clGCqVnO(GJaYbKqUzL(fwa54RisdoVnO(GJ0G7(NAyLgx6f9NAinqNgWrJnRHFyVnGAabqJZK0OfOlrdU7FQHFyF0Oi89A4m0l0OfmeudWEJKgTaDjAyVg)jPbvGAaZA8NKgy2P6p9pAW3Zzn2SgCEBYgJPbxyNbwT51iBmMgWCwd4OHFyxdBinGLgyuJ3gC0JaYXn7tZAa5W3ZzbSO)eLCmYMeGfTWs0L0WZtJdAiJgO3M8oKWKsUtYDtdSAiJgaSznEgjwCfCOe6Tb1hCKgEEACqd(EolCwAlNyOgBlKgxPbE0aRg89Cw4S0worxsdppnoOXbn475SWzPTCIHASTqACLg4CGIgdFAGHA4OLPXbnm0pgljb5sJgxRrlBxJJAGvd(EolCwAlNOlPHNNg89CwmgaQGDukpujB)j0w5olD6h90SMyOgBlKgxPbohOOXWNgyOgoAzACqdd9JXssqU0OX1A0Y214Ogy1GVNZIXaqfSJs5Hkz7pH2k3zPt)ONM1eDjnoQbwnCqauz1laq1F6F04Ogh1aRgh0ajrmw6Tbh9ib6TjBmMgxPrl1WZtda2SgpJeO3MSXyjUW6tzJXsWCwJJACudSAiJgaSznEgjwCfCOe6Tb1hCKgy14GgYOX0lkdhCK43gIlCQe4qwd)wG0iOY4zeOgEEAGKigl92GJEKa92KngtJR0OLACe4deZXiEaIja5qLXZiqGykqoM7xybKtrCtnqybKdiHCZk9lSaYXxrKgxAqyH0yln4az2ObE7yReI0WkqnqgasdFBNX04sdclnYWrd83IR9LYbKJB2NM1aY5Gg89Cwqo2kHOecYSrmuJTfsdF0GWh56pL(TH0WZtJdA4oTbhH04UgyudSAmK70gCu63gsJR0apACudppnCN2GJqACxJwQXrnWQHjLCNK7gWhiMJrmiqmbihQmEgbcetbYXn7tZAa5Cqd(EolihBLqucbz2igQX2cPHpAq4JC9Ns)2qA45PXbnCN2GJqACxdmQbwngYDAdok9BdPXvAGhnoQHNNgUtBWrinURrl14Ogy1WKsUtYDtdSACqd(EolgdavWokLhQKTFXqn2winUsd8Obwn475Symaub7OuEOs2(fDjnWQHmAm9IYWbhjqBL7S0PF0tZAcQmEgbQHNNgYObFpNfJbGkyhLYdvY2VOlPXrGCm3VWciNtJLtnqyb8bI5yedaetaYHkJNrGaXuGCCZ(0Sgqoh0GVNZcYXwjeLqqMnIHASTqA4Jge(ix)P0VnKgy14GgoiKbc5wcNL2YjgQX2cPHpAGN21WZtdheYaHClHdwaG3O0FsjK0o7Jed1yBH0WhnWt7ACudppnoOH70gCesJ7AGrnWQXqUtBWrPFBinUsd8OXrn880WDAdocPXDnAPgh1aRgMuYDsUBAGvJdAW3ZzXyaOc2rP8qLS9lgQX2cPXvAGhnWQbFpNfJbGkyhLYdvY2VOlPbwnKrJPxugo4ibARCNLo9JEAwtqLXZiqn880qgn475Symaub7OuEOs2(fDjnocKJ5(fwa5K7mwQbclGpqmhJ(oqmbihQmEgbcetbYbKqUzL(fwa54RisdmliERbS0a)(gGCm3VWcihU2mlCsWCIy9Ia(aXCmE5aXeGCOY4zeiqmfihOeqoi6bYXC)clGCayZA8mcihagRta5GKigl92GJEKa92K3H0WhnKvnAvJmdchnoOrJHEA8NaySoPbgQHCT3UgxRbgBxJJA0QgzgeoACqd(EolqVnO(GJsuJeKlnnu9jeKzJa9M7MgxRHSQXrGCajKBwPFHfqo43yUoZEcPb3t6pPrJhQrhrAW5TjVdPXwAWbYSrdUNR7uJfPH9AGhnEBWrpQv50idhnia04xdm2oMrJgd904xd4OHSQbN3guFWrAG3nsqU00q1Rb6n3neqoaSjvwdbKd6TjVdL2kHGmBa(aX8w2oqmbihQmEgbcetbYbkbKdIEGCm3VWciha2SgpJaYbGX6eqoYPX1AGKiglDAON04knWOgxMgh0ODbg1ad14GgijIXsVn4OhjqVn5DinUmnKtJJAGHACqd50OvnEJr1lqWolbZP)Ksz4qOxqLXZiqnWqnKtGhnoQXrnAvJ2fYHhnWqn475Symaub7OuEOs2(fd1yBHaYbKqUzL(fwa5GFJ56m7jKgCpP)KgnEOgywJ9NAa2NTWPHVDOs2(bYbGnPYAiGC4o2FM2kLhQKTFGpqmVLYbetaYHkJNrGaXuGCm3VWcihUJ9Na5asi3Ss)clGC8vePbM1y)PgBPbhiZgnWBhBLqKgWrJnRrb1GZBtEhsdUlJPrEFn26HAG)wCTVuonSYFdCiGCCZ(0Sgqoh0GCSvcrcwVSjve(En880GCSvcrcR8NkcFVgy1aGnRXZiXIsogzainoQbwnoOXBdo6f)2qPhMaxsdF0qw1WZtdYXwjejy9YM0wjmQHNNg5f35NgQX2cPXvAix7ACudppn475SGCSvcrjeKzJyOgBlKgxPH5(fwc0BtEhsq4JC9Ns)2qAGvd(EolihBLqucbz2i6sA45Pb5yReIeBLqqMnAGvdz0aGnRXZib6TjVdL2kHGmB0WZtd(EolCwAlNyOgBlKgxPH5(fwc0BtEhsq4JC9Ns)2qAGvdz0aGnRXZiXIsogzainWQbFpNfolTLtmuJTfsJR0GWh56pL(TH0aRg89Cw4S0worxsdppn475Symaub7OuEOs2(fDjnWQbaBwJNrcUJ9NPTs5Hkz7xdppnKrda2SgpJelk5yKbG0aRg89Cw4S0woXqn2win8rdcFKR)u63gc4deZBjgbIja5qLXZiqGykqoGeYnR0VWcihFfrAW5TjVdPXM1ylnAREzJg4TJTsi6cn2sdoqMnAG3o2kHinGLgYARA82GJEKgWrJhQH0aDAWbYSrd82XwjebKJ5(fwa5GEBY7qaFGyElBjqmbihQmEgbcetbYbKqUzL(fwa54Bng7pNoqoM7xybKZ0RK5(fwj2IEGCyl6tL1qa5Kng7pNoWh4dKt2yS)C6aXeGyUCaXeGCOY4zeiqmfihZ9lSaYb92G6docihqc5Mv6xybKdN3guFWrAKHJgnqaudvVg9IriKgD0w40atHTataYXn7tZAa5iJgtVOmCWrcEJzLJsWCYyS0FUfoKGWR(kjrGaFGyogbIja5qLXZiqGykqoM7xybKdQx5DiGCC(Dmk92GJEeqmxoGCCZ(0SgqoGWx0aHvEhsmuJTfsdF0yOgBlKgyOgyeJACTgY57a5asi3Ss)clGCWVHEn(tsdq4Rb39p14pjnAGOxJFBinEOggiOg96xMg)jPrJHpna7J9lS0yrACUVqdo9kVdPXqn2winA6SFLylbQXd1OXE3PgnqyL3H0aSp2VWc4deZBjqmbihZ9lSaYPbcR8oeqouz8mceiMc8b(a5GEGycqmxoGycqouz8mceiMcKJ5(fwa5GEBq9bhbKdiHCZk9lSaYXxrKgCEBq9bhPXd14grsA0L04pjn8ndzn8BbsJg89CwJnRX(AWf2zGAq4tAhsdEkdhsJ8wl6ClCA8NKgfHVxdNHEnGJgpudWEJKg8ugoKg4hwaG3iGCCZ(0SgqotVOmCWrIFBiUWPsGdzn8BbsJGkJNrGAGvJdAqo2kHiXwjR8RbwnKrJdACqd(Eol(TH4cNkboK1WVfinIHASTqA4JgM7xyj4o2Fki8rU(tPFBinAvJ2fYPbwnoOb5yReIeBL4H)PgEEAqo2kHiXwjeKzJgEEAqo2kHibRx2KkcFVgh1WZtd(Eol(TH4cNkboK1WVfinIHASTqA4JgM7xyjqVn5DibHpY1Fk9BdPrRA0UqonWQXbnihBLqKyReRx2OHNNgKJTsisGGmBsfHVxdppnihBLqKWk)PIW3RXrnoQHNNgYObFpNf)2qCHtLahYA43cKgrxsJJA45PXbn475SWzPTCIUKgEEAaWM14zKWblaWBucKq(lNgh1aRgoiKbc5wchSaaVrP)KsiPD2hjgYa9RbwnCqauz1lQf35NYgPXrnWQXbnKrdheavw9IB(N1kn880WbHmqi3sqnsqU0K4HfOyOgBlKg(OHVRXrnWQXbn475SWzPTCIUKgEEAiJgoiKbc5wcNL2YjgYa9RXrGpqmhJaXeGCOY4zeiqmfihZ9lSaYXanPFbqjexBAaYX53XO0Bdo6raXC5aYXn7tZAa5iJgGWxyGM0VaOeIRnnjqRXWrIFD32cNgy1qgnm3VWsyGM0VaOeIRnnjqRXWrITsz2I781aRgh0qgnaHVWanPFbqjexBAsNKXe)6UTfon880ae(cd0K(faLqCTPjDsgtmuJTfsdF0apACudppnaHVWanPFbqjexBAsGwJHJeO3C304knAPgy1ae(cd0K(faLqCTPjbAngosmuJTfsJR0OLAGvdq4lmqt6xaucX1MMeO1y4iXVUBBHdihqc5Mv6xybKJVIinAbOj9lasdoCTPrdUNuPXFsdPXI0OGAyUFbqAG4AtZfAyiny2tAyinKGi0YZinGLgiU20Ob39p1aJAahnYexA0a9M7gsd4ObS0W0OLTQbIRnnAGGA8N2RXFsAuexnqCTPrdBMfaH0aZMo61WYpnA8N2RbIRnnAq4tAhcb8bI5TeiMaKdvgpJabIPa5yUFHfqooybaEJs)jLqs7Spcihqc5Mv6xybKJVIiKg4hwaG3in2Sg4Vfx7lLtJfPrxsd4OHFyxdBinajK)YTfonWFlU2xkNgC3)ud8dlaWBKgwbQHFyxdBin4jgKRgYA7A0c0LaKJB2NM1aYrgnaN(ckkyYbI0aRgh04GgaSznEgjCWca8gLajK)YPbwnKrdheYaHClHZsB5edzG(1aRgYOX0lkdhCKqA2g4aUglzJZQ1LK6mKncQmEgbQHNNg89Cw4S0worxsJJAGvdd9JXssqU0OXv31qwBxdSACqd(EolihBLquI1lBed1yBH0WhnKRDn880GVNZcYXwjeLqqMnIHASTqA4JgY1Ugh1WZtdEicPbwnYlUZpnuJTfsJR0qU21aRgYOHdczGqULWzPTCIHmq)ACe4deZLvGycqouz8mceiMcKducihe9a5yUFHfqoaSznEgbKdaJ1jGCoObFpNfJbGkyhLYdvY2VyOgBlKg(ObE0WZtdz0GVNZIXaqfSJs5Hkz7x0L04Ogy1qgn475Symaub7OuEOs2(tOTYDw60p6PznrxsdSACqd(EolUTf4qGjQrcYLMgQ(ev0GBLnjgQX2cPXvAGZbkAm8PXrnWQXbn475SGCSvcrjeKzJyOgBlKg(ObohOOXWNgEEAW3Zzb5yReIsSEzJyOgBlKg(ObohOOXWNgEEACqdz0GVNZcYXwjeLy9YgrxsdppnKrd(EolihBLqucbz2i6sACudSAiJgVXO6fiid9RJeuz8mcuJJa5asi3Ss)clGCWpSa3FHLgz4OHXyAacFKg)P9A0y3iKgO(qA8NKFnSHQ28AmuEi0jbQb3tQ04s1aqfSJ0W3oujB)ACAinyecPXFALg4rde5qAmuJT1w40aoA8NKg38pRvAW3ZznwKggpS)A8qnYgJPbmN1aoAyLFnWBhBLqKglsdJh2FnEOge(K2HaYbGnPYAiGCaHFAi8QVd1q1Ja(aXC8aetaYHkJNrGaXuGCGsa5GOhihZ9lSaYbGnRXZiGCaySobKZbnKrd(EolihBLqucbz2i6sAGvdz0GVNZcYXwjeLy9YgrxsJJA45PXBmQEbcYq)6ibvgpJabYbKqUzL(fwa5GFybU)cln(t71WDsUBin2Sg(HDnSH0a2F0csAqo2kHinEOgWI5xdq4RXFsdPbC0yXvWH04pxKgC3)udoqg6xhbKdaBsL1qa5ac)eS)OfKsKJTsic4deZXGaXeGCOY4zeiqmfihZ9lSaYPbcR8oeqoUzFAwdiNHYdHonEgPbwnoObFpNfKJTsikHGmBed1yBH0WhngQX2cPHNNg89Cwqo2kHOeRx2igQX2cPHpAmuJTfsdppnayZA8msac)eS)OfKsKJTsisJJAGvJHYdHonEgPbwnEBWrV43gk9We4sA4JgYHrnWQHjLCNK7Mgy1aGnRXZibi8tdHx9DOgQEeqoo)ogLEBWrpciMlhWhiMJbaIja5qLXZiqGykqoM7xybKdQx5DiGCCZ(0SgqodLhcDA8msdSACqd(EolihBLqucbz2igQX2cPHpAmuJTfsdppn475SGCSvcrjwVSrmuJTfsdF0yOgBlKgEEAaWM14zKae(jy)rliLihBLqKgh1aRgdLhcDA8msdSA82GJEXVnu6HjWL0WhnKdJAGvdtk5oj3nnWQbaBwJNrcq4NgcV67qnu9iGCC(Dmk92GJEeqmxoGpqm33bIja5qLXZiqGykqoM7xybKd6jgZMuMzdbKJB2NM1aYzO8qOtJNrAGvJdAW3Zzb5yReIsiiZgXqn2win8rJHASTqA45PbFpNfKJTsikX6LnIHASTqA4Jgd1yBH0WZtda2SgpJeGWpb7pAbPe5yReI04Ogy1yO8qOtJNrAGvJ3gC0l(THspmbUKg(OHCyqnWQHjLCNK7Mgy1aGnRXZibi8tdHx9DOgQEeqoo)ogLEBWrpciMlhWhiMF5aXeGCOY4zeiqmfihZ9lSaYjdhhLG5uzFFiGCajKBwPFHfqo(kI0W3cXCnGLgoqn4U)jS)A4mjPTWbKJB2NM1aYXKsUtYDd4deZLRDGycqouz8mceiMcKJ5(fwa5qnsqU0K4HfiqoGeYnR0VWcihFfrACPylWHa1GJ0o7J0G7(NAyLFnyWcNgub74o1GzOFlCAG3o2kHinScuJF8RXd1GTfPX(A0L0G7(NACjDgYgnScud83IR9LYbKJB2NM1aY5Ggh0GVNZcYXwjeLqqMnIHASTqA4JgY1UgEEAW3Zzb5yReIsSEzJyOgBlKg(OHCTRXrnWQHdczGqULWzPTCIHASTqA4JgTSDnWQXbn475SqA2g4aUglzJZQ1LK6mKncagRtACLgyuwBxdppnKrJPxugo4iH0SnWbCnwYgNvRlj1ziBeeE1xjjcuJJACudppn475SqA2g4aUglzJZQ1LK6mKncagRtA4ZDnWigODn880WbHmqi3s4S0woXqgOFnWQHH(XyjjixA0WhnU82b(aXC5KdiMaKdvgpJabIPa5aLaYbrpqoM7xybKdaBwJNra5aWyDcihz0aC6lOOGjhisdSAaWM14zKWbMCWcC)fwAGvJdACqdheYaHClb1i5FiJLGdyzLJed1yBH04knKddIb0OvnoOHCYPbgQX0lkdhCKaTvUZsN(rpnRjOY4zeOgh1aRgeE1xjjcuqns(hYyj4aww5inoQHNNgg6hJLKGCPrdFURXL3Ugy14GgYOXBmQErUp(tWCIy9Ieuz8mcudppn475SWzPTCcW(y)cln8rdheYaHClrUp(tWCIy9Ied1yBH0Ovn8DnoQbwnaHVa1R8oKyOgBlKg(OHCyudSAacFrdew5DiXqn2win8rdFxdSACqdq4lqpXy2KYmBiXqn2win8rdFxdppnKrJ3yu9c0tmMnPmZgsqLXZiqnoQbwnayZA8ms8NZYyjer3OjX12xdSACqd(EolUTf4qGjQrcYLMgQ(ev0GBLnj6sA45PHmA4GaOYQxCZ)SwPXrnWQXBdo6f)2qPhMaxsdF0GVNZcNL2Yja7J9lS0ad1ODbgqdppn4HiKgy1iV4o)0qn2winUsd(EolCwAlNaSp2VWsdppnCqauz1lQf35NYgPHNNg89CwWZGqqwh9IUKgy1GVNZcEgecY6OxmuJTfsJR0GVNZcNL2Yja7J9lS0OvnoOXLRbgQX0lkdhCKqA2g4aUglzJZQ1LK6mKnccV6RKebQXrnoQbwnKrd(EolCwAlNOlPbwnoOHmA4GaOYQxulUZpLnsdppnCqideYTeoybaEJs)jLqs7Sps0L0WZtdEicPbwnYlUZpnuJTfsJR0WbHmqi3s4Gfa4nk9NucjTZ(iXqn2winAvdmOgEEAKxCNFAOgBlKgygnKZ3BxJR0GVNZcNL2Yja7J9lS04iqoGeYnR0VWcihFfrAG)wCTVuon4U)Pg4hwaG3ORVuSf4qGAWrAN9rAyfOgGWQnVgqa0WD2N04s6mKnAahn4EsLgykdcbzD0RbxyNbQbHpPDin4PmCinWFlU2xkNge(K2Hqa5aWMuzneqooWKdwG7VWkHEGpqmxomcetaYHkJNrGaXuGCGsa5GOhihZ9lSaYbGnRXZiGCaySobKJmAao9fuuWKdePbwnayZA8ms4atoybU)clnWQXbnoOHdczGqULGAK8pKXsWbSSYrIHASTqACLgYHbXaA0Qgh0qo50ad1y6fLHdosG2k3zPt)ONM1euz8mcuJJAGvdcV6RKebkOgj)dzSeCalRCKgh1WZtdd9JXssqU0OHp314YBxdSACqdz04ngvVi3h)jyorSErcQmEgbQHNNg89Cw4S0wobyFSFHLg(OHdczGqULi3h)jyorSErIHASTqA0Qg(Ugh1aRgGWxG6vEhsmuJTfsdF0W31aRgGWx0aHvEhsmuJTfsdF04Y1aRgh0ae(c0tmMnPmZgsmuJTfsdF0qU21WZtdz04ngvVa9eJztkZSHeuz8mcuJJAGvda2SgpJe)5Smwcr0nAsCT91aRgh0GVNZIBBboeyIAKGCPPHQprfn4wztIUKgEEAiJgoiaQS6f38pRvACudSA82GJEXVnu6HjWL0Whn475SWzPTCcW(y)clnWqnAxGb0WZtdEicPbwnYlUZpnuJTfsJR0GVNZcNL2Yja7J9lS0WZtdheavw9IAXD(PSrA45PbFpNf8mieK1rVOlPbwn475SGNbHGSo6fd1yBH04kn475SWzPTCcW(y)clnAvJdAC5AGHAm9IYWbhjKMTboGRXs24SADjPodzJGWR(kjrGACuJJAGvdz0GVNZcNL2Yj6sAGvJdAiJgoiaQS6f1I78tzJ0WZtdheYaHClHdwaG3O0FsjK0o7JeDjn880GhIqAGvJ8I78td1yBH04knCqideYTeoybaEJs)jLqs7SpsmuJTfsJw1adQHNNg8qesdSAKxCNFAOgBlKgygnKZ3BxJR0GVNZcNL2Yja7J9lS04iqoaSjvwdbKJdm5Gf4(lSsOh4deZLRLaXeGCOY4zeiqmfihZ9lSaYzmaub7OuEOs2(bYbKqUzL(fwa54RisJ)K0aZov)P)rdU7FQHPb(BX1(s504pTxJfvT51ipWgnUKodzdqoUzFAwdih(EolCwAlNyOgBlKg(OHC4rdppn475SWzPTCcW(y)clnUsJwIrnWQbaBwJNrchyYblW9xyLqpWhiMlNScetaYHkJNrGaXuGCCZ(0SgqoaSznEgjCGjhSa3FHvc9AGvJdAW3ZzHZsB5eG9X(fwA4ZDnAjg1WZtdz0WbbqLvVaav)P)rJJA45PbFpNfJbGkyhLYdvY2VOlPbwn475Symaub7OuEOs2(fd1yBH04knUCnAvdhSa77lKgYTikzSfx1q1l(THsamwN0OvnoOHmAW3ZzbpdcbzD0l6sAGvdz04ngvVa92WGdOGkJNrGACeihZ9lSaYXrmc9RXsgBXvnu9aFGyUC4biMaKdvgpJabIPa54M9PznGCayZA8ms4atoybU)cRe6bYXC)clGC2Yztz)clGpqmxomiqmbihQmEgbcetbYbkbKdIEGCm3VWciha2SgpJaYbGX6eqoYOHdczGqULWzPTCIHmq)A45PHmAaWM14zKWblaWBucKq(lNgy1WbbqLvVOwCNFkBKgEEAao9fuuWKdebKdiHCZk9lSaYbZUnRXZin6icudyPHXVS9xcPXFAVgCT614HAWtAGmaeOgz4Ob(BX1(s50ab14pTxJ)K8RHnu9AW1qpbQbMnD0RbpLHdPXFsna5aWMuzneqoidaLYWj5S0woGpqmxomaqmbihQmEgbcetbYXC)clGCY9XFcMteRxeqoGeYnR0VWcihFfrin8Tq8wJnRXwAyLg4TJTsisdRa14NLqA8qnyBrASVgDjn4U)PgxsNHS5cnWFlU2xkNgwbQrlanPFbqAWHRnna54M9PznGCihBLqKyRKv(1aRgMuYDsUBAGvd(EolKMTboGRXs24SADjPodzJaGX6KgxPbgL121aRgh0ae(cd0K(faLqCTPjbAngos8R72w40WZtdz0WbbqLvVOi3azWbuJJAGvda2SgpJeidaLYWj5S0wonWQXbn475Symaub7OuEOs2(fd1yBH04knUCnUmnoObE0ad1y6fLHdosG2k3zPt)ONM1euz8mcuJw1qgni8QVsseOyl0pD3dhucCbSfL4jgtJJAGvd(EolgdavWokLhQKTFrxsdppnKrd(EolgdavWokLhQKTFrxsJJaFGyUC(oqmbihQmEgbcetbYXC)clGCqVnzJXaYbKqUzL(fwa54RisJl9I(tn482KngtdPb6qASzn482KngtJfvT51OlbKJB2NM1aYHVNZcyr)jkjrJJK(fwIUKgy1GVNZc0Bt2ymXq5HqNgpJa(aXC5UCGycqouz8mceiMcKJB2NM1aYHVNZc0BddoGIHASTqACLg4rdSACqd(EolihBLqucbz2igQX2cPHpAGhn880GVNZcYXwjeLy9YgXqn2win8rd8OXrnWQHH(XyjjixA0WhnU82bYXC)clGCCw5iwIVNZa5W3Z5uzneqoO3ggCab(aXCm2oqmbihQmEgbcetbYXC)clGCqVnO(GJaYbKqUzL(fwa54B6nsinAb6s0GNYWH0a)Wca8gPrhTfon(tsd8dlaWBKgoybU)clnEOgUtYDtJnRb(Hfa4nsJfPH5(UXy(1W4H9xJhQbpPHZqpqoUzFAwdihheavw9IAXD(PSrAGvda2SgpJeoybaEJsGeYF50aRgoiKbc5wchSaaVrP)KsiPD2hjgQX2cPXvAGhnWQHmAao9fuuWKdePbwnihBLqKyRKv(1aRgg6hJLKGCPrdF0qwBh4deZXOCaXeGCOY4zeiqmfihZ9lSaYb92Kngdihqc5Mv6xybKJVIin482KngtdU7FQbNNymB0W3mB(1WkqnkOgCEByWb8cn4EsLgfudoVnzJX0yrA0LUqd)WUg2qASLgTvVSrd82XwjePrgoA47TIihsd4OXd1qAGonUKodzJgCpPsdJhcG04YBxJwGUenGJggOK9lasdexBA040qA47TIihsJHAST2cNgWrJfPXwAKzlUZxObMdFsJ)0En6finA8NKgiRH0WblW9xyH0y)2G0aucPrr9FmMgpudoVnzJX0aSpBHtJlvdavWosdF7qLS9FHgCpPsd)WEBa1a9lJPbvGA0L0G7(NAC5T3QHK0idhn(tsdMHEnWXG8gdjaYXn7tZAa58gJQxGEIXSjboB(fuz8mcudSAiJgVXO6fO3ggCafuz8mcudSAW3Zzb6TjBmMyO8qOtJNrAGvJdAW3Zzb5yReIsSEzJyOgBlKg(OHVRbwnihBLqKyReRx2Obwn475SqA2g4aUglzJZQ1LK6mKncagRtACLgyepTRHNNg89CwinBdCaxJLSXz16ssDgYgbaJ1jn85UgyepTRbwnm0pgljb5sJg(OXL3UgEEAacFHbAs)cGsiU20KaTgdhjgQX2cPHpA47A45PH5(fwcd0K(faLqCTPjbAngosSvkZwCNVgh1aRgoiKbc5wcNL2YjgQX2cPHpAix7aFGyogXiqmbihQmEgbcetbYXC)clGCqVnO(GJaYbKqUzL(fwa54RisdoVnO(GJ04sVO)udPb6qAyfOgG9gjnAb6s0G7jvAG)wCTVuonGJg)jPbMDQ(t)Jg89CwJfPHXd7VgpuJSXyAaZznGJg(H92aQHZK0OfOlbih3SpnRbKdFpNfWI(tuYXiBsaw0clrxsdppn475S42wGdbMOgjixAAO6turdUv2KOlPHNNg89Cw4S0worxsdSACqd(EolgdavWokLhQKTFXqn2winUsdCoqrJHpnWqnC0Y04Ggg6hJLKGCPrJR1OLTRXrnAvJwQbgQXBmQErrCtnqyjOY4zeOgy1qgnMErz4GJeOTYDw60p6PznbvgpJa1aRg89CwmgaQGDukpujB)IUKgEEAW3ZzHZsB5ed1yBH04knW5afng(0ad1WrltJdAyOFmwscYLgnUwJw2Ugh1WZtd(EolgdavWokLhQKT)eARCNLo9JEAwt0L0WZtJdAW3ZzXyaOc2rP8qLS9lgQX2cPXvAyUFHLa92K3Hee(ix)P0VnKgy1ajrmw60qpPXvA0Uqw1WZtd(EolgdavWokLhQKTFXqn2winUsdZ9lSeCh7pfe(ix)P0VnKgEEAaWM14zKyXlWKdwG7VWsdSA4GqgiKBj2c5M(B8mkHxDR(EtcKaSosmKb6xdSAq4vFLKiqXwi30FJNrj8QB13BsGeG1rACudSAW3ZzXyaOc2rP8qLS9l6sA45PHmAW3ZzXyaOc2rP8qLS9l6sAGvdz0WbHmqi3smgaQGDukpujB)IHmq)A45PHmA4GaOYQxaGQ)0)OXrn880Wq)ySKeKlnA4JgxE7AGvdYXwjej2kzLFGpqmhJTeiMaKdvgpJabIPa5yUFHfqoO3guFWra5asi3Ss)clGCWKXVgpuJg7gPXFsAWtOxdywdoVnm4aQbVFnqV5UTfon2xJUKg4vFD3y(1ylnSYVg4TJTsisd((RXL0ziB0yr1RHXd7VgpudEsdPb6CeiqoUzFAwdiN3yu9c0BddoGcQmEgbQbwnKrJPxugo4iXVnex4ujWHSg(TaPrqLXZiqnWQXbn475Sa92WGdOOlPHNNgg6hJLKGCPrdF04YBxJJAGvd(EolqVnm4akqV5UPXvA0snWQXbn475SGCSvcrjeKzJOlPHNNg89Cwqo2kHOeRx2i6sACudSAW3ZzH0SnWbCnwYgNvRlj1ziBeamwN04knWigODnWQXbnCqideYTeolTLtmuJTfsdF0qU21WZtdz0aGnRXZiHdwaG3OeiH8xonWQHdcGkRErT4o)u2inoc8bI5yuwbIja5qLXZiqGykqoqjGCq0dKJ5(fwa5aWM14zeqoamwNaYHCSvcrITsSEzJgyOg(UgxRH5(fwc0BtEhsq4JC9Ns)2qA0QgYOb5yReIeBLy9YgnWqnoObguJw14ngvVab7SemN(tkLHdHEbvgpJa1ad1OLACuJR1WC)clb3X(tbHpY1Fk9BdPrRA0UqwXJgxRbsIyS0PHEsJw1ODbE0ad14ngvVOSVpekXBmRCKGkJNrGa5asi3Ss)clGCWB0Vn2tinoHC1OP7o1OfOlrdBinWzBrGAirJgiYblqGCaytQSgcihdjDj0WHCaFGyogXdqmbihQmEgbcetbYXC)clGCqVnO(GJaYbKqUzL(fwa54B6nsAW5Tb1hCKgBPHPbgOve50GdKzJg4TJTsi6cnaHvBEny0RX(AinqNgxsNHSrJd)P9ASinoTcKrGAW7xdA)tA04pjn482Kngtd2wKgWrJ)K0OfOlXNlVDnyBrAKHJgCEBq9bhD8cnaHvBEnGaOH7SpPHvACPx0FQH0aDAyfOgm614pjnmEiasd2wKgNwbYin482WGdiqoUzFAwdihz0y6fLHdos8BdXfovcCiRHFlqAeuz8mcudSACqd(EolKMTboGRXs24SADjPodzJaGX6KgxPbgXaTRHNNg89CwinBdCaxJLSXz16ssDgYgbaJ1jnUsdmIN21aRgVXO6fONymBsGZMFbvgpJa14Ogy14GgKJTsisSvcbz2Obwnm0pgljb5sJgTQbaBwJNrcdjDj0WHCAGHAW3Zzb5yReIsiiZgXqn2winAvdq4lY9XFcMteRxK4x3nuAOgBlnWqnWOapA4Jg(E7A45Pb5yReIeBLy9YgnWQHH(XyjjixA0OvnayZA8msyiPlHgoKtdmud(EolihBLquI1lBed1yBH0OvnaHVi3h)jyorSErIFD3qPHAST0ad1aJc8OHpAC5TRXrnWQHmAW3ZzbSO)eLKOXrs)clrxsdSAiJgVXO6fO3ggCafuz8mcudSACqdheYaHClHZsB5ed1yBH0WhnWaA45Pbc2z8Bbk(ZzzSeIOB0iOY4zeOgy1GVNZI)CwglHi6gnc0BUBACLgTSLACzACqJPxugo4ibARCNLo9JEAwtqLXZiqnWqnWJgh1aRg5f35NgQX2cPHpAix7TRbwnYlUZpnuJTfsJR0aJT3UgEEAao9fuuWKdePXrnWQXbnCqideYTe32cCiWesAN9rIHASTqA4Jgyan880qgnCqauz1lU5FwR04iWhiMJrmiqmbihQmEgbcetbYXC)clGCkIBQbclGCajKBwPFHfqo(kI04sdclKgBPrB1lB0aVDSvcrAyfOgidaPXLYgl3QVTZyACPbHLgz4Ob(BX1(s50WkqnUuSf4qGAG3nsqU00q1dKJB2NM1aY5Gg89Cwqo2kHOeRx2igQX2cPHpAq4JC9Ns)2qA45PXbnCN2GJqACxdmQbwngYDAdok9BdPXvAGhnoQHNNgUtBWrinURrl14Ogy1WKsUtYDtdSAaWM14zKazaOugojNL2Yb8bI5yedaetaYHkJNrGaXuGCCZ(0Sgqoh0GVNZcYXwjeLy9YgXqn2win8rdcFKR)u63gsdSAiJgoiaQS6f38pRvA45PXbn475S42wGdbMOgjixAAO6turdUv2KOlPbwnCqauz1lU5FwR04OgEEACqd3Pn4iKg31aJAGvJHCN2GJs)2qACLg4rJJA45PH70gCesJ7A0sn880GVNZcNL2Yj6sACudSAysj3j5UPbwnayZA8msGmaukdNKZsB50aRgh0GVNZIXaqfSJs5Hkz7xmuJTfsJR04Gg4rJltdmQbgQX0lkdhCKaTvUZsN(rpnRjOY4zeOgh1aRg89CwmgaQGDukpujB)IUKgEEAiJg89CwmgaQGDukpujB)IUKghbYXC)clGConwo1aHfWhiMJrFhiMaKdvgpJabIPa54M9PznGCoObFpNfKJTsikX6LnIHASTqA4Jge(ix)P0VnKgy1qgnCqauz1lU5FwR0WZtJdAW3ZzXTTahcmrnsqU00q1NOIgCRSjrxsdSA4GaOYQxCZ)SwPXrn8804GgUtBWrinURbg1aRgd5oTbhL(TH04knWJgh1WZtd3Pn4iKg31OLA45PbFpNfolTLt0L04Ogy1WKsUtYDtdSAaWM14zKazaOugojNL2YPbwnoObFpNfJbGkyhLYdvY2VyOgBlKgxPbE0aRg89CwmgaQGDukpujB)IUKgy1qgnMErz4GJeOTYDw60p6PznbvgpJa1WZtdz0GVNZIXaqfSJs5Hkz7x0L04iqoM7xybKtUZyPgiSa(aXCmE5aXeGCOY4zeiqmfihqc5Mv6xybKJVIinWSG4TgWsdhiqoM7xybKdxBMfojyorSEraFGyElBhiMaKdvgpJabIPa5yUFHfqoO3M8oeqoGeYnR0VWcihFfrAW5TjVdPXd1qAGon4az2ObE7yReIUqd83IR9LYPXPH0GriKg)2qA8NwPHPbM1y)Pge(ix)jnyu(1aoAalMFnAREzJg4TJTsisJfPrxcih3SpnRbKd5yReIeBLy9YgnWQHmAW3ZzXyaOc2rP8qLS9l6sA45Pb5yReIeiiZMur471WZtdYXwjejSYFQi89A45PXbn475SGRnZcNemNiwVirxsdppnqseJLon0tACLgTlKv8ObwnKrdheavw9cau9N(hn880ajrmw60qpPXvA0Uqw1aRgoiaQS6faO6p9pACudSAW3Zzb5yReIsSEzJOlPHNNgh0GVNZcNL2YjgQX2cPXvAyUFHLG7y)PGWh56pL(TH0aRg89Cw4S0worxsJJaFGyElLdiMaKdvgpJabIPa5asi3Ss)clGC8vePbM1y)PgW)KgUlI0G756o1yrASLgCGmB0aVDSvcrxOb(BX1(s50aoA8qnKgOtJ2Qx2ObE7yReIaYXC)clGC4o2Fc8bI5TeJaXeGCOY4zeiqmfihqc5Mv6xybKJV1yS)C6a5yUFHfqotVsM7xyLyl6bYHTOpvwdbKt2yS)C6aFGpqosd5Gn82detaI5YbetaYXC)clGCUTf4qGjK0o7JaYHkJNrGaXuGpqmhJaXeGCOY4zeiqmfihOeqoi6bYXC)clGCayZA8mcihagRta50oqoGeYnR0VWcihm5K0aGnRXZinwKgi614HA0UgC3)uJcQb6TxdyPrhrA8Zw3OhDHgYPb3tQ04pjnY7GEnGfPXI0awA0r0fAGrn2Sg)jPbICWcuJfPHvGA0sn2Sg8W)udBiGCaytQSgcihyL6ik9Zw3Oh4deZBjqmbihQmEgbcetbYbkbKJbccKJ5(fwa5aWM14zeqoamwNaYroGCCZ(0Sgqo)S1n6fVCItdL6ikX3ZznWQXpBDJEXlNWbHmqi3sa2h7xyPbwnKrJF26g9IxoXIepSHsWCQbwOFGDuYbl0pD3VWcbKdaBsL1qa5aRuhrPF26g9aFGyUScetaYHkJNrGaXuGCGsa5yGGa5yUFHfqoaSznEgbKdaJ1jGCWiqoUzFAwdiNF26g9IhJItdL6ikX3ZznWQXpBDJEXJrHdczGqULaSp2VWsdSAiJg)S1n6fpgfls8WgkbZPgyH(b2rjhSq)0D)cleqoaSjvwdbKdSsDeL(zRB0d8bI54biMaKdvgpJabIPa5aLaYXabbYXC)clGCayZA8mciha2KkRHaYbwPoIs)S1n6bYXn7tZAa5q4vFLKiqXwi30FJNrj8QB13BsGeG1rA45PbHx9vsIafuJK)HmwcoGLvosdppni8QVsseOab7mg9)w4stN3pqoGeYnR0VWcihm5KqKg)S1n6rAydPrbFnS(dBSFDgJ5xdq6j3tGAyinGLgDePb6TxJF26g9iHgAWHEnayZA8msJhQHSQHH04pj)AymeuJIiqnqsKBnMgNwbY2cNaihagRta5iRaFGyogeiMaKJ5(fwa50aH1TTsz40aKdvgpJabIPaFGyogaiMaKdvgpJabIPa5yUFHfqoCh7pbYXn7tZAa5CqdYXwjejy9YMur471WZtdYXwjej2kHGmB0WZtdYXwjej2kXd)tn880GCSvcrcR8NkcFVghbYHTfLCGa5ix7aFGpWhiha0GwybeZXy7yuU29DmE5a5W1MAlCiGCWSAXLkM7ly(LsYsn0atojn2gj48AKHJgTbkrfnTrJHWR(oeOgiydPH1FyJ9eOgUtRWriHkFBTfPbgLLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OXb5W3rHkFBTfPrlLLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OXb5W3rHkVkpMvlUuXCFbZVuswQHgyYjPX2ibNxJmC0OnGu26SVnAmeE13Ha1abBinS(dBSNa1WDAfocju5BRTinWGYsnWpSaqZtGAWzBWVgi)1B4tdmJgpuJ2QBAaUaw0clnGs0ypC04W1h14GC47OqLVT2I0adkl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2AlsdmGSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTin8DzPg4hwaO5jqn4Sn4xdK)6n8PbMrJhQrB1nnaxalAHLgqjAShoAC46JACaJ47OqLVT2I0W3LLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OXb5W3rHkFBTfPXLll1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2AlsJlxwQb(HfaAEcuJ28Zw3OxiNqw0gnEOgT5NTUrV4LtilAJghWi(oku5BRTinUCzPg4hwaO5jqnAZpBDJEbgfYI2OXd1On)S1n6fpgfYI2OXbmIVJcv(2Alsd5AxwQb(HfaAEcuJ2m9IYWbhjKfTrJhQrBMErz4GJeYcbvgpJaBJghKdFhfQ8T1wKgYjNSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinKdJYsnWpSaqZtGA0MPxugo4iHSOnA8qnAZ0lkdhCKqwiOY4zeyB04GC47OqLVT2I0qUwkl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2Alsd5WJSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinKddkl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdyeFhfQ8T1wKgYHbLLAGFybGMNa1On)S1n6fYjKfTrJhQrB(zRB0lE5eYI2OXbmIVJcv(2Alsd5WGYsnWpSaqZtGA0MF26g9cmkKfTrJhQrB(zRB0lEmkKfTrJdYHVJcv(2Alsd5WaYsnWpSaqZtGA0MPxugo4iHSOnA8qnAZ0lkdhCKqwiOY4zeyB04agX3rHkFBTfPHCyazPg4hwaO5jqnAZpBDJEHCczrB04HA0MF26g9IxoHSOnACqo8DuOY3wBrAihgqwQb(HfaAEcuJ28Zw3OxGrHSOnA8qnAZpBDJEXJrHSOnACaJ47OqLxLhZQfxQyUVG5xkjl1qdm5K0yBKGZRrgoA0gPHCWgE7BJgdHx9DiqnqWgsdR)Wg7jqnCNwHJqcv(2AlsJwkl1a)WcanpbQrB(zRB0lKtilAJgpuJ28Zw3Ox8YjKfTrJdTeFhfQ8T1wKgYQSud8dla08eOgT5NTUrVaJczrB04HA0MF26g9IhJczrB04qlX3rHkVkpMvlUuXCFbZVuswQHgyYjPX2ibNxJmC0OngKAJgdHx9DiqnqWgsdR)Wg7jqnCNwHJqcv(2Alsd5KLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OH9AG3x6TLghKdFhfQ8T1wKgTuwQb(HfaAEcuJ2m9IYWbhjKfTrJhQrBMErz4GJeYcbvgpJaBJghKdFhfQ8T1wKgyazPg4hwaO5jqn4Sn4xdK)6n8PbMbZOXd1OT6MgnqWoRJ0akrJ9WrJdyMJACqo8DuOY3wBrAGbKLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OXbmIVJcv(2AlsdFxwQb(HfaAEcudoBd(1a5VEdFAGzWmA8qnARUPrdeSZ6inGs0ypC04aM5OghKdFhfQ8T1wKg(USud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinUCzPg4hwaO5jqnAZ0lkdhCKqw0gnEOgTz6fLHdosileuz8mcSnACqo8DuOY3wBrAix7YsnWpSaqZtGAWzBWVgi)1B4tdmJgpuJ2QBAaUaw0clnGs0ypC04W1h14agX3rHkFBTfPHCTuwQb(HfaAEcudoBd(1a5VEdFAGz04HA0wDtdWfWIwyPbuIg7HJghU(OghKdFhfQ8T1wKgySDzPg4hwaO5jqnAZ0lkdhCKqw0gnEOgTz6fLHdosileuz8mcSnACqo8DuOY3wBrAGrmkl1a)WcanpbQbNTb)AG8xVHpnWmA8qnARUPb4cyrlS0akrJ9WrJdxFuJdYHVJcv(2AlsdmkRYsnWpSaqZtGAWzBWVgi)1B4tdmJgpuJ2QBAaUaw0clnGs0ypC04W1h14agX3rHkFBTfPbgLvzPg4hwaO5jqnAZ0lkdhCKqw0gnEOgTz6fLHdosileuz8mcSnACqo8DuOY3wBrAGrmOSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinWigqwQb(HfaAEcuJ2m9IYWbhjKfTrJhQrBMErz4GJeYcbvgpJaBJghKdFhfQ8T1wKgy8YLLAGFybGMNa1GZ2GFnq(R3WNgygnEOgTv30aCbSOfwAaLOXE4OXHRpQXbmIVJcv(2AlsJw2USud8dla08eOgC2g8RbYF9g(0aZOXd1OT6MgGlGfTWsdOen2dhnoC9rnoih(oku5v5XSAXLkM7ly(LsYsn0atojn2gj48AKHJgTjBm2Fo92OXq4vFhcudeSH0W6pSXEcud3Pv4iKqLVT2I0aJYsnWpSaqZtGAWzBWVgi)1B4tdmJgpuJ2QBAaUaw0clnGs0ypC04W1h14GC47OqLxLhZQfxQyUVG5xkjl1qdm5K0yBKGZRrgoA0g03gngcV67qGAGGnKgw)Hn2tGA4oTchHeQ8T1wKgYjl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2AlsJwkl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2Alsd5KtwQb(HfaAEcudoBd(1a5VEdFAGzWmA8qnARUPrdeSZ6inGs0ypC04aM5OghKdFhfQ8T1wKgYjNSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinKdJYsnWpSaqZtGAWzBWVgi)1B4tdmdMrJhQrB1nnAGGDwhPbuIg7HJghWmh14GC47OqLVT2I0qomkl1a)WcanpbQrBMErz4GJeYI2OXd1OntVOmCWrczHGkJNrGTrJdYHVJcv(2Alsd5WaYsnWpSaqZtGA0MPxugo4iHSOnA8qnAZ0lkdhCKqwiOY4zeyB04GC47OqLVT2I0aJyuwQb(HfaAEcudoBd(1a5VEdFAGz04HA0wDtdWfWIwyPbuIg7HJghU(OghWi(oku5BRTinWigLLAGFybGMNa1OntVOmCWrczrB04HA0MPxugo4iHSqqLXZiW2OXb5W3rHkFBTfPbgBPSud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5BRTinWOSkl1a)WcanpbQbNTb)AG8xVHpnWmA8qnARUPb4cyrlS0akrJ9WrJdxFuJdTeFhfQ8T1wKgyepYsnWpSaqZtGA0MPxugo4iHSOnA8qnAZ0lkdhCKqwiOY4zeyB04agX3rHkFBTfPbgXaYsnWpSaqZtGA0MPxugo4iHSOnA8qnAZ0lkdhCKqwiOY4zeyB04GC47OqLVT2I0aJ(USud8dla08eOgTz6fLHdosilAJgpuJ2m9IYWbhjKfcQmEgb2gnoih(oku5v5XSAXLkM7ly(LsYsn0atojn2gj48AKHJgTHhAFB0yi8QVdbQbc2qAy9h2ypbQH70kCesOY3wBrAihgqwQb(HfaAEcudoBd(1a5VEdFAGz04HA0wDtdWfWIwyPbuIg7HJghU(OghAj(oku5BRTinKZ3LLAGFybGMNa1GZ2GFnq(R3WNgygnEOgTv30aCbSOfwAaLOXE4OXHRpQXb5W3rHkVkVV0ibNNa1adOH5(fwAWw0JeQ8a5GKihqmxU2XiqosdmVmciN2UT1atnMvosdFZ0xqv(2UT1Gdj9udpnAihg8cnWy7yuovEv(2UT1a)NwHJqYsv(2UT14Y0OfGGeOgCGmB0atjRrOY32TTgxMg4)0kCeOgVn4OpTznCgIqA8qnC(Dmk92GJEKqLVTBBnUmnUuPgiacuJEvKJqiB8RbaBwJNrinoScsCHgsdbiHEBq9bhPXL5JgsdbqGEBq9bhDuOY32TTgxMgTaaCb1qAiNH(TWPbM1y)PgBwJ9BdsJ)K0G7alCAG3o2kHiHkFB32ACzACPz3inWpSaaVrA8NKgCK2zFKgMgS9FgPrdCinYmcFlpJ04WM1WpSRXPbwT514CFn2xd020zVveSJy(1G7(NAGPx6Tat0OvnWpXi0VgtJwWwCvdv)fASFBa1aDBLoku5B72wJltJln7gPrde9A0M8I78td1yBHAJgihv2SqKgMKeZVgpudEicPrEXD(inGfZVqLVTBBnUmnWKHSxdmb2qAaZAGPm7udmLzNAGPm7uddPHPbsICRX04NTUrVqLVTBBnUmnU0LOIgnoScsCHgywJ9NxObM1y)5fAW5TjVdDuJgdK0OboKgdHw2s1RXd1GSHT0OHd2WB)LHEBEHkVkFB32A0IQGV9eOgyQXSYrA0IlPT0WzLg8KgzyVa1WEno)xcjlV(AEJzLJUm024e42)SZlw41yQXSYrxgNTb)x3ako)ggMTZlJUZBmRCK4X3RYRYBUFHfsinKd2WB)9BBboeycjTZ(iv(2wdm5K0aGnRXZinwKgi614HA0UgC3)uJcQb6TxdyPrhrA8Zw3OhDHgYPb3tQ04pjnY7GEnGfPXI0awA0r0fAGrn2Sg)jPbICWcuJfPHvGA0sn2Sg8W)udBivEZ9lSqcPHCWgE7B9(1aSznEgDrzn0DyL6ik9Zw3O)cagRt3BxL3C)clKqAihSH3(wVFnaBwJNrxuwdDhwPoIs)S1n6VakD3abVaGX60D5UyZ3)zRB0lKtCAOuhrj(EoJ9NTUrVqoHdczGqULaSp2VWcRm)S1n6fYjwK4HnucMtnWc9dSJsoyH(P7(fwivEZ9lSqcPHCWgE7B9(1aSznEgDrzn0DyL6ik9Zw3O)cO0Dde8cagRt3X4fB((pBDJEbgfNgk1ruIVNZy)zRB0lWOWbHmqi3sa2h7xyHvMF26g9cmkwK4HnucMtnWc9dSJsoyH(P7(fwiv(2wdm5KqKg)S1n6rAydPrbFnS(dBSFDgJ5xdq6j3tGAyinGLgDePb6TxJF26g9iHgAWHEnayZA8msJhQHSQHH04pj)AymeuJIiqnqsKBnMgNwbY2cNqL3C)clKqAihSH3(wVFnaBwJNrxuwdDhwPoIs)S1n6VakD3abVaGX60Dz9InFNWR(kjrGITqUP)gpJs4v3QV3KajaRJ88i8QVsseOGAK8pKXsWbSSYrEEeE1xjjcuGGDgJ(FlCPPZ7xL3C)clKqAihSH3(wVFDdew32kLHtJkV5(fwiH0qoydV9TE)AUJ9NxW2IsoW7Y1(fB((bYXwjejy9YMur4798ihBLqKyRecYSXZJCSvcrITs8W)0ZJCSvcrcR8NkcF)rvEv(2wJlziNHEnWOgywJ9NAyfOgMgCEBq9bhPbS0GdMOb39p1aZxCNVg(wJ0WkqnWuylWenGJgCEBY7qAa)tA4UisL3C)clKakrfnTE)AUJ9NxS57hihBLqKG1lBsfHV3ZJCSvcrITsiiZgppYXwjej2kXd)tppYXwjejSYFQi89hXkneaHCcUJ9NyLrAiacmk4o2FQYBUFHfsaLOIMwVFn6TjVdDbBlk5aVJNl28DzMErz4GJe8gZkhLG5KXyP)ClCippzCqauz1lQf35NYg55jdsIyS0Bdo6rc0Bt2yS7Y55jZBmQErzFFiuI3yw5ibvgpJa98oqo2kHibcYSjve(EppYXwjej2kX6LnEEKJTsisSvIh(NEEKJTsisyL)ur47pQYBUFHfsaLOIMwVFn6Tb1hC0fSTOKd8oEUyZ3NErz4GJe8gZkhLG5KXyP)ClCiSoiaQS6f1I78tzJWIKigl92GJEKa92Kng7UCQ8Q8TDBRbEJpY1Fcudcan(143gsJ)K0WCpC0yrAyaSLz8msOYBUFHf6ocYSjXtwJkV5(fwOwVFTZySK5(fwj2I(lkRHUdLOIMl289FBORoGrm0C)clb3X(tHZqF63gQvZ9lSeO3M8oKWzOp9BdDuLVT1Gd9inAbeV1awA0Yw1G7(NW(Rb4S5xdRa1G7(NAW5THbhqnScudm2QgW)KgUlIu5n3VWc169RbyZA8m6IYAO7lkzq6cagRt3rseJLEBWrpsGEBYgJ5JCypiZBmQEb6THbhqbvgpJa98EJr1lqpXy2KaNn)cQmEgbE0Zdjrmw6Tbh9ib6TjBmMpyuLVT1Gd9inCmYaqAW9Kkn482K3H0WzLgN7RbgBvJ3gC0J0G756o1yrAmeJay1RrgoA8NKg4TJTsisJhQbpPH0qzAgcudRa1G756o1iVmgnA8qnCg6v5n3VWc169RbyZA8m6IYAO7lk5yKbGUaGX60DKeXyP3gC0JeO3M8oKpYPY32AGz3M14zKg)P9A4oj3nKgBwd)WUg2qASLgMg4CGA8qnmaWfuJ)K0aTF3(fwAW9KgsdtJF26g9AqVtJfPrhrGASLg80ZLOsdNHEKkV5(fwOwVFnaBwJNrxuwdDFReoh4famwNUlneardew5DippPHaiq9kVd55jneab6Tb1hCKNN0qaeO3MSXyEEsdbqK7J)emNiwVipp(EolCwAlNyOgBl0D(EolCwAlNaSp2VWYZtAiaIXaqfSJs5Hkz73ZdGnRXZiXIsgKu5BBn8vePbMsdIMBBHtdU7FQb(BX1(s50aoAy5NgnWpSaaVrASLg4Vfx7lLtL3C)cluR3VMNgen32c3fB((HdY4GaOYQxulUZpLnYZtgheYaHClHdwaG3O0FsjK0o7JeDPJy575SWzPTCIHASTq(ihEWY3ZzXyaOc2rP8qLS9lgQX2cDLSIvgheavw9cau9N(hppheavw9cau9N(hS89Cw4S0worxclFpNfJbGkyhLYdvY2VOlH9aFpNfJbGkyhLYdvY2VyOgBl0vYj3LHhmC6fLHdosG2k3zPt)ONM188475SWzPTCIHASTqxjNCEEYHzqseJLon0txjNap454rSaSznEgj2kHZbQY32ACjWxdU7FQHPb(BX1(s504pTxJfvT51W04s6mKnAinqNgWrdUNuPXFsAKxCNVglsdJh2FnEOgubQYBUFHfQ17xlb)fwxS5789Cw4S0woXqn2wiFKdpypiZ0lkdhCKaTvUZsN(rpnR55X3ZzXyaOc2rP8qLS9lgQX2cDLCyGldJyiFpNf8mieK1rVOlHLVNZIXaqfSJs5Hkz7x0Lo65XdriS5f35NgQX2cDfgXJkFBRb(nMRZSNqAW9K(tA0OJ2cNg4hwaG3inkixn4UmMggJb5QHFyxJhQb6xgtdNHEn(tsdK1qAynWE9AaZAGFybaEJAf)T4AFPCA4m0Ju5n3VWc169RbyZA8m6IYAO7oybaEJsGeYF5UaGX60DhTSdhYlUZpnuJTf6YKdpxMdczGqULWzPTCIHASTqhXmY57TF8UJw2Hd5f35NgQX2cDzYHNlZbHmqi3s4Gfa4nk9NucjTZ(ibyFSFH1L5GqgiKBjCWca8gL(tkHK2zFKyOgBl0rmJC(E7hXkZylyIaq1lmqqKGW3IEKNNdczGqULWzPTCIHASTq(S1tJeKzpbMYlUZpnuJTfYZB6fLHdos4igH(1yjK0o7JW6GqgiKBjCwAlNyOgBlKpTSDppheYaHClHdwaG3O0FsjK0o7Jed1yBH8zRNgjiZEcmLxCNFAOgBl0Ljx7EEY4GaOYQxulUZpLnsLVT1WxreOgpudqIz(14pjn6idhPbmRb(BX1(s50G7jvA0rBHtdqyNNrAaln6isdRa1qAiau9A0rgosdUNuPHvAyGGAqaO61yrAy8W(RXd1aCjvEZ9lSqTE)Aa2SgpJUOSg6Udm5Gf4(lSUaGX609d5f35NgQX2c5JC4XZBSfmraO6fgiisSLp4P9JypC4aHx9vsIafuJK)HmwcoGLvoc7bheYaHClb1i5FiJLGdyzLJed1yBHUsomy7EEoiaQS6faO6p9pyDqideYTeuJK)HmwcoGLvosmuJTf6k5WGyGwpiNCy40lkdhCKaTvUZsN(rpnRD8iwzCqideYTeuJK)HmwcoGLvosmKb6)ONhHx9vsIafiyNXO)3cxA68(XEqgheavw9IAXD(PSrEEoiKbc5wceSZy0)BHlnDE)PwkR4X3BxoXqn2wORKtoz9ON3bheYaHClbpniAUTfoXqgOFppzgZrIFGm2rShoq4vFLKiqXwi30FJNrj8QB13BsGeG1ryp4GqgiKBj2c5M(B8mkHxDR(EtcKaSosmKb63ZZC)clXwi30FJNrj8QB13BsGeG1rcWfz8mc84rpVdeE1xjjcuGonqixcmbh(emNE40q1J1bHmqi3s8WPHQNatBHwCNFQL4bpTeJYjgQX2cD0Z7Wba2SgpJeWk1ru6NTUr)D588ayZA8msaRuhrPF26g93B5rSh(zRB0lKtmKb6p5GqgiKB559Zw3OxiNWbHmqi3smuJTfYNTEAKGm7jWuEXD(PHASTqxMCTF0ZdGnRXZibSsDeL(zRB0FhJyp8Zw3OxGrXqgO)KdczGqULN3pBDJEbgfoiKbc5wIHASTq(S1tJeKzpbMYlUZpnuJTf6YKR9JEEaSznEgjGvQJO0pBDJ(7TF84rppheavw9IB(N1QJEE8qecBEXD(PHASTqxX3ZzHZsB5eG9X(fwQ8TTgy2TznEgPrhrGA8qnajM5xdR8RXpBDJEKgwbQHdePb3tQ0GRT)w40idhnSsd8UlDcN10qAGovEZ9lSqTE)Aa2SgpJUOSg6(FolJLqeDJMexB)laySoDxgeSZ43cu8NZYyjer3OrqLXZiqpV8I78td1yBH8bJT3UNhpeHWMxCNFAOgBl0vyepTEqwB)Y475S4pNLXsiIUrJa9M7ggIXJEE89Cw8NZYyjer3OrGEZDZNw67x2HPxugo4ibARCNLo9JEAwddXZrv(2wdFfrAG3ns(hYyACPpGLvosdm2oICin4PmCinmnWFlU2xkNgDeju5n3VWc169R7ikTp1Crzn0DQrY)qglbhWYkhDXMV7GqgiKBjCwAlNyOgBl0vySDSoiKbc5wchSaaVrP)KsiPD2hjgQX2cDfgBh7ba2SgpJe)5Smwcr0nAsCT998475S4pNLXsiIUrJa9M7MpTS9wpm9IYWbhjqBL7S0PF0tZAyig84rSaSznEgj2kHZb65XdriS5f35NgQX2cDvlXaQ8TTg(kI0GdSZy0VfonUu78(1adIihsdEkdhsdtd83IR9LYPrhrcvEZ9lSqTE)6oIs7tnxuwdDhb7mg9)w4stN3)fB((bheYaHClHZsB5ed1yBHUcdIvgheavw9cau9N(hSY4GaOYQxulUZpLnYZZbbqLvVOwCNFkBewheYaHClHdwaG3O0FsjK0o7Jed1yBHUcdI9aaBwJNrchSaaVrjqc5VCEEoiKbc5wcNL2YjgQX2cDfg8ONNdcGkREbaQ(t)d2dYm9IYWbhjqBL7S0PF0tZAyDqideYTeolTLtmuJTf6kmONhFpNfJbGkyhLYdvY2VyOgBl0vYjRTEapyiHx9vsIafBH(P7E4GsGlGTOepXyhXY3ZzXyaOc2rP8qLS9l6sh984Hie28I78td1yBHUcJ4XZJWR(kjrGcQrY)qglbhWYkhH1bHmqi3sqns(hYyj4aww5iXqn2wiFWy7hXcWM14zKyReohiwzi8QVsseOylKB6VXZOeE1T67njqcW6ippheYaHClXwi30FJNrj8QB13BsGeG1rIHASTq(GX2984Hie28I78td1yBHUcJTRY32A0cgxZpsJoI0WxWSLVrdU7FQb(BX1(s5u5n3VWc169RbyZA8m6IYAO7lEbMCWcC)fwxaWyD6oFpNfolTLtmuJTfYh5Wd2dYm9IYWbhjqBL7S0PF0tZAEE89CwmgaQGDukpujB)IHASTqxDxomkWyRhAjgY3ZzbpdcbzD0l6shB9GVFz4bd575SGNbHGSo6fDPJyiHx9vsIafBH(P7E4GsGlGTOepXyy575Symaub7OuEOs2(fDPJEE8qecBEXD(PHASTqxHr845r4vFLKiqb1i5FiJLGdyzLJW6GqgiKBjOgj)dzSeCalRCKyOgBlKkV5(fwOwVFDhrP9PMlkRHUVfYn934zucV6w99MeibyD0fB(oaBwJNrIfVatoybU)clSaSznEgj2kHZbQY32A4RisJzXD(AWtz4qA4arQ8M7xyHA9(1DeL2NAUOSg6o60aHCjWeC4tWC6Htdv)fB((bheYaHClHZsB5edzG(XkJdcGkRErT4o)u2iSaSznEgj(ZzzSeIOB0K4A7J9GdczGqULGNgen32cNyid0VNNmJ5iXpqg7ONNdcGkRErT4o)u2iSoiKbc5wchSaaVrP)KsiPD2hjgYa9J9aaBwJNrchSaaVrjqc5VCEEoiKbc5wcNL2YjgYa9F8iwq4lq9kVdj(1DBlCypacFb6jgZMuMzdj(1DBlCEEY8gJQxGEIXSjLz2qcQmEgb65HKigl92GJEKa92K3H8PLhXccFrdew5DiXVUBBHd7ba2SgpJelkzqYZB6fLHdosWBmRCucMtgJL(ZTWH88m0pgljb5sJp3V8298ayZA8ms4Gfa4nkbsi)LZZJVNZcEgecY6Ox0LoIvgcV6RKebk2c5M(B8mkHxDR(EtcKaSoYZJWR(kjrGITqUP)gpJs4v3QV3KajaRJW6GqgiKBj2c5M(B8mkHxDR(EtcKaSosmuJTfYNw2owz475SWzPTCIUKNhpeHWMxCNFAOgBl0vYA7Q8TTgyY5I0yrAyAm2FsJgeZ4HJ9KgCn)A8qnASBKggJPbS0OJinqV9A8Zw3OhPXd1GN0GTfbQrxsdU7FQb(BX1(s50WkqnWpSaaVrAyfOgDePXFsAGXcuded(AalnCGASzn4H)Pg)S1n6rAydPbS0OJinqV9A8Zw3OhPYBUFHfQ17x3ruAFQbDbIbF09F26g9YDXMVFaGnRXZibSsDeL(zRB0lZD5WkZpBDJEbgfdzG(toiKbc5wEEhayZA8msaRuhrPF26g93LZZdGnRXZibSsDeL(zRB0FVLhXEGVNZcNL2Yj6sypiJdcGkREbaQ(t)JNhFpNfJbGkyhLYdvY2VyOgBluRhWdgo9IYWbhjqBL7S0PF0tZAhV6(pBDJEHCc(EoNa7J9lSWY3ZzXyaOc2rP8qLS9l6sEE89CwmgaQGDukpujB)j0w5olD6h90SMOlD0ZZbHmqi3s4S0woXqn2wOwXOp)S1n6fYjCqideYTeG9X(fwyLHVNZcNL2Yj6sypiJdcGkRErT4o)u2ippzayZA8ms4Gfa4nkbsi)L7iwzCqauz1lU5FwR88Cqauz1lQf35NYgHfGnRXZiHdwaG3OeiH8xoSoiKbc5wchSaaVrP)KsiPD2hj6syLXbHmqi3s4S0worxc7Hd89Cwqo2kHOeRx2igQX2c5JCT75X3Zzb5yReIsiiZgXqn2wiFKR9JyLz6fLHdosWBmRCucMtgJL(ZTWH88oW3ZzbVXSYrjyozmw6p3chkv23hsGEZD7oE88475SG3yw5OemNmgl9NBHdLSXzfjqV5UD33pE0ZJVNZIBBboeyIAKGCPPHQprfn4wztIU0rppEicHnV4o)0qn2wORWy7EEaSznEgjGvQJO0pBDJ(7TFelaBwJNrITs4CGQ8M7xyHA9(1DeL2NAqxGyWhD)NTUrpgVyZ3paWM14zKawPoIs)S1n6L5ogXkZpBDJEHCIHmq)jheYaHClppa2SgpJeWk1ru6NTUr)DmI9aFpNfolTLt0LWEqgheavw9cau9N(hpp(EolgdavWokLhQKTFXqn2wOwpGhmC6fLHdosG2k3zPt)ONM1oE19F26g9cmk475CcSp2VWclFpNfJbGkyhLYdvY2VOl55X3ZzXyaOc2rP8qLS9NqBL7S0PF0tZAIU0rppheYaHClHZsB5ed1yBHAfJ(8Zw3OxGrHdczGqULaSp2VWcRm89Cw4S0worxc7bzCqauz1lQf35NYg55jdaBwJNrchSaaVrjqc5VChXkJdcGkREXn)ZAf2dYW3ZzHZsB5eDjppzCqauz1laq1F6Fo655GaOYQxulUZpLnclaBwJNrchSaaVrjqc5VCyDqideYTeoybaEJs)jLqs7Sps0LWkJdczGqULWzPTCIUe2dh475SGCSvcrjwVSrmuJTfYh5A3ZJVNZcYXwjeLqqMnIHASTq(ix7hXkZ0lkdhCKG3yw5OemNmgl9NBHd55DGVNZcEJzLJsWCYyS0FUfouQSVpKa9M72D845X3ZzbVXSYrjyozmw6p3chkzJZksGEZD7UVF84rpp(EolUTf4qGjQrcYLMgQ(ev0GBLnj6sEE8qecBEXD(PHASTqxHX298ayZA8msaRuhrPF26g93B)iwa2SgpJeBLW5av5BBn8veH0WymnG)jnAaln6isJ9PgKgWsdhOkV5(fwOwVFDhrP9PgKkFBRHVHCliPH5(fwAWw0RbVHiqnGLgO972VW6AgHBrQ8M7xyHA9(1tVsM7xyLyl6VOSg6UbPlq)SU)UCxS57aSznEgjwuYGKkV5(fwOwVF90RK5(fwj2I(lkRHUZdT)c0pR7Vl3fB((0lkdhCKG3yw5OemNmgl9NBHdji8QVsseOkV5(fwOwVF90RK5(fwj2I(lkRHUJEvEv(2wd8BmxNzpH0G7j9N0OXFsA4BgYAC27oPrd(EoRb3LX0iBmMgWCwdU7FULg)jPrr471WzOxL3C)clKWG0Da2SgpJUOSg6o4qwtI7YyPSXyjyoFbaJ1P7h475S43gIlCQe4qwd)wG0igQX2cDfohOOXWxRTlKZZJVNZIFBiUWPsGdzn8BbsJyOgBl0vM7xyjqVn5DibHpY1Fk9Bd1A7c5WEGCSvcrITsSEzJNh5yReIeiiZMur4798ihBLqKWk)PIW3F8iw(Eol(TH4cNkboK1WVfinIUe2Pxugo4iXVnex4ujWHSg(TaPrLVT1a)gZ1z2tin4Es)jnAW5Tb1hCKglsdUW5p1WzOFlCAabqJgCEBY7qASLgTvVSrd82XwjePYBUFHfsyqQ17xdWM14z0fL1q3xCfCOe6Tb1hC0famwNUld5yReIeBLqqMnypGKigl92GJEKa92K3H8bpyFJr1lqWolbZP)Ksz4qOxqLXZiqppKeXyP3gC0JeO3M8oKpyGJQ8TTg(kI0a)Wca8gPb3tQ0WEnyecPXFALg4PDnAb6s0WkqnyBrA0L0G7(NAG)wCTVuovEZ9lSqcdsTE)AhSaaVrP)KsiPD2hDXMVld40xqrbtoqe2dhayZA8ms4Gfa4nkbsi)LdRmoiKbc5wcNL2YjgYa975X3ZzHZsB5eDPJypW3Zzb5yReIsSEzJyOgBlKpyqpp(EolihBLqucbz2igQX2c5dg8i2dYm9IYWbhj4nMvokbZjJXs)5w4qEE89CwWBmRCucMtgJL(ZTWHsL99HeO3C38PLEE89CwWBmRCucMtgJL(ZTWHs24SIeO3C38PLh984Hie28I78td1yBHUsU2XkJdczGqULWzPTCIHmq)hv5BBn8vePHVDOs2(1G7(NAG)wCTVuovEZ9lSqcdsTE)6XaqfSJs5Hkz7)InFNVNZcNL2YjgQX2c5JC4rLVT1WxrKgC6vEhsJT0qYkqQzDAalnSY)FUfon(t71GTaiKgYjRiYH0WkqnyecPb39p1OboKgVn4OhPHvGAyVg)jPbvGAaZAyAWbYSrd82XwjePH9AiNSQbICinGJgmcH0yOgBRTWPHH04HAuWxJtdWw404HAmuEi0PgG9zlCA0w9YgnWBhBLqKkV5(fwiHbPwVFnQx5DOlC(Dmk92GJE0D5UyZ3pmuEi0PXZipp(EolihBLqucbz2igQX2cDvlXso2kHiXwjeKzd2HASTqxjNSI9ngvVab7SemN(tkLHdHEbvgpJapI9Tbh9IFBO0dtGl5JCY6LHKigl92GJEuRd1yBHWEGCSvcrITsw53ZBOgBl0v4CGIgdFhv5BBn8vePbNEL3H04HACAainmnWXG8gtJhQrhrA4ly2Y3OYBUFHfsyqQ17xJ6vEh6InFhGnRXZiXIxGjhSa3FHfwheYaHClXwi30FJNrj8QB13BsGeG1rIHmq)yj8QVsseOylKB6VXZOeE1T67njqcW6ivEZ9lSqcdsTE)A0Bt2ySl28DzEJr1lqpXy2KaNn)cQmEgbI9aFpNfO3MSXyIHYdHonEgH9asIyS0Bdo6rc0Bt2ySRAPNNmtVOmCWrIFBiUWPsGdzn8BbsZrpV3yu9ceSZsWC6pPugoe6fuz8mcelFpNfKJTsikHGmBed1yBHUQLyjhBLqKyRecYSblFpNfO3MSXyIHASTqxHbWIKigl92GJEKa92KngZN7Y6rShKz6fLHdosW87SXqPmJOFlCjCSTrcrEE)2qygmJSIhF475Sa92KngtmuJTfQvmEe7Bdo6f)2qPhMaxYh8OY32AGzT)PgCEIXSrdFZS5xJoI0awA4a1G7jvAmuEi0PXZin47VgOFzmn4A7RrgoA0w(D2yinKgOtdRa1aewT51OJin4PmCinWVVbj0GZVmMgDePbpLHdPb(Hfa4nsd0wosJ)0En4UmMgsd0PHvW)Kgn482KngtL3C)clKWGuR3Vg92Kng7InF)ngvVa9eJztcC28lOY4zeiw(EolqVnzJXedLhcDA8mc7bzMErz4GJem)oBmukZi63cxchBBKqKN3VneMbZiR4Xhz9i23gC0l(THspmbUKpTuLVT1aZA)tn8ndzn8BbsJgDePbN3MSXyA8qnUrKKgDjn(tsd(EoRbVFnmgcQrhTfon482KngtdyPbE0aroybI0aoAWiesJHAST2cNkV5(fwiHbPwVFn6TjBm2fB((0lkdhCK43gIlCQe4qwd)wG0Gfjrmw6Tbh9ib6TjBmMp3Bj2dYW3ZzXVnex4ujWHSg(TaPr0LWY3Zzb6TjBmMyO8qOtJNrEEhayZA8msaoK1K4UmwkBmwcMZypW3Zzb6TjBmMyOgBl0vT0Zdjrmw6Tbh9ib6TjBmMpye7BmQEb6jgZMe4S5xqLXZiqS89CwGEBYgJjgQX2cDfEoE8OkFBRb(nMRZSNqAW9K(tA0W0GZBdQp4in6isdUlJPHZ6isdoVnzJX04HAKngtdyoFHgwbQrhrAW5Tb1hCKgpuJBejPHVziRHFlqA0a9M7MgDjvEZ9lSqcdsTE)Aa2SgpJUOSg6o6TjBmwIlS(u2ySemNVaGX60Dd9JXssqU04JV3(LDqU2Xq(Eol(TH4cNkboK1WVfinc0BUBhVSd89CwGEBYgJjgQX2cHHTeZGKiglDAONWqzEJr1lqpXy2KaNn)cQmEgbE8Yo4GqgiKBjqVnzJXed1yBHWWwIzqseJLon0ty4BmQEb6jgZMe4S5xqLXZiWJx2bq4lY9XFcMteRxKyOgBlegINJypW3Zzb6TjBmMOl555GqgiKBjqVnzJXed1yBHoQY32A4RisdoVnO(GJ0G7(NA4BgYA43cKgnEOg3issJUKg)jPbFpN1G7(NW(RbdI2cNgCEBYgJPrx63gsdRa1OJin482G6dosdyPHS2QgykSfyIgO3C3qA0RFzAiRA82GJEKkV5(fwiHbPwVFn6Tb1hC0fB(oaBwJNrcWHSMe3LXszJXsWCglaBwJNrc0Bt2ySexy9PSXyjyoJvga2SgpJelUcouc92G6doYZ7aFpNf8gZkhLG5KXyP)ClCOuzFFib6n3nFAPNhFpNf8gZkhLG5KXyP)ClCOKnoRib6n3nFA5rSijIXsVn4OhjqVnzJXUswXcWM14zKa92KnglXfwFkBmwcMZQ8TTg(kI0aX1Mgnqqn(t71WpSRbo61OXWNgDPFBin49RrhTfon2xddPbZEsddPHeeHwEgPbS0GriKg)PvA0snqV5UH0aoAGzth9AW9KknAzRAGEZDdPbHpPDivEZ9lSqcdsTE)Ad0K(faLqCTP5cNFhJsVn4OhDxUl28Dz(1DBlCyLXC)clHbAs)cGsiU20KaTgdhj2kLzlUZ3Zde(cd0K(faLqCTPjbAngosGEZD7QwIfe(cd0K(faLqCTPjbAngosmuJTf6QwQY32ACPs5HqNACPbHvEhsJnRb(BX1(s50yrAmKb6)cn(tAinSH0GriKg)PvAGhnEBWrpsJT0OT6LnAG3o2kHin4U)PgCGVV9cnyecPXFALgY1UgW)KgUlI0ylnSYVg4TJTsisd4OrxsJhQbE04Tbh9in4PmCinmnAREzJg4TJTsisOHVbwT51yO8qOtna7Zw404sXwGdbQbE3ib5stdvVg9IriKgBPbhiZgnWBhBLqKkV5(fwiHbPwVFDdew5DOlC(Dmk92GJE0D5UyZ3hkpe604ze23gC0l(THspmbUKphoiNS26bKeXyP3gC0JeO3M8oegIrmKVNZcYXwjeLy9Ygrx64XwhQX2cDeZCqUwFJr1lEUBLAGWcjOY4ze4rShCqideYTeolTLtmKb6hRmGtFbffm5arypaWM14zKWblaWBucKq(lNNNdczGqULWblaWBu6pPesAN9rIHmq)EEY4GaOYQxulUZpLn6ONhsIyS0Bdo6rc0BtEh6QdhWGx2b(EolihBLquI1lBeDjmeJhpIHhKR13yu9IN7wPgiSqcQmEgbE8iwzihBLqKabz2KkcFVN3bYXwjej2kHGmB88oqo2kHiXwjE4F65ro2kHiXwjwVS5iwzEJr1lqWolbZP)Ksz4qOxqLXZiqpp(EolKMTboGRXs24SADjPodzJaGX6Kp3XiEA)i2dijIXsVn4OhjqVn5DORKRDm8GCT(gJQx8C3k1aHfsqLXZiWJhXAOFmwscYLgFWt7xgFpNfO3MSXyIHASTqyig8i2dYW3ZzXTTahcmrnsqU00q1NOIgCRSjrxYZJCSvcrITsiiZgppzCqauz1lU5FwRoIvg(EolgdavWokLhQKT)eARCNLo9JEAwt0Lu5BBn8vePHVfI5AalnCGAWD)ty)1WzssBHtL3C)clKWGuR3VodhhLG5uzFFOl28Dtk5oj3nvEZ9lSqcdsTE)Aa2SgpJUOSg6Udm5Gf4(lSsgKUaGX60DzaN(ckkyYbIWcWM14zKWbMCWcC)fwypCGVNZc0Bt2ymrxYZ7ngvVa9eJztcC28lOY4zeONNdcGkRErT4o)u2OJypidFpNfiid9RJeDjSYW3ZzHZsB5eDjShK5ngvVi3h)jyorSErcQmEgb65X3ZzHZsB5eG9X(fw(4GqgiKBjY9XFcMteRxKyOgBluR((rSaSznEgj(ZzzSeIOB0K4A7J9GmoiaQS6f1I78tzJ88CqideYTeoybaEJs)jLqs7Sps0LWEGVNZc0Bt2ymXqn2wORWONNmVXO6fONymBsGZMFbvgpJapEe7Bdo6f)2qPhMaxYh(EolCwAlNaSp2VWcdBxGbo65XdriS5f35NgQX2cDfFpNfolTLta2h7xyDuLVT1WxrKg4Vfx7lLtdyPHduJEXiesdRa1GTfPX(A0L0G7(NAGFybaEJu5n3VWcjmi169RDeJq)ASKXwCvdv)fB(oaBwJNrchyYblW9xyLmiPYBUFHfsyqQ17xVLZMY(fwxS57aSznEgjCGjhSa3FHvYGKkFBRHVIinW7gjixA0atHfOgWsdhOgC3)udoVnzJX0OlPHvGAGmaKgz4OXL0ziB0WkqnWFlU2xkNkV5(fwiHbPwVFn1ib5stIhwGxS578qec7wpnsqM9eykV4o)0qn2wORKdpEEh475SqA2g4aUglzJZQ1LK6mKncagRtxHr80UNhFpNfsZ2ahW1yjBCwTUKuNHSraWyDYN7yepTFelFpNfO3MSXyIUe2doiKbc5wcNL2YjgQX2c5dEA3ZdC6lOOGjhi6OkFBRXLkLhcDQrMzdPbS0OlPXd1OLA82GJEKgC3)e2FnWFlU2xkNg80w40W4H9xJhQbHpPDinScuJc(AabqJZKK2cNkV5(fwiHbPwVFn6jgZMuMzdDHZVJrP3gC0JUl3fB((q5HqNgpJW(BdLEycCjFKdpyrseJLEBWrpsGEBY7qxjRynPK7KC3WEGVNZcNL2YjgQX2c5JCT75jdFpNfolTLt0LoQY32A4RisdFleV1yZASfAbjnSsd82XwjePHvGAW2I0yFn6sAWD)tnmnUKodzJgsd0PHvGA0cqt6xaKgC4AtJkV5(fwiHbPwVFDUp(tWCIy9IUyZ3jhBLqKyRKv(XAsj3j5UHLVNZcPzBGd4ASKnoRwxsQZq2iaySoDfgXt7ypacFHbAs)cGsiU20KaTgdhj(1DBlCEEY4GaOYQxuKBGm4a65HKigl92GJEKpy8i2d89CwmgaQGDukpujB)IHASTqxD5x2b8GHtVOmCWrc0w5olD6h90S2rS89CwmgaQGDukpujB)IUKNNm89CwmgaQGDukpujB)IU0rShKXbHmqi3s4S0worxYZJVNZI)CwglHi6gnc0BUBxjhEWMxCNFAOgBl0vyS92XMxCNFAOgBlKpY1E7EEYGGDg)wGI)CwglHi6gncQmEgbEe7beSZ43cu8NZYyjer3OrqLXZiqppheYaHClHZsB5ed1yBH8PLTFuLVT1WxrKgMgCEBYgJPXLEr)Pgsd0PrVyecPbN3MSXyASinm2qgOFn6sAahn8d7AydPHXd7VgpudiaACMKgTaDjQ8M7xyHegKA9(1O3MSXyxS5789Cwal6prjjACK0VWs0LWEGVNZc0Bt2ymXq5HqNgpJ88m0pgljb5sJpxE7hv5BBn8n9gjnAb6s0GNYWH0a)Wca8gPb39p1GZBt2ymnScuJ)Kkn482G6dosL3C)clKWGuR3Vg92Kng7InF3bbqLvVOwCNFkBewzEJr1lqpXy2KaNn)cQmEgbI9aaBwJNrchSaaVrjqc5VCEEoiKbc5wcNL2Yj6sEE89Cw4S0worx6iwheYaHClHdwaG3O0FsjK0o7Jed1yBHUcNdu0y4ddD0YoyOFmwscYLgmdEA)iw(EolqVnzJXed1yBHUswXkd40xqrbtoqKkV5(fwiHbPwVFn6Tb1hC0fB(UdcGkRErT4o)u2iShayZA8ms4Gfa4nkbsi)LZZZbHmqi3s4S0worxYZJVNZcNL2Yj6shX6GqgiKBjCWca8gL(tkHK2zFKyOgBl0vyqS89CwGEBYgJj6syjhBLqKyRKv(XkdaBwJNrIfxbhkHEBq9bhHvgWPVGIcMCGiv(2wdFfrAW5Tb1hCKgC3)udR04sVO)udPb60aoASzn8d7TbudiaACMKgTaDjAWD)tn8d7JgfHVxdNHEHgTGHGAa2BK0OfOlrd714pjnOcudywJ)K0aZov)P)rd(EoRXM1GZBt2ymn4c7mWQnVgzJX0aMZAahn8d7AydPbS0aJA82GJEKkV5(fwiHbPwVFn6Tb1hC0fB(oFpNfWI(tuYXiBsaw0clrxYZ7GmO3M8oKWKsUtYDdRmaSznEgjwCfCOe6Tb1hCKN3b(EolCwAlNyOgBl0v4blFpNfolTLt0L88oCGVNZcNL2YjgQX2cDfohOOXWhg6OLDWq)ySKeKlnyMw2(rS89Cw4S0worxYZJVNZIXaqfSJs5Hkz7pH2k3zPt)ONM1ed1yBHUcNdu0y4ddD0YoyOFmwscYLgmtlB)iw(EolgdavWokLhQKT)eARCNLo9JEAwt0LoI1bbqLvVaav)P)54rShqseJLEBWrpsGEBYgJDvl98ayZA8msGEBYgJL4cRpLnglbZ5JhXkdaBwJNrIfxbhkHEBq9bhH9GmtVOmCWrIFBiUWPsGdzn8BbsJNhsIyS0Bdo6rc0Bt2ySRA5rv(2wdFfrACPbHfsJT0GdKzJg4TJTsisdRa1azain8TDgtJlniS0idhnWFlU2xkNkV5(fwiHbPwVFDrCtnqyDXMVFGVNZcYXwjeLqqMnIHASTq(q4JC9Ns)2qEEhCN2GJq3Xi2HCN2GJs)2qxHNJEEUtBWrO7T8iwtk5oj3nvEZ9lSqcdsTE)6tJLtnqyDXMVFGVNZcYXwjeLqqMnIHASTq(q4JC9Ns)2qEEhCN2GJq3Xi2HCN2GJs)2qxHNJEEUtBWrO7T8iwtk5oj3nSh475Symaub7OuEOs2(fd1yBHUcpy575Symaub7OuEOs2(fDjSYm9IYWbhjqBL7S0PF0tZAEEYW3ZzXyaOc2rP8qLS9l6shv5n3VWcjmi169RZDgl1aH1fB((b(EolihBLqucbz2igQX2c5dHpY1Fk9BdH9GdczGqULWzPTCIHASTq(GN298CqideYTeoybaEJs)jLqs7SpsmuJTfYh80(rpVdUtBWrO7ye7qUtBWrPFBORWZrpp3Pn4i09wEeRjLCNK7g2d89CwmgaQGDukpujB)IHASTqxHhS89CwmgaQGDukpujB)IUewzMErz4GJeOTYDw60p6Pznppz475Symaub7OuEOs2(fDPJQ8TTg(kI0aZcI3AalnWVVrL3C)clKWGuR3VMRnZcNemNiwViv(2wd8BmxNzpH0G7j9N0OXd1OJin482K3H0yln4az2Ob3Z1DQXI0WEnWJgVn4Oh1QCAKHJgeaA8RbgBhZOrJHEA8RbC0qw1GZBdQp4inW7gjixAAO61a9M7gsL3C)clKWGuR3VgGnRXZOlkRHUJEBY7qPTsiiZMlaySoDhjrmw6Tbh9ib6TjVd5JS2AMbHZHgd904pbWyDcdLR92XmyS9JTMzq4CGVNZc0BdQp4Oe1ib5stdvFcbz2iqV5UHzK1JQ8TTg43yUoZEcPb3t6pPrJhQbM1y)PgG9zlCA4BhQKTFvEZ9lSqcdsTE)Aa2SgpJUOSg6o3X(Z0wP8qLS9FbaJ1P7YHzqseJLon0txHXl7q7cmIHhqseJLEBWrpsGEBY7qxMChXWdY16BmQEbc2zjyo9Nukdhc9cQmEgbIHYjWZXJT2Uqo8GH89CwmgaQGDukpujB)IHASTqQ8TTg(kI0aZAS)uJT0GdKzJg4TJTsisd4OXM1OGAW5TjVdPb3LX0iVVgB9qnWFlU2xkNgw5VboKkV5(fwiHbPwVFn3X(Zl289dKJTsisW6LnPIW375ro2kHiHv(tfHVhlaBwJNrIfLCmYaqhXE4Tbh9IFBO0dtGl5JS65ro2kHibRx2K2kHrpV8I78td1yBHUsU2p65X3Zzb5yReIsiiZgXqn2wORm3VWsGEBY7qccFKR)u63gclFpNfKJTsikHGmBeDjppYXwjej2kHGmBWkdaBwJNrc0BtEhkTvcbz245X3ZzHZsB5ed1yBHUYC)clb6TjVdji8rU(tPFBiSYaWM14zKyrjhJmaew(EolCwAlNyOgBl0ve(ix)P0Vnew(EolCwAlNOl55X3ZzXyaOc2rP8qLS9l6sybyZA8msWDS)mTvkpujB)EEYaWM14zKyrjhJmaew(EolCwAlNyOgBlKpe(ix)P0VnKkFBRHVIin482K3H0yZASLgTvVSrd82XwjeDHgBPbhiZgnWBhBLqKgWsdzTvnEBWrpsd4OXd1qAGon4az2ObE7yReIu5n3VWcjmi169RrVn5Div(2wdFRXy)50v5n3VWcjmi169RNELm3VWkXw0Frzn09SXy)50v5v5BBn8TdvY2VgC3)ud83IR9LYPYBUFHfsWdT)(yaOc2rP8qLS9FXMVZ3ZzHZsB5ed1yBH8ro8OY32A4RisJwaAs)cG0GdxBA0G7jvAyVgmcH04pTsdzvdmf2cmrd0BUBinScuJhQXq5HqNAyAC1DmQb6n3nnmKgm7jnmKgsqeA5zKgWrJFBin2xdeuJ91WMzbqinWSPJEnS8tJgMgTSvnqV5UPbHpPDiKkV5(fwibp0(wVFTbAs)cGsiU20CHZVJrP3gC0JUl3fB(oFpNf8gZkhLG5KXyP)ClCOuzFFib6n3TR8DS89CwWBmRCucMtgJL(ZTWHs24SIeO3C3UY3XEqgq4lmqt6xaucX1MMeO1y4iXVUBBHdRmM7xyjmqt6xaucX1MMeO1y4iXwPmBXD(ypidi8fgOj9lakH4Att6KmM4x3TTW55bcFHbAs)cGsiU20KojJjgQX2c5tlp65bcFHbAs)cGsiU20KaTgdhjqV5UDvlXccFHbAs)cGsiU20KaTgdhjgQX2cDfEWccFHbAs)cGsiU20KaTgdhj(1DBlChv5BBn8vePb(Hfa4nsdU7FQb(BX1(s50G7jvAibrOLNrAyfOgW)KgUlI0G7(NAyAGPWwGjAW3Zzn4EsLgGeYF52cNkV5(fwibp0(wVFTdwaG3O0FsjK0o7JUyZ3LbC6lOOGjhic7HdaSznEgjCWca8gLajK)YHvgheYaHClHZsB5edzG(98475SWzPTCIU0rSh475SG3yw5OemNmgl9NBHdLk77djqV5UD3398475SG3yw5OemNmgl9NBHdLSXzfjqV5UD33p65XdriS5f35NgQX2cDLCTJ1bHmqi3s4S0woXqn2wiFWahv5BBn8Tq8wddPXFsAK3b9AGZbQXwA8NKgMgykSfyIgC3ceYvd4Ob39p14pjnUu4FwR0GVNZAahn4U)PgMg(ERiYPrlanPFbqAWHRnnAyfOgCT91idhnWFlU2xkNgBwJ91GlSEn4jn6sAy4ST0GNYWH04pjnCGASinYBTOtcuL3C)clKGhAFR3Vo3h)jyorSErxS57hoCGVNZcEJzLJsWCYyS0FUfouQSVpKa9M7Mpyqpp(Eol4nMvokbZjJXs)5w4qjBCwrc0BUB(GbpI9GmoiaQS6faO6p9pEEYW3ZzXyaOc2rP8qLS9l6shpI9a40xqrbtoqKNNdczGqULWzPTCIHASTq(GN298o4GaOYQxulUZpLncRdczGqULWblaWBu6pPesAN9rIHASTq(GN2pE8ON3bq4lmqt6xaucX1MMeO1y4iXqn2wiF8DSoiKbc5wcNL2YjgQX2c5JCTJ1bbqLvVOi3azWb8ON3wpnsqM9eykV4o)0qn2wOR8DSY4GqgiKBjCwAlNyid0VNNdcGkREXn)ZAfw(EolUTf4qGjQrcYLMgQErxYZZbbqLvVaav)P)blFpNfJbGkyhLYdvY2VyOgBl0vxow(EolgdavWokLhQKTFrxsLVT1a)w5iMgCEByWbudU7FQHPrrC1atHTat0GVNZAyfOg4Vfx7lLtJfvT51W4H9xJhQbpPrhrGQ8M7xyHe8q7B9(1oRCelX3Z5lkRHUJEByWb8InF)aFpNf8gZkhLG5KXyP)ClCOuzFFiXqn2wiFWac845X3ZzbVXSYrjyozmw6p3chkzJZksmuJTfYhmGaphXEWbHmqi3s4S0woXqn2wiFWaEEhCqideYTeuJeKlnjEybkgQX2c5dgaRm89CwCBlWHatuJeKlnnu9jQOb3kBs0LW6GaOYQxCZ)SwD8iwd9JXssqU04Z9w2UkFBRHVP3iPbN3guFWrin4U)PgMgykSfyIg89Cwd((RrbFn4EsLgsqiBlCAKHJg4Vfx7lLtd4OXLITahcudos7SpsL39lSqcEO9TE)A0BdQp4Ol289d89CwWBmRCucMtgJL(ZTWHsL99HeO3C38bJEE89CwWBmRCucMtgJL(ZTWHs24SIeO3C38bJhXE4GmoiaQS6f1I78tzJ88m0pgljb5sJp3L12pI1bHmqi3s4S0woXqn2wiFWaEEYaWM14zKWbMCWcC)fwyLXbbqLvV4M)zTYZ7GdczGqULGAKGCPjXdlqXqn2wiFWayLHVNZIBBboeyIAKGCPPHQprfn4wztIUewheavw9IB(N1QJhXEqgq4lY9XFcMteRxK4x3TTW55jJdczGqULWzPTCIHmq)EEY4GqgiKBjCWca8gL(tkHK2zFKyid0)rv(2wdFtVrsdoVnO(GJqAWtz4qAGFybaEJu5n3VWcj4H2369RrVnO(GJUyZ3p4GqgiKBjCWca8gL(tkHK2zFKyOgBl0v4bRmGtFbffm5arypaWM14zKWblaWBucKq(lNNNdczGqULWzPTCIHASTqxHNJybyZA8ms4atoybU)cRJyLbe(ICF8NG5eX6fj(1DBlCyDqauz1lQf35NYgHvgWPVGIcMCGiSKJTsisSvYk)yn0pgljb5sJpYA7Q8TTg(gy1Mxdq4RbyF2cNg)jPbvGAaZACPAaOc2rA4BhQKT)l0aSpBHtJBBboeOguJeKlnnu9Aahn2sJ)K0GzOxdCoqnGznSsd82XwjePYBUFHfsWdTV17xdWM14z0fL1q3bHFAi8QVd1q1JUaGX609d89CwmgaQGDukpujB)IHASTq(Ghppz475Symaub7OuEOs2(fDPJypW3ZzXTTahcmrnsqU00q1NOIgCRSjXqn2wORW5afng(oI9aFpNfKJTsikHGmBed1yBH8bNdu0y4ZZJVNZcYXwjeLy9YgXqn2wiFW5afng(oQYBUFHfsWdTV17xJ6vEh6cNFhJsVn4OhDxUl289HYdHonEgH9Tbh9IFBO0dtGl5JCyqSMuYDsUBybyZA8msac)0q4vFhQHQhPYBUFHfsWdTV17x3aHvEh6cNFhJsVn4OhDxUl289HYdHonEgH9Tbh9IFBO0dtGl5JCTuGhSMuYDsUBybyZA8msac)0q4vFhQHQhPYBUFHfsWdTV17xJEIXSjLz2qx487yu6Tbh9O7YDXMVpuEi0PXZiSVn4Ox8BdLEycCjFKdd26qn2wiSMuYDsUBybyZA8msac)0q4vFhQHQhPY32A4BHyUgWsdhOgC3)e2FnCMK0w4u5n3VWcj4H2369RZWXrjyov23h6InF3KsUtYDtLVT1aVBKGCPrdmfwGAW9KknmEy)14HAq1tJgMgfXvdmf2cmrdUBbc5QHvGAGmaKgz4Ob(BX1(s5u5n3VWcj4H2369RPgjixAs8Wc8InF)a5yReIeSEztQi89EEKJTsisGGmBsfHV3ZJCSvcrcR8NkcFVNhFpNf8gZkhLG5KXyP)ClCOuzFFiXqn2wiFWac845X3ZzbVXSYrjyozmw6p3chkzJZksmuJTfYhmGapEEg6hJLKGCPXNlVDSoiKbc5wcNL2YjgYa9JvgWPVGIcMCGOJyp4GqgiKBjCwAlNyOgBlKpTSDppheYaHClHZsB5edzG(p65XdriSB90ibz2tGP8I78td1yBHUsU2v5BBn8Tq8wJzXD(AWtz4qA0rBHtd83cvEZ9lSqcEO9TE)6CF8NG5eX6fDXMV7GqgiKBjCwAlNyid0pwa2SgpJeoWKdwG7VWc7bd9JXssqU04ZL3owzCqauz1lQf35NYg555GaOYQxulUZpLncRH(XyjjixAUswB)iwzCqauz1laq1F6FWEqgheavw9IAXD(PSrEEoiKbc5wchSaaVrP)KsiPD2hjgYa9FeRmGtFbffm5arQ8TTg4Vfx7lLtdUNuPH9AC5T3QgTaDjACaomixA04pTsdzTDnAb6s0G7(NAGFybaEJoQb39pH9xdgeTfon(TH0ylnWugecY6OxdRa1GTfPrxsdU7FQb(Hfa4nsJnRX(AW1qAasi)LJav5n3VWcj4H2369RbyZA8m6IYAO7oWKdwG7VWkXdT)cagRt3LbC6lOOGjhiclaBwJNrchyYblW9xyH9Wbd9JXssqU04ZL3o2d89CwCBlWHatuJeKlnnu9jQOb3kBs0L88KXbbqLvV4M)zT6ONhFpNf8mieK1rVOlHLVNZcEgecY6OxmuJTf6k(EolCwAlNaSp2VW6ONhpeHWU1tJeKzpbMYlUZpnuJTf6k(EolCwAlNaSp2VWYZZbbqLvVOwCNFkB0rShKXbbqLvVOwCNFkBKN3bd9JXssqU0CLS2UNhi8f5(4pbZjI1ls8R72w4oI9aaBwJNrchSaaVrjqc5VCEEoiKbc5wchSaaVrP)KsiPD2hjgYa9F8OkV5(fwibp0(wVFTJye6xJLm2IRAO6VyZ3byZA8ms4atoybU)cRep0EvEZ9lSqcEO9TE)6TC2u2VW6InFhGnRXZiHdm5Gf4(lSs8q7v5BBnWB0Vn2tinoHC1OP7o1OfOlrdBinWzBrGAirJgiYblqvEZ9lSqcEO9TE)Aa2SgpJUOSg6UHKUeA4qUlaySoDNCSvcrITsSEzdg67ygZ9lSeO3M8oKGWh56pL(THAvgYXwjej2kX6Lny4bmyRVXO6fiyNLG50FsPmCi0lOY4zeig2YJygZ9lSeCh7pfe(ix)P0VnuRTlWiMbjrmw60qpPY32A4B6nsAW5Tb1hCesdUNuPXFsAKxCNVglsdJh2FnEOgubEHg5Hkz7xJfPHXd7VgpudQaVqd)WUg2qAyVgxE7TQrlqxIgBPHvAG3o2kHOl0a)T4AFPCAWm0J0Wk4FsJg(ERiYH0aoA4h21GlSZa1acGgNjPrdCin(tR0q9KRDnAb6s0G7jvA4h21GlSZaR28AW5Tb1hCKgfKRkV5(fwibp0(wVFn6Tb1hC0fB((bEicHDRNgjiZEcmLxCNFAOgBl0vYQN3b(EolgdavWokLhQKTFXqn2wORW5afng(WqhTSdg6hJLKGCPbZ0Y2pILVNZIXaqfSJs5Hkz7x0LoE0Z7GH(XyjjixAAfGnRXZiHHKUeA4qomKVNZcYXwjeLqqMnIHASTqTccFrUp(tWCIy9Ie)6UHsd1yBHHyuGhFKtU298m0pgljb5stRaSznEgjmK0LqdhYHH89Cwqo2kHOeRx2igQX2c1ki8f5(4pbZjI1ls8R7gknuJTfgIrbE8ro5A)iwYXwjej2kzLFShKHVNZcNL2Yj6sEEY8gJQxGEByWbuqLXZiWJypCqgheYaHClHZsB5eDjppheavw9IB(N1kSY4GqgiKBjOgjixAs8Wcu0Lo655GaOYQxulUZpLn6i2dY4GaOYQxaGQ)0)45jdFpNfolTLt0L88m0pgljb5sJpxE7h98o8gJQxGEByWbuqLXZiqS89Cw4S0worxc7b(EolqVnm4akqV5UDvl98m0pgljb5sJpxE7hp65X3ZzHZsB5eDjSYW3ZzXyaOc2rP8qLS9l6syL5ngvVa92WGdOGkJNrGQ8TTg(kI04sdclKgBPrB1lB0aVDSvcrAyfOgidaPXLYgl3QVTZyACPbHLgz4Ob(BX1(s5u5n3VWcj4H2369RlIBQbcRl289d89Cwqo2kHOeRx2igQX2c5dHpY1Fk9Bd55DWDAdocDhJyhYDAdok9BdDfEo655oTbhHU3YJynPK7KC3u5n3VWcj4H2369Rpnwo1aH1fB((b(EolihBLquI1lBed1yBH8HWh56pL(THWEWbHmqi3s4S0woXqn2wiFWt7EEoiKbc5wchSaaVrP)KsiPD2hjgQX2c5dEA)ON3b3Pn4i0DmIDi3Pn4O0Vn0v45ONN70gCe6ElpI1KsUtYDtL3C)clKGhAFR3Vo3zSudewxS57h475SGCSvcrjwVSrmuJTfYhcFKR)u63gc7bheYaHClHZsB5ed1yBH8bpT755GqgiKBjCWca8gL(tkHK2zFKyOgBlKp4P9JEEhCN2GJq3Xi2HCN2GJs)2qxHNJEEUtBWrO7T8iwtk5oj3nv(2wdmliERbS0WbQYBUFHfsWdTV17xZ1MzHtcMteRxKkFBRHVIin482K3H04HAinqNgCGmB0aVDSvcrAahn4EsLgBPbSy(1OT6LnAG3o2kHinScuJoI0aZcI3AinqhsJnRXwA0w9YgnWBhBLqKkV5(fwibp0(wVFn6TjVdDXMVto2kHiXwjwVSXZJCSvcrceKztQi89EEKJTsisyL)ur4798475SGRnZcNemNiwVirxclFpNfKJTsikX6LnIUKN3b(EolCwAlNyOgBl0vM7xyj4o2Fki8rU(tPFBiS89Cw4S0worx6OkV5(fwibp0(wVFn3X(tvEZ9lSqcEO9TE)6PxjZ9lSsSf9xuwdDpBm2FoDvEv(2wdoVnO(GJ0idhnAGaOgQEn6fJqin6OTWPbMcBbMOYBUFHfsKng7pN(D0BdQp4Ol28DzMErz4GJe8gZkhLG5KXyP)ClCibHx9vsIav5BBnWVHEn(tsdq4Rb39p14pjnAGOxJFBinEOggiOg96xMg)jPrJHpna7J9lS0yrACUVqdo9kVdPXqn2winA6SFLylbQXd1OXE3PgnqyL3H0aSp2VWsL3C)clKiBm2Fo9wVFnQx5DOlC(Dmk92GJE0D5UyZ3bHVObcR8oKyOgBlKpd1yBHWqmIrmJC(UkV5(fwir2yS)C6TE)6giSY7qQ8Q8TTg(kI0GZBdQp4inEOg3issJUKg)jPHVziRHFlqA0GVNZASzn2xdUWodudcFs7qAWtz4qAK3ArNBHtJ)K0Oi89A4m0RbC04HAa2BK0GNYWH0a)Wca8gPYBUFHfsG(7O3guFWrxS57tVOmCWrIFBiUWPsGdzn8Bbsd2dKJTsisSvYk)yL5Wb(Eol(TH4cNkboK1WVfinIHASTq(yUFHLG7y)PGWh56pL(THATDHCypqo2kHiXwjE4F65ro2kHiXwjeKzJNh5yReIeSEztQi89h98475S43gIlCQe4qwd)wG0igQX2c5J5(fwc0BtEhsq4JC9Ns)2qT2UqoShihBLqKyReRx245ro2kHibcYSjve(EppYXwjejSYFQi89hp65jdFpNf)2qCHtLahYA43cKgrx6ON3b(EolCwAlNOl55bWM14zKWblaWBucKq(l3rSoiKbc5wchSaaVrP)KsiPD2hjgYa9J1bbqLvVOwCNFkB0rShKXbbqLvV4M)zTYZZbHmqi3sqnsqU0K4HfOyOgBlKp((rSh475SWzPTCIUKNNmoiKbc5wcNL2YjgYa9FuLVT1WxrKgTa0K(faPbhU20Ob3tQ04pPH0yrAuqnm3VainqCTP5cnmKgm7jnmKgsqeA5zKgWsdexBA0G7(NAGrnGJgzIlnAGEZDdPbC0awAyA0Yw1aX1Mgnqqn(t714pjnkIRgiU20OHnZcGqAGzth9Ay5Ngn(t71aX1Mgni8jTdHu5n3VWcjqFR3V2anPFbqjexBAUW53XO0Bdo6r3L7InFxgq4lmqt6xaucX1MMeO1y4iXVUBBHdRmM7xyjmqt6xaucX1MMeO1y4iXwPmBXD(ypidi8fgOj9lakH4Att6KmM4x3TTW55bcFHbAs)cGsiU20KojJjgQX2c5dEo65bcFHbAs)cGsiU20KaTgdhjqV5UDvlXccFHbAs)cGsiU20KaTgdhjgQX2cDvlXccFHbAs)cGsiU20KaTgdhj(1DBlCQ8TTg(kIqAGFybaEJ0yZAG)wCTVuonwKgDjnGJg(HDnSH0aKq(l3w40a)T4AFPCAWD)tnWpSaaVrAyfOg(HDnSH0GNyqUAiRTRrlqxIkV5(fwib6B9(1oybaEJs)jLqs7Sp6InFxgWPVGIcMCGiShoaWM14zKWblaWBucKq(lhwzCqideYTeolTLtmKb6hRmtVOmCWrcPzBGd4ASKnoRwxsQZq245X3ZzHZsB5eDPJyn0pgljb5sZv3L12XEGVNZcYXwjeLy9YgXqn2wiFKRDpp(EolihBLqucbz2igQX2c5JCTF0ZJhIqyZlUZpnuJTf6k5AhRmoiKbc5wcNL2YjgYa9FuLVT1a)WcC)fwAKHJggJPbi8rA8N2RrJDJqAG6dPXFs(1WgQAZRXq5HqNeOgCpPsJlvdavWosdF7qLS9RXPH0GriKg)PvAGhnqKdPXqn2wBHtd4OXFsACZ)SwPbFpN1yrAy8W(RXd1iBmMgWCwd4OHv(1aVDSvcrASinmEy)14HAq4tAhsL3C)clKa9TE)Aa2SgpJUOSg6oi8tdHx9DOgQE0famwNUFGVNZIXaqfSJs5Hkz7xmuJTfYh845jdFpNfJbGkyhLYdvY2VOlDeRm89CwmgaQGDukpujB)j0w5olD6h90SMOlH9aFpNf32cCiWe1ib5stdvFIkAWTYMed1yBHUcNdu0y47i2d89Cwqo2kHOecYSrmuJTfYhCoqrJHppp(EolihBLquI1lBed1yBH8bNdu0y4ZZ7Gm89Cwqo2kHOeRx2i6sEEYW3Zzb5yReIsiiZgrx6iwzEJr1lqqg6xhjOY4ze4rv(2wd8dlW9xyPXFAVgUtYDdPXM1WpSRHnKgW(JwqsdYXwjePXd1awm)AacFn(tAinGJglUcoKg)5I0G7(NAWbYq)6ivEZ9lSqc0369RbyZA8m6IYAO7GWpb7pAbPe5yReIUaGX609dYW3Zzb5yReIsiiZgrxcRm89Cwqo2kHOeRx2i6sh98EJr1lqqg6xhjOY4zeOkV5(fwib6B9(1nqyL3HUW53XO0Bdo6r3L7InFFO8qOtJNrypW3Zzb5yReIsiiZgXqn2wiFgQX2c55X3Zzb5yReIsSEzJyOgBlKpd1yBH88ayZA8msac)eS)OfKsKJTsi6i2HYdHonEgH9Tbh9IFBO0dtGl5JCyeRjLCNK7gwa2SgpJeGWpneE13HAO6rQ8M7xyHeOV17xJ6vEh6cNFhJsVn4OhDxUl289HYdHonEgH9aFpNfKJTsikHGmBed1yBH8zOgBlKNhFpNfKJTsikX6LnIHASTq(muJTfYZdGnRXZibi8tW(Jwqkro2kHOJyhkpe604ze23gC0l(THspmbUKpYHrSMuYDsUBybyZA8msac)0q4vFhQHQhPYBUFHfsG(wVFn6jgZMuMzdDHZVJrP3gC0JUl3fB((q5HqNgpJWEGVNZcYXwjeLqqMnIHASTq(muJTfYZJVNZcYXwjeLy9YgXqn2wiFgQX2c55bWM14zKae(jy)rliLihBLq0rSdLhcDA8mc7Bdo6f)2qPhMaxYh5WGynPK7KC3WcWM14zKae(PHWR(oudvpsLVT1WxrKg(wiMRbS0WbQb39pH9xdNjjTfovEZ9lSqc0369RZWXrjyov23h6InF3KsUtYDtLVT1WxrKgxk2cCiqn4iTZ(in4U)Pgw5xdgSWPbvWoUtnyg63cNg4TJTsisdRa14h)A8qnyBrASVgDjn4U)PgxsNHSrdRa1a)T4AFPCQ8M7xyHeOV17xtnsqU0K4Hf4fB((Hd89Cwqo2kHOecYSrmuJTfYh5A3ZJVNZcYXwjeLy9YgXqn2wiFKR9JyDqideYTeolTLtmuJTfYNw2o2d89CwinBdCaxJLSXz16ssDgYgbaJ1PRWOS2UNNmtVOmCWrcPzBGd4ASKnoRwxsQZq2ii8QVsse4XJEE89CwinBdCaxJLSXz16ssDgYgbaJ1jFUJrmq7EEoiKbc5wcNL2YjgYa9J1q)ySKeKln(C5TRY32A4Risd83IR9LYPb39p1a)Wca8gD9LITahcudos7SpsdRa1aewT51acGgUZ(KgxsNHSrd4Ob3tQ0atzqiiRJEn4c7mqni8jTdPbpLHdPb(BX1(s50GWN0oesL3C)clKa9TE)Aa2SgpJUOSg6Udm5Gf4(lSsO)cagRt3LbC6lOOGjhiclaBwJNrchyYblW9xyH9WbheYaHClb1i5FiJLGdyzLJed1yBHUsomigO1dYjhgo9IYWbhjqBL7S0PF0tZAhXs4vFLKiqb1i5FiJLGdyzLJo65zOFmwscYLgFUF5TJ9GmVXO6f5(4pbZjI1lsqLXZiqpp(EolCwAlNaSp2VWYhheYaHClrUp(tWCIy9Ied1yBHA13pIfe(cuVY7qIHASTq(ihgXccFrdew5DiXqn2wiF8DShaHVa9eJztkZSHed1yBH8X398K5ngvVa9eJztkZSHeuz8mc8iwa2SgpJe)5Smwcr0nAsCT9XEGVNZIBBboeyIAKGCPPHQprfn4wztIUKNNmoiaQS6f38pRvhX(2GJEXVnu6HjWL8HVNZcNL2Yja7J9lSWW2fyappEicHnV4o)0qn2wOR475SWzPTCcW(y)clppheavw9IAXD(PSrEE89CwWZGqqwh9IUew(Eol4zqiiRJEXqn2wOR475SWzPTCcW(y)cRwpC5y40lkdhCKqA2g4aUglzJZQ1LK6mKnccV6RKebE8iwz475SWzPTCIUe2dY4GaOYQxulUZpLnYZZbHmqi3s4Gfa4nk9NucjTZ(irxYZJhIqyZlUZpnuJTf6kheYaHClHdwaG3O0FsjK0o7Jed1yBHAfd65LxCNFAOgBleMbZiNV3(v89Cw4S0wobyFSFH1rvEZ9lSqc0369RbyZA8m6IYAO7oWKdwG7VWkH(laySoDxgWPVGIcMCGiSaSznEgjCGjhSa3FHf2dhCqideYTeuJK)HmwcoGLvosmuJTf6k5WGyGwpiNCy40lkdhCKaTvUZsN(rpnRDelHx9vsIafuJK)HmwcoGLvo6ONNH(XyjjixA85(L3o2dY8gJQxK7J)emNiwVibvgpJa98475SWzPTCcW(y)clFCqideYTe5(4pbZjI1lsmuJTfQvF)iwq4lq9kVdjgQX2c5JVJfe(IgiSY7qIHASTq(C5ypacFb6jgZMuMzdjgQX2c5JCT75jZBmQEb6jgZMuMzdjOY4ze4rSaSznEgj(ZzzSeIOB0K4A7J9aFpNf32cCiWe1ib5stdvFIkAWTYMeDjppzCqauz1lU5FwRoI9Tbh9IFBO0dtGl5dFpNfolTLta2h7xyHHTlWaEE8qecBEXD(PHASTqxX3ZzHZsB5eG9X(fwEEoiaQS6f1I78tzJ88475SGNbHGSo6fDjS89CwWZGqqwh9IHASTqxX3ZzHZsB5eG9X(fwTE4YXWPxugo4iH0SnWbCnwYgNvRlj1ziBeeE1xjjc84rSYW3ZzHZsB5eDjShKXbbqLvVOwCNFkBKNNdczGqULWblaWBu6pPesAN9rIUKNhpeHWMxCNFAOgBl0voiKbc5wchSaaVrP)KsiPD2hjgQX2c1kg0ZJhIqyZlUZpnuJTfcZGzKZ3B)k(EolCwAlNaSp2VW6OkFBRHVIin(tsdm7u9N(hn4U)PgMg4Vfx7lLtJ)0Enwu1MxJ8aB04s6mKnQ8M7xyHeOV17xpgaQGDukpujB)xS5789Cw4S0woXqn2wiFKdpEE89Cw4S0wobyFSFH1vTeJybyZA8ms4atoybU)cRe6v5n3VWcjqFR3V2rmc9RXsgBXvnu9xS57aSznEgjCGjhSa3FHvc9ypW3ZzHZsB5eG9X(fw(CVLy0Ztgheavw9cau9N(NJEE89CwmgaQGDukpujB)IUew(EolgdavWokLhQKTFXqn2wORU8wDWcSVVqAi3IOKXwCvdvV43gkbWyDQ1dYW3ZzbpdcbzD0l6syL5ngvVa92WGdOGkJNrGhv5n3VWcjqFR3VElNnL9lSUyZ3byZA8ms4atoybU)cRe6v5BBnWSBZA8msJoIa1awAy8lB)LqA8N2RbxREnEOg8KgidabQrgoAG)wCTVuonqqn(t714pj)AydvVgCn0tGAGzth9AWtz4qA8NuJkV5(fwib6B9(1aSznEgDrzn0DKbGsz4KCwAl3famwNUlJdczGqULWzPTCIHmq)EEYaWM14zKWblaWBucKq(lhwheavw9IAXD(PSrEEGtFbffm5arQ8TTg(kIqA4BH4TgBwJT0WknWBhBLqKgwbQXplH04HAW2I0yFn6sAWD)tnUKodzZfAG)wCTVuonScuJwaAs)cG0GdxBAu5n3VWcjqFR3Vo3h)jyorSErxS57KJTsisSvYk)ynPK7KC3WY3ZzH0SnWbCnwYgNvRlj1ziBeamwNUcJYA7ypacFHbAs)cGsiU20KaTgdhj(1DBlCEEY4GaOYQxuKBGm4aEelaBwJNrcKbGsz4KCwAlh2d89CwmgaQGDukpujB)IHASTqxD5x2b8GHtVOmCWrc0w5olD6h90SwRYq4vFLKiqXwOF6UhoOe4cylkXtm2rS89CwmgaQGDukpujB)IUKNNm89CwmgaQGDukpujB)IU0rv(2wdFfrACPx0FQbN3MSXyAinqhsJnRbN3MSXyASOQnVgDjvEZ9lSqc0369RrVnzJXUyZ3575Saw0FIss04iPFHLOlHLVNZc0Bt2ymXq5HqNgpJu5n3VWcjqFR3V2zLJyj(EoFrzn0D0BddoGxS5789CwGEByWbumuJTf6k8G9aFpNfKJTsikHGmBed1yBH8bpEE89Cwqo2kHOeRx2igQX2c5dEoI1q)ySKeKln(C5TRY32A4B6nsinAb6s0GNYWH0a)Wca8gPrhTfon(tsd8dlaWBKgoybU)clnEOgUtYDtJnRb(Hfa4nsJfPH5(UXy(1W4H9xJhQbpPHZqVkV5(fwib6B9(1O3guFWrxS57oiaQS6f1I78tzJWcWM14zKWblaWBucKq(lhwheYaHClHdwaG3O0FsjK0o7Jed1yBHUcpyLbC6lOOGjhicl5yReIeBLSYpwd9JXssqU04JS2UkFBRHVIin482KngtdU7FQbNNymB0W3mB(1WkqnkOgCEByWb8cn4EsLgfudoVnzJX0yrA0LUqd)WUg2qASLgTvVSrd82XwjePrgoA47TIihsd4OXd1qAGonUKodzJgCpPsdJhcG04YBxJwGUenGJggOK9lasdexBA040qA47TIihsJHAST2cNgWrJfPXwAKzlUZxObMdFsJ)0En6finA8NKgiRH0WblW9xyH0y)2G0aucPrr9FmMgpudoVnzJX0aSpBHtJlvdavWosdF7qLS9FHgCpPsd)WEBa1a9lJPbvGA0L0G7(NAC5T3QHK0idhn(tsdMHEnWXG8gdju5n3VWcjqFR3Vg92Kng7InF)ngvVa9eJztcC28lOY4zeiwzEJr1lqVnm4akOY4zeiw(EolqVnzJXedLhcDA8mc7b(EolihBLquI1lBed1yBH8X3Xso2kHiXwjwVSblFpNfsZ2ahW1yjBCwTUKuNHSraWyD6kmIN298475SqA2g4aUglzJZQ1LK6mKncagRt(ChJ4PDSg6hJLKGCPXNlVDppq4lmqt6xaucX1MMeO1y4iXqn2wiF8DppZ9lSegOj9lakH4Attc0AmCKyRuMT4o)JyDqideYTeolTLtmuJTfYh5AxLVT1WxrKgCEBq9bhPXLEr)Pgsd0H0Wkqna7nsA0c0LOb3tQ0a)T4AFPCAahn(tsdm7u9N(hn475SglsdJh2FnEOgzJX0aMZAahn8d7TbudNjPrlqxIkV5(fwib6B9(1O3guFWrxS5789Cwal6prjhJSjbyrlSeDjpp(EolUTf4qGjQrcYLMgQ(ev0GBLnj6sEE89Cw4S0worxc7b(EolgdavWokLhQKTFXqn2wORW5afng(WqhTSdg6hJLKGCPbZ0Y2p2AlXW3yu9II4MAGWsqLXZiqSYm9IYWbhjqBL7S0PF0tZAy575Symaub7OuEOs2(fDjpp(EolCwAlNyOgBl0v4CGIgdFyOJw2bd9JXssqU0GzAz7h98475Symaub7OuEOs2(tOTYDw60p6PznrxYZ7aFpNfJbGkyhLYdvY2VyOgBl0vM7xyjqVn5DibHpY1Fk9BdHfjrmw60qpDv7cz1ZJVNZIXaqfSJs5Hkz7xmuJTf6kZ9lSeCh7pfe(ix)P0VnKNhaBwJNrIfVatoybU)clSoiKbc5wITqUP)gpJs4v3QV3KajaRJedzG(Xs4vFLKiqXwi30FJNrj8QB13BsGeG1rhXY3ZzXyaOc2rP8qLS9l6sEEYW3ZzXyaOc2rP8qLS9l6syLXbHmqi3smgaQGDukpujB)IHmq)EEY4GaOYQxaGQ)0)C0ZZq)ySKeKln(C5TJLCSvcrITsw5xLVT1atg)A8qnASBKg)jPbpHEnGzn482WGdOg8(1a9M72w40yFn6sAGx91DJ5xJT0Wk)AG3o2kHin47VgxsNHSrJfvVggpS)A8qn4jnKgOZrGQ8M7xyHeOV17xJEBq9bhDXMV)gJQxGEByWbuqLXZiqSYm9IYWbhj(TH4cNkboK1WVfinypW3Zzb6THbhqrxYZZq)ySKeKln(C5TFelFpNfO3ggCafO3C3UQLypW3Zzb5yReIsiiZgrxYZJVNZcYXwjeLy9Ygrx6iw(EolKMTboGRXs24SADjPodzJaGX60vyed0o2doiKbc5wcNL2YjgQX2c5JCT75jdaBwJNrchSaaVrjqc5VCyDqauz1lQf35NYgDuLVT1aVr)2ypH04eYvJMU7uJwGUenSH0aNTfbQHenAGihSav5n3VWcjqFR3VgGnRXZOlkRHUBiPlHgoK7cagRt3jhBLqKyReRx2GH(oMXC)clb6TjVdji8rU(tPFBOwLHCSvcrITsSEzdgEad26BmQEbc2zjyo9Nukdhc9cQmEgbIHT8iMXC)clb3X(tbHpY1Fk9Bd1A7czfpygKeXyPtd9uRTlWdg(gJQxu23hcL4nMvosqLXZiqv(2wdFtVrsdoVnO(GJ0ylnmnWaTIiNgCGmB0aVDSvcrxObiSAZRbJEn2xdPb604s6mKnAC4pTxJfPXPvGmcudE)Aq7FsJg)jPbN3MSXyAW2I0aoA8NKgTaDj(C5TRbBlsJmC0GZBdQp4OJxObiSAZRbeanCN9jnSsJl9I(tnKgOtdRa1GrVg)jPHXdbqAW2I040kqgPbN3ggCav5n3VWcjqFR3Vg92G6do6InFxMPxugo4iXVnex4ujWHSg(TaPb7b(EolKMTboGRXs24SADjPodzJaGX60vyed0UNhFpNfsZ2ahW1yjBCwTUKuNHSraWyD6kmIN2X(gJQxGEIXSjboB(fuz8mc8i2dKJTsisSvcbz2G1q)ySKeKlnTcWM14zKWqsxcnCihgY3Zzb5yReIsiiZgXqn2wOwbHVi3h)jyorSErIFD3qPHASTWqmkWJp(E7EEKJTsisSvI1lBWAOFmwscYLMwbyZA8msyiPlHgoKdd575SGCSvcrjwVSrmuJTfQvq4lY9XFcMteRxK4x3nuAOgBlmeJc84ZL3(rSYW3ZzbSO)eLKOXrs)clrxcRmVXO6fO3ggCafuz8mce7bheYaHClHZsB5ed1yBH8bd45HGDg)wGI)CwglHi6gncQmEgbILVNZI)CwglHi6gnc0BUBx1YwEzhMErz4GJeOTYDw60p6PznmephXMxCNFAOgBlKpY1E7yZlUZpnuJTf6km2E7EEGtFbffm5arhXEWbHmqi3sCBlWHatiPD2hjgQX2c5dgWZtgheavw9IB(N1QJQ8TTg(kI04sdclKgBPrB1lB0aVDSvcrAyfOgidaPXLYgl3QVTZyACPbHLgz4Ob(BX1(s50WkqnUuSf4qGAG3nsqU00q1RYBUFHfsG(wVFDrCtnqyDXMVFGVNZcYXwjeLy9YgXqn2wiFi8rU(tPFBipVdUtBWrO7ye7qUtBWrPFBORWZrpp3Pn4i09wEeRjLCNK7gwa2SgpJeidaLYWj5S0wovEZ9lSqc0369Rpnwo1aH1fB((b(EolihBLquI1lBed1yBH8HWh56pL(THWkJdcGkREXn)ZALN3b(EolUTf4qGjQrcYLMgQ(ev0GBLnj6syDqauz1lU5FwRo65DWDAdocDhJyhYDAdok9BdDfEo655oTbhHU3spp(EolCwAlNOlDeRjLCNK7gwa2SgpJeidaLYWj5S0woSh475Symaub7OuEOs2(fd1yBHU6aEUmmIHtVOmCWrc0w5olD6h90S2rS89CwmgaQGDukpujB)IUKNNm89CwmgaQGDukpujB)IU0rvEZ9lSqc0369RZDgl1aH1fB((b(EolihBLquI1lBed1yBH8HWh56pL(THWkJdcGkREXn)ZALN3b(EolUTf4qGjQrcYLMgQ(ev0GBLnj6syDqauz1lU5FwRo65DWDAdocDhJyhYDAdok9BdDfEo655oTbhHU3spp(EolCwAlNOlDeRjLCNK7gwa2SgpJeidaLYWj5S0woSh475Symaub7OuEOs2(fd1yBHUcpy575Symaub7OuEOs2(fDjSYm9IYWbhjqBL7S0PF0tZAEEYW3ZzXyaOc2rP8qLS9l6shv5BBn8vePbMfeV1awA4av5n3VWcjqFR3VMRnZcNemNiwViv(2wdFfrAW5TjVdPXd1qAGon4az2ObE7yReIUqd83IR9LYPXPH0GriKg)2qA8NwPHPbM1y)Pge(ix)jnyu(1aoAalMFnAREzJg4TJTsisJfPrxsL3C)clKa9TE)A0BtEh6InFNCSvcrITsSEzdwz475Symaub7OuEOs2(fDjppYXwjejqqMnPIW375ro2kHiHv(tfHV3Z7aFpNfCTzw4KG5eX6fj6sEEijIXsNg6PRAxiR4bRmoiaQS6faO6p9pEEijIXsNg6PRAxiRyDqauz1laq1F6FoILVNZcYXwjeLy9YgrxYZ7aFpNfolTLtmuJTf6kZ9lSeCh7pfe(ix)P0Vnew(EolCwAlNOlDuLVT1WxrKgywJ9NAa)tA4UisdUNR7uJfPXwAWbYSrd82XwjeDHg4Vfx7lLtd4OXd1qAGonAREzJg4TJTsisL3C)clKa9TE)AUJ9NQ8TTg(wJX(ZPRYBUFHfsG(wVF90RK5(fwj2I(lkRHUNng7pNoWh4deia]] )
    

end