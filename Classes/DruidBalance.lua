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


    spec:RegisterPack( "Balance", 20210719, [[deLNHfqisvEeePUeejTjsXNGuzusvoLuvRcqvVcqzwqkDlaq7IIFbrmmrQogPKLbiEMqrtdsvUgKITbOIVbGY4aqCoaKwhaQMhG09iLAFIK(hejkDqrIwOqHhcrzIcLsxesvTrHsXhHir1iHirXjjvLwPiLxcrImtsvXnbGKDkuYpbGudfaQLcaHNQunvsv1vfkvBfaI8visySaa7Ls9xrnyIdt1IPKhlyYaDzKnlLpdjJwPCAvTAaiQxdqZMKBlv2TKFdA4c54aQ0Yv8COMUkxxjBhcFNuz8quDEHQ1lsy(Iy)O2wlB9BVd6hzhlGKoq0kDaMwauJwOx6Oh6HE27x8iYEpYda6Oi79Y7i79y4kVcK9EKhxbDqB9BVJHRjq27B3fHb4ibjwUYRabaXFxWG6VTLL5HijgUYRaba3)oKHKoqZ21PqkB7vK2wUYRazoKF27wRxD6BzBzVd6hzhlGKoq0kDaMwauJwOx6Oxmbi27(62GJ9((3Hm79TheKkBl7DqchS3JHR8kqSeBN1dYPL2sfNfTaOOLfGKoq0ItJtdzBEHIWaConailPeeKazzhQ8HLyqENHtdaYcY28cfbYY5dk6YFJLGJjmlhKLq8GIYNpOOdB40aGSaGG6GiiqwwvrbcJ9joli85DlfHzP3BidAzjAiez85dEnOiwaGPYs0qim4Zh8Aqr9nCAaqwsjc4dYs0qbhFFHIfKIXVnw(gl)Homl3gXIUbwOyb9dQpctgonailaOCajwqgSqabKy52iw2J(5pmlolQ)ofXshCiwAkc5VLIyP33yjoCXYMdwO7yz7pw(Jf83TuNxeCHvXzr3FBSeda0Pu)SamwqgPi89UILuQEuvhvhAz5p0bYcgWpQVHtdaYcakhqILoi(ybDTh12LhQZ)cJowWbQ85Hyw8OivCwoilwqmML2JA7WSalvCdNgaKf9pKFSOFyhXcSXsmu(glXq5BSedLVXIJzXzbhrH3vSCZxasNXEx94dBRF7DqQ5l1zRF7yPLT(T39W9WYEhdv(KTiVZENk3srG2XW(SJfqS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYEhhrkv(8bfDyd(8P5kflPYIwSOHLESOhlNRO6m4ZhfCanu5wkcKLKewoxr1zWhPu(KbNVDgQClfbYsFwssybhrkv(8bfDyd(8P5kflPYcqS3bjCy(O7HL9(oDywsje9zbwSetGXIU)2GRJfW5BhlEbYIU)2yz)8rbhqw8cKfGamwG3gn6EmzVJWNC5DK9(JZoKSp7yftB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS3XrKsLpFqrh2GpFA)qSKklAzVds4W8r3dl79D6WSeuKJGyr3gvSSF(0(Hyj4flB)XcqaglNpOOdZIUTpSXYJzzifHWRJLgCy52iwq)G6JWelhKflILOHA0meilEbYIUTpSXs7vkAy5GSeC8zVJWNC5DK9(JZbf5ii7ZowONT(T3PYTueODmS39W9WYE3Igmna(fk7DqchMp6EyzVh7yILyqdMga)cfl6(BJfKLsKOVvGf4WI3oAybzWcbeqILVybzPej6BfS3dZF08U9Epw0JLaebvEDM6rTD5MtSKKWIESeGqfiuxzcWcbeqkFBugh9ZFyZkIL(SOHfRvRzcE(RGzOo)lmlPYIwOHfnSyTAnZ4iOcUW52qvkIBgQZ)cZcqzb9yrdl6XsaIGkVodcQUT4dljjSeGiOYRZGGQBl(WIgwSwTMj45VcMvelAyXA1AMXrqfCHZTHQue3SIyrdl9yXA1AMXrqfCHZTHQue3muN)fMfGYIwAXcaKf0WcWZYSkQbhuKb)vBPYBXXhnVBOYTueiljjSyTAntWZFfmd15FHzbOSOLwSKKWIwSGewWrKsL3C8rSauw0YGg0WsF7ZowOXw)27u5wkc0og27H5pAE3E3A1AMGN)kygQZ)cZsQSOfAyrdl9yrpwMvrn4GIm4VAlvElo(O5DdvULIazjjHfRvRzghbvWfo3gQsrCZqD(xywaklAbWybaYcqyb4zXA1AglfecQw4ZSIyrdlwRwZmocQGlCUnuLI4Mvel9zjjHL2JA7Yd15FHzbOSae0yVds4W8r3dl7Dam8yr3FBS4SGSuIe9TcSCB(XYJl0DS4SaGxkSpSenWalWHfDBuXYTrS0EuBhlpMf3cUowoilubAV7H7HL9Ee8EyzF2Xc4yRF7DQClfbAhd7DyK9oMo7DpCpSS3r4Z7wkYEhHRwK9EGEfl9yPhlTh12LhQZ)cZcaKfTqdlaqwcqOceQRmbp)vWmuN)fML(SGew0cGKol9zrBwc0RyPhl9yP9O2U8qD(xywaGSOfAybaYsacvGqDLjaleqaP8TrzC0p)HnGRXVhwSaazjaHkqOUYeGfciGu(2Omo6N)WMH68VWS0NfKWIwaK0zPplAyrpwg)bZecQoJdcIneYF8HzjjHLaeQaH6ktWZFfmd15FHzjvw(6OjcQ8JaZTh12LhQZ)cZssclbiubc1vMaSqabKY3gLXr)8h2muN)fMLuz5RJMiOYpcm3EuBxEOo)lmlaqw0kDwssyrpwcqeu51zQh12LBozVds4W8r3dl7DK5QWs5hHzr3gDB0WYc)fkwqgSqabKyPG6yr3RuS4kfuhlXHlwoil47vkwco(y52iwWEhXI3bx1XcSXcYGfciGeWqwkrI(wbwco(W27i8jxEhzVhGfciGugKWXRG9zhlaMT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr279yP9O2U8qD(xywsLfTqdljjSm(dMjeuDgheeB(ILuzbnPZsFw0Wspw6XspwiG76JIiqd1ffFixLHdy5vGyrdl9yPhlbiubc1vgQlk(qUkdhWYRazgQZ)cZcqzrlGt6SKKWsaIGkVodcQUT4dlAyjaHkqOUYqDrXhYvz4awEfiZqD(xywaklAbCaySamw6XIwAXcWZYSkQbhuKb)vBPYBXXhnVBOYTueil9zPplAyrpwcqOceQRmuxu8HCvgoGLxbYmKdgNL(S0NLKew6XcbCxFuebAWWLsr39fQ8SSIZIgw6XIESeGiOYRZupQTl3CILKewcqOceQRmy4sPO7(cvEwwXZXe9qdajDTmd15FHzbOSOLwOhl9zPpljjS0JLaeQaH6kJfnyAa8luMHCW4SKKWIESmEGm3avkw6ZIgw6XspwiG76JIiqZx4WSo3srzG7YRB1LbjeFGyrdlbiubc1vMVWHzDULIYa3Lx3Qldsi(azgYbJZsFwssyPhleWD9rreObV5GqDeygowzylFWPJQJfnSeGqfiuxzo40r1rG5VWpQTlht0GMyceTmd15FHzPpljjS0JLESGWN3TuKbw5fMY38fG0XI2SOfljjSGWN3TuKbw5fMY38fG0XI2Setw6ZIgw6XYnFbiDMtlZqoy8CacvGqDfljjSCZxasN50YeGqfiuxzgQZ)cZsQS81rteu5hbMBpQTlpuN)fMfailALol9zjjHfe(8ULImWkVWu(MVaKow0MfGWIgw6XYnFbiDMdiMHCW45aeQaH6kwssy5MVaKoZbetacvGqDLzOo)lmlPYYxhnrqLFeyU9O2U8qD(xywaGSOv6S0NLKewq4Z7wkYaR8ct5B(cq6yrBwsNL(S0NL(SKKWsaIGkVodGXN3lw6ZssclTh12LhQZ)cZcqzXA1AMGN)kyaxJFpSS3bjCy(O7HL9ESJjqwoilGKYJZYTrSSWokIfyJfKLsKOVvGfDBuXYc)fkwaHllfXcSyzHjw8cKLOHqq1XYc7Oiw0TrflEXIdcYcHGQJLhZIBbxhlhKfWNS3r4tU8oYEpaMdWc8Vhw2NDSai263ENk3srG2XWEhgzVJPZE3d3dl7De(8ULIS3r4QfzVRhly4sz9fO52MxPYyIaKgdvULIazjjHL2JA7Yd15FHzjvwas6PZssclTh12LhQZ)cZcqzbiOHfGXspwqV0zbaYI1Q1m328kvgteG0yWNhaKfGNfGWsFwssyXA1AMBBELkJjcqAm4ZdaYsQSetaclaqw6XYSkQbhuKb)vBPYBXXhnVBOYTueilaplOHL(27GeomF09WYEhajFE3srSSWeilhKfqs5XzXR4SCZxashMfVazjaIzr3gvSOZ)7luS0GdlEXc6VI2GZ7SenWG9ocFYL3r27328kvgteG0K15)zF2XcGARF7DQClfbAhd7DqchMp6EyzVh7yIf0Vlk(qUIfa0dy5vGybiPJPaMflQbhIfNfKLsKOVvGLfMm27L3r27uxu8HCvgoGLxbYEpm)rZ727biubc1vMGN)kygQZ)cZcqzbiPZIgwcqOceQRmbyHaciLVnkJJ(5pSzOo)lmlaLfGKolAyPhli85DlfzUT5vQmMiaPjRZ)JLKewSwTM52MxPYyIaKgd(8aGSKklXmDwagl9yzwf1GdkYG)QTu5T44JM3nu5wkcKfGNfGdl9zPpljjS0EuBxEOo)lmlaLLycWS39W9WYEN6IIpKRYWbS8kq2NDS0kDB9BVtLBPiq7yyVds4W8r3dl79yhtSSdxkfDFHIfaelR4SaCWuaZIf1GdXIZcYsjs03kWYctg79Y7i7DmCPu0DFHkplR427H5pAE3EpaHkqOUYe88xbZqD(xywaklahw0WIESeGiOYRZGGQBl(WIgw0JLaebvEDM6rTD5MtSKKWsaIGkVot9O2UCZjw0WsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbOSaCyrdl9ybHpVBPitawiGaszqchVcSKKWsacvGqDLj45VcMH68VWSauwaoS0NLKewcqeu51zqq1TfFyrdl9yrpwMvrn4GIm4VAlvElo(O5DdvULIazrdlbiubc1vMGN)kygQZ)cZcqzb4WssclwRwZmocQGlCUnuLI4MH68VWSauw0c9ybyS0Jf0WcWZcbCxFuebA(cFZkCWbNbFeFrzlsPyPplAyXA1AMXrqfCHZTHQue3SIyPpljjS0EuBxEOo)lmlaLfGGg7DpCpSS3XWLsr39fQ8SSIBF2XslTS1V9ovULIaTJH9UhUhw27FHdZ6ClfLbUlVUvxgKq8bYEpm)rZ727wRwZe88xbZqD(xywsLfTqdlAyPhl6XYSkQbhuKb)vBPYBXXhnVBOYTueiljjSyTAnZ4iOcUW52qvkIBgQZ)cZcqzrlGWcWyPhlXKfGNfRvRzSuqiOAHpZkIL(Samw6XspwaySaazbnSa8SyTAnJLccbvl8zwrS0NfGNfc4U(Oic08f(Mv4Gdod(i(IYwKsXsFw0WI1Q1mJJGk4cNBdvPiUzfXsFwssyP9O2U8qD(xywaklabn27L3r27FHdZ6ClfLbUlVUvxgKq8bY(SJLwaXw)27u5wkc0og27GeomF09WYEp2XelZJA7yXIAWHyjaIT3lVJS3XBoiuhbMHJvg2YhC6O6S3dZF08U9EpwcqOceQRmbp)vWmKdgNfnSOhlbicQ86m1JA7YnNyrdli85DlfzUT5vQmMiaPjRZ)JLKewcqeu51zQh12LBoXIgwcqOceQRmbyHaciLVnkJJ(5pSzihmolAyPhli85DlfzcWcbeqkds44vGLKewcqOceQRmbp)vWmKdgNL(S0NfnSacpdEvTFiZ9ba)cflAyPhlGWZGpsP8j3u(qM7da(fkwssyrpwoxr1zWhPu(KBkFidvULIazjjHfCePu5Zhu0Hn4ZN2pelPYsmzPplAyPhlGWZ0bHv7hYCFaWVqXsFw0Wspwq4Z7wkY84Sdjwssyzwf1GdkYy5kVcug2YUsLVTVqHnu5wkcKLKewC8nUkhb1rdlPQnla00zjjHfRvRzSuqiOAHpZkIL(SOHLESeGqfiuxzSObtdGFHYmKdgNLKew0JLXdK5gOsXsFwssyP9O2U8qD(xywaklOx627E4EyzVJ3CqOocmdhRmSLp40r1zF2XsRyARF7DQClfbAhd7DqchMp6EyzVR)ThZYJzXzz8BJgwiLBbh)iw05Xz5GS05asS4kflWILfMybF(XYnFbiDywoilwelQViqwwrSO7VnwqwkrI(wbw8cKfKbleqajw8cKLfMy52iwasbYcwbpwGflbqw(glwWBJLB(cq6WS4dXcSyzHjwWNFSCZxash2Epm)rZ727i85DlfzGvEHP8nFbiDSOnlaHfnSOhl38fG0zoGygYbJNdqOceQRyjjHLESGWN3TuKbw5fMY38fG0XI2SOfljjSGWN3TuKbw5fMY38fG0XI2Setw6ZIgw6XI1Q1mbp)vWSIyrdl9yrpwcqeu51zqq1TfFyjjHfRvRzghbvWfo3gQsrCZqD(xywagl9ybnSa8SmRIAWbfzWF1wQ8wC8rZ7gQClfbYsFwaQ2SCZxasN50YyTATm4A87HflAyXA1AMXrqfCHZTHQue3SIyjjHfRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SIyPpljjSeGqfiuxzcE(RGzOo)lmlaJfGWsQSCZxasN50YeGqfiuxzaxJFpSyrdl6XI1Q1mbp)vWSIyrdl9yrpwcqeu51zQh12LBoXsscl6XccFE3srMaSqabKYGeoEfyPplAyrpwcqeu51zam(8EXssclbicQ86m1JA7YnNyrdli85DlfzcWcbeqkds44vGfnSeGqfiuxzcWcbeqkFBugh9ZFyZkIfnSOhlbiubc1vMGN)kywrSOHLES0JfRvRzOG6JWuwTkFmd15FHzjvw0kDwssyXA1AgkO(imLXqLpMH68VWSKklALol9zrdl6XYSkQbhuKXYvEfOmSLDLkFBFHcBOYTueiljjS0JfRvRzSCLxbkdBzxPY32xOW5YV1qg85bazrBwqdljjSyTAnJLR8kqzyl7kv(2(cfo7tWlYGppailAZcaHL(S0NLKewSwTMbWVahcmtDrqD00r1LPIguFkiZkIL(SKKWs7rTD5H68VWSauwas6SKKWccFE3srgyLxykFZxashlAZs627yf8W2738fG0PL9UhUhw2738fG0PL9zhlTqpB9BVtLBPiq7yyV7H7HL9(nFbiDaXEpm)rZ727i85DlfzGvEHP8nFbiDSON2Saew0WIESCZxasN50YmKdgphGqfiuxXsscli85DlfzGvEHP8nFbiDSOnlaHfnS0JfRvRzcE(RGzfXIgw6XIESeGiOYRZGGQBl(WssclwRwZmocQGlCUnuLI4MH68VWSamw6XcAyb4zzwf1GdkYG)QTu5T44JM3nu5wkcKL(SauTz5MVaKoZbeJ1Q1YGRXVhwSOHfRvRzghbvWfo3gQsrCZkILKewSwTMzCeubx4CBOkfXZ4VAlvElo(O5DZkIL(SKKWsacvGqDLj45VcMH68VWSamwaclPYYnFbiDMdiMaeQaH6kd4A87HflAyrpwSwTMj45VcMvelAyPhl6XsaIGkVot9O2UCZjwssyrpwq4Z7wkYeGfciGugKWXRal9zrdl6XsaIGkVodGXN3lw0Wspw0JfRvRzcE(RGzfXsscl6XsaIGkVodcQUT4dl9zjjHLaebvEDM6rTD5MtSOHfe(8ULImbyHaciLbjC8kWIgwcqOceQRmbyHaciLVnkJJ(5pSzfXIgw0JLaeQaH6ktWZFfmRiw0Wspw6XI1Q1muq9rykRwLpMH68VWSKklALoljjSyTAndfuFeMYyOYhZqD(xywsLfTsNL(SOHf9yzwf1GdkYy5kVcug2YUsLVTVqHnu5wkcKLKew6XI1Q1mwUYRaLHTSRu5B7lu4C53Aid(8aGSOnlOHLKewSwTMXYvEfOmSLDLkFBFHcN9j4fzWNhaKfTzbGWsFw6ZsFwssyXA1Aga)cCiWm1fb1rthvxMkAq9PGmRiwssyP9O2U8qD(xywaklajDwssybHpVBPidSYlmLV5laPJfTzjD7DScEy79B(cq6aI9zhlTqJT(T3PYTueODmS3bjCy(O7HL9ESJjmlUsXc82OHfyXYctS8h1HzbwSeaT39W9WYEFHP8Fuh2(SJLwahB9BVtLBPiq7yyVds4W8r3dl79ylfEqIfpCpSyr94JflhtGSalwW)T87HfsueQhBV7H7HL9(SQShUhwz1Jp7D8nF4SJLw27H5pAE3EhHpVBPiZJZoKS3vp(YL3r27oKSp7yPfaZw)27u5wkc0og27H5pAE3EFwf1GdkYy5kVcug2YUsLVTVqHneWD9rreO9o(MpC2Xsl7DpCpSS3NvL9W9WkRE8zVRE8LlVJS3TG(zF2XslaIT(T3PYTueODmS39W9WYEFwv2d3dRS6XN9U6XxU8oYEhF2N9zVBb9Zw)2XslB9BVtLBPiq7yyV7H7HL9(4iOcUW52qvkIBVds4W8r3dl79yZqvkIZIU)2ybzPej6BfS3dZF08U9U1Q1mbp)vWmuN)fMLuzrl0yF2Xci263ENk3srG2XWE3d3dl7Dh0JUhbLX68PZEpepOO85dk6W2Xsl79W8hnVBVBTAnJLR8kqzyl7kv(2(cfox(TgYGppailaLfaclAyXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaqwaklaew0Wspw0Jfq4zCqp6EeugRZNUmO35OiZ9ba)cflAyrpw8W9WY4GE09iOmwNpDzqVZrrMVYn1JA7yrdl9yrpwaHNXb9O7rqzSoF6YBKRm3ha8luSKKWci8moOhDpckJ15txEJCLzOo)lmlPYsmzPpljjSacpJd6r3JGYyD(0Lb9ohfzWNhaKfGYsmzrdlGWZ4GE09iOmwNpDzqVZrrMH68VWSauwqdlAybeEgh0JUhbLX68Pld6DokYCFaWVqXsF7DqchMp6EyzVh7yILuc6r3JGyzxNpDSOBJkw8JffHXSCBEXc6XsmGPu)SGppaiMfVaz5GSmuBi8glolavBGWc(8aGS4ywu(rS4ywIGy8BPiwGdl33rS8hlyil)XIpZJGWSaG8cFS4TJgwCwIjWybFEaqwiKh9dHTp7yftB9BVtLBPiq7yyV7H7HL9EawiGas5BJY4OF(dBVds4W8r3dl79yhtSGmyHaciXIU)2ybzPej6Bfyr3gvSebX43srS4filWBJgDpMyr3FBS4Sedyk1plwRwJfDBuXciHJxHVqzVhM)O5D7D9ybCwpOPG5aiMfnS0JLESGWN3TuKjaleqaPmiHJxbw0WIESeGqfiuxzcE(RGzihmoljjSyTAntWZFfmRiw6ZIgw6XI1Q1mwUYRaLHTSRu5B7lu4C53Aid(8aGSOnlaewssyXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaqw0Mfacl9zjjHL2JA7Yd15FHzbOSOv6S03(SJf6zRF7DQClfbAhd7DpCpSS3BRjEg2YKAvK9oiHdZhDpSS3Jnq0NfhZYTrS0(bFSGkaYYxSCBelolXaMs9ZIUVaH6yboSO7VnwUnIfKsXN3lwSwTglWHfD)TXIZcabyykWskb9O7rqSSRZNow8cKfD(FS0GdlilLirFRalFJL)yrhSowSiwwrS4O8VyXIAWHy52iwcGS8ywAF94nc0Epm)rZ7279yPhl9yXA1Aglx5vGYWw2vQ8T9fkCU8BnKbFEaqwsLfGdljjSyTAnJLR8kqzyl7kv(2(cfo7tWlYGppailPYcWHL(SOHLESOhlbicQ86miO62IpSKKWIESyTAnZ4iOcUW52qvkIBwrS0NL(SOHLESaoRh0uWCaeZssclbiubc1vMGN)kygQZ)cZsQSGM0zjjHLESeGiOYRZupQTl3CIfnSeGqfiuxzcWcbeqkFBugh9ZFyZqD(xywsLf0Kol9zPpl9zjjHLESacpJd6r3JGYyD(0Lb9ohfzgQZ)cZsQSaqyrdlbiubc1vMGN)kygQZ)cZsQSOv6SOHLaebvEDMIcdubhqw6ZssclFD0ebv(rG52JA7Yd15FHzbOSaqyrdl6XsacvGqDLj45VcMHCW4SKKWsaIGkVodGXN3lw0WI1Q1ma(f4qGzQlcQJMoQoZkILKewcqeu51zqq1TfFyrdlwRwZmocQGlCUnuLI4MH68VWSauwaOSOHfRvRzghbvWfo3gQsrCZkY(SJfAS1V9ovULIaTJH9UhUhw27bVcKkBTAn79W8hnVBV3JfRvRzSCLxbkdBzxPY32xOW5YV1qMH68VWSKklamdAyjjHfRvRzSCLxbkdBzxPY32xOWzFcErMH68VWSKklamdAyPplAyPhlbiubc1vMGN)kygQZ)cZsQSaWyjjHLESeGqfiuxzOUiOoAYwWc0muN)fMLuzbGXIgw0JfRvRza8lWHaZuxeuhnDuDzQOb1NcYSIyrdlbicQ86magFEVyPpl9zrdlo(gxLJG6OHLu1MLyMU9U1Q1YL3r274ZhfCaT3bjCy(O7HL9oY8kqkw2pFuWbKfD)TXIZsr6yjgWuQFwSwTglEbYcYsjs03kWYJl0DS4wW1XYbzXIyzHjq7ZowahB9BVtLBPiq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JTRUiw2pFWRbfHzr3FBS4Sedyk1plwRwJfR1Xsbpw0TrflrqO6luS0GdlilLirFRalWHfKsFboeil7r)8h2Epm)rZ7279yXA1Aglx5vGYWw2vQ8T9fkCU8BnKbFEaqwsLfGWssclwRwZy5kVcug2YUsLVTVqHZ(e8Im4ZdaYsQSaew6ZIgw6XsaIGkVot9O2UCZjwssyjaHkqOUYe88xbZqD(xywsLfagljjSOhli85DlfzcG5aSa)7HflAyrpwcqeu51zam(8EXsscl9yjaHkqOUYqDrqD0KTGfOzOo)lmlPYcaJfnSOhlwRwZa4xGdbMPUiOoA6O6YurdQpfKzfXIgwcqeu51zam(8EXsFw6ZIgw6XIESacptBnXZWwMuRIm3ha8luSKKWIESeGqfiuxzcE(RGzihmoljjSOhlbiubc1vMaSqabKY3gLXr)8h2mKdgNL(2NDSay263ENk3srG2XWE3d3dl7D85dEnOi7DqchMp6EyzVhBxDrSSF(GxdkcZIf1GdXcYGfciGK9Ey(JM3T37XsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbOSGgw0WIESaoRh0uWCaeZIgw6XccFE3srMaSqabKYGeoEfyjjHLaeQaH6ktWZFfmd15FHzbOSGgw6ZIgwq4Z7wkYeaZbyb(3dlw6ZIgw0Jfq4zARjEg2YKAvK5(aGFHIfnSeGiOYRZupQTl3CIfnSOhlGZ6bnfmhaXSOHfkO(imz(k7vCw0WIJVXv5iOoAyjvwqV0Tp7ybqS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYEVhlwRwZmocQGlCUnuLI4MH68VWSKklOHLKew0JfRvRzghbvWfo3gQsrCZkIL(SOHLESyTAndGFboeyM6IG6OPJQltfnO(uqMH68VWSauwqfanDoYzPplAyPhlwRwZqb1hHPmgQ8XmuN)fMLuzbva005iNLKewSwTMHcQpctz1Q8XmuN)fMLuzbva005iNL(27GeomF09WYEp2cl0DSacpwaxZxOy52iwOcKfyJfaeocQGlmlXMHQuehTSaUMVqXcGFboeiluxeuhnDuDSahw(ILBJyr54JfubqwGnw8If0pO(imzVJWNC5DK9oi8YdbCx)qDuDy7ZowauB9BVtLBPiq7yyV7H7HL9oEvTFi79W8hnVBVpuBi8MBPiw0WY5dk6m33r5dMbFILuzrlGdlAyXJYHnkailAybHpVBPidi8YdbCx)qDuDy79q8GIYNpOOdBhlTSp7yPv6263ENk3srG2XWE3d3dl79oiSA)q27H5pAE3EFO2q4n3srSOHLZhu0zUVJYhmd(elPYIwX0Ggw0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2owAzF2XslTS1V9ovULIaTJH9UhUhw274JukFYnLpK9Ey(JM3T3hQneEZTuelAy58bfDM77O8bZGpXsQSOfWHfGXYqD(xyw0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2owAzF2XslGyRF7DQClfbAhd7DpCpSS3BWjqzylx(TgYEhKWH5JUhw27XgySybwSeazr3FBW1XsWJI(cL9Ey(JM3T39OCyJcaAF2XsRyARF7DQClfbAhd7DpCpSS3PUiOoAYwWc0EhKWH5JUhw27OFxeuhnSedybYIUnQyXTGRJLdYcvhnS4SuKowIbmL6NfDFbc1XIxGSGDeeln4WcYsjs03kyVhM)O5D79ESqb1hHjJAv(Klc5hljjSqb1hHjdgQ8jxeYpwssyHcQpctgVINlc5hljjSyTAnJLR8kqzyl7kv(2(cfox(TgYmuN)fMLuzbGzqdljjSyTAnJLR8kqzyl7kv(2(cfo7tWlYmuN)fMLuzbGzqdljjS44BCvocQJgwsLfaA6SOHLaeQaH6ktWZFfmd5GXzrdl6Xc4SEqtbZbqml9zrdl9yjaHkqOUYe88xbZqD(xywsLLyMoljjSeGqfiuxzcE(RGzihmol9zjjHLVoAIGk)iWC7rTD5H68VWSauw0kD7ZowAHE263ENk3srG2XWE3d3dl792AINHTmPwfzVds4W8r3dl79yde9zzEuBhlwudoell8xOybzP0Epm)rZ727biubc1vMGN)kygYbJZIgwq4Z7wkYeaZbyb(3dlw0WspwC8nUkhb1rdlPYcanDw0WIESeGiOYRZupQTl3CILKewcqeu51zQh12LBoXIgwC8nUkhb1rdlaLf0lDw6ZIgw0JLaebvEDgeuDBXhw0Wspw0JLaebvEDM6rTD5MtSKKWsacvGqDLjaleqaP8TrzC0p)Hnd5GXzPplAyrpwaN1dAkyoaITp7yPfAS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYExpwaN1dAkyoaIzrdli85DlfzcG5aSa)7HflAyPhl9yXX34QCeuhnSKkla00zrdl9yXA1Aga)cCiWm1fb1rthvxMkAq9PGmRiwssyrpwcqeu51zam(8EXsFwssyXA1AglfecQw4ZSIyrdlwRwZyPGqq1cFMH68VWSauwSwTMj45VcgW143dlw6ZssclFD0ebv(rG52JA7Yd15FHzbOSyTAntWZFfmGRXVhwSKKWsaIGkVot9O2UCZjw6ZIgw6XIESeGiOYRZupQTl3CILKew6XIJVXv5iOoAybOSGEPZssclGWZ0wt8mSLj1QiZ9ba)cfl9zrdl9ybHpVBPitawiGaszqchVcSKKWsacvGqDLjaleqaP8TrzC0p)Hnd5GXzPpl9T3bjCy(O7HL9oYsjs03kWIUnQyXpwaOPdmwsjgaZsp4OG6OHLBZlwqV0zjLyaml6(BJfKbleqaP(SO7Vn46yrbXFHIL77iw(ILyOGqq1cFS4filQViwwrSO7VnwqgSqabKy5BS8hl6CmlGeoEfiq7De(KlVJS3dG5aSa)7Hv2c6N9zhlTao263ENk3srG2XWEpm)rZ727i85DlfzcG5aSa)7Hv2c6N9UhUhw27bsr47Dv2vpQQJQZ(SJLwamB9BVtLBPiq7yyVhM)O5D7De(8ULImbWCawG)9WkBb9ZE3d3dl79Vc(u(9WY(SJLwaeB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS3PG6JWK5RSAv(WcWZcaHfKWIhUhwg85t7hYqiNcRJY33rSamw0JfkO(imz(kRwLpSa8S0JfGdlaJLZvuDgmCPYWw(2OCdoe(mu5wkcKfGNLyYsFwqclE4Eyz0n(TziKtH1r577iwaglPBacliHfCePu5nhFK9oiHdZhDpSS3rF89D(ryw2G6yPBf2yjLyaml(qSGY)IazjIgwWuawG27i8jxEhzV74iamn7uW(SJLwauB9BVtLBPiq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JTRUiw2pFWRbfHzr3gvSCBelTh12XYJzXTGRJLdYcvGOLL2qvkIZYJzXTGRJLdYcvGOLL4Wfl(qS4hla00bglPedGz5lw8If0pO(imHwwqwkrI(wbwuo(WS4f82OHfacWWuaZcCyjoCXIo4sbYcebnbpILo4qSCBEXcNOv6SKsmaMfDBuXsC4IfDWLcSq3XY(5dEnOiwkOo79W8hnVBV3JLVoAIGk)iWC7rTD5H68VWSauwqpwssyPhlwRwZmocQGlCUnuLI4MH68VWSauwqfanDoYzb4zjqVILES44BCvocQJgwqclXmDw6ZIgwSwTMzCeubx4CBOkfXnRiw6ZsFwssyPhlo(gxLJG6OHfGXccFE3srghhbGPzNcSa8SyTAndfuFeMYyOYhZqD(xywaglGWZ0wt8mSLj1QiZ9baX5H68Vyb4zbig0WsQSOLwPZssclo(gxLJG6OHfGXccFE3srghhbGPzNcSa8SyTAndfuFeMYQv5JzOo)lmlaJfq4zARjEg2YKAvK5(aG48qD(xSa8SaedAyjvw0sR0zPplAyHcQpctMVYEfNfnS0Jf9yXA1AMGN)kywrSKKWIESCUIQZGpFuWb0qLBPiqw6ZIgw6Xspw0JLaeQaH6ktWZFfmRiwssyjarqLxNbW4Z7flAyrpwcqOceQRmuxeuhnzlybAwrS0NLKewcqeu51zQh12LBoXsFw0Wspw0JLaebvEDgeuDBXhwssyrpwSwTMj45VcMveljjS44BCvocQJgwsLfaA6S0NLKew6XY5kQod(8rbhqdvULIazrdlwRwZe88xbZkIfnS0JfRvRzWNpk4aAWNhaKfGYsmzjjHfhFJRYrqD0WsQSaqtNL(S0NLKewSwTMj45VcMvelAyrpwSwTMzCeubx4CBOkfXnRiw0WIESCUIQZGpFuWb0qLBPiq7ZowajDB9BVtLBPiq7yyV7H7HL9Er6YDqyzVds4W8r3dl79yhtSaGcclmlFXI(SkFyb9dQpctS4filyhbXcszCvdyXMLsXcakiSyPbhwqwkrI(wb79W8hnVBV3JfRvRzOG6JWuwTkFmd15FHzjvwiKtH1r577iwssyPhlHnFqryw0MfGWIgwgkS5dkkFFhXcqzbnS0NLKewcB(GIWSOnlXKL(SOHfpkh2OaG2NDSaIw263ENk3srG2XWEpm)rZ7279yXA1AgkO(imLvRYhZqD(xywsLfc5uyDu((oIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWsacvGqDLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NLKew6XsyZhueMfTzbiSOHLHcB(GIY33rSauwqdl9zjjHLWMpOimlAZsmzPplAyXJYHnkaO9UhUhw27BUQL7GWY(SJfqaIT(T3PYTueODmS3dZF08U9EpwSwTMHcQpctz1Q8XmuN)fMLuzHqofwhLVVJyrdl9yjaHkqOUYe88xbZqD(xywsLf0KoljjSeGqfiuxzcWcbeqkFBugh9ZFyZqD(xywsLf0Kol9zjjHLESe28bfHzrBwaclAyzOWMpOO89DelaLf0WsFwssyjS5dkcZI2Setw6ZIgw8OCyJcaAV7H7HL9EBPu5oiSSp7ybKyARF7DQClfbAhd7DqchMp6EyzVJuarFwGflbq7DpCpSS315Z8WjdBzsTkY(SJfqqpB9BVtLBPiq7yyV7H7HL9o(8P9dzVds4W8r3dl79yhtSSF(0(Hy5GSenWal7qLpSG(b1hHjwGdl62OILVybwQ4SOpRYhwq)G6JWelEbYYctSGuarFwIgyaZY3y5lw0Nv5dlOFq9ryYEpm)rZ727uq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yjjHfRvRz05Z8WjdBzsTkYSIyrdlwRwZqb1hHPSAv(ywrSKKWspwSwTMj45VcMH68VWSauw8W9WYOB8BZqiNcRJY33rSOHfRvRzcE(RGzfXsF7Zowabn263E3d3dl7DDJFB27u5wkc0og2NDSacWXw)27u5wkc0og27E4EyzVpRk7H7Hvw94ZEx94lxEhzV3CL62ML9zF27oKS1VDS0Yw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi79ESyTAnZ9DKo4uzWH8oRVaPXmuN)fMfGYcQaOPZrolaJL0nAXssclwRwZCFhPdovgCiVZ6lqAmd15FHzbOS4H7HLbF(0(HmeYPW6O89DelaJL0nAXIgw6XcfuFeMmFLvRYhwssyHcQpctgmu5tUiKFSKKWcfuFeMmEfpxeYpw6ZsFw0WI1Q1m33r6GtLbhY7S(cKgZkIfnSmRIAWbfzUVJ0bNkdoK3z9fingQClfbAVds4W8r3dl7DK5QWs5hHzr3gDB0WYTrSeBhY7c(f2OHfRvRXIUxPyP5kflWwJfD)T9fl3gXsri)yj44ZEhHp5Y7i7DWH8USUxPYnxPYWwZ(SJfqS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYExpwOG6JWK5RmgQ8HfnS0JfCePu5Zhu0Hn4ZN2pelPYcAyrdlNRO6my4sLHT8Tr5gCi8zOYTueiljjSGJiLkF(GIoSbF(0(HyjvwayS03EhKWH5JUhw27iZvHLYpcZIUn62OHL9Zh8AqrS8yw0bNBJLGJVVqXcebnSSF(0(Hy5lw0Nv5dlOFq9ryYEhHp5Y7i79hvbhkJpFWRbfzF2XkM263ENk3srG2XWE3d3dl79aSqabKY3gLXr)8h2EhKWH5JUhw27XoMybzWcbeqIfDBuXIFSOimMLBZlwqt6SKsmaMfVazr9fXYkIfD)TXcYsjs03kyVhM)O5D7D9ybCwpOPG5aiMfnS0JLESGWN3TuKjaleqaPmiHJxbw0WIESeGqfiuxzcE(RGzihmoljjSyTAntWZFfmRiw6ZIgw6XI1Q1muq9rykRwLpMH68VWSKklahwssyXA1AgkO(imLXqLpMH68VWSKklahw6ZIgw6XIESmRIAWbfzSCLxbkdBzxPY32xOWgQClfbYssclwRwZy5kVcug2YUsLVTVqHZLFRHm4ZdaYsQSetwssyXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaqwsLLyYsFwssyXcIXSOHL2JA7Yd15FHzbOSOv6SOHf9yjaHkqOUYe88xbZqoyCw6BF2Xc9S1V9ovULIaTJH9UhUhw27JJGk4cNBdvPiU9oiHdZhDpSS3JDmXsSzOkfXzr3FBSGSuIe9Tc27H5pAE3E3A1AMGN)kygQZ)cZsQSOfASp7yHgB9BVtLBPiq7yyV7H7HL9oEvTFi79q8GIYNpOOdBhlTS3dZF08U9EpwgQneEZTueljjSyTAndfuFeMYyOYhZqD(xywaklXKfnSqb1hHjZxzmu5dlAyzOo)lmlaLfTqpw0WY5kQodgUuzylFBuUbhcFgQClfbYsFw0WY5dk6m33r5dMbFILuzrl0Jfail4isPYNpOOdZcWyzOo)lmlAyPhluq9ryY8v2R4SKKWYqD(xywaklOcGMoh5S03EhKWH5JUhw27XoMyzFvTFiw(ILiVaPUpWcSyXR432xOy528Jf1JGWSOf6HPaMfVazrryml6(BJLo4qSC(GIomlEbYIFSCBelubYcSXIZYou5dlOFq9ryIf)yrl0JfmfWSahwuegZYqD(xFHIfhZYbzPGhlBoIVqXYbzzO2q4nwaxZxOyrFwLpSG(b1hHj7ZowahB9BVtLBPiq7yyV7H7HL9o(8P5kL9oiHdZhDpSS3rkruelRiw2pFAUsXIFS4kfl33rywwLIWyww4VqXI(ep4JJzXlqw(JLhZIBbxhlhKLObgyboSOOJLBJybhrH3vS4H7HflQViwSifuhlBEbQiwITd5DwFbsdlWIfGWY5dk6W27H5pAE3Expwoxr1zWhPu(KbNVDgQClfbYIgw6XI1Q1m4ZNMRuMHAdH3ClfXIgw6XcoIuQ85dk6Wg85tZvkwaklXKLKew0JLzvudoOiZ9DKo4uzWH8oRVaPXqLBPiqw6ZssclNRO6my4sLHT8Tr5gCi8zOYTueilAyXA1AgkO(imLXqLpMH68VWSauwIjlAyHcQpctMVYyOYhw0WI1Q1m4ZNMRuMH68VWSauwaySOHfCePu5Zhu0Hn4ZNMRuSKQ2SGES0NfnS0Jf9yzwf1GdkYOIh8XX5MIO7luzuQVlctgQClfbYsscl33rSGuzb9qdlPYI1Q1m4ZNMRuMH68VWSamwacl9zrdlNpOOZCFhLpyg8jwsLf0yF2XcGzRF7DQClfbAhd7DpCpSS3XNpnxPS3bjCy(O7HL9osXFBSSFKs5dlX25BhllmXcSyjaYIUnQyzO2q4n3srSyTowW3RuSOZ)JLgCyrFIh8XXSenWalEbYciSq3XYctSyrn4qSGSyl2WY(9kfllmXIf1GdXcYGfciGel4Vcel3MFSO7vkwIgyGfVG3gnSSF(0CLYEpm)rZ727NRO6m4JukFYGZ3odvULIazrdlwRwZGpFAUszgQneEZTuelAyPhl6XYSkQbhuKrfp4JJZnfr3xOYOuFxeMmu5wkcKLKewUVJybPYc6HgwsLf0JL(SOHLZhu0zUVJYhmd(elPYsmTp7ybqS1V9ovULIaTJH9UhUhw274ZNMRu27GeomF09WYEhP4VnwITd5DwFbsdllmXY(5tZvkwoilasuelRiwUnIfRvRXIvCwCfgYYc)fkw2pFAUsXcSybnSGPaSaXSahwuegZYqD(xFHYEpm)rZ727ZQOgCqrM77iDWPYGd5DwFbsJHk3srGSOHfCePu5Zhu0Hn4ZNMRuSKQ2Setw0Wspw0JfRvRzUVJ0bNkdoK3z9finMvelAyXA1Ag85tZvkZqTHWBULIyjjHLESGWN3TuKbCiVlR7vQCZvQmS1yrdl9yXA1Ag85tZvkZqD(xywaklXKLKewWrKsLpFqrh2GpFAUsXsQSaew0WY5kQod(iLYNm48TZqLBPiqw0WI1Q1m4ZNMRuMH68VWSauwqdl9zPpl9Tp7ybqT1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYE3X34QCeuhnSKklaK0zbaYspw0kDwaEwSwTM5(oshCQm4qEN1xG0yWNhaKL(SaazPhlwRwZGpFAUszgQZ)cZcWZsmzbjSGJiLkV54Jyb4zrpwoxr1zWhPu(KbNVDgQClfbYsFwaGS0JLaeQaH6kd(8P5kLzOo)lmlaplXKfKWcoIuQ8MJpIfGNLZvuDg8rkLpzW5BNHk3srGS0Nfail9ybeEM2AINHTmPwfzgQZ)cZcWZcAyPplAyPhlwRwZGpFAUszwrSKKWsacvGqDLbF(0CLYmuN)fML(27GeomF09WYEhzUkSu(ryw0Tr3gnS4SSF(GxdkILfMyr3RuSe8fMyz)8P5kflhKLMRuSaBn0YIxGSSWel7Np41GIy5GSairrSeBhY7S(cKgwWNhaKLvK9ocFYL3r274ZNMRuzDW6YnxPYWwZ(SJLwPBRF7DQClfbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9ESJjw2pFWRbfXIU)2yj2oK3z9finSCqwaKOiwwrSCBelwRwJfD)Tbxhlki(luSSF(0CLILv09DelEbYYctSSF(GxdkIfyXc6bmwIbmL6Nf85baXSSQ7vSGESC(GIoS9Ey(JM3T3r4Z7wkYaoK3L19kvU5kvg2ASOHfe(8ULIm4ZNMRuzDW6YnxPYWwJfnSOhli85DlfzEufCOm(8bVgueljjS0JfRvRzSCLxbkdBzxPY32xOW5YV1qg85bazjvwIjljjSyTAnJLR8kqzyl7kv(2(cfo7tWlYGppailPYsmzPplAybhrkv(8bfDyd(8P5kflaLf0JfnSGWN3TuKbF(0CLkRdwxU5kvg2A2NDS0slB9BVtLBPiq7yyV7H7HL9Ud6r3JGYyD(0zVhIhuu(8bfDy7yPL9Ey(JM3T31JL7da(fkw0WIES4H7HLXb9O7rqzSoF6YGENJImFLBQh12XssclGWZ4GE09iOmwNpDzqVZrrg85bazbOSetw0Wci8moOhDpckJ15txg07CuKzOo)lmlaLLyAVds4W8r3dl79yhtSG15thlyil3MFSehUybfDS05iNLv09DelwXzzH)cfl)XIJzr5hXIJzjcIXVLIybwSOimMLBZlwIjl4ZdaIzboSaG8cFSOBJkwIjWybFEaqmleYJ(HSp7yPfqS1V9ovULIaTJH9UhUhw27Dqy1(HS3dXdkkF(GIoSDS0YEpm)rZ727d1gcV5wkIfnSC(GIoZ9Du(GzWNyjvw6Xspw0c9ybyS0JfCePu5Zhu0Hn4ZN2pelaplaHfGNfRvRzOG6JWuwTkFmRiw6ZsFwagld15FHzPpliHLESOflaJLZvuDMt3x5oiSWgQClfbYsFw0WspwcqOceQRmbp)vWmKdgNfnSOhlGZ6bnfmhaXSOHLESGWN3TuKjaleqaPmiHJxbwssyjaHkqOUYeGfciGu(2Omo6N)WMHCW4SKKWIESeGiOYRZupQTl3CIL(SKKWcoIuQ85dk6Wg85t7hIfGYspw6XcWHfail9yXA1AgkO(imLvRYhZkIfGNfGWsFw6ZcWZspw0IfGXY5kQoZP7RChewydvULIazPpl9zrdl6XcfuFeMmyOYNCri)yjjHLESqb1hHjZxzmu5dljjS0JfkO(imz(kBbVnwssyHcQpctMVYQv5dl9zrdl6XY5kQodgUuzylFBuUbhcFgQClfbYssclwRwZenFhCaFxL9j41hYrlf2hdcxTiwsvBwacAsNL(SOHLESGJiLkF(GIoSbF(0(HybOSOv6Sa8S0JfTybySCUIQZC6(k3bHf2qLBPiqw6ZsFw0WIJVXv5iOoAyjvwqt6SaazXA1Ag85tZvkZqD(xywaEwaoS0NfnS0Jf9yXA1Aga)cCiWm1fb1rthvxMkAq9PGmRiwssyHcQpctMVYyOYhwssyrpwcqeu51zam(8EXsFw0WIESyTAnZ4iOcUW52qvkINXF1wQ8wC8rZ7MvK9oiHdZhDpSS3bqqTHWBSaGccR2pelFJfKLsKOVvGLhZYqoyC0YYTrdXIpelkcJz528If0WY5dk6WS8fl6ZQ8Hf0pO(imXIU)2yzhEXg0YIIWywUnVyrR0zbEB0O7XelFXIxXzb9dQpctSahwwrSCqwqdlNpOOdZIf1GdXIZI(SkFyb9dQpctgwITWcDhld1gcVXc4A(cfliL(cCiqwq)UiOoA6O6yzvkcJz5lw2HkFyb9dQpct2NDS0kM263ENk3srG2XWE3d3dl79gCcug2YLFRHS3bjCy(O7HL9ESJjwInWyXcSyjaYIU)2GRJLGhf9fk79W8hnVBV7r5Wgfa0(SJLwONT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr276Xc4SEqtbZbqmlAybHpVBPitamhGf4FpSyrdl9yPhlwRwZGpFAUszwrSKKWY5kQod(iLYNm48TZqLBPiqwssyjarqLxNPEuBxU5el9zrdl9yrpwSwTMbdv47dKzfXIgw0JfRvRzcE(RGzfXIgw6XIESCUIQZ0wt8mSLj1QidvULIazjjHfRvRzcE(RGbCn(9WILuzjaHkqOUY0wt8mSLj1QiZqD(xywaglaew6ZIgwq4Z7wkYCBZRuzmrastwN)hlAyPhl6XsaIGkVot9O2UCZjwssyjaHkqOUYeGfciGu(2Omo6N)WMvelAyPhlwRwZGpFAUszgQZ)cZcqzbiSKKWIESCUIQZGpsP8jdoF7mu5wkcKL(S0NfnSC(GIoZ9Du(GzWNyjvwSwTMj45VcgW143dlwaEws3aWyPpljjS0EuBxEOo)lmlaLfRvRzcE(RGbCn(9WIL(27i8jxEhzVhaZbyb(3dRSdj7ZowAHgB9BVtLBPiq7yyV7H7HL9EGue(ExLD1JQ6O6S3bjCy(O7HL9ESJjwqwkrI(wbwGflbqwwLIWyw8cKf1xel)XYkIfD)TXcYGfciGK9Ey(JM3T3r4Z7wkYeaZbyb(3dRSdj7ZowAbCS1V9ovULIaTJH9Ey(JM3T3r4Z7wkYeaZbyb(3dRSdj7DpCpSS3)k4t53dl7ZowAbWS1V9ovULIaTJH9UhUhw27uxeuhnzlybAVds4W8r3dl79yhtSG(DrqD0WsmGfilWILail6(BJL9ZNMRuSSIyXlqwWocILgCybaVuyFyXlqwqwkrI(wb79W8hnVBV)1rteu5hbMBpQTlpuN)fMfGYIwOHLKew6XI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlIfGYcqqt6SKKWI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlILu1MfGGM0zPplAyXA1Ag85tZvkZkIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWc4SEqtbZbqml9Tp7yPfaXw)27u5wkc0og27E4EyzVJpsP8j3u(q27H4bfLpFqrh2owAzVhM)O5D79HAdH3ClfXIgwUVJYhmd(elPYIwOHfnSGJiLkF(GIoSbF(0(HybOSGESOHfpkh2OaGSOHLESyTAntWZFfmd15FHzjvw0kDwssyrpwSwTMj45VcMvel9T3bjCy(O7HL9oacQneEJLMYhIfyXYkILdYsmz58bfDyw093gCDSGSuIe9TcSyrFHIf3cUowoileYJ(HyXlqwk4Xcebnbpk6lu2NDS0cGARF7DQClfbAhd7DpCpSS3BRjEg2YKAvK9oiHdZhDpSS3JDmXsSbI(S8nw(c)GelEXc6huFeMyXlqwuFrS8hlRiw093glola4Lc7dlrdmWIxGSKsqp6Eeel768PZEpm)rZ727uq9ryY8v2R4SOHfpkh2OaGSOHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaLfGGM0zrdl9ybeEgh0JUhbLX68Pld6DokYCFaWVqXsscl6XsaIGkVotrHbQGdiljjSGJiLkF(GIomlPYcqyPplAyPhlwRwZmocQGlCUnuLI4MH68VWSauwaOSaazPhlOHfGNLzvudoOid(R2sL3IJpAE3qLBPiqw6ZIgwSwTMzCeubx4CBOkfXnRiwssyrpwSwTMzCeubx4CBOkfXnRiw6ZIgw6XIESeGqfiuxzcE(RGzfXssclwRwZCBZRuzmrasJbFEaqwaklAHgw0Ws7rTD5H68VWSauwas6PZIgwApQTlpuN)fMLuzrR0tNLKew0JfmCPS(c0CBZRuzmrasJHk3srGS0NfnS0JfmCPS(c0CBZRuzmrasJHk3srGSKKWsacvGqDLj45VcMH68VWSKklXmDw6BF2XciPBRF7DQClfbAhd7DpCpSS3XNpnxPS3bjCy(O7HL9ESJjwCw2pFAUsXca6IUnwIgyGLvPimML9ZNMRuS8ywC1qoyCwwrSahwIdxS4dXIBbxhlhKficAcEelPedGT3dZF08U9U1Q1mWIUnCoIMafDpSmRiw0WspwSwTMbF(0CLYmuBi8MBPiwssyXX34QCeuhnSKkla00zPV9zhlGOLT(T3PYTueODmS39W9WYEhF(0CLYEhKWH5JUhw27X2vxelPedGzXIAWHybzWcbeqIfD)TXY(5tZvkw8cKLBJkw2pFWRbfzVhM)O5D79aebvEDM6rTD5MtSOHf9y5CfvNbFKs5tgC(2zOYTueilAyPhli85DlfzcWcbeqkds44vGLKewcqOceQRmbp)vWSIyjjHfRvRzcE(RGzfXsFw0WsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbOSGkaA6CKZcWZsGEfl9yXX34QCeuhnSGewqt6S0NfnSyTAnd(8P5kLzOo)lmlaLf0JfnSOhlGZ6bnfmhaX2NDSacqS1V9ovULIaTJH9Ey(JM3T3dqeu51zQh12LBoXIgw6XccFE3srMaSqabKYGeoEfyjjHLaeQaH6ktWZFfmRiwssyXA1AMGN)kywrS0NfnSeGqfiuxzcWcbeqkFBugh9ZFyZqD(xywaklahw0WI1Q1m4ZNMRuMvelAyHcQpctMVYEfNfnSOhli85DlfzEufCOm(8bVguelAyrpwaN1dAkyoaIT39W9WYEhF(GxdkY(SJfqIPT(T3PYTueODmS39W9WYEhF(GxdkYEhKWH5JUhw27XoMyz)8bVguel6(BJfVybaDr3glrdmWcCy5BSehUqhilqe0e8iwsjgaZIU)2yjoCnSueYpwco(mSKsfgYc4QlILuIbWS4hl3gXcvGSaBSCBelair1TfFyXA1AS8nw2pFAUsXIo4sbwO7yP5kflWwJf4WsC4IfFiwGflaHLZhu0HT3dZF08U9U1Q1mWIUnCoOiFYiE8dlZkILKew6XIESGpFA)qgpkh2OaGSOHf9ybHpVBPiZJQGdLXNp41GIyjjHLESyTAntWZFfmd15FHzbOSGgw0WI1Q1mbp)vWSIyjjHLES0JfRvRzcE(RGzOo)lmlaLfubqtNJCwaEwc0RyPhlo(gxLJG6OHfKWsmtNL(SOHfRvRzcE(RGzfXssclwRwZmocQGlCUnuLI4z8xTLkVfhF08UzOo)lmlaLfubqtNJCwaEwc0RyPhlo(gxLJG6OHfKWsmtNL(SOHfRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SIyPplAyjarqLxNbbv3w8HL(S0NfnS0JfCePu5Zhu0Hn4ZNMRuSauwIjljjSGWN3TuKbF(0CLkRdwxU5kvg2AS0NL(SOHf9ybHpVBPiZJQGdLXNp41GIyrdl9yrpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazjjHfCePu5Zhu0Hn4ZNMRuSauwIjl9Tp7ybe0Zw)27u5wkc0og27E4EyzVxKUChew27GeomF09WYEp2XelaOGWcZYxSSdv(Wc6huFeMyXlqwWocILyZsPybafewS0GdlilLirFRG9Ey(JM3T37XI1Q1muq9rykJHkFmd15FHzjvwiKtH1r577iwssyPhlHnFqryw0MfGWIgwgkS5dkkFFhXcqzbnS0NLKewcB(GIWSOnlXKL(SOHfpkh2OaG2NDSacAS1V9ovULIaTJH9Ey(JM3T37XI1Q1muq9rykJHkFmd15FHzjvwiKtH1r577iwssyPhlHnFqryw0MfGWIgwgkS5dkkFFhXcqzbnS0NLKewcB(GIWSOnlXKL(SOHfpkh2OaGSOHLESyTAnZ4iOcUW52qvkIBgQZ)cZcqzbnSOHfRvRzghbvWfo3gQsrCZkIfnSOhlZQOgCqrg8xTLkVfhF08UHk3srGSKKWIESyTAnZ4iOcUW52qvkIBwrS03E3d3dl79nx1YDqyzF2XciahB9BVtLBPiq7yyVhM)O5D79ESyTAndfuFeMYyOYhZqD(xywsLfc5uyDu((oIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWsacvGqDLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NLKew6XsyZhueMfTzbiSOHLHcB(GIY33rSauwqdl9zjjHLWMpOimlAZsmzPplAyXJYHnkailAyPhlwRwZmocQGlCUnuLI4MH68VWSauwqdlAyXA1AMXrqfCHZTHQue3SIyrdl6XYSkQbhuKb)vBPYBXXhnVBOYTueiljjSOhlwRwZmocQGlCUnuLI4Mvel9T39W9WYEVTuQChew2NDSacaZw)27u5wkc0og27GeomF09WYEp2Xelifq0NfyXcYIT27E4EyzVRZN5Htg2YKAvK9zhlGaqS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYEhhrkv(8bfDyd(8P9dXsQSGESamwAkiCyPhlDo(OjEgHRwelaplALE6SGewas6S0NfGXstbHdl9yXA1Ag85dEnOOm1fb1rthvxgdv(yWNhaKfKWc6XsF7DqchMp6EyzVJmxfwk)iml62OBJgwoillmXY(5t7hILVyzhQ8HfDBFyJLhZIFSGgwoFqrhgyAXsdoSqiOjolajDKklDo(OjolWHf0JL9Zh8AqrSG(DrqD00r1Xc(8aGy7De(KlVJS3XNpTFO8xzmu5J9zhlGaqT1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYExlwqcl4isPYBo(iwaklaHfail9yjDdqyb4zPhl4isPYNpOOdBWNpTFiwaGSOfl9zb4zPhlAXcWy5CfvNbdxQmSLVnk3GdHpdvULIazb4zrldAyPpl9zbySKUrl0WcWZI1Q1mJJGk4cNBdvPiUzOo)lS9oiHdZhDpSS3rMRclLFeMfDB0TrdlhKfKIXVnwaxZxOyj2muLI427i8jxEhzVRB8Bl)vUnuLI42NDSIz6263ENk3srG2XWE3d3dl7DDJFB27GeomF09WYEp2XelifJFBS8fl7qLpSG(b1hHjwGdlFJLcYY(5t7hIfDVsXs7pw(6GSGSuIe9TcS4v8o4q27H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY4v8Cri)yrdli85DlfzECoOihbXsFw0WspwoFqrN5(okFWm4tSKklOhljjSqb1hHjJAv(K)kdewssyP9O2U8qD(xywaklALol9zjjHfRvRzOG6JWugdv(ygQZ)cZcqzXd3dld(8P9dziKtH1r577iw0WI1Q1muq9rykJHkFmRiwssyHcQpctMVYyOYhw0WIESGWN3TuKbF(0(HYFLXqLpSKKWI1Q1mbp)vWmuN)fMfGYIhUhwg85t7hYqiNcRJY33rSOHf9ybHpVBPiZJZbf5iiw0WI1Q1mbp)vWmuN)fMfGYcHCkSokFFhXIgwSwTMj45VcMveljjSyTAnZ4iOcUW52qvkIBwrSOHfe(8ULIm6g)2YFLBdvPioljjSOhli85DlfzECoOihbXIgwSwTMj45VcMH68VWSKkleYPW6O89DK9zhRyQLT(T3PYTueODmS3bjCy(O7HL9ESJjw2pFA)qS8nw(If9zv(Wc6huFeMqllFXYou5dlOFq9ryIfyXc6bmwoFqrhMf4WYbzjAGbw2HkFyb9dQpct27E4EyzVJpFA)q2NDSIjqS1V9ovULIaTJH9oiHdZhDpSS3JnUsDBZYE3d3dl79zvzpCpSYQhF27QhF5Y7i79MRu32SSp7ZEV5k1TnlB9BhlTS1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEF)8bVgueln4Wsheb1r1XYQuegZYc)fkwIbmL63Epm)rZ7276XYSkQbhuKXYvEfOmSLDLkFBFHcBiG76JIiq7ZowaXw)27u5wkc0og27E4EyzVJxv7hYEpepOO85dk6W2Xsl79W8hnVBVdcpthewTFiZqD(xywsLLH68VWSa8SaeGWcsyrlaI9oiHdZhDpSS3rMJpwUnIfq4XIU)2y52iw6G4JL77iwoiloiilR6Efl3gXsNJCwaxJFpSy5XSS9NHL9v1(HyzOo)lmlDl19rQNaz5GS05xyJLoiSA)qSaUg)EyzF2XkM263E3d3dl79oiSA)q27u5wkc0og2N9zVJpB9BhlTS1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEp2Xel7Np41GIy5GSairrSSIy52iwITd5DwFbsdlwRwJLVXYFSOdUuGSqip6hIflQbhIL2xpE7luSCBelfH8JLGJpwGdlhKfWvxelwudoelidwiGas27H5pAE3EFwf1GdkYCFhPdovgCiVZ6lqAmu5wkcKfnS0JfkO(imz(k7vCw0WIES0JLESyTAnZ9DKo4uzWH8oRVaPXmuN)fMLuzXd3dlJUXVndHCkSokFFhXcWyjDJwSOHLESqb1hHjZxzl4TXsscluq9ryY8vgdv(Wsscluq9ryYOwLp5Iq(XsFwssyXA1AM77iDWPYGd5DwFbsJzOo)lmlPYIhUhwg85t7hYqiNcRJY33rSamws3OflAyPhluq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yPpl9zjjHf9yXA1AM77iDWPYGd5DwFbsJzfXsFwssyPhlwRwZe88xbZkILKewq4Z7wkYeGfciGugKWXRal9zrdlbiubc1vMaSqabKY3gLXr)8h2mKdgNfnSeGiOYRZupQTl3CIL(SOHLESOhlbicQ86magFEVyjjHLaeQaH6kd1fb1rt2cwGMH68VWSKklaew6ZIgw6XI1Q1mbp)vWSIyjjHf9yjaHkqOUYe88xbZqoyCw6BF2Xci263ENk3srG2XWE3d3dl7Dh0JUhbLX68PZEpepOO85dk6W2Xsl79W8hnVBVRhlGWZ4GE09iOmwNpDzqVZrrM7da(fkw0WIES4H7HLXb9O7rqzSoF6YGENJImFLBQh12XIgw6XIESacpJd6r3JGYyD(0L3ixzUpa4xOyjjHfq4zCqp6EeugRZNU8g5kZqD(xywsLf0WsFwssybeEgh0JUhbLX68Pld6DokYGppailaLLyYIgwaHNXb9O7rqzSoF6YGENJImd15FHzbOSetw0Wci8moOhDpckJ15txg07CuK5(aGFHYEhKWH5JUhw27XoMyjLGE09iiw215thl62OILBJgILhZsbzXd3JGybRZNo0YIJzr5hXIJzjcIXVLIybwSG15thl6(BJfGWcCyPr6OHf85baXSahwGflolXeySG15thlyil3MFSCBelfPJfSoF6yXN5rqywaqEHpw82rdl3MFSG15thleYJ(HW2NDSIPT(T3PYTueODmS39W9WYEpaleqaP8TrzC0p)HT3bjCy(O7HL9ESJjmlidwiGasS8nwqwkrI(wbwEmlRiwGdlXHlw8HybKWXRWxOybzPej6Bfyr3FBSGmyHaciXIxGSehUyXhIflsb1Xc6LolPedGT3dZF08U9UESaoRh0uWCaeZIgw6Xspwq4Z7wkYeGfciGugKWXRalAyrpwcqOceQRmbp)vWmKdgNfnSOhlZQOgCqrMO57Gd47QSpbV(qoAPW(yOYTueiljjSyTAntWZFfmRiw6ZIgwC8nUkhb1rdlavBwqV0zrdl9yXA1AgkO(imLvRYhZqD(xywsLfTsNLKewSwTMHcQpctzmu5JzOo)lmlPYIwPZsFwssyP9O2U8qD(xywaklALolAyrpwcqOceQRmbp)vWmKdgNL(2NDSqpB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS37XI1Q1mJJGk4cNBdvPiUzOo)lmlPYcAyjjHf9yXA1AMXrqfCHZTHQue3SIyPplAyrpwSwTMzCeubx4CBOkfXZ4VAlvElo(O5DZkIfnS0JfRvRza8lWHaZuxeuhnDuDzQOb1NcYmuN)fMfGYcQaOPZrol9zrdl9yXA1AgkO(imLXqLpMH68VWSKklOcGMoh5SKKWI1Q1muq9rykRwLpMH68VWSKklOcGMoh5SKKWspw0JfRvRzOG6JWuwTkFmRiwssyrpwSwTMHcQpctzmu5JzfXsFw0WIESCUIQZGHk89bYqLBPiqw6BVds4W8r3dl7DKblW)EyXsdoS4kflGWdZYT5hlDoGeMf8AiwUnkol(qf6owgQneEJazr3gvSaGWrqfCHzj2muLI4SS5ywuegZYT5flOHfmfWSmuN)1xOyboSCBelagFEVyXA1AS8ywCl46y5GS0CLIfyRXcCyXR4SG(b1hHjwEmlUfCDSCqwiKh9dzVJWNC5DK9oi8YdbCx)qDuDy7ZowOXw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi79ESOhlwRwZqb1hHPmgQ8XSIyrdl6XI1Q1muq9rykRwLpMvel9zjjHLZvuDgmuHVpqgQClfbAVds4W8r3dl7DKblW)EyXYT5hlHnkaiMLVXsC4IfFiwGRd)Geluq9ryILdYcSuXzbeESCB0qSahwEufCiwUThZIU)2yzhQW3hi7De(KlVJS3bHxgUo8dszkO(imzF2Xc4yRF7DQClfbAhd7DpCpSS37GWQ9dzVhM)O5D79HAdH3ClfXIgw6XI1Q1muq9rykJHkFmd15FHzjvwgQZ)cZssclwRwZqb1hHPSAv(ygQZ)cZsQSmuN)fMLKewq4Z7wkYacVmCD4hKYuq9ryIL(SOHLHAdH3ClfXIgwoFqrN5(okFWm4tSKklAbew0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2owAzF2XcGzRF7DQClfbAhd7DpCpSS3XRQ9dzVhM)O5D79HAdH3ClfXIgw6XI1Q1muq9rykJHkFmd15FHzjvwgQZ)cZssclwRwZqb1hHPSAv(ygQZ)cZsQSmuN)fMLKewq4Z7wkYacVmCD4hKYuq9ryIL(SOHLHAdH3ClfXIgwoFqrN5(okFWm4tSKklAbew0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2owAzF2XcGyRF7DQClfbAhd7DpCpSS3XhPu(KBkFi79W8hnVBVpuBi8MBPiw0WspwSwTMHcQpctzmu5JzOo)lmlPYYqD(xywssyXA1AgkO(imLvRYhZqD(xywsLLH68VWSKKWccFE3srgq4LHRd)GuMcQpctS0NfnSmuBi8MBPiw0WY5dk6m33r5dMbFILuzrlGdlAyXJYHnkailAybHpVBPidi8YdbCx)qDuDy79q8GIYNpOOdBhlTSp7ybqT1V9ovULIaTJH9UhUhw27n4eOmSLl)wdzVds4W8r3dl79yhtSeBGXIfyXsaKfD)Tbxhlbpk6lu27H5pAE3E3JYHnkaO9zhlTs3w)27u5wkc0og27E4EyzVtDrqD0KTGfO9oiHdZhDpSS3JDmXcsPVahcKL9OF(dZIU)2yXR4SOGfkwOcUqTXIYX3xOyb9dQpctS4fil3eNLdYI6lIL)yzfXIU)2ybaVuyFyXlqwqwkrI(wb79W8hnVBV3JLESyTAndfuFeMYyOYhZqD(xywsLfTsNLKewSwTMHcQpctz1Q8XmuN)fMLuzrR0zPplAyjaHkqOUYe88xbZqD(xywsLLyMolAyPhlwRwZenFhCaFxL9j41hYrlf2hdcxTiwaklab9sNLKew0JLzvudoOit08DWb8Dv2NGxFihTuyFmeWD9rreil9zPpljjSyTAnt08DWb8Dv2NGxFihTuyFmiC1IyjvTzbiaS0zjjHLaeQaH6ktWZFfmd5GXzrdlo(gxLJG6OHLuzbGMU9zhlT0Yw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9ybCwpOPG5aiMfnSGWN3TuKjaMdWc8VhwSOHLES0JLaeQaH6kd1ffFixLHdy5vGmd15FHzbOSOfWbGXcWyPhlAPflaplZQOgCqrg8xTLkVfhF08UHk3srGS0NfnSqa31hfrGgQlk(qUkdhWYRaXsFwssyXX34QCeuhnSKQ2SaqtNfnS0Jf9y5CfvNPTM4zyltQvrgQClfbYssclwRwZe88xbd4A87HflPYsacvGqDLPTM4zyltQvrMH68VWSamwaiS0NfnSGWN3TuK52MxPYyIaKMSo)pw0WspwSwTMbWVahcmtDrqD00r1LPIguFkiZkILKew0JLaebvEDgaJpVxS0NfnSC(GIoZ9Du(GzWNyjvwSwTMj45VcgW143dlwaEws3aWyjjHL2JA7Yd15FHzbOSyTAntWZFfmGRXVhwSKKWsaIGkVot9O2UCZjwssyXA1AglfecQw4ZSIyrdlwRwZyPGqq1cFMH68VWSauwSwTMj45VcgW143dlwagl9ybGYcWZYSkQbhuKjA(o4a(Uk7tWRpKJwkSpgc4U(OicKL(S0NfnSOhlwRwZe88xbZkIfnS0Jf9yjarqLxNPEuBxU5eljjSeGqfiuxzcWcbeqkFBugh9ZFyZkILKewApQTlpuN)fMfGYsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbySaCyjjHL2JA7Yd15FHzbPYIwaK0zbOSyTAntWZFfmGRXVhwS03EhKWH5JUhw27XoMybzPej6Bfyr3FBSGmyHaciHeKsFboeil7r)8hMfVazbewO7ybIGgDZFela4Lc7dlWHfDBuXsmuqiOAHpw0bxkqwiKh9dXIf1GdXcYsjs03kWcH8OFiS9ocFYL3r27bWCawG)9WkJp7ZowAbeB9BVtLBPiq7yyV7H7HL9(4iOcUW52qvkIBVds4W8r3dl79yhtSCBelair1TfFyr3FBS4SGSuIe9TcSCB(XYJl0DS0gyhla4Lc7J9Ey(JM3T3TwTMj45VcMH68VWSKklAHgwssyXA1AMGN)kyaxJFpSybOSeZ0zrdli85DlfzcG5aSa)7HvgF2NDS0kM263ENk3srG2XWEpm)rZ727i85DlfzcG5aSa)7HvgFSOHLESOhlwRwZe88xbd4A87HflPYsmtNLKew0JLaebvEDgeuDBXhw6ZssclwRwZmocQGlCUnuLI4MvelAyXA1AMXrqfCHZTHQue3muN)fMfGYcaLfGXsawGR)mrdfEmLD1JQ6O6m33rzeUArSamw6XIESyTAnJLccbvl8zwrSOHf9y5CfvNbF(OGdOHk3srGS03E3d3dl79aPi89Uk7Qhv1r1zF2Xsl0Zw)27u5wkc0og27H5pAE3EhHpVBPitamhGf4FpSY4ZE3d3dl79Vc(u(9WY(SJLwOXw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9yjaHkqOUYe88xbZqoyCwssyrpwq4Z7wkYeGfciGugKWXRalAyjarqLxNPEuBxU5eljjSaoRh0uWCaeBVds4W8r3dl7DaK85DlfXYctGSalwCRx93tywUn)yrNxhlhKflIfSJGazPbhwqwkrI(wbwWqwUn)y52O4S4dvhl6C8rGSaG8cFSyrn4qSCBuN9ocFYL3r27yhbLBWjh88xb7ZowAbCS1V9ovULIaTJH9UhUhw27T1epdBzsTkYEhKWH5JUhw27XoMWSeBGOplFJLVyXlwq)G6JWelEbYYnpHz5GSO(Iy5pwwrSO7VnwaWlf2h0YcYsjs03kWIxGSKsqp6Eeel768PZEpm)rZ727uq9ryY8v2R4SOHfpkh2OaGSOHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaLfGGEPZIgw6Xci8moOhDpckJ15txg07CuK5(aGFHILKew0JLaebvEDMIcdubhqw6ZIgwq4Z7wkYGDeuUbNCWZFfyrdl9yXA1AMXrqfCHZTHQue3muN)fMfGYcaLfail9ybnSa8SmRIAWbfzWF1wQ8wC8rZ7gQClfbYsFw0WI1Q1mJJGk4cNBdvPiUzfXsscl6XI1Q1mJJGk4cNBdvPiUzfXsF7ZowAbWS1V9ovULIaTJH9UhUhw274ZNMRu27GeomF09WYEp2XelaOl62yz)8P5kflrdmGz5BSSF(0CLILhxO7yzfzVhM)O5D7DRvRzGfDB4Cenbk6EyzwrSOHfRvRzWNpnxPmd1gcV5wkY(SJLwaeB9BVtLBPiq7yyVhM)O5D7DRvRzWNpk4aAgQZ)cZcqzbnSOHLESyTAndfuFeMYyOYhZqD(xywsLf0WssclwRwZqb1hHPSAv(ygQZ)cZsQSGgw6ZIgwC8nUkhb1rdlPYcanD7DpCpSS3dEfiv2A1A27wRwlxEhzVJpFuWb0(SJLwauB9BVtLBPiq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JTRUimlPedGzXIAWHybzWcbeqILf(luSCBelidwiGasSeGf4FpSy5GSe2OaGS8nwqgSqabKy5XS4HB5kvCwCl46y5GSyrSeC8zVhM)O5D79aebvEDM6rTD5MtSOHfe(8ULImbyHaciLbjC8kWIgwcqOceQRmbyHaciLVnkJJ(5pSzOo)lmlaLf0WIgw0JfWz9GMcMdGyw0WcfuFeMmFL9kolAyXX34QCeuhnSKklOx62NDSas6263ENk3srG2XWE3d3dl7D85tZvk7DqchMp6EyzVh7yIL9ZNMRuSO7Vnw2psP8HLy78TJfVazPGSSF(OGdiAzr3gvSuqw2pFAUsXYJzzfHwwIdxS4dXYxSOpRYhwq)G6JWeln4WcabyykGzboSCqwIgyGfa8sH9HfDBuXIBbrqSaqtNLuIbWSahwCWi)EeelyD(0XYMJzbGammfWSmuN)1xOyboS8yw(ILM6rTDgwIf8iwUn)yzvG0WYTrSG9oILaSa)7HfML)qhMfWimlfTUXvSCqw2pFAUsXc4A(cflaiCeubxywIndvPioAzr3gvSehUqhil47vkwOcKLvel6(BJfaA6aZXrS0Gdl3gXIYXhlOuqlxHn27H5pAE3E)CfvNbFKs5tgC(2zOYTueilAyrpwoxr1zWNpk4aAOYTueilAyXA1Ag85tZvkZqTHWBULIyrdl9yXA1AgkO(imLvRYhZqD(xywsLfaclAyHcQpctMVYQv5dlAyXA1AMO57Gd47QSpbV(qoAPW(yq4QfXcqzbiOjDwssyXA1AMO57Gd47QSpbV(qoAPW(yq4QfXsQAZcqqt6SOHfhFJRYrqD0WsQSaqtNLKewaHNXb9O7rqzSoF6YGENJImd15FHzjvwaiSKKWIhUhwgh0JUhbLX68Pld6DokY8vUPEuBhl9zrdlbiubc1vMGN)kygQZ)cZsQSOv62NDSaIw263ENk3srG2XWE3d3dl7D85dEnOi7DqchMp6EyzVh7yIL9Zh8AqrSaGUOBJLObgWS4filGRUiwsjgaZIUnQybzPej6BfyboSCBelair1TfFyXA1AS8ywCl46y5GS0CLIfyRXcCyjoCHoqwcEelPedGT3dZF08U9U1Q1mWIUnCoOiFYiE8dlZkILKewSwTMbWVahcmtDrqD00r1LPIguFkiZkILKewSwTMj45VcMvelAyPhlwRwZmocQGlCUnuLI4MH68VWSauwqfanDoYzb4zjqVILES44BCvocQJgwqclXmDw6ZcWyjMSa8SCUIQZuKUChewgQClfbYIgw0JLzvudoOid(R2sL3IJpAE3qLBPiqw0WI1Q1mJJGk4cNBdvPiUzfXssclwRwZe88xbZqD(xywaklOcGMoh5Sa8SeOxXspwC8nUkhb1rdliHLyMol9zjjHfRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SIyjjHf9yXA1AMXrqfCHZTHQue3SIyrdl6XsacvGqDLzCeubx4CBOkfXnd5GXzjjHf9yjarqLxNbbv3w8HL(SKKWIJVXv5iOoAyjvwaOPZIgwOG6JWK5RSxXTp7ybeGyRF7DQClfbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9U(N4SCqw6CajwUnIflcFSaBSSF(OGdilwXzbFEaWVqXYFSSIyb4U(aGQ4S8flEfNf0pO(imXI16ybaVuyFy5X1XIBbxhlhKflILObgceO9Ey(JM3T3pxr1zWNpk4aAOYTueilAyrpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazrdl9yXA1Ag85JcoGMveljjS44BCvocQJgwsLfaA6S0NfnSyTAnd(8rbhqd(8aGSauwIjlAyPhlwRwZqb1hHPmgQ8XSIyjjHfRvRzOG6JWuwTkFmRiw6ZIgwSwTMjA(o4a(Uk7tWRpKJwkSpgeUArSauwacalDw0WspwcqOceQRmbp)vWmuN)fMLuzrR0zjjHf9ybHpVBPitawiGaszqchVcSOHLaebvEDM6rTD5MtS03(SJfqIPT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr27uq9ryY8vwTkFyb4zbGWcsyXd3dld(8P9dziKtH1r577iwagl6XcfuFeMmFLvRYhwaEw6XcWHfGXY5kQodgUuzylFBuUbhcFgQClfbYcWZsmzPpliHfpCpSm6g)2meYPW6O89DelaJL0nOhAybjSGJiLkV54JybySKUbnSa8SCUIQZu(TgcNTCLxbYqLBPiq7DqchMp6EyzVJ(4778JWSSb1Xs3kSXskXayw8HybL)fbYsenSGPaSaT3r4tU8oYE3XrayA2PG9zhlGGE263ENk3srG2XWE3d3dl7D85dEnOi7DqchMp6EyzVhBxDrSSF(GxdkILVyXzbGbmmfyzhQ8Hf0pO(imHwwaHf6owu0XYFSenWala4Lc7dl9Un)y5XSS5fOIazXkol0FB0WYTrSSF(0CLIf1xelWHLBJyjLyaCQa00zr9fXsdoSSF(GxdkQpAzbewO7ybIGgDZFelEXca6IUnwIgyGfVazrrhl3gXIBbrqSO(IyzZlqfXY(5JcoG27H5pAE3ExpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazrdl9yXA1AMO57Gd47QSpbV(qoAPW(yq4QfXcqzbiaS0zjjHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaLfGGM0zrdlNRO6m4JukFYGZ3odvULIazPplAyPhluq9ryY8vgdv(WIgwC8nUkhb1rdlaJfe(8ULImoocatZofyb4zXA1AgkO(imLXqLpMH68VWSamwaHNPTM4zyltQvrM7daIZd15FXcWZcqmOHLuzbGKoljjSqb1hHjZxz1Q8HfnS44BCvocQJgwagli85DlfzCCeaMMDkWcWZI1Q1muq9rykRwLpMH68VWSamwaHNPTM4zyltQvrM7daIZd15FXcWZcqmOHLuzbGMol9zrdl6XI1Q1mWIUnCoIMafDpSmRiw0WIESCUIQZGpFuWb0qLBPiqw0WspwcqOceQRmbp)vWmuN)fMLuzbGXsscly4sz9fO52MxPYyIaKgdvULIazrdlwRwZCBZRuzmrasJbFEaqwaklXmMSaazPhlZQOgCqrg8xTLkVfhF08UHk3srGSa8SGgw6ZIgwApQTlpuN)fMLuzrR0tNfnS0EuBxEOo)lmlaLfGKE6S0NfnS0JLaeQaH6kdGFboeygh9ZFyZqD(xywsLfagljjSOhlbicQ86magFEVyPV9zhlGGgB9BVtLBPiq7yyV7H7HL9Er6YDqyzVds4W8r3dl79yhtSaGcclmlFXI(SkFyb9dQpctS4filyhbXcszCvdyXMLsXcakiSyPbhwqwkrI(wbw8cKfKsFboeilOFxeuhnDuD27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSKKWspwcB(GIWSOnlaHfnSmuyZhuu((oIfGYcAyPpljjSe28bfHzrBwIjl9zrdlEuoSrbazrdli85DlfzWock3Gto45Vc2NDSacWXw)27u5wkc0og27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSOHf9yjarqLxNbW4Z7fljjS0JfRvRza8lWHaZuxeuhnDuDzQOb1NcYSIyrdlbicQ86magFEVyPpljjS0JLWMpOimlAZcqyrdldf28bfLVVJybOSGgw6ZssclHnFqryw0MLyYssclwRwZe88xbZkIL(SOHfpkh2OaGSOHfe(8ULImyhbLBWjh88xbw0WspwSwTMzCeubx4CBOkfXnd15FHzbOS0Jf0WcaKfGWcWZYSkQbhuKb)vBPYBXXhnVBOYTueil9zrdlwRwZmocQGlCUnuLI4MveljjSOhlwRwZmocQGlCUnuLI4Mvel9T39W9WYEFZvTChew2NDSacaZw)27u5wkc0og27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSOHf9yjarqLxNbW4Z7fljjS0JfRvRza8lWHaZuxeuhnDuDzQOb1NcYSIyrdlbicQ86magFEVyPpljjS0JLWMpOimlAZcqyrdldf28bfLVVJybOSGgw6ZssclHnFqryw0MLyYssclwRwZe88xbZkIL(SOHfpkh2OaGSOHfe(8ULImyhbLBWjh88xbw0WspwSwTMzCeubx4CBOkfXnd15FHzbOSGgw0WI1Q1mJJGk4cNBdvPiUzfXIgw0JLzvudoOid(R2sL3IJpAE3qLBPiqwssyrpwSwTMzCeubx4CBOkfXnRiw6BV7H7HL9EBPu5oiSSp7ybeaIT(T3PYTueODmS3bjCy(O7HL9ESJjwqkGOplWILaO9UhUhw2768zE4KHTmPwfzF2XciauB9BVtLBPiq7yyV7H7HL9o(8P9dzVds4W8r3dl79yhtSSF(0(Hy5GSenWal7qLpSG(b1hHj0YcYsjs03kWYMJzrryml33rSCBEXIZcsX43gleYPW6iwuu7yboSalvCw0Nv5dlOFq9ryILhZYkYEpm)rZ727uq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yjjHLESyTAnJoFMhozyltQvrMveljjSGJiLkV54JybOSKUb9qdlAyrpwcqeu51zqq1TfFyjjHfCePu5nhFelaLL0nOhlAyjarqLxNbbv3w8HL(SOHfRvRzOG6JWuwTkFmRiwssyPhlwRwZe88xbZqD(xywaklE4Eyz0n(TziKtH1r577iw0WI1Q1mbp)vWSIyPV9zhRyMUT(T3PYTueODmS3bjCy(O7HL9ESJjwqkg)2ybEB0O7Xel62(WglpMLVyzhQ8Hf0pO(imHwwqwkrI(wbwGdlhKLObgyrFwLpSG(b1hHj7DpCpSS31n(TzF2XkMAzRF7DQClfbAhd7DqchMp6EyzVhBCL62ML9UhUhw27ZQYE4EyLvp(S3vp(YL3r27nxPUTzzF2N9E0qbyNLF263owAzRF7DpCpSS3b8lWHaZ4OF(dBVtLBPiq7yyF2Xci263ENk3srG2XWEhgzVJPZE3d3dl7De(8ULIS3r4QfzVNU9oiHdZhDpSS31)gXccFE3srS8ywW0XYbzjDw093glfKf85hlWILfMy5MVaKomAzrlw0Trfl3gXs7h8XcSiwEmlWILfMqllaHLVXYTrSGPaSaz5XS4filXKLVXIf82yXhYEhHp5Y7i7DyLxykFZxasN9zhRyARF7DQClfbAhd7DyK9UdcAV7H7HL9ocFE3sr27iC1IS31YEpm)rZ72738fG0zoTmBooVWu2A1ASOHLB(cq6mNwMaeQaH6kd4A87HflAyrpwU5laPZCAzES5GDug2YDWcFdCHZbyHVzfUhwy7De(KlVJS3HvEHP8nFbiD2NDSqpB9BVtLBPiq7yyVdJS3Dqq7DpCpSS3r4Z7wkYEhHRwK9oqS3dZF08U9(nFbiDMdiMnhNxykBTAnw0WYnFbiDMdiMaeQaH6kd4A87HflAyrpwU5laPZCaX8yZb7OmSL7Gf(g4cNdWcFZkCpSW27i8jxEhzVdR8ct5B(cq6Sp7yHgB9BVtLBPiq7yyVdJS3Dqq7DpCpSS3r4Z7wkYEhHp5Y7i7DyLxykFZxasN9Ey(JM3T3jG76JIiqZx4WSo3srzG7YRB1LbjeFGyjjHfc4U(Oic0qDrXhYvz4awEfiwssyHaURpkIany4sPO7(cvEwwXT3bjCy(O7HL9U(3imXYnFbiDyw8HyPGhl(6687dUsfNfq6OWrGS4ywGfllmXc(8JLB(cq6WgwsPsNhhZIdc(fkw0ILoYlml3gfNfDVsXIR05XXSyrSenuJMHaz5lqkIkqQowGnwWk4zVJWvlYExl7ZowahB9BV7H7HL9Ehewa(vUbNo7DQClfbAhd7ZowamB9BVtLBPiq7yyV7H7HL9UUXVn7D1xuoaAVRv627H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY8vgdv(Wsscluq9ryY8v2cEBSKKWcfuFeMmEfpxeYpw6BVds4W8r3dl7Da8qbhFSaewqkg)2yXlqwCw2pFWRbfXcSyzx)SO7VnwI1JA7yj24elEbYsmGPu)Sahw2pFA)qSaVnA09yY(SJfaXw)27u5wkc0og27H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY8vgdv(Wsscluq9ryY8v2cEBSKKWcfuFeMmEfpxeYpw6ZIgwIgcHrlJUXVnw0WIESenecdqm6g)2S39W9WYEx343M9zhlaQT(T3PYTueODmS3dZF08U9UESmRIAWbfzSCLxbkdBzxPY32xOWgQClfbYsscl6XsaIGkVot9O2UCZjwssyrpwWrKsLpFqrh2GpFAUsXI2SOfljjSOhlNRO6mLFRHWzlx5vGmu5wkcKLKew6XcfuFeMmyOYNCri)yjjHfkO(imz(kRwLpSKKWcfuFeMmFLTG3gljjSqb1hHjJxXZfH8JL(27E4EyzVJpFA)q2NDS0kDB9BVtLBPiq7yyVhM)O5D79zvudoOiJLR8kqzyl7kv(2(cf2qLBPiqw0WsaIGkVot9O2UCZjw0WcoIuQ85dk6Wg85tZvkw0MfTS39W9WYEhF(GxdkY(Sp7ZEhbn4hw2XciPdeTshGPfqS315t9fkS9osrkbqel9nwiLdWzHf9VrS8DrW5yPbhwqhi18L6qhldbCx)qGSGHDel(6GD(rGSe28cfHnCA6ZxelOhaNfKble0Ceil7FhYybhVoh5SGuz5GSOplNfWhXJFyXcmIg)Gdl9qsFw6PfY7B400NViwqpaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPPpFrSGgaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPPpFrSaCa4SGmyHGMJazz)7qgl4415iNfKklhKf9z5Sa(iE8dlwGr04hCyPhs6ZspGG8(gon95lIfagaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViwayaCwqgSqqZrGSGUB(cq6mAzaaOJLdYc6U5laPZCAzaaOJLEab59nCA6ZxelamaolidwiO5iqwq3nFbiDgGyaaOJLdYc6U5laPZCaXaaqhl9acY7B400NViwaiaCwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHttF(IybGcWzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gon95lIfTshGZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCA6ZxelAPfaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViw0ciaCwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHttF(IyrRycWzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEab59nCA6ZxelAftaolidwiO5iqwq3nFbiDgTmaa0XYbzbD38fG0zoTmaa0XspGG8(gon95lIfTIjaNfKble0CeilO7MVaKodqmaa0XYbzbD38fG0zoGyaaOJLEAH8(gon95lIfTqpaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0diiVVHttF(Iyrl0dGZcYGfcAocKf0DZxasNrldaaDSCqwq3nFbiDMtldaaDS0tlK33WPPpFrSOf6bWzbzWcbnhbYc6U5laPZaedaaDSCqwq3nFbiDMdigaa6yPhqqEFdNgNgsrkbqel9nwiLdWzHf9VrS8DrW5yPbhwqx0qbyNLFOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon95lILycWzbzWcbnhbYc6U5laPZOLbaGowoilO7MVaKoZPLbaGow6ftK33WPPpFrSGEaCwqgSqqZrGSGUB(cq6maXaaqhlhKf0DZxasN5aIbaGow6ftK33WPPpFrSaqb4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNM(8fXIwPdWzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gononKIucGiw6BSqkhGZcl6FJy57IGZXsdoSGohsOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon95lIfTa4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XIFSG(aO1hw6PfY7B400NViwIjaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViwaoaCwqgSqqZrGSS)DiJfC86CKZcsfPYYbzrFwolDqWLAHzbgrJFWHLEi1(S0tlK33WPPpFrSaCa4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspGG8(gon95lIfagaNfKble0Ceil7FhYybhVoh5SGurQSCqw0NLZsheCPwywGr04hCyPhsTpl90c59nCA6ZxelamaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPPpFrSaqa4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNM(8fXcafGZcYGfcAocKL9VdzSGJxNJCwqQSCqw0NLZc4J4XpSybgrJFWHLEiPpl9acY7B400NViw0ciaCwqgSqqZrGSS)DiJfC86CKZcsLLdYI(SCwaFep(HflWiA8doS0dj9zPNwiVVHttF(IyrlakaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViwaIwaCwqgSqqZrGSS)DiJfC86CKZcsLLdYI(SCwaFep(HflWiA8doS0dj9zPNwiVVHttF(IybiXeGZcYGfcAocKL9VdzSGJxNJCwqQSCqw0NLZc4J4XpSybgrJFWHLEiPpl9acY7B400NViwasmb4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNM(8fXcqqdaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViwacWbGZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCA6ZxelabGaWzbzWcbnhbYY(3HmwWXRZrolivwoil6ZYzb8r84hwSaJOXp4WspK0NLEab59nCA6ZxelabGcWzbzWcbnhbYY(3HmwWXRZrolivwoil6ZYzb8r84hwSaJOXp4WspK0NLEAH8(gononKIucGiw6BSqkhGZcl6FJy57IGZXsdoSGUMRu32SqhldbCx)qGSGHDel(6GD(rGSe28cfHnCA6ZxelabGZcYGfcAocKL9VdzSGJxNJCwqQSCqw0NLZc4J4XpSybgrJFWHLEiPpl90c59nCACAifPearS03yHuoaNfw0)gXY3fbNJLgCybD4dDSmeWD9dbYcg2rS4Rd25hbYsyZlue2WPPpFrSOfaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViwIjaNfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B400NViw0slaolidwiO5iqw2)oKXcoEDoYzbPIuz5GSOplNLoi4sTWSaJOXp4WspKAFw6PfY7B400NViw0slaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPPpFrSOfWbGZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCA6ZxelarlaolidwiO5iqw2)oKXcoEDoYzbPYYbzrFwolGpIh)WIfyen(bhw6HK(S0diiVVHttF(IybiAbWzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gon95lIfGaeaolidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPPpFrSaKycWzbzWcbnhbYY(3HmwWXRZrolivwoil6ZYzb8r84hwSaJOXp4WspK0NLEXe59nCA6Zxelab9a4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspGG8(gon95lIfGaCa4SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNM(8fXcqayaCwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHtJtdPiLaiIL(glKYb4SWI(3iw(Ui4CS0GdlOZc6h6yziG76hcKfmSJyXxhSZpcKLWMxOiSHttF(IyrlacaNfKble0Ceil7FhYybhVoh5SGuz5GSOplNfWhXJFyXcmIg)Gdl9qsFw6ftK33WPPpFrSOfafGZcYGfcAocKL9VdzSGJxNJCwqQSCqw0NLZc4J4XpSybgrJFWHLEiPpl90c59nCACA6BxeCocKfGdlE4EyXI6Xh2WPzVJJOGDS0kDGyVhnW2Ri7DKgPzjgUYRaXsSDwpiNgsJ0SK2sfNfTaOOLfGKoq0ItJtdPrAwq2MxOimaNtdPrAwaGSKsqqcKLDOYhwIb5DgonKgPzbaYcY28cfbYY5dk6YFJLGJjmlhKLq8GIYNpOOdB40qAKMfailaiOoiccKLvvuGWyFIZccFE3sryw69gYGwwIgcrgF(GxdkIfayQSenecd(8bVguuFdNgsJ0SaazjLiGpilrdfC89fkwqkg)2y5BS8h6WSCBel6gyHIf0pO(imz40qAKMfailaOCajwqgSqabKy52iw2J(5pmlolQ)ofXshCiwAkc5VLIyP33yjoCXYMdwO7yz7pw(Jf83TuNxeCHvXzr3FBSeda0Pu)SamwqgPi89UILuQEuvhvhAz5p0bYcgWpQVHtdPrAwaGSaGYbKyPdIpwqx7rTD5H68VWOJfCGkFEiMfpksfNLdYIfeJzP9O2omlWsf3WPH0inlaqw0)q(XI(HDelWglXq5BSedLVXsmu(gloMfNfCefExXYnFbiDgononKgPzjLvbp)iqwIHR8kqSKsaS(WsWlwSiwAWvbYIFSSDxegGJeKy5kVceae)DbdQ)2wwMhIKy4kVceaC)7qgs6anBxNcPSTxrAB5kVcK5q(XPXP5H7Hf2enua2z5N2a(f4qGzC0p)H50qAw0)gXccFE3srS8ywW0XYbzjDw093glfKf85hlWILfMy5MVaKomAzrlw0Trfl3gXs7h8XcSiwEmlWILfMqllaHLVXYTrSGPaSaz5XS4filXKLVXIf82yXhItZd3dlSjAOaSZYpGPnsq4Z7wkcTL3rAdR8ct5B(cq6qlcxTiTtNtZd3dlSjAOaSZYpGPnsq4Z7wkcTL3rAdR8ct5B(cq6qlmsBheeTiC1I0wl0(nTV5laPZOLzZX5fMYwRwtZnFbiDgTmbiubc1vgW143dln6DZxasNrlZJnhSJYWwUdw4BGlCoal8nRW9WcZP5H7Hf2enua2z5hW0gji85DlfH2Y7iTHvEHP8nFbiDOfgPTdcIweUArAde0(nTV5laPZaeZMJZlmLTwTMMB(cq6maXeGqfiuxzaxJFpS0O3nFbiDgGyES5GDug2YDWcFdCHZbyHVzfUhwyonKMf9VryILB(cq6WS4dXsbpw81153hCLkolG0rHJazXXSalwwyIf85hl38fG0HnSKsLopoMfhe8luSOflDKxywUnkol6ELIfxPZJJzXIyjAOgndbYYxGuevGuDSaBSGvWJtZd3dlSjAOaSZYpGPnsq4Z7wkcTL3rAdR8ct5B(cq6qlmsBheeTiC1I0wl0(nTjG76JIiqZx4WSo3srzG7YRB1LbjeFGssiG76JIiqd1ffFixLHdy5vGssiG76JIiqdgUuk6UVqLNLvConpCpSWMOHcWol)aM2iPdcla)k3GthNgsZcaEOGJpwaclifJFBS4filol7Np41GIybwSSRFw093glX6rTDSeBCIfVazjgWuQFwGdl7NpTFiwG3gn6EmXP5H7Hf2enua2z5hW0gj6g)2qR6lkha1wR0r730UhfuFeMmQv5tUiKFjjuq9ryY8vgdv(KKqb1hHjZxzl4TLKqb1hHjJxXZfH8RpNMhUhwyt0qbyNLFatBKOB8BdTFt7Euq9ryYOwLp5Iq(LKqb1hHjZxzmu5tscfuFeMmFLTG3wscfuFeMmEfpxeYV(AIgcHrlJUXVnn6fnecdqm6g)2408W9WcBIgka7S8dyAJe85t7hcTFtB9Mvrn4GImwUYRaLHTSRu5B7lu4Ke9cqeu51zQh12LBoLKOhoIuQ85dk6Wg85tZvkT1kjrVZvuDMYV1q4SLR8kqgQClfbMK0JcQpctgmu5tUiKFjjuq9ryY8vwTkFssOG6JWK5RSf82ssOG6JWKXR45Iq(1NtZd3dlSjAOaSZYpGPnsWNp41GIq730Ewf1GdkYy5kVcug2YUsLVTVqH1eGiOYRZupQTl3CsdoIuQ85dk6Wg85tZvkT1ItJtdPrAwqFKtH1rGSqiOjol33rSCBelE4GdlpMfhH)k3srgonpCpSWAJHkFYwK3XPH0SSthMLucrFwGflXeySO7Vn46ybC(2XIxGSO7Vnw2pFuWbKfVazbiaJf4TrJUhtCAE4EyHbM2ibHpVBPi0wEhP9JZoKqlcxTiTXrKsLpFqrh2GpFAUsLQwA6P35kQod(8rbhqdvULIatsoxr1zWhPu(KbNVDgQClfb2pjbhrkv(8bfDyd(8P5kvQaHtdPzzNomlbf5iiw0Trfl7NpTFiwcEXY2FSaeGXY5dk6WSOB7dBS8ywgsri86yPbhwUnIf0pO(imXYbzXIyjAOgndbYIxGSOB7dBS0ELIgwoilbhFCAE4EyHbM2ibHpVBPi0wEhP9JZbf5ii0IWvlsBCePu5Zhu0Hn4ZN2puQAXPH0Se7yILyqdMga)cfl6(BJfKLsKOVvGf4WI3oAybzWcbeqILVybzPej6Bf408W9WcdmTrIfnyAa8luO9BA3tVaebvEDM6rTD5Mtjj6fGqfiuxzcWcbeqkFBugh9ZFyZkQVgRvRzcE(RGzOo)lCQAHgnwRwZmocQGlCUnuLI4MH68VWaf90OxaIGkVodcQUT4tssaIGkVodcQUT4JgRvRzcE(RGzfPXA1AMXrqfCHZTHQue3SI00ZA1AMXrqfCHZTHQue3muN)fgOAPfaena)SkQbhuKb)vBPYBXXhnVNKyTAntWZFfmd15FHbQwALKOfsfhrkvEZXhbuTmObn950qAwaWWJfD)TXIZcYsjs03kWYT5hlpUq3XIZcaEPW(Ws0adSahw0Trfl3gXs7rTDS8ywCl46y5GSqfiNMhUhwyGPnsIG3dl0(nTTwTMj45VcMH68VWPQfA00tVzvudoOid(R2sL3IJpAEpjXA1AMXrqfCHZTHQue3muN)fgOAbWaGab4TwTMXsbHGQf(mRinwRwZmocQGlCUnuLI4Mvu)KK2JA7Yd15FHbkqqdNgsZcYCvyP8JWSOBJUnAyzH)cflidwiGasSuqDSO7vkwCLcQJL4WflhKf89kflbhFSCBelyVJyX7GR6yb2ybzWcbeqcyilLirFRalbhFyonpCpSWatBKGWN3TueAlVJ0oaleqaPmiHJxb0IWvls7a9QE9ApQTlpuN)fgaQfAaGbiubc1vMGN)kygQZ)c3hPQfaj9(AhOx1Rx7rTD5H68VWaqTqdamaHkqOUYeGfciGu(2Omo6N)WgW143dlayacvGqDLjaleqaP8TrzC0p)Hnd15FH7Ju1cGKEFn6n(dMjeuDgheeBiK)4dNKeGqfiuxzcE(RGzOo)lCQFD0ebv(rG52JA7Yd15FHtscqOceQRmbyHaciLVnkJJ(5pSzOo)lCQFD0ebv(rG52JA7Yd15FHbGALEsIEbicQ86m1JA7YnN40qAwIDmbYYbzbKuECwUnILf2rrSaBSGSuIe9TcSOBJkww4VqXciCzPiwGfllmXIxGSenecQowwyhfXIUnQyXlwCqqwieuDS8ywCl46y5GSa(eNMhUhwyGPnsq4Z7wkcTL3rAhaZbyb(3dl0IWvls7ETh12LhQZ)cNQwOjjz8hmtiO6moii28vQOj9(A61RhbCxFuebAOUO4d5QmCalVcKME9cqOceQRmuxu8HCvgoGLxbYmuN)fgOAbCspjjarqLxNbbv3w8rtacvGqDLH6IIpKRYWbS8kqMH68VWavlGdady90slGFwf1GdkYG)QTu5T44JM373xJEbiubc1vgQlk(qUkdhWYRazgYbJ3VFsspc4U(Oic0GHlLIU7lu5zzfxtp9cqeu51zQh12LBoLKeGqfiuxzWWLsr39fQ8SSINJj6Hgas6AzgQZ)cduT0c963pjPxacvGqDLXIgmna(fkZqoy8Ke9gpqMBGkvFn96ra31hfrGMVWHzDULIYa3Lx3Qldsi(aPjaHkqOUY8fomRZTuug4U86wDzqcXhiZqoy8(jj9iG76JIiqdEZbH6iWmCSYWw(GthvNMaeQaH6kZbNoQocm)f(rTD5yIg0etGOLzOo)lC)KKE9q4Z7wkYaR8ct5B(cq60wRKee(8ULImWkVWu(MVaKoTJzFn9U5laPZOLzihmEoaHkqOUkj5MVaKoJwMaeQaH6kZqD(x4u)6OjcQ8JaZTh12LhQZ)cda1k9(jji85DlfzGvEHP8nFbiDAden9U5laPZaeZqoy8CacvGqDvsYnFbiDgGycqOceQRmd15FHt9RJMiOYpcm3EuBxEOo)lmauR07NKGWN3TuKbw5fMY38fG0PD6973pjjarqLxNbW4Z7v)KK2JA7Yd15FHbQ1Q1mbp)vWaUg)EyXPH0SaGKpVBPiwwycKLdYciP84S4vCwU5laPdZIxGSeaXSOBJkw05)9fkwAWHfVyb9xrBW5DwIgyGtZd3dlmW0gji85DlfH2Y7iTVT5vQmMiaPjRZ)dTiC1I0wpmCPS(c0CBZRuzmrasJHk3srGjjTh12LhQZ)cNkqsp9KK2JA7Yd15FHbkqqdW6HEPdaTwTM52MxPYyIaKgd(8aGapq6NKyTAnZTnVsLXebing85batnMaeayVzvudoOid(R2sL3IJpAEh4rtFonKMLyhtSG(DrXhYvSaGEalVcelajDmfWSyrn4qS4SGSuIe9TcSSWKHtZd3dlmW0gjlmL)J6qB5DK2uxu8HCvgoGLxbcTFt7aeQaH6ktWZFfmd15FHbkqsxtacvGqDLjaleqaP8TrzC0p)Hnd15FHbkqsxtpe(8ULIm328kvgteG0K15)LKyTAnZTnVsLXebing85batnMPdSEZQOgCqrg8xTLkVfhF08oWdC63pjP9O2U8qD(xyGgtagNgsZsSJjw2HlLIUVqXcaILvCwaoykGzXIAWHyXzbzPej6BfyzHjdNMhUhwyGPnswyk)h1H2Y7iTXWLsr39fQ8SSIJ2VPDacvGqDLj45VcMH68VWaf4OrVaebvEDgeuDBXhn6fGiOYRZupQTl3CkjjarqLxNPEuBxU5KMaeQaH6ktawiGas5BJY4OF(dBgQZ)cduGJMEi85DlfzcWcbeqkds44vijjaHkqOUYe88xbZqD(xyGcC6NKeGiOYRZGGQBl(OPNEZQOgCqrg8xTLkVfhF08UMaeQaH6ktWZFfmd15FHbkWjjXA1AMXrqfCHZTHQue3muN)fgOAHEaRhAaEc4U(Oic08f(Mv4Gdod(i(IYwKs1xJ1Q1mJJGk4cNBdvPiUzf1pjP9O2U8qD(xyGce0WP5H7HfgyAJKfMY)rDOT8os7VWHzDULIYa3Lx3Qldsi(aH2VPT1Q1mbp)vWmuN)fovTqJME6nRIAWbfzWF1wQ8wC8rZ7jjwRwZmocQGlCUnuLI4MH68VWavlGaSEXe4TwTMXsbHGQf(mRO(aRxpagaenaV1Q1mwkieuTWNzf1h4jG76JIiqZx4BwHdo4m4J4lkBrkvFnwRwZmocQGlCUnuLI4Mvu)KK2JA7Yd15FHbkqqdNgsZsSJjwMh12XIf1GdXsaeZP5H7HfgyAJKfMY)rDOT8osB8Mdc1rGz4yLHT8bNoQo0(nT7fGqfiuxzcE(RGzihmUg9cqeu51zQh12LBoPbHpVBPiZTnVsLXebinzD(FjjbicQ86m1JA7YnN0eGqfiuxzcWcbeqkFBugh9ZFyZqoyCn9q4Z7wkYeGfciGugKWXRqssacvGqDLj45VcMHCW497RbeEg8QA)qM7da(fkn9aHNbFKs5tUP8Hm3ha8lujj6DUIQZGpsP8j3u(qgQClfbMKGJiLkF(GIoSbF(0(HsnM910deEMoiSA)qM7da(fQ(A6HWN3TuK5XzhsjjZQOgCqrglx5vGYWw2vQ8T9fkCsIJVXv5iOoAsvBaA6jjwRwZyPGqq1cFMvuFn9cqOceQRmw0GPbWVqzgYbJNKO34bYCduP6NK0EuBxEOo)lmqrV050qAw0)2Jz5XS4Sm(TrdlKYTGJFel684SCqw6CajwCLIfyXYctSGp)y5MVaKomlhKflIf1xeilRiw093glilLirFRalEbYcYGfciGelEbYYctSCBelaPazbRGhlWILailFJfl4TXYnFbiDyw8HybwSSWel4ZpwU5laPdZP5H7HfgyAJKfMY)rDy0IvWdR9nFbiDAH2VPncFE3srgyLxykFZxasN2arJE38fG0zaIzihmEoaHkqOUkjPhcFE3srgyLxykFZxasN2ALKGWN3TuKbw5fMY38fG0PDm7RPN1Q1mbp)vWSI00tVaebvEDgeuDBXNKeRvRzghbvWfo3gQsrCZqD(xyG1dna)SkQbhuKb)vBPYBXXhnV3hOAFZxasNrlJ1Q1YGRXVhwASwTMzCeubx4CBOkfXnROKeRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SI6NKeGqfiuxzcE(RGzOo)lmWasQ38fG0z0YeGqfiuxzaxJFpS0ON1Q1mbp)vWSI00tVaebvEDM6rTD5Mtjj6HWN3TuKjaleqaPmiHJxH(A0larqLxNbW4Z7vssaIGkVot9O2UCZjni85DlfzcWcbeqkds44vqtacvGqDLjaleqaP8TrzC0p)HnRin6fGqfiuxzcE(RGzfPPxpRvRzOG6JWuwTkFmd15FHtvR0tsSwTMHcQpctzmu5JzOo)lCQALEFn6nRIAWbfzSCLxbkdBzxPY32xOWjj9SwTMXYvEfOmSLDLkFBFHcNl)wdzWNhauB0KKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppaO2aK(9tsSwTMbWVahcmtDrqD00r1LPIguFkiZkQFss7rTD5H68VWafiPNKGWN3TuKbw5fMY38fG0PD6CAE4EyHbM2izHP8FuhgTyf8WAFZxashqq730gHpVBPidSYlmLV5laPtpTbIg9U5laPZOLzihmEoaHkqOUkjbHpVBPidSYlmLV5laPtBGOPN1Q1mbp)vWSI00tVaebvEDgeuDBXNKeRvRzghbvWfo3gQsrCZqD(xyG1dna)SkQbhuKb)vBPYBXXhnV3hOAFZxasNbigRvRLbxJFpS0yTAnZ4iOcUW52qvkIBwrjjwRwZmocQGlCUnuLI4z8xTLkVfhF08Uzf1pjjaHkqOUYe88xbZqD(xyGbKuV5laPZaetacvGqDLbCn(9WsJEwRwZe88xbZkstp9cqeu51zQh12LBoLKOhcFE3srMaSqabKYGeoEf6RrVaebvEDgaJpVxA6PN1Q1mbp)vWSIss0larqLxNbbv3w8PFssaIGkVot9O2UCZjni85DlfzcWcbeqkds44vqtacvGqDLjaleqaP8TrzC0p)HnRin6fGqfiuxzcE(RGzfPPxpRvRzOG6JWuwTkFmd15FHtvR0tsSwTMHcQpctzmu5JzOo)lCQALEFn6nRIAWbfzSCLxbkdBzxPY32xOWjj9SwTMXYvEfOmSLDLkFBFHcNl)wdzWNhauB0KKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppaO2aK(97NKyTAndGFboeyM6IG6OPJQltfnO(uqMvuss7rTD5H68VWafiPNKGWN3TuKbw5fMY38fG0PD6CAinlXoMWS4kflWBJgwGfllmXYFuhMfyXsaKtZd3dlmW0gjlmL)J6WCAinlXwk8GelE4EyXI6XhlwoMazbwSG)B53dlKOiupMtZd3dlmW0gjZQYE4EyLvp(qB5DK2oKql(MpCARfA)M2i85DlfzEC2HeNMhUhwyGPnsMvL9W9WkRE8H2Y7iTTG(Hw8nF40wl0(nTNvrn4GImwUYRaLHTSRu5B7luydbCxFuebYP5H7HfgyAJKzvzpCpSYQhFOT8osB8XPXPH0SGmxfwk)iml62OBJgwUnILy7qExWVWgnSyTAnw09kflnxPyb2ASO7VTVy52iwkc5hlbhFCAE4EyHnoK0gHpVBPi0wEhPn4qExw3Ru5MRuzyRHweUArA3ZA1AM77iDWPYGd5DwFbsJzOo)lmqrfanDoYbw6gTssSwTM5(oshCQm4qEN1xG0ygQZ)cdupCpSm4ZN2pKHqofwhLVVJaw6gT00JcQpctMVYQv5tscfuFeMmyOYNCri)ssOG6JWKXR45Iq(1VVgRvRzUVJ0bNkdoK3z9finMvKMzvudoOiZ9DKo4uzWH8oRVaPHtdPzbzUkSu(ryw0Tr3gnSSF(GxdkILhZIo4CBSeC89fkwGiOHL9ZN2pelFXI(SkFyb9dQpctCAE4EyHnoKaM2ibHpVBPi0wEhP9JQGdLXNp41GIqlcxTiT1JcQpctMVYyOYhn9WrKsLpFqrh2GpFA)qPIgnNRO6my4sLHT8Tr5gCi8zOYTueyscoIuQ85dk6Wg85t7hkvawFonKMLyhtSGmyHaciXIUnQyXpwuegZYT5flOjDwsjgaZIxGSO(IyzfXIU)2ybzPej6Bf408W9WcBCibmTrsawiGas5BJY4OF(dJ2VPTEGZ6bnfmhaXA61dHpVBPitawiGaszqchVcA0laHkqOUYe88xbZqoy8KeRvRzcE(RGzf1xtpRvRzOG6JWuwTkFmd15FHtf4KKyTAndfuFeMYyOYhZqD(x4ubo910tVzvudoOiJLR8kqzyl7kv(2(cfojXA1Aglx5vGYWw2vQ8T9fkCU8BnKbFEaWuJzsI1Q1mwUYRaLHTSRu5B7lu4SpbVid(8aGPgZ(jjwqmwt7rTD5H68VWavR01OxacvGqDLj45VcMHCW4950qAwIDmXsSzOkfXzr3FBSGSuIe9TcCAE4EyHnoKaM2izCeubx4CBOkfXr7302A1AMGN)kygQZ)cNQwOHtdPzj2Xel7RQ9dXYxSe5fi19bwGflEf)2(cfl3MFSOEeeMfTqpmfWS4filkcJzr3FBS0bhILZhu0HzXlqw8JLBJyHkqwGnwCw2HkFyb9dQpctS4hlAHESGPaMf4WIIWywgQZ)6luS4ywoilf8yzZr8fkwoild1gcVXc4A(cfl6ZQ8Hf0pO(imXP5H7Hf24qcyAJe8QA)qOnepOO85dk6WARfA)M29gQneEZTuusI1Q1muq9rykJHkFmd15FHbAm1qb1hHjZxzmu5JMH68VWavl0tZ5kQodgUuzylFBuUbhcFgQClfb2xZ5dk6m33r5dMbFkvTqpaioIuQ85dk6WaBOo)lSMEuq9ryY8v2R4jjd15FHbkQaOPZrEFonKMfKsefXYkIL9ZNMRuS4hlUsXY9DeMLvPimMLf(luSOpXd(4yw8cKL)y5XS4wW1XYbzjAGbwGdlk6y52iwWru4DflE4EyXI6lIflsb1XYMxGkILy7qEN1xG0WcSybiSC(GIomNMhUhwyJdjGPnsWNpnxPq730wVZvuDg8rkLpzW5BNHk3srGA6zTAnd(8P5kLzO2q4n3srA6HJiLkF(GIoSbF(0CLcOXmjrVzvudoOiZ9DKo4uzWH8oRVaPPFsY5kQodgUuzylFBuUbhcFgQClfbQXA1AgkO(imLXqLpMH68VWanMAOG6JWK5RmgQ8rJ1Q1m4ZNMRuMH68VWafGPbhrkv(8bfDyd(8P5kvQAJE910tVzvudoOiJkEWhhNBkIUVqLrP(UimLKCFhHurQOhAs1A1Ag85tZvkZqD(xyGbK(AoFqrN5(okFWm4tPIgonKMfKI)2yz)iLYhwITZ3owwyIfyXsaKfDBuXYqTHWBULIyXADSGVxPyrN)hln4WI(ep4JJzjAGbw8cKfqyHUJLfMyXIAWHybzXwSHL97vkwwyIflQbhIfKbleqajwWFfiwUn)yr3RuSenWalEbVnAyz)8P5kfNMhUhwyJdjGPnsWNpnxPq730(CfvNbFKs5tgC(2zOYTueOgRvRzWNpnxPmd1gcV5wkstp9Mvrn4GImQ4bFCCUPi6(cvgL67IWusY9DesfPIEOjv0RVMZhu0zUVJYhmd(uQXKtdPzbP4VnwITd5DwFbsdllmXY(5tZvkwoilasuelRiwUnIfRvRXIvCwCfgYYc)fkw2pFAUsXcSybnSGPaSaXSahwuegZYqD(xFHItZd3dlSXHeW0gj4ZNMRuO9BApRIAWbfzUVJ0bNkdoK3z9finAWrKsLpFqrh2GpFAUsLQ2Xutp9SwTM5(oshCQm4qEN1xG0ywrASwTMbF(0CLYmuBi8MBPOKKEi85DlfzahY7Y6ELk3CLkdBnn9SwTMbF(0CLYmuN)fgOXmjbhrkv(8bfDyd(8P5kvQarZ5kQod(iLYNm48TZqLBPiqnwRwZGpFAUszgQZ)cdu00VFFonKMfK5QWs5hHzr3gDB0WIZY(5dEnOiwwyIfDVsXsWxyIL9ZNMRuSCqwAUsXcS1qllEbYYctSSF(GxdkILdYcGefXsSDiVZ6lqAybFEaqwwrCAE4EyHnoKaM2ibHpVBPi0wEhPn(8P5kvwhSUCZvQmS1qlcxTiTD8nUkhb1rtQaK0bG90kDG3A1AM77iDWPYGd5DwFbsJbFEaW(aWEwRwZGpFAUszgQZ)cd8XePIJiLkV54JaE9oxr1zWhPu(KbNVDgQClfb2ha2laHkqOUYGpFAUszgQZ)cd8XePIJiLkV54Ja(ZvuDg8rkLpzW5BNHk3srG9bG9aHNPTM4zyltQvrMH68VWapA6RPN1Q1m4ZNMRuMvussacvGqDLbF(0CLYmuN)fUpNgsZsSJjw2pFWRbfXIU)2yj2oK3z9finSCqwaKOiwwrSCBelwRwJfD)Tbxhlki(luSSF(0CLILv09DelEbYYctSSF(GxdkIfyXc6bmwIbmL6Nf85baXSSQ7vSGESC(GIomNMhUhwyJdjGPnsWNp41GIq730gHpVBPid4qExw3Ru5MRuzyRPbHpVBPid(8P5kvwhSUCZvQmS10OhcFE3srMhvbhkJpFWRbfLK0ZA1Aglx5vGYWw2vQ8T9fkCU8BnKbFEaWuJzsI1Q1mwUYRaLHTSRu5B7lu4SpbVid(8aGPgZ(AWrKsLpFqrh2GpFAUsbu0tdcFE3srg85tZvQSoyD5MRuzyRXPH0Se7yIfSoF6ybdz528JL4WflOOJLoh5SSIUVJyXkoll8xOy5pwCmlk)iwCmlrqm(TuelWIffHXSCBEXsmzbFEaqmlWHfaKx4JfDBuXsmbgl4ZdaIzHqE0peNMhUhwyJdjGPnsCqp6EeugRZNo0gIhuu(8bfDyT1cTFtB9Upa4xO0ONhUhwgh0JUhbLX68Pld6DokY8vUPEuBxsci8moOhDpckJ15txg07CuKbFEaqGgtnGWZ4GE09iOmwNpDzqVZrrMH68VWanMCAinlaiO2q4nwaqbHv7hILVXcYsjs03kWYJzzihmoAz52OHyXhIffHXSCBEXcAy58bfDyw(If9zv(Wc6huFeMyr3FBSSdVydAzrryml3MxSOv6SaVnA09yILVyXR4SG(b1hHjwGdlRiwoilOHLZhu0HzXIAWHyXzrFwLpSG(b1hHjdlXwyHUJLHAdH3ybCnFHIfKsFboeilOFxeuhnDuDSSkfHXS8fl7qLpSG(b1hHjonpCpSWghsatBK0bHv7hcTH4bfLpFqrhwBTq730EO2q4n3srAoFqrN5(okFWm4tP2RNwOhW6HJiLkF(GIoSbF(0(HaEGa8wRwZqb1hHPSAv(ywr97dSH68VW9rQ90cyNRO6mNUVYDqyHnu5wkcSVMEbiubc1vMGN)kygYbJRrpWz9GMcMdGyn9q4Z7wkYeGfciGugKWXRqssacvGqDLjaleqaP8TrzC0p)Hnd5GXts0larqLxNPEuBxU5u)KeCePu5Zhu0Hn4ZN2peq71d4aa7zTAndfuFeMYQv5Jzfb8aPFFGVNwa7CfvN509vUdclSHk3srG97RrpkO(imzWqLp5Iq(LK0JcQpctMVYyOYNKKEuq9ryY8v2cEBjjuq9ryY8vwTkF6RrVZvuDgmCPYWw(2OCdoe(mu5wkcmjXA1AMO57Gd47QSpbV(qoAPW(yq4QfLQ2abnP3xtpCePu5Zhu0Hn4ZN2peq1kDGVNwa7CfvN509vUdclSHk3srG97RXX34QCeuhnPIM0bGwRwZGpFAUszgQZ)cd8aN(A6PN1Q1ma(f4qGzQlcQJMoQUmv0G6tbzwrjjuq9ryY8vgdv(KKOxaIGkVodGXN3R(A0ZA1AMXrqfCHZTHQuepJ)QTu5T44JM3nRionKMLyhtSeBGXIfyXsaKfD)Tbxhlbpk6luCAE4EyHnoKaM2iPbNaLHTC53Ai0(nT9OCyJcaYP5H7Hf24qcyAJee(8ULIqB5DK2bWCawG)9Wk7qcTiC1I0wpWz9GMcMdGyni85DlfzcG5aSa)7HLME9SwTMbF(0CLYSIssoxr1zWhPu(KbNVDgQClfbMKeGiOYRZupQTl3CQVME6zTAndgQW3hiZksJEwRwZe88xbZkstp9oxr1zARjEg2YKAvKHk3srGjjwRwZe88xbd4A87HvQbiubc1vM2AINHTmPwfzgQZ)cdmasFni85DlfzUT5vQmMiaPjRZ)ttp9cqeu51zQh12LBoLKeGqfiuxzcWcbeqkFBugh9ZFyZkstpRvRzWNpnxPmd15FHbkqss07CfvNbFKs5tgC(2zOYTuey)(AoFqrN5(okFWm4tPATAntWZFfmGRXVhwaF6gaw)KK2JA7Yd15FHbQ1Q1mbp)vWaUg)Ey1NtdPzj2XelilLirFRalWILailRsrymlEbYI6lIL)yzfXIU)2ybzWcbeqItZd3dlSXHeW0gjbsr47Dv2vpQQJQdTFtBe(8ULImbWCawG)9Wk7qItZd3dlSXHeW0gjFf8P87HfA)M2i85DlfzcG5aSa)7Hv2HeNgsZsSJjwq)UiOoAyjgWcKfyXsaKfD)TXY(5tZvkwwrS4filyhbXsdoSaGxkSpS4fililLirFRaNMhUhwyJdjGPnsOUiOoAYwWceTFt7VoAIGk)iWC7rTD5H68VWavl0KK0ZA1AMO57Gd47QSpbV(qoAPW(yq4QfbuGGM0tsSwTMjA(o4a(Uk7tWRpKJwkSpgeUArPQnqqt691yTAnd(8P5kLzfPPxacvGqDLj45VcMH68VWPIM0tsaN1dAkyoaI7ZPH0SaGGAdH3yPP8HybwSSIy5GSetwoFqrhMfD)TbxhlilLirFRalw0xOyXTGRJLdYcH8OFiw8cKLcESarqtWJI(cfNMhUhwyJdjGPnsWhPu(KBkFi0gIhuu(8bfDyT1cTFt7HAdH3ClfP5(okFWm4tPQfA0GJiLkF(GIoSbF(0(Hak6PXJYHnkaOMEwRwZe88xbZqD(x4u1k9Ke9SwTMj45VcMvuFonKMLyhtSeBGOplFJLVWpiXIxSG(b1hHjw8cKf1xel)XYkIfD)TXIZcaEPW(Ws0adS4filPe0JUhbXYUoF6408W9WcBCibmTrsBnXZWwMuRIq730McQpctMVYEfxJhLdBuaqnwRwZenFhCaFxL9j41hYrlf2hdcxTiGce0KUMEGWZ4GE09iOmwNpDzqVZrrM7da(fQKe9cqeu51zkkmqfCatsWrKsLpFqrhovG0xtpRvRzghbvWfo3gQsrCZqD(xyGcqbG9qdWpRIAWbfzWF1wQ8wC8rZ791yTAnZ4iOcUW52qvkIBwrjj6zTAnZ4iOcUW52qvkIBwr910tVaeQaH6ktWZFfmROKeRvRzUT5vQmMiaPXGppaiq1cnAApQTlpuN)fgOaj9010EuBxEOo)lCQALE6jj6HHlL1xGMBBELkJjcqAmu5wkcSVMEy4sz9fO52MxPYyIaKgdvULIatscqOceQRmbp)vWmuN)fo1yMEFonKMLyhtS4SSF(0CLIfa0fDBSenWalRsryml7NpnxPy5XS4QHCW4SSIyboSehUyXhIf3cUowoilqe0e8iwsjgaZP5H7Hf24qcyAJe85tZvk0(nTTwTMbw0THZr0eOO7HLzfPPN1Q1m4ZNMRuMHAdH3ClfLK44BCvocQJMubOP3NtdPzj2U6IyjLyamlwudoelidwiGasSO7Vnw2pFAUsXIxGSCBuXY(5dEnOionpCpSWghsatBKGpFAUsH2VPDaIGkVot9O2UCZjn6DUIQZGpsP8jdoF7mu5wkcutpe(8ULImbyHaciLbjC8kKKeGqfiuxzcE(RGzfLKyTAntWZFfmRO(AcqOceQRmbyHaciLVnkJJ(5pSzOo)lmqrfanDoYb(a9QEo(gxLJG6ObPIM07RXA1Ag85tZvkZqD(xyGIEA0dCwpOPG5aiMtZd3dlSXHeW0gj4Zh8AqrO9BAhGiOYRZupQTl3Cstpe(8ULImbyHaciLbjC8kKKeGqfiuxzcE(RGzfLKyTAntWZFfmRO(AcqOceQRmbyHaciLVnkJJ(5pSzOo)lmqboASwTMbF(0CLYSI0qb1hHjZxzVIRrpe(8ULImpQcougF(GxdksJEGZ6bnfmhaXCAinlXoMyz)8bVguel6(BJfVybaDr3glrdmWcCy5BSehUqhilqe0e8iwsjgaZIU)2yjoCnSueYpwco(mSKsfgYc4QlILuIbWS4hl3gXcvGSaBSCBelair1TfFyXA1AS8nw2pFAUsXIo4sbwO7yP5kflWwJf4WsC4IfFiwGflaHLZhu0H508W9WcBCibmTrc(8bVgueA)M2wRwZal62W5GI8jJ4XpSmROKKE6HpFA)qgpkh2OaGA0dHpVBPiZJQGdLXNp41GIss6zTAntWZFfmd15FHbkA0yTAntWZFfmROKKE9SwTMj45VcMH68VWafva005ih4d0R654BCvocQJgKAmtVVgRvRzcE(RGzfLKyTAnZ4iOcUW52qvkINXF1wQ8wC8rZ7MH68VWafva005ih4d0R654BCvocQJgKAmtVVgRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SI6RjarqLxNbbv3w8PFFn9WrKsLpFqrh2GpFAUsb0yMKGWN3TuKbF(0CLkRdwxU5kvg2A97Rrpe(8ULImpQcougF(Gxdkstp9Mvrn4GIm33r6GtLbhY7S(cKMKeCePu5Zhu0Hn4ZNMRuanM950qAwIDmXcakiSWS8fl7qLpSG(b1hHjw8cKfSJGyj2SukwaqbHfln4WcYsjs03kWP5H7Hf24qcyAJKI0L7GWcTFt7EwRwZqb1hHPmgQ8XmuN)fovc5uyDu((okjPxyZhuewBGOzOWMpOO89Deqrt)KKWMpOiS2XSVgpkh2OaGCAE4EyHnoKaM2izZvTChewO9BA3ZA1AgkO(imLXqLpMH68VWPsiNcRJY33rjj9cB(GIWAdendf28bfLVVJakA6NKe28bfH1oM914r5WgfautpRvRzghbvWfo3gQsrCZqD(xyGIgnwRwZmocQGlCUnuLI4MvKg9Mvrn4GIm4VAlvElo(O59Ke9SwTMzCeubx4CBOkfXnRO(CAE4EyHnoKaM2iPTuQChewO9BA3ZA1AgkO(imLXqLpMH68VWPsiNcRJY33rA6fGqfiuxzcE(RGzOo)lCQOj9KKaeQaH6ktawiGas5BJY4OF(dBgQZ)cNkAsVFssVWMpOiS2arZqHnFqr577iGIM(jjHnFqryTJzFnEuoSrba10ZA1AMXrqfCHZTHQue3muN)fgOOrJ1Q1mJJGk4cNBdvPiUzfPrVzvudoOid(R2sL3IJpAEpjrpRvRzghbvWfo3gQsrCZkQpNgsZsSJjwqkGOplWIfKfB508W9WcBCibmTrIoFMhozyltQvrCAinliZvHLYpcZIUn62OHLdYYctSSF(0(Hy5lw2HkFyr32h2y5XS4hlOHLZhu0HbMwS0GdlecAIZcqshPYsNJpAIZcCyb9yz)8bVguelOFxeuhnDuDSGppaiMtZd3dlSXHeW0gji85DlfH2Y7iTXNpTFO8xzmu5dAr4QfPnoIuQ85dk6Wg85t7hkv0dynfeo96C8rt8mcxTiGxR0thPcK07dSMccNEwRwZGpFWRbfLPUiOoA6O6YyOYhd(8aGiv0RpNgsZcYCvyP8JWSOBJUnAy5GSGum(TXc4A(cflXMHQueNtZd3dlSXHeW0gji85DlfH2Y7iT1n(TL)k3gQsrC0IWvlsBTqQ4isPYBo(iGceayV0nab47HJiLkF(GIoSbF(0(HaGA1h47PfWoxr1zWWLkdB5BJYn4q4ZqLBPiqGxldA63hyPB0cnaV1Q1mJJGk4cNBdvPiUzOo)lmNgsZsSJjwqkg)2y5lw2HkFyb9dQpctSahw(glfKL9ZN2pel6ELIL2FS81bzbzPej6BfyXR4DWH408W9WcBCibmTrIUXVn0(nT7rb1hHjJAv(Klc5xscfuFeMmEfpxeYpni85DlfzECoOihb1xtVZhu0zUVJYhmd(uQOxscfuFeMmQv5t(RmqssApQTlpuN)fgOALE)KeRvRzOG6JWugdv(ygQZ)cdupCpSm4ZN2pKHqofwhLVVJ0yTAndfuFeMYyOYhZkkjHcQpctMVYyOYhn6HWN3TuKbF(0(HYFLXqLpjjwRwZe88xbZqD(xyG6H7HLbF(0(HmeYPW6O89DKg9q4Z7wkY84CqrocsJ1Q1mbp)vWmuN)fgOeYPW6O89DKgRvRzcE(RGzfLKyTAnZ4iOcUW52qvkIBwrAq4Z7wkYOB8Bl)vUnuLI4jj6HWN3TuK5X5GICeKgRvRzcE(RGzOo)lCQeYPW6O89DeNgsZsSJjw2pFA)qS8nw(If9zv(Wc6huFeMqllFXYou5dlOFq9ryIfyXc6bmwoFqrhMf4WYbzjAGbw2HkFyb9dQpctCAE4EyHnoKaM2ibF(0(H40qAwInUsDBZItZd3dlSXHeW0gjZQYE4EyLvp(qB5DK2nxPUTzXPXPH0SeBgQsrCw093glilLirFRaNMhUhwyJf0pThhbvWfo3gQsrC0(nTTwTMj45VcMH68VWPQfA40qAwIDmXskb9O7rqSSRZNow0Trfl(XIIWywUnVyb9yjgWuQFwWNhaeZIxGSCqwgQneEJfNfGQnqybFEaqwCmlk)iwCmlrqm(TuelWHL77iw(JfmKL)yXN5rqywaqEHpw82rdlolXeySGppaileYJ(HWCAE4EyHnwq)aM2iXb9O7rqzSoF6qBiEqr5Zhu0H1wl0(nTTwTMXYvEfOmSLDLkFBFHcNl)wdzWNhaeOaenwRwZy5kVcug2YUsLVTVqHZ(e8Im4ZdacuaIME6bcpJd6r3JGYyD(0Lb9ohfzUpa4xO0ONhUhwgh0JUhbLX68Pld6DokY8vUPEuBNME6bcpJd6r3JGYyD(0L3ixzUpa4xOssaHNXb9O7rqzSoF6YBKRmd15FHtnM9tsaHNXb9O7rqzSoF6YGENJIm4Zdac0yQbeEgh0JUhbLX68Pld6DokYmuN)fgOOrdi8moOhDpckJ15txg07CuK5(aGFHQpNgsZsSJjwqgSqabKyr3FBSGSuIe9TcSOBJkwIGy8BPiw8cKf4TrJUhtSO7VnwCwIbmL6NfRvRXIUnQybKWXRWxO408W9WcBSG(bmTrsawiGas5BJY4OF(dJ2VPTEGZ6bnfmhaXA61dHpVBPitawiGaszqchVcA0laHkqOUYe88xbZqoy8KeRvRzcE(RGzf1xtpRvRzSCLxbkdBzxPY32xOW5YV1qg85ba1gGKKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppaO2aK(jjTh12LhQZ)cduTsVpNgsZsSbI(S4ywUnIL2p4Jfubqw(ILBJyXzjgWuQFw09fiuhlWHfD)TXYTrSGuk(8EXI1Q1yboSO7VnwCwaiadtbwsjOhDpcILDD(0XIxGSOZ)JLgCybzPej6Bfy5BS8hl6G1XIfXYkIfhL)flwudoel3gXsaKLhZs7RhVrGCAE4EyHnwq)aM2iPTM4zyltQvrO9BA3RxpRvRzSCLxbkdBzxPY32xOW5YV1qg85batf4KKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppayQaN(A6PxaIGkVodcQUT4tsIEwRwZmocQGlCUnuLI4Mvu)(A6boRh0uWCaeNKeGqfiuxzcE(RGzOo)lCQOj9KKEbicQ86m1JA7YnN0eGqfiuxzcWcbeqkFBugh9ZFyZqD(x4urt6973pjPhi8moOhDpckJ15txg07CuKzOo)lCQaenbiubc1vMGN)kygQZ)cNQwPRjarqLxNPOWavWbSFsYxhnrqLFeyU9O2U8qD(xyGcq0OxacvGqDLj45VcMHCW4jjbicQ86magFEV0yTAndGFboeyM6IG6OPJQZSIsscqeu51zqq1TfF0yTAnZ4iOcUW52qvkIBgQZ)cduaQgRvRzghbvWfo3gQsrCZkItdPzbzEfifl7Npk4aYIU)2yXzPiDSedyk1plwRwJfVazbzPej6Bfy5Xf6owCl46y5GSyrSSWeiNMhUhwyJf0pGPnscEfiv2A1AOT8osB85JcoGO9BA3ZA1Aglx5vGYWw2vQ8T9fkCU8BnKzOo)lCQamdAssSwTMXYvEfOmSLDLkFBFHcN9j4fzgQZ)cNkaZGM(A6fGqfiuxzcE(RGzOo)lCQaSKKEbiubc1vgQlcQJMSfSand15FHtfGPrpRvRza8lWHaZuxeuhnDuDzQOb1NcYSI0eGiOYRZay859QFFno(gxLJG6OjvTJz6CAinlX2vxel7Np41GIWSO7VnwCwIbmL6NfRvRXI16yPGhl62OILiiu9fkwAWHfKLsKOVvGf4WcsPVahcKL9OF(dZP5H7Hf2yb9dyAJe85dEnOi0(nT7zTAnJLR8kqzyl7kv(2(cfox(TgYGppayQajjXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaWubsFn9cqeu51zQh12LBoLKeGqfiuxzcE(RGzOo)lCQaSKe9q4Z7wkYeaZbyb(3dln6fGiOYRZay859kjPxacvGqDLH6IG6OjBblqZqD(x4ubyA0ZA1Aga)cCiWm1fb1rthvxMkAq9PGmRinbicQ86magFEV63xtp9aHNPTM4zyltQvrM7da(fQKe9cqOceQRmbp)vWmKdgpjrVaeQaH6ktawiGas5BJY4OF(dBgYbJ3NtdPzj2U6Iyz)8bVgueMflQbhIfKbleqajonpCpSWglOFatBKGpFWRbfH2VPDVaeQaH6ktawiGas5BJY4OF(dBgQZ)cdu0OrpWz9GMcMdGyn9q4Z7wkYeGfciGugKWXRqssacvGqDLj45VcMH68VWafn91GWN3TuKjaMdWc8Vhw91Ohi8mT1epdBzsTkYCFaWVqPjarqLxNPEuBxU5Kg9aN1dAkyoaI1qb1hHjZxzVIRXX34QCeuhnPIEPZPH0SeBHf6owaHhlGR5luSCBelubYcSXcachbvWfMLyZqvkIJwwaxZxOybWVahcKfQlcQJMoQowGdlFXYTrSOC8XcQailWglEXc6huFeM408W9WcBSG(bmTrccFE3srOT8osBq4Lhc4U(H6O6WOfHRwK29SwTMzCeubx4CBOkfXnd15FHtfnjj6zTAnZ4iOcUW52qvkIBwr910ZA1Aga)cCiWm1fb1rthvxMkAq9PGmd15FHbkQaOPZrEFn9SwTMHcQpctzmu5JzOo)lCQOcGMoh5jjwRwZqb1hHPSAv(ygQZ)cNkQaOPZrEFonpCpSWglOFatBKGxv7hcTH4bfLpFqrhwBTq730EO2q4n3srAoFqrN5(okFWm4tPQfWrJhLdBuaqni85DlfzaHxEiG76hQJQdZP5H7Hf2yb9dyAJKoiSA)qOnepOO85dk6WARfA)M2d1gcV5wksZ5dk6m33r5dMbFkvTIPbnA8OCyJcaQbHpVBPidi8YdbCx)qDuDyonpCpSWglOFatBKGpsP8j3u(qOnepOO85dk6WARfA)M2d1gcV5wksZ5dk6m33r5dMbFkvTaoaBOo)lSgpkh2OaGAq4Z7wkYacV8qa31puhvhMtdPzj2aJflWILail6(BdUowcEu0xO408W9WcBSG(bmTrsdobkdB5YV1qO9BA7r5WgfaKtdPzb97IG6OHLyalqw0TrflUfCDSCqwO6OHfNLI0XsmGPu)SO7lqOow8cKfSJGyPbhwqwkrI(wbonpCpSWglOFatBKqDrqD0KTGfiA)M29OG6JWKrTkFYfH8ljHcQpctgmu5tUiKFjjuq9ryY4v8Cri)ssSwTMXYvEfOmSLDLkFBFHcNl)wdzgQZ)cNkaZGMKeRvRzSCLxbkdBzxPY32xOWzFcErMH68VWPcWmOjjXX34QCeuhnPcqtxtacvGqDLj45VcMHCW4A0dCwpOPG5aiUVMEbiubc1vMGN)kygQZ)cNAmtpjjaHkqOUYe88xbZqoy8(jjFD0ebv(rG52JA7Yd15FHbQwPZPH0SeBGOplZJA7yXIAWHyzH)cflilLCAE4EyHnwq)aM2iPTM4zyltQvrO9BAhGqfiuxzcE(RGzihmUge(8ULImbWCawG)9WstphFJRYrqD0KkanDn6fGiOYRZupQTl3CkjjarqLxNPEuBxU5KghFJRYrqD0au0l9(A0larqLxNbbv3w8rtp9cqeu51zQh12LBoLKeGqfiuxzcWcbeqkFBugh9ZFyZqoy8(A0dCwpOPG5aiMtdPzbzPej6Bfyr3gvS4hla00bglPedGzPhCuqD0WYT5flOx6SKsmaMfD)TXcYGfciGuFw093gCDSOG4VqXY9DelFXsmuqiOAHpw8cKf1xelRiw093glidwiGasS8nw(JfDoMfqchVceiNMhUhwyJf0pGPnsq4Z7wkcTL3rAhaZbyb(3dRSf0p0IWvlsB9aN1dAkyoaI1GWN3TuKjaMdWc8VhwA61ZX34QCeuhnPcqtxtpRvRza8lWHaZuxeuhnDuDzQOb1NcYSIss0larqLxNbW4Z7v)KeRvRzSuqiOAHpZksJ1Q1mwkieuTWNzOo)lmqTwTMj45VcgW143dR(jjFD0ebv(rG52JA7Yd15FHbQ1Q1mbp)vWaUg)EyLKeGiOYRZupQTl3CQVME6fGiOYRZupQTl3CkjPNJVXv5iOoAak6LEsci8mT1epdBzsTkYCFaWVq1xtpe(8ULImbyHaciLbjC8kKKeGqfiuxzcWcbeqkFBugh9ZFyZqoy8(9508W9WcBSG(bmTrsGue(ExLD1JQ6O6q730gHpVBPitamhGf4FpSYwq)408W9WcBSG(bmTrYxbFk)EyH2VPncFE3srMayoalW)EyLTG(XPH0SG(4778JWSSb1Xs3kSXskXayw8HybL)fbYsenSGPaSa508W9WcBSG(bmTrccFE3srOT8osBhhbGPzNcOfHRwK2uq9ryY8vwTkFaEacs1d3dld(8P9dziKtH1r577iGPhfuFeMmFLvRYhGVhWbyNRO6my4sLHT8Tr5gCi8zOYTueiWhZ(ivpCpSm6g)2meYPW6O89DeWs3aeKkoIuQ8MJpItdPzj2U6Iyz)8bVgueMfDBuXYTrS0EuBhlpMf3cUowoilubIwwAdvPiolpMf3cUowoilubIwwIdxS4dXIFSaqthySKsmaMLVyXlwq)G6JWeAzbzPej6Bfyr54dZIxWBJgwaiadtbmlWHL4Wfl6Glfilqe0e8iw6GdXYT5flCIwPZskXayw0TrflXHlw0bxkWcDhl7Np41GIyPG6408W9WcBSG(bmTrc(8bVgueA)M29(6OjcQ8JaZTh12LhQZ)cdu0ljPN1Q1mJJGk4cNBdvPiUzOo)lmqrfanDoYb(a9QEo(gxLJG6ObPgZ07RXA1AMXrqfCHZTHQue3SI63pjPNJVXv5iOoAagcFE3srghhbGPzNcaV1Q1muq9rykJHkFmd15FHbgi8mT1epdBzsTkYCFaqCEOo)lGhig0KQwALEsIJVXv5iOoAagcFE3srghhbGPzNcaV1Q1muq9rykRwLpMH68VWadeEM2AINHTmPwfzUpaiopuN)fWdedAsvlTsVVgkO(imz(k7vCn90ZA1AMGN)kywrjj6DUIQZGpFuWb0qLBPiW(A61tVaeQaH6ktWZFfmROKKaebvEDgaJpVxA0laHkqOUYqDrqD0KTGfOzf1pjjarqLxNPEuBxU5uFn90larqLxNbbv3w8jjrpRvRzcE(RGzfLK44BCvocQJMubOP3pjP35kQod(8rbhqdvULIa1yTAntWZFfmRin9SwTMbF(OGdObFEaqGgZKehFJRYrqD0Kkan9(9tsSwTMj45VcMvKg9SwTMzCeubx4CBOkfXnRin6DUIQZGpFuWb0qLBPiqonKMLyhtSaGcclmlFXI(SkFyb9dQpctS4filyhbXcszCvdyXMLsXcakiSyPbhwqwkrI(wbonpCpSWglOFatBKuKUChewO9BA3ZA1AgkO(imLvRYhZqD(x4ujKtH1r577OKKEHnFqryTbIMHcB(GIY33rafn9tscB(GIWAhZ(A8OCyJcaYP5H7Hf2yb9dyAJKnx1YDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ00laHkqOUYe88xbZqD(x4urt6jjbiubc1vMaSqabKY3gLXr)8h2muN)fov0KE)KKEHnFqryTbIMHcB(GIY33rafn9tscB(GIWAhZ(A8OCyJcaYP5H7Hf2yb9dyAJK2sPYDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ00laHkqOUYe88xbZqD(x4urt6jjbiubc1vMaSqabKY3gLXr)8h2muN)fov0KE)KKEHnFqryTbIMHcB(GIY33rafn9tscB(GIWAhZ(A8OCyJcaYPH0SGuarFwGflbqonpCpSWglOFatBKOZN5Htg2YKAveNgsZsSJjw2pFA)qSCqwIgyGLDOYhwq)G6JWelWHfDBuXYxSalvCw0Nv5dlOFq9ryIfVazzHjwqkGOplrdmGz5BS8fl6ZQ8Hf0pO(imXP5H7Hf2yb9dyAJe85t7hcTFtBkO(imz(kRwLpjjuq9ryYGHkFYfH8ljHcQpctgVINlc5xsI1Q1m68zE4KHTmPwfzwrASwTMHcQpctz1Q8XSIss6zTAntWZFfmd15FHbQhUhwgDJFBgc5uyDu((osJ1Q1mbp)vWSI6ZP5H7Hf2yb9dyAJeDJFBCAE4EyHnwq)aM2izwv2d3dRS6XhAlVJ0U5k1TnlononKML9Zh8AqrS0GdlDqeuhvhlRsrymll8xOyjgWuQFonpCpSWMMRu32S0gF(GxdkcTFtB9Mvrn4GImwUYRaLHTSRu5B7luydbCxFuebYPH0SGmhFSCBelGWJfD)TXYTrS0bXhl33rSCqwCqqww19kwUnILoh5SaUg)EyXYJzz7pdl7RQ9dXYqD(xyw6wQ7JupbYYbzPZVWglDqy1(HybCn(9WItZd3dlSP5k1TnlGPnsWRQ9dH2q8GIYNpOOdRTwO9BAdcpthewTFiZqD(x4uhQZ)cd8abiivTaiCAE4EyHnnxPUTzbmTrshewTFiononKMLyhtSSF(GxdkILdYcGefXYkILBJyj2oK3z9finSyTAnw(gl)XIo4sbYcH8OFiwSOgCiwAF94TVqXYTrSueYpwco(yboSCqwaxDrSyrn4qSGmyHaciXP5H7Hf2GpTXNp41GIq730Ewf1GdkYCFhPdovgCiVZ6lqA00JcQpctMVYEfxJE96zTAnZ9DKo4uzWH8oRVaPXmuN)fovpCpSm6g)2meYPW6O89DeWs3OLMEuq9ryY8v2cEBjjuq9ryY8vgdv(KKqb1hHjJAv(Klc5x)KeRvRzUVJ0bNkdoK3z9finMH68VWP6H7HLbF(0(HmeYPW6O89DeWs3OLMEuq9ryY8vwTkFssOG6JWKbdv(Klc5xscfuFeMmEfpxeYV(9ts0ZA1AM77iDWPYGd5DwFbsJzf1pjPN1Q1mbp)vWSIssq4Z7wkYeGfciGugKWXRqFnbiubc1vMaSqabKY3gLXr)8h2mKdgxtaIGkVot9O2UCZP(A6PxaIGkVodGXN3RKKaeQaH6kd1fb1rt2cwGMH68VWPcq6RPN1Q1mbp)vWSIss0laHkqOUYe88xbZqoy8(CAinlXoMyjLGE09iiw215thl62OILBJgILhZsbzXd3JGybRZNo0YIJzr5hXIJzjcIXVLIybwSG15thl6(BJfGWcCyPr6OHf85baXSahwGflolXeySG15thlyil3MFSCBelfPJfSoF6yXN5rqywaqEHpw82rdl3MFSG15thleYJ(HWCAE4EyHn4dyAJeh0JUhbLX68PdTH4bfLpFqrhwBTq730wpq4zCqp6EeugRZNUmO35OiZ9ba)cLg98W9WY4GE09iOmwNpDzqVZrrMVYn1JA700tpq4zCqp6EeugRZNU8g5kZ9ba)cvsci8moOhDpckJ15txEJCLzOo)lCQOPFsci8moOhDpckJ15txg07CuKbFEaqGgtnGWZ4GE09iOmwNpDzqVZrrMH68VWanMAaHNXb9O7rqzSoF6YGENJIm3ha8luCAinlXoMWSGmyHaciXY3ybzPej6Bfy5XSSIyboSehUyXhIfqchVcFHIfKLsKOVvGfD)TXcYGfciGelEbYsC4IfFiwSifuhlOx6SKsmaMtZd3dlSbFatBKeGfciGu(2Omo6N)WO9BARh4SEqtbZbqSME9q4Z7wkYeGfciGugKWXRGg9cqOceQRmbp)vWmKdgxJEZQOgCqrMO57Gd47QSpbV(qoAPW(KKyTAntWZFfmRO(AC8nUkhb1rdq1g9sxtpRvRzOG6JWuwTkFmd15FHtvR0tsSwTMHcQpctzmu5JzOo)lCQALE)KK2JA7Yd15FHbQwPRrVaeQaH6ktWZFfmd5GX7ZPH0SGmyb(3dlwAWHfxPybeEywUn)yPZbKWSGxdXYTrXzXhQq3XYqTHWBeil62OIfaeocQGlmlXMHQueNLnhZIIWywUnVybnSGPaMLH68V(cflWHLBJybW4Z7flwRwJLhZIBbxhlhKLMRuSaBnwGdlEfNf0pO(imXYJzXTGRJLdYcH8OFionpCpSWg8bmTrccFE3srOT8osBq4Lhc4U(H6O6WOfHRwK29SwTMzCeubx4CBOkfXnd15FHtfnjj6zTAnZ4iOcUW52qvkIBwr91ON1Q1mJJGk4cNBdvPiEg)vBPYBXXhnVBwrA6zTAndGFboeyM6IG6OPJQltfnO(uqMH68VWafva005iVVMEwRwZqb1hHPmgQ8XmuN)fovubqtNJ8KeRvRzOG6JWuwTkFmd15FHtfva005ipjPNEwRwZqb1hHPSAv(ywrjj6zTAndfuFeMYyOYhZkQVg9oxr1zWqf((azOYTueyFonKMfKblW)EyXYT5hlHnkaiMLVXsC4IfFiwGRd)Geluq9ryILdYcSuXzbeESCB0qSahwEufCiwUThZIU)2yzhQW3hionpCpSWg8bmTrccFE3srOT8osBq4LHRd)GuMcQpctOfHRwK290ZA1AgkO(imLXqLpMvKg9SwTMHcQpctz1Q8XSI6NKCUIQZGHk89bYqLBPiqonpCpSWg8bmTrshewTFi0gIhuu(8bfDyT1cTFt7HAdH3ClfPPN1Q1muq9rykJHkFmd15FHtDOo)lCsI1Q1muq9rykRwLpMH68VWPouN)fojbHpVBPidi8YW1HFqktb1hHP(AgQneEZTuKMZhu0zUVJYhmd(uQAbenEuoSrba1GWN3TuKbeE5HaURFOoQomNMhUhwyd(aM2ibVQ2peAdXdkkF(GIoS2AH2VP9qTHWBULI00ZA1AgkO(imLXqLpMH68VWPouN)fojXA1AgkO(imLvRYhZqD(x4uhQZ)cNKGWN3TuKbeEz46WpiLPG6JWuFnd1gcV5wksZ5dk6m33r5dMbFkvTaIgpkh2OaGAq4Z7wkYacV8qa31puhvhMtZd3dlSbFatBKGpsP8j3u(qOnepOO85dk6WARfA)M2d1gcV5wkstpRvRzOG6JWugdv(ygQZ)cN6qD(x4KeRvRzOG6JWuwTkFmd15FHtDOo)lCsccFE3srgq4LHRd)GuMcQpct91muBi8MBPinNpOOZCFhLpyg8Pu1c4OXJYHnkaOge(8ULImGWlpeWD9d1r1H50qAwIDmXsSbglwGflbqw093gCDSe8OOVqXP5H7Hf2GpGPnsAWjqzylx(TgcTFtBpkh2OaGCAinlXoMybP0xGdbYYE0p)Hzr3FBS4vCwuWcflubxO2yr547luSG(b1hHjw8cKLBIZYbzr9fXYFSSIyr3FBSaGxkSpS4fililLirFRaNMhUhwyd(aM2iH6IG6OjBblq0(nT71ZA1AgkO(imLXqLpMH68VWPQv6jjwRwZqb1hHPSAv(ygQZ)cNQwP3xtacvGqDLj45VcMH68VWPgZ010ZA1AMO57Gd47QSpbV(qoAPW(yq4QfbuGGEPNKO3SkQbhuKjA(o4a(Uk7tWRpKJwkSpgc4U(OicSF)KeRvRzIMVdoGVRY(e86d5OLc7JbHRwuQAdeaw6jjbiubc1vMGN)kygYbJRXX34QCeuhnPcqtNtdPzj2XelilLirFRal6(BJfKbleqajKGu6lWHazzp6N)WS4filGWcDhlqe0OB(JybaVuyFyboSOBJkwIHccbvl8XIo4sbYcH8OFiwSOgCiwqwkrI(wbwiKh9dH508W9WcBWhW0gji85DlfH2Y7iTdG5aSa)7HvgFOfHRwK26boRh0uWCaeRbHpVBPitamhGf4FpS00RxacvGqDLH6IIpKRYWbS8kqMH68VWavlGdady90slGFwf1GdkYG)QTu5T44JM37RHaURpkIanuxu8HCvgoGLxbQFsIJVXv5iOoAsvBaA6A6P35kQotBnXZWwMuRImu5wkcmjXA1AMGN)kyaxJFpSsnaHkqOUY0wt8mSLj1QiZqD(xyGbq6RbHpVBPiZTnVsLXebinzD(FA6zTAndGFboeyM6IG6OPJQltfnO(uqMvusIEbicQ86magFEV6R58bfDM77O8bZGpLQ1Q1mbp)vWaUg)Eyb8PBayjjTh12LhQZ)cduRvRzcE(RGbCn(9WkjjarqLxNPEuBxU5usI1Q1mwkieuTWNzfPXA1AglfecQw4ZmuN)fgOwRwZe88xbd4A87HfW6bqb(zvudoOit08DWb8Dv2NGxFihTuyFmeWD9rrey)(A0ZA1AMGN)kywrA6PxaIGkVot9O2UCZPKKaeQaH6ktawiGas5BJY4OF(dBwrjjTh12LhQZ)cd0aeQaH6ktawiGas5BJY4OF(dBgQZ)cdmGtss7rTD5H68VWivKQwaK0bQ1Q1mbp)vWaUg)Ey1NtdPzj2Xel3gXcasuDBXhw093glolilLirFRal3MFS84cDhlTb2XcaEPW(WP5H7Hf2GpGPnsghbvWfo3gQsrC0(nTTwTMj45VcMH68VWPQfAssSwTMj45VcgW143dlGgZ01GWN3TuKjaMdWc8Vhwz8XP5H7Hf2GpGPnscKIW37QSREuvhvhA)M2i85DlfzcG5aSa)7HvgFA6PN1Q1mbp)vWaUg)EyLAmtpjrVaebvEDgeuDBXN(jjwRwZmocQGlCUnuLI4MvKgRvRzghbvWfo3gQsrCZqD(xyGcqbwawGR)mrdfEmLD1JQ6O6m33rzeUAraRNEwRwZyPGqq1cFMvKg9oxr1zWNpk4aAOYTueyFonpCpSWg8bmTrYxbFk)EyH2VPncFE3srMayoalW)EyLXhNgsZcas(8ULIyzHjqwGflU1R(7jml3MFSOZRJLdYIfXc2rqGS0GdlilLirFRalyil3MFSCBuCw8HQJfDo(iqwaqEHpwSOgCiwUnQJtZd3dlSbFatBKGWN3TueAlVJ0g7iOCdo5GN)kGweUArARxacvGqDLj45VcMHCW4jj6HWN3TuKjaleqaPmiHJxbnbicQ86m1JA7YnNssaN1dAkyoaI50qAwIDmHzj2arFw(glFXIxSG(b1hHjw8cKLBEcZYbzr9fXYFSSIyr3FBSaGxkSpOLfKLsKOVvGfVazjLGE09iiw215thNMhUhwyd(aM2iPTM4zyltQvrO9BAtb1hHjZxzVIRXJYHnkaOgRvRzIMVdoGVRY(e86d5OLc7JbHRweqbc6LUMEGWZ4GE09iOmwNpDzqVZrrM7da(fQKe9cqeu51zkkmqfCa7RbHpVBPid2rq5gCYbp)vqtpRvRzghbvWfo3gQsrCZqD(xyGcqbG9qdWpRIAWbfzWF1wQ8wC8rZ791yTAnZ4iOcUW52qvkIBwrjj6zTAnZ4iOcUW52qvkIBwr950qAwIDmXca6IUnw2pFAUsXs0adyw(gl7NpnxPy5Xf6owwrCAE4EyHn4dyAJe85tZvk0(nTTwTMbw0THZr0eOO7HLzfPXA1Ag85tZvkZqTHWBULI408W9WcBWhW0gjbVcKkBTAn0wEhPn(8rbhq0(nTTwTMbF(OGdOzOo)lmqrJMEwRwZqb1hHPmgQ8XmuN)fov0KKyTAndfuFeMYQv5JzOo)lCQOPVghFJRYrqD0KkanDonKMLy7QlcZskXaywSOgCiwqgSqabKyzH)cfl3gXcYGfciGelbyb(3dlwoilHnkailFJfKbleqajwEmlE4wUsfNf3cUowoilwelbhFCAE4EyHn4dyAJe85dEnOi0(nTdqeu51zQh12LBoPbHpVBPitawiGaszqchVcAcqOceQRmbyHaciLVnkJJ(5pSzOo)lmqrJg9aN1dAkyoaI1qb1hHjZxzVIRXX34QCeuhnPIEPZPH0Se7yIL9ZNMRuSO7Vnw2psP8HLy78TJfVazPGSSF(OGdiAzr3gvSuqw2pFAUsXYJzzfHwwIdxS4dXYxSOpRYhwq)G6JWeln4WcabyykGzboSCqwIgyGfa8sH9HfDBuXIBbrqSaqtNLuIbWSahwCWi)EeelyD(0XYMJzbGammfWSmuN)1xOyboS8yw(ILM6rTDgwIf8iwUn)yzvG0WYTrSG9oILaSa)7HfML)qhMfWimlfTUXvSCqw2pFAUsXc4A(cflaiCeubxywIndvPioAzr3gvSehUqhil47vkwOcKLvel6(BJfaA6aZXrS0Gdl3gXIYXhlOuqlxHnCAE4EyHn4dyAJe85tZvk0(nTpxr1zWhPu(KbNVDgQClfbQrVZvuDg85JcoGgQClfbQXA1Ag85tZvkZqTHWBULI00ZA1AgkO(imLvRYhZqD(x4ubiAOG6JWK5RSAv(OXA1AMO57Gd47QSpbV(qoAPW(yq4QfbuGGM0tsSwTMjA(o4a(Uk7tWRpKJwkSpgeUArPQnqqt6AC8nUkhb1rtQa00tsaHNXb9O7rqzSoF6YGENJImd15FHtfGKK4H7HLXb9O7rqzSoF6YGENJImFLBQh121xtacvGqDLj45VcMH68VWPQv6CAinlXoMyz)8bVguelaOl62yjAGbmlEbYc4QlILuIbWSOBJkwqwkrI(wbwGdl3gXcasuDBXhwSwTglpMf3cUowoilnxPyb2ASahwIdxOdKLGhXskXayonpCpSWg8bmTrc(8bVgueA)M2wRwZal62W5GI8jJ4XpSmROKeRvRza8lWHaZuxeuhnDuDzQOb1NcYSIssSwTMj45VcMvKMEwRwZmocQGlCUnuLI4MH68VWafva005ih4d0R654BCvocQJgKAmtVpWIjWFUIQZuKUChewgQClfbQrVzvudoOid(R2sL3IJpAExJ1Q1mJJGk4cNBdvPiUzfLKyTAntWZFfmd15FHbkQaOPZroWhOx1ZX34QCeuhni1yME)KeRvRzghbvWfo3gQsr8m(R2sL3IJpAE3SIss0ZA1AMXrqfCHZTHQue3SI0OxacvGqDLzCeubx4CBOkfXnd5GXts0larqLxNbbv3w8PFsIJVXv5iOoAsfGMUgkO(imz(k7vConKMf9pXz5GS05asSCBelwe(yb2yz)8rbhqwSIZc(8aGFHIL)yzfXcWD9bavXz5lw8kolOFq9ryIfR1XcaEPW(WYJRJf3cUowoilwelrdmeiqonpCpSWg8bmTrc(8bVgueA)M2NRO6m4ZhfCanu5wkcuJEZQOgCqrM77iDWPYGd5DwFbsJMEwRwZGpFuWb0SIssC8nUkhb1rtQa007RXA1Ag85JcoGg85babAm10ZA1AgkO(imLXqLpMvusI1Q1muq9rykRwLpMvuFnwRwZenFhCaFxL9j41hYrlf2hdcxTiGceaw6A6fGqfiuxzcE(RGzOo)lCQALEsIEi85DlfzcWcbeqkds44vqtaIGkVot9O2UCZP(CAinlOp((o)imlBqDS0TcBSKsmaMfFiwq5FrGSerdlykalqonpCpSWg8bmTrccFE3srOT8osBhhbGPzNcOfHRwK2uq9ryY8vwTkFaEacs1d3dld(8P9dziKtH1r577iGPhfuFeMmFLvRYhGVhWbyNRO6my4sLHT8Tr5gCi8zOYTueiWhZ(ivpCpSm6g)2meYPW6O89DeWs3GEObPIJiLkV54Jaw6g0a8NRO6mLFRHWzlx5vGmu5wkcKtdPzj2U6Iyz)8bVguelFXIZcadyykWYou5dlOFq9rycTSacl0DSOOJL)yjAGbwaWlf2hw6DB(XYJzzZlqfbYIvCwO)2OHLBJyz)8P5kflQViwGdl3gXskXa4ubOPZI6lILgCyz)8bVguuF0YciSq3Xcebn6M)iw8Ifa0fDBSenWalEbYIIowUnIf3cIGyr9fXYMxGkIL9ZhfCa508W9WcBWhW0gj4Zh8AqrO9BAR3SkQbhuK5(oshCQm4qEN1xG0OPN1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlcOabGLEsI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlcOabnPR5CfvNbFKs5tgC(2zOYTueyFn9OG6JWK5RmgQ8rJJVXv5iOoAagcFE3srghhbGPzNcaV1Q1muq9rykJHkFmd15FHbgi8mT1epdBzsTkYCFaqCEOo)lGhig0Kkaj9KekO(imz(kRwLpAC8nUkhb1rdWq4Z7wkY44iamn7ua4TwTMHcQpctz1Q8XmuN)fgyGWZ0wt8mSLj1QiZ9baX5H68VaEGyqtQa007RrpRvRzGfDB4Cenbk6EyzwrA07CfvNbF(OGdOHk3srGA6fGqfiuxzcE(RGzOo)lCQaSKemCPS(c0CBZRuzmrasJHk3srGASwTM52MxPYyIaKgd(8aGanMXea2Bwf1GdkYG)QTu5T44JM3bE00xt7rTD5H68VWPQv6PRP9O2U8qD(xyGcK0tVVMEbiubc1vga)cCiWmo6N)WMH68VWPcWss0larqLxNbW4Z7vFonKMLyhtSaGcclmlFXI(SkFyb9dQpctS4filyhbXcszCvdyXMLsXcakiSyPbhwqwkrI(wbw8cKfKsFboeilOFxeuhnDuDCAE4EyHn4dyAJKI0L7GWcTFt7EwRwZqb1hHPSAv(ygQZ)cNkHCkSokFFhLK0lS5dkcRnq0muyZhuu((ocOOPFssyZhuew7y2xJhLdBuaqni85DlfzWock3Gto45VcCAE4EyHn4dyAJKnx1YDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ0OxaIGkVodGXN3RKKEwRwZa4xGdbMPUiOoA6O6YurdQpfKzfPjarqLxNbW4Z7v)KKEHnFqryTbIMHcB(GIY33rafn9tscB(GIWAhZKeRvRzcE(RGzf1xJhLdBuaqni85DlfzWock3Gto45VcA6zTAnZ4iOcUW52qvkIBgQZ)cd0EObaceGFwf1GdkYG)QTu5T44JM37RXA1AMXrqfCHZTHQue3SIss0ZA1AMXrqfCHZTHQue3SI6ZP5H7Hf2GpGPnsAlLk3bHfA)M29SwTMHcQpctz1Q8XmuN)fovc5uyDu((osJEbicQ86magFEVss6zTAndGFboeyM6IG6OPJQltfnO(uqMvKMaebvEDgaJpVx9ts6f28bfH1giAgkS5dkkFFhbu00pjjS5dkcRDmtsSwTMj45VcMvuFnEuoSrba1GWN3TuKb7iOCdo5GN)kOPN1Q1mJJGk4cNBdvPiUzOo)lmqrJgRvRzghbvWfo3gQsrCZksJEZQOgCqrg8xTLkVfhF08EsIEwRwZmocQGlCUnuLI4MvuFonKMLyhtSGuarFwGflbqonpCpSWg8bmTrIoFMhozyltQvrCAinlXoMyz)8P9dXYbzjAGbw2HkFyb9dQpctOLfKLsKOVvGLnhZIIWywUVJy528IfNfKIXVnwiKtH1rSOO2XcCybwQ4SOpRYhwq)G6JWelpMLveNMhUhwyd(aM2ibF(0(Hq730McQpctMVYQv5tscfuFeMmyOYNCri)ssOG6JWKXR45Iq(LK0ZA1AgD(mpCYWwMuRImROKeCePu5nhFeqt3GEOrJEbicQ86miO62Ipjj4isPYBo(iGMUb90eGiOYRZGGQBl(0xJ1Q1muq9rykRwLpMvusspRvRzcE(RGzOo)lmq9W9WYOB8BZqiNcRJY33rASwTMj45VcMvuFonKMLyhtSGum(TXc82Or3Jjw0T9HnwEmlFXYou5dlOFq9rycTSGSuIe9TcSahwoilrdmWI(SkFyb9dQpctCAE4EyHn4dyAJeDJFBCAinlXgxPUTzXP5H7Hf2GpGPnsMvL9W9WkRE8H2Y7iTBUsDBZY(SpBBa]] )

end