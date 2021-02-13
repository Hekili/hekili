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


    spec:RegisterPack( "Balance", 20210213, [[davSveqibQhPkOlbcYMOK(eePgLc5ukuRIqsELQqZcI4wcqAxc9lqudteCmb0YarEMaX0OePRrjyBGa9ncj14eG4CQcyDcKyEGq3JqSprKdcrYcfH8qkHMOiu1fjKyJGa6JGaOrkqs4KcKALIOEPajrZuek3eeG2jLO(PajPgQiuzPcKupvbtvaCvkrSvbss(kiOmwqq1Ej4VIAWKomvlMs9ykMmOUmYMv0NHWOvLoTuRgeaETQOzt0Tf0UL8BGHdPJRkqlxLNd10v66QQTdsFNqnEcPope16fGA(I0(rTqGcbqya2xsWYqkbifycqkWGedmiqkblvulmSiJscdOU5PJGegkpKegsKl9YqcdOoYsGdleaHbm4Fgsy4DxuCqbYqgrVVF7ObeczCh(L(2GYC(CHmUdnqwyW(3YnOlbBHbyFjbldPeGuGjaPadsmWGaPecYdim4)9fCcddDOffgEByyQeSfgGjSry4HpK1e5sVmeRj(73WCYp8HScbs233pKznWGGewHucqkqozo5h(qwT4RxiiCqHt(HpK1akRifmmbZ6aq6hRjI8WiN8dFiRbuwT4Rxiiywx)qqBUNSACmHzDbSAq2iP86hcAXro5h(qwdOSgutHaOemR)QidHX(HmRq9RDBjHzDuhPisyf9iOz86h(FiiwdOjXk6rqJ41p8)qqJJCYp8HSgqzfPGcAywrpY44TleScHD((YApzTxKgZ6(sSk(afcwffJSrXuKt(HpK1akRqa9NeRweuqbpjw3xI1b0(6fZQZQS3vsSgcoI1PKeDBljwh1twrg8z91HlKEz9Txw7LvCh(LRxe4JLiZQ4EFznrbvJubG1hz1IKKWB7swrkzJOcPArcR9I0WSIF2OJJcdYgVyHaimatt)lxHaiy5afcGWGB2gucdyG0VSn5Hcdu52scwircRGLHKqaegOYTLeSqIegaOcdyAfgCZ2GsyaQFTBljHbOU8tcdyuskZRFiOfhXRFtxkznjwdKvRSoI1GzDDjvBeV(jbhCKk3wsWSMMY66sQ2iEjP0Vm81ZnsLBljywhZAAkRyuskZRFiOfhXRFtxkznjwHKWamHnxJUnOeggOfZksbefwbfRb5rwf37l4VScF9Cz1lywf37lRdRFsWbZQxWScPhzfSV0jUXKWau)YLhscdno7asyfSCqecGWavUTKGfsKWaavyatRWGB2gucdq9RDBjjma1LFsyaJsszE9dbT4iE9B2hXAsSgOWamHnxJUnOeggOfZQrsouIvXVuX6W63SpIvJxS(2lRq6rwx)qqlMvXVT5L1gZ6rscQxlRtWX6(sSkkgzJIjwxaR2eROhnP7iyHbO(LlpKegAC2ijhkjScw2sfcGWavUTKGfsKWGB2gucd20HP7zxiegGjS5A0TbLWGLGjwTPdt3ZUqWQ4EFz14Scow95shRweuqbpjw7IvJlmyUEPRDHHrSgmRgauQ8AJvJ4DZtNynnL1Gz1aasyG4kAafuWtkVVugJ2xV44hL1XSALv7)CgnEUlt8JkScw2ccbqyGk3wsWcjsyWC9sx7cd2)5mA8CxM4rHExywtI1atqyaMWMRr3gucdjoWYQ4EFz14SUV(YAJlKEz1znX9Ly)yf9agHb3SnOegqbBdkHvWYqqHaimqLBljyHejmaqfgW0km4MTbLWau)A3wscdqD5NegmulzDeRJyTRLouG0xcopBeVB(OqVlmRbuwd0cSgqz1aasyG4kA8CxM4rHExywhZkKznWascSoMvry1qTK1rSoI1Uw6qbsFj48Sr8U5Jc9UWSgqznqlWAaL1aHucSgqz1aasyG4kAafuWtkVVugJ2xV44rHExywhZkKznWascSoM10uwnaGegiUIgp3LjEuO3fM1KyTRLouG0xcopBeVB(OqVlmRPPSAaajmqCfnGck4jL3xkJr7RxC8OqVlmRjXAxlDOaPVeCE2iE38rHExywdOSgycSMMYAWSAaqPYRnwnI3npDsyaMWMRr3gucdw0LMV0xcZQ4xAFPJ1pUleSArqbf8KyTaIzvClLS6sjqmRid(SUawXBlLSAC8Y6(sSI9qIvpe8RLvWKvlckOGN0JwePGCqxgwnoEXcdq9lxEijmyafuWtkdtyKlJWkyzrTqaegOYTLeSqIegaOcdyAfgCZ2GsyaQFTBljHbOU8tcdJynywPh83OOeCKcrr(ixMbhC5LHynnLvdaiHbIRifII8rUmdo4Yldfpk07cZkeznqiycSAL1Gz1aasyG4ksHOiFKlZGdU8YqXJCyKzDmRPPSAaqPYRn(e5R9syaMWMRr3gucdwcMGzDbSctshzw3xI1p2rqScMSArKcYbDzyv8lvS(XDHGvyW3wsSckw)ysyaQF5YdjHbdC2ak4EBqjScwoGieaHbQCBjblKiHbycBUgDBqjmyjyIvrjef5JCjRbvFWLxgIviLaMmywTPj4iwDwTisb5GUmS(XuuyO8qsyGcrr(ixMbhC5LHegmxV01UWGbaKWaXv045UmXJc9UWScrwHucSALvdaiHbIRObuqbpP8(szmAF9IJhf6DHzfIScPeynnL1zJ4DZhf6DHzfISgerTWGB2gucduikYh5Ym4GlVmKWky5hqiacdu52scwircdWe2Cn62GsyWsWeRdGVusBxiynO(BJmRqqmzWSAttWrS6SArKcYbDzy9JPOWq5HKWag8LsA3UqKVVnYcdMRx6AxyWaasyG4kA8CxM4rHExywHiRqqwTYAWSc1V2TLu0akOGNugMWixgwttz1aasyG4kAafuWtkVVugJ2xV44rHExywHiRqqwTYku)A3wsrdOGcEszycJCzynnL1zJ4DZhf6DHzfIScjlim4MTbLWag8LsA3UqKVVnYcRGLdmbHaimqLBljyHejm4MTbLWqxyZ9x3ws5h871(dZWe02qcdMRx6AxyW(pNrJN7Ye)OcdLhscdDHn3FDBjLFWVx7pmdtqBdjScwoWafcGWavUTKGfsKWGB2gucd711tAduyaMWMRr3gucdb4TXS2ywDwpFFPJvs62GZxIvXoYSUawd9NeRUuYkOy9JjwXRVSUxxpPfZ6cy1Myv2fbZ6hLvX9(YQfrkih0LHvVGz1IGck4jXQxWS(XeR7lXkKkywXsWYkOy1aZApz1gSVSUxxpPfZQFeRGI1pMyfV(Y6ED9KwSWG56LU2fggXku)A3wsrqL)ykVxxpPLvrynqwttzfQFTBlPiOYFmL3RRN0YQiSgewhZQvwhXQ9FoJgp3Lj(rznnLvdaiHbIROXZDzIhf6DHz9rwHeRjX6ED9K24gy0aasyG4kc)pFBqXQvwhXAWSAaqPYRnwnI3npDI10uwdMvO(1UTKIgqbf8KYWeg5YW6ywTYAWSAaqPYRn(e5R9I10uwnaOu51gRgX7MNoXQvwH6x72skAafuWtkdtyKldRwz1aasyG4kAafuWtkVVugJ2xV44hLvRSgmRgaqcdexrJN7Ye)OSAL1rSoIv7)CgjJSrXuw(l)Ihf6DHznjwdmbwttz1(pNrYiBumLXaPFXJc9UWSMeRbMaRJz1kRbZ69lAcoeu02LEzOmyMDPmVVDHahPYTLemRPPSoIv7)CgTDPxgkdMzxkZ7BxiW5Y3)rr86MNSkcRwG10uwT)Zz02LEzOmyMDPmVVDHaN9Z4ffXRBEYQiSAbwhZ6ywttz1(pNXNDbFeCMcrbIPlKQntfDi6aMIFuwhZAAkRZgX7Mpk07cZkezfsjWAAkRq9RDBjfbv(JP8ED9KwwfH1eewblhiKecGWavUTKGfsKWG56LU2fgG6x72skcQ8ht5966jTSkcRbHvRSgmR711tAJBGXJCyKZgaqcdexSMMY6iwT)Zz045UmXpkRPPSAaajmqCfnEUlt8OqVlmRpYkKynjw3RRN0gxifnaGegiUIW)Z3guSAL1rSgmRgauQ8AJvJ4DZtNynnL1GzfQFTBlPObuqbpPmmHrUmSoMvRSgmRgauQ8AJpr(AVynnLvdakvETXQr8U5PtSALvO(1UTKIgqbf8KYWeg5YWQvwnaGegiUIgqbf8KY7lLXO91lo(rz1kRbZQbaKWaXv045UmXpkRwzDeRJy1(pNrYiBumLL)YV4rHExywtI1atG10uwT)ZzKmYgftzmq6x8OqVlmRjXAGjW6ywTYAWSE)IMGdbfTDPxgkdMzxkZ7BxiWrQCBjbZAAkRJy1(pNrBx6LHYGz2LY8(2fcCU89FueVU5jRIWQfynnLv7)CgTDPxgkdMzxkZ7BxiWz)mErr86MNSkcRwG1XSoM1XSMMYQ9FoJp7c(i4mfIcetxivBMk6q0bmf)OSMMY6Sr8U5Jc9UWScrwHucSMMYku)A3wsrqL)ykVxxpPLvrynbHb3SnOeg2RRN0cjHvWYbgeHaimqLBljyHejm4MTbLWWht5EPqSWamHnxJUnOegSemHz1Lswb7lDSckw)yI1EPqmRGIvdSWG56LU2fgS)Zz045UmXpkRPPSAaqPYRnwnI3npDIvRSc1V2TLu0akOGNugMWixgwTYQbaKWaXv0akOGNuEFPmgTVEXXpkRwznywnaGegiUIgp3Lj(rz1kRJyDeR2)5msgzJIPS8x(fpk07cZAsSgycSMMYQ9FoJKr2OykJbs)Ihf6DHznjwdmbwhZQvwdM17x0eCiOOTl9YqzWm7szEF7cbosLBljywttz9(fnbhckA7sVmugmZUuM33UqGJu52scMvRSoIv7)CgTDPxgkdMzxkZ7BxiW5Y3)rr86MNSMeRbH10uwT)Zz02LEzOmyMDPmVVDHaN9Z4ffXRBEYAsSgewhZ6ywttz1(pNXNDbFeCMcrbIPlKQntfDi6aMIFuwttzD2iE38rHExywHiRqkbHvWYbAPcbqyGk3wsWcjsyaMWMRr3gucdjEY0WeRUzBqXQSXlR2oMGzfuSI797BdkiljenwyWnBdkHH7xz3SnOYYgVcd49AZky5afgmxV01UWau)A3wsXgNDajmiB8MlpKegCajScwoqlieaHbQCBjblKiHbZ1lDTlmC)IMGdbfTDPxgkdMzxkZ7BxiWr6b)nkkblmG3RnRGLduyWnBdkHH7xz3SnOYYgVcdYgV5YdjHbBGVcRGLdeckeaHbQCBjblKiHb3SnOegUFLDZ2GklB8kmiB8MlpKegWRWkScd2aFfcGGLduiacdu52scwircdUzBqjmCouQaFCEEufWilmatyZ1OBdkHbiWJQagzwf37lRwePGCqxgHbZ1lDTlmy)NZOXZDzIFuHvWYqsiacdu52scwircdauHbmTcdUzBqjma1V2TLKWaux(jHHGz1(pNrBx6LHYGz2LY8(2fcCU89Fu8JYQvwdMv7)CgTDPxgkdMzxkZ7BxiWz)mErXpQWamHnxJUnOegS4lzEIzTNSUVeRMRxwT)ZjRnM1cSS(rzDcowL(shRFmjma1VC5HKWG56Ta7hvyfSCqecGWavUTKGfsKWGB2gucdoSJUnukJf7xOWG56LU2fgS)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEYkez1sz1kR2)5mA7sVmugmZUuM33UqGZ(z8II41npzfISAPSAL1rSgmRWGn6Wo62qPmwSFHzyp0rqXTnp7cbRwznywDZ2Gk6Wo62qPmwSFHzyp0rqXUYtzJ4Dz1kRJynywHbB0HD0THszSy)cZVKlJBBE2fcwttzfgSrh2r3gkLXI9lm)sUmEuO3fM1KyniSoM10uwHbB0HD0THszSy)cZWEOJGI41npzfISgewTYkmyJoSJUnukJf7xyg2dDeu8OqVlmRqKvlWQvwHbB0HD0THszSy)cZWEOJGIBBE2fcwhlmyq2iP86hcAXcwoqHvWYwQqaegOYTLeSqIegCZ2GsyWakOGNuEFPmgTVEXcdWe2Cn62GsyWsWeRweuqbpjwHjuQG7cbRGIvmYLH1pkRI79LvlIuqoOldRGIvdmRGJvBKzvS3BxiyDbiO9Lowf37lRoRMRxwT)ZPWG56LU2fggXku)A3wsrdOGcEszycJCzy1kRbZQbaKWaXv045UmXJCyKznnLv7)CgnEUlt8JY6ywTY6iwT)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEYQiSAbwttz1(pNrBx6LHYGz2LY8(2fcC2pJxueVU5jRIWQfyDmRPPSoBeVB(OqVlmRqK1atqyfSSfecGWavUTKGfsKWGB2gucdgVmKmB)NtHbZ1lDTlmmIv7)CgTDPxgkdMzxkZ7BxiW5Y3)rXJc9UWSMeRwA0cSMMYQ9FoJ2U0ldLbZSlL59Tle4SFgVO4rHExywtIvlnAbwhZQvwD8EUmJcethRjjcRpqcSAL1rSAaajmqCfnEUlt8OqVlmRjXQOM10uwhXQbaKWaXvKcrbIPlBdk44rHExywtIvrnRwznywT)Zz8zxWhbNPquGy6cPAZurhIoGP4hLvRSAaqPYRn(e5R9I1XSowyW(pN5YdjHb86NeCWcdWe2Cn62GsyWIEzijRdRFsWbZQ4EFzvsymR7RxScbzftgmRhf6D1fcw9cMv3g8xwxaRW)quwhw)W)dbHfwbldbfcGWavUTKGfsKWG56LU2fgwxs1gXljL(LHVEUrQCBjbZQvwX0UDHahXajidF9Cz1kR2)5mIx)MUugHbIlHb3SnOegWRFtxkfwbllQfcGWavUTKGfsKWGB2gucd41p8)qqcdWe2Cn62GsyiX)drzDy9d)peeMvX9(Y6(sSAd8Lv7)CYQ9FzTalRIFPIvuaq2fcwNGJvJZk4yLcrbIPJvBqblmyUEPRDHHGzfQFTBlPO56Ta7hLvRSoIvdakvETXQr8U5PtSMMYQbaKWaXv045UmXJc9UWSMeRIAwttznywH6x72skAGZgqb3BdkwTYAWSAaqPYRn(e5R9I10uwhXQbaKWaXvKcrbIPlBdk44rHExywtIvrnRwznywT)Zz8zxWhbNPquGy6cPAZurhIoGP4hLvRSAaqPYRn(e5R9I1XSowyfSCariacdu52scwircdUzBqjmGx)W)dbjmatyZ1OBdkHHe)peL1H1p8)qqywTPj4iwTiOGcEscdMRx6AxyyeRgaqcdexrdOGcEs59LYy0(6fhpk07cZkez1cSAL1Gzf((nCSazdmMvRSoIvO(1UTKIgqbf8KYWeg5YWAAkRgaqcdexrJN7Yepk07cZkez1cSoMvRSc1V2TLu0aNnGcU3guSoMvRS649CzgfiMowtIvlnbwTYQbaLkV2y1iE380jwTYAWScF)gowGSbgZQvwjJSrXuSRSxilScw(becGWavUTKGfsKWaavyatRWGB2gucdq9RDBjjma1LFsyyeR2)5mA8CxM4rHExywtIvlWQvwhXQ9FoJNdLkWhNNhvbmYXJc9UWSMeRwG10uwdMv7)CgphkvGpoppQcyKJFuwhZAAkRbZQ9FoJgp3Lj(rzDmRwzDeRbZQ9FoJp7c(i4mfIcetxivBMk6q0bmf)OSoMvRSoIv7)CgjJSrXugdK(fpk07cZAsSIWahdDrZAAkR2)5msgzJIPS8x(fpk07cZAsSIWahdDrZ6yHbycBUgDBqjmK4bfsVScdwwH)xxiyDFjwPcMvWKvlIuqoOldsyf(FDHG1NDbFemRuikqmDHuTScow7I19Lyv64Lvegywbtw9IvrXiBumjma1VC5HKWamyZh9G)(OqQwSWky5atqiacdu52scwircdUzBqjmG)1SpsyWC9sx7cdhnpc)62sIvRSU(HG242HuEbz4MynjwdecYQvwD0S5Lmpz1kRq9RDBjfHbB(Oh83hfs1IfgmiBKuE9dbTyblhOWky5aduiacdu52scwircdUzBqjmeca1SpsyWC9sx7cdhnpc)62sIvRSU(HG242HuEbz4MynjwdmirlWQvwD0S5Lmpz1kRq9RDBjfHbB(Oh83hfs1IfgmiBKuE9dbTyblhOWky5aHKqaegOYTLeSqIegCZ2GsyaVKu6xEk9JegmxV01UWWrZJWVUTKy1kRRFiOnUDiLxqgUjwtI1aHGS(iRhf6DHz1kRoA28sMNSALvO(1UTKIWGnF0d(7JcPAXcdgKnskV(HGwSGLduyfSCGbriacdu52scwircdUzBqjmmbNHYGzU89FKWamHnxJUnOegGabwMvWFXnmX6(sSAUEz1(pNScowf)sfRid(ScdkKEz91HsSsf4J4LvhJY6cyf)peKWG56LU2fgC0S5LmpfwblhOLkeaHbQCBjblKiHb3SnOegM)d5myMj5ViHbycBUgDBqjmabcefwTPj4iwDwnxVSkUlyGywbhRDHByIvVyvumYgftcdMRx6AxyyeRKr2Oyk2v2lKznnLvYiBumfXaPF5UYbYAAkRKr2Oykk)LF5UYbY6ywTY6iwdMvdakvETXQr8U5PtSMMYk89B4ybYgymRPPSoIvhVNlZOaX0Xkez9bSaRwzDeRq9RDBjfnxVfy)OSMMYQJ3ZLzuGy6yfISgKeynnLvO(1UTKIno7aI1XSAL1rSc1V2TLu0akOGNugMWixgwTYAWSAaajmqCfnGck4jL3xkJr7RxC8JYAAkRbZku)A3wsrdOGcEszycJCzy1kRbZQbaKWaXv045UmXpkRJzDmRJz1kRJy1aasyG4kA8CxM4rHExywtI1GKaRPPScF)gowGSbgZAAkRoEpxMrbIPJ1Ky9bsGvRSAaajmqCfnEUlt8JYQvwhXQbaKWaXvKcrbIPlBdk44rHExywHiRUzBqfXRFZ(OijAY8xkVDiXAAkRbZQbaLkV24tKV2lwhZAAkRDT0HcK(sW5zJ4DZhf6DHzfISgycSoMvRSoIvyWgDyhDBOugl2VWmSh6iO4rHExywtIvlL10uwdMvdakvETXImhqcoywhlScwoqlieaHbQCBjblKiHb3SnOegOquGy6Y2GcwyaMWMRr3gucdIsikqmDSAdkywf)sfRG)IByIvVyvumYgftScowTisb5GUmS2ywDBWFzfSSAtS(XeCK1bhkX6eCSArKcYbDzegmxV01UWWiwjJSrXuu(l)Yfj6L10uwjJSrXuedK(Lls0lRPPSsgzJIPOxiNls0lRPPSA)NZOTl9YqzWm7szEF7cbox((pkEuO3fM1Ky1sJwG10uwT)Zz02LEzOmyMDPmVVDHaN9Z4ffpk07cZAsSAPrlWAAkRoEpxMrbIPJ1Ky9bsGvRSAaajmqCfnEUlt8ihgzwTYAWScF)gowGSbgZ6ywTY6iwnaGegiUIgp3LjEuO3fM1KynijWAAkRgaqcdexrJN7YepYHrM1XSMMYAxlDOaPVeCE2iE38rHExywHiRbMGWky5aHGcbqyGk3wsWcjsyWnBdkHbdjj82Um7Ygrfs1kmatyZ1OBdkHblIuqoOldRIFPIvFz9bs4rwDmkRI79f8xwLaCxiyD7qI1Uynrsaaw(XlRGJvia(4LvqXQbaKWaXfRIFPI1cSSk7QleS(rzvCVVSArqbf8KegmxV01UWqWScF)gowGSbgZQvwH6x72skAGZgqb3BdkwTY6iwhXQJ3ZLzuGy6ynjwFGey1kRJy1(pNXNDbFeCMcrbIPlKQntfDi6aMIFuwttznywnaOu51gFI81EX6ywttz1(pNrBjaal)4n(rz1kR2)5mAlbay5hVXJc9UWScrwHucS(iRJy1ak4FVr0JmnMYUSruHuTXTdPmux(jwhZ6ywttzTRLouG0xcopBeVB(OqVlmRqKviLaRpY6iwnGc(3Be9itJPSlBevivBC7qkd1LFI1XSMMYQbaLkV2y1iE380jwhZQvwhXAWSAaqPYRnwnI3npDI10uwD8EUmJcethRqKvlnbwTY6iwH6x72skAafuWtkdtyKldRPPSAaajmqCfnGck4jL3xkJr7RxC8ihgzwhZ6yHvWYbkQfcGWavUTKGfsKWG56LU2fgcMv473WXcKnWywTYku)A3wsrdC2ak4EBqXQvwhX6iwD8EUmJcethRjX6dKaRwzDeR2)5m(Sl4JGZuikqmDHuTzQOdrhWu8JYAAkRbZQbaLkV24tKV2lwhZAAkR2)5mAlbay5hVXpkRwz1(pNrBjaal)4nEuO3fMviYAqsG1hzDeRgqb)7nIEKPXu2LnIkKQnUDiLH6YpX6ywhZAAkRDT0HcK(sW5zJ4DZhf6DHzfISgKey9rwhXQbuW)EJOhzAmLDzJOcPAJBhszOU8tSoM10uwnaOu51gRgX7MNoX6ywTY6iwdMvdakvETXQr8U5PtSMMYQJ3ZLzuGy6yfISAPjWQvwhXku)A3wsrdOGcEszycJCzynnLvdaiHbIRObuqbpP8(szmAF9IJh5WiZ6ywhlm4MTbLWqxg)kFBqjScwoWaIqaegOYTLeSqIegaOcdyAfgCZ2GsyaQFTBljHbOU8tcdKr2Oyk2vw(l)yvuXAaHviZQB2gur863SpksIMm)LYBhsS(iRbZkzKnkMIDLL)YpwfvSoIviiRpY66sQ2ig8LzWmVVuEcocVrQCBjbZQOI1GW6ywHmRUzBqffF((gjrtM)s5TdjwFK1eIqIviZkgLKY8RJxsyaMWMRr3gucdIcE7qFjmRVaXSg(nVSIu4ehRid(S6hXkcVRUqWkkDSIjdOGfgG6xU8qsyWXOjo6giJWky5aFaHaimqLBljyHejm4MTbLWaE9d)peKWamHnxJUnOegs8)quwhw)W)dbHzv8lvSUVeRZgX7YAJz1Tb)L1fWkvWiH15rvaJmRnMv3g8xwxaRubJewrg8z1pIvFz9bs4rwDmkRDXQxSkkgzJIjKWQfrkih0LHvPJxmREb2x6ynG8iMmywbhRid(Skg8LWScGsNXrzneCeR7RxSYPbMaRifoXXQ4xQyfzWNvXGVeUq6L1H1p8)qqSwaXcdMRx6AxyyeRDT0HcK(sW5zJ4DZhf6DHzfISAPSMMY6iwT)Zz8COub(488OkGroEuO3fMviYkcdCm0fnRIkwnulzDeRoEpxMrbIPJviZAqsG1XSALv7)CgphkvGpoppQcyKJFuwhZ6ywttzDeRoEpxMrbIPJ1hzfQFTBlPOJrtC0nqgwfvSA)NZizKnkMYyG0V4rHExywFKvyWgN)d5myMj5VO42MN48rHExSkQyfsrlWAsSgyGjWAAkRoEpxMrbIPJ1hzfQFTBlPOJrtC0nqgwfvSA)NZizKnkMYYF5x8OqVlmRpYkmyJZ)HCgmZK8xuCBZtC(OqVlwfvScPOfynjwdmWeyDmRwzLmYgftXUYEHmRwzDeRbZQ9FoJgp3Lj(rznnL1GzDDjvBeV(jbhCKk3wsWSoMvRSoI1rSgmRgaqcdexrJN7Ye)OSMMYQbaLkV24tKV2lwTYAWSAaajmqCfPquGy6Y2Gco(rzDmRPPSAaqPYRnwnI3npDI1XSAL1rSgmRgauQ8AJqPAFr(ynnL1Gz1(pNrJN7Ye)OSMMYQJ3ZLzuGy6ynjwFGeyDmRPPSoI11LuTr86NeCWrQCBjbZQvwT)Zz045UmXpkRwzDeR2)5mIx)KGdoIx38KviYAqynnLvhVNlZOaX0XAsS(ajW6ywhZAAkR2)5mA8CxM4rHExywtI1acRwznywT)Zz8COub(488OkGro(rz1kRbZ66sQ2iE9tco4ivUTKGfwbldPeecGWavUTKGfsKWGB2gucdfjohcaLWamHnxJUnOegSemXkeqaOWS2fRj2V8JvrXiBumXQxWSIDOeRbv4Y5JqGFPKviGaqX6eCSArKcYbDzegmxV01UWWiwT)ZzKmYgftz5V8lEuO3fM1KyLenz(lL3oKynnL1rSAE9dbHzvewHeRwz9iZRFiO82HeRqKvlW6ywttz186hccZQiSgewhZQvwD0S5LmpfwbldPafcGWavUTKGfsKWG56LU2fggXQ9FoJKr2Oykl)LFXJc9UWSMeRKOjZFP82HeRwzDeRgaqcdexrJN7Yepk07cZAsSAHeynnLvdaiHbIRObuqbpP8(szmAF9IJhf6DHznjwTqcSoM10uwhXQ51peeMvryfsSAL1JmV(HGYBhsScrwTaRJznnLvZRFiimRIWAqyDmRwz1rZMxY8uyWnBdkHHxxoZHaqjScwgsqsiacdu52scwircdMRx6AxyyeR2)5msgzJIPS8x(fpk07cZAsSsIMm)LYBhsSAL1rSAaajmqCfnEUlt8OqVlmRjXQfsG10uwnaGegiUIgqbf8KY7lLXO91loEuO3fM1Ky1cjW6ywttzDeRMx)qqywfHviXQvwpY86hckVDiXkez1cSoM10uwnV(HGWSkcRbH1XSALvhnBEjZtHb3SnOegMFPmhcaLWkyzifeHaimqLBljyHejmatyZ1OBdkHbimGOWkOy1aZQ9Fzf9agmRIBPKvqjrMvBI1pMGzTlCdtSMy)YpwffJSrXKWGB2gucdI97AWLbZmj)fjScwgswQqaegOYTLeSqIegCZ2GsyaV(n7JegGjS5A0TbLWGLGjwhw)M9rSUawrpGH1bG0pwffJSrXeRGJvXVuXAxSMy)YpwffJSrXKWG56LU2fgiJSrXuSRS8x(XAAkRKr2OykIbs)Yfj6L10uwjJSrXu0lKZfj6L10uwT)ZzuSFxdUmyMj5VO4hLvRSA)NZizKnkMYYF5x8JYAAkRJy1(pNrJN7Yepk07cZkez1nBdQO4Z33ijAY8xkVDiXQvwT)Zz045UmXpkRJfwbldjlieaHb3SnOegeF((kmqLBljyHejScwgsqqHaimqLBljyHejm4MTbLWW9RSB2guzzJxHbzJ3C5HKWW0LY99(cRWkm4asiacwoqHaimqLBljyHejmaqfgW0km4MTbLWau)A3wscdqD5NeggXQ9FoJBhsIbxLHpYdT7cMU4rHExywHiRimWXqx0S(iRjedK10uwT)ZzC7qsm4Qm8rEODxW0fpk07cZkez1nBdQiE9B2hfjrtM)s5TdjwFK1eIbYQvwhXkzKnkMIDLL)YpwttzLmYgftrmq6xUirVSMMYkzKnkMIEHCUirVSoM1XSALv7)Cg3oKedUkdFKhA3fmDXpkRwz9(fnbhckUDijgCvg(ip0Uly6I0d(BuucwyaMWMRr3gucdw0LMV0xcZQ4xAFPJ19LynXFKhA818shR2)5KvXTuY60LswbZjRI79Tlw3xI1Ie9YQXXRWau)YLhscdWh5HzXTuMNUuMbZPWkyzijeaHbQCBjblKiHbaQWaMwHb3SnOegG6x72ssyaQl)KWqWSsgzJIPyxzmq6hRwzDeRyuskZRFiOfhXRFZ(iwtIvlWQvwxxs1gXGVmdM59LYtWr4nsLBljywttzfJsszE9dbT4iE9B2hXAsSkQzDSWamHnxJUnOegSOlnFPVeMvXV0(shRdRF4)HGyTXSkgC7lRghVDHGvau6yDy9B2hXAxSMy)YpwffJSrXKWau)YLhscdnIcCugV(H)hcsyfSCqecGWavUTKGfsKWGB2gucdgqbf8KY7lLXO91lwyaMWMRr3gucdwcMy1IGck4jXQ4xQy1xwLegZ6(6fRwibwD8EUKvuGy6y1lywLDrS(rzvCVVSArKcYbDzyvCVVG)YQeG7cbRoRFmjmyUEPRDHHrSc1V2TLu0akOGNugMWixgwTYAWSAaajmqCfnEUlt8ihgzwttz1(pNrJN7Ye)OSoMvRSoIvhVNlZOaX0Xkez1cjWAAkRq9RDBjfBef4OmE9d)peeRJz1kRJy1(pNrYiBumLL)YV4rHExywtIviiRPPSA)NZizKnkMYyG0V4rHExywtIviiRJz1kRJynywVFrtWHGI2U0ldLbZSlL59Tle4ivUTKGznnLv7)CgTDPxgkdMzxkZ7BxiW5Y3)rr86MNSMeRbH10uwT)Zz02LEzOmyMDPmVVDHaN9Z4ffXRBEYAsSgewhZAAkRZgX7Mpk07cZkeznWeewblBPcbqyGk3wsWcjsyWnBdkHb8VM9rcdgKnskV(HGwSGLduyWC9sx7cdJy9O5r4x3wsSMMYQ9FoJKr2OykJbs)Ihf6DHzfISgewTYkzKnkMIDLXaPFSAL1Jc9UWScrwd0sz1kRRlPAJyWxMbZ8(s5j4i8gPYTLemRJz1kRRFiOnUDiLxqgUjwtI1aTuwdOSIrjPmV(HGwmRpY6rHExywTY6iwjJSrXuSRSxiZAAkRhf6DHzfISIWahdDrZ6yHbycBUgDBqjmyjyIv8VM9rS2fROEbtHTHvXVuXQVSgOLIjdM1Jc9U6cbRGJvjHXSkU3xwdbhX66hcAXS6fmR9K1Ezvm4lHzD6sjRG5KvBAcoIvQw66cbR7lXArIEzvumYgftcRGLTGqaegOYTLeSqIegCZ2GsyaV(nDPuyaMWMRr3gucdbvsekRFuwhw)MUuYQVS6sjRBhsyw)LKWyw)4UqWAIHSXphZQxWS2lRnMv3g8xwxaROhWWk4yvslR7lXkgLmTlz1nBdkwLDrSAtsGywF9cwsSM4pYdT7cMowbfRqI11pe0IfgmxV01UWWiwT)ZzeV(nDPmE08i8RBljwTY6iwXOKuMx)qqloIx)MUuYkezniSMMYAWSE)IMGdbf3oKedUkdFKhA3fmDr6b)nkkbZ6ywttzDDjvBed(YmyM3xkpbhH3ivUTKGz1kR2)5msgzJIPmgi9lEuO3fMviYAqy1kRKr2Oyk2vgdK(XQvwT)ZzeV(nDPmEuO3fMviYQOMvRSIrjPmV(HGwCeV(nDPK1KeHvlL1XSAL1rSgmR3VOj4qqrjYg)CCEkjA7crgHSdrXuKEWFJIsWSMMY62HeRqiwTulWAsSA)NZiE9B6sz8OqVlmRpYkKyDmRwzD9dbTXTdP8cYWnXAsSAbHvWYqqHaimqLBljyHejm4MTbLWaE9B6sPWamHnxJUnOegGW69L1e)rEODxW0X6htSoS(nDPK1fW6tIqz9JY6(sSA)NtwTrMvxIbS(XDHG1H1VPlLSckwTaRyYakymRGJvjHXSEuO3vxiegmxV01UWW9lAcoeuC7qsm4Qm8rEODxW0fPh83OOemRwzfJsszE9dbT4iE9B6sjRjjcRbHvRSoI1Gz1(pNXTdjXGRYWh5H2Dbtx8JYQvwT)ZzeV(nDPmE08i8RBljwttzDeRq9RDBjfHpYdZIBPmpDPmdMtwTY6iwT)ZzeV(nDPmEuO3fMviYAqynnLvmkjL51pe0IJ41VPlLSMeRqIvRSUUKQnIxsk9ldF9CJu52scMvRSA)NZiE9B6sz8OqVlmRqKvlW6ywhZ6yHvWYIAHaimqLBljyHejmaqfgW0km4MTbLWau)A3wscdqD5NegC8EUmJcethRjXAajbwdOSoI1atGvrfR2)5mUDijgCvg(ip0Uly6I41npzDmRbuwhXQ9FoJ41VPlLXJc9UWSkQyniSczwXOKuMFD8sSoM1akRJyfgSX5)qodMzs(lkEuO3fMvrfRwG1XSALv7)CgXRFtxkJFuHbycBUgDBqjmyrxA(sFjmRIFP9LowDwhw)W)dbX6htSkULswn(htSoS(nDPK1fW60LswbZjsy1lyw)yI1H1p8)qqSUawFsekRj(J8q7UGPJv86MNS(rfgG6xU8qsyaV(nDPmlguBE6szgmNcRGLdicbqyGk3wsWcjsyWnBdkHb86h(FiiHbycBUgDBqjmyjyI1H1p8)qqSkU3xwt8h5H2DbthRlG1NeHY6hL19Ly1(pNSkU3xWFzvcWDHG1H1VPlLS(r3oKy1lyw)yI1H1p8)qqSckwT0hznraKkaSIx38eZ6V2wYQLY66hcAXcdMRx6AxyaQFTBlPi8rEywClL5PlLzWCYQvwH6x72skIx)MUuMfdQnpDPmdMtwTYAWSc1V2TLuSruGJY41p8)qqSMMY6iwT)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEYAsSgewttz1(pNrBx6LHYGz2LY8(2fcC2pJxueVU5jRjXAqyDmRwzfJsszE9dbT4iE9B6sjRqKvlvyfS8dieaHbQCBjblKiHb3SnOegCyhDBOugl2VqHbdYgjLx)qqlwWYbkmyUEPRDHHGzDBZZUqWQvwdMv3SnOIoSJUnukJf7xyg2dDeuSR8u2iExwttzfgSrh2r3gkLXI9lmd7HockIx38KviYAqy1kRWGn6Wo62qPmwSFHzyp0rqXJc9UWScrwdIWamHnxJUnOegSemXkwSFHSIbSUV(YkYGpRiOL1qx0S(r3oKy1gzw)4UqWAVS6ywL(sS6ywrbyCBljwbfRscJzDF9I1GWkEDZtmRGJvia(4LvXVuXAqEKv86MNywjrJ2hjScwoWeecGWavUTKGfsKWGB2gucdHaqn7JegmiBKuE9dbTyblhOWG56LU2fgoAEe(1TLeRwzD9dbTXTdP8cYWnXAsSoI1aTuwFK1rSIrjPmV(HGwCeV(n7JyvuXAGrlW6ywhZkKzfJsszE9dbTywFK1Jc9UWSAL1rSoIvdaiHbIROXZDzIh5WiZQvwdMv473WXcKnWywTY6iwH6x72skAafuWtkdtyKldRPPSAaajmqCfnGck4jL3xkJr7RxC8ihgzwttznywnaOu51gRgX7MNoX6ywttzfJsszE9dbT4iE9B2hXkezDeRwGvrfRJynqwFK11LuTXvCx5qaOWrQCBjbZ6ywhZAAkRJyLmYgftXUYyG0pwttzDeRKr2Oyk2v2gSVSMMYkzKnkMIDLL)YpwhZQvwdM11LuTrm4lZGzEFP8eCeEJu52scM10uwT)Zze96qWb3Um7NXR2Kr)sSFrOU8tSMKiScjlKaRJz1kRJyfJsszE9dbT4iE9B2hXkeznWeyvuX6iwdK1hzDDjvBCf3voeakCKk3wsWSoM1XSALvhVNlZOaX0XAsSAHeynGYQ9FoJ41VPlLXJc9UWSkQyfcY6ywTY6iwdMv7)CgF2f8rWzkefiMUqQ2mv0HOdyk(rznnLvYiBumf7kJbs)ynnL1Gz1aGsLxB8jYx7fRJz1kRoA28sMNSowyaMWMRr3gucdb108i8lRHaqn7JyTNSArKcYbDzyTXSEKdJmRGJ19LoIv)iwLegZ6(6fRwG11pe0IzTlwtSF5hRIIr2OyIvX9(YkgStwbhRscJzDF9I1atGvW(sN4gtS2fREHmRIIr2OykYAIhui9Y6rZJWVSc)VUqW6ZUGpcMvkefiMUqQww9cMvyqH0lRaO0zCuwDmQWky5aduiacdu52scwircdUzBqjmmbNHYGzU89FKWamHnxJUnOegSemX6euSckwnWSkU3xWFz14OODHqyWC9sx7cdoA28sMNcRGLdescbqyGk3wsWcjsyWnBdkHHZHsf4JZZJQagzHbycBUgDBqjmyjyI15rvaJmRGIvdmsyDFBmRIBPKv)VGqFBJlLiZQSlI1pkRI79LvJlmyUEPRDHb7)CgnEUlt8JkScwoWGieaHbQCBjblKiHb3SnOegmKKWB7YSlBevivRWamHnxJUnOegSemXQfrkih0LHvqXQbM1FjjmMvKbFwnEXQSlI1Ez9JYQ4EFz1IGck4jXQ4EFb)Lvja3fcwDwnoEfgmxV01UWqWScF)gowGSbgZQvwH6x72skAGZgqb3BdkwTY6iwT)ZzeV(nDPm(rznnLvhVNlZOaX0XAsSAHeyDmRwznywT)ZzedK4Tnu8JYQvwdMv7)CgnEUlt8JYQvwhXAWSAaqPYRnwnI3npDI10uwH6x72skAafuWtkdtyKldRPPSAaajmqCfnGck4jL3xkJr7RxC8JYAAkRDT0HcK(sW5zJ4DZhf6DHzfIScPey9rwhXQbuW)EJOhzAmLDzJOcPAJBhszOU8tSoM1XcRGLd0sfcGWavUTKGfsKWG56LU2fgcMv473WXcKnWywTYku)A3wsrdC2ak4EBqXQvwhXQ9FoJ41VPlLXpkRPPS649CzgfiMowtIvlKaRJz1kRbZQ9FoJyGeVTHIFuwTYAWSA)NZOXZDzIFuwTY6iwdMvdakvETXQr8U5PtSMMYku)A3wsrdOGcEszycJCzynnLvdaiHbIRObuqbpP8(szmAF9IJFuwttzTRLouG0xcopBeVB(OqVlmRqKvdaiHbIRObuqbpP8(szmAF9IJhf6DHz9rwHGSMMYAxlDOaPVeCE2iE38rHExywHqSgyajbwHiRbjbwFK1rSAaf8V3i6rMgtzx2iQqQ242HugQl)eRJzDSWGB2gucdDz8R8TbLWky5aTGqaegOYTLeSqIegCZ2GsyGcrbIPlBdkyHbycBUgDBqjmyjyIvqXQbMvX9(Y6W630Lsw)OS6fmRyhkX6eCSM4(sSFcdMRx6AxyORLouG0xcopBeVB(OqVlmRqK1aTaRPPSoIv7)CgrVoeCWTlZ(z8Qnz0Ve7xeQl)eRqKvizHeynnLv7)CgrVoeCWTlZ(z8Qnz0Ve7xeQl)eRjjcRqYcjW6ywTYQ9FoJ41VPlLXpkRwzDeRgaqcdexrJN7Yepk07cZAsSAHeynnLv473WXcKnWywhlScwoqiOqaegOYTLeSqIegCZ2GsyaVKu6xEk9JegmiBKuE9dbTyblhOWG56LU2fgoAEe(1TLeRwzD7qkVGmCtSMeRbAbwTYkgLKY86hcAXr863SpIviYQLYQvwD0S5Lmpz1kRJy1(pNrJN7Yepk07cZAsSgycSMMYAWSA)NZOXZDzIFuwhlmatyZ1OBdkHHGAAEe(L1P0pIvqX6hL1fWAqyD9dbTywf37l4VS2LbYgNvBQleS62G)Y6cyLenAFeREbZAbwwbqPZ4OODHqyfSCGIAHaimqLBljyHejm4MTbLWW8FiNbZmj)fjmatyZ1OBdkHblbtywHabIcR9K1UWnmXQxSkkgzJIjw9cMvzxeR9Y6hLvX9(YQZAI7lX(Xk6bmS6fmRifSJUnuI1bX(fkmyUEPRDHbYiBumf7k7fYSALvhnBEjZtwTYQ9FoJOxhco42Lz)mE1Mm6xI9lc1LFIviYkKSqcSAL1rScd2Od7OBdLYyX(fMH9qhbf328SleSMMYAWSAaqPYRnwK5asWbZAAkRyuskZRFiOfZAsScjwhlScwoWaIqaegOYTLeSqIegCZ2GsyaV(nDPuyaMWMRr3gucdwcMy1lwbfTVSIEadR)ssymRdRFtxkzTXS6YJCyKz9JYk4yfzWNv)iwDBWFzDbScGsNXrz1XOcdMRx6AxyW(pNrqr7loJsNHq3guXpkRwzDeR2)5mIx)MUugpAEe(1TLeRPPS649CzgfiMowtI1hibwhlScwoWhqiacdu52scwircdUzBqjmGx)MUukmatyZ1OBdkHHe)peLvhJYQnnbhXQfbfuWtIvX9(Y6W630Lsw9cM19Lkwhw)W)dbjmyUEPRDHbdakvETXQr8U5PtSAL1rSc1V2TLu0akOGNugMWixgwttz1aasyG4kA8CxM4hL10uwT)Zz045UmXpkRJz1kRgaqcdexrdOGcEs59LYy0(6fhpk07cZkezfHbog6IMvrfRgQLSoIvhVNlZOaX0XkKz1cjW6ywTYQ9FoJ41VPlLXJc9UWScrwTuwTYAWScF)gowGSbglScwgsjieaHbQCBjblKiHbZ1lDTlmyaqPYRnwnI3npDIvRSoIvO(1UTKIgqbf8KYWeg5YWAAkRgaqcdexrJN7Ye)OSMMYQ9FoJgp3Lj(rzDmRwz1aasyG4kAafuWtkVVugJ2xV44rHExywHiRqqwTYQ9FoJ41VPlLXpkRwzLmYgftXUYEHmRwznywH6x72sk2ikWrz86h(FiiwTYAWScF)gowGSbglm4MTbLWaE9d)peKWkyzifOqaegOYTLeSqIegCZ2GsyaV(H)hcsyaMWMRr3gucdwcMyDy9d)peeRI79LvVyfu0(Yk6bmScowrg8rAywbqPZ4OS6yuwf37lRid(hRfj6LvJJ3iRiLedyf(hIIz1XOS6lR7lXkvWScMSUVeRqPAFr(y1(pNS2twhw)MUuYQyWxcxlRtxkzfmNSckwTuwbhRscJzD9dbTyHbZ1lDTlmy)NZiOO9fNnsYVm0g3Gk(rznnL1rSgmR41VzFu0rZMxY8KvRSgmRq9RDBjfBef4OmE9d)peeRPPSoIv7)CgnEUlt8OqVlmRqKvlWQvwT)Zz045UmXpkRPPSoIv7)CgphkvGpoppQcyKJhf6DHzfISIWahdDrZQOIvd1swhXQJ3ZLzuGy6yfYSgKeyDmRwz1(pNXZHsf4JZZJQag54hL1XSoMvRSc1V2TLueV(nDPmlguBE6szgmNSALvmkjL51pe0IJ41VPlLScrwdcRJz1kRJynywVFrtWHGIBhsIbxLHpYdT7cMUi9G)gfLGznnLvmkjL51pe0IJ41VPlLScrwdcRJfwbldjijeaHbQCBjblKiHb3SnOegksCoeakHbycBUgDBqjmyjyIviGaqHzTlwhas)yvumYgftS6fmRyhkXke4xkzfciauSobhRwePGCqxgHbZ1lDTlmmIv7)CgjJSrXugdK(fpk07cZAsSsIMm)LYBhsSMMY6iwnV(HGWSkcRqIvRSEK51peuE7qIviYQfyDmRPPSAE9dbHzvewdcRJz1kRoA28sMNcRGLHuqecGWavUTKGfsKWG56LU2fggXQ9FoJKr2OykJbs)Ihf6DHznjwjrtM)s5TdjwttzDeRMx)qqywfHviXQvwpY86hckVDiXkez1cSoM10uwnV(HGWSkcRbH1XSALvhnBEjZtHb3SnOegED5mhcaLWkyzizPcbqyGk3wsWcjsyWC9sx7cdJy1(pNrYiBumLXaPFXJc9UWSMeRKOjZFP82HeRwzDeRgaqcdexrJN7Yepk07cZAsSAHeynnLvdaiHbIRObuqbpP8(szmAF9IJhf6DHznjwTqcSoM10uwhXQ51peeMvryfsSAL1JmV(HGYBhsScrwTaRJznnLvZRFiimRIWAqyDmRwz1rZMxY8uyWnBdkHH5xkZHaqjScwgswqiacdu52scwircdWe2Cn62GsyWsWeRqyarHv4)1fcwtSF5hRIIr2OysyWnBdkHbX(Dn4YGzMK)IewbldjiOqaegOYTLeSqIegaOcdyAfgCZ2GsyaQFTBljHbOU8tcdyuskZRFiOfhXRFZ(iwtIvlL1hzDkbGJ1rSg64LoKZqD5NyvuXAGjKaRqMviLaRJz9rwNsa4yDeR2)5mIx)W)dbLPquGy6cPAZyG0ViEDZtwHmRwkRJfgG6xU8qsyaV(n7JYDLXaPFcRGLHKOwiacdu52scwircdUzBqjmi(89vyaMWMRr3gucdwcMyfc789L1UyDai9JvrXiBumXk4yDFjwLoEzDy9B2hXQyqTSo7L1UwaRoRwePGCqxgwT)ZzuyWC9sx7cdKr2Oykk)LF5Ie9YAAkRKr2Oyk6fY5Ie9YQvwH6x72sk24SrsouI10uwT)ZzKmYgftzmq6x8OqVlmRqKv3SnOI41VzFuKenz(lL3oKy1kR2)5msgzJIPmgi9l(rznnLvYiBumf7kJbs)y1kRbZku)A3wsr863Spk3vgdK(XAAkR2)5mA8CxM4rHExywHiRUzBqfXRFZ(OijAY8xkVDiXQvwdMvO(1UTKInoBKKdLy1kR2)5mA8CxM4rHExywHiRKOjZFP82HeRwz1(pNrJN7Ye)OSMMYQ9FoJNdLkWhNNhvbmYXpkRwzfJssz(1XlXAsSMqecYQvwhXkgLKY86hcAXScrryniSMMYAWSUUKQnIbFzgmZ7lLNGJWBKk3wsWSoM10uwdMvO(1UTKInoBKKdLy1kR2)5mA8CxM4rHExywtIvs0K5VuE7qsyfSmKcicbqyGk3wsWcjsyaMWMRr3gucdwcMyDy9B2hXApzTlwtSF5hRIIr2OycjS2fRdaPFSkkgzJIjwbfRw6JSU(HGwmRGJ1fWk6bmSoaK(XQOyKnkMegCZ2GsyaV(n7JewbldPhqiacdu52scwircdWe2Cn62Gsyac0LY99(cdUzBqjmC)k7MTbvw24vyq24nxEijmmDPCFVVWkScdtxk337leablhOqaegOYTLeSqIegCZ2GsyaV(H)hcsyaMWMRr3gucddRF4)HGyDcowdbqPqQww)LKWyw)4UqWAIaivaegmxV01UWqWSE)IMGdbfTDPxgkdMzxkZ7BxiWr6b)nkkblScwgscbqyGk3wsWcjsyWnBdkHb8VM9rcdgKnskV(HGwSGLduyWC9sx7cdWGngca1SpkEuO3fM1Ky9OqVlmRIkwHeKyfYSgyaryaMWMRr3gucdw0XlR7lXkmyzvCVVSUVeRHa8Y62HeRlGvhgM1FTTK19Lyn0fnRW)Z3guS2ywF7nY6WVM9rSEuO3fM1WVCBuztWSUawd918YAiauZ(iwH)NVnOewblheHaim4MTbLWqiauZ(iHbQCBjblKiHvyfgWRqaeSCGcbqyGk3wsWcjsyWnBdkHb86h(FiiHbycBUgDBqjmyrxA(sFjmRIFP9Lowhw)W)dbXAremM1fWQnX6htWSUawFsekRFuw3xI1e)rEODxW0XQ9FozfCSUawH)HOSAttWrSAafuWtsyWC9sx7cd3VOj4qqXTdjXGRYWh5H2DbtxKEWFJIsWSAL1rSsgzJIPyxzVqMvRSgmRJyDeR2)5mUDijgCvg(ip0Uly6Ihf6DHznjwryGJHUOz9rwtigiRwzDeRKr2Oyk2v2gSVSMMYkzKnkMIDLXaPFSMMYkzKnkMIYF5xUirVSoM10uwT)ZzC7qsm4Qm8rEODxW0fpk07cZAsS6MTbveV(n7JIKOjZFP82HeRpYAcXaz1kRJyLmYgftXUYYF5hRPPSsgzJIPigi9lxKOxwttzLmYgftrVqoxKOxwhZ6ywttznywT)ZzC7qsm4Qm8rEODxW0f)OSoM10uwhXQ9FoJgp3Lj(rznnLvO(1UTKIgqbf8KYWeg5YW6ywTYQbaKWaXv0akOGNuEFPmgTVEXXJCyKzDSWkyzijeaHbQCBjblKiHb3SnOegCyhDBOugl2VqHbdYgjLx)qqlwWYbkmyUEPRDHHGzfgSrh2r3gkLXI9lmd7HockUT5zxiy1kRbZQB2gurh2r3gkLXI9lmd7Hock2vEkBeVlRwzDeRbZkmyJoSJUnukJf7xy(LCzCBZZUqWAAkRWGn6Wo62qPmwSFH5xYLXJc9UWSMeRwG1XSMMYkmyJoSJUnukJf7xyg2dDeueVU5jRqK1GWQvwHbB0HD0THszSy)cZWEOJGIhf6DHzfISgewTYkmyJoSJUnukJf7xyg2dDeuCBZZUqimatyZ1OBdkHblbtSIuWo62qjwhe7xiRIFPI19LoI1gZAby1nBdLyfl2VqKWQJzv6lXQJzffGXTTKyfuSIf7xiRI79LviXk4yDsIPJv86MNywbhRGIvN1G8iRyX(fYkgW6(6lR7lXArIzfl2Vqw97AOeMvia(4LvFU0X6(6lRyX(fYkjA0(iSWky5GieaHbQCBjblKiHb3SnOegmGck4jL3xkJr7RxSWamHnxJUnOegSemHz1IGck4jXApz14S2yw)OScowrg8z1pIvycJCz6cbRwePGCqxgwf37lRweuqbpjw9cMvKbFw9Jy1MKaXSAPjWQJrfgmxV01UWWiwH6x72skAafuWtkdtyKldRwznywnaGegiUIgp3LjEKdJmRPPSA)NZOXZDzIFuwhZQvwD8EUmJcethRqKvlnbwTY6iwT)ZzKmYgftz5V8lEuO3fM1KynWeynnLv7)CgjJSrXugdK(fpk07cZAsSgycSoM10uwNnI3nFuO3fMviYAGjiScw2sfcGWavUTKGfsKWaavyatRWGB2gucdq9RDBjjma1LFsyyeR2)5mA8CxM4rHExywtIvlWQvwhXQ9FoJNdLkWhNNhvbmYXJc9UWSMeRwG10uwdMv7)CgphkvGpoppQcyKJFuwhZAAkRbZQ9FoJgp3Lj(rznnLvhVNlZOaX0XkeznijW6ywTY6iwdMv7)CgF2f8rWzkefiMUqQ2mv0HOdyk(rznnLvhVNlZOaX0XkeznijW6ywTY6iwT)ZzKmYgftzmq6x8OqVlmRjXkcdCm0fnRPPSA)NZizKnkMYYF5x8OqVlmRjXkcdCm0fnRJfgGjS5A0TbLWqqnnpc)YkmyXS(ljHXSArKcYbDzy91XSkjmM191lwTaRyYGz9OqVRUqGew3xIvOuTViFSA)NtwbhR7lX6tKV2lwT)ZjRnMv3g8xwxaRtxkzfmNS6fmREHmRIIr2OyI1gZQBd(lRlGvs0O9rcdq9lxEijmad28rp4VpkKQflScw2ccbqyGk3wsWcjsyWnBdkHHqaOM9rcdMRx6Axy4O5r4x3wsSAL11pe0g3oKYlid3eRjXAGqIvRSoIvhnBEjZtwTYku)A3wsryWMp6b)9rHuTywhlmyq2iP86hcAXcwoqHvWYqqHaimqLBljyHejm4MTbLWa(xZ(iHbZ1lDTlmC08i8RBljwTY66hcAJBhs5fKHBI1KynqiXQvwhXQJMnVK5jRwzfQFTBlPimyZh9G)(OqQwmRJfgmiBKuE9dbTyblhOWkyzrTqaegOYTLeSqIegCZ2GsyaVKu6xEk9JegmxV01UWWrZJWVUTKy1kRRFiOnUDiLxqgUjwtI1aHGSAL1rS6OzZlzEYQvwH6x72skcd28rp4VpkKQfZ6yHbdYgjLx)qqlwWYbkScwoGieaHbQCBjblKiHb3SnOegMGZqzWmx((psyaMWMRr3gucdwcMyfceyzwbfRgywf37l4VSACu0UqimyUEPRDHbhnBEjZtHvWYpGqaegOYTLeSqIegCZ2Gsy4COub(488OkGrwyaMWMRr3gucdwcMyDFjwdQIQ9f5Jv3UL9ImRGIvdmRIFBZlRnMvBAcoIvlIuqoOlJWG56LU2fgS)Zz045UmXpQWky5atqiacdu52scwircdUzBqjmqHOaX0LTbfSWamHnxJUnOegSemXAqLDbFemRdO91lMvX9(Y6aq6hRIIr2OyIvVGznX9Ly)y9xscJzvcWDHGvN1pMegmxV01UWWiwhXQ9FoJKr2OykJbs)Ihf6DHznjwdmbwttz1(pNrYiBumLL)YV4rHExywtI1atG1XSALvdaiHbIROXZDzIhf6DHznjwdscSAL1rSA)NZi61HGdUDz2pJxTjJ(Ly)IqD5NyfIScjlnbwttznywVFrtWHGIOxhco42Lz)mE1Mm6xI9lsp4VrrjywhZ6ywttz1(pNr0RdbhC7YSFgVAtg9lX(fH6YpXAsIWkKe1jWAAkRgaqcdexrJN7YepYHrMvRSoIvhVNlZOaX0XAsS(ajWAAkRq9RDBjfBC2beRJfwblhyGcbqyGk3wsWcjsyWnBdkHbdjj82Um7Ygrfs1kmatyZ1OBdkHblbtSArKcYbDzyvCVVSArqbf8Ky1lywHbfsVScGsN4RxI1e3xI9tyWC9sx7cdbZk89B4ybYgymRwzfQFTBlPOboBafCVnOy1kRJy1X75YmkqmDSMeRpqcSAL1rSA)NZ4ZUGpcotHOaX0fs1MPIoeDatXpkRPPSgmRgauQ8AJpr(AVyDmRPPSAaqPYRnwnI3npDI10uwH6x72sk24Sdiwttz1(pNrBjaal)4n(rz1kR2)5mAlbay5hVXJc9UWScrwHucS(iRJyDeRpaRIkwVFrtWHGIOxhco42Lz)mE1Mm6xI9lsp4VrrjywhZ6JSoIvdOG)9grpY0yk7Ygrfs1g3oKYqD5NyDmRJzDmRwznywT)Zz045UmXpkRwzDeRbZQbaLkV2y1iE380jwttz1aasyG4kAafuWtkVVugJ2xV44hL10uw7APdfi9LGZZgX7Mpk07cZkez1aasyG4kAafuWtkVVugJ2xV44rHExywFKviiRPPS21shkq6lbNNnI3nFuO3fMvieRbgqsGviYkKsG1hzDeRgqb)7nIEKPXu2LnIkKQnUDiLH6YpX6ywhlScwoqijeaHbQCBjblKiHbZ1lDTlmemRW3VHJfiBGXSALvO(1UTKIg4SbuW92GIvRSoIvhVNlZOaX0XAsS(ajWQvwhXQ9FoJp7c(i4mfIcetxivBMk6q0bmf)OSMMYAWSAaqPYRn(e5R9I1XSMMYQbaLkV2y1iE380jwttzfQFTBlPyJZoGynnLv7)CgTLaaS8J34hLvRSA)NZOTeaGLF8gpk07cZkeznijW6JSoI1rS(aSkQy9(fnbhckIEDi4GBxM9Z4vBYOFj2Vi9G)gfLGzDmRpY6iwnGc(3Be9itJPSlBevivBC7qkd1LFI1XSoM1XSAL1Gz1(pNrJN7Ye)OSAL1rSgmRgauQ8AJvJ4DZtNynnLvdaiHbIRObuqbpP8(szmAF9IJFuwttzTRLouG0xcopBeVB(OqVlmRqKvdaiHbIRObuqbpP8(szmAF9IJhf6DHz9rwHGSMMYAxlDOaPVeCE2iE38rHExywHqSgyajbwHiRbjbwFK1rSAaf8V3i6rMgtzx2iQqQ242HugQl)eRJzDSWGB2gucdDz8R8TbLWky5adIqaegOYTLeSqIegaOcdyAfgCZ2GsyaQFTBljHbOU8tcdbZQbaKWaXv045UmXJCyKznnL1GzfQFTBlPObuqbpPmmHrUmSALvdakvETXQr8U5PtSMMYk89B4ybYgySWamHnxJUnOegcQYV2TLeRFmbZkOy1TBzVnHzDF9LvXETSUawTjwXoucM1j4y1IifKd6YWkgW6(6lR7lHmR(r1YQyhVemRqa8XlR20eCeR7lfkma1VC5HKWa2Hs5j4Ygp3LryfSCGwQqaegOYTLeSqIegCZ2Gsyy(pKZGzMK)IegGjS5A0TbLWGLGjmRqGarH1EYAxS6fRIIr2OyIvVGzDVMWSUawLDrS2lRFuwf37lRjUVe7hsy1IifKd6YWQxWSIuWo62qjwhe7xOWG56LU2fgiJSrXuSRSxiZQvwD0S5Lmpz1kR2)5mIEDi4GBxM9Z4vBYOFj2Viux(jwHiRqYstGvRSoIvyWgDyhDBOugl2VWmSh6iO42MNDHG10uwdMvdakvETXImhqcoywhZQvwH6x72skIDOuEcUSXZDzewblhOfecGWavUTKGfsKWGB2gucd41VPlLcdWe2Cn62GsyWsWeRGI2xwhw)MUuYk6bmyw7jRdRFtxkzTXfsVS(rfgmxV01UWG9FoJGI2xCgLodHUnOIFuwTYQ9FoJ41VPlLXJMhHFDBjjScwoqiOqaegOYTLeSqIegmxV01UWG9FoJ41pj4GJhf6DHzfISAbwTY6iwT)ZzKmYgftzmq6x8OqVlmRjXQfynnLv7)CgjJSrXuw(l)Ihf6DHznjwTaRJz1kRoEpxMrbIPJ1Ky9bsqyWnBdkHbJxgsMT)ZPWG9FoZLhscd41pj4GfwblhOOwiacdu52scwircdMRx6AxyyDjvBeVKu6xg(65gPYTLemRwzft72fcCedKGm81ZLvRSA)NZiE9B6szegiUegCZ2GsyaV(nDPuyfSCGbeHaimqLBljyHejm4MTbLWaE9d)peKWamHnxJUnOegs8)qumRogLvBAcoIvlckOGNeRFCxiyDFjwTiOGcEsSAafCVnOyDbSAEjZtw7jRweuqbpjwBmRUz)UuImRUn4VSUawTjwnoEfgmxV01UWGbaLkV2y1iE380jwTYku)A3wsrdOGcEszycJCzy1kRgaqcdexrdOGcEs59LYy0(6fhpk07cZkez1cSAL1Gzf((nCSazdmwyfSCGpGqaegOYTLeSqIegCZ2GsyaV(nDPuyaMWMRr3gucdwcMyDy9B6sjRI79Lv8ssPFScF9Cz1lywlaRdRFsWbJewf)sfRfG1H1VPlLS2yw)OiHvKbFw9JyTlwtSF5hRIIr2OycjSIEadRjUVe7hRIFPIv3gaLy9bsGvhJYk4y1Hr9THsSIf7xiRVoM1aYJyYGz9OqVRUqWk4yTXS2fRtzJ4DfgmxV01UWW6sQ2iEjP0Vm81ZnsLBljywTYAWSUUKQnIx)KGdosLBljywTYQ9FoJ41VPlLXJMhHFDBjXQvwhXQ9FoJKr2Oykl)LFXJc9UWSMeRqqwTYkzKnkMIDLL)YpwTYQ9FoJOxhco42Lz)mE1Mm6xI9lc1LFIviYkKSqcSMMYQ9FoJOxhco42Lz)mE1Mm6xI9lc1LFI1KeHvizHey1kRoEpxMrbIPJ1Ky9bsG10uwHbB0HD0THszSy)cZWEOJGIhf6DHznjwdiSMMYQB2gurh2r3gkLXI9lmd7Hock2vEkBeVlRJz1kRbZQbaKWaXv045UmXJCyKfwbldPeecGWavUTKGfsKWGB2gucd41p8)qqcdWe2Cn62GsyWsWeRymRGI2xwrpGbZQxWSc)drz1XOSk(LkwTisb5GUmScow3xIvOuTViFSA)NtwBmRUn4VSUawNUuYkyozfCSIm4J0WSACuwDmQWG56LU2fgS)Zzeu0(IZgj5xgAJBqf)OSMMYQ9FoJp7c(i4mfIcetxivBMk6q0bmf)OSMMYQ9FoJgp3Lj(rz1kRJy1(pNXZHsf4JZZJQag54rHExywHiRimWXqx0SkQy1qTK1rS649CzgfiMowHmRbjbwhZQvwT)Zz8COub(488OkGro(rznnL1Gz1(pNXZHsf4JZZJQag54hLvRSgmRgaqcdexXZHsf4JZZJQag54romYSMMYAWSAaqPYRncLQ9f5J1XSMMYQJ3ZLzuGy6ynjwFGey1kRKr2Oyk2v2lKfwbldPafcGWavUTKGfsKWGB2gucd41p8)qqcdWe2Cn62GsyiahYSUawd9NeR7lXQnHxwbtwhw)KGdMvBKzfVU5zxiyTxw)OS(G)28uImRDX6aq6hRIIr2OyIv7)YAI7lX(XAJRLv3g8xwxaR2eROhWyiyHbZ1lDTlmSUKQnIx)KGdosLBljywTYAWSE)IMGdbf3oKedUkdFKhA3fmDr6b)nkkbZQvwhXQ9FoJ41pj4GJFuwttz1X75YmkqmDSMeRpqcSoMvRSA)NZiE9tco4iEDZtwHiRbHvRSoIv7)CgjJSrXugdK(f)OSMMYQ9FoJKr2Oykl)LFXpkRJz1kR2)5mIEDi4GBxM9Z4vBYOFj2Viux(jwHiRqsuNaRwzDeRgaqcdexrJN7Yepk07cZAsSgycSMMYAWSc1V2TLu0akOGNugMWixgwTYQbaLkV2y1iE380jwhlScwgsqsiacdu52scwircdUzBqjmGx)W)dbjmatyZ1OBdkHblbtSoS(H)hcI1UyDai9JvrXiBumHewHbfsVSkPL1Ezf9agwtCFj2pwhTV(YAJz91lyjbZQnYSs9(shR7lX6W630LswLDrScow3xIvhJM0dKaRYUiwNGJ1H1p8)qqJrcRWGcPxwbqPt81lXQxSckAFzf9agw9cMvjTSUVeRUnakXQSlI1xVGLeRdRFsWblmyUEPRDHHGz9(fnbhckUDijgCvg(ip0Uly6I0d(BuucMvRSoIv7)CgrVoeCWTlZ(z8Qnz0Ve7xeQl)eRqKvijQtG10uwT)Zze96qWb3Um7NXR2Kr)sSFrOU8tScrwHKfsGvRSUUKQnIxsk9ldF9CJu52scM1XSALv7)CgjJSrXugdK(fpk07cZAsSkQz1kRKr2Oyk2vgdK(XQvwdMv7)CgbfTV4mkDgcDBqf)OSAL1GzDDjvBeV(jbhCKk3wsWSALvdaiHbIROXZDzIhf6DHznjwf1SAL1rSAaajmqCfF2f8rWzmAF9IJhf6DHznjwf1SMMYAWSAaqPYRn(e5R9I1XcRGLHuqecGWavUTKGfsKWGB2gucdfjohcaLWamHnxJUnOegSemXkeqaOWS2fRj2V8JvrXiBumXQxWSIDOeRbv4Y5JqGFPKviGaqX6eCSArKcYbDzegmxV01UWWiwT)ZzKmYgftz5V8lEuO3fM1KyLenz(lL3oKynnL1rSAE9dbHzvewHeRwz9iZRFiO82HeRqKvlW6ywttz186hccZQiSgewhZQvwD0S5Lmpz1kRq9RDBjfXoukpbx245UmcRGLHKLkeaHbQCBjblKiHbZ1lDTlmmIv7)CgjJSrXuw(l)Ihf6DHznjwjrtM)s5TdjwTYAWSAaqPYRn(e5R9I10uwhXQ9FoJp7c(i4mfIcetxivBMk6q0bmf)OSALvdakvETXNiFTxSoM10uwhXQ51peeMvryfsSAL1JmV(HGYBhsScrwTaRJznnLvZRFiimRIWAqynnLv7)CgnEUlt8JY6ywTYQJMnVK5jRwzfQFTBlPi2Hs5j4Ygp3LryWnBdkHHxxoZHaqjScwgswqiacdu52scwircdMRx6AxyyeR2)5msgzJIPS8x(fpk07cZAsSsIMm)LYBhsSAL1Gz1aGsLxB8jYx7fRPPSoIv7)CgF2f8rWzkefiMUqQ2mv0HOdyk(rz1kRgauQ8AJpr(AVyDmRPPSoIvZRFiimRIWkKy1kRhzE9dbL3oKyfISAbwhZAAkRMx)qqywfH1GWAAkR2)5mA8CxM4hL1XSALvhnBEjZtwTYku)A3wsrSdLYtWLnEUlJWGB2gucdZVuMdbGsyfSmKGGcbqyGk3wsWcjsyaMWMRr3gucdwcMyfcdikSckwnWcdUzBqjmi2VRbxgmZK8xKWkyzijQfcGWavUTKGfsKWGB2gucd41VzFKWamHnxJUnOegSemX6W63SpI1fWk6bmSoaK(XQOyKnkMqcRwePGCqxgwFDmRscJzD7qI191lwDwHWoFFzLenz(lXQKMlRGJvqjrM1e7x(XQOyKnkMyTXS(rfgmxV01UWazKnkMIDLL)YpwttzLmYgftrmq6xUirVSMMYkzKnkMIEHCUirVSMMYQ9FoJI97AWLbZmj)ff)OSALv7)CgjJSrXuw(l)IFuwttzDeR2)5mA8CxM4rHExywHiRUzBqffF((gjrtM)s5TdjwTYQ9FoJgp3Lj(rzDSWkyzifqecGWavUTKGfsKWamHnxJUnOegSemXke257lRG9LoXnMyv8BBEzTXS2fRdaPFSkkgzJIjKWQfrkih0LHvWX6cyf9agwtSF5hRIIr2OysyWnBdkHbXNVVcRGLH0dieaHbQCBjblKiHbycBUgDBqjmab6s5(EFHb3SnOegUFLDZ2GklB8kmiB8MlpKegMUuUV3xyfwHb0JmGqBFfcGGLduiacdUzBqjm8Sl4JGZy0(6flmqLBljyHejScwgscbqyGk3wsWcjsyaGkmGPvyWnBdkHbO(1UTKegG6YpjmKGWamHnxJUnOegcWlXku)A3wsS2ywX0Y6cynbwf37lRfGv86lRGI1pMyDVUEslgjSgiRIFPI19LyD2hEzfueRnMvqX6htiHviXApzDFjwXKbuWS2yw9cM1GWApz1gSVS6hjma1VC5HKWaOYFmL3RRN0kScwoicbqyGk3wsWcjsyaGkm4WWcdUzBqjma1V2TLKWaux(jHHafgmxV01UWWED9K24gy8JDBjXQvw3RRN0g3aJgaqcdexr4)5BdkHbO(LlpKegav(JP8ED9KwHvWYwQqaegOYTLeSqIegaOcdomSWGB2gucdq9RDBjjma1LFsyascdMRx6AxyyVUEsBCHu8JDBjXQvw3RRN0gxifnaGegiUIW)Z3gucdq9lxEijmaQ8ht5966jTcRGLTGqaegCZ2GsyieaQNDLNGluyGk3wsWcjsyfSmeuiacdu52scwircdUzBqjmi(89vyq2fLnWcdbMGWG56LU2fggXkzKnkMIYF5xUirVSMMYkzKnkMIDLL)YpwttzLmYgftXUY2G9L10uwjJSrXu0lKZfj6L1XcdWe2Cn62GsyiXDKXXlRqIviSZ3xw9cMvN1H1p8)qqSckwhcaRI79Lvl3iExwHaDIvVGznraKkaScowhw)M9rSc2x6e3ysyfSSOwiacdu52scwircdMRx6AxyyeRKr2Oykk)LF5Ie9YAAkRKr2Oyk2vw(l)ynnLvYiBumf7kBd2xwttzLmYgftrVqoxKOxwhZQvwrpcAmWO4Z3xwTYAWSIEe0iKIIpFFfgCZ2Gsyq857RWky5aIqaegOYTLeSqIegmxV01UWqWSE)IMGdbfTDPxgkdMzxkZ7BxiWrQCBjbZAAkRbZQbaLkV2y1iE380jwttznywXOKuMx)qqloIx)MUuYQiSgiRPPSgmRRlPAJLV)JWzBx6LHIu52scwyWnBdkHb863SpsyfS8dieaHbQCBjblKiHbZ1lDTlmC)IMGdbfTDPxgkdMzxkZ7BxiWrQCBjbZQvwnaOu51gRgX7MNoXQvwXOKuMx)qqloIx)MUuYQiSgOWGB2gucd41p8)qqcRWkScdqPd3GsWYqkbifycqkHaIWGy)QUqGfgGWqQGAlh0wgcWGcRSgGxI1oefClRtWXksdtt)lxKM1JEWFFemRyqiXQ)xqOVemRMxVqq4iNCI1fXkemOWQfbfu6wcM1Ho0ISIrUwx0ScHyDbSMyFNv4gAJBqXkaLoFbhRJG8ywhbjrpoYjNyDrSgyGbfwTiOGs3sWSI03VOj4qqriCKM1fWksF)IMGdbfHWJu52scgPzDuGIECKtoX6IynWadkSArqbLULGzfP3RRN0gdmcHJ0SUawr6966jTXnWieosZ6Oaf94iNCI1fXAGqkOWQfbfu6wcMvK((fnbhckcHJ0SUawr67x0eCiOieEKk3wsWinRJcu0JJCYjwxeRbcPGcRweuqPBjywr6966jTXaJq4inRlGvKEVUEsBCdmcHJ0SokqrpoYjNyDrSgiKckSArqbLULGzfP3RRN0gHuechPzDbSI0711tAJlKIq4inRJcu0JJCYjwxeRbgKGcRweuqPBjywr67x0eCiOieosZ6cyfPVFrtWHGIq4rQCBjbJ0SocsIECKtMtgcdPcQTCqBziadkSYAaEjw7quWTSobhRin6rgqOTVinRh9G)(iywXGqIv)VGqFjywnVEHGWro5eRlI1Geuy1IGckDlbZksVxxpPngyechPzDbSI0711tAJBGriCKM1rqs0JJCYjwxeRwAqHvlckO0TemRi9ED9K2iKIq4inRlGvKEVUEsBCHuechPzDeKe94iNCI1fXAajOWQfbfu6wcMvK((fnbhckcHJ0SUawr67x0eCiOieEKk3wsWinRJcu0JJCYjwxeRpqqHvlckO0TemRi99lAcoeuechPzDbSI03VOj4qqri8ivUTKGrAwhfOOhh5K5KHWqQGAlh0wgcWGcRSgGxI1oefClRtWXks7acPz9Oh83hbZkgesS6)fe6lbZQ51leeoYjNyDrSgKGcRweuqPBjywr67x0eCiOieosZ6cyfPVFrtWHGIq4rQCBjbJ0SokqrpoYjNyDrSAHGcRweuqPBjywh6qlYkg5ADrZkeccX6cynX(oRHa4V8JzfGsNVGJ1rqOXSokqrpoYjNyDrSkQdkSArqbLULGzDOdTiRyKR1fnRqiwxaRj23zfUH24guScqPZxWX6iipM1rbk6Xro5eRlI1atiOWQfbfu6wcM1Ho0ISIrUwx0ScHyDbSMyFNv4gAJBqXkaLoFbhRJG8ywhfOOhh5KtSUiwd0sdkSArqbLULGzDOdTiRyKR1fnRqiieRlG1e77SgcG)YpMvakD(cowhbHgZ6Oaf94iNCI1fXAGpqqHvlckO0TemRdDOfzfJCTUOzfcX6cynX(oRWn0g3GIvakD(cowhb5XSokqrpoYjNyDrScPadkSArqbLULGzDOdTiRyKR1fnRqiwxaRj23zfUH24guScqPZxWX6iipM1rbk6Xro5eRlIvibbdkSArqbLULGzDOdTiRyKR1fnRqiwxaRj23zfUH24guScqPZxWX6iipM1rqs0JJCYCYqyivqTLdAldbyqHvwdWlXAhIcUL1j4yfPNUuUV3hPz9Oh83hbZkgesS6)fe6lbZQ51leeoYjNyDrScPGcRweuqPBjywh6qlYkg5ADrZkeI1fWAI9DwHBOnUbfRau68fCSocYJzDuGIECKtMtgcdPcQTCqBziadkSYAaEjw7quWTSobhRinErAwp6b)9rWSIbHeR(FbH(sWSAE9cbHJCYjwxeRbgyqHvlckO0TemRdDOfzfJCTUOzfcbHyDbSMyFN1qa8x(XScqPZxWX6ii0ywhfOOhh5KtSUiwdesbfwTiOGs3sWSo0HwKvmY16IMvieeI1fWAI9DwdbWF5hZkaLoFbhRJGqJzDuGIECKtoX6Iyfsjeuy1IGckDlbZ6qhArwXixRlAwHqSUawtSVZkCdTXnOyfGsNVGJ1rqEmRJcu0JJCYCYqyivqTLdAldbyqHvwdWlXAhIcUL1j4yfPTb(I0SE0d(7JGzfdcjw9)cc9LGz186fcch5KtSUiwdmGeuy1IGckDlbZ6qhArwXixRlAwHqSUawtSVZkCdTXnOyfGsNVGJ1rqEmRJcIOhh5KtSUiwd8bckSArqbLULGzDOdTiRyKR1fnRqiwxaRj23zfUH24guScqPZxWX6iipM1rbk6Xrozo5GoefClbZkeKv3SnOyv24fh5KfgWOKrWYbMaKegqpWSLKWWdFiRjYLEziwt83VH5KF4dzfcKSVVFiZAGbbjScPeGuGCYCYp8HSAXxVqq4GcN8dFiRbuwrkyycM1bG0pwte5Hro5h(qwdOSAXxVqqWSU(HG2Cpz14ycZ6cy1GSrs51pe0IJCYp8HSgqznOMcbqjyw)vrgcJ9dzwH6x72scZ6OosrKWk6rqZ41p8)qqSgqtIv0JGgXRF4)HGgh5KF4dznGYksbf0WSIEKXXBxiyfc789L1EYAVinM19Lyv8bkeSkkgzJIPiN8dFiRbuwHa6pjwTiOGcEsSUVeRdO91lMvNvzVRKyneCeRtjj62wsSoQNSIm4Z6Rdxi9Y6BVS2lR4o8lxViWhlrMvX9(YAIcQgPcaRpYQfjjH32LSIuYgrfs1Iew7fPHzf)Srhh5K5KDZ2GchrpYacT9vKNDbFeCgJ2xVyo5hYAaEjwH6x72sI1gZkMwwxaRjWQ4EFzTaSIxFzfuS(XeR711tAXiH1azv8lvSUVeRZ(WlRGIyTXSckw)ycjScjw7jR7lXkMmGcM1gZQxWSgew7jR2G9Lv)ioz3SnOWr0JmGqBFFueid1V2TLeskpKebu5pMY711tArcux(jrsGt2nBdkCe9idi023hfbYq9RDBjHKYdjrav(JP8ED9KwKaqfXHHrcux(jrcej9uK966jTXaJFSBljR711tAJbgnaGegiUIW)Z3guCYUzBqHJOhzaH2((OiqgQFTBljKuEijcOYFmL3RRN0IeaQiommsG6YpjcKqspfzVUEsBesXp2TLK1966jTrifnaGegiUIW)Z3guCYUzBqHJOhzaH2((OiqoeaQNDLNGlKt(HSM4oY44LviXke257lREbZQZ6W6h(FiiwbfRdbGvX9(YQLBeVlRqGoXQxWSMiasfawbhRdRFZ(iwb7lDIBmXj7MTbfoIEKbeA77JIazXNVVir2fLnWIeyciPNImImYgftr5V8lxKO30uYiBumf7kl)LFPPKr2Oyk2v2gSVPPKr2Oyk6fY5Ie9oMt2nBdkCe9idi023hfbYIpFFrspfzezKnkMIYF5xUirVPPKr2Oyk2vw(l)stjJSrXuSRSnyFttjJSrXu0lKZfj6DSv0JGgdmk(891AWOhbncPO4Z3xoz3SnOWr0JmGqBFFueiJx)M9riPNIe89lAcoeu02LEzOmyMDPmVVDHaNMgSbaLkV2y1iE380P00GXOKuMx)qqloIx)MUuksGPPbVUKQnw((pcNTDPxgksLBljyoz3SnOWr0JmGqBFFueiJx)W)dbHKEkY9lAcoeu02LEzOmyMDPmVVDHaB1aGsLxBSAeVBE6KvmkjL51pe0IJ41VPlLIeiNmN8dFiRIIOjZFjywjO0HmRBhsSUVeRUzbhRnMvhQ3s3wsroz3SnOWIGbs)Y2KhYj)qwhOfZksbefwbfRb5rwf37l4VScF9Cz1lywf37lRdRFsWbZQxWScPhzfSV0jUXeNSB2guyrG6x72scjLhsI04SdiKa1LFsemkjL51pe0IJ41VPlLjfO1rbVUKQnIx)KGdosLBlj4001LuTr8ssPFz4RNBKk3wsWJttXOKuMx)qqloIx)MUuMeK4KFiRd0Iz1ijhkXQ4xQyDy9B2hXQXlwF7Lvi9iRRFiOfZQ4328YAJz9ijb1RL1j4yDFjwffJSrXeRlGvBIv0JM0DemNSB2gu4hfbYq9RDBjHKYdjrAC2ijhkHeOU8tIGrjPmV(HGwCeV(n7Jskqo5hYQLGjwTPdt3ZUqWQ4EFz14Scow95shRweuqbpjw7IvJZj7MTbf(rrGSnDy6E2fcK0trgfSbaLkV2y1iE380P00GnaGegiUIgqbf8KY7lLXO91lo(rhB1(pNrJN7Ye)OCYpK1ehyzvCVVSACw3xFzTXfsVS6SM4(sSFSIEadNSB2gu4hfbYOGTbfs6Pi2)5mA8CxM4rHEx4Kcmbo5hYQfDP5l9LWSk(L2x6y9J7cbRweuqbpjwlGywf3sjRUuceZkYGpRlGv82sjRghVSUVeRypKy1db)Azfmz1IGck4j9Ofrkih0LHvJJxmNSB2gu4hfbYq9RDBjHKYdjrmGck4jLHjmYLbjqD5NeXqTC0OUw6qbsFj48Sr8U5Jc9UWb0aTqa1aasyG4kA8CxM4rHEx4XqOadijmwed1YrJ6APdfi9LGZZgX7Mpk07chqd0cb0aHucbudaiHbIRObuqbpP8(szmAF9IJhf6DHhdHcmGKW40udaiHbIROXZDzIhf6DHtQRLouG0xcopBeVB(OqVlCAQbaKWaXv0akOGNuEFPmgTVEXXJc9UWj11shkq6lbNNnI3nFuO3foGgycPPbBaqPYRnwnI3npDIt(HSAjycM1fWkmjDKzDFjw)yhbXkyYQfrkih0LHvXVuX6h3fcwHbFBjXkOy9Jjoz3SnOWpkcKH6x72scjLhsIyGZgqb3BdkKa1LFsKrbtp4Vrrj4ifII8rUmdo4YldLMAaajmqCfPquKpYLzWbxEzO4rHExyigiembRbBaajmqCfPquKpYLzWbxEzO4romYJttnaOu51gFI81EXj)qwTemXQOeII8rUK1GQp4YldXkKsatgmR20eCeRoRwePGCqxgw)ykYj7MTbf(rrG8ht5EPqKuEijcfII8rUmdo4YldHKEkIbaKWaXv045UmXJc9UWqesjy1aasyG4kAafuWtkVVugJ2xV44rHExyicPestNnI3nFuO3fgIbruZj)qwTemX6a4lL02fcwdQ)2iZkeetgmR20eCeRoRwePGCqxgw)ykYj7MTbf(rrG8ht5EPqKuEijcg8LsA3UqKVVnYiPNIyaajmqCfnEUlt8OqVlmeHGwdgQFTBlPObuqbpPmmHrUmPPgaqcdexrdOGcEs59LYy0(6fhpk07cdriOvO(1UTKIgqbf8KYWeg5YKMoBeVB(OqVlmeHKf4KDZ2Gc)Oiq(JPCVuiskpKePlS5(RBlP8d(9A)HzycABiK0trS)Zz045UmXpkN8dznaVnM1gZQZ657lDSss3gC(sSk2rM1fWAO)Ky1LswbfRFmXkE9L1966jTywxaR2eRYUiyw)OSkU3xwTisb5GUmS6fmRweuqbpjw9cM1pMyDFjwHubZkwcwwbfRgyw7jR2G9L1966jTyw9JyfuS(XeR41xw3RRN0I5KDZ2Gc)OiqEVUEsBGiPNImcQFTBlPiOYFmL3RRN0ksGPPq9RDBjfbv(JP8ED9KwrcYyRJS)Zz045UmXpAAQbaKWaXv045UmXJc9UWpcPK2RRN0gdmAaajmqCfH)NVnOSokydakvETXQr8U5PtPPbd1V2TLu0akOGNugMWixMXwd2aGsLxB8jYx7vAQbaLkV2y1iE380jRq9RDBjfnGck4jLHjmYLXQbaKWaXv0akOGNuEFPmgTVEXXpQ1GnaGegiUIgp3Lj(rToAK9FoJKr2Oykl)LFXJc9UWjfycPP2)5msgzJIPmgi9lEuO3foPatyS1GVFrtWHGI2U0ldLbZSlL59Tle400r2)5mA7sVmugmZUuM33UqGZLV)JI41npfXcPP2)5mA7sVmugmZUuM33UqGZ(z8II41npfXcJhNMA)NZ4ZUGpcotHOaX0fs1MPIoeDatXp6400zJ4DZhf6DHHiKsinfQFTBlPiOYFmL3RRN0kscCYUzBqHFueiVxxpPfsiPNIa1V2TLueu5pMY711tAfjiwdEVUEsBmW4romYzdaiHbIR00r2)5mA8CxM4hnn1aasyG4kA8CxM4rHEx4hHus711tAJqkAaajmqCfH)NVnOSokydakvETXQr8U5PtPPbd1V2TLu0akOGNugMWixMXwd2aGsLxB8jYx7vAQbaLkV2y1iE380jRq9RDBjfnGck4jLHjmYLXQbaKWaXv0akOGNuEFPmgTVEXXpQ1GnaGegiUIgp3Lj(rToAK9FoJKr2Oykl)LFXJc9UWjfycPP2)5msgzJIPmgi9lEuO3foPatyS1GVFrtWHGI2U0ldLbZSlL59Tle400r2)5mA7sVmugmZUuM33UqGZLV)JI41npfXcPP2)5mA7sVmugmZUuM33UqGZ(z8II41npfXcJhpon1(pNXNDbFeCMcrbIPlKQntfDi6aMIF000zJ4DZhf6DHHiKsinfQFTBlPiOYFmL3RRN0kscCYpKvlbtywDPKvW(shRGI1pMyTxkeZkOy1aZj7MTbf(rrG8ht5EPqms6Pi2)5mA8CxM4hnn1aGsLxBSAeVBE6KvO(1UTKIgqbf8KYWeg5Yy1aasyG4kAafuWtkVVugJ2xV44h1AWgaqcdexrJN7Ye)OwhnY(pNrYiBumLL)YV4rHEx4KcmH0u7)CgjJSrXugdK(fpk07cNuGjm2AW3VOj4qqrBx6LHYGz2LY8(2fcCA69lAcoeu02LEzOmyMDPmVVDHaBDK9FoJ2U0ldLbZSlL59Tle4C57)OiEDZZKcsAQ9FoJ2U0ldLbZSlL59Tle4SFgVOiEDZZKcY4XPP2)5m(Sl4JGZuikqmDHuTzQOdrhWu8JMMoBeVB(OqVlmeHucCYpK1epzAyIv3SnOyv24LvBhtWSckwX9(9TbfKLeIgZj7MTbf(rrG89RSB2guzzJxKuEijIdiKG3RnRibIKEkcu)A3wsXgNDaXj7MTbf(rrG89RSB2guzzJxKuEijInWxKG3RnRibIKEkY9lAcoeu02LEzOmyMDPmVVDHahPh83OOemNSB2gu4hfbY3VYUzBqLLnErs5HKi4LtMt(HSArxA(sFjmRIFP9Low3xI1e)rEOXxZlDSA)Ntwf3sjRtxkzfmNSkU33UyDFjwls0lRghVCYUzBqHJoGebQFTBljKuEijc8rEywClL5PlLzWCIeOU8tImY(pNXTdjXGRYWh5H2Dbtx8OqVlmeryGJHUOFmHyGPP2)5mUDijgCvg(ip0Uly6Ihf6DHHOB2gur863SpksIMm)LYBhspMqmqRJiJSrXuSRS8x(LMsgzJIPigi9lxKO30uYiBumf9c5CrIEhp2Q9FoJBhsIbxLHpYdT7cMU4h169lAcoeuC7qsm4Qm8rEODxW0fPh83OOemN8dz1IU08L(sywf)s7lDSoS(H)hcI1gZQyWTVSAC82fcwbqPJ1H1VzFeRDXAI9l)yvumYgftCYUzBqHJoGEueid1V2TLeskpKePruGJY41p8)qqibQl)KibtgzJIPyxzmq6N1ryuskZRFiOfhXRFZ(OKSG11LuTrm4lZGzEFP8eCeEJu52sconfJsszE9dbT4iE9B2hLKOEmN8dz1sWeRweuqbpjwf)sfR(YQKWyw3xVy1cjWQJ3ZLSIcethREbZQSlI1pkRI79LvlIuqoOldRI79f8xwLaCxiy1z9Jjoz3SnOWrhqpkcKnGck4jL3xkJr7Rxms6PiJG6x72skAafuWtkdtyKlJ1GnaGegiUIgp3LjEKdJCAQ9FoJgp3Lj(rhBDKJ3ZLzuGy6GOfsinfQFTBlPyJOahLXRF4)HGgBDK9FoJKr2Oykl)LFXJc9UWjbbttT)ZzKmYgftzmq6x8OqVlCsqWXwhf89lAcoeu02LEzOmyMDPmVVDHaNMA)NZOTl9YqzWm7szEF7cbox((pkIx38mPGKMA)NZOTl9YqzWm7szEF7cbo7NXlkIx38mPGmonD2iE38rHExyigycCYpKvlbtSI)1SpI1Uyf1lykSnSk(Lkw9L1aTumzWSEuO3vxiyfCSkjmMvX9(YAi4iwx)qqlMvVGzTNS2lRIbFjmRtxkzfmNSAttWrSs1sxxiyDFjwls0lRIIr2OyIt2nBdkC0b0JIaz8VM9riXGSrs51pe0IfjqK0trgD08i8RBlP0u7)CgjJSrXugdK(fpk07cdXGyLmYgftXUYyG0pRhf6DHHyGwQ11LuTrm4lZGzEFP8eCeEJu52scES11pe0g3oKYlid3usbAPbumkjL51pe0IF8OqVlS1rKr2Oyk2v2lKttpk07cdreg4yOl6XCYpK1GkjcL1pkRdRFtxkz1xwDPK1TdjmR)ssymRFCxiynXq24NJz1lyw7L1gZQBd(lRlGv0dyyfCSkPL19LyfJsM2LS6MTbfRYUiwTjjqmRVEbljwt8h5H2DbthRGIviX66hcAXCYUzBqHJoGEueiJx)MUuIKEkYi7)CgXRFtxkJhnpc)62sY6imkjL51pe0IJ41VPlLqmiPPbF)IMGdbf3oKedUkdFKhA3fmDr6b)nkkbponDDjvBed(YmyM3xkpbhH3ivUTKGTA)NZizKnkMYyG0V4rHExyigeRKr2Oyk2vgdK(z1(pNr8630LY4rHExyikQTIrjPmV(HGwCeV(nDPmjrS0Xwhf89lAcoeuuISXphNNsI2UqKri7qumfPh83OOeCA62HeecczPwij7)CgXRFtxkJhf6DHFesJTU(HG242HuEbz4MsYcCYpKviSEFznXFKhA3fmDS(XeRdRFtxkzDbS(Kiuw)OSUVeR2)5KvBKz1LyaRFCxiyDy9B6sjRGIvlWkMmGcgZk4yvsymRhf6D1fcoz3SnOWrhqpkcKXRFtxkrspf5(fnbhckUDijgCvg(ip0Uly6I0d(Buuc2kgLKY86hcAXr8630LYKejiwhfS9FoJBhsIbxLHpYdT7cMU4h1Q9FoJ41VPlLXJMhHFDBjLMocQFTBlPi8rEywClL5PlLzWCADK9FoJ41VPlLXJc9UWqmiPPyuskZRFiOfhXRFtxktcswxxs1gXljL(LHVEUrQCBjbB1(pNr8630LY4rHExyiAHXJhZj)qwTOlnFPVeMvXV0(shRoRdRF4)HGy9Jjwf3sjRg)Jjwhw)MUuY6cyD6sjRG5ejS6fmRFmX6W6h(FiiwxaRpjcL1e)rEODxW0XkEDZtw)OCYUzBqHJoGEueid1V2TLeskpKebV(nDPmlguBE6szgmNibQl)KioEpxMrbIPlPascb0rbMGOY(pNXTdjXGRYWh5H2DbtxeVU554a6i7)CgXRFtxkJhf6DHfvbbcHrjPm)64Lghqhbd248FiNbZmj)ffpk07clQSWyR2)5mIx)MUug)OCYpKvlbtSoS(H)hcIvX9(YAI)ip0Uly6yDbS(Kiuw)OSUVeR2)5KvX9(c(lRsaUleSoS(nDPK1p62HeREbZ6htSoS(H)hcIvqXQL(iRjcGubGv86MNyw)12swTuwx)qqlMt2nBdkC0b0JIaz86h(FiiK0trG6x72skcFKhMf3szE6szgmNwH6x72skIx)MUuMfdQnpDPmdMtRbd1V2TLuSruGJY41p8)qqPPJS)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEMuqstT)Zz02LEzOmyMDPmVVDHaN9Z4ffXRBEMuqgBfJsszE9dbT4iE9B6sjeTuo5hYQLGjwXI9lKvmG191xwrg8zfbTSg6IM1p62HeR2iZ6h3fcw7LvhZQ0xIvhZkkaJBBjXkOyvsymR7RxSgewXRBEIzfCScbWhVSk(LkwdYJSIx38eZkjA0(ioz3SnOWrhqpkcKDyhDBOugl2VqKyq2iP86hcAXIeis6PibVT5zxiSgSB2gurh2r3gkLXI9lmd7Hock2vEkBeVBAkmyJoSJUnukJf7xyg2dDeueVU5jedIvyWgDyhDBOugl2VWmSh6iO4rHExyigeo5hYAqnnpc)YAiauZ(iw7jRwePGCqxgwBmRh5WiZk4yDFPJy1pIvjHXSUVEXQfyD9dbTyw7I1e7x(XQOyKnkMyvCVVSIb7KvWXQKWyw3xVynWeyfSV0jUXeRDXQxiZQOyKnkMISM4bfsVSE08i8lRW)RleS(Sl4JGzLcrbIPlKQLvVGzfgui9YkakDghLvhJYj7MTbfo6a6rrGCiauZ(iKyq2iP86hcAXIeis6Pihnpc)62sY66hcAJBhs5fKHBkPrbAPpocJsszE9dbT4iE9B2hjQcmAHXJHqyuskZRFiOf)4rHExyRJgzaajmqCfnEUlt8ihgzRbdF)gowGSbgBDeu)A3wsrdOGcEszycJCzstnaGegiUIgqbf8KY7lLXO91loEKdJCAAWgauQ8AJvJ4DZtNgNMIrjPmV(HGwCeV(n7JG4iliQgf4JRlPAJR4UYHaqHJu52scE8400rKr2Oyk2vgdK(LMoImYgftXUY2G9nnLmYgftXUYYF53yRbVUKQnIbFzgmZ7lLNGJWBKk3wsWPP2)5mIEDi4GBxM9Z4vBYOFj2Viux(PKebswiHXwhHrjPmV(HGwCeV(n7JGyGjiQgf4JRlPAJR4UYHaqHJu52scE8yRoEpxMrbIPljlKqa1(pNr8630LY4rHExyrfeCS1rbB)NZ4ZUGpcotHOaX0fs1MPIoeDatXpAAkzKnkMIDLXaPFPPbBaqPYRn(e5R9ASvhnBEjZZXCYpKvlbtSobfRGIvdmRI79f8xwnokAxi4KDZ2GchDa9OiqEcodLbZC57)iK0trC0S5Lmp5KFiRwcMyDEufWiZkOy1aJew33gZQ4wkz1)li0324sjYSk7Iy9JYQ4EFz14CYUzBqHJoGEueiFouQaFCEEufWiJKEkI9FoJgp3Lj(r5KFiRwcMy1IifKd6YWkOy1aZ6VKegZkYGpRgVyv2fXAVS(rzvCVVSArqbf8KyvCVVG)YQeG7cbRoRghVCYUzBqHJoGEueiBijH32Lzx2iQqQwK0trcg((nCSazdm2ku)A3wsrdC2ak4EBqzDK9FoJ41VPlLXpAAQJ3ZLzuGy6sYcjm2AW2)5mIbs82gk(rTgS9FoJgp3Lj(rTokydakvETXQr8U5PtPPq9RDBjfnGck4jLHjmYLjn1aasyG4kAafuWtkVVugJ2xV44hnnTRLouG0xcopBeVB(OqVlmeHucpoYak4FVr0JmnMYUSruHuTXTdPmux(PXJ5KDZ2GchDa9OiqUlJFLVnOqspfjy473WXcKnWyRq9RDBjfnWzdOG7TbL1r2)5mIx)MUug)OPPoEpxMrbIPljlKWyRbB)NZigiXBBO4h1AW2)5mA8CxM4h16OGnaOu51gRgX7MNoLMc1V2TLu0akOGNugMWixM0udaiHbIRObuqbpP8(szmAF9IJF000Uw6qbsFj48Sr8U5Jc9UWq0aasyG4kAafuWtkVVugJ2xV44rHEx4hHGPPDT0HcK(sW5zJ4DZhf6DHHqqOadijaXGKWJJmGc(3Be9itJPSlBevivBC7qkd1LFA8yo5hYQLGjwbfRgywf37lRdRFtxkz9JYQxWSIDOeRtWXAI7lX(Xj7MTbfo6a6rrGmfIcetx2guWiPNI01shkq6lbNNnI3nFuO3fgIbAH00r2)5mIEDi4GBxM9Z4vBYOFj2Viux(jicjlKqAQ9FoJOxhco42Lz)mE1Mm6xI9lc1LFkjrGKfsySv7)CgXRFtxkJFuRJmaGegiUIgp3LjEuO3fojlKqAk89B4ybYgy8yo5hYAqnnpc)Y6u6hXkOy9JY6cyniSU(HGwmRI79f8xw7YazJZQn1fcwDBWFzDbSsIgTpIvVGzTalRaO0zCu0UqWj7MTbfo6a6rrGmEjP0V8u6hHedYgjLx)qqlwKarspf5O5r4x3wsw3oKYlid3usbAbRyuskZRFiOfhXRFZ(iiAPwD0S5LmpToY(pNrJN7Yepk07cNuGjKMgS9FoJgp3Lj(rhZj)qwTemHzfceikS2tw7c3WeREXQOyKnkMy1lywLDrS2lRFuwf37lRoRjUVe7hROhWWQxWSIuWo62qjwhe7xiNSB2gu4OdOhfbYZ)HCgmZK8xes6PiKr2Oyk2v2lKT6OzZlzEA1(pNr0RdbhC7YSFgVAtg9lX(fH6YpbrizHeSocgSrh2r3gkLXI9lmd7HockUT5zxistd2aGsLxBSiZbKGdonfJsszE9dbT4KG0yo5hYQLGjw9Ivqr7lROhWW6VKegZ6W630LswBmRU8ihgzw)OScowrg8z1pIv3g8xwxaRaO0zCuwDmkNSB2gu4OdOhfbY41VPlLiPNIy)NZiOO9fNrPZqOBdQ4h16i7)CgXRFtxkJhnpc)62skn1X75YmkqmDj9ajmMt(HSM4)HOS6yuwTPj4iwTiOGcEsSkU3xwhw)MUuYQxWSUVuX6W6h(Fiioz3SnOWrhqpkcKXRFtxkrspfXaGsLxBSAeVBE6K1rq9RDBjfnGck4jLHjmYLjn1aasyG4kA8CxM4hnn1(pNrJN7Ye)OJTAaajmqCfnGck4jL3xkJr7RxC8OqVlmeryGJHUOfvgQLJC8EUmJcetheYcjm2Q9FoJ41VPlLXJc9UWq0sTgm89B4ybYgymNSB2gu4OdOhfbY41p8)qqiPNIyaqPYRnwnI3npDY6iO(1UTKIgqbf8KYWeg5YKMAaajmqCfnEUlt8JMMA)NZOXZDzIF0XwnaGegiUIgqbf8KY7lLXO91loEuO3fgIqqR2)5mIx)MUug)OwjJSrXuSRSxiBnyO(1UTKInIcCugV(H)hcYAWW3VHJfiBGXCYpKvlbtSoS(H)hcIvX9(YQxSckAFzf9agwbhRid(inmRaO0zCuwDmkRI79LvKb)J1Ie9YQXXBKvKsIbSc)drXS6yuw9L19LyLkywbtw3xIvOuTViFSA)Ntw7jRdRFtxkzvm4lHRL1PlLScMtwbfRwkRGJvjHXSU(HGwmNSB2gu4OdOhfbY41p8)qqiPNIy)NZiOO9fNnsYVm0g3Gk(rtthfmE9B2hfD0S5LmpTgmu)A3wsXgrbokJx)W)dbLMoY(pNrJN7Yepk07cdrly1(pNrJN7Ye)OPPJS)Zz8COub(488OkGroEuO3fgIimWXqx0Ikd1YroEpxMrbIPdcfKegB1(pNXZHsf4JZZJQag54hD8yRq9RDBjfXRFtxkZIb1MNUuMbZPvmkjL51pe0IJ41VPlLqmiJTok47x0eCiO42HKyWvz4J8q7UGPlsp4Vrrj40umkjL51pe0IJ41VPlLqmiJ5KFiRwcMyfciauyw7I1bG0pwffJSrXeREbZk2HsScb(LswHacafRtWXQfrkih0LHt2nBdkC0b0JIa5IeNdbGcj9uKr2)5msgzJIPmgi9lEuO3fojs0K5VuE7qknDK51peeweiz9iZRFiO82HeeTW40uZRFiiSibzSvhnBEjZtoz3SnOWrhqpkcKFD5mhcafs6PiJS)ZzKmYgftzmq6x8OqVlCsKOjZFP82HuA6iZRFiiSiqY6rMx)qq5TdjiAHXPPMx)qqyrcYyRoA28sMNCYUzBqHJoGEueip)szoeakK0trgz)NZizKnkMYyG0V4rHEx4KirtM)s5TdjRJmaGegiUIgp3LjEuO3fojlKqAQbaKWaXv0akOGNuEFPmgTVEXXJc9UWjzHegNMoY86hcclcKSEK51peuE7qcIwyCAQ51peewKGm2QJMnVK5jN8dz1sWeRqyarHv4)1fcwtSF5hRIIr2OyIt2nBdkC0b0JIazX(Dn4YGzMK)I4KDZ2GchDa9OiqgQFTBljKuEijcE9B2hL7kJbs)qcux(jrWOKuMx)qqloIx)M9rjzPpoLaWnk0XlDiNH6YpjQcmHeGqqkHXpoLaWnY(pNr86h(FiOmfIcetxivBgdK(fXRBEcHS0XCYpKvlbtScHD((YAxSoaK(XQOyKnkMyfCSUVeRshVSoS(n7JyvmOwwN9YAxlGvNvlIuqoOldR2)5mYj7MTbfo6a6rrGS4Z3xK0triJSrXuu(l)Yfj6nnLmYgftrVqoxKOxRq9RDBjfBC2ijhkLMA)NZizKnkMYyG0V4rHExyi6MTbveV(n7JIKOjZFP82HKv7)CgjJSrXugdK(f)OPPKr2Oyk2vgdK(znyO(1UTKI41VzFuURmgi9ln1(pNrJN7Yepk07cdr3SnOI41VzFuKenz(lL3oKSgmu)A3wsXgNnsYHswT)Zz045UmXJc9UWqKenz(lL3oKSA)NZOXZDzIF00u7)CgphkvGpoppQcyKJFuRyuskZVoEPKsicbTocJsszE9dbTyiksqstdEDjvBed(YmyM3xkpbhH3ivUTKGhNMgmu)A3wsXgNnsYHswT)Zz045UmXJc9UWjrIMm)LYBhsCYpKvlbtSoS(n7JyTNS2fRj2V8JvrXiBumHew7I1bG0pwffJSrXeRGIvl9rwx)qqlMvWX6cyf9agwhas)yvumYgftCYUzBqHJoGEueiJx)M9rCYpKviqxk337Zj7MTbfo6a6rrG89RSB2guzzJxKuEijY0LY99(CYCYpKviWJQagzwf37lRwePGCqxgoz3SnOWrBGVICouQaFCEEufWiJKEkI9FoJgp3Lj(r5KFiRw8LmpXS2tw3xIvZ1lR2)5K1gZAbww)OSobhRsFPJ1pM4KDZ2GchTb((OiqgQFTBljKuEijI56Ta7hfjqD5Nejy7)CgTDPxgkdMzxkZ7BxiW5Y3)rXpQ1GT)Zz02LEzOmyMDPmVVDHaN9Z4ff)OCYUzBqHJ2aFFuei7Wo62qPmwSFHiXGSrs51pe0IfjqK0trS)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEcrl1Q9FoJ2U0ldLbZSlL59Tle4SFgVOiEDZtiAPwhfmmyJoSJUnukJf7xyg2dDeuCBZZUqyny3SnOIoSJUnukJf7xyg2dDeuSR8u2iExRJcggSrh2r3gkLXI9lm)sUmUT5zxistHbB0HD0THszSy)cZVKlJhf6DHtkiJttHbB0HD0THszSy)cZWEOJGI41npHyqScd2Od7OBdLYyX(fMH9qhbfpk07cdrlyfgSrh2r3gkLXI9lmd7HockUT5zxigZj)qwTemXQfbfuWtIvycLk4UqWkOyfJCzy9JYQ4EFz1IifKd6YWkOy1aZk4y1gzwf792fcwxacAFPJvX9(YQZQ56Lv7)CYj7MTbfoAd89rrGSbuqbpP8(szmAF9Irspfzeu)A3wsrdOGcEszycJCzSgSbaKWaXv045UmXJCyKttT)Zz045UmXp6yRJS)Zz02LEzOmyMDPmVVDHaNlF)hfXRBEkIfstT)Zz02LEzOmyMDPmVVDHaN9Z4ffXRBEkIfgNMoBeVB(OqVlmedmbo5hYQf9Yqswhw)KGdMvX9(YQKWyw3xVyfcYkMmywpk07QleS6fmRUn4VSUawH)HOSoS(H)hccZj7MTbfoAd89rrGSXldjZ2)5ejLhsIGx)KGdgj9uKr2)5mA7sVmugmZUuM33UqGZLV)JIhf6DHtYsJwin1(pNrBx6LHYGz2LY8(2fcC2pJxu8OqVlCswA0cJT649CzgfiMUKe5bsW6idaiHbIROXZDzIhf6DHtsuNMoYaasyG4ksHOaX0LTbfC8OqVlCsIARbB)NZ4ZUGpcotHOaX0fs1MPIoeDatXpQvdakvETXNiFTxJhZj7MTbfoAd89rrGmE9B6sjs6PiRlPAJ4LKs)YWxp3ivUTKGTIPD7cboIbsqg(65A1(pNr8630LYimqCXj)qwt8)quwhw)W)dbHzvCVVSUVeR2aFz1(pNSA)xwlWYQ4xQyffaKDHG1j4y14ScowPquGy6y1guWCYUzBqHJ2aFFueiJx)W)dbHKEksWq9RDBjfnxVfy)OwhzaqPYRnwnI3npDkn1aasyG4kA8CxM4rHEx4Ke1PPbd1V2TLu0aNnGcU3guwd2aGsLxB8jYx7vA6idaiHbIRifIcetx2guWXJc9UWjjQTgS9FoJp7c(i4mfIcetxivBMk6q0bmf)OwnaOu51gFI81EnEmN8dznX)drzDy9d)peeMvBAcoIvlckOGNeNSB2gu4OnW3hfbY41p8)qqiPNImYaasyG4kAafuWtkVVugJ2xV44rHExyiAbRbdF)gowGSbgBDeu)A3wsrdOGcEszycJCzstnaGegiUIgp3LjEuO3fgIwySvO(1UTKIg4SbuW92GASvhVNlZOaX0LKLMGvdakvETXQr8U5Ptwdg((nCSazdm2kzKnkMIDL9czo5hYAIhui9Ykmyzf(FDHG19LyLkywbtwTisb5GUmiHv4)1fcwF2f8rWSsHOaX0fs1Yk4yTlw3xIvPJxwryGzfmz1lwffJSrXeNSB2gu4OnW3hfbYq9RDBjHKYdjrGbB(Oh83hfs1Ircux(jrgz)NZOXZDzIhf6DHtYcwhz)NZ45qPc8X55rvaJC8OqVlCswinny7)CgphkvGpoppQcyKJF0XPPbB)NZOXZDzIF0XwhfS9FoJp7c(i4mfIcetxivBMk6q0bmf)OJToY(pNrYiBumLXaPFXJc9UWjHWahdDrNMA)NZizKnkMYYF5x8OqVlCsimWXqx0J5KDZ2GchTb((Oiqg)RzFesmiBKuE9dbTyrcej9uKJMhHFDBjzD9dbTXTdP8cYWnLuGqqRoA28sMNwH6x72skcd28rp4VpkKQfZj7MTbfoAd89rrGCiauZ(iKyq2iP86hcAXIeis6Pihnpc)62sY66hcAJBhs5fKHBkPads0cwD0S5LmpTc1V2TLuegS5JEWFFuivlMt2nBdkC0g47JIaz8ssPF5P0pcjgKnskV(HGwSibIKEkYrZJWVUTKSU(HG242HuEbz4Mskqi4Jhf6DHT6OzZlzEAfQFTBlPimyZh9G)(OqQwmN8dzfceyzwb)f3WeR7lXQ56Lv7)CYk4yv8lvSIm4ZkmOq6L1xhkXkvGpIxwDmkRlGv8)qqCYUzBqHJ2aFFueipbNHYGzU89Fes6PioA28sMNCYpKviqGOWQnnbhXQZQ56LvXDbdeZk4yTlCdtS6fRIIr2OyIt2nBdkC0g47JIa55)qodMzs(lcj9uKrKr2Oyk2v2lKttjJSrXuedK(L7khyAkzKnkMIYF5xURCGJTokydakvETXQr8U5PtPPW3VHJfiBGXPPJC8EUmJcetheFalyDeu)A3wsrZ1Bb2pAAQJ3ZLzuGy6GyqsinfQFTBlPyJZoGgBDeu)A3wsrdOGcEszycJCzSgSbaKWaXv0akOGNuEFPmgTVEXXpAAAWq9RDBjfnGck4jLHjmYLXAWgaqcdexrJN7Ye)OJhp26idaiHbIROXZDzIhf6DHtkijKMcF)gowGSbgNM649CzgfiMUKEGeSAaajmqCfnEUlt8JADKbaKWaXvKcrbIPlBdk44rHExyi6MTbveV(n7JIKOjZFP82HuAAWgauQ8AJpr(AVgNM21shkq6lbNNnI3nFuO3fgIbMWyRJGbB0HD0THszSy)cZWEOJGIhf6DHtYsttd2aGsLxBSiZbKGdEmN8dzvucrbIPJvBqbZQ4xQyf8xCdtS6fRIIr2OyIvWXQfrkih0LH1gZQBd(lRGLvBI1pMGJSo4qjwNGJvlIuqoOldNSB2gu4OnW3hfbYuikqmDzBqbJKEkYiYiBumfL)YVCrIEttjJSrXuedK(Lls0BAkzKnkMIEHCUirVPP2)5mA7sVmugmZUuM33UqGZLV)JIhf6DHtYsJwin1(pNrBx6LHYGz2LY8(2fcC2pJxu8OqVlCswA0cPPoEpxMrbIPlPhibRgaqcdexrJN7YepYHr2AWW3VHJfiBGXJToYaasyG4kA8CxM4rHEx4KcscPPgaqcdexrJN7YepYHrECAAxlDOaPVeCE2iE38rHExyigycCYpKvlIuqoOldRIFPIvFz9bs4rwDmkRI79f8xwLaCxiyD7qI1Uynrsaaw(XlRGJvia(4LvqXQbaKWaXfRIFPI1cSSk7QleS(rzvCVVSArqbf8K4KDZ2GchTb((Oiq2qscVTlZUSruHuTiPNIem89B4ybYgySvO(1UTKIg4SbuW92GY6OroEpxMrbIPlPhibRJS)Zz8zxWhbNPquGy6cPAZurhIoGP4hnnnydakvETXNiFTxJttT)Zz0wcaWYpEJFuR2)5mAlbay5hVXJc9UWqesj84idOG)9grpY0yk7Ygrfs1g3oKYqD5NgponTRLouG0xcopBeVB(OqVlmeHucpoYak4FVr0JmnMYUSruHuTXTdPmux(PXPPgauQ8AJvJ4DZtNgBDuWgauQ8AJvJ4DZtNstD8EUmJcetheT0eSocQFTBlPObuqbpPmmHrUmPPgaqcdexrdOGcEs59LYy0(6fhpYHrE8yoz3SnOWrBGVpkcK7Y4x5BdkK0trcg((nCSazdm2ku)A3wsrdC2ak4EBqzD0ihVNlZOaX0L0dKG1r2)5m(Sl4JGZuikqmDHuTzQOdrhWu8JMMgSbaLkV24tKV2RXPP2)5mAlbay5hVXpQv7)CgTLaaS8J34rHExyigKeECKbuW)EJOhzAmLDzJOcPAJBhszOU8tJhNM21shkq6lbNNnI3nFuO3fgIbjHhhzaf8V3i6rMgtzx2iQqQ242HugQl)040udakvETXQr8U5PtJTokydakvETXQr8U5PtPPoEpxMrbIPdIwAcwhb1V2TLu0akOGNugMWixM0udaiHbIRObuqbpP8(szmAF9IJh5WipEmN8dzvuWBh6lHz9fiM1WV5LvKcN4yfzWNv)iwr4D1fcwrPJvmzafmNSB2gu4OnW3hfbYq9RDBjHKYdjrCmAIJUbYGeOU8tIqgzJIPyxz5V8tufqGqUzBqfXRFZ(OijAY8xkVDi9yWKr2Oyk2vw(l)evJGGpUUKQnIbFzgmZ7lLNGJWBKk3wsWIQGmgc5MTbvu857BKenz(lL3oKEmHiKGqyuskZVoEjo5hYAI)hIY6W6h(FiimRIFPI19LyD2iExwBmRUn4VSUawPcgjSopQcyKzTXS62G)Y6cyLkyKWkYGpR(rS6lRpqcpYQJrzTlw9IvrXiBumHewTisb5GUmSkD8Iz1lW(shRbKhXKbZk4yfzWNvXGVeMvau6mokRHGJyDF9IvonWeyfPWjowf)sfRid(Skg8LWfsVSoS(H)hcI1ciMt2nBdkC0g47JIaz86h(FiiK0trg11shkq6lbNNnI3nFuO3fgIwAA6i7)CgphkvGpoppQcyKJhf6DHHicdCm0fTOYqTCKJ3ZLzuGy6GqbjHXwT)Zz8COub(488OkGro(rhponDKJ3ZLzuGy6EeQFTBlPOJrtC0nqgrL9FoJKr2OykJbs)Ihf6DHFegSX5)qodMzs(lkUT5joFuO3LOcsrlKuGbMqAQJ3ZLzuGy6EeQFTBlPOJrtC0nqgrL9FoJKr2Oykl)LFXJc9UWpcd248FiNbZmj)ff328eNpk07subPOfskWatySvYiBumf7k7fYwhfS9FoJgp3Lj(rttdEDjvBeV(jbhCKk3wsWJToAuWgaqcdexrJN7Ye)OPPgauQ8AJpr(AVSgSbaKWaXvKcrbIPlBdk44hDCAQbaLkV2y1iE380PXwhfSbaLkV2iuQ2xKV00GT)Zz045UmXpAAQJ3ZLzuGy6s6bsyCA6O1LuTr86NeCWrQCBjbB1(pNrJN7Ye)Owhz)NZiE9tco4iEDZtigK0uhVNlZOaX0L0dKW4XPP2)5mA8CxM4rHEx4Kciwd2(pNXZHsf4JZZJQag54h1AWRlPAJ41pj4GJu52scMt(HSAjyIviGaqHzTlwtSF5hRIIr2OyIvVGzf7qjwdQWLZhHa)sjRqabGI1j4y1IifKd6YWj7MTbfoAd89rrGCrIZHaqHKEkYi7)CgjJSrXuw(l)Ihf6DHtIenz(lL3oKsthzE9dbHfbswpY86hckVDibrlmon186hcclsqgB1rZMxY8Kt2nBdkC0g47JIa5xxoZHaqHKEkYi7)CgjJSrXuw(l)Ihf6DHtIenz(lL3oKSoYaasyG4kA8CxM4rHEx4KSqcPPgaqcdexrdOGcEs59LYy0(6fhpk07cNKfsyCA6iZRFiiSiqY6rMx)qq5TdjiAHXPPMx)qqyrcYyRoA28sMNCYUzBqHJ2aFFueip)szoeakK0trgz)NZizKnkMYYF5x8OqVlCsKOjZFP82HK1rgaqcdexrJN7Yepk07cNKfsin1aasyG4kAafuWtkVVugJ2xV44rHEx4KSqcJtthzE9dbHfbswpY86hckVDibrlmon186hcclsqgB1rZMxY8Kt(HScHbefwbfRgywT)lROhWGzvClLSckjYSAtS(XemRDHByI1e7x(XQOyKnkM4KDZ2GchTb((OiqwSFxdUmyMj5Vio5hYQLGjwhw)M9rSUawrpGH1bG0pwffJSrXeRGJvXVuXAxSMy)YpwffJSrXeNSB2gu4OnW3hfbY41VzFes6PiKr2Oyk2vw(l)stjJSrXuedK(Lls0BAkzKnkMIEHCUirVPP2)5mk2VRbxgmZK8xu8JA1(pNrYiBumLL)YV4hnnDK9FoJgp3LjEuO3fgIUzBqffF((gjrtM)s5TdjR2)5mA8CxM4hDmNSB2gu4OnW3hfbYIpFF5KDZ2GchTb((Oiq((v2nBdQSSXlskpKez6s5(EFozo5hY6W6h(FiiwNGJ1qaukKQL1FjjmM1pUleSMiasfaoz3SnOWXPlL779fbV(H)hccj9uKGVFrtWHGI2U0ldLbZSlL59Tle4i9G)gfLG5KFiRw0XlR7lXkmyzvCVVSUVeRHa8Y62HeRlGvhgM1FTTK19Lyn0fnRW)Z3guS2ywF7nY6WVM9rSEuO3fM1WVCBuztWSUawd918YAiauZ(iwH)NVnO4KDZ2GchNUuUV3)rrGm(xZ(iKyq2iP86hcAXIeis6PiWGngca1SpkEuO3foPJc9UWIkibjiuGbeoz3SnOWXPlL779Fueihca1SpItMt(HSArxA(sFjmRIFP9Lowhw)W)dbXAremM1fWQnX6htWSUawFsekRFuw3xI1e)rEODxW0XQ9FozfCSUawH)HOSAttWrSAafuWtIt2nBdkCeVIGx)W)dbHKEkY9lAcoeuC7qsm4Qm8rEODxW0fPh83OOeS1rKr2Oyk2v2lKTg8Or2)5mUDijgCvg(ip0Uly6Ihf6DHtcHbog6I(XeIbADezKnkMIDLTb7BAkzKnkMIDLXaPFPPKr2Oykk)LF5Ie9oon1(pNXTdjXGRYWh5H2Dbtx8OqVlCsUzBqfXRFZ(OijAY8xkVDi9ycXaToImYgftXUYYF5xAkzKnkMIyG0VCrIEttjJSrXu0lKZfj6D8400GT)ZzC7qsm4Qm8rEODxW0f)OJtthz)NZOXZDzIF00uO(1UTKIgqbf8KYWeg5Ym2QbaKWaXv0akOGNuEFPmgTVEXXJCyKhZj)qwTemXksb7OBdLyDqSFHSk(Lkw3x6iwBmRfGv3SnuIvSy)crcRoMvPVeRoMvuag32sIvqXkwSFHSkU3xwHeRGJ1jjMowXRBEIzfCSckwDwdYJSIf7xiRyaR7RVSUVeRfjMvSy)cz1VRHsywHa4Jxw95shR7RVSIf7xiRKOr7JWCYUzBqHJ49rrGSd7OBdLYyX(fIedYgjLx)qqlwKarspfjyyWgDyhDBOugl2VWmSh6iO42MNDHWAWUzBqfDyhDBOugl2VWmSh6iOyx5PSr8UwhfmmyJoSJUnukJf7xy(LCzCBZZUqKMcd2Od7OBdLYyX(fMFjxgpk07cNKfgNMcd2Od7OBdLYyX(fMH9qhbfXRBEcXGyfgSrh2r3gkLXI9lmd7HockEuO3fgIbXkmyJoSJUnukJf7xyg2dDeuCBZZUqWj)qwTemHz1IGck4jXApz14S2yw)OScowrg8z1pIvycJCz6cbRwePGCqxgwf37lRweuqbpjw9cMvKbFw9Jy1MKaXSAPjWQJr5KDZ2GchX7JIazdOGcEs59LYy0(6fJKEkYiO(1UTKIgqbf8KYWeg5YynydaiHbIROXZDzIh5WiNMA)NZOXZDzIF0XwD8EUmJcetheT0eSoY(pNrYiBumLL)YV4rHEx4KcmH0u7)CgjJSrXugdK(fpk07cNuGjmonD2iE38rHExyigycCYpK1GAAEe(LvyWIz9xscJz1IifKd6YW6RJzvsymR7RxSAbwXKbZ6rHExDHajSUVeRqPAFr(y1(pNScow3xI1NiFTxSA)NtwBmRUn4VSUawNUuYkyoz1lyw9czwffJSrXeRnMv3g8xwxaRKOr7J4KDZ2GchX7JIazO(1UTKqs5HKiWGnF0d(7JcPAXibQl)KiJS)Zz045UmXJc9UWjzbRJS)Zz8COub(488OkGroEuO3fojlKMgS9FoJNdLkWhNNhvbmYXp6400GT)Zz045UmXpAAQJ3ZLzuGy6GyqsyS1rbB)NZ4ZUGpcotHOaX0fs1MPIoeDatXpAAQJ3ZLzuGy6GyqsyS1r2)5msgzJIPmgi9lEuO3fojeg4yOl60u7)CgjJSrXuw(l)Ihf6DHtcHbog6IEmNSB2gu4iEFueihca1SpcjgKnskV(HGwSibIKEkYrZJWVUTKSU(HG242HuEbz4MskqizDKJMnVK5PvO(1UTKIWGnF0d(7JcPAXJ5KDZ2GchX7JIaz8VM9riXGSrs51pe0IfjqK0troAEe(1TLK11pe0g3oKYlid3usbcjRJC0S5LmpTc1V2TLuegS5JEWFFuivlEmNSB2gu4iEFueiJxsk9lpL(riXGSrs51pe0IfjqK0troAEe(1TLK11pe0g3oKYlid3usbcbToYrZMxY80ku)A3wsryWMp6b)9rHuT4XCYpKvlbtScbcSmRGIvdmRI79f8xwnokAxi4KDZ2GchX7JIa5j4mugmZLV)JqspfXrZMxY8Kt(HSAjyI19LynOkQ2xKpwD7w2lYSckwnWSk(TnVS2ywTPj4iwTisb5GUmCYUzBqHJ49rrG85qPc8X55rvaJms6Pi2)5mA8CxM4hLt(HSAjyI1Gk7c(iywhq7RxmRI79L1bG0pwffJSrXeREbZAI7lX(X6VKegZQeG7cbRoRFmXj7MTbfoI3hfbYuikqmDzBqbJKEkYOr2)5msgzJIPmgi9lEuO3foPatin1(pNrYiBumLL)YV4rHEx4KcmHXwnaGegiUIgp3LjEuO3foPGKG1r2)5mIEDi4GBxM9Z4vBYOFj2Viux(jicjlnH00GVFrtWHGIOxhco42Lz)mE1Mm6xI9lsp4Vrrj4XJttT)Zze96qWb3Um7NXR2Kr)sSFrOU8tjjcKe1jKMAaajmqCfnEUlt8ihgzRJC8EUmJcetxspqcPPq9RDBjfBC2b0yo5hYQLGjwTisb5GUmSkU3xwTiOGcEsS6fmRWGcPxwbqPt81lXAI7lX(Xj7MTbfoI3hfbYgss4TDz2LnIkKQfj9uKGHVFdhlq2aJTc1V2TLu0aNnGcU3guwh549CzgfiMUKEGeSoY(pNXNDbFeCMcrbIPlKQntfDi6aMIF000GnaOu51gFI81Enon1aGsLxBSAeVBE6uAku)A3wsXgNDaLMA)NZOTeaGLF8g)OwT)Zz0wcaWYpEJhf6DHHiKs4XrJEar19lAcoeue96qWb3Um7NXR2Kr)sSFr6b)nkkbp(Xrgqb)7nIEKPXu2LnIkKQnUDiLH6YpnE8yRbB)NZOXZDzIFuRJc2aGsLxBSAeVBE6uAQbaKWaXv0akOGNuEFPmgTVEXXpAAAxlDOaPVeCE2iE38rHExyiAaajmqCfnGck4jL3xkJr7RxC8OqVl8JqW00Uw6qbsFj48Sr8U5Jc9UWqiiuGbKeGiKs4Xrgqb)7nIEKPXu2LnIkKQnUDiLH6YpnEmNSB2gu4iEFuei3LXVY3guiPNIem89B4ybYgySvO(1UTKIg4SbuW92GY6ihVNlZOaX0L0dKG1r2)5m(Sl4JGZuikqmDHuTzQOdrhWu8JMMgSbaLkV24tKV2RXPPgauQ8AJvJ4DZtNstH6x72sk24SdO0u7)CgTLaaS8J34h1Q9FoJ2saaw(XB8OqVlmedscpoA0diQUFrtWHGIOxhco42Lz)mE1Mm6xI9lsp4Vrrj4XpoYak4FVr0JmnMYUSruHuTXTdPmux(PXJhBny7)CgnEUlt8JADuWgauQ8AJvJ4DZtNstnaGegiUIgqbf8KY7lLXO91lo(rtt7APdfi9LGZZgX7Mpk07cdrdaiHbIRObuqbpP8(szmAF9IJhf6DHFecMM21shkq6lbNNnI3nFuO3fgcbHcmGKaedscpoYak4FVr0JmnMYUSruHuTXTdPmux(PXJ5KFiRbv5x72sI1pMGzfuS62TS3MWSUV(YQyVwwxaR2eRyhkbZ6eCSArKcYbDzyfdyDF9L19LqMv)OAzvSJxcMvia(4LvBAcoI19Lc5KDZ2GchX7JIazO(1UTKqs5HKiyhkLNGlB8CxgKa1LFsKGnaGegiUIgp3LjEKdJCAAWq9RDBjfnGck4jLHjmYLXQbaLkV2y1iE380P0u473WXcKnWyo5hYQLGjmRqGarH1EYAxS6fRIIr2OyIvVGzDVMWSUawLDrS2lRFuwf37lRjUVe7hsy1IifKd6YWQxWSIuWo62qjwhe7xiNSB2gu4iEFueip)hYzWmtYFriPNIqgzJIPyxzVq2QJMnVK5Pv7)CgrVoeCWTlZ(z8Qnz0Ve7xeQl)eeHKLMG1rWGn6Wo62qPmwSFHzyp0rqXTnp7crAAWgauQ8AJfzoGeCWJTc1V2TLue7qP8eCzJN7YWj)qwTemXkOO9L1H1VPlLSIEadM1EY6W630LswBCH0lRFuoz3SnOWr8(OiqgV(nDPej9ue7)CgbfTV4mkDgcDBqf)OwT)ZzeV(nDPmE08i8RBljoz3SnOWr8(Oiq24LHKz7)CIKYdjrWRFsWbJKEkI9FoJ41pj4GJhf6DHHOfSoY(pNrYiBumLXaPFXJc9UWjzH0u7)CgjJSrXuw(l)Ihf6DHtYcJT649CzgfiMUKEGe4KDZ2GchX7JIaz8630LsK0trwxs1gXljL(LHVEUrQCBjbBft72fcCedKGm81Z1Q9FoJ41VPlLryG4It(HSM4)HOywDmkR20eCeRweuqbpjw)4UqW6(sSArqbf8Ky1ak4EBqX6cy18sMNS2twTiOGcEsS2ywDZ(DPezwDBWFzDbSAtSAC8Yj7MTbfoI3hfbY41p8)qqiPNIyaqPYRnwnI3npDYku)A3wsrdOGcEszycJCzSAaajmqCfnGck4jL3xkJr7RxC8OqVlmeTG1GHVFdhlq2aJ5KFiRwcMyDy9B6sjRI79Lv8ssPFScF9Cz1lywlaRdRFsWbJewf)sfRfG1H1VPlLS2yw)OiHvKbFw9JyTlwtSF5hRIIr2OycjSIEadRjUVe7hRIFPIv3gaLy9bsGvhJYk4y1Hr9THsSIf7xiRVoM1aYJyYGz9OqVRUqWk4yTXS2fRtzJ4D5KDZ2GchX7JIaz8630LsK0trwxs1gXljL(LHVEUrQCBjbBn41LuTr86NeCWrQCBjbB1(pNr8630LY4rZJWVUTKSoY(pNrYiBumLL)YV4rHEx4KGGwjJSrXuSRS8x(z1(pNr0RdbhC7YSFgVAtg9lX(fH6YpbrizHestT)Zze96qWb3Um7NXR2Kr)sSFrOU8tjjcKSqcwD8EUmJcetxspqcPPWGn6Wo62qPmwSFHzyp0rqXJc9UWjfqstDZ2Gk6Wo62qPmwSFHzyp0rqXUYtzJ4DhBnydaiHbIROXZDzIh5WiZj)qwTemXkgZkOO9Lv0dyWS6fmRW)quwDmkRIFPIvlIuqoOldRGJ19Lyfkv7lYhR2)5K1gZQBd(lRlG1PlLScMtwbhRid(inmRghLvhJYj7MTbfoI3hfbY41p8)qqiPNIy)NZiOO9fNnsYVm0g3Gk(rttT)Zz8zxWhbNPquGy6cPAZurhIoGP4hnn1(pNrJN7Ye)Owhz)NZ45qPc8X55rvaJC8OqVlmeryGJHUOfvgQLJC8EUmJcethekijm2Q9FoJNdLkWhNNhvbmYXpAAAW2)5mEouQaFCEEufWih)Owd2aasyG4kEouQaFCEEufWihpYHronnydakvETrOuTViFJttD8EUmJcetxspqcwjJSrXuSRSxiZj)qwdWHmRlG1q)jX6(sSAt4LvWK1H1pj4Gz1gzwXRBE2fcw7L1pkRp4VnpLiZAxSoaK(XQOyKnkMy1(VSM4(sSFS24Az1Tb)L1fWQnXk6bmgcMt2nBdkCeVpkcKXRF4)HGqspfzDjvBeV(jbhCKk3wsWwd((fnbhckUDijgCvg(ip0Uly6I0d(Buuc26i7)CgXRFsWbh)OPPoEpxMrbIPlPhiHXwT)ZzeV(jbhCeVU5jedI1r2)5msgzJIPmgi9l(rttT)ZzKmYgftz5V8l(rhB1(pNr0RdbhC7YSFgVAtg9lX(fH6YpbrijQtW6idaiHbIROXZDzIhf6DHtkWestdgQFTBlPObuqbpPmmHrUmwnaOu51gRgX7MNonMt(HSAjyI1H1p8)qqS2fRdaPFSkkgzJIjKWkmOq6LvjTS2lROhWWAI7lX(X6O91xwBmRVEbljywTrMvQ3x6yDFjwhw)MUuYQSlIvWX6(sS6y0KEGeyv2fX6eCSoS(H)hcAmsyfgui9YkakDIVEjw9Ivqr7lROhWWQxWSkPL19Ly1TbqjwLDrS(6fSKyDy9tcoyoz3SnOWr8(OiqgV(H)hccj9uKGVFrtWHGIBhsIbxLHpYdT7cMUi9G)gfLGToY(pNr0RdbhC7YSFgVAtg9lX(fH6YpbrijQtin1(pNr0RdbhC7YSFgVAtg9lX(fH6YpbrizHeSUUKQnIxsk9ldF9CJu52scESv7)CgjJSrXugdK(fpk07cNKO2kzKnkMIDLXaPFwd2(pNrqr7loJsNHq3guXpQ1Gxxs1gXRFsWbhPYTLeSvdaiHbIROXZDzIhf6DHtsuBDKbaKWaXv8zxWhbNXO91loEuO3fojrDAAWgauQ8AJpr(AVgZj)qwTemXkeqaOWS2fRj2V8JvrXiBumXQxWSIDOeRbv4Y5JqGFPKviGaqX6eCSArKcYbDz4KDZ2GchX7JIa5IeNdbGcj9uKr2)5msgzJIPS8x(fpk07cNejAY8xkVDiLMoY86hcclcKSEK51peuE7qcIwyCAQ51peewKGm2QJMnVK5PvO(1UTKIyhkLNGlB8Cxgoz3SnOWr8(Oiq(1LZCiauiPNImY(pNrYiBumLL)YV4rHEx4KirtM)s5TdjRbBaqPYRn(e5R9knDK9FoJp7c(i4mfIcetxivBMk6q0bmf)OwnaOu51gFI81EnonDK51peeweiz9iZRFiO82HeeTW40uZRFiiSibjn1(pNrJN7Ye)OJT6OzZlzEAfQFTBlPi2Hs5j4Ygp3LHt2nBdkCeVpkcKNFPmhcafs6PiJS)ZzKmYgftz5V8lEuO3fojs0K5VuE7qYAWgauQ8AJpr(AVsthz)NZ4ZUGpcotHOaX0fs1MPIoeDatXpQvdakvETXNiFTxJtthzE9dbHfbswpY86hckVDibrlmon186hcclsqstT)Zz045UmXp6yRoA28sMNwH6x72skIDOuEcUSXZDz4KFiRwcMyfcdikSckwnWCYUzBqHJ49rrGSy)UgCzWmtYFrCYpKvlbtSoS(n7JyDbSIEadRdaPFSkkgzJIjKWQfrkih0LH1xhZQKWyw3oKyDF9IvNviSZ3xwjrtM)sSkP5Yk4yfusKznX(LFSkkgzJIjwBmRFuoz3SnOWr8(OiqgV(n7JqspfHmYgftXUYYF5xAkzKnkMIyG0VCrIEttjJSrXu0lKZfj6nn1(pNrX(Dn4YGzMK)IIFuR2)5msgzJIPS8x(f)OPPJS)Zz045UmXJc9UWq0nBdQO4Z33ijAY8xkVDiz1(pNrJN7Ye)OJ5KFiRwcMyfc789LvW(sN4gtSk(TnVS2yw7I1bG0pwffJSrXesy1IifKd6YWk4yDbSIEadRj2V8JvrXiBumXj7MTbfoI3hfbYIpFF5KFiRqGUuUV3Nt2nBdkCeVpkcKVFLDZ2GklB8IKYdjrMUuUV3xyfwbba]] )


end