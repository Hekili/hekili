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


    spec:RegisterPack( "Balance", 20210829, [[dife7fqikjpcIuxcIK2eK6tKqgLuLtjv1Qau1RauMfjWTKkP2ff)cIyykfogjQLPuYZekzAusPRrcABkfvFdqLgNqfoNsrADaQyEkL6EKi7tOQ)brIuhuQeluOupeIQjkuOUiLuSrLIWhfkezKcfI6KcfSsPs9sisuZKeQUPsrKDkuPFQue1qvkkhfIejlvOq6PamvkP6Qcv0wfke(kejmwPsYEfYFf1GjomvlMKESGjd0Lr2Su(mKmALQtRYQHir8Aaz2K62I0UL8BqdNsDCsOSCfphQPRQRRKTdHVtjgpeLZlvSEHIMVi2pQJuoY6raa9NII7wBSLYBehBTPgL3CRDZ3kwra(o2ueaBpaKJIIauEkfbi2U2RafbW27OHoyK1JaGHRjqra2)3gdCqcsuDTxbQRXxAWG6(9LQ5Gij2U2Ra11aUuKJKuqZ(NQrkD70KsQU2RazEK9rauxN(JHksncaO)uuC3AJTuEJ4yRn1O8MBTkuHBAeaF97WjcaGlf5ra2pqqQIuJaas4qeGy7AVcelX4zDGC3DzHAHFw2AtvalBTXwkZDZDJ8DVqryGd3DxZsxabjqwaa1(WsSjp1WD31SG8DVqrGS8(GI(81yj4ycZYdzj0jOP87dk6XgU7UMLyukfIGazzvffim2NoSGWNZv1eMLENHmkGf7HqKXVp41GIyPRJNf7HqyWVp41GI6B4U7Aw6cc4bYI9qbh)xHIfKIX)DwUgl3Riml)oXILbwOyXAc6ZgtgU7UMLnjhiIfKdleqGiw(DIfa23CpMfNf99VMyjfoelnnHStvtS07AS0bUyz3blf9SSFpl3Zc(sx63lcUW6oSy5(DwI9MCxSolaJfKtAc)NRzPl6dvLs1RawUxrGSGb6S7B4U7Aw2KCGiwsH4Nff1ou7FEOu)kSIybhOYNdIzXTT1Dy5HSOcXywAhQ9hZcS0DmC3DnlwFi)zX6WuIfyJLyR9DwIT23zj2AFNfhZIZc2McNRz5NRaIEd3DxZYMSnv0WsVZqgfWcsX4)UcybPy8FxbSa49PDd1NLuhKyjfoeldHp9r1ZYdzH8rF0WsaMQ6FxJFFEd3n3DxQc((tGSeBx7vGyPlBMIZsWlwujwAWvbYI)SS)Vng4GeKO6AVcuxJV0Gb197lvZbrsSDTxbQRbCPihjPGM9pvJu62PjLuDTxbY8i7JaOp8JJSEeaOnv0ez9O4QCK1JaqLRQjWOyhbWd)bRiawg)3Jaas4WC2)bRiaB2qbh)SSflifJ)7S4filolaEFWRbfXcSybG1zXY97Se3d1(ZYMWjw8cKLyd7I1zboSa49PDdXc83PXYHPiaH5EAopcqpwOG(SXKrVkFYfHSNLKewOG(SXK5QmgQ9HLKewOG(SXK5QSk83zjjHfkOpBmz8QtUiK9S0Nf0SypecJYglJ)7SGMfRyXEieMTmwg)3J(O4UvK1JaqLRQjWOyhbWd)bRia43N2nueGWCpnNhbWkwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHfRyjarqLxVPou7FU5eljjSyflyBsRZVpOOhBWVpnxRzrjwuMLKewSIL31u9MY)1q4SQR9kqgQCvnbYsscl9yHc6Zgtgmu7tUiK9SKKWcf0NnMmxL1RYhwssyHc6ZgtMRYQWFNLKewOG(SXKXRo5Iq2Zs)ia6ROCamcGcJ(O4gRiRhbGkxvtGrXocGh(dwraWVp41GIIaeM7P58iaZQOgCqrgvx7vGYWw2168VFfkSHkxvtGSGMLaebvE9M6qT)5MtSGMfSnP153hu0Jn43NMR1SOelkhbqFfLdGrauy0h9raaPMV0FK1JIRYrwpcGh(dwraWqTpzvYtJaqLRQjWOyh9rXDRiRhbGkxvtGrXocqyUNMZJa8xkXY2S0JLTyb4zXd)blJLX)DtWXF(VuIfGXIh(dwg87t7gYeC8N)lLyPFeap8hSIaeCTo7H)GvwF4pcG(WFU8ukca0MkAI(O4gRiRhbGkxvtGrXoca0ocaM(iaE4pyfbaHpNRQPiaiC9IIaGTjTo)(GIESb)(0CTML4zrzwqZspwSIL31u9g87JgoGgQCvnbYssclVRP6n4N0AFYGZ1EdvUQMazPpljjSGTjTo)(GIESb)(0CTML4zzRiaGeomN9FWkcaa6XS0fO1WcSyjwaJfl3VdxplGZ1Ew8cKfl3VZcG3hnCazXlqw2cySa)DASCykcacFYLNsraoC2Hu0hfxRnY6raOYv1eyuSJaaTJaGPpcGh(dwraq4Z5QAkcacxVOiayBsRZVpOOhBWVpTBiwINfLJaas4WC2)bRiaaOhZsqtocIfl7uXcG3N2nelbVyz)Ew2cyS8(GIEmlw2VWolhMLH0ecVEwAWHLFNyXAc6ZgtS8qwujwShQrZqGS4filw2VWolTtRPHLhYsWXFeae(KlpLIaC4Cqtock6JIRcJSEeaQCvnbgf7iaq7iay6Ja4H)Gveae(CUQMIaGW1lkcG9qimPqy1UHyjjHf7HqyWRQDdXsscl2dHWGFFWRbfXsscl2dHWGFFAUwZsscl2dHW0wtNmSLj9QiwssyrD1AMGNVkygk1VcZIsSOUAntWZxfmGRX)dwSKKWI9qimJJGk4cNBdvXSdljjSGWNZv1K5WzhsraajCyo7)GveGye(CUQMy539NLWofacZY1yPdCXIpelxXIZcQailpKfhb8az53jwW3V8)Gflw2PHyXz5NRaIEwOpWYHzzHjqwUIfv6TquXsWXpocacFYLNsraUkJkag9rXDZJSEeaQCvnbgf7iaE4pyfbqLgmnaDfQiaGeomN9FWkcqCIjwInnyAa6kuSy5(DwqExqsmubwGdlE7PHfKdleqGiwUIfK3fKedvicqyUNMZJa0JLESyflbicQ86n1HA)ZnNyjjHfRyjaHAqOLYeGfciqu(3Pm2(M7XMLnl9zbnlQRwZe88vbZqP(vywINfLvilOzrD1AMXrqfCHZTHQy2XmuQFfMLTzXAzbnlwXsaIGkVEdcQ(9odljjSeGiOYR3GGQFVZWcAwuxTMj45RcMLnlOzrD1AMXrqfCHZTHQy2XSSzbnl9yrD1AMXrqfCHZTHQy2XmuQFfMLTzrzLzPRzrHSa8SmRIAWbfzWx1w68Eh8tZ5gQCvnbYssclQRwZe88vbZqP(vyw2MfLvMLKewuMfKWc2M068UJFILTzrzJcvil9zPplOzbHpNRQjZvzubWOpkUa3iRhbGkxvtGrXocqyUNMZJaOUAntWZxfmdL6xHzjEwuwHSGMLESyflZQOgCqrg8vTLoV3b)0CUHkxvtGSKKWI6Q1mJJGk4cNBdvXSJzOu)kmlBZIYaxw6Aw2IfGNf1vRzu1qiOEHFZYMf0SOUAnZ4iOcUW52qvm7yw2S0NLKewuHymlOzPDO2)8qP(vyw2MLTuyeaqchMZ(pyfbyZGplwUFNfNfK3fKedvGLF3FwoCPONfNLnBPX(WI9adSahwSStfl)oXs7qT)SCywCv46z5HSqfyeap8hSIayd)dwrFuCJJiRhbGkxvtGrXoca0ocaM(iaE4pyfbaHpNRQPiaiC9IIaeOtZspw6Xs7qT)5Hs9RWS01SOSczPRzjaHAqOLYe88vbZqP(vyw6Zcsyr54ydw6ZIsSeOtZspw6Xs7qT)5Hs9RWS01SOSczPRzjaHAqOLYeGfciqu(3Pm2(M7XgW14)blw6AwcqOgeAPmbyHaceL)DkJTV5ESzOu)kml9zbjSOCCSbl9zbnlwXY4hyMqq1BCqqSHq2HFmljjSeGqni0szcE(QGzOu)kmlXZYvpn2qT)eyUDO2)8qP(vywssyzwf1GdkYeinH)Z1zS9n3Jnu5QAcKf0SeGqni0szcE(QGzOu)kmlXZsS2GLKewcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlXZYvpn2qT)eyUDO2)8qP(vyw6AwuEdwssyXkwcqeu51BQd1(NBofbaKWH5S)dwraqURdlT)eMfl70Vtdll8vOyb5WcbeiILcAHflNwZIR1qlS0bUy5HSG)tRzj44NLFNyb7PelEkCvplWglihwiGarad5DbjXqfyj44hhbaHp5YtPiabyHaceLbjCNke9rXDtJSEeaQCvnbgf7iaq7iay6Ja4H)Gveae(CUQMIaGW1lkcqpwAhQ9ppuQFfML4zrzfYssclJFGzcbvVXbbXMRyjEwu4gS0Nf0S0JLES0JfsXwNTnbAOu7od56mCalVcelOzPhlbiudcTugk1UZqUodhWYRazgk1VcZY2SO8MVbljjSeGiOYR3GGQFVZWcAwcqOgeAPmuQDNHCDgoGLxbYmuQFfMLTzr5nh4YcWyPhlkRmlaplZQOgCqrg8vTLoV3b)0CUHkxvtGS0NL(SGMfRyjaHAqOLYqP2DgY1z4awEfiZqoyhw6ZssclKIToBBc0GHlTM()ku5zP2Hf0S0JfRyjarqLxVPou7FU5eljjSeGqni0szWWLwt)FfQ8Su7KJL1QW4ydLndL6xHzzBwuwzRLL(SKKWspwcqOgeAPmQ0GPbORqzgYb7WssclwXY4bY8duRzPplOzPhl9yHuS1zBtGMRWHz9UQMYk2YRFLMbjexGybnl9yjaHAqOLYCfomR3v1uwXwE9R0miH4cKzihSdljjS4H)GL5kCywVRQPSIT86xPzqcXfid4HDvnbYsFw6Zsscl9yHuS1zBtGg8UdcTqGz4OMHT8dNuQEwqZsac1GqlL5HtkvpbMVcFO2)CSuOcJ1wkBgk1VcZsFwssyPhl9ybHpNRQjdSYlmL)5kGONfLyrzwssybHpNRQjdSYlmL)5kGONfLyjwS0Nf0S0JLFUci6nVYMHCWo5aeQbHwkwssy5NRaIEZRSjaHAqOLYmuQFfML4z5QNgBO2Fcm3ou7FEOu)kmlDnlkVbl9zjjHfe(CUQMmWkVWu(NRaIEwuILTybnl9y5NRaIEZVLzihStoaHAqOLILKew(5kGO38BzcqOgeAPmdL6xHzjEwU6PXgQ9NaZTd1(Nhk1VcZsxZIYBWsFwssybHpNRQjdSYlmL)5kGONfLyzdw6ZsFw6ZssclbicQ86na1zoVyPpljjSOcXywqZs7qT)5Hs9RWSSnlQRwZe88vbd4A8)GveaqchMZ(pyfbioXeilpKfqs7Dy53jwwyhfXcSXcY7csIHkWILDQyzHVcflGWLQMybwSSWelEbYI9qiO6zzHDuelw2PIfVyXbbzHqq1ZYHzXvHRNLhYc4rraq4tU8ukcqamhGf49hSI(O4Q8grwpcavUQMaJIDeaODeam9ra8WFWkcacFoxvtraq46ffbWkwWWLw9kqZVpNwNXebengQCvnbYssclTd1(Nhk1VcZs8SS1gBWssclQqmMf0S0ou7FEOu)kmlBZYwkKfGXspwS2nyPRzrD1AMFFoToJjciAm43daXcWZYwS0NLKewuxTM53NtRZyIaIgd(9aqSeplXkoyPRzPhlZQOgCqrg8vTLoV3b)0CUHkxvtGSa8SOqw6hbaKWH5S)dwraIr4Z5QAILfMaz5HSasAVdlE1HLFUci6XS4filbqmlw2PIfl(9xHILgCyXlwSML9oCoNf7bgIaGWNC5PueGFFoToJjciAYw87J(O4QSYrwpcavUQMaJIDeaqchMZ(pyfbioXelwtQDNHCnlBYdy5vGyzRnWuaZIk1GdXIZcY7csIHkWYctMiaLNsraOu7od56mCalVcueGWCpnNhbiaHAqOLYe88vbZqP(vyw2MLT2Gf0SeGqni0szcWcbeik)7ugBFZ9yZqP(vyw2MLT2Gf0S0Jfe(CUQMm)(CADgteq0KT43ZssclQRwZ87ZP1zmrarJb)EaiwINLyTblaJLESmRIAWbfzWx1w68Eh8tZ5gQCvnbYcWZYMZsFw6ZcAwq4Z5QAYCvgvaKLKewuHymlOzPDO2)8qP(vyw2MLybCJa4H)Gveak1UZqUodhWYRaf9rXv5TISEeaQCvnbgf7iaGeomN9FWkcqCIjwaaxAn9xHILy0LAhw2CmfWSOsn4qS4SG8UGKyOcSSWKjcq5PueamCP10)xHkpl1oracZ90CEeGESeGqni0szcE(QGzOu)kmlBZYMZcAwSILaebvE9geu97DgwqZIvSeGiOYR3uhQ9p3CILKewcqeu51BQd1(NBoXcAwcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlBZYMZcAw6XccFoxvtMaSqabIYGeUtfyjjHLaeQbHwktWZxfmdL6xHzzBw2Cw6ZssclbicQ86niO637mSGMLESyflZQOgCqrg8vTLoV3b)0CUHkxvtGSGMLaeQbHwktWZxfmdL6xHzzBw2CwssyrD1AMXrqfCHZTHQy2XmuQFfMLTzrzRLfGXspwuilaplKIToBBc0Cf(Nv4HdodEiUIYQKwZsFwqZI6Q1mJJGk4cNBdvXSJzzZsFwssyrfIXSGML2HA)ZdL6xHzzBw2sHSKKWcPyRZ2ManuQDNHCDgoGLxbIf0SeGqni0szOu7od56mCalVcKzOu)kmlXZYwBWsFwqZccFoxvtMRYOcGSGMfRyHuS1zBtGMRWHz9UQMYk2YRFLMbjexGyjjHLaeQbHwkZv4WSExvtzfB51VsZGeIlqMHs9RWSeplBTbljjSOcXywqZs7qT)5Hs9RWSSnlBTreap8hSIaGHlTM()ku5zP2j6JIRYXkY6raOYv1eyuSJaaTJaGPpcGh(dwraq4Z5QAkcacxVOiaQRwZe88vbZqP(vywINfLvilOzPhlwXYSkQbhuKbFvBPZ7DWpnNBOYv1eiljjSOUAnZ4iOcUW52qvm7ygk1VcZY2kXIYBz2IfGXspwIflaplQRwZOQHqq9c)MLnl9zbyS0JL4GLUMffYcWZI6Q1mQAieuVWVzzZsFwaEwifBD22eO5k8pRWdhCg8qCfLvjTMf0SOUAnZ4iOcUW52qvm7yw2S0NLKewuHymlOzPDO2)8qP(vyw2MLTuiljjSqk26STjqdLA3zixNHdy5vGybnlbiudcTugk1UZqUodhWYRazgk1VchbaKWH5S)dwra6I2I3bZYctSediLkgZIL73zb5DbjXqfIaGWNC5PueGtXaZbybE)bROpkUkBTrwpcavUQMaJIDeap8hSIaCfomR3v1uwXwE9R0miH4cueGWCpnNhbaHpNRQjZPyG5aSaV)GflOzbHpNRQjZvzubWiaLNsraUchM17QAkRylV(vAgKqCbk6JIRYkmY6raOYv1eyuSJaas4WC2)bRiaXjMyzou7plQudoelbqCeGYtPia4DheAHaZWrndB5hoPu9racZ90CEeGESeGqni0szcE(QGzihSdlOzXkwcqeu51BQd1(NBoXcAwq4Z5QAY87ZP1zmrart2IFpljjSeGiOYR3uhQ9p3CIf0SeGqni0szcWcbeik)7ugBFZ9yZqoyhwqZspwq4Z5QAYeGfciqugKWDQaljjSeGqni0szcE(QGzihSdl9zPplOzbe(g8QA3qM)caDfkwqZspwaHVb)Kw7tUP9Hm)fa6kuSKKWIvS8UMQ3GFsR9j30(qgQCvnbYssclyBsRZVpOOhBWVpTBiwINLyXsFwqZspwaHVjfcR2nK5VaqxHIL(SGMLESGWNZv1K5WzhsSKKWYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjS44FCD2gAHgwIxjw20nyjjHf1vRzu1qiOEHFZYML(SGMLESeGqni0szuPbtdqxHYmKd2HLKewSILXdK5hOwZsFwqZIvSqk26STjqZv4WSExvtzfB51VsZGeIlqSKKWcPyRZ2ManxHdZ6DvnLvSLx)kndsiUaXcAw6Xsac1GqlL5kCywVRQPSIT86xPzqcXfiZqP(vywINLyTbljjSeGqni0szuPbtdqxHYmuQFfML4zjwBWsFwqZIvSOUAntWZxfmlBwssyrfIXSGML2HA)ZdL6xHzzBwS2nIa4H)Gvea8UdcTqGz4OMHT8dNuQ(OpkUkV5rwpcavUQMaJIDeaqchMZ(pyfbW67hMLdZIZY4)onSqAxfo(tSyX7WYdzj1bIyX1AwGfllmXc(9NLFUci6XS8qwujw0xrGSSSzXY97SG8UGKyOcS4filihwiGarS4fillmXYVtSSvbYcwdFwGflbqwUglQWFNLFUci6XS4dXcSyzHjwWV)S8ZvarpocqyUNMZJa0Jfe(CUQMmWkVWu(NRaIEwSsjwuMf0Syfl)Cfq0B(Tmd5GDYbiudcTuSKKWspwq4Z5QAYaR8ct5FUci6zrjwuMLKewq4Z5QAYaR8ct5FUci6zrjwIfl9zbnl9yrD1AMGNVkyw2SGMLESyflbicQ86niO637mSKKWI6Q1mJJGk4cNBdvXSJzOu)kmlaJLESOqwaEwMvrn4GIm4RAlDEVd(P5CdvUQMazPplBRel)Cfq0BELnQRwldUg)pyXcAwuxTMzCeubx4CBOkMDmlBwssyrD1AMXrqfCHZTHQy2jJVQT059o4NMZnlBw6ZssclbiudcTuMGNVkygk1VcZcWyzlwINLFUci6nVYMaeQbHwkd4A8)GflOzXkwuxTMj45RcMLnlOzPhlwXsaIGkVEtDO2)CZjwssyXkwq4Z5QAYeGfciqugKWDQal9zbnlwXsaIGkVEdqDMZlwssyjarqLxVPou7FU5elOzbHpNRQjtawiGarzqc3PcSGMLaeQbHwktawiGar5FNYy7BUhBw2SGMfRyjaHAqOLYe88vbZYMf0S0JLESOUAndf0NnMY6v5JzOu)kmlXZIYBWssclQRwZqb9zJPmgQ9XmuQFfML4zr5nyPplOzXkwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelkXIczjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGyrjwIdw6ZsFwssyrD1AgGUcCiWmLAdTqtkvFMkAqDXKmlBw6ZssclQqmMf0S0ou7FEOu)kmlBZYwBWsscli85CvnzGvEHP8pxbe9SOelBWsFwqZccFoxvtMRYOcGraWA4JJa8ZvarVYra8WFWkcWpxbe9kh9rXvzGBK1JaqLRQjWOyhbWd)bRia)Cfq0VveGWCpnNhbOhli85CvnzGvEHP8pxbe9SyLsSSflOzXkw(5kGO38kBgYb7KdqOgeAPyjjHfe(CUQMmWkVWu(NRaIEwuILTybnl9yrD1AMGNVkyw2SGMLESyflbicQ86niO637mSKKWI6Q1mJJGk4cNBdvXSJzOu)kmlaJLESOqwaEwMvrn4GIm4RAlDEVd(P5CdvUQMazPplBRel)Cfq0B(TmQRwldUg)pyXcAwuxTMzCeubx4CBOkMDmlBwssyrD1AMXrqfCHZTHQy2jJVQT059o4NMZnlBw6ZssclbiudcTuMGNVkygk1VcZcWyzlwINLFUci6n)wMaeQbHwkd4A8)GflOzXkwuxTMj45RcMLnlOzPhlwXsaIGkVEtDO2)CZjwssyXkwq4Z5QAYeGfciqugKWDQal9zbnlwXsaIGkVEdqDMZlwqZspwSIf1vRzcE(QGzzZssclwXsaIGkVEdcQ(9odl9zjjHLaebvE9M6qT)5MtSGMfe(CUQMmbyHaceLbjCNkWcAwcqOgeAPmbyHaceL)DkJTV5ESzzZcAwSILaeQbHwktWZxfmlBwqZspw6XI6Q1muqF2ykRxLpMHs9RWSeplkVbljjSOUAndf0NnMYyO2hZqP(vywINfL3GL(SGMfRyzwf1GdkYO6AVcug2YUwN)9RqHnu5QAcKLKew6XI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqSOelkKLKewuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIfLyjoyPpl9zPpljjSOUAndqxboeyMsTHwOjLQptfnOUysMLnljjSOcXywqZs7qT)5Hs9RWSSnlBTbljjSGWNZv1Kbw5fMY)Cfq0ZIsSSbl9zbnli85CvnzUkJkagbaRHpocWpxbe9Bf9rXv54iY6raOYv1eyuSJaas4WC2)bRiaXjMWS4AnlWFNgwGfllmXY9ukMfyXsamcGh(dwrawykFpLIJ(O4Q8Mgz9iau5QAcmk2raajCyo7)GveGymfoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdhbWd)bRiaZQYE4pyL1h(JaG)5cFuCvocqyUNMZJaGWNZv1K5Wzhsra0h(ZLNsraCif9rXDRnISEeaQCvnbgf7iaH5EAopcWSkQbhuKr11EfOmSLDTo)7xHcBifBD22eyea8px4JIRYra8WFWkcWSQSh(dwz9H)ia6d)5YtPiaQq)J(O4ULYrwpcavUQMaJIDeap8hSIamRk7H)GvwF4pcG(WFU8ukca(J(OpcGk0)iRhfxLJSEeaQCvnbgf7iaE4pyfbyCeubx4CBOkMDIaas4WC2)bRiaBIHQy2Hfl3VZcY7csIHkebim3tZ5rauxTMj45RcMHs9RWSeplkRWOpkUBfz9iau5QAcmk2ra8WFWkcGd62)HGYyl(Kgbi0jOP87dk6XrXv5iaH5EAopcG6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqSSnlXblOzrD1Agvx7vGYWw2168VFfkC2NGxKb)Eaiw2ML4Gf0S0JfRybe(gh0T)dbLXw8jnd6PokY8xaORqXcAwSIfp8hSmoOB)hckJT4tAg0tDuK5QCtFO2FwqZspwSIfq4BCq3(peugBXN08o5AZFbGUcfljjSacFJd62)HGYyl(KM3jxBgk1VcZs8Selw6ZssclGW34GU9FiOm2IpPzqp1rrg87bGyzBwIflOzbe(gh0T)dbLXw8jnd6PokYmuQFfMLTzrHSGMfq4BCq3(peugBXN0mON6OiZFbGUcfl9Jaas4WC2)bRiaXjMyPlGU9FiiwayXNuwSStfl(ZIMWyw(DVyXAzj2WUyDwWVhacZIxGS8qwgQneENfNLTvAlwWVhaIfhZI2FIfhZIneJpvnXcCy5VuIL7zbdz5Ew8zoeeMfKsw4NfV90WIZsSagl43daXcHm7BiC0hf3yfz9iau5QAcmk2ra8WFWkcqawiGar5FNYy7BUhhbaKWH5S)dwraItmXcYHfciqelwUFNfK3fKedvGfl7uXIneJpvnXIxGSa)DASCyIfl3VZIZsSHDX6SOUAnwSStflGeUtfUcveGWCpnNhbWkwaN1bAkyoaIzbnl9yPhli85CvnzcWcbeikds4ovGf0SyflbiudcTuMGNVkygYb7WssclQRwZe88vbZYML(SGMLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelkXsCWssclQRwZO6AVcug2YUwN)9RqHZ(e8Im43daXIsSehS0NLKewuHymlOzPDO2)8qP(vyw2MfL3GL(rFuCT2iRhbGkxvtGrXocGh(dwraARPtg2YKEvueaqchMZ(pyfbytaTgwCml)oXs7g8ZcQailxXYVtS4SeByxSolwUceAHf4WIL73z53jwqk3zoVyrD1ASahwSC)ololXbWWuGLUa62)HGybGfFszXlqwS43ZsdoSG8UGKyOcSCnwUNflW6zrLyzzZIJYVIfvQbhILFNyjaYYHzPD1H3jWiaH5EAopcqpw6XspwuxTMr11EfOmSLDTo)7xHcNl)xdzWVhaIL4zzZzjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGyjEw2Cw6ZcAw6XIvSeGiOYR3GGQFVZWssclwXI6Q1mJJGk4cNBdvXSJzzZsFw6ZcAw6Xc4SoqtbZbqmljjSeGqni0szcE(QGzOu)kmlXZIc3GLKew6XsaIGkVEtDO2)CZjwqZsac1GqlLjaleqGO8VtzS9n3JndL6xHzjEwu4gS0NL(S0NLKew6Xci8noOB)hckJT4tAg0tDuKzOu)kmlXZsCWcAwcqOgeAPmbpFvWmuQFfML4zr5nybnlbicQ86nffgOgoGS0NLKewU6PXgQ9NaZTd1(Nhk1VcZY2SehSGMfRyjaHAqOLYe88vbZqoyhwssyjarqLxVbOoZ5flOzrD1AgGUcCiWmLAdTqtkvVzzZssclbicQ86niO637mSGMf1vRzghbvWfo3gQIzhZqP(vyw2MLnLf0SOUAnZ4iOcUW52qvm7yw2rFuCvyK1JaqLRQjWOyhbWd)bRiabVcKoRUATiaH5EAopcqpwuxTMr11EfOmSLDTo)7xHcNl)xdzgk1VcZs8SaCnkKLKewuxTMr11EfOmSLDTo)7xHcN9j4fzgk1VcZs8SaCnkKL(SGMLESeGqni0szcE(QGzOu)kmlXZcWLLKew6Xsac1GqlLHsTHwOjRclqZqP(vywINfGllOzXkwuxTMbORahcmtP2ql0Ks1NPIguxmjZYMf0SeGiOYR3auN58IL(S0Nf0S44FCD2gAHgwIxjwI1grauxTwU8ukca(9rdhWiaGeomN9FWkcaY9kqAwa8(OHdilwUFNfNLISWsSHDX6SOUAnw8cKfK3fKedvGLdxk6zXvHRNLhYIkXYctGrFuC38iRhbGkxvtGrXocGh(dwraWVp41GIIaas4WC2)bRiaX4vQnlaEFWRbfHzXY97S4SeByxSolQRwJf11ZsbFwSStfl2qO(kuS0GdliVlijgQalWHfKYxboeilaSV5ECeGWCpnNhbOhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SSfljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZYwS0Nf0S0JLaebvE9M6qT)5MtSKKWsac1GqlLj45RcMHs9RWSeplaxwssyXkwq4Z5QAYeaZbybE)blwqZIvSeGiOYR3auN58ILKew6Xsac1GqlLHsTHwOjRclqZqP(vywINfGllOzXkwuxTMbORahcmtP2ql0Ks1NPIguxmjZYMf0SeGiOYR3auN58IL(S0Nf0S0JfRybe(M2A6KHTmPxfz(la0vOyjjHfRyjaHAqOLYe88vbZqoyhwssyXkwcqOgeAPmbyHaceL)DkJTV5ESzihSdl9J(O4cCJSEeaQCvnbgf7iaE4pyfba)(GxdkkcaiHdZz)hSIaeJxP2Sa49bVgueMfvQbhIfKdleqGOiaH5EAopcqpwcqOgeAPmbyHaceL)DkJTV5ESzOu)kmlBZIczbnlwXc4SoqtbZbqmlOzPhli85CvnzcWcbeikds4ovGLKewcqOgeAPmbpFvWmuQFfMLTzrHS0Nf0SGWNZv1KjaMdWc8(dwS0Nf0SyflGW30wtNmSLj9QiZFbGUcflOzjarqLxVPou7FU5elOzXkwaN1bAkyoaIzbnluqF2yYCv2RoSGMfh)JRZ2ql0Ws8SyTBe9rXnoISEeaQCvnbgf7iaq7iay6Ja4H)Gveae(CUQMIaGW1lkcqpwuxTMzCeubx4CBOkMDmdL6xHzjEwuiljjSyflQRwZmocQGlCUnufZoMLnl9zbnl9yrD1AgGUcCiWmLAdTqtkvFMkAqDXKmdL6xHzzBwqfanPoYyPplOzPhlQRwZqb9zJPmgQ9XmuQFfML4zbva0K6iJLKewuxTMHc6Zgtz9Q8XmuQFfML4zbva0K6iJL(raajCyo7)GveGymSu0Zci8zbCnxHILFNyHkqwGnwIrDeubxyw2edvXSJcybCnxHIfGUcCiqwOuBOfAsP6zboSCfl)oXI2XplOcGSaBS4flwtqF2ykcacFYLNsraaHFEifBDdLs1JJ(O4UPrwpcavUQMaJIDeap8hSIaGxv7gkcqyUNMZJamuBi8URQjwqZY7dk6n)Ls5hMbpIL4zr5nNf0S425WofaIf0SGWNZv1Kbe(5HuS1nukvpocqOtqt53hu0JJIRYrFuCvEJiRhbGkxvtGrXocGh(dwrasHWQDdfbim3tZ5ragQneE3v1elOz59bf9M)sP8dZGhXs8SOCSmkKf0S425WofaIf0SGWNZv1Kbe(5HuS1nukvpocqOtqt53hu0JJIRYrFuCvw5iRhbGkxvtGrXocGh(dwraWpP1(KBAFOiaH5EAopcWqTHW7UQMybnlVpOO38xkLFyg8iwINfL3CwagldL6xHzbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hfxL3kY6raOYv1eyuSJa4H)GveGgCcug2YL)RHIaas4WC2)bRiaBcyCzbwSeazXY97W1ZsWTTVcveGWCpnNhbWTZHDkau0hfxLJvK1JaqLRQjWOyhbWd)bRiauQn0cnzvybgbaKWH5S)dwraSMuBOfAyj2WcKfl7uXIRcxplpKfQEAyXzPilSeByxSolwUceAHfVazb7iiwAWHfK3fKedvicqyUNMZJa0JfkOpBmz0RYNCri7zjjHfkOpBmzWqTp5Iq2ZsscluqF2yY4vNCri7zjjHf1vRzuDTxbkdBzxRZ)(vOW5Y)1qMHs9RWSeplaxJczjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErMHs9RWSeplaxJczjjHfh)JRZ2ql0Ws8SSPBWcAwcqOgeAPmbpFvWmKd2Hf0SyflGZ6anfmhaXS0Nf0S0JLaeQbHwktWZxfmdL6xHzjEwI1gSKKWsac1GqlLj45RcMHCWoS0NLKewuHymlOz5QNgBO2Fcm3ou7FEOu)kmlBZIYBe9rXvzRnY6raOYv1eyuSJa4H)GveG2A6KHTmPxffbaKWH5S)dwra2eqRHL5qT)SOsn4qSSWxHIfK3LiaH5EAopcqac1GqlLj45RcMHCWoSGMfe(CUQMmbWCawG3FWIf0S0Jfh)JRZ2ql0Ws8SSPBWcAwSILaebvE9M6qT)5MtSKKWsaIGkVEtDO2)CZjwqZIJ)X1zBOfAyzBwS2nyPplOzXkwcqeu51Bqq1V3zybnl9yXkwcqeu51BQd1(NBoXssclbiudcTuMaSqabIY)oLX23Cp2mKd2HL(SGMfRybCwhOPG5aio6JIRYkmY6raOYv1eyuSJaaTJaGPpcGh(dwraq4Z5QAkcacxVOiawXc4SoqtbZbqmlOzbHpNRQjtamhGf49hSybnl9yPhlo(hxNTHwOHL4zzt3Gf0S0Jf1vRza6kWHaZuQn0cnPu9zQOb1ftYSSzjjHfRyjarqLxVbOoZ5fl9zjjHf1vRzu1qiOEHFZYMf0SOUAnJQgcb1l8Bgk1VcZY2SOUAntWZxfmGRX)dwS0NLKewuHymlOz5QNgBO2Fcm3ou7FEOu)kmlBZI6Q1mbpFvWaUg)pyXssclbicQ86n1HA)ZnNyPplOzPhlwXsaIGkVEtDO2)CZjwssyPhlo(hxNTHwOHLTzXA3GLKewaHVPTMozylt6vrM)caDfkw6ZcAw6XccFoxvtMaSqabIYGeUtfyjjHLaeQbHwktawiGar5FNYy7BUhBgYb7WsFw6hbaKWH5S)dwraqExqsmubwSStfl(ZYMUbWyPl4nJLEWrdTqdl)UxSyTBWsxWBglwUFNfKdleqGO(Sy5(D46zrdXxHIL)sjwUILyRHqq9c)S4fil6Riww2Sy5(DwqoSqabIy5ASCplwCmlGeUtfiWiai8jxEkfbiaMdWc8(dwzvO)rFuCvEZJSEeaQCvnbgf7iaH5EAopcacFoxvtMayoalW7pyLvH(hbWd)bRiabst4)CD21hQkLQp6JIRYa3iRhbGkxvtGrXocqyUNMZJaGWNZv1KjaMdWc8(dwzvO)ra8WFWkcWvbFk)pyf9rXv54iY6raOYv1eyuSJaaTJaGPpcGh(dwraq4Z5QAkcacxVOiauqF2yYCvwVkFyb4zjoybjS4H)GLb)(0UHmeYOW6P8FPelaJfRyHc6ZgtMRY6v5dlapl9yzZzbyS8UMQ3GHlDg2Y)oLBWHWVHkxvtGSa8Selw6ZcsyXd)blJLX)DdHmkSEk)xkXcWyzdZwSGewW2KwN3D8traajCyo7)GveaRb)xQ)eMLDOfwsxHDw6cEZyXhIfu(veil20WcMcWcmcacFYLNsraCS9Mrdake9rXv5nnY6raOYv1eyuSJa4H)Gvea87dEnOOiaGeomN9FWkcqmELAZcG3h8AqrywSStfl)oXs7qT)SCywCv46z5HSqfOcyPnufZoSCywCv46z5HSqfOcyPdCXIpel(ZYMUbWyPl4nJLRyXlwSMG(SXKcyb5DbjXqfyr74hZIxWFNgwIdGHPaMf4Wsh4IflWLgKficAcUnlPWHy539Ifor5nyPl4nJfl7uXsh4IflWLgSu0ZcG3h8AqrSuqlracZ90CEeGESOcXywqZYvpn2qT)eyUDO2)8qP(vyw2MfRLLKew6XI6Q1mJJGk4cNBdvXSJzOu)kmlBZcQaOj1rglaplb60S0Jfh)JRZ2ql0WcsyjwBWsFwqZI6Q1mJJGk4cNBdvXSJzzZsFw6Zsscl9yXX)46Sn0cnSamwq4Z5QAY4y7nJgauGfGNf1vRzOG(SXugd1(ygk1VcZcWybe(M2A6KHTmPxfz(laeopuQFflaplBzuilXZIYkVbljjS44FCD2gAHgwagli85CvnzCS9MrdakWcWZI6Q1muqF2ykRxLpMHs9RWSamwaHVPTMozylt6vrM)caHZdL6xXcWZYwgfYs8SOSYBWsFwqZcf0NnMmxL9QdlOzPhlwXI6Q1mbpFvWSSzjjHfRy5DnvVb)(OHdOHkxvtGS0Nf0S0JLESyflbiudcTuMGNVkyw2SKKWsaIGkVEdqDMZlwqZIvSeGqni0szOuBOfAYQWc0SSzPpljjSeGiOYR3uhQ9p3CIL(SGMLESyflbicQ86niO637mSKKWIvSOUAntWZxfmlBwssyXX)46Sn0cnSeplB6gS0NLKew6XY7AQEd(9rdhqdvUQMazbnlQRwZe88vbZYMf0S0Jf1vRzWVpA4aAWVhaILTzjwSKKWIJ)X1zBOfAyjEw20nyPpl9zjjHf1vRzcE(QGzzZcAwSIf1vRzghbvWfo3gQIzhZYMf0SyflVRP6n43hnCanu5QAcm6JI7wBez9iau5QAcmk2ra8WFWkcqrwYPqyfbaKWH5S)dwraItmXYMeewywUIffFv(WI1e0NnMyXlqwWocILyKDDdyBILwZYMeewS0GdliVlijgQqeGWCpnNhbOhlQRwZqb9zJPSEv(ygk1VcZs8SqiJcRNY)LsSKKWspwc7(GIWSOelBXcAwgkS7dkk)xkXY2SOqw6ZssclHDFqrywuILyXsFwqZIBNd7uaOOpkUBPCK1JaqLRQjWOyhbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPelOzPhlbiudcTuMGNVkygk1VcZs8SOWnyjjHLaeQbHwktawiGar5FNYy7BUhBgk1VcZs8SOWnyPpljjS0JLWUpOimlkXYwSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyjwS0Nf0S425WofakcGh(dwra2DDlNcHv0hf3T2kY6raOYv1eyuSJaeM7P58ia9yrD1AgkOpBmL1RYhZqP(vywINfczuy9u(VuIf0S0JLaeQbHwktWZxfmdL6xHzjEwu4gSKKWsac1GqlLjaleqGO8VtzS9n3JndL6xHzjEwu4gS0NLKew6Xsy3hueMfLyzlwqZYqHDFqr5)sjw2MffYsFwssyjS7dkcZIsSelw6ZcAwC7CyNcafbWd)bRiaTLwNtHWk6JI7wXkY6raOYv1eyuSJaas4WC2)bRiaifqRHfyXsamcGh(dwraS4ZCWjdBzsVkk6JI7wwBK1JaqLRQjWOyhbWd)bRia43N2nueaqchMZ(pyfbioXelaEFA3qS8qwShyGfaqTpSynb9zJjwGdlw2PILRybw6oSO4RYhwSMG(SXelEbYYctSGuaTgwShyaZY1y5kwu8v5dlwtqF2ykcqyUNMZJaqb9zJjZvz9Q8HLKewOG(SXKbd1(KlczpljjSqb9zJjJxDYfHSNLKewuxTMXIpZbNmSLj9QiZYMf0SOUAndf0NnMY6v5JzzZsscl9yrD1AMGNVkygk1VcZY2S4H)GLXY4)UHqgfwpL)lLybnlQRwZe88vbZYML(rFuC3sHrwpcGh(dwraSm(VhbGkxvtGrXo6JI7wBEK1JaqLRQjWOyhbWd)bRiaZQYE4pyL1h(JaOp8NlpLIa0CT(3Nv0h9raCifz9O4QCK1JaqLRQjWOyhbaAhbatFeap8hSIaGWNZv1ueaeUErra6XI6Q1m)LswGtLbhYtvVcKgZqP(vyw2MfubqtQJmwaglByuMLKewuxTM5VuYcCQm4qEQ6vG0ygk1VcZY2S4H)GLb)(0UHmeYOW6P8FPelaJLnmkZcAw6Xcf0NnMmxL1RYhwssyHc6Zgtgmu7tUiK9SKKWcf0NnMmE1jxeYEw6ZsFwqZI6Q1m)LswGtLbhYtvVcKgZYMf0SmRIAWbfz(lLSaNkdoKNQEfingQCvnbgbaKWH5S)dwraqURdlT)eMfl70Vtdl)oXsmEipn4FyNgwuxTglwoTMLMR1SaBnwSC)(vS87elfHSNLGJ)iai8jxEkfbaCipnB506CZ16mS1I(O4UvK1JaqLRQjWOyhbaAhbatFeap8hSIaGWNZv1ueaeUErraSIfkOpBmzUkJHAFybnl9ybBtAD(9bf9yd(9PDdXs8SOqwqZY7AQEdgU0zyl)7uUbhc)gQCvnbYssclyBsRZVpOOhBWVpTBiwINfGll9Jaas4WC2)bRiai31HL2FcZILD63PHfaVp41GIy5WSybo)olbh)xHIficAybW7t7gILRyrXxLpSynb9zJPiai8jxEkfb4qvWHY43h8AqrrFuCJvK1JaqLRQjWOyhbWd)bRiabyHaceL)DkJTV5ECeaqchMZ(pyfbioXelihwiGarSyzNkw8NfnHXS87EXIc3GLUG3mw8cKf9vellBwSC)oliVlijgQqeGWCpnNhbWkwaN1bAkyoaIzbnl9yPhli85CvnzcWcbeikds4ovGf0SyflbiudcTuMGNVkygYb7WssclQRwZe88vbZYML(SGMLESOUAndf0NnMY6v5JzOu)kmlXZYMZssclQRwZqb9zJPmgQ9XmuQFfML4zzZzPplOzPhlwXYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjSOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelXZsSyjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGyjEwIfl9zjjHfvigZcAwAhQ9ppuQFfMLTzr5nybnlwXsac1GqlLj45RcMHCWoS0p6JIR1gz9iau5QAcmk2ra8WFWkcW4iOcUW52qvm7ebaKWH5S)dwraItmXYMyOkMDyXY97SG8UGKyOcracZ90CEea1vRzcE(QGzOu)kmlXZIYkm6JIRcJSEeaQCvnbgf7iaE4pyfbaVQ2nueGqNGMYVpOOhhfxLJaeM7P58ia9yzO2q4DxvtSKKWI6Q1muqF2ykJHAFmdL6xHzzBwIflOzHc6ZgtMRYyO2hwqZYqP(vyw2MfLTwwqZY7AQEdgU0zyl)7uUbhc)gQCvnbYsFwqZY7dk6n)Ls5hMbpIL4zrzRLLUMfSnP153hu0JzbySmuQFfMf0S0JfkOpBmzUk7vhwssyzOu)kmlBZcQaOj1rgl9Jaas4WC2)bRiaXjMybWQA3qSCfl2EbsPxGfyXIxD(9RqXYV7pl6dbHzrzRftbmlEbYIMWywSC)olPWHy59bf9yw8cKf)z53jwOcKfyJfNfaqTpSynb9zJjw8NfLTwwWuaZcCyrtymldL6xDfkwCmlpKLc(SS7iUcflpKLHAdH3zbCnxHIffFv(WI1e0NnMI(O4U5rwpcavUQMaJIDeap8hSIaGxv7gkcaiHdZz)hSIaeNyIfaRQDdXYdzz3rqS4SGsdvDnlpKLfMyjgqkvmocqyUNMZJaGWNZv1K5umWCawG3FWIf0SeGqni0szUchM17QAkRylV(vAgKqCbYmKd2Hf0Sqk26STjqZv4WSExvtzfB51VsZGeIlqrFuCbUrwpcavUQMaJIDeGWCpnNhbWkwExt1BWpP1(KbNR9gQCvnbYcAw6XI6Q1m43NMR1MHAdH3DvnXcAw6Xc2M0687dk6Xg87tZ1Aw2MLyXssclwXYSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eil9zjjHL31u9gmCPZWw(3PCdoe(nu5QAcKf0SOUAndf0NnMYyO2hZqP(vyw2MLyXcAwOG(SXK5QmgQ9Hf0SOUAnd(9P5ATzOu)kmlBZcWLf0SGTjTo)(GIESb)(0CTML4vIfRLL(SGMLESyflZQOgCqrgDNGpoo30e9xHkJsFP2yYqLRQjqwssy5VuIfKklwRczjEwuxTMb)(0CT2muQFfMfGXYwS0Nf0S8(GIEZFPu(HzWJyjEwuyeap8hSIaGFFAUwh9rXnoISEeaQCvnbgf7iaE4pyfba)(0CTocaiHdZz)hSIaGuC)olaEsR9HLy8CTNLfMybwSeazXYovSmuBi8URQjwuxpl4)0AwS43ZsdoSO4Dc(4ywShyGfVazbewk6zzHjwuPgCiwqEmgBybWFAnllmXIk1GdXcYHfciqel4Rcel)U)Sy50AwShyGfVG)onSa49P5ADeGWCpnNhb4DnvVb)Kw7tgCU2BOYv1eilOzrD1Ag87tZ1AZqTHW7UQMybnl9yXkwMvrn4GIm6obFCCUPj6VcvgL(sTXKHkxvtGSKKWYFPelivwSwfYs8SyTS0Nf0S8(GIEZFPu(HzWJyjEwIv0hf3nnY6raOYv1eyuSJa4H)Gvea87tZ16iaGeomN9FWkcasX97SeJhYtvVcKgwwyIfaVpnxRz5HSaer2SSSz53jwuxTglQDyX1yill8vOybW7tZ1AwGflkKfmfGfiMf4WIMWywgk1V6kuracZ90CEeGzvudoOiZFPKf4uzWH8u1RaPXqLRQjqwqZc2M0687dk6Xg87tZ1AwIxjwIflOzPhlwXI6Q1m)LswGtLbhYtvVcKgZYMf0SOUAnd(9P5ATzO2q4DxvtSKKWspwq4Z5QAYaoKNMTCADU5ADg2ASGMLESOUAnd(9P5ATzOu)kmlBZsSyjjHfSnP153hu0Jn43NMR1SeplBXcAwExt1BWpP1(KbNR9gQCvnbYcAwuxTMb)(0CT2muQFfMLTzrHS0NL(S0p6JIRYBez9iau5QAcmk2raG2raW0hbWd)bRiai85CvnfbaHRxueah)JRZ2ql0Ws8SehBWsxZspwuEdwaEwuxTM5VuYcCQm4qEQ6vG0yWVhaIL(S01S0Jf1vRzWVpnxRndL6xHzb4zjwSGewW2KwN3D8tSa8SyflVRP6n4N0AFYGZ1EdvUQMazPplDnl9yjaHAqOLYGFFAUwBgk1VcZcWZsSybjSGTjToV74Nyb4z5DnvVb)Kw7tgCU2BOYv1eil9zPRzPhlGW30wtNmSLj9QiZqP(vywaEwuil9zbnl9yrD1Ag87tZ1AZYMLKewcqOgeAPm43NMR1MHs9RWS0pcaiHdZz)hSIaGCxhwA)jmlw2PFNgwCwa8(GxdkILfMyXYP1Se8fMybW7tZ1AwEilnxRzb2AkGfVazzHjwa8(GxdkILhYcqezZsmEipv9kqAyb)Eaiww2raq4tU8ukca(9P5AD2cS(CZ16mS1I(O4QSYrwpcavUQMaJIDeap8hSIaGFFWRbffbaKWH5S)dwraItmXcG3h8AqrSy5(DwIXd5PQxbsdlpKfGiYMLLnl)oXI6Q1yXY97W1ZIgIVcflaEFAUwZYY(VuIfVazzHjwa8(GxdkIfyXI1cmwInSlwNf87bGWSSQ)0SyTS8(GIECeGWCpnNhbaHpNRQjd4qEA2YP15MR1zyRXcAwq4Z5QAYGFFAUwNTaRp3CTodBnwqZIvSGWNZv1K5qvWHY43h8AqrSKKWspwuxTMr11EfOmSLDTo)7xHcNl)xdzWVhaIL4zjwSKKWI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqSeplXIL(SGMfSnP153hu0Jn43NMR1SSnlwllOzbHpNRQjd(9P5AD2cS(CZ16mS1I(O4Q8wrwpcavUQMaJIDeap8hSIa4GU9FiOm2IpPracDcAk)(GIECuCvocqyUNMZJayfl)fa6kuSGMfRyXd)blJd62)HGYyl(KMb9uhfzUk30hQ9NLKewaHVXbD7)qqzSfFsZGEQJIm43daXY2SelwqZci8noOB)hckJT4tAg0tDuKzOu)kmlBZsSIaas4WC2)bRiaXjMybBXNuwWqw(D)zPdCXck6zj1rgll7)sjwu7WYcFfkwUNfhZI2FIfhZIneJpvnXcSyrtyml)UxSelwWVhacZcCybPKf(zXYovSelGXc(9aqywiKzFdf9rXv5yfz9iau5QAcmk2ra8WFWkcqkewTBOiaHobnLFFqrpokUkhbim3tZ5ragQneE3v1elOz59bf9M)sP8dZGhXs8S0JLESOS1YcWyPhlyBsRZVpOOhBWVpTBiwaEw2IfGNf1vRzOG(SXuwVkFmlBw6ZsFwagldL6xHzPpliHLESOmlaJL31u9M3Yv5uiSWgQCvnbYsFwqZspwcqOgeAPmbpFvWmKd2Hf0SyflGZ6anfmhaXSGMLESGWNZv1KjaleqGOmiH7ubwssyjaHAqOLYeGfciqu(3Pm2(M7XMHCWoSKKWIvSeGiOYR3uhQ9p3CIL(SKKWc2M0687dk6Xg87t7gILTzPhl9yzZzPRzPhlQRwZqb9zJPSEv(yw2Sa8SSfl9zPplapl9yrzwaglVRP6nVLRYPqyHnu5QAcKL(S0Nf0SyfluqF2yYGHAFYfHSNLKew6Xcf0NnMmxLXqTpSKKWspwOG(SXK5QSk83zjjHfkOpBmzUkRxLpS0Nf0SyflVRP6ny4sNHT8Vt5gCi8BOYv1eiljjSOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyjELyzlfUbl9zbnl9ybBtAD(9bf9yd(9PDdXY2SO8gSa8S0JfLzbyS8UMQ38wUkNcHf2qLRQjqw6ZsFwqZIJ)X1zBOfAyjEwu4gS01SOUAnd(9P5ATzOu)kmlaplBol9zbnl9yXkwuxTMbORahcmtP2ql0Ks1NPIguxmjZYMLKewOG(SXK5QmgQ9HLKewSILaebvE9gG6mNxS0Nf0SyflQRwZmocQGlCUnufZoz8vTLoV3b)0CUzzhbaKWH5S)dwraIrP2q4Dw2KGWQDdXY1yb5DbjXqfy5WSmKd2rbS870qS4dXIMWyw(DVyrHS8(GIEmlxXIIVkFyXAc6ZgtSy5(Dwaa)nHcyrtyml)UxSO8gSa)DASCyILRyXRoSynb9zJjwGdllBwEilkKL3hu0JzrLAWHyXzrXxLpSynb9zJjdlXyyPONLHAdH3zbCnxHIfKYxboeilwtQn0cnPu9SSknHXSCflaGAFyXAc6ZgtrFuCv2AJSEeaQCvnbgf7iaE4pyfbObNaLHTC5)AOiaGeomN9FWkcqCIjw2eW4YcSyjaYIL73HRNLGBBFfQiaH5EAopcGBNd7uaOOpkUkRWiRhbGkxvtGrXoca0ocaM(iaE4pyfbaHpNRQPiaiC9IIayflGZ6anfmhaXSGMfe(CUQMmbWCawG3FWIf0S0JLESOUAnd(9P5ATzzZssclVRP6n4N0AFYGZ1EdvUQMazjjHLaebvE9M6qT)5MtS0Nf0S0JfRyrD1AgmuJ)lqMLnlOzXkwuxTMj45RcMLnlOzPhlwXY7AQEtBnDYWwM0RImu5QAcKLKewuxTMj45RcgW14)blwINLaeQbHwktBnDYWwM0RImdL6xHzbySehS0Nf0SGWNZv1K53NtRZyIaIMSf)EwqZspwSILaebvE9M6qT)5MtSKKWsac1GqlLjaleqGO8VtzS9n3JnlBwqZspwuxTMb)(0CT2muQFfMLTzzlwssyXkwExt1BWpP1(KbNR9gQCvnbYsFw6ZcAwEFqrV5Vuk)Wm4rSeplQRwZe88vbd4A8)GflaplByaUS0NLKewuHymlOzPDO2)8qP(vyw2Mf1vRzcE(QGbCn(FWIL(raq4tU8ukcqamhGf49hSYoKI(O4Q8Mhz9iau5QAcmk2ra8WFWkcqG0e(pxND9HQsP6Jaas4WC2)bRiaXjMyb5DbjXqfybwSeazzvAcJzXlqw0xrSCpllBwSC)olihwiGarracZ90CEeae(CUQMmbWCawG3FWk7qk6JIRYa3iRhbGkxvtGrXocqyUNMZJaGWNZv1KjaMdWc8(dwzhsra8WFWkcWvbFk)pyf9rXv54iY6raOYv1eyuSJa4H)Gveak1gAHMSkSaJaas4WC2)bRiaXjMyXAsTHwOHLydlqwGflbqwSC)olaEFAUwZYYMfVazb7iiwAWHLnBPX(WIxGSG8UGKyOcracZ90CEeavigZcAwU6PXgQ9NaZTd1(Nhk1VcZY2SOSczjjHLESOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyzBw2sHBWssclQRwZypxkCapxN9j41fY2ln2hdcxViwIxjw2sHBWsFwqZI6Q1m43NMR1MLnlOzPhlbiudcTuMGNVkygk1VcZs8SOWnyjjHfWzDGMcMdGyw6h9rXv5nnY6raOYv1eyuSJa4H)Gvea8tATp5M2hkcqOtqt53hu0JJIRYracZ90CEeGHAdH3DvnXcAw(lLYpmdEelXZIYkKf0SGTjTo)(GIESb)(0UHyzBwSwwqZIBNd7uaiwqZspwuxTMj45RcMHs9RWSeplkVbljjSyflQRwZe88vbZYML(raajCyo7)GveGyuQneENLM2hIfyXYYMLhYsSy59bf9ywSC)oC9SG8UGKyOcSOsxHIfxfUEwEileYSVHyXlqwk4Zcebnb32(kurFuC3AJiRhbGkxvtGrXocGh(dwraARPtg2YKEvueaqchMZ(pyfbioXelBcO1WY1y5k8bsS4flwtqF2yIfVazrFfXY9SSSzXY97S4SSzln2hwShyGfVazPlGU9FiiwayXN0iaH5EAopcaf0NnMmxL9QdlOzXTZHDkaelOzrD1Ag75sHd456SpbVUq2EPX(yq46fXY2SSLc3Gf0S0Jfq4BCq3(peugBXN0mON6OiZFbGUcfljjSyflbicQ86nffgOgoGSKKWc2M0687dk6XSeplBXsFwqZspwuxTMzCeubx4CBOkMDmdL6xHzzBw2uw6Aw6XIczb4zzwf1GdkYGVQT059o4NMZnu5QAcKL(SGMf1vRzghbvWfo3gQIzhZYMLKewSIf1vRzghbvWfo3gQIzhZYML(SGMLESyflbiudcTuMGNVkyw2SKKWI6Q1m)(CADgteq0yWVhaILTzrzfYcAwAhQ9ppuQFfMLTzzRn2Gf0S0ou7FEOu)kmlXZIYBSbljjSyfly4sREfO53NtRZyIaIgdvUQMazPplOzPhly4sREfO53NtRZyIaIgdvUQMazjjHLaeQbHwktWZxfmdL6xHzjEwI1gS0p6JI7wkhz9iau5QAcmk2ra8WFWkca(9P5ADeaqchMZ(pyfbioXelolaEFAUwZYMCr)ol2dmWYQ0egZcG3NMR1SCywC9qoyhww2Sahw6axS4dXIRcxplpKficAcUnlDbVzracZ90CEea1vRzGf974SnnbY(pyzw2SGMLESOUAnd(9P5ATzO2q4DxvtSKKWIJ)X1zBOfAyjEw20nyPF0hf3T2kY6raOYv1eyuSJa4H)Gvea87tZ16iaGeomN9FWkcqmELAZsxWBglQudoelihwiGarSy5(Dwa8(0CTMfVaz53PIfaVp41GIIaeM7P58iabicQ86n1HA)ZnNybnlwXY7AQEd(jT2Nm4CT3qLRQjqwqZspwq4Z5QAYeGfciqugKWDQaljjSeGqni0szcE(QGzzZssclQRwZe88vbZYML(SGMLaeQbHwktawiGar5FNYy7BUhBgk1VcZY2SGkaAsDKXcWZsGonl9yXX)46Sn0cnSGewu4gS0Nf0SOUAnd(9P5ATzOu)kmlBZI1YcAwSIfWzDGMcMdG4OpkUBfRiRhbGkxvtGrXocqyUNMZJaeGiOYR3uhQ9p3CIf0S0Jfe(CUQMmbyHaceLbjCNkWssclbiudcTuMGNVkyw2SKKWI6Q1mbpFvWSSzPplOzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSSnlBolOzrD1Ag87tZ1AZYMf0Sqb9zJjZvzV6WcAwSIfe(CUQMmhQcoug)(GxdkIf0SyflGZ6anfmhaXra8WFWkca(9bVguu0hf3TS2iRhbGkxvtGrXocGh(dwraWVp41GIIaas4WC2)bRiaXjMybW7dEnOiwSC)olEXYMCr)ol2dmWcCy5AS0bUueilqe0eCBw6cEZyXY97S0bUgwkczplbh)gw6IgdzbCLAZsxWBgl(ZYVtSqfilWgl)oXsmcQ(9odlQRwJLRXcG3NMR1SybU0GLIEwAUwZcS1yboS0bUyXhIfyXYwS8(GIECeGWCpnNhbqD1Agyr)ooh0Kpzeh(GLzzZsscl9yXkwWVpTBiJBNd7uaiwqZIvSGWNZv1K5qvWHY43h8AqrSKKWspwuxTMj45RcMHs9RWSSnlkKf0SOUAntWZxfmlBwssyPhl9yrD1AMGNVkygk1VcZY2SGkaAsDKXcWZsGonl9yXX)46Sn0cnSGewI1gS0Nf0SOUAntWZxfmlBwssyrD1AMXrqfCHZTHQy2jJVQT059o4NMZndL6xHzzBwqfanPoYyb4zjqNMLES44FCD2gAHgwqclXAdw6ZcAwuxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYML(SGMLaebvE9geu97Dgw6ZsFwqZspwW2KwNFFqrp2GFFAUwZY2SelwssybHpNRQjd(9P5AD2cS(CZ16mS1yPpl9zbnlwXccFoxvtMdvbhkJFFWRbfXcAw6XIvSmRIAWbfz(lLSaNkdoKNQEfingQCvnbYssclyBsRZVpOOhBWVpnxRzzBwIfl9J(O4ULcJSEeaQCvnbgf7iaE4pyfbOil5uiSIaas4WC2)bRiaXjMyztcclmlxXcaO2hwSMG(SXelEbYc2rqSSjwAnlBsqyXsdoSG8UGKyOcracZ90CEeGESOUAndf0NnMYyO2hZqP(vywINfczuy9u(VuILKew6Xsy3hueMfLyzlwqZYqHDFqr5)sjw2MffYsFwssyjS7dkcZIsSelw6ZcAwC7CyNcaf9rXDRnpY6raOYv1eyuSJaeM7P58ia9yrD1AgkOpBmLXqTpMHs9RWSepleYOW6P8FPeljjS0JLWUpOimlkXYwSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyjwS0Nf0S425WofaIf0S0Jf1vRzghbvWfo3gQIzhZqP(vyw2MffYcAwuxTMzCeubx4CBOkMDmlBwqZIvSmRIAWbfzWx1w68Eh8tZ5gQCvnbYssclwXI6Q1mJJGk4cNBdvXSJzzZs)iaE4pyfby31TCkewrFuC3c4gz9iau5QAcmk2racZ90CEeGESOUAndf0NnMYyO2hZqP(vywINfczuy9u(VuIf0S0JLaeQbHwktWZxfmdL6xHzjEwu4gSKKWsac1GqlLjaleqGO8VtzS9n3JndL6xHzjEwu4gS0NLKew6Xsy3hueMfLyzlwqZYqHDFqr5)sjw2MffYsFwssyjS7dkcZIsSelw6ZcAwC7CyNcaXcAw6XI6Q1mJJGk4cNBdvXSJzOu)kmlBZIczbnlQRwZmocQGlCUnufZoMLnlOzXkwMvrn4GIm4RAlDEVd(P5CdvUQMazjjHfRyrD1AMXrqfCHZTHQy2XSSzPFeap8hSIa0wADofcROpkUBfhrwpcavUQMaJIDeaqchMZ(pyfbioXelifqRHfyXcYJXra8WFWkcGfFMdozylt6vrrFuC3AtJSEeaQCvnbgf7iaq7iay6Ja4H)Gveae(CUQMIaGW1lkca2M0687dk6Xg87t7gIL4zXAzbyS00q4WspwsD8ttNmcxViwaEwuEJnybjSS1gS0NfGXstdHdl9yrD1Ag87dEnOOmLAdTqtkvFgd1(yWVhaIfKWI1Ys)iaGeomN9FWkcaYDDyP9NWSyzN(DAy5HSSWelaEFA3qSCflaGAFyXY(f2z5WS4plkKL3hu0JbMYS0GdlecA6WYwBGuzj1XpnDyboSyTSa49bVguelwtQn0cnPu9SGFpaeocacFYLNsraWVpTBO8vzmu7t0hf3yTrK1JaqLRQjWOyhbaAhbatFeap8hSIaGWNZv1ueaeUErrauMfKWc2M068UJFILTzzlw6Aw6XYgMTyb4zPhlyBsRZVpOOhBWVpTBiw6AwuML(Sa8S0JfLzbyS8UMQ3GHlDg2Y)oLBWHWVHkxvtGSa8SOSrHS0NL(Samw2WOSczb4zrD1AMXrqfCHZTHQy2XmuQFfocaiHdZz)hSIaGCxhwA)jmlw2PFNgwEilifJ)7SaUMRqXYMyOkMDIaGWNC5PuealJ)75RYTHQy2j6JIBSuoY6raOYv1eyuSJa4H)GvealJ)7raajCyo7)GveG4etSGum(VZYvSaaQ9HfRjOpBmXcCy5ASuqwa8(0UHyXYP1S0UNLREiliVlijgQalE1jfoueGWCpnNhbOhluqF2yYOxLp5Iq2ZsscluqF2yY4vNCri7zbnli85CvnzoCoOjhbXsFwqZspwEFqrV5Vuk)Wm4rSeplwlljjSqb9zJjJEv(KVkVfljjS0ou7FEOu)kmlBZIYBWsFwssyrD1AgkOpBmLXqTpMHs9RWSSnlE4pyzWVpTBidHmkSEk)xkXcAwuxTMHc6Zgtzmu7JzzZsscluqF2yYCvgd1(WcAwSIfe(CUQMm43N2nu(QmgQ9HLKewuxTMj45RcMHs9RWSSnlE4pyzWVpTBidHmkSEk)xkXcAwSIfe(CUQMmhoh0KJGybnlQRwZe88vbZqP(vyw2Mfczuy9u(VuIf0SOUAntWZxfmlBwssyrD1AMXrqfCHZTHQy2XSSzbnli85CvnzSm(VNVk3gQIzhwssyXkwq4Z5QAYC4CqtocIf0SOUAntWZxfmdL6xHzjEwiKrH1t5)sPOpkUXARiRhbGkxvtGrXocaiHdZz)hSIaeNyIfaVpTBiwUglxXIIVkFyXAc6ZgtkGLRybau7dlwtqF2yIfyXI1cmwEFqrpMf4WYdzXEGbwaa1(WI1e0NnMIa4H)Gvea87t7gk6JIBSIvK1JaqLRQjWOyhbaKWH5S)dwra2eUw)7ZkcGh(dwraMvL9WFWkRp8hbqF4pxEkfbO5A9VpROp6Ja0CT(3NvK1JIRYrwpcavUQMaJIDeap8hSIaGFFWRbffbaKWH5S)dwraa8(GxdkILgCyjfIGsP6zzvAcJzzHVcflXg2fRhbim3tZ5raSILzvudoOiJQR9kqzyl7AD(3Vcf2qk26STjWOpkUBfz9iau5QAcmk2ra8WFWkcaEvTBOiaHobnLFFqrpokUkhbim3tZ5raaHVjfcR2nKzOu)kmlXZYqP(vywaEw2AlwqclkhhraajCyo7)GveaK74NLFNybe(Sy5(Dw(DILui(z5VuILhYIdcYYQ(tZYVtSK6iJfW14)blwoml73BybWQA3qSmuQFfML0L(pB9rGS8qws9pSZskewTBiwaxJ)hSI(O4gRiRhbWd)bRiaPqy1UHIaqLRQjWOyh9rFea8hz9O4QCK1JaqLRQjWOyhbWd)bRia43h8AqrraajCyo7)GveG4etSa49bVguelpKfGiYMLLnl)oXsmEipv9kqAyrD1ASCnwUNflWLgKfcz23qSOsn4qS0U6W7xHILFNyPiK9SeC8ZcCy5HSaUsTzrLAWHyb5WcbeikcqyUNMZJamRIAWbfz(lLSaNkdoKNQEfingQCvnbYcAw6Xcf0NnMmxL9QdlOzXkw6XspwuxTM5VuYcCQm4qEQ6vG0ygk1VcZs8S4H)GLXY4)UHqgfwpL)lLybySSHrzwqZspwOG(SXK5QSk83zjjHfkOpBmzUkJHAFyjjHfkOpBmz0RYNCri7zPpljjSOUAnZFPKf4uzWH8u1RaPXmuQFfML4zXd)bld(9PDdziKrH1t5)sjwaglByuMf0S0JfkOpBmzUkRxLpSKKWcf0NnMmyO2NCri7zjjHfkOpBmz8QtUiK9S0NL(SKKWIvSOUAnZFPKf4uzWH8u1RaPXSSzPpljjS0Jf1vRzcE(QGzzZsscli85CvnzcWcbeikds4ovGL(SGMLaeQbHwktawiGar5FNYy7BUhBgYb7WcAwcqeu51BQd1(NBoXsFwqZspwSILaebvE9gG6mNxSKKWsac1GqlLHsTHwOjRclqZqP(vywINL4GL(SGMLESOUAntWZxfmlBwssyXkwcqOgeAPmbpFvWmKd2HL(rFuC3kY6raOYv1eyuSJa4H)Gveah0T)dbLXw8jncqOtqt53hu0JJIRYracZ90CEeaRybe(gh0T)dbLXw8jnd6PokY8xaORqXcAwSIfp8hSmoOB)hckJT4tAg0tDuK5QCtFO2FwqZspwSIfq4BCq3(peugBXN08o5AZFbGUcfljjSacFJd62)HGYyl(KM3jxBgk1VcZs8SOqw6ZssclGW34GU9FiOm2IpPzqp1rrg87bGyzBwIflOzbe(gh0T)dbLXw8jnd6PokYmuQFfMLTzjwSGMfq4BCq3(peugBXN0mON6OiZFbGUcveaqchMZ(pyfbioXelDb0T)dbXcal(KYILDQy53PHy5WSuqw8WFiiwWw8jvbS4yw0(tS4ywSHy8PQjwGflyl(KYIL73zzlwGdlnYcnSGFpaeMf4WcSyXzjwaJfSfFszbdz539NLFNyPilSGT4tkl(mhccZcsjl8ZI3EAy539NfSfFszHqM9neo6JIBSISEeaQCvnbgf7iaE4pyfbialeqGO8VtzS9n3JJaas4WC2)bRiaXjMWSGCyHaceXY1yb5DbjXqfy5WSSSzboS0bUyXhIfqc3PcxHIfK3fKedvGfl3VZcYHfciqelEbYsh4IfFiwujn0clw7gS0f8Mfbim3tZ5raSIfWzDGMcMdGywqZspw6XccFoxvtMaSqabIYGeUtfybnlwXsac1GqlLj45RcMHCWoSGMfRyzwf1GdkYypxkCapxN9j41fY2ln2hdvUQMazjjHf1vRzcE(QGzzZsFwqZIJ)X1zBOfAyzBLyXA3Gf0S0Jf1vRzOG(SXuwVkFmdL6xHzjEwuEdwssyrD1AgkOpBmLXqTpMHs9RWSeplkVbl9zjjHfvigZcAwAhQ9ppuQFfMLTzr5nybnlwXsac1GqlLj45RcMHCWoS0p6JIR1gz9iau5QAcmk2raG2raW0hbWd)bRiai85CvnfbaHRxueGESOUAnZ4iOcUW52qvm7ygk1VcZs8SOqwssyXkwuxTMzCeubx4CBOkMDmlBw6ZcAwSIf1vRzghbvWfo3gQIzNm(Q2sN37GFAo3SSzbnl9yrD1AgGUcCiWmLAdTqtkvFMkAqDXKmdL6xHzzBwqfanPoYyPplOzPhlQRwZqb9zJPmgQ9XmuQFfML4zbva0K6iJLKewuxTMHc6Zgtz9Q8XmuQFfML4zbva0K6iJLKew6XIvSOUAndf0NnMY6v5JzzZssclwXI6Q1muqF2ykJHAFmlBw6ZcAwSIL31u9gmuJ)lqgQCvnbYs)iaGeomN9FWkcaYHf49hSyPbhwCTMfq4Jz539NLuhicZcEnel)o1HfFOsrpld1gcVtGSyzNkwIrDeubxyw2edvXSdl7oMfnHXS87EXIczbtbmldL6xDfkwGdl)oXcqDMZlwuxTglhMfxfUEwEilnxRzb2ASahw8QdlwtqF2yILdZIRcxplpKfcz23qraq4tU8ukcai8ZdPyRBOuQEC0hfxfgz9iau5QAcmk2raG2raW0hbWd)bRiai85CvnfbaHRxueGESyflQRwZqb9zJPmgQ9XSSzbnlwXI6Q1muqF2ykRxLpMLnl9zjjHL31u9gmuJ)lqgQCvnbgbaKWH5S)dwraqoSaV)Gfl)U)Se2PaqywUglDGlw8HybUE8bsSqb9zJjwEilWs3Hfq4ZYVtdXcCy5qvWHy53pmlwUFNfaqn(VafbaHp5YtPiaGWpdxp(aPmf0NnMI(O4U5rwpcavUQMaJIDeap8hSIaKcHv7gkcqyUNMZJamuBi8URQjwqZspwuxTMHc6Zgtzmu7JzOu)kmlXZYqP(vywssyrD1AgkOpBmL1RYhZqP(vywINLHs9RWSKKWccFoxvtgq4NHRhFGuMc6ZgtS0Nf0SmuBi8URQjwqZY7dk6n)Ls5hMbpIL4zr5TybnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hfxGBK1JaqLRQjWOyhbWd)bRia4v1UHIaeM7P58iad1gcV7QAIf0S0Jf1vRzOG(SXugd1(ygk1VcZs8SmuQFfMLKewuxTMHc6Zgtz9Q8XmuQFfML4zzOu)kmljjSGWNZv1Kbe(z46XhiLPG(SXel9zbnld1gcV7QAIf0S8(GIEZFPu(HzWJyjEwuElwqZIBNd7uaiwqZccFoxvtgq4NhsXw3qPu94iaHobnLFFqrpokUkh9rXnoISEeaQCvnbgf7iaE4pyfba)Kw7tUP9HIaeM7P58iad1gcV7QAIf0S0Jf1vRzOG(SXugd1(ygk1VcZs8SmuQFfMLKewuxTMHc6Zgtz9Q8XmuQFfML4zzOu)kmljjSGWNZv1Kbe(z46XhiLPG(SXel9zbnld1gcV7QAIf0S8(GIEZFPu(HzWJyjEwuEZzbnlUDoStbGybnli85CvnzaHFEifBDdLs1JJae6e0u(9bf94O4QC0hf3nnY6raOYv1eyuSJa4H)GveGgCcug2YL)RHIaas4WC2)bRiaXjMyztaJllWILailwUFhUEwcUT9vOIaeM7P58iaUDoStbGI(O4Q8grwpcavUQMaJIDeap8hSIaqP2ql0KvHfyeaqchMZ(pyfbioXeliLVcCiqwayFZ9ywSC)olE1HfnSqXcvWfQDw0o(VcflwtqF2yIfVaz5NoS8qw0xrSCpllBwSC)olB2sJ9HfVazb5DbjXqfIaeM7P58ia9yPhlQRwZqb9zJPmgQ9XmuQFfML4zr5nyjjHf1vRzOG(SXuwVkFmdL6xHzjEwuEdw6ZcAwcqOgeAPmbpFvWmuQFfML4zjwBWcAw6XI6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lILTzzlRDdwssyXkwMvrn4GIm2ZLchWZ1zFcEDHS9sJ9Xqk26STjqw6ZsFwssyrD1Ag75sHd456SpbVUq2EPX(yq46fXs8kXYwa3nyjjHLaeQbHwktWZxfmd5GDybnlo(hxNTHwOHL4zzt3i6JIRYkhz9iau5QAcmk2raG2raW0hbWd)bRiai85CvnfbaHRxueaRybCwhOPG5aiMf0SGWNZv1KjaMdWc8(dwSGMLES0JLaeQbHwkdLA3zixNHdy5vGmdL6xHzzBwuEZbUSamw6XIYkZcWZYSkQbhuKbFvBPZ7DWpnNBOYv1eil9zbnlKIToBBc0qP2DgY1z4awEfiw6Zssclo(hxNTHwOHL4vILnDdwqZspwSIL31u9M2A6KHTmPxfzOYv1eiljjSOUAntWZxfmGRX)dwSeplbiudcTuM2A6KHTmPxfzgk1VcZcWyjoyPplOzbe(g8QA3qMHs9RWSeplkVflOzbe(MuiSA3qMHs9RWSeplXblOzPhlGW3GFsR9j30(qMHs9RWSeplXbljjSyflVRP6n4N0AFYnTpKHkxvtGS0Nf0SGWNZv1K53NtRZyIaIMSf)EwqZspwuxTMbORahcmtP2ql0Ks1NPIguxmjZYMLKewSILaebvE9gG6mNxS0Nf0S8(GIEZFPu(HzWJyjEwuxTMj45RcgW14)blwaEw2WaCzjjHfvigZcAwAhQ9ppuQFfMLTzrD1AMGNVkyaxJ)hSyjjHLaebvE9M6qT)5MtSKKWI6Q1mQAieuVWVzzZcAwuxTMrvdHG6f(ndL6xHzzBwuxTMj45RcgW14)blwagl9yztzb4zzwf1GdkYypxkCapxN9j41fY2ln2hdPyRZ2MazPpl9zbnlwXI6Q1mbpFvWSSzbnl9yXkwcqeu51BQd1(NBoXssclbiudcTuMaSqabIY)oLX23Cp2SSzjjHfvigZcAwAhQ9ppuQFfMLTzjaHAqOLYeGfciqu(3Pm2(M7XMHs9RWSamw2CwssyPDO2)8qP(vywqQSOCCSblBZI6Q1mbpFvWaUg)pyXs)iaGeomN9FWkcqCIjwqExqsmubwSC)olihwiGaribP8vGdbYca7BUhZIxGSaclf9SarqJL5EILnBPX(WcCyXYovSeBnecQx4NflWLgKfcz23qSOsn4qSG8UGKyOcSqiZ(gchbaHp5YtPiabWCawG3FWkJ)OpkUkVvK1JaqLRQjWOyhbaAhbatFeap8hSIaGWNZv1ueaeUErraSIfWzDGMcMdGywqZccFoxvtMayoalW7pyXcAw6XspwcqOgeAPmuQDNHCDgoGLxbYmuQFfMLTzr5nh4YcWyPhlkRmlaplZQOgCqrg8vTLoV3b)0CUHkxvtGS0Nf0Sqk26STjqdLA3zixNHdy5vGyPpljjS44FCD2gAHgwIxjw20nybnl9yXkwExt1BARPtg2YKEvKHkxvtGSKKWI6Q1mbpFvWaUg)pyXs8SeGqni0szARPtg2YKEvKzOu)kmlaJL4GL(SGMfq4BWRQDdzgk1VcZs8SehSGMfq4BsHWQDdzgk1VcZs8SSPSGMLESacFd(jT2NCt7dzgk1VcZs8SO8gSKKWIvS8UMQ3GFsR9j30(qgQCvnbYsFwqZccFoxvtMFFoToJjciAYw87zbnl9yrD1AgGUcCiWmLAdTqtkvFMkAqDXKmlBwssyXkwcqeu51BaQZCEXsFwqZY7dk6n)Ls5hMbpIL4zrD1AMGNVkyaxJ)hSyb4zzddWLLKewuHymlOzPDO2)8qP(vyw2Mf1vRzcE(QGbCn(FWILKewcqeu51BQd1(NBoXssclQRwZOQHqq9c)MLnlOzrD1AgvnecQx43muQFfMLTzrD1AMGNVkyaxJ)hSybyS0JLnLfGNLzvudoOiJ9CPWb8CD2NGxxiBV0yFmKIToBBcKL(S0Nf0SyflQRwZe88vbZYMf0S0JfRyjarqLxVPou7FU5eljjSeGqni0szcWcbeik)7ugBFZ9yZYMLKewuHymlOzPDO2)8qP(vyw2MLaeQbHwktawiGar5FNYy7BUhBgk1VcZcWyzZzjjHfvigZcAwAhQ9ppuQFfMfKklkhhBWY2SOUAntWZxfmGRX)dwS0pcacFYLNsracG5aSaV)Gvg)rFuCvowrwpcavUQMaJIDeap8hSIamocQGlCUnufZoraajCyo7)GveG4etS87elXiO637mSy5(DwCwqExqsmubw(D)z5WLIEwAdmLLnBPX(ebim3tZ5rauxTMj45RcMHs9RWSeplkRqwssyrD1AMGNVkyaxJ)hSyzBwI1wSGMfe(CUQMmbWCawG3FWkJ)OpkUkBTrwpcavUQMaJIDeGWCpnNhbaHpNRQjtamhGf49hSY4Nf0S0Jf1vRzcE(QGbCn(FWIL4vILyTfljjSyflbicQ86niO637mS0NLKewuxTMzCeubx4CBOkMDmlBwqZI6Q1mJJGk4cNBdvXSJzOu)kmlBZYMYcWyjalW19g7HchMYU(qvPu9M)sPmcxViwagl9yXkwuxTMrvdHG6f(nlBwqZIvS8UMQ3GFF0Wb0qLRQjqw6hbWd)bRiabst4)CD21hQkLQp6JIRYkmY6raOYv1eyuSJaeM7P58iai85CvnzcG5aSaV)Gvg)ra8WFWkcWvbFk)pyf9rXv5npY6raOYv1eyuSJaaTJaGPpcGh(dwraq4Z5QAkcacxVOiawXsac1GqlLj45RcMHCWoSKKWIvSGWNZv1KjaleqGOmiH7ubwqZsaIGkVEtDO2)CZjwssybCwhOPG5aiocaiHdZz)hSIaeJWNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoccKLgCyb5DbjXqfybdz539NLFN6WIpu9SyXXpbYcsjl8ZIk1GdXYVtPraq4tU8ukca2rq5gCYbpFvi6JIRYa3iRhbGkxvtGrXocGh(dwraARPtg2YKEvueaqchMZ(pyfbioXeMLnb0Ay5ASCflEXI1e0NnMyXlqw(5imlpKf9vel3ZYYMfl3VZYMT0yFualiVlijgQalEbYsxaD7)qqSaWIpPracZ90CEeakOpBmzUk7vhwqZIBNd7uaiwqZI6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lILTzzlRDdwqZspwaHVXbD7)qqzSfFsZGEQJIm)fa6kuSKKWIvSeGiOYR3uuyGA4aYsFwqZccFoxvtgSJGYn4KdE(QalOzPhlQRwZmocQGlCUnufZoMHs9RWSSnlBklDnl9yrHSa8SmRIAWbfzWx1w68Eh8tZ5gQCvnbYcWyXkwifBD22eO5k8pRWdhCg8qCfLvjTML(SGMf1vRzghbvWfo3gQIzhZYMLKewSIf1vRzghbvWfo3gQIzhZYML(rFuCvooISEeaQCvnbgf7iaE4pyfba)(0CTocaiHdZz)hSIaeNyILn5I(Dwa8(0CTMf7bgWSCnwa8(0CTMLdxk6zzzhbim3tZ5rauxTMbw0VJZ20ei7)GLzzZcAwuxTMb)(0CT2muBi8URQPOpkUkVPrwpcavUQMaJIDeGWCpnNhbqD1Ag87JgoGMHs9RWSSnlkKf0S0Jf1vRzOG(SXugd1(ygk1VcZs8SOqwssyrD1AgkOpBmL1RYhZqP(vywINffYsFwqZIJ)X1zBOfAyjEw20nIa4H)GveGGxbsNvxTwea1vRLlpLIaGFF0Wbm6JI7wBez9iau5QAcmk2ra8WFWkca(9bVguueaqchMZ(pyfbigVsTXS0f8MXIk1GdXcYHfciqell8vOy53jwqoSqabIyjalW7pyXYdzjStbGy5ASGCyHaceXYHzXd)Y16oS4QW1ZYdzrLyj44pcqyUNMZJaeGiOYR3uhQ9p3CIf0SGWNZv1KjaleqGOmiH7ubwqZsac1GqlLjaleqGO8VtzS9n3JndL6xHzzBwuilOzXkwaN1bAkyoaIzbnluqF2yYCv2RoSGMfh)JRZ2ql0Ws8SyTBe9rXDlLJSEeaQCvnbgf7iaE4pyfba)(0CTocaiHdZz)hSIaeNyIfaVpnxRzXY97Sa4jT2hwIXZ1Ew8cKLcYcG3hnCavalw2PILcYcG3NMR1SCyww2kGLoWfl(qSCflk(Q8HfRjOpBmXsdoSehadtbmlWHLhYI9adSSzln2hwSStflUkebXYMUblDbVzSahwCqB)peelyl(KYYUJzjoagMcywgk1V6kuSahwomlxXstFO2FdlXf(el)U)SSkqAy53jwWEkXsawG3FWcZY9kcZcOnMLIw)4AwEilaEFAUwZc4AUcflXOocQGlmlBIHQy2rbSyzNkw6axkcKf8FAnlubYYYMfl3VZYMUbWCSnln4WYVtSOD8Zcknu11yteGWCpnNhb4DnvVb)Kw7tgCU2BOYv1eilOzXkwExt1BWVpA4aAOYv1eilOzrD1Ag87tZ1AZqTHW7UQMybnl9yrD1AgkOpBmL1RYhZqP(vywINL4Gf0Sqb9zJjZvz9Q8Hf0SOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IyzBw2sHBWssclQRwZypxkCapxN9j41fY2ln2hdcxViwIxjw2sHBWcAwC8pUoBdTqdlXZYMUbljjSacFJd62)HGYyl(KMb9uhfzgk1VcZs8SehSKKWIh(dwgh0T)dbLXw8jnd6PokYCvUPpu7pl9zbnlbiudcTuMGNVkygk1VcZs8SO8grFuC3ARiRhbGkxvtGrXocGh(dwraWVp41GIIaas4WC2)bRiaXjMybW7dEnOiw2Kl63zXEGbmlEbYc4k1MLUG3mwSStfliVlijgQalWHLFNyjgbv)ENHf1vRXYHzXvHRNLhYsZ1AwGTglWHLoWLIazj42S0f8Mfbim3tZ5rauxTMbw0VJZbn5tgXHpyzw2SKKWI6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2SKKWI6Q1mbpFvWSSzbnl9yrD1AMXrqfCHZTHQy2XmuQFfMLTzbva0K6iJfGNLaDAw6XIJ)X1zBOfAybjSeRnyPplaJLyXcWZY7AQEtrwYPqyzOYv1eilOzXkwMvrn4GIm4RAlDEVd(P5CdvUQMazbnlQRwZmocQGlCUnufZoMLnljjSOUAntWZxfmdL6xHzzBwqfanPoYyb4zjqNMLES44FCD2gAHgwqclXAdw6ZssclQRwZmocQGlCUnufZoz8vTLoV3b)0CUzzZsscl9yrD1AMXrqfCHZTHQy2XmuQFfMLTzXd)bld(9PDdziKrH1t5)sjwqZc2M068UJFILTzzdJ1YssclQRwZmocQGlCUnufZoMHs9RWSSnlE4pyzSm(VBiKrH1t5)sjwssybHpNRQjZPyG5aSaV)GflOzjaHAqOLYCfomR3v1uwXwE9R0miH4cKzihSdlOzHuS1zBtGMRWHz9UQMYk2YRFLMbjexGyPplOzrD1AMXrqfCHZTHQy2XSSzjjHfRyrD1AMXrqfCHZTHQy2XSSzbnlwXsac1GqlLzCeubx4CBOkMDmd5GDyjjHfRyjarqLxVbbv)ENHL(SKKWIJ)X1zBOfAyjEw20nybnluqF2yYCv2RorFuC3kwrwpcavUQMaJIDeap8hSIaGFFWRbffbaKWH5S)dwraS(0HLhYsQdeXYVtSOs4NfyJfaVpA4aYIAhwWVha6kuSCpllBwuS1fas3HLRyXRoSynb9zJjwuxplB2sJ9HLdxplUkC9S8qwujwShyiqGracZ90CEeG31u9g87JgoGgQCvnbYcAwSILzvudoOiZFPKf4uzWH8u1RaPXqLRQjqwqZspwuxTMb)(OHdOzzZssclo(hxNTHwOHL4zzt3GL(SGMf1vRzWVpA4aAWVhaILTzjwSGMLESOUAndf0NnMYyO2hZYMLKewuxTMHc6Zgtz9Q8XSSzPplOzrD1Ag75sHd456SpbVUq2EPX(yq46fXY2SSfWDdwqZspwcqOgeAPmbpFvWmuQFfML4zr5nyjjHfRybHpNRQjtawiGarzqc3PcSGMLaebvE9M6qT)5MtS0p6JI7wwBK1JaqLRQjWOyhbaAhbatFeap8hSIaGWNZv1ueaeUErraOG(SXK5QSEv(WcWZsCWcsyXd)bld(9PDdziKrH1t5)sjwaglwXcf0NnMmxL1RYhwaEw6XYMZcWy5DnvVbdx6mSL)Dk3GdHFdvUQMazb4zjwS0NfKWIh(dwglJ)7gczuy9u(VuIfGXYggRvHSGewW2KwN3D8tSamw2WOqwaEwExt1Bk)xdHZQU2RazOYv1eyeaqchMZ(pyfbWAW)L6pHzzhAHL0vyNLUG3mw8HybLFfbYInnSGPaSaJaGWNC5PueahBVz0aGcrFuC3sHrwpcavUQMaJIDeap8hSIaGFFWRbffbaKWH5S)dwraIXRuBwa8(GxdkILRyXzb4cmmfybau7dlwtqF2ysbSaclf9SOPNL7zXEGbw2SLg7dl9(D)z5WSS7fOMazrTdl0970WYVtSa49P5Anl6RiwGdl)oXsxWBw8B6gSOVIyPbhwa8(GxdkQVcybewk6zbIGglZ9elEXYMCr)ol2dmWIxGSOPNLFNyXvHiiw0xrSS7fOMybW7JgoGracZ90CEeaRyzwf1GdkY8xkzbovgCipv9kqAmu5QAcKf0S0Jf1vRzSNlfoGNRZ(e86cz7Lg7JbHRxelBZYwa3nyjjHf1vRzSNlfoGNRZ(e86cz7Lg7JbHRxelBZYwkCdwqZY7AQEd(jT2Nm4CT3qLRQjqw6ZcAw6Xcf0NnMmxLXqTpSGMfh)JRZ2ql0WcWybHpNRQjJJT3mAaqbwaEwuxTMHc6Zgtzmu7JzOu)kmlaJfq4BARPtg2YKEvK5Vaq48qP(vSa8SSLrHSeplXXgSKKWcf0NnMmxL1RYhwqZIJ)X1zBOfAybySGWNZv1KXX2BgnaOalaplQRwZqb9zJPSEv(ygk1VcZcWybe(M2A6KHTmPxfz(laeopuQFflaplBzuilXZYMUbl9zbnlwXI6Q1mWI(DC2MMaz)hSmlBwqZIvS8UMQ3GFF0Wb0qLRQjqwqZspwcqOgeAPmbpFvWmuQFfML4zb4Ysscly4sREfO53NtRZyIaIgdvUQMazbnlQRwZ87ZP1zmrarJb)Eaiw2MLyflw6Aw6XYSkQbhuKbFvBPZ7DWpnNBOYv1eilaplkKL(SGML2HA)ZdL6xHzjEwuEJnybnlTd1(Nhk1VcZY2SS1gBWssclGZ6anfmhaXS0Nf0S0JLaeQbHwkdqxboeygBFZ9yZqP(vywINfGlljjSyflbicQ86na1zoVyPF0hf3T28iRhbGkxvtGrXocGh(dwrakYsofcRiaGeomN9FWkcqCIjw2KGWcZYvSO4RYhwSMG(SXelEbYc2rqSeJSRBaBtS0Aw2KGWILgCyb5DbjXqfyXlqwqkFf4qGSynP2ql0Ks1hbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPeljjS0JLWUpOimlkXYwSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyjwS0Nf0S425WofaIf0SGWNZv1Kb7iOCdo5GNVke9rXDlGBK1JaqLRQjWOyhbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPelOzXkwcqeu51BaQZCEXsscl9yrD1AgGUcCiWmLAdTqtkvFMkAqDXKmlBwqZsaIGkVEdqDMZlw6Zsscl9yjS7dkcZIsSSflOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwIfljjSOUAntWZxfmlBw6ZcAwC7CyNcaXcAwq4Z5QAYGDeuUbNCWZxfybnl9yrD1AMXrqfCHZTHQy2XmuQFfMLTzPhlkKLUMLTyb4zzwf1GdkYGVQT059o4NMZnu5QAcKL(SGMf1vRzghbvWfo3gQIzhZYMLKewSIf1vRzghbvWfo3gQIzhZYML(ra8WFWkcWURB5uiSI(O4UvCez9iau5QAcmk2racZ90CEeGESOUAndf0NnMY6v5JzOu)kmlXZcHmkSEk)xkXcAwSILaebvE9gG6mNxSKKWspwuxTMbORahcmtP2ql0Ks1NPIguxmjZYMf0SeGiOYR3auN58IL(SKKWspwc7(GIWSOelBXcAwgkS7dkk)xkXY2SOqw6ZssclHDFqrywuILyXssclQRwZe88vbZYML(SGMf3oh2PaqSGMfe(CUQMmyhbLBWjh88vbwqZspwuxTMzCeubx4CBOkMDmdL6xHzzBwuilOzrD1AMXrqfCHZTHQy2XSSzbnlwXYSkQbhuKbFvBPZ7DWpnNBOYv1eiljjSyflQRwZmocQGlCUnufZoMLnl9Ja4H)GveG2sRZPqyf9rXDRnnY6raOYv1eyuSJaas4WC2)bRiaXjMybPaAnSalwcGra8WFWkcGfFMdozylt6vrrFuCJ1grwpcavUQMaJIDeap8hSIaGFFA3qraajCyo7)GveG4etSa49PDdXYdzXEGbwaa1(WI1e0NnMualiVlijgQal7oMfnHXS8xkXYV7flolifJ)7SqiJcRNyrtTNf4WcS0DyrXxLpSynb9zJjwomll7iaH5EAopcaf0NnMmxL1RYhwqZIvSOUAnZ4iOcUW52qvm7yw2SKKWcf0NnMmyO2NCri7zjjHfkOpBmz8QtUiK9SKKWspwuxTMXIpZbNmSLj9QiZYMLKewW2KwN3D8tSSnlBySwfYcAwSILaebvE9geu97DgwssybBtADE3XpXY2SSHXAzbnlbicQ86niO637mS0Nf0SOUAndf0NnMY6v5JzzZsscl9yrD1AMGNVkygk1VcZY2S4H)GLXY4)UHqgfwpL)lLybnlQRwZe88vbZYML(rFuCJLYrwpcavUQMaJIDeaqchMZ(pyfbioXelifJ)7Sa)DASCyIfl7xyNLdZYvSaaQ9HfRjOpBmPawqExqsmubwGdlpKf7bgyrXxLpSynb9zJPiaE4pyfbWY4)E0hf3yTvK1JaqLRQjWOyhbaKWH5S)dwra2eUw)7ZkcGh(dwraMvL9WFWkRp8hbqF4pxEkfbO5A9VpROp6JaypuaMQ6FK1JIRYrwpcGh(dwraa6kWHaZy7BUhhbGkxvtGrXo6JI7wrwpcavUQMaJIDeaODeam9ra8WFWkcacFoxvtraq46ffbyJiaGeomN9FWkcG13jwq4Z5QAILdZcMEwEilBWIL73zPGSGF)zbwSSWel)Cfq0JvalkZILDQy53jwA3GFwGfXYHzbwSSWKcyzlwUgl)oXcMcWcKLdZIxGSelwUglQWFNfFOiai8jxEkfbaw5fMY)Cfq0h9rXnwrwpcavUQMaJIDeaODeahemcGh(dwraq4Z5QAkcacxVOiakhbim3tZ5ra(5kGO38kB2DCEHPS6Q1ybnl)Cfq0BELnbiudcTugW14)blwqZIvS8ZvarV5v2CyZdtPmSLtHf(h4cNdWc)Zk8hSWraq4tU8ukcaSYlmL)5kGOp6JIR1gz9iau5QAcmk2raG2raCqWiaE4pyfbaHpNRQPiaiC9IIaSveGWCpnNhb4NRaIEZVLz3X5fMYQRwJf0S8ZvarV53YeGqni0szaxJ)hSybnlwXYpxbe9MFlZHnpmLYWwofw4FGlCoal8pRWFWchbaHp5YtPiaWkVWu(NRaI(OpkUkmY6raOYv1eyuSJaaTJa4GGra8WFWkcacFoxvtraq4tU8ukcaSYlmL)5kGOpcqyUNMZJaqk26STjqZv4WSExvtzfB51VsZGeIlqSKKWcPyRZ2ManuQDNHCDgoGLxbILKewifBD22eObdxAn9)vOYZsTteaqchMZ(pyfbW67eMy5NRaIEml(qSuWNfF9Wu)VGR1DybKEk8eiloMfyXYctSGF)z5NRaIESHfwaqpli85CvnXYdzXAzXXS87uhwCngYsreilyBkCUMLDVa1xHYebaHRxueaRn6JI7Mhz9iaE4pyfbifclGUk3GtAeaQCvnbgf7OpkUa3iRhbGkxvtGrXocGh(dwraSm(Vhbim3tZ5ra6Xcf0NnMm6v5tUiK9SKKWcf0NnMmxLXqTpSKKWcf0NnMmxLvH)oljjSqb9zJjJxDYfHSNL(ra0xr5ayeaL3i6J(OpcacAWhSII7wBSLYBehkhhraS4tDfkCeaKIUeJg3yiUXibCyHfRVtSCP2W5zPbhwue0MkAueldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kILTaoSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSelGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3C3ifDjgnUXqCJrc4WclwFNy5sTHZZsdoSOiqQ5l9RiwgsXw3qGSGHPel(6HP(tGSe29cfHnC3k(velBoWHfKdle08eilaUuKZcUt9oYybPYYdzrXxolGhIdFWIfOnn(dhw6HK(S0tzK13WDR4xrSS5ahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8RiwaUahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8RiwIdGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zP3wiRVH7wXVIyjoaoSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSSPahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8Riw2uGdlihwiO5jqwu0pxbe9gLnDLIy5HSOOFUci6nVYMUsrS0BlK13WDR4xrSSPahwqoSqqZtGSOOFUci6nBz6kfXYdzrr)Cfq0B(TmDLIyP3wiRVH7wXVIyr5naoSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSOSYahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8RiwuElGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkhlGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkRqGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkV5ahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6TfY6B4Uv8RiwuEZboSGCyHGMNazrr)Cfq0Bu20vkILhYII(5kGO38kB6kfXsVTqwFd3TIFfXIYBoWHfKdle08eilk6NRaIEZwMUsrS8qwu0pxbe9MFltxPiw6PmY6B4Uv8Riwug4cCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyP3wiRVH7wXVIyrzGlWHfKdle08eilk6NRaIEJYMUsrS8qwu0pxbe9MxztxPiw6PmY6B4Uv8Riwug4cCyb5WcbnpbYII(5kGO3SLPRuelpKff9ZvarV53Y0vkILEBHS(gUBUBKIUeJg3yiUXibCyHfRVtSCP2W5zPbhwuK9qbyQQ)kILHuS1neilyykXIVEyQ)eilHDVqryd3TIFfXsSaoSGCyHGMNazrr)Cfq0Bu20vkILhYII(5kGO38kB6kfXsVyHS(gUBf)kIfRf4WcYHfcAEcKff9ZvarVzltxPiwEilk6NRaIEZVLPRuel9IfY6B4U5Urk6smACJH4gJeWHfwS(oXYLAdNNLgCyrroKueldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kIfLboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS4plwZMSIZspLrwFd3TIFfXsSaoSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSaCboSGCyHGMNazbWLICwWDQ3rglivKklpKffF5SKcbx6fMfOnn(dhw6Hu7ZspLrwFd3TIFfXcWf4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXsVTqwFd3TIFfXsCaCyb5WcbnpbYcGlf5SG7uVJmwqQivwEilk(YzjfcU0lmlqBA8hoS0dP2NLEkJS(gUBf)kIL4a4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYMcCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyr5naoSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEBHS(gUBf)kIfLJfWHfKdle08eilaUuKZcUt9oYybPYYdzrXxolGhIdFWIfOnn(dhw6HK(S0tzK13WDR4xrSS1gahwqoSqqZtGSOOzvudoOitxPiwEilkAwf1GdkY0vgQCvnbQiw6PmY6B4Uv8Riw2AlGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zPNYiRVH7wXVIyzlRf4WcYHfcAEcKfaxkYzb3PEhzSGuz5HSO4lNfWdXHpyXc0Mg)Hdl9qsFw6TfY6B4Uv8Riw2YAboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSS1MdCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyzlGlWHfKdle08eilkAwf1GdkY0vkILhYIIMvrn4GImDLHkxvtGkILEkJS(gUBf)kILT2uGdlihwiO5jqwaCPiNfCN6DKXcsLLhYIIVCwapeh(GflqBA8hoS0dj9zP3wiRVH7wXVIyjwBaCyb5WcbnpbYcGlf5SG7uVJmwqQS8qwu8LZc4H4WhSybAtJ)WHLEiPpl9ugz9nC3C3ifDjgnUXqCJrc4WclwFNy5sTHZZsdoSOOMR1)(SueldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kILTaoSGCyHGMNazbWLICwWDQ3rglivwEilk(Yzb8qC4dwSaTPXF4WspK0NLEkJS(gUBUBKIUeJg3yiUXibCyHfRVtSCP2W5zPbhwue(veldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUBf)kIfLboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSelGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkRmWHfKdle08eilaUuKZcUt9oYybPIuz5HSO4lNLui4sVWSaTPXF4WspKAFw6PmY6B4Uv8RiwuwzGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkVfWHfKdle08eilaUuKZcUt9oYybPIuz5HSO4lNLui4sVWSaTPXF4WspKAFw6PmY6B4Uv8RiwuElGdlihwiO5jqwu0SkQbhuKPRuelpKffnRIAWbfz6kdvUQMavel9ugz9nC3k(velkdCboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0tzK13WDR4xrSS1wahwqoSqqZtGSa4srol4o17iJfKklpKffF5SaEio8blwG204pCyPhs6ZsVTqwFd3TIFfXYwBbCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyzRybCyb5WcbnpbYIIMvrn4GImDLIy5HSOOzvudoOitxzOYv1eOIyPNYiRVH7wXVIyzlRf4WcYHfcAEcKfaxkYzb3PEhzSGuz5HSO4lNfWdXHpyXc0Mg)Hdl9qsFw6flK13WDR4xrSSLcboSGCyHGMNazrrZQOgCqrMUsrS8qwu0SkQbhuKPRmu5QAcurS0BlK13WDR4xrSSfWf4WcYHfcAEcKffnRIAWbfz6kfXYdzrrZQOgCqrMUYqLRQjqfXspLrwFd3TIFfXYwXbWHfKdle08eilkAwf1GdkY0vkILhYIIMvrn4GImDLHkxvtGkILEkJS(gUBUBKIUeJg3yiUXibCyHfRVtSCP2W5zPbhwuKk0FfXYqk26gcKfmmLyXxpm1FcKLWUxOiSH7wXVIyr54a4WcYHfcAEcKfaxkYzb3PEhzSGuz5HSO4lNfWdXHpyXc0Mg)Hdl9qsFw6flK13WDR4xrSO8McCyb5WcbnpbYcGlf5SG7uVJmwqQS8qwu8LZc4H4WhSybAtJ)WHLEiPpl9ugz9nC3C3XqQnCEcKfGllE4pyXI(Wp2WDhbaBtHO4Q8gBfbWEGTttraqAKMLy7AVcelX4zDGC3insZsxwOw4NLT2ufWYwBSLYC3C3insZcY39cfHboC3insZsxZsxabjqwaa1(WsSjp1WDJ0inlDnliF3lueilVpOOpFnwcoMWS8qwcDcAk)(GIESH7gPrAw6AwIrPuiccKLvvuGWyF6WccFoxvtyw6DgYOawShcrg)(GxdkILUoEwShcHb)(GxdkQVH7gPrAw6Aw6cc4bYI9qbh)xHIfKIX)DwUgl3Riml)oXILbwOyXAc6ZgtgUBKgPzPRzztYbIyb5WcbeiILFNybG9n3JzXzrF)RjwsHdXstti7u1el9UglDGlw2DWsrpl73ZY9SGV0L(9IGlSUdlwUFNLyVj3fRZcWyb5KMW)5Aw6I(qvPu9kGL7veilyGo7(gUBKgPzPRzztYbIyjfIFwuu7qT)5Hs9RWkIfCGkFoiMf32w3HLhYIkeJzPDO2FmlWs3XWDJ0inlDnlwFi)zX6WuIfyJLyR9DwIT23zj2AFNfhZIZc2McNRz5NRaIEd3nsJ0S01SSjBtfnS07mKrbSGum(VRawqkg)3valaEFA3q9zj1bjwsHdXYq4tFu9S8qwiF0hnSeGPQ(3143N3WDZDJ0inlDPk47pbYsSDTxbILUSzkolbVyrLyPbxfil(ZY()2yGdsqIQR9kqDn(sdgu3VVunhejX21EfOUgWLICKKcA2)unsPBNMus11EfiZJSN7M72d)blSXEOamv1FLa6kWHaZy7BUhZDJ0Sy9DIfe(CUQMy5WSGPNLhYYgSy5(Dwkil43FwGfllmXYpxbe9yfWIYSyzNkw(DIL2n4NfyrSCywGfllmPaw2ILRXYVtSGPaSaz5WS4filXILRXIk83zXhI72d)blSXEOamv1FGPesq4Z5QAsbLNskbR8ct5FUci6vacxViL2G72d)blSXEOamv1FGPesq4Z5QAsbLNskbR8ct5FUci6va0wjheubiC9IuszfCnL(5kGO3OSz3X5fMYQRwd9pxbe9gLnbiudcTugW14)bl0w9ZvarVrzZHnpmLYWwofw4FGlCoal8pRWFWcZD7H)Gf2ypuaMQ6pWucji85CvnPGYtjLGvEHP8pxbe9kaARKdcQaeUErkTLcUMs)Cfq0B2YS748ctz1vRH(NRaIEZwMaeQbHwkd4A8)GfAR(5kGO3SL5WMhMszylNcl8pWfohGf(Nv4pyH5UrAwS(oHjw(5kGOhZIpelf8zXxpm1)l4ADhwaPNcpbYIJzbwSSWel43Fw(5kGOhByHfa0ZccFoxvtS8qwSwwCml)o1HfxJHSuebYc2McNRzz3lq9vOmC3E4pyHn2dfGPQ(dmLqccFoxvtkO8usjyLxyk)ZvarVcG2k5GGkaHRxKswRcUMsKIToBBc0CfomR3v1uwXwE9R0miH4cuscPyRZ2ManuQDNHCDgoGLxbkjHuS1zBtGgmCP10)xHkpl1oC3E4pyHn2dfGPQ(dmLqskewaDvUbNuUBp8hSWg7HcWuv)bMsiXY4)Uc0xr5aOskVHcUMs9OG(SXKrVkFYfHSpjHc6ZgtMRYyO2NKekOpBmzUkRc)9KekOpBmz8QtUiK995U5UrAw2SHco(zzlwqkg)3zXlqwCwa8(GxdkIfyXcaRZIL73zjUhQ9NLnHtS4filXg2fRZcCybW7t7gIf4VtJLdtC3E4pyHnqBQObykHelJ)7k4Ak1Jc6Zgtg9Q8jxeY(KekOpBmzUkJHAFssOG(SXK5QSk83tsOG(SXKXRo5Iq23hT9qimkBSm(VJ2k7Hqy2Yyz8FN72d)blSbAtfnatjKGFFA3qkqFfLdGkPqfCnLSAwf1GdkYO6AVcug2YUwN)9RqHtsSkarqLxVPou7FU5usIvyBsRZVpOOhBWVpnxRvs5KeRExt1Bk)xdHZQU2RazOYv1eysspkOpBmzWqTp5Iq2NKqb9zJjZvz9Q8jjHc6ZgtMRYQWFpjHc6ZgtgV6KlczFFUBp8hSWgOnv0amLqc(9bVguKc0xr5aOskubxtPzvudoOiJQR9kqzyl7AD(3VcfgDaIGkVEtDO2)CZj0yBsRZVpOOhBWVpnxRvszUBUBKgPzXAqgfwpbYcHGMoS8xkXYVtS4HhoSCywCe(PDvnz4U9WFWcRegQ9jRsEk3Th(dwyGPescUwN9WFWkRp8RGYtjLG2urJcUMs)LsB3BlG3d)blJLX)DtWXF(VucyE4pyzWVpTBitWXF(VuQp3nsZca6XS0fO1WcSyjwaJfl3VdxplGZ1Ew8cKfl3VZcG3hnCazXlqw2cySa)DASCyI72d)blmWucji85CvnPGYtjLoC2HKcq46fPe2M0687dk6Xg87tZ164vgDpRExt1BWVpA4aAOYv1eysY7AQEd(jT2Nm4CT3qLRQjW(jjyBsRZVpOOhBWVpnxRJFlUBKMfa0JzjOjhbXILDQybW7t7gILGxSSFplBbmwEFqrpMfl7xyNLdZYqAcHxpln4WYVtSynb9zJjwEilQel2d1Oziqw8cKfl7xyNL2P10WYdzj44N72d)blmWucji85CvnPGYtjLoCoOjhbPaeUErkHTjTo)(GIESb)(0UHIxzUBKMLye(CUQMy539NLWofacZY1yPdCXIpelxXIZcQailpKfhb8az53jwW3V8)Gflw2PHyXz5NRaIEwOpWYHzzHjqwUIfv6TquXsWXpM72d)blmWucji85CvnPGYtjLUkJkaQaeUErkzpectkewTBOKe7HqyWRQDdLKypecd(9bVguusI9qim43NMR1jj2dHW0wtNmSLj9QOKe1vRzcE(QGzOu)kSsQRwZe88vbd4A8)GvsI9qimJJGk4cNBdvXStsccFoxvtMdNDiXDJ0SeNyILytdMgGUcflwUFNfK3fKedvGf4WI3EAyb5WcbeiILRyb5DbjXqf4U9WFWcdmLqIknyAa6kuk4Ak1RNvbicQ86n1HA)ZnNssSkaHAqOLYeGfciqu(3Pm2(M7XMLDF0QRwZe88vbZqP(v44vwHOvxTMzCeubx4CBOkMDmdL6xH32ArBvaIGkVEdcQ(9otssaIGkVEdcQ(9odA1vRzcE(QGzzJwD1AMXrqfCHZTHQy2XSSr3tD1AMXrqfCHZTHQy2XmuQFfEBLvURviWpRIAWbfzWx1w68Eh8tZ5jjQRwZe88vbZqP(v4Tvw5KeLrQyBsRZ7o(PTv2Oqf2VpAe(CUQMmxLrfa5UrAw2m4ZIL73zXzb5DbjXqfy539NLdxk6zXzzZwASpSypWalWHfl7uXYVtS0ou7plhMfxfUEwEilubYD7H)GfgykHeB4FWsbxtj1vRzcE(QGzOu)kC8kRq09SAwf1GdkYGVQT059o4NMZtsuxTMzCeubx4CBOkMDmdL6xH3wzGBxVfWRUAnJQgcb1l8Bw2OvxTMzCeubx4CBOkMDml7(jjQqmgD7qT)5Hs9RWBVLc5UrAwqURdlT)eMfl70Vtdll8vOyb5WcbeiILcAHflNwZIR1qlS0bUy5HSG)tRzj44NLFNyb7PelEkCvplWglihwiGarad5DbjXqfyj44hZD7H)GfgykHee(CUQMuq5PKsbyHaceLbjCNkOaeUErkfOt3Rx7qT)5Hs9RWDTYkSRdqOgeAPmbpFvWmuQFfUpsv54yJ(kfOt3Rx7qT)5Hs9RWDTYkSRdqOgeAPmbyHaceL)DkJTV5ESbCn(FWQRdqOgeAPmbyHaceL)DkJTV5ESzOu)kCFKQYXXg9rB14hyMqq1BCqqSHq2HFCssac1GqlLj45RcMHs9RWXF1tJnu7pbMBhQ9ppuQFfojzwf1GdkYeinH)Z1zS9n3JrhGqni0szcE(QGzOu)kC8XAJKKaeQbHwktawiGar5FNYy7BUhBgk1Vch)vpn2qT)eyUDO2)8qP(v4Uw5nssSkarqLxVPou7FU5e3nsZsCIjqwEilGK27WYVtSSWokIfyJfK3fKedvGfl7uXYcFfkwaHlvnXcSyzHjw8cKf7Hqq1ZYc7OiwSStflEXIdcYcHGQNLdZIRcxplpKfWJ4U9WFWcdmLqccFoxvtkO8usPayoalW7pyPaeUErk1RDO2)8qP(v44vwHjjJFGzcbvVXbbXMRIxHB0hDVE9ifBD22eOHsT7mKRZWbS8kqO7fGqni0szOu7od56mCalVcKzOu)k82kV5BKKeGiOYR3GGQFVZGoaHAqOLYqP2DgY1z4awEfiZqP(v4TvEZbUaRNYkd8ZQOgCqrg8vTLoV3b)0CE)(OTkaHAqOLYqP2DgY1z4awEfiZqoyN(jjKIToBBc0GHlTM()ku5zP2bDpRcqeu51BQd1(NBoLKeGqni0szWWLwt)FfQ8Su7KJL1QW4ydLndL6xH3wzLT2(jj9cqOgeAPmQ0GPbORqzgYb7KKy14bY8duR7JUxpsXwNTnbAUchM17QAkRylV(vAgKqCbcDVaeQbHwkZv4WSExvtzfB51VsZGeIlqMHCWojjE4pyzUchM17QAkRylV(vAgKqCbYaEyxvtG97NK0JuS1zBtGg8UdcTqGz4OMHT8dNuQE0biudcTuMhoPu9ey(k8HA)ZXsHkmwBPSzOu)kC)KKE9q4Z5QAYaR8ct5FUci6vs5Kee(CUQMmWkVWu(NRaIELIvF09(5kGO3OSzihStoaHAqOLkj5NRaIEJYMaeQbHwkZqP(v44V6PXgQ9NaZTd1(Nhk1Vc31kVr)Kee(CUQMmWkVWu(NRaIEL2cDVFUci6nBzgYb7KdqOgeAPss(5kGO3SLjaHAqOLYmuQFfo(REASHA)jWC7qT)5Hs9RWDTYB0pjbHpNRQjdSYlmL)5kGOxPn63VFssaIGkVEdqDMZR(jjQqmgD7qT)5Hs9RWBRUAntWZxfmGRX)dwC3inlXi85CvnXYctGS8qwajT3HfV6WYpxbe9yw8cKLaiMfl7uXIf)(RqXsdoS4flwZYEhoNZI9adC3E4pyHbMsibHpNRQjfuEkP0VpNwNXebenzl(9kaHRxKswHHlT6vGMFFoToJjciAmu5QAcmjPDO2)8qP(v443AJnssuHym62HA)ZdL6xH3ElfcSEw7gDT6Q1m)(CADgteq0yWVhac43QFsI6Q1m)(CADgteq0yWVhak(yfhDDVzvudoOid(Q2sN37GFAoh4vyFUBKML4etSynP2DgY1SSjpGLxbILT2atbmlQudoeloliVlijgQallmz4U9WFWcdmLqYct57PufuEkPeLA3zixNHdy5vGuW1ukaHAqOLYe88vbZqP(v4T3Ad0biudcTuMaSqabIY)oLX23Cp2muQFfE7T2aDpe(CUQMm)(CADgteq0KT43NKOUAnZVpNwNXebeng87bGIpwBaSEZQOgCqrg8vTLoV3b)0CoWV597JgHpNRQjZvzubWKevigJUDO2)8qP(v4TJfWL7gPzjoXelaGlTM(RqXsm6sTdlBoMcywuPgCiwCwqExqsmubwwyYWD7H)GfgykHKfMY3tPkO8usjmCP10)xHkpl1ok4Ak1laHAqOLYe88vbZqP(v4T3C0wfGiOYR3GGQFVZG2QaebvE9M6qT)5MtjjbicQ86n1HA)ZnNqhGqni0szcWcbeik)7ugBFZ9yZqP(v4T3C09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMHs9RWBV59tscqeu51Bqq1V3zq3ZQzvudoOid(Q2sN37GFAohDac1GqlLj45RcMHs9RWBV5jjQRwZmocQGlCUnufZoMHs9RWBRS1cSEke4jfBD22eO5k8pRWdhCg8qCfLvjTUpA1vRzghbvWfo3gQIzhZYUFsIkeJr3ou7FEOu)k82BPWKesXwNTnbAOu7od56mCalVce6aeQbHwkdLA3zixNHdy5vGmdL6xHJFRn6JgHpNRQjZvzubq0wrk26STjqZv4WSExvtzfB51VsZGeIlqjjbiudcTuMRWHz9UQMYk2YRFLMbjexGmdL6xHJFRnssuHym62HA)ZdL6xH3ERn4UrAw6I2I3bZYctSediLkgZIL73zb5DbjXqf4U9WFWcdmLqccFoxvtkO8usPtXaZbybE)blfGW1lsj1vRzcE(QGzOu)kC8kRq09SAwf1GdkYGVQT059o4NMZtsuxTMzCeubx4CBOkMDmdL6xH3wjL3YSfW6flGxD1AgvnecQx43SS7dSEXrxRqGxD1AgvnecQx43SS7d8KIToBBc0Cf(Nv4HdodEiUIYQKwJwD1AMXrqfCHZTHQy2XSS7NKOcXy0Td1(Nhk1VcV9wkmjHuS1zBtGgk1UZqUodhWYRaHoaHAqOLYqP2DgY1z4awEfiZqP(vyUBp8hSWatjKSWu(EkvbLNskDfomR3v1uwXwE9R0miH4cKcUMsi85CvnzofdmhGf49hSqJWNZv1K5QmQai3nsZsCIjwMd1(ZIk1GdXsaeZD7H)GfgykHKfMY3tPkO8usj8UdcTqGz4OMHT8dNuQEfCnL6fGqni0szcE(QGzihSdARcqeu51BQd1(NBoHgHpNRQjZVpNwNXebenzl(9jjbicQ86n1HA)ZnNqhGqni0szcWcbeik)7ugBFZ9yZqoyh09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMHCWo97Jge(g8QA3qM)caDfk09aHVb)Kw7tUP9Hm)fa6kujjw9UMQ3GFsR9j30(qgQCvnbMKGTjTo)(GIESb)(0UHIpw9r3de(MuiSA3qM)caDfQ(O7HWNZv1K5WzhsjjZQOgCqrgvx7vGYWw2168VFfkCsIJ)X1zBOfAIxPnDJKe1vRzu1qiOEHFZYUp6EbiudcTugvAW0a0vOmd5GDssSA8az(bQ19rBfPyRZ2ManxHdZ6DvnLvSLx)kndsiUaLKqk26STjqZv4WSExvtzfB51VsZGeIlqO7fGqni0szUchM17QAkRylV(vAgKqCbYmuQFfo(yTrssac1GqlLrLgmnaDfkZqP(v44J1g9rBL6Q1mbpFvWSStsuHym62HA)ZdL6xH32A3G7gPzX67hMLdZIZY4)onSqAxfo(tSyX7WYdzj1bIyX1AwGfllmXc(9NLFUci6XS8qwujw0xrGSSSzXY97SG8UGKyOcS4filihwiGarS4fillmXYVtSSvbYcwdFwGflbqwUglQWFNLFUci6XS4dXcSyzHjwWV)S8ZvarpM72d)blmWucjlmLVNsXkaRHpwPFUci6vwbxtPEi85CvnzGvEHP8pxbe9wPKYOT6NRaIEZwMHCWo5aeQbHwQKKEi85CvnzGvEHP8pxbe9kPCsccFoxvtgyLxyk)ZvarVsXQp6EQRwZe88vbZYgDpRcqeu51Bqq1V3zssuxTMzCeubx4CBOkMDmdL6xHbwpfc8ZQOgCqrg8vTLoV3b)0CE)Tv6NRaIEJYg1vRLbxJ)hSqRUAnZ4iOcUW52qvm7yw2jjQRwZmocQGlCUnufZoz8vTLoV3b)0CUzz3pjjaHAqOLYe88vbZqP(vyGTv8)Cfq0Bu2eGqni0szaxJ)hSqBL6Q1mbpFvWSSr3ZQaebvE9M6qT)5MtjjwHWNZv1KjaleqGOmiH7uH(OTkarqLxVbOoZ5vssaIGkVEtDO2)CZj0i85CvnzcWcbeikds4ovaDac1GqlLjaleqGO8VtzS9n3JnlB0wfGqni0szcE(QGzzJUxp1vRzOG(SXuwVkFmdL6xHJx5nssuxTMHc6Zgtzmu7JzOu)kC8kVrF0wnRIAWbfzuDTxbkdBzxRZ)(vOWjj9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhasjfMKOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaKsXr)(jjQRwZa0vGdbMPuBOfAsP6ZurdQlMKzz3pjrfIXOBhQ9ppuQFfE7T2ijbHpNRQjdSYlmL)5kGOxPn6JgHpNRQjZvzubqUBp8hSWatjKSWu(EkfRaSg(yL(5kGOFlfCnL6HWNZv1Kbw5fMY)Cfq0BLsBH2QFUci6nkBgYb7KdqOgeAPssq4Z5QAYaR8ct5FUci6vAl09uxTMj45RcMLn6EwfGiOYR3GGQFVZKKOUAnZ4iOcUW52qvm7ygk1VcdSEke4Nvrn4GIm4RAlDEVd(P58(BR0pxbe9MTmQRwldUg)pyHwD1AMXrqfCHZTHQy2XSStsuxTMzCeubx4CBOkMDY4RAlDEVd(P5CZYUFssac1GqlLj45RcMHs9RWaBR4)5kGO3SLjaHAqOLYaUg)pyH2k1vRzcE(QGzzJUNvbicQ86n1HA)ZnNssScHpNRQjtawiGarzqc3Pc9rBvaIGkVEdqDMZl09SsD1AMGNVkyw2jjwfGiOYR3GGQFVZ0pjjarqLxVPou7FU5eAe(CUQMmbyHaceLbjCNkGoaHAqOLYeGfciqu(3Pm2(M7XMLnARcqOgeAPmbpFvWSSr3RN6Q1muqF2ykRxLpMHs9RWXR8gjjQRwZqb9zJPmgQ9XmuQFfoEL3OpARMvrn4GImQU2RaLHTSR15F)ku4KKEQRwZO6AVcug2YUwN)9RqHZL)RHm43daPKctsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhasP4OF)(jjQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKOcXy0Td1(Nhk1VcV9wBKKGWNZv1Kbw5fMY)Cfq0R0g9rJWNZv1K5QmQai3nsZsCIjmlUwZc83PHfyXYctSCpLIzbwSea5U9WFWcdmLqYct57Pum3nsZsmMchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1H5U9WFWcdmLqYSQSh(dwz9HFfuEkPKdjfG)5cVskRGRPecFoxvtMdNDiXD7H)GfgykHKzvzp8hSY6d)kO8usjvO)ka)ZfELuwbxtPzvudoOiJQR9kqzyl7AD(3Vcf2qk26STjqUBp8hSWatjKmRk7H)GvwF4xbLNskHFUBUBKMfK76Ws7pHzXYo970WYVtSeJhYtd(h2PHf1vRXILtRzP5AnlWwJfl3VFfl)oXsri7zj44N72d)blSXHKsi85CvnPGYtjLahYtZwoTo3CTodBnfGW1lsPEQRwZ8xkzbovgCipv9kqAmdL6xH3gva0K6idyByuojrD1AM)sjlWPYGd5PQxbsJzOu)k82E4pyzWVpTBidHmkSEk)xkbSnmkJUhf0NnMmxL1RYNKekOpBmzWqTp5Iq2NKqb9zJjJxDYfHSVFF0QRwZ8xkzbovgCipv9kqAmlB0ZQOgCqrM)sjlWPYGd5PQxbsd3nsZcYDDyP9NWSyzN(DAybW7dEnOiwomlwGZVZsWX)vOybIGgwa8(0UHy5kwu8v5dlwtqF2yI72d)blSXHeWucji85CvnPGYtjLoufCOm(9bVguKcq46fPKvuqF2yYCvgd1(GUh2M0687dk6Xg87t7gkEfI(DnvVbdx6mSL)Dk3GdHFdvUQMatsW2KwNFFqrp2GFFA3qXdC7ZDJ0SeNyIfKdleqGiwSStfl(ZIMWyw(DVyrHBWsxWBglEbYI(kILLnlwUFNfK3fKedvG72d)blSXHeWucjbyHaceL)DkJTV5EScUMswboRd0uWCaeJUxpe(CUQMmbyHaceLbjCNkG2QaeQbHwktWZxfmd5GDssuxTMj45RcMLDF09uxTMHc6Zgtz9Q8XmuQFfo(npjrD1AgkOpBmLXqTpMHs9RWXV59r3ZQzvudoOiJQR9kqzyl7AD(3VcfojrD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4JvsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXhR(jjQqmgD7qT)5Hs9RWBR8gOTkaHAqOLYe88vbZqoyN(C3inlXjMyztmufZoSy5(DwqExqsmubUBp8hSWghsatjKmocQGlCUnufZok4AkPUAntWZxfmdL6xHJxzfYDJ0SeNyIfaRQDdXYvSy7fiLEbwGflE153Vcfl)U)SOpeeMfLTwmfWS4filAcJzXY97SKchIL3hu0JzXlqw8NLFNyHkqwGnwCwaa1(WI1e0NnMyXFwu2AzbtbmlWHfnHXSmuQF1vOyXXS8qwk4ZYUJ4kuS8qwgQneENfW1Cfkwu8v5dlwtqF2yI72d)blSXHeWucj4v1UHuqOtqt53hu0JvszfCnL6nuBi8URQPKe1vRzOG(SXugd1(ygk1VcVDSqtb9zJjZvzmu7d6Hs9RWBRS1I(DnvVbdx6mSL)Dk3GdHFdvUQMa7J(9bf9M)sP8dZGhfVYwBxJTjTo)(GIEmWgk1VcJUhf0NnMmxL9QtsYqP(v4TrfanPoY6ZDJ0SeNyIfaRQDdXYdzz3rqS4SGsdvDnlpKLfMyjgqkvmM72d)blSXHeWucj4v1UHuW1ucHpNRQjZPyG5aSaV)Gf6aeQbHwkZv4WSExvtzfB51VsZGeIlqMHCWoOjfBD22eO5kCywVRQPSIT86xPzqcXfiUBp8hSWghsatjKGFFAUwRGRPKvVRP6n4N0AFYGZ1EdvUQMar3tD1Ag87tZ1AZqTHW7UQMq3dBtAD(9bf9yd(9P5A92XkjXQzvudoOiZFPKf4uzWH8u1RaPPFsY7AQEdgU0zyl)7uUbhc)gQCvnbIwD1AgkOpBmLXqTpMHs9RWBhl0uqF2yYCvgd1(GwD1Ag87tZ1AZqP(v4TbUOX2KwNFFqrp2GFFAUwhVswBF09SAwf1GdkYO7e8XX5MMO)kuzu6l1gtjj)LsivKQ1QW4vxTMb)(0CT2muQFfgyB1h97dk6n)Ls5hMbpkEfYDJ0SGuC)olaEsR9HLy8CTNLfMybwSeazXYovSmuBi8URQjwuxpl4)0AwS43ZsdoSO4Dc(4ywShyGfVazbewk6zzHjwuPgCiwqEmgBybWFAnllmXIk1GdXcYHfciqel4Rcel)U)Sy50AwShyGfVG)onSa49P5An3Th(dwyJdjGPesWVpnxRvW1u6DnvVb)Kw7tgCU2BOYv1eiA1vRzWVpnxRnd1gcV7QAcDpRMvrn4GIm6obFCCUPj6VcvgL(sTXusYFPesfPATkmERTp63hu0B(lLYpmdEu8XI7gPzbP4(DwIXd5PQxbsdllmXcG3NMR1S8qwaIiBww2S87elQRwJf1oS4AmKLf(kuSa49P5AnlWIffYcMcWceZcCyrtymldL6xDfkUBp8hSWghsatjKGFFAUwRGRP0SkQbhuK5VuYcCQm4qEQ6vG0GgBtAD(9bf9yd(9P5AD8kfl09SsD1AM)sjlWPYGd5PQxbsJzzJwD1Ag87tZ1AZqTHW7UQMss6HWNZv1KbCipnB506CZ16mS1q3tD1Ag87tZ1AZqP(v4TJvsc2M0687dk6Xg87tZ1643c97AQEd(jT2Nm4CT3qLRQjq0QRwZGFFAUwBgk1VcVTc73Vp3nsZcYDDyP9NWSyzN(DAyXzbW7dEnOiwwyIflNwZsWxyIfaVpnxRz5HS0CTMfyRPaw8cKLfMybW7dEnOiwEilarKnlX4H8u1RaPHf87bGyzzZD7H)Gf24qcykHee(CUQMuq5PKs43NMR1zlW6ZnxRZWwtbiC9IuYX)46Sn0cnXhhB019uEdGxD1AM)sjlWPYGd5PQxbsJb)EaO(DDp1vRzWVpnxRndL6xHb(yHuX2KwN3D8taVvVRP6n4N0AFYGZ1EdvUQMa7319cqOgeAPm43NMR1MHs9RWaFSqQyBsRZ7o(jG)DnvVb)Kw7tgCU2BOYv1ey)UUhi8nT10jdBzsVkYmuQFfg4vyF09uxTMb)(0CT2SStscqOgeAPm43NMR1MHs9RW95UrAwItmXcG3h8AqrSy5(DwIXd5PQxbsdlpKfGiYMLLnl)oXI6Q1yXY97W1ZIgIVcflaEFAUwZYY(VuIfVazzHjwa8(GxdkIfyXI1cmwInSlwNf87bGWSSQ)0SyTS8(GIEm3Th(dwyJdjGPesWVp41GIuW1ucHpNRQjd4qEA2YP15MR1zyRHgHpNRQjd(9P5AD2cS(CZ16mS1qBfcFoxvtMdvbhkJFFWRbfLK0tD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4JvsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXhR(OX2KwNFFqrp2GFFAUwVT1IgHpNRQjd(9P5AD2cS(CZ16mS14UrAwItmXc2IpPSGHS87(Zsh4Ifu0ZsQJmww2)LsSO2HLf(kuSCploMfT)eloMfBigFQAIfyXIMWyw(DVyjwSGFpaeMf4Wcsjl8ZILDQyjwaJf87bGWSqiZ(gI72d)blSXHeWucjoOB)hckJT4tQccDcAk)(GIESskRGRPKv)fa6kuOTYd)blJd62)HGYyl(KMb9uhfzUk30hQ9pjbe(gh0T)dbLXw8jnd6PokYGFpa02Xcni8noOB)hckJT4tAg0tDuKzOu)k82XI7gPzjgLAdH3zztccR2nelxJfK3fKedvGLdZYqoyhfWYVtdXIpelAcJz539IffYY7dk6XSCflk(Q8HfRjOpBmXIL73zba83ekGfnHXS87EXIYBWc83PXYHjwUIfV6WI1e0NnMyboSSSz5HSOqwEFqrpMfvQbhIfNffFv(WI1e0NnMmSeJHLIEwgQneENfW1CfkwqkFf4qGSynP2ql0Ks1ZYQ0egZYvSaaQ9HfRjOpBmXD7H)Gf24qcykHKuiSA3qki0jOP87dk6XkPScUMsd1gcV7QAc97dk6n)Ls5hMbpk(E9u2AbwpSnP153hu0Jn43N2neWVfWRUAndf0NnMY6v5Jzz3VpWgk1Vc3hP2tzG9UMQ38wUkNcHf2qLRQjW(O7fGqni0szcE(QGzihSdARaN1bAkyoaIr3dHpNRQjtawiGarzqc3PcjjbiudcTuMaSqabIY)oLX23Cp2mKd2jjXQaebvE9M6qT)5Mt9tsW2KwNFFqrp2GFFA3qB3R3M319uxTMHc6Zgtz9Q8XSSb(T63h47PmWExt1BElxLtHWcBOYv1ey)(OTIc6Zgtgmu7tUiK9jj9OG(SXK5QmgQ9jjPhf0NnMmxLvH)Escf0NnMmxL1RYN(OT6DnvVbdx6mSL)Dk3GdHFdvUQMatsuxTMXEUu4aEUo7tWRlKTxASpgeUErXR0wkCJ(O7HTjTo)(GIESb)(0UH2w5na(EkdS31u9M3Yv5uiSWgQCvnb2VpAh)JRZ2ql0eVc3ORvxTMb)(0CT2muQFfg438(O7zL6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2jjuqF2yYCvgd1(KKyvaIGkVEdqDMZR(OTsD1AMXrqfCHZTHQy2jJVQT059o4NMZnlBUBKML4etSSjGXLfyXsaKfl3Vdxplb32(kuC3E4pyHnoKaMsiPbNaLHTC5)AifCnLC7CyNcaXD7H)Gf24qcykHee(CUQMuq5PKsbWCawG3FWk7qsbiC9IuYkWzDGMcMdGy0i85CvnzcG5aSaV)Gf6E9uxTMb)(0CT2SStsExt1BWpP1(KbNR9gQCvnbMKeGiOYR3uhQ9p3CQp6EwPUAndgQX)fiZYgTvQRwZe88vbZYgDpRExt1BARPtg2YKEvKHkxvtGjjQRwZe88vbd4A8)Gv8biudcTuM2A6KHTmPxfzgk1VcdS4OpAe(CUQMm)(CADgteq0KT43JUNvbicQ86n1HA)ZnNsscqOgeAPmbyHaceL)DkJTV5ESzzJUN6Q1m43NMR1MHs9RWBVvsIvVRP6n4N0AFYGZ1EdvUQMa73h97dk6n)Ls5hMbpkE1vRzcE(QGbCn(FWc43WaC7NKOcXy0Td1(Nhk1VcVT6Q1mbpFvWaUg)py1N7gPzjoXeliVlijgQalWILailRstymlEbYI(kIL7zzzZIL73zb5WcbeiI72d)blSXHeWucjbst4)CD21hQkLQxbxtje(CUQMmbWCawG3FWk7qI72d)blSXHeWucjxf8P8)GLcUMsi85CvnzcG5aSaV)Gv2He3nsZsCIjwSMuBOfAyj2WcKfyXsaKfl3VZcG3NMR1SSSzXlqwWocILgCyzZwASpS4filiVlijgQa3Th(dwyJdjGPesOuBOfAYQWcubxtjvigJ(QNgBO2Fcm3ou7FEOu)k82kRWKKEQRwZypxkCapxN9j41fY2ln2hdcxVOT3sHBKKOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IIxPTu4g9rRUAnd(9P5ATzzJUxac1GqlLj45RcMHs9RWXRWnssaN1bAkyoaI7ZDJ0SeJsTHW7S00(qSalww2S8qwIflVpOOhZIL73HRNfK3fKedvGfv6kuS4QW1ZYdzHqM9nelEbYsbFwGiOj422xHI72d)blSXHeWucj4N0AFYnTpKccDcAk)(GIESskRGRP0qTHW7UQMq)xkLFyg8O4vwHOX2KwNFFqrp2GFFA3qBBTOD7CyNcaHUN6Q1mbpFvWmuQFfoEL3ijXk1vRzcE(QGzz3N7gPzjoXelBcO1WY1y5k8bsS4flwtqF2yIfVazrFfXY9SSSzXY97S4SSzln2hwShyGfVazPlGU9FiiwayXNuUBp8hSWghsatjK0wtNmSLj9QifCnLOG(SXK5QSxDq725WofacT6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lA7Tu4gO7bcFJd62)HGYyl(KMb9uhfz(la0vOssSkarqLxVPOWa1WbmjbBtAD(9bf9443Qp6EQRwZmocQGlCUnufZoMHs9RWBVPDDpfc8ZQOgCqrg8vTLoV3b)0CEF0QRwZmocQGlCUnufZoMLDsIvQRwZmocQGlCUnufZoMLDF09SkaHAqOLYe88vbZYojrD1AMFFoToJjciAm43daTTYkeD7qT)5Hs9RWBV1gBGUDO2)8qP(v44vEJnssScdxA1Ran)(CADgteq0yOYv1eyF09WWLw9kqZVpNwNXebengQCvnbMKeGqni0szcE(QGzOu)kC8XAJ(C3inlXjMyXzbW7tZ1Aw2Kl63zXEGbwwLMWywa8(0CTMLdZIRhYb7WYYMf4Wsh4IfFiwCv46z5HSarqtWTzPl4nJ72d)blSXHeWucj43NMR1k4AkPUAndSOFhNTPjq2)blZYgDp1vRzWVpnxRnd1gcV7QAkjXX)46Sn0cnXVPB0N7gPzjgVsTzPl4nJfvQbhIfKdleqGiwSC)olaEFAUwZIxGS87uXcG3h8AqrC3E4pyHnoKaMsib)(0CTwbxtPaebvE9M6qT)5MtOT6DnvVb)Kw7tgCU2BOYv1ei6Ei85CvnzcWcbeikds4ovijjaHAqOLYe88vbZYojrD1AMGNVkyw29rhGqni0szcWcbeik)7ugBFZ9yZqP(v4TrfanPoYa(aD6Eo(hxNTHwObPQWn6JwD1Ag87tZ1AZqP(v4TTw0wboRd0uWCaeZD7H)Gf24qcykHe87dEnOifCnLcqeu51BQd1(NBoHUhcFoxvtMaSqabIYGeUtfsscqOgeAPmbpFvWSStsuxTMj45RcMLDF0biudcTuMaSqabIY)oLX23Cp2muQFfE7nhT6Q1m43NMR1MLnAkOpBmzUk7vh0wHWNZv1K5qvWHY43h8AqrOTcCwhOPG5aiM7gPzjoXelaEFWRbfXIL73zXlw2Kl63zXEGbwGdlxJLoWLIazbIGMGBZsxWBglwUFNLoW1Wsri7zj443Wsx0yilGRuBw6cEZyXFw(DIfQazb2y53jwIrq1V3zyrD1ASCnwa8(0CTMflWLgSu0ZsZ1AwGTglWHLoWfl(qSalw2IL3hu0J5U9WFWcBCibmLqc(9bVguKcUMsQRwZal63X5GM8jJ4WhSml7KKEwHFFA3qg3oh2PaqOTcHpNRQjZHQGdLXVp41GIss6PUAntWZxfmdL6xH3wHOvxTMj45RcMLDssVEQRwZe88vbZqP(v4TrfanPoYa(aD6Eo(hxNTHwObPgRn6JwD1AMGNVkyw2jjQRwZmocQGlCUnufZoz8vTLoV3b)0CUzOu)k82OcGMuhzaFGoDph)JRZ2ql0GuJ1g9rRUAnZ4iOcUW52qvm7KXx1w68Eh8tZ5MLDF0bicQ86niO637m97JUh2M0687dk6Xg87tZ16TJvsccFoxvtg87tZ16Sfy95MR1zyR1VpARq4Z5QAYCOk4qz87dEnOi09SAwf1GdkY8xkzbovgCipv9kqAssW2KwNFFqrp2GFFAUwVDS6ZDJ0SeNyILnjiSWSCflaGAFyXAc6ZgtS4filyhbXYMyP1SSjbHfln4WcY7csIHkWD7H)Gf24qcykHKISKtHWsbxtPEQRwZqb9zJPmgQ9XmuQFfoEczuy9u(VukjPxy3huewPTqpuy3huu(VuABf2pjjS7dkcRuS6J2TZHDkae3Th(dwyJdjGPes2DDlNcHLcUMs9uxTMHc6Zgtzmu7JzOu)kC8eYOW6P8FPussVWUpOiSsBHEOWUpOO8FP02kSFssy3huewPy1hTBNd7uai09uxTMzCeubx4CBOkMDmdL6xH3wHOvxTMzCeubx4CBOkMDmlB0wnRIAWbfzWx1w68Eh8tZ5jjwPUAnZ4iOcUW52qvm7yw295U9WFWcBCibmLqsBP15uiSuW1uQN6Q1muqF2ykJHAFmdL6xHJNqgfwpL)lLq3laHAqOLYe88vbZqP(v44v4gjjbiudcTuMaSqabIY)oLX23Cp2muQFfoEfUr)KKEHDFqryL2c9qHDFqr5)sPTvy)KKWUpOiSsXQpA3oh2PaqO7PUAnZ4iOcUW52qvm7ygk1VcVTcrRUAnZ4iOcUW52qvm7yw2OTAwf1GdkYGVQT059o4NMZtsSsD1AMXrqfCHZTHQy2XSS7ZDJ0SeNyIfKcO1WcSyb5XyUBp8hSWghsatjKyXN5Gtg2YKEve3nsZcYDDyP9NWSyzN(DAy5HSSWelaEFA3qSCflaGAFyXY(f2z5WS4plkKL3hu0JbMYS0GdlecA6WYwBGuzj1XpnDyboSyTSa49bVguelwtQn0cnPu9SGFpaeM72d)blSXHeWucji85CvnPGYtjLWVpTBO8vzmu7Jcq46fPe2M0687dk6Xg87t7gkERfynneo9sD8ttNmcxViGx5n2aPU1g9bwtdHtp1vRzWVp41GIYuQn0cnPu9zmu7Jb)EaiKQ12N7gPzb5UoS0(tywSSt)onS8qwqkg)3zbCnxHILnXqvm7WD7H)Gf24qcykHee(CUQMuq5PKswg)3ZxLBdvXSJcq46fPKYivSnP15Dh)02B1192WSfW3dBtAD(9bf9yd(9PDd11k3h47PmWExt1BWWLodB5FNYn4q43qLRQjqGxzJc73hyByuwHaV6Q1mJJGk4cNBdvXSJzOu)km3nsZsCIjwqkg)3z5kwaa1(WI1e0NnMyboSCnwkilaEFA3qSy50AwA3ZYvpKfK3fKedvGfV6KchI72d)blSXHeWucjwg)3vW1uQhf0NnMm6v5tUiK9jjuqF2yY4vNCri7rJWNZv1K5W5GMCeuF09EFqrV5Vuk)Wm4rXBTjjuqF2yYOxLp5RYBLK0ou7FEOu)k82kVr)Ke1vRzOG(SXugd1(ygk1VcVTh(dwg87t7gYqiJcRNY)LsOvxTMHc6Zgtzmu7JzzNKqb9zJjZvzmu7dARq4Z5QAYGFFA3q5RYyO2NKe1vRzcE(QGzOu)k82E4pyzWVpTBidHmkSEk)xkH2ke(CUQMmhoh0KJGqRUAntWZxfmdL6xH3MqgfwpL)lLqRUAntWZxfml7Ke1vRzghbvWfo3gQIzhZYgncFoxvtglJ)75RYTHQy2jjXke(CUQMmhoh0KJGqRUAntWZxfmdL6xHJNqgfwpL)lL4UrAwItmXcG3N2nelxJLRyrXxLpSynb9zJjfWYvSaaQ9HfRjOpBmXcSyXAbglVpOOhZcCy5HSypWalaGAFyXAc6ZgtC3E4pyHnoKaMsib)(0UH4UrAw2eUw)7ZI72d)blSXHeWucjZQYE4pyL1h(vq5PKsnxR)9zXDZDJ0SSjgQIzhwSC)oliVlijgQa3Th(dwyJk0FLghbvWfo3gQIzhfCnLuxTMj45RcMHs9RWXRSc5UrAwItmXsxaD7)qqSaWIpPSyzNkw8NfnHXS87EXI1YsSHDX6SGFpaeMfVaz5HSmuBi8ololBR0wSGFpaeloMfT)eloMfBigFQAIf4WYFPel3ZcgYY9S4ZCiimliLSWplE7PHfNLybmwWVhaIfcz23qyUBp8hSWgvO)atjK4GU9FiOm2IpPki0jOP87dk6XkPScUMsQRwZO6AVcug2YUwN)9RqHZL)RHm43daTDCGwD1Agvx7vGYWw2168VFfkC2NGxKb)EaOTJd09Sce(gh0T)dbLXw8jnd6PokY8xaORqH2kp8hSmoOB)hckJT4tAg0tDuK5QCtFO2F09Sce(gh0T)dbLXw8jnVtU28xaORqLKacFJd62)HGYyl(KM3jxBgk1VchFS6NKacFJd62)HGYyl(KMb9uhfzWVhaA7yHge(gh0T)dbLXw8jnd6PokYmuQFfEBfIge(gh0T)dbLXw8jnd6PokY8xaORq1N7gPzjoXelihwiGarSy5(DwqExqsmubwSStfl2qm(u1elEbYc83PXYHjwSC)ololXg2fRZI6Q1yXYovSas4ov4kuC3E4pyHnQq)bMsijaleqGO8VtzS9n3JvW1uYkWzDGMcMdGy096HWNZv1KjaleqGOmiH7ub0wfGqni0szcE(QGzihStsI6Q1mbpFvWSS7JUN6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqkfhjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43daPuC0pjrfIXOBhQ9ppuQFfEBL3Op3nsZYMaAnS4yw(DIL2n4NfubqwUILFNyXzj2WUyDwSCfi0clWHfl3VZYVtSGuUZCEXI6Q1yboSy5(DwCwIdGHPalDb0T)dbXcal(KYIxGSyXVNLgCyb5DbjXqfy5ASCplwG1ZIkXYYMfhLFflQudoel)oXsaKLdZs7QdVtGC3E4pyHnQq)bMsiPTMozylt6vrk4Ak1Rxp1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGIFZtsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhak(nVp6EwfGiOYR3GGQFVZKKyL6Q1mJJGk4cNBdvXSJzz3Vp6EGZ6anfmhaXjjbiudcTuMGNVkygk1VchVc3ijPxaIGkVEtDO2)CZj0biudcTuMaSqabIY)oLX23Cp2muQFfoEfUr)(9ts6bcFJd62)HGYyl(KMb9uhfzgk1VchFCGoaHAqOLYe88vbZqP(v44vEd0bicQ86nffgOgoG9tsU6PXgQ9NaZTd1(Nhk1VcVDCG2QaeQbHwktWZxfmd5GDsscqeu51BaQZCEHwD1AgGUcCiWmLAdTqtkvVzzNKeGiOYR3GGQFVZGwD1AMXrqfCHZTHQy2XmuQFfE7nfT6Q1mJJGk4cNBdvXSJzzZDJ0SGCVcKMfaVpA4aYIL73zXzPilSeByxSolQRwJfVazb5DbjXqfy5WLIEwCv46z5HSOsSSWei3Th(dwyJk0FGPescEfiDwD1AkO8usj87JgoGk4Ak1tD1Agvx7vGYWw2168VFfkCU8FnKzOu)kC8axJctsuxTMr11EfOmSLDTo)7xHcN9j4fzgk1VchpW1OW(O7fGqni0szcE(QGzOu)kC8a3KKEbiudcTugk1gAHMSkSandL6xHJh4I2k1vRza6kWHaZuQn0cnPu9zQOb1ftYSSrhGiOYR3auN58QFF0o(hxNTHwOjELI1gC3inlX4vQnlaEFWRbfHzXY97S4SeByxSolQRwJf11ZsbFwSStfl2qO(kuS0GdliVlijgQalWHfKYxboeilaSV5Em3Th(dwyJk0FGPesWVp41GIuW1uQN6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqXVvsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXVvF09cqeu51BQd1(NBoLKeGqni0szcE(QGzOu)kC8a3KeRq4Z5QAYeaZbybE)bl0wfGiOYR3auN58kjPxac1GqlLHsTHwOjRclqZqP(v44bUOTsD1AgGUcCiWmLAdTqtkvFMkAqDXKmlB0bicQ86na1zoV63hDpRaHVPTMozylt6vrM)caDfQKeRcqOgeAPmbpFvWmKd2jjXQaeQbHwktawiGar5FNYy7BUhBgYb70N7gPzjgVsTzbW7dEnOimlQudoelihwiGarC3E4pyHnQq)bMsib)(GxdksbxtPEbiudcTuMaSqabIY)oLX23Cp2muQFfEBfI2kWzDGMcMdGy09q4Z5QAYeGfciqugKWDQqssac1GqlLj45RcMHs9RWBRW(Or4Z5QAYeaZbybE)bR(OTce(M2A6KHTmPxfz(la0vOqhGiOYR3uhQ9p3CcTvGZ6anfmhaXOPG(SXK5QSxDq74FCD2gAHM4T2n4UrAwIXWsrplGWNfW1Cfkw(DIfQazb2yjg1rqfCHzztmufZokGfW1Cfkwa6kWHazHsTHwOjLQNf4WYvS87elAh)SGkaYcSXIxSynb9zJjUBp8hSWgvO)atjKGWNZv1KckpLuce(5HuS1nukvpwbiC9IuQN6Q1mJJGk4cNBdvXSJzOu)kC8kmjXk1vRzghbvWfo3gQIzhZYUp6EQRwZa0vGdbMPuBOfAsP6ZurdQlMKzOu)k82OcGMuhz9r3tD1AgkOpBmLXqTpMHs9RWXJkaAsDKLKOUAndf0NnMY6v5JzOu)kC8OcGMuhz95U9WFWcBuH(dmLqcEvTBife6e0u(9bf9yLuwbxtPHAdH3DvnH(9bf9M)sP8dZGhfVYBoA3oh2PaqOr4Z5QAYac)8qk26gkLQhZD7H)Gf2Oc9hykHKuiSA3qki0jOP87dk6XkPScUMsd1gcV7QAc97dk6n)Ls5hMbpkELJLrHOD7CyNcaHgHpNRQjdi8ZdPyRBOuQEm3Th(dwyJk0FGPesWpP1(KBAFife6e0u(9bf9yLuwbxtPHAdH3DvnH(9bf9M)sP8dZGhfVYBoWgk1VcJ2TZHDkaeAe(CUQMmGWppKITUHsP6XC3inlBcyCzbwSeazXY97W1ZsWTTVcf3Th(dwyJk0FGPesAWjqzylx(Vgsbxtj3oh2PaqC3inlwtQn0cnSeBybYILDQyXvHRNLhYcvpnS4SuKfwInSlwNflxbcTWIxGSGDeeln4WcY7csIHkWD7H)Gf2Oc9hykHek1gAHMSkSavW1uQhf0NnMm6v5tUiK9jjuqF2yYGHAFYfHSpjHc6ZgtgV6KlczFsI6Q1mQU2RaLHTSR15F)ku4C5)AiZqP(v44bUgfMKOUAnJQR9kqzyl7AD(3Vcfo7tWlYmuQFfoEGRrHjjo(hxNTHwOj(nDd0biudcTuMGNVkygYb7G2kWzDGMcMdG4(O7fGqni0szcE(QGzOu)kC8XAJKKaeQbHwktWZxfmd5GD6NKOcXy0x90yd1(tG52HA)ZdL6xH3w5n4UrAw2eqRHL5qT)SOsn4qSSWxHIfK3fUBp8hSWgvO)atjK0wtNmSLj9QifCnLcqOgeAPmbpFvWmKd2bncFoxvtMayoalW7pyHUNJ)X1zBOfAIFt3aTvbicQ86n1HA)ZnNsscqeu51BQd1(NBoH2X)46Sn0cnBBTB0hTvbicQ86niO637mO7zvaIGkVEtDO2)CZPKKaeQbHwktawiGar5FNYy7BUhBgYb70hTvGZ6anfmhaXC3inliVlijgQalw2PIf)zzt3ayS0f8MXsp4OHwOHLF3lwS2nyPl4nJfl3VZcYHfciquFwSC)oC9SOH4RqXYFPelxXsS1qiOEHFw8cKf9vellBwSC)olihwiGarSCnwUNfloMfqc3Pcei3Th(dwyJk0FGPesq4Z5QAsbLNskfaZbybE)bRSk0FfGW1lsjRaN1bAkyoaIrJWNZv1KjaMdWc8(dwO71ZX)46Sn0cnXVPBGUN6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2jjwfGiOYR3auN58QFsI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWQFsIkeJrF1tJnu7pbMBhQ9ppuQFfEB1vRzcE(QGbCn(FWkjjarqLxVPou7FU5uF09SkarqLxVPou7FU5ussph)JRZ2ql0ST1Ursci8nT10jdBzsVkY8xaORq1hDpe(CUQMmbyHaceLbjCNkKKeGqni0szcWcbeik)7ugBFZ9yZqoyN(95U9WFWcBuH(dmLqsG0e(pxND9HQsP6vW1ucHpNRQjtamhGf49hSYQq)5U9WFWcBuH(dmLqYvbFk)pyPGRPecFoxvtMayoalW7pyLvH(ZDJ0Syn4)s9NWSSdTWs6kSZsxWBgl(qSGYVIazXMgwWuawGC3E4pyHnQq)bMsibHpNRQjfuEkPKJT3mAaqbfGW1lsjkOpBmzUkRxLpaFCGu9WFWYGFFA3qgczuy9u(Vucywrb9zJjZvz9Q8b47T5a7DnvVbdx6mSL)Dk3GdHFdvUQMab(y1hP6H)GLXY4)UHqgfwpL)lLa2gMTqQyBsRZ7o(jUBKMLy8k1MfaVp41GIWSyzNkw(DIL2HA)z5WS4QW1ZYdzHkqfWsBOkMDy5WS4QW1ZYdzHkqfWsh4IfFiw8NLnDdGXsxWBglxXIxSynb9zJjfWcY7csIHkWI2XpMfVG)onSehadtbmlWHLoWflwGlnilqe0eCBwsHdXYV7flCIYBWsxWBglw2PILoWflwGlnyPONfaVp41GIyPGw4U9WFWcBuH(dmLqc(9bVguKcUMs9uHym6REASHA)jWC7qT)5Hs9RWBBTjj9uxTMzCeubx4CBOkMDmdL6xH3gva0K6id4d0P754FCD2gAHgKAS2OpA1vRzghbvWfo3gQIzhZYUF)KKEo(hxNTHwObyi85CvnzCS9Mrdaka8QRwZqb9zJPmgQ9XmuQFfgyGW30wtNmSLj9QiZFbGW5Hs9Ra(TmkmELvEJKeh)JRZ2ql0ame(CUQMmo2EZObafaE1vRzOG(SXuwVkFmdL6xHbgi8nT10jdBzsVkY8xaiCEOu)kGFlJcJxzL3OpAkOpBmzUk7vh09SsD1AMGNVkyw2jjw9UMQ3GFF0Wb0qLRQjW(O71ZQaeQbHwktWZxfml7KKaebvE9gG6mNxOTkaHAqOLYqP2ql0KvHfOzz3pjjarqLxVPou7FU5uF09SkarqLxVbbv)ENjjXk1vRzcE(QGzzNK44FCD2gAHM430n6NK07DnvVb)(OHdOHkxvtGOvxTMj45RcMLn6EQRwZGFF0Wb0GFpa02XkjXX)46Sn0cnXVPB0VFsI6Q1mbpFvWSSrBL6Q1mJJGk4cNBdvXSJzzJ2Q31u9g87JgoGgQCvnbYDJ0SeNyILnjiSWSCflk(Q8HfRjOpBmXIxGSGDeelXi76gW2elTMLnjiSyPbhwqExqsmubUBp8hSWgvO)atjKuKLCkewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sPKKEHDFqryL2c9qHDFqr5)sPTvy)KKWUpOiSsXQpA3oh2PaqC3E4pyHnQq)bMsiz31TCkewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sj09cqOgeAPmbpFvWmuQFfoEfUrssac1GqlLjaleqGO8VtzS9n3JndL6xHJxHB0pjPxy3huewPTqpuy3huu(VuABf2pjjS7dkcRuS6J2TZHDkae3Th(dwyJk0FGPesAlToNcHLcUMs9uxTMHc6Zgtz9Q8XmuQFfoEczuy9u(VucDVaeQbHwktWZxfmdL6xHJxHBKKeGqni0szcWcbeik)7ugBFZ9yZqP(v44v4g9ts6f29bfHvAl0df29bfL)lL2wH9tsc7(GIWkfR(OD7CyNcaXDJ0SGuaTgwGflbqUBp8hSWgvO)atjKyXN5Gtg2YKEve3nsZsCIjwa8(0UHy5HSypWalaGAFyXAc6ZgtSahwSStflxXcS0DyrXxLpSynb9zJjw8cKLfMybPaAnSypWaMLRXYvSO4RYhwSMG(SXe3Th(dwyJk0FGPesWVpTBifCnLOG(SXK5QSEv(KKqb9zJjdgQ9jxeY(KekOpBmz8QtUiK9jjQRwZyXN5Gtg2YKEvKzzJwD1AgkOpBmL1RYhZYojPN6Q1mbpFvWmuQFfEBp8hSmwg)3neYOW6P8FPeA1vRzcE(QGzz3N72d)blSrf6pWucjwg)35U9WFWcBuH(dmLqYSQSh(dwz9HFfuEkPuZ16FFwC3C3inlaEFWRbfXsdoSKcrqPu9SSknHXSSWxHILyd7I15U9WFWcBAUw)7Zsj87dEnOifCnLSAwf1GdkYO6AVcug2YUwN)9RqHnKIToBBcK7gPzb5o(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9gwaSQ2neldL6xHzjDP)ZwFeilpKLu)d7SKcHv7gIfW14)blUBp8hSWMMR1)(SaMsibVQ2nKccDcAk)(GIESskRGRPei8nPqy1UHmdL6xHJFOu)kmWV1wivLJdUBp8hSWMMR1)(SaMsijfcR2ne3n3nsZsCIjwa8(GxdkILhYcqezZYYMLFNyjgpKNQEfinSOUAnwUgl3ZIf4sdYcHm7BiwuPgCiwAxD49RqXYVtSueYEwco(zboS8qwaxP2SOsn4qSGCyHaceXD7H)Gf2GFLWVp41GIuW1uAwf1GdkY8xkzbovgCipv9kqAq3Jc6ZgtMRYE1bTv96PUAnZFPKf4uzWH8u1RaPXmuQFfoEp8hSmwg)3neYOW6P8FPeW2WOm6EuqF2yYCvwf(7jjuqF2yYCvgd1(KKqb9zJjJEv(KlczF)Ke1vRz(lLSaNkdoKNQEfinMHs9RWX7H)GLb)(0UHmeYOW6P8FPeW2WOm6EuqF2yYCvwVkFssOG(SXKbd1(KlczFscf0NnMmE1jxeY((9tsSsD1AM)sjlWPYGd5PQxbsJzz3pjPN6Q1mbpFvWSStsq4Z5QAYeGfciqugKWDQqF0biudcTuMaSqabIY)oLX23Cp2mKd2bDaIGkVEtDO2)CZP(O7zvaIGkVEdqDMZRKKaeQbHwkdLAdTqtwfwGMHs9RWXhh9r3tD1AMGNVkyw2jjwfGqni0szcE(QGzihStFUBKML4etS0fq3(peelaS4tklw2PILFNgILdZsbzXd)HGybBXNufWIJzr7pXIJzXgIXNQMybwSGT4tklwUFNLTyboS0il0Wc(9aqywGdlWIfNLybmwWw8jLfmKLF3Fw(DILISWc2IpPS4ZCiimliLSWplE7PHLF3FwWw8jLfcz23qyUBp8hSWg8dmLqId62)HGYyl(KQGqNGMYVpOOhRKYk4Akzfi8noOB)hckJT4tAg0tDuK5VaqxHcTvE4pyzCq3(peugBXN0mON6OiZv5M(qT)O7zfi8noOB)hckJT4tAENCT5VaqxHkjbe(gh0T)dbLXw8jnVtU2muQFfoEf2pjbe(gh0T)dbLXw8jnd6PokYGFpa02Xcni8noOB)hckJT4tAg0tDuKzOu)k82Xcni8noOB)hckJT4tAg0tDuK5VaqxHI7gPzjoXeMfKdleqGiwUgliVlijgQalhMLLnlWHLoWfl(qSas4ov4kuSG8UGKyOcSy5(DwqoSqabIyXlqw6axS4dXIkPHwyXA3GLUG3mUBp8hSWg8dmLqsawiGar5FNYy7BUhRGRPKvGZ6anfmhaXO71dHpNRQjtawiGarzqc3PcOTkaHAqOLYe88vbZqoyh0wnRIAWbfzSNlfoGNRZ(e86cz7Lg7tsI6Q1mbpFvWSS7J2X)46Sn0cnBRK1Ub6EQRwZqb9zJPSEv(ygk1VchVYBKKOUAndf0NnMYyO2hZqP(v44vEJ(jjQqmgD7qT)5Hs9RWBR8gOTkaHAqOLYe88vbZqoyN(C3inlihwG3FWILgCyX1AwaHpMLF3FwsDGiml41qS87uhw8Hkf9SmuBi8obYILDQyjg1rqfCHzztmufZoSS7yw0egZYV7flkKfmfWSmuQF1vOyboS87ela1zoVyrD1ASCywCv46z5HS0CTMfyRXcCyXRoSynb9zJjwomlUkC9S8qwiKzFdXD7H)Gf2GFGPesq4Z5QAsbLNskbc)8qk26gkLQhRaeUErk1tD1AMXrqfCHZTHQy2XmuQFfoEfMKyL6Q1mJJGk4cNBdvXSJzz3hTvQRwZmocQGlCUnufZoz8vTLoV3b)0CUzzJUN6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzgk1VcVnQaOj1rwF09uxTMHc6Zgtzmu7JzOu)kC8OcGMuhzjjQRwZqb9zJPSEv(ygk1VchpQaOj1rwsspRuxTMHc6Zgtz9Q8XSStsSsD1AgkOpBmLXqTpMLDF0w9UMQ3GHA8FbYqLRQjW(C3inlihwG3FWILF3Fwc7uaimlxJLoWfl(qSaxp(ajwOG(SXelpKfyP7Wci8z53PHyboSCOk4qS87hMfl3VZcaOg)xG4U9WFWcBWpWucji85CvnPGYtjLaHFgUE8bszkOpBmPaeUErk1Zk1vRzOG(SXugd1(yw2OTsD1AgkOpBmL1RYhZYUFsY7AQEdgQX)fidvUQMa5U9WFWcBWpWucjPqy1UHuqOtqt53hu0JvszfCnLgQneE3v1e6EQRwZqb9zJPmgQ9XmuQFfo(Hs9RWjjQRwZqb9zJPSEv(ygk1Vch)qP(v4Kee(CUQMmGWpdxp(aPmf0NnM6JEO2q4DxvtOFFqrV5Vuk)Wm4rXR8wOD7CyNcaHgHpNRQjdi8ZdPyRBOuQEm3Th(dwyd(bMsibVQ2nKccDcAk)(GIESskRGRP0qTHW7UQMq3tD1AgkOpBmLXqTpMHs9RWXpuQFfojrD1AgkOpBmL1RYhZqP(v44hk1VcNKGWNZv1Kbe(z46XhiLPG(SXuF0d1gcV7QAc97dk6n)Ls5hMbpkEL3cTBNd7uai0i85CvnzaHFEifBDdLs1J5U9WFWcBWpWucj4N0AFYnTpKccDcAk)(GIESskRGRP0qTHW7UQMq3tD1AgkOpBmLXqTpMHs9RWXpuQFfojrD1AgkOpBmL1RYhZqP(v44hk1VcNKGWNZv1Kbe(z46XhiLPG(SXuF0d1gcV7QAc97dk6n)Ls5hMbpkEL3C0UDoStbGqJWNZv1Kbe(5HuS1nukvpM7gPzjoXelBcyCzbwSeazXY97W1ZsWTTVcf3Th(dwyd(bMsiPbNaLHTC5)AifCnLC7CyNcaXDJ0SeNyIfKYxboeilaSV5EmlwUFNfV6WIgwOyHk4c1olAh)xHIfRjOpBmXIxGS8thwEil6RiwUNLLnlwUFNLnBPX(WIxGSG8UGKyOcC3E4pyHn4hykHek1gAHMSkSavW1uQxp1vRzOG(SXugd1(ygk1VchVYBKKOUAndf0NnMY6v5JzOu)kC8kVrF0biudcTuMGNVkygk1VchFS2aDp1vRzSNlfoGNRZ(e86cz7Lg7JbHRx02BzTBKKy1SkQbhuKXEUu4aEUo7tWRlKTxASpgsXwNTnb2VFsI6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lkEL2c4Urssac1GqlLj45RcMHCWoOD8pUoBdTqt8B6gC3inlXjMyb5DbjXqfyXY97SGCyHaceHeKYxboeilaSV5EmlEbYciSu0ZcebnwM7jw2SLg7dlWHfl7uXsS1qiOEHFwSaxAqwiKzFdXIk1GdXcY7csIHkWcHm7Bim3Th(dwyd(bMsibHpNRQjfuEkPuamhGf49hSY4xbiC9IuYkWzDGMcMdGy0i85CvnzcG5aSaV)Gf6E9cqOgeAPmuQDNHCDgoGLxbYmuQFfEBL3CGlW6PSYa)SkQbhuKbFvBPZ7DWpnN3hnPyRZ2ManuQDNHCDgoGLxbQFsIJ)X1zBOfAIxPnDd09S6DnvVPTMozylt6vrgQCvnbMKOUAntWZxfmGRX)dwXhGqni0szARPtg2YKEvKzOu)kmWIJ(ObHVbVQ2nKzOu)kC8kVfAq4BsHWQDdzgk1VchFCGUhi8n4N0AFYnTpKzOu)kC8XrsIvVRP6n4N0AFYnTpKHkxvtG9rJWNZv1K53NtRZyIaIMSf)E09uxTMbORahcmtP2ql0Ks1NPIguxmjZYojXQaebvE9gG6mNx9r)(GIEZFPu(HzWJIxD1AMGNVkyaxJ)hSa(nma3KevigJUDO2)8qP(v4TvxTMj45RcgW14)bRKKaebvE9M6qT)5MtjjQRwZOQHqq9c)MLnA1vRzu1qiOEHFZqP(v4TvxTMj45RcgW14)blG1Btb(zvudoOiJ9CPWb8CD2NGxxiBV0yFmKIToBBcSFF0wPUAntWZxfmlB09SkarqLxVPou7FU5ussac1GqlLjaleqGO8VtzS9n3Jnl7KevigJUDO2)8qP(v4TdqOgeAPmbyHaceL)DkJTV5ESzOu)kmW28KK2HA)ZdL6xHrQivLJJn2wD1AMGNVkyaxJ)hS6ZD7H)Gf2GFGPesq4Z5QAsbLNskfaZbybE)bRm(vacxViLScCwhOPG5aigncFoxvtMayoalW7pyHUxVaeQbHwkdLA3zixNHdy5vGmdL6xH3w5nh4cSEkRmWpRIAWbfzWx1w68Eh8tZ59rtk26STjqdLA3zixNHdy5vG6NK44FCD2gAHM4vAt3aDpRExt1BARPtg2YKEvKHkxvtGjjQRwZe88vbd4A8)Gv8biudcTuM2A6KHTmPxfzgk1VcdS4OpAq4BWRQDdzgk1VchFCGge(MuiSA3qMHs9RWXVPO7bcFd(jT2NCt7dzgk1VchVYBKKy17AQEd(jT2NCt7dzOYv1eyF0i85Cvnz(9506mMiGOjBXVhDp1vRza6kWHaZuQn0cnPu9zQOb1ftYSStsSkarqLxVbOoZ5vF0VpOO38xkLFyg8O4vxTMj45RcgW14)blGFddWnjrfIXOBhQ9ppuQFfEB1vRzcE(QGbCn(FWkjjarqLxVPou7FU5usI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWcy92uGFwf1GdkYypxkCapxN9j41fY2ln2hdPyRZ2Ma73hTvQRwZe88vbZYgDpRcqeu51BQd1(NBoLKeGqni0szcWcbeik)7ugBFZ9yZYojrfIXOBhQ9ppuQFfE7aeQbHwktawiGar5FNYy7BUhBgk1VcdSnpjrfIXOBhQ9ppuQFfgPIuvoo2yB1vRzcE(QGbCn(FWQp3nsZsCIjw(DILyeu97DgwSC)ololiVlijgQal)U)SC4srplTbMYYMT0yF4U9WFWcBWpWucjJJGk4cNBdvXSJcUMsQRwZe88vbZqP(v44vwHjjQRwZe88vbd4A8)G12XAl0i85CvnzcG5aSaV)Gvg)C3E4pyHn4hykHKaPj8FUo76dvLs1RGRPecFoxvtMayoalW7pyLXp6EQRwZe88vbd4A8)Gv8kfRTssSkarqLxVbbv)ENPFsI6Q1mJJGk4cNBdvXSJzzJwD1AMXrqfCHZTHQy2XmuQFfE7nfybybUU3ypu4Wu21hQkLQ38xkLr46fbSEwPUAnJQgcb1l8Bw2OT6DnvVb)(OHdOHkxvtG95U9WFWcBWpWucjxf8P8)GLcUMsi85CvnzcG5aSaV)Gvg)C3inlXi85CvnXYctGSalwC1tF)ryw(D)zXIxplpKfvIfSJGazPbhwqExqsmubwWqw(D)z53PoS4dvplwC8tGSGuYc)SOsn4qS87uk3Th(dwyd(bMsibHpNRQjfuEkPe2rq5gCYbpFvqbiC9IuYQaeQbHwktWZxfmd5GDssScHpNRQjtawiGarzqc3PcOdqeu51BQd1(NBoLKaoRd0uWCaeZDJ0SeNycZYMaAnSCnwUIfVyXAc6ZgtS4fil)CeMLhYI(kIL7zzzZIL73zzZwASpkGfK3fKedvGfVazPlGU9FiiwayXNuUBp8hSWg8dmLqsBnDYWwM0RIuW1uIc6ZgtMRYE1bTBNd7uai0QRwZypxkCapxN9j41fY2ln2hdcxVOT3YA3aDpq4BCq3(peugBXN0mON6OiZFbGUcvsIvbicQ86nffgOgoG9rJWNZv1Kb7iOCdo5GNVkGUN6Q1mJJGk4cNBdvXSJzOu)k82BAx3tHa)SkQbhuKbFvBPZ7DWpnNdmRifBD22eO5k8pRWdhCg8qCfLvjTUpA1vRzghbvWfo3gQIzhZYojXk1vRzghbvWfo3gQIzhZYUp3nsZsCIjw2Kl63zbW7tZ1AwShyaZY1ybW7tZ1AwoCPONLLn3Th(dwyd(bMsib)(0CTwbxtj1vRzGf974SnnbY(pyzw2OvxTMb)(0CT2muBi8URQjUBp8hSWg8dmLqsWRaPZQRwtbLNskHFF0Wbubxtj1vRzWVpA4aAgk1VcVTcr3tD1AgkOpBmLXqTpMHs9RWXRWKe1vRzOG(SXuwVkFmdL6xHJxH9r74FCD2gAHM430n4UrAwIXRuBmlDbVzSOsn4qSGCyHaceXYcFfkw(DIfKdleqGiwcWc8(dwS8qwc7uaiwUglihwiGarSCyw8WVCTUdlUkC9S8qwujwco(5U9WFWcBWpWucj43h8Aqrk4AkfGiOYR3uhQ9p3CcncFoxvtMaSqabIYGeUtfqhGqni0szcWcbeik)7ugBFZ9yZqP(v4TviARaN1bAkyoaIrtb9zJjZvzV6G2X)46Sn0cnXBTBWDJ0SeNyIfaVpnxRzXY97Sa4jT2hwIXZ1Ew8cKLcYcG3hnCavalw2PILcYcG3NMR1SCyww2kGLoWfl(qSCflk(Q8HfRjOpBmXsdoSehadtbmlWHLhYI9adSSzln2hwSStflUkebXYMUblDbVzSahwCqB)peelyl(KYYUJzjoagMcywgk1V6kuSahwomlxXstFO2FdlXf(el)U)SSkqAy53jwWEkXsawG3FWcZY9kcZcOnMLIw)4AwEilaEFAUwZc4AUcflXOocQGlmlBIHQy2rbSyzNkw6axkcKf8FAnlubYYYMfl3VZYMUbWCSnln4WYVtSOD8Zcknu11yd3Th(dwyd(bMsib)(0CTwbxtP31u9g8tATpzW5AVHkxvtGOT6DnvVb)(OHdOHkxvtGOvxTMb)(0CT2muBi8URQj09uxTMHc6Zgtz9Q8XmuQFfo(4anf0NnMmxL1RYh0QRwZypxkCapxN9j41fY2ln2hdcxVOT3sHBKKOUAnJ9CPWb8CD2NGxxiBV0yFmiC9IIxPTu4gOD8pUoBdTqt8B6gjjGW34GU9FiOm2IpPzqp1rrMHs9RWXhhjjE4pyzCq3(peugBXN0mON6OiZv5M(qT)9rhGqni0szcE(QGzOu)kC8kVb3nsZsCIjwa8(GxdkILn5I(DwShyaZIxGSaUsTzPl4nJfl7uXcY7csIHkWcCy53jwIrq1V3zyrD1ASCywCv46z5HS0CTMfyRXcCyPdCPiqwcUnlDbVzC3E4pyHn4hykHe87dEnOifCnLuxTMbw0VJZbn5tgXHpyzw2jjQRwZa0vGdbMPuBOfAsP6ZurdQlMKzzNKOUAntWZxfmlB09uxTMzCeubx4CBOkMDmdL6xH3gva0K6id4d0P754FCD2gAHgKAS2OpWIfW)UMQ3uKLCkewgQCvnbI2QzvudoOid(Q2sN37GFAohT6Q1mJJGk4cNBdvXSJzzNKOUAntWZxfmdL6xH3gva0K6id4d0P754FCD2gAHgKAS2OFsI6Q1mJJGk4cNBdvXStgFvBPZ7DWpnNBw2jj9uxTMzCeubx4CBOkMDmdL6xH32d)bld(9PDdziKrH1t5)sj0yBsRZ7o(PT3WyTjjQRwZmocQGlCUnufZoMHs9RWB7H)GLXY4)UHqgfwpL)lLssq4Z5QAYCkgyoalW7pyHoaHAqOLYCfomR3v1uwXwE9R0miH4cKzihSdAsXwNTnbAUchM17QAkRylV(vAgKqCbQpA1vRzghbvWfo3gQIzhZYojXk1vRzghbvWfo3gQIzhZYgTvbiudcTuMXrqfCHZTHQy2XmKd2jjXQaebvE9geu97DM(jjo(hxNTHwOj(nDd0uqF2yYCv2RoC3inlwF6WYdzj1bIy53jwuj8ZcSXcG3hnCazrTdl43daDfkwUNLLnlk26caP7WYvS4vhwSMG(SXelQRNLnBPX(WYHRNfxfUEwEilQel2dmeiqUBp8hSWg8dmLqc(9bVguKcUMsVRP6n43hnCanu5QAceTvZQOgCqrM)sjlWPYGd5PQxbsd6EQRwZGFF0Wb0SStsC8pUoBdTqt8B6g9rRUAnd(9rdhqd(9aqBhl09uxTMHc6Zgtzmu7JzzNKOUAndf0NnMY6v5Jzz3hT6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lA7TaUBGUxac1GqlLj45RcMHs9RWXR8gjjwHWNZv1KjaleqGOmiH7ub0bicQ86n1HA)ZnN6ZDJ0Syn4)s9NWSSdTWs6kSZsxWBgl(qSGYVIazXMgwWuawGC3E4pyHn4hykHee(CUQMuq5PKso2EZObafuacxViLOG(SXK5QSEv(a8Xbs1d)bld(9PDdziKrH1t5)sjGzff0NnMmxL1RYhGV3MdS31u9gmCPZWw(3PCdoe(nu5QAce4JvFKQh(dwglJ)7gczuy9u(VucyBySwfIuX2KwN3D8taBdJcb(31u9MY)1q4SQR9kqgQCvnbYDJ0SeJxP2Sa49bVguelxXIZcWfyykWcaO2hwSMG(SXKcybewk6zrtpl3ZI9adSSzln2hw697(ZYHzz3lqnbYIAhwO73PHLFNybW7tZ1Aw0xrSahw(DILUG3S430nyrFfXsdoSa49bVguuFfWciSu0ZcebnwM7jw8ILn5I(DwShyGfVazrtpl)oXIRcrqSOVIyz3lqnXcG3hnCa5U9WFWcBWpWucj43h8Aqrk4Akz1SkQbhuK5VuYcCQm4qEQ6vG0GUN6Q1m2ZLchWZ1zFcEDHS9sJ9XGW1lA7TaUBKKOUAnJ9CPWb8CD2NGxxiBV0yFmiC9I2ElfUb631u9g8tATpzW5AVHkxvtG9r3Jc6ZgtMRYyO2h0o(hxNTHwObyi85CvnzCS9Mrdaka8QRwZqb9zJPmgQ9XmuQFfgyGW30wtNmSLj9QiZFbGW5Hs9Ra(Tmkm(4yJKekOpBmzUkRxLpOD8pUoBdTqdWq4Z5QAY4y7nJgaua4vxTMHc6Zgtz9Q8XmuQFfgyGW30wtNmSLj9QiZFbGW5Hs9Ra(Tmkm(nDJ(OTsD1Agyr)ooBttGS)dwMLnARExt1BWVpA4aAOYv1ei6EbiudcTuMGNVkygk1VchpWnjbdxA1Ran)(CADgteq0yOYv1eiA1vRz(9506mMiGOXGFpa02XkwDDVzvudoOid(Q2sN37GFAoh4vyF0Td1(Nhk1VchVYBSb62HA)ZdL6xH3ERn2ijbCwhOPG5aiUp6EbiudcTugGUcCiWm2(M7XMHs9RWXdCtsSkarqLxVbOoZ5vFUBKML4etSSjbHfMLRyrXxLpSynb9zJjw8cKfSJGyjgzx3a2MyP1SSjbHfln4WcY7csIHkWIxGSGu(kWHazXAsTHwOjLQN72d)blSb)atjKuKLCkewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sPKKEHDFqryL2c9qHDFqr5)sPTvy)KKWUpOiSsXQpA3oh2PaqOr4Z5QAYGDeuUbNCWZxf4U9WFWcBWpWucj7UULtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkH2QaebvE9gG6mNxjj9uxTMbORahcmtP2ql0Ks1NPIguxmjZYgDaIGkVEdqDMZR(jj9c7(GIWkTf6Hc7(GIY)LsBRW(jjHDFqryLIvsI6Q1mbpFvWSS7J2TZHDkaeAe(CUQMmyhbLBWjh88vb09uxTMzCeubx4CBOkMDmdL6xH3UNc76Ta(zvudoOid(Q2sN37GFAoVpA1vRzghbvWfo3gQIzhZYojXk1vRzghbvWfo3gQIzhZYUp3Th(dwyd(bMsiPT06Ckewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sj0wfGiOYR3auN58kjPN6Q1maDf4qGzk1gAHMuQ(mv0G6Ijzw2Odqeu51BaQZCE1pjPxy3huewPTqpuy3huu(VuABf2pjjS7dkcRuSssuxTMj45RcMLDF0UDoStbGqJWNZv1Kb7iOCdo5GNVkGUN6Q1mJJGk4cNBdvXSJzOu)k82keT6Q1mJJGk4cNBdvXSJzzJ2QzvudoOid(Q2sN37GFAopjXk1vRzghbvWfo3gQIzhZYUp3nsZsCIjwqkGwdlWILai3Th(dwyd(bMsiXIpZbNmSLj9QiUBKML4etSa49PDdXYdzXEGbwaa1(WI1e0NnMualiVlijgQal7oMfnHXS8xkXYV7flolifJ)7SqiJcRNyrtTNf4WcS0DyrXxLpSynb9zJjwomllBUBp8hSWg8dmLqc(9PDdPGRPef0NnMmxL1RYh0wPUAnZ4iOcUW52qvm7yw2jjuqF2yYGHAFYfHSpjHc6ZgtgV6KlczFssp1vRzS4ZCWjdBzsVkYSStsW2KwN3D8tBVHXAviARcqeu51Bqq1V3zssW2KwN3D8tBVHXArhGiOYR3GGQFVZ0hT6Q1muqF2ykRxLpMLDssp1vRzcE(QGzOu)k82E4pyzSm(VBiKrH1t5)sj0QRwZe88vbZYUp3nsZsCIjwqkg)3zb(70y5Welw2VWolhMLRybau7dlwtqF2ysbSG8UGKyOcSahwEil2dmWIIVkFyXAc6ZgtC3E4pyHn4hykHelJ)7C3inlBcxR)9zXD7H)Gf2GFGPesMvL9WFWkRp8RGYtjLAUw)7Zk6J(Oi]] )
    

end