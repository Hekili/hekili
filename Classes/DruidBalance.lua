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


    spec:RegisterPack( "Balance", 20210320, [[davcLeqirWJar1LGkjBIe9jqugLQKtPk1QajPxPqAwqfUfPsQDj0VargMi0Xiv1YabpteLPbvIRbvQTbsIVrcvnoOsQZbcL1rQs18ajUhjyFIihKurlKufpeQOjscvUiiP2iPkLpccvLrccvvNKekRuH4LGqOzkIk3KujXojvQFccvzOIOQLsQK0tfPPsQWvjvITccb(kienwqOYEjL)kQbtCyQwSapMstguxg1Mv0NHIrRkoTuRgec61kuZMIBlODl53adNKooiKwUkphY0v66QQTdL(ou14jHCEqQ1tQsMVc2pYA6RPdTuyFznDdHeHG(jMmiKyu)etwYWfCTw6cTkRLQ62XogwlT8qwlvpUXllRLQ6qBaoSMo0srG)zzT0NDvr6Dibjm9(8dIwqiKqD434Bdk75ZfsOo0cjT0GFBwfR0c0sH9L10nesec6NyYGqIr9tmzjdxWTwQ)3hWPLM2H4ul9PHH5slqlfMrwTu94gVSmjkU73W0i6k(zFirFCnoibcjcb9PrOrW5JxyyKENgrxtIoHHzyssbg)irpShgPr01KGZhVWWWKS(HH3CpjX6igrYciXcT1W51pm8II0i6As0v5qawgMKFvSLri)GMeS(1EGHrK8QJCehKOEm2mA9d9pmmj66Kir9ySr06h6Fy43rAeDnj6elOHjr9yRJ2UWqce557dj9KKEHmej7dtc(duyibQTMwfXrAeDnj6k(yMeCckSGXmj7dtsQAF9IiXjX07AyscbhtY0WkQdmmjV6jjqd(K84WfKTK80lj9scQd)M1lg8rgOjbFVpKOhiE6uhKmkj4KnmAB3qIonnMkKRfhK0lKbtcACR(osJORjrxXhZKecqljq2SX8S5Jd9Uqqgjilx(1aejUQQbAswajbaeIKzJ5zrKakd0rTutJwKMo0sH5P)nRMo00T(A6ql1TBdkTueW4xoG9qTuU8addRPhTvt3qqthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zTuKkBm51pm8IIO1VPBmKKej6tIssErscKSUHRnIw)mGdoYLhyyysggizDdxBeTSX4xg(65g5YdmmmjVjzyGeKkBm51pm8IIO1VPBmKKejqqlfMr2Rv3guAPP8IirNaOMeqrsYgLe89(a(ljWxpxs8cMe89(qs66NbCWK4fmjqyusa7dF4BeRLI1VC5HSwAJYoG1wnDNmnDOLYLhyyyn9OLcu1sr8QL62TbLwkw)ApWWAPyDZN1srQSXKx)WWlkIw)M9XKKej6RLcZi71QBdkT0uErKynSJLjb)dxKKU(n7JjX6fjp9scegLK1pm8Iib)tBFiPrKCSHX61sYeCKSpmjqT10QiMKfqsatI6Xt(ogMeVGjb)tBFiz2gdFKSasSoA1sX6xU8qwlTrzRHDSS2QPBCrthAPC5bggwtpAPUDBqPLgWhIVXDHrlfMr2Rv3guAP6cIjrp8H4BCxyibFVpKGtDcjfRSKaos85Yhj4euybJzs6IeCQtiPyLvl1E9Yx7APVijbsSaSC51gRgZZMNotYWajjqIfamWa8v0ckSGXCEF4msTVErXVkjVjrjjb)5mA9Cx24XHExissIe9XT2QPBCRPdTuU8addRPhTu71lFTRLg8NZO1ZDzJhh6DHijjs0h3KmmqsaaHirjjZgZZMpo07crcuibc4wlfMr2Rv3guAPjpyjbFVpK4KGtDcjfRSKSp(ssJkiBjXjj5)gKFKOEaljGJe8pCrY(WKmBmpljnIepa8xswajCbRL62TbLwQkyBqPTA6gQOPdTuU8addRPhTuGQwkIxTu3UnO0sX6x7bgwlfRB(SwQLBdjVi5fjDT8Pcm(YW5zJ5zZhh6DHirxtI(4MeDnjwaWadWxrRN7Ygpo07crYBsGej6JRtKK3KOajwUnK8IKxK01YNkW4ldNNnMNnFCO3fIeDnj6JBs01KOpesKeDnjwaWadWxrlOWcgZ59HZi1(6ffpo07crYBsGej6JRtKK3KmmqIfamWa8v065USXJd9UqKKejDT8Pcm(YW5zJ5zZhh6DHizyGelayGb4ROfuybJ58(WzKAF9IIhh6DHijjs6A5tfy8LHZZgZZMpo07crIUMe9tKKHbssGelalxETXQX8S5PZAPWmYET62GslfNUX(n(YisW)W7dFK8rDHHeCckSGXmjfapj4BJHe3ya4jbAWNKfqcABJHeRJws2hMeKhYK4HGFTKaMKGtqHfmMhfN6eskwzjX6OfPLI1VC5HSwQfuybJ5mmJGUSARMUv8A6qlLlpWWWA6rlfOQLI4vl1TBdkTuS(1EGH1sX6MpRL(IKeiHHO)wvLHJCOk0h7Mm4GlVSmjddKybadmaFf5qvOp2nzWbxEz54XHExisGcj6dvsKeLKKajwaWadWxrouf6JDtgCWLxwoESddnjVjzyGelalxETXXqFTxAPWmYET62GslvxqmmjlGey24qtY(WK8rogMeWKeCQtiPyLLe8pCrYh1fgsGb)adtcOi5JyTuS(LlpK1sTWzlOG7TbL2QPBCTMo0s5YdmmSME0sHzK9A1TbLwQUGysG6qvOp2nKaX7GlVSmjqireBrKeWtWXK4KGtDcjfRSK8rCulT8qwlLdvH(y3KbhC5LL1sTxV81UwQfamWa8v065USXJd9UqKafsGqIKOKelayGb4ROfuybJ58(WzKAF9IIhh6DHibkKaHejzyGKaacrIssMnMNnFCO3fIeOqsYu8APUDBqPLYHQqFSBYGdU8YYARMUHyA6qlLlpWWWA6rlfMr2Rv3guAP6cIjjf8ngE7cdj6Q)aOjbQGylIKaEcoMeNeCQtiPyLLKpIJAPLhYAPiW3y4D7ct((bqRLAVE5RDTulayGb4RO1ZDzJhh6DHibkKavirjjjqcw)ApWWrlOWcgZzygbDzjzyGelayGb4ROfuybJ58(WzKAF9IIhh6DHibkKavirjjy9R9adhTGclymNHze0LLKHbscaiejkjz2yE28XHExisGcjqa3APUDBqPLIaFJH3Tlm57haT2QPB9tuthAPC5bggwtpAPUDBqPL2fYE)1dmCgI(9A)HzygBBzTu71lFTRLg8NZO1ZDzJhh6DHijjs0h3APLhYAPDHS3F9adNHOFV2FygMX2wwB10T(6RPdTuU8addRPhTu3UnO0s3RRX8QVwkmJSxRUnO0s1XtJiPrK4KC((WhjSXdaNVmj4DOjzbKe6JzsCJHeqrYhXKGwFjzVUgZlIKfqsatIPlgMKVkj479HeCQtiPyLLeVGjbNGclymtIxWK8rmj7dtcekysqgWscOiXctspjjaSpKSxxJ5frIFmjGIKpIjbT(sYEDnMxKwQ96LV21sX6x7bgocQ8hX596AmVKOajqGeLKKaj711yEJleIh7WqNTaGbgGVizyGKxKG1V2dmCeu5pIZ711yEjrbs0NKHbsW6x7bgocQ8hX596AmVKOajjJK3KOKKxKe8NZO1ZDzJFvsggiXcagya(kA9Cx24XHExisgLeiqssKSxxJ5nU6hTaGbgGVIW)Z3guKOKKxKKajwawU8AJvJ5zZtNjzyGKeibRFThy4OfuybJ5mmJGUSK8MeLKKajwawU8AJJH(AVizyGelalxETXQX8S5PZKOKeS(1EGHJwqHfmMZWmc6YsIssSaGbgGVIwqHfmMZ7dNrQ91lk(vjrjjjqIfamWa8v065USXVkjkj5fjVij4pNr2AAveNn)YV4XHExissIe9tKKHbsc(ZzKTMwfXzeW4x84qVlejjrI(jsYBsusscKC)INGddhdCJxwodMz3yY7txyqrU8addtYWajVij4pNXa34LLZGz2nM8(0fguU89FCeTUDmjkqcUjzyGKG)CgdCJxwodMz3yY7txyqz)SEXr062XKOaj4MK3K8MKHbsc(ZzCCxWhdN5qvaE(c5AZCXhMwV44xLK3KmmqsaaHirjjZgZZMpo07crcuibcjsYWajy9R9adhbv(J48EDnMxsuGKe1wnDRpe00HwkxEGHH10JwQ96LV21sX6x7bgocQ8hX596AmVKKGcKabsusscKSxxJ5nU6hp2HHoBbadmaFrYWajy9R9adhbv(J48EDnMxsuGeiqIssErsWFoJwp3Ln(vjzyGelayGb4RO1ZDzJhh6DHizusGajjrYEDnM34cHOfamWa8ve(F(2GIeLK8IKeiXcWYLxBSAmpBE6mjddKKajy9R9adhTGclymNHze0LLK3KOKKeiXcWYLxBCm0x7fjddKyby5YRnwnMNnpDMeLKG1V2dmC0ckSGXCgMrqxwsusIfamWa8v0ckSGXCEF4msTVErXVkjkjjbsSaGbgGVIwp3Ln(vjrjjVi5fjb)5mYwtRI4S5x(fpo07crssKOFIKmmqsWFoJS10QioJag)Ihh6DHijjs0prsEtIsssGK7x8eCy4yGB8YYzWm7gtEF6cdkYLhyyysggi5fjb)5mg4gVSCgmZUXK3NUWGYLV)JJO1TJjrbsWnjddKe8NZyGB8YYzWm7gtEF6cdk7N1loIw3oMefib3K8MK3K8MKHbsc(ZzCCxWhdN5qvaE(c5AZCXhMwV44xLKHbscaiejkjz2yE28XHExisGcjqirsggibRFThy4iOYFeN3RRX8sIcKKOwQB3guAP711yEHG2QPB9tMMo0s5YdmmSME0sD72Gsl9J4CVCislfMr2Rv3guAP6cIrK4gdjG9HpsafjFetsVCiIeqrIfwl1E9Yx7APb)5mA9Cx24xLKHbsSaSC51gRgZZMNotIssW6x7bgoAbfwWyodZiOlljkjXcagya(kAbfwWyoVpCgP2xVO4xLeLKKajwaWadWxrRN7Yg)QKOKKxK8IKG)CgzRPvrC28l)Ihh6DHijjs0prsggij4pNr2AAveNraJFXJd9UqKKej6NijVjrjjjqY9lEcomCmWnEz5myMDJjVpDHbf5YdmmmjddKC)INGddhdCJxwodMz3yY7txyqrU8addtIssErsWFoJbUXllNbZSBm59PlmOC57)4iAD7yssIKKrYWajb)5mg4gVSCgmZUXK3NUWGY(z9IJO1TJjjjssgjVj5njddKe8NZ44UGpgoZHQa88fY1M5IpmTEXXVkjddKeaqisusYSX8S5Jd9UqKafsGqIARMU1hx00HwkxEGHH10JwkmJSxRUnO0svCSTHzsC72GIetJwscCedtcOib1733guqYWyAKwQB3guAP3VYUDBqLnnA1sr712vt36RLAVE5RDTuS(1EGHJnk7awl10OnxEiRL6awB10T(4wthAPC5bggwtpAP2Rx(Axl9(fpbhgog4gVSCgmZUXK3NUWGIme93QQmSwkAV2UA6wFTu3UnO0sVFLD72GkBA0QLAA0MlpK1sda(QTA6wFOIMo0s5YdmmSME0sD72Gsl9(v2TBdQSPrRwQPrBU8qwlfTAR2QLga8vthA6wFnDOLYLhyyyn9OL62TbLw65y5c8r55XLEbTwkmJSxRUnO0s1Bhx6f0KGV3hsWPoHKIvwTu71lFTRLg8NZO1ZDzJhh6DHijjs0h3ARMUHGMo0s5YdmmSME0sbQAPiE1sD72GslfRFThyyTuSU5ZAPjqsWFoJbUXllNbZSBm59PlmOC57)44xLeLKKajb)5mg4gVSCgmZUXK3NUWGY(z9IJFvTuygzVwDBqPLIZh2ogrspjzFys0dqN6Ge71ljb)5KKgrsbws(QKmbhjgF5JKpI1sX6xU8qwl1E9wG9RQTA6ozA6qlLlpWWWA6rl1TBdkTuh2v3glNr49lul1cT1W51pm8I00T(AP2Rx(Axln4pNXa34LLZGz2nM8(0fguU89FCeTUDmjqHeCHeLKe8NZyGB8YYzWm7gtEF6cdk7N1loIw3oMeOqcUqIssErscKad2Od7QBJLZi8(fMH9qhdh32oUlmKOKKeiXTBdQOd7QBJLZi8(fMH9qhdh7kpnnMNLeLK8IKeibgSrh2v3glNr49lm)WUjUTDCxyizyGeyWgDyxDBSCgH3VW8d7M4XHExissIKKrYBsggibgSrh2v3glNr49lmd7HogoIw3oMeOqsYirjjWGn6WU62y5mcVFHzyp0XWXJd9UqKafsWnjkjbgSrh2v3glNr49lmd7HogoUTDCxyi5TwkmJSxRUnO0s1fetIoHD1TXYKKI3VqsW)Wfj(sIHris2hVibxirpaDQdsqRBhJiXlyswajhppg9qItcuuacKGw3oMehrIXxMehrIkaH6adtc4iz7qMKEjbbiPxs87ASmIeic)OLeFU8rItsYgLe062XKWksTpgPTA6gx00HwkxEGHH10JwQB3guAPwqHfmMZ7dNrQ91lslfMr2Rv3guAP6cIjbNGclymtc(EFibN6eskwzjb)dxKOcqOoWWK4fmjG9Hp8nIjbFVpK4KOhGo1bjb)5Ke8pCrcmJGUSDHrl1E9Yx7APVibRFThy4OfuybJ5mmJGUSKOKKeiXcagya(kA9Cx24Xom0KmmqsWFoJwp3Ln(vj5njkj5fjb)5mg4gVSCgmZUXK3NUWGYLV)JJO1TJjrbsWnjddKe8NZyGB8YYzWm7gtEF6cdk7N1loIw3oMefib3K8MKHbscaiejkjz2yE28XHExisGcj6NO2QPBCRPdTuU8addRPhTu3UnO0sN)d6myMzZVyTuygzVwDBqPLQ3aqnjoIK9Hjz2hAjbJfMKUizFysCs0dqN6Ge8DbdWtc4ibFVpKSpmjqeH(AVij4pNKaosW37djoj46rrSLeDc7QBJLjjfVFHK4fmj49EjzcosWPoHKIvws6jj9scEqTKeWK8vjXX4DrsapbhtY(WKyHjPrKm7QrpmSwQ96LV21sFrYlsc(ZzmWnEz5myMDJjVpDHbLlF)hhrRBhtssKGlKmmqsWFoJbUXllNbZSBm59PlmOSFwV4iAD7yssIeCHK3KOKKxKaF)gowGSfgrYWajwaWadWxrRN7Ygpo07crssKG7ejzyGKxKyby5YRnwnMNnpDMeLKybadmaFfTGclymN3hoJu7Rxu84qVlejjrcUtKK3K8MK3KmmqYlsGbB0HD1TXYzeE)cZWEOJHJhh6DHijjsW1KOKelayGb4RO1ZDzJhh6DHijjs0prsusIfGLlV2yX2dyahmjVjzyGKaacrIss6A5tfy8LHZZgZZMpo07crcuibxtYWajViXcWYLxBCm0x7fjkjj4pNXXDbFmCMdvb45lKRn(vj5T2QPBOIMo0s5YdmmSME0sD72Gsl16LLn5G)CQLAVE5RDT0xKe8NZyGB8YYzWm7gtEF6cdkx((poECO3fIKKibxI4MKHbsc(ZzmWnEz5myMDJjVpDHbL9Z6fhpo07crssKGlrCtYBsusYlsSaGbgGVIwp3LnECO3fIKKirXtYWajViXcagya(kYHQa88LdafC84qVlejjrIINeLKKajb)5moUl4JHZCOkapFHCTzU4dtRxC8RsIssSaSC51ghd91ErYBsEtIssC0EUjRcWZhjjPajjlrT0G)CMlpK1srRFgWbRLcZi71QBdkTuC6LLnKKU(zahmj479HeNKIXtIEa6uhKe8Nts8cMeCQtiPyLLKgvq2sIha(ljlGKaMKpIH1wnDR410HwkxEGHH10JwQB3guAPO1VPBmAPWmYET62GslvX9dvjjD9d9pmmIe89(qItIEa6uhKe8Ntsc(ljfyjb)dxKOcaMUWqYeCKGtDcjfRSKaosGi2f8XWKKQ2xViTu71lFTRLUUHRnIw2y8ldF9CJC5bggMeLKG4D7cdkIagqg(65sIssc(ZzeT(nDJjcdWxARMUX1A6qlLlpWWWA6rl1TBdkTu06h6FyyTuygzVwDBqPLQ4(HQKKU(H(hggrc(EFizFysca(ssWFojj4VKuGLe8pCrIkay6cdjtWrI1jbCKWHQa88rsaOG1sTxV81UwAcKG1V2dmC0E9wG9RsIssErIfGLlV2y1yE280zsggiXcagya(kA9Cx24XHExissIefpjddKKajy9R9adhTWzlOG7TbfjkjjbsSaSC51ghd91ErYWajViXcagya(kYHQa88LdafC84qVlejjrIINeLKKajb)5moUl4JHZCOkapFHCTzU4dtRxC8RsIssSaSC51ghd91ErYBsEtIssErscKad248FqNbZmB(fh32oUlmKmmqscKybadmaFfTEUlB8yhgAsggijbsSaGbgGVIwqHfmMZ7dNrQ91lkESddnjV1wnDdX00HwkxEGHH10JwQB3guAPO1p0)WWAPWmYET62GslvX9dvjjD9d9pmmIKaEcoMeCckSGXSwQ96LV21sFrIfamWa8v0ckSGXCEF4msTVErXJd9UqKafsWnjkjjbsGVFdhlq2cJirjjVibRFThy4OfuybJ5mmJGUSKmmqIfamWa8v065USXJd9UqKafsWnjVjrjjy9R9adhTWzlOG7TbfjVjrjjjqcmyJZ)bDgmZS5xCCB74UWqIssSaSC51gRgZZMNotIsssGe473WXcKTWisuscBnTkIJDL9cATvt36NOMo0s5YdmmSME0sbQAPiE1sD72GslfRFThyyTuSU5ZAPVij4pNXZXYf4JYZJl9c64XHExissIeCtYWajjqsWFoJNJLlWhLNhx6f0XVkjVjrjjVij4pNXXDbFmCMdvb45lKRnZfFyA9IJhh6DHibkKGXchdDfrYBsusYlsc(ZzKTMwfXzeW4x84qVlejjrcglCm0vejddKe8NZiBnTkIZMF5x84qVlejjrcglCm0vejV1sHzK9A1TbLwQIduq2scmyjb(FDHHK9HjHlysats0vDSCb(is0Bhx6f04Ge4)1fgsg3f8XWKWHQa88fY1sc4iPls2hMeJJwsWyHjbmjXlsGARPvrSwkw)YLhYAPWGnFme93hhY1I0wnDRV(A6qlLlpWWWA6rl1TBdkTu0VM9XAP2Rx(Axl945XOhpWWKOKK1pm8g3oKZlid3mjjrI(qfsusIRMTpSDmjkjbRFThy4imyZhdr)9XHCTiTul0wdNx)WWlst36RTA6wFiOPdTuU8addRPhTu3UnO0sdbGA2hRLAVE5RDT0JNhJE8adtIssw)WWBC7qoVGmCZKKej6NSiUjrjjUA2(W2XKOKeS(1EGHJWGnFme93hhY1I0sTqBnCE9ddVinDRV2QPB9tMMo0s5YdmmSME0sD72GslfTSX4xEA8J1sTxV81Uw6XZJrpEGHjrjjRFy4nUDiNxqgUzssIe9HkKmkjhh6DHirjjUA2(W2XKOKeS(1EGHJWGnFme93hhY1I0sTqBnCE9ddVinDRV2QPB9XfnDOLYLhyyyn9OL62TbLw6eCwodM5Y3)XAPWmYET62GslvVb0njGIelmj479b8xsSUQAxy0sTxV81UwQRMTpSDS2QPB9XTMo0s5YdmmSME0sD72GslLdvb45lhakyTuygzVwDBqPLc1HQa88rIEafmj4F4Iepa8xswajCT8rItsX4jrpaDQdsW3fmapjEbtcYXYKmbhj4uNqsXkRwQ96LV21sFrcBnTkIJMF5xUyfTKmmqcBnTkIJiGXVCXkAjzyGe2AAveh9c6CXkAjzyGKG)CgdCJxwodMz3yY7txyq5Y3)XXJd9UqKKej4se3KmmqsWFoJbUXllNbZSBm59PlmOSFwV44XHExissIeCjIBsggiXr75MSkapFKKejqSejrjjwaWadWxrRN7Ygp2HHMeLKKajW3VHJfiBHrK8MeLK8IelayGb4RO1ZDzJhh6DHijjsswIKmmqIfamWa8v065USXJDyOj5njddKeaqisussxlFQaJVmCE2yE28XHExisGcj6NO2QPB9HkA6qlLlpWWWA6rl1TBdkT05)GodMz28lwlfMr2Rv3guAP6nautY1yEwsc4j4ys(OUWqco1PwQ96LV21sTaGbgGVIwp3LnESddnjkjbRFThy4OfoBbfCVnOirjjViXr75MSkapFKKejqSejrjjjqIfGLlV2y1yE280zsggiXcWYLxBSAmpBE6mjkjXr75MSkapFKafsWLej5njkj5fjjqIfGLlV2y1yE280zsggiXcagya(kAbfwWyoVpCgP2xVO4Xom0K8MeLKKajW3VHJfiBHrARMU1xXRPdTuU8addRPhTu3UnO0sTSHrB7MSBAmvixRwkmJSxRUnO0sXPoHKIvwsW)Wfj(scelXrjrNOKNKxGZaWZhj7JxKGljsIorjpj479HeCckSGX8BsW37d4VKyaOUWqY2HmjDrIEmaaS5Jws8cMetxmjFvsW37dj4euybJzs6jj9scEhrcmJGUSmSwQ96LV21stGe473WXcKTWisuscw)ApWWrlC2ck4EBqrIssErYlsC0EUjRcWZhjjrcelrsusYlsc(ZzCCxWhdN5qvaE(c5AZCXhMwV44xLKHbssGelalxETXXqFTxK8MKHbsc(ZzmWaaWMpAJFvsussWFoJbgaa28rB84qVlejqHeiKijJsYlsSGc(3Bu9yBJ4SBAmvixBC7qoJ1nFMK3K8MKHbscaiejkjPRLpvGXxgopBmpB(4qVlejqHeiKijJsYlsSGc(3Bu9yBJ4SBAmvixBC7qoJ1nFMK3KmmqIfGLlV2y1yE280zsEtIssErscKyby5YRnwnMNnpDMKHbsErIJ2ZnzvaE(ibkKGljsYWajWGno)h0zWmZMFXXTTJ7cdjVjrjjVibRFThy4OfuybJ5mmJGUSKmmqIfamWa8v0ckSGXCEF4msTVErXJDyOj5njV1wnDRpUwthAPC5bggwtpAP2Rx(AxlnbsGVFdhlq2cJirjjy9R9adhTWzlOG7Tbfjkj5fjViXr75MSkapFKKejqSejrjjVij4pNXXDbFmCMdvb45lKRnZfFyA9IJFvsggijbsSaSC51ghd91ErYBsggij4pNXadaaB(On(vjrjjb)5mgyaayZhTXJd9UqKafsswIKmkjViXck4FVr1JTnIZUPXuHCTXTd5mw38zsEtYBsggijaGqKOKKUw(ubgFz48SX8S5Jd9UqKafsswIKmkjViXck4FVr1JTnIZUPXuHCTXTd5mw38zsEtYWajwawU8AJvJ5zZtNj5njkj5fjjqIfGLlV2y1yE280zsggi5fjoAp3Kvb45JeOqcUKijddKad248FqNbZmB(fh32oUlmK8MeLK8IeS(1EGHJwqHfmMZWmc6YsYWajwaWadWxrlOWcgZ59HZi1(6ffp2HHMK3K8wl1TBdkT0US(v(2GsB10T(qmnDOLYLhyyyn9OLcu1sr8QL62TbLwkw)ApWWAPyDZN1szRPvrCSRS5x(rcuLeCnjqIe3UnOIO1VzFCKveB)lN3oKjzussGe2AAveh7kB(LFKavj5fjqfsgLK1nCTre4BYGzEF48eCmAJC5bggMeOkjjJK3KajsC72GkI)89jYkIT)LZBhYKmkjjgHajqIeKkBm5hhTSwkmJSxRUnO0sHA02H(YisEa4jj8BFirNOKNe)ysW4DXWKOYhji2ckyTuS(LlpK1sDKAYZxkB1wnDdHe10HwkxEGHH10JwQB3guAPO1p0)WWAPWmYET62GslvX9dvjjD9d9pmmIe8pCrY(WKmBmpljnIepa8xswajCbJdsMhx6f0K0is8aWFjzbKWfmoibAWNe)ys8LeiwIJsIorjpjDrIxKa1wtRIyCqco1jKuSYsIXrlIeVa7dFKGRhfXwejGJeObFsWd(gysay5Z6QKecoMK9XlsOb9tKeDIsEsW)Wfjqd(KGh8nWfKTKKU(H(hgMKcGxl1E9Yx7APVijaGqKOKKUw(ubgFz48SX8S5Jd9UqKafsWfsggi5fjb)5mEowUaFuEECPxqhpo07crcuibJfog6kIeOkjwUnK8IehTNBYQa88rcKijzjsYBsussWFoJNJLlWhLNhx6f0XVkjVj5njddK8IehTNBYQa88rYOKG1V2dmC0rQjpFPSLeOkjb)5mYwtRI4mcy8lECO3fIKrjbgSX5)GodMz28loUTDmkFCO3fjqvsGqe3KKej6RFIKmmqIJ2ZnzvaE(izusW6x7bgo6i1KNVu2scuLKG)CgzRPvrC28l)Ihh6DHizusGbBC(pOZGzMn)IJBBhJYhh6DrcuLeieXnjjrI(6NijVjrjjS10Qio2v2lOjrjjVijbsc(Zz065USXVkjddKKajRB4AJO1pd4GJC5bggMK3KOKKxK8IKeiXcagya(kA9Cx24xLKHbsSaSC51ghd91ErIsssGelayGb4RihQcWZxoauWXVkjVjzyGelalxETXQX8S5PZK8MeLK8IKeiXcWYLxBelx7d0hjddKKajb)5mA9Cx24xLKHbsC0EUjRcWZhjjrcelrsEtYWajVizDdxBeT(zahCKlpWWWKOKKG)CgTEUlB8RsIssErsWFoJO1pd4GJO1TJjbkKKmsggiXr75MSkapFKKejqSej5njVjzyGKG)CgTEUlB8RsIsssGKG)CgphlxGpkppU0lOJFvsusscKSUHRnIw)mGdoYLhyyyTvt3qqFnDOLYLhyyyn9OL62TbLwAX4ZHaqPLcZi71QBdkTuDbXKORaafIKUij5(LFKa1wtRIys8cMeKJLjbIF3mhvV9ngs0vaGIKj4ibN6eskwz1sTxV81Uw6lsc(ZzKTMwfXzZV8lECO3fIKKiHveB)lN3oKjzyGKxKyF8ddJirbsGajkj5y7JFy482HmjqHeCtYBsggiX(4hggrIcKKmsEtIssC1S9HTJ1wnDdbiOPdTuU8addRPhTu71lFTRL(IKG)CgzRPvrC28l)Ihh6DHijjsyfX2)Y5TdzsusYlsSaGbgGVIwp3LnECO3fIKKib3jsYWajwaWadWxrlOWcgZ59HZi1(6ffpo07crssKG7ej5njddK8Ie7JFyyejkqceirjjhBF8ddN3oKjbkKGBsEtYWaj2h)WWisuGKKrYBsusIRMTpSDSwQB3guAPpUzMdbGsB10nesMMo0s5YdmmSME0sTxV81Uw6lsc(ZzKTMwfXzZV8lECO3fIKKiHveB)lN3oKjrjjViXcagya(kA9Cx24XHExissIeCNijddKybadmaFfTGclymN3hoJu7Rxu84qVlejjrcUtKK3KmmqYlsSp(HHrKOajqGeLKCS9XpmCE7qMeOqcUj5njddKyF8ddJirbssgjVjrjjUA2(W2XAPUDBqPLo)gtoeakTvt3qax00HwkxEGHH10JwkmJSxRUnO0sHibqnjGIelSwQB3guAP497AWLbZmB(fRTA6gc4wthAPC5bggwtpAPUDBqPLIw)M9XAPWmYET62GslvxqmjPRFZ(yswajQhWsskW4hjqT10QiMeWrc(hUiPlsaLbAssUF5hjqT10QiMeVGj5JysGibqnjQhWIiPNK0fjj3V8JeO2AAveRLAVE5RDTu2AAveh7kB(LFKmmqcBnTkIJiGXVCXkAjzyGe2AAveh9c6CXkAjzyGKG)CgX731GldMz28lo(vjrjjb)5mYwtRI4S5x(f)QKmmqYlsc(Zz065USXJd9UqKafsC72GkI)89jYkIT)LZBhYKOKKG)CgTEUlB8RsYBTvt3qaQOPdTu3UnO0sXF((OLYLhyyyn9OTA6gckEnDOLYLhyyyn9OL62TbLw69RSB3guztJwTutJ2C5HSw60nM95(AR2QL6awthA6wFnDOLYLhyyyn9OLcu1sr8QL62TbLwkw)ApWWAPyDZN1sFrsWFoJBhY4bxLHp2dd6cMV4XHExisGcjySWXqxrKmkjjg1NKHbsc(ZzC7qgp4Qm8XEyqxW8fpo07crcuiXTBdQiA9B2hhzfX2)Y5TdzsgLKeJ6tIssErcBnTkIJDLn)YpsggiHTMwfXreW4xUyfTKmmqcBnTkIJEbDUyfTK8MK3KOKKG)Cg3oKXdUkdFShg0fmFXVkjkj5(fpbhgoUDiJhCvg(ypmOly(Ime93QQmSwkmJSxRUnO0sXPBSFJVmIe8p8(Whj7dtII7yp06R9Hpsc(Zjj4BJHKPBmKaMtsW37txKSpmjfROLeRJwTuS(LlpK1sHp2dZ4BJjpDJjdMtTvt3qqthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zT0eiHTMwfXXUYiGXpsusYlsqQSXKx)WWlkIw)M9XKKej4MeLKSUHRnIaFtgmZ7dNNGJrBKlpWWWKmmqcsLnM86hgErr063SpMKKirXtYBTuygzVwDBqPLIt3y)gFzej4F49Hpssx)q)ddtsJibp42hsSoA7cdjaS8rs663SpMKUij5(LFKa1wtRIyTuS(LlpK1sBmf44mA9d9pmS2QP7KPPdTuU8addRPhTu3UnO0sTGclymN3hoJu7RxKwkmJSxRUnO0s1fetcobfwWyMe8pCrIVKyyeIK9XlsWDIKOtuYtIxWKy6Ij5Rsc(EFibN6eskwz1sTxV81Uw6lsW6x7bgoAbfwWyodZiOlljkjjbsSaGbgGVIwp3LnESddnjddKe8NZO1ZDzJFvsEtIssErIJ2ZnzvaE(ibkKG7ejzyGeS(1EGHJnMcCCgT(H(hgMK3KOKKxKe8NZiBnTkIZMF5x84qVlejjrcuHKHbsc(ZzKTMwfXzeW4x84qVlejjrcuHK3KOKKxKKaj3V4j4WWXa34LLZGz2nM8(0fguKlpWWWKmmqsWFoJbUXllNbZSBm59PlmOC57)4iAD7yssIKKrYWajb)5mg4gVSCgmZUXK3NUWGY(z9IJO1TJjjjssgjVjzyGKaacrIssMnMNnFCO3fIeOqI(jQTA6gx00HwkxEGHH10JwQB3guAPNJLlWhLNhx6f0APWmYET62Gslvxqmj6TJl9cAsW37dj4uNqsXkRwQ96LV21sd(Zz065USXJd9UqKKej6JBTvt34wthAPC5bggwtpAPUDBqPLI(1Spwl1cT1W51pm8I00T(AP2Rx(Axl9fjhppg94bgMKHbsc(ZzKTMwfXzeW4x84qVlejqHKKrIssyRPvrCSRmcy8JeLKCCO3fIeOqI(4cjkjzDdxBeb(MmyM3hopbhJ2ixEGHHj5njkjz9ddVXTd58cYWntssKOpUqIUMeKkBm51pm8Iizusoo07crIssErcBnTkIJDL9cAsggi54qVlejqHemw4yORisERLcZi71QBdkTuDbXKK(RzFmjDrIQxWCyBjbuK4f07txyizF8LetJLrKOpUGylIeVGjXWiej479HKqWXKS(HHxejEbtIVKSpmjCbtcysItskW4hjqT10QiMeFjrFCHeeBrKaosmmcrYXHExDHHehrYciPaljpo2UWqYci545XOhsG)xxyij5(LFKa1wtRIyTvt3qfnDOLYLhyyyn9OL62TbLwkA9B6gJwkmJSxRUnO0sHiYSkjFvssx)MUXqIVK4gdjBhYis(LHris(OUWqsYbT1phrIxWK0ljnIepa8xswajQhWsc4iXWlj7dtcsLTTBiXTBdksmDXKeWgaEsE8c2WKO4o2dd6cMpsafjqGK1pm8I0sTxV81Uw6lsc(ZzeT(nDJjE88y0JhyysusYlsqQSXKx)WWlkIw)MUXqcuijzKmmqscKC)INGddh3oKXdUkdFShg0fmFrgI(BvvgMK3KmmqY6gU2ic8nzWmVpCEcogTrU8addtIssc(ZzKTMwfXzeW4x84qVlejqHKKrIssyRPvrCSRmcy8JeLKe8NZiA9B6gt84qVlejqHefpjkjbPYgtE9ddVOiA9B6gdjjPaj4cjVjrjjVijbsUFXtWHHJgOT(5O80W82fMmgthQI4idr)TQkdtYWajBhYKGRibxWnjjrsWFoJO1VPBmXJd9UqKmkjqGK3KOKK1pm8g3oKZlid3mjjrcU1wnDR410HwkxEGHH10JwQB3guAPO1VPBmAPWmYET62GslfIS3hsuCh7HbDbZhjFets6630ngswajJzwLKVkj7dtsWFojjaAsCdcqYh1fgssx)MUXqcOib3KGylOGrKaosmmcrYXHExDHrl1E9Yx7AP3V4j4WWXTdz8GRYWh7HbDbZxKHO)wvLHjrjjiv2yYRFy4ffrRFt3yijjfijzKOKKxKKajb)5mUDiJhCvg(ypmOly(IFvsussWFoJO1VPBmXJNhJE8adtYWajVibRFThy4i8XEygFBm5PBmzWCsIssErsWFoJO1VPBmXJd9UqKafssgjddKGuzJjV(HHxueT(nDJHKKibcKOKK1nCTr0YgJFz4RNBKlpWWWKOKKG)CgrRFt3yIhh6DHibkKGBsEtYBsERTA6gxRPdTuU8addRPhTuGQwkIxTu3UnO0sX6x7bgwlfRB(SwQJ2ZnzvaE(ijjsW1jsIUMKxKOFIKavjj4pNXTdz8GRYWh7HbDbZxeTUDmjVjrxtYlsc(ZzeT(nDJjECO3fIeOkjjJeircsLnM8JJwMK3KORj5fjWGno)h0zWmZMFXXJd9UqKavjb3K8MeLKe8NZiA9B6gt8RQLcZi71QBdkTuC6g734lJib)dVp8rIts66h6Fyys(iMe8TXqI1)iMK01VPBmKSasMUXqcyoXbjEbtYhXKKU(H(hgMKfqYyMvjrXDShg0fmFKGw3oMKVQwkw)YLhYAPO1VPBmz8GAZt3yYG5uB10netthAPC5bggwtpAPUDBqPLIw)q)ddRLcZi71QBdkTuDbXKKU(H(hgMe89(qII7ypmOly(izbKmMzvs(QKSpmjb)5Ke89(a(ljgaQlmKKU(nDJHKV62HmjEbtYhXKKU(H(hgMeqrcUmkj6bOtDqcAD7yej)ABdj4cjRFy4fPLAVE5RDTuS(1EGHJWh7Hz8TXKNUXKbZjjkjbRFThy4iA9B6gtgpO280nMmyojrjjjqcw)ApWWXgtbooJw)q)ddtYWajVij4pNXa34LLZGz2nM8(0fguU89FCeTUDmjjrsYizyGKG)CgdCJxwodMz3yY7txyqz)SEXr062XKKejjJK3KOKeKkBm51pm8IIO1VPBmKafsWfsuscw)ApWWr0630nMmEqT5PBmzWCQTA6w)e10HwkxEGHH10JwQB3guAPoSRUnwoJW7xOwQfARHZRFy4fPPB91sTxV81UwAcKSTDCxyirjjjqIB3gurh2v3glNr49lmd7Hogo2vEAAmpljddKad2Od7QBJLZi8(fMH9qhdhrRBhtcuijzKOKeyWgDyxDBSCgH3VWmSh6y44XHExisGcjjtlfMr2Rv3guAP6cIjbH3Vqsqas2hFjbAWNem8ssORis(QBhYKeanjFuxyiPxsCejgFzsCejQaeQdmmjGIedJqKSpErsYibTUDmIeWrceHF0sc(hUijzJscAD7yejSIu7J1wnDRV(A6qlLlpWWWA6rl1TBdkT0qaOM9XAPwOTgoV(HHxKMU1xl1E9Yx7APhppg94bgMeLKS(HH342HCEbz4MjjjsErYls0hxizusErcsLnM86hgErr063SpMeOkjqGeOkjb)5mYwtRI4S5x(f)QK8MK3Kmkjhh6DHi5njqIKxKOpjJsY6gU24IVRCiauOixEGHHj5njkj5fjwaWadWxrRN7Ygp2HHMeLKKajW3VHJfiBHrKOKKxKG1V2dmC0ckSGXCgMrqxwsggiXcagya(kAbfwWyoVpCgP2xVO4Xom0KmmqscKyby5YRnwnMNnpDMK3KmmqcsLnM86hgErr063SpMeOqYlsErcuHeDnjVij4pNr2AAveNn)YV4xLeOkjqGK3K8MeOkjVirFsgLK1nCTXfFx5qaOqrU8addtYBsEtIsssGe2AAvehraJF5Iv0sYWajViHTMwfXXUYiGXpsggi5fjS10Qio2voaSpKmmqcBnTkIJDLn)YpsEtIsssGK1nCTre4BYGzEF48eCmAJC5bggMKHbsc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZKKKcKabCNijVjrjjVibPYgtE9ddVOiA9B2htcuir)ejbQsYls0NKrjzDdxBCX3voeakuKlpWWWK8MK3KOKehTNBYQa88rssKG7ejrxtsWFoJO1VPBmXJd9UqKavjbQqYBsusYlssGKG)Cgh3f8XWzoufGNVqU2mx8HP1lo(vjzyGe2AAveh7kJag)izyGKeiXcWYLxBCm0x7fjV1sHzK9A1TbLwQUkppg9qIUcauZ(ys6jj4uNqsXkljnIKJDyOXbj7dFmj(XKyyeIK9XlsWnjRFy4frsxKKC)YpsGARPvrmj479HKuWQ3WbjggHizF8Ie9tKeW(Wh(gXK0fjEbnjqT10QiMeWrYxLKfqcUjz9ddVisc4j4ysCssUF5hjqT10QiosIIduq2sYXZJrpKa)VUWqceXUGpgMeOoufGNVqUws(LHris6IKuGXpsGARPvrS2QPB9HGMo0s5YdmmSME0sD72GslDcolNbZC57)yTuygzVwDBqPLQliMe9gq3KaksSWKGV3hWFjX6QQDHrl1E9Yx7APUA2(W2XARMU1pzA6qlLlpWWWA6rl1TBdkTulBy02Uj7MgtfY1QLcZi71QBdkTuDbXKGtDcjfRSKaksSWK8ldJqK4fmjMUys6LKVkj479HeCckSGXSwQ96LV21stGe473WXcKTWisuscw)ApWWrlC2ck4EBqrIssErsWFoJO1VPBmXVkjddK4O9CtwfGNpssIeCNijVjrjjVijbsc(ZzebmOTTC8RsIsssGKG)CgTEUlB8RsIssErscKyby5YRnwnMNnpDMKHbsSaGbgGVIwqHfmMZ7dNrQ91lk(vjrjjoAp3Kvb45JeOqcUtKK3KOKK1pm8g3oKZlid3mjjrI(4MKrjXck4FVr1JTnIZUPXuHCTXTd5mw38zsggijaGqKOKKUw(ubgFz48SX8S5Jd9UqKafsGqIKmkjwqb)7nQESTrC2nnMkKRnUDiNX6MptYBTvt36JlA6qlLlpWWWA6rl1E9Yx7APjqc89B4ybYwyejkjbRFThy4OfoBbfCVnOirjjVij4pNr0630nM4xLKHbsC0EUjRcWZhjjrcUtKK3KOKKxKKajb)5mIag02wo(vjrjjjqsWFoJwp3Ln(vjrjjVijbsSaSC51gRgZZMNotYWajwaWadWxrlOWcgZ59HZi1(6ff)QKOKehTNBYQa88rcuib3jsYBsusY6hgEJBhY5fKHBMKKibcjsYOKybf8V3O6X2gXz30yQqU242HCgRB(mjddKeaqisussxlFQaJVmCE2yE28XHExisGcjjlrsgLelOG)9gvp22io7MgtfY1g3oKZyDZNj5TwQB3guAPDz9R8TbL2QPB9XTMo0s5YdmmSME0sD72GslLdvb45lhakyTuygzVwDBqPLQliMeOoufGNps0dOGjbuKyHjbFVpKKU(nDJHKVkjEbtcYXYKmbhjj)3G8JeVGjbN6eskwz1sTxV81UwAaaHirjjDT8Pcm(YW5zJ5zZhh6DHibkKOpUjzyGKxKe8NZO61HGdUDt2pRxTnR(ni)IyDZNjbkKabCNijddKe8NZO61HGdUDt2pRxTnR(ni)IyDZNjjjfibc4orsEtIssc(ZzeT(nDJj(vjrjjViXcagya(kA9Cx24XHExissIeCNijddKaF)gowGSfgrYBTvt36dv00HwkxEGHH10JwQB3guAPOLng)YtJFSwQfARHZRFy4fPPB91sTxV81Uw6XZJrpEGHjrjjBhY5fKHBMKKirFCtIssqQSXKx)WWlkIw)M9XKafsWfsusIRMTpSDmjkj5fjb)5mA9Cx24XHExissIe9tKKHbssGKG)CgTEUlB8RsYBTuygzVwDBqPLQRYZJrpKmn(XKaks(QKSassgjRFy4frc(EFa)LeCQtiPyLLKaUlmK4bG)sYciHvKAFmjEbtsbwsay5Z6QQDHrB10T(kEnDOLYLhyyyn9OL62TbLw68FqNbZmB(fRLcZi71QBdkTuDbXKO3aqnj9KKUqnmtIxKa1wtRIys8cMetxmj9sYxLe89(qItsY)ni)ir9aws8cMeDc7QBJLjjfVFHAP2Rx(AxlLTMwfXXUYEbnjkjXvZ2h2oMeLKe8NZO61HGdUDt2pRxTnR(ni)IyDZNjbkKabCNijkj5fjWGn6WU62y5mcVFHzyp0XWXTTJ7cdjddKKajwawU8AJfBpGbCWKmmqcsLnM86hgErKKejqGK3ARMU1hxRPdTuU8addRPhTu3UnO0srRFt3y0sHzK9A1TbLwQUGysCssx)MUXqceVI3hsupGLKFzyeIK01VPBmK0isCZXom0K8vjbCKan4tIFmjEa4VKSasay5Z6QKOtuYRLAVE5RDT0G)CgbfVpOSkFwwDBqf)QKOKKxKe8NZiA9B6gt845XOhpWWKmmqIJ2ZnzvaE(ijjsGyjsYBTvt36dX00HwkxEGHH10JwQB3guAPO1VPBmAPWmYET62GslvX9dvjrNOKNKaEcoMeCckSGXmj479HK01VPBmK4fmj7dxKKU(H(hgwl1E9Yx7APwawU8AJvJ5zZtNjrjjVibRFThy4OfuybJ5mmJGUSKmmqIfamWa8v065USXVkjddKe8NZO1ZDzJFvsEtIssSaGbgGVIwqHfmMZ7dNrQ91lkECO3fIeOqcglCm0vejqvsSCBi5fjoAp3Kvb45JeircUtKK3KOKKG)CgrRFt3yIhh6DHibkKGlKOKKeib((nCSazlmsB10nesuthAPC5bggwtpAP2Rx(Axl1cWYLxBSAmpBE6mjkj5fjy9R9adhTGclymNHze0LLKHbsSaGbgGVIwp3Ln(vjzyGKG)CgTEUlB8RsYBsusIfamWa8v0ckSGXCEF4msTVErXJd9UqKafsGkKOKKG)CgrRFt3yIFvsuscBnTkIJDL9cAsusscKG1V2dmCSXuGJZO1p0)WWKOKKeib((nCSazlmsl1TBdkTu06h6FyyTvt3qqFnDOLYLhyyyn9OL62TbLwkA9d9pmSwkmJSxRUnO0s1fets66h6FyysW37djErceVI3hsupGLeWrspjbAWhYGjbGLpRRsIorjpj479HeOb)JKIv0sI1rBKeDAqasG)HQis0jk5jXxs2hMeUGjbmjzFysGiGR9b6JKG)CsspjjD9B6gdj4bFdCbzljt3yibmNKaksWfsahjggHiz9ddViTu71lFTRLg8NZiO49bLTg2Vm2g1Gk(vjzyGKxKKajO1VzFC0vZ2h2oMeLKKajy9R9adhBmf44mA9d9pmmjddK8IKG)CgTEUlB84qVlejqHeCtIssc(Zz065USXVkjddK8IKG)CgphlxGpkppU0lOJhh6DHibkKGXchdDfrcuLel3gsErIJ2ZnzvaE(ibsKKSej5njkjj4pNXZXYf4JYZJl9c64xLK3K8MeLKG1V2dmCeT(nDJjJhuBE6gtgmNKOKeKkBm51pm8IIO1VPBmKafssgjVjrjjVijbsUFXtWHHJBhY4bxLHp2dd6cMVidr)TQkdtYWajiv2yYRFy4ffrRFt3yibkKKmsERTA6gcqqthAPC5bggwtpAPUDBqPLwm(CiauAPWmYET62Gslvxqmj6kaqHiPlssbg)ibQTMwfXK4fmjihltIE7BmKORaafjtWrco1jKuSYQLAVE5RDT0xKe8NZiBnTkIZiGXV4XHExissIewrS9VCE7qMKHbsErI9XpmmIefibcKOKKJTp(HHZBhYKafsWnjVjzyGe7JFyyejkqsYi5njkjXvZ2h2owB10nesMMo0s5YdmmSME0sTxV81Uw6lsc(ZzKTMwfXzeW4x84qVlejjrcRi2(xoVDitYWajViX(4hggrIcKabsusYX2h)WW5TdzsGcj4MK3KmmqI9XpmmIefijzK8MeLK4Qz7dBhRL62TbLw6JBM5qaO0wnDdbCrthAPC5bggwtpAP2Rx(Axl9fjb)5mYwtRI4mcy8lECO3fIKKiHveB)lN3oKjrjjViXcagya(kA9Cx24XHExissIeCNijddKybadmaFfTGclymN3hoJu7Rxu84qVlejjrcUtKK3KmmqYlsSp(HHrKOajqGeLKCS9XpmCE7qMeOqcUj5njddKyF8ddJirbssgjVjrjjUA2(W2XAPUDBqPLo)gtoeakTvt3qa3A6qlLlpWWWA6rlfMr2Rv3guAP6cIjbIea1KaksWPItl1TBdkTu8(Dn4YGzMn)I1wnDdbOIMo0s5YdmmSME0sbQAPiE1sD72GslfRFThyyTuSU5ZAPiv2yYRFy4ffrRFZ(yssIeCHKrjzAaGJKxKe6OLpOZyDZNjbQsI(jMijqIeiKijVjzusMga4i5fjb)5mIw)q)ddN5qvaE(c5AZiGXViAD7ysGej4cjV1sHzK9A1TbLwkoDJ9B8LrKG)H3h(izbK8rmjPRFZ(ys6IKuGXpsW)02hsAej(scUjz9ddVOr1NKj4iHXYh0KaHeXvKe6OLpOjbCKGlKKU(H(hgMeOoufGNVqUwsqRBhJ0sX6xU8qwlfT(n7JZDLraJFARMUHGIxthAPC5bggwtpAPUDBqPLI)89rlfMr2Rv3guAP6cIjbI889HKUijfy8JeO2AAvetc4iPNKuassx)M9XKGVngsM9ssxlGeCQtiPyLLeVGoeCSwQ96LV21sFrcBnTkIJMF5xUyfTKmmqcBnTkIJEbDUyfTKOKeS(1EGHJnkBnSJLj5njkj5fjRFy4nUDiNxqgUzssIeCHKHbsyRPvrC08l)YDLHajddKmBmpB(4qVlejqHe9tKK3KmmqsWFoJS10QioJag)Ihh6DHibkK42TbveT(n7JJSIy7F582Hmjkjj4pNr2AAveNraJFXVkjddKWwtRI4yxzeW4hjkjjbsW6x7bgoIw)M9X5UYiGXpsggij4pNrRN7Ygpo07crcuiXTBdQiA9B2hhzfX2)Y5TdzsusscKG1V2dmCSrzRHDSmjkjj4pNrRN7Ygpo07crcuiHveB)lN3oKjrjjb)5mA9Cx24xLKHbsc(Zz8CSCb(O884sVGo(vjrjjiv2yYpoAzssIKeJqfsusYlsqQSXKx)WWlIeOOajjJKHbssGK1nCTre4BYGzEF48eCmAJC5bggMK3KmmqscKG1V2dmCSrzRHDSmjkjj4pNrRN7Ygpo07crssKWkIT)LZBhYARMUHaUwthAPC5bggwtpAPWmYET62GslvxqmjPRFZ(ys6jjDrsY9l)ibQTMwfX4GKUijfy8JeO2AAvetcOibxgLK1pm8IibCKSasupGLKuGXpsGARPvrSwQB3guAPO1VzFS2QPBiaX00HwkxEGHH10JwkmJSxRUnO0s1BUXSp3xl1TBdkT07xz3UnOYMgTAPMgT5YdzT0PBm7Z91wTvlD6gZ(CFnDOPB910HwkxEGHH10JwQB3guAPO1p0)WWAPWmYET62GslnD9d9pmmjtWrsialhY1sYVmmcrYh1fgs0dqN6ql1E9Yx7APjqY9lEcomCmWnEz5myMDJjVpDHbfzi6VvvzyTvt3qqthAPC5bggwtpAPUDBqPLI(1Spwl1cT1W51pm8I00T(AP2Rx(AxlfgSXqaOM9XXJd9UqKKejhh6DHibQsceGajqIe9X1APWmYET62GslfNoAjzFysGblj479HK9HjjeGws2oKjzbK4WWK8RTnKSpmjHUIib(F(2GIKgrYtVrss)1SpMKJd9UqKe(nBRAAgMKfqsOV2hscbGA2htc8)8TbL2QP7KPPdTu3UnO0sdbGA2hRLYLhyyyn9OTARwkA10HMU1xthAPC5bggwtpAPUDBqPLEowUaFuEECPxqRLcZi71QBdkTuDbXKSpmjqeW1(a9rc(EFiXjbN6eskwzjzF8LKgvq2sY8aHKK8FdYpTu71lFTRLg8NZO1ZDzJhh6DHijjs0h3ARMUHGMo0s5YdmmSME0sD72GslfT(H(hgwlfMr2Rv3guAP6cIjjD9d9pmmjlGKXmRsYxLK9HjrXDShg0fmFKe8Nts6jj9scEW3atcRi1(ysc4j4ysMD1ONUWqY(WKuSIwsSoAjbCKSasG)HQKeWtWXKGtqHfmM1sTxV81Uw69lEcomCC7qgp4Qm8XEyqxW8fzi6VvvzysusYlsyRPvrCSRSxqtIsssGKxK8IKG)Cg3oKXdUkdFShg0fmFXJd9UqKKejUDBqfXF((ezfX2)Y5TdzsgLKeJ6tIssErcBnTkIJDLda7djddKWwtRI4yxzeW4hjddKWwtRI4O5x(LlwrljVjzyGKG)Cg3oKXdUkdFShg0fmFXJd9UqKKejUDBqfrRFZ(4iRi2(xoVDitYOKKyuFsusYlsyRPvrCSRS5x(rYWajS10QioIag)YfROLKHbsyRPvrC0lOZfROLK3K8MKHbssGKG)Cg3oKXdUkdFShg0fmFXVkjVjzyGKxKe8NZO1ZDzJFvsggibRFThy4OfuybJ5mmJGUSK8MeLKybadmaFfTGclymN3hoJu7Rxu8yhgAsusIfGLlV2y1yE280zsEtIssErscKyby5YRnog6R9IKHbsSaGbgGVICOkapF5aqbhpo07crssKGRj5njkj5fjb)5mA9Cx24xLKHbssGelayGb4RO1ZDzJh7WqtYBTvt3jtthAPC5bggwtpAPUDBqPL6WU62y5mcVFHAPwOTgoV(HHxKMU1xl1E9Yx7APjqcmyJoSRUnwoJW7xyg2dDmCCB74UWqIsssGe3UnOIoSRUnwoJW7xyg2dDmCSR800yEwsusYlssGeyWgDyxDBSCgH3VW8d7M422XDHHKHbsGbB0HD1TXYzeE)cZpSBIhh6DHijjsWnjVjzyGeyWgDyxDBSCgH3VWmSh6y4iAD7ysGcjjJeLKad2Od7QBJLZi8(fMH9qhdhpo07crcuijzKOKeyWgDyxDBSCgH3VWmSh6y4422XDHrlfMr2Rv3guAP6cIjrNWU62yzssX7xij4F4IK9HpMKgrsbiXTBJLjbH3VqCqIJiX4ltIJirfGqDGHjbuKGW7xij479Heiqc4izY45Je062XisahjGIeNKKnkji8(fsccqY(4lj7dtsX4jbH3Vqs87ASmIeic)OLeFU8rY(4lji8(fscRi1(yK2QPBCrthAPC5bggwtpAPUDBqPLAbfwWyoVpCgP2xViTuygzVwDBqPLQligrcobfwWyMKEsco1jKuSYssJi5Rsc4ibAWNe)ysGze0LTlmKGtDcjfRSKGV3hsWjOWcgZK4fmjqd(K4htsaBa4jbxsKeDIsETu71lFTRLMajW3VHJfiBHrKOKKxK8IeS(1EGHJwqHfmMZWmc6YsIsssGelayGb4RO1ZDzJh7WqtIsssGK7x8eCy4O61HGdUDt2pRxTnR(ni)IC5bggMKHbsc(Zz065USXVkjVjrjjoAp3Kvb45JeOqcUKijkj5fjb)5mYwtRI4S5x(fpo07crssKOFIKmmqsWFoJS10QioJag)Ihh6DHijjs0prsEtYWajbaeIeLKmBmpB(4qVlejqHe9tKK3ARMUXTMo0s5YdmmSME0sbQAPiE1sD72GslfRFThyyTuSU5ZAPVij4pNXZXYf4JYZJl9c64XHExissIeCtYWajjqsWFoJNJLlWhLNhx6f0XVkjVjrjjVij4pNXXDbFmCMdvb45lKRnZfFyA9IJhh6DHibkKGXchdDfrYBsusYlsc(ZzKTMwfXzeW4x84qVlejjrcglCm0vejddKe8NZiBnTkIZMF5x84qVlejjrcglCm0vejV1sHzK9A1TbLwkobfCVnOizcosCJHeyWIizF8LKqFmJib9pMK9HHMe)4cYwsoEEm6HHjb)dxKOR6y5c8rKO3oU0lOj5XrKyyeIK9XlsWnji2Ii54qVRUWqc4izFysgd91ErsWFojPrK4bG)sYciz6gdjG5KeWrIxqtcuBnTkIjPrK4bG)sYciHvKAFSwkw)YLhYAPWGnFme93hhY1I0wnDdv00HwkxEGHH10JwQB3guAPHaqn7J1sTxV81Uw6XZJrpEGHjrjjRFy4nUDiNxqgUzssIe9Hajkj5fjUA2(W2XKOKeS(1EGHJWGnFme93hhY1Ii5TwQfARHZRFy4fPPB91wnDR410HwkxEGHH10JwQB3guAPOFn7J1sTxV81Uw6XZJrpEGHjrjjRFy4nUDiNxqgUzssIe9Hajkj5fjUA2(W2XKOKeS(1EGHJWGnFme93hhY1Ii5TwQfARHZRFy4fPPB91wnDJR10HwkxEGHH10JwQB3guAPOLng)YtJFSwQ96LV21spEEm6Xdmmjkjz9ddVXTd58cYWntssKOpuHeLK8IexnBFy7ysuscw)ApWWryWMpgI(7Jd5ArK8wl1cT1W51pm8I00T(ARMUHyA6qlLlpWWWA6rl1TBdkT0j4SCgmZLV)J1sHzK9A1TbLwQUGys0BaDtcOiXctc(EFa)LeRRQ2fgTu71lFTRL6Qz7dBhRTA6w)e10HwkxEGHH10JwQB3guAPCOkapF5aqbRLcZi71QBdkTuDbXKarSl4JHjjvTVErKGV3hs8cAsmGcdjCb(yEiX4OTlmKa1wtRIys8cMK9GMKfqIPlMKEj5Rsc(EFij5)gKFK4fmj4uNqsXkRwQ96LV21sFrYlsc(ZzKTMwfXzeW4x84qVlejjrI(jsYWajb)5mYwtRI4S5x(fpo07crssKOFIK8MeLKybadmaFfTEUlB84qVlejjrsYsKeLK8IKG)CgvVoeCWTBY(z9QTz1Vb5xeRB(mjqHeiGljsYWajjqY9lEcomCu96qWb3Uj7N1R2Mv)gKFrgI(BvvgMK3K8MKHbsc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZKKKcKabfFIKmmqIfamWa8v065USXJDyOjrjjoAp3Kvb45JKKibILO2QPB91xthAPC5bggwtpAPUDBqPLAzdJ22nz30yQqUwTuygzVwDBqPLQliMeCQtiPyLLe89(qcobfwWygsqe7c(yyssv7RxejEbtcmOGSLeaw(WF9YKK8FdYpsahj4F4Ie9yaayZhTKGh8nWKWksTpMKaEcoMeCQtiPyLLewrQ9XiTu71lFTRLMajW3VHJfiBHrKOKeS(1EGHJw4SfuW92GIeLK8IehTNBYQa88rssKaXsKeLK8IKG)Cgh3f8XWzoufGNVqU2mx8HP1lo(vjzyGKeiXcWYLxBCm0x7fjVjzyGelalxETXQX8S5PZKmmqsWFoJbgaa28rB8RsIssc(ZzmWaaWMpAJhh6DHibkKaHejzusErYlsGyKavj5(fpbhgoQEDi4GB3K9Z6vBZQFdYVidr)TQkdtYBsgLKxKybf8V3O6X2gXz30yQqU242HCgRB(mjVj5njVjrjjjqsWFoJwp3Ln(vjrjjVijbsSaSC51gRgZZMNotYWajwaWadWxrlOWcgZ59HZi1(6ff)QKmmqsaaHirjjDT8Pcm(YW5zJ5zZhh6DHibkKybadmaFfTGclymN3hoJu7Rxu84qVlejJscuHKHbs6A5tfy8LHZZgZZMpo07crcUIe9X1jscuibcjsYOK8IelOG)9gvp22io7MgtfY1g3oKZyDZNj5njV1wnDRpe00HwkxEGHH10JwQ96LV21stGe473WXcKTWisuscw)ApWWrlC2ck4EBqrIssErIJ2ZnzvaE(ijjsGyjsIssErsWFoJJ7c(y4mhQcWZxixBMl(W06fh)QKmmqscKyby5YRnog6R9IK3KmmqIfGLlV2y1yE280zsggij4pNXadaaB(On(vjrjjb)5mgyaayZhTXJd9UqKafsswIKmkjVi5fjqmsGQKC)INGddhvVoeCWTBY(z9QTz1Vb5xKHO)wvLHj5njJsYlsSGc(3Bu9yBJ4SBAmvixBC7qoJ1nFMK3K8MK3KOKKeij4pNrRN7Yg)QKOKKxKKajwawU8AJvJ5zZtNjzyGelayGb4ROfuybJ58(WzKAF9IIFvsggijaGqKOKKUw(ubgFz48SX8S5Jd9UqKafsSaGbgGVIwqHfmMZ7dNrQ91lkECO3fIKrjbQqYWajDT8Pcm(YW5zJ5zZhh6DHibxrI(46ejbkKKSejzusErIfuW)EJQhBBeNDtJPc5AJBhYzSU5ZK8MK3APUDBqPL2L1VY3guARMU1pzA6qlLlpWWWA6rlfOQLI4vl1TBdkTuS(1EGH1sX6MpRLMajwaWadWxrRN7Ygp2HHMKHbssGeS(1EGHJwqHfmMZWmc6YsIssSaSC51gRgZZMNotYWajW3VHJfiBHrAPWmYET62GslfIa)ApWWK8rmmjGIepOn92mIK9XxsW71sYcijGjb5yzysMGJeCQtiPyLLeeGK9Xxs2hgAs8JRLe8oAzysGi8Jwsc4j4ys2houlfRF5YdzTuKJLZtWLTEUlR2QPB9XfnDOLYLhyyyn9OL62TbLw68FqNbZmB(fRLcZi71QBdkTuDbXis0BaOMKEssxK4fjqT10QiMeVGjzVMrKSasmDXK0ljFvsW37djj)3G8dhKGtDcjfRSK4fmj6e2v3gltskE)c1sTxV81UwkBnTkIJDL9cAsusIRMTpSDmjkjj4pNr1RdbhC7MSFwVABw9Bq(fX6Mptcuibc4sIKOKKxKad2Od7QBJLZi8(fMH9qhdh32oUlmKmmqscKyby5YRnwS9agWbtYBsuscw)ApWWrKJLZtWLTEUlR2QPB9XTMo0s5YdmmSME0sD72GslfT(nDJrlfMr2Rv3guAP6cIjbIxX7djPRFt3yir9awej9KK01VPBmK0OcYws(QAP2Rx(Axln4pNrqX7dkRYNLv3guXVkjkjj4pNr0630nM4XZJrpEGH1wnDRpurthAPC5bggwtpAP2Rx(Axln4pNr06NbCWXJd9UqKafsWnjkj5fjb)5mYwtRI4mcy8lECO3fIKKib3KmmqsWFoJS10QioB(LFXJd9UqKKej4MK3KOKehTNBYQa88rssKaXsul1TBdkTuRxw2Kd(ZPwAWFoZLhYAPO1pd4G1wnDRVIxthAPC5bggwtpAPUDBqPLIw)MUXOLcZi71QBdkTuf3pufrIorjpjb8eCmj4euybJzs(OUWqY(WKGtqHfmMjXck4EBqrYciX(W2XK0tsWjOWcgZK0isC7(DJbAs8aWFjzbKeWKyD0QLAVE5RDT01nCTr0YgJFz4RNBKlpWWWKOKeeVBxyqreWaYWxpxsussWFoJO1VPBmrya(sB10T(4AnDOLYLhyyyn9OL62TbLwkA9d9pmSwkmJSxRUnO0svC)qvejosLKaEcoMeCckSGXmjFuxyizFysWjOWcgZKybfCVnOizbKyFy7ys6jj4euybJzsAejUD)UXanjEa4VKSascysSoA1sTxV81UwQfGLlV2y1yE280zsuscw)ApWWrlOWcgZzygbDzjrjjwaWadWxrlOWcgZ59HZi1(6ffpo07crcuib3KOKKeib((nCSazlmsB10T(qmnDOLYLhyyyn9OL62TbLwkA9B6gJwkmJSxRUnO0s1fets6630ngsW37djPlBm(rII765sIxWKuassx)mGdghKG)HlskajPRFt3yiPrK8vXbjqd(K4htsxKKC)YpsGARPvrmjGJKfqI6bSKK8FdYpsW)WfjEaaltcelrs0jk5jbCK4WQ(2yzsq49lKKhhrcUEueBrKCCO3vxyibCK0is6IKPPX8SAP2Rx(AxlDDdxBeTSX4xg(65g5Ydmmmjkjjbsw3W1grRFgWbh5Ydmmmjkjj4pNr0630nM4XZJrpEGHjrjjVij4pNr2AAveNn)YV4XHExissIeOcjkjHTMwfXXUYMF5hjkjj4pNr1RdbhC7MSFwVABw9Bq(fX6Mptcuibc4orsggij4pNr1RdbhC7MSFwVABw9Bq(fX6MptsskqceWDIKOKehTNBYQa88rssKaXsKKHbsGbB0HD1TXYzeE)cZWEOJHJhh6DHijjsW1KmmqIB3gurh2v3glNr49lmd7Hogo2vEAAmpljVjrjjjqIfamWa8v065USXJDyO1wnDdHe10HwkxEGHH10JwQB3guAPO1p0)WWAPWmYET62GslvxqmjPRFO)HHjbIxX7djQhWIiXlysG)HQKOtuYtc(hUibN6eskwzjbCKSpmjqeW1(a9rsWFojPrK4bG)sYciz6gdjG5KeWrc0GpKbtI1vjrNOKxl1E9Yx7APb)5mckEFqzRH9lJTrnOIFvsggij4pNXXDbFmCMdvb45lKRnZfFyA9IJFvsggij4pNrRN7Yg)QKOKKxKe8NZ45y5c8r55XLEbD84qVlejqHemw4yORisGQKy52qYlsC0EUjRcWZhjqIKKLijVjrjjb)5mEowUaFuEECPxqh)QKmmqscKe8NZ45y5c8r55XLEbD8RsIsssGelayGb4R45y5c8r55XLEbD8yhgAsggijbsSaSC51gXY1(a9rYBsggiXr75MSkapFKKejqSejrjjS10Qio2v2lO1wnDdb910HwkxEGHH10JwQB3guAPO1p0)WWAPWmYET62Gslvhh0KSasc9Xmj7dtsaJwsatssx)mGdMKaOjbTUDCxyiPxs(QKar)TDSbAs6IeVGMeO2AAvetsWFjj5)gKFK0OAjXda)LKfqsatI6bSwgwl1E9Yx7APRB4AJO1pd4GJC5bggMeLKKaj3V4j4WWXTdz8GRYWh7HbDbZxKHO)wvLHjrjjVij4pNr06NbCWXVkjddK4O9CtwfGNpssIeiwIK8MeLKe8NZiA9Zao4iAD7ysGcjjJeLK8IKG)CgzRPvrCgbm(f)QKmmqsWFoJS10QioB(LFXVkjVjrjjb)5mQEDi4GB3K9Z6vBZQFdYViw38zsGcjqqXNijkj5fjwaWadWxrRN7Ygpo07crssKOFIKmmqscKG1V2dmC0ckSGXCgMrqxwsusIfGLlV2y1yE280zsERTA6gcqqthAPC5bggwtpAPUDBqPLIw)q)ddRLcZi71QBdkTuf3puLK01p0)WWK0fjojk(rrSLKuGXpsGARPvrmoibguq2sIHxs6Le1dyjj5)gKFK8AF8LKgrYJxWggMKaOjH79Hps2hMK01VPBmKy6IjbCKSpmj6eL8jbXsKetxmjtWrs66h6Fy434GeyqbzljaS8H)6LjXlsG4v8(qI6bSK4fmjgEjzFys8aawMetxmjpEbByssx)mGdwl1E9Yx7APjqY9lEcomCC7qgp4Qm8XEyqxW8fzi6VvvzysusYlsc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5ZKafsGGIprsggij4pNr1RdbhC7MSFwVABw9Bq(fX6Mptcuibc4orsusY6gU2iAzJXVm81ZnYLhyyysEtIssc(ZzKTMwfXzeW4x84qVlejjrIINeLKWwtRI4yxzeW4hjkjjbsc(Zzeu8(GYQ8zz1Tbv8RsIsssGK1nCTr06NbCWrU8addtIssSaGbgGVIwp3LnECO3fIKKirXtIssErIfamWa8vCCxWhdNrQ91lkECO3fIKKirXtYWajjqIfGLlV24yOV2lsERTA6gcjtthAPC5bggwtpAPUDBqPLwm(CiauAPWmYET62Gslvxqmj6kaqHiPlssUF5hjqT10QiMeVGjb5yzsG43nZr1BFJHeDfaOizcosWPoHKIvws8cMeiIDbFmmjqDOkapFHCTAP2Rx(Axl9fjb)5mYwtRI4S5x(fpo07crssKWkIT)LZBhYKmmqYlsSp(HHrKOajqGeLKCS9XpmCE7qMeOqcUj5njddKyF8ddJirbssgjVjrjjUA2(W2XKOKeS(1EGHJihlNNGlB9CxwTvt3qax00HwkxEGHH10JwQ96LV21sFrsWFoJS10QioB(LFXJd9UqKKejSIy7F582HmjkjjbsSaSC51ghd91ErYWajVij4pNXXDbFmCMdvb45lKRnZfFyA9IJFvsusIfGLlV24yOV2lsEtYWajViX(4hggrIcKabsusYX2h)WW5TdzsGcj4MK3KmmqI9XpmmIefijzKmmqsWFoJwp3Ln(vj5njkjXvZ2h2oMeLKG1V2dmCe5y58eCzRN7YQL62TbLw6JBM5qaO0wnDdbCRPdTuU8addRPhTu71lFTRL(IKG)CgzRPvrC28l)Ihh6DHijjsyfX2)Y5TdzsusscKyby5YRnog6R9IKHbsErsWFoJJ7c(y4mhQcWZxixBMl(W06fh)QKOKelalxETXXqFTxK8MKHbsErI9XpmmIefibcKOKKJTp(HHZBhYKafsWnjVjzyGe7JFyyejkqsYizyGKG)CgTEUlB8RsYBsusIRMTpSDmjkjbRFThy4iYXY5j4Ywp3Lvl1TBdkT053yYHaqPTA6gcqfnDOLYLhyyyn9OLcZi71QBdkTuDbXKarcGAsafjwyTu3UnO0sX731GldMz28lwB10neu8A6qlLlpWWWA6rl1TBdkTu063SpwlfMr2Rv3guAP6cIjjD9B2htYcir9awssbg)ibQTMwfX4GeCQtiPyLLKhhrIHris2oKjzF8IeNeiYZ3hsyfX2)YKy45sc4ibugOjj5(LFKa1wtRIysAejFvTu71lFTRLYwtRI4yxzZV8JKHbsyRPvrCebm(LlwrljddKWwtRI4OxqNlwrljddKe8NZiE)UgCzWmZMFXXVkjkjj4pNr2AAveNn)YV4xLKHbsErsWFoJwp3LnECO3fIeOqIB3gur8NVprwrS9VCE7qMeLKe8NZO1ZDzJFvsERTA6gc4AnDOLYLhyyyn9OLcZi71QBdkTuDbXKarE((qcyF4dFJysW)02hsAejDrskW4hjqT10QighKGtDcjfRSKaoswajQhWssY9l)ibQTMwfXAPUDBqPLI)89rB10neGyA6qlLlpWWWA6rlfMr2Rv3guAP6n3y2N7RL62TbLw69RSB3guztJwTutJ2C5HSw60nM95(AR2QLQESfeg4RMo00T(A6ql1TBdkT0XDbFmCgP2xViTuU8addRPhTvt3qqthAPC5bggwtpAPavTueVAPUDBqPLI1V2dmSwkw38zT0e1sHzK9A1TbLwQoEysW6x7bgMKgrcIxswajjsc(EFiPaKGwFjbuK8rmj711yEr4Ge9jb)dxKSpmjZ(qljGIjPrKaks(ighKabs6jj7dtcITGcMKgrIxWKKms6jjbG9He)yTuS(LlpK1sbv(J48EDnMxTvt3jtthAPC5bggwtpAPavTuhgwl1TBdkTuS(1EGH1sX6MpRLQVwQ96LV21s3RRX8gx9JFKhyysusYEDnM34QF0cagya(kc)pFBqPLI1VC5HSwkOYFeN3RRX8QTA6gx00HwkxEGHH10Jwkqvl1HH1sD72GslfRFThyyTuSU5ZAPqql1E9Yx7AP711yEJleIFKhyysusYEDnM34cHOfamWa8ve(F(2GslfRF5YdzTuqL)ioVxxJ5vB10nU10HwQB3guAPHaqnUR8eCHAPC5bggwtpARMUHkA6qlLlpWWWA6rl1TBdkTu8NVpAPMU4Sfwlv)e1sTxV81Uw6lsyRPvrC08l)YfROLKHbsyRPvrCSRS5x(rYWajS10Qio2voaSpKmmqcBnTkIJEbDUyfTK8wlfMr2Rv3guAPj)XwhTKabsGipFFiXlysCssx)q)ddtcOijvhKGV3hs0DJ5zjrV5mjEbtIEa6uhKaossx)M9XKa2h(W3iwB10TIxthAPC5bggwtpAP2Rx(Axl9fjS10QioA(LF5Iv0sYWajS10Qio2v28l)izyGe2AAveh7kha2hsggiHTMwfXrVGoxSIwsEtIssupgBu)i(Z3hsusscKOEm2ieI4pFF0sD72Gslf)57J2QPBCTMo0s5YdmmSME0sTxV81UwAcKC)INGddhdCJxwodMz3yY7txyqrU8addtYWajjqIfGLlV2y1yE280zsggijbsqQSXKx)WWlkIw)MUXqIcKOpjddKKajRB4AJLV)Jr5a34LLJC5bggwl1TBdkTu063SpwB10netthAPC5bggwtpAP2Rx(Axl9(fpbhgog4gVSCgmZUXK3NUWGIC5bggMeLKyby5YRnwnMNnpDMeLKGuzJjV(HHxueT(nDJHefirFTu3UnO0srRFO)HH1wTvB1sXYhQbLMUHqIqq)etM(jQLI3VQlmiTuisDQRQBft3q8P3jHeD8WK0HQGBjzcosGmyE6FZczKCme93hdtcceYK4)fe6ldtI9XlmmksJKCDXKav07KGtqHLVLHjjTdXjjiOR1vej4kswajj33jbUX2OguKau5ZxWrYli9MKxqqrVJ0ijxxmj6RVENeCckS8Tmmjq29lEcomCeIdYizbKaz3V4j4WWriUixEGHHHmsEPVIEhPrsUUys0xF9oj4euy5BzysGS96AmVr9JqCqgjlGeiBVUgZBC1pcXbzK8sFf9osJKCDXKOV(6DsWjOWY3YWKaz711yEJqicXbzKSasGS96AmVXfcrioiJKx6RO3rAKKRlMe9HGENeCckS8Tmmjq29lEcomCeIdYizbKaz3V4j4WWriUixEGHHHmsEPVIEhPrsUUys0hc6DsWjOWY3YWKaz711yEJ6hH4Gmswajq2EDnM34QFeIdYi5L(k6DKgj56IjrFiO3jbNGclFldtcKTxxJ5ncHiehKrYcibY2RRX8gxieH4GmsEPVIEhPrsUUys0pz6DsWjOWY3YWKaz3V4j4WWrioiJKfqcKD)INGddhH4IC5bgggYi5feu07incncePo1v1TIPBi(07KqIoEys6qvWTKmbhjqM6XwqyGVqgjhdr)9XWKGaHmj(FbH(YWKyF8cdJI0ijxxmjjtVtcobfw(wgMeiBVUgZBu)iehKrYcibY2RRX8gx9JqCqgjVGGIEhPrsUUysWf9oj4euy5BzysGS96AmVrieH4Gmswajq2EDnM34cHiehKrYliOO3rAKKRlMeCTENeCckS8Tmmjq29lEcomCeIdYizbKaz3V4j4WWriUixEGHHHmsEPVIEhPrsUUysGy6DsWjOWY3YWKaz3V4j4WWrioiJKfqcKD)INGddhH4IC5bgggYi5L(k6DKgHgbIuN6Q6wX0neF6DsirhpmjDOk4wsMGJeiZbmKrYXq0FFmmjiqitI)xqOVmmj2hVWWOinsY1ftsY07KGtqHLVLHjbYUFXtWHHJqCqgjlGei7(fpbhgocXf5YdmmmKrYl9v07insY1ftcurVtcobfw(wgMK0oeNKGGUwxrKGRWvKSassUVtsia(B(isaQ85l4i5fU6njV0xrVJ0ijxxmj4A9oj4euy5Bzyss7qCscc6ADfrcUIKfqsY9DsGBSnQbfjav(8fCK8csVj5L(k6DKgj56IjrF917KGtqHLVLHjjTdXjjiOR1vej4kswajj33jbUX2OguKau5ZxWrYli9MKx6RO3rAKKRlMe9Hy6DsWjOWY3YWKK2H4Kee016kIeCfjlGKK77Ka3yBudksaQ85l4i5fKEtYl9v07insY1ftce0xVtcobfw(wgMK0oeNKGGUwxrKGRizbKKCFNe4gBJAqrcqLpFbhjVG0BsEPVIEhPrsUUysGaurVtcobfw(wgMK0oeNKGGUwxrKGRizbKKCFNe4gBJAqrcqLpFbhjVG0BsEbbf9osJqJarQtDvDRy6gIp9ojKOJhMKoufCljtWrcKnDJzFUpKrYXq0FFmmjiqitI)xqOVmmj2hVWWOinsY1ftce07KGtqHLVLHjjTdXjjiOR1vej4kswajj33jbUX2OguKau5ZxWrYli9MKx6RO3rAeAeisDQRQBft3q8P3jHeD8WK0HQGBjzcosGm0czKCme93hdtcceYK4)fe6ldtI9XlmmksJKCDXKGl6DsWjOWY3YWKaz3V4j4WWrioiJKfqcKD)INGddhH4IC5bgggYi5L(k6DKgj56IjrF917KGtqHLVLHjjTdXjjiOR1vej4kCfjlGKK77KecG)MpIeGkF(cosEHREtYl9v07insY1ftI(qqVtcobfw(wgMK0oeNKGGUwxrKGRWvKSassUVtsia(B(isaQ85l4i5fU6njV0xrVJ0ijxxmjqir9oj4euy5Bzyss7qCscc6ADfrcUIKfqsY9DsGBSnQbfjav(8fCK8csVj5L(k6DKgHgbIuN6Q6wX0neF6DsirhpmjDOk4wsMGJeila4lKrYXq0FFmmjiqitI)xqOVmmj2hVWWOinsY1ftI(qm9oj4euy5Bzyss7qCscc6ADfrcUIKfqsY9DsGBSnQbfjav(8fCK8csVj5vYu07insY1ftcesuVtcobfw(wgMK0oeNKGGUwxrKGRizbKKCFNe4gBJAqrcqLpFbhjVG0BsEPVIEhPrOruSqvWTmmjqfsC72GIetJwuKgrlv9aZ2WAPqoKtIECJxwMef39ByAeihYjrxXp7dj6JRXbjqiriOpncncKd5KGZhVWWi9oncKd5KORjrNWWmmjPaJFKOh2dJ0iqoKtIUMeC(4fggMK1pm8M7jjwhXiswajwOTgoV(HHxuKgbYHCs01KORYHaSmmj)QylJq(bnjy9R9adJi5vh5ioir9ySz06h6Fyys01jrI6XyJO1p0)WWVJ0iqoKtIUMeDIf0WKOES1rBxyibI889HKEssVqgIK9Hjb)bkmKa1wtRI4incKd5KORjrxXhZKGtqHfmMjzFyssv7RxejojMExdtsi4ysMgwrDGHj5vpjbAWNKhhUGSLKNEjPxsqD43SEXGpYanj479He9aXtN6GKrjbNSHrB7gs0PPXuHCT4GKEHmysqJB13rAeihYjrxtIUIpMjjeGwsGSzJ5zZhh6DHGmsqwU8RbisCvvd0KSascaiejZgZZIibugOJ0i0iUDBqHIQhBbHb(QW4UGpgoJu7RxencKtIoEysW6x7bgMKgrcIxswajjsc(EFiPaKGwFjbuK8rmj711yEr4Ge9jb)dxKSpmjZ(qljGIjPrKaks(ighKabs6jj7dtcITGcMKgrIxWKKms6jjbG9He)yAe3UnOqr1JTGWaFhvbiH1V2dmmokpKvau5pIZ711yEXbw38zfsKgXTBdkuu9ylimW3rvasy9R9adJJYdzfav(J48EDnMxCauvWHHXbw38zf0hh9uH96AmVr9JFKhyyL711yEJ6hTaGbgGVIW)Z3gu0iUDBqHIQhBbHb(oQcqcRFThyyCuEiRaOYFeN3RRX8IdGQcommoW6MpRaeWrpvyVUgZBecXpYdmSY96AmVrieTaGbgGVIW)Z3gu0iUDBqHIQhBbHb(oQcqkeaQXDLNGlKgbYjj5p26OLeiqce557djEbtIts66h6FyysafjP6Ge89(qIUBmplj6nNjXlys0dqN6GeWrs663SpMeW(Wh(gX0iUDBqHIQhBbHb(oQcqc)57domDXzlSc6Nio6PcVyRPvrC08l)YfRODyGTMwfXXUYMF53WaBnTkIJDLda7ZWaBnTkIJEbDUyfTVPrC72Gcfvp2ccd8DufGe(Z3hC0tfEXwtRI4O5x(Llwr7WaBnTkIJDLn)YVHb2AAveh7kha2NHb2AAveh9c6CXkAFRu9ySr9J4pFFuMG6XyJqiI)89HgXTBdkuu9ylimW3rvasO1VzFmo6PcjC)INGddhdCJxwodMz3yY7txyqddjyby5YRnwnMNnpDEyibKkBm51pm8IIO1VPBmkO)WqcRB4AJLV)Jr5a34LLJC5bggMgXTBdkuu9ylimW3rvasO1p0)WW4ONkC)INGddhdCJxwodMz3yY7txyqkTaSC51gRgZZMNoRePYgtE9ddVOiA9B6gJc6tJqJa5qojqTIy7FzysyS8bnjBhYKSpmjUDbhjnIehR3gpWWrAe3UnOqkGag)YbShsJa5KKYlIeDcGAsafjjBusW37d4VKaF9CjXlysW37djPRFgWbtIxWKaHrjbSp8HVrmnIB3guifW6x7bgghLhYk0OSdyCG1nFwbKkBm51pm8IIO1VPBmjPVYxjSUHRnIw)mGdoYLhyy4HH1nCTr0YgJFz4RNBKlpWWWVhgqQSXKx)WWlkIw)MUXKeeOrGCss5frI1WowMe8pCrs663SpMeRxK80ljqyusw)WWlIe8pT9HKgrYXggRxljtWrY(WKa1wtRIyswajbmjQhp57yys8cMe8pT9HKzBm8rYciX6OLgXTBdk0OkajS(1EGHXr5HScnkBnSJLXbw38zfqQSXKx)WWlkIw)M9XjPpncKtIUGys0dFi(g3fgsW37dj4uNqsXkljGJeFU8rcobfwWyMKUibN6eskwzPrC72GcnQcqkGpeFJ7cdo6PcVsWcWYLxBSAmpBE68WqcwaWadWxrlOWcgZ59HZi1(6ff)QVvg8NZO1ZDzJhh6DHssFCtJa5KK8GLe89(qItco1jKuSYsY(4ljnQGSLeNKK)Bq(rI6bSKaosW)Wfj7dtYSX8SK0is8aWFjzbKWfmnIB3guOrvasQGTbfo6Pcb)5mA9Cx24XHExOK0h3ddbaes5SX8S5Jd9Uqqbc4MgbYjbNUX(n(YisW)W7dFK8rDHHeCckSGXmjfapj4BJHe3ya4jbAWNKfqcABJHeRJws2hMeKhYK4HGFTKaMKGtqHfmMhfN6eskwzjX6OfrJ42TbfAufGew)ApWW4O8qwblOWcgZzygbDzXbw38zfSCBE9QRLpvGXxgopBmpB(4qVlKUwFCRRTaGbgGVIwp3LnECO3f6nUsFCDIVvWYT51RUw(ubgFz48SX8S5Jd9Uq6A9XTUwFiKOU2cagya(kAbfwWyoVpCgP2xVO4XHExO34k9X1j(EyWcagya(kA9Cx24XHExOK6A5tfy8LHZZgZZMpo07cnmybadmaFfTGclymN3hoJu7Rxu84qVlusDT8Pcm(YW5zJ5zZhh6DH016N4WqcwawU8AJvJ5zZtNPrGCs0fedtYcibMno0KSpmjFKJHjbmjbN6eskwzjb)dxK8rDHHeyWpWWKaks(iMgXTBdk0OkajS(1EGHXr5HScw4SfuW92GchyDZNv4vcme93QQmCKdvH(y3KbhC5LLhgSaGbgGVICOk0h7Mm4GlVSC84qVleu0hQKOYeSaGbgGVICOk0h7Mm4GlVSC8yhg63ddwawU8AJJH(AVOrGCs0fetcuhQc9XUHeiEhC5LLjbcjIylIKaEcoMeNeCQtiPyLLKpIJ0iUDBqHgvbi9rCUxoehLhYkWHQqFSBYGdU8YY4ONkybadmaFfTEUlB84qVleuGqIkTaGbgGVIwqHfmMZ7dNrQ91lkECO3fckqiXHHaacPC2yE28XHExiOKmfpncKtIUGyssbFJH3UWqIU6paAsGki2IijGNGJjXjbN6eskwzj5J4inIB3guOrvasFeN7LdXr5HSciW3y4D7ct((bqJJEQGfamWa8v065USXJd9UqqbQOmbS(1EGHJwqHfmMZWmc6YomybadmaFfTGclymN3hoJu7Rxu84qVleuGkkX6x7bgoAbfwWyodZiOl7WqaaHuoBmpB(4qVleuGaUPrC72GcnQcq6J4CVCiokpKvOlK9(Rhy4me971(dZWm22Y4ONke8NZO1ZDzJhh6DHssFCtJa5KOJNgrsJiXj589HpsyJhaoFzsW7qtYcij0hZK4gdjGIKpIjbT(sYEDnMxejlGKaMetxmmjFvsW37dj4uNqsXkljEbtcobfwWyMeVGj5Jys2hMeiuWKGmGLeqrIfMKEssayFizVUgZlIe)ysafjFetcA9LK96AmViAe3UnOqJQaK2RRX8Qpo6Pcy9R9adhbv(J48EDnMxfGGYe2RRX8gHq8yhg6SfamWa81WWlS(1EGHJGk)rCEVUgZRc6pmG1V2dmCeu5pIZ711yEvizVv(k4pNrRN7Yg)QddwaWadWxrRN7Ygpo07cnkesAVUgZBu)OfamWa8ve(F(2Gs5ReSaSC51gRgZZMNopmKaw)ApWWrlOWcgZzygbDzFRmblalxETXXqFTxddwawU8AJvJ5zZtNvI1V2dmC0ckSGXCgMrqxwLwaWadWxrlOWcgZ59HZi1(6ff)QktWcagya(kA9Cx24xv5Rxb)5mYwtRI4S5x(fpo07cLK(jome8NZiBnTkIZiGXV4XHExOK0pX3kt4(fpbhgog4gVSCgmZUXK3NUWGggEf8NZyGB8YYzWm7gtEF6cdkx((poIw3owbCpme8NZyGB8YYzWm7gtEF6cdk7N1loIw3owbC)(9WqWFoJJ7c(y4mhQcWZxixBMl(W06fh)QVhgcaiKYzJ5zZhh6DHGcesCyaRFThy4iOYFeN3RRX8QqI0iUDBqHgvbiTxxJ5fc4ONkG1V2dmCeu5pIZ711yEtqbiOmH96AmVr9Jh7WqNTaGbgGVggW6x7bgocQ8hX596AmVkabLVc(Zz065USXV6WGfamWa8v065USXJd9UqJcHK2RRX8gHq0cagya(kc)pFBqP8vcwawU8AJvJ5zZtNhgsaRFThy4OfuybJ5mmJGUSVvMGfGLlV24yOV2RHblalxETXQX8S5PZkX6x7bgoAbfwWyodZiOlRslayGb4ROfuybJ58(WzKAF9IIFvLjybadmaFfTEUlB8RQ81RG)CgzRPvrC28l)Ihh6DHss)ehgc(ZzKTMwfXzeW4x84qVlus6N4BLjC)INGddhdCJxwodMz3yY7txyqddVc(ZzmWnEz5myMDJjVpDHbLlF)hhrRBhRaUhgc(ZzmWnEz5myMDJjVpDHbL9Z6fhrRBhRaUF)(9WqWFoJJ7c(y4mhQcWZxixBMl(W06fh)Qddbaes5SX8S5Jd9UqqbcjomG1V2dmCeu5pIZ711yEvirAeiNeDbXisCJHeW(WhjGIKpIjPxoercOiXctJ42TbfAufG0hX5E5qeo6Pcb)5mA9Cx24xDyWcWYLxBSAmpBE6SsS(1EGHJwqHfmMZWmc6YQ0cagya(kAbfwWyoVpCgP2xVO4xvzcwaWadWxrRN7Yg)QkF9k4pNr2AAveNn)YV4XHExOK0pXHHG)CgzRPvrCgbm(fpo07cLK(j(wzc3V4j4WWXa34LLZGz2nM8(0fg0WW9lEcomCmWnEz5myMDJjVpDHbP8vWFoJbUXllNbZSBm59PlmOC57)4iAD74Ks2WqWFoJbUXllNbZSBm59PlmOSFwV4iAD74Ks273ddb)5moUl4JHZCOkapFHCTzU4dtRxC8RomeaqiLZgZZMpo07cbfiKincKtIIJTnmtIB3guKyA0ssGJyysafjOE)(2GcsggtJOrC72GcnQcq6(v2TBdQSPrlokpKvWbmoq712vb9XrpvaRFThy4yJYoGPrC72GcnQcq6(v2TBdQSPrlokpKvia4loq712vb9Xrpv4(fpbhgog4gVSCgmZUXK3NUWGIme93QQmmnIB3guOrvas3VYUDBqLnnAXr5HScOLgHgbYjbNUX(n(YisW)W7dFKSpmjkUJ9qRV2h(ij4pNKGVngsMUXqcyojbFVpDrY(WKuSIwsSoAPrC72GcfDaRaw)ApWW4O8qwb4J9Wm(2yYt3yYG5ehyDZNv4vWFoJBhY4bxLHp2dd6cMV4XHExiOGXchdDfnAIr9hgc(ZzC7qgp4Qm8XEyqxW8fpo07cbf3UnOIO1VzFCKveB)lN3oKhnXO(kFXwtRI4yxzZV8ByGTMwfXreW4xUyfTddS10Qio6f05Iv0((TYG)Cg3oKXdUkdFShg0fmFXVQY7x8eCy442HmEWvz4J9WGUG5lYq0FRQYW0iqoj40n2VXxgrc(hEF4JK01p0)WWK0isWdU9HeRJ2UWqcalFKKU(n7JjPlssUF5hjqT10QiMgXTBdku0b8OkajS(1EGHXr5HScnMcCCgT(H(hgghyDZNvib2AAveh7kJag)u(cPYgtE9ddVOiA9B2hNeUvUUHRnIaFtgmZ7dNNGJrBKlpWWWddiv2yYRFy4ffrRFZ(4Ku8VPrGCs0fetcobfwWyMe8pCrIVKyyeIK9XlsWDIKOtuYtIxWKy6Ij5Rsc(EFibN6eskwzPrC72GcfDapQcqYckSGXCEF4msTVEr4ONk8cRFThy4OfuybJ5mmJGUSktWcagya(kA9Cx24Xom0ddb)5mA9Cx24x9TYxoAp3Kvb45dk4oXHbS(1EGHJnMcCCgT(H(hg(TYxb)5mYwtRI4S5x(fpo07cLeuzyi4pNr2AAveNraJFXJd9UqjbvER8vc3V4j4WWXa34LLZGz2nM8(0fg0WqWFoJbUXllNbZSBm59PlmOC57)4iAD74Ks2WqWFoJbUXllNbZSBm59PlmOSFwV4iAD74Ks27HHaacPC2yE28XHExiOOFI0iqoj6cIjrVDCPxqtc(EFibN6eskwzPrC72GcfDapQcq6CSCb(O884sVGgh9uHG)CgTEUlB84qVlus6JBAeiNeDbXKK(RzFmjDrIQxWCyBjbuK4f07txyizF8LetJLrKOpUGylIeVGjXWiej479HKqWXKS(HHxejEbtIVKSpmjCbtcysItskW4hjqT10QiMeFjrFCHeeBrKaosmmcrYXHExDHHehrYciPaljpo2UWqYci545XOhsG)xxyij5(LFKa1wtRIyAe3UnOqrhWJQaKq)A2hJdl0wdNx)WWlsb9Xrpv41XZJrpEGHhgc(ZzKTMwfXzeW4x84qVleusMs2AAveh7kJag)uECO3fck6Jlkx3W1grGVjdM59HZtWXOnYLhyy43kx)WWBC7qoVGmCZjPpUORrQSXKx)WWlA0Jd9UqkFXwtRI4yxzVGEy44qVleuWyHJHUIEtJa5KarKzvs(QKKU(nDJHeFjXngs2oKrK8ldJqK8rDHHKKdARFoIeVGjPxsAejEa4VKSasupGLeWrIHxs2hMeKkBB3qIB3guKy6IjjGna8K84fSHjrXDShg0fmFKaksGajRFy4frJ42Tbfk6aEufGeA9B6gdo6PcVc(ZzeT(nDJjE88y0JhyyLVqQSXKx)WWlkIw)MUXaLKnmKW9lEcomCC7qgp4Qm8XEyqxW8fzi6Vvvz43ddRB4AJiW3KbZ8(W5j4y0g5YdmmSYG)CgzRPvrCgbm(fpo07cbLKPKTMwfXXUYiGXpLb)5mIw)MUXepo07cbffVsKkBm51pm8IIO1VPBmjPaU8w5ReUFXtWHHJgOT(5O80W82fMmgthQI4idr)TQkdpmSDiJRWv4cUtk4pNr0630nM4XHExOrHWBLRFy4nUDiNxqgU5KWnncKtcezVpKO4o2dd6cMps(iMK01VPBmKSasgZSkjFvs2hMKG)Cssa0K4geGKpQlmKKU(nDJHeqrcUjbXwqbJibCKyyeIKJd9U6cdnIB3guOOd4rvasO1VPBm4ONkC)INGddh3oKXdUkdFShg0fmFrgI(BvvgwjsLnM86hgErr0630nMKuizkFLqWFoJBhY4bxLHp2dd6cMV4xvzWFoJO1VPBmXJNhJE8adpm8cRFThy4i8XEygFBm5PBmzWCQ8vWFoJO1VPBmXJd9Uqqjzddiv2yYRFy4ffrRFt3yscckx3W1grlBm(LHVEUrU8addRm4pNr0630nM4XHExiOG73VFtJa5KGt3y)gFzej4F49HpsCssx)q)ddtYhXKGVngsS(hXKKU(nDJHKfqY0ngsaZjoiXlys(iMK01p0)WWKSasgZSkjkUJ9WGUG5Je062XK8vPrC72GcfDapQcqcRFThyyCuEiRaA9B6gtgpO280nMmyoXbw38zfC0EUjRcWZxs46e11V0prOAWFoJBhY4bxLHp2dd6cMViAD74366xb)5mIw)MUXepo07cbvtgUcPYgt(Xrl)wx)cgSX5)GodMz28loECO3fcQI73kd(ZzeT(nDJj(vPrGCs0fets66h6FyysW37djkUJ9WGUG5JKfqYyMvj5RsY(WKe8NtsW37d4VKyaOUWqs6630ngs(QBhYK4fmjFets66h6Fyysafj4YOKOhGo1bjO1TJrK8RTnKGlKS(HHxenIB3guOOd4rvasO1p0)WW4ONkG1V2dmCe(ypmJVnM80nMmyovI1V2dmCeT(nDJjJhuBE6gtgmNktaRFThy4yJPahNrRFO)HHhgEf8NZyGB8YYzWm7gtEF6cdkx((poIw3ooPKnme8NZyGB8YYzWm7gtEF6cdk7N1loIw3ooPK9wjsLnM86hgErr0630ngOGlkX6x7bgoIw)MUXKXdQnpDJjdMtAeiNeDbXKGW7xijiaj7JVKan4tcgEjj0vejF1TdzscGMKpQlmK0ljoIeJVmjoIevac1bgMeqrIHris2hVijzKGw3ogrc4ibIWpAjb)dxKKSrjbTUDmIewrQ9X0iUDBqHIoGhvbi5WU62y5mcVFH4WcT1W51pm8IuqFC0tfsyB74UWOmb3UnOIoSRUnwoJW7xyg2dDmCSR800yE2HbyWgDyxDBSCgH3VWmSh6y4iAD7yOKmLWGn6WU62y5mcVFHzyp0XWXJd9Uqqjz0iqoj6Q88y0dj6kaqn7JjPNKGtDcjfRSK0iso2HHghKSp8XK4htIHris2hVib3KS(HHxejDrsY9l)ibQTMwfXKGV3hssbREdhKyyeIK9Xls0prsa7dF4BetsxK4f0Ka1wtRIysahjFvswaj4MK1pm8IijGNGJjXjj5(LFKa1wtRI4ijkoqbzljhppg9qc8)6cdjqe7c(yysG6qvaE(c5Aj5xggHiPlssbg)ibQTMwfX0iUDBqHIoGhvbifca1SpghwOTgoV(HHxKc6JJEQWXZJrpEGHvU(HH342HCEbz4Mt61l9XLrFHuzJjV(HHxueT(n7JHQqaQg8NZiBnTkIZMF5x8R((9Ohh6DHEJREP)ORB4AJl(UYHaqHIC5bgg(TYxwaWadWxrRN7Ygp2HHwzcW3VHJfiBHrkFH1V2dmC0ckSGXCgMrqx2HblayGb4ROfuybJ58(WzKAF9IIh7WqpmKGfGLlV2y1yE28053ddiv2yYRFy4ffrRFZ(yO86furx)k4pNr2AAveNn)YV4xfQcH3VHQV0F01nCTXfFx5qaOqrU8add)(TYeyRPvrCebm(Llwr7WWl2AAveh7kJag)ggEXwtRI4yx5aW(mmWwtRI4yxzZV87TYew3W1grGVjdM59HZtWXOnYLhyy4HHG)CgvVoeCWTBY(z9QTz1Vb5xeRB(CskabCN4BLVqQSXKx)WWlkIw)M9Xqr)eHQV0F01nCTXfFx5qaOqrU8add)(TshTNBYQa88LeUtuxh8NZiA9B6gt84qVleufQ8w5Rec(ZzCCxWhdN5qvaE(c5AZCXhMwV44xDyGTMwfXXUYiGXVHHeSaSC51ghd91E9MgbYjrxqmj6nGUjbuKyHjbFVpG)sI1vv7cdnIB3guOOd4rvastWz5myMlF)hJJEQGRMTpSDmncKtIUGysWPoHKIvwsafjwys(LHris8cMetxmj9sYxLe89(qcobfwWyMgXTBdku0b8OkajlBy02Uj7MgtfY1IJEQqcW3VHJfiBHrkX6x7bgoAHZwqb3BdkLVc(ZzeT(nDJj(vhgC0EUjRcWZxs4oX3kFLqWFoJiGbTTLJFvLje8NZO1ZDzJFvLVsWcWYLxBSAmpBE68WGfamWa8v0ckSGXCEF4msTVErXVQshTNBYQa88bfCN4BLRFy4nUDiNxqgU5K0h3JAbf8V3O6X2gXz30yQqU242HCgRB(8WqaaHu21YNkW4ldNNnMNnFCO3fckqiXrTGc(3Bu9yBJ4SBAmvixBC7qoJ1nF(nnIB3guOOd4rvasDz9R8Tbfo6PcjaF)gowGSfgPeRFThy4OfoBbfCVnOu(k4pNr0630nM4xDyWr75MSkapFjH7eFR8vcb)5mIag02wo(vvMqWFoJwp3Ln(vv(kblalxETXQX8S5PZddwaWadWxrlOWcgZ59HZi1(6ff)QkD0EUjRcWZhuWDIVvU(HH342HCEbz4MtccjoQfuW)EJQhBBeNDtJPc5AJBhYzSU5ZddbaeszxlFQaJVmCE2yE28XHExiOKSeh1ck4FVr1JTnIZUPXuHCTXTd5mw38530iqoj6cIjbQdvb45Je9akysafjwysW37djPRFt3yi5RsIxWKGCSmjtWrsY)ni)iXlysWPoHKIvwAe3UnOqrhWJQaK4qvaE(YbGcgh9uHaacPSRLpvGXxgopBmpB(4qVleu0h3ddVc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5Zqbc4oXHHG)CgvVoeCWTBY(z9QTz1Vb5xeRB(CskabCN4BLb)5mIw)MUXe)QkFzbadmaFfTEUlB84qVlus4oXHb473WXcKTWO30iqoj6Q88y0djtJFmjGIKVkjlGKKrY6hgErKGV3hWFjbN6eskwzjjG7cdjEa4VKSasyfP2htIxWKuGLeaw(SUQAxyOrC72GcfDapQcqcTSX4xEA8JXHfARHZRFy4fPG(4ONkC88y0JhyyLBhY5fKHBoj9XTsKkBm51pm8IIO1VzFmuWfLUA2(W2XkFf8NZO1ZDzJhh6DHss)ehgsi4pNrRN7Yg)QVPrGCs0fetIEda1K0ts6c1WmjErcuBnTkIjXlysmDXK0ljFvsW37djojj)3G8Je1dyjXlys0jSRUnwMKu8(fsJ42Tbfk6aEufG08FqNbZmB(fJJEQaBnTkIJDL9cALUA2(W2Xkd(Zzu96qWb3Uj7N1R2Mv)gKFrSU5Zqbc4orLVGbB0HD1TXYzeE)cZWEOJHJBBh3fMHHeSaSC51gl2Ead4GhgqQSXKx)WWlkji8MgbYjrxqmjojPRFt3yibIxX7djQhWsYVmmcrs6630ngsAejU5yhgAs(QKaosGg8jXpMepa8xswajaS8zDvs0jk5PrC72GcfDapQcqcT(nDJbh9uHG)CgbfVpOSkFwwDBqf)QkFf8NZiA9B6gt845XOhpWWddoAp3Kvb45ljiwIVPrGCsuC)qvs0jk5jjGNGJjbNGclymtc(EFijD9B6gdjEbtY(WfjPRFO)HHPrC72GcfDapQcqcT(nDJbh9ublalxETXQX8S5PZkFH1V2dmC0ckSGXCgMrqx2HblayGb4RO1ZDzJF1HHG)CgTEUlB8R(wPfamWa8v0ckSGXCEF4msTVErXJd9UqqbJfog6kcQA528Yr75MSkapF4kCN4BLb)5mIw)MUXepo07cbfCrzcW3VHJfiBHr0iUDBqHIoGhvbiHw)q)ddJJEQGfGLlV2y1yE280zLVW6x7bgoAbfwWyodZiOl7WGfamWa8v065USXV6WqWFoJwp3Ln(vFR0cagya(kAbfwWyoVpCgP2xVO4XHExiOavug8NZiA9B6gt8RQKTMwfXXUYEbTYeW6x7bgo2ykWXz06h6FyyLjaF)gowGSfgrJa5KOliMK01p0)WWKGV3hs8IeiEfVpKOEaljGJKEsc0GpKbtcalFwxLeDIsEsW37djqd(hjfROLeRJ2ij60GaKa)dvrKOtuYtIVKSpmjCbtcysY(WKarax7d0hjb)5KKEss6630ngsWd(g4cYwsMUXqcyojbuKGlKaosmmcrY6hgEr0iUDBqHIoGhvbiHw)q)ddJJEQqWFoJGI3hu2Ay)YyBudQ4xDy4vcO1VzFC0vZ2h2owzcy9R9adhBmf44mA9d9pm8WWRG)CgTEUlB84qVleuWTYG)CgTEUlB8Rom8k4pNXZXYf4JYZJl9c64XHExiOGXchdDfbvTCBE5O9CtwfGNpCvYs8TYG)CgphlxGpkppU0lOJF13VvI1V2dmCeT(nDJjJhuBE6gtgmNkrQSXKx)WWlkIw)MUXaLK9w5ReUFXtWHHJBhY4bxLHp2dd6cMVidr)TQkdpmGuzJjV(HHxueT(nDJbkj7nncKtIUGys0vaGcrsxKKcm(rcuBnTkIjXlysqowMe923yirxbaksMGJeCQtiPyLLgXTBdku0b8OkaPIXNdbGch9uHxb)5mYwtRI4mcy8lECO3fkjwrS9VCE7qEy4L9XpmmsbiO8y7JFy482HmuW97Hb7JFyyKcj7TsxnBFy7yAe3UnOqrhWJQaKECZmhcafo6PcVc(ZzKTMwfXzeW4x84qVlusSIy7F582H8WWl7JFyyKcqq5X2h)WW5TdzOG73dd2h)WWifs2BLUA2(W2X0iUDBqHIoGhvbin)gtoeakC0tfEf8NZiBnTkIZiGXV4XHExOKyfX2)Y5TdzLVSaGbgGVIwp3LnECO3fkjCN4WGfamWa8v0ckSGXCEF4msTVErXJd9UqjH7eFpm8Y(4hggPaeuES9XpmCE7qgk4(9WG9XpmmsHK9wPRMTpSDmncKtIUGysGibqnjGIeCQ4OrC72GcfDapQcqcVFxdUmyMzZVyAeiNeC6g734lJib)dVp8rYci5Jyssx)M9XK0fjPaJFKG)PTpK0is8LeCtY6hgErJQpjtWrcJLpOjbcjIRij0rlFqtc4ibxijD9d9pmmjqDOkapFHCTKGw3ogrJ42Tbfk6aEufGew)ApWW4O8qwb063Spo3vgbm(HdSU5ZkGuzJjV(HHxueT(n7JtcxgDAaG7vOJw(GoJ1nFgQQFIjIRGqIVhDAaG7vWFoJO1p0)WWzoufGNVqU2mcy8lIw3ogxHlVPrGCs0fetce557djDrskW4hjqT10QiMeWrspjPaKKU(n7JjbFBmKm7LKUwaj4uNqsXkljEbDi4yAe3UnOqrhWJQaKWF((GJEQWl2AAvehn)YVCXkAhgyRPvrC0lOZfROvjw)ApWWXgLTg2XYVv(A9ddVXTd58cYWnNeUmmWwtRI4O5x(L7kdHHHzJ5zZhh6DHGI(j(Eyi4pNr2AAveNraJFXJd9UqqXTBdQiA9B2hhzfX2)Y5TdzLb)5mYwtRI4mcy8l(vhgyRPvrCSRmcy8tzcy9R9adhrRFZ(4CxzeW43WqWFoJwp3LnECO3fckUDBqfrRFZ(4iRi2(xoVDiRmbS(1EGHJnkBnSJLvg8NZO1ZDzJhh6DHGcRi2(xoVDiRm4pNrRN7Yg)Qddb)5mEowUaFuEECPxqh)QkrQSXKFC0YjLyeQO8fsLnM86hgErqrHKnmKW6gU2ic8nzWmVpCEcogTrU8add)EyibS(1EGHJnkBnSJLvg8NZO1ZDzJhh6DHsIveB)lN3oKPrGCs0fets663SpMKEssxKKC)YpsGARPvrmoiPlssbg)ibQTMwfXKaksWLrjz9ddVisahjlGe1dyjjfy8JeO2AAvetJ42Tbfk6aEufGeA9B2htJa5KO3CJzFUpnIB3guOOd4rvas3VYUDBqLnnAXr5HSct3y2N7tJqJa5KO3oU0lOjbFVpKGtDcjfRS0iUDBqHIbaFv4CSCb(O884sVGgh9uHG)CgTEUlB84qVlus6JBAeiNeC(W2Xis6jj7dtIEa6uhKyVEjj4pNK0iskWsYxLKj4iX4lFK8rmnIB3guOyaW3rvasy9R9adJJYdzfSxVfy)Q4aRB(Scje8NZyGB8YYzWm7gtEF6cdkx((po(vvMqWFoJbUXllNbZSBm59PlmOSFwV44xLgbYjrxqmj6e2v3gltskE)cjb)dxK4ljggHizF8IeCHe9a0PoibTUDmIeVGjzbKC88y0djojqrbiqcAD7ysCejgFzsCejQaeQdmmjGJKTdzs6LeeGKEjXVRXYisGi8Jws85YhjojjBusqRBhtcRi1(yenIB3guOyaW3rvasoSRUnwoJW7xioSqBnCE9ddVif0hh9uHG)CgdCJxwodMz3yY7txyq5Y3)Xr062Xqbxug8NZyGB8YYzWm7gtEF6cdk7N1loIw3ogk4IYxjad2Od7QBJLZi8(fMH9qhdh32oUlmktWTBdQOd7QBJLZi8(fMH9qhdh7kpnnMNv5ReGbB0HD1TXYzeE)cZpSBIBBh3fMHbyWgDyxDBSCgH3VW8d7M4XHExOKs27HbyWgDyxDBSCgH3VWmSh6y4iAD7yOKmLWGn6WU62y5mcVFHzyp0XWXJd9Uqqb3kHbB0HD1TXYzeE)cZWEOJHJBBh3fM30iqoj6cIjbNGclymtc(EFibN6eskwzjb)dxKOcqOoWWK4fmjG9Hp8nIjbFVpK4KOhGo1bjb)5Ke8pCrcmJGUSDHHgXTBdkuma47OkajlOWcgZ59HZi1(6fHJEQWlS(1EGHJwqHfmMZWmc6YQmblayGb4RO1ZDzJh7Wqpme8NZO1ZDzJF13kFf8NZyGB8YYzWm7gtEF6cdkx((poIw3owbCpme8NZyGB8YYzWm7gtEF6cdk7N1loIw3owbC)EyiaGqkNnMNnFCO3fck6NincKtIEda1K4is2hMKzFOLemwys6IK9HjXjrpaDQdsW3fmapjGJe89(qY(WKare6R9IKG)Csc4ibFVpK4KGRhfXws0jSRUnwMKu8(fsIxWKG37LKj4ibN6eskwzjPNK0lj4b1ssatYxLehJ3fjb8eCmj7dtIfMKgrYSRg9WW0iUDBqHIbaFhvbin)h0zWmZMFX4ONk86vWFoJbUXllNbZSBm59PlmOC57)4iAD74KWLHHG)CgdCJxwodMz3yY7txyqz)SEXr062XjHlVv(c((nCSazlmAyWcagya(kA9Cx24XHExOKWDIddVSaSC51gRgZZMNoR0cagya(kAbfwWyoVpCgP2xVO4XHExOKWDIVF)Ey4fmyJoSRUnwoJW7xyg2dDmC84qVlus4ALwaWadWxrRN7Ygpo07cLK(jQ0cWYLxBSy7bmGd(9WqaaHu21YNkW4ldNNnMNnFCO3fck46HHxwawU8AJJH(AVug8NZ44UGpgoZHQa88fY1g)QVPrGCsWPxw2qs66NbCWKGV3hsCskgpj6bOtDqsWFojXlysWPoHKIvwsAubzljEa4VKSascys(igMgXTBdkuma47OkajRxw2Kd(ZjokpKvaT(zahmo6PcVc(ZzmWnEz5myMDJjVpDHbLlF)hhpo07cLeUeX9WqWFoJbUXllNbZSBm59PlmOSFwV44XHExOKWLiUFR8LfamWa8v065USXJd9UqjP4hgEzbadmaFf5qvaE(YbGcoECO3fkjfVYec(ZzCCxWhdN5qvaE(c5AZCXhMwV44xvPfGLlV24yOV2R3Vv6O9CtwfGNVKuizjsJa5KO4(HQKKU(H(hggrc(EFiXjrpaDQdsc(Zjjb)LKcSKG)HlsubatxyizcosWPoHKIvwsahjqe7c(yyssv7RxenIB3guOyaW3rvasO1VPBm4ONkSUHRnIw2y8ldF9CJC5bggwjI3TlmOicyaz4RNRYG)CgrRFt3yIWa8fncKtII7hQss66h6Fyyej479HK9Hjja4ljb)5KKG)ssbwsW)WfjQaGPlmKmbhjwNeWrchQcWZhjbGcMgXTBdkuma47Okaj06h6FyyC0tfsaRFThy4O96Ta7xv5llalxETXQX8S5PZddwaWadWxrRN7Ygpo07cLKIFyibS(1EGHJw4SfuW92GszcwawU8AJJH(AVggEzbadmaFf5qvaE(YbGcoECO3fkjfVYec(ZzCCxWhdN5qvaE(c5AZCXhMwV44xvPfGLlV24yOV2R3Vv(kbyWgN)d6myMzZV4422XDHzyiblayGb4RO1ZDzJh7WqpmKGfamWa8v0ckSGXCEF4msTVErXJDyOFtJa5KO4(HQKKU(H(hggrsapbhtcobfwWyMgXTBdkuma47Okaj06h6FyyC0tfEzbadmaFfTGclymN3hoJu7Rxu84qVleuWTYeGVFdhlq2cJu(cRFThy4OfuybJ5mmJGUSddwaWadWxrRN7Ygpo07cbfC)wjw)ApWWrlC2ck4EBq9wzcWGno)h0zWmZMFXXTTJ7cJslalxETXQX8S5PZkta((nCSazlmsjBnTkIJDL9cAAeiNefhOGSLeyWsc8)6cdj7dtcxWKaMKOR6y5c8rKO3oU0lOXbjW)RlmKmUl4JHjHdvb45lKRLeWrsxKSpmjghTKGXctcysIxKa1wtRIyAe3UnOqXaGVJQaKW6x7bgghLhYkad28Xq0FFCixlchyDZNv4vWFoJNJLlWhLNhx6f0XJd9UqjH7HHec(Zz8CSCb(O884sVGo(vFR8vWFoJJ7c(y4mhQcWZxixBMl(W06fhpo07cbfmw4yORO3kFf8NZiBnTkIZiGXV4XHExOKWyHJHUIggc(ZzKTMwfXzZV8lECO3fkjmw4yORO30iUDBqHIbaFhvbiH(1SpghwOTgoV(HHxKc6JJEQWXZJrpEGHvU(HH342HCEbz4MtsFOIsxnBFy7yLy9R9adhHbB(yi6VpoKRfrJ42Tbfkga8DufGuiauZ(yCyH2A486hgErkOpo6Pchppg94bgw56hgEJBhY5fKHBoj9twe3kD1S9HTJvI1V2dmCegS5JHO)(4qUwenIB3guOyaW3rvasOLng)YtJFmoSqBnCE9ddVif0hh9uHJNhJE8adRC9ddVXTd58cYWnNK(qLrpo07cP0vZ2h2owjw)ApWWryWMpgI(7Jd5Ar0iqoj6nGUjbuKyHjbFVpG)sI1vv7cdnIB3guOyaW3rvastWz5myMlF)hJJEQGRMTpSDmncKtcuhQcWZhj6buWKG)Hls8aWFjzbKW1YhjojfJNe9a0PoibFxWa8K4fmjihltYeCKGtDcjfRS0iUDBqHIbaFhvbiXHQa88Ldafmo6PcVyRPvrC08l)YfRODyGTMwfXreW4xUyfTddS10Qio6f05Iv0ome8NZyGB8YYzWm7gtEF6cdkx((poECO3fkjCjI7HHG)CgdCJxwodMz3yY7txyqz)SEXXJd9UqjHlrCpm4O9CtwfGNVKGyjQ0cagya(kA9Cx24Xom0kta((nCSazlm6TYxwaWadWxrRN7Ygpo07cLuYsCyWcagya(kA9Cx24Xom0VhgcaiKYUw(ubgFz48SX8S5Jd9Uqqr)ePrGCs0BaOMKRX8SKeWtWXK8rDHHeCQtAe3UnOqXaGVJQaKM)d6myMzZVyC0tfSaGbgGVIwp3LnESddTsS(1EGHJw4SfuW92Gs5lhTNBYQa88LeelrLjyby5YRnwnMNnpDEyWcWYLxBSAmpBE6SshTNBYQa88bfCjX3kFLGfGLlV2y1yE2805HblayGb4ROfuybJ58(WzKAF9IIh7Wq)wzcW3VHJfiBHr0iqoj4uNqsXklj4F4IeFjbIL4OKOtuYtYlWza45JK9XlsWLejrNOKNe89(qcobfwWy(nj479b8xsmauxyiz7qMKUirpgaa28rljEbtIPlMKVkj479HeCckSGXmj9KKEjbVJibMrqxwgMgXTBdkuma47OkajlBy02Uj7MgtfY1IJEQqcW3VHJfiBHrkX6x7bgoAHZwqb3BdkLVE5O9CtwfGNVKGyjQ8vWFoJJ7c(y4mhQcWZxixBMl(W06fh)Qddjyby5YRnog6R969WqWFoJbgaa28rB8RQm4pNXadaaB(OnECO3fckqiXrFzbf8V3O6X2gXz30yQqU242HCgRB(873ddbaeszxlFQaJVmCE2yE28XHExiOaHeh9LfuW)EJQhBBeNDtJPc5AJBhYzSU5ZVhgSaSC51gRgZZMNo)w5ReSaSC51gRgZZMNopm8Yr75MSkapFqbxsCyagSX5)GodMz28loUTDCxyER8fw)ApWWrlOWcgZzygbDzhgSaGbgGVIwqHfmMZ7dNrQ91lkESdd9730iUDBqHIbaFhvbi1L1VY3gu4ONkKa89B4ybYwyKsS(1EGHJw4SfuW92Gs5RxoAp3Kvb45ljiwIkFf8NZ44UGpgoZHQa88fY1M5IpmTEXXV6WqcwawU8AJJH(AVEpme8NZyGbaGnF0g)Qkd(ZzmWaaWMpAJhh6DHGsYsC0xwqb)7nQESTrC2nnMkKRnUDiNX6Mp)(9WqaaHu21YNkW4ldNNnMNnFCO3fckjlXrFzbf8V3O6X2gXz30yQqU242HCgRB(87HblalxETXQX8S5PZVv(kblalxETXQX8S5PZddVC0EUjRcWZhuWLehgGbBC(pOZGzMn)IJBBh3fM3kFH1V2dmC0ckSGXCgMrqx2HblayGb4ROfuybJ58(WzKAF9IIh7Wq)(nncKtcuJ2o0xgrYdapjHF7dj6eL8K4htcgVlgMev(ibXwqbtJ42Tbfkga8DufGew)ApWW4O8qwbhPM88LYwCG1nFwb2AAveh7kB(LFqvCnUYTBdQiA9B2hhzfX2)Y5Td5rtGTMwfXXUYMF5hu9fuz01nCTre4BYGzEF48eCmAJC5bgggQMS34k3UnOI4pFFISIy7F582H8OjgHaUcPYgt(XrltJa5KO4(HQKKU(H(hggrc(hUizFysMnMNLKgrIha(ljlGeUGXbjZJl9cAsAejEa4VKSas4cghKan4tIFmj(scelXrjrNOKNKUiXlsGARPvrmoibN6eskwzjX4OfrIxG9HpsW1JIylIeWrc0Gpj4bFdmjaS8zDvscbhtY(4fj0G(jsIorjpj4F4IeObFsWd(g4cYwssx)q)ddtsbWtJ42Tbfkga8DufGeA9d9pmmo6PcVcaiKYUw(ubgFz48SX8S5Jd9UqqbxggEf8NZ45y5c8r55XLEbD84qVleuWyHJHUIGQwUnVC0EUjRcWZhUkzj(wzWFoJNJLlWhLNhx6f0XV673ddVC0EUjRcWZ3Oy9R9adhDKAYZxkBHQb)5mYwtRI4mcy8lECO3fAuyWgN)d6myMzZV4422XO8XHExqvieXDs6RFIddoAp3Kvb45BuS(1EGHJosn55lLTq1G)CgzRPvrC28l)Ihh6DHgfgSX5)GodMz28loUTDmkFCO3fufcrCNK(6N4BLS10Qio2v2lOv(kHG)CgTEUlB8RomKW6gU2iA9Zao4ixEGHHFR81ReSaGbgGVIwp3Ln(vhgSaSC51ghd91EPmblayGb4RihQcWZxoauWXV67HblalxETXQX8S5PZVv(kblalxETrSCTpqFddje8NZO1ZDzJF1HbhTNBYQa88LeelX3ddVw3W1grRFgWbh5YdmmSYG)CgTEUlB8RQ8vWFoJO1pd4GJO1TJHsYggC0EUjRcWZxsqSeF)Eyi4pNrRN7Yg)Qkti4pNXZXYf4JYZJl9c64xvzcRB4AJO1pd4GJC5bggMgbYjrxqmj6kaqHiPlssUF5hjqT10QiMeVGjb5yzsG43nZr1BFJHeDfaOizcosWPoHKIvwAe3UnOqXaGVJQaKkgFoeakC0tfEf8NZiBnTkIZMF5x84qVlusSIy7F582H8WWl7JFyyKcqq5X2h)WW5TdzOG73dd2h)WWifs2BLUA2(W2X0iUDBqHIbaFhvbi94MzoeakC0tfEf8NZiBnTkIZMF5x84qVlusSIy7F582HSYxwaWadWxrRN7Ygpo07cLeUtCyWcagya(kAbfwWyoVpCgP2xVO4XHExOKWDIVhgEzF8ddJuackp2(4hgoVDidfC)EyW(4hggPqYER0vZ2h2oMgXTBdkuma47OkaP53yYHaqHJEQWRG)CgzRPvrC28l)Ihh6DHsIveB)lN3oKv(Ycagya(kA9Cx24XHExOKWDIddwaWadWxrlOWcgZ59HZi1(6ffpo07cLeUt89WWl7JFyyKcqq5X2h)WW5TdzOG73dd2h)WWifs2BLUA2(W2X0iqojqKaOMeqrIfMgXTBdkuma47Okaj8(Dn4YGzMn)IPrGCs0fets663SpMKfqI6bSKKcm(rcuBnTkIjbCKG)Hls6IeqzGMKK7x(rcuBnTkIjXlys(iMeisautI6bSis6jjDrsY9l)ibQTMwfX0iUDBqHIbaFhvbiHw)M9X4ONkWwtRI4yxzZV8ByGTMwfXreW4xUyfTddS10Qio6f05Iv0ome8NZiE)UgCzWmZMFXXVQYG)CgzRPvrC28l)IF1HHxb)5mA9Cx24XHExiO42Tbve)57tKveB)lN3oKvg8NZO1ZDzJF130iUDBqHIbaFhvbiH)89HgXTBdkuma47OkaP7xz3UnOYMgT4O8qwHPBm7Z9PrOrGCssx)q)ddtYeCKecWYHCTK8ldJqK8rDHHe9a0PoOrC72GcfNUXSp3xb06h6FyyC0tfs4(fpbhgog4gVSCgmZUXK3NUWGIme93QQmmncKtcoD0sY(WKadwsW37dj7dtsiaTKSDitYciXHHj5xBBizFyscDfrc8)8TbfjnIKNEJKK(RzFmjhh6DHij8B2w10mmjlGKqFTpKeca1SpMe4)5BdkAe3UnOqXPBm7Z9hvbiH(1SpghwOTgoV(HHxKc6JJEQamyJHaqn7JJhh6DHs64qVleufcqaxPpUMgXTBdkuC6gZ(C)rvasHaqn7JPrOrGCs0fetY(WKarax7d0hj479HeNeCQtiPyLLK9XxsAubzljZdessY)ni)OrC72GcfrRcNJLlWhLNhx6f04ONke8NZO1ZDzJhh6DHssFCtJa5KOliMK01p0)WWKSasgZSkjFvs2hMef3XEyqxW8rsWFojPNK0lj4bFdmjSIu7JjjGNGJjz2vJE6cdj7dtsXkAjX6OLeWrYcib(hQssapbhtcobfwWyMgXTBdkueTJQaKqRFO)HHXrpv4(fpbhgoUDiJhCvg(ypmOly(Ime93QQmSYxS10Qio2v2lOvMWRxb)5mUDiJhCvg(ypmOly(Ihh6DHsYTBdQi(Z3NiRi2(xoVDipAIr9v(ITMwfXXUYbG9zyGTMwfXXUYiGXVHb2AAvehn)YVCXkAFpme8NZ42HmEWvz4J9WGUG5lECO3fkj3UnOIO1VzFCKveB)lN3oKhnXO(kFXwtRI4yxzZV8ByGTMwfXreW4xUyfTddS10Qio6f05Iv0((9Wqcb)5mUDiJhCvg(ypmOly(IF13ddVc(Zz065USXV6Waw)ApWWrlOWcgZzygbDzFR0cagya(kAbfwWyoVpCgP2xVO4Xom0kTaSC51gRgZZMNo)w5ReSaSC51ghd91EnmybadmaFf5qvaE(YbGcoECO3fkjC9BLVc(Zz065USXV6WqcwaWadWxrRN7Ygp2HH(nncKtIUGys0jSRUnwMKu8(fsc(hUizF4JjPrKuasC72yzsq49lehK4ism(YK4isubiuhyysafji8(fsc(EFibcKaosMmE(ibTUDmIeWrcOiXjjzJsccVFHKGaKSp(sY(WKumEsq49lKe)UglJibIWpAjXNlFKSp(sccVFHKWksTpgrJ42TbfkI2rvasoSRUnwoJW7xioSqBnCE9ddVif0hh9uHeGbB0HD1TXYzeE)cZWEOJHJBBh3fgLj42Tbv0HD1TXYzeE)cZWEOJHJDLNMgZZQ8vcWGn6WU62y5mcVFH5h2nXTTJ7cZWamyJoSRUnwoJW7xy(HDt84qVlus4(9WamyJoSRUnwoJW7xyg2dDmCeTUDmusMsyWgDyxDBSCgH3VWmSh6y44XHExiOKmLWGn6WU62y5mcVFHzyp0XWXTTJ7cdncKtIUGyej4euybJzs6jj4uNqsXkljnIKVkjGJeObFs8JjbMrqx2UWqco1jKuSYsc(EFibNGclymtIxWKan4tIFmjbSbGNeCjrs0jk5PrC72Gcfr7OkajlOWcgZ59HZi1(6fHJEQqcW3VHJfiBHrkF9cRFThy4OfuybJ5mmJGUSktWcagya(kA9Cx24Xom0kt4(fpbhgoQEDi4GB3K9Z6vBZQFdYVHHG)CgTEUlB8R(wPJ2ZnzvaE(GcUKOYxb)5mYwtRI4S5x(fpo07cLK(jome8NZiBnTkIZiGXV4XHExOK0pX3ddbaes5SX8S5Jd9Uqqr)eFtJa5KGtqb3BdksMGJe3yibgSis2hFjj0hZisq)JjzFyOjXpUGSLKJNhJEyysW)Wfj6QowUaFej6TJl9cAsECejggHizF8IeCtcITisoo07QlmKaos2hMKXqFTxKe8NtsAejEa4VKSasMUXqcyojbCK4f0Ka1wtRIysAejEa4VKSasyfP2htJ42TbfkI2rvasy9R9adJJYdzfGbB(yi6VpoKRfHdSU5Zk8k4pNXZXYf4JYZJl9c64XHExOKW9Wqcb)5mEowUaFuEECPxqh)QVv(k4pNXXDbFmCMdvb45lKRnZfFyA9IJhh6DHGcglCm0v0BLVc(ZzKTMwfXzeW4x84qVlusySWXqxrddb)5mYwtRI4S5x(fpo07cLeglCm0v0BAe3UnOqr0oQcqkeaQzFmoSqBnCE9ddVif0hh9uHJNhJE8adRC9ddVXTd58cYWnNK(qq5lxnBFy7yLy9R9adhHbB(yi6VpoKRf9MgXTBdkueTJQaKq)A2hJdl0wdNx)WWlsb9Xrpv445XOhpWWkx)WWBC7qoVGmCZjPpeu(YvZ2h2owjw)ApWWryWMpgI(7Jd5ArVPrC72Gcfr7Okaj0YgJF5PXpghwOTgoV(HHxKc6JJEQWXZJrpEGHvU(HH342HCEbz4MtsFOIYxUA2(W2XkX6x7bgocd28Xq0FFCixl6nncKtIUGys0BaDtcOiXctc(EFa)LeRRQ2fgAe3UnOqr0oQcqAcolNbZC57)yC0tfC1S9HTJPrGCs0fetceXUGpgMKu1(6frc(EFiXlOjXakmKWf4J5HeJJ2UWqcuBnTkIjXlys2dAswajMUys6LKVkj479HKK)Bq(rIxWKGtDcjfRS0iUDBqHIODufGehQcWZxoauW4ONk86vWFoJS10QioJag)Ihh6DHss)ehgc(ZzKTMwfXzZV8lECO3fkj9t8TslayGb4RO1ZDzJhh6DHskzjQ8vWFoJQxhco42nz)SE12S63G8lI1nFgkqaxsCyiH7x8eCy4O61HGdUDt2pRxTnR(ni)Ime93QQm873ddb)5mQEDi4GB3K9Z6vBZQFdYViw385Kuack(ehgSaGbgGVIwp3LnESddTshTNBYQa88LeelrAeiNeDbXKGtDcjfRSKGV3hsWjOWcgZqcIyxWhdtsQAF9IiXlysGbfKTKaWYh(RxMKK)Bq(rc4ib)dxKOhdaaB(OLe8GVbMewrQ9XKeWtWXKGtDcjfRSKWksTpgrJ42TbfkI2rvasw2WOTDt2nnMkKRfh9uHeGVFdhlq2cJuI1V2dmC0cNTGcU3gukF5O9CtwfGNVKGyjQ8vWFoJJ7c(y4mhQcWZxixBMl(W06fh)Qddjyby5YRnog6R969WGfGLlV2y1yE2805HHG)CgdmaaS5J24xvzWFoJbgaa28rB84qVleuGqIJ(6fedQE)INGddhvVoeCWTBY(z9QTz1Vb5xKHO)wvLHFp6llOG)9gvp22io7MgtfY1g3oKZyDZNF)(TYec(Zz065USXVQYxjyby5YRnwnMNnpDEyWcagya(kAbfwWyoVpCgP2xVO4xDyiaGqk7A5tfy8LHZZgZZMpo07cbflayGb4ROfuybJ58(WzKAF9IIhh6DHgfQmm01YNkW4ldNNnMNnFCO3fcxHR0hxNiuGqIJ(Yck4FVr1JTnIZUPXuHCTXTd5mw3853VPrC72Gcfr7OkaPUS(v(2Gch9uHeGVFdhlq2cJuI1V2dmC0cNTGcU3gukF5O9CtwfGNVKGyjQ8vWFoJJ7c(y4mhQcWZxixBMl(W06fh)Qddjyby5YRnog6R969WGfGLlV2y1yE2805HHG)CgdmaaS5J24xvzWFoJbgaa28rB84qVleuswIJ(6fedQE)INGddhvVoeCWTBY(z9QTz1Vb5xKHO)wvLHFp6llOG)9gvp22io7MgtfY1g3oKZyDZNF)(TYec(Zz065USXVQYxjyby5YRnwnMNnpDEyWcagya(kAbfwWyoVpCgP2xVO4xDyiaGqk7A5tfy8LHZZgZZMpo07cbflayGb4ROfuybJ58(WzKAF9IIhh6DHgfQmm01YNkW4ldNNnMNnFCO3fcxHR0hxNiuswIJ(Yck4FVr1JTnIZUPXuHCTXTd5mw3853VPrGCsGiWV2dmmjFedtcOiXdAtVnJizF8Le8ETKSascysqowgMKj4ibN6eskwzjbbizF8LK9HHMe)4AjbVJwgMeic)OLKaEcoMK9HdPrC72Gcfr7OkajS(1EGHXr5HScihlNNGlB9CxwCG1nFwHeSaGbgGVIwp3LnESdd9Wqcy9R9adhTGclymNHze0LvPfGLlV2y1yE2805Hb473WXcKTWiAeiNeDbXis0BaOMKEssxK4fjqT10QiMeVGjzVMrKSasmDXK0ljFvsW37djj)3G8dhKGtDcjfRSK4fmj6e2v3gltskE)cPrC72Gcfr7OkaP5)GodMz28lgh9ub2AAveh7k7f0kD1S9HTJvg8NZO61HGdUDt2pRxTnR(ni)IyDZNHceWLev(cgSrh2v3glNr49lmd7HogoUTDCxyggsWcWYLxBSy7bmGd(TsS(1EGHJihlNNGlB9CxwAeiNeDbXKaXR49HK01VPBmKOEalIKEss6630ngsAubzljFvAe3UnOqr0oQcqcT(nDJbh9uHG)CgbfVpOSkFwwDBqf)Qkd(ZzeT(nDJjE88y0JhyyAe3UnOqr0oQcqY6LLn5G)CIJYdzfqRFgWbJJEQqWFoJO1pd4GJhh6DHGcUv(k4pNr2AAveNraJFXJd9UqjH7HHG)CgzRPvrC28l)Ihh6DHsc3Vv6O9CtwfGNVKGyjsJa5KO4(HQis0jk5jjGNGJjbNGclymtYh1fgs2hMeCckSGXmjwqb3Bdkswaj2h2oMKEscobfwWyMKgrIB3VBmqtIha(ljlGKaMeRJwAe3UnOqr0oQcqcT(nDJbh9uH1nCTr0YgJFz4RNBKlpWWWkr8UDHbfradidF9Cvg8NZiA9B6gtegGVOrGCsuC)qvejosLKaEcoMeCckSGXmjFuxyizFysWjOWcgZKybfCVnOizbKyFy7ys6jj4euybJzsAejUD)UXanjEa4VKSascysSoAPrC72Gcfr7Okaj06h6FyyC0tfSaSC51gRgZZMNoReRFThy4OfuybJ5mmJGUSkTaGbgGVIwqHfmMZ7dNrQ91lkECO3fck4wzcW3VHJfiBHr0iqoj6cIjjD9B6gdj479HK0Lng)irXD9CjXlyskajPRFgWbJdsW)WfjfGK01VPBmK0is(Q4GeObFs8JjPlssUF5hjqT10QiMeWrYcir9awss(Vb5hj4F4IepaGLjbILij6eL8KaosCyvFBSmji8(fsYJJibxpkITisoo07QlmKaosAejDrY00yEwAe3UnOqr0oQcqcT(nDJbh9uH1nCTr0YgJFz4RNBKlpWWWktyDdxBeT(zahCKlpWWWkd(ZzeT(nDJjE88y0JhyyLVc(ZzKTMwfXzZV8lECO3fkjOIs2AAveh7kB(LFkd(Zzu96qWb3Uj7N1R2Mv)gKFrSU5Zqbc4oXHHG)CgvVoeCWTBY(z9QTz1Vb5xeRB(CskabCNOshTNBYQa88LeelXHbyWgDyxDBSCgH3VWmSh6y44XHExOKW1ddUDBqfDyxDBSCgH3VWmSh6y4yx5PPX8SVvMGfamWa8v065USXJDyOPrGCs0fets66h6FyysG4v8(qI6bSis8cMe4FOkj6eL8KG)HlsWPoHKIvwsahj7dtcebCTpqFKe8NtsAejEa4VKSasMUXqcyojbCKan4dzWKyDvs0jk5PrC72Gcfr7Okaj06h6FyyC0tfc(Zzeu8(GYwd7xgBJAqf)Qddb)5moUl4JHZCOkapFHCTzU4dtRxC8Rome8NZO1ZDzJFvLVc(Zz8CSCb(O884sVGoECO3fckySWXqxrqvl3MxoAp3Kvb45dxLSeFRm4pNXZXYf4JYZJl9c64xDyiHG)CgphlxGpkppU0lOJFvLjybadmaFfphlxGpkppU0lOJh7WqpmKGfGLlV2iwU2hOV3ddoAp3Kvb45ljiwIkzRPvrCSRSxqtJa5KOJdAswajH(yMK9HjjGrljGjjPRFgWbtsa0KGw3oUlmK0ljFvsGO)2o2anjDrIxqtcuBnTkIjj4VKK8FdYpsAuTK4bG)sYcijGjr9awldtJ42TbfkI2rvasO1p0)WW4ONkSUHRnIw)mGdoYLhyyyLjC)INGddh3oKXdUkdFShg0fmFrgI(Bvvgw5RG)CgrRFgWbh)QddoAp3Kvb45ljiwIVvg8NZiA9Zao4iAD7yOKmLVc(ZzKTMwfXzeW4x8Rome8NZiBnTkIZMF5x8R(wzWFoJQxhco42nz)SE12S63G8lI1nFgkqqXNOYxwaWadWxrRN7Ygpo07cLK(jomKaw)ApWWrlOWcgZzygbDzvAby5YRnwnMNnpD(nncKtII7hQss66h6Fyys6IeNef)Oi2sskW4hjqT10QighKadkiBjXWlj9sI6bSKK8FdYpsETp(ssJi5Xlyddtsa0KW9(Whj7dts6630ngsmDXKaos2hMeDIs(KGyjsIPlMKj4ijD9d9pm8BCqcmOGSLeaw(WF9YK4fjq8kEFir9aws8cMedVKSpmjEaaltIPlMKhVGnmjPRFgWbtJ42TbfkI2rvasO1p0)WW4ONkKW9lEcomCC7qgp4Qm8XEyqxW8fzi6VvvzyLVc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5Zqbck(ehgc(Zzu96qWb3Uj7N1R2Mv)gKFrSU5Zqbc4orLRB4AJOLng)YWxp3ixEGHHFRm4pNr2AAveNraJFXJd9UqjP4vYwtRI4yxzeW4NYec(Zzeu8(GYQ8zz1Tbv8RQmH1nCTr06NbCWrU8addR0cagya(kA9Cx24XHExOKu8kFzbadmaFfh3f8XWzKAF9IIhh6DHssXpmKGfGLlV24yOV2R30iqoj6cIjrxbakejDrsY9l)ibQTMwfXK4fmjihltce)UzoQE7BmKORaafjtWrco1jKuSYsIxWKarSl4JHjbQdvb45lKRLgXTBdkueTJQaKkgFoeakC0tfEf8NZiBnTkIZMF5x84qVlusSIy7F582H8WWl7JFyyKcqq5X2h)WW5TdzOG73dd2h)WWifs2BLUA2(W2XkX6x7bgoICSCEcUS1ZDzPrC72Gcfr7OkaPh3mZHaqHJEQWRG)CgzRPvrC28l)Ihh6DHsIveB)lN3oKvMGfGLlV24yOV2RHHxb)5moUl4JHZCOkapFHCTzU4dtRxC8RQ0cWYLxBCm0x717HHx2h)WWifGGYJTp(HHZBhYqb3VhgSp(HHrkKSHHG)CgTEUlB8R(wPRMTpSDSsS(1EGHJihlNNGlB9CxwAe3UnOqr0oQcqA(nMCiau4ONk8k4pNr2AAveNn)YV4XHExOKyfX2)Y5TdzLjyby5YRnog6R9Ay4vWFoJJ7c(y4mhQcWZxixBMl(W06fh)QkTaSC51ghd91E9Ey4L9XpmmsbiO8y7JFy482HmuW97Hb7JFyyKcjByi4pNrRN7Yg)QVv6Qz7dBhReRFThy4iYXY5j4Ywp3LLgbYjrxqmjqKaOMeqrIfMgXTBdkueTJQaKW731GldMz28lMgbYjrxqmjPRFZ(yswajQhWsskW4hjqT10QighKGtDcjfRSK84ismmcrY2Hmj7JxK4KarE((qcRi2(xMedpxsahjGYanjj3V8JeO2AAvetsJi5RsJ42TbfkI2rvasO1VzFmo6PcS10Qio2v28l)ggyRPvrCebm(Llwr7WaBnTkIJEbDUyfTddb)5mI3VRbxgmZS5xC8RQm4pNr2AAveNn)YV4xDy4vWFoJwp3LnECO3fckUDBqfXF((ezfX2)Y5TdzLb)5mA9Cx24x9nncKtIUGysGipFFibSp8HVrmj4FA7djnIKUijfy8JeO2AAveJdsWPoHKIvwsahjlGe1dyjj5(LFKa1wtRIyAe3UnOqr0oQcqc)57dncKtIEZnM95(0iUDBqHIODufG09RSB3guztJwCuEiRW0nM95(APiv2QPB9tecAR2QPba]] )


end