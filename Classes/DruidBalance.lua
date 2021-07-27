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


    spec:RegisterPack( "Balance", 20210727, [[difVSfqikv9iisDjisAtKWNGuzusvoLuvRcqvVcqzwquDlrvLDrXVGiggaCmsuldG8mHsnniv11GuABaQ4BaighasNdavRdqLMha19ir2NOk)tOqKoOOIwOqrpesXefkuxesv2OOQkFeIePrkuiQtsPIwPOsVeIe1mPuHBkQQk7uOKFkQQQgkakhvOqelvOq6PkLPsPsxvuvSvHcHVcrcJvuvAVuYFfzWehMQftspwWKb6YiBwkFgsgTs1Pvz1qKiEnGmBsDBPYUL8BqdxihxOGLR45qnDvDDLSDi8DkLXdr58cvRxuH5lk7h1wkBzxRnq)jRybiaaiLbaabqaedaa4aa4eBaQ12hpIS2I8aqokYAR8oYAlMU2RazTf5X1qh0YUwBy4AcK12()ryGlsqIQR9kq5h(6cgu3VVunhejX01EfO8B76qds6an7FNogPTttkP6AVcK5r2BTPUo9BNLLQ1gO)KvSaeaaKYaaGaiaIbaaCaaCaeaXAZx)oCS22Uo0yTTFGGuzPATbs4G1wmDTxbILy8Soqo3Cx64SaiacYzbqaaqkZ5Y5IMDVqryGlNB(Xsobbjqw2GAFyjMK3z4CZpwqZUxOiqwEFqrF6ASeCmHz5HSeIh0u69bf9ydNB(Xsmk1brqGSSQIceg7tCwq4Z5QAcZsVZqgKZs0qis43h8AqrSKF5Xs0qim43h8Aqr9nCU5hl5eb8azjAOGJ)RqXcsX4)olxJL7rhMLFNyX2aluSGEb9fHjdNB(Xs(NdeXcAGfciqel)oXYw0n3JzXzrF)Rjw6GdXstti7u1el9UglXHlw2DWcDpl73ZY9SGVUL(9IGlSool2UFNLyM)Nt7YcWybnKMW)5AwYP(qvDu9iNL7rhilyGUO(go38JL8phiILoi(zbDTd1(NgQZVcJowWbQ85Gyw8OiDCwEilQqmML2HA)XSalDCdNB(XIDhYFwSlSJyb2yjMAFNLyQ9DwIP23zXXS4SGJOW5Aw(5kGO3W5MFSK)hrfnS07mKb5SGum(VJCwqkg)3rolBVpTBO(S05GelDWHyzi8PpQEwEilKp6JgwcWov)Zp87ZBS20h(Xw21Adgrfnw21kwkBzxRnQCvnbAftRnp8hSS2Sn(VBTbs4WCr)blRna2qbh)Saiwqkg)3zXlqwCw2EFWRbfXcSyzZUSy7(DwI1HA)zj)5elEbYsmH50USahw2EFA3qSa)DASDyYAlm3tZ5wB9yHc6lctg9Q8jveYEwYYyHc6lctMRsyO2hwYYyHc6lctMRsQWFNLSmwOG(IWKXR4PIq2ZsFwuWs0qimkBSn(VZIcwSNLOHqyaKX24)U1BflazzxRnQCvnbAftRnp8hSS2WVpTBiRTWCpnNBTzplZQOgCqrgvx7vGsWwY160VFfkSHkxvtGSKLXI9SeGiOYR3uhQ9p1CILSmwSNfCeP1P3hu0Jn43NMR1SOelkZswgl2ZY7AQEt5)AiCs11EfidvUQMazjlJLESqb9fHjdgQ9jveYEwYYyHc6lctMRs6v5dlzzSqb9fHjZvjv4VZswgluqFryY4v8uri7zPV1M(kkfaT2qR1BfRyBzxRnQCvnbAftRnp8hSS2WVp41GIS2cZ90CU12SkQbhuKr11EfOeSLCTo97xHcBOYv1eilkyjarqLxVPou7FQ5elkybhrAD69bf9yd(9P5AnlkXIYwB6ROua0AdTwV1BTbsnFPFl7AflLTSR1Mh(dwwByO2NKk5DwBu5QAc0kMwVvSaKLDT2OYv1eOvmT2cZ90CU12FDelaMLESaiwaEw8WFWYyB8F3eC8N(RJybyS4H)GLb)(0UHmbh)P)6iw6BT5H)GL1wW16Kh(dwj9HFRn9H)u5DK1gmIkASERyfBl7ATrLRQjqRyATbJS2W0BT5H)GL1gcFoxvtwBiC9IS2WrKwNEFqrp2GFFAUwZsESOmlkyPhl2ZY7AQEd(9rdhqdvUQMazjlJL31u9g8tATpjW5AVHkxvtGS0NLSmwWrKwNEFqrp2GFFAUwZsESaiRnqchMl6pyzTTrpMLCcrpwGflXgySy7(D46zbCU2ZIxGSy7(Dw2EF0WbKfVazbqaJf4VtJTdtwBi8jvEhzTD4KdjR3kwOVLDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB4isRtVpOOhBWVpTBiwYJfLT2ajCyUO)GL12g9ywcAYrqSyBNkw2EFA3qSe8IL97zbqaJL3hu0JzX2(f2z5WSmKMq41ZsdoS87elOxqFryILhYIkXs0qnAgcKfVazX2(f2zPDAnnS8qwco(T2q4tQ8oYA7WPGMCeK1Bfl0AzxRnQCvnbAftRnyK1gMERnp8hSS2q4Z5QAYAdHRxK1w0qimDqy1UHyjlJLOHqyWRQDdXswglrdHWGFFWRbfXswglrdHWGFFAUwZswglrdHW0wt8eSLi9QiwYYyrD1AMGNUkygQZVcZIsSOUAntWtxfmGRX)dwwBGeomx0FWYAlgHpNRQjw(D)zjStbGWSCnwIdxS4dXYvS4SGkaYYdzXrapqw(DIf89l)pyXITDAiwCw(5kGONf6dSCywwycKLRyrLEBevSeC8JT2q4tQ8oYA7QeQaO1BflGJLDT2OYv1eOvmT28WFWYAtLgmnaDfkRnqchMl6pyzTLpyILysdMgGUcfl2UFNf0KtKyNvGf4WI3EAybnWcbeiILRybn5ej2zfS2cZ90CU1wpw6XI9SeGiOYR3uhQ9p1CILSmwSNLaeQbH2ktawiGarPFNs4OBUhBwrS0NffSOUAntWtxfmd15xHzjpwugTSOGf1vRzghbvWfo1gQYrCZqD(vywamlOplkyXEwcqeu51Bqq1VhFyjlJLaebvE9geu97XhwuWI6Q1mbpDvWSIyrblQRwZmocQGlCQnuLJ4MvelkyPhlQRwZmocQGlCQnuLJ4MH68RWSaywuwzwYpwqllaplZQOgCqrg8vTLoThh)0CUHkxvtGSKLXI6Q1mbpDvWmuNFfMfaZIYkZswglkZcsybhrADA3XpXcGzrzdArll9zPplkybHpNRQjZvjubqR3kwael7ATrLRQjqRyATfM7P5CRn1vRzcE6QGzOo)kml5XIYOLffS0Jf7zzwf1GdkYGVQT0P944NMZnu5QAcKLSmwuxTMzCeubx4uBOkhXnd15xHzbWSOmaHL8JfaXcWZI6Q1mQAieuVWVzfXIcwuxTMzCeubx4uBOkhXnRiw6ZswglQqmMffS0ou7FAOo)kmlaMfaHwRnqchMl6pyzTbWGpl2UFNfNf0KtKyNvGLF3FwoCHUNfNfa2sJ9HLObgyboSyBNkw(DIL2HA)z5WS4QW1ZYdzHkqRnp8hSS2IG)blR3kwaul7ATrLRQjqRyATbJS2W0BT5H)GL1gcFoxvtwBiC9IS2c0PzPhl9yPDO2)0qD(vywYpwugTSKFSeGqni0wzcE6QGzOo)kml9zbjSOmafaS0NfLyjqNMLES0JL2HA)td15xHzj)yrz0Ys(Xsac1GqBLjaleqGO0VtjC0n3JnGRX)dwSKFSeGqni0wzcWcbeik97uchDZ9yZqD(vyw6ZcsyrzakayPplkyXEwg)atecQEJdcIneYo8JzjlJLaeQbH2ktWtxfmd15xHzjpwU6PjcQ9NatTd1(NgQZVcZswglbiudcTvMaSqabIs)oLWr3Cp2muNFfML8y5QNMiO2Fcm1ou7FAOo)kml5hlkdawYYyXEwcqeu51BQd1(NAozTbs4WCr)blRn046Ws7pHzX2o970WYcFfkwqdSqabIyPG2yX2P1S4An0glXHlwEil4)0Awco(z53jwWEhXI3bx1ZcSXcAGfciqeWqtorIDwbwco(XwBi8jvEhzTfGfciqucKWXRG1BflaULDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB9yPDO2)0qD(vywYJfLrllzzSm(bMieu9gheeBUIL8ybTaGL(SOGLES0JLESqXW6IIiqd1ffFixNGdy5vGyrbl9yjaHAqOTYqDrXhY1j4awEfiZqD(vywamlkdCaalzzSeGiOYR3GGQFp(WIcwcqOgeARmuxu8HCDcoGLxbYmuNFfMfaZIYahaclaJLESOSYSa8SmRIAWbfzWx1w60EC8tZ5gQCvnbYsFw6ZIcwSNLaeQbH2kd1ffFixNGdy5vGmd5GXzPplzzSqXW6IIiqdgU0A6)RqLMLACwuWspwSNLaebvE9M6qT)PMtSKLXsac1GqBLbdxAn9)vOsZsnEk2OpAbOaqzZqD(vywamlkRm6ZsFwYYyPhlbiudcTvgvAW0a0vOmd5GXzjlJf7zz8az(bQ1S0NffS0JLESqXW6IIiqZv4WSExvtPyy51V6sGeIlqSOGLESeGqni0wzUchM17QAkfdlV(vxcKqCbYmKdgNLSmw8WFWYCfomR3v1ukgwE9RUeiH4cKb8WUQMazPpl9zjlJLESqXW6IIiqdE3bH2iWeCutWw6HthvplkyjaHAqOTY8WPJQNatxHpu7Fk2OfTXgqkBgQZVcZsFwYYyPhl9ybHpNRQjdSslmL(5kGONfLyrzwYYybHpNRQjdSslmL(5kGONfLyj2S0NffS0JLFUci6nVYMHCW4PaeQbH2kwYYy5NRaIEZRSjaHAqOTYmuNFfML8y5QNMiO2Fcm1ou7FAOo)kml5hlkdaw6Zswgli85CvnzGvAHP0pxbe9SOelaIffS0JLFUci6npGmd5GXtbiudcTvSKLXYpxbe9MhqMaeQbH2kZqD(vywYJLREAIGA)jWu7qT)PH68RWSKFSOmayPplzzSGWNZv1KbwPfMs)Cfq0ZIsSaaw6ZsFw6ZswglbicQ86nafFoVyPplzzSOcXywuWs7qT)PH68RWSaywuxTMj4PRcgW14)blRnqchMl6pyzTLpycKLhYciP94S87ellSJIyb2ybn5ej2zfyX2ovSSWxHIfq4svtSalwwyIfVazjAieu9SSWokIfB7uXIxS4GGSqiO6z5WS4QW1ZYdzb8iRne(KkVJS2cGPaSaV)GL1BflLbGLDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB2ZcgU0QxbA(9506eMiGOXqLRQjqwYYyPDO2)0qD(vywYJfabaaWswglQqmMffS0ou7FAOo)kmlaMfaHwwagl9yb9bal5hlQRwZ87ZP1jmrarJb)EaiwaEwael9zjlJf1vRz(9506eMiGOXGFpael5XsSbOSKFS0JLzvudoOid(Q2sN2JJFAo3qLRQjqwaEwqll9T2ajCyUO)GL1wmcFoxvtSSWeilpKfqs7XzXR4S8ZvarpMfVazjaIzX2ovSyZV)kuS0GdlEXc6TI2HZ5SenWG1gcFsL3rwB)(CADcteq0KS53B9wXszLTSR1gvUQMaTIP1giHdZf9hSS2YhmXc61ffFixZs()awEfiwaeaWuaZIk1GdXIZcAYjsSZkWYctgRTY7iRnQlk(qUobhWYRazTfM7P5CRTaeQbH2ktWtxfmd15xHzbWSaiaWIcwcqOgeARmbyHaceL(DkHJU5ESzOo)kmlaMfabawuWspwq4Z5QAY87ZP1jmrartYMFplzzSOUAnZVpNwNWebeng87bGyjpwInaybyS0JLzvudoOid(Q2sN2JJFAo3qLRQjqwaEwaoS0NL(SOGfe(CUQMmxLqfazjlJfvigZIcwAhQ9pnuNFfMfaZsSbiwBE4pyzTrDrXhY1j4awEfiR3kwkdil7ATrLRQjqRyATbs4WCr)blRT8btSSbxAn9xHILy0LACwaoykGzrLAWHyXzbn5ej2zfyzHjJ1w5DK1ggU0A6)RqLMLACRTWCpnNBT1JLaeQbH2ktWtxfmd15xHzbWSaCyrbl2ZsaIGkVEdcQ(94dlkyXEwcqeu51BQd1(NAoXswglbicQ86n1HA)tnNyrblbiudcTvMaSqabIs)oLWr3Cp2muNFfMfaZcWHffS0Jfe(CUQMmbyHaceLajC8kWswglbiudcTvMGNUkygQZVcZcGzb4WsFwYYyjarqLxVbbv)E8HffS0Jf7zzwf1GdkYGVQT0P944NMZnu5QAcKffSeGqni0wzcE6QGzOo)kmlaMfGdlzzSOUAnZ4iOcUWP2qvoIBgQZVcZcGzrz0NfGXspwqllaplumSUOic0Cf(Nv4HdobEiUIsQKwZsFwuWI6Q1mJJGk4cNAdv5iUzfXsFwYYyrfIXSOGL2HA)td15xHzbWSai0YswglumSUOic0qDrXhY1j4awEfiwuWsac1GqBLH6IIpKRtWbS8kqMH68RWSKhlXgaS0NffSGWNZv1K5QeQaO1Mh(dwwBy4sRP)VcvAwQXTERyPCSTSR1gvUQMaTIP1gmYAdtV1Mh(dwwBi85CvnzTHW1lYAtD1AMGNUkygQZVcZsESOmAzrbl9yXEwMvrn4GIm4RAlDApo(P5CdvUQMazjlJf1vRzghbvWfo1gQYrCZqD(vywaSsSOmGybyS0JLyZcWZI6Q1mQAieuVWVzfXsFwagl9yPhlauwYpwqllaplQRwZOQHqq9c)Mvel9zb4zHIH1ffrGMRW)ScpCWjWdXvusL0Aw6ZIcwuxTMzCeubx4uBOkhXnRiw6ZswglQqmMffS0ou7FAOo)kmlaMfaHwwYYyHIH1ffrGgQlk(qUobhWYRaXIcwcqOgeARmuxu8HCDcoGLxbYmuNFf2AdKWH5I(dwwB5uBZJJzzHjwSZyKeJzX297SGMCIe7ScwBi8jvEhzTDXaykalW7pyz9wXsz03YUwBu5QAc0kMwBE4pyzTDfomR3v1ukgwE9RUeiH4cK1wyUNMZT2q4Z5QAYCXaykalW7pyXIcwq4Z5QAYCvcva0AR8oYA7kCywVRQPumS86xDjqcXfiR3kwkJwl7ATrLRQjqRyATbs4WCr)blRT8btSmhQ9NfvQbhILai2AR8oYAdV7GqBeycoQjyl9WPJQ3Alm3tZ5wB9yjaHAqOTYe80vbZqoyCwuWI9SeGiOYR3uhQ9p1CIffSGWNZv1K53NtRtyIaIMKn)EwYYyjarqLxVPou7FQ5elkyjaHAqOTYeGfciqu63Peo6M7XMHCW4SOGLESGWNZv1KjaleqGOeiHJxbwYYyjaHAqOTYe80vbZqoyCw6ZsFwuWci8n4v1UHm)fa6kuSOGLESacFd(jT2Nut7dz(la0vOyjlJf7z5DnvVb)Kw7tQP9Hmu5QAcKLSmwWrKwNEFqrp2GFFA3qSKhlXML(SOGLESacFthewTBiZFbGUcfl9zrbl9ybHpNRQjZHtoKyjlJLzvudoOiJQR9kqjyl5AD63Vcf2qLRQjqwYYyXX)46ue0gnSKNsSaWbalzzSOUAnJQgcb1l8BwrS0NffS0JLaeQbH2kJknyAa6kuMHCW4SKLXI9SmEGm)a1Aw6ZswglQqmMffS0ou7FAOo)kmlaMf0hawBE4pyzTH3DqOncmbh1eSLE40r1B9wXszGJLDT2OYv1eOvmT2ajCyUO)GL1MD3pmlhMfNLX)DAyH0UkC8NyXMhNLhYsNdeXIR1SalwwyIf87pl)Cfq0Jz5HSOsSOVIazzfXIT73zbn5ej2zfyXlqwqdSqabIyXlqwwyILFNybqfilyn8zbwSeaz5ASOc)Dw(5kGOhZIpelWILfMyb)(ZYpxbe9yRTWCpnNBT1Jfe(CUQMmWkTWu6NRaIEwSxjwuMffSypl)Cfq0BEazgYbJNcqOgeARyjlJLESGWNZv1KbwPfMs)Cfq0ZIsSOmlzzSGWNZv1KbwPfMs)Cfq0ZIsSeBw6ZIcw6XI6Q1mbpDvWSIyrbl9yXEwcqeu51Bqq1VhFyjlJf1vRzghbvWfo1gQYrCZqD(vywagl9ybTSa8SmRIAWbfzWx1w60EC8tZ5gQCvnbYsFwaSsS8ZvarV5v2OUATe4A8)GflkyrD1AMXrqfCHtTHQCe3SIyjlJf1vRzghbvWfo1gQYr8e(Q2sN2JJFAo3SIyPplzzSeGqni0wzcE6QGzOo)kmlaJfaXsES8ZvarV5v2eGqni0wzaxJ)hSyrbl2ZI6Q1mbpDvWSIyrbl9yXEwcqeu51BQd1(NAoXswgl2ZccFoxvtMaSqabIsGeoEfyPplkyXEwcqeu51Bak(CEXswglbicQ86n1HA)tnNyrbli85CvnzcWcbeikbs44vGffSeGqni0wzcWcbeik97uchDZ9yZkIffSyplbiudcTvMGNUkywrSOGLES0Jf1vRzOG(IWusVkFmd15xHzjpwugaSKLXI6Q1muqFrykHHAFmd15xHzjpwugaS0NffSyplZQOgCqrgvx7vGsWwY160VFfkSHkxvtGSKLXspwuxTMr11EfOeSLCTo97xHcNk)xdzWVhaIfLybTSKLXI6Q1mQU2RaLGTKR1PF)ku4KpbVid(9aqSOelauw6ZsFwYYyrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiw6ZswglTd1(NgQZVcZcGzbqaGLSmwq4Z5QAYaR0ctPFUci6zrjwaal9zrbli85CvnzUkHkaATH1WhBT9ZvarVYwBE4pyzT9ZvarVYwVvSugGyzxRnQCvnbAftRnp8hSS2(5kGOhqwBH5EAo3ARhli85CvnzGvAHP0pxbe9SyVsSaiwuWI9S8ZvarV5v2mKdgpfGqni0wXswgli85CvnzGvAHP0pxbe9SOelaIffS0Jf1vRzcE6QGzfXIcw6XI9SeGiOYR3GGQFp(WswglQRwZmocQGlCQnuLJ4MH68RWSamw6XcAzb4zzwf1GdkYGVQT0P944NMZnu5QAcKL(SayLy5NRaIEZdiJ6Q1sGRX)dwSOGf1vRzghbvWfo1gQYrCZkILSmwuxTMzCeubx4uBOkhXt4RAlDApo(P5CZkIL(SKLXsac1GqBLj4PRcMH68RWSamwael5XYpxbe9MhqMaeQbH2kd4A8)GflkyXEwuxTMj4PRcMvelkyPhl2ZsaIGkVEtDO2)uZjwYYyXEwq4Z5QAYeGfciqucKWXRal9zrbl2ZsaIGkVEdqXNZlwuWspwSNf1vRzcE6QGzfXswgl2ZsaIGkVEdcQ(94dl9zjlJLaebvE9M6qT)PMtSOGfe(CUQMmbyHaceLajC8kWIcwcqOgeARmbyHaceL(DkHJU5ESzfXIcwSNLaeQbH2ktWtxfmRiwuWspw6XI6Q1muqFrykPxLpMH68RWSKhlkdawYYyrD1AgkOVimLWqTpMH68RWSKhlkdaw6ZIcwSNLzvudoOiJQR9kqjyl5AD63Vcf2qLRQjqwYYyPhlQRwZO6AVcuc2sUwN(9RqHtL)RHm43daXIsSGwwYYyrD1Agvx7vGsWwY160VFfkCYNGxKb)EaiwuIfakl9zPpl9zjlJf1vRza6kWHatuxe0gnDu9jQOb1LdYSIyjlJfvigZIcwAhQ9pnuNFfMfaZcGaalzzSGWNZv1KbwPfMs)Cfq0ZIsSaaw6ZIcwq4Z5QAYCvcva0AdRHp2A7NRaIEaz9wXszaQLDT2OYv1eOvmT2ajCyUO)GL1w(GjmlUwZc83PHfyXYctSCp1HzbwSeaT28WFWYABHP09uh26TILYaCl7ATrLRQjqRyATbs4WCr)blRTymfoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdBT5H)GL12SQKh(dwj9HFRn8px4TILYwBH5EAo3AdHpNRQjZHtoKS20h(tL3rwBoKSERybiayzxRnQCvnbAftRTWCpnNBTnRIAWbfzuDTxbkbBjxRt)(vOWgkgwxuebATH)5cVvSu2AZd)blRTzvjp8hSs6d)wB6d)PY7iRnvO)wVvSaKYw21AJkxvtGwX0AZd)blRTzvjp8hSs6d)wB6d)PY7iRn8B9wV1Mk0Fl7AflLTSR1gvUQMaTIP1Mh(dwwBJJGk4cNAdv5iU1giHdZf9hSS2YFdv5iol2UFNf0KtKyNvWAlm3tZ5wBQRwZe80vbZqD(vywYJfLrR1BflazzxRnQCvnbAftRnp8hSS2Cqp6peucBZNoRTq8GMsVpOOhBflLT2cZ90CU1M6Q1mQU2RaLGTKR1PF)ku4u5)Aid(9aqSaywaOSOGf1vRzuDTxbkbBjxRt)(vOWjFcErg87bGybWSaqzrbl9yXEwaHVXb9O)qqjSnF6sGENJIm)fa6kuSOGf7zXd)blJd6r)HGsyB(0La9ohfzUk10hQ9NffS0Jf7zbe(gh0J(dbLW28PlTtU28xaORqXswglGW34GE0FiOe2MpDPDY1MH68RWSKhlXML(SKLXci8noOh9hckHT5txc07CuKb)EaiwamlXMffSacFJd6r)HGsyB(0La9ohfzgQZVcZcGzbTSOGfq4BCqp6peucBZNUeO35OiZFbGUcfl9T2ajCyUO)GL1w(GjwYjOh9hcILnB(0XITDQyXFw0egZYV7flOplXeMt7Yc(9aqyw8cKLhYYqTHW7S4SayLael43daXIJzr7pXIJzjcIXNQMyboS8xhXY9SGHSCpl(mhccZcsjl8ZI3EAyXzj2aJf87bGyHqw0ne26TIvSTSR1gvUQMaTIP1Mh(dwwBbyHaceL(DkHJU5ES1giHdZf9hSS2YhmXcAGfciqel2UFNf0KtKyNvGfB7uXseeJpvnXIxGSa)DASDyIfB3VZIZsmH50USOUAnwSTtflGeoEfUcL1wyUNMZT2SNfWzDGMcMcGywuWspw6XccFoxvtMaSqabIsGeoEfyrbl2Zsac1GqBLj4PRcMHCW4SKLXI6Q1mbpDvWSIyPplkyPhlQRwZO6AVcuc2sUwN(9RqHtL)RHm43daXIsSaqzjlJf1vRzuDTxbkbBjxRt)(vOWjFcErg87bGyrjwaOS0NLSmwuHymlkyPDO2)0qD(vywamlkdaw6B9wXc9TSR1gvUQMaTIP1Mh(dwwBT1epbBjsVkYAdKWH5I(dwwB5pi6XIJz53jwA3GFwqfaz5kw(DIfNLycZPDzX2vGqBSahwSD)ol)oXcs54Z5flQRwJf4WIT73zXzbGcmmfyjNGE0Fiiw2S5thlEbYIn)EwAWHf0KtKyNvGLRXY9SydwplQelRiwCu(vSOsn4qS87elbqwomlTRo8obATfM7P5CRTES0JLESOUAnJQR9kqjyl5AD63Vcfov(VgYGFpael5XcWHLSmwuxTMr11EfOeSLCTo97xHcN8j4fzWVhaIL8yb4WsFwuWspwSNLaebvE9geu97XhwYYyXEwuxTMzCeubx4uBOkhXnRiw6ZsFwuWspwaN1bAkykaIzjlJLaeQbH2ktWtxfmd15xHzjpwqlayjlJLESeGiOYR3uhQ9p1CIffSeGqni0wzcWcbeik97uchDZ9yZqD(vywYJf0caw6ZsFw6Zswgl9ybe(gh0J(dbLW28Plb6DokYmuNFfML8ybGYIcwcqOgeARmbpDvWmuNFfML8yrzaWIcwcqeu51BkkmqnCazPplzzSC1tteu7pbMAhQ9pnuNFfMfaZcaLffSyplbiudcTvMGNUkygYbJZswglbicQ86nafFoVyrblQRwZa0vGdbMOUiOnA6O6nRiwYYyjarqLxVbbv)E8HffSOUAnZ4iOcUWP2qvoIBgQZVcZcGzbGZIcwuxTMzCeubx4uBOkhXnRiR3kwO1YUwBu5QAc0kMwBE4pyzTf8kq6K6Q1S2cZ90CU1wpwuxTMr11EfOeSLCTo97xHcNk)xdzgQZVcZsESaqmOLLSmwuxTMr11EfOeSLCTo97xHcN8j4fzgQZVcZsESaqmOLL(SOGLESeGqni0wzcE6QGzOo)kml5XcaHLSmw6Xsac1GqBLH6IG2OjPclqZqD(vywYJfaclkyXEwuxTMbORahcmrDrqB00r1NOIguxoiZkIffSeGiOYR3au858IL(S0NffS44FCDkcAJgwYtjwInaS2uxTwQ8oYAd)(OHdO1giHdZf9hSS2qJxbsZY27JgoGSy7(DwCwkYglXeMt7YI6Q1yXlqwqtorIDwbwoCHUNfxfUEwEilQellmbA9wXc4yzxRnQCvnbAftRnp8hSS2WVp41GIS2ajCyUO)GL1wmE1fXY27dEnOiml2UFNfNLycZPDzrD1ASOUEwk4ZITDQyjcc1xHILgCybn5ej2zfyboSGu(kWHazzl6M7XwBH5EAo3ARhlQRwZO6AVcuc2sUwN(9RqHtL)RHm43daXsESaiwYYyrD1Agvx7vGsWwY160VFfkCYNGxKb)EaiwYJfaXsFwuWspwcqeu51BQd1(NAoXswglbiudcTvMGNUkygQZVcZsESaqyjlJf7zbHpNRQjtamfGf49hSyrbl2ZsaIGkVEdqXNZlwYYyPhlbiudcTvgQlcAJMKkSand15xHzjpwaiSOGf7zrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiwuWsaIGkVEdqXNZlw6ZsFwuWspwSNfq4BARjEc2sKEvK5VaqxHILSmwSNLaeQbH2ktWtxfmd5GXzjlJf7zjaHAqOTYeGfciqu63Peo6M7XMHCW4S036TIfaXYUwBu5QAc0kMwBE4pyzTHFFWRbfzTbs4WCr)blRTy8QlILT3h8AqrywuPgCiwqdSqabIS2cZ90CU1wpwcqOgeARmbyHaceL(DkHJU5ESzOo)kmlaMf0YIcwSNfWzDGMcMcGywuWspwq4Z5QAYeGfciqucKWXRalzzSeGqni0wzcE6QGzOo)kmlaMf0YsFwuWccFoxvtMaykalW7pyXsFwuWI9SacFtBnXtWwI0RIm)fa6kuSOGLaebvE9M6qT)PMtSOGf7zbCwhOPGPaiMffSqb9fHjZvjVIZIcwC8pUofbTrdl5Xc6daR3kwaul7ATrLRQjqRyATbJS2W0BT5H)GL1gcFoxvtwBiC9IS26XI6Q1mJJGk4cNAdv5iUzOo)kml5XcAzjlJf7zrD1AMXrqfCHtTHQCe3SIyPplkyPhlQRwZa0vGdbMOUiOnA6O6turdQlhKzOo)kmlaMfubqtNJmw6ZIcw6XI6Q1muqFrykHHAFmd15xHzjpwqfanDoYyjlJf1vRzOG(IWusVkFmd15xHzjpwqfanDoYyPV1giHdZf9hSS2IXWcDplGWNfW1Cfkw(DIfQazb2yjg1rqfCHzj)nuLJ4iNfW1Cfkwa6kWHazH6IG2OPJQNf4WYvS87elAh)SGkaYcSXIxSGEb9fHjRne(KkVJS2aHFAOyyDd1r1JTERybWTSR1gvUQMaTIP1Mh(dwwB4v1UHS2cZ90CU12qTHW7UQMyrblVpOO38xhLEyc8iwYJfLboSOGfpkf2PaqSOGfe(CUQMmGWpnumSUH6O6XwBH4bnLEFqrp2kwkB9wXszayzxRnQCvnbAftRnp8hSS26GWQDdzTfM7P5CRTHAdH3DvnXIcwEFqrV5Vok9We4rSKhlkhBdAzrblEukStbGyrbli85CvnzaHFAOyyDd1r1JT2cXdAk9(GIESvSu26TILYkBzxRnQCvnbAftRnp8hSS2WpP1(KAAFiRTWCpnNBTnuBi8URQjwuWY7dk6n)1rPhMapIL8yrzGdlaJLH68RWSOGfpkf2PaqSOGfe(CUQMmGWpnumSUH6O6XwBH4bnLEFqrp2kwkB9wXszazzxRnQCvnbAftRnp8hSS2AWjqjylv(VgYAdKWH5I(dwwB5pySybwSeazX297W1ZsWJIUcL1wyUNMZT28OuyNcaz9wXs5yBzxRnQCvnbAftRnp8hSS2OUiOnAsQWc0AdKWH5I(dwwBOxxe0gnSetybYITDQyXvHRNLhYcvpnS4SuKnwIjmN2LfBxbcTXIxGSGDeeln4WcAYjsSZkyTfM7P5CRTESqb9fHjJEv(KkczplzzSqb9fHjdgQ9jveYEwYYyHc6lctgVINkczplzzSOUAnJQR9kqjyl5AD63Vcfov(VgYmuNFfML8ybGyqllzzSOUAnJQR9kqjyl5AD63Vcfo5tWlYmuNFfML8ybGyqllzzS44FCDkcAJgwYJfaoayrblbiudcTvMGNUkygYbJZIcwSNfWzDGMcMcGyw6ZIcw6Xsac1GqBLj4PRcMH68RWSKhlXgaSKLXsac1GqBLj4PRcMHCW4S0NLSmwU6PjcQ9NatTd1(NgQZVcZcGzrzay9wXsz03YUwBu5QAc0kMwBE4pyzT1wt8eSLi9QiRnqchMl6pyzTL)GOhlZHA)zrLAWHyzHVcflOjNwBH5EAo3AlaHAqOTYe80vbZqoyCwuWccFoxvtMaykalW7pyXIcw6XIJ)X1PiOnAyjpwa4aGffSyplbicQ86n1HA)tnNyjlJLaebvE9M6qT)PMtSOGfh)JRtrqB0WcGzb9bal9zrbl2ZsaIGkVEdcQ(94dlkyPhl2ZsaIGkVEtDO2)uZjwYYyjaHAqOTYeGfciqu63Peo6M7XMHCW4S0NffSyplGZ6anfmfaXwVvSugTw21AJkxvtGwX0AdgzTHP3AZd)blRne(CUQMS2q46fzTzplGZ6anfmfaXSOGfe(CUQMmbWuawG3FWIffS0JLES44FCDkcAJgwYJfaoayrbl9yrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiwYYyXEwcqeu51Bak(CEXsFwYYyrD1AgvnecQx43SIyrblQRwZOQHqq9c)MH68RWSaywuxTMj4PRcgW14)blw6Zswglx90eb1(tGP2HA)td15xHzbWSOUAntWtxfmGRX)dwSKLXsaIGkVEtDO2)uZjw6ZIcw6XI9SeGiOYR3uhQ9p1CILSmw6XIJ)X1PiOnAybWSG(aGLSmwaHVPTM4jylr6vrM)caDfkw6ZIcw6XccFoxvtMaSqabIsGeoEfyjlJLaeQbH2ktawiGarPFNs4OBUhBgYbJZsFw6BTbs4WCr)blRn0KtKyNvGfB7uXI)SaWbaWyjNyagl9GJgAJgw(DVyb9bal5edWyX297SGgyHace1NfB3VdxplAi(kuS8xhXYvSetnecQx4NfVazrFfXYkIfB3VZcAGfciqelxJL7zXMJzbKWXRabATHWNu5DK1wamfGf49hSsQq)TERyPmWXYUwBu5QAc0kMwBH5EAo3AdHpNRQjtamfGf49hSsQq)T28WFWYAlqAc)NRtU(qvDu9wVvSugGyzxRnQCvnbAftRTWCpnNBTHWNZv1KjaMcWc8(dwjvO)wBE4pyzTDvWNY)dwwVvSugGAzxRnQCvnbAftRnyK1gMERnp8hSS2q4Z5QAYAdHRxK1gf0xeMmxL0RYhwaEwaOSGew8WFWYGFFA3qgczuy9u6VoIfGXI9Sqb9fHjZvj9Q8HfGNLESaCybyS8UMQ3GHlDc2s)oLAWHWVHkxvtGSa8SeBw6ZcsyXd)blJTX)DdHmkSEk9xhXcWybagaXcsybhrADA3XpzTbs4WCr)blRn0d)xN)eMLDOnw6wHDwYjgGXIpelO8RiqwIOHfmfGfO1gcFsL3rwBoocGrZgfSERyPma3YUwBu5QAc0kMwBE4pyzTHFFWRbfzTbs4WCr)blRTy8QlILT3h8AqrywSTtfl)oXs7qT)SCywCv46z5HSqfiYzPnuLJ4SCywCv46z5HSqfiYzjoCXIpel(ZcahaaJLCIbySCflEXc6f0xeMqolOjNiXoRalAh)yw8c(70WcafyykGzboSehUyXgCPbzbIGMGhXshCiw(DVyHZugaSKtmaJfB7uXsC4IfBWLgSq3ZY27dEnOiwkOnRTWCpnNBT1JLREAIGA)jWu7qT)PH68RWSaywqFwYYyPhlQRwZmocQGlCQnuLJ4MH68RWSaywqfanDoYyb4zjqNMLES44FCDkcAJgwqclXgaS0NffSOUAnZ4iOcUWP2qvoIBwrS0NL(SKLXspwC8pUofbTrdlaJfe(CUQMmoocGrZgfyb4zrD1AgkOVimLWqTpMH68RWSamwaHVPTM4jylr6vrM)caHtd15xXcWZcGmOLL8yrzLbalzzS44FCDkcAJgwagli85CvnzCCeaJMnkWcWZI6Q1muqFrykPxLpMH68RWSamwaHVPTM4jylr6vrM)caHtd15xXcWZcGmOLL8yrzLbal9zrbluqFryYCvYR4SOGLESyplQRwZe80vbZkILSmwSNL31u9g87JgoGgQCvnbYsFwuWspw6XI9SeGqni0wzcE6QGzfXswglbicQ86nafFoVyrbl2Zsac1GqBLH6IG2OjPclqZkIL(SKLXsaIGkVEtDO2)uZjw6ZIcw6XI9SeGiOYR3GGQFp(Wswgl2ZI6Q1mbpDvWSIyjlJfh)JRtrqB0WsESaWbal9zjlJLES8UMQ3GFF0Wb0qLRQjqwuWI6Q1mbpDvWSIyrbl9yrD1Ag87JgoGg87bGybWSeBwYYyXX)46ue0gnSKhlaCaWsFw6ZswglQRwZe80vbZkIffSyplQRwZmocQGlCQnuLJ4MvelkyXEwExt1BWVpA4aAOYv1eO1Bflabal7ATrLRQjqRyAT5H)GL1wr2sDqyzTbs4WCr)blRT8btSK)bHfMLRyXowLpSGEb9fHjw8cKfSJGyjgzx3aw(BP1SK)bHfln4WcAYjsSZkyTfM7P5CRTESOUAndf0xeMs6v5JzOo)kml5XcHmkSEk9xhXswgl9yjS7dkcZIsSaiwuWYqHDFqrP)6iwamlOLL(SKLXsy3hueMfLyj2S0NffS4rPWofaY6TIfGu2YUwBu5QAc0kMwBH5EAo3ARhlQRwZqb9fHPKEv(ygQZVcZsESqiJcRNs)1rSOGLESeGqni0wzcE6QGzOo)kml5XcAbalzzSeGqni0wzcWcbeik97uchDZ9yZqD(vywYJf0caw6Zswgl9yjS7dkcZIsSaiwuWYqHDFqrP)6iwamlOLL(SKLXsy3hueMfLyj2S0NffS4rPWofaYAZd)blRTDx3sDqyz9wXcqaYYUwBu5QAc0kMwBH5EAo3ARhlQRwZqb9fHPKEv(ygQZVcZsESqiJcRNs)1rSOGLESeGqni0wzcE6QGzOo)kml5XcAbalzzSeGqni0wzcWcbeik97uchDZ9yZqD(vywYJf0caw6Zswgl9yjS7dkcZIsSaiwuWYqHDFqrP)6iwamlOLL(SKLXsy3hueMfLyj2S0NffS4rPWofaYAZd)blRT2sRtDqyz9wXcqX2YUwBu5QAc0kMwBGeomx0FWYAdPaIESalwcGwBE4pyzTzZN5Gtc2sKEvK1BflaH(w21AJkxvtGwX0AZd)blRn87t7gYAdKWH5I(dwwB5dMyz79PDdXYdzjAGbw2GAFyb9c6lctSahwSTtflxXcS0XzXowLpSGEb9fHjw8cKLfMybPaIESenWaMLRXYvSyhRYhwqVG(IWK1wyUNMZT2OG(IWK5QKEv(WswgluqFryYGHAFsfHSNLSmwOG(IWKXR4PIq2ZswglQRwZyZN5Gtc2sKEvKzfXIcwuxTMHc6lctj9Q8XSIyjlJLESOUAntWtxfmd15xHzbWS4H)GLX24)UHqgfwpL(RJyrblQRwZe80vbZkIL(wVvSaeATSR1Mh(dwwB2g)3T2OYv1eOvmTERybiGJLDT2OYv1eOvmT28WFWYABwvYd)bRK(WV1M(WFQ8oYAR5A9VplR36T2CizzxRyPSLDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB9yrD1AM)6iBWPsGd5DQxbsJzOo)kmlaMfubqtNJmwaglaWOmlzzSOUAnZFDKn4ujWH8o1RaPXmuNFfMfaZIh(dwg87t7gYqiJcRNs)1rSamwaGrzwuWspwOG(IWK5QKEv(WswgluqFryYGHAFsfHSNLSmwOG(IWKXR4PIq2ZsFw6ZIcwuxTM5VoYgCQe4qEN6vG0ywrSOGLzvudoOiZFDKn4ujWH8o1RaPXqLRQjqRnqchMl6pyzTHgxhwA)jml22PFNgw(DILy8qExW)WonSOUAnwSDAnlnxRzb2ASy7(9Ry53jwkczplbh)wBi8jvEhzTboK3LSDADQ5ADc2AwVvSaKLDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB2Zcf0xeMmxLWqTpSOGLESGJiTo9(GIESb)(0UHyjpwqllky5DnvVbdx6eSL(Dk1GdHFdvUQMazjlJfCeP1P3hu0Jn43N2nel5XcaHL(wBGeomx0FWYAdnUoS0(tywSTt)onSS9(GxdkILdZIn487SeC8FfkwGiOHLT3N2nelxXIDSkFyb9c6lctwBi8jvEhzTDOk4qj87dEnOiR3kwX2YUwBu5QAc0kMwBE4pyzTfGfciqu63Peo6M7XwBGeomx0FWYAlFWelObwiGarSyBNkw8NfnHXS87EXcAbal5edWyXlqw0xrSSIyX297SGMCIe7ScwBH5EAo3AZEwaN1bAkykaIzrbl9yPhli85CvnzcWcbeikbs44vGffSyplbiudcTvMGNUkygYbJZswglQRwZe80vbZkIL(SOGLESOUAndf0xeMs6v5JzOo)kml5XcWHLSmwuxTMHc6lctjmu7JzOo)kml5XcWHL(SOGLESyplZQOgCqrgvx7vGsWwY160VFfkSHkxvtGSKLXI6Q1mQU2RaLGTKR1PF)ku4u5)Aid(9aqSKhlXMLSmwuxTMr11EfOeSLCTo97xHcN8j4fzWVhaIL8yj2S0NLSmwuHymlkyPDO2)0qD(vywamlkdawuWI9SeGqni0wzcE6QGzihmol9TERyH(w21AJkxvtGwX0AZd)blRTXrqfCHtTHQCe3AdKWH5I(dwwB5dMyj)nuLJ4Sy7(DwqtorIDwbRTWCpnNBTPUAntWtxfmd15xHzjpwugTwVvSqRLDT2OYv1eOvmT28WFWYAdVQ2nK1wiEqtP3hu0JTILYwBH5EAo3ARhld1gcV7QAILSmwuxTMHc6lctjmu7JzOo)kmlaMLyZIcwOG(IWK5QegQ9HffSmuNFfMfaZIYOplky5DnvVbdx6eSL(Dk1GdHFdvUQMazPplky59bf9M)6O0dtGhXsESOm6Zs(XcoI0607dk6XSamwgQZVcZIcw6Xcf0xeMmxL8kolzzSmuNFfMfaZcQaOPZrgl9T2ajCyUO)GL1w(Gjw2wv7gILRyjYlqQ7cSalw8k(VFfkw(D)zrFiimlkJ(ykGzXlqw0egZIT73zPdoelVpOOhZIxGS4pl)oXcvGSaBS4SSb1(Wc6f0xeMyXFwug9zbtbmlWHfnHXSmuNF1vOyXXS8qwk4ZYUJ4kuS8qwgQneENfW1CfkwSJv5dlOxqFryY6TIfWXYUwBu5QAc0kMwBE4pyzTHxv7gYAdKWH5I(dwwB5dMyzBvTBiwEil7ocIfNfuAOQRz5HSSWel2zmsIXwBH5EAo3AdHpNRQjZfdGPaSaV)GflkyjaHAqOTYCfomR3v1ukgwE9RUeiH4cKzihmolkyHIH1ffrGMRWHz9UQMsXWYRF1LajexGSERybqSSR1gvUQMaTIP1wyUNMZT2SNL31u9g8tATpjW5AVHkxvtGSOGLESOUAnd(9P5ATzO2q4DxvtSOGLESGJiTo9(GIESb)(0CTMfaZsSzjlJf7zzwf1GdkY8xhzdovcCiVt9kqAmu5QAcKL(SKLXY7AQEdgU0jyl97uQbhc)gQCvnbYIcwuxTMHc6lctjmu7JzOo)kmlaMLyZIcwOG(IWK5QegQ9HffSOUAnd(9P5ATzOo)kmlaMfaclkybhrAD69bf9yd(9P5Anl5PelOpl9zrbl9yXEwMvrn4GIm64bFCCQPj6VcvcL(6IWKHkxvtGSKLXYFDelivwqF0YsESOUAnd(9P5ATzOo)kmlaJfaXsFwuWY7dk6n)1rPhMapIL8ybTwBE4pyzTHFFAUwB9wXcGAzxRnQCvnbAftRnp8hSS2WVpnxRT2ajCyUO)GL1gsX97SS9Kw7dlX45ApllmXcSyjaYITDQyzO2q4DxvtSOUEwW)P1SyZVNLgCyXoIh8XXSenWalEbYciSq3ZYctSOsn4qSGMym2WY2FAnllmXIk1GdXcAGfciqel4Rcel)U)Sy70AwIgyGfVG)onSS9(0CT2Alm3tZ5wBVRP6n4N0AFsGZ1EdvUQMazrblQRwZGFFAUwBgQneE3v1elkyPhl2ZYSkQbhuKrhp4JJtnnr)vOsO0xxeMmu5QAcKLSmw(RJybPYc6JwwYJf0NL(SOGL3hu0B(RJspmbEel5XsSTERybWTSR1gvUQMaTIP1Mh(dwwB43NMR1wBGeomx0FWYAdP4(DwIXd5DQxbsdllmXY27tZ1AwEilaruelRiw(DIf1vRXIACwCngYYcFfkw2EFAUwZcSybTSGPaSaXSahw0egZYqD(vxHYAlm3tZ5wBZQOgCqrM)6iBWPsGd5DQxbsJHkxvtGSOGfCeP1P3hu0Jn43NMR1SKNsSeBwuWspwSNf1vRz(RJSbNkboK3PEfinMvelkyrD1Ag87tZ1AZqTHW7UQMyjlJLESGWNZv1KbCiVlz706uZ16eS1yrbl9yrD1Ag87tZ1AZqD(vywamlXMLSmwWrKwNEFqrp2GFFAUwZsESaiwuWY7AQEd(jT2Ne4CT3qLRQjqwuWI6Q1m43NMR1MH68RWSaywqll9zPpl9TERyPmaSSR1gvUQMaTIP1gmYAdtV1Mh(dwwBi85CvnzTHW1lYAZX)46ue0gnSKhlauaWs(XspwugaSa8SOUAnZFDKn4ujWH8o1RaPXGFpael9zj)yPhlQRwZGFFAUwBgQZVcZcWZsSzbjSGJiToT74Nyb4zXEwExt1BWpP1(KaNR9gQCvnbYsFwYpw6Xsac1GqBLb)(0CT2muNFfMfGNLyZcsybhrADA3XpXcWZY7AQEd(jT2Ne4CT3qLRQjqw6Zs(XspwaHVPTM4jylr6vrMH68RWSa8SGww6ZIcw6XI6Q1m43NMR1MvelzzSeGqni0wzWVpnxRnd15xHzPV1giHdZf9hSS2qJRdlT)eMfB70VtdlolBVp41GIyzHjwSDAnlbFHjw2EFAUwZYdzP5AnlWwd5S4fillmXY27dEnOiwEilaruelX4H8o1RaPHf87bGyzfzTHWNu5DK1g(9P5ADYgS(uZ16eS1SERyPSYw21AJkxvtGwX0AZd)blRn87dEnOiRnqchMl6pyzTLpyILT3h8AqrSy7(DwIXd5DQxbsdlpKfGikILvel)oXI6Q1yX297W1ZIgIVcflBVpnxRzzf9xhXIxGSSWelBVp41GIybwSG(aJLycZPDzb)EaimlR6pnlOplVpOOhBTfM7P5CRne(CUQMmGd5DjBNwNAUwNGTglkybHpNRQjd(9P5ADYgS(uZ16eS1yrbl2ZccFoxvtMdvbhkHFFWRbfXswgl9yrD1Agvx7vGsWwY160VFfkCQ8FnKb)EaiwYJLyZswglQRwZO6AVcuc2sUwN(9RqHt(e8Im43daXsESeBw6ZIcwWrKwNEFqrp2GFFAUwZcGzb9zrbli85CvnzWVpnxRt2G1NAUwNGTM1BflLbKLDT2OYv1eOvmT28WFWYAZb9O)qqjSnF6S2cXdAk9(GIESvSu2Alm3tZ5wB2ZYFbGUcflkyXEw8WFWY4GE0FiOe2MpDjqVZrrMRsn9HA)zjlJfq4BCqp6peucBZNUeO35Oid(9aqSaywInlkybe(gh0J(dbLW28Plb6DokYmuNFfMfaZsST2ajCyUO)GL1w(GjwW28PJfmKLF3FwIdxSGIEw6CKXYk6VoIf14SSWxHIL7zXXSO9NyXXSebX4tvtSalw0egZYV7flXMf87bGWSahwqkzHFwSTtflXgySGFpaeMfczr3qwVvSuo2w21AJkxvtGwX0AZd)blRToiSA3qwBH4bnLEFqrp2kwkBTfM7P5CRTHAdH3DvnXIcwEFqrV5Vok9We4rSKhl9yPhlkJ(Samw6XcoI0607dk6Xg87t7gIfGNfaXcWZI6Q1muqFrykPxLpMvel9zPplaJLH68RWS0NfKWspwuMfGXY7AQEZB7QuhewydvUQMazPplkyPhlbiudcTvMGNUkygYbJZIcwSNfWzDGMcMcGywuWspwq4Z5QAYeGfciqucKWXRalzzSeGqni0wzcWcbeik97uchDZ9yZqoyCwYYyXEwcqeu51BQd1(NAoXsFwYYybhrAD69bf9yd(9PDdXcGzPhl9yb4Ws(XspwuxTMHc6lctj9Q8XSIyb4zbqS0NL(Sa8S0JfLzbyS8UMQ382Uk1bHf2qLRQjqw6ZsFwuWI9Sqb9fHjdgQ9jveYEwYYyPhluqFryYCvcd1(Wswgl9yHc6lctMRsQWFNLSmwOG(IWK5QKEv(WsFwuWI9S8UMQ3GHlDc2s)oLAWHWVHkxvtGSKLXI6Q1mrZ1bhWZ1jFcEDHu0sJ9XGW1lIL8uIfaHwaWsFwuWspwWrKwNEFqrp2GFFA3qSaywugaSa8S0JfLzbyS8UMQ382Uk1bHf2qLRQjqw6ZsFwuWIJ)X1PiOnAyjpwqlayj)yrD1Ag87tZ1AZqD(vywaEwaoS0NffS0Jf7zrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiwYYyHc6lctMRsyO2hwYYyXEwcqeu51Bak(CEXsFwuWI9SOUAnZ4iOcUWP2qvoINWx1w60EC8tZ5MvK1giHdZf9hSS2IrP2q4DwY)GWQDdXY1ybn5ej2zfy5WSmKdgh5S870qS4dXIMWyw(DVybTS8(GIEmlxXIDSkFyb9c6lctSy7(Dw2GF(d5SOjmMLF3lwugaSa)DASDyILRyXR4SGEb9fHjwGdlRiwEilOLL3hu0JzrLAWHyXzXowLpSGEb9fHjdlXyyHUNLHAdH3zbCnxHIfKYxboeilOxxe0gnDu9SSknHXSCflBqTpSGEb9fHjR3kwkJ(w21AJkxvtGwX0AZd)blRTgCcuc2sL)RHS2ajCyUO)GL1w(GjwYFWyXcSyjaYIT73HRNLGhfDfkRTWCpnNBT5rPWofaY6TILYO1YUwBu5QAc0kMwBWiRnm9wBE4pyzTHWNZv1K1gcxViRn7zbCwhOPGPaiMffSGWNZv1KjaMcWc8(dwSOGLES0Jf1vRzWVpnxRnRiwYYy5DnvVb)Kw7tcCU2BOYv1eilzzSeGiOYR3uhQ9p1CIL(SOGLESyplQRwZGHA8FbYSIyrbl2ZI6Q1mbpDvWSIyrbl9yXEwExt1BARjEc2sKEvKHkxvtGSKLXI6Q1mbpDvWaUg)pyXsESeGqni0wzARjEc2sKEvKzOo)kmlaJfakl9zrbli85Cvnz(9506eMiGOjzZVNffS0Jf7zjarqLxVPou7FQ5elzzSeGqni0wzcWcbeik97uchDZ9yZkIffS0Jf1vRzWVpnxRnd15xHzbWSaiwYYyXEwExt1BWpP1(KaNR9gQCvnbYsFw6ZIcwEFqrV5Vok9We4rSKhlQRwZe80vbd4A8)GflaplaWaqyPplzzSOcXywuWs7qT)PH68RWSaywuxTMj4PRcgW14)blw6BTHWNu5DK1wamfGf49hSsoKSERyPmWXYUwBu5QAc0kMwBE4pyzTfinH)Z1jxFOQoQERnqchMl6pyzTLpyIf0KtKyNvGfyXsaKLvPjmMfVazrFfXY9SSIyX297SGgyHacezTfM7P5CRne(CUQMmbWuawG3FWk5qY6TILYael7ATrLRQjqRyATfM7P5CRne(CUQMmbWuawG3FWk5qYAZd)blRTRc(u(FWY6TILYaul7ATrLRQjqRyAT5H)GL1g1fbTrtsfwGwBGeomx0FWYAlFWelOxxe0gnSetybYcSyjaYIT73zz79P5AnlRiw8cKfSJGyPbhwayln2hw8cKf0KtKyNvWAlm3tZ5wBx90eb1(tGP2HA)td15xHzbWSOmAzjlJLESOUAnt0CDWb8CDYNGxxifT0yFmiC9IybWSai0cawYYyrD1AMO56Gd456KpbVUqkAPX(yq46fXsEkXcGqlayPplkyrD1Ag87tZ1AZkIffS0JLaeQbH2ktWtxfmd15xHzjpwqlayjlJfWzDGMcMcGyw6B9wXszaULDT2OYv1eOvmT28WFWYAd)Kw7tQP9HS2cXdAk9(GIESvSu2Alm3tZ5wBd1gcV7QAIffS8xhLEyc8iwYJfLrllkybhrAD69bf9yd(9PDdXcGzb9zrblEukStbGyrbl9yrD1AMGNUkygQZVcZsESOmayjlJf7zrD1AMGNUkywrS03AdKWH5I(dwwBXOuBi8olnTpelWILvelpKLyZY7dk6XSy7(D46zbn5ej2zfyrLUcflUkC9S8qwiKfDdXIxGSuWNficAcEu0vOSERybiayzxRnQCvnbAftRnp8hSS2ARjEc2sKEvK1giHdZf9hSS2YhmXs(dIESCnwUcFGelEXc6f0xeMyXlqw0xrSCplRiwSD)ololaSLg7dlrdmWIxGSKtqp6peelB28PZAlm3tZ5wBuqFryYCvYR4SOGfpkf2PaqSOGf1vRzIMRdoGNRt(e86cPOLg7JbHRxelaMfaHwaWIcw6Xci8noOh9hckHT5txc07CuK5VaqxHILSmwSNLaebvE9MIcdudhqwYYybhrAD69bf9ywYJfaXsFwuWspwuxTMzCeubx4uBOkhXnd15xHzbWSaWzj)yPhlOLfGNLzvudoOid(Q2sN2JJFAo3qLRQjqw6ZIcwuxTMzCeubx4uBOkhXnRiwYYyXEwuxTMzCeubx4uBOkhXnRiw6ZIcw6XI9SeGqni0wzcE6QGzfXswglQRwZ87ZP1jmrarJb)EaiwamlkJwwuWs7qT)PH68RWSaywaeaaalkyPDO2)0qD(vywYJfLbaayjlJf7zbdxA1Ran)(CADcteq0yOYv1eil9zrbl9ybdxA1Ran)(CADcteq0yOYv1eilzzSeGqni0wzcE6QGzOo)kml5XsSbal9TERybiLTSR1gvUQMaTIP1Mh(dwwB43NMR1wBGeomx0FWYAlFWelolBVpnxRzj)VOFNLObgyzvAcJzz79P5AnlhMfxpKdgNLvelWHL4Wfl(qS4QW1ZYdzbIGMGhXsoXamRTWCpnNBTPUAndSOFhNIOjqr)blZkIffS0Jf1vRzWVpnxRnd1gcV7QAILSmwC8pUofbTrdl5XcahaS036TIfGaKLDT2OYv1eOvmT28WFWYAd)(0CT2AdKWH5I(dwwBX4vxel5edWyrLAWHybnWcbeiIfB3VZY27tZ1Aw8cKLFNkw2EFWRbfzTfM7P5CRTaebvE9M6qT)PMtSOGf7z5DnvVb)Kw7tcCU2BOYv1eilkyPhli85CvnzcWcbeikbs44vGLSmwcqOgeARmbpDvWSIyjlJf1vRzcE6QGzfXsFwuWsac1GqBLjaleqGO0VtjC0n3Jnd15xHzbWSGkaA6CKXcWZsGonl9yXX)46ue0gnSGewqlayPplkyrD1Ag87tZ1AZqD(vywamlOplkyXEwaN1bAkykaITERybOyBzxRnQCvnbAftRTWCpnNBTfGiOYR3uhQ9p1CIffS0Jfe(CUQMmbyHaceLajC8kWswglbiudcTvMGNUkywrSKLXI6Q1mbpDvWSIyPplkyjaHAqOTYeGfciqu63Peo6M7XMH68RWSaywaoSOGf1vRzWVpnxRnRiwuWcf0xeMmxL8kolkyXEwq4Z5QAYCOk4qj87dEnOiwuWI9SaoRd0uWuaeBT5H)GL1g(9bVguK1BflaH(w21AJkxvtGwX0AZd)blRn87dEnOiRnqchMl6pyzTLpyILT3h8AqrSy7(Dw8IL8)I(DwIgyGf4WY1yjoCHoqwGiOj4rSKtmaJfB3VZsC4AyPiK9SeC8ByjNAmKfWvxel5edWyXFw(DIfQazb2y53jwIrq1VhFyrD1ASCnw2EFAUwZIn4sdwO7zP5AnlWwJf4WsC4IfFiwGflaIL3hu0JT2cZ90CU1M6Q1mWI(DCkOjFsio8blZkILSmw6XI9SGFFA3qgpkf2PaqSOGf7zbHpNRQjZHQGdLWVp41GIyjlJLESOUAntWtxfmd15xHzbWSGwwuWI6Q1mbpDvWSIyjlJLES0Jf1vRzcE6QGzOo)kmlaMfubqtNJmwaEwc0PzPhlo(hxNIG2OHfKWsSbal9zrblQRwZe80vbZkILSmwuxTMzCeubx4uBOkhXt4RAlDApo(P5CZqD(vywamlOcGMohzSa8SeOtZspwC8pUofbTrdliHLydaw6ZIcwuxTMzCeubx4uBOkhXt4RAlDApo(P5CZkIL(SOGLaebvE9geu97Xhw6ZsFwuWspwWrKwNEFqrp2GFFAUwZcGzj2SKLXccFoxvtg87tZ16Kny9PMR1jyRXsFw6ZIcwSNfe(CUQMmhQcouc)(GxdkIffS0Jf7zzwf1GdkY8xhzdovcCiVt9kqAmu5QAcKLSmwWrKwNEFqrp2GFFAUwZcGzj2S036TIfGqRLDT2OYv1eOvmT28WFWYARiBPoiSS2ajCyUO)GL1w(GjwY)GWcZYvSSb1(Wc6f0xeMyXlqwWocIL83sRzj)dclwAWHf0KtKyNvWAlm3tZ5wB9yrD1AgkOVimLWqTpMH68RWSKhleYOW6P0FDelzzS0JLWUpOimlkXcGyrbldf29bfL(RJybWSGww6ZswglHDFqrywuILyZsFwuWIhLc7uaiR3kwac4yzxRnQCvnbAftRTWCpnNBT1Jf1vRzOG(IWucd1(ygQZVcZsESqiJcRNs)1rSKLXspwc7(GIWSOelaIffSmuy3huu6VoIfaZcAzPplzzSe29bfHzrjwInl9zrblEukStbGyrbl9yrD1AMXrqfCHtTHQCe3muNFfMfaZcAzrblQRwZmocQGlCQnuLJ4MvelkyXEwMvrn4GIm4RAlDApo(P5CdvUQMazjlJf7zrD1AMXrqfCHtTHQCe3SIyPV1Mh(dwwB7UUL6GWY6TIfGaiw21AJkxvtGwX0Alm3tZ5wB9yrD1AgkOVimLWqTpMH68RWSKhleYOW6P0FDelkyPhlbiudcTvMGNUkygQZVcZsESGwaWswglbiudcTvMaSqabIs)oLWr3Cp2muNFfML8ybTaGL(SKLXspwc7(GIWSOelaIffSmuy3huu6VoIfaZcAzPplzzSe29bfHzrjwInl9zrblEukStbGyrbl9yrD1AMXrqfCHtTHQCe3muNFfMfaZcAzrblQRwZmocQGlCQnuLJ4MvelkyXEwMvrn4GIm4RAlDApo(P5CdvUQMazjlJf7zrD1AMXrqfCHtTHQCe3SIyPV1Mh(dwwBTLwN6GWY6TIfGaOw21AJkxvtGwX0AdKWH5I(dwwB5dMybPaIESalwqtm2AZd)blRnB(mhCsWwI0RISERybiaULDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB4isRtVpOOhBWVpTBiwYJf0NfGXstdHdl9yPZXpnXtiC9Iyb4zrzaaawqclacaS0NfGXstdHdl9yrD1Ag87dEnOOe1fbTrthvFcd1(yWVhaIfKWc6ZsFRnqchMl6pyzTHgxhwA)jml22PFNgwEillmXY27t7gILRyzdQ9HfB7xyNLdZI)SGwwEFqrpgykZsdoSqiOjolacaivw6C8ttCwGdlOplBVp41GIyb96IG2OPJQNf87bGWwBi8jvEhzTHFFA3qPRsyO2hR3kwXgaw21AJkxvtGwX0AdgzTHP3AZd)blRne(CUQMS2q46fzTPmliHfCeP1PDh)elaMfaXs(XspwaGbqSa8S0JfCeP1P3hu0Jn43N2nel5hlkZsFwaEw6XIYSamwExt1BWWLobBPFNsn4q43qLRQjqwaEwu2Gww6ZsFwaglaWOmAzb4zrD1AMXrqfCHtTHQCe3muNFf2AdKWH5I(dwwBOX1HL2FcZITD63PHLhYcsX4)olGR5kuSK)gQYrCRne(KkVJS2Sn(VNUk1gQYrCR3kwXwzl7ATrLRQjqRyAT5H)GL1MTX)DRnqchMl6pyzTLpyIfKIX)DwUILnO2hwqVG(IWelWHLRXsbzz79PDdXITtRzPDplx9qwqtorIDwbw8kEhCiRTWCpnNBT1JfkOVimz0RYNuri7zjlJfkOVimz8kEQiK9SOGfe(CUQMmhof0KJGyPplkyPhlVpOO38xhLEyc8iwYJf0NLSmwOG(IWKrVkFsxLaelzzS0ou7FAOo)kmlaMfLbal9zjlJf1vRzOG(IWucd1(ygQZVcZcGzXd)bld(9PDdziKrH1tP)6iwuWI6Q1muqFrykHHAFmRiwYYyHc6lctMRsyO2hwuWI9SGWNZv1Kb)(0UHsxLWqTpSKLXI6Q1mbpDvWmuNFfMfaZIh(dwg87t7gYqiJcRNs)1rSOGf7zbHpNRQjZHtbn5iiwuWI6Q1mbpDvWmuNFfMfaZcHmkSEk9xhXIcwuxTMj4PRcMvelzzSOUAnZ4iOcUWP2qvoIBwrSOGfe(CUQMm2g)3txLAdv5iolzzSypli85CvnzoCkOjhbXIcwuxTMj4PRcMH68RWSKhleYOW6P0FDK1BfRydil7ATrLRQjqRyATbs4WCr)blRT8btSS9(0UHy5ASCfl2XQ8Hf0lOVimHCwUILnO2hwqVG(IWelWIf0hyS8(GIEmlWHLhYs0adSSb1(Wc6f0xeMS28WFWYAd)(0UHSERyf7yBzxRnQCvnbAftRnqchMl6pyzTL)CT(3NL1Mh(dwwBZQsE4pyL0h(T20h(tL3rwBnxR)9zz9wV1wZ16FFww21kwkBzxRnQCvnbAftRnp8hSS2WVp41GIS2ajCyUO)GL1227dEnOiwAWHLoicQJQNLvPjmMLf(kuSetyoTR1wyUNMZT2SNLzvudoOiJQR9kqjyl5AD63Vcf2qXW6IIiqR3kwaYYUwBu5QAc0kMwBE4pyzTHxv7gYAlepOP07dk6XwXszRTWCpnNBTbcFthewTBiZqD(vywYJLH68RWSa8SaiaXcsyrzaQ1giHdZf9hSS2qJJFw(DIfq4ZIT73z53jw6G4NL)6iwEiloiilR6pnl)oXsNJmwaxJ)hSy5WSSFVHLTv1UHyzOo)kmlDl9Fr6Jaz5HS05FyNLoiSA3qSaUg)pyz9wXk2w21AZd)blRToiSA3qwBu5QAc0kMwV1BTHFl7AflLTSR1gvUQMaTIP1Mh(dwwB43h8AqrwBGeomx0FWYAlFWelBVp41GIy5HSaerrSSIy53jwIXd5DQxbsdlQRwJLRXY9SydU0GSqil6gIfvQbhIL2vhE)kuS87elfHSNLGJFwGdlpKfWvxelQudoelObwiGarwBH5EAo3ABwf1GdkY8xhzdovcCiVt9kqAmu5QAcKffS0JfkOVimzUk5vCwuWI9S0JLESOUAnZFDKn4ujWH8o1RaPXmuNFfML8yXd)blJTX)DdHmkSEk9xhXcWybagLzrbl9yHc6lctMRsQWFNLSmwOG(IWK5QegQ9HLSmwOG(IWKrVkFsfHSNL(SKLXI6Q1m)1r2GtLahY7uVcKgZqD(vywYJfp8hSm43N2nKHqgfwpL(RJybySaaJYSOGLESqb9fHjZvj9Q8HLSmwOG(IWKbd1(KkczplzzSqb9fHjJxXtfHSNL(S0NLSmwSNf1vRz(RJSbNkboK3PEfinMvel9zjlJLESOUAntWtxfmRiwYYybHpNRQjtawiGarjqchVcS0NffSeGqni0wzcWcbeik97uchDZ9yZqoyCwuWsaIGkVEtDO2)uZjw6ZIcw6XI9SeGiOYR3au858ILSmwcqOgeARmuxe0gnjvybAgQZVcZsESaqzPplkyPhlQRwZe80vbZkILSmwSNLaeQbH2ktWtxfmd5GXzPV1BflazzxRnQCvnbAftRnp8hSS2Cqp6peucBZNoRTq8GMsVpOOhBflLT2cZ90CU1M9SacFJd6r)HGsyB(0La9ohfz(la0vOyrbl2ZIh(dwgh0J(dbLW28Plb6DokYCvQPpu7plkyPhl2Zci8noOh9hckHT5txANCT5VaqxHILSmwaHVXb9O)qqjSnF6s7KRnd15xHzjpwqll9zjlJfq4BCqp6peucBZNUeO35Oid(9aqSaywInlkybe(gh0J(dbLW28Plb6DokYmuNFfMfaZsSzrblGW34GE0FiOe2MpDjqVZrrM)caDfkRnqchMl6pyzTLpyILCc6r)HGyzZMpDSyBNkw(DAiwomlfKfp8hcIfSnF6qoloMfT)eloMLiigFQAIfyXc2MpDSy7(DwaelWHLgzJgwWVhacZcCybwS4SeBGXc2MpDSGHS87(ZYVtSuKnwW28PJfFMdbHzbPKf(zXBpnS87(Zc2MpDSqil6gcB9wXk2w21AJkxvtGwX0AZd)blRTaSqabIs)oLWr3Cp2AdKWH5I(dwwB5dMWSGgyHaceXY1ybn5ej2zfy5WSSIyboSehUyXhIfqchVcxHIf0KtKyNvGfB3VZcAGfciqelEbYsC4IfFiwujn0glOpayjNyaM1wyUNMZT2SNfWzDGMcMcGywuWspw6XccFoxvtMaSqabIsGeoEfyrbl2Zsac1GqBLj4PRcMHCW4SOGf7zzwf1GdkYenxhCapxN8j41fsrln2hdvUQMazjlJf1vRzcE6QGzfXsFwuWIJ)X1PiOnAybWkXc6dawuWspwuxTMHc6lctj9Q8XmuNFfML8yrzaWswglQRwZqb9fHPegQ9XmuNFfML8yrzaWsFwYYyrfIXSOGL2HA)td15xHzbWSOmayrbl2Zsac1GqBLj4PRcMHCW4S036TIf6BzxRnQCvnbAftRnyK1gMERnp8hSS2q4Z5QAYAdHRxK1wpwuxTMzCeubx4uBOkhXnd15xHzjpwqllzzSyplQRwZmocQGlCQnuLJ4Mvel9zrbl2ZI6Q1mJJGk4cNAdv5iEcFvBPt7XXpnNBwrSOGLESOUAndqxboeyI6IG2OPJQprfnOUCqMH68RWSaywqfanDoYyPplkyPhlQRwZqb9fHPegQ9XmuNFfML8ybva005iJLSmwuxTMHc6lctj9Q8XmuNFfML8ybva005iJLSmw6XI9SOUAndf0xeMs6v5JzfXswgl2ZI6Q1muqFrykHHAFmRiw6ZIcwSNL31u9gmuJ)lqgQCvnbYsFRnqchMl6pyzTHgybE)blwAWHfxRzbe(yw(D)zPZbIWSGxdXYVtXzXhQq3ZYqTHW7eil22PILyuhbvWfML83qvoIZYUJzrtyml)UxSGwwWuaZYqD(vxHIf4WYVtSau858If1vRXYHzXvHRNLhYsZ1AwGTglWHfVIZc6f0xeMy5WS4QW1ZYdzHqw0nK1gcFsL3rwBGWpnumSUH6O6XwVvSqRLDT2OYv1eOvmT2GrwBy6T28WFWYAdHpNRQjRneUErwB9yXEwuxTMHc6lctjmu7JzfXIcwSNf1vRzOG(IWusVkFmRiw6ZswglVRP6nyOg)xGmu5QAc0AdKWH5I(dwwBObwG3FWILF3Fwc7uaimlxJL4Wfl(qSaxp(ajwOG(IWelpKfyPJZci8z53PHyboSCOk4qS87hMfB3VZYguJ)lqwBi8jvEhzTbc)eC94dKsuqFryY6TIfWXYUwBu5QAc0kMwBE4pyzT1bHv7gYAlm3tZ5wBd1gcV7QAIffS0Jf1vRzOG(IWucd1(ygQZVcZsESmuNFfMLSmwuxTMHc6lctj9Q8XmuNFfML8yzOo)kmlzzSGWNZv1Kbe(j46XhiLOG(IWel9zrbld1gcV7QAIffS8(GIEZFDu6HjWJyjpwugqSOGfpkf2PaqSOGfe(CUQMmGWpnumSUH6O6XwBH4bnLEFqrp2kwkB9wXcGyzxRnQCvnbAftRnp8hSS2WRQDdzTfM7P5CRTHAdH3DvnXIcw6XI6Q1muqFrykHHAFmd15xHzjpwgQZVcZswglQRwZqb9fHPKEv(ygQZVcZsESmuNFfMLSmwq4Z5QAYac)eC94dKsuqFryIL(SOGLHAdH3DvnXIcwEFqrV5Vok9We4rSKhlkdiwuWIhLc7uaiwuWccFoxvtgq4Ngkgw3qDu9yRTq8GMsVpOOhBflLTERybqTSR1gvUQMaTIP1Mh(dwwB4N0AFsnTpK1wyUNMZT2gQneE3v1elkyPhlQRwZqb9fHPegQ9XmuNFfML8yzOo)kmlzzSOUAndf0xeMs6v5JzOo)kml5XYqD(vywYYybHpNRQjdi8tW1Jpqkrb9fHjw6ZIcwgQneE3v1elky59bf9M)6O0dtGhXsESOmWHffS4rPWofaIffSGWNZv1Kbe(PHIH1nuhvp2AlepOP07dk6XwXszR3kwaCl7ATrLRQjqRyAT5H)GL1wdobkbBPY)1qwBGeomx0FWYAlFWel5pySybwSeazX297W1ZsWJIUcL1wyUNMZT28OuyNcaz9wXszayzxRnQCvnbAftRnp8hSS2OUiOnAsQWc0AdKWH5I(dwwB5dMybP8vGdbYYw0n3JzX297S4vCw0WcflubxO2zr74)kuSGEb9fHjw8cKLFIZYdzrFfXY9SSIyX297SaWwASpS4filOjNiXoRG1wyUNMZT26XspwuxTMHc6lctjmu7JzOo)kml5XIYaGLSmwuxTMHc6lctj9Q8XmuNFfML8yrzaWsFwuWsac1GqBLj4PRcMH68RWSKhlXgaSOGLESOUAnt0CDWb8CDYNGxxifT0yFmiC9IybWSai0haSKLXI9SmRIAWbfzIMRdoGNRt(e86cPOLg7JHIH1ffrGS0NL(SKLXI6Q1mrZ1bhWZ1jFcEDHu0sJ9XGW1lIL8uIfabqaalzzSeGqni0wzcE6QGzihmolkyXX)46ue0gnSKhlaCay9wXszLTSR1gvUQMaTIP1gmYAdtV1Mh(dwwBi85CvnzTHW1lYAZEwaN1bAkykaIzrbli85CvnzcGPaSaV)GflkyPhl9yjaHAqOTYqDrXhY1j4awEfiZqD(vywamlkdCaiSamw6XIYkZcWZYSkQbhuKbFvBPt7XXpnNBOYv1eil9zrblumSUOic0qDrXhY1j4awEfiw6Zswglo(hxNIG2OHL8uIfaoayrbl9yXEwExt1BARjEc2sKEvKHkxvtGSKLXI6Q1mbpDvWaUg)pyXsESeGqni0wzARjEc2sKEvKzOo)kmlaJfakl9zrbli85Cvnz(9506eMiGOjzZVNffS0Jf1vRza6kWHatuxe0gnDu9jQOb1LdYSIyjlJf7zjarqLxVbO4Z5fl9zrblVpOO38xhLEyc8iwYJf1vRzcE6QGbCn(FWIfGNfayaiSKLXIkeJzrblTd1(NgQZVcZcGzrD1AMGNUkyaxJ)hSyjlJLaebvE9M6qT)PMtSKLXI6Q1mQAieuVWVzfXIcwuxTMrvdHG6f(nd15xHzbWSOUAntWtxfmGRX)dwSamw6XcaNfGNLzvudoOit0CDWb8CDYNGxxifT0yFmumSUOicKL(S0NffSyplQRwZe80vbZkIffS0Jf7zjarqLxVPou7FQ5elzzSeGqni0wzcWcbeik97uchDZ9yZkILSmwuHymlkyPDO2)0qD(vywamlbiudcTvMaSqabIs)oLWr3Cp2muNFfMfGXcWHLSmwAhQ9pnuNFfMfKklkdqbalaMf1vRzcE6QGbCn(FWIL(wBGeomx0FWYAlFWelOjNiXoRal2UFNf0aleqGiKGu(kWHazzl6M7XS4filGWcDplqe0yBUNybGT0yFyboSyBNkwIPgcb1l8ZIn4sdYcHSOBiwuPgCiwqtorIDwbwiKfDdHT2q4tQ8oYAlaMcWc8(dwj8B9wXszazzxRnQCvnbAftRnp8hSS2ghbvWfo1gQYrCRnqchMl6pyzTLpyILFNyjgbv)E8HfB3VZIZcAYjsSZkWYV7plhUq3ZsBGDSaWwASpwBH5EAo3AtD1AMGNUkygQZVcZsESOmAzjlJf1vRzcE6QGbCn(FWIfaZsSbalkybHpNRQjtamfGf49hSs436TILYX2YUwBu5QAc0kMwBH5EAo3AdHpNRQjtamfGf49hSs4NffS0Jf7zrD1AMGNUkyaxJ)hSyjpwInayjlJf7zjarqLxVbbv)E8HL(SKLXI6Q1mJJGk4cNAdv5iUzfXIcwuxTMzCeubx4uBOkhXnd15xHzbWSaWzbySeGf46Et0qHdtjxFOQoQEZFDucHRxelaJLESyplQRwZOQHqq9c)MvelkyXEwExt1BWVpA4aAOYv1eil9T28WFWYAlqAc)NRtU(qvDu9wVvSug9TSR1gvUQMaTIP1wyUNMZT2q4Z5QAYeatbybE)bRe(T28WFWYA7QGpL)hSSERyPmATSR1gvUQMaTIP1gmYAdtV1Mh(dwwBi85CvnzTHW1lYAZEwcqOgeARmbpDvWmKdgNLSmwSNfe(CUQMmbyHaceLajC8kWIcwcqeu51BQd1(NAoXswglGZ6anfmfaXwBGeomx0FWYAlgHpNRQjwwycKfyXIRE67pcZYV7pl286z5HSOsSGDeeiln4WcAYjsSZkWcgYYV7pl)ofNfFO6zXMJFcKfKsw4NfvQbhILFN6S2q4tQ8oYAd7iOudoPGNUky9wXszGJLDT2OYv1eOvmT28WFWYARTM4jylr6vrwBGeomx0FWYAlFWeML8he9y5ASCflEXc6f0xeMyXlqw(5imlpKf9vel3ZYkIfB3VZcaBPX(GCwqtorIDwbw8cKLCc6r)HGyzZMpDwBH5EAo3AJc6lctMRsEfNffS4rPWofaIffSOUAnt0CDWb8CDYNGxxifT0yFmiC9IybWSai0haSOGLESacFJd6r)HGsyB(0La9ohfz(la0vOyjlJf7zjarqLxVPOWa1WbKL(SOGfe(CUQMmyhbLAWjf80vbwuWspwuxTMzCeubx4uBOkhXnd15xHzbWSaWzj)yPhlOLfGNLzvudoOid(Q2sN2JJFAo3qLRQjqw6ZIcwuxTMzCeubx4uBOkhXnRiwYYyXEwuxTMzCeubx4uBOkhXnRiw6B9wXszaILDT2OYv1eOvmT28WFWYAd)(0CT2AdKWH5I(dwwB5dMyj)VOFNLT3NMR1SenWaMLRXY27tZ1AwoCHUNLvK1wyUNMZT2uxTMbw0VJtr0eOO)GLzfXIcwuxTMb)(0CT2muBi8URQjR3kwkdqTSR1gvUQMaTIP1wyUNMZT2uxTMb)(OHdOzOo)kmlaMf0YIcw6XI6Q1muqFrykHHAFmd15xHzjpwqllzzSOUAndf0xeMs6v5JzOo)kml5XcAzPplkyXX)46ue0gnSKhlaCayT5H)GL1wWRaPtQRwZAtD1APY7iRn87JgoGwVvSugGBzxRnQCvnbAftRnp8hSS2WVp41GIS2ajCyUO)GL1wmE1fHzjNyaglQudoelObwiGarSSWxHILFNybnWcbeiILaSaV)GflpKLWofaILRXcAGfciqelhMfp8lxRJZIRcxplpKfvILGJFRTWCpnNBTfGiOYR3uhQ9p1CIffSGWNZv1KjaleqGOeiHJxbwuWsac1GqBLjaleqGO0VtjC0n3Jnd15xHzbWSGwwuWI9SaoRd0uWuaeZIcwOG(IWK5QKxXzrblo(hxNIG2OHL8yb9bG1Bflabal7ATrLRQjqRyAT5H)GL1g(9P5AT1giHdZf9hSS2YhmXY27tZ1AwSD)olBpP1(WsmEU2ZIxGSuqw2EF0Wbe5SyBNkwkilBVpnxRz5WSSIqolXHlw8Hy5kwSJv5dlOxqFryILgCybGcmmfWSahwEilrdmWcaBPX(WITDQyXvHiiwa4aGLCIbySahwCWi)peelyB(0XYUJzbGcmmfWSmuNF1vOyboSCywUILM(qT)gwIf8jw(D)zzvG0WYVtSG9oILaSaV)GfML7rhMfWimlfT(X1S8qw2EFAUwZc4AUcflXOocQGlml5VHQCeh5SyBNkwIdxOdKf8FAnlubYYkIfB3VZcahaaZXrS0Gdl)oXI2XplO0qvxJnwBH5EAo3A7DnvVb)Kw7tcCU2BOYv1eilkyXEwExt1BWVpA4aAOYv1eilkyrD1Ag87tZ1AZqTHW7UQMyrbl9yrD1AgkOVimL0RYhZqD(vywYJfaklkyHc6lctMRs6v5dlkyrD1AMO56Gd456KpbVUqkAPX(yq46fXcGzbqOfaSKLXI6Q1mrZ1bhWZ1jFcEDHu0sJ9XGW1lIL8uIfaHwaWIcwC8pUofbTrdl5XcahaSKLXci8noOh9hckHT5txc07CuKzOo)kml5XcaLLSmw8WFWY4GE0FiOe2MpDjqVZrrMRsn9HA)zPplkyjaHAqOTYe80vbZqD(vywYJfLbG1BflaPSLDT2OYv1eOvmT28WFWYAd)(GxdkYAdKWH5I(dwwB5dMyz79bVguel5)f97SenWaMfVazbC1fXsoXamwSTtflOjNiXoRalWHLFNyjgbv)E8Hf1vRXYHzXvHRNLhYsZ1AwGTglWHL4Wf6azj4rSKtmaZAlm3tZ5wBQRwZal63XPGM8jH4WhSmRiwYYyrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiwYYyrD1AMGNUkywrSOGLESOUAnZ4iOcUWP2qvoIBgQZVcZcGzbva005iJfGNLaDAw6XIJ)X1PiOnAybjSeBaWsFwaglXMfGNL31u9MISL6GWYqLRQjqwuWI9SmRIAWbfzWx1w60EC8tZ5gQCvnbYIcwuxTMzCeubx4uBOkhXnRiwYYyrD1AMGNUkygQZVcZcGzbva005iJfGNLaDAw6XIJ)X1PiOnAybjSeBaWsFwYYyrD1AMXrqfCHtTHQCepHVQT0P944NMZnRiwYYyPhlQRwZmocQGlCQnuLJ4MH68RWSayw8WFWYGFFA3qgczuy9u6VoIffSGJiToT74NybWSaad6ZswglQRwZmocQGlCQnuLJ4MH68RWSayw8WFWYyB8F3qiJcRNs)1rSKLXccFoxvtMlgatbybE)blwuWsac1GqBL5kCywVRQPumS86xDjqcXfiZqoyCwuWcfdRlkIanxHdZ6DvnLIHLx)QlbsiUaXsFwuWI6Q1mJJGk4cNAdv5iUzfXswgl2ZI6Q1mJJGk4cNAdv5iUzfXIcwSNLaeQbH2kZ4iOcUWP2qvoIBgYbJZswgl2ZsaIGkVEdcQ(94dl9zjlJfh)JRtrqB0WsESaWbalkyHc6lctMRsEf36TIfGaKLDT2OYv1eOvmT28WFWYAd)(GxdkYAdKWH5I(dwwB2DIZYdzPZbIy53jwuj8ZcSXY27JgoGSOgNf87bGUcfl3ZYkILyyDbG0Xz5kw8kolOxqFryIf11ZcaBPX(WYHRNfxfUEwEilQelrdmeiqRTWCpnNBT9UMQ3GFF0Wb0qLRQjqwuWI9SmRIAWbfz(RJSbNkboK3PEfingQCvnbYIcw6XI6Q1m43hnCanRiwYYyXX)46ue0gnSKhlaCaWsFwuWI6Q1m43hnCan43daXcGzj2SOGLESOUAndf0xeMsyO2hZkILSmwuxTMHc6lctj9Q8XSIyPplkyrD1AMO56Gd456KpbVUqkAPX(yq46fXcGzbqaeaWIcw6Xsac1GqBLj4PRcMH68RWSKhlkdawYYyXEwq4Z5QAYeGfciqucKWXRalkyjarqLxVPou7FQ5el9TERybOyBzxRnQCvnbAftRnyK1gMERnp8hSS2q4Z5QAYAdHRxK1gf0xeMmxL0RYhwaEwaOSGew8WFWYGFFA3qgczuy9u6VoIfGXI9Sqb9fHjZvj9Q8HfGNLESaCybyS8UMQ3GHlDc2s)oLAWHWVHkxvtGSa8SeBw6ZcsyXd)blJTX)DdHmkSEk9xhXcWybag0hTSGewWrKwN2D8tSamwaGbTSa8S8UMQ3u(VgcNuDTxbYqLRQjqRnqchMl6pyzTHE4)68NWSSdTXs3kSZsoXamw8HybLFfbYsenSGPaSaT2q4tQ8oYAZXramA2OG1BflaH(w21AJkxvtGwX0AZd)blRn87dEnOiRnqchMl6pyzTfJxDrSS9(GxdkILRyXzbGammfyzdQ9Hf0lOVimHCwaHf6Ew00ZY9SenWalaSLg7dl9(D)z5WSS7fOMazrnol0970WYVtSS9(0CTMf9velWHLFNyjNyawEaCaWI(kILgCyz79bVguuFKZciSq3Zcebn2M7jw8IL8)I(DwIgyGfVazrtpl)oXIRcrqSOVIyz3lqnXY27JgoGwBH5EAo3AZEwMvrn4GIm)1r2GtLahY7uVcKgdvUQMazrbl9yrD1AMO56Gd456KpbVUqkAPX(yq46fXcGzbqaeaWswglQRwZenxhCapxN8j41fsrln2hdcxViwamlacTaGffS8UMQ3GFsR9jbox7nu5QAcKL(SOGLESqb9fHjZvjmu7dlkyXX)46ue0gnSamwq4Z5QAY44iagnBuGfGNf1vRzOG(IWucd1(ygQZVcZcWybe(M2AINGTePxfz(laeonuNFflaplaYGwwYJfakayjlJfkOVimzUkPxLpSOGfh)JRtrqB0WcWybHpNRQjJJJay0SrbwaEwuxTMHc6lctj9Q8XmuNFfMfGXci8nT1epbBjsVkY8xaiCAOo)kwaEwaKbTSKhlaCaWsFwuWI9SOUAndSOFhNIOjqr)blZkIffSyplVRP6n43hnCanu5QAcKffS0JLaeQbH2ktWtxfmd15xHzjpwaiSKLXcgU0QxbA(9506eMiGOXqLRQjqwuWI6Q1m)(CADcteq0yWVhaIfaZsSJnl5hl9yzwf1GdkYGVQT0P944NMZnu5QAcKfGNf0YsFwuWs7qT)PH68RWSKhlkdaaWIcwAhQ9pnuNFfMfaZcGaaayPplkyPhlbiudcTvgGUcCiWeo6M7XMH68RWSKhlaewYYyXEwcqeu51Bak(CEXsFR3kwacTw21AJkxvtGwX0AZd)blRTISL6GWYAdKWH5I(dwwB5dMyj)dclmlxXIDSkFyb9c6lctS4filyhbXsmYUUbS83sRzj)dclwAWHf0KtKyNvGfVazbP8vGdbYc61fbTrthvV1wyUNMZT26XI6Q1muqFrykPxLpMH68RWSKhleYOW6P0FDelzzS0JLWUpOimlkXcGyrbldf29bfL(RJybWSGww6ZswglHDFqrywuILyZsFwuWIhLc7uaiwuWccFoxvtgSJGsn4KcE6QG1BflabCSSR1gvUQMaTIP1wyUNMZT26XI6Q1muqFrykPxLpMH68RWSKhleYOW6P0FDelkyXEwcqeu51Bak(CEXswgl9yrD1AgGUcCiWe1fbTrthvFIkAqD5GmRiwuWsaIGkVEdqXNZlw6Zswgl9yjS7dkcZIsSaiwuWYqHDFqrP)6iwamlOLL(SKLXsy3hueMfLyj2SKLXI6Q1mbpDvWSIyPplkyXJsHDkaelkybHpNRQjd2rqPgCsbpDvGffS0Jf1vRzghbvWfo1gQYrCZqD(vywaml9ybTSKFSaiwaEwMvrn4GIm4RAlDApo(P5CdvUQMazPplkyrD1AMXrqfCHtTHQCe3SIyjlJf7zrD1AMXrqfCHtTHQCe3SIyPV1Mh(dwwB7UUL6GWY6TIfGaiw21AJkxvtGwX0Alm3tZ5wB9yrD1AgkOVimL0RYhZqD(vywYJfczuy9u6VoIffSyplbicQ86nafFoVyjlJLESOUAndqxboeyI6IG2OPJQprfnOUCqMvelkyjarqLxVbO4Z5fl9zjlJLESe29bfHzrjwaelkyzOWUpOO0FDelaMf0YsFwYYyjS7dkcZIsSeBwYYyrD1AMGNUkywrS0NffS4rPWofaIffSGWNZv1Kb7iOudoPGNUkWIcw6XI6Q1mJJGk4cNAdv5iUzOo)kmlaMf0YIcwuxTMzCeubx4uBOkhXnRiwuWI9SmRIAWbfzWx1w60EC8tZ5gQCvnbYswgl2ZI6Q1mJJGk4cNAdv5iUzfXsFRnp8hSS2AlTo1bHL1BflabqTSR1gvUQMaTIP1giHdZf9hSS2YhmXcsbe9ybwSeaT28WFWYAZMpZbNeSLi9QiR3kwacGBzxRnQCvnbAftRnp8hSS2WVpTBiRnqchMl6pyzTLpyILT3N2nelpKLObgyzdQ9Hf0lOVimHCwqtorIDwbw2DmlAcJz5VoILF3lwCwqkg)3zHqgfwpXIMAplWHfyPJZIDSkFyb9c6lctSCywwrwBH5EAo3AJc6lctMRs6v5dlzzSqb9fHjdgQ9jveYEwYYyHc6lctgVINkczplzzS0Jf1vRzS5ZCWjbBjsVkYSIyjlJfCeP1PDh)elaMfayqF0YIcwSNLaebvE9geu97XhwYYybhrADA3XpXcGzbag0NffSeGiOYR3GGQFp(WsFwuWI6Q1muqFrykPxLpMvelzzS0Jf1vRzcE6QGzOo)kmlaMfp8hSm2g)3neYOW6P0FDelkyrD1AMGNUkywrS036TIvSbGLDT2OYv1eOvmT2ajCyUO)GL1w(Gjwqkg)3zb(70y7Wel22VWolhMLRyzdQ9Hf0lOVimHCwqtorIDwbwGdlpKLObgyXowLpSGEb9fHjRnp8hSS2Sn(VB9wXk2kBzxRnQCvnbAftRnqchMl6pyzTL)CT(3NL1Mh(dwwBZQsE4pyL0h(T20h(tL3rwBnxR)9zz9wV1w0qbyNQ)w21kwkBzxRnp8hSS2a6kWHat4OBUhBTrLRQjqRyA9wXcqw21AJkxvtGwX0AdgzTHP3AZd)blRne(CUQMS2q46fzTbaRnqchMl6pyzTz3DIfe(CUQMy5WSGPNLhYcayX297SuqwWV)SalwwyILFUci6XiNfLzX2ovS87elTBWplWIy5WSalwwyc5SaiwUgl)oXcMcWcKLdZIxGSeBwUglQWFNfFiRne(KkVJS2GvAHP0pxbe9wVvSITLDT2OYv1eOvmT2GrwBoiO1Mh(dwwBi85CvnzTHW1lYAtzRTWCpnNBT9ZvarV5v2S740ctj1vRXIcw(5kGO38kBcqOgeARmGRX)dwSOGf7z5NRaIEZRS5WMh2rjyl1bl8pWfofGf(Nv4pyHT2q4tQ8oYAdwPfMs)Cfq0B9wXc9TSR1gvUQMaTIP1gmYAZbbT28WFWYAdHpNRQjRneUErwBaYAlm3tZ5wB)Cfq0BEaz2DCAHPK6Q1yrbl)Cfq0BEazcqOgeARmGRX)dwSOGf7z5NRaIEZdiZHnpSJsWwQdw4FGlCkal8pRWFWcBTHWNu5DK1gSslmL(5kGO36TIfATSR1gvUQMaTIP1gmYAdtV1Mh(dwwBi85CvnzTHWNu5DK1gSslmL(5kGO3Alm3tZ5wBumSUOic0CfomR3v1ukgwE9RUeiH4celzzSqXW6IIiqd1ffFixNGdy5vGyjlJfkgwxuebAWWLwt)FfQ0SuJBTbs4WCr)blRn7UtyILFUci6XS4dXsbFw81d78)cUwhNfq6PWtGS4ywGfllmXc(9NLFUci6XgwyzJEwq4Z5QAILhYc6ZIJz53P4S4AmKLIiqwWru4Cnl7EbQVcLXAdHRxK1g6B9wXc4yzxRnp8hSS26GWcORsn40zTrLRQjqRyA9wXcGyzxRnQCvnbAftRnp8hSS2Sn(VBTfM7P5CRTESqb9fHjJEv(KkczplzzSqb9fHjZvjmu7dlzzSqb9fHjZvjv4VZswgluqFryY4v8uri7zPV1M(kkfaT2ugawV1B9wBiObFWYkwacaaszaaqaeAnkBTzZN6kuyRnKICgJgl7mwiLcCzHf7UtSCDrW5zPbhwqhmIkAqhldfdRBiqwWWoIfF9Wo)jqwc7EHIWgox74kIfabCzbnWcbnpbYc6Mvrn4GIm5l6y5HSGUzvudoOit(AOYv1ei6yPNYiRVHZ1oUIyj2axwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4C5CrkYzmASSZyHukWLfwS7oXY1fbNNLgCybDGuZx6hDSmumSUHazbd7iw81d78NazjS7fkcB4CTJRiwaoaxwqdSqqZtGSSDDOHfC86DKXcsLLhYIDSCwapeh(GflWiA8hoS0dj9zPNYiRVHZ1oUIyb4aCzbnWcbnpbYc6Mvrn4GIm5l6y5HSGUzvudoOit(AOYv1ei6yPNYiRVHZ1oUIybGaCzbnWcbnpbYc6Mvrn4GIm5l6y5HSGUzvudoOit(AOYv1ei6yPNYiRVHZ1oUIybGcCzbnWcbnpbYY21HgwWXR3rglivwEil2XYzb8qC4dwSaJOXF4WspK0NLEacz9nCU2XvelaCGllObwiO5jqwq3SkQbhuKjFrhlpKf0nRIAWbfzYxdvUQMarhl9ugz9nCU2XvelaCGllObwiO5jqwq3pxbe9gLn5l6y5HSGUFUci6nVYM8fDS0dqiRVHZ1oUIybGdCzbnWcbnpbYc6(5kGO3ait(IowEilO7NRaIEZdit(Iow6biK13W5AhxrSOmaaUSGgyHGMNazbDZQOgCqrM8fDS8qwq3SkQbhuKjFnu5QAceDS0tzK13W5AhxrSOSYaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwugqaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwuo2axwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwugTaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwug4aCzbnWcbnpbYc6Mvrn4GIm5l6y5HSGUzvudoOit(AOYv1ei6yPhGqwFdNRDCfXIYahGllObwiO5jqwq3pxbe9gLn5l6y5HSGUFUci6nVYM8fDS0dqiRVHZ1oUIyrzGdWLf0ale08eilO7NRaIEdGm5l6y5HSGUFUci6npGm5l6yPNYiRVHZ1oUIyrzacWLf0ale08eilOBwf1GdkYKVOJLhYc6Mvrn4GIm5RHkxvtGOJLEacz9nCU2XvelkdqaUSGgyHGMNazbD)Cfq0Bu2KVOJLhYc6(5kGO38kBYx0XspLrwFdNRDCfXIYaeGllObwiO5jqwq3pxbe9gazYx0XYdzbD)Cfq0BEazYx0XspaHS(goxoxKICgJgl7mwiLcCzHf7UtSCDrW5zPbhwqx0qbyNQ)OJLHIH1neilyyhXIVEyN)eilHDVqrydNRDCfXsSbUSGgyHGMNazbD)Cfq0Bu2KVOJLhYc6(5kGO38kBYx0XsVyJS(gox74kIf0h4YcAGfcAEcKf09ZvarVbqM8fDS8qwq3pxbe9MhqM8fDS0l2iRVHZLZfPiNXOXYoJfsPaxwyXU7elxxeCEwAWHf05qcDSmumSUHazbd7iw81d78NazjS7fkcB4CTJRiwug4YcAGfcAEcKf0nRIAWbfzYx0XYdzbDZQOgCqrM81qLRQjq0XI)SGE5)2bl9ugz9nCU2XvelXg4YcAGfcAEcKf0nRIAWbfzYx0XYdzbDZQOgCqrM81qLRQjq0XspLrwFdNRDCfXcab4YcAGfcAEcKLTRdnSGJxVJmwqQivwEil2XYzPdcU0lmlWiA8hoS0dP2NLEkJS(gox74kIfacWLf0ale08eilOBwf1GdkYKVOJLhYc6Mvrn4GIm5RHkxvtGOJLEacz9nCU2XvelauGllObwiO5jqw2Uo0WcoE9oYybPIuz5HSyhlNLoi4sVWSaJOXF4WspKAFw6PmY6B4CTJRiwaOaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwa4axwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwugaaxwqdSqqZtGSSDDOHfC86DKXcsLLhYIDSCwapeh(GflWiA8hoS0dj9zPhGqwFdNRDCfXIYXg4YcAGfcAEcKLTRdnSGJxVJmwqQS8qwSJLZc4H4WhSybgrJ)WHLEiPpl9ugz9nCU2XvelacaaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwaeGaUSGgyHGMNazz76qdl4417iJfKklpKf7y5SaEio8blwGr04pCyPhs6ZspLrwFdNRDCfXcGqFGllObwiO5jqw2Uo0WcoE9oYybPYYdzXowolGhIdFWIfyen(dhw6HK(S0dqiRVHZ1oUIybqOpWLf0ale08eilOBwf1GdkYKVOJLhYc6Mvrn4GIm5RHkxvtGOJLEkJS(gox74kIfabCaUSGgyHGMNazbDZQOgCqrM8fDS8qwq3SkQbhuKjFnu5QAceDS0tzK13W5AhxrSaiacWLf0ale08eilOBwf1GdkYKVOJLhYc6Mvrn4GIm5RHkxvtGOJLEkJS(gox74kIfabWbUSGgyHGMNazz76qdl4417iJfKklpKf7y5SaEio8blwGr04pCyPhs6ZspaHS(gox74kILydaGllObwiO5jqw2Uo0WcoE9oYybPYYdzXowolGhIdFWIfyen(dhw6HK(S0tzK13W5Y5IuKZy0yzNXcPuGllSy3DILRlcopln4Wc6AUw)7ZcDSmumSUHazbd7iw81d78NazjS7fkcB4CTJRiwaeWLf0ale08eilBxhAybhVEhzSGuz5HSyhlNfWdXHpyXcmIg)Hdl9qsFw6PmY6B4C5CrkYzmASSZyHukWLfwS7oXY1fbNNLgCybD4hDSmumSUHazbd7iw81d78NazjS7fkcB4CTJRiwug4YcAGfcAEcKf0nRIAWbfzYx0XYdzbDZQOgCqrM81qLRQjq0XspLrwFdNRDCfXsSbUSGgyHGMNazbDZQOgCqrM8fDS8qwq3SkQbhuKjFnu5QAceDS0tzK13W5AhxrSOSYaxwqdSqqZtGSSDDOHfC86DKXcsfPYYdzXowolDqWLEHzbgrJ)WHLEi1(S0tzK13W5AhxrSOSYaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwug4aCzbnWcbnpbYc6Mvrn4GIm5l6y5HSGUzvudoOit(AOYv1ei6yPNYiRVHZ1oUIybqkdCzbnWcbnpbYY21HgwWXR3rglivwEil2XYzb8qC4dwSaJOXF4WspK0NLEacz9nCU2XvelaszGllObwiO5jqwq3SkQbhuKjFrhlpKf0nRIAWbfzYxdvUQMarhl9ugz9nCU2XvelacqaxwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6PmY6B4CTJRiwauSbUSGgyHGMNazz76qdl4417iJfKklpKf7y5SaEio8blwGr04pCyPhs6ZsVyJS(gox74kIfaH(axwqdSqqZtGSGUzvudoOit(IowEilOBwf1GdkYKVgQCvnbIow6biK13W5AhxrSaiGdWLf0ale08eilOBwf1GdkYKVOJLhYc6Mvrn4GIm5RHkxvtGOJLEkJS(gox74kIfabqaUSGgyHGMNazbDZQOgCqrM8fDS8qwq3SkQbhuKjFnu5QAceDS0tzK13W5Y5IuKZy0yzNXcPuGllSy3DILRlcopln4Wc6uH(Jowgkgw3qGSGHDel(6HD(tGSe29cfHnCU2XvelkdqbUSGgyHGMNazz76qdl4417iJfKklpKf7y5SaEio8blwGr04pCyPhs6ZsVyJS(gox74kIfLb4axwqdSqqZtGSSDDOHfC86DKXcsLLhYIDSCwapeh(GflWiA8hoS0dj9zPNYiRVHZLZ1o7IGZtGSaqyXd)blw0h(XgoxRTOb2onzTH0inlX01EfiwIXZ6a5CrAKMLCx64SaiacYzbqaaqkZ5Y5I0inlOz3lueg4Y5I0inl5hl5eeKazzdQ9HLysENHZfPrAwYpwqZUxOiqwEFqrF6ASeCmHz5HSeIh0u69bf9ydNlsJ0SKFSeJsDqeeilRQOaHX(eNfe(CUQMWS07mKb5SeneIe(9bVguel5xESenecd(9bVguuFdNlsJ0SKFSKteWdKLOHco(VcflifJ)7SCnwUhDyw(DIfBdSqXc6f0xeMmCUinsZs(Xs(NdeXcAGfciqel)oXYw0n3JzXzrF)Rjw6GdXstti7u1el9UglXHlw2DWcDpl73ZY9SGVUL(9IGlSool2UFNLyM)Nt7YcWybnKMW)5AwYP(qvDu9iNL7rhilyGUO(goxKgPzj)yj)ZbIyPdIFwqx7qT)PH68RWOJfCGkFoiMfpkshNLhYIkeJzPDO2FmlWsh3W5I0inl5hl2Di)zXUWoIfyJLyQ9DwIP23zjMAFNfhZIZcoIcNRz5NRaIEdNlsJ0SKFSK)hrfnS07mKb5SGum(VJCwqkg)3rolBVpTBO(S05GelDWHyzi8PpQEwEilKp6JgwcWov)Zp87ZB4C5CrAKMLCwf89NazjMU2RaXsoby2blbVyrLyPbxfil(ZY()ryGlsqIQR9kq5h(6cgu3VVunhejX01EfO8B76qds6an7FNogPTttkP6AVcK5r2Z5Y56H)Gf2enua2P6VsaDf4qGjC0n3J5CrAwS7oXccFoxvtSCywW0ZYdzbaSy7(Dwkil43FwGfllmXYpxbe9yKZIYSyBNkw(DIL2n4NfyrSCywGfllmHCwaelxJLFNybtbybYYHzXlqwInlxJfv4VZIpeNRh(dwyt0qbyNQ)atjKGWNZv1eYlVJucwPfMs)Cfq0JCeUErkbaoxp8hSWMOHcWov)bMsibHpNRQjKxEhPeSslmL(5kGOh5WiLCqqKJW1lsjLr(1u6NRaIEJYMDhNwykPUAnf)Cfq0Bu2eGqni0wzaxJ)hSuy)pxbe9gLnh28WokbBPoyH)bUWPaSW)Sc)blmNRh(dwyt0qbyNQ)atjKGWNZv1eYlVJucwPfMs)Cfq0JCyKsoiiYr46fPeGq(1u6NRaIEdGm7ooTWusD1Ak(5kGO3aitac1GqBLbCn(FWsH9)Cfq0BaK5WMh2rjyl1bl8pWfofGf(Nv4pyH5CrAwS7oHjw(5kGOhZIpelf8zXxpSZ)l4ADCwaPNcpbYIJzbwSSWel43Fw(5kGOhByHLn6zbHpNRQjwEilOploMLFNIZIRXqwkIazbhrHZ1SS7fO(kugoxp8hSWMOHcWov)bMsibHpNRQjKxEhPeSslmL(5kGOh5WiLW0JCeUErkH(i)AkrXW6IIiqZv4WSExvtPyy51V6sGeIlqzzumSUOic0qDrXhY1j4awEfOSmkgwxuebAWWLwt)FfQ0SuJZ56H)Gf2enua2P6pWucjDqyb0vPgC64C9WFWcBIgka7u9hykHeBJ)7ixFfLcGkPmaq(1uQhf0xeMm6v5tQiK9zzuqFryYCvcd1(KLrb9fHjZvjv4VNLrb9fHjJxXtfHSVpNlNlsZcaBOGJFwaelifJ)7S4filolBVp41GIybwSSzxwSD)olX6qT)SK)CIfVazjMWCAxwGdlBVpTBiwG)on2omX56H)Gf2aJOIgGPesSn(VJ8RPupkOVimz0RYNuri7ZYOG(IWK5QegQ9jlJc6lctMRsQWFplJc6lctgVINkczFFfrdHWOSX24)Uc7JgcHbqgBJ)7CUE4pyHnWiQObykHe87t7gc56ROuauj0I8RPK9ZQOgCqrgvx7vGsWwY160VFfkCwM9bicQ86n1HA)tnNYYShhrAD69bf9yd(9P5ATskNLz)7AQEt5)AiCs11EfidvUQMaZY6rb9fHjdgQ9jveY(SmkOVimzUkPxLpzzuqFryYCvsf(7zzuqFryY4v8uri77Z56H)Gf2aJOIgGPesWVp41GIqU(kkfavcTi)AknRIAWbfzuDTxbkbBjxRt)(vOWkcqeu51BQd1(NAoPahrAD69bf9yd(9P5ATskZ5Y5I0inlOhYOW6jqwie0eNL)6iw(DIfp8WHLdZIJWpTRQjdNRh(dwyLWqTpjvY74C9WFWcdmLqsW16Kh(dwj9HFKxEhPemIkAq(1u6VocW9aeW7H)GLX24)Uj44p9xhbmp8hSm43N2nKj44p9xh1NZfPzzJEml5eIESalwInWyX297W1Zc4CTNfVazX297SS9(OHdilEbYcGaglWFNgBhM4C9WFWcdmLqccFoxvtiV8osPdNCiHCeUErkHJiTo9(GIESb)(0CTopLv0Z(31u9g87JgoGgQCvnbML9UMQ3GFsR9jbox7nu5QAcSFwgoI0607dk6Xg87tZ168aeNlsZYg9ywcAYrqSyBNkw2EFA3qSe8IL97zbqaJL3hu0JzX2(f2z5WSmKMq41ZsdoS87elOxqFryILhYIkXs0qnAgcKfVazX2(f2zPDAnnS8qwco(5C9WFWcdmLqccFoxvtiV8osPdNcAYrqihHRxKs4isRtVpOOhBWVpTBO8uMZfPzjgHpNRQjw(D)zjStbGWSCnwIdxS4dXYvS4SGkaYYdzXrapqw(DIf89l)pyXITDAiwCw(5kGONf6dSCywwycKLRyrLEBevSeC8J5C9WFWcdmLqccFoxvtiV8osPRsOcGihHRxKsrdHW0bHv7gkllAieg8QA3qzzrdHWGFFWRbfLLfnecd(9P5ADww0qimT1epbBjsVkkltD1AMGNUkygQZVcRK6Q1mbpDvWaUg)pyX5I0SKpyILysdMgGUcfl2UFNf0KtKyNvGf4WI3EAybnWcbeiILRybn5ej2zf4C9WFWcdmLqIknyAa6kui)Ak1RN9bicQ86n1HA)tnNYYSpaHAqOTYeGfciqu63Peo6M7XMvuFfQRwZe80vbZqD(v48ugTkuxTMzCeubx4uBOkhXnd15xHbm6RW(aebvE9geu97XNSSaebvE9geu97XhfQRwZe80vbZksH6Q1mJJGk4cNAdv5iUzfPON6Q1mJJGk4cNAdv5iUzOo)kmGvw58dTa)SkQbhuKbFvBPt7XXpnNNLPUAntWtxfmd15xHbSYkNLPmsfhrADA3XpbyLnOfT97RaHpNRQjZvjubqoxKMfag8zX297S4SGMCIe7ScS87(ZYHl09S4SaWwASpSenWalWHfB7uXYVtS0ou7plhMfxfUEwEilubY56H)GfgykHKi4FWc5xtj1vRzcE6QGzOo)kCEkJwf9SFwf1GdkYGVQT0P944NMZZYuxTMzCeubx4uBOkhXnd15xHbSYaK8dqaV6Q1mQAieuVWVzfPqD1AMXrqfCHtTHQCe3SI6NLPcXyfTd1(NgQZVcdyaHwoxKMf046Ws7pHzX2o970WYcFfkwqdSqabIyPG2yX2P1S4An0glXHlwEil4)0Awco(z53jwWEhXI3bx1ZcSXcAGfciqeWqtorIDwbwco(XCUE4pyHbMsibHpNRQjKxEhPuawiGarjqchVcihHRxKsb60961ou7FAOo)kC(PmAZVaeQbH2ktWtxfmd15xH7JuvgGcG(kfOt3Rx7qT)PH68RW5NYOn)cqOgeARmbyHaceL(DkHJU5ESbCn(FWk)cqOgeARmbyHaceL(DkHJU5ESzOo)kCFKQYaua0xH9JFGjcbvVXbbXgczh(XzzbiudcTvMGNUkygQZVcN3vpnrqT)eyQDO2)0qD(v4SSaeQbH2ktawiGarPFNs4OBUhBgQZVcN3vpnrqT)eyQDO2)0qD(v48tzaKLzFaIGkVEtDO2)uZjoxKML8btGS8qwajThNLFNyzHDuelWglOjNiXoRal22PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyBNkw8IfheKfcbvplhMfxfUEwEilGhX56H)GfgykHee(CUQMqE5DKsbWuawG3FWc5iC9IuQx7qT)PH68RW5PmAZYg)atecQEJdcInxLhAbqFf961JIH1ffrGgQlk(qUobhWYRaPOxac1GqBLH6IIpKRtWbS8kqMH68RWawzGdaYYcqeu51Bqq1VhFueGqni0wzOUO4d56eCalVcKzOo)kmGvg4aqawpLvg4Nvrn4GIm4RAlDApo(P58(9vyFac1GqBLH6IIpKRtWbS8kqMHCW49ZYOyyDrreObdxAn9)vOsZsnUIE2hGiOYR3uhQ9p1CkllaHAqOTYGHlTM()kuPzPgpfB0hTauaOSzOo)kmGvwz0VFwwVaeQbH2kJknyAa6kuMHCW4zz2pEGm)a16(k61JIH1ffrGMRWHz9UQMsXWYRF1LajexGu0laHAqOTYCfomR3v1ukgwE9RUeiH4cKzihmEwMh(dwMRWHz9UQMsXWYRF1LajexGmGh2v1ey)(zz9OyyDrreObV7GqBeycoQjyl9WPJQxrac1GqBL5HthvpbMUcFO2)uSrlAJnGu2muNFfUFwwVEi85CvnzGvAHP0pxbe9kPCwgcFoxvtgyLwyk9ZvarVsXUVIE)Cfq0Bu2mKdgpfGqni0wLL9ZvarVrztac1GqBLzOo)kCEx90eb1(tGP2HA)td15xHZpLbq)Sme(CUQMmWkTWu6NRaIELaKIE)Cfq0BaKzihmEkaHAqOTkl7NRaIEdGmbiudcTvMH68RW5D1tteu7pbMAhQ9pnuNFfo)uga9ZYq4Z5QAYaR0ctPFUci6vca973pllarqLxVbO4Z5v)SmvigRODO2)0qD(vyaRUAntWtxfmGRX)dwCUinlXi85CvnXYctGS8qwajThNfVIZYpxbe9yw8cKLaiMfB7uXIn)(RqXsdoS4flO3kAhoNZs0adCUE4pyHbMsibHpNRQjKxEhP0VpNwNWebenjB(9ihHRxKs2JHlT6vGMFFoToHjciAmu5QAcmlRDO2)0qD(v48aeaaqwMkeJv0ou7FAOo)kmGbeAbwp0ha5N6Q1m)(CADcteq0yWVhac4bu)Sm1vRz(9506eMiGOXGFpauEXgGMF9Mvrn4GIm4RAlDApo(P5CGhT95CrAwYhmXc61ffFixZs()awEfiwaeaWuaZIk1GdXIZcAYjsSZkWYctgoxp8hSWatjKSWu6EQd5L3rkrDrXhY1j4awEfiKFnLcqOgeARmbpDvWmuNFfgWacakcqOgeARmbyHaceL(DkHJU5ESzOo)kmGbeau0dHpNRQjZVpNwNWebenjB(9zzQRwZ87ZP1jmrarJb)EaO8InaawVzvudoOid(Q2sN2JJFAoh4bo97RaHpNRQjZvjubWSmvigRODO2)0qD(vyahBacNlsZs(Gjw2GlTM(RqXsm6snolahmfWSOsn4qS4SGMCIe7ScSSWKHZ1d)blmWucjlmLUN6qE5DKsy4sRP)VcvAwQXr(1uQxac1GqBLj4PRcMH68RWag4OW(aebvE9geu97Xhf2hGiOYR3uhQ9p1CkllarqLxVPou7FQ5KIaeQbH2ktawiGarPFNs4OBUhBgQZVcdyGJIEi85CvnzcWcbeikbs44villaHAqOTYe80vbZqD(vyadC6NLfGiOYR3GGQFp(OON9ZQOgCqrg8vTLoThh)0CUIaeQbH2ktWtxfmd15xHbmWjltD1AMXrqfCHtTHQCe3muNFfgWkJ(aRhAbEkgwxuebAUc)Zk8WbNapexrjvsR7RqD1AMXrqfCHtTHQCe3SI6NLPcXyfTd1(NgQZVcdyaH2SmkgwxuebAOUO4d56eCalVcKIaeQbH2kd1ffFixNGdy5vGmd15xHZl2aOVce(CUQMmxLqfa5CrAwYP2MhhZYctSyNXijgZIT73zbn5ej2zf4C9WFWcdmLqccFoxvtiV8osPlgatbybE)blKJW1lsj1vRzcE6QGzOo)kCEkJwf9SFwf1GdkYGVQT0P944NMZZYuxTMzCeubx4uBOkhXnd15xHbSskdiG1l2aV6Q1mQAieuVWVzf1hy96bqZp0c8QRwZOQHqq9c)MvuFGNIH1ffrGMRW)ScpCWjWdXvusL06(kuxTMzCeubx4uBOkhXnRO(zzQqmwr7qT)PH68RWagqOnlJIH1ffrGgQlk(qUobhWYRaPiaHAqOTYqDrXhY1j4awEfiZqD(vyoxp8hSWatjKSWu6EQd5L3rkDfomR3v1ukgwE9RUeiH4ceYVMsi85CvnzUyamfGf49hSuGWNZv1K5QeQaiNlsZs(GjwMd1(ZIk1GdXsaeZ56H)GfgykHKfMs3tDiV8osj8UdcTrGj4OMGT0dNoQEKFnL6fGqni0wzcE6QGzihmUc7dqeu51BQd1(NAoPaHpNRQjZVpNwNWebenjB(9zzbicQ86n1HA)tnNueGqni0wzcWcbeik97uchDZ9yZqoyCf9q4Z5QAYeGfciqucKWXRqwwac1GqBLj4PRcMHCW497Rae(g8QA3qM)caDfkf9aHVb)Kw7tQP9Hm)fa6kuzz2)UMQ3GFsR9j10(qgQCvnbMLHJiTo9(GIESb)(0UHYl29v0de(MoiSA3qM)caDfQ(k6HWNZv1K5WjhszzZQOgCqrgvx7vGsWwY160VFfkCwMJ)X1PiOnAYtjaoaYYuxTMrvdHG6f(nRO(k6fGqni0wzuPbtdqxHYmKdgplZ(XdK5hOw3pltfIXkAhQ9pnuNFfgWOpa4CrAwS7(Hz5WS4Sm(VtdlK2vHJ)el284S8qw6CGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSD)olOjNiXoRalEbYcAGfciqelEbYYctS87elaQazbRHplWILailxJfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhZ56H)GfgykHKfMs3tDyKJ1WhR0pxbe9kJ8RPupe(CUQMmWkTWu6NRaIE7vszf2)ZvarVbqMHCW4PaeQbH2QSSEi85CvnzGvAHP0pxbe9kPCwgcFoxvtgyLwyk9ZvarVsXUVIEQRwZe80vbZksrp7dqeu51Bqq1VhFYYuxTMzCeubx4uBOkhXnd15xHbwp0c8ZQOgCqrg8vTLoThh)0CEFaR0pxbe9gLnQRwlbUg)pyPqD1AMXrqfCHtTHQCe3SIYYuxTMzCeubx4uBOkhXt4RAlDApo(P5CZkQFwwac1GqBLj4PRcMH68RWadq59ZvarVrztac1GqBLbCn(FWsH9QRwZe80vbZksrp7dqeu51BQd1(NAoLLzpcFoxvtMaSqabIsGeoEf6RW(aebvE9gGIpNxzzbicQ86n1HA)tnNuGWNZv1KjaleqGOeiHJxbfbiudcTvMaSqabIs)oLWr3Cp2SIuyFac1GqBLj4PRcMvKIE9uxTMHc6lctj9Q8XmuNFfopLbqwM6Q1muqFrykHHAFmd15xHZtza0xH9ZQOgCqrgvx7vGsWwY160VFfkCwwp1vRzuDTxbkbBjxRt)(vOWPY)1qg87bGucTzzQRwZO6AVcuc2sUwN(9RqHt(e8Im43daPeaTF)Sm1vRza6kWHatuxe0gnDu9jQOb1LdYSI6NL1ou7FAOo)kmGbeaYYq4Z5QAYaR0ctPFUci6vca9vGWNZv1K5QeQaiNRh(dwyGPeswykDp1HrowdFSs)Cfq0diKFnL6HWNZv1KbwPfMs)Cfq0BVsasH9)Cfq0Bu2mKdgpfGqni0wLLHWNZv1KbwPfMs)Cfq0ReGu0tD1AMGNUkywrk6zFaIGkVEdcQ(94twM6Q1mJJGk4cNAdv5iUzOo)kmW6HwGFwf1GdkYGVQT0P944NMZ7dyL(5kGO3aiJ6Q1sGRX)dwkuxTMzCeubx4uBOkhXnROSm1vRzghbvWfo1gQYr8e(Q2sN2JJFAo3SI6NLfGqni0wzcE6QGzOo)kmWauE)Cfq0BaKjaHAqOTYaUg)pyPWE1vRzcE6QGzfPON9bicQ86n1HA)tnNYYShHpNRQjtawiGarjqchVc9vyFaIGkVEdqXNZlf9SxD1AMGNUkywrzz2hGiOYR3GGQFp(0pllarqLxVPou7FQ5Kce(CUQMmbyHaceLajC8kOiaHAqOTYeGfciqu63Peo6M7XMvKc7dqOgeARmbpDvWSIu0RN6Q1muqFrykPxLpMH68RW5PmaYYuxTMHc6lctjmu7JzOo)kCEkdG(kSFwf1GdkYO6AVcuc2sUwN(9RqHZY6PUAnJQR9kqjyl5AD63Vcfov(VgYGFpaKsOnltD1Agvx7vGsWwY160VFfkCYNGxKb)EaiLaO973pltD1AgGUcCiWe1fbTrthvFIkAqD5GmROSmvigRODO2)0qD(vyadiaKLHWNZv1KbwPfMs)Cfq0Rea6RaHpNRQjZvjubqoxKML8btywCTMf4VtdlWILfMy5EQdZcSyjaY56H)GfgykHKfMs3tDyoxKMLymfoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdZ56H)GfgykHKzvjp8hSs6d)iV8osjhsih)ZfELug5xtje(CUQMmho5qIZ1d)blmWucjZQsE4pyL0h(rE5DKsQq)ro(Nl8kPmYVMsZQOgCqrgvx7vGsWwY160VFfkSHIH1ffrGCUE4pyHbMsizwvYd)bRK(WpYlVJuc)CUCUinlOX1HL2FcZITD63PHLFNyjgpK3f8pStdlQRwJfBNwZsZ1AwGTgl2UF)kw(DILIq2ZsWXpNRh(dwyJdjLq4Z5QAc5L3rkboK3LSDADQ5ADc2AihHRxKs9uxTM5VoYgCQe4qEN6vG0ygQZVcdyubqtNJmGbaJYzzQRwZ8xhzdovcCiVt9kqAmd15xHbSh(dwg87t7gYqiJcRNs)1radagLv0Jc6lctMRs6v5twgf0xeMmyO2Nuri7ZYOG(IWKXR4PIq23VVc1vRz(RJSbNkboK3PEfinMvKIzvudoOiZFDKn4ujWH8o1RaPHZfPzbnUoS0(tywSTt)onSS9(GxdkILdZIn487SeC8FfkwGiOHLT3N2nelxXIDSkFyb9c6lctCUE4pyHnoKaMsibHpNRQjKxEhP0HQGdLWVp41GIqocxViLSNc6lctMRsyO2hf9WrKwNEFqrp2GFFA3q5HwfVRP6ny4sNGT0VtPgCi8BOYv1eywgoI0607dk6Xg87t7gkpasFoxKML8btSGgyHaceXITDQyXFw0egZYV7flOfaSKtmaJfVazrFfXYkIfB3VZcAYjsSZkW56H)Gf24qcykHKaSqabIs)oLWr3Cpg5xtj7bN1bAkykaIv0RhcFoxvtMaSqabIsGeoEfuyFac1GqBLj4PRcMHCW4zzQRwZe80vbZkQVIEQRwZqb9fHPKEv(ygQZVcNhWjltD1AgkOVimLWqTpMH68RW5bC6RON9ZQOgCqrgvx7vGsWwY160VFfkCwM6Q1mQU2RaLGTKR1PF)ku4u5)Aid(9aq5f7Sm1vRzuDTxbkbBjxRt)(vOWjFcErg87bGYl29ZYuHySI2HA)td15xHbSYaqH9biudcTvMGNUkygYbJ3NZfPzjFWel5VHQCeNfB3VZcAYjsSZkW56H)Gf24qcykHKXrqfCHtTHQCeh5xtj1vRzcE6QGzOo)kCEkJwoxKML8btSSTQ2nelxXsKxGu3fybwS4v8F)kuS87(ZI(qqywug9XuaZIxGSOjmMfB3VZshCiwEFqrpMfVazXFw(DIfQazb2yXzzdQ9Hf0lOVimXI)SOm6ZcMcywGdlAcJzzOo)QRqXIJz5HSuWNLDhXvOy5HSmuBi8olGR5kuSyhRYhwqVG(IWeNRh(dwyJdjGPesWRQDdH8q8GMsVpOOhRKYi)Ak1BO2q4DxvtzzQRwZqb9fHPegQ9XmuNFfgWXwbf0xeMmxLWqTpkgQZVcdyLrFfVRP6ny4sNGT0VtPgCi8BOYv1eyFfVpOO38xhLEyc8O8ug9ZpCeP1P3hu0Jb2qD(vyf9OG(IWK5QKxXZYgQZVcdyubqtNJS(CUinl5dMyzBvTBiwEil7ocIfNfuAOQRz5HSSWel2zmsIXCUE4pyHnoKaMsibVQ2neYVMsi85CvnzUyamfGf49hSueGqni0wzUchM17QAkfdlV(vxcKqCbYmKdgxbfdRlkIanxHdZ6DvnLIHLx)QlbsiUaX56H)Gf24qcykHe87tZ1AKFnLS)DnvVb)Kw7tcCU2BOYv1eOIEQRwZGFFAUwBgQneE3v1KIE4isRtVpOOhBWVpnxRbCSZYSFwf1GdkY8xhzdovcCiVt9kqA6NL9UMQ3GHlDc2s)oLAWHWVHkxvtGkuxTMHc6lctjmu7JzOo)kmGJTckOVimzUkHHAFuOUAnd(9P5ATzOo)kmGbikWrKwNEFqrp2GFFAUwNNsOFFf9SFwf1GdkYOJh8XXPMMO)kuju6Rlctzz)1rivKk6J28uxTMb)(0CT2muNFfgyaQVI3hu0B(RJspmbEuEOLZfPzbP4(Dw2EsR9HLy8CTNLfMybwSeazX2ovSmuBi8URQjwuxpl4)0AwS53ZsdoSyhXd(4ywIgyGfVazbewO7zzHjwuPgCiwqtmgByz7pTMLfMyrLAWHybnWcbeiIf8vbILF3FwSDAnlrdmWIxWFNgw2EFAUwZ56H)Gf24qcykHe87tZ1AKFnLExt1BWpP1(KaNR9gQCvnbQqD1Ag87tZ1AZqTHW7UQMu0Z(zvudoOiJoEWhhNAAI(RqLqPVUimLL9xhHurQOpAZd97R49bf9M)6O0dtGhLxS5CrAwqkUFNLy8qEN6vG0WYctSS9(0CTMLhYcqefXYkILFNyrD1ASOgNfxJHSSWxHILT3NMR1SalwqllykalqmlWHfnHXSmuNF1vO4C9WFWcBCibmLqc(9P5AnYVMsZQOgCqrM)6iBWPsGd5DQxbsJcCeP1P3hu0Jn43NMR15PuSv0ZE1vRz(RJSbNkboK3PEfinMvKc1vRzWVpnxRnd1gcV7QAklRhcFoxvtgWH8UKTtRtnxRtWwtrp1vRzWVpnxRnd15xHbCSZYWrKwNEFqrp2GFFAUwNhGu8UMQ3GFsR9jbox7nu5QAcuH6Q1m43NMR1MH68RWagT973NZfPzbnUoS0(tywSTt)onS4SS9(GxdkILfMyX2P1Se8fMyz79P5AnlpKLMR1SaBnKZIxGSSWelBVp41GIy5HSaerrSeJhY7uVcKgwWVhaILveNRh(dwyJdjGPesq4Z5QAc5L3rkHFFAUwNSbRp1CTobBnKJW1lsjh)JRtrqB0Khafa5xpLbaWRUAnZFDKn4ujWH8o1RaPXGFpau)8RN6Q1m43NMR1MH68RWaFSrQ4isRt7o(jG3(31u9g8tATpjW5AVHkxvtG9ZVEbiudcTvg87tZ1AZqD(vyGp2ivCeP1PDh)eW)UMQ3GFsR9jbox7nu5QAcSF(1de(M2AINGTePxfzgQZVcd8OTVIEQRwZGFFAUwBwrzzbiudcTvg87tZ1AZqD(v4(CUinl5dMyz79bVguel2UFNLy8qEN6vG0WYdzbiIIyzfXYVtSOUAnwSD)oC9SOH4RqXY27tZ1Awwr)1rS4fillmXY27dEnOiwGflOpWyjMWCAxwWVhacZYQ(tZc6ZY7dk6XCUE4pyHnoKaMsib)(Gxdkc5xtje(CUQMmGd5DjBNwNAUwNGTMce(CUQMm43NMR1jBW6tnxRtWwtH9i85CvnzoufCOe(9bVguuwwp1vRzuDTxbkbBjxRt)(vOWPY)1qg87bGYl2zzQRwZO6AVcuc2sUwN(9RqHt(e8Im43daLxS7RahrAD69bf9yd(9P5AnGrFfi85CvnzWVpnxRt2G1NAUwNGTgNlsZs(GjwW28PJfmKLF3FwIdxSGIEw6CKXYk6VoIf14SSWxHIL7zXXSO9NyXXSebX4tvtSalw0egZYV7flXMf87bGWSahwqkzHFwSTtflXgySGFpaeMfczr3qCUE4pyHnoKaMsiXb9O)qqjSnF6qEiEqtP3hu0JvszKFnLS)VaqxHsH9E4pyzCqp6peucBZNUeO35OiZvPM(qT)zzGW34GE0FiOe2MpDjqVZrrg87bGaCSvacFJd6r)HGsyB(0La9ohfzgQZVcd4yZ5I0SeJsTHW7SK)bHv7gILRXcAYjsSZkWYHzzihmoYz53PHyXhIfnHXS87EXcAz59bf9ywUIf7yv(Wc6f0xeMyX297SSb)8hYzrtyml)UxSOmayb(70y7WelxXIxXzb9c6lctSahwwrS8qwqllVpOOhZIk1GdXIZIDSkFyb9c6lctgwIXWcDpld1gcVZc4AUcfliLVcCiqwqVUiOnA6O6zzvAcJz5kw2GAFyb9c6lctCUE4pyHnoKaMsiPdcR2neYdXdAk9(GIESskJ8RP0qTHW7UQMu8(GIEZFDu6HjWJYRxpLrFG1dhrAD69bf9yd(9PDdb8ac4vxTMHc6lctj9Q8XSI63hyd15xH7Ju7PmWExt1BEBxL6GWcBOYv1eyFf9cqOgeARmbpDvWmKdgxH9GZ6anfmfaXk6HWNZv1KjaleqGOeiHJxHSSaeQbH2ktawiGarPFNs4OBUhBgYbJNLzFaIGkVEtDO2)uZP(zz4isRtVpOOhBWVpTBia3RhWj)6PUAndf0xeMs6v5Jzfb8aQFFGVNYa7DnvV5TDvQdclSHkxvtG97RWEkOVimzWqTpPIq2NL1Jc6lctMRsyO2NSSEuqFryYCvsf(7zzuqFryYCvsVkF6RW(31u9gmCPtWw63Pudoe(nu5QAcmltD1AMO56Gd456KpbVUqkAPX(yq46fLNsacTaOVIE4isRtVpOOhBWVpTBiaRmaa(EkdS31u9M32vPoiSWgQCvnb2VVch)JRtrqB0KhAbq(PUAnd(9P5ATzOo)kmWdC6RON9QRwZa0vGdbMOUiOnA6O6turdQlhKzfLLrb9fHjZvjmu7twM9bicQ86nafFoV6RWE1vRzghbvWfo1gQYr8e(Q2sN2JJFAo3SI4CrAwYhmXs(dglwGflbqwSD)oC9Se8OORqX56H)Gf24qcykHKgCcuc2sL)RHq(1uYJsHDkaeNRh(dwyJdjGPesq4Z5QAc5L3rkfatbybE)bRKdjKJW1lsj7bN1bAkykaIvGWNZv1KjaMcWc8(dwk61tD1Ag87tZ1AZkkl7DnvVb)Kw7tcCU2BOYv1eywwaIGkVEtDO2)uZP(k6zV6Q1myOg)xGmRif2RUAntWtxfmRif9S)DnvVPTM4jylr6vrgQCvnbMLPUAntWtxfmGRX)dw5fGqni0wzARjEc2sKEvKzOo)kmWaO9vGWNZv1K53NtRtyIaIMKn)Ef9SparqLxVPou7FQ5uwwac1GqBLjaleqGO0VtjC0n3JnRif9uxTMb)(0CT2muNFfgWaklZ(31u9g8tATpjW5AVHkxvtG97R49bf9M)6O0dtGhLN6Q1mbpDvWaUg)pyb8aWaq6NLPcXyfTd1(NgQZVcdy1vRzcE6QGbCn(FWQpNlsZs(GjwqtorIDwbwGflbqwwLMWyw8cKf9vel3ZYkIfB3VZcAGfciqeNRh(dwyJdjGPescKMW)56KRpuvhvpYVMsi85CvnzcGPaSaV)GvYHeNRh(dwyJdjGPesUk4t5)blKFnLq4Z5QAYeatbybE)bRKdjoxKML8btSGEDrqB0WsmHfilWILail2UFNLT3NMR1SSIyXlqwWocILgCybGT0yFyXlqwqtorIDwboxp8hSWghsatjKqDrqB0KuHfiYVMsx90eb1(tGP2HA)td15xHbSYOnlRN6Q1mrZ1bhWZ1jFcEDHu0sJ9XGW1lcWacTailtD1AMO56Gd456KpbVUqkAPX(yq46fLNsacTaOVc1vRzWVpnxRnRif9cqOgeARmbpDvWmuNFfop0cGSmWzDGMcMcG4(CUinlXOuBi8olnTpelWILvelpKLyZY7dk6XSy7(D46zbn5ej2zfyrLUcflUkC9S8qwiKfDdXIxGSuWNficAcEu0vO4C9WFWcBCibmLqc(jT2Nut7dH8q8GMsVpOOhRKYi)AknuBi8URQjf)1rPhMapkpLrRcCeP1P3hu0Jn43N2neGrFfEukStbGu0tD1AMGNUkygQZVcNNYailZE1vRzcE6QGzf1NZfPzjFWel5pi6XY1y5k8bsS4flOxqFryIfVazrFfXY9SSIyX297S4SaWwASpSenWalEbYsob9O)qqSSzZNooxp8hSWghsatjK0wt8eSLi9QiKFnLOG(IWK5QKxXv4rPWofasH6Q1mrZ1bhWZ1jFcEDHu0sJ9XGW1lcWacTaqrpq4BCqp6peucBZNUeO35OiZFbGUcvwM9bicQ86nffgOgoGzz4isRtVpOOhNhG6RON6Q1mJJGk4cNAdv5iUzOo)kmGb45xp0c8ZQOgCqrg8vTLoThh)0CEFfQRwZmocQGlCQnuLJ4MvuwM9QRwZmocQGlCQnuLJ4MvuFf9SpaHAqOTYe80vbZkkltD1AMFFoToHjciAm43dabyLrRI2HA)td15xHbmGaaau0ou7FAOo)kCEkdaaKLzpgU0QxbA(9506eMiGOXqLRQjW(k6HHlT6vGMFFoToHjciAmu5QAcmllaHAqOTYe80vbZqD(v48Ina6Z5I0SKpyIfNLT3NMR1SK)x0VZs0adSSknHXSS9(0CTMLdZIRhYbJZYkIf4WsC4IfFiwCv46z5HSarqtWJyjNyagNRh(dwyJdjGPesWVpnxRr(1usD1Agyr)oofrtGI(dwMvKIEQRwZGFFAUwBgQneE3v1uwMJ)X1PiOnAYdGdG(CUinlX4vxel5edWyrLAWHybnWcbeiIfB3VZY27tZ1Aw8cKLFNkw2EFWRbfX56H)Gf24qcykHe87tZ1AKFnLcqeu51BQd1(NAoPW(31u9g8tATpjW5AVHkxvtGk6HWNZv1KjaleqGOeiHJxHSSaeQbH2ktWtxfmROSm1vRzcE6QGzf1xrac1GqBLjaleqGO0VtjC0n3Jnd15xHbmQaOPZrgWhOt3ZX)46ue0gniv0cG(kuxTMb)(0CT2muNFfgWOVc7bN1bAkykaI5C9WFWcBCibmLqc(9bVgueYVMsbicQ86n1HA)tnNu0dHpNRQjtawiGarjqchVczzbiudcTvMGNUkywrzzQRwZe80vbZkQVIaeQbH2ktawiGarPFNs4OBUhBgQZVcdyGJc1vRzWVpnxRnRifuqFryYCvYR4kShHpNRQjZHQGdLWVp41GIuyp4SoqtbtbqmNlsZs(Gjw2EFWRbfXIT73zXlwY)l63zjAGbwGdlxJL4Wf6azbIGMGhXsoXamwSD)olXHRHLIq2ZsWXVHLCQXqwaxDrSKtmaJf)z53jwOcKfyJLFNyjgbv)E8Hf1vRXY1yz79P5Anl2GlnyHUNLMR1SaBnwGdlXHlw8HybwSaiwEFqrpMZ1d)blSXHeWucj43h8Aqri)AkPUAndSOFhNcAYNeIdFWYSIYY6zp(9PDdz8OuyNcaPWEe(CUQMmhQcouc)(GxdkklRN6Q1mbpDvWmuNFfgWOvH6Q1mbpDvWSIYY61tD1AMGNUkygQZVcdyubqtNJmGpqNUNJ)X1PiOnAqQXga9vOUAntWtxfmROSm1vRzghbvWfo1gQYr8e(Q2sN2JJFAo3muNFfgWOcGMohzaFGoDph)JRtrqB0GuJna6RqD1AMXrqfCHtTHQCepHVQT0P944NMZnRO(kcqeu51Bqq1VhF63xrpCeP1P3hu0Jn43NMR1ao2zzi85CvnzWVpnxRt2G1NAUwNGTw)(kShHpNRQjZHQGdLWVp41GIu0Z(zvudoOiZFDKn4ujWH8o1RaPjldhrAD69bf9yd(9P5AnGJDFoxKML8btSK)bHfMLRyzdQ9Hf0lOVimXIxGSGDeel5VLwZs(hewS0GdlOjNiXoRaNRh(dwyJdjGPeskYwQdclKFnL6PUAndf0xeMsyO2hZqD(v48iKrH1tP)6OSSEHDFqryLaKIHc7(GIs)1ragT9ZYc7(GIWkf7(k8OuyNcaX56H)Gf24qcykHKDx3sDqyH8RPup1vRzOG(IWucd1(ygQZVcNhHmkSEk9xhLL1lS7dkcReGumuy3huu6VocWOTFwwy3huewPy3xHhLc7uaif9uxTMzCeubx4uBOkhXnd15xHbmAvOUAnZ4iOcUWP2qvoIBwrkSFwf1GdkYGVQT0P944NMZZYSxD1AMXrqfCHtTHQCe3SI6Z56H)Gf24qcykHK2sRtDqyH8RPup1vRzOG(IWucd1(ygQZVcNhHmkSEk9xhPOxac1GqBLj4PRcMH68RW5HwaKLfGqni0wzcWcbeik97uchDZ9yZqD(v48qla6NL1lS7dkcReGumuy3huu6VocWOTFwwy3huewPy3xHhLc7uaif9uxTMzCeubx4uBOkhXnd15xHbmAvOUAnZ4iOcUWP2qvoIBwrkSFwf1GdkYGVQT0P944NMZZYSxD1AMXrqfCHtTHQCe3SI6Z5I0SKpyIfKci6XcSybnXyoxp8hSWghsatjKyZN5Gtc2sKEveNlsZcACDyP9NWSyBN(DAy5HSSWelBVpTBiwUILnO2hwSTFHDwoml(ZcAz59bf9yGPmln4WcHGM4SaiaGuzPZXpnXzboSG(SS9(GxdkIf0RlcAJMoQEwWVhacZ56H)Gf24qcykHee(CUQMqE5DKs43N2nu6QegQ9b5iC9IuchrAD69bf9yd(9PDdLh6dSMgcNEDo(PjEcHRxeWRmaaasfqaOpWAAiC6PUAnd(9bVguuI6IG2OPJQpHHAFm43daHur)(CUinlOX1HL2FcZITD63PHLhYcsX4)olGR5kuSK)gQYrCoxp8hSWghsatjKGWNZv1eYlVJuY24)E6QuBOkhXrocxViLugPIJiToT74NamGYVEaWaiGVhoI0607dk6Xg87t7gk)uUpW3tzG9UMQ3GHlDc2s)oLAWHWVHkxvtGaVYg02VpWaGrz0c8QRwZmocQGlCQnuLJ4MH68RWCUinl5dMybPy8FNLRyzdQ9Hf0lOVimXcCy5ASuqw2EFA3qSy70AwA3ZYvpKf0KtKyNvGfVI3bhIZ1d)blSXHeWucj2g)3r(1uQhf0xeMm6v5tQiK9zzuqFryY4v8uri7vGWNZv1K5WPGMCeuFf9EFqrV5Vok9We4r5H(zzuqFryYOxLpPRsaklRDO2)0qD(vyaRma6NLPUAndf0xeMsyO2hZqD(vya7H)GLb)(0UHmeYOW6P0FDKc1vRzOG(IWucd1(ywrzzuqFryYCvcd1(OWEe(CUQMm43N2nu6QegQ9jltD1AMGNUkygQZVcdyp8hSm43N2nKHqgfwpL(RJuypcFoxvtMdNcAYrqkuxTMj4PRcMH68RWaMqgfwpL(RJuOUAntWtxfmROSm1vRzghbvWfo1gQYrCZksbcFoxvtgBJ)7PRsTHQCeplZEe(CUQMmhof0KJGuOUAntWtxfmd15xHZJqgfwpL(RJ4CrAwYhmXY27t7gILRXYvSyhRYhwqVG(IWeYz5kw2GAFyb9c6lctSalwqFGXY7dk6XSahwEilrdmWYgu7dlOxqFryIZ1d)blSXHeWucj43N2neNlsZs(Z16FFwCUE4pyHnoKaMsizwvYd)bRK(WpYlVJuQ5A9VploxoxKML83qvoIZIT73zbn5ej2zf4C9WFWcBuH(R04iOcUWP2qvoIJ8RPK6Q1mbpDvWmuNFfopLrlNlsZs(GjwYjOh9hcILnB(0XITDQyXFw0egZYV7flOplXeMt7Yc(9aqyw8cKLhYYqTHW7S4SayLael43daXIJzr7pXIJzjcIXNQMyboS8xhXY9SGHSCpl(mhccZcsjl8ZI3EAyXzj2aJf87bGyHqw0neMZ1d)blSrf6pWucjoOh9hckHT5thYdXdAk9(GIESskJ8RPK6Q1mQU2RaLGTKR1PF)ku4u5)Aid(9aqagGQqD1Agvx7vGsWwY160VFfkCYNGxKb)Eaiadqv0ZEq4BCqp6peucBZNUeO35OiZFbGUcLc79WFWY4GE0FiOe2MpDjqVZrrMRsn9HA)v0ZEq4BCqp6peucBZNU0o5AZFbGUcvwgi8noOh9hckHT5txANCTzOo)kCEXUFwgi8noOh9hckHT5txc07CuKb)EaiahBfGW34GE0FiOe2MpDjqVZrrMH68RWagTkaHVXb9O)qqjSnF6sGENJIm)fa6ku95CrAwYhmXcAGfciqel2UFNf0KtKyNvGfB7uXseeJpvnXIxGSa)DASDyIfB3VZIZsmH50USOUAnwSTtflGeoEfUcfNRh(dwyJk0FGPescWcbeik97uchDZ9yKFnLShCwhOPGPaiwrVEi85CvnzcWcbeikbs44vqH9biudcTvMGNUkygYbJNLPUAntWtxfmRO(k6PUAnJQR9kqjyl5AD63Vcfov(VgYGFpaKsa0Sm1vRzuDTxbkbBjxRt)(vOWjFcErg87bGucG2pltfIXkAhQ9pnuNFfgWkdG(CUinl5pi6XIJz53jwA3GFwqfaz5kw(DIfNLycZPDzX2vGqBSahwSD)ol)oXcs54Z5flQRwJf4WIT73zXzbGcmmfyjNGE0Fiiw2S5thlEbYIn)EwAWHf0KtKyNvGLRXY9SydwplQelRiwCu(vSOsn4qS87elbqwomlTRo8obY56H)Gf2Oc9hykHK2AINGTePxfH8RPuVE9uxTMr11EfOeSLCTo97xHcNk)xdzWVhakpGtwM6Q1mQU2RaLGTKR1PF)ku4KpbVid(9aq5bC6RON9bicQ86niO63Jpzz2RUAnZ4iOcUWP2qvoIBwr97ROh4SoqtbtbqCwwac1GqBLj4PRcMH68RW5HwaKL1larqLxVPou7FQ5KIaeQbH2ktawiGarPFNs4OBUhBgQZVcNhAbq)(9ZY6bcFJd6r)HGsyB(0La9ohfzgQZVcNhavrac1GqBLj4PRcMH68RW5PmaueGiOYR3uuyGA4a2pl7QNMiO2Fcm1ou7FAOo)kmGbOkSpaHAqOTYe80vbZqoy8SSaebvE9gGIpNxkuxTMbORahcmrDrqB00r1BwrzzbicQ86niO63JpkuxTMzCeubx4uBOkhXnd15xHbmaxH6Q1mJJGk4cNAdv5iUzfX5I0SGgVcKMLT3hnCazX297S4SuKnwIjmN2Lf1vRXIxGSGMCIe7ScSC4cDplUkC9S8qwujwwycKZ1d)blSrf6pWucjbVcKoPUAnKxEhPe(9rdhqKFnL6PUAnJQR9kqjyl5AD63Vcfov(VgYmuNFfopaIbTzzQRwZO6AVcuc2sUwN(9RqHt(e8Imd15xHZdGyqBFf9cqOgeARmbpDvWmuNFfopaswwVaeQbH2kd1fbTrtsfwGMH68RW5bquyV6Q1maDf4qGjQlcAJMoQ(ev0G6Ybzwrkcqeu51Bak(CE1VVch)JRtrqB0KNsXgaCUinlX4vxelBVp41GIWSy7(DwCwIjmN2Lf1vRXI66zPGpl22PILiiuFfkwAWHf0KtKyNvGf4Wcs5RahcKLTOBUhZ56H)Gf2Oc9hykHe87dEnOiKFnL6PUAnJQR9kqjyl5AD63Vcfov(VgYGFpauEakltD1Agvx7vGsWwY160VFfkCYNGxKb)EaO8auFf9cqeu51BQd1(NAoLLfGqni0wzcE6QGzOo)kCEaKSm7r4Z5QAYeatbybE)blf2hGiOYR3au858klRxac1GqBLH6IG2OjPclqZqD(v48aikSxD1AgGUcCiWe1fbTrthvFIkAqD5GmRifbicQ86nafFoV63xrp7bHVPTM4jylr6vrM)caDfQSm7dqOgeARmbpDvWmKdgplZ(aeQbH2ktawiGarPFNs4OBUhBgYbJ3NZfPzjgV6Iyz79bVgueMfvQbhIf0aleqGioxp8hSWgvO)atjKGFFWRbfH8RPuVaeQbH2ktawiGarPFNs4OBUhBgQZVcdy0QWEWzDGMcMcGyf9q4Z5QAYeGfciqucKWXRqwwac1GqBLj4PRcMH68RWagT9vGWNZv1KjaMcWc8(dw9vypi8nT1epbBjsVkY8xaORqPiarqLxVPou7FQ5Kc7bN1bAkykaIvqb9fHjZvjVIRWX)46ue0gn5H(aGZfPzjgdl09SacFwaxZvOy53jwOcKfyJLyuhbvWfML83qvoIJCwaxZvOybORahcKfQlcAJMoQEwGdlxXYVtSOD8ZcQailWglEXc6f0xeM4C9WFWcBuH(dmLqccFoxvtiV8osjq4Ngkgw3qDu9yKJW1lsPEQRwZmocQGlCQnuLJ4MH68RW5H2Sm7vxTMzCeubx4uBOkhXnRO(k6PUAndqxboeyI6IG2OPJQprfnOUCqMH68RWagva005iRVIEQRwZqb9fHPegQ9XmuNFfopubqtNJSSm1vRzOG(IWusVkFmd15xHZdva005iRpNRh(dwyJk0FGPesWRQDdH8q8GMsVpOOhRKYi)AknuBi8URQjfVpOO38xhLEyc8O8ug4OWJsHDkaKce(CUQMmGWpnumSUH6O6XCUE4pyHnQq)bMsiPdcR2neYdXdAk9(GIESskJ8RP0qTHW7UQMu8(GIEZFDu6HjWJYt5yBqRcpkf2Paqkq4Z5QAYac)0qXW6gQJQhZ56H)Gf2Oc9hykHe8tATpPM2hc5H4bnLEFqrpwjLr(1uAO2q4DxvtkEFqrV5Vok9We4r5PmWbyd15xHv4rPWofasbcFoxvtgq4Ngkgw3qDu9yoxKML8hmwSalwcGSy7(D46zj4rrxHIZ1d)blSrf6pWucjn4eOeSLk)xdH8RPKhLc7uaioxKMf0RlcAJgwIjSazX2ovS4QW1ZYdzHQNgwCwkYglXeMt7YITRaH2yXlqwWocILgCybn5ej2zf4C9WFWcBuH(dmLqc1fbTrtsfwGi)Ak1Jc6lctg9Q8jveY(SmkOVimzWqTpPIq2NLrb9fHjJxXtfHSpltD1Agvx7vGsWwY160VFfkCQ8FnKzOo)kCEaedAZYuxTMr11EfOeSLCTo97xHcN8j4fzgQZVcNhaXG2Smh)JRtrqB0KhahakcqOgeARmbpDvWmKdgxH9GZ6anfmfaX9v0laHAqOTYe80vbZqD(v48InaYYcqOgeARmbpDvWmKdgVFw2vpnrqT)eyQDO2)0qD(vyaRma4CrAwYFq0JL5qT)SOsn4qSSWxHIf0Ktoxp8hSWgvO)atjK0wt8eSLi9QiKFnLcqOgeARmbpDvWmKdgxbcFoxvtMaykalW7pyPONJ)X1PiOnAYdGdaf2hGiOYR3uhQ9p1CkllarqLxVPou7FQ5Kch)JRtrqB0ay0ha9vyFaIGkVEdcQ(94JIE2hGiOYR3uhQ9p1CkllaHAqOTYeGfciqu63Peo6M7XMHCW49vyp4SoqtbtbqmNlsZcAYjsSZkWITDQyXFwa4aaySKtmaJLEWrdTrdl)UxSG(aGLCIbySy7(DwqdSqabI6ZIT73HRNfneFfkw(RJy5kwIPgcb1l8ZIxGSOVIyzfXIT73zbnWcbeiILRXY9SyZXSas44vGa5C9WFWcBuH(dmLqccFoxvtiV8osPaykalW7pyLuH(JCeUErkzp4SoqtbtbqSce(CUQMmbWuawG3FWsrVEo(hxNIG2Ojpaoau0tD1AgGUcCiWe1fbTrthvFIkAqD5GmROSm7dqeu51Bak(CE1pltD1AgvnecQx43SIuOUAnJQgcb1l8BgQZVcdy1vRzcE6QGbCn(FWQFw2vpnrqT)eyQDO2)0qD(vyaRUAntWtxfmGRX)dwzzbicQ86n1HA)tnN6RON9bicQ86n1HA)tnNYY654FCDkcAJgaJ(ailde(M2AINGTePxfz(la0vO6ROhcFoxvtMaSqabIsGeoEfYYcqOgeARmbyHaceL(DkHJU5ESzihmE)(CUE4pyHnQq)bMsijqAc)NRtU(qvDu9i)AkHWNZv1KjaMcWc8(dwjvO)CUE4pyHnQq)bMsi5QGpL)hSq(1ucHpNRQjtamfGf49hSsQq)5CrAwqp8FD(tyw2H2yPBf2zjNyagl(qSGYVIazjIgwWuawGCUE4pyHnQq)bMsibHpNRQjKxEhPKJJay0SrbKJW1lsjkOVimzUkPxLpapafP6H)GLb)(0UHmeYOW6P0FDeWSNc6lctMRs6v5dW3d4aS31u9gmCPtWw63Pudoe(nu5QAce4JDFKQh(dwgBJ)7gczuy9u6VocyaWaiKkoI060UJFIZfPzjgV6Iyz79bVgueMfB7uXYVtS0ou7plhMfxfUEwEilubICwAdv5iolhMfxfUEwEilubICwIdxS4dXI)SaWbaWyjNyaglxXIxSGEb9fHjKZcAYjsSZkWI2XpMfVG)onSaqbgMcywGdlXHlwSbxAqwGiOj4rS0bhILF3lw4mLbal5edWyX2ovSehUyXgCPbl09SS9(GxdkILcAJZ1d)blSrf6pWucj43h8Aqri)Ak17QNMiO2Fcm1ou7FAOo)kmGr)SSEQRwZmocQGlCQnuLJ4MH68RWagva005id4d0P754FCDkcAJgKASbqFfQRwZmocQGlCQnuLJ4Mvu)(zz9C8pUofbTrdWq4Z5QAY44iagnBua4vxTMHc6lctjmu7JzOo)kmWaHVPTM4jylr6vrM)caHtd15xb8aYG28uwzaKL54FCDkcAJgGHWNZv1KXXramA2OaWRUAndf0xeMs6v5JzOo)kmWaHVPTM4jylr6vrM)caHtd15xb8aYG28uwza0xbf0xeMmxL8kUIE2RUAntWtxfmROSm7Fxt1BWVpA4aAOYv1eyFf96zFac1GqBLj4PRcMvuwwaIGkVEdqXNZlf2hGqni0wzOUiOnAsQWc0SI6NLfGiOYR3uhQ9p1CQVIE2hGiOYR3GGQFp(KLzV6Q1mbpDvWSIYYC8pUofbTrtEaCa0plR37AQEd(9rdhqdvUQMavOUAntWtxfmRif9uxTMb)(OHdOb)Eaiah7Smh)JRtrqB0Khaha97NLPUAntWtxfmRif2RUAnZ4iOcUWP2qvoIBwrkS)DnvVb)(OHdOHkxvtGCUinl5dMyj)dclmlxXIDSkFyb9c6lctS4filyhbXsmYUUbS83sRzj)dclwAWHf0KtKyNvGZ1d)blSrf6pWucjfzl1bHfYVMs9uxTMHc6lctj9Q8XmuNFfopczuy9u6VoklRxy3huewjaPyOWUpOO0FDeGrB)SSWUpOiSsXUVcpkf2PaqCUE4pyHnQq)bMsiz31Tuhewi)Ak1tD1AgkOVimL0RYhZqD(v48iKrH1tP)6if9cqOgeARmbpDvWmuNFfop0cGSSaeQbH2ktawiGarPFNs4OBUhBgQZVcNhAbq)SSEHDFqryLaKIHc7(GIs)1ragT9ZYc7(GIWkf7(k8OuyNcaX56H)Gf2Oc9hykHK2sRtDqyH8RPup1vRzOG(IWusVkFmd15xHZJqgfwpL(RJu0laHAqOTYe80vbZqD(v48qlaYYcqOgeARmbyHaceL(DkHJU5ESzOo)kCEOfa9ZY6f29bfHvcqkgkS7dkk9xhby02pllS7dkcRuS7RWJsHDkaeNlsZcsbe9ybwSea5C9WFWcBuH(dmLqInFMdojylr6vrCUinl5dMyz79PDdXYdzjAGbw2GAFyb9c6lctSahwSTtflxXcS0XzXowLpSGEb9fHjw8cKLfMybPaIESenWaMLRXYvSyhRYhwqVG(IWeNRh(dwyJk0FGPesWVpTBiKFnLOG(IWK5QKEv(KLrb9fHjdgQ9jveY(SmkOVimz8kEQiK9zzQRwZyZN5Gtc2sKEvKzfPqD1AgkOVimL0RYhZkklRN6Q1mbpDvWmuNFfgWE4pyzSn(VBiKrH1tP)6ifQRwZe80vbZkQpNRh(dwyJk0FGPesSn(VZ56H)Gf2Oc9hykHKzvjp8hSs6d)iV8osPMR1)(S4C5CrAw2EFWRbfXsdoS0brqDu9SSknHXSSWxHILycZPD5C9WFWcBAUw)7Zsj87dEnOiKFnLSFwf1GdkYO6AVcuc2sUwN(9RqHnumSUOicKZfPzbno(z53jwaHpl2UFNLFNyPdIFw(RJy5HS4GGSSQ)0S87elDoYybCn(FWILdZY(9gw2wv7gILH68RWS0T0)fPpcKLhYsN)HDw6GWQDdXc4A8)GfNRh(dwytZ16FFwatjKGxv7gc5H4bnLEFqrpwjLr(1uce(MoiSA3qMH68RW5nuNFfg4beGqQkdq5C9WFWcBAUw)7ZcykHKoiSA3qCUCUinl5dMyz79bVguelpKfGikILvel)oXsmEiVt9kqAyrD1ASCnwUNfBWLgKfczr3qSOsn4qS0U6W7xHILFNyPiK9SeC8ZcCy5HSaU6IyrLAWHybnWcbeiIZ1d)blSb)kHFFWRbfH8RP0SkQbhuK5VoYgCQe4qEN6vG0OOhf0xeMmxL8kUc771tD1AM)6iBWPsGd5DQxbsJzOo)kCEE4pyzSn(VBiKrH1tP)6iGbaJYk6rb9fHjZvjv4VNLrb9fHjZvjmu7twgf0xeMm6v5tQiK99ZYuxTM5VoYgCQe4qEN6vG0ygQZVcNNh(dwg87t7gYqiJcRNs)1radagLv0Jc6lctMRs6v5twgf0xeMmyO2Nuri7ZYOG(IWKXR4PIq23VFwM9QRwZ8xhzdovcCiVt9kqAmRO(zz9uxTMj4PRcMvuwgcFoxvtMaSqabIsGeoEf6RiaHAqOTYeGfciqu63Peo6M7XMHCW4kcqeu51BQd1(NAo1xrp7dqeu51Bak(CELLfGqni0wzOUiOnAsQWc0muNFfopaAFf9uxTMj4PRcMvuwM9biudcTvMGNUkygYbJ3NZfPzjFWel5e0J(dbXYMnF6yX2ovS870qSCywkilE4peelyB(0HCwCmlA)jwCmlrqm(u1elWIfSnF6yX297SaiwGdlnYgnSGFpaeMf4WcSyXzj2aJfSnF6ybdz539NLFNyPiBSGT5thl(mhccZcsjl8ZI3EAy539NfSnF6yHqw0neMZ1d)blSb)atjK4GE0FiOe2MpDipepOP07dk6XkPmYVMs2dcFJd6r)HGsyB(0La9ohfz(la0vOuyVh(dwgh0J(dbLW28Plb6DokYCvQPpu7VIE2dcFJd6r)HGsyB(0L2jxB(la0vOYYaHVXb9O)qqjSnF6s7KRnd15xHZdT9ZYaHVXb9O)qqjSnF6sGENJIm43dab4yRae(gh0J(dbLW28Plb6DokYmuNFfgWXwbi8noOh9hckHT5txc07CuK5VaqxHIZfPzjFWeMf0aleqGiwUglOjNiXoRalhMLvelWHL4Wfl(qSas44v4kuSGMCIe7ScSy7(DwqdSqabIyXlqwIdxS4dXIkPH2yb9bal5edW4C9WFWcBWpWucjbyHaceL(DkHJU5EmYVMs2doRd0uWuaeROxpe(CUQMmbyHaceLajC8kOW(aeQbH2ktWtxfmd5GXvy)SkQbhuKjAUo4aEUo5tWRlKIwASpzzQRwZe80vbZkQVch)JRtrqB0ayLqFaOON6Q1muqFrykPxLpMH68RW5PmaYYuxTMHc6lctjmu7JzOo)kCEkdG(zzQqmwr7qT)PH68RWawzaOW(aeQbH2ktWtxfmd5GX7Z5I0SGgybE)blwAWHfxRzbe(yw(D)zPZbIWSGxdXYVtXzXhQq3ZYqTHW7eil22PILyuhbvWfML83qvoIZYUJzrtyml)UxSGwwWuaZYqD(vxHIf4WYVtSau858If1vRXYHzXvHRNLhYsZ1AwGTglWHfVIZc6f0xeMy5WS4QW1ZYdzHqw0neNRh(dwyd(bMsibHpNRQjKxEhPei8tdfdRBOoQEmYr46fPup1vRzghbvWfo1gQYrCZqD(v48qBwM9QRwZmocQGlCQnuLJ4MvuFf2RUAnZ4iOcUWP2qvoINWx1w60EC8tZ5MvKIEQRwZa0vGdbMOUiOnA6O6turdQlhKzOo)kmGrfanDoY6RON6Q1muqFrykHHAFmd15xHZdva005illtD1AgkOVimL0RYhZqD(v48qfanDoYYY6zV6Q1muqFrykPxLpMvuwM9QRwZqb9fHPegQ9XSI6RW(31u9gmuJ)lqgQCvnb2NZfPzbnWc8(dwS87(ZsyNcaHz5ASehUyXhIf46XhiXcf0xeMy5HSalDCwaHpl)onelWHLdvbhILF)WSy7(Dw2GA8FbIZ1d)blSb)atjKGWNZv1eYlVJuce(j46XhiLOG(IWeYr46fPup7vxTMHc6lctjmu7JzfPWE1vRzOG(IWusVkFmRO(zzVRP6nyOg)xGmu5QAcKZ1d)blSb)atjK0bHv7gc5H4bnLEFqrpwjLr(1uAO2q4Dxvtk6PUAndf0xeMsyO2hZqD(v48gQZVcNLPUAndf0xeMs6v5JzOo)kCEd15xHZYq4Z5QAYac)eC94dKsuqFryQVIHAdH3DvnP49bf9M)6O0dtGhLNYasHhLc7uaifi85CvnzaHFAOyyDd1r1J5C9WFWcBWpWucj4v1UHqEiEqtP3hu0JvszKFnLgQneE3v1KIEQRwZqb9fHPegQ9XmuNFfoVH68RWzzQRwZqb9fHPKEv(ygQZVcN3qD(v4Sme(CUQMmGWpbxp(aPef0xeM6RyO2q4DxvtkEFqrV5Vok9We4r5PmGu4rPWofasbcFoxvtgq4Ngkgw3qDu9yoxp8hSWg8dmLqc(jT2Nut7dH8q8GMsVpOOhRKYi)AknuBi8URQjf9uxTMHc6lctjmu7JzOo)kCEd15xHZYuxTMHc6lctj9Q8XmuNFfoVH68RWzzi85CvnzaHFcUE8bsjkOVim1xXqTHW7UQMu8(GIEZFDu6HjWJYtzGJcpkf2Paqkq4Z5QAYac)0qXW6gQJQhZ5I0SKpyIL8hmwSalwcGSy7(D46zj4rrxHIZ1d)blSb)atjK0GtGsWwQ8FneYVMsEukStbG4CrAwYhmXcs5RahcKLTOBUhZIT73zXR4SOHfkwOcUqTZI2X)vOyb9c6lctS4fil)eNLhYI(kIL7zzfXIT73zbGT0yFyXlqwqtorIDwboxp8hSWg8dmLqc1fbTrtsfwGi)Ak1RN6Q1muqFrykHHAFmd15xHZtzaKLPUAndf0xeMs6v5JzOo)kCEkdG(kcqOgeARmbpDvWmuNFfoVydaf9uxTMjAUo4aEUo5tWRlKIwASpgeUEragqOpaYYSFwf1GdkYenxhCapxN8j41fsrln2hdfdRlkIa73pltD1AMO56Gd456KpbVUqkAPX(yq46fLNsacGaGSSaeQbH2ktWtxfmd5GXv44FCDkcAJM8a4aGZfPzjFWelOjNiXoRal2UFNf0aleqGiKGu(kWHazzl6M7XS4filGWcDplqe0yBUNybGT0yFyboSyBNkwIPgcb1l8ZIn4sdYcHSOBiwuPgCiwqtorIDwbwiKfDdH5C9WFWcBWpWucji85CvnH8Y7iLcGPaSaV)Gvc)ihHRxKs2doRd0uWuaeRaHpNRQjtamfGf49hSu0Rxac1GqBLH6IIpKRtWbS8kqMH68RWawzGdaby9uwzGFwf1GdkYGVQT0P944NMZ7RGIH1ffrGgQlk(qUobhWYRa1plZX)46ue0gn5Peahak6z)7AQEtBnXtWwI0RImu5QAcmltD1AMGNUkyaxJ)hSYlaHAqOTY0wt8eSLi9QiZqD(vyGbq7RaHpNRQjZVpNwNWebenjB(9k6PUAndqxboeyI6IG2OPJQprfnOUCqMvuwM9bicQ86nafFoV6R49bf9M)6O0dtGhLN6Q1mbpDvWaUg)pyb8aWaqYYuHySI2HA)td15xHbS6Q1mbpDvWaUg)pyLLfGiOYR3uhQ9p1CkltD1AgvnecQx43SIuOUAnJQgcb1l8BgQZVcdy1vRzcE6QGbCn(FWcy9a4a)SkQbhuKjAUo4aEUo5tWRlKIwASpgkgwxueb2VVc7vxTMj4PRcMvKIE2hGiOYR3uhQ9p1CkllaHAqOTYeGfciqu63Peo6M7XMvuwMkeJv0ou7FAOo)kmGdqOgeARmbyHaceL(DkHJU5ESzOo)kmWaozzTd1(NgQZVcJurQkdqbaGvxTMj4PRcgW14)bR(CUinl5dMy53jwIrq1VhFyX297S4SGMCIe7ScS87(ZYHl09S0gyhlaSLg7dNRh(dwyd(bMsizCeubx4uBOkhXr(1usD1AMGNUkygQZVcNNYOnltD1AMGNUkyaxJ)hSaCSbGce(CUQMmbWuawG3FWkHFoxp8hSWg8dmLqsG0e(pxNC9HQ6O6r(1ucHpNRQjtamfGf49hSs4xrp7vxTMj4PRcgW14)bR8InaYYSparqLxVbbv)E8PFwM6Q1mJJGk4cNAdv5iUzfPqD1AMXrqfCHtTHQCe3muNFfgWaCGfGf46Et0qHdtjxFOQoQEZFDucHRxeW6zV6Q1mQAieuVWVzfPW(31u9g87JgoGgQCvnb2NZ1d)blSb)atjKCvWNY)dwi)AkHWNZv1KjaMcWc8(dwj8Z5I0SeJWNZv1ellmbYcSyXvp99hHz539NfBE9S8qwujwWoccKLgCybn5ej2zfybdz539NLFNIZIpu9SyZXpbYcsjl8ZIk1GdXYVtDCUE4pyHn4hykHee(CUQMqE5DKsyhbLAWjf80vbKJW1lsj7dqOgeARmbpDvWmKdgplZEe(CUQMmbyHaceLajC8kOiarqLxVPou7FQ5uwg4SoqtbtbqmNlsZs(Gjml5pi6XY1y5kw8If0lOVimXIxGS8ZrywEil6RiwUNLvel2UFNfa2sJ9b5SGMCIe7ScS4fil5e0J(dbXYMnF64C9WFWcBWpWucjT1epbBjsVkc5xtjkOVimzUk5vCfEukStbGuOUAnt0CDWb8CDYNGxxifT0yFmiC9IamGqFaOOhi8noOh9hckHT5txc07CuK5VaqxHklZ(aebvE9MIcdudhW(kq4Z5QAYGDeuQbNuWtxfu0tD1AMXrqfCHtTHQCe3muNFfgWa88RhAb(zvudoOid(Q2sN2JJFAoVVc1vRzghbvWfo1gQYrCZkklZE1vRzghbvWfo1gQYrCZkQpNlsZs(GjwY)l63zz79P5AnlrdmGz5ASS9(0CTMLdxO7zzfX56H)Gf2GFGPesWVpnxRr(1usD1Agyr)oofrtGI(dwMvKc1vRzWVpnxRnd1gcV7QAIZ1d)blSb)atjKe8kq6K6Q1qE5DKs43hnCar(1usD1Ag87JgoGMH68RWagTk6PUAndf0xeMsyO2hZqD(v48qBwM6Q1muqFrykPxLpMH68RW5H2(kC8pUofbTrtEaCaW5I0SeJxDrywYjgGXIk1GdXcAGfciqell8vOy53jwqdSqabIyjalW7pyXYdzjStbGy5ASGgyHaceXYHzXd)Y164S4QW1ZYdzrLyj44NZ1d)blSb)atjKGFFWRbfH8RPuaIGkVEtDO2)uZjfi85CvnzcWcbeikbs44vqrac1GqBLjaleqGO0VtjC0n3Jnd15xHbmAvyp4SoqtbtbqSckOVimzUk5vCfo(hxNIG2Ojp0haCUinl5dMyz79P5Anl2UFNLTN0AFyjgpx7zXlqwkilBVpA4aICwSTtflfKLT3NMR1SCywwriNL4Wfl(qSCfl2XQ8Hf0lOVimXsdoSaqbgMcywGdlpKLObgybGT0yFyX2ovS4QqeelaCaWsoXamwGdloyK)hcIfSnF6yz3XSaqbgMcywgQZV6kuSahwomlxXstFO2FdlXc(el)U)SSkqAy53jwWEhXsawG3FWcZY9OdZcyeMLIw)4AwEilBVpnxRzbCnxHILyuhbvWfML83qvoIJCwSTtflXHl0bYc(pTMfQazzfXIT73zbGdaG54iwAWHLFNyr74NfuAOQRXgoxp8hSWg8dmLqc(9P5AnYVMsVRP6n4N0AFsGZ1EdvUQMavy)7AQEd(9rdhqdvUQMavOUAnd(9P5ATzO2q4Dxvtk6PUAndf0xeMs6v5JzOo)kCEaufuqFryYCvsVkFuOUAnt0CDWb8CDYNGxxifT0yFmiC9IamGqlaYYuxTMjAUo4aEUo5tWRlKIwASpgeUEr5PeGqlau44FCDkcAJM8a4ailde(gh0J(dbLW28Plb6DokYmuNFfopaAwMh(dwgh0J(dbLW28Plb6DokYCvQPpu7FFfbiudcTvMGNUkygQZVcNNYaGZfPzjFWelBVp41GIyj)VOFNLObgWS4filGRUiwYjgGXITDQybn5ej2zfyboS87elXiO63JpSOUAnwomlUkC9S8qwAUwZcS1yboSehUqhilbpILCIbyCUE4pyHn4hykHe87dEnOiKFnLuxTMbw0VJtbn5tcXHpyzwrzzQRwZa0vGdbMOUiOnA6O6turdQlhKzfLLPUAntWtxfmRif9uxTMzCeubx4uBOkhXnd15xHbmQaOPZrgWhOt3ZX)46ue0gni1ydG(al2a)7AQEtr2sDqyzOYv1eOc7Nvrn4GIm4RAlDApo(P5CfQRwZmocQGlCQnuLJ4MvuwM6Q1mbpDvWmuNFfgWOcGMohzaFGoDph)JRtrqB0GuJna6NLPUAnZ4iOcUWP2qvoINWx1w60EC8tZ5Mvuwwp1vRzghbvWfo1gQYrCZqD(vya7H)GLb)(0UHmeYOW6P0FDKcCeP1PDh)eGbGb9ZYuxTMzCeubx4uBOkhXnd15xHbSh(dwgBJ)7gczuy9u6VokldHpNRQjZfdGPaSaV)GLIaeQbH2kZv4WSExvtPyy51V6sGeIlqMHCW4kOyyDrreO5kCywVRQPumS86xDjqcXfO(kuxTMzCeubx4uBOkhXnROSm7vxTMzCeubx4uBOkhXnRif2hGqni0wzghbvWfo1gQYrCZqoy8Sm7dqeu51Bqq1VhF6NL54FCDkcAJM8a4aqbf0xeMmxL8koNlsZIDN4S8qw6CGiw(DIfvc)SaBSS9(OHdilQXzb)EaORqXY9SSIyjgwxaiDCwUIfVIZc6f0xeMyrD9SaWwASpSC46zXvHRNLhYIkXs0adbcKZ1d)blSb)atjKGFFWRbfH8RP07AQEd(9rdhqdvUQMavy)SkQbhuK5VoYgCQe4qEN6vG0OON6Q1m43hnCanROSmh)JRtrqB0Khaha9vOUAnd(9rdhqd(9aqao2k6PUAndf0xeMsyO2hZkkltD1AgkOVimL0RYhZkQVc1vRzIMRdoGNRt(e86cPOLg7JbHRxeGbeabak6fGqni0wzcE6QGzOo)kCEkdGSm7r4Z5QAYeGfciqucKWXRGIaebvE9M6qT)PMt95CrAwqp8FD(tyw2H2yPBf2zjNyagl(qSGYVIazjIgwWuawGCUE4pyHn4hykHee(CUQMqE5DKsoocGrZgfqocxViLOG(IWK5QKEv(a8auKQh(dwg87t7gYqiJcRNs)1raZEkOVimzUkPxLpaFpGdWExt1BWWLobBPFNsn4q43qLRQjqGp29rQE4pyzSn(VBiKrH1tP)6iGbad6JwKkoI060UJFcyaWGwG)DnvVP8FneoP6AVcKHkxvtGCUinlX4vxelBVp41GIy5kwCwaiadtbw2GAFyb9c6lctiNfqyHUNfn9SCplrdmWcaBPX(WsVF3Fwoml7EbQjqwuJZcD)onS87elBVpnxRzrFfXcCy53jwYjgGLhahaSOVIyPbhw2EFWRbf1h5Sacl09SarqJT5EIfVyj)VOFNLObgyXlqw00ZYVtS4Qqeel6Riw29cutSS9(OHdiNRh(dwyd(bMsib)(Gxdkc5xtj7Nvrn4GIm)1r2GtLahY7uVcKgf9uxTMjAUo4aEUo5tWRlKIwASpgeUEragqaeaKLPUAnt0CDWb8CDYNGxxifT0yFmiC9IamGqlau8UMQ3GFsR9jbox7nu5QAcSVIEuqFryYCvcd1(OWX)46ue0gnadHpNRQjJJJay0SrbGxD1AgkOVimLWqTpMH68RWade(M2AINGTePxfz(laeonuNFfWdidAZdGcGSmkOVimzUkPxLpkC8pUofbTrdWq4Z5QAY44iagnBua4vxTMHc6lctj9Q8XmuNFfgyGW30wt8eSLi9QiZFbGWPH68RaEazqBEaCa0xH9QRwZal63XPiAcu0FWYSIuy)7AQEd(9rdhqdvUQMav0laHAqOTYe80vbZqD(v48aizzy4sREfO53NtRtyIaIgdvUQMavOUAnZVpNwNWebeng87bGaCSJD(1Bwf1GdkYGVQT0P944NMZbE02xr7qT)PH68RW5PmaaGI2HA)td15xHbmGaaa6ROxac1GqBLbORahcmHJU5ESzOo)kCEaKSm7dqeu51Bak(CE1NZfPzjFWel5FqyHz5kwSJv5dlOxqFryIfVazb7iiwIr21nGL)wAnl5FqyXsdoSGMCIe7ScS4filiLVcCiqwqVUiOnA6O65C9WFWcBWpWucjfzl1bHfYVMs9uxTMHc6lctj9Q8XmuNFfopczuy9u6VoklRxy3huewjaPyOWUpOO0FDeGrB)SSWUpOiSsXUVcpkf2Paqkq4Z5QAYGDeuQbNuWtxf4C9WFWcBWpWucj7UUL6GWc5xtPEQRwZqb9fHPKEv(ygQZVcNhHmkSEk9xhPW(aebvE9gGIpNxzz9uxTMbORahcmrDrqB00r1NOIguxoiZksraIGkVEdqXNZR(zz9c7(GIWkbifdf29bfL(RJamA7NLf29bfHvk2zzQRwZe80vbZkQVcpkf2Paqkq4Z5QAYGDeuQbNuWtxfu0tD1AMXrqfCHtTHQCe3muNFfgW9qB(biGFwf1GdkYGVQT0P944NMZ7RqD1AMXrqfCHtTHQCe3SIYYSxD1AMXrqfCHtTHQCe3SI6Z56H)Gf2GFGPesAlTo1bHfYVMs9uxTMHc6lctj9Q8XmuNFfopczuy9u6VosH9bicQ86nafFoVYY6PUAndqxboeyI6IG2OPJQprfnOUCqMvKIaebvE9gGIpNx9ZY6f29bfHvcqkgkS7dkk9xhby02pllS7dkcRuSZYuxTMj4PRcMvuFfEukStbGuGWNZv1Kb7iOudoPGNUkOON6Q1mJJGk4cNAdv5iUzOo)kmGrRc1vRzghbvWfo1gQYrCZksH9ZQOgCqrg8vTLoThh)0CEwM9QRwZmocQGlCQnuLJ4MvuFoxKML8btSGuarpwGflbqoxp8hSWg8dmLqInFMdojylr6vrCUinl5dMyz79PDdXYdzjAGbw2GAFyb9c6lctiNf0KtKyNvGLDhZIMWyw(RJy539IfNfKIX)DwiKrH1tSOP2ZcCybw64SyhRYhwqVG(IWelhMLveNRh(dwyd(bMsib)(0UHq(1uIc6lctMRs6v5twgf0xeMmyO2Nuri7ZYOG(IWKXR4PIq2NL1tD1AgB(mhCsWwI0RImROSmCeP1PDh)eGbGb9rRc7dqeu51Bqq1VhFYYWrKwN2D8tagag0xraIGkVEdcQ(94tFfQRwZqb9fHPKEv(ywrzz9uxTMj4PRcMH68RWa2d)blJTX)DdHmkSEk9xhPqD1AMGNUkywr95CrAwYhmXcsX4)olWFNgBhMyX2(f2z5WSCflBqTpSGEb9fHjKZcAYjsSZkWcCy5HSenWal2XQ8Hf0lOVimX56H)Gf2GFGPesSn(VZ5I0SK)CT(3NfNRh(dwyd(bMsizwvYd)bRK(WpYlVJuQ5A9VplRnCefSILYaaqwV1Bzba]] )

end