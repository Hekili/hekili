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


    spec:RegisterPack( "Balance", 20210310, [[dafjKeqirOhbf4sqLKnrI(euqJsvYPuLAvqHQxPqAwqfUfPsQDj0VaHgMiYXivzzGiptHW0GkX1Gk12ab13iHkJdQK6CGGSosvvnpqu3JeSprWbjv0cjvLhcv0ejHQUiuiBKuvLpcfkYiHcf1jjHYkfr9sqaAMke5MKkj2jPs9tOqHHQqulLujPNkstLuHRsQeBfea(kiGgluO0EjL)kQbtCyQwSapMstguxg1Mv0NbPrRkoTuRgea9AfQztXTf0UL8BGHtshheOLRYZHmDLUUQA7qPVdvnEsiNhkA9KQkZxb7hzn900HwkSVSMUHusqsVKgHEjf1dcHl6bjCTw6IPkRLQ62XouwlT8qwlvFUXllRLQ6yAaoSMo0srG)zzT0NDvr6FicrO9(8dIwqierD434Bdk75ZfIOo0crT0GFBwfR0c0sH9L10nKscs6L0i0lPOEqiCrpiPNwQ)3hWPLM2H4ul9PHH5slqlfMrwTu95gVSmjk(73WuY6k(zFirVKWbjqkjiPhLmLmoF8ckJ0)uY6As0jmmdtskW4hj6J9WiLSUMeC(4fugMK1pO8M7jjwhXiswajwmTgoV(bLxuKswxtIUkhcWYWK8RITmc5hMKG1V2dmmIKxDKJ4Ge1JXMrRFO)bLjrxNajQhJnIw)q)dk)osjRRjrNybnmjQhBD02fusGapFFiPNK0lgIizFysWFGckjyK10QiosjRRjrxXhZKGtqHfmMjzFyssv7RxejojMExdtsi4ysMgwrDGHj5vpjbtWNKhhUWWLKNEjPxsqD43SEXGpYGjj479He9HXqN6GKrjbNSHrB7gs0PPHwHCT4GKEXqysqJB13rkzDnj6k(yMKqaAjbdNn0NnFCO3fcdjbz5YVgGiXvvnysYcijaGqKmBOplIeqzWmQLAA0I00Hwkmp9Vz10HMU1tthAPUDBqPLIag)YbShQLYLhyyyn9PTA6gsA6qlLlpWWWA6tlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLIuzJjV(bLxueT(nDJHKeirpsusYlssKK1nCTr06NbCWrU8addtYWajRB4AJOLng)YWxp3ixEGHHj5njddKGuzJjV(bLxueT(nDJHKeibsAPWmYET62GslnLxej6eGrKaksgXOKGV3hWFjb(65sIxWKGV3hssx)mGdMeVGjbsJscyF4dFJyTuS(LlpK1sBu2bS2QP7rOPdTuU8addRPpTuGQwkIxTu3UnO0sX6x7bgwlfRB(SwksLnM86huErr063SpMKeirpTuygzVwDBqPLMYlIeRHDSmj4F4IK01VzFmjwVi5PxsG0OKS(bLxej4FA7djnIKJnmwVwsMGJK9HjbJSMwfXKSascysupEY3XWK4fmj4FA7djZ2y4JKfqI1rRwkw)YLhYAPnkBnSJL1wnDJlA6qlLlpWWWA6tl1TBdkT0a(q8nUlOAPWmYET62Gslvxqmj6JpeFJ7ckj479HeCQtiQyLLeWrIpx(ibNGclymtsxKGtDcrfRSAP2Rx(Axl9fjjsIfGLlV2y1qF280zsggijrsSaGbgGVIwqHfmMZ7dNrQ91lk(vj5njkjj4pNrRN7Ygpo07crscKOhU1wnDJBnDOLYLhyyyn9PLAVE5RDT0G)CgTEUlB84qVlejjqIE4MKHbscaiejkjz2qF28XHExisGmjqc3APWmYET62GslDKblj479HeNeCQtiQyLLK9XxsAuHHljojJ83G8Je1dyjbCKG)Hls2hMKzd9zjPrK4bG)sYciHlyTu3UnO0svbBdkTvt3qynDOLYLhyyyn9PLcu1sr8QL62TbLwkw)ApWWAPyDZN1sTCBi5fjViPRLpvGXxgopBOpB(4qVlej6As0d3KORjXcagya(kA9Cx24XHExisEtcejrpCDsK8MefiXYTHKxK8IKUw(ubgFz48SH(S5Jd9UqKORjrpCtIUMe9GusKORjXcagya(kAbfwWyoVpCgP2xVO4XHExisEtcejrpCDsK8MKHbsSaGbgGVIwp3LnECO3fIKeiPRLpvGXxgopBOpB(4qVlejddKybadmaFfTGclymN3hoJu7Rxu84qVlejjqsxlFQaJVmCE2qF28XHExis01KOxsKmmqsIKyby5YRnwn0NnpDwlfMr2Rv3guAP40n2VXxgrc(hEF4JKpQlOKGtqHfmMjPa4jbFBmK4gdapjyc(KSasqBBmKyD0sY(WKG8qMepe8RLeWKeCckSGX8O4uNquXkljwhTiTuS(LlpK1sTGclymNHzeMLvB10TItthAPC5bggwtFAPavTueVAPUDBqPLI1V2dmSwkw38zT0xKKijme83QQmCKdvX8y3KbhC5LLjzyGelayGb4RihQI5XUjdo4Yllhpo07crcKjrpiCsKOKKejXcagya(kYHQyESBYGdU8YYXJDymj5njddKyby5YRnogZR9slfMr2Rv3guAP6cIHjzbKaZghts2hMKpYHYKaMKGtDcrfRSKG)Hls(OUGscm4hyysafjFeRLI1VC5HSwQfoBbfCVnO0wnDJR10HwkxEGHH10NwkmJSxRUnO0s1fetcgfQI5XUHemghC5LLjbsjHylIKaEcoMeNeCQtiQyLLKpIJAPLhYAPCOkMh7Mm4GlVSSwQ96LV21sTaGbgGVIwp3LnECO3fIeitcKsIeLKybadmaFfTGclymN3hoJu7Rxu84qVlejqMeiLejddKeaqisusYSH(S5Jd9UqKazsgHItl1TBdkTuoufZJDtgCWLxwwB10nesthAPC5bggwtFAPWmYET62GslvxqmjPGVXWBxqjrx9hGjjqyeBrKeWtWXK4KGtDcrfRSK8rCulT8qwlfb(gdVBxqZ3patTu71lFTRLAbadmaFfTEUlB84qVlejqMeimjkjjrsW6x7bgoAbfwWyodZimlljddKybadmaFfTGclymN3hoJu7Rxu84qVlejqMeimjkjbRFThy4OfuybJ5mmJWSSKmmqsaaHirjjZg6ZMpo07crcKjbs4wl1TBdkTue4Bm8UDbnF)am1wnDRxsA6qlLlpWWWA6tl1TBdkT0Uq27VEGHZqWVx7pmdZyBlRLAVE5RDT0G)CgTEUlB84qVlejjqIE4wlT8qwlTlK9(Rhy4me871(dZWm22YARMU1tpnDOLYLhyyyn9PL62TbLw6EDnMx90sHzK9A1TbLwQoEAejnIeNKZ3h(iHnEa48LjbVJjjlGKqFmtIBmKaks(iMe06lj711yErKSascysmDXWK8vjbFVpKGtDcrfRSK4fmj4euybJzs8cMKpIjzFysGubtcYawsafjwys6jjbG9HK96AmVis8JjbuK8rmjO1xs2RRX8I0sTxV81Uw6lsW6x7bgocQ8hX596AmVKOaj6rYWajy9R9adhbv(J48EDnMxsuGKrqYBsusYlsc(Zz065USXVkjddKybadmaFfTEUlB84qVlejJscKijbs2RRX8gx9IwaWadWxr4)5BdksusYlssKelalxETXQH(S5PZKmmqsIKG1V2dmC0ckSGXCgMrywwsEtIsssKelalxETXXyETxKmmqIfGLlV2y1qF280zsuscw)ApWWrlOWcgZzygHzzjrjjwaWadWxrlOWcgZ59HZi1(6ff)QKOKKejXcagya(kA9Cx24xLeLK8IKxKe8NZiBnTkIZMF5x84qVlejjqIEjrYWajb)5mYwtRI4mcy8lECO3fIKeirVKi5njkjjrsUFXtWbLJbUXllNbZSBm59PlOOixEGHHjzyGKxKe8NZyGB8YYzWm7gtEF6ckkx((poIw3oMefib3KmmqsWFoJbUXllNbZSBm59PlOOSFwV4iAD7ysuGeCtYBsEtYWajb)5moUl4JHZCOkapFHCTzU4dARFC8RsYBsggijaGqKOKKzd9zZhh6DHibYKaPKizyGeS(1EGHJGk)rCEVUgZljkqssARMU1dsA6qlLlpWWWA6tl1E9Yx7APy9R9adhbv(J48EDnMxsuGKrqIsssKK96AmVXvV4XomMzlayGb4lsggi5fjb)5mA9Cx24xLKHbsSaGbgGVIwp3LnECO3fIKrjbsKKaj711yEJlKIwaWadWxr4)5BdksusYlssKelalxETXQH(S5PZKmmqsIKG1V2dmC0ckSGXCgMrywwsEtIsssKelalxETXXyETxKmmqIfGLlV2y1qF280zsuscw)ApWWrlOWcgZzygHzzjrjjwaWadWxrlOWcgZ59HZi1(6ff)QKOKKejXcagya(kA9Cx24xLeLK8IKxKe8NZiBnTkIZMF5x84qVlejjqIEjrYWajb)5mYwtRI4mcy8lECO3fIKeirVKi5njkjjrsUFXtWbLJbUXllNbZSBm59PlOOixEGHHjzyGKxKe8NZyGB8YYzWm7gtEF6ckkx((poIw3oMefib3KmmqsWFoJbUXllNbZSBm59PlOOSFwV4iAD7ysuGeCtYBsEtYBsggij4pNXXDbFmCMdvb45lKRnZfFqB9JJFvsggijaGqKOKKzd9zZhh6DHibYKaPKizyGeS(1EGHJGk)rCEVUgZljkqssAPUDBqPLUxxJ5fsARMU1BeA6qlLlpWWWA6tl1TBdkT0pIZ9YHiTuygzVwDBqPLQligrIBmKa2h(ibuK8rmj9YHisafjwyTu71lFTRLg8NZO1ZDzJFvsggiXcWYLxBSAOpBE6mjkjbRFThy4OfuybJ5mmJWSSKOKelayGb4ROfuybJ58(WzKAF9IIFvsussIKybadmaFfTEUlB8RsIssErYlsc(ZzKTMwfXzZV8lECO3fIKeirVKizyGKG)CgzRPvrCgbm(fpo07crscKOxsK8MeLKKij3V4j4GYXa34LLZGz2nM8(0fuuKlpWWWKmmqY9lEcoOCmWnEz5myMDJjVpDbff5Ydmmmjkj5fjb)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJjjbsgbjddKe8NZyGB8YYzWm7gtEF6ckk7N1loIw3oMKeizeK8MK3KmmqsWFoJJ7c(y4mhQcWZxixBMl(G26hh)QKmmqsaaHirjjZg6ZMpo07crcKjbsjPTA6wpCrthAPC5bggwtFAPWmYET62GslvXZ2gMjXTBdksmnAjjWrmmjGIeuVFFBqbrddTrAPUDBqPLE)k72Tbv20OvlfTxBxnDRNwQ96LV21sX6x7bgo2OSdyTutJ2C5HSwQdyTvt36HBnDOLYLhyyyn9PLAVE5RDT07x8eCq5yGB8YYzWm7gtEF6ckkYqWFRQYWAPO9A7QPB90sD72Gsl9(v2TBdQSPrRwQPrBU8qwlna4R2QPB9GWA6qlLlpWWWA6tl1TBdkT07xz3UnOYMgTAPMgT5YdzTu0QTARwAaWxnDOPB900HwkxEGHH10NwQB3guAPNJLlWhLNhx6hMAPWmYET62Gslv)DCPFysc(EFibN6eIkwz1sTxV81UwAWFoJwp3LnECO3fIKeirpCRTA6gsA6qlLlpWWWA6tlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLMijb)5mg4gVSCgmZUXK3NUGIYLV)JJFvsussIKe8NZyGB8YYzWm7gtEF6ckk7N1lo(v1sHzK9A1TbLwkoFy7yej9KK9HjrFaDQdsSxVKe8NtsAejfyj5RsYeCKy8Lps(iwlfRF5YdzTu71Bb2VQ2QP7rOPdTuU8addRPpTu3UnO0sDyxDBSCgH3VqTulMwdNx)GYlst36PLAVE5RDT0G)CgdCJxwodMz3yY7txqr5Y3)Xr062XKazsWfsussWFoJbUXllNbZSBm59PlOOSFwV4iAD7ysGmj4cjkj5fjjscmyJoSRUnwoJW7xyg2dDOCCB74UGsIsssKe3UnOIoSRUnwoJW7xyg2dDOCSR800qFwsusYlssKeyWgDyxDBSCgH3VW8d7M422XDbLKHbsGbB0HD1TXYzeE)cZpSBIhh6DHijbsgbjVjzyGeyWgDyxDBSCgH3VWmSh6q5iAD7ysGmjJGeLKad2Od7QBJLZi8(fMH9qhkhpo07crcKjb3KOKeyWgDyxDBSCgH3VWmSh6q5422XDbLK3APWmYET62Gslvxqmj6e2v3gltskE)cjb)dxK4ljggHizF8IeCHe9b0PoibTUDmIeVGjzbKC88y0djojqwbircAD7ysCejgFzsCejQaeQdmmjGJKTdzs6LeeGKEjXVRXYisGa8Jws85YhjojJyusqRBhtcRi1(yK2QPBCrthAPC5bggwtFAPUDBqPLAbfwWyoVpCgP2xViTuygzVwDBqPLQliMeCckSGXmj479HeCQtiQyLLe8pCrIkaH6adtIxWKa2h(W3iMe89(qItI(a6uhKe8NtsW)WfjWmcZY2fuTu71lFTRL(IeS(1EGHJwqHfmMZWmcZYsIsssKelayGb4RO1ZDzJh7WysYWajb)5mA9Cx24xLK3KOKKxKe8NZyGB8YYzWm7gtEF6ckkx((poIw3oMefib3KmmqsWFoJbUXllNbZSBm59PlOOSFwV4iAD7ysuGeCtYBsggijaGqKOKKzd9zZhh6DHibYKOxsARMUXTMo0s5YdmmSM(0sD72GslD(pmZGzMn)I1sHzK9A1TbLwQ(dGrK4is2hMKzFOLeOwys6IK9HjXjrFaDQdsW3fmapjGJe89(qY(WKabeZR9IKG)Csc4ibFVpK4KGRhfXws0jSRUnwMKu8(fsIxWKG37LKj4ibN6eIkwzjPNK0lj4b1ssatYxLehQ3fjb8eCmj7dtIfMKgrYSRg9WWAP2Rx(Axl9fjVij4pNXa34LLZGz2nM8(0fuuU89FCeTUDmjjqcUqYWajb)5mg4gVSCgmZUXK3NUGIY(z9IJO1TJjjbsWfsEtIssErc89B4ybYwyejddKybadmaFfTEUlB84qVlejjqcUtIKHbsErIfGLlV2y1qF280zsusIfamWa8v0ckSGXCEF4msTVErXJd9UqKKaj4ojsEtYBsEtYWajVibgSrh2v3glNr49lmd7HouoECO3fIKeibxtIssSaGbgGVIwp3LnECO3fIKeirVKirjjwawU8AJfBpGbCWK8MKHbscaiejkjPRLpvGXxgopBOpB(4qVlejqMeCnjddK8IelalxETXXyETxKOKKG)Cgh3f8XWzoufGNVqU24xLK3ARMUHWA6qlLlpWWWA6tl1TBdkTuRxw2Kd(ZPwQ96LV21sFrsWFoJbUXllNbZSBm59PlOOC57)44XHExissGeCjIBsggij4pNXa34LLZGz2nM8(0fuu2pRxC84qVlejjqcUeXnjVjrjjViXcagya(kA9Cx24XHExissGefhjddK8IelayGb4RihQcWZxoauWXJd9UqKKajkosussIKe8NZ44UGpgoZHQa88fY1M5IpOT(XXVkjkjXcWYLxBCmMx7fjVj5njkjXr75MSkapFKKGcKmIK0sd(ZzU8qwlfT(zahSwkmJSxRUnO0sXPxw2qs66NbCWKGV3hsCskgpj6dOtDqsWFojXlysWPoHOIvwsAuHHljEa4VKSascys(igwB10TItthAPC5bggwtFAPUDBqPLIw)MUXOLcZi71QBdkTuf)puLK01p0)GYisW37djoj6dOtDqsWFojj4VKuGLe8pCrIkay6ckjtWrco1jevSYsc4ibcyxWhdtsQAF9I0sTxV81Uw66gU2iAzJXVm81ZnYLhyyysuscI3TlOOicyaz4RNljkjj4pNr0630nMimaFPTA6gxRPdTuU8addRPpTu3UnO0srRFO)bL1sHzK9A1TbLwQI)hQss66h6Fqzej479HK9Hjja4ljb)5KKG)ssbwsW)WfjQaGPlOKmbhjwNeWrchQcWZhjbGcwl1E9Yx7APjscw)ApWWr71Bb2Vkjkj5fjwawU8AJvd9zZtNjzyGelayGb4RO1ZDzJhh6DHijbsuCKmmqsIKG1V2dmC0cNTGcU3guKOKKejXcWYLxBCmMx7fjddK8IelayGb4RihQcWZxoauWXJd9UqKKajkosussIKe8NZ44UGpgoZHQa88fY1M5IpOT(XXVkjkjXcWYLxBCmMx7fjVj5njkj5fjjscmyJZ)HzgmZS5xCCB74UGsYWajjsIfamWa8v065USXJDymjzyGKejXcagya(kAbfwWyoVpCgP2xVO4XomMK8wB10nesthAPC5bggwtFAPUDBqPLIw)q)dkRLcZi71QBdkTuf)puLK01p0)GYisc4j4ysWjOWcgZAP2Rx(Axl9fjwaWadWxrlOWcgZ59HZi1(6ffpo07crcKjb3KOKKejb((nCSazlmIeLK8IeS(1EGHJwqHfmMZWmcZYsYWajwaWadWxrRN7Ygpo07crcKjb3K8MeLKG1V2dmC0cNTGcU3guK8MeLKKijWGno)hMzWmZMFXXTTJ7ckjkjXcWYLxBSAOpBE6mjkjjrsGVFdhlq2cJirjjS10Qio2v2lm1wnDRxsA6qlLlpWWWA6tlfOQLI4vl1TBdkTuS(1EGH1sX6MpRL(IKG)CgphlxGpkppU0pmJhh6DHijbsWnjddKKijb)5mEowUaFuEECPFyg)QK8MeLK8IKG)Cgh3f8XWzoufGNVqU2mx8bT1poECO3fIeitculCm0vejVjrjjVij4pNr2AAveNraJFXJd9UqKKajqTWXqxrKmmqsWFoJS10QioB(LFXJd9UqKKajqTWXqxrK8wlfMr2Rv3guAPkEqHHljWGLe4)1fus2hMeUGjbmjrx1XYf4Jir)DCPFyIdsG)xxqjzCxWhdtchQcWZxixljGJKUizFysmoAjbQfMeWKeVibJSMwfXAPy9lxEiRLcd28XqWFFCixlsB10TE6PPdTuU8addRPpTu3UnO0sr)A2hRLAVE5RDT0JNhJE8adtIssw)GYBC7qoVGmCZKKaj6bHjrjjUA2(W2XKOKeS(1EGHJWGnFme83hhY1I0sTyAnCE9dkVinDRN2QPB9GKMo0s5YdmmSM(0sD72GslneaQzFSwQ96LV21spEEm6Xdmmjkjz9dkVXTd58cYWntscKO3iI4MeLK4Qz7dBhtIssW6x7bgocd28XqWFFCixlsl1IP1W51pO8I00TEARMU1BeA6qlLlpWWWA6tl1TBdkTu0YgJF5PXpwl1E9Yx7APhppg94bgMeLKS(bL342HCEbz4Mjjbs0dctYOKCCO3fIeLK4Qz7dBhtIssW6x7bgocd28XqWFFCixlsl1IP1W51pO8I00TEARMU1dx00HwkxEGHH10NwQB3guAPtWz5myMlF)hRLcZi71QBdkTu9hq3KaksSWKGV3hWFjX6QQDbvl1E9Yx7APUA2(W2XARMU1d3A6qlLlpWWWA6tl1TBdkTuoufGNVCaOG1sHzK9A1TbLwkgfQcWZhj6duWKG)Hls8aWFjzbKW1YhjojfJNe9b0PoibFxWa8K4fmjihltYeCKGtDcrfRSAP2Rx(Axl9fjS10QioA(LF5Iv0sYWajS10QioIag)YfROLKHbsyRPvrC0lmZfROLKHbsc(ZzmWnEz5myMDJjVpDbfLlF)hhpo07crscKGlrCtYWajb)5mg4gVSCgmZUXK3NUGIY(z9IJhh6DHijbsWLiUjzyGehTNBYQa88rscKaHsIeLKybadmaFfTEUlB8yhgtsussIKaF)gowGSfgrYBsusYlsSaGbgGVIwp3LnECO3fIKeizejrYWajwaWadWxrRN7Ygp2HXKK3KmmqsaaHirjjDT8Pcm(YW5zd9zZhh6DHibYKOxsARMU1dcRPdTuU8addRPpTu3UnO0sN)dZmyMzZVyTuygzVwDBqPLQ)ayejxd9zjjGNGJj5J6ckj4uNAP2Rx(Axl1cagya(kA9Cx24XomMKOKeS(1EGHJw4SfuW92GIeLK8IehTNBYQa88rscKaHsIeLKKijwawU8AJvd9zZtNjzyGelalxETXQH(S5PZKOKehTNBYQa88rcKjbxsIK3KOKKxKKijwawU8AJvd9zZtNjzyGelayGb4ROfuybJ58(WzKAF9IIh7WysYBsussIKaF)gowGSfgPTA6wpfNMo0s5YdmmSM(0sD72Gsl1YggTTBYUPHwHCTAPWmYET62GslfN6eIkwzjb)dxK4ljqOKgLeDIgzsEbodapFKSpErcUKej6enYKGV3hsWjOWcgZVjbFVpG)sIbG6ckjBhYK0fj6ZaaWMpAjXlysmDXK8vjbFVpKGtqHfmMjPNK0lj4DejWmcZYYWAP2Rx(AxlnrsGVFdhlq2cJirjjy9R9adhTWzlOG7Tbfjkj5fjViXr75MSkapFKKajqOKirjjVij4pNXXDbFmCMdvb45lKRnZfFqB9JJFvsggijrsSaSC51ghJ51ErYBsggij4pNXadaaB(On(vjrjjb)5mgyaayZhTXJd9UqKazsGusKmkjViXck4FVr1JTnIZUPHwHCTXTd5mw38zsEtYBsggijaGqKOKKUw(ubgFz48SH(S5Jd9UqKazsGusKmkjViXck4FVr1JTnIZUPHwHCTXTd5mw38zsEtYWajwawU8AJvd9zZtNj5njkj5fjjsIfGLlV2y1qF280zsggi5fjoAp3Kvb45JeitcUKejddKad248FyMbZmB(fh32oUlOK8MeLK8IeS(1EGHJwqHfmMZWmcZYsYWajwaWadWxrlOWcgZ59HZi1(6ffp2HXKK3K8wB10TE4AnDOLYLhyyyn9PLAVE5RDT0ejb((nCSazlmIeLKG1V2dmC0cNTGcU3guKOKKxK8IehTNBYQa88rscKaHsIeLK8IKG)Cgh3f8XWzoufGNVqU2mx8bT1po(vjzyGKejXcWYLxBCmMx7fjVjzyGKG)CgdmaaS5J24xLeLKe8NZyGbaGnF0gpo07crcKjzejrYOK8IelOG)9gvp22io7MgAfY1g3oKZyDZNj5njVjzyGKaacrIss6A5tfy8LHZZg6ZMpo07crcKjzejrYOK8IelOG)9gvp22io7MgAfY1g3oKZyDZNj5njddKyby5YRnwn0NnpDMK3KOKKxKKijwawU8AJvd9zZtNjzyGKxK4O9CtwfGNpsGmj4ssKmmqcmyJZ)HzgmZS5xCCB74UGsYBsusYlsW6x7bgoAbfwWyodZimlljddKybadmaFfTGclymN3hoJu7Rxu8yhgtsEtYBTu3UnO0s7Y6x5BdkTvt36bH00HwkxEGHH10NwkqvlfXRwQB3guAPy9R9adRLI1nFwlLTMwfXXUYMF5hjyCsW1KarsC72GkIw)M9XrwrS9VCE7qMKrjjrsyRPvrCSRS5x(rcgNKxKaHjzusw3W1grGVjdM59HZtWXOnYLhyyysW4KmcsEtcejXTBdQi(Z3NiRi2(xoVDitYOKKuesKarsqQSXKFC0YAPWmYET62GslfJqBh6lJi5bGNKWV9HeDIgzs8JjbQ3fdtIkFKGylOG1sX6xU8qwl1rQJmFPSvB10nKssthAPC5bggwtFAPUDBqPLIw)q)dkRLcZi71QBdkTuf)puLK01p0)GYisW)Wfj7dtYSH(SK0is8aWFjzbKWfmoizECPFyssJiXda)LKfqcxW4GembFs8JjXxsGqjnkj6enYK0fjErcgznTkIXbj4uNquXkljghTis8cSp8rcUEueBrKaosWe8jbp4BGjbGLpRRssi4ys2hViHg0ljs0jAKjb)dxKGj4tcEW3axy4ss66h6FqzskaETu71lFTRL(IKaacrIss6A5tfy8LHZZg6ZMpo07crcKjbxizyGKxKe8NZ45y5c8r55XL(Hz84qVlejqMeOw4yORisW4Ky52qYlsC0EUjRcWZhjqKKrKejVjrjjb)5mEowUaFuEECPFyg)QK8MK3KmmqYlsC0EUjRcWZhjJscw)ApWWrhPoY8LYwsW4Ke8NZiBnTkIZiGXV4XHExisgLeyWgN)dZmyMzZV4422XO8XHExKGXjbsrCtscKONEjrYWajoAp3Kvb45JKrjbRFThy4OJuhz(szljyCsc(ZzKTMwfXzZV8lECO3fIKrjbgSX5)WmdMz28loUTDmkFCO3fjyCsGue3KKaj6PxsK8MeLKWwtRI4yxzVWKeLK8IKejj4pNrRN7Yg)QKmmqsIKSUHRnIw)mGdoYLhyyysEtIssErYlssKelayGb4RO1ZDzJFvsggiXcWYLxBCmMx7fjkjjrsSaGbgGVICOkapF5aqbh)QK8MKHbsSaSC51gRg6ZMNotYBsusYlssKelalxETrSCTpyEKmmqsIKe8NZO1ZDzJFvsggiXr75MSkapFKKajqOKi5njddK8IK1nCTr06NbCWrU8addtIssc(Zz065USXVkjkj5fjb)5mIw)mGdoIw3oMeitYiizyGehTNBYQa88rscKaHsIK3K8MKHbsc(Zz065USXJd9UqKKaj4AsussIKe8NZ45y5c8r55XL(Hz8RsIsssKK1nCTr06NbCWrU8addRTA6gs6PPdTuU8addRPpTu3UnO0slgFoeakTuygzVwDBqPLQliMeDfaOqK0fjJ0V8JemYAAvetIxWKGCSmjym7M5O6VVXqIUcauKmbhj4uNquXkRwQ96LV21sFrsWFoJS10QioB(LFXJd9UqKKajSIy7F582HmjddK8Ie7JFqzejkqcKirjjhBF8dkN3oKjbYKGBsEtYWaj2h)GYisuGKrqYBsusIRMTpSDS2QPBibjnDOLYLhyyyn9PLAVE5RDT0xKe8NZiBnTkIZMF5x84qVlejjqcRi2(xoVDitIssErIfamWa8v065USXJd9UqKKaj4ojsggiXcagya(kAbfwWyoVpCgP2xVO4XHExissGeCNejVjzyGKxKyF8dkJirbsGejkj5y7JFq582HmjqMeCtYBsggiX(4hugrIcKmcsEtIssC1S9HTJ1sD72Gsl9XnZCiauARMUH0i00HwkxEGHH10NwQ96LV21sFrsWFoJS10QioB(LFXJd9UqKKajSIy7F582Hmjkj5fjwaWadWxrRN7Ygpo07crscKG7KizyGelayGb4ROfuybJ58(WzKAF9IIhh6DHijbsWDsK8MKHbsErI9XpOmIefibsKOKKJTp(bLZBhYKazsWnjVjzyGe7JFqzejkqYii5njkjXvZ2h2owl1TBdkT053yYHaqPTA6gs4IMo0s5YdmmSM(0sHzK9A1TbLwkeiaJibuKyH1sD72GslfVFxdUmyMzZVyTvt3qc3A6qlLlpWWWA6tl1TBdkTu063SpwlfMr2Rv3guAP6cIjjD9B2htYcir9awssbg)ibJSMwfXKaosW)WfjDrcOmysYi9l)ibJSMwfXK4fmjFetceiaJir9awej9KKUizK(LFKGrwtRIyTu71lFTRLYwtRI4yxzZV8JKHbsyRPvrCebm(LlwrljddKWwtRI4OxyMlwrljddKe8NZiE)UgCzWmZMFXXVkjkjj4pNr2AAveNn)YV4xLKHbsErsWFoJwp3LnECO3fIeitIB3gur8NVprwrS9VCE7qMeLKe8NZO1ZDzJFvsERTA6gsqynDOL62TbLwk(Z3hTuU8addRPpTvt3qsXPPdTuU8addRPpTu3UnO0sVFLD72GkBA0QLAA0MlpK1sNUXSp3xB1wTuhWA6qt36PPdTuU8addRPpTuGQwkIxTu3UnO0sX6x7bgwlfRB(Sw6lsc(ZzC7qgp4Qm8XEyqxW8fpo07crcKjbQfog6kIKrjjPOEKmmqsWFoJBhY4bxLHp2dd6cMV4XHExisGmjUDBqfrRFZ(4iRi2(xoVDitYOKKuupsusYlsyRPvrCSRS5x(rYWajS10QioIag)YfROLKHbsyRPvrC0lmZfROLK3K8MeLKe8NZ42HmEWvz4J9WGUG5l(vjrjj3V4j4GYXTdz8GRYWh7HbDbZxKHG)wvLH1sHzK9A1TbLwkoDJ9B8LrKG)H3h(izFysu8h7HwFTp8rsWFojbFBmKmDJHeWCsc(EF6IK9HjPyfTKyD0QLI1VC5HSwk8XEygFBm5PBmzWCQTA6gsA6qlLlpWWWA6tlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLMijS10Qio2vgbm(rIssErcsLnM86huErr063SpMKeib3KOKK1nCTre4BYGzEF48eCmAJC5bggMKHbsqQSXKx)GYlkIw)M9XKKajkosERLcZi71QBdkTuC6g734lJib)dVp8rs66h6FqzsAej4b3(qI1rBxqjbGLpssx)M9XK0fjJ0V8JemYAAveRLI1VC5HSwAdTahNrRFO)bL1wnDpcnDOLYLhyyyn9PL62TbLwQfuybJ58(WzKAF9I0sHzK9A1TbLwQUGysWjOWcgZKG)Hls8LedJqKSpErcUtIeDIgzs8cMetxmjFvsW37dj4uNquXkRwQ96LV21sFrcw)ApWWrlOWcgZzygHzzjrjjjsIfamWa8v065USXJDymjzyGKG)CgTEUlB8RsYBsusYlsC0EUjRcWZhjqMeCNejddKG1V2dmCSHwGJZO1p0)GYK8MeLK8IKG)CgzRPvrC28l)Ihh6DHijbsGWKmmqsWFoJS10QioJag)Ihh6DHijbsGWK8MeLK8IKej5(fpbhuog4gVSCgmZUXK3NUGIIC5bggMKHbsc(ZzmWnEz5myMDJjVpDbfLlF)hhrRBhtscKmcsggij4pNXa34LLZGz2nM8(0fuu2pRxCeTUDmjjqYii5njddKeaqisusYSH(S5Jd9UqKazs0ljTvt34IMo0s5YdmmSM(0sD72Gsl9CSCb(O884s)WulfMr2Rv3guAP6cIjr)DCPFysc(EFibN6eIkwz1sTxV81UwAWFoJwp3LnECO3fIKeirpCRTA6g3A6qlLlpWWWA6tl1TBdkTu0VM9XAPwmTgoV(bLxKMU1tl1E9Yx7APVi545XOhpWWKmmqsWFoJS10QioJag)Ihh6DHibYKmcsuscBnTkIJDLraJFKOKKJd9UqKazs0dxirjjRB4AJiW3KbZ8(W5j4y0g5YdmmmjVjrjjRFq5nUDiNxqgUzssGe9Wfs01KGuzJjV(bLxejJsYXHExisusYlsyRPvrCSRSxysYWajhh6DHibYKa1chdDfrYBTuygzVwDBqPLQliMK0Fn7JjPlsu9cMdBljGIeVWCF6ckj7JVKyASmIe9WfeBrK4fmjggHibFVpKecoMK1pO8IiXlys8LK9HjHlysatsCssbg)ibJSMwfXK4lj6HlKGylIeWrIHrisoo07QlOK4iswajfyj5XX2fuswajhppg9qc8)6ckjJ0V8JemYAAveRTA6gcRPdTuU8addRPpTu3UnO0srRFt3y0sHzK9A1TbLwkeqMvj5Rss6630ngs8Le3yiz7qgrYVmmcrYh1fusgjmT(5is8cMKEjPrK4bG)sYcir9awsahjgEjzFysqQSTDdjUDBqrIPlMKa2aWtYJxWgMef)XEyqxW8rcOibsKS(bLxKwQ96LV21sFrsWFoJO1VPBmXJNhJE8adtIssErcsLnM86huErr0630ngsGmjJGKHbssKK7x8eCq542HmEWvz4J9WGUG5lYqWFRQYWK8MKHbsw3W1grGVjdM59HZtWXOnYLhyyysussWFoJS10QioJag)Ihh6DHibYKmcsuscBnTkIJDLraJFKOKKG)CgrRFt3yIhh6DHibYKO4irjjiv2yYRFq5ffrRFt3yijbfibxi5njkj5fjjsY9lEcoOC0GP1phLNgM3UGMHA6qvehzi4Vvvzysggiz7qMeCfj4cUjjbsc(ZzeT(nDJjECO3fIKrjbsK8MeLKS(bL342HCEbz4MjjbsWT2QPBfNMo0s5YdmmSM(0sD72GslfT(nDJrlfMr2Rv3guAPqG9(qII)ypmOly(i5Jyssx)MUXqYcizmZQK8vjzFysc(ZjjbysIBqas(OUGss6630ngsafj4MeeBbfmIeWrIHrisoo07QlOAP2Rx(Axl9(fpbhuoUDiJhCvg(ypmOly(Ime83QQmmjkjbPYgtE9dkVOiA9B6gdjjOajJGeLK8IKejj4pNXTdz8GRYWh7HbDbZx8RsIssc(ZzeT(nDJjE88y0Jhyysggi5fjy9R9adhHp2dZ4BJjpDJjdMtsusYlsc(ZzeT(nDJjECO3fIeitYiizyGeKkBm51pO8IIO1VPBmKKajqIeLKSUHRnIw2y8ldF9CJC5bggMeLKe8NZiA9B6gt84qVlejqMeCtYBsEtYBTvt34AnDOLYLhyyyn9PLcu1sr8QL62TbLwkw)ApWWAPyDZN1sD0EUjRcWZhjjqcUojs01K8Ie9sIemojb)5mUDiJhCvg(ypmOly(IO1TJj5nj6AsErsWFoJO1VPBmXJd9UqKGXjzeKarsqQSXKFC0YK8MeDnjVibgSX5)WmdMz28loECO3fIemoj4MK3KOKKG)CgrRFt3yIFvTuygzVwDBqPLIt3y)gFzej4F49HpsCssx)q)dktYhXKGVngsS(hXKKU(nDJHKfqY0ngsaZjoiXlys(iMK01p0)GYKSasgZSkjk(J9WGUG5Je062XK8v1sX6xU8qwlfT(nDJjJhuBE6gtgmNARMUHqA6qlLlpWWWA6tl1TBdkTu06h6FqzTuygzVwDBqPLQliMK01p0)GYKGV3hsu8h7HbDbZhjlGKXmRsYxLK9Hjj4pNKGV3hWFjXaqDbLK01VPBmK8v3oKjXlys(iMK01p0)GYKaksWLrjrFaDQdsqRBhJi5xBBibxiz9dkViTu71lFTRLI1V2dmCe(ypmJVnM80nMmyojrjjy9R9adhrRFt3yY4b1MNUXKbZjjkjjrsW6x7bgo2qlWXz06h6Fqzsggi5fjb)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJjjbsgbjddKe8NZyGB8YYzWm7gtEF6ckk7N1loIw3oMKeizeK8MeLKGuzJjV(bLxueT(nDJHeitcUqIssW6x7bgoIw)MUXKXdQnpDJjdMtTvt36LKMo0s5YdmmSM(0sD72Gsl1HD1TXYzeE)c1sTyAnCE9dkVinDRNwQ96LV21stKKTTJ7ckjkjjrsC72Gk6WU62y5mcVFHzyp0HYXUYttd9zjzyGeyWgDyxDBSCgH3VWmSh6q5iAD7ysGmjJGeLKad2Od7QBJLZi8(fMH9qhkhpo07crcKjzeAPWmYET62Gslvxqmji8(fsccqY(4ljyc(KaLxscDfrYxD7qMKamj5J6ckj9sIJiX4ltIJirfGqDGHjbuKyyeIK9XlsgbjO1TJrKaosGa8JwsW)WfjJyusqRBhJiHvKAFS2QPB90tthAPC5bggwtFAPUDBqPLgca1Spwl1IP1W51pO8I00TEAP2Rx(Axl945XOhpWWKOKK1pO8g3oKZlid3mjjqYlsErIE4cjJsYlsqQSXKx)GYlkIw)M9XKGXjbsKGXjj4pNr2AAveNn)YV4xLK3K8MKrj54qVlejVjbIK8Ie9izusw3W1gx8DLdbGcf5YdmmmjVjrjjViXcagya(kA9Cx24XomMKOKKejb((nCSazlmIeLK8IeS(1EGHJwqHfmMZWmcZYsYWajwaWadWxrlOWcgZ59HZi1(6ffp2HXKKHbssKelalxETXQH(S5PZK8MKHbsqQSXKx)GYlkIw)M9XKazsErYlsGWKORj5fjb)5mYwtRI4S5x(f)QKGXjbsK8MK3KGXj5fj6rYOKSUHRnU47khcafkYLhyyysEtYBsussIKWwtRI4icy8lxSIwsggi5fjS10Qio2vgbm(rYWajViHTMwfXXUYbG9HKHbsyRPvrCSRS5x(rYBsussIKSUHRnIaFtgmZ7dNNGJrBKlpWWWKmmqsWFoJQxhco42nz)SE12S63G8lI1nFMKeuGeiH7Ki5njkj5fjiv2yYRFq5ffrRFZ(ysGmj6LejyCsErIEKmkjRB4AJl(UYHaqHIC5bggMK3K8MeLK4O9CtwfGNpssGeCNej6Asc(ZzeT(nDJjECO3fIemojqysEtIssErsIKe8NZ44UGpgoZHQa88fY1M5IpOT(XXVkjddKWwtRI4yxzeW4hjddKKijwawU8AJJX8AVi5TwkmJSxRUnO0s1v55XOhs0vaGA2htspjbN6eIkwzjPrKCSdJjoizF4JjXpMedJqKSpErcUjz9dkVis6IKr6x(rcgznTkIjbFVpKKcw9hoiXWiej7JxKOxsKa2h(W3iMKUiXlmjbJSMwfXKaos(QKSasWnjRFq5frsapbhtItYi9l)ibJSMwfXrsu8GcdxsoEEm6He4)1fusGa2f8XWKGrHQa88fY1sYVmmcrsxKKcm(rcgznTkI1wnDRhK00HwkxEGHH10NwQB3guAPtWz5myMlF)hRLcZi71QBdkTuDbXKO)a6MeqrIfMe89(a(ljwxvTlOAP2Rx(Axl1vZ2h2owB10TEJqthAPC5bggwtFAPUDBqPLAzdJ22nz30qRqUwTuygzVwDBqPLQliMeCQtiQyLLeqrIfMKFzyeIeVGjX0ftsVK8vjbFVpKGtqHfmM1sTxV81UwAIKaF)gowGSfgrIssW6x7bgoAHZwqb3BdksusYlsc(ZzeT(nDJj(vjzyGehTNBYQa88rscKG7Ki5njkj5fjjssWFoJiGbTTLJFvsussIKe8NZO1ZDzJFvsusYlssKelalxETXQH(S5PZKmmqIfamWa8v0ckSGXCEF4msTVErXVkjkjXr75MSkapFKazsWDsK8MeLKS(bL342HCEbz4Mjjbs0d3Kmkjwqb)7nQESTrC2nn0kKRnUDiNX6MptYWajbaeIeLK01YNkW4ldNNn0NnFCO3fIeitcKsIKrjXck4FVr1JTnIZUPHwHCTXTd5mw38zsERTA6wpCrthAPC5bggwtFAP2Rx(AxlnrsGVFdhlq2cJirjjy9R9adhTWzlOG7Tbfjkj5fjb)5mIw)MUXe)QKmmqIJ2ZnzvaE(ijbsWDsK8MeLK8IKejj4pNreWG22YXVkjkjjrsc(Zz065USXVkjkj5fjjsIfGLlV2y1qF280zsggiXcagya(kAbfwWyoVpCgP2xVO4xLeLK4O9CtwfGNpsGmj4ojsEtIssw)GYBC7qoVGmCZKKajqkjsgLelOG)9gvp22io7MgAfY1g3oKZyDZNjzyGKaacrIss6A5tfy8LHZZg6ZMpo07crcKjzejrYOKybf8V3O6X2gXz30qRqU242HCgRB(mjV1sD72GslTlRFLVnO0wnDRhU10HwkxEGHH10NwQB3guAPCOkapF5aqbRLcZi71QBdkTuDbXKGrHQa88rI(afmjGIelmj479HK01VPBmK8vjXlysqowMKj4izK)gKFK4fmj4uNquXkRwQ96LV21sdaiejkjPRLpvGXxgopBOpB(4qVlejqMe9WnjddK8IKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjqMeiH7KizyGKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjjOajqc3jrYBsussWFoJO1VPBmXVkjkj5fjwaWadWxrRN7Ygpo07crscKG7KizyGe473WXcKTWisERTA6wpiSMo0s5YdmmSM(0sD72GslfTSX4xEA8J1sTyAnCE9dkVinDRNwQ96LV21spEEm6Xdmmjkjz7qoVGmCZKKaj6HBsuscsLnM86huErr063SpMeitcUqIssC1S9HTJjrjjVij4pNrRN7Ygpo07crscKOxsKmmqsIKe8NZO1ZDzJFvsERLcZi71QBdkTuDvEEm6HKPXpMeqrYxLKfqYiiz9dkVisW37d4VKGtDcrfRSKeWDbLepa8xswajSIu7JjXlyskWscalFwxvTlOARMU1tXPPdTuU8addRPpTu3UnO0sN)dZmyMzZVyTuygzVwDBqPLQliMe9haJiPNK0fQHzs8IemYAAvetIxWKy6IjPxs(QKGV3hsCsg5Vb5hjQhWsIxWKOtyxDBSmjP49lul1E9Yx7APS10Qio2v2lmjrjjUA2(W2XKOKKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjqMeiH7KirjjVibgSrh2v3glNr49lmd7HouoUTDCxqjzyGKejXcWYLxBSy7bmGdMKHbsqQSXKx)GYlIKeibsK8wB10TE4AnDOLYLhyyyn9PL62TbLwkA9B6gJwkmJSxRUnO0s1fetIts6630ngsWyu8(qI6bSK8ldJqKKU(nDJHKgrIBo2HXKKVkjGJembFs8JjXda)LKfqcalFwxLeDIgzTu71lFTRLg8NZiO49bLv5ZYQBdQ4xLeLK8IKG)CgrRFt3yIhppg94bgMKHbsC0EUjRcWZhjjqcekjsERTA6wpiKMo0s5YdmmSM(0sD72GslfT(nDJrlfMr2Rv3guAPk(FOkj6enYKeWtWXKGtqHfmMjbFVpKKU(nDJHeVGjzF4IK01p0)GYAP2Rx(Axl1cWYLxBSAOpBE6mjkj5fjy9R9adhTGclymNHzeMLLKHbsSaGbgGVIwp3Ln(vjzyGKG)CgTEUlB8RsYBsusIfamWa8v0ckSGXCEF4msTVErXJd9UqKazsGAHJHUIibJtILBdjViXr75MSkapFKarsWDsK8MeLKe8NZiA9B6gt84qVlejqMeCHeLKKijW3VHJfiBHrARMUHusA6qlLlpWWWA6tl1E9Yx7APwawU8AJvd9zZtNjrjjVibRFThy4OfuybJ5mmJWSSKmmqIfamWa8v065USXVkjddKe8NZO1ZDzJFvsEtIssSaGbgGVIwqHfmMZ7dNrQ91lkECO3fIeitceMeLKe8NZiA9B6gt8RsIssyRPvrCSRSxysIsssKeS(1EGHJn0cCCgT(H(huMeLKKijW3VHJfiBHrAPUDBqPLIw)q)dkRTA6gs6PPdTuU8addRPpTu3UnO0srRFO)bL1sHzK9A1TbLwQUGyssx)q)dktc(EFiXlsWyu8(qI6bSKaos6jjyc(yimjaS8zDvs0jAKjbFVpKGj4FKuSIwsSoAJKOtdcqc8pufrIorJmj(sY(WKWfmjGjj7dtceaCTpyEKe8Nts6jjPRFt3yibp4BGlmCjz6gdjG5KeqrcUqc4iXWiejRFq5fPLAVE5RDT0G)CgbfVpOS1W(LX2OguXVkjddK8IKejbT(n7JJUA2(W2XKOKKejbRFThy4ydTahNrRFO)bLjzyGKxKe8NZO1ZDzJhh6DHibYKGBsussWFoJwp3Ln(vjzyGKxKe8NZ45y5c8r55XL(Hz84qVlejqMeOw4yORisW4Ky52qYlsC0EUjRcWZhjqKKrKejVjrjjb)5mEowUaFuEECPFyg)QK8MK3KOKeS(1EGHJO1VPBmz8GAZt3yYG5KeLKGuzJjV(bLxueT(nDJHeitYii5njkj5fjjsY9lEcoOCC7qgp4Qm8XEyqxW8fzi4VvvzysggibPYgtE9dkVOiA9B6gdjqMKrqYBTvt3qcsA6qlLlpWWWA6tl1TBdkT0IXNdbGslfMr2Rv3guAP6cIjrxbakejDrskW4hjyK10QiMeVGjb5yzs0FFJHeDfaOizcosWPoHOIvwTu71lFTRL(IKG)CgzRPvrCgbm(fpo07crscKWkIT)LZBhYKmmqYlsSp(bLrKOajqIeLKCS9XpOCE7qMeitcUj5njddKyF8dkJirbsgbjVjrjjUA2(W2XARMUH0i00HwkxEGHH10NwQ96LV21sFrsWFoJS10QioJag)Ihh6DHijbsyfX2)Y5Tdzsggi5fj2h)GYisuGeirIsso2(4huoVDitcKjb3K8MKHbsSp(bLrKOajJGK3KOKexnBFy7yTu3UnO0sFCZmhcaL2QPBiHlA6qlLlpWWWA6tl1E9Yx7APVij4pNr2AAveNraJFXJd9UqKKajSIy7F582Hmjkj5fjwaWadWxrRN7Ygpo07crscKG7KizyGelayGb4ROfuybJ58(WzKAF9IIhh6DHijbsWDsK8MKHbsErI9XpOmIefibsKOKKJTp(bLZBhYKazsWnjVjzyGe7JFqzejkqYii5njkjXvZ2h2owl1TBdkT053yYHaqPTA6gs4wthAPC5bggwtFAPWmYET62GslvxqmjqGamIeqrcov8APUDBqPLI3VRbxgmZS5xS2QPBibH10HwkxEGHH10NwkqvlfXRwQB3guAPy9R9adRLI1nFwlfPYgtE9dkVOiA9B2htscKGlKmkjtdaCK8IKqhT8HzgRB(mjyCs0lPKibIKaPKi5njJsY0aahjVij4pNr06h6Fq5mhQcWZxixBgbm(frRBhtcejbxi5TwkmJSxRUnO0sXPBSFJVmIe8p8(WhjlGKpIjjD9B2htsxKKcm(rc(N2(qsJiXxsWnjRFq5fnQEKmbhjmw(WKeiLeUIKqhT8HjjGJeCHK01p0)GYKGrHQa88fY1scAD7yKwkw)YLhYAPO1VzFCURmcy8tB10nKuCA6qlLlpWWWA6tl1TBdkTu8NVpAPWmYET62GslvxqmjqGNVpK0fjPaJFKGrwtRIysahj9KKcqs663SpMe8TXqYSxs6AbKGtDcrfRSK4fMHGJ1sTxV81Uw6lsyRPvrC08l)YfROLKHbsyRPvrC0lmZfROLeLKG1V2dmCSrzRHDSmjVjrjjViz9dkVXTd58cYWntscKGlKmmqcBnTkIJMF5xURmKizyGKzd9zZhh6DHibYKOxsK8MKHbsc(ZzKTMwfXzeW4x84qVlejqMe3UnOIO1VzFCKveB)lN3oKjrjjb)5mYwtRI4mcy8l(vjzyGe2AAveh7kJag)irjjjscw)ApWWr063Spo3vgbm(rYWajb)5mA9Cx24XHExisGmjUDBqfrRFZ(4iRi2(xoVDitIsssKeS(1EGHJnkBnSJLjrjjb)5mA9Cx24XHExisGmjSIy7F582Hmjkjj4pNrRN7Yg)QKmmqsWFoJNJLlWhLNhx6hMXVkjkjbPYgt(XrltscKKuectIssErcsLnM86huErKazfizeKmmqsIKSUHRnIaFtgmZ7dNNGJrBKlpWWWK8MKHbssKeS(1EGHJnkBnSJLjrjjb)5mA9Cx24XHExissGewrS9VCE7qwB10nKW1A6qlLlpWWWA6tlfMr2Rv3guAP6cIjjD9B2htspjPlsgPF5hjyK10QighK0fjPaJFKGrwtRIysafj4YOKS(bLxejGJKfqI6bSKKcm(rcgznTkI1sD72GslfT(n7J1wnDdjiKMo0s5YdmmSM(0sHzK9A1TbLwQ(ZnM95(APUDBqPLE)k72Tbv20Ovl10OnxEiRLoDJzFUV2QTAPt3y2N7RPdnDRNMo0s5YdmmSM(0sD72GslfT(H(huwlfMr2Rv3guAPPRFO)bLjzcoscby5qUws(LHris(OUGsI(a6uhAP2Rx(AxlnrsUFXtWbLJbUXllNbZSBm59PlOOidb)TQkdRTA6gsA6qlLlpWWWA6tl1TBdkTu0VM9XAPwmTgoV(bLxKMU1tl1E9Yx7APWGngca1SpoECO3fIKei54qVlejyCsGeKibIKOhUwlfMr2Rv3guAP40rlj7dtcmyjbFVpKSpmjHa0sY2HmjlGehgMKFTTHK9Hjj0vejW)Z3guK0isE6nss6VM9XKCCO3fIKWVzBvtZWKSasc91(qsiauZ(ysG)NVnO0wnDpcnDOL62TbLwAiauZ(yTuU8addRPpTvB1srRMo00TEA6qlLlpWWWA6tl1TBdkT0ZXYf4JYZJl9dtTuygzVwDBqPLQliMK9HjbcaU2hmpsW37djoj4uNquXklj7JVK0OcdxsMhiKKr(Bq(PLAVE5RDT0G)CgTEUlB84qVlejjqIE4wB10nK00HwkxEGHH10NwQB3guAPO1p0)GYAPWmYET62GslvxqmjPRFO)bLjzbKmMzvs(QKSpmjk(J9WGUG5JKG)CsspjPxsWd(gysyfP2htsapbhtYSRg90fus2hMKIv0sI1rljGJKfqc8puLKaEcoMeCckSGXSwQ96LV21sVFXtWbLJBhY4bxLHp2dd6cMVidb)TQkdtIssErcBnTkIJDL9ctsussIK8IKxKe8NZ42HmEWvz4J9WGUG5lECO3fIKeiXTBdQi(Z3NiRi2(xoVDitYOKKuupsusYlsyRPvrCSRCayFizyGe2AAveh7kJag)izyGe2AAvehn)YVCXkAj5njddKe8NZ42HmEWvz4J9WGUG5lECO3fIKeiXTBdQiA9B2hhzfX2)Y5TdzsgLKKI6rIssErcBnTkIJDLn)YpsggiHTMwfXreW4xUyfTKmmqcBnTkIJEHzUyfTK8MK3KmmqsIKe8NZ42HmEWvz4J9WGUG5l(vj5njddK8IKG)CgTEUlB8RsYWajy9R9adhTGclymNHzeMLLK3KOKelayGb4ROfuybJ58(WzKAF9IIh7WysIssSaSC51gRg6ZMNotYBsusYlssKelalxETXXyETxKmmqIfamWa8vKdvb45lhak44XHExissGeCnjVjrjjVij4pNrRN7Yg)QKmmqsIKybadmaFfTEUlB8yhgtsERTA6EeA6qlLlpWWWA6tl1TBdkTuh2v3glNr49lul1IP1W51pO8I00TEAP2Rx(AxlnrsGbB0HD1TXYzeE)cZWEOdLJBBh3fusussIK42Tbv0HD1TXYzeE)cZWEOdLJDLNMg6ZsIssErsIKad2Od7QBJLZi8(fMFy3e32oUlOKmmqcmyJoSRUnwoJW7xy(HDt84qVlejjqcUj5njddKad2Od7QBJLZi8(fMH9qhkhrRBhtcKjzeKOKeyWgDyxDBSCgH3VWmSh6q54XHExisGmjJGeLKad2Od7QBJLZi8(fMH9qhkh32oUlOAPWmYET62Gslvxqmj6e2v3gltskE)cjb)dxKSp8XK0iskajUDBSmji8(fIdsCejgFzsCejQaeQdmmjGIeeE)cjbFVpKajsahjtgpFKGw3ogrc4ibuK4KmIrjbH3Vqsqas2hFjzFyskgpji8(fsIFxJLrKab4hTK4ZLps2hFjbH3VqsyfP2hJ0wnDJlA6qlLlpWWWA6tl1TBdkTulOWcgZ59HZi1(6fPLcZi71QBdkTuDbXisWjOWcgZK0tsWPoHOIvwsAejFvsahjyc(K4htcmJWSSDbLeCQtiQyLLe89(qcobfwWyMeVGjbtWNe)yscydapj4ssKOt0iRLAVE5RDT0ejb((nCSazlmIeLK8IKxKG1V2dmC0ckSGXCgMrywwsussIKybadmaFfTEUlB8yhgtsussIKC)INGdkhvVoeCWTBY(z9QTz1Vb5xKlpWWWKmmqsWFoJwp3Ln(vj5njkjXr75MSkapFKazsWLKirjjVij4pNr2AAveNn)YV4XHExissGe9sIKHbsc(ZzKTMwfXzeW4x84qVlejjqIEjrYBsggijaGqKOKKzd9zZhh6DHibYKOxsK8wB10nU10HwkxEGHH10NwkqvlfXRwQB3guAPy9R9adRLI1nFwl9fjb)5mEowUaFuEECPFygpo07crscKGBsggijrsc(Zz8CSCb(O884s)Wm(vj5njkj5fjb)5moUl4JHZCOkapFHCTzU4dARFC84qVlejqMeOw4yORisEtIssErsWFoJS10QioJag)Ihh6DHijbsGAHJHUIizyGKG)CgzRPvrC28l)Ihh6DHijbsGAHJHUIi5TwkmJSxRUnO0sXjOG7TbfjtWrIBmKadwej7JVKe6JzejO)XKSpmMK4hxy4sYXZJrpmmj4F4IeDvhlxGpIe93XL(HjjpoIedJqKSpErcUjbXwejhh6D1fusahj7dtYymV2lsc(ZjjnIepa8xswajt3yibmNKaos8ctsWiRPvrmjnIepa8xswajSIu7J1sX6xU8qwlfgS5JHG)(4qUwK2QPBiSMo0s5YdmmSM(0sD72GslneaQzFSwQ96LV21spEEm6Xdmmjkjz9dkVXTd58cYWntscKOhKirjjViXvZ2h2oMeLKG1V2dmCegS5JHG)(4qUwejV1sTyAnCE9dkVinDRN2QPBfNMo0s5YdmmSM(0sD72Gslf9RzFSwQ96LV21spEEm6Xdmmjkjz9dkVXTd58cYWntscKOhKirjjViXvZ2h2oMeLKG1V2dmCegS5JHG)(4qUwejV1sTyAnCE9dkVinDRN2QPBCTMo0s5YdmmSM(0sD72GslfTSX4xEA8J1sTxV81Uw6XZJrpEGHjrjjRFq5nUDiNxqgUzssGe9GWKOKKxK4Qz7dBhtIssW6x7bgocd28XqWFFCixlIK3APwmTgoV(bLxKMU1tB10nesthAPC5bggwtFAPUDBqPLobNLZGzU89FSwkmJSxRUnO0s1fetI(dOBsafjwysW37d4VKyDv1UGQLAVE5RDTuxnBFy7yTvt36LKMo0s5YdmmSM(0sD72GslLdvb45lhakyTuygzVwDBqPLQliMeiGDbFmmjPQ91lIe89(qIxysIbuqjHlWh6djghTDbLemYAAvetIxWKShMKSasmDXK0ljFvsW37djJ83G8JeVGjbN6eIkwz1sTxV81Uw6lsErsWFoJS10QioJag)Ihh6DHijbs0ljsggij4pNr2AAveNn)YV4XHExissGe9sIK3KOKelayGb4RO1ZDzJhh6DHijbsgrsKOKKxKe8NZO61HGdUDt2pRxTnR(ni)IyDZNjbYKajCjjsggijrsUFXtWbLJQxhco42nz)SE12S63G8lYqWFRQYWK8MK3KmmqsWFoJQxhco42nz)SE12S63G8lI1nFMKeuGeiP4sIKHbsSaGbgGVIwp3LnESdJjjkjXr75MSkapFKKajqOK0wnDRNEA6qlLlpWWWA6tl1TBdkTulBy02Uj7MgAfY1QLcZi71QBdkTuDbXKGtDcrfRSKGV3hsWjOWcgZqecyxWhdtsQAF9IiXlysGbfgUKaWYh(RxMKr(Bq(rc4ib)dxKOpdaaB(OLe8GVbMewrQ9XKeWtWXKGtDcrfRSKWksTpgPLAVE5RDT0ejb((nCSazlmIeLKG1V2dmC0cNTGcU3guKOKKxK4O9CtwfGNpssGeiusKOKKxKe8NZ44UGpgoZHQa88fY1M5IpOT(XXVkjddKKijwawU8AJJX8AVi5njddKyby5YRnwn0NnpDMKHbsc(ZzmWaaWMpAJFvsussWFoJbgaa28rB84qVlejqMeiLejJsYlsErceIemoj3V4j4GYr1RdbhC7MSFwVABw9Bq(fzi4VvvzysEtYOK8IelOG)9gvp22io7MgAfY1g3oKZyDZNj5njVj5njkjjrsc(Zz065USXVkjkj5fjjsIfGLlV2y1qF280zsggiXcagya(kAbfwWyoVpCgP2xVO4xLKHbscaiejkjPRLpvGXxgopBOpB(4qVlejqMelayGb4ROfuybJ58(WzKAF9IIhh6DHizusGWKmmqsxlFQaJVmCE2qF28XHExisWvKOhUojsGmjqkjsgLKxKybf8V3O6X2gXz30qRqU242HCgRB(mjVj5T2QPB9GKMo0s5YdmmSM(0sTxV81UwAIKaF)gowGSfgrIssW6x7bgoAHZwqb3BdksusYlsC0EUjRcWZhjjqcekjsusYlsc(ZzCCxWhdN5qvaE(c5AZCXh0w)44xLKHbssKelalxETXXyETxK8MKHbsSaSC51gRg6ZMNotYWajb)5mgyaayZhTXVkjkjj4pNXadaaB(OnECO3fIeitYisIKrj5fjVibcrcgNK7x8eCq5O61HGdUDt2pRxTnR(ni)Ime83QQmmjVjzusErIfuW)EJQhBBeNDtdTc5AJBhYzSU5ZK8MK3K8MeLKKijb)5mA9Cx24xLeLK8IKejXcWYLxBSAOpBE6mjddKybadmaFfTGclymN3hoJu7Rxu8RsYWajbaeIeLK01YNkW4ldNNn0NnFCO3fIeitIfamWa8v0ckSGXCEF4msTVErXJd9UqKmkjqysggiPRLpvGXxgopBOpB(4qVlej4ks0dxNejqMKrKejJsYlsSGc(3Bu9yBJ4SBAOvixBC7qoJ1nFMK3K8wl1TBdkT0US(v(2GsB10TEJqthAPC5bggwtFAPavTueVAPUDBqPLI1V2dmSwkw38zT0ejXcagya(kA9Cx24XomMKmmqsIKG1V2dmC0ckSGXCgMrywwsusIfGLlV2y1qF280zsggib((nCSazlmslfMr2Rv3guAPqa4x7bgMKpIHjbuK4bTP3MrKSp(scEVwswajbmjihldtYeCKGtDcrfRSKGaKSp(sY(WysIFCTKG3rldtceGF0ssapbhtY(WHAPy9lxEiRLICSCEcUS1ZDz1wnDRhUOPdTuU8addRPpTu3UnO0sN)dZmyMzZVyTuygzVwDBqPLQligrI(dGrK0ts6IeVibJSMwfXK4fmj71mIKfqIPlMKEj5Rsc(EFizK)gKF4GeCQtiQyLLeVGjrNWU62yzssX7xOwQ96LV21szRPvrCSRSxysIssC1S9HTJjrjjb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqcxsIeLK8IeyWgDyxDBSCgH3VWmSh6q5422XDbLKHbssKelalxETXIThWaoysEtIssW6x7bgoICSCEcUS1ZDz1wnDRhU10HwkxEGHH10NwQB3guAPO1VPBmAPWmYET62GslvxqmjymkEFijD9B6gdjQhWIiPNKKU(nDJHKgvy4sYxvl1E9Yx7APb)5mckEFqzv(SS62Gk(vjrjjb)5mIw)MUXepEEm6XdmS2QPB9GWA6qlLlpWWWA6tl1E9Yx7APb)5mIw)mGdoECO3fIeitcUjrjjVij4pNr2AAveNraJFXJd9UqKKaj4MKHbsc(ZzKTMwfXzZV8lECO3fIKeib3K8MeLK4O9CtwfGNpssGeiusAPUDBqPLA9YYMCWFo1sd(ZzU8qwlfT(zahS2QPB9uCA6qlLlpWWWA6tl1TBdkTu0630ngTuygzVwDBqPLQ4)HQis0jAKjjGNGJjbNGclymtYh1fus2hMeCckSGXmjwqb3Bdkswaj2h2oMKEscobfwWyMKgrIB3VBmysIha(ljlGKaMeRJwTu71lFTRLUUHRnIw2y8ldF9CJC5bggMeLKG4D7ckkIagqg(65sIssc(ZzeT(nDJjcdWxARMU1dxRPdTuU8addRPpTu3UnO0srRFO)bL1sHzK9A1TbLwQI)hQIiXrQKeWtWXKGtqHfmMj5J6ckj7dtcobfwWyMelOG7TbfjlGe7dBhtspjbNGclymtsJiXT73ngmjXda)LKfqsatI1rRwQ96LV21sTaSC51gRg6ZMNotIssW6x7bgoAbfwWyodZimlljkjXcagya(kAbfwWyoVpCgP2xVO4XHExisGmj4MeLKKijW3VHJfiBHrARMU1dcPPdTuU8addRPpTu3UnO0srRFt3y0sHzK9A1TbLwQUGyssx)MUXqc(EFijDzJXpsu8xpxs8cMKcqs66NbCW4Ge8pCrsbijD9B6gdjnIKVkoibtWNe)ys6IKr6x(rcgznTkIjbCKSasupGLKr(Bq(rc(hUiXdayzsGqjrIorJmjGJehw13gltccVFHK84isW1JIylIKJd9U6ckjGJKgrsxKmnn0Nvl1E9Yx7APRB4AJOLng)YWxp3ixEGHHjrjjjsY6gU2iA9Zao4ixEGHHjrjjb)5mIw)MUXepEEm6Xdmmjkj5fjb)5mYwtRI4S5x(fpo07crscKaHjrjjS10Qio2v28l)irjjb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqc3jrYWajb)5mQEDi4GB3K9Z6vBZQFdYViw38zssqbsGeUtIeLK4O9CtwfGNpssGeiusKmmqcmyJoSRUnwoJW7xyg2dDOC84qVlejjqcUMKHbsC72Gk6WU62y5mcVFHzyp0HYXUYttd9zj5njkjjrsSaGbgGVIwp3LnESdJP2QPBiLKMo0s5YdmmSM(0sD72GslfT(H(huwlfMr2Rv3guAP6cIjjD9d9pOmjymkEFir9awejEbtc8puLeDIgzsW)Wfj4uNquXkljGJK9HjbcaU2hmpsc(ZjjnIepa8xswajt3yibmNKaosWe8XqysSUkj6enYAP2Rx(Axln4pNrqX7dkBnSFzSnQbv8RsYWajb)5moUl4JHZCOkapFHCTzU4dARFC8RsYWajb)5mA9Cx24xLeLK8IKG)CgphlxGpkppU0pmJhh6DHibYKa1chdDfrcgNel3gsErIJ2ZnzvaE(ibIKmIKi5njkjj4pNXZXYf4JYZJl9dZ4xLKHbssKKG)CgphlxGpkppU0pmJFvsussIKybadmaFfphlxGpkppU0pmJh7WysYWajjsIfGLlV2iwU2hmpsEtYWajoAp3Kvb45JKeibcLejkjHTMwfXXUYEHP2QPBiPNMo0s5YdmmSM(0sD72GslfT(H(huwlfMr2Rv3guAP64WKKfqsOpMjzFyscy0scyss66NbCWKeGjjO1TJ7ckj9sYxLei4VTJnyssxK4fMKGrwtRIysc(ljJ83G8JKgvljEa4VKSascysupG1YWAP2Rx(AxlDDdxBeT(zahCKlpWWWKOKKej5(fpbhuoUDiJhCvg(ypmOly(Ime83QQmmjkj5fjb)5mIw)mGdo(vjzyGehTNBYQa88rscKaHsIK3KOKKG)CgrRFgWbhrRBhtcKjzeKOKKxKe8NZiBnTkIZiGXV4xLKHbsc(ZzKTMwfXzZV8l(vj5njkjj4pNr1RdbhC7MSFwVABw9Bq(fX6MptcKjbskUKirjjViXcagya(kA9Cx24XHExissGe9sIKHbssKeS(1EGHJwqHfmMZWmcZYsIssSaSC51gRg6ZMNotYBTvt3qcsA6qlLlpWWWA6tl1TBdkTu06h6FqzTuygzVwDBqPLQ4)HQKKU(H(huMKUiXjrXnkITKKcm(rcgznTkIXbjWGcdxsm8ssVKOEaljJ83G8JKx7JVK0isE8c2WWKeGjjCVp8rY(WKKU(nDJHetxmjGJK9HjrNOrobiusKy6Ijzcossx)q)dk)ghKadkmCjbGLp8xVmjErcgJI3hsupGLeVGjXWlj7dtIhaWYKy6Ij5Xlydts66NbCWAP2Rx(AxlnrsUFXtWbLJBhY4bxLHp2dd6cMVidb)TQkdtIssErsWFoJQxhco42nz)SE12S63G8lI1nFMeitcKuCjrYWajb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqc3jrIssw3W1grlBm(LHVEUrU8addtYBsussWFoJS10QioJag)Ihh6DHijbsuCKOKe2AAveh7kJag)irjjjssWFoJGI3huwLplRUnOIFvsussIKSUHRnIw)mGdoYLhyyysusIfamWa8v065USXJd9UqKKajkosusYlsSaGbgGVIJ7c(y4msTVErXJd9UqKKajkosggijrsSaSC51ghJ51ErYBTvt3qAeA6qlLlpWWWA6tl1TBdkT0IXNdbGslfMr2Rv3guAP6cIjrxbakejDrYi9l)ibJSMwfXK4fmjihltcgZUzoQ(7BmKORaafjtWrco1jevSYsIxWKabSl4JHjbJcvb45lKRvl1E9Yx7APVij4pNr2AAveNn)YV4XHExissGewrS9VCE7qMKHbsErI9XpOmIefibsKOKKJTp(bLZBhYKazsWnjVjzyGe7JFqzejkqYii5njkjXvZ2h2oMeLKG1V2dmCe5y58eCzRN7YQTA6gs4IMo0s5YdmmSM(0sTxV81Uw6lsc(ZzKTMwfXzZV8lECO3fIKeiHveB)lN3oKjrjjjsIfGLlV24ymV2lsggi5fjb)5moUl4JHZCOkapFHCTzU4dARFC8RsIssSaSC51ghJ51ErYBsggi5fj2h)GYisuGeirIsso2(4huoVDitcKjb3K8MKHbsSp(bLrKOajJGKHbsc(Zz065USXVkjVjrjjUA2(W2XKOKeS(1EGHJihlNNGlB9CxwTu3UnO0sFCZmhcaL2QPBiHBnDOLYLhyyyn9PLAVE5RDT0xKe8NZiBnTkIZMF5x84qVlejjqcRi2(xoVDitIsssKelalxETXXyETxKmmqYlsc(ZzCCxWhdN5qvaE(c5AZCXh0w)44xLeLKyby5YRnogZR9IK3KmmqYlsSp(bLrKOajqIeLKCS9XpOCE7qMeitcUj5njddKyF8dkJirbsgbjddKe8NZO1ZDzJFvsEtIssC1S9HTJjrjjy9R9adhrowopbx265USAPUDBqPLo)gtoeakTvt3qccRPdTuU8addRPpTuygzVwDBqPLQliMeiqagrcOiXcRL62TbLwkE)UgCzWmZMFXARMUHKItthAPC5bggwtFAPUDBqPLIw)M9XAPWmYET62GslvxqmjPRFZ(yswajQhWsskW4hjyK10QighKGtDcrfRSK84ismmcrY2Hmj7JxK4KabE((qcRi2(xMedpxsahjGYGjjJ0V8JemYAAvetsJi5RQLAVE5RDTu2AAveh7kB(LFKmmqcBnTkIJiGXVCXkAjzyGe2AAveh9cZCXkAjzyGKG)CgX731GldMz28lo(vjrjjb)5mYwtRI4S5x(f)QKmmqYlsc(Zz065USXJd9UqKazsC72GkI)89jYkIT)LZBhYKOKKG)CgTEUlB8RsYBTvt3qcxRPdTuU8addRPpTuygzVwDBqPLQliMeiWZ3hsa7dF4Betc(N2(qsJiPlssbg)ibJSMwfX4GeCQtiQyLLeWrYcir9awsgPF5hjyK10Qiwl1TBdkTu8NVpARMUHeesthAPC5bggwtFAPWmYET62Gslv)5gZ(CFTu3UnO0sVFLD72GkBA0QLAA0MlpK1sNUXSp3xB1wTu1JTGWaF10HMU1tthAPUDBqPLoUl4JHZi1(6fPLYLhyyyn9PTA6gsA6qlLlpWWWA6tlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLMKwkmJSxRUnO0s1Xdtcw)ApWWK0isq8sYcijjsW37djfGe06ljGIKpIjzVUgZlchKOhj4F4IK9Hjz2hAjbumjnIeqrYhX4GeirspjzFysqSfuWK0is8cMKrqspjjaSpK4hRLI1VC5HSwkOYFeN3RRX8QTA6EeA6qlLlpWWWA6tlfOQL6WWAPUDBqPLI1V2dmSwkw38zTu90sTxV81Uw6EDnM34Qx8J8adtIss2RRX8gx9IwaWadWxr4)5BdkTuS(LlpK1sbv(J48EDnMxTvt34IMo0s5YdmmSM(0sbQAPomSwQB3guAPy9R9adRLI1nFwlfsAP2Rx(AxlDVUgZBCHu8J8adtIss2RRX8gxifTaGbgGVIW)Z3guAPy9lxEiRLcQ8hX596AmVARMUXTMo0sD72GslneaQXDLNGlulLlpWWWA6tB10newthAPC5bggwtFAPUDBqPLI)89rl10fNTWAP6LKwQ96LV21sFrcBnTkIJMF5xUyfTKmmqcBnTkIJDLn)YpsggiHTMwfXXUYbG9HKHbsyRPvrC0lmZfROLK3APWmYET62GslDKp26OLeirce457djEbtIts66h6FqzsafjP6Ge89(qIUBOplj6pNjXlys0hqN6GeWrs663SpMeW(Wh(gXARMUvCA6qlLlpWWWA6tl1E9Yx7APViHTMwfXrZV8lxSIwsggiHTMwfXXUYMF5hjddKWwtRI4yx5aW(qYWajS10Qio6fM5Iv0sYBsusI6XyJ6fXF((qIsssKe1JXgHue)57JwQB3guAP4pFF0wnDJR10HwkxEGHH10NwQ96LV21stKK7x8eCq5yGB8YYzWm7gtEF6ckkYLhyyysggijrsSaSC51gRg6ZMNotYWajjscsLnM86huErr0630ngsuGe9izyGKejzDdxBS89Fmkh4gVSCKlpWWWAPUDBqPLIw)M9XARMUHqA6qlLlpWWWA6tl1E9Yx7AP3V4j4GYXa34LLZGz2nM8(0fuuKlpWWWKOKelalxETXQH(S5PZKOKeKkBm51pO8IIO1VPBmKOaj6PL62TbLwkA9d9pOS2QTARwkw(qnO00nKscs6L0issXPLI3VQlOiTuiqDQRQBft3ymP)jHeD8WK0HQGBjzcosWqyE6FZIHKCme83hdtcceYK4)fe6ldtI9XlOmksjpsDXKaH1)KGtqHLVLHjjTdXjjimR1vej4kswajJ03jbUX2OguKau5ZxWrYli(MKxqsrVJuYJuxmj6PN(NeCckS8Tmmjy49lEcoOCeJfdjzbKGH3V4j4GYrm2ixEGHHXqsEPNIEhPKhPUys0tp9pj4euy5BzysWW96AmVr9IySyijlGemCVUgZBC1lIXIHK8spf9osjpsDXKOhK0)KGtqHLVLHjbdVFXtWbLJySyijlGem8(fpbhuoIXg5YdmmmgsYl9u07iL8i1ftIEqs)tcobfw(wgMemCVUgZBuViglgsYcibd3RRX8gx9IySyijV0trVJuYJuxmj6bj9pj4euy5BzysWW96AmVrifXyXqswajy4EDnM34cPiglgsYl9u07iL8i1ftIEJq)tcobfw(wgMem8(fpbhuoIXIHKSasWW7x8eCq5igBKlpWWWyijVGKIEhPKPKHa1PUQUvmDJXK(Nes0XdtshQcULKj4ibdvp2ccd8fdj5yi4VpgMeeiKjX)li0xgMe7JxqzuKsEK6Ijze6FsWjOWY3YWKGH711yEJ6fXyXqswajy4EDnM34QxeJfdj5fKu07iL8i1ftcUO)jbNGclFldtcgUxxJ5ncPiglgsYcibd3RRX8gxifXyXqsEbjf9osjpsDXKGR1)KGtqHLVLHjbdVFXtWbLJySyijlGem8(fpbhuoIXg5YdmmmgsYl9u07iL8i1ftces)tcobfw(wgMem8(fpbhuoIXIHKSasWW7x8eCq5igBKlpWWWyijV0trVJuYuYqG6uxv3kMUXys)tcj64HjPdvb3sYeCKGHoGXqsogc(7JHjbbczs8)cc9LHjX(4fugfPKhPUysgH(NeCckS8Tmmjy49lEcoOCeJfdjzbKGH3V4j4GYrm2ixEGHHXqsEPNIEhPKhPUysGW6FsWjOWY3YWKK2H4KeeM16kIeCfUIKfqYi9DscbWFZhrcqLpFbhjVWvVj5LEk6DKsEK6IjbxR)jbNGclFldtsAhItsqywRRisWvKSasgPVtcCJTrnOibOYNVGJKxq8njV0trVJuYJuxmj6PN(NeCckS8TmmjPDiojbHzTUIibxrYcizK(ojWn2g1GIeGkF(cosEbX3K8spf9osjpsDXKOhes)tcobfw(wgMK0oeNKGWSwxrKGRizbKmsFNe4gBJAqrcqLpFbhjVG4BsEPNIEhPKhPUysGKE6FsWjOWY3YWKK2H4KeeM16kIeCfjlGKr67Ka3yBudksaQ85l4i5feFtYl9u07iL8i1ftcKGW6FsWjOWY3YWKK2H4KeeM16kIeCfjlGKr67Ka3yBudksaQ85l4i5feFtYliPO3rkzkziqDQRQBft3ymP)jHeD8WK0HQGBjzcosWWPBm7Z9Xqsogc(7JHjbbczs8)cc9LHjX(4fugfPKhPUysGK(NeCckS8TmmjPDiojbHzTUIibxrYcizK(ojWn2g1GIeGkF(cosEbX3K8spf9osjtjdbQtDvDRy6gJj9pjKOJhMKoufCljtWrcgIwmKKJHG)(yysqGqMe)VGqFzysSpEbLrrk5rQlMeCr)tcobfw(wgMem8(fpbhuoIXIHKSasWW7x8eCq5igBKlpWWWyijV0trVJuYJuxmj6PN(NeCckS8TmmjPDiojbHzTUIibxHRizbKmsFNKqa838rKau5ZxWrYlC1BsEPNIEhPKhPUys0ds6FsWjOWY3YWKK2H4KeeM16kIeCfUIKfqYi9DscbWFZhrcqLpFbhjVWvVj5LEk6DKsEK6IjbsjP)jbNGclFldtsAhItsqywRRisWvKSasgPVtcCJTrnOibOYNVGJKxq8njV0trVJuYuYqG6uxv3kMUXys)tcj64HjPdvb3sYeCKGHbaFXqsogc(7JHjbbczs8)cc9LHjX(4fugfPKhPUys0dcP)jbNGclFldtsAhItsqywRRisWvKSasgPVtcCJTrnOibOYNVGJKxq8njVgHIEhPKhPUysGus6FsWjOWY3YWKK2H4KeeM16kIeCfjlGKr67Ka3yBudksaQ85l4i5feFtYl9u07iLmLSIfQcULHjbctIB3guKyA0IIuYAPiv2QPB9scsAPQhy2gwlfdWas0NB8YYKO4VFdtjJbyaj6k(zFirVKWbjqkjiPhLmLmgGbKGZhVGYi9pLmgGbKORjrNWWmmjPaJFKOp2dJuYyagqIUMeC(4fugMK1pO8M7jjwhXiswajwmTgoV(bLxuKsgdWas01KORYHaSmmj)QylJq(Hjjy9R9adJi5vh5ioir9ySz06h6Fqzs01jqI6XyJO1p0)GYVJuYyagqIUMeDIf0WKOES1rBxqjbc889HKEssVyiIK9Hjb)bkOKGrwtRI4iLmgGbKORjrxXhZKGtqHfmMjzFyssv7RxejojMExdtsi4ysMgwrDGHj5vpjbtWNKhhUWWLKNEjPxsqD43SEXGpYGjj479He9HXqN6GKrjbNSHrB7gs0PPHwHCT4GKEXqysqJB13rkzmadirxtIUIpMjjeGwsWWzd9zZhh6DHWqsqwU8RbisCvvdMKSascaiejZg6ZIibugmJuYuYUDBqHIQhBbHb(QW4UGpgoJu7RxeLmgqIoEysW6x7bgMKgrcIxswajjrc(EFiPaKGwFjbuK8rmj711yEr4Ge9ib)dxKSpmjZ(qljGIjPrKaks(ighKajs6jj7dtcITGcMKgrIxWKmcs6jjbG9He)ykz3UnOqr1JTGWaFhvbiI1V2dmmokpKvau5pIZ711yEXbw38zfsIs2TBdkuu9ylimW3rvaIy9R9adJJYdzfav(J48EDnMxCauvWHHXbw38zf0dh9uH96AmVr9IFKhyyL711yEJ6fTaGbgGVIW)Z3guuYUDBqHIQhBbHb(oQcqeRFThyyCuEiRaOYFeN3RRX8IdGQcommoW6MpRaKWrpvyVUgZBesXpYdmSY96AmVrifTaGbgGVIW)Z3guuYUDBqHIQhBbHb(oQcqmeaQXDLNGlKsgdizKp26OLeirce457djEbtIts66h6FqzsafjP6Ge89(qIUBOplj6pNjXlys0hqN6GeWrs663SpMeW(Wh(gXuYUDBqHIQhBbHb(oQcqe)57domDXzlSc6Leo6PcVyRPvrC08l)YfRODyGTMwfXXUYMF53WaBnTkIJDLda7ZWaBnTkIJEHzUyfTVPKD72Gcfvp2ccd8DufGi(Z3hC0tfEXwtRI4O5x(Llwr7WaBnTkIJDLn)YVHb2AAveh7kha2NHb2AAveh9cZCXkAFRu9ySr9I4pFFuMO6XyJqkI)89Hs2TBdkuu9ylimW3rvaIO1VzFmo6PcjE)INGdkhdCJxwodMz3yY7txqrddjAby5YRnwn0NnpDEyirKkBm51pO8IIO1VPBmkO3WqIRB4AJLV)Jr5a34LLJC5bggMs2TBdkuu9ylimW3rvaIO1p0)GY4ONkC)INGdkhdCJxwodMz3yY7txqrkTaSC51gRg6ZMNoRePYgtE9dkVOiA9B6gJc6rjtjJbyajyKIy7FzysyS8HjjBhYKSpmjUDbhjnIehR3gpWWrkz3UnOqkGag)YbShsjJbKKYlIeDcWisafjJyusW37d4VKaF9CjXlysW37djPRFgWbtIxWKaPrjbSp8HVrmLSB3guifW6x7bgghLhYk0OSdyCG1nFwbKkBm51pO8IIO1VPBmjONYxjUUHRnIw)mGdoYLhyy4HH1nCTr0YgJFz4RNBKlpWWWVhgqQSXKx)GYlkIw)MUXKaKOKXass5frI1WowMe8pCrs663SpMeRxK80ljqAusw)GYlIe8pT9HKgrYXggRxljtWrY(WKGrwtRIyswajbmjQhp57yys8cMe8pT9HKzBm8rYciX6OLs2TBdk0OkarS(1EGHXr5HScnkBnSJLXbw38zfqQSXKx)GYlkIw)M9XjOhLmgqIUGys0hFi(g3fusW37dj4uNquXkljGJeFU8rcobfwWyMKUibN6eIkwzPKD72GcnQcqmGpeFJ7cko6PcVs0cWYLxBSAOpBE68WqIwaWadWxrlOWcgZ59HZi1(6ff)QVvg8NZO1ZDzJhh6DHsqpCtjJbKmYGLe89(qItco1jevSYsY(4ljnQWWLeNKr(Bq(rI6bSKaosW)Wfj7dtYSH(SK0is8aWFjzbKWfmLSB3guOrvaIQGTbfo6Pcb)5mA9Cx24XHExOe0d3ddbaes5SH(S5Jd9Uqqgs4MsgdibNUX(n(YisW)W7dFK8rDbLeCckSGXmjfapj4BJHe3ya4jbtWNKfqcABJHeRJws2hMeKhYK4HGFTKaMKGtqHfmMhfN6eIkwzjX6Ofrj72TbfAufGiw)ApWW4O8qwblOWcgZzygHzzXbw38zfSCBE9QRLpvGXxgopBOpB(4qVlKUwpCRRTaGbgGVIwp3LnECO3f6nUspCDsVvWYT51RUw(ubgFz48SH(S5Jd9Uq6A9WTUwpiLKU2cagya(kAbfwWyoVpCgP2xVO4XHExO34k9W1j9EyWcagya(kA9Cx24XHExOe6A5tfy8LHZZg6ZMpo07cnmybadmaFfTGclymN3hoJu7Rxu84qVlucDT8Pcm(YW5zd9zZhh6DH016L0WqIwawU8AJvd9zZtNPKXas0fedtYcibMnoMKSpmjFKdLjbmjbN6eIkwzjb)dxK8rDbLeyWpWWKaks(iMs2TBdk0OkarS(1EGHXr5HScw4SfuW92GchyDZNv4vIme83QQmCKdvX8y3KbhC5LLhgSaGbgGVICOkMh7Mm4GlVSC84qVleK1dcNKYeTaGbgGVICOkMh7Mm4GlVSC8yhgZ3ddwawU8AJJX8AVOKXas0fetcgfQI5XUHemghC5LLjbsjHylIKaEcoMeNeCQtiQyLLKpIJuYUDBqHgvbi(rCUxoehLhYkWHQyESBYGdU8YY4ONkybadmaFfTEUlB84qVleKHuskTaGbgGVIwqHfmMZ7dNrQ91lkECO3fcYqkPHHaacPC2qF28XHExiipcfhLmgqIUGyssbFJH3UGsIU6patsGWi2IijGNGJjXjbN6eIkwzj5J4iLSB3guOrvaIFeN7LdXr5HSciW3y4D7cA((byIJEQGfamWa8v065USXJd9UqqgcRmrS(1EGHJwqHfmMZWmcZYomybadmaFfTGclymN3hoJu7Rxu84qVleKHWkX6x7bgoAbfwWyodZiml7WqaaHuoBOpB(4qVleKHeUPKD72GcnQcq8J4CVCiokpKvOlK9(Rhy4me871(dZWm22Y4ONke8NZO1ZDzJhh6DHsqpCtjJbKOJNgrsJiXj589HpsyJhaoFzsW7ysYcij0hZK4gdjGIKpIjbT(sYEDnMxejlGKaMetxmmjFvsW37dj4uNquXkljEbtcobfwWyMeVGj5Jys2hMeivWKGmGLeqrIfMKEssayFizVUgZlIe)ysafjFetcA9LK96AmVikz3UnOqJQae3RRX8Qho6PcVW6x7bgocQ8hX596AmVkO3Waw)ApWWrqL)ioVxxJ5vHr8w5RG)CgTEUlB8RomybadmaFfTEUlB84qVl0OqkH96AmVr9IwaWadWxr4)5BdkLVs0cWYLxBSAOpBE68WqIy9R9adhTGclymNHzeML9TYeTaSC51ghJ51Enmyby5YRnwn0NnpDwjw)ApWWrlOWcgZzygHzzvAbadmaFfTGclymN3hoJu7Rxu8RQmrlayGb4RO1ZDzJFvLVEf8NZiBnTkIZMF5x84qVluc6L0WqWFoJS10QioJag)Ihh6DHsqVKERmX7x8eCq5yGB8YYzWm7gtEF6ckAy4vWFoJbUXllNbZSBm59PlOOC57)4iAD7yfW9WqWFoJbUXllNbZSBm59PlOOSFwV4iAD7yfW973ddb)5moUl4JHZCOkapFHCTzU4dARFC8R(EyiaGqkNn0NnFCO3fcYqkPHbS(1EGHJGk)rCEVUgZRcjrj72TbfAufG4EDnMxiHJEQaw)ApWWrqL)ioVxxJ5vHrOmX96AmVr9Ih7WyMTaGbgGVggEf8NZO1ZDzJF1HblayGb4RO1ZDzJhh6DHgfsjSxxJ5ncPOfamWa8ve(F(2Gs5ReTaSC51gRg6ZMNopmKiw)ApWWrlOWcgZzygHzzFRmrlalxETXXyETxddwawU8AJvd9zZtNvI1V2dmC0ckSGXCgMrywwLwaWadWxrlOWcgZ59HZi1(6ff)Qkt0cagya(kA9Cx24xv5Rxb)5mYwtRI4S5x(fpo07cLGEjnme8NZiBnTkIZiGXV4XHExOe0lP3kt8(fpbhuog4gVSCgmZUXK3NUGIggEf8NZyGB8YYzWm7gtEF6ckkx((poIw3owbCpme8NZyGB8YYzWm7gtEF6ckk7N1loIw3owbC)(97HHG)Cgh3f8XWzoufGNVqU2mx8bT1po(vhgcaiKYzd9zZhh6DHGmKsAyaRFThy4iOYFeN3RRX8QqsuYyaj6cIrK4gdjG9HpsafjFetsVCiIeqrIfMs2TBdk0OkaXpIZ9YHiC0tfc(Zz065USXV6WGfGLlV2y1qF280zLy9R9adhTGclymNHzeMLvPfamWa8v0ckSGXCEF4msTVErXVQYeTaGbgGVIwp3Ln(vv(6vWFoJS10QioB(LFXJd9UqjOxsddb)5mYwtRI4mcy8lECO3fkb9s6TYeVFXtWbLJbUXllNbZSBm59PlOOHH7x8eCq5yGB8YYzWm7gtEF6cks5RG)CgdCJxwodMz3yY7txqr5Y3)Xr062XjmIHHG)CgdCJxwodMz3yY7txqrz)SEXr062XjmI3Vhgc(ZzCCxWhdN5qvaE(c5AZCXh0w)44xDyiaGqkNn0NnFCO3fcYqkjkzmGefpBByMe3UnOiX0OLKahXWKaksq9(9Tbfenm0grj72TbfAufG49RSB3guztJwCuEiRGdyCG2RTRc6HJEQaw)ApWWXgLDatj72TbfAufG49RSB3guztJwCuEiRqaWxCG2RTRc6HJEQW9lEcoOCmWnEz5myMDJjVpDbffzi4Vvvzykz3UnOqJQaeVFLD72GkBA0IJYdzfqlLmLmgqcoDJ9B8LrKG)H3h(izFysu8h7HwFTp8rsWFojbFBmKmDJHeWCsc(EF6IK9HjPyfTKyD0sj72Tbfk6awbS(1EGHXr5HScWh7Hz8TXKNUXKbZjoW6MpRWRG)Cg3oKXdUkdFShg0fmFXJd9UqqgQfog6kA0KI6nme8NZ42HmEWvz4J9WGUG5lECO3fcYUDBqfrRFZ(4iRi2(xoVDipAsr9u(ITMwfXXUYMF53WaBnTkIJiGXVCXkAhgyRPvrC0lmZfRO99BLb)5mUDiJhCvg(ypmOly(IFvL3V4j4GYXTdz8GRYWh7HbDbZxKHG)wvLHPKXasWPBSFJVmIe8p8(WhjPRFO)bLjPrKGhC7djwhTDbLeaw(ijD9B2htsxKms)YpsWiRPvrmLSB3guOOd4rvaIy9R9adJJYdzfAOf44mA9d9pOmoW6MpRqIS10Qio2vgbm(P8fsLnM86huErr063SpobCRCDdxBeb(MmyM3hopbhJ2ixEGHHhgqQSXKx)GYlkIw)M9XjO4EtjJbKOliMeCckSGXmj4F4IeFjXWiej7JxKG7KirNOrMeVGjX0ftYxLe89(qco1jevSYsj72Tbfk6aEufGOfuybJ58(WzKAF9IWrpv4fw)ApWWrlOWcgZzygHzzvMOfamWa8v065USXJDymhgc(Zz065USXV6BLVC0EUjRcWZhKXDsddy9R9adhBOf44mA9d9pO8BLVc(ZzKTMwfXzZV8lECO3fkbi8WqWFoJS10QioJag)Ihh6DHsac)w5ReVFXtWbLJbUXllNbZSBm59PlOOHHG)CgdCJxwodMz3yY7txqr5Y3)Xr062XjmIHHG)CgdCJxwodMz3yY7txqrz)SEXr062XjmI3ddbaes5SH(S5Jd9UqqwVKOKXas0fetI(74s)WKe89(qco1jevSYsj72Tbfk6aEufG45y5c8r55XL(Hjo6Pcb)5mA9Cx24XHExOe0d3uYyaj6cIjj9xZ(ys6IevVG5W2scOiXlm3NUGsY(4ljMglJirpCbXwejEbtIHrisW37djHGJjz9dkVis8cMeFjzFys4cMeWKeNKuGXpsWiRPvrmj(sIE4cji2IibCKyyeIKJd9U6ckjoIKfqsbwsECSDbLKfqYXZJrpKa)VUGsYi9l)ibJSMwfXuYUDBqHIoGhvbiI(1SpghwmTgoV(bLxKc6HJEQWRJNhJE8adpme8NZiBnTkIZiGXV4XHExiipcLS10Qio2vgbm(P84qVleK1dxuUUHRnIaFtgmZ7dNNGJrBKlpWWWVvU(bL342HCEbz4MtqpCrxJuzJjV(bLx0Ohh6DHu(ITMwfXXUYEH5WWXHExiid1chdDf9MsgdibciZQK8vjjD9B6gdj(sIBmKSDiJi5xggHi5J6ckjJeMw)CejEbtsVK0is8aWFjzbKOEaljGJedVKSpmjiv22UHe3UnOiX0ftsaBa4j5XlydtII)ypmOly(ibuKajsw)GYlIs2TBdku0b8Okar0630ngC0tfEf8NZiA9B6gt845XOhpWWkFHuzJjV(bLxueT(nDJbYJyyiX7x8eCq542HmEWvz4J9WGUG5lYqWFRQYWVhgw3W1grGVjdM59HZtWXOnYLhyyyLb)5mYwtRI4mcy8lECO3fcYJqjBnTkIJDLraJFkd(ZzeT(nDJjECO3fcYkoLiv2yYRFq5ffrRFt3ysqbC5TYxjE)INGdkhnyA9Zr5PH5TlOzOMoufXrgc(BvvgEyy7qgxHRWfCNqWFoJO1VPBmXJd9UqJcP3kx)GYBC7qoVGmCZjGBkzmGeiWEFirXFShg0fmFK8rmjPRFt3yizbKmMzvs(QKSpmjb)5KKamjXniajFuxqjjD9B6gdjGIeCtcITGcgrc4iXWiejhh6D1fukz3UnOqrhWJQaerRFt3yWrpv4(fpbhuoUDiJhCvg(ypmOly(Ime83QQmSsKkBm51pO8IIO1VPBmjOWiu(kXG)Cg3oKXdUkdFShg0fmFXVQYG)CgrRFt3yIhppg94bgEy4fw)ApWWr4J9Wm(2yYt3yYG5u5RG)CgrRFt3yIhh6DHG8iggqQSXKx)GYlkIw)MUXKaKuUUHRnIw2y8ldF9CJC5bggwzWFoJO1VPBmXJd9Uqqg3VF)MsgdibNUX(n(YisW)W7dFK4KKU(H(huMKpIjbFBmKy9pIjjD9B6gdjlGKPBmKaMtCqIxWK8rmjPRFO)bLjzbKmMzvsu8h7HbDbZhjO1TJj5Rsj72Tbfk6aEufGiw)ApWW4O8qwb0630nMmEqT5PBmzWCIdSU5Zk4O9CtwfGNVeW1jPRFPxsy8G)Cg3oKXdUkdFShg0fmFr062XV11Vc(ZzeT(nDJjECO3fcJpcCfsLnM8JJw(TU(fmyJZ)HzgmZS5xC84qVlegh3Vvg8NZiA9B6gt8RsjJbKOliMK01p0)GYKGV3hsu8h7HbDbZhjlGKXmRsYxLK9Hjj4pNKGV3hWFjXaqDbLK01VPBmK8v3oKjXlys(iMK01p0)GYKaksWLrjrFaDQdsqRBhJi5xBBibxiz9dkVikz3UnOqrhWJQaerRFO)bLXrpvaRFThy4i8XEygFBm5PBmzWCQeRFThy4iA9B6gtgpO280nMmyovMiw)ApWWXgAbooJw)q)dkpm8k4pNXa34LLZGz2nM8(0fuuU89FCeTUDCcJyyi4pNXa34LLZGz2nM8(0fuu2pRxCeTUDCcJ4TsKkBm51pO8IIO1VPBmqgxuI1V2dmCeT(nDJjJhuBE6gtgmNuYyaj6cIjbH3Vqsqas2hFjbtWNeO8ssORis(QBhYKeGjjFuxqjPxsCejgFzsCejQaeQdmmjGIedJqKSpErYiibTUDmIeWrceGF0sc(hUizeJscAD7yejSIu7JPKD72GcfDapQcq0HD1TXYzeE)cXHftRHZRFq5fPGE4ONkK422XDbvzIUDBqfDyxDBSCgH3VWmSh6q5yx5PPH(SddWGn6WU62y5mcVFHzyp0HYr062XqEekHbB0HD1TXYzeE)cZWEOdLJhh6DHG8iOKXas0v55XOhs0vaGA2htspjbN6eIkwzjPrKCSdJjoizF4JjXpMedJqKSpErcUjz9dkVis6IKr6x(rcgznTkIjbFVpKKcw9hoiXWiej7JxKOxsKa2h(W3iMKUiXlmjbJSMwfXKaos(QKSasWnjRFq5frsapbhtItYi9l)ibJSMwfXrsu8GcdxsoEEm6He4)1fusGa2f8XWKGrHQa88fY1sYVmmcrsxKKcm(rcgznTkIPKD72GcfDapQcqmeaQzFmoSyAnCE9dkVif0dh9uHJNhJE8adRC9dkVXTd58cYWnNWRx6HlJ(cPYgtE9dkVOiA9B2hJXHegp4pNr2AAveNn)YV4x997rpo07c9gx9sVrx3W1gx8DLdbGcf5Ydmm8BLVSaGbgGVIwp3LnESdJPYeHVFdhlq2cJu(cRFThy4OfuybJ5mmJWSSddwaWadWxrlOWcgZ59HZi1(6ffp2HXCyirlalxETXQH(S5PZVhgqQSXKx)GYlkIw)M9Xq(1liSU(vWFoJS10QioB(LFXVkghsVFJXFP3ORB4AJl(UYHaqHIC5bgg(9BLjYwtRI4icy8lxSI2HHxS10Qio2vgbm(nm8ITMwfXXUYbG9zyGTMwfXXUYMF53BLjUUHRnIaFtgmZ7dNNGJrBKlpWWWddb)5mQEDi4GB3K9Z6vBZQFdYViw385euas4oP3kFHuzJjV(bLxueT(n7JHSEjHXFP3ORB4AJl(UYHaqHIC5bgg(9BLoAp3Kvb45lbCNKUo4pNr0630nM4XHEximoe(TYxjg8NZ44UGpgoZHQa88fY1M5IpOT(XXV6WaBnTkIJDLraJFddjAby5YRnogZR96nLmgqIUGys0FaDtcOiXctc(EFa)LeRRQ2fukz3UnOqrhWJQaeNGZYzWmx((pgh9ubxnBFy7ykzmGeDbXKGtDcrfRSKaksSWK8ldJqK4fmjMUys6LKVkj479HeCckSGXmLSB3guOOd4rvaIw2WOTDt2nn0kKRfh9uHeHVFdhlq2cJuI1V2dmC0cNTGcU3gukFf8NZiA9B6gt8Rom4O9CtwfGNVeWDsVv(kXG)CgradABlh)Qktm4pNrRN7Yg)QkFLOfGLlV2y1qF2805HblayGb4ROfuybJ58(WzKAF9IIFvLoAp3Kvb45dY4oP3kx)GYBC7qoVGmCZjOhUh1ck4FVr1JTnIZUPHwHCTXTd5mw385HHaacPSRLpvGXxgopBOpB(4qVleKHusJAbf8V3O6X2gXz30qRqU242HCgRB(8Bkz3UnOqrhWJQae7Y6x5BdkC0tfse((nCSazlmsjw)ApWWrlC2ck4EBqP8vWFoJO1VPBmXV6WGJ2ZnzvaE(sa3j9w5Red(ZzebmOTTC8RQmXG)CgTEUlB8RQ8vIwawU8AJvd9zZtNhgSaGbgGVIwqHfmMZ7dNrQ91lk(vv6O9CtwfGNpiJ7KERC9dkVXTd58cYWnNaKsAulOG)9gvp22io7MgAfY1g3oKZyDZNhgcaiKYUw(ubgFz48SH(S5Jd9UqqEejnQfuW)EJQhBBeNDtdTc5AJBhYzSU5ZVPKXas0fetcgfQcWZhj6duWKaksSWKGV3hssx)MUXqYxLeVGjb5yzsMGJKr(Bq(rIxWKGtDcrfRSuYUDBqHIoGhvbiYHQa88Ldafmo6PcbaeszxlFQaJVmCE2qF28XHExiiRhUhgEf8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKWDsddb)5mQEDi4GB3K9Z6vBZQFdYViw385euas4oP3kd(ZzeT(nDJj(vv(Ycagya(kA9Cx24XHExOeWDsddW3VHJfiBHrVPKXas0v55XOhsMg)ysafjFvswajJGK1pO8IibFVpG)sco1jevSYssa3fus8aWFjzbKWksTpMeVGjPaljaS8zDv1UGsj72Tbfk6aEufGiAzJXV804hJdlMwdNx)GYlsb9Wrpv445XOhpWWk3oKZlid3Cc6HBLiv2yYRFq5ffrRFZ(yiJlkD1S9HTJv(k4pNrRN7Ygpo07cLGEjnmKyWFoJwp3Ln(vFtjJbKOliMe9haJiPNK0fQHzs8IemYAAvetIxWKy6IjPxs(QKGV3hsCsg5Vb5hjQhWsIxWKOtyxDBSmjP49lKs2TBdku0b8OkaX5)WmdMz28lgh9ub2AAveh7k7fMkD1S9HTJvg8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKWDskFbd2Od7QBJLZi8(fMH9qhkh32oUlOddjAby5YRnwS9agWbpmGuzJjV(bLxucq6nLmgqIUGysCssx)MUXqcgJI3hsupGLKFzyeIK01VPBmK0isCZXomMK8vjbCKGj4tIFmjEa4VKSasay5Z6QKOt0itj72Tbfk6aEufGiA9B6gdo6Pcb)5mckEFqzv(SS62Gk(vv(k4pNr0630nM4XZJrpEGHhgC0EUjRcWZxcqOKEtjJbKO4)HQKOt0itsapbhtcobfwWyMe89(qs6630ngs8cMK9Hlssx)q)dktj72Tbfk6aEufGiA9B6gdo6PcwawU8AJvd9zZtNv(cRFThy4OfuybJ5mmJWSSddwaWadWxrRN7Yg)Qddb)5mA9Cx24x9TslayGb4ROfuybJ58(WzKAF9IIhh6DHGmulCm0veg3YT5LJ2ZnzvaE(Wv4oP3kd(ZzeT(nDJjECO3fcY4IYeHVFdhlq2cJOKD72GcfDapQcqeT(H(hugh9ublalxETXQH(S5PZkFH1V2dmC0ckSGXCgMryw2HblayGb4RO1ZDzJF1HHG)CgTEUlB8R(wPfamWa8v0ckSGXCEF4msTVErXJd9UqqgcRm4pNr0630nM4xvjBnTkIJDL9ctLjI1V2dmCSHwGJZO1p0)GYkte((nCSazlmIsgdirxqmjPRFO)bLjbFVpK4fjymkEFir9awsahj9KembFmeMeaw(SUkj6enYKGV3hsWe8pskwrljwhTrs0Pbbib(hQIirNOrMeFjzFys4cMeWKK9HjbcaU2hmpsc(Zjj9KK01VPBmKGh8nWfgUKmDJHeWCscOibxibCKyyeIK1pO8IOKD72GcfDapQcqeT(H(hugh9uHG)CgbfVpOS1W(LX2OguXV6WWRerRFZ(4ORMTpSDSYeX6x7bgo2qlWXz06h6Fq5HHxb)5mA9Cx24XHExiiJBLb)5mA9Cx24xDy4vWFoJNJLlWhLNhx6hMXJd9UqqgQfog6kcJB528Yr75MSkapF4QrK0BLb)5mEowUaFuEECPFyg)QVFReRFThy4iA9B6gtgpO280nMmyovIuzJjV(bLxueT(nDJbYJ4TYxjE)INGdkh3oKXdUkdFShg0fmFrgc(BvvgEyaPYgtE9dkVOiA9B6gdKhXBkzmGeDbXKORaafIKUijfy8JemYAAvetIxWKGCSmj6VVXqIUcauKmbhj4uNquXklLSB3guOOd4rvaIfJphcafo6PcVc(ZzKTMwfXzeW4x84qVlucSIy7F582H8WWl7JFqzKcqs5X2h)GY5TdziJ73dd2h)GYifgXBLUA2(W2XuYUDBqHIoGhvbi(4MzoeakC0tfEf8NZiBnTkIZiGXV4XHExOeyfX2)Y5Td5HHx2h)GYifGKYJTp(bLZBhYqg3VhgSp(bLrkmI3kD1S9HTJPKD72GcfDapQcqC(nMCiau4ONk8k4pNr2AAveNraJFXJd9UqjWkIT)LZBhYkFzbadmaFfTEUlB84qVluc4oPHblayGb4ROfuybJ58(WzKAF9IIhh6DHsa3j9Ey4L9XpOmsbiP8y7JFq582HmKX97Hb7JFqzKcJ4TsxnBFy7ykzmGeDbXKabcWisafj4uXtj72Tbfk6aEufGiE)UgCzWmZMFXuYyaj40n2VXxgrc(hEF4JKfqYhXKKU(n7JjPlssbg)ib)tBFiPrK4lj4MK1pO8IgvpsMGJeglFyscKscxrsOJw(WKeWrcUqs66h6FqzsWOqvaE(c5AjbTUDmIs2TBdku0b8OkarS(1EGHXr5HScO1VzFCURmcy8dhyDZNvaPYgtE9dkVOiA9B2hNaUm60aa3RqhT8HzgRB(mgxVKscxbPKEp60aa3RG)CgrRFO)bLZCOkapFHCTzeW4xeTUDmUcxEtjJbKOliMeiWZ3hs6IKuGXpsWiRPvrmjGJKEssbijD9B2htc(2yiz2ljDTasWPoHOIvws8cZqWXuYUDBqHIoGhvbiI)89bh9uHxS10QioA(LF5Iv0omWwtRI4OxyMlwrRsS(1EGHJnkBnSJLFR816huEJBhY5fKHBobCzyGTMwfXrZV8l3vgsddZg6ZMpo07cbz9s69WqWFoJS10QioJag)Ihh6DHGSB3gur063SpoYkIT)LZBhYkd(ZzKTMwfXzeW4x8RomWwtRI4yxzeW4NYeX6x7bgoIw)M9X5UYiGXVHHG)CgTEUlB84qVleKD72GkIw)M9XrwrS9VCE7qwzIy9R9adhBu2AyhlRm4pNrRN7Ygpo07cbzwrS9VCE7qwzWFoJwp3Ln(vhgc(Zz8CSCb(O884s)Wm(vvIuzJj)4OLtiPiew5lKkBm51pO8IGScJyyiX1nCTre4BYGzEF48eCmAJC5bgg(9WqIy9R9adhBu2AyhlRm4pNrRN7Ygpo07cLaRi2(xoVDitjJbKOliMK01VzFmj9KKUizK(LFKGrwtRIyCqsxKKcm(rcgznTkIjbuKGlJsY6huErKaoswajQhWsskW4hjyK10QiMs2TBdku0b8Okar063SpMsgdir)5gZ(CFkz3UnOqrhWJQaeVFLD72GkBA0IJYdzfMUXSp3NsMsgdir)DCPFysc(EFibN6eIkwzPKD72Gcfda(QW5y5c8r55XL(Hjo6Pcb)5mA9Cx24XHExOe0d3uYyaj48HTJrK0ts2hMe9b0PoiXE9ssWFojPrKuGLKVkjtWrIXx(i5Jykz3UnOqXaGVJQaeX6x7bgghLhYkyVElW(vXbw38zfsm4pNXa34LLZGz2nM8(0fuuU89FC8RQmXG)CgdCJxwodMz3yY7txqrz)SEXXVkLmgqIUGys0jSRUnwMKu8(fsc(hUiXxsmmcrY(4fj4cj6dOtDqcAD7yejEbtYci545XOhsCsGScqIe062XK4ism(YK4isubiuhyysahjBhYK0ljiaj9sIFxJLrKab4hTK4ZLpsCsgXOKGw3oMewrQ9Xikz3UnOqXaGVJQaeDyxDBSCgH3VqCyX0A486huErkOho6Pcb)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJHmUOm4pNXa34LLZGz2nM8(0fuu2pRxCeTUDmKXfLVsegSrh2v3glNr49lmd7HouoUTDCxqvMOB3gurh2v3glNr49lmd7Houo2vEAAOpRYxjcd2Od7QBJLZi8(fMFy3e32oUlOddWGn6WU62y5mcVFH5h2nXJd9UqjmI3ddWGn6WU62y5mcVFHzyp0HYr062XqEekHbB0HD1TXYzeE)cZWEOdLJhh6DHGmUvcd2Od7QBJLZi8(fMH9qhkh32oUlOVPKXas0fetcobfwWyMe89(qco1jevSYsc(hUirfGqDGHjXlysa7dF4Betc(EFiXjrFaDQdsc(Zjj4F4IeygHzz7ckLSB3guOyaW3rvaIwqHfmMZ7dNrQ91lch9uHxy9R9adhTGclymNHzeMLvzIwaWadWxrRN7Ygp2HXCyi4pNrRN7Yg)QVv(k4pNXa34LLZGz2nM8(0fuuU89FCeTUDSc4Eyi4pNXa34LLZGz2nM8(0fuu2pRxCeTUDSc4(9WqaaHuoBOpB(4qVleK1ljkzmGe9haJiXrKSpmjZ(qljqTWK0fj7dtItI(a6uhKGVlyaEsahj479HK9HjbciMx7fjb)5KeWrc(EFiXjbxpkITKOtyxDBSmjP49lKeVGjbV3ljtWrco1jevSYsspjPxsWdQLKaMKVkjouVlsc4j4ys2hMelmjnIKzxn6HHPKD72Gcfda(oQcqC(pmZGzMn)IXrpv41RG)CgdCJxwodMz3yY7txqr5Y3)Xr062XjGlddb)5mg4gVSCgmZUXK3NUGIY(z9IJO1TJtaxER8f89B4ybYwy0WGfamWa8v065USXJd9UqjG7KggEzby5YRnwn0NnpDwPfamWa8v0ckSGXCEF4msTVErXJd9UqjG7KE)(9WWlyWgDyxDBSCgH3VWmSh6q54XHExOeW1kTaGbgGVIwp3LnECO3fkb9ssPfGLlV2yX2dyah87HHaacPSRLpvGXxgopBOpB(4qVleKX1ddVSaSC51ghJ51EPm4pNXXDbFmCMdvb45lKRn(vFtjJbKGtVSSHK01pd4GjbFVpK4KumEs0hqN6GKG)CsIxWKGtDcrfRSK0Ocdxs8aWFjzbKeWK8rmmLSB3guOyaW3rvaIwVSSjh8NtCuEiRaA9ZaoyC0tfEf8NZyGB8YYzWm7gtEF6ckkx((poECO3fkbCjI7HHG)CgdCJxwodMz3yY7txqrz)SEXXJd9UqjGlrC)w5llayGb4RO1ZDzJhh6DHsqXnm8Ycagya(kYHQa88LdafC84qVluckoLjg8NZ44UGpgoZHQa88fY1M5IpOT(XXVQslalxETXXyETxVFR0r75MSkapFjOWisIsgdirX)dvjjD9d9pOmIe89(qItI(a6uhKe8Ntsc(ljfyjb)dxKOcaMUGsYeCKGtDcrfRSKaosGa2f8XWKKQ2xVikz3UnOqXaGVJQaerRFt3yWrpvyDdxBeTSX4xg(65g5YdmmSseVBxqrreWaYWxpxLb)5mIw)MUXeHb4lkzmGef)puLK01p0)GYisW37dj7dtsaWxsc(Zjjb)LKcSKG)HlsubatxqjzcosSojGJeoufGNpscafmLSB3guOyaW3rvaIO1p0)GY4ONkKiw)ApWWr71Bb2VQYxwawU8AJvd9zZtNhgSaGbgGVIwp3LnECO3fkbf3WqIy9R9adhTWzlOG7TbLYeTaSC51ghJ51Enm8Ycagya(kYHQa88LdafC84qVluckoLjg8NZ44UGpgoZHQa88fY1M5IpOT(XXVQslalxETXXyETxVFR8vIWGno)hMzWmZMFXXTTJ7c6WqIwaWadWxrRN7Ygp2HXCyirlayGb4ROfuybJ58(WzKAF9IIh7Wy(MsgdirX)dvjjD9d9pOmIKaEcoMeCckSGXmLSB3guOyaW3rvaIO1p0)GY4ONk8Ycagya(kAbfwWyoVpCgP2xVO4XHExiiJBLjcF)gowGSfgP8fw)ApWWrlOWcgZzygHzzhgSaGbgGVIwp3LnECO3fcY4(TsS(1EGHJw4SfuW92G6TYeHbBC(pmZGzMn)IJBBh3fuLwawU8AJvd9zZtNvMi89B4ybYwyKs2AAveh7k7fMuYyajkEqHHljWGLe4)1fus2hMeUGjbmjrx1XYf4Jir)DCPFyIdsG)xxqjzCxWhdtchQcWZxixljGJKUizFysmoAjbQfMeWKeVibJSMwfXuYUDBqHIbaFhvbiI1V2dmmokpKvagS5JHG)(4qUweoW6MpRWRG)CgphlxGpkppU0pmJhh6DHsa3ddjg8NZ45y5c8r55XL(Hz8R(w5RG)Cgh3f8XWzoufGNVqU2mx8bT1poECO3fcYqTWXqxrVv(k4pNr2AAveNraJFXJd9Uqja1chdDfnme8NZiBnTkIZMF5x84qVlucqTWXqxrVPKD72Gcfda(oQcqe9RzFmoSyAnCE9dkVif0dh9uHJNhJE8adRC9dkVXTd58cYWnNGEqyLUA2(W2XkX6x7bgocd28XqWFFCixlIs2TBdkuma47OkaXqaOM9X4WIP1W51pO8IuqpC0tfoEEm6XdmSY1pO8g3oKZlid3Cc6nIiUv6Qz7dBhReRFThy4imyZhdb)9XHCTikz3UnOqXaGVJQaerlBm(LNg)yCyX0A486huErkOho6Pchppg94bgw56huEJBhY5fKHBob9GWJECO3fsPRMTpSDSsS(1EGHJWGnFme83hhY1IOKXas0FaDtcOiXctc(EFa)LeRRQ2fukz3UnOqXaGVJQaeNGZYzWmx((pgh9ubxnBFy7ykzmGemkufGNps0hOGjb)dxK4bG)sYciHRLpsCskgpj6dOtDqc(UGb4jXlysqowMKj4ibN6eIkwzPKD72Gcfda(oQcqKdvb45lhakyC0tfEXwtRI4O5x(Llwr7WaBnTkIJiGXVCXkAhgyRPvrC0lmZfRODyi4pNXa34LLZGz2nM8(0fuuU89FC84qVluc4se3ddb)5mg4gVSCgmZUXK3NUGIY(z9IJhh6DHsaxI4EyWr75MSkapFjaHssPfamWa8v065USXJDymvMi89B4ybYwy0BLVSaGbgGVIwp3LnECO3fkHrK0WGfamWa8v065USXJDymFpmeaqiLDT8Pcm(YW5zd9zZhh6DHGSEjrjJbKO)ayejxd9zjjGNGJj5J6ckj4uNuYUDBqHIbaFhvbio)hMzWmZMFX4ONkybadmaFfTEUlB8yhgtLy9R9adhTWzlOG7TbLYxoAp3Kvb45lbiuskt0cWYLxBSAOpBE68WGfGLlV2y1qF280zLoAp3Kvb45dY4ssVv(krlalxETXQH(S5PZddwaWadWxrlOWcgZ59HZi1(6ffp2HX8TYeHVFdhlq2cJOKXasWPoHOIvwsW)Wfj(scekPrjrNOrMKxGZaWZhj7JxKGljrIorJmj479HeCckSGX8BsW37d4VKyaOUGsY2HmjDrI(maaS5Jws8cMetxmjFvsW37dj4euybJzs6jj9scEhrcmJWSSmmLSB3guOyaW3rvaIw2WOTDt2nn0kKRfh9uHeHVFdhlq2cJuI1V2dmC0cNTGcU3gukF9Yr75MSkapFjaHss5RG)Cgh3f8XWzoufGNVqU2mx8bT1po(vhgs0cWYLxBCmMx717HHG)CgdmaaS5J24xvzWFoJbgaa28rB84qVleKHusJ(Yck4FVr1JTnIZUPHwHCTXTd5mw3853VhgcaiKYUw(ubgFz48SH(S5Jd9Uqqgsjn6llOG)9gvp22io7MgAfY1g3oKZyDZNFpmyby5YRnwn0NnpD(TYxjAby5YRnwn0NnpDEy4LJ2ZnzvaE(GmUK0WamyJZ)HzgmZS5xCCB74UG(w5lS(1EGHJwqHfmMZWmcZYomybadmaFfTGclymN3hoJu7Rxu8yhgZ3VPKD72Gcfda(oQcqSlRFLVnOWrpvir473WXcKTWiLy9R9adhTWzlOG7TbLYxVC0EUjRcWZxcqOKu(k4pNXXDbFmCMdvb45lKRnZfFqB9JJF1HHeTaSC51ghJ51E9Eyi4pNXadaaB(On(vvg8NZyGbaGnF0gpo07cb5rK0OVSGc(3Bu9yBJ4SBAOvixBC7qoJ1nF(97HHaacPSRLpvGXxgopBOpB(4qVleKhrsJ(Yck4FVr1JTnIZUPHwHCTXTd5mw3853ddwawU8AJvd9zZtNFR8vIwawU8AJvd9zZtNhgE5O9CtwfGNpiJljnmad248FyMbZmB(fh32oUlOVv(cRFThy4OfuybJ5mmJWSSddwaWadWxrlOWcgZ59HZi1(6ffp2HX89BkzmGemcTDOVmIKhaEsc)2hs0jAKjXpMeOExmmjQ8rcITGcMs2TBdkuma47OkarS(1EGHXr5HScosDK5lLT4aRB(ScS10Qio2v28l)W44ACLB3gur063SpoYkIT)LZBhYJMiBnTkIJDLn)Ypm(li8ORB4AJiW3KbZ8(W5j4y0g5YdmmmgFeVXvUDBqfXF((ezfX2)Y5Td5rtkcjCfsLnM8JJwMsgdirX)dvjjD9d9pOmIe8pCrY(WKmBOpljnIepa8xswajCbJdsMhx6hMK0is8aWFjzbKWfmoibtWNe)ys8LeiusJsIorJmjDrIxKGrwtRIyCqco1jevSYsIXrlIeVa7dFKGRhfXwejGJembFsWd(gysay5Z6QKecoMK9XlsOb9sIeDIgzsW)Wfjyc(KGh8nWfgUKKU(H(huMKcGNs2TBdkuma47Okar06h6FqzC0tfEfaqiLDT8Pcm(YW5zd9zZhh6DHGmUmm8k4pNXZXYf4JYZJl9dZ4XHExiid1chdDfHXTCBE5O9CtwfGNpC1is6TYG)CgphlxGpkppU0pmJF13VhgE5O9CtwfGNVrX6x7bgo6i1rMVu2IXd(ZzKTMwfXzeW4x84qVl0OWGno)hMzWmZMFXXTTJr5Jd9UW4qkI7e0tVKggC0EUjRcWZ3Oy9R9adhDK6iZxkBX4b)5mYwtRI4S5x(fpo07cnkmyJZ)HzgmZS5xCCB7yu(4qVlmoKI4ob90lP3kzRPvrCSRSxyQ8vIb)5mA9Cx24xDyiX1nCTr06NbCWrU8add)w5RxjAbadmaFfTEUlB8Romyby5YRnogZR9szIwaWadWxroufGNVCaOGJF13ddwawU8AJvd9zZtNFR8vIwawU8AJy5AFW8ggsm4pNrRN7Yg)QddoAp3Kvb45lbiusVhgETUHRnIw)mGdoYLhyyyLb)5mA9Cx24xv5RG)CgrRFgWbhrRBhd5rmm4O9CtwfGNVeGqj9(9WqWFoJwp3LnECO3fkbCTYed(Zz8CSCb(O884s)Wm(vvM46gU2iA9Zao4ixEGHHPKXas0fetIUcauis6IKr6x(rcgznTkIjXlysqowMemMDZCu933yirxbaksMGJeCQtiQyLLs2TBdkuma47OkaXIXNdbGch9uHxb)5mYwtRI4S5x(fpo07cLaRi2(xoVDipm8Y(4hugPaKuES9XpOCE7qgY4(9WG9XpOmsHr8wPRMTpSDmLSB3guOyaW3rvaIpUzMdbGch9uHxb)5mYwtRI4S5x(fpo07cLaRi2(xoVDiR8LfamWa8v065USXJd9UqjG7KggSaGbgGVIwqHfmMZ7dNrQ91lkECO3fkbCN07HHx2h)GYifGKYJTp(bLZBhYqg3VhgSp(bLrkmI3kD1S9HTJPKD72Gcfda(oQcqC(nMCiau4ONk8k4pNr2AAveNn)YV4XHExOeyfX2)Y5TdzLVSaGbgGVIwp3LnECO3fkbCN0WGfamWa8v0ckSGXCEF4msTVErXJd9UqjG7KEpm8Y(4hugPaKuES9XpOCE7qgY4(9WG9XpOmsHr8wPRMTpSDmLmgqceiaJibuKyHPKD72Gcfda(oQcqeVFxdUmyMzZVykzmGeDbXKKU(n7JjzbKOEaljPaJFKGrwtRIysahj4F4IKUibugmjzK(LFKGrwtRIys8cMKpIjbceGrKOEalIKEssxKms)YpsWiRPvrmLSB3guOyaW3rvaIO1VzFmo6PcS10Qio2v28l)ggyRPvrCebm(Llwr7WaBnTkIJEHzUyfTddb)5mI3VRbxgmZS5xC8RQm4pNr2AAveNn)YV4xDy4vWFoJwp3LnECO3fcYUDBqfXF((ezfX2)Y5TdzLb)5mA9Cx24x9nLSB3guOyaW3rvaI4pFFOKD72Gcfda(oQcq8(v2TBdQSPrlokpKvy6gZ(CFkzkzmGK01p0)GYKmbhjHaSCixlj)YWiejFuxqjrFaDQdkz3UnOqXPBm7Z9vaT(H(hugh9uHeVFXtWbLJbUXllNbZSBm59PlOOidb)TQkdtjJbKGthTKSpmjWGLe89(qY(WKecqljBhYKSasCyys(12gs2hMKqxrKa)pFBqrsJi5P3ijP)A2htYXHExisc)MTvnndtYcij0x7djHaqn7Jjb(F(2GIs2TBdkuC6gZ(C)rvaIOFn7JXHftRHZRFq5fPGE4ONkad2yiauZ(44XHExOeoo07cHXHeKWv6HRPKD72GcfNUXSp3FufGyiauZ(ykzkzmGeDbXKSpmjqaW1(G5rc(EFiXjbN6eIkwzjzF8LKgvy4sY8aHKmYFdYpkz3UnOqr0QW5y5c8r55XL(Hjo6Pcb)5mA9Cx24XHExOe0d3uYyaj6cIjjD9d9pOmjlGKXmRsYxLK9HjrXFShg0fmFKe8Nts6jj9scEW3atcRi1(ysc4j4ysMD1ONUGsY(WKuSIwsSoAjbCKSasG)HQKeWtWXKGtqHfmMPKD72Gcfr7Okar06h6FqzC0tfUFXtWbLJBhY4bxLHp2dd6cMVidb)TQkdR8fBnTkIJDL9ctLj(6vWFoJBhY4bxLHp2dd6cMV4XHExOeC72GkI)89jYkIT)LZBhYJMuupLVyRPvrCSRCayFggyRPvrCSRmcy8ByGTMwfXrZV8lxSI23ddb)5mUDiJhCvg(ypmOly(Ihh6DHsWTBdQiA9B2hhzfX2)Y5Td5rtkQNYxS10Qio2v28l)ggyRPvrCebm(Llwr7WaBnTkIJEHzUyfTVFpmKyWFoJBhY4bxLHp2dd6cMV4x99WWRG)CgTEUlB8RomG1V2dmC0ckSGXCgMryw23kTaGbgGVIwqHfmMZ7dNrQ91lkESdJPslalxETXQH(S5PZVv(krlalxETXXyETxddwaWadWxroufGNVCaOGJhh6DHsax)w5RG)CgTEUlB8RomKOfamWa8v065USXJDymFtjJbKOliMeDc7QBJLjjfVFHKG)Hls2h(ysAejfGe3UnwMeeE)cXbjoIeJVmjoIevac1bgMeqrccVFHKGV3hsGejGJKjJNpsqRBhJibCKaksCsgXOKGW7xijiaj7JVKSpmjfJNeeE)cjXVRXYisGa8Jws85Yhj7JVKGW7xijSIu7JruYUDBqHIODufGOd7QBJLZi8(fIdlMwdNx)GYlsb9WrpviryWgDyxDBSCgH3VWmSh6q5422XDbvzIUDBqfDyxDBSCgH3VWmSh6q5yx5PPH(SkFLimyJoSRUnwoJW7xy(HDtCB74UGomad2Od7QBJLZi8(fMFy3epo07cLaUFpmad2Od7QBJLZi8(fMH9qhkhrRBhd5rOegSrh2v3glNr49lmd7HouoECO3fcYJqjmyJoSRUnwoJW7xyg2dDOCCB74UGsjJbKOligrcobfwWyMKEsco1jevSYssJi5Rsc4ibtWNe)ysGzeMLTlOKGtDcrfRSKGV3hsWjOWcgZK4fmjyc(K4htsaBa4jbxsIeDIgzkz3UnOqr0oQcq0ckSGXCEF4msTVEr4ONkKi89B4ybYwyKYxVW6x7bgoAbfwWyodZimlRYeTaGbgGVIwp3LnESdJPYeVFXtWbLJQxhco42nz)SE12S63G8Byi4pNrRN7Yg)QVv6O9CtwfGNpiJljP8vWFoJS10QioB(LFXJd9UqjOxsddb)5mYwtRI4mcy8lECO3fkb9s69WqaaHuoBOpB(4qVleK1lP3uYyaj4euW92GIKj4iXngsGblIK9Xxsc9XmIe0)ys2hgts8JlmCj545XOhgMe8pCrIUQJLlWhrI(74s)WKKhhrIHris2hVib3KGylIKJd9U6ckjGJK9HjzmMx7fjb)5KKgrIha(ljlGKPBmKaMtsahjEHjjyK10QiMKgrIha(ljlGewrQ9XuYUDBqHIODufGiw)ApWW4O8qwbyWMpgc(7Jd5Ar4aRB(ScVc(Zz8CSCb(O884s)WmECO3fkbCpmKyWFoJNJLlWhLNhx6hMXV6BLVc(ZzCCxWhdN5qvaE(c5AZCXh0w)44XHExiid1chdDf9w5RG)CgzRPvrCgbm(fpo07cLaulCm0v0WqWFoJS10QioB(LFXJd9Uqja1chdDf9Ms2TBdkueTJQaedbGA2hJdlMwdNx)GYlsb9Wrpv445XOhpWWkx)GYBC7qoVGmCZjOhKu(YvZ2h2owjw)ApWWryWMpgc(7Jd5ArVPKD72Gcfr7Okar0VM9X4WIP1W51pO8IuqpC0tfoEEm6XdmSY1pO8g3oKZlid3Cc6bjLVC1S9HTJvI1V2dmCegS5JHG)(4qUw0Bkz3UnOqr0oQcqeTSX4xEA8JXHftRHZRFq5fPGE4ONkC88y0JhyyLRFq5nUDiNxqgU5e0dcR8LRMTpSDSsS(1EGHJWGnFme83hhY1IEtjJbKOliMe9hq3KaksSWKGV3hWFjX6QQDbLs2TBdkueTJQaeNGZYzWmx((pgh9ubxnBFy7ykzmGeDbXKabSl4JHjjvTVErKGV3hs8ctsmGckjCb(qFiX4OTlOKGrwtRIys8cMK9WKKfqIPlMKEj5Rsc(EFizK)gKFK4fmj4uNquXklLSB3guOiAhvbiYHQa88Ldafmo6PcVEf8NZiBnTkIZiGXV4XHExOe0lPHHG)CgzRPvrC28l)Ihh6DHsqVKER0cagya(kA9Cx24XHExOegrskFf8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKWLKggs8(fpbhuoQEDi4GB3K9Z6vBZQFdYVidb)TQkd)(9WqWFoJQxhco42nz)SE12S63G8lI1nFobfGKIlPHblayGb4RO1ZDzJh7WyQ0r75MSkapFjaHsIsgdirxqmj4uNquXklj479HeCckSGXmeHa2f8XWKKQ2xVis8cMeyqHHljaS8H)6LjzK)gKFKaosW)Wfj6ZaaWMpAjbp4BGjHvKAFmjb8eCmj4uNquXkljSIu7JruYUDBqHIODufGOLnmAB3KDtdTc5AXrpvir473WXcKTWiLy9R9adhTWzlOG7TbLYxoAp3Kvb45lbiuskFf8NZ44UGpgoZHQa88fY1M5IpOT(XXV6WqIwawU8AJJX8AVEpmyby5YRnwn0NnpDEyi4pNXadaaB(On(vvg8NZyGbaGnF0gpo07cbziL0OVEbHW43V4j4GYr1RdbhC7MSFwVABw9Bq(fzi4Vvvz43J(Yck4FVr1JTnIZUPHwHCTXTd5mw3853VFRmXG)CgTEUlB8RQ8vIwawU8AJvd9zZtNhgSaGbgGVIwqHfmMZ7dNrQ91lk(vhgcaiKYUw(ubgFz48SH(S5Jd9Uqq2cagya(kAbfwWyoVpCgP2xVO4XHExOrHWddDT8Pcm(YW5zd9zZhh6DHWv4k9W1jbziL0OVSGc(3Bu9yBJ4SBAOvixBC7qoJ1nF(9Bkz3UnOqr0oQcqSlRFLVnOWrpvir473WXcKTWiLy9R9adhTWzlOG7TbLYxoAp3Kvb45lbiuskFf8NZ44UGpgoZHQa88fY1M5IpOT(XXV6WqIwawU8AJJX8AVEpmyby5YRnwn0NnpDEyi4pNXadaaB(On(vvg8NZyGbaGnF0gpo07cb5rK0OVEbHW43V4j4GYr1RdbhC7MSFwVABw9Bq(fzi4Vvvz43J(Yck4FVr1JTnIZUPHwHCTXTd5mw3853VFRmXG)CgTEUlB8RQ8vIwawU8AJvd9zZtNhgSaGbgGVIwqHfmMZ7dNrQ91lk(vhgcaiKYUw(ubgFz48SH(S5Jd9Uqq2cagya(kAbfwWyoVpCgP2xVO4XHExOrHWddDT8Pcm(YW5zd9zZhh6DHWv4k9W1jb5rK0OVSGc(3Bu9yBJ4SBAOvixBC7qoJ1nF(9BkzmGeia8R9adtYhXWKaks8G20BZis2hFjbVxljlGKaMeKJLHjzcosWPoHOIvwsqas2hFjzFymjXpUwsW7OLHjbcWpAjjGNGJjzF4qkz3UnOqr0oQcqeRFThyyCuEiRaYXY5j4Ywp3LfhyDZNvirlayGb4RO1ZDzJh7WyomKiw)ApWWrlOWcgZzygHzzvAby5YRnwn0NnpDEya((nCSazlmIsgdirxqmIe9haJiPNK0fjErcgznTkIjXlys2RzejlGetxmj9sYxLe89(qYi)ni)Wbj4uNquXkljEbtIoHD1TXYKKI3Vqkz3UnOqr0oQcqC(pmZGzMn)IXrpvGTMwfXXUYEHPsxnBFy7yLb)5mQEDi4GB3K9Z6vBZQFdYViw38zidjCjjLVGbB0HD1TXYzeE)cZWEOdLJBBh3f0HHeTaSC51gl2Ead4GFReRFThy4iYXY5j4Ywp3LLsgdirxqmjymkEFijD9B6gdjQhWIiPNKKU(nDJHKgvy4sYxLs2TBdkueTJQaerRFt3yWrpvi4pNrqX7dkRYNLv3guXVQYG)CgrRFt3yIhppg94bgMs2TBdkueTJQaeTEzzto4pN4O8qwb06NbCW4ONke8NZiA9Zao44XHExiiJBLVc(ZzKTMwfXzeW4x84qVluc4Eyi4pNr2AAveNn)YV4XHExOeW9BLoAp3Kvb45lbiusuYyajk(FOkIeDIgzsc4j4ysWjOWcgZK8rDbLK9HjbNGclymtIfuW92GIKfqI9HTJjPNKGtqHfmMjPrK4297gdMK4bG)sYcijGjX6OLs2TBdkueTJQaerRFt3yWrpvyDdxBeTSX4xg(65g5YdmmSseVBxqrreWaYWxpxLb)5mIw)MUXeHb4lkzmGef)pufrIJujjGNGJjbNGclymtYh1fus2hMeCckSGXmjwqb3Bdkswaj2h2oMKEscobfwWyMKgrIB3VBmysIha(ljlGKaMeRJwkz3UnOqr0oQcqeT(H(hugh9ublalxETXQH(S5PZkX6x7bgoAbfwWyodZimlRslayGb4ROfuybJ58(WzKAF9IIhh6DHGmUvMi89B4ybYwyeLmgqIUGyssx)MUXqc(EFijDzJXpsu8xpxs8cMKcqs66NbCW4Ge8pCrsbijD9B6gdjnIKVkoibtWNe)ys6IKr6x(rcgznTkIjbCKSasupGLKr(Bq(rc(hUiXdayzsGqjrIorJmjGJehw13gltccVFHK84isW1JIylIKJd9U6ckjGJKgrsxKmnn0NLs2TBdkueTJQaerRFt3yWrpvyDdxBeTSX4xg(65g5YdmmSYex3W1grRFgWbh5YdmmSYG)CgrRFt3yIhppg94bgw5RG)CgzRPvrC28l)Ihh6DHsacRKTMwfXXUYMF5NYG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mKHeUtAyi4pNr1RdbhC7MSFwVABw9Bq(fX6MpNGcqc3jP0r75MSkapFjaHsAyagSrh2v3glNr49lmd7HouoECO3fkbC9WGB3gurh2v3glNr49lmd7Houo2vEAAOp7BLjAbadmaFfTEUlB8yhgtkzmGeDbXKKU(H(huMemgfVpKOEalIeVGjb(hQsIorJmj4F4IeCQtiQyLLeWrY(WKabax7dMhjb)5KKgrIha(ljlGKPBmKaMtsahjyc(yimjwxLeDIgzkz3UnOqr0oQcqeT(H(hugh9uHG)CgbfVpOS1W(LX2OguXV6WqWFoJJ7c(y4mhQcWZxixBMl(G26hh)Qddb)5mA9Cx24xv5RG)CgphlxGpkppU0pmJhh6DHGmulCm0veg3YT5LJ2ZnzvaE(WvJiP3kd(Zz8CSCb(O884s)Wm(vhgsm4pNXZXYf4JYZJl9dZ4xvzIwaWadWxXZXYf4JYZJl9dZ4XomMddjAby5YRnILR9bZ79WGJ2ZnzvaE(sacLKs2AAveh7k7fMuYyaj64WKKfqsOpMjzFyscy0scyss66NbCWKeGjjO1TJ7ckj9sYxLei4VTJnyssxK4fMKGrwtRIysc(ljJ83G8JKgvljEa4VKSascysupG1YWuYUDBqHIODufGiA9d9pOmo6PcRB4AJO1pd4GJC5bggwzI3V4j4GYXTdz8GRYWh7HbDbZxKHG)wvLHv(k4pNr06NbCWXV6WGJ2ZnzvaE(sacL0BLb)5mIw)mGdoIw3ogYJq5RG)CgzRPvrCgbm(f)Qddb)5mYwtRI4S5x(f)QVvg8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKuCjP8LfamWa8v065USXJd9UqjOxsddjI1V2dmC0ckSGXCgMrywwLwawU8AJvd9zZtNFtjJbKO4)HQKKU(H(huMKUiXjrXnkITKKcm(rcgznTkIXbjWGcdxsm8ssVKOEaljJ83G8JKx7JVK0isE8c2WWKeGjjCVp8rY(WKKU(nDJHetxmjGJK9HjrNOrobiusKy6Ijzcossx)q)dk)ghKadkmCjbGLp8xVmjErcgJI3hsupGLeVGjXWlj7dtIhaWYKy6Ij5Xlydts66NbCWuYUDBqHIODufGiA9d9pOmo6PcjE)INGdkh3oKXdUkdFShg0fmFrgc(Bvvgw5RG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mKHKIlPHHG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mKHeUts56gU2iAzJXVm81ZnYLhyy43kd(ZzKTMwfXzeW4x84qVluckoLS10Qio2vgbm(PmXG)CgbfVpOSkFwwDBqf)QktCDdxBeT(zahCKlpWWWkTaGbgGVIwp3LnECO3fkbfNYxwaWadWxXXDbFmCgP2xVO4XHExOeuCddjAby5YRnogZR96nLmgqIUGys0vaGcrsxKms)YpsWiRPvrmjEbtcYXYKGXSBMJQ)(gdj6kaqrYeCKGtDcrfRSK4fmjqa7c(yysWOqvaE(c5APKD72Gcfr7OkaXIXNdbGch9uHxb)5mYwtRI4S5x(fpo07cLaRi2(xoVDipm8Y(4hugPaKuES9XpOCE7qgY4(9WG9XpOmsHr8wPRMTpSDSsS(1EGHJihlNNGlB9Cxwkz3UnOqr0oQcq8XnZCiau4ONk8k4pNr2AAveNn)YV4XHExOeyfX2)Y5TdzLjAby5YRnogZR9Ay4vWFoJJ7c(y4mhQcWZxixBMl(G26hh)QkTaSC51ghJ51E9Ey4L9XpOmsbiP8y7JFq582HmKX97Hb7JFqzKcJyyi4pNrRN7Yg)QVv6Qz7dBhReRFThy4iYXY5j4Ywp3LLs2TBdkueTJQaeNFJjhcafo6PcVc(ZzKTMwfXzZV8lECO3fkbwrS9VCE7qwzIwawU8AJJX8AVggEf8NZ44UGpgoZHQa88fY1M5IpOT(XXVQslalxETXXyETxVhgEzF8dkJuaskp2(4huoVDidzC)EyW(4hugPWiggc(Zz065USXV6BLUA2(W2XkX6x7bgoICSCEcUS1ZDzPKXas0fetceiaJibuKyHPKD72Gcfr7Okar8(Dn4YGzMn)IPKXas0fets663SpMKfqI6bSKKcm(rcgznTkIXbj4uNquXkljpoIedJqKSDitY(4fjojqGNVpKWkIT)LjXWZLeWrcOmysYi9l)ibJSMwfXK0is(QuYUDBqHIODufGiA9B2hJJEQaBnTkIJDLn)YVHb2AAvehraJF5Iv0omWwtRI4OxyMlwr7WqWFoJ497AWLbZmB(fh)Qkd(ZzKTMwfXzZV8l(vhgEf8NZO1ZDzJhh6DHGSB3gur8NVprwrS9VCE7qwzWFoJwp3Ln(vFtjJbKOliMeiWZ3hsa7dF4Betc(N2(qsJiPlssbg)ibJSMwfX4GeCQtiQyLLeWrYcir9awsgPF5hjyK10QiMs2TBdkueTJQaeXF((qjJbKO)CJzFUpLSB3guOiAhvbiE)k72Tbv20OfhLhYkmDJzFUV2QTAA]] )


end