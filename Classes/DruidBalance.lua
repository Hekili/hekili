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


    spec:RegisterPack( "Balance", 20210804, [[divwWfqikPEeePUeejTjs4tqQmkPKtjLAvqO6vqiZcIQBbaAxu8liIHjf1XirTmaYZekAAqQQRbP02aq13GqX4aqCoiuADaOmpaQ7rISpHQ(hejsDqHsTqHsEiKIjsjP6IusyJaq5JuskYiHirYjPKKvkf5LqKOMjLeDtaOYofQ4NaqvdfaPJsjPOwkLKspvPmvHcxfayRusk8visySaq2lL6VIAWehMQftspwWKb6YiBwQ(mKmALQtRYQHir8Aiy2K62I0UL8BqdxihhsvwUINd10v11vY2b03PeJhIY5LcRxOsZxe7h12kBhd7nq)j74aOMbKYndqAg9nkRmGAgTaC7TVrezVf5beCuK9w5PK9wSCTxbYElYBOHoODmS3WW1ei7T9)JWamKGevx7vGaG4lnyqD)(s1CqKelx7vGaGBxkAqskOz)t1iLUFAsjvx7vGmpYE7n11PFRQSvT3a9NSJdGAgqk3maPz03OSYaQ5yIw7nF97WXEB7srJ92(bcsLTQ9giHd2BXY1EfiwS6Z6a5MI9c1c)SetKZcGAgqkZnXnHMDVqryag3eaKLydcsGSSb1(WsSip1Wnbazbn7EHIaz59bf95RZsWXeMLhYsOrqt53hu0JnCtaqwSAPuiqcKLvvuGWyFAWcqFoxvtywADgYGCwIgcyg)(GxdkIfay8Seneqd(9bVguuBd3eaKLydeEGSenuWX)vOybPy8FNLRZY9OdZYVtSyzGfkwSIG(IWKHBcaYcaohbIf0alGqeiw(DILTOBUhZIZI((xtSKchILUMq2PQjwADDwAaxSS7Gf6Ew2VNL7zbFPl97fbxyDdwSC)olXcaFSJbliIf0qAc)NRzj26dvLs1JCwUhDGSGr4IAB4MaGSaGZrGyjfIFwqx)qT)5Hs9RWOJfCGkFoiMfpks3GLhYIkeJzPFO2FmlWs3WWnbazjgd5plXaMsSa7SelTVZsS0(olXs77S4ywCwWru4Cnl)Cfc0B4MaGSaGpIkAyP1zidYzbPy8Fh5SGum(VJCw2EF63qTzj1bjwsHdXYq4tFu9S8qwiF0hnSeGPQ(daXVpVHBIBk2vbF)jqwILR9kqSeBaQvYsWlwujw6WvbYI)SS)FegGHeKO6AVceaeFPbdQ73xQMdIKy5AVceaC7srdssbn7FQgP09ttkP6AVcK5r2BVPp8JTJH9gmIkASJHDCu2og2Bu5QAc0ow2BE4pyzVzz8F3EdKWH5I(dw2Ba0Hco(zbqSGum(VZIxGS4SS9(GxdkIfyXYwmyXY97SeNd1(ZcaMtS4filXcg7yWcCyz79PFdXc83PXYHj7TWCpnNBV1IfkOVimz0RYNCri7zjjHfkOVimzUkJHAFyjjHfkOVimzUkRc)DwssyHc6lctgVAKlczplTzrblrdb0OSXY4)olkyXAwIgcObqglJ)72VDCaKDmS3OYv1eODSS38WFWYEd)(0VHS3cZ90CU9M1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYssclwZsacKkVEtDO2)C3jwssyXAwWrKwNFFqrp2GFF6UwZIsSOmljjSynlVRP6nL)RHWzvx7vGmu5QAcKLKewAXcf0xeMmyO2NCri7zjjHfkOVimzUkRxLpSKKWcf0xeMmxLvH)oljjSqb9fHjJxnYfHSNL22B6ROCa0EdT2VDCIPDmS3OYv1eODSS38WFWYEd)(GxdkYElm3tZ52BZQOoCqrgvx7vGYWE2168VFfkSHkxvtGSOGLaeivE9M6qT)5UtSOGfCeP153hu0Jn43NUR1SOelkBVPVIYbq7n0A)2V9gi19L(TJHDCu2og2BE4pyzVHHAFYQKNAVrLRQjq7yz)2Xbq2XWEJkxvtG2XYElm3tZ52B)LsSaywAXcGybXzXd)blJLX)DtWXF(VuIfeXIh(dwg87t)gYeC8N)lLyPT9Mh(dw2BbxRZE4pyL1h(T30h(ZLNs2BWiQOX(TJtmTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEdhrAD(9bf9yd(9P7AnlXZIYSOGLwSynlVRP6n43hnCanu5QAcKLKewExt1BWpP1(KbNR)gQCvnbYsBwssybhrAD(9bf9yd(9P7AnlXZcGS3ajCyUO)GL92g9ywIn0kybwSeteXIL73HRNfW56plEbYIL73zz79rdhqw8cKfaHiwG)onwomzVb0NC5PK92HZoKSF74G(2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVHJiTo)(GIESb)(0VHyjEwu2EdKWH5I(dw2BB0JzjOjhiXILDQyz79PFdXsWlw2VNfaHiwEFqrpMfl7xyNLdZYqAcOxplD4WYVtSyfb9fHjwEilQelrd1Pziqw8cKfl7xyNL(P10WYdzj443EdOp5Ytj7TdNdAYbs2VDCqRDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2Brdb0KcHv)gILKewIgcObVQ(neljjSeneqd(9bVgueljjSeneqd(9P7AnljjSeneqtFnnYWEM0RIyjjHf1vVBcE(QGzOu)kmlkXI6Q3nbpFvWaUg)pyzVbs4WCr)bl7nRg(CUQMy539NLWofqaZY1zPbCXIpelxXIZcQailpKfhi8az53jwW3V8)Gflw2PHyXz5NRqGEwOpWYHzzHjqwUIfv6TquXsWXp2EdOp5Ytj7TRYOcG2VDCa42XWEJkxvtG2XYEZd)bl7nvAW0GWvOS3ajCyUO)GL9gaatSelAW0GWvOyXY97SGMyJeRQcSahw8(tdlObwaHiqSCflOj2iXQQG9wyUNMZT3AXslwSMLaeivE9M6qT)5UtSKKWI1SeGqni0szcWciebk)7ughDZ9yZkIL2SOGf1vVBcE(QGzOu)kmlXZIYOLffSOU6DZ4aPcUW5(qvCBygk1VcZcGzb9zrblwZsacKkVEdqQ(9gdljjSeGaPYR3aKQFVXWIcwux9Uj45RcMvelkyrD17MXbsfCHZ9HQ42WSIyrblTyrD17MXbsfCHZ9HQ42WmuQFfMfaZIYkZcaKf0YcIZYSkQdhuKbFvFPZ7nWpnNBOYv1eiljjSOU6DtWZxfmdL6xHzbWSOSYSKKWIYSGewWrKwN3D8tSaywu2Gw0YsBwAZIcwa6Z5QAYCvgva0(TJdIXog2Bu5QAc0ow2BH5EAo3EtD17MGNVkygk1VcZs8SOmAzrblTyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazjjHf1vVBghivWfo3hQIBdZqP(vywamlkJyybaYcGybXzrD17gvnecQx43SIyrblQRE3moqQGlCUpuf3gMvelTzjjHfvigZIcw6hQ9ppuQFfMfaZcGqR9giHdZf9hSS3aOWNfl3VZIZcAInsSQkWYV7plhUq3ZIZcaDPX(Ws0adSahwSStfl)oXs)qT)SCywCv46z5HSqfO9Mh(dw2BrW)GL9BhhaIDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2Bb60S0ILwS0pu7FEOu)kmlaqwugTSaazjaHAqOLYe88vbZqP(vywAZcsyrzasZS0MfLyjqNMLwS0IL(HA)ZdL6xHzbaYIYOLfailbiudcTuMaSacrGY)oLXr3Cp2aUg)pyXcaKLaeQbHwktawaHiq5FNY4OBUhBgk1VcZsBwqclkdqAML2SOGfRzz8dmtaP6noii2qi7WpMLKewcqOgeAPmbpFvWmuQFfML4z5QNMiO2Fcm3pu7FEOu)kmljjSmRI6WbfzcKMW)56mo6M7XgQCvnbYIcwcqOgeAPmbpFvWmuQFfML4zjMnZssclbiudcTuMaSacrGY)oLXr3Cp2muQFfML4z5QNMiO2Fcm3pu7FEOu)kmlaqwuUzwssyXAwcqGu51BQd1(N7ozVbs4WCr)bl7n046Ws7pHzXYo970WYcFfkwqdSacrGyPGwyXYP1S4An0clnGlwEil4)0Awco(z53jwWEkXINcx1ZcSZcAGfqiceIqtSrIvvbwco(X2Ba9jxEkzVfGfqicugKWnQG9BhheRDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2BTyPFO2)8qP(vywINfLrlljjSm(bMjGu9gheeBUIL4zbTnZsBwuWslwAXslwi0BDrreOHsJAmKRZWbS8kqSOGLwSeGqni0szO0Ogd56mCalVcKzOu)kmlaMfLb4nZssclbiqQ86naP63BmSOGLaeQbHwkdLg1yixNHdy5vGmdL6xHzbWSOmahXWcIyPflkRmliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0ML2SOGfRzjaHAqOLYqPrngY1z4awEfiZqoydwAZsscle6TUOic0GHlTM()ku5zP2GffS0IfRzjabsLxVPou7FU7eljjSeGqni0szWWLwt)FfQ8SuBKJj6JwasZkBgk1VcZcGzrzLrFwAZssclTyjaHAqOLYOsdMgeUcLzihSbljjSynlJhiZpqTML2SOGLwS0Ifc9wxuebAUchM17QAkJElV(vAgKaEbIffS0ILaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgSKKWIh(dwMRWHz9UQMYO3YRFLMbjGxGmGh2v1eilTzPnljjS0Ifc9wxuebAW7oi0cbMHJAg2ZpCsP6zrblbiudcTuMhoPu9ey(k8HA)ZXeTOnMaszZqP(vywAZssclTyPfla95CvnzGvEHP8pxHa9SOelkZsscla95CvnzGvEHP8pxHa9SOelXKL2SOGLwS8ZviqV5v2mKd2ihGqni0sXsscl)Cfc0BELnbiudcTuMHs9RWSeplx90eb1(tG5(HA)ZdL6xHzbaYIYnZsBwssybOpNRQjdSYlmL)5keONfLybqSOGLwS8ZviqV5bKzihSroaHAqOLILKew(5keO38aYeGqni0szgk1VcZs8SC1tteu7pbM7hQ9ppuQFfMfailk3mlTzjjHfG(CUQMmWkVWu(NRqGEwuILMzPnlTzPnljjSeGaPYR3GqJ58IL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSS3ajCyUO)GL9gaatGS8qwajT3GLFNyzHDuelWolOj2iXQQalw2PILf(kuSacxQAIfyXYctS4filrdbKQNLf2rrSyzNkw8IfheKfcivplhMfxfUEwEilGhzVb0NC5PK9wamhGf49hSSF74OCZ2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVznly4sREfO53NtRZyIqGgdvUQMazjjHL(HA)ZdL6xHzjEwauZnZssclQqmMffS0pu7FEOu)kmlaMfaHwwqelTyb9BMfailQRE387ZP1zmriqJb)EabwqCwaelTzjjHf1vVB(9506mMieOXGFpGalXZsmbiSaazPflZQOoCqrg8v9LoV3a)0CUHkxvtGSG4SGwwABVbs4WCr)bl7nRg(CUQMyzHjqwEilGK2BWIxny5NRqGEmlEbYsaeZILDQyXIF)vOyPdhw8IfRyfTdNZzjAGb7nG(KlpLS3(9506mMieOjBXV3(TJJYkBhd7nQCvnbAhl7nqchMl6pyzVbaWelwrAuJHCnla4hWYRaXcGAgtbmlQuhoelolOj2iXQQallmzS3kpLS3O0Ogd56mCalVcK9wyUNMZT3cqOgeAPmbpFvWmuQFfMfaZcGAMffSeGqni0szcWciebk)7ughDZ9yZqP(vywamlaQzwuWslwa6Z5QAY87ZP1zmriqt2IFpljjSOU6DZVpNwNXeHang87beyjEwIzZSGiwAXYSkQdhuKbFvFPZ7nWpnNBOYv1eiliolaCwAZsBwuWcqFoxvtMRYOcGSKKWIkeJzrbl9d1(Nhk1VcZcGzjMig7np8hSS3O0Ogd56mCalVcK9BhhLbKDmS3OYv1eODSS3ajCyUO)GL9gaatSSbxAn9xHIfR2LAdwa4ykGzrL6WHyXzbnXgjwvfyzHjJ9w5PK9ggU0A6)RqLNLAd7TWCpnNBV1ILaeQbHwktWZxfmdL6xHzbWSaWzrblwZsacKkVEdqQ(9gdlkyXAwcqGu51BQd1(N7oXssclbiqQ86n1HA)ZDNyrblbiudcTuMaSacrGY)oLXr3Cp2muQFfMfaZcaNffS0IfG(CUQMmbybeIaLbjCJkWssclbiudcTuMGNVkygk1VcZcGzbGZsBwssyjabsLxVbiv)EJHffS0IfRzzwf1HdkYGVQV059g4NMZnu5QAcKffSeGqni0szcE(QGzOu)kmlaMfaoljjSOU6DZ4aPcUW5(qvCBygk1VcZcGzrz0NfeXslwqlliole6TUOic0Cf(Nv4HdodEaVIYQKwZsBwuWI6Q3nJdKk4cN7dvXTHzfXsBwssyPFO2)8qP(vywamlacTSKKWcHERlkIanuAuJHCDgoGLxbIffSeGqni0szO0Ogd56mCalVcKzOu)kmlXZcGAML2SOGfG(CUQMmxLrfazrblwZcHERlkIanxHdZ6DvnLrVLx)kndsaVaXssclbiudcTuMRWHz9UQMYO3YRFLMbjGxGmdL6xHzjEwauZSKKWIkeJzrbl9d1(Nhk1VcZcGzbqnBV5H)GL9ggU0A6)RqLNLAd73ookht7yyVrLRQjq7yzVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3ux9Uj45RcMHs9RWSeplkJwwuWslwSMLzvuhoOid(Q(sN3BGFAo3qLRQjqwssyrD17MXbsfCHZ9HQ42WmuQFfMfaRelkdiwqelTyjMSG4SOU6DJQgcb1l8BwrS0MfeXslwAXcaHfailOLfeNf1vVBu1qiOEHFZkIL2SG4SqO36IIiqZv4FwHho4m4b8kkRsAnlTzrblQRE3moqQGlCUpuf3gMvelTzjjHfvigZIcw6hQ9ppuQFfMfaZcGqlljjSqO36IIiqdLg1yixNHdy5vGyrblbiudcTugknQXqUodhWYRazgk1VcBVbs4WCr)bl7TyRT4nWSSWelwLvZwDwSC)olOj2iXQQG9gqFYLNs2Bh6bMdWc8(dw2VDCug9TJH9gvUQMaTJL9Mh(dw2BxHdZ6DvnLrVLx)kndsaVazVfM7P5C7nG(CUQMmh6bMdWc8(dwSOGfG(CUQMmxLrfaT3kpLS3UchM17QAkJElV(vAgKaEbY(TJJYO1og2Bu5QAc0ow2BGeomx0FWYEdaGjwMd1(ZIk1HdXsaeBVvEkzVH3DqOfcmdh1mSNF4Ks1BVfM7P5C7TwSeGqni0szcE(QGzihSblkyXAwcqGu51BQd1(N7oXIcwa6Z5QAY87ZP1zmriqt2IFpljjSeGaPYR3uhQ9p3DIffSeGqni0szcWciebk)7ughDZ9yZqoydwuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcE(QGzihSblTzPnlkybe(g8Q63qM)ciCfkwuWslwaHVb)Kw7tUR9Hm)fq4kuSKKWI1S8UMQ3GFsR9j31(qgQCvnbYsscl4isRZVpOOhBWVp9BiwINLyYsBwuWslwaHVjfcR(nK5VacxHIL2SOGLwSa0NZv1K5WzhsSKKWYSkQdhuKr11EfOmSNDTo)7xHcBOYv1eiljjS44FCDocAHgwIxjwqSnZssclQRE3OQHqq9c)MvelTzrblTyjaHAqOLYOsdMgeUcLzihSbljjSynlJhiZpqTML2SOGfRzHqV1ffrGMRWHz9UQMYO3YRFLMbjGxGyjjHfc9wxuebAUchM17QAkJElV(vAgKaEbIffS0ILaeQbHwkZv4WSExvtz0B51VsZGeWlqMHs9RWSeplXSzwssyjaHAqOLYOsdMgeUcLzOu)kmlXZsmBML2SOGfRzrD17MGNVkywrSKKWIkeJzrbl9d1(Nhk1VcZcGzb9B2EZd)bl7n8UdcTqGz4OMH98dNuQE73ookdWTJH9gvUQMaTJL9giHdZf9hSS3IX(Hz5WS4Sm(VtdlK2vHJ)elw8gS8qwsDeiwCTMfyXYctSGF)z5NRqGEmlpKfvIf9veilRiwSC)olOj2iXQQalEbYcAGfqicelEbYYctS87elaQazbRHplWILailxNfv4VZYpxHa9yw8HybwSSWel43Fw(5keOhBVfM7P5C7TwSa0NZv1Kbw5fMY)Cfc0ZI1kXIYSOGfRz5NRqGEZdiZqoyJCac1GqlfljjS0IfG(CUQMmWkVWu(NRqGEwuIfLzjjHfG(CUQMmWkVWu(NRqGEwuILyYsBwuWslwux9Uj45RcMvelkyPflwZsacKkVEdqQ(9gdljjSOU6DZ4aPcUW5(qvCBygk1VcZcIyPflOLfeNLzvuhoOid(Q(sN3BGFAo3qLRQjqwAZcGvILFUcb6nVYg1vVNbxJ)hSyrblQRE3moqQGlCUpuf3gMveljjSOU6DZ4aPcUW5(qvCBKXx1x68Ed8tZ5MvelTzjjHLaeQbHwktWZxfmdL6xHzbrSaiwINLFUcb6nVYMaeQbHwkd4A8)GflkyXAwux9Uj45RcMvelkyPflwZsacKkVEtDO2)C3jwssyXAwa6Z5QAYeGfqicugKWnQalTzrblwZsacKkVEdcnMZlwssyjabsLxVPou7FU7elkybOpNRQjtawaHiqzqc3OcSOGLaeQbHwktawaHiq5FNY4OBUhBwrSOGfRzjaHAqOLYe88vbZkIffS0ILwSOU6Ddf0xeMY6v5JzOu)kmlXZIYnZssclQRE3qb9fHPmgQ9XmuQFfML4zr5MzPnlkyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazjjHLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpGalkXcAzjjHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87beyrjwaiS0ML2SKKWI6Q3niCf4qGzkncAHMuQ(mv0G6IlzwrS0MLKew6hQ9ppuQFfMfaZcGAMLKewa6Z5QAYaR8ct5FUcb6zrjwAML2SOGfG(CUQMmxLrfaT3WA4JT3(5keOxz7np8hSS3(5keOxz73ookJySJH9gvUQMaTJL9Mh(dw2B)Cfc0di7TWCpnNBV1IfG(CUQMmWkVWu(NRqGEwSwjwaelkyXAw(5keO38kBgYbBKdqOgeAPyjjHfG(CUQMmWkVWu(NRqGEwuIfaXIcwAXI6Q3nbpFvWSIyrblTyXAwcqGu51Bas1V3yyjjHf1vVBghivWfo3hQIBdZqP(vywqelTybTSG4SmRI6WbfzWx1x68Ed8tZ5gQCvnbYsBwaSsS8ZviqV5bKrD17zW14)blwuWI6Q3nJdKk4cN7dvXTHzfXssclQRE3moqQGlCUpuf3gz8v9LoV3a)0CUzfXsBwssyjaHAqOLYe88vbZqP(vywqelaIL4z5NRqGEZditac1GqlLbCn(FWIffSynlQRE3e88vbZkIffS0IfRzjabsLxVPou7FU7eljjSynla95CvnzcWciebkds4gvGL2SOGfRzjabsLxVbHgZ5flkyPflwZI6Q3nbpFvWSIyjjHfRzjabsLxVbiv)EJHL2SKKWsacKkVEtDO2)C3jwuWcqFoxvtMaSacrGYGeUrfyrblbiudcTuMaSacrGY)oLXr3Cp2SIyrblwZsac1GqlLj45RcMvelkyPflTyrD17gkOVimL1RYhZqP(vywINfLBMLKewux9UHc6lctzmu7JzOu)kmlXZIYnZsBwuWI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYssclTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwuIf0YssclQRE3O6AVcug2ZUwN)9RqHZ(e8Im43diWIsSaqyPnlTzPnljjSOU6DdcxboeyMsJGwOjLQptfnOU4sMveljjSOcXywuWs)qT)5Hs9RWSaywauZSKKWcqFoxvtgyLxyk)ZviqplkXsZS0MffSa0NZv1K5QmQaO9gwdFS92pxHa9aY(TJJYae7yyVrLRQjq7yzVbs4WCr)bl7naaMWS4AnlWFNgwGfllmXY9ukMfyXsa0EZd)bl7TfMY3tPy73ookJyTJH9gvUQMaTJL9giHdZf9hSS3S6u4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOoS9Mh(dw2BZQYE4pyL1h(T3W)CH3ookBVfM7P5C7nG(CUQMmho7qYEtF4pxEkzV5qY(TJdGA2og2Bu5QAc0ow2BH5EAo3EBwf1HdkYO6AVcug2ZUwN)9RqHne6TUOic0Ed)ZfE74OS9Mh(dw2BZQYE4pyL1h(T30h(ZLNs2BQq)TF74aiLTJH9gvUQMaTJL9Mh(dw2BZQYE4pyL1h(T30h(ZLNs2B43(TF7nvO)2XWookBhd7nQCvnbAhl7np8hSS3ghivWfo3hQIBd7nqchMl6pyzVbGnuf3gSy5(DwqtSrIvvb7TWCpnNBVPU6DtWZxfmdL6xHzjEwugT2VDCaKDmS3OYv1eODSS38WFWYEZb9O)aszSfFsT3cncAk)(GIESDCu2Elm3tZ52BQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWcGzbGWIcwux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqGfaZcaHffS0IfRzbe(gh0J(diLXw8jnd6PokY8xaHRqXIcwSMfp8hSmoOh9hqkJT4tAg0tDuK5QCxFO2FwuWslwSMfq4BCqp6pGugBXN08o5AZFbeUcfljjSacFJd6r)bKYyl(KM3jxBgk1VcZs8SetwAZssclGW34GE0FaPm2IpPzqp1rrg87beybWSetwuWci8noOh9hqkJT4tAg0tDuKzOu)kmlaMf0YIcwaHVXb9O)aszSfFsZGEQJIm)fq4kuS02EdKWH5I(dw2BaamXsSb9O)asSSzXNuwSStfl(ZIMWyw(DVyb9zjwWyhdwWVhqaZIxGS8qwgQpeENfNfaReGyb)EabwCmlA)jwCmlrqm(u1elWHL)sjwUNfmKL7zXN5asywqkzHFw8(tdlolXerSGFpGaleYIUHW2VDCIPDmS3OYv1eODSS38WFWYElalGqeO8VtzC0n3JT3ajCyUO)GL9gaatSGgybeIaXIL73zbnXgjwvfyXYovSebX4tvtS4filWFNglhMyXY97S4SelySJblQRENfl7uXciHBuHRqzVfM7P5C7nRzbCwhOPG5aiMffS0ILwSa0NZv1KjalGqeOmiHBubwuWI1SeGqni0szcE(QGzihSbljjSOU6DtWZxfmRiwAZIcwAXI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acSOelaewssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwuIfaclTzjjHfvigZIcw6hQ9ppuQFfMfaZIYnZsB73ooOVDmS3OYv1eODSS38WFWYERVMgzypt6vr2BGeomx0FWYEdadAfS4yw(DIL(n4NfubqwUILFNyXzjwWyhdwSCfi0clWHfl3VZYVtSGuUXCEXI6Q3zboSy5(DwCwaiictbwInOh9hqILnl(KYIxGSyXVNLoCybnXgjwvfy56SCplwG1ZIkXYkIfhLFflQuhoel)oXsaKLdZs)QdVtG2BH5EAo3ERflTyPflQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWs8SaWzjjHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87beyjEwa4S0MffS0IfRzjabsLxVbiv)EJHLKewSMf1vVBghivWfo3hQIBdZkIL2S0MffS0IfWzDGMcMdGywssyjaHAqOLYe88vbZqP(vywINf02mljjS0ILaeivE9M6qT)5UtSOGLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SG2MzPnlTzPnljjS0Ifq4BCqp6pGugBXN0mON6OiZqP(vywINfaclkyjaHAqOLYe88vbZqP(vywINfLBMffSeGaPYR3uuyGA4aYsBwssy5QNMiO2Fcm3pu7FEOu)kmlaMfaclkyXAwcqOgeAPmbpFvWmKd2GLKewcqGu51BqOXCEXIcwux9UbHRahcmtPrql0Ks1BwrSKKWsacKkVEdqQ(9gdlkyrD17MXbsfCHZ9HQ42WmuQFfMfaZcILffSOU6DZ4aPcUW5(qvCBywr2VDCqRDmS3OYv1eODSS38WFWYEl4vG0z1vVBVfM7P5C7TwSOU6DJQR9kqzyp7AD(3Vcfox(VgYmuQFfML4zbXyqlljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYmuQFfML4zbXyqllTzrblTyjaHAqOLYe88vbZqP(vywINfedljjS0ILaeQbHwkdLgbTqtwfwGMHs9RWSepligwuWI1SOU6DdcxboeyMsJGwOjLQptfnOU4sMvelkyjabsLxVbHgZ5flTzPnlkyXX)46Ce0cnSeVsSeZMT3ux9EU8uYEd)(OHdO9giHdZf9hSS3qJxbsZY27JgoGSy5(DwCwkYclXcg7yWI6Q3zXlqwqtSrIvvbwoCHUNfxfUEwEilQellmbA)2XbGBhd7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9MvFLgXY27dEnOimlwUFNfNLybJDmyrD17SOUEwk4ZILDQyjcc1xHILoCybnXgjwvfyboSGu(kWHazzl6M7X2BH5EAo3ERflQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWs8SaiwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwINfaXsBwuWslwcqGu51BQd1(N7oXssclbiudcTuMGNVkygk1VcZs8SGyyjjHfRzbOpNRQjtamhGf49hSyrblwZsacKkVEdcnMZlwssyPflbiudcTugkncAHMSkSandL6xHzjEwqmSOGfRzrD17geUcCiWmLgbTqtkvFMkAqDXLmRiwuWsacKkVEdcnMZlwAZsBwuWslwSMfq4B6RPrg2ZKEvK5VacxHILKewSMLaeQbHwktWZxfmd5GnyjjHfRzjaHAqOLYeGfqicu(3Pmo6M7XMHCWgS02(TJdIXog2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7nR(knILT3h8AqrywuPoCiwqdSacrGS3cZ90CU9wlwcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlaMf0YIcwSMfWzDGMcMdGywuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcE(QGzOu)kmlaMf0YsBwuWcqFoxvtMayoalW7pyXsBwuWI1SacFtFnnYWEM0RIm)fq4kuSOGLaeivE9M6qT)5UtSOGfRzbCwhOPG5aiMffSqb9fHjZvzVAWIcwC8pUohbTqdlXZc63S9BhhaIDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2BTyrD17MXbsfCHZ9HQ42WmuQFfML4zbTSKKWI1SOU6DZ4aPcUW5(qvCBywrS0MffS0If1vVBq4kWHaZuAe0cnPu9zQOb1fxYmuQFfMfaZcQaOj1rglTzrblTyrD17gkOVimLXqTpMHs9RWSeplOcGMuhzSKKWI6Q3nuqFrykRxLpMHs9RWSeplOcGMuhzS02EdKWH5I(dw2BwDyHUNfq4Zc4AUcfl)oXcvGSa7Sy16aPcUWSaGnuf3giNfW1Cfkwq4kWHazHsJGwOjLQNf4WYvS87elAh)SGkaYcSZIxSyfb9fHj7nG(KlpLS3aHFEi0BDdLs1JTF74GyTJH9gvUQMaTJL9Mh(dw2B4v1VHS3cZ90CU92q9HW7UQMyrblVpOO38xkLFyg8iwINfLb4SOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2ookB)2Xr5MTJH9gvUQMaTJL9Mh(dw2BPqy1VHS3cZ90CU92q9HW7UQMyrblVpOO38xkLFyg8iwINfLJPbTSOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2ookB)2XrzLTJH9gvUQMaTJL9Mh(dw2B4N0AFYDTpK9wyUNMZT3gQpeE3v1elky59bf9M)sP8dZGhXs8SOmaNfeXYqP(vywuWIhLd7uabwuWcqFoxvtgq4Nhc9w3qPu9y7TqJGMYVpOOhBhhLTF74OmGSJH9gvUQMaTJL9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7namyCybwSeazXY97W1ZsWJIUcL9wyUNMZT38OCyNciy)2Xr5yAhd7nQCvnbAhl7np8hSS3O0iOfAYQWc0EdKWH5I(dw2BwrAe0cnSelybYILDQyXvHRNLhYcvpnS4SuKfwIfm2XGflxbcTWIxGSGDGelD4WcAInsSQkyVfM7P5C7TwSqb9fHjJEv(KlczpljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczpljjSOU6DJQR9kqzyp7AD(3Vcfox(VgYmuQFfML4zbXyqlljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYmuQFfML4zbXyqlljjS44FCDocAHgwINfeBZSOGLaeQbHwktWZxfmd5GnyrblwZc4SoqtbZbqmlTzrblTyjaHAqOLYe88vbZqP(vywINLy2mljjSeGqni0szcE(QGzihSblTzjjHLREAIGA)jWC)qT)5Hs9RWSaywuUz73ookJ(2XWEJkxvtG2XYEZd)bl7T(AAKH9mPxfzVbs4WCr)bl7namOvWYCO2FwuPoCiww4RqXcAIT9wyUNMZT3cqOgeAPmbpFvWmKd2GffSa0NZv1KjaMdWc8(dwSOGLwS44FCDocAHgwINfeBZSOGfRzjabsLxVPou7FU7eljjSeGaPYR3uhQ9p3DIffS44FCDocAHgwamlOFZS0MffSynlbiqQ86naP63BmSOGLwSynlbiqQ86n1HA)ZDNyjjHLaeQbHwktawaHiq5FNY4OBUhBgYbBWsBwuWI1SaoRd0uWCaeB)2Xrz0Ahd7nQCvnbAhl7nyK9gME7np8hSS3a6Z5QAYEdORxK9M1SaoRd0uWCaeZIcwa6Z5QAYeaZbybE)blwuWslwAXIJ)X15iOfAyjEwqSnZIcwAXI6Q3niCf4qGzkncAHMuQ(mv0G6IlzwrSKKWI1SeGaPYR3GqJ58IL2SKKWI6Q3nQAieuVWVzfXIcwux9UrvdHG6f(ndL6xHzbWSOU6DtWZxfmGRX)dwS0MLKewU6PjcQ9NaZ9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyjjHLaeivE9M6qT)5UtS0MffS0IfRzjabsLxVPou7FU7eljjS0Ifh)JRZrql0WcGzb9BMLKewaHVPVMgzypt6vrM)ciCfkwAZIcwAXcqFoxvtMaSacrGYGeUrfyjjHLaeQbHwktawaHiq5FNY4OBUhBgYbBWsBwABVbs4WCr)bl7n0eBKyvvGfl7uXI)SGyBgrSeBmaLLwWrdTqdl)UxSG(nZsSXauwSC)olObwaHiqTzXY97W1ZIgIVcfl)LsSCflXsdHG6f(zXlqw0xrSSIyXY97SGgybeIaXY1z5EwS4ywajCJkqG2Ba9jxEkzVfaZbybE)bRSk0F73ookdWTJH9gvUQMaTJL9wyUNMZT3a6Z5QAYeaZbybE)bRSk0F7np8hSS3cKMW)56SRpuvkvV9BhhLrm2XWEJkxvtG2XYElm3tZ52Ba95CvnzcG5aSaV)Gvwf6V9Mh(dw2Bxf8P8)GL9BhhLbi2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVrb9fHjZvz9Q8HfeNfacliHfp8hSm43N(nKHqgfwpL)lLybrSynluqFryYCvwVkFybXzPflaCwqelVRP6ny4sNH98Vt5oCi8BOYv1eiliolXKL2SGew8WFWYyz8F3qiJcRNY)LsSGiwA2aiwqcl4isRZ7o(j7nqchMl6pyzVzf4)s9NWSSdTWs6kSZsSXauw8HybLFfbYsenSGPaSaT3a6tU8uYEZXrauA2OG9BhhLrS2XWEJkxvtG2XYEZd)bl7n87dEnOi7nqchMl6pyzVz1xPrSS9(GxdkcZILDQy53jw6hQ9NLdZIRcxplpKfQarol9HQ42GLdZIRcxplpKfQarolnGlw8HyXFwqSnJiwIngGYYvS4flwrqFryc5SGMyJeRQcSOD8JzXl4VtdlaeeHPaMf4Wsd4IflWLgKfiqAcEelPWHy539Ifor5Mzj2yaklw2PILgWflwGlnyHUNLT3h8AqrSuql2BH5EAo3ERflx90eb1(tG5(HA)ZdL6xHzbWSG(SKKWslwux9UzCGubx4CFOkUnmdL6xHzbWSGkaAsDKXcIZsGonlTyXX)46Ce0cnSGewIzZS0MffSOU6DZ4aPcUW5(qvCBywrS0ML2SKKWslwC8pUohbTqdliIfG(CUQMmoocGsZgfybXzrD17gkOVimLXqTpMHs9RWSGiwaHVPVMgzypt6vrM)ciGZdL6xXcIZcGmOLL4zrzLBMLKewC8pUohbTqdliIfG(CUQMmoocGsZgfybXzrD17gkOVimL1RYhZqP(vywqelGW30xtJmSNj9QiZFbeW5Hs9RybXzbqg0Ys8SOSYnZsBwuWcf0xeMmxL9QblkyPflwZI6Q3nbpFvWSIyjjHfRz5DnvVb)(OHdOHkxvtGS0MffS0ILwSynlbiudcTuMGNVkywrSKKWsacKkVEdcnMZlwuWI1SeGqni0szO0iOfAYQWc0SIyPnljjSeGaPYR3uhQ9p3DIL2SOGLwSynlbiqQ86naP63BmSKKWI1SOU6DtWZxfmRiwssyXX)46Ce0cnSepli2MzPnljjS0IL31u9g87JgoGgQCvnbYIcwux9Uj45RcMvelkyPflQRE3GFF0Wb0GFpGalaMLyYssclo(hxNJGwOHL4zbX2mlTzPnljjSOU6DtWZxfmRiwuWI1SOU6DZ4aPcUW5(qvCBywrSOGfRz5DnvVb)(OHdOHkxvtG2VDCauZ2XWEJkxvtG2XYEZd)bl7TISKtHWYEdKWH5I(dw2BaamXcaoiSWSCflw5Q8HfRiOVimXIxGSGDGeliLY1DebGT0AwaWbHflD4WcAInsSQkyVfM7P5C7TwSOU6Ddf0xeMY6v5JzOu)kmlXZcHmkSEk)xkXssclTyjS7dkcZIsSaiwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjMS0MffS4r5WofqW(TJdGu2og2Bu5QAc0ow2BH5EAo3ERflQRE3qb9fHPSEv(ygk1VcZs8SqiJcRNY)LsSOGLwSeGqni0szcE(QGzOu)kmlXZcABMLKewcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlXZcABML2SKKWslwc7(GIWSOelaIffSmuy3huu(VuIfaZcAzPnljjSe29bfHzrjwIjlTzrblEuoStbeS38WFWYEB319Ckew2VDCaeGSJH9gvUQMaTJL9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYOW6P8FPelkyPflbiudcTuMGNVkygk1VcZs8SG2MzjjHLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SG2MzPnljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyYsBwuWIhLd7uab7np8hSS36lToNcHL9Bhhaft7yyVrLRQjq7yzVbs4WCr)bl7nKcOvWcSyjaAV5H)GL9MfFMdozypt6vr2VDCae6Bhd7nQCvnbAhl7np8hSS3WVp9Bi7nqchMl6pyzVbaWelBVp9BiwEilrdmWYgu7dlwrqFryIf4WILDQy5kwGLUblw5Q8HfRiOVimXIxGSSWelifqRGLObgWSCDwUIfRCv(WIve0xeMS3cZ90CU9gf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwssyrD17gl(mhCYWEM0RImRiwuWI6Q3nuqFrykRxLpMveljjS0If1vVBcE(QGzOu)kmlaMfp8hSmwg)3neYOW6P8FPelkyrD17MGNVkywrS02(TJdGqRDmS38WFWYEZY4)U9gvUQMaTJL9BhhabWTJH9gvUQMaTJL9Mh(dw2BZQYE4pyL1h(T30h(ZLNs2BDxR)9zz)2V9Mdj7yyhhLTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYERflQRE38xkzbovgCipv9kqAmdL6xHzbWSGkaAsDKXcIyPzJYSKKWI6Q3n)LswGtLbhYtvVcKgZqP(vywamlE4pyzWVp9BidHmkSEk)xkXcIyPzJYSOGLwSqb9fHjZvz9Q8HLKewOG(IWKbd1(KlczpljjSqb9fHjJxnYfHSNL2S0MffSOU6DZFPKf4uzWH8u1RaPXSIyrblZQOoCqrM)sjlWPYGd5PQxbsJHkxvtG2BGeomx0FWYEdnUoS0(tywSSt)onS87elw9H80G)HDAyrD17Sy50Aw6UwZcS3zXY97xXYVtSueYEwco(T3a6tU8uYEdCipnB506C316mS3TF74ai7yyVrLRQjq7yzVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3SMfkOVimzUkJHAFyrblTybhrAD(9bf9yd(9PFdXs8SGwwuWY7AQEdgU0zyp)7uUdhc)gQCvnbYsscl4isRZVpOOhBWVp9BiwINfedlTT3ajCyUO)GL9gACDyP9NWSyzN(DAyz79bVguelhMflW53zj44)kuSabsdlBVp9BiwUIfRCv(WIve0xeMS3a6tU8uYE7qvWHY43h8Aqr2VDCIPDmS3OYv1eODSS38WFWYElalGqeO8VtzC0n3JT3ajCyUO)GL9gaatSGgybeIaXILDQyXFw0egZYV7flOTzwIngGYIxGSOVIyzfXIL73zbnXgjwvfS3cZ90CU9M1SaoRd0uWCaeZIcwAXslwa6Z5QAYeGfqicugKWnQalkyXAwcqOgeAPmbpFvWmKd2GLKewux9Uj45RcMvelTzrblTyrD17gkOVimL1RYhZqP(vywINfaoljjSOU6Ddf0xeMYyO2hZqP(vywINfaolTzrblTyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazjjHf1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87beyjEwIjljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGalXZsmzPnljjSOcXywuWs)qT)5Hs9RWSaywuUzwuWI1SeGqni0szcE(QGzihSblTTF74G(2XWEJkxvtG2XYEZd)bl7TXbsfCHZ9HQ42WEdKWH5I(dw2BaamXca2qvCBWIL73zbnXgjwvfS3cZ90CU9M6Q3nbpFvWmuQFfML4zrz0A)2XbT2XWEJkxvtG2XYEZd)bl7n8Q63q2BHgbnLFFqrp2ookBVfM7P5C7TwSmuFi8URQjwssyrD17gkOVimLXqTpMHs9RWSaywIjlkyHc6lctMRYyO2hwuWYqP(vywamlkJ(SOGL31u9gmCPZWE(3PChoe(nu5QAcKL2SOGL3hu0B(lLYpmdEelXZIYOplaqwWrKwNFFqrpMfeXYqP(vywuWslwOG(IWK5QSxnyjjHLHs9RWSaywqfanPoYyPT9giHdZf9hSS3aayILTv1VHy5kwI8cKsValWIfVA87xHILF3Fw0hqcZIYOpMcyw8cKfnHXSy5(DwsHdXY7dk6XS4fil(ZYVtSqfilWololBqTpSyfb9fHjw8NfLrFwWuaZcCyrtymldL6xDfkwCmlpKLc(SS7aVcflpKLH6dH3zbCnxHIfRCv(WIve0xeMSF74aWTJH9gvUQMaTJL9Mh(dw2B4v1VHS3ajCyUO)GL9gaatSSTQ(nelpKLDhiXIZcknu11S8qwwyIfRYQzRU9wyUNMZT3a6Z5QAYCOhyoalW7pyXIcwcqOgeAPmxHdZ6DvnLrVLx)kndsaVazgYbBWIcwi0BDrreO5kCywVRQPm6T86xPzqc4fi73ooig7yyVrLRQjq7yzVfM7P5C7nRz5DnvVb)Kw7tgCU(BOYv1eilkyPflQRE3GFF6UwBgQpeE3v1elkyPfl4isRZVpOOhBWVpDxRzbWSetwssyXAwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazPnljjS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSOGf1vVBOG(IWugd1(ygk1VcZcGzjMSOGfkOVimzUkJHAFyrblQRE3GFF6UwBgk1VcZcGzbXWIcwWrKwNFFqrp2GFF6UwZs8kXc6ZsBwuWslwSMLzvuhoOiJUrWhhN7AI(RqLrPV0imzOYv1eiljjS8xkXcsLf0hTSeplQRE3GFF6UwBgk1VcZcIybqS0MffS8(GIEZFPu(HzWJyjEwqR9Mh(dw2B43NUR12VDCai2XWEJkxvtG2XYEZd)bl7n87t31A7nqchMl6pyzVHuC)olBpP1(WIvFU(ZYctSalwcGSyzNkwgQpeE3v1elQRNf8FAnlw87zPdhwSYgbFCmlrdmWIxGSacl09SSWelQuhoelOXQJnSS9NwZYctSOsD4qSGgybeIaXc(QaXYV7plwoTMLObgyXl4VtdlBVpDxRT3cZ90CU927AQEd(jT2Nm4C93qLRQjqwuWI6Q3n43NUR1MH6dH3DvnXIcwAXI1SmRI6Wbfz0nc(44Cxt0FfQmk9LgHjdvUQMazjjHL)sjwqQSG(OLL4zb9zPnlky59bf9M)sP8dZGhXs8Set73ooiw7yyVrLRQjq7yzV5H)GL9g(9P7AT9giHdZf9hSS3qkUFNfR(qEQ6vG0WYctSS9(0DTMLhYccefXYkILFNyrD17SO2GfxJHSSWxHILT3NUR1SalwqllykalqmlWHfnHXSmuQF1vOS3cZ90CU92SkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkybhrAD(9bf9yd(9P7AnlXRelXKffS0IfRzrD17M)sjlWPYGd5PQxbsJzfXIcwux9Ub)(0DT2muFi8URQjwssyPfla95CvnzahYtZwoTo3DTod7DwuWslwux9Ub)(0DT2muQFfMfaZsmzjjHfCeP153hu0Jn43NUR1SeplaIffS8UMQ3GFsR9jdox)nu5QAcKffSOU6Dd(9P7ATzOu)kmlaMf0YsBwAZsB73ook3SDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2Bo(hxNJGwOHL4zbG0mlaqwAXIYnZcIZI6Q3n)LswGtLbhYtvVcKgd(9acS0MfailTyrD17g87t31AZqP(vywqCwIjliHfCeP15Dh)eliolwZY7AQEd(jT2Nm4C93qLRQjqwAZcaKLwSeGqni0szWVpDxRndL6xHzbXzjMSGewWrKwN3D8tSG4S8UMQ3GFsR9jdox)nu5QAcKL2SaazPflGW30xtJmSNj9QiZqP(vywqCwqllTzrblTyrD17g87t31AZkILKewcqOgeAPm43NUR1MHs9RWS02EdKWH5I(dw2BOX1HL2FcZILD63PHfNLT3h8AqrSSWelwoTMLGVWelBVpDxRz5HS0DTMfyVJCw8cKLfMyz79bVguelpKfeikIfR(qEQ6vG0Wc(9acSSIS3a6tU8uYEd)(0DToBbwFU7ADg272VDCuwz7yyVrLRQjq7yzV5H)GL9g(9bVguK9giHdZf9hSS3aayILT3h8AqrSy5(DwS6d5PQxbsdlpKfeikILvel)oXI6Q3zXY97W1ZIgIVcflBVpDxRzzf9xkXIxGSSWelBVp41GIybwSG(iILybJDmyb)EabmlR6pnlOplVpOOhBVfM7P5C7nG(CUQMmGd5PzlNwN7UwNH9olkybOpNRQjd(9P7AD2cS(C316mS3zrblwZcqFoxvtMdvbhkJFFWRbfXssclTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwINLyYssclQRE3O6AVcug2ZUwN)9RqHZ(e8Im43diWs8SetwAZIcwWrKwNFFqrp2GFF6UwZcGzb9zrbla95CvnzWVpDxRZwG1N7UwNH9U9BhhLbKDmS3OYv1eODSS38WFWYEZb9O)aszSfFsT3cncAk)(GIESDCu2Elm3tZ52BwZYFbeUcflkyXAw8WFWY4GE0FaPm2IpPzqp1rrMRYD9HA)zjjHfq4BCqp6pGugBXN0mON6Oid(9acSaywIjlkybe(gh0J(diLXw8jnd6PokYmuQFfMfaZsmT3ajCyUO)GL9gaatSGT4tklyil)U)S0aUybf9SK6iJLv0FPelQnyzHVcfl3ZIJzr7pXIJzjcIXNQMybwSOjmMLF3lwIjl43diGzboSGuYc)SyzNkwIjIyb)EabmleYIUHSF74OCmTJH9gvUQMaTJL9Mh(dw2BPqy1VHS3cncAk)(GIESDCu2Elm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwAXslwug9zbrS0IfCeP153hu0Jn43N(neliolaIfeNf1vVBOG(IWuwVkFmRiwAZsBwqeldL6xHzPnliHLwSOmliIL31u9M3Yv5uiSWgQCvnbYsBwuWslwcqOgeAPmbpFvWmKd2GffSynlGZ6anfmhaXSOGLwSa0NZv1KjalGqeOmiHBubwssyjaHAqOLYeGfqicu(3Pmo6M7XMHCWgSKKWI1SeGaPYR3uhQ9p3DIL2SKKWcoI0687dk6Xg87t)gIfaZslwAXcaNfailTyrD17gkOVimL1RYhZkIfeNfaXsBwAZcIZslwuMfeXY7AQEZB5QCkewydvUQMazPnlTzrblwZcf0xeMmyO2NCri7zjjHLwSqb9fHjZvzmu7dljjS0IfkOVimzUkRc)DwssyHc6lctMRY6v5dlTzrblwZY7AQEdgU0zyp)7uUdhc)gQCvnbYssclQRE3enxkCapxN9j41fYrln2hdqxViwIxjwaeABML2SOGLwSGJiTo)(GIESb)(0VHybWSOCZSG4S0IfLzbrS8UMQ38wUkNcHf2qLRQjqwAZsBwuWIJ)X15iOfAyjEwqBZSaazrD17g87t31AZqP(vywqCwa4S0MffS0IfRzrD17geUcCiWmLgbTqtkvFMkAqDXLmRiwssyHc6lctMRYyO2hwssyXAwcqGu51BqOXCEXsBwuWI1SOU6DZ4aPcUW5(qvCBKXx1x68Ed8tZ5MvK9giHdZf9hSS3SAP(q4DwaWbHv)gILRZcAInsSQkWYHzzihSbYz53PHyXhIfnHXS87EXcAz59bf9ywUIfRCv(WIve0xeMyXY97SSbFamKZIMWyw(DVyr5Mzb(70y5WelxXIxnyXkc6lctSahwwrS8qwqllVpOOhZIk1HdXIZIvUkFyXkc6lctgwS6WcDpld1hcVZc4AUcfliLVcCiqwSI0iOfAsP6zzvAcJz5kw2GAFyXkc6lct2VDCug9TJH9gvUQMaTJL9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7naaMybadghwGflbqwSC)oC9Se8OORqzVfM7P5C7npkh2Pac2VDCugT2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVznlGZ6anfmhaXSOGfG(CUQMmbWCawG3FWIffS0ILwSOU6Dd(9P7ATzfXssclVRP6n4N0AFYGZ1FdvUQMazjjHLaeivE9M6qT)5UtS0MffS0IfRzrD17gmuJ)lqMvelkyXAwux9Uj45RcMvelkyPflwZY7AQEtFnnYWEM0RImu5QAcKLKewux9Uj45RcgW14)blwINLaeQbHwktFnnYWEM0RImdL6xHzbrSaqyPnlkybOpNRQjZVpNwNXeHanzl(9SOGLwSynlbiqQ86n1HA)ZDNyjjHLaeQbHwktawaHiq5FNY4OBUhBwrSOGLwSOU6Dd(9P7ATzOu)kmlaMfaXssclwZY7AQEd(jT2Nm4C93qLRQjqwAZsBwuWY7dk6n)Ls5hMbpIL4zrD17MGNVkyaxJ)hSybXzPzdIHL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyPT9gqFYLNs2BbWCawG3FWk7qY(TJJYaC7yyVrLRQjq7yzV5H)GL9wG0e(pxND9HQsP6T3ajCyUO)GL9gaatSGMyJeRQcSalwcGSSknHXS4fil6RiwUNLvelwUFNf0alGqei7TWCpnNBVb0NZv1KjaMdWc8(dwzhs2VDCugXyhd7nQCvnbAhl7TWCpnNBVb0NZv1KjaMdWc8(dwzhs2BE4pyzVDvWNY)dw2VDCugGyhd7nQCvnbAhl7np8hSS3O0iOfAYQWc0EdKWH5I(dw2BaamXIvKgbTqdlXcwGSalwcGSy5(Dw2EF6UwZYkIfVazb7ajw6WHfa6sJ9HfVazbnXgjwvfS3cZ90CU92vpnrqT)eyUFO2)8qP(vywamlkJwwssyPflQRE3enxkCapxN9j41fYrln2hdqxViwamlacTnZssclQRE3enxkCapxN9j41fYrln2hdqxViwIxjwaeABML2SOGf1vVBWVpDxRnRiwuWslwcqOgeAPmbpFvWmuQFfML4zbTnZssclGZ6anfmhaXS02(TJJYiw7yyVrLRQjq7yzV5H)GL9g(jT2NCx7dzVfAe0u(9bf9y74OS9wyUNMZT3gQpeE3v1elky5Vuk)Wm4rSeplkJwwuWcoI0687dk6Xg87t)gIfaZc6ZIcw8OCyNciWIcwAXI6Q3nbpFvWmuQFfML4zr5MzjjHfRzrD17MGNVkywrS02EdKWH5I(dw2BwTuFi8olDTpelWILvelpKLyYY7dk6XSy5(D46zbnXgjwvfyrLUcflUkC9S8qwiKfDdXIxGSuWNfiqAcEu0vOSF74aOMTJH9gvUQMaTJL9Mh(dw2B910id7zsVkYEdKWH5I(dw2BaamXcag0ky56SCf(ajw8IfRiOVimXIxGSOVIy5EwwrSy5(DwCwaOln2hwIgyGfVazj2GE0Fajw2S4tQ9wyUNMZT3OG(IWK5QSxnyrblEuoStbeyrblQRE3enxkCapxN9j41fYrln2hdqxViwamlacTnZIcwAXci8noOh9hqkJT4tAg0tDuK5VacxHILKewSMLaeivE9MIcdudhqwssybhrAD(9bf9ywINfaXsBwuWslwux9UzCGubx4CFOkUnmdL6xHzbWSGyzbaYslwqlliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0MffSOU6DZ4aPcUW5(qvCBywrSKKWI1SOU6DZ4aPcUW5(qvCBywrS0MffS0IfRzjaHAqOLYe88vbZkILKewux9U53NtRZyIqGgd(9acSaywugTSOGL(HA)ZdL6xHzbWSaOMBMffS0pu7FEOu)kmlXZIYn3mljjSynly4sREfO53NtRZyIqGgdvUQMazPnlkyPfly4sREfO53NtRZyIqGgdvUQMazjjHLaeQbHwktWZxfmdL6xHzjEwIzZS02(TJdGu2og2Bu5QAc0ow2BE4pyzVHFF6UwBVbs4WCr)bl7naaMyXzz79P7Anla4l63zjAGbwwLMWyw2EF6UwZYHzX1d5GnyzfXcCyPbCXIpelUkC9S8qwGaPj4rSeBma1Elm3tZ52BQRE3al63X5iAcu0FWYSIyrblTyrD17g87t31AZq9HW7UQMyjjHfh)JRZrql0Ws8SGyBML22VDCaeGSJH9gvUQMaTJL9Mh(dw2B43NUR12BGeomx0FWYEZQVsJyj2yaklQuhoelObwaHiqSy5(Dw2EF6UwZIxGS87uXY27dEnOi7TWCpnNBVfGaPYR3uhQ9p3DIffSynlVRP6n4N0AFYGZ1FdvUQMazrblTybOpNRQjtawaHiqzqc3OcSKKWsac1GqlLj45RcMveljjSOU6DtWZxfmRiwAZIcwcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlaMfubqtQJmwqCwc0PzPflo(hxNJGwOHfKWcABML2SOGf1vVBWVpDxRndL6xHzbWSG(SOGfRzbCwhOPG5ai2(TJdGIPDmS3OYv1eODSS3cZ90CU9wacKkVEtDO2)C3jwuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcE(QGzfXssclQRE3e88vbZkIL2SOGLaeQbHwktawaHiq5FNY4OBUhBgk1VcZcGzbGZIcwux9Ub)(0DT2SIyrbluqFryYCv2RgSOGfRzbOpNRQjZHQGdLXVp41GIyrblwZc4SoqtbZbqS9Mh(dw2B43h8Aqr2VDCae6Bhd7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9gaatSS9(GxdkIfl3VZIxSaGVOFNLObgyboSCDwAaxOdKfiqAcEelXgdqzXY97S0aUgwkczplbh)gwITgdzbCLgXsSXauw8NLFNyHkqwGDw(DIfRgu97ngwux9olxNLT3NUR1SybU0Gf6Ew6UwZcS3zboS0aUyXhIfyXcGy59bf9y7TWCpnNBVPU6DdSOFhNdAYNmWdFWYSIyjjHLwSynl43N(nKXJYHDkGalkyXAwa6Z5QAYCOk4qz87dEnOiwssyPflQRE3e88vbZqP(vywamlOLffSOU6DtWZxfmRiwssyPflTyrD17MGNVkygk1VcZcGzbva0K6iJfeNLaDAwAXIJ)X15iOfAybjSeZMzPnlkyrD17MGNVkywrSKKWI6Q3nJdKk4cN7dvXTrgFvFPZ7nWpnNBgk1VcZcGzbva0K6iJfeNLaDAwAXIJ)X15iOfAybjSeZMzPnlkyrD17MXbsfCHZ9HQ42iJVQV059g4NMZnRiwAZIcwcqGu51Bas1V3yyPnlTzrblTybhrAD(9bf9yd(9P7AnlaMLyYsscla95CvnzWVpDxRZwG1N7UwNH9olTzPnlkyXAwa6Z5QAYCOk4qz87dEnOiwuWslwSMLzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwssybhrAD(9bf9yd(9P7AnlaMLyYsB73ooacT2XWEJkxvtG2XYEZd)bl7TISKtHWYEdKWH5I(dw2BaamXcaoiSWSCflBqTpSyfb9fHjw8cKfSdKybaBP1SaGdclw6WHf0eBKyvvWElm3tZ52BTyrD17gkOVimLXqTpMHs9RWSepleYOW6P8FPeljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyYsBwuWIhLd7uab73ooacGBhd7nQCvnbAhl7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiJcRNY)LsSKKWslwc7(GIWSOelaIffSmuy3huu(VuIfaZcAzPnljjSe29bfHzrjwIjlTzrblEuoStbeyrblTyrD17MXbsfCHZ9HQ42WmuQFfMfaZcAzrblQRE3moqQGlCUpuf3gMvelkyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazjjHfRzrD17MXbsfCHZ9HQ42WSIyPT9Mh(dw2B7UUNtHWY(TJdGqm2XWEJkxvtG2XYElm3tZ52BTyrD17gkOVimLXqTpMHs9RWSepleYOW6P8FPelkyPflbiudcTuMGNVkygk1VcZs8SG2MzjjHLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SG2MzPnljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyYsBwuWIhLd7uabwuWslwux9UzCGubx4CFOkUnmdL6xHzbWSGwwuWI6Q3nJdKk4cN7dvXTHzfXIcwSMLzvuhoOid(Q(sN3BGFAo3qLRQjqwssyXAwux9UzCGubx4CFOkUnmRiwABV5H)GL9wFP15uiSSF74aiaIDmS3OYv1eODSS3ajCyUO)GL9gaatSGuaTcwGflOXQBV5H)GL9MfFMdozypt6vr2VDCaeI1og2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nCeP153hu0Jn43N(nelXZc6ZcIyPRHWHLwSK64NMgzGUErSG4SOCZnZcsybqnZsBwqelDneoS0If1vVBWVp41GIYuAe0cnPu9zmu7Jb)EabwqclOplTT3ajCyUO)GL9gACDyP9NWSyzN(DAy5HSSWelBVp9BiwUILnO2hwSSFHDwoml(ZcAz59bf9yePmlD4WcbKMgSaOMrQSK64NMgSahwqFw2EFWRbfXIvKgbTqtkvpl43diGT3a6tU8uYEd)(0VHYxLXqTp2VDCIzZ2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVPmliHfCeP15Dh)elaMfaXcaKLwS0SbqSG4S0IfCeP153hu0Jn43N(nelaqwuML2SG4S0IfLzbrS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSG4SOSbTS0ML2SGiwA2OmAzbXzrD17MXbsfCHZ9HQ42WmuQFf2EdKWH5I(dw2BOX1HL2FcZILD63PHLhYcsX4)olGR5kuSaGnuf3g2Ba9jxEkzVzz8FpFvUpuf3g2VDCIPY2XWEJkxvtG2XYEZd)bl7nlJ)72BGeomx0FWYEdaGjwqkg)3z5kw2GAFyXkc6lctSahwUolfKLT3N(nelwoTML(9SC1dzbnXgjwvfyXRgPWHS3cZ90CU9wlwOG(IWKrVkFYfHSNLKewOG(IWKXRg5Iq2ZIcwa6Z5QAYC4CqtoqIL2SOGLwS8(GIEZFPu(HzWJyjEwqFwssyHc6lctg9Q8jFvgqSKKWs)qT)5Hs9RWSaywuUzwAZssclQRE3qb9fHPmgQ9XmuQFfMfaZIh(dwg87t)gYqiJcRNY)LsSOGf1vVBOG(IWugd1(ywrSKKWcf0xeMmxLXqTpSOGfRzbOpNRQjd(9PFdLVkJHAFyjjHf1vVBcE(QGzOu)kmlaMfp8hSm43N(nKHqgfwpL)lLyrblwZcqFoxvtMdNdAYbsSOGf1vVBcE(QGzOu)kmlaMfczuy9u(VuIffSOU6DtWZxfmRiwssyrD17MXbsfCHZ9HQ42WSIyrbla95CvnzSm(VNVk3hQIBdwssyXAwa6Z5QAYC4CqtoqIffSOU6DtWZxfmdL6xHzjEwiKrH1t5)sj73ooXeq2XWEJkxvtG2XYEdKWH5I(dw2BaamXY27t)gILRZYvSyLRYhwSIG(IWeYz5kw2GAFyXkc6lctSalwqFeXY7dk6XSahwEilrdmWYgu7dlwrqFryYEZd)bl7n87t)gY(TJtmJPDmS3OYv1eODSS3ajCyUO)GL9gaMR1)(SS38WFWYEBwv2d)bRS(WV9M(WFU8uYER7A9Vpl73(T36Uw)7ZYog2Xrz7yyVrLRQjq7yzV5H)GL9g(9bVguK9giHdZf9hSS32EFWRbfXshoSKcbsPu9SSknHXSSWxHILybJDmS3cZ90CU9M1SmRI6WbfzuDTxbkd7zxRZ)(vOWgc9wxuebA)2Xbq2XWEJkxvtG2XYEZd)bl7n8Q63q2BHgbnLFFqrp2ookBVfM7P5C7nq4BsHWQFdzgk1VcZs8SmuQFfMfeNfabiwqclkdqS3ajCyUO)GL9gAC8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDKXc4A8)GflhML97nSSTQ(neldL6xHzjDP)lsFeilpKLu)d7SKcHv)gIfW14)bl73ooX0og2BE4pyzVLcHv)gYEJkxvtG2XY(TF7n8Bhd74OSDmS3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BaamXY27dEnOiwEiliquelRiw(DIfR(qEQ6vG0WI6Q3z56SCplwGlnileYIUHyrL6WHyPF1H3Vcfl)oXsri7zj44Nf4WYdzbCLgXIk1HdXcAGfqicK9wyUNMZT3MvrD4GIm)LswGtLbhYtvVcKgdvUQMazrblTyHc6lctMRYE1GffSynlTyPflQRE38xkzbovgCipv9kqAmdL6xHzjEw8WFWYyz8F3qiJcRNY)LsSGiwA2OmlkyPfluqFryYCvwf(7SKKWcf0xeMmxLXqTpSKKWcf0xeMm6v5tUiK9S0MLKewux9U5VuYcCQm4qEQ6vG0ygk1VcZs8S4H)GLb)(0VHmeYOW6P8FPeliILMnkZIcwAXcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwAZsBwssyXAwux9U5VuYcCQm4qEQ6vG0ywrS0MLKewAXI6Q3nbpFvWSIyjjHfG(CUQMmbybeIaLbjCJkWsBwuWsac1GqlLjalGqeO8VtzC0n3Jnd5GnyrblbiqQ86n1HA)ZDNyPnlkyPflwZsacKkVEdcnMZlwssyjaHAqOLYqPrql0KvHfOzOu)kmlXZcaHL2SOGLwSOU6DtWZxfmRiwssyXAwcqOgeAPmbpFvWmKd2GL22VDCaKDmS3OYv1eODSS38WFWYEZb9O)aszSfFsT3cncAk)(GIESDCu2Elm3tZ52BwZci8noOh9hqkJT4tAg0tDuK5VacxHIffSynlE4pyzCqp6pGugBXN0mON6OiZv5U(qT)SOGLwSynlGW34GE0FaPm2IpP5DY1M)ciCfkwssybe(gh0J(diLXw8jnVtU2muQFfML4zbTS0MLKewaHVXb9O)aszSfFsZGEQJIm43diWcGzjMSOGfq4BCqp6pGugBXN0mON6OiZqP(vywamlXKffSacFJd6r)bKYyl(KMb9uhfz(lGWvOS3ajCyUO)GL9gaatSeBqp6pGelBw8jLfl7uXYVtdXYHzPGS4H)asSGT4tkYzXXSO9NyXXSebX4tvtSalwWw8jLfl3VZcGyboS0jl0Wc(9acywGdlWIfNLyIiwWw8jLfmKLF3Fw(DILISWc2IpPS4ZCajmliLSWplE)PHLF3FwWw8jLfczr3qy73ooX0og2Bu5QAc0ow2BE4pyzVfGfqicu(3Pmo6M7X2BGeomx0FWYEdaGjmlObwaHiqSCDwqtSrIvvbwomlRiwGdlnGlw8HybKWnQWvOybnXgjwvfyXY97SGgybeIaXIxGS0aUyXhIfvsdTWc63mlXgdqT3cZ90CU9M1SaoRd0uWCaeZIcwAXslwa6Z5QAYeGfqicugKWnQalkyXAwcqOgeAPmbpFvWmKd2GffSynlZQOoCqrMO5sHd456SpbVUqoAPX(yOYv1eiljjSOU6DtWZxfmRiwAZIcwC8pUohbTqdlawjwq)MzrblTyrD17gkOVimL1RYhZqP(vywINfLBMLKewux9UHc6lctzmu7JzOu)kmlXZIYnZsBwssyrfIXSOGL(HA)ZdL6xHzbWSOCZSOGfRzjaHAqOLYe88vbZqoydwAB)2Xb9TJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYERflQRE3moqQGlCUpuf3gMHs9RWSeplOLLKewSMf1vVBghivWfo3hQIBdZkIL2SOGfRzrD17MXbsfCHZ9HQ42iJVQV059g4NMZnRiwuWslwux9UbHRahcmtPrql0Ks1NPIguxCjZqP(vywamlOcGMuhzS0MffS0If1vVBOG(IWugd1(ygk1VcZs8SGkaAsDKXssclQRE3qb9fHPSEv(ygk1VcZs8SGkaAsDKXssclTyXAwux9UHc6lctz9Q8XSIyjjHfRzrD17gkOVimLXqTpMvelTzrblwZY7AQEdgQX)fidvUQMazPT9giHdZf9hSS3qdSaV)GflD4WIR1SacFml)U)SK6iqywWRHy53PgS4dvO7zzO(q4DcKfl7uXIvRdKk4cZca2qvCBWYUJzrtyml)UxSGwwWuaZYqP(vxHIf4WYVtSGqJ58If1vVZYHzXvHRNLhYs31AwG9olWHfVAWIve0xeMy5WS4QW1ZYdzHqw0nK9gqFYLNs2BGWppe6TUHsP6X2VDCqRDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2BTyXAwux9UHc6lctzmu7JzfXIcwSMf1vVBOG(IWuwVkFmRiwAZssclVRP6nyOg)xGmu5QAc0EdKWH5I(dw2BObwG3FWILF3Fwc7uabmlxNLgWfl(qSaxp(ajwOG(IWelpKfyPBWci8z53PHyboSCOk4qS87hMfl3VZYguJ)lq2Ba9jxEkzVbc)mC94dKYuqFryY(TJda3og2Bu5QAc0ow2BE4pyzVLcHv)gYElm3tZ52Bd1hcV7QAIffS0If1vVBOG(IWugd1(ygk1VcZs8SmuQFfMLKewux9UHc6lctz9Q8XmuQFfML4zzOu)kmljjSa0NZv1Kbe(z46XhiLPG(IWelTzrbld1hcV7QAIffS8(GIEZFPu(HzWJyjEwugqSOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2ookB)2XbXyhd7nQCvnbAhl7np8hSS3WRQFdzVfM7P5C7TH6dH3DvnXIcwAXI6Q3nuqFrykJHAFmdL6xHzjEwgk1VcZssclQRE3qb9fHPSEv(ygk1VcZs8SmuQFfMLKewa6Z5QAYac)mC94dKYuqFryIL2SOGLH6dH3DvnXIcwEFqrV5Vuk)Wm4rSeplkdiwuWIhLd7uabwuWcqFoxvtgq4Nhc9w3qPu9y7TqJGMYVpOOhBhhLTF74aqSJH9gvUQMaTJL9Mh(dw2B4N0AFYDTpK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmljjSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywssybOpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmaNffS4r5WofqGffSa0NZv1Kbe(5HqV1nukvp2El0iOP87dk6X2Xrz73ooiw7yyVrLRQjq7yzV5H)GL9whobkd75Y)1q2BGeomx0FWYEdaGjwaWGXHfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkGG9BhhLB2og2Bu5QAc0ow2BE4pyzVrPrql0KvHfO9giHdZf9hSS3aayIfKYxboeilBr3CpMfl3VZIxnyrdluSqfCHANfTJ)RqXIve0xeMyXlqw(PblpKf9vel3ZYkIfl3VZcaDPX(WIxGSGMyJeRQc2BH5EAo3ERflTyrD17gkOVimLXqTpMHs9RWSeplk3mljjSOU6Ddf0xeMY6v5JzOu)kmlXZIYnZsBwuWsac1GqlLj45RcMHs9RWSeplXSzwuWslwux9UjAUu4aEUo7tWRlKJwASpgGUErSaywae63mljjSynlZQOoCqrMO5sHd456SpbVUqoAPX(yi0BDrreilTzPnljjSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IyjELybqiMMzjjHLaeQbHwktWZxfmd5Gnyrblo(hxNJGwOHL4zbX2S9BhhLv2og2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nRzbCwhOPG5aiMffSa0NZv1KjaMdWc8(dwSOGLwS0ILaeQbHwkdLg1yixNHdy5vGmdL6xHzbWSOmahXWcIyPflkRmliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0MffSqO36IIiqdLg1yixNHdy5vGyPnljjS44FCDocAHgwIxjwqSnZIcwAXI1S8UMQ30xtJmSNj9QidvUQMazjjHf1vVBcE(QGbCn(FWIL4zjaHAqOLY0xtJmSNj9QiZqP(vywqelaewAZIcwa6Z5QAY87ZP1zmriqt2IFplkyPflQRE3GWvGdbMP0iOfAsP6ZurdQlUKzfXssclwZsacKkVEdcnMZlwAZIcwEFqrV5Vuk)Wm4rSeplQRE3e88vbd4A8)GfliolnBqmSKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyjjHLaeivE9M6qT)5UtSKKWI6Q3nQAieuVWVzfXIcwux9UrvdHG6f(ndL6xHzbWSOU6DtWZxfmGRX)dwSGiwAXcILfeNLzvuhoOit0CPWb8CD2NGxxihT0yFme6TUOicKL2S0MffSynlQRE3e88vbZkIffS0IfRzjabsLxVPou7FU7eljjSeGqni0szcWciebk)7ughDZ9yZkILKewuHymlkyPFO2)8qP(vywamlbiudcTuMaSacrGY)oLXr3Cp2muQFfMfeXcaNLKew6hQ9ppuQFfMfKklkdqAMfaZI6Q3nbpFvWaUg)pyXsB7nqchMl6pyzVbaWelOj2iXQQalwUFNf0alGqeiKGu(kWHazzl6M7XS4filGWcDplqG0yzUNybGU0yFyboSyzNkwILgcb1l8ZIf4sdYcHSOBiwuPoCiwqtSrIvvbwiKfDdHT3a6tU8uYElaMdWc8(dwz8B)2Xrzazhd7nQCvnbAhl7np8hSS3ghivWfo3hQIBd7nqchMl6pyzVbaWel)oXIvdQ(9gdlwUFNfNf0eBKyvvGLF3FwoCHUNL(atzbGU0yFS3cZ90CU9M6Q3nbpFvWmuQFfML4zrz0YssclQRE3e88vbd4A8)GflaMLy2mlkybOpNRQjtamhGf49hSY43(TJJYX0og2Bu5QAc0ow2BH5EAo3EdOpNRQjtamhGf49hSY4NffS0IfRzrD17MGNVkyaxJ)hSyjEwIzZSKKWI1SeGaPYR3aKQFVXWsBwssyrD17MXbsfCHZ9HQ42WSIyrblQRE3moqQGlCUpuf3gMHs9RWSaywqSSGiwcWcCDVjAOWHPSRpuvkvV5Vukd01lIfeXslwSMf1vVBu1qiOEHFZkIffSynlVRP6n43hnCanu5QAcKL22BE4pyzVfinH)Z1zxFOQuQE73ookJ(2XWEJkxvtG2XYElm3tZ52Ba95CvnzcG5aSaV)Gvg)2BE4pyzVDvWNY)dw2VDCugT2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzVznlbiudcTuMGNVkygYbBWssclwZcqFoxvtMaSacrGYGeUrfyrblbiqQ86n1HA)ZDNyjjHfWzDGMcMdGy7nqchMl6pyzVz1WNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoqcKLoCybnXgjwvfybdz539NLFNAWIpu9SyXXpbYcsjl8ZIk1HdXYVtP2Ba9jxEkzVHDGuUdNCWZxfSF74Oma3og2Bu5QAc0ow2BE4pyzV1xtJmSNj9Qi7nqchMl6pyzVbaWeMfamOvWY1z5kw8IfRiOVimXIxGS8ZrywEil6RiwUNLvelwUFNfa6sJ9b5SGMyJeRQcS4filXg0J(diXYMfFsT3cZ90CU9gf0xeMmxL9QblkyXJYHDkGalkyrD17MO5sHd456SpbVUqoAPX(ya66fXcGzbqOFZSOGLwSacFJd6r)bKYyl(KMb9uhfz(lGWvOyjjHfRzjabsLxVPOWa1WbKL2SOGfG(CUQMmyhiL7Wjh88vbwuWslwux9UzCGubx4CFOkUnmdL6xHzbWSGyzbaYslwqlliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0MffSOU6DZ4aPcUW5(qvCBywrSKKWI1SOU6DZ4aPcUW5(qvCBywrS02(TJJYig7yyVrLRQjq7yzV5H)GL9g(9P7AT9giHdZf9hSS3aayIfa8f97SS9(0DTMLObgWSCDw2EF6UwZYHl09SSIS3cZ90CU9M6Q3nWI(DCoIMaf9hSmRiwuWI6Q3n43NUR1MH6dH3Dvnz)2XrzaIDmS3OYv1eODSS3cZ90CU9M6Q3n43hnCandL6xHzbWSGwwuWslwux9UHc6lctzmu7JzOu)kmlXZcAzjjHf1vVBOG(IWuwVkFmdL6xHzjEwqllTzrblo(hxNJGwOHL4zbX2S9Mh(dw2BbVcKoRU6D7n1vVNlpLS3WVpA4aA)2XrzeRDmS3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2Bw9vAeMLyJbOSOsD4qSGgybeIaXYcFfkw(DIf0alGqeiwcWc8(dwS8qwc7uabwUolObwaHiqSCyw8WVCTUblUkC9S8qwujwco(T3cZ90CU9wacKkVEtDO2)C3jwuWcqFoxvtMaSacrGYGeUrfyrblbiudcTuMaSacrGY)oLXr3Cp2muQFfMfaZcAzrblwZc4SoqtbZbqmlkyHc6lctMRYE1GffS44FCDocAHgwINf0Vz73ooaQz7yyVrLRQjq7yzV5H)GL9g(9P7AT9giHdZf9hSS3aayILT3NUR1Sy5(Dw2EsR9HfR(C9NfVazPGSS9(OHdiYzXYovSuqw2EF6UwZYHzzfHCwAaxS4dXYvSyLRYhwSIG(IWelD4WcabrykGzboS8qwIgyGfa6sJ9Hfl7uXIRcbsSGyBMLyJbOSahwCWi)pGelyl(KYYUJzbGGimfWSmuQF1vOyboSCywUILU(qT)gwId8jw(D)zzvG0WYVtSG9uILaSaV)GfML7rhMfWimlfT(X1S8qw2EF6UwZc4AUcflwToqQGlmlaydvXTbYzXYovS0aUqhil4)0AwOcKLvelwUFNfeBZiYXrS0Hdl)oXI2XplO0qvxJn2BH5EAo3E7DnvVb)Kw7tgCU(BOYv1eilkyXAwExt1BWVpA4aAOYv1eilkyrD17g87t31AZq9HW7UQMyrblTyrD17gkOVimL1RYhZqP(vywINfaclkyHc6lctMRY6v5dlkyrD17MO5sHd456SpbVUqoAPX(ya66fXcGzbqOTzwssyrD17MO5sHd456SpbVUqoAPX(ya66fXs8kXcGqBZSOGfh)JRZrql0Ws8SGyBMLKewaHVXb9O)aszSfFsZGEQJImdL6xHzjEwaiSKKWIh(dwgh0J(diLXw8jnd6PokYCvURpu7plTzrblbiudcTuMGNVkygk1VcZs8SOCZ2VDCaKY2XWEJkxvtG2XYEZd)bl7n87dEnOi7nqchMl6pyzVbaWelBVp41GIybaFr)olrdmGzXlqwaxPrSeBmaLfl7uXcAInsSQkWcCy53jwSAq1V3yyrD17SCywCv46z5HS0DTMfyVZcCyPbCHoqwcEelXgdqT3cZ90CU9M6Q3nWI(DCoOjFYap8blZkILKewux9UbHRahcmtPrql0Ks1NPIguxCjZkILKewux9Uj45RcMvelkyPflQRE3moqQGlCUpuf3gMHs9RWSaywqfanPoYybXzjqNMLwS44FCDocAHgwqclXSzwAZcIyjMSG4S8UMQ3uKLCkewgQCvnbYIcwSMLzvuhoOid(Q(sN3BGFAo3qLRQjqwuWI6Q3nJdKk4cN7dvXTHzfXssclQRE3e88vbZqP(vywamlOcGMuhzSG4SeOtZslwC8pUohbTqdliHLy2mlTzjjHf1vVBghivWfo3hQIBJm(Q(sN3BGFAo3SIyjjHLwSOU6DZ4aPcUW5(qvCBygk1VcZcGzXd)bld(9PFdziKrH1t5)sjwuWcoI068UJFIfaZsZg0NLKewux9UzCGubx4CFOkUnmdL6xHzbWS4H)GLXY4)UHqgfwpL)lLyjjHfG(CUQMmh6bMdWc8(dwSOGLaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgSOGfc9wxuebAUchM17QAkJElV(vAgKaEbIL2SOGf1vVBghivWfo3hQIBdZkILKewSMf1vVBghivWfo3hQIBdZkIffSynlbiudcTuMXbsfCHZ9HQ42WmKd2GLKewSMLaeivE9gGu97ngwAZssclo(hxNJGwOHL4zbX2mlkyHc6lctMRYE1W(TJdGaKDmS3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BXyAWYdzj1rGy53jwuj8ZcSZY27JgoGSO2Gf87beUcfl3ZYkIf0BDbe0ny5kw8QblwrqFryIf11ZcaDPX(WYHRNfxfUEwEilQelrdmeiq7TWCpnNBV9UMQ3GFF0Wb0qLRQjqwuWI1SmRI6Wbfz(lLSaNkdoKNQEfingQCvnbYIcwAXI6Q3n43hnCanRiwssyXX)46Ce0cnSepli2MzPnlkyrD17g87JgoGg87beybWSetwuWslwux9UHc6lctzmu7JzfXssclQRE3qb9fHPSEv(ywrS0MffSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSaietZSOGLwSeGqni0szcE(QGzOu)kmlXZIYnZssclwZcqFoxvtMaSacrGYGeUrfyrblbiqQ86n1HA)ZDNyPT9Bhhaft7yyVrLRQjq7yzVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3OG(IWK5QSEv(WcIZcaHfKWIh(dwg87t)gYqiJcRNY)LsSGiwSMfkOVimzUkRxLpSG4S0IfaoliIL31u9gmCPZWE(3PChoe(nu5QAcKfeNLyYsBwqclE4pyzSm(VBiKrH1t5)sjwqelnBqF0YcsybhrADE3XpXcIyPzdAzbXz5DnvVP8FneoR6AVcKHkxvtG2BGeomx0FWYEZkW)L6pHzzhAHL0vyNLyJbOS4dXck)kcKLiAybtbybAVb0NC5PK9MJJaO0Srb73ooac9TJH9gvUQMaTJL9Mh(dw2B43h8Aqr2BGeomx0FWYEZQVsJyz79bVguelxXIZcIbrykWYgu7dlwrqFryc5Sacl09SOPNL7zjAGbwaOln2hwA97(ZYHzz3lqnbYIAdwO73PHLFNyz79P7Anl6RiwGdl)oXsSXa04rSnZI(kILoCyz79bVguuBKZciSq3ZceinwM7jw8Ifa8f97SenWalEbYIMEw(DIfxfcKyrFfXYUxGAILT3hnCaT3cZ90CU9M1SmRI6Wbfz(lLSaNkdoKNQEfingQCvnbYIcwAXI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIfaZcGqmnZssclQRE3enxkCapxN9j41fYrln2hdqxViwamlacTnZIcwExt1BWpP1(KbNR)gQCvnbYsBwuWslwOG(IWK5QmgQ9HffS44FCDocAHgwqela95CvnzCCeaLMnkWcIZI6Q3nuqFrykJHAFmdL6xHzbrSacFtFnnYWEM0RIm)fqaNhk1VIfeNfazqllXZcaPzwssyHc6lctMRY6v5dlkyXX)46Ce0cnSGiwa6Z5QAY44iaknBuGfeNf1vVBOG(IWuwVkFmdL6xHzbrSacFtFnnYWEM0RIm)fqaNhk1VIfeNfazqllXZcITzwAZIcwSMf1vVBGf974Cenbk6pyzwrSOGfRz5DnvVb)(OHdOHkxvtGSOGLwSeGqni0szcE(QGzOu)kmlXZcIHLKewWWLw9kqZVpNwNXeHangQCvnbYIcwux9U53NtRZyIqGgd(9acSaywIzmzbaYslwMvrD4GIm4R6lDEVb(P5CdvUQMazbXzbTS0MffS0pu7FEOu)kmlXZIYn3mlkyPFO2)8qP(vywamlaQ5MzPnlkyPflbiudcTugeUcCiWmo6M7XMHs9RWSepligwssyXAwcqGu51BqOXCEXsB73ooacT2XWEJkxvtG2XYEZd)bl7TISKtHWYEdKWH5I(dw2BaamXcaoiSWSCflw5Q8HfRiOVimXIxGSGDGeliLY1DebGT0AwaWbHflD4WcAInsSQkWIxGSGu(kWHazXksJGwOjLQ3Elm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfczuy9u(VuILKewAXsy3hueMfLybqSOGLHc7(GIY)LsSaywqllTzjjHLWUpOimlkXsmzPnlkyXJYHDkGalkybOpNRQjd2bs5oCYbpFvW(TJdGa42XWEJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfczuy9u(VuIffSynlbiqQ86ni0yoVyjjHLwSOU6DdcxboeyMsJGwOjLQptfnOU4sMvelkyjabsLxVbHgZ5flTzjjHLwSe29bfHzrjwaelkyzOWUpOO8FPelaMf0YsBwssyjS7dkcZIsSetwssyrD17MGNVkywrS0MffS4r5WofqGffSa0NZv1Kb7aPCho5GNVkWIcwAXI6Q3nJdKk4cN7dvXTHzOu)kmlaMLwSGwwaGSaiwqCwMvrD4GIm4R6lDEVb(P5CdvUQMazPnlkyrD17MXbsfCHZ9HQ42WSIyjjHfRzrD17MXbsfCHZ9HQ42WSIyPT9Mh(dw2B7UUNtHWY(TJdGqm2XWEJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfczuy9u(VuIffSynlbiqQ86ni0yoVyjjHLwSOU6DdcxboeyMsJGwOjLQptfnOU4sMvelkyjabsLxVbHgZ5flTzjjHLwSe29bfHzrjwaelkyzOWUpOO8FPelaMf0YsBwssyjS7dkcZIsSetwssyrD17MGNVkywrS0MffS4r5WofqGffSa0NZv1Kb7aPCho5GNVkWIcwAXI6Q3nJdKk4cN7dvXTHzOu)kmlaMf0YIcwux9UzCGubx4CFOkUnmRiwuWI1SmRI6WbfzWx1x68Ed8tZ5gQCvnbYssclwZI6Q3nJdKk4cN7dvXTHzfXsB7np8hSS36lToNcHL9BhhabqSJH9gvUQMaTJL9giHdZf9hSS3aayIfKcOvWcSyjaAV5H)GL9MfFMdozypt6vr2VDCaeI1og2Bu5QAc0ow2BE4pyzVHFF63q2BGeomx0FWYEdaGjw2EF63qS8qwIgyGLnO2hwSIG(IWeYzbnXgjwvfyz3XSOjmML)sjw(DVyXzbPy8FNfczuy9elAQ)SahwGLUblw5Q8HfRiOVimXYHzzfzVfM7P5C7nkOVimzUkRxLpSKKWcf0xeMmyO2NCri7zjjHfkOVimz8QrUiK9SKKWslwux9UXIpZbNmSNj9QiZkILKewWrKwN3D8tSaywA2G(OLffSynlbiqQ86naP63BmSKKWcoI068UJFIfaZsZg0NffSeGaPYR3aKQFVXWsBwuWI6Q3nuqFrykRxLpMveljjS0If1vVBcE(QGzOu)kmlaMfp8hSmwg)3neYOW6P8FPelkyrD17MGNVkywrS02(TJtmB2og2Bu5QAc0ow2BGeomx0FWYEdaGjwqkg)3zb(70y5Welw2VWolhMLRyzdQ9HfRiOVimHCwqtSrIvvbwGdlpKLObgyXkxLpSyfb9fHj7np8hSS3Sm(VB)2XjMkBhd7nQCvnbAhl7nqchMl6pyzVbG5A9Vpl7np8hSS3MvL9WFWkRp8BVPp8NlpLS36Uw)7ZY(TF7TOHcWuv)TJHDCu2og2BE4pyzVHWvGdbMXr3Cp2EJkxvtG2XY(TJdGSJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYERz7nqchMl6pyzVfJDIfG(CUQMy5WSGPNLhYsZSy5(Dwkil43FwGfllmXYpxHa9yKZIYSyzNkw(DIL(n4NfyrSCywGfllmHCwaelxNLFNybtbybYYHzXlqwIjlxNfv4VZIpK9gqFYLNs2BWkVWu(NRqGE73ooX0og2Bu5QAc0ow2BWi7nhe0EZd)bl7nG(CUQMS3a66fzVPS9wyUNMZT3(5keO38kB2DCEHPS6Q3zrbl)Cfc0BELnbiudcTugW14)blwuWI1S8ZviqV5v2CyZdtPmSNtHf(h4cNdWc)Zk8hSW2Ba9jxEkzVbR8ct5FUcb6TF74G(2XWEJkxvtG2XYEdgzV5GG2BE4pyzVb0NZv1K9gqxVi7nazVfM7P5C7TFUcb6npGm7ooVWuwD17SOGLFUcb6npGmbiudcTugW14)blwuWI1S8ZviqV5bK5WMhMszypNcl8pWfohGf(Nv4pyHT3a6tU8uYEdw5fMY)Cfc0B)2XbT2XWEJkxvtG2XYEdgzV5GG2BE4pyzVb0NZv1K9gqFYLNs2BWkVWu(NRqGE7TWCpnNBVrO36IIiqZv4WSExvtz0B51VsZGeWlqSKKWcHERlkIanuAuJHCDgoGLxbILKewi0BDrreObdxAn9)vOYZsTH9giHdZf9hSS3IXoHjw(5keOhZIpelf8zXxpm1)l4ADdwaPNcpbYIJzbwSSWel43Fw(5keOhByHLn6zbOpNRQjwEilOploMLFNAWIRXqwkIazbhrHZ1SS7fO(kug7nGUEr2BOV9BhhaUDmS38WFWYElfcleUk3HtQ9gvUQMaTJL9BhheJDmS3OYv1eODSS38WFWYEZY4)U9wyUNMZT3AXcf0xeMm6v5tUiK9SKKWcf0xeMmxLXqTpSKKWcf0xeMmxLvH)oljjSqb9fHjJxnYfHSNL22B6ROCa0Et5MTF73(T3asd(GLDCauZas5MbinRS9MfFQRqHT3qkITvBCSQ4y1eaJfwIXoXYLgbNNLoCybDWiQObDSme6TUHazbdtjw81dt9NazjS7fkcB4MSYRiwaeaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4MSYRiwIjaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4M4MqkITvBCSQ4y1eaJfwIXoXYLgbNNLoCybDGu3x6hDSme6TUHazbdtjw81dt9NazjS7fkcB4MSYRiwa4amwqdSasZtGSSDPOHfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPLYiRTHBYkVIybGdWybnWcinpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJS2gUjR8kIfedaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4MSYRiwaiamwqdSasZtGSSDPOHfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPfGqwBd3KvEfXcabGXcAGfqAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTugzTnCtw5veliwaglObwaP5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK12WnzLxrSGybySGgybKMNazbD)Cfc0Bu2aGqhlpKf09ZviqV5v2aGqhlTaeYAB4MSYRiwqSamwqdSasZtGSGUFUcb6naYaGqhlpKf09ZviqV5bKbaHowAbiK12WnzLxrSOCZamwqdSasZtGSGUzvuhoOidacDS8qwq3SkQdhuKbazOYv1ei6yPLYiRTHBYkVIyrzLbySGgybKMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrwBd3KvEfXIYacGXcAGfqAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTugzTnCtw5velkhtaglObwaP5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK12WnzLxrSOmAbySGgybKMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrwBd3KvEfXIYaCaglObwaP5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0cqiRTHBYkVIyrzaoaJf0alG08eilO7NRqGEJYgae6y5HSGUFUcb6nVYgae6yPfGqwBd3KvEfXIYaCaglObwaP5jqwq3pxHa9gazaqOJLhYc6(5keO38aYaGqhlTugzTnCtw5velkJyaySGgybKMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslaHS2gUjR8kIfLrmamwqdSasZtGSGUFUcb6nkBaqOJLhYc6(5keO38kBaqOJLwkJS2gUjR8kIfLrmamwqdSasZtGSGUFUcb6naYaGqhlpKf09ZviqV5bKbaHowAbiK12WnXnHueBR24yvXXQjaglSeJDILlncoplD4Wc6Igkatv9hDSme6TUHazbdtjw81dt9NazjS7fkcB4MSYRiwIjaJf0alG08eilO7NRqGEJYgae6y5HSGUFUcb6nVYgae6yPvmrwBd3KvEfXc6dWybnWcinpbYc6(5keO3aidacDS8qwq3pxHa9Mhqgae6yPvmrwBd3e3esrSTAJJvfhRMaySWsm2jwU0i48S0HdlOZHe6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnzLxrSOmaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIow8NfRaaVvYslLrwBd3KvEfXsmbySGgybKMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrwBd3KvEfXcIbGXcAGfqAEcKLTlfnSGBuVJmwqQivwEilw5YzjfcU0lmlWiA8hoS0cP2MLwkJS2gUjR8kIfedaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAbiK12WnzLxrSaqaySGgybKMNazz7srdl4g17iJfKksLLhYIvUCwsHGl9cZcmIg)HdlTqQTzPLYiRTHBYkVIybGaWybnWcinpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJS2gUjR8kIfelaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4MSYRiwuUzaglObwaP5jqw2Uu0WcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0cqiRTHBYkVIyr5ycWybnWcinpbYY2LIgwWnQ3rglivwEilw5Yzb8aE4dwSaJOXF4WslK0MLwkJS2gUjR8kIfa1maJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4MSYRiwaeGaySGgybKMNazz7srdl4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslLrwBd3KvEfXcGqFaglObwaP5jqw2Uu0WcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0cqiRTHBYkVIybqOpaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4MSYRiwaeahGXcAGfqAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTugzTnCtw5velacXaWybnWcinpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJS2gUjR8kIfaHybySGgybKMNazz7srdl4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslaHS2gUjR8kILy2maJf0alG08eilBxkAyb3OEhzSGuz5HSyLlNfWd4HpyXcmIg)HdlTqsBwAPmYAB4M4MqkITvBCSQ4y1eaJfwIXoXYLgbNNLoCybDDxR)9zHowgc9w3qGSGHPel(6HP(tGSe29cfHnCtw5velacGXcAGfqAEcKLTlfnSGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTugzTnCtCtifX2QnowvCSAcGXclXyNy5sJGZZshoSGo8Jowgc9w3qGSGHPel(6HP(tGSe29cfHnCtw5velkdWybnWcinpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJS2gUjR8kILycWybnWcinpbYc6MvrD4GImai0XYdzbDZQOoCqrgaKHkxvtGOJLwkJS2gUjR8kIfLvgGXcAGfqAEcKLTlfnSGBuVJmwqQivwEilw5YzjfcU0lmlWiA8hoS0cP2MLwkJS2gUjR8kIfLvgGXcAGfqAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTugzTnCtw5velkdWbySGgybKMNazbDZQOoCqrgae6y5HSGUzvuhoOidaYqLRQjq0XslLrwBd3KvEfXcGugGXcAGfqAEcKLTlfnSGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTaeYAB4MSYRiwaKYamwqdSasZtGSGUzvuhoOidacDS8qwq3SkQdhuKbazOYv1ei6yPLYiRTHBYkVIybqacGXcAGfqAEcKf0nRI6WbfzaqOJLhYc6MvrD4GImaidvUQMarhlTugzTnCtw5velakMamwqdSasZtGSSDPOHfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPvmrwBd3KvEfXcGqFaglObwaP5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0cqiRTHBYkVIybqaCaglObwaP5jqwq3SkQdhuKbaHowEilOBwf1HdkYaGmu5QAceDS0szK12WnzLxrSaiedaJf0alG08eilOBwf1HdkYaGqhlpKf0nRI6WbfzaqgQCvnbIowAPmYAB4M4MqkITvBCSQ4y1eaJfwIXoXYLgbNNLoCybDQq)rhldHERBiqwWWuIfF9Wu)jqwc7EHIWgUjR8kIfLbiamwqdSasZtGSSDPOHfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPvmrwBd3KvEfXIYiwaglObwaP5jqw2Uu0WcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0szK12WnXnzvPrW5jqwqmS4H)Gfl6d)yd3K9w0a7NMS3qAKMLy5AVcelw9zDGCtinsZsSxOw4NLyICwauZaszUjUjKgPzbn7EHIWamUjKgPzbaYsSbbjqw2GAFyjwKNA4MqAKMfailOz3lueilVpOOpFDwcoMWS8qwcncAk)(GIESHBcPrAwaGSy1sPqGeilRQOaHX(0GfG(CUQMWS06mKb5SeneWm(9bVguelaW4zjAiGg87dEnOO2gUjKgPzbaYsSbcpqwIgk44)kuSGum(VZY1z5E0Hz53jwSmWcflwrqFryYWnH0inlaqwaW5iqSGgybeIaXYVtSSfDZ9ywCw03)AILu4qS01eYovnXsRRZsd4ILDhSq3ZY(9SCpl4lDPFVi4cRBWIL73zjwa4JDmybrSGgst4)CnlXwFOQuQEKZY9OdKfmcxuBd3esJ0SaazbaNJaXske)SGU(HA)ZdL6xHrhl4av(CqmlEuKUblpKfvigZs)qT)ywGLUHHBcPrAwaGSeJH8NLyatjwGDwIL23zjwAFNLyP9DwCmlol4ikCUMLFUcb6nCtinsZcaKfa8rurdlTodzqolifJ)7iNfKIX)DKZY27t)gQnlPoiXskCiwgcF6JQNLhYc5J(OHLamv1Fai(95nCtCtinsZsSRc((tGSelx7vGyj2auRKLGxSOsS0HRcKf)zz))imadjir11Efiai(sdgu3VVunhejXY1Efia42LIgKKcA2)unsP7NMus11EfiZJSNBIBYd)blSjAOamv1FLq4kWHaZ4OBUhZnH0SeJDIfG(CUQMy5WSGPNLhYsZSy5(Dwkil43FwGfllmXYpxHa9yKZIYSyzNkw(DIL(n4NfyrSCywGfllmHCwaelxNLFNybtbybYYHzXlqwIjlxNfv4VZIpe3Kh(dwyt0qbyQQ)isjKa0NZv1eYlpLucw5fMY)Cfc0JCGUErk1m3Kh(dwyt0qbyQQ)isjKa0NZv1eYlpLucw5fMY)Cfc0JCyKsoiiYb66fPKYi)6k9ZviqVrzZUJZlmLvx9UIFUcb6nkBcqOgeAPmGRX)dwkS(NRqGEJYMdBEykLH9CkSW)ax4Caw4FwH)GfMBYd)blSjAOamv1FePesa6Z5QAc5LNskbR8ct5FUcb6romsjhee5aD9Iucqi)6k9ZviqVbqMDhNxykRU6Df)Cfc0BaKjaHAqOLYaUg)pyPW6FUcb6naYCyZdtPmSNtHf(h4cNdWc)Zk8hSWCtinlXyNWel)Cfc0JzXhILc(S4RhM6)fCTUblG0tHNazXXSalwwyIf87pl)Cfc0JnSWYg9Sa0NZv1elpKf0NfhZYVtnyX1yilfrGSGJOW5Aw29cuFfkd3Kh(dwyt0qbyQQ)isjKa0NZv1eYlpLucw5fMY)Cfc0JCyKsoiiYb66fPe6J8RReHERlkIanxHdZ6DvnLrVLx)kndsaVaLKqO36IIiqdLg1yixNHdy5vGssi0BDrreObdxAn9)vOYZsTb3Kh(dwyt0qbyQQ)isjKKcHfcxL7WjLBYd)blSjAOamv1FePesSm(VJC9vuoaQKYnJ8RRulkOVimz0RYNCri7tsOG(IWK5QmgQ9jjHc6lctMRYQWFpjHc6lctgVAKlczFBUjUjKMfa6qbh)Saiwqkg)3zXlqwCw2EFWRbfXcSyzlgSy5(DwIZHA)zbaZjw8cKLybJDmyboSS9(0VHyb(70y5We3Kh(dwydmIkAqKsiXY4)oYVUsTOG(IWKrVkFYfHSpjHc6lctMRYyO2NKekOVimzUkRc)9KekOVimz8QrUiK9TveneqJYglJ)7kSoAiGgazSm(VZn5H)Gf2aJOIgePesWVp9BiKRVIYbqLqlYVUswpRI6WbfzuDTxbkd7zxRZ)(vOWjjwhGaPYR3uhQ9p3DkjXACeP153hu0Jn43NUR1kPCsI1VRP6nL)RHWzvx7vGmu5QAcmjPff0xeMmyO2NCri7tsOG(IWK5QSEv(KKqb9fHjZvzv4VNKqb9fHjJxnYfHSVn3Kh(dwydmIkAqKsib)(Gxdkc56ROCauj0I8RR0SkQdhuKr11EfOmSNDTo)7xHcRiabsLxVPou7FU7KcCeP153hu0Jn43NUR1kPm3e3esJ0SyfiJcRNazHastdw(lLy53jw8Wdhwomloq)0UQMmCtE4pyHvcd1(KvjpLBYd)blmIucjbxRZE4pyL1h(rE5PKsWiQOb5xxP)sja3cqiUh(dwglJ)7MGJ)8FPeI8WFWYGFF63qMGJ)8FPuBUjKMLn6XSeBOvWcSyjMiIfl3VdxplGZ1Fw8cKfl3VZY27JgoGS4filacrSa)DASCyIBYd)blmIucja95CvnH8YtjLoC2HeYb66fPeoI0687dk6Xg87t3164vwrlRFxt1BWVpA4aAOYv1eysY7AQEd(jT2Nm4C93qLRQjW2jj4isRZVpOOhBWVpDxRJhqCtinlB0JzjOjhiXILDQyz79PFdXsWlw2VNfaHiwEFqrpMfl7xyNLdZYqAcOxplD4WYVtSyfb9fHjwEilQelrd1Pziqw8cKfl7xyNL(P10WYdzj44NBYd)blmIucja95CvnH8YtjLoCoOjhiHCGUErkHJiTo)(GIESb)(0VHIxzUjKMfRg(CUQMy539NLWofqaZY1zPbCXIpelxXIZcQailpKfhi8az53jwW3V8)Gflw2PHyXz5NRqGEwOpWYHzzHjqwUIfv6TquXsWXpMBYd)blmIucja95CvnH8YtjLUkJkaICGUErkfneqtkew9BOKKOHaAWRQFdLKeneqd(9bVguuss0qan43NUR1jjrdb00xtJmSNj9QOKe1vVBcE(QGzOu)kSsQRE3e88vbd4A8)Gf3esZcaatSelAW0GWvOyXY97SGMyJeRQcSahw8(tdlObwaHiqSCflOj2iXQQa3Kh(dwyePesuPbtdcxHc5xxPwTSoabsLxVPou7FU7usI1biudcTuMaSacrGY)oLXr3Cp2SIARqD17MGNVkygk1VchVYOvH6Q3nJdKk4cN7dvXTHzOu)kmGrFfwhGaPYR3aKQFVXKKeGaPYR3aKQFVXOqD17MGNVkywrkux9UzCGubx4CFOkUnmRifTux9UzCGubx4CFOkUnmdL6xHbSYkdarlIpRI6WbfzWx1x68Ed8tZ5jjQRE3e88vbZqP(vyaRSYjjkJuXrKwN3D8tawzdArB72ka6Z5QAYCvgvaKBcPzbGcFwSC)ololOj2iXQQal)U)SC4cDplola0Lg7dlrdmWcCyXYovS87el9d1(ZYHzXvHRNLhYcvGCtE4pyHrKsijc(hSq(1vsD17MGNVkygk1VchVYOvrlRNvrD4GIm4R6lDEVb(P58Ke1vVBghivWfo3hQIBdZqP(vyaRmIbaciexD17gvnecQx43SIuOU6DZ4aPcUW5(qvCBywrTtsuHySI(HA)ZdL6xHbmGql3esZcACDyP9NWSyzN(DAyzHVcflObwaHiqSuqlSy50AwCTgAHLgWflpKf8FAnlbh)S87elypLyXtHR6zb2zbnWciebcrOj2iXQQalbh)yUjp8hSWisjKa0NZv1eYlpLukalGqeOmiHBubKd01lsPaD6wT6hQ9ppuQFfgaQmAbGbiudcTuMGNVkygk1Vc3gPQmaP52kfOt3Qv)qT)5Hs9RWaqLrlamaHAqOLYeGfqicu(3Pmo6M7XgW14)blayac1GqlLjalGqeO8VtzC0n3JndL6xHBJuvgG0CBfwp(bMjGu9gheeBiKD4hNKeGqni0szcE(QGzOu)kC8x90eb1(tG5(HA)ZdL6xHtsMvrD4GImbst4)CDghDZ9yfbiudcTuMGNVkygk1VchFmBojjaHAqOLYeGfqicu(3Pmo6M7XMHs9RWXF1tteu7pbM7hQ9ppuQFfgaQCZjjwhGaPYR3uhQ9p3DIBcPzbaGjqwEilGK2BWYVtSSWokIfyNf0eBKyvvGfl7uXYcFfkwaHlvnXcSyzHjw8cKLOHas1ZYc7OiwSStflEXIdcYcbKQNLdZIRcxplpKfWJ4M8WFWcJiLqcqFoxvtiV8usPayoalW7pyHCGUErk1QFO2)8qP(v44vgTjjJFGzcivVXbbXMRIhTn3wrRwTi0BDrreOHsJAmKRZWbS8kqkAfGqni0szO0Ogd56mCalVcKzOu)kmGvgG3CssacKkVEdqQ(9gJIaeQbHwkdLg1yixNHdy5vGmdL6xHbSYaCedIAPSYi(SkQdhuKbFvFPZ7nWpnN3UTcRdqOgeAPmuAuJHCDgoGLxbYmKd2ODscHERlkIany4sRP)VcvEwQnu0Y6aeivE9M6qT)5UtjjbiudcTugmCP10)xHkpl1g5yI(OfG0SYMHs9RWawzLr)2jjTcqOgeAPmQ0GPbHRqzgYbBKKy94bY8duRBROvlc9wxuebAUchM17QAkJElV(vAgKaEbsrRaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgjjE4pyzUchM17QAkJElV(vAgKaEbYaEyxvtGTBNK0IqV1ffrGg8UdcTqGz4OMH98dNuQEfbiudcTuMhoPu9ey(k8HA)ZXeTOnMaszZqP(v42jjTAb0NZv1Kbw5fMY)Cfc0RKYjja95CvnzGvEHP8pxHa9kfZ2kA9ZviqVrzZqoyJCac1GqlvsYpxHa9gLnbiudcTuMHs9RWXF1tteu7pbM7hQ9ppuQFfgaQCZTtsa6Z5QAYaR8ct5FUcb6vcqkA9ZviqVbqMHCWg5aeQbHwQKKFUcb6naYeGqni0szgk1Vch)vpnrqT)eyUFO2)8qP(vyaOYn3ojbOpNRQjdSYlmL)5keOxPMB3UDssacKkVEdcnMZR2jjQqmwr)qT)5Hs9RWawD17MGNVkyaxJ)hS4MqAwSA4Z5QAILfMaz5HSasAVblE1GLFUcb6XS4filbqmlw2PIfl(9xHILoCyXlwSIv0oCoNLObg4M8WFWcJiLqcqFoxvtiV8usPFFoToJjcbAYw87roqxViLSgdxA1Ran)(CADgtec0yOYv1eyss)qT)5Hs9RWXdOMBojrfIXk6hQ9ppuQFfgWacTiQf63mauD17MFFoToJjcbAm43diG4aQDsI6Q3n)(CADgtec0yWVhqi(ycqaGTMvrD4GIm4R6lDEVb(P5CehTT5MqAwaayIfRinQXqUMfa8dy5vGybqnJPaMfvQdhIfNf0eBKyvvGLfMmCtE4pyHrKsizHP89ukYlpLuIsJAmKRZWbS8kqi)6kfGqni0szcE(QGzOu)kmGbuZkcqOgeAPmbybeIaL)DkJJU5ESzOu)kmGbuZkAb0NZv1K53NtRZyIqGMSf)(Ke1vVB(9506mMieOXGFpGq8XSze1Awf1HdkYGVQV059g4NMZrCaE72ka6Z5QAYCvgvamjrfIXk6hQ9ppuQFfgWXeXWnH0SaaWelBWLwt)vOyXQDP2GfaoMcywuPoCiwCwqtSrIvvbwwyYWn5H)GfgrkHKfMY3tPiV8usjmCP10)xHkpl1gi)6k1kaHAqOLYe88vbZqP(vyadWvyDacKkVEdqQ(9gJcRdqGu51BQd1(N7oLKeGaPYR3uhQ9p3Dsrac1GqlLjalGqeO8VtzC0n3JndL6xHbmaxrlG(CUQMmbybeIaLbjCJkKKeGqni0szcE(QGzOu)kmGb4TtscqGu51Bas1V3yu0Y6zvuhoOid(Q(sN3BGFAoxrac1GqlLj45RcMHs9RWagGNKOU6DZ4aPcUW5(qvCBygk1VcdyLrFe1cTioHERlkIanxH)zfE4GZGhWROSkP1TvOU6DZ4aPcUW5(qvCBywrTts6hQ9ppuQFfgWacTjje6TUOic0qPrngY1z4awEfifbiudcTugknQXqUodhWYRazgk1VchpGAUTcG(CUQMmxLrfavynHERlkIanxHdZ6DvnLrVLx)kndsaVaLKeGqni0szUchM17QAkJElV(vAgKaEbYmuQFfoEa1CsIkeJv0pu7FEOu)kmGbuZCtinlXwBXBGzzHjwSkRMT6Sy5(DwqtSrIvvbUjp8hSWisjKa0NZv1eYlpLu6qpWCawG3FWc5aD9IusD17MGNVkygk1VchVYOvrlRNvrD4GIm4R6lDEVb(P58Ke1vVBghivWfo3hQIBdZqP(vyaRKYacrTIjIRU6DJQgcb1l8BwrTruRwaeaiArC1vVBu1qiOEHFZkQnItO36IIiqZv4FwHho4m4b8kkRsADBfQRE3moqQGlCUpuf3gMvu7KevigROFO2)8qP(vyadi0MKqO36IIiqdLg1yixNHdy5vGueGqni0szO0Ogd56mCalVcKzOu)km3Kh(dwyePeswykFpLI8YtjLUchM17QAkJElV(vAgKaEbc5xxjG(CUQMmh6bMdWc8(dwka6Z5QAYCvgvaKBcPzbaGjwMd1(ZIk1HdXsaeZn5H)GfgrkHKfMY3tPiV8usj8UdcTqGz4OMH98dNuQEKFDLAfGqni0szcE(QGzihSHcRdqGu51BQd1(N7oPaOpNRQjZVpNwNXeHanzl(9jjbiqQ86n1HA)ZDNueGqni0szcWciebk)7ughDZ9yZqoydfTa6Z5QAYeGfqicugKWnQqssac1GqlLj45RcMHCWgTBRae(g8Q63qM)ciCfkfTaHVb)Kw7tUR9Hm)fq4kujjw)UMQ3GFsR9j31(qgQCvnbMKGJiTo)(GIESb)(0VHIpMTv0ce(MuiS63qM)ciCfQ2kAb0NZv1K5WzhsjjZQOoCqrgvx7vGYWE2168VFfkCsIJ)X15iOfAIxjeBZjjQRE3OQHqq9c)MvuBfTcqOgeAPmQ0GPbHRqzgYbBKKy94bY8duRBRWAc9wxuebAUchM17QAkJElV(vAgKaEbkjHqV1ffrGMRWHz9UQMYO3YRFLMbjGxGu0kaHAqOLYCfomR3v1ug9wE9R0mib8cKzOu)kC8XS5KKaeQbHwkJknyAq4kuMHs9RWXhZMBRWA1vVBcE(QGzfLKOcXyf9d1(Nhk1Vcdy0VzUjKMLySFywomlolJ)70WcPDv44pXIfVblpKLuhbIfxRzbwSSWel43Fw(5keOhZYdzrLyrFfbYYkIfl3VZcAInsSQkWIxGSGgybeIaXIxGSSWel)oXcGkqwWA4ZcSyjaYY1zrf(7S8ZviqpMfFiwGfllmXc(9NLFUcb6XCtE4pyHrKsizHP89ukg5yn8Xk9ZviqVYi)6k1cOpNRQjdSYlmL)5keO3ALuwH1)Cfc0BaKzihSroaHAqOLkjPfqFoxvtgyLxyk)ZviqVskNKa0NZv1Kbw5fMY)Cfc0RumBROL6Q3nbpFvWSIu0Y6aeivE9gGu97nMKe1vVBghivWfo3hQIBdZqP(vye1cTi(SkQdhuKbFvFPZ7nWpnN3gWk9ZviqVrzJ6Q3ZGRX)dwkux9UzCGubx4CFOkUnmROKe1vVBghivWfo3hQIBJm(Q(sN3BGFAo3SIANKeGqni0szcE(QGzOu)kmIau8)Cfc0Bu2eGqni0szaxJ)hSuyT6Q3nbpFvWSIu0Y6aeivE9M6qT)5Utjjwd0NZv1KjalGqeOmiHBuH2kSoabsLxVbHgZ5vssacKkVEtDO2)C3jfa95CvnzcWciebkds4gvqrac1GqlLjalGqeO8VtzC0n3JnRifwhGqni0szcE(QGzfPOvl1vVBOG(IWuwVkFmdL6xHJx5Mtsux9UHc6lctzmu7JzOu)kC8k3CBfwpRI6WbfzuDTxbkd7zxRZ)(vOWjjTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqqj0MKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGGsaK2Ttsux9UbHRahcmtPrql0Ks1NPIguxCjZkQDss)qT)5Hs9RWagqnNKa0NZv1Kbw5fMY)Cfc0RuZTva0NZv1K5QmQai3Kh(dwyePeswykFpLIrowdFSs)Cfc0diKFDLAb0NZv1Kbw5fMY)Cfc0BTsasH1)Cfc0Bu2mKd2ihGqni0sLKa0NZv1Kbw5fMY)Cfc0ReGu0sD17MGNVkywrkAzDacKkVEdqQ(9gtsI6Q3nJdKk4cN7dvXTHzOu)kmIAHweFwf1HdkYGVQV059g4NMZBdyL(5keO3aiJ6Q3ZGRX)dwkux9UzCGubx4CFOkUnmROKe1vVBghivWfo3hQIBJm(Q(sN3BGFAo3SIANKeGqni0szcE(QGzOu)kmIau8)Cfc0BaKjaHAqOLYaUg)pyPWA1vVBcE(QGzfPOL1biqQ86n1HA)ZDNssSgOpNRQjtawaHiqzqc3OcTvyDacKkVEdcnMZlfTSwD17MGNVkywrjjwhGaPYR3aKQFVX0ojjabsLxVPou7FU7KcG(CUQMmbybeIaLbjCJkOiaHAqOLYeGfqicu(3Pmo6M7XMvKcRdqOgeAPmbpFvWSIu0QL6Q3nuqFrykRxLpMHs9RWXRCZjjQRE3qb9fHPmgQ9XmuQFfoELBUTcRNvrD4GImQU2RaLH9SR15F)ku4KKwQRE3O6AVcug2ZUwN)9RqHZL)RHm43diOeAtsux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqqjas72Ttsux9UbHRahcmtPrql0Ks1NPIguxCjZkkjrfIXk6hQ9ppuQFfgWaQ5KeG(CUQMmWkVWu(NRqGELAUTcG(CUQMmxLrfa5MqAwaaycZIR1Sa)DAybwSSWel3tPywGflbqUjp8hSWisjKSWu(EkfZnH0Sy1PWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDyUjp8hSWisjKmRk7H)GvwF4h5LNsk5qc54FUWRKYi)6kb0NZv1K5WzhsCtE4pyHrKsizwv2d)bRS(WpYlpLusf6pYX)CHxjLr(1vAwf1HdkYO6AVcug2ZUwN)9RqHne6TUOicKBYd)blmIucjZQYE4pyL1h(rE5PKs4NBIBcPzbnUoS0(tywSSt)onS87elw9H80G)HDAyrD17Sy50Aw6UwZcS3zXY97xXYVtSueYEwco(5M8WFWcBCiPeqFoxvtiV8usjWH80SLtRZDxRZWEh5aD9IuQL6Q3n)LswGtLbhYtvVcKgZqP(vyaJkaAsDKHOMnkNKOU6DZFPKf4uzWH8u1RaPXmuQFfgWE4pyzWVp9BidHmkSEk)xkHOMnkROff0xeMmxL1RYNKekOVimzWqTp5Iq2NKqb9fHjJxnYfHSVDBfQRE38xkzbovgCipv9kqAmRifZQOoCqrM)sjlWPYGd5PQxbsd3esZcACDyP9NWSyzN(DAyz79bVguelhMflW53zj44)kuSabsdlBVp9BiwUIfRCv(WIve0xeM4M8WFWcBCiHiLqcqFoxvtiV8usPdvbhkJFFWRbfHCGUErkznf0xeMmxLXqTpkAHJiTo)(GIESb)(0VHIhTkExt1BWWLod75FNYD4q43qLRQjWKeCeP153hu0Jn43N(nu8iM2CtinlaamXcAGfqicelw2PIf)zrtyml)UxSG2Mzj2yaklEbYI(kILvelwUFNf0eBKyvvGBYd)blSXHeIucjbybeIaL)DkJJU5EmYVUswdoRd0uWCaeROvlG(CUQMmbybeIaLbjCJkOW6aeQbHwktWZxfmd5Gnssux9Uj45RcMvuBfTux9UHc6lctz9Q8XmuQFfoEaEsI6Q3nuqFrykJHAFmdL6xHJhG3wrlRNvrD4GImQU2RaLH9SR15F)ku4Ke1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87beIpMjjQRE3O6AVcug2ZUwN)9RqHZ(e8Im43dieFmBNKOcXyf9d1(Nhk1VcdyLBwH1biudcTuMGNVkygYbB0MBcPzbaGjwaWgQIBdwSC)olOj2iXQQa3Kh(dwyJdjePesghivWfo3hQIBdKFDLux9Uj45RcMHs9RWXRmA5MqAwaayILTv1VHy5kwI8cKsValWIfVA87xHILF3Fw0hqcZIYOpMcyw8cKfnHXSy5(DwsHdXY7dk6XS4fil(ZYVtSqfilWololBqTpSyfb9fHjw8NfLrFwWuaZcCyrtymldL6xDfkwCmlpKLc(SS7aVcflpKLH6dH3zbCnxHIfRCv(WIve0xeM4M8WFWcBCiHiLqcEv9BiKhAe0u(9bf9yLug5xxPwd1hcV7QAkjrD17gkOVimLXqTpMHs9RWaoMkOG(IWK5QmgQ9rXqP(vyaRm6R4DnvVbdx6mSN)Dk3HdHFdvUQMaBR49bf9M)sP8dZGhfVYOpaehrAD(9bf9yenuQFfwrlkOVimzUk7vJKKHs9RWagva0K6iRn3esZcaatSSTQ(nelpKLDhiXIZcknu11S8qwwyIfRYQzRo3Kh(dwyJdjePesWRQFdH8RReqFoxvtMd9aZbybE)blfbiudcTuMRWHz9UQMYO3YRFLMbjGxGmd5GnuqO36IIiqZv4WSExvtz0B51VsZGeWlqCtE4pyHnoKqKsib)(0DTg5xxjRFxt1BWpP1(KbNR)gQCvnbQOL6Q3n43NUR1MH6dH3DvnPOfoI0687dk6Xg87t31AahZKeRNvrD4GIm)LswGtLbhYtvVcKM2jjVRP6ny4sNH98Vt5oCi8BOYv1eOc1vVBOG(IWugd1(ygk1Vcd4yQGc6lctMRYyO2hfQRE3GFF6UwBgk1VcdyeJcCeP153hu0Jn43NUR1XRe63wrlRNvrD4GIm6gbFCCURj6VcvgL(sJWusYFPesfPI(OnE1vVBWVpDxRndL6xHreGAR49bf9M)sP8dZGhfpA5MqAwqkUFNLTN0AFyXQpx)zzHjwGflbqwSStfld1hcV7QAIf11Zc(pTMfl(9S0HdlwzJGpoMLObgyXlqwaHf6EwwyIfvQdhIf0y1Xgw2(tRzzHjwuPoCiwqdSacrGybFvGy539NflNwZs0adS4f83PHLT3NUR1CtE4pyHnoKqKsib)(0DTg5xxP31u9g8tATpzW56VHkxvtGkux9Ub)(0DT2muFi8URQjfTSEwf1HdkYOBe8XX5UMO)kuzu6lnctjj)LsivKk6J24r)2kEFqrV5Vuk)Wm4rXhtUjKMfKI73zXQpKNQEfinSSWelBVpDxRz5HSGarrSSIy53jwux9olQnyX1yill8vOyz79P7AnlWIf0YcMcWceZcCyrtymldL6xDfkUjp8hSWghsisjKGFF6UwJ8RR0SkQdhuK5VuYcCQm4qEQ6vG0OahrAD(9bf9yd(9P7AD8kftfTSwD17M)sjlWPYGd5PQxbsJzfPqD17g87t31AZq9HW7UQMssAb0NZv1KbCipnB506C316mS3v0sD17g87t31AZqP(vyahZKeCeP153hu0Jn43NUR1XdifVRP6n4N0AFYGZ1FdvUQMavOU6Dd(9P7ATzOu)kmGrB72T5MqAwqJRdlT)eMfl70VtdlolBVp41GIyzHjwSCAnlbFHjw2EF6UwZYdzP7AnlWEh5S4fillmXY27dEnOiwEiliquelw9H8u1RaPHf87beyzfXn5H)Gf24qcrkHeG(CUQMqE5PKs43NUR1zlW6ZDxRZWEh5aD9IuYX)46Ce0cnXdqAga2s5MrC1vVB(lLSaNkdoKNQEfing87beAdaBPU6Dd(9P7ATzOu)kmIhtKkoI068UJFcXT(DnvVb)Kw7tgCU(BOYv1eyBayRaeQbHwkd(9P7ATzOu)kmIhtKkoI068UJFcXFxt1BWpP1(KbNR)gQCvnb2ga2ce(M(AAKH9mPxfzgk1VcJ4OTTIwQRE3GFF6UwBwrjjbiudcTug87t31AZqP(v42CtinlaamXY27dEnOiwSC)olw9H8u1RaPHLhYccefXYkILFNyrD17Sy5(D46zrdXxHILT3NUR1SSI(lLyXlqwwyILT3h8AqrSalwqFeXsSGXogSGFpGaMLv9NMf0NL3hu0J5M8WFWcBCiHiLqc(9bVgueYVUsa95CvnzahYtZwoTo3DTod7Dfa95CvnzWVpDxRZwG1N7UwNH9UcRb6Z5QAYCOk4qz87dEnOOKKwQRE3O6AVcug2ZUwN)9RqHZL)RHm43dieFmtsux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqi(y2wboI0687dk6Xg87t31AaJ(ka6Z5QAYGFF6UwNTaRp3DTod7DUjKMfaaMybBXNuwWqw(D)zPbCXck6zj1rglRO)sjwuBWYcFfkwUNfhZI2FIfhZseeJpvnXcSyrtyml)UxSetwWVhqaZcCybPKf(zXYovSeteXc(9acywiKfDdXn5H)Gf24qcrkHeh0J(diLXw8jf5HgbnLFFqrpwjLr(1vY6)ciCfkfw7H)GLXb9O)aszSfFsZGEQJImxL76d1(NKacFJd6r)bKYyl(KMb9uhfzWVhqaWXubi8noOh9hqkJT4tAg0tDuKzOu)kmGJj3esZIvl1hcVZcaoiS63qSCDwqtSrIvvbwomld5Gnqol)onel(qSOjmMLF3lwqllVpOOhZYvSyLRYhwSIG(IWelwUFNLn4dGHCw0egZYV7flk3mlWFNglhMy5kw8QblwrqFryIf4WYkILhYcAz59bf9ywuPoCiwCwSYv5dlwrqFryYWIvhwO7zzO(q4DwaxZvOybP8vGdbYIvKgbTqtkvplRstymlxXYgu7dlwrqFryIBYd)blSXHeIucjPqy1VHqEOrqt53hu0JvszKFDLgQpeE3v1KI3hu0B(lLYpmdEu8TAPm6JOw4isRZVpOOhBWVp9BiehqiU6Q3nuqFrykRxLpMvu72iAOu)kCBKAlLr07AQEZB5QCkewydvUQMaBROvac1GqlLj45RcMHCWgkSgCwhOPG5aiwrlG(CUQMmbybeIaLbjCJkKKeGqni0szcWciebk)7ughDZ9yZqoyJKeRdqGu51BQd1(N7o1ojbhrAD(9bf9yd(9PFdb4wTa4aWwQRE3qb9fHPSEv(ywrioGA3gXBPmIExt1BElxLtHWcBOYv1ey72kSMc6lctgmu7tUiK9jjTOG(IWK5QmgQ9jjPff0xeMmxLvH)Escf0xeMmxL1RYN2kS(DnvVbdx6mSN)Dk3HdHFdvUQMatsux9UjAUu4aEUo7tWRlKJwASpgGUErXReGqBZTv0chrAD(9bf9yd(9PFdbyLBgXBPmIExt1BElxLtHWcBOYv1ey72kC8pUohbTqt8OTzaO6Q3n43NUR1MHs9RWioaVTIwwRU6DdcxboeyMsJGwOjLQptfnOU4sMvuscf0xeMmxLXqTpjjwhGaPYR3GqJ58QTcRvx9UzCGubx4CFOkUnY4R6lDEVb(P5CZkIBcPzbaGjwaWGXHfyXsaKfl3Vdxplbpk6kuCtE4pyHnoKqKsiPdNaLH9C5)AiKFDL8OCyNciWn5H)Gf24qcrkHeG(CUQMqE5PKsbWCawG3FWk7qc5aD9IuYAWzDGMcMdGyfa95CvnzcG5aSaV)GLIwTux9Ub)(0DT2SIssExt1BWpP1(KbNR)gQCvnbMKeGaPYR3uhQ9p3DQTIwwRU6DdgQX)fiZksH1QRE3e88vbZksrlRFxt1B6RPrg2ZKEvKHkxvtGjjQRE3e88vbd4A8)Gv8biudcTuM(AAKH9mPxfzgk1VcJiasBfa95Cvnz(9506mMieOjBXVxrlRdqGu51BQd1(N7oLKeGqni0szcWciebk)7ughDZ9yZksrl1vVBWVpDxRndL6xHbmGssS(DnvVb)Kw7tgCU(BOYv1ey72kEFqrV5Vuk)Wm4rXRU6DtWZxfmGRX)dwiEZget7KevigROFO2)8qP(vyaRU6DtWZxfmGRX)dwT5MqAwaayIf0eBKyvvGfyXsaKLvPjmMfVazrFfXY9SSIyXY97SGgybeIaXn5H)Gf24qcrkHKaPj8FUo76dvLs1J8RReqFoxvtMayoalW7pyLDiXn5H)Gf24qcrkHKRc(u(FWc5xxjG(CUQMmbWCawG3FWk7qIBcPzbaGjwSI0iOfAyjwWcKfyXsaKfl3VZY27t31AwwrS4filyhiXshoSaqxASpS4filOj2iXQQa3Kh(dwyJdjePesO0iOfAYQWce5xxPREAIGA)jWC)qT)5Hs9RWawz0MK0sD17MO5sHd456SpbVUqoAPX(ya66fbyaH2Mtsux9UjAUu4aEUo7tWRlKJwASpgGUErXReGqBZTvOU6Dd(9P7ATzfPOvac1GqlLj45RcMHs9RWXJ2MtsaN1bAkyoaIBZnH0Sy1s9HW7S01(qSalwwrS8qwIjlVpOOhZIL73HRNf0eBKyvvGfv6kuS4QW1ZYdzHqw0nelEbYsbFwGaPj4rrxHIBYd)blSXHeIucj4N0AFYDTpeYdncAk)(GIESskJ8RR0q9HW7UQMu8xkLFyg8O4vgTkWrKwNFFqrp2GFF63qag9v4r5Wofqqrl1vVBcE(QGzOu)kC8k3CsI1QRE3e88vbZkQn3esZcaatSaGbTcwUolxHpqIfVyXkc6lctS4fil6RiwUNLvelwUFNfNfa6sJ9HLObgyXlqwInOh9hqILnl(KYn5H)Gf24qcrkHK(AAKH9mPxfH8RRef0xeMmxL9QHcpkh2Packux9UjAUu4aEUo7tWRlKJwASpgGUEragqOTzfTaHVXb9O)aszSfFsZGEQJIm)fq4kujjwhGaPYR3uuyGA4aMKGJiTo)(GIEC8aQTIwQRE3moqQGlCUpuf3gMHs9RWagXcaBHweFwf1HdkYGVQV059g4NMZBRqD17MXbsfCHZ9HQ42WSIssSwD17MXbsfCHZ9HQ42WSIAROL1biudcTuMGNVkywrjjQRE387ZP1zmriqJb)EabaRmAv0pu7FEOu)kmGbuZnROFO2)8qP(v44vU5MtsSgdxA1Ran)(CADgtec0yOYv1eyBfTWWLw9kqZVpNwNXeHangQCvnbMKeGqni0szcE(QGzOu)kC8XS52CtinlaamXIZY27t31AwaWx0VZs0adSSknHXSS9(0DTMLdZIRhYbBWYkIf4Wsd4IfFiwCv46z5HSabstWJyj2yak3Kh(dwyJdjePesWVpDxRr(1vsD17gyr)oohrtGI(dwMvKIwQRE3GFF6UwBgQpeE3v1usIJ)X15iOfAIhX2CBUjKMfR(knILyJbOSOsD4qSGgybeIaXIL73zz79P7AnlEbYYVtflBVp41GI4M8WFWcBCiHiLqc(9P7AnYVUsbiqQ86n1HA)ZDNuy97AQEd(jT2Nm4C93qLRQjqfTa6Z5QAYeGfqicugKWnQqssac1GqlLj45RcMvusI6Q3nbpFvWSIARiaHAqOLYeGfqicu(3Pmo6M7XMHs9RWagva0K6idXd0PB54FCDocAHgKkABUTc1vVBWVpDxRndL6xHbm6RWAWzDGMcMdGyUjp8hSWghsisjKGFFWRbfH8RRuacKkVEtDO2)C3jfTa6Z5QAYeGfqicugKWnQqssac1GqlLj45RcMvusI6Q3nbpFvWSIARiaHAqOLYeGfqicu(3Pmo6M7XMHs9RWagGRqD17g87t31AZksbf0xeMmxL9QHcRb6Z5QAYCOk4qz87dEnOifwdoRd0uWCaeZnH0SaaWelBVp41GIyXY97S4fla4l63zjAGbwGdlxNLgWf6azbcKMGhXsSXauwSC)olnGRHLIq2ZsWXVHLyRXqwaxPrSeBmaLf)z53jwOcKfyNLFNyXQbv)EJHf1vVZY1zz79P7AnlwGlnyHUNLUR1Sa7DwGdlnGlw8HybwSaiwEFqrpMBYd)blSXHeIucj43h8Aqri)6kPU6DdSOFhNdAYNmWdFWYSIssAzn(9PFdz8OCyNciOWAG(CUQMmhQcoug)(GxdkkjPL6Q3nbpFvWmuQFfgWOvH6Q3nbpFvWSIssA1sD17MGNVkygk1VcdyubqtQJmepqNULJ)X15iOfAqQXS52kux9Uj45RcMvusI6Q3nJdKk4cN7dvXTrgFvFPZ7nWpnNBgk1VcdyubqtQJmepqNULJ)X15iOfAqQXS52kux9UzCGubx4CFOkUnY4R6lDEVb(P5CZkQTIaeivE9gGu97nM2Tv0chrAD(9bf9yd(9P7AnGJzscqFoxvtg87t316Sfy95UR1zyV3UTcRb6Z5QAYCOk4qz87dEnOifTSEwf1HdkY8xkzbovgCipv9kqAssWrKwNFFqrp2GFF6Uwd4y2MBcPzbaGjwaWbHfMLRyzdQ9HfRiOVimXIxGSGDGelaylTMfaCqyXshoSGMyJeRQcCtE4pyHnoKqKsiPil5uiSq(1vQL6Q3nuqFrykJHAFmdL6xHJNqgfwpL)lLssAf29bfHvcqkgkS7dkk)xkby02ojjS7dkcRumBRWJYHDkGa3Kh(dwyJdjePes2DDpNcHfYVUsTux9UHc6lctzmu7JzOu)kC8eYOW6P8FPussRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbeu0sD17MXbsfCHZ9HQ42WmuQFfgWOvH6Q3nJdKk4cN7dvXTHzfPW6zvuhoOid(Q(sN3BGFAopjXA1vVBghivWfo3hQIBdZkQn3Kh(dwyJdjePes6lToNcHfYVUsTux9UHc6lctzmu7JzOu)kC8eYOW6P8FPKIwbiudcTuMGNVkygk1VchpABojjaHAqOLYeGfqicu(3Pmo6M7XMHs9RWXJ2MBNK0kS7dkcReGumuy3huu(VucWOTDssy3huewPy2wHhLd7uabfTux9UzCGubx4CFOkUnmdL6xHbmAvOU6DZ4aPcUW5(qvCBywrkSEwf1HdkYGVQV059g4NMZtsSwD17MXbsfCHZ9HQ42WSIAZnH0SaaWelifqRGfyXcAS6CtE4pyHnoKqKsiXIpZbNmSNj9QiUjKMf046Ws7pHzXYo970WYdzzHjw2EF63qSCflBqTpSyz)c7SCyw8Nf0YY7dk6Xiszw6WHfcinnybqnJuzj1XpnnyboSG(SS9(GxdkIfRincAHMuQEwWVhqaZn5H)Gf24qcrkHeG(CUQMqE5PKs43N(nu(QmgQ9b5aD9IuchrAD(9bf9yd(9PFdfp6JOUgcNwPo(PPrgORxeIRCZnJubuZTruxdHtl1vVBWVp41GIYuAe0cnPu9zmu7Jb)EabKk63MBcPzbnUoS0(tywSSt)onS8qwqkg)3zbCnxHIfaSHQ42GBYd)blSXHeIucja95CvnH8YtjLSm(VNVk3hQIBdKd01lsjLrQ4isRZ7o(jadiayRMnacXBHJiTo)(GIESb)(0VHaGk3gXBPmIExt1BWWLod75FNYD4q43qLRQjqexzdAB3grnBugTiU6Q3nJdKk4cN7dvXTHzOu)km3esZcaatSGum(VZYvSSb1(WIve0xeMyboSCDwkilBVp9BiwSCAnl97z5QhYcAInsSQkWIxnsHdXn5H)Gf24qcrkHelJ)7i)6k1Ic6lctg9Q8jxeY(KekOVimz8QrUiK9ka6Z5QAYC4CqtoqQTIwVpOO38xkLFyg8O4r)KekOVimz0RYN8vzaLK0pu7FEOu)kmGvU52jjQRE3qb9fHPmgQ9XmuQFfgWE4pyzWVp9BidHmkSEk)xkPqD17gkOVimLXqTpMvuscf0xeMmxLXqTpkSgOpNRQjd(9PFdLVkJHAFssux9Uj45RcMHs9RWa2d)bld(9PFdziKrH1t5)sjfwd0NZv1K5W5GMCGKc1vVBcE(QGzOu)kmGjKrH1t5)sjfQRE3e88vbZkkjrD17MXbsfCHZ9HQ42WSIua0NZv1KXY4)E(QCFOkUnssSgOpNRQjZHZbn5ajfQRE3e88vbZqP(v44jKrH1t5)sjUjKMfaaMyz79PFdXY1z5kwSYv5dlwrqFryc5SCflBqTpSyfb9fHjwGflOpIy59bf9ywGdlpKLObgyzdQ9HfRiOVimXn5H)Gf24qcrkHe87t)gIBcPzbaZ16FFwCtE4pyHnoKqKsizwv2d)bRS(WpYlpLuQ7A9VplUjUjKMfaSHQ42Gfl3VZcAInsSQkWn5H)Gf2Oc9xPXbsfCHZ9HQ42a5xxj1vVBcE(QGzOu)kC8kJwUjKMfaaMyj2GE0Fajw2S4tklw2PIf)zrtyml)UxSG(SelySJbl43diGzXlqwEild1hcVZIZcGvcqSGFpGaloMfT)eloMLiigFQAIf4WYFPel3ZcgYY9S4ZCajmliLSWplE)PHfNLyIiwWVhqGfczr3qyUjp8hSWgvO)isjK4GE0FaPm2IpPip0iOP87dk6XkPmYVUsQRE3O6AVcug2ZUwN)9RqHZL)RHm43diayaIc1vVBuDTxbkd7zxRZ)(vOWzFcErg87beamarrlRbHVXb9O)aszSfFsZGEQJIm)fq4kukS2d)blJd6r)bKYyl(KMb9uhfzUk31hQ9xrlRbHVXb9O)aszSfFsZ7KRn)fq4kujjGW34GE0FaPm2IpP5DY1MHs9RWXhZ2jjGW34GE0FaPm2IpPzqp1rrg87beaCmvacFJd6r)bKYyl(KMb9uhfzgk1Vcdy0Qae(gh0J(diLXw8jnd6PokY8xaHRq1MBcPzbaGjwqdSacrGyXY97SGMyJeRQcSyzNkwIGy8PQjw8cKf4VtJLdtSy5(DwCwIfm2XGf1vVZILDQybKWnQWvO4M8WFWcBuH(JiLqsawaHiq5FNY4OBUhJ8RRK1GZ6anfmhaXkA1cOpNRQjtawaHiqzqc3OckSoaHAqOLYe88vbZqoyJKe1vVBcE(QGzf1wrl1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87beucGKKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGGsaK2jjQqmwr)qT)5Hs9RWaw5MBZnH0SaGbTcwCml)oXs)g8ZcQailxXYVtS4SelySJblwUceAHf4WIL73z53jwqk3yoVyrD17SahwSC)ololaeeHPalXg0J(diXYMfFszXlqwS43ZshoSGMyJeRQcSCDwUNflW6zrLyzfXIJYVIfvQdhILFNyjaYYHzPF1H3jqUjp8hSWgvO)isjK0xtJmSNj9QiKFDLA1QL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acXdWtsux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqiEaEBfTSoabsLxVbiv)EJjjXA1vVBghivWfo3hQIBdZkQDBfTaN1bAkyoaItscqOgeAPmbpFvWmuQFfoE02CssRaeivE9M6qT)5UtkcqOgeAPmbybeIaL)DkJJU5ESzOu)kC8OT52TBNK0ce(gh0J(diLXw8jnd6PokYmuQFfoEaIIaeQbHwktWZxfmdL6xHJx5MveGaPYR3uuyGA4a2oj5QNMiO2Fcm3pu7FEOu)kmGbikSoaHAqOLYe88vbZqoyJKKaeivE9geAmNxkux9UbHRahcmtPrql0Ks1BwrjjbiqQ86naP63Bmkux9UzCGubx4CFOkUnmdL6xHbmIvH6Q3nJdKk4cN7dvXTHzfXnH0SGgVcKMLT3hnCazXY97S4SuKfwIfm2XGf1vVZIxGSGMyJeRQcSC4cDplUkC9S8qwujwwycKBYd)blSrf6pIucjbVcKoRU6DKxEkPe(9rdhqKFDLAPU6DJQR9kqzyp7AD(3Vcfox(VgYmuQFfoEeJbTjjQRE3O6AVcug2ZUwN)9RqHZ(e8ImdL6xHJhXyqBBfTcqOgeAPmbpFvWmuQFfoEetssRaeQbHwkdLgbTqtwfwGMHs9RWXJyuyT6Q3niCf4qGzkncAHMuQ(mv0G6IlzwrkcqGu51BqOXCE1UTch)JRZrql0eVsXSzUjKMfR(knILT3h8AqrywSC)ololXcg7yWI6Q3zrD9SuWNfl7uXseeQVcflD4WcAInsSQkWcCybP8vGdbYYw0n3J5M8WFWcBuH(JiLqc(9bVgueYVUsTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqiEaLKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGq8aQTIwbiqQ86n1HA)ZDNsscqOgeAPmbpFvWmuQFfoEetsI1a95CvnzcG5aSaV)GLcRdqGu51BqOXCELK0kaHAqOLYqPrql0KvHfOzOu)kC8igfwRU6DdcxboeyMsJGwOjLQptfnOU4sMvKIaeivE9geAmNxTBROL1GW30xtJmSNj9QiZFbeUcvsI1biudcTuMGNVkygYbBKKyDac1GqlLjalGqeO8VtzC0n3Jnd5GnAZnH0Sy1xPrSS9(GxdkcZIk1HdXcAGfqice3Kh(dwyJk0FePesWVp41GIq(1vQvac1GqlLjalGqeO8VtzC0n3JndL6xHbmAvyn4SoqtbZbqSIwa95CvnzcWciebkds4gvijjaHAqOLYe88vbZqP(vyaJ22ka6Z5QAYeaZbybE)bR2kSge(M(AAKH9mPxfz(lGWvOueGaPYR3uhQ9p3DsH1GZ6anfmhaXkOG(IWK5QSxnu44FCDocAHM4r)M5MqAwS6WcDplGWNfW1Cfkw(DIfQazb2zXQ1bsfCHzbaBOkUnqolGR5kuSGWvGdbYcLgbTqtkvplWHLRy53jw0o(zbvaKfyNfVyXkc6lctCtE4pyHnQq)rKsibOpNRQjKxEkPei8ZdHERBOuQEmYb66fPul1vVBghivWfo3hQIBdZqP(v44rBsI1QRE3moqQGlCUpuf3gMvuBfTux9UbHRahcmtPrql0Ks1NPIguxCjZqP(vyaJkaAsDK1wrl1vVBOG(IWugd1(ygk1VchpQaOj1rwsI6Q3nuqFrykRxLpMHs9RWXJkaAsDK1MBYd)blSrf6pIucj4v1VHqEOrqt53hu0JvszKFDLgQpeE3v1KI3hu0B(lLYpmdEu8kdWv4r5WofqqbqFoxvtgq4Nhc9w3qPu9yUjp8hSWgvO)isjKKcHv)gc5HgbnLFFqrpwjLr(1vAO(q4DxvtkEFqrV5Vuk)Wm4rXRCmnOvHhLd7uabfa95CvnzaHFEi0BDdLs1J5M8WFWcBuH(JiLqc(jT2NCx7dH8qJGMYVpOOhRKYi)6knuFi8URQjfVpOO38xkLFyg8O4vgGJOHs9RWk8OCyNciOaOpNRQjdi8ZdHERBOuQEm3esZcagmoSalwcGSy5(D46zj4rrxHIBYd)blSrf6pIucjD4eOmSNl)xdH8RRKhLd7uabUjKMfRincAHgwIfSazXYovS4QW1ZYdzHQNgwCwkYclXcg7yWILRaHwyXlqwWoqILoCybnXgjwvf4M8WFWcBuH(JiLqcLgbTqtwfwGi)6k1Ic6lctg9Q8jxeY(KekOVimzWqTp5Iq2NKqb9fHjJxnYfHSpjrD17gvx7vGYWE2168VFfkCU8FnKzOu)kC8igdAtsux9Ur11EfOmSNDTo)7xHcN9j4fzgk1VchpIXG2Keh)JRZrql0epITzfbiudcTuMGNVkygYbBOWAWzDGMcMdG42kAfGqni0szcE(QGzOu)kC8XS5KKaeQbHwktWZxfmd5GnANKC1tteu7pbM7hQ9ppuQFfgWk3m3esZcag0kyzou7plQuhoell8vOybnXMBYd)blSrf6pIucj910id7zsVkc5xxPaeQbHwktWZxfmd5Gnua0NZv1KjaMdWc8(dwkA54FCDocAHM4rSnRW6aeivE9M6qT)5UtjjbiqQ86n1HA)ZDNu44FCDocAHgaJ(n3wH1biqQ86naP63BmkAzDacKkVEtDO2)C3PKKaeQbHwktawaHiq5FNY4OBUhBgYbB0wH1GZ6anfmhaXCtinlOj2iXQQalw2PIf)zbX2mIyj2yaklTGJgAHgw(DVyb9BMLyJbOSy5(DwqdSacrGAZIL73HRNfneFfkw(lLy5kwILgcb1l8ZIxGSOVIyzfXIL73zbnWciebILRZY9SyXXSas4gvGa5M8WFWcBuH(JiLqcqFoxvtiV8usPayoalW7pyLvH(JCGUErkzn4SoqtbZbqScG(CUQMmbWCawG3FWsrRwo(hxNJGwOjEeBZkAPU6DdcxboeyMsJGwOjLQptfnOU4sMvusI1biqQ86ni0yoVANKOU6DJQgcb1l8Bwrkux9UrvdHG6f(ndL6xHbS6Q3nbpFvWaUg)py1oj5QNMiO2Fcm3pu7FEOu)kmGvx9Uj45RcgW14)bRKKaeivE9M6qT)5UtTv0Y6aeivE9M6qT)5UtjjTC8pUohbTqdGr)MtsaHVPVMgzypt6vrM)ciCfQ2kAb0NZv1KjalGqeOmiHBuHKKaeQbHwktawaHiq5FNY4OBUhBgYbB0Un3Kh(dwyJk0FePescKMW)56SRpuvkvpYVUsa95CvnzcG5aSaV)Gvwf6p3Kh(dwyJk0FePesUk4t5)blKFDLa6Z5QAYeaZbybE)bRSk0FUjKMfRa)xQ)eMLDOfwsxHDwIngGYIpelO8RiqwIOHfmfGfi3Kh(dwyJk0FePesa6Z5QAc5LNsk54iaknBua5aD9IuIc6lctMRY6v5dIdqqQE4pyzWVp9BidHmkSEk)xkHiRPG(IWK5QSEv(G4Ta4i6DnvVbdx6mSN)Dk3HdHFdvUQMar8y2gP6H)GLXY4)UHqgfwpL)lLquZgaHuXrKwN3D8tCtinlw9vAelBVp41GIWSyzNkw(DIL(HA)z5WS4QW1ZYdzHkqKZsFOkUny5WS4QW1ZYdzHkqKZsd4IfFiw8NfeBZiILyJbOSCflEXIve0xeMqolOj2iXQQalAh)yw8c(70WcabrykGzboS0aUyXcCPbzbcKMGhXskCiw(DVyHtuUzwIngGYILDQyPbCXIf4sdwO7zz79bVguelf0c3Kh(dwyJk0FePesWVp41GIq(1vQ1vpnrqT)eyUFO2)8qP(vyaJ(jjTux9UzCGubx4CFOkUnmdL6xHbmQaOj1rgIhOt3YX)46Ce0cni1y2CBfQRE3moqQGlCUpuf3gMvu72jjTC8pUohbTqdIa6Z5QAY44iaknBuaXvx9UHc6lctzmu7JzOu)kmIaHVPVMgzypt6vrM)ciGZdL6xH4aYG24vw5MtsC8pUohbTqdIa6Z5QAY44iaknBuaXvx9UHc6lctz9Q8XmuQFfgrGW30xtJmSNj9QiZFbeW5Hs9RqCazqB8kRCZTvqb9fHjZvzVAOOL1QRE3e88vbZkkjX631u9g87JgoGgQCvnb2wrRwwhGqni0szcE(QGzfLKeGaPYR3GqJ58sH1biudcTugkncAHMSkSanRO2jjbiqQ86n1HA)ZDNAROL1biqQ86naP63BmjjwRU6DtWZxfmROKeh)JRZrql0epIT52jjTExt1BWVpA4aAOYv1eOc1vVBcE(QGzfPOL6Q3n43hnCan43dia4yMK44FCDocAHM4rSn3UDsI6Q3nbpFvWSIuyT6Q3nJdKk4cN7dvXTHzfPW631u9g87JgoGgQCvnbYnH0SaaWela4GWcZYvSyLRYhwSIG(IWelEbYc2bsSGukx3rea2sRzbahewS0HdlOj2iXQQa3Kh(dwyJk0FePeskYsofclKFDLAPU6Ddf0xeMY6v5JzOu)kC8eYOW6P8FPussRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbe4M8WFWcBuH(JiLqYUR75uiSq(1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LskAfGqni0szcE(QGzOu)kC8OT5KKaeQbHwktawaHiq5FNY4OBUhBgk1VchpABUDssRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbe4M8WFWcBuH(JiLqsFP15uiSq(1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LskAfGqni0szcE(QGzOu)kC8OT5KKaeQbHwktawaHiq5FNY4OBUhBgk1VchpABUDssRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbe4MqAwqkGwblWILai3Kh(dwyJk0FePesS4ZCWjd7zsVkIBcPzbaGjw2EF63qS8qwIgyGLnO2hwSIG(IWelWHfl7uXYvSalDdwSYv5dlwrqFryIfVazzHjwqkGwblrdmGz56SCflw5Q8HfRiOVimXn5H)Gf2Oc9hrkHe87t)gc5xxjkOVimzUkRxLpjjuqFryYGHAFYfHSpjHc6lctgVAKlczFsI6Q3nw8zo4KH9mPxfzwrkux9UHc6lctz9Q8XSIssAPU6DtWZxfmdL6xHbSh(dwglJ)7gczuy9u(VusH6Q3nbpFvWSIAZn5H)Gf2Oc9hrkHelJ)7CtE4pyHnQq)rKsizwv2d)bRS(WpYlpLuQ7A9VplUjUjKMLT3h8AqrS0HdlPqGukvplRstymll8vOyjwWyhdUjp8hSWMUR1)(Suc)(Gxdkc5xxjRNvrD4GImQU2RaLH9SR15F)kuydHERlkIa5MqAwqJJFw(DIfq4ZIL73z53jwsH4NL)sjwEiloiilR6pnl)oXsQJmwaxJ)hSy5WSSFVHLTv1VHyzOu)kmlPl9Fr6Jaz5HSK6FyNLuiS63qSaUg)pyXn5H)Gf20DT(3NfIucj4v1VHqEOrqt53hu0JvszKFDLaHVjfcR(nKzOu)kC8dL6xHrCabiKQYaeUjp8hSWMUR1)(SqKsijfcR(ne3e3esZcaatSS9(GxdkILhYccefXYkILFNyXQpKNQEfinSOU6DwUol3ZIf4sdYcHSOBiwuPoCiw6xD49RqXYVtSueYEwco(zboS8qwaxPrSOsD4qSGgybeIaXn5H)Gf2GFLWVp41GIq(1vAwf1HdkY8xkzbovgCipv9kqAu0Ic6lctMRYE1qH1TAPU6DZFPKf4uzWH8u1RaPXmuQFfoEp8hSmwg)3neYOW6P8FPeIA2OSIwuqFryYCvwf(7jjuqFryYCvgd1(KKqb9fHjJEv(KlczF7Ke1vVB(lLSaNkdoKNQEfinMHs9RWX7H)GLb)(0VHmeYOW6P8FPeIA2OSIwuqFryYCvwVkFssOG(IWKbd1(KlczFscf0xeMmE1ixeY(2TtsSwD17M)sjlWPYGd5PQxbsJzf1ojPL6Q3nbpFvWSIssa6Z5QAYeGfqicugKWnQqBfbiudcTuMaSacrGY)oLXr3Cp2mKd2qracKkVEtDO2)C3P2kAzDacKkVEdcnMZRKKaeQbHwkdLgbTqtwfwGMHs9RWXdqAROL6Q3nbpFvWSIssSoaHAqOLYe88vbZqoyJ2CtinlaamXsSb9O)asSSzXNuwSStfl)onelhMLcYIh(diXc2IpPiNfhZI2FIfhZseeJpvnXcSybBXNuwSC)olaIf4WsNSqdl43diGzboSalwCwIjIybBXNuwWqw(D)z53jwkYclyl(KYIpZbKWSGuYc)S49Ngw(D)zbBXNuwiKfDdH5M8WFWcBWpIucjoOh9hqkJT4tkYdncAk)(GIESskJ8RRK1GW34GE0FaPm2IpPzqp1rrM)ciCfkfw7H)GLXb9O)aszSfFsZGEQJImxL76d1(ROL1GW34GE0FaPm2IpP5DY1M)ciCfQKeq4BCqp6pGugBXN08o5AZqP(v44rB7Keq4BCqp6pGugBXN0mON6Oid(9acaoMkaHVXb9O)aszSfFsZGEQJImdL6xHbCmvacFJd6r)bKYyl(KMb9uhfz(lGWvO4MqAwaaycZcAGfqicelxNf0eBKyvvGLdZYkIf4Wsd4IfFiwajCJkCfkwqtSrIvvbwSC)olObwaHiqS4filnGlw8HyrL0qlSG(nZsSXauUjp8hSWg8JiLqsawaHiq5FNY4OBUhJ8RRK1GZ6anfmhaXkA1cOpNRQjtawaHiqzqc3OckSoaHAqOLYe88vbZqoydfwpRI6WbfzIMlfoGNRZ(e86c5OLg7tsI6Q3nbpFvWSIARWX)46Ce0cnawj0VzfTux9UHc6lctz9Q8XmuQFfoELBojrD17gkOVimLXqTpMHs9RWXRCZTtsuHySI(HA)ZdL6xHbSYnRW6aeQbHwktWZxfmd5GnAZnH0SGgybE)blw6WHfxRzbe(yw(D)zj1rGWSGxdXYVtnyXhQq3ZYq9HW7eilw2PIfRwhivWfMfaSHQ42GLDhZIMWyw(DVybTSGPaMLHs9RUcflWHLFNybHgZ5flQRENLdZIRcxplpKLUR1Sa7DwGdlE1GfRiOVimXYHzXvHRNLhYcHSOBiUjp8hSWg8JiLqcqFoxvtiV8usjq4Nhc9w3qPu9yKd01lsPwQRE3moqQGlCUpuf3gMHs9RWXJ2KeRvx9UzCGubx4CFOkUnmRO2kSwD17MXbsfCHZ9HQ42iJVQV059g4NMZnRifTux9UbHRahcmtPrql0Ks1NPIguxCjZqP(vyaJkaAsDK1wrl1vVBOG(IWugd1(ygk1VchpQaOj1rwsI6Q3nuqFrykRxLpMHs9RWXJkaAsDKLK0YA1vVBOG(IWuwVkFmROKeRvx9UHc6lctzmu7Jzf1wH1VRP6nyOg)xGmu5QAcSn3esZcAGf49hSy539NLWofqaZY1zPbCXIpelW1JpqIfkOVimXYdzbw6gSacFw(DAiwGdlhQcoel)(HzXY97SSb14)ce3Kh(dwyd(rKsibOpNRQjKxEkPei8ZW1Jpqktb9fHjKd01lsPwwRU6Ddf0xeMYyO2hZksH1QRE3qb9fHPSEv(ywrTtsExt1BWqn(VazOYv1ei3Kh(dwyd(rKsijfcR(neYdncAk)(GIESskJ8RR0q9HW7UQMu0sD17gkOVimLXqTpMHs9RWXpuQFfojrD17gkOVimL1RYhZqP(v44hk1VcNKa0NZv1Kbe(z46XhiLPG(IWuBfd1hcV7QAsX7dk6n)Ls5hMbpkELbKcpkh2Packa6Z5QAYac)8qO36gkLQhZn5H)Gf2GFePesWRQFdH8qJGMYVpOOhRKYi)6knuFi8URQjfTux9UHc6lctzmu7JzOu)kC8dL6xHtsux9UHc6lctz9Q8XmuQFfo(Hs9RWjja95CvnzaHFgUE8bszkOVim1wXq9HW7UQMu8(GIEZFPu(HzWJIxzaPWJYHDkGGcG(CUQMmGWppe6TUHsP6XCtE4pyHn4hrkHe8tATp5U2hc5HgbnLFFqrpwjLr(1vAO(q4DxvtkAPU6Ddf0xeMYyO2hZqP(v44hk1VcNKOU6Ddf0xeMY6v5JzOu)kC8dL6xHtsa6Z5QAYac)mC94dKYuqFryQTIH6dH3DvnP49bf9M)sP8dZGhfVYaCfEuoStbeua0NZv1Kbe(5HqV1nukvpMBcPzbaGjwaWGXHfyXsaKfl3Vdxplbpk6kuCtE4pyHn4hrkHKoCcug2ZL)RHq(1vYJYHDkGa3esZcaatSGu(kWHazzl6M7XSy5(Dw8QblAyHIfQGlu7SOD8FfkwSIG(IWelEbYYpny5HSOVIy5EwwrSy5(DwaOln2hw8cKf0eBKyvvGBYd)blSb)isjKqPrql0KvHfiYVUsTAPU6Ddf0xeMYyO2hZqP(v44vU5Ke1vVBOG(IWuwVkFmdL6xHJx5MBRiaHAqOLYe88vbZqP(v44JzZkAPU6Dt0CPWb8CD2NGxxihT0yFmaD9IamGq)MtsSEwf1HdkYenxkCapxN9j41fYrln2hdHERlkIaB3ojrD17MO5sHd456SpbVUqoAPX(ya66ffVsacX0Cssac1GqlLj45RcMHCWgkC8pUohbTqt8i2M5MqAwaayIf0eBKyvvGfl3VZcAGfqicesqkFf4qGSSfDZ9yw8cKfqyHUNfiqASm3tSaqxASpSahwSStflXsdHG6f(zXcCPbzHqw0nelQuhoelOj2iXQQaleYIUHWCtE4pyHn4hrkHeG(CUQMqE5PKsbWCawG3FWkJFKd01lsjRbN1bAkyoaIva0NZv1KjaMdWc8(dwkA1kaHAqOLYqPrngY1z4awEfiZqP(vyaRmahXGOwkRmIpRI6WbfzWx1x68Ed8tZ5TvqO36IIiqdLg1yixNHdy5vGANK44FCDocAHM4vcX2SIww)UMQ30xtJmSNj9QidvUQMatsux9Uj45RcgW14)bR4dqOgeAPm910id7zsVkYmuQFfgraK2ka6Z5QAY87ZP1zmriqt2IFVIwQRE3GWvGdbMP0iOfAsP6ZurdQlUKzfLKyDacKkVEdcnMZR2kEFqrV5Vuk)Wm4rXRU6DtWZxfmGRX)dwiEZgetsIkeJv0pu7FEOu)kmGvx9Uj45RcgW14)bRKKaeivE9M6qT)5UtjjQRE3OQHqq9c)MvKc1vVBu1qiOEHFZqP(vyaRU6DtWZxfmGRX)dwiQfIfXNvrD4GImrZLchWZ1zFcEDHC0sJ9XqO36IIiW2TvyT6Q3nbpFvWSIu0Y6aeivE9M6qT)5UtjjbiudcTuMaSacrGY)oLXr3Cp2SIssuHySI(HA)ZdL6xHbCac1GqlLjalGqeO8VtzC0n3JndL6xHreapjPFO2)8qP(vyKksvzasZawD17MGNVkyaxJ)hSAZnH0SaaWel)oXIvdQ(9gdlwUFNfNf0eBKyvvGLF3FwoCHUNL(atzbGU0yF4M8WFWcBWpIucjJdKk4cN7dvXTbYVUsQRE3e88vbZqP(v44vgTjjQRE3e88vbd4A8)GfGJzZka6Z5QAYeaZbybE)bRm(5M8WFWcBWpIucjbst4)CD21hQkLQh5xxjG(CUQMmbWCawG3FWkJFfTSwD17MGNVkyaxJ)hSIpMnNKyDacKkVEdqQ(9gt7Ke1vVBghivWfo3hQIBdZksH6Q3nJdKk4cN7dvXTHzOu)kmGrSikalW19MOHchMYU(qvPu9M)sPmqxVie1YA1vVBu1qiOEHFZksH1VRP6n43hnCanu5QAcSn3Kh(dwyd(rKsi5QGpL)hSq(1vcOpNRQjtamhGf49hSY4NBcPzXQHpNRQjwwycKfyXIRE67pcZYV7plw86z5HSOsSGDGeilD4WcAInsSQkWcgYYV7pl)o1GfFO6zXIJFcKfKsw4NfvQdhILFNs5M8WFWcBWpIucja95CvnH8YtjLWoqk3Hto45RcihORxKswhGqni0szcE(QGzihSrsI1a95CvnzcWciebkds4gvqracKkVEtDO2)C3PKeWzDGMcMdGyUjKMfaaMWSaGbTcwUolxXIxSyfb9fHjw8cKLFocZYdzrFfXY9SSIyXY97SaqxASpiNf0eBKyvvGfVazj2GE0Fajw2S4tk3Kh(dwyd(rKsiPVMgzypt6vri)6krb9fHjZvzVAOWJYHDkGGc1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbe63SIwGW34GE0FaPm2IpPzqp1rrM)ciCfQKeRdqGu51BkkmqnCaBRaOpNRQjd2bs5oCYbpFvqrl1vVBghivWfo3hQIBdZqP(vyaJybGTqlIpRI6WbfzWx1x68Ed8tZ5TvOU6DZ4aPcUW5(qvCBywrjjwRU6DZ4aPcUW5(qvCBywrT5MqAwaayIfa8f97SS9(0DTMLObgWSCDw2EF6UwZYHl09SSI4M8WFWcBWpIucj43NUR1i)6kPU6DdSOFhNJOjqr)blZksH6Q3n43NUR1MH6dH3DvnXn5H)Gf2GFePescEfiDwD17iV8usj87JgoGi)6kPU6Dd(9rdhqZqP(vyaJwfTux9UHc6lctzmu7JzOu)kC8OnjrD17gkOVimL1RYhZqP(v44rBBfo(hxNJGwOjEeBZCtinlw9vAeMLyJbOSOsD4qSGgybeIaXYcFfkw(DIf0alGqeiwcWc8(dwS8qwc7uabwUolObwaHiqSCyw8WVCTUblUkC9S8qwujwco(5M8WFWcBWpIucj43h8Aqri)6kfGaPYR3uhQ9p3DsbqFoxvtMaSacrGYGeUrfueGqni0szcWciebk)7ughDZ9yZqP(vyaJwfwdoRd0uWCaeRGc6lctMRYE1qHJ)X15iOfAIh9BMBcPzbaGjw2EF6UwZIL73zz7jT2hwS6Z1Fw8cKLcYY27JgoGiNfl7uXsbzz79P7AnlhMLveYzPbCXIpelxXIvUkFyXkc6lctS0HdlaeeHPaMf4WYdzjAGbwaOln2hwSStflUkeiXcITzwIngGYcCyXbJ8)asSGT4tkl7oMfacIWuaZYqP(vxHIf4WYHz5kw66d1(ByjoWNy539NLvbsdl)oXc2tjwcWc8(dwywUhDywaJWSu06hxZYdzz79P7AnlGR5kuSy16aPcUWSaGnuf3giNfl7uXsd4cDGSG)tRzHkqwwrSy5(DwqSnJihhXshoS87elAh)SGsdvDn2Wn5H)Gf2GFePesWVpDxRr(1v6DnvVb)Kw7tgCU(BOYv1eOcRFxt1BWVpA4aAOYv1eOc1vVBWVpDxRnd1hcV7QAsrl1vVBOG(IWuwVkFmdL6xHJhGOGc6lctMRY6v5Jc1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbeABojrD17MO5sHd456SpbVUqoAPX(ya66ffVsacTnRWX)46Ce0cnXJyBojbe(gh0J(diLXw8jnd6PokYmuQFfoEassIh(dwgh0J(diLXw8jnd6PokYCvURpu7FBfbiudcTuMGNVkygk1VchVYnZnH0SaaWelBVp41GIybaFr)olrdmGzXlqwaxPrSeBmaLfl7uXcAInsSQkWcCy53jwSAq1V3yyrD17SCywCv46z5HS0DTMfyVZcCyPbCHoqwcEelXgdq5M8WFWcBWpIucj43h8Aqri)6kPU6DdSOFhNdAYNmWdFWYSIssux9UbHRahcmtPrql0Ks1NPIguxCjZkkjrD17MGNVkywrkAPU6DZ4aPcUW5(qvCBygk1VcdyubqtQJmepqNULJ)X15iOfAqQXS52ikMi(7AQEtrwYPqyzOYv1eOcRNvrD4GIm4R6lDEVb(P5CfQRE3moqQGlCUpuf3gMvusI6Q3nbpFvWmuQFfgWOcGMuhziEGoDlh)JRZrql0GuJzZTtsux9UzCGubx4CFOkUnY4R6lDEVb(P5CZkkjPL6Q3nJdKk4cN7dvXTHzOu)kmG9WFWYGFF63qgczuy9u(VusboI068UJFcWnBq)Ke1vVBghivWfo3hQIBdZqP(vya7H)GLXY4)UHqgfwpL)lLssa6Z5QAYCOhyoalW7pyPiaHAqOLYCfomR3v1ug9wE9R0mib8cKzihSHcc9wxuebAUchM17QAkJElV(vAgKaEbQTc1vVBghivWfo3hQIBdZkkjXA1vVBghivWfo3hQIBdZksH1biudcTuMXbsfCHZ9HQ42WmKd2ijX6aeivE9gGu97nM2jjo(hxNJGwOjEeBZkOG(IWK5QSxn4MqAwIX0GLhYsQJaXYVtSOs4NfyNLT3hnCazrTbl43diCfkwUNLvelO36ciOBWYvS4vdwSIG(IWelQRNfa6sJ9HLdxplUkC9S8qwujwIgyiqGCtE4pyHn4hrkHe87dEnOiKFDLExt1BWVpA4aAOYv1eOcRNvrD4GIm)LswGtLbhYtvVcKgfTux9Ub)(OHdOzfLK44FCDocAHM4rSn3wH6Q3n43hnCan43dia4yQOL6Q3nuqFrykJHAFmROKe1vVBOG(IWuwVkFmRO2kux9UjAUu4aEUo7tWRlKJwASpgGUEragqiMMv0kaHAqOLYe88vbZqP(v44vU5KeRb6Z5QAYeGfqicugKWnQGIaeivE9M6qT)5UtT5MqAwSc8FP(tyw2HwyjDf2zj2yakl(qSGYVIazjIgwWuawGCtE4pyHn4hrkHeG(CUQMqE5PKsoocGsZgfqoqxViLOG(IWK5QSEv(G4aeKQh(dwg87t)gYqiJcRNY)LsiYAkOVimzUkRxLpiElaoIExt1BWWLod75FNYD4q43qLRQjqepMTrQE4pyzSm(VBiKrH1t5)sje1Sb9rlsfhrADE3XpHOMnOfXFxt1Bk)xdHZQU2RazOYv1ei3esZIvFLgXY27dEnOiwUIfNfedIWuGLnO2hwSIG(IWeYzbewO7zrtpl3Zs0adSaqxASpS0639NLdZYUxGAcKf1gSq3Vtdl)oXY27t31Aw0xrSahw(DILyJbOXJyBMf9velD4WY27dEnOO2iNfqyHUNfiqASm3tS4fla4l63zjAGbw8cKfn9S87elUkeiXI(kILDVa1elBVpA4aYn5H)Gf2GFePesWVp41GIq(1vY6zvuhoOiZFPKf4uzWH8u1RaPrrl1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbeIP5Ke1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbeABwX7AQEd(jT2Nm4C93qLRQjW2kArb9fHjZvzmu7Jch)JRZrql0GiG(CUQMmoocGsZgfqC1vVBOG(IWugd1(ygk1VcJiq4B6RPrg2ZKEvK5Vac48qP(vioGmOnEasZjjuqFryYCvwVkFu44FCDocAHgeb0NZv1KXXrauA2OaIRU6Ddf0xeMY6v5JzOu)kmIaHVPVMgzypt6vrM)ciGZdL6xH4aYG24rSn3wH1QRE3al63X5iAcu0FWYSIuy97AQEd(9rdhqdvUQMav0kaHAqOLYe88vbZqP(v44rmjjy4sREfO53NtRZyIqGgdvUQMavOU6DZVpNwNXeHang87beaCmJjaS1SkQdhuKbFvFPZ7nWpnNJ4OTTI(HA)ZdL6xHJx5MBwr)qT)5Hs9RWagqn3CBfTcqOgeAPmiCf4qGzC0n3JndL6xHJhXKKyDacKkVEdcnMZR2CtinlaamXcaoiSWSCflw5Q8HfRiOVimXIxGSGDGeliLY1DebGT0AwaWbHflD4WcAInsSQkWIxGSGu(kWHazXksJGwOjLQNBYd)blSb)isjKuKLCkewi)6k1sD17gkOVimL1RYhZqP(v44jKrH1t5)sPKKwHDFqryLaKIHc7(GIY)LsagTTtsc7(GIWkfZ2k8OCyNciOaOpNRQjd2bs5oCYbpFvGBYd)blSb)isjKS76EofclKFDLAPU6Ddf0xeMY6v5JzOu)kC8eYOW6P8FPKcRdqGu51BqOXCELK0sD17geUcCiWmLgbTqtkvFMkAqDXLmRifbiqQ86ni0yoVANK0kS7dkcReGumuy3huu(VucWOTDssy3huewPyMKOU6DtWZxfmRO2k8OCyNciOaOpNRQjd2bs5oCYbpFvqrl1vVBghivWfo3hQIBdZqP(vya3cTaqaH4ZQOoCqrg8v9LoV3a)0CEBfQRE3moqQGlCUpuf3gMvusI1QRE3moqQGlCUpuf3gMvuBUjp8hSWg8JiLqsFP15uiSq(1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LskSoabsLxVbHgZ5vssl1vVBq4kWHaZuAe0cnPu9zQOb1fxYSIueGaPYR3GqJ58QDssRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIzsI6Q3nbpFvWSIARWJYHDkGGcG(CUQMmyhiL7Wjh88vbfTux9UzCGubx4CFOkUnmdL6xHbmAvOU6DZ4aPcUW5(qvCBywrkSEwf1HdkYGVQV059g4NMZtsSwD17MXbsfCHZ9HQ42WSIAZnH0SaaWelifqRGfyXsaKBYd)blSb)isjKyXN5Gtg2ZKEve3esZcaatSS9(0VHy5HSenWalBqTpSyfb9fHjKZcAInsSQkWYUJzrtyml)LsS87EXIZcsX4)oleYOW6jw0u)zboSalDdwSYv5dlwrqFryILdZYkIBYd)blSb)isjKGFF63qi)6krb9fHjZvz9Q8jjHc6lctgmu7tUiK9jjuqFryY4vJCri7tsAPU6DJfFMdozypt6vrMvuscoI068UJFcWnBqF0QW6aeivE9gGu97nMKeCeP15Dh)eGB2G(kcqGu51Bas1V3yARqD17gkOVimL1RYhZkkjPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKrH1t5)sjfQRE3e88vbZkQn3esZcaatSGum(VZc83PXYHjwSSFHDwomlxXYgu7dlwrqFryc5SGMyJeRQcSahwEilrdmWIvUkFyXkc6lctCtE4pyHn4hrkHelJ)7CtinlayUw)7ZIBYd)blSb)isjKmRk7H)GvwF4h5LNsk1DT(3NL9goIc2Xr5MbK9B)22a]] )

end