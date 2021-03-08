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


    spec:RegisterPack( "Balance", 20210307, [[davmJeqirKhbfXLGkrBIe9jOOAuQsDkvjRckkELcPzbv4wKkP2Lq)ceAyIqhJuvlde5zkeMgujDnsiBdeuFdQeghjuCoqGwhPkvZde19ib7teCqsfTqsv8qOIMiju6IqrAJKQu(iuusgjuusDssOALIOEjuuIzQqKBsQKyNKk1pbbOHQqulLujPNkstLuHRsQeBfea9vqanwOOu7Lu(ROgmXHPAXc8yknzqDzuBwrFgKgTQ40sTAqa41kuZMIBlODl53adNKooiilxLNdz6kDDv12HsFhQA8qL68qH1tQsMVc2pYA6RPdTuyFznDdPeHK(joIeXfr9HG6JlWvT0fdvwlv1TJDOSwA5HSwQECJxwwlv1XWaCynDOLIa)ZYAPp7QI07qeIq795heTGqiI6WVX3gu2ZNlerDOfIAPb)2SkEPfOLc7lRPBiLiK0pXrKiUiQpeuFCbKGGAP(FFaNwAAhItT0NggMlTaTuygz1s1JB8YYKOyVFdtjRR4N9HeCboibsjcj9PKPKX5JxqzKENswxtIoHHzyssbg)irpShgPK11KGZhVGYWKS(bL3CpjX6igrYciXIH1W51pO8IIuY6As0v5qawgMKFvSLri)WGeS(1EGHrK8UJCehKOEm2mA9d9pOmj66eir9ySr06h6Fq5xrkzDnj6elOHjr9yRJ2UGsce457dj9KKEXCej7dtc(duqjbtTMwfXrkzDnj6k(yMeCckSGXmj7dtsQAF9IiXjX07AyscbhtY0W4UdmmjV7jjya(K84WfMVK80lj9scQd)M1lg8rgmibFVpKOhiG6uhKmkj4KnmAB3qIonn0kKRfhK0lMdtcACR(ksjRRjrxXhZKecqljy(SH(S5Jd9Uqyojilx(1aejUQQbdswajbaeIKzd9zrKakdgrTutJwKMo0sH5P)nRMo00T(A6ql1TBdkTueW4xoG9qTuU8addRPhTvt3qsthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zTuKkBm51pO8IIO1VPBmKKaj6tIssEtssKSUHRnIw)mGdoYLhyyysggizDdxBeTSX4xg(65g5YdmmmjVizyGeKkBm51pO8IIO1VPBmKKajqslfMr2Rv3guAPP8IirNamLeqrYigLe89(a(ljWxpxs8cMe89(qs66NbCWK4fmjqAusa7dF4BeRLI1VC5HSwAJYoG1wnDpcnDOLYLhyyyn9OLcu1sr8QL62TbLwkw)ApWWAPyDZN1srQSXKx)GYlkIw)M9XKKaj6RLcZi71QBdkT0uErKynSJLjb)dxKKU(n7JjX6fjp9scKgLK1pO8Iib)tBFiPrKCSHX61sYeCKSpmjyQ10QiMKfqsatI6Xt(ogMeVGjb)tBFiz2gdFKSasSoA1sX6xU8qwlTrzRHDSS2QPBCvthAPC5bggwtpAPUDBqPLgWhIVXDbvlfMr2Rv3guAP6cIjrp8H4BCxqjbFVpKGtDcrfVSKaos85Yhj4euybJzs6IeCQtiQ4Lvl1E9Yx7APVjjjsSaSC51gRg6ZMNotYWajjrIfamWa8v0ckSGXCEF4msTVErXVkjVirjjb)5mA9Cx24xvB10TI00HwkxEGHH10JwQ96LV21sd(Zz065USXJd9UqKKaj6RisggijaGqKOKKzd9zZhh6DHibYKajfPLcZi71QBdkT0rgSKGV3hsCsWPoHOIxws2hFjPrfMVK4KmYFdYpsupGLeWrc(hUizFysMn0NLKgrIha(ljlGeUG1sD72GslvfSnO0wnDdH10HwkxEGHH10JwkqvlfXRwQB3guAPy9R9adRLI1nFwl1YTHK3K8MKUw(ubgFz48SH(S5Jd9UqKORjrFfrIUMelayGb4RO1ZDzJhh6DHi5fjqKe9vmjsYlsuGel3gsEtYBs6A5tfy8LHZZg6ZMpo07crIUMe9vej6As0hsjsIUMelayGb4ROfuybJ58(WzKAF9IIhh6DHi5fjqKe9vmjsYlsggiXcagya(kA9Cx24XHExissGKUw(ubgFz48SH(S5Jd9UqKmmqIfamWa8v0ckSGXCEF4msTVErXJd9UqKKajDT8Pcm(YW5zd9zZhh6DHirxtI(jsYWajjrIfGLlV2y1qF280zTuygzVwDBqPLIt3y)gFzej4F49Hps(OUGscobfwWyMKcGNe8TXqIBma8KGb4tYcibTTXqI1rlj7dtcYdzs8qWVwsatsWjOWcgZJItDcrfVSKyD0I0sX6xU8qwl1ckSGXCgMryuwTvt34cnDOLYLhyyyn9OLcu1sr8QL62TbLwkw)ApWWAPyDZN1sFtssKWqOFRQYWroufJJDtgCWLxwMKHbsSaGbgGVICOkgh7Mm4GlVSC84qVlejqMe9HWjsIsssIelayGb4RihQIXXUjdo4Yllhp2HXGKxKmmqIfGLlV24ymU2lTuygzVwDBqPLQligMKfqcmBCmizFys(ihktcysco1jev8Ysc(hUi5J6ckjWGFGHjbuK8rSwkw)YLhYAPw4SfuW92GsB10TIrthAPC5bggwtpAPWmYET62GslvxqmjyAOkgh7gsGaEWLxwMeiLiITisc4j4ysCsWPoHOIxws(ioQLwEiRLYHQyCSBYGdU8YYAP2Rx(Axl1cagya(kA9Cx24XHExisGmjqkrsusIfamWa8v0ckSGXCEF4msTVErXJd9UqKazsGuIKmmqsaaHirjjZg6ZMpo07crcKjze4cTu3UnO0s5qvmo2nzWbxEzzTvt3qqnDOLYLhyyyn9OLcZi71QBdkTuDbXKKc(gdVDbLeD1FagKaHrSfrsapbhtItco1jev8YsYhXrT0YdzTue4Bm8UDbnF)am0sTxV81UwQfamWa8v065USXJd9UqKazsGWKOKKKibRFThy4OfuybJ5mmJWOSKmmqIfamWa8v0ckSGXCEF4msTVErXJd9UqKazsGWKOKeS(1EGHJwqHfmMZWmcJYsYWajbaeIeLKmBOpB(4qVlejqMeiPiTu3UnO0srGVXW72f089dWqB10T(jQPdTuU8addRPhTu3UnO0s7czV)6bgodH(ET)WmmJTTSwQ96LV21sd(Zz065USXVQwA5HSwAxi79xpWWzi03R9hMHzSTL1wnDRV(A6qlLlpWWWA6rl1TBdkT096AmV6RLcZi71QBdkTuD80isAejojNVp8rcB8aW5ltcEhdswajH(yMe3yibuK8rmjO1xs2RRX8IizbKeWKy6IHj5Rsc(EFibN6eIkEzjXlysWjOWcgZK4fmjFetY(WKaPcMeKbSKaksSWK0tsca7dj711yErK4htcOi5JysqRVKSxxJ5fPLAVE5RDT03KG1V2dmCeu5pIZ711yEjrbs0NKHbsW6x7bgocQ8hX596AmVKOajJGKxKOKK3Ke8NZO1ZDzJFvsggiXcagya(kA9Cx24XHExisgLeirscKSxxJ5nU6hTaGbgGVIW)Z3guKOKK3KKejwawU8AJvd9zZtNjzyGKKibRFThy4OfuybJ5mmJWOSK8IeLKKejwawU8AJJX4AVizyGelalxETXQH(S5PZKOKeS(1EGHJwqHfmMZWmcJYsIssSaGbgGVIwqHfmMZ7dNrQ91lk(vjrjjjrIfamWa8v065USXVkjkj5njVjj4pNr2AAveNn)YV4XHExissGe9tKKHbsc(ZzKTMwfXzeW4x84qVlejjqI(jsYlsusssKC)INGdkhdCJxwodMz3yY7txqrrU8addtYWajVjj4pNXa34LLZGz2nM8(0fuuU89FCeTUDmjkqIIizyGKG)CgdCJxwodMz3yY7txqrz)SEXr062XKOajkIKxK8IKHbsc(ZzCCxWhdN5qvaE(c5AZCXh0wV44xLKxKmmqsaaHirjjZg6ZMpo07crcKjbsjsYWajy9R9adhbv(J48EDnMxsuGKe1wnDRpK00HwkxEGHH10JwQ96LV21sX6x7bgocQ8hX596AmVKOajJGeLKKej711yEJR(XJDymYwaWadWxKmmqYBsc(Zz065USXVkjddKybadmaFfTEUlB84qVlejJscKijbs2RRX8gxifTaGbgGVIW)Z3guKOKK3KKejwawU8AJvd9zZtNjzyGKKibRFThy4OfuybJ5mmJWOSK8IeLKKejwawU8AJJX4AVizyGelalxETXQH(S5PZKOKeS(1EGHJwqHfmMZWmcJYsIssSaGbgGVIwqHfmMZ7dNrQ91lk(vjrjjjrIfamWa8v065USXVkjkj5njVjj4pNr2AAveNn)YV4XHExissGe9tKKHbsc(ZzKTMwfXzeW4x84qVlejjqI(jsYlsusssKC)INGdkhdCJxwodMz3yY7txqrrU8addtYWajVjj4pNXa34LLZGz2nM8(0fuuU89FCeTUDmjkqIIizyGKG)CgdCJxwodMz3yY7txqrz)SEXr062XKOajkIKxK8IKxKmmqsWFoJJ7c(y4mhQcWZxixBMl(G26fh)QKmmqsaaHirjjZg6ZMpo07crcKjbsjsYWajy9R9adhbv(J48EDnMxsuGKe1sD72GslDVUgZlK0wnDR)i00HwkxEGHH10JwQB3guAPFeN7LdrAPWmYET62GslvxqmIe3yibSp8rcOi5Jys6LdrKaksSWAP2Rx(Axln4pNrRN7Yg)QKmmqIfGLlV2y1qF280zsuscw)ApWWrlOWcgZzygHrzjrjjwaWadWxrlOWcgZ59HZi1(6ff)QKOKKKiXcagya(kA9Cx24xLeLK8MK3Ke8NZiBnTkIZMF5x84qVlejjqI(jsYWajb)5mYwtRI4mcy8lECO3fIKeir)ej5fjkjjjsUFXtWbLJbUXllNbZSBm59PlOOixEGHHjzyGK7x8eCq5yGB8YYzWm7gtEF6ckkYLhyyysusYBsc(ZzmWnEz5myMDJjVpDbfLlF)hhrRBhtscKmcsggij4pNXa34LLZGz2nM8(0fuu2pRxCeTUDmjjqYii5fjVizyGKG)Cgh3f8XWzoufGNVqU2mx8bT1lo(vjzyGKaacrIssMn0NnFCO3fIeitcKsuB10T(4QMo0s5YdmmSME0sHzK9A1TbLwQILTnmtIB3guKyA0ssGJyysafjOE)(2GcIggAJ0sD72Gsl9(v2TBdQSPrRwkAV2UA6wFTu71lFTRLI1V2dmCSrzhWAPMgT5YdzTuhWARMU1xrA6qlLlpWWWA6rl1E9Yx7AP3V4j4GYXa34LLZGz2nM8(0fuuKHq)wvLH1sr712vt36RL62TbLw69RSB3guztJwTutJ2C5HSwAaWxTvt36dH10HwkxEGHH10JwQB3guAP3VYUDBqLnnA1snnAZLhYAPOvB1wT0aGVA6qt36RPdTuU8addRPhTu3UnO0sphlxGpkppU0lm0sHzK9A1TbLwQE74sVWGe89(qco1jev8YQLAVE5RDT0G)CgTEUlB84qVlejjqI(ksB10nK00HwkxEGHH10JwkqvlfXRwQB3guAPy9R9adRLI1nFwlnjsc(ZzmWnEz5myMDJjVpDbfLlF)hh)QKOKKKij4pNXa34LLZGz2nM8(0fuu2pRxC8RQLcZi71QBdkTuC(W2Xis6jj7dtIEa6uhKyVEjj4pNK0iskWsYxLKj4iX4lFK8rSwkw)YLhYAP2R3cSFvTvt3JqthAPC5bggwtpAPUDBqPL6WU62y5mcVFHAPwmSgoV(bLxKMU1xl1E9Yx7APb)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJjbYKGRKOKKG)CgdCJxwodMz3yY7txqrz)SEXr062XKazsWvsusYBssIeyWgDyxDBSCgH3VWmSh6q5422XDbLeLKKejUDBqfDyxDBSCgH3VWmSh6q5yx5PPH(SKOKK3KKejWGn6WU62y5mcVFH5h2nXTTJ7ckjddKad2Od7QBJLZi8(fMFy3epo07crscKmcsErYWajWGn6WU62y5mcVFHzyp0HYr062XKazsgbjkjbgSrh2v3glNr49lmd7HouoECO3fIeitIIirjjWGn6WU62y5mcVFHzyp0HYXTTJ7ckjV0sHzK9A1TbLwQUGys0jSRUnwMKu8(fsc(hUiXxsmmcrY(4fj4kj6bOtDqcAD7yejEbtYci545XOhsCsGScqIe062XK4ism(YK4isubiuhyysahjBhYK0ljiaj9sIFxJLrKabWhTK4ZLpsCsgXOKGw3oMeg3Q9XiTvt34QMo0s5YdmmSME0sD72Gsl1ckSGXCEF4msTVErAPWmYET62Gslvxqmj4euybJzsW37dj4uNquXllj4F4Ievac1bgMeVGjbSp8HVrmj479HeNe9a0Poij4pNKG)HlsGzegLTlOAP2Rx(Axl9njy9R9adhTGclymNHzegLLeLKKejwaWadWxrRN7Ygp2HXGKHbsc(Zz065USXVkjVirjjVjj4pNXa34LLZGz2nM8(0fuuU89FCeTUDmjkqIIizyGKG)CgdCJxwodMz3yY7txqrz)SEXr062XKOajkIKxKmmqsaaHirjjZg6ZMpo07crcKjr)e1wnDRinDOLYLhyyyn9OL62TbLw68FyKbZmB(fRLcZi71QBdkTu9gatjXrKSpmjZ(qljqTWK0fj7dtItIEa6uhKGVlyaEsahj479HK9HjbZcgx7fjb)5KeWrc(EFiXjrXmkITKOtyxDBSmjP49lKeVGjbV3ljtWrco1jev8YsspjPxsWdQLKaMKVkjouVlsc4j4ys2hMelmjnIKzxn6HH1sTxV81Uw6BsEtsWFoJbUXllNbZSBm59PlOOC57)4iAD7yssGeCLKHbsc(ZzmWnEz5myMDJjVpDbfL9Z6fhrRBhtscKGRK8IeLK8Me473WXcKTWisggiXcagya(kA9Cx24XHExissGefLijddK8MelalxETXQH(S5PZKOKelayGb4ROfuybJ58(WzKAF9IIhh6DHijbsuuIK8IKxK8IKHbsEtcmyJoSRUnwoJW7xyg2dDOC84qVlejjqIIHeLKybadmaFfTEUlB84qVlejjqI(jsIssSaSC51gl2Ead4Gj5fjddKeaqisussxlFQaJVmCE2qF28XHExisGmjkgsggi5njwawU8AJJX4AVirjjb)5moUl4JHZCOkapFHCTXVkjV0wnDdH10HwkxEGHH10JwQB3guAPwVSSjh8NtTu71lFTRL(MKG)CgdCJxwodMz3yY7txqr5Y3)XXJd9UqKKaj4AurKmmqsWFoJbUXllNbZSBm59PlOOSFwV44XHExissGeCnQisErIssEtIfamWa8v065USXJd9UqKKaj4csggi5njwaWadWxroufGNVCaOGJhh6DHijbsWfKOKKKij4pNXXDbFmCMdvb45lKRnZfFqB9IJFvsusIfGLlV24ymU2lsErYlsusIJ2ZnzvaE(ijbfizejQLg8NZC5HSwkA9ZaoyTuygzVwDBqPLItVSSHK01pd4GjbFVpK4KumEs0dqN6GKG)CsIxWKGtDcrfVSK0OcZxs8aWFjzbKeWK8rmS2QPBCHMo0s5YdmmSME0sD72GslfT(nDJrlfMr2Rv3guAPk2FOkjPRFO)bLrKGV3hsCs0dqN6GKG)CssWFjPalj4F4IevaW0fusMGJeCQtiQ4LLeWrcMLUGpgMKu1(6fPLAVE5RDT01nCTr0YgJFz4RNBKlpWWWKOKeeVBxqrreWaYWxpxsussWFoJO1VPBmrya(sB10TIrthAPC5bggwtpAPUDBqPLIw)q)dkRLcZi71QBdkTuf7puLK01p0)GYisW37dj7dtsaWxsc(Zjjb)LKcSKG)HlsubatxqjzcosSojGJeoufGNpscafSwQ96LV21stIeS(1EGHJ2R3cSFvsusYBsSaSC51gRg6ZMNotYWajwaWadWxrRN7Ygpo07crscKGlizyGKKibRFThy4OfoBbfCVnOirjjjrIfGLlV24ymU2lsggi5njwaWadWxroufGNVCaOGJhh6DHijbsWfKOKKKij4pNXXDbFmCMdvb45lKRnZfFqB9IJFvsusIfGLlV24ymU2lsErYlsusYBssIeyWgN)dJmyMzZV4422XDbLKHbssIelayGb4RO1ZDzJh7WyqYWajjrIfamWa8v0ckSGXCEF4msTVErXJDymi5L2QPBiOMo0s5YdmmSME0sD72GslfT(H(huwlfMr2Rv3guAPk2FOkjPRFO)bLrKeWtWXKGtqHfmM1sTxV81Uw6BsSaGbgGVIwqHfmMZ7dNrQ91lkECO3fIeitIIirjjjrc89B4ybYwyejkj5njy9R9adhTGclymNHzegLLKHbsSaGbgGVIwp3LnECO3fIeitIIi5fjkjbRFThy4OfoBbfCVnOi5fjkjjjsGbBC(pmYGzMn)IJBBh3fususIfGLlV2y1qF280zsusssKaF)gowGSfgrIssyRPvrCSRSxyOTA6w)e10HwkxEGHH10JwkqvlfXRwQB3guAPy9R9adRLI1nFwl9njb)5mEowUaFuEECPxyepo07crscKOisggijjsc(Zz8CSCb(O884sVWi(vj5fjkj5njb)5moUl4JHZCOkapFHCTzU4dARxC84qVlejqMeOw4yOJBsErIssEtsWFoJS10QioJag)Ihh6DHijbsGAHJHoUjzyGKG)CgzRPvrC28l)Ihh6DHijbsGAHJHoUj5LwkmJSxRUnO0svSGcZxsGbljW)RlOKSpmjCbtcysIUQJLlWhrIE74sVWahKa)VUGsY4UGpgMeoufGNVqUwsahjDrY(WKyC0sculmjGjjErcMAnTkI1sX6xU8qwlfgS5JHq)(4qUwK2QPB91xthAPC5bggwtpAPUDBqPLI(1Spwl1E9Yx7APhppg94bgMeLKS(bL342HCEbz4Mjjbs0hctIssC1S9HTJjrjjy9R9adhHbB(yi0VpoKRfPLAXWA486huErA6wFTvt36djnDOLYLhyyyn9OL62TbLwAiauZ(yTu71lFTRLE88y0JhyysusY6huEJBhY5fKHBMKeir)revejkjXvZ2h2oMeLKG1V2dmCegS5JHq)(4qUwKwQfdRHZRFq5fPPB91wnDR)i00HwkxEGHH10JwQB3guAPOLng)YtJFSwQ96LV21spEEm6Xdmmjkjz9dkVXTd58cYWntscKOpeMKrj54qVlejkjXvZ2h2oMeLKG1V2dmCegS5JHq)(4qUwKwQfdRHZRFq5fPPB91wnDRpUQPdTuU8addRPhTu3UnO0sNGZYzWmx((pwlfMr2Rv3guAP6nGUjbuKyHjbFVpG)sI1vv7cQwQ96LV21sD1S9HTJ1wnDRVI00HwkxEGHH10JwQB3guAPCOkapF5aqbRLcZi71QBdkTumnufGNps0dOGjb)dxK4bG)sYciHRLpsCskgpj6bOtDqc(UGb4jXlysqowMKj4ibN6eIkEz1sTxV81Uw6BsyRPvrC08l)YfJ7LKHbsyRPvrCebm(Llg3ljddKWwtRI4OxyKlg3ljddKe8NZyGB8YYzWm7gtEF6ckkx((poECO3fIKeibxJkIKHbsc(ZzmWnEz5myMDJjVpDbfL9Z6fhpo07crscKGRrfrYWajoAp3Kvb45JKeibcMijkjXcagya(kA9Cx24XomgKOKKKib((nCSazlmIKxKOKK3KybadmaFfTEUlB84qVlejjqYisKKHbsSaGbgGVIwp3LnESdJbjVizyGKaacrIss6A5tfy8LHZZg6ZMpo07crcKjr)e1wnDRpewthAPC5bggwtpAPUDBqPLo)hgzWmZMFXAPWmYET62GslvVbWusUg6ZssapbhtYh1fusWPo1sTxV81UwQfamWa8v065USXJDymirjjy9R9adhTWzlOG7Tbfjkj5njoAp3Kvb45JKeibcMijkjjjsSaSC51gRg6ZMNotYWajwawU8AJvd9zZtNjrjjoAp3Kvb45JeitcUMijVirjjVjjjsSaSC51gRg6ZMNotYWajwaWadWxrlOWcgZ59HZi1(6ffp2HXGKxKOKKKib((nCSazlmsB10T(4cnDOLYLhyyyn9OL62TbLwQLnmAB3KDtdTc5A1sHzK9A1TbLwko1jev8Ysc(hUiXxsGGjokj6enYK8gCgaE(izF8IeCnrs0jAKjbFVpKGtqHfmMFrc(EFa)Leda1fus2oKjPls0JbaGnF0sIxWKy6Ij5Rsc(EFibNGclymtspjPxsW7isGzegLLH1sTxV81UwAsKaF)gowGSfgrIssW6x7bgoAHZwqb3BdksusYBsEtIJ2ZnzvaE(ijbsGGjsIssEtsWFoJJ7c(y4mhQcWZxixBMl(G26fh)QKmmqssKyby5YRnogJR9IKxKmmqsWFoJbgaa28rB8RsIssc(ZzmWaaWMpAJhh6DHibYKaPejzusEtIfuW)EJQhBBeNDtdTc5AJBhYzSU5ZK8IKxKmmqsaaHirjjDT8Pcm(YW5zd9zZhh6DHibYKaPejzusEtIfuW)EJQhBBeNDtdTc5AJBhYzSU5ZK8IKHbsSaSC51gRg6ZMNotYlsusYBssIelalxETXQH(S5PZKmmqYBsC0EUjRcWZhjqMeCnrsggibgSX5)WidMz28loUTDCxqj5fjkj5njy9R9adhTGclymNHzegLLKHbsSaGbgGVIwqHfmMZ7dNrQ91lkESdJbjVi5L2QPB9vmA6qlLlpWWWA6rl1E9Yx7APjrc89B4ybYwyejkjbRFThy4OfoBbfCVnOirjjVj5njoAp3Kvb45JKeibcMijkj5njb)5moUl4JHZCOkapFHCTzU4dARxC8RsYWajjrIfGLlV24ymU2lsErYWajb)5mgyaayZhTXVkjkjj4pNXadaaB(OnECO3fIeitYisKKrj5njwqb)7nQESTrC2nn0kKRnUDiNX6MptYlsErYWajbaeIeLK01YNkW4ldNNn0NnFCO3fIeitYisKKrj5njwqb)7nQESTrC2nn0kKRnUDiNX6MptYlsggiXcWYLxBSAOpBE6mjVirjjVjjjsSaSC51gRg6ZMNotYWajVjXr75MSkapFKazsW1ejzyGeyWgN)dJmyMzZV4422XDbLKxKOKK3KG1V2dmC0ckSGXCgMryuwsggiXcagya(kAbfwWyoVpCgP2xVO4XomgK8IKxAPUDBqPL2L1VY3guARMU1hcQPdTuU8addRPhTuGQwkIxTu3UnO0sX6x7bgwlfRB(SwkBnTkIJDLn)YpsWmKOyibIK42TbveT(n7JJmUz7F582HmjJsssKWwtRI4yxzZV8JemdjVjbctYOKSUHRnIaFtgmZ7dNNGJrBKlpWWWKGzizeK8IeisIB3gur8NVprg3S9VCE7qMKrjjXiKibIKGuzJj)4OL1sHzK9A1TbLwkMI2o0xgrYdapjHF7dj6enYK4htcuVlgMev(ibXwqbRLI1VC5HSwQJuhz(szR2QPBiLOMo0s5YdmmSME0sD72GslfT(H(huwlfMr2Rv3guAPk2FOkjPRFO)bLrKG)Hls2hMKzd9zjPrK4bG)sYciHlyCqY84sVWGKgrIha(ljlGeUGXbjya(K4htIVKabtCus0jAKjPls8Iem1AAveJdsWPoHOIxwsmoArK4fyF4JefZOi2IibCKGb4tcEW3atcalFwxLKqWXKSpErcnOFIKOt0itc(hUibdWNe8GVbUW8LK01p0)GYKua8AP2Rx(Axl9njbaeIeLK01YNkW4ldNNn0NnFCO3fIeitcUsYWajVjj4pNXZXYf4JYZJl9cJ4XHExisGmjqTWXqh3KGziXYTHK3K4O9CtwfGNpsGijJirsErIssc(Zz8CSCb(O884sVWi(vj5fjVizyGK3K4O9CtwfGNpsgLeS(1EGHJosDK5lLTKGzij4pNr2AAveNraJFXJd9UqKmkjWGno)hgzWmZMFXXTTJr5Jd9UibZqcKIkIKeirF9tKKHbsC0EUjRcWZhjJscw)ApWWrhPoY8LYwsWmKe8NZiBnTkIZMF5x84qVlejJscmyJZ)HrgmZS5xCCB7yu(4qVlsWmKaPOIijbs0x)ej5fjkjHTMwfXXUYEHbjkj5njjrsWFoJwp3Ln(vjzyGKKizDdxBeT(zahCKlpWWWK8IeLK8MK3KKejwaWadWxrRN7Yg)QKmmqIfGLlV24ymU2lsusssKybadmaFf5qvaE(YbGco(vj5fjddKyby5YRnwn0NnpDMKxKOKK3KKejwawU8AJy5AFW4izyGKKij4pNrRN7Yg)QKmmqIJ2ZnzvaE(ijbsGGjsYlsggi5njRB4AJO1pd4GJC5bggMeLKe8NZO1ZDzJFvsusYBsc(ZzeT(zahCeTUDmjqMKrqYWajoAp3Kvb45JKeibcMijVi5fjddKe8NZO1ZDzJhh6DHijbsumKOKKKij4pNXZXYf4JYZJl9cJ4xLeLKKejRB4AJO1pd4GJC5bggwB10nK0xthAPC5bggwtpAPUDBqPLwm(CiauAPWmYET62Gslvxqmj6kaqHiPlsgPF5hjyQ10QiMeVGjb5yzsWS2nZr1BFJHeDfaOizcosWPoHOIxwTu71lFTRL(MKG)CgzRPvrC28l)Ihh6DHijbsyCZ2)Y5Tdzsggi5nj2h)GYisuGeirIsso2(4huoVDitcKjrrK8IKHbsSp(bLrKOajJGKxKOKexnBFy7yTvt3qcsA6qlLlpWWWA6rl1E9Yx7APVjj4pNr2AAveNn)YV4XHExissGeg3S9VCE7qMeLK8MelayGb4RO1ZDzJhh6DHijbsuuIKmmqIfamWa8v0ckSGXCEF4msTVErXJd9UqKKajkkrsErYWajVjX(4hugrIcKajsusYX2h)GY5TdzsGmjkIKxKmmqI9XpOmIefizeK8IeLK4Qz7dBhRL62TbLw6JBM5qaO0wnDdPrOPdTuU8addRPhTu71lFTRL(MKG)CgzRPvrC28l)Ihh6DHijbsyCZ2)Y5TdzsusYBsSaGbgGVIwp3LnECO3fIKeirrjsYWajwaWadWxrlOWcgZ59HZi1(6ffpo07crscKOOej5fjddK8Me7JFqzejkqcKirjjhBF8dkN3oKjbYKOisErYWaj2h)GYisuGKrqYlsusIRMTpSDSwQB3guAPZVXKdbGsB10nKWvnDOLYLhyyyn9OLcZi71QBdkTuiqaMscOiXcRL62TbLwkE)UgCzWmZMFXARMUHKI00HwkxEGHH10JwQB3guAPO1VzFSwkmJSxRUnO0s1fets663SpMKfqI6bSKKcm(rcMAnTkIjbCKG)Hls6IeqzWGKr6x(rcMAnTkIjXlys(iMeiqaMsI6bSis6jjDrYi9l)ibtTMwfXAP2Rx(AxlLTMwfXXUYMF5hjddKWwtRI4icy8lxmUxsggiHTMwfXrVWixmUxsggij4pNr8(Dn4YGzMn)IJFvsussWFoJS10QioB(LFXVkjddK8MKG)CgTEUlB84qVlejqMe3UnOI4pFFImUz7F582Hmjkjj4pNrRN7Yg)QK8sB10nKGWA6ql1TBdkTu8NVpAPC5bggwtpARMUHeUqthAPC5bggwtpAPUDBqPLE)k72Tbv20Ovl10OnxEiRLoDJzFUV2QTAPoG10HMU1xthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zT03Ke8NZ42HmEWvz4J9WGUG5lECO3fIeitculCm0XnjJssIr9jzyGKG)Cg3oKXdUkdFShg0fmFXJd9UqKazsC72GkIw)M9Xrg3S9VCE7qMKrjjXO(KOKK3KWwtRI4yxzZV8JKHbsyRPvrCebm(Llg3ljddKWwtRI4OxyKlg3ljVi5fjkjj4pNXTdz8GRYWh7HbDbZx8RsIssUFXtWbLJBhY4bxLHp2dd6cMVidH(TQkdRLcZi71QBdkTuC6g734lJib)dVp8rY(WKOyp2dT(AF4JKG)Csc(2yiz6gdjG5Ke89(0fj7dtsX4EjX6OvlfRF5YdzTu4J9Wm(2yYt3yYG5uB10nK00HwkxEGHH10JwkqvlfXRwQB3guAPy9R9adRLI1nFwlnjsyRPvrCSRmcy8JeLK8MeKkBm51pO8IIO1VzFmjjqIIirjjRB4AJiW3KbZ8(W5j4y0g5YdmmmjddKGuzJjV(bLxueT(n7JjjbsWfK8slfMr2Rv3guAP40n2VXxgrc(hEF4JK01p0)GYK0isWdU9HeRJ2UGscalFKKU(n7JjPlsgPF5hjyQ10QiwlfRF5YdzT0gAbooJw)q)dkRTA6EeA6qlLlpWWWA6rl1TBdkTulOWcgZ59HZi1(6fPLcZi71QBdkTuDbXKGtqHfmMjb)dxK4ljggHizF8IefLij6enYK4fmjMUys(QKGV3hsWPoHOIxwTu71lFTRL(MeS(1EGHJwqHfmMZWmcJYsIsssIelayGb4RO1ZDzJh7WyqYWajb)5mA9Cx24xLKxKOKK3K4O9CtwfGNpsGmjkkrsggibRFThy4ydTahNrRFO)bLj5fjkj5njb)5mYwtRI4S5x(fpo07crscKaHjzyGKG)CgzRPvrCgbm(fpo07crscKaHj5fjkj5njjrY9lEcoOCmWnEz5myMDJjVpDbff5YdmmmjddKe8NZyGB8YYzWm7gtEF6ckkx((poIw3oMKeizeKmmqsWFoJbUXllNbZSBm59PlOOSFwV4iAD7yssGKrqYlsggijaGqKOKKzd9zZhh6DHibYKOFIARMUXvnDOLYLhyyyn9OL62TbLw65y5c8r55XLEHHwkmJSxRUnO0s1fetIE74sVWGe89(qco1jev8YQLAVE5RDT0G)CgTEUlB84qVlejjqI(ksB10TI00HwkxEGHH10JwQB3guAPOFn7J1sTyynCE9dkVinDRVwQ96LV21sFtYXZJrpEGHjzyGKG)CgzRPvrCgbm(fpo07crcKjzeKOKe2AAveh7kJag)irjjhh6DHibYKOpUsIssw3W1grGVjdM59HZtWXOnYLhyyysErIssw)GYBC7qoVGmCZKKaj6JRKORjbPYgtE9dkVisgLKJd9UqKOKK3KWwtRI4yxzVWGKHbsoo07crcKjbQfog64MKxAPWmYET62GslvxqmjP)A2htsxKO6fmh2wsafjEHX(0fus2hFjX0yzej6JRi2IiXlysmmcrc(EFijeCmjRFq5frIxWK4lj7dtcxWKaMK4KKcm(rcMAnTkIjXxs0hxjbXwejGJedJqKCCO3vxqjXrKSaskWsYJJTlOKSasoEEm6He4)1fusgPF5hjyQ10QiwB10newthAPC5bggwtpAPUDBqPLIw)MUXOLcZi71QBdkTumlmRsYxLK01VPBmK4ljUXqY2HmIKFzyeIKpQlOKmsyy9ZrK4fmj9ssJiXda)LKfqI6bSKaosm8sY(WKGuzB7gsC72GIetxmjbSbGNKhVGnmjk2J9WGUG5JeqrcKiz9dkViTu71lFTRL(MKG)CgrRFt3yIhppg94bgMeLK8MeKkBm51pO8IIO1VPBmKazsgbjddKKej3V4j4GYXTdz8GRYWh7HbDbZxKHq)wvLHj5fjddKSUHRnIaFtgmZ7dNNGJrBKlpWWWKOKKG)CgzRPvrCgbm(fpo07crcKjzeKOKe2AAveh7kJag)irjjb)5mIw)MUXepo07crcKjbxqIssqQSXKx)GYlkIw)MUXqsckqcUsYlsusYBssIK7x8eCq5ObdRFokpnmVDbnd10HQioYqOFRQYWKmmqY2Hmj4ssWvfrscKe8NZiA9B6gt84qVlejJscKi5fjkjz9dkVXTd58cYWntscKOiTvt34cnDOLYLhyyyn9OL62TbLwkA9B6gJwkmJSxRUnO0sHa79Hef7XEyqxW8rYhXKKU(nDJHKfqYyMvj5RsY(WKe8NtscWGe3GaK8rDbLK01VPBmKaksueji2ckyejGJedJqKCCO3vxq1sTxV81Uw69lEcoOCC7qgp4Qm8XEyqxW8fzi0VvvzysuscsLnM86huErr0630ngssqbsgbjkj5njjrsWFoJBhY4bxLHp2dd6cMV4xLeLKe8NZiA9B6gt845XOhpWWKmmqYBsW6x7bgocFShMX3gtE6gtgmNKOKK3Ke8NZiA9B6gt84qVlejqMKrqYWajiv2yYRFq5ffrRFt3yijbsGejkjzDdxBeTSX4xg(65g5Ydmmmjkjj4pNr0630nM4XHExisGmjkIKxK8IKxARMUvmA6qlLlpWWWA6rlfOQLI4vl1TBdkTuS(1EGH1sX6MpRL6O9CtwfGNpssGeftIKORj5nj6Nijygsc(ZzC7qgp4Qm8XEyqxW8frRBhtYls01K8MKG)CgrRFt3yIhh6DHibZqYiibIKGuzJj)4OLj5fj6AsEtcmyJZ)HrgmZS5xC84qVlejygsuejVirjjb)5mIw)MUXe)QAPWmYET62GslfNUX(n(YisW)W7dFK4KKU(H(huMKpIjbFBmKy9pIjjD9B6gdjlGKPBmKaMtCqIxWK8rmjPRFO)bLjzbKmMzvsuSh7HbDbZhjO1TJj5RQLI1VC5HSwkA9B6gtgpO280nMmyo1wnDdb10HwkxEGHH10JwQB3guAPO1p0)GYAPWmYET62GslvxqmjPRFO)bLjbFVpKOyp2dd6cMpswajJzwLKVkj7dtsWFojbFVpG)sIbG6ckjPRFt3yi5RUDitIxWK8rmjPRFO)bLjbuKGRJsIEa6uhKGw3ogrYV22qcUsY6huErAP2Rx(AxlfRFThy4i8XEygFBm5PBmzWCsIssW6x7bgoIw)MUXKXdQnpDJjdMtsusssKG1V2dmCSHwGJZO1p0)GYKmmqYBsc(ZzmWnEz5myMDJjVpDbfLlF)hhrRBhtscKmcsggij4pNXa34LLZGz2nM8(0fuu2pRxCeTUDmjjqYii5fjkjbPYgtE9dkVOiA9B6gdjqMeCLeLKG1V2dmCeT(nDJjJhuBE6gtgmNARMU1prnDOLYLhyyyn9OL62TbLwQd7QBJLZi8(fQLAXWA486huErA6wFTu71lFTRLMejBBh3fususssK42Tbv0HD1TXYzeE)cZWEOdLJDLNMg6ZsYWajWGn6WU62y5mcVFHzyp0HYr062XKazsgbjkjbgSrh2v3glNr49lmd7HouoECO3fIeitYi0sHzK9A1TbLwQUGysq49lKeeGK9XxsWa8jbkVKe64MKV62HmjbyqYh1fus6LehrIXxMehrIkaH6adtcOiXWiej7JxKmcsqRBhJibCKabWhTKG)HlsgXOKGw3ogrcJB1(yTvt36RVMo0s5YdmmSME0sD72GslneaQzFSwQfdRHZRFq5fPPB91sTxV81Uw6XZJrpEGHjrjjRFq5nUDiNxqgUzssGK3K8Me9XvsgLK3KGuzJjV(bLxueT(n7JjbZqcKibZqsWFoJS10QioB(LFXVkjVi5fjJsYXHExisErcej5nj6tYOKSUHRnU47khcafkYLhyyysErIssEtIfamWa8v065USXJDymirjjjrc89B4ybYwyejkj5njy9R9adhTGclymNHzegLLKHbsSaGbgGVIwqHfmMZ7dNrQ91lkESdJbjddKKejwawU8AJvd9zZtNj5fjddKGuzJjV(bLxueT(n7JjbYK8MK3KaHjrxtYBsc(ZzKTMwfXzZV8l(vjbZqcKi5fjVibZqYBs0NKrjzDdxBCX3voeakuKlpWWWK8IKxKOKKKiHTMwfXreW4xUyCVKmmqYBsyRPvrCSRmcy8JKHbsEtcBnTkIJDLda7djddKWwtRI4yxzZV8JKxKOKKKizDdxBeb(MmyM3hopbhJ2ixEGHHjzyGKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjjOajqsrjsYlsusYBsqQSXKx)GYlkIw)M9XKazs0prsWmK8Me9jzusw3W1gx8DLdbGcf5YdmmmjVi5fjkjXr75MSkapFKKajkkrs01Ke8NZiA9B6gt84qVlejygsGWK8IeLK8MKKij4pNXXDbFmCMdvb45lKRnZfFqB9IJFvsggiHTMwfXXUYiGXpsggijjsSaSC51ghJX1ErYlTuygzVwDBqPLQRYZJrpKORaa1SpMKEsco1jev8YssJi5yhgdCqY(WhtIFmjggHizF8IefrY6huErK0fjJ0V8Jem1AAvetc(EFijfS6nCqIHris2hVir)ejbSp8HVrmjDrIxyqcMAnTkIjbCK8vjzbKOisw)GYlIKaEcoMeNKr6x(rcMAnTkIJKOybfMVKC88y0djW)RlOKGzPl4JHjbtdvb45lKRLKFzyeIKUijfy8Jem1AAveRTA6wFiPPdTuU8addRPhTu3UnO0sNGZYzWmx((pwlfMr2Rv3guAP6cIjrVb0njGIelmj479b8xsSUQAxq1sTxV81UwQRMTpSDS2QPB9hHMo0s5YdmmSME0sD72Gsl1YggTTBYUPHwHCTAPWmYET62Gslvxqmj4uNquXlljGIelmj)YWiejEbtIPlMKEj5Rsc(EFibNGclymRLAVE5RDT0Kib((nCSazlmIeLKG1V2dmC0cNTGcU3guKOKK3Ke8NZiA9B6gt8RsYWajoAp3Kvb45JKeirrjsYlsusYBssIKG)CgradABlh)QKOKKKij4pNrRN7Yg)QKOKK3KKejwawU8AJvd9zZtNjzyGelayGb4ROfuybJ58(WzKAF9IIFvsusIJ2ZnzvaE(ibYKOOej5fjkjz9dkVXTd58cYWntscKOVIizusSGc(3Bu9yBJ4SBAOvixBC7qoJ1nFMKHbscaiejkjPRLpvGXxgopBOpB(4qVlejqMeiLijJsIfuW)EJQhBBeNDtdTc5AJBhYzSU5ZK8sB10T(4QMo0s5YdmmSME0sTxV81UwAsKaF)gowGSfgrIssW6x7bgoAHZwqb3BdksusYBsc(ZzeT(nDJj(vjzyGehTNBYQa88rscKOOej5fjkj5njjrsWFoJiGbTTLJFvsusssKe8NZO1ZDzJFvsusYBssIelalxETXQH(S5PZKmmqIfamWa8v0ckSGXCEF4msTVErXVkjkjXr75MSkapFKazsuuIK8IeLKS(bL342HCEbz4MjjbsGuIKmkjwqb)7nQESTrC2nn0kKRnUDiNX6MptYWajbaeIeLK01YNkW4ldNNn0NnFCO3fIeitYisKKrjXck4FVr1JTnIZUPHwHCTXTd5mw38zsEPL62TbLwAxw)kFBqPTA6wFfPPdTuU8addRPhTu3UnO0s5qvaE(YbGcwlfMr2Rv3guAP6cIjbtdvb45Je9akysafjwysW37djPRFt3yi5RsIxWKGCSmjtWrYi)ni)iXlysWPoHOIxwTu71lFTRLgaqisussxlFQaJVmCE2qF28XHExisGmj6Risggi5njb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqsrjsYWajb)5mQEDi4GB3K9Z6vBZQFdYViw38zssqbsGKIsKKxKOKKG)CgrRFt3yIFvsusYBsSaGbgGVIwp3LnECO3fIKeirrjsYWajW3VHJfiBHrK8sB10T(qynDOLYLhyyyn9OL62TbLwkAzJXV804hRLAXWA486huErA6wFTu71lFTRLE88y0JhyysusY2HCEbz4Mjjbs0xrKOKeKkBm51pO8IIO1VzFmjqMeCLeLK4Qz7dBhtIssEtsWFoJwp3LnECO3fIKeir)ejzyGKKij4pNrRN7Yg)QK8slfMr2Rv3guAP6Q88y0djtJFmjGIKVkjlGKrqY6huErKGV3hWFjbN6eIkEzjjG7ckjEa4VKSasyCR2htIxWKuGLeaw(SUQAxq1wnDRpUqthAPC5bggwtpAPUDBqPLo)hgzWmZMFXAPWmYET62Gslvxqmj6naMsspjPludZK4fjyQ10QiMeVGjX0ftsVK8vjbFVpK4KmYFdYpsupGLeVGjrNWU62yzssX7xOwQ96LV21szRPvrCSRSxyqIssC1S9HTJjrjjb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqsrjsIssEtcmyJoSRUnwoJW7xyg2dDOCCB74UGsYWajjrIfGLlV2yX2dyahmjddKGuzJjV(bLxejjqcKi5L2QPB9vmA6qlLlpWWWA6rl1TBdkTu0630ngTuygzVwDBqPLQliMeNK01VPBmKabS49He1dyj5xggHijD9B6gdjnIe3CSdJbjFvsahjya(K4htIha(ljlGeaw(SUkj6enYAP2Rx(Axln4pNrqX7dkRYNLv3guXVkjkj5njb)5mIw)MUXepEEm6XdmmjddK4O9CtwfGNpssGeiyIK8sB10T(qqnDOLYLhyyyn9OL62TbLwkA9B6gJwkmJSxRUnO0svS)qvs0jAKjjGNGJjbNGclymtc(EFijD9B6gdjEbtY(WfjPRFO)bL1sTxV81UwQfGLlV2y1qF280zsusYBsW6x7bgoAbfwWyodZimkljddKybadmaFfTEUlB8RsYWajb)5mA9Cx24xLKxKOKelayGb4ROfuybJ58(WzKAF9IIhh6DHibYKa1chdDCtcMHel3gsEtIJ2ZnzvaE(ibIKOOej5fjkjj4pNr0630nM4XHExisGmj4kjkjjjsGVFdhlq2cJ0wnDdPe10HwkxEGHH10JwQ96LV21sTaSC51gRg6ZMNotIssEtcw)ApWWrlOWcgZzygHrzjzyGelayGb4RO1ZDzJFvsggij4pNrRN7Yg)QK8IeLKybadmaFfTGclymN3hoJu7Rxu84qVlejqMeimjkjj4pNr0630nM4xLeLKWwtRI4yxzVWGeLKKejy9R9adhBOf44mA9d9pOmjkjjjsGVFdhlq2cJ0sD72GslfT(H(huwB10nK0xthAPC5bggwtpAPUDBqPLIw)q)dkRLcZi71QBdkTuDbXKKU(H(huMe89(qIxKabS49He1dyjbCK0tsWa8XCysay5Z6QKOt0itc(EFibdW)iPyCVKyD0gjrNgeGe4FOkIeDIgzs8LK9HjHlysats2hMeia5AFW4ij4pNK0tssx)MUXqcEW3axy(sY0ngsaZjjGIeCLeWrIHrisw)GYlsl1E9Yx7APb)5mckEFqzRH9lJTrnOIFvsggi5njjrcA9B2hhD1S9HTJjrjjjrcw)ApWWXgAbooJw)q)dktYWajVjj4pNrRN7Ygpo07crcKjrrKOKKG)CgTEUlB8RsYWajVjj4pNXZXYf4JYZJl9cJ4XHExisGmjqTWXqh3KGziXYTHK3K4O9CtwfGNpsGijJirsErIssc(Zz8CSCb(O884sVWi(vj5fjVirjjy9R9adhrRFt3yY4b1MNUXKbZjjkjbPYgtE9dkVOiA9B6gdjqMKrqYlsusYBssIK7x8eCq542HmEWvz4J9WGUG5lYqOFRQYWKmmqcsLnM86huErr0630ngsGmjJGKxARMUHeK00HwkxEGHH10JwQB3guAPfJphcaLwkmJSxRUnO0s1fetIUcauis6IKuGXpsWuRPvrmjEbtcYXYKO3(gdj6kaqrYeCKGtDcrfVSAP2Rx(Axl9njb)5mYwtRI4mcy8lECO3fIKeiHXnB)lN3oKjzyGK3KyF8dkJirbsGejkj5y7JFq582HmjqMefrYlsggiX(4hugrIcKmcsErIssC1S9HTJ1wnDdPrOPdTuU8addRPhTu71lFTRL(MKG)CgzRPvrCgbm(fpo07crscKW4MT)LZBhYKmmqYBsSp(bLrKOajqIeLKCS9XpOCE7qMeitIIi5fjddKyF8dkJirbsgbjVirjjUA2(W2XAPUDBqPL(4MzoeakTvt3qcx10HwkxEGHH10JwQ96LV21sFtsWFoJS10QioJag)Ihh6DHijbsyCZ2)Y5TdzsusYBsSaGbgGVIwp3LnECO3fIKeirrjsYWajwaWadWxrlOWcgZ59HZi1(6ffpo07crscKOOej5fjddK8Me7JFqzejkqcKirjjhBF8dkN3oKjbYKOisErYWaj2h)GYisuGKrqYlsusIRMTpSDSwQB3guAPZVXKdbGsB10nKuKMo0s5YdmmSME0sHzK9A1TbLwQUGysGabykjGIeCQy1sD72GslfVFxdUmyMzZVyTvt3qccRPdTuU8addRPhTuGQwkIxTu3UnO0sX6x7bgwlfRB(SwksLnM86huErr063SpMKeibxjzusMga4i5njHoA5dJmw38zsWmKOFIjscejbsjsYlsgLKPbaosEtsWFoJO1p0)GYzoufGNVqU2mcy8lIw3oMeiscUsYlTuygzVwDBqPLIt3y)gFzej4F49HpswajFets663SpMKUijfy8Je8pT9HKgrIVKOisw)GYlAu9jzcosyS8HbjqkrCjjHoA5ddsahj4kjPRFO)bLjbtdvb45lKRLe062XiTuS(LlpK1srRFZ(4CxzeW4N2QPBiHl00HwkxEGHH10JwQB3guAP4pFF0sHzK9A1TbLwQUGysGapFFiPlssbg)ibtTMwfXKaos6jjfGK01VzFmj4BJHKzVK01cibN6eIkEzjXlmcbhRLAVE5RDT03KWwtRI4O5x(Llg3ljddKWwtRI4OxyKlg3ljkjbRFThy4yJYwd7yzsErIssEtY6huEJBhY5fKHBMKeibxjzyGe2AAvehn)YVCxzirYWajZg6ZMpo07crcKjr)ej5fjddKe8NZiBnTkIZiGXV4XHExisGmjUDBqfrRFZ(4iJB2(xoVDitIssc(ZzKTMwfXzeW4x8RsYWajS10Qio2vgbm(rIsssIeS(1EGHJO1VzFCURmcy8JKHbsc(Zz065USXJd9UqKazsC72GkIw)M9Xrg3S9VCE7qMeLKKejy9R9adhBu2AyhltIssc(Zz065USXJd9UqKazsyCZ2)Y5TdzsussWFoJwp3Ln(vjzyGKG)CgphlxGpkppU0lmIFvsuscsLnM8JJwMKeijXieMeLK8MeKkBm51pO8IibYkqYiizyGKKizDdxBeb(MmyM3hopbhJ2ixEGHHj5fjddKKejy9R9adhBu2AyhltIssc(Zz065USXJd9UqKKajmUz7F582HS2QPBiPy00HwkxEGHH10JwkmJSxRUnO0s1fets663SpMKEssxKms)YpsWuRPvrmoiPlssbg)ibtTMwfXKaksW1rjz9dkVisahjlGe1dyjjfy8Jem1AAveRL62TbLwkA9B2hRTA6gsqqnDOLYLhyyyn9OLcZi71QBdkTu9MBm7Z91sD72Gsl9(v2TBdQSPrRwQPrBU8qwlD6gZ(CFTvB1sNUXSp3xthA6wFnDOLYLhyyyn9OL62TbLwkA9d9pOSwkmJSxRUnO0stx)q)dktYeCKecWYHCTK8ldJqK8rDbLe9a0Po0sTxV81UwAsKC)INGdkhdCJxwodMz3yY7txqrrgc9BvvgwB10nK00HwkxEGHH10JwQB3guAPOFn7J1sTyynCE9dkVinDRVwQ96LV21sHbBmeaQzFC84qVlejjqYXHExisWmKajircejrFfJwkmJSxRUnO0sXPJws2hMeyWsc(EFizFyscbOLKTdzswajommj)ABdj7dtsOJBsG)NVnOiPrK80BKK0Fn7Jj54qVlejHFZ2QMMHjzbKe6R9HKqaOM9XKa)pFBqPTA6EeA6ql1TBdkT0qaOM9XAPC5bggwtpAR2QLIwnDOPB910HwkxEGHH10JwQB3guAPNJLlWhLNhx6fgAPWmYET62Gslvxqmj7dtceGCTpyCKGV3hsCsWPoHOIxws2hFjPrfMVKmpqijJ83G8tl1E9Yx7APb)5mA9Cx24XHExissGe9vK2QPBiPPdTuU8addRPhTu3UnO0srRFO)bL1sHzK9A1TbLwQUGyssx)q)dktYcizmZQK8vjzFysuSh7HbDbZhjb)5KKEssVKGh8nWKW4wTpMKaEcoMKzxn6PlOKSpmjfJ7LeRJwsahjlGe4FOkjb8eCmj4euybJzTu71lFTRLE)INGdkh3oKXdUkdFShg0fmFrgc9BvvgMeLK8Me2AAveh7k7fgKOKKKi5njVjj4pNXTdz8GRYWh7HbDbZx84qVlejjqIB3gur8NVprg3S9VCE7qMKrjjXO(KOKK3KWwtRI4yx5aW(qYWajS10Qio2vgbm(rYWajS10QioA(LF5IX9sYlsggij4pNXTdz8GRYWh7HbDbZx84qVlejjqIB3gur063SpoY4MT)LZBhYKmkjjg1NeLK8Me2AAveh7kB(LFKmmqcBnTkIJiGXVCX4EjzyGe2AAveh9cJCX4Ej5fjVizyGKKij4pNXTdz8GRYWh7HbDbZx8RsYlsggi5njb)5mA9Cx24xLKHbsW6x7bgoAbfwWyodZimkljVirjjwaWadWxrlOWcgZ59HZi1(6ffp2HXGeLKyby5YRnwn0NnpDMKxKOKK3KKejwawU8AJJX4AVizyGelayGb4RihQcWZxoauWXJd9UqKKajkgsErIssEtsWFoJwp3Ln(vjzyGKKiXcagya(kA9Cx24XomgK8sB109i00HwkxEGHH10JwQB3guAPoSRUnwoJW7xOwQfdRHZRFq5fPPB91sTxV81UwAsKad2Od7QBJLZi8(fMH9qhkh32oUlOKOKKKiXTBdQOd7QBJLZi8(fMH9qhkh7kpnn0NLeLK8MKKibgSrh2v3glNr49lm)WUjUTDCxqjzyGeyWgDyxDBSCgH3VW8d7M4XHExissGefrYlsggibgSrh2v3glNr49lmd7HouoIw3oMeitYiirjjWGn6WU62y5mcVFHzyp0HYXJd9UqKazsgbjkjbgSrh2v3glNr49lmd7HouoUTDCxq1sHzK9A1TbLwQUGys0jSRUnwMKu8(fsc(hUizF4JjPrKuasC72yzsq49lehK4ism(YK4isubiuhyysafji8(fsc(EFibsKaosMmE(ibTUDmIeWrcOiXjzeJsccVFHKGaKSp(sY(WKumEsq49lKe)UglJibcGpAjXNlFKSp(sccVFHKW4wTpgPTA6gx10HwkxEGHH10JwQB3guAPwqHfmMZ7dNrQ91lslfMr2Rv3guAP6cIrKGtqHfmMjPNKGtDcrfVSK0is(QKaosWa8jXpMeygHrz7ckj4uNquXllj479HeCckSGXmjEbtcgGpj(XKeWgaEsW1ejrNOrwl1E9Yx7APVjbRFThy4OfuybJ5mmJWOSKOKKKiXcagya(kA9Cx24XomgKmmqsWFoJwp3Ln(vj5fjkjXr75MSkapFKazsW1ejrjjVjj4pNr2AAveNn)YV4XHExissGe9tKKHbsc(ZzKTMwfXzeW4x84qVlejjqI(jsYlsggijaGqKOKKzd9zZhh6DHibYKOFIARMUvKMo0s5YdmmSME0sbQAPiE1sD72GslfRFThyyTuSU5ZAPVjj4pNXZXYf4JYZJl9cJ4XHExissGefrYWajjrsWFoJNJLlWhLNhx6fgXVkjVirjjVjj4pNXXDbFmCMdvb45lKRnZfFqB9IJhh6DHibYKa1chdDCtYlsusYBsc(ZzKTMwfXzeW4x84qVlejjqculCm0XnjddKe8NZiBnTkIZMF5x84qVlejjqculCm0XnjV0sHzK9A1TbLwkobfCVnOizcosCJHeyWIizF8LKqFmJib9pMK9HXGe)4cZxsoEEm6HHjb)dxKOR6y5c8rKO3oU0lmi5XrKyyeIK9Xlsueji2Ii54qVRUGsc4izFysgJX1ErsWFojPrK4bG)sYciz6gdjG5KeWrIxyqcMAnTkIjPrK4bG)sYciHXTAFSwkw)YLhYAPWGnFme63hhY1I0wnDdH10HwkxEGHH10JwQB3guAPHaqn7J1sTxV81Uw6XZJrpEGHjrjjRFq5nUDiNxqgUzssGe9Hejkj5njUA2(W2XKOKeS(1EGHJWGnFme63hhY1Ii5LwQfdRHZRFq5fPPB91wnDJl00HwkxEGHH10JwQB3guAPOFn7J1sTxV81Uw6XZJrpEGHjrjjRFq5nUDiNxqgUzssGe9Hejkj5njUA2(W2XKOKeS(1EGHJWGnFme63hhY1Ii5LwQfdRHZRFq5fPPB91wnDRy00HwkxEGHH10JwQB3guAPOLng)YtJFSwQ96LV21spEEm6Xdmmjkjz9dkVXTd58cYWntscKOpeMeLK8MexnBFy7ysuscw)ApWWryWMpgc97Jd5ArK8sl1IH1W51pO8I00T(ARMUHGA6qlLlpWWWA6rl1TBdkT0j4SCgmZLV)J1sHzK9A1TbLwQUGys0BaDtcOiXctc(EFa)LeRRQ2fuTu71lFTRL6Qz7dBhRTA6w)e10HwkxEGHH10JwQB3guAPCOkapF5aqbRLcZi71QBdkTuDbXKGzPl4JHjjvTVErKGV3hs8cdsmGckjCb(qFiX4OTlOKGPwtRIys8cMK9WGKfqIPlMKEj5Rsc(EFizK)gKFK4fmj4uNquXlRwQ96LV21sFtYBsc(ZzKTMwfXzeW4x84qVlejjqI(jsYWajb)5mYwtRI4S5x(fpo07crscKOFIK8IeLKybadmaFfTEUlB84qVlejjqYisKeLK8MKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjqMeiHRjsYWajjrY9lEcoOCu96qWb3Uj7N1R2Mv)gKFrgc9BvvgMKxK8IKHbsc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZKKGcKajCrIKmmqIfamWa8v065USXJDymirjjoAp3Kvb45JKeibcMO2QPB91xthAPC5bggwtpAPUDBqPLAzdJ22nz30qRqUwTuygzVwDBqPLQliMeCQtiQ4LLe89(qcobfwWygIyw6c(yyssv7RxejEbtcmOW8Leaw(WF9YKmYFdYpsahj4F4Ie9yaayZhTKGh8nWKW4wTpMKaEcoMeCQtiQ4LLeg3Q9XiTu71lFTRLMejW3VHJfiBHrKOKeS(1EGHJw4SfuW92GIeLK8MehTNBYQa88rscKabtKeLK8MKG)Cgh3f8XWzoufGNVqU2mx8bT1lo(vjzyGKKiXcWYLxBCmgx7fjVizyGelalxETXQH(S5PZKmmqsWFoJbgaa28rB8RsIssc(ZzmWaaWMpAJhh6DHibYKaPejzusEtYBsGGKGzi5(fpbhuoQEDi4GB3K9Z6vBZQFdYVidH(TQkdtYlsgLK3Kybf8V3O6X2gXz30qRqU242HCgRB(mjVi5fjVirjjjrsWFoJwp3Ln(vjrjjVjjjsSaSC51gRg6ZMNotYWajwaWadWxrlOWcgZ59HZi1(6ff)QKmmqsaaHirjjDT8Pcm(YW5zd9zZhh6DHibYKybadmaFfTGclymN3hoJu7Rxu84qVlejJsceMKHbs6A5tfy8LHZZg6ZMpo07crcUKe9vmjscKjbsjsYOK8MelOG)9gvp22io7MgAfY1g3oKZyDZNj5fjV0wnDRpK00HwkxEGHH10JwQ96LV21stIe473WXcKTWisuscw)ApWWrlC2ck4EBqrIssEtIJ2ZnzvaE(ijbsGGjsIssEtsWFoJJ7c(y4mhQcWZxixBMl(G26fh)QKmmqssKyby5YRnogJR9IKxKmmqIfGLlV2y1qF280zsggij4pNXadaaB(On(vjrjjb)5mgyaayZhTXJd9UqKazsgrIKmkjVj5njqqsWmKC)INGdkhvVoeCWTBY(z9QTz1Vb5xKHq)wvLHj5fjJsYBsSGc(3Bu9yBJ4SBAOvixBC7qoJ1nFMKxK8IKxKOKKKij4pNrRN7Yg)QKOKK3KKejwawU8AJvd9zZtNjzyGelayGb4ROfuybJ58(WzKAF9IIFvsggijaGqKOKKUw(ubgFz48SH(S5Jd9UqKazsSaGbgGVIwqHfmMZ7dNrQ91lkECO3fIKrjbctYWajDT8Pcm(YW5zd9zZhh6DHibxsI(kMejbYKmIejzusEtIfuW)EJQhBBeNDtdTc5AJBhYzSU5ZK8IKxAPUDBqPL2L1VY3guARMU1FeA6qlLlpWWWA6rlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLMejwaWadWxrRN7Ygp2HXGKHbssIeS(1EGHJwqHfmMZWmcJYsIssSaSC51gRg6ZMNotYWajW3VHJfiBHrAPWmYET62Gslfcq)ApWWK8rmmjGIepOn92mIK9XxsW71sYcijGjb5yzysMGJeCQtiQ4LLeeGK9Xxs2hgds8JRLe8oAzysGa4Jwsc4j4ys2houlfRF5YdzTuKJLZtWLTEUlR2QPB9XvnDOLYLhyyyn9OL62TbLw68FyKbZmB(fRLcZi71QBdkTuDbXis0BamLKEssxK4fjyQ10QiMeVGjzVMrKSasmDXK0ljFvsW37djJ83G8dhKGtDcrfVSK4fmj6e2v3gltskE)c1sTxV81UwkBnTkIJDL9cdsusIRMTpSDmjkjj4pNr1RdbhC7MSFwVABw9Bq(fX6MptcKjbs4AIKOKK3Kad2Od7QBJLZi8(fMH9qhkh32oUlOKmmqssKyby5YRnwS9agWbtYlsuscw)ApWWrKJLZtWLTEUlR2QPB9vKMo0s5YdmmSME0sD72GslfT(nDJrlfMr2Rv3guAP6cIjbcyX7djPRFt3yir9awej9KK01VPBmK0OcZxs(QAP2Rx(Axln4pNrqX7dkRYNLv3guXVkjkjj4pNr0630nM4XZJrpEGH1wnDRpewthAPC5bggwtpAP2Rx(Axln4pNr06NbCWXJd9UqKazsuejkj5njb)5mYwtRI4mcy8lECO3fIKeirrKmmqsWFoJS10QioB(LFXJd9UqKKajkIKxKOKehTNBYQa88rscKabtul1TBdkTuRxw2Kd(ZPwAWFoZLhYAPO1pd4G1wnDRpUqthAPC5bggwtpAPUDBqPLIw)MUXOLcZi71QBdkTuf7pufrIorJmjb8eCmj4euybJzs(OUGsY(WKGtqHfmMjXck4EBqrYciX(W2XK0tsWjOWcgZK0isC7(DJbds8aWFjzbKeWKyD0QLAVE5RDT01nCTr0YgJFz4RNBKlpWWWKOKeeVBxqrreWaYWxpxsussWFoJO1VPBmrya(sB10T(kgnDOLYLhyyyn9OL62TbLwkA9d9pOSwkmJSxRUnO0svS)qvejosLKaEcoMeCckSGXmjFuxqjzFysWjOWcgZKybfCVnOizbKyFy7ys6jj4euybJzsAejUD)UXGbjEa4VKSascysSoA1sTxV81UwQfGLlV2y1qF280zsuscw)ApWWrlOWcgZzygHrzjrjjwaWadWxrlOWcgZ59HZi1(6ffpo07crcKjrrKOKKKib((nCSazlmsB10T(qqnDOLYLhyyyn9OL62TbLwkA9B6gJwkmJSxRUnO0s1fets6630ngsW37djPlBm(rII965sIxWKuassx)mGdghKG)HlskajPRFt3yiPrK8vXbjya(K4htsxKms)YpsWuRPvrmjGJKfqI6bSKmYFdYpsW)WfjEaaltcemrs0jAKjbCK4WQ(2yzsq49lKKhhrIIzueBrKCCO3vxqjbCK0is6IKPPH(SAP2Rx(AxlDDdxBeTSX4xg(65g5Ydmmmjkjjjsw3W1grRFgWbh5Ydmmmjkjj4pNr0630nM4XZJrpEGHjrjjVjj4pNr2AAveNn)YV4XHExissGeimjkjHTMwfXXUYMF5hjkjj4pNr1RdbhC7MSFwVABw9Bq(fX6MptcKjbskkrsggij4pNr1RdbhC7MSFwVABw9Bq(fX6MptsckqcKuuIKOKehTNBYQa88rscKabtKKHbsGbB0HD1TXYzeE)cZWEOdLJhh6DHijbsumKmmqIB3gurh2v3glNr49lmd7Houo2vEAAOpljVirjjjrIfamWa8v065USXJDym0wnDdPe10HwkxEGHH10JwQB3guAPO1p0)GYAPWmYET62GslvxqmjPRFO)bLjbcyX7djQhWIiXlysG)HQKOt0itc(hUibN6eIkEzjbCKSpmjqaY1(GXrsWFojPrK4bG)sYciz6gdjG5KeWrcgGpMdtI1vjrNOrwl1E9Yx7APb)5mckEFqzRH9lJTrnOIFvsggij4pNXXDbFmCMdvb45lKRnZfFqB9IJFvsggij4pNrRN7Yg)QKOKK3Ke8NZ45y5c8r55XLEHr84qVlejqMeOw4yOJBsWmKy52qYBsC0EUjRcWZhjqKKrKijVirjjb)5mEowUaFuEECPxye)QKmmqssKe8NZ45y5c8r55XLEHr8RsIsssIelayGb4R45y5c8r55XLEHr8yhgdsggijjsSaSC51gXY1(GXrYlsggiXr75MSkapFKKajqWejrjjS10Qio2v2lm0wnDdj910HwkxEGHH10JwQB3guAPO1p0)GYAPWmYET62GslvhhgKSasc9Xmj7dtsaJwsatssx)mGdMKamibTUDCxqjPxs(QKaH(TDSbds6IeVWGem1AAvetsWFjzK)gKFK0OAjXda)LKfqsatI6bSwgwl1E9Yx7APRB4AJO1pd4GJC5bggMeLKKej3V4j4GYXTdz8GRYWh7HbDbZxKHq)wvLHjrjjVjj4pNr06NbCWXVkjddK4O9CtwfGNpssGeiyIK8IeLKe8NZiA9Zao4iAD7ysGmjJGeLK8MKG)CgzRPvrCgbm(f)QKmmqsWFoJS10QioB(LFXVkjVirjjb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGmjqcxKijkj5njwaWadWxrRN7Ygpo07crscKOFIKmmqssKG1V2dmC0ckSGXCgMryuwsusIfGLlV2y1qF280zsEPTA6gsqsthAPC5bggwtpAPUDBqPLIw)q)dkRLcZi71QBdkTuf7puLK01p0)GYK0fjoj4IrrSLKuGXpsWuRPvrmoibguy(sIHxs6Le1dyjzK)gKFK8EF8LKgrYJxWggMKamiH79Hps2hMK01VPBmKy6IjbCKSpmj6enYjabtKetxmjtWrs66h6Fq5x4GeyqH5ljaS8H)6LjXlsGaw8(qI6bSK4fmjgEjzFys8aawMetxmjpEbByssx)mGdwl1E9Yx7APjrY9lEcoOCC7qgp4Qm8XEyqxW8fzi0VvvzysusYBsc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZKazsGeUirsggij4pNr1RdbhC7MSFwVABw9Bq(fX6MptcKjbskkrsusY6gU2iAzJXVm81ZnYLhyyysErIssc(ZzKTMwfXzeW4x84qVlejjqcUGeLKWwtRI4yxzeW4hjkjjjsc(Zzeu8(GYQ8zz1Tbv8RsIsssIK1nCTr06NbCWrU8addtIssSaGbgGVIwp3LnECO3fIKeibxqIssEtIfamWa8vCCxWhdNrQ91lkECO3fIKeibxqYWajjrIfGLlV24ymU2lsEPTA6gsJqthAPC5bggwtpAPUDBqPLwm(CiauAPWmYET62Gslvxqmj6kaqHiPlsgPF5hjyQ10QiMeVGjb5yzsWS2nZr1BFJHeDfaOizcosWPoHOIxws8cMemlDbFmmjyAOkapFHCTAP2Rx(Axl9njb)5mYwtRI4S5x(fpo07crscKW4MT)LZBhYKmmqYBsSp(bLrKOajqIeLKCS9XpOCE7qMeitIIi5fjddKyF8dkJirbsgbjVirjjUA2(W2XKOKeS(1EGHJihlNNGlB9CxwTvt3qcx10HwkxEGHH10JwQ96LV21sFtsWFoJS10QioB(LFXJd9UqKKajmUz7F582HmjkjjjsSaSC51ghJX1ErYWajVjj4pNXXDbFmCMdvb45lKRnZfFqB9IJFvsusIfGLlV24ymU2lsErYWajVjX(4hugrIcKajsusYX2h)GY5TdzsGmjkIKxKmmqI9XpOmIefizeKmmqsWFoJwp3Ln(vj5fjkjXvZ2h2oMeLKG1V2dmCe5y58eCzRN7YQL62TbLw6JBM5qaO0wnDdjfPPdTuU8addRPhTu71lFTRL(MKG)CgzRPvrC28l)Ihh6DHijbsyCZ2)Y5TdzsusssKyby5YRnogJR9IKHbsEtsWFoJJ7c(y4mhQcWZxixBMl(G26fh)QKOKelalxETXXyCTxK8IKHbsEtI9XpOmIefibsKOKKJTp(bLZBhYKazsuejVizyGe7JFqzejkqYiizyGKG)CgTEUlB8RsYlsusIRMTpSDmjkjbRFThy4iYXY5j4Ywp3Lvl1TBdkT053yYHaqPTA6gsqynDOLYLhyyyn9OLcZi71QBdkTuDbXKabcWusafjwyTu3UnO0sX731GldMz28lwB10nKWfA6qlLlpWWWA6rl1TBdkTu063SpwlfMr2Rv3guAP6cIjjD9B2htYcir9awssbg)ibtTMwfX4GeCQtiQ4LLKhhrIHris2oKjzF8IeNeiWZ3hsyCZ2)YKy45sc4ibugmizK(LFKGPwtRIysAejFvTu71lFTRLYwtRI4yxzZV8JKHbsyRPvrCebm(Llg3ljddKWwtRI4OxyKlg3ljddKe8NZiE)UgCzWmZMFXXVkjkjj4pNr2AAveNn)YV4xLKHbsEtsWFoJwp3LnECO3fIeitIB3gur8NVprg3S9VCE7qMeLKe8NZO1ZDzJFvsEPTA6gskgnDOLYLhyyyn9OLcZi71QBdkTuDbXKabE((qcyF4dFJysW)02hsAejDrskW4hjyQ10QighKGtDcrfVSKaoswajQhWsYi9l)ibtTMwfXAPUDBqPLI)89rB10nKGGA6qlLlpWWWA6rlfMr2Rv3guAP6n3y2N7RL62TbLw69RSB3guztJwTutJ2C5HSw60nM95(AR2QLQESfeg4RMo00T(A6ql1TBdkT0XDbFmCgP2xViTuU8addRPhTvt3qsthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zT0e1sHzK9A1TbLwQoEysW6x7bgMKgrcIxswajjsc(EFiPaKGwFjbuK8rmj711yEr4Ge9jb)dxKSpmjZ(qljGIjPrKaks(ighKajs6jj7dtcITGcMKgrIxWKmcs6jjbG9He)yTuS(LlpK1sbv(J48EDnMxTvt3JqthAPC5bggwtpAPavTuhgwl1TBdkTuS(1EGH1sX6MpRLQVwQ96LV21s3RRX8gx9JFKhyysusYEDnM34QF0cagya(kc)pFBqPLI1VC5HSwkOYFeN3RRX8QTA6gx10HwkxEGHH10Jwkqvl1HH1sD72GslfRFThyyTuSU5ZAPqsl1E9Yx7AP711yEJlKIFKhyysusYEDnM34cPOfamWa8ve(F(2GslfRF5YdzTuqL)ioVxxJ5vB10TI00HwQB3guAPHaqnUR8eCHAPC5bggwtpARMUHWA6qlLlpWWWA6rl1TBdkTu8NVpAPMU4Sfwlv)e1sTxV81Uw6BsyRPvrC08l)YfJ7LKHbsyRPvrCSRS5x(rYWajS10Qio2voaSpKmmqcBnTkIJEHrUyCVK8slfMr2Rv3guAPJ8XwhTKajsGapFFiXlysCssx)q)dktcOijvhKGV3hs0Dd9zjrV5mjEbtIEa6uhKaossx)M9XKa2h(W3iwB10nUqthAPC5bggwtpAP2Rx(Axl9njS10QioA(LF5IX9sYWajS10Qio2v28l)izyGe2AAveh7kha2hsggiHTMwfXrVWixmUxsErIssupgBu)i(Z3hsusssKOEm2iKI4pFF0sD72Gslf)57J2QPBfJMo0s5YdmmSME0sTxV81UwAsKC)INGdkhdCJxwodMz3yY7txqrrU8addtYWajjrIfGLlV2y1qF280zsggijjsqQSXKx)GYlkIw)MUXqIcKOpjddKKejRB4AJLV)Jr5a34LLJC5bggwl1TBdkTu063SpwB10neuthAPC5bggwtpAP2Rx(Axl9(fpbhuog4gVSCgmZUXK3NUGIIC5bggMeLKyby5YRnwn0NnpDMeLKGuzJjV(bLxueT(nDJHefirFTu3UnO0srRFO)bL1wTvB1sXYhQbLMUHuIqs)eHK(JqlfVFvxqrAPqG6uxv3kUUXSsVtcj64HjPdvb3sYeCKG5W80)MfZj5yi0VpgMeeiKjX)li0xgMe7JxqzuKsEK6IjbcR3jbNGclFldtsAhItsqyuRJBsWLKSasgPVtcCJTrnOibOYNVGJK3q8fjVHeUFfPKhPUys0xF9oj4euy5BzysW87x8eCq5iMnMtYcibZVFXtWbLJy2rU8addJ5K8wFC)ksjpsDXKOV(6DsWjOWY3YWKG5711yEJ6hXSXCswajy(EDnM34QFeZgZj5T(4(vKsEK6IjrFiP3jbNGclFldtcMF)INGdkhXSXCswajy(9lEcoOCeZoYLhyyymNK36J7xrk5rQlMe9HKENeCckS8Tmmjy(EDnM3O(rmBmNKfqcMVxxJ5nU6hXSXCsERpUFfPKhPUys0hs6DsWjOWY3YWKG5711yEJqkIzJ5KSasW896AmVXfsrmBmNK36J7xrk5rQlMe9hHENeCckS8Tmmjy(9lEcoOCeZgZjzbKG53V4j4GYrm7ixEGHHXCsEdjC)ksjtjdbQtDvDR46gZk9ojKOJhMKoufCljtWrcMRESfeg4lMtYXqOFFmmjiqitI)xqOVmmj2hVGYOiL8i1ftYi07KGtqHLVLHjbZ3RRX8g1pIzJ5KSasW896AmVXv)iMnMtYBiH7xrk5rQlMeCvVtcobfw(wgMemFVUgZBesrmBmNKfqcMVxxJ5nUqkIzJ5K8gs4(vKsEK6IjrXO3jbNGclFldtcMF)INGdkhXSXCswajy(9lEcoOCeZoYLhyyymNK36J7xrk5rQlMeiOENeCckS8Tmmjy(9lEcoOCeZgZjzbKG53V4j4GYrm7ixEGHHXCsERpUFfPKPKHa1PUQUvCDJzLENes0XdtshQcULKj4ibZDaJ5KCme63hdtcceYK4)fe6ldtI9XlOmksjpsDXKmc9oj4euy5BzysW87x8eCq5iMnMtYcibZVFXtWbLJy2rU8addJ5K8wFC)ksjpsDXKaH17KGtqHLVLHjjTdXjjimQ1Xnj4sCjjlGKr67KecG)MpIeGkF(cosEJlFrYB9X9RiL8i1ftIIrVtcobfw(wgMK0oeNKGWOwh3KGljzbKmsFNe4gBJAqrcqLpFbhjVH4lsERpUFfPKhPUys0xF9oj4euy5Bzyss7qCsccJADCtcUKKfqYi9DsGBSnQbfjav(8fCK8gIVi5T(4(vKsEK6IjrFiOENeCckS8TmmjPDiojbHrToUjbxsYcizK(ojWn2g1GIeGkF(cosEdXxK8wFC)ksjpsDXKaj917KGtqHLVLHjjTdXjjimQ1Xnj4sswajJ03jbUX2OguKau5ZxWrYBi(IK36J7xrk5rQlMeibH17KGtqHLVLHjjTdXjjimQ1Xnj4sswajJ03jbUX2OguKau5ZxWrYBi(IK3qc3VIuYuYqG6uxv3kUUXSsVtcj64HjPdvb3sYeCKG5t3y2N7J5KCme63hdtcceYK4)fe6ldtI9XlOmksjpsDXKaj9oj4euy5Bzyss7qCsccJADCtcUKKfqYi9DsGBSnQbfjav(8fCK8gIVi5T(4(vKsMsgcuN6Q6wX1nMv6DsirhpmjDOk4wsMGJemhTyojhdH(9XWKGaHmj(FbH(YWKyF8ckJIuYJuxmj6RVENeCckS8TmmjPDiojbHrToUjbxIljzbKmsFNKqa838rKau5ZxWrYBC5lsERpUFfPKhPUys0hs6DsWjOWY3YWKK2H4Keeg164MeCjUKKfqYi9DscbWFZhrcqLpFbhjVXLVi5T(4(vKsEK6IjbsjQ3jbNGclFldtsAhItsqyuRJBsWLKSasgPVtcCJTrnOibOYNVGJK3q8fjV1h3VIuYuYqG6uxv3kUUXSsVtcj64HjPdvb3sYeCKG5baFXCsogc97JHjbbczs8)cc9LHjX(4fugfPKhPUys0hcQ3jbNGclFldtsAhItsqyuRJBsWLKSasgPVtcCJTrnOibOYNVGJK3q8fjVhbUFfPKhPUysGuI6DsWjOWY3YWKK2H4Keeg164MeCjjlGKr67Ka3yBudksaQ85l4i5neFrYB9X9RiLmLSIhQcULHjbctIB3guKyA0IIuYAPQhy2gwlftWes0JB8YYKOyVFdtjJjycj6k(zFibxGdsGuIqsFkzkzmbtibNpEbLr6DkzmbtirxtIoHHzyssbg)irpShgPKXemHeDnj48XlOmmjRFq5n3tsSoIrKSasSyynCE9dkVOiLmMGjKORjrxLdbyzys(vXwgH8ddsW6x7bggrY7oYrCqI6XyZO1p0)GYKORtGe1JXgrRFO)bLFfPKXemHeDnj6elOHjr9yRJ2UGsce457dj9KKEXCej7dtc(duqjbtTMwfXrkzmbtirxtIUIpMjbNGclymtY(WKKQ2xVisCsm9UgMKqWXKmnmU7adtY7EscgGpjpoCH5ljp9ssVKG6WVz9IbFKbdsW37dj6bcOo1bjJscozdJ22nKOttdTc5AXbj9I5WKGg3QVIuYycMqIUMeDfFmtsiaTKG5Zg6ZMpo07cH5KGSC5xdqK4QQgmizbKeaqisMn0NfrcOmyePKPKD72Gcfvp2ccd8vHXDbFmCgP2xVikzmHeD8WKG1V2dmmjnIeeVKSassKe89(qsbibT(scOi5Jys2RRX8IWbj6tc(hUizFysM9HwsaftsJibuK8rmoibsK0ts2hMeeBbfmjnIeVGjzeK0tsca7dj(XuYUDBqHIQhBbHb(oQcqeRFThyyCuEiRaOYFeN3RRX8IdSU5ZkKiLSB3guOO6XwqyGVJQaeX6x7bgghLhYkaQ8hX596AmV4aOQGddJdSU5ZkOpo6Pc711yEJ6h)ipWWk3RRX8g1pAbadmaFfH)NVnOOKD72Gcfvp2ccd8DufGiw)ApWW4O8qwbqL)ioVxxJ5fhavfCyyCG1nFwbiHJEQWEDnM3iKIFKhyyL711yEJqkAbadmaFfH)NVnOOKD72Gcfvp2ccd8DufGyiauJ7kpbxiLmMqYiFS1rljqIeiWZ3hs8cMeNK01p0)GYKakss1bj479HeD3qFws0BotIxWKOhGo1bjGJK01VzFmjG9Hp8nIPKD72Gcfvp2ccd8DufGi(Z3hCy6IZwyf0prC0tfEZwtRI4O5x(Llg37WaBnTkIJDLn)YVHb2AAveh7kha2NHb2AAveh9cJCX4EFrj72TbfkQESfeg47Okar8NVp4ONk8MTMwfXrZV8lxmU3Hb2AAveh7kB(LFddS10Qio2voaSpddS10Qio6fg5IX9(sP6XyJ6hXF((Omj1JXgHue)57dLSB3guOO6XwqyGVJQaerRFZ(yC0tfs6(fpbhuog4gVSCgmZUXK3NUGIggsYcWYLxBSAOpBE68Wqsiv2yYRFq5ffrRFt3yuq)HHKw3W1glF)hJYbUXllh5YdmmmLSB3guOO6XwqyGVJQaerRFO)bLXrpv4(fpbhuog4gVSCgmZUXK3NUGIuAby5YRnwn0NnpDwjsLnM86huErr0630ngf0NsMsgtWesWuCZ2)YWKWy5dds2oKjzFysC7cosAejowVnEGHJuYUDBqHuabm(LdypKsgtijLxej6eGPKaksgXOKGV3hWFjb(65sIxWKGV3hssx)mGdMeVGjbsJscyF4dFJykz3UnOqkG1V2dmmokpKvOrzhW4aRB(Sciv2yYRFq5ffrRFt3ysqFLVtADdxBeT(zahCKlpWWWddRB4AJOLng)YWxp3ixEGHHFnmGuzJjV(bLxueT(nDJjbirjJjKKYlIeRHDSmj4F4IK01VzFmjwVi5PxsG0OKS(bLxej4FA7djnIKJnmwVwsMGJK9HjbtTMwfXKSascysupEY3XWK4fmj4FA7djZ2y4JKfqI1rlLSB3guOrvaIy9R9adJJYdzfAu2AyhlJdSU5ZkGuzJjV(bLxueT(n7JtqFkzmHeDbXKOh(q8nUlOKGV3hsWPoHOIxwsahj(C5JeCckSGXmjDrco1jev8Ysj72TbfAufGyaFi(g3fuC0tfENKfGLlV2y1qF2805HHKSaGbgGVIwqHfmMZ7dNrQ91lk(vFPm4pNrRN7Yg)QuYycjJmyjbFVpK4KGtDcrfVSKSp(ssJkmFjXjzK)gKFKOEaljGJe8pCrY(WKmBOpljnIepa8xswajCbtj72TbfAufGOkyBqHJEQqWFoJwp3LnECO3fkb9v0WqaaHuoBOpB(4qVleKHKIOKXesWPBSFJVmIe8p8(WhjFuxqjbNGclymtsbWtc(2yiXngaEsWa8jzbKG22yiX6OLK9Hjb5HmjEi4xljGjj4euybJ5rXPoHOIxwsSoAruYUDBqHgvbiI1V2dmmokpKvWckSGXCgMryuwCG1nFwbl3M3V7A5tfy8LHZZg6ZMpo07cPR1xr6AlayGb4RO1ZDzJhh6DHEHl1xXK4lfSCBE)URLpvGXxgopBOpB(4qVlKUwFfPR1hsjQRTaGbgGVIwqHfmMZ7dNrQ91lkECO3f6fUuFftIVggSaGbgGVIwp3LnECO3fkHUw(ubgFz48SH(S5Jd9UqddwaWadWxrlOWcgZ59HZi1(6ffpo07cLqxlFQaJVmCE2qF28XHExiDT(jomKKfGLlV2y1qF280zkzmHeDbXWKSasGzJJbj7dtYh5qzsatsWPoHOIxwsW)WfjFuxqjbg8dmmjGIKpIPKD72GcnQcqeRFThyyCuEiRGfoBbfCVnOWbw38zfENedH(TQkdh5qvmo2nzWbxEz5HblayGb4RihQIXXUjdo4Yllhpo07cbz9HWjQmjlayGb4RihQIXXUjdo4Yllhp2HX41WGfGLlV24ymU2lkzmHeDbXKGPHQyCSBibc4bxEzzsGuIi2IijGNGJjXjbN6eIkEzj5J4iLSB3guOrvaIFeN7LdXr5HScCOkgh7Mm4GlVSmo6PcwaWadWxrRN7Ygpo07cbziLOslayGb4ROfuybJ58(WzKAF9IIhh6DHGmKsCyiaGqkNn0NnFCO3fcYJaxqjJjKOliMKuW3y4TlOKOR(dWGeimITisc4j4ysCsWPoHOIxws(iosj72TbfAufG4hX5E5qCuEiRac8ngE3UGMVFag4ONkybadmaFfTEUlB84qVleKHWktcRFThy4OfuybJ5mmJWOSddwaWadWxrlOWcgZ59HZi1(6ffpo07cbziSsS(1EGHJwqHfmMZWmcJYomeaqiLZg6ZMpo07cbziPikz3UnOqJQae)io3lhIJYdzf6czV)6bgodH(ET)WmmJTTmo6Pcb)5mA9Cx24xLsgtirhpnIKgrItY57dFKWgpaC(YKG3XGKfqsOpMjXngsafjFetcA9LK96AmViswajbmjMUyys(QKGV3hsWPoHOIxws8cMeCckSGXmjEbtYhXKSpmjqQGjbzaljGIelmj9KKaW(qYEDnMxej(XKaks(iMe06lj711yEruYUDBqHgvbiUxxJ5vFC0tfEJ1V2dmCeu5pIZ711yEvq)HbS(1EGHJGk)rCEVUgZRcJ4LY3b)5mA9Cx24xDyWcagya(kA9Cx24XHExOrHuc711yEJ6hTaGbgGVIW)Z3gukFNKfGLlV2y1qF2805HHKW6x7bgoAbfwWyodZimk7lLjzby5YRnogJR9AyWcWYLxBSAOpBE6SsS(1EGHJwqHfmMZWmcJYQ0cagya(kAbfwWyoVpCgP2xVO4xvzswaWadWxrRN7Yg)QkF)o4pNr2AAveNn)YV4XHExOe0pXHHG)CgzRPvrCgbm(fpo07cLG(j(szs3V4j4GYXa34LLZGz2nM8(0fu0WW7G)CgdCJxwodMz3yY7txqr5Y3)Xr062XkOOHHG)CgdCJxwodMz3yY7txqrz)SEXr062XkOOxVggc(ZzCCxWhdN5qvaE(c5AZCXh0wV44x91WqaaHuoBOpB(4qVleKHuIddy9R9adhbv(J48EDnMxfsKs2TBdk0OkaX96AmVqch9ubS(1EGHJGk)rCEVUgZRcJqzs711yEJ6hp2HXiBbadmaFnm8o4pNrRN7Yg)QddwaWadWxrRN7Ygpo07cnkKsyVUgZBesrlayGb4Ri8)8TbLY3jzby5YRnwn0NnpDEyijS(1EGHJwqHfmMZWmcJY(szswawU8AJJX4AVggSaSC51gRg6ZMNoReRFThy4OfuybJ5mmJWOSkTaGbgGVIwqHfmMZ7dNrQ91lk(vvMKfamWa8v065USXVQY3Vd(ZzKTMwfXzZV8lECO3fkb9tCyi4pNr2AAveNraJFXJd9UqjOFIVuM09lEcoOCmWnEz5myMDJjVpDbfnm8o4pNXa34LLZGz2nM8(0fuuU89FCeTUDSckAyi4pNXa34LLZGz2nM8(0fuu2pRxCeTUDSck61Rxddb)5moUl4JHZCOkapFHCTzU4dARxC8RomeaqiLZg6ZMpo07cbziL4Waw)ApWWrqL)ioVxxJ5vHePKXes0feJiXngsa7dFKaks(iMKE5qejGIelmLSB3guOrvaIFeN7Ldr4ONke8NZO1ZDzJF1HblalxETXQH(S5PZkX6x7bgoAbfwWyodZimkRslayGb4ROfuybJ58(WzKAF9IIFvLjzbadmaFfTEUlB8RQ897G)CgzRPvrC28l)Ihh6DHsq)ehgc(ZzKTMwfXzeW4x84qVluc6N4lLjD)INGdkhdCJxwodMz3yY7txqrdd3V4j4GYXa34LLZGz2nM8(0fuKY3b)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJtyeddb)5mg4gVSCgmZUXK3NUGIY(z9IJO1TJtyeVEnme8NZ44UGpgoZHQa88fY1M5IpOTEXXV6WqaaHuoBOpB(4qVleKHuIuYycjkw22WmjUDBqrIPrljboIHjbuKG697BdkiAyOnIs2TBdk0OkaX7xz3UnOYMgT4O8qwbhW4aTxBxf0hh9ubS(1EGHJnk7aMs2TBdk0OkaX7xz3UnOYMgT4O8qwHaGV4aTxBxf0hh9uH7x8eCq5yGB8YYzWm7gtEF6ckkYqOFRQYWuYUDBqHgvbiE)k72Tbv20OfhLhYkGwkzkzmHeC6g734lJib)dVp8rY(WKOyp2dT(AF4JKG)Csc(2yiz6gdjG5Ke89(0fj7dtsX4EjX6OLs2TBdku0bScy9R9adJJYdzfGp2dZ4BJjpDJjdMtCG1nFwH3b)5mUDiJhCvg(ypmOly(Ihh6DHGmulCm0X9Ojg1Fyi4pNXTdz8GRYWh7HbDbZx84qVleKD72GkIw)M9Xrg3S9VCE7qE0eJ6R8nBnTkIJDLn)YVHb2AAvehraJF5IX9omWwtRI4OxyKlg37Rxkd(ZzC7qgp4Qm8XEyqxW8f)QkVFXtWbLJBhY4bxLHp2dd6cMVidH(TQkdtjJjKGt3y)gFzej4F49Hpssx)q)dktsJibp42hsSoA7ckjaS8rs663SpMKUizK(LFKGPwtRIykz3UnOqrhWJQaeX6x7bgghLhYk0qlWXz06h6FqzCG1nFwHKyRPvrCSRmcy8t5BKkBm51pO8IIO1VzFCcks56gU2ic8nzWmVpCEcogTrU8addpmGuzJjV(bLxueT(n7Jtax8Isgtirxqmj4euybJzsW)Wfj(sIHris2hVirrjsIorJmjEbtIPlMKVkj479HeCQtiQ4LLs2TBdku0b8OkarlOWcgZ59HZi1(6fHJEQWBS(1EGHJwqHfmMZWmcJYQmjlayGb4RO1ZDzJh7Wymme8NZO1ZDzJF1xkF7O9CtwfGNpiROehgW6x7bgo2qlWXz06h6Fq5xkFh8NZiBnTkIZMF5x84qVlucq4HHG)CgzRPvrCgbm(fpo07cLae(LY3jD)INGdkhdCJxwodMz3yY7txqrddb)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJtyeddb)5mg4gVSCgmZUXK3NUGIY(z9IJO1TJtyeVggcaiKYzd9zZhh6DHGS(jsjJjKOliMe92XLEHbj479HeCQtiQ4LLs2TBdku0b8OkaXZXYf4JYZJl9cdC0tfc(Zz065USXJd9UqjOVIOKXes0fets6VM9XK0fjQEbZHTLeqrIxySpDbLK9XxsmnwgrI(4kITis8cMedJqKGV3hscbhtY6huErK4fmj(sY(WKWfmjGjjojPaJFKGPwtRIys8Le9XvsqSfrc4iXWiejhh6D1fusCejlGKcSK84y7ckjlGKJNhJEib(FDbLKr6x(rcMAnTkIPKD72GcfDapQcqe9RzFmoSyynCE9dkVif0hh9uH3hppg94bgEyi4pNr2AAveNraJFXJd9UqqEekzRPvrCSRmcy8t5XHExiiRpUQCDdxBeb(MmyM3hopbhJ2ixEGHHFPC9dkVXTd58cYWnNG(4QUgPYgtE9dkVOrpo07cP8nBnTkIJDL9cJHHJd9UqqgQfog64(fLmMqcMfMvj5Rss6630ngs8Le3yiz7qgrYVmmcrYh1fusgjmS(5is8cMKEjPrK4bG)sYcir9awsahjgEjzFysqQSTDdjUDBqrIPlMKa2aWtYJxWgMef7XEyqxW8rcOibsKS(bLxeLSB3guOOd4rvaIO1VPBm4ONk8o4pNr0630nM4XZJrpEGHv(gPYgtE9dkVOiA9B6gdKhXWqs3V4j4GYXTdz8GRYWh7HbDbZxKHq)wvLHFnmSUHRnIaFtgmZ7dNNGJrBKlpWWWkd(ZzKTMwfXzeW4x84qVleKhHs2AAveh7kJag)ug8NZiA9B6gt84qVleKXfkrQSXKx)GYlkIw)MUXKGc46lLVt6(fpbhuoAWW6NJYtdZBxqZqnDOkIJme63QQm8WW2HmUexIRkkHG)CgrRFt3yIhh6DHgfsVuU(bL342HCEbz4MtqruYycjqG9(qII9ypmOly(i5Jyssx)MUXqYcizmZQK8vjzFysc(ZjjbyqIBqas(OUGss6630ngsafjkIeeBbfmIeWrIHrisoo07QlOuYUDBqHIoGhvbiIw)MUXGJEQW9lEcoOCC7qgp4Qm8XEyqxW8fzi0VvvzyLiv2yYRFq5ffrRFt3ysqHrO8Dsb)5mUDiJhCvg(ypmOly(IFvLb)5mIw)MUXepEEm6Xdm8WWBS(1EGHJWh7Hz8TXKNUXKbZPY3b)5mIw)MUXepo07cb5rmmGuzJjV(bLxueT(nDJjbiPCDdxBeTSX4xg(65g5YdmmSYG)CgrRFt3yIhh6DHGSIE96fLmMqcoDJ9B8LrKG)H3h(iXjjD9d9pOmjFetc(2yiX6Fets6630ngswajt3yibmN4GeVGj5Jyssx)q)dktYcizmZQKOyp2dd6cMpsqRBhtYxLs2TBdku0b8OkarS(1EGHXr5HScO1VPBmz8GAZt3yYG5ehyDZNvWr75MSkapFjOysux)w)eXmb)5mUDiJhCvg(ypmOly(IO1TJFPRFh8NZiA9B6gt84qVleMze4sKkBm5hhT8lD9ByWgN)dJmyMzZV44XHEximJIEPm4pNr0630nM4xLsgtirxqmjPRFO)bLjbFVpKOyp2dd6cMpswajJzwLKVkj7dtsWFojbFVpG)sIbG6ckjPRFt3yi5RUDitIxWK8rmjPRFO)bLjbuKGRJsIEa6uhKGw3ogrYV22qcUsY6huEruYUDBqHIoGhvbiIw)q)dkJJEQaw)ApWWr4J9Wm(2yYt3yYG5ujw)ApWWr0630nMmEqT5PBmzWCQmjS(1EGHJn0cCCgT(H(huEy4DWFoJbUXllNbZSBm59PlOOC57)4iAD74egXWqWFoJbUXllNbZSBm59PlOOSFwV4iAD74egXlLiv2yYRFq5ffrRFt3yGmUQeRFThy4iA9B6gtgpO280nMmyoPKXes0fetccVFHKGaKSp(scgGpjq5LKqh3K8v3oKjjads(OUGssVK4ism(YK4isubiuhyysafjggHizF8IKrqcAD7yejGJeia(OLe8pCrYigLe062XisyCR2htj72Tbfk6aEufGOd7QBJLZi8(fIdlgwdNx)GYlsb9XrpviPTTJ7cQYKC72Gk6WU62y5mcVFHzyp0HYXUYttd9zhgGbB0HD1TXYzeE)cZWEOdLJO1TJH8iucd2Od7QBJLZi8(fMH9qhkhpo07cb5rqjJjKORYZJrpKORaa1SpMKEsco1jev8YssJi5yhgdCqY(WhtIFmjggHizF8IefrY6huErK0fjJ0V8Jem1AAvetc(EFijfS6nCqIHris2hVir)ejbSp8HVrmjDrIxyqcMAnTkIjbCK8vjzbKOisw)GYlIKaEcoMeNKr6x(rcMAnTkIJKOybfMVKC88y0djW)RlOKGzPl4JHjbtdvb45lKRLKFzyeIKUijfy8Jem1AAvetj72Tbfk6aEufGyiauZ(yCyXWA486huErkOpo6Pchppg94bgw56huEJBhY5fKHBoH3V1hxh9nsLnM86huErr063SpgZajmtWFoJS10QioB(LFXV6RxJECO3f6fU8T(JUUHRnU47khcafkYLhyy4xkFBbadmaFfTEUlB8yhgdLjbF)gowGSfgP8nw)ApWWrlOWcgZzygHrzhgSaGbgGVIwqHfmMZ7dNrQ91lkESdJXWqswawU8AJvd9zZtNFnmGuzJjV(bLxueT(n7JH873qyD97G)CgzRPvrC28l)IFvmdKE9cZ8w)rx3W1gx8DLdbGcf5Ydmm8RxktITMwfXreW4xUyCVddVzRPvrCSRmcy8By4nBnTkIJDLda7ZWaBnTkIJDLn)YVxktADdxBeb(MmyM3hopbhJ2ixEGHHhgc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZjOaKuuIVu(gPYgtE9dkVOiA9B2hdz9teZ8w)rx3W1gx8DLdbGcf5Ydmm8RxkD0EUjRcWZxckkrDDWFoJO1VPBmXJd9Uqygi8lLVtk4pNXXDbFmCMdvb45lKRnZfFqB9IJF1Hb2AAveh7kJag)ggsYcWYLxBCmgx71lkzmHeDbXKO3a6MeqrIfMe89(a(ljwxvTlOuYUDBqHIoGhvbiobNLZGzU89Fmo6PcUA2(W2XuYycj6cIjbN6eIkEzjbuKyHj5xggHiXlysmDXK0ljFvsW37dj4euybJzkz3UnOqrhWJQaeTSHrB7MSBAOvixlo6PcjbF)gowGSfgPeRFThy4OfoBbfCVnOu(o4pNr0630nM4xDyWr75MSkapFjOOeFP8Dsb)5mIag02wo(vvMuWFoJwp3Ln(vv(ojlalxETXQH(S5PZddwaWadWxrlOWcgZ59HZi1(6ff)QkD0EUjRcWZhKvuIVuU(bL342HCEbz4MtqFfnQfuW)EJQhBBeNDtdTc5AJBhYzSU5ZddbaeszxlFQaJVmCE2qF28XHExiidPeh1ck4FVr1JTnIZUPHwHCTXTd5mw385xuYUDBqHIoGhvbi2L1VY3gu4ONkKe89B4ybYwyKsS(1EGHJw4SfuW92Gs57G)CgrRFt3yIF1HbhTNBYQa88LGIs8LY3jf8NZicyqBB54xvzsb)5mA9Cx24xv57KSaSC51gRg6ZMNopmybadmaFfTGclymN3hoJu7Rxu8RQ0r75MSkapFqwrj(s56huEJBhY5fKHBobiL4Owqb)7nQESTrC2nn0kKRnUDiNX6MppmeaqiLDT8Pcm(YW5zd9zZhh6DHG8isCulOG)9gvp22io7MgAfY1g3oKZyDZNFrjJjKOliMemnufGNps0dOGjbuKyHjbFVpKKU(nDJHKVkjEbtcYXYKmbhjJ83G8JeVGjbN6eIkEzPKD72GcfDapQcqKdvb45lhakyC0tfcaiKYUw(ubgFz48SH(S5Jd9UqqwFfnm8o4pNr1RdbhC7MSFwVABw9Bq(fX6MpdziPOehgc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZjOaKuuIVug8NZiA9B6gt8RQ8TfamWa8v065USXJd9UqjOOehgGVFdhlq2cJErjJjKORYZJrpKmn(XKaks(QKSasgbjRFq5frc(EFa)LeCQtiQ4LLKaUlOK4bG)sYciHXTAFmjEbtsbwsay5Z6QQDbLs2TBdku0b8Okar0YgJF5PXpghwmSgoV(bLxKc6JJEQWXZJrpEGHvUDiNxqgU5e0xrkrQSXKx)GYlkIw)M9Xqgxv6Qz7dBhR8DWFoJwp3LnECO3fkb9tCyiPG)CgTEUlB8R(Isgtirxqmj6naMsspjPludZK4fjyQ10QiMeVGjX0ftsVK8vjbFVpK4KmYFdYpsupGLeVGjrNWU62yzssX7xiLSB3guOOd4rvaIZ)HrgmZS5xmo6PcS10Qio2v2lmu6Qz7dBhRm4pNr1RdbhC7MSFwVABw9Bq(fX6MpdziPOev(ggSrh2v3glNr49lmd7HouoUTDCxqhgsYcWYLxBSy7bmGdEyaPYgtE9dkVOeG0lkzmHeDbXK4KKU(nDJHeiGfVpKOEalj)YWiejPRFt3yiPrK4MJDymi5Rsc4ibdWNe)ys8aWFjzbKaWYN1vjrNOrMs2TBdku0b8Okar0630ngC0tfc(Zzeu8(GYQ8zz1Tbv8RQ8DWFoJO1VPBmXJNhJE8adpm4O9CtwfGNVeGGj(IsgtirX(dvjrNOrMKaEcoMeCckSGXmj479HK01VPBmK4fmj7dxKKU(H(huMs2TBdku0b8Okar0630ngC0tfSaSC51gRg6ZMNoR8nw)ApWWrlOWcgZzygHrzhgSaGbgGVIwp3Ln(vhgc(Zz065USXV6lLwaWadWxrlOWcgZ59HZi1(6ffpo07cbzOw4yOJBmJLBZBhTNBYQa88HlvuIVug8NZiA9B6gt84qVleKXvLjbF)gowGSfgrj72Tbfk6aEufGiA9d9pOmo6PcwawU8AJvd9zZtNv(gRFThy4OfuybJ5mmJWOSddwaWadWxrRN7Yg)Qddb)5mA9Cx24x9LslayGb4ROfuybJ58(WzKAF9IIhh6DHGmewzWFoJO1VPBmXVQs2AAveh7k7fgktcRFThy4ydTahNrRFO)bLvMe89B4ybYwyeLmMqIUGyssx)q)dktc(EFiXlsGaw8(qI6bSKaos6jjya(yomjaS8zDvs0jAKjbFVpKGb4FKumUxsSoAJKOtdcqc8pufrIorJmj(sY(WKWfmjGjj7dtceGCTpyCKe8Nts6jjPRFt3yibp4BGlmFjz6gdjG5KeqrcUsc4iXWiejRFq5frj72Tbfk6aEufGiA9d9pOmo6Pcb)5mckEFqzRH9lJTrnOIF1HH3jHw)M9XrxnBFy7yLjH1V2dmCSHwGJZO1p0)GYddVd(Zz065USXJd9Uqqwrkd(Zz065USXV6WW7G)CgphlxGpkppU0lmIhh6DHGmulCm0XnMXYT5TJ2ZnzvaE(WLJiXxkd(Zz8CSCb(O884sVWi(vF9sjw)ApWWr0630nMmEqT5PBmzWCQePYgtE9dkVOiA9B6gdKhXlLVt6(fpbhuoUDiJhCvg(ypmOly(Ime63QQm8WasLnM86huErr0630ngipIxuYycj6cIjrxbakejDrskW4hjyQ10QiMeVGjb5yzs0BFJHeDfaOizcosWPoHOIxwkz3UnOqrhWJQaelgFoeakC0tfEh8NZiBnTkIZiGXV4XHExOeyCZ2)Y5Td5HH32h)GYifGKYJTp(bLZBhYqwrVggSp(bLrkmIxkD1S9HTJPKD72GcfDapQcq8XnZCiau4ONk8o4pNr2AAveNraJFXJd9UqjW4MT)LZBhYddVTp(bLrkajLhBF8dkN3oKHSIEnmyF8dkJuyeVu6Qz7dBhtj72Tbfk6aEufG48Bm5qaOWrpv4DWFoJS10QioJag)Ihh6DHsGXnB)lN3oKv(2cagya(kA9Cx24XHExOeuuIddwaWadWxrlOWcgZ59HZi1(6ffpo07cLGIs81WWB7JFqzKcqs5X2h)GY5TdziROxdd2h)GYifgXlLUA2(W2XuYycj6cIjbceGPKaksWPILs2TBdku0b8Okar8(Dn4YGzMn)IPKXesWPBSFJVmIe8p8(WhjlGKpIjjD9B2htsxKKcm(rc(N2(qsJiXxsuejRFq5fnQ(Kmbhjmw(WGeiLiUKKqhT8HbjGJeCLK01p0)GYKGPHQa88fY1scAD7yeLSB3guOOd4rvaIy9R9adJJYdzfqRFZ(4CxzeW4hoW6MpRasLnM86huErr063SpobCD0PbaU3HoA5dJmw38zmJ(jMiUesj(A0PbaU3b)5mIw)q)dkN5qvaE(c5AZiGXViAD7yCjU(IsgtirxqmjqGNVpK0fjPaJFKGPwtRIysahj9KKcqs663SpMe8TXqYSxs6AbKGtDcrfVSK4fgHGJPKD72GcfDapQcqe)57do6PcVzRPvrC08l)YfJ7DyGTMwfXrVWixmUxLy9R9adhBu2Ayhl)s571pO8g3oKZlid3Cc46WaBnTkIJMF5xURmKggMn0NnFCO3fcY6N4RHHG)CgzRPvrCgbm(fpo07cbz3UnOIO1VzFCKXnB)lN3oKvg8NZiBnTkIZiGXV4xDyGTMwfXXUYiGXpLjH1V2dmCeT(n7JZDLraJFddb)5mA9Cx24XHExii72TbveT(n7JJmUz7F582HSYKW6x7bgo2OS1WowwzWFoJwp3LnECO3fcYmUz7F582HSYG)CgTEUlB8Rome8NZ45y5c8r55XLEHr8RQePYgt(XrlNqIriSY3iv2yYRFq5fbzfgXWqsRB4AJiW3KbZ8(W5j4y0g5Ydmm8RHHKW6x7bgo2OS1WowwzWFoJwp3LnECO3fkbg3S9VCE7qMsgtirxqmjPRFZ(ys6jjDrYi9l)ibtTMwfX4GKUijfy8Jem1AAvetcOibxhLK1pO8IibCKSasupGLKuGXpsWuRPvrmLSB3guOOd4rvaIO1VzFmLmMqIEZnM95(uYUDBqHIoGhvbiE)k72Tbv20OfhLhYkmDJzFUpLmLmMqIE74sVWGe89(qco1jev8Ysj72Tbfkga8vHZXYf4JYZJl9cdC0tfc(Zz065USXJd9UqjOVIOKXesW5dBhJiPNKSpmj6bOtDqI96LKG)CssJiPaljFvsMGJeJV8rYhXuYUDBqHIbaFhvbiI1V2dmmokpKvWE9wG9RIdSU5ZkKuWFoJbUXllNbZSBm59PlOOC57)44xvzsb)5mg4gVSCgmZUXK3NUGIY(z9IJFvkzmHeDbXKOtyxDBSmjP49lKe8pCrIVKyyeIK9XlsWvs0dqN6Ge062Xis8cMKfqYXZJrpK4KazfGejO1TJjXrKy8LjXrKOcqOoWWKaos2oKjPxsqas6Le)UglJibcGpAjXNlFK4KmIrjbTUDmjmUv7JruYUDBqHIbaFhvbi6WU62y5mcVFH4WIH1W51pO8IuqFC0tfc(ZzmWnEz5myMDJjVpDbfLlF)hhrRBhdzCvzWFoJbUXllNbZSBm59PlOOSFwV4iAD7yiJRkFNemyJoSRUnwoJW7xyg2dDOCCB74UGQmj3UnOIoSRUnwoJW7xyg2dDOCSR800qFwLVtcgSrh2v3glNr49lm)WUjUTDCxqhgGbB0HD1TXYzeE)cZpSBIhh6DHsyeVggGbB0HD1TXYzeE)cZWEOdLJO1TJH8iucd2Od7QBJLZi8(fMH9qhkhpo07cbzfPegSrh2v3glNr49lmd7HouoUTDCxqFrjJjKOliMeCckSGXmj479HeCQtiQ4LLe8pCrIkaH6adtIxWKa2h(W3iMe89(qItIEa6uhKe8NtsW)WfjWmcJY2fukz3UnOqXaGVJQaeTGclymN3hoJu7Rxeo6PcVX6x7bgoAbfwWyodZimkRYKSaGbgGVIwp3LnESdJXWqWFoJwp3Ln(vFP8DWFoJbUXllNbZSBm59PlOOC57)4iAD7yfu0WqWFoJbUXllNbZSBm59PlOOSFwV4iAD7yfu0RHHaacPC2qF28XHExiiRFIuYycj6naMsIJizFysM9HwsGAHjPls2hMeNe9a0PoibFxWa8KaosW37dj7dtcMfmU2lsc(ZjjGJe89(qItIIzueBjrNWU62yzssX7xijEbtcEVxsMGJeCQtiQ4LLKEssVKGhuljbmjFvsCOExKeWtWXKSpmjwysAejZUA0ddtj72Tbfkga8DufG48FyKbZmB(fJJEQW73b)5mg4gVSCgmZUXK3NUGIYLV)JJO1TJtaxhgc(ZzmWnEz5myMDJjVpDbfL9Z6fhrRBhNaU(s5B473WXcKTWOHblayGb4RO1ZDzJhh6DHsqrjom82cWYLxBSAOpBE6SslayGb4ROfuybJ58(WzKAF9IIhh6DHsqrj(61RHH3WGn6WU62y5mcVFHzyp0HYXJd9UqjOyuAbadmaFfTEUlB84qVluc6NOslalxETXIThWao4xddbaeszxlFQaJVmCE2qF28XHExiiRyggEBby5YRnogJR9szWFoJJ7c(y4mhQcWZxixB8R(IsgtibNEzzdjPRFgWbtc(EFiXjPy8KOhGo1bjb)5KeVGjbN6eIkEzjPrfMVK4bG)sYcijGj5Jyykz3UnOqXaGVJQaeTEzzto4pN4O8qwb06NbCW4ONk8o4pNXa34LLZGz2nM8(0fuuU89FC84qVluc4Aurddb)5mg4gVSCgmZUXK3NUGIY(z9IJhh6DHsaxJk6LY3waWadWxrRN7Ygpo07cLaUyy4TfamWa8vKdvb45lhak44XHExOeWfktk4pNXXDbFmCMdvb45lKRnZfFqB9IJFvLwawU8AJJX4AVE9sPJ2ZnzvaE(sqHrKiLmMqII9hQss66h6Fqzej479HeNe9a0Poij4pNKe8xskWsc(hUirfamDbLKj4ibN6eIkEzjbCKGzPl4JHjjvTVEruYUDBqHIbaFhvbiIw)MUXGJEQW6gU2iAzJXVm81ZnYLhyyyLiE3UGIIiGbKHVEUkd(ZzeT(nDJjcdWxuYycjk2FOkjPRFO)bLrKGV3hs2hMKaGVKe8Ntsc(ljfyjb)dxKOcaMUGsYeCKyDsahjCOkapFKeakykz3UnOqXaGVJQaerRFO)bLXrpvijS(1EGHJ2R3cSFvLVTaSC51gRg6ZMNopmybadmaFfTEUlB84qVluc4IHHKW6x7bgoAHZwqb3BdkLjzby5YRnogJR9Ay4TfamWa8vKdvb45lhak44XHExOeWfktk4pNXXDbFmCMdvb45lKRnZfFqB9IJFvLwawU8AJJX4AVE9s57KGbBC(pmYGzMn)IJBBh3f0HHKSaGbgGVIwp3LnESdJXWqswaWadWxrlOWcgZ59HZi1(6ffp2HX4fLmMqII9hQss66h6Fqzejb8eCmj4euybJzkz3UnOqXaGVJQaerRFO)bLXrpv4TfamWa8v0ckSGXCEF4msTVErXJd9Uqqwrktc((nCSazlms5BS(1EGHJwqHfmMZWmcJYomybadmaFfTEUlB84qVleKv0lLy9R9adhTWzlOG7Tb1lLjbd248FyKbZmB(fh32oUlOkTaSC51gRg6ZMNoRmj473WXcKTWiLS10Qio2v2lmOKXesuSGcZxsGbljW)RlOKSpmjCbtcysIUQJLlWhrIE74sVWahKa)VUGsY4UGpgMeoufGNVqUwsahjDrY(WKyC0sculmjGjjErcMAnTkIPKD72Gcfda(oQcqeRFThyyCuEiRamyZhdH(9XHCTiCG1nFwH3b)5mEowUaFuEECPxyepo07cLGIggsk4pNXZXYf4JYZJl9cJ4x9LY3b)5moUl4JHZCOkapFHCTzU4dARxC84qVleKHAHJHoUFP8DWFoJS10QioJag)Ihh6DHsaQfog64Eyi4pNr2AAveNn)YV4XHExOeGAHJHoUFrj72Tbfkga8DufGi6xZ(yCyXWA486huErkOpo6Pchppg94bgw56huEJBhY5fKHBob9HWkD1S9HTJvI1V2dmCegS5JHq)(4qUweLSB3guOyaW3rvaIHaqn7JXHfdRHZRFq5fPG(4ONkC88y0JhyyLRFq5nUDiNxqgU5e0FerfP0vZ2h2owjw)ApWWryWMpgc97Jd5AruYUDBqHIbaFhvbiIw2y8lpn(X4WIH1W51pO8IuqFC0tfoEEm6XdmSY1pO8g3oKZlid3Cc6dHh94qVlKsxnBFy7yLy9R9adhHbB(yi0VpoKRfrjJjKO3a6MeqrIfMe89(a(ljwxvTlOuYUDBqHIbaFhvbiobNLZGzU89Fmo6PcUA2(W2XuYycjyAOkapFKOhqbtc(hUiXda)LKfqcxlFK4KumEs0dqN6Ge8DbdWtIxWKGCSmjtWrco1jev8Ysj72Tbfkga8DufGihQcWZxoauW4ONk8MTMwfXrZV8lxmU3Hb2AAvehraJF5IX9omWwtRI4OxyKlg37WqWFoJbUXllNbZSBm59PlOOC57)44XHExOeW1OIggc(ZzmWnEz5myMDJjVpDbfL9Z6fhpo07cLaUgv0WGJ2ZnzvaE(sacMOslayGb4RO1ZDzJh7WyOmj473WXcKTWOxkFBbadmaFfTEUlB84qVlucJiXHblayGb4RO1ZDzJh7Wy8AyiaGqk7A5tfy8LHZZg6ZMpo07cbz9tKsgtirVbWusUg6ZssapbhtYh1fusWPoPKD72Gcfda(oQcqC(pmYGzMn)IXrpvWcagya(kA9Cx24XomgkX6x7bgoAHZwqb3BdkLVD0EUjRcWZxcqWevMKfGLlV2y1qF2805HblalxETXQH(S5PZkD0EUjRcWZhKX1eFP8DswawU8AJvd9zZtNhgSaGbgGVIwqHfmMZ7dNrQ91lkESdJXlLjbF)gowGSfgrjJjKGtDcrfVSKG)Hls8LeiyIJsIorJmjVbNbGNps2hVibxtKeDIgzsW37dj4euybJ5xKGV3hWFjXaqDbLKTdzs6Ie9yaayZhTK4fmjMUys(QKGV3hsWjOWcgZK0ts6Le8oIeygHrzzykz3UnOqXaGVJQaeTSHrB7MSBAOvixlo6PcjbF)gowGSfgPeRFThy4OfoBbfCVnOu((TJ2ZnzvaE(sacMOY3b)5moUl4JHZCOkapFHCTzU4dARxC8RomKKfGLlV24ymU2Rxddb)5mgyaayZhTXVQYG)CgdmaaS5J24XHExiidPeh9TfuW)EJQhBBeNDtdTc5AJBhYzSU5ZVEnmeaqiLDT8Pcm(YW5zd9zZhh6DHGmKsC03wqb)7nQESTrC2nn0kKRnUDiNX6Mp)AyWcWYLxBSAOpBE68lLVtYcWYLxBSAOpBE68WWBhTNBYQa88bzCnXHbyWgN)dJmyMzZV4422XDb9LY3y9R9adhTGclymNHzegLDyWcagya(kAbfwWyoVpCgP2xVO4XomgVErj72Tbfkga8DufGyxw)kFBqHJEQqsW3VHJfiBHrkX6x7bgoAHZwqb3BdkLVF7O9CtwfGNVeGGjQ8DWFoJJ7c(y4mhQcWZxixBMl(G26fh)Qddjzby5YRnogJR961WqWFoJbgaa28rB8RQm4pNXadaaB(OnECO3fcYJiXrFBbf8V3O6X2gXz30qRqU242HCgRB(8RxddbaeszxlFQaJVmCE2qF28XHExiipIeh9TfuW)EJQhBBeNDtdTc5AJBhYzSU5ZVggSaSC51gRg6ZMNo)s57KSaSC51gRg6ZMNopm82r75MSkapFqgxtCyagSX5)WidMz28loUTDCxqFP8nw)ApWWrlOWcgZzygHrzhgSaGbgGVIwqHfmMZ7dNrQ91lkESdJXRxuYycjykA7qFzejpa8Ke(TpKOt0itIFmjq9Uyysu5JeeBbfmLSB3guOyaW3rvaIy9R9adJJYdzfCK6iZxkBXbw38zfyRPvrCSRS5x(Hzum4s3UnOIO1VzFCKXnB)lN3oKhnj2AAveh7kB(LFyM3q4rx3W1grGVjdM59HZtWXOnYLhyyymZiEHlD72GkI)89jY4MT)LZBhYJMyes4sKkBm5hhTmLmMqII9hQss66h6Fqzej4F4IK9Hjz2qFwsAejEa4VKSas4cghKmpU0lmiPrK4bG)sYciHlyCqcgGpj(XK4ljqWehLeDIgzs6IeVibtTMwfX4GeCQtiQ4LLeJJwejEb2h(irXmkITisahjya(KGh8nWKaWYN1vjjeCmj7JxKqd6Nij6enYKG)HlsWa8jbp4BGlmFjjD9d9pOmjfapLSB3guOyaW3rvaIO1p0)GY4ONk8oaGqk7A5tfy8LHZZg6ZMpo07cbzCDy4DWFoJNJLlWhLNhx6fgXJd9UqqgQfog64gZy5282r75MSkapF4YrK4lLb)5mEowUaFuEECPxye)QVEnm82r75MSkapFJI1V2dmC0rQJmFPSfZe8NZiBnTkIZiGXV4XHExOrHbBC(pmYGzMn)IJBBhJYhh6DHzGuurjOV(jom4O9CtwfGNVrX6x7bgo6i1rMVu2Izc(ZzKTMwfXzZV8lECO3fAuyWgN)dJmyMzZV4422XO8XHExygifvuc6RFIVuYwtRI4yxzVWq57Kc(Zz065USXV6WqsRB4AJO1pd4GJC5bgg(LY3VtYcagya(kA9Cx24xDyWcWYLxBCmgx7LYKSaGbgGVICOkapF5aqbh)QVggSaSC51gRg6ZMNo)s57KSaSC51gXY1(GXnmKuWFoJwp3Ln(vhgC0EUjRcWZxcqWeFnm8EDdxBeT(zahCKlpWWWkd(Zz065USXVQY3b)5mIw)mGdoIw3ogYJyyWr75MSkapFjabt81RHHG)CgTEUlB84qVluckgLjf8NZ45y5c8r55XLEHr8RQmP1nCTr06NbCWrU8addtjJjKOliMeDfaOqK0fjJ0V8Jem1AAvetIxWKGCSmjyw7M5O6TVXqIUcauKmbhj4uNquXllLSB3guOyaW3rvaIfJphcafo6PcVd(ZzKTMwfXzZV8lECO3fkbg3S9VCE7qEy4T9XpOmsbiP8y7JFq582HmKv0RHb7JFqzKcJ4LsxnBFy7ykz3UnOqXaGVJQaeFCZmhcafo6PcVd(ZzKTMwfXzZV8lECO3fkbg3S9VCE7qw5BlayGb4RO1ZDzJhh6DHsqrjomybadmaFfTGclymN3hoJu7Rxu84qVluckkXxddVTp(bLrkajLhBF8dkN3oKHSIEnmyF8dkJuyeVu6Qz7dBhtj72Tbfkga8DufG48Bm5qaOWrpv4DWFoJS10QioB(LFXJd9UqjW4MT)LZBhYkFBbadmaFfTEUlB84qVluckkXHblayGb4ROfuybJ58(WzKAF9IIhh6DHsqrj(Ay4T9XpOmsbiP8y7JFq582HmKv0RHb7JFqzKcJ4LsxnBFy7ykzmHeiqaMscOiXctj72Tbfkga8DufGiE)UgCzWmZMFXuYycj6cIjjD9B2htYcir9awssbg)ibtTMwfXKaosW)WfjDrcOmyqYi9l)ibtTMwfXK4fmjFetceiatjr9awej9KKUizK(LFKGPwtRIykz3UnOqXaGVJQaerRFZ(yC0tfyRPvrCSRS5x(nmWwtRI4icy8lxmU3Hb2AAveh9cJCX4Ehgc(ZzeVFxdUmyMzZV44xvzWFoJS10QioB(LFXV6WW7G)CgTEUlB84qVleKD72GkI)89jY4MT)LZBhYkd(Zz065USXV6lkz3UnOqXaGVJQaeXF((qj72Tbfkga8DufG49RSB3guztJwCuEiRW0nM95(uYuYycjPRFO)bLjzcoscby5qUws(LHris(OUGsIEa6uhuYUDBqHIt3y2N7RaA9d9pOmo6PcjD)INGdkhdCJxwodMz3yY7txqrrgc9BvvgMsgtibNoAjzFysGblj479HK9HjjeGws2oKjzbK4WWK8RTnKSpmjHoUjb(F(2GIKgrYtVrss)1SpMKJd9UqKe(nBRAAgMKfqsOV2hscbGA2htc8)8TbfLSB3guO40nM95(JQaer)A2hJdlgwdNx)GYlsb9XrpvagSXqaOM9XXJd9UqjCCO3fcZajiHl1xXqj72TbfkoDJzFU)OkaXqaOM9XuYuYycj6cIjzFysGaKR9bJJe89(qItco1jev8YsY(4ljnQW8LK5bcjzK)gKFuYUDBqHIOvHZXYf4JYZJl9cdC0tfc(Zz065USXJd9UqjOVIOKXes0fets66h6FqzswajJzwLKVkj7dtII9ypmOly(ij4pNK0ts6Le8GVbMeg3Q9XKeWtWXKm7QrpDbLK9HjPyCVKyD0sc4izbKa)dvjjGNGJjbNGclymtj72TbfkI2rvaIO1p0)GY4ONkC)INGdkh3oKXdUkdFShg0fmFrgc9Bvvgw5B2AAveh7k7fgkt697G)Cg3oKXdUkdFShg0fmFXJd9Uqj42Tbve)57tKXnB)lN3oKhnXO(kFZwtRI4yx5aW(mmWwtRI4yxzeW43WaBnTkIJMF5xUyCVVggc(ZzC7qgp4Qm8XEyqxW8fpo07cLGB3gur063SpoY4MT)LZBhYJMyuFLVzRPvrCSRS5x(nmWwtRI4icy8lxmU3Hb2AAveh9cJCX4EF9AyiPG)Cg3oKXdUkdFShg0fmFXV6RHH3b)5mA9Cx24xDyaRFThy4OfuybJ5mmJWOSVuAbadmaFfTGclymN3hoJu7Rxu8yhgdLwawU8AJvd9zZtNFP8DswawU8AJJX4AVggSaGbgGVICOkapF5aqbhpo07cLGI5LY3b)5mA9Cx24xDyijlayGb4RO1ZDzJh7Wy8Isgtirxqmj6e2v3gltskE)cjb)dxKSp8XK0iskajUDBSmji8(fIdsCejgFzsCejQaeQdmmjGIeeE)cjbFVpKajsahjtgpFKGw3ogrc4ibuK4KmIrjbH3Vqsqas2hFjzFyskgpji8(fsIFxJLrKabWhTK4ZLps2hFjbH3VqsyCR2hJOKD72Gcfr7Okarh2v3glNr49lehwmSgoV(bLxKc6JJEQqsWGn6WU62y5mcVFHzyp0HYXTTJ7cQYKC72Gk6WU62y5mcVFHzyp0HYXUYttd9zv(ojyWgDyxDBSCgH3VW8d7M422XDbDyagSrh2v3glNr49lm)WUjECO3fkbf9AyagSrh2v3glNr49lmd7HouoIw3ogYJqjmyJoSRUnwoJW7xyg2dDOC84qVleKhHsyWgDyxDBSCgH3VWmSh6q5422XDbLsgtirxqmIeCckSGXmj9KeCQtiQ4LLKgrYxLeWrcgGpj(XKaZimkBxqjbN6eIkEzjbFVpKGtqHfmMjXlysWa8jXpMKa2aWtcUMij6enYuYUDBqHIODufGOfuybJ58(WzKAF9IWrpv4nw)ApWWrlOWcgZzygHrzvMKfamWa8v065USXJDymggc(Zz065USXV6lLoAp3Kvb45dY4AIkFh8NZiBnTkIZMF5x84qVluc6N4WqWFoJS10QioJag)Ihh6DHsq)eFnmeaqiLZg6ZMpo07cbz9tKsgtibNGcU3guKmbhjUXqcmyrKSp(ssOpMrKG(htY(WyqIFCH5ljhppg9WWKG)Hls0vDSCb(is0Bhx6fgK84ismmcrY(4fjkIeeBrKCCO3vxqjbCKSpmjJX4AVij4pNK0is8aWFjzbKmDJHeWCsc4iXlmibtTMwfXK0is8aWFjzbKW4wTpMs2TBdkueTJQaeX6x7bgghLhYkad28XqOFFCixlchyDZNv4DWFoJNJLlWhLNhx6fgXJd9UqjOOHHKc(Zz8CSCb(O884sVWi(vFP8DWFoJJ7c(y4mhQcWZxixBMl(G26fhpo07cbzOw4yOJ7xkFh8NZiBnTkIZiGXV4XHExOeGAHJHoUhgc(ZzKTMwfXzZV8lECO3fkbOw4yOJ7xuYUDBqHIODufGyiauZ(yCyXWA486huErkOpo6Pchppg94bgw56huEJBhY5fKHBob9HKY3UA2(W2XkX6x7bgocd28XqOFFCixl6fLSB3guOiAhvbiI(1SpghwmSgoV(bLxKc6JJEQWXZJrpEGHvU(bL342HCEbz4MtqFiP8TRMTpSDSsS(1EGHJWGnFme63hhY1IErj72TbfkI2rvaIOLng)YtJFmoSyynCE9dkVif0hh9uHJNhJE8adRC9dkVXTd58cYWnNG(qyLVD1S9HTJvI1V2dmCegS5JHq)(4qUw0lkzmHeDbXKO3a6MeqrIfMe89(a(ljwxvTlOuYUDBqHIODufG4eCwodM5Y3)X4ONk4Qz7dBhtjJjKOliMemlDbFmmjPQ91lIe89(qIxyqIbuqjHlWh6djghTDbLem1AAvetIxWKShgKSasmDXK0ljFvsW37djJ83G8JeVGjbN6eIkEzPKD72Gcfr7OkaroufGNVCaOGXrpv497G)CgzRPvrCgbm(fpo07cLG(jome8NZiBnTkIZMF5x84qVluc6N4lLwaWadWxrRN7Ygpo07cLWisu57G)CgvVoeCWTBY(z9QTz1Vb5xeRB(mKHeUM4Wqs3V4j4GYr1RdbhC7MSFwVABw9Bq(fzi0Vvvz4xVggc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZjOaKWfjomybadmaFfTEUlB8yhgdLoAp3Kvb45lbiyIuYycj6cIjbN6eIkEzjbFVpKGtqHfmMHiMLUGpgMKu1(6frIxWKadkmFjbGLp8xVmjJ83G8JeWrc(hUirpgaa28rlj4bFdmjmUv7JjjGNGJjbN6eIkEzjHXTAFmIs2TBdkueTJQaeTSHrB7MSBAOvixlo6PcjbF)gowGSfgPeRFThy4OfoBbfCVnOu(2r75MSkapFjabtu57G)Cgh3f8XWzoufGNVqU2mx8bT1lo(vhgsYcWYLxBCmgx71RHblalxETXQH(S5PZddb)5mgyaayZhTXVQYG)CgdmaaS5J24XHExiidPeh99BiiM5(fpbhuoQEDi4GB3K9Z6vBZQFdYVidH(TQkd)A03wqb)7nQESTrC2nn0kKRnUDiNX6Mp)61lLjf8NZO1ZDzJFvLVtYcWYLxBSAOpBE68WGfamWa8v0ckSGXCEF4msTVErXV6WqaaHu21YNkW4ldNNn0NnFCO3fcYwaWadWxrlOWcgZ59HZi1(6ffpo07cnkeEyORLpvGXxgopBOpB(4qVleUexQVIjridPeh9TfuW)EJQhBBeNDtdTc5AJBhYzSU5ZVErj72TbfkI2rvaIDz9R8Tbfo6PcjbF)gowGSfgPeRFThy4OfoBbfCVnOu(2r75MSkapFjabtu57G)Cgh3f8XWzoufGNVqU2mx8bT1lo(vhgsYcWYLxBCmgx71RHblalxETXQH(S5PZddb)5mgyaayZhTXVQYG)CgdmaaS5J24XHExiipIeh99BiiM5(fpbhuoQEDi4GB3K9Z6vBZQFdYVidH(TQkd)A03wqb)7nQESTrC2nn0kKRnUDiNX6Mp)61lLjf8NZO1ZDzJFvLVtYcWYLxBSAOpBE68WGfamWa8v0ckSGXCEF4msTVErXV6WqaaHu21YNkW4ldNNn0NnFCO3fcYwaWadWxrlOWcgZ59HZi1(6ffpo07cnkeEyORLpvGXxgopBOpB(4qVleUexQVIjripIeh9TfuW)EJQhBBeNDtdTc5AJBhYzSU5ZVErjJjKabOFThyys(igMeqrIh0MEBgrY(4lj49AjzbKeWKGCSmmjtWrco1jev8YsccqY(4lj7dJbj(X1scEhTmmjqa8rljb8eCmj7dhsj72TbfkI2rvaIy9R9adJJYdzfqowopbx265US4aRB(ScjzbadmaFfTEUlB8yhgJHHKW6x7bgoAbfwWyodZimkRslalxETXQH(S5PZddW3VHJfiBHruYycj6cIrKO3aykj9KKUiXlsWuRPvrmjEbtYEnJizbKy6IjPxs(QKGV3hsg5Vb5hoibN6eIkEzjXlys0jSRUnwMKu8(fsj72TbfkI2rvaIZ)HrgmZS5xmo6PcS10Qio2v2lmu6Qz7dBhRm4pNr1RdbhC7MSFwVABw9Bq(fX6MpdziHRjQ8nmyJoSRUnwoJW7xyg2dDOCCB74UGomKKfGLlV2yX2dyah8lLy9R9adhrowopbx265USuYycj6cIjbcyX7djPRFt3yir9awej9KK01VPBmK0OcZxs(QuYUDBqHIODufGiA9B6gdo6Pcb)5mckEFqzv(SS62Gk(vvg8NZiA9B6gt845XOhpWWuYUDBqHIODufGO1llBYb)5ehLhYkGw)mGdgh9uHG)CgrRFgWbhpo07cbzfP8DWFoJS10QioJag)Ihh6DHsqrddb)5mYwtRI4S5x(fpo07cLGIEP0r75MSkapFjabtKsgtirX(dvrKOt0itsapbhtcobfwWyMKpQlOKSpmj4euybJzsSGcU3guKSasSpSDmj9KeCckSGXmjnIe3UF3yWGepa8xswajbmjwhTuYUDBqHIODufGiA9B6gdo6PcRB4AJOLng)YWxp3ixEGHHvI4D7ckkIagqg(65Qm4pNr0630nMimaFrjJjKOy)HQisCKkjb8eCmj4euybJzs(OUGsY(WKGtqHfmMjXck4EBqrYciX(W2XK0tsWjOWcgZK0isC7(DJbds8aWFjzbKeWKyD0sj72TbfkI2rvaIO1p0)GY4ONkyby5YRnwn0NnpDwjw)ApWWrlOWcgZzygHrzvAbadmaFfTGclymN3hoJu7Rxu84qVleKvKYKGVFdhlq2cJOKXes0fets6630ngsW37djPlBm(rII965sIxWKuassx)mGdghKG)HlskajPRFt3yiPrK8vXbjya(K4htsxKms)YpsWuRPvrmjGJKfqI6bSKmYFdYpsW)WfjEaaltcemrs0jAKjbCK4WQ(2yzsq49lKKhhrIIzueBrKCCO3vxqjbCK0is6IKPPH(SuYUDBqHIODufGiA9B6gdo6PcRB4AJOLng)YWxp3ixEGHHvM06gU2iA9Zao4ixEGHHvg8NZiA9B6gt845XOhpWWkFh8NZiBnTkIZMF5x84qVlucqyLS10Qio2v28l)ug8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKuuIddb)5mQEDi4GB3K9Z6vBZQFdYViw385euaskkrLoAp3Kvb45lbiyIddWGn6WU62y5mcVFHzyp0HYXJd9UqjOyggC72Gk6WU62y5mcVFHzyp0HYXUYttd9zFPmjlayGb4RO1ZDzJh7WyqjJjKOliMK01p0)GYKabS49He1dyrK4fmjW)qvs0jAKjb)dxKGtDcrfVSKaos2hMeia5AFW4ij4pNK0is8aWFjzbKmDJHeWCsc4ibdWhZHjX6QKOt0itj72TbfkI2rvaIO1p0)GY4ONke8NZiO49bLTg2Vm2g1Gk(vhgc(ZzCCxWhdN5qvaE(c5AZCXh0wV44xDyi4pNrRN7Yg)QkFh8NZ45y5c8r55XLEHr84qVleKHAHJHoUXmwUnVD0EUjRcWZhUCej(szWFoJNJLlWhLNhx6fgXV6Wqsb)5mEowUaFuEECPxye)QktYcagya(kEowUaFuEECPxyep2HXyyijlalxETrSCTpyCVggC0EUjRcWZxcqWevYwtRI4yxzVWGsgtirhhgKSasc9Xmj7dtsaJwsatssx)mGdMKamibTUDCxqjPxs(QKaH(TDSbds6IeVWGem1AAvetsWFjzK)gKFK0OAjXda)LKfqsatI6bSwgMs2TBdkueTJQaerRFO)bLXrpvyDdxBeT(zahCKlpWWWkt6(fpbhuoUDiJhCvg(ypmOly(Ime63QQmSY3b)5mIw)mGdo(vhgC0EUjRcWZxcqWeFPm4pNr06NbCWr062XqEekFh8NZiBnTkIZiGXV4xDyi4pNr2AAveNn)YV4x9LYG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mKHeUirLVTaGbgGVIwp3LnECO3fkb9tCyijS(1EGHJwqHfmMZWmcJYQ0cWYLxBSAOpBE68lkzmHef7puLK01p0)GYK0fjoj4IrrSLKuGXpsWuRPvrmoibguy(sIHxs6Le1dyjzK)gKFK8EF8LKgrYJxWggMKamiH79Hps2hMK01VPBmKy6IjbCKSpmj6enYjabtKetxmjtWrs66h6Fq5x4GeyqH5ljaS8H)6LjXlsGaw8(qI6bSK4fmjgEjzFys8aawMetxmjpEbByssx)mGdMs2TBdkueTJQaerRFO)bLXrpviP7x8eCq542HmEWvz4J9WGUG5lYqOFRQYWkFh8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKWfjome8NZO61HGdUDt2pRxTnR(ni)IyDZNHmKuuIkx3W1grlBm(LHVEUrU8add)szWFoJS10QioJag)Ihh6DHsaxOKTMwfXXUYiGXpLjf8NZiO49bLv5ZYQBdQ4xvzsRB4AJO1pd4GJC5bggwPfamWa8v065USXJd9UqjGlu(2cagya(koUl4JHZi1(6ffpo07cLaUyyijlalxETXXyCTxVOKXes0fetIUcauis6IKr6x(rcMAnTkIjXlysqowMemRDZCu923yirxbaksMGJeCQtiQ4LLeVGjbZsxWhdtcMgQcWZxixlLSB3guOiAhvbiwm(Ciau4ONk8o4pNr2AAveNn)YV4XHExOeyCZ2)Y5Td5HH32h)GYifGKYJTp(bLZBhYqwrVggSp(bLrkmIxkD1S9HTJvI1V2dmCe5y58eCzRN7Ysj72TbfkI2rvaIpUzMdbGch9uH3b)5mYwtRI4S5x(fpo07cLaJB2(xoVDiRmjlalxETXXyCTxddVd(ZzCCxWhdN5qvaE(c5AZCXh0wV44xvPfGLlV24ymU2RxddVTp(bLrkajLhBF8dkN3oKHSIEnmyF8dkJuyeddb)5mA9Cx24x9LsxnBFy7yLy9R9adhrowopbx265USuYUDBqHIODufG48Bm5qaOWrpv4DWFoJS10QioB(LFXJd9UqjW4MT)LZBhYktYcWYLxBCmgx71WW7G)Cgh3f8XWzoufGNVqU2mx8bT1lo(vvAby5YRnogJR961WWB7JFqzKcqs5X2h)GY5TdziROxdd2h)GYifgXWqWFoJwp3Ln(vFP0vZ2h2owjw)ApWWrKJLZtWLTEUllLmMqIUGysGabykjGIelmLSB3guOiAhvbiI3VRbxgmZS5xmLmMqIUGyssx)M9XKSasupGLKuGXpsWuRPvrmoibN6eIkEzj5XrKyyeIKTdzs2hViXjbc889Heg3S9VmjgEUKaosaLbdsgPF5hjyQ10QiMKgrYxLs2TBdkueTJQaerRFZ(yC0tfyRPvrCSRS5x(nmWwtRI4icy8lxmU3Hb2AAveh9cJCX4Ehgc(ZzeVFxdUmyMzZV44xvzWFoJS10QioB(LFXV6WW7G)CgTEUlB84qVleKD72GkI)89jY4MT)LZBhYkd(Zz065USXV6lkzmHeDbXKabE((qcyF4dFJysW)02hsAejDrskW4hjyQ10QighKGtDcrfVSKaoswajQhWsYi9l)ibtTMwfXuYUDBqHIODufGi(Z3hkzmHe9MBm7Z9PKD72Gcfr7OkaX7xz3UnOYMgT4O8qwHPBm7Z91srQSvt36NiK0wTvtd]] )


end