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


    spec:RegisterPack( "Balance", 20210724, [[di1HNfqikjpcsjxcII2ej8jivnkPKtjLAvaQ6vakZcsLBba1UO4xqedte5yKOwga5zcfnnikDnifBdqL(gakJdaX5auX6aq18aOUhjY(eQ6Fqui1bfQ0cfk1dHOAIcfYfHuQncaXhfkuyKcfk6KusPvkI6LquOMjLuCtaizNcv8tai1qbq6OquizPcfQEQs1uPKQRcaSvHcL(kefmwaq7Ls9xrnyIdt1IjPhlyYaDzKnlvFgsgTs50QSAikeVgqMnPUTiTBj)g0WfYXfky5kEoutxvxxjBhcFNsmEisNxewVqjZxk2pQTv22627G(t2XbqjbiLtcGbiK1OCsXuz0yV)jIi79ipaKJIS3lpLS3JTR9kq27rEcn0bTTU9ogUMazVV9FegGJeKO6AVceagFPbdQ73wQMdIKy7AVceaE)srossbnBFQgz09ttkP6AVcK5r6BVRUo9BTLTQ9oO)KDCausas5KayacznkNumvgzrJ9UV(n4yVVFPi3EF7abPYw1EhKWb79y7AVcelXOzDGCYjV0jybqil6ybqjbiL5K5Kr(MxOimaNtgaZsCbbjqw2HAFyj2KNA4KbWSG8nVqrGS8(GI(81zj4ycZYdzjKiOP87dk6XgozamlX4ukebbYYQkkqySpjybHpNRQjmlTodzqhlrdHiJFFWRbfXcaoEwIgcHb)(GxdkQTHtgaZsCrapqwIgk44)kuSGmm(VXY1z5E0Jz53iwSmWcflODqFryYWjdGzbaLdeXcYHfciqel)gXYE0n3JzXzrF)RjwsHdXsxti9u1elTUoljGlw2CWc9plB3ZY9SGV0L(9IGlSoblwUFJLydGoUwNfGXcYjnH)Z1Sex9HQsP6rhl3JEqwWaDrTnCYaywaq5arSKcXplOVFO2(8qP(vy0ZcoqLpheZIhfPtWYdzrfIXS0puBpMfyPty4KbWSy9H8NfRdtjwGDwIT23yj2AFJLyR9nwCmlol4ikCUMLFUci6n276d)yBRBVdsDFPFBRBhhLTTU9Uh(dw27yO2NSk5P27u5QAc0o22VDCaKT1T3PYv1eODST3Hr27y6T39WFWYEhHpNRQj7DeUEr274isRZVpOOhBWVpDxRzjEwuMffS0IfRy5DnvVb)(OHdOHkxvtGS00WY7AQEd(jT2Nm4C93qLRQjqwAZstdl4isRZVpOOhBWVpDxRzjEwaK9oiHdZf9hSS33PhZsCHOnlWILycmwSC)gC9Saox)zXlqwSC)gl7VpA4aYIxGSaiGXc83OXYHj7De(KlpLS3pC2HK9BhNyABD7DQCvnbAhB7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9ooI0687dk6Xg87t)gIL4zrz7DqchMl6pyzVVtpMLGMCeelw2OIL93N(nelbVyz7EwaeWy59bf9ywSSDHnwomldPjeE9S0Hdl)gXcAh0xeMy5HSOsSenuNMHazXlqwSSDHnw6NwtdlpKLGJF7De(KlpLS3pCoOjhbz)2XbzTTU9ovUQMaTJT9Uh(dw27Q0GPbORqzVds4WCr)bl7DaaMyj20GPbORqXIL73yb5XfjwBfyboS49NgwqoSqabIy5kwqECrI1wb79WCpnNBV3ILwSyflbicQ86n1HA7ZDNyPPHfRyjaHAqOLYeGfciqu(3Omo6M7XMvelTzrblQRE3e88vbZqP(vywINfLrdlkyrD17MXrqfCHZ9HQyLWmuQFfMfaZcYYIcwSILaebvE9geu9BjgwAAyjarqLxVbbv)wIHffSOU6DtWZxfmRiwuWI6Q3nJJGk4cN7dvXkHzfXIcwAXI6Q3nJJGk4cN7dvXkHzOu)kmlaMfLvMfamlOHfGNLzvuhoOid(Q(sN3sGFAo3qLRQjqwAAyrD17MGNVkygk1VcZcGzrzLzPPHfLzbjSGJiToV54NybWSOSbnOHL2S0MffSGkaAgk1VcZs8SKK9Bhh0yBD7DQCvnbAhB79WCpnNBVRU6DtWZxfmdL6xHzjEwugnSOGLwSyflZQOoCqrg8v9LoVLa)0CUHkxvtGS00WI6Q3nJJGk4cN7dvXkHzOu)kmlaMfLbySaGzbqSa8SOU6DJQgcb1l8BwrSOGf1vVBghbvWfo3hQIvcZkIL2S00WIkeJzrbl9d12Nhk1VcZcGzbqOXEhKWH5I(dw27au4ZIL73yXzb5XfjwBfy538NLdxO)zXzbGU0yFyjAGbwGdlw2OILFJyPFO2EwomlUkC9S8qwOc0E3d)bl79i4FWY(TJdW12627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi79aDAwAXslw6hQTppuQFfMfamlkJgwaWSeGqni0szcE(QGzOu)kmlTzbjSOmajjwAZIsSeOtZslwAXs)qT95Hs9RWSaGzrz0WcaMLaeQbHwktawiGar5FJY4OBUhBaxJ)hSybaZsac1GqlLjaleqGO8VrzC0n3JndL6xHzPnliHfLbijXsBwuWIvSm(bMjeu9gheeBiKE4hZstdlbiudcTuMGNVkygk1VcZs8SC1tteu7pbM7hQTppuQFfMLMgwcqOgeAPmbyHaceL)nkJJU5ESzOu)kmlXZYvpnrqT)eyUFO2(8qP(vywaWSOCsS00WIvSeGiOYR3uhQTp3DYEhKWH5I(dw27i31HL2FcZILn63OHLf(kuSGCyHaceXsbTWILtRzX1AOfwsaxS8qwW)P1SeC8ZYVrSG9uIfpfUQNfyNfKdleqGiGH84IeRTcSeC8JT3r4tU8uYEpaleqGOmiHtub73ooamBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3BXs)qT95Hs9RWSeplkJgwAAyz8dmtiO6noii2CflXZcAsIL2SOGLwS0ILwSqXW6IIiqdLgLyixNHdy5vGyrblTyjaHAqOLYqPrjgY1z4awEfiZqP(vywamlkdCtILMgwcqeu51Bqq1VLyyrblbiudcTugknkXqUodhWYRazgk1VcZcGzrzGlaJfGXslwuwzwaEwMvrD4GIm4R6lDElb(P5CdvUQMazPnlTzrblwXsac1GqlLHsJsmKRZWbS8kqMHCWeS0MLMgwOyyDrreObdxAn9)vOYZsnblkyPflwXsaIGkVEtDO2(C3jwAAyjaHAqOLYGHlTM()ku5zPMihtKfnaKKu2muQFfMfaZIYkJSS0MLMgwAXsac1GqlLrLgmnaDfkZqoycwAAyXkwgpqMFGAnlTzrblTyPflumSUOic0CfomR3v1uogwE9R0miH4celkyjaHAqOLYCfomR3v1uogwE9R0miH4cKzihmblTzPPHLwSqXW6IIiqdEZbHwiWmCuZWE(HtkvplkyjaHAqOLY8WjLQNaZxHpuBFoMObnXeqkBgk1VcZsBwAAyPflTybHpNRQjdSYlmL)5kGONfLyrzwAAybHpNRQjdSYlmL)5kGONfLyjMS0MffS0ILFUci6nVYMHCWe5aeQbHwkwAAy5NRaIEZRSjaHAqOLYmuQFfML4z5QNMiO2Fcm3puBFEOu)kmlaywuojwAZstdli85CvnzGvEHP8pxbe9SOelaIffS0ILFUci6npGmd5GjYbiudcTuS00WYpxbe9MhqMaeQbHwkZqP(vywINLREAIGA)jWC)qT95Hs9RWSaGzr5KyPnlnnSGWNZv1Kbw5fMY)Cfq0ZIsSKelTzPnlTzPPHLaebvE9gGsmNxS0MLMgwuHymlkyPFO2(8qP(vywamlQRE3e88vbd4A8)GL9oiHdZf9hSS3baycKLhYciP9eS8BellSJIyb2zb5XfjwBfyXYgvSSWxHIfq4svtSalwwyIfVazjAieu9SSWokIflBuXIxS4GGSqiO6z5WS4QW1ZYdzb8i7De(KlpLS3dG5aSaV)GL9BhhaIT1T3PYv1eODST3Hr27y6T39WFWYEhHpNRQj7DeUEr27wXcgU0QxbA(T506mMiGOXqLRQjqwAAyPFO2(8qP(vywINfaLusS00WIkeJzrbl9d12Nhk1VcZcGzbqOHfGXslwq2KybaZI6Q3n)2CADgteq0yWVhaIfGNfaXsBwAAyrD17MFBoToJjciAm43daXs8SetaclaywAXYSkQdhuKbFvFPZBjWpnNBOYv1eilaplOHL227Geomx0FWYEpgRpNRQjwwycKLhYciP9eS4vcw(5kGOhZIxGSeaXSyzJkwS43Ffkw6WHfVybTxrBW5CwIgyWEhHp5Ytj79FBoToJjciAYw87TF74aCSTU9ovUQMaTJT9oiHdZf9hSS3bayIf0onkXqUMfa0dy5vGybqjHPaMfvQdhIfNfKhxKyTvGLfMm27LNs27uAuIHCDgoGLxbYEpm3tZ527biudcTuMGNVkygk1VcZcGzbqjXIcwcqOgeAPmbyHaceL)nkJJU5ESzOu)kmlaMfaLelkyPfli85Cvnz(T506mMiGOjBXVNLMgwux9U53MtRZyIaIgd(9aqSeplXmjwaglTyzwf1HdkYGVQV05Te4NMZnu5QAcKfGNfGllTzPnlkybva0muQFfML4zjjwAAyrfIXSOGL(HA7ZdL6xHzbWSetaM9Uh(dw27uAuIHCDgoGLxbY(TJJYjzBD7DQCvnbAhB7DqchMl6pyzVdaWel7WLwt)vOyjgFPMGfGlMcywuPoCiwCwqECrI1wbwwyYyVxEkzVJHlTM()ku5zPMWEpm3tZ527TyjaHAqOLYe88vbZqP(vywamlaxwuWIvSeGiOYR3GGQFlXWIcwSILaebvE9M6qT95UtS00WsaIGkVEtDO2(C3jwuWsac1GqlLjaleqGO8VrzC0n3JndL6xHzbWSaCzrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLj45RcMHs9RWSaywaUS0MLMgwcqeu51Bqq1VLyyrblTyXkwMvrD4GIm4R6lDElb(P5CdvUQMazrblbiudcTuMGNVkygk1VcZcGzb4YstdlQRE3mocQGlCUpufReMHs9RWSaywugzzbyS0If0WcWZcfdRlkIanxH)zfE4GZGhIROSkP1S0MffSOU6DZ4iOcUW5(qvSsywrS0MLMgwuHymlkyPFO2(8qP(vywamlacnS00WcfdRlkIanuAuIHCDgoGLxbIffSeGqni0szO0Oed56mCalVcKzOu)kmlXZsmtIL2SOGfubqZqP(vywINLKS39WFWYEhdxAn9)vOYZsnH9BhhLv22627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi7D1vVBcE(QGzOu)kmlXZIYOHffS0IfRyzwf1HdkYGVQV05Te4NMZnu5QAcKLMgwux9UzCeubx4CFOkwjmdL6xHzbWkXIYaIfGXslwIjlaplQRE3OQHqq9c)MvelTzbyS0ILwSaqybaZcAyb4zrD17gvnecQx43SIyPnlaplumSUOic0Cf(Nv4HdodEiUIYQKwZsBwuWI6Q3nJJGk4cN7dvXkHzfXsBwAAyrfIXSOGL(HA7ZdL6xHzbWSai0WstdlumSUOic0qPrjgY1z4awEfiwuWsac1GqlLHsJsmKRZWbS8kqMHs9RW27Geomx0FWYEpUAlEcmllmXI1ImQyelwUFJfKhxKyTvWEhHp5Ytj79lgaZbybE)bl73ookdiBRBVtLRQjq7yBV7H)GL9(v4WSExvt5yy51VsZGeIlq27H5EAo3EhHpNRQjZfdG5aSaV)Gflkybva0muQFfML4zjj79Ytj79RWHz9UQMYXWYRFLMbjexGSF74OCmTTU9ovUQMaTJT9oiHdZf9hSS3bayIL5qT9SOsD4qSeaX27LNs274nheAHaZWrnd75hoPu927H5EAo3EVflbiudcTuMGNVkygYbtWIcwSILaebvE9M6qT95UtSOGfe(CUQMm)2CADgteq0KT43ZstdlbicQ86n1HA7ZDNyrblbiudcTuMaSqabIY)gLXr3Cp2mKdMGffS0Ife(CUQMmbyHaceLbjCIkWstdlbiudcTuMGNVkygYbtWsBwAZIcwaHVbVQ(nK5VaqxHIffS0Ifq4BWpP1(K7AFiZFbGUcflnnSyflVRP6n4N0AFYDTpKHkxvtGS00WcoI0687dk6Xg87t)gIL4zjMS0MffS0Ifq4BsHWQFdz(la0vOyPnlkyPfli85CvnzoC2HelnnSmRI6WbfzuDTxbkd7zxRZ)2vOWgQCvnbYstdlo(hxNJGwOHL4vIfGtsS00WI6Q3nQAieuVWVzfXsBwuWslwcqOgeAPmQ0GPbORqzgYbtWstdlwXY4bY8duRzPnlnnSOcXywuWs)qT95Hs9RWSaywq2KS39WFWYEhV5GqleygoQzyp)WjLQ3(TJJYiRT1T3PYv1eODST3bjCyUO)GL9U13omlhMfNLX)nAyH0UkC8NyXINGLhYsQdeXIR1SalwwyIf87pl)Cfq0Jz5HSOsSOVIazzfXIL73yb5XfjwBfyXlqwqoSqabIyXlqwwyILFJybqfilyn8zbwSeaz56SOc)nw(5kGOhZIpelWILfMyb)(ZYpxbe9y79WCpnNBV3Ife(CUQMmWkVWu(NRaIEwSsjwuMffSyfl)Cfq0BEazgYbtKdqOgeAPyPPHLwSGWNZv1Kbw5fMY)Cfq0ZIsSOmlnnSGWNZv1Kbw5fMY)Cfq0ZIsSetwAZIcwAXI6Q3nbpFvWSIyrblTyXkwcqeu51Bqq1VLyyPPHf1vVBghbvWfo3hQIvcZqP(vywaglTybnSa8SmRI6WbfzWx1x68wc8tZ5gQCvnbYsBwaSsS8ZvarV5v2OU69m4A8)GflkyrD17MXrqfCHZ9HQyLWSIyPPHf1vVBghbvWfo3hQIvIm(Q(sN3sGFAo3SIyPnlnnSeGqni0szcE(QGzOu)kmlaJfaXs8S8ZvarV5v2eGqni0szaxJ)hSyrblwXI6Q3nbpFvWSIyrblTyXkwcqeu51BQd12N7oXstdlwXccFoxvtMaSqabIYGeorfyPnlkyXkwcqeu51BakXCEXstdlbicQ86n1HA7ZDNyrbli85CvnzcWcbeikds4evGffSeGqni0szcWcbeik)BughDZ9yZkIffSyflbiudcTuMGNVkywrSOGLwS0If1vVBOG(IWuwVkFmdL6xHzjEwuojwAAyrD17gkOVimLXqTpMHs9RWSeplkNelTzrblwXYSkQdhuKr11EfOmSNDTo)BxHcBOYv1eilnnS0If1vVBuDTxbkd7zxRZ)2vOW5Y)1qg87bGyrjwqdlnnSOU6DJQR9kqzyp7AD(3Ucfo7tWlYGFpaelkXcaHL2S0MLMgwux9UbORahcmtPrql0Ks1NPIguxSiZkIL2S00Ws)qT95Hs9RWSaywausS00WccFoxvtgyLxyk)ZvarplkXssS0MffSGkaAgk1VcZs8SKK9owdFS9(pxbe9kBV7H)GL9(pxbe9kB)2Xrz0yBD7DQCvnbAhB7Dp8hSS3)5kGOhq27H5EAo3EVfli85CvnzGvEHP8pxbe9SyLsSaiwuWIvS8ZvarV5v2mKdMihGqni0sXstdli85CvnzGvEHP8pxbe9SOelaIffS0If1vVBcE(QGzfXIcwAXIvSeGiOYR3GGQFlXWstdlQRE3mocQGlCUpufReMHs9RWSamwAXcAyb4zzwf1HdkYGVQV05Te4NMZnu5QAcKL2SayLy5NRaIEZdiJ6Q3ZGRX)dwSOGf1vVBghbvWfo3hQIvcZkILMgwux9UzCeubx4CFOkwjY4R6lDElb(P5CZkIL2S00Wsac1GqlLj45RcMHs9RWSamwaelXZYpxbe9MhqMaeQbHwkd4A8)GflkyXkwux9Uj45RcMvelkyPflwXsaIGkVEtDO2(C3jwAAyXkwq4Z5QAYeGfciqugKWjQalTzrblwXsaIGkVEdqjMZlwuWslwSIf1vVBcE(QGzfXstdlwXsaIGkVEdcQ(TedlTzPPHLaebvE9M6qT95UtSOGfe(CUQMmbyHaceLbjCIkWIcwcqOgeAPmbyHaceL)nkJJU5ESzfXIcwSILaeQbHwktWZxfmRiwuWslwAXI6Q3nuqFrykRxLpMHs9RWSeplkNelnnSOU6Ddf0xeMYyO2hZqP(vywINfLtIL2SOGfRyzwf1HdkYO6AVcug2ZUwN)TRqHnu5QAcKLMgwAXI6Q3nQU2RaLH9SR15F7ku4C5)Aid(9aqSOelOHLMgwux9Ur11EfOmSNDTo)BxHcN9j4fzWVhaIfLybGWsBwAZsBwAAyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwAAyrfIXSOGL(HA7ZdL6xHzbWSaOKyPPHfe(CUQMmWkVWu(NRaIEwuILKyPnlkybva0muQFfML4zjj7DSg(y79FUci6bK9BhhLbU2w3ENkxvtG2X2EhKWH5I(dw27aamHzX1AwG)gnSalwwyIL7PumlWILaO9Uh(dw27lmLVNsX2VDCugGzBD7DQCvnbAhB7DqchMl6pyzVhJOWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDy7Dp8hSS3NvL9WFWkRp8BVJ)5cVDCu2Epm3tZ527i85CvnzoC2HK9U(WFU8uYE3HK9BhhLbi2w3ENkxvtG2X2Epm3tZ527ZQOoCqrgvx7vGYWE2168VDfkSHIH1ffrG274FUWBhhLT39WFWYEFwv2d)bRS(WV9U(WFU8uYExf6V9BhhLbo2w3ENkxvtG2X2E3d)bl79zvzp8hSY6d)276d)5Ytj7D8B)2V9Uk0FBRBhhLTTU9ovUQMaTJT9Uh(dw27JJGk4cN7dvXkH9oiHdZf9hSS3bqgQIvcwSC)glipUiXARG9EyUNMZT3vx9Uj45RcMHs9RWSeplkJg73ooaY2627u5QAc0o227E4pyzV7GE0FiOm2IpP27HebnLFFqrp2ookBVhM7P5C7D1vVBuDTxbkd7zxRZ)2vOW5Y)1qg87bGybWSaqyrblQRE3O6AVcug2ZUwN)TRqHZ(e8Im43daXcGzbGWIcwAXIvSacFJd6r)HGYyl(KMb9uhfz(la0vOyrblwXIh(dwgh0J(dbLXw8jnd6PokYCvURpuBplkyPflwXci8noOh9hckJT4tAEJCT5VaqxHILMgwaHVXb9O)qqzSfFsZBKRndL6xHzjEwIjlTzPPHfq4BCqp6peugBXN0mON6Oid(9aqSaywIjlkybe(gh0J(dbLXw8jnd6PokYmuQFfMfaZcAyrblGW34GE0FiOm2IpPzqp1rrM)caDfkwABVds4WCr)bl7DaaMyjUGE0Fiiw2T4tklw2OIf)zrtyml)MxSGSSeByCTol43daHzXlqwEild1hcVXIZcGvcqSGFpaeloMfT)eloMLiigFQAIf4WYFPel3ZcgYY9S4ZCiimliJSWplE)PHfNLycmwWVhaIfcPr3qy73ooX02627u5QAc0o227E4pyzVhGfciqu(3Omo6M7X27Geomx0FWYEhaGjwqoSqabIyXY9BSG84IeRTcSyzJkwIGy8PQjw8cKf4VrJLdtSy5(nwCwInmUwNf1vVZILnQybKWjQWvOS3dZ90CU9UvSaoRd0uWCaeZIcwAXslwq4Z5QAYeGfciqugKWjQalkyXkwcqOgeAPmbpFvWmKdMGLMgwux9Uj45RcMvelTzrblTyrD17gvx7vGYWE2168VDfkCU8FnKb)EaiwuIfaclnnSOU6DJQR9kqzyp7AD(3Ucfo7tWlYGFpaelkXcaHL2S00WIkeJzrbl9d12Nhk1VcZcGzr5KyPT9BhhK12627u5QAc0o227E4pyzV3xtImSNj9Qi7DqchMl6pyzVdGarBwCml)gXs)g8ZcQailxXYVrS4SeByCTolwUceAHf4WIL73y53iwqgNyoVyrD17SahwSC)glolaeGHPalXf0J(dbXYUfFszXlqwS43ZshoSG84IeRTcSCDwUNflW6zrLyzfXIJYVIfvQdhILFJyjaYYHzPF1H3iq79WCpnNBV3ILwS0If1vVBuDTxbkd7zxRZ)2vOW5Y)1qg87bGyjEwaUS00WI6Q3nQU2RaLH9SR15F7ku4SpbVid(9aqSeplaxwAZIcwAXIvSeGiOYR3GGQFlXWstdlwXI6Q3nJJGk4cN7dvXkHzfXsBwAZIcwAXc4SoqtbZbqmlnnSeGqni0szcE(QGzOu)kmlXZcAsILMgwAXsaIGkVEtDO2(C3jwuWsac1GqlLjaleqGO8VrzC0n3JndL6xHzjEwqtsS0ML2S0MLMgwAXci8noOh9hckJT4tAg0tDuKzOu)kmlXZcaHffSeGqni0szcE(QGzOu)kmlXZIYjXIcwcqeu51BkkmqnCazPnlnnSC1tteu7pbM7hQTppuQFfMfaZcaHffSyflbiudcTuMGNVkygYbtWstdlbicQ86naLyoVyrblQRE3a0vGdbMP0iOfAsP6nRiwAAyjarqLxVbbv)wIHffSOU6DZ4iOcUW5(qvSsygk1VcZcGzb4WIcwux9UzCeubx4CFOkwjmRi73ooOX2627u5QAc0o227E4pyzVh8kq6S6Q3T3dZ90CU9Elwux9Ur11EfOmSNDTo)BxHcNl)xdzgk1VcZs8SaWmOHLMgwux9Ur11EfOmSNDTo)BxHcN9j4fzgk1VcZs8SaWmOHL2SOGLwSeGqni0szcE(QGzOu)kmlXZcaJLMgwAXsac1GqlLHsJGwOjRclqZqP(vywINfaglkyXkwux9UbORahcmtPrql0Ks1NPIguxSiZkIffSeGiOYR3auI58IL2S0MffS44FCDocAHgwIxjwIzs27QREpxEkzVJFF0Wb0EhKWH5I(dw27i3RaPzz)9rdhqwSC)glolfzHLydJR1zrD17S4filipUiXARalhUq)ZIRcxplpKfvILfMaTF74aCTTU9ovUQMaTJT9Uh(dw2743h8Aqr27Geomx0FWYEpgTsJyz)9bVgueMfl3VXIZsSHX16SOU6Dwuxplf8zXYgvSebH6RqXshoSG84IeRTcSahwqgFf4qGSShDZ9y79WCpnNBV3If1vVBuDTxbkd7zxRZ)2vOW5Y)1qg87bGyjEwaelnnSOU6DJQR9kqzyp7AD(3Ucfo7tWlYGFpaelXZcGyPnlkyPflbicQ86n1HA7ZDNyPPHLaeQbHwktWZxfmdL6xHzjEwayS00WIvSGWNZv1KjaMdWc8(dwSOGfRyjarqLxVbOeZ5flnnS0ILaeQbHwkdLgbTqtwfwGMHs9RWSeplamwuWIvSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelkyjarqLxVbOeZ5flTzPnlkyPflwXci8n91Kid7zsVkY8xaORqXstdlwXsac1GqlLj45RcMHCWeS00WIvSeGqni0szcWcbeik)BughDZ9yZqoycwAB)2XbGzBD7DQCvnbAhB7Dp8hSS3XVp41GIS3bjCyUO)GL9EmALgXY(7dEnOimlQuhoelihwiGar27H5EAo3EVflbiudcTuMaSqabIY)gLXr3Cp2muQFfMfaZcAyrblwXc4SoqtbZbqmlkyPfli85CvnzcWcbeikds4evGLMgwcqOgeAPmbpFvWmuQFfMfaZcAyPnlkybHpNRQjtamhGf49hSyPnlkyXkwaHVPVMezypt6vrM)caDfkwuWsaIGkVEtDO2(C3jwuWIvSaoRd0uWCaeZIcwOG(IWK5QSxjyrblo(hxNJGwOHL4zbztY(TJdaX2627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi79wSOU6DZ4iOcUW5(qvSsygk1VcZs8SGgwAAyXkwux9UzCeubx4CFOkwjmRiwAZIcwAXI6Q3naDf4qGzkncAHMuQ(mv0G6Ifzgk1VcZcGzbva0K6iLL2SOGLwSOU6Ddf0xeMYyO2hZqP(vywINfubqtQJuwAAyrD17gkOVimL1RYhZqP(vywINfubqtQJuwABVds4WCr)bl79yeSq)Zci8zbCnxHILFJyHkqwGDwIXDeubxywaqgQIvc0Xc4AUcflaDf4qGSqPrql0Ks1ZcCy5kw(nIfTJFwqfazb2zXlwq7G(IWK9ocFYLNs27GWppumSUHsP6X2VDCao2w3ENkxvtG2X2E3d)bl7D8Q63q27H5EAo3EFO(q4nxvtSOGL3hu0B(lLYpmdEelXZIYaxwuWIhLdBuaiwuWccFoxvtgq4Nhkgw3qPu9y79qIGMYVpOOhBhhLTF74OCs2w3ENkxvtG2X2E3d)bl79uiS63q27H5EAo3EFO(q4nxvtSOGL3hu0B(lLYpmdEelXZIYX0GgwuWIhLdBuaiwuWccFoxvtgq4Nhkgw3qPu9y79qIGMYVpOOhBhhLTF74OSY2w3ENkxvtG2X2E3d)bl7D8tATp5U2hYEpm3tZ527d1hcV5QAIffS8(GIEZFPu(HzWJyjEwug4YcWyzOu)kmlkyXJYHnkaelkybHpNRQjdi8ZdfdRBOuQES9Eirqt53hu0JTJJY2VDCugq2w3ENkxvtG2X2E3d)bl79oCcug2ZL)RHS3bjCyUO)GL9oacmoSalwcGSy5(n46zj4rrxHYEpm3tZ527EuoSrbGSF74OCmTTU9ovUQMaTJT9Uh(dw27uAe0cnzvybAVds4WCr)bl7D0oncAHgwInSazXYgvS4QW1ZYdzHQNgwCwkYclXggxRZILRaHwyXlqwWocILoCyb5XfjwBfS3dZ90CU9ElwOG(IWKrVkFYfH0NLMgwOG(IWKbd1(KlcPplnnSqb9fHjJxjYfH0NLMgwux9Ur11EfOmSNDTo)BxHcNl)xdzgk1VcZs8SaWmOHLMgwux9Ur11EfOmSNDTo)BxHcN9j4fzgk1VcZs8SaWmOHLMgwC8pUohbTqdlXZcWjjwuWsac1GqlLj45RcMHCWeSOGfRybCwhOPG5aiML2SOGLwSeGqni0szcE(QGzOu)kmlXZsmtILMgwcqOgeAPmbpFvWmKdMGL2S00WYvpnrqT)eyUFO2(8qP(vywamlkNK9BhhLrwBRBVtLRQjq7yBV7H)GL9EFnjYWEM0RIS3bjCyUO)GL9oaceTzzouBplQuhoell8vOyb5X1Epm3tZ527biudcTuMGNVkygYbtWIcwq4Z5QAYeaZbybE)blwuWslwC8pUohbTqdlXZcWjjwuWIvSeGiOYR3uhQTp3DILMgwcqeu51BQd12N7oXIcwC8pUohbTqdlaMfKnjwAZIcwSILaebvE9geu9BjgwuWslwSILaebvE9M6qT95UtS00Wsac1GqlLjaleqGO8VrzC0n3Jnd5GjyPnlkyXkwaN1bAkyoaITF74OmASTU9ovUQMaTJT9omYEhtV9Uh(dw27i85CvnzVJW1lYE3kwaN1bAkyoaIzrbli85CvnzcG5aSaV)GflkyPflTyXX)46Ce0cnSeplaNKyrblTyrD17gGUcCiWmLgbTqtkvFMkAqDXImRiwAAyXkwcqeu51BakXCEXsBwAAyrD17gvnecQx43SIyrblQRE3OQHqq9c)MHs9RWSaywux9Uj45RcgW14)blwAZstdlx90eb1(tG5(HA7ZdL6xHzbWSOU6DtWZxfmGRX)dwS00WsaIGkVEtDO2(C3jwAZIcwAXIvSeGiOYR3uhQTp3DILMgwAXIJ)X15iOfAybWSGSjXstdlGW30xtImSNj9QiZFbGUcflTzrblTybHpNRQjtawiGarzqcNOcS00Wsac1GqlLjaleqGO8VrzC0n3Jnd5GjyPnlTT3bjCyUO)GL9oYJlsS2kWILnQyXFwaojbmwIlgGYsl4OHwOHLFZlwq2KyjUyaklwUFJfKdleqGO2Sy5(n46zrdXxHIL)sjwUILyRHqq9c)S4fil6RiwwrSy5(nwqoSqabIy56SCplwCmlGeorfiq7De(KlpLS3dG5aSaV)Gvwf6V9BhhLbU2w3ENkxvtG2X2Epm3tZ527i85CvnzcG5aSaV)Gvwf6V9Uh(dw27bst4)CD21hQkLQ3(TJJYamBRBVtLRQjq7yBVhM7P5C7De(CUQMmbWCawG3FWkRc93E3d)bl79Rc(u(FWY(TJJYaeBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3PG(IWK5QSEv(WcWZcaHfKWIh(dwg87t)gYqiLcRNY)LsSamwSIfkOVimzUkRxLpSa8S0IfGllaJL31u9gmCPZWE(3OChoe(nu5QAcKfGNLyYsBwqclE4pyzSm(VziKsH1t5)sjwagljzaeliHfCeP15nh)K9oiHdZf9hSS3rB8FP(tyw2GwyjDf2yjUyakl(qSGYVIazjIgwWuawG27i8jxEkzV74iakn7uW(TJJYahBRBVtLRQjq7yBV7H)GL9o(9bVguK9oiHdZf9hSS3JrR0iw2FFWRbfHzXYgvS8Bel9d12ZYHzXvHRNLhYcvGOJL(qvSsWYHzXvHRNLhYcvGOJLeWfl(qS4plaNKaglXfdqz5kw8If0oOVimHowqECrI1wbw0o(XS4f83OHfacWWuaZcCyjbCXIf4sdYcebnbpILu4qS8BEXc3OCsSexmaLflBuXsc4IflWLgSq)ZY(7dEnOiwkOf79WCpnNBV3ILREAIGA)jWC)qT95Hs9RWSaywqwwAAyPflQRE3mocQGlCUpufReMHs9RWSaywqfanPoszb4zjqNMLwS44FCDocAHgwqclXmjwAZIcwux9UzCeubx4CFOkwjmRiwAZsBwAAyPflo(hxNJGwOHfGXccFoxvtghhbqPzNcSa8SOU6Ddf0xeMYyO2hZqP(vywaglGW30xtImSNj9QiZFbGW5Hs9Ryb4zbqg0Ws8SOSYjXstdlo(hxNJGwOHfGXccFoxvtghhbqPzNcSa8SOU6Ddf0xeMY6v5JzOu)kmlaJfq4B6Rjrg2ZKEvK5Vaq48qP(vSa8SaidAyjEwuw5KyPnlkyHc6lctMRYELGffS0IfRyrD17MGNVkywrS00WIvS8UMQ3GFF0Wb0qLRQjqwAZIcwAXslwSILaeQbHwktWZxfmRiwAAyjarqLxVbOeZ5flkyXkwcqOgeAPmuAe0cnzvybAwrS0MLMgwcqeu51BQd12N7oXsBwuWslwSILaebvE9geu9BjgwAAyXkwux9Uj45RcMvelnnS44FCDocAHgwINfGtsS0MLMgwAXY7AQEd(9rdhqdvUQMazrblQRE3e88vbZkIffS0If1vVBWVpA4aAWVhaIfaZsmzPPHfh)JRZrql0Ws8SaCsIL2S0MLMgwux9Uj45RcMvelkyXkwux9UzCeubx4CFOkwjmRiwuWIvS8UMQ3GFF0Wb0qLRQjq73ooakjBRBVtLRQjq7yBV7H)GL9ErwYPqyzVds4WCr)bl7DaaMybafewywUIfRzv(WcAh0xeMyXlqwWocILymDDhyailTMfauqyXshoSG84IeRTc27H5EAo3EVflQRE3qb9fHPSEv(ygk1VcZs8SqiLcRNY)LsS00WslwcB(GIWSOelaIffSmuyZhuu(VuIfaZcAyPnlnnSe28bfHzrjwIjlTzrblEuoSrbGSF74aiLTTU9ovUQMaTJT9EyUNMZT3BXI6Q3nuqFrykRxLpMHs9RWSeplesPW6P8FPelkyPflbiudcTuMGNVkygk1VcZs8SGMKyPPHLaeQbHwktawiGar5FJY4OBUhBgk1VcZs8SGMKyPnlnnS0ILWMpOimlkXcGyrbldf28bfL)lLybWSGgwAZstdlHnFqrywuILyYsBwuWIhLdBuai7Dp8hSS33CDpNcHL9BhhabiBRBVtLRQjq7yBVhM7P5C79wSOU6Ddf0xeMY6v5JzOu)kmlXZcHukSEk)xkXIcwAXsac1GqlLj45RcMHs9RWSeplOjjwAAyjaHAqOLYeGfciqu(3Omo6M7XMHs9RWSeplOjjwAZstdlTyjS5dkcZIsSaiwuWYqHnFqr5)sjwamlOHL2S00WsyZhueMfLyjMS0MffS4r5WgfaYE3d)bl79(sRZPqyz)2XbqX02627u5QAc0o227Geomx0FWYEhzaI2SalwcG27E4pyzVBXN5Gtg2ZKEvK9BhhaHS2w3ENkxvtG2X2E3d)bl7D87t)gYEhKWH5I(dw27aamXY(7t)gILhYs0adSSd1(WcAh0xeMyboSyzJkwUIfyPtWI1SkFybTd6lctS4fillmXcYaeTzjAGbmlxNLRyXAwLpSG2b9fHj79WCpnNBVtb9fHjZvz9Q8HLMgwOG(IWKbd1(KlcPplnnSqb9fHjJxjYfH0NLMgwux9UXIpZbNmSNj9QiZkIffSOU6Ddf0xeMY6v5JzfXstdlTyrD17MGNVkygk1VcZcGzXd)blJLX)ndHukSEk)xkXIcwux9Uj45RcMvelTTF74ai0yBD7Dp8hSS3Tm(VzVtLRQjq7yB)2XbqaxBRBVtLRQjq7yBV7H)GL9(SQSh(dwz9HF7D9H)C5PK9E316FBw2V9BV7qY262XrzBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3BXI6Q3n)LswGtLbhYtvVcKgZqP(vywamlOcGMuhPSamwsYOmlnnSOU6DZFPKf4uzWH8u1RaPXmuQFfMfaZIh(dwg87t)gYqiLcRNY)LsSamwsYOmlkyPfluqFryYCvwVkFyPPHfkOVimzWqTp5Iq6ZstdluqFryY4vICri9zPnlTzrblQRE38xkzbovgCipv9kqAmRiwuWYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eO9oiHdZf9hSS3rURdlT)eMflB0Vrdl)gXsmAipn4FyJgwux9olwoTMLUR1Sa7DwSC)2vS8BelfH0NLGJF7De(KlpLS3bhYtZwoTo3DTod7D73ooaY2627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi7DRyHc6lctMRYyO2hwuWslwWrKwNFFqrp2GFF63qSeplOHffS8UMQ3GHlDg2Z)gL7WHWVHkxvtGS00WcoI0687dk6Xg87t)gIL4zbGXsB7DqchMl6pyzVJCxhwA)jmlw2OFJgw2FFWRbfXYHzXcC(nwco(Vcflqe0WY(7t)gILRyXAwLpSG2b9fHj7De(KlpLS3pufCOm(9bVguK9BhNyABD7DQCvnbAhB7Dp8hSS3dWcbeik)BughDZ9y7DqchMl6pyzVdaWelihwiGarSyzJkw8NfnHXS8BEXcAsIL4IbOS4fil6RiwwrSy5(nwqECrI1wb79WCpnNBVBflGZ6anfmhaXSOGLwS0Ife(CUQMmbyHaceLbjCIkWIcwSILaeQbHwktWZxfmd5GjyPPHf1vVBcE(QGzfXsBwuWslwux9UHc6lctz9Q8XmuQFfML4zb4YstdlQRE3qb9fHPmgQ9XmuQFfML4zb4YsBwuWslwSILzvuhoOiJQR9kqzyp7AD(3Ucf2qLRQjqwAAyrD17gvx7vGYWE2168VDfkCU8FnKb)EaiwINLyYstdlQRE3O6AVcug2ZUwN)TRqHZ(e8Im43daXs8SetwAZstdlQqmMffS0puBFEOu)kmlaMfLtIffSyflbiudcTuMGNVkygYbtWsB73ooiRT1T3PYv1eODST39WFWYEFCeubx4CFOkwjS3bjCyUO)GL9oaatSaGmufReSy5(nwqECrI1wb79WCpnNBVRU6DtWZxfmdL6xHzjEwugn2VDCqJT1T3PYv1eODST39WFWYEhVQ(nK9Eirqt53hu0JTJJY27H5EAo3EVfld1hcV5QAILMgwux9UHc6lctzmu7JzOu)kmlaMLyYIcwOG(IWK5QmgQ9HffSmuQFfMfaZIYillky5DnvVbdx6mSN)nk3HdHFdvUQMazPnlky59bf9M)sP8dZGhXs8SOmYYcaMfCeP153hu0JzbySmuQFfMffS0IfkOVimzUk7vcwAAyzOu)kmlaMfubqtQJuwABVds4WCr)bl7DaaMyzFv9BiwUILiVaP0lWcSyXRe)2vOy538Nf9HGWSOmYIPaMfVazrtymlwUFJLu4qS8(GIEmlEbYI)S8BelubYcSZIZYou7dlODqFryIf)zrzKLfmfWSahw0egZYqP(vxHIfhZYdzPGplBoIRqXYdzzO(q4nwaxZvOyXAwLpSG2b9fHj73ooaxBRBVtLRQjq7yBV7H)GL9oEv9Bi7DqchMl6pyzVdaWel7RQFdXYdzzZrqS4SGsdvDnlpKLfMyXArgvmYEpm3tZ527i85CvnzUyamhGf49hSyrblbiudcTuMRWHz9UQMYXWYRFLMbjexGmd5GjyrblumSUOic0CfomR3v1uogwE9R0miH4cK9BhhaMT1T3PYv1eODST3dZ90CU9UvS8UMQ3GFsR9jdox)nu5QAcKffS0If1vVBWVpDxRnd1hcV5QAIffS0IfCeP153hu0Jn43NUR1SaywIjlnnSyflZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGS0MLMgwExt1BWWLod75FJYD4q43qLRQjqwuWI6Q3nuqFrykJHAFmdL6xHzbWSetwuWcf0xeMmxLXqTpSOGf1vVBWVpDxRndL6xHzbWSaWyrbl4isRZVpOOhBWVpDxRzjELybzzPnlkyPflwXYSkQdhuKrNi4JJZDnr)vOYO0xAeMmu5QAcKLMgw(lLybzYcYIgwINf1vVBWVpDxRndL6xHzbySaiwAZIcwEFqrV5Vuk)Wm4rSeplOXE3d)bl7D87t31A73ooaeBRBVtLRQjq7yBV7H)GL9o(9P7AT9oiHdZf9hSS3rgUFJL9N0AFyjgnx)zzHjwGflbqwSSrfld1hcV5QAIf11Zc(pTMfl(9S0HdlwtIGpoMLObgyXlqwaHf6FwwyIfvQdhIfKhJWgw2)tRzzHjwuPoCiwqoSqabIybFvGy538NflNwZs0adS4f83OHL93NUR127H5EAo3E)DnvVb)Kw7tgCU(BOYv1eilkyrD17g87t31AZq9HWBUQMyrblTyXkwMvrD4GIm6ebFCCURj6VcvgL(sJWKHkxvtGS00WYFPelitwqw0Ws8SGSS0MffS8(GIEZFPu(HzWJyjEwIP9BhhGJT1T3PYv1eODST39WFWYEh)(0DT2EhKWH5I(dw27id3VXsmAipv9kqAyzHjw2FF6UwZYdzbiIIyzfXYVrSOU6DwutWIRXqww4RqXY(7t31AwGflOHfmfGfiMf4WIMWywgk1V6ku27H5EAo3EFwf1HdkY8xkzbovgCipv9kqAmu5QAcKffSGJiTo)(GIESb)(0DTML4vILyYIcwAXIvSOU6DZFPKf4uzWH8u1RaPXSIyrblQRE3GFF6UwBgQpeEZv1elnnS0Ife(CUQMmGd5PzlNwN7UwNH9olkyPflQRE3GFF6UwBgk1VcZcGzjMS00WcoI0687dk6Xg87t31AwINfaXIcwExt1BWpP1(KbNR)gQCvnbYIcwux9Ub)(0DT2muQFfMfaZcAyPnlTzPT9BhhLtY2627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi7Dh)JRZrql0Ws8SaqsIfamlTyr5Kyb4zrD17M)sjlWPYGd5PQxbsJb)EaiwAZcaMLwSOU6Dd(9P7ATzOu)kmlaplXKfKWcoI068MJFIfGNfRy5DnvVb)Kw7tgCU(BOYv1eilTzbaZslwcqOgeAPm43NUR1MHs9RWSa8Setwqcl4isRZBo(jwaEwExt1BWpP1(KbNR)gQCvnbYsBwaWS0Ifq4B6Rjrg2ZKEvKzOu)kmlaplOHL2SOGLwSOU6Dd(9P7ATzfXstdlbiudcTug87t31AZqP(vywABVds4WCr)bl7DK76Ws7pHzXYg9B0WIZY(7dEnOiwwyIflNwZsWxyIL93NUR1S8qw6UwZcS3rhlEbYYctSS)(GxdkILhYcqefXsmAipv9kqAyb)Eaiwwr27i8jxEkzVJFF6UwNTaRp3DTod7D73ookRST1T3PYv1eODST39WFWYEh)(GxdkYEhKWH5I(dw27aamXY(7dEnOiwSC)glXOH8u1RaPHLhYcqefXYkILFJyrD17Sy5(n46zrdXxHIL93NUR1SSI(lLyXlqwwyIL93h8AqrSalwqwGXsSHX16SGFpaeMLv9NMfKLL3hu0JT3dZ90CU9ocFoxvtgWH80SLtRZDxRZWENffSGWNZv1Kb)(0DToBbwFU7ADg27SOGfRybHpNRQjZHQGdLXVp41GIyPPHLwSOU6DJQR9kqzyp7AD(3Ucfox(VgYGFpaelXZsmzPPHf1vVBuDTxbkd7zxRZ)2vOWzFcErg87bGyjEwIjlTzrbl4isRZVpOOhBWVpDxRzbWSGSSOGfe(CUQMm43NUR1zlW6ZDxRZWE3(TJJYaY2627u5QAc0o227E4pyzV7GE0FiOm2IpP27HebnLFFqrp2ookBVhM7P5C7DRy5VaqxHIffSyflE4pyzCqp6peugBXN0mON6OiZv5U(qT9S00Wci8noOh9hckJT4tAg0tDuKb)EaiwamlXKffSacFJd6r)HGYyl(KMb9uhfzgk1VcZcGzjM27Geomx0FWYEhaGjwWw8jLfmKLFZFwsaxSGIEwsDKYYk6VuIf1eSSWxHIL7zXXSO9NyXXSebX4tvtSalw0egZYV5flXKf87bGWSahwqgzHFwSSrflXeySGFpaeMfcPr3q2VDCuoM2w3ENkxvtG2X2E3d)bl79uiS63q27HebnLFFqrp2ookBVhM7P5C79H6dH3CvnXIcwEFqrV5Vuk)Wm4rSeplTyPflkJSSamwAXcoI0687dk6Xg87t)gIfGNfaXcWZI6Q3nuqFrykRxLpMvelTzPnlaJLHs9RWS0MfKWslwuMfGXY7AQEZB5QCkewydvUQMazPnlkyPflbiudcTuMGNVkygYbtWIcwSIfWzDGMcMdGywuWslwq4Z5QAYeGfciqugKWjQalnnSeGqni0szcWcbeik)BughDZ9yZqoycwAAyXkwcqeu51BQd12N7oXsBwAAybhrAD(9bf9yd(9PFdXcGzPflTyb4YcaMLwSOU6Ddf0xeMY6v5JzfXcWZcGyPnlTzb4zPflkZcWy5DnvV5TCvofclSHkxvtGS0ML2SOGfRyHc6lctgmu7tUiK(S00WslwOG(IWK5QmgQ9HLMgwAXcf0xeMmxLvH)glnnSqb9fHjZvz9Q8HL2SOGfRy5DnvVbdx6mSN)nk3HdHFdvUQMazPPHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelXRelacnjXsBwuWslwWrKwNFFqrp2GFF63qSaywuojwaEwAXIYSamwExt1BElxLtHWcBOYv1eilTzPnlkyXX)46Ce0cnSeplOjjwaWSOU6Dd(9P7ATzOu)kmlaplaxwAZIcwAXIvSOU6DdqxboeyMsJGwOjLQptfnOUyrMvelnnSqb9fHjZvzmu7dlnnSyflbicQ86naLyoVyPnlkyXkwux9UzCeubx4CFOkwjY4R6lDElb(P5CZkYEhKWH5I(dw27X4uFi8glaOGWQFdXY1zb5XfjwBfy5WSmKdMaDS8B0qS4dXIMWyw(nVybnS8(GIEmlxXI1SkFybTd6lctSy5(nw2Hpac6yrtyml)MxSOCsSa)nASCyILRyXReSG2b9fHjwGdlRiwEilOHL3hu0JzrL6WHyXzXAwLpSG2b9fHjdlXiyH(NLH6dH3ybCnxHIfKXxboeilODAe0cnPu9SSknHXSCfl7qTpSG2b9fHj73ookJS2w3ENkxvtG2X2E3d)bl79oCcug2ZL)RHS3bjCyUO)GL9oaatSaGaJdlWILailwUFdUEwcEu0vOS3dZ90CU9UhLdBuai73ookJgBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3TIfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcwAXslwux9Ub)(0DT2SIyPPHL31u9g8tATpzW56VHkxvtGS00WsaIGkVEtDO2(C3jwAZIcwAXIvSOU6DdgQX)fiZkIffSyflQRE3e88vbZkIffS0IfRy5DnvVPVMezypt6vrgQCvnbYstdlQRE3e88vbd4A8)GflXZsac1GqlLPVMezypt6vrMHs9RWSamwaiS0MffSGWNZv1K53MtRZyIaIMSf)EwuWslwSILaebvE9M6qT95UtS00Wsac1GqlLjaleqGO8VrzC0n3JnRiwuWslwux9Ub)(0DT2muQFfMfaZcGyPPHfRy5DnvVb)Kw7tgCU(BOYv1eilTzPnlky59bf9M)sP8dZGhXs8SOU6DtWZxfmGRX)dwSa8SKKbGXsBwAAyrfIXSOGL(HA7ZdL6xHzbWSOU6DtWZxfmGRX)dwS02EhHp5Ytj79ayoalW7pyLDiz)2XrzGRT1T3PYv1eODST39WFWYEpqAc)NRZU(qvPu927Geomx0FWYEhaGjwqECrI1wbwGflbqwwLMWyw8cKf9vel3ZYkIfl3VXcYHfciqK9EyUNMZT3r4Z5QAYeaZbybE)bRSdj73ookdWSTU9ovUQMaTJT9EyUNMZT3r4Z5QAYeaZbybE)bRSdj7Dp8hSS3Vk4t5)bl73ookdqSTU9ovUQMaTJT9Uh(dw27uAe0cnzvybAVds4WCr)bl7DaaMybTtJGwOHLydlqwGflbqwSC)gl7VpDxRzzfXIxGSGDeelD4WcaDPX(WIxGSG84IeRTc27H5EAo3E)QNMiO2Fcm3puBFEOu)kmlaMfLrdlnnS0If1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaHMKyPPHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelXRelacnjXsBwuWI6Q3n43NUR1MvelkyPflbiudcTuMGNVkygk1VcZs8SGMKyPPHfWzDGMcMdGywAB)2XrzGJT1T3PYv1eODST39WFWYEh)Kw7tUR9HS3djcAk)(GIESDCu2Epm3tZ527d1hcV5QAIffS8xkLFyg8iwINfLrdlkybhrAD(9bf9yd(9PFdXcGzbzzrblEuoSrbGyrblTyrD17MGNVkygk1VcZs8SOCsS00WIvSOU6DtWZxfmRiwABVds4WCr)bl79yCQpeEJLU2hIfyXYkILhYsmz59bf9ywSC)gC9SG84IeRTcSOsxHIfxfUEwEilesJUHyXlqwk4Zcebnbpk6ku2VDCaus2w3ENkxvtG2X2E3d)bl79(AsKH9mPxfzVds4WCr)bl7DaaMybabI2SCDwUcFGelEXcAh0xeMyXlqw0xrSCplRiwSC)glola0Lg7dlrdmWIxGSexqp6peel7w8j1Epm3tZ527uqFryYCv2ReSOGfpkh2OaqSOGf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaHMKyrblTybe(gh0J(dbLXw8jnd6PokY8xaORqXstdlwXsaIGkVEtrHbQHdilnnSGJiTo)(GIEmlXZcGyPnlkyPflQRE3mocQGlCUpufReMHs9RWSaywaoSaGzPflOHfGNLzvuhoOid(Q(sN3sGFAo3qLRQjqwAZIcwux9UzCeubx4CFOkwjmRiwAAyXkwux9UzCeubx4CFOkwjmRiwAZIcwAXIvSeGqni0szcE(QGzfXstdlQRE38BZP1zmrarJb)EaiwamlkJgwuWs)qT95Hs9RWSaywausjXIcw6hQTppuQFfML4zr5KsILMgwSIfmCPvVc08BZP1zmrarJHkxvtGS0MffS0IfmCPvVc08BZP1zmrarJHkxvtGS00Wsac1GqlLj45RcMHs9RWSeplXmjwAB)2XbqkBBD7DQCvnbAhB7Dp8hSS3XVpDxRT3bjCyUO)GL9oaatS4SS)(0DTMfa0f9BSenWalRstyml7VpDxRz5WS46HCWeSSIyboSKaUyXhIfxfUEwEilqe0e8iwIlgGAVhM7P5C7D1vVBGf9B4Cenbk6pyzwrSOGLwSOU6Dd(9P7ATzO(q4nxvtS00WIJ)X15iOfAyjEwaojXsB73ooacq2w3ENkxvtG2X2E3d)bl7D87t31A7DqchMl6pyzVhJwPrSexmaLfvQdhIfKdleqGiwSC)gl7VpDxRzXlqw(nQyz)9bVguK9EyUNMZT3dqeu51BQd12N7oXIcwSIL31u9g8tATpzW56VHkxvtGSOGLwSGWNZv1KjaleqGOmiHtubwAAyjaHAqOLYe88vbZkILMgwux9Uj45RcMvelTzrblbiudcTuMaSqabIY)gLXr3Cp2muQFfMfaZcQaOj1rklaplb60S0Ifh)JRZrql0WcsybnjXsBwuWI6Q3n43NUR1MHs9RWSaywqwwuWIvSaoRd0uWCaeB)2XbqX02627u5QAc0o227H5EAo3EparqLxVPouBFU7elkyPfli85CvnzcWcbeikds4evGLMgwcqOgeAPmbpFvWSIyPPHf1vVBcE(QGzfXsBwuWsac1GqlLjaleqGO8VrzC0n3JndL6xHzbWSaCzrblQRE3GFF6UwBwrSOGfkOVimzUk7vcwuWIvSGWNZv1K5qvWHY43h8AqrSOGfRybCwhOPG5ai2E3d)bl7D87dEnOi73ooaczTTU9ovUQMaTJT9Uh(dw2743h8Aqr27Geomx0FWYEhaGjw2FFWRbfXIL73yXlwaqx0VXs0adSahwUoljGl0dYcebnbpIL4IbOSy5(nwsaxdlfH0NLGJFdlXvJHSaUsJyjUyakl(ZYVrSqfilWol)gXsmwQ(TedlQRENLRZY(7t31AwSaxAWc9plDxRzb27SahwsaxS4dXcSybqS8(GIES9EyUNMZT3vx9Ubw0VHZbn5tgXHpyzwrS00WslwSIf87t)gY4r5WgfaIffSyfli85CvnzoufCOm(9bVguelnnS0If1vVBcE(QGzOu)kmlaMf0WIcwux9Uj45RcMvelnnS0ILwSOU6DtWZxfmdL6xHzbWSGkaAsDKYcWZsGonlTyXX)46Ce0cnSGewIzsS0MffSOU6DtWZxfmRiwAAyrD17MXrqfCHZ9HQyLiJVQV05Te4NMZndL6xHzbWSGkaAsDKYcWZsGonlTyXX)46Ce0cnSGewIzsS0MffSOU6DZ4iOcUW5(qvSsKXx1x68wc8tZ5MvelTzrblbicQ86niO63smS0ML2SOGLwSGJiTo)(GIESb)(0DTMfaZsmzPPHfe(CUQMm43NUR1zlW6ZDxRZWENL2S0MffSyfli85CvnzoufCOm(9bVguelkyPflwXYSkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilnnSGJiTo)(GIESb)(0DTMfaZsmzPT9BhhaHgBRBVtLRQjq7yBV7H)GL9ErwYPqyzVds4WCr)bl7DaaMybafewywUILDO2hwq7G(IWelEbYc2rqSaGS0AwaqbHflD4WcYJlsS2kyVhM7P5C79wSOU6Ddf0xeMYyO2hZqP(vywINfcPuy9u(VuILMgwAXsyZhueMfLybqSOGLHcB(GIY)LsSaywqdlTzPPHLWMpOimlkXsmzPnlkyXJYHnkaK9BhhabCTTU9ovUQMaTJT9EyUNMZT3BXI6Q3nuqFrykJHAFmdL6xHzjEwiKsH1t5)sjwAAyPflHnFqrywuIfaXIcwgkS5dkk)xkXcGzbnS0MLMgwcB(GIWSOelXKL2SOGfpkh2OaqSOGLwSOU6DZ4iOcUW5(qvSsygk1VcZcGzbnSOGf1vVBghbvWfo3hQIvcZkIffSyflZQOoCqrg8v9LoVLa)0CUHkxvtGS00WIvSOU6DZ4iOcUW5(qvSsywrS02E3d)bl79nx3ZPqyz)2XbqamBRBVtLRQjq7yBVhM7P5C79wSOU6Ddf0xeMYyO2hZqP(vywINfcPuy9u(VuIffS0ILaeQbHwktWZxfmdL6xHzjEwqtsS00Wsac1GqlLjaleqGO8VrzC0n3JndL6xHzjEwqtsS0MLMgwAXsyZhueMfLybqSOGLHcB(GIY)LsSaywqdlTzPPHLWMpOimlkXsmzPnlkyXJYHnkaelkyPflQRE3mocQGlCUpufReMHs9RWSaywqdlkyrD17MXrqfCHZ9HQyLWSIyrblwXYSkQdhuKbFvFPZBjWpnNBOYv1eilnnSyflQRE3mocQGlCUpufReMvelTT39WFWYEVV06Ckew2VDCaeaX2627u5QAc0o227Geomx0FWYEhaGjwqgGOnlWIfKhJS39WFWYE3IpZbNmSNj9Qi73ooac4yBD7DQCvnbAhB7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9ooI0687dk6Xg87t)gIL4zbzzbyS01q4WslwsD8ttImcxViwaEwuoPKybjSaOKyPnlaJLUgchwAXI6Q3n43h8AqrzkncAHMuQ(mgQ9XGFpaeliHfKLL227Geomx0FWYEh5UoS0(tywSSr)gnS8qwwyIL93N(nelxXYou7dlw2UWglhMf)zbnS8(GIEmWuMLoCyHqqtcwausitwsD8ttcwGdlill7Vp41GIybTtJGwOjLQNf87bGW27i8jxEkzVJFF63q5RYyO2h73ooXmjBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3vMfKWcoI068MJFIfaZcGybaZslwsYaiwaEwAXcoI0687dk6Xg87t)gIfamlkZsBwaEwAXIYSamwExt1BWWLod75FJYD4q43qLRQjqwaEwu2GgwAZsBwagljzugnSa8SOU6DZ4iOcUW5(qvSsygk1VcBVds4WCr)bl7DK76Ws7pHzXYg9B0WYdzbzy8FJfW1CfkwaqgQIvc7De(KlpLS3Tm(VLVk3hQIvc73ooXuzBRBVtLRQjq7yBV7H)GL9ULX)n7DqchMl6pyzVdaWelidJ)BSCfl7qTpSG2b9fHjwGdlxNLcYY(7t)gIflNwZs)EwU6HSG84IeRTcS4vIu4q27H5EAo3EVfluqFryYOxLp5Iq6ZstdluqFryY4vICri9zrbli85CvnzoCoOjhbXsBwuWslwEFqrV5Vuk)Wm4rSeplillnnSqb9fHjJEv(KVkdiwAAyPFO2(8qP(vywamlkNelTzPPHf1vVBOG(IWugd1(ygk1VcZcGzXd)bld(9PFdziKsH1t5)sjwuWI6Q3nuqFrykJHAFmRiwAAyHc6lctMRYyO2hwuWIvSGWNZv1Kb)(0VHYxLXqTpS00WI6Q3nbpFvWmuQFfMfaZIh(dwg87t)gYqiLcRNY)LsSOGfRybHpNRQjZHZbn5iiwuWI6Q3nbpFvWmuQFfMfaZcHukSEk)xkXIcwux9Uj45RcMvelnnSOU6DZ4iOcUW5(qvSsywrSOGfe(CUQMmwg)3YxL7dvXkblnnSyfli85CvnzoCoOjhbXIcwux9Uj45RcMHs9RWSeplesPW6P8FPK9BhNyciBRBVtLRQjq7yBVds4WCr)bl7DaaMyz)9PFdXY1z5kwSMv5dlODqFrycDSCfl7qTpSG2b9fHjwGflilWy59bf9ywGdlpKLObgyzhQ9Hf0oOVimzV7H)GL9o(9PFdz)2XjMX02627u5QAc0o227Geomx0FWYEhaX16FBw27E4pyzVpRk7H)GvwF43ExF4pxEkzV3DT(3ML9B)27DxR)TzzBD74OST1T3PYv1eODST39WFWYEh)(GxdkYEhKWH5I(dw277Vp41GIyPdhwsHiOuQEwwLMWyww4RqXsSHX1627H5EAo3E3kwMvrD4GImQU2RaLH9SR15F7kuydfdRlkIaTF74aiBRBVtLRQjq7yBV7H)GL9oEv9Bi79qIGMYVpOOhBhhLT3dZ90CU9oi8nPqy1VHmdL6xHzjEwgk1VcZcWZcGaeliHfLbi27Geomx0FWYEh5o(z53iwaHplwUFJLFJyjfIFw(lLy5HS4GGSSQ)0S8BelPoszbCn(FWILdZY29gw2xv)gILHs9RWSKU0)fPpcKLhYsQ)HnwsHWQFdXc4A8)GL9BhNyABD7Dp8hSS3tHWQFdzVtLRQjq7yB)2V9o(TTUDCu22627u5QAc0o227E4pyzVJFFWRbfzVds4WCr)bl7DaaMyz)9bVguelpKfGikILvel)gXsmAipv9kqAyrD17SCDwUNflWLgKfcPr3qSOsD4qS0V6WBxHILFJyPiK(SeC8ZcCy5HSaUsJyrL6WHyb5WcbeiYEpm3tZ527ZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGSOGLwSqb9fHjZvzVsWIcwSILwS0If1vVB(lLSaNkdoKNQEfinMHs9RWSeplE4pyzSm(VziKsH1t5)sjwagljzuMffS0IfkOVimzUkRc)nwAAyHc6lctMRYyO2hwAAyHc6lctg9Q8jxesFwAZstdlQRE38xkzbovgCipv9kqAmdL6xHzjEw8WFWYGFF63qgcPuy9u(VuIfGXssgLzrblTyHc6lctMRY6v5dlnnSqb9fHjdgQ9jxesFwAAyHc6lctgVsKlcPplTzPnlnnSyflQRE38xkzbovgCipv9kqAmRiwAZstdlTyrD17MGNVkywrS00WccFoxvtMaSqabIYGeorfyPnlkyjaHAqOLYeGfciqu(3Omo6M7XMHCWeSOGLaebvE9M6qT95UtS0MffS0IfRyjarqLxVbOeZ5flnnSeGqni0szO0iOfAYQWc0muQFfML4zbGWsBwuWslwux9Uj45RcMvelnnSyflbiudcTuMGNVkygYbtWsB73ooaY2627u5QAc0o227E4pyzV7GE0FiOm2IpP27HebnLFFqrp2ookBVhM7P5C7DRybe(gh0J(dbLXw8jnd6PokY8xaORqXIcwSIfp8hSmoOh9hckJT4tAg0tDuK5QCxFO2EwuWslwSIfq4BCqp6peugBXN08g5AZFbGUcflnnSacFJd6r)HGYyl(KM3ixBgk1VcZs8SGgwAZstdlGW34GE0FiOm2IpPzqp1rrg87bGybWSetwuWci8noOh9hckJT4tAg0tDuKzOu)kmlaMLyYIcwaHVXb9O)qqzSfFsZGEQJIm)fa6ku27Geomx0FWYEhaGjwIlOh9hcILDl(KYILnQy53OHy5WSuqw8WFiiwWw8jfDS4yw0(tS4ywIGy8PQjwGflyl(KYIL73ybqSahw6KfAyb)EaimlWHfyXIZsmbglyl(KYcgYYV5pl)gXsrwybBXNuw8zoeeMfKrw4NfV)0WYV5plyl(KYcH0OBiS9BhNyABD7DQCvnbAhB7Dp8hSS3dWcbeik)BughDZ9y7DqchMl6pyzVdaWeMfKdleqGiwUolipUiXARalhMLvelWHLeWfl(qSas4ev4kuSG84IeRTcSy5(nwqoSqabIyXlqwsaxS4dXIkPHwybztIL4IbO27H5EAo3E3kwaN1bAkyoaIzrblTyPfli85CvnzcWcbeikds4evGffSyflbiudcTuMGNVkygYbtWIcwSILzvuhoOit0CPWb8CD2NGxxihT0yFmu5QAcKLMgwux9Uj45RcMvelTzrblo(hxNJGwOHfaReliBsSOGLwSOU6Ddf0xeMY6v5JzOu)kmlXZIYjXstdlQRE3qb9fHPmgQ9XmuQFfML4zr5KyPnlnnSOcXywuWs)qT95Hs9RWSaywuojwuWIvSeGqni0szcE(QGzihmblTTF74GS2w3ENkxvtG2X2EhgzVJP3E3d)bl7De(CUQMS3r46fzV3If1vVBghbvWfo3hQIvcZqP(vywINf0WstdlwXI6Q3nJJGk4cN7dvXkHzfXsBwuWIvSOU6DZ4iOcUW5(qvSsKXx1x68wc8tZ5MvelkyPflQRE3a0vGdbMP0iOfAsP6ZurdQlwKzOu)kmlaMfubqtQJuwAZIcwAXI6Q3nuqFrykJHAFmdL6xHzjEwqfanPoszPPHf1vVBOG(IWuwVkFmdL6xHzjEwqfanPoszPPHLwSyflQRE3qb9fHPSEv(ywrS00WIvSOU6Ddf0xeMYyO2hZkIL2SOGfRy5DnvVbd14)cKHkxvtGS02EhKWH5I(dw27ihwG3FWILoCyX1AwaHpMLFZFwsDGiml41qS8Bucw8Hk0)SmuFi8gbYILnQyjg3rqfCHzbazOkwjyzZXSOjmMLFZlwqdlykGzzOu)QRqXcCy53iwakXCEXI6Q3z5WS4QW1ZYdzP7AnlWENf4WIxjybTd6lctSCywCv46z5HSqin6gYEhHp5Ytj7Dq4Nhkgw3qPu9y73ooOX2627u5QAc0o227Wi7Dm927E4pyzVJWNZv1K9ocxVi79wSyflQRE3qb9fHPmgQ9XSIyrblwXI6Q3nuqFrykRxLpMvelTzPPHL31u9gmuJ)lqgQCvnbAVds4WCr)bl7DKdlW7pyXYV5plHnkaeMLRZsc4IfFiwGRhFGeluqFryILhYcS0jybe(S8B0qSahwoufCiw(TdZIL73yzhQX)fi7De(KlpLS3bHFgUE8bszkOVimz)2Xb4ABD7DQCvnbAhB7Dp8hSS3tHWQFdzVhM7P5C79H6dH3CvnXIcwAXI6Q3nuqFrykJHAFmdL6xHzjEwgk1VcZstdlQRE3qb9fHPSEv(ygk1VcZs8SmuQFfMLMgwq4Z5QAYac)mC94dKYuqFryIL2SOGLH6dH3CvnXIcwEFqrV5Vuk)Wm4rSeplkdiwuWIhLdBuaiwuWccFoxvtgq4Nhkgw3qPu9y79qIGMYVpOOhBhhLTF74aWSTU9ovUQMaTJT9Uh(dw274v1VHS3dZ90CU9(q9HWBUQMyrblTyrD17gkOVimLXqTpMHs9RWSepldL6xHzPPHf1vVBOG(IWuwVkFmdL6xHzjEwgk1VcZstdli85CvnzaHFgUE8bszkOVimXsBwuWYq9HWBUQMyrblVpOO38xkLFyg8iwINfLbelkyXJYHnkaelkybHpNRQjdi8ZdfdRBOuQES9Eirqt53hu0JTJJY2VDCai2w3ENkxvtG2X2E3d)bl7D8tATp5U2hYEpm3tZ527d1hcV5QAIffS0If1vVBOG(IWugd1(ygk1VcZs8SmuQFfMLMgwux9UHc6lctz9Q8XmuQFfML4zzOu)kmlnnSGWNZv1Kbe(z46XhiLPG(IWelTzrbld1hcV5QAIffS8(GIEZFPu(HzWJyjEwug4YIcw8OCyJcaXIcwq4Z5QAYac)8qXW6gkLQhBVhse0u(9bf9y74OS9BhhGJT1T3PYv1eODST39WFWYEVdNaLH9C5)Ai7DqchMl6pyzVdaWelaiW4WcSyjaYIL73GRNLGhfDfk79WCpnNBV7r5WgfaY(TJJYjzBD7DQCvnbAhB7Dp8hSS3P0iOfAYQWc0EhKWH5I(dw27aamXcY4RahcKL9OBUhZIL73yXReSOHfkwOcUqTXI2X)vOybTd6lctS4fil)KGLhYI(kIL7zzfXIL73ybGU0yFyXlqwqECrI1wb79WCpnNBV3ILwSOU6Ddf0xeMYyO2hZqP(vywINfLtILMgwux9UHc6lctz9Q8XmuQFfML4zr5KyPnlkyjaHAqOLYe88vbZqP(vywINLyMelkyPflQRE3enxkCapxN9j41fYrln2hdcxViwamlacztILMgwSILzvuhoOit0CPWb8CD2NGxxihT0yFmumSUOicKL2S0MLMgwux9UjAUu4aEUo7tWRlKJwASpgeUErSeVsSaiawsS00Wsac1GqlLj45RcMHCWeSOGfh)JRZrql0Ws8SaCsY(TJJYkBBD7DQCvnbAhB7DyK9oME7Dp8hSS3r4Z5QAYEhHRxK9UvSaoRd0uWCaeZIcwq4Z5QAYeaZbybE)blwuWslwAXsac1GqlLHsJsmKRZWbS8kqMHs9RWSaywug4cWybyS0IfLvMfGNLzvuhoOid(Q(sN3sGFAo3qLRQjqwAZIcwOyyDrreOHsJsmKRZWbS8kqS0MLMgwC8pUohbTqdlXRelaNKyrblTyXkwExt1B6Rjrg2ZKEvKHkxvtGS00WI6Q3nbpFvWaUg)pyXs8SeGqni0sz6Rjrg2ZKEvKzOu)kmlaJfaclTzrbli85Cvnz(T506mMiGOjBXVNffS0If1vVBa6kWHaZuAe0cnPu9zQOb1flYSIyPPHfRyjarqLxVbOeZ5flTzrblVpOO38xkLFyg8iwINf1vVBcE(QGbCn(FWIfGNLKmamwAAyrfIXSOGL(HA7ZdL6xHzbWSOU6DtWZxfmGRX)dwS00WsaIGkVEtDO2(C3jwAAyrD17gvnecQx43SIyrblQRE3OQHqq9c)MHs9RWSaywux9Uj45RcgW14)blwaglTyb4WcWZYSkQdhuKjAUu4aEUo7tWRlKJwASpgkgwxuebYsBwAZIcwSIf1vVBcE(QGzfXIcwAXIvSeGiOYR3uhQTp3DILMgwcqOgeAPmbyHaceL)nkJJU5ESzfXstdlQqmMffS0puBFEOu)kmlaMLaeQbHwktawiGar5FJY4OBUhBgk1VcZcWyb4Ystdl9d12Nhk1VcZcYKfLbijXcGzrD17MGNVkyaxJ)hSyPT9oiHdZf9hSS3bayIfKhxKyTvGfl3VXcYHfciqesqgFf4qGSShDZ9yw8cKfqyH(NficASm3tSaqxASpSahwSSrflXwdHG6f(zXcCPbzHqA0nelQuhoelipUiXARalesJUHW27i8jxEkzVhaZbybE)bRm(TF74OmGSTU9ovUQMaTJT9Uh(dw27JJGk4cN7dvXkH9oiHdZf9hSS3bayILFJyjglv)wIHfl3VXIZcYJlsS2kWYV5plhUq)ZsFGPSaqxASp27H5EAo3ExD17MGNVkygk1VcZs8SOmAyPPHf1vVBcE(QGbCn(FWIfaZsmtIffSGWNZv1KjaMdWc8(dwz8B)2Xr5yABD7DQCvnbAhB79WCpnNBVJWNZv1KjaMdWc8(dwz8ZIcwAXIvSOU6DtWZxfmGRX)dwSeplXmjwAAyXkwcqeu51Bqq1VLyyPnlnnSOU6DZ4iOcUW5(qvSsywrSOGf1vVBghbvWfo3hQIvcZqP(vywamlahwaglbybUU3enu4Wu21hQkLQ38xkLr46fXcWyPflwXI6Q3nQAieuVWVzfXIcwSIL31u9g87JgoGgQCvnbYsB7Dp8hSS3dKMW)56SRpuvkvV9BhhLrwBRBVtLRQjq7yBVhM7P5C7De(CUQMmbWCawG3FWkJF7Dp8hSS3Vk4t5)bl73ookJgBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3TILaeQbHwktWZxfmd5GjyPPHfRybHpNRQjtawiGarzqcNOcSOGLaebvE9M6qT95UtS00Wc4SoqtbZbqS9oiHdZf9hSS3JX6Z5QAILfMazbwS4QN((JWS8B(ZIfVEwEilQelyhbbYshoSG84IeRTcSGHS8B(ZYVrjyXhQEwS44NazbzKf(zrL6WHy53Ou7De(KlpLS3Xock3Hto45Rc2VDCug4ABD7DQCvnbAhB7Dp8hSS37Rjrg2ZKEvK9oiHdZf9hSS3baycZcaceTz56SCflEXcAh0xeMyXlqw(5imlpKf9vel3ZYkIfl3VXcaDPX(GowqECrI1wbw8cKL4c6r)HGyz3IpP27H5EAo3ENc6lctMRYELGffS4r5WgfaIffSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSaiKnjwuWslwaHVXb9O)qqzSfFsZGEQJIm)fa6kuS00WIvSeGiOYR3uuyGA4aYsBwuWccFoxvtgSJGYD4KdE(QalkyPflQRE3mocQGlCUpufReMHs9RWSaywaoSaGzPflOHfGNLzvuhoOid(Q(sN3sGFAo3qLRQjqwAZIcwux9UzCeubx4CFOkwjmRiwAAyXkwux9UzCeubx4CFOkwjmRiwAB)2XrzaMT1T3PYv1eODST39WFWYEh)(0DT2EhKWH5I(dw27aamXca6I(nw2FF6UwZs0adywUol7VpDxRz5Wf6Fwwr27H5EAo3ExD17gyr)gohrtGI(dwMvelkyrD17g87t31AZq9HWBUQMSF74OmaX2627u5QAc0o227H5EAo3ExD17g87JgoGMHs9RWSaywqdlkyPflQRE3qb9fHPmgQ9XmuQFfML4zbnS00WI6Q3nuqFrykRxLpMHs9RWSeplOHL2SOGfh)JRZrql0Ws8SaCsYE3d)bl79GxbsNvx9U9U6Q3ZLNs2743hnCaTF74OmWX2627u5QAc0o227E4pyzVJFFWRbfzVds4WCr)bl79y0kncZsCXauwuPoCiwqoSqabIyzHVcfl)gXcYHfciqelbybE)blwEilHnkaelxNfKdleqGiwomlE4xUwNGfxfUEwEilQelbh)27H5EAo3EparqLxVPouBFU7elkybHpNRQjtawiGarzqcNOcSOGLaeQbHwktawiGar5FJY4OBUhBgk1VcZcGzbnSOGfRybCwhOPG5aiMffSqb9fHjZvzVsWIcwC8pUohbTqdlXZcYMK9BhhaLKT1T3PYv1eODST39WFWYEh)(0DT2EhKWH5I(dw27aamXY(7t31AwSC)gl7pP1(WsmAU(ZIxGSuqw2FF0WbeDSyzJkwkil7VpDxRz5WSSIqhljGlw8Hy5kwSMv5dlODqFryILoCybGammfWSahwEilrdmWcaDPX(WILnQyXvHiiwaojXsCXauwGdloyK)hcIfSfFszzZXSaqagMcywgk1V6kuSahwomlxXsxFO2EdlXb(el)M)SSkqAy53iwWEkXsawG3FWcZY9OhZcyeMLIw)4AwEil7VpDxRzbCnxHILyChbvWfMfaKHQyLaDSyzJkwsaxOhKf8FAnlubYYkIfl3VXcWjjG54iw6WHLFJyr74NfuAOQRXg79WCpnNBV)UMQ3GFsR9jdox)nu5QAcKffSyflVRP6n43hnCanu5QAcKffSOU6Dd(9P7ATzO(q4nxvtSOGLwSOU6Ddf0xeMY6v5JzOu)kmlXZcaHffSqb9fHjZvz9Q8HffSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IybWSai0KelnnSOU6Dt0CPWb8CD2NGxxihT0yFmiC9IyjELybqOjjwuWIJ)X15iOfAyjEwaojXstdlGW34GE0FiOm2IpPzqp1rrMHs9RWSeplaewAAyXd)blJd6r)HGYyl(KMb9uhfzUk31hQTNL2SOGLaeQbHwktWZxfmdL6xHzjEwuoj73ooaszBRBVtLRQjq7yBV7H)GL9o(9bVguK9oiHdZf9hSS3bayIL93h8AqrSaGUOFJLObgWS4filGR0iwIlgGYILnQyb5XfjwBfyboS8BelXyP63smSOU6DwomlUkC9S8qw6UwZcS3zboSKaUqpilbpIL4IbO27H5EAo3ExD17gyr)goh0Kpzeh(GLzfXstdlQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfXstdlQRE3e88vbZkIffS0If1vVBghbvWfo3hQIvcZqP(vywamlOcGMuhPSa8SeOtZslwC8pUohbTqdliHLyMelTzbySetwaEwExt1BkYsofcldvUQMazrblwXYSkQdhuKbFvFPZBjWpnNBOYv1eilkyrD17MXrqfCHZ9HQyLWSIyPPHf1vVBcE(QGzOu)kmlaMfubqtQJuwaEwc0PzPflo(hxNJGwOHfKWsmtIL2S00WI6Q3nJJGk4cN7dvXkrgFvFPZBjWpnNBwrS00Wslwux9UzCeubx4CFOkwjmdL6xHzbWS4H)GLb)(0VHmesPW6P8FPelkybhrADEZXpXcGzjjdYYstdlQRE3mocQGlCUpufReMHs9RWSayw8WFWYyz8FZqiLcRNY)LsS00WccFoxvtMlgaZbybE)blwuWsac1GqlL5kCywVRQPCmS86xPzqcXfiZqoycwuWcfdRlkIanxHdZ6DvnLJHLx)kndsiUaXsBwuWI6Q3nJJGk4cN7dvXkHzfXstdlwXI6Q3nJJGk4cN7dvXkHzfXIcwSILaeQbHwkZ4iOcUW5(qvSsygYbtWstdlwXsaIGkVEdcQ(TedlTzPPHfh)JRZrql0Ws8SaCsIffSqb9fHjZvzVsy)2XbqaY2627u5QAc0o227E4pyzVJFFWRbfzVds4WCr)bl7DRpjy5HSK6arS8BelQe(zb2zz)9rdhqwutWc(9aqxHIL7zzfXsmSUaq6eSCflELGf0oOVimXI66zbGU0yFy5W1ZIRcxplpKfvILObgceO9EyUNMZT3Fxt1BWVpA4aAOYv1eilkyXkwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazrblTyrD17g87JgoGMvelnnS44FCDocAHgwINfGtsS0MffSOU6Dd(9rdhqd(9aqSaywIjlkyPflQRE3qb9fHPmgQ9XSIyPPHf1vVBOG(IWuwVkFmRiwAZIcwux9UjAUu4aEUo7tWRlKJwASpgeUErSaywaealjwuWslwcqOgeAPmbpFvWmuQFfML4zr5KyPPHfRybHpNRQjtawiGarzqcNOcSOGLaebvE9M6qT95UtS02(TJdGIPT1T3PYv1eODST3Hr27y6T39WFWYEhHpNRQj7DeUEr27uqFryYCvwVkFyb4zbGWcsyXd)bld(9PFdziKsH1t5)sjwaglwXcf0xeMmxL1RYhwaEwAXcWLfGXY7AQEdgU0zyp)BuUdhc)gQCvnbYcWZsmzPnliHfp8hSmwg)3mesPW6P8FPelaJLKmilAybjSGJiToV54NybySKKbnSa8S8UMQ3u(VgcNvDTxbYqLRQjq7DqchMl6pyzVJ24)s9NWSSbTWs6kSXsCXauw8HybLFfbYsenSGPaSaT3r4tU8uYE3XrauA2PG9BhhaHS2w3ENkxvtG2X2E3d)bl7D87dEnOi7DqchMl6pyzVhJwPrSS)(GxdkILRyXzbGbmmfyzhQ9Hf0oOVimHowaHf6Fw00ZY9SenWala0Lg7dlT(n)z5WSS5fOMazrnbl09B0WYVrSS)(0DTMf9velWHLFJyjUyaA8aNKyrFfXshoSS)(GxdkQn6ybewO)zbIGglZ9elEXca6I(nwIgyGfVazrtpl)gXIRcrqSOVIyzZlqnXY(7JgoG27H5EAo3E3kwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazrblTyrD17MO5sHd456SpbVUqoAPX(yq46fXcGzbqaSKyPPHf1vVBIMlfoGNRZ(e86c5OLg7JbHRxelaMfaHMKyrblVRP6n4N0AFYGZ1FdvUQMazPnlkyPfluqFryYCvgd1(WIcwC8pUohbTqdlaJfe(CUQMmoocGsZofyb4zrD17gkOVimLXqTpMHs9RWSamwaHVPVMezypt6vrM)caHZdL6xXcWZcGmOHL4zbGKelnnSqb9fHjZvz9Q8HffS44FCDocAHgwagli85CvnzCCeaLMDkWcWZI6Q3nuqFrykRxLpMHs9RWSamwaHVPVMezypt6vrM)caHZdL6xXcWZcGmOHL4zb4KelTzrblwXI6Q3nWI(nCoIMaf9hSmRiwuWIvS8UMQ3GFF0Wb0qLRQjqwuWslwcqOgeAPmbpFvWmuQFfML4zbGXstdly4sREfO53MtRZyIaIgdvUQMazrblQRE38BZP1zmrarJb)EaiwamlXmMSaGzPflZQOoCqrg8v9LoVLa)0CUHkxvtGSa8SGgwAZIcw6hQTppuQFfML4zr5KsIffS0puBFEOu)kmlaMfaLusS0MffS0ILaeQbHwkdqxboeyghDZ9yZqP(vywINfaglnnSyflbicQ86naLyoVyPT9BhhaHgBRBVtLRQjq7yBV7H)GL9ErwYPqyzVds4WCr)bl7DaaMybafewywUIfRzv(WcAh0xeMyXlqwWocILymDDhyailTMfauqyXshoSG84IeRTcS4filiJVcCiqwq70iOfAsP6T3dZ90CU9Elwux9UHc6lctz9Q8XmuQFfML4zHqkfwpL)lLyPPHLwSe28bfHzrjwaelkyzOWMpOO8FPelaMf0WsBwAAyjS5dkcZIsSetwAZIcw8OCyJcaXIcwq4Z5QAYGDeuUdNCWZxfSF74aiGRT1T3PYv1eODST3dZ90CU9Elwux9UHc6lctz9Q8XmuQFfML4zHqkfwpL)lLyrblwXsaIGkVEdqjMZlwAAyPflQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfXIcwcqeu51BakXCEXsBwAAyPflHnFqrywuIfaXIcwgkS5dkk)xkXcGzbnS0MLMgwcB(GIWSOelXKLMgwux9Uj45RcMvelTzrblEuoSrbGyrbli85CvnzWock3Hto45RcSOGLwSOU6DZ4iOcUW5(qvSsygk1VcZcGzPflOHfamlaIfGNLzvuhoOid(Q(sN3sGFAo3qLRQjqwAZIcwux9UzCeubx4CFOkwjmRiwAAyXkwux9UzCeubx4CFOkwjmRiwABV7H)GL9(MR75uiSSF74aiaMT1T3PYv1eODST3dZ90CU9Elwux9UHc6lctz9Q8XmuQFfML4zHqkfwpL)lLyrblwXsaIGkVEdqjMZlwAAyPflQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfXIcwcqeu51BakXCEXsBwAAyPflHnFqrywuIfaXIcwgkS5dkk)xkXcGzbnS0MLMgwcB(GIWSOelXKLMgwux9Uj45RcMvelTzrblEuoSrbGyrbli85CvnzWock3Hto45RcSOGLwSOU6DZ4iOcUW5(qvSsygk1VcZcGzbnSOGf1vVBghbvWfo3hQIvcZkIffSyflZQOoCqrg8v9LoVLa)0CUHkxvtGS00WIvSOU6DZ4iOcUW5(qvSsywrS02E3d)bl79(sRZPqyz)2XbqaeBRBVtLRQjq7yBVds4WCr)bl7DaaMybzaI2SalwcG27E4pyzVBXN5Gtg2ZKEvK9BhhabCSTU9ovUQMaTJT9Uh(dw2743N(nK9oiHdZf9hSS3bayIL93N(nelpKLObgyzhQ9Hf0oOVimHowqECrI1wbw2CmlAcJz5VuILFZlwCwqgg)3yHqkfwpXIM6plWHfyPtWI1SkFybTd6lctSCywwr27H5EAo3ENc6lctMRY6v5dlnnSqb9fHjdgQ9jxesFwAAyHc6lctgVsKlcPplnnS0If1vVBS4ZCWjd7zsVkYSIyPPHfCeP15nh)elaMLKmilAyrblwXsaIGkVEdcQ(TedlnnSGJiToV54NybWSKKbzzrblbicQ86niO63smS0MffSOU6Ddf0xeMY6v5JzfXstdlTyrD17MGNVkygk1VcZcGzXd)blJLX)ndHukSEk)xkXIcwux9Uj45RcMvelTTF74eZKSTU9ovUQMaTJT9oiHdZf9hSS3bayIfKHX)nwG)gnwomXILTlSXYHz5kw2HAFybTd6lctOJfKhxKyTvGf4WYdzjAGbwSMv5dlODqFryYE3d)bl7DlJ)B2VDCIPY2w3ENkxvtG2X2EhKWH5I(dw27aiUw)BZYE3d)bl79zvzp8hSY6d)276d)5Ytj79UR1)2SSF73EpAOamv1FBRBhhLTTU9Uh(dw27aDf4qGzC0n3JT3PYv1eODSTF74aiBRBVtLRQjq7yBVdJS3X0BV7H)GL9ocFoxvt27iC9IS3tYEhKWH5I(dw27wFJybHpNRQjwomly6z5HSKelwUFJLcYc(9NfyXYctS8ZvarpgDSOmlw2OILFJyPFd(zbwelhMfyXYctOJfaXY1z53iwWuawGSCyw8cKLyYY1zrf(BS4dzVJWNC5PK9oSYlmL)5kGO3(TJtmTTU9ovUQMaTJT9omYE3bbT39WFWYEhHpNRQj7DeUEr27kBVhM7P5C79FUci6nVYMnhNxykRU6DwuWYpxbe9Mxztac1GqlLbCn(FWIffSyfl)Cfq0BELnh28Wukd75uyH)bUW5aSW)Sc)blS9ocFYLNs27WkVWu(NRaIE73ooiRT1T3PYv1eODST3Hr27oiO9Uh(dw27i85CvnzVJW1lYEhq27H5EAo3E)NRaIEZdiZMJZlmLvx9olky5NRaIEZditac1GqlLbCn(FWIffSyfl)Cfq0BEazoS5HPug2ZPWc)dCHZbyH)zf(dwy7De(KlpLS3HvEHP8pxbe92VDCqJT1T3PYv1eODST3Hr27y6T39WFWYEhHpNRQj7De(KlpLS3HvEHP8pxbe927H5EAo3ENIH1ffrGMRWHz9UQMYXWYRFLMbjexGyPPHfkgwxuebAO0Oed56mCalVcelnnSqXW6IIiqdgU0A6)RqLNLAc7DqchMl6pyzVB9nctS8ZvarpMfFiwk4ZIVEyQ)xW16eSaspfEcKfhZcSyzHjwWV)S8Zvarp2Wcl70ZccFoxvtS8qwqwwCml)gLGfxJHSuebYcoIcNRzzZlq9vOm27iC9IS3rw73ooaxBRBV7H)GL9EkewaDvUdNu7DQCvnbAhB73ooamBRBVtLRQjq7yBV7H)GL9ULX)n7D9vuoaAVRCs27H5EAo3EVfluqFryYOxLp5Iq6ZstdluqFryYCvgd1(WstdluqFryYCvwf(BS00Wcf0xeMmELixesFwABVds4WCr)bl7Da6qbh)Saiwqgg)3yXlqwCw2FFWRbfXcSyz36Sy5(nwIZHA7zbaXjw8cKLydJR1zboSS)(0VHyb(B0y5WK9BhhaIT1T3PYv1eODST3dZ90CU9ElwOG(IWKrVkFYfH0NLMgwOG(IWK5QmgQ9HLMgwOG(IWK5QSk83yPPHfkOVimz8krUiK(S0MffSenecJYglJ)BSOGfRyjAiegazSm(VzV7H)GL9ULX)n73ooahBRBVtLRQjq7yBVhM7P5C7DRyzwf1HdkYO6AVcug2ZUwN)TRqHnu5QAcKLMgwSILaebvE9M6qT95UtS00WIvSGJiTo)(GIESb)(0DTMfLyrzwAAyXkwExt1Bk)xdHZQU2RazOYv1eilnnS0IfkOVimzWqTp5Iq6ZstdluqFryYCvwVkFyPPHfkOVimzUkRc)nwAAyHc6lctgVsKlcPplTT39WFWYEh)(0VHSF74OCs2w3ENkxvtG2X2Epm3tZ527ZQOoCqrgvx7vGYWE2168VDfkSHkxvtGSOGLaebvE9M6qT95UtSOGfCeP153hu0Jn43NUR1SOelkBV7H)GL9o(9bVguK9B)2V9ocAWhSSJdGscqkNeadqX0E3Ip1vOW27idXngpowBCIXaGZclwFJy5sJGZZshoSGEqQ7l9JEwgkgw3qGSGHPel(6HP(tGSe28cfHnCYwZvelilaNfKdle08eil7xkYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)HdlTqsBwAPmsBB4KTMRiwqwaolihwiO5jqwq)SkQdhuKbaIEwEilOFwf1HdkYaanu5QAce9S0szK22WjBnxrSGgaolihwiO5jqwq)SkQdhuKbaIEwEilOFwf1HdkYaanu5QAce9S0szK22WjBnxrSaCb4SGCyHGMNazz)srol4e17iLfKjlpKfRz5SaEio8blwGr04pCyPfsAZslaH02gozR5kIfagaNfKdle08eilOFwf1HdkYaarplpKf0pRI6WbfzaGgQCvnbIEwAPmsBB4KTMRiwayaCwqoSqqZtGSG(FUci6nkBaGONLhYc6)5kGO38kBaGONLwacPTnCYwZvelamaolihwiO5jqwq)pxbe9gazaGONLhYc6)5kGO38aYaarplTaesBB4KTMRiwaiaCwqoSqqZtGSG(zvuhoOidae9S8qwq)SkQdhuKbaAOYv1ei6zPLYiTTHt2AUIyb4aWzb5WcbnpbYc6NvrD4GImaq0ZYdzb9ZQOoCqrgaOHkxvtGONLwkJ02gozR5kIfLtcGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTugPTnCYwZvelkRmaNfKdle08eilOFwf1HdkYaarplpKf0pRI6WbfzaGgQCvnbIEwAPmsBB4KTMRiwuoMaCwqoSqqZtGSG(zvuhoOidae9S8qwq)SkQdhuKbaAOYv1ei6zPLYiTTHt2AUIyrzKfGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTaesBB4KTMRiwugzb4SGCyHGMNazb9)Cfq0Bu2aarplpKf0)ZvarV5v2aarplTaesBB4KTMRiwugzb4SGCyHGMNazb9)Cfq0BaKbaIEwEilO)NRaIEZdidae9S0szK22WjBnxrSOmAa4SGCyHGMNazb9ZQOoCqrgai6z5HSG(zvuhoOida0qLRQjq0ZslaH02gozR5kIfLrdaNfKdle08eilO)NRaIEJYgai6z5HSG(FUci6nVYgai6zPLYiTTHt2AUIyrz0aWzb5WcbnpbYc6)5kGO3aidae9S8qwq)pxbe9Mhqgai6zPfGqABdNmNmYqCJXJJ1gNyma4SWI13iwU0i48S0HdlOpAOamv1F0ZYqXW6gcKfmmLyXxpm1FcKLWMxOiSHt2AUIyjMaCwqoSqqZtGSG(FUci6nkBaGONLhYc6)5kGO38kBaGONLwXePTnCYwZvelilaNfKdle08eilO)NRaIEdGmaq0ZYdzb9)Cfq0BEazaGONLwXePTnCYwZvelahaolihwiO5jqwq)SkQdhuKbaIEwEilOFwf1HdkYaanu5QAce9S0szK22WjBnxrSOCsaCwqoSqqZtGSG(zvuhoOidae9S8qwq)SkQdhuKbaAOYv1ei6zPLYiTTHtMtgziUX4XXAJtmgaCwyX6BelxAeCEw6WHf07qc9SmumSUHazbdtjw81dt9NazjS5fkcB4KTMRiwugGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarpl(ZcAdG2AyPLYiTTHt2AUIyjMaCwqoSqqZtGSG(zvuhoOidae9S8qwq)SkQdhuKbaAOYv1ei6zPLYiTTHt2AUIybGbWzb5WcbnpbYY(LICwWjQ3rklitKjlpKfRz5SKcbx6fMfyen(dhwAHmBZslLrABdNS1CfXcadGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTaesBB4KTMRiwaiaCwqoSqqZtGSSFPiNfCI6DKYcYezYYdzXAwolPqWLEHzbgrJ)WHLwiZ2S0szK22WjBnxrSaqa4SGCyHGMNazb9ZQOoCqrgai6z5HSG(zvuhoOida0qLRQjq0ZslLrABdNS1CfXcWbGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTugPTnCYwZvelkNeaNfKdle08eil7xkYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)HdlTqsBwAbiK22WjBnxrSOCmb4SGCyHGMNazz)srol4e17iLfKjlpKfRz5SaEio8blwGr04pCyPfsAZslLrABdNS1CfXcGscGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTugPTnCYwZvelacqaCwqoSqqZtGSSFPiNfCI6DKYcYKLhYI1SCwapeh(GflWiA8hoS0cjTzPLYiTTHt2AUIybqilaNfKdle08eil7xkYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)HdlTqsBwAbiK22WjBnxrSaiKfGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTugPTnCYwZvelac4cWzb5WcbnpbYc6NvrD4GImaq0ZYdzb9ZQOoCqrgaOHkxvtGONLwkJ02gozR5kIfabWa4SGCyHGMNazb9ZQOoCqrgai6z5HSG(zvuhoOida0qLRQjq0ZslLrABdNS1CfXcGaoaCwqoSqqZtGSSFPiNfCI6DKYcYKLhYI1SCwapeh(GflWiA8hoS0cjTzPfGqABdNS1CfXsmtcGZcYHfcAEcKL9lf5SGtuVJuwqMS8qwSMLZc4H4WhSybgrJ)WHLwiPnlTugPTnCYCYidXngpowBCIXaGZclwFJy5sJGZZshoSG(UR1)2SqpldfdRBiqwWWuIfF9Wu)jqwcBEHIWgozR5kIfabWzb5WcbnpbYY(LICwWjQ3rklitwEilwZYzb8qC4dwSaJOXF4WslK0MLwkJ02gozozKH4gJhhRnoXyaWzHfRVrSCPrW5zPdhwqp(rpldfdRBiqwWWuIfF9Wu)jqwcBEHIWgozR5kIfLb4SGCyHGMNazb9ZQOoCqrgai6z5HSG(zvuhoOida0qLRQjq0ZslLrABdNS1CfXsmb4SGCyHGMNazb9ZQOoCqrgai6z5HSG(zvuhoOida0qLRQjq0ZslLrABdNS1CfXIYkdWzb5WcbnpbYY(LICwWjQ3rklitKjlpKfRz5SKcbx6fMfyen(dhwAHmBZslLrABdNS1CfXIYkdWzb5WcbnpbYc6NvrD4GImaq0ZYdzb9ZQOoCqrgaOHkxvtGONLwkJ02gozR5kIfLbUaCwqoSqqZtGSG(zvuhoOidae9S8qwq)SkQdhuKbaAOYv1ei6zPLYiTTHt2AUIybqkdWzb5WcbnpbYY(LICwWjQ3rklitwEilwZYzb8qC4dwSaJOXF4WslK0MLwacPTnCYwZvelaszaolihwiO5jqwq)SkQdhuKbaIEwEilOFwf1HdkYaanu5QAce9S0szK22WjBnxrSaiabWzb5WcbnpbYc6NvrD4GImaq0ZYdzb9ZQOoCqrgaOHkxvtGONLwkJ02gozR5kIfaftaolihwiO5jqw2VuKZcor9oszbzYYdzXAwolGhIdFWIfyen(dhwAHK2S0kMiTTHt2AUIybqilaNfKdle08eilOFwf1HdkYaarplpKf0pRI6WbfzaGgQCvnbIEwAbiK22WjBnxrSaiGlaNfKdle08eilOFwf1HdkYaarplpKf0pRI6WbfzaGgQCvnbIEwAPmsBB4KTMRiwaeadGZcYHfcAEcKf0pRI6WbfzaGONLhYc6NvrD4GImaqdvUQMarplTugPTnCYCYidXngpowBCIXaGZclwFJy5sJGZZshoSGEvO)ONLHIH1neilyykXIVEyQ)eilHnVqrydNS1CfXIYaeaolihwiO5jqw2VuKZcor9oszbzYYdzXAwolGhIdFWIfyen(dhwAHK2S0kMiTTHt2AUIyrzGdaNfKdle08eil7xkYzbNOEhPSGmz5HSynlNfWdXHpyXcmIg)HdlTqsBwAPmsBB4K5KT20i48eilaxw8WFWIf9HFSHt2Ehhrb74OCsaYEpAG9tt27OfAXsSDTxbILy0Soqoz0cTyj5LoblaczrhlakjaPmNmNmAHwSG8nVqryaoNmAHwSaGzjUGGeil7qTpSeBYtnCYOfAXcaMfKV5fkcKL3hu0NVolbhtywEilHebnLFFqrp2WjJwOflaywIXPuiccKLvvuGWyFsWccFoxvtywADgYGowIgcrg)(GxdkIfaC8Senecd(9bVguuBdNmAHwSaGzjUiGhilrdfC8Ffkwqgg)3y56SCp6XS8BelwgyHIf0oOVimz4Krl0IfamlaOCGiwqoSqabIy53iw2JU5Emlol67FnXskCiw6AcPNQMyP11zjbCXYMdwO)zz7EwUNf8LU0VxeCH1jyXY9BSeBa0X16SamwqoPj8FUML4Qpuvkvp6y5E0dYcgOlQTHtgTqlwaWSaGYbIyjfIFwqF)qT95Hs9RWONfCGkFoiMfpksNGLhYIkeJzPFO2EmlWsNWWjJwOflaywS(q(ZI1HPelWolXw7BSeBTVXsS1(gloMfNfCefoxZYpxbe9gozoz0cTyjUvbF)jqwITR9kqSexaQ1WsWlwujw6WvbYI)SS9FegGJeKO6AVceagFPbdQ73wQMdIKy7AVceaE)srossbnBFQgz09ttkP6AVcK5r6ZjZj7H)Gf2enuaMQ6VsaDf4qGzC0n3J5KrlwS(gXccFoxvtSCywW0ZYdzjjwSC)glfKf87plWILfMy5NRaIEm6yrzwSSrfl)gXs)g8ZcSiwomlWILfMqhlaILRZYVrSGPaSaz5WS4filXKLRZIk83yXhIt2d)blSjAOamv1FGPesq4Z5QAcDLNskbR8ct5FUci6rhcxViLsIt2d)blSjAOamv1FGPesq4Z5QAcDLNskbR8ct5FUci6rhmsjheeDiC9Iusz0DDL(5kGO3OSzZX5fMYQRExXpxbe9gLnbiudcTugW14)blfw9ZvarVrzZHnpmLYWEofw4FGlCoal8pRWFWcZj7H)Gf2enuaMQ6pWucji85CvnHUYtjLGvEHP8pxbe9OdgPKdcIoeUErkbi0DDL(5kGO3aiZMJZlmLvx9UIFUci6naYeGqni0szaxJ)hSuy1pxbe9gazoS5HPug2ZPWc)dCHZbyH)zf(dwyoz0IfRVryILFUci6XS4dXsbFw81dt9)cUwNGfq6PWtGS4ywGfllmXc(9NLFUci6XgwyzNEwq4Z5QAILhYcYYIJz53OeS4AmKLIiqwWru4CnlBEbQVcLHt2d)blSjAOamv1FGPesq4Z5QAcDLNskbR8ct5FUci6rhmsjm9OdHRxKsil6UUsumSUOic0CfomR3v1uogwE9R0miH4cutdfdRlkIanuAuIHCDgoGLxbQPHIH1ffrGgmCP10)xHkpl1eCYE4pyHnrdfGPQ(dmLqskewaDvUdNuoz0Ifa6qbh)Saiwqgg)3yXlqwCw2FFWRbfXcSyz36Sy5(nwIZHA7zbaXjw8cKLydJR1zboSS)(0VHyb(B0y5WeNSh(dwyt0qbyQQ)atjKyz8FdD6ROCaujLtcDxxPwuqFryYOxLp5Iq630qb9fHjZvzmu7ttdf0xeMmxLvH)wtdf0xeMmELixes)2CYE4pyHnrdfGPQ(dmLqILX)n0DDLArb9fHjJEv(KlcPFtdf0xeMmxLXqTpnnuqFryYCvwf(BnnuqFryY4vICri9BRiAiegLnwg)3uyv0qimaYyz8FJt2d)blSjAOamv1FGPesWVp9Bi0DDLSAwf1HdkYO6AVcug2ZUwN)TRqHBASkarqLxVPouBFU7utJv4isRZVpOOhBWVpDxRvs5MgRExt1Bk)xdHZQU2RazOYv1eyttlkOVimzWqTp5Iq630qb9fHjZvz9Q8PPHc6lctMRYQWFRPHc6lctgVsKlcPFBozp8hSWMOHcWuv)bMsib)(GxdkcDxxPzvuhoOiJQR9kqzyp7AD(3UcfwraIGkVEtDO2(C3jf4isRZVpOOhBWVpDxRvszozoz0cTybTrkfwpbYcHGMeS8xkXYVrS4HhoSCywCe(PDvnz4K9WFWcRegQ9jRsEkNmAXYo9ywIleTzbwSetGXIL73GRNfW56plEbYIL73yz)9rdhqw8cKfabmwG)gnwomXj7H)GfgykHee(CUQMqx5PKsho7qcDiC9IuchrAD(9bf9yd(9P7AD8kROLvVRP6n43hnCanu5QAcSP5DnvVb)Kw7tgCU(BOYv1ey7MgCeP153hu0Jn43NUR1Xdioz0ILD6XSe0KJGyXYgvSS)(0VHyj4flB3ZcGaglVpOOhZILTlSXYHzzinHWRNLoCy53iwq7G(IWelpKfvILOH60meilEbYILTlSXs)0AAy5HSeC8Zj7H)GfgykHee(CUQMqx5PKshoh0KJGqhcxViLWrKwNFFqrp2GFF63qXRmNmAXcaatSeBAW0a0vOyXY9BSG84IeRTcSahw8(tdlihwiGarSCflipUiXARaNSh(dwyGPesuPbtdqxHcDxxPwTSkarqLxVPouBFU7utJvbiudcTuMaSqabIY)gLXr3Cp2SIARqD17MGNVkygk1VchVYOrH6Q3nJJGk4cN7dvXkHzOu)kmGrwfwfGiOYR3GGQFlX00eGiOYR3GGQFlXOqD17MGNVkywrkux9UzCeubx4CFOkwjmRifTux9UzCeubx4CFOkwjmdL6xHbSYkdGrdWpRI6WbfzWx1x68wc8tZ5nnQRE3e88vbZqP(vyaRSYnnkJmXrKwN3C8tawzdAqt72kqfandL6xHJpjoz0Ifak8zXY9BS4SG84IeRTcS8B(ZYHl0)S4SaqxASpSenWalWHflBuXYVrS0puBplhMfxfUEwEilubYj7H)GfgykHKi4FWcDxxj1vVBcE(QGzOu)kC8kJgfTSAwf1HdkYGVQV05Te4NMZBAux9UzCeubx4CFOkwjmdL6xHbSYamamGaE1vVBu1qiOEHFZksH6Q3nJJGk4cN7dvXkHzf1UPrfIXk6hQTppuQFfgWacnCYOfli31HL2FcZILn63OHLf(kuSGCyHaceXsbTWILtRzX1AOfwsaxS8qwW)P1SeC8ZYVrSG9uIfpfUQNfyNfKdleqGiGH84IeRTcSeC8J5K9WFWcdmLqccFoxvtOR8usPaSqabIYGeorfqhcxViLc0PB1QFO2(8qP(vyaSYObahGqni0szcE(QGzOu)kCBKPYaKKARuGoDRw9d12Nhk1VcdGvgna4aeQbHwktawiGar5FJY4OBUhBaxJ)hSaWbiudcTuMaSqabIY)gLXr3Cp2muQFfUnYuzassTvy14hyMqq1BCqqSHq6HFCttac1GqlLj45RcMHs9RWXF1tteu7pbM7hQTppuQFfUPjaHAqOLYeGfciqu(3Omo6M7XMHs9RWXF1tteu7pbM7hQTppuQFfgaRCsnnwfGiOYR3uhQTp3DItgTybaGjqwEilGK2tWYVrSSWokIfyNfKhxKyTvGflBuXYcFfkwaHlvnXcSyzHjw8cKLOHqq1ZYc7OiwSSrflEXIdcYcHGQNLdZIRcxplpKfWJ4K9WFWcdmLqccFoxvtOR8usPayoalW7pyHoeUErk1QFO2(8qP(v44vgnnnJFGzcbvVXbbXMRIhnj1wrRwTOyyDrreOHsJsmKRZWbS8kqkAfGqni0szO0Oed56mCalVcKzOu)kmGvg4MuttaIGkVEdcQ(TeJIaeQbHwkdLgLyixNHdy5vGmdL6xHbSYaxagWAPSYa)SkQdhuKbFvFPZBjWpnN3UTcRcqOgeAPmuAuIHCDgoGLxbYmKdMODtdfdRlkIany4sRP)VcvEwQju0YQaebvE9M6qT95UtnnbiudcTugmCP10)xHkpl1e5yISObGKKYMHs9RWawzLr22nnTcqOgeAPmQ0GPbORqzgYbt00y14bY8duRBROvlkgwxuebAUchM17QAkhdlV(vAgKqCbsrac1GqlL5kCywVRQPCmS86xPzqcXfiZqoyI2nnTOyyDrreObV5GqleygoQzyp)WjLQxrac1GqlL5HtkvpbMVcFO2(CmrdAIjGu2muQFfUDttRwi85CvnzGvEHP8pxbe9kPCtdcFoxvtgyLxyk)ZvarVsXSTIw)Cfq0Bu2mKdMihGqni0s108ZvarVrztac1GqlLzOu)kC8x90eb1(tG5(HA7ZdL6xHbWkNu7Mge(CUQMmWkVWu(NRaIELaKIw)Cfq0BaKzihmroaHAqOLQP5NRaIEdGmbiudcTuMHs9RWXF1tteu7pbM7hQTppuQFfgaRCsTBAq4Z5QAYaR8ct5FUci6vkP2TB30eGiOYR3auI58QDtJkeJv0puBFEOu)kmGvx9Uj45RcgW14)bloz0ILyS(CUQMyzHjqwEilGK2tWIxjy5NRaIEmlEbYsaeZILnQyXIF)vOyPdhw8If0EfTbNZzjAGbozp8hSWatjKGWNZv1e6kpLu63MtRZyIaIMSf)E0HW1lsjRWWLw9kqZVnNwNXebengQCvnb200puBFEOu)kC8akPKAAuHySI(HA7ZdL6xHbmGqdWAHSjbGvx9U53MtRZyIaIgd(9aqapGA30OU6DZVnNwNXebeng87bGIpMaeaCRzvuhoOid(Q(sN3sGFAoh4rtBoz0IfaaMybTtJsmKRzba9awEfiwausykGzrL6WHyXzb5XfjwBfyzHjdNSh(dwyGPeswykFpLIUYtjLO0Oed56mCalVce6UUsbiudcTuMGNVkygk1VcdyaLKIaeQbHwktawiGar5FJY4OBUhBgk1VcdyaLKIwi85Cvnz(T506mMiGOjBXVVPrD17MFBoToJjciAm43dafFmtcyTMvrD4GIm4R6lDElb(P5CGh42UTcubqZqP(v44tQPrfIXk6hQTppuQFfgWXeGXjJwSaaWel7WLwt)vOyjgFPMGfGlMcywuPoCiwCwqECrI1wbwwyYWj7H)GfgykHKfMY3tPOR8usjmCP10)xHkpl1eO76k1kaHAqOLYe88vbZqP(vyadCvyvaIGkVEdcQ(TeJcRcqeu51BQd12N7o10eGiOYR3uhQTp3Dsrac1GqlLjaleqGO8VrzC0n3JndL6xHbmWvrle(CUQMmbyHaceLbjCIk00eGqni0szcE(QGzOu)kmGbUTBAcqeu51Bqq1VLyu0YQzvuhoOid(Q(sN3sGFAoxrac1GqlLj45RcMHs9RWag420OU6DZ4iOcUW5(qvSsygk1VcdyLrwG1cnapfdRlkIanxH)zfE4GZGhIROSkP1TvOU6DZ4iOcUW5(qvSsywrTBAuHySI(HA7ZdL6xHbmGqttdfdRlkIanuAuIHCDgoGLxbsrac1GqlLHsJsmKRZWbS8kqMHs9RWXhZKARava0muQFfo(K4KrlwIR2INaZYctSyTiJkgXIL73yb5XfjwBf4K9WFWcdmLqccFoxvtOR8usPlgaZbybE)bl0HW1lsj1vVBcE(QGzOu)kC8kJgfTSAwf1HdkYGVQV05Te4NMZBAux9UzCeubx4CFOkwjmdL6xHbSskdiG1kMaV6Q3nQAieuVWVzf1gyTAbqaWOb4vx9UrvdHG6f(nRO2apfdRlkIanxH)zfE4GZGhIROSkP1TvOU6DZ4iOcUW5(qvSsywrTBAuHySI(HA7ZdL6xHbmGqttdfdRlkIanuAuIHCDgoGLxbsrac1GqlLHsJsmKRZWbS8kqMHs9RWCYE4pyHbMsizHP89uk6kpLu6kCywVRQPCmS86xPzqcXfi0DDLq4Z5QAYCXayoalW7pyPava0muQFfo(K4KrlwaayIL5qT9SOsD4qSeaXCYE4pyHbMsizHP89uk6kpLucV5GqleygoQzyp)WjLQhDxxPwbiudcTuMGNVkygYbtOWQaebvE9M6qT95Utkq4Z5QAY8BZP1zmrart2IFFttaIGkVEtDO2(C3jfbiudcTuMaSqabIY)gLXr3Cp2mKdMqrle(CUQMmbyHaceLbjCIk00eGqni0szcE(QGzihmr72kaHVbVQ(nK5VaqxHsrlq4BWpP1(K7AFiZFbGUcvtJvVRP6n4N0AFYDTpKHkxvtGnn4isRZVpOOhBWVp9BO4JzBfTaHVjfcR(nK5VaqxHQTIwi85CvnzoC2HutZSkQdhuKr11EfOmSNDTo)BxHc3044FCDocAHM4vc4KutJ6Q3nQAieuVWVzf1wrRaeQbHwkJknyAa6kuMHCWennwnEGm)a162nnQqmwr)qT95Hs9RWagztItgTyX6BhMLdZIZY4)gnSqAxfo(tSyXtWYdzj1bIyX1AwGfllmXc(9NLFUci6XS8qwujw0xrGSSIyXY9BSG84IeRTcS4filihwiGarS4fillmXYVrSaOcKfSg(SalwcGSCDwuH)gl)Cfq0JzXhIfyXYctSGF)z5NRaIEmNSh(dwyGPeswykFpLIrhwdFSs)Cfq0Rm6UUsTq4Z5QAYaR8ct5FUci6TsjLvy1pxbe9gazgYbtKdqOgeAPAAAHWNZv1Kbw5fMY)Cfq0RKYnni85CvnzGvEHP8pxbe9kfZ2kAPU6DtWZxfmRifTSkarqLxVbbv)wIPPrD17MXrqfCHZ9HQyLWmuQFfgyTqdWpRI6WbfzWx1x68wc8tZ5TbSs)Cfq0Bu2OU69m4A8)GLc1vVBghbvWfo3hQIvcZkQPrD17MXrqfCHZ9HQyLiJVQV05Te4NMZnRO2nnbiudcTuMGNVkygk1Vcdmaf)pxbe9gLnbiudcTugW14)blfwPU6DtWZxfmRifTSkarqLxVPouBFU7utJvi85CvnzcWcbeikds4evOTcRcqeu51BakXCE10eGiOYR3uhQTp3DsbcFoxvtMaSqabIYGeorfueGqni0szcWcbeik)BughDZ9yZksHvbiudcTuMGNVkywrkA1sD17gkOVimL1RYhZqP(v44voPMg1vVBOG(IWugd1(ygk1VchVYj1wHvZQOoCqrgvx7vGYWE2168VDfkCttl1vVBuDTxbkd7zxRZ)2vOW5Y)1qg87bGucnnnQRE3O6AVcug2ZUwN)TRqHZ(e8Im43daPeaPD7Mg1vVBa6kWHaZuAe0cnPu9zQOb1flYSIA300puBFEOu)kmGbusnni85CvnzGvEHP8pxbe9kLuBfOcGMHs9RWXNeNSh(dwyGPeswykFpLIrhwdFSs)Cfq0di0DDLAHWNZv1Kbw5fMY)Cfq0BLsasHv)Cfq0Bu2mKdMihGqni0s10GWNZv1Kbw5fMY)Cfq0ReGu0sD17MGNVkywrkAzvaIGkVEdcQ(TettJ6Q3nJJGk4cN7dvXkHzOu)kmWAHgGFwf1HdkYGVQV05Te4NMZBdyL(5kGO3aiJ6Q3ZGRX)dwkux9UzCeubx4CFOkwjmROMg1vVBghbvWfo3hQIvIm(Q(sN3sGFAo3SIA30eGqni0szcE(QGzOu)kmWau8)Cfq0BaKjaHAqOLYaUg)pyPWk1vVBcE(QGzfPOLvbicQ86n1HA7ZDNAAScHpNRQjtawiGarzqcNOcTvyvaIGkVEdqjMZlfTSsD17MGNVkywrnnwfGiOYR3GGQFlX0UPjarqLxVPouBFU7Kce(CUQMmbyHaceLbjCIkOiaHAqOLYeGfciqu(3Omo6M7XMvKcRcqOgeAPmbpFvWSIu0QL6Q3nuqFrykRxLpMHs9RWXRCsnnQRE3qb9fHPmgQ9XmuQFfoELtQTcRMvrD4GImQU2RaLH9SR15F7ku4MMwQRE3O6AVcug2ZUwN)TRqHZL)RHm43daPeAAAux9Ur11EfOmSNDTo)BxHcN9j4fzWVhasjas72TBAux9UbORahcmtPrql0Ks1NPIguxSiZkQPrfIXk6hQTppuQFfgWakPMge(CUQMmWkVWu(NRaIELsQTcubqZqP(v44tItgTybaGjmlUwZc83OHfyXYctSCpLIzbwSea5K9WFWcdmLqYct57PumNmAXsmIchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1H5K9WFWcdmLqYSQSh(dwz9HF0vEkPKdj0H)5cVskJURRecFoxvtMdNDiXj7H)GfgykHKzvzp8hSY6d)OR8usjvO)Od)ZfELugDxxPzvuhoOiJQR9kqzyp7AD(3Ucf2qXW6IIiqozp8hSWatjKmRk7H)GvwF4hDLNskHFozoz0IfK76Ws7pHzXYg9B0WYVrSeJgYtd(h2OHf1vVZILtRzP7AnlWENfl3VDfl)gXsri9zj44Nt2d)blSXHKsi85CvnHUYtjLahYtZwoTo3DTod7D0HW1lsPwQRE38xkzbovgCipv9kqAmdL6xHbmQaOj1rkWsYOCtJ6Q3n)LswGtLbhYtvVcKgZqP(vya7H)GLb)(0VHmesPW6P8FPeWsYOSIwuqFryYCvwVkFAAOG(IWKbd1(KlcPFtdf0xeMmELixes)2TvOU6DZFPKf4uzWH8u1RaPXSIumRI6Wbfz(lLSaNkdoKNQEfinCYOfli31HL2FcZILn63OHL93h8AqrSCywSaNFJLGJ)RqXcebnSS)(0VHy5kwSMv5dlODqFryIt2d)blSXHeWucji85CvnHUYtjLoufCOm(9bVgue6q46fPKvuqFryYCvgd1(OOfoI0687dk6Xg87t)gkE0O4DnvVbdx6mSN)nk3HdHFdvUQMaBAWrKwNFFqrp2GFF63qXdWAZjJwSaaWelihwiGarSyzJkw8NfnHXS8BEXcAsIL4IbOS4fil6RiwwrSy5(nwqECrI1wbozp8hSWghsatjKeGfciqu(3Omo6M7XO76kzf4SoqtbZbqSIwTq4Z5QAYeGfciqugKWjQGcRcqOgeAPmbpFvWmKdMOPrD17MGNVkywrTv0sD17gkOVimL1RYhZqP(v44bUnnQRE3qb9fHPmgQ9XmuQFfoEGBBfTSAwf1HdkYO6AVcug2ZUwN)TRqHBAux9Ur11EfOmSNDTo)BxHcNl)xdzWVhak(y20OU6DJQR9kqzyp7AD(3Ucfo7tWlYGFpau8XSDtJkeJv0puBFEOu)kmGvojfwfGqni0szcE(QGzihmrBoz0IfaaMybazOkwjyXY9BSG84IeRTcCYE4pyHnoKaMsizCeubx4CFOkwjq31vsD17MGNVkygk1VchVYOHtgTybaGjw2xv)gILRyjYlqk9cSalw8kXVDfkw(n)zrFiimlkJSykGzXlqw0egZIL73yjfoelVpOOhZIxGS4pl)gXcvGSa7S4SSd1(WcAh0xeMyXFwugzzbtbmlWHfnHXSmuQF1vOyXXS8qwk4ZYMJ4kuS8qwgQpeEJfW1CfkwSMv5dlODqFryIt2d)blSXHeWucj4v1VHqxirqt53hu0Jvsz0DDLAnuFi8MRQPMg1vVBOG(IWugd1(ygk1Vcd4yQGc6lctMRYyO2hfdL6xHbSYiRI31u9gmCPZWE(3OChoe(nu5QAcSTI3hu0B(lLYpmdEu8kJSayCeP153hu0Jb2qP(vyfTOG(IWK5QSxjAAgk1VcdyubqtQJ02CYOflaamXY(Q63qS8qw2CeelolO0qvxZYdzzHjwSwKrfJ4K9WFWcBCibmLqcEv9Bi0DDLq4Z5QAYCXayoalW7pyPiaHAqOLYCfomR3v1uogwE9R0miH4cKzihmHckgwxuebAUchM17QAkhdlV(vAgKqCbIt2d)blSXHeWucj43NUR1O76kz17AQEd(jT2Nm4C93qLRQjqfTux9Ub)(0DT2muFi8MRQjfTWrKwNFFqrp2GFF6Uwd4y20y1SkQdhuK5VuYcCQm4qEQ6vG00UP5DnvVbdx6mSN)nk3HdHFdvUQMavOU6Ddf0xeMYyO2hZqP(vyahtfuqFryYCvgd1(OqD17g87t31AZqP(vyadWuGJiTo)(GIESb)(0DToELq22kAz1SkQdhuKrNi4JJZDnr)vOYO0xAeMAA(lLqMitKfnXRU6Dd(9P7ATzOu)kmWauBfVpOO38xkLFyg8O4rdNmAXcYW9BSS)Kw7dlXO56pllmXcSyjaYILnQyzO(q4nxvtSOUEwW)P1SyXVNLoCyXAse8XXSenWalEbYciSq)ZYctSOsD4qSG8ye2WY(FAnllmXIk1HdXcYHfciqel4Rcel)M)Sy50AwIgyGfVG)gnSS)(0DTMt2d)blSXHeWucj43NUR1O76k9UMQ3GFsR9jdox)nu5QAcuH6Q3n43NUR1MH6dH3CvnPOLvZQOoCqrgDIGpoo31e9xHkJsFPryQP5VuczImrw0epY2wX7dk6n)Ls5hMbpk(yYjJwSGmC)glXOH8u1RaPHLfMyz)9P7AnlpKfGikILvel)gXI6Q3zrnblUgdzzHVcfl7VpDxRzbwSGgwWuawGywGdlAcJzzOu)QRqXj7H)Gf24qcykHe87t31A0DDLMvrD4GIm)LswGtLbhYtvVcKgf4isRZVpOOhBWVpDxRJxPyQOLvQRE38xkzbovgCipv9kqAmRifQRE3GFF6UwBgQpeEZv1uttle(CUQMmGd5PzlNwN7UwNH9UIwQRE3GFF6UwBgk1Vcd4y20GJiTo)(GIESb)(0DToEaP4DnvVb)Kw7tgCU(BOYv1eOc1vVBWVpDxRndL6xHbmAA3UnNmAXcYDDyP9NWSyzJ(nAyXzz)9bVguellmXILtRzj4lmXY(7t31AwEilDxRzb27OJfVazzHjw2FFWRbfXYdzbiIIyjgnKNQEfinSGFpaelRiozp8hSWghsatjKGWNZv1e6kpLuc)(0DToBbwFU7ADg27OdHRxKso(hxNJGwOjEassa4wkNeWRU6DZFPKf4uzWH8u1RaPXGFpauBaCl1vVBWVpDxRndL6xHb(yImXrKwN3C8taVvVRP6n4N0AFYGZ1FdvUQMaBdGBfGqni0szWVpDxRndL6xHb(yImXrKwN3C8ta)7AQEd(jT2Nm4C93qLRQjW2a4wGW30xtImSNj9QiZqP(vyGhnTv0sD17g87t31AZkQPjaHAqOLYGFF6UwBgk1Vc3MtgTybaGjw2FFWRbfXIL73yjgnKNQEfinS8qwaIOiwwrS8BelQRENfl3VbxplAi(kuSS)(0DTMLv0FPelEbYYctSS)(GxdkIfyXcYcmwInmUwNf87bGWSSQ)0SGSS8(GIEmNSh(dwyJdjGPesWVp41GIq31vcHpNRQjd4qEA2YP15UR1zyVRaHpNRQjd(9P7AD2cS(C316mS3vyfcFoxvtMdvbhkJFFWRbf100sD17gvx7vGYWE2168VDfkCU8FnKb)EaO4JztJ6Q3nQU2RaLH9SR15F7ku4SpbVid(9aqXhZ2kWrKwNFFqrp2GFF6UwdyKvbcFoxvtg87t316Sfy95UR1zyVZjJwSaaWelyl(KYcgYYV5pljGlwqrplPoszzf9xkXIAcww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz538ILyYc(9aqywGdliJSWplw2OILycmwWVhacZcH0OBiozp8hSWghsatjK4GE0FiOm2IpPOlKiOP87dk6XkPm6UUsw9xaORqPWkp8hSmoOh9hckJT4tAg0tDuK5QCxFO2(Mgq4BCqp6peugBXN0mON6Oid(9aqaoMkaHVXb9O)qqzSfFsZGEQJImdL6xHbCm5KrlwIXP(q4nwaqbHv)gILRZcYJlsS2kWYHzzihmb6y53OHyXhIfnHXS8BEXcAy59bf9ywUIfRzv(WcAh0xeMyXY9BSSdFae0XIMWyw(nVyr5Kyb(B0y5WelxXIxjybTd6lctSahwwrS8qwqdlVpOOhZIk1HdXIZI1SkFybTd6lctgwIrWc9pld1hcVXc4AUcfliJVcCiqwq70iOfAsP6zzvAcJz5kw2HAFybTd6lctCYE4pyHnoKaMsijfcR(ne6cjcAk)(GIESskJURR0q9HWBUQMu8(GIEZFPu(HzWJIVvlLrwG1chrAD(9bf9yd(9PFdb8ac4vx9UHc6lctz9Q8XSIA3gydL6xHBJmBPmWExt1BElxLtHWcBOYv1eyBfTcqOgeAPmbpFvWmKdMqHvGZ6anfmhaXkAHWNZv1KjaleqGOmiHtuHMMaeQbHwktawiGar5FJY4OBUhBgYbt00yvaIGkVEtDO2(C3P2nn4isRZVpOOhBWVp9Bia3QfWfa3sD17gkOVimL1RYhZkc4bu72aFlLb27AQEZB5QCkewydvUQMaB3wHvuqFryYGHAFYfH0VPPff0xeMmxLXqTpnnTOG(IWK5QSk83AAOG(IWK5QSEv(0wHvVRP6ny4sNH98Vr5oCi8BOYv1eytJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaeAsQTIw4isRZVpOOhBWVp9BiaRCsaFlLb27AQEZB5QCkewydvUQMaB3wHJ)X15iOfAIhnjbGvx9Ub)(0DT2muQFfg4bUTv0Yk1vVBa6kWHaZuAe0cnPu9zQOb1flYSIAAOG(IWK5QmgQ9PPXQaebvE9gGsmNxTvyL6Q3nJJGk4cN7dvXkrgFvFPZBjWpnNBwrCYOflaamXcacmoSalwcGSy5(n46zj4rrxHIt2d)blSXHeWucjD4eOmSNl)xdHURRKhLdBuaiozp8hSWghsatjKGWNZv1e6kpLukaMdWc8(dwzhsOdHRxKswboRd0uWCaeRaHpNRQjtamhGf49hSu0QL6Q3n43NUR1MvutZ7AQEd(jT2Nm4C93qLRQjWMMaebvE9M6qT95UtTv0Yk1vVBWqn(VazwrkSsD17MGNVkywrkAz17AQEtFnjYWEM0RImu5QAcSPrD17MGNVkyaxJ)hSIpaHAqOLY0xtImSNj9QiZqP(vyGbqARaHpNRQjZVnNwNXebenzl(9kAzvaIGkVEtDO2(C3PMMaeQbHwktawiGar5FJY4OBUhBwrkAPU6Dd(9P7ATzOu)kmGbutJvVRP6n4N0AFYGZ1FdvUQMaB3wX7dk6n)Ls5hMbpkE1vVBcE(QGbCn(FWc4tYaWA30OcXyf9d12Nhk1Vcdy1vVBcE(QGbCn(FWQnNmAXcaatSG84IeRTcSalwcGSSknHXS4fil6RiwUNLvelwUFJfKdleqGiozp8hSWghsatjKeinH)Z1zxFOQuQE0DDLq4Z5QAYeaZbybE)bRSdjozp8hSWghsatjKCvWNY)dwO76kHWNZv1KjaMdWc8(dwzhsCYOflaamXcANgbTqdlXgwGSalwcGSy5(nw2FF6UwZYkIfVazb7iiw6WHfa6sJ9HfVazb5XfjwBf4K9WFWcBCibmLqcLgbTqtwfwGO76kD1tteu7pbM7hQTppuQFfgWkJMMMwQRE3enxkCapxN9j41fYrln2hdcxViadi0KutJ6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lkELaeAsQTc1vVBWVpDxRnRifTcqOgeAPmbpFvWmuQFfoE0Kutd4SoqtbZbqCBoz0ILyCQpeEJLU2hIfyXYkILhYsmz59bf9ywSC)gC9SG84IeRTcSOsxHIfxfUEwEilesJUHyXlqwk4Zcebnbpk6kuCYE4pyHnoKaMsib)Kw7tUR9Hqxirqt53hu0Jvsz0DDLgQpeEZv1KI)sP8dZGhfVYOrboI0687dk6Xg87t)gcWiRcpkh2OaqkAPU6DtWZxfmdL6xHJx5KAASsD17MGNVkywrT5KrlwaayIfaeiAZY1z5k8bsS4flODqFryIfVazrFfXY9SSIyXY9BS4SaqxASpSenWalEbYsCb9O)qqSSBXNuozp8hSWghsatjK0xtImSNj9Qi0DDLOG(IWK5QSxju4r5WgfasH6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lcWacnjPOfi8noOh9hckJT4tAg0tDuK5VaqxHQPXQaebvE9MIcdudhWMgCeP153hu0JJhqTv0sD17MXrqfCHZ9HQyLWmuQFfgWahaCl0a8ZQOoCqrg8v9LoVLa)0CEBfQRE3mocQGlCUpufReMvutJvQRE3mocQGlCUpufReMvuBfTSkaHAqOLYe88vbZkQPrD17MFBoToJjciAm43dabyLrJI(HA7ZdL6xHbmGskjf9d12Nhk1VchVYjLutJvy4sREfO53MtRZyIaIgdvUQMaBROfgU0QxbA(T506mMiGOXqLRQjWMMaeQbHwktWZxfmdL6xHJpMj1MtgTybaGjwCw2FF6UwZca6I(nwIgyGLvPjmML93NUR1SCywC9qoycwwrSahwsaxS4dXIRcxplpKficAcEelXfdq5K9WFWcBCibmLqc(9P7An6UUsQRE3al63W5iAcu0FWYSIu0sD17g87t31AZq9HWBUQMAAC8pUohbTqt8aNKAZjJwSeJwPrSexmaLfvQdhIfKdleqGiwSC)gl7VpDxRzXlqw(nQyz)9bVgueNSh(dwyJdjGPesWVpDxRr31vkarqLxVPouBFU7KcRExt1BWpP1(KbNR)gQCvnbQOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWSIAAux9Uj45RcMvuBfbiudcTuMaSqabIY)gLXr3Cp2muQFfgWOcGMuhPaFGoDlh)JRZrql0GmrtsTvOU6Dd(9P7ATzOu)kmGrwfwboRd0uWCaeZj7H)Gf24qcykHe87dEnOi0DDLcqeu51BQd12N7oPOfcFoxvtMaSqabIYGeorfAAcqOgeAPmbpFvWSIAAux9Uj45RcMvuBfbiudcTuMaSqabIY)gLXr3Cp2muQFfgWaxfQRE3GFF6UwBwrkOG(IWK5QSxjuyfcFoxvtMdvbhkJFFWRbfPWkWzDGMcMdGyoz0IfaaMyz)9bVguelwUFJfVybaDr)glrdmWcCy56SKaUqpilqe0e8iwIlgGYIL73yjbCnSuesFwco(nSexngYc4knIL4IbOS4pl)gXcvGSa7S8BelXyP63smSOU6DwUol7VpDxRzXcCPbl0)S0DTMfyVZcCyjbCXIpelWIfaXY7dk6XCYE4pyHnoKaMsib)(GxdkcDxxj1vVBGf9B4Cqt(KrC4dwMvuttlRWVp9BiJhLdBuaifwHWNZv1K5qvWHY43h8AqrnnTux9Uj45RcMHs9RWagnkux9Uj45RcMvuttRwQRE3e88vbZqP(vyaJkaAsDKc8b60TC8pUohbTqdYmMj1wH6Q3nbpFvWSIAAux9UzCeubx4CFOkwjY4R6lDElb(P5CZqP(vyaJkaAsDKc8b60TC8pUohbTqdYmMj1wH6Q3nJJGk4cN7dvXkrgFvFPZBjWpnNBwrTveGiOYR3GGQFlX0UTIw4isRZVpOOhBWVpDxRbCmBAq4Z5QAYGFF6UwNTaRp3DTod792TvyfcFoxvtMdvbhkJFFWRbfPOLvZQOoCqrM)sjlWPYGd5PQxbsttdoI0687dk6Xg87t31AahZ2CYOflaamXcakiSWSCfl7qTpSG2b9fHjw8cKfSJGybazP1SaGcclw6WHfKhxKyTvGt2d)blSXHeWucjfzjNcHf6UUsTux9UHc6lctzmu7JzOu)kC8esPW6P8FPuttRWMpOiSsasXqHnFqr5)sjaJM2nnHnFqryLIzBfEuoSrbG4K9WFWcBCibmLqYMR75uiSq31vQL6Q3nuqFrykJHAFmdL6xHJNqkfwpL)lLAAAf28bfHvcqkgkS5dkk)xkby00UPjS5dkcRumBRWJYHnkaKIwQRE3mocQGlCUpufReMHs9RWagnkux9UzCeubx4CFOkwjmRifwnRI6WbfzWx1x68wc8tZ5nnwPU6DZ4iOcUW5(qvSsywrT5K9WFWcBCibmLqsFP15uiSq31vQL6Q3nuqFrykJHAFmdL6xHJNqkfwpL)lLu0kaHAqOLYe88vbZqP(v44rtsnnbiudcTuMaSqabIY)gLXr3Cp2muQFfoE0Ku7MMwHnFqryLaKIHcB(GIY)LsagnTBAcB(GIWkfZ2k8OCyJcaPOL6Q3nJJGk4cN7dvXkHzOu)kmGrJc1vVBghbvWfo3hQIvcZksHvZQOoCqrg8v9LoVLa)0CEtJvQRE3mocQGlCUpufReMvuBoz0IfaaMybzaI2SalwqEmIt2d)blSXHeWucjw8zo4KH9mPxfXjJwSGCxhwA)jmlw2OFJgwEillmXY(7t)gILRyzhQ9HflBxyJLdZI)SGgwEFqrpgykZshoSqiOjblakjKjlPo(PjblWHfKLL93h8AqrSG2Prql0Ks1Zc(9aqyozp8hSWghsatjKGWNZv1e6kpLuc)(0VHYxLXqTpOdHRxKs4isRZVpOOhBWVp9BO4rwG11q40k1XpnjYiC9IaELtkjKjGsQnW6AiCAPU6Dd(9bVguuMsJGwOjLQpJHAFm43daHmr22CYOfli31HL2FcZILn63OHLhYcYW4)glGR5kuSaGmufReCYE4pyHnoKaMsibHpNRQj0vEkPKLX)T8v5(qvSsGoeUErkPmYehrADEZXpbyabGBLKbqaFlCeP153hu0Jn43N(neaw52aFlLb27AQEdgU0zyp)BuUdhc)gQCvnbc8kBqt72aljJYOb4vx9UzCeubx4CFOkwjmdL6xH5KrlwaayIfKHX)nwUILDO2hwq7G(IWelWHLRZsbzz)9PFdXILtRzPFplx9qwqECrI1wbw8krkCiozp8hSWghsatjKyz8FdDxxPwuqFryYOxLp5Iq630qb9fHjJxjYfH0xbcFoxvtMdNdAYrqTv069bf9M)sP8dZGhfpY20qb9fHjJEv(KVkdOMM(HA7ZdL6xHbSYj1UPrD17gkOVimLXqTpMHs9RWa2d)bld(9PFdziKsH1t5)sjfQRE3qb9fHPmgQ9XSIAAOG(IWK5QmgQ9rHvi85CvnzWVp9BO8vzmu7ttJ6Q3nbpFvWmuQFfgWE4pyzWVp9BidHukSEk)xkPWke(CUQMmhoh0KJGuOU6DtWZxfmdL6xHbmHukSEk)xkPqD17MGNVkywrnnQRE3mocQGlCUpufReMvKce(CUQMmwg)3YxL7dvXkrtJvi85CvnzoCoOjhbPqD17MGNVkygk1VchpHukSEk)xkXjJwSaaWel7Vp9BiwUolxXI1SkFybTd6lctOJLRyzhQ9Hf0oOVimXcSybzbglVpOOhZcCy5HSenWal7qTpSG2b9fHjozp8hSWghsatjKGFF63qCYOflaiUw)BZIt2d)blSXHeWucjZQYE4pyL1h(rx5PKsDxR)TzXjZjJwSaGmufReSy5(nwqECrI1wbozp8hSWgvO)knocQGlCUpufReO76kPU6DtWZxfmdL6xHJxz0WjJwSaaWelXf0J(dbXYUfFszXYgvS4plAcJz538IfKLLydJR1zb)EaimlEbYYdzzO(q4nwCwaSsaIf87bGyXXSO9NyXXSebX4tvtSahw(lLy5EwWqwUNfFMdbHzbzKf(zX7pnS4SetGXc(9aqSqin6gcZj7H)Gf2Oc9hykHeh0J(dbLXw8jfDHebnLFFqrpwjLr31vsD17gvx7vGYWE2168VDfkCU8FnKb)EaiadquOU6DJQR9kqzyp7AD(3Ucfo7tWlYGFpaeGbikAzfi8noOh9hckJT4tAg0tDuK5VaqxHsHvE4pyzCqp6peugBXN0mON6OiZv5U(qT9kAzfi8noOh9hckJT4tAEJCT5VaqxHQPbe(gh0J(dbLXw8jnVrU2muQFfo(y2UPbe(gh0J(dbLXw8jnd6PokYGFpaeGJPcq4BCqp6peugBXN0mON6OiZqP(vyaJgfGW34GE0FiOm2IpPzqp1rrM)caDfQ2CYOflaamXcYHfciqelwUFJfKhxKyTvGflBuXseeJpvnXIxGSa)nASCyIfl3VXIZsSHX16SOU6DwSSrflGeorfUcfNSh(dwyJk0FGPescWcbeik)BughDZ9y0DDLScCwhOPG5aiwrRwi85CvnzcWcbeikds4evqHvbiudcTuMGNVkygYbt00OU6DtWZxfmRO2kAPU6DJQR9kqzyp7AD(3Ucfox(VgYGFpaKsaKMg1vVBuDTxbkd7zxRZ)2vOWzFcErg87bGucG0UPrfIXk6hQTppuQFfgWkNuBoz0IfaeiAZIJz53iw63GFwqfaz5kw(nIfNLydJR1zXYvGqlSahwSC)gl)gXcY4eZ5flQRENf4WIL73yXzbGammfyjUGE0Fiiw2T4tklEbYIf)Ew6WHfKhxKyTvGLRZY9SybwplQelRiwCu(vSOsD4qS8Belbqwoml9Ro8gbYj7H)Gf2Oc9hykHK(AsKH9mPxfHURRuRwTux9Ur11EfOmSNDTo)BxHcNl)xdzWVhakEGBtJ6Q3nQU2RaLH9SR15F7ku4SpbVid(9aqXdCBROLvbicQ86niO63smnnwPU6DZ4iOcUW5(qvSsywrTBROf4SoqtbZbqCttac1GqlLj45RcMHs9RWXJMKAAAfGiOYR3uhQTp3Dsrac1GqlLjaleqGO8VrzC0n3JndL6xHJhnj1UD7MMwGW34GE0FiOm2IpPzqp1rrMHs9RWXdqueGqni0szcE(QGzOu)kC8kNKIaebvE9MIcdudhW2nnx90eb1(tG5(HA7ZdL6xHbmarHvbiudcTuMGNVkygYbt00eGiOYR3auI58sH6Q3naDf4qGzkncAHMuQEZkQPjarqLxVbbv)wIrH6Q3nJJGk4cN7dvXkHzOu)kmGbokux9UzCeubx4CFOkwjmRioz0IfK7vG0SS)(OHdilwUFJfNLISWsSHX16SOU6Dw8cKfKhxKyTvGLdxO)zXvHRNLhYIkXYctGCYE4pyHnQq)bMsij4vG0z1vVJUYtjLWVpA4aIURRul1vVBuDTxbkd7zxRZ)2vOW5Y)1qMHs9RWXdWmOPPrD17gvx7vGYWE2168VDfkC2NGxKzOu)kC8amdAAROvac1GqlLj45RcMHs9RWXdWAAAfGqni0szO0iOfAYQWc0muQFfoEaMcRux9UbORahcmtPrql0Ks1NPIguxSiZksraIGkVEdqjMZR2Tv44FCDocAHM4vkMjXjJwSeJwPrSS)(GxdkcZIL73yXzj2W4ADwux9olQRNLc(SyzJkwIGq9vOyPdhwqECrI1wbwGdliJVcCiqw2JU5EmNSh(dwyJk0FGPesWVp41GIq31vQL6Q3nQU2RaLH9SR15F7ku4C5)Aid(9aqXdOMg1vVBuDTxbkd7zxRZ)2vOWzFcErg87bGIhqTv0karqLxVPouBFU7uttac1GqlLj45RcMHs9RWXdWAAScHpNRQjtamhGf49hSuyvaIGkVEdqjMZRMMwbiudcTugkncAHMSkSandL6xHJhGPWk1vVBa6kWHaZuAe0cnPu9zQOb1flYSIueGiOYR3auI58QDBfTSce(M(AsKH9mPxfz(la0vOAASkaHAqOLYe88vbZqoyIMgRcqOgeAPmbyHaceL)nkJJU5ESzihmrBoz0ILy0knIL93h8AqrywuPoCiwqoSqabI4K9WFWcBuH(dmLqc(9bVgue6UUsTcqOgeAPmbyHaceL)nkJJU5ESzOu)kmGrJcRaN1bAkyoaIv0cHpNRQjtawiGarzqcNOcnnbiudcTuMGNVkygk1Vcdy00wbcFoxvtMayoalW7py1wHvGW30xtImSNj9QiZFbGUcLIaebvE9M6qT95UtkScCwhOPG5aiwbf0xeMmxL9kHch)JRZrql0epYMeNmAXsmcwO)zbe(SaUMRqXYVrSqfilWolX4ocQGlmlaidvXkb6ybCnxHIfGUcCiqwO0iOfAsP6zboSCfl)gXI2XplOcGSa7S4flODqFryIt2d)blSrf6pWucji85CvnHUYtjLaHFEOyyDdLs1JrhcxViLAPU6DZ4iOcUW5(qvSsygk1VchpAAASsD17MXrqfCHZ9HQyLWSIAROL6Q3naDf4qGzkncAHMuQ(mv0G6Ifzgk1VcdyubqtQJ02kAPU6Ddf0xeMYyO2hZqP(v44rfanPosBAux9UHc6lctz9Q8XmuQFfoEubqtQJ02CYE4pyHnQq)bMsibVQ(ne6cjcAk)(GIESskJURR0q9HWBUQMu8(GIEZFPu(HzWJIxzGRcpkh2Oaqkq4Z5QAYac)8qXW6gkLQhZj7H)Gf2Oc9hykHKuiS63qOlKiOP87dk6XkPm6UUsd1hcV5QAsX7dk6n)Ls5hMbpkELJPbnk8OCyJcaPaHpNRQjdi8ZdfdRBOuQEmNSh(dwyJk0FGPesWpP1(K7AFi0fse0u(9bf9yLugDxxPH6dH3CvnP49bf9M)sP8dZGhfVYaxGnuQFfwHhLdBuaifi85CvnzaHFEOyyDdLs1J5KrlwaqGXHfyXsaKfl3Vbxplbpk6kuCYE4pyHnQq)bMsiPdNaLH9C5)Ai0DDL8OCyJcaXjJwSG2Prql0WsSHfilw2OIfxfUEwEilu90WIZsrwyj2W4ADwSCfi0clEbYc2rqS0HdlipUiXARaNSh(dwyJk0FGPesO0iOfAYQWceDxxPwuqFryYOxLp5Iq630qb9fHjdgQ9jxes)MgkOVimz8krUiK(nnQRE3O6AVcug2ZUwN)TRqHZL)RHmdL6xHJhGzqttJ6Q3nQU2RaLH9SR15F7ku4SpbViZqP(v44byg00044FCDocAHM4bojPiaHAqOLYe88vbZqoycfwboRd0uWCae3wrRaeQbHwktWZxfmdL6xHJpMj10eGqni0szcE(QGzihmr7MMREAIGA)jWC)qT95Hs9RWaw5K4KrlwaqGOnlZHA7zrL6WHyzHVcflipUCYE4pyHnQq)bMsiPVMezypt6vrO76kfGqni0szcE(QGzihmHce(CUQMmbWCawG3FWsrlh)JRZrql0epWjjfwfGiOYR3uhQTp3DQPjarqLxVPouBFU7Kch)JRZrql0ayKnP2kSkarqLxVbbv)wIrrlRcqeu51BQd12N7o10eGqni0szcWcbeik)BughDZ9yZqoyI2kScCwhOPG5aiMtgTyb5XfjwBfyXYgvS4plaNKaglXfdqzPfC0ql0WYV5fliBsSexmaLfl3VXcYHfciquBwSC)gC9SOH4RqXYFPelxXsS1qiOEHFw8cKf9velRiwSC)glihwiGarSCDwUNfloMfqcNOceiNSh(dwyJk0FGPesq4Z5QAcDLNskfaZbybE)bRSk0F0HW1lsjRaN1bAkyoaIvGWNZv1KjaMdWc8(dwkA1YX)46Ce0cnXdCssrl1vVBa6kWHaZuAe0cnPu9zQOb1flYSIAASkarqLxVbOeZ5v7Mg1vVBu1qiOEHFZksH6Q3nQAieuVWVzOu)kmGvx9Uj45RcgW14)bR2nnx90eb1(tG5(HA7ZdL6xHbS6Q3nbpFvWaUg)py10eGiOYR3uhQTp3DQTIwwfGiOYR3uhQTp3DQPPLJ)X15iOfAamYMutdi8n91Kid7zsVkY8xaORq1wrle(CUQMmbyHaceLbjCIk00eGqni0szcWcbeik)BughDZ9yZqoyI2T5K9WFWcBuH(dmLqsG0e(pxND9HQsP6r31vcHpNRQjtamhGf49hSYQq)5K9WFWcBuH(dmLqYvbFk)pyHURRecFoxvtMayoalW7pyLvH(ZjJwSG24)s9NWSSbTWs6kSXsCXauw8HybLFfbYsenSGPaSa5K9WFWcBuH(dmLqccFoxvtOR8usjhhbqPzNcOdHRxKsuqFryYCvwVkFaEacY0d)bld(9PFdziKsH1t5)sjGzff0xeMmxL1RYhGVfWfyVRP6ny4sNH98Vr5oCi8BOYv1eiWhZ2itp8hSmwg)3mesPW6P8FPeWsYaiKjoI068MJFItgTyjgTsJyz)9bVgueMflBuXYVrS0puBplhMfxfUEwEilubIow6dvXkblhMfxfUEwEilubIowsaxS4dXI)SaCscySexmaLLRyXlwq7G(IWe6yb5XfjwBfyr74hZIxWFJgwaiadtbmlWHLeWflwGlnilqe0e8iwsHdXYV5flCJYjXsCXauwSSrfljGlwSaxAWc9pl7Vp41GIyPGw4K9WFWcBuH(dmLqc(9bVgue6UUsTU6PjcQ9NaZ9d12Nhk1VcdyKTPPL6Q3nJJGk4cN7dvXkHzOu)kmGrfanPosb(aD6wo(hxNJGwObzgZKARqD17MXrqfCHZ9HQyLWSIA3UPPLJ)X15iOfAagcFoxvtghhbqPzNcaV6Q3nuqFrykJHAFmdL6xHbgi8n91Kid7zsVkY8xaiCEOu)kGhqg0eVYkNutJJ)X15iOfAagcFoxvtghhbqPzNcaV6Q3nuqFrykRxLpMHs9RWade(M(AsKH9mPxfz(laeopuQFfWdidAIxzLtQTckOVimzUk7vcfTSsD17MGNVkywrnnw9UMQ3GFF0Wb0qLRQjW2kA1YQaeQbHwktWZxfmROMMaebvE9gGsmNxkSkaHAqOLYqPrql0KvHfOzf1UPjarqLxVPouBFU7uBfTSkarqLxVbbv)wIPPXk1vVBcE(QGzf1044FCDocAHM4boj1UPP17AQEd(9rdhqdvUQMavOU6DtWZxfmRifTux9Ub)(OHdOb)EaiahZMgh)JRZrql0epWjP2TBAux9Uj45RcMvKcRux9UzCeubx4CFOkwjmRifw9UMQ3GFF0Wb0qLRQjqoz0IfaaMybafewywUIfRzv(WcAh0xeMyXlqwWocILymDDhyailTMfauqyXshoSG84IeRTcCYE4pyHnQq)bMsiPil5uiSq31vQL6Q3nuqFrykRxLpMHs9RWXtiLcRNY)LsnnTcB(GIWkbifdf28bfL)lLamAA30e28bfHvkMTv4r5WgfaIt2d)blSrf6pWucjBUUNtHWcDxxPwQRE3qb9fHPSEv(ygk1VchpHukSEk)xkPOvac1GqlLj45RcMHs9RWXJMKAAcqOgeAPmbyHaceL)nkJJU5ESzOu)kC8OjP2nnTcB(GIWkbifdf28bfL)lLamAA30e28bfHvkMTv4r5WgfaIt2d)blSrf6pWucj9LwNtHWcDxxPwQRE3qb9fHPSEv(ygk1VchpHukSEk)xkPOvac1GqlLj45RcMHs9RWXJMKAAcqOgeAPmbyHaceL)nkJJU5ESzOu)kC8OjP2nnTcB(GIWkbifdf28bfL)lLamAA30e28bfHvkMTv4r5WgfaItgTybzaI2SalwcGCYE4pyHnQq)bMsiXIpZbNmSNj9Qioz0IfaaMyz)9PFdXYdzjAGbw2HAFybTd6lctSahwSSrflxXcS0jyXAwLpSG2b9fHjw8cKLfMybzaI2SenWaMLRZYvSynRYhwq7G(IWeNSh(dwyJk0FGPesWVp9Bi0DDLOG(IWK5QSEv(00qb9fHjdgQ9jxes)MgkOVimz8krUiK(nnQRE3yXN5Gtg2ZKEvKzfPqD17gkOVimL1RYhZkQPPL6Q3nbpFvWmuQFfgWE4pyzSm(VziKsH1t5)sjfQRE3e88vbZkQnNSh(dwyJk0FGPesSm(VXj7H)Gf2Oc9hykHKzvzp8hSY6d)OR8usPUR1)2S4K5Krlw2FFWRbfXshoSKcrqPu9SSknHXSSWxHILydJR15K9WFWcB6Uw)BZsj87dEnOi0DDLSAwf1HdkYO6AVcug2ZUwN)TRqHnumSUOicKtgTyb5o(z53iwaHplwUFJLFJyjfIFw(lLy5HS4GGSSQ)0S8BelPoszbCn(FWILdZY29gw2xv)gILHs9RWSKU0)fPpcKLhYsQ)HnwsHWQFdXc4A8)GfNSh(dwyt316FBwatjKGxv)gcDHebnLFFqrpwjLr31vce(MuiS63qMHs9RWXpuQFfg4beGqMkdq4K9WFWcB6Uw)BZcykHKuiS63qCYCYOflaamXY(7dEnOiwEilaruelRiw(nILy0qEQ6vG0WI6Q3z56SCplwGlnilesJUHyrL6WHyPF1H3Ucfl)gXsri9zj44Nf4WYdzbCLgXIk1HdXcYHfciqeNSh(dwyd(vc)(GxdkcDxxPzvuhoOiZFPKf4uzWH8u1RaPrrlkOVimzUk7vcfw1QL6Q3n)LswGtLbhYtvVcKgZqP(v449WFWYyz8FZqiLcRNY)LsaljJYkArb9fHjZvzv4V10qb9fHjZvzmu7ttdf0xeMm6v5tUiK(TBAux9U5VuYcCQm4qEQ6vG0ygk1VchVh(dwg87t)gYqiLcRNY)LsaljJYkArb9fHjZvz9Q8PPHc6lctgmu7tUiK(nnuqFryY4vICri9B3UPXk1vVB(lLSaNkdoKNQEfinMvu7MMwQRE3e88vbZkQPbHpNRQjtawiGarzqcNOcTveGqni0szcWcbeik)BughDZ9yZqoycfbicQ86n1HA7ZDNAROLvbicQ86naLyoVAAcqOgeAPmuAe0cnzvybAgk1VchpaPTIwQRE3e88vbZkQPXQaeQbHwktWZxfmd5GjAZjJwSaaWelXf0J(dbXYUfFszXYgvS8B0qSCywkilE4peelyl(KIowCmlA)jwCmlrqm(u1elWIfSfFszXY9BSaiwGdlDYcnSGFpaeMf4WcSyXzjMaJfSfFszbdz538NLFJyPilSGT4tkl(mhccZcYil8ZI3FAy538NfSfFszHqA0neMt2d)blSb)atjK4GE0FiOm2IpPOlKiOP87dk6XkPm6UUswbcFJd6r)HGYyl(KMb9uhfz(la0vOuyLh(dwgh0J(dbLXw8jnd6PokYCvURpuBVIwwbcFJd6r)HGYyl(KM3ixB(la0vOAAaHVXb9O)qqzSfFsZBKRndL6xHJhnTBAaHVXb9O)qqzSfFsZGEQJIm43dab4yQae(gh0J(dbLXw8jnd6PokYmuQFfgWXubi8noOh9hckJT4tAg0tDuK5VaqxHItgTybaGjmlihwiGarSCDwqECrI1wbwomlRiwGdljGlw8HybKWjQWvOyb5XfjwBfyXY9BSGCyHaceXIxGSKaUyXhIfvsdTWcYMelXfdq5K9WFWcBWpWucjbyHaceL)nkJJU5Em6UUswboRd0uWCaeROvle(CUQMmbyHaceLbjCIkOWQaeQbHwktWZxfmd5Gjuy1SkQdhuKjAUu4aEUo7tWRlKJwASpnnQRE3e88vbZkQTch)JRZrql0ayLq2Ku0sD17gkOVimL1RYhZqP(v44voPMg1vVBOG(IWugd1(ygk1VchVYj1UPrfIXk6hQTppuQFfgWkNKcRcqOgeAPmbpFvWmKdMOnNmAXcYHf49hSyPdhwCTMfq4Jz538NLuhicZcEnel)gLGfFOc9pld1hcVrGSyzJkwIXDeubxywaqgQIvcw2CmlAcJz538If0WcMcywgk1V6kuSahw(nIfGsmNxSOU6DwomlUkC9S8qw6UwZcS3zboS4vcwq7G(IWelhMfxfUEwEilesJUH4K9WFWcBWpWucji85CvnHUYtjLaHFEOyyDdLs1JrhcxViLAPU6DZ4iOcUW5(qvSsygk1VchpAAASsD17MXrqfCHZ9HQyLWSIARWk1vVBghbvWfo3hQIvIm(Q(sN3sGFAo3SIu0sD17gGUcCiWmLgbTqtkvFMkAqDXImdL6xHbmQaOj1rABfTux9UHc6lctzmu7JzOu)kC8OcGMuhPnnQRE3qb9fHPSEv(ygk1VchpQaOj1rAttlRux9UHc6lctz9Q8XSIAASsD17gkOVimLXqTpMvuBfw9UMQ3GHA8FbYqLRQjW2CYOflihwG3FWILFZFwcBuaimlxNLeWfl(qSaxp(ajwOG(IWelpKfyPtWci8z53OHyboSCOk4qS8BhMfl3VXYouJ)lqCYE4pyHn4hykHee(CUQMqx5PKsGWpdxp(aPmf0xeMqhcxViLAzL6Q3nuqFrykJHAFmRifwPU6Ddf0xeMY6v5Jzf1UP5DnvVbd14)cKHkxvtGCYE4pyHn4hykHKuiS63qOlKiOP87dk6XkPm6UUsd1hcV5QAsrl1vVBOG(IWugd1(ygk1Vch)qP(v4Mg1vVBOG(IWuwVkFmdL6xHJFOu)kCtdcFoxvtgq4NHRhFGuMc6lctTvmuFi8MRQjfVpOO38xkLFyg8O4vgqk8OCyJcaPaHpNRQjdi8ZdfdRBOuQEmNSh(dwyd(bMsibVQ(ne6cjcAk)(GIESskJURR0q9HWBUQMu0sD17gkOVimLXqTpMHs9RWXpuQFfUPrD17gkOVimL1RYhZqP(v44hk1Vc30GWNZv1Kbe(z46XhiLPG(IWuBfd1hcV5QAsX7dk6n)Ls5hMbpkELbKcpkh2Oaqkq4Z5QAYac)8qXW6gkLQhZj7H)Gf2GFGPesWpP1(K7AFi0fse0u(9bf9yLugDxxPH6dH3CvnPOL6Q3nuqFrykJHAFmdL6xHJFOu)kCtJ6Q3nuqFrykRxLpMHs9RWXpuQFfUPbHpNRQjdi8ZW1Jpqktb9fHP2kgQpeEZv1KI3hu0B(lLYpmdEu8kdCv4r5WgfasbcFoxvtgq4Nhkgw3qPu9yoz0IfaaMybabghwGflbqwSC)gC9Se8OORqXj7H)Gf2GFGPes6Wjqzypx(VgcDxxjpkh2OaqCYOflaamXcY4RahcKL9OBUhZIL73yXReSOHfkwOcUqTXI2X)vOybTd6lctS4fil)KGLhYI(kIL7zzfXIL73ybGU0yFyXlqwqECrI1wbozp8hSWg8dmLqcLgbTqtwfwGO76k1QL6Q3nuqFrykJHAFmdL6xHJx5KAAux9UHc6lctz9Q8XmuQFfoELtQTIaeQbHwktWZxfmdL6xHJpMjPOL6Q3nrZLchWZ1zFcEDHC0sJ9XGW1lcWacztQPXQzvuhoOit0CPWb8CD2NGxxihT0yFmumSUOicSD7Mg1vVBIMlfoGNRZ(e86c5OLg7JbHRxu8kbiawsnnbiudcTuMGNVkygYbtOWX)46Ce0cnXdCsItgTybaGjwqECrI1wbwSC)glihwiGaribz8vGdbYYE0n3JzXlqwaHf6FwGiOXYCpXcaDPX(WcCyXYgvSeBnecQx4NflWLgKfcPr3qSOsD4qSG84IeRTcSqin6gcZj7H)Gf2GFGPesq4Z5QAcDLNskfaZbybE)bRm(rhcxViLScCwhOPG5aiwbcFoxvtMayoalW7pyPOvRaeQbHwkdLgLyixNHdy5vGmdL6xHbSYaxagWAPSYa)SkQdhuKbFvFPZBjWpnN3wbfdRlkIanuAuIHCDgoGLxbQDtJJ)X15iOfAIxjGtskAz17AQEtFnjYWEM0RImu5QAcSPrD17MGNVkyaxJ)hSIpaHAqOLY0xtImSNj9QiZqP(vyGbqARaHpNRQjZVnNwNXebenzl(9kAPU6DdqxboeyMsJGwOjLQptfnOUyrMvutJvbicQ86naLyoVAR49bf9M)sP8dZGhfV6Q3nbpFvWaUg)pyb8jzaynnQqmwr)qT95Hs9RWawD17MGNVkyaxJ)hSAAcqeu51BQd12N7o10OU6DJQgcb1l8Bwrkux9UrvdHG6f(ndL6xHbS6Q3nbpFvWaUg)pybSwahGFwf1HdkYenxkCapxN9j41fYrln2hdfdRlkIaB3wHvQRE3e88vbZksrlRcqeu51BQd12N7o10eGqni0szcWcbeik)BughDZ9yZkQPrfIXk6hQTppuQFfgWbiudcTuMaSqabIY)gLXr3Cp2muQFfgya3MM(HA7ZdL6xHrMitLbijby1vVBcE(QGbCn(FWQnNmAXcaatS8BelXyP63smSy5(nwCwqECrI1wbw(n)z5Wf6Fw6dmLfa6sJ9Ht2d)blSb)atjKmocQGlCUpufReO76kPU6DtWZxfmdL6xHJxz000OU6DtWZxfmGRX)dwaoMjPaHpNRQjtamhGf49hSY4Nt2d)blSb)atjKeinH)Z1zxFOQuQE0DDLq4Z5QAYeaZbybE)bRm(v0Yk1vVBcE(QGbCn(FWk(yMutJvbicQ86niO63smTBAux9UzCeubx4CFOkwjmRifQRE3mocQGlCUpufReMHs9RWag4aSaSax3BIgkCyk76dvLs1B(lLYiC9IawlRux9UrvdHG6f(nRifw9UMQ3GFF0Wb0qLRQjW2CYE4pyHn4hykHKRc(u(FWcDxxje(CUQMmbWCawG3FWkJFoz0ILyS(CUQMyzHjqwGflU6PV)iml)M)SyXRNLhYIkXc2rqGS0HdlipUiXARalyil)M)S8Bucw8HQNflo(jqwqgzHFwuPoCiw(nkLt2d)blSb)atjKGWNZv1e6kpLuc7iOCho5GNVkGoeUErkzvac1GqlLj45RcMHCWennwHWNZv1KjaleqGOmiHtubfbicQ86n1HA7ZDNAAaN1bAkyoaI5KrlwaaycZcaceTz56SCflEXcAh0xeMyXlqw(5imlpKf9vel3ZYkIfl3VXcaDPX(GowqECrI1wbw8cKL4c6r)HGyz3IpPCYE4pyHn4hykHK(AsKH9mPxfHURRef0xeMmxL9kHcpkh2Oaqkux9UjAUu4aEUo7tWRlKJwASpgeUEragqiBskAbcFJd6r)HGYyl(KMb9uhfz(la0vOAASkarqLxVPOWa1WbSTce(CUQMmyhbL7Wjh88vbfTux9UzCeubx4CFOkwjmdL6xHbmWba3cna)SkQdhuKbFvFPZBjWpnN3wH6Q3nJJGk4cN7dvXkHzf10yL6Q3nJJGk4cN7dvXkHzf1MtgTybaGjwaqx0VXY(7t31AwIgyaZY1zz)9P7AnlhUq)ZYkIt2d)blSb)atjKGFF6UwJURRK6Q3nWI(nCoIMaf9hSmRifQRE3GFF6UwBgQpeEZv1eNSh(dwyd(bMsij4vG0z1vVJUYtjLWVpA4aIURRK6Q3n43hnCandL6xHbmAu0sD17gkOVimLXqTpMHs9RWXJMMg1vVBOG(IWuwVkFmdL6xHJhnTv44FCDocAHM4bojXjJwSeJwPrywIlgGYIk1HdXcYHfciqell8vOy53iwqoSqabIyjalW7pyXYdzjSrbGy56SGCyHaceXYHzXd)Y16eS4QW1ZYdzrLyj44Nt2d)blSb)atjKGFFWRbfHURRuaIGkVEtDO2(C3jfi85CvnzcWcbeikds4evqrac1GqlLjaleqGO8VrzC0n3JndL6xHbmAuyf4SoqtbZbqSckOVimzUk7vcfo(hxNJGwOjEKnjoz0IfaaMyz)9P7AnlwUFJL9N0AFyjgnx)zXlqwkil7VpA4aIowSSrflfKL93NUR1SCywwrOJLeWfl(qSCflwZQ8Hf0oOVimXshoSaqagMcywGdlpKLObgybGU0yFyXYgvS4QqeelaNKyjUyaklWHfhmY)dbXc2IpPSS5ywaiadtbmldL6xDfkwGdlhMLRyPRpuBVHL4aFILFZFwwfinS8BelypLyjalW7pyHz5E0JzbmcZsrRFCnlpKL93NUR1SaUMRqXsmUJGk4cZcaYqvSsGowSSrfljGl0dYc(pTMfQazzfXIL73yb4KeWCCelD4WYVrSOD8Zcknu11ydNSh(dwyd(bMsib)(0DTgDxxP31u9g8tATpzW56VHkxvtGkS6DnvVb)(OHdOHkxvtGkux9Ub)(0DT2muFi8MRQjfTux9UHc6lctz9Q8XmuQFfoEaIckOVimzUkRxLpkux9UjAUu4aEUo7tWRlKJwASpgeUEragqOjPMg1vVBIMlfoGNRZ(e86c5OLg7JbHRxu8kbi0KKch)JRZrql0epWjPMgq4BCqp6peugBXN0mON6OiZqP(v44binnE4pyzCqp6peugBXN0mON6OiZv5U(qT9TveGqni0szcE(QGzOu)kC8kNeNmAXcaatSS)(GxdkIfa0f9BSenWaMfVazbCLgXsCXauwSSrflipUiXARalWHLFJyjglv)wIHf1vVZYHzXvHRNLhYs31AwG9olWHLeWf6bzj4rSexmaLt2d)blSb)atjKGFFWRbfHURRK6Q3nWI(nCoOjFYio8blZkQPrD17gGUcCiWmLgbTqtkvFMkAqDXImROMg1vVBcE(QGzfPOL6Q3nJJGk4cN7dvXkHzOu)kmGrfanPosb(aD6wo(hxNJGwObzgZKAdSyc8VRP6nfzjNcHLHkxvtGkSAwf1HdkYGVQV05Te4NMZvOU6DZ4iOcUW5(qvSsywrnnQRE3e88vbZqP(vyaJkaAsDKc8b60TC8pUohbTqdYmMj1UPrD17MXrqfCHZ9HQyLiJVQV05Te4NMZnROMMwQRE3mocQGlCUpufReMHs9RWa2d)bld(9PFdziKsH1t5)sjf4isRZBo(jaNKbzBAux9UzCeubx4CFOkwjmdL6xHbSh(dwglJ)BgcPuy9u(VuQPbHpNRQjZfdG5aSaV)GLIaeQbHwkZv4WSExvt5yy51VsZGeIlqMHCWekOyyDrreO5kCywVRQPCmS86xPzqcXfO2kux9UzCeubx4CFOkwjmROMgRux9UzCeubx4CFOkwjmRifwfGqni0szghbvWfo3hQIvcZqoyIMgRcqeu51Bqq1VLyA3044FCDocAHM4bojPGc6lctMRYELGtgTyX6tcwEilPoqel)gXIkHFwGDw2FF0WbKf1eSGFpa0vOy5EwwrSedRlaKoblxXIxjybTd6lctSOUEwaOln2hwoC9S4QW1ZYdzrLyjAGHabYj7H)Gf2GFGPesWVp41GIq31v6DnvVb)(OHdOHkxvtGkSAwf1HdkY8xkzbovgCipv9kqAu0sD17g87JgoGMvutJJ)X15iOfAIh4KuBfQRE3GFF0Wb0GFpaeGJPIwQRE3qb9fHPmgQ9XSIAAux9UHc6lctz9Q8XSIARqD17MO5sHd456SpbVUqoAPX(yq46fbyabWssrRaeQbHwktWZxfmdL6xHJx5KAAScHpNRQjtawiGarzqcNOckcqeu51BQd12N7o1MtgTybTX)L6pHzzdAHL0vyJL4IbOS4dXck)kcKLiAybtbybYj7H)Gf2GFGPesq4Z5QAcDLNsk54iakn7uaDiC9IuIc6lctMRY6v5dWdqqME4pyzWVp9BidHukSEk)xkbmROG(IWK5QSEv(a8TaUa7DnvVbdx6mSN)nk3HdHFdvUQMab(y2gz6H)GLXY4)MHqkfwpL)lLawsgKfnitCeP15nh)eWsYGgG)DnvVP8FneoR6AVcKHkxvtGCYOflXOvAel7Vp41GIy5kwCwayadtbw2HAFybTd6lctOJfqyH(Nfn9SCplrdmWcaDPX(WsRFZFwomlBEbQjqwutWcD)gnS8Bel7VpDxRzrFfXcCy53iwIlgGgpWjjw0xrS0Hdl7Vp41GIAJowaHf6FwGiOXYCpXIxSaGUOFJLObgyXlqw00ZYVrS4Qqeel6Riw28cutSS)(OHdiNSh(dwyd(bMsib)(GxdkcDxxjRMvrD4GIm)LswGtLbhYtvVcKgfTux9UjAUu4aEUo7tWRlKJwASpgeUEragqaSKAAux9UjAUu4aEUo7tWRlKJwASpgeUEragqOjjfVRP6n4N0AFYGZ1FdvUQMaBROff0xeMmxLXqTpkC8pUohbTqdWq4Z5QAY44iakn7ua4vx9UHc6lctzmu7JzOu)kmWaHVPVMezypt6vrM)caHZdL6xb8aYGM4bij10qb9fHjZvz9Q8rHJ)X15iOfAagcFoxvtghhbqPzNcaV6Q3nuqFrykRxLpMHs9RWade(M(AsKH9mPxfz(laeopuQFfWdidAIh4KuBfwPU6DdSOFdNJOjqr)blZksHvVRP6n43hnCanu5QAcurRaeQbHwktWZxfmdL6xHJhG10GHlT6vGMFBoToJjciAmu5QAcuH6Q3n)2CADgteq0yWVhacWXmMa4wZQOoCqrg8v9LoVLa)0CoWJM2k6hQTppuQFfoELtkjf9d12Nhk1VcdyaLusTv0kaHAqOLYa0vGdbMXr3Cp2muQFfoEawtJvbicQ86naLyoVAZjJwSaaWelaOGWcZYvSynRYhwq7G(IWelEbYc2rqSeJPR7adazP1SaGcclw6WHfKhxKyTvGfVazbz8vGdbYcANgbTqtkvpNSh(dwyd(bMsiPil5uiSq31vQL6Q3nuqFrykRxLpMHs9RWXtiLcRNY)LsnnTcB(GIWkbifdf28bfL)lLamAA30e28bfHvkMTv4r5WgfasbcFoxvtgSJGYD4KdE(QaNSh(dwyd(bMsizZ19CkewO76k1sD17gkOVimL1RYhZqP(v44jKsH1t5)sjfwfGiOYR3auI58QPPL6Q3naDf4qGzkncAHMuQ(mv0G6Ifzwrkcqeu51BakXCE1UPPvyZhuewjaPyOWMpOO8FPeGrt7MMWMpOiSsXSPrD17MGNVkywrTv4r5WgfasbcFoxvtgSJGYD4KdE(QGIwQRE3mocQGlCUpufReMHs9RWaUfAaWac4NvrD4GIm4R6lDElb(P582kux9UzCeubx4CFOkwjmROMgRux9UzCeubx4CFOkwjmRO2CYE4pyHn4hykHK(sRZPqyHURRul1vVBOG(IWuwVkFmdL6xHJNqkfwpL)lLuyvaIGkVEdqjMZRMMwQRE3a0vGdbMP0iOfAsP6ZurdQlwKzfPiarqLxVbOeZ5v7MMwHnFqryLaKIHcB(GIY)LsagnTBAcB(GIWkfZMg1vVBcE(QGzf1wHhLdBuaifi85CvnzWock3Hto45RckAPU6DZ4iOcUW5(qvSsygk1Vcdy0OqD17MXrqfCHZ9HQyLWSIuy1SkQdhuKbFvFPZBjWpnN30yL6Q3nJJGk4cN7dvXkHzf1MtgTybaGjwqgGOnlWILaiNSh(dwyd(bMsiXIpZbNmSNj9Qioz0IfaaMyz)9PFdXYdzjAGbw2HAFybTd6lctOJfKhxKyTvGLnhZIMWyw(lLy538IfNfKHX)nwiKsH1tSOP(ZcCybw6eSynRYhwq7G(IWelhMLveNSh(dwyd(bMsib)(0VHq31vIc6lctMRY6v5ttdf0xeMmyO2NCri9BAOG(IWKXRe5Iq6300sD17gl(mhCYWEM0RImROMgCeP15nh)eGtYGSOrHvbicQ86niO63smnn4isRZBo(jaNKbzveGiOYR3GGQFlX0wH6Q3nuqFrykRxLpMvuttl1vVBcE(QGzOu)kmG9WFWYyz8FZqiLcRNY)Lskux9Uj45RcMvuBoz0IfaaMybzy8FJf4VrJLdtSyz7cBSCywUILDO2hwq7G(IWe6yb5XfjwBfyboS8qwIgyGfRzv(WcAh0xeM4K9WFWcBWpWucjwg)34KrlwaqCT(3MfNSh(dwyd(bMsizwv2d)bRS(Wp6kpLuQ7A9Vnl73(TTba]] )

end