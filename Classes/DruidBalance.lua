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
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
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
            duration = function () return talent.stellar_drift.enabled and 10 or 8 end,
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
            duration = 5,
            max_stack = 5
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 5,
            max_stack = 5,
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
        removeBuff( "starsurge_empowerment_lunar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
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
                eclipse.reset_stacks()
            elseif buff.eclipse_solar.up then
                eclipse.state = "IN_SOLAR"
                eclipse.reset_stacks()
            elseif buff.eclipse_lunar.up then
                eclipse.state = "IN_LUNAR"
                eclipse.reset_stacks()
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
                applyBuff( "balance_of_all_things_arcane", nil, 5, 8 )
                applyBuff( "balance_of_all_things_nature", nil, 5, 8 )
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
            
            if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )                
                state:RemoveAuraExpiration( "eclipse_solar" )
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                eclipse.state = "IN_SOLAR"
                eclipse.reset_stacks()
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
                eclipse.reset_stacks()
                if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                return
            end

            if eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" then
                -- Do nothing.
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
            cast = 1.7,
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
            cast = 1.7,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 0,
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
                if buff.warrior_of_elune.up or buff.elunes_wrath.up then return 0 end
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

            impact = function () end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" then
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

    spec:RegisterSetting( "solo_drift", false, {
        name = "Use |T236168:0|t Starfall in Single-Target with Stellar Drift",
        desc = "If checked, the addon will include a recommendation for |T236168:0|t Starfall in single-target.  This allows you to cast while moving during Starfall.\n\n" ..
            "This is a DPS loss but may be useful during M+.",
        icon = 236168,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = "full"        
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20210403, [[dav1PeqirWJar1LiHKnrI(eiOrjvCkPsRcKk9kqOzbj6wKqQDj0VargMiYXivAzsj9mruMgjexdsY2aPIVrcvghju15arX6ivrnpqk3JeSprOdsQOfsQkpesyIKQixeKQ2iPQQ(iikvgjikvDssOSsPeVeeGMPiQCtsvvANKQ0pbrPmuru1sjvvXtLIPsQWvjvHTccaFfeLmwqaTxs5VIAWehMQflWJP0Kb1LrTzv5Zqy0svNwXQbbqVwk1SP42cA3s(nWWjPJdc0Yv55qnDLUUQA7q03HuJhsQZdswpPQY8fP9JSMUA6qRb2xwtVTMuR6MKIKuYI6QBY0vxiJwZcLkR1O622ocwRP8qwRrFUXllR1O6qzaoSMo0AWG)zzTM(DvX6zibjeZ2)dIwqiKWt4347ak75Vfs4j0cjTMG)ywfR0c0AG9L10BRj1QUjPijLSOU6MmD1fvAn(F7bNwtZeIcTM(bgMlTaTgygB1A0NB8YYKONU)atTOt1BmK0kkjP1KAvxQfQfu07fcgRNPwu0KOtyygMKgGXps0h7HrQffnjOO3lemmjRFi4nppsSoMXKSasSqznCE9dbV4i1IIMe9hoeGKHj5xfBzm2pOibPFJhyymjDMihrjjQhJmJx)W)dbtIIorsupgzeV(H)hcUBKArrtIorcgysup264DkeKazD(2tY8izwietY2ZKG(afcsGERzuXCKArrtI(R3MjbfGcjOntY2ZK0Oo3SysCsmZUgMKqWXK8mmQNadtsN5rcuGpj9oCbHlj9ZsYSKGNWVz9IbFSbksqpBpj6dYMo1bjqKeuWggVJBirNMbrfY1IssMfcHjb3Eu7gPwu0KO)6Tzscb4Lei8ni638XH(uyiKeSLl)gaMexv1afjlGKaagtYBq0VysaLbQOwJzWlwthAnW8Z)MvthA6vxnDO142DaLwdgy8lhWEOwdxEGHH10N2QP3w10HwdxEGHH10NwdqvRbZRwJB3buAni9B8adR1G0nFwRbRYgtE9dbV4iE975gdjjsIUKOKKoKKajRB4AJ41pd4GJC5bggMK0usw3W1gXlBm(LHV5TrU8addtsxsstjbRYgtE9dbV4iE975gdjjssRAnWm2EJ6oGsRPHxmj6ea9Kakssgejb9S9G)sc8nVLeVGjb9S9K0S(zahmjEbtsRqKeW2Zh6bZAni9lxEiR1m4SdyTvtVjtthAnC5bggwtFAnavTgmVAnUDhqP1G0VXdmSwds38zTgSkBm51pe8IJ41V3CmjjsIUAnWm2EJ6oGsRPHxmjwd7izsq3ZfjnRFV5ysSErs)SK0kejz9dbVysq3p2EsgmjhByKETK8ahjBptc0BnJkMjzbKeWKOE8JVJHjXlysq3p2EsEJXWhjlGeRJxTgK(LlpK1AgC2AyhjRTA6vr00HwdxEGHH10NwJB3buAnb8H5R9ui0AGzS9g1DaLwJEGzs0hFy(ApfcsqpBpjOqNqsXkljGJe)T8rckafsqBMKPibf6eskwz1AS3S8nUwthssGelajxETXAq0V5NZKKMsscKybadmaDfTGcjOnN3EoJvNBwC8RssxsussW)9IwppLnECOpfMKejrxuPTA6fvA6qRHlpWWWA6tRXEZY34Anb)3lA98u24XH(uyssKeDrfjPPKeaWysusYBq0V5Jd9PWKansAfvAnWm2EJ6oGsRj5bljONTNeNeuOtiPyLLKT3xsgCbHljojj)3G9Je1dyjbCKGUNls2EMK3GOFjzWK4bG)sYciHlyTg3UdO0Aub7akTvtVqhnDO1WLhyyyn9P1au1AW8Q142DaLwds)gpWWAniDZN1AS8yiPdjDizQLpvGXxgo)ge9B(4qFkmjkAs0fvKOOjXcagya6kA98u24XH(uys6scKirxfFsK0LefiXYJHKoK0HKPw(ubgFz48Bq0V5Jd9PWKOOjrxurIIMeDBnjsu0KybadmaDfTGcjOnN3EoJvNBwC84qFkmjDjbsKORIpjs6sIsssGKZh4mJKRn6WW4iJ6bVysstjXcagya6kA98u24XH(uyssKKPw(ubgFz48Bq0V5Jd9PWKKMsIfamWa0v0ckKG2CE75mwDUzXXJd9PWKKijtT8Pcm(YW53GOFZhh6tHjrrtIUjrsAkjjqIfGKlV2yni638ZzTgygBVrDhqP1Gc3y)gFzmjO75TNps(4PqqckafsqBMKcGMe0JXqIBma0Kaf4tYcibVJXqI1XljBptc2dzs8qWVwsapsqbOqcAZqef6eskwzjX64fR1G0VC5HSwJfuibT5mmJHQSARMEvCA6qRHlpWWWA6tRbOQ1G5vRXT7akTgK(nEGH1Aq6MpR10HK1pe8g3jKZlidpmjjsIUOIK0usoFGZmsU2OddJJtrsIKGQKiPljkjPdjDijbsyi4Fuvz4ihQc1XUjdo4YlltsAkjwaWadqxroufQJDtgCWLxwoECOpfMeOrIUqNKirjjjqIfamWa0vKdvH6y3KbhC5LLJh7Wqrsxsusshs6qcs)gpWWrqL)yoV3uT5LefirxsstjbPFJhy4iOYFmN3BQ28sIcKKms6sIss6qYEt1M34QB8yhgQSfamWa0fjPPKS3uT5nU6gTaGbgGUIhh6tHjjrsMA5tfy8LHZVbr)Mpo0NctIIMeDtIKUKKMscs)gpWWrqL)yoV3uT5LefiPvsusshs2BQ28g3wJh7WqLTaGbgGUijnLK9MQnVXT1OfamWa0v84qFkmjjsYulFQaJVmC(ni638XH(uysu0KOBsK0LK0usq634bgocQ8hZ59MQnVKOajjrsxsstjXcqYLxBSnu34fjD1AGzS9g1DaLwJEGzyswajWSXHIKTNj5JDemjGhjOqNqsXkljO75IKpEkeKad(bgMeqrYhZK4fmjQhJKRLKp2rWKGUNls8IehgMegjxljdMepa8xswajWdR1G0VC5HSwJfoBbf8SdO0wn9Q410HwdxEGHH10NwdmJT3OUdO0A0dmtc0hQc1XUHeiBhC5LLjP1KWSftsa)ahtItck0jKuSYsYhZrTMYdzTgoufQJDtgCWLxwwRXEZY34AnwaWadqxrRNNYgpo0Nctc0iP1KirjjwaWadqxrlOqcAZ5TNZy15Mfhpo0Nctc0iP1KijnLKaagtIssEdI(nFCOpfMeOrsYuCAnUDhqP1WHQqDSBYGdU8YYARMEHmA6qRHlpWWWA6tRbMX2Bu3buAn6bMjPb8ngENcbj6p)aOib6GzlMKa(boMeNeuOtiPyLLKpMJAnLhYAnyW3y4DNcr((bqP1yVz5BCTglayGbORO1ZtzJhh6tHjbAKaDirjjjqcs)gpWWrlOqcAZzygdvzjjnLelayGbOROfuibT582ZzS6CZIJhh6tHjbAKaDirjji9B8adhTGcjOnNHzmuLLK0uscaymjkj5ni638XH(uysGgjTIkTg3UdO0AWGVXW7ofI89dGsB10RUjPPdTgU8addRPpTg3UdO0AMcBV)6bgodb)ET)WmmJCSSwJ9MLVX1Ac(Vx065PSXJd9PWKKij6IkTMYdzTMPW27VEGHZqWVx7pmdZihlRTA6vxD10HwdxEGHH10NwJB3buAn7nvBE1vRbMX2Bu3buAn6OFWKmysCsoF75Je24bGZxMe0ouKSasc92mjUXqcOi5JzsWRVKS3uT5ftYcijGjXmfdtYxLe0Z2tck0jKuSYsIxWKGcqHe0MjXlys(yMKTNjP1cMeSbSKaksSWKmpscaBpj7nvBEXK4htcOi5JzsWRVKS3uT5fR1yVz5BCTgK(nEGHJGk)XCEVPAZljkqsRKOKKeizVPAZBCBnESddv2cagya6IK0us6qcs)gpWWrqL)yoV3uT5LefirxsstjbPFJhy4iOYFmN3BQ28sIcKKms6sIss6qsW)9IwppLn(vjjnLelayGbORO1ZtzJhh6tHjbIK0kjjsYEt1M34QB0cagya6kc)pFhqrIss6qscKybi5YRnwdI(n)CMK0ussGeK(nEGHJwqHe0MZWmgQYssxsusscKybi5YRn2gQB8IK0usSaKC51gRbr)MFotIssq634bgoAbfsqBodZyOkljkjXcagya6kAbfsqBoV9CgRo3S44xLeLKKajwaWadqxrRNNYg)QKOKKoK0HKG)7fzRzuXC28l)Ihh6tHjjrs0njsstjj4)Er2AgvmNXaJFXJd9PWKKij6MejDjrjjjqY9l(boeCmWnEz5m4LDJjV9tHah5YdmmmjPPK0HKG)7fdCJxwodEz3yYB)uiW5Y3)Xr8622KOajOIK0usc(VxmWnEz5m4LDJjV9tHaN9Z6fhXRBBtIcKGks6ssxsstjj4)EX2tbFmCMdvbO5lKRnZfFig9JJFvs6ssAkjbamMeLK8ge9B(4qFkmjqJKwtIK0usq634bgocQ8hZ59MQnVKOajjPTA6v3w10HwdxEGHH10NwJ9MLVX1Aq634bgocQ8hZ59MQnVKKGcK0kjkjjbs2BQ28gxDJh7WqLTaGbgGUijnLeK(nEGHJGk)XCEVPAZljkqsRKOKKoKe8FVO1ZtzJFvsstjXcagya6kA98u24XH(uysGijTssIKS3uT5nUTgTaGbgGUIW)Z3buKOKKoKKajwasU8AJ1GOFZpNjjnLKeibPFJhy4OfuibT5mmJHQSK0LeLKKajwasU8AJTH6gVijnLelajxETXAq0V5NZKOKeK(nEGHJwqHe0MZWmgQYsIssSaGbgGUIwqHe0MZBpNXQZnlo(vjrjjjqIfamWa0v065PSXVkjkjPdjDij4)Er2AgvmNn)YV4XH(uyssKeDtIK0usc(VxKTMrfZzmW4x84qFkmjjsIUjrsxsusscKC)IFGdbhdCJxwodEz3yYB)uiWrU8addtsAkjDij4)EXa34LLZGx2nM82pfcCU89FCeVUTnjkqcQijnLKG)7fdCJxwodEz3yYB)uiWz)SEXr8622KOajOIKUK0LKUKKMssW)9ITNc(y4mhQcqZxixBMl(qm6hh)QKKMssaaJjrjjVbr)Mpo0Nctc0iP1KijnLeK(nEGHJGk)XCEVPAZljkqssAnUDhqP1S3uT5TvTvtV6MmnDO1WLhyyyn9P142DaLwZhZ5z5qSwdmJT3OUdO0A0dmJjXngsaBpFKaks(yMKz5qmjGIelSwJ9MLVX1Ac(Vx065PSXVkjPPKybi5YRnwdI(n)CMeLKG0VXdmC0ckKG2CgMXqvwsusIfamWa0v0ckKG2CE75mwDUzXXVkjkjjbsSaGbgGUIwppLn(vjrjjDiPdjb)3lYwZOI5S5x(fpo0NctsIKOBsKKMssW)9IS1mQyoJbg)Ihh6tHjjrs0njs6sIsssGK7x8dCi4yGB8YYzWl7gtE7NcboYLhyyysstj5(f)ahcog4gVSCg8YUXK3(PqGJC5bggMeLK0HKG)7fdCJxwodEz3yYB)uiW5Y3)Xr8622KKijjJK0usc(VxmWnEz5m4LDJjV9tHaN9Z6fhXRBBtsIKKms6ssxsstjj4)EX2tbFmCMdvbO5lKRnZfFig9JJFvsstjjaGXKOKK3GOFZhh6tHjbAK0AsARME1vr00HwdxEGHH10NwdmJT3OUdO0A0tSDGzsC7oGIeZGxscCmdtcOibp733buqYWigSwJB3buAn3VYUDhqLndE1AW7n2vtV6Q1yVz5BCTgK(nEGHJdo7awRXm4nxEiR14awB10RUOsthAnC5bggwtFAn2Bw(gxR5(f)ahcog4gVSCg8YUXK3(PqGJme8pQQmSwdEVXUA6vxTg3UdO0AUFLD7oGkBg8Q1yg8MlpK1Aca(QTA6vxOJMo0A4YdmmSM(0AC7oGsR5(v2T7aQSzWRwJzWBU8qwRbVAR2Q1ea8vthA6vxnDO1WLhyyyn9P142DaLwZ5i5c8X53XL(bLwdmJT3OUdO0A0)hx6huKGE2EsqHoHKIvwTg7nlFJR1e8FVO1ZtzJhh6tHjjrs0fvARMEBvthAnC5bggwtFAnavTgmVAnUDhqP1G0VXdmSwds38zTMeij4)EXa34LLZGx2nM82pfcCU89FC8RsIsssGKG)7fdCJxwodEz3yYB)uiWz)SEXXVQwdmJT3OUdO0AqrpBBJjzEKS9mj6dOtDqI9MLKG)7rYGjPaljFvsEGJeJV8rYhZAni9lxEiR1yVzlW(v1wn9MmnDO1WLhyyyn9P142DaLwJd7Q7GKZy0(fQ1yHYA486hcEXA6vxTg7nlFJR1e8FVyGB8YYzWl7gtE7Ncbox((poIx32MeOrIIqIssc(VxmWnEz5m4LDJjV9tHaN9Z6fhXRBBtc0irrirjjDijbsGbB0HD1DqYzmA)cZWEOJGJ7yBpfcsusscK42Dav0HD1DqYzmA)cZWEOJGJtLFMbr)sIss6qscKad2Od7Q7GKZy0(fM7z3e3X2EkeKKMscmyJoSRUdsoJr7xyUNDt84qFkmjjssYiPljPPKad2Od7Q7GKZy0(fMH9qhbhXRBBtc0ijzKOKeyWgDyxDhKCgJ2VWmSh6i44XH(uysGgjOIeLKad2Od7Q7GKZy0(fMH9qhbh3X2EkeK0vRbMX2Bu3buAn6bMjrNWU6oizsAq7xijO75IeFjXWymjBVxKOiKOpGo1bj41TTXK4fmjlGKJFhJ7jXjbAk0kj41TTjXXKy8LjXXKOcW4jWWKaos2jKjzwsWasMLe)UbjJjbcWpEjXFlFK4KKmiscEDBBsyuRohJ1wn9QiA6qRHlpWWWA6tRXT7akTglOqcAZ5TNZy15MfR1aZy7nQ7akTg9aZKGcqHe0Mjb9S9KGcDcjfRSKGUNlsuby8eyys8cMeW2Zh6bZKGE2EsCs0hqN6GKG)7rc6EUibMXqv2PqO1yVz5BCTMoKG0VXdmC0ckKG2CgMXqvwsusscKybadmaDfTEEkB8yhgksstjj4)ErRNNYg)QK0LeLK0HKG)7fdCJxwodEz3yYB)uiW5Y3)Xr8622KOajOIK0usc(VxmWnEz5m4LDJjV9tHaN9Z6fhXRBBtIcKGks6ssAkjbamMeLK8ge9B(4qFkmjqJeDtsB10lQ00HwdxEGHH10NwJB3buAnV)bvg8YS5xSwdmJT3OUdO0A0)aONehtY2ZK8MdVKGWctYuKS9mjoj6dOtDqc6PGbOjbCKGE2Es2EMeiGqDJxKe8FpsahjONTNeNefpeXSLeDc7Q7GKjPbTFHK4fmjO9zj5bosqHoHKIvwsMhjZscAqTKeWK8vjXr4trsa)ahtY2ZKyHjzWK8MAW9mSwJ9MLVX1A6qshsc(VxmWnEz5m4LDJjV9tHaNlF)hhXRBBtsIKOiKKMssW)9IbUXllNbVSBm5TFke4SFwV4iEDBBssKefHKUKOKKoKaF)bowGSfgtsAkjwaWadqxrRNNYgpo0NctsIKGQKijnLKoKybi5YRnwdI(n)CMeLKybadmaDfTGcjOnN3EoJvNBwC84qFkmjjscQsIKUK0LKUKKMsshsGbB0HD1DqYzmA)cZWEOJGJhh6tHjjrsu8KOKelayGbORO1ZtzJhh6tHjjrs0njsusIfGKlV2yX2dyahmjDjjnLKPw(ubgFz48Bq0V5Jd9PWKansu8KOKKeiXcagya6kA98u24XomuKKMsshsSaKC51gBd1nErIssc(VxS9uWhdN5qvaA(c5AJFvs6QTA6f6OPdTgU8addRPpTg3UdO0ASEzzto4)EAn2Bw(gxRPdjb)3lg4gVSCg8YUXK3(PqGZLV)JJhh6tHjjrsuKiQijnLKG)7fdCJxwodEz3yYB)uiWz)SEXXJd9PWKKijksevK0LeLK0HelayGbORO1ZtzJhh6tHjjrsuCKKMsshsSaGbgGUICOkanF5aqbhpo0NctsIKO4irjjjqsW)9ITNc(y4mhQcqZxixBMl(qm6hh)QKOKelajxETX2qDJxK0LKUKOKehVNBYQa08rsIkqsYssRj4)E5YdzTg86NbCWAnWm2EJ6oGsRbfEzzdjnRFgWbtc6z7jXjPy0KOpGo1bjb)3JeVGjbf6eskwzjzWfeUK4bG)sYcijGj5JzyTvtVkonDO1WLhyyyn9P142DaLwdE975gJwdmJT3OUdO0A0t)qvsAw)W)dbJjb9S9K4KOpGo1bjb)3JKG)ssbwsq3ZfjQaGzkeK8ahjOqNqsXkljGJeiGtbFmmjnQZnlwRXEZY34AnRB4AJ4Lng)YW382ixEGHHjrjjyE3PqGJyGbKHV5TKOKKG)7fXRFp3yIWa0L2QPxfVMo0A4YdmmSM(0AC7oGsRbV(H)hcwRbMX2Bu3buAn6PFOkjnRF4)HGXKGE2Es2EMKaGVKe8Fpsc(ljfyjbDpxKOcaMPqqYdCKyDsahjCOkanFKeakyTg7nlFJR1Kaji9B8adhT3Sfy)QKOKKoKybi5YRnwdI(n)CMK0usSaGbgGUIwppLnECOpfMKejrXrsAkjjqcs)gpWWrlC2ck4zhqrIsssGelajxETX2qDJxKKMsshsSaGbgGUICOkanF5aqbhpo0NctsIKO4irjjjqsW)9ITNc(y4mhQcqZxixBMl(qm6hh)QKOKelajxETX2qDJxK0LKUKOKKoKKajWGn((huzWlZMFXXDSTNcbjPPKKajwaWadqxrRNNYgp2HHIK0ussGelayGbOROfuibT582ZzS6CZIJh7WqrsxTvtVqgnDO1WLhyyyn9P142DaLwdE9d)peSwdmJT3OUdO0A0t)qvsAw)W)dbJjjGFGJjbfGcjOnR1yVz5BCTMoKybadmaDfTGcjOnN3EoJvNBwC84qFkmjqJeurIsssGe47pWXcKTWysusshsq634bgoAbfsqBodZyOkljPPKybadmaDfTEEkB84qFkmjqJeursxsuscs)gpWWrlC2ck4zhqrsxsusscKad247FqLbVmB(fh3X2EkeKOKelajxETXAq0V5NZKOKKeib((dCSazlmMeLKWwZOI54uzVGsB10RUjPPdTgU8addRPpTgGQwdMxTg3UdO0Aq634bgwRbPB(Swthsc(Vx8CKCb(4874s)GkECOpfMKejbvKKMsscKe8FV45i5c8X53XL(bv8Rssxsusshsc(VxS9uWhdN5qvaA(c5AZCXhIr)44XH(uysGgjiSWXqh1K0LeLK0HKG)7fzRzuXCgdm(fpo0NctsIKGWchdDutsAkjb)3lYwZOI5S5x(fpo0NctsIKGWchdDutsxTgygBVrDhqP1ONafeUKadwsG)3uiiz7zs4cMeWJe9hhjxGpMe9)XL(bfkjb(FtHGK2tbFmmjCOkanFHCTKaosMIKTNjX44Leewysaps8IeO3AgvmR1G0VC5HSwdmyZhdb)ZXHCTyTvtV6QRMo0A4YdmmSM(0AC7oGsRb)R3CSwJ9MLVX1Ao(DmU3dmmjkjz9dbVXDc58cYWdtsIKOl0HeLK4QzBpBBtIssq634bgocd28XqW)CCixlwRXcL1W51pe8I10RUARME1TvnDO1WLhyyyn9P142DaLwtiauV5yTg7nlFJR1C87yCVhyysusY6hcEJ7eY5fKHhMKejr3KfrfjkjXvZ2E22MeLKG0VXdmCegS5JHG)54qUwSwJfkRHZRFi4fRPxD1wn9QBY00HwdxEGHH10NwJB3buAn4Lng)YpJFSwJ9MLVX1Ao(DmU3dmmjkjz9dbVXDc58cYWdtsIKOl0HeisYXH(uysusIRMT9STnjkjbPFJhy4imyZhdb)ZXHCTyTgluwdNx)qWlwtV6QTA6vxfrthAnC5bggwtFAnUDhqP18aNLZGxU89FSwdmJT3OUdO0A0)a9scOiXctc6z7b)LeRRQofcTg7nlFJR14QzBpBBRTA6vxuPPdTgU8addRPpTg3UdO0A4qvaA(YbGcwRbMX2Bu3buAnqFOkanFKOpqbtc6EUiXda)LKfqcxlFK4KumAs0hqN6Ge0tbdqtIxWKGDKmjpWrck0jKuSYQ1yVz5BCTMoKWwZOI5O5x(Llg1ljPPKWwZOI5igy8lxmQxsstjHTMrfZrVGkxmQxsstjj4)EXa34LLZGx2nM82pfcCU89FC84qFkmjjsIIerfjPPKe8FVyGB8YYzWl7gtE7Ncbo7N1loECOpfMKejrrIOIK0usC8EUjRcqZhjjscKjjsusIfamWa0v065PSXJDyOirjjjqc89h4ybYwymjDjrjjDiXcagya6kA98u24XH(uyssKKKLejPPKybadmaDfTEEkB8yhgks6ssAkjbamMeLKm1YNkW4ldNFdI(nFCOpfMeOrIUjPTA6vxOJMo0A4YdmmSM(0AC7oGsR59pOYGxMn)I1AGzS9g1DaLwJ(ha9KCdI(LKa(boMKpEkeKGcDQ1yVz5BCTglayGbORO1ZtzJh7WqrIssq634bgoAHZwqbp7aksusshsC8EUjRcqZhjjscKjjsusscKybi5YRnwdI(n)CMK0usSaKC51gRbr)MFotIssC8EUjRcqZhjqJefjjs6sIss6qscKybi5YRnwdI(n)CMK0usSaGbgGUIwqHe0MZBpNXQZnloESddfjDjrjjjqc89h4ybYwyS2QPxDvCA6qRHlpWWWA6tRXT7akTglBy8oUj7MbrfY1Q1aZy7nQ7akTguOtiPyLLe09CrIVKazscIKOtCYtshWzaO5JKT3lsuKKirN4KNe0Z2tckafsqBUljONTh8xsma8uiizNqMKPirFgaa28XljEbtIzkMKVkjONTNeuakKG2mjZJKzjbTJjbMXqvwgwRXEZY34Anjqc89h4ybYwymjkjbPFJhy4OfoBbf8SdOirjjDiPdjoEp3KvbO5JKejbYKejkjPdjb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RssAkjjqIfGKlV2yBOUXls6ssAkjb)3lgyaayZhVXVkjkjj4)EXadaaB(4nECOpfMeOrsRjrcejPdjwqb)NnQESDWC2ndIkKRnUtiNr6Mptsxs6ssAkjbamMeLKm1YNkW4ldNFdI(nFCOpfMeOrsRjrcejPdjwqb)NnQESDWC2ndIkKRnUtiNr6MptsxsstjXcqYLxBSge9B(5mjDjrjjDijbsSaKC51gRbr)MFotsAkjDiXX75MSkanFKansuKKijnLeyWgF)dQm4LzZV44o22tHGKUKOKKoKG0VXdmC0ckKG2CgMXqvwsstjXcagya6kAbfsqBoV9CgRo3S44XomuK0LKUARME1vXRPdTgU8addRPpTg7nlFJR1KajW3FGJfiBHXKOKeK(nEGHJw4SfuWZoGIeLK0HKoK449CtwfGMpssKeitsKOKKoKe8FVy7PGpgoZHQa08fY1M5IpeJ(XXVkjPPKKajwasU8AJTH6gViPljPPKe8FVyGbaGnF8g)QKOKKG)7fdmaaS5J34XH(uysGgjjljsGijDiXck4)Sr1JTdMZUzquHCTXDc5ms38zs6ssxsstjjaGXKOKKPw(ubgFz48Bq0V5Jd9PWKansswsKars6qIfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZK0LK0usSaKC51gRbr)MFotsxsusshssGelajxETXAq0V5NZKKMsshsC8EUjRcqZhjqJefjjsstjbgSX3)GkdEz28loUJT9uiiPljkjPdji9B8adhTGcjOnNHzmuLLK0usSaGbgGUIwqHe0MZBpNXQZnloESddfjDjPRwJB3buAntz9R8DaL2QPxDHmA6qRHlpWWWA6tRbOQ1G5vRXT7akTgK(nEGH1Aq6MpR1WwZOI54uzZV8JeOljkEsGejUDhqfXRFV54iJA2(xoVtitcejjbsyRzuXCCQS5x(rc0LKoKaDibIKSUHRnIbFtg8YBpNFGJXBKlpWWWKaDjjzK0LeirIB3bur0NV9rg1S9VCENqMeisssXwjbsKGvzJj374L1AGzS9g1DaLwd0J3j0xgtspanjHFBpj6eN8K4htccFkgMev(ibZwqbR1G0VC5HSwJJvtE(AyR2QP3wtsthAnC5bggwtFAnUDhqP1Gx)W)dbR1aZy7nQ7akTg90puLKM1p8)qWysq3ZfjBptYBq0VKmys8aWFjzbKWfmkj5DCPFqrYGjXda)LKfqcxWOKeOaFs8JjXxsGmjbrs0jo5jzks8IeO3AgvmJssqHoHKIvwsmoEXK4fy75JefpeXSftc4ibkWNe0GVbMeas(SUkjHGJjz79Iekv3KirN4KNe09CrcuGpjObFdCbHljnRF4)HGjPaO1AS3S8nUwthscaymjkjzQLpvGXxgo)ge9B(4qFkmjqJefHK0us6qsW)9INJKlWhNFhx6huXJd9PWKansqyHJHoQjb6sILhdjDiXX75MSkanFKajsswsK0LeLKe8FV45i5c8X53XL(bv8Rssxs6ssAkjDiXX75MSkanFKarsq634bgo6y1KNVg2sc0LKG)7fzRzuXCgdm(fpo0NctcejbgSX3)GkdEz28loUJTnoFCOpfjqxsAnIkssKeD1njsstjXX75MSkanFKarsq634bgo6y1KNVg2sc0LKG)7fzRzuXC28l)Ihh6tHjbIKad247FqLbVmB(fh3X2gNpo0NIeOljTgrfjjsIU6MejDjrjjS1mQyoov2lOirjjDijbsc(Vx065PSXVkjPPKKajRB4AJ41pd4GJC5bggMKUKOKKoK0HKeiXcagya6kA98u24xLK0usSaKC51gBd1nErIsssGelayGbORihQcqZxoauWXVkjDjjnLelajxETXAq0V5NZK0LeLK0HKeiXcqYLxBejxBpuhjPPKKajb)3lA98u24xLK0usC8EUjRcqZhjjscKjjs6ssAkjDizDdxBeV(zahCKlpWWWKOKKG)7fTEEkB8RsIss6qsW)9I41pd4GJ41TTjbAKKmsstjXX75MSkanFKKijqMKiPljDjjnLKG)7fTEEkB8RsIsssGKG)7fphjxGpo)oU0pOIFvsusscKSUHRnIx)mGdoYLhyyyTvtVTQRMo0A4YdmmSM(0AC7oGsRPy05qaO0AGzS9g1DaLwJEGzs0FbGctYuKKC)YpsGERzuXmjEbtc2rYKazVBEqu))ngs0FbGIKh4ibf6eskwz1AS3S8nUwthsc(VxKTMrfZzZV8lECOpfMKejHrnB)lN3jKjjnLKoKy79dbJjrbsALeLKCST3peCENqMeOrcQiPljPPKy79dbJjrbssgjDjrjjUA22Z22ARMEBTvnDO1WLhyyyn9P1yVz5BCTMoKe8FViBnJkMZMF5x84qFkmjjscJA2(xoVtitIss6qIfamWa0v065PSXJd9PWKKijOkjsstjXcagya6kAbfsqBoV9CgRo3S44XH(uyssKeuLejDjjnLKoKy79dbJjrbsALeLKCST3peCENqMeOrcQiPljPPKy79dbJjrbssgjDjrjjUA22Z22AnUDhqP107MxoeakTvtVTMmnDO1WLhyyyn9P1yVz5BCTMoKe8FViBnJkMZMF5x84qFkmjjscJA2(xoVtitIss6qIfamWa0v065PSXJd9PWKKijOkjsstjXcagya6kAbfsqBoV9CgRo3S44XH(uyssKeuLejDjjnLKoKy79dbJjrbsALeLKCST3peCENqMeOrcQiPljPPKy79dbJjrbssgjDjrjjUA22Z22AnUDhqP18(gtoeakTvtVTQiA6qRHlpWWWA6tRbMX2Bu3buAnqwaONeqrIfwRXT7akTg0(Dd4YGxMn)I1wn92kQ00HwdxEGHH10NwJB3buAn41V3CSwdmJT3OUdO0A0dmtsZ63BoMKfqI6bSK0am(rc0BnJkMjbCKGUNlsMIeqzGIKK7x(rc0BnJkMjXlys(yMeila0tI6bSysMhjtrsY9l)ib6TMrfZAn2Bw(gxRHTMrfZXPYMF5hjPPKWwZOI5igy8lxmQxsstjHTMrfZrVGkxmQxsstjj4)Er0(Dd4YGxMn)IJFvsussW)9IS1mQyoB(LFXVkjPPK0HKG)7fTEEkB84qFkmjqJe3UdOIOpF7JmQz7F58oHmjkjj4)ErRNNYg)QK0vB10BRqhnDO142DaLwd6Z3ETgU8addRPpTvtVTQ400HwdxEGHH10NwJB3buAn3VYUDhqLndE1AmdEZLhYAnp3y2(7RTARwJdynDOPxD10HwdxEGHH10NwdqvRbZRwJB3buAni9B8adR1G0nFwRPdjb)3lUtiJgCvg(ypmyky(Ihh6tHjbAKGWchdDutcejjPOUKKMssW)9I7eYObxLHp2ddMcMV4XH(uysGgjUDhqfXRFV54iJA2(xoVtitcejjPOUKOKKoKWwZOI54uzZV8JK0usyRzuXCedm(Llg1ljPPKWwZOI5OxqLlg1ljDjPljkjj4)EXDcz0GRYWh7HbtbZx8RsIssUFXpWHGJ7eYObxLHp2ddMcMVidb)JQkdR1aZy7nQ7akTgu4g734lJjbDpV98rY2ZKONo2dT(A75JKG)7rc6Xyi55gdjG3Je0Z2pfjBptsXOEjX64vRbPF5YdzTg4J9Wm6XyYp3yYG3tB10BRA6qRHlpWWWA6tRbOQ1G5vRXT7akTgK(nEGH1Aq6MpR1KajS1mQyoovgdm(rIss6qcwLnM86hcEXr863BoMKejbvKOKK1nCTrm4BYGxE758dCmEJC5bggMK0usWQSXKx)qWloIx)EZXKKijkos6Q1aZy7nQ7akTgu4g734lJjbDpV98rsZ6h(FiysgmjOb32tI1X7uiibGKpsAw)EZXKmfjj3V8JeO3AgvmR1G0VC5HSwZGOahNXRF4)HG1wn9MmnDO1WLhyyyn9P142DaLwJfuibT582ZzS6CZI1AGzS9g1DaLwJEGzsqbOqcAZKGUNls8LedJXKS9ErcQsIeDItEs8cMeZumjFvsqpBpjOqNqsXkRwJ9MLVX1AsGe47pWXcKTWysusshs6qcs)gpWWrlOqcAZzygdvzjrjjjqIfamWa0v065PSXJDyOijnLKG)7fTEEkB8RssxsusshsC8EUjRcqZhjqJeuLejPPKG0VXdmCCquGJZ41p8)qWK0LeLK0HKG)7fzRzuXC28l)Ihh6tHjjrsGoKKMssW)9IS1mQyoJbg)Ihh6tHjjrsGoK0LeLK0HKei5(f)ahcog4gVSCg8YUXK3(PqGJC5bggMK0usc(VxmWnEz5m4LDJjV9tHaNlF)hhXRBBtsIKKmsstjj4)EXa34LLZGx2nM82pfcC2pRxCeVUTnjjssYiPljPPK8ge9B(4qFkmjqJeDtIeLKKajwaWadqxrRNNYgp2HHIKUARMEvenDO1WLhyyyn9P142DaLwZ5i5c8X53XL(bLwdmJT3OUdO0A0dmtI()4s)GIe0Z2tck0jKuSYQ1yVz5BCTMG)7fTEEkB84qFkmjjsIUOsB10lQ00HwdxEGHH10NwJB3buAn4F9MJ1ASqznCE9dbVyn9QRwJ9MLVX1A6qYXVJX9EGHjjnLKG)7fzRzuXCgdm(fpo0Nctc0ijzKOKe2AgvmhNkJbg)irjjhh6tHjbAKORIqIssw3W1gXGVjdE5TNZpWX4nYLhyyys6sIssw)qWBCNqoVGm8WKKij6QiKOOjbRYgtE9dbVysGijhh6tHjrjjDiHTMrfZXPYEbfjPPKCCOpfMeOrcclCm0rnjD1AGzS9g1DaLwJEGzsA(1BoMKPir1lyoCSKaks8cQTFkeKS9(sIzqYys0vrWSftIxWKyymMe0Z2tsi4ysw)qWlMeVGjXxs2EMeUGjb8iXjPby8JeO3AgvmtIVKORIqcMTysahjggJj54qFQPqqIJjzbKuGLKEh5uiizbKC87yCpjW)BkeKKC)YpsGERzuXS2QPxOJMo0A4YdmmSM(0AC7oGsRbV(9CJrRbMX2Bu3buAnqazwLKVkjnRFp3yiXxsCJHKDczmj)YWymjF8uiij5GY6NJjXlysMLKbtIha(ljlGe1dyjbCKy4LKTNjbRY2XnK42DafjMPyscydanj9EbBys0th7HbtbZhjGIKwjz9dbVyTg7nlFJR10HKG)7fXRFp3yIh)og37bgMeLK0HeSkBm51pe8IJ41VNBmKanssgjPPKKaj3V4h4qWXDcz0GRYWh7HbtbZxKHG)rvLHjPljPPKSUHRnIbFtg8YBpNFGJXBKlpWWWKOKKG)7fzRzuXCgdm(fpo0Nctc0ijzKOKe2AgvmhNkJbg)irjjb)3lIx)EUXepo0Nctc0irXrIssWQSXKx)qWloIx)EUXqsIkqIIqsxsusshssGK7x8dCi4ObkRFoo)mmVtHiJWmHQyoYqW)OQYWKKMsYoHmjkksueursIKe8FViE975gt84qFkmjqKKwjPljkjz9dbVXDc58cYWdtsIKGkTvtVkonDO1WLhyyyn9P142DaLwdE975gJwdmJT3OUdO0AGSMTNe90XEyWuW8rYhZK0S(9CJHKfqsBMvj5RsY2ZKe8FpscGIe3GbK8XtHGKM1VNBmKaksqfjy2ckymjGJedJXKCCOp1ui0AS3S8nUwZ9l(boeCCNqgn4Qm8XEyWuW8fzi4FuvzysuscwLnM86hcEXr863ZngssubssgjkjPdjjqsW)9I7eYObxLHp2ddMcMV4xLeLKe8FViE975gt843X4EpWWKKMsshsq634bgocFShMrpgt(5gtg8EKOKKoKe8FViE975gt84qFkmjqJKKrsAkjyv2yYRFi4fhXRFp3yijrsALeLKSUHRnIx2y8ldFZBJC5bggMeLKe8FViE975gt84qFkmjqJeursxs6ssxTvtVkEnDO1WLhyyyn9P1au1AW8Q142DaLwds)gpWWAniDZN1AC8EUjRcqZhjjsIIpjsu0K0HeDtIeOljb)3lUtiJgCvg(ypmyky(I41TTjPljkAs6qsW)9I41VNBmXJd9PWKaDjjzKajsWQSXK7D8YK0LefnjDibgSX3)GkdEz28loECOpfMeOljOIKUKOKKG)7fXRFp3yIFvTgygBVrDhqP1Gc3y)gFzmjO75TNpsCsAw)W)dbtYhZKGEmgsS(hZK0S(9CJHKfqYZngsaVhkjXlys(yMKM1p8)qWKSasAZSkj6PJ9WGPG5Je8622K8v1Aq6xU8qwRbV(9CJjJguB(5gtg8EARMEHmA6qRHlpWWWA6tRXT7akTg86h(FiyTgygBVrDhqP1OhyMKM1p8)qWKGE2Es0th7HbtbZhjlGK2mRsYxLKTNjj4)EKGE2EWFjXaWtHGKM1VNBmK8v3jKjXlys(yMKM1p8)qWKaksueisI(a6uhKGx32gtYV2XqIIqY6hcEXAn2Bw(gxRbPFJhy4i8XEyg9ym5NBmzW7rIssq634bgoIx)EUXKrdQn)CJjdEpsusscKG0VXdmCCquGJZ41p8)qWKKMsshsc(VxmWnEz5m4LDJjV9tHaNlF)hhXRBBtsIKKmsstjj4)EXa34LLZGx2nM82pfcC2pRxCeVUTnjjssYiPljkjbRYgtE9dbV4iE975gdjqJefHeLKG0VXdmCeV(9CJjJguB(5gtg8EARME1njnDO1WLhyyyn9P142DaLwJd7Q7GKZy0(fQ1yHYA486hcEXA6vxTg7nlFJR1Kaj7yBpfcsusscK42Dav0HD1DqYzmA)cZWEOJGJtLFMbr)ssAkjWGn6WU6oi5mgTFHzyp0rWr8622KanssgjkjbgSrh2v3bjNXO9lmd7HocoECOpfMeOrsY0AGzS9g1DaLwJEGzsWO9lKemGKT3xsGc8jbbVKe6OMKV6oHmjbqrYhpfcsMLehtIXxMehtIkaJNadtcOiXWymjBVxKKmsWRBBJjbCKab4hVKGUNlssgejbVUTnMeg1QZXARME1vxnDO1WLhyyyn9P142DaLwtiauV5yTgluwdNx)qWlwtV6Q1yVz5BCTMJFhJ79adtIssw)qWBCNqoVGm8WKKijDiPdj6QiKars6qcwLnM86hcEXr863BoMeOljTsc0LKG)7fzRzuXC28l)IFvs6ssxsGijhh6tHjPljqIKoKOljqKK1nCTXf9u5qaOWrU8addtsxsusshsSaGbgGUIwppLnESddfjkjjbsGV)ahlq2cJjrjjDibPFJhy4OfuibT5mmJHQSKKMsIfamWa0v0ckKG2CE75mwDUzXXJDyOijnLKeiXcqYLxBSge9B(5mjDjjnLeSkBm51pe8IJ41V3CmjqJKoK0HeOdjkAs6qsW)9IS1mQyoB(LFXVkjqxsALKUK0LeOljDirxsGijRB4AJl6PYHaqHJC5bggMKUK0LeLKKajS1mQyoIbg)YfJ6LK0us6qcBnJkMJtLXaJFKKMsshsyRzuXCCQCay7jjnLe2AgvmhNkB(LFK0LeLKKajRB4AJyW3KbV82Z5h4y8g5YdmmmjPPKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjjrfiPvuLejDjrjjDibRYgtE9dbV4iE97nhtc0ir3Kib6sshs0LeisY6gU24IEQCiau4ixEGHHjPljDjrjjoEp3KvbO5JKejbvjrIIMKG)7fXRFp3yIhh6tHjb6sc0HKUKOKKoKKajb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RssAkjS1mQyoovgdm(rsAkjjqIfGKlV2yBOUXls6Q1aZy7nQ7akTg9h(DmUNe9xaOEZXKmpsqHoHKIvwsgmjh7WqHss2E(ys8JjXWymjBVxKGksw)qWlMKPij5(LFKa9wZOIzsqpBpjnGv)JssmmgtY27fj6MejGTNp0dMjzks8cksGERzuXmjGJKVkjlGeurY6hcEXKeWpWXK4KKC)YpsGERzuXCKe9eOGWLKJFhJ7jb(FtHGeiGtbFmmjqFOkanFHCTK8ldJXKmfjnaJFKa9wZOIzTvtV62QMo0A4YdmmSM(0AC7oGsR5bolNbVC57)yTgygBVrDhqP1OhyMe9pqVKaksSWKGE2EWFjX6QQtHqRXEZY34AnUA22Z22ARME1nzA6qRHlpWWWA6tRXT7akTglBy8oUj7MbrfY1Q1aZy7nQ7akTg9aZKGcDcjfRSKaksSWK8ldJXK4fmjMPysMLKVkjONTNeuakKG2SwJ9MLVX1AsGe47pWXcKTWysuscs)gpWWrlC2ck4zhqrIss6qsW)9I41VNBmXVkjPPK449CtwfGMpssKeuLejDjrjjDijbsc(Vxedm4DSC8RsIsssGKG)7fTEEkB8RsIss6qscKybi5YRnwdI(n)CMK0usSaGbgGUIwqHe0MZBpNXQZnlo(vjrjjoEp3KvbO5JeOrcQsIKUKOKK1pe8g3jKZlidpmjjsIUOIeisIfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZKKMssaaJjrjjtT8Pcm(YW53GOFZhh6tHjbAK0AsKarsSGc(pBu9y7G5SBgevixBCNqoJ0nFMKUARME1vr00HwdxEGHH10NwJ9MLVX1AsGe47pWXcKTWysuscs)gpWWrlC2ck4zhqrIss6qsW)9I41VNBmXVkjPPK449CtwfGMpssKeuLejDjrjjDijbsc(Vxedm4DSC8RsIsssGKG)7fTEEkB8RsIss6qscKybi5YRnwdI(n)CMK0usSaGbgGUIwqHe0MZBpNXQZnlo(vjrjjoEp3KvbO5JeOrcQsIKUKOKK1pe8g3jKZlidpmjjssRjrcejXck4)Sr1JTdMZUzquHCTXDc5ms38zsstjjaGXKOKKPw(ubgFz48Bq0V5Jd9PWKansswsKarsSGc(pBu9y7G5SBgevixBCNqoJ0nFMKUAnUDhqP1mL1VY3buARME1fvA6qRHlpWWWA6tRXT7akTgoufGMVCaOG1AGzS9g1DaLwJEGzsG(qvaA(irFGcMeqrIfMe0Z2tsZ63Zngs(QK4fmjyhjtYdCKK8Fd2ps8cMeuOtiPyLvRXEZY34AnbamMeLKm1YNkW4ldNFdI(nFCOpfMeOrIUOIK0us6qsW)9IQ3eco4Xnz)SEn2S63G9lI0nFMeOrsROkjsstjj4)Er1Bcbh84MSFwVgBw9BW(fr6MptsIkqsROkjs6sIssc(VxeV(9CJj(vjrjjDiXcagya6kA98u24XH(uyssKeuLejPPKaF)bowGSfgtsxTvtV6cD00HwdxEGHH10NwJB3buAn4Lng)YpJFSwJfkRHZRFi4fRPxD1AS3S8nUwZXVJX9EGHjrjj7eY5fKHhMKejrxurIssWQSXKx)qWloIx)EZXKansuesusIRMT9STnjkjPdjb)3lA98u24XH(uyssKeDtIK0ussGKG)7fTEEkB8RssxTgygBVrDhqP1O)WVJX9K8m(XKaks(QKSassgjRFi4ftc6z7b)LeuOtiPyLLKaEkeK4bG)sYciHrT6CmjEbtsbwsai5Z6QQtHqB10RUkonDO1WLhyyyn9P142DaLwZ7FqLbVmB(fR1aZy7nQ7akTg9aZKO)bqpjZJKPWdmtIxKa9wZOIzs8cMeZumjZsYxLe0Z2tItsY)ny)ir9aws8cMeDc7Q7GKjPbTFHAn2Bw(gxRHTMrfZXPYEbfjkjXvZ2E22MeLKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjbAK0kQsIeLK0HeyWgDyxDhKCgJ2VWmSh6i44o22tHGK0ussGelajxETXIThWaoysstjbRYgtE9dbVyssKKwjPR2QPxDv8A6qRHlpWWWA6tRXT7akTg863ZngTgygBVrDhqP1OhyMeNKM1VNBmKazR4TNe1dyj5xggJjPz975gdjdMe3CSddfjFvsahjqb(K4htIha(ljlGeas(SUkj6eN8An2Bw(gxRj4)ErqXBpoRYNLv3buXVkjkjPdjb)3lIx)EUXep(DmU3dmmjPPK449CtwfGMpssKeitsK0vB10RUqgnDO1WLhyyyn9P142DaLwdE975gJwdmJT3OUdO0A0t)qvs0jo5jjGFGJjbfGcjOntc6z7jPz975gdjEbtY2ZfjnRF4)HG1AS3S8nUwJfGKlV2yni638Zzsusshsq634bgoAbfsqBodZyOkljPPKybadmaDfTEEkB8RssAkjb)3lA98u24xLKUKOKelayGbOROfuibT582ZzS6CZIJhh6tHjbAKGWchdDutc0Lelpgs6qIJ3ZnzvaA(ibsKGQKiPljkjj4)Er863ZnM4XH(uysGgjkcjkjjbsGV)ahlq2cJ1wn92AsA6qRHlpWWWA6tRXEZY34AnwasU8AJ1GOFZpNjrjjDibPFJhy4OfuibT5mmJHQSKKMsIfamWa0v065PSXVkjPPKe8FVO1ZtzJFvs6sIssSaGbgGUIwqHe0MZBpNXQZnloECOpfMeOrc0HeLKe8FViE975gt8RsIssyRzuXCCQSxqrIsssGeK(nEGHJdIcCCgV(H)hcMeLKKajW3FGJfiBHXAnUDhqP1Gx)W)dbRTA6TvD10HwdxEGHH10NwJB3buAn41p8)qWAnWm2EJ6oGsRrpWmjnRF4)HGjb9S9K4fjq2kE7jr9awsahjZJeOaFieMeas(SUkj6eN8KGE2EsGc8pskg1ljwhVrs0Pbdib(hQIjrN4KNeFjz7zs4cMeWJKTNjbcaU2EOosc(VhjZJKM1VNBmKGg8nWfeUK8CJHeW7rcOirribCKyymMK1pe8I1AS3S8nUwtW)9IGI3EC2Ay)Yih8aQ4xLK0us6qscKGx)EZXrxnB7zBBsusscKG0VXdmCCquGJZ41p8)qWKKMsshsc(Vx065PSXJd9PWKansqfjkjj4)ErRNNYg)QKKMsshsc(Vx8CKCb(4874s)GkECOpfMeOrcclCm0rnjqxsS8yiPdjoEp3KvbO5JeirsYsIKUKOKKG)7fphjxGpo)oU0pOIFvs6ssxsuscs)gpWWr863ZnMmAqT5NBmzW7rIssWQSXKx)qWloIx)EUXqc0ijzK0LeLK0HKei5(f)ahcoUtiJgCvg(ypmyky(Ime8pQQmmjPPKGvzJjV(HGxCeV(9CJHeOrsYiPR2QP3wBvthAnC5bggwtFAnUDhqP1um6CiauAnWm2EJ6oGsRrpWmj6VaqHjzksAag)ib6TMrfZK4fmjyhjtI()BmKO)cafjpWrck0jKuSYQ1yVz5BCTMoKe8FViBnJkMZyGXV4XH(uyssKeg1S9VCENqMK0us6qIT3pemMefiPvsusYX2E)qW5DczsGgjOIKUKKMsIT3pemMefijzK0LeLK4QzBpBBRTA6T1KPPdTgU8addRPpTg7nlFJR10HKG)7fzRzuXCgdm(fpo0NctsIKWOMT)LZ7eYKKMsshsS9(HGXKOajTsIsso227hcoVtitc0ibvK0LK0usS9(HGXKOajjJKUKOKexnB7zBBTg3UdO0A6DZlhcaL2QP3wvenDO1WLhyyyn9P1yVz5BCTMoKe8FViBnJkMZyGXV4XH(uyssKeg1S9VCENqMeLK0HelayGbORO1ZtzJhh6tHjjrsqvsKKMsIfamWa0v0ckKG2CE75mwDUzXXJd9PWKKijOkjs6ssAkjDiX27hcgtIcK0kjkj5yBVFi48oHmjqJeursxsstjX27hcgtIcKKms6sIssC1STNTT1AC7oGsR59nMCiauARMEBfvA6qRHlpWWWA6tRbMX2Bu3buAn6bMjbYca9KaksqHEsRXT7akTg0(Dd4YGxMn)I1wn92k0rthAnC5bggwtFAnavTgmVAnUDhqP1G0VXdmSwds38zTgSkBm51pe8IJ41V3CmjjsIIqcej5zaGJKoKe64LpOYiDZNjb6sIUjLejqIKwtIKUKarsEga4iPdjb)3lIx)W)dbN5qvaA(c5AZyGXViEDBBsGejkcjD1AGzS9g1DaLwdkCJ9B8LXKGUN3E(izbK8XmjnRFV5ysMIKgGXpsq3p2Esgmj(scQiz9dbVyiQljpWrcJKpOiP1KuuKe64LpOibCKOiK0S(H)hcMeOpufGMVqUwsWRBBJ1Aq6xU8qwRbV(9MJZtLXaJFARMEBvXPPdTgU8addRPpTg3UdO0AqF(2R1aZy7nQ7akTg9aZKazD(2tYuK0am(rc0BnJkMjbCKmpskajnRFV5ysqpgdjVzjzQfqck0jKuSYsIxqfcowRXEZY34AnDiHTMrfZrZV8lxmQxsstjHTMrfZrVGkxmQxsuscs)gpWWXbNTg2rYK0LeLK0HK1pe8g3jKZlidpmjjsIIqsAkjS1mQyoA(LF5PYTssAkjVbr)Mpo0Nctc0ir3KiPljPPKe8FViBnJkMZyGXV4XH(uysGgjUDhqfXRFV54iJA2(xoVtitIssc(VxKTMrfZzmW4x8RssAkjS1mQyoovgdm(rIsssGeK(nEGHJ41V3CCEQmgy8JK0usc(Vx065PSXJd9PWKansC7oGkIx)EZXrg1S9VCENqMeLKKaji9B8adhhC2AyhjtIssc(Vx065PSXJd9PWKansyuZ2)Y5DczsussW)9IwppLn(vjjnLKG)7fphjxGpo)oU0pOIFvsuscwLnMCVJxMKejjPi0HeLK0HeSkBm51pe8IjbAkqsYijnLKeizDdxBed(Mm4L3Eo)ahJ3ixEGHHjPljPPKKaji9B8adhhC2AyhjtIssc(Vx065PSXJd9PWKKijmQz7F58oHS2QP3wv8A6qRHlpWWWA6tRbMX2Bu3buAn6bMjPz97nhtY8izkssUF5hjqV1mQygLKmfjnaJFKa9wZOIzsafjkcejz9dbVysahjlGe1dyjPby8JeO3AgvmR142DaLwdE97nhRTA6TviJMo0A4YdmmSM(0AGzS9g1DaLwJ(3nMT)(AnUDhqP1C)k72Dav2m4vRXm4nxEiR18CJz7VV2QTAnp3y2(7RPdn9QRMo0A4YdmmSM(0AC7oGsRbV(H)hcwRbMX2Bu3buAnnRF4)HGj5boscbi5qUws(LHXys(4PqqI(a6uhAn2Bw(gxRjbsUFXpWHGJbUXllNbVSBm5TFke4idb)JQkdRTA6TvnDO1WLhyyyn9P142DaLwd(xV5yTgluwdNx)qWlwtV6Q1yVz5BCTgyWgdbG6nhhpo0NctsIKCCOpfMeOljT2kjqIeDv8AnWm2EJ6oGsRbfoEjz7zsGbljONTNKTNjjeGxs2jKjzbK4WWK8RDmKS9mjHoQjb(F(oGIKbts)SrsA(1BoMKJd9PWKe(n7OAggMKfqsOV2EscbG6nhtc8)8DaL2QP3KPPdTg3UdO0AcbG6nhR1WLhyyyn9PTARwdE10HME1vthAnC5bggwtFAnUDhqP1CosUaFC(DCPFqP1aZy7nQ7akTg9aZKS9mjqaW12d1rc6z7jXjbf6eskwzjz79LKbxq4sY7aHKK8Fd2pTg7nlFJR1e8FVO1ZtzJhh6tHjjrs0fvARMEBvthAnC5bggwtFAnUDhqP1Gx)W)dbR1aZy7nQ7akTg9aZK0S(H)hcMKfqsBMvj5RsY2ZKONo2ddMcMpsc(VhjZJKzjbn4BGjHrT6Cmjb8dCmjVPgC)uiiz7zskg1ljwhVKaoswajW)qvsc4h4ysqbOqcAZAn2Bw(gxR5(f)ahcoUtiJgCvg(ypmyky(Ime8pQQmmjkjPdjS1mQyoov2lOirjjjqshs6qsW)9I7eYObxLHp2ddMcMV4XH(uyssKe3UdOIOpF7JmQz7F58oHmjqKKKI6sIss6qcBnJkMJtLdaBpjPPKWwZOI54uzmW4hjPPKWwZOI5O5x(Llg1ljDjjnLKG)7f3jKrdUkdFShgmfmFXJd9PWKKijUDhqfXRFV54iJA2(xoVtitcejjPOUKOKKoKWwZOI54uzZV8JK0usyRzuXCedm(Llg1ljPPKWwZOI5OxqLlg1ljDjPljPPKKajb)3lUtiJgCvg(ypmyky(IFvs6ssAkjDij4)ErRNNYg)QKKMscs)gpWWrlOqcAZzygdvzjPljkjXcagya6kAbfsqBoV9CgRo3S44XomuKOKelajxETXAq0V5NZK0LeLK0HKeiXcqYLxBSnu34fjPPKybadmaDf5qvaA(YbGcoECOpfMKejrXtsxsusshsc(Vx065PSXVkjPPKKajwaWadqxrRNNYgp2HHIKUARMEtMMo0A4YdmmSM(0AC7oGsRXHD1DqYzmA)c1ASqznCE9dbVyn9QRwJ9MLVX1AsGeyWgDyxDhKCgJ2VWmSh6i44o22tHGeLKKajUDhqfDyxDhKCgJ2VWmSh6i44u5Nzq0VKOKKoKKajWGn6WU6oi5mgTFH5E2nXDSTNcbjPPKad2Od7Q7GKZy0(fM7z3epo0NctsIKGks6ssAkjWGn6WU6oi5mgTFHzyp0rWr8622KanssgjkjbgSrh2v3bjNXO9lmd7HocoECOpfMeOrsYirjjWGn6WU6oi5mgTFHzyp0rWXDSTNcHwdmJT3OUdO0A0dmtIoHD1DqYK0G2Vqsq3ZfjBpFmjdMKcqIB3bjtcgTFHOKehtIXxMehtIkaJNadtcOibJ2VqsqpBpjTsc4i5XO5Je8622ysahjGIeNKKbrsWO9lKemGKT3xs2EMKIrtcgTFHK43nizmjqa(Xlj(B5JKT3xsWO9lKeg1QZXyTvtVkIMo0A4YdmmSM(0AC7oGsRXckKG2CE75mwDUzXAnWm2EJ6oGsRrpWmMeuakKG2mjZJeuOtiPyLLKbtYxLeWrcuGpj(XKaZyOk7uiibf6eskwzjb9S9KGcqHe0MjXlysGc8jXpMKa2aqtIIKej6eN8An2Bw(gxRjbsGV)ahlq2cJjrjjDiPdji9B8adhTGcjOnNHzmuLLeLKKajwaWadqxrRNNYgp2HHIeLKKaj3V4h4qWr1Bcbh84MSFwVgBw9BW(f5YdmmmjPPKe8FVO1ZtzJFvs6sIssC8EUjRcqZhjqJefjjsusshsc(VxKTMrfZzZV8lECOpfMKejr3KijnLKG)7fzRzuXCgdm(fpo0NctsIKOBsK0LK0usEdI(nFCOpfMeOrIUjrIsssGelayGbORO1ZtzJh7WqrsxTvtVOsthAnC5bggwtFAnavTgmVAnUDhqP1G0VXdmSwds38zTMoKe8FV45i5c8X53XL(bv84qFkmjjscQijnLKeij4)EXZrYf4JZVJl9dQ4xLKUKOKKoKe8FVy7PGpgoZHQa08fY1M5IpeJ(XXJd9PWKansqyHJHoQjPljkjPdjb)3lYwZOI5mgy8lECOpfMKejbHfog6OMK0usc(VxKTMrfZzZV8lECOpfMKejbHfog6OMKUAnWm2EJ6oGsRbfGcE2buK8ahjUXqcmyXKS9(ssO3MXKG)htY2ZqrIFCbHljh)og3ZWKGUNls0FCKCb(ys0)hx6huK07ysmmgtY27fjOIemBXKCCOp1uiibCKS9mjTH6gVij4)EKmys8aWFjzbK8CJHeW7rc4iXlOib6TMrfZKmys8aWFjzbKWOwDowRbPF5YdzTgyWMpgc(NJd5AXARMEHoA6qRHlpWWWA6tRXT7akTMqaOEZXAn2Bw(gxR543X4EpWWKOKK1pe8g3jKZlidpmjjsIUTsIss6qIRMT9STnjkjbPFJhy4imyZhdb)ZXHCTys6Q1yHYA486hcEXA6vxTvtVkonDO1WLhyyyn9P142DaLwd(xV5yTg7nlFJR1C87yCVhyysusY6hcEJ7eY5fKHhMKejr3wjrjjDiXvZ2E22MeLKG0VXdmCegS5JHG)54qUwmjD1ASqznCE9dbVyn9QR2QPxfVMo0A4YdmmSM(0AC7oGsRbVSX4x(z8J1AS3S8nUwZXVJX9EGHjrjjRFi4nUtiNxqgEyssKeDHoKOKKoK4QzBpBBtIssq634bgocd28XqW)CCixlMKUAnwOSgoV(HGxSME1vB10lKrthAnC5bggwtFAnUDhqP18aNLZGxU89FSwdmJT3OUdO0A0dmtI(hOxsafjwysqpBp4VKyDv1PqO1yVz5BCTgxnB7zBBTvtV6MKMo0A4YdmmSM(0AC7oGsRHdvbO5lhakyTgygBVrDhqP1OhyMeiGtbFmmjnQZnlMe0Z2tIxqrIbuiiHlWhrpjghVtHGeO3AgvmtIxWKShuKSasmtXKmljFvsqpBpjj)3G9JeVGjbf6eskwz1AS3S8nUwths6qsW)9IS1mQyoJbg)Ihh6tHjjrs0njsstjj4)Er2AgvmNn)YV4XH(uyssKeDtIKUKOKelayGbORO1ZtzJhh6tHjjrsswsKOKKoKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjbAK0QIKejPPKKaj3V4h4qWr1Bcbh84MSFwVgBw9BW(fzi4Fuvzys6ssxsstjj4)Er1Bcbh84MSFwVgBw9BW(fr6MptsIkqsRkUKijnLelayGbORO1ZtzJh7WqrIssC8EUjRcqZhjjscKjjTvtV6QRMo0A4YdmmSM(0AC7oGsRXYggVJBYUzquHCTAnWm2EJ6oGsRrpWmjOqNqsXkljONTNeuakKG2mKGaof8XWK0Oo3Sys8cMeyqbHljaK8H(MLjj5)gSFKaosq3Zfj6ZaaWMpEjbn4BGjHrT6Cmjb8dCmjOqNqsXkljmQvNJXAn2Bw(gxRjbsGV)ahlq2cJjrjji9B8adhTWzlOGNDafjkjPdjoEp3KvbO5JKejbYKejkjPdjb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RssAkjjqIfGKlV2yBOUXls6ssAkjwasU8AJ1GOFZpNjjnLKG)7fdmaaS5J34xLeLKe8FVyGbaGnF8gpo0Nctc0iP1KibIK0HKoKazib6sY9l(boeCu9MqWbpUj7N1RXMv)gSFrgc(hvvgMKUKars6qIfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZK0LKUK0LeLKKajb)3lA98u24xLeLK0HKeiXcqYLxBSge9B(5mjPPKybadmaDfTGcjOnN3EoJvNBwC8RssAkjbamMeLKm1YNkW4ldNFdI(nFCOpfMeOrIfamWa0v0ckKG2CE75mwDUzXXJd9PWKarsGoKKMsYulFQaJVmC(ni638XH(uysuuKORIpjsGgjTMejqKKoKybf8F2O6X2bZz3miQqU24oHCgPB(mjDjPR2QPxDBvthAnC5bggwtFAn2Bw(gxRjbsGV)ahlq2cJjrjji9B8adhTWzlOGNDafjkjPdjoEp3KvbO5JKejbYKejkjPdjb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RssAkjjqIfGKlV2yBOUXls6ssAkjwasU8AJ1GOFZpNjjnLKG)7fdmaaS5J34xLeLKe8FVyGbaGnF8gpo0Nctc0ijzjrcejPdjDibYqc0LK7x8dCi4O6nHGdECt2pRxJnR(ny)Ime8pQQmmjDjbIK0HelOG)Zgvp2oyo7MbrfY1g3jKZiDZNjPljDjPljkjjbsc(Vx065PSXVkjkjPdjjqIfGKlV2yni638ZzsstjXcagya6kAbfsqBoV9CgRo3S44xLK0uscaymjkjzQLpvGXxgo)ge9B(4qFkmjqJelayGbOROfuibT582ZzS6CZIJhh6tHjbIKaDijnLKPw(ubgFz48Bq0V5Jd9PWKOOirxfFsKansswsKars6qIfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZK0LKUAnUDhqP1mL1VY3buARME1nzA6qRHlpWWWA6tRbOQ1G5vRXT7akTgK(nEGH1Aq6MpR1KajwaWadqxrRNNYgp2HHIK0ussGeK(nEGHJwqHe0MZWmgQYsIssSaKC51gRbr)MFotsAkjW3FGJfiBHXAnWm2EJ6oGsRbca)gpWWK8XmmjGIepymZomMKT3xsq71sYcijGjb7izysEGJeuOtiPyLLemGKT3xs2Egks8JRLe0oEzysGa8Jxsc4h4ys2EouRbPF5YdzTgSJKZpWLTEEkR2QPxDvenDO1WLhyyyn9P142DaLwZ7FqLbVmB(fR1aZy7nQ7akTg9aZys0)aONK5rYuK4fjqV1mQyMeVGjzVHXKSasmtXKmljFvsqpBpjj)3G9dLKGcDcjfRSK4fmj6e2v3bjtsdA)c1AS3S8nUwdBnJkMJtL9cksusIRMT9STnjkjj4)Er1Bcbh84MSFwVgBw9BW(fr6Mptc0iPvfjjsusshsGbB0HD1DqYzmA)cZWEOJGJ7yBpfcsstjjbsSaKC51gl2Ead4GjPljkjbPFJhy4i2rY5h4YwppLvB10RUOsthAnC5bggwtFAnUDhqP1Gx)EUXO1aZy7nQ7akTg9aZKazR4TNKM1VNBmKOEalMK5rsZ63ZngsgCbHljFvTg7nlFJR1e8FViO4ThNv5ZYQ7aQ4xLeLKe8FViE975gt843X4EpWWARME1f6OPdTgU8addRPpTg7nlFJR1e8FViE9Zao44XH(uysGgjOIeLK0HKG)7fzRzuXCgdm(fpo0NctsIKGksstjj4)Er2AgvmNn)YV4XH(uyssKeursxsusIJ3ZnzvaA(ijrsGmjP142DaLwJ1llBYb)3tRj4)E5YdzTg86NbCWARME1vXPPdTgU8addRPpTg3UdO0AWRFp3y0AGzS9g1DaLwJE6hQIjrN4KNKa(boMeuakKG2mjF8uiiz7zsqbOqcAZKybf8SdOizbKy7zBBsMhjOauibTzsgmjUD)UXafjEa4VKSascysSoE1AS3S8nUwZ6gU2iEzJXVm8nVnYLhyyysuscM3Dke4igyaz4BEljkjj4)Er863ZnMimaDPTA6vxfVMo0A4YdmmSM(0AC7oGsRbV(H)hcwRbMX2Bu3buAn6PFOkMehRssa)ahtckafsqBMKpEkeKS9mjOauibTzsSGcE2buKSasS9STnjZJeuakKG2mjdMe3UF3yGIepa8xswajbmjwhVAn2Bw(gxRXcqYLxBSge9B(5mjkjbPFJhy4OfuibT5mmJHQSKOKelayGbOROfuibT582ZzS6CZIJhh6tHjbAKGksusscKaF)bowGSfgRTA6vxiJMo0A4YdmmSM(0AC7oGsRbV(9CJrRbMX2Bu3buAn6bMjPz975gdjONTNKMLng)irpDZBjXlyskajnRFgWbJssq3ZfjfGKM1VNBmKmys(QOKeOaFs8JjzkssUF5hjqV1mQyMeWrYcir9awss(Vb7hjO75IepaGKjbYKej6eN8KaosCyvFhKmjy0(fssVJjrXdrmBXKCCOp1uiibCKmysMIKNzq0VAn2Bw(gxRzDdxBeVSX4xg(M3g5Ydmmmjkjjbsw3W1gXRFgWbh5Ydmmmjkjj4)Er863ZnM4XVJX9EGHjrjjDij4)Er2AgvmNn)YV4XH(uyssKeOdjkjHTMrfZXPYMF5hjkjj4)Er1Bcbh84MSFwVgBw9BW(fr6Mptc0iPvuLejPPKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjjrfiPvuLejkjXX75MSkanFKKijqMKijnLeyWgDyxDhKCgJ2VWmSh6i44XH(uyssKefpjPPK42Dav0HD1DqYzmA)cZWEOJGJtLFMbr)ssxsusscKybadmaDfTEEkB8yhgkTvtVTMKMo0A4YdmmSM(0AC7oGsRbV(H)hcwRbMX2Bu3buAn6bMjPz9d)pemjq2kE7jr9awmjEbtc8puLeDItEsq3ZfjOqNqsXkljGJKTNjbcaU2EOosc(VhjdMepa8xswajp3yib8EKaosGc8HqysSUkj6eN8An2Bw(gxRj4)ErqXBpoBnSFzKdEav8RssAkjb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RssAkjb)3lA98u24xLeLK0HKG)7fphjxGpo)oU0pOIhh6tHjbAKGWchdDutc0Lelpgs6qIJ3ZnzvaA(ibsKKSKiPljkjj4)EXZrYf4JZVJl9dQ4xLK0ussGKG)7fphjxGpo)oU0pOIFvsusscKybadmaDfphjxGpo)oU0pOIh7WqrsAkjjqIfGKlV2isU2EOos6ssAkjoEp3KvbO5JKejbYKejkjHTMrfZXPYEbL2QP3w1vthAnC5bggwtFAnUDhqP1Gx)W)dbR1aZy7nQ7akTgDCqrYcij0BZKS9mjbmEjb8iPz9ZaoyscGIe8622tHGKzj5Rsce8p22gOizks8cksGERzuXmjb)LKK)BW(rYGRLepa8xswajbmjQhWAzyTg7nlFJR1SUHRnIx)mGdoYLhyyysusscKC)IFGdbh3jKrdUkdFShgmfmFrgc(hvvgMeLK0HKG)7fXRFgWbh)QKKMsIJ3ZnzvaA(ijrsGmjrsxsussW)9I41pd4GJ41TTjbAKKmsusshsc(VxKTMrfZzmW4x8RssAkjb)3lYwZOI5S5x(f)QK0LeLKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjbAK0QIljsusshsSaGbgGUIwppLnECOpfMKejr3KijnLKeibPFJhy4OfuibT5mmJHQSKOKelajxETXAq0V5NZK0vB10BRTQPdTgU8addRPpTg3UdO0AWRF4)HG1AGzS9g1DaLwJE6hQssZ6h(FiysMIeNefheXSLKgGXpsGERzuXmkjbguq4sIHxsMLe1dyjj5)gSFK0z79LKbtsVxWggMKaOiHNTNps2EMKM1VNBmKyMIjbCKS9mj6eN8jczsIeZumjpWrsZ6h(Fi4UOKeyqbHljaK8H(MLjXlsGSv82tI6bSK4fmjgEjz7zs8aasMeZumj9EbBysAw)mGdwRXEZY34AnjqY9l(boeCCNqgn4Qm8XEyWuW8fzi4Fuvzysusshsc(Vxu9MqWbpUj7N1RXMv)gSFrKU5ZKansAvXLejPPKe8FVO6nHGdECt2pRxJnR(ny)IiDZNjbAK0kQsIeLKSUHRnIx2y8ldFZBJC5bggMKUKOKKG)7fzRzuXCgdm(fpo0NctsIKO4irjjS1mQyoovgdm(rIsssGKG)7fbfV94SkFwwDhqf)QKOKKeizDdxBeV(zahCKlpWWWKOKelayGbORO1ZtzJhh6tHjjrsuCKOKKoKybadmaDfBpf8XWzS6CZIJhh6tHjjrsuCKKMsscKybi5YRn2gQB8IKUARMEBnzA6qRHlpWWWA6tRXT7akTMIrNdbGsRbMX2Bu3buAn6bMjr)fakmjtrsY9l)ib6TMrfZK4fmjyhjtcK9U5br9)3yir)faksEGJeuOtiPyLLeVGjbc4uWhdtc0hQcqZxixRwJ9MLVX1A6qsW)9IS1mQyoB(LFXJd9PWKKijmQz7F58oHmjPPK0HeBVFiymjkqsRKOKKJT9(HGZ7eYKansqfjDjjnLeBVFiymjkqsYiPljkjXvZ2E22MeLKG0VXdmCe7i58dCzRNNYQTA6TvfrthAnC5bggwtFAn2Bw(gxRPdjb)3lYwZOI5S5x(fpo0NctsIKWOMT)LZ7eYKOKKeiXcqYLxBSnu34fjPPK0HKG)7fBpf8XWzoufGMVqU2mx8Hy0po(vjrjjwasU8AJTH6gViPljPPK0HeBVFiymjkqsRKOKKJT9(HGZ7eYKansqfjDjjnLeBVFiymjkqsYijnLKG)7fTEEkB8RssxsusIRMT9STnjkjbPFJhy4i2rY5h4YwppLvRXT7akTME38YHaqPTA6TvuPPdTgU8addRPpTg7nlFJR10HKG)7fzRzuXC28l)Ihh6tHjjrsyuZ2)Y5DczsusscKybi5YRn2gQB8IK0us6qsW)9ITNc(y4mhQcqZxixBMl(qm6hh)QKOKelajxETX2qDJxK0LK0us6qIT3pemMefiPvsusYX2E)qW5DczsGgjOIKUKKMsIT3pemMefijzKKMssW)9IwppLn(vjPljkjXvZ2E22MeLKG0VXdmCe7i58dCzRNNYQ142DaLwZ7Bm5qaO0wn92k0rthAnC5bggwtFAnWm2EJ6oGsRrpWmjqwaONeqrIfwRXT7akTg0(Dd4YGxMn)I1wn92QItthAnC5bggwtFAnUDhqP1Gx)EZXAnWm2EJ6oGsRrpWmjnRFV5yswajQhWssdW4hjqV1mQygLKGcDcjfRSK07ysmmgtYoHmjBVxK4KazD(2tcJA2(xMed)wsahjGYafjj3V8JeO3AgvmtYGj5RQ1yVz5BCTg2AgvmhNkB(LFKKMscBnJkMJyGXVCXOEjjnLe2Agvmh9cQCXOEjjnLKG)7fr73nGldEz28lo(vjrjjb)3lYwZOI5S5x(f)QKKMsshsc(Vx065PSXJd9PWKansC7oGkI(8TpYOMT)LZ7eYKOKKG)7fTEEkB8RssxTvtVTQ410HwdxEGHH10NwdmJT3OUdO0A0dmtcK15BpjGTNp0dMjbD)y7jzWKmfjnaJFKa9wZOIzusck0jKuSYsc4izbKOEaljj3V8JeO3AgvmR142DaLwd6Z3ETvtVTcz00HwdxEGHH10NwdmJT3OUdO0A0)UXS93xRXT7akTM7xz3UdOYMbVAnMbV5YdzTMNBmB)91wTvRr9ylimWxnDOPxD10HwJB3buAnTNc(y4mwDUzXAnC5bggwtFARMEBvthAnC5bggwtFAnavTgmVAnUDhqP1G0VXdmSwds38zTMK0AGzS9g1DaLwJo6zsq634bgMKbtcMxswajjrc6z7jPaKGxFjbuK8Xmj7nvBEXOKeDjbDpxKS9mjV5WljGIjzWKaks(ygLK0kjZJKTNjbZwqbtYGjXlyssgjZJKaW2tIFSwds)YLhYAnGk)XCEVPAZR2QP3KPPdTgU8addRPpTgGQwJddR142DaLwds)gpWWAniDZN1A0vRXEZY34An7nvBEJRUXp2dmmjkjzVPAZBC1nAbadmaDfH)NVdO0Aq6xU8qwRbu5pMZ7nvBE1wn9QiA6qRHlpWWWA6tRbOQ14WWAnUDhqP1G0VXdmSwds38zTMw1AS3S8nUwZEt1M342A8J9adtIss2BQ28g3wJwaWadqxr4)57akTgK(LlpK1Aav(J58Et1MxTvtVOsthAnUDhqP1ecav7PYpWfQ1WLhyyyn9PTA6f6OPdTgU8addRPpTg3UdO0AqF(2R1yMIZwyTgDtsRXEZY34AnDiHTMrfZrZV8lxmQxsstjHTMrfZXPYMF5hjPPKWwZOI54u5aW2tsAkjS1mQyo6fu5Ir9ssxTgygBVrDhqP1K8hBD8ssRKazD(2tIxWK4K0S(H)hcMeqrsJoib9S9KO3br)sI(3zs8cMe9b0PoibCK0S(9MJjbS98HEWS2QPxfNMo0A4YdmmSM(0AS3S8nUwthsyRzuXC08l)YfJ6LK0usyRzuXCCQS5x(rsAkjS1mQyoovoaS9KKMscBnJkMJEbvUyuVK0LeLKOEmYOUr0NV9KOKKeir9yKXwJOpF71AC7oGsRb95BV2QPxfVMo0A4YdmmSM(0AS3S8nUwtcKC)IFGdbhdCJxwodEz3yYB)uiWrU8addtsAkjjqIfGKlV2yni638ZzsstjjbsWQSXKx)qWloIx)EUXqIcKOljPPKKajRB4AJLV)JX5a34LLJC5bggwRXT7akTg863BowB10lKrthAnC5bggwtFAn2Bw(gxR5(f)ahcog4gVSCg8YUXK3(PqGJC5bggMeLKybi5YRnwdI(n)CMeLKGvzJjV(HGxCeV(9CJHefirxTg3UdO0AWRF4)HG1wTvB1AqYhEaLMEBnPw1nPK1AsAnO9RMcbwRbYsN6p6vX0lKD6zsirh9mjtOk4wsEGJeieMF(3Sqijhdb)ZXWKGbHmj(FbH(YWKy79cbJJulj3umjqh9mjOaui5BzysAMquqcgQADutIIIKfqsY9DsGhKdEafjav(8fCK0bsDjPtROUBKAj5MIjrXPNjbfGcjFldtceU3uT5nQBececjzbKaH7nvBEJRUriqiKKoTI6UrQLKBkMefNEMeuakK8Tmmjq4Et1M3yRriqiKKfqceU3uT5nUTgHaHqs60kQ7gPwsUPys0vx9mjOaui5BzysGW7x8dCi4ieiesYcibcVFXpWHGJqGrU8adddHK0rxu3nsTKCtXKORU6zsqbOqY3YWKaH7nvBEJ6gHaHqswajq4Et1M34QBececjPJUOUBKAj5MIjrxD1ZKGcqHKVLHjbc3BQ28gBncbcHKSasGW9MQnVXT1ieiesshDrD3i1sYnftIUTQNjbfGcjFldtceE)IFGdbhHaHqswajq49l(boeCecmYLhyyyiKKo6I6UrQLKBkMeDBvptckafs(wgMeiCVPAZBu3ieiesYcibc3BQ28gxDJqGqijD0f1DJulj3umj62QEMeuakK8Tmmjq4Et1M3yRriqiKKfqceU3uT5nUTgHaHqs6OlQ7gPwsUPys0nz6zsqbOqY3YWKaH3V4h4qWriqiKKfqceE)IFGdbhHaJC5bgggcjPtROUBKAHAbYsN6p6vX0lKD6zsirh9mjtOk4wsEGJeiu9ylimWxiKKJHG)5yysWGqMe)VGqFzysS9EHGXrQLKBkMKKPNjbfGcjFldtceU3uT5nQBececjzbKaH7nvBEJRUriqiKKoTI6UrQLKBkMefrptckafs(wgMeiCVPAZBS1ieiesYcibc3BQ28g3wJqGqijDAf1DJulj3umjkE9mjOaui5BzysGW7x8dCi4ieiesYcibcVFXpWHGJqGrU8adddHK0rxu3nsTKCtXKaz0ZKGcqHKVLHjbcVFXpWHGJqGqijlGei8(f)ahcocbg5YdmmmesshDrD3i1c1cKLo1F0RIPxi70ZKqIo6zsMqvWTK8ahjqOdyiKKJHG)5yysWGqMe)VGqFzysS9EHGXrQLKBkMKKPNjbfGcjFldtceE)IFGdbhHaHqswajq49l(boeCecmYLhyyyiKKo6I6UrQLKBkMeOJEMeuakK8TmmjntikibdvToQjrrPOizbKKCFNKqa838XKau5ZxWrshfvxs6OlQ7gPwsUPysu86zsqbOqY3YWK0mHOGemu16OMeffjlGKK77Kapih8aksaQ85l4iPdK6sshDrD3i1sYnftIU6QNjbfGcjFldtsZeIcsWqvRJAsuuKSassUVtc8GCWdOibOYNVGJKoqQljD0f1DJulj3umj6cz0ZKGcqHKVLHjPzcrbjyOQ1rnjkkswajj33jbEqo4buKau5ZxWrshi1LKo6I6UrQLKBkMKw1vptckafs(wgMKMjefKGHQwh1KOOizbKKCFNe4b5GhqrcqLpFbhjDGuxs6OlQ7gPwsUPysAf6ONjbfGcjFldtsZeIcsWqvRJAsuuKSassUVtc8GCWdOibOYNVGJKoqQljDAf1DJululqw6u)rVkMEHStptcj6ONjzcvb3sYdCKaHp3y2(7dHKCme8phdtcgeYK4)fe6ldtIT3lemosTKCtXK0QEMeuakK8TmmjntikibdvToQjrrrYcij5(ojWdYbpGIeGkF(cos6aPUK0rxu3nsTqTazPt9h9Qy6fYo9mjKOJEMKjufCljpWrceIxiKKJHG)5yysWGqMe)VGqFzysS9EHGXrQLKBkMefrptckafs(wgMei8(f)ahcocbcHKSasGW7x8dCi4ieyKlpWWWqijD0f1DJulj3umj6QREMeuakK8TmmjntikibdvToQjrrPOizbKKCFNKqa838XKau5ZxWrshfvxs6OlQ7gPwsUPys0Tv9mjOaui5BzysAMquqcgQADutIIsrrYcij5(ojHa4V5JjbOYNVGJKokQUK0rxu3nsTKCtXK0As6zsqbOqY3YWK0mHOGemu16OMeffjlGKK77Kapih8aksaQ85l4iPdK6sshDrD3i1c1cKLo1F0RIPxi70ZKqIo6zsMqvWTK8ahjqyaWxiKKJHG)5yysWGqMe)VGqFzysS9EHGXrQLKBkMeDHm6zsqbOqY3YWK0mHOGemu16OMeffjlGKK77Kapih8aksaQ85l4iPdK6ssNKH6UrQLKBkMKwtsptckafs(wgMKMjefKGHQwh1KOOizbKKCFNe4b5GhqrcqLpFbhjDGuxs6OlQ7gPwOwuSqvWTmmjqhsC7oGIeZGxCKArRr9aVXWAnqoKtI(CJxwMe909hyQfihYjrNQ3yiPvussRj1QUululqoKtck69cbJ1ZulqoKtIIMeDcdZWK0am(rI(ypmsTa5qojkAsqrVxiyysw)qWBEEKyDmJjzbKyHYA486hcEXrQfihYjrrtI(dhcqYWK8RITmg7huKG0VXdmmMKotKJOKe1JrMXRF4)HGjrrNijQhJmIx)W)db3nsTa5qojkAs0jsWatI6XwhVtHGeiRZ3EsMhjZcHys2EMe0hOqqc0BnJkMJulqoKtIIMe9xVntckafsqBMKTNjPrDUzXK4KyMDnmjHGJj5zyupbgMKoZJeOaFs6D4ccxs6NLKzjbpHFZ6fd(yduKGE2Es0hKnDQdsGijOGnmEh3qIondIkKRfLKmlectcU9O2nsTa5qojkAs0F92mjHa8sce(ge9B(4qFkmesc2YLFdatIRQAGIKfqsaaJj5ni6xmjGYavKAHAXT7akCu9ylimWxfApf8XWzS6CZIPwGCs0rptcs)gpWWKmysW8sYcijjsqpBpjfGe86ljGIKpMjzVPAZlgLKOljO75IKTNj5nhEjbumjdMeqrYhZOKKwjzEKS9mjy2ckysgmjEbtsYizEKea2Es8JPwC7oGchvp2ccd8fIkajK(nEGHrz5HScGk)XCEVPAZlkr6MpRqsulUDhqHJQhBbHb(crfGes)gpWWOS8qwbqL)yoV3uT5fLavfCyyuI0nFwbDr58uyVPAZBu34h7bgw5Et1M3OUrlayGbORi8)8Daf1IB3bu4O6XwqyGVqubiH0VXdmmklpKvau5pMZ7nvBErjqvbhggLiDZNvOvuopf2BQ28gBn(XEGHvU3uT5n2A0cagya6kc)pFhqrT42DafoQESfeg4levasHaq1EQ8dCHulqojj)XwhVK0kjqwNV9K4fmjojnRF4)HGjbuK0OdsqpBpj6Dq0VKO)DMeVGjrFaDQdsahjnRFV5ysaBpFOhmtT42DafoQESfeg4levasOpF7rPzkoBHvq3Kq58uOdBnJkMJMF5xUyuVPPS1mQyoov28l)stzRzuXCCQCay7ttzRzuXC0lOYfJ6Tl1IB3bu4O6XwqyGVqubiH(8ThLZtHoS1mQyoA(LF5Ir9MMYwZOI54uzZV8lnLTMrfZXPYbGTpnLTMrfZrVGkxmQ3Ukvpgzu3i6Z3ELjOEmYyRr0NV9ulUDhqHJQhBbHb(crfGeE97nhJY5Pqc3V4h4qWXa34LLZGx2nM82pfcCAAcwasU8AJ1GOFZpNtttaRYgtE9dbV4iE975gJc6MMMW6gU2y57)yCoWnEz5ixEGHHPwC7oGchvp2ccd8fIkaj86h(FiyuopfUFXpWHGJbUXllNbVSBm5TFkeyLwasU8AJ1GOFZpNvIvzJjV(HGxCeV(9CJrbDPwOwGCiNeOh1S9Vmmjms(GIKDczs2EMe3UGJKbtIJ0hJhy4i1IB3buyfWaJF5a2dPwGCsA4ftIobqpjGIKKbrsqpBp4VKaFZBjXlysqpBpjnRFgWbtIxWK0kejbS98HEWm1IB3buyfq634bggLLhYkm4SdyuI0nFwbSkBm51pe8IJ41VNBmjQRYojSUHRnIx)mGdoYLhyy4001nCTr8YgJFz4BEBKlpWWWDttXQSXKx)qWloIx)EUXKyRulqojn8IjXAyhjtc6EUiPz97nhtI1ls6NLKwHijRFi4ftc6(X2tYGj5ydJ0RLKh4iz7zsGERzuXmjlGKaMe1JF8DmmjEbtc6(X2tYBmg(izbKyD8sT42DafgIkajK(nEGHrz5HScdoBnSJKrjs38zfWQSXKx)qWloIx)EZXjQl1cKtIEGzs0hFy(ApfcsqpBpjOqNqsXkljGJe)T8rckafsqBMKPibf6eskwzPwC7oGcdrfGuaFy(Apfcuopf6KGfGKlV2yni638Z500eSaGbgGUIwqHe0MZBpNXQZnlo(v7Qm4)ErRNNYgpo0NcNOUOIAbYjj5bljONTNeNeuOtiPyLLKT3xsgCbHljojj)3G9Je1dyjbCKGUNls2EMK3GOFjzWK4bG)sYciHlyQf3UdOWqubiPc2buOCEke8FVO1ZtzJhh6tHtuxuLMgaWyLVbr)Mpo0NcdTwrf1cKtckCJ9B8LXKGUN3E(i5JNcbjOauibTzskaAsqpgdjUXaqtcuGpjlGe8ogdjwhVKS9mjypKjXdb)Ajb8ibfGcjOndruOtiPyLLeRJxm1IB3buyiQaKq634bggLLhYkybfsqBodZyOklkr6MpRGLhtNotT8Pcm(YW53GOFZhh6tHv06IkfTfamWa0v065PSXJd9PWDvu6Q4tQRcwEmD6m1YNkW4ldNFdI(nFCOpfwrRlQu062AskAlayGbOROfuibT582ZzS6CZIJhh6tH7QO0vXNuxLjC(aNzKCTrhgghzup4fNMAbadmaDfTEEkB84qFkCItT8Pcm(YW53GOFZhh6tHttTaGbgGUIwqHe0MZBpNXQZnloECOpfoXPw(ubgFz48Bq0V5Jd9PWkADtknnblajxETXAq0V5NZulqoj6bMHjzbKaZghks2EMKp2rWKaEKGcDcjfRSKGUNls(4Pqqcm4hyysafjFmtIxWKOEmsUws(yhbtc6EUiXlsCyysyKCTKmys8aWFjzbKapm1IB3buyiQaKq634bggLLhYkyHZwqbp7akuI0nFwHoRFi4nUtiNxqgE4e1fvPPNpWzgjxB0HHXXPsevj1vzNojWqW)OQYWroufQJDtgCWLxwon1cagya6kYHQqDSBYGdU8YYXJd9PWqtxOtsktWcagya6kYHQqDSBYGdU8YYXJDyO6QSthK(nEGHJGk)XCEVPAZRc6MMI0VXdmCeu5pMZ7nvBEvizDv2zVPAZBu34XomuzlayGbOR009MQnVrDJwaWadqxXJd9PWjo1YNkW4ldNFdI(nFCOpfwrRBsDttr634bgocQ8hZ59MQnVk0QYo7nvBEJTgp2HHkBbadmaDLMU3uT5n2A0cagya6kECOpfoXPw(ubgFz48Bq0V5Jd9PWkADtQBAks)gpWWrqL)yoV3uT5vHK6MMAbi5YRn2gQB8Ql1cKtIEGzsG(qvOo2nKaz7GlVSmjTMeMTysc4h4ysCsqHoHKIvws(yosT42DafgIkaPpMZZYHOS8qwboufQJDtgCWLxwgLZtblayGbORO1ZtzJhh6tHHwRjP0cagya6kAbfsqBoV9CgRo3S44XH(uyO1AsPPbamw5Bq0V5Jd9PWqlzkoQfiNe9aZK0a(gdVtHGe9NFauKaDWSftsa)ahtItck0jKuSYsYhZrQf3UdOWqubi9XCEwoeLLhYkGbFJH3Dke57hafkNNcwaWadqxrRNNYgpo0NcdnOJYeq634bgoAbfsqBodZyOkBAQfamWa0v0ckKG2CE75mwDUzXXJd9PWqd6OePFJhy4OfuibT5mmJHQSPPbamw5Bq0V5Jd9PWqRvurT42DafgIkaPpMZZYHOS8qwHPW27VEGHZqWVx7pmdZihlJY5PqW)9IwppLnECOpforDrf1cKtIo6hmjdMeNKZ3E(iHnEa48LjbTdfjlGKqVntIBmKaks(yMe86lj7nvBEXKSascysmtXWK8vjb9S9KGcDcjfRSK4fmjOauibTzs8cMKpMjz7zsATGjbBaljGIelmjZJKaW2tYEt1Mxmj(XKaks(yMe86lj7nvBEXulUDhqHHOcqAVPAZRUOCEkG0VXdmCeu5pMZ7nvBEvOvLjS3uT5n2A8yhgQSfamWa0vAAhK(nEGHJGk)XCEVPAZRc6MMI0VXdmCeu5pMZ7nvBEvizDv2j4)ErRNNYg)QPPwaWadqxrRNNYgpo0NcdXwtCVPAZBu3OfamWa0ve(F(oGszNeSaKC51gRbr)MFoNMMas)gpWWrlOqcAZzygdvz7QmblajxETX2qDJxPPwasU8AJ1GOFZpNvI0VXdmC0ckKG2CgMXqvwLwaWadqxrlOqcAZ5TNZy15Mfh)QktWcagya6kA98u24xvzNob)3lYwZOI5S5x(fpo0NcNOUjLMg8FViBnJkMZyGXV4XH(u4e1nPUkt4(f)ahcog4gVSCg8YUXK3(PqGtt7e8FVyGB8YYzWl7gtE7Ncbox((poIx32wbuLMg8FVyGB8YYzWl7gtE7Ncbo7N1loIx32wbu1TBAAW)9ITNc(y4mhQcqZxixBMl(qm6hh)QDttdaySY3GOFZhh6tHHwRjLMI0VXdmCeu5pMZ7nvBEvijQf3UdOWqubiT3uT5Tvuopfq634bgocQ8hZ59MQnVjOqRktyVPAZBu34XomuzlayGbOR0uK(nEGHJGk)XCEVPAZRcTQStW)9IwppLn(vttTaGbgGUIwppLnECOpfgITM4Et1M3yRrlayGbORi8)8DaLYojybi5YRnwdI(n)ConnbK(nEGHJwqHe0MZWmgQY2vzcwasU8AJTH6gVstTaKC51gRbr)MFoRePFJhy4OfuibT5mmJHQSkTaGbgGUIwqHe0MZBpNXQZnlo(vvMGfamWa0v065PSXVQYoDc(VxKTMrfZzZV8lECOpforDtknn4)Er2AgvmNXaJFXJd9PWjQBsDvMW9l(boeCmWnEz5m4LDJjV9tHaNM2j4)EXa34LLZGx2nM82pfcCU89FCeVUTTcOknn4)EXa34LLZGx2nM82pfcC2pRxCeVUTTcOQB3UPPb)3l2Ek4JHZCOkanFHCTzU4dXOFC8RMMgaWyLVbr)Mpo0NcdTwtknfPFJhy4iOYFmN3BQ28Qqsulqoj6bMXK4gdjGTNpsafjFmtYSCiMeqrIfMAXT7akmevasFmNNLdXOCEke8FVO1ZtzJF10ulajxETXAq0V5NZkr634bgoAbfsqBodZyOkRslayGbOROfuibT582ZzS6CZIJFvLjybadmaDfTEEkB8RQStNG)7fzRzuXC28l)Ihh6tHtu3Kstd(VxKTMrfZzmW4x84qFkCI6MuxLjC)IFGdbhdCJxwodEz3yYB)uiWPP3V4h4qWXa34LLZGx2nM82pfcSYob)3lg4gVSCg8YUXK3(PqGZLV)JJ41TTtmzPPb)3lg4gVSCg8YUXK3(PqGZ(z9IJ41TTtmzD7MMg8FVy7PGpgoZHQa08fY1M5IpeJ(XXVAAAaaJv(ge9B(4qFkm0AnjQfiNe9eBhyMe3UdOiXm4LKahZWKaksWZ(9DafKmmIbtT42DafgIkaP7xz3UdOYMbVOS8qwbhWOeV3yxf0fLZtbK(nEGHJdo7aMAXT7akmevas3VYUDhqLndErz5HScbaFrjEVXUkOlkNNc3V4h4qWXa34LLZGx2nM82pfcCKHG)rvLHPwC7oGcdrfG09RSB3buzZGxuwEiRaEPwOwGCsqHBSFJVmMe0982ZhjBptIE6yp06RTNpsc(VhjOhJHKNBmKaEpsqpB)uKS9mjfJ6LeRJxQf3UdOWrhWkG0VXdmmklpKva(ypmJEmM8ZnMm49qjs38zf6e8FV4oHmAWvz4J9WGPG5lECOpfgAiSWXqh1qmPOUPPb)3lUtiJgCvg(ypmyky(Ihh6tHHMB3bur863BooYOMT)LZ7eYqmPOUk7WwZOI54uzZV8lnLTMrfZrmW4xUyuVPPS1mQyo6fu5Ir92TRYG)7f3jKrdUkdFShgmfmFXVQY7x8dCi44oHmAWvz4J9WGPG5lYqW)OQYWulqojOWn2VXxgtc6EE75JKM1p8)qWKmysqdUTNeRJ3PqqcajFK0S(9MJjzkssUF5hjqV1mQyMAXT7akC0bmevasi9B8adJYYdzfgef44mE9d)pemkr6MpRqcS1mQyoovgdm(PSdwLnM86hcEXr863BooruPCDdxBed(Mm4L3Eo)ahJ3ixEGHHttXQSXKx)qWloIx)EZXjQ46sTa5KOhyMeuakKG2mjO75IeFjXWymjBVxKGQKirN4KNeVGjXmftYxLe0Z2tck0jKuSYsT42Dafo6agIkajlOqcAZ5TNZy15MfJY5PqcW3FGJfiBHXk70bPFJhy4OfuibT5mmJHQSktWcagya6kA98u24XomuPPb)3lA98u24xTRYooEp3KvbO5dAOkP0uK(nEGHJdIcCCgV(H)hcURYob)3lYwZOI5S5x(fpo0NcNi0jnn4)Er2AgvmNXaJFXJd9PWjcD6QStc3V4h4qWXa34LLZGx2nM82pfcCAAW)9IbUXllNbVSBm5TFke4C57)4iEDB7etwAAW)9IbUXllNbVSBm5TFke4SFwV4iEDB7etw3003GOFZhh6tHHMUjPmblayGbORO1ZtzJh7Wq1LAbYjrpWmj6)Jl9dksqpBpjOqNqsXkl1IB3bu4OdyiQaKohjxGpo)oU0pOq58ui4)ErRNNYgpo0NcNOUOIAbYjrpWmjn)6nhtYuKO6fmhowsafjEb12pfcs2EFjXmizmj6Qiy2IjXlysmmgtc6z7jjeCmjRFi4ftIxWK4ljBptcxWKaEK4K0am(rc0BnJkMjXxs0vribZwmjGJedJXKCCOp1uiiXXKSaskWssVJCkeKSaso(DmUNe4)nfcssUF5hjqV1mQyMAXT7akC0bmevas4F9MJrPfkRHZRFi4fRGUOCEk0543X4EpWWPPb)3lYwZOI5mgy8lECOpfgAjtjBnJkMJtLXaJFkpo0NcdnDveLRB4AJyW3KbV82Z5h4y8g5YdmmCxLRFi4nUtiNxqgE4e1vru0yv2yYRFi4fdXJd9PWk7WwZOI54uzVGkn94qFkm0qyHJHoQ7sTa5KabKzvs(QK0S(9CJHeFjXngs2jKXK8ldJXK8XtHGKKdkRFoMeVGjzwsgmjEa4VKSasupGLeWrIHxs2EMeSkBh3qIB3buKyMIjjGna0K07fSHjrpDShgmfmFKaksALK1pe8IPwC7oGchDadrfGeE975gdkNNcDc(VxeV(9CJjE87yCVhyyLDWQSXKx)qWloIx)EUXaTKLMMW9l(boeCCNqgn4Qm8XEyWuW8fzi4Fuvz4UPPRB4AJyW3KbV82Z5h4y8g5YdmmSYG)7fzRzuXCgdm(fpo0NcdTKPKTMrfZXPYyGXpLb)3lIx)EUXepo0NcdnfNsSkBm51pe8IJ41VNBmjQGI0vzNeUFXpWHGJgOS(548ZW8ofImcZeQI5idb)JQkdNMUtiROuukcQsm4)Er863ZnM4XH(uyi2AxLRFi4nUtiNxqgE4erf1cKtcK1S9KONo2ddMcMps(yMKM1VNBmKSasAZSkjFvs2EMKG)7rsauK4gmGKpEkeK0S(9CJHeqrcQibZwqbJjbCKyymMKJd9PMcb1IB3bu4OdyiQaKWRFp3yq58u4(f)ahcoUtiJgCvg(ypmyky(Ime8pQQmSsSkBm51pe8IJ41VNBmjQqYu2jHG)7f3jKrdUkdFShgmfmFXVQYG)7fXRFp3yIh)og37bgonTds)gpWWr4J9Wm6XyYp3yYG3tzNG)7fXRFp3yIhh6tHHwYstXQSXKx)qWloIx)EUXKyRkx3W1gXlBm(LHV5TrU8addRm4)Er863ZnM4XH(uyOHQUD7sTa5KGc3y)gFzmjO75TNpsCsAw)W)dbtYhZKGEmgsS(hZK0S(9CJHKfqYZngsaVhkjXlys(yMKM1p8)qWKSasAZSkj6PJ9WGPG5Je8622K8vPwC7oGchDadrfGes)gpWWOS8qwb863ZnMmAqT5NBmzW7HsKU5Zk449CtwfGMVev8jPO7OBsq3G)7f3jKrdUkdFShgmfmFr8622Dv0Dc(VxeV(9CJjECOpfg6MmffwLnMCVJxURIUdmyJV)bvg8YS5xC84qFkm0fvDvg8FViE975gt8RsTa5KOhyMKM1p8)qWKGE2Es0th7HbtbZhjlGK2mRsYxLKTNjj4)EKGE2EWFjXaWtHGKM1VNBmK8v3jKjXlys(yMKM1p8)qWKaksueisI(a6uhKGx32gtYV2XqIIqY6hcEXulUDhqHJoGHOcqcV(H)hcgLZtbK(nEGHJWh7Hz0JXKFUXKbVNsK(nEGHJ41VNBmz0GAZp3yYG3tzci9B8adhhef44mE9d)peCAANG)7fdCJxwodEz3yYB)uiW5Y3)Xr8622jMS00G)7fdCJxwodEz3yYB)uiWz)SEXr8622jMSUkXQSXKx)qWloIx)EUXanfrjs)gpWWr863ZnMmAqT5NBmzW7rTa5KOhyMemA)cjbdiz79LeOaFsqWljHoQj5RUtitsauK8XtHGKzjXXKy8LjXXKOcW4jWWKaksmmgtY27fjjJe8622ysahjqa(XljO75IKKbrsWRBBJjHrT6Cm1IB3bu4OdyiQaKCyxDhKCgJ2VquAHYA486hcEXkOlkNNcjSJT9uiuMGB3burh2v3bjNXO9lmd7Hocoov(zge9BAkmyJoSRUdsoJr7xyg2dDeCeVUTn0sMsyWgDyxDhKCgJ2VWmSh6i44XH(uyOLmQfiNe9h(DmUNe9xaOEZXKmpsqHoHKIvwsgmjh7WqHss2E(ys8JjXWymjBVxKGksw)qWlMKPij5(LFKa9wZOIzsqpBpjnGv)JssmmgtY27fj6MejGTNp0dMjzks8cksGERzuXmjGJKVkjlGeurY6hcEXKeWpWXK4KKC)YpsGERzuXCKe9eOGWLKJFhJ7jb(FtHGeiGtbFmmjqFOkanFHCTK8ldJXKmfjnaJFKa9wZOIzQf3UdOWrhWqubifca1BogLwOSgoV(HGxSc6IY5PWXVJX9EGHvU(HG34oHCEbz4HtSthDvei2bRYgtE9dbV4iE97nhdDBf6g8FViBnJkMZMF5x8R2Tlepo0Nc3vr1rxiUUHRnUONkhcafoYLhyy4Uk7ybadmaDfTEEkB8yhgkLjaF)bowGSfgRSds)gpWWrlOqcAZzygdvzttTaGbgGUIwqHe0MZBpNXQZnloESddvAAcwasU8AJ1GOFZpN7MMIvzJjV(HGxCeV(9MJHwNoqhfDNG)7fzRzuXC28l)IFvOBRD7cD7Olex3W1gx0tLdbGch5YdmmC3UktGTMrfZrmW4xUyuVPPDyRzuXCCQmgy8lnTdBnJkMJtLdaBFAkBnJkMJtLn)YVUktyDdxBed(Mm4L3Eo)ahJ3ixEGHHttd(Vxu9MqWbpUj7N1RXMv)gSFrKU5ZjQqROkPUk7GvzJjV(HGxCeV(9MJHMUjbD7Olex3W1gx0tLdbGch5YdmmC3UkD8EUjRcqZxIOkjfDW)9I41VNBmXJd9PWqxOtxLDsi4)EX2tbFmCMdvbO5lKRnZfFig9JJF10u2AgvmhNkJbg)sttWcqYLxBSnu34vxQfiNe9aZKO)b6LeqrIfMe0Z2d(ljwxvDkeulUDhqHJoGHOcq6bolNbVC57)yuopfC1STNTTPwGCs0dmtck0jKuSYscOiXctYVmmgtIxWKyMIjzws(QKGE2EsqbOqcAZulUDhqHJoGHOcqYYggVJBYUzquHCTOCEkKa89h4ybYwySsK(nEGHJw4SfuWZoGszNG)7fXRFp3yIF10uhVNBYQa08LiQsQRYoje8FVigyW7y54xvzcb)3lA98u24xvzNeSaKC51gRbr)MFoNMAbadmaDfTGcjOnN3EoJvNBwC8RQ0X75MSkanFqdvj1v56hcEJ7eY5fKHhorDrfeTGc(pBu9y7G5SBgevixBCNqoJ0nFonnaGXkNA5tfy8LHZVbr)Mpo0NcdTwtcIwqb)NnQESDWC2ndIkKRnUtiNr6Mp3LAXT7akC0bmevastz9R8DafkNNcjaF)bowGSfgRePFJhy4OfoBbf8SdOu2j4)Er863ZnM4xnn1X75MSkanFjIQK6QStcb)3lIbg8owo(vvMqW)9IwppLn(vv2jblajxETXAq0V5NZPPwaWadqxrlOqcAZ5TNZy15Mfh)QkD8EUjRcqZh0qvsDvU(HG34oHCEbz4HtS1KGOfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZPPbamw5ulFQaJVmC(ni638XH(uyOLSKGOfuW)zJQhBhmNDZGOc5AJ7eYzKU5ZDPwGCs0dmtc0hQcqZhj6duWKaksSWKGE2EsAw)EUXqYxLeVGjb7izsEGJKK)BW(rIxWKGcDcjfRSulUDhqHJoGHOcqIdvbO5lhakyuopfcaySYPw(ubgFz48Bq0V5Jd9PWqtxuLM2j4)Er1Bcbh84MSFwVgBw9BW(fr6MpdTwrvsPPb)3lQEti4Gh3K9Z61yZQFd2Vis385evOvuLuxLb)3lIx)EUXe)Qk7ybadmaDfTEEkB84qFkCIOkP0u47pWXcKTW4Uulqoj6p87yCpjpJFmjGIKVkjlGKKrY6hcEXKGE2EWFjbf6eskwzjjGNcbjEa4VKSasyuRohtIxWKuGLeas(SUQ6uiOwC7oGchDadrfGeEzJXV8Z4hJsluwdNx)qWlwbDr58u443X4EpWWk3jKZlidpCI6IkLyv2yYRFi4fhXRFV5yOPikD1STNTTv2j4)ErRNNYgpo0NcNOUjLMMqW)9IwppLn(v7sTa5KOhyMe9pa6jzEKmfEGzs8IeO3AgvmtIxWKyMIjzws(QKGE2EsCss(Vb7hjQhWsIxWKOtyxDhKmjnO9lKAXT7akC0bmevasV)bvg8YS5xmkNNcS1mQyoov2lOu6QzBpBBRm4)Er1Bcbh84MSFwVgBw9BW(fr6MpdTwrvsk7ad2Od7Q7GKZy0(fMH9qhbh3X2EkePPjybi5YRnwS9agWbNMIvzJjV(HGxCIT2LAbYjrpWmjojnRFp3yibYwXBpjQhWsYVmmgtsZ63ZngsgmjU5yhgks(QKaosGc8jXpMepa8xswajaK8zDvs0jo5PwC7oGchDadrfGeE975gdkNNcb)3lckE7Xzv(SS6oGk(vv2j4)Er863ZnM4XVJX9EGHttD8EUjRcqZxIqMK6sTa5KON(HQKOtCYtsa)ahtckafsqBMe0Z2tsZ63Zngs8cMKTNlsAw)W)dbtT42Dafo6agIkaj863ZnguopfSaKC51gRbr)MFoRSds)gpWWrlOqcAZzygdvzttTaGbgGUIwppLn(vttd(Vx065PSXVAxLwaWadqxrlOqcAZ5TNZy15Mfhpo0Ncdnew4yOJAORLhthhVNBYQa08POqvsDvg8FViE975gt84qFkm0ueLjaF)bowGSfgtT42Dafo6agIkaj86h(FiyuopfSaKC51gRbr)MFoRSds)gpWWrlOqcAZzygdvzttTaGbgGUIwppLn(vttd(Vx065PSXVAxLwaWadqxrlOqcAZ5TNZy15Mfhpo0NcdnOJYG)7fXRFp3yIFvLS1mQyoov2lOuMas)gpWWXbrbooJx)W)dbRmb47pWXcKTWyQfiNe9aZK0S(H)hcMe0Z2tIxKazR4TNe1dyjbCKmpsGc8Hqysai5Z6QKOtCYtc6z7jbkW)iPyuVKyD8gjrNgmGe4FOkMeDItEs8LKTNjHlysaps2EMeia4A7H6ij4)EKmpsAw)EUXqcAW3axq4sYZngsaVhjGIefHeWrIHXysw)qWlMAXT7akC0bmevas41p8)qWOCEke8FViO4ThNTg2VmYbpGk(vtt7KaE97nhhD1STNTTvMas)gpWWXbrbooJx)W)dbNM2j4)ErRNNYgpo0NcdnuPm4)ErRNNYg)QPPDc(Vx8CKCb(4874s)GkECOpfgAiSWXqh1qxlpMooEp3KvbO5trLSK6Qm4)EXZrYf4JZVJl9dQ4xTBxLi9B8adhXRFp3yYOb1MFUXKbVNsSkBm51pe8IJ41VNBmqlzDv2jH7x8dCi44oHmAWvz4J9WGPG5lYqW)OQYWPPyv2yYRFi4fhXRFp3yGwY6sTa5KOhyMe9xaOWKmfjnaJFKa9wZOIzs8cMeSJKjr))ngs0FbGIKh4ibf6eskwzPwC7oGchDadrfGuXOZHaqHY5PqNG)7fzRzuXCgdm(fpo0NcNiJA2(xoVtiNM2X27hcgRqRkp227hcoVtidnu1nn127hcgRqY6Q0vZ2E22MAXT7akC0bmevas9U5LdbGcLZtHob)3lYwZOI5mgy8lECOpforg1S9VCENqonTJT3pemwHwvEST3peCENqgAOQBAQT3pemwHK1vPRMT9STn1IB3bu4OdyiQaKEFJjhcafkNNcDc(VxKTMrfZzmW4x84qFkCImQz7F58oHSYowaWadqxrRNNYgpo0NcNiQskn1cagya6kAbfsqBoV9CgRo3S44XH(u4ervsDtt7y79dbJvOvLhB79dbN3jKHgQ6MMA79dbJvizDv6QzBpBBtTa5KOhyMeila0tcOibf6jQf3UdOWrhWqubiH2VBaxg8YS5xm1cKtckCJ9B8LXKGUN3E(izbK8XmjnRFV5ysMIKgGXpsq3p2Esgmj(scQiz9dbVyiQljpWrcJKpOiP1KuuKe64LpOibCKOiK0S(H)hcMeOpufGMVqUwsWRBBJPwC7oGchDadrfGes)gpWWOS8qwb863Boopvgdm(HsKU5ZkGvzJjV(HGxCeV(9MJturG4ZaaxNqhV8bvgPB(m0v3Kssr1AsDH4ZaaxNG)7fXRF4)HGZCOkanFHCTzmW4xeVUTTIsr6sTa5KOhyMeiRZ3EsMIKgGXpsGERzuXmjGJK5rsbiPz97nhtc6Xyi5nljtTasqHoHKIvws8cQqWXulUDhqHJoGHOcqc95BpkNNcDyRzuXC08l)YfJ6nnLTMrfZrVGkxmQxLi9B8adhhC2Ayhj3vzN1pe8g3jKZlidpCIksAkBnJkMJMF5xEQCRPPVbr)Mpo0NcdnDtQBAAW)9IS1mQyoJbg)Ihh6tHHMB3bur863BooYOMT)LZ7eYkd(VxKTMrfZzmW4x8RMMYwZOI54uzmW4NYeq634bgoIx)EZX5PYyGXV00G)7fTEEkB84qFkm0C7oGkIx)EZXrg1S9VCENqwzci9B8adhhC2AyhjRm4)ErRNNYgpo0Ncdng1S9VCENqwzW)9IwppLn(vttd(Vx8CKCb(4874s)Gk(vvIvzJj374LtmPi0rzhSkBm51pe8IHMcjlnnH1nCTrm4BYGxE758dCmEJC5bggUBAAci9B8adhhC2AyhjRm4)ErRNNYgpo0NcNiJA2(xoVtitTa5KOhyMKM1V3CmjZJKPij5(LFKa9wZOIzusYuK0am(rc0BnJkMjbuKOiqKK1pe8IjbCKSasupGLKgGXpsGERzuXm1IB3bu4OdyiQaKWRFV5yQfiNe9VBmB)9PwC7oGchDadrfG09RSB3buzZGxuwEiRWZnMT)(ululqoj6)Jl9dksqpBpjOqNqsXkl1IB3bu4yaWxfohjxGpo)oU0pOq58ui4)ErRNNYgpo0NcNOUOIAbYjbf9STnMK5rY2ZKOpGo1bj2Bwsc(VhjdMKcSK8vj5bosm(YhjFmtT42Dafoga8fIkajK(nEGHrz5HSc2B2cSFvuI0nFwHec(VxmWnEz5m4LDJjV9tHaNlF)hh)Qkti4)EXa34LLZGx2nM82pfcC2pRxC8RsTa5KOhyMeDc7Q7GKjPbTFHKGUNls8LedJXKS9ErIIqI(a6uhKGx32gtIxWKSaso(DmUNeNeOPqRKGx32MehtIXxMehtIkaJNadtc4izNqMKzjbdizws87gKmMeia)4Le)T8rItsYGij41TTjHrT6CmMAXT7akCma4levasoSRUdsoJr7xikTqznCE9dbVyf0fLZtHG)7fdCJxwodEz3yYB)uiW5Y3)Xr8622qtrug8FVyGB8YYzWl7gtE7Ncbo7N1loIx32gAkIYojad2Od7Q7GKZy0(fMH9qhbh3X2EkektWT7aQOd7Q7GKZy0(fMH9qhbhNk)mdI(vzNeGbB0HD1DqYzmA)cZ9SBI7yBpfI0uyWgDyxDhKCgJ2VWCp7M4XH(u4etw30uyWgDyxDhKCgJ2VWmSh6i4iEDBBOLmLWGn6WU6oi5mgTFHzyp0rWXJd9PWqdvkHbB0HD1DqYzmA)cZWEOJGJ7yBpfIUulqoj6bMjbfGcjOntc6z7jbf6eskwzjbDpxKOcW4jWWK4fmjGTNp0dMjb9S9K4KOpGo1bjb)3Je09CrcmJHQStHGAXT7akCma4levaswqHe0MZBpNXQZnlgLZtHoi9B8adhTGcjOnNHzmuLvzcwaWadqxrRNNYgp2HHknn4)ErRNNYg)QDv2j4)EXa34LLZGx2nM82pfcCU89FCeVUTTcOknn4)EXa34LLZGx2nM82pfcC2pRxCeVUTTcOQBAAaaJv(ge9B(4qFkm00njQfiNe9pa6jXXKS9mjV5WljiSWKmfjBptItI(a6uhKGEkyaAsahjONTNKTNjbciu34fjb)3JeWrc6z7jXjrXdrmBjrNWU6oizsAq7xijEbtcAFwsEGJeuOtiPyLLK5rYSKGguljbmjFvsCe(uKeWpWXKS9mjwysgmjVPgCpdtT42Dafoga8fIkaP3)GkdEz28lgLZtHoDc(VxmWnEz5m4LDJjV9tHaNlF)hhXRBBNOIKMg8FVyGB8YYzWl7gtE7Ncbo7N1loIx32orfPRYoW3FGJfiBHXPPwaWadqxrRNNYgpo0NcNiQsknTJfGKlV2yni638ZzLwaWadqxrlOqcAZ5TNZy15Mfhpo0NcNiQsQB3UPPDGbB0HD1DqYzmA)cZWEOJGJhh6tHtuXR0cagya6kA98u24XH(u4e1njLwasU8AJfBpGbCWDttNA5tfy8LHZVbr)Mpo0NcdnfVYeSaGbgGUIwppLnESddvAAhlajxETX2qDJxkd(VxS9uWhdN5qvaA(c5AJF1UulqojOWllBiPz9ZaoysqpBpjojfJMe9b0Poij4)EK4fmjOqNqsXkljdUGWLepa8xswajbmjFmdtT42Dafoga8fIkajRxw2Kd(VhklpKvaV(zahmkNNcDc(VxmWnEz5m4LDJjV9tHaNlF)hhpo0NcNOIervAAW)9IbUXllNbVSBm5TFke4SFwV44XH(u4evKiQ6QSJfamWa0v065PSXJd9PWjQ4st7ybadmaDf5qvaA(YbGcoECOpforfNYec(VxS9uWhdN5qvaA(c5AZCXhIr)44xvPfGKlV2yBOUXRUDv649CtwfGMVevizjrTa5KON(HQK0S(H)hcgtc6z7jXjrFaDQdsc(Vhjb)LKcSKGUNlsubaZuii5bosqHoHKIvwsahjqaNc(yysAuNBwm1IB3bu4yaWxiQaKWRFp3yq58uyDdxBeVSX4xg(M3g5YdmmSsmV7uiWrmWaYW38wLb)3lIx)EUXeHbOlQfiNe90puLKM1p8)qWysqpBpjBptsaWxsc(Vhjb)LKcSKGUNlsubaZuii5bosSojGJeoufGMpscafm1IB3bu4yaWxiQaKWRF4)HGr58uibK(nEGHJ2B2cSFvLDSaKC51gRbr)MFoNMAbadmaDfTEEkB84qFkCIkU00eq634bgoAHZwqbp7akLjybi5YRn2gQB8knTJfamWa0vKdvbO5lhak44XH(u4evCkti4)EX2tbFmCMdvbO5lKRnZfFig9JJFvLwasU8AJTH6gV62vzNeGbB89pOYGxMn)IJ7yBpfI00eSaGbgGUIwppLnESddvAAcwaWadqxrlOqcAZ5TNZy15Mfhp2HHQl1cKtIE6hQssZ6h(Fiymjb8dCmjOauibTzQf3UdOWXaGVqubiHx)W)dbJY5PqhlayGbOROfuibT582ZzS6CZIJhh6tHHgQuMa89h4ybYwySYoi9B8adhTGcjOnNHzmuLnn1cagya6kA98u24XH(uyOHQUkr634bgoAHZwqbp7aQUktagSX3)GkdEz28loUJT9uiuAbi5YRnwdI(n)CwzcW3FGJfiBHXkzRzuXCCQSxqrTa5KONafeUKadwsG)3uiiz7zs4cMeWJe9hhjxGpMe9)XL(bfkjb(FtHGK2tbFmmjCOkanFHCTKaosMIKTNjX44Leewysaps8IeO3AgvmtT42Dafoga8fIkajK(nEGHrz5HScWGnFme8phhY1Irjs38zf6e8FV45i5c8X53XL(bv84qFkCIOknnHG)7fphjxGpo)oU0pOIF1Uk7e8FVy7PGpgoZHQa08fY1M5IpeJ(XXJd9PWqdHfog6OURYob)3lYwZOI5mgy8lECOpforew4yOJ600G)7fzRzuXC28l)Ihh6tHteHfog6OUl1IB3bu4yaWxiQaKW)6nhJsluwdNx)qWlwbDr58u443X4EpWWkx)qWBCNqoVGm8WjQl0rPRMT9STTsK(nEGHJWGnFme8phhY1IPwC7oGchda(crfGuiauV5yuAHYA486hcEXkOlkNNch)og37bgw56hcEJ7eY5fKHhorDtwevkD1STNTTvI0VXdmCegS5JHG)54qUwm1IB3bu4yaWxiQaKWlBm(LFg)yuAHYA486hcEXkOlkNNch)og37bgw56hcEJ7eY5fKHhorDHoq84qFkSsxnB7zBBLi9B8adhHbB(yi4FooKRftTa5KO)b6LeqrIfMe0Z2d(ljwxvDkeulUDhqHJbaFHOcq6bolNbVC57)yuopfC1STNTTPwGCsG(qvaA(irFGcMe09CrIha(ljlGeUw(iXjPy0KOpGo1bjONcgGMeVGjb7izsEGJeuOtiPyLLAXT7akCma4levasCOkanF5aqbJY5Pqh2Agvmhn)YVCXOEttzRzuXCedm(Llg1BAkBnJkMJEbvUyuVPPb)3lg4gVSCg8YUXK3(PqGZLV)JJhh6tHturIOknn4)EXa34LLZGx2nM82pfcC2pRxC84qFkCIksevPPoEp3KvbO5lritskTaGbgGUIwppLnESddLYeGV)ahlq2cJ7QSJfamWa0v065PSXJd9PWjMSKstTaGbgGUIwppLnESddv300aagRCQLpvGXxgo)ge9B(4qFkm00njQfiNe9pa6j5ge9ljb8dCmjF8uiibf6KAXT7akCma4levasV)bvg8YS5xmkNNcwaWadqxrRNNYgp2HHsjs)gpWWrlC2ck4zhqPSJJ3ZnzvaA(seYKKYeSaKC51gRbr)MFoNMAbi5YRnwdI(n)CwPJ3ZnzvaA(GMIKuxLDsWcqYLxBSge9B(5CAQfamWa0v0ckKG2CE75mwDUzXXJDyO6Qmb47pWXcKTWyQfiNeuOtiPyLLe09CrIVKazscIKOtCYtshWzaO5JKT3lsuKKirN4KNe0Z2tckafsqBUljONTh8xsma8uiizNqMKPirFgaa28XljEbtIzkMKVkjONTNeuakKG2mjZJKzjbTJjbMXqvwgMAXT7akCma4levasw2W4DCt2ndIkKRfLZtHeGV)ahlq2cJvI0VXdmC0cNTGcE2buk70XX75MSkanFjczsszNG)7fBpf8XWzoufGMVqU2mx8Hy0po(vtttWcqYLxBSnu34v300G)7fdmaaS5J34xvzW)9Ibgaa28XB84qFkm0Anji2Xck4)Sr1JTdMZUzquHCTXDc5ms385UDttdaySYPw(ubgFz48Bq0V5Jd9PWqR1KGyhlOG)Zgvp2oyo7MbrfY1g3jKZiDZN7MMAbi5YRnwdI(n)CURYojybi5YRnwdI(n)ConTJJ3ZnzvaA(GMIKuAkmyJV)bvg8YS5xCChB7Pq0vzhK(nEGHJwqHe0MZWmgQYMMAbadmaDfTGcjOnN3EoJvNBwC8yhgQUDPwC7oGchda(crfG0uw)kFhqHY5PqcW3FGJfiBHXkr634bgoAHZwqbp7akLD6449CtwfGMVeHmjPStW)9ITNc(y4mhQcqZxixBMl(qm6hh)QPPjybi5YRn2gQB8QBAAW)9Ibgaa28XB8RQm4)EXadaaB(4nECOpfgAjlji2Xck4)Sr1JTdMZUzquHCTXDc5ms385UDttdaySYPw(ubgFz48Bq0V5Jd9PWqlzjbXowqb)NnQESDWC2ndIkKRnUtiNr6Mp3nn1cqYLxBSge9B(5CxLDsWcqYLxBSge9B(5CAAhhVNBYQa08bnfjP0uyWgF)dQm4LzZV44o22tHORYoi9B8adhTGcjOnNHzmuLnn1cagya6kAbfsqBoV9CgRo3S44XomuD7sTa5Ka94Dc9LXK0dqts432tIoXjpj(XKGWNIHjrLpsWSfuWulUDhqHJbaFHOcqcPFJhyyuwEiRGJvtE(Aylkr6MpRaBnJkMJtLn)YpORIxr52DaveV(9MJJmQz7F58oHmetGTMrfZXPYMF5h0Td0bIRB4AJyW3KbV82Z5h4y8g5Ydmmm0nzDvuUDhqfrF(2hzuZ2)Y5DcziMuSvffwLnMCVJxMAbYjrp9dvjPz9d)pemMe09CrY2ZK8ge9ljdMepa8xswajCbJssEhx6huKmys8aWFjzbKWfmkjbkWNe)ys8LeitsqKeDItEsMIeVib6TMrfZOKeuOtiPyLLeJJxmjEb2E(irXdrmBXKaosGc8jbn4BGjbGKpRRssi4ys2EViHs1njs0jo5jbDpxKaf4tcAW3axq4ssZ6h(FiyskaAQf3UdOWXaGVqubiHx)W)dbJY5PqNaagRCQLpvGXxgo)ge9B(4qFkm0uK00ob)3lEosUaFC(DCPFqfpo0Ncdnew4yOJAORLhthhVNBYQa08POswsDvg8FV45i5c8X53XL(bv8R2TBAAhhVNBYQa08brK(nEGHJown55RHTq3G)7fzRzuXCgdm(fpo0NcdryWgF)dQm4LzZV44o2248XH(uq3wJOkrD1nP0uhVNBYQa08brK(nEGHJown55RHTq3G)7fzRzuXC28l)Ihh6tHHimyJV)bvg8YS5xCChBBC(4qFkOBRruLOU6MuxLS1mQyoov2lOu2jHG)7fTEEkB8RMMMW6gU2iE9Zao4ixEGHH7QStNeSaGbgGUIwppLn(vttTaKC51gBd1nEPmblayGbORihQcqZxoauWXVA30ulajxETXAq0V5NZDv2jblajxETrKCT9qDPPje8FVO1ZtzJF10uhVNBYQa08LiKjPUPPDw3W1gXRFgWbh5YdmmSYG)7fTEEkB8RQStW)9I41pd4GJ41TTHwYstD8EUjRcqZxIqMK62nnn4)ErRNNYg)Qkti4)EXZrYf4JZVJl9dQ4xvzcRB4AJ41pd4GJC5bggMAbYjrpWmj6VaqHjzkssUF5hjqV1mQyMeVGjb7izsGS3npiQ))gdj6VaqrYdCKGcDcjfRSulUDhqHJbaFHOcqQy05qaOq58uOtW)9IS1mQyoB(LFXJd9PWjYOMT)LZ7eYPPDS9(HGXk0QYJT9(HGZ7eYqdvDttT9(HGXkKSUkD1STNTTPwC7oGchda(crfGuVBE5qaOq58uOtW)9IS1mQyoB(LFXJd9PWjYOMT)LZ7eYk7ybadmaDfTEEkB84qFkCIOkP0ulayGbOROfuibT582ZzS6CZIJhh6tHtevj1nnTJT3pemwHwvEST3peCENqgAOQBAQT3pemwHK1vPRMT9STn1IB3bu4yaWxiQaKEFJjhcafkNNcDc(VxKTMrfZzZV8lECOpforg1S9VCENqwzhlayGbORO1ZtzJhh6tHtevjLMAbadmaDfTGcjOnN3EoJvNBwC84qFkCIOkPUPPDS9(HGXk0QYJT9(HGZ7eYqdvDttT9(HGXkKSUkD1STNTTPwGCsGSaqpjGIelm1IB3bu4yaWxiQaKq73nGldEz28lMAbYjrpWmjnRFV5yswajQhWssdW4hjqV1mQyMeWrc6EUizksaLbkssUF5hjqV1mQyMeVGj5JzsGSaqpjQhWIjzEKmfjj3V8JeO3AgvmtT42Dafoga8fIkaj863BogLZtb2AgvmhNkB(LFPPS1mQyoIbg)YfJ6nnLTMrfZrVGkxmQ300G)7fr73nGldEz28lo(vvg8FViBnJkMZMF5x8RMM2j4)ErRNNYgpo0Ncdn3UdOIOpF7JmQz7F58oHSYG)7fTEEkB8R2LAXT7akCma4levasOpF7PwC7oGchda(crfG09RSB3buzZGxuwEiRWZnMT)(ululqojnRF4)HGj5boscbi5qUws(LHXys(4PqqI(a6uhulUDhqHJp3y2(7RaE9d)pemkNNcjC)IFGdbhdCJxwodEz3yYB)uiWrgc(hvvgMAbYjbfoEjz7zsGbljONTNKTNjjeGxs2jKjzbK4WWK8RDmKS9mjHoQjb(F(oGIKbts)SrsA(1BoMKJd9PWKe(n7OAggMKfqsOV2EscbG6nhtc8)8Daf1IB3bu44ZnMT)(qubiH)1BogLwOSgoV(HGxSc6IY5PamyJHaq9MJJhh6tHt84qFkm0T1wvu6Q4PwC7oGchFUXS93hIkaPqaOEZXululqoj6bMjz7zsGaGRThQJe0Z2tItck0jKuSYsY27ljdUGWLK3bcjj5)gSFulUDhqHJ4vHZrYf4JZVJl9dkuopfc(Vx065PSXJd9PWjQlQOwGCs0dmtsZ6h(FiyswajTzwLKVkjBptIE6ypmyky(ij4)EKmpsMLe0GVbMeg1QZXKeWpWXK8MAW9tHGKTNjPyuVKyD8sc4izbKa)dvjjGFGJjbfGcjOntT42DafoIxiQaKWRF4)HGr58u4(f)ahcoUtiJgCvg(ypmyky(Ime8pQQmSYoS1mQyoov2lOuMqNob)3lUtiJgCvg(ypmyky(Ihh6tHt0T7aQi6Z3(iJA2(xoVtidXKI6QSdBnJkMJtLdaBFAkBnJkMJtLXaJFPPS1mQyoA(LF5Ir92nnn4)EXDcz0GRYWh7HbtbZx84qFkCIUDhqfXRFV54iJA2(xoVtidXKI6QSdBnJkMJtLn)YV0u2AgvmhXaJF5Ir9MMYwZOI5OxqLlg1B3UPPje8FV4oHmAWvz4J9WGPG5l(v7MM2j4)ErRNNYg)QPPi9B8adhTGcjOnNHzmuLTRslayGbOROfuibT582ZzS6CZIJh7WqP0cqYLxBSge9B(5CxLDsWcqYLxBSnu34vAQfamWa0vKdvbO5lhak44XH(u4ev8Dv2j4)ErRNNYg)QPPjybadmaDfTEEkB8yhgQUulqoj6bMjrNWU6oizsAq7xijO75IKTNpMKbtsbiXT7GKjbJ2VqusIJjX4ltIJjrfGXtGHjbuKGr7xijONTNKwjbCK8y08rcEDBBmjGJeqrItsYGijy0(fscgqY27ljBptsXOjbJ2Vqs87gKmMeia)4Le)T8rY27ljy0(fscJA15ym1IB3bu4iEHOcqYHD1DqYzmA)crPfkRHZRFi4fRGUOCEkKamyJoSRUdsoJr7xyg2dDeCChB7PqOmb3UdOIoSRUdsoJr7xyg2dDeCCQ8Zmi6xLDsagSrh2v3bjNXO9lm3ZUjUJT9uistHbB0HD1DqYzmA)cZ9SBIhh6tHtevDttHbB0HD1DqYzmA)cZWEOJGJ41TTHwYucd2Od7Q7GKZy0(fMH9qhbhpo0NcdTKPegSrh2v3bjNXO9lmd7HocoUJT9uiOwGCs0dmJjbfGcjOntY8ibf6eskwzjzWK8vjbCKaf4tIFmjWmgQYofcsqHoHKIvwsqpBpjOauibTzs8cMeOaFs8JjjGna0KOijrIoXjp1IB3bu4iEHOcqYckKG2CE75mwDUzXOCEkKa89h4ybYwySYoDq634bgoAbfsqBodZyOkRYeSaGbgGUIwppLnESddLYeUFXpWHGJQ3eco4Xnz)SEn2S63G9lnn4)ErRNNYg)QDv649CtwfGMpOPijPStW)9IS1mQyoB(LFXJd9PWjQBsPPb)3lYwZOI5mgy8lECOpforDtQBA6Bq0V5Jd9PWqt3KuMGfamWa0v065PSXJDyO6sTa5KGcqbp7aksEGJe3yibgSys2EFjj0BZysW)Jjz7zOiXpUGWLKJFhJ7zysq3Zfj6posUaFmj6)Jl9dks6DmjggJjz79IeurcMTysoo0NAkeKaos2EMK2qDJxKe8FpsgmjEa4VKSasEUXqc49ibCK4fuKa9wZOIzsgmjEa4VKSasyuRohtT42DafoIxiQaKq634bggLLhYkad28XqW)CCixlgLiDZNvOtW)9INJKlWhNFhx6huXJd9PWjIQ00ec(Vx8CKCb(4874s)Gk(v7QStW)9ITNc(y4mhQcqZxixBMl(qm6hhpo0Ncdnew4yOJ6Uk7e8FViBnJkMZyGXV4XH(u4eryHJHoQttd(VxKTMrfZzZV8lECOpforew4yOJ6UulUDhqHJ4fIkaPqaOEZXO0cL1W51pe8Ivqxuopfo(DmU3dmSY1pe8g3jKZlidpCI62QYoUA22Z22kr634bgocd28XqW)CCixlUl1IB3bu4iEHOcqc)R3CmkTqznCE9dbVyf0fLZtHJFhJ79adRC9dbVXDc58cYWdNOUTQSJRMT9STTsK(nEGHJWGnFme8phhY1I7sT42DafoIxiQaKWlBm(LFg)yuAHYA486hcEXkOlkNNch)og37bgw56hcEJ7eY5fKHhorDHok74QzBpBBRePFJhy4imyZhdb)ZXHCT4Uulqoj6bMjr)d0ljGIelmjONTh8xsSUQ6uiOwC7oGchXlevaspWz5m4LlF)hJY5PGRMT9STn1cKtIEGzsGaof8XWK0Oo3SysqpBpjEbfjgqHGeUaFe9KyC8ofcsGERzuXmjEbtYEqrYciXmftYSK8vjb9S9KK8Fd2ps8cMeuOtiPyLLAXT7akCeVqubiXHQa08LdafmkNNcD6e8FViBnJkMZyGXV4XH(u4e1nP00G)7fzRzuXC28l)Ihh6tHtu3K6Q0cagya6kA98u24XH(u4etwsk7e8FVO6nHGdECt2pRxJnR(ny)IiDZNHwRkssPPjC)IFGdbhvVjeCWJBY(z9ASz1Vb7xKHG)rvLH72nnn4)Er1Bcbh84MSFwVgBw9BW(fr6MpNOcTQ4skn1cagya6kA98u24XomukD8EUjRcqZxIqMKOwGCs0dmtck0jKuSYsc6z7jbfGcjOndjiGtbFmmjnQZnlMeVGjbguq4scajFOVzzss(Vb7hjGJe09CrI(maaS5Jxsqd(gysyuRohtsa)ahtck0jKuSYscJA15ym1IB3bu4iEHOcqYYggVJBYUzquHCTOCEkKa89h4ybYwySsK(nEGHJw4SfuWZoGszhhVNBYQa08LiKjjLDc(VxS9uWhdN5qvaA(c5AZCXhIr)44xnnnblajxETX2qDJxDttTaKC51gRbr)MFoNMg8FVyGbaGnF8g)Qkd(VxmWaaWMpEJhh6tHHwRjbXoDGmq37x8dCi4O6nHGdECt2pRxJnR(ny)Ime8pQQmCxi2Xck4)Sr1JTdMZUzquHCTXDc5ms385UD7QmHG)7fTEEkB8RQStcwasU8AJ1GOFZpNttTaGbgGUIwqHe0MZBpNXQZnlo(vttdaySYPw(ubgFz48Bq0V5Jd9PWqZcagya6kAbfsqBoV9CgRo3S44XH(uyicDstNA5tfy8LHZVbr)Mpo0NcROuu6Q4tcATMee7ybf8F2O6X2bZz3miQqU24oHCgPB(C3UulUDhqHJ4fIkaPPS(v(oGcLZtHeGV)ahlq2cJvI0VXdmC0cNTGcE2buk7449CtwfGMVeHmjPStW)9ITNc(y4mhQcqZxixBMl(qm6hh)QPPjybi5YRn2gQB8QBAQfGKlV2yni638Z500G)7fdmaaS5J34xvzW)9Ibgaa28XB84qFkm0swsqSthid09(f)ahcoQEti4Gh3K9Z61yZQFd2Vidb)JQkd3fIDSGc(pBu9y7G5SBgevixBCNqoJ0nFUB3Ukti4)ErRNNYg)Qk7KGfGKlV2yni638Z50ulayGbOROfuibT582ZzS6CZIJF100aagRCQLpvGXxgo)ge9B(4qFkm0SaGbgGUIwqHe0MZBpNXQZnloECOpfgIqN00Pw(ubgFz48Bq0V5Jd9PWkkfLUk(KGwYscIDSGc(pBu9y7G5SBgevixBCNqoJ0nFUBxQfiNeia8B8adtYhZWKaks8GXm7Wys2EFjbTxljlGKaMeSJKHj5bosqHoHKIvwsWas2EFjz7zOiXpUwsq74LHjbcWpEjjGFGJjz75qQf3UdOWr8crfGes)gpWWOS8qwbSJKZpWLTEEklkr6MpRqcwaWadqxrRNNYgp2HHknnbK(nEGHJwqHe0MZWmgQYQ0cqYLxBSge9B(5CAk89h4ybYwym1cKtIEGzmj6Fa0tY8izks8IeO3AgvmtIxWKS3WyswajMPysMLKVkjONTNKK)BW(HssqHoHKIvws8cMeDc7Q7GKjPbTFHulUDhqHJ4fIkaP3)GkdEz28lgLZtb2AgvmhNk7fukD1STNTTvg8FVO6nHGdECt2pRxJnR(ny)IiDZNHwRkssk7ad2Od7Q7GKZy0(fMH9qhbh3X2EkePPjybi5YRnwS9agWb3vjs)gpWWrSJKZpWLTEEkl1cKtIEGzsGSv82tsZ63ZngsupGftY8iPz975gdjdUGWLKVk1IB3bu4iEHOcqcV(9CJbLZtHG)7fbfV94SkFwwDhqf)Qkd(VxeV(9CJjE87yCVhyyQf3UdOWr8crfGK1llBYb)3dLLhYkGx)mGdgLZtHG)7fXRFgWbhpo0NcdnuPStW)9IS1mQyoJbg)Ihh6tHtevPPb)3lYwZOI5S5x(fpo0NcNiQ6Q0X75MSkanFjczsIAbYjrp9dvXKOtCYtsa)ahtckafsqBMKpEkeKS9mjOauibTzsSGcE2buKSasS9STnjZJeuakKG2mjdMe3UF3yGIepa8xswajbmjwhVulUDhqHJ4fIkaj863Znguopfw3W1gXlBm(LHV5TrU8addReZ7ofcCedmGm8nVvzW)9I41VNBmrya6IAbYjrp9dvXK4yvsc4h4ysqbOqcAZK8XtHGKTNjbfGcjOntIfuWZoGIKfqITNTTjzEKGcqHe0MjzWK4297gduK4bG)sYcijGjX64LAXT7akCeVqubiHx)W)dbJY5PGfGKlV2yni638ZzLi9B8adhTGcjOnNHzmuLvPfamWa0v0ckKG2CE75mwDUzXXJd9PWqdvkta((dCSazlmMAbYjrpWmjnRFp3yib9S9K0SSX4hj6PBEljEbtsbiPz9Zaoyusc6EUiPaK0S(9CJHKbtYxfLKaf4tIFmjtrsY9l)ib6TMrfZKaoswajQhWssY)ny)ibDpxK4baKmjqMKirN4KNeWrIdR67GKjbJ2Vqs6DmjkEiIzlMKJd9PMcbjGJKbtYuK8mdI(LAXT7akCeVqubiHx)EUXGY5PW6gU2iEzJXVm8nVnYLhyyyLjSUHRnIx)mGdoYLhyyyLb)3lIx)EUXep(DmU3dmSYob)3lYwZOI5S5x(fpo0NcNi0rjBnJkMJtLn)YpLb)3lQEti4Gh3K9Z61yZQFd2Vis38zO1kQsknn4)Er1Bcbh84MSFwVgBw9BW(fr6MpNOcTIQKu649CtwfGMVeHmjLMcd2Od7Q7GKZy0(fMH9qhbhpo0NcNOIpn1T7aQOd7Q7GKZy0(fMH9qhbhNk)mdI(TRYeSaGbgGUIwppLnESddf1cKtIEGzsAw)W)dbtcKTI3EsupGftIxWKa)dvjrN4KNe09Crck0jKuSYsc4iz7zsGaGRThQJKG)7rYGjXda)LKfqYZngsaVhjGJeOaFieMeRRsIoXjp1IB3bu4iEHOcqcV(H)hcgLZtHG)7fbfV94S1W(Lro4buXVAAAW)9ITNc(y4mhQcqZxixBMl(qm6hh)QPPb)3lA98u24xvzNG)7fphjxGpo)oU0pOIhh6tHHgclCm0rn01YJPJJ3ZnzvaA(uujlPUkd(Vx8CKCb(4874s)Gk(vttti4)EXZrYf4JZVJl9dQ4xvzcwaWadqxXZrYf4JZVJl9dQ4XomuPPjybi5YRnIKRThQRBAQJ3ZnzvaA(seYKKs2AgvmhNk7fuulqoj64GIKfqsO3Mjz7zscy8sc4rsZ6NbCWKeafj41TTNcbjZsYxLei4FSTnqrYuK4fuKa9wZOIzsc(ljj)3G9JKbxljEa4VKSascysupG1YWulUDhqHJ4fIkaj86h(Fiyuopfw3W1gXRFgWbh5YdmmSYeUFXpWHGJ7eYObxLHp2ddMcMVidb)JQkdRStW)9I41pd4GJF10uhVNBYQa08LiKjPUkd(VxeV(zahCeVUTn0sMYob)3lYwZOI5mgy8l(vttd(VxKTMrfZzZV8l(v7Qm4)Er1Bcbh84MSFwVgBw9BW(fr6MpdTwvCjPSJfamWa0v065PSXJd9PWjQBsPPjG0VXdmC0ckKG2CgMXqvwLwasU8AJ1GOFZpN7sTa5KON(HQK0S(H)hcMKPiXjrXbrmBjPby8JeO3AgvmJssGbfeUKy4LKzjr9awss(Vb7hjD2EFjzWK07fSHHjjaks4z75JKTNjPz975gdjMPysahjBptIoXjFIqMKiXmftYdCK0S(H)hcUlkjbguq4scajFOVzzs8IeiBfV9KOEaljEbtIHxs2EMepaGKjXmftsVxWgMKM1pd4GPwC7oGchXlevas41p8)qWOCEkKW9l(boeCCNqgn4Qm8XEyWuW8fzi4FuvzyLDc(Vxu9MqWbpUj7N1RXMv)gSFrKU5ZqRvfxsPPb)3lQEti4Gh3K9Z61yZQFd2Vis38zO1kQss56gU2iEzJXVm8nVnYLhyy4Ukd(VxKTMrfZzmW4x84qFkCIkoLS1mQyoovgdm(PmHG)7fbfV94SkFwwDhqf)QktyDdxBeV(zahCKlpWWWkTaGbgGUIwppLnECOpforfNYowaWadqxX2tbFmCgRo3S44XH(u4evCPPjybi5YRn2gQB8Ql1cKtIEGzs0FbGctYuKKC)YpsGERzuXmjEbtc2rYKazVBEqu))ngs0FbGIKh4ibf6eskwzjXlysGaof8XWKa9HQa08fY1sT42DafoIxiQaKkgDoeakuopf6e8FViBnJkMZMF5x84qFkCImQz7F58oHCAAhBVFiyScTQ8yBVFi48oHm0qv30uBVFiyScjRRsxnB7zBBLi9B8adhXoso)ax265PSulUDhqHJ4fIkaPE38YHaqHY5PqNG)7fzRzuXC28l)Ihh6tHtKrnB)lN3jKvMGfGKlV2yBOUXR00ob)3l2Ek4JHZCOkanFHCTzU4dXOFC8RQ0cqYLxBSnu34v300o2E)qWyfAv5X2E)qW5DczOHQUPP2E)qWyfswAAW)9IwppLn(v7Q0vZ2E22wjs)gpWWrSJKZpWLTEEkl1IB3bu4iEHOcq69nMCiauOCEk0j4)Er2AgvmNn)YV4XH(u4ezuZ2)Y5DczLjybi5YRn2gQB8knTtW)9ITNc(y4mhQcqZxixBMl(qm6hh)QkTaKC51gBd1nE1nnTJT3pemwHwvEST3peCENqgAOQBAQT3pemwHKLMg8FVO1ZtzJF1UkD1STNTTvI0VXdmCe7i58dCzRNNYsTa5KOhyMeila0tcOiXctT42DafoIxiQaKq73nGldEz28lMAbYjrpWmjnRFV5yswajQhWssdW4hjqV1mQygLKGcDcjfRSK07ysmmgtYoHmjBVxK4KazD(2tcJA2(xMed)wsahjGYafjj3V8JeO3AgvmtYGj5RsT42DafoIxiQaKWRFV5yuopfyRzuXCCQS5x(LMYwZOI5igy8lxmQ30u2Agvmh9cQCXOEttd(VxeTF3aUm4LzZV44xvzW)9IS1mQyoB(LFXVAAANG)7fTEEkB84qFkm0C7oGkI(8TpYOMT)LZ7eYkd(Vx065PSXVAxQfiNe9aZKazD(2tcy75d9Gzsq3p2EsgmjtrsdW4hjqV1mQygLKGcDcjfRSKaoswajQhWssY9l)ib6TMrfZulUDhqHJ4fIkaj0NV9ulqoj6F3y2(7tT42DafoIxiQaKUFLD7oGkBg8IYYdzfEUXS93xRbRYwn9QBsTQTARMga]] )


end