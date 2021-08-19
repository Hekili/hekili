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


    spec:RegisterPack( "Balance", 20210818, [[difN6fqikPEeePUeejTji1NiHmkPkNsQQvbOQxbOmlsGBjvsTlk(feXWukCmsultPONjuQPrjrxJe02auPVPusghLK6CkLuRdqfZtPu3JezFcv9pisK6GsLyHcL8qiQMOqf6IusyJkLGpkubYifQa1jPKKvkvQxcrIAMKq1nvkHStHk9tLsOgQsj6OqKizPcvqpfGPku4Qcv0wfQa(kejmwPsYEfYFf1GjomvlMKESGjd0Lr2Su(mKmALQtRYQHir8Aaz2K62I0UL8BqdNsDCsOSCfphQPRQRRKTdHVtjgpeLZlvSEHIMVi2pQJuokgraa9NII7MBSPYBy1kB1Mn3WkbUkCRIa8DSPia2EaihffbO8ukcqSCTxbkcGT3rdDWOyebadxtGIaS)Vng4GeKO6AVcuxJV0Gb197lvZbrsSCTxbQRbCPihjPGM9pvJu62PjLuDTxbY8i7JaOUo9BvvKAeaq)PO4U5gBQ8gwTYwTzZnSsGRcvyeaF97WjcaGlf5ra2pqqQIuJaas4qeGy5AVcelXXzDGC3DzHAHFwu2QvalBUXMkZDZDJ8DVqryGd3DxZsxabjqwaa1(WsSip1WD31SG8DVqrGS8(GI(81yj4ycZYdzj0jOP87dk6XgU7UML4qkfIGazzvffim2NoSGWNZv1eMLENHmkGf7HqKXVp41GIyPRJNf7HqyWVp41GI6B4U7Aw6cc4bYI9qbh)xHIfKIX)DwUgl3Riml)oXILbwOyXkc6ZgtgU7UMLTihiIfKdleqGiw(DIfa23CpMfNf99VMyjfoelnnHStvtS07AS0bUyz3blf9SSFpl3Zc(sx63lcUW6oSy5(DwI1wCxIblaJfKtAc)NRzPl6dvLs1RawUxrGSGb6S7B4U7Aw2ICGiwsH4Nff1ou7FEOu)kSIybhOYNdIzXTT1Dy5HSOcXywAhQ9hZcS0DmC3DnlXyi)zjgWuIfyJLyP9DwIL23zjwAFNfhZIZc2McNRz5NRaIEd3DxZYwSnv0WsVZqgfWcsX4)UcybPy8FxbSa49PDd1NLuhKyjfoeldHp9r1ZYdzH8rF0WsaMQ6FxJFFEd3n3DxQc((tGSelx7vGyPlBPIZsWlwujwAWvbYI)SS)Vng4GeKO6AVcuxJV0Gb197lvZbrsSCTxbQRbCPihjPGM9pvJu62PjLuDTxbY8i7JaOp8JJIreaOnv0efJO4QCumIaqLRQjWOyfbWd)bRiawg)3Jaas4WC2)bRiaB5qbh)SSjlifJ)7S4filolaEFWRbfXcSybqmyXY97Se3d1(ZYwWjw8cKLyb7smyboSa49PDdXc83PXYHPiaH5EAopcqpwOG(SXKrVkFYfHSNLKewOG(SXK5QmgQ9HLKewOG(SXK5QSk83zjjHfkOpBmz8QtUiK9S0Nf0SypecJYglJ)7SGMfRzXEieMnnwg)3J(O4UzumIaqLRQjWOyfbWd)bRia43N2nueGWCpnNhbWAwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHfRzjarqLxVPou7FU5eljjSynlyBsRZVpOOhBWVpnxRzrjwuMLKewSML31u9MY)1q4SQR9kqgQCvnbYsscl9yHc6Zgtgmu7tUiK9SKKWcf0NnMmxL1RYhwssyHc6ZgtMRYQWFNLKewOG(SXKXRo5Iq2Zs)ia6ROCamcGcJ(O4g7OyebGkxvtGrXkcGh(dwraWVp41GIIaeM7P58iaZQOgCqrgvx7vGYWw2168VFfkSHkxvtGSGMLaebvE9M6qT)5MtSGMfSnP153hu0Jn43NMR1SOelkhbqFfLdGrauy0h9raaPMV0FumIIRYrXicGh(dwraWqTpzvYtJaqLRQjWOyf9rXDZOyebGkxvtGrXkcqyUNMZJa8xkXY2S0JLnzb4zXd)blJLX)DtWXF(VuIfGXIh(dwg87t7gYeC8N)lLyPFeap8hSIaeCTo7H)GvwF4pcG(WFU8ukca0MkAI(O4g7OyebGkxvtGrXkca0ocaM(iaE4pyfbaHpNRQPiaiC9IIaGTjTo)(GIESb)(0CTML4zrzwqZspwSML31u9g87JgoGgQCvnbYssclVRP6n4N0AFYGZ1EdvUQMazPpljjSGTjTo)(GIESb)(0CTML4zzZiaGeomN9FWkcaa6XS0fOvWcSyj2aJfl3VdxplGZ1Ew8cKfl3VZcG3hnCazXlqw2eySa)DASCykcacFYLNsraoC2Hu0hfxRmkgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiayBsRZVpOOhBWVpTBiwINfLJaas4WC2)bRiaaOhZsqtocIfl7uXcG3N2nelbVyz)Ew2eyS8(GIEmlw2VWolhMLH0ecVEwAWHLFNyXkc6ZgtS8qwujwShQrZqGS4filw2VWolTtRPHLhYsWXFeae(KlpLIaC4Cqtock6JIRcJIreaQCvnbgfRiaq7iay6Ja4H)Gveae(CUQMIaGW1lkcG9qimPqy1UHyjjHf7HqyWRQDdXsscl2dHWGFFWRbfXsscl2dHWGFFAUwZsscl2dHW0wtNmSLj9QiwssyrD1AMGNVkygk1VcZIsSOUAntWZxfmGRX)dwSKKWI9qimJJGk4cNBdvXSdljjSGWNZv1K5WzhsraajCyo7)GveG4a(CUQMy539NLWofacZY1yPdCXIpelxXIZcQailpKfhb8az53jwW3V8)Gflw2PHyXz5NRaIEwOpWYHzzHjqwUIfv6TquXsWXpocacFYLNsraUkJkag9rXf4gfJiau5QAcmkwra8WFWkcGknyAa6kuraajCyo7)GveG4etSelAW0a0vOyXY97SG8UGeRQcSahw82tdlihwiGarSCfliVliXQQqeGWCpnNhbOhl9yXAwcqeu51BQd1(NBoXssclwZsac1GqlLjaleqGO8VtzS9n3JnlBw6ZcAwuxTMj45RcMHs9RWSeplkRqwqZI6Q1mJJGk4cNBdvXSJzOu)kmlBZIvYcAwSMLaebvE9geu97DgwssyjarqLxVbbv)ENHf0SOUAntWZxfmlBwqZI6Q1mJJGk4cNBdvXSJzzZcAw6XI6Q1mJJGk4cNBdvXSJzOu)kmlBZIYkZsxZIczb4zzwf1GdkYGVQT059o4NMZnu5QAcKLKewuxTMj45RcMHs9RWSSnlkRmljjSOmliHfSnP15Dh)elBZIYgfQqw6ZsFwqZccFoxvtMRYOcGrFuC3QOyebGkxvtGrXkcqyUNMZJaOUAntWZxfmdL6xHzjEwuwHSGMLESynlZQOgCqrg8vTLoV3b)0CUHkxvtGSKKWI6Q1mJJGk4cNBdvXSJzOu)kmlBZIYBflDnlBYcWZI6Q1mQAieuVWVzzZcAwuxTMzCeubx4CBOkMDmlBw6ZssclQqmMf0S0ou7FEOu)kmlBZYMkmcaiHdZz)hSIaSLWNfl3VZIZcY7csSQkWYV7plhUu0ZIZYwU0yFyXEGbwGdlw2PILFNyPDO2FwomlUkC9S8qwOcmcGh(dwraSH)bROpkUwDumIaqLRQjWOyfbaAhbatFeap8hSIaGWNZv1ueaeUErrac0PzPhl9yPDO2)8qP(vyw6AwuwHS01SeGqni0szcE(QGzOu)kml9zbjSOSvVbl9zrjwc0PzPhl9yPDO2)8qP(vyw6AwuwHS01SeGqni0szcWcbeik)7ugBFZ9yd4A8)GflDnlbiudcTuMaSqabIY)oLX23Cp2muQFfML(SGewu2Q3GL(SGMfRzz8dmtiO6noii2qi7WpMLKewcqOgeAPmbpFvWmuQFfML4z5QNgBO2Fcm3ou7FEOu)kmljjSmRIAWbfzcKMW)56m2(M7XgQCvnbYcAwcqOgeAPmbpFvWmuQFfML4zj2BWssclbiudcTuMaSqabIY)oLX23Cp2muQFfML4z5QNgBO2Fcm3ou7FEOu)kmlDnlkVbljjSynlbicQ86n1HA)ZnNIaas4WC2)bRiai31HL2FcZILD63PHLf(kuSGCyHaceXsbTWILtRzX1AOfw6axS8qwW)P1SeC8ZYVtSG9uIfpfUQNfyJfKdleqGiGH8UGeRQcSeC8JJaGWNC5PueGaSqabIYGeUtfI(O4U1rXicavUQMaJIveaODeam9ra8WFWkcacFoxvtraq46ffbOhlTd1(Nhk1VcZs8SOSczjjHLXpWmHGQ34GGyZvSeplkCdw6ZcAw6Xspw6XcPyRZ2ManuQDNHCDgoGLxbIf0S0JLaeQbHwkdLA3zixNHdy5vGmdL6xHzzBwug4UbljjSeGiOYR3GGQFVZWcAwcqOgeAPmuQDNHCDgoGLxbYmuQFfMLTzrzG7wXcWyPhlkRmlaplZQOgCqrg8vTLoV3b)0CUHkxvtGS0NL(SGMfRzjaHAqOLYqP2DgY1z4awEfiZqoyhw6ZssclKIToBBc0GHlTM()ku5zP2Hf0S0JfRzjarqLxVPou7FU5eljjSeGqni0szWWLwt)FfQ8Su7KJTvQqREdLndL6xHzzBwuwzRKL(SKKWspwcqOgeAPmQ0GPbORqzgYb7WssclwZY4bY8duRzPplOzPhl9yHuS1zBtGMRWHz9UQMYk2YRFLMbjexGybnl9yjaHAqOLYCfomR3v1uwXwE9R0miH4cKzihSdljjS4H)GL5kCywVRQPSIT86xPzqcXfid4HDvnbYsFw6Zsscl9yHuS1zBtGg8UdcTqGz4OMHT8dNuQEwqZsac1GqlL5HtkvpbMVcFO2)CSvOcJ9MkBgk1VcZsFwssyPhl9ybHpNRQjdSYlmL)5kGONfLyrzwssybHpNRQjdSYlmL)5kGONfLyj2S0Nf0S0JLFUci6nVYMHCWo5aeQbHwkwssy5NRaIEZRSjaHAqOLYmuQFfML4z5QNgBO2Fcm3ou7FEOu)kmlDnlkVbl9zjjHfe(CUQMmWkVWu(NRaIEwuILnzbnl9y5NRaIEZVPzihStoaHAqOLILKew(5kGO38BAcqOgeAPmdL6xHzjEwU6PXgQ9NaZTd1(Nhk1VcZsxZIYBWsFwssybHpNRQjdSYlmL)5kGONfLyzdw6ZsFw6ZssclbicQ86na1zoVyPpljjSOcXywqZs7qT)5Hs9RWSSnlQRwZe88vbd4A8)GveaqchMZ(pyfbioXeilpKfqs7Dy53jwwyhfXcSXcY7csSQkWILDQyzHVcflGWLQMybwSSWelEbYI9qiO6zzHDuelw2PIfVyXbbzHqq1ZYHzXvHRNLhYc4rraq4tU8ukcqamhGf49hSI(O4Q8grXicavUQMaJIveaODeam9ra8WFWkcacFoxvtraq46ffbWAwWWLw9kqZVpNwNXebengQCvnbYssclTd1(Nhk1VcZs8SS5gBWssclQqmMf0S0ou7FEOu)kmlBZYMkKfGXspwSYnyPRzrD1AMFFoToJjciAm43daXcWZYMS0NLKewuxTM53NtRZyIaIgd(9aqSeplX2QzPRzPhlZQOgCqrg8vTLoV3b)0CUHkxvtGSa8SOqw6hbaKWH5S)dwraId4Z5QAILfMaz5HSasAVdlE1HLFUci6XS4filbqmlw2PIfl(9xHILgCyXlwSIL9oCoNf7bgIaGWNC5PueGFFoToJjciAYw87J(O4QSYrXicavUQMaJIveaqchMZ(pyfbioXelwrQDNHCnlBXdy5vGyzZnWuaZIk1GdXIZcY7csSQkWYctMiaLNsraOu7od56mCalVcueGWCpnNhbiaHAqOLYe88vbZqP(vyw2MLn3Gf0SeGqni0szcWcbeik)7ugBFZ9yZqP(vyw2MLn3Gf0S0Jfe(CUQMm)(CADgteq0KT43ZssclQRwZ87ZP1zmrarJb)EaiwINLyVblaJLESmRIAWbfzWx1w68Eh8tZ5gQCvnbYcWZcWLL(S0Nf0SGWNZv1K5QmQailjjSOcXywqZs7qT)5Hs9RWSSnlXERIa4H)Gveak1UZqUodhWYRaf9rXv5nJIreaQCvnbgfRiaGeomN9FWkcqCIjwaaxAn9xHIL4WLAhwaUykGzrLAWHyXzb5DbjwvfyzHjteGYtPiay4sRP)VcvEwQDIaeM7P58ia9yjaHAqOLYe88vbZqP(vyw2MfGllOzXAwcqeu51Bqq1V3zybnlwZsaIGkVEtDO2)CZjwssyjarqLxVPou7FU5elOzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSSnlaxwqZspwq4Z5QAYeGfciqugKWDQaljjSeGqni0szcE(QGzOu)kmlBZcWLL(SKKWsaIGkVEdcQ(9odlOzPhlwZYSkQbhuKbFvBPZ7DWpnNBOYv1eilOzjaHAqOLYe88vbZqP(vyw2MfGlljjSOUAnZ4iOcUW52qvm7ygk1VcZY2SOSvYcWyPhlkKfGNfsXwNTnbAUc)Zk8WbNbpexrzvsRzPplOzrD1AMXrqfCHZTHQy2XSSzPpljjS0ou7FEOu)kmlBZYMkKLKewifBD22eOHsT7mKRZWbS8kqSGMLaeQbHwkdLA3zixNHdy5vGmdL6xHzjEw2Cdw6ZcAwq4Z5QAYCvgvaKf0SynlKIToBBc0CfomR3v1uwXwE9R0miH4celjjSeGqni0szUchM17QAkRylV(vAgKqCbYmuQFfML4zzZnyjjHfvigZcAwAhQ9ppuQFfMLTzzZnIa4H)GveamCP10)xHkpl1orFuCvo2rXicavUQMaJIveaODeam9ra8WFWkcacFoxvtraq46ffbqD1AMGNVkygk1VcZs8SOSczbnl9yXAwMvrn4GIm4RAlDEVd(P5CdvUQMazjjHf1vRzghbvWfo3gQIzhZqP(vyw2wjwuEtZMSamw6XsSzb4zrD1AgvnecQx43SSzPplaJLESy1S01SOqwaEwuxTMrvdHG6f(nlBw6ZcWZcPyRZ2ManxH)zfE4GZGhIROSkP1SGMf1vRzghbvWfo3gQIzhZYML(SKKWIkeJzbnlTd1(Nhk1VcZY2SSPczjjHfsXwNTnbAOu7od56mCalVcelOzjaHAqOLYqP2DgY1z4awEfiZqP(v4iaGeomN9FWkcqx0w8oywwyIfRcPuXrwSC)oliVliXQQqeae(KlpLIaCkgyoalW7pyf9rXvzRmkgraOYv1eyuSIa4H)GveGRWHz9UQMYk2YRFLMbjexGIaeM7P58iai85CvnzofdmhGf49hSybnli85CvnzUkJkagbO8ukcWv4WSExvtzfB51VsZGeIlqrFuCvwHrXicavUQMaJIveaqchMZ(pyfbioXelZHA)zrLAWHyjaIJauEkfbaV7GqleygoQzyl)WjLQpcqyUNMZJa0JLaeQbHwktWZxfmd5GDybnlwZsaIGkVEtDO2)CZjwqZccFoxvtMFFoToJjciAYw87zjjHLaebvE9M6qT)5MtSGMLaeQbHwktawiGar5FNYy7BUhBgYb7WcAw6XccFoxvtMaSqabIYGeUtfyjjHLaeQbHwktWZxfmd5GDyPpl9zbnlGW3Gxv7gY8xaORqXcAw6Xci8n4N0AFYnTpK5VaqxHILKewSML31u9g8tATp5M2hYqLRQjqwssybBtAD(9bf9yd(9PDdXs8SeBw6ZcAw6Xci8nPqy1UHm)fa6kuS0Nf0S0Jfe(CUQMmho7qILKewMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHfh)JRZ2ql0Ws8kXYwVbljjSOUAnJQgcb1l8Bw2S0Nf0S0JLaeQbHwkJknyAa6kuMHCWoSKKWI1SmEGm)a1Aw6ZcAwSMfsXwNTnbAUchM17QAkRylV(vAgKqCbILKewifBD22eO5kCywVRQPSIT86xPzqcXfiwqZspwcqOgeAPmxHdZ6DvnLvSLx)kndsiUazgk1VcZs8Se7nyjjHLaeQbHwkJknyAa6kuMHs9RWSeplXEdw6ZcAwSMf1vRzcE(QGzzZssclQqmMf0S0ou7FEOu)kmlBZIvUreap8hSIaG3DqOfcmdh1mSLF4Ks1h9rXvzGBumIaqLRQjWOyfbaKWH5S)dwraIX(Hz5WS4Sm(VtdlK2vHJ)elw8oS8qwsDGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veillBwSC)oliVliXQQalEbYcYHfciqelEbYYctS87elBwGSG1WNfyXsaKLRXIk83z5NRaIEml(qSalwwyIf87pl)Cfq0JJaeM7P58ia9ybHpNRQjdSYlmL)5kGONfRvIfLzbnlwZYpxbe9MFtZqoyNCac1GqlfljjS0Jfe(CUQMmWkVWu(NRaIEwuIfLzjjHfe(CUQMmWkVWu(NRaIEwuILyZsFwqZspwuxTMj45RcMLnlOzPhlwZsaIGkVEdcQ(9odljjSOUAnZ4iOcUW52qvm7ygk1VcZcWyPhlkKfGNLzvudoOid(Q2sN37GFAo3qLRQjqw6ZY2kXYpxbe9MxzJ6Q1YGRX)dwSGMf1vRzghbvWfo3gQIzhZYMLKewuxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYML(SKKWsac1GqlLj45RcMHs9RWSamw2KL4z5NRaIEZRSjaHAqOLYaUg)pyXcAwSMf1vRzcE(QGzzZcAw6XI1SeGiOYR3uhQ9p3CILKewSMfe(CUQMmbyHaceLbjCNkWsFwqZI1SeGiOYR3auN58ILKewcqeu51BQd1(NBoXcAwq4Z5QAYeGfciqugKWDQalOzjaHAqOLYeGfciqu(3Pm2(M7XMLnlOzXAwcqOgeAPmbpFvWSSzbnl9yPhlQRwZqb9zJPSEv(ygk1VcZs8SO8gSKKWI6Q1muqF2ykJHAFmdL6xHzjEwuEdw6ZcAwSMLzvudoOiJQR9kqzyl7AD(3Vcf2qLRQjqwssyPhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXIsSOqwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwuIfRML(S0NLKewuxTMbORahcmtP2ql0Ks1NPIguxmjZYML(SKKWs7qT)5Hs9RWSSnlBUbljjSGWNZv1Kbw5fMY)Cfq0ZIsSSbl9zbnli85CvnzUkJkagbaRHpocWpxbe9khbWd)bRia)Cfq0RC0hfxL3QOyebGkxvtGrXkcGh(dwra(5kGOFZiaH5EAopcqpwq4Z5QAYaR8ct5FUci6zXALyztwqZI1S8ZvarV5v2mKd2jhGqni0sXsscli85CvnzGvEHP8pxbe9SOelBYcAw6XI6Q1mbpFvWSSzbnl9yXAwcqeu51Bqq1V3zyjjHf1vRzghbvWfo3gQIzhZqP(vywagl9yrHSa8SmRIAWbfzWx1w68Eh8tZ5gQCvnbYsFw2wjw(5kGO38BAuxTwgCn(FWIf0SOUAnZ4iOcUW52qvm7yw2SKKWI6Q1mJJGk4cNBdvXStgFvBPZ7DWpnNBw2S0NLKewcqOgeAPmbpFvWmuQFfMfGXYMSepl)Cfq0B(nnbiudcTugW14)blwqZI1SOUAntWZxfmlBwqZspwSMLaebvE9M6qT)5MtSKKWI1SGWNZv1KjaleqGOmiH7ubw6ZcAwSMLaebvE9gG6mNxSGMLESynlQRwZe88vbZYMLKewSMLaebvE9geu97Dgw6ZssclbicQ86n1HA)ZnNybnli85CvnzcWcbeikds4ovGf0SeGqni0szcWcbeik)7ugBFZ9yZYMf0SynlbiudcTuMGNVkyw2SGMLES0Jf1vRzOG(SXuwVkFmdL6xHzjEwuEdwssyrD1AgkOpBmLXqTpMHs9RWSeplkVbl9zbnlwZYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjS0Jf1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyrjwuiljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelkXIvZsFw6ZsFwssyrD1AgGUcCiWmLAdTqtkvFMkAqDXKmlBwssyrfIXSGML2HA)ZdL6xHzzBw2CdwssybHpNRQjdSYlmL)5kGONfLyzdw6ZcAwq4Z5QAYCvgvamcawdFCeGFUci63m6JIRYwDumIaqLRQjWOyfbaKWH5S)dwraItmHzX1AwG)onSalwwyIL7PumlWILayeap8hSIaSWu(Ekfh9rXv5TokgraOYv1eyuSIaas4WC2)bRiaXrkCGelE4pyXI(WplQoMazbwSGVF5)blKOjuhocGh(dwraMvL9WFWkRp8hba)Zf(O4QCeGWCpnNhbaHpNRQjZHZoKIaOp8NlpLIa4qk6JI7MBefJiau5QAcmkwracZ90CEeGzvudoOiJQR9kqzyl7AD(3Vcf2qk26STjWia4FUWhfxLJa4H)GveGzvzp8hSY6d)ra0h(ZLNsrauH(h9rXDtLJIreaQCvnbgfRiaE4pyfbywv2d)bRS(WFea9H)C5Puea8h9rFeavO)rXikUkhfJiau5QAcmkwra8WFWkcW4iOcUW52qvm7ebaKWH5S)dwra2cdvXSdlwUFNfK3fKyvvicqyUNMZJaOUAntWZxfmdL6xHzjEwuwHrFuC3mkgraOYv1eyuSIa4H)Gveah0T)dbLXw8jncqOtqt53hu0JJIRYracZ90CEea1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyzBwSAwqZI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqSSnlwnlOzPhlwZci8noOB)hckJT4tAg0tDuK5VaqxHIf0SynlE4pyzCq3(peugBXN0mON6OiZv5M(qT)SGMLESynlGW34GU9FiOm2IpP5DY1M)caDfkwssybe(gh0T)dbLXw8jnVtU2muQFfML4zj2S0NLKewaHVXbD7)qqzSfFsZGEQJIm43daXY2SeBwqZci8noOB)hckJT4tAg0tDuKzOu)kmlBZIczbnlGW34GU9FiOm2IpPzqp1rrM)caDfkw6hbaKWH5S)dwraItmXsxaD7)qqSaWIpPSyzNkw8NfnHXS87EXIvYsSGDjgSGFpaeMfVaz5HSmuBi8ololBR0MSGFpaeloMfT)eloMfBigFQAIf4WYFPel3ZcgYY9S4ZCiimliLSWplE7PHfNLydmwWVhaIfcz23q4OpkUXokgraOYv1eyuSIa4H)GveGaSqabIY)oLX23CpocaiHdZz)hSIaeNyIfKdleqGiwSC)oliVliXQQalw2PIfBigFQAIfVazb(70y5WelwUFNfNLyb7smyrD1ASyzNkwajCNkCfQiaH5EAopcG1SaoRd0uWCaeZcAw6Xspwq4Z5QAYeGfciqugKWDQalOzXAwcqOgeAPmbpFvWmKd2HLKewuxTMj45RcMLnl9zbnl9yrD1Agvx7vGYWw2168VFfkCU8FnKb)EaiwuIfRMLKewuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIfLyXQzPpljjSOcXywqZs7qT)5Hs9RWSSnlkVbl9J(O4ALrXicavUQMaJIveap8hSIa0wtNmSLj9QOiaGeomN9FWkcWwaAfS4yw(DIL2n4NfubqwUILFNyXzjwWUedwSCfi0clWHfl3VZYVtSGuUZCEXI6Q1yboSy5(DwCwSAGHPalDb0T)dbXcal(KYIxGSyXVNLgCyb5Dbjwvfy5ASCplwG1ZIkXYYMfhLFflQudoel)oXsaKLdZs7QdVtGracZ90CEeGES0JLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelXZcWLLKewuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIL4zb4YsFwqZspwSMLaebvE9geu97DgwssyXAwuxTMzCeubx4CBOkMDmlBw6ZsFwqZspwaN1bAkyoaIzjjHLaeQbHwktWZxfmdL6xHzjEwu4gSKKWspwcqeu51BQd1(NBoXcAwcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlXZIc3GL(S0NL(SKKWspwaHVXbD7)qqzSfFsZGEQJImdL6xHzjEwSAwqZsac1GqlLj45RcMHs9RWSeplkVblOzjarqLxVPOWa1WbKL(SKKWYvpn2qT)eyUDO2)8qP(vyw2MfRMf0SynlbiudcTuMGNVkygYb7WssclbicQ86na1zoVybnlQRwZa0vGdbMPuBOfAsP6nlBwssyjarqLxVbbv)ENHf0SOUAnZ4iOcUW52qvm7ygk1VcZY2SS1SGMf1vRzghbvWfo3gQIzhZYo6JIRcJIreaQCvnbgfRiaE4pyfbi4vG0z1vRfbim3tZ5ra6XI6Q1mQU2RaLHTSR15F)ku4C5)AiZqP(vywINLTYOqwssyrD1Agvx7vGYWw2168VFfkC2NGxKzOu)kmlXZYwzuil9zbnl9yjaHAqOLYe88vbZqP(vywINLTILKew6Xsac1GqlLHsTHwOjRclqZqP(vywINLTIf0SynlQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzZcAwcqeu51BaQZCEXsFw6ZcAwC8pUoBdTqdlXRelXEJiaQRwlxEkfba)(OHdyeaqchMZ(pyfba5EfinlaEF0WbKfl3VZIZsrwyjwWUedwuxTglEbYcY7csSQkWYHlf9S4QW1ZYdzrLyzHjWOpkUa3OyebGkxvtGrXkcGh(dwraWVp41GIIaas4WC2)bRiaXXvQnlaEFWRbfHzXY97S4SelyxIblQRwJf11ZsbFwSStfl2qO(kuS0GdliVliXQQalWHfKYxboeilaSV5ECeGWCpnNhbOhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SSjljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZYMS0Nf0S0JLaebvE9M6qT)5MtSKKWsac1GqlLj45RcMHs9RWSeplBfljjSynli85CvnzcG5aSaV)GflOzXAwcqeu51BaQZCEXsscl9yjaHAqOLYqP2ql0KvHfOzOu)kmlXZYwXcAwSMf1vRza6kWHaZuQn0cnPu9zQOb1ftYSSzbnlbicQ86na1zoVyPpl9zbnl9yXAwaHVPTMozylt6vrM)caDfkwssyXAwcqOgeAPmbpFvWmKd2HLKewSMLaeQbHwktawiGar5FNYy7BUhBgYb7Ws)OpkUBvumIaqLRQjWOyfbWd)bRia43h8AqrraajCyo7)GveG44k1MfaVp41GIWSOsn4qSGCyHacefbim3tZ5ra6Xsac1GqlLjaleqGO8VtzS9n3JndL6xHzzBwuilOzXAwaN1bAkyoaIzbnl9ybHpNRQjtawiGarzqc3PcSKKWsac1GqlLj45RcMHs9RWSSnlkKL(SGMfe(CUQMmbWCawG3FWIL(SGMfRzbe(M2A6KHTmPxfz(la0vOybnlbicQ86n1HA)ZnNybnlwZc4SoqtbZbqmlOzHc6ZgtMRYE1Hf0S44FCD2gAHgwINfRCJOpkUwDumIaqLRQjWOyfbaAhbatFeap8hSIaGWNZv1ueaeUErra6XI6Q1mJJGk4cNBdvXSJzOu)kmlXZIczjjHfRzrD1AMXrqfCHZTHQy2XSSzPplOzPhlQRwZa0vGdbMPuBOfAsP6ZurdQlMKzOu)kmlBZcQaOj1rgl9zbnl9yrD1AgkOpBmLXqTpMHs9RWSeplOcGMuhzSKKWI6Q1muqF2ykRxLpMHs9RWSeplOcGMuhzS0pcaiHdZz)hSIaehHLIEwaHplGR5kuS87elubYcSXsCOJGk4cZYwyOkMDualGR5kuSa0vGdbYcLAdTqtkvplWHLRy53jw0o(zbvaKfyJfVyXkc6Zgtraq4tU8ukcai8ZdPyRBOuQEC0hf3TokgraOYv1eyuSIa4H)Gvea8QA3qracZ90CEeGHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkdCzbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hfxL3ikgraOYv1eyuSIa4H)GveGuiSA3qracZ90CEeGHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkhBJczbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hfxLvokgraOYv1eyuSIa4H)Gvea8tATp5M2hkcqyUNMZJamuBi8URQjwqZY7dk6n)Ls5hMbpIL4zrzGllaJLHs9RWSGMf3oh2PaqSGMfe(CUQMmGWppKITUHsP6XracDcAk)(GIECuCvo6JIRYBgfJiau5QAcmkwra8WFWkcqdobkdB5Y)1qraajCyo7)GveGTamUSalwcGSy5(D46zj422xHkcqyUNMZJa425Wofak6JIRYXokgraOYv1eyuSIa4H)Gveak1gAHMSkSaJaas4WC2)bRiawrQn0cnSelybYILDQyXvHRNLhYcvpnS4SuKfwIfSlXGflxbcTWIxGSGDeeln4WcY7csSQkebim3tZ5ra6Xcf0NnMm6v5tUiK9SKKWcf0NnMmyO2NCri7zjjHfkOpBmz8QtUiK9SKKWI6Q1mQU2RaLHTSR15F)ku4C5)AiZqP(vywINLTYOqwssyrD1Agvx7vGYWw2168VFfkC2NGxKzOu)kmlXZYwzuiljjS44FCD2gAHgwINLTEdwqZsac1GqlLj45RcMHCWoSGMfRzbCwhOPG5aiML(SGMLESeGqni0szcE(QGzOu)kmlXZsS3GLKewcqOgeAPmbpFvWmKd2HL(SKKWYvpn2qT)eyUDO2)8qP(vyw2MfL3i6JIRYwzumIaqLRQjWOyfbWd)bRiaT10jdBzsVkkcaiHdZz)hSIaSfGwblZHA)zrLAWHyzHVcfliVlracZ90CEeGaeQbHwktWZxfmd5GDybnli85CvnzcG5aSaV)GflOzPhlo(hxNTHwOHL4zzR3Gf0SynlbicQ86n1HA)ZnNyjjHLaebvE9M6qT)5MtSGMfh)JRZ2ql0WY2SyLBWsFwqZI1SeGiOYR3GGQFVZWcAw6XI1SeGiOYR3uhQ9p3CILKewcqOgeAPmbyHaceL)DkJTV5ESzihSdl9zbnlwZc4SoqtbZbqC0hfxLvyumIaqLRQjWOyfbaAhbatFeap8hSIaGWNZv1ueaeUErraSMfWzDGMcMdGywqZccFoxvtMayoalW7pyXcAw6XspwC8pUoBdTqdlXZYwVblOzPhlQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzZssclwZsaIGkVEdqDMZlw6ZssclQRwZOQHqq9c)MLnlOzrD1AgvnecQx43muQFfMLTzrD1AMGNVkyaxJ)hSyPpljjSC1tJnu7pbMBhQ9ppuQFfMLTzrD1AMGNVkyaxJ)hSyjjHLaebvE9M6qT)5MtS0Nf0S0JfRzjarqLxVPou7FU5eljjS0Jfh)JRZ2ql0WY2SyLBWssclGW30wtNmSLj9QiZFbGUcfl9zbnl9ybHpNRQjtawiGarzqc3PcSKKWsac1GqlLjaleqGO8VtzS9n3Jnd5GDyPpl9Jaas4WC2)bRiaiVliXQQalw2PIf)zzR3ayS0f8wYsp4OHwOHLF3lwSYnyPl4TKfl3VZcYHfciquFwSC)oC9SOH4RqXYFPelxXsS0qiOEHFw8cKf9vellBwSC)olihwiGarSCnwUNfloMfqc3Pceyeae(KlpLIaeaZbybE)bRSk0)OpkUkdCJIreaQCvnbgfRiaH5EAopcacFoxvtMayoalW7pyLvH(hbWd)bRiabst4)CD21hQkLQp6JIRYBvumIaqLRQjWOyfbim3tZ5raq4Z5QAYeaZbybE)bRSk0)iaE4pyfb4QGpL)hSI(O4QSvhfJiau5QAcmkwraG2raW0hbWd)bRiai85CvnfbaHRxueakOpBmzUkRxLpSa8Sy1SGew8WFWYGFFA3qgczuy9u(VuIfGXI1Sqb9zJjZvz9Q8HfGNLESaCzbyS8UMQ3GHlDg2Y)oLBWHWVHkxvtGSa8SeBw6ZcsyXd)blJLX)DdHmkSEk)xkXcWyzdZMSGewW2KwN3D8traajCyo7)GveaRa)xQ)eMLDOfwsxHDw6cElzXhIfu(veil20WcMcWcmcacFYLNsraCS9wsdake9rXv5TokgraOYv1eyuSIa4H)Gvea87dEnOOiaGeomN9FWkcqCCLAZcG3h8AqrywSStfl)oXs7qT)SCywCv46z5HSqfOcyPnufZoSCywCv46z5HSqfOcyPdCXIpel(ZYwVbWyPl4TKLRyXlwSIG(SXKcyb5Dbjwvfyr74hZIxWFNgwSAGHPaMf4Wsh4IflWLgKficAcUnlPWHy539Ifor5nyPl4TKfl7uXsh4IflWLgSu0ZcG3h8AqrSuqlracZ90CEeGESC1tJnu7pbMBhQ9ppuQFfMLTzXkzjjHLESOUAnZ4iOcUW52qvm7ygk1VcZY2SGkaAsDKXcWZsGonl9yXX)46Sn0cnSGewI9gS0Nf0SOUAnZ4iOcUW52qvm7yw2S0NL(SKKWspwC8pUoBdTqdlaJfe(CUQMmo2ElPbafyb4zrD1AgkOpBmLXqTpMHs9RWSamwaHVPTMozylt6vrM)caHZdL6xXcWZYMgfYs8SOSYBWssclo(hxNTHwOHfGXccFoxvtghBVL0aGcSa8SOUAndf0NnMY6v5JzOu)kmlaJfq4BARPtg2YKEvK5Vaq48qP(vSa8SSPrHSeplkR8gS0Nf0Sqb9zJjZvzV6WcAw6XI1SOUAntWZxfmlBwssyXAwExt1BWVpA4aAOYv1eil9zbnl9yPhlwZsac1GqlLj45RcMLnljjSeGiOYR3auN58If0SynlbiudcTugk1gAHMSkSanlBw6ZssclbicQ86n1HA)ZnNyPplOzPhlwZsaIGkVEdcQ(9odljjSynlQRwZe88vbZYMLKewC8pUoBdTqdlXZYwVbl9zjjHLES8UMQ3GFF0Wb0qLRQjqwqZI6Q1mbpFvWSSzbnl9yrD1Ag87JgoGg87bGyzBwInljjS44FCD2gAHgwINLTEdw6ZsFwssyrD1AMGNVkyw2SGMfRzrD1AMXrqfCHZTHQy2XSSzbnlwZY7AQEd(9rdhqdvUQMaJ(O4U5grXicavUQMaJIveap8hSIauKLCkewraajCyo7)GveG4etSSfbHfMLRyrXxLpSyfb9zJjw8cKfSJGyjoyx3a2wyP1SSfbHfln4WcY7csSQkebim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPeljjS0JLWUpOimlkXYMSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyj2S0Nf0S425Wofak6JI7MkhfJiau5QAcmkwracZ90CEeGESOUAndf0NnMY6v5JzOu)kmlXZcHmkSEk)xkXcAw6Xsac1GqlLj45RcMHs9RWSeplkCdwssyjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSeplkCdw6Zsscl9yjS7dkcZIsSSjlOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwInl9zbnlUDoStbGIa4H)GveGDx3YPqyf9rXDZnJIreaQCvnbgfRiaH5EAopcqpwuxTMHc6Zgtz9Q8XmuQFfML4zHqgfwpL)lLybnl9yjaHAqOLYe88vbZqP(vywINffUbljjSeGqni0szcWcbeik)7ugBFZ9yZqP(vywINffUbl9zjjHLESe29bfHzrjw2Kf0Smuy3huu(VuILTzrHS0NLKewc7(GIWSOelXML(SGMf3oh2Paqra8WFWkcqBP15uiSI(O4UzSJIreaQCvnbgfRiaGeomN9FWkcasb0kybwSeaJa4H)Gveal(mhCYWwM0RII(O4UPvgfJiau5QAcmkwra8WFWkca(9PDdfbaKWH5S)dwraItmXcG3N2nelpKf7bgybau7dlwrqF2yIf4WILDQy5kwGLUdlk(Q8HfRiOpBmXIxGSSWelifqRGf7bgWSCnwUIffFv(WIve0NnMIaeM7P58iauqF2yYCvwVkFyjjHfkOpBmzWqTp5Iq2ZsscluqF2yY4vNCri7zjjHf1vRzS4ZCWjdBzsVkYSSzbnlQRwZqb9zJPSEv(yw2SKKWspwuxTMj45RcMHs9RWSSnlE4pyzSm(VBiKrH1t5)sjwqZI6Q1mbpFvWSSzPF0hf3nvyumIa4H)GvealJ)7raOYv1eyuSI(O4UjWnkgraOYv1eyuSIa4H)GveGzvzp8hSY6d)ra0h(ZLNsraAUw)7Zk6J(iaoKIIruCvokgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOia9yrD1AM)sjlWPYGd5PQxbsJzOu)kmlBZcQaOj1rglaJLnmkZssclQRwZ8xkzbovgCipv9kqAmdL6xHzzBw8WFWYGFFA3qgczuy9u(VuIfGXYggLzbnl9yHc6ZgtMRY6v5dljjSqb9zJjdgQ9jxeYEwssyHc6ZgtgV6Klczpl9zPplOzrD1AM)sjlWPYGd5PQxbsJzzZcAwMvrn4GIm)LswGtLbhYtvVcKgdvUQMaJaas4WC2)bRiai31HL2FcZILD63PHLFNyjooKNg8pStdlQRwJflNwZsZ1AwGTglwUF)kw(DILIq2ZsWXFeae(KlpLIaaoKNMTCADU5ADg2ArFuC3mkgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiawZcf0NnMmxLXqTpSGMLESGTjTo)(GIESb)(0UHyjEwuilOz5DnvVbdx6mSL)Dk3GdHFdvUQMazjjHfSnP153hu0Jn43N2nelXZYwXs)iaGeomN9FWkcaYDDyP9NWSyzN(DAybW7dEnOiwomlwGZVZsWX)vOybIGgwa8(0UHy5kwu8v5dlwrqF2ykcacFYLNsraoufCOm(9bVguu0hf3yhfJiau5QAcmkwra8WFWkcqawiGar5FNYy7BUhhbaKWH5S)dwraItmXcYHfciqelw2PIf)zrtyml)UxSOWnyPl4TKfVazrFfXYYMfl3VZcY7csSQkebim3tZ5raSMfWzDGMcMdGywqZspw6XccFoxvtMaSqabIYGeUtfybnlwZsac1GqlLj45RcMHCWoSKKWI6Q1mbpFvWSSzPplOzPhlQRwZqb9zJPSEv(ygk1VcZs8SaCzjjHf1vRzOG(SXugd1(ygk1VcZs8SaCzPplOzPhlwZYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjSOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelXZsSzjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGyjEwInl9zjjHfvigZcAwAhQ9ppuQFfMLTzr5nybnlwZsac1GqlLj45RcMHCWoS0p6JIRvgfJiau5QAcmkwra8WFWkcW4iOcUW52qvm7ebaKWH5S)dwraItmXYwyOkMDyXY97SG8UGeRQcracZ90CEea1vRzcE(QGzOu)kmlXZIYkm6JIRcJIreaQCvnbgfRiaE4pyfbaVQ2nueGqNGMYVpOOhhfxLJaeM7P58ia9yzO2q4DxvtSKKWI6Q1muqF2ykJHAFmdL6xHzzBwInlOzHc6ZgtMRYyO2hwqZYqP(vyw2MfLTswqZY7AQEdgU0zyl)7uUbhc)gQCvnbYsFwqZY7dk6n)Ls5hMbpIL4zrzRKLUMfSnP153hu0JzbySmuQFfMf0S0JfkOpBmzUk7vhwssyzOu)kmlBZcQaOj1rgl9Jaas4WC2)bRiaXjMybWQA3qSCfl2EbsPxGfyXIxD(9RqXYV7pl6dbHzrzRetbmlEbYIMWywSC)olPWHy59bf9yw8cKf)z53jwOcKfyJfNfaqTpSyfb9zJjw8NfLTswWuaZcCyrtymldL6xDfkwCmlpKLc(SS7iUcflpKLHAdH3zbCnxHIffFv(WIve0NnMI(O4cCJIreaQCvnbgfRiaE4pyfbaVQ2nueaqchMZ(pyfbioXelawv7gILhYYUJGyXzbLgQ6AwEillmXIvHuQ4yeGWCpnNhbaHpNRQjZPyG5aSaV)GflOzjaHAqOLYCfomR3v1uwXwE9R0miH4cKzihSdlOzHuS1zBtGMRWHz9UQMYk2YRFLMbjexGI(O4UvrXicavUQMaJIveGWCpnNhbWAwExt1BWpP1(KbNR9gQCvnbYcAw6XI6Q1m43NMR1MHAdH3DvnXcAw6Xc2M0687dk6Xg87tZ1Aw2MLyZssclwZYSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eil9zjjHL31u9gmCPZWw(3PCdoe(nu5QAcKf0SOUAndf0NnMYyO2hZqP(vyw2MLyZcAwOG(SXK5QmgQ9Hf0SOUAnd(9P5ATzOu)kmlBZYwXcAwW2KwNFFqrp2GFFAUwZs8kXIvYsFwqZspwSMLzvudoOiJUtWhhNBAI(RqLrPVuBmzOYv1eiljjS8xkXcsLfRuHSeplQRwZGFFAUwBgk1VcZcWyztw6ZcAwEFqrV5Vuk)Wm4rSeplkmcGh(dwraWVpnxRJ(O4A1rXicavUQMaJIveap8hSIaGFFAUwhbaKWH5S)dwraqkUFNfapP1(WsCCU2ZYctSalwcGSyzNkwgQneE3v1elQRNf8FAnlw87zPbhwu8obFCml2dmWIxGSaclf9SSWelQudoelipoInSa4pTMLfMyrLAWHyb5WcbeiIf8vbILF3FwSCAnl2dmWIxWFNgwa8(0CTocqyUNMZJa8UMQ3GFsR9jdox7nu5QAcKf0SOUAnd(9P5ATzO2q4DxvtSGMLESynlZQOgCqrgDNGpoo30e9xHkJsFP2yYqLRQjqwssy5VuIfKklwPczjEwSsw6ZcAwEFqrV5Vuk)Wm4rSeplXo6JI7whfJiau5QAcmkwra8WFWkca(9P5ADeaqchMZ(pyfbaP4(DwIJd5PQxbsdllmXcG3NMR1S8qwaIiBww2S87elQRwJf1oS4AmKLf(kuSa49P5AnlWIffYcMcWceZcCyrtymldL6xDfQiaH5EAopcWSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eilOzbBtAD(9bf9yd(9P5AnlXRelXMf0S0JfRzrD1AM)sjlWPYGd5PQxbsJzzZcAwuxTMb)(0CT2muBi8URQjwssyPhli85CvnzahYtZwoTo3CTodBnwqZspwuxTMb)(0CT2muQFfMLTzj2SKKWc2M0687dk6Xg87tZ1AwINLnzbnlVRP6n4N0AFYGZ1EdvUQMazbnlQRwZGFFAUwBgk1VcZY2SOqw6ZsFw6h9rXv5nIIreaQCvnbgfRiaq7iay6Ja4H)Gveae(CUQMIaGW1lkcGJ)X1zBOfAyjEwS6nyPRzPhlkVblaplQRwZ8xkzbovgCipv9kqAm43daXsFw6Aw6XI6Q1m43NMR1MHs9RWSa8SeBwqclyBsRZ7o(jwaEwSML31u9g8tATpzW5AVHkxvtGS0NLUMLESeGqni0szWVpnxRndL6xHzb4zj2SGewW2KwN3D8tSa8S8UMQ3GFsR9jdox7nu5QAcKL(S01S0Jfq4BARPtg2YKEvKzOu)kmlaplkKL(SGMLESOUAnd(9P5ATzzZssclbiudcTug87tZ1AZqP(vyw6hbaKWH5S)dwraqURdlT)eMfl70VtdlolaEFWRbfXYctSy50Awc(ctSa49P5AnlpKLMR1SaBnfWIxGSSWelaEFWRbfXYdzbiISzjooKNQEfinSGFpaell7iai8jxEkfba)(0CToBbwFU5ADg2ArFuCvw5OyebGkxvtGrXkcGh(dwraWVp41GIIaas4WC2)bRiaXjMybW7dEnOiwSC)olXXH8u1RaPHLhYcqezZYYMLFNyrD1ASy5(D46zrdXxHIfaVpnxRzzz)xkXIxGSSWelaEFWRbfXcSyXkbglXc2LyWc(9aqyww1FAwSswEFqrpocqyUNMZJaGWNZv1KbCipnB506CZ16mS1ybnli85CvnzWVpnxRZwG1NBUwNHTglOzXAwq4Z5QAYCOk4qz87dEnOiwssyPhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SeBwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINLyZsFwqZc2M0687dk6Xg87tZ1Aw2MfRKf0SGWNZv1Kb)(0CToBbwFU5ADg2ArFuCvEZOyebGkxvtGrXkcGh(dwraCq3(peugBXN0iaHobnLFFqrpokUkhbim3tZ5raSML)caDfkwqZI1S4H)GLXbD7)qqzSfFsZGEQJImxLB6d1(ZssclGW34GU9FiOm2IpPzqp1rrg87bGyzBwInlOzbe(gh0T)dbLXw8jnd6PokYmuQFfMLTzj2raajCyo7)GveG4etSGT4tklyil)U)S0bUybf9SK6iJLL9FPelQDyzHVcfl3ZIJzr7pXIJzXgIXNQMybwSOjmMLF3lwInl43daHzboSGuYc)SyzNkwInWyb)EaimleYSVHI(O4QCSJIreaQCvnbgfRiaE4pyfbifcR2nueGqNGMYVpOOhhfxLJaeM7P58iad1gcV7QAIf0S8(GIEZFPu(HzWJyjEw6Xspwu2kzbyS0JfSnP153hu0Jn43N2nelaplBYcWZI6Q1muqF2ykRxLpMLnl9zPplaJLHs9RWS0NfKWspwuMfGXY7AQEZB5QCkewydvUQMazPplOzPhlbiudcTuMGNVkygYb7WcAwSMfWzDGMcMdGywqZspwq4Z5QAYeGfciqugKWDQaljjSeGqni0szcWcbeik)7ugBFZ9yZqoyhwssyXAwcqeu51BQd1(NBoXsFwssybBtAD(9bf9yd(9PDdXY2S0JLESaCzPRzPhlQRwZqb9zJPSEv(yw2Sa8SSjl9zPplapl9yrzwaglVRP6nVLRYPqyHnu5QAcKL(S0Nf0SynluqF2yYGHAFYfHSNLKew6Xcf0NnMmxLXqTpSKKWspwOG(SXK5QSk83zjjHfkOpBmzUkRxLpS0Nf0SynlVRP6ny4sNHT8Vt5gCi8BOYv1eiljjSOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyjELyztfUbl9zbnl9ybBtAD(9bf9yd(9PDdXY2SO8gSa8S0JfLzbyS8UMQ38wUkNcHf2qLRQjqw6ZsFwqZIJ)X1zBOfAyjEwu4gS01SOUAnd(9P5ATzOu)kmlaplaxw6ZcAw6XI1SOUAndqxboeyMsTHwOjLQptfnOUysMLnljjSqb9zJjZvzmu7dljjSynlbicQ86na1zoVyPplOzXAwuxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYocaiHdZz)hSIaehsTHW7SSfbHv7gILRXcY7csSQkWYHzzihSJcy53PHyXhIfnHXS87EXIcz59bf9ywUIffFv(WIve0NnMyXY97Saa(BbfWIMWyw(DVyr5nyb(70y5WelxXIxDyXkc6ZgtSahww2S8qwuilVpOOhZIk1GdXIZIIVkFyXkc6ZgtgwIJWsrpld1gcVZc4AUcfliLVcCiqwSIuBOfAsP6zzvAcJz5kwaa1(WIve0NnMI(O4QSvgfJiau5QAcmkwra8WFWkcqdobkdB5Y)1qraajCyo7)GveG4etSSfGXLfyXsaKfl3Vdxplb32(kuracZ90CEea3oh2PaqrFuCvwHrXicavUQMaJIveaODeam9ra8WFWkcacFoxvtraq46ffbWAwaN1bAkyoaIzbnli85CvnzcG5aSaV)GflOzPhl9yrD1Ag87tZ1AZYMLKewExt1BWpP1(KbNR9gQCvnbYssclbicQ86n1HA)ZnNyPplOzPhlwZI6Q1myOg)xGmlBwqZI1SOUAntWZxfmlBwqZspwSML31u9M2A6KHTmPxfzOYv1eiljjSOUAntWZxfmGRX)dwSeplbiudcTuM2A6KHTmPxfzgk1VcZcWyXQzPplOzbHpNRQjZVpNwNXebenzl(9SGMLESynlbicQ86n1HA)ZnNyjjHLaeQbHwktawiGar5FNYy7BUhBw2SGMLESOUAnd(9P5ATzOu)kmlBZYMSKKWI1S8UMQ3GFsR9jdox7nu5QAcKL(S0Nf0S8(GIEZFPu(HzWJyjEwuxTMj45RcgW14)blwaEw2WSvS0NLKewuHymlOzPDO2)8qP(vyw2Mf1vRzcE(QGbCn(FWIL(raq4tU8ukcqamhGf49hSYoKI(O4QmWnkgraOYv1eyuSIa4H)GveGaPj8FUo76dvLs1hbaKWH5S)dwraItmXcY7csSQkWcSyjaYYQ0egZIxGSOVIy5Eww2Sy5(DwqoSqabIIaeM7P58iai85CvnzcG5aSaV)Gv2Hu0hfxL3QOyebGkxvtGrXkcqyUNMZJaGWNZv1KjaMdWc8(dwzhsra8WFWkcWvbFk)pyf9rXvzRokgraOYv1eyuSIa4H)Gveak1gAHMSkSaJaas4WC2)bRiaXjMyXksTHwOHLyblqwGflbqwSC)olaEFAUwZYYMfVazb7iiwAWHLTCPX(WIxGSG8UGeRQcracZ90CEeGREASHA)jWC7qT)5Hs9RWSSnlkRqwssyPhlQRwZypxkCapxN9j41fY2ln2hdcxViw2MLnv4gSKKWI6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lIL4vILnv4gS0Nf0SOUAnd(9P5ATzzZcAw6Xsac1GqlLj45RcMHs9RWSeplkCdwssybCwhOPG5aiML(rFuCvERJIreaQCvnbgfRiaE4pyfba)Kw7tUP9HIae6e0u(9bf94O4QCeGWCpnNhbyO2q4DxvtSGML)sP8dZGhXs8SOSczbnlyBsRZVpOOhBWVpTBiw2MfRKf0S425WofaIf0S0Jf1vRzcE(QGzOu)kmlXZIYBWssclwZI6Q1mbpFvWSSzPFeaqchMZ(pyfbioKAdH3zPP9HybwSSSz5HSeBwEFqrpMfl3VdxpliVliXQQalQ0vOyXvHRNLhYcHm7Biw8cKLc(SarqtWTTVcv0hf3n3ikgraOYv1eyuSIa4H)GveG2A6KHTmPxffbaKWH5S)dwraItmXYwaAfSCnwUcFGelEXIve0NnMyXlqw0xrSCpllBwSC)ololB5sJ9Hf7bgyXlqw6cOB)hcIfaw8jncqyUNMZJaqb9zJjZvzV6WcAwC7CyNcaXcAwuxTMXEUu4aEUo7tWRlKTxASpgeUErSSnlBQWnybnl9ybe(gh0T)dbLXw8jnd6PokY8xaORqXssclwZsaIGkVEtrHbQHdiljjSGTjTo)(GIEmlXZYMS0Nf0S0Jf1vRzghbvWfo3gQIzhZqP(vyw2MLTMLUMLESOqwaEwMvrn4GIm4RAlDEVd(P5CdvUQMazPplOzrD1AMXrqfCHZTHQy2XSSzjjHfRzrD1AMXrqfCHZTHQy2XSSzPplOzPhlwZsac1GqlLj45RcMLnljjSOUAnZVpNwNXebeng87bGyzBwuwHSGML2HA)ZdL6xHzzBw2CJnybnlTd1(Nhk1VcZs8SO8gBWssclwZcgU0QxbA(9506mMiGOXqLRQjqw6ZcAw6XcgU0QxbA(9506mMiGOXqLRQjqwssyjaHAqOLYe88vbZqP(vywINLyVbl9J(O4UPYrXicavUQMaJIveap8hSIaGFFAUwhbaKWH5S)dwraItmXIZcG3NMR1SSfx0VZI9adSSknHXSa49P5AnlhMfxpKd2HLLnlWHLoWfl(qS4QW1ZYdzbIGMGBZsxWBzeGWCpnNhbqD1Agyr)ooBttGS)dwMLnlOzPhlQRwZGFFAUwBgQneE3v1eljjS44FCD2gAHgwINLTEdw6h9rXDZnJIreaQCvnbgfRiaE4pyfba)(0CTocaiHdZz)hSIaehxP2S0f8wYIk1GdXcYHfciqelwUFNfaVpnxRzXlqw(DQybW7dEnOOiaH5EAopcqaIGkVEtDO2)CZjwqZI1S8UMQ3GFsR9jdox7nu5QAcKf0S0Jfe(CUQMmbyHaceLbjCNkWssclbiudcTuMGNVkyw2SKKWI6Q1mbpFvWSSzPplOzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSSnlOcGMuhzSa8SeOtZspwC8pUoBdTqdliHffUbl9zbnlQRwZGFFAUwBgk1VcZY2SyLSGMfRzbCwhOPG5aio6JI7MXokgraOYv1eyuSIaeM7P58iabicQ86n1HA)ZnNybnl9ybHpNRQjtawiGarzqc3PcSKKWsac1GqlLj45RcMLnljjSOUAntWZxfmlBw6ZcAwcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlBZcWLf0SOUAnd(9P5ATzzZcAwOG(SXK5QSxDybnlwZccFoxvtMdvbhkJFFWRbfXcAwSMfWzDGMcMdG4iaE4pyfba)(Gxdkk6JI7MwzumIaqLRQjWOyfbWd)bRia43h8AqrraajCyo7)GveG4etSa49bVguelwUFNfVyzlUOFNf7bgyboSCnw6axkcKficAcUnlDbVLSy5(Dw6axdlfHSNLGJFdlDrJHSaUsTzPl4TKf)z53jwOcKfyJLFNyjoav)ENHf1vRXY1ybW7tZ1AwSaxAWsrplnxRzb2ASahw6axS4dXcSyztwEFqrpocqyUNMZJaOUAndSOFhNdAYNmIdFWYSSzjjHLESynl43N2nKXTZHDkaelOzXAwq4Z5QAYCOk4qz87dEnOiwssyPhlQRwZe88vbZqP(vyw2MffYcAwuxTMj45RcMLnljjS0JLESOUAntWZxfmdL6xHzzBwqfanPoYyb4zjqNMLES44FCD2gAHgwqclXEdw6ZcAwuxTMj45RcMLnljjSOUAnZ4iOcUW52qvm7KXx1w68Eh8tZ5MHs9RWSSnlOcGMuhzSa8SeOtZspwC8pUoBdTqdliHLyVbl9zbnlQRwZmocQGlCUnufZoz8vTLoV3b)0CUzzZsFwqZsaIGkVEdcQ(9odl9zPplOzPhlyBsRZVpOOhBWVpnxRzzBwInljjSGWNZv1Kb)(0CToBbwFU5ADg2AS0NL(SGMfRzbHpNRQjZHQGdLXVp41GIybnl9yXAwMvrn4GIm)LswGtLbhYtvVcKgdvUQMazjjHfSnP153hu0Jn43NMR1SSnlXML(rFuC3uHrXicavUQMaJIveap8hSIauKLCkewraajCyo7)GveG4etSSfbHfMLRybau7dlwrqF2yIfVazb7iiw2clTMLTiiSyPbhwqExqIvvHiaH5EAopcqpwuxTMHc6Zgtzmu7JzOu)kmlXZcHmkSEk)xkXsscl9yjS7dkcZIsSSjlOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwInl9zbnlUDoStbGI(O4UjWnkgraOYv1eyuSIaeM7P58ia9yrD1AgkOpBmLXqTpMHs9RWSepleYOW6P8FPeljjS0JLWUpOimlkXYMSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyj2S0Nf0S425WofaIf0S0Jf1vRzghbvWfo3gQIzhZqP(vyw2MffYcAwuxTMzCeubx4CBOkMDmlBwqZI1SmRIAWbfzWx1w68Eh8tZ5gQCvnbYssclwZI6Q1mJJGk4cNBdvXSJzzZs)iaE4pyfby31TCkewrFuC3CRIIreaQCvnbgfRiaH5EAopcqpwuxTMHc6Zgtzmu7JzOu)kmlXZcHmkSEk)xkXcAw6Xsac1GqlLj45RcMHs9RWSeplkCdwssyjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSeplkCdw6Zsscl9yjS7dkcZIsSSjlOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwInl9zbnlUDoStbGybnl9yrD1AMXrqfCHZTHQy2XmuQFfMLTzrHSGMf1vRzghbvWfo3gQIzhZYMf0SynlZQOgCqrg8vTLoV3b)0CUHkxvtGSKKWI1SOUAnZ4iOcUW52qvm7yw2S0pcGh(dwraAlToNcHv0hf3nT6OyebGkxvtGrXkcaiHdZz)hSIaeNyIfKcOvWcSyb5XXiaE4pyfbWIpZbNmSLj9QOOpkUBU1rXicavUQMaJIveaODeam9ra8WFWkcacFoxvtraq46ffbaBtAD(9bf9yd(9PDdXs8SyLSamwAAiCyPhlPo(PPtgHRxelaplkVXgSGew2Cdw6ZcWyPPHWHLESOUAnd(9bVguuMsTHwOjLQpJHAFm43daXcsyXkzPFeaqchMZ(pyfba5UoS0(tywSSt)onS8qwwyIfaVpTBiwUIfaqTpSyz)c7SCyw8NffYY7dk6XatzwAWHfcbnDyzZnqQSK64NMoSahwSswa8(GxdkIfRi1gAHMuQEwWVhachbaHp5YtPia43N2nu(QmgQ9j6JIBS3ikgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiakZcsybBtADE3XpXY2SSjlDnl9yzdZMSa8S0JfSnP153hu0Jn43N2nelDnlkZsFwaEw6XIYSamwExt1BWWLodB5FNYn4q43qLRQjqwaEwu2Oqw6ZsFwaglByuwHSa8SOUAnZ4iOcUW52qvm7ygk1VchbaKWH5S)dwraqURdlT)eMfl70VtdlpKfKIX)DwaxZvOyzlmufZoraq4tU8ukcGLX)98v52qvm7e9rXn2khfJiau5QAcmkwra8WFWkcGLX)9iaGeomN9FWkcqCIjwqkg)3z5kwaa1(WIve0NnMyboSCnwkilaEFA3qSy50AwA3ZYvpKfK3fKyvvGfV6KchkcqyUNMZJa0JfkOpBmz0RYNCri7zjjHfkOpBmz8QtUiK9SGMfe(CUQMmhoh0KJGyPplOzPhlVpOO38xkLFyg8iwINfRKLKewOG(SXKrVkFYxL3KLKewAhQ9ppuQFfMLTzr5nyPpljjSOUAndf0NnMYyO2hZqP(vyw2Mfp8hSm43N2nKHqgfwpL)lLybnlQRwZqb9zJPmgQ9XSSzjjHfkOpBmzUkJHAFybnlwZccFoxvtg87t7gkFvgd1(WssclQRwZe88vbZqP(vyw2Mfp8hSm43N2nKHqgfwpL)lLybnlwZccFoxvtMdNdAYrqSGMf1vRzcE(QGzOu)kmlBZcHmkSEk)xkXcAwuxTMj45RcMLnljjSOUAnZ4iOcUW52qvm7yw2SGMfe(CUQMmwg)3ZxLBdvXSdljjSynli85CvnzoCoOjhbXcAwuxTMj45RcMHs9RWSepleYOW6P8FPu0hf3yVzumIaqLRQjWOyfbaKWH5S)dwraItmXcG3N2nelxJLRyrXxLpSyfb9zJjfWYvSaaQ9HfRiOpBmXcSyXkbglVpOOhZcCy5HSypWalaGAFyXkc6Zgtra8WFWkca(9PDdf9rXn2XokgraOYv1eyuSIaas4WC2)bRiaBbxR)9zfbWd)bRiaZQYE4pyL1h(JaOp8NlpLIa0CT(3Nv0h9raAUw)7ZkkgrXv5OyebGkxvtGrXkcGh(dwraWVp41GIIaas4WC2)bRiaaEFWRbfXsdoSKcrqPu9SSknHXSSWxHILyb7smIaeM7P58iawZYSkQbhuKr11EfOmSLDTo)7xHcBifBD22ey0hf3nJIreaQCvnbgfRiaE4pyfbaVQ2nueGqNGMYVpOOhhfxLJaeM7P58iaGW3KcHv7gYmuQFfML4zzOu)kmlaplBUjliHfLT6iaGeomN9FWkcaYD8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDKXc4A8)GflhML97nSayvTBiwgk1VcZs6s)NT(iqwEilP(h2zjfcR2nelGRX)dwrFuCJDumIa4H)GveGuiSA3qraOYv1eyuSI(Opca(JIruCvokgraOYv1eyuSIa4H)Gvea87dEnOOiaGeomN9FWkcqCIjwa8(GxdkILhYcqezZYYMLFNyjooKNQEfinSOUAnwUgl3ZIf4sdYcHm7BiwuPgCiwAxD49RqXYVtSueYEwco(zboS8qwaxP2SOsn4qSGCyHacefbim3tZ5raMvrn4GIm)LswGtLbhYtvVcKgdvUQMazbnl9yHc6ZgtMRYE1Hf0Synl9yPhlQRwZ8xkzbovgCipv9kqAmdL6xHzjEw8WFWYyz8F3qiJcRNY)LsSamw2WOmlOzPhluqF2yYCvwf(7SKKWcf0NnMmxLXqTpSKKWcf0NnMm6v5tUiK9S0NLKewuxTM5VuYcCQm4qEQ6vG0ygk1VcZs8S4H)GLb)(0UHmeYOW6P8FPelaJLnmkZcAw6Xcf0NnMmxL1RYhwssyHc6Zgtgmu7tUiK9SKKWcf0NnMmE1jxeYEw6ZsFwssyXAwuxTM5VuYcCQm4qEQ6vG0yw2S0NLKew6XI6Q1mbpFvWSSzjjHfe(CUQMmbyHaceLbjCNkWsFwqZsac1GqlLjaleqGO8VtzS9n3Jnd5GDybnlbicQ86n1HA)ZnNyPplOzPhlwZsaIGkVEdqDMZlwssyjaHAqOLYqP2ql0KvHfOzOu)kmlXZIvZsFwqZspwuxTMj45RcMLnljjSynlbiudcTuMGNVkygYb7Ws)OpkUBgfJiau5QAcmkwra8WFWkcGd62)HGYyl(Kgbi0jOP87dk6XrXv5iaH5EAopcG1SacFJd62)HGYyl(KMb9uhfz(la0vOybnlwZIh(dwgh0T)dbLXw8jnd6PokYCvUPpu7plOzPhlwZci8noOB)hckJT4tAENCT5VaqxHILKewaHVXbD7)qqzSfFsZ7KRndL6xHzjEwuil9zjjHfq4BCq3(peugBXN0mON6Oid(9aqSSnlXMf0SacFJd62)HGYyl(KMb9uhfzgk1VcZY2SeBwqZci8noOB)hckJT4tAg0tDuK5VaqxHkcaiHdZz)hSIaeNyILUa62)HGybGfFszXYovS870qSCywkilE4peelyl(KQawCmlA)jwCml2qm(u1elWIfSfFszXY97SSjlWHLgzHgwWVhacZcCybwS4SeBGXc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdbHzbPKf(zXBpnS87(Zc2IpPSqiZ(gch9rXn2rXicavUQMaJIveap8hSIaeGfciqu(3Pm2(M7XraajCyo7)GveG4etywqoSqabIy5ASG8UGeRQcSCyww2Sahw6axS4dXciH7uHRqXcY7csSQkWIL73zb5WcbeiIfVazPdCXIpelQKgAHfRCdw6cElJaeM7P58iawZc4SoqtbZbqmlOzPhl9ybHpNRQjtawiGarzqc3PcSGMfRzjaHAqOLYe88vbZqoyhwqZI1SmRIAWbfzSNlfoGNRZ(e86cz7Lg7JHkxvtGSKKWI6Q1mbpFvWSSzPplOzXX)46Sn0cnSSTsSyLBWcAw6XI6Q1muqF2ykRxLpMHs9RWSeplkVbljjSOUAndf0NnMYyO2hZqP(vywINfL3GL(SKKWIkeJzbnlTd1(Nhk1VcZY2SO8gSGMfRzjaHAqOLYe88vbZqoyhw6h9rX1kJIreaQCvnbgfRiaq7iay6Ja4H)Gveae(CUQMIaGW1lkcqpwuxTMzCeubx4CBOkMDmdL6xHzjEwuiljjSynlQRwZmocQGlCUnufZoMLnl9zbnlwZI6Q1mJJGk4cNBdvXStgFvBPZ7DWpnNBw2SGMLESOUAndqxboeyMsTHwOjLQptfnOUysMHs9RWSSnlOcGMuhzS0Nf0S0Jf1vRzOG(SXugd1(ygk1VcZs8SGkaAsDKXssclQRwZqb9zJPSEv(ygk1VcZs8SGkaAsDKXsscl9yXAwuxTMHc6Zgtz9Q8XSSzjjHfRzrD1AgkOpBmLXqTpMLnl9zbnlwZY7AQEdgQX)fidvUQMazPFeaqchMZ(pyfba5Wc8(dwS0GdlUwZci8XS87(ZsQdeHzbVgILFN6WIpuPONLHAdH3jqwSStflXHocQGlmlBHHQy2HLDhZIMWyw(DVyrHSGPaMLHs9RUcflWHLFNybOoZ5flQRwJLdZIRcxplpKLMR1SaBnwGdlE1HfRiOpBmXYHzXvHRNLhYcHm7BOiai8jxEkfbae(5HuS1nukvpo6JIRcJIreaQCvnbgfRiaq7iay6Ja4H)Gveae(CUQMIaGW1lkcqpwSMf1vRzOG(SXugd1(yw2SGMfRzrD1AgkOpBmL1RYhZYML(SKKWY7AQEdgQX)fidvUQMaJaas4WC2)bRiaihwG3FWILF3Fwc7uaimlxJLoWfl(qSaxp(ajwOG(SXelpKfyP7Wci8z53PHyboSCOk4qS87hMfl3VZcaOg)xGIaGWNC5Pueaq4NHRhFGuMc6ZgtrFuCbUrXicavUQMaJIveap8hSIaKcHv7gkcqyUNMZJamuBi8URQjwqZspwuxTMHc6Zgtzmu7JzOu)kmlXZYqP(vywssyrD1AgkOpBmL1RYhZqP(vywINLHs9RWSKKWccFoxvtgq4NHRhFGuMc6ZgtS0Nf0SmuBi8URQjwqZY7dk6n)Ls5hMbpIL4zr5nzbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hf3TkkgraOYv1eyuSIa4H)Gvea8QA3qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjEwgk1VcZssclQRwZqb9zJPSEv(ygk1VcZs8SmuQFfMLKewq4Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkVjlOzXTZHDkaelOzbHpNRQjdi8ZdPyRBOuQECeGqNGMYVpOOhhfxLJ(O4A1rXicavUQMaJIveap8hSIaGFsR9j30(qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjEwgk1VcZssclQRwZqb9zJPSEv(ygk1VcZs8SmuQFfMLKewq4Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkdCzbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hf3TokgraOYv1eyuSIa4H)GveGgCcug2YL)RHIaas4WC2)bRiaXjMyzlaJllWILailwUFhUEwcUT9vOIaeM7P58iaUDoStbGI(O4Q8grXicavUQMaJIveap8hSIaqP2ql0KvHfyeaqchMZ(pyfbioXeliLVcCiqwayFZ9ywSC)olE1HfnSqXcvWfQDw0o(VcflwrqF2yIfVaz5NoS8qw0xrSCpllBwSC)olB5sJ9HfVazb5DbjwvfIaeM7P58ia9yPhlQRwZqb9zJPmgQ9XmuQFfML4zr5nyjjHf1vRzOG(SXuwVkFmdL6xHzjEwuEdw6ZcAwcqOgeAPmbpFvWmuQFfML4zj2BWcAw6XI6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lILTzztRCdwssyXAwMvrn4GIm2ZLchWZ1zFcEDHS9sJ9Xqk26STjqw6ZsFwssyrD1Ag75sHd456SpbVUq2EPX(yq46fXs8kXYMB1gSKKWsac1GqlLj45RcMHCWoSGMfh)JRZ2ql0Ws8SS1Be9rXvzLJIreaQCvnbgfRiaq7iay6Ja4H)Gveae(CUQMIaGW1lkcG1SaoRd0uWCaeZcAwq4Z5QAYeaZbybE)blwqZspw6Xsac1GqlLHsT7mKRZWbS8kqMHs9RWSSnlkdC3kwagl9yrzLzb4zzwf1GdkYGVQT059o4NMZnu5QAcKL(SGMfsXwNTnbAOu7od56mCalVcel9zjjHfh)JRZ2ql0Ws8kXYwVblOzPhlwZY7AQEtBnDYWwM0RImu5QAcKLKewuxTMj45RcgW14)blwINLaeQbHwktBnDYWwM0RImdL6xHzbySy1S0Nf0SacFdEvTBiZqP(vywINfL3Kf0SacFtkewTBiZqP(vywINfRMf0S0Jfq4BWpP1(KBAFiZqP(vywINfRMLKewSML31u9g8tATp5M2hYqLRQjqw6ZcAwq4Z5QAY87ZP1zmrart2IFplOzPhlQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzZssclwZsaIGkVEdqDMZlw6ZcAwEFqrV5Vuk)Wm4rSeplQRwZe88vbd4A8)GflaplBy2kwssyrfIXSGML2HA)ZdL6xHzzBwuxTMj45RcgW14)blwssyjarqLxVPou7FU5eljjSOUAnJQgcb1l8Bw2SGMf1vRzu1qiOEHFZqP(vyw2Mf1vRzcE(QGbCn(FWIfGXspw2AwaEwMvrn4GIm2ZLchWZ1zFcEDHS9sJ9Xqk26STjqw6ZsFwqZI1SOUAntWZxfmlBwqZspwSMLaebvE9M6qT)5MtSKKWsac1GqlLjaleqGO8VtzS9n3JnlBwssyrfIXSGML2HA)ZdL6xHzzBwcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlaJfGlljjS0ou7FEOu)kmlivwu2Q3GLTzrD1AMGNVkyaxJ)hSyPFeaqchMZ(pyfbioXeliVliXQQalwUFNfKdleqGiKGu(kWHazbG9n3JzXlqwaHLIEwGiOXYCpXYwU0yFyboSyzNkwILgcb1l8ZIf4sdYcHm7BiwuPgCiwqExqIvvbwiKzFdHJaGWNC5PueGayoalW7pyLXF0hfxL3mkgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiawZc4SoqtbZbqmlOzbHpNRQjtamhGf49hSybnl9yPhlbiudcTugk1UZqUodhWYRazgk1VcZY2SOmWDRybyS0JfLvMfGNLzvudoOid(Q2sN37GFAo3qLRQjqw6ZcAwifBD22eOHsT7mKRZWbS8kqS0NLKewC8pUoBdTqdlXRelB9gSGMLESynlVRP6nT10jdBzsVkYqLRQjqwssyrD1AMGNVkyaxJ)hSyjEwcqOgeAPmT10jdBzsVkYmuQFfMfGXIvZsFwqZci8n4v1UHmdL6xHzjEwSAwqZci8nPqy1UHmdL6xHzjEw2AwqZspwaHVb)Kw7tUP9HmdL6xHzjEwuEdwssyXAwExt1BWpP1(KBAFidvUQMazPplOzbHpNRQjZVpNwNXebenzl(9SGMLESOUAndqxboeyMsTHwOjLQptfnOUysMLnljjSynlbicQ86na1zoVyPplOz59bf9M)sP8dZGhXs8SOUAntWZxfmGRX)dwSa8SSHzRyjjHfvigZcAwAhQ9ppuQFfMLTzrD1AMGNVkyaxJ)hSyjjHLaebvE9M6qT)5MtSKKWI6Q1mQAieuVWVzzZcAwuxTMrvdHG6f(ndL6xHzzBwuxTMj45RcgW14)blwagl9yzRzb4zzwf1GdkYypxkCapxN9j41fY2ln2hdPyRZ2MazPpl9zbnlwZI6Q1mbpFvWSSzbnl9yXAwcqeu51BQd1(NBoXssclbiudcTuMaSqabIY)oLX23Cp2SSzjjHfvigZcAwAhQ9ppuQFfMLTzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSamwaUSKKWIkeJzbnlTd1(Nhk1VcZcsLfLT6nyzBwuxTMj45RcgW14)blw6hbaHp5YtPiabWCawG3FWkJ)OpkUkh7OyebGkxvtGrXkcGh(dwraghbvWfo3gQIzNiaGeomN9FWkcqCIjw(DIL4au97DgwSC)ololiVliXQQal)U)SC4srplTbMYYwU0yFIaeM7P58iaQRwZe88vbZqP(vywINfLviljjSOUAntWZxfmGRX)dwSSnlXEtwqZccFoxvtMayoalW7pyLXF0hfxLTYOyebGkxvtGrXkcqyUNMZJaGWNZv1KjaMdWc8(dwz8ZcAw6XI6Q1mbpFvWaUg)pyXs8kXsS3KLKewSMLaebvE9geu97Dgw6ZssclQRwZmocQGlCUnufZoMLnlOzrD1AMXrqfCHZTHQy2XmuQFfMLTzzRzbySeGf46EJ9qHdtzxFOQuQEZFPugHRxelaJLESynlQRwZOQHqq9c)MLnlOzXAwExt1BWVpA4aAOYv1eil9Ja4H)GveGaPj8FUo76dvLs1h9rXvzfgfJiau5QAcmkwracZ90CEeae(CUQMmbWCawG3FWkJ)iaE4pyfb4QGpL)hSI(O4QmWnkgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiawZsac1GqlLj45RcMHCWoSKKWI1SGWNZv1KjaleqGOmiH7ubwqZsaIGkVEtDO2)CZjwssybCwhOPG5aiocaiHdZz)hSIaehWNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoccKLgCyb5Dbjwvfybdz539NLFN6WIpu9SyXXpbYcsjl8ZIk1GdXYVtPraq4tU8ukca2rq5gCYbpFvi6JIRYBvumIaqLRQjWOyfbWd)bRiaT10jdBzsVkkcaiHdZz)hSIaeNycZYwaAfSCnwUIfVyXkc6ZgtS4fil)CeMLhYI(kIL7zzzZIL73zzlxASpkGfK3fKyvvGfVazPlGU9FiiwayXN0iaH5EAopcaf0NnMmxL9QdlOzXTZHDkaelOzrD1Ag75sHd456SpbVUq2EPX(yq46fXY2SSPvUblOzPhlGW34GU9FiOm2IpPzqp1rrM)caDfkwssyXAwcqeu51BkkmqnCazPplOzbHpNRQjd2rq5gCYbpFvGf0S0Jf1vRzghbvWfo3gQIzhZqP(vyw2MLTMLUMLESOqwaEwMvrn4GIm4RAlDEVd(P5CdvUQMazbySynlKIToBBc0Cf(Nv4HdodEiUIYQKwZsFwqZI6Q1mJJGk4cNBdvXSJzzZssclwZI6Q1mJJGk4cNBdvXSJzzZs)OpkUkB1rXicavUQMaJIveap8hSIaGFFAUwhbaKWH5S)dwraItmXYwCr)olaEFAUwZI9adywUglaEFAUwZYHlf9SSSJaeM7P58iaQRwZal63XzBAcK9FWYSSzbnlQRwZGFFAUwBgQneE3v1u0hfxL36OyebGkxvtGrXkcqyUNMZJaOUAnd(9rdhqZqP(vyw2MffYcAw6XI6Q1muqF2ykJHAFmdL6xHzjEwuiljjSOUAndf0NnMY6v5JzOu)kmlXZIczPplOzXX)46Sn0cnSeplB9gra8WFWkcqWRaPZQRwlcG6Q1YLNsraWVpA4ag9rXDZnIIreaQCvnbgfRiaE4pyfba)(GxdkkcaiHdZz)hSIaehxP2yw6cElzrLAWHyb5WcbeiILf(kuS87elihwiGarSeGf49hSy5HSe2PaqSCnwqoSqabIy5WS4HF5ADhwCv46z5HSOsSeC8hbim3tZ5racqeu51BQd1(NBoXcAwq4Z5QAYeGfciqugKWDQalOzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSSnlkKf0SynlGZ6anfmhaXSGMfkOpBmzUk7vhwqZIJ)X1zBOfAyjEwSYnI(O4UPYrXicavUQMaJIveap8hSIaGFFAUwhbaKWH5S)dwraItmXcG3NMR1Sy5(Dwa8Kw7dlXX5AplEbYsbzbW7JgoGkGfl7uXsbzbW7tZ1AwomllBfWsh4IfFiwUIffFv(WIve0NnMyPbhwSAGHPaMf4WYdzXEGbw2YLg7dlw2PIfxfIGyzR3GLUG3swGdloOT)hcIfSfFszz3XSy1adtbmldL6xDfkwGdlhMLRyPPpu7VHL4cFILF3FwwfinS87elypLyjalW7pyHz5EfHzb0gZsrRFCnlpKfaVpnxRzbCnxHIL4qhbvWfMLTWqvm7OawSStflDGlfbYc(pTMfQazzzZIL73zzR3ayo2MLgCy53jw0o(zbLgQ6ASjcqyUNMZJa8UMQ3GFsR9jdox7nu5QAcKf0SynlVRP6n43hnCanu5QAcKf0SOUAnd(9P5ATzO2q4DxvtSGMLESOUAndf0NnMY6v5JzOu)kmlXZIvZcAwOG(SXK5QSEv(WcAwuxTMXEUu4aEUo7tWRlKTxASpgeUErSSnlBQWnyjjHf1vRzSNlfoGNRZ(e86cz7Lg7JbHRxelXRelBQWnybnlo(hxNTHwOHL4zzR3GLKewaHVXbD7)qqzSfFsZGEQJImdL6xHzjEwSAwssyXd)blJd62)HGYyl(KMb9uhfzUk30hQ9NL(SGMLaeQbHwktWZxfmdL6xHzjEwuEJOpkUBUzumIaqLRQjWOyfbWd)bRia43h8AqrraajCyo7)GveG4etSa49bVguelBXf97SypWaMfVazbCLAZsxWBjlw2PIfK3fKyvvGf4WYVtSehGQFVZWI6Q1y5WS4QW1ZYdzP5AnlWwJf4Wsh4srGSeCBw6cElJaeM7P58iaQRwZal63X5GM8jJ4WhSmlBwssyrD1AgGUcCiWmLAdTqtkvFMkAqDXKmlBwssyrD1AMGNVkyw2SGMLESOUAnZ4iOcUW52qvm7ygk1VcZY2SGkaAsDKXcWZsGonl9yXX)46Sn0cnSGewI9gS0NfGXsSzb4z5DnvVPil5uiSmu5QAcKf0SynlZQOgCqrg8vTLoV3b)0CUHkxvtGSGMf1vRzghbvWfo3gQIzhZYMLKewuxTMj45RcMHs9RWSSnlOcGMuhzSa8SeOtZspwC8pUoBdTqdliHLyVbl9zjjHf1vRzghbvWfo3gQIzNm(Q2sN37GFAo3SSzjjHLESOUAnZ4iOcUW52qvm7ygk1VcZY2S4H)GLb)(0UHmeYOW6P8FPelOzbBtADE3XpXY2SSHXkzjjHf1vRzghbvWfo3gQIzhZqP(vyw2Mfp8hSmwg)3neYOW6P8FPeljjSGWNZv1K5umWCawG3FWIf0SeGqni0szUchM17QAkRylV(vAgKqCbYmKd2Hf0Sqk26STjqZv4WSExvtzfB51VsZGeIlqS0Nf0SOUAnZ4iOcUW52qvm7yw2SKKWI1SOUAnZ4iOcUW52qvm7yw2SGMfRzjaHAqOLYmocQGlCUnufZoMHCWoSKKWI1SeGiOYR3GGQFVZWsFwssyXX)46Sn0cnSeplB9gSGMfkOpBmzUk7vNOpkUBg7OyebGkxvtGrXkcGh(dwraWVp41GIIaas4WC2)bRiaXy6WYdzj1bIy53jwuj8ZcSXcG3hnCazrTdl43daDfkwUNLLnlk26caP7WYvS4vhwSIG(SXelQRNLTCPX(WYHRNfxfUEwEilQel2dmeiWiaH5EAopcW7AQEd(9rdhqdvUQMazbnlwZYSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eilOzPhlQRwZGFF0Wb0SSzjjHfh)JRZ2ql0Ws8SS1BWsFwqZI6Q1m43hnCan43daXY2SeBwqZspwuxTMHc6Zgtzmu7JzzZssclQRwZqb9zJPSEv(yw2S0Nf0SOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyzBw2CR2Gf0S0JLaeQbHwktWZxfmdL6xHzjEwuEdwssyXAwq4Z5QAYeGfciqugKWDQalOzjarqLxVPou7FU5el9J(O4UPvgfJiau5QAcmkwraG2raW0hbWd)bRiai85CvnfbaHRxueakOpBmzUkRxLpSa8Sy1SGew8WFWYGFFA3qgczuy9u(VuIfGXI1Sqb9zJjZvz9Q8HfGNLESaCzbyS8UMQ3GHlDg2Y)oLBWHWVHkxvtGSa8SeBw6ZcsyXd)blJLX)DdHmkSEk)xkXcWyzdJvQqwqclyBsRZ7o(jwaglByuilaplVRP6nL)RHWzvx7vGmu5QAcmcaiHdZz)hSIayf4)s9NWSSdTWs6kSZsxWBjl(qSGYVIazXMgwWuawGraq4tU8ukcGJT3sAaqHOpkUBQWOyebGkxvtGrXkcGh(dwraWVp41GIIaas4WC2)bRiaXXvQnlaEFWRbfXYvS4SSvadtbwaa1(WIve0NnMualGWsrplA6z5EwShyGLTCPX(WsVF3Fwoml7EbQjqwu7WcD)onS87elaEFAUwZI(kIf4WYVtS0f8wg)wVbl6RiwAWHfaVp41GI6RawaHLIEwGiOXYCpXIxSSfx0VZI9adS4filA6z53jwCvicIf9vel7EbQjwa8(OHdyeGWCpnNhbWAwMvrn4GIm)LswGtLbhYtvVcKgdvUQMazbnl9yrD1Ag75sHd456SpbVUq2EPX(yq46fXY2SS5wTbljjSOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyzBw2uHBWcAwExt1BWpP1(KbNR9gQCvnbYsFwqZspwOG(SXK5QmgQ9Hf0S44FCD2gAHgwagli85CvnzCS9wsdakWcWZI6Q1muqF2ykJHAFmdL6xHzbySacFtBnDYWwM0RIm)facNhk1VIfGNLnnkKL4zXQ3GLKewOG(SXK5QSEv(WcAwC8pUoBdTqdlaJfe(CUQMmo2ElPbafyb4zrD1AgkOpBmL1RYhZqP(vywaglGW30wtNmSLj9QiZFbGW5Hs9Ryb4zztJczjEw26nyPplOzXAwuxTMbw0VJZ20ei7)GLzzZcAwSML31u9g87JgoGgQCvnbYcAw6Xsac1GqlLj45RcMHs9RWSeplBfljjSGHlT6vGMFFoToJjciAmu5QAcKf0SOUAnZVpNwNXebeng87bGyzBwIDSzPRzPhlZQOgCqrg8vTLoV3b)0CUHkxvtGSa8SOqw6ZcAwAhQ9ppuQFfML4zr5n2Gf0S0ou7FEOu)kmlBZYMBSbl9zbnl9yjaHAqOLYa0vGdbMX23Cp2muQFfML4zzRyjjHfRzjarqLxVbOoZ5fl9J(O4UjWnkgraOYv1eyuSIa4H)GveGISKtHWkcaiHdZz)hSIaeNyILTiiSWSCflk(Q8HfRiOpBmXIxGSGDeelXb76gW2clTMLTiiSyPbhwqExqIvvbw8cKfKYxboeilwrQn0cnPu9racZ90CEeGESOUAndf0NnMY6v5JzOu)kmlXZcHmkSEk)xkXsscl9yjS7dkcZIsSSjlOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwInl9zbnlUDoStbGybnli85CvnzWock3Gto45RcrFuC3CRIIreaQCvnbgfRiaH5EAopcqpwuxTMHc6Zgtz9Q8XmuQFfML4zHqgfwpL)lLybnlwZsaIGkVEdqDMZlwssyPhlQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzZcAwcqeu51BaQZCEXsFwssyPhlHDFqrywuILnzbnldf29bfL)lLyzBwuil9zjjHLWUpOimlkXsSzjjHf1vRzcE(QGzzZsFwqZIBNd7uaiwqZccFoxvtgSJGYn4KdE(QalOzPhlQRwZmocQGlCUnufZoMHs9RWSSnl9yrHS01SSjlaplZQOgCqrg8vTLoV3b)0CUHkxvtGS0Nf0SOUAnZ4iOcUW52qvm7yw2SKKWI1SOUAnZ4iOcUW52qvm7yw2S0pcGh(dwra2DDlNcHv0hf3nT6OyebGkxvtGrXkcqyUNMZJa0Jf1vRzOG(SXuwVkFmdL6xHzjEwiKrH1t5)sjwqZI1SeGiOYR3auN58ILKew6XI6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2SGMLaebvE9gG6mNxS0NLKew6Xsy3hueMfLyztwqZYqHDFqr5)sjw2MffYsFwssyjS7dkcZIsSeBwssyrD1AMGNVkyw2S0Nf0S425WofaIf0SGWNZv1Kb7iOCdo5GNVkWcAw6XI6Q1mJJGk4cNBdvXSJzOu)kmlBZIczbnlQRwZmocQGlCUnufZoMLnlOzXAwMvrn4GIm4RAlDEVd(P5CdvUQMazjjHfRzrD1AMXrqfCHZTHQy2XSSzPFeap8hSIa0wADofcROpkUBU1rXicavUQMaJIveaqchMZ(pyfbioXelifqRGfyXsamcGh(dwraS4ZCWjdBzsVkk6JIBS3ikgraOYv1eyuSIa4H)Gvea87t7gkcaiHdZz)hSIaeNyIfaVpTBiwEil2dmWcaO2hwSIG(SXKcyb5Dbjwvfyz3XSOjmML)sjw(DVyXzbPy8FNfczuy9elAQ9SahwGLUdlk(Q8HfRiOpBmXYHzzzhbim3tZ5raOG(SXK5QSEv(WcAwSMf1vRzghbvWfo3gQIzhZYMLKewOG(SXKbd1(KlczpljjSqb9zJjJxDYfHSNLKew6XI6Q1mw8zo4KHTmPxfzw2SKKWc2M068UJFILTzzdJvQqwqZI1SeGiOYR3GGQFVZWssclyBsRZ7o(jw2MLnmwjlOzjarqLxVbbv)ENHL(SGMf1vRzOG(SXuwVkFmlBwssyPhlQRwZe88vbZqP(vyw2Mfp8hSmwg)3neYOW6P8FPelOzrD1AMGNVkyw2S0p6JIBSvokgraOYv1eyuSIaas4WC2)bRiaXjMybPy8FNf4VtJLdtSyz)c7SCywUIfaqTpSyfb9zJjfWcY7csSQkWcCy5HSypWalk(Q8HfRiOpBmfbWd)bRiawg)3J(O4g7nJIreaQCvnbgfRiaGeomN9FWkcWwW16FFwra8WFWkcWSQSh(dwz9H)ia6d)5YtPianxR)9zf9rFea7HcWuv)JIruCvokgra8WFWkcaqxboeygBFZ94iau5QAcmkwrFuC3mkgraOYv1eyuSIaaTJaGPpcGh(dwraq4Z5QAkcacxVOiaBebaKWH5S)dwraIXoXccFoxvtSCywW0ZYdzzdwSC)olfKf87plWILfMy5NRaIEScyrzwSStfl)oXs7g8ZcSiwomlWILfMualBYY1y53jwWuawGSCyw8cKLyZY1yrf(7S4dfbaHp5YtPiaWkVWu(NRaI(OpkUXokgraOYv1eyuSIaaTJa4GGra8WFWkcacFoxvtraq46ffbq5iaH5EAopcWpxbe9MxzZUJZlmLvxTglOz5NRaIEZRSjaHAqOLYaUg)pyXcAwSMLFUci6nVYMdBEykLHTCkSW)ax4Caw4FwH)GfocacFYLNsraGvEHP8pxbe9rFuCTYOyebGkxvtGrXkca0ocGdcgbWd)bRiai85CvnfbaHRxueGnJaeM7P58ia)Cfq0B(nn7ooVWuwD1ASGMLFUci6n)MMaeQbHwkd4A8)GflOzXAw(5kGO38BAoS5HPug2YPWc)dCHZbyH)zf(dw4iai8jxEkfbaw5fMY)Cfq0h9rXvHrXicavUQMaJIveaODeahemcGh(dwraq4Z5QAkcacFYLNsraGvEHP8pxbe9racZ90CEeasXwNTnbAUchM17QAkRylV(vAgKqCbILKewifBD22eOHsT7mKRZWbS8kqSKKWcPyRZ2Many4sRP)VcvEwQDIaas4WC2)bRiaXyNWel)Cfq0JzXhILc(S4RhM6)fCTUdlG0tHNazXXSalwwyIf87pl)Cfq0JnSWca6zbHpNRQjwEilwjloMLFN6WIRXqwkIazbBtHZ1SS7fO(kuMiaiC9IIayLrFuCbUrXicGh(dwrasHWcORYn4KgbGkxvtGrXk6JI7wffJiau5QAcmkwra8WFWkcGLX)9iaH5EAopcqpwOG(SXKrVkFYfHSNLKewOG(SXK5QmgQ9HLKewOG(SXK5QSk83zjjHfkOpBmz8QtUiK9S0pcG(kkhaJaO8grF0h9raqqd(GvuC3CJnvEdRw5nJayXN6ku4iaifDjomUwvCJdc4WclXyNy5sTHZZsdoSOiOnv0OiwgsXw3qGSGHPel(6HP(tGSe29cfHnC3k(velBcCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyj2ahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4U5Urk6sCyCTQ4gheWHfwIXoXYLAdNNLgCyrrGuZx6xrSmKITUHazbdtjw81dt9NazjS7fkcB4Uv8RiwaUahwqoSqqZtGSa4srol4o17iJfKklpKffF5SaEio8blwG204pCyPhs6ZspLrwFd3TIFfXcWf4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYwbCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyXQboSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEBIS(gUBf)kIfRg4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYwdCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyzRboSGCyHGMNazrr)Cfq0Bu20vkILhYII(5kGO38kB6kfXsVnrwFd3TIFfXYwdCyb5WcbnpbYII(5kGO3SPPRuelpKff9ZvarV5300vkILEBIS(gUBf)kIfL3a4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXIYkdCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyr5nboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSOCSboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSOScboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSOmWf4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXsVnrwFd3TIFfXIYaxGdlihwiO5jqwu0pxbe9gLnDLIy5HSOOFUci6nVYMUsrS0BtK13WDR4xrSOmWf4WcYHfcAEcKff9ZvarVzttxPiwEilk6NRaIEZVPPRuel9ugz9nC3k(velkVvahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6TjY6B4Uv8RiwuERaoSGCyHGMNazrr)Cfq0Bu20vkILhYII(5kGO38kB6kfXspLrwFd3TIFfXIYBfWHfKdle08eilk6NRaIEZMMUsrS8qwu0pxbe9MFttxPiw6TjY6B4U5Urk6sCyCTQ4gheWHfwIXoXYLAdNNLgCyrr2dfGPQ(RiwgsXw3qGSGHPel(6HP(tGSe29cfHnC3k(velXg4WcYHfcAEcKff9ZvarVrztxPiwEilk6NRaIEZRSPRuel9InY6B4Uv8RiwSsGdlihwiO5jqwu0pxbe9MnnDLIy5HSOOFUci6n)MMUsrS0l2iRVH7M7gPOlXHX1QIBCqahwyjg7elxQnCEwAWHff5qsrSmKITUHazbdtjw81dt9NazjS7fkcB4Uv8Riwug4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXI)SyfBXkol9ugz9nC3k(velXg4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYwbCyb5WcbnpbYcGlf5SG7uVJmwqQivwEilk(YzjfcU0lmlqBA8hoS0dP2NLEkJS(gUBf)kILTc4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXsVnrwFd3TIFfXIvdCyb5WcbnpbYcGlf5SG7uVJmwqQivwEilk(YzjfcU0lmlqBA8hoS0dP2NLEkJS(gUBf)kIfRg4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYwdCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyr5naoSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEBIS(gUBf)kIfLJnWHfKdle08eilaUuKZcUt9oYybPYYdzrXxolGhIdFWIfOnn(dhw6HK(S0tzK13WDR4xrSS5gahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8Riw2CtGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zPNYiRVH7wXVIyztRe4WcYHfcAEcKfaxkYzb3PEhzSGuz5HSO4lNfWdXHpyXc0Mg)Hdl9qsFw6TjY6B4Uv8Riw20kboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSSjWf4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYMBfWHfKdle08eilkAwf1GdkY0vkILhYIIMvrn4GImDLHkxvtGkILEkJS(gUBf)kILn3AGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zP3MiRVH7wXVIyj2BaCyb5WcbnpbYcGlf5SG7uVJmwqQS8qwu8LZc4H4WhSybAtJ)WHLEiPpl9ugz9nC3C3ifDjomUwvCJdc4WclXyNy5sTHZZsdoSOOMR1)(SueldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kILnboSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEkJS(gUBUBKIUehgxRkUXbbCyHLyStSCP2W5zPbhwue(veldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kIfLboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSeBGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkRmWHfKdle08eilaUuKZcUt9oYybPIuz5HSO4lNLui4sVWSaTPXF4WspKAFw6PmY6B4Uv8RiwuwzGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkVjWHfKdle08eilaUuKZcUt9oYybPIuz5HSO4lNLui4sVWSaTPXF4WspKAFw6PmY6B4Uv8RiwuEtGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkVvahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8Riw2CtGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zP3MiRVH7wXVIyzZnboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSSzSboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSSPvcCyb5WcbnpbYcGlf5SG7uVJmwqQS8qwu8LZc4H4WhSybAtJ)WHLEiPpl9InY6B4Uv8Riw2uHahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6TjY6B4Uv8Riw2CRaoSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSSPvdCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7M7gPOlXHX1QIBCqahwyjg7elxQnCEwAWHffPc9xrSmKITUHazbdtjw81dt9NazjS7fkcB4Uv8Riwu2QboSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEXgz9nC3k(velkV1ahwqoSqqZtGSa4srol4o17iJfKklpKffF5SaEio8blwG204pCyPhs6ZspLrwFd3n3TvLAdNNazzRyXd)blw0h(XgU7ia2dSDAkcasJ0Selx7vGyjooRdK7gPrAw6Yc1c)SOSvRaw2CJnvM7M7gPrAwq(UxOimWH7gPrAw6Aw6ciibYcaO2hwIf5PgUBKgPzPRzb57EHIaz59bf95RXsWXeMLhYsOtqt53hu0JnC3insZsxZsCiLcrqGSSQIceg7thwq4Z5QAcZsVZqgfWI9qiY43h8AqrS01XZI9qim43h8Aqr9nC3insZsxZsxqapqwShk44)kuSGum(VZY1y5EfHz53jwSmWcflwrqF2yYWDJ0inlDnlBroqelihwiGarS87elaSV5Emlol67FnXskCiwAAczNQMyP31yPdCXYUdwk6zz)EwUNf8LU0VxeCH1DyXY97SeRT4UedwagliN0e(pxZsx0hQkLQxbSCVIazbd0z33WDJ0inlDnlBroqelPq8ZIIAhQ9ppuQFfwrSGdu5ZbXS4226oS8qwuHymlTd1(Jzbw6ogUBKgPzPRzjgd5plXaMsSaBSelTVZsS0(olXs77S4ywCwW2u4Cnl)Cfq0B4UrAKMLUMLTyBQOHLENHmkGfKIX)DfWcsX4)UcybW7t7gQplPoiXskCiwgcF6JQNLhYc5J(OHLamv1)Ug)(8gUBUBKgPzPlvbF)jqwILR9kqS0LTuXzj4flQeln4QazXFw2)3gdCqcsuDTxbQRXxAWG6(9LQ5GijwU2Ra11aUuKJKuqZ(NQrkD70KsQU2RazEK9C3C3E4pyHn2dfGPQ(ReqxboeygBFZ9yUBKMLyStSGWNZv1elhMfm9S8qw2Gfl3VZsbzb)(ZcSyzHjw(5kGOhRawuMfl7uXYVtS0Ub)SalILdZcSyzHjfWYMSCnw(DIfmfGfilhMfVazj2SCnwuH)ol(qC3E4pyHn2dfGPQ(dmLqccFoxvtkO8usjyLxyk)ZvarVcq46fP0gC3E4pyHn2dfGPQ(dmLqccFoxvtkO8usjyLxyk)ZvarVcG2k5GGkaHRxKskRGRP0pxbe9gLn7ooVWuwD1AO)5kGO3OSjaHAqOLYaUg)pyH26FUci6nkBoS5HPug2YPWc)dCHZbyH)zf(dwyUBp8hSWg7HcWuv)bMsibHpNRQjfuEkPeSYlmL)5kGOxbqBLCqqfGW1lsPnvW1u6NRaIEZMMDhNxykRUAn0)Cfq0B20eGqni0szaxJ)hSqB9pxbe9Mnnh28WukdB5uyH)bUW5aSW)Sc)blm3nsZsm2jmXYpxbe9yw8HyPGpl(6HP(FbxR7Wci9u4jqwCmlWILfMyb)(ZYpxbe9ydlSaGEwq4Z5QAILhYIvYIJz53PoS4AmKLIiqwW2u4Cnl7EbQVcLH72d)blSXEOamv1FGPesq4Z5QAsbLNskbR8ct5FUci6va0wjheubiC9IuYkvW1uIuS1zBtGMRWHz9UQMYk2YRFLMbjexGssifBD22eOHsT7mKRZWbS8kqjjKIToBBc0GHlTM()ku5zP2H72d)blSXEOamv1FGPessHWcORYn4KYD7H)Gf2ypuaMQ6pWucjwg)3vG(kkhavs5nuW1uQhf0NnMm6v5tUiK9jjuqF2yYCvgd1(KKqb9zJjZvzv4VNKqb9zJjJxDYfHSVp3n3nsZYwouWXplBYcsX4)olEbYIZcG3h8AqrSalwaedwSC)olX9qT)SSfCIfVazjwWUedwGdlaEFA3qSa)DASCyI72d)blSbAtfnatjKyz8FxbxtPEuqF2yYOxLp5Iq2NKqb9zJjZvzmu7tscf0NnMmxLvH)Escf0NnMmE1jxeY((OThcHrzJLX)D0wBpecZMglJ)7C3E4pyHnqBQObykHe87t7gsb6ROCaujfQGRPK1ZQOgCqrgvx7vGYWw2168VFfkCsI1bicQ86n1HA)ZnNssSgBtAD(9bf9yd(9P5ATskNKy97AQEt5)AiCw11EfidvUQMats6rb9zJjdgQ9jxeY(KekOpBmzUkRxLpjjuqF2yYCvwf(7jjuqF2yY4vNCri77ZD7H)Gf2aTPIgGPesWVp41GIuG(kkhavsHk4AknRIAWbfzuDTxbkdBzxRZ)(vOWOdqeu51BQd1(NBoHgBtAD(9bf9yd(9P5ATskZDZDJ0inlwbYOW6jqwie00HL)sjw(DIfp8WHLdZIJWpTRQjd3Th(dwyLWqTpzvYt5U9WFWcdmLqsW16Sh(dwz9HFfuEkPe0MkAuW1u6VuA7EBc8E4pyzSm(VBco(Z)LsaZd)bld(9PDdzco(Z)Ls95UrAwaqpMLUaTcwGflXgySy5(D46zbCU2ZIxGSy5(Dwa8(OHdilEbYYMaJf4VtJLdtC3E4pyHbMsibHpNRQjfuEkP0HZoKuacxViLW2KwNFFqrp2GFFAUwhVYO7z97AQEd(9rdhqdvUQMatsExt1BWpP1(KbNR9gQCvnb2pjbBtAD(9bf9yd(9P5AD8BYDJ0SaGEmlbn5iiwSStflaEFA3qSe8IL97zztGXY7dk6XSyz)c7SCywgsti86zPbhw(DIfRiOpBmXYdzrLyXEOgndbYIxGSyz)c7S0oTMgwEilbh)C3E4pyHbMsibHpNRQjfuEkP0HZbn5iifGW1lsjSnP153hu0Jn43N2nu8kZDJ0SehWNZv1el)U)Se2PaqywUglDGlw8Hy5kwCwqfaz5HS4iGhil)oXc((L)hSyXYonelol)Cfq0Zc9bwomllmbYYvSOsVfIkwco(XC3E4pyHbMsibHpNRQjfuEkP0vzubqfGW1lsj7HqysHWQDdLKypecdEvTBOKe7HqyWVp41GIssShcHb)(0CTojXEieM2A6KHTmPxfLKOUAntWZxfmdL6xHvsD1AMGNVkyaxJ)hSssShcHzCeubx4CBOkMDssq4Z5QAYC4SdjUBKML4etSelAW0a0vOyXY97SG8UGeRQcSahw82tdlihwiGarSCfliVliXQQa3Th(dwyGPesuPbtdqxHsbxtPE9SoarqLxVPou7FU5usI1biudcTuMaSqabIY)oLX23Cp2SS7JwD1AMGNVkygk1VchVYkeT6Q1mJJGk4cNBdvXSJzOu)k82wjARdqeu51Bqq1V3zsscqeu51Bqq1V3zqRUAntWZxfmlB0QRwZmocQGlCUnufZoMLn6EQRwZmocQGlCUnufZoMHs9RWBRSYDTcb(zvudoOid(Q2sN37GFAopjrD1AMGNVkygk1VcVTYkNKOmsfBtADE3XpTTYgfQW(9rJWNZv1K5QmQai3nsZYwcFwSC)ololiVliXQQal)U)SC4srplolB5sJ9Hf7bgyboSyzNkw(DIL2HA)z5WS4QW1ZYdzHkqUBp8hSWatjKyd)dwk4AkPUAntWZxfmdL6xHJxzfIUN1ZQOgCqrg8vTLoV3b)0CEsI6Q1mJJGk4cNBdvXSJzOu)k82kVvD9MaV6Q1mQAieuVWVzzJwD1AMXrqfCHZTHQy2XSS7NKOcXy0Td1(Nhk1VcV9MkK7gPzb5UoS0(tywSSt)onSSWxHIfKdleqGiwkOfwSCAnlUwdTWsh4ILhYc(pTMLGJFw(DIfSNsS4PWv9SaBSGCyHacebmK3fKyvvGLGJFm3Th(dwyGPesq4Z5QAsbLNskfGfciqugKWDQGcq46fPuGoDVETd1(Nhk1Vc31kRWUoaHAqOLYe88vbZqP(v4(ivLT6n6RuGoDVETd1(Nhk1Vc31kRWUoaHAqOLYeGfciqu(3Pm2(M7XgW14)bRUoaHAqOLYeGfciqu(3Pm2(M7XMHs9RW9rQkB1B0hT1JFGzcbvVXbbXgczh(XjjbiudcTuMGNVkygk1Vch)vpn2qT)eyUDO2)8qP(v4KKzvudoOitG0e(pxNX23CpgDac1GqlLj45RcMHs9RWXh7nsscqOgeAPmbyHaceL)DkJTV5ESzOu)kC8x90yd1(tG52HA)ZdL6xH7AL3ijX6aebvE9M6qT)5MtC3inlXjMaz5HSasAVdl)oXYc7OiwGnwqExqIvvbwSStfll8vOybeUu1elWILfMyXlqwShcbvpllSJIyXYovS4floiilecQEwomlUkC9S8qwapI72d)blmWucji85CvnPGYtjLcG5aSaV)GLcq46fPuV2HA)ZdL6xHJxzfMKm(bMjeu9gheeBUkEfUrF0961JuS1zBtGgk1UZqUodhWYRaHUxac1GqlLHsT7mKRZWbS8kqMHs9RWBRmWDJKKaebvE9geu97Dg0biudcTugk1UZqUodhWYRazgk1VcVTYa3Tcy9uwzGFwf1GdkYGVQT059o4NMZ73hT1biudcTugk1UZqUodhWYRazgYb70pjHuS1zBtGgmCP10)xHkpl1oO7zDaIGkVEtDO2)CZPKKaeQbHwkdgU0A6)RqLNLANCSTsfA1BOSzOu)k82kRSv2pjPxac1GqlLrLgmnaDfkZqoyNKeRhpqMFGADF096rk26STjqZv4WSExvtzfB51VsZGeIlqO7fGqni0szUchM17QAkRylV(vAgKqCbYmKd2jjXd)blZv4WSExvtzfB51VsZGeIlqgWd7QAcSF)KKEKIToBBc0G3DqOfcmdh1mSLF4Ks1JoaHAqOLY8WjLQNaZxHpu7Fo2kuHXEtLndL6xH7NK0RhcFoxvtgyLxyk)ZvarVskNKGWNZv1Kbw5fMY)Cfq0RuS7JU3pxbe9gLnd5GDYbiudcTujj)Cfq0Bu2eGqni0szgk1Vch)vpn2qT)eyUDO2)8qP(v4Uw5n6NKGWNZv1Kbw5fMY)Cfq0R0MO79ZvarVztZqoyNCac1GqlvsYpxbe9MnnbiudcTuMHs9RWXF1tJnu7pbMBhQ9ppuQFfURvEJ(jji85CvnzGvEHP8pxbe9kTr)(9tscqeu51BaQZCE1pjrfIXOBhQ9ppuQFfEB1vRzcE(QGbCn(FWI7gPzjoGpNRQjwwycKLhYciP9oS4vhw(5kGOhZIxGSeaXSyzNkwS43FfkwAWHfVyXkw27W5CwShyG72d)blmWucji85CvnPGYtjL(9506mMiGOjBXVxbiC9IuYAmCPvVc087ZP1zmrarJHkxvtGjjTd1(Nhk1Vch)MBSrsIkeJr3ou7FEOu)k82BQqG1Zk3ORvxTM53NtRZyIaIgd(9aqa)M9tsuxTM53NtRZyIaIgd(9aqXhBRUR7nRIAWbfzWx1w68Eh8tZ5aVc7ZDJ0SeNyIfRi1UZqUMLT4bS8kqSS5gykGzrLAWHyXzb5DbjwvfyzHjd3Th(dwyGPeswykFpLQGYtjLOu7od56mCalVcKcUMsbiudcTuMGNVkygk1VcV9MBGoaHAqOLYeGfciqu(3Pm2(M7XMHs9RWBV5gO7HWNZv1K53NtRZyIaIMSf)(Ke1vRz(9506mMiGOXGFpau8XEdG1Bwf1GdkYGVQT059o4NMZbEGB)(Or4Z5QAYCvgvamjrfIXOBhQ9ppuQFfE7yVvC3inlXjMybaCP10FfkwIdxQDyb4IPaMfvQbhIfNfK3fKyvvGLfMmC3E4pyHbMsizHP89uQckpLucdxAn9)vOYZsTJcUMs9cqOgeAPmbpFvWmuQFfEBGlARdqeu51Bqq1V3zqBDaIGkVEtDO2)CZPKKaebvE9M6qT)5MtOdqOgeAPmbyHaceL)DkJTV5ESzOu)k82ax09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMHs9RWBdC7NKeGiOYR3GGQFVZGUN1ZQOgCqrg8vTLoV3b)0Co6aeQbHwktWZxfmdL6xH3g4MKOUAnZ4iOcUW52qvm7ygk1VcVTYwjW6PqGNuS1zBtGMRW)ScpCWzWdXvuwL06(OvxTMzCeubx4CBOkMDml7(jjTd1(Nhk1VcV9MkmjHuS1zBtGgk1UZqUodhWYRaHoaHAqOLYqP2DgY1z4awEfiZqP(v443CJ(Or4Z5QAYCvgvaeT1KIToBBc0CfomR3v1uwXwE9R0miH4cussac1GqlL5kCywVRQPSIT86xPzqcXfiZqP(v443CJKevigJUDO2)8qP(v4T3CdUBKMLUOT4DWSSWelwfsPIJSy5(DwqExqIvvbUBp8hSWatjKGWNZv1KckpLu6umWCawG3FWsbiC9IusD1AMGNVkygk1VchVYkeDpRNvrn4GIm4RAlDEVd(P58Ke1vRzghbvWfo3gQIzhZqP(v4Tvs5nnBcSEXg4vxTMrvdHG6f(nl7(aRNv31ke4vxTMrvdHG6f(nl7(apPyRZ2ManxH)zfE4GZGhIROSkP1OvxTMzCeubx4CBOkMDml7(jjQqmgD7qT)5Hs9RWBVPctsifBD22eOHsT7mKRZWbS8kqOdqOgeAPmuQDNHCDgoGLxbYmuQFfM72d)blmWucjlmLVNsvq5PKsxHdZ6DvnLvSLx)kndsiUaPGRPecFoxvtMtXaZbybE)bl0i85CvnzUkJkaYDJ0SeNyIL5qT)SOsn4qSeaXC3E4pyHbMsizHP89uQckpLucV7GqleygoQzyl)WjLQxbxtPEbiudcTuMGNVkygYb7G26aebvE9M6qT)5MtOr4Z5QAY87ZP1zmrart2IFFssaIGkVEtDO2)CZj0biudcTuMaSqabIY)oLX23Cp2mKd2bDpe(CUQMmbyHaceLbjCNkKKeGqni0szcE(QGzihSt)(ObHVbVQ2nK5VaqxHcDpq4BWpP1(KBAFiZFbGUcvsI1VRP6n4N0AFYnTpKHkxvtGjjyBsRZVpOOhBWVpTBO4JDF09aHVjfcR2nK5VaqxHQp6Ei85CvnzoC2HusYSkQbhuKr11EfOmSLDTo)7xHcNK44FCD2gAHM4vAR3ijrD1AgvnecQx43SS7JUxac1GqlLrLgmnaDfkZqoyNKeRhpqMFGADF0wtk26STjqZv4WSExvtzfB51VsZGeIlqjjKIToBBc0CfomR3v1uwXwE9R0miH4ce6EbiudcTuMRWHz9UQMYk2YRFLMbjexGmdL6xHJp2BKKeGqni0szuPbtdqxHYmuQFfo(yVrF0wRUAntWZxfml7KevigJUDO2)8qP(v4TTYn4UrAwIX(Hz5WS4Sm(VtdlK2vHJ)elw8oS8qwsDGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veillBwSC)oliVliXQQalEbYcYHfciqelEbYYctS87elBwGSG1WNfyXsaKLRXIk83z5NRaIEml(qSalwwyIf87pl)Cfq0J5U9WFWcdmLqYct57PuScWA4Jv6NRaIELvW1uQhcFoxvtgyLxyk)ZvarV1kPmAR)5kGO3SPzihStoaHAqOLkjPhcFoxvtgyLxyk)ZvarVskNKGWNZv1Kbw5fMY)Cfq0RuS7JUN6Q1mbpFvWSSr3Z6aebvE9geu97DMKe1vRzghbvWfo3gQIzhZqP(vyG1tHa)SkQbhuKbFvBPZ7DWpnN3FBL(5kGO3OSrD1AzW14)bl0QRwZmocQGlCUnufZoMLDsI6Q1mJJGk4cNBdvXStgFvBPZ7DWpnNBw29tscqOgeAPmbpFvWmuQFfgyBg)pxbe9gLnbiudcTugW14)bl0wRUAntWZxfmlB09SoarqLxVPou7FU5usI1i85CvnzcWcbeikds4ovOpARdqeu51BaQZCELKeGiOYR3uhQ9p3CcncFoxvtMaSqabIYGeUtfqhGqni0szcWcbeik)7ugBFZ9yZYgT1biudcTuMGNVkyw2O71tD1AgkOpBmL1RYhZqP(v44vEJKe1vRzOG(SXugd1(ygk1VchVYB0hT1ZQOgCqrgvx7vGYWw2168VFfkCssp1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGusHjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43daPKv3VFsI6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw29tsAhQ9ppuQFfE7n3ijbHpNRQjdSYlmL)5kGOxPn6JgHpNRQjZvzubqUBp8hSWatjKSWu(EkfRaSg(yL(5kGOFtfCnL6HWNZv1Kbw5fMY)Cfq0BTsBI26FUci6nkBgYb7KdqOgeAPssq4Z5QAYaR8ct5FUci6vAt09uxTMj45RcMLn6EwhGiOYR3GGQFVZKKOUAnZ4iOcUW52qvm7ygk1VcdSEke4Nvrn4GIm4RAlDEVd(P58(BR0pxbe9MnnQRwldUg)pyHwD1AMXrqfCHZTHQy2XSStsuxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYUFssac1GqlLj45RcMHs9RWaBZ4)5kGO3SPjaHAqOLYaUg)pyH2A1vRzcE(QGzzJUN1bicQ86n1HA)ZnNssSgHpNRQjtawiGarzqc3Pc9rBDaIGkVEdqDMZl09SwD1AMGNVkyw2jjwhGiOYR3GGQFVZ0pjjarqLxVPou7FU5eAe(CUQMmbyHaceLbjCNkGoaHAqOLYeGfciqu(3Pm2(M7XMLnARdqOgeAPmbpFvWSSr3RN6Q1muqF2ykRxLpMHs9RWXR8gjjQRwZqb9zJPmgQ9XmuQFfoEL3OpARNvrn4GImQU2RaLHTSR15F)ku4KKEQRwZO6AVcug2YUwN)9RqHZL)RHm43daPKctsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhasjRUF)(jjQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKOcXy0Td1(Nhk1VcV9MBKKGWNZv1Kbw5fMY)Cfq0R0g9rJWNZv1K5QmQai3nsZsCIjmlUwZc83PHfyXYctSCpLIzbwSea5U9WFWcdmLqYct57Pum3nsZsCKchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1H5U9WFWcdmLqYSQSh(dwz9HFfuEkPKdjfG)5cVskRGRPecFoxvtMdNDiXD7H)GfgykHKzvzp8hSY6d)kO8usjvO)ka)ZfELuwbxtPzvudoOiJQR9kqzyl7AD(3Vcf2qk26STjqUBp8hSWatjKmRk7H)GvwF4xbLNskHFUBUBKMfK76Ws7pHzXYo970WYVtSehhYtd(h2PHf1vRXILtRzP5AnlWwJfl3VFfl)oXsri7zj44N72d)blSXHKsi85CvnPGYtjLahYtZwoTo3CTodBnfGW1lsPEQRwZ8xkzbovgCipv9kqAmdL6xH3gva0K6idyByuojrD1AM)sjlWPYGd5PQxbsJzOu)k82E4pyzWVpTBidHmkSEk)xkbSnmkJUhf0NnMmxL1RYNKekOpBmzWqTp5Iq2NKqb9zJjJxDYfHSVFF0QRwZ8xkzbovgCipv9kqAmlB0ZQOgCqrM)sjlWPYGd5PQxbsd3nsZcYDDyP9NWSyzN(DAybW7dEnOiwomlwGZVZsWX)vOybIGgwa8(0UHy5kwu8v5dlwrqF2yI72d)blSXHeWucji85CvnPGYtjLoufCOm(9bVguKcq46fPK1uqF2yYCvgd1(GUh2M0687dk6Xg87t7gkEfI(DnvVbdx6mSL)Dk3GdHFdvUQMatsW2KwNFFqrp2GFFA3qXVv95UrAwItmXcYHfciqelw2PIf)zrtyml)UxSOWnyPl4TKfVazrFfXYYMfl3VZcY7csSQkWD7H)Gf24qcykHKaSqabIY)oLX23CpwbxtjRbN1bAkyoaIr3RhcFoxvtMaSqabIYGeUtfqBDac1GqlLj45RcMHCWojjQRwZe88vbZYUp6EQRwZqb9zJPSEv(ygk1VchpWnjrD1AgkOpBmLXqTpMHs9RWXdC7JUN1ZQOgCqrgvx7vGYWw2168VFfkCsI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqXh7Ke1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGIp29tsuHym62HA)ZdL6xH3w5nqBDac1GqlLj45RcMHCWo95UrAwItmXYwyOkMDyXY97SG8UGeRQcC3E4pyHnoKaMsizCeubx4CBOkMDuW1usD1AMGNVkygk1VchVYkK7gPzjoXelawv7gILRyX2lqk9cSalw8QZVFfkw(D)zrFiimlkBLykGzXlqw0egZIL73zjfoelVpOOhZIxGS4pl)oXcvGSaBS4SaaQ9HfRiOpBmXI)SOSvYcMcywGdlAcJzzOu)QRqXIJz5HSuWNLDhXvOy5HSmuBi8olGR5kuSO4RYhwSIG(SXe3Th(dwyJdjGPesWRQDdPGqNGMYVpOOhRKYk4Ak1BO2q4DxvtjjQRwZqb9zJPmgQ9XmuQFfE7yJMc6ZgtMRYyO2h0dL6xH3wzRe97AQEdgU0zyl)7uUbhc)gQCvnb2h97dk6n)Ls5hMbpkELTYUgBtAD(9bf9yGnuQFfgDpkOpBmzUk7vNKKHs9RWBJkaAsDK1N7gPzjoXelawv7gILhYYUJGyXzbLgQ6AwEillmXIvHuQ4i3Th(dwyJdjGPesWRQDdPGRPecFoxvtMtXaZbybE)bl0biudcTuMRWHz9UQMYk2YRFLMbjexGmd5GDqtk26STjqZv4WSExvtzfB51VsZGeIlqC3E4pyHnoKaMsib)(0CTwbxtjRFxt1BWpP1(KbNR9gQCvnbIUN6Q1m43NMR1MHAdH3DvnHUh2M0687dk6Xg87tZ16TJDsI1ZQOgCqrM)sjlWPYGd5PQxbst)KK31u9gmCPZWw(3PCdoe(nu5QAceT6Q1muqF2ykJHAFmdL6xH3o2OPG(SXK5QmgQ9bT6Q1m43NMR1MHs9RWBVvOX2KwNFFqrp2GFFAUwhVswzF09SEwf1GdkYO7e8XX5MMO)kuzu6l1gtjj)LsivKQvQW4vxTMb)(0CT2muQFfgyB2h97dk6n)Ls5hMbpkEfYDJ0SGuC)olaEsR9HL44CTNLfMybwSeazXYovSmuBi8URQjwuxpl4)0AwS43ZsdoSO4Dc(4ywShyGfVazbewk6zzHjwuPgCiwqECeBybWFAnllmXIk1GdXcYHfciqel4Rcel)U)Sy50AwShyGfVG)onSa49P5An3Th(dwyJdjGPesWVpnxRvW1u6DnvVb)Kw7tgCU2BOYv1eiA1vRzWVpnxRnd1gcV7QAcDpRNvrn4GIm6obFCCUPj6VcvgL(sTXusYFPesfPALkmERSp63hu0B(lLYpmdEu8XM7gPzbP4(DwIJd5PQxbsdllmXcG3NMR1S8qwaIiBww2S87elQRwJf1oS4AmKLf(kuSa49P5AnlWIffYcMcWceZcCyrtymldL6xDfkUBp8hSWghsatjKGFFAUwRGRP0SkQbhuK5VuYcCQm4qEQ6vG0GgBtAD(9bf9yd(9P5AD8kfB09SwD1AM)sjlWPYGd5PQxbsJzzJwD1Ag87tZ1AZqTHW7UQMss6HWNZv1KbCipnB506CZ16mS1q3tD1Ag87tZ1AZqP(v4TJDsc2M0687dk6Xg87tZ1643e97AQEd(jT2Nm4CT3qLRQjq0QRwZGFFAUwBgk1VcVTc73Vp3nsZcYDDyP9NWSyzN(DAyXzbW7dEnOiwwyIflNwZsWxyIfaVpnxRz5HS0CTMfyRPaw8cKLfMybW7dEnOiwEilarKnlXXH8u1RaPHf87bGyzzZD7H)Gf24qcykHee(CUQMuq5PKs43NMR1zlW6ZnxRZWwtbiC9IuYX)46Sn0cnXB1B019uEdGxD1AM)sjlWPYGd5PQxbsJb)EaO(DDp1vRzWVpnxRndL6xHb(yJuX2KwN3D8taV1VRP6n4N0AFYGZ1EdvUQMa7319cqOgeAPm43NMR1MHs9RWaFSrQyBsRZ7o(jG)DnvVb)Kw7tgCU2BOYv1ey)UUhi8nT10jdBzsVkYmuQFfg4vyF09uxTMb)(0CT2SStscqOgeAPm43NMR1MHs9RW95UrAwItmXcG3h8AqrSy5(DwIJd5PQxbsdlpKfGiYMLLnl)oXI6Q1yXY97W1ZIgIVcflaEFAUwZYY(VuIfVazzHjwa8(GxdkIfyXIvcmwIfSlXGf87bGWSSQ)0SyLS8(GIEm3Th(dwyJdjGPesWVp41GIuW1ucHpNRQjd4qEA2YP15MR1zyRHgHpNRQjd(9P5AD2cS(CZ16mS1qBncFoxvtMdvbhkJFFWRbfLK0tD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4JDsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXh7(OX2KwNFFqrp2GFFAUwVTvIgHpNRQjd(9P5AD2cS(CZ16mS14UrAwItmXc2IpPSGHS87(Zsh4Ifu0ZsQJmww2)LsSO2HLf(kuSCploMfT)eloMfBigFQAIfyXIMWyw(DVyj2SGFpaeMf4Wcsjl8ZILDQyj2aJf87bGWSqiZ(gI72d)blSXHeWucjoOB)hckJT4tQccDcAk)(GIESskRGRPK1)fa6kuOT2d)blJd62)HGYyl(KMb9uhfzUk30hQ9pjbe(gh0T)dbLXw8jnd6PokYGFpa02Xgni8noOB)hckJT4tAg0tDuKzOu)k82XM7gPzjoKAdH3zzlccR2nelxJfK3fKyvvGLdZYqoyhfWYVtdXIpelAcJz539IffYY7dk6XSCflk(Q8HfRiOpBmXIL73zba83ckGfnHXS87EXIYBWc83PXYHjwUIfV6WIve0NnMyboSSSz5HSOqwEFqrpMfvQbhIfNffFv(WIve0NnMmSehHLIEwgQneENfW1CfkwqkFf4qGSyfP2ql0Ks1ZYQ0egZYvSaaQ9HfRiOpBmXD7H)Gf24qcykHKuiSA3qki0jOP87dk6XkPScUMsd1gcV7QAc97dk6n)Ls5hMbpk(E9u2kbwpSnP153hu0Jn43N2neWVjWRUAndf0NnMY6v5Jzz3VpWgk1Vc3hP2tzG9UMQ38wUkNcHf2qLRQjW(O7fGqni0szcE(QGzihSdARbN1bAkyoaIr3dHpNRQjtawiGarzqc3PcjjbiudcTuMaSqabIY)oLX23Cp2mKd2jjX6aebvE9M6qT)5Mt9tsW2KwNFFqrp2GFFA3qB3RhWTR7PUAndf0NnMY6v5Jzzd8B2VpW3tzG9UMQ38wUkNcHf2qLRQjW(9rBnf0NnMmyO2NCri7ts6rb9zJjZvzmu7tsspkOpBmzUkRc)9KekOpBmzUkRxLp9rB97AQEdgU0zyl)7uUbhc)gQCvnbMKOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IIxPnv4g9r3dBtAD(9bf9yd(9PDdTTYBa89ugyVRP6nVLRYPqyHnu5QAcSFF0o(hxNTHwOjEfUrxRUAnd(9P5ATzOu)kmWdC7JUN1QRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKqb9zJjZvzmu7tsI1bicQ86na1zoV6J2A1vRzghbvWfo3gQIzNm(Q2sN37GFAo3SS5UrAwItmXYwagxwGflbqwSC)oC9SeCB7RqXD7H)Gf24qcykHKgCcug2YL)RHuW1uYTZHDkae3Th(dwyJdjGPesq4Z5QAsbLNskfaZbybE)bRSdjfGW1lsjRbN1bAkyoaIrJWNZv1KjaMdWc8(dwO71tD1Ag87tZ1AZYoj5DnvVb)Kw7tgCU2BOYv1eyssaIGkVEtDO2)CZP(O7zT6Q1myOg)xGmlB0wRUAntWZxfmlB09S(DnvVPTMozylt6vrgQCvnbMKOUAntWZxfmGRX)dwXhGqni0szARPtg2YKEvKzOu)kmWS6(Or4Z5QAY87ZP1zmrart2IFp6EwhGiOYR3uhQ9p3CkjjaHAqOLYeGfciqu(3Pm2(M7XMLn6EQRwZGFFAUwBgk1VcV9Mjjw)UMQ3GFsR9jdox7nu5QAcSFF0VpOO38xkLFyg8O4vxTMj45RcgW14)blGFdZw1pjrfIXOBhQ9ppuQFfEB1vRzcE(QGbCn(FWQp3nsZsCIjwqExqIvvbwGflbqwwLMWyw8cKf9vel3ZYYMfl3VZcYHfciqe3Th(dwyJdjGPescKMW)56SRpuvkvVcUMsi85CvnzcG5aSaV)Gv2He3Th(dwyJdjGPesUk4t5)blfCnLq4Z5QAYeaZbybE)bRSdjUBKML4etSyfP2ql0WsSGfilWILailwUFNfaVpnxRzzzZIxGSGDeeln4WYwU0yFyXlqwqExqIvvbUBp8hSWghsatjKqP2ql0KvHfOcUMsx90yd1(tG52HA)ZdL6xH3wzfMK0tD1Ag75sHd456SpbVUq2EPX(yq46fT9MkCJKe1vRzSNlfoGNRZ(e86cz7Lg7JbHRxu8kTPc3OpA1vRzWVpnxRnlB09cqOgeAPmbpFvWmuQFfoEfUrsc4SoqtbZbqCFUBKML4qQneENLM2hIfyXYYMLhYsSz59bf9ywSC)oC9SG8UGeRQcSOsxHIfxfUEwEileYSVHyXlqwk4Zcebnb32(kuC3E4pyHnoKaMsib)Kw7tUP9HuqOtqt53hu0JvszfCnLgQneE3v1e6)sP8dZGhfVYken2M0687dk6Xg87t7gABReTBNd7uai09uxTMj45RcMHs9RWXR8gjjwRUAntWZxfml7(C3inlXjMyzlaTcwUglxHpqIfVyXkc6ZgtS4fil6RiwUNLLnlwUFNfNLTCPX(WI9adS4filDb0T)dbXcal(KYD7H)Gf24qcykHK2A6KHTmPxfPGRPef0NnMmxL9QdA3oh2PaqOvxTMXEUu4aEUo7tWRlKTxASpgeUErBVPc3aDpq4BCq3(peugBXN0mON6OiZFbGUcvsI1bicQ86nffgOgoGjjyBsRZVpOOhh)M9r3tD1AMXrqfCHZTHQy2XmuQFfE7TUR7PqGFwf1GdkYGVQT059o4NMZ7JwD1AMXrqfCHZTHQy2XSStsSwD1AMXrqfCHZTHQy2XSS7JUN1biudcTuMGNVkyw2jjQRwZ87ZP1zmrarJb)EaOTvwHOBhQ9ppuQFfE7n3yd0Td1(Nhk1VchVYBSrsI1y4sREfO53NtRZyIaIgdvUQMa7JUhgU0QxbA(9506mMiGOXqLRQjWKKaeQbHwktWZxfmdL6xHJp2B0N7gPzjoXelolaEFAUwZYwCr)ol2dmWYQ0egZcG3NMR1SCywC9qoyhww2Sahw6axS4dXIRcxplpKficAcUnlDbVLC3E4pyHnoKaMsib)(0CTwbxtj1vRzGf974SnnbY(pyzw2O7PUAnd(9P5ATzO2q4Dxvtjjo(hxNTHwOj(TEJ(C3inlXXvQnlDbVLSOsn4qSGCyHaceXIL73zbW7tZ1Aw8cKLFNkwa8(GxdkI72d)blSXHeWucj43NMR1k4AkfGiOYR3uhQ9p3CcT1VRP6n4N0AFYGZ1EdvUQMar3dHpNRQjtawiGarzqc3PcjjbiudcTuMGNVkyw2jjQRwZe88vbZYUp6aeQbHwktawiGar5FNYy7BUhBgk1VcVnQaOj1rgWhOt3ZX)46Sn0cnivfUrF0QRwZGFFAUwBgk1VcVTvI2AWzDGMcMdGyUBp8hSWghsatjKGFFWRbfPGRPuaIGkVEtDO2)CZj09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMLDsI6Q1mbpFvWSS7JoaHAqOLYeGfciqu(3Pm2(M7XMHs9RWBdCrRUAnd(9P5ATzzJMc6ZgtMRYE1bT1i85CvnzoufCOm(9bVgueARbN1bAkyoaI5UrAwItmXcG3h8AqrSy5(Dw8ILT4I(DwShyGf4WY1yPdCPiqwGiOj42S0f8wYIL73zPdCnSueYEwco(nS0fngYc4k1MLUG3sw8NLFNyHkqwGnw(DIL4au97DgwuxTglxJfaVpnxRzXcCPblf9S0CTMfyRXcCyPdCXIpelWILnz59bf9yUBp8hSWghsatjKGFFWRbfPGRPK6Q1mWI(DCoOjFYio8blZYojPN143N2nKXTZHDkaeARr4Z5QAYCOk4qz87dEnOOKKEQRwZe88vbZqP(v4TviA1vRzcE(QGzzNK0RN6Q1mbpFvWmuQFfEBubqtQJmGpqNUNJ)X1zBOfAqQXEJ(OvxTMj45RcMLDsI6Q1mJJGk4cNBdvXStgFvBPZ7DWpnNBgk1VcVnQaOj1rgWhOt3ZX)46Sn0cni1yVrF0QRwZmocQGlCUnufZoz8vTLoV3b)0CUzz3hDaIGkVEdcQ(9ot)(O7HTjTo)(GIESb)(0CTE7yNKGWNZv1Kb)(0CToBbwFU5ADg2A97J2Ae(CUQMmhQcoug)(GxdkcDpRNvrn4GIm)LswGtLbhYtvVcKMKeSnP153hu0Jn43NMR1Bh7(C3inlXjMyzlcclmlxXcaO2hwSIG(SXelEbYc2rqSSfwAnlBrqyXsdoSG8UGeRQcC3E4pyHnoKaMsiPil5uiSuW1uQN6Q1muqF2ykJHAFmdL6xHJNqgfwpL)lLss6f29bfHvAt0df29bfL)lL2wH9tsc7(GIWkf7(OD7CyNcaXD7H)Gf24qcykHKDx3YPqyPGRPup1vRzOG(SXugd1(ygk1VchpHmkSEk)xkLK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvk29r725WofacDp1vRzghbvWfo3gQIzhZqP(v4TviA1vRzghbvWfo3gQIzhZYgT1ZQOgCqrg8vTLoV3b)0CEsI1QRwZmocQGlCUnufZoMLDFUBp8hSWghsatjK0wADofclfCnL6PUAndf0NnMYyO2hZqP(v44jKrH1t5)sj09cqOgeAPmbpFvWmuQFfoEfUrssac1GqlLjaleqGO8VtzS9n3JndL6xHJxHB0pjPxy3huewPnrpuy3huu(VuABf2pjjS7dkcRuS7J2TZHDkae6EQRwZmocQGlCUnufZoMHs9RWBRq0QRwZmocQGlCUnufZoMLnARNvrn4GIm4RAlDEVd(P58KeRvxTMzCeubx4CBOkMDml7(C3inlXjMybPaAfSalwqECK72d)blSXHeWucjw8zo4KHTmPxfXDJ0SGCxhwA)jmlw2PFNgwEillmXcG3N2nelxXcaO2hwSSFHDwoml(ZIcz59bf9yGPmln4WcHGMoSS5givwsD8tthwGdlwjlaEFWRbfXIvKAdTqtkvpl43daH5U9WFWcBCibmLqccFoxvtkO8usj87t7gkFvgd1(OaeUErkHTjTo)(GIESb)(0UHI3kbwtdHtVuh)00jJW1lc4vEJnqQBUrFG10q40tD1Ag87dEnOOmLAdTqtkvFgd1(yWVhacPAL95UrAwqURdlT)eMfl70VtdlpKfKIX)DwaxZvOyzlmufZoC3E4pyHnoKaMsibHpNRQjfuEkPKLX)98v52qvm7OaeUErkPmsfBtADE3XpT9MDDVnmBc89W2KwNFFqrp2GFFA3qDTY9b(EkdS31u9gmCPZWw(3PCdoe(nu5QAce4v2OW(9b2ggLviWRUAnZ4iOcUW52qvm7ygk1VcZDJ0SeNyIfKIX)DwUIfaqTpSyfb9zJjwGdlxJLcYcG3N2nelwoTML29SC1dzb5DbjwvfyXRoPWH4U9WFWcBCibmLqILX)DfCnL6rb9zJjJEv(KlczFscf0NnMmE1jxeYE0i85CvnzoCoOjhb1hDV3hu0B(lLYpmdEu8wzscf0NnMm6v5t(Q8MjjTd1(Nhk1VcVTYB0pjrD1AgkOpBmLXqTpMHs9RWB7H)GLb)(0UHmeYOW6P8FPeA1vRzOG(SXugd1(yw2jjuqF2yYCvgd1(G2Ae(CUQMm43N2nu(QmgQ9jjrD1AMGNVkygk1VcVTh(dwg87t7gYqiJcRNY)LsOTgHpNRQjZHZbn5ii0QRwZe88vbZqP(v4TjKrH1t5)sj0QRwZe88vbZYojrD1AMXrqfCHZTHQy2XSSrJWNZv1KXY4)E(QCBOkMDssSgHpNRQjZHZbn5ii0QRwZe88vbZqP(v44jKrH1t5)sjUBKML4etSa49PDdXY1y5kwu8v5dlwrqF2ysbSCflaGAFyXkc6ZgtSalwSsGXY7dk6XSahwEil2dmWcaO2hwSIG(SXe3Th(dwyJdjGPesWVpTBiUBKMLTGR1)(S4U9WFWcBCibmLqYSQSh(dwz9HFfuEkPuZ16FFwC3C3inlBHHQy2Hfl3VZcY7csSQkWD7H)Gf2Oc9xPXrqfCHZTHQy2rbxtj1vRzcE(QGzOu)kC8kRqUBKML4etS0fq3(peelaS4tklw2PIf)zrtyml)UxSyLSelyxIbl43daHzXlqwEild1gcVZIZY2kTjl43daXIJzr7pXIJzXgIXNQMyboS8xkXY9SGHSCpl(mhccZcsjl8ZI3EAyXzj2aJf87bGyHqM9neM72d)blSrf6pWucjoOB)hckJT4tQccDcAk)(GIESskRGRPK6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqBB1OvxTMr11EfOmSLDTo)7xHcN9j4fzWVhaABRgDpRbHVXbD7)qqzSfFsZGEQJIm)fa6kuOT2d)blJd62)HGYyl(KMb9uhfzUk30hQ9hDpRbHVXbD7)qqzSfFsZ7KRn)fa6kujjGW34GU9FiOm2IpP5DY1MHs9RWXh7(jjGW34GU9FiOm2IpPzqp1rrg87bG2o2ObHVXbD7)qqzSfFsZGEQJImdL6xH3wHObHVXbD7)qqzSfFsZGEQJIm)fa6ku95UrAwItmXcYHfciqelwUFNfK3fKyvvGfl7uXIneJpvnXIxGSa)DASCyIfl3VZIZsSGDjgSOUAnwSStflGeUtfUcf3Th(dwyJk0FGPescWcbeik)7ugBFZ9yfCnLSgCwhOPG5aigDVEi85CvnzcWcbeikds4ovaT1biudcTuMGNVkygYb7KKOUAntWZxfml7(O7PUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaKswDsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqkz19tsuHym62HA)ZdL6xH3w5n6ZDJ0SSfGwbloMLFNyPDd(zbvaKLRy53jwCwIfSlXGflxbcTWcCyXY97S87eliL7mNxSOUAnwGdlwUFNfNfRgyykWsxaD7)qqSaWIpPS4filw87zPbhwqExqIvvbwUgl3ZIfy9SOsSSSzXr5xXIk1GdXYVtSeaz5WS0U6W7ei3Th(dwyJk0FGPesARPtg2YKEvKcUMs961tD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4bUjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43dafpWTp6EwhGiOYR3GGQFVZKKyT6Q1mJJGk4cNBdvXSJzz3Vp6EGZ6anfmhaXjjbiudcTuMGNVkygk1VchVc3ijPxaIGkVEtDO2)CZj0biudcTuMaSqabIY)oLX23Cp2muQFfoEfUr)(9ts6bcFJd62)HGYyl(KMb9uhfzgk1VchVvJoaHAqOLYe88vbZqP(v44vEd0bicQ86nffgOgoG9tsU6PXgQ9NaZTd1(Nhk1VcVTvJ26aeQbHwktWZxfmd5GDsscqeu51BaQZCEHwD1AgGUcCiWmLAdTqtkvVzzNKeGiOYR3GGQFVZGwD1AMXrqfCHZTHQy2XmuQFfE7TgT6Q1mJJGk4cNBdvXSJzzZDJ0SGCVcKMfaVpA4aYIL73zXzPilSelyxIblQRwJfVazb5Dbjwvfy5WLIEwCv46z5HSOsSSWei3Th(dwyJk0FGPescEfiDwD1AkO8usj87JgoGk4Ak1tD1Agvx7vGYWw2168VFfkCU8FnKzOu)kC8BLrHjjQRwZO6AVcug2YUwN)9RqHZ(e8ImdL6xHJFRmkSp6EbiudcTuMGNVkygk1Vch)wLK0laHAqOLYqP2ql0KvHfOzOu)kC8BfARvxTMbORahcmtP2ql0Ks1NPIguxmjZYgDaIGkVEdqDMZR(9r74FCD2gAHM4vk2BWDJ0SehxP2Sa49bVgueMfl3VZIZsSGDjgSOUAnwuxplf8zXYovSydH6RqXsdoSG8UGeRQcSahwqkFf4qGSaW(M7XC3E4pyHnQq)bMsib)(GxdksbxtPEQRwZO6AVcug2YUwN)9RqHZL)RHm43daf)MjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43daf)M9r3larqLxVPou7FU5ussac1GqlLj45RcMHs9RWXVvjjwJWNZv1KjaMdWc8(dwOToarqLxVbOoZ5vssVaeQbHwkdLAdTqtwfwGMHs9RWXVvOTwD1AgGUcCiWmLAdTqtkvFMkAqDXKmlB0bicQ86na1zoV63hDpRbHVPTMozylt6vrM)caDfQKeRdqOgeAPmbpFvWmKd2jjX6aeQbHwktawiGar5FNYy7BUhBgYb70N7gPzjoUsTzbW7dEnOimlQudoelihwiGarC3E4pyHnQq)bMsib)(GxdksbxtPEbiudcTuMaSqabIY)oLX23Cp2muQFfEBfI2AWzDGMcMdGy09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMHs9RWBRW(Or4Z5QAYeaZbybE)bR(OTge(M2A6KHTmPxfz(la0vOqhGiOYR3uhQ9p3CcT1GZ6anfmhaXOPG(SXK5QSxDq74FCD2gAHM4TYn4UrAwIJWsrplGWNfW1Cfkw(DIfQazb2yjo0rqfCHzzlmufZokGfW1Cfkwa6kWHazHsTHwOjLQNf4WYvS87elAh)SGkaYcSXIxSyfb9zJjUBp8hSWgvO)atjKGWNZv1KckpLuce(5HuS1nukvpwbiC9IuQN6Q1mJJGk4cNBdvXSJzOu)kC8kmjXA1vRzghbvWfo3gQIzhZYUp6EQRwZa0vGdbMPuBOfAsP6ZurdQlMKzOu)k82OcGMuhz9r3tD1AgkOpBmLXqTpMHs9RWXJkaAsDKLKOUAndf0NnMY6v5JzOu)kC8OcGMuhz95U9WFWcBuH(dmLqcEvTBife6e0u(9bf9yLuwbxtPHAdH3DvnH(9bf9M)sP8dZGhfVYax0UDoStbGqJWNZv1Kbe(5HuS1nukvpM72d)blSrf6pWucjPqy1UHuqOtqt53hu0JvszfCnLgQneE3v1e63hu0B(lLYpmdEu8khBJcr725WofacncFoxvtgq4NhsXw3qPu9yUBp8hSWgvO)atjKGFsR9j30(qki0jOP87dk6XkPScUMsd1gcV7QAc97dk6n)Ls5hMbpkELbUaBOu)kmA3oh2PaqOr4Z5QAYac)8qk26gkLQhZDJ0SSfGXLfyXsaKfl3Vdxplb32(kuC3E4pyHnQq)bMsiPbNaLHTC5)AifCnLC7CyNcaXDJ0SyfP2ql0WsSGfilw2PIfxfUEwEilu90WIZsrwyjwWUedwSCfi0clEbYc2rqS0GdliVliXQQa3Th(dwyJk0FGPesOuBOfAYQWcubxtPEuqF2yYOxLp5Iq2NKqb9zJjdgQ9jxeY(KekOpBmz8QtUiK9jjQRwZO6AVcug2YUwN)9RqHZL)RHmdL6xHJFRmkmjrD1Agvx7vGYWw2168VFfkC2NGxKzOu)kC8BLrHjjo(hxNTHwOj(TEd0biudcTuMGNVkygYb7G2AWzDGMcMdG4(O7fGqni0szcE(QGzOu)kC8XEJKKaeQbHwktWZxfmd5GD6NKC1tJnu7pbMBhQ9ppuQFfEBL3G7gPzzlaTcwMd1(ZIk1GdXYcFfkwqEx4U9WFWcBuH(dmLqsBnDYWwM0RIuW1ukaHAqOLYe88vbZqoyh0i85CvnzcG5aSaV)Gf6Eo(hxNTHwOj(TEd0whGiOYR3uhQ9p3CkjjarqLxVPou7FU5eAh)JRZ2ql0STvUrF0whGiOYR3GGQFVZGUN1bicQ86n1HA)ZnNsscqOgeAPmbyHaceL)DkJTV5ESzihStF0wdoRd0uWCaeZDJ0SG8UGeRQcSyzNkw8NLTEdGXsxWBjl9GJgAHgw(DVyXk3GLUG3swSC)olihwiGar9zXY97W1ZIgIVcfl)LsSCflXsdHG6f(zXlqw0xrSSSzXY97SGCyHaceXY1y5EwS4ywajCNkqGC3E4pyHnQq)bMsibHpNRQjfuEkPuamhGf49hSYQq)vacxViLSgCwhOPG5aigncFoxvtMayoalW7pyHUxph)JRZ2ql0e)wVb6EQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKyDaIGkVEdqDMZR(jjQRwZOQHqq9c)MLnA1vRzu1qiOEHFZqP(v4TvxTMj45RcgW14)bR(jjx90yd1(tG52HA)ZdL6xH3wD1AMGNVkyaxJ)hSsscqeu51BQd1(NBo1hDpRdqeu51BQd1(NBoLK0ZX)46Sn0cnBBLBKKacFtBnDYWwM0RIm)fa6ku9r3dHpNRQjtawiGarzqc3PcjjbiudcTuMaSqabIY)oLX23Cp2mKd2PFFUBp8hSWgvO)atjKeinH)Z1zxFOQuQEfCnLq4Z5QAYeaZbybE)bRSk0FUBp8hSWgvO)atjKCvWNY)dwk4AkHWNZv1KjaMdWc8(dwzvO)C3inlwb(Vu)jml7qlSKUc7S0f8wYIpelO8RiqwSPHfmfGfi3Th(dwyJk0FGPesq4Z5QAsbLNsk5y7TKgauqbiC9IuIc6ZgtMRY6v5dWB1ivp8hSm43N2nKHqgfwpL)lLaM1uqF2yYCvwVkFa(EaxG9UMQ3GHlDg2Y)oLBWHWVHkxvtGaFS7Ju9WFWYyz8F3qiJcRNY)LsaBdZMivSnP15Dh)e3nsZsCCLAZcG3h8AqrywSStfl)oXs7qT)SCywCv46z5HSqfOcyPnufZoSCywCv46z5HSqfOcyPdCXIpel(ZYwVbWyPl4TKLRyXlwSIG(SXKcyb5Dbjwvfyr74hZIxWFNgwSAGHPaMf4Wsh4IflWLgKficAcUnlPWHy539Ifor5nyPl4TKfl7uXsh4IflWLgSu0ZcG3h8AqrSuqlC3E4pyHnQq)bMsib)(GxdksbxtPEx90yd1(tG52HA)ZdL6xH32kts6PUAnZ4iOcUW52qvm7ygk1VcVnQaOj1rgWhOt3ZX)46Sn0cni1yVrF0QRwZmocQGlCUnufZoMLD)(jj9C8pUoBdTqdWq4Z5QAY4y7TKgaua4vxTMHc6Zgtzmu7JzOu)kmWaHVPTMozylt6vrM)caHZdL6xb8BAuy8kR8gjjo(hxNTHwObyi85CvnzCS9wsdaka8QRwZqb9zJPSEv(ygk1Vcdmq4BARPtg2YKEvK5Vaq48qP(va)MgfgVYkVrF0uqF2yYCv2RoO7zT6Q1mbpFvWSStsS(DnvVb)(OHdOHkxvtG9r3RN1biudcTuMGNVkyw2jjbicQ86na1zoVqBDac1GqlLHsTHwOjRclqZYUFssaIGkVEtDO2)CZP(O7zDaIGkVEdcQ(9otsI1QRwZe88vbZYojXX)46Sn0cnXV1B0pjP37AQEd(9rdhqdvUQMarRUAntWZxfmlB09uxTMb)(OHdOb)EaOTJDsIJ)X1zBOfAIFR3OF)Ke1vRzcE(QGzzJ2A1vRzghbvWfo3gQIzhZYgT1VRP6n43hnCanu5QAcK7gPzjoXelBrqyHz5kwu8v5dlwrqF2yIfVazb7iiwId21nGTfwAnlBrqyXsdoSG8UGeRQcC3E4pyHnQq)bMsiPil5uiSuW1uQN6Q1muqF2ykRxLpMHs9RWXtiJcRNY)Lsjj9c7(GIWkTj6Hc7(GIY)LsBRW(jjHDFqryLIDF0UDoStbG4U9WFWcBuH(dmLqYURB5uiSuW1uQN6Q1muqF2ykRxLpMHs9RWXtiJcRNY)LsO7fGqni0szcE(QGzOu)kC8kCJKKaeQbHwktawiGar5FNYy7BUhBgk1VchVc3OFssVWUpOiSsBIEOWUpOO8FP02kSFssy3huewPy3hTBNd7uaiUBp8hSWgvO)atjK0wADofclfCnL6PUAndf0NnMY6v5JzOu)kC8eYOW6P8FPe6EbiudcTuMGNVkygk1VchVc3ijjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWXRWn6NK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvk29r725WofaI7gPzbPaAfSalwcGC3E4pyHnQq)bMsiXIpZbNmSLj9QiUBKML4etSa49PDdXYdzXEGbwaa1(WIve0NnMyboSyzNkwUIfyP7WIIVkFyXkc6ZgtS4fillmXcsb0kyXEGbmlxJLRyrXxLpSyfb9zJjUBp8hSWgvO)atjKGFFA3qk4Akrb9zJjZvz9Q8jjHc6Zgtgmu7tUiK9jjuqF2yY4vNCri7tsuxTMXIpZbNmSLj9QiZYgT6Q1muqF2ykRxLpMLDssp1vRzcE(QGzOu)k82E4pyzSm(VBiKrH1t5)sj0QRwZe88vbZYUp3Th(dwyJk0FGPesSm(VZD7H)Gf2Oc9hykHKzvzp8hSY6d)kO8usPMR1)(S4U5UrAwa8(GxdkILgCyjfIGsP6zzvAcJzzHVcflXc2LyWD7H)Gf20CT(3NLs43h8Aqrk4Akz9SkQbhuKr11EfOmSLDTo)7xHcBifBD22ei3nsZcYD8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDKXc4A8)GflhML97nSayvTBiwgk1VcZs6s)NT(iqwEilP(h2zjfcR2nelGRX)dwC3E4pyHnnxR)9zbmLqcEvTBife6e0u(9bf9yLuwbxtjq4BsHWQDdzgk1Vch)qP(vyGFZnrQkB1C3E4pyHnnxR)9zbmLqskewTBiUBUBKML4etSa49bVguelpKfGiYMLLnl)oXsCCipv9kqAyrD1ASCnwUNflWLgKfcz23qSOsn4qS0U6W7xHILFNyPiK9SeC8ZcCy5HSaUsTzrLAWHyb5WcbeiI72d)blSb)kHFFWRbfPGRP0SkQbhuK5VuYcCQm4qEQ6vG0GUhf0NnMmxL9QdAR71tD1AM)sjlWPYGd5PQxbsJzOu)kC8E4pyzSm(VBiKrH1t5)sjGTHrz09OG(SXK5QSk83tsOG(SXK5QmgQ9jjHc6Zgtg9Q8jxeY((jjQRwZ8xkzbovgCipv9kqAmdL6xHJ3d)bld(9PDdziKrH1t5)sjGTHrz09OG(SXK5QSEv(KKqb9zJjdgQ9jxeY(KekOpBmz8QtUiK997NKyT6Q1m)LswGtLbhYtvVcKgZYUFssp1vRzcE(QGzzNKGWNZv1KjaleqGOmiH7uH(OdqOgeAPmbyHaceL)DkJTV5ESzihSd6aebvE9M6qT)5Mt9r3Z6aebvE9gG6mNxjjbiudcTugk1gAHMSkSandL6xHJ3Q7JUN6Q1mbpFvWSStsSoaHAqOLYe88vbZqoyN(C3inlXjMyPlGU9FiiwayXNuwSStfl)onelhMLcYIh(dbXc2IpPkGfhZI2FIfhZIneJpvnXcSybBXNuwSC)olBYcCyPrwOHf87bGWSahwGflolXgySGT4tklyil)U)S87elfzHfSfFszXN5qqywqkzHFw82tdl)U)SGT4tkleYSVHWC3E4pyHn4hykHeh0T)dbLXw8jvbHobnLFFqrpwjLvW1uYAq4BCq3(peugBXN0mON6OiZFbGUcfAR9WFWY4GU9FiOm2IpPzqp1rrMRYn9HA)r3ZAq4BCq3(peugBXN08o5AZFbGUcvsci8noOB)hckJT4tAENCTzOu)kC8kSFsci8noOB)hckJT4tAg0tDuKb)EaOTJnAq4BCq3(peugBXN0mON6OiZqP(v4TJnAq4BCq3(peugBXN0mON6OiZFbGUcf3nsZsCIjmlihwiGarSCnwqExqIvvbwomllBwGdlDGlw8HybKWDQWvOyb5DbjwvfyXY97SGCyHaceXIxGS0bUyXhIfvsdTWIvUblDbVLC3E4pyHn4hykHKaSqabIY)oLX23CpwbxtjRbN1bAkyoaIr3RhcFoxvtMaSqabIYGeUtfqBDac1GqlLj45RcMHCWoOTEwf1GdkYypxkCapxN9j41fY2ln2NKe1vRzcE(QGzz3hTJ)X1zBOfA2wjRCd09uxTMHc6Zgtz9Q8XmuQFfoEL3ijrD1AgkOpBmLXqTpMHs9RWXR8g9tsuHym62HA)ZdL6xH3w5nqBDac1GqlLj45RcMHCWo95UrAwqoSaV)Gfln4WIR1SacFml)U)SK6arywWRHy53PoS4dvk6zzO2q4DcKfl7uXsCOJGk4cZYwyOkMDyz3XSOjmMLF3lwuilykGzzOu)QRqXcCy53jwaQZCEXI6Q1y5WS4QW1ZYdzP5AnlWwJf4WIxDyXkc6ZgtSCywCv46z5HSqiZ(gI72d)blSb)atjKGWNZv1KckpLuce(5HuS1nukvpwbiC9IuQN6Q1mJJGk4cNBdvXSJzOu)kC8kmjXA1vRzghbvWfo3gQIzhZYUpARvxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYgDp1vRza6kWHaZuQn0cnPu9zQOb1ftYmuQFfEBubqtQJS(O7PUAndf0NnMYyO2hZqP(v44rfanPoYssuxTMHc6Zgtz9Q8XmuQFfoEubqtQJSKKEwRUAndf0NnMY6v5JzzNKyT6Q1muqF2ykJHAFml7(OT(DnvVbd14)cKHkxvtG95UrAwqoSaV)Gfl)U)Se2PaqywUglDGlw8HybUE8bsSqb9zJjwEilWs3Hfq4ZYVtdXcCy5qvWHy53pmlwUFNfaqn(VaXD7H)Gf2GFGPesq4Z5QAsbLNskbc)mC94dKYuqF2ysbiC9IuQN1QRwZqb9zJPmgQ9XSSrBT6Q1muqF2ykRxLpMLD)KK31u9gmuJ)lqgQCvnbYD7H)Gf2GFGPessHWQDdPGqNGMYVpOOhRKYk4AknuBi8URQj09uxTMHc6Zgtzmu7JzOu)kC8dL6xHtsuxTMHc6Zgtz9Q8XmuQFfo(Hs9RWjji85CvnzaHFgUE8bszkOpBm1h9qTHW7UQMq)(GIEZFPu(HzWJIx5nr725WofacncFoxvtgq4NhsXw3qPu9yUBp8hSWg8dmLqcEvTBife6e0u(9bf9yLuwbxtPHAdH3DvnHUN6Q1muqF2ykJHAFmdL6xHJFOu)kCsI6Q1muqF2ykRxLpMHs9RWXpuQFfojbHpNRQjdi8ZW1Jpqktb9zJP(OhQneE3v1e63hu0B(lLYpmdEu8kVjA3oh2PaqOr4Z5QAYac)8qk26gkLQhZD7H)Gf2GFGPesWpP1(KBAFife6e0u(9bf9yLuwbxtPHAdH3DvnHUN6Q1muqF2ykJHAFmdL6xHJFOu)kCsI6Q1muqF2ykRxLpMHs9RWXpuQFfojbHpNRQjdi8ZW1Jpqktb9zJP(OhQneE3v1e63hu0B(lLYpmdEu8kdCr725WofacncFoxvtgq4NhsXw3qPu9yUBKML4etSSfGXLfyXsaKfl3Vdxplb32(kuC3E4pyHn4hykHKgCcug2YL)RHuW1uYTZHDkae3nsZsCIjwqkFf4qGSaW(M7XSy5(Dw8QdlAyHIfQGlu7SOD8FfkwSIG(SXelEbYYpDy5HSOVIy5Eww2Sy5(Dw2YLg7dlEbYcY7csSQkWD7H)Gf2GFGPesOuBOfAYQWcubxtPE9uxTMHc6Zgtzmu7JzOu)kC8kVrsI6Q1muqF2ykRxLpMHs9RWXR8g9rhGqni0szcE(QGzOu)kC8XEd09uxTMXEUu4aEUo7tWRlKTxASpgeUErBVPvUrsI1ZQOgCqrg75sHd456SpbVUq2EPX(yifBD22ey)(jjQRwZypxkCapxN9j41fY2ln2hdcxVO4vAZTAJKKaeQbHwktWZxfmd5GDq74FCD2gAHM436n4UrAwItmXcY7csSQkWIL73zb5WcbeicjiLVcCiqwayFZ9yw8cKfqyPONficASm3tSSLln2hwGdlw2PILyPHqq9c)SybU0GSqiZ(gIfvQbhIfK3fKyvvGfcz23qyUBp8hSWg8dmLqccFoxvtkO8usPayoalW7pyLXVcq46fPK1GZ6anfmhaXOr4Z5QAYeaZbybE)bl096fGqni0szOu7od56mCalVcKzOu)k82kdC3kG1tzLb(zvudoOid(Q2sN37GFAoVpAsXwNTnbAOu7od56mCalVcu)Keh)JRZ2ql0eVsB9gO7z97AQEtBnDYWwM0RImu5QAcmjrD1AMGNVkyaxJ)hSIpaHAqOLY0wtNmSLj9QiZqP(vyGz19rdcFdEvTBiZqP(v44vEt0GW3KcHv7gYmuQFfoERgDpq4BWpP1(KBAFiZqP(v44T6KeRFxt1BWpP1(KBAFidvUQMa7JgHpNRQjZVpNwNXebenzl(9O7PUAndqxboeyMsTHwOjLQptfnOUysMLDsI1bicQ86na1zoV6J(9bf9M)sP8dZGhfV6Q1mbpFvWaUg)pyb8By2QKevigJUDO2)8qP(v4TvxTMj45RcgW14)bRKKaebvE9M6qT)5MtjjQRwZOQHqq9c)MLnA1vRzu1qiOEHFZqP(v4TvxTMj45RcgW14)blG1BRb(zvudoOiJ9CPWb8CD2NGxxiBV0yFmKIToBBcSFF0wRUAntWZxfmlB09SoarqLxVPou7FU5ussac1GqlLjaleqGO8VtzS9n3Jnl7KevigJUDO2)8qP(v4TdqOgeAPmbyHaceL)DkJTV5ESzOu)kmWaUjjTd1(Nhk1VcJurQkB1BST6Q1mbpFvWaUg)py1N72d)blSb)atjKGWNZv1KckpLukaMdWc8(dwz8RaeUErkzn4SoqtbZbqmAe(CUQMmbWCawG3FWcDVEbiudcTugk1UZqUodhWYRazgk1VcVTYa3Tcy9uwzGFwf1GdkYGVQT059o4NMZ7JMuS1zBtGgk1UZqUodhWYRa1pjXX)46Sn0cnXR0wVb6Ew)UMQ30wtNmSLj9QidvUQMatsuxTMj45RcgW14)bR4dqOgeAPmT10jdBzsVkYmuQFfgywDF0GW3Gxv7gYmuQFfoERgni8nPqy1UHmdL6xHJFRr3de(g8tATp5M2hYmuQFfoEL3ijX631u9g8tATp5M2hYqLRQjW(Or4Z5QAY87ZP1zmrart2IFp6EQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKyDaIGkVEdqDMZR(OFFqrV5Vuk)Wm4rXRUAntWZxfmGRX)dwa)gMTkjrfIXOBhQ9ppuQFfEB1vRzcE(QGbCn(FWkjjarqLxVPou7FU5usI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWcy92AGFwf1GdkYypxkCapxN9j41fY2ln2hdPyRZ2Ma73hT1QRwZe88vbZYgDpRdqeu51BQd1(NBoLKeGqni0szcWcbeik)7ugBFZ9yZYojrfIXOBhQ9ppuQFfE7aeQbHwktawiGar5FNYy7BUhBgk1VcdmGBsIkeJr3ou7FEOu)kmsfPQSvVX2QRwZe88vbd4A8)GvFUBKML4etS87elXbO637mSy5(DwCwqExqIvvbw(D)z5WLIEwAdmLLTCPX(WD7H)Gf2GFGPesghbvWfo3gQIzhfCnLuxTMj45RcMHs9RWXRSctsuxTMj45RcgW14)bRTJ9MOr4Z5QAYeaZbybE)bRm(5U9WFWcBWpWucjbst4)CD21hQkLQxbxtje(CUQMmbWCawG3FWkJF09uxTMj45RcgW14)bR4vk2BMKyDaIGkVEdcQ(9ot)Ke1vRzghbvWfo3gQIzhZYgT6Q1mJJGk4cNBdvXSJzOu)k82BnWcWcCDVXEOWHPSRpuvkvV5VukJW1lcy9SwD1AgvnecQx43SSrB97AQEd(9rdhqdvUQMa7ZD7H)Gf2GFGPesUk4t5)blfCnLq4Z5QAYeaZbybE)bRm(5UrAwId4Z5QAILfMazbwS4QN((JWS87(ZIfVEwEilQelyhbbYsdoSG8UGeRQcSGHS87(ZYVtDyXhQEwS44NazbPKf(zrLAWHy53PuUBp8hSWg8dmLqccFoxvtkO8usjSJGYn4KdE(QGcq46fPK1biudcTuMGNVkygYb7KKyncFoxvtMaSqabIYGeUtfqhGiOYR3uhQ9p3CkjbCwhOPG5aiM7gPzjoXeMLTa0ky5ASCflEXIve0NnMyXlqw(5imlpKf9vel3ZYYMfl3VZYwU0yFualiVliXQQalEbYsxaD7)qqSaWIpPC3E4pyHn4hykHK2A6KHTmPxfPGRPef0NnMmxL9QdA3oh2PaqOvxTMXEUu4aEUo7tWRlKTxASpgeUErBVPvUb6EGW34GU9FiOm2IpPzqp1rrM)caDfQKeRdqeu51BkkmqnCa7JgHpNRQjd2rq5gCYbpFvaDp1vRzghbvWfo3gQIzhZqP(v4T36UUNcb(zvudoOid(Q2sN37GFAohywtk26STjqZv4FwHho4m4H4kkRsADF0QRwZmocQGlCUnufZoMLDsI1QRwZmocQGlCUnufZoMLDFUBKML4etSSfx0VZcG3NMR1SypWaMLRXcG3NMR1SC4srpllBUBp8hSWg8dmLqc(9P5ATcUMsQRwZal63XzBAcK9FWYSSrRUAnd(9P5ATzO2q4DxvtC3E4pyHn4hykHKGxbsNvxTMckpLuc)(OHdOcUMsQRwZGFF0Wb0muQFfEBfIUN6Q1muqF2ykJHAFmdL6xHJxHjjQRwZqb9zJPSEv(ygk1VchVc7J2X)46Sn0cnXV1BWDJ0SehxP2yw6cElzrLAWHyb5WcbeiILf(kuS87elihwiGarSeGf49hSy5HSe2PaqSCnwqoSqabIy5WS4HF5ADhwCv46z5HSOsSeC8ZD7H)Gf2GFGPesWVp41GIuW1ukarqLxVPou7FU5eAe(CUQMmbyHaceLbjCNkGoaHAqOLYeGfciqu(3Pm2(M7XMHs9RWBRq0wdoRd0uWCaeJMc6ZgtMRYE1bTJ)X1zBOfAI3k3G7gPzjoXelaEFAUwZIL73zbWtATpSehNR9S4filfKfaVpA4aQawSStflfKfaVpnxRz5WSSSvalDGlw8Hy5kwu8v5dlwrqF2yILgCyXQbgMcywGdlpKf7bgyzlxASpSyzNkwCvicILTEdw6cElzboS4G2(FiiwWw8jLLDhZIvdmmfWSmuQF1vOyboSCywUILM(qT)gwIl8jw(D)zzvG0WYVtSG9uILaSaV)GfML7veMfqBmlfT(X1S8qwa8(0CTMfW1CfkwIdDeubxyw2cdvXSJcyXYovS0bUueil4)0AwOcKLLnlwUFNLTEdG5yBwAWHLFNyr74NfuAOQRXgUBp8hSWg8dmLqc(9P5ATcUMsVRP6n4N0AFYGZ1EdvUQMarB97AQEd(9rdhqdvUQMarRUAnd(9P5ATzO2q4DxvtO7PUAndf0NnMY6v5JzOu)kC8wnAkOpBmzUkRxLpOvxTMXEUu4aEUo7tWRlKTxASpgeUErBVPc3ijrD1Ag75sHd456SpbVUq2EPX(yq46ffVsBQWnq74FCD2gAHM436nssaHVXbD7)qqzSfFsZGEQJImdL6xHJ3Qts8WFWY4GU9FiOm2IpPzqp1rrMRYn9HA)7JoaHAqOLYe88vbZqP(v44vEdUBKML4etSa49bVguelBXf97SypWaMfVazbCLAZsxWBjlw2PIfK3fKyvvGf4WYVtSehGQFVZWI6Q1y5WS4QW1ZYdzP5AnlWwJf4Wsh4srGSeCBw6cEl5U9WFWcBWpWucj43h8Aqrk4AkPUAndSOFhNdAYNmIdFWYSStsuxTMbORahcmtP2ql0Ks1NPIguxmjZYojrD1AMGNVkyw2O7PUAnZ4iOcUW52qvm7ygk1VcVnQaOj1rgWhOt3ZX)46Sn0cni1yVrFGfBG)DnvVPil5uiSmu5QAceT1ZQOgCqrg8vTLoV3b)0CoA1vRzghbvWfo3gQIzhZYojrD1AMGNVkygk1VcVnQaOj1rgWhOt3ZX)46Sn0cni1yVr)Ke1vRzghbvWfo3gQIzNm(Q2sN37GFAo3SSts6PUAnZ4iOcUW52qvm7ygk1VcVTh(dwg87t7gYqiJcRNY)LsOX2KwN3D8tBVHXktsuxTMzCeubx4CBOkMDmdL6xH32d)blJLX)DdHmkSEk)xkLKGWNZv1K5umWCawG3FWcDac1GqlL5kCywVRQPSIT86xPzqcXfiZqoyh0KIToBBc0CfomR3v1uwXwE9R0miH4cuF0QRwZmocQGlCUnufZoMLDsI1QRwZmocQGlCUnufZoMLnARdqOgeAPmJJGk4cNBdvXSJzihStsI1bicQ86niO637m9tsC8pUoBdTqt8B9gOPG(SXK5QSxD4UrAwIX0HLhYsQdeXYVtSOs4NfyJfaVpA4aYIAhwWVha6kuSCpllBwuS1fas3HLRyXRoSyfb9zJjwuxplB5sJ9HLdxplUkC9S8qwujwShyiqGC3E4pyHn4hykHe87dEnOifCnLExt1BWVpA4aAOYv1eiARNvrn4GIm)LswGtLbhYtvVcKg09uxTMb)(OHdOzzNK44FCD2gAHM436n6JwD1Ag87JgoGg87bG2o2O7PUAndf0NnMYyO2hZYojrD1AgkOpBmL1RYhZYUpA1vRzSNlfoGNRZ(e86cz7Lg7JbHRx02BUvBGUxac1GqlLj45RcMHs9RWXR8gjjwJWNZv1KjaleqGOmiH7ub0bicQ86n1HA)ZnN6ZDJ0Syf4)s9NWSSdTWs6kSZsxWBjl(qSGYVIazXMgwWuawGC3E4pyHn4hykHee(CUQMuq5PKso2ElPbafuacxViLOG(SXK5QSEv(a8wns1d)bld(9PDdziKrH1t5)sjGznf0NnMmxL1RYhGVhWfyVRP6ny4sNHT8Vt5gCi8BOYv1eiWh7(ivp8hSmwg)3neYOW6P8FPeW2WyLkePITjToV74Na2ggfc8VRP6nL)RHWzvx7vGmu5QAcK7gPzjoUsTzbW7dEnOiwUIfNLTcyykWcaO2hwSIG(SXKcybewk6zrtpl3ZI9adSSLln2hw697(ZYHzz3lqnbYIAhwO73PHLFNybW7tZ1Aw0xrSahw(DILUG3Y436nyrFfXsdoSa49bVguuFfWciSu0ZcebnwM7jw8ILT4I(DwShyGfVazrtpl)oXIRcrqSOVIyz3lqnXcG3hnCa5U9WFWcBWpWucj43h8Aqrk4Akz9SkQbhuK5VuYcCQm4qEQ6vG0GUN6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lA7n3QnssuxTMXEUu4aEUo7tWRlKTxASpgeUErBVPc3a97AQEd(jT2Nm4CT3qLRQjW(O7rb9zJjZvzmu7dAh)JRZ2ql0ame(CUQMmo2ElPbafaE1vRzOG(SXugd1(ygk1Vcdmq4BARPtg2YKEvK5Vaq48qP(va)MgfgVvVrscf0NnMmxL1RYh0o(hxNTHwObyi85CvnzCS9wsdaka8QRwZqb9zJPSEv(ygk1Vcdmq4BARPtg2YKEvK5Vaq48qP(va)Mgfg)wVrF0wRUAndSOFhNTPjq2)blZYgT1VRP6n43hnCanu5QAceDVaeQbHwktWZxfmdL6xHJFRssWWLw9kqZVpNwNXebengQCvnbIwD1AMFFoToJjciAm43daTDSJDx3Bwf1GdkYGVQT059o4NMZbEf2hD7qT)5Hs9RWXR8gBGUDO2)8qP(v4T3CJn6JUxac1GqlLbORahcmJTV5ESzOu)kC8BvsI1bicQ86na1zoV6ZDJ0SeNyILTiiSWSCflk(Q8HfRiOpBmXIxGSGDeelXb76gW2clTMLTiiSyPbhwqExqIvvbw8cKfKYxboeilwrQn0cnPu9C3E4pyHn4hykHKISKtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkLK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvk29r725WofacncFoxvtgSJGYn4KdE(Qa3Th(dwyd(bMsiz31TCkewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sj0whGiOYR3auN58kjPN6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2Odqeu51BaQZCE1pjPxy3huewPnrpuy3huu(VuABf2pjjS7dkcRuStsuxTMj45RcMLDF0UDoStbGqJWNZv1Kb7iOCdo5GNVkGUN6Q1mJJGk4cNBdvXSJzOu)k829uyxVjWpRIAWbfzWx1w68Eh8tZ59rRUAnZ4iOcUW52qvm7yw2jjwRUAnZ4iOcUW52qvm7yw295U9WFWcBWpWucjTLwNtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkH26aebvE9gG6mNxjj9uxTMbORahcmtP2ql0Ks1NPIguxmjZYgDaIGkVEdqDMZR(jj9c7(GIWkTj6Hc7(GIY)LsBRW(jjHDFqryLIDsI6Q1mbpFvWSS7J2TZHDkaeAe(CUQMmyhbLBWjh88vb09uxTMzCeubx4CBOkMDmdL6xH3wHOvxTMzCeubx4CBOkMDmlB0wpRIAWbfzWx1w68Eh8tZ5jjwRUAnZ4iOcUW52qvm7yw295UrAwItmXcsb0kybwSea5U9WFWcBWpWucjw8zo4KHTmPxfXDJ0SeNyIfaVpTBiwEil2dmWcaO2hwSIG(SXKcyb5Dbjwvfyz3XSOjmML)sjw(DVyXzbPy8FNfczuy9elAQ9SahwGLUdlk(Q8HfRiOpBmXYHzzzZD7H)Gf2GFGPesWVpTBifCnLOG(SXK5QSEv(G2A1vRzghbvWfo3gQIzhZYojHc6Zgtgmu7tUiK9jjuqF2yY4vNCri7ts6PUAnJfFMdozylt6vrMLDsc2M068UJFA7nmwPcrBDaIGkVEdcQ(9otsc2M068UJFA7nmwj6aebvE9geu97DM(OvxTMHc6Zgtz9Q8XSSts6PUAntWZxfmdL6xH32d)blJLX)DdHmkSEk)xkHwD1AMGNVkyw295UrAwItmXcsX4)olWFNglhMyXY(f2z5WSCflaGAFyXkc6ZgtkGfK3fKyvvGf4WYdzXEGbwu8v5dlwrqF2yI72d)blSb)atjKyz8FN7gPzzl4A9VplUBp8hSWg8dmLqYSQSh(dwz9HFfuEkPuZ16FFwraW2uikUkVXMrF0hfba]] )
    

end