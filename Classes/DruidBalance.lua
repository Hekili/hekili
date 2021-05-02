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


    spec:RegisterPack( "Balance", 20210502, [[da1XQeqirWJaLQlrcjBIe9jqHgLsXPukTkqvPxbkAwqIUfjKAxc(fOKHjcDmkkltjPNPKOPrcX1GKSnqvX3iHkJJeQ6CGsX6OOQmpqvUhjyFIihKIKfsrLhcjmrkI4IGQQnsrv1hbLsLrckLQojjuwPiQxckGMPscUjfrYoPi1pbLszOkj0sPis9uLyQueUkfrTvqbWxbLsglOaTxk8xrnyIdt1IfYJP0Kb5YO2SQ8zimALQtl1QbfGETsQztQBlu7wYVbgojDCqbTCvEoutxX1vvBhI(oKA8qsDEqL1trvMViTFKnmZWeglq(WgME1ex1ServIRgmdvOcvgldCQSXIQBx7iyJLYJzJfZ5AVSSXIQdNg4qgMWybd(NLnw2NrfB(GfSq0Z(pkybXWc3XFTpnOSN)gyH7ylSmwI(TEuSYiYybYh2W0RM4QMLiQsC1GzOcvksIkIXI)NDWzSS0XOWyzVHG4YiYybIXwJfZ5AVSmjMK73quYMuoCKSkkjz1ex1mkzkzuS7fcgB(OKv0KykiigIKfG2psmh7XbkzfnjOy3lemejJFi4j3psSoMXKmasSWz1CE8dbp4aLSIMetAogGKHi5xfBzm2p4ibPFThPzmjB6ahqjjQhJmJh)W)dbtIIojsupgzap(H)hcEBGswrtIPqcAisup264PleKaBD(Sts)iPhyetYSZKG(afcsGFRUvXCGswrtIjLVMjbfGcjyntYSZKSO2xpysCs09mAMKyWXK80mQ7intYM(rcCGpj7oubJdj79qspKG74VE8IbFSgosq3ZojMd2MPmbjWKeuWAgpTRjXu6grfZ1Gss6bgHibVUv3gOKv0Kys5RzsIb4Hey81i2N8XXExyyKeSLl)AaMexvvdhjdGKiagtYRrSpysaLgUGXIUXd2Weglq8Z)6XWegM2mdtyS42PbLXcgO9lhXESXcxEKMHmmNXyy6vnmHXcxEKMHmmNXcq1ybZJXIBNgugli9R9inBSG01F2ybRYADE8dbp4aE875AnjjrIzKOKKnKKajJR5Ac4Xpn4GcC5rAgIK0usgxZ1eWdR1(LHU(nbU8indrYwsstjbRYADE8dbp4aE875AnjjrYQglqm2ET60GYyzHhmjMca)KakswjmjbDp7G)qc01VHeVGibDp7KSm(PbhejEbrYQWKeWSZh6gZgli9lxEmBS04SdyJXW0R0WeglC5rAgYWCglavJfmpglUDAqzSG0V2J0SXcsx)zJfSkR15Xpe8Gd4XVxFmjjrIzglqm2ET60GYyzHhmjwn7izsqVZfjlJFV(ysSErYEpKSkmjz8dbpysqV32DsAmjhRzKEnK8ahjZotc8B1TkMjzaKeXKOE8JVJHiXlisqV32DsETwZhjdGeRJhJfK(LlpMnwAC2QzhjBmgMwrmmHXcxEKMHmmNXIBNguglr8H5BDximwGyS9A1PbLXIjJzsmhFy(w3fcsq3ZojOWuWsXkljGJe)n8rckafsWAMKUibfMcwkwznwSxp81UXYgssGelajxEnHQrSp5NZKKMsscKybaneaDfSGcjynNNDoJv7RhC4RsYwsuss0)9cwp3LnCCS3fMKKiXmuzmgMgvgMWyHlpsZqgMZyXE9Wx7glr)3ly9Cx2WXXExyssIeZqfjPPKebWysusYRrSp5JJ9UWKapswfvglqm2ET60GYyzfbdjO7zNeNeuykyPyLLKz3hsACbJdjojR4xJ9Je1dyjbCKGENlsMDMKxJyFiPXK4rG)qYaiHliJf3onOmwubtdkJXW0WhdtySWLhPzidZzSaunwW8yS42PbLXcs)ApsZgliD9NnwSCRjzdjBiPRHpvG2hgk)Ae7t(4yVlmjkAsmdvKOOjXcaAia6ky9Cx2WXXExys2scSiXmfFIKSLefiXYTMKnKSHKUg(ubAFyO8RrSp5JJ9UWKOOjXmurIIMeZwnrsu0KybaneaDfSGcjynNNDoJv7RhC44yVlmjBjbwKyMIprs2sIsssGKZBOmJKRj4qq4aJ6gpysstjXcaAia6ky9Cx2WXXExyssIKUg(ubAFyO8RrSp5JJ9UWKKMsIfa0qa0vWckKG1CE25mwTVEWHJJ9UWKKejDn8Pc0(Wq5xJyFYhh7DHjrrtIzjssAkjjqIfGKlVMq1i2N8ZzsstjXTtdQGfuibR58SZzSAF9Gdqn2J0mKXceJTxRonOmwqHRTFTpmMe078SZhjFCxiibfGcjyntsbqtc6wRjX1AaAsGd8jzaKGNwRjX64HKzNjb7XmjEm4xdjGhjOauibRzyIctblfRSKyD8Gnwq6xU8y2yXckKG1CgIXWvwJXW0kodtySWLhPzidZzSaunwW8yS42PbLXcs)ApsZgliD9Nnw2qY4hcEcthZ5bKHAMKKiXmursAkjN3qzgjxtWHGWHUijjsqvIKSLeLKSHKnKKajmm83QQmuGJvH7yxNbhu5LLjjnLelaOHaORahRc3XUodoOYllhoo27ctc8iXm4tIKOKKeiXcaAia6kWXQWDSRZGdQ8YYHJDi4izljkjzdjBibPFThP5aOYFmNNRR18qIcKygjPPKG0V2J0Cau5pMZZ11AEirbswjjBjrjjBizUUwZtymlCSdbx2caAia6IK0usMRR18egZcwaqdbqxHJJ9UWKKejDn8Pc0(Wq5xJyFYhh7DHjrrtIzjsYwsstjbPFThP5aOYFmNNRR18qIcKSkjkjzdjZ11AEcZQHJDi4YwaqdbqxKKMsYCDTMNWSAWcaAia6kCCS3fMKKiPRHpvG2hgk)Ae7t(4yVlmjkAsmlrs2ssAkji9R9inhav(J58CDTMhsuGKejzljPPKybi5YRjSgUR9IKTglqm2ET60GYyXKXmejdGeiw7WrYSZK8XocMeWJeuykyPyLLe07CrYh3fcsGa)intcOi5Jzs8cIe1JrY1qYh7iysqVZfjErIdbrcJKRHKgtIhb(djdGeOMnwq6xU8y2yXcLTGcQNgugJHPv8gMWyHlpsZqgMZybIX2RvNguglMmMjb(JvH7yxtcSTdQ8YYKSAIy2IjjIFGJjXjbfMcwkwzj5J5GXs5XSXchRc3XUodoOYllBSyVE4RDJflaOHaORG1ZDzdhh7DHjbEKSAIKOKelaOHaORGfuibR58SZzSAF9Gdhh7DHjbEKSAIKKMsseaJjrjjVgX(Kpo27ctc8izLkoJf3onOmw4yv4o21zWbvEzzJXW0WgdtySWLhPzidZzSaXy71QtdkJftgZKSa(AnpDHGet6FeCKaFWSftse)ahtItckmfSuSYsYhZbJLYJzJfm4R18mDHiF)i4mwSxp81UXIfa0qa0vW65USHJJ9UWKapsGpKOKKeibPFThP5GfuibR5meJHRSKKMsIfa0qa0vWckKG1CE25mwTVEWHJJ9UWKapsGpKOKeK(1EKMdwqHeSMZqmgUYssAkjramMeLK8Ae7t(4yVlmjWJKvrLXIBNguglyWxR5z6cr((rWzmgM2SenmHXcxEKMHmmNXIBNguglDHT3F8inNHHFVMFCgIr2w2yXE9Wx7glr)3ly9Cx2WXXExyssIeZqLXs5XSXsxy79hpsZzy43R5hNHyKTLngdtBMzgMWyHlpsZqgMZyXTtdkJL56AnpMzSaXy71QtdkJftS3ysAmjojNp78rcR9iW5dtcAhosgajX(AMexRjbuK8Xmj4XhsMRR18GjzaKeXKO7IHi5Rsc6E2jbfMcwkwzjXlisqbOqcwZK4fejFmtYSZKSAbrcwdgsafjwis6hjrGzNK56Anpys8JjbuK8Xmj4XhsMRR18GnwSxp81UXcs)ApsZbqL)yopxxR5HefizvsusscKmxxR5jmRgo2HGlBbaneaDrsAkjBibPFThP5aOYFmNNRR18qIcKygjPPKG0V2J0Cau5pMZZ11AEirbswjjBjrjjBij6)EbRN7Yg(QKKMsIfa0qa0vW65USHJJ9UWKatswLKKizUUwZtymlybaneaDfG(NpnOirjjBijbsSaKC51eQgX(KFotsAkjjqcs)ApsZblOqcwZzigdxzjzljkjjbsSaKC51ewd31ErsAkjwasU8AcvJyFYpNjrjji9R9inhSGcjynNHymCLLeLKybaneaDfSGcjynNNDoJv7RhC4RsIsssGelaOHaORG1ZDzdFvsusYgs2qs0)9cSv3QyoR)LFHJJ9UWKKejMLijPPKe9FVaB1TkMZyG2VWXXExyssIeZsKKTKOKKei5(f)ahcoe5AVSCg8YUwNN9UqGdC5rAgIK0us2qs0)9crU2llNbVSR15zVle4C5Z)4aEC7AsuGeursAkjr)3le5AVSCg8YUwNN9UqGZ(z9Id4XTRjrbsqfjBjzljPPKe9FVW6UGogkZXQa08fZ1K5IpeT5XHVkjBjjnLKiagtIssEnI9jFCS3fMe4rYQjssAkji9R9inhav(J58CDTMhsuGKengdtB2QgMWyHlpsZqgMZyXE9Wx7gli9R9inhav(J58CDTMhssqbswLeLKKajZ11AEcJzHJDi4YwaqdbqxKKMscs)ApsZbqL)yopxxR5HefizvsusYgsI(VxW65USHVkjPPKybaneaDfSEUlB44yVlmjWKKvjjjsMRR18eMvdwaqdbqxbO)5tdksusYgssGelajxEnHQrSp5NZKKMsscKG0V2J0CWckKG1CgIXWvws2sIsssGelajxEnH1WDTxKKMsIfGKlVMq1i2N8Zzsuscs)ApsZblOqcwZzigdxzjrjjwaqdbqxblOqcwZ5zNZy1(6bh(QKOKKeiXcaAia6ky9Cx2WxLeLKSHKnKe9FVaB1TkMZ6F5x44yVlmjjrIzjssAkjr)3lWwDRI5mgO9lCCS3fMKKiXSejzljkjjbsUFXpWHGdrU2llNbVSR15zVle4axEKMHijnLKnKe9FVqKR9YYzWl7ADE27cbox(8poGh3UMefibvKKMss0)9crU2llNbVSR15zVle4SFwV4aEC7AsuGeurYws2sYwsstjj6)EH1DbDmuMJvbO5lMRjZfFiAZJdFvsstjjcGXKOKKxJyFYhh7DHjbEKSAIKKMscs)ApsZbqL)yopxxR5HefijrJf3onOmwMRR18SQXyyAZwPHjmw4YJ0mKH5mwC70GYy5J5CpCm2ybIX2RvNguglMmMXK4AnjGzNpsafjFmtspCmMeqrIfYyXE9Wx7glr)3ly9Cx2WxLK0usSaKC51eQgX(KFotIssq6x7rAoybfsWAodXy4kljkjXcaAia6kybfsWAop7CgR2xp4WxLeLKKajwaqdbqxbRN7Yg(QKOKKnKSHKO)7fyRUvXCw)l)chh7DHjjjsmlrsstjj6)Eb2QBvmNXaTFHJJ9UWKKejMLijBjrjjjqY9l(boeCiY1Ez5m4LDTop7DHah4YJ0mejPPKC)IFGdbhICTxwodEzxRZZExiWbU8indrIss2qs0)9crU2llNbVSR15zVle4C5Z)4aEC7AssIKvssAkjr)3le5AVSCg8YUwNN9UqGZ(z9Id4XTRjjjswjjBjzljPPKe9FVW6UGogkZXQa08fZ1K5IpeT5XHVkjPPKebWysusYRrSp5JJ9UWKapswnrJXW0MPigMWyHlpsZqgMZybIX2RvNguglMe22qmjUDAqrIUXdjroMHibuKG757tdkyPzen2yXTtdkJL7xz3onOY6gpgl45A7yyAZmwSxp81UXcs)ApsZHgNDaBSOB8KlpMnwCaBmgM2muzycJfU8indzyoJf71dFTBSC)IFGdbhICTxwodEzxRZZExiWbgg(BvvgYybpxBhdtBMXIBNgugl3VYUDAqL1nEmw0nEYLhZglraFmgdtBg8XWeglC5rAgYWCglUDAqzSC)k72Pbvw34Xyr34jxEmBSGhJXymwIa(yycdtBMHjmw4YJ0mKH5mwC70GYy5CKCb(4874Y8GZybIX2RvNguglM)JlZdosq3ZojOWuWsXkRXI96HV2nwI(VxW65USHJJ9UWKKejMHkJXW0RAycJfU8indzyoJfGQXcMhJf3onOmwq6x7rA2ybPR)SXscKe9FVqKR9YYzWl7ADE27cbox(8po8vjrjjjqs0)9crU2llNbVSR15zVle4SFwV4Wx1ybIX2RvNguglOyNTRXK0psMDMeZbmLjiXE9qs0)9iPXKuGHKVkjpWrI2h(i5JzJfK(LlpMnwSxpfy(QgJHPxPHjmw4YJ0mKH5mwC70GYyXHC1PrYzmA)InwSWz1CE8dbpydtBMXI96HV2nwI(VxiY1Ez5m4LDTop7DHaNlF(hhWJBxtc8irrirjjr)3le5AVSCg8YUwNN9UqGZ(z9Id4XTRjbEKOiKOKKnKKajqGj4qU60i5mgTFXzip2rWHPTR7cbjkjjbsC70Gk4qU60i5mgTFXzip2rWHUYpDJyFirjjBijbsGatWHC1PrYzmA)IZ7SRdtBx3fcsstjbcmbhYvNgjNXO9loVZUoCCS3fMKKizLKSLK0usGatWHC1PrYzmA)IZqESJGd4XTRjbEKSssusceycoKRonsoJr7xCgYJDeC44yVlmjWJeurIssGatWHC1PrYzmA)IZqESJGdtBx3fcs2ASaXy71QtdkJftgZKykixDAKmjlO9lMe07CrIpKOzmMKz3lsuesmhWuMGe8421ys8cIKbqYXVJX7K4KapfwLe8421K4ys0(WK4ysubyChPzsahjthZK0djyaj9qIFxJKXKad4hpK4VHpsCswjmjbpUDnjmQv7JXgJHPvedtySWLhPzidZzS42PbLXIfuibR58SZzSAF9GnwGyS9A1PbLXIjJzsqbOqcwZKGUNDsqHPGLIvwsqVZfjQamUJ0mjEbrcy25dDJzsq3ZojojMdyktqs0)9ib9oxKaXy4kBximwSxp81UXYgsq6x7rAoybfsWAodXy4kljkjjbsSaGgcGUcwp3LnCSdbhjPPKe9FVG1ZDzdFvs2sIss2qs0)9crU2llNbVSR15zVle4C5Z)4aEC7AsuGeursAkjr)3le5AVSCg8YUwNN9UqGZ(z9Id4XTRjrbsqfjBjjnLKiagtIssEnI9jFCS3fMe4rIzjAmgMgvgMWyHlpsZqgMZyXTtdkJL3)GldEzw)l2ybIX2RvNguglMFa8tIJjz2zsE9HhsqyHiPlsMDMeNeZbmLjibDxqa0Kaosq3ZojZotcmq4U2lsI(VhjGJe09StItIIhMy2sIPGC1PrYKSG2Vys8cIe0EpK8ahjOWuWsXklj9JKEibnOgsIys(QK4i8UijIFGJjz2zsSqK0ysED14DgYyXE9Wx7glBizdjr)3le5AVSCg8YUwNN9UqGZLp)Jd4XTRjjjsuesstjj6)EHix7LLZGx2168S3fcC2pRxCapUDnjjrIIqYwsusYgsGUFdfkq2cHjjnLelaOHaORG1ZDzdhh7DHjjjsqvIKKMsYgsSaKC51eQgX(KFotIssSaGgcGUcwqHeSMZZoNXQ91doCCS3fMKKibvjsYws2sYwsstjzdjqGj4qU60i5mgTFXzip2rWHJJ9UWKKejkEsusIfa0qa0vW65USHJJ9UWKKejMLijkjXcqYLxtOy7b0GdIKTKKMssxdFQaTpmu(1i2N8XXExysGhjkEsusscKybaneaDfSEUlB4yhcosstjzdjwasU8AcRH7AVirjjr)3lSUlOJHYCSkanFXCnHVkjBngdtdFmmHXcxEKMHmmNXIBNguglwVSSoh9FpJf71dFTBSSHKO)7fICTxwodEzxRZZExiW5YN)XHJJ9UWKKejksavKKMss0)9crU2llNbVSR15zVle4SFwV4WXXExyssIefjGks2sIss2qIfa0qa0vW65USHJJ9UWKKejkosstjzdjwaqdbqxbowfGMVCeOGchh7DHjjjsuCKOKKeij6)EH1DbDmuMJvbO5lMRjZfFiAZJdFvsusIfGKlVMWA4U2ls2sYwsusIJNZ1zvaA(ijjfizLjASe9FVC5XSXcE8tdoiJfigBVwDAqzSGcVSSMKLXpn4GibDp7K4KumAsmhWuMGKO)7rIxqKGctblfRSK04cghs8iWFizaKeXK8XmKXyyAfNHjmw4YJ0mKH5mwC70GYybp(9CT2ybIX2RvNguglMKFSkjlJF4)HGXKGUNDsCsmhWuMGKO)7rs0FiPadjO35Ievaq3fcsEGJeuykyPyLLeWrcmWUGogIKf1(6bBSyVE4RDJLX1Cnb8WATFzORFtGlpsZqKOKemptxiWbmqdYqx)gsuss0)9c4XVNR1bia6YymmTI3WeglC5rAgYWCglUDAqzSGh)W)dbBSaXy71QtdkJftYpwLKLXp8)qWysq3ZojZotseWhsI(Vhjr)HKcmKGENlsubaDxii5bosSojGJeowfGMpsIafKXI96HV2nwsGeK(1EKMd2RNcmFvsusYgsSaKC51eQgX(KFotsAkjwaqdbqxbRN7Ygoo27ctssKO4ijnLKeibPFThP5GfkBbfupnOirjjjqIfGKlVMWA4U2lsstjzdjwaqdbqxbowfGMVCeOGchh7DHjjjsuCKOKKeij6)EH1DbDmuMJvbO5lMRjZfFiAZJdFvsusIfGKlVMWA4U2ls2sYwsusYgssGeiWeE)dUm4Lz9V4W021DHGK0ussGelaOHaORG1ZDzdh7qWrsAkjjqIfa0qa0vWckKG1CE25mwTVEWHJDi4izRXyyAyJHjmw4YJ0mKH5mwC70GYybp(H)hc2ybIX2RvNguglMKFSkjlJF4)HGXKeXpWXKGcqHeSMnwSxp81UXYgsSaGgcGUcwqHeSMZZoNXQ91doCCS3fMe4rcQirjjjqc09BOqbYwimjkjzdji9R9inhSGcjynNHymCLLK0usSaGgcGUcwp3LnCCS3fMe4rcQizljkjbPFThP5GfkBbfupnOizljkjjbsGat49p4YGxM1)IdtBx3fcsusIfGKlVMq1i2N8ZzsusscKaD)gkuGSfctIssyRUvXCORSxWzmgM2SenmHXcxEKMHmmNXcq1ybZJXIBNgugli9R9inBSG01F2yzdjr)3lCosUaFC(DCzEWfoo27ctssKGksstjjbsI(Vx4CKCb(4874Y8Gl8vjzljkjzdjr)3lSUlOJHYCSkanFXCnzU4drBEC44yVlmjWJeewOqSJAs2sIss2qs0)9cSv3QyoJbA)chh7DHjjjsqyHcXoQjjnLKO)7fyRUvXCw)l)chh7DHjjjsqyHcXoQjzRXceJTxRonOmwmjGcghsGadjq)RleKm7mjCbrc4rIjTJKlWhtI5)4Y8GdLKa9VUqqY6UGogIeowfGMVyUgsahjDrYSZKOD8qcclejGhjErc8B1TkMnwq6xU8y2ybcm5JHH)(4yUgSXyyAZmZWeglC5rAgYWCglUDAqzSG)1Rp2yXE9Wx7glh)ogV7rAMeLKm(HGNW0XCEazOMjjjsmd(qIssC1SDNTRjrjji9R9inhGat(yy4VpoMRbBSyHZQ584hcEWgM2mJXW0MTQHjmw4YJ0mKH5mwC70GYyjgaQxFSXI96HV2nwo(DmE3J0mjkjz8dbpHPJ58aYqntssKy2kdOIeLK4Qz7oBxtIssq6x7rAoabM8XWWFFCmxd2yXcNvZ5Xpe8GnmTzgJHPnBLgMWyHlpsZqgMZyXTtdkJf8WATF5N2p2yXE9Wx7glh)ogV7rAMeLKm(HGNW0XCEazOMjjjsmd(qcmj54yVlmjkjXvZ2D2UMeLKG0V2J0Cacm5JHH)(4yUgSXIfoRMZJFi4bByAZmgdtBMIyycJfU8indzyoJf3onOmwEGZYzWlx(8p2ybIX2RvNguglMFGPjbuKyHibDp7G)qI1vv7cHXI96HV2nwC1SDNTRngdtBgQmmHXcxEKMHmmNXIBNguglCSkanF5iqbzSaXy71QtdkJf4pwfGMpsmhOGib9oxK4rG)qYaiHRHpsCskgnjMdyktqc6UGaOjXlisWosMKh4ibfMcwkwznwSxp81UXYgsyRUvXCq)l)YfJ6HK0usyRUvXCad0(Llg1djPPKWwDRI5GxWLlg1djPPKe9FVqKR9YYzWl7ADE27cbox(8poCCS3fMKKirrcOIK0usI(VxiY1Ez5m4LDTop7DHaN9Z6fhoo27ctssKOibursAkjoEoxNvbO5JKKib2KijkjXcaAia6ky9Cx2WXoeCKOKKeib6(nuOazleMKTKOKKnKybaneaDfSEUlB44yVlmjjrYktKK0usSaGgcGUcwp3LnCSdbhjBjjnLKiagtIss6A4tfO9HHYVgX(Kpo27ctc8iXSengdtBg8XWeglC5rAgYWCglUDAqzS8(hCzWlZ6FXglqm2ET60GYyX8dGFsUgX(qse)ahtYh3fcsqHPmwSxp81UXIfa0qa0vW65USHJDi4irjji9R9inhSqzlOG6PbfjkjzdjoEoxNvbO5JKKib2KijkjjbsSaKC51eQgX(KFotsAkjwasU8AcvJyFYpNjrjjoEoxNvbO5Je4rIIKijBjrjjBijbsSaKC51eQgX(KFotsAkjwaqdbqxblOqcwZ5zNZy1(6bho2HGJKTKOKKeib6(nuOazle2ymmTzkodtySWLhPzidZzS42PbLXIL1mEAxNDDJOI5AmwGyS9A1PbLXckmfSuSYsc6DUiXhsGnjctsmfEfjzd40a08rYS7fjksIKyk8ksc6E2jbfGcjynVLe09Sd(djAaUleKmDmtsxKyonaaP)4HeVGir3ftYxLe09StckafsWAMK(rspKG2XKaXy4kldzSyVE4RDJLeib6(nuOazleMeLKG0V2J0CWcLTGcQNguKOKKnKSHehpNRZQa08rssKaBsKeLKSHKO)7fw3f0XqzowfGMVyUMmx8HOnpo8vjjnLKeiXcqYLxtynCx7fjBjjnLKO)7fI0aaK(JNWxLeLKe9FVqKgaG0F8eoo27ctc8iz1ejbMKSHelOG(9eup22yo76grfZ1eMoMZiD9NjzljBjjnLKiagtIss6A4tfO9HHYVgX(Kpo27ctc8iz1ejbMKSHelOG(9eup22yo76grfZ1eMoMZiD9NjzljPPKybi5YRjunI9j)CMKTKOKKnKKajwasU8AcvJyFYpNjjnLKnK445CDwfGMpsGhjksIKKMsceycV)bxg8YS(xCyA76UqqYwsusYgsq6x7rAoybfsWAodXy4kljPPKybaneaDfSGcjynNNDoJv7RhC4yhcos2sYwJXW0MP4nmHXcxEKMHmmNXI96HV2nwsGeO73qHcKTqysuscs)ApsZblu2ckOEAqrIss2qYgsC8CUoRcqZhjjrcSjrsusYgsI(VxyDxqhdL5yvaA(I5AYCXhI284WxLK0ussGelajxEnH1WDTxKSLK0usI(Vxisdaq6pEcFvsuss0)9crAaas)Xt44yVlmjWJKvMijWKKnKybf0VNG6X2gZzx3iQyUMW0XCgPR)mjBjzljPPKebWysussxdFQaTpmu(1i2N8XXExysGhjRmrsGjjBiXckOFpb1JTnMZUUruXCnHPJ5msx)zs2ssAkjwasU8AcvJyFYpNjzljkjzdjjqIfGKlVMq1i2N8ZzsstjzdjoEoxNvbO5Je4rIIKijPPKabMW7FWLbVmR)fhM2UUleKSLeLKSHeK(1EKMdwqHeSMZqmgUYssAkjwaqdbqxblOqcwZ5zNZy1(6bho2HGJKTKS1yXTtdkJLUS(v(0GYymmTzWgdtySWLhPzidZzSaunwW8yS42PbLXcs)ApsZgliD9NnwyRUvXCORS(x(rc8LefpjWIe3onOc4XVxFCGrnB)dNNoMjbMKKajSv3Qyo0vw)l)ib(sYgsGpKatsgxZ1eWGVodE5zNZpWX4jWLhPzisGVKSss2scSiXTtdQa6ZN9aJA2(hopDmtcmjjXWQKalsWQSwN3D8Wglqm2ET60GYyb(Xth7dJjzhGMK4VDNetHxrs8JjbH3fdrIkFKGzlOGmwq6xU8y2yXXQRiFlS1ymm9QjAycJfU8indzyoJf3onOmwWJF4)HGnwGyS9A1PbLXIj5hRsYY4h(FiymjO35IKzNj51i2hsAmjEe4pKmas4ccLK8oUmp4iPXK4rG)qYaiHliuscCGpj(XK4djWMeHjjMcVIK0fjErc8B1TkMrjjOWuWsXkljAhpys8cm78rIIhMy2IjbCKah4tcAWxdrcajFwxLKyWXKm7ErcLAwIKyk8ksc6DUiboWNe0GVgQGXHKLXp8)qWKua0gl2Rh(A3yzdjramMeLK01WNkq7ddLFnI9jFCS3fMe4rIIqsAkjBij6)EHZrYf4JZVJlZdUWXXExysGhjiSqHyh1KaFjXYTMKnK445CDwfGMpsGfjRmrs2sIssI(Vx4CKCb(4874Y8Gl8vjzljBjjnLKnK445CDwfGMpsGjji9R9inhCS6kY3cBjb(ss0)9cSv3QyoJbA)chh7DHjbMKabMW7FWLbVmR)fhM2UgNpo27Ie4ljRgqfjjrIzMLijPPK445CDwfGMpsGjji9R9inhCS6kY3cBjb(ss0)9cSv3QyoR)LFHJJ9UWKatsGat49p4YGxM1)IdtBxJZhh7Drc8LKvdOIKKiXmZsKKTKOKe2QBvmh6k7fCKOKKnKKajr)3ly9Cx2WxLK0ussGKX1Cnb84NgCqbU8indrYwsusYgs2qscKybaneaDfSEUlB4RssAkjwasU8AcRH7AVirjjjqIfa0qa0vGJvbO5lhbkOWxLKTKKMsIfGKlVMq1i2N8Zzs2sIss2qscKybi5YRjGKRzhUJK0ussGKO)7fSEUlB4RssAkjoEoxNvbO5JKKib2KijBjjnLKnKmUMRjGh)0GdkWLhPzisuss0)9cwp3Ln8vjrjjBij6)Eb84NgCqb8421KapswjjPPK445CDwfGMpssIeytIKSLKTKKMss0)9cwp3Ln8vjrjjjqs0)9cNJKlWhNFhxMhCHVkjkjjbsgxZ1eWJFAWbf4YJ0mKXyy6vnZWeglC5rAgYWCglUDAqzSum6Cmauglqm2ET60GYyXKXmjMuaqHjPlswHF5hjWVv3QyMeVGib7izsGT31pyA()AnjMuaqrYdCKGctblfRSgl2Rh(A3yzdjr)3lWwDRI5S(x(foo27ctssKWOMT)HZthZKKMsYgsS7(HGXKOajRsIsso2U7hcopDmtc8ibvKSLK0usS7(HGXKOajRKKTKOKexnB3z7AJXW0RUQHjmw4YJ0mKH5mwSxp81UXYgsI(VxGT6wfZz9V8lCCS3fMKKiHrnB)dNNoMjrjjBiXcaAia6ky9Cx2WXXExyssIeuLijPPKybaneaDfSGcjynNNDoJv7RhC44yVlmjjrcQsKKTKKMsYgsS7(HGXKOajRsIsso2U7hcopDmtc8ibvKSLK0usS7(HGXKOajRKKTKOKexnB3z7AJf3onOmw2D9lhdaLXyy6vxPHjmw4YJ0mKH5mwSxp81UXYgsI(VxGT6wfZz9V8lCCS3fMKKiHrnB)dNNoMjrjjBiXcaAia6ky9Cx2WXXExyssIeuLijPPKybaneaDfSGcjynNNDoJv7RhC44yVlmjjrcQsKKTKKMsYgsS7(HGXKOajRsIsso2U7hcopDmtc8ibvKSLK0usS7(HGXKOajRKKTKOKexnB3z7AJf3onOmwEFTohdaLXyy6vvedtySWLhPzidZzSaXy71QtdkJfyla8tcOiXczS42PbLXcA)UgCzWlZ6FXgJHPxfvgMWyHlpsZqgMZyXTtdkJf843Rp2ybIX2RvNguglMmMjzz871htYair9awswaA)ib(T6wfZKaosqVZfjDrcO0WrYk8l)ib(T6wfZK4fejFmtcSfa(jr9awmj9JKUizf(LFKa)wDRIzJf71dFTBSWwDRI5qxz9V8JK0usyRUvXCad0(Llg1djPPKWwDRI5GxWLlg1djPPKe9FVaA)UgCzWlZ6FXHVkjkjj6)Eb2QBvmN1)YVWxLK0us2qs0)9cwp3LnCCS3fMe4rIBNgub0Np7bg1S9pCE6yMeLKe9FVG1ZDzdFvs2AmgMEv4JHjmwC70GYyb95ZUXcxEKMHmmNXyy6vvCgMWyHlpsZqgMZyXTtdkJL7xz3onOY6gpgl6gp5YJzJLNR1Z(9ngJXyXbSHjmmTzgMWyHlpsZqgMZybOASG5XyXTtdkJfK(1EKMnwq66pBSSHKO)7fMoMrdUkdDShh1feFHJJ9UWKapsqyHcXoQjbMKKyWmsstjj6)EHPJz0GRYqh7XrDbXx44yVlmjWJe3onOc4XVxFCGrnB)dNNoMjbMKKyWmsusYgsyRUvXCORS(x(rsAkjSv3QyoGbA)YfJ6HK0usyRUvXCWl4YfJ6HKTKSLeLKe9FVW0XmAWvzOJ94OUG4l8vjrjj3V4h4qWHPJz0GRYqh7XrDbXxGHH)wvLHmwGyS9A1PbLXckCT9R9HXKGENND(iz2zsmjh7XwFS78rs0)9ibDR1K8CTMeW7rc6E27IKzNjPyupKyD8ySG0VC5XSXc0XECgDR15NR1zW7zmgMEvdtySWLhPzidZzSaunwW8yS42PbLXcs)ApsZgliD9NnwsGe2QBvmh6kJbA)irjjBibRYADE8dbp4aE871htssKGksusY4AUMag81zWlp7C(bogpbU8indrsAkjyvwRZJFi4bhWJFV(yssIefhjBnwGyS9A1PbLXckCT9R9HXKGENND(izz8d)pemjnMe0GB2jX64PleKaqYhjlJFV(ys6IKv4x(rc8B1TkMnwq6xU8y2yPruGJZ4Xp8)qWgJHPxPHjmw4YJ0mKH5mwC70GYyXckKG1CE25mwTVEWglqm2ET60GYyXKXmjOauibRzsqVZfj(qIMXysMDVibvjsIPWRijEbrIUlMKVkjO7zNeuykyPyL1yXE9Wx7gljqc09BOqbYwimjkjzdjBibPFThP5GfuibR5meJHRSKOKKeiXcaAia6ky9Cx2WXoeCKKMss0)9cwp3Ln8vjzljkjzdjoEoxNvbO5Je4rcQsKK0usq6x7rAo0ikWXz84h(Fiys2sIss2qs0)9cSv3QyoR)LFHJJ9UWKKejWhsstjj6)Eb2QBvmNXaTFHJJ9UWKKejWhs2sIss2qscKC)IFGdbhICTxwodEzxRZZExiWbU8indrsAkjr)3le5AVSCg8YUwNN9UqGZLp)Jd4XTRjjjswjjPPKe9FVqKR9YYzWl7ADE27cbo7N1loGh3UMKKizLKSLK0usEnI9jFCS3fMe4rIzjsIsssGelaOHaORG1ZDzdh7qWrYwJXW0kIHjmw4YJ0mKH5mwC70GYy5CKCb(4874Y8GZybIX2RvNguglMmMjX8FCzEWrc6E2jbfMcwkwznwSxp81UXs0)9cwp3LnCCS3fMKKiXmuzmgMgvgMWyHlpsZqgMZyXTtdkJf8VE9Xglw4SAop(HGhSHPnZyXE9Wx7glBi543X4DpsZKKMss0)9cSv3QyoJbA)chh7DHjbEKSssuscB1TkMdDLXaTFKOKKJJ9UWKapsmtrirjjJR5AcyWxNbV8SZ5h4y8e4YJ0mejBjrjjJFi4jmDmNhqgQzssIeZuesu0KGvzTop(HGhmjWKKJJ9UWKOKKnKWwDRI5qxzVGJK0usoo27ctc8ibHfke7OMKTglqm2ET60GYyXKXmjl)61htsxKO6feh3wsafjEb3S3fcsMDFir3izmjMPiy2IjXlis0mgtc6E2jjgCmjJFi4btIxqK4djZotcxqKaEK4KSa0(rc8B1TkMjXhsmtribZwmjGJenJXKCCS3vxiiXXKmaskWqYUJSleKmaso(DmENeO)1fcswHF5hjWVv3Qy2ymmn8XWeglC5rAgYWCglUDAqzSGh)EUwBSaXy71QtdkJfyGmRsYxLKLXVNR1K4djUwtY0XmMKFPzmMKpUleKScWz9ZXK4fej9qsJjXJa)HKbqI6bSKaos08qYSZKGvzB7AsC70GIeDxmjrSgGMKDVG0mjMKJ94OUG4JeqrYQKm(HGhSXI96HV2nw2qs0)9c4XVNR1HJFhJ39intIss2qcwL1684hcEWb843Z1AsGhjRKK0ussGK7x8dCi4W0XmAWvzOJ94OUG4lWWWFRQYqKSLK0usgxZ1eWGVodE5zNZpWX4jWLhPzisuss0)9cSv3QyoJbA)chh7DHjbEKSssuscB1TkMdDLXaTFKOKKO)7fWJFpxRdhh7DHjbEKO4irjjyvwRZJFi4bhWJFpxRjjjfirrizljkjzdjjqY9l(boeCqdN1phNFAMNUqKrO7yvmhyy4Vvvzisstjz6yMeffjkcQijjsI(Vxap(9CToCCS3fMeysYQKSLeLKm(HGNW0XCEazOMjjjsqLXyyAfNHjmw4YJ0mKH5mwC70GYybp(9CT2ybIX2RvNguglWw9StIj5ypoQli(i5Jzswg)EUwtYaiznZQK8vjz2zsI(VhjrWrIRXas(4UqqYY43Z1AsafjOIemBbfeMeWrIMXysoo27Qlegl2Rh(A3y5(f)ahcomDmJgCvg6ypoQli(cmm83QQmejkjbRYADE8dbp4aE875AnjjPajRKeLKSHKeij6)EHPJz0GRYqh7XrDbXx4RsIssI(Vxap(9CToC87y8UhPzsstjzdji9R9inhGo2JZOBTo)CTodEpsusYgsI(Vxap(9CToCCS3fMe4rYkjjnLeSkR15Xpe8Gd4XVNR1KKejRsIssgxZ1eWdR1(LHU(nbU8indrIssI(Vxap(9CToCCS3fMe4rcQizljBjzRXyyAfVHjmw4YJ0mKH5mwaQglyEmwC70GYybPFThPzJfKU(ZgloEoxNvbO5JKKirXNijkAs2qIzjsc8LKO)7fMoMrdUkdDShh1feFb8421KSLefnjBij6)Eb843Z16WXXExysGVKSssGfjyvwRZ7oEys2sIIMKnKabMW7FWLbVmR)fhoo27ctc8LeurYwsuss0)9c4XVNR1HVQXceJTxRonOmwqHRTFTpmMe078SZhjojlJF4)HGj5Jzsq3Anjw)Jzswg)EUwtYai55AnjG3dLK4fejFmtYY4h(FiysgajRzwLetYXECuxq8rcEC7As(Qgli9lxEmBSGh)EUwNrdQj)CTodEpJXW0WgdtySWLhPzidZzS42PbLXcE8d)peSXceJTxRonOmwmzmtYY4h(Fiysq3ZojMKJ94OUG4JKbqYAMvj5RsYSZKe9Fpsq3Zo4pKOb4UqqYY43Z1As(QthZK4fejFmtYY4h(FiysafjkcmjXCatzcsWJBxJj5xtRjrriz8dbpyJf71dFTBSG0V2J0Ca6ypoJU168Z16m49irjji9R9inhWJFpxRZOb1KFUwNbVhjkjjbsq6x7rAo0ikWXz84h(Fiysstjzdjr)3le5AVSCg8YUwNN9UqGZLp)Jd4XTRjjjswjjPPKe9FVqKR9YYzWl7ADE27cbo7N1loGh3UMKKizLKSLeLKGvzTop(HGhCap(9CTMe4rIIqIssq6x7rAoGh)EUwNrdQj)CTodEpJXW0MLOHjmw4YJ0mKH5mwC70GYyXHC1PrYzmA)InwSWz1CE8dbpydtBMXI96HV2nwsGKPTR7cbjkjjbsC70Gk4qU60i5mgTFXzip2rWHUYpDJyFijnLeiWeCixDAKCgJ2V4mKh7i4aEC7AsGhjRKeLKabMGd5QtJKZy0(fNH8yhbhoo27ctc8izLglqm2ET60GYyXKXmjy0(ftcgqYS7djWb(KGGhsIDutYxD6yMKi4i5J7cbj9qIJjr7dtIJjrfGXDKMjbuKOzmMKz3lswjj4XTRXKaosGb8JhsqVZfjReMKGh3UgtcJA1(yJXW0MzMHjmw4YJ0mKH5mwC70GYyjgaQxFSXIfoRMZJFi4bByAZmwSxp81UXYXVJX7EKMjrjjJFi4jmDmNhqgQzssIKnKSHeZuesGjjBibRYADE8dbp4aE871htc8LKvjb(ss0)9cSv3QyoR)LFHVkjBjzljWKKJJ9UWKSLeyrYgsmJeysY4AUMWGURCmau4axEKMHizljkjzdjwaqdbqxbRN7Ygo2HGJeLKKajq3VHcfiBHWKOKKnKG0V2J0CWckKG1CgIXWvwsstjXcaAia6kybfsWAop7CgR2xp4WXoeCKKMsscKybi5YRjunI9j)CMKTKKMscwL1684hcEWb843RpMe4rYgs2qc8HefnjBij6)Eb2QBvmN1)YVWxLe4ljRsYws2sc8LKnKygjWKKX1CnHbDx5yaOWbU8indrYws2sIsssGe2QBvmhWaTF5Ir9qsAkjBiHT6wfZHUYyG2psstjzdjSv3Qyo0vocm7KKMscB1TkMdDL1)Yps2sIsssGKX1Cnbm4RZGxE258dCmEcC5rAgIK0usI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKKKcKSkQsKKTKOKKnKGvzTop(HGhCap(96JjbEKywIKaFjzdjMrcmjzCnxtyq3vogakCGlpsZqKSLKTKOKehpNRZQa08rssKGQejrrts0)9c4XVNR1HJJ9UWKaFjb(qYwsusYgssGKO)7fw3f0XqzowfGMVyUMmx8HOnpo8vjjnLe2QBvmh6kJbA)ijnLKeiXcqYLxtynCx7fjBnwGyS9A1PbLXIjn)ogVtIjfauV(ys6hjOWuWsXkljnMKJDi4qjjZoFmj(XKOzmMKz3lsqfjJFi4btsxKSc)YpsGFRUvXmjO7zNKfWy(rjjAgJjz29IeZsKeWSZh6gZK0fjEbhjWVv3QyMeWrYxLKbqcQiz8dbpysI4h4ysCswHF5hjWVv3QyoqIjbuW4qYXVJX7Ka9VUqqcmWUGogIe4pwfGMVyUgs(LMXys6IKfG2psGFRUvXSXyyAZw1WeglC5rAgYWCglUDAqzS8aNLZGxU85FSXceJTxRonOmwmzmtI5hyAsafjwisq3Zo4pKyDv1UqySyVE4RDJfxnB3z7AJXW0MTsdtySWLhPzidZzS42PbLXIL1mEAxNDDJOI5AmwGyS9A1PbLXIjJzsqHPGLIvwsafjwis(LMXys8cIeDxmj9qYxLe09StckafsWA2yXE9Wx7gljqc09BOqbYwimjkjbPFThP5GfkBbfupnOirjjBij6)Eb843Z16WxLK0usC8CUoRcqZhjjrcQsKKTKOKKnKKajr)3lGbA80wo8vjrjjjqs0)9cwp3Ln8vjrjjBijbsSaKC51eQgX(KFotsAkjwaqdbqxblOqcwZ5zNZy1(6bh(QKOKehpNRZQa08rc8ibvjsYwsusY4hcEcthZ5bKHAMKKiXmurcmjXckOFpb1JTnMZUUruXCnHPJ5msx)zsstjjcGXKOKKUg(ubAFyO8RrSp5JJ9UWKapswnrsGjjwqb97jOESTXC21nIkMRjmDmNr66ptYwJXW0MPigMWyHlpsZqgMZyXE9Wx7gljqc09BOqbYwimjkjbPFThP5GfkBbfupnOirjjBij6)Eb843Z16WxLK0usC8CUoRcqZhjjrcQsKKTKOKKnKKajr)3lGbA80wo8vjrjjjqs0)9cwp3Ln8vjrjjBijbsSaKC51eQgX(KFotsAkjwaqdbqxblOqcwZ5zNZy1(6bh(QKOKehpNRZQa08rc8ibvjsYwsusY4hcEcthZ5bKHAMKKiz1ejbMKybf0VNG6X2gZzx3iQyUMW0XCgPR)mjPPKebWysussxdFQaTpmu(1i2N8XXExysGhjRmrsGjjwqb97jOESTXC21nIkMRjmDmNr66ptYwJf3onOmw6Y6x5tdkJXW0MHkdtySWLhPzidZzS42PbLXchRcqZxocuqglqm2ET60GYyXKXmjWFSkanFKyoqbrcOiXcrc6E2jzz875AnjFvs8cIeSJKj5boswXVg7hjEbrckmfSuSYASyVE4RDJLiagtIss6A4tfO9HHYVgX(Kpo27ctc8iXmursAkjBij6)Eb1RJbhu76SFwVABw9RX(fq66ptc8izvuLijPPKe9FVG61XGdQDD2pRxTnR(1y)ciD9NjjjfizvuLijBjrjjr)3lGh)EUwh(QKOKKnKybaneaDfSEUlB44yVlmjjrcQsKK0usGUFdfkq2cHjzRXyyAZGpgMWyHlpsZqgMZyXTtdkJf8WATF5N2p2yXcNvZ5Xpe8GnmTzgl2Rh(A3y543X4DpsZKOKKPJ58aYqntssKygQirjjyvwRZJFi4bhWJFV(ysGhjkcjkjXvZ2D2UMeLKSHKO)7fSEUlB44yVlmjjrIzjssAkjjqs0)9cwp3Ln8vjzRXceJTxRonOmwmP53X4DsEA)ysafjFvsgajRKKXpe8GjbDp7G)qckmfSuSYsse3fcs8iWFizaKWOwTpMeVGiPadjaK8zDv1UqymgM2mfNHjmw4YJ0mKH5mwC70GYy59p4YGxM1)InwGyS9A1PbLXIjJzsm)a4NK(rsx4gIjXlsGFRUvXmjEbrIUlMKEi5Rsc6E2jXjzf)ASFKOEaljEbrIPGC1PrYKSG2VyJf71dFTBSWwDRI5qxzVGJeLK4Qz7oBxtIssI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKapswfvjsIss2qceycoKRonsoJr7xCgYJDeCyA76UqqsAkjjqIfGKlVMqX2dObhejPPKGvzTop(HGhmjjrYQKS1ymmTzkEdtySWLhPzidZzS42PbLXcE875ATXceJTxRonOmwmzmtItYY43Z1AsGTv8StI6bSK8lnJXKSm(9CTMKgtIRp2HGJKVkjGJe4aFs8JjXJa)HKbqcajFwxLetHxrJf71dFTBSe9FVaO4zhNv5ZYQtdQWxLeLKSHKO)7fWJFpxRdh)ogV7rAMK0usC8CUoRcqZhjjrcSjrs2AmgM2myJHjmw4YJ0mKH5mwC70GYybp(9CT2ybIX2RvNguglMKFSkjMcVIKeXpWXKGcqHeSMjbDp7KSm(9CTMeVGiz25IKLXp8)qWgl2Rh(A3yXcqYLxtOAe7t(5mjkjzdji9R9inhSGcjynNHymCLLK0usSaGgcGUcwp3Ln8vjjnLKO)7fSEUlB4RsYwsusIfa0qa0vWckKG1CE25mwTVEWHJJ9UWKapsqyHcXoQjb(sILBnjBiXXZ56SkanFKalsqvIKSLeLKe9FVaE875AD44yVlmjWJefHeLKKajq3VHcfiBHWgJHPxnrdtySWLhPzidZzSyVE4RDJflajxEnHQrSp5NZKOKKnKG0V2J0CWckKG1CgIXWvwsstjXcaAia6ky9Cx2WxLK0usI(VxW65USHVkjBjrjjwaqdbqxblOqcwZ5zNZy1(6bhoo27ctc8ib(qIssI(Vxap(9CTo8vjrjjSv3Qyo0v2l4irjjjqcs)ApsZHgrbooJh)W)dbtIsssGeO73qHcKTqyJf3onOmwWJF4)HGngdtVQzgMWyHlpsZqgMZyXTtdkJf84h(FiyJfigBVwDAqzSyYyMKLXp8)qWKGUNDs8IeyBfp7KOEaljGJK(rcCGpmcrcajFwxLetHxrsq3ZojWb(hjfJ6HeRJNajMsJbKa9JvXKyk8ksIpKm7mjCbrc4rYSZKadaxZoChjr)3JK(rYY43Z1Asqd(AOcghsEUwtc49ibuKOiKaos0mgtY4hcEWgl2Rh(A3yj6)EbqXZooB1SFzKnUbv4RssAkjBijbsWJFV(4GRMT7SDnjkjjbsq6x7rAo0ikWXz84h(Fiysstjzdjr)3ly9Cx2WXXExysGhjOIeLKe9FVG1ZDzdFvsstjzdjr)3lCosUaFC(DCzEWfoo27ctc8ibHfke7OMe4ljwU1KSHehpNRZQa08rcSizLjsYwsuss0)9cNJKlWhNFhxMhCHVkjBjzljkjbPFThP5aE875ADgnOM8Z16m49irjjyvwRZJFi4bhWJFpxRjbEKSss2sIss2qscKC)IFGdbhMoMrdUkdDShh1feFbgg(BvvgIK0usWQSwNh)qWdoGh)EUwtc8izLKS1ymm9QRAycJfU8indzyoJf3onOmwkgDogakJfigBVwDAqzSyYyMetkaOWK0fjlaTFKa)wDRIzs8cIeSJKjX8)1AsmPaGIKh4ibfMcwkwznwSxp81UXYgsI(VxGT6wfZzmq7x44yVlmjjrcJA2(hopDmtsAkjBiXU7hcgtIcKSkjkj5y7UFi480XmjWJeurYwsstjXU7hcgtIcKSss2sIssC1SDNTRngdtV6knmHXcxEKMHmmNXI96HV2nw2qs0)9cSv3QyoJbA)chh7DHjjjsyuZ2)W5PJzsstjzdj2D)qWysuGKvjrjjhB39dbNNoMjbEKGks2ssAkj2D)qWysuGKvsYwsusIRMT7SDTXIBNgugl7U(LJbGYymm9QkIHjmw4YJ0mKH5mwSxp81UXYgsI(VxGT6wfZzmq7x44yVlmjjrcJA2(hopDmtIss2qIfa0qa0vW65USHJJ9UWKKejOkrsstjXcaAia6kybfsWAop7CgR2xp4WXXExyssIeuLijBjjnLKnKy39dbJjrbswLeLKCSD3peCE6yMe4rcQizljPPKy39dbJjrbswjjBjrjjUA2UZ21glUDAqzS8(ADogakJXW0RIkdtySWLhPzidZzSaXy71QtdkJftgZKaBbGFsafjOWKyS42PbLXcA)UgCzWlZ6FXgJHPxf(yycJfU8indzyoJfGQXcMhJf3onOmwq6x7rA2ybPR)SXcwL1684hcEWb843RpMKKirribMK80aWrYgsID8WhCzKU(ZKaFjXSetKeyrYQjsYwsGjjpnaCKSHKO)7fWJF4)HGZCSkanFXCnzmq7xapUDnjWIefHKTglqm2ET60GYybfU2(1(WysqVZZoFKmas(yMKLXVxFmjDrYcq7hjO3B7ojnMeFibvKm(HGhmmnJKh4iHrYhCKSAIkksID8WhCKaosueswg)W)dbtc8hRcqZxmxdj4XTRXgli9lxEmBSGh)E9X5UYyG2pJXW0RQ4mmHXcxEKMHmmNXIBNguglOpF2nwGyS9A1PbLXIjJzsGToF2jPlswaA)ib(T6wfZKaos6hjfGKLXVxFmjOBTMKxpK01aibfMcwkwzjXl4IbhBSyVE4RDJLnKWwDRI5G(x(Llg1djPPKWwDRI5GxWLlg1djkjbPFThP5qJZwn7izs2sIss2qY4hcEcthZ5bKHAMKKirrijnLe2QBvmh0)YVCx5vjjnLKxJyFYhh7DHjbEKywIKSLK0usI(VxGT6wfZzmq7x44yVlmjWJe3onOc4XVxFCGrnB)dNNoMjrjjr)3lWwDRI5mgO9l8vjjnLe2QBvmh6kJbA)irjjjqcs)ApsZb843Rpo3vgd0(rsAkjr)3ly9Cx2WXXExysGhjUDAqfWJFV(4aJA2(hopDmtIsssGeK(1EKMdnoB1SJKjrjjr)3ly9Cx2WXXExysGhjmQz7F480Xmjkjj6)EbRN7Yg(QKKMss0)9cNJKlWhNFhxMhCHVkjkjbRYADE3XdtssKKya(qIss2qcwL1684hcEWKapfizLKKMsscKmUMRjGbFDg8YZoNFGJXtGlpsZqKSLK0ussGeK(1EKMdnoB1SJKjrjjr)3ly9Cx2WXXExyssIeg1S9pCE6y2ymm9QkEdtySWLhPzidZzSaXy71QtdkJftgZKSm(96JjPFK0fjRWV8Je43QBvmJss6IKfG2psGFRUvXmjGIefbMKm(HGhmjGJKbqI6bSKSa0(rc8B1TkMnwC70GYybp(96JngdtVkSXWeglC5rAgYWCglqm2ET60GYyX87A9SFFJf3onOmwUFLD70GkRB8ySOB8KlpMnwEUwp733ymgJLNR1Z(9nmHHPnZWeglC5rAgYWCglUDAqzSGh)W)dbBSaXy71QtdkJLLXp8)qWK8ahjXaKCmxdj)sZymjFCxiiXCatzcJf71dFTBSKaj3V4h4qWHix7LLZGx2168S3fcCGHH)wvLHmgdtVQHjmw4YJ0mKH5mwC70GYyb)RxFSXIfoRMZJFi4bByAZmwSxp81UXceycXaq96Jdhh7DHjjjsoo27ctc8LKvxLeyrIzkEJfigBVwDAqzSGchpKm7mjqGHe09StYSZKedWdjthZKmasCiis(10AsMDMKyh1Ka9pFAqrsJjzVNajl)61htYXXExysI)6Pv1ndrYaij2h7ojXaq96Jjb6F(0GYymm9knmHXIBNguglXaq96Jnw4YJ0mKH5mgJXybpgMWW0MzycJfU8indzyoJf3onOmwohjxGpo)oUmp4mwGyS9A1PbLXIjJzsMDMeya4A2H7ibDp7K4KGctblfRSKm7(qsJlyCi5DGyswXVg7NXI96HV2nwI(VxW65USHJJ9UWKKejMHkJXW0RAycJfU8indzyoJf3onOmwWJF4)HGnwGyS9A1PbLXIjJzswg)W)dbtYaiznZQK8vjz2zsmjh7XrDbXhjr)3JK(rspKGg81qKWOwTpMKi(boMKxxnEVleKm7mjfJ6HeRJhsahjdGeOFSkjr8dCmjOauibRzJf71dFTBSC)IFGdbhMoMrdUkdDShh1feFbgg(BvvgIeLKSHe2QBvmh6k7fCKOKKeizdjBij6)EHPJz0GRYqh7XrDbXx44yVlmjjrIBNgub0Np7bg1S9pCE6yMeyssIbZirjjBiHT6wfZHUYrGzNK0usyRUvXCORmgO9JK0usyRUvXCq)l)YfJ6HKTKKMss0)9cthZObxLHo2JJ6cIVWXXExyssIe3onOc4XVxFCGrnB)dNNoMjbMKKyWmsusYgsyRUvXCORS(x(rsAkjSv3QyoGbA)YfJ6HK0usyRUvXCWl4YfJ6HKTKSLK0ussGKO)7fMoMrdUkdDShh1feFHVkjBjjnLKnKe9FVG1ZDzdFvsstjbPFThP5GfuibR5meJHRSKSLeLKybaneaDfSGcjynNNDoJv7RhC4yhcosusIfGKlVMq1i2N8Zzs2sIss2qscKybi5YRjSgUR9IK0usSaGgcGUcCSkanF5iqbfoo27ctssKO4jzljkjzdjr)3ly9Cx2WxLK0ussGelaOHaORG1ZDzdh7qWrYwJXW0R0WeglC5rAgYWCglUDAqzS4qU60i5mgTFXglw4SAop(HGhSHPnZyXE9Wx7gljqceycoKRonsoJr7xCgYJDeCyA76UqqIsssGe3onOcoKRonsoJr7xCgYJDeCOR8t3i2hsusYgssGeiWeCixDAKCgJ2V48o76W021DHGK0usGatWHC1PrYzmA)IZ7SRdhh7DHjjjsqfjBjjnLeiWeCixDAKCgJ2V4mKh7i4aEC7AsGhjRKeLKabMGd5QtJKZy0(fNH8yhbhoo27ctc8izLKOKeiWeCixDAKCgJ2V4mKh7i4W021DHWybIX2RvNguglMmMjXuqU60izswq7xmjO35IKzNpMKgtsbiXTtJKjbJ2VyusIJjr7dtIJjrfGXDKMjbuKGr7xmjO7zNKvjbCK8y08rcEC7AmjGJeqrItYkHjjy0(ftcgqYS7djZotsXOjbJ2Vys87AKmMeya)4He)n8rYS7djy0(ftcJA1(ySXyyAfXWeglC5rAgYWCglUDAqzSybfsWAop7CgR2xpyJfigBVwDAqzSyYygtckafsWAMK(rckmfSuSYssJj5Rsc4iboWNe)ysGymCLTleKGctblfRSKGUNDsqbOqcwZK4fejWb(K4htseRbOjrrsKetHxrJf71dFTBSKajq3VHcfiBHWKOKKnKSHeK(1EKMdwqHeSMZqmgUYsIsssGelaOHaORG1ZDzdh7qWrIsssGK7x8dCi4G61XGdQDD2pRxTnR(1y)cC5rAgIK0usI(VxW65USHVkjBjrjjoEoxNvbO5Je4rIIKijkjzdjr)3lWwDRI5S(x(foo27ctssKywIKKMss0)9cSv3QyoJbA)chh7DHjjjsmlrs2ssAkjVgX(Kpo27ctc8iXSejrjjjqIfa0qa0vW65USHJDi4izRXyyAuzycJfU8indzyoJfGQXcMhJf3onOmwq6x7rA2ybPR)SXYgsI(Vx4CKCb(4874Y8GlCCS3fMKKibvKKMsscKe9FVW5i5c8X53XL5bx4RsYwsusYgsI(VxyDxqhdL5yvaA(I5AYCXhI284WXXExysGhjiSqHyh1KSLeLKSHKO)7fyRUvXCgd0(foo27ctssKGWcfIDutsAkjr)3lWwDRI5S(x(foo27ctssKGWcfIDutYwJfigBVwDAqzSGcqb1tdksEGJexRjbcmysMDFij2xZysW)Jjz2z4iXpUGXHKJFhJ3zisqVZfjM0osUaFmjM)JlZdos2DmjAgJjz29IeurcMTysoo27QleKaosMDMK1WDTxKe9FpsAmjEe4pKmasEUwtc49ibCK4fCKa)wDRIzsAmjEe4pKmasyuR2hBSG0VC5XSXceyYhdd)9XXCnyJXW0WhdtySWLhPzidZzS42PbLXsmauV(yJf71dFTBSC87y8UhPzsusY4hcEcthZ5bKHAMKKiXSvjrjjBiXvZ2D2UMeLKG0V2J0Cacm5JHH)(4yUgmjBnwSWz1CE8dbpydtBMXyyAfNHjmw4YJ0mKH5mwC70GYyb)RxFSXI96HV2nwo(DmE3J0mjkjz8dbpHPJ58aYqntssKy2QKOKKnK4Qz7oBxtIssq6x7rAoabM8XWWFFCmxdMKTglw4SAop(HGhSHPnZymmTI3WeglC5rAgYWCglUDAqzSGhwR9l)0(Xgl2Rh(A3y543X4DpsZKOKKXpe8eMoMZdid1mjjrIzWhsusYgsC1SDNTRjrjji9R9inhGat(yy4VpoMRbtYwJflCwnNh)qWd2W0MzmgMg2yycJfU8indzyoJf3onOmwEGZYzWlx(8p2ybIX2RvNguglMmMjX8dmnjGIelejO7zh8hsSUQAximwSxp81UXIRMT7SDTXyyAZs0WeglC5rAgYWCglUDAqzSWXQa08LJafKXceJTxRonOmwmzmtcmWUGogIKf1(6btc6E2jXl4irdkeKWf4JyNeTJNUqqc8B1TkMjXlisMdosgaj6Uys6HKVkjO7zNKv8RX(rIxqKGctblfRSgl2Rh(A3yzdjBij6)Eb2QBvmNXaTFHJJ9UWKKejMLijPPKe9FVaB1TkMZ6F5x44yVlmjjrIzjsYwsusIfa0qa0vW65USHJJ9UWKKejRmrsusYgsI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKapswvrsKK0ussGK7x8dCi4G61XGdQDD2pRxTnR(1y)cmm83QQmejBjzljPPKe9FVG61XGdQDD2pRxTnR(1y)ciD9NjjjfizvfxIKKMsIfa0qa0vW65USHJDi4irjjoEoxNvbO5JKKib2KOXyyAZmZWeglC5rAgYWCglUDAqzSyznJN21zx3iQyUgJfigBVwDAqzSyYyMeuykyPyLLe09StckafsWAgwWa7c6yiswu7RhmjEbrceOGXHeas(qF9WKSIFn2psahjO35IeZPbai9hpKGg81qKWOwTpMKi(boMeuykyPyLLeg1Q9XyJf71dFTBSKajq3VHcfiBHWKOKeK(1EKMdwOSfuq90GIeLKSHehpNRZQa08rssKaBsKeLKSHKO)7fw3f0XqzowfGMVyUMmx8HOnpo8vjjnLKeiXcqYLxtynCx7fjBjjnLelajxEnHQrSp5NZKKMss0)9crAaas)Xt4RsIssI(Vxisdaq6pEchh7DHjbEKSAIKats2qYgsGnKaFj5(f)ahcoOEDm4GAxN9Z6vBZQFn2Vadd)TQkdrYwsGjjBiXckOFpb1JTnMZUUruXCnHPJ5msx)zs2sYws2sIsssGKO)7fSEUlB4RsIss2qscKybi5YRjunI9j)CMK0usSaGgcGUcwqHeSMZZoNXQ91do8vjjnLKiagtIss6A4tfO9HHYVgX(Kpo27ctc8iXcaAia6kybfsWAop7CgR2xp4WXXExysGjjWhsstjPRHpvG2hgk)Ae7t(4yVlmjkksmtXNijWJKvtKeysYgsSGc63tq9yBJ5SRBevmxty6yoJ01FMKTKS1ymmTzRAycJfU8indzyoJf71dFTBSKajq3VHcfiBHWKOKeK(1EKMdwOSfuq90GIeLKSHehpNRZQa08rssKaBsKeLKSHKO)7fw3f0XqzowfGMVyUMmx8HOnpo8vjjnLKeiXcqYLxtynCx7fjBjjnLelajxEnHQrSp5NZKKMss0)9crAaas)Xt4RsIssI(Vxisdaq6pEchh7DHjbEKSYejbMKSHKnKaBib(sY9l(boeCq96yWb1Uo7N1R2Mv)ASFbgg(BvvgIKTKats2qIfuq)EcQhBBmNDDJOI5ActhZzKU(ZKSLKTKSLeLKKajr)3ly9Cx2WxLeLKSHKeiXcqYLxtOAe7t(5mjPPKybaneaDfSGcjynNNDoJv7RhC4RssAkjramMeLK01WNkq7ddLFnI9jFCS3fMe4rIfa0qa0vWckKG1CE25mwTVEWHJJ9UWKatsGpKKMssxdFQaTpmu(1i2N8XXExysuuKyMIprsGhjRmrsGjjBiXckOFpb1JTnMZUUruXCnHPJ5msx)zs2sYwJf3onOmw6Y6x5tdkJXW0MTsdtySWLhPzidZzSaunwW8yS42PbLXcs)ApsZgliD9NnwsGelaOHaORG1ZDzdh7qWrsAkjjqcs)ApsZblOqcwZzigdxzjrjjwasU8AcvJyFYpNjjnLeO73qHcKTqyJfigBVwDAqzSadGFThPzs(ygIeqrIh16EAgtYS7djO9AizaKeXKGDKmejpWrckmfSuSYscgqYS7djZodhj(X1qcAhpmejWa(Xdjr8dCmjZohBSG0VC5XSXc2rY5h4Ywp3L1ymmTzkIHjmw4YJ0mKH5mwC70GYy59p4YGxM1)InwGyS9A1PbLXIjJzmjMFa8ts)iPls8Ie43QBvmtIxqKmxZysgaj6Uys6HKVkjO7zNKv8RX(HssqHPGLIvws8cIetb5QtJKjzbTFXgl2Rh(A3yHT6wfZHUYEbhjkjXvZ2D2UMeLKe9FVG61XGdQDD2pRxTnR(1y)ciD9NjbEKSQIKijkjzdjqGj4qU60i5mgTFXzip2rWHPTR7cbjPPKKajwasU8AcfBpGgCqKSLeLKG0V2J0Ca7i58dCzRN7YAmgM2muzycJfU8indzyoJf3onOmwWJFpxRnwGyS9A1PbLXIjJzsGTv8StYY43Z1AsupGfts)izz875AnjnUGXHKVQXI96HV2nwI(Vxau8SJZQ8zz1Pbv4RsIssI(Vxap(9CToC87y8UhPzJXW0MbFmmHXcxEKMHmmNXI96HV2nwI(Vxap(Pbhu44yVlmjWJeurIss2qs0)9cSv3QyoJbA)chh7DHjjjsqfjPPKe9FVaB1TkMZ6F5x44yVlmjjrcQizljkjXXZ56SkanFKKejWMenwC70GYyX6LL15O)7zSe9FVC5XSXcE8tdoiJXW0MP4mmHXcxEKMHmmNXIBNgugl4XVNR1glqm2ET60GYyXK8JvXKyk8ksse)ahtckafsWAMKpUleKm7mjOauibRzsSGcQNguKmasS7SDnj9JeuakKG1mjnMe3oFxRHJepc8hsgajrmjwhpgl2Rh(A3yzCnxtapSw7xg663e4YJ0mejkjbZZ0fcCad0Gm01VHeLKe9FVaE875ADacGUmgdtBMI3WeglC5rAgYWCglUDAqzSGh)W)dbBSaXy71QtdkJftYpwftIJvjjIFGJjbfGcjyntYh3fcsMDMeuakKG1mjwqb1tdksgaj2D2UMK(rckafsWAMKgtIBNVR1WrIhb(djdGKiMeRJhJf71dFTBSybi5YRjunI9j)CMeLKG0V2J0CWckKG1CgIXWvwsusIfa0qa0vWckKG1CE25mwTVEWHJJ9UWKapsqfjkjjbsGUFdfkq2cHngdtBgSXWeglC5rAgYWCglUDAqzSGh)EUwBSaXy71QtdkJftgZKSm(9CTMe09StYYWATFKysU(nK4fejfGKLXpn4GqjjO35IKcqYY43Z1AsAmjFvuscCGpj(XK0fjRWV8Je43QBvmtc4izaKOEaljR4xJ9Je07CrIhbqYKaBsKetHxrsahjoKQpnsMemA)Ijz3XKO4HjMTysoo27QleKaosAmjDrYt3i2hJf71dFTBSmUMRjGhwR9ldD9BcC5rAgIeLKKajJR5Ac4Xpn4GcC5rAgIeLKe9FVaE875AD443X4DpsZKOKKnKe9FVaB1TkMZ6F5x44yVlmjjrc8HeLKWwDRI5qxz9V8JeLKe9FVG61XGdQDD2pRxTnR(1y)ciD9NjbEKSkQsKK0usI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKKKcKSkQsKeLK445CDwfGMpssIeytIKKMsceycoKRonsoJr7xCgYJDeC44yVlmjjrIINK0usC70Gk4qU60i5mgTFXzip2rWHUYpDJyFizljkjjbsSaGgcGUcwp3LnCSdbNXyy6vt0WeglC5rAgYWCglUDAqzSGh)W)dbBSaXy71QtdkJftgZKSm(H)hcMeyBfp7KOEalMeVGib6hRsIPWRijO35IeuykyPyLLeWrYSZKadaxZoChjr)3JKgtIhb(djdGKNR1KaEpsahjWb(WiejwxLetHxrJf71dFTBSe9FVaO4zhNTA2VmYg3Gk8vjjnLKO)7fw3f0XqzowfGMVyUMmx8HOnpo8vjjnLKO)7fSEUlB4RsIss2qs0)9cNJKlWhNFhxMhCHJJ9UWKapsqyHcXoQjb(sILBnjBiXXZ56SkanFKalswzIKSLeLKe9FVW5i5c8X53XL5bx4RssAkjjqs0)9cNJKlWhNFhxMhCHVkjkjjbsSaGgcGUcNJKlWhNFhxMhCHJDi4ijnLKeiXcqYLxtajxZoChjBjjnLehpNRZQa08rssKaBsKeLKWwDRI5qxzVGZymm9QMzycJfU8indzyoJf3onOmwWJF4)HGnwGyS9A1PbLXIjo4izaKe7RzsMDMKigpKaEKSm(PbhejrWrcEC76UqqspK8vjbg(B7AnCK0fjEbhjWVv3QyMKO)qYk(1y)iPX1qIhb(djdGKiMe1dyTmKXI96HV2nwgxZ1eWJFAWbf4YJ0mejkjjbsUFXpWHGdthZObxLHo2JJ6cIVadd)TQkdrIss2qs0)9c4Xpn4GcFvsstjXXZ56SkanFKKejWMejzljkjj6)Eb84NgCqb8421Kapswjjkjzdjr)3lWwDRI5mgO9l8vjjnLKO)7fyRUvXCw)l)cFvs2sIssI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKapswvXLijkjzdjwaqdbqxbRN7Ygoo27ctssKywIKKMsscKG0V2J0CWckKG1CgIXWvwsusIfGKlVMq1i2N8Zzs2AmgME1vnmHXcxEKMHmmNXIBNgugl4Xp8)qWglqm2ET60GYyXK8Jvjzz8d)pemjDrItIIdMy2sYcq7hjWVv3QygLKabkyCirZdj9qI6bSKSIFn2ps2m7(qsJjz3lindrseCKW9SZhjZotYY43Z1As0DXKaosMDMetHxXKGnjsIUlMKh4izz8d)pe8wusceOGXHeas(qF9WK4fjW2kE2jr9aws8cIenpKm7mjEeajtIUlMKDVG0mjlJFAWbzSyVE4RDJLei5(f)ahcomDmJgCvg6ypoQli(cmm83QQmejkjzdjr)3lOEDm4GAxN9Z6vBZQFn2Vasx)zsGhjRQ4sKK0usI(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZKapswfvjsIssgxZ1eWdR1(LHU(nbU8indrYwsuss0)9cSv3QyoJbA)chh7DHjjjsuCKOKe2QBvmh6kJbA)irjjjqs0)9cGINDCwLplRonOcFvsusscKmUMRjGh)0GdkWLhPzisusIfa0qa0vW65USHJJ9UWKKejkosusYgsSaGgcGUcR7c6yOmwTVEWHJJ9UWKKejkosstjjbsSaKC51ewd31ErYwJXW0RUsdtySWLhPzidZzS42PbLXsXOZXaqzSaXy71QtdkJftgZKysbafMKUizf(LFKa)wDRIzs8cIeSJKjb2Ex)GP5)R1KysbafjpWrckmfSuSYsIxqKadSlOJHib(JvbO5lMRXyXE9Wx7glBij6)Eb2QBvmN1)YVWXXExyssIeg1S9pCE6yMK0us2qID3pemMefizvsusYX2D)qW5PJzsGhjOIKTKKMsID3pemMefizLKSLeLK4Qz7oBxtIssq6x7rAoGDKC(bUS1ZDzngdtVQIyycJfU8indzyoJf71dFTBSSHKO)7fyRUvXCw)l)chh7DHjjjsyuZ2)W5PJzsusscKybi5YRjSgUR9IK0us2qs0)9cR7c6yOmhRcqZxmxtMl(q0Mhh(QKOKelajxEnH1WDTxKSLK0us2qID3pemMefizvsusYX2D)qW5PJzsGhjOIKTKKMsID3pemMefizLKKMss0)9cwp3Ln8vjzljkjXvZ2D2UMeLKG0V2J0Ca7i58dCzRN7YAS42PbLXYURF5yaOmgdtVkQmmHXcxEKMHmmNXI96HV2nw2qs0)9cSv3QyoR)LFHJJ9UWKKejmQz7F480XmjkjjbsSaKC51ewd31ErsAkjBij6)EH1DbDmuMJvbO5lMRjZfFiAZJdFvsusIfGKlVMWA4U2ls2ssAkjBiXU7hcgtIcKSkjkj5y7UFi480XmjWJeurYwsstjXU7hcgtIcKSssstjj6)EbRN7Yg(QKSLeLK4Qz7oBxtIssq6x7rAoGDKC(bUS1ZDznwC70GYy5916CmaugJHPxf(yycJfU8indzyoJfigBVwDAqzSyYyMeyla8tcOiXczS42PbLXcA)UgCzWlZ6FXgJHPxvXzycJfU8indzyoJf3onOmwWJFV(yJfigBVwDAqzSyYyMKLXVxFmjdGe1dyjzbO9Je43QBvmJssqHPGLIvws2DmjAgJjz6yMKz3lsCsGToF2jHrnB)dtIMFdjGJeqPHJKv4x(rc8B1TkMjPXK8vnwSxp81UXcB1TkMdDL1)YpsstjHT6wfZbmq7xUyupKKMscB1TkMdEbxUyupKKMss0)9cO97AWLbVmR)fh(QKOKKO)7fyRUvXCw)l)cFvsstjzdjr)3ly9Cx2WXXExysGhjUDAqfqF(ShyuZ2)W5PJzsuss0)9cwp3Ln8vjzRXyy6vv8gMWyHlpsZqgMZybIX2RvNguglMmMjb268zNeWSZh6gZKGEVT7K0ys6IKfG2psGFRUvXmkjbfMcwkwzjbCKmasupGLKv4x(rc8B1TkMnwC70GYyb95ZUXyy6vHngMWyHlpsZqgMZybIX2RvNguglMFxRN97BS42PbLXY9RSBNguzDJhJfDJNC5XSXYZ16z)(gJXySOESfeh5JHjmmTzgMWyXTtdkJL1DbDmugR2xpyJfU8indzyoJXW0RAycJfU8indzyoJfGQXcMhJf3onOmwq6x7rA2ybPR)SXsIglqm2ET60GYyXe7mji9R9intsJjbZdjdGKejbDp7KuasWJpKaks(yMK56AnpyusIzKGENlsMDMKxF4HeqXK0ysafjFmJsswLK(rYSZKGzlOGiPXK4fejRKK(rsey2jXp2ybPF5YJzJfqL)yopxxR5Xymm9knmHXcxEKMHmmNXcq1yXHGmwC70GYybPFThPzJfKU(ZglMzSyVE4RDJL56AnpHXSWh7rAMeLKmxxR5jmMfSaGgcGUcq)ZNgugli9lxEmBSaQ8hZ556AnpgJHPvedtySWLhPzidZzSaunwCiiJf3onOmwq6x7rA2ybPR)SXYQgl2Rh(A3yzUUwZtywn8XEKMjrjjZ11AEcZQblaOHaORa0)8PbLXcs)YLhZglGk)XCEUUwZJXyyAuzycJf3onOmwIbGADx5h4Inw4YJ0mKH5mgdtdFmmHXcxEKMHmmNXIBNguglOpF2nw0DXzlKXIzjASyVE4RDJLnKWwDRI5G(x(Llg1djPPKWwDRI5qxzmq7hjPPKWwDRI5qx5iWStsAkjSv3Qyo4fC5Ir9qYwJfigBVwDAqzSSIhBD8qYQKaBD(StIxqK4KSm(H)hcMeqrYIjibDp7Ky6gX(qI53zs8cIeZbmLjibCKSm(96Jjbm78HUXSXyyAfNHjmw4YJ0mKH5mwSxp81UXYgsyRUvXCq)l)YfJ6HK0usyRUvXCORmgO9JK0usyRUvXCORCey2jjnLe2QBvmh8cUCXOEizljkjr9yKbZcOpF2jrjjjqI6XidRgqF(SBS42PbLXc6ZNDJXW0kEdtySWLhPzidZzSyVE4RDJLei5(f)ahcoe5AVSCg8YUwNN9UqGdC5rAgIK0ussGelajxEnHQrSp5NZKKMsscKGvzTop(HGhCap(9CTMefiXmsstjjbsgxZ1ekF(hJZrU2llh4YJ0mejPPKSHe2QBvmhWaTF5Ir9qsAkjSv3Qyo0vw)l)ijnLe2QBvmh6khbMDsstjHT6wfZbVGlxmQhs2AS42PbLXcE871hBmgMg2yycJfU8indzyoJf71dFTBSC)IFGdbhICTxwodEzxRZZExiWbU8indrIssSaKC51eQgX(KFotIssWQSwNh)qWdoGh)EUwtIcKyMXIBNgugl4Xp8)qWgJXymgli5d3GYW0RM4QMLOISAIglO9R6cb2yb2YuM0MwXmnSDMpsiXe7mjDSk4gsEGJeyeIF(xpWijhdd)9XqKGbXmj(FaX(WqKy39cbJduYRqxmjWhZhjOaui5Byisw6yuqcgUACutIIIKbqYk8DsGAKnUbfjav(8bCKSbwBjzZQOEBGsEf6IjrXz(ibfGcjFddrcmoxxR5jywagegjzaKaJZ11AEcJzbyqyKKnRI6Tbk5vOlMefN5JeuakK8nmejW4CDTMNWQbyqyKKbqcmoxxR5jmRgGbHrs2SkQ3gOKxHUysmZmZhjOaui5ByisGX7x8dCi4amimsYaibgVFXpWHGdWGbU8indbJKSXmuVnqjVcDXKyMzMpsqbOqY3WqKaJZ11AEcMfGbHrsgajW4CDTMNWywagegjzJzOEBGsEf6IjXmZmFKGcqHKVHHibgNRR18ewnadcJKmasGX56AnpHz1amimsYgZq92aL8k0ftIzRA(ibfGcjFddrcmE)IFGdbhGbHrsgajW49l(boeCagmWLhPziyKKnMH6Tbk5vOlMeZw18rckafs(ggIeyCUUwZtWSamimsYaibgNRR18egZcWGWijBmd1BduYRqxmjMTQ5JeuakK8nmejW4CDTMNWQbyqyKKbqcmoxxR5jmRgGbHrs2ygQ3gOKxHUysmBLMpsqbOqY3WqKaJ3V4h4qWbyqyKKbqcmE)IFGdbhGbdC5rAgcgjzZQOEBGsMsg2YuM0MwXmnSDMpsiXe7mjDSk4gsEGJeyu9ylioYhyKKJHH)(yisWGyMe)pGyFyisS7EHGXbk5vOlMKvA(ibfGcjFddrcmoxxR5jywagegjzaKaJZ11AEcJzbyqyKKnRI6Tbk5vOlMefX8rckafs(ggIeyCUUwZty1amimsYaibgNRR18eMvdWGWijBwf1BduYRqxmjkEZhjOaui5ByisGX7x8dCi4amimsYaibgVFXpWHGdWGbU8indbJKSXmuVnqjVcDXKaBmFKGcqHKVHHibgVFXpWHGdWGWijdGey8(f)ahcoadg4YJ0memsYgZq92aLmLmSLPmPnTIzAy7mFKqIj2zs6yvWnK8ahjWOdyyKKJHH)(yisWGyMe)pGyFyisS7EHGXbk5vOlMKvA(ibfGcjFddrcmE)IFGdbhGbHrsgajW49l(boeCagmWLhPziyKKnMH6Tbk5vOlMe4J5JeuakK8nmejlDmkibdxnoQjrrPOizaKScFNKya0x)XKau5ZhWrYgf1ws2ygQ3gOKxHUysu8MpsqbOqY3WqKS0XOGemC14OMeffjdGKv47Ka1iBCdksaQ85d4izdS2sYgZq92aL8k0ftIzMz(ibfGcjFddrYshJcsWWvJJAsuuKmaswHVtcuJSXnOibOYNpGJKnWAljBmd1BduYRqxmjMbBmFKGcqHKVHHizPJrbjy4QXrnjkksgajRW3jbQr24guKau5ZhWrYgyTLKnMH6Tbk5vOlMKvnZ8rckafs(ggIKLogfKGHRgh1KOOizaKScFNeOgzJBqrcqLpFahjBG1ws2ygQ3gOKxHUyswf(y(ibfGcjFddrYshJcsWWvJJAsuuKmaswHVtcuJSXnOibOYNpGJKnWAljBwf1BduYuYWwMYK20kMPHTZ8rcjMyNjPJvb3qYdCKaJpxRN97dJKCmm83hdrcgeZK4)be7ddrID3lemoqjVcDXKSQ5JeuakK8nmejlDmkibdxnoQjrrrYaizf(ojqnYg3GIeGkF(aos2aRTKSXmuVnqjtjdBzktAtRyMg2oZhjKyIDMKowfCdjpWrcmIhyKKJHH)(yisWGyMe)pGyFyisS7EHGXbk5vOlMefX8rckafs(ggIey8(f)ahcoadcJKmasGX7x8dCi4amyGlpsZqWijBmd1BduYRqxmjMzM5JeuakK8nmejlDmkibdxnoQjrrPOizaKScFNKya0x)XKau5ZhWrYgf1ws2ygQ3gOKxHUysmBvZhjOaui5Byisw6yuqcgUACutIIsrrYaizf(ojXaOV(JjbOYNpGJKnkQTKSXmuVnqjVcDXKSAIMpsqbOqY3WqKS0XOGemC14OMeffjdGKv47Ka1iBCdksaQ85d4izdS2sYgZq92aLmLmSLPmPnTIzAy7mFKqIj2zs6yvWnK8ahjWyeWhyKKJHH)(yisWGyMe)pGyFyisS7EHGXbk5vOlMeZGnMpsqbOqY3WqKS0XOGemC14OMeffjdGKv47Ka1iBCdksaQ85d4izdS2sYMvI6Tbk5vOlMKvt08rckafs(ggIKLogfKGHRgh1KOOizaKScFNeOgzJBqrcqLpFahjBG1ws2ygQ3gOKPKvSyvWnmejWhsC70GIeDJhCGs2yr9aVwZglWoStI5CTxwMetY9Bikzyh2jXKYHJKvrjjRM4QMrjtjd7WojOy3lem28rjd7WojkAsmfeedrYcq7hjMJ94aLmSd7KOOjbf7EHGHiz8dbp5(rI1XmMKbqIfoRMZJFi4bhOKHDyNefnjM0CmajdrYVk2YySFWrcs)ApsZys20boGssupgzgp(H)hcMefDsKOEmYaE8d)pe82aLmSd7KOOjXuibnejQhBD80fcsGToF2jPFK0dmIjz2zsqFGcbjWVv3Qyoqjd7WojkAsmP81mjOauibRzsMDMKf1(6btItIUNrZKedoMKNMrDhPzs20psGd8jz3HkyCizVhs6HeCh)1Jxm4J1Wrc6E2jXCW2mLjibMKGcwZ4PDnjMs3iQyUgusspWiej41T62aLmSd7KOOjXKYxZKedWdjW4RrSp5JJ9UWWijylx(1amjUQQgosgajramMKxJyFWKaknCbkzkz3onOWb1JTG4iFuyDxqhdLXQ91dMsg2jXe7mji9R9intsJjbZdjdGKejbDp7KuasWJpKaks(yMK56AnpyusIzKGENlsMDMKxF4HeqXK0ysafjFmJsswLK(rYSZKGzlOGiPXK4fejRKK(rsey2jXpMs2TtdkCq9ylioYhyQaSq6x7rAgLLhZkaQ8hZ556AnpOePR)Scjsj72PbfoOESfeh5dmvawi9R9inJYYJzfav(J58CDTMhucuvWHGqjsx)zfmdL9tH56AnpbZcFShPzLZ11AEcMfSaGgcGUcq)ZNguuYUDAqHdQhBbXr(atfGfs)ApsZOS8ywbqL)yopxxR5bLavfCiiuI01FwHvrz)uyUUwZty1Wh7rAw5CDTMNWQblaOHaORa0)8PbfLSBNgu4G6XwqCKpWubyfda16UYpWftjd7KSIhBD8qYQKaBD(StIxqK4KSm(H)hcMeqrYIjibDp7Ky6gX(qI53zs8cIeZbmLjibCKSm(96Jjbm78HUXmLSBNgu4G6XwqCKpWubyH(8zhL6U4SfsbZseL9tHnSv3QyoO)LF5Ir9KMYwDRI5qxzmq7xAkB1TkMdDLJaZEAkB1TkMdEbxUyupBPKD70Gchup2cIJ8bMkal0Np7OSFkSHT6wfZb9V8lxmQN0u2QBvmh6kJbA)stzRUvXCORCey2ttzRUvXCWl4YfJ6zRs1JrgmlG(8zxzcQhJmSAa95ZoLSBNgu4G6XwqCKpWubyHh)E9XOSFkKW9l(boeCiY1Ez5m4LDTop7DHaNMMGfGKlVMq1i2N8Z500eWQSwNh)qWdoGh)EUwRGzPPjmUMRju(8pgNJCTxwoWLhPzO00nSv3QyoGbA)YfJ6jnLT6wfZHUY6F5xAkB1TkMdDLJaZEAkB1TkMdEbxUyupBPKD70Gchup2cIJ8bMkal84h(Fiyu2pfUFXpWHGdrU2llNbVSR15zVleyLwasU8AcvJyFYpNvIvzTop(HGhCap(9CTwbZOKPKHDyNe4h1S9pmejms(GJKPJzsMDMe3oGJKgtIJ0BThP5aLSBNguyfWaTF5i2JPKHDsw4btIPaWpjGIKvctsq3Zo4pKaD9BiXlisq3ZojlJFAWbrIxqKSkmjbm78HUXmLSBNguyfq6x7rAgLLhZk04SdyuI01FwbSkR15Xpe8Gd4XVNR1jzMYnjmUMRjGh)0GdkWLhPzO00X1Cnb8WATFzORFtGlpsZqBttXQSwNh)qWdoGh)EUwN0QuYWojl8GjXQzhjtc6DUizz871htI1ls27HKvHjjJFi4btc692UtsJj5ynJ0RHKh4iz2zsGFRUvXmjdGKiMe1JF8DmejEbrc692UtYR1A(izaKyD8qj72PbfgMkalK(1EKMrz5XScnoB1SJKrjsx)zfWQSwNh)qWdoGh)E9XjzgLmStIjJzsmhFy(w3fcsq3ZojOWuWsXkljGJe)n8rckafsWAMKUibfMcwkwzPKD70GcdtfGveFy(w3fcu2pf2KGfGKlVMq1i2N8Z500eSaGgcGUcwqHeSMZZoNXQ91do8v3Qm6)EbRN7Ygoo27cNKzOIsg2jzfbdjO7zNeNeuykyPyLLKz3hsACbJdjojR4xJ9Je1dyjbCKGENlsMDMKxJyFiPXK4rG)qYaiHlikz3onOWWubyPcMguOSFke9FVG1ZDzdhh7DHtYmuLMgbWyLVgX(Kpo27cdVvrfLmStckCT9R9HXKGENND(i5J7cbjOauibRzskaAsq3AnjUwdqtcCGpjdGe80AnjwhpKm7mjypMjXJb)Aib8ibfGcjyndtuykyPyLLeRJhmLSBNguyyQaSq6x7rAgLLhZkybfsWAodXy4klkr66pRGLB9MnDn8Pc0(Wq5xJyFYhh7DHv0MHkfTfa0qa0vW65USHJJ9UWBvuMP4tCRcwU1B201WNkq7ddLFnI9jFCS3fwrBgQu0MTAIkAlaOHaORGfuibR58SZzSAF9Gdhh7DH3QOmtXN4wLjCEdLzKCnbhcchyu34bNMAbaneaDfSEUlB44yVlCsDn8Pc0(Wq5xJyFYhh7DHttTaGgcGUcwqHeSMZZoNXQ91doCCS3foPUg(ubAFyO8RrSp5JJ9UWkAZsmnnblajxEnHQrSp5NZPPUDAqfSGcjynNNDoJv7RhCaQXEKMHOKHDsmzmdrYaibI1oCKm7mjFSJGjb8ibfMcwkwzjb9oxK8XDHGeiWpsZKaks(yMeVGir9yKCnK8XocMe07CrIxK4qqKWi5AiPXK4rG)qYaibQzkz3onOWWubyH0V2J0mklpMvWcLTGcQNguOePR)ScBg)qWty6yopGmuZjzgQstpVHYmsUMGdbHdDLeQsCRYnBsGHH)wvLHcCSkCh76m4GkVSCAQfa0qa0vGJvH7yxNbhu5LLdhh7DHHNzWNevMGfa0qa0vGJvH7yxNbhu5LLdh7qWTv5Mni9R9inhav(J58CDTMhfmlnfPFThP5aOYFmNNRR18OWk3QCZCDTMNGzHJDi4YwaqdbqxPPZ11AEcMfSaGgcGUchh7DHtQRHpvG2hgk)Ae7t(4yVlSI2Se3MMI0V2J0Cau5pMZZ11AEuyvLBMRR18ewnCSdbx2caAia6knDUUwZty1Gfa0qa0v44yVlCsDn8Pc0(Wq5xJyFYhh7DHv0ML420uK(1EKMdGk)XCEUUwZJcjUnn1cqYLxtynCx71wkzyNetgZKa)XQWDSRjb22bvEzzswnrmBXKeXpWXK4KGctblfRSK8XCGs2TtdkmmvawFmN7HJrz5XScCSkCh76m4GkVSmk7NcwaqdbqxbRN7Ygoo27cdVvtuPfa0qa0vWckKG1CE25mwTVEWHJJ9UWWB1ettJaySYxJyFYhh7DHH3kvCuYWojMmMjzb81AE6cbjM0)i4ib(GzlMKi(boMeNeuykyPyLLKpMduYUDAqHHPcW6J5CpCmklpMvad(AnptxiY3pcou2pfSaGgcGUcwp3LnCCS3fgEWhLjG0V2J0CWckKG1CgIXWv20ulaOHaORGfuibR58SZzSAF9Gdhh7DHHh8rjs)ApsZblOqcwZzigdxzttJaySYxJyFYhh7DHH3QOIs2TtdkmmvawFmN7HJrz5XScDHT3F8inNHHFVMFCgIr2wgL9tHO)7fSEUlB44yVlCsMHkkzyNetS3ysAmjojNp78rcR9iW5dtcAhosgajX(AMexRjbuK8Xmj4XhsMRR18GjzaKeXKO7IHi5Rsc6E2jbfMcwkwzjXlisqbOqcwZK4fejFmtYSZKSAbrcwdgsafjwis6hjrGzNK56Anpys8JjbuK8Xmj4XhsMRR18GPKD70GcdtfG1CDTMhZqz)uaPFThP5aOYFmNNRR18OWQktyUUwZty1WXoeCzlaOHaOR00ni9R9inhav(J58CDTMhfmlnfPFThP5aOYFmNNRR18OWk3QCt0)9cwp3Ln8vttTaGgcGUcwp3LnCCS3fgMRM0CDTMNGzblaOHaORa0)8PbLYnjybi5YRjunI9j)ConnbK(1EKMdwqHeSMZqmgUYUvzcwasU8AcRH7AVstTaKC51eQgX(KFoRePFThP5GfuibR5meJHRSkTaGgcGUcwqHeSMZZoNXQ91do8vvMGfa0qa0vW65USHVQYnBI(VxGT6wfZz9V8lCCS3fojZsmnn6)Eb2QBvmNXaTFHJJ9UWjzwIBvMW9l(boeCiY1Ez5m4LDTop7DHaNMUj6)EHix7LLZGx2168S3fcCU85FCapUDTcOknn6)EHix7LLZGx2168S3fcC2pRxCapUDTcOA7200O)7fw3f0XqzowfGMVyUMmx8HOnpo8v3MMgbWyLVgX(Kpo27cdVvtmnfPFThP5aOYFmNNRR18OqIuYUDAqHHPcWAUUwZZQOSFkG0V2J0Cau5pMZZ11AEsqHvvMWCDTMNGzHJDi4YwaqdbqxPPi9R9inhav(J58CDTMhfwv5MO)7fSEUlB4RMMAbaneaDfSEUlB44yVlmmxnP56AnpHvdwaqdbqxbO)5tdkLBsWcqYLxtOAe7t(5CAAci9R9inhSGcjynNHymCLDRYeSaKC51ewd31ELMAbi5YRjunI9j)Cwjs)ApsZblOqcwZzigdxzvAbaneaDfSGcjynNNDoJv7RhC4RQmblaOHaORG1ZDzdFvLB2e9FVaB1TkMZ6F5x44yVlCsMLyAA0)9cSv3QyoJbA)chh7DHtYSe3QmH7x8dCi4qKR9YYzWl7ADE27cbonDt0)9crU2llNbVSR15zVle4C5Z)4aEC7AfqvAA0)9crU2llNbVSR15zVle4SFwV4aEC7Afq12TBttJ(VxyDxqhdL5yvaA(I5AYCXhI284WxnnncGXkFnI9jFCS3fgERMyAks)ApsZbqL)yopxxR5rHePKHDsmzmJjX1AsaZoFKaks(yMKE4ymjGIeleLSBNguyyQaS(yo3dhJrz)ui6)EbRN7Yg(QPPwasU8AcvJyFYpNvI0V2J0CWckKG1CgIXWvwLwaqdbqxblOqcwZ5zNZy1(6bh(QktWcaAia6ky9Cx2Wxv5Mnr)3lWwDRI5S(x(foo27cNKzjMMg9FVaB1TkMZyG2VWXXEx4KmlXTkt4(f)ahcoe5AVSCg8YUwNN9UqGttVFXpWHGdrU2llNbVSR15zVleyLBI(VxiY1Ez5m4LDTop7DHaNlF(hhWJBxN0kttJ(VxiY1Ez5m4LDTop7DHaN9Z6fhWJBxN0k3Unnn6)EH1DbDmuMJvbO5lMRjZfFiAZJdF100iagR81i2N8XXExy4TAIuYWojMe22qmjUDAqrIUXdjroMHibuKG757tdkyPzenMs2Ttdkmmvaw3VYUDAqL1nEqz5XScoGrjEU2okygk7Nci9R9inhAC2bmLSBNguyyQaSUFLD70GkRB8GYYJzfIa(Gs8CTDuWmu2pfUFXpWHGdrU2llNbVSR15zVle4add)TQkdrj72PbfgMkaR7xz3onOY6gpOS8ywb8qjtjd7KGcxB)AFymjO35zNpsMDMetYXES1h7oFKe9Fpsq3AnjpxRjb8EKGUN9Uiz2zskg1djwhpuYUDAqHdoGvaPFThPzuwEmRa0XECgDR15NR1zW7HsKU(ZkSj6)EHPJz0GRYqh7XrDbXx44yVlm8qyHcXoQHzIbZstJ(Vxy6ygn4Qm0XECuxq8foo27cdp3onOc4XVxFCGrnB)dNNoMHzIbZuUHT6wfZHUY6F5xAkB1TkMdyG2VCXOEstzRUvXCWl4YfJ6z7wLr)3lmDmJgCvg6ypoQli(cFvL3V4h4qWHPJz0GRYqh7XrDbXxGHH)wvLHOKHDsqHRTFTpmMe078SZhjlJF4)HGjPXKGgCZojwhpDHGeas(izz871htsxKSc)YpsGFRUvXmLSBNgu4GdyyQaSq6x7rAgLLhZk0ikWXz84h(FiyuI01FwHeyRUvXCORmgO9t5gSkR15Xpe8Gd4XVxFCsOs54AUMag81zWlp7C(bogpbU8indLMIvzTop(HGhCap(96JtsXTLsg2jXKXmjOauibRzsqVZfj(qIMXysMDVibvjsIPWRijEbrIUlMKVkjO7zNeuykyPyLLs2TtdkCWbmmvawwqHeSMZZoNXQ91dgL9tHeGUFdfkq2cHvUzds)ApsZblOqcwZzigdxzvMGfa0qa0vW65USHJDi4stJ(VxW65USHV6wLBC8CUoRcqZh8qvIPPi9R9inhAef44mE8d)pe8wLBI(VxGT6wfZz9V8lCCS3foj4tAA0)9cSv3QyoJbA)chh7DHtc(Sv5MeUFXpWHGdrU2llNbVSR15zVle400O)7fICTxwodEzxRZZExiW5YN)Xb8421jTY00O)7fICTxwodEzxRZZExiWz)SEXb8421jTYTPPVgX(Kpo27cdpZsuzcwaqdbqxbRN7Ygo2HGBlLmStIjJzsm)hxMhCKGUNDsqHPGLIvwkz3onOWbhWWubyDosUaFC(DCzEWHY(Pq0)9cwp3LnCCS3fojZqfLmStIjJzsw(1RpMKUir1lioUTKaks8cUzVleKm7(qIUrYysmtrWSftIxqKOzmMe09Stsm4ysg)qWdMeVGiXhsMDMeUGib8iXjzbO9Je43QBvmtIpKyMIqcMTysahjAgJj54yVRUqqIJjzaKuGHKDhzxiizaKC87y8ojq)RleKSc)YpsGFRUvXmLSBNgu4GdyyQaSW)61hJslCwnNh)qWdwbZqz)uyZXVJX7EKMttJ(VxGT6wfZzmq7x44yVlm8wPs2QBvmh6kJbA)uECS3fgEMPikhxZ1eWGVodE5zNZpWX4jWLhPzOTkh)qWty6yopGmuZjzMIOOXQSwNh)qWdgMhh7DHvUHT6wfZHUYEbxA6XXExy4HWcfIDuVLsg2jbgiZQK8vjzz875Anj(qIR1KmDmJj5xAgJj5J7cbjRaCw)CmjEbrspK0ys8iWFizaKOEaljGJenpKm7mjyv22UMe3onOir3ftseRbOjz3lintIj5ypoQli(ibuKSkjJFi4btj72Pbfo4agMkal843Z1Au2pf2e9FVaE875AD443X4DpsZk3GvzTop(HGhCap(9CTgERmnnH7x8dCi4W0XmAWvzOJ94OUG4lWWWFRQYqBtthxZ1eWGVodE5zNZpWX4jWLhPziLr)3lWwDRI5mgO9lCCS3fgERujB1TkMdDLXaTFkJ(Vxap(9CToCCS3fgEkoLyvwRZJFi4bhWJFpxRtsbfzRYnjC)IFGdbh0Wz9ZX5NM5Pleze6owfZbgg(BvvgknD6ywrPOueuLu0)9c4XVNR1HJJ9UWWC1Tkh)qWty6yopGmuZjHkkzyNeyRE2jXKCShh1feFK8XmjlJFpxRjzaKSMzvs(QKm7mjr)3JKi4iX1yajFCxiizz875AnjGIeurcMTGcctc4irZymjhh7D1fckz3onOWbhWWubyHh)EUwJY(PW9l(boeCy6ygn4Qm0XECuxq8fyy4VvvziLyvwRZJFi4bhWJFpxRtsHvQCtcr)3lmDmJgCvg6ypoQli(cFvLr)3lGh)EUwho(DmE3J0CA6gK(1EKMdqh7Xz0TwNFUwNbVNYnr)3lGh)EUwhoo27cdVvMMIvzTop(HGhCap(9CToPvvoUMRjGhwR9ldD9BcC5rAgsz0)9c4XVNR1HJJ9UWWdvB3ULsg2jbfU2(1(WysqVZZoFK4KSm(H)hcMKpMjbDR1Ky9pMjzz875AnjdGKNR1KaEpusIxqK8XmjlJF4)HGjzaKSMzvsmjh7XrDbXhj4XTRj5Rsj72Pbfo4agMkalK(1EKMrz5XSc4XVNR1z0GAYpxRZG3dLiD9NvWXZ56SkanFjP4turVXSeHVr)3lmDmJgCvg6ypoQli(c4XTR3QO3e9FVaE875AD44yVlm8DLkkSkR15Dhp8wf9giWeE)dUm4Lz9V4WXXExy4lQ2Qm6)Eb843Z16WxLsg2jXKXmjlJF4)HGjbDp7Kyso2JJ6cIpsgajRzwLKVkjZots0)9ibDp7G)qIgG7cbjlJFpxRj5RoDmtIxqK8XmjlJF4)HGjbuKOiWKeZbmLjibpUDnMKFnTMefHKXpe8GPKD70GchCadtfGfE8d)pemk7Nci9R9inhGo2JZOBTo)CTodEpLi9R9inhWJFpxRZOb1KFUwNbVNYeq6x7rAo0ikWXz84h(Fi400nr)3le5AVSCg8YUwNN9UqGZLp)Jd4XTRtALPPr)3le5AVSCg8YUwNN9UqGZ(z9Id4XTRtALBvIvzTop(HGhCap(9CTgEkIsK(1EKMd4XVNR1z0GAYpxRZG3Jsg2jXKXmjy0(ftcgqYS7djWb(KGGhsIDutYxD6yMKi4i5J7cbj9qIJjr7dtIJjrfGXDKMjbuKOzmMKz3lswjj4XTRXKaosGb8JhsqVZfjReMKGh3UgtcJA1(ykz3onOWbhWWuby5qU60i5mgTFXO0cNvZ5Xpe8GvWmu2pfsyA76UqOmb3onOcoKRonsoJr7xCgYJDeCOR8t3i2N0uiWeCixDAKCgJ2V4mKh7i4aEC7A4TsLqGj4qU60i5mgTFXzip2rWHJJ9UWWBLuYWojM087y8ojMuaq96JjPFKGctblfRSK0yso2HGdLKm78XK4htIMXysMDVibvKm(HGhmjDrYk8l)ib(T6wfZKGUNDswaJ5hLKOzmMKz3lsmlrsaZoFOBmtsxK4fCKa)wDRIzsahjFvsgajOIKXpe8GjjIFGJjXjzf(LFKa)wDRI5ajMeqbJdjh)ogVtc0)6cbjWa7c6yisG)yvaA(I5Ai5xAgJjPlswaA)ib(T6wfZuYUDAqHdoGHPcWkgaQxFmkTWz1CE8dbpyfmdL9tHJFhJ39inRC8dbpHPJ58aYqnN0MnMPiWCdwL1684hcEWb843Rpg(Uk8n6)Eb2QBvmN1)YVWxD7wyECS3fERIAJzWCCnxtyq3vogakCGlpsZqBvUXcaAia6ky9Cx2WXoeCkta6(nuOazlew5gK(1EKMdwqHeSMZqmgUYMMAbaneaDfSGcjynNNDoJv7RhC4yhcU00eSaKC51eQgX(KFoVnnfRYADE8dbp4aE871hdVnBGpk6nr)3lWwDRI5S(x(f(QW3v3Uf(UXmyoUMRjmO7khdafoWLhPzOTBvMaB1TkMdyG2VCXOEst3WwDRI5qxzmq7xA6g2QBvmh6khbM90u2QBvmh6kR)LFBvMW4AUMag81zWlp7C(bogpbU8indLMg9FVG61XGdQDD2pRxTnR(1y)ciD9NtsHvrvIBvUbRYADE8dbp4aE871hdpZse(UXmyoUMRjmO7khdafoWLhPzOTBv645CDwfGMVKqvIk6O)7fWJFpxRdhh7DHHVWNTk3Kq0)9cR7c6yOmhRcqZxmxtMl(q0Mhh(QPPSv3Qyo0vgd0(LMMGfGKlVMWA4U2RTuYWojMmMjX8dmnjGIelejO7zh8hsSUQAxiOKD70GchCadtfG1dCwodE5YN)XOSFk4Qz7oBxtjd7KyYyMeuykyPyLLeqrIfIKFPzmMeVGir3ftspK8vjbDp7KGcqHeSMPKD70GchCadtfGLL1mEAxNDDJOI5Aqz)uibO73qHcKTqyLi9R9inhSqzlOG6PbLYnr)3lGh)EUwh(QPPoEoxNvbO5ljuL4wLBsi6)EbmqJN2YHVQYeI(VxW65USHVQYnjybi5YRjunI9j)Con1caAia6kybfsWAop7CgR2xp4WxvPJNZ1zvaA(GhQsCRYXpe8eMoMZdid1CsMHkyAbf0VNG6X2gZzx3iQyUMW0XCgPR)CAAeaJv21WNkq7ddLFnI9jFCS3fgERMimTGc63tq9yBJ5SRBevmxty6yoJ01FElLSBNgu4GdyyQaS6Y6x5tdku2pfsa6(nuOazlewjs)ApsZblu2ckOEAqPCt0)9c4XVNR1HVAAQJNZ1zvaA(scvjUv5MeI(Vxad04PTC4RQmHO)7fSEUlB4RQCtcwasU8AcvJyFYpNttTaGgcGUcwqHeSMZZoNXQ91do8vv645CDwfGMp4HQe3QC8dbpHPJ58aYqnN0QjctlOG(9eup22yo76grfZ1eMoMZiD9NttJaySYUg(ubAFyO8RrSp5JJ9UWWBLjctlOG(9eup22yo76grfZ1eMoMZiD9N3sjd7KyYyMe4pwfGMpsmhOGibuKyHibDp7KSm(9CTMKVkjEbrc2rYK8ahjR4xJ9JeVGibfMcwkwzPKD70GchCadtfGfhRcqZxocuqOSFkebWyLDn8Pc0(Wq5xJyFYhh7DHHNzOknDt0)9cQxhdoO21z)SE12S6xJ9lG01FgERIQettJ(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZjPWQOkXTkJ(Vxap(9CTo8vvUXcaAia6ky9Cx2WXXEx4KqvIPPq3VHcfiBHWBPKHDsmP53X4DsEA)ysafjFvsgajRKKXpe8GjbDp7G)qckmfSuSYsse3fcs8iWFizaKWOwTpMeVGiPadjaK8zDv1Uqqj72Pbfo4agMkal8WATF5N2pgLw4SAop(HGhScMHY(PWXVJX7EKMvoDmNhqgQ5KmdvkXQSwNh)qWdoGh)E9XWtru6Qz7oBxRCt0)9cwp3LnCCS3fojZsmnnHO)7fSEUlB4RULsg2jXKXmjMFa8ts)iPlCdXK4fjWVv3QyMeVGir3ftspK8vjbDp7K4KSIFn2psupGLeVGiXuqU60izswq7xmLSBNgu4GdyyQaSE)dUm4Lz9Vyu2pfyRUvXCORSxWP0vZ2D2Uwz0)9cQxhdoO21z)SE12S6xJ9lG01FgERIQevUbcmbhYvNgjNXO9lod5XocomTDDxisttWcqYLxtOy7b0GdknfRYADE8dbp4KwDlLmStIjJzsCswg)EUwtcSTINDsupGLKFPzmMKLXVNR1K0ysC9XoeCK8vjbCKah4tIFmjEe4pKmasai5Z6QKyk8ksj72Pbfo4agMkal843Z1Au2pfI(Vxau8SJZQ8zz1Pbv4RQCt0)9c4XVNR1HJFhJ39inNM645CDwfGMVKGnjULsg2jXK8JvjXu4vKKi(boMeuakKG1mjO7zNKLXVNR1K4fejZoxKSm(H)hcMs2TtdkCWbmmvaw4XVNR1OSFkybi5YRjunI9j)Cw5gK(1EKMdwqHeSMZqmgUYMMAbaneaDfSEUlB4RMMg9FVG1ZDzdF1TkTaGgcGUcwqHeSMZZoNXQ91doCCS3fgEiSqHyh1Wxl36noEoxNvbO5trHQe3Qm6)Eb843Z16WXXExy4Pikta6(nuOazleMs2TtdkCWbmmvaw4Xp8)qWOSFkybi5YRjunI9j)Cw5gK(1EKMdwqHeSMZqmgUYMMAbaneaDfSEUlB4RMMg9FVG1ZDzdF1TkTaGgcGUcwqHeSMZZoNXQ91doCCS3fgEWhLr)3lGh)EUwh(QkzRUvXCORSxWPmbK(1EKMdnIcCCgp(H)hcwzcq3VHcfiBHWuYWojMmMjzz8d)pemjO7zNeVib2wXZojQhWsc4iPFKah4dJqKaqYN1vjXu4vKe09StcCG)rsXOEiX64jqIP0yajq)yvmjMcVIK4djZotcxqKaEKm7mjWaW1Sd3rs0)9iPFKSm(9CTMe0GVgQGXHKNR1KaEpsafjkcjGJenJXKm(HGhmLSBNgu4GdyyQaSWJF4)HGrz)ui6)EbqXZooB1SFzKnUbv4RMMUjb843Rpo4Qz7oBxRmbK(1EKMdnIcCCgp(H)hconDt0)9cwp3LnCCS3fgEOsz0)9cwp3Ln8vtt3e9FVW5i5c8X53XL5bx44yVlm8qyHcXoQHVwU1BC8CUoRcqZNIALjUvz0)9cNJKlWhNFhxMhCHV62Tkr6x7rAoGh)EUwNrdQj)CTodEpLyvwRZJFi4bhWJFpxRH3k3QCtc3V4h4qWHPJz0GRYqh7XrDbXxGHH)wvLHstXQSwNh)qWdoGh)EUwdVvULsg2jXKXmjMuaqHjPlswaA)ib(T6wfZK4fejyhjtI5)R1KysbafjpWrckmfSuSYsj72Pbfo4agMkaRIrNJbGcL9tHnr)3lWwDRI5mgO9lCCS3fojg1S9pCE6yonDJD3pemwHvvESD3peCE6ygEOABAQD3pemwHvUvPRMT7SDnLSBNgu4GdyyQaS2D9lhdafk7NcBI(VxGT6wfZzmq7x44yVlCsmQz7F480XCA6g7UFiyScRQ8y7UFi480Xm8q120u7UFiyScRCRsxnB3z7Akz3onOWbhWWuby9(ADogaku2pf2e9FVaB1TkMZyG2VWXXEx4KyuZ2)W5PJzLBSaGgcGUcwp3LnCCS3fojuLyAQfa0qa0vWckKG1CE25mwTVEWHJJ9UWjHQe3MMUXU7hcgRWQkp2U7hcopDmdpuTnn1U7hcgRWk3Q0vZ2D2UMsg2jXKXmjWwa4NeqrckmjuYUDAqHdoGHPcWcTFxdUm4Lz9VykzyNeu4A7x7dJjb9op78rYai5Jzswg)E9XK0fjlaTFKGEVT7K0ys8HeurY4hcEWW0msEGJegjFWrYQjQOij2XdFWrc4irrizz8d)pemjWFSkanFXCnKGh3Ugtj72Pbfo4agMkalK(1EKMrz5XSc4XVxFCURmgO9dLiD9NvaRYADE8dbp4aE871hNKIaZNgaUnXoE4dUmsx)z4RzjMOIA1e3cZNgaUnr)3lGh)W)dbN5yvaA(I5AYyG2VaEC7AfLISLsg2jXKXmjWwNp7K0fjlaTFKa)wDRIzsahj9JKcqYY43RpMe0TwtYRhs6AaKGctblfRSK4fCXGJPKD70GchCadtfGf6ZNDu2pf2WwDRI5G(x(Llg1tAkB1TkMdEbxUyupkr6x7rAo04SvZosERYnJFi4jmDmNhqgQ5KuK0u2QBvmh0)YVCx5vttFnI9jFCS3fgEML4200O)7fyRUvXCgd0(foo27cdp3onOc4XVxFCGrnB)dNNoMvg9FVaB1TkMZyG2VWxnnLT6wfZHUYyG2pLjG0V2J0Cap(96JZDLXaTFPPr)3ly9Cx2WXXExy452Pbvap(96JdmQz7F480XSYeq6x7rAo04SvZoswz0)9cwp3LnCCS3fgEmQz7F480XSYO)7fSEUlB4RMMg9FVW5i5c8X53XL5bx4RQeRYADE3XdNuIb4JYnyvwRZJFi4bdpfwzAAcJR5AcyWxNbV8SZ5h4y8e4YJ0m0200eq6x7rAo04SvZoswz0)9cwp3LnCCS3fojg1S9pCE6yMsg2jXKXmjlJFV(ys6hjDrYk8l)ib(T6wfZOKKUizbO9Je43QBvmtcOirrGjjJFi4btc4izaKOEaljlaTFKa)wDRIzkz3onOWbhWWubyHh)E9XuYWojMFxRN97tj72Pbfo4agMkaR7xz3onOY6gpOS8ywHNR1Z(9PKPKHDsm)hxMhCKGUNDsqHPGLIvwkz3onOWHiGpkCosUaFC(DCzEWHY(Pq0)9cwp3LnCCS3fojZqfLmStck2z7Amj9JKzNjXCatzcsSxpKe9FpsAmjfyi5RsYdCKO9Hps(yMs2TtdkCic4dmvawi9R9inJYYJzfSxpfy(QOePR)Scje9FVqKR9YYzWl7ADE27cbox(8po8vvMq0)9crU2llNbVSR15zVle4SFwV4WxLsg2jXKXmjMcYvNgjtYcA)Ijb9oxK4djAgJjz29IefHeZbmLjibpUDnMeVGizaKC87y8ojojWtHvjbpUDnjoMeTpmjoMevag3rAMeWrY0Xmj9qcgqspK431izmjWa(Xdj(B4JeNKvctsWJBxtcJA1(ymLSBNgu4qeWhyQaSCixDAKCgJ2VyuAHZQ584hcEWkygk7Ncr)3le5AVSCg8YUwNN9UqGZLp)Jd4XTRHNIOm6)EHix7LLZGx2168S3fcC2pRxCapUDn8ueLBsacmbhYvNgjNXO9lod5XocomTDDxiuMGBNgubhYvNgjNXO9lod5Xoco0v(PBe7JYnjabMGd5QtJKZy0(fN3zxhM2UUlePPqGj4qU60i5mgTFX5D21HJJ9UWjTYTPPqGj4qU60i5mgTFXzip2rWb8421WBLkHatWHC1PrYzmA)IZqESJGdhh7DHHhQucbMGd5QtJKZy0(fNH8yhbhM2UUleBPKHDsmzmtckafsWAMe09StckmfSuSYsc6DUirfGXDKMjXlisaZoFOBmtc6E2jXjXCatzcsI(VhjO35Ieigdxz7cbLSBNgu4qeWhyQaSSGcjynNNDoJv7Rhmk7NcBq6x7rAoybfsWAodXy4kRYeSaGgcGUcwp3LnCSdbxAA0)9cwp3Ln8v3QCt0)9crU2llNbVSR15zVle4C5Z)4aEC7AfqvAA0)9crU2llNbVSR15zVle4SFwV4aEC7Afq1200iagR81i2N8XXExy4zwIuYWojMFa8tIJjz2zsE9HhsqyHiPlsMDMeNeZbmLjibDxqa0Kaosq3ZojZotcmq4U2lsI(VhjGJe09StItIIhMy2sIPGC1PrYKSG2Vys8cIe0EpK8ahjOWuWsXklj9JKEibnOgsIys(QK4i8UijIFGJjz2zsSqK0ysED14DgIs2TtdkCic4dmvawV)bxg8YS(xmk7NcB2e9FVqKR9YYzWl7ADE27cbox(8poGh3Uojfjnn6)EHix7LLZGx2168S3fcC2pRxCapUDDskYwLBGUFdfkq2cHttTaGgcGUcwp3LnCCS3fojuLyA6glajxEnHQrSp5NZkTaGgcGUcwqHeSMZZoNXQ91doCCS3fojuL42TBtt3abMGd5QtJKZy0(fNH8yhbhoo27cNKIxPfa0qa0vW65USHJJ9UWjzwIkTaKC51ek2Ean4G2MM21WNkq7ddLFnI9jFCS3fgEkELjybaneaDfSEUlB4yhcU00nwasU8AcRH7AVug9FVW6UGogkZXQa08fZ1e(QBPKHDsqHxwwtYY4NgCqKGUNDsCskgnjMdyktqs0)9iXlisqHPGLIvwsACbJdjEe4pKmasIys(ygIs2TtdkCic4dmvawwVSSoh9FpuwEmRaE8tdoiu2pf2e9FVqKR9YYzWl7ADE27cbox(8poCCS3fojfjGQ00O)7fICTxwodEzxRZZExiWz)SEXHJJ9UWjPibuTv5glaOHaORG1ZDzdhh7DHtsXLMUXcaAia6kWXQa08LJafu44yVlCskoLje9FVW6UGogkZXQa08fZ1K5IpeT5XHVQslajxEnH1WDTxB3Q0XZ56SkanFjPWktKsg2jXK8Jvjzz8d)pemMe09StItI5aMYeKe9FpsI(djfyib9oxKOca6UqqYdCKGctblfRSKaosGb2f0XqKSO2xpykz3onOWHiGpWubyHh)EUwJY(PW4AUMaEyT2Vm01VjWLhPziLyEMUqGdyGgKHU(nkJ(Vxap(9CToabqxuYWojMKFSkjlJF4)HGXKGUNDsMDMKiGpKe9FpsI(djfyib9oxKOca6UqqYdCKyDsahjCSkanFKebkikz3onOWHiGpWubyHh)W)dbJY(Pqci9R9inhSxpfy(Qk3ybi5YRjunI9j)Con1caAia6ky9Cx2WXXEx4KuCPPjG0V2J0CWcLTGcQNguktWcqYLxtynCx7vA6glaOHaORahRcqZxocuqHJJ9UWjP4uMq0)9cR7c6yOmhRcqZxmxtMl(q0Mhh(QkTaKC51ewd31ETDRYnjabMW7FWLbVmR)fhM2UUlePPjybaneaDfSEUlB4yhcU00eSaGgcGUcwqHeSMZZoNXQ91doCSdb3wkzyNetYpwLKLXp8)qWysI4h4ysqbOqcwZuYUDAqHdraFGPcWcp(H)hcgL9tHnwaqdbqxblOqcwZ5zNZy1(6bhoo27cdpuPmbO73qHcKTqyLBq6x7rAoybfsWAodXy4kBAQfa0qa0vW65USHJJ9UWWdvBvI0V2J0CWcLTGcQNguBvMaeycV)bxg8YS(xCyA76UqO0cqYLxtOAe7t(5SYeGUFdfkq2cHvYwDRI5qxzVGJsg2jXKakyCibcmKa9VUqqYSZKWfejGhjM0osUaFmjM)JlZdousc0)6cbjR7c6yis4yvaA(I5AibCK0fjZotI2XdjiSqKaEK4fjWVv3QyMs2TtdkCic4dmvawi9R9inJYYJzfGat(yy4VpoMRbJsKU(ZkSj6)EHZrYf4JZVJlZdUWXXEx4KqvAAcr)3lCosUaFC(DCzEWf(QBvUj6)EH1DbDmuMJvbO5lMRjZfFiAZJdhh7DHHhclui2r9wLBI(VxGT6wfZzmq7x44yVlCsiSqHyh1PPr)3lWwDRI5S(x(foo27cNeclui2r9wkz3onOWHiGpWubyH)1RpgLw4SAop(HGhScMHY(PWXVJX7EKMvo(HGNW0XCEazOMtYm4JsxnB3z7ALi9R9inhGat(yy4VpoMRbtj72Pbfoeb8bMkaRyaOE9XO0cNvZ5Xpe8GvWmu2pfo(DmE3J0SYXpe8eMoMZdid1CsMTYaQu6Qz7oBxRePFThP5aeyYhdd)9XXCnykz3onOWHiGpWubyHhwR9l)0(XO0cNvZ5Xpe8GvWmu2pfo(DmE3J0SYXpe8eMoMZdid1CsMbFG5XXExyLUA2UZ21kr6x7rAoabM8XWWFFCmxdMsg2jX8dmnjGIelejO7zh8hsSUQAxiOKD70GchIa(atfG1dCwodE5YN)XOSFk4Qz7oBxtjd7Ka)XQa08rI5afejO35Iepc8hsgajCn8rItsXOjXCatzcsq3feanjEbrc2rYK8ahjOWuWsXklLSBNgu4qeWhyQaS4yvaA(YrGccL9tHnSv3QyoO)LF5Ir9KMYwDRI5agO9lxmQN0u2QBvmh8cUCXOEstJ(VxiY1Ez5m4LDTop7DHaNlF(hhoo27cNKIeqvAA0)9crU2llNbVSR15zVle4SFwV4WXXEx4KuKaQstD8CUoRcqZxsWMevAbaneaDfSEUlB4yhcoLjaD)gkuGSfcVv5glaOHaORG1ZDzdhh7DHtALjMMAbaneaDfSEUlB4yhcUTPPramwzxdFQaTpmu(1i2N8XXExy4zwIuYWojMFa8tY1i2hsI4h4ys(4UqqckmfLSBNgu4qeWhyQaSE)dUm4Lz9Vyu2pfSaGgcGUcwp3LnCSdbNsK(1EKMdwOSfuq90Gs5ghpNRZQa08LeSjrLjybi5YRjunI9j)Con1cqYLxtOAe7t(5SshpNRZQa08bpfjXTk3KGfGKlVMq1i2N8Z50ulaOHaORGfuibR58SZzSAF9Gdh7qWTvzcq3VHcfiBHWuYWojOWuWsXkljO35IeFib2KimjXu4vKKnGtdqZhjZUxKOijsIPWRijO7zNeuakKG18wsq3Zo4pKOb4UqqY0XmjDrI50aaK(Jhs8cIeDxmjFvsq3ZojOauibRzs6hj9qcAhtceJHRSmeLSBNgu4qeWhyQaSSSMXt76SRBevmxdk7NcjaD)gkuGSfcRePFThP5GfkBbfupnOuUzJJNZ1zvaA(sc2KOYnr)3lSUlOJHYCSkanFXCnzU4drBEC4RMMMGfGKlVMWA4U2RTPPr)3lePbai9hpHVQYO)7fI0aaK(JNWXXExy4TAIWCJfuq)EcQhBBmNDDJOI5ActhZzKU(ZB3MMgbWyLDn8Pc0(Wq5xJyFYhh7DHH3QjcZnwqb97jOESTXC21nIkMRjmDmNr66pVnn1cqYLxtOAe7t(58wLBsWcqYLxtOAe7t(5CA6ghpNRZQa08bpfjX0uiWeE)dUm4Lz9V4W021DHyRYni9R9inhSGcjynNHymCLnn1caAia6kybfsWAop7CgR2xp4WXoeCB3sj72Pbfoeb8bMkaRUS(v(0GcL9tHeGUFdfkq2cHvI0V2J0CWcLTGcQNguk3SXXZ56SkanFjbBsu5MO)7fw3f0XqzowfGMVyUMmx8HOnpo8vtttWcqYLxtynCx71200O)7fI0aaK(JNWxvz0)9crAaas)Xt44yVlm8wzIWCJfuq)EcQhBBmNDDJOI5ActhZzKU(ZB3MMgbWyLDn8Pc0(Wq5xJyFYhh7DHH3kteMBSGc63tq9yBJ5SRBevmxty6yoJ01FEBAQfGKlVMq1i2N8Z5Tk3KGfGKlVMq1i2N8Z500noEoxNvbO5dEksIPPqGj8(hCzWlZ6FXHPTR7cXwLBq6x7rAoybfsWAodXy4kBAQfa0qa0vWckKG1CE25mwTVEWHJDi42ULsg2jb(Xth7dJjzhGMK4VDNetHxrs8JjbH3fdrIkFKGzlOGOKD70GchIa(atfGfs)ApsZOS8ywbhRUI8TWwuI01Fwb2QBvmh6kR)LFWxfVIYTtdQaE871hhyuZ2)W5PJzyMaB1TkMdDL1)Yp47g4dmhxZ1eWGVodE5zNZpWX4jWLhPzi47k3QOC70GkG(8zpWOMT)HZthZWmXWQkkSkR15DhpmLmStIj5hRsYY4h(FiymjO35IKzNj51i2hsAmjEe4pKmas4ccLK8oUmp4iPXK4rG)qYaiHliuscCGpj(XK4djWMeHjjMcVIK0fjErc8B1TkMrjjOWuWsXkljAhpys8cm78rIIhMy2IjbCKah4tcAWxdrcajFwxLKyWXKm7ErcLAwIKyk8ksc6DUiboWNe0GVgQGXHKLXp8)qWKua0uYUDAqHdraFGPcWcp(H)hcgL9tHnramwzxdFQaTpmu(1i2N8XXExy4PiPPBI(Vx4CKCb(4874Y8GlCCS3fgEiSqHyh1Wxl36noEoxNvbO5trTYe3Qm6)EHZrYf4JZVJlZdUWxD7200noEoxNvbO5dMi9R9inhCS6kY3cBHVr)3lWwDRI5mgO9lCCS3fgMqGj8(hCzWlZ6FXHPTRX5JJ9UGVRgqvsMzwIPPoEoxNvbO5dMi9R9inhCS6kY3cBHVr)3lWwDRI5S(x(foo27cdtiWeE)dUm4Lz9V4W02148XXExW3vdOkjZmlXTkzRUvXCORSxWPCtcr)3ly9Cx2WxnnnHX1Cnb84NgCqbU8indTv5MnjybaneaDfSEUlB4RMMAbi5YRjSgUR9szcwaqdbqxbowfGMVCeOGcF1TPPwasU8AcvJyFYpN3QCtcwasU8Aci5A2H7stti6)EbRN7Yg(QPPoEoxNvbO5ljytIBtt3mUMRjGh)0GdkWLhPziLr)3ly9Cx2Wxv5MO)7fWJFAWbfWJBxdVvMM645CDwfGMVKGnjUDBAA0)9cwp3Ln8vvMq0)9cNJKlWhNFhxMhCHVQYegxZ1eWJFAWbf4YJ0meLmStIjJzsmPaGctsxKSc)YpsGFRUvXmjEbrc2rYKaBVRFW08)1AsmPaGIKh4ibfMcwkwzPKD70GchIa(atfGvXOZXaqHY(PWMO)7fyRUvXCw)l)chh7DHtIrnB)dNNoMtt3y39dbJvyvLhB39dbNNoMHhQ2MMA39dbJvyLBv6Qz7oBxtj72Pbfoeb8bMkaRDx)YXaqHY(PWMO)7fyRUvXCw)l)chh7DHtIrnB)dNNoMvUXcaAia6ky9Cx2WXXEx4KqvIPPwaqdbqxblOqcwZ5zNZy1(6bhoo27cNeQsCBA6g7UFiyScRQ8y7UFi480Xm8q120u7UFiyScRCRsxnB3z7Akz3onOWHiGpWuby9(ADogaku2pf2e9FVaB1TkMZ6F5x44yVlCsmQz7F480XSYnwaqdbqxbRN7Ygoo27cNeQsmn1caAia6kybfsWAop7CgR2xp4WXXEx4KqvIBtt3y39dbJvyvLhB39dbNNoMHhQ2MMA39dbJvyLBv6Qz7oBxtjd7KaBbGFsafjwikz3onOWHiGpWubyH2VRbxg8YS(xmLmStIjJzswg)E9XKmasupGLKfG2psGFRUvXmjGJe07CrsxKaknCKSc)YpsGFRUvXmjEbrYhZKaBbGFsupGfts)iPlswHF5hjWVv3QyMs2TtdkCic4dmvaw4XVxFmk7NcSv3Qyo0vw)l)stzRUvXCad0(Llg1tAkB1TkMdEbxUyupPPr)3lG2VRbxg8YS(xC4RQm6)Eb2QBvmN1)YVWxnnDt0)9cwp3LnCCS3fgEUDAqfqF(ShyuZ2)W5PJzLr)3ly9Cx2WxDlLSBNgu4qeWhyQaSqF(Stj72Pbfoeb8bMkaR7xz3onOY6gpOS8ywHNR1Z(9PKPKHDswg)W)dbtYdCKedqYXCnK8lnJXK8XDHGeZbmLjOKD70GchEUwp73xb84h(Fiyu2pfs4(f)ahcoe5AVSCg8YUwNN9UqGdmm83QQmeLmStckC8qYSZKabgsq3ZojZotsmapKmDmtYaiXHGi5xtRjz2zsIDutc0)8PbfjnMK9EcKS8RxFmjhh7DHjj(RNwv3mejdGKyFS7Keda1RpMeO)5tdkkz3onOWHNR1Z(9HPcWc)RxFmkTWz1CE8dbpyfmdL9tbiWeIbG61hhoo27cN0XXExy47QRQOmtXtj72Pbfo8CTE2VpmvawXaq96JPKPKHDsmzmtYSZKadaxZoChjO7zNeNeuykyPyLLKz3hsACbJdjVdetYk(1y)OKD70GchWJcNJKlWhNFhxMhCOSFke9FVG1ZDzdhh7DHtYmurjd7KyYyMKLXp8)qWKmaswZSkjFvsMDMetYXECuxq8rs0)9iPFK0djObFnejmQv7JjjIFGJj51vJ37cbjZotsXOEiX64HeWrYaib6hRsse)ahtckafsWAMs2TtdkCapWubyHh)W)dbJY(PW9l(boeCy6ygn4Qm0XECuxq8fyy4VvvziLByRUvXCORSxWPmHnBI(Vxy6ygn4Qm0XECuxq8foo27cNKBNgub0Np7bg1S9pCE6ygMjgmt5g2QBvmh6khbM90u2QBvmh6kJbA)stzRUvXCq)l)YfJ6zBAA0)9cthZObxLHo2JJ6cIVWXXEx4KC70GkGh)E9Xbg1S9pCE6ygMjgmt5g2QBvmh6kR)LFPPSv3QyoGbA)YfJ6jnLT6wfZbVGlxmQNTBttti6)EHPJz0GRYqh7XrDbXx4RUnnDt0)9cwp3Ln8vttr6x7rAoybfsWAodXy4k7wLwaqdbqxblOqcwZ5zNZy1(6bho2HGtPfGKlVMq1i2N8Z5Tk3KGfGKlVMWA4U2R0ulaOHaORahRcqZxocuqHJJ9UWjP43QCt0)9cwp3Ln8vtttWcaAia6ky9Cx2WXoeCBPKHDsmzmtIPGC1PrYKSG2VysqVZfjZoFmjnMKcqIBNgjtcgTFXOKehtI2hMehtIkaJ7intcOibJ2Vysq3ZojRsc4i5XO5Je8421ysahjGIeNKvctsWO9lMemGKz3hsMDMKIrtcgTFXK431izmjWa(Xdj(B4JKz3hsWO9lMeg1Q9Xykz3onOWb8atfGLd5QtJKZy0(fJslCwnNh)qWdwbZqz)uibiWeCixDAKCgJ2V4mKh7i4W021DHqzcUDAqfCixDAKCgJ2V4mKh7i4qx5NUrSpk3KaeycoKRonsoJr7xCENDDyA76UqKMcbMGd5QtJKZy0(fN3zxhoo27cNeQ2MMcbMGd5QtJKZy0(fNH8yhbhWJBxdVvQecmbhYvNgjNXO9lod5XocoCCS3fgERujeycoKRonsoJr7xCgYJDeCyA76Uqqjd7KyYygtckafsWAMK(rckmfSuSYssJj5Rsc4iboWNe)ysGymCLTleKGctblfRSKGUNDsqbOqcwZK4fejWb(K4htseRbOjrrsKetHxrkz3onOWb8atfGLfuibR58SZzSAF9Grz)uibO73qHcKTqyLB2G0V2J0CWckKG1CgIXWvwLjybaneaDfSEUlB4yhcoLjC)IFGdbhuVogCqTRZ(z9QTz1Vg7xAA0)9cwp3Ln8v3Q0XZ56SkanFWtrsu5MO)7fyRUvXCw)l)chh7DHtYSettJ(VxGT6wfZzmq7x44yVlCsML4200xJyFYhh7DHHNzjQmblaOHaORG1ZDzdh7qWTLsg2jbfGcQNguK8ahjUwtceyWKm7(qsSVMXKG)htYSZWrIFCbJdjh)ogVZqKGENlsmPDKCb(ysm)hxMhCKS7ys0mgtYS7fjOIemBXKCCS3vxiibCKm7mjRH7AVij6)EK0ys8iWFizaK8CTMeW7rc4iXl4ib(T6wfZK0ys8iWFizaKWOwTpMs2TtdkCapWubyH0V2J0mklpMvacm5JHH)(4yUgmkr66pRWMO)7fohjxGpo)oUmp4chh7DHtcvPPje9FVW5i5c8X53XL5bx4RUv5MO)7fw3f0XqzowfGMVyUMmx8HOnpoCCS3fgEiSqHyh1BvUj6)Eb2QBvmNXaTFHJJ9UWjHWcfIDuNMg9FVaB1TkMZ6F5x44yVlCsiSqHyh1BPKD70GchWdmvawXaq96JrPfoRMZJFi4bRGzOSFkC87y8UhPzLJFi4jmDmNhqgQ5KmBvLBC1SDNTRvI0V2J0Cacm5JHH)(4yUg8wkz3onOWb8atfGf(xV(yuAHZQ584hcEWkygk7Nch)ogV7rAw54hcEcthZ5bKHAojZwv5gxnB3z7ALi9R9inhGat(yy4VpoMRbVLs2TtdkCapWubyHhwR9l)0(XO0cNvZ5Xpe8GvWmu2pfo(DmE3J0SYXpe8eMoMZdid1CsMbFuUXvZ2D2Uwjs)ApsZbiWKpgg(7JJ5AWBPKHDsmzmtI5hyAsafjwisq3Zo4pKyDv1Uqqj72PbfoGhyQaSEGZYzWlx(8pgL9tbxnB3z7AkzyNetgZKadSlOJHizrTVEWKGUNDs8cos0GcbjCb(i2jr74PleKa)wDRIzs8cIK5GJKbqIUlMKEi5Rsc6E2jzf)ASFK4fejOWuWsXklLSBNgu4aEGPcWIJvbO5lhbkiu2pf2Sj6)Eb2QBvmNXaTFHJJ9UWjzwIPPr)3lWwDRI5S(x(foo27cNKzjUvPfa0qa0vW65USHJJ9UWjTYevUj6)Eb1RJbhu76SFwVABw9RX(fq66pdVvvKettt4(f)ahcoOEDm4GAxN9Z6vBZQFn2Vadd)TQkdTDBAA0)9cQxhdoO21z)SE12S6xJ9lG01FojfwvXLyAQfa0qa0vW65USHJDi4u645CDwfGMVKGnjsjd7KyYyMeuykyPyLLe09StckafsWAgwWa7c6yiswu7RhmjEbrceOGXHeas(qF9WKSIFn2psahjO35IeZPbai9hpKGg81qKWOwTpMKi(boMeuykyPyLLeg1Q9Xykz3onOWb8atfGLL1mEAxNDDJOI5Aqz)uibO73qHcKTqyLi9R9inhSqzlOG6PbLYnoEoxNvbO5ljytIk3e9FVW6UGogkZXQa08fZ1K5IpeT5XHVAAAcwasU8AcRH7AV2MMAbi5YRjunI9j)Conn6)EHinaaP)4j8vvg9FVqKgaG0F8eoo27cdVvteMB2aBGV3V4h4qWb1RJbhu76SFwVABw9RX(fyy4VvvzOTWCJfuq)EcQhBBmNDDJOI5ActhZzKU(ZB3Uvzcr)3ly9Cx2Wxv5MeSaKC51eQgX(KFoNMAbaneaDfSGcjynNNDoJv7RhC4RMMgbWyLDn8Pc0(Wq5xJyFYhh7DHHNfa0qa0vWckKG1CE25mwTVEWHJJ9UWWe(KM21WNkq7ddLFnI9jFCS3fwrPOmtXNi8wnryUXckOFpb1JTnMZUUruXCnHPJ5msx)5TBPKD70GchWdmvawDz9R8Pbfk7NcjaD)gkuGSfcRePFThP5GfkBbfupnOuUXXZ56SkanFjbBsu5MO)7fw3f0XqzowfGMVyUMmx8HOnpo8vtttWcqYLxtynCx7120ulajxEnHQrSp5NZPPr)3lePbai9hpHVQYO)7fI0aaK(JNWXXExy4TYeH5MnWg479l(boeCq96yWb1Uo7N1R2Mv)ASFbgg(BvvgAlm3ybf0VNG6X2gZzx3iQyUMW0XCgPR)82TBvMq0)9cwp3Ln8vvUjblajxEnHQrSp5NZPPwaqdbqxblOqcwZ5zNZy1(6bh(QPPramwzxdFQaTpmu(1i2N8XXExy4zbaneaDfSGcjynNNDoJv7RhC44yVlmmHpPPDn8Pc0(Wq5xJyFYhh7DHvukkZu8jcVvMim3ybf0VNG6X2gZzx3iQyUMW0XCgPR)82TuYWojWa4x7rAMKpMHibuK4rTUNMXKm7(qcAVgsgajrmjyhjdrYdCKGctblfRSKGbKm7(qYSZWrIFCnKG2XddrcmGF8qse)ahtYSZXuYUDAqHd4bMkalK(1EKMrz5XScyhjNFGlB9CxwuI01FwHeSaGgcGUcwp3LnCSdbxAAci9R9inhSGcjynNHymCLvPfGKlVMq1i2N8Z50uO73qHcKTqykzyNetgZysm)a4NK(rsxK4fjWVv3QyMeVGizUMXKmas0DXK0djFvsq3ZojR4xJ9dLKGctblfRSK4fejMcYvNgjtYcA)IPKD70GchWdmvawV)bxg8YS(xmk7NcSv3Qyo0v2l4u6Qz7oBxRm6)Eb1RJbhu76SFwVABw9RX(fq66pdVvvKevUbcmbhYvNgjNXO9lod5XocomTDDxisttWcqYLxtOy7b0GdARsK(1EKMdyhjNFGlB9CxwkzyNetgZKaBR4zNKLXVNR1KOEalMK(rYY43Z1AsACbJdjFvkz3onOWb8atfGfE875Ank7Ncr)3lakE2Xzv(SS60Gk8vvg9FVaE875AD443X4DpsZuYUDAqHd4bMkalRxwwNJ(VhklpMvap(Pbhek7Ncr)3lGh)0GdkCCS3fgEOs5MO)7fyRUvXCgd0(foo27cNeQstJ(VxGT6wfZz9V8lCCS3fojuTvPJNZ1zvaA(sc2KiLmStIj5hRIjXu4vKKi(boMeuakKG1mjFCxiiz2zsqbOqcwZKybfupnOizaKy3z7As6hjOauibRzsAmjUD(UwdhjEe4pKmasIysSoEOKD70GchWdmvaw4XVNR1OSFkmUMRjGhwR9ldD9BcC5rAgsjMNPle4agObzORFJYO)7fWJFpxRdqa0fLmStIj5hRIjXXQKeXpWXKGcqHeSMj5J7cbjZotckafsWAMelOG6PbfjdGe7oBxts)ibfGcjyntsJjXTZ31A4iXJa)HKbqsetI1XdLSBNgu4aEGPcWcp(H)hcgL9tblajxEnHQrSp5NZkr6x7rAoybfsWAodXy4kRslaOHaORGfuibR58SZzSAF9Gdhh7DHHhQuMa09BOqbYwimLmStIjJzswg)EUwtc6E2jzzyT2psmjx)gs8cIKcqYY4NgCqOKe07Crsbizz875AnjnMKVkkjboWNe)ys6IKv4x(rc8B1TkMjbCKmasupGLKv8RX(rc6DUiXJaizsGnjsIPWRijGJehs1NgjtcgTFXKS7ysu8WeZwmjhh7D1fcsahjnMKUi5PBe7dLSBNgu4aEGPcWcp(9CTgL9tHX1Cnb8WATFzORFtGlpsZqktyCnxtap(PbhuGlpsZqkJ(Vxap(9CToC87y8UhPzLBI(VxGT6wfZz9V8lCCS3foj4Js2QBvmh6kR)LFkJ(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZWBvuLyAA0)9cQxhdoO21z)SE12S6xJ9lG01FojfwfvjQ0XZ56SkanFjbBsmnfcmbhYvNgjNXO9lod5XocoCCS3fojfFAQBNgubhYvNgjNXO9lod5Xoco0v(PBe7ZwLjybaneaDfSEUlB4yhcokzyNetgZKSm(H)hcMeyBfp7KOEalMeVGib6hRsIPWRijO35IeuykyPyLLeWrYSZKadaxZoChjr)3JKgtIhb(djdGKNR1KaEpsahjWb(WiejwxLetHxrkz3onOWb8atfGfE8d)pemk7Ncr)3lakE2XzRM9lJSXnOcF100O)7fw3f0XqzowfGMVyUMmx8HOnpo8vttJ(VxW65USHVQYnr)3lCosUaFC(DCzEWfoo27cdpewOqSJA4RLB9ghpNRZQa08POwzIBvg9FVW5i5c8X53XL5bx4RMMMq0)9cNJKlWhNFhxMhCHVQYeSaGgcGUcNJKlWhNFhxMhCHJDi4sttWcqYLxtajxZoC320uhpNRZQa08LeSjrLSv3Qyo0v2l4OKHDsmXbhjdGKyFntYSZKeX4HeWJKLXpn4GijcosWJBx3fcs6HKVkjWWFBxRHJKUiXl4ib(T6wfZKe9hswXVg7hjnUgs8iWFizaKeXKOEaRLHOKD70GchWdmvaw4Xp8)qWOSFkmUMRjGh)0GdkWLhPziLjC)IFGdbhMoMrdUkdDShh1feFbgg(Bvvgs5MO)7fWJFAWbf(QPPoEoxNvbO5ljytIBvg9FVaE8tdoOaEC7A4TsLBI(VxGT6wfZzmq7x4RMMg9FVaB1TkMZ6F5x4RUvz0)9cQxhdoO21z)SE12S6xJ9lG01FgERQ4su5glaOHaORG1ZDzdhh7DHtYSetttaPFThP5GfuibR5meJHRSkTaKC51eQgX(KFoVLsg2jXK8Jvjzz8d)pemjDrItIIdMy2sYcq7hjWVv3QygLKabkyCirZdj9qI6bSKSIFn2ps2m7(qsJjz3lindrseCKW9SZhjZotYY43Z1As0DXKaosMDMetHxXKGnjsIUlMKh4izz8d)pe8wusceOGXHeas(qF9WK4fjW2kE2jr9aws8cIenpKm7mjEeajtIUlMKDVG0mjlJFAWbrj72PbfoGhyQaSWJF4)HGrz)uiH7x8dCi4W0XmAWvzOJ94OUG4lWWWFRQYqk3e9FVG61XGdQDD2pRxTnR(1y)ciD9NH3QkUettJ(Vxq96yWb1Uo7N1R2Mv)ASFbKU(ZWBvuLOYX1Cnb8WATFzORFtGlpsZqBvg9FVaB1TkMZyG2VWXXEx4KuCkzRUvXCORmgO9tzcr)3lakE2Xzv(SS60Gk8vvMW4AUMaE8tdoOaxEKMHuAbaneaDfSEUlB44yVlCskoLBSaGgcGUcR7c6yOmwTVEWHJJ9UWjP4sttWcqYLxtynCx71wkzyNetgZKysbafMKUizf(LFKa)wDRIzs8cIeSJKjb2Ex)GP5)R1KysbafjpWrckmfSuSYsIxqKadSlOJHib(JvbO5lMRHs2TtdkCapWubyvm6CmauOSFkSj6)Eb2QBvmN1)YVWXXEx4KyuZ2)W5PJ500n2D)qWyfwv5X2D)qW5PJz4HQTPP2D)qWyfw5wLUA2UZ21kr6x7rAoGDKC(bUS1ZDzPKD70GchWdmvaw7U(LJbGcL9tHnr)3lWwDRI5S(x(foo27cNeJA2(hopDmRmblajxEnH1WDTxPPBI(VxyDxqhdL5yvaA(I5AYCXhI284WxvPfGKlVMWA4U2RTPPBS7(HGXkSQYJT7(HGZthZWdvBttT7(HGXkSY00O)7fSEUlB4RUvPRMT7SDTsK(1EKMdyhjNFGlB9Cxwkz3onOWb8atfG17R15yaOqz)uyt0)9cSv3QyoR)LFHJJ9UWjXOMT)HZthZktWcqYLxtynCx7vA6MO)7fw3f0XqzowfGMVyUMmx8HOnpo8vvAbi5YRjSgUR9ABA6g7UFiyScRQ8y7UFi480Xm8q120u7UFiyScRmnn6)EbRN7Yg(QBv6Qz7oBxRePFThP5a2rY5h4Ywp3LLsg2jXKXmjWwa4NeqrIfIs2TtdkCapWubyH2VRbxg8YS(xmLmStIjJzswg)E9XKmasupGLKfG2psGFRUvXmkjbfMcwkwzjz3XKOzmMKPJzsMDViXjb268zNeg1S9pmjA(nKaosaLgoswHF5hjWVv3QyMKgtYxLs2TtdkCapWubyHh)E9XOSFkWwDRI5qxz9V8lnLT6wfZbmq7xUyupPPSv3Qyo4fC5Ir9KMg9FVaA)UgCzWlZ6FXHVQYO)7fyRUvXCw)l)cF100nr)3ly9Cx2WXXExy452Pbva95ZEGrnB)dNNoMvg9FVG1ZDzdF1TuYWojMmMjb268zNeWSZh6gZKGEVT7K0ys6IKfG2psGFRUvXmkjbfMcwkwzjbCKmasupGLKv4x(rc8B1TkMPKD70GchWdmvawOpF2PKHDsm)Uwp73Ns2TtdkCapWubyD)k72Pbvw34bLLhZk8CTE2VVXcwLTgM2Sex1ymgdda]] )


end