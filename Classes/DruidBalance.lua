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


    spec:RegisterPack( "Balance", 20210806, [[divFXfqikPEeePUeejTjs4tqQmkPKtjLAvqO6vqiZcsXTKIu7IIFbrmma4yKOwga5zcLmniv11GuABaO8niuACsr05GqX6aq18aOUhjY(eQ6FqKi1bfQyHcf9qiQMiLKQlsjHncGWhPKuKrcrIKtsjjRukQxcrIAMus0nbqKDkuPFcGOgkashLssrTukjLEQszQcfUQue2kLKcFfIegRuKSxk1Ff1GjomvlMKESGjd0Lr2Su9ziz0kvNwLvdrI41qWSj1TfPDl53GgUqooKQSCfphQPRQRRKTdOVtjgpeLZlfwVqPMVi2pQTv2og2BG(t2XfqaaqkdGMeaamdaAs0hXaieR923iIS3I8acokYER8uYElMU2RazVf5n0qh0og2By4AcK92()ryaosqIQR9kqnn(sdgu3VVunhejX01EfOME7srossbn7FQgP09ttkP6AVcK5r2BVPUo9BvLTQ9gO)KDCbeaaKYaOjbaaZaGMe9rmasz7nF97WXEB7srU92(bcsLTQ9giHd2BX01EfiwS6Z6a5MJZc1c)SaWqdlacaaszUzUzKV7fkcdW5MBAwIdiibYYgu7dlXK8ud3CtZcY39cfbYY7dk6ZxNLGJjmlpKLqJGMYVpOOhB4MBAwSAPuiqcKLvvuGWyFAWcqFoxvtywADgYGgwIgcyg)(GxdkILMoEwIgcOb)(GxdkQTHBUPzjoaHhilrdfC8Ffkwqkg)3z56SCp6WS87elwgyHIfRiOVimz4MBAwai5iqSGCybeIaXYVtSSfDZ9ywCw03)AILu4qS01eYovnXsRRZsd4ILDhSq3ZY(9SCpl4lDPFVi4cRBWIL73zjMaKJtmybrSGCst4)CnlXrFOQuQE0WY9OdKfmcxuBd3CtZcajhbILui(zbD9d1(Nhk1VcJowWbQ85Gyw8OiDdwEilQqmML(HA)XSalDdd3CtZsmgYFwIbmLyb2zjMAFNLyQ9DwIP23zXXS4SGJOW5Aw(5keO3Wn30SaqoIkAyP1zidAybPy8FhnSGum(VJgw2EF63qTzj1bjwsHdXYq4tFu9S8qwiF0hnSeGPQ(3043N3WnZnhNQGV)eilX01EfiwIda1kzj4flQelD4QazXFw2)pcdWrcsuDTxbQPXxAWG6(9LQ5GijMU2Ra10BxkYrskOz)t1iLUFAsjvx7vGmpYE7n9HFSDmS3GrurJDmSJRY2XWEJkxvtG2X0EZd)bl7nlJ)72BGeomx0FWYEdGouWXplaIfKIX)Dw8cKfNLT3h8AqrSalw2IblwUFNL4EO2FwaiCIfVazjMW4edwGdlBVp9BiwG)onwomzVfM7P5C7TwSqb9fHjJEv(KlczpljjSqb9fHjZvzmu7dljjSqb9fHjZvzv4VZsscluqFryY4vJCri7zPnlkyjAiGgLnwg)3zrblwZs0qanaYyz8F3(TJlGSJH9gvUQMaTJP9Mh(dw2B43N(nK9wyUNMZT3SMLzvuhoOiJQR9kqzyp7AD(3Vcf2qLRQjqwssyXAwcqGu51BQd1(N7oXssclwZcoI0687dk6Xg87t31AwuIfLzjjHfRz5DnvVP8FneoR6AVcKHkxvtGSKKWslwOG(IWKbd1(KlczpljjSqb9fHjZvz9Q8HLKewOG(IWK5QSk83zjjHfkOVimz8QrUiK9S02EtFfLdG2BO1(TJBSSJH9gvUQMaTJP9Mh(dw2B43h8Aqr2BH5EAo3EBwf1HdkYO6AVcug2ZUwN)9RqHnu5QAcKffSeGaPYR3uhQ9p3DIffSGJiTo)(GIESb)(0DTMfLyrz7n9vuoaAVHw73(T3aPUV0VDmSJRY2XWEZd)bl7nmu7twL8u7nQCvnbAht73oUaYog2Bu5QAc0oM2BH5EAo3E7VuIfaZslwaeliolE4pyzSm(VBco(Z)LsSGiw8WFWYGFF63qMGJ)8FPelTT38WFWYEl4AD2d)bRS(WV9M(WFU8uYEdgrfn2VDCJLDmS3OYv1eODmT3Gr2By6T38WFWYEdOpNRQj7nGUEr2B4isRZVpOOhBWVpDxRzjEwuMffS0IfRz5DnvVb)(OHdOHkxvtGSKKWY7AQEd(jT2Nm4C93qLRQjqwAZsscl4isRZVpOOhBWVpDxRzjEwaK9giHdZf9hSS32OhZsCGwblWILyHiwSC)oC9Saox)zXlqwSC)olBVpA4aYIxGSaieXc83PXYHj7nG(KlpLS3oC2HK9Bhx03og2Bu5QAc0oM2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nCeP153hu0Jn43N(nelXZIY2BGeomx0FWYEBJEmlbn5ajwSStflBVp9BiwcEXY(9SaieXY7dk6XSyz)c7SCywgsta96zPdhw(DIfRiOVimXYdzrLyjAOondbYIxGSyz)c7S0pTMgwEilbh)2Ba9jxEkzVD4CqtoqY(TJlATJH9gvUQMaTJP9gmYEdtV9Mh(dw2Ba95CvnzVb01lYElAiGMuiS63qSKKWs0qan4v1VHyjjHLOHaAWVp41GIyjjHLOHaAWVpDxRzjjHLOHaA6RPrg2ZKEveljjSOU6DtWZxfmdL6xHzrjwux9Uj45RcgW14)blwssyjAiGMXbsfCHZ9HQy3WEdKWH5I(dw2Bwn85CvnXYV7plHDkGaMLRZsd4IfFiwUIfNfubqwEiloq4bYYVtSGVF5)blwSStdXIZYpxHa9SqFGLdZYctGSCflQ0BHOILGJFS9gqFYLNs2BxLrfaTF74cWSJH9gvUQMaTJP9Mh(dw2BQ0GPbHRqzVbs4WCr)bl7TMatSetAW0GWvOyXY97SG84GeRQcSahw8(tdlihwaHiqSCflipoiXQQG9wyUNMZT3AXslwSMLaeivE9M6qT)5UtSKKWI1SeGqni0szcWciebk)7ughDZ9yZkIL2SOGf1vVBcE(QGzOu)kmlXZIYOLffSOU6DZ4aPcUW5(qvSBygk1VcZcGzb9zrblwZsacKkVEdqQ(9gdljjSeGaPYR3aKQFVXWIcwux9Uj45RcMvelkyrD17MXbsfCHZ9HQy3WSIyrblTyrD17MXbsfCHZ9HQy3WmuQFfMfaZIYkZstZcAzbXzzwf1HdkYGVQV059g4NMZnu5QAcKLKewux9Uj45RcMHs9RWSaywuwzwssyrzwqcl4isRZ7o(jwamlkBqlAzPnlTzrbla95CvnzUkJkaA)2XfXAhd7nQCvnbAht7TWCpnNBVPU6DtWZxfmdL6xHzjEwugTSOGLwSynlZQOoCqrg8v9LoV3a)0CUHkxvtGSKKWI6Q3nJdKk4cN7dvXUHzOu)kmlaMfLrSS00SaiwqCwux9UrvdHG6f(nRiwuWI6Q3nJdKk4cN7dvXUHzfXsBwssyrfIXSOGL(HA)ZdL6xHzbWSai0AVbs4WCr)bl7nak8zXY97S4SG84GeRQcS87(ZYHl09S4SaqxASpSenWalWHfl7uXYVtS0pu7plhMfxfUEwEilubAV5H)GL9we8pyz)2XTjTJH9gvUQMaTJP9gmYEdtV9Mh(dw2Ba95CvnzVb01lYElqNMLwS0IL(HA)ZdL6xHzPPzrz0YstZsac1GqlLj45RcMHs9RWS0MfKWIYnjayPnlkXsGonlTyPfl9d1(Nhk1VcZstZIYOLLMMLaeQbHwktawaHiq5FNY4OBUhBaxJ)hSyPPzjaHAqOLYeGfqicu(3Pmo6M7XMHs9RWS0MfKWIYnjayPnlkyXAwg)aZeqQEJdcIneYo8JzjjHLaeQbHwktWZxfmdL6xHzjEwU6PjcQ9NaZ9d1(Nhk1VcZssclZQOoCqrMaPj8FUoJJU5ESHkxvtGSOGLaeQbHwktWZxfmdL6xHzjEwIfayjjHLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SC1tteu7pbM7hQ9ppuQFfMLMMfLbaljjSynlbiqQ86n1HA)ZDNS3ajCyUO)GL9gYDDyP9NWSyzN(DAyzHVcflihwaHiqSuqlSy50AwCTgAHLgWflpKf8FAnlbh)S87elypLyXtHR6zb2zb5WciebcripoiXQQalbh)y7nG(KlpLS3cWciebkds4gvW(TJlIXog2Bu5QAc0oM2BWi7nm92BE4pyzVb0NZv1K9gqxVi7TwS0pu7FEOu)kmlXZIYOLLKewg)aZeqQEJdcInxXs8SGwaWsBwuWslwAXslwi0BDrreOHsJAmKRZWbS8kqSOGLwSeGqni0szO0Ogd56mCalVcKzOu)kmlaMfLbyaGLKewcqGu51Bas1V3yyrblbiudcTugknQXqUodhWYRazgk1VcZcGzrzagILfeXslwuwzwqCwMvrD4GIm4R6lDEVb(P5CdvUQMazPnlTzrblwZsac1GqlLHsJAmKRZWbS8kqMHCWgS0MLKewi0BDrreObdxAn9)vOYZsTblkyPflwZsacKkVEtDO2)C3jwssyjaHAqOLYGHlTM()ku5zP2ihl0hTnjau2muQFfMfaZIYkJ(S0MLKewAXsac1GqlLrLgmniCfkZqoydwssyXAwgpqMFGAnlTzrblTyPfle6TUOic0CfomR3v1ug9wE9R0mib8celkyPflbiudcTuMRWHz9UQMYO3YRFLMbjGxGmd5GnyjjHfp8hSmxHdZ6DvnLrVLx)kndsaVazapSRQjqwAZsBwssyPfle6TUOic0G3DqOfcmdh1mSNF4Ks1ZIcwcqOgeAPmpCsP6jW8v4d1(NJfArBSaKYMHs9RWS0MLKewAXslwa6Z5QAYaR8ct5FUcb6zrjwuMLKewa6Z5QAYaR8ct5FUcb6zrjwIflTzrblTy5NRqGEZRSzihSroaHAqOLILKew(5keO38kBcqOgeAPmdL6xHzjEwU6PjcQ9NaZ9d1(Nhk1VcZstZIYaGL2SKKWcqFoxvtgyLxyk)ZviqplkXcGyrblTy5NRqGEZdiZqoyJCac1GqlfljjS8ZviqV5bKjaHAqOLYmuQFfML4z5QNMiO2Fcm3pu7FEOu)kmlnnlkdawAZsscla95CvnzGvEHP8pxHa9SOelaGL2S0ML2SKKWsacKkVEdcnMZlwAZssclQqmMffS0pu7FEOu)kmlaMf1vVBcE(QGbCn(FWYEdKWH5I(dw2BnbMaz5HSasAVbl)oXYc7OiwGDwqECqIvvbwSStfll8vOybeUu1elWILfMyXlqwIgcivpllSJIyXYovS4floiileqQEwomlUkC9S8qwapYEdOp5Ytj7TayoalW7pyz)2Xvzayhd7nQCvnbAht7nyK9gME7np8hSS3a6Z5QAYEdORxK9M1SGHlT6vGMFFoToJjcbAmu5QAcKLKew6hQ9ppuQFfML4zbqaaaSKKWIkeJzrbl9d1(Nhk1VcZcGzbqOLfeXslwqFaWstZI6Q3n)(CADgtec0yWVhqGfeNfaXsBwssyrD17MFFoToJjcbAm43diWs8SeRMKLMMLwSmRI6WbfzWx1x68Ed8tZ5gQCvnbYcIZcAzPT9giHdZf9hSS3SA4Z5QAILfMaz5HSasAVblE1GLFUcb6XS4filbqmlw2PIfl(9xHILoCyXlwSIv0oCoNLObgS3a6tU8uYE73NtRZyIqGMSf)E73oUkRSDmS3OYv1eODmT3ajCyUO)GL9wtGjwSI0Ogd5AwaipGLxbIfabamfWSOsD4qS4SG84GeRQcSSWKXER8uYEJsJAmKRZWbS8kq2BH5EAo3ElaHAqOLYe88vbZqP(vywamlacaSOGLaeQbHwktawaHiq5FNY4OBUhBgk1VcZcGzbqaGffS0IfG(CUQMm)(CADgtec0KT43ZssclQRE387ZP1zmriqJb)EabwINLybawqelTyzwf1HdkYGVQV059g4NMZnu5QAcKfeNfaglTzPnlkybOpNRQjZvzubqwssyrfIXSOGL(HA)ZdL6xHzbWSeleR9Mh(dw2BuAuJHCDgoGLxbY(TJRYaYog2Bu5QAc0oM2BGeomx0FWYERjWelBWLwt)vOyXQDP2GfagMcywuPoCiwCwqECqIvvbwwyYyVvEkzVHHlTM()ku5zP2WElm3tZ52BTyjaHAqOLYe88vbZqP(vywamlamwuWI1SeGaPYR3aKQFVXWIcwSMLaeivE9M6qT)5UtSKKWsacKkVEtDO2)C3jwuWsac1GqlLjalGqeO8VtzC0n3JndL6xHzbWSaWyrblTybOpNRQjtawaHiqzqc3OcSKKWsac1GqlLj45RcMHs9RWSaywayS0MLKewcqGu51Bas1V3yyrblTyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazrblbiudcTuMGNVkygk1VcZcGzbGXssclQRE3moqQGlCUpuf7gMHs9RWSaywug9zbrS0If0YcIZcHERlkIanxH)zfE4GZGhWROSkP1S0MffSOU6DZ4aPcUW5(qvSBywrS0MLKew6hQ9ppuQFfMfaZcGqlljjSqO36IIiqdLg1yixNHdy5vGyrblbiudcTugknQXqUodhWYRazgk1VcZs8SaiaWsBwuWcqFoxvtMRYOcGSOGfRzHqV1ffrGMRWHz9UQMYO3YRFLMbjGxGyjjHLaeQbHwkZv4WSExvtz0B51VsZGeWlqMHs9RWSeplacaSKKWIkeJzrbl9d1(Nhk1VcZcGzbqaWEZd)bl7nmCP10)xHkpl1g2VDCvow2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVPU6DtWZxfmdL6xHzjEwugTSOGLwSynlZQOoCqrg8v9LoV3a)0CUHkxvtGSKKWI6Q3nJdKk4cN7dvXUHzOu)kmlawjwugqgaXcIyPflXIfeNf1vVBu1qiOEHFZkIL2SGiwAXstYstZcAzbXzrD17gvnecQx43SIyPnliole6TUOic0Cf(Nv4HdodEaVIYQKwZsBwuWI6Q3nJdKk4cN7dvXUHzfXssclQqmMffS0pu7FEOu)kmlaMfaHwwssyHqV1ffrGgknQXqUodhWYRaXIcwcqOgeAPmuAuJHCDgoGLxbYmuQFf2EdKWH5I(dw2BXrBXBGzzHjwSkRMT6Sy5(DwqECqIvvb7nG(KlpLS3o0dmhGf49hSSF74Qm6Bhd7nQCvnbAht7np8hSS3UchM17QAkJElV(vAgKaEbYElm3tZ52Ba95Cvnzo0dmhGf49hSyrbla95CvnzUkJkaAVvEkzVDfomR3v1ug9wE9R0mib8cK9BhxLrRDmS3OYv1eODmT3ajCyUO)GL9wtGjwMd1(ZIk1HdXsaeBVvEkzVH3DqOfcmdh1mSNF4Ks1BVfM7P5C7TwSeGqni0szcE(QGzihSblkyXAwcqGu51BQd1(N7oXIcwa6Z5QAY87ZP1zmriqt2IFpljjSeGaPYR3uhQ9p3DIffSeGqni0szcWciebk)7ughDZ9yZqoydwuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcE(QGzihSblTzPnlkybe(g8Q63qM)ciCfkwuWslwaHVb)Kw7tUR9Hm)fq4kuSKKWI1S8UMQ3GFsR9j31(qgQCvnbYsscl4isRZVpOOhBWVp9BiwINLyXsBwuWslwaHVjfcR(nK5VacxHIL2SOGLwSa0NZv1K5WzhsSKKWYSkQdhuKr11EfOmSNDTo)7xHcBOYv1eiljjS44FCDocAHgwIxjwqmaGLKewux9UrvdHG6f(nRiwAZIcwAXsac1GqlLrLgmniCfkZqoydwssyXAwgpqMFGAnlTzrblwZcHERlkIanxHdZ6DvnLrVLx)kndsaVaXsscle6TUOic0CfomR3v1ug9wE9R0mib8celkyPflbiudcTuMRWHz9UQMYO3YRFLMbjGxGmdL6xHzjEwIfayjjHLaeQbHwkJknyAq4kuMHs9RWSeplXcaS0MffSynlQRE3e88vbZkILKewuHymlkyPFO2)8qP(vywamlOpaS38WFWYEdV7GqleygoQzyp)WjLQ3(TJRYam7yyVrLRQjq7yAVbs4WCr)bl7TySFywomlolJ)70WcPDv44pXIfVblpKLuhbIfxRzbwSSWel43Fw(5keOhZYdzrLyrFfbYYkIfl3VZcYJdsSQkWIxGSGCybeIaXIxGSSWel)oXcGkqwWA4ZcSyjaYY1zrf(7S8ZviqpMfFiwGfllmXc(9NLFUcb6X2BH5EAo3ERfla95CvnzGvEHP8pxHa9SyTsSOmlkyXAw(5keO38aYmKd2ihGqni0sXssclTybOpNRQjdSYlmL)5keONfLyrzwssybOpNRQjdSYlmL)5keONfLyjwS0MffS0If1vVBcE(QGzfXIcwAXI1SeGaPYR3aKQFVXWssclQRE3moqQGlCUpuf7gMHs9RWSGiwAXcAzbXzzwf1HdkYGVQV059g4NMZnu5QAcKL2SayLy5NRqGEZRSrD17zW14)blwuWI6Q3nJdKk4cN7dvXUHzfXssclQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzfXsBwssyjaHAqOLYe88vbZqP(vywqelaIL4z5NRqGEZRSjaHAqOLYaUg)pyXIcwSMf1vVBcE(QGzfXIcwAXI1SeGaPYR3uhQ9p3DILKewSMfG(CUQMmbybeIaLbjCJkWsBwuWI1SeGaPYR3GqJ58ILKewcqGu51BQd1(N7oXIcwa6Z5QAYeGfqicugKWnQalkyjaHAqOLYeGfqicu(3Pmo6M7XMvelkyXAwcqOgeAPmbpFvWSIyrblTyPflQRE3qb9fHPSEv(ygk1VcZs8SOmayjjHf1vVBOG(IWugd1(ygk1VcZs8SOmayPnlkyXAwMvrD4GImQU2RaLH9SR15F)kuydvUQMazjjHLwSOU6DJQR9kqzyp7AD(3Vcfox(VgYGFpGalkXcAzjjHf1vVBuDTxbkd7zxRZ)(vOWzFcErg87beyrjwAswAZsBwssyrD17geUcCiWmLgbTqtkvFMkAqDXMmRiwAZsscl9d1(Nhk1VcZcGzbqaGLKewa6Z5QAYaR8ct5FUcb6zrjwaalTzrbla95CvnzUkJkaAVH1WhBV9ZviqVY2BE4pyzV9ZviqVY2VDCvgXAhd7nQCvnbAht7np8hSS3(5keOhq2BH5EAo3ERfla95CvnzGvEHP8pxHa9SyTsSaiwuWI1S8ZviqV5v2mKd2ihGqni0sXsscla95CvnzGvEHP8pxHa9SOelaIffS0If1vVBcE(QGzfXIcwAXI1SeGaPYR3aKQFVXWssclQRE3moqQGlCUpuf7gMHs9RWSGiwAXcAzbXzzwf1HdkYGVQV059g4NMZnu5QAcKL2SayLy5NRqGEZdiJ6Q3ZGRX)dwSOGf1vVBghivWfo3hQIDdZkILKewux9UzCGubx4CFOk2nY4R6lDEVb(P5CZkIL2SKKWsac1GqlLj45RcMHs9RWSGiwaelXZYpxHa9MhqMaeQbHwkd4A8)GflkyXAwux9Uj45RcMvelkyPflwZsacKkVEtDO2)C3jwssyXAwa6Z5QAYeGfqicugKWnQalTzrblwZsacKkVEdcnMZlwuWslwSMf1vVBcE(QGzfXssclwZsacKkVEdqQ(9gdlTzjjHLaeivE9M6qT)5UtSOGfG(CUQMmbybeIaLbjCJkWIcwcqOgeAPmbybeIaL)DkJJU5ESzfXIcwSMLaeQbHwktWZxfmRiwuWslwAXI6Q3nuqFrykRxLpMHs9RWSeplkdawssyrD17gkOVimLXqTpMHs9RWSeplkdawAZIcwSMLzvuhoOiJQR9kqzyp7AD(3Vcf2qLRQjqwssyPflQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWIsSGwwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwuILMKL2S0ML2SKKWI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrSKKWIkeJzrbl9d1(Nhk1VcZcGzbqaGLKewa6Z5QAYaR8ct5FUcb6zrjwaalTzrbla95CvnzUkJkaAVH1WhBV9ZviqpGSF74QCtAhd7nQCvnbAht7nqchMl6pyzV1eycZIR1Sa)DAybwSSWel3tPywGflbq7np8hSS3wykFpLITF74QmIXog2Bu5QAc0oM2BGeomx0FWYEZQtHdKyXd)blw0h(zr1XeilWIf89l)pyHenH6W2BE4pyzVnRk7H)GvwF43Ed)ZfE74QS9wyUNMZT3a6Z5QAYC4Sdj7n9H)C5PK9Mdj73oUaca2XWEJkxvtG2X0Elm3tZ52BZQOoCqrgvx7vGYWE2168VFfkSHqV1ffrG2B4FUWBhxLT38WFWYEBwv2d)bRS(WV9M(WFU8uYEtf6V9BhxaPSDmS3OYv1eODmT38WFWYEBwv2d)bRS(WV9M(WFU8uYEd)2V9BVPc93og2Xvz7yyVrLRQjq7yAV5H)GL924aPcUW5(qvSByVbs4WCr)bl7naIHQy3Gfl3VZcYJdsSQkyVfM7P5C7n1vVBcE(QGzOu)kmlXZIYO1(TJlGSJH9gvUQMaTJP9Mh(dw2BoOh9hqkJT4tQ9wOrqt53hu0JTJRY2BH5EAo3EtD17gvx7vGYWE2168VFfkCU8FnKb)EabwamlnjlkyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwamlnjlkyPflwZci8noOh9hqkJT4tAg0tDuK5VacxHIffSynlE4pyzCqp6pGugBXN0mON6OiZv5U(qT)SOGLwSynlGW34GE0FaPm2IpP5DY1M)ciCfkwssybe(gh0J(diLXw8jnVtU2muQFfML4zjwS0MLKewaHVXb9O)aszSfFsZGEQJIm43diWcGzjwSOGfq4BCqp6pGugBXN0mON6OiZqP(vywamlOLffSacFJd6r)bKYyl(KMb9uhfz(lGWvOyPT9giHdZf9hSS3AcmXsCa9O)asSSzXNuwSStfl(ZIMWyw(DVyb9zjMW4edwWVhqaZIxGS8qwgQpeENfNfaReGyb)EabwCmlA)jwCmlrqm(u1elWHL)sjwUNfmKL7zXN5asywqkzHFw8(tdlolXcrSGFpGaleYIUHW2VDCJLDmS3OYv1eODmT38WFWYElalGqeO8VtzC0n3JT3ajCyUO)GL9wtGjwqoSacrGyXY97SG84GeRQcSyzNkwIGy8PQjw8cKf4VtJLdtSy5(DwCwIjmoXGf1vVZILDQybKWnQWvOS3cZ90CU9M1SaoRd0uWCaeZIcwAXslwa6Z5QAYeGfqicugKWnQalkyXAwcqOgeAPmbpFvWmKd2GLKewux9Uj45RcMvelTzrblTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwuILMKLKewux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqGfLyPjzPnljjSOcXywuWs)qT)5Hs9RWSaywugaS02(TJl6Bhd7nQCvnbAht7np8hSS36RPrg2ZKEvK9giHdZf9hSS3aiGwbloMLFNyPFd(zbvaKLRy53jwCwIjmoXGflxbcTWcCyXY97S87eliLBmNxSOU6DwGdlwUFNfNLMerykWsCa9O)asSSzXNuw8cKfl(9S0HdlipoiXQQalxNL7zXcSEwujwwrS4O8RyrL6WHy53jwcGSCyw6xD4Dc0Elm3tZ52BTyPflTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwINfagljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGalXZcaJL2SOGLwSynlbiqQ86naP63BmSKKWI1SOU6DZ4aPcUW5(qvSBywrS0ML2SOGLwSaoRd0uWCaeZssclbiudcTuMGNVkygk1VcZs8SGwaWssclTyjabsLxVPou7FU7elkyjaHAqOLYeGfqicu(3Pmo6M7XMHs9RWSeplOfaS0ML2S0MLKewAXci8noOh9hqkJT4tAg0tDuKzOu)kmlXZstYIcwcqOgeAPmbpFvWmuQFfML4zrzaWIcwcqGu51BkkmqnCazPnljjSC1tteu7pbM7hQ9ppuQFfMfaZstYIcwSMLaeQbHwktWZxfmd5GnyjjHLaeivE9geAmNxSOGf1vVBq4kWHaZuAe0cnPu9MveljjSeGaPYR3aKQFVXWIcwux9UzCGubx4CFOk2nmdL6xHzbWSGyyrblQRE3moqQGlCUpuf7gMvK9Bhx0Ahd7nQCvnbAht7np8hSS3cEfiDwD172BH5EAo3ERflQRE3O6AVcug2ZUwN)9RqHZL)RHmdL6xHzjEwqSg0YssclQRE3O6AVcug2ZUwN)9RqHZ(e8ImdL6xHzjEwqSg0YsBwuWslwcqOgeAPmbpFvWmuQFfML4zbXYssclTyjaHAqOLYqPrql0KvHfOzOu)kmlXZcILffSynlQRE3GWvGdbMP0iOfAsP6ZurdQl2KzfXIcwcqGu51BqOXCEXsBwAZIcwC8pUohbTqdlXRelXca2BQREpxEkzVHFF0Wb0EdKWH5I(dw2Bi3RaPzz79rdhqwSC)ololfzHLycJtmyrD17S4filipoiXQQalhUq3ZIRcxplpKfvILfMaTF74cWSJH9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYEZQVsJyz79bVgueMfl3VZIZsmHXjgSOU6Dwuxplf8zXYovSebH6RqXshoSG84GeRQcSahwqkFf4qGSSfDZ9y7TWCpnNBV1If1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87beyjEwaeljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGalXZcGyPnlkyPflbiqQ86n1HA)ZDNyjjHLaeQbHwktWZxfmdL6xHzjEwqSSKKWI1Sa0NZv1KjaMdWc8(dwSOGfRzjabsLxVbHgZ5fljjS0ILaeQbHwkdLgbTqtwfwGMHs9RWSepliwwuWI1SOU6DdcxboeyMsJGwOjLQptfnOUytMvelkyjabsLxVbHgZ5flTzPnlkyPflwZci8n910id7zsVkY8xaHRqXssclwZsac1GqlLj45RcMHCWgSKKWI1SeGqni0szcWciebk)7ughDZ9yZqoydwAB)2XfXAhd7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9MvFLgXY27dEnOimlQuhoelihwaHiq2BH5EAo3ERflbiudcTuMaSacrGY)oLXr3Cp2muQFfMfaZcAzrblwZc4SoqtbZbqmlkyPfla95CvnzcWciebkds4gvGLKewcqOgeAPmbpFvWmuQFfMfaZcAzPnlkybOpNRQjtamhGf49hSyPnlkyXAwaHVPVMgzypt6vrM)ciCfkwuWsacKkVEtDO2)C3jwuWI1SaoRd0uWCaeZIcwOG(IWK5QSxnyrblo(hxNJGwOHL4zb9bG9Bh3M0og2Bu5QAc0oM2BWi7nm92BE4pyzVb0NZv1K9gqxVi7TwSOU6DZ4aPcUW5(qvSBygk1VcZs8SGwwssyXAwux9UzCGubx4CFOk2nmRiwAZIcwAXI6Q3niCf4qGzkncAHMuQ(mv0G6Inzgk1VcZcGzbva0K6iJL2SOGLwSOU6Ddf0xeMYyO2hZqP(vywINfubqtQJmwssyrD17gkOVimL1RYhZqP(vywINfubqtQJmwABVbs4WCr)bl7nRoSq3Zci8zbCnxHILFNyHkqwGDwSADGubxywaigQIDd0Wc4AUcfliCf4qGSqPrql0Ks1ZcCy5kw(DIfTJFwqfazb2zXlwSIG(IWK9gqFYLNs2BGWppe6TUHsP6X2VDCrm2XWEJkxvtG2X0EZd)bl7n8Q63q2BH5EAo3EBO(q4DxvtSOGL3hu0B(lLYpmdEelXZIYamwuWIhLd7uabwuWcqFoxvtgq4Nhc9w3qPu9y7TqJGMYVpOOhBhxLTF74QmaSJH9gvUQMaTJP9Mh(dw2BPqy1VHS3cZ90CU92q9HW7UQMyrblVpOO38xkLFyg8iwINfLJLbTSOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2oUkB)2XvzLTJH9gvUQMaTJP9Mh(dw2B4N0AFYDTpK9wyUNMZT3gQpeE3v1elky59bf9M)sP8dZGhXs8SOmaJfeXYqP(vywuWIhLd7uabwuWcqFoxvtgq4Nhc9w3qPu9y7TqJGMYVpOOhBhxLTF74QmGSJH9gvUQMaTJP9Mh(dw2BD4eOmSNl)xdzVbs4WCr)bl7nacyCzbwSeazXY97W1ZsWJIUcL9wyUNMZT38OCyNciy)2Xv5yzhd7nQCvnbAht7np8hSS3O0iOfAYQWc0EdKWH5I(dw2BwrAe0cnSetybYILDQyXvHRNLhYcvpnS4SuKfwIjmoXGflxbcTWIxGSGDGelD4WcYJdsSQkyVfM7P5C7TwSqb9fHjJEv(KlczpljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczpljjSOU6DJQR9kqzyp7AD(3Vcfox(VgYmuQFfML4zbXAqlljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYmuQFfML4zbXAqlljjS44FCDocAHgwINfedayrblbiudcTuMGNVkygYbBWIcwSMfWzDGMcMdGywAZIcwAXsac1GqlLj45RcMHs9RWSeplXcaSKKWsac1GqlLj45RcMHCWgS0MLKewU6PjcQ9NaZ9d1(Nhk1VcZcGzrzay)2Xvz03og2Bu5QAc0oM2BE4pyzV1xtJmSNj9Qi7nqchMl6pyzVbqaTcwMd1(ZIk1HdXYcFfkwqECS3cZ90CU9wac1GqlLj45RcMHCWgSOGfG(CUQMmbWCawG3FWIffS0Ifh)JRZrql0Ws8SGyaalkyXAwcqGu51BQd1(N7oXssclbiqQ86n1HA)ZDNyrblo(hxNJGwOHfaZc6dawAZIcwSMLaeivE9gGu97ngwuWslwSMLaeivE9M6qT)5UtSKKWsac1GqlLjalGqeO8VtzC0n3Jnd5GnyPnlkyXAwaN1bAkyoaITF74QmATJH9gvUQMaTJP9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEZAwaN1bAkyoaIzrbla95CvnzcG5aSaV)GflkyPflTyXX)46Ce0cnSepligaWIcwAXI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrSKKWI1SeGaPYR3GqJ58IL2SKKWI6Q3nQAieuVWVzfXIcwux9UrvdHG6f(ndL6xHzbWSOU6DtWZxfmGRX)dwS0MLKewU6PjcQ9NaZ9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyjjHLaeivE9M6qT)5UtS0MffS0IfRzjabsLxVPou7FU7eljjS0Ifh)JRZrql0WcGzb9baljjSacFtFnnYWEM0RIm)fq4kuS0MffS0IfG(CUQMmbybeIaLbjCJkWssclbiudcTuMaSacrGY)oLXr3Cp2mKd2GL2S02EdKWH5I(dw2BipoiXQQalw2PIf)zbXaaeXsCWauwAbhn0cnS87EXc6dawIdgGYIL73zb5WciebQnlwUFhUEw0q8vOy5VuILRyjMAieuVWplEbYI(kILvelwUFNfKdlGqeiwUol3ZIfhZciHBubc0EdOp5Ytj7TayoalW7pyLvH(B)2XvzaMDmS3OYv1eODmT3cZ90CU9gqFoxvtMayoalW7pyLvH(BV5H)GL9wG0e(pxND9HQsP6TF74QmI1og2Bu5QAc0oM2BH5EAo3EdOpNRQjtamhGf49hSYQq)T38WFWYE7QGpL)hSSF74QCtAhd7nQCvnbAht7nyK9gME7np8hSS3a6Z5QAYEdORxK9gf0xeMmxL1RYhwqCwAswqclE4pyzWVp9BidHmkSEk)xkXcIyXAwOG(IWK5QSEv(WcIZslwaySGiwExt1BWWLod75FNYD4q43qLRQjqwqCwIflTzbjS4H)GLXY4)UHqgfwpL)lLybrSaadGybjSGJiToV74NS3ajCyUO)GL9MvG)l1FcZYo0clPRWolXbdqzXhIfu(veilr0WcMcWc0EdOp5Ytj7nhhbqPzJc2VDCvgXyhd7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9MvFLgXY27dEnOimlw2PILFNyPFO2FwomlUkC9S8qwOcenS0hQIDdwomlUkC9S8qwOcenS0aUyXhIf)zbXaaeXsCWauwUIfVyXkc6lctOHfKhhKyvvGfTJFmlEb)DAyPjreMcywGdlnGlwSaxAqwGaPj4rSKchILF3lw4eLbalXbdqzXYovS0aUyXcCPbl09SS9(GxdkILcAXElm3tZ52BTy5QNMiO2Fcm3pu7FEOu)kmlaMf0NLKewAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMfubqtQJmwqCwc0PzPflo(hxNJGwOHfKWsSaalTzrblQRE3moqQGlCUpuf7gMvelTzPnljjS0Ifh)JRZrql0WcIybOpNRQjJJJaO0SrbwqCwux9UHc6lctzmu7JzOu)kmliIfq4B6RPrg2ZKEvK5Vac48qP(vSG4SaidAzjEwuwzaWssclo(hxNJGwOHfeXcqFoxvtghhbqPzJcSG4SOU6Ddf0xeMY6v5JzOu)kmliIfq4B6RPrg2ZKEvK5Vac48qP(vSG4SaidAzjEwuwzaWsBwuWcf0xeMmxL9QblkyPflwZI6Q3nbpFvWSIyjjHfRz5DnvVb)(OHdOHkxvtGS0MffS0ILwSynlbiudcTuMGNVkywrSKKWsacKkVEdcnMZlwuWI1SeGqni0szO0iOfAYQWc0SIyPnljjSeGaPYR3uhQ9p3DIL2SOGLwSynlbiqQ86naP63BmSKKWI1SOU6DtWZxfmRiwssyXX)46Ce0cnSepligaWsBwssyPflVRP6n43hnCanu5QAcKffSOU6DtWZxfmRiwuWslwux9Ub)(OHdOb)EabwamlXILKewC8pUohbTqdlXZcIbaS0ML2SKKWI6Q3nbpFvWSIyrblwZI6Q3nJdKk4cN7dvXUHzfXIcwSML31u9g87JgoGgQCvnbA)2XfqaWog2Bu5QAc0oM2BE4pyzVvKLCkew2BGeomx0FWYERjWelaKGWcZYvSyLRYhwSIG(IWelEbYc2bsSGukx3reaXsRzbGeewS0HdlipoiXQQG9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYOW6P8FPeljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyXsBwuWIhLd7uab73oUasz7yyVrLRQjq7yAVfM7P5C7TwSOU6Ddf0xeMY6v5JzOu)kmlXZcHmkSEk)xkXIcwAXsac1GqlLj45RcMHs9RWSeplOfaSKKWsac1GqlLjalGqeO8VtzC0n3JndL6xHzjEwqlayPnljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyXsBwuWIhLd7uab7np8hSS32DDpNcHL9Bhxabi7yyVrLRQjq7yAVfM7P5C7TwSOU6Ddf0xeMY6v5JzOu)kmlXZcHmkSEk)xkXIcwAXsac1GqlLj45RcMHs9RWSeplOfaSKKWsac1GqlLjalGqeO8VtzC0n3JndL6xHzjEwqlayPnljjS0ILWUpOimlkXcGyrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyXsBwuWIhLd7uab7np8hSS36lToNcHL9Bhxafl7yyVrLRQjq7yAVbs4WCr)bl7nKcOvWcSyjaAV5H)GL9MfFMdozypt6vr2VDCbe6Bhd7nQCvnbAht7np8hSS3WVp9Bi7nqchMl6pyzV1eyILT3N(nelpKLObgyzdQ9HfRiOVimXcCyXYovSCflWs3GfRCv(WIve0xeMyXlqwwyIfKcOvWs0adywUolxXIvUkFyXkc6lct2BH5EAo3EJc6lctMRY6v5dljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczpljjSOU6DJfFMdozypt6vrMvelkyrD17gkOVimL1RYhZkILKewAXI6Q3nbpFvWmuQFfMfaZIh(dwglJ)7gczuy9u(VuIffSOU6DtWZxfmRiwAB)2XfqO1og2BE4pyzVzz8F3EJkxvtG2X0(TJlGay2XWEJkxvtG2X0EZd)bl7Tzvzp8hSY6d)2B6d)5Ytj7TUR1)(SSF73EZHKDmSJRY2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzV1If1vVB(lLSaNkdoKNQEfinMHs9RWSaywqfanPoYybrSaaJYSKKWI6Q3n)LswGtLbhYtvVcKgZqP(vywamlE4pyzWVp9BidHmkSEk)xkXcIybagLzrblTyHc6lctMRY6v5dljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczplTzPnlkyrD17M)sjlWPYGd5PQxbsJzfXIcwMvrD4GIm)LswGtLbhYtvVcKgdvUQMaT3ajCyUO)GL9gYDDyP9NWSyzN(DAy53jwS6d5Pb)d70WI6Q3zXYP1S0DTMfyVZIL73VILFNyPiK9SeC8BVb0NC5PK9g4qEA2YP15UR1zyVB)2Xfq2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVznluqFryYCvgd1(WIcwAXcoI0687dk6Xg87t)gIL4zbTSOGL31u9gmCPZWE(3PChoe(nu5QAcKLKewWrKwNFFqrp2GFF63qSepliwwABVbs4WCr)bl7nK76Ws7pHzXYo970WY27dEnOiwomlwGZVZsWX)vOybcKgw2EF63qSCflw5Q8HfRiOVimzVb0NC5PK92HQGdLXVp41GISF74gl7yyVrLRQjq7yAV5H)GL9wawaHiq5FNY4OBUhBVbs4WCr)bl7TMatSGCybeIaXILDQyXFw0egZYV7flOfaSehmaLfVazrFfXYkIfl3VZcYJdsSQkyVfM7P5C7nRzbCwhOPG5aiMffS0ILwSa0NZv1KjalGqeOmiHBubwuWI1SeGqni0szcE(QGzihSbljjSOU6DtWZxfmRiwAZIcwAXI6Q3nuqFrykRxLpMHs9RWSeplamwssyrD17gkOVimLXqTpMHs9RWSeplamwAZIcwAXI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYssclQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWs8SelwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwINLyXsBwssyrfIXSOGL(HA)ZdL6xHzbWSOmayrblwZsac1GqlLj45RcMHCWgS02(TJl6Bhd7nQCvnbAht7np8hSS3ghivWfo3hQIDd7nqchMl6pyzV1eyIfaIHQy3Gfl3VZcYJdsSQkyVfM7P5C7n1vVBcE(QGzOu)kmlXZIYO1(TJlATJH9gvUQMaTJP9Mh(dw2B4v1VHS3cncAk)(GIESDCv2Elm3tZ52BTyzO(q4DxvtSKKWI6Q3nuqFrykJHAFmdL6xHzbWSelwuWcf0xeMmxLXqTpSOGLHs9RWSaywug9zrblVRP6ny4sNH98Vt5oCi8BOYv1eilTzrblVpOO38xkLFyg8iwINfLrFwAAwWrKwNFFqrpMfeXYqP(vywuWslwOG(IWK5QSxnyjjHLHs9RWSaywqfanPoYyPT9giHdZf9hSS3AcmXY2Q63qSCflrEbsPxGfyXIxn(9RqXYV7pl6diHzrz0htbmlEbYIMWywSC)olPWHy59bf9yw8cKf)z53jwOcKfyNfNLnO2hwSIG(IWel(ZIYOplykGzboSOjmMLHs9RUcfloMLhYsbFw2DGxHILhYYq9HW7SaUMRqXIvUkFyXkc6lct2VDCby2XWEJkxvtG2X0EZd)bl7n8Q63q2BGeomx0FWYERjWelBRQFdXYdzz3bsS4SGsdvDnlpKLfMyXQSA2QBVfM7P5C7nG(CUQMmh6bMdWc8(dwSOGLaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgSOGfc9wxuebAUchM17QAkJElV(vAgKaEbY(TJlI1og2Bu5QAc0oM2BH5EAo3EZAwExt1BWpP1(KbNR)gQCvnbYIcwAXI6Q3n43NUR1MH6dH3DvnXIcwAXcoI0687dk6Xg87t31AwamlXILKewSMLzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwAZssclVRP6ny4sNH98Vt5oCi8BOYv1eilkyrD17gkOVimLXqTpMHs9RWSaywIflkyHc6lctMRYyO2hwuWI6Q3n43NUR1MHs9RWSaywqSSOGfCeP153hu0Jn43NUR1SeVsSG(S0MffS0IfRzzwf1HdkYOBe8XX5UMO)kuzu6lnctgQCvnbYsscl)LsSGuzb9rllXZI6Q3n43NUR1MHs9RWSGiwaelTzrblVpOO38xkLFyg8iwINf0AV5H)GL9g(9P7AT9Bh3M0og2Bu5QAc0oM2BE4pyzVHFF6UwBVbs4WCr)bl7nKI73zz7jT2hwS6Z1FwwyIfyXsaKfl7uXYq9HW7UQMyrD9SG)tRzXIFplD4WIv2i4JJzjAGbw8cKfqyHUNLfMyrL6WHyb5wDSHLT)0AwwyIfvQdhIfKdlGqeiwWxfiw(D)zXYP1SenWalEb)DAyz79P7AT9wyUNMZT3Ext1BWpP1(KbNR)gQCvnbYIcwux9Ub)(0DT2muFi8URQjwuWslwSMLzvuhoOiJUrWhhN7AI(RqLrPV0imzOYv1eiljjS8xkXcsLf0hTSeplOplTzrblVpOO38xkLFyg8iwINLyz)2XfXyhd7nQCvnbAht7np8hSS3WVpDxRT3ajCyUO)GL9gsX97Sy1hYtvVcKgwwyILT3NUR1S8qwqGOiwwrS87elQRENf1gS4AmKLf(kuSS9(0DTMfyXcAzbtbybIzboSOjmMLHs9RUcL9wyUNMZT3MvrD4GIm)LswGtLbhYtvVcKgdvUQMazrbl4isRZVpOOhBWVpDxRzjELyjwSOGLwSynlQRE38xkzbovgCipv9kqAmRiwuWI6Q3n43NUR1MH6dH3DvnXssclTybOpNRQjd4qEA2YP15UR1zyVZIcwAXI6Q3n43NUR1MHs9RWSaywIfljjSGJiTo)(GIESb)(0DTML4zbqSOGL31u9g8tATpzW56VHkxvtGSOGf1vVBWVpDxRndL6xHzbWSGwwAZsBwAB)2Xvzayhd7nQCvnbAht7nyK9gME7np8hSS3a6Z5QAYEdORxK9MJ)X15iOfAyjEwAsaWstZslwugaSG4SOU6DZFPKf4uzWH8u1RaPXGFpGalTzPPzPflQRE3GFF6UwBgk1VcZcIZsSybjSGJiToV74NybXzXAwExt1BWpP1(KbNR)gQCvnbYsBwAAwAXsac1GqlLb)(0DT2muQFfMfeNLyXcsybhrADE3XpXcIZY7AQEd(jT2Nm4C93qLRQjqwAZstZslwaHVPVMgzypt6vrMHs9RWSG4SGwwAZIcwAXI6Q3n43NUR1MveljjSeGqni0szWVpDxRndL6xHzPT9giHdZf9hSS3qURdlT)eMfl70VtdlolBVp41GIyzHjwSCAnlbFHjw2EF6UwZYdzP7AnlWEhnS4fillmXY27dEnOiwEiliquelw9H8u1RaPHf87beyzfzVb0NC5PK9g(9P7AD2cS(C316mS3TF74QSY2XWEJkxvtG2X0EZd)bl7n87dEnOi7nqchMl6pyzV1eyILT3h8AqrSy5(DwS6d5PQxbsdlpKfeikILvel)oXI6Q3zXY97W1ZIgIVcflBVpDxRzzf9xkXIxGSSWelBVp41GIybwSG(iILycJtmyb)EabmlR6pnlOplVpOOhBVfM7P5C7nG(CUQMmGd5PzlNwN7UwNH9olkybOpNRQjd(9P7AD2cS(C316mS3zrblwZcqFoxvtMdvbhkJFFWRbfXssclTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwINLyXssclQRE3O6AVcug2ZUwN)9RqHZ(e8Im43diWs8SelwAZIcwWrKwNFFqrp2GFF6UwZcGzb9zrbla95CvnzWVpDxRZwG1N7UwNH9U9BhxLbKDmS3OYv1eODmT38WFWYEZb9O)aszSfFsT3cncAk)(GIESDCv2Elm3tZ52BwZYFbeUcflkyXAw8WFWY4GE0FaPm2IpPzqp1rrMRYD9HA)zjjHfq4BCqp6pGugBXN0mON6Oid(9acSaywIflkybe(gh0J(diLXw8jnd6PokYmuQFfMfaZsSS3ajCyUO)GL9wtGjwWw8jLfmKLF3FwAaxSGIEwsDKXYk6VuIf1gSSWxHIL7zXXSO9NyXXSebX4tvtSalw0egZYV7flXIf87beWSahwqkzHFwSStflXcrSGFpGaMfczr3q2VDCvow2XWEJkxvtG2X0EZd)bl7TuiS63q2BHgbnLFFqrp2oUkBVfM7P5C7TH6dH3DvnXIcwEFqrV5Vuk)Wm4rSeplTyPflkJ(SGiwAXcoI0687dk6Xg87t)gIfeNfaXcIZI6Q3nuqFrykRxLpMvelTzPnliILHs9RWS0MfKWslwuMfeXY7AQEZB5QCkewydvUQMazPnlkyPflbiudcTuMGNVkygYbBWIcwSMfWzDGMcMdGywuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcWciebk)7ughDZ9yZqoydwssyXAwcqGu51BQd1(N7oXsBwssybhrAD(9bf9yd(9PFdXcGzPflTybGXstZslwux9UHc6lctz9Q8XSIybXzbqS0ML2SG4S0IfLzbrS8UMQ38wUkNcHf2qLRQjqwAZsBwuWI1Sqb9fHjdgQ9jxeYEwssyPfluqFryYCvgd1(WssclTyHc6lctMRYQWFNLKewOG(IWK5QSEv(WsBwuWI1S8UMQ3GHlDg2Z)oL7WHWVHkxvtGSKKWI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIL4vIfaHwaWsBwuWslwWrKwNFFqrp2GFF63qSaywugaSG4S0IfLzbrS8UMQ38wUkNcHf2qLRQjqwAZsBwuWIJ)X15iOfAyjEwqlayPPzrD17g87t31AZqP(vywqCwayS0MffS0IfRzrD17geUcCiWmLgbTqtkvFMkAqDXMmRiwssyHc6lctMRYyO2hwssyXAwcqGu51BqOXCEXsBwuWI1SOU6DZ4aPcUW5(qvSBKXx1x68Ed8tZ5MvK9giHdZf9hSS3SAP(q4DwaibHv)gILRZcYJdsSQkWYHzzihSbAy53PHyXhIfnHXS87EXcAz59bf9ywUIfRCv(WIve0xeMyXY97SSbFac0WIMWyw(DVyrzaWc83PXYHjwUIfVAWIve0xeMyboSSIy5HSGwwEFqrpMfvQdhIfNfRCv(WIve0xeMmSy1Hf6EwgQpeENfW1CfkwqkFf4qGSyfPrql0Ks1ZYQ0egZYvSSb1(WIve0xeMSF74Qm6Bhd7nQCvnbAht7np8hSS36Wjqzypx(VgYEdKWH5I(dw2BnbMybGagxwGflbqwSC)oC9Se8OORqzVfM7P5C7npkh2Pac2VDCvgT2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVznlGZ6anfmhaXSOGfG(CUQMmbWCawG3FWIffS0ILwSOU6Dd(9P7ATzfXssclVRP6n4N0AFYGZ1FdvUQMazjjHLaeivE9M6qT)5UtS0MffS0IfRzrD17gmuJ)lqMvelkyXAwux9Uj45RcMvelkyPflwZY7AQEtFnnYWEM0RImu5QAcKLKewux9Uj45RcgW14)blwINLaeQbHwktFnnYWEM0RImdL6xHzbrS0KS0MffSa0NZv1K53NtRZyIqGMSf)EwuWslwSMLaeivE9M6qT)5UtSKKWsac1GqlLjalGqeO8VtzC0n3JnRiwuWslwux9Ub)(0DT2muQFfMfaZcGyjjHfRz5DnvVb)Kw7tgCU(BOYv1eilTzPnlky59bf9M)sP8dZGhXs8SOU6DtWZxfmGRX)dwSG4SaadILL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyPT9gqFYLNs2BbWCawG3FWk7qY(TJRYam7yyVrLRQjq7yAV5H)GL9wG0e(pxND9HQsP6T3ajCyUO)GL9wtGjwqECqIvvbwGflbqwwLMWyw8cKf9vel3ZYkIfl3VZcYHfqicK9wyUNMZT3a6Z5QAYeaZbybE)bRSdj73oUkJyTJH9gvUQMaTJP9wyUNMZT3a6Z5QAYeaZbybE)bRSdj7np8hSS3Uk4t5)bl73oUk3K2XWEJkxvtG2X0EZd)bl7nkncAHMSkSaT3ajCyUO)GL9wtGjwSI0iOfAyjMWcKfyXsaKfl3VZY27t31AwwrS4filyhiXshoSaqxASpS4filipoiXQQG9wyUNMZT3U6PjcQ9NaZ9d1(Nhk1VcZcGzrz0YssclTyrD17MO5sHd456SpbVUqoAPX(ya66fXcGzbqOfaSKKWI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIL4vIfaHwaWsBwuWI6Q3n43NUR1MvelkyPflbiudcTuMGNVkygk1VcZs8SGwaWssclGZ6anfmhaXS02(TJRYig7yyVrLRQjq7yAV5H)GL9g(jT2NCx7dzVfAe0u(9bf9y74QS9wyUNMZT3gQpeE3v1elky5Vuk)Wm4rSeplkJwwuWcoI0687dk6Xg87t)gIfaZc6ZIcw8OCyNciWIcwAXI6Q3nbpFvWmuQFfML4zrzaWssclwZI6Q3nbpFvWSIyPT9giHdZf9hSS3SAP(q4Dw6AFiwGflRiwEilXIL3hu0JzXY97W1ZcYJdsSQkWIkDfkwCv46z5HSqil6gIfVazPGplqG0e8OORqz)2XfqaWog2Bu5QAc0oM2BE4pyzV1xtJmSNj9Qi7nqchMl6pyzV1eyIfacOvWY1z5k8bsS4flwrqFryIfVazrFfXY9SSIyXY97S4SaqxASpSenWalEbYsCa9O)asSSzXNu7TWCpnNBVrb9fHjZvzVAWIcw8OCyNciWIcwux9UjAUu4aEUo7tWRlKJwASpgGUErSaywaeAbalkyPflGW34GE0FaPm2IpPzqp1rrM)ciCfkwssyXAwcqGu51BkkmqnCazjjHfCeP153hu0JzjEwaelTzrblTyrD17MXbsfCHZ9HQy3WmuQFfMfaZcIHLMMLwSGwwqCwMvrD4GIm4R6lDEVb(P5CdvUQMazPnlkyrD17MXbsfCHZ9HQy3WSIyjjHfRzrD17MXbsfCHZ9HQy3WSIyPnlkyPflwZsac1GqlLj45RcMveljjSOU6DZVpNwNXeHang87beybWSOmAzrbl9d1(Nhk1VcZcGzbqaaaSOGL(HA)ZdL6xHzjEwugaaGLKewSMfmCPvVc087ZP1zmriqJHkxvtGS0MffS0IfmCPvVc087ZP1zmriqJHkxvtGSKKWsac1GqlLj45RcMHs9RWSeplXcaS02(TJlGu2og2Bu5QAc0oM2BE4pyzVHFF6UwBVbs4WCr)bl7TMatS4SS9(0DTMfaYf97SenWalRstymlBVpDxRz5WS46HCWgSSIyboS0aUyXhIfxfUEwEilqG0e8iwIdgGAVfM7P5C7n1vVBGf974Cenbk6pyzwrSOGLwSOU6Dd(9P7ATzO(q4DxvtSKKWIJ)X15iOfAyjEwqmaGL22VDCbeGSJH9gvUQMaTJP9Mh(dw2B43NUR12BGeomx0FWYEZQVsJyjoyaklQuhoelihwaHiqSy5(Dw2EF6UwZIxGS87uXY27dEnOi7TWCpnNBVfGaPYR3uhQ9p3DIffSynlVRP6n4N0AFYGZ1FdvUQMazrblTybOpNRQjtawaHiqzqc3OcSKKWsac1GqlLj45RcMveljjSOU6DtWZxfmRiwAZIcwcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlaMfubqtQJmwqCwc0PzPflo(hxNJGwOHfKWcAbalTzrblQRE3GFF6UwBgk1VcZcGzb9zrblwZc4SoqtbZbqS9Bhxafl7yyVrLRQjq7yAVfM7P5C7TaeivE9M6qT)5UtSOGLwSa0NZv1KjalGqeOmiHBubwssyjaHAqOLYe88vbZkILKewux9Uj45RcMvelTzrblbiudcTuMaSacrGY)oLXr3Cp2muQFfMfaZcaJffSOU6Dd(9P7ATzfXIcwOG(IWK5QSxnyrblwZcqFoxvtMdvbhkJFFWRbfXIcwSMfWzDGMcMdGy7np8hSS3WVp41GISF74ci03og2Bu5QAc0oM2BE4pyzVHFFWRbfzVbs4WCr)bl7TMatSS9(GxdkIfl3VZIxSaqUOFNLObgyboSCDwAaxOdKfiqAcEelXbdqzXY97S0aUgwkczplbh)gwIJgdzbCLgXsCWauw8NLFNyHkqwGDw(DIfRgu97ngwux9olxNLT3NUR1SybU0Gf6Ew6UwZcS3zboS0aUyXhIfyXcGy59bf9y7TWCpnNBVPU6DdSOFhNdAYNmWdFWYSIyjjHLwSynl43N(nKXJYHDkGalkyXAwa6Z5QAYCOk4qz87dEnOiwssyPflQRE3e88vbZqP(vywamlOLffSOU6DtWZxfmRiwssyPflTyrD17MGNVkygk1VcZcGzbva0K6iJfeNLaDAwAXIJ)X15iOfAybjSelaWsBwuWI6Q3nbpFvWSIyjjHf1vVBghivWfo3hQIDJm(Q(sN3BGFAo3muQFfMfaZcQaOj1rgliolb60S0Ifh)JRZrql0WcsyjwaGL2SOGf1vVBghivWfo3hQIDJm(Q(sN3BGFAo3SIyPnlkyjabsLxVbiv)EJHL2S0MffS0IfCeP153hu0Jn43NUR1SaywIfljjSa0NZv1Kb)(0DToBbwFU7ADg27S0ML2SOGfRzbOpNRQjZHQGdLXVp41GIyrblTyXAwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazjjHfCeP153hu0Jn43NUR1SaywIflTTF74ci0Ahd7nQCvnbAht7np8hSS3kYsofcl7nqchMl6pyzV1eyIfasqyHz5kw2GAFyXkc6lctS4filyhiXcaXsRzbGeewS0HdlipoiXQQG9wyUNMZT3AXI6Q3nuqFrykJHAFmdL6xHzjEwiKrH1t5)sjwssyPflHDFqrywuIfaXIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXIL2SOGfpkh2Pac2VDCbeaZog2Bu5QAc0oM2BH5EAo3ERflQRE3qb9fHPmgQ9XmuQFfML4zHqgfwpL)lLyjjHLwSe29bfHzrjwaelkyzOWUpOO8FPelaMf0YsBwssyjS7dkcZIsSelwAZIcw8OCyNciWIcwAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMf0YIcwux9UzCGubx4CFOk2nmRiwuWI1SmRI6WbfzWx1x68Ed8tZ5gQCvnbYssclwZI6Q3nJdKk4cN7dvXUHzfXsB7np8hSS32DDpNcHL9BhxaHyTJH9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykJHAFmdL6xHzjEwiKrH1t5)sjwuWslwcqOgeAPmbpFvWmuQFfML4zbTaGLKewcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlXZcAbalTzjjHLwSe29bfHzrjwaelkyzOWUpOO8FPelaMf0YsBwssyjS7dkcZIsSelwAZIcw8OCyNciWIcwAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMf0YIcwux9UzCGubx4CFOk2nmRiwuWI1SmRI6WbfzWx1x68Ed8tZ5gQCvnbYssclwZI6Q3nJdKk4cN7dvXUHzfXsB7np8hSS36lToNcHL9Bhxa1K2XWEJkxvtG2X0EdKWH5I(dw2BnbMybPaAfSalwqUv3EZd)bl7nl(mhCYWEM0RISF74cieJDmS3OYv1eODmT3Gr2By6T38WFWYEdOpNRQj7nGUEr2B4isRZVpOOhBWVp9BiwINf0NfeXsxdHdlTyj1XpnnYaD9IybXzrzaaawqclacaS0MfeXsxdHdlTyrD17g87dEnOOmLgbTqtkvFgd1(yWVhqGfKWc6ZsB7nqchMl6pyzVHCxhwA)jmlw2PFNgwEillmXY27t)gILRyzdQ9Hfl7xyNLdZI)SGwwEFqrpgrkZshoSqaPPblacaivwsD8ttdwGdlOplBVp41GIyXksJGwOjLQNf87beW2Ba9jxEkzVHFF63q5RYyO2h73oUXca2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVPmliHfCeP15Dh)elaMfaXstZslwaGbqSG4S0IfCeP153hu0Jn43N(nelnnlkZsBwqCwAXIYSGiwExt1BWWLod75FNYD4q43qLRQjqwqCwu2GwwAZsBwqelaWOmAzbXzrD17MXbsfCHZ9HQy3WmuQFf2EdKWH5I(dw2Bi31HL2FcZILD63PHLhYcsX4)olGR5kuSaqmuf7g2Ba9jxEkzVzz8FpFvUpuf7g2VDCJLY2XWEJkxvtG2X0EZd)bl7nlJ)72BGeomx0FWYERjWelifJ)7SCflBqTpSyfb9fHjwGdlxNLcYY27t)gIflNwZs)EwU6HSG84GeRQcS4vJu4q2BH5EAo3ERfluqFryYOxLp5Iq2ZsscluqFryY4vJCri7zrbla95CvnzoCoOjhiXsBwuWslwEFqrV5Vuk)Wm4rSeplOpljjSqb9fHjJEv(KVkdiwssyPFO2)8qP(vywamlkdawAZssclQRE3qb9fHPmgQ9XmuQFfMfaZIh(dwg87t)gYqiJcRNY)LsSOGf1vVBOG(IWugd1(ywrSKKWcf0xeMmxLXqTpSOGfRzbOpNRQjd(9PFdLVkJHAFyjjHf1vVBcE(QGzOu)kmlaMfp8hSm43N(nKHqgfwpL)lLyrblwZcqFoxvtMdNdAYbsSOGf1vVBcE(QGzOu)kmlaMfczuy9u(VuIffSOU6DtWZxfmRiwssyrD17MXbsfCHZ9HQy3WSIyrbla95CvnzSm(VNVk3hQIDdwssyXAwa6Z5QAYC4CqtoqIffSOU6DtWZxfmdL6xHzjEwiKrH1t5)sj73oUXcq2XWEJkxvtG2X0EdKWH5I(dw2BnbMyz79PFdXY1z5kwSYv5dlwrqFrycnSCflBqTpSyfb9fHjwGflOpIy59bf9ywGdlpKLObgyzdQ9HfRiOVimzV5H)GL9g(9PFdz)2XnwXYog2Bu5QAc0oM2BGeomx0FWYEdGW16FFw2BE4pyzVnRk7H)GvwF43EtF4pxEkzV1DT(3NL9B)2BDxR)9zzhd74QSDmS3OYv1eODmT38WFWYEd)(GxdkYEdKWH5I(dw2BBVp41GIyPdhwsHaPuQEwwLMWyww4RqXsmHXjg2BH5EAo3EZAwMvrD4GImQU2RaLH9SR15F)kuydHERlkIaTF74ci7yyVrLRQjq7yAV5H)GL9gEv9Bi7TqJGMYVpOOhBhxLT3cZ90CU9gi8nPqy1VHmdL6xHzjEwgk1VcZcIZcGaeliHfLBs7nqchMl6pyzVHCh)S87elGWNfl3VZYVtSKcXpl)LsS8qwCqqww1FAw(DILuhzSaUg)pyXYHzz)EdlBRQFdXYqP(vywsx6)I0hbYYdzj1)WolPqy1VHybCn(FWY(TJBSSJH9Mh(dw2BPqy1VHS3OYv1eODmTF73Ed)2XWoUkBhd7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9wtGjw2EFWRbfXYdzbbIIyzfXYVtSy1hYtvVcKgwux9olxNL7zXcCPbzHqw0nelQuhoel9Ro8(vOy53jwkczplbh)SahwEilGR0iwuPoCiwqoSacrGS3cZ90CU92SkQdhuK5VuYcCQm4qEQ6vG0yOYv1eilkyPfluqFryYCv2RgSOGfRzPflTyrD17M)sjlWPYGd5PQxbsJzOu)kmlXZIh(dwglJ)7gczuy9u(VuIfeXcamkZIcwAXcf0xeMmxLvH)oljjSqb9fHjZvzmu7dljjSqb9fHjJEv(KlczplTzjjHf1vVB(lLSaNkdoKNQEfinMHs9RWSeplE4pyzWVp9BidHmkSEk)xkXcIybagLzrblTyHc6lctMRY6v5dljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczplTzPnljjSynlQRE38xkzbovgCipv9kqAmRiwAZssclTyrD17MGNVkywrSKKWcqFoxvtMaSacrGYGeUrfyPnlkyjaHAqOLYeGfqicu(3Pmo6M7XMHCWgSOGLaeivE9M6qT)5UtS0MffS0IfRzjabsLxVbHgZ5fljjSeGqni0szO0iOfAYQWc0muQFfML4zPjzPnlkyPflQRE3e88vbZkILKewSMLaeQbHwktWZxfmd5GnyPT9Bhxazhd7nQCvnbAht7np8hSS3Cqp6pGugBXNu7TqJGMYVpOOhBhxLT3cZ90CU9M1SacFJd6r)bKYyl(KMb9uhfz(lGWvOyrblwZIh(dwgh0J(diLXw8jnd6PokYCvURpu7plkyPflwZci8noOh9hqkJT4tAENCT5VacxHILKewaHVXb9O)aszSfFsZ7KRndL6xHzjEwqllTzjjHfq4BCqp6pGugBXN0mON6Oid(9acSaywIflkybe(gh0J(diLXw8jnd6PokYmuQFfMfaZsSyrblGW34GE0FaPm2IpPzqp1rrM)ciCfk7nqchMl6pyzV1eyIL4a6r)bKyzZIpPSyzNkw(DAiwomlfKfp8hqIfSfFsrdloMfT)eloMLiigFQAIfyXc2IpPSy5(DwaelWHLozHgwWVhqaZcCybwS4SeleXc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdiHzbPKf(zX7pnS87(Zc2IpPSqil6gcB)2Xnw2XWEJkxvtG2X0EZd)bl7TaSacrGY)oLXr3Cp2EdKWH5I(dw2BnbMWSGCybeIaXY1zb5Xbjwvfy5WSSIyboS0aUyXhIfqc3OcxHIfKhhKyvvGfl3VZcYHfqicelEbYsd4IfFiwujn0clOpayjoyaQ9wyUNMZT3SMfWzDGMcMdGywuWslwAXcqFoxvtMaSacrGYGeUrfyrblwZsac1GqlLj45RcMHCWgSOGfRzzwf1HdkYenxkCapxN9j41fYrln2hdvUQMazjjHf1vVBcE(QGzfXsBwuWIJ)X15iOfAybWkXc6dawuWslwux9UHc6lctz9Q8XmuQFfML4zrzaWssclQRE3qb9fHPmgQ9XmuQFfML4zrzaWsBwssyrfIXSOGL(HA)ZdL6xHzbWSOmayrblwZsac1GqlLj45RcMHCWgS02(TJl6Bhd7nQCvnbAht7nyK9gME7np8hSS3a6Z5QAYEdORxK9wlwux9UzCGubx4CFOk2nmdL6xHzjEwqlljjSynlQRE3moqQGlCUpuf7gMvelTzrblwZI6Q3nJdKk4cN7dvXUrgFvFPZ7nWpnNBwrSOGLwSOU6DdcxboeyMsJGwOjLQptfnOUytMHs9RWSaywqfanPoYyPnlkyPflQRE3qb9fHPmgQ9XmuQFfML4zbva0K6iJLKewux9UHc6lctz9Q8XmuQFfML4zbva0K6iJLKewAXI1SOU6Ddf0xeMY6v5JzfXssclwZI6Q3nuqFrykJHAFmRiwAZIcwSML31u9gmuJ)lqgQCvnbYsB7nqchMl6pyzVHCybE)blw6WHfxRzbe(yw(D)zj1rGWSGxdXYVtnyXhQq3ZYq9HW7eilw2PIfRwhivWfMfaIHQy3GLDhZIMWyw(DVybTSGPaMLHs9RUcflWHLFNybHgZ5flQRENLdZIRcxplpKLUR1Sa7DwGdlE1GfRiOVimXYHzXvHRNLhYcHSOBi7nG(KlpLS3aHFEi0BDdLs1JTF74Iw7yyVrLRQjq7yAVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3AXI1SOU6Ddf0xeMYyO2hZkIffSynlQRE3qb9fHPSEv(ywrS0MLKewExt1BWqn(VazOYv1eO9giHdZf9hSS3qoSaV)Gfl)U)Se2PacywUolnGlw8HybUE8bsSqb9fHjwEilWs3Gfq4ZYVtdXcCy5qvWHy53pmlwUFNLnOg)xGS3a6tU8uYEde(z46XhiLPG(IWK9BhxaMDmS3OYv1eODmT38WFWYElfcR(nK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmljjSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywssybOpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmGyrblEuoStbeyrbla95CvnzaHFEi0BDdLs1JT3cncAk)(GIESDCv2(TJlI1og2Bu5QAc0oM2BE4pyzVHxv)gYElm3tZ52Bd1hcV7QAIffS0If1vVBOG(IWugd1(ygk1VcZs8SmuQFfMLKewux9UHc6lctz9Q8XmuQFfML4zzOu)kmljjSa0NZv1Kbe(z46XhiLPG(IWelTzrbld1hcV7QAIffS8(GIEZFPu(HzWJyjEwugqSOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2oUkB)2XTjTJH9gvUQMaTJP9Mh(dw2B4N0AFYDTpK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmljjSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywssybOpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmaJffS4r5WofqGffSa0NZv1Kbe(5HqV1nukvp2El0iOP87dk6X2Xvz73oUig7yyVrLRQjq7yAV5H)GL9whobkd75Y)1q2BGeomx0FWYERjWelaeW4YcSyjaYIL73HRNLGhfDfk7TWCpnNBV5r5WofqW(TJRYaWog2Bu5QAc0oM2BE4pyzVrPrql0KvHfO9giHdZf9hSS3AcmXcs5RahcKLTOBUhZIL73zXRgSOHfkwOcUqTZI2X)vOyXkc6lctS4fil)0GLhYI(kIL7zzfXIL73zbGU0yFyXlqwqECqIvvb7TWCpnNBV1ILwSOU6Ddf0xeMYyO2hZqP(vywINfLbaljjSOU6Ddf0xeMY6v5JzOu)kmlXZIYaGL2SOGLaeQbHwktWZxfmdL6xHzjEwIfayrblTyrD17MO5sHd456SpbVUqoAPX(ya66fXcGzbqOpayjjHfRzzwf1HdkYenxkCapxN9j41fYrln2hdHERlkIazPnlTzjjHf1vVBIMlfoGNRZ(e86c5OLg7JbORxelXRelacXcawssyjaHAqOLYe88vbZqoydwuWIJ)X15iOfAyjEwqmaW(TJRYkBhd7nQCvnbAht7nyK9gME7np8hSS3a6Z5QAYEdORxK9M1SaoRd0uWCaeZIcwa6Z5QAYeaZbybE)blwuWslwAXsac1GqlLHsJAmKRZWbS8kqMHs9RWSaywugGHyzbrS0IfLvMfeNLzvuhoOid(Q(sN3BGFAo3qLRQjqwAZIcwi0BDrreOHsJAmKRZWbS8kqS0MLKewC8pUohbTqdlXReligaWIcwAXI1S8UMQ30xtJmSNj9QidvUQMazjjHf1vVBcE(QGbCn(FWIL4zjaHAqOLY0xtJmSNj9QiZqP(vywqelnjlTzrblGW3Gxv)gYmuQFfML4zrzaXIcwaHVjfcR(nKzOu)kmlXZstYIcwAXci8n4N0AFYDTpKzOu)kmlXZstYssclwZY7AQEd(jT2NCx7dzOYv1eilTzrbla95Cvnz(9506mMieOjBXVNffS0If1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIyjjHfRzjabsLxVbHgZ5flTzrblVpOO38xkLFyg8iwINf1vVBcE(QGbCn(FWIfeNfayqSSKKWIkeJzrbl9d1(Nhk1VcZcGzrD17MGNVkyaxJ)hSyjjHLaeivE9M6qT)5UtSKKWI6Q3nQAieuVWVzfXIcwux9UrvdHG6f(ndL6xHzbWSOU6DtWZxfmGRX)dwSGiwAXcIHfeNLzvuhoOit0CPWb8CD2NGxxihT0yFme6TUOicKL2S0MffSynlQRE3e88vbZkIffS0IfRzjabsLxVPou7FU7eljjSeGqni0szcWciebk)7ughDZ9yZkILKewuHymlkyPFO2)8qP(vywamlbiudcTuMaSacrGY)oLXr3Cp2muQFfMfeXcaJLKew6hQ9ppuQFfMfKklk3KaGfaZI6Q3nbpFvWaUg)pyXsB7nqchMl6pyzV1eyIfKhhKyvvGfl3VZcYHfqicesqkFf4qGSSfDZ9yw8cKfqyHUNfiqASm3tSaqxASpSahwSStflXudHG6f(zXcCPbzHqw0nelQuhoelipoiXQQaleYIUHW2Ba9jxEkzVfaZbybE)bRm(TF74QmGSJH9gvUQMaTJP9Mh(dw2BJdKk4cN7dvXUH9giHdZf9hSS3AcmXYVtSy1GQFVXWIL73zXzb5Xbjwvfy539NLdxO7zPpWuwaOln2h7TWCpnNBVPU6DtWZxfmdL6xHzjEwugTSKKWI6Q3nbpFvWaUg)pyXcGzjwaGffSa0NZv1KjaMdWc8(dwz8B)2Xv5yzhd7nQCvnbAht7TWCpnNBVb0NZv1KjaMdWc8(dwz8ZIcwAXI1SOU6DtWZxfmGRX)dwSeplXcaSKKWI1SeGaPYR3aKQFVXWsBwssyrD17MXbsfCHZ9HQy3WSIyrblQRE3moqQGlCUpuf7gMHs9RWSaywqmSGiwcWcCDVjAOWHPSRpuvkvV5Vukd01lIfeXslwSMf1vVBu1qiOEHFZkIffSynlVRP6n43hnCanu5QAcKL22BE4pyzVfinH)Z1zxFOQuQE73oUkJ(2XWEJkxvtG2X0Elm3tZ52Ba95CvnzcG5aSaV)Gvg)2BE4pyzVDvWNY)dw2VDCvgT2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVznlbiudcTuMGNVkygYbBWssclwZcqFoxvtMaSacrGYGeUrfyrblbiqQ86n1HA)ZDNyjjHfWzDGMcMdGy7nqchMl6pyzVz1WNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoqcKLoCyb5Xbjwvfybdz539NLFNAWIpu9SyXXpbYcsjl8ZIk1HdXYVtP2Ba9jxEkzVHDGuUdNCWZxfSF74QmaZog2Bu5QAc0oM2BE4pyzV1xtJmSNj9Qi7nqchMl6pyzV1eycZcab0ky56SCflEXIve0xeMyXlqw(5imlpKf9vel3ZYkIfl3VZcaDPX(GgwqECqIvvbw8cKL4a6r)bKyzZIpP2BH5EAo3EJc6lctMRYE1GffS4r5WofqGffSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSai0haSOGLwSacFJd6r)bKYyl(KMb9uhfz(lGWvOyjjHfRzjabsLxVPOWa1WbKL2SOGfG(CUQMmyhiL7Wjh88vbwuWslwux9UzCGubx4CFOk2nmdL6xHzbWSGyyPPzPflOLfeNLzvuhoOid(Q(sN3BGFAo3qLRQjqwAZIcwux9UzCGubx4CFOk2nmRiwssyXAwux9UzCGubx4CFOk2nmRiwAB)2XvzeRDmS3OYv1eODmT38WFWYEd)(0DT2EdKWH5I(dw2BnbMybGCr)olBVpDxRzjAGbmlxNLT3NUR1SC4cDplRi7TWCpnNBVPU6DdSOFhNJOjqr)blZkIffSOU6Dd(9P7ATzO(q4Dxvt2VDCvUjTJH9gvUQMaTJP9wyUNMZT3ux9Ub)(OHdOzOu)kmlaMf0YIcwAXI6Q3nuqFrykJHAFmdL6xHzjEwqlljjSOU6Ddf0xeMY6v5JzOu)kmlXZcAzPnlkyXX)46Ce0cnSepligayV5H)GL9wWRaPZQRE3EtD175Ytj7n87JgoG2VDCvgXyhd7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9MvFLgHzjoyaklQuhoelihwaHiqSSWxHILFNyb5WciebILaSaV)GflpKLWofqGLRZcYHfqicelhMfp8lxRBWIRcxplpKfvILGJF7TWCpnNBVfGaPYR3uhQ9p3DIffSa0NZv1KjalGqeOmiHBubwuWsac1GqlLjalGqeO8VtzC0n3JndL6xHzbWSGwwuWI1SaoRd0uWCaeZIcwOG(IWK5QSxnyrblo(hxNJGwOHL4zb9bG9Bhxaba7yyVrLRQjq7yAV5H)GL9g(9P7AT9giHdZf9hSS3AcmXY27t31AwSC)olBpP1(WIvFU(ZIxGSuqw2EF0WbenSyzNkwkilBVpDxRz5WSSIqdlnGlw8Hy5kwSYv5dlwrqFryILoCyPjreMcywGdlpKLObgybGU0yFyXYovS4QqGeligaWsCWauwGdloyK)hqIfSfFszz3XS0KictbmldL6xDfkwGdlhMLRyPRpu7VHL4cFILF3FwwfinS87elypLyjalW7pyHz5E0HzbmcZsrRFCnlpKLT3NUR1SaUMRqXIvRdKk4cZcaXqvSBGgwSStflnGl0bYc(pTMfQazzfXIL73zbXaae54iw6WHLFNyr74NfuAOQRXg7TWCpnNBV9UMQ3GFsR9jdox)nu5QAcKffSynlVRP6n43hnCanu5QAcKffSOU6Dd(9P7ATzO(q4DxvtSOGLwSOU6Ddf0xeMY6v5JzOu)kmlXZstYIcwOG(IWK5QSEv(WIcwux9UjAUu4aEUo7tWRlKJwASpgGUErSaywaeAbaljjSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IyjELybqOfaSOGfh)JRZrql0Ws8SGyaaljjSacFJd6r)bKYyl(KMb9uhfzgk1VcZs8S0KSKKWIh(dwgh0J(diLXw8jnd6PokYCvURpu7plTzrblbiudcTuMGNVkygk1VcZs8SOmaSF74ciLTJH9gvUQMaTJP9Mh(dw2B43h8Aqr2BGeomx0FWYERjWelBVp41GIybGCr)olrdmGzXlqwaxPrSehmaLfl7uXcYJdsSQkWcCy53jwSAq1V3yyrD17SCywCv46z5HS0DTMfyVZcCyPbCHoqwcEelXbdqT3cZ90CU9M6Q3nWI(DCoOjFYap8blZkILKewux9UbHRahcmtPrql0Ks1NPIguxSjZkILKewux9Uj45RcMvelkyPflQRE3moqQGlCUpuf7gMHs9RWSaywqfanPoYybXzjqNMLwS44FCDocAHgwqclXcaS0MfeXsSybXz5DnvVPil5uiSmu5QAcKffSynlZQOoCqrg8v9LoV3a)0CUHkxvtGSOGf1vVBghivWfo3hQIDdZkILKewux9Uj45RcMHs9RWSaywqfanPoYybXzjqNMLwS44FCDocAHgwqclXcaS0MLKewux9UzCGubx4CFOk2nY4R6lDEVb(P5CZkILKewAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMfp8hSm43N(nKHqgfwpL)lLyrbl4isRZ7o(jwamlaWG(SKKWI6Q3nJdKk4cN7dvXUHzOu)kmlaMfp8hSmwg)3neYOW6P8FPeljjSa0NZv1K5qpWCawG3FWIffSeGqni0szUchM17QAkJElV(vAgKaEbYmKd2GffSqO36IIiqZv4WSExvtz0B51VsZGeWlqS0MffSOU6DZ4aPcUW5(qvSBywrSKKWI1SOU6DZ4aPcUW5(qvSBywrSOGfRzjaHAqOLYmoqQGlCUpuf7gMHCWgSKKWI1SeGaPYR3aKQFVXWsBwssyXX)46Ce0cnSepligaWIcwOG(IWK5QSxnSF74ciazhd7nQCvnbAht7np8hSS3WVp41GIS3ajCyUO)GL9wmMgS8qwsDeiw(DIfvc)Sa7SS9(OHdilQnyb)EaHRqXY9SSIyb9wxabDdwUIfVAWIve0xeMyrD9SaqxASpSC46zXvHRNLhYIkXs0adbc0Elm3tZ52BVRP6n43hnCanu5QAcKffSynlZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGSOGLwSOU6Dd(9rdhqZkILKewC8pUohbTqdlXZcIbaS0MffSOU6Dd(9rdhqd(9acSaywIflkyPflQRE3qb9fHPmgQ9XSIyjjHf1vVBOG(IWuwVkFmRiwAZIcwux9UjAUu4aEUo7tWRlKJwASpgGUErSaywaeIfaSOGLwSeGqni0szcE(QGzOu)kmlXZIYaGLKewSMfG(CUQMmbybeIaLbjCJkWIcwcqGu51BQd1(N7oXsB73oUakw2XWEJkxvtG2X0EdgzVHP3EZd)bl7nG(CUQMS3a66fzVrb9fHjZvz9Q8HfeNLMKfKWIh(dwg87t)gYqiJcRNY)LsSGiwSMfkOVimzUkRxLpSG4S0IfagliIL31u9gmCPZWE(3PChoe(nu5QAcKfeNLyXsBwqclE4pyzSm(VBiKrH1t5)sjwqelaWG(OLfKWcoI068UJFIfeXcamOLfeNL31u9MY)1q4SQR9kqgQCvnbAVbs4WCr)bl7nRa)xQ)eMLDOfwsxHDwIdgGYIpelO8RiqwIOHfmfGfO9gqFYLNs2BoocGsZgfSF74ci03og2Bu5QAc0oM2BE4pyzVHFFWRbfzVbs4WCr)bl7nR(knILT3h8AqrSCfloliweHPalBqTpSyfb9fHj0WciSq3ZIMEwUNLObgybGU0yFyP1V7plhMLDVa1eilQnyHUFNgw(DILT3NUR1SOVIyboS87elXbdqJhXaaw0xrS0HdlBVp41GIAJgwaHf6EwGaPXYCpXIxSaqUOFNLObgyXlqw00ZYVtS4QqGel6Riw29cutSS9(OHdO9wyUNMZT3SMLzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwuWslwux9UjAUu4aEUo7tWRlKJwASpgGUErSaywaeIfaSKKWI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIfaZcGqlayrblVRP6n4N0AFYGZ1FdvUQMazPnlkyPfluqFryYCvgd1(WIcwC8pUohbTqdliIfG(CUQMmoocGsZgfybXzrD17gkOVimLXqTpMHs9RWSGiwaHVPVMgzypt6vrM)ciGZdL6xXcIZcGmOLL4zPjbaljjSqb9fHjZvz9Q8HffS44FCDocAHgwqela95CvnzCCeaLMnkWcIZI6Q3nuqFrykRxLpMHs9RWSGiwaHVPVMgzypt6vrM)ciGZdL6xXcIZcGmOLL4zbXaawAZIcwSMf1vVBGf974Cenbk6pyzwrSOGfRz5DnvVb)(OHdOHkxvtGSOGLwSeGqni0szcE(QGzOu)kmlXZcILLKewWWLw9kqZVpNwNXeHangQCvnbYIcwux9U53NtRZyIqGgd(9acSaywIvSyPPzPflZQOoCqrg8v9LoV3a)0CUHkxvtGSG4SGwwAZIcw6hQ9ppuQFfML4zrzaaawuWs)qT)5Hs9RWSaywaeaaalTzrblTyjaHAqOLYGWvGdbMXr3Cp2muQFfML4zbXYssclwZsacKkVEdcnMZlwAB)2XfqO1og2Bu5QAc0oM2BE4pyzVvKLCkew2BGeomx0FWYERjWelaKGWcZYvSyLRYhwSIG(IWelEbYc2bsSGukx3reaXsRzbGeewS0HdlipoiXQQalEbYcs5RahcKfRincAHMuQE7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKrH1t5)sjwssyPflHDFqrywuIfaXIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXIL2SOGfpkh2PacSOGfG(CUQMmyhiL7Wjh88vb73oUacGzhd7nQCvnbAht7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKrH1t5)sjwuWI1SeGaPYR3GqJ58ILKewAXI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrSOGLaeivE9geAmNxS0MLKewAXsy3hueMfLybqSOGLHc7(GIY)LsSaywqllTzjjHLWUpOimlkXsSyjjHf1vVBcE(QGzfXsBwuWIhLd7uabwuWcqFoxvtgSdKYD4KdE(QalkyPflQRE3moqQGlCUpuf7gMHs9RWSaywAXcAzPPzbqSG4SmRI6WbfzWx1x68Ed8tZ5gQCvnbYsBwuWI6Q3nJdKk4cN7dvXUHzfXssclwZI6Q3nJdKk4cN7dvXUHzfXsB7np8hSS32DDpNcHL9BhxaHyTJH9gvUQMaTJP9wyUNMZT3AXI6Q3nuqFrykRxLpMHs9RWSepleYOW6P8FPelkyXAwcqGu51BqOXCEXssclTyrD17geUcCiWmLgbTqtkvFMkAqDXMmRiwuWsacKkVEdcnMZlwAZssclTyjS7dkcZIsSaiwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjwSKKWI6Q3nbpFvWSIyPnlkyXJYHDkGalkybOpNRQjd2bs5oCYbpFvGffS0If1vVBghivWfo3hQIDdZqP(vywamlOLffSOU6DZ4aPcUW5(qvSBywrSOGfRzzwf1HdkYGVQV059g4NMZnu5QAcKLKewSMf1vVBghivWfo3hQIDdZkIL22BE4pyzV1xADofcl73oUaQjTJH9gvUQMaTJP9giHdZf9hSS3AcmXcsb0kybwSeaT38WFWYEZIpZbNmSNj9Qi73oUacXyhd7nQCvnbAht7np8hSS3WVp9Bi7nqchMl6pyzV1eyILT3N(nelpKLObgyzdQ9HfRiOVimHgwqECqIvvbw2DmlAcJz5VuILF3lwCwqkg)3zHqgfwpXIM6plWHfyPBWIvUkFyXkc6lctSCywwr2BH5EAo3EJc6lctMRY6v5dljjSqb9fHjdgQ9jxeYEwssyHc6lctgVAKlczpljjS0If1vVBS4ZCWjd7zsVkYSIyjjHfCeP15Dh)elaMfayqF0YIcwSMLaeivE9gGu97ngwssybhrADE3XpXcGzbag0NffSeGaPYR3aKQFVXWsBwuWI6Q3nuqFrykRxLpMveljjS0If1vVBcE(QGzOu)kmlaMfp8hSmwg)3neYOW6P8FPelkyrD17MGNVkywrS02(TJBSaGDmS3OYv1eODmT3ajCyUO)GL9wtGjwqkg)3zb(70y5Welw2VWolhMLRyzdQ9HfRiOVimHgwqECqIvvbwGdlpKLObgyXkxLpSyfb9fHj7np8hSS3Sm(VB)2XnwkBhd7nQCvnbAht7nqchMl6pyzVbq4A9Vpl7np8hSS3MvL9WFWkRp8BVPp8NlpLS36Uw)7ZY(TF7TOHcWuv)TJHDCv2og2BE4pyzVHWvGdbMXr3Cp2EJkxvtG2X0(TJlGSJH9gvUQMaTJP9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEda2BGeomx0FWYElg7ela95CvnXYHzbtplpKfaWIL73zPGSGF)zbwSSWel)Cfc0JrdlkZILDQy53jw63GFwGfXYHzbwSSWeAybqSCDw(DIfmfGfilhMfVazjwSCDwuH)ol(q2Ba9jxEkzVbR8ct5FUcb6TF74gl7yyVrLRQjq7yAVbJS3Cqq7np8hSS3a6Z5QAYEdORxK9MY2BH5EAo3E7NRqGEZRSz3X5fMYQRENffS8ZviqV5v2eGqni0szaxJ)hSyrblwZYpxHa9MxzZHnpmLYWEofw4FGlCoal8pRWFWcBVb0NC5PK9gSYlmL)5keO3(TJl6Bhd7nQCvnbAht7nyK9MdcAV5H)GL9gqFoxvt2BaD9IS3aK9wyUNMZT3(5keO38aYS748ctz1vVZIcw(5keO38aYeGqni0szaxJ)hSyrblwZYpxHa9MhqMdBEykLH9CkSW)ax4Caw4FwH)Gf2EdOp5Ytj7nyLxyk)ZviqV9Bhx0Ahd7nQCvnbAht7nyK9MdcAV5H)GL9gqFoxvt2Ba9jxEkzVbR8ct5FUcb6T3cZ90CU9gHERlkIanxHdZ6DvnLrVLx)kndsaVaXsscle6TUOic0qPrngY1z4awEfiwssyHqV1ffrGgmCP10)xHkpl1g2BGeomx0FWYElg7eMy5NRqGEml(qSuWNfF9Wu)VGR1nybKEk8eiloMfyXYctSGF)z5NRqGESHfw2ONfG(CUQMy5HSG(S4yw(DQblUgdzPicKfCefoxZYUxG6RqzS3a66fzVH(2VDCby2XWEZd)bl7TuiSq4QChoP2Bu5QAc0oM2VDCrS2XWEJkxvtG2X0EZd)bl7nlJ)72BH5EAo3ERfluqFryYOxLp5Iq2ZsscluqFryYCvgd1(WsscluqFryYCvwf(7SKKWcf0xeMmE1ixeYEwABVPVIYbq7nLbG9B)2V9gqAWhSSJlGaaGuganjaqF7nl(uxHcBVHuehR24AvX1QjaolSeJDILlncoplD4Wc6Grurd6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnBLxrSaiaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5velXcGZcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3m3msrCSAJRvfxRMa4SWsm2jwU0i48S0HdlOdK6(s)OJLHqV1neilyykXIVEyQ)eilHDVqryd3SvEfXcadGZcYHfqAEcKLTlf5SGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTugzTnCZw5velamaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5veliwaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5velnjaNfKdlG08eilBxkYzb3OEhzSGuz5HSyLlNfWd4HpyXcmIg)HdlTqsBwAbiK12WnBLxrS0KaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwqmaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwqmaCwqoSasZtGSGUFUcb6nkBAk0XYdzbD)Cfc0BELnnf6yPfGqwBd3SvEfXcIbGZcYHfqAEcKf09ZviqVbqMMcDS8qwq3pxHa9MhqMMcDS0cqiRTHB2kVIyrzaaWzb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIyrzLb4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSOmGa4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSOCSa4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSOmAb4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSOmadGZcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslaHS2gUzR8kIfLbyaCwqoSasZtGSGUFUcb6nkBAk0XYdzbD)Cfc0BELnnf6yPfGqwBd3SvEfXIYamaolihwaP5jqwq3pxHa9gazAk0XYdzbD)Cfc0BEazAk0XslLrwBd3SvEfXIYiwaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTaeYAB4MTYRiwugXcWzb5WcinpbYc6(5keO3OSPPqhlpKf09ZviqV5v20uOJLwkJS2gUzR8kIfLrSaCwqoSasZtGSGUFUcb6naY0uOJLhYc6(5keO38aY0uOJLwaczTnCZCZifXXQnUwvCTAcGZclXyNy5sJGZZshoSGUOHcWuv)rhldHERBiqwWWuIfF9Wu)jqwc7EHIWgUzR8kILybWzb5WcinpbYc6(5keO3OSPPqhlpKf09ZviqV5v20uOJLwXczTnCZw5velOpaNfKdlG08eilO7NRqGEdGmnf6y5HSGUFUcb6npGmnf6yPvSqwBd3m3msrCSAJRvfxRMa4SWsm2jwU0i48S0HdlOZHe6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnBLxrSOmaNfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJf)zXkaiBLS0szK12WnBLxrSelaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5veliwaolihwaP5jqw2UuKZcUr9oYybPIuz5HSyLlNLui4sVWSaJOXF4WslKABwAPmYAB4MTYRiwqSaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAbiK12WnBLxrS0KaCwqoSasZtGSSDPiNfCJ6DKXcsfPYYdzXkxolPqWLEHzbgrJ)WHLwi12S0szK12WnBLxrS0KaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwqmaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwugaaCwqoSasZtGSSDPiNfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPfGqwBd3SvEfXIYXcGZcYHfqAEcKLTlf5SGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTugzTnCZw5velacaaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwaeGa4SGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslLrwBd3SvEfXcGqFaolihwaP5jqw2UuKZcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0cqiRTHB2kVIybqOpaNfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJLwkJS2gUzR8kIfabWa4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSaielaNfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJLwkJS2gUzR8kIfaHya4SGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslaHS2gUzR8kILybaaolihwaP5jqw2UuKZcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0szK12WnZnJuehR24AvX1QjaolSeJDILlncoplD4Wc66Uw)7ZcDSme6TUHazbdtjw81dt9NazjS7fkcB4MTYRiwaeaNfKdlG08eilBxkYzb3OEhzSGuz5HSyLlNfWd4HpyXcmIg)HdlTqsBwAPmYAB4M5MrkIJvBCTQ4A1eaNfwIXoXYLgbNNLoCybD4hDSme6TUHazbdtjw81dt9NazjS7fkcB4MTYRiwugGZcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXsSa4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSOSYaCwqoSasZtGSSDPiNfCJ6DKXcsfPYYdzXkxolPqWLEHzbgrJ)WHLwi12S0szK12WnBLxrSOSYaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwugGbWzb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybqkdWzb5WcinpbYY2LICwWnQ3rglivwEilw5Yzb8aE4dwSaJOXF4WslK0MLwaczTnCZw5velaszaolihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5velacqaCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwauSa4SGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZsRyHS2gUzR8kIfaH(aCwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAbiK12WnBLxrSaiagaNfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJLwkJS2gUzR8kIfaHyb4SGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnZnJuehR24AvX1QjaolSeJDILlncoplD4Wc6uH(Jowgc9w3qGSGHPel(6HP(tGSe29cfHnCZw5velk3KaCwqoSasZtGSSDPiNfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPvSqwBd3SvEfXIYigaolihwaP5jqw2UuKZcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0szK12WnZnBvPrW5jqwqSS4H)Gfl6d)yd3S9w0a7NMS3qAKMLy6AVcelw9zDGCZinsZsCwOw4NfagAybqaaqkZnZnJ0inliF3luegGZnJ0inlnnlXbeKazzdQ9HLysEQHBgPrAwAAwq(UxOiqwEFqrF(6SeCmHz5HSeAe0u(9bf9yd3msJ0S00Sy1sPqGeilRQOaHX(0GfG(CUQMWS06mKbnSeneWm(9bVguelnD8Seneqd(9bVguuBd3msJ0S00SehGWdKLOHco(VcflifJ)7SCDwUhDyw(DIfldSqXIve0xeMmCZinsZstZcajhbIfKdlGqeiw(DILTOBUhZIZI((xtSKchILUMq2PQjwADDwAaxSS7Gf6Ew2VNL7zbFPl97fbxyDdwSC)olXeGCCIbliIfKtAc)NRzjo6dvLs1JgwUhDGSGr4IAB4MrAKMLMMfasocelPq8Zc66hQ9ppuQFfgDSGdu5ZbXS4rr6gS8qwuHyml9d1(Jzbw6ggUzKgPzPPzjgd5plXaMsSa7SetTVZsm1(olXu77S4ywCwWru4Cnl)Cfc0B4MrAKMLMMfaYrurdlTodzqdlifJ)7OHfKIX)D0WY27t)gQnlPoiXskCiwgcF6JQNLhYc5J(OHLamv1)Mg)(8gUzUzKgPzjovbF)jqwIPR9kqSehaQvYsWlwujw6WvbYI)SS)FegGJeKO6AVcutJV0Gb197lvZbrsmDTxbQP3UuKJKuqZ(NQrkD)0KsQU2RazEK9CZCZE4pyHnrdfGPQ(RecxboeyghDZ9yUzKMLyStSa0NZv1elhMfm9S8qwaalwUFNLcYc(9NfyXYctS8ZviqpgnSOmlw2PILFNyPFd(zbwelhMfyXYctOHfaXY1z53jwWuawGSCyw8cKLyXY1zrf(7S4dXn7H)Gf2enuaMQ6pIucja95CvnHMYtjLGvEHP8pxHa9ObORxKsaGB2d)blSjAOamv1FePesa6Z5QAcnLNskbR8ct5FUcb6rdmsjheenaD9Iusz0CDL(5keO3OSz3X5fMYQRExXpxHa9gLnbiudcTugW14)blfw)ZviqVrzZHnpmLYWEofw4FGlCoal8pRWFWcZn7H)Gf2enuaMQ6pIucja95CvnHMYtjLGvEHP8pxHa9ObgPKdcIgGUErkbi0CDL(5keO3aiZUJZlmLvx9UIFUcb6naYeGqni0szaxJ)hSuy9pxHa9gazoS5HPug2ZPWc)dCHZbyH)zf(dwyUzKMLyStyILFUcb6XS4dXsbFw81dt9)cUw3Gfq6PWtGS4ywGfllmXc(9NLFUcb6XgwyzJEwa6Z5QAILhYc6ZIJz53PgS4AmKLIiqwWru4Cnl7EbQVcLHB2d)blSjAOamv1FePesa6Z5QAcnLNskbR8ct5FUcb6rdmsjheenaD9Iuc9rZ1vIqV1ffrGMRWHz9UQMYO3YRFLMbjGxGssi0BDrreOHsJAmKRZWbS8kqjje6TUOic0GHlTM()ku5zP2GB2d)blSjAOamv1FePessHWcHRYD4KYn7H)Gf2enuaMQ6pIucjwg)3rJ(kkhavszaGMRRulkOVimz0RYNCri7tsOG(IWK5QmgQ9jjHc6lctMRYQWFpjHc6lctgVAKlczFBUzUzKMfa6qbh)Saiwqkg)3zXlqwCw2EFWRbfXcSyzlgSy5(DwI7HA)zbGWjw8cKLycJtmyboSS9(0VHyb(70y5We3Sh(dwydmIkAqKsiXY4)oAUUsTOG(IWKrVkFYfHSpjHc6lctMRYyO2NKekOVimzUkRc)9KekOVimz8QrUiK9TveneqJYglJ)7kSoAiGgazSm(VZn7H)Gf2aJOIgePesWVp9Bi0OVIYbqLqlAUUswpRI6WbfzuDTxbkd7zxRZ)(vOWjjwhGaPYR3uhQ9p3DkjXACeP153hu0Jn43NUR1kPCsI1VRP6nL)RHWzvx7vGmu5QAcmjPff0xeMmyO2NCri7tsOG(IWK5QSEv(KKqb9fHjZvzv4VNKqb9fHjJxnYfHSVn3Sh(dwydmIkAqKsib)(Gxdkcn6ROCauj0IMRR0SkQdhuKr11EfOmSNDTo)7xHcRiabsLxVPou7FU7KcCeP153hu0Jn43NUR1kPm3m3msJ0SyfiJcRNazHastdw(lLy53jw8Wdhwomloq)0UQMmCZE4pyHvcd1(KvjpLB2d)blmIucjbxRZE4pyL1h(rt5PKsWiQObnxxP)sja3cqiUh(dwglJ)7MGJ)8FPeI8WFWYGFF63qMGJ)8FPuBUzKMLn6XSehOvWcSyjwiIfl3VdxplGZ1Fw8cKfl3VZY27JgoGS4filacrSa)DASCyIB2d)blmIucja95CvnHMYtjLoC2HeAa66fPeoI0687dk6Xg87t3164vwrlRFxt1BWVpA4aAOYv1eysY7AQEd(jT2Nm4C93qLRQjW2jj4isRZVpOOhBWVpDxRJhqCZinlB0JzjOjhiXILDQyz79PFdXsWlw2VNfaHiwEFqrpMfl7xyNLdZYqAcOxplD4WYVtSyfb9fHjwEilQelrd1Pziqw8cKfl7xyNL(P10WYdzj44NB2d)blmIucja95CvnHMYtjLoCoOjhiHgGUErkHJiTo)(GIESb)(0VHIxzUzKMfRg(CUQMy539NLWofqaZY1zPbCXIpelxXIZcQailpKfhi8az53jwW3V8)Gflw2PHyXz5NRqGEwOpWYHzzHjqwUIfv6TquXsWXpMB2d)blmIucja95CvnHMYtjLUkJkaIgGUErkfneqtkew9BOKKOHaAWRQFdLKeneqd(9bVguuss0qan43NUR1jjrdb00xtJmSNj9QOKe1vVBcE(QGzOu)kSsQRE3e88vbd4A8)Gvss0qanJdKk4cN7dvXUb3msZstGjwIjnyAq4kuSy5(DwqECqIvvbwGdlE)PHfKdlGqeiwUIfKhhKyvvGB2d)blmIucjQ0GPbHRqHMRRuRwwhGaPYR3uhQ9p3DkjX6aeQbHwktawaHiq5FNY4OBUhBwrTvOU6DtWZxfmdL6xHJxz0QqD17MXbsfCHZ9HQy3WmuQFfgWOVcRdqGu51Bas1V3ysscqGu51Bas1V3yuOU6DtWZxfmRifQRE3moqQGlCUpuf7gMvKIwQRE3moqQGlCUpuf7gMHs9RWawzLBA0I4ZQOoCqrg8v9LoV3a)0CEsI6Q3nbpFvWmuQFfgWkRCsIYivCeP15Dh)eGv2Gw02UTcG(CUQMmxLrfa5MrAwaOWNfl3VZIZcYJdsSQkWYV7plhUq3ZIZcaDPX(Ws0adSahwSStfl)oXs)qT)SCywCv46z5HSqfi3Sh(dwyePesIG)bl0CDLux9Uj45RcMHs9RWXRmAv0Y6zvuhoOid(Q(sN3BGFAopjrD17MXbsfCHZ9HQy3WmuQFfgWkJyBAaH4QRE3OQHqq9c)MvKc1vVBghivWfo3hQIDdZkQDsIkeJv0pu7FEOu)kmGbeA5MrAwqURdlT)eMfl70Vtdll8vOyb5WciebILcAHflNwZIR1qlS0aUy5HSG)tRzj44NLFNyb7PelEkCvplWolihwaHiqic5Xbjwvfyj44hZn7H)GfgrkHeG(CUQMqt5PKsbybeIaLbjCJkGgGUErkfOt3Qv)qT)5Hs9RWnTYOTPdqOgeAPmbpFvWmuQFfUnsv5MeaTvkqNUvR(HA)ZdL6xHBALrBthGqni0szcWciebk)7ughDZ9yd4A8)GvthGqni0szcWciebk)7ughDZ9yZqP(v42ivLBsa0wH1JFGzcivVXbbXgczh(XjjbiudcTuMGNVkygk1Vch)vpnrqT)eyUFO2)8qP(v4KKzvuhoOitG0e(pxNXr3Cpwrac1GqlLj45RcMHs9RWXhlaKKeGqni0szcWciebk)7ughDZ9yZqP(v44V6PjcQ9NaZ9d1(Nhk1Vc30kdGKeRdqGu51BQd1(N7oXnJ0S0eycKLhYciP9gS87ellSJIyb2zb5XbjwvfyXYovSSWxHIfq4svtSalwwyIfVazjAiGu9SSWokIfl7uXIxS4GGSqaP6z5WS4QW1ZYdzb8iUzp8hSWisjKa0NZv1eAkpLukaMdWc8(dwObORxKsT6hQ9ppuQFfoELrBsY4hyMas1BCqqS5Q4rlaAROvRwe6TUOic0qPrngY1z4awEfifTcqOgeAPmuAuJHCDgoGLxbYmuQFfgWkdWaqssacKkVEdqQ(9gJIaeQbHwkdLg1yixNHdy5vGmdL6xHbSYamelIAPSYi(SkQdhuKbFvFPZ7nWpnN3UTcRdqOgeAPmuAuJHCDgoGLxbYmKd2ODscHERlkIany4sRP)VcvEwQnu0Y6aeivE9M6qT)5UtjjbiudcTugmCP10)xHkpl1g5yH(OTjbGYMHs9RWawzLr)2jjTcqOgeAPmQ0GPbHRqzgYbBKKy94bY8duRBROvlc9wxuebAUchM17QAkJElV(vAgKaEbsrRaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgjjE4pyzUchM17QAkJElV(vAgKaEbYaEyxvtGTBNK0IqV1ffrGg8UdcTqGz4OMH98dNuQEfbiudcTuMhoPu9ey(k8HA)ZXcTOnwaszZqP(v42jjTAb0NZv1Kbw5fMY)Cfc0RKYjja95CvnzGvEHP8pxHa9kfR2kA9ZviqVrzZqoyJCac1GqlvsYpxHa9gLnbiudcTuMHs9RWXF1tteu7pbM7hQ9ppuQFfUPvgaTtsa6Z5QAYaR8ct5FUcb6vcqkA9ZviqVbqMHCWg5aeQbHwQKKFUcb6naYeGqni0szgk1Vch)vpnrqT)eyUFO2)8qP(v4Mwza0ojbOpNRQjdSYlmL)5keOxja0UD7KKaeivE9geAmNxTtsuHySI(HA)ZdL6xHbS6Q3nbpFvWaUg)pyXnJ0Sy1WNZv1ellmbYYdzbK0Edw8Qbl)Cfc0JzXlqwcGywSStflw87VcflD4WIxSyfROD4ColrdmWn7H)GfgrkHeG(CUQMqt5PKs)(CADgtec0KT43JgGUErkzngU0QxbA(9506mMieOXqLRQjWKK(HA)ZdL6xHJhqaaajjQqmwr)qT)5Hs9RWagqOfrTqFa00QRE387ZP1zmriqJb)EabehqTtsux9U53NtRZyIqGgd(9acXhRMSPBnRI6WbfzWx1x68Ed8tZ5ioABZnJ0S0eyIfRinQXqUMfaYdy5vGybqaatbmlQuhoelolipoiXQQallmz4M9WFWcJiLqYct57Pu0uEkPeLg1yixNHdy5vGqZ1vkaHAqOLYe88vbZqP(vyadiaOiaHAqOLYeGfqicu(3Pmo6M7XMHs9RWagqaqrlG(CUQMm)(CADgtec0KT43NKOU6DZVpNwNXeHang87beIpwaarTMvrD4GIm4R6lDEVb(P5CehG1UTcG(CUQMmxLrfatsuHySI(HA)ZdL6xHbCSqSCZinlnbMyzdU0A6VcflwTl1gSaWWuaZIk1HdXIZcYJdsSQkWYctgUzp8hSWisjKSWu(EkfnLNskHHlTM()ku5zP2anxxPwbiudcTuMGNVkygk1VcdyaMcRdqGu51Bas1V3yuyDacKkVEtDO2)C3PKKaeivE9M6qT)5UtkcqOgeAPmbybeIaL)DkJJU5ESzOu)kmGbykAb0NZv1KjalGqeOmiHBuHKKaeQbHwktWZxfmdL6xHbmaRDssacKkVEdqQ(9gJIwwpRI6WbfzWx1x68Ed8tZ5kcqOgeAPmbpFvWmuQFfgWaSKe1vVBghivWfo3hQIDdZqP(vyaRm6JOwOfXj0BDrreO5k8pRWdhCg8aEfLvjTUTc1vVBghivWfo3hQIDdZkQDss)qT)5Hs9RWagqOnjHqV1ffrGgknQXqUodhWYRaPiaHAqOLYqPrngY1z4awEfiZqP(v44beaARaOpNRQjZvzubqfwtO36IIiqZv4WSExvtz0B51VsZGeWlqjjbiudcTuMRWHz9UQMYO3YRFLMbjGxGmdL6xHJhqaijrfIXk6hQ9ppuQFfgWacaCZinlXrBXBGzzHjwSkRMT6Sy5(DwqECqIvvbUzp8hSWisjKa0NZv1eAkpLu6qpWCawG3FWcnaD9IusD17MGNVkygk1VchVYOvrlRNvrD4GIm4R6lDEVb(P58Ke1vVBghivWfo3hQIDdZqP(vyaRKYaYaie1kwiU6Q3nQAieuVWVzf1grTAYMgTiU6Q3nQAieuVWVzf1gXj0BDrreO5k8pRWdhCg8aEfLvjTUTc1vVBghivWfo3hQIDdZkkjrfIXk6hQ9ppuQFfgWacTjje6TUOic0qPrngY1z4awEfifbiudcTugknQXqUodhWYRazgk1VcZn7H)GfgrkHKfMY3tPOP8usPRWHz9UQMYO3YRFLMbjGxGqZ1vcOpNRQjZHEG5aSaV)GLcG(CUQMmxLrfa5MrAwAcmXYCO2FwuPoCiwcGyUzp8hSWisjKSWu(EkfnLNskH3DqOfcmdh1mSNF4Ks1JMRRuRaeQbHwktWZxfmd5GnuyDacKkVEtDO2)C3jfa95Cvnz(9506mMieOjBXVpjjabsLxVPou7FU7KIaeQbHwktawaHiq5FNY4OBUhBgYbBOOfqFoxvtMaSacrGYGeUrfsscqOgeAPmbpFvWmKd2ODBfGW3Gxv)gY8xaHRqPOfi8n4N0AFYDTpK5VacxHkjX631u9g8tATp5U2hYqLRQjWKeCeP153hu0Jn43N(nu8XQTIwGW3KcHv)gY8xaHRq1wrlG(CUQMmho7qkjzwf1HdkYO6AVcug2ZUwN)9RqHtsC8pUohbTqt8kHyaqsI6Q3nQAieuVWVzf1wrRaeQbHwkJknyAq4kuMHCWgjjwpEGm)a162kSMqV1ffrGMRWHz9UQMYO3YRFLMbjGxGssi0BDrreO5kCywVRQPm6T86xPzqc4fifTcqOgeAPmxHdZ6DvnLrVLx)kndsaVazgk1VchFSaqssac1GqlLrLgmniCfkZqP(v44JfaARWA1vVBcE(QGzfLKOcXyf9d1(Nhk1Vcdy0haCZinlXy)WSCywCwg)3PHfs7QWXFIflEdwEilPocelUwZcSyzHjwWV)S8ZviqpMLhYIkXI(kcKLvelwUFNfKhhKyvvGfVazb5WciebIfVazzHjw(DIfavGSG1WNfyXsaKLRZIk83z5NRqGEml(qSalwwyIf87pl)Cfc0J5M9WFWcJiLqYct57PumAWA4Jv6NRqGELrZ1vQfqFoxvtgyLxyk)ZviqV1kPScR)5keO3aiZqoyJCac1GqlvsslG(CUQMmWkVWu(NRqGELuojbOpNRQjdSYlmL)5keOxPy1wrl1vVBcE(QGzfPOL1biqQ86naP63BmjjQRE3moqQGlCUpuf7gMHs9RWiQfAr8zvuhoOid(Q(sN3BGFAoVnGv6NRqGEJYg1vVNbxJ)hSuOU6DZ4aPcUW5(qvSBywrjjQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzf1ojjaHAqOLYe88vbZqP(vyebO4)5keO3OSjaHAqOLYaUg)pyPWA1vVBcE(QGzfPOL1biqQ86n1HA)ZDNssSgOpNRQjtawaHiqzqc3OcTvyDacKkVEdcnMZRKKaeivE9M6qT)5Utka6Z5QAYeGfqicugKWnQGIaeQbHwktawaHiq5FNY4OBUhBwrkSoaHAqOLYe88vbZksrRwQRE3qb9fHPSEv(ygk1VchVYaijrD17gkOVimLXqTpMHs9RWXRmaARW6zvuhoOiJQR9kqzyp7AD(3VcfojPL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9ackH2Ke1vVBuDTxbkd7zxRZ)(vOWzFcErg87beuQjB3ojrD17geUcCiWmLgbTqtkvFMkAqDXMmRO2jj9d1(Nhk1VcdyabGKeG(CUQMmWkVWu(NRqGELaqBfa95CvnzUkJkaYn7H)GfgrkHKfMY3tPy0G1WhR0pxHa9acnxxPwa95CvnzGvEHP8pxHa9wReGuy9pxHa9gLnd5GnYbiudcTujja95CvnzGvEHP8pxHa9kbifTux9Uj45RcMvKIwwhGaPYR3aKQFVXKKOU6DZ4aPcUW5(qvSBygk1VcJOwOfXNvrD4GIm4R6lDEVb(P582awPFUcb6naYOU69m4A8)GLc1vVBghivWfo3hQIDdZkkjrD17MXbsfCHZ9HQy3iJVQV059g4NMZnRO2jjbiudcTuMGNVkygk1VcJiaf)pxHa9gazcqOgeAPmGRX)dwkSwD17MGNVkywrkAzDacKkVEtDO2)C3PKeRb6Z5QAYeGfqicugKWnQqBfwhGaPYR3GqJ58srlRvx9Uj45RcMvusI1biqQ86naP63BmTtscqGu51BQd1(N7oPaOpNRQjtawaHiqzqc3OckcqOgeAPmbybeIaL)DkJJU5ESzfPW6aeQbHwktWZxfmRifTAPU6Ddf0xeMY6v5JzOu)kC8kdGKe1vVBOG(IWugd1(ygk1VchVYaOTcRNvrD4GImQU2RaLH9SR15F)ku4KKwQRE3O6AVcug2ZUwN)9RqHZL)RHm43diOeAtsux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqqPMSD72jjQRE3GWvGdbMP0iOfAsP6ZurdQl2KzfLKOcXyf9d1(Nhk1VcdyabGKeG(CUQMmWkVWu(NRqGELaqBfa95CvnzUkJkaYnJ0S0eycZIR1Sa)DAybwSSWel3tPywGflbqUzp8hSWisjKSWu(EkfZnJ0Sy1PWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDyUzp8hSWisjKmRk7H)GvwF4hnLNsk5qcn4FUWRKYO56kb0NZv1K5WzhsCZE4pyHrKsizwv2d)bRS(WpAkpLusf6pAW)CHxjLrZ1vAwf1HdkYO6AVcug2ZUwN)9RqHne6TUOicKB2d)blmIucjZQYE4pyL1h(rt5PKs4NBMBgPzb5UoS0(tywSSt)onS87elw9H80G)HDAyrD17Sy50Aw6UwZcS3zXY97xXYVtSueYEwco(5M9WFWcBCiPeqFoxvtOP8usjWH80SLtRZDxRZWEhnaD9IuQL6Q3n)LswGtLbhYtvVcKgZqP(vyaJkaAsDKHiayuojrD17M)sjlWPYGd5PQxbsJzOu)kmG9WFWYGFF63qgczuy9u(VucraWOSIwuqFryYCvwVkFssOG(IWKbd1(KlczFscf0xeMmE1ixeY(2TvOU6DZFPKf4uzWH8u1RaPXSIumRI6Wbfz(lLSaNkdoKNQEfinCZinli31HL2FcZILD63PHLT3h8AqrSCywSaNFNLGJ)RqXceinSS9(0VHy5kwSYv5dlwrqFryIB2d)blSXHeIucja95CvnHMYtjLoufCOm(9bVgueAa66fPK1uqFryYCvgd1(OOfoI0687dk6Xg87t)gkE0Q4DnvVbdx6mSN)Dk3HdHFdvUQMatsWrKwNFFqrp2GFF63qXJyBZnJ0S0eyIfKdlGqeiwSStfl(ZIMWyw(DVybTaGL4GbOS4fil6RiwwrSy5(DwqECqIvvbUzp8hSWghsisjKeGfqicu(3Pmo6M7XO56kzn4SoqtbZbqSIwTa6Z5QAYeGfqicugKWnQGcRdqOgeAPmbpFvWmKd2ijrD17MGNVkywrTv0sD17gkOVimL1RYhZqP(v44byjjQRE3qb9fHPmgQ9XmuQFfoEawBfTSEwf1HdkYO6AVcug2ZUwN)9RqHtsux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqi(yLKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGq8XQDsIkeJv0pu7FEOu)kmGvgakSoaHAqOLYe88vbZqoyJ2CZinlnbMybGyOk2nyXY97SG84GeRQcCZE4pyHnoKqKsizCGubx4CFOk2nqZ1vsD17MGNVkygk1VchVYOLBgPzPjWelBRQFdXYvSe5fiLEbwGflE143Vcfl)U)SOpGeMfLrFmfWS4filAcJzXY97SKchIL3hu0JzXlqw8NLFNyHkqwGDwCw2GAFyXkc6lctS4plkJ(SGPaMf4WIMWywgk1V6kuS4ywEilf8zz3bEfkwEild1hcVZc4AUcflw5Q8HfRiOVimXn7H)Gf24qcrkHe8Q63qOj0iOP87dk6XkPmAUUsTgQpeE3v1usI6Q3nuqFrykJHAFmdL6xHbCSuqb9fHjZvzmu7JIHs9RWawz0xX7AQEdgU0zyp)7uUdhc)gQCvnb2wX7dk6n)Ls5hMbpkELr)MghrAD(9bf9yenuQFfwrlkOVimzUk7vJKKHs9RWagva0K6iRn3msZstGjw2wv)gILhYYUdKyXzbLgQ6AwEillmXIvz1SvNB2d)blSXHeIucj4v1VHqZ1vcOpNRQjZHEG5aSaV)GLIaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgki0BDrreO5kCywVRQPm6T86xPzqc4fiUzp8hSWghsisjKGFF6UwJMRRK1VRP6n4N0AFYGZ1FdvUQMav0sD17g87t31AZq9HW7UQMu0chrAD(9bf9yd(9P7AnGJvsI1ZQOoCqrM)sjlWPYGd5PQxbst7KK31u9gmCPZWE(3PChoe(nu5QAcuH6Q3nuqFrykJHAFmdL6xHbCSuqb9fHjZvzmu7Jc1vVBWVpDxRndL6xHbmIvboI0687dk6Xg87t3164vc9BROL1ZQOoCqrgDJGpoo31e9xHkJsFPrykj5VucPIurF0gV6Q3n43NUR1MHs9RWicqTv8(GIEZFPu(HzWJIhTCZinlif3VZY2tATpSy1NR)SSWelWILailw2PILH6dH3DvnXI66zb)NwZIf)Ew6WHfRSrWhhZs0adS4filGWcDpllmXIk1HdXcYT6ydlB)P1SSWelQuhoelihwaHiqSGVkqS87(ZILtRzjAGbw8c(70WY27t31AUzp8hSWghsisjKGFF6UwJMRR07AQEd(jT2Nm4C93qLRQjqfQRE3GFF6UwBgQpeE3v1KIwwpRI6Wbfz0nc(44Cxt0FfQmk9LgHPKK)sjKksf9rB8OFBfVpOO38xkLFyg8O4Jf3msZcsX97Sy1hYtvVcKgwwyILT3NUR1S8qwqGOiwwrS87elQRENf1gS4AmKLf(kuSS9(0DTMfyXcAzbtbybIzboSOjmMLHs9RUcf3Sh(dwyJdjePesWVpDxRrZ1vAwf1HdkY8xkzbovgCipv9kqAuGJiTo)(GIESb)(0DToELILIwwRU6DZFPKf4uzWH8u1RaPXSIuOU6Dd(9P7ATzO(q4DxvtjjTa6Z5QAYaoKNMTCADU7ADg27kAPU6Dd(9P7ATzOu)kmGJvscoI0687dk6Xg87t3164bKI31u9g8tATpzW56VHkxvtGkux9Ub)(0DT2muQFfgWOTD72CZinli31HL2FcZILD63PHfNLT3h8AqrSSWelwoTMLGVWelBVpDxRz5HS0DTMfyVJgw8cKLfMyz79bVguelpKfeikIfR(qEQ6vG0Wc(9acSSI4M9WFWcBCiHiLqcqFoxvtOP8usj87t316Sfy95UR1zyVJgGUErk54FCDocAHM4Bsa00TugaiU6Q3n)LswGtLbhYtvVcKgd(9acTB6wQRE3GFF6UwBgk1VcJ4XcPIJiToV74NqCRFxt1BWpP1(KbNR)gQCvnb2UPBfGqni0szWVpDxRndL6xHr8yHuXrKwN3D8ti(7AQEd(jT2Nm4C93qLRQjW2nDlq4B6RPrg2ZKEvKzOu)kmIJ22kAPU6Dd(9P7ATzfLKeGqni0szWVpDxRndL6xHBZnJ0S0eyILT3h8AqrSy5(DwS6d5PQxbsdlpKfeikILvel)oXI6Q3zXY97W1ZIgIVcflBVpDxRzzf9xkXIxGSSWelBVp41GIybwSG(iILycJtmyb)EabmlR6pnlOplVpOOhZn7H)Gf24qcrkHe87dEnOi0CDLa6Z5QAYaoKNMTCADU7ADg27ka6Z5QAYGFF6UwNTaRp3DTod7Dfwd0NZv1K5qvWHY43h8AqrjjTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqi(yLKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGq8XQTcCeP153hu0Jn43NUR1ag9va0NZv1Kb)(0DToBbwFU7ADg27CZinlnbMybBXNuwWqw(D)zPbCXck6zj1rglRO)sjwuBWYcFfkwUNfhZI2FIfhZseeJpvnXcSyrtyml)UxSelwWVhqaZcCybPKf(zXYovSeleXc(9acywiKfDdXn7H)Gf24qcrkHeh0J(diLXw8jfnHgbnLFFqrpwjLrZ1vY6)ciCfkfw7H)GLXb9O)aszSfFsZGEQJImxL76d1(NKacFJd6r)bKYyl(KMb9uhfzWVhqaWXsbi8noOh9hqkJT4tAg0tDuKzOu)kmGJf3msZIvl1hcVZcajiS63qSCDwqECqIvvbwomld5Gnqdl)onel(qSOjmMLF3lwqllVpOOhZYvSyLRYhwSIG(IWelwUFNLn4dqGgw0egZYV7flkdawG)onwomXYvS4vdwSIG(IWelWHLvelpKf0YY7dk6XSOsD4qS4SyLRYhwSIG(IWKHfRoSq3ZYq9HW7SaUMRqXcs5RahcKfRincAHMuQEwwLMWywUILnO2hwSIG(IWe3Sh(dwyJdjePessHWQFdHMqJGMYVpOOhRKYO56knuFi8URQjfVpOO38xkLFyg8O4B1sz0hrTWrKwNFFqrp2GFF63qioGqC1vVBOG(IWuwVkFmRO2Tr0qP(v42i1wkJO31u9M3Yv5uiSWgQCvnb2wrRaeQbHwktWZxfmd5Gnuyn4SoqtbZbqSIwa95CvnzcWciebkds4gvijjaHAqOLYeGfqicu(3Pmo6M7XMHCWgjjwhGaPYR3uhQ9p3DQDscoI0687dk6Xg87t)gcWTAbWA6wQRE3qb9fHPSEv(ywrioGA3gXBPmIExt1BElxLtHWcBOYv1ey72kSMc6lctgmu7tUiK9jjTOG(IWK5QmgQ9jjPff0xeMmxLvH)Escf0xeMmxL1RYN2kS(DnvVbdx6mSN)Dk3HdHFdvUQMatsux9UjAUu4aEUo7tWRlKJwASpgGUErXReGqlaAROfoI0687dk6Xg87t)gcWkdaeVLYi6DnvV5TCvofclSHkxvtGTBRWX)46Ce0cnXJwa00QRE3GFF6UwBgk1VcJ4aS2kAzT6Q3niCf4qGzkncAHMuQ(mv0G6InzwrjjuqFryYCvgd1(KKyDacKkVEdcnMZR2kSwD17MXbsfCHZ9HQy3iJVQV059g4NMZnRiUzKMLMatSaqaJllWILailwUFhUEwcEu0vO4M9WFWcBCiHiLqshobkd75Y)1qO56k5r5WofqGB2d)blSXHeIucja95CvnHMYtjLcG5aSaV)Gv2HeAa66fPK1GZ6anfmhaXka6Z5QAYeaZbybE)blfTAPU6Dd(9P7ATzfLK8UMQ3GFsR9jdox)nu5QAcmjjabsLxVPou7FU7uBfTSwD17gmuJ)lqMvKcRvx9Uj45RcMvKIww)UMQ30xtJmSNj9QidvUQMatsux9Uj45RcgW14)bR4dqOgeAPm910id7zsVkYmuQFfgrnzBfa95Cvnz(9506mMieOjBXVxrlRdqGu51BQd1(N7oLKeGqni0szcWciebk)7ughDZ9yZksrl1vVBWVpDxRndL6xHbmGssS(DnvVb)Kw7tgCU(BOYv1ey72kEFqrV5Vuk)Wm4rXRU6DtWZxfmGRX)dwioami22jjQqmwr)qT)5Hs9RWawD17MGNVkyaxJ)hSAZnJ0S0eyIfKhhKyvvGfyXsaKLvPjmMfVazrFfXY9SSIyXY97SGCybeIaXn7H)Gf24qcrkHKaPj8FUo76dvLs1JMRReqFoxvtMayoalW7pyLDiXn7H)Gf24qcrkHKRc(u(FWcnxxjG(CUQMmbWCawG3FWk7qIBgPzPjWelwrAe0cnSetybYcSyjaYIL73zz79P7AnlRiw8cKfSdKyPdhwaOln2hw8cKfKhhKyvvGB2d)blSXHeIucjuAe0cnzvybIMRR0vpnrqT)eyUFO2)8qP(vyaRmAtsAPU6Dt0CPWb8CD2NGxxihT0yFmaD9IamGqlassux9UjAUu4aEUo7tWRlKJwASpgGUErXReGqlaARqD17g87t31AZksrRaeQbHwktWZxfmdL6xHJhTaijbCwhOPG5aiUn3msZIvl1hcVZsx7dXcSyzfXYdzjwS8(GIEmlwUFhUEwqECqIvvbwuPRqXIRcxplpKfczr3qS4filf8zbcKMGhfDfkUzp8hSWghsisjKGFsR9j31(qOj0iOP87dk6XkPmAUUsd1hcV7QAsXFPu(HzWJIxz0QahrAD(9bf9yd(9PFdby0xHhLd7uabfTux9Uj45RcMHs9RWXRmassSwD17MGNVkywrT5MrAwAcmXcab0ky56SCf(ajw8IfRiOVimXIxGSOVIy5EwwrSy5(DwCwaOln2hwIgyGfVazjoGE0Fajw2S4tk3Sh(dwyJdjePes6RPrg2ZKEveAUUsuqFryYCv2Rgk8OCyNciOqD17MO5sHd456SpbVUqoAPX(ya66fbyaHwaOOfi8noOh9hqkJT4tAg0tDuK5VacxHkjX6aeivE9MIcdudhWKeCeP153hu0JJhqTv0sD17MXbsfCHZ9HQy3WmuQFfgWiMMUfAr8zvuhoOid(Q(sN3BGFAoVTc1vVBghivWfo3hQIDdZkkjXA1vVBghivWfo3hQIDdZkQTIwwhGqni0szcE(QGzfLKOU6DZVpNwNXeHang87beaSYOvr)qT)5Hs9RWagqaaak6hQ9ppuQFfoELbaassSgdxA1Ran)(CADgtec0yOYv1eyBfTWWLw9kqZVpNwNXeHangQCvnbMKeGqni0szcE(QGzOu)kC8XcaT5MrAwAcmXIZY27t31Awaix0VZs0adSSknHXSS9(0DTMLdZIRhYbBWYkIf4Wsd4IfFiwCv46z5HSabstWJyjoyak3Sh(dwyJdjePesWVpDxRrZ1vsD17gyr)oohrtGI(dwMvKIwQRE3GFF6UwBgQpeE3v1usIJ)X15iOfAIhXaG2CZinlw9vAelXbdqzrL6WHyb5WciebIfl3VZY27t31Aw8cKLFNkw2EFWRbfXn7H)Gf24qcrkHe87t31A0CDLcqGu51BQd1(N7oPW631u9g8tATpzW56VHkxvtGkAb0NZv1KjalGqeOmiHBuHKKaeQbHwktWZxfmROKe1vVBcE(QGzf1wrac1GqlLjalGqeO8VtzC0n3JndL6xHbmQaOj1rgIhOt3YX)46Ce0cniv0cG2kux9Ub)(0DT2muQFfgWOVcRbN1bAkyoaI5M9WFWcBCiHiLqc(9bVgueAUUsbiqQ86n1HA)ZDNu0cOpNRQjtawaHiqzqc3OcjjbiudcTuMGNVkywrjjQRE3e88vbZkQTIaeQbHwktawaHiq5FNY4OBUhBgk1VcdyaMc1vVBWVpDxRnRifuqFryYCv2RgkSgOpNRQjZHQGdLXVp41GIuyn4SoqtbZbqm3msZstGjw2EFWRbfXIL73zXlwaix0VZs0adSahwUolnGl0bYceinbpIL4GbOSy5(DwAaxdlfHSNLGJFdlXrJHSaUsJyjoyakl(ZYVtSqfilWol)oXIvdQ(9gdlQRENLRZY27t31AwSaxAWcDplDxRzb27SahwAaxS4dXcSybqS8(GIEm3Sh(dwyJdjePesWVp41GIqZ1vsD17gyr)ooh0KpzGh(GLzfLK0YA87t)gY4r5WofqqH1a95CvnzoufCOm(9bVguussl1vVBcE(QGzOu)kmGrRc1vVBcE(QGzfLK0QL6Q3nbpFvWmuQFfgWOcGMuhziEGoDlh)JRZrql0GuJfaARqD17MGNVkywrjjQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzOu)kmGrfanPoYq8aD6wo(hxNJGwObPgla0wH6Q3nJdKk4cN7dvXUrgFvFPZ7nWpnNBwrTveGaPYR3aKQFVX0UTIw4isRZVpOOhBWVpDxRbCSssa6Z5QAYGFF6UwNTaRp3DTod792TvynqFoxvtMdvbhkJFFWRbfPOL1ZQOoCqrM)sjlWPYGd5PQxbstscoI0687dk6Xg87t31AahR2CZinlnbMybGeewywUILnO2hwSIG(IWelEbYc2bsSaqS0AwaibHflD4WcYJdsSQkWn7H)Gf24qcrkHKISKtHWcnxxPwQRE3qb9fHPmgQ9XmuQFfoEczuy9u(VukjPvy3huewjaPyOWUpOO8FPeGrB7KKWUpOiSsXQTcpkh2PacCZE4pyHnoKqKsiz319CkewO56k1sD17gkOVimLXqTpMHs9RWXtiJcRNY)LsjjTc7(GIWkbifdf29bfL)lLamABNKe29bfHvkwTv4r5Wofqqrl1vVBghivWfo3hQIDdZqP(vyaJwfQRE3moqQGlCUpuf7gMvKcRNvrD4GIm4R6lDEVb(P58KeRvx9UzCGubx4CFOk2nmRO2CZE4pyHnoKqKsiPV06CkewO56k1sD17gkOVimLXqTpMHs9RWXtiJcRNY)LskAfGqni0szcE(QGzOu)kC8OfajjbiudcTuMaSacrGY)oLXr3Cp2muQFfoE0cG2jjTc7(GIWkbifdf29bfL)lLamABNKe29bfHvkwTv4r5Wofqqrl1vVBghivWfo3hQIDdZqP(vyaJwfQRE3moqQGlCUpuf7gMvKcRNvrD4GIm4R6lDEVb(P58KeRvx9UzCGubx4CFOk2nmRO2CZinlnbMybPaAfSalwqUvNB2d)blSXHeIucjw8zo4KH9mPxfXnJ0SGCxhwA)jmlw2PFNgwEillmXY27t)gILRyzdQ9Hfl7xyNLdZI)SGwwEFqrpgrkZshoSqaPPblacaivwsD8ttdwGdlOplBVp41GIyXksJGwOjLQNf87beWCZE4pyHnoKqKsibOpNRQj0uEkPe(9PFdLVkJHAFqdqxViLWrKwNFFqrp2GFF63qXJ(iQRHWPvQJFAAKb66fH4kdaaGubeaAJOUgcNwQRE3GFFWRbfLP0iOfAsP6ZyO2hd(9aciv0Vn3msZcYDDyP9NWSyzN(DAy5HSGum(VZc4AUcflaedvXUb3Sh(dwyJdjePesa6Z5QAcnLNskzz8FpFvUpuf7gObORxKskJuXrKwN3D8tagqnDlayaeI3chrAD(9bf9yd(9PFd10k3gXBPmIExt1BWWLod75FNYD4q43qLRQjqexzdAB3graWOmArC1vVBghivWfo3hQIDdZqP(vyUzKMLMatSGum(VZYvSSb1(WIve0xeMyboSCDwkilBVp9BiwSCAnl97z5QhYcYJdsSQkWIxnsHdXn7H)Gf24qcrkHelJ)7O56k1Ic6lctg9Q8jxeY(KekOVimz8QrUiK9ka6Z5QAYC4CqtoqQTIwVpOO38xkLFyg8O4r)KekOVimz0RYN8vzaLK0pu7FEOu)kmGvgaTtsux9UHc6lctzmu7JzOu)kmG9WFWYGFF63qgczuy9u(VusH6Q3nuqFrykJHAFmROKekOVimzUkJHAFuynqFoxvtg87t)gkFvgd1(KKOU6DtWZxfmdL6xHbSh(dwg87t)gYqiJcRNY)LskSgOpNRQjZHZbn5ajfQRE3e88vbZqP(vyatiJcRNY)Lskux9Uj45RcMvusI6Q3nJdKk4cN7dvXUHzfPaOpNRQjJLX)98v5(qvSBKKynqFoxvtMdNdAYbskux9Uj45RcMHs9RWXtiJcRNY)LsCZinlnbMyz79PFdXY1z5kwSYv5dlwrqFrycnSCflBqTpSyfb9fHjwGflOpIy59bf9ywGdlpKLObgyzdQ9HfRiOVimXn7H)Gf24qcrkHe87t)gIBgPzbGW16FFwCZE4pyHnoKqKsizwv2d)bRS(WpAkpLuQ7A9VplUzUzKMfaIHQy3Gfl3VZcYJdsSQkWn7H)Gf2Oc9xPXbsfCHZ9HQy3anxxj1vVBcE(QGzOu)kC8kJwUzKMLMatSehqp6pGelBw8jLfl7uXI)SOjmMLF3lwqFwIjmoXGf87beWS4filpKLH6dH3zXzbWkbiwWVhqGfhZI2FIfhZseeJpvnXcCy5VuIL7zbdz5Ew8zoGeMfKsw4NfV)0WIZsSqel43diWcHSOBim3Sh(dwyJk0FePesCqp6pGugBXNu0eAe0u(9bf9yLugnxxj1vVBuDTxbkd7zxRZ)(vOW5Y)1qg87beaCtQqD17gvx7vGYWE2168VFfkC2NGxKb)Eaba3KkAzni8noOh9hqkJT4tAg0tDuK5VacxHsH1E4pyzCqp6pGugBXN0mON6OiZv5U(qT)kAzni8noOh9hqkJT4tAENCT5VacxHkjbe(gh0J(diLXw8jnVtU2muQFfo(y1ojbe(gh0J(diLXw8jnd6PokYGFpGaGJLcq4BCqp6pGugBXN0mON6OiZqP(vyaJwfGW34GE0FaPm2IpPzqp1rrM)ciCfQ2CZinlnbMyb5WciebIfl3VZcYJdsSQkWILDQyjcIXNQMyXlqwG)onwomXIL73zXzjMW4edwux9olw2PIfqc3OcxHIB2d)blSrf6pIucjbybeIaL)DkJJU5EmAUUswdoRd0uWCaeROvlG(CUQMmbybeIaLbjCJkOW6aeQbHwktWZxfmd5Gnssux9Uj45RcMvuBfTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqqPMmjrD17gvx7vGYWE2168VFfkC2NGxKb)EabLAY2jjQqmwr)qT)5Hs9RWawza0MBgPzbGaAfS4yw(DIL(n4NfubqwUILFNyXzjMW4edwSCfi0clWHfl3VZYVtSGuUXCEXI6Q3zboSy5(DwCwAseHPalXb0J(diXYMfFszXlqwS43ZshoSG84GeRQcSCDwUNflW6zrLyzfXIJYVIfvQdhILFNyjaYYHzPF1H3jqUzp8hSWgvO)isjK0xtJmSNj9Qi0CDLA1QL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acXdWssux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqiEawBfTSoabsLxVbiv)EJjjXA1vVBghivWfo3hQIDdZkQDBfTaN1bAkyoaItscqOgeAPmbpFvWmuQFfoE0cGKKwbiqQ86n1HA)ZDNueGqni0szcWciebk)7ughDZ9yZqP(v44rlaA3UDsslq4BCqp6pGugBXN0mON6OiZqP(v44BsfbiudcTuMGNVkygk1VchVYaqracKkVEtrHbQHdy7KKREAIGA)jWC)qT)5Hs9RWaUjvyDac1GqlLj45RcMHCWgjjbiqQ86ni0yoVuOU6DdcxboeyMsJGwOjLQ3SIsscqGu51Bas1V3yuOU6DZ4aPcUW5(qvSBygk1VcdyeJc1vVBghivWfo3hQIDdZkIBgPzb5EfinlBVpA4aYIL73zXzPilSetyCIblQRENfVazb5Xbjwvfy5Wf6EwCv46z5HSOsSSWei3Sh(dwyJk0FePescEfiDwD17OP8usj87JgoGO56k1sD17gvx7vGYWE2168VFfkCU8FnKzOu)kC8iwdAtsux9Ur11EfOmSNDTo)7xHcN9j4fzgk1VchpI1G22kAfGqni0szcE(QGzOu)kC8i2KKwbiudcTugkncAHMSkSandL6xHJhXQWA1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIueGaPYR3GqJ58QDBfo(hxNJGwOjELIfa4MrAwS6R0iw2EFWRbfHzXY97S4SetyCIblQRENf11ZsbFwSStflrqO(kuS0HdlipoiXQQalWHfKYxboeilBr3CpMB2d)blSrf6pIucj43h8AqrO56k1sD17gvx7vGYWE2168VFfkCU8FnKb)EaH4busI6Q3nQU2RaLH9SR15F)ku4SpbVid(9acXdO2kAfGaPYR3uhQ9p3DkjjaHAqOLYe88vbZqP(v44rSjjwd0NZv1KjaMdWc8(dwkSoabsLxVbHgZ5vssRaeQbHwkdLgbTqtwfwGMHs9RWXJyvyT6Q3niCf4qGzkncAHMuQ(mv0G6InzwrkcqGu51BqOXCE1UTIwwdcFtFnnYWEM0RIm)fq4kujjwhGqni0szcE(QGzihSrsI1biudcTuMaSacrGY)oLXr3Cp2mKd2On3msZIvFLgXY27dEnOimlQuhoelihwaHiqCZE4pyHnQq)rKsib)(GxdkcnxxPwbiudcTuMaSacrGY)oLXr3Cp2muQFfgWOvH1GZ6anfmhaXkAb0NZv1KjalGqeOmiHBuHKKaeQbHwktWZxfmdL6xHbmABRaOpNRQjtamhGf49hSARWAq4B6RPrg2ZKEvK5VacxHsracKkVEtDO2)C3jfwdoRd0uWCaeRGc6lctMRYE1qHJ)X15iOfAIh9ba3msZIvhwO7zbe(SaUMRqXYVtSqfilWolwToqQGlmlaedvXUbAybCnxHIfeUcCiqwO0iOfAsP6zboSCfl)oXI2XplOcGSa7S4flwrqFryIB2d)blSrf6pIucja95CvnHMYtjLaHFEi0BDdLs1JrdqxViLAPU6DZ4aPcUW5(qvSBygk1VchpAtsSwD17MXbsfCHZ9HQy3WSIAROL6Q3niCf4qGzkncAHMuQ(mv0G6Inzgk1VcdyubqtQJS2kAPU6Ddf0xeMYyO2hZqP(v44rfanPoYssux9UHc6lctz9Q8XmuQFfoEubqtQJS2CZE4pyHnQq)rKsibVQ(neAcncAk)(GIESskJMRR0q9HW7UQMu8(GIEZFPu(HzWJIxzaMcpkh2Packa6Z5QAYac)8qO36gkLQhZn7H)Gf2Oc9hrkHKuiS63qOj0iOP87dk6XkPmAUUsd1hcV7QAsX7dk6n)Ls5hMbpkELJLbTk8OCyNciOaOpNRQjdi8ZdHERBOuQEm3Sh(dwyJk0FePesWpP1(K7AFi0eAe0u(9bf9yLugnxxPH6dH3DvnP49bf9M)sP8dZGhfVYamenuQFfwHhLd7uabfa95CvnzaHFEi0BDdLs1J5MrAwaiGXLfyXsaKfl3Vdxplbpk6kuCZE4pyHnQq)rKsiPdNaLH9C5)Ai0CDL8OCyNciWnJ0SyfPrql0WsmHfilw2PIfxfUEwEilu90WIZsrwyjMW4edwSCfi0clEbYc2bsS0HdlipoiXQQa3Sh(dwyJk0FePesO0iOfAYQWcenxxPwuqFryYOxLp5Iq2NKqb9fHjdgQ9jxeY(KekOVimz8QrUiK9jjQRE3O6AVcug2ZUwN)9RqHZL)RHmdL6xHJhXAqBsI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(v44rSg0MK44FCDocAHM4rmaqrac1GqlLj45RcMHCWgkSgCwhOPG5aiUTIwbiudcTuMGNVkygk1VchFSaqssac1GqlLj45RcMHCWgTtsU6PjcQ9NaZ9d1(Nhk1VcdyLba3msZcab0kyzou7plQuhoell8vOyb5XHB2d)blSrf6pIucj910id7zsVkcnxxPaeQbHwktWZxfmd5Gnua0NZv1KjaMdWc8(dwkA54FCDocAHM4rmaqH1biqQ86n1HA)ZDNsscqGu51BQd1(N7oPWX)46Ce0cnag9bqBfwhGaPYR3aKQFVXOOL1biqQ86n1HA)ZDNsscqOgeAPmbybeIaL)DkJJU5ESzihSrBfwdoRd0uWCaeZnJ0SG84GeRQcSyzNkw8NfedaqelXbdqzPfC0ql0WYV7flOpayjoyaklwUFNfKdlGqeO2Sy5(D46zrdXxHIL)sjwUILyQHqq9c)S4fil6RiwwrSy5(DwqoSacrGy56SCplwCmlGeUrfiqUzp8hSWgvO)isjKa0NZv1eAkpLukaMdWc8(dwzvO)ObORxKswdoRd0uWCaeRaOpNRQjtamhGf49hSu0QLJ)X15iOfAIhXaafTux9UbHRahcmtPrql0Ks1NPIguxSjZkkjX6aeivE9geAmNxTtsux9UrvdHG6f(nRifQRE3OQHqq9c)MHs9RWawD17MGNVkyaxJ)hSANKC1tteu7pbM7hQ9ppuQFfgWQRE3e88vbd4A8)GvssacKkVEtDO2)C3P2kAzDacKkVEtDO2)C3PKKwo(hxNJGwObWOpassaHVPVMgzypt6vrM)ciCfQ2kAb0NZv1KjalGqeOmiHBuHKKaeQbHwktawaHiq5FNY4OBUhBgYbB0Un3Sh(dwyJk0FePescKMW)56SRpuvkvpAUUsa95CvnzcG5aSaV)Gvwf6p3Sh(dwyJk0FePesUk4t5)bl0CDLa6Z5QAYeaZbybE)bRSk0FUzKMfRa)xQ)eMLDOfwsxHDwIdgGYIpelO8RiqwIOHfmfGfi3Sh(dwyJk0FePesa6Z5QAcnLNsk54iaknBuanaD9IuIc6lctMRY6v5dI3Kivp8hSm43N(nKHqgfwpL)lLqK1uqFryYCvwVkFq8wame9UMQ3GHlDg2Z)oL7WHWVHkxvtGiESAJu9WFWYyz8F3qiJcRNY)LsicagaHuXrKwN3D8tCZinlw9vAelBVp41GIWSyzNkw(DIL(HA)z5WS4QW1ZYdzHkq0WsFOk2ny5WS4QW1ZYdzHkq0Wsd4IfFiw8NfedaqelXbdqz5kw8IfRiOVimHgwqECqIvvbw0o(XS4f83PHLMerykGzboS0aUyXcCPbzbcKMGhXskCiw(DVyHtugaSehmaLfl7uXsd4IflWLgSq3ZY27dEnOiwkOfUzp8hSWgvO)isjKGFFWRbfHMRRuRREAIGA)jWC)qT)5Hs9RWag9tsAPU6DZ4aPcUW5(qvSBygk1VcdyubqtQJmepqNULJ)X15iOfAqQXcaTvOU6DZ4aPcUW5(qvSBywrTBNK0YX)46Ce0cnicOpNRQjJJJaO0SrbexD17gkOVimLXqTpMHs9RWice(M(AAKH9mPxfz(lGaopuQFfIdidAJxzLbqsIJ)X15iOfAqeqFoxvtghhbqPzJciU6Q3nuqFrykRxLpMHs9RWice(M(AAKH9mPxfz(lGaopuQFfIdidAJxzLbqBfuqFryYCv2RgkAzT6Q3nbpFvWSIssS(DnvVb)(OHdOHkxvtGTv0QL1biudcTuMGNVkywrjjbiqQ86ni0yoVuyDac1GqlLHsJGwOjRclqZkQDssacKkVEtDO2)C3P2kAzDacKkVEdqQ(9gtsI1QRE3e88vbZkkjXX)46Ce0cnXJyaq7KKwVRP6n43hnCanu5QAcuH6Q3nbpFvWSIu0sD17g87JgoGg87beaCSssC8pUohbTqt8iga0UDsI6Q3nbpFvWSIuyT6Q3nJdKk4cN7dvXUHzfPW631u9g87JgoGgQCvnbYnJ0S0eyIfasqyHz5kwSYv5dlwrqFryIfVazb7ajwqkLR7icGyP1Saqcclw6WHfKhhKyvvGB2d)blSrf6pIucjfzjNcHfAUUsTux9UHc6lctz9Q8XmuQFfoEczuy9u(VukjPvy3huewjaPyOWUpOO8FPeGrB7KKWUpOiSsXQTcpkh2PacCZE4pyHnQq)rKsiz319CkewO56k1sD17gkOVimL1RYhZqP(v44jKrH1t5)sjfTcqOgeAPmbpFvWmuQFfoE0cGKKaeQbHwktawaHiq5FNY4OBUhBgk1VchpAbq7KKwHDFqryLaKIHc7(GIY)LsagTTtsc7(GIWkfR2k8OCyNciWn7H)Gf2Oc9hrkHK(sRZPqyHMRRul1vVBOG(IWuwVkFmdL6xHJNqgfwpL)lLu0kaHAqOLYe88vbZqP(v44rlasscqOgeAPmbybeIaL)DkJJU5ESzOu)kC8OfaTtsAf29bfHvcqkgkS7dkk)xkby02ojjS7dkcRuSARWJYHDkGa3msZcsb0kybwSea5M9WFWcBuH(JiLqIfFMdozypt6vrCZinlnbMyz79PFdXYdzjAGbw2GAFyXkc6lctSahwSStflxXcS0nyXkxLpSyfb9fHjw8cKLfMybPaAfSenWaMLRZYvSyLRYhwSIG(IWe3Sh(dwyJk0FePesWVp9Bi0CDLOG(IWK5QSEv(KKqb9fHjdgQ9jxeY(KekOVimz8QrUiK9jjQRE3yXN5Gtg2ZKEvKzfPqD17gkOVimL1RYhZkkjPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKrH1t5)sjfQRE3e88vbZkQn3Sh(dwyJk0FePesSm(VZn7H)Gf2Oc9hrkHKzvzp8hSY6d)OP8usPUR1)(S4M5MrAw2EFWRbfXshoSKcbsPu9SSknHXSSWxHILycJtm4M9WFWcB6Uw)7Zsj87dEnOi0CDLSEwf1HdkYO6AVcug2ZUwN)9RqHne6TUOicKBgPzb5o(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9gw2wv)gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQFdXc4A8)Gf3Sh(dwyt316FFwisjKGxv)gcnHgbnLFFqrpwjLrZ1vce(MuiS63qMHs9RWXpuQFfgXbeGqQk3KCZE4pyHnDxR)9zHiLqskew9BiUzUzKMLMatSS9(GxdkILhYccefXYkILFNyXQpKNQEfinSOU6DwUol3ZIf4sdYcHSOBiwuPoCiw6xD49RqXYVtSueYEwco(zboS8qwaxPrSOsD4qSGCybeIaXn7H)Gf2GFLWVp41GIqZ1vAwf1HdkY8xkzbovgCipv9kqAu0Ic6lctMRYE1qH1TAPU6DZFPKf4uzWH8u1RaPXmuQFfoEp8hSmwg)3neYOW6P8FPeIaGrzfTOG(IWK5QSk83tsOG(IWK5QmgQ9jjHc6lctg9Q8jxeY(2jjQRE38xkzbovgCipv9kqAmdL6xHJ3d)bld(9PFdziKrH1t5)sjebaJYkArb9fHjZvz9Q8jjHc6lctgmu7tUiK9jjuqFryY4vJCri7B3ojXA1vVB(lLSaNkdoKNQEfinMvu7KKwQRE3e88vbZkkjbOpNRQjtawaHiqzqc3OcTveGqni0szcWciebk)7ughDZ9yZqoydfbiqQ86n1HA)ZDNAROL1biqQ86ni0yoVsscqOgeAPmuAe0cnzvybAgk1VchFt2wrl1vVBcE(QGzfLKyDac1GqlLj45RcMHCWgT5MrAwAcmXsCa9O)asSSzXNuwSStfl)onelhMLcYIh(diXc2IpPOHfhZI2FIfhZseeJpvnXcSybBXNuwSC)olaIf4WsNSqdl43diGzboSalwCwIfIybBXNuwWqw(D)z53jwkYclyl(KYIpZbKWSGuYc)S49Ngw(D)zbBXNuwiKfDdH5M9WFWcBWpIucjoOh9hqkJT4tkAcncAk)(GIESskJMRRK1GW34GE0FaPm2IpPzqp1rrM)ciCfkfw7H)GLXb9O)aszSfFsZGEQJImxL76d1(ROL1GW34GE0FaPm2IpP5DY1M)ciCfQKeq4BCqp6pGugBXN08o5AZqP(v44rB7Keq4BCqp6pGugBXN0mON6Oid(9acaowkaHVXb9O)aszSfFsZGEQJImdL6xHbCSuacFJd6r)bKYyl(KMb9uhfz(lGWvO4MrAwAcmHzb5WciebILRZcYJdsSQkWYHzzfXcCyPbCXIpelGeUrfUcflipoiXQQalwUFNfKdlGqeiw8cKLgWfl(qSOsAOfwqFaWsCWauUzp8hSWg8JiLqsawaHiq5FNY4OBUhJMRRK1GZ6anfmhaXkA1cOpNRQjtawaHiqzqc3OckSoaHAqOLYe88vbZqoydfwpRI6WbfzIMlfoGNRZ(e86c5OLg7tsI6Q3nbpFvWSIARWX)46Ce0cnawj0hakAPU6Ddf0xeMY6v5JzOu)kC8kdGKe1vVBOG(IWugd1(ygk1VchVYaODsIkeJv0pu7FEOu)kmGvgakSoaHAqOLYe88vbZqoyJ2CZinlihwG3FWILoCyX1AwaHpMLF3FwsDeiml41qS87udw8Hk09SmuFi8obYILDQyXQ1bsfCHzbGyOk2nyz3XSOjmMLF3lwqllykGzzOu)QRqXcCy53jwqOXCEXI6Q3z5WS4QW1ZYdzP7AnlWENf4WIxnyXkc6lctSCywCv46z5HSqil6gIB2d)blSb)isjKa0NZv1eAkpLuce(5HqV1nukvpgnaD9IuQL6Q3nJdKk4cN7dvXUHzOu)kC8OnjXA1vVBghivWfo3hQIDdZkQTcRvx9UzCGubx4CFOk2nY4R6lDEVb(P5CZksrl1vVBq4kWHaZuAe0cnPu9zQOb1fBYmuQFfgWOcGMuhzTv0sD17gkOVimLXqTpMHs9RWXJkaAsDKLKOU6Ddf0xeMY6v5JzOu)kC8OcGMuhzjjTSwD17gkOVimL1RYhZkkjXA1vVBOG(IWugd1(ywrTvy97AQEdgQX)fidvUQMaBZnJ0SGCybE)blw(D)zjStbeWSCDwAaxS4dXcC94dKyHc6lctS8qwGLUblGWNLFNgIf4WYHQGdXYVFywSC)olBqn(VaXn7H)Gf2GFePesa6Z5QAcnLNskbc)mC94dKYuqFrycnaD9IuQL1QRE3qb9fHPmgQ9XSIuyT6Q3nuqFrykRxLpMvu7KK31u9gmuJ)lqgQCvnbYn7H)Gf2GFePessHWQFdHMqJGMYVpOOhRKYO56knuFi8URQjfTux9UHc6lctzmu7JzOu)kC8dL6xHtsux9UHc6lctz9Q8XmuQFfo(Hs9RWjja95CvnzaHFgUE8bszkOVim1wXq9HW7UQMu8(GIEZFPu(HzWJIxzaPWJYHDkGGcG(CUQMmGWppe6TUHsP6XCZE4pyHn4hrkHe8Q63qOj0iOP87dk6XkPmAUUsd1hcV7QAsrl1vVBOG(IWugd1(ygk1Vch)qP(v4Ke1vVBOG(IWuwVkFmdL6xHJFOu)kCscqFoxvtgq4NHRhFGuMc6lctTvmuFi8URQjfVpOO38xkLFyg8O4vgqk8OCyNciOaOpNRQjdi8ZdHERBOuQEm3Sh(dwyd(rKsib)Kw7tUR9HqtOrqt53hu0Jvsz0CDLgQpeE3v1KIwQRE3qb9fHPmgQ9XmuQFfo(Hs9RWjjQRE3qb9fHPSEv(ygk1Vch)qP(v4KeG(CUQMmGWpdxp(aPmf0xeMARyO(q4DxvtkEFqrV5Vuk)Wm4rXRmatHhLd7uabfa95CvnzaHFEi0BDdLs1J5MrAwAcmXcabmUSalwcGSy5(D46zj4rrxHIB2d)blSb)isjK0HtGYWEU8FneAUUsEuoStbe4MrAwAcmXcs5RahcKLTOBUhZIL73zXRgSOHfkwOcUqTZI2X)vOyXkc6lctS4fil)0GLhYI(kIL7zzfXIL73zbGU0yFyXlqwqECqIvvbUzp8hSWg8JiLqcLgbTqtwfwGO56k1QL6Q3nuqFrykJHAFmdL6xHJxzaKKOU6Ddf0xeMY6v5JzOu)kC8kdG2kcqOgeAPmbpFvWmuQFfo(ybafTux9UjAUu4aEUo7tWRlKJwASpgGUEragqOpassSEwf1HdkYenxkCapxN9j41fYrln2hdHERlkIaB3ojrD17MO5sHd456SpbVUqoAPX(ya66ffVsacXcGKKaeQbHwktWZxfmd5Gnu44FCDocAHM4rmaGBgPzPjWelipoiXQQalwUFNfKdlGqeiKGu(kWHazzl6M7XS4filGWcDplqG0yzUNybGU0yFyboSyzNkwIPgcb1l8ZIf4sdYcHSOBiwuPoCiwqECqIvvbwiKfDdH5M9WFWcBWpIucja95CvnHMYtjLcG5aSaV)Gvg)ObORxKswdoRd0uWCaeRaOpNRQjtamhGf49hSu0Qvac1GqlLHsJAmKRZWbS8kqMHs9RWawzagIfrTuwzeFwf1HdkYGVQV059g4NMZBRGqV1ffrGgknQXqUodhWYRa1ojXX)46Ce0cnXReIbakAz97AQEtFnnYWEM0RImu5QAcmjrD17MGNVkyaxJ)hSIpaHAqOLY0xtJmSNj9QiZqP(vye1KTvacFdEv9BiZqP(v44vgqkaHVjfcR(nKzOu)kC8nPIwGW3GFsR9j31(qMHs9RWX3Kjjw)UMQ3GFsR9j31(qgQCvnb2wbqFoxvtMFFoToJjcbAYw87v0sD17geUcCiWmLgbTqtkvFMkAqDXMmROKeRdqGu51BqOXCE1wX7dk6n)Ls5hMbpkE1vVBcE(QGbCn(FWcXbGbXMKOcXyf9d1(Nhk1Vcdy1vVBcE(QGbCn(FWkjjabsLxVPou7FU7usI6Q3nQAieuVWVzfPqD17gvnecQx43muQFfgWQRE3e88vbd4A8)GfIAHyq8zvuhoOit0CPWb8CD2NGxxihT0yFme6TUOicSDBfwRU6DtWZxfmRifTSoabsLxVPou7FU7ussac1GqlLjalGqeO8VtzC0n3JnROKevigROFO2)8qP(vyahGqni0szcWciebk)7ughDZ9yZqP(vyebWss6hQ9ppuQFfgPIuvUjbaGvx9Uj45RcgW14)bR2CZinlnbMy53jwSAq1V3yyXY97S4SG84GeRQcS87(ZYHl09S0hykla0Lg7d3Sh(dwyd(rKsizCGubx4CFOk2nqZ1vsD17MGNVkygk1VchVYOnjrD17MGNVkyaxJ)hSaCSaGcG(CUQMmbWCawG3FWkJFUzp8hSWg8JiLqsG0e(pxND9HQsP6rZ1vcOpNRQjtamhGf49hSY4xrlRvx9Uj45RcgW14)bR4JfassSoabsLxVbiv)EJPDsI6Q3nJdKk4cN7dvXUHzfPqD17MXbsfCHZ9HQy3WmuQFfgWigefGf46Et0qHdtzxFOQuQEZFPugORxeIAzT6Q3nQAieuVWVzfPW631u9g87JgoGgQCvnb2MB2d)blSb)isjKCvWNY)dwO56kb0NZv1KjaMdWc8(dwz8ZnJ0Sy1WNZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoqcKLoCyb5Xbjwvfybdz539NLFNAWIpu9SyXXpbYcsjl8ZIk1HdXYVtPCZE4pyHn4hrkHeG(CUQMqt5PKsyhiL7Wjh88vb0a01lsjRdqOgeAPmbpFvWmKd2ijXAG(CUQMmbybeIaLbjCJkOiabsLxVPou7FU7usc4SoqtbZbqm3msZstGjmlaeqRGLRZYvS4flwrqFryIfVaz5NJWS8qw0xrSCplRiwSC)ola0Lg7dAyb5XbjwvfyXlqwIdOh9hqILnl(KYn7H)Gf2GFePes6RPrg2ZKEveAUUsuqFryYCv2Rgk8OCyNciOqD17MO5sHd456SpbVUqoAPX(ya66fbyaH(aqrlq4BCqp6pGugBXN0mON6OiZFbeUcvsI1biqQ86nffgOgoGTva0NZv1Kb7aPCho5GNVkOOL6Q3nJdKk4cN7dvXUHzOu)kmGrmnDl0I4ZQOoCqrg8v9LoV3a)0CEBfQRE3moqQGlCUpuf7gMvusI1QRE3moqQGlCUpuf7gMvuBUzKMLMatSaqUOFNLT3NUR1SenWaMLRZY27t31AwoCHUNLve3Sh(dwyd(rKsib)(0DTgnxxj1vVBGf974Cenbk6pyzwrkux9Ub)(0DT2muFi8URQjUzp8hSWg8JiLqsWRaPZQREhnLNskHFF0Wbenxxj1vVBWVpA4aAgk1Vcdy0QOL6Q3nuqFrykJHAFmdL6xHJhTjjQRE3qb9fHPSEv(ygk1VchpABRWX)46Ce0cnXJyaa3msZIvFLgHzjoyaklQuhoelihwaHiqSSWxHILFNyb5WciebILaSaV)GflpKLWofqGLRZcYHfqicelhMfp8lxRBWIRcxplpKfvILGJFUzp8hSWg8JiLqc(9bVgueAUUsbiqQ86n1HA)ZDNua0NZv1KjalGqeOmiHBubfbiudcTuMaSacrGY)oLXr3Cp2muQFfgWOvH1GZ6anfmhaXkOG(IWK5QSxnu44FCDocAHM4rFaWnJ0S0eyILT3NUR1Sy5(Dw2EsR9HfR(C9NfVazPGSS9(OHdiAyXYovSuqw2EF6UwZYHzzfHgwAaxS4dXYvSyLRYhwSIG(IWelD4WstIimfWSahwEilrdmWcaDPX(WILDQyXvHajwqmaGL4GbOSahwCWi)pGelyl(KYYUJzPjreMcywgk1V6kuSahwomlxXsxFO2FdlXf(el)U)SSkqAy53jwWEkXsawG3FWcZY9OdZcyeMLIw)4AwEilBVpDxRzbCnxHIfRwhivWfMfaIHQy3anSyzNkwAaxOdKf8FAnlubYYkIfl3VZcIbaiYXrS0Hdl)oXI2XplO0qvxJnCZE4pyHn4hrkHe87t31A0CDLExt1BWpP1(KbNR)gQCvnbQW631u9g87JgoGgQCvnbQqD17g87t31AZq9HW7UQMu0sD17gkOVimL1RYhZqP(v44BsfuqFryYCvwVkFuOU6Dt0CPWb8CD2NGxxihT0yFmaD9IamGqlassux9UjAUu4aEUo7tWRlKJwASpgGUErXReGqlau44FCDocAHM4rmaijbe(gh0J(diLXw8jnd6PokYmuQFfo(MmjXd)blJd6r)bKYyl(KMb9uhfzUk31hQ9VTIaeQbHwktWZxfmdL6xHJxzaWnJ0S0eyILT3h8AqrSaqUOFNLObgWS4filGR0iwIdgGYILDQyb5XbjwvfyboS87elwnO63BmSOU6DwomlUkC9S8qw6UwZcS3zboS0aUqhilbpIL4GbOCZE4pyHn4hrkHe87dEnOi0CDLux9Ubw0VJZbn5tg4HpyzwrjjQRE3GWvGdbMP0iOfAsP6ZurdQl2KzfLKOU6DtWZxfmRifTux9UzCGubx4CFOk2nmdL6xHbmQaOj1rgIhOt3YX)46Ce0cni1ybG2ikwi(7AQEtrwYPqyzOYv1eOcRNvrD4GIm4R6lDEVb(P5CfQRE3moqQGlCUpuf7gMvusI6Q3nbpFvWmuQFfgWOcGMuhziEGoDlh)JRZrql0GuJfaANKOU6DZ4aPcUW5(qvSBKXx1x68Ed8tZ5Mvussl1vVBghivWfo3hQIDdZqP(vya7H)GLb)(0VHmeYOW6P8FPKcCeP15Dh)eGbGb9tsux9UzCGubx4CFOk2nmdL6xHbSh(dwglJ)7gczuy9u(VukjbOpNRQjZHEG5aSaV)GLIaeQbHwkZv4WSExvtz0B51VsZGeWlqMHCWgki0BDrreO5kCywVRQPm6T86xPzqc4fO2kux9UzCGubx4CFOk2nmROKeRvx9UzCGubx4CFOk2nmRifwhGqni0szghivWfo3hQIDdZqoyJKeRdqGu51Bas1V3yANK44FCDocAHM4rmaqbf0xeMmxL9Qb3msZsmMgS8qwsDeiw(DIfvc)Sa7SS9(OHdilQnyb)EaHRqXY9SSIyb9wxabDdwUIfVAWIve0xeMyrD9SaqxASpSC46zXvHRNLhYIkXs0adbcKB2d)blSb)isjKGFFWRbfHMRR07AQEd(9rdhqdvUQMavy9SkQdhuK5VuYcCQm4qEQ6vG0OOL6Q3n43hnCanROKeh)JRZrql0epIbaTvOU6Dd(9rdhqd(9acaowkAPU6Ddf0xeMYyO2hZkkjrD17gkOVimL1RYhZkQTc1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbeIfakAfGqni0szcE(QGzOu)kC8kdGKeRb6Z5QAYeGfqicugKWnQGIaeivE9M6qT)5UtT5MrAwSc8FP(tyw2HwyjDf2zjoyakl(qSGYVIazjIgwWuawGCZE4pyHn4hrkHeG(CUQMqt5PKsoocGsZgfqdqxViLOG(IWK5QSEv(G4njs1d)bld(9PFdziKrH1t5)sjeznf0xeMmxL1RYheVfadrVRP6ny4sNH98Vt5oCi8BOYv1eiIhR2ivp8hSmwg)3neYOW6P8FPeIaGb9rlsfhrADE3XpHiayqlI)UMQ3u(VgcNvDTxbYqLRQjqUzKMfR(knILT3h8AqrSCfloliweHPalBqTpSyfb9fHj0WciSq3ZIMEwUNLObgybGU0yFyP1V7plhMLDVa1eilQnyHUFNgw(DILT3NUR1SOVIyboS87elXbdqJhXaaw0xrS0HdlBVp41GIAJgwaHf6EwGaPXYCpXIxSaqUOFNLObgyXlqw00ZYVtS4QqGel6Riw29cutSS9(OHdi3Sh(dwyd(rKsib)(GxdkcnxxjRNvrD4GIm)LswGtLbhYtvVcKgfTux9UjAUu4aEUo7tWRlKJwASpgGUEragqiwaKKOU6Dt0CPWb8CD2NGxxihT0yFmaD9IamGqlau8UMQ3GFsR9jdox)nu5QAcSTIwuqFryYCvgd1(OWX)46Ce0cnicOpNRQjJJJaO0SrbexD17gkOVimLXqTpMHs9RWice(M(AAKH9mPxfz(lGaopuQFfIdidAJVjbqscf0xeMmxL1RYhfo(hxNJGwObra95CvnzCCeaLMnkG4QRE3qb9fHPSEv(ygk1VcJiq4B6RPrg2ZKEvK5Vac48qP(vioGmOnEedaARWA1vVBGf974Cenbk6pyzwrkS(DnvVb)(OHdOHkxvtGkAfGqni0szcE(QGzOu)kC8i2KemCPvVc087ZP1zmriqJHkxvtGkux9U53NtRZyIqGgd(9acaowXQPBnRI6WbfzWx1x68Ed8tZ5ioABROFO2)8qP(v44vgaaqr)qT)5Hs9RWagqaaaTv0kaHAqOLYGWvGdbMXr3Cp2muQFfoEeBsI1biqQ86ni0yoVAZnJ0S0eyIfasqyHz5kwSYv5dlwrqFryIfVazb7ajwqkLR7icGyP1Saqcclw6WHfKhhKyvvGfVazbP8vGdbYIvKgbTqtkvp3Sh(dwyd(rKsiPil5uiSqZ1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LsjjTc7(GIWkbifdf29bfL)lLamABNKe29bfHvkwTv4r5WofqqbqFoxvtgSdKYD4KdE(Qa3Sh(dwyd(rKsiz319CkewO56k1sD17gkOVimL1RYhZqP(v44jKrH1t5)sjfwhGaPYR3GqJ58kjPL6Q3niCf4qGzkncAHMuQ(mv0G6InzwrkcqGu51BqOXCE1ojPvy3huewjaPyOWUpOO8FPeGrB7KKWUpOiSsXkjrD17MGNVkywrTv4r5WofqqbqFoxvtgSdKYD4KdE(QGIwQRE3moqQGlCUpuf7gMHs9RWaUfABAaH4ZQOoCqrg8v9LoV3a)0CEBfQRE3moqQGlCUpuf7gMvusI1QRE3moqQGlCUpuf7gMvuBUzp8hSWg8JiLqsFP15uiSqZ1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LskSoabsLxVbHgZ5vssl1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIueGaPYR3GqJ58QDssRWUpOiSsasXqHDFqr5)sjaJ22jjHDFqryLIvsI6Q3nbpFvWSIARWJYHDkGGcG(CUQMmyhiL7Wjh88vbfTux9UzCGubx4CFOk2nmdL6xHbmAvOU6DZ4aPcUW5(qvSBywrkSEwf1HdkYGVQV059g4NMZtsSwD17MXbsfCHZ9HQy3WSIAZnJ0S0eyIfKcOvWcSyjaYn7H)Gf2GFePesS4ZCWjd7zsVkIBgPzPjWelBVp9BiwEilrdmWYgu7dlwrqFrycnSG84GeRQcSS7yw0egZYFPel)UxS4SGum(VZcHmkSEIfn1FwGdlWs3GfRCv(WIve0xeMy5WSSI4M9WFWcBWpIucj43N(neAUUsuqFryYCvwVkFssOG(IWKbd1(KlczFscf0xeMmE1ixeY(KKwQRE3yXN5Gtg2ZKEvKzfLKGJiToV74NamamOpAvyDacKkVEdqQ(9gtscoI068UJFcWaWG(kcqGu51Bas1V3yARqD17gkOVimL1RYhZkkjPL6Q3nbpFvWmuQFfgWE4pyzSm(VBiKrH1t5)sjfQRE3e88vbZkQn3msZstGjwqkg)3zb(70y5Welw2VWolhMLRyzdQ9HfRiOVimHgwqECqIvvbwGdlpKLObgyXkxLpSyfb9fHjUzp8hSWg8JiLqILX)DUzKMfacxR)9zXn7H)Gf2GFePesMvL9WFWkRp8JMYtjL6Uw)7ZYEdhrb74QmaaK9B)22a]] )

end