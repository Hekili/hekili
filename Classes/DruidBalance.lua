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


    spec:RegisterPack( "Balance", 20210812, [[di1FXfqikPEeePUeejTjs4tqQmkPKtjLAvqO6vqiZcsXTKIu7IIFbrmma4yKOwga6zcfnnkjCniL2gaP(gekgNueDoiuADaKmpaQ7rISpHQ(hejsDqHkwOqjpeIQjsjP6IqQQncqWhPKuKrcrIKtsjjRukQxsjPWmPKOBcqi7uOs)eGqnuaIokLKIAPusk9uLYufkCvPiSvisuFfIegRuKSxk1Ff1GjomvlMKESGjd0Lr2Su9ziz0kvNwLvdrI41qWSj1TfPDl53GgUqooKQSCfphQPRQRRKTdOVtjgpeLZlfwVqPMVi2pQTv2og2BG(t2XfGaaGkdGMuzaAaqtgtacqaT923iIS3I8acokYER8uYElwU2RazVf5n0qh0og2By4AcK92()ryafsqIQR9kqnn(sdgu3VVunhejXY1EfOME7srossbn7FQgP09ttkP6AVcK5r2BVPUo9BvLTQ9gO)KDCbiaaOYaOjvgGga0KXeGkBf2B(63HJ922LIC7T9deKkBv7nqchS3ILR9kqSy1N1bYnhNfQf(zrzaIgwaiaaOYCZCZiF3luegqXn30SehqqcKLnO2hwIf5PgU5MMfKV7fkcKL3hu0NVolbhtywEilHgbnLFFqrp2Wn30Sy1sPqGeilRQOaHX(0GfG(CUQMWS06mKbnSeneWm(9bVguelnD8Seneqd(9bVguuBd3CtZsCacpqwIgk44)kuSGum(VZY1z5E0Hz53jwSmWcflOFqFryYWn30SaiYrGyb5WciebILFNyzl6M7XS4SOV)1elPWHyPRjKDQAILwxNLgWfl7oyHUNL97z5EwWx6s)ErWfw3Gfl3VZsSaehNyWcIyb5KMW)5AwIJ(qvPu9OHL7rhilyeUO2gU5MMfarocelPq8Zc66hQ9ppuQFfgDSGdu5ZbXS4rr6gS8qwuHyml9d1(Jzbw6ggU5MMLymK)SedykXcSZsS0(olXs77SelTVZIJzXzbhrHZ1S8ZviqVHBUPzbqCev0WsRZqg0WcsX4)oAybPy8FhnSS9(0VHAZsQdsSKchILHWN(O6z5HSq(OpAyjatv9VPXVpVHBMBoovbF)jqwILR9kqSehaPvYsWlwujw6WvbYI)SS)FegqHeKO6AVcutJV0Gb197lvZbrsSCTxbQP3UuKJKuqZ(NQrkD)0KsQU2RazEK92B6d)y7yyVbJOIg7yyhxLTJH9gvUQMaTJL9Mh(dw2Bwg)3T3ajCyUO)GL9gGCOGJFwailifJ)7S4filolBVp41GIybwSSfdwSC)olX9qT)Sai4elEbYsSGXjgSahw2EF63qSa)DASCyYElm3tZ52BTyHc6lctg9Q8jxeYEwssyHc6lctMRYyO2hwssyHc6lctMRYQWFNLKewOG(IWKXRg5Iq2ZsBwuWs0qankBSm(VZIcwSMLOHaAaOXY4)U9BhxaAhd7nQCvnbAhl7np8hSS3WVp9Bi7TWCpnNBVznlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGSKKWI1SeGaPYR3uhQ9p3DILKewSMfCeP153hu0Jn43NUR1SOelkZssclwZY7AQEt5)AiCw11EfidvUQMazjjHLwSqb9fHjdgQ9jxeYEwssyHc6lctMRY6v5dljjSqb9fHjZvzv4VZsscluqFryY4vJCri7zPT9M(kkhaT3qR9Bh3yAhd7nQCvnbAhl7np8hSS3WVp41GIS3cZ90CU92SkQdhuKr11EfOmSNDTo)7xHcBOYv1eilkyjabsLxVPou7FU7elkybhrAD(9bf9yd(9P7AnlkXIY2B6ROCa0EdT2V9BVbsDFPF7yyhxLTJH9Mh(dw2ByO2NSk5P2Bu5QAc0ow2VDCbODmS3OYv1eODSS3cZ90CU92FPelaMLwSaqwqCw8WFWYyz8F3eC8N)lLybrS4H)GLb)(0VHmbh)5)sjwABV5H)GL9wW16Sh(dwz9HF7n9H)C5PK9gmIkASF74gt7yyVrLRQjq7yzVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3WrKwNFFqrp2GFF6UwZs8SOmlkyPflwZY7AQEd(9rdhqdvUQMazjjHL31u9g8tATpzW56VHkxvtGS0MLKewWrKwNFFqrp2GFF6UwZs8Saq7nqchMl6pyzVTrpML4arFwGflXerSy5(D46zbCU(ZIxGSy5(Dw2EF0WbKfVazbGiIf4VtJLdt2Ba9jxEkzVD4Sdj73oUwHDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2B4isRZVpOOhBWVp9BiwINfLT3ajCyUO)GL92g9ywcAYbsSyzNkw2EF63qSe8IL97zbGiIL3hu0JzXY(f2z5WSmKMa61ZshoS87elOFqFryILhYIkXs0qDAgcKfVazXY(f2zPFAnnS8qwco(T3a6tU8uYE7W5GMCGK9Bhx0Ahd7nQCvnbAhl7nyK9gME7np8hSS3a6Z5QAYEdORxK9w0qanPqy1VHyjjHLOHaAWRQFdXssclrdb0GFFWRbfXssclrdb0GFF6UwZssclrdb00xtJmSNj9QiwssyrD17MGNVkygk1VcZIsSOU6DtWZxfmGRX)dwSKKWs0qanJdKk4cN7dvXUH9giHdZf9hSS3qk7Z5QAILF3Fwc7uabmlxNLgWfl(qSCflolOcGS8qwCGWdKLFNybF)Y)dwSyzNgIfNLFUcb6zH(alhMLfMaz5kwuP3crflbh)y7nG(KlpLS3UkJkaA)2XfqBhd7nQCvnbAhl7np8hSS3uPbtdcxHYEdKWH5I(dw2BnbMyjw0GPbHRqXIL73zb5XbjwvfyboS49NgwqoSacrGy5kwqECqIvvb7TWCpnNBV1ILwSynlbiqQ86n1HA)ZDNyjjHfRzjaHAqOLYeGfqicu(3Pmo6M7XMvelTzrblQRE3e88vbZqP(vywINfLrllkyrD17MXbsfCHZ9HQy3WmuQFfMfaZIvWIcwSMLaeivE9gGu97ngwssyjabsLxVbiv)EJHffSOU6DtWZxfmRiwuWI6Q3nJdKk4cN7dvXUHzfXIcwAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMfLvMLMMf0YcIZYSkQdhuKbFvFPZ7nWpnNBOYv1eiljjSOU6DtWZxfmdL6xHzbWSOSYSKKWIYSGewWrKwN3D8tSaywu2Gw0YsBwAZIcwa6Z5QAYCvgva0(TJlIXog2Bu5QAc0ow2BH5EAo3EtD17MGNVkygk1VcZs8SOmAzrblTyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazjjHf1vVBghivWfo3hQIDdZqP(vywamlkJyyPPzbGSG4SOU6DJQgcb1l8BwrSOGf1vVBghivWfo3hQIDdZkIL2SKKWIkeJzrbl9d1(Nhk1VcZcGzbGO1EdKWH5I(dw2Bas4ZIL73zXzb5Xbjwvfy539NLdxO7zXzbqU0yFyjAGbwGdlw2PILFNyPFO2FwomlUkC9S8qwOc0EZd)bl7Ti4FWY(TJBtAhd7nQCvnbAhl7nyK9gME7np8hSS3a6Z5QAYEdORxK9wGonlTyPfl9d1(Nhk1VcZstZIYOLLMMLaeQbHwktWZxfmdL6xHzPnliHfLBsaWsBwuILaDAwAXslw6hQ9ppuQFfMLMMfLrllnnlbiudcTuMaSacrGY)oLXr3Cp2aUg)pyXstZsac1GqlLjalGqeO8VtzC0n3JndL6xHzPnliHfLBsaWsBwuWI1Sm(bMjGu9gheeBiKD4hZssclbiudcTuMGNVkygk1VcZs8SC1tteu7pbM7hQ9ppuQFfMLKewMvrD4GImbst4)CDghDZ9ydvUQMazrblbiudcTuMGNVkygk1VcZs8SetaWssclbiudcTuMaSacrGY)oLXr3Cp2muQFfML4z5QNMiO2Fcm3pu7FEOu)kmlnnlkdawssyXAwcqGu51BQd1(N7ozVbs4WCr)bl7nK76Ws7pHzXYo970WYcFfkwqoSacrGyPGwyXYP1S4An0clnGlwEil4)0Awco(z53jwWEkXINcx1ZcSZcYHfqiceIqECqIvvbwco(X2Ba9jxEkzVfGfqicugKWnQG9BhxeRDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2BTyPFO2)8qP(vywINfLrlljjSm(bMjGu9gheeBUIL4zbTaGL2SOGLwS0ILwSqO36IIiqdLg1yixNHdy5vGyrblTyjaHAqOLYqPrngY1z4awEfiZqP(vywamlkdObaljjSeGaPYR3aKQFVXWIcwcqOgeAPmuAuJHCDgoGLxbYmuQFfMfaZIYaAedliILwSOSYSG4SmRI6WbfzWx1x68Ed8tZ5gQCvnbYsBwAZIcwSMLaeQbHwkdLg1yixNHdy5vGmd5GnyPnljjSqO36IIiqdgU0A6)RqLNLAdwuWslwSMLaeivE9M6qT)5UtSKKWsac1GqlLbdxAn9)vOYZsTroMwbABsaOSzOu)kmlaMfLv2kyPnljjS0ILaeQbHwkJknyAq4kuMHCWgSKKWI1SmEGm)a1AwAZIcwAXslwi0BDrreO5kCywVRQPm6T86xPzqc4fiwuWslwcqOgeAPmxHdZ6DvnLrVLx)kndsaVazgYbBWssclE4pyzUchM17QAkJElV(vAgKaEbYaEyxvtGS0ML2SKKWslwi0BDrreObV7GqleygoQzyp)WjLQNffSeGqni0szE4Ks1tG5RWhQ9pht0I2ycqLndL6xHzPnljjS0ILwSa0NZv1Kbw5fMY)Cfc0ZIsSOmljjSa0NZv1Kbw5fMY)Cfc0ZIsSetwAZIcwAXYpxHa9MxzZqoyJCac1GqlfljjS8ZviqV5v2eGqni0szgk1VcZs8SC1tteu7pbM7hQ9ppuQFfMLMMfLbalTzjjHfG(CUQMmWkVWu(NRqGEwuIfaYIcwAXYpxHa9MhGMHCWg5aeQbHwkwssy5NRqGEZdqtac1GqlLzOu)kmlXZYvpnrqT)eyUFO2)8qP(vywAAwugaS0MLKewa6Z5QAYaR8ct5FUcb6zrjwaalTzPnlTzjjHLaeivE9geAmNxS0MLKewuHymlkyPFO2)8qP(vywamlQRE3e88vbd4A8)GL9giHdZf9hSS3AcmbYYdzbK0Edw(DILf2rrSa7SG84GeRQcSyzNkww4RqXciCPQjwGfllmXIxGSeneqQEwwyhfXILDQyXlwCqqwiGu9SCywCv46z5HSaEK9gqFYLNs2BbWCawG3FWY(TJRYaWog2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nRzbdxA1Ran)(CADgtec0yOYv1eiljjS0pu7FEOu)kmlXZcabaayjjHfvigZIcw6hQ9ppuQFfMfaZcarlliILwSyfaGLMMf1vVB(9506mMieOXGFpGaliolaKL2SKKWI6Q3n)(CADgtec0yWVhqGL4zjMnjlnnlTyzwf1HdkYGVQV059g4NMZnu5QAcKfeNf0YsB7nqchMl6pyzVHu2NZv1ellmbYYdzbK0Edw8Qbl)Cfc0JzXlqwcGywSStflw87VcflD4WIxSG(ROD4ColrdmyVb0NC5PK92VpNwNXeHanzl(92VDCvwz7yyVrLRQjq7yzVbs4WCr)bl7TMatSG(PrngY1SaiEalVcelaeaykGzrL6WHyXzb5XbjwvfyzHjJ9w5PK9gLg1yixNHdy5vGS3cZ90CU9wac1GqlLj45RcMHs9RWSaywaiayrblbiudcTuMaSacrGY)oLXr3Cp2muQFfMfaZcabalkyPfla95Cvnz(9506mMieOjBXVNLKewux9U53NtRZyIqGgd(9acSeplXeaSGiwAXYSkQdhuKbFvFPZ7nWpnNBOYv1eiliolaAwAZsBwuWcqFoxvtMRYOcGSKKWIkeJzrbl9d1(Nhk1VcZcGzjMig7np8hSS3O0Ogd56mCalVcK9BhxLbODmS3OYv1eODSS3ajCyUO)GL9wtGjw2GlTM(RqXIv7sTblaAmfWSOsD4qS4SG84GeRQcSSWKXER8uYEddxAn9)vOYZsTH9wyUNMZT3AXsac1GqlLj45RcMHs9RWSaywa0SOGfRzjabsLxVbiv)EJHffSynlbiqQ86n1HA)ZDNyjjHLaeivE9M6qT)5UtSOGLaeQbHwktawaHiq5FNY4OBUhBgk1VcZcGzbqZIcwAXcqFoxvtMaSacrGYGeUrfyjjHLaeQbHwktWZxfmdL6xHzbWSaOzPnljjSeGaPYR3aKQFVXWIcwAXI1SmRI6WbfzWx1x68Ed8tZ5gQCvnbYIcwcqOgeAPmbpFvWmuQFfMfaZcGMLKewux9UzCGubx4CFOk2nmdL6xHzbWSOSvWcIyPflOLfeNfc9wxuebAUc)Zk8WbNbpGxrzvsRzPnlkyrD17MXbsfCHZ9HQy3WSIyPnljjS0pu7FEOu)kmlaMfaIwwssyHqV1ffrGgknQXqUodhWYRaXIcwcqOgeAPmuAuJHCDgoGLxbYmuQFfML4zbGaGL2SOGfG(CUQMmxLrfazrblwZcHERlkIanxHdZ6DvnLrVLx)kndsaVaXssclbiudcTuMRWHz9UQMYO3YRFLMbjGxGmdL6xHzjEwaiayjjHfvigZIcw6hQ9ppuQFfMfaZcabG9Mh(dw2By4sRP)VcvEwQnSF74QCmTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEtD17MGNVkygk1VcZs8SOmAzrblTyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazjjHf1vVBghivWfo3hQIDdZqP(vywaSsSOmanaKfeXslwIjliolQRE3OQHqq9c)MvelTzbrS0ILMKLMMf0YcIZI6Q3nQAieuVWVzfXsBwqCwi0BDrreO5k8pRWdhCg8aEfLvjTMffSOU6DZ4aPcUW5(qvSBywrS0MLKewuHymlkyPFO2)8qP(vywamlaeTSKKWcHERlkIanuAuJHCDgoGLxbIffSeGqni0szO0Ogd56mCalVcKzOu)kS9giHdZf9hSS3IJ2I3aZYctSyvwnB1zXY97SG84GeRQc2Ba9jxEkzVDOhyoalW7pyz)2XvzRWog2Bu5QAc0ow2BE4pyzVDfomR3v1ug9wE9R0mib8cK9wyUNMZT3a6Z5QAYCOhyoalW7pyXIcwa6Z5QAYCvgva0ER8uYE7kCywVRQPm6T86xPzqc4fi73oUkJw7yyVrLRQjq7yzVbs4WCr)bl7TMatSmhQ9NfvQdhILai2ER8uYEdV7GqleygoQzyp)WjLQ3Elm3tZ52BTyjaHAqOLYe88vbZqoydwuWI1SeGaPYR3uhQ9p3DIffSa0NZv1K53NtRZyIqGMSf)EwssyjabsLxVPou7FU7elkyjaHAqOLYeGfqicu(3Pmo6M7XMHCWgSOGLwSa0NZv1KjalGqeOmiHBubwssyjaHAqOLYe88vbZqoydwAZsBwuWci8n4v1VHm)fq4kuSOGLwSacFd(jT2NCx7dz(lGWvOyjjHfRz5DnvVb)Kw7tUR9Hmu5QAcKLKewWrKwNFFqrp2GFF63qSeplXKL2SOGLwSacFtkew9BiZFbeUcflTzrblTybOpNRQjZHZoKyjjHLzvuhoOiJQR9kqzyp7AD(3Vcf2qLRQjqwssyXX)46Ce0cnSeVsSGybaljjSOU6DJQgcb1l8BwrS0MffS0ILaeQbHwkJknyAq4kuMHCWgSKKWI1SmEGm)a1AwAZIcwSMfc9wxuebAUchM17QAkJElV(vAgKaEbILKewi0BDrreO5kCywVRQPm6T86xPzqc4fiwuWslwcqOgeAPmxHdZ6DvnLrVLx)kndsaVazgk1VcZs8SetaWssclbiudcTugvAW0GWvOmdL6xHzjEwIjayPnlkyXAwux9Uj45RcMveljjSOcXywuWs)qT)5Hs9RWSaywScayV5H)GL9gE3bHwiWmCuZWE(HtkvV9BhxLb02XWEJkxvtG2XYEdKWH5I(dw2BXy)WSCywCwg)3PHfs7QWXFIflEdwEilPocelUwZcSyzHjwWV)S8ZviqpMLhYIkXI(kcKLvelwUFNfKhhKyvvGfVazb5WciebIfVazzHjw(DIfawGSG1WNfyXsaKLRZIk83z5NRqGEml(qSalwwyIf87pl)Cfc0JT3cZ90CU9wlwa6Z5QAYaR8ct5FUcb6zXALyrzwuWI1S8ZviqV5bOzihSroaHAqOLILKewAXcqFoxvtgyLxyk)ZviqplkXIYSKKWcqFoxvtgyLxyk)ZviqplkXsmzPnlkyPflQRE3e88vbZkIffS0IfRzjabsLxVbiv)EJHLKewux9UzCGubx4CFOk2nmdL6xHzbrS0If0YcIZYSkQdhuKbFvFPZ7nWpnNBOYv1eilTzbWkXYpxHa9MxzJ6Q3ZGRX)dwSOGf1vVBghivWfo3hQIDdZkILKewux9UzCGubx4CFOk2nY4R6lDEVb(P5CZkIL2SKKWsac1GqlLj45RcMHs9RWSGiwailXZYpxHa9Mxztac1GqlLbCn(FWIffSynlQRE3e88vbZkIffS0IfRzjabsLxVPou7FU7eljjSynla95CvnzcWciebkds4gvGL2SOGfRzjabsLxVbHgZ5fljjSeGaPYR3uhQ9p3DIffSa0NZv1KjalGqeOmiHBubwuWsac1GqlLjalGqeO8VtzC0n3JnRiwuWI1SeGqni0szcE(QGzfXIcwAXslwux9UHc6lctz9Q8XmuQFfML4zrzaWssclQRE3qb9fHPmgQ9XmuQFfML4zrzaWsBwuWI1SmRI6WbfzuDTxbkd7zxRZ)(vOWgQCvnbYssclTyrD17gvx7vGYWE2168VFfkCU8FnKb)EabwuIf0YssclQRE3O6AVcug2ZUwN)9RqHZ(e8Im43diWIsS0KS0ML2SKKWI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrS0MLKew6hQ9ppuQFfMfaZcabaljjSa0NZv1Kbw5fMY)Cfc0ZIsSaawAZIcwa6Z5QAYCvgva0EdRHp2E7NRqGELT38WFWYE7NRqGELTF74QmIXog2Bu5QAc0ow2BE4pyzV9ZviqpaT3cZ90CU9wlwa6Z5QAYaR8ct5FUcb6zXALybGSOGfRz5NRqGEZRSzihSroaHAqOLILKewa6Z5QAYaR8ct5FUcb6zrjwailkyPflQRE3e88vbZkIffS0IfRzjabsLxVbiv)EJHLKewux9UzCGubx4CFOk2nmdL6xHzbrS0If0YcIZYSkQdhuKbFvFPZ7nWpnNBOYv1eilTzbWkXYpxHa9MhGg1vVNbxJ)hSyrblQRE3moqQGlCUpuf7gMveljjSOU6DZ4aPcUW5(qvSBKXx1x68Ed8tZ5MvelTzjjHLaeQbHwktWZxfmdL6xHzbrSaqwINLFUcb6npanbiudcTugW14)blwuWI1SOU6DtWZxfmRiwuWslwSMLaeivE9M6qT)5UtSKKWI1Sa0NZv1KjalGqeOmiHBubwAZIcwSMLaeivE9geAmNxSOGLwSynlQRE3e88vbZkILKewSMLaeivE9gGu97ngwAZssclbiqQ86n1HA)ZDNyrbla95CvnzcWciebkds4gvGffSeGqni0szcWciebk)7ughDZ9yZkIffSynlbiudcTuMGNVkywrSOGLwS0If1vVBOG(IWuwVkFmdL6xHzjEwugaSKKWI6Q3nuqFrykJHAFmdL6xHzjEwugaS0MffSynlZQOoCqrgvx7vGYWE2168VFfkSHkxvtGSKKWslwux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqGfLybTSKKWI6Q3nQU2RaLH9SR15F)ku4SpbVid(9acSOelnjlTzPnlTzjjHf1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIyjjHfvigZIcw6hQ9ppuQFfMfaZcabaljjSa0NZv1Kbw5fMY)Cfc0ZIsSaawAZIcwa6Z5QAYCvgva0EdRHp2E7NRqGEaA)2Xv5M0og2Bu5QAc0ow2BGeomx0FWYERjWeMfxRzb(70WcSyzHjwUNsXSalwcG2BE4pyzVTWu(EkfB)2XvzeRDmS3OYv1eODSS3ajCyUO)GL9MvNchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1HT38WFWYEBwv2d)bRS(WV9g(Nl82Xvz7TWCpnNBVb0NZv1K5Wzhs2B6d)5Ytj7nhs2VDCbiaSJH9gvUQMaTJL9wyUNMZT3MvrD4GImQU2RaLH9SR15F)kuydHERlkIaT3W)CH3oUkBV5H)GL92SQSh(dwz9HF7n9H)C5PK9Mk0F73oUauz7yyVrLRQjq7yzV5H)GL92SQSh(dwz9HF7n9H)C5PK9g(TF73Etf6VDmSJRY2XWEJkxvtG2XYEZd)bl7TXbsfCHZ9HQy3WEdKWH5I(dw2BacdvXUblwUFNfKhhKyvvWElm3tZ52BQRE3e88vbZqP(vywINfLrR9BhxaAhd7nQCvnbAhl7np8hSS3Cqp6pGugBXNu7TqJGMYVpOOhBhxLT3cZ90CU9M6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acSaywAswuWI6Q3nQU2RaLH9SR15F)ku4SpbVid(9acSaywAswuWslwSMfq4BCqp6pGugBXN0mON6OiZFbeUcflkyXAw8WFWY4GE0FaPm2IpPzqp1rrMRYD9HA)zrblTyXAwaHVXb9O)aszSfFsZ7KRn)fq4kuSKKWci8noOh9hqkJT4tAENCTzOu)kmlXZsmzPnljjSacFJd6r)bKYyl(KMb9uhfzWVhqGfaZsmzrblGW34GE0FaPm2IpPzqp1rrMHs9RWSaywqllkybe(gh0J(diLXw8jnd6PokY8xaHRqXsB7nqchMl6pyzV1eyIL4a6r)bKyzZIpPSyzNkw8NfnHXS87EXIvWsSGXjgSGFpGaMfVaz5HSmuFi8ololawjaYc(9acS4yw0(tS4ywIGy8PQjwGdl)LsSCplyil3ZIpZbKWSGuYc)S49NgwCwIjIyb)EabwiKfDdHTF74gt7yyVrLRQjq7yzV5H)GL9wawaHiq5FNY4OBUhBVbs4WCr)bl7TMatSGCybeIaXIL73zb5XbjwvfyXYovSebX4tvtS4filWFNglhMyXY97S4SelyCIblQRENfl7uXciHBuHRqzVfM7P5C7nRzbCwhOPG5aiMffS0ILwSa0NZv1KjalGqeOmiHBubwuWI1SeGqni0szcE(QGzihSbljjSOU6DtWZxfmRiwAZIcwAXI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acSOelnjljjSOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGalkXstYsBwssyrfIXSOGL(HA)ZdL6xHzbWSOmayPT9BhxRWog2Bu5QAc0ow2BE4pyzV1xtJmSNj9Qi7nqchMl6pyzVbiarFwCml)oXs)g8ZcQailxXYVtS4SelyCIblwUceAHf4WIL73z53jwSA0yoVyrD17SahwSC)ololnjIWuGL4a6r)bKyzZIpPS4filw87zPdhwqECqIvvbwUol3ZIfy9SOsSSIyXr5xXIk1HdXYVtSeaz5WS0V6W7eO9wyUNMZT3AXslwAXI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acSeplaAwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwINfanlTzrblTyXAwcqGu51Bas1V3yyjjHfRzrD17MXbsfCHZ9HQy3WSIyPnlTzrblTybCwhOPG5aiMLKewcqOgeAPmbpFvWmuQFfML4zbTaGLKewAXsacKkVEtDO2)C3jwuWsac1GqlLjalGqeO8VtzC0n3JndL6xHzjEwqlayPnlTzPnljjS0Ifq4BCqp6pGugBXN0mON6OiZqP(vywINLMKffSeGqni0szcE(QGzOu)kmlXZIYaGffSeGaPYR3uuyGA4aYsBwssy5QNMiO2Fcm3pu7FEOu)kmlaMLMKffSynlbiudcTuMGNVkygYbBWssclbiqQ86ni0yoVyrblQRE3GWvGdbMP0iOfAsP6nRiwssyjabsLxVbiv)EJHffSOU6DZ4aPcUW5(qvSBygk1VcZcGzbXYIcwux9UzCGubx4CFOk2nmRi73oUO1og2Bu5QAc0ow2BE4pyzVf8kq6S6Q3T3cZ90CU9wlwux9Ur11EfOmSNDTo)7xHcNl)xdzgk1VcZs8SGymOLLKewux9Ur11EfOmSNDTo)7xHcN9j4fzgk1VcZs8SGymOLL2SOGLwSeGqni0szcE(QGzOu)kmlXZcIHLKewAXsac1GqlLHsJGwOjRclqZqP(vywINfedlkyXAwux9UbHRahcmtPrql0Ks1NPIguxSjZkIffSeGaPYR3GqJ58IL2S0MffS44FCDocAHgwIxjwIjaS3ux9EU8uYEd)(OHdO9giHdZf9hSS3qUxbsZY27JgoGSy5(DwCwkYclXcgNyWI6Q3zXlqwqECqIvvbwoCHUNfxfUEwEilQellmbA)2XfqBhd7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9MvFLgXY27dEnOimlwUFNfNLybJtmyrD17SOUEwk4ZILDQyjcc1xHILoCyb5XbjwvfyboSy14kWHazzl6M7X2BH5EAo3ERflQRE3O6AVcug2ZUwN)9RqHZL)RHm43diWs8SaqwssyrD17gvx7vGYWE2168VFfkC2NGxKb)EabwINfaYsBwuWslwcqGu51BQd1(N7oXssclbiudcTuMGNVkygk1VcZs8SGyyjjHfRzbOpNRQjtamhGf49hSyrblwZsacKkVEdcnMZlwssyPflbiudcTugkncAHMSkSandL6xHzjEwqmSOGfRzrD17geUcCiWmLgbTqtkvFMkAqDXMmRiwuWsacKkVEdcnMZlwAZsBwuWslwSMfq4B6RPrg2ZKEvK5VacxHILKewSMLaeQbHwktWZxfmd5GnyjjHfRzjaHAqOLYeGfqicu(3Pmo6M7XMHCWgS02(TJlIXog2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7nR(knILT3h8AqrywuPoCiwqoSacrGS3cZ90CU9wlwcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlaMf0YIcwSMfWzDGMcMdGywuWslwa6Z5QAYeGfqicugKWnQaljjSeGqni0szcE(QGzOu)kmlaMf0YsBwuWcqFoxvtMayoalW7pyXsBwuWI1SacFtFnnYWEM0RIm)fq4kuSOGLaeivE9M6qT)5UtSOGfRzbCwhOPG5aiMffSqb9fHjZvzVAWIcwC8pUohbTqdlXZIvaa73oUnPDmS3OYv1eODSS3Gr2By6T38WFWYEdOpNRQj7nGUEr2BTyrD17MXbsfCHZ9HQy3WmuQFfML4zbTSKKWI1SOU6DZ4aPcUW5(qvSBywrS0MffS0If1vVBq4kWHaZuAe0cnPu9zQOb1fBYmuQFfMfaZcQaOj1rglTzrblTyrD17gkOVimLXqTpMHs9RWSeplOcGMuhzSKKWI6Q3nuqFrykRxLpMHs9RWSeplOcGMuhzS02EdKWH5I(dw2BwDyHUNfq4Zc4AUcfl)oXcvGSa7Sy16aPcUWSaimuf7gOHfW1Cfkwq4kWHazHsJGwOjLQNf4WYvS87elAh)SGkaYcSZIxSG(b9fHj7nG(KlpLS3aHFEi0BDdLs1JTF74IyTJH9gvUQMaTJL9Mh(dw2B4v1VHS3cZ90CU92q9HW7UQMyrblVpOO38xkLFyg8iwINfLb0SOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2oUkB)2Xvzayhd7nQCvnbAhl7np8hSS3sHWQFdzVfM7P5C7TH6dH3DvnXIcwEFqrV5Vuk)Wm4rSeplkhtdAzrblEuoStbeyrbla95CvnzaHFEi0BDdLs1JT3cncAk)(GIESDCv2(TJRYkBhd7nQCvnbAhl7np8hSS3WpP1(K7AFi7TWCpnNBVnuFi8URQjwuWY7dk6n)Ls5hMbpIL4zrzanliILHs9RWSOGfpkh2PacSOGfG(CUQMmGWppe6TUHsP6X2BHgbnLFFqrp2oUkB)2XvzaAhd7nQCvnbAhl7np8hSS36Wjqzypx(VgYEdKWH5I(dw2BacW4YcSyjaYIL73HRNLGhfDfk7TWCpnNBV5r5WofqW(TJRYX0og2Bu5QAc0ow2BE4pyzVrPrql0KvHfO9giHdZf9hSS3q)0iOfAyjwWcKfl7uXIRcxplpKfQEAyXzPilSelyCIblwUceAHfVazb7ajw6WHfKhhKyvvWElm3tZ52BTyHc6lctg9Q8jxeYEwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwssyrD17gvx7vGYWE2168VFfkCU8FnKzOu)kmlXZcIXGwwssyrD17gvx7vGYWE2168VFfkC2NGxKzOu)kmlXZcIXGwwssyXX)46Ce0cnSepliwaWIcwcqOgeAPmbpFvWmKd2GffSynlGZ6anfmhaXS0MffS0ILaeQbHwktWZxfmdL6xHzjEwIjayjjHLaeQbHwktWZxfmd5GnyPnljjSC1tteu7pbM7hQ9ppuQFfMfaZIYaW(TJRYwHDmS3OYv1eODSS38WFWYERVMgzypt6vr2BGeomx0FWYEdqaI(SmhQ9NfvQdhILf(kuSG84yVfM7P5C7TaeQbHwktWZxfmd5Gnyrbla95CvnzcG5aSaV)GflkyPflo(hxNJGwOHL4zbXcawuWI1SeGaPYR3uhQ9p3DILKewcqGu51BQd1(N7oXIcwC8pUohbTqdlaMfRaaS0MffSynlbiqQ86naP63BmSOGLwSynlbiqQ86n1HA)ZDNyjjHLaeQbHwktawaHiq5FNY4OBUhBgYbBWsBwuWI1SaoRd0uWCaeB)2Xvz0Ahd7nQCvnbAhl7nyK9gME7np8hSS3a6Z5QAYEdORxK9M1SaoRd0uWCaeZIcwa6Z5QAYeaZbybE)blwuWslwAXIJ)X15iOfAyjEwqSaGffS0If1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIyjjHfRzjabsLxVbHgZ5flTzjjHf1vVBu1qiOEHFZkIffSOU6DJQgcb1l8Bgk1VcZcGzrD17MGNVkyaxJ)hSyPnljjSC1tteu7pbM7hQ9ppuQFfMfaZI6Q3nbpFvWaUg)pyXssclbiqQ86n1HA)ZDNyPnlkyPflwZsacKkVEtDO2)C3jwssyPflo(hxNJGwOHfaZIvaawssybe(M(AAKH9mPxfz(lGWvOyPnlkyPfla95CvnzcWciebkds4gvGLKewcqOgeAPmbybeIaL)DkJJU5ESzihSblTzPT9giHdZf9hSS3qECqIvvbwSStfl(ZcIfaiIL4GbKS0coAOfAy539IfRaaSehmGKfl3VZcYHfqicuBwSC)oC9SOH4RqXYFPelxXsS0qiOEHFw8cKf9velRiwSC)olihwaHiqSCDwUNfloMfqc3OceO9gqFYLNs2BbWCawG3FWkRc93(TJRYaA7yyVrLRQjq7yzVfM7P5C7nG(CUQMmbWCawG3FWkRc93EZd)bl7TaPj8FUo76dvLs1B)2XvzeJDmS3OYv1eODSS3cZ90CU9gqFoxvtMayoalW7pyLvH(BV5H)GL92vbFk)pyz)2Xv5M0og2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nkOVimzUkRxLpSG4S0KSGew8WFWYGFF63qgczuy9u(VuIfeXI1Sqb9fHjZvz9Q8HfeNLwSaOzbrS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSG4SetwAZcsyXd)blJLX)DdHmkSEk)xkXcIybagaYcsybhrADE3XpzVbs4WCr)bl7n0h)xQ)eMLDOfwsxHDwIdgqYIpelO8RiqwIOHfmfGfO9gqFYLNs2BoocqsZgfSF74QmI1og2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7nR(knILT3h8AqrywSStfl)oXs)qT)SCywCv46z5HSqfiAyPpuf7gSCywCv46z5HSqfiAyPbCXIpel(ZcIfaiIL4GbKSCflEXc6h0xeMqdlipoiXQQalAh)yw8c(70WstIimfWSahwAaxSybU0GSabstWJyjfoel)UxSWjkdawIdgqYILDQyPbCXIf4sdwO7zz79bVguelf0I9wyUNMZT3AXYvpnrqT)eyUFO2)8qP(vywamlwbljjS0If1vVBghivWfo3hQIDdZqP(vywamlOcGMuhzSG4SeOtZslwC8pUohbTqdliHLycawAZIcwux9UzCGubx4CFOk2nmRiwAZsBwssyPflo(hxNJGwOHfeXcqFoxvtghhbiPzJcSG4SOU6Ddf0xeMYyO2hZqP(vywqelGW30xtJmSNj9QiZFbeW5Hs9RybXzbGg0Ys8SOSYaGLKewC8pUohbTqdliIfG(CUQMmoocqsZgfybXzrD17gkOVimL1RYhZqP(vywqelGW30xtJmSNj9QiZFbeW5Hs9RybXzbGg0Ys8SOSYaGL2SOGfkOVimzUk7vdwuWslwSMf1vVBcE(QGzfXssclwZY7AQEd(9rdhqdvUQMazPnlkyPflTyXAwcqOgeAPmbpFvWSIyjjHLaeivE9geAmNxSOGfRzjaHAqOLYqPrql0KvHfOzfXsBwssyjabsLxVPou7FU7elTzrblTyXAwcqGu51Bas1V3yyjjHfRzrD17MGNVkywrSKKWIJ)X15iOfAyjEwqSaGL2SKKWslwExt1BWVpA4aAOYv1eilkyrD17MGNVkywrSOGLwSOU6Dd(9rdhqd(9acSaywIjljjS44FCDocAHgwINfelayPnlTzjjHf1vVBcE(QGzfXIcwSMf1vVBghivWfo3hQIDdZkIffSynlVRP6n43hnCanu5QAc0(TJlabGDmS3OYv1eODSS38WFWYERil5uiSS3ajCyUO)GL9wtGjwaebHfMLRyXkxLpSG(b9fHjw8cKfSdKybPuUUJiaHLwZcGiiSyPdhwqECqIvvb7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKrH1t5)sjwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Pac2VDCbOY2XWEJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfczuy9u(VuIffS0ILaeQbHwktWZxfmdL6xHzjEwqlayjjHLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SGwaWsBwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Pac2BE4pyzVT76Eofcl73oUaeG2XWEJkxvtG2XYElm3tZ52BTyrD17gkOVimL1RYhZqP(vywINfczuy9u(VuIffS0ILaeQbHwktWZxfmdL6xHzjEwqlayjjHLaeQbHwktawaHiq5FNY4OBUhBgk1VcZs8SGwaWsBwssyPflHDFqrywuIfaYIcwgkS7dkk)xkXcGzbTS0MLKewc7(GIWSOelXKL2SOGfpkh2Pac2BE4pyzV1xADofcl73oUamM2XWEJkxvtG2XYEdKWH5I(dw2Bifq0NfyXsa0EZd)bl7nl(mhCYWEM0RISF74cqRWog2Bu5QAc0ow2BE4pyzVHFF63q2BGeomx0FWYERjWelBVp9BiwEilrdmWYgu7dlOFqFryIf4WILDQy5kwGLUblw5Q8Hf0pOVimXIxGSSWelifq0NLObgWSCDwUIfRCv(Wc6h0xeMS3cZ90CU9gf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwssyrD17gl(mhCYWEM0RImRiwuWI6Q3nuqFrykRxLpMveljjS0If1vVBcE(QGzOu)kmlaMfp8hSmwg)3neYOW6P8FPelkyrD17MGNVkywrS02(TJlarRDmS38WFWYEZY4)U9gvUQMaTJL9BhxacOTJH9gvUQMaTJL9Mh(dw2BZQYE4pyL1h(T30h(ZLNs2BDxR)9zz)2V9Mdj7yyhxLTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYERflQRE38xkzbovgCipv9kqAmdL6xHzbWSGkaAsDKXcIybagLzjjHf1vVB(lLSaNkdoKNQEfinMHs9RWSayw8WFWYGFF63qgczuy9u(VuIfeXcamkZIcwAXcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwAZsBwuWI6Q3n)LswGtLbhYtvVcKgZkIffSmRI6Wbfz(lLSaNkdoKNQEfingQCvnbAVbs4WCr)bl7nK76Ws7pHzXYo970WYVtSy1hYtd(h2PHf1vVZILtRzP7AnlWENfl3VFfl)oXsri7zj443EdOp5Ytj7nWH80SLtRZDxRZWE3(TJlaTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEZAwOG(IWK5QmgQ9HffS0IfCeP153hu0Jn43N(nelXZcAzrblVRP6ny4sNH98Vt5oCi8BOYv1eiljjSGJiTo)(GIESb)(0VHyjEwqmS02EdKWH5I(dw2Bi31HL2FcZILD63PHLT3h8AqrSCywSaNFNLGJ)RqXceinSS9(0VHy5kwSYv5dlOFqFryYEdOp5Ytj7TdvbhkJFFWRbfz)2XnM2XWEJkxvtG2XYEZd)bl7TaSacrGY)oLXr3Cp2EdKWH5I(dw2BnbMyb5WciebIfl7uXI)SOjmMLF3lwqlayjoyajlEbYI(kILvelwUFNfKhhKyvvWElm3tZ52BwZc4SoqtbZbqmlkyPflTybOpNRQjtawaHiqzqc3OcSOGfRzjaHAqOLYe88vbZqoydwssyrD17MGNVkywrS0MffS0If1vVBOG(IWuwVkFmdL6xHzjEwa0SKKWI6Q3nuqFrykJHAFmdL6xHzjEwa0S0MffS0IfRzzwf1HdkYO6AVcug2ZUwN)9RqHnu5QAcKLKewux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqGL4zjMSKKWI6Q3nQU2RaLH9SR15F)ku4SpbVid(9acSeplXKL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrzaWIcwSMLaeQbHwktWZxfmd5GnyPT9BhxRWog2Bu5QAc0ow2BE4pyzVnoqQGlCUpuf7g2BGeomx0FWYERjWelacdvXUblwUFNfKhhKyvvWElm3tZ52BQRE3e88vbZqP(vywINfLrR9Bhx0Ahd7nQCvnbAhl7np8hSS3WRQFdzVfAe0u(9bf9y74QS9wyUNMZT3AXYq9HW7UQMyjjHf1vVBOG(IWugd1(ygk1VcZcGzjMSOGfkOVimzUkJHAFyrbldL6xHzbWSOSvWIcwExt1BWWLod75FNYD4q43qLRQjqwAZIcwEFqrV5Vuk)Wm4rSeplkBfS00SGJiTo)(GIEmliILHs9RWSOGLwSqb9fHjZvzVAWsscldL6xHzbWSGkaAsDKXsB7nqchMl6pyzV1eyILTv1VHy5kwI8cKsValWIfVA87xHILF3Fw0hqcZIYwbMcyw8cKfnHXSy5(DwsHdXY7dk6XS4fil(ZYVtSqfilWololBqTpSG(b9fHjw8NfLTcwWuaZcCyrtymldL6xDfkwCmlpKLc(SS7aVcflpKLH6dH3zbCnxHIfRCv(Wc6h0xeMSF74cOTJH9gvUQMaTJL9Mh(dw2B4v1VHS3ajCyUO)GL9wtGjw2wv)gILhYYUdKyXzbLgQ6AwEillmXIvz1Sv3Elm3tZ52Ba95Cvnzo0dmhGf49hSyrblbiudcTuMRWHz9UQMYO3YRFLMbjGxGmd5Gnyrble6TUOic0CfomR3v1ug9wE9R0mib8cK9BhxeJDmS3OYv1eODSS3cZ90CU9M1S8UMQ3GFsR9jdox)nu5QAcKffS0If1vVBWVpDxRnd1hcV7QAIffS0IfCeP153hu0Jn43NUR1SaywIjljjSynlZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGS0MLKewExt1BWWLod75FNYD4q43qLRQjqwuWI6Q3nuqFrykJHAFmdL6xHzbWSetwuWcf0xeMmxLXqTpSOGf1vVBWVpDxRndL6xHzbWSGyyrbl4isRZVpOOhBWVpDxRzjELyXkyPnlkyPflwZYSkQdhuKr3i4JJZDnr)vOYO0xAeMmu5QAcKLKew(lLybPYIvGwwINf1vVBWVpDxRndL6xHzbrSaqwAZIcwEFqrV5Vuk)Wm4rSeplO1EZd)bl7n87t31A73oUnPDmS3OYv1eODSS38WFWYEd)(0DT2EdKWH5I(dw2Bif3VZY2tATpSy1NR)SSWelWILailw2PILH6dH3DvnXI66zb)NwZIf)Ew6WHfRSrWhhZs0adS4filGWcDpllmXIk1HdXcYT6ydlB)P1SSWelQuhoelihwaHiqSGVkqS87(ZILtRzjAGbw8c(70WY27t31A7TWCpnNBV9UMQ3GFsR9jdox)nu5QAcKffSOU6Dd(9P7ATzO(q4DxvtSOGLwSynlZQOoCqrgDJGpoo31e9xHkJsFPryYqLRQjqwssy5VuIfKklwbAzjEwScwAZIcwEFqrV5Vuk)Wm4rSeplX0(TJlI1og2Bu5QAc0ow2BE4pyzVHFF6UwBVbs4WCr)bl7nKI73zXQpKNQEfinSSWelBVpDxRz5HSGarrSSIy53jwux9olQnyX1yill8vOyz79P7AnlWIf0YcMcWceZcCyrtymldL6xDfk7TWCpnNBVnRI6Wbfz(lLSaNkdoKNQEfingQCvnbYIcwWrKwNFFqrp2GFF6UwZs8kXsmzrblTyXAwux9U5VuYcCQm4qEQ6vG0ywrSOGf1vVBWVpDxRnd1hcV7QAILKewAXcqFoxvtgWH80SLtRZDxRZWENffS0If1vVBWVpDxRndL6xHzbWSetwssybhrAD(9bf9yd(9P7AnlXZcazrblVRP6n4N0AFYGZ1FdvUQMazrblQRE3GFF6UwBgk1VcZcGzbTS0ML2S02(TJRYaWog2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nh)JRZrql0Ws8S0KaGLMMLwSOmaybXzrD17M)sjlWPYGd5PQxbsJb)EabwAZstZslwux9Ub)(0DT2muQFfMfeNLyYcsybhrADE3XpXcIZI1S8UMQ3GFsR9jdox)nu5QAcKL2S00S0ILaeQbHwkd(9P7ATzOu)kmliolXKfKWcoI068UJFIfeNL31u9g8tATpzW56VHkxvtGS0MLMMLwSacFtFnnYWEM0RImdL6xHzbXzbTS0MffS0If1vVBWVpDxRnRiwssyjaHAqOLYGFF6UwBgk1VcZsB7nqchMl6pyzVHCxhwA)jmlw2PFNgwCw2EFWRbfXYctSy50Awc(ctSS9(0DTMLhYs31AwG9oAyXlqwwyILT3h8AqrS8qwqGOiwS6d5PQxbsdl43diWYkYEdOp5Ytj7n87t316Sfy95UR1zyVB)2XvzLTJH9gvUQMaTJL9Mh(dw2B43h8Aqr2BGeomx0FWYERjWelBVp41GIyXY97Sy1hYtvVcKgwEiliquelRiw(DIf1vVZIL73HRNfneFfkw2EF6UwZYk6VuIfVazzHjw2EFWRbfXcSyXkqelXcgNyWc(9acyww1FAwScwEFqrp2Elm3tZ52Ba95CvnzahYtZwoTo3DTod7DwuWcqFoxvtg87t316Sfy95UR1zyVZIcwSMfG(CUQMmhQcoug)(GxdkILKewAXI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acSeplXKLKewux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqGL4zjMS0MffSGJiTo)(GIESb)(0DTMfaZIvWIcwa6Z5QAYGFF6UwNTaRp3DTod7D73oUkdq7yyVrLRQjq7yzV5H)GL9Md6r)bKYyl(KAVfAe0u(9bf9y74QS9wyUNMZT3SML)ciCfkwuWI1S4H)GLXb9O)aszSfFsZGEQJImxL76d1(ZssclGW34GE0FaPm2IpPzqp1rrg87beybWSetwuWci8noOh9hqkJT4tAg0tDuKzOu)kmlaMLyAVbs4WCr)bl7TMatSGT4tklyil)U)S0aUybf9SK6iJLv0FPelQnyzHVcfl3ZIJzr7pXIJzjcIXNQMybwSOjmMLF3lwIjl43diGzboSGuYc)SyzNkwIjIyb)EabmleYIUHSF74QCmTJH9gvUQMaTJL9Mh(dw2BPqy1VHS3cncAk)(GIESDCv2Elm3tZ52Bd1hcV7QAIffS8(GIEZFPu(HzWJyjEwAXslwu2kybrS0IfCeP153hu0Jn43N(neliolaKfeNf1vVBOG(IWuwVkFmRiwAZsBwqeldL6xHzPnliHLwSOmliIL31u9M3Yv5uiSWgQCvnbYsBwuWslwcqOgeAPmbpFvWmKd2GffSynlGZ6anfmhaXSOGLwSa0NZv1KjalGqeOmiHBubwssyjaHAqOLYeGfqicu(3Pmo6M7XMHCWgSKKWI1SeGaPYR3uhQ9p3DIL2SKKWcoI0687dk6Xg87t)gIfaZslwAXcGMLMMLwSOU6Ddf0xeMY6v5JzfXcIZcazPnlTzbXzPflkZcIy5DnvV5TCvofclSHkxvtGS0ML2SOGfRzHc6lctgmu7tUiK9SKKWslwOG(IWK5QmgQ9HLKewAXcf0xeMmxLvH)oljjSqb9fHjZvz9Q8HL2SOGfRz5DnvVbdx6mSN)Dk3HdHFdvUQMazjjHf1vVBIMlfoGNRZ(e86c5OLg7JbORxelXRelaeTaGL2SOGLwSGJiTo)(GIESb)(0VHybWSOmaybXzPflkZcIy5DnvV5TCvofclSHkxvtGS0ML2SOGfh)JRZrql0Ws8SGwaWstZI6Q3n43NUR1MHs9RWSG4SaOzPnlkyPflwZI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrSKKWcf0xeMmxLXqTpSKKWI1SeGaPYR3GqJ58IL2SOGfRzrD17MXbsfCHZ9HQy3iJVQV059g4NMZnRi7nqchMl6pyzVz1s9HW7SaiccR(nelxNfKhhKyvvGLdZYqoyd0WYVtdXIpelAcJz539If0YY7dk6XSCflw5Q8Hf0pOVimXIL73zzd(acOHfnHXS87EXIYaGf4VtJLdtSCflE1Gf0pOVimXcCyzfXYdzbTS8(GIEmlQuhoelolw5Q8Hf0pOVimzyXQdl09SmuFi8olGR5kuSy14kWHazb9tJGwOjLQNLvPjmMLRyzdQ9Hf0pOVimz)2XvzRWog2Bu5QAc0ow2BE4pyzV1HtGYWEU8FnK9giHdZf9hSS3AcmXcGamUSalwcGSy5(D46zj4rrxHYElm3tZ52BEuoStbeSF74QmATJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEZAwaN1bAkyoaIzrbla95CvnzcG5aSaV)GflkyPflTyrD17g87t31AZkILKewExt1BWpP1(KbNR)gQCvnbYssclbiqQ86n1HA)ZDNyPnlkyPflwZI6Q3nyOg)xGmRiwuWI1SOU6DtWZxfmRiwuWslwSML31u9M(AAKH9mPxfzOYv1eiljjSOU6DtWZxfmGRX)dwSeplbiudcTuM(AAKH9mPxfzgk1VcZcIyPjzPnlkybOpNRQjZVpNwNXeHanzl(9SOGLwSynlbiqQ86n1HA)ZDNyjjHLaeQbHwktawaHiq5FNY4OBUhBwrSOGLwSOU6Dd(9P7ATzOu)kmlaMfaYssclwZY7AQEd(jT2Nm4C93qLRQjqwAZsBwuWY7dk6n)Ls5hMbpIL4zrD17MGNVkyaxJ)hSybXzbagedlTzjjHfvigZIcw6hQ9ppuQFfMfaZI6Q3nbpFvWaUg)pyXsB7nG(KlpLS3cG5aSaV)Gv2HK9BhxLb02XWEJkxvtG2XYEZd)bl7TaPj8FUo76dvLs1BVbs4WCr)bl7TMatSG84GeRQcSalwcGSSknHXS4fil6RiwUNLvelwUFNfKdlGqei7TWCpnNBVb0NZv1KjaMdWc8(dwzhs2VDCvgXyhd7nQCvnbAhl7TWCpnNBVb0NZv1KjaMdWc8(dwzhs2BE4pyzVDvWNY)dw2VDCvUjTJH9gvUQMaTJL9Mh(dw2BuAe0cnzvybAVbs4WCr)bl7TMatSG(Prql0WsSGfilWILailwUFNLT3NUR1SSIyXlqwWoqILoCybqU0yFyXlqwqECqIvvb7TWCpnNBVD1tteu7pbM7hQ9ppuQFfMfaZIYOLLKewAXI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIfaZcarlayjjHf1vVBIMlfoGNRZ(e86c5OLg7JbORxelXRelaeTaGL2SOGf1vVBWVpDxRnRiwuWslwcqOgeAPmbpFvWmuQFfML4zbTaGLKewaN1bAkyoaIzPT9BhxLrS2XWEJkxvtG2XYEZd)bl7n8tATp5U2hYEl0iOP87dk6X2Xvz7TWCpnNBVnuFi8URQjwuWYFPu(HzWJyjEwugTSOGfCeP153hu0Jn43N(nelaMfRGffS4r5WofqGffS0If1vVBcE(QGzOu)kmlXZIYaGLKewSMf1vVBcE(QGzfXsB7nqchMl6pyzVz1s9HW7S01(qSalwwrS8qwIjlVpOOhZIL73HRNfKhhKyvvGfv6kuS4QW1ZYdzHqw0nelEbYsbFwGaPj4rrxHY(TJlabGDmS3OYv1eODSS38WFWYERVMgzypt6vr2BGeomx0FWYERjWelacq0NLRZYv4dKyXlwq)G(IWelEbYI(kIL7zzfXIL73zXzbqU0yFyjAGbw8cKL4a6r)bKyzZIpP2BH5EAo3EJc6lctMRYE1GffS4r5WofqGffSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSaq0cawuWslwaHVXb9O)aszSfFsZGEQJIm)fq4kuSKKWI1SeGaPYR3uuyGA4aYsscl4isRZVpOOhZs8SaqwAZIcwAXI6Q3nJdKk4cN7dvXUHzOu)kmlaMfellnnlTybTSG4SmRI6WbfzWx1x68Ed8tZ5gQCvnbYsBwuWI6Q3nJdKk4cN7dvXUHzfXssclwZI6Q3nJdKk4cN7dvXUHzfXsBwuWslwSMLaeQbHwktWZxfmRiwssyrD17MFFoToJjcbAm43diWcGzrz0YIcw6hQ9ppuQFfMfaZcabaayrbl9d1(Nhk1VcZs8SOmaaaljjSynly4sREfO53NtRZyIqGgdvUQMazPnlkyPfly4sREfO53NtRZyIqGgdvUQMazjjHLaeQbHwktWZxfmdL6xHzjEwIjayPT9BhxaQSDmS3OYv1eODSS38WFWYEd)(0DT2EdKWH5I(dw2BnbMyXzz79P7AnlaIl63zjAGbwwLMWyw2EF6UwZYHzX1d5GnyzfXcCyPbCXIpelUkC9S8qwGaPj4rSehmG0Elm3tZ52BQRE3al63X5iAcu0FWYSIyrblTyrD17g87t31AZq9HW7UQMyjjHfh)JRZrql0Ws8SGybalTTF74cqaAhd7nQCvnbAhl7np8hSS3WVpDxRT3ajCyUO)GL9MvFLgXsCWaswuPoCiwqoSacrGyXY97SS9(0DTMfVaz53PILT3h8Aqr2BH5EAo3ElabsLxVPou7FU7elkyXAwExt1BWpP1(KbNR)gQCvnbYIcwAXcqFoxvtMaSacrGYGeUrfyjjHLaeQbHwktWZxfmRiwssyrD17MGNVkywrS0MffSeGqni0szcWciebk)7ughDZ9yZqP(vywamlOcGMuhzSG4SeOtZslwC8pUohbTqdliHf0cawAZIcwux9Ub)(0DT2muQFfMfaZIvWIcwSMfWzDGMcMdGy73oUamM2XWEJkxvtG2XYElm3tZ52BbiqQ86n1HA)ZDNyrblTybOpNRQjtawaHiqzqc3OcSKKWsac1GqlLj45RcMveljjSOU6DtWZxfmRiwAZIcwcqOgeAPmbybeIaL)DkJJU5ESzOu)kmlaMfanlkyrD17g87t31AZkIffSqb9fHjZvzVAWIcwSMfG(CUQMmhQcoug)(GxdkIffSynlGZ6anfmhaX2BE4pyzVHFFWRbfz)2XfGwHDmS3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2BnbMyz79bVguelwUFNfVybqCr)olrdmWcCy56S0aUqhilqG0e8iwIdgqYIL73zPbCnSueYEwco(nSehngYc4knIL4GbKS4pl)oXcvGSa7S87eliLP63BmSOU6DwUolBVpDxRzXcCPbl09S0DTMfyVZcCyPbCXIpelWIfaYY7dk6X2BH5EAo3EtD17gyr)ooh0KpzGh(GLzfXssclTyXAwWVp9BiJhLd7uabwuWI1Sa0NZv1K5qvWHY43h8AqrSKKWslwux9Uj45RcMHs9RWSaywqllkyrD17MGNVkywrSKKWslwAXI6Q3nbpFvWmuQFfMfaZcQaOj1rgliolb60S0Ifh)JRZrql0WcsyjMaGL2SOGf1vVBcE(QGzfXssclQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzOu)kmlaMfubqtQJmwqCwc0PzPflo(hxNJGwOHfKWsmbalTzrblQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzfXsBwuWsacKkVEdqQ(9gdlTzPnlkyPfl4isRZVpOOhBWVpDxRzbWSetwssybOpNRQjd(9P7AD2cS(C316mS3zPnlTzrblwZcqFoxvtMdvbhkJFFWRbfXIcwAXI1SmRI6Wbfz(lLSaNkdoKNQEfingQCvnbYsscl4isRZVpOOhBWVpDxRzbWSetwAB)2XfGO1og2Bu5QAc0ow2BE4pyzVvKLCkew2BGeomx0FWYERjWelaIGWcZYvSSb1(Wc6h0xeMyXlqwWoqIfaHLwZcGiiSyPdhwqECqIvvb7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiJcRNY)LsSKKWslwc7(GIWSOelaKffSmuy3huu(VuIfaZcAzPnljjSe29bfHzrjwIjlTzrblEuoStbeSF74cqaTDmS3OYv1eODSS3cZ90CU9wlwux9UHc6lctzmu7JzOu)kmlXZcHmkSEk)xkXssclTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjMS0MffS4r5WofqGffS0If1vVBghivWfo3hQIDdZqP(vywamlOLffSOU6DZ4aPcUW5(qvSBywrSOGfRzzwf1HdkYGVQV059g4NMZnu5QAcKLKewSMf1vVBghivWfo3hQIDdZkIL22BE4pyzVT76Eofcl73oUaeXyhd7nQCvnbAhl7TWCpnNBV1If1vVBOG(IWugd1(ygk1VcZs8SqiJcRNY)LsSOGLwSeGqni0szcE(QGzOu)kmlXZcAbaljjSeGqni0szcWciebk)7ughDZ9yZqP(vywINf0cawAZssclTyjS7dkcZIsSaqwuWYqHDFqr5)sjwamlOLL2SKKWsy3hueMfLyjMS0MffS4r5WofqGffS0If1vVBghivWfo3hQIDdZqP(vywamlOLffSOU6DZ4aPcUW5(qvSBywrSOGfRzzwf1HdkYGVQV059g4NMZnu5QAcKLKewSMf1vVBghivWfo3hQIDdZkIL22BE4pyzV1xADofcl73oUaSjTJH9gvUQMaTJL9giHdZf9hSS3AcmXcsbe9zbwSGCRU9Mh(dw2Bw8zo4KH9mPxfz)2XfGiw7yyVrLRQjq7yzVbJS3W0BV5H)GL9gqFoxvt2BaD9IS3WrKwNFFqrp2GFF63qSeplwbliILUgchwAXsQJFAAKb66fXcIZIYaaaSGewaiayPnliILUgchwAXI6Q3n43h8AqrzkncAHMuQ(mgQ9XGFpGaliHfRGL22BGeomx0FWYEd5UoS0(tywSSt)onS8qwwyILT3N(nelxXYgu7dlw2VWolhMf)zbTS8(GIEmIuMLoCyHastdwaiaqQSK64NMgSahwScw2EFWRbfXc6NgbTqtkvpl43diGT3a6tU8uYEd)(0VHYxLXqTp2VDCJjaSJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEtzwqcl4isRZ7o(jwamlaKLMMLwSaadazbXzPfl4isRZVpOOhBWVp9BiwAAwuML2SG4S0IfLzbrS8UMQ3GHlDg2Z)oL7WHWVHkxvtGSG4SOSbTS0ML2SGiwaGrz0YcIZI6Q3nJdKk4cN7dvXUHzOu)kS9giHdZf9hSS3qURdlT)eMfl70VtdlpKfKIX)DwaxZvOybqyOk2nS3a6tU8uYEZY4)E(QCFOk2nSF74gtLTJH9gvUQMaTJL9Mh(dw2Bwg)3T3ajCyUO)GL9wtGjwqkg)3z5kw2GAFyb9d6lctSahwUolfKLT3N(nelwoTML(9SC1dzb5XbjwvfyXRgPWHS3cZ90CU9wlwOG(IWKrVkFYfHSNLKewOG(IWKXRg5Iq2ZIcwa6Z5QAYC4CqtoqIL2SOGLwS8(GIEZFPu(HzWJyjEwScwssyHc6lctg9Q8jFvgGSKKWs)qT)5Hs9RWSaywugaS0MLKewux9UHc6lctzmu7JzOu)kmlaMfp8hSm43N(nKHqgfwpL)lLyrblQRE3qb9fHPmgQ9XSIyjjHfkOVimzUkJHAFyrblwZcqFoxvtg87t)gkFvgd1(WssclQRE3e88vbZqP(vywamlE4pyzWVp9BidHmkSEk)xkXIcwSMfG(CUQMmhoh0KdKyrblQRE3e88vbZqP(vywamleYOW6P8FPelkyrD17MGNVkywrSKKWI6Q3nJdKk4cN7dvXUHzfXIcwa6Z5QAYyz8FpFvUpuf7gSKKWI1Sa0NZv1K5W5GMCGelkyrD17MGNVkygk1VcZs8SqiJcRNY)Ls2VDCJjaTJH9gvUQMaTJL9giHdZf9hSS3AcmXY27t)gILRZYvSyLRYhwq)G(IWeAy5kw2GAFyb9d6lctSalwSceXY7dk6XSahwEilrdmWYgu7dlOFqFryYEZd)bl7n87t)gY(TJBmJPDmS3OYv1eODSS3ajCyUO)GL9gGGR1)(SS38WFWYEBwv2d)bRS(WV9M(WFU8uYER7A9Vpl73(T36Uw)7ZYog2Xvz7yyVrLRQjq7yzV5H)GL9g(9bVguK9giHdZf9hSS32EFWRbfXshoSKcbsPu9SSknHXSSWxHILybJtmS3cZ90CU9M1SmRI6WbfzuDTxbkd7zxRZ)(vOWgc9wxuebA)2XfG2XWEJkxvtG2XYEZd)bl7n8Q63q2BHgbnLFFqrp2oUkBVfM7P5C7nq4BsHWQFdzgk1VcZs8SmuQFfMfeNfacqwqclk3K2BGeomx0FWYEd5o(z53jwaHplwUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9gw2wv)gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQFdXc4A8)GL9Bh3yAhd7np8hSS3sHWQFdzVrLRQjq7yz)2V9g(TJHDCv2og2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7TMatSS9(GxdkILhYccefXYkILFNyXQpKNQEfinSOU6DwUol3ZIf4sdYcHSOBiwuPoCiw6xD49RqXYVtSueYEwco(zboS8qwaxPrSOsD4qSGCybeIazVfM7P5C7TzvuhoOiZFPKf4uzWH8u1RaPXqLRQjqwuWslwOG(IWK5QSxnyrblwZslwAXI6Q3n)LswGtLbhYtvVcKgZqP(vywINfp8hSmwg)3neYOW6P8FPeliIfayuMffS0IfkOVimzUkRc)DwssyHc6lctMRYyO2hwssyHc6lctg9Q8jxeYEwAZssclQRE38xkzbovgCipv9kqAmdL6xHzjEw8WFWYGFF63qgczuy9u(VuIfeXcamkZIcwAXcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwAZsBwssyXAwux9U5VuYcCQm4qEQ6vG0ywrS0MLKewAXI6Q3nbpFvWSIyjjHfG(CUQMmbybeIaLbjCJkWsBwuWsac1GqlLjalGqeO8VtzC0n3Jnd5GnyrblbiqQ86n1HA)ZDNyPnlkyPflwZsacKkVEdcnMZlwssyjaHAqOLYqPrql0KvHfOzOu)kmlXZstYsBwuWslwux9Uj45RcMveljjSynlbiudcTuMGNVkygYbBWsB73oUa0og2Bu5QAc0ow2BE4pyzV5GE0FaPm2IpP2BHgbnLFFqrp2oUkBVfM7P5C7nRzbe(gh0J(diLXw8jnd6PokY8xaHRqXIcwSMfp8hSmoOh9hqkJT4tAg0tDuK5QCxFO2FwuWslwSMfq4BCqp6pGugBXN08o5AZFbeUcfljjSacFJd6r)bKYyl(KM3jxBgk1VcZs8SGwwAZssclGW34GE0FaPm2IpPzqp1rrg87beybWSetwuWci8noOh9hqkJT4tAg0tDuKzOu)kmlaMLyYIcwaHVXb9O)aszSfFsZGEQJIm)fq4ku2BGeomx0FWYERjWelXb0J(diXYMfFszXYovS870qSCywkilE4pGelyl(KIgwCmlA)jwCmlrqm(u1elWIfSfFszXY97SaqwGdlDYcnSGFpGaMf4WcSyXzjMiIfSfFszbdz539NLFNyPilSGT4tkl(mhqcZcsjl8ZI3FAy539NfSfFszHqw0ne2(TJBmTJH9gvUQMaTJL9Mh(dw2BbybeIaL)DkJJU5ES9giHdZf9hSS3AcmHzb5WciebILRZcYJdsSQkWYHzzfXcCyPbCXIpelGeUrfUcflipoiXQQalwUFNfKdlGqeiw8cKLgWfl(qSOsAOfwScaWsCWas7TWCpnNBVznlGZ6anfmhaXSOGLwS0IfG(CUQMmbybeIaLbjCJkWIcwSMLaeQbHwktWZxfmd5GnyrblwZYSkQdhuKjAUu4aEUo7tWRlKJwASpgQCvnbYssclQRE3e88vbZkIL2SOGfh)JRZrql0WcGvIfRaaSOGLwSOU6Ddf0xeMY6v5JzOu)kmlXZIYaGLKewux9UHc6lctzmu7JzOu)kmlXZIYaGL2SKKWIkeJzrbl9d1(Nhk1VcZcGzrzaWIcwSMLaeQbHwktWZxfmd5GnyPT9BhxRWog2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7TwSOU6DZ4aPcUW5(qvSBygk1VcZs8SGwwssyXAwux9UzCGubx4CFOk2nmRiwAZIcwSMf1vVBghivWfo3hQIDJm(Q(sN3BGFAo3SIyrblTyrD17geUcCiWmLgbTqtkvFMkAqDXMmdL6xHzbWSGkaAsDKXsBwuWslwux9UHc6lctzmu7JzOu)kmlXZcQaOj1rgljjSOU6Ddf0xeMY6v5JzOu)kmlXZcQaOj1rgljjS0IfRzrD17gkOVimL1RYhZkILKewSMf1vVBOG(IWugd1(ywrS0MffSynlVRP6nyOg)xGmu5QAcKL22BGeomx0FWYEd5Wc8(dwS0HdlUwZci8XS87(ZsQJaHzbVgILFNAWIpuHUNLH6dH3jqwSStflwToqQGlmlacdvXUbl7oMfnHXS87EXcAzbtbmldL6xDfkwGdl)oXccnMZlwux9olhMfxfUEwEilDxRzb27Sahw8QblOFqFryILdZIRcxplpKfczr3q2Ba9jxEkzVbc)8qO36gkLQhB)2XfT2XWEJkxvtG2XYEdgzVHP3EZd)bl7nG(CUQMS3a66fzV1IfRzrD17gkOVimLXqTpMvelkyXAwux9UHc6lctz9Q8XSIyPnljjS8UMQ3GHA8FbYqLRQjq7nqchMl6pyzVHCybE)blw(D)zjStbeWSCDwAaxS4dXcC94dKyHc6lctS8qwGLUblGWNLFNgIf4WYHQGdXYVFywSC)olBqn(VazVb0NC5PK9gi8ZW1Jpqktb9fHj73oUaA7yyVrLRQjq7yzV5H)GL9wkew9Bi7TWCpnNBVnuFi8URQjwuWslwux9UHc6lctzmu7JzOu)kmlXZYqP(vywssyrD17gkOVimL1RYhZqP(vywINLHs9RWSKKWcqFoxvtgq4NHRhFGuMc6lctS0MffSmuFi8URQjwuWY7dk6n)Ls5hMbpIL4zrzaYIcw8OCyNciWIcwa6Z5QAYac)8qO36gkLQhBVfAe0u(9bf9y74QS9BhxeJDmS3OYv1eODSS38WFWYEdVQ(nK9wyUNMZT3gQpeE3v1elkyPflQRE3qb9fHPmgQ9XmuQFfML4zzOu)kmljjSOU6Ddf0xeMY6v5JzOu)kmlXZYqP(vywssybOpNRQjdi8ZW1Jpqktb9fHjwAZIcwgQpeE3v1elky59bf9M)sP8dZGhXs8SOmazrblEuoStbeyrbla95CvnzaHFEi0BDdLs1JT3cncAk)(GIESDCv2(TJBtAhd7nQCvnbAhl7np8hSS3WpP1(K7AFi7TWCpnNBVnuFi8URQjwuWslwux9UHc6lctzmu7JzOu)kmlXZYqP(vywssyrD17gkOVimL1RYhZqP(vywINLHs9RWSKKWcqFoxvtgq4NHRhFGuMc6lctS0MffSmuFi8URQjwuWY7dk6n)Ls5hMbpIL4zrzanlkyXJYHDkGalkybOpNRQjdi8ZdHERBOuQES9wOrqt53hu0JTJRY2VDCrS2XWEJkxvtG2XYEZd)bl7ToCcug2ZL)RHS3ajCyUO)GL9wtGjwaeGXLfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkGG9BhxLbGDmS3OYv1eODSS38WFWYEJsJGwOjRclq7nqchMl6pyzV1eyIfRgxboeilBr3CpMfl3VZIxnyrdluSqfCHANfTJ)RqXc6h0xeMyXlqw(PblpKf9vel3ZYkIfl3VZcGCPX(WIxGSG84GeRQc2BH5EAo3ERflTyrD17gkOVimLXqTpMHs9RWSeplkdawssyrD17gkOVimL1RYhZqP(vywINfLbalTzrblbiudcTuMGNVkygk1VcZs8SetaWIcwAXI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lIfaZcaTcaWssclwZYSkQdhuKjAUu4aEUo7tWRlKJwASpgc9wxuebYsBwAZssclQRE3enxkCapxN9j41fYrln2hdqxViwIxjwaiIbaSKKWsac1GqlLj45RcMHCWgSOGfh)JRZrql0Ws8SGybG9BhxLv2og2Bu5QAc0ow2BWi7nm92BE4pyzVb0NZv1K9gqxVi7nRzbCwhOPG5aiMffSa0NZv1KjaMdWc8(dwSOGLwS0ILaeQbHwkdLg1yixNHdy5vGmdL6xHzbWSOmGgXWcIyPflkRmliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0MffSqO36IIiqdLg1yixNHdy5vGyPnljjS44FCDocAHgwIxjwqSaGffS0IfRz5DnvVPVMgzypt6vrgQCvnbYssclQRE3e88vbd4A8)GflXZsac1GqlLPVMgzypt6vrMHs9RWSGiwAswAZIcwaHVbVQ(nKzOu)kmlXZIYaKffSacFtkew9BiZqP(vywINLMKffS0Ifq4BWpP1(K7AFiZqP(vywINLMKLKewSML31u9g8tATp5U2hYqLRQjqwAZIcwa6Z5QAY87ZP1zmriqt2IFplkyPflQRE3GWvGdbMP0iOfAsP6ZurdQl2KzfXssclwZsacKkVEdcnMZlwAZIcwEFqrV5Vuk)Wm4rSeplQRE3e88vbd4A8)GfliolaWGyyjjHfvigZIcw6hQ9ppuQFfMfaZI6Q3nbpFvWaUg)pyXssclbiqQ86n1HA)ZDNyjjHf1vVBu1qiOEHFZkIffSOU6DJQgcb1l8Bgk1VcZcGzrD17MGNVkyaxJ)hSybrS0IfelliolZQOoCqrMO5sHd456SpbVUqoAPX(yi0BDrreilTzPnlkyXAwux9Uj45RcMvelkyPflwZsacKkVEtDO2)C3jwssyjaHAqOLYeGfqicu(3Pmo6M7XMveljjSOcXywuWs)qT)5Hs9RWSaywcqOgeAPmbybeIaL)DkJJU5ESzOu)kmliIfanljjS0pu7FEOu)kmlivwuUjbalaMf1vVBcE(QGbCn(FWIL22BGeomx0FWYERjWelipoiXQQalwUFNfKdlGqeiKy14kWHazzl6M7XS4filGWcDplqG0yzUNybqU0yFyboSyzNkwILgcb1l8ZIf4sdYcHSOBiwuPoCiwqECqIvvbwiKfDdHT3a6tU8uYElaMdWc8(dwz8B)2XvzaAhd7nQCvnbAhl7np8hSS3ghivWfo3hQIDd7nqchMl6pyzV1eyILFNybPmv)EJHfl3VZIZcYJdsSQkWYV7plhUq3ZsFGPSaixASp2BH5EAo3EtD17MGNVkygk1VcZs8SOmAzjjHf1vVBcE(QGbCn(FWIfaZsmbalkybOpNRQjtamhGf49hSY43(TJRYX0og2Bu5QAc0ow2BH5EAo3EdOpNRQjtamhGf49hSY4NffS0IfRzrD17MGNVkyaxJ)hSyjEwIjayjjHfRzjabsLxVbiv)EJHL2SKKWI6Q3nJdKk4cN7dvXUHzfXIcwux9UzCGubx4CFOk2nmdL6xHzbWSGyzbrSeGf46Et0qHdtzxFOQuQEZFPugORxeliILwSynlQRE3OQHqq9c)MvelkyXAwExt1BWVpA4aAOYv1eilTT38WFWYElqAc)NRZU(qvPu92VDCv2kSJH9gvUQMaTJL9wyUNMZT3a6Z5QAYeaZbybE)bRm(T38WFWYE7QGpL)hSSF74QmATJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEZAwcqOgeAPmbpFvWmKd2GLKewSMfG(CUQMmbybeIaLbjCJkWIcwcqGu51BQd1(N7oXssclGZ6anfmhaX2BGeomx0FWYEdPSpNRQjwwycKfyXIRE67pcZYV7plw86z5HSOsSGDGeilD4WcYJdsSQkWcgYYV7pl)o1GfFO6zXIJFcKfKsw4NfvQdhILFNsT3a6tU8uYEd7aPCho5GNVky)2XvzaTDmS3OYv1eODSS38WFWYERVMgzypt6vr2BGeomx0FWYERjWeMfabi6ZY1z5kw8If0pOVimXIxGS8ZrywEil6RiwUNLvelwUFNfa5sJ9bnSG84GeRQcS4filXb0J(diXYMfFsT3cZ90CU9gf0xeMmxL9QblkyXJYHDkGalkyrD17MO5sHd456SpbVUqoAPX(ya66fXcGzbGwbayrblTybe(gh0J(diLXw8jnd6PokY8xaHRqXssclwZsacKkVEtrHbQHdilTzrbla95CvnzWoqk3Hto45RcSOGLwSOU6DZ4aPcUW5(qvSBygk1VcZcGzbXYstZslwqlliolZQOoCqrg8v9LoV3a)0CUHkxvtGS0MffSOU6DZ4aPcUW5(qvSBywrSKKWI1SOU6DZ4aPcUW5(qvSBywrS02(TJRYig7yyVrLRQjq7yzV5H)GL9g(9P7AT9giHdZf9hSS3AcmXcG4I(Dw2EF6UwZs0adywUolBVpDxRz5Wf6Ewwr2BH5EAo3EtD17gyr)oohrtGI(dwMvelkyrD17g87t31AZq9HW7UQMSF74QCtAhd7nQCvnbAhl7TWCpnNBVPU6Dd(9rdhqZqP(vywamlOLffS0If1vVBOG(IWugd1(ygk1VcZs8SGwwssyrD17gkOVimL1RYhZqP(vywINf0YsBwuWIJ)X15iOfAyjEwqSaWEZd)bl7TGxbsNvx9U9M6Q3ZLNs2B43hnCaTF74QmI1og2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7nR(kncZsCWaswuPoCiwqoSacrGyzHVcfl)oXcYHfqicelbybE)blwEilHDkGalxNfKdlGqeiwomlE4xUw3GfxfUEwEilQelbh)2BH5EAo3ElabsLxVPou7FU7elkybOpNRQjtawaHiqzqc3OcSOGLaeQbHwktawaHiq5FNY4OBUhBgk1VcZcGzbTSOGfRzbCwhOPG5aiMffSqb9fHjZvzVAWIcwC8pUohbTqdlXZIvaa73oUaea2XWEJkxvtG2XYEZd)bl7n87t31A7nqchMl6pyzV1eyILT3NUR1Sy5(Dw2EsR9HfR(C9NfVazPGSS9(OHdiAyXYovSuqw2EF6UwZYHzzfHgwAaxS4dXYvSyLRYhwq)G(IWelD4WstIimfWSahwEilrdmWcGCPX(WILDQyXvHajwqSaGL4GbKSahwCWi)pGelyl(KYYUJzPjreMcywgk1V6kuSahwomlxXsxFO2FdlXf(el)U)SSkqAy53jwWEkXsawG3FWcZY9OdZcyeMLIw)4AwEilBVpDxRzbCnxHIfRwhivWfMfaHHQy3anSyzNkwAaxOdKf8FAnlubYYkIfl3VZcIfaiYXrS0Hdl)oXI2XplO0qvxJn2BH5EAo3E7DnvVb)Kw7tgCU(BOYv1eilkyXAwExt1BWVpA4aAOYv1eilkyrD17g87t31AZq9HW7UQMyrblTyrD17gkOVimL1RYhZqP(vywINLMKffSqb9fHjZvz9Q8HffSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSaq0cawssyrD17MO5sHd456SpbVUqoAPX(ya66fXs8kXcarlayrblo(hxNJGwOHL4zbXcawssybe(gh0J(diLXw8jnd6PokYmuQFfML4zPjzjjHfp8hSmoOh9hqkJT4tAg0tDuK5QCxFO2FwAZIcwcqOgeAPmbpFvWmuQFfML4zrzay)2XfGkBhd7nQCvnbAhl7np8hSS3WVp41GIS3ajCyUO)GL9wtGjw2EFWRbfXcG4I(DwIgyaZIxGSaUsJyjoyajlw2PIfKhhKyvvGf4WYVtSGuMQFVXWI6Q3z5WS4QW1ZYdzP7AnlWENf4Wsd4cDGSe8iwIdgqAVfM7P5C7n1vVBGf974Cqt(KbE4dwMveljjSOU6DdcxboeyMsJGwOjLQptfnOUytMveljjSOU6DtWZxfmRiwuWslwux9UzCGubx4CFOk2nmdL6xHzbWSGkaAsDKXcIZsGonlTyXX)46Ce0cnSGewIjayPnliILyYcIZY7AQEtrwYPqyzOYv1eilkyXAwMvrD4GIm4R6lDEVb(P5CdvUQMazrblQRE3moqQGlCUpuf7gMveljjSOU6DtWZxfmdL6xHzbWSGkaAsDKXcIZsGonlTyXX)46Ce0cnSGewIjayPnljjSOU6DZ4aPcUW5(qvSBKXx1x68Ed8tZ5MveljjS0If1vVBghivWfo3hQIDdZqP(vywamlE4pyzWVp9BidHmkSEk)xkXIcwWrKwN3D8tSaywaGXkyjjHf1vVBghivWfo3hQIDdZqP(vywamlE4pyzSm(VBiKrH1t5)sjwssybOpNRQjZHEG5aSaV)GflkyjaHAqOLYCfomR3v1ug9wE9R0mib8cKzihSblkyHqV1ffrGMRWHz9UQMYO3YRFLMbjGxGyPnlkyrD17MXbsfCHZ9HQy3WSIyjjHfRzrD17MXbsfCHZ9HQy3WSIyrblwZsac1GqlLzCGubx4CFOk2nmd5GnyjjHfRzjabsLxVbiv)EJHL2SKKWIJ)X15iOfAyjEwqSaGffSqb9fHjZvzVAy)2XfGa0og2Bu5QAc0ow2BE4pyzVHFFWRbfzVbs4WCr)bl7Tymny5HSK6iqS87elQe(zb2zz79rdhqwuBWc(9acxHIL7zzfXc6TUac6gSCflE1Gf0pOVimXI66zbqU0yFy5W1ZIRcxplpKfvILObgceO9wyUNMZT3Ext1BWVpA4aAOYv1eilkyXAwMvrD4GIm)LswGtLbhYtvVcKgdvUQMazrblTyrD17g87JgoGMveljjS44FCDocAHgwINfelayPnlkyrD17g87JgoGg87beybWSetwuWslwux9UHc6lctzmu7JzfXssclQRE3qb9fHPSEv(ywrS0MffSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSaqedayrblTyjaHAqOLYe88vbZqP(vywINfLbaljjSynla95CvnzcWciebkds4gvGffSeGaPYR3uhQ9p3DIL22VDCbymTJH9gvUQMaTJL9gmYEdtV9Mh(dw2Ba95CvnzVb01lYEJc6lctMRY6v5dliolnjliHfp8hSm43N(nKHqgfwpL)lLybrSynluqFryYCvwVkFybXzPflaAwqelVRP6ny4sNH98Vt5oCi8BOYv1eiliolXKL2SGew8WFWYyz8F3qiJcRNY)LsSGiwaGXkqlliHfCeP15Dh)eliIfayqlliolVRP6nL)RHWzvx7vGmu5QAc0EdKWH5I(dw2BOp(Vu)jml7qlSKUc7SehmGKfFiwq5xrGSerdlykalq7nG(KlpLS3CCeGKMnky)2XfGwHDmS3OYv1eODSS38WFWYEd)(GxdkYEdKWH5I(dw2Bw9vAelBVp41GIy5kwCwqmictbw2GAFyb9d6lctOHfqyHUNfn9SCplrdmWcGCPX(WsRF3Fwoml7EbQjqwuBWcD)onS87elBVpDxRzrFfXcCy53jwIdgqgpIfaSOVIyPdhw2EFWRbf1gnSacl09SabsJL5EIfVybqCr)olrdmWIxGSOPNLFNyXvHajw0xrSS7fOMyz79rdhq7TWCpnNBVznlZQOoCqrM)sjlWPYGd5PQxbsJHkxvtGSOGLwSOU6Dt0CPWb8CD2NGxxihT0yFmaD9IybWSaqedayjjHf1vVBIMlfoGNRZ(e86c5OLg7JbORxelaMfaIwaWIcwExt1BWpP1(KbNR)gQCvnbYsBwuWslwOG(IWK5QmgQ9HffS44FCDocAHgwqela95CvnzCCeGKMnkWcIZI6Q3nuqFrykJHAFmdL6xHzbrSacFtFnnYWEM0RIm)fqaNhk1VIfeNfaAqllXZstcawssyHc6lctMRY6v5dlkyXX)46Ce0cnSGiwa6Z5QAY44iajnBuGfeNf1vVBOG(IWuwVkFmdL6xHzbrSacFtFnnYWEM0RIm)fqaNhk1VIfeNfaAqllXZcIfaS0MffSynlQRE3al63X5iAcu0FWYSIyrblwZY7AQEd(9rdhqdvUQMazrblTyjaHAqOLYe88vbZqP(vywINfedljjSGHlT6vGMFFoToJjcbAmu5QAcKffSOU6DZVpNwNXeHang87beybWSeZyYstZslwMvrD4GIm4R6lDEVb(P5CdvUQMazbXzbTS0MffS0pu7FEOu)kmlXZIYaaaSOGL(HA)ZdL6xHzbWSaqaaawAZIcwAXsac1GqlLbHRahcmJJU5ESzOu)kmlXZcIHLKewSMLaeivE9geAmNxS02(TJlarRDmS3OYv1eODSS38WFWYERil5uiSS3ajCyUO)GL9wtGjwaebHfMLRyXkxLpSG(b9fHjw8cKfSdKybPuUUJiaHLwZcGiiSyPdhwqECqIvvbw8cKfRgxboeilOFAe0cnPu92BH5EAo3ERflQRE3qb9fHPSEv(ygk1VcZs8SqiJcRNY)LsSKKWslwc7(GIWSOelaKffSmuy3huu(VuIfaZcAzPnljjSe29bfHzrjwIjlTzrblEuoStbeyrbla95CvnzWoqk3Hto45Rc2VDCbiG2og2Bu5QAc0ow2BH5EAo3ERflQRE3qb9fHPSEv(ygk1VcZs8SqiJcRNY)LsSOGfRzjabsLxVbHgZ5fljjS0If1vVBq4kWHaZuAe0cnPu9zQOb1fBYSIyrblbiqQ86ni0yoVyPnljjS0ILWUpOimlkXcazrbldf29bfL)lLybWSGwwAZssclHDFqrywuILyYssclQRE3e88vbZkIL2SOGfpkh2PacSOGfG(CUQMmyhiL7Wjh88vbwuWslwux9UzCGubx4CFOk2nmdL6xHzbWS0If0YstZcazbXzzwf1HdkYGVQV059g4NMZnu5QAcKL2SOGf1vVBghivWfo3hQIDdZkILKewSMf1vVBghivWfo3hQIDdZkIL22BE4pyzVT76Eofcl73oUaeXyhd7nQCvnbAhl7TWCpnNBV1If1vVBOG(IWuwVkFmdL6xHzjEwiKrH1t5)sjwuWI1SeGaPYR3GqJ58ILKewAXI6Q3niCf4qGzkncAHMuQ(mv0G6InzwrSOGLaeivE9geAmNxS0MLKewAXsy3hueMfLybGSOGLHc7(GIY)LsSaywqllTzjjHLWUpOimlkXsmzjjHf1vVBcE(QGzfXsBwuWIhLd7uabwuWcqFoxvtgSdKYD4KdE(QalkyPflQRE3moqQGlCUpuf7gMHs9RWSaywqllkyrD17MXbsfCHZ9HQy3WSIyrblwZYSkQdhuKbFvFPZ7nWpnNBOYv1eiljjSynlQRE3moqQGlCUpuf7gMvelTT38WFWYERV06Ckew2VDCbytAhd7nQCvnbAhl7nqchMl6pyzV1eyIfKci6ZcSyjaAV5H)GL9MfFMdozypt6vr2VDCbiI1og2Bu5QAc0ow2BE4pyzVHFF63q2BGeomx0FWYERjWelBVp9BiwEilrdmWYgu7dlOFqFrycnSG84GeRQcSS7yw0egZYFPel)UxS4SGum(VZcHmkSEIfn1FwGdlWs3GfRCv(Wc6h0xeMy5WSSIS3cZ90CU9gf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmE1ixeYEwssyPflQRE3yXN5Gtg2ZKEvKzfXsscl4isRZ7o(jwamlaWyfOLffSynlbiqQ86naP63BmSKKWcoI068UJFIfaZcamwblkyjabsLxVbiv)EJHL2SOGf1vVBOG(IWuwVkFmRiwssyPflQRE3e88vbZqP(vywamlE4pyzSm(VBiKrH1t5)sjwuWI6Q3nbpFvWSIyPT9Bh3yca7yyVrLRQjq7yzVbs4WCr)bl7TMatSGum(VZc83PXYHjwSSFHDwomlxXYgu7dlOFqFrycnSG84GeRQcSahwEilrdmWIvUkFyb9d6lct2BE4pyzVzz8F3(TJBmv2og2Bu5QAc0ow2BGeomx0FWYEdqW16FFw2BE4pyzVnRk7H)GvwF43EtF4pxEkzV1DT(3NL9B)2BrdfGPQ(Bhd74QSDmS38WFWYEdHRahcmJJU5ES9gvUQMaTJL9BhxaAhd7nQCvnbAhl7nyK9gME7np8hSS3a6Z5QAYEdORxK9gaS3ajCyUO)GL9wm2jwa6Z5QAILdZcMEwEilaGfl3VZsbzb)(ZcSyzHjw(5keOhJgwuMfl7uXYVtS0Vb)SalILdZcSyzHj0Wcaz56S87elykalqwomlEbYsmz56SOc)Dw8HS3a6tU8uYEdw5fMY)Cfc0B)2XnM2XWEJkxvtG2XYEdgzV5GG2BE4pyzVb0NZv1K9gqxVi7nLT3cZ90CU92pxHa9MxzZUJZlmLvx9olky5NRqGEZRSjaHAqOLYaUg)pyXIcwSMLFUcb6nVYMdBEykLH9CkSW)ax4Caw4FwH)Gf2EdOp5Ytj7nyLxyk)ZviqV9BhxRWog2Bu5QAc0ow2BWi7nhe0EZd)bl7nG(CUQMS3a66fzVbq7TWCpnNBV9ZviqV5bOz3X5fMYQRENffS8ZviqV5bOjaHAqOLYaUg)pyXIcwSMLFUcb6npanh28Wukd75uyH)bUW5aSW)Sc)blS9gqFYLNs2BWkVWu(NRqGE73oUO1og2Bu5QAc0ow2BWi7nhe0EZd)bl7nG(CUQMS3a6tU8uYEdw5fMY)Cfc0BVfM7P5C7nc9wxuebAUchM17QAkJElV(vAgKaEbILKewi0BDrreOHsJAmKRZWbS8kqSKKWcHERlkIany4sRP)VcvEwQnS3ajCyUO)GL9wm2jmXYpxHa9yw8HyPGpl(6HP(FbxRBWci9u4jqwCmlWILfMyb)(ZYpxHa9ydlSSrpla95CvnXYdzXkyXXS87udwCngYsreil4ikCUMLDVa1xHYyVb01lYEZkSF74cOTJH9Mh(dw2BPqyHWv5oCsT3OYv1eODSSF74IySJH9gvUQMaTJL9Mh(dw2Bwg)3T3cZ90CU9wlwOG(IWKrVkFYfHSNLKewOG(IWK5QmgQ9HLKewOG(IWK5QSk83zjjHfkOVimz8QrUiK9S02EtFfLdG2Bkda73(TF7nG0GpyzhxacaaQmaAsaaOT3S4tDfkS9gsrCSAJRvfxRMauSWsm2jwU0i48S0HdlOdgrfnOJLHqV1neilyykXIVEyQ)eilHDVqryd3SvEfXcabuSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSetaflihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZCZifXXQnUwvCTAcqXclXyNy5sJGZZshoSGoqQ7l9Jowgc9w3qGSGHPel(6HP(tGSe29cfHnCZw5velaAaflihwaP5jqw2UuKZcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0szK12WnBLxrSaObuSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSGyauSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrS0KakwqoSasZtGSSDPiNfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPfarwBd3SvEfXstcOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybXcOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybXcOyb5WcinpbYc6(5keO3OSPPqhlpKf09ZviqV5v20uOJLwaezTnCZw5veliwaflihwaP5jqwq3pxHa9gaAAk0XYdzbD)Cfc0BEaAAk0XslaIS2gUzR8kIfLbaGIfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJLwkJS2gUzR8kIfLvgqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXIYaeqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXIYXeqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXIYOfqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXIYaAaflihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTaiYAB4MTYRiwugqdOyb5WcinpbYc6(5keO3OSPPqhlpKf09ZviqV5v20uOJLwaezTnCZw5velkdObuSGCybKMNazbD)Cfc0BaOPPqhlpKf09ZviqV5bOPPqhlTugzTnCZw5velkJyauSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0cGiRTHB2kVIyrzedGIfKdlG08eilO7NRqGEJYMMcDS8qwq3pxHa9MxzttHowAPmYAB4MTYRiwugXaOyb5WcinpbYc6(5keO3aqttHowEilO7NRqGEZdqttHowAbqK12WnZnJuehR24AvX1QjaflSeJDILlncoplD4Wc6Igkatv9hDSme6TUHazbdtjw81dt9NazjS7fkcB4MTYRiwIjGIfKdlG08eilO7NRqGEJYMMcDS8qwq3pxHa9MxzttHowAftK12WnBLxrSyfakwqoSasZtGSGUFUcb6na00uOJLhYc6(5keO38a00uOJLwXezTnCZCZifXXQnUwvCTAcqXclXyNy5sJGZZshoSGohsOJLHqV1neilyykXIVEyQ)eilHDVqryd3SvEfXIYakwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIow8Nf0hqSvYslLrwBd3SvEfXsmbuSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSGyauSGCybKMNazz7srol4g17iJfKksLLhYIvUCwsHGl9cZcmIg)HdlTqQTzPLYiRTHB2kVIybXaOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPfarwBd3SvEfXstcOyb5WcinpbYY2LICwWnQ3rglivKklpKfRC5SKcbx6fMfyen(dhwAHuBZslLrwBd3SvEfXstcOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybXcOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIyrzaaOyb5WcinpbYY2LICwWnQ3rglivwEilw5Yzb8aE4dwSaJOXF4WslK0MLwaezTnCZw5velkhtaflihwaP5jqw2UuKZcUr9oYybPYYdzXkxolGhWdFWIfyen(dhwAHK2S0szK12WnBLxrSaqaaOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybGaeqXcYHfqAEcKLTlf5SGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTugzTnCZw5vela0kauSGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslaIS2gUzR8kIfaAfakwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwaiGgqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXcarmakwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwaiIfqXcYHfqAEcKLTlf5SGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTaiYAB4MTYRiwIjaauSGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslLrwBd3m3msrCSAJRvfxRMauSWsm2jwU0i48S0HdlOR7A9Vpl0XYqO36gcKfmmLyXxpm1FcKLWUxOiSHB2kVIybGakwqoSasZtGSSDPiNfCJ6DKXcsLLhYIvUCwapGh(GflWiA8hoS0cjTzPLYiRTHBMBgPiowTX1QIRvtakwyjg7elxAeCEw6WHf0HF0XYqO36gcKfmmLyXxpm1FcKLWUxOiSHB2kVIyrzaflihwaP5jqwq3SkQdhuKPPqhlpKf0nRI6WbfzAkdvUQMarhlTugzTnCZw5velXeqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3SvEfXIYkdOyb5WcinpbYY2LICwWnQ3rglivKklpKfRC5SKcbx6fMfyen(dhwAHuBZslLrwBd3SvEfXIYkdOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIyrzanGIfKdlG08eilOBwf1HdkY0uOJLhYc6MvrD4GImnLHkxvtGOJLwkJS2gUzR8kIfaQmGIfKdlG08eilBxkYzb3OEhzSGuz5HSyLlNfWd4HpyXcmIg)HdlTqsBwAbqK12WnBLxrSaqLbuSGCybKMNazbDZQOoCqrMMcDS8qwq3SkQdhuKPPmu5QAceDS0szK12WnBLxrSaqacOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPLYiRTHB2kVIybGXeqXcYHfqAEcKLTlf5SGBuVJmwqQS8qwSYLZc4b8WhSybgrJ)WHLwiPnlTIjYAB4MTYRiwaOvaOyb5WcinpbYc6MvrD4GImnf6y5HSGUzvuhoOittzOYv1ei6yPfarwBd3SvEfXcab0akwqoSasZtGSGUzvuhoOittHowEilOBwf1HdkY0ugQCvnbIowAPmYAB4MTYRiwaiIbqXcYHfqAEcKf0nRI6WbfzAk0XYdzbDZQOoCqrMMYqLRQjq0XslLrwBd3m3msrCSAJRvfxRMauSWsm2jwU0i48S0HdlOtf6p6yzi0BDdbYcgMsS4RhM6pbYsy3lue2WnBLxrSOCtcOyb5WcinpbYY2LICwWnQ3rglivwEilw5Yzb8aE4dwSaJOXF4WslK0MLwXezTnCZw5velkJybuSGCybKMNazz7srol4g17iJfKklpKfRC5SaEap8blwGr04pCyPfsAZslLrwBd3m3SvLgbNNazbXWIh(dwSOp8JnCZ2B4ikyhxLbaaT3Igy)0K9gsJ0Selx7vGyXQpRdKBgPrAwIZc1c)SOmardlaeaauzUzUzKgPzb57EHIWakUzKgPzPPzjoGGeilBqTpSelYtnCZinsZstZcY39cfbYY7dk6ZxNLGJjmlpKLqJGMYVpOOhB4MrAKMLMMfRwkfcKazzvffim2NgSa0NZv1eMLwNHmOHLOHaMXVp41GIyPPJNLOHaAWVp41GIAB4MrAKMLMML4aeEGSenuWX)vOybPy8FNLRZY9OdZYVtSyzGfkwq)G(IWKHBgPrAwAAwae5iqSGCybeIaXYVtSSfDZ9ywCw03)AILu4qS01eYovnXsRRZsd4ILDhSq3ZY(9SCpl4lDPFVi4cRBWIL73zjwaIJtmybrSGCst4)CnlXrFOQuQE0WY9OdKfmcxuBd3msJ0S00SaiYrGyjfIFwqx)qT)5Hs9RWOJfCGkFoiMfpks3GLhYIkeJzPFO2FmlWs3WWnJ0inlnnlXyi)zjgWuIfyNLyP9DwIL23zjwAFNfhZIZcoIcNRz5NRqGEd3msJ0S00SaioIkAyP1zidAybPy8FhnSGum(VJgw2EF63qTzj1bjwsHdXYq4tFu9S8qwiF0hnSeGPQ(3043N3WnZnJ0inlXPk47pbYsSCTxbIL4aiTswcEXIkXshUkqw8NL9)JWakKGevx7vGAA8LgmOUFFPAoisILR9kqn92LICKKcA2)unsP7NMus11EfiZJSNBMB2d)blSjAOamv1FLq4kWHaZ4OBUhZnJ0SeJDIfG(CUQMy5WSGPNLhYcayXY97SuqwWV)SalwwyILFUcb6XOHfLzXYovS87el9BWplWIy5WSalwwycnSaqwUol)oXcMcWcKLdZIxGSetwUolQWFNfFiUzp8hSWMOHcWuv)rKsibOpNRQj0uEkPeSYlmL)5keOhnaD9IucaCZE4pyHnrdfGPQ(JiLqcqFoxvtOP8usjyLxyk)ZviqpAGrk5GGObORxKskJMRR0pxHa9gLn7ooVWuwD17k(5keO3OSjaHAqOLYaUg)pyPW6FUcb6nkBoS5HPug2ZPWc)dCHZbyH)zf(dwyUzp8hSWMOHcWuv)rKsibOpNRQj0uEkPeSYlmL)5keOhnWiLCqq0a01lsjaIMRR0pxHa9gaA2DCEHPS6Q3v8ZviqVbGMaeQbHwkd4A8)GLcR)5keO3aqZHnpmLYWEofw4FGlCoal8pRWFWcZnJ0SeJDctS8ZviqpMfFiwk4ZIVEyQ)xW16gSaspfEcKfhZcSyzHjwWV)S8Zviqp2WclB0ZcqFoxvtS8qwScwCml)o1GfxJHSuebYcoIcNRzz3lq9vOmCZE4pyHnrdfGPQ(JiLqcqFoxvtOP8usjyLxyk)ZviqpAGrk5GGObORxKswbAUUse6TUOic0CfomR3v1ug9wE9R0mib8cuscHERlkIanuAuJHCDgoGLxbkjHqV1ffrGgmCP10)xHkpl1gCZE4pyHnrdfGPQ(JiLqskewiCvUdNuUzp8hSWMOHcWuv)rKsiXY4)oA0xr5aOskda0CDLArb9fHjJEv(KlczFscf0xeMmxLXqTpjjuqFryYCvwf(7jjuqFryY4vJCri7BZnZnJ0Saihk44NfaYcsX4)olEbYIZY27dEnOiwGflBXGfl3VZsCpu7placoXIxGSelyCIblWHLT3N(nelWFNglhM4M9WFWcBGrurdIucjwg)3rZ1vQff0xeMm6v5tUiK9jjuqFryYCvgd1(KKqb9fHjZvzv4VNKqb9fHjJxnYfHSVTIOHaAu2yz8FxH1rdb0aqJLX)DUzp8hSWgyev0GiLqc(9PFdHg9vuoaQeArZ1vY6zvuhoOiJQR9kqzyp7AD(3VcfojX6aeivE9M6qT)5UtjjwJJiTo)(GIESb)(0DTwjLtsS(DnvVP8FneoR6AVcKHkxvtGjjTOG(IWKbd1(KlczFscf0xeMmxL1RYNKekOVimzUkRc)9KekOVimz8QrUiK9T5M9WFWcBGrurdIucj43h8AqrOrFfLdGkHw0CDLMvrD4GImQU2RaLH9SR15F)kuyfbiqQ86n1HA)ZDNuGJiTo)(GIESb)(0DTwjL5M5MrAKMf0hzuy9eileqAAWYFPel)oXIhE4WYHzXb6N2v1KHB2d)blSsyO2NSk5PCZE4pyHrKsij4AD2d)bRS(WpAkpLucgrfnO56k9xkb4waeX9WFWYyz8F3eC8N)lLqKh(dwg87t)gYeC8N)lLAZnJ0SSrpML4arFwGflXerSy5(D46zbCU(ZIxGSy5(Dw2EF0WbKfVazbGiIf4VtJLdtCZE4pyHrKsibOpNRQj0uEkP0HZoKqdqxViLWrKwNFFqrp2GFF6UwhVYkAz97AQEd(9rdhqdvUQMatsExt1BWpP1(KbNR)gQCvnb2ojbhrAD(9bf9yd(9P7AD8aKBgPzzJEmlbn5ajwSStflBVp9BiwcEXY(9SaqeXY7dk6XSyz)c7SCywgsta96zPdhw(DIf0pOVimXYdzrLyjAOondbYIxGSyz)c7S0pTMgwEilbh)CZE4pyHrKsibOpNRQj0uEkP0HZbn5aj0a01lsjCeP153hu0Jn43N(nu8kZnJ0SGu2NZv1el)U)Se2PacywUolnGlw8Hy5kwCwqfaz5HS4aHhil)oXc((L)hSyXYonelol)Cfc0Zc9bwomllmbYYvSOsVfIkwco(XCZE4pyHrKsibOpNRQj0uEkP0vzubq0a01lsPOHaAsHWQFdLKeneqdEv9BOKKOHaAWVp41GIssIgcOb)(0DTojjAiGM(AAKH9mPxfLKOU6DtWZxfmdL6xHvsD17MGNVkyaxJ)hSssIgcOzCGubx4CFOk2n4MrAwAcmXsSObtdcxHIfl3VZcYJdsSQkWcCyX7pnSGCybeIaXYvSG84GeRQcCZE4pyHrKsirLgmniCfk0CDLA1Y6aeivE9M6qT)5UtjjwhGqni0szcWciebk)7ughDZ9yZkQTc1vVBcE(QGzOu)kC8kJwfQRE3moqQGlCUpuf7gMHs9RWa2kuyDacKkVEdqQ(9gtssacKkVEdqQ(9gJc1vVBcE(QGzfPqD17MXbsfCHZ9HQy3WSIu0sD17MXbsfCHZ9HQy3WmuQFfgWkRCtJweFwf1HdkYGVQV059g4NMZtsux9Uj45RcMHs9RWawzLtsugPIJiToV74NaSYg0I22Tva0NZv1K5QmQai3msZcGe(Sy5(DwCwqECqIvvbw(D)z5Wf6EwCwaKln2hwIgyGf4WILDQy53jw6hQ9NLdZIRcxplpKfQa5M9WFWcJiLqse8pyHMRRK6Q3nbpFvWmuQFfoELrRIwwpRI6WbfzWx1x68Ed8tZ5jjQRE3moqQGlCUpuf7gMHs9RWawzettdqexD17gvnecQx43SIuOU6DZ4aPcUW5(qvSBywrTtsuHySI(HA)ZdL6xHbmarl3msZcYDDyP9NWSyzN(DAyzHVcflihwaHiqSuqlSy50AwCTgAHLgWflpKf8FAnlbh)S87elypLyXtHR6zb2zb5WciebcripoiXQQalbh)yUzp8hSWisjKa0NZv1eAkpLukalGqeOmiHBub0a01lsPaD6wT6hQ9ppuQFfUPvgTnDac1GqlLj45RcMHs9RWTrQk3KaOTsb60TA1pu7FEOu)kCtRmAB6aeQbHwktawaHiq5FNY4OBUhBaxJ)hSA6aeQbHwktawaHiq5FNY4OBUhBgk1Vc3gPQCtcG2kSE8dmtaP6noii2qi7WpojjaHAqOLYe88vbZqP(v44V6PjcQ9NaZ9d1(Nhk1VcNKmRI6WbfzcKMW)56mo6M7XkcqOgeAPmbpFvWmuQFfo(ycGKKaeQbHwktawaHiq5FNY4OBUhBgk1Vch)vpnrqT)eyUFO2)8qP(v4MwzaKKyDacKkVEtDO2)C3jUzKMLMatGS8qwajT3GLFNyzHDuelWolipoiXQQalw2PILf(kuSacxQAIfyXYctS4filrdbKQNLf2rrSyzNkw8IfheKfcivplhMfxfUEwEilGhXn7H)GfgrkHeG(CUQMqt5PKsbWCawG3FWcnaD9IuQv)qT)5Hs9RWXRmAtsg)aZeqQEJdcInxfpAbqBfTA1IqV1ffrGgknQXqUodhWYRaPOvac1GqlLHsJAmKRZWbS8kqMHs9RWawzanasscqGu51Bas1V3yueGqni0szO0Ogd56mCalVcKzOu)kmGvgqJyqulLvgXNvrD4GIm4R6lDEVb(P582TvyDac1GqlLHsJAmKRZWbS8kqMHCWgTtsi0BDrreObdxAn9)vOYZsTHIwwhGaPYR3uhQ9p3DkjjaHAqOLYGHlTM()ku5zP2ihtRaTnjau2muQFfgWkRSv0ojPvac1GqlLrLgmniCfkZqoyJKeRhpqMFGADBfTArO36IIiqZv4WSExvtz0B51VsZGeWlqkAfGqni0szUchM17QAkJElV(vAgKaEbYmKd2ijXd)blZv4WSExvtz0B51VsZGeWlqgWd7QAcSD7KKwe6TUOic0G3DqOfcmdh1mSNF4Ks1RiaHAqOLY8WjLQNaZxHpu7FoMOfTXeGkBgk1Vc3ojPvlG(CUQMmWkVWu(NRqGELuojbOpNRQjdSYlmL)5keOxPy2wrRFUcb6nkBgYbBKdqOgeAPss(5keO3OSjaHAqOLYmuQFfo(REAIGA)jWC)qT)5Hs9RWnTYaODscqFoxvtgyLxyk)ZviqVsaurRFUcb6na0mKd2ihGqni0sLK8ZviqVbGMaeQbHwkZqP(v44V6PjcQ9NaZ9d1(Nhk1Vc30kdG2jja95CvnzGvEHP8pxHa9kbG2TBNKeGaPYR3GqJ58QDsIkeJv0pu7FEOu)kmGvx9Uj45RcgW14)blUzKMfKY(CUQMyzHjqwEilGK2BWIxny5NRqGEmlEbYsaeZILDQyXIF)vOyPdhw8If0FfTdNZzjAGbUzp8hSWisjKa0NZv1eAkpLu63NtRZyIqGMSf)E0a01lsjRXWLw9kqZVpNwNXeHangQCvnbMK0pu7FEOu)kC8aeaaijrfIXk6hQ9ppuQFfgWaeTiQLvaGMwD17MFFoToJjcbAm43diG4aSDsI6Q3n)(CADgtec0yWVhqi(y2KnDRzvuhoOid(Q(sN3BGFAohXrBBUzKMLMatSG(PrngY1SaiEalVcelaeaykGzrL6WHyXzb5XbjwvfyzHjd3Sh(dwyePeswykFpLIMYtjLO0Ogd56mCalVceAUUsbiudcTuMGNVkygk1VcdyacafbiudcTuMaSacrGY)oLXr3Cp2muQFfgWaeakAb0NZv1K53NtRZyIqGMSf)(Ke1vVB(9506mMieOXGFpGq8XeaiQ1SkQdhuKbFvFPZ7nWpnNJ4a62Tva0NZv1K5QmQaysIkeJv0pu7FEOu)kmGJjIHBgPzPjWelBWLwt)vOyXQDP2GfanMcywuPoCiwCwqECqIvvbwwyYWn7H)GfgrkHKfMY3tPOP8usjmCP10)xHkpl1gO56k1kaHAqOLYe88vbZqP(vyadOvyDacKkVEdqQ(9gJcRdqGu51BQd1(N7oLKeGaPYR3uhQ9p3Dsrac1GqlLjalGqeO8VtzC0n3JndL6xHbmGwrlG(CUQMmbybeIaLbjCJkKKeGqni0szcE(QGzOu)kmGb0TtscqGu51Bas1V3yu0Y6zvuhoOid(Q(sN3BGFAoxrac1GqlLj45RcMHs9RWagqNKOU6DZ4aPcUW5(qvSBygk1VcdyLTce1cTioHERlkIanxH)zfE4GZGhWROSkP1TvOU6DZ4aPcUW5(qvSBywrTts6hQ9ppuQFfgWaeTjje6TUOic0qPrngY1z4awEfifbiudcTugknQXqUodhWYRazgk1VchpabqBfa95CvnzUkJkaQWAc9wxuebAUchM17QAkJElV(vAgKaEbkjjaHAqOLYCfomR3v1ug9wE9R0mib8cKzOu)kC8aeajjQqmwr)qT)5Hs9RWagGaGBgPzjoAlEdmllmXIvz1SvNfl3VZcYJdsSQkWn7H)GfgrkHeG(CUQMqt5PKsh6bMdWc8(dwObORxKsQRE3e88vbZqP(v44vgTkAz9SkQdhuKbFvFPZ7nWpnNNKOU6DZ4aPcUW5(qvSBygk1VcdyLugGgaIOwXeXvx9UrvdHG6f(nRO2iQvt20OfXvx9UrvdHG6f(nRO2ioHERlkIanxH)zfE4GZGhWROSkP1kux9UzCGubx4CFOk2nmRO2jjQqmwr)qT)5Hs9RWagGOnjHqV1ffrGgknQXqUodhWYRaPiaHAqOLYqPrngY1z4awEfiZqP(vyUzp8hSWisjKSWu(EkfnLNskDfomR3v1ug9wE9R0mib8ceAUUsa95Cvnzo0dmhGf49hSua0NZv1K5QmQai3msZstGjwMd1(ZIk1HdXsaeZn7H)GfgrkHKfMY3tPOP8usj8UdcTqGz4OMH98dNuQE0CDLAfGqni0szcE(QGzihSHcRdqGu51BQd1(N7oPaOpNRQjZVpNwNXeHanzl(9jjbiqQ86n1HA)ZDNueGqni0szcWciebk)7ughDZ9yZqoydfTa6Z5QAYeGfqicugKWnQqssac1GqlLj45RcMHCWgTBRae(g8Q63qM)ciCfkfTaHVb)Kw7tUR9Hm)fq4kujjw)UMQ3GFsR9j31(qgQCvnbMKGJiTo)(GIESb)(0VHIpMTv0ce(MuiS63qM)ciCfQ2kAb0NZv1K5WzhsjjZQOoCqrgvx7vGYWE2168VFfkCsIJ)X15iOfAIxjelassux9UrvdHG6f(nRO2kAfGqni0szuPbtdcxHYmKd2ijX6XdK5hOw3wH1e6TUOic0CfomR3v1ug9wE9R0mib8cuscHERlkIanxHdZ6DvnLrVLx)kndsaVaPOvac1GqlL5kCywVRQPm6T86xPzqc4fiZqP(v44JjasscqOgeAPmQ0GPbHRqzgk1VchFmbqBfwRU6DtWZxfmROKevigROFO2)8qP(vyaBfaGBgPzjg7hMLdZIZY4)onSqAxfo(tSyXBWYdzj1rGyX1AwGfllmXc(9NLFUcb6XS8qwujw0xrGSSIyXY97SG84GeRQcS4filihwaHiqS4fillmXYVtSaWcKfSg(SalwcGSCDwuH)ol)Cfc0JzXhIfyXYctSGF)z5NRqGEm3Sh(dwyePeswykFpLIrdwdFSs)Cfc0RmAUUsTa6Z5QAYaR8ct5FUcb6TwjLvy9pxHa9gaAgYbBKdqOgeAPssAb0NZv1Kbw5fMY)Cfc0RKYjja95CvnzGvEHP8pxHa9kfZ2kAPU6DtWZxfmRifTSoabsLxVbiv)EJjjrD17MXbsfCHZ9HQy3WmuQFfgrTqlIpRI6WbfzWx1x68Ed8tZ5TbSs)Cfc0Bu2OU69m4A8)GLc1vVBghivWfo3hQIDdZkkjrD17MXbsfCHZ9HQy3iJVQV059g4NMZnRO2jjbiudcTuMGNVkygk1VcJiag)pxHa9gLnbiudcTugW14)blfwRU6DtWZxfmRifTSoabsLxVPou7FU7usI1a95CvnzcWciebkds4gvOTcRdqGu51BqOXCELKeGaPYR3uhQ9p3DsbqFoxvtMaSacrGYGeUrfueGqni0szcWciebk)7ughDZ9yZksH1biudcTuMGNVkywrkA1sD17gkOVimL1RYhZqP(v44vgajjQRE3qb9fHPmgQ9XmuQFfoELbqBfwpRI6WbfzuDTxbkd7zxRZ)(vOWjjTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqqj0MKOU6DJQR9kqzyp7AD(3Vcfo7tWlYGFpGGsnz72jjQRE3GWvGdbMP0iOfAsP6ZurdQl2Kzf1ojPFO2)8qP(vyadqaKKa0NZv1Kbw5fMY)Cfc0ReaARaOpNRQjZvzubqUzp8hSWisjKSWu(EkfJgSg(yL(5keOhGO56k1cOpNRQjdSYlmL)5keO3ALaOcR)5keO3OSzihSroaHAqOLkjbOpNRQjdSYlmL)5keOxjaQOL6Q3nbpFvWSIu0Y6aeivE9gGu97nMKe1vVBghivWfo3hQIDdZqP(vye1cTi(SkQdhuKbFvFPZ7nWpnN3gWk9ZviqVbGg1vVNbxJ)hSuOU6DZ4aPcUW5(qvSBywrjjQRE3moqQGlCUpuf7gz8v9LoV3a)0CUzf1ojjaHAqOLYe88vbZqP(vyebW4)5keO3aqtac1GqlLbCn(FWsH1QRE3e88vbZksrlRdqGu51BQd1(N7oLKynqFoxvtMaSacrGYGeUrfARW6aeivE9geAmNxkAzT6Q3nbpFvWSIssSoabsLxVbiv)EJPDssacKkVEtDO2)C3jfa95CvnzcWciebkds4gvqrac1GqlLjalGqeO8VtzC0n3JnRifwhGqni0szcE(QGzfPOvl1vVBOG(IWuwVkFmdL6xHJxzaKKOU6Ddf0xeMYyO2hZqP(v44vgaTvy9SkQdhuKr11EfOmSNDTo)7xHcNK0sD17gvx7vGYWE2168VFfkCU8FnKb)EabLqBsI6Q3nQU2RaLH9SR15F)ku4SpbVid(9ack1KTB3ojrD17geUcCiWmLgbTqtkvFMkAqDXMmROKevigROFO2)8qP(vyadqaKKa0NZv1Kbw5fMY)Cfc0ReaARaOpNRQjZvzubqUzKMLMatywCTMf4VtdlWILfMy5EkfZcSyjaYn7H)GfgrkHKfMY3tPyUzKMfRofoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdZn7H)GfgrkHKzvzp8hSY6d)OP8usjhsOb)ZfELugnxxjG(CUQMmho7qIB2d)blmIucjZQYE4pyL1h(rt5PKsQq)rd(Nl8kPmAUUsZQOoCqrgvx7vGYWE2168VFfkSHqV1ffrGCZE4pyHrKsizwv2d)bRS(WpAkpLuc)CZCZinli31HL2FcZILD63PHLFNyXQpKNg8pStdlQRENflNwZs31AwG9olwUF)kw(DILIq2ZsWXp3Sh(dwyJdjLa6Z5QAcnLNskboKNMTCADU7ADg27ObORxKsTux9U5VuYcCQm4qEQ6vG0ygk1VcdyubqtQJmebaJYjjQRE38xkzbovgCipv9kqAmdL6xHbSh(dwg87t)gYqiJcRNY)LsicagLv0Ic6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXRg5Iq23UTc1vVB(lLSaNkdoKNQEfinMvKIzvuhoOiZFPKf4uzWH8u1RaPHBgPzb5UoS0(tywSSt)onSS9(GxdkILdZIf487SeC8FfkwGaPHLT3N(nelxXIvUkFyb9d6lctCZE4pyHnoKqKsibOpNRQj0uEkP0HQGdLXVp41GIqdqxViLSMc6lctMRYyO2hfTWrKwNFFqrp2GFF63qXJwfVRP6ny4sNH98Vt5oCi8BOYv1eyscoI0687dk6Xg87t)gkEetBUzKMLMatSGCybeIaXILDQyXFw0egZYV7flOfaSehmGKfVazrFfXYkIfl3VZcYJdsSQkWn7H)Gf24qcrkHKaSacrGY)oLXr3CpgnxxjRbN1bAkyoaIv0QfqFoxvtMaSacrGYGeUrfuyDac1GqlLj45RcMHCWgjjQRE3e88vbZkQTIwQRE3qb9fHPSEv(ygk1VchpGojrD17gkOVimLXqTpMHs9RWXdOBROL1ZQOoCqrgvx7vGYWE2168VFfkCsI6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acXhZKe1vVBuDTxbkd7zxRZ)(vOWzFcErg87beIpMTtsuHySI(HA)ZdL6xHbSYaqH1biudcTuMGNVkygYbB0MBgPzPjWelacdvXUblwUFNfKhhKyvvGB2d)blSXHeIucjJdKk4cN7dvXUbAUUsQRE3e88vbZqP(v44vgTCZinlnbMyzBv9BiwUILiVaP0lWcSyXRg)(vOy539Nf9bKWSOSvGPaMfVazrtymlwUFNLu4qS8(GIEmlEbYI)S87elubYcSZIZYgu7dlOFqFryIf)zrzRGfmfWSahw0egZYqP(vxHIfhZYdzPGpl7oWRqXYdzzO(q4DwaxZvOyXkxLpSG(b9fHjUzp8hSWghsisjKGxv)gcnHgbnLFFqrpwjLrZ1vQ1q9HW7UQMssux9UHc6lctzmu7JzOu)kmGJPckOVimzUkJHAFumuQFfgWkBfkExt1BWWLod75FNYD4q43qLRQjW2kEFqrV5Vuk)Wm4rXRSv004isRZVpOOhJOHs9RWkArb9fHjZvzVAKKmuQFfgWOcGMuhzT5MrAwAcmXY2Q63qS8qw2DGelolO0qvxZYdzzHjwSkRMT6CZE4pyHnoKqKsibVQ(neAUUsa95Cvnzo0dmhGf49hSueGqni0szUchM17QAkJElV(vAgKaEbYmKd2qbHERlkIanxHdZ6DvnLrVLx)kndsaVaXn7H)Gf24qcrkHe87t31A0CDLS(DnvVb)Kw7tgCU(BOYv1eOIwQRE3GFF6UwBgQpeE3v1KIw4isRZVpOOhBWVpDxRbCmtsSEwf1HdkY8xkzbovgCipv9kqAANK8UMQ3GHlDg2Z)oL7WHWVHkxvtGkux9UHc6lctzmu7JzOu)kmGJPckOVimzUkJHAFuOU6Dd(9P7ATzOu)kmGrmkWrKwNFFqrp2GFF6UwhVswrBfTSEwf1HdkYOBe8XX5UMO)kuzu6lnctjj)LsivKQvG24vx9Ub)(0DT2muQFfgraSTI3hu0B(lLYpmdEu8OLBgPzbP4(Dw2EsR9HfR(C9NLfMybwSeazXYovSmuFi8URQjwuxpl4)0AwS43ZshoSyLnc(4ywIgyGfVazbewO7zzHjwuPoCiwqUvhByz7pTMLfMyrL6WHyb5WciebIf8vbILF3FwSCAnlrdmWIxWFNgw2EF6UwZn7H)Gf24qcrkHe87t31A0CDLExt1BWpP1(KbNR)gQCvnbQqD17g87t31AZq9HW7UQMu0Y6zvuhoOiJUrWhhN7AI(RqLrPV0imLK8xkHurQwbAJ3kAR49bf9M)sP8dZGhfFm5MrAwqkUFNfR(qEQ6vG0WYctSS9(0DTMLhYccefXYkILFNyrD17SO2GfxJHSSWxHILT3NUR1SalwqllykalqmlWHfnHXSmuQF1vO4M9WFWcBCiHiLqc(9P7AnAUUsZQOoCqrM)sjlWPYGd5PQxbsJcCeP153hu0Jn43NUR1XRumv0YA1vVB(lLSaNkdoKNQEfinMvKc1vVBWVpDxRnd1hcV7QAkjPfqFoxvtgWH80SLtRZDxRZWExrl1vVBWVpDxRndL6xHbCmtsWrKwNFFqrp2GFF6Uwhpav8UMQ3GFsR9jdox)nu5QAcuH6Q3n43NUR1MHs9RWagTTB3MBgPzb5UoS0(tywSSt)onS4SS9(GxdkILfMyXYP1Se8fMyz79P7AnlpKLUR1Sa7D0WIxGSSWelBVp41GIy5HSGarrSy1hYtvVcKgwWVhqGLve3Sh(dwyJdjePesa6Z5QAcnLNskHFF6UwNTaRp3DTod7D0a01lsjh)JRZrql0eFtcGMULYaaXvx9U5VuYcCQm4qEQ6vG0yWVhqODt3sD17g87t31AZqP(vyepMivCeP15Dh)eIB97AQEd(jT2Nm4C93qLRQjW2nDRaeQbHwkd(9P7ATzOu)kmIhtKkoI068UJFcXFxt1BWpP1(KbNR)gQCvnb2UPBbcFtFnnYWEM0RImdL6xHrC02wrl1vVBWVpDxRnROKKaeQbHwkd(9P7ATzOu)kCBUzKMLMatSS9(GxdkIfl3VZIvFipv9kqAy5HSGarrSSIy53jwux9olwUFhUEw0q8vOyz79P7AnlRO)sjw8cKLfMyz79bVguelWIfRarSelyCIbl43diGzzv)PzXky59bf9yUzp8hSWghsisjKGFFWRbfHMRReqFoxvtgWH80SLtRZDxRZWExbqFoxvtg87t316Sfy95UR1zyVRWAG(CUQMmhQcoug)(GxdkkjPL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9acXhZKe1vVBuDTxbkd7zxRZ)(vOWzFcErg87beIpMTvGJiTo)(GIESb)(0DTgWwHcG(CUQMm43NUR1zlW6ZDxRZWENBgPzPjWelyl(KYcgYYV7plnGlwqrplPoYyzf9xkXIAdww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz539ILyYc(9acywGdliLSWplw2PILyIiwWVhqaZcHSOBiUzp8hSWghsisjK4GE0FaPm2IpPOj0iOP87dk6XkPmAUUsw)xaHRqPWAp8hSmoOh9hqkJT4tAg0tDuK5QCxFO2)Keq4BCqp6pGugBXN0mON6Oid(9acaoMkaHVXb9O)aszSfFsZGEQJImdL6xHbCm5MrAwSAP(q4DwaebHv)gILRZcYJdsSQkWYHzzihSbAy53PHyXhIfnHXS87EXcAz59bf9ywUIfRCv(Wc6h0xeMyXY97SSbFab0WIMWyw(DVyrzaWc83PXYHjwUIfVAWc6h0xeMyboSSIy5HSGwwEFqrpMfvQdhIfNfRCv(Wc6h0xeMmSy1Hf6EwgQpeENfW1CfkwSACf4qGSG(Prql0Ks1ZYQ0egZYvSSb1(Wc6h0xeM4M9WFWcBCiHiLqskew9Bi0eAe0u(9bf9yLugnxxPH6dH3DvnP49bf9M)sP8dZGhfFRwkBfiQfoI0687dk6Xg87t)gcXbiIRU6Ddf0xeMY6v5Jzf1UnIgk1Vc3gP2sze9UMQ38wUkNcHf2qLRQjW2kAfGqni0szcE(QGzihSHcRbN1bAkyoaIv0cOpNRQjtawaHiqzqc3OcjjbiudcTuMaSacrGY)oLXr3Cp2mKd2ijX6aeivE9M6qT)5UtTtsWrKwNFFqrp2GFF63qaUvlaDt3sD17gkOVimL1RYhZkcXby72iElLr07AQEZB5QCkewydvUQMaB3wH1uqFryYGHAFYfHSpjPff0xeMmxLXqTpjjTOG(IWK5QSk83tsOG(IWK5QSEv(0wH1VRP6ny4sNH98Vt5oCi8BOYv1eysI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lkELaiAbqBfTWrKwNFFqrp2GFF63qawzaG4TugrVRP6nVLRYPqyHnu5QAcSDBfo(hxNJGwOjE0cGMwD17g87t31AZqP(vyehq3wrlRvx9UbHRahcmtPrql0Ks1NPIguxSjZkkjHc6lctMRYyO2NKeRdqGu51BqOXCE1wH1QRE3moqQGlCUpuf7gz8v9LoV3a)0CUzfXnJ0S0eyIfabyCzbwSeazXY97W1ZsWJIUcf3Sh(dwyJdjePes6Wjqzypx(Vgcnxxjpkh2PacCZE4pyHnoKqKsibOpNRQj0uEkPuamhGf49hSYoKqdqxViLSgCwhOPG5aiwbqFoxvtMayoalW7pyPOvl1vVBWVpDxRnROKK31u9g8tATpzW56VHkxvtGjjbiqQ86n1HA)ZDNAROL1QRE3GHA8FbYSIuyT6Q3nbpFvWSIu0Y631u9M(AAKH9mPxfzOYv1eysI6Q3nbpFvWaUg)pyfFac1GqlLPVMgzypt6vrMHs9RWiQjBRaOpNRQjZVpNwNXeHanzl(9kAzDacKkVEtDO2)C3PKKaeQbHwktawaHiq5FNY4OBUhBwrkAPU6Dd(9P7ATzOu)kmGbysI1VRP6n4N0AFYGZ1FdvUQMaB3wX7dk6n)Ls5hMbpkE1vVBcE(QGbCn(FWcXbGbX0ojrfIXk6hQ9ppuQFfgWQRE3e88vbd4A8)GvBUzKMLMatSG84GeRQcSalwcGSSknHXS4fil6RiwUNLvelwUFNfKdlGqeiUzp8hSWghsisjKeinH)Z1zxFOQuQE0CDLa6Z5QAYeaZbybE)bRSdjUzp8hSWghsisjKCvWNY)dwO56kb0NZv1KjaMdWc8(dwzhsCZinlnbMyb9tJGwOHLyblqwGflbqwSC)olBVpDxRzzfXIxGSGDGelD4WcGCPX(WIxGSG84GeRQcCZE4pyHnoKqKsiHsJGwOjRclq0CDLU6PjcQ9NaZ9d1(Nhk1VcdyLrBssl1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbiAbqsI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lkELaiAbqBfQRE3GFF6UwBwrkAfGqni0szcE(QGzOu)kC8OfajjGZ6anfmhaXT5MrAwSAP(q4Dw6AFiwGflRiwEilXKL3hu0JzXY97W1ZcYJdsSQkWIkDfkwCv46z5HSqil6gIfVazPGplqG0e8OORqXn7H)Gf24qcrkHe8tATp5U2hcnHgbnLFFqrpwjLrZ1vAO(q4Dxvtk(lLYpmdEu8kJwf4isRZVpOOhBWVp9BiaBfk8OCyNciOOL6Q3nbpFvWmuQFfoELbqsI1QRE3e88vbZkQn3msZstGjwaeGOplxNLRWhiXIxSG(b9fHjw8cKf9vel3ZYkIfl3VZIZcGCPX(Ws0adS4filXb0J(diXYMfFs5M9WFWcBCiHiLqsFnnYWEM0RIqZ1vIc6lctMRYE1qHhLd7uabfQRE3enxkCapxN9j41fYrln2hdqxViadq0cafTaHVXb9O)aszSfFsZGEQJIm)fq4kujjwhGaPYR3uuyGA4aMKGJiTo)(GIEC8aSTIwQRE3moqQGlCUpuf7gMHs9RWagX20TqlIpRI6WbfzWx1x68Ed8tZ5TvOU6DZ4aPcUW5(qvSBywrjjwRU6DZ4aPcUW5(qvSBywrTv0Y6aeQbHwktWZxfmROKe1vVB(9506mMieOXGFpGaGvgTk6hQ9ppuQFfgWaeaaqr)qT)5Hs9RWXRmaaqsI1y4sREfO53NtRZyIqGgdvUQMaBROfgU0QxbA(9506mMieOXqLRQjWKKaeQbHwktWZxfmdL6xHJpMaOn3msZstGjwCw2EF6UwZcG4I(DwIgyGLvPjmMLT3NUR1SCywC9qoydwwrSahwAaxS4dXIRcxplpKfiqAcEelXbdi5M9WFWcBCiHiLqc(9P7AnAUUsQRE3al63X5iAcu0FWYSIu0sD17g87t31AZq9HW7UQMssC8pUohbTqt8iwa0MBgPzXQVsJyjoyajlQuhoelihwaHiqSy5(Dw2EF6UwZIxGS87uXY27dEnOiUzp8hSWghsisjKGFF6UwJMRRuacKkVEtDO2)C3jfw)UMQ3GFsR9jdox)nu5QAcurlG(CUQMmbybeIaLbjCJkKKeGqni0szcE(QGzfLKOU6DtWZxfmRO2kcqOgeAPmbybeIaL)DkJJU5ESzOu)kmGrfanPoYq8aD6wo(hxNJGwObPIwa0wH6Q3n43NUR1MHs9RWa2kuyn4SoqtbZbqm3Sh(dwyJdjePesWVp41GIqZ1vkabsLxVPou7FU7KIwa95CvnzcWciebkds4gvijjaHAqOLYe88vbZkkjrD17MGNVkywrTveGqni0szcWciebk)7ughDZ9yZqP(vyadOvOU6Dd(9P7ATzfPGc6lctMRYE1qH1a95CvnzoufCOm(9bVguKcRbN1bAkyoaI5MrAwAcmXY27dEnOiwSC)olEXcG4I(DwIgyGf4WY1zPbCHoqwGaPj4rSehmGKfl3VZsd4AyPiK9SeC8ByjoAmKfWvAelXbdizXFw(DIfQazb2z53jwqkt1V3yyrD17SCDw2EF6UwZIf4sdwO7zP7AnlWENf4Wsd4IfFiwGflaKL3hu0J5M9WFWcBCiHiLqc(9bVgueAUUsQRE3al63X5GM8jd8WhSmROKKwwJFF63qgpkh2PackSgOpNRQjZHQGdLXVp41GIssAPU6DtWZxfmdL6xHbmAvOU6DtWZxfmROKKwTux9Uj45RcMHs9RWagva0K6idXd0PB54FCDocAHgKAmbqBfQRE3e88vbZkkjrD17MXbsfCHZ9HQy3iJVQV059g4NMZndL6xHbmQaOj1rgIhOt3YX)46Ce0cni1ycG2kux9UzCGubx4CFOk2nY4R6lDEVb(P5CZkQTIaeivE9gGu97nM2Tv0chrAD(9bf9yd(9P7AnGJzscqFoxvtg87t316Sfy95UR1zyV3UTcRb6Z5QAYCOk4qz87dEnOifTSEwf1HdkY8xkzbovgCipv9kqAssWrKwNFFqrp2GFF6Uwd4y2MBgPzPjWelaIGWcZYvSSb1(Wc6h0xeMyXlqwWoqIfaHLwZcGiiSyPdhwqECqIvvbUzp8hSWghsisjKuKLCkewO56k1sD17gkOVimLXqTpMHs9RWXtiJcRNY)LsjjTc7(GIWkbqfdf29bfL)lLamABNKe29bfHvkMTv4r5WofqGB2d)blSXHeIucj7UUNtHWcnxxPwQRE3qb9fHPmgQ9XmuQFfoEczuy9u(VukjPvy3huewjaQyOWUpOO8FPeGrB7KKWUpOiSsXSTcpkh2PackAPU6DZ4aPcUW5(qvSBygk1Vcdy0QqD17MXbsfCHZ9HQy3WSIuy9SkQdhuKbFvFPZ7nWpnNNKyT6Q3nJdKk4cN7dvXUHzf1MB2d)blSXHeIucj9LwNtHWcnxxPwQRE3qb9fHPmgQ9XmuQFfoEczuy9u(VusrRaeQbHwktWZxfmdL6xHJhTaijjaHAqOLYeGfqicu(3Pmo6M7XMHs9RWXJwa0ojPvy3huewjaQyOWUpOO8FPeGrB7KKWUpOiSsXSTcpkh2PackAPU6DZ4aPcUW5(qvSBygk1Vcdy0QqD17MXbsfCHZ9HQy3WSIuy9SkQdhuKbFvFPZ7nWpnNNKyT6Q3nJdKk4cN7dvXUHzf1MBgPzPjWelifq0NfyXcYT6CZE4pyHnoKqKsiXIpZbNmSNj9QiUzKMfK76Ws7pHzXYo970WYdzzHjw2EF63qSCflBqTpSyz)c7SCyw8Nf0YY7dk6Xiszw6WHfcinnybGaaPYsQJFAAWcCyXkyz79bVguelOFAe0cnPu9SGFpGaMB2d)blSXHeIucja95CvnHMYtjLWVp9BO8vzmu7dAa66fPeoI0687dk6Xg87t)gkERarDneoTsD8ttJmqxViexzaaaKkabqBe11q40sD17g87dEnOOmLgbTqtkvFgd1(yWVhqaPAfT5MrAwqURdlT)eMfl70VtdlpKfKIX)DwaxZvOybqyOk2n4M9WFWcBCiHiLqcqFoxvtOP8usjlJ)75RY9HQy3anaD9IuszKkoI068UJFcWaSPBbadar8w4isRZVpOOhBWVp9BOMw52iElLr07AQEdgU0zyp)7uUdhc)gQCvnbI4kBqB72icagLrlIRU6DZ4aPcUW5(qvSBygk1VcZnJ0S0eyIfKIX)DwUILnO2hwq)G(IWelWHLRZsbzz79PFdXILtRzPFplx9qwqECqIvvbw8QrkCiUzp8hSWghsisjKyz8FhnxxPwuqFryYOxLp5Iq2NKqb9fHjJxnYfHSxbqFoxvtMdNdAYbsTv069bf9M)sP8dZGhfVvKKqb9fHjJEv(KVkdWKK(HA)ZdL6xHbSYaODsI6Q3nuqFrykJHAFmdL6xHbSh(dwg87t)gYqiJcRNY)Lskux9UHc6lctzmu7JzfLKqb9fHjZvzmu7JcRb6Z5QAYGFF63q5RYyO2NKe1vVBcE(QGzOu)kmG9WFWYGFF63qgczuy9u(VusH1a95CvnzoCoOjhiPqD17MGNVkygk1Vcdyczuy9u(VusH6Q3nbpFvWSIssux9UzCGubx4CFOk2nmRifa95CvnzSm(VNVk3hQIDJKeRb6Z5QAYC4CqtoqsH6Q3nbpFvWmuQFfoEczuy9u(VuIBgPzPjWelBVp9BiwUolxXIvUkFyb9d6lctOHLRyzdQ9Hf0pOVimXcSyXkqelVpOOhZcCy5HSenWalBqTpSG(b9fHjUzp8hSWghsisjKGFF63qCZinlacUw)7ZIB2d)blSXHeIucjZQYE4pyL1h(rt5PKsDxR)9zXnZnJ0Saimuf7gSy5(DwqECqIvvbUzp8hSWgvO)knoqQGlCUpuf7gO56kPU6DtWZxfmdL6xHJxz0YnJ0S0eyIL4a6r)bKyzZIpPSyzNkw8NfnHXS87EXIvWsSGXjgSGFpGaMfVaz5HSmuFi8ololawjaYc(9acS4yw0(tS4ywIGy8PQjwGdl)LsSCplyil3ZIpZbKWSGuYc)S49NgwCwIjIyb)EabwiKfDdH5M9WFWcBuH(JiLqId6r)bKYyl(KIMqJGMYVpOOhRKYO56kPU6DJQR9kqzyp7AD(3Vcfox(VgYGFpGaGBsfQRE3O6AVcug2ZUwN)9RqHZ(e8Im43dia4MurlRbHVXb9O)aszSfFsZGEQJIm)fq4kukS2d)blJd6r)bKYyl(KMb9uhfzUk31hQ9xrlRbHVXb9O)aszSfFsZ7KRn)fq4kujjGW34GE0FaPm2IpP5DY1MHs9RWXhZ2jjGW34GE0FaPm2IpPzqp1rrg87beaCmvacFJd6r)bKYyl(KMb9uhfzgk1Vcdy0Qae(gh0J(diLXw8jnd6PokY8xaHRq1MBgPzPjWelihwaHiqSy5(DwqECqIvvbwSStflrqm(u1elEbYc83PXYHjwSC)ololXcgNyWI6Q3zXYovSas4gv4kuCZE4pyHnQq)rKsijalGqeO8VtzC0n3JrZ1vYAWzDGMcMdGyfTAb0NZv1KjalGqeOmiHBubfwhGqni0szcE(QGzihSrsI6Q3nbpFvWSIAROL6Q3nQU2RaLH9SR15F)ku4C5)Aid(9ack1KjjQRE3O6AVcug2ZUwN)9RqHZ(e8Im43diOut2ojrfIXk6hQ9ppuQFfgWkdG2CZinlacq0NfhZYVtS0Vb)SGkaYYvS87elolXcgNyWILRaHwyboSy5(Dw(DIfRgnMZlwux9olWHfl3VZIZstIimfyjoGE0Fajw2S4tklEbYIf)Ew6WHfKhhKyvvGLRZY9SybwplQelRiwCu(vSOsD4qS87elbqwoml9Ro8obYn7H)Gf2Oc9hrkHK(AAKH9mPxfHMRRuRwTux9Ur11EfOmSNDTo)7xHcNl)xdzWVhqiEaDsI6Q3nQU2RaLH9SR15F)ku4SpbVid(9acXdOBROL1biqQ86naP63BmjjwRU6DZ4aPcUW5(qvSBywrTBROf4SoqtbZbqCssac1GqlLj45RcMHs9RWXJwaKK0kabsLxVPou7FU7KIaeQbHwktawaHiq5FNY4OBUhBgk1VchpAbq72TtsAbcFJd6r)bKYyl(KMb9uhfzgk1VchFtQiaHAqOLYe88vbZqP(v44vgakcqGu51BkkmqnCaBNKC1tteu7pbM7hQ9ppuQFfgWnPcRdqOgeAPmbpFvWmKd2ijjabsLxVbHgZ5Lc1vVBq4kWHaZuAe0cnPu9MvussacKkVEdqQ(9gJc1vVBghivWfo3hQIDdZqP(vyaJyvOU6DZ4aPcUW5(qvSBywrCZinli3RaPzz79rdhqwSC)ololfzHLybJtmyrD17S4filipoiXQQalhUq3ZIRcxplpKfvILfMa5M9WFWcBuH(JiLqsWRaPZQREhnLNskHFF0WbenxxPwQRE3O6AVcug2ZUwN)9RqHZL)RHmdL6xHJhXyqBsI6Q3nQU2RaLH9SR15F)ku4SpbViZqP(v44rmg02wrRaeQbHwktWZxfmdL6xHJhXKK0kaHAqOLYqPrql0KvHfOzOu)kC8igfwRU6DdcxboeyMsJGwOjLQptfnOUytMvKIaeivE9geAmNxTBRWX)46Ce0cnXRumba3msZIvFLgXY27dEnOimlwUFNfNLybJtmyrD17SOUEwk4ZILDQyjcc1xHILoCyb5XbjwvfyboSy14kWHazzl6M7XCZE4pyHnQq)rKsib)(GxdkcnxxPwQRE3O6AVcug2ZUwN)9RqHZL)RHm43diepatsux9Ur11EfOmSNDTo)7xHcN9j4fzWVhqiEa2wrRaeivE9M6qT)5UtjjbiudcTuMGNVkygk1VchpIjjXAG(CUQMmbWCawG3FWsH1biqQ86ni0yoVssAfGqni0szO0iOfAYQWc0muQFfoEeJcRvx9UbHRahcmtPrql0Ks1NPIguxSjZksracKkVEdcnMZR2Tv0YAq4B6RPrg2ZKEvK5VacxHkjX6aeQbHwktWZxfmd5GnssSoaHAqOLYeGfqicu(3Pmo6M7XMHCWgT5MrAwS6R0iw2EFWRbfHzrL6WHyb5WciebIB2d)blSrf6pIucj43h8AqrO56k1kaHAqOLYeGfqicu(3Pmo6M7XMHs9RWagTkSgCwhOPG5aiwrlG(CUQMmbybeIaLbjCJkKKeGqni0szcE(QGzOu)kmGrBBfa95CvnzcG5aSaV)GvBfwdcFtFnnYWEM0RIm)fq4kukcqGu51BQd1(N7oPWAWzDGMcMdGyfuqFryYCv2RgkC8pUohbTqt8wba4MrAwS6WcDplGWNfW1Cfkw(DIfQazb2zXQ1bsfCHzbqyOk2nqdlGR5kuSGWvGdbYcLgbTqtkvplWHLRy53jw0o(zbvaKfyNfVyb9d6lctCZE4pyHnQq)rKsibOpNRQj0uEkPei8ZdHERBOuQEmAa66fPul1vVBghivWfo3hQIDdZqP(v44rBsI1QRE3moqQGlCUpuf7gMvuBfTux9UbHRahcmtPrql0Ks1NPIguxSjZqP(vyaJkaAsDK1wrl1vVBOG(IWugd1(ygk1VchpQaOj1rwsI6Q3nuqFrykRxLpMHs9RWXJkaAsDK1MB2d)blSrf6pIucj4v1VHqtOrqt53hu0Jvsz0CDLgQpeE3v1KI3hu0B(lLYpmdEu8kdOv4r5WofqqbqFoxvtgq4Nhc9w3qPu9yUzp8hSWgvO)isjKKcHv)gcnHgbnLFFqrpwjLrZ1vAO(q4DxvtkEFqrV5Vuk)Wm4rXRCmnOvHhLd7uabfa95CvnzaHFEi0BDdLs1J5M9WFWcBuH(JiLqc(jT2NCx7dHMqJGMYVpOOhRKYO56knuFi8URQjfVpOO38xkLFyg8O4vgqJOHs9RWk8OCyNciOaOpNRQjdi8ZdHERBOuQEm3msZcGamUSalwcGSy5(D46zj4rrxHIB2d)blSrf6pIucjD4eOmSNl)xdHMRRKhLd7uabUzKMf0pncAHgwIfSazXYovS4QW1ZYdzHQNgwCwkYclXcgNyWILRaHwyXlqwWoqILoCyb5Xbjwvf4M9WFWcBuH(JiLqcLgbTqtwfwGO56k1Ic6lctg9Q8jxeY(KekOVimzWqTp5Iq2NKqb9fHjJxnYfHSpjrD17gvx7vGYWE2168VFfkCU8FnKzOu)kC8igdAtsux9Ur11EfOmSNDTo)7xHcN9j4fzgk1VchpIXG2Keh)JRZrql0epIfakcqOgeAPmbpFvWmKd2qH1GZ6anfmhaXTv0kaHAqOLYe88vbZqP(v44JjasscqOgeAPmbpFvWmKd2ODsYvpnrqT)eyUFO2)8qP(vyaRma4MrAwaeGOplZHA)zrL6WHyzHVcflipoCZE4pyHnQq)rKsiPVMgzypt6vrO56kfGqni0szcE(QGzihSHcG(CUQMmbWCawG3FWsrlh)JRZrql0epIfakSoabsLxVPou7FU7ussacKkVEtDO2)C3jfo(hxNJGwObWwbaARW6aeivE9gGu97ngfTSoabsLxVPou7FU7ussac1GqlLjalGqeO8VtzC0n3Jnd5GnARWAWzDGMcMdGyUzKMfKhhKyvvGfl7uXI)SGybaIyjoyajlTGJgAHgw(DVyXkaalXbdizXY97SGCybeIa1Mfl3VdxplAi(kuS8xkXYvSelnecQx4NfVazrFfXYkIfl3VZcYHfqicelxNL7zXIJzbKWnQabYn7H)Gf2Oc9hrkHeG(CUQMqt5PKsbWCawG3FWkRc9hnaD9IuYAWzDGMcMdGyfa95CvnzcG5aSaV)GLIwTC8pUohbTqt8iwaOOL6Q3niCf4qGzkncAHMuQ(mv0G6InzwrjjwhGaPYR3GqJ58QDsI6Q3nQAieuVWVzfPqD17gvnecQx43muQFfgWQRE3e88vbd4A8)Gv7KKREAIGA)jWC)qT)5Hs9RWawD17MGNVkyaxJ)hSsscqGu51BQd1(N7o1wrlRdqGu51BQd1(N7oLK0YX)46Ce0cna2kaqsci8n910id7zsVkY8xaHRq1wrlG(CUQMmbybeIaLbjCJkKKeGqni0szcWciebk)7ughDZ9yZqoyJ2T5M9WFWcBuH(JiLqsG0e(pxND9HQsP6rZ1vcOpNRQjtamhGf49hSYQq)5M9WFWcBuH(JiLqYvbFk)pyHMRReqFoxvtMayoalW7pyLvH(ZnJ0SG(4)s9NWSSdTWs6kSZsCWasw8HybLFfbYsenSGPaSa5M9WFWcBuH(JiLqcqFoxvtOP8usjhhbiPzJcObORxKsuqFryYCvwVkFq8MeP6H)GLb)(0VHmeYOW6P8FPeISMc6lctMRY6v5dI3cqJO31u9gmCPZWE(3PChoe(nu5QAceXJzBKQh(dwglJ)7gczuy9u(VucraWaqKkoI068UJFIBgPzXQVsJyz79bVgueMfl7uXYVtS0pu7plhMfxfUEwEilubIgw6dvXUblhMfxfUEwEilubIgwAaxS4dXI)SGybaIyjoyajlxXIxSG(b9fHj0WcYJdsSQkWI2XpMfVG)onS0KictbmlWHLgWflwGlnilqG0e8iwsHdXYV7flCIYaGL4GbKSyzNkwAaxSybU0Gf6Ew2EFWRbfXsbTWn7H)Gf2Oc9hrkHe87dEnOi0CDLAD1tteu7pbM7hQ9ppuQFfgWwrssl1vVBghivWfo3hQIDdZqP(vyaJkaAsDKH4b60TC8pUohbTqdsnMaOTc1vVBghivWfo3hQIDdZkQD7KKwo(hxNJGwObra95CvnzCCeGKMnkG4QRE3qb9fHPmgQ9XmuQFfgrGW30xtJmSNj9QiZFbeW5Hs9RqCaAqB8kRmassC8pUohbTqdIa6Z5QAY44iajnBuaXvx9UHc6lctz9Q8XmuQFfgrGW30xtJmSNj9QiZFbeW5Hs9RqCaAqB8kRmaARGc6lctMRYE1qrlRvx9Uj45RcMvusI1VRP6n43hnCanu5QAcSTIwTSoaHAqOLYe88vbZkkjjabsLxVbHgZ5LcRdqOgeAPmuAe0cnzvybAwrTtscqGu51BQd1(N7o1wrlRdqGu51Bas1V3yssSwD17MGNVkywrjjo(hxNJGwOjEelaANK06DnvVb)(OHdOHkxvtGkux9Uj45RcMvKIwQRE3GFF0Wb0GFpGaGJzsIJ)X15iOfAIhXcG2Ttsux9Uj45RcMvKcRvx9UzCGubx4CFOk2nmRifw)UMQ3GFF0Wb0qLRQjqUzKMLMatSaicclmlxXIvUkFyb9d6lctS4filyhiXcsPCDhraclTMfarqyXshoSG84GeRQcCZE4pyHnQq)rKsiPil5uiSqZ1vQL6Q3nuqFrykRxLpMHs9RWXtiJcRNY)LsjjTc7(GIWkbqfdf29bfL)lLamABNKe29bfHvkMTv4r5WofqGB2d)blSrf6pIucj7UUNtHWcnxxPwQRE3qb9fHPSEv(ygk1VchpHmkSEk)xkPOvac1GqlLj45RcMHs9RWXJwaKKeGqni0szcWciebk)7ughDZ9yZqP(v44rlaANK0kS7dkcReavmuy3huu(VucWOTDssy3huewPy2wHhLd7uabUzp8hSWgvO)isjK0xADofcl0CDLAPU6Ddf0xeMY6v5JzOu)kC8eYOW6P8FPKIwbiudcTuMGNVkygk1VchpAbqssac1GqlLjalGqeO8VtzC0n3JndL6xHJhTaODssRWUpOiSsauXqHDFqr5)sjaJ22jjHDFqryLIzBfEuoStbe4MrAwqkGOplWILai3Sh(dwyJk0FePesS4ZCWjd7zsVkIBgPzPjWelBVp9BiwEilrdmWYgu7dlOFqFryIf4WILDQy5kwGLUblw5Q8Hf0pOVimXIxGSSWelifq0NLObgWSCDwUIfRCv(Wc6h0xeM4M9WFWcBuH(JiLqc(9PFdHMRRef0xeMmxL1RYNKekOVimzWqTp5Iq2NKqb9fHjJxnYfHSpjrD17gl(mhCYWEM0RImRifQRE3qb9fHPSEv(ywrjjTux9Uj45RcMHs9RWa2d)blJLX)DdHmkSEk)xkPqD17MGNVkywrT5M9WFWcBuH(JiLqILX)DUzp8hSWgvO)isjKmRk7H)GvwF4hnLNsk1DT(3Nf3m3msZY27dEnOiw6WHLuiqkLQNLvPjmMLf(kuSelyCIb3Sh(dwyt316FFwkHFFWRbfHMRRK1ZQOoCqrgvx7vGYWE2168VFfkSHqV1ffrGCZinli3Xpl)oXci8zXY97S87elPq8ZYFPelpKfheKLv9NMLFNyj1rglGRX)dwSCyw2V3WY2Q63qSmuQFfML0L(Vi9rGS8qws9pSZskew9BiwaxJ)hS4M9WFWcB6Uw)7ZcrkHe8Q63qOj0iOP87dk6XkPmAUUsGW3KcHv)gYmuQFfo(Hs9RWioabisv5MKB2d)blSP7A9VplePessHWQFdXnZnJ0S0eyILT3h8AqrS8qwqGOiwwrS87elw9H8u1RaPHf1vVZY1z5EwSaxAqwiKfDdXIk1HdXs)QdVFfkw(DILIq2ZsWXplWHLhYc4knIfvQdhIfKdlGqeiUzp8hSWg8Re(9bVgueAUUsZQOoCqrM)sjlWPYGd5PQxbsJIwuqFryYCv2RgkSUvl1vVB(lLSaNkdoKNQEfinMHs9RWX7H)GLXY4)UHqgfwpL)lLqeamkROff0xeMmxLvH)Escf0xeMmxLXqTpjjuqFryYOxLp5Iq23ojrD17M)sjlWPYGd5PQxbsJzOu)kC8E4pyzWVp9BidHmkSEk)xkHiayuwrlkOVimzUkRxLpjjuqFryYGHAFYfHSpjHc6lctgVAKlczF72jjwRU6DZFPKf4uzWH8u1RaPXSIANK0sD17MGNVkywrjja95CvnzcWciebkds4gvOTIaeQbHwktawaHiq5FNY4OBUhBgYbBOiabsLxVPou7FU7uBfTSoabsLxVbHgZ5vssac1GqlLHsJGwOjRclqZqP(v44BY2kAPU6DtWZxfmROKeRdqOgeAPmbpFvWmKd2On3msZstGjwIdOh9hqILnl(KYILDQy53PHy5WSuqw8WFajwWw8jfnS4yw0(tS4ywIGy8PQjwGflyl(KYIL73zbGSahw6KfAyb)EabmlWHfyXIZsmrelyl(KYcgYYV7pl)oXsrwybBXNuw8zoGeMfKsw4NfV)0WYV7plyl(KYcHSOBim3Sh(dwyd(rKsiXb9O)aszSfFsrtOrqt53hu0Jvsz0CDLSge(gh0J(diLXw8jnd6PokY8xaHRqPWAp8hSmoOh9hqkJT4tAg0tDuK5QCxFO2FfTSge(gh0J(diLXw8jnVtU28xaHRqLKacFJd6r)bKYyl(KM3jxBgk1VchpABNKacFJd6r)bKYyl(KMb9uhfzWVhqaWXubi8noOh9hqkJT4tAg0tDuKzOu)kmGJPcq4BCqp6pGugBXN0mON6OiZFbeUcf3msZstGjmlihwaHiqSCDwqECqIvvbwomlRiwGdlnGlw8HybKWnQWvOyb5XbjwvfyXY97SGCybeIaXIxGS0aUyXhIfvsdTWIvaawIdgqYn7H)Gf2GFePescWciebk)7ughDZ9y0CDLSgCwhOPG5aiwrRwa95CvnzcWciebkds4gvqH1biudcTuMGNVkygYbBOW6zvuhoOit0CPWb8CD2NGxxihT0yFssux9Uj45RcMvuBfo(hxNJGwObWkzfaqrl1vVBOG(IWuwVkFmdL6xHJxzaKKOU6Ddf0xeMYyO2hZqP(v44vgaTtsuHySI(HA)ZdL6xHbSYaqH1biudcTuMGNVkygYbB0MBgPzb5Wc8(dwS0HdlUwZci8XS87(ZsQJaHzbVgILFNAWIpuHUNLH6dH3jqwSStflwToqQGlmlacdvXUbl7oMfnHXS87EXcAzbtbmldL6xDfkwGdl)oXccnMZlwux9olhMfxfUEwEilDxRzb27Sahw8QblOFqFryILdZIRcxplpKfczr3qCZE4pyHn4hrkHeG(CUQMqt5PKsGWppe6TUHsP6XObORxKsTux9UzCGubx4CFOk2nmdL6xHJhTjjwRU6DZ4aPcUW5(qvSBywrTvyT6Q3nJdKk4cN7dvXUrgFvFPZ7nWpnNBwrkAPU6DdcxboeyMsJGwOjLQptfnOUytMHs9RWagva0K6iRTIwQRE3qb9fHPmgQ9XmuQFfoEubqtQJSKe1vVBOG(IWuwVkFmdL6xHJhva0K6iljPL1QRE3qb9fHPSEv(ywrjjwRU6Ddf0xeMYyO2hZkQTcRFxt1BWqn(VazOYv1eyBUzKMfKdlW7pyXYV7plHDkGaMLRZsd4IfFiwGRhFGeluqFryILhYcS0nybe(S870qSahwoufCiw(9dZIL73zzdQX)fiUzp8hSWg8JiLqcqFoxvtOP8usjq4NHRhFGuMc6lctObORxKsTSwD17gkOVimLXqTpMvKcRvx9UHc6lctz9Q8XSIANK8UMQ3GHA8FbYqLRQjqUzp8hSWg8JiLqskew9Bi0eAe0u(9bf9yLugnxxPH6dH3DvnPOL6Q3nuqFrykJHAFmdL6xHJFOu)kCsI6Q3nuqFrykRxLpMHs9RWXpuQFfojbOpNRQjdi8ZW1Jpqktb9fHP2kgQpeE3v1KI3hu0B(lLYpmdEu8kdqfEuoStbeua0NZv1Kbe(5HqV1nukvpMB2d)blSb)isjKGxv)gcnHgbnLFFqrpwjLrZ1vAO(q4DxvtkAPU6Ddf0xeMYyO2hZqP(v44hk1VcNKOU6Ddf0xeMY6v5JzOu)kC8dL6xHtsa6Z5QAYac)mC94dKYuqFryQTIH6dH3DvnP49bf9M)sP8dZGhfVYauHhLd7uabfa95CvnzaHFEi0BDdLs1J5M9WFWcBWpIucj4N0AFYDTpeAcncAk)(GIESskJMRR0q9HW7UQMu0sD17gkOVimLXqTpMHs9RWXpuQFfojrD17gkOVimL1RYhZqP(v44hk1VcNKa0NZv1Kbe(z46XhiLPG(IWuBfd1hcV7QAsX7dk6n)Ls5hMbpkELb0k8OCyNciOaOpNRQjdi8ZdHERBOuQEm3msZstGjwaeGXLfyXsaKfl3Vdxplbpk6kuCZE4pyHn4hrkHKoCcug2ZL)RHqZ1vYJYHDkGa3msZstGjwSACf4qGSSfDZ9ywSC)olE1GfnSqXcvWfQDw0o(VcflOFqFryIfVaz5NgS8qw0xrSCplRiwSC)olaYLg7dlEbYcYJdsSQkWn7H)Gf2GFePesO0iOfAYQWcenxxPwTux9UHc6lctzmu7JzOu)kC8kdGKe1vVBOG(IWuwVkFmdL6xHJxza0wrac1GqlLj45RcMHs9RWXhtaOOL6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lcWa0kaqsI1ZQOoCqrMO5sHd456SpbVUqoAPX(yi0BDrrey72jjQRE3enxkCapxN9j41fYrln2hdqxVO4vcGigaKKeGqni0szcE(QGzihSHch)JRZrql0epIfaCZinlnbMyb5XbjwvfyXY97SGCybeIaHeRgxboeilBr3CpMfVazbewO7zbcKglZ9elaYLg7dlWHfl7uXsS0qiOEHFwSaxAqwiKfDdXIk1HdXcYJdsSQkWcHSOBim3Sh(dwyd(rKsibOpNRQj0uEkPuamhGf49hSY4hnaD9IuYAWzDGMcMdGyfa95CvnzcG5aSaV)GLIwTcqOgeAPmuAuJHCDgoGLxbYmuQFfgWkdOrmiQLYkJ4ZQOoCqrg8v9LoV3a)0CEBfe6TUOic0qPrngY1z4awEfO2jjo(hxNJGwOjELqSaqrlRFxt1B6RPrg2ZKEvKHkxvtGjjQRE3e88vbd4A8)Gv8biudcTuM(AAKH9mPxfzgk1VcJOMSTcq4BWRQFdzgk1VchVYaubi8nPqy1VHmdL6xHJVjv0ce(g8tATp5U2hYmuQFfo(MmjX631u9g8tATp5U2hYqLRQjW2ka6Z5QAY87ZP1zmriqt2IFVIwQRE3GWvGdbMP0iOfAsP6ZurdQl2KzfLKyDacKkVEdcnMZR2kEFqrV5Vuk)Wm4rXRU6DtWZxfmGRX)dwioamiMKevigROFO2)8qP(vyaRU6DtWZxfmGRX)dwjjbiqQ86n1HA)ZDNssux9UrvdHG6f(nRifQRE3OQHqq9c)MHs9RWawD17MGNVkyaxJ)hSqulelIpRI6WbfzIMlfoGNRZ(e86c5OLg7JHqV1ffrGTBRWA1vVBcE(QGzfPOL1biqQ86n1HA)ZDNsscqOgeAPmbybeIaL)DkJJU5ESzfLKOcXyf9d1(Nhk1Vcd4aeQbHwktawaHiq5FNY4OBUhBgk1VcJiaDss)qT)5Hs9RWivKQYnjaaS6Q3nbpFvWaUg)py1MBgPzPjWel)oXcszQ(9gdlwUFNfNfKhhKyvvGLF3FwoCHUNL(atzbqU0yF4M9WFWcBWpIucjJdKk4cN7dvXUbAUUsQRE3e88vbZqP(v44vgTjjQRE3e88vbd4A8)GfGJjaua0NZv1KjaMdWc8(dwz8Zn7H)Gf2GFePescKMW)56SRpuvkvpAUUsa95CvnzcG5aSaV)Gvg)kAzT6Q3nbpFvWaUg)pyfFmbqsI1biqQ86naP63BmTtsux9UzCGubx4CFOk2nmRifQRE3moqQGlCUpuf7gMHs9RWagXIOaSax3BIgkCyk76dvLs1B(lLYaD9IqulRvx9UrvdHG6f(nRifw)UMQ3GFF0Wb0qLRQjW2CZE4pyHn4hrkHKRc(u(FWcnxxjG(CUQMmbWCawG3FWkJFUzKMfKY(CUQMyzHjqwGflU6PV)iml)U)SyXRNLhYIkXc2bsGS0HdlipoiXQQalyil)U)S87udw8HQNflo(jqwqkzHFwuPoCiw(DkLB2d)blSb)isjKa0NZv1eAkpLuc7aPCho5GNVkGgGUErkzDac1GqlLj45RcMHCWgjjwd0NZv1KjalGqeOmiHBubfbiqQ86n1HA)ZDNssaN1bAkyoaI5MrAwAcmHzbqaI(SCDwUIfVyb9d6lctS4fil)CeMLhYI(kIL7zzfXIL73zbqU0yFqdlipoiXQQalEbYsCa9O)asSSzXNuUzp8hSWg8JiLqsFnnYWEM0RIqZ1vIc6lctMRYE1qHhLd7uabfQRE3enxkCapxN9j41fYrln2hdqxViadqRaakAbcFJd6r)bKYyl(KMb9uhfz(lGWvOssSoabsLxVPOWa1WbSTcG(CUQMmyhiL7Wjh88vbfTux9UzCGubx4CFOk2nmdL6xHbmITPBHweFwf1HdkYGVQV059g4NMZBRqD17MXbsfCHZ9HQy3WSIssSwD17MXbsfCHZ9HQy3WSIAZnJ0S0eyIfaXf97SS9(0DTMLObgWSCDw2EF6UwZYHl09SSI4M9WFWcBWpIucj43NUR1O56kPU6DdSOFhNJOjqr)blZksH6Q3n43NUR1MH6dH3DvnXn7H)Gf2GFePescEfiDwD17OP8usj87JgoGO56kPU6Dd(9rdhqZqP(vyaJwfTux9UHc6lctzmu7JzOu)kC8OnjrD17gkOVimL1RYhZqP(v44rBBfo(hxNJGwOjEela4MrAwS6R0imlXbdizrL6WHyb5WciebILf(kuS87elihwaHiqSeGf49hSy5HSe2PacSCDwqoSacrGy5WS4HF5ADdwCv46z5HSOsSeC8Zn7H)Gf2GFePesWVp41GIqZ1vkabsLxVPou7FU7KcG(CUQMmbybeIaLbjCJkOiaHAqOLYeGfqicu(3Pmo6M7XMHs9RWagTkSgCwhOPG5aiwbf0xeMmxL9QHch)JRZrql0eVvaaUzKMLMatSS9(0DTMfl3VZY2tATpSy1NR)S4filfKLT3hnCardlw2PILcYY27t31AwomlRi0Wsd4IfFiwUIfRCv(Wc6h0xeMyPdhwAseHPaMf4WYdzjAGbwaKln2hwSStflUkeiXcIfaSehmGKf4WIdg5)bKybBXNuw2DmlnjIWuaZYqP(vxHIf4WYHz5kw66d1(ByjUWNy539NLvbsdl)oXc2tjwcWc8(dwywUhDywaJWSu06hxZYdzz79P7AnlGR5kuSy16aPcUWSaimuf7gOHfl7uXsd4cDGSG)tRzHkqwwrSy5(DwqSaarooILoCy53jw0o(zbLgQ6ASHB2d)blSb)isjKGFF6UwJMRR07AQEd(jT2Nm4C93qLRQjqfw)UMQ3GFF0Wb0qLRQjqfQRE3GFF6UwBgQpeE3v1KIwQRE3qb9fHPSEv(ygk1VchFtQGc6lctMRY6v5Jc1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbiAbqsI6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lkELaiAbGch)JRZrql0epIfajjGW34GE0FaPm2IpPzqp1rrMHs9RWX3KjjE4pyzCqp6pGugBXN0mON6OiZv5U(qT)TveGqni0szcE(QGzOu)kC8kdaUzKMLMatSS9(GxdkIfaXf97SenWaMfVazbCLgXsCWaswSStflipoiXQQalWHLFNybPmv)EJHf1vVZYHzXvHRNLhYs31AwG9olWHLgWf6azj4rSehmGKB2d)blSb)isjKGFFWRbfHMRRK6Q3nWI(DCoOjFYap8blZkkjrD17geUcCiWmLgbTqtkvFMkAqDXMmROKe1vVBcE(QGzfPOL6Q3nJdKk4cN7dvXUHzOu)kmGrfanPoYq8aD6wo(hxNJGwObPgta0grXeXFxt1BkYsofcldvUQMavy9SkQdhuKbFvFPZ7nWpnNRqD17MXbsfCHZ9HQy3WSIssux9Uj45RcMHs9RWagva0K6idXd0PB54FCDocAHgKAmbq7Ke1vVBghivWfo3hQIDJm(Q(sN3BGFAo3SIssAPU6DZ4aPcUW5(qvSBygk1Vcdyp8hSm43N(nKHqgfwpL)lLuGJiToV74NamamwrsI6Q3nJdKk4cN7dvXUHzOu)kmG9WFWYyz8F3qiJcRNY)Lsjja95Cvnzo0dmhGf49hSueGqni0szUchM17QAkJElV(vAgKaEbYmKd2qbHERlkIanxHdZ6DvnLrVLx)kndsaVa1wH6Q3nJdKk4cN7dvXUHzfLKyT6Q3nJdKk4cN7dvXUHzfPW6aeQbHwkZ4aPcUW5(qvSBygYbBKKyDacKkVEdqQ(9gt7Keh)JRZrql0epIfakOG(IWK5QSxn4MrAwIX0GLhYsQJaXYVtSOs4NfyNLT3hnCazrTbl43diCfkwUNLvelO36ciOBWYvS4vdwq)G(IWelQRNfa5sJ9HLdxplUkC9S8qwujwIgyiqGCZE4pyHn4hrkHe87dEnOi0CDLExt1BWVpA4aAOYv1eOcRNvrD4GIm)LswGtLbhYtvVcKgfTux9Ub)(OHdOzfLK44FCDocAHM4rSaOTc1vVBWVpA4aAWVhqaWXurl1vVBOG(IWugd1(ywrjjQRE3qb9fHPSEv(ywrTvOU6Dt0CPWb8CD2NGxxihT0yFmaD9IamarmaqrRaeQbHwktWZxfmdL6xHJxzaKKynqFoxvtMaSacrGYGeUrfueGaPYR3uhQ9p3DQn3msZc6J)l1FcZYo0clPRWolXbdizXhIfu(veilr0WcMcWcKB2d)blSb)isjKa0NZv1eAkpLuYXrasA2OaAa66fPef0xeMmxL1RYheVjrQE4pyzWVp9BidHmkSEk)xkHiRPG(IWK5QSEv(G4Ta0i6DnvVbdx6mSN)Dk3HdHFdvUQMar8y2gP6H)GLXY4)UHqgfwpL)lLqeamwbArQ4isRZ7o(jebadAr831u9MY)1q4SQR9kqgQCvnbYnJ0Sy1xPrSS9(GxdkILRyXzbXGimfyzdQ9Hf0pOVimHgwaHf6Ew00ZY9SenWalaYLg7dlT(D)z5WSS7fOMazrTbl0970WYVtSS9(0DTMf9velWHLFNyjoyaz8iwaWI(kILoCyz79bVguuB0WciSq3ZceinwM7jw8IfaXf97SenWalEbYIMEw(DIfxfcKyrFfXYUxGAILT3hnCa5M9WFWcBWpIucj43h8AqrO56kz9SkQdhuK5VuYcCQm4qEQ6vG0OOL6Q3nrZLchWZ1zFcEDHC0sJ9Xa01lcWaeXaGKe1vVBIMlfoGNRZ(e86c5OLg7JbORxeGbiAbGI31u9g8tATpzW56VHkxvtGTv0Ic6lctMRYyO2hfo(hxNJGwObra95CvnzCCeGKMnkG4QRE3qb9fHPmgQ9XmuQFfgrGW30xtJmSNj9QiZFbeW5Hs9RqCaAqB8njassOG(IWK5QSEv(OWX)46Ce0cnicOpNRQjJJJaK0SrbexD17gkOVimL1RYhZqP(vyebcFtFnnYWEM0RIm)fqaNhk1VcXbObTXJybqBfwRU6DdSOFhNJOjqr)blZksH1VRP6n43hnCanu5QAcurRaeQbHwktWZxfmdL6xHJhXKKGHlT6vGMFFoToJjcbAmu5QAcuH6Q3n)(CADgtec0yWVhqaWXmMnDRzvuhoOid(Q(sN3BGFAohXrBBf9d1(Nhk1VchVYaaak6hQ9ppuQFfgWaeaaOTIwbiudcTugeUcCiWmo6M7XMHs9RWXJyssSoabsLxVbHgZ5vBUzKMLMatSaicclmlxXIvUkFyb9d6lctS4filyhiXcsPCDhraclTMfarqyXshoSG84GeRQcS4filwnUcCiqwq)0iOfAsP65M9WFWcBWpIucjfzjNcHfAUUsTux9UHc6lctz9Q8XmuQFfoEczuy9u(VukjPvy3huewjaQyOWUpOO8FPeGrB7KKWUpOiSsXSTcpkh2Packa6Z5QAYGDGuUdNCWZxf4M9WFWcBWpIucj7UUNtHWcnxxPwQRE3qb9fHPSEv(ygk1VchpHmkSEk)xkPW6aeivE9geAmNxjjTux9UbHRahcmtPrql0Ks1NPIguxSjZksracKkVEdcnMZR2jjTc7(GIWkbqfdf29bfL)lLamABNKe29bfHvkMjjQRE3e88vbZkQTcpkh2Packa6Z5QAYGDGuUdNCWZxfu0sD17MXbsfCHZ9HQy3WmuQFfgWTqBtdqeFwf1HdkYGVQV059g4NMZBRqD17MXbsfCHZ9HQy3WSIssSwD17MXbsfCHZ9HQy3WSIAZn7H)Gf2GFePes6lToNcHfAUUsTux9UHc6lctz9Q8XmuQFfoEczuy9u(VusH1biqQ86ni0yoVssAPU6DdcxboeyMsJGwOjLQptfnOUytMvKIaeivE9geAmNxTtsAf29bfHvcGkgkS7dkk)xkby02ojjS7dkcRumtsux9Uj45RcMvuBfEuoStbeua0NZv1Kb7aPCho5GNVkOOL6Q3nJdKk4cN7dvXUHzOu)kmGrRc1vVBghivWfo3hQIDdZksH1ZQOoCqrg8v9LoV3a)0CEsI1QRE3moqQGlCUpuf7gMvuBUzKMLMatSGuarFwGflbqUzp8hSWg8JiLqIfFMdozypt6vrCZinlnbMyz79PFdXYdzjAGbw2GAFyb9d6lctOHfKhhKyvvGLDhZIMWyw(lLy539IfNfKIX)DwiKrH1tSOP(ZcCybw6gSyLRYhwq)G(IWelhMLve3Sh(dwyd(rKsib)(0VHqZ1vIc6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXRg5Iq2NK0sD17gl(mhCYWEM0RImROKeCeP15Dh)eGbGXkqRcRdqGu51Bas1V3yssWrKwN3D8tagagRqracKkVEdqQ(9gtBfQRE3qb9fHPSEv(ywrjjTux9Uj45RcMHs9RWa2d)blJLX)DdHmkSEk)xkPqD17MGNVkywrT5MrAwAcmXcsX4)olWFNglhMyXY(f2z5WSCflBqTpSG(b9fHj0WcYJdsSQkWcCy5HSenWalw5Q8Hf0pOVimXn7H)Gf2GFePesSm(VZnJ0Sai4A9VplUzp8hSWg8JiLqYSQSh(dwz9HF0uEkPu316FFw2V9BBd]] )
    

end