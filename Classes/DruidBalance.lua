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


    spec:RegisterPack( "Balance", 20210801, [[di1fVfqikPEeePUeejTjs4tqQmkPKtjLAvaQ6vakZcIQBjfv2ff)cIyyaWXirTma0ZekAAus4AqkTnas9nasghaHZbOsRdqfZdG6EKi7tk0)ekePdkf0cfk5HqkMOqH6IqQQnkfv5JqKinsHcrCsHcwPuKxcrIAMus0nLIQYofk1pLIQQHcq0rfke1sfkKEQszQus6QsrXwfke(kejmwPO0EPu)vudM4WuTys6XcMmqxgzZs1NHKrRuDAvwnejIxdiZMu3wK2TKFdA4c54qQYYv8COMUQUUs2oe(oLy8quoVq16LcmFrSFuBRSTvT3a9NSJnabaavgaacaOSrzanavwzaAV9XJi7TipaKJIS3kpLS3ILR9kq2BrECn0bTTQ9ggUMazVT)Feg4GeKO6AVcuZHV0Gb197lvZbrsSCTxbQ52Uu0GKuqZ(NQJrA)0KsQU2RazEK92BQRt)XqzRAVb6pzhBacaaQmaaeaqzJYaAaQSY2B(63HJ922LIg7T9deKkBv7nqchS3ILR9kqSeJN1bYn10shNLyQmYzbGaaGkZnXnHMDVqryGd3uZXsdbbjqw2GAFyjwKNA4MAowqZUxOiqwEFqrF(6SeCmHz5HSeIh0u(9bf9yd3uZXsmkLcrqGSSQIceg7tCwq4Z5QAcZsRZqgKZs0qiY43h8AqrS0CnYs0qim43h8AqrTnCtnhlneb8azjAOGJ)RqXcsX4)olxNL7rhMLFNyXYaluSG(b9fHjd3uZXsZNdeXcAGfciqel)oXYw0n3JzXzrF)RjwsHdXsxti7u1elTUolXHlw2DWcDpl73ZY9SGV0L(9IGlSoolwUFNLy183qRYcWybnKMW)5AwAO(qvPu9iNL7rhilyGUO2gUPMJLMphiILui(zbD9d1(Nhk1VcJowWbQ85Gyw8OiDCwEilQqmML(HA)XSalDCd3uZXIvhYFwSkmLyb2zjwAFNLyP9DwIL23zXXS4SGJOW5Aw(5kGO3Wn1CS08hrfnS06mKb5SGum(VJCwqkg)3rolBVp9BO2SK6GelPWHyzi8PpQEwEilKp6JgwcWuv)Bo87ZBS30h(X2w1Edgrfn2w1o2kBBv7nQCvnbAhl7np8hSS3Sm(VBVbs4WCr)bl7na5qbh)Saqwqkg)3zXlqwCw2EFWRbfXcSyzZQSy5(DwI9HA)zP55elEbYsSGn0QSahw2EF63qSa)DASCyYElm3tZ52BTyHc6lctg9Q8jxeYEwssyHc6lctMRYyO2hwssyHc6lctMRYQWFNLKewOG(IWKXR45Iq2ZsBwuWs0qimkBSm(VZIcwSMLOHqyaOXY4)U9BhBaABv7nQCvnbAhl7np8hSS3WVp9Bi7TWCpnNBVznlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGSKKWI1SeGiOYR3uhQ9p3DILKewSMfCeP153hu0Jn43NUR1SOelkZssclwZY7AQEt5)AiCw11EfidvUQMazjjHLwSqb9fHjdgQ9jxeYEwssyHc6lctMRY6v5dljjSqb9fHjZvzv4VZsscluqFryY4v8Cri7zPT9M(kkhaT3qR9Bh7yABv7nQCvnbAhl7np8hSS3WVp41GIS3cZ90CU92SkQdhuKr11EfOmSNDTo)7xHcBOYv1eilkyjarqLxVPou7FU7elkybhrAD(9bf9yd(9P7AnlkXIY2B6ROCa0EdT2V9BVbsDFPFBRAhBLTTQ9Mh(dw2ByO2NSk5P2Bu5QAc0ow2VDSbOTvT3OYv1eODSS3cZ90CU92FPelaMLwSaqwaEw8WFWYyz8F3eC8N)lLybyS4H)GLb)(0VHmbh)5)sjwABV5H)GL9wW16Sh(dwz9HF7n9H)C5PK9gmIkASF7yhtBRAVrLRQjq7yzVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3WrKwNFFqrp2GFF6UwZsJSOmlkyPflwZY7AQEd(9rdhqdvUQMazjjHL31u9g8tATpzW56VHkxvtGS0MLKewWrKwNFFqrp2GFF6UwZsJSaq7nqchMl6pyzVTrpMLgcrFwGflXeySy5(D46zbCU(ZIxGSy5(Dw2EF0WbKfVazbGaJf4VtJLdt2Bi8jxEkzVD4Sdj73o2wHTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2B4isRZVpOOhBWVp9BiwAKfLT3ajCyUO)GL92g9ywcAYrqSyzNkw2EF63qSe8IL97zbGaJL3hu0JzXY(f2z5WSmKMq41ZshoS87elOFqFryILhYIkXs0qDAgcKfVazXY(f2zPFAnnS8qwco(T3q4tU8uYE7W5GMCeK9BhB0ABv7nQCvnbAhl7nyK9gME7np8hSS3q4Z5QAYEdHRxK9w0qimPqy1VHyjjHLOHqyWRQFdXssclrdHWGFFWRbfXssclrdHWGFF6UwZssclrdHW0xt8mSNj9QiwssyrD17MGNVkygk1VcZIsSOU6DtWZxfmGRX)dw2BGeomx0FWYElgHpNRQjw(D)zjStbGWSCDwIdxS4dXYvS4SGkaYYdzXrapqw(DIf89l)pyXILDAiwCw(5kGONf6dSCywwycKLRyrLElevSeC8JT3q4tU8uYE7QmQaO9BhBaTTvT3OYv1eODSS38WFWYEtLgmnaDfk7nqchMl6pyzV1myILyrdMgGUcflwUFNf00qKedvGf4WI3FAybnWcbeiILRybnnejXqfS3cZ90CU9wlwAXI1SeGiOYR3uhQ9p3DILKewSMLaeQbHwktawiGar5FNY4OBUhBwrS0MffSOU6DtWZxfmdL6xHzPrwugTSOGf1vVBghbvWfo3hQAqCZqP(vywamlwblkyXAwcqeu51Bqq1VhFyjjHLaebvE9geu97XhwuWI6Q3nbpFvWSIyrblQRE3mocQGlCUpu1G4MvelkyPflQRE3mocQGlCUpu1G4MHs9RWSaywuwzwAowqllaplZQOoCqrg8v9LoVhh)0CUHkxvtGSKKWI6Q3nbpFvWmuQFfMfaZIYkZssclkZcsybhrADE3XpXcGzrzdArllTzPnlkybHpNRQjZvzubq73o2akBRAVrLRQjq7yzVfM7P5C7n1vVBcE(QGzOu)kmlnYIYOLffS0IfRzzwf1HdkYGVQV05944NMZnu5QAcKLKewux9UzCeubx4CFOQbXndL6xHzbWSOmGILMJfaYcWZI6Q3nQAieuVWVzfXIcwux9UzCeubx4CFOQbXnRiwAZssclQqmMffS0pu7FEOu)kmlaMfaIw7nqchMl6pyzVbiHplwUFNfNf00qKedvGLF3FwoCHUNfNfa5sJ9HLObgyboSyzNkw(DIL(HA)z5WS4QW1ZYdzHkq7np8hSS3IG)bl73o2acBRAVrLRQjq7yzVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3c0PzPflTyPFO2)8qP(vywAowugTS0CSeGqni0szcE(QGzOu)kmlTzbjSOmGaaS0MfLyjqNMLwS0IL(HA)ZdL6xHzP5yrz0YsZXsac1GqlLjaleqGO8VtzC0n3JnGRX)dwS0CSeGqni0szcWcbeik)7ughDZ9yZqP(vywAZcsyrzabayPnlkyXAwg)aZecQEJdcIneYo8JzjjHLaeQbHwktWZxfmdL6xHzPrwU6PjcQ9NaZ9d1(Nhk1VcZssclbiudcTuMaSqabIY)oLXr3Cp2muQFfMLgz5QNMiO2Fcm3pu7FEOu)kmlnhlkdawssyXAwcqeu51BQd1(N7ozVbs4WCr)bl7n046Ws7pHzXYo970WYcFfkwqdSqabIyPGwyXYP1S4An0clXHlwEil4)0Awco(z53jwWEkXINcx1ZcSZcAGfciqeWqtdrsmubwco(X2Bi8jxEkzVfGfciqugKWXRG9BhBGRTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2BTyPFO2)8qP(vywAKfLrlljjSm(bMjeu9gheeBUILgzbTaGL2SOGLwS0ILwSqO36IIiqdLgfFixNHdy5vGyrblTyjaHAqOLYqPrXhY1z4awEfiZqP(vywamlkdObaljjSeGiOYR3GGQFp(WIcwcqOgeAPmuAu8HCDgoGLxbYmuQFfMfaZIYaAaflaJLwSOSYSa8SmRI6WbfzWx1x68EC8tZ5gQCvnbYsBwAZIcwSMLaeQbHwkdLgfFixNHdy5vGmd5GXzPnljjSqO36IIiqdgU0A6)RqLNLACwuWslwSMLaebvE9M6qT)5UtSKKWsac1GqlLbdxAn9)vOYZsnEoMwbAbeaqzZqP(vywamlkRSvWsBwssyPflbiudcTugvAW0a0vOmd5GXzjjHfRzz8az(bQ1S0MffS0ILwSqO36IIiqZv4WSExvtz0B51VsZGeIlqSOGLwSeGqni0szUchM17QAkJElV(vAgKqCbYmKdgNLKew8WFWYCfomR3v1ug9wE9R0miH4cKb8WUQMazPnlTzjjHLwSqO36IIiqdE3bHwiWmCuZWE(HtkvplkyjaHAqOLY8WjLQNaZxHpu7FoMOfTXeGkBgk1VcZsBwssyPflTybHpNRQjdSYlmL)5kGONfLyrzwssybHpNRQjdSYlmL)5kGONfLyjMS0MffS0ILFUci6nVYMHCW45aeQbHwkwssy5NRaIEZRSjaHAqOLYmuQFfMLgz5QNMiO2Fcm3pu7FEOu)kmlnhlkdawAZsscli85CvnzGvEHP8pxbe9SOelaKffS0ILFUci6npand5GXZbiudcTuSKKWYpxbe9MhGMaeQbHwkZqP(vywAKLREAIGA)jWC)qT)5Hs9RWS0CSOmayPnljjSGWNZv1Kbw5fMY)Cfq0ZIsSaawAZsBwAZssclbicQ86nafFoVyPnljjSOcXywuWs)qT)5Hs9RWSaywux9Uj45RcgW14)bl7nqchMl6pyzV1mycKLhYciP94S87ellSJIyb2zbnnejXqfyXYovSSWxHIfq4svtSalwwyIfVazjAieu9SSWokIfl7uXIxS4GGSqiO6z5WS4QW1ZYdzb8i7ne(KlpLS3cG5aSaV)GL9BhBLbGTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2BwZcgU0QxbA(9506mMiGOXqLRQjqwssyPFO2)8qP(vywAKfacaaWssclQqmMffS0pu7FEOu)kmlaMfaIwwaglTyXkaalnhlQRE387ZP1zmrarJb)EaiwaEwailTzjjHf1vVB(9506mMiGOXGFpaelnYsmbeS0CS0ILzvuhoOid(Q(sN3JJFAo3qLRQjqwaEwqllTT3ajCyUO)GL9wmcFoxvtSSWeilpKfqs7XzXR4S8ZvarpMfVazjaIzXYovSyXV)kuS0HdlEXc6VI2HZ5SenWG9gcFYLNs2B)(CADgteq0KT43B)2XwzLTTQ9gvUQMaTJL9giHdZf9hSS3AgmXc6NgfFixZsZ)awEfiwaiaWuaZIk1HdXIZcAAisIHkWYctg7TYtj7nknk(qUodhWYRazVfM7P5C7TaeQbHwktWZxfmdL6xHzbWSaqaWIcwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlaMfacawuWslwq4Z5QAY87ZP1zmrart2IFpljjSOU6DZVpNwNXebeng87bGyPrwIjaybyS0ILzvuhoOid(Q(sN3JJFAo3qLRQjqwaEwa0S0ML2SOGfe(CUQMmxLrfazjjHfvigZIcw6hQ9ppuQFfMfaZsmbu2BE4pyzVrPrXhY1z4awEfi73o2kdqBRAVrLRQjq7yzVbs4WCr)bl7TMbtSSbxAn9xHILy0LACwa0ykGzrL6WHyXzbnnejXqfyzHjJ9w5PK9ggU0A6)RqLNLAC7TWCpnNBV1ILaeQbHwktWZxfmdL6xHzbWSaOzrblwZsaIGkVEdcQ(94dlkyXAwcqeu51BQd1(N7oXssclbicQ86n1HA)ZDNyrblbiudcTuMaSqabIY)oLXr3Cp2muQFfMfaZcGMffS0Ife(CUQMmbyHaceLbjC8kWssclbiudcTuMGNVkygk1VcZcGzbqZsBwssyjarqLxVbbv)E8HffS0IfRzzwf1HdkYGVQV05944NMZnu5QAcKffSeGqni0szcE(QGzOu)kmlaMfanljjSOU6DZ4iOcUW5(qvdIBgk1VcZcGzrzRGfGXslwqllaple6TUOic0Cf(Nv4HdodEiUIYQKwZsBwuWI6Q3nJJGk4cN7dvniUzfXsBwssyPFO2)8qP(vywamlaeTSKKWcHERlkIanuAu8HCDgoGLxbIffSeGqni0szO0O4d56mCalVcKzOu)kmlnYcabalTzrbli85CvnzUkJkaYIcwSMfc9wxuebAUchM17QAkJElV(vAgKqCbILKewcqOgeAPmxHdZ6DvnLrVLx)kndsiUazgk1VcZsJSaqaWssclQqmMffS0pu7FEOu)kmlaMfaca7np8hSS3WWLwt)FfQ8SuJB)2Xw5yABv7nQCvnbAhl7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M6Q3nbpFvWmuQFfMLgzrz0YIcwAXI1SmRI6WbfzWx1x68EC8tZ5gQCvnbYssclQRE3mocQGlCUpu1G4MHs9RWSayLyrzaYcWyPflXKfGNf1vVBu1qiOEHFZkIL2SamwAXslwaeS0CSGwwaEwux9UrvdHG6f(nRiwAZcWZcHERlkIanxH)zfE4GZGhIROSkP1S0MffSOU6DZ4iOcUW5(qvdIBwrS0MLKewuHymlkyPFO2)8qP(vywamlaeTSKKWcHERlkIanuAu8HCDgoGLxbIffSeGqni0szO0O4d56mCalVcKzOu)kS9giHdZf9hSS3AO2IhhZYctSedXihJzXY97SGMgIKyOc2Bi8jxEkzVDOhyoalW7pyz)2XwzRW2Q2Bu5QAc0ow2BE4pyzVDfomR3v1ug9wE9R0miH4cK9wyUNMZT3q4Z5QAYCOhyoalW7pyXIcwq4Z5QAYCvgva0ER8uYE7kCywVRQPm6T86xPzqcXfi73o2kJwBRAVrLRQjq7yzVbs4WCr)bl7TMbtSmhQ9NfvQdhILai2ER8uYEdV7GqleygoQzyp)WjLQ3Elm3tZ52BTyjaHAqOLYe88vbZqoyCwuWI1SeGiOYR3uhQ9p3DIffSGWNZv1K53NtRZyIaIMSf)EwssyjarqLxVPou7FU7elkyjaHAqOLYeGfciqu(3Pmo6M7XMHCW4SOGLwSGWNZv1KjaleqGOmiHJxbwssyjaHAqOLYe88vbZqoyCwAZsBwuWci8n4v1VHm)fa6kuSOGLwSacFd(jT2NCx7dz(la0vOyjjHfRz5DnvVb)Kw7tUR9Hmu5QAcKLKewWrKwNFFqrp2GFF63qS0ilXKL2SOGLwSacFtkew9BiZFbGUcflTzrblTybHpNRQjZHZoKyjjHLzvuhoOiJQR9kqzyp7AD(3Vcf2qLRQjqwssyXX)46Ce0cnS0OsSaCbaljjSOU6DJQgcb1l8BwrS0MffS0ILaeQbHwkJknyAa6kuMHCW4SKKWI1SmEGm)a1AwAZIcwSMfc9wxuebAUchM17QAkJElV(vAgKqCbILKewi0BDrreO5kCywVRQPm6T86xPzqcXfiwuWslwcqOgeAPmxHdZ6DvnLrVLx)kndsiUazgk1VcZsJSetaWssclbiudcTugvAW0a0vOmdL6xHzPrwIjayPnlkyXAwux9Uj45RcMveljjSOcXywuWs)qT)5Hs9RWSaywScayV5H)GL9gE3bHwiWmCuZWE(HtkvV9BhBLb02w1EJkxvtG2XYEdKWH5I(dw2BwD)WSCywCwg)3PHfs7QWXFIflECwEilPoqelUwZcSyzHjwWV)S8ZvarpMLhYIkXI(kcKLvelwUFNf00qKedvGfVazbnWcbeiIfVazzHjw(DIfawGSG1WNfyXsaKLRZIk83z5NRaIEml(qSalwwyIf87pl)Cfq0JT3cZ90CU9wlwq4Z5QAYaR8ct5FUci6zXALyrzwuWI1S8ZvarV5bOzihmEoaHAqOLILKewAXccFoxvtgyLxyk)ZvarplkXIYSKKWccFoxvtgyLxyk)ZvarplkXsmzPnlkyPflQRE3e88vbZkIffS0IfRzjarqLxVbbv)E8HLKewux9UzCeubx4CFOQbXndL6xHzbyS0If0YcWZYSkQdhuKbFvFPZ7XXpnNBOYv1eilTzbWkXYpxbe9MxzJ6Q3ZGRX)dwSOGf1vVBghbvWfo3hQAqCZkILKewux9UzCeubx4CFOQbXZ4R6lDEpo(P5CZkIL2SKKWsac1GqlLj45RcMHs9RWSamwailnYYpxbe9Mxztac1GqlLbCn(FWIffSynlQRE3e88vbZkIffS0IfRzjarqLxVPou7FU7eljjSynli85CvnzcWcbeikds44vGL2SOGfRzjarqLxVbO4Z5fljjSeGiOYR3uhQ9p3DIffSGWNZv1KjaleqGOmiHJxbwuWsac1GqlLjaleqGO8VtzC0n3JnRiwuWI1SeGqni0szcE(QGzfXIcwAXslwux9UHc6lctz9Q8XmuQFfMLgzrzaWssclQRE3qb9fHPmgQ9XmuQFfMLgzrzaWsBwuWI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYssclTyrD17gvx7vGYWE2168VFfkCU8FnKb)EaiwuIf0YssclQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daXIsSaiyPnlTzjjHf1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyPnljjS0pu7FEOu)kmlaMfacawssybHpNRQjdSYlmL)5kGONfLybaS0MffSGWNZv1K5QmQaO9gwdFS92pxbe9kBV5H)GL92pxbe9kB)2XwzaLTvT3OYv1eODSS38WFWYE7NRaIEaAVfM7P5C7TwSGWNZv1Kbw5fMY)Cfq0ZI1kXcazrblwZYpxbe9MxzZqoy8Cac1GqlfljjSGWNZv1Kbw5fMY)Cfq0ZIsSaqwuWslwux9Uj45RcMvelkyPflwZsaIGkVEdcQ(94dljjSOU6DZ4iOcUW5(qvdIBgk1VcZcWyPflOLfGNLzvuhoOid(Q(sN3JJFAo3qLRQjqwAZcGvILFUci6npanQREpdUg)pyXIcwux9UzCeubx4CFOQbXnRiwssyrD17MXrqfCHZ9HQgepJVQV05944NMZnRiwAZssclbiudcTuMGNVkygk1VcZcWybGS0il)Cfq0BEaAcqOgeAPmGRX)dwSOGfRzrD17MGNVkywrSOGLwSynlbicQ86n1HA)ZDNyjjHfRzbHpNRQjtawiGarzqchVcS0MffSynlbicQ86nafFoVyrblTyXAwux9Uj45RcMveljjSynlbicQ86niO63JpS0MLKewcqeu51BQd1(N7oXIcwq4Z5QAYeGfciqugKWXRalkyjaHAqOLYeGfciqu(3Pmo6M7XMvelkyXAwcqOgeAPmbpFvWSIyrblTyPflQRE3qb9fHPSEv(ygk1VcZsJSOmayjjHf1vVBOG(IWugd1(ygk1VcZsJSOmayPnlkyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazjjHLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelkXcAzjjHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyrjwaeS0ML2S0MLKewux9UbORahcmtPrql0Ks1NPIguxdiZkILKewuHymlkyPFO2)8qP(vywamlaeaSKKWccFoxvtgyLxyk)ZvarplkXcayPnlkybHpNRQjZvzubq7nSg(y7TFUci6bO9BhBLbe2w1EJkxvtG2XYEdKWH5I(dw2BndMWS4AnlWFNgwGfllmXY9ukMfyXsa0EZd)bl7TfMY3tPy73o2kdCTTQ9gvUQMaTJL9giHdZf9hSS3IXu4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOoS9Mh(dw2BZQYE4pyL1h(T3W)CH3o2kBVfM7P5C7ne(CUQMmho7qYEtF4pxEkzV5qY(TJnabGTvT3OYv1eODSS3cZ90CU92SkQdhuKr11EfOmSNDTo)7xHcBi0BDrreO9g(Nl82Xwz7np8hSS3MvL9WFWkRp8BVPp8NlpLS3uH(B)2XgGkBBv7nQCvnbAhl7np8hSS3MvL9WFWkRp8BVPp8NlpLS3WV9B)2BQq)TTQDSv22Q2Bu5QAc0ow2BE4pyzVnocQGlCUpu1G42BGeomx0FWYER5nu1G4Sy5(Dwqtdrsmub7TWCpnNBVPU6DtWZxfmdL6xHzPrwugT2VDSbOTvT3OYv1eODSS38WFWYEZb9O)qqzSfFsT3cXdAk)(GIESDSv2Elm3tZ52BQRE3O6AVcug2ZUwN)9RqHZL)RHm43daXcGzbqWIcwux9Ur11EfOmSNDTo)7xHcN9j4fzWVhaIfaZcGGffS0IfRzbe(gh0J(dbLXw8jnd6PokY8xaORqXIcwSMfp8hSmoOh9hckJT4tAg0tDuK5QCxFO2FwuWslwSMfq4BCqp6peugBXN08o5AZFbGUcfljjSacFJd6r)HGYyl(KM3jxBgk1VcZsJSetwAZssclGW34GE0FiOm2IpPzqp1rrg87bGybWSetwuWci8noOh9hckJT4tAg0tDuKzOu)kmlaMf0YIcwaHVXb9O)qqzSfFsZGEQJIm)fa6kuS02EdKWH5I(dw2BndMyPHGE0Fiiw2S4tklw2PIf)zrtyml)UxSyfSelydTkl43daHzXlqwEild1hcVZIZcGvcGSGFpaeloMfT)eloMLiigFQAIf4WYFPel3ZcgYY9S4ZCiimliLSWplE)PHfNLycmwWVhaIfczr3qy73o2X02Q2Bu5QAc0ow2BE4pyzVfGfciqu(3Pmo6M7X2BGeomx0FWYERzWelObwiGarSy5(DwqtdrsmubwSStflrqm(u1elEbYc83PXYHjwSC)ololXc2qRYI6Q3zXYovSas44v4ku2BH5EAo3EZAwaN1bAkyoaIzrblTyPfli85CvnzcWcbeikds44vGffSynlbiudcTuMGNVkygYbJZssclQRE3e88vbZkIL2SOGLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelkXcGGLKewux9Ur11EfOmSNDTo)7xHcN9j4fzWVhaIfLybqWsBwssyrfIXSOGL(HA)ZdL6xHzbWSOmayPT9BhBRW2Q2Bu5QAc0ow2BE4pyzV1xt8mSNj9Qi7nqchMl6pyzV18GOploMLFNyPFd(zbvaKLRy53jwCwIfSHwLflxbcTWcCyXY97S87eliLJpNxSOU6DwGdlwUFNfNfabWWuGLgc6r)HGyzZIpPS4filw87zPdhwqtdrsmubwUol3ZIfy9SOsSSIyXr5xXIk1HdXYVtSeaz5WS0V6W7eO9wyUNMZT3AXslwAXI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9aqS0ilaAwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EaiwAKfanlTzrblTyXAwcqeu51Bqq1VhFyjjHfRzrD17MXrqfCHZ9HQge3SIyPnlTzrblTybCwhOPG5aiMLKewcqOgeAPmbpFvWmuQFfMLgzbTaGLKewAXsaIGkVEtDO2)C3jwuWsac1GqlLjaleqGO8VtzC0n3JndL6xHzPrwqlayPnlTzPnljjS0Ifq4BCqp6peugBXN0mON6OiZqP(vywAKfablkyjaHAqOLYe88vbZqP(vywAKfLbalkyjarqLxVPOWa1WbKL2SKKWYvpnrqT)eyUFO2)8qP(vywamlacwuWI1SeGqni0szcE(QGzihmoljjSeGiOYR3au858IffSOU6DdqxboeyMsJGwOjLQ3SIyjjHLaebvE9geu97XhwuWI6Q3nJJGk4cN7dvniUzOu)kmlaMfGllkyrD17MXrqfCHZ9HQge3SISF7yJwBRAVrLRQjq7yzV5H)GL9wWRaPZQRE3Elm3tZ52BTyrD17gvx7vGYWE2168VFfkCU8FnKzOu)kmlnYcGYGwwssyrD17gvx7vGYWE2168VFfkC2NGxKzOu)kmlnYcGYGwwAZIcwAXsac1GqlLj45RcMHs9RWS0ilakwssyPflbiudcTugkncAHMSkSandL6xHzPrwauSOGfRzrD17gGUcCiWmLgbTqtkvFMkAqDnGmRiwuWsaIGkVEdqXNZlwAZsBwuWIJ)X15iOfAyPrLyjMaWEtD175Ytj7n87JgoG2BGeomx0FWYEdnEfinlBVpA4aYIL73zXzPilSelydTklQRENfVazbnnejXqfy5Wf6EwCv46z5HSOsSSWeO9BhBaTTvT3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BX4vAelBVp41GIWSy5(DwCwIfSHwLf1vVZI66zPGplw2PILiiuFfkw6WHf00qKedvGf4Wcs5RahcKLTOBUhBVfM7P5C7TwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelnYcazjjHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyPrwailTzrblTyjarqLxVPou7FU7eljjSeGqni0szcE(QGzOu)kmlnYcGILKewSMfe(CUQMmbWCawG3FWIffSynlbicQ86nafFoVyjjHLwSeGqni0szO0iOfAYQWc0muQFfMLgzbqXIcwSMf1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyrblbicQ86nafFoVyPnlTzrblTyXAwaHVPVM4zypt6vrM)caDfkwssyXAwcqOgeAPmbpFvWmKdgNLKewSMLaeQbHwktawiGar5FNY4OBUhBgYbJZsB73o2akBRAVrLRQjq7yzV5H)GL9g(9bVguK9giHdZf9hSS3IXR0iw2EFWRbfHzrL6WHybnWcbeiYElm3tZ52BTyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywqllkyXAwaN1bAkyoaIzrblTybHpNRQjtawiGarzqchVcSKKWsac1GqlLj45RcMHs9RWSaywqllTzrbli85CvnzcG5aSaV)GflTzrblwZci8n91epd7zsVkY8xaORqXIcwcqeu51BQd1(N7oXIcwSMfWzDGMcMdGywuWcf0xeMmxL9kolkyXX)46Ce0cnS0ilwbaSF7ydiSTQ9gvUQMaTJL9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYERflQRE3mocQGlCUpu1G4MHs9RWS0ilOLLKewSMf1vVBghbvWfo3hQAqCZkIL2SOGLwSOU6DdqxboeyMsJGwOjLQptfnOUgqMHs9RWSaywqfanPoYyPnlkyPflQRE3qb9fHPmgQ9XmuQFfMLgzbva0K6iJLKewux9UHc6lctz9Q8XmuQFfMLgzbva0K6iJL22BGeomx0FWYElgdl09SacFwaxZvOy53jwOcKfyNLyuhbvWfMLM3qvdIJCwaxZvOybORahcKfkncAHMuQEwGdlxXYVtSOD8ZcQailWolEXc6h0xeMS3q4tU8uYEde(5HqV1nukvp2(TJnW12Q2Bu5QAc0ow2BE4pyzVHxv)gYElm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyPrwugqZIcw8OCyNcaXIcwq4Z5QAYac)8qO36gkLQhBVfIh0u(9bf9y7yRS9BhBLbGTvT3OYv1eODSS38WFWYElfcR(nK9wyUNMZT3gQpeE3v1elky59bf9M)sP8dZGhXsJSOCmnOLffS4r5WofaIffSGWNZv1Kbe(5HqV1nukvp2ElepOP87dk6X2Xwz73o2kRSTvT3OYv1eODSS38WFWYEd)Kw7tUR9HS3cZ90CU92q9HW7UQMyrblVpOO38xkLFyg8iwAKfLb0Samwgk1VcZIcw8OCyNcaXIcwq4Z5QAYac)8qO36gkLQhBVfIh0u(9bf9y7yRS9BhBLbOTvT3OYv1eODSS38WFWYERdNaLH9C5)Ai7nqchMl6pyzV18GXMfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhBLJPTvT3OYv1eODSS38WFWYEJsJGwOjRclq7nqchMl6pyzVH(Prql0WsSGfilw2PIfxfUEwEilu90WIZsrwyjwWgAvwSCfi0clEbYc2rqS0HdlOPHijgQG9wyUNMZT3AXcf0xeMm6v5tUiK9SKKWcf0xeMmyO2NCri7zjjHfkOVimz8kEUiK9SKKWI6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(vywAKfaLbTSKKWI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(vywAKfaLbTSKKWIJ)X15iOfAyPrwaUaGffSeGqni0szcE(QGzihmolkyXAwaN1bAkyoaIzPnlkyPflbiudcTuMGNVkygk1VcZsJSetaWssclbiudcTuMGNVkygYbJZsBwssy5QNMiO2Fcm3pu7FEOu)kmlaMfLbG9BhBLTcBRAVrLRQjq7yzV5H)GL9wFnXZWEM0RIS3ajCyUO)GL9wZdI(SmhQ9NfvQdhILf(kuSGMgAVfM7P5C7TaeQbHwktWZxfmd5GXzrbli85CvnzcG5aSaV)GflkyPflo(hxNJGwOHLgzb4cawuWI1SeGiOYR3uhQ9p3DILKewcqeu51BQd1(N7oXIcwC8pUohbTqdlaMfRaaS0MffSynlbicQ86niO63JpSOGLwSynlbicQ86n1HA)ZDNyjjHLaeQbHwktawiGar5FNY4OBUhBgYbJZsBwuWI1SaoRd0uWCaeB)2Xwz0ABv7nQCvnbAhl7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M1SaoRd0uWCaeZIcwq4Z5QAYeaZbybE)blwuWslwAXIJ)X15iOfAyPrwaUaGffS0If1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyjjHfRzjarqLxVbO4Z5flTzjjHf1vVBu1qiOEHFZkIffSOU6DJQgcb1l8Bgk1VcZcGzrD17MGNVkyaxJ)hSyPnljjSC1tteu7pbM7hQ9ppuQFfMfaZI6Q3nbpFvWaUg)pyXssclbicQ86n1HA)ZDNyPnlkyPflwZsaIGkVEtDO2)C3jwssyPflo(hxNJGwOHfaZIvaawssybe(M(AINH9mPxfz(la0vOyPnlkyPfli85CvnzcWcbeikds44vGLKewcqOgeAPmbyHaceL)DkJJU5ESzihmolTzPT9giHdZf9hSS3qtdrsmubwSStfl(ZcWfaaJLgIbKS0coAOfAy539IfRaaS0qmGKfl3VZcAGfciquBwSC)oC9SOH4RqXYFPelxXsS0qiOEHFw8cKf9velRiwSC)olObwiGarSCDwUNfloMfqchVceO9gcFYLNs2BbWCawG3FWkRc93(TJTYaABRAVrLRQjq7yzVfM7P5C7ne(CUQMmbWCawG3FWkRc93EZd)bl7TaPj8FUo76dvLs1B)2XwzaLTvT3OYv1eODSS3cZ90CU9gcFoxvtMayoalW7pyLvH(BV5H)GL92vbFk)pyz)2XwzaHTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2BuqFryYCvwVkFyb4zbqWcsyXd)bld(9PFdziKrH1t5)sjwaglwZcf0xeMmxL1RYhwaEwAXcGMfGXY7AQEdgU0zyp)7uUdhc)gQCvnbYcWZsmzPnliHfp8hSmwg)3neYOW6P8FPelaJfayailiHfCeP15Dh)K9giHdZf9hSS3qF8FP(tyw2HwyjDf2zPHyajl(qSGYVIazjIgwWuawG2Bi8jxEkzV54iajnBuW(TJTYaxBRAVrLRQjq7yzV5H)GL9g(9bVguK9giHdZf9hSS3IXR0iw2EFWRbfHzXYovS87el9d1(ZYHzXvHRNLhYcvGiNL(qvdIZYHzXvHRNLhYcvGiNL4Wfl(qS4plaxaamwAigqYYvS4flOFqFryc5SGMgIKyOcSOD8JzXl4VtdlacGHPaMf4WsC4IflWLgKficAcEelPWHy539IforzaWsdXaswSStflXHlwSaxAWcDplBVp41GIyPGwS3cZ90CU9wlwU6PjcQ9NaZ9d1(Nhk1VcZcGzXkyjjHLwSOU6DZ4iOcUW5(qvdIBgk1VcZcGzbva0K6iJfGNLaDAwAXIJ)X15iOfAybjSetaWsBwuWI6Q3nJJGk4cN7dvniUzfXsBwAZssclTyXX)46Ce0cnSamwq4Z5QAY44iajnBuGfGNf1vVBOG(IWugd1(ygk1VcZcWybe(M(AINH9mPxfz(laeopuQFflapla0GwwAKfLvgaSKKWIJ)X15iOfAybySGWNZv1KXXrasA2OalaplQRE3qb9fHPSEv(ygk1VcZcWybe(M(AINH9mPxfz(laeopuQFflapla0GwwAKfLvgaS0MffSqb9fHjZvzVIZIcwAXI1SOU6DtWZxfmRiwssyXAwExt1BWVpA4aAOYv1eilTzrblTyPflwZsac1GqlLj45RcMveljjSeGiOYR3au858IffSynlbiudcTugkncAHMSkSanRiwAZssclbicQ86n1HA)ZDNyPnlkyPflwZsaIGkVEdcQ(94dljjSynlQRE3e88vbZkILKewC8pUohbTqdlnYcWfaS0MLKewAXY7AQEd(9rdhqdvUQMazrblQRE3e88vbZkIffS0If1vVBWVpA4aAWVhaIfaZsmzjjHfh)JRZrql0WsJSaCbalTzPnljjSOU6DtWZxfmRiwuWI1SOU6DZ4iOcUW5(qvdIBwrSOGfRz5DnvVb)(OHdOHkxvtG2VDSbiaSTQ9gvUQMaTJL9Mh(dw2BfzjNcHL9giHdZf9hSS3AgmXsZhewywUIfRCv(Wc6h0xeMyXlqwWocILyK46oWAElTMLMpiSyPdhwqtdrsmub7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzPrwiKrH1t5)sjwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Paq2VDSbOY2w1EJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywAKfczuy9u(VuIffS0ILaeQbHwktWZxfmdL6xHzPrwqlayjjHLaeQbHwktawiGar5FNY4OBUhBgk1VcZsJSGwaWsBwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Paq2BE4pyzVT76Eofcl73o2aeG2w1EJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywAKfczuy9u(VuIffS0ILaeQbHwktWZxfmdL6xHzPrwqlayjjHLaeQbHwktawiGar5FNY4OBUhBgk1VcZsJSGwaWsBwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Paq2BE4pyzV1xADofcl73o2amM2w1EJkxvtG2XYEdKWH5I(dw2Bifq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF7ydqRW2Q2Bu5QAc0ow2BE4pyzVHFF63q2BGeomx0FWYERzWelBVp9BiwEilrdmWYgu7dlOFqFryIf4WILDQy5kwGLoolw5Q8Hf0pOVimXIxGSSWelifq0NLObgWSCDwUIfRCv(Wc6h0xeMS3cZ90CU9gf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmEfpxeYEwssyrD17gl(mhCYWEM0RImRiwuWI6Q3nuqFrykRxLpMveljjS0If1vVBcE(QGzOu)kmlaMfp8hSmwg)3neYOW6P8FPelkyrD17MGNVkywrS02(TJnarRTvT38WFWYEZY4)U9gvUQMaTJL9BhBacOTTQ9gvUQMaTJL9Mh(dw2BZQYE4pyL1h(T30h(ZLNs2BDxR)9zz)2V9MdjBRAhBLTTQ9gvUQMaTJL9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYERflQRE38xkzbovgCipv9kqAmdL6xHzbWSGkaAsDKXcWybagLzjjHf1vVB(lLSaNkdoKNQEfinMHs9RWSayw8WFWYGFF63qgczuy9u(VuIfGXcamkZIcwAXcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmEfpxeYEwAZsBwuWI6Q3n)LswGtLbhYtvVcKgZkIffSmRI6Wbfz(lLSaNkdoKNQEfingQCvnbAVbs4WCr)bl7n046Ws7pHzXYo970WYVtSeJhYtd(h2PHf1vVZILtRzP7AnlWENfl3VFfl)oXsri7zj443EdHp5Ytj7nWH80SLtRZDxRZWE3(TJnaTTQ9gvUQMaTJL9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZAwOG(IWK5QmgQ9HffS0IfCeP153hu0Jn43N(nelnYcAzrblVRP6ny4sNH98Vt5oCi8BOYv1eiljjSGJiTo)(GIESb)(0VHyPrwauS02EdKWH5I(dw2BOX1HL2FcZILD63PHLT3h8AqrSCywSaNFNLGJ)RqXcebnSS9(0VHy5kwSYv5dlOFqFryYEdHp5Ytj7TdvbhkJFFWRbfz)2XoM2w1EJkxvtG2XYEZd)bl7TaSqabIY)oLXr3Cp2EdKWH5I(dw2BndMybnWcbeiIfl7uXI)SOjmMLF3lwqlayPHyajlEbYI(kILvelwUFNf00qKedvWElm3tZ52BwZc4SoqtbZbqmlkyPflTybHpNRQjtawiGarzqchVcSOGfRzjaHAqOLYe88vbZqoyCwssyrD17MGNVkywrS0MffS0If1vVBOG(IWuwVkFmdL6xHzPrwa0SKKWI6Q3nuqFrykJHAFmdL6xHzPrwa0S0MffS0IfRzzwf1HdkYO6AVcug2ZUwN)9RqHnu5QAcKLKewux9Ur11EfOmSNDTo)7xHcNl)xdzWVhaILgzjMSKKWI6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqS0ilXKL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrzaWIcwSMLaeQbHwktWZxfmd5GXzPT9BhBRW2Q2Bu5QAc0ow2BE4pyzVnocQGlCUpu1G42BGeomx0FWYERzWelnVHQgeNfl3VZcAAisIHkyVfM7P5C7n1vVBcE(QGzOu)kmlnYIYO1(TJnATTQ9gvUQMaTJL9Mh(dw2B4v1VHS3cXdAk)(GIESDSv2Elm3tZ52BTyzO(q4DxvtSKKWI6Q3nuqFrykJHAFmdL6xHzbWSetwuWcf0xeMmxLXqTpSOGLHs9RWSaywu2kyrblVRP6ny4sNH98Vt5oCi8BOYv1eilTzrblVpOO38xkLFyg8iwAKfLTcwAowWrKwNFFqrpMfGXYqP(vywuWslwOG(IWK5QSxXzjjHLHs9RWSaywqfanPoYyPT9giHdZf9hSS3AgmXY2Q63qSCflrEbsPxGfyXIxX)9RqXYV7pl6dbHzrzRatbmlEbYIMWywSC)olPWHy59bf9yw8cKf)z53jwOcKfyNfNLnO2hwq)G(IWel(ZIYwblykGzboSOjmMLHs9RUcfloMLhYsbFw2DexHILhYYq9HW7SaUMRqXIvUkFyb9d6lct2VDSb02w1EJkxvtG2XYEZd)bl7n8Q63q2BGeomx0FWYERzWelBRQFdXYdzz3rqS4SGsdvDnlpKLfMyjgIrogBVfM7P5C7ne(CUQMmh6bMdWc8(dwSOGLaeQbHwkZv4WSExvtz0B51VsZGeIlqMHCW4SOGfc9wxuebAUchM17QAkJElV(vAgKqCbY(TJnGY2Q2Bu5QAc0ow2BH5EAo3EZAwExt1BWpP1(KbNR)gQCvnbYIcwAXI6Q3n43NUR1MH6dH3DvnXIcwAXcoI0687dk6Xg87t31AwamlXKLKewSMLzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwAZssclVRP6ny4sNH98Vt5oCi8BOYv1eilkyrD17gkOVimLXqTpMHs9RWSaywIjlkyHc6lctMRYyO2hwuWI6Q3n43NUR1MHs9RWSaywauSOGfCeP153hu0Jn43NUR1S0OsSyfS0MffS0IfRzzwf1HdkYOJh8XX5UMO)kuzu6lnctgQCvnbYsscl)LsSGuzXkqllnYI6Q3n43NUR1MHs9RWSamwailTzrblVpOO38xkLFyg8iwAKf0AV5H)GL9g(9P7AT9BhBaHTvT3OYv1eODSS38WFWYEd)(0DT2EdKWH5I(dw2Bif3VZY2tATpSeJNR)SSWelWILailw2PILH6dH3DvnXI66zb)NwZIf)Ew6WHfRmEWhhZs0adS4filGWcDpllmXIk1HdXcAIXydlB)P1SSWelQuhoelObwiGarSGVkqS87(ZILtRzjAGbw8c(70WY27t31A7TWCpnNBV9UMQ3GFsR9jdox)nu5QAcKffSOU6Dd(9P7ATzO(q4DxvtSOGLwSynlZQOoCqrgD8Gpoo31e9xHkJsFPryYqLRQjqwssy5VuIfKklwbAzPrwScwAZIcwEFqrV5Vuk)Wm4rS0ilX0(TJnW12Q2Bu5QAc0ow2BE4pyzVHFF6UwBVbs4WCr)bl7nKI73zjgpKNQEfinSSWelBVpDxRz5HSaerrSSIy53jwux9olQXzX1yill8vOyz79P7AnlWIf0YcMcWceZcCyrtymldL6xDfk7TWCpnNBVnRI6Wbfz(lLSaNkdoKNQEfingQCvnbYIcwWrKwNFFqrp2GFF6UwZsJkXsmzrblTyXAwux9U5VuYcCQm4qEQ6vG0ywrSOGf1vVBWVpDxRnd1hcV7QAILKewAXccFoxvtgWH80SLtRZDxRZWENffS0If1vVBWVpDxRndL6xHzbWSetwssybhrAD(9bf9yd(9P7AnlnYcazrblVRP6n4N0AFYGZ1FdvUQMazrblQRE3GFF6UwBgk1VcZcGzbTS0ML2S02(TJTYaW2Q2Bu5QAc0ow2BWi7nm92BE4pyzVHWNZv1K9gcxVi7nh)JRZrql0WsJSaiaalnhlTyrzaWcWZI6Q3n)LswGtLbhYtvVcKgd(9aqS0MLMJLwSOU6Dd(9P7ATzOu)kmlaplXKfKWcoI068UJFIfGNfRz5DnvVb)Kw7tgCU(BOYv1eilTzP5yPflbiudcTug87t31AZqP(vywaEwIjliHfCeP15Dh)elaplVRP6n4N0AFYGZ1FdvUQMazPnlnhlTybe(M(AINH9mPxfzgk1VcZcWZcAzPnlkyPflQRE3GFF6UwBwrSKKWsac1GqlLb)(0DT2muQFfML22BGeomx0FWYEdnUoS0(tywSSt)onS4SS9(GxdkILfMyXYP1Se8fMyz79P7AnlpKLUR1Sa7DKZIxGSSWelBVp41GIy5HSaerrSeJhYtvVcKgwWVhaILvK9gcFYLNs2B43NUR1zlW6ZDxRZWE3(TJTYkBBv7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9wZGjw2EFWRbfXIL73zjgpKNQEfinS8qwaIOiwwrS87elQRENfl3VdxplAi(kuSS9(0DTMLv0FPelEbYYctSS9(GxdkIfyXIvamwIfSHwLf87bGWSSQ)0SyfS8(GIES9wyUNMZT3q4Z5QAYaoKNMTCADU7ADg27SOGfe(CUQMm43NUR1zlW6ZDxRZWENffSynli85CvnzoufCOm(9bVgueljjS0If1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGyPrwIjljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpaelnYsmzPnlkybhrAD(9bf9yd(9P7AnlaMfRGffSGWNZv1Kb)(0DToBbwFU7ADg272VDSvgG2w1EJkxvtG2XYEZd)bl7nh0J(dbLXw8j1ElepOP87dk6X2Xwz7TWCpnNBVznl)fa6kuSOGfRzXd)blJd6r)HGYyl(KMb9uhfzUk31hQ9NLKewaHVXb9O)qqzSfFsZGEQJIm43daXcGzjMSOGfq4BCqp6peugBXN0mON6OiZqP(vywamlX0EdKWH5I(dw2BndMybBXNuwWqw(D)zjoCXck6zj1rglRO)sjwuJZYcFfkwUNfhZI2FIfhZseeJpvnXcSyrtyml)UxSetwWVhacZcCybPKf(zXYovSetGXc(9aqywiKfDdz)2Xw5yABv7nQCvnbAhl7np8hSS3sHWQFdzVfIh0u(9bf9y7yRS9wyUNMZT3gQpeE3v1elky59bf9M)sP8dZGhXsJS0ILwSOSvWcWyPfl4isRZVpOOhBWVp9BiwaEwailaplQRE3qb9fHPSEv(ywrS0ML2Samwgk1VcZsBwqclTyrzwaglVRP6nVLRYPqyHnu5QAcKL2SOGLwSeGqni0szcE(QGzihmolkyXAwaN1bAkyoaIzrblTybHpNRQjtawiGarzqchVcSKKWsac1GqlLjaleqGO8VtzC0n3Jnd5GXzjjHfRzjarqLxVPou7FU7elTzjjHfCeP153hu0Jn43N(nelaMLwS0IfanlnhlTyrD17gkOVimL1RYhZkIfGNfaYsBwAZcWZslwuMfGXY7AQEZB5QCkewydvUQMazPnlTzrblwZcf0xeMmyO2NCri7zjjHLwSqb9fHjZvzmu7dljjS0IfkOVimzUkRc)DwssyHc6lctMRY6v5dlTzrblwZY7AQEdgU0zyp)7uUdhc)gQCvnbYssclQRE3enxkCapxN9j41fYrln2hdcxViwAujwaiAbalTzrblTybhrAD(9bf9yd(9PFdXcGzrzaWcWZslwuMfGXY7AQEZB5QCkewydvUQMazPnlTzrblo(hxNJGwOHLgzbTaGLMJf1vVBWVpDxRndL6xHzb4zbqZsBwuWslwSMf1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyjjHfkOVimzUkJHAFyjjHfRzjarqLxVbO4Z5flTzrblwZI6Q3nJJGk4cN7dvniEgFvFPZ7XXpnNBwr2BGeomx0FWYElgL6dH3zP5dcR(nelxNf00qKedvGLdZYqoyCKZYVtdXIpelAcJz539If0YY7dk6XSCflw5Q8Hf0pOVimXIL73zzd(npKZIMWyw(DVyrzaWc83PXYHjwUIfVIZc6h0xeMyboSSIy5HSGwwEFqrpMfvQdhIfNfRCv(Wc6h0xeMmSeJHf6EwgQpeENfW1CfkwqkFf4qGSG(Prql0Ks1ZYQ0egZYvSSb1(Wc6h0xeMSF7yRSvyBv7nQCvnbAhl7np8hSS36Wjqzypx(VgYEdKWH5I(dw2BndMyP5bJnlWILailwUFhUEwcEu0vOS3cZ90CU9MhLd7uai73o2kJwBRAVrLRQjq7yzVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3SMfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcwAXslwux9Ub)(0DT2SIyjjHL31u9g8tATpzW56VHkxvtGSKKWsaIGkVEtDO2)C3jwAZIcwAXI1SOU6DdgQX)fiZkIffSynlQRE3e88vbZkIffS0IfRz5DnvVPVM4zypt6vrgQCvnbYssclQRE3e88vbd4A8)GflnYsac1GqlLPVM4zypt6vrMHs9RWSamwaeS0MffSGWNZv1K53NtRZyIaIMSf)EwuWslwSMLaebvE9M6qT)5UtSKKWsac1GqlLjaleqGO8VtzC0n3JnRiwuWslwux9Ub)(0DT2muQFfMfaZcazjjHfRz5DnvVb)Kw7tgCU(BOYv1eilTzPnlky59bf9M)sP8dZGhXsJSOU6DtWZxfmGRX)dwSa8SaadGIL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyPT9gcFYLNs2BbWCawG3FWk7qY(TJTYaABRAVrLRQjq7yzV5H)GL9wG0e(pxND9HQsP6T3ajCyUO)GL9wZGjwqtdrsmubwGflbqwwLMWyw8cKf9vel3ZYkIfl3VZcAGfciqK9wyUNMZT3q4Z5QAYeaZbybE)bRSdj73o2kdOSTQ9gvUQMaTJL9wyUNMZT3q4Z5QAYeaZbybE)bRSdj7np8hSS3Uk4t5)bl73o2kdiSTQ9gvUQMaTJL9Mh(dw2BuAe0cnzvybAVbs4WCr)bl7TMbtSG(Prql0WsSGfilWILailwUFNLT3NUR1SSIyXlqwWocILoCybqU0yFyXlqwqtdrsmub7TWCpnNBVD1tteu7pbM7hQ9ppuQFfMfaZIYOLLKewAXI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIfaZcarlayjjHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelnQelaeTaGL2SOGf1vVBWVpDxRnRiwuWslwcqOgeAPmbpFvWmuQFfMLgzbTaGLKewaN1bAkyoaIzPT9BhBLbU2w1EJkxvtG2XYEZd)bl7n8tATp5U2hYElepOP87dk6X2Xwz7TWCpnNBVnuFi8URQjwuWYFPu(HzWJyPrwugTSOGfCeP153hu0Jn43N(nelaMfRGffS4r5WofaIffS0If1vVBcE(QGzOu)kmlnYIYaGLKewSMf1vVBcE(QGzfXsB7nqchMl6pyzVfJs9HW7S01(qSalwwrS8qwIjlVpOOhZIL73HRNf00qKedvGfv6kuS4QW1ZYdzHqw0nelEbYsbFwGiOj4rrxHY(TJnabGTvT3OYv1eODSS38WFWYERVM4zypt6vr2BGeomx0FWYERzWelnpi6ZY1z5k8bsS4flOFqFryIfVazrFfXY9SSIyXY97S4SaixASpSenWalEbYsdb9O)qqSSzXNu7TWCpnNBVrb9fHjZvzVIZIcw8OCyNcaXIcwux9UjAUu4aEUo7tWRlKJwASpgeUErSaywaiAbalkyPflGW34GE0FiOm2IpPzqp1rrM)caDfkwssyXAwcqeu51BkkmqnCazjjHfCeP153hu0JzPrwailTzrblTyrD17MXrqfCHZ9HQge3muQFfMfaZcWLLMJLwSGwwaEwMvrD4GIm4R6lDEpo(P5CdvUQMazPnlkyrD17MXrqfCHZ9HQge3SIyjjHfRzrD17MXrqfCHZ9HQge3SIyPnlkyPflwZsac1GqlLj45RcMveljjSOU6DZVpNwNXebeng87bGybWSOmAzrbl9d1(Nhk1VcZcGzbGaaaSOGL(HA)ZdL6xHzPrwugaaGLKewSMfmCPvVc087ZP1zmrarJHkxvtGS0MffS0IfmCPvVc087ZP1zmrarJHkxvtGSKKWsac1GqlLj45RcMHs9RWS0ilXeaS02(TJnav22Q2Bu5QAc0ow2BE4pyzVHFF6UwBVbs4WCr)bl7TMbtS4SS9(0DTMLM)I(DwIgyGLvPjmMLT3NUR1SCywC9qoyCwwrSahwIdxS4dXIRcxplpKficAcEelnediT3cZ90CU9M6Q3nWI(DCoIMaf9hSmRiwuWslwux9Ub)(0DT2muFi8URQjwssyXX)46Ce0cnS0ilaxaWsB73o2aeG2w1EJkxvtG2XYEZd)bl7n87t31A7nqchMl6pyzVfJxPrS0qmGKfvQdhIf0aleqGiwSC)olBVpDxRzXlqw(DQyz79bVguK9wyUNMZT3cqeu51BQd1(N7oXIcwSML31u9g8tATpzW56VHkxvtGSOGLwSGWNZv1KjaleqGOmiHJxbwssyjaHAqOLYe88vbZkILKewux9Uj45RcMvelTzrblbiudcTuMaSqabIY)oLXr3Cp2muQFfMfaZcQaOj1rglaplb60S0Ifh)JRZrql0WcsybTaGL2SOGf1vVBWVpDxRndL6xHzbWSyfSOGfRzbCwhOPG5ai2(TJnaJPTvT3OYv1eODSS3cZ90CU9waIGkVEtDO2)C3jwuWslwq4Z5QAYeGfciqugKWXRaljjSeGqni0szcE(QGzfXssclQRE3e88vbZkIL2SOGLaeQbHwktawiGar5FNY4OBUhBgk1VcZcGzbqZIcwux9Ub)(0DT2SIyrbluqFryYCv2R4SOGfRzbHpNRQjZHQGdLXVp41GIyrblwZc4SoqtbZbqS9Mh(dw2B43h8Aqr2VDSbOvyBv7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9wZGjw2EFWRbfXIL73zXlwA(l63zjAGbwGdlxNL4Wf6azbIGMGhXsdXaswSC)olXHRHLIq2ZsWXVHLgQXqwaxPrS0qmGKf)z53jwOcKfyNLFNyjgbv)E8Hf1vVZY1zz79P7AnlwGlnyHUNLUR1Sa7DwGdlXHlw8HybwSaqwEFqrp2Elm3tZ52BQRE3al63X5GM8jJ4WhSmRiwssyPflwZc(9PFdz8OCyNcaXIcwSMfe(CUQMmhQcoug)(GxdkILKewAXI6Q3nbpFvWmuQFfMfaZcAzrblQRE3e88vbZkILKewAXslwux9Uj45RcMHs9RWSaywqfanPoYyb4zjqNMLwS44FCDocAHgwqclXeaS0MffSOU6DtWZxfmRiwssyrD17MXrqfCHZ9HQgepJVQV05944NMZndL6xHzbWSGkaAsDKXcWZsGonlTyXX)46Ce0cnSGewIjayPnlkyrD17MXrqfCHZ9HQgepJVQV05944NMZnRiwAZIcwcqeu51Bqq1VhFyPnlTzrblTybhrAD(9bf9yd(9P7AnlaMLyYsscli85CvnzWVpDxRZwG1N7UwNH9olTzPnlkyXAwq4Z5QAYCOk4qz87dEnOiwuWslwSMLzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwssybhrAD(9bf9yd(9P7AnlaMLyYsB73o2aeT2w1EJkxvtG2XYEZd)bl7TISKtHWYEdKWH5I(dw2BndMyP5dclmlxXYgu7dlOFqFryIfVazb7iiwAElTMLMpiSyPdhwqtdrsmub7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZsJSqiJcRNY)LsSKKWslwc7(GIWSOelaKffSmuy3huu(VuIfaZcAzPnljjSe29bfHzrjwIjlTzrblEuoStbGSF7ydqaTTvT3OYv1eODSS3cZ90CU9wlwux9UHc6lctzmu7JzOu)kmlnYcHmkSEk)xkXssclTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjMS0MffS4r5WofaIffS0If1vVBghbvWfo3hQAqCZqP(vywamlOLffSOU6DZ4iOcUW5(qvdIBwrSOGfRzzwf1HdkYGVQV05944NMZnu5QAcKLKewSMf1vVBghbvWfo3hQAqCZkIL22BE4pyzVT76Eofcl73o2aeqzBv7nQCvnbAhl7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZsJSqiJcRNY)LsSOGLwSeGqni0szcE(QGzOu)kmlnYcAbaljjSeGqni0szcWcbeik)7ughDZ9yZqP(vywAKf0cawAZssclTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjMS0MffS4r5WofaIffS0If1vVBghbvWfo3hQAqCZqP(vywamlOLffSOU6DZ4iOcUW5(qvdIBwrSOGfRzzwf1HdkYGVQV05944NMZnu5QAcKLKewSMf1vVBghbvWfo3hQAqCZkIL22BE4pyzV1xADofcl73o2aeqyBv7nQCvnbAhl7nqchMl6pyzV1myIfKci6ZcSybnXy7np8hSS3S4ZCWjd7zsVkY(TJnabU2w1EJkxvtG2XYEdgzVHP3EZd)bl7ne(CUQMS3q46fzVHJiTo)(GIESb)(0VHyPrwScwaglDneoS0ILuh)0epJW1lIfGNfLbaaybjSaqaWsBwaglDneoS0If1vVBWVp41GIYuAe0cnPu9zmu7Jb)EaiwqclwblTT3ajCyUO)GL9gACDyP9NWSyzN(DAy5HSSWelBVp9BiwUILnO2hwSSFHDwoml(ZcAz59bf9yGPmlD4WcHGM4SaqaGuzj1XpnXzboSyfSS9(GxdkIf0pncAHMuQEwWVhacBVHWNC5PK9g(9PFdLVkJHAFSF7yhtayBv7nQCvnbAhl7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MYSGewWrKwN3D8tSaywailnhlTybagaYcWZslwWrKwNFFqrp2GFF63qS0CSOmlTzb4zPflkZcWy5DnvVbdx6mSN)Dk3HdHFdvUQMazb4zrzdAzPnlTzbySaaJYOLfGNf1vVBghbvWfo3hQAqCZqP(vy7nqchMl6pyzVHgxhwA)jmlw2PFNgwEilifJ)7SaUMRqXsZBOQbXT3q4tU8uYEZY4)E(QCFOQbXTF7yhtLTTQ9gvUQMaTJL9Mh(dw2Bwg)3T3ajCyUO)GL9wZGjwqkg)3z5kw2GAFyb9d6lctSahwUolfKLT3N(nelwoTML(9SC1dzbnnejXqfyXR4PWHS3cZ90CU9wlwOG(IWKrVkFYfHSNLKewOG(IWKXR45Iq2ZIcwq4Z5QAYC4CqtocIL2SOGLwS8(GIEZFPu(HzWJyPrwScwssyHc6lctg9Q8jFvgGSKKWs)qT)5Hs9RWSaywugaS0MLKewux9UHc6lctzmu7JzOu)kmlaMfp8hSm43N(nKHqgfwpL)lLyrblQRE3qb9fHPmgQ9XSIyjjHfkOVimzUkJHAFyrblwZccFoxvtg87t)gkFvgd1(WssclQRE3e88vbZqP(vywamlE4pyzWVp9BidHmkSEk)xkXIcwSMfe(CUQMmhoh0KJGyrblQRE3e88vbZqP(vywamleYOW6P8FPelkyrD17MGNVkywrSKKWI6Q3nJJGk4cN7dvniUzfXIcwq4Z5QAYyz8FpFvUpu1G4SKKWI1SGWNZv1K5W5GMCeelkyrD17MGNVkygk1VcZsJSqiJcRNY)Ls2VDSJjaTTQ9gvUQMaTJL9giHdZf9hSS3AgmXY27t)gILRZYvSyLRYhwq)G(IWeYz5kw2GAFyb9d6lctSalwScGXY7dk6XSahwEilrdmWYgu7dlOFqFryYEZd)bl7n87t)gY(TJDmJPTvT3OYv1eODSS3ajCyUO)GL9wZZ16FFw2BE4pyzVnRk7H)GvwF43EtF4pxEkzV1DT(3NL9B)2BDxR)9zzBv7yRSTvT3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BBVp41GIyPdhwsHiOuQEwwLMWyww4RqXsSGn0Q2BH5EAo3EZAwMvrD4GImQU2RaLH9SR15F)kuydHERlkIaTF7ydqBRAVrLRQjq7yzV5H)GL9gEv9Bi7Tq8GMYVpOOhBhBLT3cZ90CU9gi8nPqy1VHmdL6xHzPrwgk1VcZcWZcabiliHfLbe2BGeomx0FWYEdno(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9gw2wv)gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQFdXc4A8)GL9Bh7yABv7np8hSS3sHWQFdzVrLRQjq7yz)2V9g(TTQDSv22Q2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7TMbtSS9(GxdkILhYcqefXYkILFNyjgpKNQEfinSOU6DwUol3ZIf4sdYcHSOBiwuPoCiw6xD49RqXYVtSueYEwco(zboS8qwaxPrSOsD4qSGgyHacezVfM7P5C7TzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwuWslwOG(IWK5QSxXzrblwZslwAXI6Q3n)LswGtLbhYtvVcKgZqP(vywAKfp8hSmwg)3neYOW6P8FPelaJfayuMffS0IfkOVimzUkRc)DwssyHc6lctMRYyO2hwssyHc6lctg9Q8jxeYEwAZssclQRE38xkzbovgCipv9kqAmdL6xHzPrw8WFWYGFF63qgczuy9u(VuIfGXcamkZIcwAXcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmEfpxeYEwAZsBwssyXAwux9U5VuYcCQm4qEQ6vG0ywrS0MLKewAXI6Q3nbpFvWSIyjjHfe(CUQMmbyHaceLbjC8kWsBwuWsac1GqlLjaleqGO8VtzC0n3Jnd5GXzrblbicQ86n1HA)ZDNyPnlkyPflwZsaIGkVEdqXNZlwssyjaHAqOLYqPrql0KvHfOzOu)kmlnYcGGL2SOGLwSOU6DtWZxfmRiwssyXAwcqOgeAPmbpFvWmKdgNL22VDSbOTvT3OYv1eODSS38WFWYEZb9O)qqzSfFsT3cXdAk)(GIESDSv2Elm3tZ52BwZci8noOh9hckJT4tAg0tDuK5VaqxHIffSynlE4pyzCqp6peugBXN0mON6OiZv5U(qT)SOGLwSynlGW34GE0FiOm2IpP5DY1M)caDfkwssybe(gh0J(dbLXw8jnVtU2muQFfMLgzbTS0MLKewaHVXb9O)qqzSfFsZGEQJIm43daXcGzjMSOGfq4BCqp6peugBXN0mON6OiZqP(vywamlXKffSacFJd6r)HGYyl(KMb9uhfz(la0vOS3ajCyUO)GL9wZGjwAiOh9hcILnl(KYILDQy53PHy5WSuqw8WFiiwWw8jf5S4yw0(tS4ywIGy8PQjwGflyl(KYIL73zbGSahw6KfAyb)EaimlWHfyXIZsmbglyl(KYcgYYV7pl)oXsrwybBXNuw8zoeeMfKsw4NfV)0WYV7plyl(KYcHSOBiS9Bh7yABv7nQCvnbAhl7np8hSS3cWcbeik)7ughDZ9y7nqchMl6pyzV1mycZcAGfciqelxNf00qKedvGLdZYkIf4WsC4IfFiwajC8kCfkwqtdrsmubwSC)olObwiGarS4filXHlw8HyrL0qlSyfaGLgIbK2BH5EAo3EZAwaN1bAkyoaIzrblTyPfli85CvnzcWcbeikds44vGffSynlbiudcTuMGNVkygYbJZIcwSMLzvuhoOit0CPWb8CD2NGxxihT0yFmu5QAcKLKewux9Uj45RcMvelTzrblo(hxNJGwOHfaRelwbayrblTyrD17gkOVimL1RYhZqP(vywAKfLbaljjSOU6Ddf0xeMYyO2hZqP(vywAKfLbalTzjjHfvigZIcw6hQ9ppuQFfMfaZIYaGffSynlbiudcTuMGNVkygYbJZsB73o2wHTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2BTyrD17MXrqfCHZ9HQge3muQFfMLgzbTSKKWI1SOU6DZ4iOcUW5(qvdIBwrS0MffSynlQRE3mocQGlCUpu1G4z8v9LoVhh)0CUzfXIcwAXI6Q3naDf4qGzkncAHMuQ(mv0G6Aazgk1VcZcGzbva0K6iJL2SOGLwSOU6Ddf0xeMYyO2hZqP(vywAKfubqtQJmwssyrD17gkOVimL1RYhZqP(vywAKfubqtQJmwssyPflwZI6Q3nuqFrykRxLpMveljjSynlQRE3qb9fHPmgQ9XSIyPnlkyXAwExt1BWqn(VazOYv1eilTT3ajCyUO)GL9gAGf49hSyPdhwCTMfq4Jz539NLuhicZcEnel)ofNfFOcDpld1hcVtGSyzNkwIrDeubxywAEdvniol7oMfnHXS87EXcAzbtbmldL6xDfkwGdl)oXcqXNZlwux9olhMfxfUEwEilDxRzb27Sahw8kolOFqFryILdZIRcxplpKfczr3q2Bi8jxEkzVbc)8qO36gkLQhB)2XgT2w1EJkxvtG2XYEdgzVHP3EZd)bl7ne(CUQMS3q46fzV1IfRzrD17gkOVimLXqTpMvelkyXAwux9UHc6lctz9Q8XSIyPnljjS8UMQ3GHA8FbYqLRQjq7nqchMl6pyzVHgybE)blw(D)zjStbGWSCDwIdxS4dXcC94dKyHc6lctS8qwGLoolGWNLFNgIf4WYHQGdXYVFywSC)olBqn(VazVHWNC5PK9gi8ZW1Jpqktb9fHj73o2aABRAVrLRQjq7yzV5H)GL9wkew9Bi7TWCpnNBVnuFi8URQjwuWslwux9UHc6lctzmu7JzOu)kmlnYYqP(vywssyrD17gkOVimL1RYhZqP(vywAKLHs9RWSKKWccFoxvtgq4NHRhFGuMc6lctS0MffSmuFi8URQjwuWY7dk6n)Ls5hMbpILgzrzaYIcw8OCyNcaXIcwq4Z5QAYac)8qO36gkLQhBVfIh0u(9bf9y7yRS9BhBaLTvT3OYv1eODSS38WFWYEdVQ(nK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfMLgzzOu)kmljjSOU6Ddf0xeMY6v5JzOu)kmlnYYqP(vywssybHpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXsJSOmazrblEuoStbGyrbli85CvnzaHFEi0BDdLs1JT3cXdAk)(GIESDSv2(TJnGW2Q2Bu5QAc0ow2BE4pyzVHFsR9j31(q2BH5EAo3EBO(q4DxvtSOGLwSOU6Ddf0xeMYyO2hZqP(vywAKLHs9RWSKKWI6Q3nuqFrykRxLpMHs9RWS0ildL6xHzjjHfe(CUQMmGWpdxp(aPmf0xeMyPnlkyzO(q4DxvtSOGL3hu0B(lLYpmdEelnYIYaAwuWIhLd7uaiwuWccFoxvtgq4Nhc9w3qPu9y7Tq8GMYVpOOhBhBLTF7ydCTTQ9gvUQMaTJL9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7TMbtS08GXMfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhBLbGTvT3OYv1eODSS38WFWYEJsJGwOjRclq7nqchMl6pyzV1myIfKYxboeilBr3CpMfl3VZIxXzrdluSqfCHANfTJ)RqXc6h0xeMyXlqw(jolpKf9vel3ZYkIfl3VZcGCPX(WIxGSGMgIKyOc2BH5EAo3ERflTyrD17gkOVimLXqTpMHs9RWS0ilkdawssyrD17gkOVimL1RYhZqP(vywAKfLbalTzrblbiudcTuMGNVkygk1VcZsJSetaWIcwAXI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIfaZcaTcaWssclwZYSkQdhuKjAUu4aEUo7tWRlKJwASpgc9wxuebYsBwAZssclQRE3enxkCapxN9j41fYrln2hdcxViwAujwaiGcaSKKWsac1GqlLj45RcMHCW4SOGfh)JRZrql0WsJSaCbG9BhBLv22Q2Bu5QAc0ow2BWi7nm92BE4pyzVHWNZv1K9gcxVi7nRzbCwhOPG5aiMffSGWNZv1KjaMdWc8(dwSOGLwS0ILaeQbHwkdLgfFixNHdy5vGmdL6xHzbWSOmGgqXcWyPflkRmlaplZQOoCqrg8v9LoVhh)0CUHkxvtGS0MffSqO36IIiqdLgfFixNHdy5vGyPnljjS44FCDocAHgwAujwaUaGffS0IfRz5DnvVPVM4zypt6vrgQCvnbYssclQRE3e88vbd4A8)GflnYsac1GqlLPVM4zypt6vrMHs9RWSamwaeS0MffSGWNZv1K53NtRZyIaIMSf)EwuWslwux9UbORahcmtPrql0Ks1NPIguxdiZkILKewSMLaebvE9gGIpNxS0MffS8(GIEZFPu(HzWJyPrwux9Uj45RcgW14)blwaEwaGbqXssclQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWILKewcqeu51BQd1(N7oXssclQRE3OQHqq9c)MvelkyrD17gvnecQx43muQFfMfaZI6Q3nbpFvWaUg)pyXcWyPflaxwaEwMvrD4GImrZLchWZ1zFcEDHC0sJ9XqO36IIiqwAZsBwuWI1SOU6DtWZxfmRiwuWslwSMLaebvE9M6qT)5UtSKKWsac1GqlLjaleqGO8VtzC0n3JnRiwssyrfIXSOGL(HA)ZdL6xHzbWSeGqni0szcWcbeik)7ughDZ9yZqP(vywaglaAwssyPFO2)8qP(vywqQSOmGaaSaywux9Uj45RcgW14)blwABVbs4WCr)bl7TMbtSGMgIKyOcSy5(DwqdSqabIqcs5RahcKLTOBUhZIxGSacl09SarqJL5EIfa5sJ9Hf4WILDQyjwAieuVWplwGlnileYIUHyrL6WHybnnejXqfyHqw0ne2EdHp5Ytj7TayoalW7pyLXV9BhBLbOTvT3OYv1eODSS38WFWYEBCeubx4CFOQbXT3ajCyUO)GL9wZGjw(DILyeu97XhwSC)ololOPHijgQal)U)SC4cDpl9bMYcGCPX(yVfM7P5C7n1vVBcE(QGzOu)kmlnYIYOLLKewux9Uj45RcgW14)blwamlXeaSOGfe(CUQMmbWCawG3FWkJF73o2khtBRAVrLRQjq7yzVfM7P5C7ne(CUQMmbWCawG3FWkJFwuWslwSMf1vVBcE(QGbCn(FWILgzjMaGLKewSMLaebvE9geu97XhwAZssclQRE3mocQGlCUpu1G4MvelkyrD17MXrqfCHZ9HQge3muQFfMfaZcWLfGXsawGR7nrdfomLD9HQsP6n)LszeUErSamwAXI1SOU6DJQgcb1l8BwrSOGfRz5DnvVb)(OHdOHkxvtGS02EZd)bl7TaPj8FUo76dvLs1B)2XwzRW2Q2Bu5QAc0ow2BH5EAo3EdHpNRQjtamhGf49hSY43EZd)bl7TRc(u(FWY(TJTYO12Q2Bu5QAc0ow2BWi7nm92BE4pyzVHWNZv1K9gcxVi7nRzjaHAqOLYe88vbZqoyCwssyXAwq4Z5QAYeGfciqugKWXRalkyjarqLxVPou7FU7eljjSaoRd0uWCaeBVbs4WCr)bl7Tye(CUQMyzHjqwGflU6PV)iml)U)SyXRNLhYIkXc2rqGS0HdlOPHijgQalyil)U)S87uCw8HQNflo(jqwqkzHFwuPoCiw(Dk1EdHp5Ytj7nSJGYD4KdE(QG9BhBLb02w1EJkxvtG2XYEZd)bl7T(AINH9mPxfzVbs4WCr)bl7TMbtywAEq0NLRZYvS4flOFqFryIfVaz5NJWS8qw0xrSCplRiwSC)olaYLg7dYzbnnejXqfyXlqwAiOh9hcILnl(KAVfM7P5C7nkOVimzUk7vCwuWIhLd7uaiwuWI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIfaZcaTcaWIcwAXci8noOh9hckJT4tAg0tDuK5VaqxHILKewSMLaebvE9MIcdudhqwAZIcwq4Z5QAYGDeuUdNCWZxfyrblTyrD17MXrqfCHZ9HQge3muQFfMfaZcWLLMJLwSGwwaEwMvrD4GIm4R6lDEpo(P5CdvUQMazPnlkyrD17MXrqfCHZ9HQge3SIyjjHfRzrD17MXrqfCHZ9HQge3SIyPT9BhBLbu2w1EJkxvtG2XYEZd)bl7n87t31A7nqchMl6pyzV1myILM)I(Dw2EF6UwZs0adywUolBVpDxRz5Wf6Ewwr2BH5EAo3EtD17gyr)oohrtGI(dwMvelkyrD17g87t31AZq9HW7UQMSF7yRmGW2Q2Bu5QAc0ow2BH5EAo3EtD17g87JgoGMHs9RWSaywqllkyPflQRE3qb9fHPmgQ9XmuQFfMLgzbTSKKWI6Q3nuqFrykRxLpMHs9RWS0ilOLL2SOGfh)JRZrql0WsJSaCbG9Mh(dw2BbVcKoRU6D7n1vVNlpLS3WVpA4aA)2XwzGRTvT3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BX4vAeMLgIbKSOsD4qSGgyHaceXYcFfkw(DIf0aleqGiwcWc8(dwS8qwc7uaiwUolObwiGarSCyw8WVCToolUkC9S8qwujwco(T3cZ90CU9waIGkVEtDO2)C3jwuWccFoxvtMaSqabIYGeoEfyrblbiudcTuMaSqabIY)oLXr3Cp2muQFfMfaZcAzrblwZc4SoqtbZbqmlkyHc6lctMRYEfNffS44FCDocAHgwAKfRaa2VDSbiaSTQ9gvUQMaTJL9Mh(dw2B43NUR12BGeomx0FWYERzWelBVpDxRzXY97SS9Kw7dlX456plEbYsbzz79rdhqKZILDQyPGSS9(0DTMLdZYkc5SehUyXhILRyXkxLpSG(b9fHjw6WHfabWWuaZcCy5HSenWalaYLg7dlw2PIfxfIGyb4cawAigqYcCyXbJ8)qqSGT4tkl7oMfabWWuaZYqP(vxHIf4WYHz5kw66d1(Byj2WNy539NLvbsdl)oXc2tjwcWc8(dwywUhDywaJWSu06hxZYdzz79P7AnlGR5kuSeJ6iOcUWS08gQAqCKZILDQyjoCHoqwW)P1SqfilRiwSC)olaxaamhhXshoS87elAh)SGsdvDn2yVfM7P5C7T31u9g8tATpzW56VHkxvtGSOGfRz5DnvVb)(OHdOHkxvtGSOGf1vVBWVpDxRnd1hcV7QAIffS0If1vVBOG(IWuwVkFmdL6xHzPrwaeSOGfkOVimzUkRxLpSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaIwaWssclQRE3enxkCapxN9j41fYrln2hdcxViwAujwaiAbalkyXX)46Ce0cnS0ilaxaWssclGW34GE0FiOm2IpPzqp1rrMHs9RWS0ilacwssyXd)blJd6r)HGYyl(KMb9uhfzUk31hQ9NL2SOGLaeQbHwktWZxfmdL6xHzPrwuga2VDSbOY2w1EJkxvtG2XYEZd)bl7n87dEnOi7nqchMl6pyzV1myILT3h8AqrS08x0VZs0adyw8cKfWvAelnedizXYovSGMgIKyOcSahw(DILyeu97Xhwux9olhMfxfUEwEilDxRzb27SahwIdxOdKLGhXsdXas7TWCpnNBVPU6DdSOFhNdAYNmIdFWYSIyjjHf1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyjjHf1vVBcE(QGzfXIcwAXI6Q3nJJGk4cN7dvniUzOu)kmlaMfubqtQJmwaEwc0PzPflo(hxNJGwOHfKWsmbalTzbySetwaEwExt1BkYsofcldvUQMazrblwZYSkQdhuKbFvFPZ7XXpnNBOYv1eilkyrD17MXrqfCHZ9HQge3SIyjjHf1vVBcE(QGzOu)kmlaMfubqtQJmwaEwc0PzPflo(hxNJGwOHfKWsmbalTzjjHf1vVBghbvWfo3hQAq8m(Q(sN3JJFAo3SIyjjHLwSOU6DZ4iOcUW5(qvdIBgk1VcZcGzXd)bld(9PFdziKrH1t5)sjwuWcoI068UJFIfaZcamwbljjSOU6DZ4iOcUW5(qvdIBgk1VcZcGzXd)blJLX)DdHmkSEk)xkXsscli85Cvnzo0dmhGf49hSyrblbiudcTuMRWHz9UQMYO3YRFLMbjexGmd5GXzrble6TUOic0CfomR3v1ug9wE9R0miH4celTzrblQRE3mocQGlCUpu1G4MveljjSynlQRE3mocQGlCUpu1G4MvelkyXAwcqOgeAPmJJGk4cN7dvniUzihmoljjSynlbicQ86niO63JpS0MLKewC8pUohbTqdlnYcWfaSOGfkOVimzUk7vC73o2aeG2w1EJkxvtG2XYEZd)bl7n87dEnOi7nqchMl6pyzVz1jolpKLuhiILFNyrLWplWolBVpA4aYIACwWVha6kuSCplRiwqV1fashNLRyXR4SG(b9fHjwuxplaYLg7dlhUEwCv46z5HSOsSenWqGaT3cZ90CU927AQEd(9rdhqdvUQMazrblwZYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPflQRE3GFF0Wb0SIyjjHfh)JRZrql0WsJSaCbalTzrblQRE3GFF0Wb0GFpaelaMLyYIcwAXI6Q3nuqFrykJHAFmRiwssyrD17gkOVimL1RYhZkIL2SOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfacOaalkyPflbiudcTuMGNVkygk1VcZsJSOmayjjHfRzbHpNRQjtawiGarzqchVcSOGLaebvE9M6qT)5UtS02(TJnaJPTvT3OYv1eODSS3Gr2By6T38WFWYEdHpNRQj7neUEr2BuqFryYCvwVkFyb4zbqWcsyXd)bld(9PFdziKrH1t5)sjwaglwZcf0xeMmxL1RYhwaEwAXcGMfGXY7AQEdgU0zyp)7uUdhc)gQCvnbYcWZsmzPnliHfp8hSmwg)3neYOW6P8FPelaJfaySc0YcsybhrADE3XpXcWybag0YcWZY7AQEt5)AiCw11EfidvUQMaT3ajCyUO)GL9g6J)l1FcZYo0clPRWolnedizXhIfu(veilr0WcMcWc0EdHp5Ytj7nhhbiPzJc2VDSbOvyBv7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9wmELgXY27dEnOiwUIfNfafWWuGLnO2hwq)G(IWeYzbewO7zrtpl3Zs0adSaixASpS0639NLdZYUxGAcKf14Sq3Vtdl)oXY27t31Aw0xrSahw(DILgIbKncCbal6Riw6WHLT3h8AqrTrolGWcDplqe0yzUNyXlwA(l63zjAGbw8cKfn9S87elUkebXI(kILDVa1elBVpA4aAVfM7P5C7nRzzwf1HdkY8xkzbovgCipv9kqAmu5QAcKffS0If1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfacOaaljjSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaq0cawuWY7AQEd(jT2Nm4C93qLRQjqwAZIcwAXcf0xeMmxLXqTpSOGfh)JRZrql0WcWybHpNRQjJJJaK0SrbwaEwux9UHc6lctzmu7JzOu)kmlaJfq4B6RjEg2ZKEvK5Vaq48qP(vSa8SaqdAzPrwaeaGLKewOG(IWK5QSEv(WIcwC8pUohbTqdlaJfe(CUQMmoocqsZgfyb4zrD17gkOVimL1RYhZqP(vywaglGW30xt8mSNj9QiZFbGW5Hs9Ryb4zbGg0YsJSaCbalTzrblwZI6Q3nWI(DCoIMaf9hSmRiwuWI1S8UMQ3GFF0Wb0qLRQjqwuWslwcqOgeAPmbpFvWmuQFfMLgzbqXsscly4sREfO53NtRZyIaIgdvUQMazrblQRE387ZP1zmrarJb)EaiwamlXmMS0CS0ILzvuhoOid(Q(sN3JJFAo3qLRQjqwaEwqllTzrbl9d1(Nhk1VcZsJSOmaaalkyPFO2)8qP(vywamlaeaaGL2SOGLwSeGqni0sza6kWHaZ4OBUhBgk1VcZsJSaOyjjHfRzjarqLxVbO4Z5flTTF7ydq0ABv7nQCvnbAhl7np8hSS3kYsofcl7nqchMl6pyzV1myILMpiSWSCflw5Q8Hf0pOVimXIxGSGDeelXiX1DG18wAnlnFqyXshoSGMgIKyOcS4filiLVcCiqwq)0iOfAsP6T3cZ90CU9wlwux9UHc6lctz9Q8XmuQFfMLgzHqgfwpL)lLyjjHLwSe29bfHzrjwailkyzOWUpOO8FPelaMf0YsBwssyjS7dkcZIsSetwAZIcw8OCyNcaXIcwq4Z5QAYGDeuUdNCWZxfSF7ydqaTTvT3OYv1eODSS3cZ90CU9wlwux9UHc6lctz9Q8XmuQFfMLgzHqgfwpL)lLyrblwZsaIGkVEdqXNZlwssyPflQRE3a0vGdbMP0iOfAsP6ZurdQRbKzfXIcwcqeu51Bak(CEXsBwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKLKewux9Uj45RcMvelTzrblEuoStbGyrbli85CvnzWock3Hto45RcSOGLwSOU6DZ4iOcUW5(qvdIBgk1VcZcGzPflOLLMJfaYcWZYSkQdhuKbFvFPZ7XXpnNBOYv1eilTzrblQRE3mocQGlCUpu1G4MveljjSynlQRE3mocQGlCUpu1G4MvelTT38WFWYEB319Ckew2VDSbiGY2Q2Bu5QAc0ow2BH5EAo3ERflQRE3qb9fHPSEv(ygk1VcZsJSqiJcRNY)LsSOGfRzjarqLxVbO4Z5fljjS0If1vVBa6kWHaZuAe0cnPu9zQOb11aYSIyrblbicQ86nafFoVyPnljjS0ILWUpOimlkXcazrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyYssclQRE3e88vbZkIL2SOGfpkh2PaqSOGfe(CUQMmyhbL7Wjh88vbwuWslwux9UzCeubx4CFOQbXndL6xHzbWSGwwuWI6Q3nJJGk4cN7dvniUzfXIcwSMLzvuhoOid(Q(sN3JJFAo3qLRQjqwssyXAwux9UzCeubx4CFOQbXnRiwABV5H)GL9wFP15uiSSF7ydqaHTvT3OYv1eODSS3ajCyUO)GL9wZGjwqkGOplWILaO9Mh(dw2Bw8zo4KH9mPxfz)2XgGaxBRAVrLRQjq7yzV5H)GL9g(9PFdzVbs4WCr)bl7TMbtSS9(0VHy5HSenWalBqTpSG(b9fHjKZcAAisIHkWYUJzrtyml)LsS87EXIZcsX4)oleYOW6jw0u)zboSalDCwSYv5dlOFqFryILdZYkYElm3tZ52BuqFryYCvwVkFyjjHfkOVimzWqTp5Iq2ZsscluqFryY4v8Cri7zjjHLwSOU6DJfFMdozypt6vrMveljjSGJiToV74NybWSaaJvGwwuWI1SeGiOYR3GGQFp(Wsscl4isRZ7o(jwamlaWyfSOGLaebvE9geu97XhwAZIcwux9UHc6lctz9Q8XSIyjjHLwSOU6DtWZxfmdL6xHzbWS4H)GLXY4)UHqgfwpL)lLyrblQRE3e88vbZkIL22VDSJjaSTQ9gvUQMaTJL9giHdZf9hSS3AgmXcsX4)olWFNglhMyXY(f2z5WSCflBqTpSG(b9fHjKZcAAisIHkWcCy5HSenWalw5Q8Hf0pOVimzV5H)GL9MLX)D73o2XuzBRAVrLRQjq7yzVbs4WCr)bl7TMNR1)(SS38WFWYEBwv2d)bRS(WV9M(WFU8uYER7A9Vpl73(T3Igkatv932Q2XwzBRAV5H)GL9gqxboeyghDZ9y7nQCvnbAhl73o2a02Q2Bu5QAc0ow2BWi7nm92BE4pyzVHWNZv1K9gcxVi7nayVbs4WCr)bl7nRUtSGWNZv1elhMfm9S8qwaalwUFNLcYc(9NfyXYctS8Zvarpg5SOmlw2PILFNyPFd(zbwelhMfyXYctiNfaYY1z53jwWuawGSCyw8cKLyYY1zrf(7S4dzVHWNC5PK9gSYlmL)5kGO3(TJDmTTQ9gvUQMaTJL9gmYEZbbT38WFWYEdHpNRQj7neUEr2BkBVfM7P5C7TFUci6nVYMDhNxykRU6DwuWYpxbe9Mxztac1GqlLbCn(FWIffSynl)Cfq0BELnh28Wukd75uyH)bUW5aSW)Sc)blS9gcFYLNs2BWkVWu(NRaIE73o2wHTvT3OYv1eODSS3Gr2BoiO9Mh(dw2Bi85CvnzVHW1lYEdG2BH5EAo3E7NRaIEZdqZUJZlmLvx9olky5NRaIEZdqtac1GqlLbCn(FWIffSynl)Cfq0BEaAoS5HPug2ZPWc)dCHZbyH)zf(dwy7ne(KlpLS3GvEHP8pxbe92VDSrRTvT3OYv1eODSS3Gr2BoiO9Mh(dw2Bi85CvnzVHWNC5PK9gSYlmL)5kGO3Elm3tZ52Be6TUOic0CfomR3v1ug9wE9R0miH4celjjSqO36IIiqdLgfFixNHdy5vGyjjHfc9wxuebAWWLwt)FfQ8SuJBVbs4WCr)bl7nRUtyILFUci6XS4dXsbFw81dt9)cUwhNfq6PWtGS4ywGfllmXc(9NLFUci6XgwyzJEwq4Z5QAILhYIvWIJz53P4S4AmKLIiqwWru4Cnl7EbQVcLXEdHRxK9Mvy)2XgqBBv7np8hSS3sHWcORYD4KAVrLRQjq7yz)2XgqzBv7nQCvnbAhl7np8hSS3Sm(VBVfM7P5C7TwSqb9fHjJEv(KlczpljjSqb9fHjZvzmu7dljjSqb9fHjZvzv4VZsscluqFryY4v8Cri7zPT9M(kkhaT3uga2V9B)2BiObFWYo2aeaauzaaOaiGYEZIp1vOW2Bifnmgn2XqSrkf4WclwDNy5sJGZZshoSGoyev0Gowgc9w3qGSGHPel(6HP(tGSe29cfHnCtw5velae4WcAGfcAEcKf0nRI6WbfzAw0XYdzbDZQOoCqrMM1qLRQjq0XslLrwBd3KvEfXsmboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnXnHu0Wy0yhdXgPuGdlSy1DILlncoplD4Wc6aPUV0p6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnzLxrSaOboSGgyHGMNazz7srdl4417iJfKklpKfRC5SaEio8blwGr04pCyPfsAZslLrwBd3KvEfXcGg4WcAGfcAEcKf0nRI6WbfzAw0XYdzbDZQOoCqrMM1qLRQjq0XslLrwBd3KvEfXcGc4WcAGfcAEcKf0nRI6WbfzAw0XYdzbDZQOoCqrMM1qLRQjq0XslLrwBd3KvEfXcGa4WcAGfcAEcKLTlfnSGJxVJmwqQS8qwSYLZc4H4WhSybgrJ)WHLwiPnlTaiYAB4MSYRiwaUahwqdSqqZtGSGUzvuhoOitZIowEilOBwf1HdkY0SgQCvnbIowAPmYAB4MSYRiwaUahwqdSqqZtGSGUFUci6nkBAw0XYdzbD)Cfq0BELnnl6yPfarwBd3KvEfXcWf4WcAGfcAEcKf09ZvarVbGMMfDS8qwq3pxbe9MhGMMfDS0cGiRTHBYkVIyrzaaCybnWcbnpbYc6MvrD4GImnl6y5HSGUzvuhoOitZAOYv1ei6yPLYiRTHBYkVIyrzLboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOmaboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOCmboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOmAboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOmGg4WcAGfcAEcKf0nRI6WbfzAw0XYdzbDZQOoCqrMM1qLRQjq0XslaIS2gUjR8kIfLb0ahwqdSqqZtGSGUFUci6nkBAw0XYdzbD)Cfq0BELnnl6yPfarwBd3KvEfXIYaAGdlObwiO5jqwq3pxbe9gaAAw0XYdzbD)Cfq0BEaAAw0XslLrwBd3KvEfXIYakGdlObwiO5jqwq3SkQdhuKPzrhlpKf0nRI6WbfzAwdvUQMarhlTaiYAB4MSYRiwugqbCybnWcbnpbYc6(5kGO3OSPzrhlpKf09ZvarV5v20SOJLwkJS2gUjR8kIfLbuahwqdSqqZtGSGUFUci6na00SOJLhYc6(5kGO38a00SOJLwaezTnCtCtifnmgn2XqSrkf4WclwDNy5sJGZZshoSGUOHcWuv)rhldHERBiqwWWuIfF9Wu)jqwc7EHIWgUjR8kILycCybnWcbnpbYc6(5kGO3OSPzrhlpKf09ZvarV5v20SOJLwXezTnCtw5velwbWHf0ale08eilO7NRaIEdannl6y5HSGUFUci6npannl6yPvmrwBd3e3esrdJrJDmeBKsboSWIv3jwU0i48S0HdlOZHe6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnzLxrSOmWHf0ale08eilOBwf1HdkY0SOJLhYc6MvrD4GImnRHkxvtGOJf)zb9B(TswAPmYAB4MSYRiwIjWHf0ale08eilOBwf1HdkY0SOJLhYc6MvrD4GImnRHkxvtGOJLwkJS2gUjR8kIfafWHf0ale08eilBxkAybhVEhzSGurQS8qwSYLZskeCPxywGr04pCyPfsTnlTugzTnCtw5velakGdlObwiO5jqwq3SkQdhuKPzrhlpKf0nRI6WbfzAwdvUQMarhlTaiYAB4MSYRiwaeahwqdSqqZtGSSDPOHfC86DKXcsfPYYdzXkxolPqWLEHzbgrJ)WHLwi12S0szK12WnzLxrSaiaoSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSaCboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOmaaoSGgyHGMNazz7srdl4417iJfKklpKfRC5SaEio8blwGr04pCyPfsAZslaIS2gUjR8kIfLJjWHf0ale08eilBxkAybhVEhzSGuz5HSyLlNfWdXHpyXcmIg)HdlTqsBwAPmYAB4MSYRiwaiaaoSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSaqacCybnWcbnpbYY2LIgwWXR3rglivwEilw5Yzb8qC4dwSaJOXF4WslK0MLwkJS2gUjR8kIfaAfahwqdSqqZtGSSDPOHfC86DKXcsLLhYIvUCwapeh(GflWiA8hoS0cjTzPfarwBd3KvEfXcaTcGdlObwiO5jqwq3SkQdhuKPzrhlpKf0nRI6WbfzAwdvUQMarhlTugzTnCtw5velaeqdCybnWcbnpbYc6MvrD4GImnl6y5HSGUzvuhoOitZAOYv1ei6yPLYiRTHBYkVIybGakGdlObwiO5jqwq3SkQdhuKPzrhlpKf0nRI6WbfzAwdvUQMarhlTugzTnCtw5velae4cCybnWcbnpbYY2LIgwWXR3rglivwEilw5Yzb8qC4dwSaJOXF4WslK0MLwaezTnCtw5velXeaahwqdSqqZtGSSDPOHfC86DKXcsLLhYIvUCwapeh(GflWiA8hoS0cjTzPLYiRTHBIBcPOHXOXogInsPahwyXQ7elxAeCEw6WHf01DT(3Nf6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnzLxrSaqGdlObwiO5jqw2Uu0WcoE9oYybPYYdzXkxolGhIdFWIfyen(dhwAHK2S0szK12WnXnHu0Wy0yhdXgPuGdlSy1DILlncoplD4Wc6Wp6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnzLxrSOmWHf0ale08eilOBwf1HdkY0SOJLhYc6MvrD4GImnRHkxvtGOJLwkJS2gUjR8kILycCybnWcbnpbYc6MvrD4GImnl6y5HSGUzvuhoOitZAOYv1ei6yPLYiRTHBYkVIyrzLboSGgyHGMNazz7srdl4417iJfKksLLhYIvUCwsHGl9cZcmIg)HdlTqQTzPLYiRTHBYkVIyrzLboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSOmGg4WcAGfcAEcKf0nRI6WbfzAw0XYdzbDZQOoCqrMM1qLRQjq0XslLrwBd3KvEfXcavg4WcAGfcAEcKLTlfnSGJxVJmwqQS8qwSYLZc4H4WhSybgrJ)WHLwiPnlTaiYAB4MSYRiwaOYahwqdSqqZtGSGUzvuhoOitZIowEilOBwf1HdkY0SgQCvnbIowAPmYAB4MSYRiwaiaboSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0szK12WnzLxrSaWycCybnWcbnpbYY2LIgwWXR3rglivwEilw5Yzb8qC4dwSaJOXF4WslK0MLwXezTnCtw5vela0kaoSGgyHGMNazbDZQOoCqrMMfDS8qwq3SkQdhuKPznu5QAceDS0cGiRTHBYkVIybGaAGdlObwiO5jqwq3SkQdhuKPzrhlpKf0nRI6WbfzAwdvUQMarhlTugzTnCtw5velaeqbCybnWcbnpbYc6MvrD4GImnl6y5HSGUzvuhoOitZAOYv1ei6yPLYiRTHBIBcPOHXOXogInsPahwyXQ7elxAeCEw6WHf0Pc9hDSme6TUHazbdtjw81dt9NazjS7fkcB4MSYRiwugqaCybnWcbnpbYY2LIgwWXR3rglivwEilw5Yzb8qC4dwSaJOXF4WslK0MLwXezTnCtw5velkdCboSGgyHGMNazz7srdl4417iJfKklpKfRC5SaEio8blwGr04pCyPfsAZslLrwBd3e3umKgbNNazbqXIh(dwSOp8JnCt2B4ikyhBLbaaT3Igy)0K9gsJ0Selx7vGyjgpRdKBcPrAwAAPJZsmvg5SaqaaqL5M4MqAKMf0S7fkcdC4MqAKMLMJLgccsGSSb1(WsSip1WnH0inlnhlOz3lueilVpOOpFDwcoMWS8qwcXdAk)(GIESHBcPrAwAowIrPuiccKLvvuGWyFIZccFoxvtywADgYGCwIgcrg)(GxdkILMRrwIgcHb)(GxdkQTHBcPrAwAowAic4bYs0qbh)xHIfKIX)DwUol3Joml)oXILbwOyb9d6lctgUjKgPzP5yP5ZbIybnWcbeiILFNyzl6M7XS4SOV)1elPWHyPRjKDQAILwxNL4Wfl7oyHUNL97z5EwWx6s)ErWfwhNfl3VZsSA(BOvzbySGgst4)CnlnuFOQuQEKZY9OdKfmqxuBd3esJ0S0CS085arSKcXplORFO2)8qP(vy0XcoqLpheZIhfPJZYdzrfIXS0pu7pMfyPJB4MqAKMLMJfRoK)SyvykXcSZsS0(olXs77SelTVZIJzXzbhrHZ1S8ZvarVHBcPrAwAowA(JOIgwADgYGCwqkg)3rolifJ)7iNLT3N(nuBwsDqILu4qSme(0hvplpKfYh9rdlbyQQ)nh(95nCtCtinsZsdRc((tGSelx7vGyPHasRKLGxSOsS0HRcKf)zz))imWbjir11EfOMdFPbdQ73xQMdIKy5AVcuZTDPObjPGM9pvhJ0(PjLuDTxbY8i75M4M8WFWcBIgkatv9xjGUcCiWmo6M7XCtinlwDNybHpNRQjwomly6z5HSaawSC)olfKf87plWILfMy5NRaIEmYzrzwSStfl)oXs)g8ZcSiwomlWILfMqolaKLRZYVtSGPaSaz5WS4filXKLRZIk83zXhIBYd)blSjAOamv1FGPesq4Z5QAc5LNskbR8ct5FUci6rocxViLaa3Kh(dwyt0qbyQQ)atjKGWNZv1eYlpLucw5fMY)Cfq0JCyKsoiiYr46fPKYi)6k9ZvarVrzZUJZlmLvx9UIFUci6nkBcqOgeAPmGRX)dwkS(NRaIEJYMdBEykLH9CkSW)ax4Caw4FwH)GfMBYd)blSjAOamv1FGPesq4Z5QAc5LNskbR8ct5FUci6romsjhee5iC9IucGi)6k9ZvarVbGMDhNxykRU6Df)Cfq0BaOjaHAqOLYaUg)pyPW6FUci6na0CyZdtPmSNtHf(h4cNdWc)Zk8hSWCtinlwDNWel)Cfq0JzXhILc(S4RhM6)fCToolG0tHNazXXSalwwyIf87pl)Cfq0JnSWYg9SGWNZv1elpKfRGfhZYVtXzX1yilfrGSGJOW5Aw29cuFfkd3Kh(dwyt0qbyQQ)atjKGWNZv1eYlpLucw5fMY)Cfq0JCyKsoiiYr46fPKvG8RReHERlkIanxHdZ6DvnLrVLx)kndsiUaLKqO36IIiqdLgfFixNHdy5vGssi0BDrreObdxAn9)vOYZsno3Kh(dwyt0qbyQQ)atjKKcHfqxL7WjLBYd)blSjAOamv1FGPesSm(VJC9vuoaQKYaa5xxPwuqFryYOxLp5Iq2NKqb9fHjZvzmu7tscf0xeMmxLvH)Escf0xeMmEfpxeY(2CtCtinlaYHco(zbGSGum(VZIxGS4SS9(GxdkIfyXYMvzXY97Se7d1(ZsZZjw8cKLybBOvzboSS9(0VHyb(70y5We3Kh(dwydmIkAaMsiXY4)oYVUsTOG(IWKrVkFYfHSpjHc6lctMRYyO2NKekOVimzUkRc)9KekOVimz8kEUiK9TvenecJYglJ)7kSoAiegaASm(VZn5H)Gf2aJOIgGPesWVp9BiKRVIYbqLqlYVUswpRI6WbfzuDTxbkd7zxRZ)(vOWjjwhGiOYR3uhQ9p3DkjXACeP153hu0Jn43NUR1kPCsI1VRP6nL)RHWzvx7vGmu5QAcmjPff0xeMmyO2NCri7tsOG(IWK5QSEv(KKqb9fHjZvzv4VNKqb9fHjJxXZfHSVn3Kh(dwydmIkAaMsib)(Gxdkc56ROCauj0I8RR0SkQdhuKr11EfOmSNDTo)7xHcRiarqLxVPou7FU7KcCeP153hu0Jn43NUR1kPm3e3esJ0SG(iJcRNazHqqtCw(lLy53jw8Wdhwomloc)0UQMmCtE4pyHvcd1(KvjpLBYd)blmWucjbxRZE4pyL1h(rE5PKsWiQOb5xxP)sja3cGaVh(dwglJ)7MGJ)8FPeW8WFWYGFF63qMGJ)8FPuBUjKMLn6XS0qi6ZcSyjMaJfl3VdxplGZ1Fw8cKfl3VZY27JgoGS4filaeySa)DASCyIBYd)blmWucji85CvnH8YtjLoC2HeYr46fPeoI0687dk6Xg87t316gvwrlRFxt1BWVpA4aAOYv1eysY7AQEd(jT2Nm4C93qLRQjW2jj4isRZVpOOhBWVpDxRBeGCtinlB0JzjOjhbXILDQyz79PFdXsWlw2VNfacmwEFqrpMfl7xyNLdZYqAcHxplD4WYVtSG(b9fHjwEilQelrd1Pziqw8cKfl7xyNL(P10WYdzj44NBYd)blmWucji85CvnH8YtjLoCoOjhbHCeUErkHJiTo)(GIESb)(0VHAuzUjKMLye(CUQMy539NLWofacZY1zjoCXIpelxXIZcQailpKfhb8az53jwW3V8)Gflw2PHyXz5NRaIEwOpWYHzzHjqwUIfv6TquXsWXpMBYd)blmWucji85CvnH8YtjLUkJkaICeUErkfnectkew9BOKKOHqyWRQFdLKenecd(9bVguuss0qim43NUR1jjrdHW0xt8mSNj9QOKe1vVBcE(QGzOu)kSsQRE3e88vbd4A8)Gf3esZsZGjwIfnyAa6kuSy5(DwqtdrsmubwGdlE)PHf0aleqGiwUIf00qKedvGBYd)blmWucjQ0GPbORqH8RRuRwwhGiOYR3uhQ9p3DkjX6aeQbHwktawiGar5FNY4OBUhBwrTvOU6DtWZxfmdL6xHBuz0QqD17MXrqfCHZ9HQge3muQFfgWwHcRdqeu51Bqq1VhFsscqeu51Bqq1VhFuOU6DtWZxfmRifQRE3mocQGlCUpu1G4MvKIwQRE3mocQGlCUpu1G4MHs9RWawzLBo0c8ZQOoCqrg8v9LoVhh)0CEsI6Q3nbpFvWmuQFfgWkRCsIYivCeP15Dh)eGv2Gw02UTce(CUQMmxLrfa5MqAwaKWNfl3VZIZcAAisIHkWYV7plhUq3ZIZcGCPX(Ws0adSahwSStfl)oXs)qT)SCywCv46z5HSqfi3Kh(dwyGPesIG)blKFDLux9Uj45RcMHs9RWnQmAv0Y6zvuhoOid(Q(sN3JJFAopjrD17MXrqfCHZ9HQge3muQFfgWkdOAoac8QRE3OQHqq9c)MvKc1vVBghbvWfo3hQAqCZkQDsIkeJv0pu7FEOu)kmGbiA5MqAwqJRdlT)eMfl70Vtdll8vOybnWcbeiILcAHflNwZIR1qlSehUy5HSG)tRzj44NLFNyb7PelEkCvplWolObwiGaradnnejXqfyj44hZn5H)GfgykHee(CUQMqE5PKsbyHaceLbjC8kGCeUErkfOt3Qv)qT)5Hs9RWnNYOT5cqOgeAPmbpFvWmuQFfUnsvzabaARuGoDRw9d1(Nhk1Vc3CkJ2MlaHAqOLYeGfciqu(3Pmo6M7XgW14)bRMlaHAqOLYeGfciqu(3Pmo6M7XMHs9RWTrQkdiaqBfwp(bMjeu9gheeBiKD4hNKeGqni0szcE(QGzOu)kCJx90eb1(tG5(HA)ZdL6xHtscqOgeAPmbyHaceL)DkJJU5ESzOu)kCJx90eb1(tG5(HA)ZdL6xHBoLbqsI1bicQ86n1HA)ZDN4MqAwAgmbYYdzbK0ECw(DILf2rrSa7SGMgIKyOcSyzNkww4RqXciCPQjwGfllmXIxGSenecQEwwyhfXILDQyXlwCqqwieu9SCywCv46z5HSaEe3Kh(dwyGPesq4Z5QAc5LNskfaZbybE)blKJW1lsPw9d1(Nhk1Vc3OYOnjz8dmtiO6noii2CvJOfaTv0Qvlc9wxuebAO0O4d56mCalVcKIwbiudcTugknk(qUodhWYRazgk1VcdyLb0aijjarqLxVbbv)E8rrac1GqlLHsJIpKRZWbS8kqMHs9RWawzanGcyTuwzGFwf1HdkYGVQV05944NMZB3wH1biudcTugknk(qUodhWYRazgYbJ3ojHqV1ffrGgmCP10)xHkpl14kAzDaIGkVEtDO2)C3PKKaeQbHwkdgU0A6)RqLNLA8CmTc0ciaGYMHs9RWawzLTI2jjTcqOgeAPmQ0GPbORqzgYbJNKy94bY8duRBROvlc9wxuebAUchM17QAkJElV(vAgKqCbsrRaeQbHwkZv4WSExvtz0B51VsZGeIlqMHCW4jjE4pyzUchM17QAkJElV(vAgKqCbYaEyxvtGTBNK0IqV1ffrGg8UdcTqGz4OMH98dNuQEfbiudcTuMhoPu9ey(k8HA)ZXeTOnMauzZqP(v42jjTAHWNZv1Kbw5fMY)Cfq0RKYjji85CvnzGvEHP8pxbe9kfZ2kA9ZvarVrzZqoy8Cac1GqlvsYpxbe9gLnbiudcTuMHs9RWnE1tteu7pbM7hQ9ppuQFfU5ugaTtsq4Z5QAYaR8ct5FUci6vcGkA9ZvarVbGMHCW45aeQbHwQKKFUci6na0eGqni0szgk1Vc34vpnrqT)eyUFO2)8qP(v4Mtza0ojbHpNRQjdSYlmL)5kGOxja0UD7KKaebvE9gGIpNxTtsuHySI(HA)ZdL6xHbS6Q3nbpFvWaUg)pyXnH0SeJWNZv1ellmbYYdzbK0ECw8kol)Cfq0JzXlqwcGywSStflw87VcflD4WIxSG(ROD4ColrdmWn5H)GfgykHee(CUQMqE5PKs)(CADgteq0KT43JCeUErkzngU0QxbA(9506mMiGOXqLRQjWKK(HA)ZdL6xHBeGaaajjQqmwr)qT)5Hs9RWagGOfyTSca0CQRE387ZP1zmrarJb)EaiGhGTtsux9U53NtRZyIaIgd(9aqngtarZ1Awf1HdkYGVQV05944NMZbE02MBcPzPzWelOFAu8HCnln)dy5vGybGaatbmlQuhoelolOPHijgQallmz4M8WFWcdmLqYct57PuKxEkPeLgfFixNHdy5vGq(1vkaHAqOLYe88vbZqP(vyadqaOiaHAqOLYeGfciqu(3Pmo6M7XMHs9RWagGaqrle(CUQMm)(CADgteq0KT43NKOU6DZVpNwNXebeng87bGAmMaayTMvrD4GIm4R6lDEpo(P5CGhq3UTce(CUQMmxLrfatsuHySI(HA)ZdL6xHbCmbuCtinlndMyzdU0A6VcflXOl14SaOXuaZIk1HdXIZcAAisIHkWYctgUjp8hSWatjKSWu(Ekf5LNskHHlTM()ku5zPgh5xxPwbiudcTuMGNVkygk1VcdyaTcRdqeu51Bqq1VhFuyDaIGkVEtDO2)C3PKKaebvE9M6qT)5UtkcqOgeAPmbyHaceL)DkJJU5ESzOu)kmGb0kAHWNZv1KjaleqGOmiHJxHKKaeQbHwktWZxfmdL6xHbmGUDssaIGkVEdcQ(94JIwwpRI6WbfzWx1x68EC8tZ5kcqOgeAPmbpFvWmuQFfgWa6Ke1vVBghbvWfo3hQAqCZqP(vyaRSvaSwOf4j0BDrreO5k8pRWdhCg8qCfLvjTUTc1vVBghbvWfo3hQAqCZkQDss)qT)5Hs9RWagGOnjHqV1ffrGgknk(qUodhWYRaPiaHAqOLYqPrXhY1z4awEfiZqP(v4gbiaARaHpNRQjZvzubqfwtO36IIiqZv4WSExvtz0B51VsZGeIlqjjbiudcTuMRWHz9UQMYO3YRFLMbjexGmdL6xHBeGaijrfIXk6hQ9ppuQFfgWaeaCtinlnuBXJJzzHjwIHyKJXSy5(DwqtdrsmubUjp8hSWatjKGWNZv1eYlpLu6qpWCawG3FWc5iC9IusD17MGNVkygk1Vc3OYOvrlRNvrD4GIm4R6lDEpo(P58Ke1vVBghbvWfo3hQAqCZqP(vyaRKYaeyTIjWRU6DJQgcb1l8BwrTbwRwaIMdTaV6Q3nQAieuVWVzf1g4j0BDrreO5k8pRWdhCg8qCfLvjTUTc1vVBghbvWfo3hQAqCZkQDsIkeJv0pu7FEOu)kmGbiAtsi0BDrreOHsJIpKRZWbS8kqkcqOgeAPmuAu8HCDgoGLxbYmuQFfMBYd)blmWucjlmLVNsrE5PKsxHdZ6DvnLrVLx)kndsiUaH8RRecFoxvtMd9aZbybE)blfi85CvnzUkJkaYnH0S0myIL5qT)SOsD4qSeaXCtE4pyHbMsizHP89ukYlpLucV7GqleygoQzyp)WjLQh5xxPwbiudcTuMGNVkygYbJRW6aebvE9M6qT)5Utkq4Z5QAY87ZP1zmrart2IFFssaIGkVEtDO2)C3jfbiudcTuMaSqabIY)oLXr3Cp2mKdgxrle(CUQMmbyHaceLbjC8kKKeGqni0szcE(QGzihmE72kaHVbVQ(nK5VaqxHsrlq4BWpP1(K7AFiZFbGUcvsI1VRP6n4N0AFYDTpKHkxvtGjj4isRZVpOOhBWVp9BOgJzBfTaHVjfcR(nK5VaqxHQTIwi85CvnzoC2HusYSkQdhuKr11EfOmSNDTo)7xHcNK44FCDocAHMgvc4cGKe1vVBu1qiOEHFZkQTIwbiudcTugvAW0a0vOmd5GXtsSE8az(bQ1TvynHERlkIanxHdZ6DvnLrVLx)kndsiUaLKqO36IIiqZv4WSExvtz0B51VsZGeIlqkAfGqni0szUchM17QAkJElV(vAgKqCbYmuQFfUXycGKKaeQbHwkJknyAa6kuMHs9RWngta0wH1QRE3e88vbZkkjrfIXk6hQ9ppuQFfgWwba4MqAwS6(Hz5WS4Sm(VtdlK2vHJ)elw84S8qwsDGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSC)olOPHijgQalEbYcAGfciqelEbYYctS87elaSazbRHplWILailxNfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhZn5H)GfgykHKfMY3tPyKJ1WhR0pxbe9kJ8RRule(CUQMmWkVWu(NRaIERvszfw)ZvarVbGMHCW45aeQbHwQKKwi85CvnzGvEHP8pxbe9kPCsccFoxvtgyLxyk)ZvarVsXSTIwQRE3e88vbZksrlRdqeu51Bqq1VhFssux9UzCeubx4CFOQbXndL6xHbwl0c8ZQOoCqrg8v9LoVhh)0CEBaR0pxbe9gLnQREpdUg)pyPqD17MXrqfCHZ9HQge3SIssux9UzCeubx4CFOQbXZ4R6lDEpo(P5CZkQDssac1GqlLj45RcMHs9RWadGn(ZvarVrztac1GqlLbCn(FWsH1QRE3e88vbZksrlRdqeu51BQd1(N7oLKyncFoxvtMaSqabIYGeoEfARW6aebvE9gGIpNxjjbicQ86n1HA)ZDNuGWNZv1KjaleqGOmiHJxbfbiudcTuMaSqabIY)oLXr3Cp2SIuyDac1GqlLj45RcMvKIwTux9UHc6lctz9Q8XmuQFfUrLbqsI6Q3nuqFrykJHAFmdL6xHBuza0wH1ZQOoCqrgvx7vGYWE2168VFfkCssl1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGucTjjQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daPeGOD7Ke1vVBa6kWHaZuAe0cnPu9zQOb11aYSIANK0pu7FEOu)kmGbiassq4Z5QAYaR8ct5FUci6vcaTvGWNZv1K5QmQai3Kh(dwyGPeswykFpLIrowdFSs)Cfq0dqKFDLAHWNZv1Kbw5fMY)Cfq0BTsauH1)Cfq0Bu2mKdgphGqni0sLKGWNZv1Kbw5fMY)Cfq0Reav0sD17MGNVkywrkAzDaIGkVEdcQ(94tsI6Q3nJJGk4cN7dvniUzOu)kmWAHwGFwf1HdkYGVQV05944NMZBdyL(5kGO3aqJ6Q3ZGRX)dwkux9UzCeubx4CFOQbXnROKe1vVBghbvWfo3hQAq8m(Q(sN3JJFAo3SIANKeGqni0szcE(QGzOu)kmWayJ)Cfq0BaOjaHAqOLYaUg)pyPWA1vVBcE(QGzfPOL1bicQ86n1HA)ZDNssSgHpNRQjtawiGarzqchVcTvyDaIGkVEdqXNZlfTSwD17MGNVkywrjjwhGiOYR3GGQFp(0ojjarqLxVPou7FU7Kce(CUQMmbyHaceLbjC8kOiaHAqOLYeGfciqu(3Pmo6M7XMvKcRdqOgeAPmbpFvWSIu0QL6Q3nuqFrykRxLpMHs9RWnQmassux9UHc6lctzmu7JzOu)kCJkdG2kSEwf1HdkYO6AVcug2ZUwN)9RqHtsAPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaKsOnjrD17gvx7vGYWE2168VFfkC2NGxKb)EaiLaeTB3ojrD17gGUcCiWmLgbTqtkvFMkAqDnGmROKevigROFO2)8qP(vyadqaKKGWNZv1Kbw5fMY)Cfq0ReaARaHpNRQjZvzubqUjKMLMbtywCTMf4VtdlWILfMy5EkfZcSyjaYn5H)GfgykHKfMY3tPyUjKMLymfoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdZn5H)GfgykHKzvzp8hSY6d)iV8usjhsih)ZfELug5xxje(CUQMmho7qIBYd)blmWucjZQYE4pyL1h(rE5PKsQq)ro(Nl8kPmYVUsZQOoCqrgvx7vGYWE2168VFfkSHqV1ffrGCtE4pyHbMsizwv2d)bRS(WpYlpLuc)CtCtinlOX1HL2FcZILD63PHLFNyjgpKNg8pStdlQRENflNwZs31AwG9olwUF)kw(DILIq2ZsWXp3Kh(dwyJdjLq4Z5QAc5LNskboKNMTCADU7ADg27ihHRxKsTux9U5VuYcCQm4qEQ6vG0ygk1VcdyubqtQJmGbaJYjjQRE38xkzbovgCipv9kqAmdL6xHbSh(dwg87t)gYqiJcRNY)LsadagLv0Ic6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXR45Iq23UTc1vVB(lLSaNkdoKNQEfinMvKIzvuhoOiZFPKf4uzWH8u1RaPHBcPzbnUoS0(tywSSt)onSS9(GxdkILdZIf487SeC8FfkwGiOHLT3N(nelxXIvUkFyb9d6lctCtE4pyHnoKaMsibHpNRQjKxEkP0HQGdLXVp41GIqocxViLSMc6lctMRYyO2hfTWrKwNFFqrp2GFF63qnIwfVRP6ny4sNH98Vt5oCi8BOYv1eyscoI0687dk6Xg87t)gQravBUjKMLMbtSGgyHaceXILDQyXFw0egZYV7flOfaS0qmGKfVazrFfXYkIfl3VZcAAisIHkWn5H)Gf24qcykHKaSqabIY)oLXr3Cpg5xxjRbN1bAkyoaIv0QfcFoxvtMaSqabIYGeoEfuyDac1GqlLj45RcMHCW4jjQRE3e88vbZkQTIwQRE3qb9fHPSEv(ygk1Vc3iGojrD17gkOVimLXqTpMHs9RWncOBROL1ZQOoCqrgvx7vGYWE2168VFfkCsI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9aqngZKe1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGAmMTtsuHySI(HA)ZdL6xHbSYaqH1biudcTuMGNVkygYbJ3MBcPzPzWelnVHQgeNfl3VZcAAisIHkWn5H)Gf24qcykHKXrqfCHZ9HQgeh5xxj1vVBcE(QGzOu)kCJkJwUjKMLMbtSSTQ(nelxXsKxGu6fybwS4v8F)kuS87(ZI(qqywu2kWuaZIxGSOjmMfl3VZskCiwEFqrpMfVazXFw(DIfQazb2zXzzdQ9Hf0pOVimXI)SOSvWcMcywGdlAcJzzOu)QRqXIJz5HSuWNLDhXvOy5HSmuFi8olGR5kuSyLRYhwq)G(IWe3Kh(dwyJdjGPesWRQFdH8q8GMYVpOOhRKYi)6k1AO(q4DxvtjjQRE3qb9fHPmgQ9XmuQFfgWXubf0xeMmxLXqTpkgk1VcdyLTcfVRP6ny4sNH98Vt5oCi8BOYv1eyBfVpOO38xkLFyg8Ogv2kAoCeP153hu0Jb2qP(vyfTOG(IWK5QSxXtsgk1VcdyubqtQJS2CtinlndMyzBv9BiwEil7ocIfNfuAOQRz5HSSWelXqmYXyUjp8hSWghsatjKGxv)gc5xxje(CUQMmh6bMdWc8(dwkcqOgeAPmxHdZ6DvnLrVLx)kndsiUazgYbJRGqV1ffrGMRWHz9UQMYO3YRFLMbjexG4M8WFWcBCibmLqc(9P7AnYVUsw)UMQ3GFsR9jdox)nu5QAcurl1vVBWVpDxRnd1hcV7QAsrlCeP153hu0Jn43NUR1aoMjjwpRI6Wbfz(lLSaNkdoKNQEfinTtsExt1BWWLod75FNYD4q43qLRQjqfQRE3qb9fHPmgQ9XmuQFfgWXubf0xeMmxLXqTpkux9Ub)(0DT2muQFfgWakf4isRZVpOOhBWVpDxRBujROTIwwpRI6Wbfz0Xd(44Cxt0FfQmk9LgHPKK)sjKks1kqBJQRE3GFF6UwBgk1Vcdma2wX7dk6n)Ls5hMbpQr0YnH0SGuC)olBpP1(WsmEU(ZYctSalwcGSyzNkwgQpeE3v1elQRNf8FAnlw87zPdhwSY4bFCmlrdmWIxGSacl09SSWelQuhoelOjgJnSS9NwZYctSOsD4qSGgyHaceXc(QaXYV7plwoTMLObgyXl4VtdlBVpDxR5M8WFWcBCibmLqc(9P7AnYVUsVRP6n4N0AFYGZ1FdvUQMavOU6Dd(9P7ATzO(q4DxvtkAz9SkQdhuKrhp4JJZDnr)vOYO0xAeMss(lLqQivRaTnAfTv8(GIEZFPu(HzWJAmMCtinlif3VZsmEipv9kqAyzHjw2EF6UwZYdzbiIIyzfXYVtSOU6DwuJZIRXqww4RqXY27t31AwGflOLfmfGfiMf4WIMWywgk1V6kuCtE4pyHnoKaMsib)(0DTg5xxPzvuhoOiZFPKf4uzWH8u1RaPrboI0687dk6Xg87t316gvkMkAzT6Q3n)LswGtLbhYtvVcKgZksH6Q3n43NUR1MH6dH3DvnLK0cHpNRQjd4qEA2YP15UR1zyVROL6Q3n43NUR1MHs9RWaoMjj4isRZVpOOhBWVpDxRBeGkExt1BWpP1(KbNR)gQCvnbQqD17g87t31AZqP(vyaJ22TBZnH0SGgxhwA)jmlw2PFNgwCw2EFWRbfXYctSy50Awc(ctSS9(0DTMLhYs31AwG9oYzXlqwwyILT3h8AqrS8qwaIOiwIXd5PQxbsdl43daXYkIBYd)blSXHeWucji85CvnH8YtjLWVpDxRZwG1N7UwNH9oYr46fPKJ)X15iOfAAeqaGMRLYaa4vx9U5VuYcCQm4qEQ6vG0yWVhaQDZ1sD17g87t31AZqP(vyGpMivCeP15Dh)eWB97AQEd(jT2Nm4C93qLRQjW2nxRaeQbHwkd(9P7ATzOu)kmWhtKkoI068UJFc4Fxt1BWpP1(KbNR)gQCvnb2U5AbcFtFnXZWEM0RImdL6xHbE02wrl1vVBWVpDxRnROKKaeQbHwkd(9P7ATzOu)kCBUjKMLMbtSS9(GxdkIfl3VZsmEipv9kqAy5HSaerrSSIy53jwux9olwUFhUEw0q8vOyz79P7AnlRO)sjw8cKLfMyz79bVguelWIfRaySelydTkl43daHzzv)PzXky59bf9yUjp8hSWghsatjKGFFWRbfH8RRecFoxvtgWH80SLtRZDxRZWExbcFoxvtg87t316Sfy95UR1zyVRWAe(CUQMmhQcoug)(GxdkkjPL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9aqngZKe1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGAmMTvGJiTo)(GIESb)(0DTgWwHce(CUQMm43NUR1zlW6ZDxRZWENBcPzPzWelyl(KYcgYYV7plXHlwqrplPoYyzf9xkXIACww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz539ILyYc(9aqywGdliLSWplw2PILycmwWVhacZcHSOBiUjp8hSWghsatjK4GE0FiOm2IpPipepOP87dk6XkPmYVUsw)xaORqPWAp8hSmoOh9hckJT4tAg0tDuK5QCxFO2)Keq4BCqp6peugBXN0mON6Oid(9aqaoMkaHVXb9O)qqzSfFsZGEQJImdL6xHbCm5MqAwIrP(q4DwA(GWQFdXY1zbnnejXqfy5WSmKdgh5S870qS4dXIMWyw(DVybTS8(GIEmlxXIvUkFyb9d6lctSy5(Dw2GFZd5SOjmMLF3lwugaSa)DASCyILRyXR4SG(b9fHjwGdlRiwEilOLL3hu0JzrL6WHyXzXkxLpSG(b9fHjdlXyyHUNLH6dH3zbCnxHIfKYxboeilOFAe0cnPu9SSknHXSCflBqTpSG(b9fHjUjp8hSWghsatjKKcHv)gc5H4bnLFFqrpwjLr(1vAO(q4DxvtkEFqrV5Vuk)Wm4rn2QLYwbWAHJiTo)(GIESb)(0VHaEac8QRE3qb9fHPSEv(ywrTBdSHs9RWTrQTugyVRP6nVLRYPqyHnu5QAcSTIwbiudcTuMGNVkygYbJRWAWzDGMcMdGyfTq4Z5QAYeGfciqugKWXRqssac1GqlLjaleqGO8VtzC0n3Jnd5GXtsSoarqLxVPou7FU7u7KeCeP153hu0Jn43N(neGB1cq3CTux9UHc6lctz9Q8XSIaEa2UnW3szG9UMQ38wUkNcHf2qLRQjW2Tvynf0xeMmyO2NCri7tsArb9fHjZvzmu7tsslkOVimzUkRc)9KekOVimzUkRxLpTvy97AQEdgU0zyp)7uUdhc)gQCvnbMKOU6Dt0CPWb8CD2NGxxihT0yFmiC9IAujaIwa0wrlCeP153hu0Jn43N(neGvgaaFlLb27AQEZB5QCkewydvUQMaB3wHJ)X15iOfAAeTaO5ux9Ub)(0DT2muQFfg4b0Tv0YA1vVBa6kWHaZuAe0cnPu9zQOb11aYSIssOG(IWK5QmgQ9jjX6aebvE9gGIpNxTvyT6Q3nJJGk4cN7dvniEgFvFPZ7XXpnNBwrCtinlndMyP5bJnlWILailwUFhUEwcEu0vO4M8WFWcBCibmLqshobkd75Y)1qi)6k5r5WofaIBYd)blSXHeWucji85CvnH8YtjLcG5aSaV)Gv2HeYr46fPK1GZ6anfmhaXkq4Z5QAYeaZbybE)blfTAPU6Dd(9P7ATzfLK8UMQ3GFsR9jdox)nu5QAcmjjarqLxVPou7FU7uBfTSwD17gmuJ)lqMvKcRvx9Uj45RcMvKIww)UMQ30xt8mSNj9QidvUQMatsux9Uj45RcgW14)bRgdqOgeAPm91epd7zsVkYmuQFfgyaI2kq4Z5QAY87ZP1zmrart2IFVIwwhGiOYR3uhQ9p3DkjjaHAqOLYeGfciqu(3Pmo6M7XMvKIwQRE3GFF6UwBgk1VcdyaMKy97AQEd(jT2Nm4C93qLRQjW2Tv8(GIEZFPu(HzWJAuD17MGNVkyaxJ)hSaEayauTtsuHySI(HA)ZdL6xHbS6Q3nbpFvWaUg)py1MBcPzPzWelOPHijgQalWILailRstymlEbYI(kIL7zzfXIL73zbnWcbeiIBYd)blSXHeWucjbst4)CD21hQkLQh5xxje(CUQMmbWCawG3FWk7qIBYd)blSXHeWucjxf8P8)GfYVUsi85CvnzcG5aSaV)Gv2He3esZsZGjwq)0iOfAyjwWcKfyXsaKfl3VZY27t31AwwrS4filyhbXshoSaixASpS4filOPHijgQa3Kh(dwyJdjGPesO0iOfAYQWce5xxPREAIGA)jWC)qT)5Hs9RWawz0MK0sD17MO5sHd456SpbVUqoAPX(yq46fbyaIwaKKOU6Dt0CPWb8CD2NGxxihT0yFmiC9IAujaIwa0wH6Q3n43NUR1MvKIwbiudcTuMGNVkygk1Vc3iAbqsc4SoqtbZbqCBUjKMLyuQpeENLU2hIfyXYkILhYsmz59bf9ywSC)oC9SGMgIKyOcSOsxHIfxfUEwEileYIUHyXlqwk4Zcebnbpk6kuCtE4pyHnoKaMsib)Kw7tUR9HqEiEqt53hu0JvszKFDLgQpeE3v1KI)sP8dZGh1OYOvboI0687dk6Xg87t)gcWwHcpkh2PaqkAPU6DtWZxfmdL6xHBuzaKKyT6Q3nbpFvWSIAZnH0S0myILMhe9z56SCf(ajw8If0pOVimXIxGSOVIy5EwwrSy5(DwCwaKln2hwIgyGfVazPHGE0Fiiw2S4tk3Kh(dwyJdjGPes6RjEg2ZKEveYVUsuqFryYCv2R4k8OCyNcaPqD17MO5sHd456SpbVUqoAPX(yq46fbyaIwaOOfi8noOh9hckJT4tAg0tDuK5VaqxHkjX6aebvE9MIcdudhWKeCeP153hu0JBeGTv0sD17MXrqfCHZ9HQge3muQFfgWa3MRfAb(zvuhoOid(Q(sN3JJFAoVTc1vVBghbvWfo3hQAqCZkkjXA1vVBghbvWfo3hQAqCZkQTIwwhGqni0szcE(QGzfLKOU6DZVpNwNXebeng87bGaSYOvr)qT)5Hs9RWagGaaak6hQ9ppuQFfUrLbaassSgdxA1Ran)(CADgteq0yOYv1eyBfTWWLw9kqZVpNwNXebengQCvnbMKeGqni0szcE(QGzOu)kCJXeaT5MqAwAgmXIZY27t31AwA(l63zjAGbwwLMWyw2EF6UwZYHzX1d5GXzzfXcCyjoCXIpelUkC9S8qwGiOj4rS0qmGKBYd)blSXHeWucj43NUR1i)6kPU6DdSOFhNJOjqr)blZksrl1vVBWVpDxRnd1hcV7QAkjXX)46Ce0cnncCbqBUjKMLy8knILgIbKSOsD4qSGgyHaceXIL73zz79P7AnlEbYYVtflBVp41GI4M8WFWcBCibmLqc(9P7AnYVUsbicQ86n1HA)ZDNuy97AQEd(jT2Nm4C93qLRQjqfTq4Z5QAYeGfciqugKWXRqssac1GqlLj45RcMvusI6Q3nbpFvWSIARiaHAqOLYeGfciqu(3Pmo6M7XMHs9RWagva0K6id4d0PB54FCDocAHgKkAbqBfQRE3GFF6UwBgk1VcdyRqH1GZ6anfmhaXCtE4pyHnoKaMsib)(Gxdkc5xxPaebvE9M6qT)5UtkAHWNZv1KjaleqGOmiHJxHKKaeQbHwktWZxfmROKe1vVBcE(QGzf1wrac1GqlLjaleqGO8VtzC0n3JndL6xHbmGwH6Q3n43NUR1MvKckOVimzUk7vCfwJWNZv1K5qvWHY43h8AqrkSgCwhOPG5aiMBcPzPzWelBVp41GIyXY97S4fln)f97SenWalWHLRZsC4cDGSarqtWJyPHyajlwUFNL4W1Wsri7zj443Wsd1yilGR0iwAigqYI)S87elubYcSZYVtSeJGQFp(WI6Q3z56SS9(0DTMflWLgSq3Zs31AwG9olWHL4Wfl(qSalwailVpOOhZn5H)Gf24qcykHe87dEnOiKFDLux9Ubw0VJZbn5tgXHpyzwrjjTSg)(0VHmEuoStbGuyncFoxvtMdvbhkJFFWRbfLK0sD17MGNVkygk1Vcdy0QqD17MGNVkywrjjTAPU6DtWZxfmdL6xHbmQaOj1rgWhOt3YX)46Ce0cni1ycG2kux9Uj45RcMvusI6Q3nJJGk4cN7dvniEgFvFPZ7XXpnNBgk1VcdyubqtQJmGpqNULJ)X15iOfAqQXeaTvOU6DZ4iOcUW5(qvdINXx1x68EC8tZ5MvuBfbicQ86niO63JpTBROfoI0687dk6Xg87t31AahZKee(CUQMm43NUR1zlW6ZDxRZWEVDBfwJWNZv1K5qvWHY43h8AqrkAz9SkQdhuK5VuYcCQm4qEQ6vG0KKGJiTo)(GIESb)(0DTgWXSn3esZsZGjwA(GWcZYvSSb1(Wc6h0xeMyXlqwWocILM3sRzP5dclw6WHf00qKedvGBYd)blSXHeWucjfzjNcHfYVUsTux9UHc6lctzmu7JzOu)kCJeYOW6P8FPussRWUpOiSsauXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbG4M8WFWcBCibmLqYUR75uiSq(1vQL6Q3nuqFrykJHAFmdL6xHBKqgfwpL)lLssAf29bfHvcGkgkS7dkk)xkby02ojjS7dkcRumBRWJYHDkaKIwQRE3mocQGlCUpu1G4MHs9RWagTkux9UzCeubx4CFOQbXnRifwpRI6WbfzWx1x68EC8tZ5jjwRU6DZ4iOcUW5(qvdIBwrT5M8WFWcBCibmLqsFP15uiSq(1vQL6Q3nuqFrykJHAFmdL6xHBKqgfwpL)lLu0kaHAqOLYe88vbZqP(v4grlasscqOgeAPmbyHaceL)DkJJU5ESzOu)kCJOfaTtsAf29bfHvcGkgkS7dkk)xkby02ojjS7dkcRumBRWJYHDkaKIwQRE3mocQGlCUpu1G4MHs9RWagTkux9UzCeubx4CFOQbXnRifwpRI6WbfzWx1x68EC8tZ5jjwRU6DZ4iOcUW5(qvdIBwrT5MqAwAgmXcsbe9zbwSGMym3Kh(dwyJdjGPesS4ZCWjd7zsVkIBcPzbnUoS0(tywSSt)onS8qwwyILT3N(nelxXYgu7dlw2VWolhMf)zbTS8(GIEmWuMLoCyHqqtCwaiaqQSK64NM4SahwScw2EFWRbfXc6NgbTqtkvpl43daH5M8WFWcBCibmLqccFoxvtiV8usj87t)gkFvgd1(GCeUErkHJiTo)(GIESb)(0VHA0kawxdHtRuh)0epJW1lc4vgaaaPcqa0gyDneoTux9Ub)(GxdkktPrql0Ks1NXqTpg87bGqQwrBUjKMf046Ws7pHzXYo970WYdzbPy8FNfW1CfkwAEdvnio3Kh(dwyJdjGPesq4Z5QAc5LNskzz8FpFvUpu1G4ihHRxKskJuXrKwN3D8tagGnxlayaiW3chrAD(9bf9yd(9PFd1Ck3g4BPmWExt1BWWLod75FNYD4q43qLRQjqGxzdAB3gyaWOmAbE1vVBghbvWfo3hQAqCZqP(vyUjKMLMbtSGum(VZYvSSb1(Wc6h0xeMyboSCDwkilBVp9BiwSCAnl97z5QhYcAAisIHkWIxXtHdXn5H)Gf24qcykHelJ)7i)6k1Ic6lctg9Q8jxeY(KekOVimz8kEUiK9kq4Z5QAYC4CqtocQTIwVpOO38xkLFyg8OgTIKekOVimz0RYN8vzaMK0pu7FEOu)kmGvgaTtsux9UHc6lctzmu7JzOu)kmG9WFWYGFF63qgczuy9u(VusH6Q3nuqFrykJHAFmROKekOVimzUkJHAFuyncFoxvtg87t)gkFvgd1(KKOU6DtWZxfmdL6xHbSh(dwg87t)gYqiJcRNY)LskSgHpNRQjZHZbn5iifQRE3e88vbZqP(vyatiJcRNY)Lskux9Uj45RcMvusI6Q3nJJGk4cN7dvniUzfPaHpNRQjJLX)98v5(qvdINKyncFoxvtMdNdAYrqkux9Uj45RcMHs9RWnsiJcRNY)LsCtinlndMyz79PFdXY1z5kwSYv5dlOFqFryc5SCflBqTpSG(b9fHjwGflwbWy59bf9ywGdlpKLObgyzdQ9Hf0pOVimXn5H)Gf24qcykHe87t)gIBcPzP55A9VplUjp8hSWghsatjKmRk7H)GvwF4h5LNsk1DT(3Nf3e3esZsZBOQbXzXY97SGMgIKyOcCtE4pyHnQq)vACeubx4CFOQbXr(1vsD17MGNVkygk1Vc3OYOLBcPzPzWelne0J(dbXYMfFszXYovS4plAcJz539IfRGLybBOvzb)EaimlEbYYdzzO(q4DwCwaSsaKf87bGyXXSO9NyXXSebX4tvtSahw(lLy5EwWqwUNfFMdbHzbPKf(zX7pnS4SetGXc(9aqSqil6gcZn5H)Gf2Oc9hykHeh0J(dbLXw8jf5H4bnLFFqrpwjLr(1vsD17gvx7vGYWE2168VFfkCU8FnKb)EaiadiuOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpaeGbekAzni8noOh9hckJT4tAg0tDuK5VaqxHsH1E4pyzCqp6peugBXN0mON6OiZv5U(qT)kAzni8noOh9hckJT4tAENCT5VaqxHkjbe(gh0J(dbLXw8jnVtU2muQFfUXy2ojbe(gh0J(dbLXw8jnd6PokYGFpaeGJPcq4BCqp6peugBXN0mON6OiZqP(vyaJwfGW34GE0FiOm2IpPzqp1rrM)caDfQ2CtinlndMybnWcbeiIfl3VZcAAisIHkWILDQyjcIXNQMyXlqwG)onwomXIL73zXzjwWgAvwux9olw2PIfqchVcxHIBYd)blSrf6pWucjbyHaceL)DkJJU5EmYVUswdoRd0uWCaeROvle(CUQMmbyHaceLbjC8kOW6aeQbHwktWZxfmd5GXtsux9Uj45RcMvuBfTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhasjarsI6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqkbiANKOcXyf9d1(Nhk1VcdyLbqBUjKMLMhe9zXXS87el9BWplOcGSCfl)oXIZsSGn0QSy5kqOfwGdlwUFNLFNybPC858If1vVZcCyXY97S4SaiagMcS0qqp6peelBw8jLfVazXIFplD4WcAAisIHkWY1z5EwSaRNfvILvelok)kwuPoCiw(DILailhML(vhENa5M8WFWcBuH(dmLqsFnXZWEM0RIq(1vQvRwQRE3O6AVcug2ZUwN)9RqHZL)RHm43da1iGojrD17gvx7vGYWE2168VFfkC2NGxKb)EaOgb0Tv0Y6aebvE9geu97XNKeRvx9UzCeubx4CFOQbXnRO2Tv0cCwhOPG5aiojjaHAqOLYe88vbZqP(v4grlassAfGiOYR3uhQ9p3Dsrac1GqlLjaleqGO8VtzC0n3JndL6xHBeTaOD72jjTaHVXb9O)qqzSfFsZGEQJImdL6xHBeqOiaHAqOLYe88vbZqP(v4gvgakcqeu51BkkmqnCaBNKC1tteu7pbM7hQ9ppuQFfgWacfwhGqni0szcE(QGzihmEssaIGkVEdqXNZlfQRE3a0vGdbMP0iOfAsP6nROKKaebvE9geu97XhfQRE3mocQGlCUpu1G4MHs9RWag4QqD17MXrqfCHZ9HQge3SI4MqAwqJxbsZY27JgoGSy5(DwCwkYclXc2qRYI6Q3zXlqwqtdrsmubwoCHUNfxfUEwEilQellmbYn5H)Gf2Oc9hykHKGxbsNvx9oYlpLuc)(OHdiYVUsTux9Ur11EfOmSNDTo)7xHcNl)xdzgk1Vc3iGYG2Ke1vVBuDTxbkd7zxRZ)(vOWzFcErMHs9RWncOmOTTIwbiudcTuMGNVkygk1Vc3iGkjPvac1GqlLHsJGwOjRclqZqP(v4gbukSwD17gGUcCiWmLgbTqtkvFMkAqDnGmRifbicQ86nafFoVA3wHJ)X15iOfAAuPycaUjKMLy8knILT3h8AqrywSC)ololXc2qRYI6Q3zrD9SuWNfl7uXseeQVcflD4WcAAisIHkWcCybP8vGdbYYw0n3J5M8WFWcBuH(dmLqc(9bVgueYVUsTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhaQraMKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpauJaSTIwbicQ86n1HA)ZDNsscqOgeAPmbpFvWmuQFfUravsI1i85CvnzcG5aSaV)GLcRdqeu51Bak(CELK0kaHAqOLYqPrql0KvHfOzOu)kCJakfwRU6DdqxboeyMsJGwOjLQptfnOUgqMvKIaebvE9gGIpNxTBROL1GW30xt8mSNj9QiZFbGUcvsI1biudcTuMGNVkygYbJNKyDac1GqlLjaleqGO8VtzC0n3Jnd5GXBZnH0SeJxPrSS9(GxdkcZIk1HdXcAGfciqe3Kh(dwyJk0FGPesWVp41GIq(1vQvac1GqlLjaleqGO8VtzC0n3JndL6xHbmAvyn4SoqtbZbqSIwi85CvnzcWcbeikds44vijjaHAqOLYe88vbZqP(vyaJ22kq4Z5QAYeaZbybE)bR2kSge(M(AINH9mPxfz(la0vOueGiOYR3uhQ9p3DsH1GZ6anfmhaXkOG(IWK5QSxXv44FCDocAHMgTcaWnH0SeJHf6EwaHplGR5kuS87elubYcSZsmQJGk4cZsZBOQbXrolGR5kuSa0vGdbYcLgbTqtkvplWHLRy53jw0o(zbvaKfyNfVyb9d6lctCtE4pyHnQq)bMsibHpNRQjKxEkPei8ZdHERBOuQEmYr46fPul1vVBghbvWfo3hQAqCZqP(v4grBsI1QRE3mocQGlCUpu1G4MvuBfTux9UbORahcmtPrql0Ks1NPIguxdiZqP(vyaJkaAsDK1wrl1vVBOG(IWugd1(ygk1Vc3iQaOj1rwsI6Q3nuqFrykRxLpMHs9RWnIkaAsDK1MBYd)blSrf6pWucj4v1VHqEiEqt53hu0JvszKFDLgQpeE3v1KI3hu0B(lLYpmdEuJkdOv4r5WofasbcFoxvtgq4Nhc9w3qPu9yUjp8hSWgvO)atjKKcHv)gc5H4bnLFFqrpwjLr(1vAO(q4DxvtkEFqrV5Vuk)Wm4rnQCmnOvHhLd7uaifi85CvnzaHFEi0BDdLs1J5M8WFWcBuH(dmLqc(jT2NCx7dH8q8GMYVpOOhRKYi)6knuFi8URQjfVpOO38xkLFyg8OgvgqdSHs9RWk8OCyNcaPaHpNRQjdi8ZdHERBOuQEm3esZsZdgBwGflbqwSC)oC9Se8OORqXn5H)Gf2Oc9hykHKoCcug2ZL)RHq(1vYJYHDkae3esZc6NgbTqdlXcwGSyzNkwCv46z5HSq1tdlolfzHLybBOvzXYvGqlS4filyhbXshoSGMgIKyOcCtE4pyHnQq)bMsiHsJGwOjRclqKFDLArb9fHjJEv(KlczFscf0xeMmyO2NCri7tsOG(IWKXR45Iq2NKOU6DJQR9kqzyp7AD(3Vcfox(VgYmuQFfUraLbTjjQRE3O6AVcug2ZUwN)9RqHZ(e8ImdL6xHBeqzqBsIJ)X15iOfAAe4cafbiudcTuMGNVkygYbJRWAWzDGMcMdG42kAfGqni0szcE(QGzOu)kCJXeajjbiudcTuMGNVkygYbJ3oj5QNMiO2Fcm3pu7FEOu)kmGvgaCtinlnpi6ZYCO2FwuPoCiww4RqXcAAi3Kh(dwyJk0FGPes6RjEg2ZKEveYVUsbiudcTuMGNVkygYbJRaHpNRQjtamhGf49hSu0YX)46Ce0cnncCbGcRdqeu51BQd1(N7oLKeGiOYR3uhQ9p3DsHJ)X15iOfAaSvaG2kSoarqLxVbbv)E8rrlRdqeu51BQd1(N7oLKeGqni0szcWcbeik)7ughDZ9yZqoy82kSgCwhOPG5aiMBcPzbnnejXqfyXYovS4plaxaamwAigqYsl4OHwOHLF3lwScaWsdXaswSC)olObwiGarTzXY97W1ZIgIVcfl)LsSCflXsdHG6f(zXlqw0xrSSIyXY97SGgyHaceXY1z5EwS4ywajC8kqGCtE4pyHnQq)bMsibHpNRQjKxEkPuamhGf49hSYQq)rocxViLSgCwhOPG5aiwbcFoxvtMayoalW7pyPOvlh)JRZrql00iWfakAPU6DdqxboeyMsJGwOjLQptfnOUgqMvusI1bicQ86nafFoVANKOU6DJQgcb1l8Bwrkux9UrvdHG6f(ndL6xHbS6Q3nbpFvWaUg)py1oj5QNMiO2Fcm3pu7FEOu)kmGvx9Uj45RcgW14)bRKKaebvE9M6qT)5UtTv0Y6aebvE9M6qT)5UtjjTC8pUohbTqdGTcaKKacFtFnXZWEM0RIm)fa6kuTv0cHpNRQjtawiGarzqchVcjjbiudcTuMaSqabIY)oLXr3Cp2mKdgVDBUjp8hSWgvO)atjKeinH)Z1zxFOQuQEKFDLq4Z5QAYeaZbybE)bRSk0FUjp8hSWgvO)atjKCvWNY)dwi)6kHWNZv1KjaMdWc8(dwzvO)CtinlOp(Vu)jml7qlSKUc7S0qmGKfFiwq5xrGSerdlykalqUjp8hSWgvO)atjKGWNZv1eYlpLuYXrasA2OaYr46fPef0xeMmxL1RYhGhqGu9WFWYGFF63qgczuy9u(Vucywtb9fHjZvz9Q8b4BbOb27AQEdgU0zyp)7uUdhc)gQCvnbc8XSns1d)blJLX)DdHmkSEk)xkbmayaisfhrADE3XpXnH0SeJxPrSS9(GxdkcZILDQy53jw6hQ9NLdZIRcxplpKfQarol9HQgeNLdZIRcxplpKfQarolXHlw8HyXFwaUaayS0qmGKLRyXlwq)G(IWeYzbnnejXqfyr74hZIxWFNgwaeadtbmlWHL4WflwGlnilqe0e8iwsHdXYV7flCIYaGLgIbKSyzNkwIdxSybU0Gf6Ew2EFWRbfXsbTWn5H)Gf2Oc9hykHe87dEnOiKFDLAD1tteu7pbM7hQ9ppuQFfgWwrssl1vVBghbvWfo3hQAqCZqP(vyaJkaAsDKb8b60TC8pUohbTqdsnMaOTc1vVBghbvWfo3hQAqCZkQD7KKwo(hxNJGwObyi85CvnzCCeGKMnka8QRE3qb9fHPmgQ9XmuQFfgyGW30xt8mSNj9QiZFbGW5Hs9RaEaAqBJkRmassC8pUohbTqdWq4Z5QAY44iajnBua4vx9UHc6lctz9Q8XmuQFfgyGW30xt8mSNj9QiZFbGW5Hs9RaEaAqBJkRmaARGc6lctMRYEfxrlRvx9Uj45RcMvusI1VRP6n43hnCanu5QAcSTIwTSoaHAqOLYe88vbZkkjjarqLxVbO4Z5LcRdqOgeAPmuAe0cnzvybAwrTtscqeu51BQd1(N7o1wrlRdqeu51Bqq1VhFssSwD17MGNVkywrjjo(hxNJGwOPrGlaANK06DnvVb)(OHdOHkxvtGkux9Uj45RcMvKIwQRE3GFF0Wb0GFpaeGJzsIJ)X15iOfAAe4cG2Ttsux9Uj45RcMvKcRvx9UzCeubx4CFOQbXnRifw)UMQ3GFF0Wb0qLRQjqUjKMLMbtS08bHfMLRyXkxLpSG(b9fHjw8cKfSJGyjgjUUdSM3sRzP5dclw6WHf00qKedvGBYd)blSrf6pWucjfzjNcHfYVUsTux9UHc6lctz9Q8XmuQFfUrczuy9u(VukjPvy3huewjaQyOWUpOO8FPeGrB7KKWUpOiSsXSTcpkh2PaqCtE4pyHnQq)bMsiz319Ckewi)6k1sD17gkOVimL1RYhZqP(v4gjKrH1t5)sjfTcqOgeAPmbpFvWmuQFfUr0cGKKaeQbHwktawiGar5FNY4OBUhBgk1Vc3iAbq7KKwHDFqryLaOIHc7(GIY)LsagTTtsc7(GIWkfZ2k8OCyNcaXn5H)Gf2Oc9hykHK(sRZPqyH8RRul1vVBOG(IWuwVkFmdL6xHBKqgfwpL)lLu0kaHAqOLYe88vbZqP(v4grlasscqOgeAPmbyHaceL)DkJJU5ESzOu)kCJOfaTtsAf29bfHvcGkgkS7dkk)xkby02ojjS7dkcRumBRWJYHDkae3esZcsbe9zbwSea5M8WFWcBuH(dmLqIfFMdozypt6vrCtinlndMyz79PFdXYdzjAGbw2GAFyb9d6lctSahwSStflxXcS0XzXkxLpSG(b9fHjw8cKLfMybPaI(SenWaMLRZYvSyLRYhwq)G(IWe3Kh(dwyJk0FGPesWVp9BiKFDLOG(IWK5QSEv(KKqb9fHjdgQ9jxeY(KekOVimz8kEUiK9jjQRE3yXN5Gtg2ZKEvKzfPqD17gkOVimL1RYhZkkjPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKrH1t5)sjfQRE3e88vbZkQn3Kh(dwyJk0FGPesSm(VZn5H)Gf2Oc9hykHKzvzp8hSY6d)iV8usPUR1)(S4M4MqAw2EFWRbfXshoSKcrqPu9SSknHXSSWxHILybBOv5M8WFWcB6Uw)7Zsj87dEnOiKFDLSEwf1HdkYO6AVcug2ZUwN)9RqHne6TUOicKBcPzbno(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9gw2wv)gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQFdXc4A8)Gf3Kh(dwyt316FFwatjKGxv)gc5H4bnLFFqrpwjLr(1vce(MuiS63qMHs9RWnouQFfg4biarQkdi4M8WFWcB6Uw)7ZcykHKuiS63qCtCtinlndMyz79bVguelpKfGikILvel)oXsmEipv9kqAyrD17SCDwUNflWLgKfczr3qSOsD4qS0V6W7xHILFNyPiK9SeC8ZcCy5HSaUsJyrL6WHybnWcbeiIBYd)blSb)kHFFWRbfH8RR0SkQdhuK5VuYcCQm4qEQ6vG0OOff0xeMmxL9kUcRB1sD17M)sjlWPYGd5PQxbsJzOu)kCJE4pyzSm(VBiKrH1t5)sjGbaJYkArb9fHjZvzv4VNKqb9fHjZvzmu7tscf0xeMm6v5tUiK9Ttsux9U5VuYcCQm4qEQ6vG0ygk1Vc3Oh(dwg87t)gYqiJcRNY)LsadagLv0Ic6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXR45Iq23UDsI1QRE38xkzbovgCipv9kqAmRO2jjTux9Uj45RcMvusccFoxvtMaSqabIYGeoEfARiaHAqOLYeGfciqu(3Pmo6M7XMHCW4kcqeu51BQd1(N7o1wrlRdqeu51Bak(CELKeGqni0szO0iOfAYQWc0muQFfUrarBfTux9Uj45RcMvusI1biudcTuMGNVkygYbJ3MBcPzPzWelne0J(dbXYMfFszXYovS870qSCywkilE4peelyl(KICwCmlA)jwCmlrqm(u1elWIfSfFszXY97SaqwGdlDYcnSGFpaeMf4WcSyXzjMaJfSfFszbdz539NLFNyPilSGT4tkl(mhccZcsjl8ZI3FAy539NfSfFszHqw0neMBYd)blSb)atjK4GE0FiOm2IpPipepOP87dk6XkPmYVUswdcFJd6r)HGYyl(KMb9uhfz(la0vOuyTh(dwgh0J(dbLXw8jnd6PokYCvURpu7VIwwdcFJd6r)HGYyl(KM3jxB(la0vOssaHVXb9O)qqzSfFsZ7KRndL6xHBeTTtsaHVXb9O)qqzSfFsZGEQJIm43dab4yQae(gh0J(dbLXw8jnd6PokYmuQFfgWXubi8noOh9hckJT4tAg0tDuK5VaqxHIBcPzPzWeMf0aleqGiwUolOPHijgQalhMLvelWHL4Wfl(qSas44v4kuSGMgIKyOcSy5(DwqdSqabIyXlqwIdxS4dXIkPHwyXkaalnedi5M8WFWcBWpWucjbyHaceL)DkJJU5EmYVUswdoRd0uWCaeROvle(CUQMmbyHaceLbjC8kOW6aeQbHwktWZxfmd5GXvy9SkQdhuKjAUu4aEUo7tWRlKJwASpjjQRE3e88vbZkQTch)JRZrql0ayLScaOOL6Q3nuqFrykRxLpMHs9RWnQmassux9UHc6lctzmu7JzOu)kCJkdG2jjQqmwr)qT)5Hs9RWawzaOW6aeQbHwktWZxfmd5GXBZnH0SGgybE)blw6WHfxRzbe(yw(D)zj1bIWSGxdXYVtXzXhQq3ZYq9HW7eilw2PILyuhbvWfMLM3qvdIZYUJzrtyml)UxSGwwWuaZYqP(vxHIf4WYVtSau858If1vVZYHzXvHRNLhYs31AwG9olWHfVIZc6h0xeMy5WS4QW1ZYdzHqw0ne3Kh(dwyd(bMsibHpNRQjKxEkPei8ZdHERBOuQEmYr46fPul1vVBghbvWfo3hQAqCZqP(v4grBsI1QRE3mocQGlCUpu1G4MvuBfwRU6DZ4iOcUW5(qvdINXx1x68EC8tZ5MvKIwQRE3a0vGdbMP0iOfAsP6ZurdQRbKzOu)kmGrfanPoYAROL6Q3nuqFrykJHAFmdL6xHBeva0K6iljrD17gkOVimL1RYhZqP(v4grfanPoYssAzT6Q3nuqFrykRxLpMvusI1QRE3qb9fHPmgQ9XSIARW631u9gmuJ)lqgQCvnb2MBcPzbnWc8(dwS87(ZsyNcaHz56SehUyXhIf46XhiXcf0xeMy5HSalDCwaHpl)onelWHLdvbhILF)WSy5(Dw2GA8FbIBYd)blSb)atjKGWNZv1eYlpLuce(z46XhiLPG(IWeYr46fPulRvx9UHc6lctzmu7JzfPWA1vVBOG(IWuwVkFmRO2jjVRP6nyOg)xGmu5QAcKBYd)blSb)atjKKcHv)gc5H4bnLFFqrpwjLr(1vAO(q4DxvtkAPU6Ddf0xeMYyO2hZqP(v4ghk1VcNKOU6Ddf0xeMY6v5JzOu)kCJdL6xHtsq4Z5QAYac)mC94dKYuqFryQTIH6dH3DvnP49bf9M)sP8dZGh1OYauHhLd7uaifi85CvnzaHFEi0BDdLs1J5M8WFWcBWpWucj4v1VHqEiEqt53hu0JvszKFDLgQpeE3v1KIwQRE3qb9fHPmgQ9XmuQFfUXHs9RWjjQRE3qb9fHPSEv(ygk1Vc34qP(v4Kee(CUQMmGWpdxp(aPmf0xeMARyO(q4DxvtkEFqrV5Vuk)Wm4rnQmav4r5WofasbcFoxvtgq4Nhc9w3qPu9yUjp8hSWg8dmLqc(jT2NCx7dH8q8GMYVpOOhRKYi)6knuFi8URQjfTux9UHc6lctzmu7JzOu)kCJdL6xHtsux9UHc6lctz9Q8XmuQFfUXHs9RWjji85CvnzaHFgUE8bszkOVim1wXq9HW7UQMu8(GIEZFPu(HzWJAuzaTcpkh2Paqkq4Z5QAYac)8qO36gkLQhZnH0S0myILMhm2SalwcGSy5(D46zj4rrxHIBYd)blSb)atjK0HtGYWEU8FneYVUsEuoStbG4MqAwAgmXcs5RahcKLTOBUhZIL73zXR4SOHfkwOcUqTZI2X)vOyb9d6lctS4fil)eNLhYI(kIL7zzfXIL73zbqU0yFyXlqwqtdrsmubUjp8hSWg8dmLqcLgbTqtwfwGi)6k1QL6Q3nuqFrykJHAFmdL6xHBuzaKKOU6Ddf0xeMY6v5JzOu)kCJkdG2kcqOgeAPmbpFvWmuQFfUXycafTux9UjAUu4aEUo7tWRlKJwASpgeUEragGwbassSEwf1HdkYenxkCapxN9j41fYrln2hdHERlkIaB3ojrD17MO5sHd456SpbVUqoAPX(yq46f1OsaeqbGKKaeQbHwktWZxfmd5GXv44FCDocAHMgbUaGBcPzPzWelOPHijgQalwUFNf0aleqGiKGu(kWHazzl6M7XS4filGWcDplqe0yzUNybqU0yFyboSyzNkwILgcb1l8ZIf4sdYcHSOBiwuPoCiwqtdrsmubwiKfDdH5M8WFWcBWpWucji85CvnH8YtjLcG5aSaV)Gvg)ihHRxKswdoRd0uWCaeRaHpNRQjtamhGf49hSu0Qvac1GqlLHsJIpKRZWbS8kqMHs9RWawzanGcyTuwzGFwf1HdkYGVQV05944NMZBRGqV1ffrGgknk(qUodhWYRa1ojXX)46Ce0cnnQeWfakAz97AQEtFnXZWEM0RImu5QAcmjrD17MGNVkyaxJ)hSAmaHAqOLY0xt8mSNj9QiZqP(vyGbiARaHpNRQjZVpNwNXebenzl(9kAPU6DdqxboeyMsJGwOjLQptfnOUgqMvusI1bicQ86nafFoVAR49bf9M)sP8dZGh1O6Q3nbpFvWaUg)pyb8aWaOssuHySI(HA)ZdL6xHbS6Q3nbpFvWaUg)pyLKeGiOYR3uhQ9p3DkjrD17gvnecQx43SIuOU6DJQgcb1l8Bgk1Vcdy1vVBcE(QGbCn(FWcyTaUa)SkQdhuKjAUu4aEUo7tWRlKJwASpgc9wxueb2UTcRvx9Uj45RcMvKIwwhGiOYR3uhQ9p3DkjjaHAqOLYeGfciqu(3Pmo6M7XMvusIkeJv0pu7FEOu)kmGdqOgeAPmbyHaceL)DkJJU5ESzOu)kmWa0jj9d1(Nhk1VcJurQkdiaaGvx9Uj45RcgW14)bR2CtinlndMy53jwIrq1VhFyXY97S4SGMgIKyOcS87(ZYHl09S0hyklaYLg7d3Kh(dwyd(bMsizCeubx4CFOQbXr(1vsD17MGNVkygk1Vc3OYOnjrD17MGNVkyaxJ)hSaCmbGce(CUQMmbWCawG3FWkJFUjp8hSWg8dmLqsG0e(pxND9HQsP6r(1vcHpNRQjtamhGf49hSY4xrlRvx9Uj45RcgW14)bRgJjassSoarqLxVbbv)E8PDsI6Q3nJJGk4cN7dvniUzfPqD17MXrqfCHZ9HQge3muQFfgWaxGfGf46Et0qHdtzxFOQuQEZFPugHRxeWAzT6Q3nQAieuVWVzfPW631u9g87JgoGgQCvnb2MBYd)blSb)atjKCvWNY)dwi)6kHWNZv1KjaMdWc8(dwz8ZnH0SeJWNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoccKLoCybnnejXqfybdz539NLFNIZIpu9SyXXpbYcsjl8ZIk1HdXYVtPCtE4pyHn4hykHee(CUQMqE5PKsyhbL7Wjh88vbKJW1lsjRdqOgeAPmbpFvWmKdgpjXAe(CUQMmbyHaceLbjC8kOiarqLxVPou7FU7usc4SoqtbZbqm3esZsZGjmlnpi6ZY1z5kw8If0pOVimXIxGS8ZrywEil6RiwUNLvelwUFNfa5sJ9b5SGMgIKyOcS4filne0J(dbXYMfFs5M8WFWcBWpWucj91epd7zsVkc5xxjkOVimzUk7vCfEuoStbGuOU6Dt0CPWb8CD2NGxxihT0yFmiC9IamaTcaOOfi8noOh9hckJT4tAg0tDuK5VaqxHkjX6aebvE9MIcdudhW2kq4Z5QAYGDeuUdNCWZxfu0sD17MXrqfCHZ9HQge3muQFfgWa3MRfAb(zvuhoOid(Q(sN3JJFAoVTc1vVBghbvWfo3hQAqCZkkjXA1vVBghbvWfo3hQAqCZkQn3esZsZGjwA(l63zz79P7AnlrdmGz56SS9(0DTMLdxO7zzfXn5H)Gf2GFGPesWVpDxRr(1vsD17gyr)oohrtGI(dwMvKc1vVBWVpDxRnd1hcV7QAIBYd)blSb)atjKe8kq6S6Q3rE5PKs43hnCar(1vsD17g87JgoGMHs9RWagTkAPU6Ddf0xeMYyO2hZqP(v4grBsI6Q3nuqFrykRxLpMHs9RWnI22kC8pUohbTqtJaxaWnH0SeJxPrywAigqYIk1HdXcAGfciqell8vOy53jwqdSqabIyjalW7pyXYdzjStbGy56SGgyHaceXYHzXd)Y164S4QW1ZYdzrLyj44NBYd)blSb)atjKGFFWRbfH8RRuaIGkVEtDO2)C3jfi85CvnzcWcbeikds44vqrac1GqlLjaleqGO8VtzC0n3JndL6xHbmAvyn4SoqtbZbqSckOVimzUk7vCfo(hxNJGwOPrRaaCtinlndMyz79P7AnlwUFNLTN0AFyjgpx)zXlqwkilBVpA4aICwSStflfKLT3NUR1SCywwriNL4Wfl(qSCflw5Q8Hf0pOVimXshoSaiagMcywGdlpKLObgybqU0yFyXYovS4QqeelaxaWsdXaswGdloyK)hcIfSfFszz3XSaiagMcywgk1V6kuSahwomlxXsxFO2FdlXg(el)U)SSkqAy53jwWEkXsawG3FWcZY9OdZcyeMLIw)4AwEilBVpDxRzbCnxHILyuhbvWfMLM3qvdIJCwSStflXHl0bYc(pTMfQazzfXIL73zb4caG54iw6WHLFNyr74NfuAOQRXgUjp8hSWg8dmLqc(9P7AnYVUsVRP6n4N0AFYGZ1FdvUQMavy97AQEd(9rdhqdvUQMavOU6Dd(9P7ATzO(q4DxvtkAPU6Ddf0xeMY6v5JzOu)kCJacfuqFryYCvwVkFuOU6Dt0CPWb8CD2NGxxihT0yFmiC9Iamarlassux9UjAUu4aEUo7tWRlKJwASpgeUErnQearlau44FCDocAHMgbUaijbe(gh0J(dbLXw8jnd6PokYmuQFfUrarsIh(dwgh0J(dbLXw8jnd6PokYCvURpu7FBfbiudcTuMGNVkygk1Vc3OYaGBcPzPzWelBVp41GIyP5VOFNLObgWS4filGR0iwAigqYILDQybnnejXqfyboS87elXiO63JpSOU6DwomlUkC9S8qw6UwZcS3zboSehUqhilbpILgIbKCtE4pyHn4hykHe87dEnOiKFDLux9Ubw0VJZbn5tgXHpyzwrjjQRE3a0vGdbMP0iOfAsP6ZurdQRbKzfLKOU6DtWZxfmRifTux9UzCeubx4CFOQbXndL6xHbmQaOj1rgWhOt3YX)46Ce0cni1ycG2alMa)7AQEtrwYPqyzOYv1eOcRNvrD4GIm4R6lDEpo(P5CfQRE3mocQGlCUpu1G4MvusI6Q3nbpFvWmuQFfgWOcGMuhzaFGoDlh)JRZrql0GuJjaANKOU6DZ4iOcUW5(qvdINXx1x68EC8tZ5Mvussl1vVBghbvWfo3hQAqCZqP(vya7H)GLb)(0VHmeYOW6P8FPKcCeP15Dh)eGbGXkssux9UzCeubx4CFOQbXndL6xHbSh(dwglJ)7gczuy9u(VukjbHpNRQjZHEG5aSaV)GLIaeQbHwkZv4WSExvtz0B51VsZGeIlqMHCW4ki0BDrreO5kCywVRQPm6T86xPzqcXfO2kux9UzCeubx4CFOQbXnROKeRvx9UzCeubx4CFOQbXnRifwhGqni0szghbvWfo3hQAqCZqoy8KeRdqeu51Bqq1VhFANK44FCDocAHMgbUaqbf0xeMmxL9ko3esZIvN4S8qwsDGiw(DIfvc)Sa7SS9(OHdilQXzb)EaORqXY9SSIyb9wxaiDCwUIfVIZc6h0xeMyrD9SaixASpSC46zXvHRNLhYIkXs0adbcKBYd)blSb)atjKGFFWRbfH8RR07AQEd(9rdhqdvUQMavy9SkQdhuK5VuYcCQm4qEQ6vG0OOL6Q3n43hnCanROKeh)JRZrql00iWfaTvOU6Dd(9rdhqd(9aqaoMkAPU6Ddf0xeMYyO2hZkkjrD17gkOVimL1RYhZkQTc1vVBIMlfoGNRZ(e86c5OLg7JbHRxeGbiGcakAfGqni0szcE(QGzOu)kCJkdGKeRr4Z5QAYeGfciqugKWXRGIaebvE9M6qT)5UtT5MqAwqF8FP(tyw2HwyjDf2zPHyajl(qSGYVIazjIgwWuawGCtE4pyHn4hykHee(CUQMqE5PKsoocqsZgfqocxViLOG(IWK5QSEv(a8acKQh(dwg87t)gYqiJcRNY)LsaZAkOVimzUkRxLpaFlanWExt1BWWLod75FNYD4q43qLRQjqGpMTrQE4pyzSm(VBiKrH1t5)sjGbaJvGwKkoI068UJFcyaWGwG)DnvVP8FneoR6AVcKHkxvtGCtinlX4vAelBVp41GIy5kwCwauadtbw2GAFyb9d6lctiNfqyHUNfn9SCplrdmWcGCPX(WsRF3Fwoml7EbQjqwuJZcD)onS87elBVpDxRzrFfXcCy53jwAigq2iWfaSOVIyPdhw2EFWRbf1g5Sacl09SarqJL5EIfVyP5VOFNLObgyXlqw00ZYVtS4Qqeel6Riw29cutSS9(OHdi3Kh(dwyd(bMsib)(Gxdkc5xxjRNvrD4GIm)LswGtLbhYtvVcKgfTux9UjAUu4aEUo7tWRlKJwASpgeUEragGakaKKOU6Dt0CPWb8CD2NGxxihT0yFmiC9Iamarlau8UMQ3GFsR9jdox)nu5QAcSTIwuqFryYCvgd1(OWX)46Ce0cnadHpNRQjJJJaK0SrbGxD17gkOVimLXqTpMHs9RWade(M(AINH9mPxfz(laeopuQFfWdqdABeqaGKekOVimzUkRxLpkC8pUohbTqdWq4Z5QAY44iajnBua4vx9UHc6lctz9Q8XmuQFfgyGW30xt8mSNj9QiZFbGW5Hs9RaEaAqBJaxa0wH1QRE3al63X5iAcu0FWYSIuy97AQEd(9rdhqdvUQMav0kaHAqOLYe88vbZqP(v4gbujjy4sREfO53NtRZyIaIgdvUQMavOU6DZVpNwNXebeng87bGaCmJzZ1Awf1HdkYGVQV05944NMZbE02wr)qT)5Hs9RWnQmaaGI(HA)ZdL6xHbmabaaAROvac1GqlLbORahcmJJU5ESzOu)kCJaQKeRdqeu51Bak(CE1MBcPzPzWelnFqyHz5kwSYv5dlOFqFryIfVazb7iiwIrIR7aR5T0AwA(GWILoCybnnejXqfyXlqwqkFf4qGSG(Prql0Ks1Zn5H)Gf2GFGPeskYsofclKFDLAPU6Ddf0xeMY6v5JzOu)kCJeYOW6P8FPussRWUpOiSsauXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbGuGWNZv1Kb7iOCho5GNVkWn5H)Gf2GFGPes2DDpNcHfYVUsTux9UHc6lctz9Q8XmuQFfUrczuy9u(VusH1bicQ86nafFoVssAPU6DdqxboeyMsJGwOjLQptfnOUgqMvKIaebvE9gGIpNxTtsAf29bfHvcGkgkS7dkk)xkby02ojjS7dkcRumtsux9Uj45RcMvuBfEuoStbGuGWNZv1Kb7iOCho5GNVkOOL6Q3nJJGk4cN7dvniUzOu)kmGBH2MdGa)SkQdhuKbFvFPZ7XXpnN3wH6Q3nJJGk4cN7dvniUzfLKyT6Q3nJJGk4cN7dvniUzf1MBYd)blSb)atjK0xADofclKFDLAPU6Ddf0xeMY6v5JzOu)kCJeYOW6P8FPKcRdqeu51Bak(CELK0sD17gGUcCiWmLgbTqtkvFMkAqDnGmRifbicQ86nafFoVANK0kS7dkcReavmuy3huu(VucWOTDssy3huewPyMKOU6DtWZxfmRO2k8OCyNcaPaHpNRQjd2rq5oCYbpFvqrl1vVBghbvWfo3hQAqCZqP(vyaJwfQRE3mocQGlCUpu1G4MvKcRNvrD4GIm4R6lDEpo(P58KeRvx9UzCeubx4CFOQbXnRO2CtinlndMybPaI(SalwcGCtE4pyHn4hykHel(mhCYWEM0RI4MqAwAgmXY27t)gILhYs0adSSb1(Wc6h0xeMqolOPHijgQal7oMfnHXS8xkXYV7flolifJ)7SqiJcRNyrt9Nf4WcS0XzXkxLpSG(b9fHjwomlRiUjp8hSWg8dmLqc(9PFdH8RRef0xeMmxL1RYNKekOVimzWqTp5Iq2NKqb9fHjJxXZfHSpjPL6Q3nw8zo4KH9mPxfzwrjj4isRZ7o(jadaJvGwfwhGiOYR3GGQFp(KKGJiToV74NamamwHIaebvE9geu97XN2kux9UHc6lctz9Q8XSIssAPU6DtWZxfmdL6xHbSh(dwglJ)7gczuy9u(VusH6Q3nbpFvWSIAZnH0S0myIfKIX)DwG)onwomXIL9lSZYHz5kw2GAFyb9d6lctiNf00qKedvGf4WYdzjAGbwSYv5dlOFqFryIBYd)blSb)atjKyz8FNBcPzP55A9VplUjp8hSWg8dmLqYSQSh(dwz9HFKxEkPu316FFw2V9BBd]] )

end