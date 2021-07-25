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


    spec:RegisterPack( "Balance", 20210725, [[di1XPfqikPEeePUeejTjs4tqQmkPKtjLAvaQ6vakZcsPBbazxu8liIHjICmsulda9mHkMgKQCnikBdqfFdGuJdGW5GiX6aizEau3JezFcv9pHcv0bfQ0cfk6HqkMOqHCriv1gbGYhbuP0ifkuPtsjrRue1lbuPAMus4MaqLDkuQFcavnuaIoQqHkSuHcLNQuMkLKUkaWwfku1xbujJfa0EPu)vudM4WuTys6XcMmqxgzZs1NHKrRuDAvwnGkfVgqMnPUTiTBj)g0WfYXfky5kEoutxvxxjBhcFNsmEiQoViSEHsMVuSFuBRSTvT3a9NSJnatcGkNeGgGiZOCsauzLrM92NiIS3I8aqokYER8uYElMU2RazVf5j0qh02Q2By4AcK92()ryafsqIQR9kqai8LgmOUFFPAoisIPR9kqaOTlfnijf0S)P6yC2pnPKQR9kqMh5V9M660Vvw2Q2BG(t2XgGjbqLtcqdqKzuojaQCsXXEZx)oCS32Uu0yVTFGGuzRAVbs4G9wmDTxbILy0Soqo5Kx6eSaqKHwwaysauzozoz0S7fkcdO4KbqSexqqcKLnO2hwIj5PgozaelOz3lueilVpOOpFDwcoMWS8qwcjcAk)(GIESHtgaXsmgLcrqGSSQIceg7tcwq4Z5QAcZsRZqg0Ys0qiY43h8AqrSaGINLOHqyWVp41GIAB4KbqSexeWdKLOHco(VcflaxJ)7SCDwUhDyw(DIfldSqXc6h0xeMmCYaiwaW5arSGgyHaceXYVtSSfDZ9ywCw03)AILu4qS01eYpvnXsRRZsc4ILDhSq3ZY(9SCpl4lDPFVi4cRtWIL73zjMa4JRvzbySGgst4)CnlXvFOQuQE0YY9OdKfmqxuBdNmaIfaCoqelPq8Zc66hQ9ppuQFfgDSGdu5ZbXS4rr6eS8qwuHyml9d1(Jzbw6egozaelwDi)zXQWuIfyNLyQ9DwIP23zjMAFNfhZIZcoIcNRz5NRaIEdNmaIfa8rurdlTodzqllaxJ)7OLfGRX)D0YY27t)gQnlPoiXskCiwgcF6JQNLhYc5J(OHLamv1Fae(95n2B6d)yBRAVbJOIgBRAhBLTTQ9gvUQMaTJP9Mh(dw2Bwg)3T3ajCyUO)GL9gGCOGJFwailaxJ)7S4filolBVp41GIybwSSzvwSC)olX(qT)SaG5elEbYsmHX1QSahw2EF63qSa)DASCyYElm3tZ52BTyHc6lctg9Q8jxeYFwAAyHc6lctMRYyO2hwAAyHc6lctMRYQWFNLMgwOG(IWKXRe5Iq(ZsBwuWs0qimkBSm(VZIcwSMLOHqyaOXY4)U9BhBaABv7nQCvnbAht7np8hSS3WVp9Bi7TWCpnNBVznlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGS00WI1SeGiOYR3uhQ9p3DILMgwSMfCeP153hu0Jn43NUR1SOelkZstdlwZY7AQEt5)AiCw11EfidvUQMazPPHLwSqb9fHjdgQ9jxeYFwAAyHc6lctMRY6v5dlnnSqb9fHjZvzv4VZstdluqFryY4vICri)zPT9M(kkhaT3qM9Bh74yBv7nQCvnbAht7np8hSS3WVp41GIS3cZ90CU92SkQdhuKr11EfOmSNDTo)7xHcBOYv1eilkyjarqLxVPou7FU7elkybhrAD(9bf9yd(9P7AnlkXIY2B6ROCa0Edz2V9BVbsDFPFBRAhBLTTQ9Mh(dw2ByO2NSk5P2Bu5QAc0oM2VDSbOTvT3OYv1eODmT3cZ90CU92FPelaMLwSaqwaEw8WFWYyz8F3eC8N)lLybyS4H)GLb)(0VHmbh)5)sjwABV5H)GL9wW16Sh(dwz9HF7n9H)C5PK9gmIkASF7yhhBRAVrLRQjq7yAVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3WrKwNFFqrp2GFF6UwZs8SOmlkyPflwZY7AQEd(9rdhqdvUQMazPPHL31u9g8tATpzW56VHkxvtGS0MLMgwWrKwNFFqrp2GFF6UwZs8Saq7nqchMl6pyzVTrpML4crFwGflXbySy5(D46zbCU(ZIxGSy5(Dw2EF0WbKfVazbGaJf4VtJLdt2Bi8jxEkzVD4Sdj73o2ONTvT3OYv1eODmT3Gr2By6T38WFWYEdHpNRQj7neUEr2B4isRZVpOOhBWVp9BiwINfLT3ajCyUO)GL92g9ywcAYrqSyzNkw2EF63qSe8IL97zbGaJL3hu0JzXY(f2z5WSmKMq41ZshoS87elOFqFryILhYIkXs0qDAgcKfVazXY(f2zPFAnnS8qwco(T3q4tU8uYE7W5GMCeK9BhBKzBv7nQCvnbAht7np8hSS3uPbtdqxHYEdKWH5I(dw2BaamXsmPbtdqxHIfl3VZcAIlsSYkWcCyX7pnSGgyHaceXYvSGM4IeRSc2BH5EAo3ERflTyXAwcqeu51BQd1(N7oXstdlwZsac1GqlLjaleqGO8VtzC0n3JnRiwAZIcwux9Uj45RcMHs9RWSeplkJmwuWI6Q3nJJGk4cN7dvXkHzOu)kmlaMf0JffSynlbicQ86niO63tmS00WsaIGkVEdcQ(9edlkyrD17MGNVkywrSOGf1vVBghbvWfo3hQIvcZkIffS0If1vVBghbvWfo3hQIvcZqP(vywamlkRmlaiwqglaplZQOoCqrg8v9LoVNa)0CUHkxvtGS00WI6Q3nbpFvWmuQFfMfaZIYkZstdlkZcsybhrADE3XpXcGzrzdYqglTzPnlkybva0muQFfML4zjj73o2ahBRAVrLRQjq7yAVfM7P5C7n1vVBcE(QGzOu)kmlXZIYiJffS0IfRzzwf1HdkYGVQV059e4NMZnu5QAcKLMgwux9UzCeubx4CFOkwjmdL6xHzbWSOmGMfaelaKfGNf1vVBu1qiOEHFZkIffSOU6DZ4iOcUW5(qvSsywrS0MLMgwuHymlkyPFO2)8qP(vywamlaez2BGeomx0FWYEdqcFwSC)ololOjUiXkRal)U)SC4cDplolaYLg7dlrdmWcCyXYovS87el9d1(ZYHzXvHRNLhYcvG2BE4pyzVfb)dw2VDSb02w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVfOtZslwAXs)qT)5Hs9RWSaGyrzKXcaILaeQbHwktWZxfmdL6xHzPnliHfLbejXsBwuILaDAwAXslw6hQ9ppuQFfMfaelkJmwaqSeGqni0szcWcbeik)7ughDZ9yd4A8)GflaiwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlTzbjSOmGijwAZIcwSMLXpWmHGQ34GGydH8d)ywAAyjaHAqOLYe88vbZqP(vywINLREAIGA)jWC)qT)5Hs9RWS00Wsac1GqlLjaleqGO8VtzC0n3JndL6xHzjEwU6PjcQ9NaZ9d1(Nhk1VcZcaIfLtILMgwSMLaebvE9M6qT)5Ut2BGeomx0FWYEdnUoS0(tywSSt)onSSWxHIf0aleqGiwkOfwSCAnlUwdTWsc4ILhYc(pTMLGJFw(DIfSNsS4PWv9Sa7SGgyHacebm0exKyLvGLGJFS9gcFYLNs2BbyHaceLbjCIky)2XgqyBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9wlw6hQ9ppuQFfML4zrzKXstdlJFGzcbvVXbbXMRyjEwqwsS0MffS0ILwS0IfkgwxuebAO0Oed56mCalVcelkyPflbiudcTugknkXqUodhWYRazgk1VcZcGzrzGtsS00WsaIGkVEdcQ(9edlkyjaHAqOLYqPrjgY1z4awEfiZqP(vywamlkdCa0SamwAXIYkZcWZYSkQdhuKbFvFPZ7jWpnNBOYv1eilTzPnlkyXAwcqOgeAPmuAuIHCDgoGLxbYmKdMGL2S00WcfdRlkIany4sRP)VcvEwQjyrblTyXAwcqeu51BQd1(N7oXstdlbiudcTugmCP10)xHkpl1e54GEidqKKYMHs9RWSaywuwz0JL2S00WslwcqOgeAPmQ0GPbORqzgYbtWstdlwZY4bY8duRzPnlkyPflTyHIH1ffrGMRWHz9UQMYXWYRFLMbjexGyrblbiudcTuMRWHz9UQMYXWYRFLMbjexGmd5GjyPnlnnS0IfkgwxuebAW7oi0cbMHJAg2ZpCsP6zrblbiudcTuMhoPu9ey(k8HA)ZXbziloauzZqP(vywAZstdlTyPfli85CvnzGvEHP8pxbe9SOelkZstdli85CvnzGvEHP8pxbe9SOelXHL2SOGLwS8ZvarV5v2mKdMihGqni0sXstdl)Cfq0BELnbiudcTuMHs9RWSeplx90eb1(tG5(HA)ZdL6xHzbaXIYjXsBwAAybHpNRQjdSYlmL)5kGONfLybGSOGLwS8ZvarV5bOzihmroaHAqOLILMgw(5kGO38a0eGqni0szgk1VcZs8SC1tteu7pbM7hQ9ppuQFfMfaelkNelTzPPHfe(CUQMmWkVWu(NRaIEwuILKyPnlTzPnlnnSeGiOYR3auI58IL2S00WIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSS3ajCyUO)GL9gaatGS8qwajTNGLFNyzHDuelWolOjUiXkRalw2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyzNkw8IfheKfcbvplhMfxfUEwEilGhzVHWNC5PK9wamhGf49hSSF7yJuSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZAwWWLw9kqZVpNwNXebengQCvnbYstdl9d1(Nhk1VcZs8SaWKsILMgwuHymlkyPFO2)8qP(vywamlaezSamwAXc6Lelaiwux9U53NtRZyIaIgd(9aqSa8SaqwAZstdlQRE387ZP1zmrarJb)EaiwINL4aiybaXslwMvrD4GIm4R6lDEpb(P5CdvUQMazb4zbzS02EdKWH5I(dw2BX495CvnXYctGS8qwajTNGfVsWYpxbe9yw8cKLaiMfl7uXIf)(RqXshoS4flO)kAhoNZs0ad2Bi8jxEkzV97ZP1zmrart2IFV9BhBLtY2Q2Bu5QAc0oM2BGeomx0FWYEdaGjwq)0Oed5AwaWpGLxbIfaMeMcywuPoCiwCwqtCrIvwbwwyYyVvEkzVrPrjgY1z4awEfi7TWCpnNBVfGqni0szcE(QGzOu)kmlaMfaMelkyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywaysSOGLwSGWNZv1K53NtRZyIaIMSf)EwAAyrD17MFFoToJjciAm43daXs8SeNKybyS0ILzvuhoOid(Q(sN3tGFAo3qLRQjqwaEwaoS0ML2SOGfubqZqP(vywINLKyPPHfvigZIcw6hQ9ppuQFfMfaZsCa02BE4pyzVrPrjgY1z4awEfi73o2kRSTvT3OYv1eODmT3ajCyUO)GL9gaatSSbxAn9xHILySLAcwaoykGzrL6WHyXzbnXfjwzfyzHjJ9w5PK9ggU0A6)RqLNLAc7TWCpnNBV1ILaeQbHwktWZxfmdL6xHzbWSaCyrblwZsaIGkVEdcQ(9edlkyXAwcqeu51BQd1(N7oXstdlbicQ86n1HA)ZDNyrblbiudcTuMaSqabIY)oLXr3Cp2muQFfMfaZcWHffS0Ife(CUQMmbyHaceLbjCIkWstdlbiudcTuMGNVkygk1VcZcGzb4WsBwAAyjarqLxVbbv)EIHffS0IfRzzwf1HdkYGVQV059e4NMZnu5QAcKffSeGqni0szcE(QGzOu)kmlaMfGdlnnSOU6DZ4iOcUW5(qvSsygk1VcZcGzrz0JfGXslwqglaplumSUOic0Cf(Nv4HdodEiUIYQKwZsBwuWI6Q3nJJGk4cN7dvXkHzfXsBwAAyrfIXSOGL(HA)ZdL6xHzbWSaqKXstdlumSUOic0qPrjgY1z4awEfiwuWsac1GqlLHsJsmKRZWbS8kqMHs9RWSeplXjjwAZIcwqfandL6xHzjEwsYEZd)bl7nmCP10)xHkpl1e2VDSvgG2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVPU6DtWZxfmdL6xHzjEwugzSOGLwSynlZQOoCqrg8v9LoVNa)0CUHkxvtGS00WI6Q3nJJGk4cN7dvXkHzOu)kmlawjwugGSamwAXsCyb4zrD17gvnecQx43SIyPnlaJLwS0IfablaiwqglaplQRE3OQHqq9c)MvelTzb4zHIH1ffrGMRW)ScpCWzWdXvuwL0AwAZIcwux9UzCeubx4CFOkwjmRiwAZstdlQqmMffS0pu7FEOu)kmlaMfaImwAAyHIH1ffrGgknkXqUodhWYRaXIcwcqOgeAPmuAuIHCDgoGLxbYmuQFf2EdKWH5I(dw2BXvBXtGzzHjwSYyCeJyXY97SGM4IeRSc2Bi8jxEkzVDXayoalW7pyz)2Xw54yBv7nQCvnbAht7np8hSS3UchM17QAkhdlV(vAgKqCbYElm3tZ52Bi85CvnzUyamhGf49hSyrblOcGMHs9RWSepljzVvEkzVDfomR3v1uogwE9R0miH4cK9BhBLrpBRAVrLRQjq7yAVbs4WCr)bl7naaMyzou7plQuhoelbqS9w5PK9gE3bHwiWmCuZWE(HtkvV9wyUNMZT3AXsac1GqlLj45RcMHCWeSOGfRzjarqLxVPou7FU7elkybHpNRQjZVpNwNXebenzl(9S00WsaIGkVEtDO2)C3jwuWsac1GqlLjaleqGO8VtzC0n3Jnd5GjyrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMHCWeS0ML2SOGfq4BWRQFdz(la0vOyrblTybe(g8tATp5U2hY8xaORqXstdlwZY7AQEd(jT2NCx7dzOYv1eilnnSGJiTo)(GIESb)(0VHyjEwIdlTzrblTybe(MuiS63qM)caDfkwAZIcwAXccFoxvtMdNDiXstdlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGS00WIJ)X15iOfAyjELybPKelnnSOU6DJQgcb1l8BwrS0MffS0ILaeQbHwkJknyAa6kuMHCWeS00WI1SmEGm)a1AwAZstdlQqmMffS0pu7FEOu)kmlaMf0lj7np8hSS3W7oi0cbMHJAg2ZpCsP6TF7yRmYSTQ9gvUQMaTJP9giHdZf9hSS3S6(Hz5WS4Sm(VtdlK2vHJ)elw8eS8qwsDGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSC)olOjUiXkRalEbYcAGfciqelEbYYctS87elaSazbRHplWILailxNfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhBVfM7P5C7TwSGWNZv1Kbw5fMY)Cfq0ZI1kXIYSOGfRz5NRaIEZdqZqoyICac1GqlflnnS0Ife(CUQMmWkVWu(NRaIEwuIfLzPPHfe(CUQMmWkVWu(NRaIEwuIL4WsBwuWslwux9Uj45RcMvelkyPflwZsaIGkVEdcQ(9edlnnSOU6DZ4iOcUW5(qvSsygk1VcZcWyPfliJfGNLzvuhoOid(Q(sN3tGFAo3qLRQjqwAZcGvILFUci6nVYg1vVNbxJ)hSyrblQRE3mocQGlCUpufReMvelnnSOU6DZ4iOcUW5(qvSsKXx1x68Ec8tZ5MvelTzPPHLaeQbHwktWZxfmdL6xHzbySaqwINLFUci6nVYMaeQbHwkd4A8)GflkyXAwux9Uj45RcMvelkyPflwZsaIGkVEtDO2)C3jwAAyXAwq4Z5QAYeGfciqugKWjQalTzrblwZsaIGkVEdqjMZlwAAyjarqLxVPou7FU7elkybHpNRQjtawiGarzqcNOcSOGLaeQbHwktawiGar5FNY4OBUhBwrSOGfRzjaHAqOLYe88vbZkIffS0ILwSOU6Ddf0xeMY6v5JzOu)kmlXZIYjXstdlQRE3qb9fHPmgQ9XmuQFfML4zr5KyPnlkyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazPPHLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelkXcYyPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyrjwaeS0ML2S00WI6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrS0MLMgw6hQ9ppuQFfMfaZcatILMgwq4Z5QAYaR8ct5FUci6zrjwsIL2SOGfubqZqP(vywINLKS3WA4JT3(5kGOxz7np8hSS3(5kGOxz73o2kdCSTQ9gvUQMaTJP9Mh(dw2B)Cfq0dq7TWCpnNBV1Ife(CUQMmWkVWu(NRaIEwSwjwailkyXAw(5kGO38kBgYbtKdqOgeAPyPPHfe(CUQMmWkVWu(NRaIEwuIfaYIcwAXI6Q3nbpFvWSIyrblTyXAwcqeu51Bqq1VNyyPPHf1vVBghbvWfo3hQIvcZqP(vywaglTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwaSsS8ZvarV5bOrD17zW14)blwuWI6Q3nJJGk4cN7dvXkHzfXstdlQRE3mocQGlCUpufRez8v9LoVNa)0CUzfXsBwAAyjaHAqOLYe88vbZqP(vywaglaKL4z5NRaIEZdqtac1GqlLbCn(FWIffSynlQRE3e88vbZkIffS0IfRzjarqLxVPou7FU7elnnSynli85CvnzcWcbeikds4evGL2SOGfRzjarqLxVbOeZ5flkyPflwZI6Q3nbpFvWSIyPPHfRzjarqLxVbbv)EIHL2S00WsaIGkVEtDO2)C3jwuWccFoxvtMaSqabIYGeorfyrblbiudcTuMaSqabIY)oLXr3Cp2SIyrblwZsac1GqlLj45RcMvelkyPflTyrD17gkOVimL1RYhZqP(vywINfLtILMgwux9UHc6lctzmu7JzOu)kmlXZIYjXsBwuWI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYstdlTyrD17gvx7vGYWE2168VFfkCU8FnKb)EaiwuIfKXstdlQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daXIsSaiyPnlTzPnlnnSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelnnSOcXywuWs)qT)5Hs9RWSaywaysS00WccFoxvtgyLxyk)ZvarplkXssS0MffSGkaAgk1VcZs8SKK9gwdFS92pxbe9a0(TJTYaABRAVrLRQjq7yAVbs4WCr)bl7naaMWS4AnlWFNgwGfllmXY9ukMfyXsa0EZd)bl7TfMY3tPy73o2kdiSTQ9gvUQMaTJP9giHdZf9hSS3Iru4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOoS9Mh(dw2BZQYE4pyL1h(T3W)CH3o2kBVfM7P5C7ne(CUQMmho7qYEtF4pxEkzV5qY(TJTYifBRAVrLRQjq7yAVfM7P5C7TzvuhoOiJQR9kqzyp7AD(3Vcf2qXW6IIiq7n8px4TJTY2BE4pyzVnRk7H)GvwF43EtF4pxEkzVPc93(TJnatY2Q2Bu5QAc0oM2BE4pyzVnRk7H)GvwF43EtF4pxEkzVHF73(T3uH(BBv7yRSTvT3OYv1eODmT38WFWYEBCeubx4CFOkwjS3ajCyUO)GL9ga2qvSsWIL73zbnXfjwzfS3cZ90CU9M6Q3nbpFvWmuQFfML4zrzKz)2XgG2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelaMfablkyrD17gvx7vGYWE2168VFfkC2NGxKb)EaiwamlacwuWslwSMfq4BCqp6peugBXN0mON6OiZFbGUcflkyXAw8WFWY4GE0FiOm2IpPzqp1rrMRYD9HA)zrblTyXAwaHVXb9O)qqzSfFsZ7KRn)fa6kuS00Wci8noOh9hckJT4tAENCTzOu)kmlXZsCyPnlnnSacFJd6r)HGYyl(KMb9uhfzWVhaIfaZsCyrblGW34GE0FiOm2IpPzqp1rrMHs9RWSaywqglkybe(gh0J(dbLXw8jnd6PokY8xaORqXsB7nqchMl6pyzVbaWelXf0J(dbXYMfFszXYovS4plAcJz539If0JLycJRvzb)EaimlEbYYdzzO(q4DwCwaSsaKf87bGyXXSO9NyXXSebX4tvtSahw(lLy5EwWqwUNfFMdbHzb4Mf(zX7pnS4SehGXc(9aqSqip6gcB)2Xoo2w1EJkxvtG2X0EZd)bl7TaSqabIY)oLXr3Cp2EdKWH5I(dw2BaamXcAGfciqelwUFNf0exKyLvGfl7uXseeJpvnXIxGSa)DASCyIfl3VZIZsmHX1QSOU6DwSStflGeorfUcL9wyUNMZT3SMfWzDGMcMdGywuWslwAXccFoxvtMaSqabIYGeorfyrblwZsac1GqlLj45RcMHCWeS00WI6Q3nbpFvWSIyPnlkyPflQRE3O6AVcug2ZUwN)9RqHZL)RHm43daXIsSaiyPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyrjwaeS0MLMgwuHymlkyPFO2)8qP(vywamlkNelTTF7yJE2w1EJkxvtG2X0EZd)bl7T(AsKH9mPxfzVbs4WCr)bl7nami6ZIJz53jw63GFwqfaz5kw(DIfNLycJRvzXYvGqlSahwSC)ol)oXcW9eZ5flQRENf4WIL73zXzbqammfyjUGE0Fiiw2S4tklEbYIf)Ew6WHf0exKyLvGLRZY9SybwplQelRiwCu(vSOsD4qS87elbqwoml9Ro8obAVfM7P5C7TwS0ILwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelXZcWHLMgwux9Ur11EfOmSNDTo)7xHcN9j4fzWVhaIL4zb4WsBwuWslwSMLaebvE9geu97jgwAAyXAwux9UzCeubx4CFOkwjmRiwAZsBwuWslwaN1bAkyoaIzPPHLaeQbHwktWZxfmdL6xHzjEwqwsS00Wslwcqeu51BQd1(N7oXIcwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlXZcYsIL2S0ML2S00WslwaHVXb9O)qqzSfFsZGEQJImdL6xHzjEwaeSOGLaeQbHwktWZxfmdL6xHzjEwuojwuWsaIGkVEtrHbQHdilTzPPHLREAIGA)jWC)qT)5Hs9RWSaywaeSOGfRzjaHAqOLYe88vbZqoycwAAyjarqLxVbOeZ5flkyrD17gGUcCiWmLgbTqtkvVzfXstdlbicQ86niO63tmSOGf1vVBghbvWfo3hQIvcZqP(vywamlifwuWI6Q3nJJGk4cN7dvXkHzfz)2Xgz2w1EJkxvtG2X0EZd)bl7TGxbsNvx9U9wyUNMZT3AXI6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(vywINfaTbzS00WI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(vywINfaTbzS0MffS0ILaeQbHwktWZxfmdL6xHzjEwa0S00WslwcqOgeAPmuAe0cnzvybAgk1VcZs8SaOzrblwZI6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrSOGLaebvE9gGsmNxS0ML2SOGfh)JRZrql0Ws8kXsCsYEtD175Ytj7n87JgoG2BGeomx0FWYEdnEfinlBVpA4aYIL73zXzPilSetyCTklQRENfVazbnXfjwzfy5Wf6EwCv46z5HSOsSSWeO9BhBGJTvT3OYv1eODmT38WFWYEd)(GxdkYEdKWH5I(dw2BXOvAelBVp41GIWSy5(DwCwIjmUwLf1vVZI66zPGplw2PILiiuFfkw6WHf0exKyLvGf4WcW9RahcKLTOBUhBVfM7P5C7TwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaelXZcazPPHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGyjEwailTzrblTyjarqLxVPou7FU7elnnSeGqni0szcE(QGzOu)kmlXZcGMLMgwSMfe(CUQMmbWCawG3FWIffSynlbicQ86naLyoVyPPHLwSeGqni0szO0iOfAYQWc0muQFfML4zbqZIcwSMf1vVBa6kWHaZuAe0cnPu9zQOb1flYSIyrblbicQ86naLyoVyPnlTzrblTyXAwaHVPVMezypt6vrM)caDfkwAAyXAwcqOgeAPmbpFvWmKdMGLMgwSMLaeQbHwktawiGar5FNY4OBUhBgYbtWsB73o2aABRAVrLRQjq7yAV5H)GL9g(9bVguK9giHdZf9hSS3IrR0iw2EFWRbfHzrL6WHybnWcbeiYElm3tZ52BTyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywqglkyXAwaN1bAkyoaIzrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMHs9RWSaywqglTzrbli85CvnzcG5aSaV)GflTzrblwZci8n91Kid7zsVkY8xaORqXIcwcqeu51BQd1(N7oXIcwSMfWzDGMcMdGywuWcf0xeMmxL9kblkyXX)46Ce0cnSeplOxs2VDSbe2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1If1vVBghbvWfo3hQIvcZqP(vywINfKXstdlwZI6Q3nJJGk4cN7dvXkHzfXsBwuWslwux9UbORahcmtPrql0Ks1NPIguxSiZqP(vywamlOcGMuh5S0MffS0If1vVBOG(IWugd1(ygk1VcZs8SGkaAsDKZstdlQRE3qb9fHPSEv(ygk1VcZs8SGkaAsDKZsB7nqchMl6pyzVfJGf6EwaHplGR5kuS87elubYcSZsmMJGk4cZca2qvSsGwwaxZvOybORahcKfkncAHMuQEwGdlxXYVtSOD8ZcQailWolEXc6h0xeMS3q4tU8uYEde(5HIH1nukvp2(TJnsX2Q2Bu5QAc0oM2BE4pyzVHxv)gYElm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwug4WIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBLtY2Q2Bu5QAc0oM2BE4pyzVLcHv)gYElm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwuoogKXIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBLv22Q2Bu5QAc0oM2BE4pyzVHFsR9j31(q2BH5EAo3EBO(q4DxvtSOGL3hu0B(lLYpmdEelXZIYahwagldL6xHzrblEuoStbGyrbli85CvnzaHFEOyyDdLs1JT3cjcAk)(GIESDSv2(TJTYa02Q2Bu5QAc0oM2BE4pyzV1HtGYWEU8FnK9giHdZf9hSS3aWGXMfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhBLJJTvT3OYv1eODmT38WFWYEJsJGwOjRclq7nqchMl6pyzVH(Prql0WsmHfilw2PIfxfUEwEilu90WIZsrwyjMW4AvwSCfi0clEbYc2rqS0HdlOjUiXkRG9wyUNMZT3AXcf0xeMm6v5tUiK)S00Wcf0xeMmyO2NCri)zPPHfkOVimz8krUiK)S00WI6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(vywINfaTbzS00WI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(vywINfaTbzS00WIJ)X15iOfAyjEwqkjXIcwcqOgeAPmbpFvWmKdMGffSynlGZ6anfmhaXS0MffS0ILaeQbHwktWZxfmdL6xHzjEwItsS00Wsac1GqlLj45RcMHCWeS0MLMgwU6PjcQ9NaZ9d1(Nhk1VcZcGzr5KSF7yRm6zBv7nQCvnbAht7np8hSS36Rjrg2ZKEvK9giHdZf9hSS3aWGOplZHA)zrL6WHyzHVcflOjU2BH5EAo3ElaHAqOLYe88vbZqoycwuWccFoxvtMayoalW7pyXIcwAXIJ)X15iOfAyjEwqkjXIcwSMLaebvE9M6qT)5UtS00WsaIGkVEtDO2)C3jwuWIJ)X15iOfAybWSGEjXsBwuWI1SeGiOYR3GGQFpXWIcwAXI1SeGiOYR3uhQ9p3DILMgwcqOgeAPmbyHaceL)DkJJU5ESzihmblTzrblwZc4SoqtbZbqS9BhBLrMTvT3OYv1eODmT3Gr2By6T38WFWYEdHpNRQj7neUEr2BwZc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrblTyPflo(hxNJGwOHL4zbPKelkyPflQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfXstdlwZsaIGkVEdqjMZlwAZstdlQRE3OQHqq9c)MvelkyrD17gvnecQx43muQFfMfaZI6Q3nbpFvWaUg)pyXsBwAAy5QNMiO2Fcm3pu7FEOu)kmlaMf1vVBcE(QGbCn(FWILMgwcqeu51BQd1(N7oXsBwuWslwSMLaebvE9M6qT)5UtS00WslwC8pUohbTqdlaMf0ljwAAybe(M(AsKH9mPxfz(la0vOyPnlkyPfli85CvnzcWcbeikds4evGLMgwcqOgeAPmbyHaceL)DkJJU5ESzihmblTzPT9giHdZf9hSS3qtCrIvwbwSStfl(ZcsjjGXsCXaswAbhn0cnS87EXc6LelXfdizXY97SGgyHace1Mfl3VdxplAi(kuS8xkXYvSetnecQx4NfVazrFfXYkIfl3VZcAGfciqelxNL7zXIJzbKWjQabAVHWNC5PK9wamhGf49hSYQq)TF7yRmWX2Q2Bu5QAc0oM2BH5EAo3EdHpNRQjtamhGf49hSYQq)T38WFWYElqAc)NRZU(qvPu92VDSvgqBBv7nQCvnbAht7TWCpnNBVHWNZv1KjaMdWc8(dwzvO)2BE4pyzVDvWNY)dw2VDSvgqyBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9gf0xeMmxL1RYhwaEwaeSGew8WFWYGFF63qgc5uy9u(VuIfGXI1Sqb9fHjZvz9Q8HfGNLwSaCybyS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSa8SehwAZcsyXd)blJLX)DdHCkSEk)xkXcWyjjdazbjSGJiToV74NS3ajCyUO)GL9g6J)l1FcZYo0clPRWolXfdizXhIfu(veilr0WcMcWc0EdHp5Ytj7nhhbiPzJc2VDSvgPyBv7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9wmALgXY27dEnOimlw2PILFNyPFO2FwomlUkC9S8qwOceTS0hQIvcwomlUkC9S8qwOceTSKaUyXhIf)zbPKeWyjUyajlxXIxSG(b9fHj0YcAIlsSYkWI2XpMfVG)onSaiagMcywGdljGlwSaxAqwGiOj4rSKchILF3lw4gLtIL4IbKSyzNkwsaxSybU0Gf6Ew2EFWRbfXsbTyVfM7P5C7TwSC1tteu7pbM7hQ9ppuQFfMfaZc6XstdlTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcQaOj1rolaplb60S0Ifh)JRZrql0WcsyjojXsBwuWI6Q3nJJGk4cN7dvXkHzfXsBwAZstdlTyXX)46Ce0cnSamwq4Z5QAY44iajnBuGfGNf1vVBOG(IWugd1(ygk1VcZcWybe(M(AsKH9mPxfz(laeopuQFflapla0GmwINfLvojwAAyXX)46Ce0cnSamwq4Z5QAY44iajnBuGfGNf1vVBOG(IWuwVkFmdL6xHzbySacFtFnjYWEM0RIm)facNhk1VIfGNfaAqglXZIYkNelTzrbluqFryYCv2ReSOGLwSynlQRE3e88vbZkILMgwSML31u9g87JgoGgQCvnbYsBwuWslwAXI1SeGqni0szcE(QGzfXstdlbicQ86naLyoVyrblwZsac1GqlLHsJGwOjRclqZkIL2S00WsaIGkVEtDO2)C3jwAZIcwAXI1SeGiOYR3GGQFpXWstdlwZI6Q3nbpFvWSIyPPHfh)JRZrql0Ws8SGusIL2S00WslwExt1BWVpA4aAOYv1eilkyrD17MGNVkywrSOGLwSOU6Dd(9rdhqd(9aqSaywIdlnnS44FCDocAHgwINfKssS0ML2S00WI6Q3nbpFvWSIyrblwZI6Q3nJJGk4cN7dvXkHzfXIcwSML31u9g87JgoGgQCvnbA)2XgGjzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSyfRYhwq)G(IWelEbYc2rqSeJRR7adaBP1SaGdclw6WHf0exKyLvWElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfc5uy9u(VuILMgwAXsy3hueMfLybGSOGLHc7(GIY)LsSaywqglTzPPHLWUpOimlkXsCyPnlkyXJYHDkaK9BhBaQSTvT3OYv1eODmT3cZ90CU9wlwux9UHc6lctz9Q8XmuQFfML4zHqofwpL)lLyrblTyjaHAqOLYe88vbZqP(vywINfKLelnnSeGqni0szcWcbeik)7ughDZ9yZqP(vywINfKLelTzPPHLwSe29bfHzrjwailkyzOWUpOO8FPelaMfKXsBwAAyjS7dkcZIsSehwAZIcw8OCyNcazV5H)GL92UR75uiSSF7ydqaABv7nQCvnbAht7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKtH1t5)sjwuWslwcqOgeAPmbpFvWmuQFfML4zbzjXstdlbiudcTuMaSqabIY)oLXr3Cp2muQFfML4zbzjXsBwAAyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbzS0MLMgwc7(GIWSOelXHL2SOGfpkh2Paq2BE4pyzV1xADofcl73o2amo2w1EJkxvtG2X0EdKWH5I(dw2Baxq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF7ydq0Z2Q2Bu5QAc0oM2BE4pyzVHFF63q2BGeomx0FWYEdaGjw2EF63qS8qwIgyGLnO2hwq)G(IWelWHfl7uXYvSalDcwSIv5dlOFqFryIfVazzHjwaUGOplrdmGz56SCflwXQ8Hf0pOVimzVfM7P5C7nkOVimzUkRxLpS00Wcf0xeMmyO2NCri)zPPHfkOVimz8krUiK)S00WI6Q3nw8zo4KH9mPxfzwrSOGf1vVBOG(IWuwVkFmRiwAAyPflQRE3e88vbZqP(vywamlE4pyzSm(VBiKtH1t5)sjwuWI6Q3nbpFvWSIyPT9BhBaImBRAV5H)GL9MLX)D7nQCvnbAht73o2ae4yBv7nQCvnbAht7np8hSS3MvL9WFWkRp8BVPp8NlpLS36Uw)7ZY(TF7nhs2w1o2kBBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9wlwux9U5VuYcCQm4qEQ6vG0ygk1VcZcGzbva0K6iNfGXssgLzPPHf1vVB(lLSaNkdoKNQEfinMHs9RWSayw8WFWYGFF63qgc5uy9u(VuIfGXssgLzrblTyHc6lctMRY6v5dlnnSqb9fHjdgQ9jxeYFwAAyHc6lctgVsKlc5plTzPnlkyrD17M)sjlWPYGd5PQxbsJzfXIcwMvrD4GIm)LswGtLbhYtvVcKgdvUQMaT3ajCyUO)GL9gACDyP9NWSyzN(DAy53jwIrd5Pb)d70WI6Q3zXYP1S0DTMfyVZIL73VILFNyPiK)SeC8BVHWNC5PK9g4qEA2YP15UR1zyVB)2XgG2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzVznluqFryYCvgd1(WIcwAXcoI0687dk6Xg87t)gIL4zbzSOGL31u9gmCPZWE(3PChoe(nu5QAcKLMgwWrKwNFFqrp2GFF63qSeplaAwABVbs4WCr)bl7n046Ws7pHzXYo970WY27dEnOiwomlwGZVZsWX)vOybIGgw2EF63qSCflwXQ8Hf0pOVimzVHWNC5PK92HQGdLXVp41GISF7yhhBRAVrLRQjq7yAV5H)GL9wawiGar5FNY4OBUhBVbs4WCr)bl7naaMybnWcbeiIfl7uXI)SOjmMLF3lwqwsSexmGKfVazrFfXYkIfl3VZcAIlsSYkyVfM7P5C7nRzbCwhOPG5aiMffS0ILwSGWNZv1KjaleqGOmiHtubwuWI1SeGqni0szcE(QGzihmblnnSOU6DtWZxfmRiwAZIcwAXI6Q3nuqFrykRxLpMHs9RWSeplahwAAyrD17gkOVimLXqTpMHs9RWSeplahwAZIcwAXI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYstdlQRE3O6AVcug2ZUwN)9RqHZL)RHm43daXs8SehwAAyrD17gvx7vGYWE2168VFfkC2NGxKb)EaiwINL4WsBwAAyrfIXSOGL(HA)ZdL6xHzbWSOCsSOGfRzjaHAqOLYe88vbZqoycwAB)2Xg9STQ9gvUQMaTJP9Mh(dw2BJJGk4cN7dvXkH9giHdZf9hSS3aayIfaSHQyLGfl3VZcAIlsSYkyVfM7P5C7n1vVBcE(QGzOu)kmlXZIYiZ(TJnYSTQ9gvUQMaTJP9Mh(dw2B4v1VHS3cjcAk)(GIESDSv2Elm3tZ52BTyzO(q4DxvtS00WI6Q3nuqFrykJHAFmdL6xHzbWSehwuWcf0xeMmxLXqTpSOGLHs9RWSaywug9yrblVRP6ny4sNH98Vt5oCi8BOYv1eilTzrblVpOO38xkLFyg8iwINfLrpwaqSGJiTo)(GIEmlaJLHs9RWSOGLwSqb9fHjZvzVsWstdldL6xHzbWSGkaAsDKZsB7nqchMl6pyzVbaWelBRQFdXYvSe5fiLEbwGflEL43Vcfl)U)SOpeeMfLrpmfWS4filAcJzXY97SKchIL3hu0JzXlqw8NLFNyHkqwGDwCw2GAFyb9d6lctS4plkJESGPaMf4WIMWywgk1V6kuS4ywEilf8zz3rCfkwEild1hcVZc4AUcflwXQ8Hf0pOVimz)2Xg4yBv7nQCvnbAht7np8hSS3WRQFdzVbs4WCr)bl7naaMyzBv9BiwEil7ocIfNfuAOQRz5HSSWelwzmoIr2BH5EAo3EdHpNRQjZfdG5aSaV)GflkyjaHAqOLYCfomR3v1uogwE9R0miH4cKzihmblkyHIH1ffrGMRWHz9UQMYXWYRFLMbjexGSF7ydOTTQ9gvUQMaTJP9wyUNMZT3SML31u9g8tATpzW56VHkxvtGSOGLwSOU6Dd(9P7ATzO(q4DxvtSOGLwSGJiTo)(GIESb)(0DTMfaZsCyPPHfRzzwf1HdkY8xkzbovgCipv9kqAmu5QAcKL2S00WY7AQEdgU0zyp)7uUdhc)gQCvnbYIcwux9UHc6lctzmu7JzOu)kmlaML4WIcwOG(IWK5QmgQ9HffSOU6Dd(9P7ATzOu)kmlaMfanlkybhrAD(9bf9yd(9P7AnlXRelOhlTzrblTyXAwMvrD4GIm6ebFCCURj6VcvgL(sJWKHkxvtGS00WYFPelivwqpKXs8SOU6Dd(9P7ATzOu)kmlaJfaYsBwuWY7dk6n)Ls5hMbpIL4zbz2BE4pyzVHFF6UwB)2XgqyBv7nQCvnbAht7np8hSS3WVpDxRT3ajCyUO)GL9gW197SS9Kw7dlXO56pllmXcSyjaYILDQyzO(q4DxvtSOUEwW)P1SyXVNLoCyXkse8XXSenWalEbYciSq3ZYctSOsD4qSGMye2WY2FAnllmXIk1HdXcAGfciqel4Rcel)U)Sy50AwIgyGfVG)onSS9(0DT2Elm3tZ52BVRP6n4N0AFYGZ1FdvUQMazrblQRE3GFF6UwBgQpeE3v1elkyPflwZYSkQdhuKrNi4JJZDnr)vOYO0xAeMmu5QAcKLMgw(lLybPYc6HmwINf0JL2SOGL3hu0B(lLYpmdEelXZsCSF7yJuSTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEd46(DwIrd5PQxbsdllmXY27t31AwEilaruelRiw(DIf1vVZIAcwCngYYcFfkw2EF6UwZcSybzSGPaSaXSahw0egZYqP(vxHYElm3tZ52BZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGSOGfCeP153hu0Jn43NUR1SeVsSehwuWslwSMf1vVB(lLSaNkdoKNQEfinMvelkyrD17g87t31AZq9HW7UQMyPPHLwSGWNZv1KbCipnB506C316mS3zrblTyrD17g87t31AZqP(vywamlXHLMgwWrKwNFFqrp2GFF6UwZs8SaqwuWY7AQEd(jT2Nm4C93qLRQjqwuWI6Q3n43NUR1MHs9RWSaywqglTzPnlTTF7yRCs2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV54FCDocAHgwINfarsSaGyPflkNelaplQRE38xkzbovgCipv9kqAm43daXsBwaqS0If1vVBWVpDxRndL6xHzb4zjoSGewWrKwN3D8tSa8SynlVRP6n4N0AFYGZ1FdvUQMazPnlaiwAXsac1GqlLb)(0DT2muQFfMfGNL4WcsybhrADE3XpXcWZY7AQEd(jT2Nm4C93qLRQjqwAZcaILwSacFtFnjYWEM0RImdL6xHzb4zbzS0MffS0If1vVBWVpDxRnRiwAAyjaHAqOLYGFF6UwBgk1VcZsB7nqchMl6pyzVHgxhwA)jmlw2PFNgwCw2EFWRbfXYctSy50Awc(ctSS9(0DTMLhYs31AwG9oAzXlqwwyILT3h8AqrS8qwaIOiwIrd5PQxbsdl43daXYkYEdHp5Ytj7n87t316Sfy95UR1zyVB)2XwzLTTQ9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYEdaGjw2EFWRbfXIL73zjgnKNQEfinS8qwaIOiwwrS87elQRENfl3VdxplAi(kuSS9(0DTMLv0FPelEbYYctSS9(GxdkIfyXc6bmwIjmUwLf87bGWSSQ)0SGES8(GIES9wyUNMZT3q4Z5QAYaoKNMTCADU7ADg27SOGfe(CUQMm43NUR1zlW6ZDxRZWENffSynli85CvnzoufCOm(9bVguelnnS0If1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGyjEwIdlnnSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpaelXZsCyPnlkybhrAD(9bf9yd(9P7AnlaMf0JffSGWNZv1Kb)(0DToBbwFU7ADg272VDSvgG2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVznl)fa6kuSOGfRzXd)blJd6r)HGYyl(KMb9uhfzUk31hQ9NLMgwaHVXb9O)qqzSfFsZGEQJIm43daXcGzjoSOGfq4BCqp6peugBXN0mON6OiZqP(vywamlXXEdKWH5I(dw2BaamXc2IpPSGHS87(Zsc4Ifu0ZsQJCwwr)LsSOMGLf(kuSCploMfT)eloMLiigFQAIfyXIMWyw(DVyjoSGFpaeMf4WcWnl8ZILDQyjoaJf87bGWSqip6gY(TJTYXX2Q2Bu5QAc0oM2BE4pyzVLcHv)gYElKiOP87dk6X2Xwz7TWCpnNBVnuFi8URQjwuWY7dk6n)Ls5hMbpIL4zPflTyrz0JfGXslwWrKwNFFqrp2GFF63qSa8SaqwaEwux9UHc6lctz9Q8XSIyPnlTzbySmuQFfML2SGewAXIYSamwExt1BElxLtHWcBOYv1eilTzrblTyjaHAqOLYe88vbZqoycwuWI1SaoRd0uWCaeZIcwAXccFoxvtMaSqabIYGeorfyPPHLaeQbHwktawiGar5FNY4OBUhBgYbtWstdlwZsaIGkVEtDO2)C3jwAZstdl4isRZVpOOhBWVp9BiwamlTyPflahwaqS0If1vVBOG(IWuwVkFmRiwaEwailTzPnlaplTyrzwaglVRP6nVLRYPqyHnu5QAcKL2S0MffSynluqFryYGHAFYfH8NLMgwAXcf0xeMmxLXqTpS00WslwOG(IWK5QSk83zPPHfkOVimzUkRxLpS0MffSynlVRP6ny4sNH98Vt5oCi8BOYv1eilnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IyjELybGiljwAZIcwAXcoI0687dk6Xg87t)gIfaZIYjXcWZslwuMfGXY7AQEZB5QCkewydvUQMazPnlTzrblo(hxNJGwOHL4zbzjXcaIf1vVBWVpDxRndL6xHzb4zb4WsBwuWslwSMf1vVBa6kWHaZuAe0cnPu9zQOb1flYSIyPPHfkOVimzUkJHAFyPPHfRzjarqLxVbOeZ5flTzrblwZI6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwr2BGeomx0FWYElgJ6dH3zbahew9BiwUolOjUiXkRalhMLHCWeOLLFNgIfFiw0egZYV7fliJL3hu0Jz5kwSIv5dlOFqFryIfl3VZYg8bWqllAcJz539IfLtIf4VtJLdtSCflELGf0pOVimXcCyzfXYdzbzS8(GIEmlQuhoelolwXQ8Hf0pOVimzyjgbl09SmuFi8olGR5kuSaC)kWHazb9tJGwOjLQNLvPjmMLRyzdQ9Hf0pOVimz)2Xwz0Z2Q2Bu5QAc0oM2BE4pyzV1HtGYWEU8FnK9giHdZf9hSS3aayIfamySzbwSeazXY97W1ZsWJIUcL9wyUNMZT38OCyNcaz)2XwzKzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M1SaoRd0uWCaeZIcwq4Z5QAYeaZbybE)blwuWslwAXI6Q3n43NUR1MvelnnS8UMQ3GFsR9jdox)nu5QAcKLMgwcqeu51BQd1(N7oXsBwuWslwSMf1vVBWqn(VazwrSOGfRzrD17MGNVkywrSOGLwSynlVRP6n91Kid7zsVkYqLRQjqwAAyrD17MGNVkyaxJ)hSyjEwcqOgeAPm91Kid7zsVkYmuQFfMfGXcGGL2SOGfe(CUQMm)(CADgteq0KT43ZIcwAXI1SeGiOYR3uhQ9p3DILMgwcqOgeAPmbyHaceL)DkJJU5ESzfXIcwAXI6Q3n43NUR1MHs9RWSaywailnnSynlVRP6n4N0AFYGZ1FdvUQMazPnlTzrblVpOO38xkLFyg8iwINf1vVBcE(QGbCn(FWIfGNLKmaAwAZstdlQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWIL22Bi8jxEkzVfaZbybE)bRSdj73o2kdCSTQ9gvUQMaTJP9Mh(dw2Bbst4)CD21hQkLQ3EdKWH5I(dw2BaamXcAIlsSYkWcSyjaYYQ0egZIxGSOVIy5EwwrSy5(DwqdSqabIS3cZ90CU9gcFoxvtMayoalW7pyLDiz)2XwzaTTvT3OYv1eODmT3cZ90CU9gcFoxvtMayoalW7pyLDizV5H)GL92vbFk)pyz)2XwzaHTvT3OYv1eODmT38WFWYEJsJGwOjRclq7nqchMl6pyzVbaWelOFAe0cnSetybYcSyjaYIL73zz79P7AnlRiw8cKfSJGyPdhwaKln2hw8cKf0exKyLvWElm3tZ52Bx90eb1(tG5(HA)ZdL6xHzbWSOmYyPPHLwSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaqKLelnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IyjELybGiljwAZIcwux9Ub)(0DT2SIyrblTyjaHAqOLYe88vbZqP(vywINfKLelnnSaoRd0uWCaeZsB73o2kJuSTQ9gvUQMaTJP9Mh(dw2B4N0AFYDTpK9wirqt53hu0JTJTY2BH5EAo3EBO(q4DxvtSOGL)sP8dZGhXs8SOmYyrbl4isRZVpOOhBWVp9BiwamlOhlkyXJYHDkaelkyPflQRE3e88vbZqP(vywINfLtILMgwSMf1vVBcE(QGzfXsB7nqchMl6pyzVfJr9HW7S01(qSalwwrS8qwIdlVpOOhZIL73HRNf0exKyLvGfv6kuS4QW1ZYdzHqE0nelEbYsbFwGiOj4rrxHY(TJnatY2Q2Bu5QAc0oM2BE4pyzV1xtImSNj9Qi7nqchMl6pyzVbaWelayq0NLRZYv4dKyXlwq)G(IWelEbYI(kIL7zzfXIL73zXzbqU0yFyjAGbw8cKL4c6r)HGyzZIpP2BH5EAo3EJc6lctMRYELGffS4r5WofaIffSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaqKLelkyPflGW34GE0FiOm2IpPzqp1rrM)caDfkwAAyXAwcqeu51BkkmqnCazPPHfCeP153hu0JzjEwailTzrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcsHfaelTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsBwuWslwSMLaeQbHwktWZxfmRiwAAyrD17MFFoToJjciAm43daXcGzrzKXIcw6hQ9ppuQFfMfaZcatkjwuWs)qT)5Hs9RWSeplkNusS00WI1SGHlT6vGMFFoToJjciAmu5QAcKL2SOGLwSGHlT6vGMFFoToJjciAmu5QAcKLMgwcqOgeAPmbpFvWmuQFfML4zjojXsB73o2auzBRAVrLRQjq7yAV5H)GL9g(9P7AT9giHdZf9hSS3aayIfNLT3NUR1SaGVOFNLObgyzvAcJzz79P7AnlhMfxpKdMGLvelWHLeWfl(qS4QW1ZYdzbIGMGhXsCXas7TWCpnNBVPU6DdSOFhNJOjqr)blZkIffS0If1vVBWVpDxRnd1hcV7QAILMgwC8pUohbTqdlXZcsjjwAB)2XgGa02Q2Bu5QAc0oM2BE4pyzVHFF6UwBVbs4WCr)bl7Ty0knIL4IbKSOsD4qSGgyHaceXIL73zz79P7AnlEbYYVtflBVp41GIS3cZ90CU9waIGkVEtDO2)C3jwuWI1S8UMQ3GFsR9jdox)nu5QAcKffS0Ife(CUQMmbyHaceLbjCIkWstdlbiudcTuMGNVkywrS00WI6Q3nbpFvWSIyPnlkyjaHAqOLYeGfciqu(3Pmo6M7XMHs9RWSaywqfanPoYzb4zjqNMLwS44FCDocAHgwqcliljwAZIcwux9Ub)(0DT2muQFfMfaZc6XIcwSMfWzDGMcMdGy73o2amo2w1EJkxvtG2X0Elm3tZ52BbicQ86n1HA)ZDNyrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMvelnnSOU6DtWZxfmRiwAZIcwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlaMfGdlkyrD17g87t31AZkIffSqb9fHjZvzVsWIcwSMfe(CUQMmhQcoug)(GxdkIffSynlGZ6anfmhaX2BE4pyzVHFFWRbfz)2XgGONTvT3OYv1eODmT38WFWYEd)(GxdkYEdKWH5I(dw2BaamXY27dEnOiwSC)olEXca(I(DwIgyGf4WY1zjbCHoqwGiOj4rSexmGKfl3VZsc4AyPiK)SeC8ByjUAmKfWvAelXfdizXFw(DIfQazb2z53jwIXt1VNyyrD17SCDw2EF6UwZIf4sdwO7zP7AnlWENf4Wsc4IfFiwGflaKL3hu0JT3cZ90CU9M6Q3nWI(DCoOjFYio8blZkILMgwAXI1SGFF63qgpkh2PaqSOGfRzbHpNRQjZHQGdLXVp41GIyPPHLwSOU6DtWZxfmdL6xHzbWSGmwuWI6Q3nbpFvWSIyPPHLwS0If1vVBcE(QGzOu)kmlaMfubqtQJCwaEwc0PzPflo(hxNJGwOHfKWsCsIL2SOGf1vVBcE(QGzfXstdlQRE3mocQGlCUpufRez8v9LoVNa)0CUzOu)kmlaMfubqtQJCwaEwc0PzPflo(hxNJGwOHfKWsCsIL2SOGf1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIyPnlkyjarqLxVbbv)EIHL2S0MffS0IfCeP153hu0Jn43NUR1SaywIdlnnSGWNZv1Kb)(0DToBbwFU7ADg27S0ML2SOGfRzbHpNRQjZHQGdLXVp41GIyrblTyXAwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazPPHfCeP153hu0Jn43NUR1SaywIdlTTF7ydqKzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSSb1(Wc6h0xeMyXlqwWocIfaSLwZcaoiSyPdhwqtCrIvwb7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiNcRNY)LsS00Wslwc7(GIWSOelaKffSmuy3huu(VuIfaZcYyPnlnnSe29bfHzrjwIdlTzrblEuoStbGSF7ydqGJTvT3OYv1eODmT3cZ90CU9wlwux9UHc6lctzmu7JzOu)kmlXZcHCkSEk)xkXstdlTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS0MffS4r5WofaIffS0If1vVBghbvWfo3hQIvcZqP(vywamliJffSOU6DZ4iOcUW5(qvSsywrSOGfRzzwf1HdkYGVQV059e4NMZnu5QAcKLMgwSMf1vVBghbvWfo3hQIvcZkIL22BE4pyzVT76Eofcl73o2aeqBBv7nQCvnbAht7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiNcRNY)LsSOGLwSeGqni0szcE(QGzOu)kmlXZcYsILMgwcqOgeAPmbyHaceL)DkJJU5ESzOu)kmlXZcYsIL2S00Wslwc7(GIWSOelaKffSmuy3huu(VuIfaZcYyPnlnnSe29bfHzrjwIdlTzrblEuoStbGyrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcYyrblQRE3mocQGlCUpufReMvelkyXAwMvrD4GIm4R6lDEpb(P5CdvUQMazPPHfRzrD17MXrqfCHZ9HQyLWSIyPT9Mh(dw2B9LwNtHWY(TJnabe2w1EJkxvtG2X0EdKWH5I(dw2BaamXcWfe9zbwSGMyK9Mh(dw2Bw8zo4KH9mPxfz)2XgGifBRAVrLRQjq7yAVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3WrKwNFFqrp2GFF63qSeplOhlaJLUgchwAXsQJFAsKr46fXcWZIYjLeliHfaMelTzbyS01q4Wslwux9Ub)(GxdkktPrql0Ks1NXqTpg87bGybjSGES02EdKWH5I(dw2BOX1HL2FcZILD63PHLhYYctSS9(0VHy5kw2GAFyXY(f2z5WS4pliJL3hu0JbMYS0HdlecAsWcatcPYsQJFAsWcCyb9yz79bVguelOFAe0cnPu9SGFpae2EdHp5Ytj7n87t)gkFvgd1(y)2XoojzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MYSGewWrKwN3D8tSaywailaiwAXssgaYcWZslwWrKwNFFqrp2GFF63qSaGyrzwAZcWZslwuMfGXY7AQEdgU0zyp)7uUdhc)gQCvnbYcWZIYgKXsBwAZcWyjjJYiJfGNf1vVBghbvWfo3hQIvcZqP(vy7nqchMl6pyzVHgxhwA)jmlw2PFNgwEilaxJ)7SaUMRqXca2qvSsyVHWNC5PK9MLX)98v5(qvSsy)2XookBBv7nQCvnbAht7np8hSS3Sm(VBVbs4WCr)bl7naaMyb4A8FNLRyzdQ9Hf0pOVimXcCy56Suqw2EF63qSy50Aw63ZYvpKf0exKyLvGfVsKchYElm3tZ52BTyHc6lctg9Q8jxeYFwAAyHc6lctgVsKlc5plkybHpNRQjZHZbn5iiwAZIcwAXY7dk6n)Ls5hMbpIL4zb9yPPHfkOVimz0RYN8vzaYstdl9d1(Nhk1VcZcGzr5KyPnlnnSOU6Ddf0xeMYyO2hZqP(vywamlE4pyzWVp9BidHCkSEk)xkXIcwux9UHc6lctzmu7JzfXstdluqFryYCvgd1(WIcwSMfe(CUQMm43N(nu(QmgQ9HLMgwux9Uj45RcMHs9RWSayw8WFWYGFF63qgc5uy9u(VuIffSynli85CvnzoCoOjhbXIcwux9Uj45RcMHs9RWSaywiKtH1t5)sjwuWI6Q3nbpFvWSIyPPHf1vVBghbvWfo3hQIvcZkIffSGWNZv1KXY4)E(QCFOkwjyPPHfRzbHpNRQjZHZbn5iiwuWI6Q3nbpFvWmuQFfML4zHqofwpL)lLSF7yhhaABv7nQCvnbAht7nqchMl6pyzVbaWelBVp9BiwUolxXIvSkFyb9d6lctOLLRyzdQ9Hf0pOVimXcSyb9aglVpOOhZcCy5HSenWalBqTpSG(b9fHj7np8hSS3WVp9Bi73o2Xjo2w1EJkxvtG2X0EdKWH5I(dw2BayUw)7ZYEZd)bl7Tzvzp8hSY6d)2B6d)5Ytj7TUR1)(SSF73ER7A9VplBRAhBLTTQ9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYEB79bVguelD4WskebLs1ZYQ0egZYcFfkwIjmUw1Elm3tZ52BwZYSkQdhuKr11EfOmSNDTo)7xHcBOyyDrreO9BhBaABv7nQCvnbAht7np8hSS3WRQFdzVfse0u(9bf9y7yRS9wyUNMZT3aHVjfcR(nKzOu)kmlXZYqP(vywaEwaiazbjSOmGWEdKWH5I(dw2BOXXpl)oXci8zXY97S87elPq8ZYFPelpKfheKLv9NMLFNyj1rolGRX)dwSCyw2V3WY2Q63qSmuQFfML0L(Vi9rGS8qws9pSZskew9BiwaxJ)hSSF7yhhBRAV5H)GL9wkew9Bi7nQCvnbAht73(T3WVTvTJTY2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVbaWelBVp41GIy5HSaerrSSIy53jwIrd5PQxbsdlQRENLRZY9SybU0GSqip6gIfvQdhIL(vhE)kuS87elfH8NLGJFwGdlpKfWvAelQuhoelObwiGar2BH5EAo3EBwf1HdkY8xkzbovgCipv9kqAmu5QAcKffS0IfkOVimzUk7vcwuWI1S0ILwSOU6DZFPKf4uzWH8u1RaPXmuQFfML4zXd)blJLX)DdHCkSEk)xkXcWyjjJYSOGLwSqb9fHjZvzv4VZstdluqFryYCvgd1(WstdluqFryYOxLp5Iq(ZsBwAAyrD17M)sjlWPYGd5PQxbsJzOu)kmlXZIh(dwg87t)gYqiNcRNY)LsSamwsYOmlkyPfluqFryYCvwVkFyPPHfkOVimzWqTp5Iq(ZstdluqFryY4vICri)zPnlTzPPHfRzrD17M)sjlWPYGd5PQxbsJzfXsBwAAyPflQRE3e88vbZkILMgwq4Z5QAYeGfciqugKWjQalTzrblbiudcTuMaSqabIY)oLXr3Cp2mKdMGffSeGiOYR3uhQ9p3DIL2SOGLwSynlbicQ86naLyoVyPPHLaeQbHwkdLgbTqtwfwGMHs9RWSeplacwAZIcwAXI6Q3nbpFvWSIyPPHfRzjaHAqOLYe88vbZqoycwAB)2XgG2w1EJkxvtG2X0EZd)bl7nh0J(dbLXw8j1ElKiOP87dk6X2Xwz7TWCpnNBVznlGW34GE0FiOm2IpPzqp1rrM)caDfkwuWI1S4H)GLXb9O)qqzSfFsZGEQJImxL76d1(ZIcwAXI1SacFJd6r)HGYyl(KM3jxB(la0vOyPPHfq4BCqp6peugBXN08o5AZqP(vywINfKXsBwAAybe(gh0J(dbLXw8jnd6PokYGFpaelaML4WIcwaHVXb9O)qqzSfFsZGEQJImdL6xHzbWSehwuWci8noOh9hckJT4tAg0tDuK5VaqxHYEdKWH5I(dw2BaamXsCb9O)qqSSzXNuwSStfl)onelhMLcYIh(dbXc2IpPOLfhZI2FIfhZseeJpvnXcSybBXNuwSC)olaKf4WsNSqdl43daHzboSalwCwIdWybBXNuwWqw(D)z53jwkYclyl(KYIpZHGWSaCZc)S49Ngw(D)zbBXNuwiKhDdHTF7yhhBRAVrLRQjq7yAV5H)GL9wawiGar5FNY4OBUhBVbs4WCr)bl7naaMWSGgyHaceXY1zbnXfjwzfy5WSSIyboSKaUyXhIfqcNOcxHIf0exKyLvGfl3VZcAGfciqelEbYsc4IfFiwujn0clOxsSexmG0Elm3tZ52BwZc4SoqtbZbqmlkyPflTybHpNRQjtawiGarzqcNOcSOGfRzjaHAqOLYe88vbZqoycwuWI1SmRI6WbfzIMlfoGNRZ(e86c5OLg7JHkxvtGS00WI6Q3nbpFvWSIyPnlkyXX)46Ce0cnSayLyb9sIffS0If1vVBOG(IWuwVkFmdL6xHzjEwuojwAAyrD17gkOVimLXqTpMHs9RWSeplkNelTzPPHfvigZIcw6hQ9ppuQFfMfaZIYjXIcwSMLaeQbHwktWZxfmd5GjyPT9BhB0Z2Q2Bu5QAc0oM2BWi7nm92BE4pyzVHWNZv1K9gcxVi7TwSOU6DZ4iOcUW5(qvSsygk1VcZs8SGmwAAyXAwux9UzCeubx4CFOkwjmRiwAZIcwSMf1vVBghbvWfo3hQIvIm(Q(sN3tGFAo3SIyrblTyrD17gGUcCiWmLgbTqtkvFMkAqDXImdL6xHzbWSGkaAsDKZsBwuWslwux9UHc6lctzmu7JzOu)kmlXZcQaOj1rolnnSOU6Ddf0xeMY6v5JzOu)kmlXZcQaOj1rolnnS0IfRzrD17gkOVimL1RYhZkILMgwSMf1vVBOG(IWugd1(ywrS0MffSynlVRP6nyOg)xGmu5QAcKL22BGeomx0FWYEdnWc8(dwS0HdlUwZci8XS87(ZsQdeHzbVgILFNsWIpuHUNLH6dH3jqwSStflXyocQGlmlaydvXkbl7oMfnHXS87EXcYybtbmldL6xDfkwGdl)oXcqjMZlwux9olhMfxfUEwEilDxRzb27Sahw8kblOFqFryILdZIRcxplpKfc5r3q2Bi8jxEkzVbc)8qXW6gkLQhB)2Xgz2w1EJkxvtG2X0EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1IfRzrD17gkOVimLXqTpMvelkyXAwux9UHc6lctz9Q8XSIyPnlnnS8UMQ3GHA8FbYqLRQjq7nqchMl6pyzVHgybE)blw(D)zjStbGWSCDwsaxS4dXcC94dKyHc6lctS8qwGLoblGWNLFNgIf4WYHQGdXYVFywSC)olBqn(VazVHWNC5PK9gi8ZW1Jpqktb9fHj73o2ahBRAVrLRQjq7yAV5H)GL9wkew9Bi7TWCpnNBVnuFi8URQjwuWslwux9UHc6lctzmu7JzOu)kmlXZYqP(vywAAyrD17gkOVimL1RYhZqP(vywINLHs9RWS00WccFoxvtgq4NHRhFGuMc6lctS0MffSmuFi8URQjwuWY7dk6n)Ls5hMbpIL4zrzaYIcw8OCyNcaXIcwq4Z5QAYac)8qXW6gkLQhBVfse0u(9bf9y7yRS9BhBaTTvT3OYv1eODmT38WFWYEdVQ(nK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmlnnSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywAAybHpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmazrblEuoStbGyrbli85CvnzaHFEOyyDdLs1JT3cjcAk)(GIESDSv2(TJnGW2Q2Bu5QAc0oM2BE4pyzVHFsR9j31(q2BH5EAo3EBO(q4DxvtSOGLwSOU6Ddf0xeMYyO2hZqP(vywINLHs9RWS00WI6Q3nuqFrykRxLpMHs9RWSepldL6xHzPPHfe(CUQMmGWpdxp(aPmf0xeMyPnlkyzO(q4DxvtSOGL3hu0B(lLYpmdEelXZIYahwuWIhLd7uaiwuWccFoxvtgq4Nhkgw3qPu9y7TqIGMYVpOOhBhBLTF7yJuSTQ9gvUQMaTJP9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7naaMybadgBwGflbqwSC)oC9Se8OORqzVfM7P5C7npkh2Paq2VDSvojBRAVrLRQjq7yAV5H)GL9gLgbTqtwfwG2BGeomx0FWYEdaGjwaUFf4qGSSfDZ9ywSC)olELGfnSqXcvWfQDw0o(VcflOFqFryIfVaz5NeS8qw0xrSCplRiwSC)olaYLg7dlEbYcAIlsSYkyVfM7P5C7TwS0If1vVBOG(IWugd1(ygk1VcZs8SOCsS00WI6Q3nuqFrykRxLpMHs9RWSeplkNelTzrblbiudcTuMGNVkygk1VcZs8SeNKyrblTyrD17MO5sHd456SpbVUqoAPX(yq46fXcGzbGOxsS00WI1SmRI6WbfzIMlfoGNRZ(e86c5OLg7JHIH1ffrGS0ML2S00WI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIL4vIfacOtILMgwcqOgeAPmbpFvWmKdMGffS44FCDocAHgwINfKss2VDSvwzBRAVrLRQjq7yAVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3SMfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcwAXslwcqOgeAPmuAuIHCDgoGLxbYmuQFfMfaZIYahanlaJLwSOSYSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWcfdRlkIanuAuIHCDgoGLxbIL2S00WIJ)X15iOfAyjELybPKelkyPflwZY7AQEtFnjYWEM0RImu5QAcKLMgwux9Uj45RcgW14)blwINLaeQbHwktFnjYWEM0RImdL6xHzbySaiyPnlkybHpNRQjZVpNwNXebenzl(9SOGLwSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelnnSynlbicQ86naLyoVyPnlky59bf9M)sP8dZGhXs8SOU6DtWZxfmGRX)dwSa8SKKbqZstdlQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWILMgwcqeu51BQd1(N7oXstdlQRE3OQHqq9c)MvelkyrD17gvnecQx43muQFfMfaZI6Q3nbpFvWaUg)pyXcWyPflifwaEwMvrD4GImrZLchWZ1zFcEDHC0sJ9XqXW6IIiqwAZsBwuWI1SOU6DtWZxfmRiwuWslwSMLaebvE9M6qT)5UtS00Wsac1GqlLjaleqGO8VtzC0n3JnRiwAAyrfIXSOGL(HA)ZdL6xHzbWSeGqni0szcWcbeik)7ughDZ9yZqP(vywaglahwAAyPFO2)8qP(vywqQSOmGijwamlQRE3e88vbd4A8)GflTT3ajCyUO)GL9gaatSGM4IeRScSy5(DwqdSqabIqcW9RahcKLTOBUhZIxGSacl09SarqJL5EIfa5sJ9Hf4WILDQyjMAieuVWplwGlnileYJUHyrL6WHybnXfjwzfyHqE0ne2EdHp5Ytj7TayoalW7pyLXV9BhBLbOTvT3OYv1eODmT38WFWYEBCeubx4CFOkwjS3ajCyUO)GL9gaatS87elX4P63tmSy5(DwCwqtCrIvwbw(D)z5Wf6Ew6dmLfa5sJ9XElm3tZ52BQRE3e88vbZqP(vywINfLrglnnSOU6DtWZxfmGRX)dwSaywItsSOGfe(CUQMmbWCawG3FWkJF73o2khhBRAVrLRQjq7yAVfM7P5C7ne(CUQMmbWCawG3FWkJFwuWslwSMf1vVBcE(QGbCn(FWIL4zjojXstdlwZsaIGkVEdcQ(9edlTzPPHf1vVBghbvWfo3hQIvcZkIffSOU6DZ4iOcUW5(qvSsygk1VcZcGzbPWcWyjalW19MOHchMYU(qvPu9M)sPmcxViwaglTyXAwux9UrvdHG6f(nRiwuWI1S8UMQ3GFF0Wb0qLRQjqwABV5H)GL9wG0e(pxND9HQsP6TF7yRm6zBv7nQCvnbAht7TWCpnNBVHWNZv1KjaMdWc8(dwz8BV5H)GL92vbFk)pyz)2XwzKzBv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9M1SeGqni0szcE(QGzihmblnnSynli85CvnzcWcbeikds4evGffSeGiOYR3uhQ9p3DILMgwaN1bAkyoaIT3ajCyUO)GL9wmEFoxvtSSWeilWIfx903FeMLF3FwS41ZYdzrLyb7iiqw6WHf0exKyLvGfmKLF3Fw(Dkbl(q1ZIfh)eila3SWplQuhoel)oLAVHWNC5PK9g2rq5oCYbpFvW(TJTYahBRAVrLRQjq7yAV5H)GL9wFnjYWEM0RIS3ajCyUO)GL9gaatywaWGOplxNLRyXlwq)G(IWelEbYYphHz5HSOVIy5EwwrSy5(DwaKln2h0YcAIlsSYkWIxGSexqp6peelBw8j1Elm3tZ52BuqFryYCv2ReSOGfpkh2PaqSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaIEjXIcwAXci8noOh9hckJT4tAg0tDuK5VaqxHILMgwSMLaebvE9MIcdudhqwAZIcwq4Z5QAYGDeuUdNCWZxfyrblTyrD17MXrqfCHZ9HQyLWmuQFfMfaZcsHfaelTybzSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsB73o2kdOTTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEdaGjwaWx0VZY27t31AwIgyaZY1zz79P7AnlhUq3ZYkYElm3tZ52BQRE3al63X5iAcu0FWYSIyrblQRE3GFF6UwBgQpeE3v1K9BhBLbe2w1EJkxvtG2X0Elm3tZ52BQRE3GFF0Wb0muQFfMfaZcYyrblTyrD17gkOVimLXqTpMHs9RWSepliJLMgwux9UHc6lctz9Q8XmuQFfML4zbzS0MffS44FCDocAHgwINfKss2BE4pyzVf8kq6S6Q3T3ux9EU8uYEd)(OHdO9BhBLrk2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVfJwPrywIlgqYIk1HdXcAGfciqell8vOy53jwqdSqabIyjalW7pyXYdzjStbGy56SGgyHaceXYHzXd)Y16eS4QW1ZYdzrLyj443Elm3tZ52BbicQ86n1HA)ZDNyrbli85CvnzcWcbeikds4evGffSeGqni0szcWcbeik)7ughDZ9yZqP(vywamliJffSynlGZ6anfmhaXSOGfkOVimzUk7vcwuWIJ)X15iOfAyjEwqVKSF7ydWKSTQ9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEdaGjw2EF6UwZIL73zz7jT2hwIrZ1Fw8cKLcYY27JgoGOLfl7uXsbzz79P7AnlhMLveAzjbCXIpelxXIvSkFyb9d6lctS0HdlacGHPaMf4WYdzjAGbwaKln2hwSStflUkebXcsjjwIlgqYcCyXbJ8)qqSGT4tkl7oMfabWWuaZYqP(vxHIf4WYHz5kw66d1(Byj2WNy539NLvbsdl)oXc2tjwcWc8(dwywUhDywaJWSu06hxZYdzz79P7AnlGR5kuSeJ5iOcUWSaGnufReOLfl7uXsc4cDGSG)tRzHkqwwrSy5(DwqkjbmhhXshoS87elAh)SGsdvDn2yVfM7P5C7T31u9g8tATpzW56VHkxvtGSOGfRz5DnvVb)(OHdOHkxvtGSOGf1vVBWVpDxRnd1hcV7QAIffS0If1vVBOG(IWuwVkFmdL6xHzjEwaeSOGfkOVimzUkRxLpSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaISKyPPHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelXRelaezjXIcwC8pUohbTqdlXZcsjjwAAybe(gh0J(dbLXw8jnd6PokYmuQFfML4zbqWstdlE4pyzCqp6peugBXN0mON6OiZv5U(qT)S0MffSeGqni0szcE(QGzOu)kmlXZIYjz)2XgGkBBv7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9gaatSS9(GxdkIfa8f97SenWaMfVazbCLgXsCXaswSStflOjUiXkRalWHLFNyjgpv)EIHf1vVZYHzXvHRNLhYs31AwG9olWHLeWf6azj4rSexmG0Elm3tZ52BQRE3al63X5GM8jJ4WhSmRiwAAyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwAAyrD17MGNVkywrSOGLwSOU6DZ4iOcUW5(qvSsygk1VcZcGzbva0K6iNfGNLaDAwAXIJ)X15iOfAybjSeNKyPnlaJL4WcWZY7AQEtrwYPqyzOYv1eilkyXAwMvrD4GIm4R6lDEpb(P5CdvUQMazrblQRE3mocQGlCUpufReMvelnnSOU6DtWZxfmdL6xHzbWSGkaAsDKZcWZsGonlTyXX)46Ce0cnSGewItsS0MLMgwux9UzCeubx4CFOkwjY4R6lDEpb(P5CZkILMgwAXI6Q3nJJGk4cN7dvXkHzOu)kmlaMfp8hSm43N(nKHqofwpL)lLyrbl4isRZ7o(jwamljzqpwAAyrD17MXrqfCHZ9HQyLWmuQFfMfaZIh(dwglJ)7gc5uy9u(VuILMgwq4Z5QAYCXayoalW7pyXIcwcqOgeAPmxHdZ6DvnLJHLx)kndsiUazgYbtWIcwOyyDrreO5kCywVRQPCmS86xPzqcXfiwAZIcwux9UzCeubx4CFOkwjmRiwAAyXAwux9UzCeubx4CFOkwjmRiwuWI1SeGqni0szghbvWfo3hQIvcZqoycwAAyXAwcqeu51Bqq1VNyyPnlnnS44FCDocAHgwINfKssSOGfkOVimzUk7vc73o2aeG2w1EJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzVz1jblpKLuhiILFNyrLWplWolBVpA4aYIAcwWVha6kuSCplRiwIH1fasNGLRyXReSG(b9fHjwuxplaYLg7dlhUEwCv46z5HSOsSenWqGaT3cZ90CU927AQEd(9rdhqdvUQMazrblwZYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPflQRE3GFF0Wb0SIyPPHfh)JRZrql0Ws8SGusIL2SOGf1vVBWVpA4aAWVhaIfaZsCyrblTyrD17gkOVimLXqTpMvelnnSOU6Ddf0xeMY6v5JzfXsBwuWI6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lIfaZcab0jXIcwAXsac1GqlLj45RcMHs9RWSeplkNelnnSynli85CvnzcWcbeikds4evGffSeGiOYR3uhQ9p3DIL22VDSbyCSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEJc6lctMRY6v5dlaplacwqclE4pyzWVp9BidHCkSEk)xkXcWyXAwOG(IWK5QSEv(WcWZslwaoSamwExt1BWWLod75FNYD4q43qLRQjqwaEwIdlTzbjS4H)GLXY4)UHqofwpL)lLybySKKb9qgliHfCeP15Dh)elaJLKmiJfGNL31u9MY)1q4SQR9kqgQCvnbAVbs4WCr)bl7n0h)xQ)eMLDOfwsxHDwIlgqYIpelO8RiqwIOHfmfGfO9gcFYLNs2BoocqsZgfSF7ydq0Z2Q2Bu5QAc0oM2BE4pyzVHFFWRbfzVbs4WCr)bl7Ty0knILT3h8AqrSCflolaAGHPalBqTpSG(b9fHj0YciSq3ZIMEwUNLObgybqU0yFyP1V7plhMLDVa1eilQjyHUFNgw(DILT3NUR1SOVIyboS87elXfdiJhPKel6Riw6WHLT3h8AqrTrllGWcDplqe0yzUNyXlwaWx0VZs0adS4filA6z53jwCvicIf9vel7EbQjw2EF0Wb0Elm3tZ52BwZYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPflQRE3enxkCapxN9j41fYrln2hdcxViwamlaeqNelnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaqKLelky5DnvVb)Kw7tgCU(BOYv1eilTzrblTyHc6lctMRYyO2hwuWIJ)X15iOfAybySGWNZv1KXXrasA2OalaplQRE3qb9fHPmgQ9XmuQFfMfGXci8n91Kid7zsVkY8xaiCEOu)kwaEwaObzSeplaIKyPPHfkOVimzUkRxLpSOGfh)JRZrql0WcWybHpNRQjJJJaK0SrbwaEwux9UHc6lctz9Q8XmuQFfMfGXci8n91Kid7zsVkY8xaiCEOu)kwaEwaObzSepliLKyPnlkyXAwux9Ubw0VJZr0eOO)GLzfXIcwSML31u9g87JgoGgQCvnbYIcwAXsac1GqlLj45RcMHs9RWSeplaAwAAybdxA1Ran)(CADgteq0yOYv1eilkyrD17MFFoToJjciAm43daXcGzjoXHfaelTyzwf1HdkYGVQV059e4NMZnu5QAcKfGNfKXsBwuWs)qT)5Hs9RWSeplkNusSOGL(HA)ZdL6xHzbWSaWKsIL2SOGLwSeGqni0sza6kWHaZ4OBUhBgk1VcZs8SaOzPPHfRzjarqLxVbOeZ5flTTF7ydqKzBv7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzVbaWela4GWcZYvSyfRYhwq)G(IWelEbYc2rqSeJRR7adaBP1SaGdclw6WHf0exKyLvGfVazb4(vGdbYc6NgbTqtkvV9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelnnS0ILWUpOimlkXcazrbldf29bfL)lLybWSGmwAZstdlHDFqrywuIL4WsBwuWIhLd7uaiwuWccFoxvtgSJGYD4KdE(QG9BhBacCSTQ9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelkyXAwcqeu51BakXCEXstdlTyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwuWsaIGkVEdqjMZlwAZstdlTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS00WI6Q3nbpFvWSIyPnlkyXJYHDkaelkybHpNRQjd2rq5oCYbpFvGffS0If1vVBghbvWfo3hQIvcZqP(vywamlTybzSaGybGSa8SmRI6WbfzWx1x68Ec8tZ5gQCvnbYsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwZI6Q3nJJGk4cN7dvXkHzfXsB7np8hSS32DDpNcHL9BhBacOTTQ9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYPW6P8FPelkyXAwcqeu51BakXCEXstdlTyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwuWsaIGkVEdqjMZlwAZstdlTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamliJL2S00Wsy3hueMfLyjoS00WI6Q3nbpFvWSIyPnlkyXJYHDkaelkybHpNRQjd2rq5oCYbpFvGffS0If1vVBghbvWfo3hQIvcZqP(vywamliJffSOU6DZ4iOcUW5(qvSsywrSOGfRzzwf1HdkYGVQV059e4NMZnu5QAcKLMgwSMf1vVBghbvWfo3hQIvcZkIL22BE4pyzV1xADofcl73o2aeqyBv7nQCvnbAht7nqchMl6pyzVbaWelaxq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF7ydqKITvT3OYv1eODmT38WFWYEd)(0VHS3ajCyUO)GL9gaatSS9(0VHy5HSenWalBqTpSG(b9fHj0YcAIlsSYkWYUJzrtyml)LsS87EXIZcW14)oleYPW6jw0u)zboSalDcwSIv5dlOFqFryILdZYkYElm3tZ52BuqFryYCvwVkFyPPHfkOVimzWqTp5Iq(ZstdluqFryY4vICri)zPPHLwSOU6DJfFMdozypt6vrMvelnnSGJiToV74NybWSKKb9qglkyXAwcqeu51Bqq1VNyyPPHfCeP15Dh)elaMLKmOhlkyjarqLxVbbv)EIHL2SOGf1vVBOG(IWuwVkFmRiwAAyPflQRE3e88vbZqP(vywamlE4pyzSm(VBiKtH1t5)sjwuWI6Q3nbpFvWSIyPT9Bh74KKTvT3OYv1eODmT3ajCyUO)GL9gaatSaCn(VZc83PXYHjwSSFHDwomlxXYgu7dlOFqFrycTSGM4IeRScSahwEilrdmWIvSkFyb9d6lct2BE4pyzVzz8F3(TJDCu22Q2Bu5QAc0oM2BGeomx0FWYEdaZ16FFw2BE4pyzVnRk7H)GvwF43EtF4pxEkzV1DT(3NL9B)2BrdfGPQ(BBv7yRSTvT38WFWYEdORahcmJJU5ES9gvUQMaTJP9BhBaABv7nQCvnbAht7nyK9gME7np8hSS3q4Z5QAYEdHRxK9ws2BGeomx0FWYEZQ7eli85CvnXYHzbtplpKLKyXY97SuqwWV)SalwwyILFUci6XOLfLzXYovS87el9BWplWIy5WSalwwycTSaqwUol)oXcMcWcKLdZIxGSehwUolQWFNfFi7ne(KlpLS3GvEHP8pxbe92VDSJJTvT3OYv1eODmT3Gr2BoiO9Mh(dw2Bi85CvnzVHW1lYEtz7TWCpnNBV9ZvarV5v2S748ctz1vVZIcw(5kGO38kBcqOgeAPmGRX)dwSOGfRz5NRaIEZRS5WMhMszypNcl8pWfohGf(Nv4pyHT3q4tU8uYEdw5fMY)Cfq0B)2Xg9STQ9gvUQMaTJP9gmYEZbbT38WFWYEdHpNRQj7neUEr2Ba0Elm3tZ52B)Cfq0BEaA2DCEHPS6Q3zrbl)Cfq0BEaAcqOgeAPmGRX)dwSOGfRz5NRaIEZdqZHnpmLYWEofw4FGlCoal8pRWFWcBVHWNC5PK9gSYlmL)5kGO3(TJnYSTQ9gvUQMaTJP9gmYEdtV9Mh(dw2Bi85CvnzVHWNC5PK9gSYlmL)5kGO3Elm3tZ52BumSUOic0CfomR3v1uogwE9R0miH4celnnSqXW6IIiqdLgLyixNHdy5vGyPPHfkgwxuebAWWLwt)FfQ8SutyVbs4WCr)bl7nRUtyILFUci6XS4dXsbFw81dt9)cUwNGfq6PWtGS4ywGfllmXc(9NLFUci6XgwyzJEwq4Z5QAILhYc6XIJz53PeS4AmKLIiqwWru4Cnl7EbQVcLXEdHRxK9g6z)2Xg4yBv7np8hSS3sHWcORYD4KAVrLRQjq7yA)2XgqBBv7nQCvnbAht7np8hSS3Sm(VBVfM7P5C7TwSqb9fHjJEv(Klc5plnnSqb9fHjZvzmu7dlnnSqb9fHjZvzv4VZstdluqFryY4vICri)zPT9M(kkhaT3uoj73(TF7ne0GpyzhBaMeavojanarp7nl(uxHcBVbCf3ySyBLXg4waflSy1DILlncoplD4Wc6Grurd6yzOyyDdbYcgMsS4RhM6pbYsy3lue2WjBfxrSaqaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjBfxrSehaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjZjdCf3ySyBLXg4waflSy1DILlncoplD4Wc6aPUV0p6yzOyyDdbYcgMsS4RhM6pbYsy3lue2WjBfxrSGmaflObwiO5jqw2Uu0Wcor9oYzbPYYdzXkwolGhIdFWIfyen(dhwAHK2S0szK32WjBfxrSGmaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjBfxrSaCauSGgyHGMNazbDZQOoCqrgai6y5HSGUzvuhoOida0qLRQjq0XslLrEBdNSvCfXcGgqXcAGfcAEcKLTlfnSGtuVJCwqQS8qwSILZc4H4WhSybgrJ)WHLwiPnlTaiYBB4KTIRiwaeakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHt2kUIybqaOybnWcbnpbYc6(5kGO3OSbaIowEilO7NRaIEZRSbaIowAbqK32WjBfxrSaiauSGgyHGMNazbD)Cfq0BaObaIowEilO7NRaIEZdqdaeDS0cGiVTHt2kUIybPaOybnWcbnpbYc6MvrD4GImaq0XYdzbDZQOoCqrgaOHkxvtGOJLwkJ82gozR4kIfLtcqXcAGfcAEcKf0nRI6WbfzaGOJLhYc6MvrD4GImaqdvUQMarhlTug5TnCYwXvelkRmGIf0ale08eilOBwf1HdkYaarhlpKf0nRI6WbfzaGgQCvnbIowAPmYBB4KTIRiwugGakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHt2kUIyrz0dqXcAGfcAEcKf0nRI6WbfzaGOJLhYc6MvrD4GImaqdvUQMarhlTug5TnCYwXvelkJmaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0cGiVTHt2kUIyrzKbOybnWcbnpbYc6(5kGO3OSbaIowEilO7NRaIEZRSbaIowAbqK32WjBfxrSOmYauSGgyHGMNazbD)Cfq0BaObaIowEilO7NRaIEZdqdaeDS0szK32WjBfxrSOmWbqXcAGfcAEcKf0nRI6WbfzaGOJLhYc6MvrD4GImaqdvUQMarhlTaiYBB4KTIRiwug4aOybnWcbnpbYc6(5kGO3OSbaIowEilO7NRaIEZRSbaIowAPmYBB4KTIRiwug4aOybnWcbnpbYc6(5kGO3aqdaeDS8qwq3pxbe9MhGgai6yPfarEBdNmNmWvCJXITvgBGBbuSWIv3jwU0i48S0HdlOlAOamv1F0XYqXW6gcKfmmLyXxpm1FcKLWUxOiSHt2kUIyjoakwqdSqqZtGSGUFUci6nkBaGOJLhYc6(5kGO38kBaGOJLwXb5TnCYwXvelOhGIf0ale08eilO7NRaIEdanaq0XYdzbD)Cfq0BEaAaGOJLwXb5TnCYCYaxXngl2wzSbUfqXclwDNy5sJGZZshoSGohsOJLHIH1neilyykXIVEyQ)eilHDVqrydNSvCfXIYakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yXFwqFa8wblTug5TnCYwXvelXbqXcAGfcAEcKf0nRI6WbfzaGOJLhYc6MvrD4GImaqdvUQMarhlTug5TnCYwXvelaAaflObwiO5jqw2Uu0Wcor9oYzbPIuz5HSyflNLui4sVWSaJOXF4WslKABwAPmYBB4KTIRiwa0akwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPfarEBdNSvCfXcGaqXcAGfcAEcKLTlfnSGtuVJCwqQivwEilwXYzjfcU0lmlWiA8hoS0cP2MLwkJ82gozR4kIfabGIf0ale08eilOBwf1HdkYaarhlpKf0nRI6WbfzaGgQCvnbIowAPmYBB4KTIRiwqkakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHt2kUIyr5KauSGgyHGMNazz7srdl4e17iNfKklpKfRy5SaEio8blwGr04pCyPfsAZslaI82gozR4kIfLJdGIf0ale08eilBxkAybNOEh5SGuz5HSyflNfWdXHpyXcmIg)HdlTqsBwAPmYBB4KTIRiwaysakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHt2kUIybGaeqXcAGfcAEcKLTlfnSGtuVJCwqQS8qwSILZc4H4WhSybgrJ)WHLwiPnlTug5TnCYwXvelae9auSGgyHGMNazz7srdl4e17iNfKklpKfRy5SaEio8blwGr04pCyPfsAZslaI82gozR4kIfaIEakwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHt2kUIybGahaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjBfxrSaqanGIf0ale08eilOBwf1HdkYaarhlpKf0nRI6WbfzaGgQCvnbIowAPmYBB4KTIRiwaisbqXcAGfcAEcKLTlfnSGtuVJCwqQS8qwSILZc4H4WhSybgrJ)WHLwiPnlTaiYBB4KTIRiwItsakwqdSqqZtGSSDPOHfCI6DKZcsLLhYIvSCwapeh(GflWiA8hoS0cjTzPLYiVTHtMtg4kUXyX2kJnWTakwyXQ7elxAeCEw6WHf01DT(3Nf6yzOyyDdbYcgMsS4RhM6pbYsy3lue2WjBfxrSaqaflObwiO5jqw2Uu0Wcor9oYzbPYYdzXkwolGhIdFWIfyen(dhwAHK2S0szK32WjZjdCf3ySyBLXg4waflSy1DILlncoplD4Wc6Wp6yzOyyDdbYcgMsS4RhM6pbYsy3lue2WjBfxrSOmGIf0ale08eilOBwf1HdkYaarhlpKf0nRI6WbfzaGgQCvnbIowAPmYBB4KTIRiwIdGIf0ale08eilOBwf1HdkYaarhlpKf0nRI6WbfzaGgQCvnbIowAPmYBB4KTIRiwuwzaflObwiO5jqw2Uu0Wcor9oYzbPIuz5HSyflNLui4sVWSaJOXF4WslKABwAPmYBB4KTIRiwuwzaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjBfxrSOmWbqXcAGfcAEcKf0nRI6WbfzaGOJLhYc6MvrD4GImaqdvUQMarhlTug5TnCYwXvelauzaflObwiO5jqw2Uu0Wcor9oYzbPYYdzXkwolGhIdFWIfyen(dhwAHK2S0cGiVTHt2kUIybGkdOybnWcbnpbYc6MvrD4GImaq0XYdzbDZQOoCqrgaOHkxvtGOJLwkJ82gozR4kIfacqaflObwiO5jqwq3SkQdhuKbaIowEilOBwf1HdkYaanu5QAceDS0szK32WjBfxrSaW4aOybnWcbnpbYY2LIgwWjQ3rolivwEilwXYzb8qC4dwSaJOXF4WslK0MLwXb5TnCYwXvelae9auSGgyHGMNazbDZQOoCqrgai6y5HSGUzvuhoOida0qLRQjq0XslaI82gozR4kIfacCauSGgyHGMNazbDZQOoCqrgai6y5HSGUzvuhoOida0qLRQjq0XslLrEBdNSvCfXcab0akwqdSqqZtGSGUzvuhoOidaeDS8qwq3SkQdhuKbaAOYv1ei6yPLYiVTHtMtg4kUXyX2kJnWTakwyXQ7elxAeCEw6WHf0Pc9hDSmumSUHazbdtjw81dt9NazjS7fkcB4KTIRiwugqaOybnWcbnpbYY2LIgwWjQ3rolivwEilwXYzb8qC4dwSaJOXF4WslK0MLwXb5TnCYwXvelkJuauSGgyHGMNazz7srdl4e17iNfKklpKfRy5SaEio8blwGr04pCyPfsAZslLrEBdNmNSvMgbNNazbqZIh(dwSOp8JnCY2BrdSFAYEdPrAwIPR9kqSeJM1bYjJ0inljV0jybGidTSaWKaOYCYCYinsZcA29cfHbuCYinsZcaIL4ccsGSSb1(Wsmjp1WjJ0inlaiwqZUxOiqwEFqrF(6SeCmHz5HSese0u(9bf9ydNmsJ0SaGyjgJsHiiqwwvrbcJ9jbli85CvnHzP1zidAzjAiez87dEnOiwaqXZs0qim43h8AqrTnCYinsZcaIL4IaEGSenuWX)vOyb4A8FNLRZY9OdZYVtSyzGfkwq)G(IWKHtgPrAwaqSaGZbIybnWcbeiILFNyzl6M7XS4SOV)1elPWHyPRjKFQAILwxNLeWfl7oyHUNL97z5EwWx6s)ErWfwNGfl3VZsmbWhxRYcWybnKMW)5AwIR(qvPu9OLL7rhilyGUO2gozKgPzbaXcaohiILui(zbD9d1(Nhk1VcJowWbQ85Gyw8OiDcwEilQqmML(HA)XSalDcdNmsJ0SaGyXQd5plwfMsSa7SetTVZsm1(olXu77S4ywCwWru4Cnl)Cfq0B4KrAKMfaela4JOIgwADgYGwwaUg)3rllaxJ)7OLLT3N(nuBwsDqILu4qSme(0hvplpKfYh9rdlbyQQ)ai87ZB4K5KrAKML4wf89NazjMU2RaXsCbKwblbVyrLyPdxfil(ZY()ryafsqIQR9kqai8LgmOUFFPAoisIPR9kqaOTlfnijf0S)P6yC2pnPKQR9kqMh5pNmNSh(dwyt0qbyQQ)kb0vGdbMXr3CpMtgPzXQ7eli85CvnXYHzbtplpKLKyXY97SuqwWV)SalwwyILFUci6XOLfLzXYovS87el9BWplWIy5WSalwwycTSaqwUol)oXcMcWcKLdZIxGSehwUolQWFNfFiozp8hSWMOHcWuv)bMsibHpNRQj0wEkPeSYlmL)5kGOhTiC9Iukjozp8hSWMOHcWuv)bMsibHpNRQj0wEkPeSYlmL)5kGOhTWiLCqq0IW1lsjLr71v6NRaIEJYMDhNxykRU6Df)Cfq0Bu2eGqni0szaxJ)hSuy9pxbe9gLnh28Wukd75uyH)bUW5aSW)Sc)blmNSh(dwyt0qbyQQ)atjKGWNZv1eAlpLucw5fMY)Cfq0JwyKsoiiAr46fPear71v6NRaIEdan7ooVWuwD17k(5kGO3aqtac1GqlLbCn(FWsH1)Cfq0BaO5WMhMszypNcl8pWfohGf(Nv4pyH5KrAwS6oHjw(5kGOhZIpelf8zXxpm1)l4ADcwaPNcpbYIJzbwSSWel43Fw(5kGOhByHLn6zbHpNRQjwEilOhloMLFNsWIRXqwkIazbhrHZ1SS7fO(kugozp8hSWMOHcWuv)bMsibHpNRQj0wEkPeSYlmL)5kGOhTWiLW0JweUErkHEO96krXW6IIiqZv4WSExvt5yy51VsZGeIlqnnumSUOic0qPrjgY1z4awEfOMgkgwxuebAWWLwt)FfQ8SutWj7H)Gf2enuaMQ6pWucjPqyb0v5oCs5K9WFWcBIgkatv9hykHelJ)7OvFfLdGkPCsO96k1Ic6lctg9Q8jxeY)MgkOVimzUkJHAFAAOG(IWK5QSk83BAOG(IWKXRe5Iq(3MtMtgPzbqouWXplaKfGRX)Dw8cKfNLT3h8AqrSalw2SklwUFNLyFO2FwaWCIfVazjMW4AvwGdlBVp9BiwG)onwomXj7H)Gf2aJOIgGPesSm(VJ2RRulkOVimz0RYNCri)BAOG(IWK5QmgQ9PPHc6lctMRYQWFVPHc6lctgVsKlc5FBfrdHWOSXY4)UcRJgcHbGglJ)7CYE4pyHnWiQObykHe87t)gcT6ROCaujKH2RRK1ZQOoCqrgvx7vGYWE2168VFfkCtJ1bicQ86n1HA)ZDNAASghrAD(9bf9yd(9P7ATsk30y97AQEt5)AiCw11EfidvUQMaBAArb9fHjdgQ9jxeY)MgkOVimzUkRxLpnnuqFryYCvwf(7nnuqFryY4vICri)BZj7H)Gf2aJOIgGPesWVp41GIqR(kkhavczO96knRI6WbfzuDTxbkd7zxRZ)(vOWkcqeu51BQd1(N7oPahrAD(9bf9yd(9P7ATskZjZjJ0inlOpYPW6jqwie0KGL)sjw(DIfp8WHLdZIJWpTRQjdNSh(dwyLWqTpzvYt5K9WFWcdmLqsW16Sh(dwz9HF0wEkPemIkAq71v6VucWTaiW7H)GLXY4)Uj44p)xkbmp8hSm43N(nKj44p)xk1MtgPzzJEmlXfI(SalwIdWyXY97W1Zc4C9NfVazXY97SS9(OHdilEbYcabglWFNglhM4K9WFWcdmLqccFoxvtOT8usPdNDiHweUErkHJiTo)(GIESb)(0DToELv0Y631u9g87JgoGgQCvnb208UMQ3GFsR9jdox)nu5QAcSDtdoI0687dk6Xg87t3164biNmsZYg9ywcAYrqSyzNkw2EF63qSe8IL97zbGaJL3hu0JzXY(f2z5WSmKMq41ZshoS87elOFqFryILhYIkXs0qDAgcKfVazXY(f2zPFAnnS8qwco(5K9WFWcdmLqccFoxvtOT8usPdNdAYrqOfHRxKs4isRZVpOOhBWVp9BO4vMtgPzbaGjwIjnyAa6kuSy5(DwqtCrIvwbwGdlE)PHf0aleqGiwUIf0exKyLvGt2d)blmWucjQ0GPbORqH2RRuRwwhGiOYR3uhQ9p3DQPX6aeQbHwktawiGar5FNY4OBUhBwrTvOU6DtWZxfmdL6xHJxzKPqD17MXrqfCHZ9HQyLWmuQFfgWONcRdqeu51Bqq1VNyAAcqeu51Bqq1VNyuOU6DtWZxfmRifQRE3mocQGlCUpufReMvKIwQRE3mocQGlCUpufReMHs9RWawzLbqid4NvrD4GIm4R6lDEpb(P58Mg1vVBcE(QGzOu)kmGvw5MgLrQ4isRZ7o(jaRSbziRDBfOcGMHs9RWXNeNmsZcGe(Sy5(DwCwqtCrIvwbw(D)z5Wf6EwCwaKln2hwIgyGf4WILDQy53jw6hQ9NLdZIRcxplpKfQa5K9WFWcdmLqse8pyH2RRK6Q3nbpFvWmuQFfoELrMIwwpRI6WbfzWx1x68Ec8tZ5nnQRE3mocQGlCUpufReMHs9RWawzanacGaV6Q3nQAieuVWVzfPqD17MXrqfCHZ9HQyLWSIA30OcXyf9d1(Nhk1VcdyaImozKMf046Ws7pHzXYo970WYcFfkwqdSqabIyPGwyXYP1S4An0cljGlwEil4)0Awco(z53jwWEkXINcx1ZcSZcAGfciqeWqtCrIvwbwco(XCYE4pyHbMsibHpNRQj0wEkPuawiGarzqcNOcOfHRxKsb60TA1pu7FEOu)kmaszKbGcqOgeAPmbpFvWmuQFfUnsvzarsTvkqNUvR(HA)ZdL6xHbqkJmauac1GqlLjaleqGO8VtzC0n3JnGRX)dwaOaeQbHwktawiGar5FNY4OBUhBgk1Vc3gPQmGiP2kSE8dmtiO6noii2qi)WpUPjaHAqOLYe88vbZqP(v44V6PjcQ9NaZ9d1(Nhk1Vc30eGqni0szcWcbeik)7ughDZ9yZqP(v44V6PjcQ9NaZ9d1(Nhk1VcdGuoPMgRdqeu51BQd1(N7oXjJ0SaaWeilpKfqs7jy53jwwyhfXcSZcAIlsSYkWILDQyzHVcflGWLQMybwSSWelEbYs0qiO6zzHDuelw2PIfVyXbbzHqq1ZYHzXvHRNLhYc4rCYE4pyHbMsibHpNRQj0wEkPuamhGf49hSqlcxViLA1pu7FEOu)kC8kJSMMXpWmHGQ34GGyZvXJSKAROvRwumSUOic0qPrjgY1z4awEfifTcqOgeAPmuAuIHCDgoGLxbYmuQFfgWkdCsQPjarqLxVbbv)EIrrac1GqlLHsJsmKRZWbS8kqMHs9RWawzGdGgyTuwzGFwf1HdkYGVQV059e4NMZB3wH1biudcTugknkXqUodhWYRazgYbt0UPHIH1ffrGgmCP10)xHkpl1ekAzDaIGkVEtDO2)C3PMMaeQbHwkdgU0A6)RqLNLAICCqpKbisszZqP(vyaRSYOx7MMwbiudcTugvAW0a0vOmd5GjAASE8az(bQ1Tv0QffdRlkIanxHdZ6DvnLJHLx)kndsiUaPiaHAqOLYCfomR3v1uogwE9R0miH4cKzihmr7MMwumSUOic0G3DqOfcmdh1mSNF4Ks1RiaHAqOLY8WjLQNaZxHpu7FooidzXbGkBgk1Vc3UPPvle(CUQMmWkVWu(NRaIELuUPbHpNRQjdSYlmL)5kGOxP40wrRFUci6nkBgYbtKdqOgeAPAA(5kGO3OSjaHAqOLYmuQFfo(REAIGA)jWC)qT)5Hs9RWaiLtQDtdcFoxvtgyLxyk)ZvarVsaurRFUci6na0mKdMihGqni0s108ZvarVbGMaeQbHwkZqP(v44V6PjcQ9NaZ9d1(Nhk1VcdGuoP2nni85CvnzGvEHP8pxbe9kLu72TBAcqeu51BakXCE1UPrfIXk6hQ9ppuQFfgWQRE3e88vbd4A8)GfNmsZsmEFoxvtSSWeilpKfqs7jyXReS8ZvarpMfVazjaIzXYovSyXV)kuS0HdlEXc6VI2HZ5SenWaNSh(dwyGPesq4Z5QAcTLNsk97ZP1zmrart2IFpAr46fPK1y4sREfO53NtRZyIaIgdvUQMaBA6hQ9ppuQFfoEaMusnnQqmwr)qT)5Hs9RWagGidyTqVKaqQRE387ZP1zmrarJb)EaiGhGTBAux9U53NtRZyIaIgd(9aqXhhabaQ1SkQdhuKbFvFPZ7jWpnNd8iRnNmsZcaatSG(PrjgY1SaGFalVcelamjmfWSOsD4qS4SGM4IeRScSSWKHt2d)blmWucjlmLVNsrB5PKsuAuIHCDgoGLxbcTxxPaeQbHwktWZxfmdL6xHbmatsrac1GqlLjaleqGO8VtzC0n3JndL6xHbmatsrle(CUQMm)(CADgteq0KT4330OU6DZVpNwNXebeng87bGIpojbSwZQOoCqrg8v9LoVNa)0CoWdCA3wbQaOzOu)kC8j10OcXyf9d1(Nhk1Vcd44aO5KrAwaayILn4sRP)kuSeJTutWcWbtbmlQuhoelolOjUiXkRallmz4K9WFWcdmLqYct57Pu0wEkPegU0A6)RqLNLAc0EDLAfGqni0szcE(QGzOu)kmGbokSoarqLxVbbv)EIrH1bicQ86n1HA)ZDNAAcqeu51BQd1(N7oPiaHAqOLYeGfciqu(3Pmo6M7XMHs9RWag4OOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWmuQFfgWaN2nnbicQ86niO63tmkAz9SkQdhuKbFvFPZ7jWpnNRiaHAqOLYe88vbZqP(vyadCAAux9UzCeubx4CFOkwjmdL6xHbSYOhWAHmGNIH1ffrGMRW)ScpCWzWdXvuwL062kux9UzCeubx4CFOkwjmRO2nnQqmwr)qT)5Hs9RWagGiRPHIH1ffrGgknkXqUodhWYRaPiaHAqOLYqPrjgY1z4awEfiZqP(v44JtsTvGkaAgk1VchFsCYinlXvBXtGzzHjwSYyCeJyXY97SGM4IeRScCYE4pyHbMsibHpNRQj0wEkP0fdG5aSaV)GfAr46fPK6Q3nbpFvWmuQFfoELrMIwwpRI6WbfzWx1x68Ec8tZ5nnQRE3mocQGlCUpufReMHs9RWawjLbiWAfhGxD17gvnecQx43SIAdSwTaeaiKb8QRE3OQHqq9c)MvuBGNIH1ffrGMRW)ScpCWzWdXvuwL062kux9UzCeubx4CFOkwjmRO2nnQqmwr)qT)5Hs9RWagGiRPHIH1ffrGgknkXqUodhWYRaPiaHAqOLYqPrjgY1z4awEfiZqP(vyozp8hSWatjKSWu(EkfTLNskDfomR3v1uogwE9R0miH4ceAVUsi85CvnzUyamhGf49hSuGkaAgk1VchFsCYinlaamXYCO2FwuPoCiwcGyozp8hSWatjKSWu(EkfTLNskH3DqOfcmdh1mSNF4Ks1J2RRuRaeQbHwktWZxfmd5GjuyDaIGkVEtDO2)C3jfi85Cvnz(9506mMiGOjBXVVPjarqLxVPou7FU7KIaeQbHwktawiGar5FNY4OBUhBgYbtOOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWmKdMODBfGW3Gxv)gY8xaORqPOfi8n4N0AFYDTpK5VaqxHQPX631u9g8tATp5U2hYqLRQjWMgCeP153hu0Jn43N(nu8XPTIwGW3KcHv)gY8xaORq1wrle(CUQMmho7qQPzwf1HdkYO6AVcug2ZUwN)9RqHBAC8pUohbTqt8kHusQPrD17gvnecQx43SIAROvac1GqlLrLgmnaDfkZqoyIMgRhpqMFGAD7MgvigROFO2)8qP(vyaJEjXjJ0Sy19dZYHzXzz8FNgwiTRch)jwS4jy5HSK6arS4AnlWILfMyb)(ZYpxbe9ywEilQel6RiqwwrSy5(DwqtCrIvwbw8cKf0aleqGiw8cKLfMy53jwaybYcwdFwGflbqwUolQWFNLFUci6XS4dXcSyzHjwWV)S8ZvarpMt2d)blmWucjlmLVNsXOfRHpwPFUci6vgTxxPwi85CvnzGvEHP8pxbe9wRKYkS(NRaIEdand5GjYbiudcTunnTq4Z5QAYaR8ct5FUci6vs5Mge(CUQMmWkVWu(NRaIELItBfTux9Uj45RcMvKIwwhGiOYR3GGQFpX00OU6DZ4iOcUW5(qvSsygk1VcdSwid4NvrD4GIm4R6lDEpb(P582awPFUci6nkBux9EgCn(FWsH6Q3nJJGk4cN7dvXkHzf10OU6DZ4iOcUW5(qvSsKXx1x68Ec8tZ5Mvu7MMaeQbHwktWZxfmdL6xHbgaJ)NRaIEJYMaeQbHwkd4A8)GLcRvx9Uj45RcMvKIwwhGiOYR3uhQ9p3DQPXAe(CUQMmbyHaceLbjCIk0wH1bicQ86naLyoVAAcqeu51BQd1(N7oPaHpNRQjtawiGarzqcNOckcqOgeAPmbyHaceL)DkJJU5ESzfPW6aeQbHwktWZxfmRifTAPU6Ddf0xeMY6v5JzOu)kC8kNutJ6Q3nuqFrykJHAFmdL6xHJx5KARW6zvuhoOiJQR9kqzyp7AD(3VcfUPPL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9aqkHSMg1vVBuDTxbkd7zxRZ)(vOWzFcErg87bGucq0UDtJ6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrTBA6hQ9ppuQFfgWamPMge(CUQMmWkVWu(NRaIELsQTcubqZqP(v44tIt2d)blmWucjlmLVNsXOfRHpwPFUci6biAVUsTq4Z5QAYaR8ct5FUci6TwjaQW6FUci6nkBgYbtKdqOgeAPAAq4Z5QAYaR8ct5FUci6vcGkAPU6DtWZxfmRifTSoarqLxVbbv)EIPPrD17MXrqfCHZ9HQyLWmuQFfgyTqgWpRI6WbfzWx1x68Ec8tZ5TbSs)Cfq0BaOrD17zW14)blfQRE3mocQGlCUpufReMvutJ6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwrTBAcqOgeAPmbpFvWmuQFfgyam(FUci6na0eGqni0szaxJ)hSuyT6Q3nbpFvWSIu0Y6aebvE9M6qT)5UtnnwJWNZv1KjaleqGOmiHtuH2kSoarqLxVbOeZ5LIwwRU6DtWZxfmROMgRdqeu51Bqq1VNyA30eGiOYR3uhQ9p3DsbcFoxvtMaSqabIYGeorfueGqni0szcWcbeik)7ughDZ9yZksH1biudcTuMGNVkywrkA1sD17gkOVimL1RYhZqP(v44voPMg1vVBOG(IWugd1(ygk1VchVYj1wH1ZQOoCqrgvx7vGYWE2168VFfkCttl1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87bGucznnQRE3O6AVcug2ZUwN)9RqHZ(e8Im43daPeGOD72nnQRE3a0vGdbMP0iOfAsP6ZurdQlwKzf10OcXyf9d1(Nhk1VcdyaMutdcFoxvtgyLxyk)ZvarVsj1wbQaOzOu)kC8jXjJ0SaaWeMfxRzb(70WcSyzHjwUNsXSalwcGCYE4pyHbMsizHP89ukMtgPzjgrHdKyXd)blw0h(zr1XeilWIf89l)pyHenH6WCYE4pyHbMsizwv2d)bRS(WpAlpLuYHeAX)CHxjLr71vcHpNRQjZHZoK4K9WFWcdmLqYSQSh(dwz9HF0wEkPKk0F0I)5cVskJ2RR0SkQdhuKr11EfOmSNDTo)7xHcBOyyDrreiNSh(dwyGPesMvL9WFWkRp8J2YtjLWpNmNmsZcACDyP9NWSyzN(DAy53jwIrd5Pb)d70WI6Q3zXYP1S0DTMfyVZIL73VILFNyPiK)SeC8Zj7H)Gf24qsje(CUQMqB5PKsGd5PzlNwN7UwNH9oAr46fPul1vVB(lLSaNkdoKNQEfinMHs9RWagva0K6ihyjzuUPrD17M)sjlWPYGd5PQxbsJzOu)kmG9WFWYGFF63qgc5uy9u(VucyjzuwrlkOVimzUkRxLpnnuqFryYGHAFYfH8VPHc6lctgVsKlc5F72kux9U5VuYcCQm4qEQ6vG0ywrkMvrD4GIm)LswGtLbhYtvVcKgozKMf046Ws7pHzXYo970WY27dEnOiwomlwGZVZsWX)vOybIGgw2EF63qSCflwXQ8Hf0pOVimXj7H)Gf24qcykHee(CUQMqB5PKshQcoug)(GxdkcTiC9IuYAkOVimzUkJHAFu0chrAD(9bf9yd(9PFdfpYu8UMQ3GHlDg2Z)oL7WHWVHkxvtGnn4isRZVpOOhBWVp9BO4b0T5KrAwaayIf0aleqGiwSStfl(ZIMWyw(DVybzjXsCXasw8cKf9velRiwSC)olOjUiXkRaNSh(dwyJdjGPescWcbeik)7ughDZ9y0EDLSgCwhOPG5aiwrRwi85CvnzcWcbeikds4evqH1biudcTuMGNVkygYbt00OU6DtWZxfmRO2kAPU6Ddf0xeMY6v5JzOu)kC8aNMg1vVBOG(IWugd1(ygk1VchpWPTIwwpRI6WbfzuDTxbkd7zxRZ)(vOWnnQRE3O6AVcug2ZUwN)9RqHZL)RHm43dafFCAAux9Ur11EfOmSNDTo)7xHcN9j4fzWVhak(40UPrfIXk6hQ9ppuQFfgWkNKcRdqOgeAPmbpFvWmKdMOnNmsZcaatSaGnufReSy5(DwqtCrIvwbozp8hSWghsatjKmocQGlCUpufReO96kPU6DtWZxfmdL6xHJxzKXjJ0SaaWelBRQFdXYvSe5fiLEbwGflEL43Vcfl)U)SOpeeMfLrpmfWS4filAcJzXY97SKchIL3hu0JzXlqw8NLFNyHkqwGDwCw2GAFyb9d6lctS4plkJESGPaMf4WIMWywgk1V6kuS4ywEilf8zz3rCfkwEild1hcVZc4AUcflwXQ8Hf0pOVimXj7H)Gf24qcykHe8Q63qOnKiOP87dk6XkPmAVUsTgQpeE3v1utJ6Q3nuqFrykJHAFmdL6xHbCCuqb9fHjZvzmu7JIHs9RWawz0tX7AQEdgU0zyp)7uUdhc)gQCvnb2wX7dk6n)Ls5hMbpkELrpaeoI0687dk6XaBOu)kSIwuqFryYCv2RenndL6xHbmQaOj1rEBozKMfaaMyzBv9BiwEil7ocIfNfuAOQRz5HSSWelwzmoIrCYE4pyHnoKaMsibVQ(neAVUsi85CvnzUyamhGf49hSueGqni0szUchM17QAkhdlV(vAgKqCbYmKdMqbfdRlkIanxHdZ6DvnLJHLx)kndsiUaXj7H)Gf24qcykHe87t31A0EDLS(DnvVb)Kw7tgCU(BOYv1eOIwQRE3GFF6UwBgQpeE3v1KIw4isRZVpOOhBWVpDxRbCCAASEwf1HdkY8xkzbovgCipv9kqAA308UMQ3GHlDg2Z)oL7WHWVHkxvtGkux9UHc6lctzmu7JzOu)kmGJJckOVimzUkJHAFuOU6Dd(9P7ATzOu)kmGb0kWrKwNFFqrp2GFF6UwhVsOxBfTSEwf1HdkYOte8XX5UMO)kuzu6lnctnn)LsivKk6HS4vx9Ub)(0DT2muQFfgyaSTI3hu0B(lLYpmdEu8iJtgPzb46(Dw2EsR9HLy0C9NLfMybwSeazXYovSmuFi8URQjwuxpl4)0AwS43ZshoSyfjc(4ywIgyGfVazbewO7zzHjwuPoCiwqtmcByz7pTMLfMyrL6WHybnWcbeiIf8vbILF3FwSCAnlrdmWIxWFNgw2EF6UwZj7H)Gf24qcykHe87t31A0EDLExt1BWpP1(KbNR)gQCvnbQqD17g87t31AZq9HW7UQMu0Y6zvuhoOiJorWhhN7AI(RqLrPV0im108xkHurQOhYIh9AR49bf9M)sP8dZGhfFC4KrAwaUUFNLy0qEQ6vG0WYctSS9(0DTMLhYcqefXYkILFNyrD17SOMGfxJHSSWxHILT3NUR1SalwqglykalqmlWHfnHXSmuQF1vO4K9WFWcBCibmLqc(9P7AnAVUsZQOoCqrM)sjlWPYGd5PQxbsJcCeP153hu0Jn43NUR1XRuCu0YA1vVB(lLSaNkdoKNQEfinMvKc1vVBWVpDxRnd1hcV7QAQPPfcFoxvtgWH80SLtRZDxRZWExrl1vVBWVpDxRndL6xHbCCAAWrKwNFFqrp2GFF6Uwhpav8UMQ3GFsR9jdox)nu5QAcuH6Q3n43NUR1MHs9RWagzTB3MtgPzbnUoS0(tywSSt)onS4SS9(GxdkILfMyXYP1Se8fMyz79P7AnlpKLUR1Sa7D0YIxGSSWelBVp41GIy5HSaerrSeJgYtvVcKgwWVhaILveNSh(dwyJdjGPesq4Z5QAcTLNskHFF6UwNTaRp3DTod7D0IW1lsjh)JRZrql0epGijaulLtc4vx9U5VuYcCQm4qEQ6vG0yWVhaQnaQL6Q3n43NUR1MHs9RWaFCqQ4isRZ7o(jG3631u9g8tATpzW56VHkxvtGTbqTcqOgeAPm43NUR1MHs9RWaFCqQ4isRZ7o(jG)DnvVb)Kw7tgCU(BOYv1eyBaulq4B6Rjrg2ZKEvKzOu)kmWJS2kAPU6Dd(9P7ATzf10eGqni0szWVpDxRndL6xHBZjJ0SaaWelBVp41GIyXY97SeJgYtvVcKgwEilaruelRiw(DIf1vVZIL73HRNfneFfkw2EF6UwZYk6VuIfVazzHjw2EFWRbfXcSyb9aglXegxRYc(9aqyww1FAwqpwEFqrpMt2d)blSXHeWucj43h8AqrO96kHWNZv1KbCipnB506C316mS3vGWNZv1Kb)(0DToBbwFU7ADg27kSgHpNRQjZHQGdLXVp41GIAAAPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpau8XPPrD17gvx7vGYWE2168VFfkC2NGxKb)EaO4JtBf4isRZVpOOhBWVpDxRbm6PaHpNRQjd(9P7AD2cS(C316mS35KrAwaayIfSfFszbdz539NLeWflOONLuh5SSI(lLyrnbll8vOy5EwCmlA)jwCmlrqm(u1elWIfnHXS87EXsCyb)EaimlWHfGBw4Nfl7uXsCagl43daHzHqE0neNSh(dwyJdjGPesCqp6peugBXNu0gse0u(9bf9yLugTxxjR)la0vOuyTh(dwgh0J(dbLXw8jnd6PokYCvURpu7Ftdi8noOh9hckJT4tAg0tDuKb)EaiahhfGW34GE0FiOm2IpPzqp1rrMHs9RWaooCYinlXyuFi8ola4GWQFdXY1zbnXfjwzfy5WSmKdMaTS870qS4dXIMWyw(DVybzS8(GIEmlxXIvSkFyb9d6lctSy5(Dw2GpagAzrtyml)UxSOCsSa)DASCyILRyXReSG(b9fHjwGdlRiwEiliJL3hu0JzrL6WHyXzXkwLpSG(b9fHjdlXiyHUNLH6dH3zbCnxHIfG7xboeilOFAe0cnPu9SSknHXSCflBqTpSG(b9fHjozp8hSWghsatjKKcHv)gcTHebnLFFqrpwjLr71vAO(q4DxvtkEFqrV5Vuk)Wm4rX3QLYOhWAHJiTo)(GIESb)(0VHaEac8QRE3qb9fHPSEv(ywrTBdSHs9RWTrQTugyVRP6nVLRYPqyHnu5QAcSTIwbiudcTuMGNVkygYbtOWAWzDGMcMdGyfTq4Z5QAYeGfciqugKWjQqttac1GqlLjaleqGO8VtzC0n3Jnd5GjAASoarqLxVPou7FU7u7MgCeP153hu0Jn43N(neGB1c4aGAPU6Ddf0xeMY6v5Jzfb8aSDBGVLYa7DnvV5TCvofclSHkxvtGTBRWAkOVimzWqTp5Iq(300Ic6lctMRYyO2NMMwuqFryYCvwf(7nnuqFryYCvwVkFARW631u9gmCPZWE(3PChoe(nu5QAcSPrD17MO5sHd456SpbVUqoAPX(yq46ffVsaezj1wrlCeP153hu0Jn43N(neGvojGVLYa7DnvV5TCvofclSHkxvtGTBRWX)46Ce0cnXJSKaqQRE3GFF6UwBgk1Vcd8aN2kAzT6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrnnuqFryYCvgd1(00yDaIGkVEdqjMZR2kSwD17MXrqfCHZ9HQyLiJVQV059e4NMZnRiozKMfaaMybadgBwGflbqwSC)oC9Se8OORqXj7H)Gf24qcykHKoCcug2ZL)RHq71vYJYHDkaeNSh(dwyJdjGPesq4Z5QAcTLNskfaZbybE)bRSdj0IW1lsjRbN1bAkyoaIvGWNZv1KjaMdWc8(dwkA1sD17g87t31AZkQP5DnvVb)Kw7tgCU(BOYv1eyttaIGkVEtDO2)C3P2kAzT6Q3nyOg)xGmRifwRU6DtWZxfmRifTS(DnvVPVMezypt6vrgQCvnb20OU6DtWZxfmGRX)dwXhGqni0sz6Rjrg2ZKEvKzOu)kmWaeTvGWNZv1K53NtRZyIaIMSf)EfTSoarqLxVPou7FU7uttac1GqlLjaleqGO8VtzC0n3JnRifTux9Ub)(0DT2muQFfgWaSPX631u9g8tATpzW56VHkxvtGTBR49bf9M)sP8dZGhfV6Q3nbpFvWaUg)pyb8jza0TBAuHySI(HA)ZdL6xHbS6Q3nbpFvWaUg)py1MtgPzbaGjwqtCrIvwbwGflbqwwLMWyw8cKf9vel3ZYkIfl3VZcAGfciqeNSh(dwyJdjGPescKMW)56SRpuvkvpAVUsi85CvnzcG5aSaV)Gv2HeNSh(dwyJdjGPesUk4t5)bl0EDLq4Z5QAYeaZbybE)bRSdjozKMfaaMyb9tJGwOHLyclqwGflbqwSC)olBVpDxRzzfXIxGSGDeelD4WcGCPX(WIxGSGM4IeRScCYE4pyHnoKaMsiHsJGwOjRclq0EDLU6PjcQ9NaZ9d1(Nhk1VcdyLrwttl1vVBIMlfoGNRZ(e86c5OLg7JbHRxeGbiYsQPrD17MO5sHd456SpbVUqoAPX(yq46ffVsaezj1wH6Q3n43NUR1MvKIwbiudcTuMGNVkygk1VchpYsQPbCwhOPG5aiUnNmsZsmg1hcVZsx7dXcSyzfXYdzjoS8(GIEmlwUFhUEwqtCrIvwbwuPRqXIRcxplpKfc5r3qS4filf8zbIGMGhfDfkozp8hSWghsatjKGFsR9j31(qOnKiOP87dk6XkPmAVUsd1hcV7QAsXFPu(HzWJIxzKPahrAD(9bf9yd(9PFdby0tHhLd7uaifTux9Uj45RcMHs9RWXRCsnnwRU6DtWZxfmRO2CYinlaamXcage9z56SCf(ajw8If0pOVimXIxGSOVIy5EwwrSy5(DwCwaKln2hwIgyGfVazjUGE0Fiiw2S4tkNSh(dwyJdjGPes6Rjrg2ZKEveAVUsuqFryYCv2Rek8OCyNcaPqD17MO5sHd456SpbVUqoAPX(yq46fbyaISKu0ce(gh0J(dbLXw8jnd6PokY8xaORq10yDaIGkVEtrHbQHdytdoI0687dk6XXdW2kAPU6DZ4iOcUW5(qvSsygk1VcdyKcaQfYa(zvuhoOid(Q(sN3tGFAoVTc1vVBghbvWfo3hQIvcZkQPXA1vVBghbvWfo3hQIvcZkQTIwwhGqni0szcE(QGzf10OU6DZVpNwNXebeng87bGaSYitr)qT)5Hs9RWagGjLKI(HA)ZdL6xHJx5KsQPXAmCPvVc087ZP1zmrarJHkxvtGTv0cdxA1Ran)(CADgteq0yOYv1eyttac1GqlLj45RcMHs9RWXhNKAZjJ0SaaWelolBVpDxRzbaFr)olrdmWYQ0egZY27t31AwomlUEihmblRiwGdljGlw8HyXvHRNLhYcebnbpIL4IbKCYE4pyHnoKaMsib)(0DTgTxxj1vVBGf974Cenbk6pyzwrkAPU6Dd(9P7ATzO(q4Dxvtnno(hxNJGwOjEKssT5KrAwIrR0iwIlgqYIk1HdXcAGfciqelwUFNLT3NUR1S4fil)ovSS9(GxdkIt2d)blSXHeWucj43NUR1O96kfGiOYR3uhQ9p3DsH1VRP6n4N0AFYGZ1FdvUQMav0cHpNRQjtawiGarzqcNOcnnbiudcTuMGNVkywrnnQRE3e88vbZkQTIaeQbHwktawiGar5FNY4OBUhBgk1VcdyubqtQJCGpqNULJ)X15iOfAqQilP2kux9Ub)(0DT2muQFfgWONcRbN1bAkyoaI5K9WFWcBCibmLqc(9bVgueAVUsbicQ86n1HA)ZDNu0cHpNRQjtawiGarzqcNOcnnbiudcTuMGNVkywrnnQRE3e88vbZkQTIaeQbHwktawiGar5FNY4OBUhBgk1VcdyGJc1vVBWVpDxRnRifuqFryYCv2RekSgHpNRQjZHQGdLXVp41GIuyn4SoqtbZbqmNmsZcaatSS9(GxdkIfl3VZIxSaGVOFNLObgyboSCDwsaxOdKficAcEelXfdizXY97SKaUgwkc5plbh)gwIRgdzbCLgXsCXasw8NLFNyHkqwGDw(DILy8u97jgwux9olxNLT3NUR1SybU0Gf6Ew6UwZcS3zboSKaUyXhIfyXcaz59bf9yozp8hSWghsatjKGFFWRbfH2RRK6Q3nWI(DCoOjFYio8blZkQPPL143N(nKXJYHDkaKcRr4Z5QAYCOk4qz87dEnOOMMwQRE3e88vbZqP(vyaJmfQRE3e88vbZkQPPvl1vVBcE(QGzOu)kmGrfanPoYb(aD6wo(hxNJGwObPgNKARqD17MGNVkywrnnQRE3mocQGlCUpufRez8v9LoVNa)0CUzOu)kmGrfanPoYb(aD6wo(hxNJGwObPgNKARqD17MXrqfCHZ9HQyLiJVQV059e4NMZnRO2kcqeu51Bqq1VNyA3wrlCeP153hu0Jn43NUR1aoonni85CvnzWVpDxRZwG1N7UwNH9E72kSgHpNRQjZHQGdLXVp41GIu0Y6zvuhoOiZFPKf4uzWH8u1RaPPPbhrAD(9bf9yd(9P7AnGJtBozKMfaaMybahewywUILnO2hwq)G(IWelEbYc2rqSaGT0AwaWbHflD4WcAIlsSYkWj7H)Gf24qcykHKISKtHWcTxxPwQRE3qb9fHPmgQ9XmuQFfoEc5uy9u(VuQPPvy3huewjaQyOWUpOO8FPeGrw7MMWUpOiSsXPTcpkh2PaqCYE4pyHnoKaMsiz319CkewO96k1sD17gkOVimLXqTpMHs9RWXtiNcRNY)LsnnTc7(GIWkbqfdf29bfL)lLamYA30e29bfHvkoTv4r5Wofasrl1vVBghbvWfo3hQIvcZqP(vyaJmfQRE3mocQGlCUpufReMvKcRNvrD4GIm4R6lDEpb(P58MgRvx9UzCeubx4CFOkwjmRO2CYE4pyHnoKaMsiPV06CkewO96k1sD17gkOVimLXqTpMHs9RWXtiNcRNY)LskAfGqni0szcE(QGzOu)kC8ilPMMaeQbHwktawiGar5FNY4OBUhBgk1VchpYsQDttRWUpOiSsauXqHDFqr5)sjaJS2nnHDFqryLItBfEuoStbGu0sD17MXrqfCHZ9HQyLWmuQFfgWitH6Q3nJJGk4cN7dvXkHzfPW6zvuhoOid(Q(sN3tGFAoVPXA1vVBghbvWfo3hQIvcZkQnNmsZcaatSaCbrFwGflOjgXj7H)Gf24qcykHel(mhCYWEM0RI4KrAwqJRdlT)eMfl70VtdlpKLfMyz79PFdXYvSSb1(WIL9lSZYHzXFwqglVpOOhdmLzPdhwie0KGfaMesLLuh)0KGf4Wc6XY27dEnOiwq)0iOfAsP6zb)EaimNSh(dwyJdjGPesq4Z5QAcTLNskHFF63q5RYyO2h0IW1lsjCeP153hu0Jn43N(nu8OhW6AiCAL64NMezeUEraVYjLesfGj1gyDneoTux9Ub)(GxdkktPrql0Ks1NXqTpg87bGqQOxBozKMf046Ws7pHzXYo970WYdzb4A8FNfW1CfkwaWgQIvcozp8hSWghsatjKGWNZv1eAlpLuYY4)E(QCFOkwjqlcxViLugPIJiToV74NamabqTsYaqGVfoI0687dk6Xg87t)gcaPCBGVLYa7DnvVbdx6mSN)Dk3HdHFdvUQMabELniRDBGLKrzKb8QRE3mocQGlCUpufReMHs9RWCYinlaamXcW14)olxXYgu7dlOFqFryIf4WY1zPGSS9(0VHyXYP1S0VNLREilOjUiXkRalELifoeNSh(dwyJdjGPesSm(VJ2RRulkOVimz0RYNCri)BAOG(IWKXRe5Iq(RaHpNRQjZHZbn5iO2kA9(GIEZFPu(HzWJIh9AAOG(IWKrVkFYxLbytt)qT)5Hs9RWaw5KA30OU6Ddf0xeMYyO2hZqP(vya7H)GLb)(0VHmeYPW6P8FPKc1vVBOG(IWugd1(ywrnnuqFryYCvgd1(OWAe(CUQMm43N(nu(QmgQ9PPrD17MGNVkygk1Vcdyp8hSm43N(nKHqofwpL)lLuyncFoxvtMdNdAYrqkux9Uj45RcMHs9RWaMqofwpL)lLuOU6DtWZxfmROMg1vVBghbvWfo3hQIvcZksbcFoxvtglJ)75RY9HQyLOPXAe(CUQMmhoh0KJGuOU6DtWZxfmdL6xHJNqofwpL)lL4KrAwaayILT3N(nelxNLRyXkwLpSG(b9fHj0YYvSSb1(Wc6h0xeMybwSGEaJL3hu0JzboS8qwIgyGLnO2hwq)G(IWeNSh(dwyJdjGPesWVp9BiozKMfamxR)9zXj7H)Gf24qcykHKzvzp8hSY6d)OT8usPUR1)(S4K5KrAwaWgQIvcwSC)olOjUiXkRaNSh(dwyJk0FLghbvWfo3hQIvc0EDLux9Uj45RcMHs9RWXRmY4KrAwaayIL4c6r)HGyzZIpPSyzNkw8NfnHXS87EXc6XsmHX1QSGFpaeMfVaz5HSmuFi8ololawjaYc(9aqS4yw0(tS4ywIGy8PQjwGdl)LsSCplyil3ZIpZHGWSaCZc)S49NgwCwIdWyb)EaiwiKhDdH5K9WFWcBuH(dmLqId6r)HGYyl(KI2qIGMYVpOOhRKYO96kPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpaeGbekux9Ur11EfOmSNDTo)7xHcN9j4fzWVhacWacfTSge(gh0J(dbLXw8jnd6PokY8xaORqPWAp8hSmoOh9hckJT4tAg0tDuK5QCxFO2FfTSge(gh0J(dbLXw8jnVtU28xaORq10acFJd6r)HGYyl(KM3jxBgk1VchFCA30acFJd6r)HGYyl(KMb9uhfzWVhacWXrbi8noOh9hckJT4tAg0tDuKzOu)kmGrMcq4BCqp6peugBXN0mON6OiZFbGUcvBozKMfaaMybnWcbeiIfl3VZcAIlsSYkWILDQyjcIXNQMyXlqwG)onwomXIL73zXzjMW4Avwux9olw2PIfqcNOcxHIt2d)blSrf6pWucjbyHaceL)DkJJU5EmAVUswdoRd0uWCaeROvle(CUQMmbyHaceLbjCIkOW6aeQbHwktWZxfmd5GjAAux9Uj45RcMvuBfTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhasjartJ6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqkbiA30OcXyf9d1(Nhk1VcdyLtQnNmsZcage9zXXS87el9BWplOcGSCfl)oXIZsmHX1QSy5kqOfwGdlwUFNLFNyb4EI58If1vVZcCyXY97S4SaiagMcSexqp6peelBw8jLfVazXIFplD4WcAIlsSYkWY1z5EwSaRNfvILvelok)kwuPoCiw(DILailhML(vhENa5K9WFWcBuH(dmLqsFnjYWEM0RIq71vQvRwQRE3O6AVcug2ZUwN)9RqHZL)RHm43dafpWPPrD17gvx7vGYWE2168VFfkC2NGxKb)EaO4boTv0Y6aebvE9geu97jMMgRvx9UzCeubx4CFOkwjmRO2Tv0cCwhOPG5aiUPjaHAqOLYe88vbZqP(v44rwsnnTcqeu51BQd1(N7oPiaHAqOLYeGfciqu(3Pmo6M7XMHs9RWXJSKA3UDttlq4BCqp6peugBXN0mON6OiZqP(v44bekcqOgeAPmbpFvWmuQFfoELtsraIGkVEtrHbQHdy7MMREAIGA)jWC)qT)5Hs9RWagqOW6aeQbHwktWZxfmd5GjAAcqeu51BakXCEPqD17gGUcCiWmLgbTqtkvVzf10eGiOYR3GGQFpXOqD17MXrqfCHZ9HQyLWmuQFfgWiffQRE3mocQGlCUpufReMveNmsZcA8kqAw2EF0WbKfl3VZIZsrwyjMW4Avwux9olEbYcAIlsSYkWYHl09S4QW1ZYdzrLyzHjqozp8hSWgvO)atjKe8kq6S6Q3rB5PKs43hnCar71vQL6Q3nQU2RaLH9SR15F)ku4C5)AiZqP(v44b0gK10OU6DJQR9kqzyp7AD(3Vcfo7tWlYmuQFfoEaTbzTv0kaHAqOLYe88vbZqP(v44b0nnTcqOgeAPmuAe0cnzvybAgk1VchpGwH1QRE3a0vGdbMP0iOfAsP6ZurdQlwKzfPiarqLxVbOeZ5v72kC8pUohbTqt8kfNK4KrAwIrR0iw2EFWRbfHzXY97S4SetyCTklQRENf11ZsbFwSStflrqO(kuS0HdlOjUiXkRalWHfG7xboeilBr3CpMt2d)blSrf6pWucj43h8AqrO96k1sD17gvx7vGYWE2168VFfkCU8FnKb)EaO4bytJ6Q3nQU2RaLH9SR15F)ku4SpbVid(9aqXdW2kAfGiOYR3uhQ9p3DQPjaHAqOLYe88vbZqP(v44b0nnwJWNZv1KjaMdWc8(dwkSoarqLxVbOeZ5vttRaeQbHwkdLgbTqtwfwGMHs9RWXdOvyT6Q3naDf4qGzkncAHMuQ(mv0G6Ifzwrkcqeu51BakXCE1UTIwwdcFtFnjYWEM0RIm)fa6kunnwhGqni0szcE(QGzihmrtJ1biudcTuMaSqabIY)oLXr3Cp2mKdMOnNmsZsmALgXY27dEnOimlQuhoelObwiGarCYE4pyHnQq)bMsib)(GxdkcTxxPwbiudcTuMaSqabIY)oLXr3Cp2muQFfgWitH1GZ6anfmhaXkAHWNZv1KjaleqGOmiHtuHMMaeQbHwktWZxfmdL6xHbmYARaHpNRQjtamhGf49hSARWAq4B6Rjrg2ZKEvK5VaqxHsraIGkVEtDO2)C3jfwdoRd0uWCaeRGc6lctMRYELqHJ)X15iOfAIh9sItgPzjgbl09SacFwaxZvOy53jwOcKfyNLymhbvWfMfaSHQyLaTSaUMRqXcqxboeiluAe0cnPu9SahwUILFNyr74NfubqwGDw8If0pOVimXj7H)Gf2Oc9hykHee(CUQMqB5PKsGWppumSUHsP6XOfHRxKsTux9UzCeubx4CFOkwjmdL6xHJhznnwRU6DZ4iOcUW5(qvSsywrTv0sD17gGUcCiWmLgbTqtkvFMkAqDXImdL6xHbmQaOj1rEBfTux9UHc6lctzmu7JzOu)kC8OcGMuh5nnQRE3qb9fHPSEv(ygk1VchpQaOj1rEBozp8hSWgvO)atjKGxv)gcTHebnLFFqrpwjLr71vAO(q4DxvtkEFqrV5Vuk)Wm4rXRmWrHhLd7uaifi85CvnzaHFEOyyDdLs1J5K9WFWcBuH(dmLqskew9Bi0gse0u(9bf9yLugTxxPH6dH3DvnP49bf9M)sP8dZGhfVYXXGmfEuoStbGuGWNZv1Kbe(5HIH1nukvpMt2d)blSrf6pWucj4N0AFYDTpeAdjcAk)(GIESskJ2RR0q9HW7UQMu8(GIEZFPu(HzWJIxzGdWgk1VcRWJYHDkaKce(CUQMmGWppumSUHsP6XCYinlayWyZcSyjaYIL73HRNLGhfDfkozp8hSWgvO)atjK0HtGYWEU8FneAVUsEuoStbG4KrAwq)0iOfAyjMWcKfl7uXIRcxplpKfQEAyXzPilSetyCTklwUceAHfVazb7iiw6WHf0exKyLvGt2d)blSrf6pWucjuAe0cnzvybI2RRulkOVimz0RYNCri)BAOG(IWKbd1(Klc5Ftdf0xeMmELixeY)Mg1vVBuDTxbkd7zxRZ)(vOW5Y)1qMHs9RWXdOniRPrD17gvx7vGYWE2168VFfkC2NGxKzOu)kC8aAdYAAC8pUohbTqt8iLKueGqni0szcE(QGzihmHcRbN1bAkyoaIBROvac1GqlLj45RcMHs9RWXhNKAAcqOgeAPmbpFvWmKdMODtZvpnrqT)eyUFO2)8qP(vyaRCsCYinlayq0NL5qT)SOsD4qSSWxHIf0exozp8hSWgvO)atjK0xtImSNj9Qi0EDLcqOgeAPmbpFvWmKdMqbcFoxvtMayoalW7pyPOLJ)X15iOfAIhPKKcRdqeu51BQd1(N7o10eGiOYR3uhQ9p3DsHJ)X15iOfAam6LuBfwhGiOYR3GGQFpXOOL1bicQ86n1HA)ZDNAAcqOgeAPmbyHaceL)DkJJU5ESzihmrBfwdoRd0uWCaeZjJ0SGM4IeRScSyzNkw8NfKssaJL4IbKS0coAOfAy539If0ljwIlgqYIL73zbnWcbeiQnlwUFhUEw0q8vOy5VuILRyjMAieuVWplEbYI(kILvelwUFNf0aleqGiwUol3ZIfhZciHtubcKt2d)blSrf6pWucji85CvnH2YtjLcG5aSaV)Gvwf6pAr46fPK1GZ6anfmhaXkq4Z5QAYeaZbybE)blfTA54FCDocAHM4rkjPOL6Q3naDf4qGzkncAHMuQ(mv0G6IfzwrnnwhGiOYR3auI58QDtJ6Q3nQAieuVWVzfPqD17gvnecQx43muQFfgWQRE3e88vbd4A8)Gv7MMREAIGA)jWC)qT)5Hs9RWawD17MGNVkyaxJ)hSAAcqeu51BQd1(N7o1wrlRdqeu51BQd1(N7o100YX)46Ce0cnag9sQPbe(M(AsKH9mPxfz(la0vOAROfcFoxvtMaSqabIYGeorfAAcqOgeAPmbyHaceL)DkJJU5ESzihmr72CYE4pyHnQq)bMsijqAc)NRZU(qvPu9O96kHWNZv1KjaMdWc8(dwzvO)CYE4pyHnQq)bMsi5QGpL)hSq71vcHpNRQjtamhGf49hSYQq)5KrAwqF8FP(tyw2HwyjDf2zjUyajl(qSGYVIazjIgwWuawGCYE4pyHnQq)bMsibHpNRQj0wEkPKJJaK0Srb0IW1lsjkOVimzUkRxLpapGaP6H)GLb)(0VHmeYPW6P8FPeWSMc6lctMRY6v5dW3c4aS31u9gmCPZWE(3PChoe(nu5QAce4JtBKQh(dwglJ)7gc5uy9u(VucyjzaisfhrADE3XpXjJ0SeJwPrSS9(GxdkcZILDQy53jw6hQ9NLdZIRcxplpKfQarll9HQyLGLdZIRcxplpKfQarlljGlw8HyXFwqkjbmwIlgqYYvS4flOFqFrycTSGM4IeRScSOD8JzXl4VtdlacGHPaMf4Wsc4IflWLgKficAcEelPWHy539IfUr5KyjUyajlw2PILeWflwGlnyHUNLT3h8AqrSuqlCYE4pyHnQq)bMsib)(GxdkcTxxPwx90eb1(tG5(HA)ZdL6xHbm6100sD17MXrqfCHZ9HQyLWmuQFfgWOcGMuh5aFGoDlh)JRZrql0GuJtsTvOU6DZ4iOcUW5(qvSsywrTB300YX)46Ce0cnadHpNRQjJJJaK0SrbGxD17gkOVimLXqTpMHs9RWade(M(AsKH9mPxfz(laeopuQFfWdqdYIxzLtQPXX)46Ce0cnadHpNRQjJJJaK0SrbGxD17gkOVimL1RYhZqP(vyGbcFtFnjYWEM0RIm)facNhk1Vc4bObzXRSYj1wbf0xeMmxL9kHIwwRU6DtWZxfmROMgRFxt1BWVpA4aAOYv1eyBfTAzDac1GqlLj45RcMvuttaIGkVEdqjMZlfwhGqni0szO0iOfAYQWc0SIA30eGiOYR3uhQ9p3DQTIwwhGiOYR3GGQFpX00yT6Q3nbpFvWSIAAC8pUohbTqt8iLKA3006DnvVb)(OHdOHkxvtGkux9Uj45RcMvKIwQRE3GFF0Wb0GFpaeGJttJJ)X15iOfAIhPKu72nnQRE3e88vbZksH1QRE3mocQGlCUpufReMvKcRFxt1BWVpA4aAOYv1eiNmsZcaatSaGdclmlxXIvSkFyb9d6lctS4filyhbXsmUUUdmaSLwZcaoiSyPdhwqtCrIvwbozp8hSWgvO)atjKuKLCkewO96k1sD17gkOVimL1RYhZqP(v44jKtH1t5)sPMMwHDFqryLaOIHc7(GIY)LsagzTBAc7(GIWkfN2k8OCyNcaXj7H)Gf2Oc9hykHKDx3ZPqyH2RRul1vVBOG(IWuwVkFmdL6xHJNqofwpL)lLu0kaHAqOLYe88vbZqP(v44rwsnnbiudcTuMaSqabIY)oLXr3Cp2muQFfoEKLu7MMwHDFqryLaOIHc7(GIY)LsagzTBAc7(GIWkfN2k8OCyNcaXj7H)Gf2Oc9hykHK(sRZPqyH2RRul1vVBOG(IWuwVkFmdL6xHJNqofwpL)lLu0kaHAqOLYe88vbZqP(v44rwsnnbiudcTuMaSqabIY)oLXr3Cp2muQFfoEKLu7MMwHDFqryLaOIHc7(GIY)LsagzTBAc7(GIWkfN2k8OCyNcaXjJ0SaCbrFwGflbqozp8hSWgvO)atjKyXN5Gtg2ZKEveNmsZcaatSS9(0VHy5HSenWalBqTpSG(b9fHjwGdlw2PILRybw6eSyfRYhwq)G(IWelEbYYctSaCbrFwIgyaZY1z5kwSIv5dlOFqFryIt2d)blSrf6pWucj43N(neAVUsuqFryYCvwVkFAAOG(IWKbd1(Klc5Ftdf0xeMmELixeY)Mg1vVBS4ZCWjd7zsVkYSIuOU6Ddf0xeMY6v5Jzf100sD17MGNVkygk1Vcdyp8hSmwg)3neYPW6P8FPKc1vVBcE(QGzf1Mt2d)blSrf6pWucjwg)35K9WFWcBuH(dmLqYSQSh(dwz9HF0wEkPu316FFwCYCYinlBVp41GIyPdhwsHiOuQEwwLMWyww4RqXsmHX1QCYE4pyHnDxR)9zPe(9bVgueAVUswpRI6WbfzuDTxbkd7zxRZ)(vOWgkgwxuebYjJ0SGgh)S87elGWNfl3VZYVtSKcXpl)LsS8qwCqqww1FAw(DILuh5SaUg)pyXYHzz)EdlBRQFdXYqP(vywsx6)I0hbYYdzj1)WolPqy1VHybCn(FWIt2d)blSP7A9VplGPesWRQFdH2qIGMYVpOOhRKYO96kbcFtkew9BiZqP(v44hk1Vcd8aeGivLbeCYE4pyHnDxR)9zbmLqskew9BiozozKMfaaMyz79bVguelpKfGikILvel)oXsmAipv9kqAyrD17SCDwUNflWLgKfc5r3qSOsD4qS0V6W7xHILFNyPiK)SeC8ZcCy5HSaUsJyrL6WHybnWcbeiIt2d)blSb)kHFFWRbfH2RR0SkQdhuK5VuYcCQm4qEQ6vG0OOff0xeMmxL9kHcRB1sD17M)sjlWPYGd5PQxbsJzOu)kC8E4pyzSm(VBiKtH1t5)sjGLKrzfTOG(IWK5QSk83BAOG(IWK5QmgQ9PPHc6lctg9Q8jxeY)2nnQRE38xkzbovgCipv9kqAmdL6xHJ3d)bld(9PFdziKtH1t5)sjGLKrzfTOG(IWK5QSEv(00qb9fHjdgQ9jxeY)MgkOVimz8krUiK)TB30yT6Q3n)LswGtLbhYtvVcKgZkQDttl1vVBcE(QGzf10GWNZv1KjaleqGOmiHtuH2kcqOgeAPmbyHaceL)DkJJU5ESzihmHIaebvE9M6qT)5UtTv0Y6aebvE9gGsmNxnnbiudcTugkncAHMSkSandL6xHJhq0wrl1vVBcE(QGzf10yDac1GqlLj45RcMHCWeT5KrAwaayIL4c6r)HGyzZIpPSyzNkw(DAiwomlfKfp8hcIfSfFsrlloMfT)eloMLiigFQAIfyXc2IpPSy5(DwailWHLozHgwWVhacZcCybwS4SehGXc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdbHzb4Mf(zX7pnS87(Zc2IpPSqip6gcZj7H)Gf2GFGPesCqp6peugBXNu0gse0u(9bf9yLugTxxjRbHVXb9O)qqzSfFsZGEQJIm)fa6kukS2d)blJd6r)HGYyl(KMb9uhfzUk31hQ9xrlRbHVXb9O)qqzSfFsZ7KRn)fa6kunnGW34GE0FiOm2IpP5DY1MHs9RWXJS2nnGW34GE0FiOm2IpPzqp1rrg87bGaCCuacFJd6r)HGYyl(KMb9uhfzgk1Vcd44Oae(gh0J(dbLXw8jnd6PokY8xaORqXjJ0SaaWeMf0aleqGiwUolOjUiXkRalhMLvelWHLeWfl(qSas4ev4kuSGM4IeRScSy5(DwqdSqabIyXlqwsaxS4dXIkPHwyb9sIL4IbKCYE4pyHn4hykHKaSqabIY)oLXr3CpgTxxjRbN1bAkyoaIv0QfcFoxvtMaSqabIYGeorfuyDac1GqlLj45RcMHCWekSEwf1HdkYenxkCapxN9j41fYrln2NMg1vVBcE(QGzf1wHJ)X15iOfAaSsOxskAPU6Ddf0xeMY6v5JzOu)kC8kNutJ6Q3nuqFrykJHAFmdL6xHJx5KA30OcXyf9d1(Nhk1VcdyLtsH1biudcTuMGNVkygYbt0MtgPzbnWc8(dwS0HdlUwZci8XS87(ZsQdeHzbVgILFNsWIpuHUNLH6dH3jqwSStflXyocQGlmlaydvXkbl7oMfnHXS87EXcYybtbmldL6xDfkwGdl)oXcqjMZlwux9olhMfxfUEwEilDxRzb27Sahw8kblOFqFryILdZIRcxplpKfc5r3qCYE4pyHn4hykHee(CUQMqB5PKsGWppumSUHsP6XOfHRxKsTux9UzCeubx4CFOkwjmdL6xHJhznnwRU6DZ4iOcUW5(qvSsywrTvyT6Q3nJJGk4cN7dvXkrgFvFPZ7jWpnNBwrkAPU6DdqxboeyMsJGwOjLQptfnOUyrMHs9RWagva0K6iVTIwQRE3qb9fHPmgQ9XmuQFfoEubqtQJ8Mg1vVBOG(IWuwVkFmdL6xHJhva0K6iVPPL1QRE3qb9fHPSEv(ywrnnwRU6Ddf0xeMYyO2hZkQTcRFxt1BWqn(VazOYv1eyBozKMf0alW7pyXYV7plHDkaeMLRZsc4IfFiwGRhFGeluqFryILhYcS0jybe(S870qSahwoufCiw(9dZIL73zzdQX)fiozp8hSWg8dmLqccFoxvtOT8usjq4NHRhFGuMc6lctOfHRxKsTSwD17gkOVimLXqTpMvKcRvx9UHc6lctz9Q8XSIA308UMQ3GHA8FbYqLRQjqozp8hSWg8dmLqskew9Bi0gse0u(9bf9yLugTxxPH6dH3DvnPOL6Q3nuqFrykJHAFmdL6xHJFOu)kCtJ6Q3nuqFrykRxLpMHs9RWXpuQFfUPbHpNRQjdi8ZW1Jpqktb9fHP2kgQpeE3v1KI3hu0B(lLYpmdEu8kdqfEuoStbGuGWNZv1Kbe(5HIH1nukvpMt2d)blSb)atjKGxv)gcTHebnLFFqrpwjLr71vAO(q4DxvtkAPU6Ddf0xeMYyO2hZqP(v44hk1Vc30OU6Ddf0xeMY6v5JzOu)kC8dL6xHBAq4Z5QAYac)mC94dKYuqFryQTIH6dH3DvnP49bf9M)sP8dZGhfVYauHhLd7uaifi85CvnzaHFEOyyDdLs1J5K9WFWcBWpWucj4N0AFYDTpeAdjcAk)(GIESskJ2RR0q9HW7UQMu0sD17gkOVimLXqTpMHs9RWXpuQFfUPrD17gkOVimL1RYhZqP(v44hk1Vc30GWNZv1Kbe(z46XhiLPG(IWuBfd1hcV7QAsX7dk6n)Ls5hMbpkELbok8OCyNcaPaHpNRQjdi8ZdfdRBOuQEmNmsZcaatSaGbJnlWILailwUFhUEwcEu0vO4K9WFWcBWpWucjD4eOmSNl)xdH2RRKhLd7uaiozKMfaaMyb4(vGdbYYw0n3JzXY97S4vcw0WcflubxO2zr74)kuSG(b9fHjw8cKLFsWYdzrFfXY9SSIyXY97SaixASpS4filOjUiXkRaNSh(dwyd(bMsiHsJGwOjRclq0EDLA1sD17gkOVimLXqTpMHs9RWXRCsnnQRE3qb9fHPSEv(ygk1VchVYj1wrac1GqlLj45RcMHs9RWXhNKu0sD17MO5sHd456SpbVUqoAPX(yq46fbyaIEj10y9SkQdhuKjAUu4aEUo7tWRlKJwASpgkgwxueb2UDtJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaiGoPMMaeQbHwktWZxfmd5Gju44FCDocAHM4rkjXjJ0SaaWelOjUiXkRalwUFNf0aleqGiKaC)kWHazzl6M7XS4filGWcDplqe0yzUNybqU0yFyboSyzNkwIPgcb1l8ZIf4sdYcH8OBiwuPoCiwqtCrIvwbwiKhDdH5K9WFWcBWpWucji85CvnH2YtjLcG5aSaV)Gvg)OfHRxKswdoRd0uWCaeRaHpNRQjtamhGf49hSu0Qvac1GqlLHsJsmKRZWbS8kqMHs9RWawzGdGgyTuwzGFwf1HdkYGVQV059e4NMZBRGIH1ffrGgknkXqUodhWYRa1UPXX)46Ce0cnXResjjfTS(DnvVPVMezypt6vrgQCvnb20OU6DtWZxfmGRX)dwXhGqni0sz6Rjrg2ZKEvKzOu)kmWaeTvGWNZv1K53NtRZyIaIMSf)EfTux9UbORahcmtPrql0Ks1NPIguxSiZkQPX6aebvE9gGsmNxTv8(GIEZFPu(HzWJIxD17MGNVkyaxJ)hSa(Kma6MgvigROFO2)8qP(vyaRU6DtWZxfmGRX)dwnnbicQ86n1HA)ZDNAAux9UrvdHG6f(nRifQRE3OQHqq9c)MHs9RWawD17MGNVkyaxJ)hSawlKcWpRI6WbfzIMlfoGNRZ(e86c5OLg7JHIH1ffrGTBRWA1vVBcE(QGzfPOL1bicQ86n1HA)ZDNAAcqOgeAPmbyHaceL)DkJJU5ESzf10OcXyf9d1(Nhk1Vcd4aeQbHwktawiGar5FNY4OBUhBgk1VcdmGttt)qT)5Hs9RWivKQYaIKaS6Q3nbpFvWaUg)py1MtgPzbaGjw(DILy8u97jgwSC)ololOjUiXkRal)U)SC4cDpl9bMYcGCPX(Wj7H)Gf2GFGPesghbvWfo3hQIvc0EDLux9Uj45RcMHs9RWXRmYAAux9Uj45RcgW14)blahNKuGWNZv1KjaMdWc8(dwz8Zj7H)Gf2GFGPescKMW)56SRpuvkvpAVUsi85CvnzcG5aSaV)Gvg)kAzT6Q3nbpFvWaUg)pyfFCsQPX6aebvE9geu97jM2nnQRE3mocQGlCUpufReMvKc1vVBghbvWfo3hQIvcZqP(vyaJuawawGR7nrdfomLD9HQsP6n)LszeUEraRL1QRE3OQHqq9c)MvKcRFxt1BWVpA4aAOYv1eyBozp8hSWg8dmLqYvbFk)pyH2RRecFoxvtMayoalW7pyLXpNmsZsmEFoxvtSSWeilWIfx903FeMLF3FwS41ZYdzrLyb7iiqw6WHf0exKyLvGfmKLF3Fw(Dkbl(q1ZIfh)eila3SWplQuhoel)oLYj7H)Gf2GFGPesq4Z5QAcTLNskHDeuUdNCWZxfqlcxViLSoaHAqOLYe88vbZqoyIMgRr4Z5QAYeGfciqugKWjQGIaebvE9M6qT)5UtnnGZ6anfmhaXCYinlaamHzbadI(SCDwUIfVyb9d6lctS4fil)CeMLhYI(kIL7zzfXIL73zbqU0yFqllOjUiXkRalEbYsCb9O)qqSSzXNuozp8hSWg8dmLqsFnjYWEM0RIq71vIc6lctMRYELqHhLd7uaifQRE3enxkCapxN9j41fYrln2hdcxViadq0ljfTaHVXb9O)qqzSfFsZGEQJIm)fa6kunnwhGiOYR3uuyGA4a2wbcFoxvtgSJGYD4KdE(QGIwQRE3mocQGlCUpufReMHs9RWagPaGAHmGFwf1HdkYGVQV059e4NMZBRqD17MXrqfCHZ9HQyLWSIAASwD17MXrqfCHZ9HQyLWSIAZjJ0SaaWela4l63zz79P7AnlrdmGz56SS9(0DTMLdxO7zzfXj7H)Gf2GFGPesWVpDxRr71vsD17gyr)oohrtGI(dwMvKc1vVBWVpDxRnd1hcV7QAIt2d)blSb)atjKe8kq6S6Q3rB5PKs43hnCar71vsD17g87JgoGMHs9RWagzkAPU6Ddf0xeMYyO2hZqP(v44rwtJ6Q3nuqFrykRxLpMHs9RWXJS2kC8pUohbTqt8iLK4KrAwIrR0imlXfdizrL6WHybnWcbeiILf(kuS87elObwiGarSeGf49hSy5HSe2PaqSCDwqdSqabIy5WS4HF5ADcwCv46z5HSOsSeC8Zj7H)Gf2GFGPesWVp41GIq71vkarqLxVPou7FU7Kce(CUQMmbyHaceLbjCIkOiaHAqOLYeGfciqu(3Pmo6M7XMHs9RWagzkSgCwhOPG5aiwbf0xeMmxL9kHch)JRZrql0ep6LeNmsZcaatSS9(0DTMfl3VZY2tATpSeJMR)S4filfKLT3hnCarllw2PILcYY27t31AwomlRi0Ysc4IfFiwUIfRyv(Wc6h0xeMyPdhwaeadtbmlWHLhYs0adSaixASpSyzNkwCvicIfKssSexmGKf4WIdg5)HGybBXNuw2DmlacGHPaMLHs9RUcflWHLdZYvS01hQ93WsSHpXYV7plRcKgw(DIfSNsSeGf49hSWSCp6WSagHzPO1pUMLhYY27t31AwaxZvOyjgZrqfCHzbaBOkwjqllw2PILeWf6azb)NwZcvGSSIyXY97SGuscyooILoCy53jw0o(zbLgQ6ASHt2d)blSb)atjKGFF6UwJ2RR07AQEd(jT2Nm4C93qLRQjqfw)UMQ3GFF0Wb0qLRQjqfQRE3GFF6UwBgQpeE3v1KIwQRE3qb9fHPSEv(ygk1VchpGqbf0xeMmxL1RYhfQRE3enxkCapxN9j41fYrln2hdcxViadqKLutJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaiYssHJ)X15iOfAIhPKutdi8noOh9hckJT4tAg0tDuKzOu)kC8aIMgp8hSmoOh9hckJT4tAg0tDuK5QCxFO2)2kcqOgeAPmbpFvWmuQFfoELtItgPzbaGjw2EFWRbfXca(I(DwIgyaZIxGSaUsJyjUyajlw2PIf0exKyLvGf4WYVtSeJNQFpXWI6Q3z5WS4QW1ZYdzP7AnlWENf4Wsc4cDGSe8iwIlgqYj7H)Gf2GFGPesWVp41GIq71vsD17gyr)ooh0Kpzeh(GLzf10OU6DdqxboeyMsJGwOjLQptfnOUyrMvutJ6Q3nbpFvWSIu0sD17MXrqfCHZ9HQyLWmuQFfgWOcGMuh5aFGoDlh)JRZrql0GuJtsTbwCa(31u9MISKtHWYqLRQjqfwpRI6WbfzWx1x68Ec8tZ5kux9UzCeubx4CFOkwjmROMg1vVBcE(QGzOu)kmGrfanPoYb(aD6wo(hxNJGwObPgNKA30OU6DZ4iOcUW5(qvSsKXx1x68Ec8tZ5Mvuttl1vVBghbvWfo3hQIvcZqP(vya7H)GLb)(0VHmeYPW6P8FPKcCeP15Dh)eGtYGEnnQRE3mocQGlCUpufReMHs9RWa2d)blJLX)DdHCkSEk)xk10GWNZv1K5IbWCawG3FWsrac1GqlL5kCywVRQPCmS86xPzqcXfiZqoycfumSUOic0CfomR3v1uogwE9R0miH4cuBfQRE3mocQGlCUpufReMvutJ1QRE3mocQGlCUpufReMvKcRdqOgeAPmJJGk4cN7dvXkHzihmrtJ1bicQ86niO63tmTBAC8pUohbTqt8iLKuqb9fHjZvzVsWjJ0Sy1jblpKLuhiILFNyrLWplWolBVpA4aYIAcwWVha6kuSCplRiwIH1fasNGLRyXReSG(b9fHjwuxplaYLg7dlhUEwCv46z5HSOsSenWqGa5K9WFWcBWpWucj43h8AqrO96k9UMQ3GFF0Wb0qLRQjqfwpRI6Wbfz(lLSaNkdoKNQEfinkAPU6Dd(9rdhqZkQPXX)46Ce0cnXJusQTc1vVBWVpA4aAWVhacWXrrl1vVBOG(IWugd1(ywrnnQRE3qb9fHPSEv(ywrTvOU6Dt0CPWb8CD2NGxxihT0yFmiC9Iamab0jPOvac1GqlLj45RcMHs9RWXRCsnnwJWNZv1KjaleqGOmiHtubfbicQ86n1HA)ZDNAZjJ0SG(4)s9NWSSdTWs6kSZsCXasw8HybLFfbYsenSGPaSa5K9WFWcBWpWucji85CvnH2YtjLCCeGKMnkGweUErkrb9fHjZvz9Q8b4beivp8hSm43N(nKHqofwpL)lLaM1uqFryYCvwVkFa(wahG9UMQ3GHlDg2Z)oL7WHWVHkxvtGaFCAJu9WFWYyz8F3qiNcRNY)Lsaljd6HmKkoI068UJFcyjzqgW)UMQ3u(VgcNvDTxbYqLRQjqozKMLy0knILT3h8AqrSCflolaAGHPalBqTpSG(b9fHj0YciSq3ZIMEwUNLObgybqU0yFyP1V7plhMLDVa1eilQjyHUFNgw(DILT3NUR1SOVIyboS87elXfdiJhPKel6Riw6WHLT3h8AqrTrllGWcDplqe0yzUNyXlwaWx0VZs0adS4filA6z53jwCvicIf9vel7EbQjw2EF0WbKt2d)blSb)atjKGFFWRbfH2RRK1ZQOoCqrM)sjlWPYGd5PQxbsJIwQRE3enxkCapxN9j41fYrln2hdcxViadqaDsnnQRE3enxkCapxN9j41fYrln2hdcxViadqKLKI31u9g8tATpzW56VHkxvtGTv0Ic6lctMRYyO2hfo(hxNJGwObyi85CvnzCCeGKMnka8QRE3qb9fHPmgQ9XmuQFfgyGW30xtImSNj9QiZFbGW5Hs9RaEaAqw8aIKAAOG(IWK5QSEv(OWX)46Ce0cnadHpNRQjJJJaK0SrbGxD17gkOVimL1RYhZqP(vyGbcFtFnjYWEM0RIm)facNhk1Vc4bObzXJusQTcRvx9Ubw0VJZr0eOO)GLzfPW631u9g87JgoGgQCvnbQOvac1GqlLj45RcMHs9RWXdOBAWWLw9kqZVpNwNXebengQCvnbQqD17MFFoToJjciAm43dab44ehauRzvuhoOid(Q(sN3tGFAoh4rwBf9d1(Nhk1VchVYjLKI(HA)ZdL6xHbmatkP2kAfGqni0sza6kWHaZ4OBUhBgk1VchpGUPX6aebvE9gGsmNxT5KrAwaayIfaCqyHz5kwSIv5dlOFqFryIfVazb7iiwIX11DGbGT0AwaWbHflD4WcAIlsSYkWIxGSaC)kWHazb9tJGwOjLQNt2d)blSb)atjKuKLCkewO96k1sD17gkOVimL1RYhZqP(v44jKtH1t5)sPMMwHDFqryLaOIHc7(GIY)LsagzTBAc7(GIWkfN2k8OCyNcaPaHpNRQjd2rq5oCYbpFvGt2d)blSb)atjKS76Eofcl0EDLAPU6Ddf0xeMY6v5JzOu)kC8eYPW6P8FPKcRdqeu51BakXCE100sD17gGUcCiWmLgbTqtkvFMkAqDXImRifbicQ86naLyoVA300kS7dkcReavmuy3huu(VucWiRDtty3huewP400OU6DtWZxfmRO2k8OCyNcaPaHpNRQjd2rq5oCYbpFvqrl1vVBghbvWfo3hQIvcZqP(vya3czaiac8ZQOoCqrg8v9LoVNa)0CEBfQRE3mocQGlCUpufReMvutJ1QRE3mocQGlCUpufReMvuBozp8hSWg8dmLqsFP15uiSq71vQL6Q3nuqFrykRxLpMHs9RWXtiNcRNY)LskSoarqLxVbOeZ5vttl1vVBa6kWHaZuAe0cnPu9zQOb1flYSIueGiOYR3auI58QDttRWUpOiSsauXqHDFqr5)sjaJS2nnHDFqryLIttJ6Q3nbpFvWSIARWJYHDkaKce(CUQMmyhbL7Wjh88vbfTux9UzCeubx4CFOkwjmdL6xHbmYuOU6DZ4iOcUW5(qvSsywrkSEwf1HdkYGVQV059e4NMZBASwD17MXrqfCHZ9HQyLWSIAZjJ0SaaWelaxq0NfyXsaKt2d)blSb)atjKyXN5Gtg2ZKEveNmsZcaatSS9(0VHy5HSenWalBqTpSG(b9fHj0YcAIlsSYkWYUJzrtyml)LsS87EXIZcW14)oleYPW6jw0u)zboSalDcwSIv5dlOFqFryILdZYkIt2d)blSb)atjKGFF63qO96krb9fHjZvz9Q8PPHc6lctgmu7tUiK)nnuqFryY4vICri)BAAPU6DJfFMdozypt6vrMvutdoI068UJFcWjzqpKPW6aebvE9geu97jMMgCeP15Dh)eGtYGEkcqeu51Bqq1VNyARqD17gkOVimL1RYhZkQPPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKtH1t5)sjfQRE3e88vbZkQnNmsZcaatSaCn(VZc83PXYHjwSSFHDwomlxXYgu7dlOFqFrycTSGM4IeRScSahwEilrdmWIvSkFyb9d6lctCYE4pyHn4hykHelJ)7CYinlayUw)7ZIt2d)blSb)atjKmRk7H)GvwF4hTLNsk1DT(3NL9goIc2Xw5KaO9B)22a]] )

end