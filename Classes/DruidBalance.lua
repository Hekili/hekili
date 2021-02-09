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


    spec:RegisterPack( "Balance", 20210208, [[d80JseqiHKhPkOlbIOnrj(eekJsk5usPwfis9kvHMfiQBjes7sWVGqgMiXXeIwgi0ZeszAes6AusSnqe(gHuACesX5ePK1jKkMhi4EeI9js1bHq1cfP4HuszIIukxKqInkecFuKsvDsvbSsrsVuiePzkKQUPiLQ0oPK0pfcrmuHuPLksPYtLIPsjvxLqQ2QiLQ4RGiXybrs7LG)kQbt6WuTyk1JPyYG6YiBwQ(minAvPtRy1cHOETQOzt0TfQDl53adhshxvGwUkphQPR01vvBhI(oHA8cbNhcwVqOMVi2pQfIuW6cnW(scwfIPaXitbIPiAcrMwIQOgz0eAweqjHgu380HscnLhtcnPXLEziHguhbjWHfSUqdg8pdj08Ulko6GiebD23VDWaIreEI)sFhqzoVVicpXgej0y)h5(aLGTqdSVKGvHykqmYuGykIMqKPLOcrrnAcn(FFbNqtZeBnHM3bgMkbBHgycBeAE4dznnU0ldXAA7(dmN6dFiRreK999dbwfnqMviMceJKtLt9HpKvR96fuchD4uF4dznIYkIddtWS2aK(XAAipoWP(WhYAeLvR96fucM11pO0MNoRghtywxaRgemskV(bLwCGt9HpK1ikRPDumajbZ6VkYqySFiWks)g3wsywBnbkazwrpczgV(H)huI1iA6SIEeYaE9d)pOu7aN6dFiRruwrCKGbMv0JmoENckRqkNVVSoDwNfXWSUVeRIpqbLvrXihumf4uF4dznIYAAV(tIvRbkKGNeR7lXAd6CZIz1zvo7kjwJbhXAxsrySLeRTMoRia(S(6WfITS(olRZYkEI)Y1lc8Xseyv8SVSMMisqCRZ6JSAnss4DCjRiUCGwXuTqM1zrmywXph02bHg5GxSG1fAGPU)LRG1fSAKcwxOXn7akHgmq6x2M8yHgQCBjblKgHvWQquW6cnu52scwincnauHgmTcnUzhqj0G0VXTLKqdsx(jHgmkjL51pO0Id41VUlLSMoRrYQfwBXAuSUUKQnGx)KGdoqLBljywtsyDDjvBaVKu6xg(M(gOYTLemRTznjHvmkjL51pO0Id41VUlLSMoRquObPF5YJjHMbNDaj0atyZnO7akHMgAXSI4arHvqXA0EKvXZ(c(lRW30xw9cMvXZ(YAZ6NeCWS6fmRq8rwb7lDIhmjScwnAcwxOHk3wsWcPrObGk0GPvOXn7akHgK(nUTKeAq6Ypj0GrjPmV(bLwCaV(1NJynDwJuObPF5YJjHMbNnsYrscnWe2Cd6oGsOPHwmRgj5ijwf)sfRnRF95iwnEX67SScXhzD9dkTywf)oMxwhmRhjjKETS2bhR7lXQOyKdkMyDbSAtSIEuNUJGfwbRkQcwxOHk3wsWcPrOXCZs34cnTynkwnaKu51gQb67M7oXAscRrXQbaKWaXvWakKGNuEFPmgDUzXHpkRTz1cR2)Epy88uMWhvOXn7akHgB6W09CkOcnWe2Cd6oGsOr0XeR20HP75uqzv8SVSACwbhREFPJvRbkKGNeRtXQXfwbRAfbRl0qLBljyH0i04MDaLqdkyhqj0yUzPBCHg7FVhmEEkt4OyFkmRPZAKPi0atyZnO7akHMOlyzv8SVSACw3xFzDWfITS6SgD)sSFSIEaJWkyviHG1fAOYTLeSqAeAaOcnyAfACZoGsObPFJBljHgKU8tcngAKS2I1wSo1shkq6lbN7d03nFuSpfM1ikRrAfwJOSAaajmqCfmEEkt4OyFkmRTzfrSgPOjfwBZQiSAOrYAlwBX6ulDOaPVeCUpqF38rX(uywJOSgPvynIYAKqmfwJOSAaajmqCfmGcj4jL3xkJrNBwC4OyFkmRTzfrSgPOjfwBZAscRgaqcdexbJNNYeok2NcZA6So1shkq6lbN7d03nFuSpfM1KewnaGegiUcgqHe8KY7lLXOZnloCuSpfM10zDQLouG0xco3hOVB(OyFkmRruwJmfwtsynkwnaKu51gQb67M7oj0G0VC5XKqJbuibpPmmHrOmcnWe2Cd6oGsOXAU08L(sywf)s7lDS(XtbLvRbkKGNeRfqmRIhPKvxkbIzfbWN1fWkEhPKvJJxw3xIvShtS6XGFTSc6SAnqHe8KE0AioIEGYWQXXlwyfSQOvW6cnu52scwincnauHgmTcnUzhqj0G0VXTLKqdsx(jHMwSgfR0d(huucoqXOiCKlZGdU8YqSMKWQbaKWaXvGIrr4ixMbhC5LHchf7tHzfcSgjKifwTWAuSAaajmqCfOyueoYLzWbxEzOWromcS2M1KewnaKu51gEIWnEj0G0VC5XKqJboBaf8SdOeAGjS5g0DaLqJOJjywxaRWK0rG19Ly9JDOeRGoRwdXr0dugwf)sfRF8uqzfg8TLeRGI1pMewbRkAeSUqdvUTKGfsJqt5XKqdfJIWrUmdo4Yldj0atyZnO7akHgrhtSkkXOiCKlznIKdU8YqScXuWKbZQn1bhXQZQ1qCe9aLH1pMccnMBw6gxOXaasyG4ky88uMWrX(uywHaRqmfwTWQbaKWaXvWakKGNuEFPmgDUzXHJI9PWScbwHykSMKWAFG(U5JI9PWScbwJMOvOXn7akHgkgfHJCzgCWLxgsyfSAAjyDHgQCBjblKgHMYJjHgm4lL0UtbnFFBeeAGjS5g0DaLqJOJjwBaFPK2PGYAA33gbwHeyYGz1M6GJy1z1AioIEGYW6htbHgZnlDJl0yaajmqCfmEEkt4OyFkmRqGvibRwynkwr6342skyafsWtkdtyekdRjjSAaajmqCfmGcj4jL3xkJrNBwC4OyFkmRqGvibRwyfPFJBlPGbuibpPmmHrOmSMKWAFG(U5JI9PWScbwHOveACZoGsObd(sjT7uqZ33gbHvWQrMIG1fAOYTLeSqAeAkpMeAMcBU)62sk)GFV2FCgMqogsOXn7akHMPWM7VUTKYp43R9hNHjKJHeAm3S0nUqJ9V3dgppLj8rfwbRgzKcwxOHk3wsWcPrOXCZs34cnTyfPFJBlPaOYFmL3BQN0YQiSgjRjjSI0VXTLuau5pMY7n1tAzvewJgRTz1cRTy1(37bJNNYe(OSMKWQbaKWaXvW45PmHJI9PWS(iRqK10zDVPEsByJmyaajmqCfG)NVdOy1cRTynkwnaKu51gQb67M7oXAscRrXks)g3wsbdOqcEszycJqzyTnRwynkwnaKu51gEIWnEXAscRgasQ8Ad1a9DZDNy1cRi9BCBjfmGcj4jLHjmcLHvlSAaajmqCfmGcj4jL3xkJrNBwC4JYQfwJIvdaiHbIRGXZtzcFuwTWAlwBXQ9V3dKroOykl)LFHJI9PWSMoRrMcRjjSA)79azKdkMYyG0VWrX(uywtN1itH12SAH1Oy9(f1bhuky7sVmug0ZUuM33PGIdu52scM1KewBXQ9V3d2U0ldLb9SlL59DkO4C57)OaEDZtwfHvRWAscR2)Epy7sVmug0ZUuM33PGIZ(z8Ic41npzvewTcRTzTnRjjSA)79WZPGpcotXOaX0ft1MPIoOtetHpkRTznjH1(a9DZhf7tHzfcScXuynjHvK(nUTKcGk)XuEVPEslRIWAkcnUzhqj0S3upPnsHgycBUbDhqj0y93bZ6Gz1z989LowjPBdoFjwf7iW6cyn2FsS6sjRGI1pMyfV(Y6Et9KwmRlGvBIv5uemRFuwfp7lRwdXr0dugw9cMvRbkKGNeREbZ6htSUVeRqSGzflblRGIvdmRtNvBW(Y6Et9KwmR(rSckw)yIv86lR7n1tAXcRGvJeIcwxOHk3wsWcPrOXCZs34cni9BCBjfav(JP8Et9KwwfH1OXQfwJI19M6jTHnYWromczdaiHbIlwtsyTfR2)Epy88uMWhL1KewnaGegiUcgppLjCuSpfM1hzfISMoR7n1tAdledgaqcdexb4)57akwTWAlwJIvdajvETHAG(U5UtSMKWAuSI0VXTLuWakKGNugMWiugwBZQfwJIvdajvETHNiCJxSMKWQbGKkV2qnqF3C3jwTWks)g3wsbdOqcEszycJqzy1cRgaqcdexbdOqcEs59LYy05Mfh(OSAH1Oy1aasyG4ky88uMWhLvlS2I1wSA)79azKdkMYYF5x4OyFkmRPZAKPWAscR2)Epqg5GIPmgi9lCuSpfM10znYuyTnRwynkwVFrDWbLc2U0ldLb9SlL59DkO4avUTKGznjH1wSA)79GTl9Yqzqp7szEFNckox((pkGx38Kvry1kSMKWQ9V3d2U0ldLb9SlL59DkO4SFgVOaEDZtwfHvRWABwBZABwtsy1(37HNtbFeCMIrbIPlMQntfDqNiMcFuwtsyTpqF38rX(uywHaRqmfwtsyfPFJBlPaOYFmL3BQN0YQiSMIqJB2bucn7n1tAHOWky1iJMG1fAOYTLeSqAeAm3S0nUqJ9V3dgppLj8rznjHvdajvETHAG(U5UtSAHvK(nUTKcgqHe8KYWegHYWQfwnaGegiUcgqHe8KY7lLXOZnlo8rz1cRrXQbaKWaXvW45PmHpkRwyTfRTy1(37bYihumLL)YVWrX(uywtN1itH1KewT)9EGmYbftzmq6x4OyFkmRPZAKPWABwTWAuSE)I6GdkfSDPxgkd6zxkZ77uqXbQCBjbZAscR3VOo4GsbBx6LHYGE2LY8(ofuCGk3wsWSAH1wSA)79GTl9Yqzqp7szEFNckox((pkGx38K10znASMKWQ9V3d2U0ldLb9SlL59DkO4SFgVOaEDZtwtN1OXABwBZAscR2)Ep8Ck4JGZumkqmDXuTzQOd6eXu4JYAscR9b67Mpk2NcZkeyfIPi04MDaLqZht5zPySqdmHn3GUdOeAeDmHz1Lswb7lDSckw)yI1zPymRGIvdSWky1ifvbRl0qLBljyH0i0atyZnO7akHM0gzgyIv3SdOyvo4LvBhtWSckwXZ(9DafIKe0bl04MDaLqZ9RSB2buz5GxHg8EJzfSAKcnMBw6gxObPFJBlPWGZoGeAKdEZLhtcnoGewbRgPveSUqdvUTKGfsJqJ5MLUXfAUFrDWbLc2U0ldLb9SlL59DkO4a9G)bfLGfAW7nMvWQrk04MDaLqZ9RSB2buz5GxHg5G3C5XKqJnWxHvWQrcjeSUqdvUTKGfsJqJB2bucn3VYUzhqLLdEfAKdEZLhtcn4vyfwHgBGVcwxWQrkyDHgQCBjblKgHgZnlDJl0y)79GXZtzcFuHg3SdOeAohjvGpo3pQIyeeAGjS5g0DaLqteXrveJaRIN9LvRH4i6bkJWkyvikyDHgQCBjblKgHgaQqdMwHg3SdOeAq6342ssObPl)KqtuSA)79GTl9Yqzqp7szEFNckox((pk8rz1cRrXQ9V3d2U0ldLb9SlL59DkO4SFgVOWhvObPF5YJjHgZnBb2pQqdmHn3GUdOeAS2lzEIzD6SUVeRMBwwT)9oRdM1cSS(rzTdowL(shRFmjScwnAcwxOHk3wsWcPrOXCZs34cn2)Epy7sVmug0ZUuM33PGIZLV)Jc41npzfcSkQSAHv7FVhSDPxgkd6zxkZ77uqXz)mErb86MNScbwfvwTWAlwJIvyWgCyhDhKugl2V4mSh7qPWoMNtbLvlSgfRUzhqfCyhDhKugl2V4mSh7qPWu5UCG(USAH1wSgfRWGn4Wo6oiPmwSFX5xYLHDmpNckRjjScd2Gd7O7GKYyX(fNFjxgok2NcZA6SgnwBZAscRWGn4Wo6oiPmwSFXzyp2Hsb86MNScbwJgRwyfgSbh2r3bjLXI9lod7XoukCuSpfMviWQvy1cRWGn4Wo6oiPmwSFXzyp2HsHDmpNckRTfACZoGsOXHD0DqszSy)IfAmiyKuE9dkTybRgPWkyvrvW6cnu52scwincnMBw6gxOPfRi9BCBjfmGcj4jLHjmcLHvlSgfRgaqcdexbJNNYeoYHrG1KewT)9EW45PmHpkRTz1cRTy1(37bBx6LHYGE2LY8(ofuCU89FuaVU5jRIWQvynjHv7FVhSDPxgkd6zxkZ77uqXz)mErb86MNSkcRwH12SMKWAFG(U5JI9PWScbwJmfHg3SdOeAmGcj4jL3xkJrNBwSqdmHn3GUdOeAeDmXQ1afsWtIvycLk4PGYkOyfJqzy9JYQ4zFz1AioIEGYWkOy1aZk4y1gbwf7ZofuwxauAFPJvXZ(YQZQ5MLv7FVlScw1kcwxOX(375YJjHg86NeCWcnMBw6gxOPfR2)Epy7sVmug0ZUuM33PGIZLV)Jchf7tHznDwf1GvynjHv7FVhSDPxgkd6zxkZ77uqXz)mErHJI9PWSMoRIAWkS2MvlS649CzgfiMowtxewtRuy1cRTy1aasyG4ky88uMWrX(uywtNvrlRjjS2IvdaiHbIRafJcetx2guWHJI9PWSMoRIwwTWAuSA)79WZPGpcotXOaX0ft1MPIoOtetHpkRwy1aqsLxB4jc34fRTzTTqdvUTKGfsJqdmHn3GUdOeASMxgsYAZ6NeCWSkE2xwLegZ6(6fRqcwXKbZ6rX(utbLvVGz1Tb)L1fWk8pgL1M1p8)GsyHg3SdOeAmEziz2(37cRGvHecwxOHk3wsWcPrOXCZs34cnRlPAd4LKs)YW303avUTKGz1cRyA3PGIdyGeKHVPVSAHv7FVhWRFDxkdWaXLqJB2bucn41VUlLcRGvfTcwxOHk3wsWcPrOXCZs34cnrXks)g3wsbZnBb2pkRwyTfRgasQ8Ad1a9DZDNynjHvdaiHbIRGXZtzchf7tHznDwfTSMKWAuSI0VXTLuWaNnGcE2buSAH1Oy1aqsLxB4jc34fRjjS2IvdaiHbIRafJcetx2guWHJI9PWSMoRIwwTWAuSA)79WZPGpcotXOaX0ft1MPIoOtetHpkRwy1aqsLxB4jc34fRTzTTqJB2bucn41p8)GscnWe2Cd6oGsOjT9JrzTz9d)pOeMvXZ(Y6(sSAd8Lv7FVZQ9FzTalRIFPIvuaqofuw7GJvJZk4yLIrbIPJvBqblScwv0iyDHgQCBjblKgHgZnlDJl00IvdaiHbIRGbuibpP8(szm6CZIdhf7tHzfcSAfwTWAuScF)bouGSbgZQfwBXks)g3wsbdOqcEszycJqzynjHvdaiHbIRGXZtzchf7tHzfcSAfwBZQfwr6342skyGZgqbp7akwBZQfwD8EUmJcethRPZQOMcRwy1aqsLxBOgOVBU7eRwynkwHV)ahkq2aJz1cRKroOykmv2leeACZoGsObV(H)husObMWMBq3bucnPTFmkRnRF4)bLWSAtDWrSAnqHe8KewbRMwcwxOHk3wsWcPrObGk0GPvOXn7akHgK(nUTKeAq6Ypj00Iv7FVhmEEkt4OyFkmRPZQvy1cRTy1(37HZrsf4JZ9JQigHWrX(uywtNvRWAscRrXQ9V3dNJKkWhN7hvrmcHpkRTznjH1Oy1(37bJNNYe(OS2MvlS2I1Oy1(37HNtbFeCMIrbIPlMQntfDqNiMcFuwBZQfwBXQ9V3dKroOykJbs)chf7tHznDwHAGdXEeynjHv7FVhiJCqXuw(l)chf7tHznDwHAGdXEeyTTqds)YLhtcnWGnF0d(NJIPAXcnWe2Cd6oGsOjTbkeBzfgSSc)VPGY6(sSsfmRGoRwdXr0dugiZk8)MckRpNc(iywPyuGy6IPAzfCSofR7lXQ0XlRqnWSc6S6fRIIroOysyfSAKPiyDHgQCBjblKgHgZnlDJl0Cu)i8RBljwTW66huAd7et5fKHhI10znsibRwy1rZMxY8KvlSI0VXTLuagS5JEW)CumvlwOXn7akHg8V6ZrcngemskV(bLwSGvJuyfSAKrkyDHgQCBjblKgHgZnlDJl0Cu)i8RBljwTW66huAd7et5fKHhI10znYOfScRwy1rZMxY8KvlSI0VXTLuagS5JEW)CumvlwOXn7akHMyaO6ZrcngemskV(bLwSGvJuyfSAKquW6cnu52scwincnMBw6gxO5O(r4x3wsSAH11pO0g2jMYlidpeRPZAKqcwFK1JI9PWSAHvhnBEjZtwTWks)g3wsbyWMp6b)ZrXuTyHg3SdOeAWljL(L7s)iHgdcgjLx)GslwWQrkScwnYOjyDHgQCBjblKgHgZnlDJl04OzZlzEk04MDaLqthCgkd65Y3)rcnWe2Cd6oGsOjIayvwb)fpWeR7lXQ5MLv7FVZk4yv8lvSIa4ZkmOqSL1xhjXkvGp0xwDmkRlGv8)GscRGvJuufSUqdvUTKGfsJqJ5MLUXfAAXkzKdkMctL9cbwtsyLmYbftbmq6xEQCKSMKWkzKdkMcYF5xEQCKS2MvlS2I1Oy1aqsLxBOgOVBU7eRjjScF)bouGSbgZAscRTy1X75YmkqmDScbwtlRWQfwBXks)g3wsbZnBb2pkRjjS649CzgfiMowHaRrlfwtsyfPFJBlPWGZoGyTnRwyTfRi9BCBjfmGcj4jLHjmcLHvlSgfRgaqcdexbdOqcEs59LYy05Mfh(OSMKWAuSI0VXTLuWakKGNugMWiugwTWAuSAaajmqCfmEEkt4JYABwBZABwTWAlwnaGegiUcgppLjCuSpfM10znAPWAscRW3FGdfiBGXSMKWQJ3ZLzuGy6ynDwtRuy1cRgaqcdexbJNNYe(OSAH1wSAaajmqCfOyuGy6Y2GcoCuSpfMviWQB2bub86xFokqrGm)LY7etSMKWAuSAaiPYRn8eHB8I12SMKW6ulDOaPVeCUpqF38rX(uywHaRrMcRTz1cRTyfgSbh2r3bjLXI9lod7XoukCuSpfM10zvuznjH1Oy1aqsLxBOiZbKGdM12cnUzhqj00)hczqptYFrcnWe2Cd6oGsOjIaikSAtDWrS6SAUzzv8uWaXScowNcpWeREXQOyKdkMewbRgPveSUqdvUTKGfsJqJ5MLUXfAAXkzKdkMcYF5xUOiSSMKWkzKdkMcyG0VCrryznjHvYihumf8cHCrryznjHv7FVhSDPxgkd6zxkZ77uqX5Y3)rHJI9PWSMoRIAWkSMKWQ9V3d2U0ldLb9SlL59DkO4SFgVOWrX(uywtNvrnyfwtsy1X75YmkqmDSMoRPvkSAHvdaiHbIRGXZtzch5WiWQfwJIv47pWHcKnWywBZQfwBXQbaKWaXvW45PmHJI9PWSMoRrlfwtsy1aasyG4ky88uMWromcS2M1KewNAPdfi9LGZ9b67Mpk2NcZkeynYueACZoGsOHIrbIPlBdkyHgycBUbDhqj0ikXOaX0XQnOGzv8lvSc(lEGjw9IvrXihumXk4y1AioIEGYW6Gz1Tb)LvWYQnX6htWbwBCKeRDWXQ1qCe9aLryfSAKqcbRl0qLBljyH0i0yUzPBCHMOyf((dCOazdmMvlSI0VXTLuWaNnGcE2buSAH1wS2IvhVNlZOaX0XA6SMwPWQfwBXQ9V3dpNc(i4mfJcetxmvBMk6Gormf(OSMKWAuSAaiPYRn8eHB8I12SMKWQ9V3d2saaw(XB4JYQfwT)9EWwcaWYpEdhf7tHzfcScXuy9rwBXQbuW)zdOhzgmLD5aTIPAd7etzKU8tS2M12SMKW6ulDOaPVeCUpqF38rX(uywHaRqmfwFK1wSAaf8F2a6rMbtzxoqRyQ2WoXugPl)eRTznjHvdajvETHAG(U5UtS2MvlS2I1Oy1aqsLxBOgOVBU7eRjjS649CzgfiMowHaRIAkSAH1wSI0VXTLuWakKGNugMWiugwtsy1aasyG4kyafsWtkVVugJo3S4WromcS2M12cnUzhqj0yijH3XLzxoqRyQwHgycBUbDhqj0ynehrpqzyv8lvS6lRPvkpYQJrzv8SVG)YQeGNckR7etSofRPrcaWYpEzfCSgr(JxwbfRgaqcdexSk(LkwlWYQCQPGY6hLvXZ(YQ1afsWtsyfSAKIwbRl0qLBljyH0i0yUzPBCHMOyf((dCOazdmMvlSI0VXTLuWaNnGcE2buSAH1wS2IvhVNlZOaX0XA6SMwPWQfwBXQ9V3dpNc(i4mfJcetxmvBMk6Gormf(OSMKWAuSAaiPYRn8eHB8I12SMKWQ9V3d2saaw(XB4JYQfwT)9EWwcaWYpEdhf7tHzfcSgTuy9rwBXQbuW)zdOhzgmLD5aTIPAd7etzKU8tS2M12SMKW6ulDOaPVeCUpqF38rX(uywHaRrlfwFK1wSAaf8F2a6rMbtzxoqRyQ2WoXugPl)eRTznjHvdajvETHAG(U5UtS2MvlS2I1Oy1aqsLxBOgOVBU7eRjjS649CzgfiMowHaRIAkSAH1wSI0VXTLuWakKGNugMWiugwtsy1aasyG4kyafsWtkVVugJo3S4WromcS2M12cnUzhqj0mLXVY3bucRGvJu0iyDHgQCBjblKgHgaQqdMwHg3SdOeAq6342ssObPl)KqdzKdkMctLL)YpwH0SkAyfrS6MDavaV(1NJcueiZFP8oXeRpYAuSsg5GIPWuz5V8JvinRTyfsW6JSUUKQnGbFzg0Z7lL7GJWBGk3wsWScPznAS2MveXQB2bubXNVVbkcK5VuENyI1hznLaezfrSIrjPm)64LeAq6xU8ysOXXOrx6AiJqdmHn3GUdOeAef8oX(sywFbIzn(BEzfXXrxwra8z1pIvO(utbLvu6yftgqblScwnY0sW6cnu52scwincnMBw6gxOPfRtT0HcK(sW5(a9DZhf7tHzfcSkQSMKWAlwT)9E4CKub(4C)OkIriCuSpfMviWkudCi2JaRqAwn0izTfRoEpxMrbIPJveXA0sH12SAHv7FVhohjvGpo3pQIyecFuwBZABwtsyTfRoEpxMrbIPJ1hzfPFJBlPGJrJU01qgwH0SA)79azKdkMYyG0VWrX(uywFKvyWg6)dHmONj5VOWoMN48rX(uScPzfIbRWA6SgzKPWAscRoEpxMrbIPJ1hzfPFJBlPGJrJU01qgwH0SA)79azKdkMYYF5x4OyFkmRpYkmyd9)Hqg0ZK8xuyhZtC(OyFkwH0ScXGvynDwJmYuyTnRwyLmYbftHPYEHaRwyTfRrXQ9V3dgppLj8rznjH1OyDDjvBaV(jbhCGk3wsWS2MvlS2I1wSgfRgaqcdexbJNNYe(OSMKWQbGKkV2WteUXlwTWAuSAaajmqCfOyuGy6Y2Gco8rzTnRjjSAaiPYRnud03n3DI12SAH1wSgfRgasQ8AdiPAFr4ynjH1Oy1(37bJNNYe(OSMKWQJ3ZLzuGy6ynDwtRuyTnRjjS2I11LuTb86NeCWbQCBjbZQfwT)9EW45PmHpkRwyTfR2)EpGx)KGdoGx38KviWA0ynjHvhVNlZOaX0XA6SMwPWABwBZAscR2)Epy88uMWrX(uywtNvrdRwynkwT)9E4CKub(4C)OkIri8rz1cRrX66sQ2aE9tco4avUTKGfACZoGsObV(H)husObMWMBq3bucnPTFmkRnRF4)bLWSk(Lkw3xI1(a9DzDWS62G)Y6cyLkyiZA)OkIrG1bZQBd(lRlGvQGHmRia(S6hXQVSMwP8iRogL1Py1lwffJCqXeKz1AioIEGYWQ0XlMvVa7lDSkAEetgmRGJveaFwfd(sywbiPZ4OSgdoI191lw5KitHvehhDzv8lvSIa4ZQyWxcxi2YAZ6h(FqjwlGyHvWQqmfbRl0qLBljyH0i0yUzPBCHMwSA)79azKdkMYYF5x4JYAscRTy186hucZQiScrwTW6rMx)Gs5DIjwHaRwH12SMKWQ51pOeMvrynAS2MvlS6OzZlzEk04MDaLqtrIZXaqjScwfIrkyDHgQCBjblKgHgZnlDJl00Iv7FVhiJCqXuw(l)cFuwtsyTfRMx)GsywfHviYQfwpY86hukVtmXkey1kS2M1KewnV(bLWSkcRrJ12SAHvhnBEjZtHg3SdOeAEDzphdaLWkyvicrbRl0qLBljyH0i0yUzPBCHMwSA)79azKdkMYYF5x4JYAscRTy186hucZQiScrwTW6rMx)Gs5DIjwHaRwH12SMKWQ51pOeMvrynAS2MvlS6OzZlzEk04MDaLqt)lL5yaOewbRcXOjyDHgQCBjblKgHgycBUbDhqj0aPaefwbfRgywT)lROhWGzv8iLSckjcSAtS(XemRtHhyI1O)x(XQOyKdkMeACZoGsOrSF3aUmONj5ViHvWQquufSUqdvUTKGfsJqJ5MLUXfAiJCqXuyQS8x(XAscRKroOykGbs)YffHL1KewjJCqXuWleYffHL1KewT)9EqSF3aUmONj5VOWhLvlSA)79azKdkMYYF5x4JYAscRTy1(37bJNNYeok2NcZkey1n7aQG4Z33afbY8xkVtmXQfwT)9EW45PmHpkRTfACZoGsObV(1NJeAGjS5g0DaLqJOJjwBw)6ZrSUawrpGH1gG0pwffJCqXeRGJvXVuX6uSg9)YpwffJCqXKWkyviAfbRl04MDaLqJ4Z3xHgQCBjblKgHvWQqesiyDHgQCBjblKgHg3SdOeAUFLDZoGklh8k0ih8MlpMeA6UuUV3xyfwHghqcwxWQrkyDHgQCBjblKgHgaQqdMwHg3SdOeAq6342ssObPl)KqtlwT)9EyNysm4Qm8rES9uW0fok2NcZkeyfQboe7rG1hznLqKSMKWQ9V3d7etIbxLHpYJTNcMUWrX(uywHaRUzhqfWRF95OafbY8xkVtmX6JSMsiswTWAlwjJCqXuyQS8x(XAscRKroOykGbs)YffHL1KewjJCqXuWleYffHL12S2MvlSA)79WoXKyWvz4J8y7PGPl8rz1cR3VOo4GsHDIjXGRYWh5X2tbtxGEW)GIsWcni9lxEmj0aFKhNfpszU7szg07cnWe2Cd6oGsOXAU08L(sywf)s7lDSUVeRPTJ8yJVMx6y1(37SkEKsw7UuYkO3zv8SVtX6(sSwuewwnoEfwbRcrbRl0qLBljyH0i0aqfAW0k04MDaLqds)g3wscniD5NeAIIvYihumfMkJbs)y1cRTyfJsszE9dkT4aE9RphXA6SAfwTW66sQ2ag8LzqpVVuUdocVbQCBjbZAscRyuskZRFqPfhWRF95iwtNvrlRTfAq6xU8ysOzGwGJY41p8)GscnWe2Cd6oGsOXAU08L(sywf)s7lDS2S(H)huI1bZQyWTVSAC8ofuwbiPJ1M1V(CeRtXA0)l)yvumYbftcRGvJMG1fAOYTLeSqAeAm3S0nUqtlwr6342skyafsWtkdtyekdRwynkwnaGegiUcgppLjCKdJaRjjSA)79GXZtzcFuwBZQfwBXQJ3ZLzuGy6yfcSALuynjHvK(nUTKcd0cCugV(H)huI12SAH1wSA)79azKdkMYYF5x4OyFkmRPZkKG1KewT)9EGmYbftzmq6x4OyFkmRPZkKG12SAH1wSgfR3VOo4GsbBx6LHYGE2LY8(ofuCGk3wsWSMKWQ9V3d2U0ldLb9SlL59DkO4C57)OaEDZtwtN1OXAscR2)Epy7sVmug0ZUuM33PGIZ(z8Ic41npznDwJgRTznjH1(a9DZhf7tHzfcSgzkcnUzhqj0yafsWtkVVugJo3SyHgycBUbDhqj0i6yIvRbkKGNeRIFPIvFzvsymR7RxSALuy1X75swrbIPJvVGzvofX6hLvXZ(YQ1qCe9aLHvXZ(c(lRsaEkOS6S(XKWkyvrvW6cnu52scwincnUzhqj0G)vFosOXGGrs51pO0IfSAKcnWe2Cd6oGsOr0XeR4F1NJyDkwr9cMIhdRIFPIvFznsrftgmRhf7tnfuwbhRscJzv8SVSgdoI11pO0Iz1lywNoRZYQyWxcZA3Lswb9oR2uhCeRuT0nfuw3xI1IIWYQOyKdkMeAm3S0nUqtlwpQFe(1TLeRjjSA)79azKdkMYyG0VWrX(uywHaRrJvlSsg5GIPWuzmq6hRwy9OyFkmRqG1ifvwTW66sQ2ag8LzqpVVuUdocVbQCBjbZABwTW66huAd7et5fKHhI10znsrL1ikRyuskZRFqPfZ6JSEuSpfMvlS2IvYihumfMk7fcSMKW6rX(uywHaRqnWHypcS2wyfSQveSUqdvUTKGfsJqJ5MLUXfAAXQ9V3d41VUlLHJ6hHFDBjXQfwBXkgLKY86huAXb86x3LswHaRrJ1KewJI17xuhCqPWoXKyWvz4J8y7PGPlqp4FqrjywBZAscRRlPAdyWxMb98(s5o4i8gOYTLemRwy1(37bYihumLXaPFHJI9PWScbwJgRwyLmYbftHPYyG0pwTWQ9V3d41VUlLHJI9PWScbwfTSAHvmkjL51pO0Id41VUlLSMUiSkQS2MvlS2I1Oy9(f1bhukirW4NJZDjr7uqZqLtmkMc0d(huucM1Kew3jMyfsYQOAfwtNv7FVhWRFDxkdhf7tHz9rwHiRTz1cRRFqPnStmLxqgEiwtNvRi04MDaLqdE9R7sPqdmHn3GUdOeAIiLiuw)OS2S(1DPKvFz1Lsw3jMWS(ljHXS(XtbL1OhbJFoMvVGzDwwhmRUn4VSUawrpGHvWXQKww3xIvmkzgxYQB2buSkNIy1MKaXS(6fSKynTDKhBpfmDSckwHiRRFqPflScwfsiyDHgQCBjblKgHgZnlDJl0C)I6Gdkf2jMedUkdFKhBpfmDb6b)dkkbZQfwXOKuMx)GsloGx)6UuYA6IWA0y1cRTynkwT)9EyNysm4Qm8rES9uW0f(OSAHv7FVhWRFDxkdh1pc)62sI1KewBXks)g3wsb4J84S4rkZDxkZGENvlS2Iv7FVhWRFDxkdhf7tHzfcSgnwtsyfJsszE9dkT4aE9R7sjRPZkez1cRRlPAd4LKs)YW303avUTKGz1cR2)EpGx)6Uugok2NcZkey1kS2M12S2wOXn7akHg86x3LsHgycBUbDhqj0aPm7lRPTJ8y7PGPJ1pMyTz9R7sjRlG1NeHY6hL19Ly1(37SAJaRUedy9JNckRnRFDxkzfuSAfwXKbuWywbhRscJz9OyFQPGkScwv0kyDHgQCBjblKgHgaQqdMwHg3SdOeAq6342ssObPl)KqJJ3ZLzuGy6ynDwfnPWAeL1wSgzkScPz1(37HDIjXGRYWh5X2tbtxaVU5jRTznIYAlwT)9EaV(1DPmCuSpfMvinRrJveXkgLKY8RJxI12SgrzTfRWGn0)hczqptYFrHJI9PWScPz1kS2MvlSA)79aE9R7sz4Jk0G0VC5XKqdE9R7szwmO2C3LYmO3fAGjS5g0DaLqJ1CP5l9LWSk(L2x6y1zTz9d)pOeRFmXQ4rkz14FmXAZ6x3LswxaRDxkzf07qMvVGz9JjwBw)W)dkX6cy9jrOSM2oYJTNcMowXRBEY6hvyfSQOrW6cnu52scwincnMBw6gxObPFJBlPa8rECw8iL5UlLzqVZQfwr6342skGx)6UuMfdQn3DPmd6DwTWAuSI0VXTLuyGwGJY41p8)GsSMKWAlwT)9EW2LEzOmONDPmVVtbfNlF)hfWRBEYA6Sgnwtsy1(37bBx6LHYGE2LY8(ofuC2pJxuaVU5jRPZA0yTnRwyfJsszE9dkT4aE9R7sjRqGvrvOXn7akHg86h(FqjHgycBUbDhqj0i6yI1M1p8)GsSkE2xwtBh5X2tbthRlG1NeHY6hL19Ly1(37SkE2xWFzvcWtbL1M1VUlLS(r3jMy1lyw)yI1M1p8)GsSckwf1hznnae36SIx38eZ6V2rYQOY66huAXcRGvtlbRl0qLBljyH0i04MDaLqJd7O7GKYyX(fl0yqWiP86huAXcwnsHgycBUbDhqj0i6yIvSy)IzfdyDF9LveaFwHslRXEey9JUtmXQncS(XtbL1zz1XSk9Ly1XSIcW4XwsSckwLegZ6(6fRrJv86MNywbhRrK)4LvXVuXA0EKv86MNywPiGohj0yUzPBCHMOyDhZZPGYQfwJIv3SdOcoSJUdskJf7xCg2JDOuyQCxoqFxwtsyfgSbh2r3bjLXI9lod7XoukGx38KviWA0y1cRWGn4Wo6oiPmwSFXzyp2HsHJI9PWScbwJMWky1itrW6cnu52scwincnUzhqj0edavFosOXGGrs51pO0IfSAKcnWe2Cd6oGsOjTJ6hHFzngaQ(CeRtNvRH4i6bkdRdM1JCyeyfCSUV0rS6hXQKWyw3xVy1kSU(bLwmRtXA0)l)yvumYbftSkE2xwXGTZk4yvsymR7RxSgzkSc2x6epyI1Py1leyvumYbftbwtBGcXwwpQFe(Lv4)nfuwFof8rWSsXOaX0ft1YQxWScdkeBzfGKoJJYQJrfAm3S0nUqZr9JWVUTKy1cRRFqPnStmLxqgEiwtN1wSgPOY6JS2IvmkjL51pO0Id41V(CeRqAwJmyfwBZABwreRyuskZRFqPfZ6JSEuSpfMvlS2I1wSAaajmqCfmEEkt4ihgbwTWAuScF)bouGSbgZQfwBXks)g3wsbdOqcEszycJqzynjHvdaiHbIRGbuibpP8(szm6CZIdh5WiWAscRrXQbGKkV2qnqF3C3jwBZAscRyuskZRFqPfhWRF95iwHaRTy1kScPzTfRrY6JSUUKQnSINkhdafoqLBljywBZABwtsyTfRKroOykmvgdK(XAscRTyLmYbftHPY2G9L1KewjJCqXuyQS8x(XABwTWAuSUUKQnGbFzg0Z7lL7GJWBGk3wsWSMKWQ9V3dO3edo4XLz)mEnMm6xI9lG0LFI10fHviALuyTnRwyTfRyuskZRFqPfhWRF95iwHaRrMcRqAwBXAKS(iRRlPAdR4PYXaqHdu52scM12S2MvlS649CzgfiMowtNvRKcRruwT)9EaV(1DPmCuSpfMvinRqcwBZQfwBXAuSA)79WZPGpcotXOaX0ft1MPIoOtetHpkRjjSsg5GIPWuzmq6hRjjSgfRgasQ8Adpr4gVyTnRwy1rZMxY8K12cRGvJmsbRl0qLBljyH0i0yUzPBCHghnBEjZtHg3SdOeA6GZqzqpx((psObMWMBq3bucnIoMyTdkwbfRgywfp7l4VSACu0PGkScwnsikyDHgQCBjblKgHgZnlDJl0y)79GXZtzcFuHg3SdOeAohjvGpo3pQIyeeAGjS5g0DaLqJOJjw7hvrmcSckwnWqM19DWSkEKsw9)cI9DmUuIaRYPiw)OSkE2xwnUWky1iJMG1fAOYTLeSqAeAm3S0nUqtuScF)bouGSbgZQfwr6342skyGZgqbp7akwTWAlwT)9EaV(1DPm8rznjHvhVNlZOaX0XA6SALuyTnRwynkwT)9EadK4Dmu4JYQfwJIv7FVhmEEkt4JYQfwBXAuSAaiPYRnud03n3DI1Kewr6342skyafsWtkdtyekdRjjSAaajmqCfmGcj4jL3xkJrNBwC4JYAscRtT0HcK(sW5(a9DZhf7tHzfcScXuy9rwBXQbuW)zdOhzgmLD5aTIPAd7etzKU8tS2M12cnUzhqj0yijH3XLzxoqRyQwHgycBUbDhqj0i6yIvRH4i6bkdRGIvdmR)ssymRia(SA8Iv5ueRZY6hLvXZ(YQ1afsWtIvXZ(c(lRsaEkOS6SAC8kScwnsrvW6cnu52scwincnMBw6gxOjkwHV)ahkq2aJz1cRi9BCBjfmWzdOGNDafRwyTfR2)EpGx)6Uug(OSMKWQJ3ZLzuGy6ynDwTskS2MvlSgfR2)EpGbs8ogk8rz1cRrXQ9V3dgppLj8rz1cRTynkwnaKu51gQb67M7oXAscRi9BCBjfmGcj4jLHjmcLH1KewnaGegiUcgqHe8KY7lLXOZnlo8rznjH1Pw6qbsFj4CFG(U5JI9PWScbwnaGegiUcgqHe8KY7lLXOZnloCuSpfM1hzfsWAscRtT0HcK(sW5(a9DZhf7tHzfsYAKIMuyfcSgTuy9rwBXQbuW)zdOhzgmLD5aTIPAd7etzKU8tS2M12cnUzhqj0mLXVY3bucRGvJ0kcwxOHk3wsWcPrOXCZs34cntT0HcK(sW5(a9DZhf7tHzfcSgPvynjH1wSA)79a6nXGdECz2pJxJjJ(Ly)ciD5NyfcScrRKcRjjSA)79a6nXGdECz2pJxJjJ(Ly)ciD5NynDryfIwjfwBZQfwT)9EaV(1DPm8rz1cRTy1aasyG4ky88uMWrX(uywtNvRKcRjjScF)bouGSbgZABHg3SdOeAOyuGy6Y2GcwObMWMBq3bucnIoMyfuSAGzv8SVS2S(1DPK1pkREbZk2rsS2bhRr3Ve7NWky1iHecwxOHk3wsWcPrOXn7akHg8ssPF5U0psOXGGrs51pO0IfSAKcnWe2Cd6oGsOjTJ6hHFzTl9JyfuS(rzDbSgnwx)GslMvXZ(c(lRtzqKXz1MMckRUn4VSUawPiGohXQxWSwGLvas6mok6uqfAm3S0nUqZr9JWVUTKy1cR7et5fKHhI10znsRWQfwXOKuMx)GsloGx)6ZrScbwfvwTWQJMnVK5jRwyTfR2)Epy88uMWrX(uywtN1itH1KewJIv7FVhmEEkt4JYABHvWQrkAfSUqdvUTKGfsJqJ5MLUXfAiJCqXuyQSxiWQfwD0S5Lmpz1cR2)EpGEtm4GhxM9Z41yYOFj2Vasx(jwHaRq0kPWQfwBXkmydoSJUdskJf7xCg2JDOuyhZZPGYAscRrXQbGKkV2qrMdibhmRjjSIrjPmV(bLwmRPZkezTTqJB2bucn9)Hqg0ZK8xKqdmHn3GUdOeAeDmHznIaikSoDwNcpWeREXQOyKdkMy1lywLtrSolRFuwfp7lRoRr3Ve7hROhWWQxWSI4Wo6oijwBe7xSWky1ifncwxOHk3wsWcPrOXCZs34cn2)EpakAFXzu6me6oGk8rz1cRTy1(37b86x3LYWr9JWVUTKynjHvhVNlZOaX0XA6SMwPWABHg3SdOeAWRFDxkfAGjS5g0DaLqJOJjw9Ivqr7lROhWW6VKegZAZ6x3LswhmRU8ihgbw)OScowra8z1pIv3g8xwxaRaK0zCuwDmQWky1itlbRl0qLBljyH0i0yUzPBCHgdajvETHAG(U5UtSAH1wSI0VXTLuWakKGNugMWiugwtsy1aasyG4ky88uMWhL1KewT)9EW45PmHpkRTz1cRgaqcdexbdOqcEs59LYy05Mfhok2NcZkeyfQboe7rGvinRgAKS2IvhVNlZOaX0XkIy1kPWABwTWQ9V3d41VUlLHJI9PWScbwfvwTWAuScF)bouGSbgl04MDaLqdE9R7sPqdmHn3GUdOeAsB)yuwDmkR2uhCeRwduibpjwfp7lRnRFDxkz1lyw3xQyTz9d)pOKWkyviMIG1fAOYTLeSqAeAm3S0nUqJbGKkV2qnqF3C3jwTWAlwr6342skyafsWtkdtyekdRjjSAaajmqCfmEEkt4JYAscR2)Epy88uMWhL12SAHvdaiHbIRGbuibpP8(szm6CZIdhf7tHzfcScjy1cR2)EpGx)6Uug(OSAHvYihumfMk7fcSAH1OyfPFJBlPWaTahLXRF4)bLy1cRrXk89h4qbYgySqJB2bucn41p8)GscRGvHyKcwxOHk3wsWcPrOXCZs34cn2)EpakAFXzJK8lJCWdOcFuwtsyTfRrXkE9RphfC0S5Lmpz1cRrXks)g3wsHbAbokJx)W)dkXAscRTy1(37bJNNYeok2NcZkey1kSAHv7FVhmEEkt4JYAscRTy1(37HZrsf4JZ9JQigHWrX(uywHaRqnWHypcScPz1qJK1wS649CzgfiMowreRrlfwBZQfwT)9E4CKub(4C)OkIri8rzTnRTz1cRi9BCBjfWRFDxkZIb1M7UuMb9oRwyfJsszE9dkT4aE9R7sjRqG1OXABwTWAlwJI17xuhCqPWoXKyWvz4J8y7PGPlqp4FqrjywtsyfJsszE9dkT4aE9R7sjRqG1OXABHg3SdOeAWRF4)bLeAGjS5g0DaLqJOJjwBw)W)dkXQ4zFz1lwbfTVSIEadRGJveaFedMvas6mokRogLvXZ(YkcG)XArryz144nWkIlXawH)XOywDmkR(Y6(sSsfmRGoR7lXksQ2xeowT)9oRtN1M1VUlLSkg8LW1YA3Lswb9oRGIvrLvWXQKWywx)GslwyfSkeHOG1fAOYTLeSqAeAm3S0nUqtlwjJCqXuyQSxiWQfwnaGegiUcgppLjCuSpfM10z1kPWAscRTy186hucZQiScrwTW6rMx)Gs5DIjwHaRwH12SMKWQ51pOeMvrynAS2MvlS6OzZlzEk04MDaLqtrIZXaqj0atyZnO7akHgrhtSgdafMv4)nfuwJ(F5hR)ssymRaK0zCu0PGYARyhbBI1IiymRMxVGsywfp7lRoEpxYAmau42cRGvHy0eSUqdvUTKGfsJqJ5MLUXfAAXkzKdkMctL9cbwTWQbaKWaXvW45PmHJI9PWSMoRwjfwtsyTfRMx)GsywfHviYQfwpY86hukVtmXkey1kS2M1KewnV(bLWSkcRrJ12SAHvhnBEjZtHg3SdOeAEDzphdaLWkyvikQcwxOHk3wsWcPrOXCZs34cnTyLmYbftHPYEHaRwy1aasyG4ky88uMWrX(uywtNvRKcRjjS2IvZRFqjmRIWkez1cRhzE9dkL3jMyfcSAfwBZAscRMx)GsywfH1OXABwTWQJMnVK5PqJB2bucn9VuMJbGsyfSkeTIG1fAOYTLeSqAeAGjS5g0DaLqJOJjwHuaIcRW)BkOSg9)YpwffJCqXKqJB2bucnI97gWLb9mj)fjScwfIqcbRl0qLBljyH0i0aqfAW0k04MDaLqds)g3wscniD5NeAWOKuMx)GsloGx)6ZrSMoRIkRpYAxcahRTyn2XlDiKr6YpXkKM1itjfwreRqmfwBZ6JS2LaWXAlwT)9EaV(H)huktXOaX0ft1MXaPFb86MNSIiwfvwBl0G0VC5XKqdE9RphLNkJbs)ewbRcrrRG1fAOYTLeSqAeAm3S0nUqdzKdkMcYF5xUOiSSMKWkzKdkMcEHqUOiSSAHvK(nUTKcdoBKKJKynjHv7FVhiJCqXugdK(fok2NcZkey1n7aQaE9RphfOiqM)s5DIjwTWQ9V3dKroOykJbs)cFuwtsyLmYbftHPYyG0pwTWAuSI0VXTLuaV(1NJYtLXaPFSMKWQ9V3dgppLjCuSpfMviWQB2bub86xFokqrGm)LY7etSAH1OyfPFJBlPWGZgj5ijwTWQ9V3dgppLjCuSpfMviWkfbY8xkVtmXQfwT)9EW45PmHpkRjjSA)79W5iPc8X5(rveJq4JYQfwXOKuMFD8sSMoRPeGeSAH1wSIrjPmV(bLwmRqqewJgRjjSgfRRlPAdyWxMb98(s5o4i8gOYTLemRTznjH1OyfPFJBlPWGZgj5ijwTWQ9V3dgppLjCuSpfM10zLIaz(lL3jMeACZoGsOr857RqdmHn3GUdOeAeDmXkKY57lRtXAdq6hRIIroOyIvWX6(sSkD8YAZ6xFoIvXGAzTplRtTawDwTgIJOhOmSA)79GWkyvikAeSUqdvUTKGfsJqdmHn3GUdOeAeDmXAZ6xFoI1PZ6uSg9)YpwffJCqXeKzDkwBas)yvumYbftSckwf1hzD9dkTywbhRlGv0dyyTbi9JvrXihumj04MDaLqdE9RphjScwfIPLG1fAOYTLeSqAeACZoGsO5(v2n7aQSCWRqdmHn3GUdOeAIiCPCFVVqJCWBU8ysOP7s5(EFHvyfA6UuUV3xW6cwnsbRl0qLBljyH0i0yUzPBCHMOy9(f1bhuky7sVmug0ZUuM33PGId0d(huucwOXn7akHg86h(FqjHgycBUbDhqj00S(H)huI1o4yngGKIPAz9xscJz9JNckRPbG4wxyfSkefSUqdvUTKGfsJqJB2bucn4F1NJeAmiyKuE9dkTybRgPqdmHn3GUdOeASMJxw3xIvyWYQ4zFzDFjwJb4L1DIjwxaRommR)AhjR7lXAShbwH)NVdOyDWS(oBG1MF1NJy9OyFkmRXF5oOYHGzDbSg7R5L1yaO6ZrSc)pFhqj0yUzPBCHgyWgIbGQphfok2NcZA6SEuSpfMvinRqeISIiwJu0iScwnAcwxOXn7akHMyaO6Zrcnu52scwincRWk0GxbRly1ifSUqdvUTKGfsJqJ5MLUXfAUFrDWbLc7etIbxLHpYJTNcMUa9G)bfLGz1cRTyLmYbftHPYEHaRwynkwBXAlwT)9EyNysm4Qm8rES9uW0fok2NcZA6Sc1ahI9iW6JSMsiswTWAlwjJCqXuyQSnyFznjHvYihumfMkJbs)ynjHvYihumfK)YVCrryzTnRjjSA)79WoXKyWvz4J8y7PGPlCuSpfM10z1n7aQaE9RphfOiqM)s5DIjwFK1ucrYQfwBXkzKdkMctLL)YpwtsyLmYbftbmq6xUOiSSMKWkzKdkMcEHqUOiSS2M12SMKWAuSA)79WoXKyWvz4J8y7PGPl8rzTnRjjS2Iv7FVhmEEkt4JYAscRi9BCBjfmGcj4jLHjmcLH12SAHvdaiHbIRGbuibpP8(szm6CZIdh5WiWABHg3SdOeAWRF4)bLeAGjS5g0DaLqJ1CP5l9LWSk(L2x6yTz9d)pOeRfrWywxaR2eRFmbZ6cy9jrOS(rzDFjwtBh5X2tbthR2)ENvWX6cyf(hJYQn1bhXQbuibpjHvWQquW6cnu52scwincnUzhqj04Wo6oiPmwSFXcngemskV(bLwSGvJuObMWMBq3bucnIoMyfXHD0DqsS2i2Vywf)sfR7lDeRdM1cWQB2bjXkwSFXqMvhZQ0xIvhZkkaJhBjXkOyfl2Vywfp7lRqKvWXANethR41npXScowbfRoRr7rwXI9lMvmG191xw3xI1IeZkwSFXS63nijmRrK)4LvVV0X6(6lRyX(fZkfb05iSqJ5MLUXfAIIvyWgCyhDhKugl2V4mSh7qPWoMNtbLvlSgfRUzhqfCyhDhKugl2V4mSh7qPWu5UCG(USAH1wSgfRWGn4Wo6oiPmwSFX5xYLHDmpNckRjjScd2Gd7O7GKYyX(fNFjxgok2NcZA6SAfwBZAscRWGn4Wo6oiPmwSFXzyp2Hsb86MNScbwJgRwyfgSbh2r3bjLXI9lod7XoukCuSpfMviWA0y1cRWGn4Wo6oiPmwSFXzyp2HsHDmpNcQWky1OjyDHgQCBjblKgHgZnlDJl00IvK(nUTKcgqHe8KYWegHYWQfwJIvdaiHbIRGXZtzch5WiWAscR2)Epy88uMWhL12SAHvhVNlZOaX0XkeyvutHvlS2Iv7FVhiJCqXuw(l)chf7tHznDwJmfwtsy1(37bYihumLXaPFHJI9PWSMoRrMcRTznjH1(a9DZhf7tHzfcSgzkcnUzhqj0yafsWtkVVugJo3SyHgycBUbDhqj0i6ycZQ1afsWtI1PZQXzDWS(rzfCSIa4ZQFeRWegHYmfuwTgIJOhOmSkE2xwTgOqcEsS6fmRia(S6hXQnjbIzvutHvhJkScwvufSUqdvUTKGfsJqdavObtRqJB2bucni9BCBjj0G0LFsOPfR2)Epy88uMWrX(uywtNvRWQfwBXQ9V3dNJKkWhN7hvrmcHJI9PWSMoRwH1KewJIv7FVhohjvGpo3pQIyecFuwBZAscRrXQ9V3dgppLj8rznjHvhVNlZOaX0XkeynAPWABwTWAlwJIv7FVhEof8rWzkgfiMUyQ2mv0bDIyk8rznjHvhVNlZOaX0XkeynAPWABwTWAlwT)9EGmYbftzmq6x4OyFkmRPZkudCi2JaRjjSA)79azKdkMYYF5x4OyFkmRPZkudCi2JaRTfAq6xU8ysObgS5JEW)CumvlwObMWMBq3bucnPDu)i8lRWGfZ6VKegZQ1qCe9aLH1xhZQKWyw3xVy1kSIjdM1JI9PMckKzDFjwrs1(IWXQ9V3zfCSUVeRpr4gVy1(37SoywDBWFzDbS2DPKvqVZQxWS6fcSkkg5GIjwhmRUn4VSUawPiGohjScw1kcwxOHk3wsWcPrOXCZs34cnh1pc)62sIvlSU(bL2WoXuEbz4HynDwJeISAH1wS6OzZlzEYQfwr6342skad28rp4FokMQfZABHg3SdOeAIbGQphj0yqWiP86huAXcwnsHvWQqcbRl0qLBljyH0i0yUzPBCHMJ6hHFDBjXQfwx)GsByNykVGm8qSMoRrcrwTWAlwD0S5Lmpz1cRi9BCBjfGbB(Oh8phft1IzTTqJB2bucn4F1NJeAmiyKuE9dkTybRgPWkyvrRG1fAOYTLeSqAeAm3S0nUqZr9JWVUTKy1cRRFqPnStmLxqgEiwtN1iHeSAH1wS6OzZlzEYQfwr6342skad28rp4FokMQfZABHg3SdOeAWljL(L7s)iHgdcgjLx)GslwWQrkScwv0iyDHgQCBjblKgHgZnlDJl04OzZlzEk04MDaLqthCgkd65Y3)rcnWe2Cd6oGsOr0XeRreaRYkOy1aZQ4zFb)LvJJIofuHvWQPLG1fAOYTLeSqAeAm3S0nUqJ9V3dgppLj8rfACZoGsO5CKub(4C)OkIrqObMWMBq3bucnIoMyDFjwt7HQ9fHJv3EKZIaRGIvdmRIFhZlRdMvBQdoIvRH4i6bkJWky1itrW6cnu52scwincnMBw6gxOPfRTy1(37bYihumLXaPFHJI9PWSMoRrMcRjjSA)79azKdkMYYF5x4OyFkmRPZAKPWABwTWQbaKWaXvW45PmHJI9PWSMoRrlfwTWAlwT)9Ea9MyWbpUm7NXRXKr)sSFbKU8tScbwHOOMcRjjSgfR3VOo4Gsb0BIbh84YSFgVgtg9lX(fOh8pOOemRTzTnRjjSA)79a6nXGdECz2pJxJjJ(Ly)ciD5NynDryfII2uynjHvdaiHbIRGXZtzch5WiWQfwBXQJ3ZLzuGy6ynDwtRuynjHvK(nUTKcdo7aI12cnUzhqj0qXOaX0LTbfSqdmHn3GUdOeAeDmXAePtbFemRnOZnlMvXZ(YAdq6hRIIroOyIvVGzn6(Ly)y9xscJzvcWtbLvN1pMewbRgzKcwxOHk3wsWcPrOXCZs34cnrXk89h4qbYgymRwyfPFJBlPGboBaf8SdOy1cRTy1X75YmkqmDSMoRPvkSAH1wSA)79WZPGpcotXOaX0ft1MPIoOtetHpkRjjSgfRgasQ8Adpr4gVyTnRjjSAaiPYRnud03n3DI1Kewr6342skm4Sdiwtsy1(37bBjaal)4n8rz1cR2)Epylbay5hVHJI9PWScbwHykS(iRTyTfRPfRqAwVFrDWbLcO3edo4XLz)mEnMm6xI9lqp4FqrjywBZ6JS2IvdOG)ZgqpYmyk7YbAft1g2jMYiD5NyTnRTzTnRwynkwT)9EW45PmHpkRwyTfRrXQbGKkV2qnqF3C3jwtsy1aasyG4kyafsWtkVVugJo3S4WhL1KewNAPdfi9LGZ9b67Mpk2NcZkey1aasyG4kyafsWtkVVugJo3S4WrX(uywFKvibRjjSo1shkq6lbN7d03nFuSpfMvijRrkAsHviWketH1hzTfRgqb)NnGEKzWu2Ld0kMQnStmLr6YpXABwBl04MDaLqJHKeEhxMD5aTIPAfAGjS5g0DaLqJOJjwTgIJOhOmSkE2xwTgOqcEsS6fmRWGcXwwbiPt8nlXA09lX(jScwnsikyDHgQCBjblKgHgZnlDJl0efRW3FGdfiBGXSAHvK(nUTKcg4SbuWZoGIvlS2IvhVNlZOaX0XA6SMwPWQfwBXQ9V3dpNc(i4mfJcetxmvBMk6Gormf(OSMKWAuSAaiPYRn8eHB8I12SMKWQbGKkV2qnqF3C3jwtsyfPFJBlPWGZoGynjHv7FVhSLaaS8J3WhLvlSA)79GTeaGLF8gok2NcZkeynAPW6JS2I1wSMwScPz9(f1bhukGEtm4GhxM9Z41yYOFj2Va9G)bfLGzTnRpYAlwnGc(pBa9iZGPSlhOvmvByNykJ0LFI12S2M12SAH1Oy1(37bJNNYe(OSAH1wSgfRgasQ8Ad1a9DZDNynjHvdaiHbIRGbuibpP8(szm6CZIdFuwtsyDQLouG0xco3hOVB(OyFkmRqGvdaiHbIRGbuibpP8(szm6CZIdhf7tHz9rwHeSMKW6ulDOaPVeCUpqF38rX(uywHKSgPOjfwHaRrlfwFK1wSAaf8F2a6rMbtzxoqRyQ2WoXugPl)eRTzTTqJB2bucntz8R8DaLWky1iJMG1fAOYTLeSqAeAaOcnyAfACZoGsObPFJBljHgKU8tcnrXQbaKWaXvW45PmHJCyeynjH1OyfPFJBlPGbuibpPmmHrOmSAHvdajvETHAG(U5UtSMKWk89h4qbYgySqds)YLhtcnyhjL7GlB88ugHgycBUbDhqj0K2JFJBljw)ycMvqXQBpYzhcZ6(6lRI9AzDbSAtSIDKemRDWXQ1qCe9aLHvmG191xw3xcbw9JQLvXoEjywJi)XlR2uhCeR7lflScwnsrvW6cnu52scwincnMBw6gxOHmYbftHPYEHaRwy1rZMxY8KvlSA)79a6nXGdECz2pJxJjJ(Ly)ciD5NyfcScrrnfwTWAlwHbBWHD0DqszSy)IZWESdLc7yEofuwtsynkwnaKu51gkYCaj4GzTnRwyfPFJBlPa2rs5o4YgppLrOXn7akHM()qid6zs(lsObMWMBq3bucnIoMWSgraefwNoRtXQxSkkg5GIjw9cM19gcZ6cyvofX6SS(rzv8SVSgD)sSFqMvRH4i6bkdREbZkId7O7GKyTrSFXcRGvJ0kcwxOHk3wsWcPrOXCZs34cn2)EpakAFXzu6me6oGk8rz1cR2)EpGx)6UugoQFe(1TLKqJB2bucn41VUlLcnWe2Cd6oGsOr0XeRGI2xwBw)6UuYk6bmywNoRnRFDxkzDWfITS(rfwbRgjKqW6cn2)EpxEmj0Gx)KGdwOHk3wsWcPrOXCZs34cn2)EpGx)KGdoCuSpfMviWQvy1cRTy1(37bYihumLXaPFHJI9PWSMoRwH1KewT)9EGmYbftz5V8lCuSpfM10z1kS2MvlS649CzgfiMowtN10kfHg3SdOeAmEziz2(37cRGvJu0kyDHgQCBjblKgHgZnlDJl0SUKQnGxsk9ldFtFdu52scMvlSIPDNckoGbsqg(M(YQfwT)9EaV(1DPmadexcnUzhqj0Gx)6UukScwnsrJG1fAOYTLeSqAeAm3S0nUqJbGKkV2qnqF3C3jwTWks)g3wsbdOqcEszycJqzy1cRgaqcdexbdOqcEs59LYy05Mfhok2NcZkey1kSAH1Oyf((dCOazdmwOXn7akHg86h(FqjHgycBUbDhqj0K2(XOywDmkR2uhCeRwduibpjw)4PGY6(sSAnqHe8Ky1ak4zhqX6cy18sMNSoDwTgOqcEsSoywDZ(DPebwDBWFzDbSAtSAC8kScwnY0sW6cnu52scwincnMBw6gxOzDjvBaVKu6xg(M(gOYTLemRwynkwxxs1gWRFsWbhOYTLemRwy1(37b86x3LYWr9JWVUTKy1cRTy1(37bYihumLL)YVWrX(uywtNvibRwyLmYbftHPYYF5hRwy1(37b0BIbh84YSFgVgtg9lX(fq6YpXkeyfIwjfwtsy1(37b0BIbh84YSFgVgtg9lX(fq6YpXA6IWkeTskSAHvhVNlZOaX0XA6SMwPWAscRWGn4Wo6oiPmwSFXzyp2HsHJI9PWSMoRIgwtsy1n7aQGd7O7GKYyX(fNH9yhkfMk3Ld03L12SAH1Oy1aasyG4ky88uMWromccnUzhqj0Gx)6Uuk0atyZnO7akHgrhtS2S(1DPKvXZ(YkEjP0pwHVPVS6fmRfG1M1pj4GHmRIFPI1cWAZ6x3LswhmRFuiZkcGpR(rSofRr)V8JvrXihumbzwrpGH1O7xI9JvXVuXQBdqsSMwPWQJrzfCS6WO(oijwXI9lM1xhZQO5rmzWSEuSp1uqzfCSoywNI1UCG(UcRGvHykcwxOHk3wsWcPrOXCZs34cn2)EpakAFXzJK8lJCWdOcFuwtsy1(37HNtbFeCMIrbIPlMQntfDqNiMcFuwtsy1(37bJNNYe(OSAH1wSA)79W5iPc8X5(rveJq4OyFkmRqGvOg4qShbwH0SAOrYAlwD8EUmJcethRiI1OLcRTz1cR2)EpCosQaFCUFufXie(OSMKWAuSA)79W5iPc8X5(rveJq4JYQfwJIvdaiHbIRW5iPc8X5(rveJq4ihgbwtsynkwnaKu51gqs1(IWXABwtsy1X75YmkqmDSMoRPvkSAHvYihumfMk7fccnUzhqj0Gx)W)dkj0atyZnO7akHgrhtSIXSckAFzf9agmREbZk8pgLvhJYQ4xQy1AioIEGYWk4yDFjwrs1(IWXQ9V3zDWS62G)Y6cyT7sjRGENvWXkcGpIbZQXrz1XOcRGvHyKcwxOHk3wsWcPrOXCZs34cnRlPAd41pj4Gdu52scMvlSgfR3VOo4GsHDIjXGRYWh5X2tbtxGEW)GIsWSAH1wSA)79aE9tco4WhL1KewD8EUmJcethRPZAALcRTz1cR2)EpGx)KGdoGx38KviWA0y1cRTy1(37bYihumLXaPFHpkRjjSA)79azKdkMYYF5x4JYABwTWQ9V3dO3edo4XLz)mEnMm6xI9lG0LFIviWkefTPWQfwBXQbaKWaXvW45PmHJI9PWSMoRrMcRjjSgfRi9BCBjfmGcj4jLHjmcLHvlSAaiPYRnud03n3DI12cnUzhqj0Gx)W)dkj0atyZnO7akHgRFiW6cyn2FsSUVeR2eEzf0zTz9tcoywTrGv86MNtbL1zz9JY6d(hZtjcSofRnaPFSkkg5GIjwT)lRr3Ve7hRdUwwDBWFzDbSAtSIEaJHGfwbRcrikyDHgQCBjblKgHgZnlDJl0efR3VOo4GsHDIjXGRYWh5X2tbtxGEW)GIsWSAH1wSA)79a6nXGdECz2pJxJjJ(Ly)ciD5NyfcScrrBkSMKWQ9V3dO3edo4XLz)mEnMm6xI9lG0LFIviWkeTskSAH11LuTb8ssPFz4B6BGk3wsWS2MvlSA)79azKdkMYyG0VWrX(uywtNvrlRwyLmYbftHPYyG0pwTWAuSA)79aOO9fNrPZqO7aQWhLvlSgfRRlPAd41pj4Gdu52scMvlSAaajmqCfmEEkt4OyFkmRPZQOLvlS2IvdaiHbIRWZPGpcoJrNBwC4OyFkmRPZQOL1KewJIvdajvETHNiCJxS2wOXn7akHg86h(FqjHgycBUbDhqj0i6yI1M1p8)GsSofRnaPFSkkg5GIjiZkmOqSLvjTSolROhWWA09lX(XAR91xwhmRVEbljywTrGvA2x6yDFjwBw)6UuYQCkIvWX6(sS6y00tRuyvofXAhCS2S(H)huQnKzfgui2YkajDIVzjw9Ivqr7lROhWWQxWSkPL19Ly1TbijwLtrS(6fSKyTz9tcoyHvWQqmAcwxOHk3wsWcPrOXCZs34cnTy1(37bYihumLL)YVWhL1KewBXQ51pOeMvryfISAH1JmV(bLY7etScbwTcRTznjHvZRFqjmRIWA0yTnRwy1rZMxY8KvlSI0VXTLua7iPChCzJNNYi04MDaLqtrIZXaqj0atyZnO7akHgrhtSgdafMv4)nfuwJ(F5hRIIroOyIvWXkcGpIbZkyFPt8GjwbiPZ4OSAE9dkHfwbRcrrvW6cnu52scwincnMBw6gxOPfR2)Epqg5GIPS8x(f(OSAH1Oy1aqsLxB4jc34fRjjS2Iv7FVhEof8rWzkgfiMUyQ2mv0bDIyk8rz1cRgasQ8Adpr4gVyTnRjjS2IvZRFqjmRIWkez1cRhzE9dkL3jMyfcSAfwBZAscRMx)GsywfH1OXAscR2)Epy88uMWhL12SAHvhnBEjZtwTWks)g3wsbSJKYDWLnEEkJqJB2bucnVUSNJbGsyfSkeTIG1fAOYTLeSqAeAm3S0nUqtlwT)9EGmYbftz5V8l8rz1cRrXQbGKkV2WteUXlwtsyTfR2)Ep8Ck4JGZumkqmDXuTzQOd6eXu4JYQfwnaKu51gEIWnEXABwtsyTfRMx)GsywfHviYQfwpY86hukVtmXkey1kS2M1KewnV(bLWSkcRrJ1KewT)9EW45PmHpkRTz1cRoA28sMNSAHvK(nUTKcyhjL7GlB88ugHg3SdOeA6FPmhdaLWkyvicjeSUqdvUTKGfsJqdmHn3GUdOeAeDmXkKcquyfuSAGfACZoGsOrSF3aUmONj5ViHvWQqu0kyDHgQCBjblKgHgZnlDJl0qg5GIPWuz5V8J1KewjJCqXuadK(LlkclRjjSsg5GIPGxiKlkclRjjSA)79Gy)UbCzqptYFrHpkRwy1(37bYihumLL)YVWhL1KewBXQ9V3dgppLjCuSpfMviWQB2bubXNVVbkcK5VuENyIvlSA)79GXZtzcFuwBl04MDaLqdE9Rphj0atyZnO7akHgrhtS2S(1NJyDbSIEadRnaPFSkkg5GIjiZQ1qCe9aLH1xhZQKWyw3jMyDF9IvNviLZ3xwPiqM)sSkP(Yk4yfuseyn6)LFSkkg5GIjwhmRFuHvWQqu0iyDHgQCBjblKgHgycBUbDhqj0i6yIviLZ3xwb7lDIhmXQ43X8Y6GzDkwBas)yvumYbftqMvRH4i6bkdRGJ1fWk6bmSg9)YpwffJCqXKqJB2bucnIpFFfwbRcX0sW6cnu52scwincnUzhqj0C)k7MDavwo4vObMWMBq3bucnreUuUV3xOro4nxEmj00DPCFVVWkScnOhzaX2(kyDbRgPG1fACZoGsO55uWhbNXOZnlwOHk3wsWcPryfSkefSUqdvUTKGfsJqdavObtRqJB2bucni9BCBjj0G0LFsOjfHgK(LlpMeAav(JP8Et9KwHgycBUbDhqj0y9xIvK(nUTKyDWSIPL1fWAkSkE2xwlaR41xwbfRFmX6Et9KwmKznswf)sfR7lXAFo8YkOiwhmRGI1pMGmRqK1PZ6(sSIjdOGzDWS6fmRrJ1PZQnyFz1psyfSA0eSUqdvUTKGfsJqdavOXHHfACZoGsObPFJBljHgKU8tcnrk0G0VC5XKqdOYFmL3BQN0k0yUzPBCHM9M6jTHnYWh72sIvlSU3upPnSrgmaGegiUcW)Z3bucRGvfvbRl0qLBljyH0i0aqfACyyHg3SdOeAq6342ssObPl)KqdefAq6xU8ysObu5pMY7n1tAfAm3S0nUqZEt9K2WcXWh72sIvlSU3upPnSqmyaajmqCfG)NVdOewbRAfbRl04MDaLqtmaupNk3bxSqdvUTKGfsJWkyviHG1fAOYTLeSqAeACZoGsOr857RqJCkkBGfAImfHgycBUbDhqj0eDpY44LviYkKY57lREbZQZAZ6h(FqjwbfRnwNvXZ(YQvhOVlRreoXQxWSMgaIBDwbhRnRF95iwb7lDIhmj0yUzPBCHMwSsg5GIPG8x(LlkclRjjSsg5GIPWuz5V8J1KewjJCqXuyQSnyFznjHvYihumf8cHCrryzTTWkyvrRG1fAOYTLeSqAeAm3S0nUqtlwjJCqXuq(l)YffHL1KewjJCqXuyQS8x(XAscRKroOykmv2gSVSMKWkzKdkMcEHqUOiSS2MvlSIEeYqKbXNVVSAH1Oyf9iKbigeF((k04MDaLqJ4Z3xHvWQIgbRl0qLBljyH0i0yUzPBCHMOy9(f1bhuky7sVmug0ZUuM33PGIdu52scM1KewJIvdajvETHAG(U5UtSMKWAuSIrjPmV(bLwCaV(1DPKvrynswtsynkwxxs1gkF)hHZ2U0ldfOYTLeSqJB2bucn41V(CKWky10sW6cnu52scwincnMBw6gxO5(f1bhuky7sVmug0ZUuM33PGIdu52scMvlSAaiPYRnud03n3DIvlSIrjPmV(bLwCaV(1DPKvrynsHg3SdOeAWRF4)bLewHvyfAqshEaLGvHykqmYuImArk0i2VAkOyHgifepTZQpGvt7hDyLvR)sSoXOGBzTdowrmyQ7F5IySE0d(NJGzfdIjw9)cI9LGz186fuch4uJ(PiwHerhwTgOqs3sWS2mXwJvmc16rGvijRlG1O)7Scpih8akwbO05l4yTfIAZAligH2bo1OFkI1iJm6WQ1afs6wcMve7(f1bhukaPIySUawrS7xuhCqPaKAGk3wsWigRTImcTdCQr)ueRrgz0HvRbkK0TemRi2Et9K2qKbiveJ1fWkIT3upPnSrgGurmwBfzeAh4uJ(PiwJeIrhwTgOqs3sWSIy3VOo4GsbiveJ1fWkID)I6GdkfGudu52scgXyTvKrODGtn6NIynsigDy1AGcjDlbZkIT3upPnezasfXyDbSIy7n1tAdBKbiveJ1wrgH2bo1OFkI1iHy0HvRbkK0TemRi2Et9K2aedqQigRlGveBVPEsByHyasfXyTvKrODGtn6NIynYOfDy1AGcjDlbZkID)I6GdkfGurmwxaRi29lQdoOuasnqLBljyeJ1wqmcTdCQCQqkiEANvFaRM2p6WkRw)LyDIrb3YAhCSIyOhzaX2(IySE0d(NJGzfdIjw9)cI9LGz186fuch4uJ(PiwJw0HvRbkK0TemRi2Et9K2qKbiveJ1fWkIT3upPnSrgGurmwBbXi0oWPg9trSkQrhwTgOqs3sWSIy7n1tAdqmaPIySUawrS9M6jTHfIbiveJ1wqmcTdCQr)ueRIMOdRwduiPBjywrS7xuhCqPaKkIX6cyfXUFrDWbLcqQbQCBjbJyS2kYi0oWPg9trSMwrhwTgOqs3sWSIy3VOo4GsbiveJ1fWkID)I6GdkfGudu52scgXyTvKrODGtLtfsbXt7S6dy10(rhwz16VeRtmk4ww7GJveZbeIX6rp4FocMvmiMy1)li2xcMvZRxqjCGtn6NIynArhwTgOqs3sWSIy3VOo4GsbiveJ1fWkID)I6GdkfGudu52scgXyTvKrODGtn6NIy1krhwTgOqs3sWS2mXwJvmc16rGvijKK1fWA0)DwJbWF5hZkaLoFbhRTGKTzTvKrODGtn6NIyv0gDy1AGcjDlbZAZeBnwXiuRhbwHKSUawJ(VZk8GCWdOyfGsNVGJ1wiQnRTImcTdCQr)ueRrMs0HvRbkK0TemRntS1yfJqTEeyfsY6cyn6)oRWdYbpGIvakD(cowBHO2S2kYi0oWPg9trSgPOgDy1AGcjDlbZAZeBnwXiuRhbwHKqswxaRr)3znga)LFmRau68fCS2cs2M1wrgH2bo1OFkI1itROdRwduiPBjywBMyRXkgHA9iWkKK1fWA0)DwHhKdEafRau68fCS2crTzTvKrODGtn6NIyfIrgDy1AGcjDlbZAZeBnwXiuRhbwHKSUawJ(VZk8GCWdOyfGsNVGJ1wiQnRTImcTdCQr)ueRqeseDy1AGcjDlbZAZeBnwXiuRhbwHKSUawJ(VZk8GCWdOyfGsNVGJ1wiQnRTGyeAh4u5uHuq80oR(awnTF0HvwT(lX6eJcUL1o4yfX6UuUV3hXy9Oh8phbZkgetS6)fe7lbZQ51lOeoWPg9trScXOdRwduiPBjywBMyRXkgHA9iWkKK1fWA0)DwHhKdEafRau68fCS2crTzTvKrODGtLtfsbXt7S6dy10(rhwz16VeRtmk4ww7GJvedVigRh9G)5iywXGyIv)VGyFjywnVEbLWbo1OFkI1iJm6WQ1afs6wcM1Mj2ASIrOwpcScjHKSUawJ(VZAma(l)ywbO05l4yTfKSnRTImcTdCQr)ueRrcXOdRwduiPBjywBMyRXkgHA9iWkKesY6cyn6)oRXa4V8JzfGsNVGJ1wqY2S2kYi0oWPg9trScXuIoSAnqHKULGzTzITgRyeQ1JaRqswxaRr)3zfEqo4buScqPZxWXAle1M1wrgH2bovovifepTZQpGvt7hDyLvR)sSoXOGBzTdowrmBGVigRh9G)5iywXGyIv)VGyFjywnVEbLWbo1OFkI1ifnrhwTgOqs3sWS2mXwJvmc16rGvijRlG1O)7Scpih8akwbO05l4yTfIAZAROfH2bo1OFkI1itROdRwduiPBjywBMyRXkgHA9iWkKK1fWA0)DwHhKdEafRau68fCS2crTzTvKrODGtLt9bIrb3sWScjy1n7akwLdEXbovHgmkzeSAKParHg0d0hjj08WhYAACPxgI1029hyo1h(qwJii777hcSkAGmRqmfigjNkN6dFiRw71lOeo6WP(WhYAeLvehgMGzTbi9J10qECGt9HpK1ikRw71lOemRRFqPnpDwnoMWSUawniyKuE9dkT4aN6dFiRruwt7OyascM1FvKHWy)qGvK(nUTKWS2AcuaYSIEeYmE9d)pOeRr00zf9iKb86h(FqP2bo1h(qwJOSI4ibdmROhzC8ofuwHuoFFzD6SolIHzDFjwfFGckRIIroOykWP(WhYAeL10E9NeRwduibpjw3xI1g05MfZQZQC2vsSgdoI1UKIWyljwBnDwra8z91HleBz9DwwNLv8e)LRxe4JLiWQ4zFznnrKG4wN1hz1AKKW74swrC5aTIPAHmRZIyWSIFoOTdCQCQUzhqHdOhzaX2(kYZPGpcoJrNBwmN6dz16VeRi9BCBjX6GzftlRlG1uyv8SVSwawXRVSckw)yI19M6jTyiZAKSk(Lkw3xI1(C4LvqrSoywbfRFmbzwHiRtN19LyftgqbZ6Gz1lywJgRtNvBW(YQFeNQB2bu4a6rgqSTVpkcIq6342scYLhtIaQ8ht59M6jTqgPl)KiPWP6MDafoGEKbeB77JIGiK(nUTKGC5XKiGk)XuEVPEslKbOI4WWqgPl)Kirc5PlYEt9K2qKHp2TLKL9M6jTHidgaqcdexb4)57akov3SdOWb0JmGyBFFueeH0VXTLeKlpMebu5pMY7n1tAHmavehggYiD5NebIqE6IS3upPnaXWh72sYYEt9K2aedgaqcdexb4)57akov3SdOWb0JmGyBFFueefda1ZPYDWfZP(qwJUhzC8Ykezfs589LvVGz1zTz9d)pOeRGI1gRZQ4zFz1Qd03L1icNy1lywtdaXToRGJ1M1V(CeRG9LoXdM4uDZoGchqpYaIT99rrqK4Z3xilNIYgyrImfipDrArg5GIPG8x(LlkcBsczKdkMctLL)YVKeYihumfMkBd23KeYihumf8cHCrryBZP6MDafoGEKbeB77JIGiXNVVqE6I0ImYbftb5V8lxue2KeYihumfMkl)LFjjKroOykmv2gSVjjKroOyk4fc5IIW22c6ridrgeF((Ajk0JqgGyq857lNQB2bu4a6rgqSTVpkcIWRF95iipDrI6(f1bhuky7sVmug0ZUuM33PGItsIYaqsLxBOgOVBU7ussuyuskZRFqPfhWRFDxkfjYKKOwxs1gkF)hHZ2U0ldfOYTLemNQB2bu4a6rgqSTVpkcIWRF4)bLG80f5(f1bhuky7sVmug0ZUuM33PGITyaiPYRnud03n3DYcgLKY86huAXb86x3LsrIKtLt9HpKvrjcK5VemRes6qG1DIjw3xIv3SGJ1bZQJ0hPBlPaNQB2buyrWaPFzBYJ5uFiRn0IzfXbIcRGI1O9iRIN9f8xwHVPVS6fmRIN9L1M1pj4Gz1lywH4JSc2x6epyIt1n7akSii9BCBjb5YJjrgC2beKr6YpjcgLKY86huAXb86x3LY0J0sROwxs1gWRFsWbhOYTLeCsY6sQ2aEjP0Vm8n9nqLBlj42jjyuskZRFqPfhWRFDxkthICQpK1gAXSAKKJKyv8lvS2S(1NJy14fRVZYkeFK11pO0Izv87yEzDWSEKKq61YAhCSUVeRIIroOyI1fWQnXk6rD6ocMt1n7ak8JIGiK(nUTKGC5XKidoBKKJKGmsx(jrWOKuMx)GsloGx)6ZrPhjN6dzv0XeR20HP75uqzv8SVSACwbhREFPJvRbkKGNeRtXQX5uDZoGc)OiiYMomDpNckKNUiTIYaqsLxBOgOVBU7ussugaqcdexbdOqcEs59LYy05Mfh(OTTy)79GXZtzcFuo1hYA0fSSkE2xwnoR7RVSo4cXwwDwJUFj2pwrpGHt1n7ak8JIGiuWoGcYtxe7FVhmEEkt4OyFkC6rMcN6dz1AU08L(sywf)s7lDS(XtbLvRbkKGNeRfqmRIhPKvxkbIzfbWN1fWkEhPKvJJxw3xIvShtS6XGFTSc6SAnqHe8KE0AioIEGYWQXXlMt1n7ak8JIGiK(nUTKGC5XKigqHe8KYWegHYazKU8tIyOr2Q1ulDOaPVeCUpqF38rX(u4iAKwjIAaajmqCfmEEkt4OyFkCBizKIMuAlIHgzRwtT0HcK(sW5(a9DZhf7tHJOrALiAKqmLiQbaKWaXvWakKGNuEFPmgDUzXHJI9PWTHKrkAsPDsIbaKWaXvW45PmHJI9PWPp1shkq6lbN7d03nFuSpfojXaasyG4kyafsWtkVVugJo3S4WrX(u40NAPdfi9LGZ9b67Mpk2NchrJmLKKOmaKu51gQb67M7oXP(qwfDmbZ6cyfMKocSUVeRFSdLyf0z1AioIEGYWQ4xQy9JNckRWGVTKyfuS(XeNQB2bu4hfbri9BCBjb5YJjrmWzdOGNDafKr6YpjsROOh8pOOeCGIrr4ixMbhC5LHssmaGegiUcumkch5Ym4GlVmu4OyFkmeIesKILOmaGegiUcumkch5Ym4GlVmu4ihgH2jjgasQ8Adpr4gV4uFiRIoMyvuIrr4ixYAejhC5LHyfIPGjdMvBQdoIvNvRH4i6bkdRFmf4uDZoGc)Oii6JP8SumKlpMeHIrr4ixMbhC5LHG80fXaasyG4ky88uMWrX(uyiaXuSyaajmqCfmGcj4jL3xkJrNBwC4OyFkmeGykjj9b67Mpk2NcdHOjA5uFiRIoMyTb8LsANckRPDFBeyfsGjdMvBQdoIvNvRH4i6bkdRFmf4uDZoGc)Oii6JP8SumKlpMebd(sjT7uqZ33gbipDrmaGegiUcgppLjCuSpfgcqclrH0VXTLuWakKGNugMWiuMKedaiHbIRGbuibpP8(szm6CZIdhf7tHHaKWcs)g3wsbdOqcEszycJqzss6d03nFuSpfgcq0kCQUzhqHFuee9XuEwkgYLhtImf2C)1TLu(b)ET)4mmHCmeKNUi2)Epy88uMWhLt9HSA93bZ6Gz1z989LowjPBdoFjwf7iW6cyn2FsS6sjRGI1pMyfV(Y6Et9KwmRlGvBIv5uemRFuwfp7lRwdXr0dugw9cMvRbkKGNeREbZ6htSUVeRqSGzflblRGIvdmRtNvBW(Y6Et9KwmR(rSckw)yIv86lR7n1tAXCQUzhqHFueeT3upPnsipDrAH0VXTLuau5pMY7n1tAfjYKeK(nUTKcGk)XuEVPEsRirRTLw2)Epy88uMWhnjXaasyG4ky88uMWrX(u4hHy67n1tAdrgmaGegiUcW)Z3buwAfLbGKkV2qnqF3C3PKKOq6342skyafsWtkdtyektBlrzaiPYRn8eHB8kjXaqsLxBOgOVBU7KfK(nUTKcgqHe8KYWegHYyXaasyG4kyafsWtkVVugJo3S4Wh1sugaqcdexbJNNYe(OwA1Y(37bYihumLL)YVWrX(u40JmLKe7FVhiJCqXugdK(fok2NcNEKP02su3VOo4GsbBx6LHYGE2LY8(ofuCssl7FVhSDPxgkd6zxkZ77uqX5Y3)rb86MNIyLKe7FVhSDPxgkd6zxkZ77uqXz)mErb86MNIyL2TtsS)9E45uWhbNPyuGy6IPAZurh0jIPWhTDssFG(U5JI9PWqaIPKKG0VXTLuau5pMY7n1tAfjfov3SdOWpkcI2BQN0cripDrq6342skaQ8ht59M6jTIenlrT3upPnez4ihgHSbaKWaXvssl7FVhmEEkt4JMKyaajmqCfmEEkt4OyFk8Jqm99M6jTbigmaGegiUcW)Z3buwAfLbGKkV2qnqF3C3PKKOq6342skyafsWtkdtyektBlrzaiPYRn8eHB8kjXaqsLxBOgOVBU7KfK(nUTKcgqHe8KYWegHYyXaasyG4kyafsWtkVVugJo3S4Wh1sugaqcdexbJNNYe(OwA1Y(37bYihumLL)YVWrX(u40JmLKe7FVhiJCqXugdK(fok2NcNEKP02su3VOo4GsbBx6LHYGE2LY8(ofuCssl7FVhSDPxgkd6zxkZ77uqX5Y3)rb86MNIyLKe7FVhSDPxgkd6zxkZ77uqXz)mErb86MNIyL2TBNKy)79WZPGpcotXOaX0ft1MPIoOtetHpAssFG(U5JI9PWqaIPKKG0VXTLuau5pMY7n1tAfjfo1hYQOJjmRUuYkyFPJvqX6htSolfJzfuSAG5uDZoGc)Oii6JP8SumgYtxe7FVhmEEkt4JMKyaiPYRnud03n3DYcs)g3wsbdOqcEszycJqzSyaajmqCfmGcj4jL3xkJrNBwC4JAjkdaiHbIRGXZtzcFulTAz)79azKdkMYYF5x4OyFkC6rMssI9V3dKroOykJbs)chf7tHtpYuABjQ7xuhCqPGTl9Yqzqp7szEFNckoj5(f1bhuky7sVmug0ZUuM33PGIT0Y(37bBx6LHYGE2LY8(ofuCU89FuaVU5z6rljX(37bBx6LHYGE2LY8(ofuC2pJxuaVU5z6rRD7Ke7FVhEof8rWzkgfiMUyQ2mv0bDIyk8rts6d03nFuSpfgcqmfo1hYAAJmdmXQB2buSkh8YQTJjywbfR4z)(oGcrsc6G5uDZoGc)Oii6(v2n7aQSCWlKlpMeXbeKX7nMvKiH80fbPFJBlPWGZoG4uDZoGc)Oii6(v2n7aQSCWlKlpMeXg4lKX7nMvKiH80f5(f1bhuky7sVmug0ZUuM33PGId0d(huucMt1n7ak8JIGO7xz3SdOYYbVqU8yse8YPYP(qwTMlnFPVeMvXV0(shR7lXAA7ip24R5LowT)9oRIhPK1UlLSc6Dwfp77uSUVeRffHLvJJxov3SdOWbhqIG0VXTLeKlpMeb(ipolEKYC3LYmO3Hmsx(jrAz)79WoXKyWvz4J8y7PGPlCuSpfgcqnWHypcpMsiYKe7FVh2jMedUkdFKhBpfmDHJI9PWqWn7aQaE9RphfOiqM)s5DIPhtjePLwKroOykmvw(l)ssiJCqXuadK(LlkcBsczKdkMcEHqUOiSTBBX(37HDIjXGRYWh5X2tbtx4JA5(f1bhukStmjgCvg(ip2Eky6c0d(huucMt9HSAnxA(sFjmRIFP9LowBw)W)dkX6Gzvm42xwnoENckRaK0XAZ6xFoI1Pyn6)LFSkkg5GIjov3SdOWbhqpkcIq6342scYLhtImqlWrz86h(FqjiJ0LFsKOiJCqXuyQmgi9ZslmkjL51pO0Id41V(Cu6wXY6sQ2ag8LzqpVVuUdocVbQCBjbNKGrjPmV(bLwCaV(1NJsx02Mt9HSk6yIvRbkKGNeRIFPIvFzvsymR7RxSALuy1X75swrbIPJvVGzvofX6hLvXZ(YQ1qCe9aLHvXZ(c(lRsaEkOS6S(XeNQB2bu4GdOhfbrgqHe8KY7lLXOZnlgYtxKwi9BCBjfmGcj4jLHjmcLXsugaqcdexbJNNYeoYHrijX(37bJNNYe(OTT0YX75YmkqmDqWkPKKG0VXTLuyGwGJY41p8)GsTT0Y(37bYihumLL)YVWrX(u40Hejj2)Epqg5GIPmgi9lCuSpfoDirBlTI6(f1bhuky7sVmug0ZUuM33PGItsS)9EW2LEzOmONDPmVVtbfNlF)hfWRBEME0ssS)9EW2LEzOmONDPmVVtbfN9Z4ffWRBEME0ANK0hOVB(OyFkmeImfo1hYQOJjwX)QphX6uSI6fmfpgwf)sfR(YAKIkMmywpk2NAkOScowLegZQ4zFzngCeRRFqPfZQxWSoDwNLvXGVeM1UlLSc6DwTPo4iwPAPBkOSUVeRffHLvrXihumXP6MDafo4a6rrqe(x95iiBqWiP86huAXIejKNUiToQFe(1TLusI9V3dKroOykJbs)chf7tHHq0Sqg5GIPWuzmq6NLJI9PWqisr1Y6sQ2ag8LzqpVVuUdocVbQCBjb32Y6huAd7et5fKHhk9if1ikgLKY86huAXpEuSpf2slYihumfMk7fcjjhf7tHHaudCi2JqBo1hYAePeHY6hL1M1VUlLS6lRUuY6oXeM1FjjmM1pEkOSg9iy8ZXS6fmRZY6Gz1Tb)L1fWk6bmScowL0Y6(sSIrjZ4swDZoGIv5ueR2KeiM1xVGLeRPTJ8y7PGPJvqXkezD9dkTyov3SdOWbhqpkcIWRFDxkH80fPL9V3d41VUlLHJ6hHFDBjzPfgLKY86huAXb86x3LsieTKKOUFrDWbLc7etIbxLHpYJTNcMUa9G)bfLGBNKSUKQnGbFzg0Z7lL7GJWBGk3wsWwS)9EGmYbftzmq6x4OyFkmeIMfYihumfMkJbs)Sy)79aE9R7sz4OyFkmeeTwWOKuMx)GsloGx)6UuMUiIABlTI6(f1bhukirW4NJZDjr7uqZqLtmkMc0d(huucojzNycscjfvRKU9V3d41VUlLHJI9PWpcX2ww)GsByNykVGm8qPBfo1hYkKYSVSM2oYJTNcMow)yI1M1VUlLSUawFsekRFuw3xIv7FVZQncS6smG1pEkOS2S(1DPKvqXQvyftgqbJzfCSkjmM1JI9PMckNQB2bu4GdOhfbr41VUlLqE6IC)I6Gdkf2jMedUkdFKhBpfmDb6b)dkkbBbJsszE9dkT4aE9R7sz6IenlTIY(37HDIjXGRYWh5X2tbtx4JAX(37b86x3LYWr9JWVUTKssAH0VXTLua(ipolEKYC3LYmO3T0Y(37b86x3LYWrX(uyieTKemkjL51pO0Id41VUlLPdrlRlPAd4LKs)YW303avUTKGTy)79aE9R7sz4OyFkmeSs72T5uFiRwZLMV0xcZQ4xAFPJvN1M1p8)GsS(XeRIhPKvJ)XeRnRFDxkzDbS2DPKvqVdzw9cM1pMyTz9d)pOeRlG1NeHYAA7ip2Eky6yfVU5jRFuov3SdOWbhqpkcIq6342scYLhtIGx)6UuMfdQn3DPmd6DiJ0LFsehVNlZOaX0LUOjLiARitbsB)79WoXKyWvz4J8y7PGPlGx38SDeTL9V3d41VUlLHJI9PWq6ObjXOKuMFD8sTJOTGbBO)peYGEMK)Ichf7tHH0wPTf7FVhWRFDxkdFuo1hYQOJjwBw)W)dkXQ4zFznTDKhBpfmDSUawFsekRFuw3xIv7FVZQ4zFb)LvjapfuwBw)6UuY6hDNyIvVGz9JjwBw)W)dkXkOyvuFK10aqCRZkEDZtmR)AhjRIkRRFqPfZP6MDafo4a6rrqeE9d)pOeKNUii9BCBjfGpYJZIhPm3DPmd6Dli9BCBjfWRFDxkZIb1M7UuMb9ULOq6342skmqlWrz86h(FqPKKw2)Epy7sVmug0ZUuM33PGIZLV)Jc41nptpAjj2)Epy7sVmug0ZUuM33PGIZ(z8Ic41nptpATTGrjPmV(bLwCaV(1DPecIkN6dzv0XeRyX(fZkgW6(6lRia(ScLwwJ9iW6hDNyIvBey9JNckRZYQJzv6lXQJzffGXJTKyfuSkjmM191lwJgR41npXScowJi)XlRIFPI1O9iR41npXSsraDoIt1n7akCWb0JIGih2r3bjLXI9lgYgemskV(bLwSirc5Plsu7yEofulr5MDavWHD0DqszSy)IZWESdLctL7Yb67MKad2Gd7O7GKYyX(fNH9yhkfWRBEcHOzbgSbh2r3bjLXI9lod7XoukCuSpfgcrJt9HSM2r9JWVSgdavFoI1PZQ1qCe9aLH1bZ6romcScow3x6iw9JyvsymR7RxSAfwx)GslM1Pyn6)LFSkkg5GIjwfp7lRyW2zfCSkjmM191lwJmfwb7lDIhmX6uS6fcSkkg5GIPaRPnqHylRh1pc)Yk8)MckRpNc(iywPyuGy6IPAz1lywHbfITScqsNXrz1XOCQUzhqHdoGEueefdavFocYgemskV(bLwSirc5PlYr9JWVUTKSS(bL2WoXuEbz4HsVvKI6JTWOKuMx)GsloGx)6Zrq6idwPDBijgLKY86huAXpEuSpf2sRwgaqcdexbJNNYeoYHrWsuW3FGdfiBGXwAH0VXTLuWakKGNugMWiuMKedaiHbIRGbuibpP8(szm6CZIdh5WiKKeLbGKkV2qnqF3C3P2jjyuskZRFqPfhWRF95ii0Ykq6wr(46sQ2WkEQCmau4avUTKGB3ojPfzKdkMctLXaPFjjTiJCqXuyQSnyFtsiJCqXuyQS8x(12suRlPAdyWxMb98(s5o4i8gOYTLeCsI9V3dO3edo4XLz)mEnMm6xI9lG0LFkDrGOvsPTLwyuskZRFqPfhWRF95iiezkq6wr(46sQ2WkEQCmau4avUTKGB32IJ3ZLzuGy6s3kPerT)9EaV(1DPmCuSpfgsdjABPvu2)Ep8Ck4JGZumkqmDXuTzQOd6eXu4JMKqg5GIPWuzmq6xssugasQ8Adpr4gVABXrZMxY8SnN6dzv0XeRDqXkOy1aZQ4zFb)LvJJIofuov3SdOWbhqpkcI6GZqzqpx((pcYtxehnBEjZto1hYQOJjw7hvrmcSckwnWqM19DWSkEKsw9)cI9DmUuIaRYPiw)OSkE2xwnoNQB2bu4GdOhfbrNJKkWhN7hvrmcqE6Iy)79GXZtzcFuo1hYQOJjwTgIJOhOmSckwnWS(ljHXSIa4ZQXlwLtrSolRFuwfp7lRwduibpjwfp7l4VSkb4PGYQZQXXlNQB2bu4GdOhfbrgss4DCz2Ld0kMQfYtxKOGV)ahkq2aJTG0VXTLuWaNnGcE2buwAz)79aE9R7sz4JMK449CzgfiMU0TskTTeL9V3dyGeVJHcFulrz)79GXZtzcFulTIYaqsLxBOgOVBU7uscs)g3wsbdOqcEszycJqzssmaGegiUcgqHe8KY7lLXOZnlo8rtsMAPdfi9LGZ9b67Mpk2NcdbiMYJTmGc(pBa9iZGPSlhOvmvByNykJ0LFQDBov3SdOWbhqpkcIMY4x57akipDrIc((dCOazdm2cs)g3wsbdC2ak4zhqzPL9V3d41VUlLHpAsIJ3ZLzuGy6s3kP02su2)EpGbs8ogk8rTeL9V3dgppLj8rT0kkdajvETHAG(U5Utjji9BCBjfmGcj4jLHjmcLjjXaasyG4kyafsWtkVVugJo3S4WhnjzQLouG0xco3hOVB(OyFkmemaGegiUcgqHe8KY7lLXOZnloCuSpf(rirsYulDOaPVeCUpqF38rX(uyijKmsrtkqiAP8yldOG)ZgqpYmyk7YbAft1g2jMYiD5NA3Mt9HSk6yIvqXQbMvXZ(YAZ6x3Lsw)OS6fmRyhjXAhCSgD)sSFCQUzhqHdoGEueerXOaX0LTbfmKNUitT0HcK(sW5(a9DZhf7tHHqKwjjPL9V3dO3edo4XLz)mEnMm6xI9lG0LFccq0kPKKy)79a6nXGdECz2pJxJjJ(Ly)ciD5NsxeiALuABX(37b86x3LYWh1sldaiHbIRGXZtzchf7tHt3kPKKaF)bouGSbg3Mt9HSM2r9JWVS2L(rSckw)OSUawJgRRFqPfZQ4zFb)L1PmiY4SAttbLv3g8xwxaRueqNJy1lywlWYkajDghfDkOCQUzhqHdoGEueeHxsk9l3L(rq2GGrs51pO0IfjsipDroQFe(1TLKLDIP8cYWdLEKwXcgLKY86huAXb86xFoccIQfhnBEjZtlTS)9EW45PmHJI9PWPhzkjjrz)79GXZtzcF02CQpKvrhtywJiaIcRtN1PWdmXQxSkkg5GIjw9cMv5ueRZY6hLvXZ(YQZA09lX(Xk6bmS6fmRioSJUdsI1gX(fZP6MDafo4a6rrqu)FiKb9mj)fb5PlczKdkMctL9cbloA28sMNwS)9Ea9MyWbpUm7NXRXKr)sSFbKU8tqaIwjflTGbBWHD0DqszSy)IZWESdLc7yEof0KKOmaKu51gkYCaj4GtsWOKuMx)GsloDi2Mt9HSk6yIvVyfu0(Yk6bmS(ljHXS2S(1DPK1bZQlpYHrG1pkRGJveaFw9Jy1Tb)L1fWkajDghLvhJYP6MDafo4a6rrqeE9R7sjKNUi2)EpakAFXzu6me6oGk8rT0Y(37b86x3LYWr9JWVUTKssC8EUmJcetx6PvkT5uFiRPTFmkRogLvBQdoIvRbkKGNeRIN9L1M1VUlLS6fmR7lvS2S(H)huIt1n7akCWb0JIGi86x3LsipDrmaKu51gQb67M7ozPfs)g3wsbdOqcEszycJqzssmaGegiUcgppLj8rtsS)9EW45PmHpABlgaqcdexbdOqcEs59LYy05Mfhok2NcdbOg4qShbiTHgzlhVNlZOaX0bjTskTTy)79aE9R7sz4OyFkmeevlrbF)bouGSbgZP6MDafo4a6rrqeE9d)pOeKNUigasQ8Ad1a9DZDNS0cPFJBlPGbuibpPmmHrOmjjgaqcdexbJNNYe(Ojj2)Epy88uMWhTTfdaiHbIRGbuibpP8(szm6CZIdhf7tHHaKWI9V3d41VUlLHpQfYihumfMk7fcwIcPFJBlPWaTahLXRF4)bLSef89h4qbYgymN6dzv0XeRnRF4)bLyv8SVS6fRGI2xwrpGHvWXkcGpIbZkajDghLvhJYQ4zFzfbW)yTOiSSAC8gyfXLyaRW)yumRogLvFzDFjwPcMvqN19Lyfjv7lchR2)EN1PZAZ6x3Lswfd(s4AzT7sjRGENvqXQOYk4yvsymRRFqPfZP6MDafo4a6rrqeE9d)pOeKNUi2)EpakAFXzJK8lJCWdOcF0KKwrHx)6ZrbhnBEjZtlrH0VXTLuyGwGJY41p8)GsjjTS)9EW45PmHJI9PWqWkwS)9EW45PmHpAssl7FVhohjvGpo3pQIyechf7tHHaudCi2JaK2qJSLJ3ZLzuGy6GKrlL2wS)9E4CKub(4C)OkIri8rB32cs)g3wsb86x3LYSyqT5UlLzqVBbJsszE9dkT4aE9R7sjeIwBlTI6(f1bhukStmjgCvg(ip2Eky6c0d(huucojbJsszE9dkT4aE9R7sjeIwBo1hYQOJjwJbGcZk8)MckRr)V8J1FjjmMvas6mok6uqzTvSJGnXAremMvZRxqjmRIN9LvhVNlzngakCBov3SdOWbhqpkcIksCogakipDrArg5GIPWuzVqWIbaKWaXvW45PmHJI9PWPBLussAzE9dkHfbIwoY86hukVtmbbR0ojX86hucls0ABXrZMxY8Kt1n7akCWb0JIGOxx2ZXaqb5PlslYihumfMk7fcwmaGegiUcgppLjCuSpfoDRKssslZRFqjSiq0YrMx)Gs5DIjiyL2jjMx)GsyrIwBloA28sMNCQUzhqHdoGEuee1)szogakipDrArg5GIPWuzVqWIbaKWaXvW45PmHJI9PWPBLussAzE9dkHfbIwoY86hukVtmbbR0ojX86hucls0ABXrZMxY8Kt9HSk6yIvifGOWk8)MckRr)V8JvrXihumXP6MDafo4a6rrqKy)UbCzqptYFrCQUzhqHdoGEueeH0VXTLeKlpMebV(1NJYtLXaPFqgPl)KiyuskZRFqPfhWRF95O0f1h7sa4Af74LoeYiD5NG0rMskqsiMs7h7sa4Az)79aE9d)pOuMIrbIPlMQnJbs)c41npHKIABo1hYQOJjwHuoFFzDkwBas)yvumYbftScow3xIvPJxwBw)6ZrSkgulR9zzDQfWQZQ1qCe9aLHv7FVh4uDZoGchCa9Oiis857lKNUiKroOyki)LF5IIWMKqg5GIPGxiKlkcRfK(nUTKcdoBKKJKssS)9EGmYbftzmq6x4OyFkmeCZoGkGx)6ZrbkcK5VuENyYI9V3dKroOykJbs)cF0KeYihumfMkJbs)Sefs)g3wsb86xFokpvgdK(LKy)79GXZtzchf7tHHGB2bub86xFokqrGm)LY7etwIcPFJBlPWGZgj5ijl2)Epy88uMWrX(uyiqrGm)LY7etwS)9EW45PmHpAsI9V3dNJKkWhN7hvrmcHpQfmkjL5xhVu6PeGewAHrjPmV(bLwmeejAjjrTUKQnGbFzg0Z7lL7GJWBGk3wsWTtsIcPFJBlPWGZgj5ijl2)Epy88uMWrX(u40PiqM)s5DIjo1hYQOJjwBw)6ZrSoDwNI1O)x(XQOyKdkMGmRtXAdq6hRIIroOyIvqXQO(iRRFqPfZk4yDbSIEadRnaPFSkkg5GIjov3SdOWbhqpkcIWRF95io1hYAeHlL7795uDZoGchCa9Oii6(v2n7aQSCWlKlpMeP7s5(EFovo1hYAeXrveJaRIN9LvRH4i6bkdNQB2bu4GnWxrohjvGpo3pQIyeG80fX(37bJNNYe(OCQpKvR9sMNywNoR7lXQ5MLv7FVZ6GzTalRFuw7GJvPV0X6htCQUzhqHd2aFFueeH0VXTLeKlpMeXCZwG9JczKU8tIeL9V3d2U0ldLb9SlL59DkO4C57)OWh1su2)Epy7sVmug0ZUuM33PGIZ(z8IcFuov3SdOWbBGVpkcICyhDhKugl2VyiBqWiP86huAXIejKNUi2)Epy7sVmug0ZUuM33PGIZLV)Jc41npHGOAX(37bBx6LHYGE2LY8(ofuC2pJxuaVU5jeevlTIcgSbh2r3bjLXI9lod7XoukSJ55uqTeLB2bubh2r3bjLXI9lod7XoukmvUlhOVRLwrbd2Gd7O7GKYyX(fNFjxg2X8CkOjjWGn4Wo6oiPmwSFX5xYLHJI9PWPhT2jjWGn4Wo6oiPmwSFXzyp2Hsb86MNqiAwGbBWHD0DqszSy)IZWESdLchf7tHHGvSad2Gd7O7GKYyX(fNH9yhkf2X8CkOT5uFiRIoMy1AGcj4jXkmHsf8uqzfuSIrOmS(rzv8SVSAnehrpqzyfuSAGzfCSAJaRI9zNckRlakTV0XQ4zFz1z1CZYQ9V35uDZoGchSb((OiiYakKGNuEFPmgDUzXqE6I0cPFJBlPGbuibpPmmHrOmwIYaasyG4ky88uMWromcjj2)Epy88uMWhTTLw2)Epy7sVmug0ZUuM33PGIZLV)Jc41npfXkjj2)Epy7sVmug0ZUuM33PGIZ(z8Ic41npfXkTts6d03nFuSpfgcrMcN6dz1AEzijRnRFsWbZQ4zFzvsymR7RxScjyftgmRhf7tnfuw9cMv3g8xwxaRW)yuwBw)W)dkH5uDZoGchSb((OiiY4LHKz7FVd5YJjrWRFsWbd5Plsl7FVhSDPxgkd6zxkZ77uqX5Y3)rHJI9PWPlQbRKKy)79GTl9Yqzqp7szEFNcko7NXlkCuSpfoDrnyL2wC8EUmJcetx6IKwPyPLbaKWaXvW45PmHJI9PWPlAtsAzaajmqCfOyuGy6Y2GcoCuSpfoDrRLOS)9E45uWhbNPyuGy6IPAZurh0jIPWh1IbGKkV2WteUXR2T5uDZoGchSb((OiicV(1DPeYtxK1LuTb8ssPFz4B6BGk3wsWwW0UtbfhWajidFtFTy)79aE9R7szagiU4uFiRPTFmkRnRF4)bLWSkE2xw3xIvBGVSA)7DwT)lRfyzv8lvSIcaYPGYAhCSACwbhRumkqmDSAdkyov3SdOWbBGVpkcIWRF4)bLG80fjkK(nUTKcMB2cSFulTmaKu51gQb67M7oLKyaajmqCfmEEkt4OyFkC6I2KKOq6342skyGZgqbp7aklrzaiPYRn8eHB8kjPLbaKWaXvGIrbIPlBdk4WrX(u40fTwIY(37HNtbFeCMIrbIPlMQntfDqNiMcFulgasQ8Adpr4gVA3Mt9HSM2(XOS2S(H)hucZQn1bhXQ1afsWtIt1n7akCWg47JIGi86h(FqjipDrAzaajmqCfmGcj4jL3xkJrNBwC4OyFkmeSILOGV)ahkq2aJT0cPFJBlPGbuibpPmmHrOmjjgaqcdexbJNNYeok2NcdbR02cs)g3wsbdC2ak4zhq12IJ3ZLzuGy6sxutXIbGKkV2qnqF3C3jlrbF)bouGSbgBHmYbftHPYEHaN6dznTbkeBzfgSSc)VPGY6(sSsfmRGoRwdXr0dugiZk8)MckRpNc(iywPyuGy6IPAzfCSofR7lXQ0XlRqnWSc6S6fRIIroOyIt1n7akCWg47JIGiK(nUTKGC5XKiWGnF0d(NJIPAXqgPl)KiTS)9EW45PmHJI9PWPBflTS)9E4CKub(4C)OkIriCuSpfoDRKKeL9V3dNJKkWhN7hvrmcHpA7KKOS)9EW45PmHpABlTIY(37HNtbFeCMIrbIPlMQntfDqNiMcF02wAz)79azKdkMYyG0VWrX(u40HAGdXEessS)9EGmYbftz5V8lCuSpfoDOg4qShH2CQUzhqHd2aFFueeH)vFocYgemskV(bLwSirc5PlYr9JWVUTKSS(bL2WoXuEbz4HspsiHfhnBEjZtli9BCBjfGbB(Oh8phft1I5uDZoGchSb((OiikgaQ(CeKniyKuE9dkTyrIeYtxKJ6hHFDBjzz9dkTHDIP8cYWdLEKrlyfloA28sMNwq6342skad28rp4FokMQfZP6MDafoyd89rrqeEjP0VCx6hbzdcgjLx)GslwKiH80f5O(r4x3wsww)GsByNykVGm8qPhjK4XJI9PWwC0S5LmpTG0VXTLuagS5JEW)CumvlMt9HSgraSkRG)IhyI19Ly1CZYQ9V3zfCSk(Lkwra8zfgui2Y6RJKyLkWh6lRogL1fWk(Fqjov3SdOWbBGVpkcI6GZqzqpx((pcYtxehnBEjZto1hYAebquy1M6GJy1z1CZYQ4PGbIzfCSofEGjw9IvrXihumXP6MDafoyd89rrqu)FiKb9mj)fb5PlslYihumfMk7fcjjKroOykGbs)YtLJmjHmYbftb5V8lpvoY2wAfLbGKkV2qnqF3C3PKe47pWHcKnW4KKwoEpxMrbIPdcPLvS0cPFJBlPG5MTa7hnjXX75YmkqmDqiAPKKG0VXTLuyWzhqTT0cPFJBlPGbuibpPmmHrOmwIYaasyG4kyafsWtkVVugJo3S4WhnjjkK(nUTKcgqHe8KYWegHYyjkdaiHbIRGXZtzcF02TBBPLbaKWaXvW45PmHJI9PWPhTussGV)ahkq2aJtsC8EUmJcetx6PvkwmaGegiUcgppLj8rT0YaasyG4kqXOaX0LTbfC4OyFkmeCZoGkGx)6ZrbkcK5VuENykjjkdajvETHNiCJxTtsMAPdfi9LGZ9b67Mpk2NcdHitPTLwWGn4Wo6oiPmwSFXzyp2HsHJI9PWPlQjjrzaiPYRnuK5asWb3Mt9HSkkXOaX0XQnOGzv8lvSc(lEGjw9IvrXihumXk4y1AioIEGYW6Gz1Tb)LvWYQnX6htWbwBCKeRDWXQ1qCe9aLHt1n7akCWg47JIGikgfiMUSnOGH80fPfzKdkMcYF5xUOiSjjKroOykGbs)YffHnjHmYbftbVqixue2Ke7FVhSDPxgkd6zxkZ77uqX5Y3)rHJI9PWPlQbRKKy)79GTl9Yqzqp7szEFNcko7NXlkCuSpfoDrnyLKehVNlZOaX0LEALIfdaiHbIRGXZtzch5Wiyjk47pWHcKnW42wAzaajmqCfmEEkt4OyFkC6rlLKedaiHbIRGXZtzch5Wi0ojzQLouG0xco3hOVB(OyFkmeImfo1hYQ1qCe9aLHvXVuXQVSMwP8iRogLvXZ(c(lRsaEkOSUtmX6uSMgjaal)4LvWXAe5pEzfuSAaajmqCXQ4xQyTalRYPMckRFuwfp7lRwduibpjov3SdOWbBGVpkcImKKW74YSlhOvmvlKNUirbF)bouGSbgBbPFJBlPGboBaf8SdOS0QLJ3ZLzuGy6spTsXsl7FVhEof8rWzkgfiMUyQ2mv0bDIyk8rtsIYaqsLxB4jc34v7Ke7FVhSLaaS8J3Wh1I9V3d2saaw(XB4OyFkmeGykp2Yak4)Sb0JmdMYUCGwXuTHDIPmsx(P2TtsMAPdfi9LGZ9b67Mpk2NcdbiMYJTmGc(pBa9iZGPSlhOvmvByNykJ0LFQDsIbGKkV2qnqF3C3P2wAfLbGKkV2qnqF3C3PKehVNlZOaX0bbrnflTq6342skyafsWtkdtyektsIbaKWaXvWakKGNuEFPmgDUzXHJCyeA3Mt1n7akCWg47JIGOPm(v(oGcYtxKOGV)ahkq2aJTG0VXTLuWaNnGcE2buwA1YX75YmkqmDPNwPyPL9V3dpNc(i4mfJcetxmvBMk6Gormf(OjjrzaiPYRn8eHB8QDsI9V3d2saaw(XB4JAX(37bBjaal)4nCuSpfgcrlLhBzaf8F2a6rMbtzxoqRyQ2WoXugPl)u72jjtT0HcK(sW5(a9DZhf7tHHq0s5Xwgqb)NnGEKzWu2Ld0kMQnStmLr6Yp1ojXaqsLxBOgOVBU7uBlTIYaqsLxBOgOVBU7usIJ3ZLzuGy6GGOMILwi9BCBjfmGcj4jLHjmcLjjXaasyG4kyafsWtkVVugJo3S4WromcTBZP(qwff8oX(sywFbIzn(BEzfXXrxwra8z1pIvO(utbLvu6yftgqbZP6MDafoyd89rrqes)g3wsqU8ysehJgDPRHmqgPl)KiKroOykmvw(l)G0IgiPB2bub86xFokqrGm)LY7etpgfzKdkMctLL)YpiDliXJRlPAdyWxMb98(s5o4i8gOYTLemKoATHKUzhqfeF((gOiqM)s5DIPhtjarijgLKY8RJxIt9HSM2(XOS2S(H)hucZQ4xQyDFjw7d03L1bZQBd(lRlGvQGHmR9JQigbwhmRUn4VSUawPcgYSIa4ZQFeR(YAALYJS6yuwNIvVyvumYbftqMvRH4i6bkdRshVyw9cSV0XQO5rmzWScowra8zvm4lHzfGKoJJYAm4iw3xVyLtImfwrCC0LvXVuXkcGpRIbFjCHylRnRF4)bLyTaI5uDZoGchSb((OiicV(H)hucYtxKwtT0HcK(sW5(a9DZhf7tHHGOMK0Y(37HZrsf4JZ9JQigHWrX(uyia1ahI9iaPn0iB549CzgfiMoiz0sPTf7FVhohjvGpo3pQIyecF02TtsA549CzgfiMUhr6342sk4y0OlDnKbsB)79azKdkMYyG0VWrX(u4hHbBO)peYGEMK)Ic7yEIZhf7tbPHyWkPhzKPKK449CzgfiMUhr6342sk4y0OlDnKbsB)79azKdkMYYF5x4OyFk8JWGn0)hczqptYFrHDmpX5JI9PG0qmyL0JmYuABHmYbftHPYEHGLwrz)79GXZtzcF0KKOwxs1gWRFsWbhOYTLeCBlTAfLbaKWaXvW45PmHpAsIbGKkV2WteUXllrzaajmqCfOyuGy6Y2Gco8rBNKyaiPYRnud03n3DQTLwrzaiPYRnGKQ9fHljjk7FVhmEEkt4JMK449CzgfiMU0tRuANK0ADjvBaV(jbhCGk3wsWwS)9EW45PmHpQLw2)EpGx)KGdoGx38ecrljXX75YmkqmDPNwP0UDsI9V3dgppLjCuSpfoDrJLOS)9E4CKub(4C)OkIri8rTe16sQ2aE9tco4avUTKG5uDZoGchSb((OiiQiX5yaOG80fPL9V3dKroOykl)LFHpAsslZRFqjSiq0YrMx)Gs5DIjiyL2jjMx)GsyrIwBloA28sMNCQUzhqHd2aFFuee96YEogakipDrAz)79azKdkMYYF5x4JMK0Y86huclceTCK51pOuENyccwPDsI51pOewKO12IJMnVK5jNQB2bu4GnW3hfbr9VuMJbGcYtxKw2)Epqg5GIPS8x(f(OjjTmV(bLWIarlhzE9dkL3jMGGvANKyE9dkHfjATT4OzZlzEYP(qwHuaIcRGIvdmR2)Lv0dyWSkEKswbLebwTjw)ycM1PWdmXA0)l)yvumYbftCQUzhqHd2aFFueej2VBaxg0ZK8xeN6dzv0XeRnRF95iwxaROhWWAdq6hRIIroOyIvWXQ4xQyDkwJ(F5hRIIroOyIt1n7akCWg47JIGi86xFocYtxeYihumfMkl)LFjjKroOykGbs)YffHnjHmYbftbVqixue2Ke7FVhe73nGld6zs(lk8rTy)79azKdkMYYF5x4JMK0Y(37bJNNYeok2Ncdb3SdOcIpFFdueiZFP8oXKf7FVhmEEkt4J2Mt1n7akCWg47JIGiXNVVCQUzhqHd2aFFueeD)k7MDavwo4fYLhtI0DPCFVpNkN6dzTz9d)pOeRDWXAmajft1Y6VKegZ6hpfuwtdaXToNQB2bu4q3LY99(IGx)W)dkb5Plsu3VOo4GsbBx6LHYGE2LY8(ofuCGEW)GIsWCQpKvR54L19LyfgSSkE2xw3xI1yaEzDNyI1fWQddZ6V2rY6(sSg7rGv4)57akwhmRVZgyT5x95iwpk2NcZA8xUdQCiywxaRX(AEzngaQ(CeRW)Z3buCQUzhqHdDxk337)Oiic)R(CeKniyKuE9dkTyrIeYtxeyWgIbGQphfok2NcN(rX(uyineHiKmsrdNQB2bu4q3LY99(pkcIIbGQphXPYP(qwTMlnFPVeMvXV0(shRnRF4)bLyTicgZ6cy1My9JjywxaRpjcL1pkR7lXAA7ip2Eky6y1(37ScowxaRW)yuwTPo4iwnGcj4jXP6MDafoGxrWRF4)bLG80f5(f1bhukStmjgCvg(ip2Eky6c0d(huuc2slYihumfMk7fcwIQvl7FVh2jMedUkdFKhBpfmDHJI9PWPd1ahI9i8ykHiT0ImYbftHPY2G9njHmYbftHPYyG0VKeYihumfK)YVCrryBNKy)79WoXKyWvz4J8y7PGPlCuSpfoD3SdOc41V(CuGIaz(lL3jMEmLqKwArg5GIPWuz5V8ljHmYbftbmq6xUOiSjjKroOyk4fc5IIW2UDssu2)EpStmjgCvg(ip2Eky6cF02jjTS)9EW45PmHpAscs)g3wsbdOqcEszycJqzABXaasyG4kyafsWtkVVugJo3S4WromcT5uFiRIoMyfXHD0DqsS2i2Vywf)sfR7lDeRdM1cWQB2bjXkwSFXqMvhZQ0xIvhZkkaJhBjXkOyfl2Vywfp7lRqKvWXANethR41npXScowbfRoRr7rwXI9lMvmG191xw3xI1IeZkwSFXS63nijmRrK)4LvVV0X6(6lRyX(fZkfb05imNQB2bu4aEFuee5Wo6oiPmwSFXq2GGrs51pO0IfjsipDrIcgSbh2r3bjLXI9lod7XoukSJ55uqTeLB2bubh2r3bjLXI9lod7XoukmvUlhOVRLwrbd2Gd7O7GKYyX(fNFjxg2X8CkOjjWGn4Wo6oiPmwSFX5xYLHJI9PWPBL2jjWGn4Wo6oiPmwSFXzyp2Hsb86MNqiAwGbBWHD0DqszSy)IZWESdLchf7tHHq0Sad2Gd7O7GKYyX(fNH9yhkf2X8CkOCQpKvrhtywTgOqcEsSoDwnoRdM1pkRGJveaFw9JyfMWiuMPGYQ1qCe9aLHvXZ(YQ1afsWtIvVGzfbWNv)iwTjjqmRIAkS6yuov3SdOWb8(OiiYakKGNuEFPmgDUzXqE6I0cPFJBlPGbuibpPmmHrOmwIYaasyG4ky88uMWromcjj2)Epy88uMWhTTfhVNlZOaX0bbrnflTS)9EGmYbftz5V8lCuSpfo9itjjX(37bYihumLXaPFHJI9PWPhzkTts6d03nFuSpfgcrMcN6dznTJ6hHFzfgSyw)LKWywTgIJOhOmS(6ywLegZ6(6fRwHvmzWSEuSp1uqHmR7lXksQ2xeowT)9oRGJ19Ly9jc34fR2)EN1bZQBd(lRlG1UlLSc6Dw9cMvVqGvrXihumX6Gz1Tb)L1fWkfb05iov3SdOWb8(OiicPFJBljixEmjcmyZh9G)5OyQwmKr6Ypjsl7FVhmEEkt4OyFkC6wXsl7FVhohjvGpo3pQIyechf7tHt3kjjrz)79W5iPc8X5(rveJq4J2ojjk7FVhmEEkt4JMK449CzgfiMoieTuABPvu2)Ep8Ck4JGZumkqmDXuTzQOd6eXu4JMK449CzgfiMoieTuABPL9V3dKroOykJbs)chf7tHthQboe7rijX(37bYihumLL)YVWrX(u40HAGdXEeAZP6MDafoG3hfbrXaq1NJGSbbJKYRFqPflsKqE6ICu)i8RBljlRFqPnStmLxqgEO0JeIwA5OzZlzEAbPFJBlPamyZh9G)5OyQwCBov3SdOWb8(Oiic)R(CeKniyKuE9dkTyrIeYtxKJ6hHFDBjzz9dkTHDIP8cYWdLEKq0slhnBEjZtli9BCBjfGbB(Oh8phft1IBZP6MDafoG3hfbr4LKs)YDPFeKniyKuE9dkTyrIeYtxKJ6hHFDBjzz9dkTHDIP8cYWdLEKqclTC0S5LmpTG0VXTLuagS5JEW)CumvlUnN6dzv0XeRreaRYkOy1aZQ4zFb)LvJJIofuov3SdOWb8(OiiQdodLb9C57)iipDrC0S5Lmp5uFiRIoMyDFjwt7HQ9fHJv3EKZIaRGIvdmRIFhZlRdMvBQdoIvRH4i6bkdNQB2bu4aEFueeDosQaFCUFufXia5PlI9V3dgppLj8r5uFiRIoMynI0PGpcM1g05MfZQ4zFzTbi9JvrXihumXQxWSgD)sSFS(ljHXSkb4PGYQZ6htCQUzhqHd49rrqefJcetx2guWqE6I0QL9V3dKroOykJbs)chf7tHtpYussS)9EGmYbftz5V8lCuSpfo9itPTfdaiHbIRGXZtzchf7tHtpAPyPL9V3dO3edo4XLz)mEnMm6xI9lG0LFccquutjjjQ7xuhCqPa6nXGdECz2pJxJjJ(Ly)c0d(huucUD7Ke7FVhqVjgCWJlZ(z8Amz0Ve7xaPl)u6IarrBkjjgaqcdexbJNNYeoYHrWslhVNlZOaX0LEALsscs)g3wsHbNDa1Mt9HSk6yIvRH4i6bkdRIN9LvRbkKGNeREbZkmOqSLvas6eFZsSgD)sSFCQUzhqHd49rrqKHKeEhxMD5aTIPAH80fjk47pWHcKnWyli9BCBjfmWzdOGNDaLLwoEpxMrbIPl90kflTS)9E45uWhbNPyuGy6IPAZurh0jIPWhnjjkdajvETHNiCJxTtsmaKu51gQb67M7oLKG0VXTLuyWzhqjj2)Epylbay5hVHpQf7FVhSLaaS8J3WrX(uyiaXuESvR0csF)I6GdkfqVjgCWJlZ(z8Amz0Ve7xGEW)GIsWTFSLbuW)zdOhzgmLD5aTIPAd7etzKU8tTB32su2)Epy88uMWh1sROmaKu51gQb67M7oLKyaajmqCfmGcj4jL3xkJrNBwC4JMKm1shkq6lbN7d03nFuSpfgcgaqcdexbdOqcEs59LYy05Mfhok2Nc)iKijzQLouG0xco3hOVB(OyFkmKesgPOjfiaXuESLbuW)zdOhzgmLD5aTIPAd7etzKU8tTBZP6MDafoG3hfbrtz8R8DafKNUirbF)bouGSbgBbPFJBlPGboBaf8SdOS0YX75YmkqmDPNwPyPL9V3dpNc(i4mfJcetxmvBMk6Gormf(OjjrzaiPYRn8eHB8QDsIbGKkV2qnqF3C3PKeK(nUTKcdo7akjX(37bBjaal)4n8rTy)79GTeaGLF8gok2NcdHOLYJTALwq67xuhCqPa6nXGdECz2pJxJjJ(Ly)c0d(huucU9JTmGc(pBa9iZGPSlhOvmvByNykJ0LFQD72wIY(37bJNNYe(OwAfLbGKkV2qnqF3C3PKedaiHbIRGbuibpP8(szm6CZIdF0KKPw6qbsFj4CFG(U5JI9PWqWaasyG4kyafsWtkVVugJo3S4WrX(u4hHejjtT0HcK(sW5(a9DZhf7tHHKqYifnPaHOLYJTmGc(pBa9iZGPSlhOvmvByNykJ0LFQDBo1hYAAp(nUTKy9JjywbfRU9iNDimR7RVSk2RL1fWQnXk2rsWS2bhRwdXr0dugwXaw3xFzDFjey1pQwwf74LGznI8hVSAtDWrSUVumNQB2bu4aEFueeH0VXTLeKlpMeb7iPChCzJNNYazKU8tIeLbaKWaXvW45PmHJCyessIcPFJBlPGbuibpPmmHrOmwmaKu51gQb67M7oLKaF)bouGSbgZP(qwfDmHznIaikSoDwNIvVyvumYbftS6fmR7neM1fWQCkI1zz9JYQ4zFzn6(Ly)GmRwdXr0dugw9cMveh2r3bjXAJy)I5uDZoGchW7JIGO()qid6zs(lcYtxeYihumfMk7fcwC0S5LmpTy)79a6nXGdECz2pJxJjJ(Ly)ciD5NGaef1uS0cgSbh2r3bjLXI9lod7XoukSJ55uqtsIYaqsLxBOiZbKGdUTfK(nUTKcyhjL7GlB88ugo1hYQOJjwbfTVS2S(1DPKv0dyWSoDwBw)6UuY6GleBz9JYP6MDafoG3hfbr41VUlLqE6Iy)79aOO9fNrPZqO7aQWh1I9V3d41VUlLHJ6hHFDBjXP6MDafoG3hfbrgVmKmB)7DixEmjcE9tcoyipDrS)9EaV(jbhC4OyFkmeSILw2)Epqg5GIPmgi9lCuSpfoDRKKy)79azKdkMYYF5x4OyFkC6wPTfhVNlZOaX0LEALcNQB2bu4aEFueeHx)6Uuc5PlY6sQ2aEjP0Vm8n9nqLBljylyA3PGIdyGeKHVPVwS)9EaV(1DPmadexCQpK102pgfZQJrz1M6GJy1AGcj4jX6hpfuw3xIvRbkKGNeRgqbp7akwxaRMxY8K1PZQ1afsWtI1bZQB2VlLiWQBd(lRlGvBIvJJxov3SdOWb8(OiicV(H)hucYtxedajvETHAG(U5Utwq6342skyafsWtkdtyekJfdaiHbIRGbuibpP8(szm6CZIdhf7tHHGvSef89h4qbYgymN6dzv0XeRnRFDxkzv8SVSIxsk9Jv4B6lREbZAbyTz9tcoyiZQ4xQyTaS2S(1DPK1bZ6hfYSIa4ZQFeRtXA0)l)yvumYbftqMv0dyyn6(Ly)yv8lvS62aKeRPvkS6yuwbhRomQVdsIvSy)Iz91XSkAEetgmRhf7tnfuwbhRdM1PyTlhOVlNQB2bu4aEFueeHx)6Uuc5PlY6sQ2aEjP0Vm8n9nqLBljylrTUKQnGx)KGdoqLBljyl2)EpGx)6UugoQFe(1TLKLw2)Epqg5GIPS8x(fok2NcNoKWczKdkMctLL)Ypl2)EpGEtm4GhxM9Z41yYOFj2Vasx(jiarRKssI9V3dO3edo4XLz)mEnMm6xI9lG0LFkDrGOvsXIJ3ZLzuGy6spTsjjbgSbh2r3bjLXI9lod7XoukCuSpfoDrtsIB2bubh2r3bjLXI9lod7XoukmvUlhOVBBlrzaajmqCfmEEkt4ihgbo1hYQOJjwXywbfTVSIEadMvVGzf(hJYQJrzv8lvSAnehrpqzyfCSUVeRiPAFr4y1(37SoywDBWFzDbS2DPKvqVZk4yfbWhXGz14OS6yuov3SdOWb8(OiicV(H)hucYtxe7FVhafTV4Srs(Lro4buHpAsI9V3dpNc(i4mfJcetxmvBMk6Gormf(Ojj2)Epy88uMWh1sl7FVhohjvGpo3pQIyechf7tHHaudCi2JaK2qJSLJ3ZLzuGy6GKrlL2wS)9E4CKub(4C)OkIri8rtsIY(37HZrsf4JZ9JQigHWh1sugaqcdexHZrsf4JZ9JQigHWromcjjrzaiPYRnGKQ9fHRDsIJ3ZLzuGy6spTsXczKdkMctL9cbo1hYQ1peyDbSg7pjw3xIvBcVSc6S2S(jbhmR2iWkEDZZPGY6SS(rz9b)J5PebwNI1gG0pwffJCqXeR2)L1O7xI9J1bxlRUn4VSUawTjwrpGXqWCQUzhqHd49rrqeE9d)pOeKNUiRlPAd41pj4Gdu52sc2su3VOo4GsHDIjXGRYWh5X2tbtxGEW)GIsWwAz)79aE9tco4WhnjXX75YmkqmDPNwP02I9V3d41pj4Gd41npHq0S0Y(37bYihumLXaPFHpAsI9V3dKroOykl)LFHpABl2)EpGEtm4GhxM9Z41yYOFj2Vasx(jiarrBkwAzaajmqCfmEEkt4OyFkC6rMsssui9BCBjfmGcj4jLHjmcLXIbGKkV2qnqF3C3P2CQpKvrhtS2S(H)huI1PyTbi9JvrXihumbzwHbfITSkPL1zzf9agwJUFj2pwBTV(Y6Gz91lyjbZQncSsZ(shR7lXAZ6x3LswLtrScow3xIvhJMEALcRYPiw7GJ1M1p8)GsTHmRWGcXwwbiPt8nlXQxSckAFzf9agw9cMvjTSUVeRUnajXQCkI1xVGLeRnRFsWbZP6MDafoG3hfbr41p8)GsqE6Ie19lQdoOuyNysm4Qm8rES9uW0fOh8pOOeSLw2)EpGEtm4GhxM9Z41yYOFj2Vasx(jiarrBkjj2)EpGEtm4GhxM9Z41yYOFj2Vasx(jiarRKIL1LuTb8ssPFz4B6BGk3wsWTTy)79azKdkMYyG0VWrX(u40fTwiJCqXuyQmgi9Zsu2)EpakAFXzu6me6oGk8rTe16sQ2aE9tco4avUTKGTyaajmqCfmEEkt4OyFkC6IwlTmaGegiUcpNc(i4mgDUzXHJI9PWPlAtsIYaqsLxB4jc34vBo1hYQOJjwJbGcZk8)MckRr)V8JvrXihumXk4yfbWhXGzfSV0jEWeRaK0zCuwnV(bLWCQUzhqHd49rrqurIZXaqb5Plsl7FVhiJCqXuw(l)cF0KKwMx)GsyrGOLJmV(bLY7etqWkTtsmV(bLWIeT2wC0S5LmpTG0VXTLua7iPChCzJNNYWP6MDafoG3hfbrVUSNJbGcYtxKw2)Epqg5GIPS8x(f(OwIYaqsLxB4jc34vssl7FVhEof8rWzkgfiMUyQ2mv0bDIyk8rTyaiPYRn8eHB8QDsslZRFqjSiq0YrMx)Gs5DIjiyL2jjMx)GsyrIwsI9V3dgppLj8rBBXrZMxY80cs)g3wsbSJKYDWLnEEkdNQB2bu4aEFuee1)szogakipDrAz)79azKdkMYYF5x4JAjkdajvETHNiCJxjjTS)9E45uWhbNPyuGy6IPAZurh0jIPWh1IbGKkV2WteUXR2jjTmV(bLWIarlhzE9dkL3jMGGvANKyE9dkHfjAjj2)Epy88uMWhTTfhnBEjZtli9BCBjfWosk3bx245PmCQpKvrhtScPaefwbfRgyov3SdOWb8(OiisSF3aUmONj5Vio1hYQOJjwBw)6ZrSUawrpGH1gG0pwffJCqXeKz1AioIEGYW6RJzvsymR7etSUVEXQZkKY57lRueiZFjwLuFzfCSckjcSg9)YpwffJCqXeRdM1pkNQB2bu4aEFueeHx)6ZrqE6Iqg5GIPWuz5V8ljHmYbftbmq6xUOiSjjKroOyk4fc5IIWMKy)79Gy)UbCzqptYFrHpQf7FVhiJCqXuw(l)cF0KKw2)Epy88uMWrX(uyi4MDavq857BGIaz(lL3jMSy)79GXZtzcF02CQpKvrhtScPC((YkyFPt8Gjwf)oMxwhmRtXAdq6hRIIroOycYSAnehrpqzyfCSUawrpGH1O)x(XQOyKdkM4uDZoGchW7JIGiXNVVCQpK1icxk337ZP6MDafoG3hfbr3VYUzhqLLdEHC5XKiDxk337lScRGa]] )


end