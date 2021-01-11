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
        thrash_cat ={
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 1,
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


    spec:RegisterPack( "Balance", 20210111, [[dOeWNdqiOIhbvk5sevPnbOpbvQmkQsNIQYQeQkVsOywaOBbvk2fk)cuPHru5yqvwga8mqvnnIQY1avzBevvFdQu14iQcNtOKwNqjmpQIUNkyFufoirvuleQkpuOunrHsu5IcLO4JcLiDsOsPALcvMPqv1nfkrPDcQ4NcLOQHkuIyPevr6PczQqL8vOsPmwIQi2li)LWGv6Wuwmv8yunzGUmYMf8zqz0eLtl51QqZMu3MkTBr)gYWHYXfkLLR45KmDvDDvA7QOVtv14HQQZdqRxOkZNi7xQHWdcxqrG2tqWbaYba8Kdp8WJHN8d)yv(KFOOhqmckcZ4hnyeuuAUeue(mTLCckcZauJmqiCbfPq3HtqrY(htflGlCHvVSRdJJCHRQCVA7luYhl8WvvUC4cf5Cl9JBpHCGIaTNGGdaKda4jhE4Hhdp5h(Xk8bauKDFzObkkQCJDOizfiiLqoqrGKIdfHB1l(mTLCQ3y5MBb2XHB1BCwETbWEXdpa2laKda41X1XHB1BSlZsyKkw0XHB1lUPx5zqqcS3iK2MEXhzUSooCREXn9g7YSegb27Bdm6fvOxUPivVpQxoGCnjEBGrVI1XHB1lUPx5PKl6Ka79MjXjLYga790MYC0KQxVfJyaSxSHofQ3g1DGr9IB8OxSHozQ3g1DGr(yDC4w9IB6vE(evG9Ine3uFLW6f32yVSERqV1J7u9(YOE9pOewVXYW1fMIyDC4w9IB6nww7i1BSJYt0rQ3xg1Bewn1R616vx)RPEDrd1Bqt4VC0uVERqVaIU9kZatC33RS67T(EvL7v)wsORsdyV(RxwV4lwE5zC1Bm9g7KMuFz6ELN1fS0LYhG9wpUdSx1XcZhdksxQxbHlOihK9q4cco4bHlOiknhnbcHpOi(upnLbf5Cdbg3evYzxmOiJ)fkHIg7Ks0vjcdLXdqOhcoaacxqruAoAcecFqrimOif9qrg)lucfDAtzoAck600xckcNEDUHaZX0wYjbkimTw8YQeMsK2FhIDX6fyV40RZneyoM2sojqbHP1IxwLWucB4wsSlgu0PnI0CjOi(uFI(lg0dbh4dHlOiknhnbcHpOiJ)fkHImqd7RtsO8BJlueFQNMYGICUHaZX0wYjbkimTw8YQeMsK2FhIPEJFSxp7v(6fyVo3qG5yAl5KafeMwlEzvctjSHBjXuVXp2RN9kF9cSxV9ItVGONzGg2xNKq53gxbO5AWi2x8JvcRxG9ItVg)luYmqd7RtsO8BJRa0CnyeRsrqxWK99cSxV9ItVGONzGg2xNKq53gxHmY0SV4hRewVss9cIEMbAyFDscLFBCfYitZgY1Qu1Rh9c)E91RKuVGONzGg2xNKq53gxbO5AWiM6n(XE9Sx43lWEbrpZanSVojHYVnUcqZ1GrSHCTkv96zVWRxG9cIEMbAyFDscLFBCfGMRbJyFXpwjSE9bfXbKRjXBdm6vqWbpOhcoYheUGIO0C0eie(GI4t90uguK3EpTPmhnX4O8eDKeGKcWK3lWEXPxocPbr(tg3evYzdzGa2RKuVo3qGXnrLC2fRxF9cSxV96CdbMJPTKtcuqyAT4LvjmLiT)oet9g)yVh6fE9kj1RZneyoM2sojqbHP1IxwLWucB4wsm1B8J9EOx41RVELK6nuWK9IHCTkv96zV4jhuKX)cLqrCuEIosIxgjuy1uVc6HGd8GWfueLMJMaHWhueFQNMYGI82RZneyoM2sojqbHP1IxwLWuI0(7qSHCTkv96rVYhdE9kj1RZneyoM2sojqbHP1IxwLWucB4wsSHCTkv96rVYhdE96RxG9AQFmTad5NME94qVXQC9cSxV9YriniYFY4MOsoBixRsvVE0lUVxjPE92lhH0Gi)jJCXq(Pr4Gsq2qUwLQE9OxCFVa7fNEDUHa7yLGdbkixmKFACP8fusdSkEe7I1lWE5OtkT8zhbCkl71xV(GIm(xOekIBjN0cNBiaf5CdbrAUeuK6TrJgqOhcoYpeUGIO0C0eie(GI4t90ugu0BAkFM6jT2gb4uHNrP5OjWEb2RI(VsykMcPrcWPcFVa715gcm1BtW0AgiYFcfz8VqjuK6TjyAn0dbhCpeUGIO0C0eie(GI4t90ugueo9EAtzoAIXN6t0FX6fyVE7LJoP0YNLfmzViyuVss9YriniYFY4MOsoBixRsvVE0lUVxjPEXP3tBkZrtmoOGJsW6lu2lWEXPxo6KslF2raNYYELK61BVCesdI8NmYfd5NgHdkbzd5AvQ61JEX99cSxC615gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVa7LJoP0YNDeWPSSxF96dkY4FHsOi1BJ6oWiOhcoYdiCbfrP5Ojqi8bfXN6PPmOiV9YriniYFY4O8eDKeVmsOWQPEfBixRsvVE2l86fyV40l4ClqwIeCqvVa71BVN2uMJMyCuEIoscqsbyY7vsQxocPbr(tg3evYzd5AvQ61ZEHxV(61xVa71u)yAbgYpn96rVYNC9cSxo6KslFwwWK9IGr9cSxC6fCUfilrcoOckY4FHsOi1BJ6oWiOhcoXkeUGIO0C0eie(GIqyqrk6HIm(xOek60MYC0eu0PPVeuK3EDUHaJBIk5SHCTkv96rVWRxG96TxNBiWg7Ks0vjcdLXdq2qUwLQE9Ox41RKuV40RZneyJDsj6QeHHY4bi7I1RVELK6fNEDUHaJBIk5SlwVss9AQFmTad5NME9Sx4lxV(6fyVE7fNEDUHa7yLGdbkixmKFACP8fusdSkEe7I1RKuVM6htlWq(PPxp7f(Y1RVEb2R3EDUHaJ46ctrcfsBdBixRsvVE0lmoiZ1WFVss96CdbgX1fMIe6BAdBixRsvVE0lmoiZ1WFV(GIoTrKMlbfbIEXqX2TgYLYxb9qWbp5GWfueLMJMaHWhuKX)cLqrQBgQHGI4t90ugu0qHHuYmhn1lWEFBGrp7lxs8ibyr96rV4j)9cSxdtWLr8J9cS3tBkZrtmq0lgk2U1qUu(kOioGCnjEBGrVcco4b9qWbp8GWfueLMJMaHWhuKX)cLqrUiugQHGI4t90ugu0qHHuYmhn1lWEFBGrp7lxs8ibyr96rV4bFg86fyVgMGlJ4h7fyVN2uMJMyGOxmuSDRHCP8vqrCa5As82aJEfeCWd6HGdEaacxqruAoAcecFqrg)lucfPEsRTre02qqr8PEAkdkAOWqkzMJM6fyVVnWON9LljEKaSOE9Ox8K)EJP3HCTkv9cSxdtWLr8J9cS3tBkZrtmq0lgk2U1qUu(kOioGCnjEBGrVcco4b9qWbp4dHlOiknhnbcHpOi(upnLbfzycUmIFekY4FHsOOaA4KafeP93HGEi4GN8bHlOiknhnbcHpOi(upnLbf5TxIRlmfXQuyjG9kj1lX1fMIykK2grLc86vsQxIRlmfX030grLc861xVa71BV40lhDsPLpllyYErWOELK6fCUfilrcoOQxjPE92RP(X0cmKFA61ZEJv41lWE927PnL5OjgFQpr)fRxjPEn1pMwGH8ttVE2l8LRxjPEpTPmhnXkLWquV(6fyVE790MYC0eJJYt0rsaskatEVa7fNE5iKge5pzCuEIosIxgjuy1uVIDX6vsQxC690MYC0eJJYt0rsaskatEVa7fNE5iKge5pzCtujNDX61xV(61xVa71BVCesdI8NmUjQKZgY1Qu1Rh9cF56vsQxW5wGSej4GQELK61u)yAbgYpn96rVXQC9cSxocPbr(tg3evYzxSEb2R3E5iKge5pzKlgYpnchucYgY1Qu1RN9A8Vqjt92eQHye(j(9jXxUuVss9ItVC0jLw(SJaoLL96RxjPER8PbdPTNafHcMSxmKRvPQxp7fp561xVa71BVGONzGg2xNKq53gxbO5AWi2qUwLQE9Ox5RxjPEXPxo6KslFws8bPrdyV(GIm(xOekkChafOGG03KGEi4Gh8GWfueLMJMaHWhueFQNMYGI82lX1fMIy6BAJij8)9kj1lX1fMIykK2grs4)7vsQxIRlmfXSeqrs4)7vsQxNBiWCmTLCsGcctRfVSkHPeP93Hyd5AvQ61JELpg86vsQxNBiWCmTLCsGcctRfVSkHPe2WTKyd5AvQ61JELpg86vsQxt9JPfyi)00Rh9gRY1lWE5iKge5pzCtujNnKbcyVa7fNEbNBbYsKGdQ61xVa71BVCesdI8NmUjQKZgY1Qu1Rh9cF56vsQxocPbr(tg3evYzdzGa2RVELK6TYNgmK2EcuekyYEXqUwLQE9Sx8KdkY4FHsOiYfd5NgHdkbHEi4GN8dHlOiknhnbcHpOi(upnLbfHtVGZTazjsWbv9cS3tBkZrtmoOGJsW6lu2lWE92RP(X0cmKFA61JEJv56fyVE715gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVss9ItVC0jLw(SJaoLL96RxjPE5OtkT8zzbt2lcg1RKuVo3qG5Oriq9v9SlwVa715gcmhncbQVQNnKRvPQxp7faY1Bm96TxokbV1ZWgIxksy6cw6s5Z(YLeNM(s96RxF9cSxV9EAtzoAIXr5j6ijajfGjVxjPE5iKge5pzCuEIosIxgjuy1uVInKbcyV(6vsQ3kFAWqA7jqrOGj7fd5AvQ61ZEbGC9gtVE7LJsWB9mSH4LIeMUGLUu(SVCjXPPVuV(GIm(xOekItAs9LPfMUGLUu(qpeCWd3dHlOiknhnbcHpOi(upnLbfHtVGZTazjsWbv9cS3tBkZrtmoOGJsW6lu2lWE92RP(X0cmKFA61JEJv56fyVE715gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVss9ItVC0jLw(SJaoLL96RxjPE5OtkT8zzbt2lcg1RKuVo3qG5Oriq9v9SlwVa715gcmhncbQVQNnKRvPQxp7f(Y1Bm96TxokbV1ZWgIxksy6cw6s5Z(YLeNM(s96RxF9cSxV9EAtzoAIXr5j6ijajfGjVxjPE5iKge5pzCuEIosIxgjuy1uVInKbcyV(6vsQ3kFAWqA7jqrOGj7fd5AvQ61ZEHVC9gtVE7LJsWB9mSH4LIeMUGLUu(SVCjXPPVuV(GIm(xOekQsUnP9fkHEi4GN8acxqruAoAcecFqrimOif9qrg)lucfDAtzoAck600xckI46ctrSkf6BAtVXxVYJEHBVg)luYuVnHAigHFIFFs8Ll1Bm9ItVexxykIvPqFtB6n(6v(7fU9A8VqjZ)yVmgHFIFFs8Ll1Bm9khda9c3EvyKwlKzQNGIoTrKMlbfzkSyj0erCOhco4fRq4ckIsZrtGq4dkIp1ttzqrE7TYNgmK2EcuekyYEXqUwLQE9Sx5RxjPE92RZneyJDsj6QeHHY4biBixRsvVE2lmoiZ1WFVXxVCQ096Txt9JPfyi)00lC7f(Y1RVEb2RZneyJDsj6QeHHY4bi7I1RVE91RKuVE71u)yAbgYpn9gtVN2uMJMyMclwcnreV34RxNBiWiUUWuKqH02WgY1Qu1Bm9cIEw4oakqbbPVjX(IFujgY1QS34RxaWGxVE0lEaqUELK61u)yAbgYpn9gtVN2uMJMyMclwcnreV34RxNBiWiUUWuKqFtByd5AvQ6nMEbrplChafOGG03KyFXpQed5Av2B81layWRxp6fpaixV(6fyVexxykIvPWsa7fyVE71BV40lhH0Gi)jJBIk5SlwVss9YrNuA5Zoc4uw2lWEXPxocPbr(tg5IH8tJWbLGSlwV(6vsQxo6KslFwwWK9IGr96RxG96TxC6LJoP0YNDs5ldWPxjPEXPxNBiW4MOso7I1RKuVM6htlWq(PPxp6nwLRxF9kj1RZneyCtujNnKRvPQxp6vE0lWEXPxNBiWg7Ks0vjcdLXdq2fdkY4FHsOi1BJ6oWiOhcoaqoiCbfrP5Ojqi8bfXN6PPmOiV96CdbgX1fMIe6BAd7I1RKuVE7LlZgyKQ3d9cGEb27qCz2aJeF5s96zVWRxF9kj1lxMnWivVh6f(96RxG9AycUmIFekY4FHsOOK8lCrOe6HGdaWdcxqruAoAcecFqr8PEAkdkYBVo3qGrCDHPiH(M2WUy9kj1R3E5YSbgP69qVaOxG9oexMnWiXxUuVE2l861xVss9YLzdms17HEHFV(6fyVgMGlJ4hHIm(xOeksMPdcxekHEi4aaaaHlOiknhnbcHpOi(upnLbf5TxNBiWiUUWuKqFtByxSELK61BVCz2aJu9EOxa0lWEhIlZgyK4lxQxp7fE96RxjPE5YSbgP69qVWVxF9cSxdtWLr8Jqrg)lucffUATWfHsOhcoaa(q4ckY4FHsOi)2mfAeOGG03KGIO0C0eie(GEi4aa5dcxqruAoAcecFqr8PEAkdkI46ctrSkf6BAtVss9sCDHPiMcPTrKe()ELK6L46ctrmlbuKe()ELK615gcm)2mfAeOGG03KyxSEb2RZneyexxyksOVPnSlwVss96TxNBiW4MOsoBixRsvVE2RX)cLm)J9Yye(j(9jXxUuVa715gcmUjQKZUy96dkY4FHsOi1BtOgc6HGdaGheUGIm(xOekY)yVmOiknhnbcHpOhcoaq(HWfueLMJMaHWhuKX)cLqrZnfg)luk0L6HI0L6fP5sqrbtRFzZf6HEOiqkyx9dHli4GheUGIm(xOeksH02iCiZfkIsZrtGq4d6HGdaGWfueLMJMaHWhuecdksrpuKX)cLqrN2uMJMGIon9LGIuyKwlEBGrVIPEBcMw3Rh9IxVa71BV407BAkFM6TrJgqgLMJMa7vsQ330u(m1tATncWPcpJsZrtG96RxjPEvyKwlEBGrVIPEBcMw3Rh9caOOtBeP5sqrLsyic6HGd8HWfueLMJMaHWhuecdksrpuKX)cLqrN2uMJMGIon9LGIuyKwlEBGrVIPEBc1q96rV4bfDAJinxckQucUMStc6HGJ8bHlOiknhnbcHpOi(upnLbf5TxC6LJoP0YNLfmzViyuVss9ItVCesdI8NmokprhjXlJekSAQxXUy96RxG96Cdbg3evYzxmOiJ)fkHICOrrZXkHb9qWbEq4ckIsZrtGq4dkIp1ttzqro3qGXnrLC2fdkY4FHsOim0xOe6HGJ8dHlOiknhnbcHpOieguKIEOiJ)fkHIoTPmhnbfDA6lbff0i00R3E92BLpnyiT9eOiuWK9IHCTkv9IB6faY1lUPxocPbr(tghLNOJK4Lrcfwn1Ryd5AvQ61xVWTx8aGC96Rxp6nOrOPxV96T3kFAWqA7jqrOGj7fd5AvQ6f30laGxV4ME92lEY1B817BAkFwLCBs7luYO0C0eyV(6f30R3E5Oe8wpdBiEPiHPlyPlLp7lxsCA6l1RVEXn9YriniYFY4MOsoBixRsvV(6fU9IN8qUE91RKuVCesdI8NmUjQKZgY1Qu1Rh9w5tdgsBpbkcfmzVyixRsvVss9YriniYFY4O8eDKeVmsOWQPEfBixRsvVE0BLpnyiT9eOiuWK9IHCTkv9kj1lo9YrNuA5ZYcMSxemck60grAUeuehLNOJKaKuaMCOhco4EiCbfrP5Ojqi8bfHWGIu0dfz8Vqju0PnL5OjOOttFjOiV9ItVuSDlmmcKrUyaoKPfObmTKt9kj1lhH0Gi)jJCXaCitlqdyAjNyd5AvQ61ZEXt(LRxG9ItVCesdI8NmYfdWHmTanGPLCInKbcyV(6vsQxo6KslF2raNYsOOtBeP5sqrCqbhLG1xOe6HGJ8acxqruAoAcecFqrg)lucfrUyaoKPfObmTKtqr8PEAkdkIJqAqK)KXnrLC2qUwLQE9SxaixVa790MYC0eJJYt0rsaskatEVss9YriniYFY4O8eDKeVmsOWQPEfBixRsvVE2laKdkknxckICXaCitlqdyAjNGEi4eRq4ckIsZrtGq4dkY4FHsOif6Q10)vctmxhaHI4t90uguehH0Gi)jJBIk5SHCTkv96zVYFVa790MYC0eJJYt0rsaskatEVss9YriniYFY4O8eDKeVmsOWQPEfBixRsvVE2R8dfLMlbfPqxTM(VsyI56ai0dbh8KdcxqruAoAcecFqrg)lucfvPIp33C0Ki2Uw(xxbiDwCckIp1ttzqro3qGXnrLC2fdkknxckQsfFUV5OjrSDT8VUcq6S4e0dbh8WdcxqruAoAcecFqr8PEAkdkY5gcmUjQKZUy9kj1lhDsPLpllyYErWOEb27PnL5OjghLNOJKaKuaM8Eb2lhH0Gi)jJJYt0rs8YiHcRM6vSlwVa7fNE5iKge5pzCtujNDX6fyVE71BVo3qGrCDHPiH(M2WgY1Qu1Rh9INC9kj1RZneyexxyksOqAByd5AvQ61JEXtUE91lWEXP35MuanWiMJPTKtcuqyAT4LvjmfJsZrtG9kj17CtkGgyeZX0wYjbkimTw8YQeMIrP5OjWEb2R3EDUHaZX0wYjbkimTw8YQeMsK2FhIPEJFSxp6f(9kj1RZneyoM2sojqbHP1IxwLWucB4wsm1B8J96rVWVxF96RxjPEDUHa7yLGdbkixmKFACP8fusdSkEe7I1RKuVHcMSxmKRvPQxp7faYbfz8Vqju0vrI6jxf0dbh8aaeUGIO0C0eie(GI4t90ugu0PnL5OjwPegIGIu)u8hco4bfz8Vqju0CtHX)cLcDPEOiDPErAUeuKHiOhco4bFiCbfrP5Ojqi8bfXN6PPmOO5MuanWi2xUKF0KcWHmxNkbPHrX2TWWiqOi1pf)HGdEqrg)lucfn3uy8VqPqxQhksxQxKMlbfboK56ujinqpeCWt(GWfueLMJMaHWhueFQNMYGIMBsb0aJyoM2sojqbHP1IxwLWumk2UfggbcfP(P4peCWdkY4FHsOO5McJ)fkf6s9qr6s9I0CjOihK9qpeCWdEq4ckIsZrtGq4dkY4FHsOO5McJ)fkf6s9qr6s9I0CjOi1d9qpue2qCKRJ9q4cco4bHlOiJ)fkHIowj4qGcfwn1RGIO0C0eie(GEi4aaiCbfz8VqjuKlcLhRueqJlueLMJMaHWh0dbh4dHlOiknhnbcHpOiJ)fkHI8p2ldkIp1ttzqrE7L46ctrm9nTrKe()ELK6L46ctrSkf6BAtVss9sCDHPiwLch0lRxjPEjUUWueZsafjH)VxFqr6kjbhekcp5GEi4iFq4ckIsZrtGq4dkIp1ttzqrE7L46ctrm9nTrKe()ELK6L46ctrSkf6BAtVss9sCDHPiwLch0lRxjPEjUUWueZsafjH)VxF9cSxSHoz4X8p2lRxG9ItVydDYaaZ)yVmOiJ)fkHI8p2ld6HGd8GWfueLMJMaHWhueFQNMYGIWP35MuanWiMJPTKtcuqyAT4LvjmfJsZrtG9kj1lo9YrNuA5ZYcMSxemQxjPEXPxfgP1I3gy0RyQ3MGP19EOx86vsQxC69nnLplT)oKs4yAl5eJsZrtGqrg)lucfPEBc1qqpeCKFiCbfrP5Ojqi8bfXN6PPmOO5MuanWiMJPTKtcuqyAT4LvjmfJsZrtG9cSxo6KslFwwWK9IGr9cSxfgP1I3gy0RyQ3MGP19EOx8GIm(xOeks92OUdmc6HEOidrq4cco4bHlOiknhnbcHpOieguKIEOiJ)fkHIoTPmhnbfDA6lbf5TxNBiW(YL8JMuaoK56ujinSHCTkv96zVW4Gmxd)9gtVYXWRxjPEDUHa7lxYpAsb4qMRtLG0WgY1Qu1RN9A8Vqjt92eQHye(j(9jXxUuVX0RCm86fyVE7L46ctrSkf6BAtVss9sCDHPiMcPTrKe()ELK6L46ctrmlbuKe()E91RVEb2RZneyF5s(rtkahYCDQeKg2fRxG9o3KcObgX(YL8JMuaoK56ujinmk2UfggbcfDAJinxckcCiZv4V0ArW0AbkeGEi4aaiCbfrP5Ojqi8bfHWGIu0dfz8Vqju0PnL5OjOOttFjOiNBiWiUUWuKqFtByxSEb2R3EvyKwlEBGrVIPEBc1q96rVYxVa79nnLptHUAbkiEzKiGgs9mknhnb2RKuVkmsRfVnWOxXuVnHAOE9Ox5VxFqrN2isZLGIkyjAiH6TrDhye0dbh4dHlOiknhnbcHpOi(upnLbf5T3tBkZrtmokprhjbiPam59cSxC6LJqAqK)KXnrLC2qgiG9kj1RZneyCtujNDX61xVa71BVM6htlWq(PPxp7fEY1RKuVN2uMJMyfSenKq92OUdmQxF9cSxV96CdbgX1fMIe6BAdBixRsvVE0R83RKuVo3qGrCDHPiHcPTHnKRvPQxp6v(71xVa71BV407CtkGgyeZX0wYjbkimTw8YQeMIrP5OjWELK615gcmhtBjNeOGW0AXlRsykrA)DiM6n(XE9Ox43RKuVo3qG5yAl5KafeMwlEzvctjSHBjXuVXp2Rh9c)E91RKuVHcMSxmKRvPQxp7fp5GIm(xOekIJYt0rs8YiHcRM6vqpeCKpiCbfrP5Ojqi8bfz8VqjuK6MHAiOi(upnLbfnuyiLmZrt9cS33gy0Z(YLepsawuVE0lEYxV4MEvyKwlEBGrVQ3y6DixRsvVa71BVexxykIvPWsa7vsQ3HCTkv96zVW4Gmxd)96dkIdixtI3gy0RGGdEqpeCGheUGIO0C0eie(GI4t90uguKZneyQ3MGP1SHcdPKzoAQxG96TxfgP1I3gy0RyQ3MGP196zVWVxjPEXP35MuanWi2xUKF0KcWHmxNkbPHrX2TWWiWE91lWE92lo9o3KcObgX0aYTXuIGMOVsycy6Yftrmk2Ufggb2RKuVF5s9kV9kFWRxp615gcm1BtW0A2qUwLQEJPxa0RVEb2BOGj7fd5AvQ61JEHhuKX)cLqrQ3MGP1qpeCKFiCbfrP5Ojqi8bfXN6PPmOO5MuanWi2xUKF0KcWHmxNkbPHrX2TWWiWEb2RcJ0AXBdm6vm1BtW06E94qVWVxG96TxC615gcSVCj)OjfGdzUovcsd7I1lWEDUHat92emTMnuyiLmZrt9kj1R3EpTPmhnXahYCf(lTwemTwGcHEb2R3EDUHat92emTMnKRvPQxp7f(9kj1RcJ0AXBdm6vm1BtW06E9Oxa0lWEFtt5ZupP12iaNk8mknhnb2lWEDUHat92emTMnKRvPQxp7fE96RxF96dkY4FHsOi1BtW0AOhco4EiCbfrP5Ojqi8bfHWGIu0dfz8Vqju0PnL5OjOOttFjOit9JPfyi)00Rh9kpKRxCtVE7fp56n(615gcSVCj)OjfGdzUovcsdt9g)yV(6f30R3EDUHat92emTMnKRvPQ34Rx43lC7vHrATqMPEQxF9IB61BVGONfUdGcuqq6BsSHCTkv9gF9cVE91lWEDUHat92emTMDXGIoTrKMlbfPEBcMwl8JYxemTwGcbOhcoYdiCbfrP5Ojqi8bfXN6PPmOOtBkZrtmWHmxH)sRfbtRfOqOxG9EAtzoAIPEBcMwl8JYxemTwGcHEb2lo9EAtzoAIvWs0qc1BJ6oWOELK61BVo3qG5yAl5KafeMwlEzvctjs7VdXuVXp2Rh9c)ELK615gcmhtBjNeOGW0AXlRsykHnCljM6n(XE9Ox43RVEb2RcJ0AXBdm6vm1BtW06E9Sx5dkY4FHsOi1BJ6oWiOhcoXkeUGIO0C0eie(GIm(xOekYanSVojHYVnUqr8PEAkdkcNE)IFSsy9cSxC614FHsMbAyFDscLFBCfGMRbJyvkc6cMSVxjPEbrpZanSVojHYVnUcqZ1Grm1B8J96zVWVxG9cIEMbAyFDscLFBCfGMRbJyd5AvQ61ZEHpuehqUMeVnWOxbbh8GEi4GNCq4ckIsZrtGq4dkY4FHsOixekd1qqr8PEAkdkAOWqkzMJM6fyVVnWON9LljEKaSOE9OxV9IN81Bm96TxfgP1I3gy0RyQ3MqnuVXxV4XGxV(61xVWTxfgP1I3gy0R6nMEhY1Qu1lWE92R3E5iKge5pzCtujNnKbcyVa7fNEbNBbYsKGdQ6fyVE790MYC0eJJYt0rsaskatEVss9YriniYFY4O8eDKeVmsOWQPEfBideWELK6fNE5OtkT8zzbt2lcg1RVELK6vHrAT4Tbg9kM6Tjud1RN96Tx41B81R3EXR3y69nnLp79xPWfHsfJsZrtG96RxF9kj1R3EjUUWueRsHcPTPxjPE92lX1fMIyvkCqVSELK6L46ctrSkf6BAtV(6fyV407BAkFMcD1cuq8YiranK6zuAoAcSxjPEDUHadBkx0awMwyd3YIlWUALnSttFPE94qVaaEY1RVEb2R3EvyKwlEBGrVIPEBc1q96zV4jxVXxVE7fVEJP330u(S3FLcxekvmknhnb2RVE91lWEn1pMwGH8ttVE0l8KRxCtVo3qGPEBcMwZgY1Qu1B81R83RVEb2R3EXPxNBiWowj4qGcYfd5NgxkFbL0aRIhXUy9kj1lX1fMIyvkuiTn9kj1lo9YrNuA5Zoc4uw2RVEb2RHj4Yi(XE9bfXbKRjXBdm6vqWbpOhco4HheUGIO0C0eie(GI4t90uguKHj4Yi(rOiJ)fkHIcOHtcuqK2Fhc6HGdEaacxqruAoAcecFqr8PEAkdkY5gcmUjQKZUyqrg)lucfn2jLORsegkJhGqpeCWd(q4ckIsZrtGq4dkIp1ttzqr40l4ClqwIeCqvVa790MYC0eJdk4OeS(cL9cSxV96CdbM6TjyAn7I1RKuVM6htlWq(PPxp6fEY1RVEb2lo96CdbMcPvFXj2fRxG9ItVo3qGXnrLC2fRxG96TxC6LJoP0YNLfmzViyuVss9EAtzoAIXr5j6ijajfGjVxjPE5iKge5pzCuEIosIxgjuy1uVIDX6vsQ3kFAWqA7jqrOGj7fd5AvQ61ZEbGC9gtVE7LJsWB9mSH4LIeMUGLUu(SVCjXPPVuV(61huKX)cLqrCstQVmTW0fS0LYh6HGdEYheUGIO0C0eie(GI4t90ugueo9co3cKLibhu1lWEpTPmhnX4GcokbRVqzVa71BVo3qGPEBcMwZUy9kj1RP(X0cmKFA61JEHNC96RxG9ItVo3qGPqA1xCIDX6fyV40RZneyCtujNDX6fyVE7fNE5OtkT8zzbt2lcg1RKuVN2uMJMyCuEIoscqsbyY7vsQxocPbr(tghLNOJK4Lrcfwn1RyxSELK6TYNgmK2EcuekyYEXqUwLQE9SxocPbr(tghLNOJK4Lrcfwn1Ryd5AvQ6nMEL)ELK6TYNgmK2EcuekyYEXqUwLQEL3EXtEixVE2l8LR3y61BVCucERNHneVuKW0fS0LYN9Lljon9L61xV(GIm(xOekQsUnP9fkHEi4Gh8GWfueLMJMaHWhueFQNMYGIQ8PbdPTNafHcMSxmKRvPQxp7fp41RKuVE715gcmSPCrdyzAHnCllUa7Qv2Won9L61ZEba8KRxjPEDUHadBkx0awMwyd3YIlWUALnSttFPE94qVaaEY1RVEb2RZneyQ3MGP1SlwVa71BVCesdI8NmUjQKZgY1Qu1Rh9cp56vsQxW5wGSej4GQE9bfz8Vqjue5IH8tJWbLGqpeCWt(HWfueLMJMaHWhuKX)cLqrQN0ABebTneueFQNMYGIgkmKsM5OPEb27xUK4rcWI61JEXdE9cSxfgP1I3gy0RyQ3MqnuVE2R81lWEnmbxgXp2lWE92RZneyCtujNnKRvPQxp6fp56vsQxC615gcmUjQKZUy96dkIdixtI3gy0RGGdEqpeCWd3dHlOiknhnbcHpOi(upnLbfrCDHPiwLclbSxG9AycUmIFSxG96Cdbg2uUObSmTWgULfxGD1kByNM(s96zVaaEY1lWE92li6zgOH91jju(TXvaAUgmI9f)yLW6vsQxC6LJoP0YNLeFqA0a2RKuVkmsRfVnWOx1Rh9cGE9bfz8Vqjuu4oakqbbPVjb9qWbp5beUGIO0C0eie(GI4t90uguKZneyOKEzkbgnCc7luYUy9cSxV96CdbM6TjyAnBOWqkzMJM6vsQxt9JPfyi)00Rh9gRY1RpOiJ)fkHIuVnbtRHEi4GxScHlOiknhnbcHpOi(upnLbfXrNuA5ZYcMSxemQxG96T3tBkZrtmokprhjbiPam59kj1lhH0Gi)jJBIk5SlwVss96Cdbg3evYzxSE91lWE5iKge5pzCuEIosIxgjuy1uVInKRvPQxp7fghK5A4V34Rxov6E92RP(X0cmKFA6fU9cp561xVa715gcm1BtW0A2qUwLQE9Sx5RxG9ItVGZTazjsWbvqrg)lucfPEBcMwd9qWbaYbHlOiknhnbcHpOi(upnLbfXrNuA5ZYcMSxemQxG96T3tBkZrtmokprhjbiPam59kj1lhH0Gi)jJBIk5SlwVss96Cdbg3evYzxSE91lWE5iKge5pzCuEIosIxgjuy1uVInKRvPQxp7v(7fyVo3qGPEBcMwZUy9cSxIRlmfXQuyjG9cSxC690MYC0eRGLOHeQ3g1DGr9cSxC6fCUfilrcoOckY4FHsOi1BJ6oWiOhcoaapiCbfrP5Ojqi8bfXN6PPmOiNBiWqj9YucUMSrCwQcLSlwVss96TxC6v92eQHygMGlJ4h7vsQxV96Cdbg3evYzd5AvQ61ZEHxVa715gcmUjQKZUy9kj1R3EDUHaBStkrxLimugpazd5AvQ61ZEHXbzUg(7n(6LtLUxV9AQFmTad5NMEHBVWxUE91lWEDUHaBStkrxLimugpazxSE91RVEb27PnL5OjM6TjyATWpkFrW0Abke6fyVkmsRfVnWOxXuVnbtR71ZEHFV(6fyVE7fNENBsb0aJyF5s(rtkahYCDQeKggfB3cdJa7vsQxfgP1I3gy0RyQ3MGP196zVWVxFqrg)lucfPEBu3bgb9qWbaaacxqruAoAcecFqr8PEAkdkYBVexxykIvPWsa7fyVCesdI8NmUjQKZgY1Qu1Rh9cp56vsQxV9YLzdms17HEbqVa7DiUmBGrIVCPE9Sx41RVELK6LlZgyKQ3d9c)E91lWEnmbxgXpcfz8Vqjuus(fUiuc9qWbaWhcxqruAoAcecFqr8PEAkdkYBVexxykIvPWsa7fyVCesdI8NmUjQKZgY1Qu1Rh9cp56vsQxV9YLzdms17HEbqVa7DiUmBGrIVCPE9Sx41RVELK6LlZgyKQ3d9c)E91lWEnmbxgXpcfz8VqjuKmtheUiuc9qWbaYheUGIO0C0eie(GI4t90uguK3EjUUWueRsHLa2lWE5iKge5pzCtujNnKRvPQxp6fEY1RKuVE7LlZgyKQ3d9cGEb27qCz2aJeF5s96zVWRxF9kj1lxMnWivVh6f(96RxG9AycUmIFekY4FHsOOWvRfUiuc9qWbaWdcxqrg)lucf53MPqJafeK(MeueLMJMaHWh0dbhai)q4ckIsZrtGq4dkcHbfPOhkY4FHsOOtBkZrtqrNM(sqrkmsRfVnWOxXuVnHAOE9Ox5R3y6nOrOPxV96AQNgafNM(s9gF9INCY1lC7faY1RVEJP3GgHME92RZneyQ3g1DGrcYfd5NgxkFHcPTHPEJFSx42R81RpOOtBeP5sqrQ3MqnKOsHcPTb6HGdaW9q4ckIsZrtGq4dkIp1ttzqrexxykIPVPnIKW)3RKuVexxykIzjGIKW)3lWEpTPmhnXkLGRj7K6vsQxNBiWiUUWuKqH02WgY1Qu1RN9A8Vqjt92eQHye(j(9jXxUuVa715gcmIRlmfjuiTnSlwVss9sCDHPiwLcfsBtVa7fNEpTPmhnXuVnHAirLcfsBtVss96Cdbg3evYzd5AvQ61ZEn(xOKPEBc1qmc)e)(K4lxQxG9ItVN2uMJMyLsW1KDs9cSxNBiW4MOsoBixRsvVE2lHFIFFs8Ll1lWEDUHaJBIk5SlwVss96Cdb2yNuIUkryOmEaYUy9cSxfgP1czM6PE9Ox5yYFVa71BVkmsRfVnWOx1RNh6f(9kj1lo9(MMYNPqxTafeVmseqdPEgLMJMa71xVss9ItVN2uMJMyLsW1KDs9cSxNBiW4MOsoBixRsvVE0lHFIFFs8Llbfz8VqjuK)XEzqpeCaG8acxqrg)lucfPEBc1qqruAoAcecFqpeCaqScHlOiknhnbcHpOiJ)fkHIMBkm(xOuOl1dfPl1lsZLGIcMw)YMl0d9qrbtRFzZfcxqWbpiCbfrP5Ojqi8bfXN6PPmOiC6DUjfqdmI5yAl5KafeMwlEzvctXOy7wyyeiuKX)cLqrQ3g1DGrqpeCaaeUGIO0C0eie(GIm(xOeksDZqneueFQNMYGIarpZfHYqneBixRsvVE07qUwLkOioGCnjEBGrVcco4b9qWb(q4ckY4FHsOixekd1qqruAoAcecFqp0dfPEiCbbh8GWfueLMJMaHWhuKX)cLqrgOH91jju(TXfkIp1ttzqr40li6zgOH91jju(TXvaAUgmI9f)yLW6fyV40RX)cLmd0W(6Kek)24kanxdgXQue0fmzFVa71BV40li6zgOH91jju(TXviJmn7l(XkH1RKuVGONzGg2xNKq53gxHmY0SHCTkv96rVWRxF9kj1li6zgOH91jju(TXvaAUgmIPEJFSxp7f(9cSxq0Zmqd7RtsO8BJRa0CnyeBixRsvVE2l87fyVGONzGg2xNKq53gxbO5AWi2x8JvcdkIdixtI3gy0RGGdEqpeCaaeUGIO0C0eie(GI4t90uguK3EpTPmhnX4O8eDKeGKcWK3lWEXPxocPbr(tg3evYzdzGa2RKuVo3qGXnrLC2fRxF9cSxt9JPfyi)00RN9kFY1lWE92RZneyexxyksOVPnSHCTkv96rV4jxVss96CdbgX1fMIekK2g2qUwLQE9Ox8KRxF9kj1BOGj7fd5AvQ61ZEXtoOiJ)fkHI4O8eDKeVmsOWQPEf0dbh4dHlOiknhnbcHpOieguKIEOiJ)fkHIoTPmhnbfDA6lbf5TxNBiW4MOsoBixRsvVE0l86fyVE715gcSXoPeDvIWqz8aKnKRvPQxp6fE9kj1lo96Cdb2yNuIUkryOmEaYUy96RxjPEXPxNBiW4MOso7I1RKuVM6htlWq(PPxp7f(Y1RVEb2R3EXPxNBiWowj4qGcYfd5NgxkFbL0aRIhXUy9kj1RP(X0cmKFA61ZEHVC96RxG96TxNBiWiUUWuKqH02WgY1Qu1Rh9cJdYCn83RKuVo3qGrCDHPiH(M2WgY1Qu1Rh9cJdYCn83RpOOtBeP5sqrGOxmuSDRHCP8vqpeCKpiCbfrP5Ojqi8bfz8VqjuKlcLHAiOi(upnLbfnuyiLmZrt9cS33gy0Z(YLepsawuVE0lEaOxG96TxdtWLr8J9cS3tBkZrtmq0lgk2U1qUu(QE9bfXbKRjXBdm6vqWbpOhcoWdcxqruAoAcecFqrg)lucfPUzOgckIp1ttzqrdfgsjZC0uVa79Tbg9SVCjXJeGf1Rh9Iha6fyVE71WeCze)yVa790MYC0ede9IHITBnKlLVQxFqrCa5As82aJEfeCWd6HGJ8dHlOiknhnbcHpOiJ)fkHIupP12icABiOi(upnLbfnuyiLmZrt9cS33gy0Z(YLepsawuVE0lEYFVa71BVgMGlJ4h7fyVN2uMJMyGOxmuSDRHCP8v96dkIdixtI3gy0RGGdEqpeCW9q4ckIsZrtGq4dkIp1ttzqrgMGlJ4hHIm(xOekkGgojqbrA)DiOhcoYdiCbfrP5Ojqi8bfXN6PPmOiNBiW4MOso7Ibfz8Vqju0yNuIUkryOmEac9qWjwHWfueLMJMaHWhueFQNMYGI82R3EDUHaJ46ctrcfsBdBixRsvVE0lEY1RKuVo3qGrCDHPiH(M2WgY1Qu1Rh9INC96RxG9YriniYFY4MOsoBixRsvVE0l8LRxG96TxNBiWWMYfnGLPf2WTS4cSRwzd700xQxp7faYNC9kj1lo9o3KcObgXWMYfnGLPf2WTS4cSRwzdJITBHHrG96RxF9kj1RZneyyt5IgWY0cB4wwCb2vRSHDA6l1Rhh6fa4E56vsQxocPbr(tg3evYzdzGa2lWE92RP(X0cmKFA61JEJv56vsQ3tBkZrtSsjme1RpOiJ)fkHIixmKFAeoOee6HGdEYbHlOiknhnbcHpOi(upnLbfHtVGZTazjsWbv9cS3tBkZrtmoOGJsW6lu2lWE92RP(X0cmKFA61JEJv56fyVE715gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVss9ItVC0jLw(SJaoLL96RxjPE5OtkT8zzbt2lcg1RKuVN2uMJMyLsyiQxjPEDUHaZrJqG6R6zxSEb2RZneyoAecuFvpBixRsvVE2laKR3y61BVE7nw7n(6DUjfqdmIHnLlAaltlSHBzXfyxTYggfB3cdJa71xVX0R3E5Oe8wpdBiEPiHPlyPlLp7lxsCA6l1RVE91RVEb2lo96Cdbg3evYzxSEb2R3EXPxo6KslFwwWK9IGr9kj1lhH0Gi)jJJYt0rs8YiHcRM6vSlwVss9w5tdgsBpbkcfmzVyixRsvVE2lhH0Gi)jJJYt0rs8YiHcRM6vSHCTkv9gtVYFVss9w5tdgsBpbkcfmzVyixRsvVYBV4jpKRxp7faY1Bm96TxokbV1ZWgIxksy6cw6s5Z(YLeNM(s96RxFqrg)lucfXjnP(Y0ctxWsxkFOhco4HheUGIO0C0eie(GI4t90ugueo9co3cKLibhu1lWEpTPmhnX4GcokbRVqzVa71BVM6htlWq(PPxp6nwLRxG96TxNBiWowj4qGcYfd5NgxkFbL0aRIhXUy9kj1lo9YrNuA5Zoc4uw2RVELK6LJoP0YNLfmzViyuVss9EAtzoAIvkHHOELK615gcmhncbQVQNDX6fyVo3qG5Oriq9v9SHCTkv96zVWxUEJPxV96T3yT34R35MuanWig2uUObSmTWgULfxGD1kByuSDlmmcSxF9gtVE7LJsWB9mSH4LIeMUGLUu(SVCjXPPVuV(61xV(6fyV40RZneyCtujNDX6fyVE7fNE5OtkT8zzbt2lcg1RKuVCesdI8NmokprhjXlJekSAQxXUy9kj1BLpnyiT9eOiuWK9IHCTkv96zVCesdI8NmokprhjXlJekSAQxXgY1Qu1Bm9k)9kj1BLpnyiT9eOiuWK9IHCTkv9kV9IN8qUE9Sx4lxVX0R3E5Oe8wpdBiEPiHPlyPlLp7lxsCA6l1RVE9bfz8VqjuuLCBs7luc9qWbpaaHlOiknhnbcHpOieguKIEOiJ)fkHIoTPmhnbfDA6lbfHtVCesdI8NmUjQKZgYabSxjPEXP3tBkZrtmokprhjbiPam59cSxo6KslFwwWK9IGr9kj1l4ClqwIeCqfu0PnI0CjOiLDsIaAeCtujh6HGdEWhcxqruAoAcecFqr8PEAkdkI46ctrSkfwcyVa71WeCze)yVa715gcmSPCrdyzAHnCllUa7Qv2Won9L61ZEbG8jxVa71BVGONzGg2xNKq53gxbO5AWi2x8JvcRxjPEXPxo6KslFws8bPrdyV(6fyVN2uMJMyk7Keb0i4MOsouKX)cLqrH7aOafeK(Me0dbh8KpiCbfrP5Ojqi8bfXN6PPmOiNBiWqj9YucmA4e2xOKDX6fyVo3qGPEBcMwZgkmKsM5OjOiJ)fkHIuVnbtRHEi4Gh8GWfueLMJMaHWhueFQNMYGICUHat92OrdiBixRsvVE2l86fyVE715gcmIRlmfjuiTnSHCTkv96rVWRxjPEDUHaJ46ctrc9nTHnKRvPQxp6fE96RxG9AQFmTad5NME9O3yvoOiJ)fkHI4wYjTW5gcqro3qqKMlbfPEB0Obe6HGdEYpeUGIO0C0eie(GI4t90ugu0BAkFM6jT2gb4uHNrP5OjWEb2RI(VsykMcPrcWPcFVa715gcm1BtW0AgiYFcfz8VqjuK6TjyAn0dbh8W9q4ckIsZrtGq4dkIp1ttzqrC0jLw(SSGj7fbJ6fyVN2uMJMyCuEIoscqsbyY7fyVCesdI8NmokprhjXlJekSAQxXgY1Qu1RN9cVEb2lo9co3cKLibhubfz8VqjuK6TrDhye0dbh8Khq4ckIsZrtGq4dkIp1ttzqrVPP8zQN0ABeGtfEgLMJMa7fyV407BAkFM6TrJgqgLMJMa7fyVo3qGPEBcMwZgkmKsM5OPEb2R3EDUHaJ46ctrc9nTHnKRvPQxp6v(7fyVexxykIvPqFtB6fyVo3qGHnLlAaltlSHBzXfyxTYg2PPVuVE2laGNC9kj1RZneyyt5IgWY0cB4wwCb2vRSHDA6l1Rhh6faWtUEb2RP(X0cmKFA61JEJv56vsQxq0Zmqd7RtsO8BJRa0CnyeBixRsvVE0R8OxjPEn(xOKzGg2xNKq53gxbO5AWiwLIGUGj771xVa7fNE5iKge5pzCtujNnKbciuKX)cLqrQ3MGP1qpeCWlwHWfueLMJMaHWhueFQNMYGICUHadL0ltj4AYgXzPkuYUy9kj1RZneyhReCiqb5IH8tJlLVGsAGvXJyxSELK615gcmUjQKZUy9cSxV96Cdb2yNuIUkryOmEaYgY1Qu1RN9cJdYCn83B81lNkDVE71u)yAbgYpn9c3EHVC96RxG96Cdb2yNuIUkryOmEaYUy9kj1lo96Cdb2yNuIUkryOmEaYUy9cSxC6LJqAqK)Kn2jLORsegkJhGSHmqa7vsQxC6LJoP0YNDs5ldWPxF9kj1RP(X0cmKFA61JEJv56fyVexxykIvPWsaHIm(xOeks92OUdmc6HGdaKdcxqruAoAcecFqr8PEAkdk6nnLpt92OrdiJsZrtG9cSxV96CdbM6TrJgq2fRxjPEn1pMwGH8ttVE0BSkxV(6fyVo3qGPEB0ObKPEJFSxp7f(9cSxV96CdbgX1fMIekK2g2fRxjPEDUHaJ46ctrc9nTHDX61xVa715gcmSPCrdyzAHnCllUa7Qv2Won9L61ZEbaUxUEb2R3E5iKge5pzCtujNnKRvPQxp6fp56vsQxC690MYC0eJJYt0rsaskatEVa7LJoP0YNLfmzViyuV(GIm(xOeks92OUdmc6HGdaWdcxqruAoAcecFqr8PEAkdkYBVo3qGHnLlAaltlSHBzXfyxTYg2PPVuVE2laW9Y1RKuVo3qGHnLlAaltlSHBzXfyxTYg2PPVuVE2laGNC9cS330u(m1tATncWPcpJsZrtG96RxG96CdbgX1fMIekK2g2qUwLQE9OxCFVa7L46ctrSkfkK2MEb2lo96CdbgkPxMsGrdNW(cLSlwVa7fNEFtt5ZuVnA0aYO0C0eyVa7LJqAqK)KXnrLC2qUwLQE9OxCFVa71BVCesdI8NmYfd5NgHdkbzd5AvQ61JEX99kj1lo9YrNuA5Zoc4uw2RpOiJ)fkHIuVnQ7aJGEi4aaaaHlOiknhnbcHpOi(upnLbf5TxNBiWiUUWuKqFtByxSELK61BVCz2aJu9EOxa0lWEhIlZgyK4lxQxp7fE96RxjPE5YSbgP69qVWVxF9cSxdtWLr8J9cS3tBkZrtmLDsIaAeCtujhkY4FHsOOK8lCrOe6HGdaGpeUGIO0C0eie(GI4t90uguK3EDUHaJ46ctrc9nTHDX6fyV40lhDsPLp7iGtzzVss96TxNBiWowj4qGcYfd5NgxkFbL0aRIhXUy9cSxo6KslF2raNYYE91RKuVE7LlZgyKQ3d9cGEb27qCz2aJeF5s96zVWRxF9kj1lxMnWivVh6f(9kj1RZneyCtujNDX61xVa71WeCze)yVa790MYC0etzNKiGgb3evYHIm(xOeksMPdcxekHEi4aa5dcxqruAoAcecFqr8PEAkdkYBVo3qGrCDHPiH(M2WUy9cSxC6LJoP0YNDeWPSSxjPE92RZneyhReCiqb5IH8tJlLVGsAGvXJyxSEb2lhDsPLp7iGtzzV(6vsQxV9YLzdms17HEbqVa7DiUmBGrIVCPE9Sx41RVELK6LlZgyKQ3d9c)ELK615gcmUjQKZUy96RxG9AycUmIFSxG9EAtzoAIPStseqJGBIk5qrg)lucffUATWfHsOhcoaaEq4ckY4FHsOi)2mfAeOGG03KGIO0C0eie(GEi4aa5hcxqruAoAcecFqr8PEAkdkI46ctrSkf6BAtVss9sCDHPiMcPTrKe()ELK6L46ctrmlbuKe()ELK615gcm)2mfAeOGG03KyxSEb2RZneyexxyksOVPnSlwVss96TxNBiW4MOsoBixRsvVE2RX)cLm)J9Yye(j(9jXxUuVa715gcmUjQKZUy96dkY4FHsOi1BtOgc6HGdaW9q4ckY4FHsOi)J9YGIO0C0eie(GEi4aa5beUGIO0C0eie(GIm(xOekAUPW4FHsHUupuKUuVinxckkyA9lBUqp0dfboK56ujinq4cco4bHlOiknhnbcHpOieguKIEOiJ)fkHIoTPmhnbfDA6lbf5TxNBiW(YL8JMuaoK56ujinSHCTkv96rVW4Gmxd)9gtVYXWRxG96TxIRlmfXQu4GEz9kj1lX1fMIyvkuiTn9kj1lX1fMIy6BAJij8)96RxjPEDUHa7lxYpAsb4qMRtLG0WgY1Qu1Rh9A8Vqjt92eQHye(j(9jXxUuVX0RCm86fyVE7L46ctrSkf6BAtVss9sCDHPiMcPTrKe()ELK6L46ctrmlbuKe()E91RVELK6fNEDUHa7lxYpAsb4qMRtLG0WUyqrN2isZLGIuwGepsCvKqHrAn0dbhaaHlOiknhnbcHpOi(upnLbf9MMYNPEsRTraov4zuAoAcSxG9QO)ReMIPqAKaCQW3lWEDUHat92emTMbI8Nqrg)lucfPEBcMwd9qWb(q4ckIsZrtGq4dkIp1ttzqrE7fNEpTPmhnXuwGepsCvKqHrADVss96TxNBiWg7Ks0vjcdLXdq2qUwLQE9SxyCqMRH)EJVE5uP71BVM6htlWq(PPx42l8LRxF9cSxNBiWg7Ks0vjcdLXdq2fRxF96RxjPEn1pMwGH8ttVE0BSkhuKX)cLqrQ3g1DGrqpeCKpiCbfrP5Ojqi8bfXN6PPmOiV9EAtzoAIXr5j6ijajfGjVxG9w5tdgsBpbkcfmzVyixRsvVE0lEWxUEb2lo9YriniYFY4MOsoBideWELK615gcmUjQKZUy96RxG9AQFmTad5NME9Sx5tUEb2R3EDUHaJ46ctrc9nTHnKRvPQxp6fp56vsQxNBiWiUUWuKqH02WgY1Qu1Rh9INC96RxjPEdfmzVyixRsvVE2lEYbfz8VqjuehLNOJK4Lrcfwn1RGEi4apiCbfrP5Ojqi8bfz8VqjuKbAyFDscLFBCHI4t90ugueo9cIEMbAyFDscLFBCfGMRbJyFXpwjSEb2lo9A8VqjZanSVojHYVnUcqZ1GrSkfbDbt23lWE92lo9cIEMbAyFDscLFBCfYitZ(IFSsy9kj1li6zgOH91jju(TXviJmnBixRsvVE0l861xVss9cIEMbAyFDscLFBCfGMRbJyQ34h71ZEHFVa7fe9md0W(6Kek)24kanxdgXgY1Qu1RN9c)Eb2li6zgOH91jju(TXvaAUgmI9f)yLWGI4aY1K4Tbg9ki4Gh0dbh5hcxqruAoAcecFqrg)lucf5IqzOgckIp1ttzqrdfgsjZC0uVa79Tbg9SVCjXJeGf1Rh9Iha6fyVE71BVo3qGXnrLC2qUwLQE9Ox41lWE92RZneyJDsj6QeHHY4biBixRsvVE0l86vsQxC615gcSXoPeDvIWqz8aKDX61xVss9ItVo3qGXnrLC2fRxjPEn1pMwGH8ttVE2l8LRxF9cSxV9ItVo3qGDSsWHafKlgYpnUu(ckPbwfpIDX6vsQxt9JPfyi)00RN9cF561xVa71WeCze)yV(GI4aY1K4Tbg9ki4Gh0dbhCpeUGIO0C0eie(GIm(xOeksDZqneueFQNMYGIgkmKsM5OPEb27Bdm6zF5sIhjalQxp6fpa0lWE92R3EDUHaJBIk5SHCTkv96rVWRxG96TxNBiWg7Ks0vjcdLXdq2qUwLQE9Ox41RKuV40RZneyJDsj6QeHHY4bi7I1RVELK6fNEDUHaJBIk5SlwVss9AQFmTad5NME9Sx4lxV(6fyVE7fNEDUHa7yLGdbkixmKFACP8fusdSkEe7I1RKuVM6htlWq(PPxp7f(Y1RVEb2RHj4Yi(XE9bfXbKRjXBdm6vqWbpOhcoYdiCbfrP5Ojqi8bfz8VqjuK6jT2grqBdbfXN6PPmOOHcdPKzoAQxG9(2aJE2xUK4rcWI61JEXt(7fyVE71BVo3qGXnrLC2qUwLQE9Ox41lWE92RZneyJDsj6QeHHY4biBixRsvVE0l86vsQxC615gcSXoPeDvIWqz8aKDX61xVss9ItVo3qGXnrLC2fRxjPEn1pMwGH8ttVE2l8LRxF9cSxV9ItVo3qGDSsWHafKlgYpnUu(ckPbwfpIDX6vsQxt9JPfyi)00RN9cF561xVa71WeCze)yV(GI4aY1K4Tbg9ki4Gh0dbNyfcxqruAoAcecFqr8PEAkdkYWeCze)iuKX)cLqrb0Wjbkis7Vdb9qWbp5GWfueLMJMaHWhueFQNMYGICUHaJBIk5SlguKX)cLqrJDsj6QeHHY4bi0dbh8WdcxqruAoAcecFqr8PEAkdkYBVE715gcmIRlmfjuiTnSHCTkv96rV4jxVss96CdbgX1fMIe6BAdBixRsvVE0lEY1RVEb2lhH0Gi)jJBIk5SHCTkv96rVWxUE91RKuVCesdI8NmUjQKZgYabekY4FHsOiYfd5NgHdkbHEi4GhaGWfueLMJMaHWhueFQNMYGIWPxW5wGSej4GQEb27PnL5OjghuWrjy9fk7fyVE71BVo3qGDSsWHafKlgYpnUu(ckPbwfpIDX6vsQxC6LJoP0YNDeWPSSxF9kj1lhDsPLpllyYErWOELK690MYC0eRucdr9kj1RZneyoAecuFvp7I1lWEDUHaZrJqG6R6zd5AvQ61ZEbGC9gtVE7LJsWB9mSH4LIeMUGLUu(SVCjXPPVuV(61xVa7fNEDUHaJBIk5SlwVa71BV40lhDsPLpllyYErWOELK6LJqAqK)KXr5j6ijEzKqHvt9k2fRxjPER8PbdPTNafHcMSxmKRvPQxp7LJqAqK)KXr5j6ijEzKqHvt9k2qUwLQEJPx5VxjPER8PbdPTNafHcMSxmKRvPQx5Tx8KhY1RN9ca56nME92lhLG36zydXlfjmDblDP8zF5sIttFPE91RpOiJ)fkHI4KMuFzAHPlyPlLp0dbh8GpeUGIO0C0eie(GI4t90ugueo9co3cKLibhu1lWEpTPmhnX4GcokbRVqzVa71BVE715gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVss9ItVC0jLw(SJaoLL96RxjPE5OtkT8zzbt2lcg1RKuVN2uMJMyLsyiQxjPEDUHaZrJqG6R6zxSEb2RZneyoAecuFvpBixRsvVE2l8LR3y61BVCucERNHneVuKW0fS0LYN9Lljon9L61xV(6fyV40RZneyCtujNDX6fyVE7fNE5OtkT8zzbt2lcg1RKuVCesdI8NmokprhjXlJekSAQxXUy9kj1BLpnyiT9eOiuWK9IHCTkv96zVCesdI8NmokprhjXlJekSAQxXgY1Qu1Bm9k)9kj1BLpnyiT9eOiuWK9IHCTkv9kV9IN8qUE9Sx4lxVX0R3E5Oe8wpdBiEPiHPlyPlLp7lxsCA6l1RVE9bfz8VqjuuLCBs7luc9qWbp5dcxqruAoAcecFqrimOif9qrg)lucfDAtzoAck600xckcNE5iKge5pzCtujNnKbcyVss9ItVN2uMJMyCuEIoscqsbyY7fyVC0jLw(SSGj7fbJ6vsQxW5wGSej4GkOOtBeP5sqrk7Keb0i4MOso0dbh8GheUGIO0C0eie(GI4t90ugueX1fMIyvkSeWEb2RHj4Yi(XEb2R3EbrpZanSVojHYVnUcqZ1GrSV4hRewVss9ItVC0jLw(SK4dsJgWE91lWEpTPmhnXu2jjcOrWnrLCOiJ)fkHIc3bqbkii9njOhco4j)q4ckIsZrtGq4dkIp1ttzqrC0jLw(SSGj7fbJ6fyVN2uMJMyCuEIoscqsbyY7fyVM6htlWq(PPxpo0R8jxVa7LJqAqK)KXr5j6ijEzKqHvt9k2qUwLQE9SxyCqMRH)EJVE5uP71BVM6htlWq(PPx42l8LRxF9cSxC6fCUfilrcoOckY4FHsOi1BJ6oWiOhco4H7HWfueLMJMaHWhueFQNMYGI82RZneyexxyksOVPnSlwVss96TxUmBGrQEp0la6fyVdXLzdms8Ll1RN9cVE91RKuVCz2aJu9EOx43RVEb2RHj4Yi(XEb27PnL5OjMYojrancUjQKdfz8Vqjuus(fUiuc9qWbp5beUGIO0C0eie(GI4t90uguK3EDUHaJ46ctrc9nTHDX6fyV40lhDsPLp7iGtzzVss96TxNBiWowj4qGcYfd5NgxkFbL0aRIhXUy9cSxo6KslF2raNYYE91RKuVE7LlZgyKQ3d9cGEb27qCz2aJeF5s96zVWRxF9kj1lxMnWivVh6f(9kj1RZneyCtujNDX61xVa71WeCze)yVa790MYC0etzNKiGgb3evYHIm(xOeksMPdcxekHEi4GxScHlOiknhnbcHpOi(upnLbf5TxNBiWiUUWuKqFtByxSEb2lo9YrNuA5Zoc4uw2RKuVE715gcSJvcoeOGCXq(PXLYxqjnWQ4rSlwVa7LJoP0YNDeWPSSxF9kj1R3E5YSbgP69qVaOxG9oexMnWiXxUuVE2l861xVss9YLzdms17HEHFVss96Cdbg3evYzxSE91lWEnmbxgXp2lWEpTPmhnXu2jjcOrWnrLCOiJ)fkHIcxTw4Iqj0dbhaiheUGIm(xOekYVntHgbkii9njOiknhnbcHpOhcoaapiCbfrP5Ojqi8bfXN6PPmOiIRlmfXQuOVPn9kj1lX1fMIykK2grs4)7vsQxIRlmfXSeqrs4)7vsQxNBiW8BZuOrGccsFtIDX6fyVo3qGrCDHPiH(M2WUy9kj1R3EDUHaJBIk5SHCTkv96zVg)luY8p2lJr4N43NeF5s9cSxNBiW4MOso7I1RpOiJ)fkHIuVnHAiOhcoaaaq4ckY4FHsOi)J9YGIO0C0eie(GEi4aa4dHlOiknhnbcHpOiJ)fkHIMBkm(xOuOl1dfPl1lsZLGIcMw)YMl0d9qpu0jnQcLqWbaYba8Kdp5aauKFBYkHPGIWTjplpfo42HtS0yrV9IlzuVLlgA(EdOPxCh4qMRtLG0G76DOy7wdb2Rc5s9A3h5Apb2lxMLWifRJl(RK6f(XIEJDuEsZtG9gvUXEVkaZ3WFVYBVpQ34)A9cwNLQqzVimAShn96fU(61lE43hRJl(RK6fpael6n2r5jnpb2Bu5g79QamFd)9kVYBVpQ34)A96IaV6RQxegn2JME9kV(61lE43hRJl(RK6fp4hl6n2r5jnpb2Bu5g79QamFd)9kVYBVpQ34)A96IaV6RQxegn2JME9kV(61lE43hRJl(RK6fp5pw0BSJYtAEcS3OYn27vby(g(7vE79r9g)xRxW6Sufk7fHrJ9OPxVW1xVEXd)(yDCDC42KNLNchC7WjwASO3EXLmQ3YfdnFVb00lUdKc2v)4UEhk2U1qG9QqUuV29rU2tG9YLzjmsX64I)kPEL)yrVXokpP5jWEJk3yVxfG5B4Vx5T3h1B8FTEbRZsvOSxegn2JME9cxF96fa43hRJl(RK6fp8If9g7O8KMNa7f3n3KcObgXKNG769r9I7MBsb0aJyYtyuAoAce31RxaGFFSoUooCBYZYtHdUD4elnw0BV4sg1B5IHMV3aA6f3Hneh56ypUR3HITBneyVkKl1RDFKR9eyVCzwcJuSoU4VsQx4fl6n2r5jnpb2lUBUjfqdmIjpb317J6f3n3KcObgXKNWO0C0eiURxV4HFFSoU4VsQx5pw0BSJYtAEcSxC3CtkGgyetEcUR3h1lUBUjfqdmIjpHrP5OjqCxVEXd)(yDCDC42KNLNchC7WjwASO3EXLmQ3YfdnFVb00lUZqeUR3HITBneyVkKl1RDFKR9eyVCzwcJuSoU4VsQx4hl6n2r5jnpb2lUBUjfqdmIjpb317J6f3n3KcObgXKNWO0C0eiURxV4HFFSoU4VsQx4fl6n2r5jnpb2Bu5g79QamFd)9kVYBVpQ34)A96IaV6RQxegn2JME9kV(61lE43hRJl(RK6f3hl6n2r5jnpb2Bu5g79QamFd)9kV9(OEJ)R1lyDwQcL9IWOXE00Rx46RxV4HFFSoU4VsQx8Klw0BSJYtAEcS3OYn27vby(g(7vE79r9g)xRxW6Sufk7fHrJ9OPxVW1xVEXd)(yDCXFLuV4jFXIEJDuEsZtG9gvUXEVkaZ3WFVYR827J6n(VwVUiWR(Q6fHrJ9OPxVYRVE9Ih(9X64I)kPEXlwJf9g7O8KMNa7nQCJ9EvaMVH)EL3EFuVX)16fSolvHYEry0ypA61lC91Rx8WVpwhx8xj1laWlw0BSJYtAEcS3OYn27vby(g(7vE79r9g)xRxW6Sufk7fHrJ9OPxVW1xVEXd)(yDCXFLuVaq(Jf9g7O8KMNa7nQCJ9EvaMVH)EL3EFuVX)16fSolvHYEry0ypA61lC91RxaGFFSoUooCBYZYtHdUD4elnw0BV4sg1B5IHMV3aA6f3PECxVdfB3AiWEvixQx7(ix7jWE5YSegPyDCXFLuV4jxSO3yhLN08eyVrLBS3RcW8n83R8kV9(OEJ)R1Rlc8QVQEry0ypA61R86RxV4HFFSoU4VsQx8Wlw0BSJYtAEcS3OYn27vby(g(7vEL3EFuVX)161fbE1xvVimAShn96vE91Rx8WVpwhx8xj1lEXASO3yhLN08eyVrLBS3RcW8n83R827J6n(VwVG1zPku2lcJg7rtVEHRVE9Ih(9X6464WTjplpfo42HtS0yrV9IlzuVLlgA(EdOPxCNdYECxVdfB3AiWEvixQx7(ix7jWE5YSegPyDCXFLuV4jpIf9g7O8KMNa7nQCJ9EvaMVH)EL3EFuVX)16fSolvHYEry0ypA61lC91Rx4JFFSoU4VsQx8I1yrVXokpP5jWEJk3yVxfG5B4Vx5T3h1B8FTEbRZsvOSxegn2JME9cxF96fp87J1X1XHB3fdnpb2lUVxJ)fk7vxQxX64GIWguO0eueUvV4Z0wYPEJLBUfyhhUvVXz51ga7fp8ayVaqoaGxhxhhUvVXUmlHrQyrhhUvV4MELNbbjWEJqAB6fFK5Y64WT6f30BSlZsyeyVVnWOxuHE5MIu9(OE5aY1K4Tbg9kwhhUvV4MELNsUOtcS3BMeNukBaS3tBkZrtQE9wmIbWEXg6uOEBu3bg1lUXJEXg6KPEBu3bg5J1XHB1lUPx55tub2l2qCt9vcRxCBJ9Y6Tc9wpUt17lJ61)Gsy9gldxxykI1XHB1lUP3yzTJuVXokprhPEFzuVry1uVQxRxD9VM61fnuVbnH)Yrt96Tc9ci62RmdmXDFVYQV367vvUx9BjHUknG96VEz9IVy5LNXvVX0BStAs9LP7vEwxWsxkFa2B94oWEvhlmFSoUooJ)fkvmSH4ixh7pCSsWHafkSAQx1Xz8VqPIHneh56yFmhGRlcLhRueqJBhNX)cLkg2qCKRJ9XCaU(h7LbqDLKGdEap5ayfo4L46ctrm9nTrKe(FjjIRlmfXQuOVPnssexxykIvPWb9YKKiUUWueZsafjH)3xhNX)cLkg2qCKRJ9XCaU(h7LbWkCWlX1fMIy6BAJij8)ssexxykIvPqFtBKKiUUWueRsHd6LjjrCDHPiMLaksc)VpGydDYWJ5FSxgqCWg6KbaM)XEzDCg)luQyydXrUo2hZb4QEBc1qaSchWzUjfqdmI5yAl5KafeMwlEzvctjjHdhDsPLpllyYErWijjCuyKwlEBGrVIPEBcMwFapjjCEtt5Zs7VdPeoM2soXO0C0eyhNX)cLkg2qCKRJ9XCaUQ3g1DGraSchMBsb0aJyoM2sojqbHP1IxwLWua5OtkT8zzbt2lcgbuHrAT4Tbg9kM6TjyA9b86464WT6nwg8t87tG9sN0ayVF5s9(YOEn(JMElvV2PvAZrtSooJ)fkvhuiTnchYC74m(xOuD40MYC0eatZLoukHHiaEA6lDqHrAT4Tbg9kM6TjyATh4b0loVPP8zQ3gnAazuAoAcus6nnLpt9KwBJaCQWZO0C0eOpjjfgP1I3gy0RyQ3MGP1EaGooJ)fkvXCaUN2uMJMayAU0Hsj4AYojaEA6lDqHrAT4Tbg9kM6Tjud5bEDCg)luQI5aCDOrrZXkHbWkCWloC0jLw(SSGj7fbJKKWHJqAqK)KXr5j6ijEzKqHvt9k2fZhqNBiW4MOso7I1Xz8VqPkMdWfd9fkbyfo4Cdbg3evYzxSooJ)fkvXCaUN2uMJMayAU0bokprhjbiPam5a800x6qqJqJxVv(0GH02tGIqbt2lgY1QuHBaGC4gocPbr(tghLNOJK4Lrcfwn1Ryd5AvQ8jV4ba585rqJqJxVv(0GH02tGIqbt2lgY1QuHBaa8WnEXtU47nnLpRsUnP9fkzuAoAc0hUXlhLG36zydXlfjmDblDP8zF5sIttFjF4gocPbr(tg3evYzd5AvQ8jV4jpKZNKehH0Gi)jJBIk5SHCTkvEu5tdgsBpbkcfmzVyixRsLKehH0Gi)jJJYt0rs8YiHcRM6vSHCTkvEu5tdgsBpbkcfmzVyixRsLKeoC0jLw(SSGj7fbJ64m(xOufZb4EAtzoAcGP5sh4GcokbRVqjapn9Lo4fhk2UfggbYixmahY0c0aMwYjjjocPbr(tg5Ib4qMwGgW0soXgY1Qu5jEYVCaXHJqAqK)KrUyaoKPfObmTKtSHmqa9jjXrNuA5Zoc4uw2Xz8VqPkMdW9Qir9KlatZLoqUyaoKPfObmTKtaSch4iKge5pzCtujNnKRvPYtaihWtBkZrtmokprhjbiPam5ssCesdI8NmokprhjXlJekSAQxXgY1Qu5jaKRJZ4FHsvmhG7vrI6jxaMMlDqHUAn9FLWeZ1bqawHdCesdI8NmUjQKZgY1Qu5P8d80MYC0eJJYt0rsaskatUKehH0Gi)jJJYt0rs8YiHcRM6vSHCTkvEk)DCg)luQI5aCVksup5cW0CPdvQ4Z9nhnjITRL)1vasNfNayfo4Cdbg3evYzxSooCREn(xOufZb4EvKOEYvbqLg9Qd)u5r6XdGv4ao)u5r6z4XKzkb2G4mlbeOxC(PYJ0ZaatMPeydIZSeqjjC(PYJ0ZaaBideqbhH0Gi)PpjjNBiW4MOso7IjjXriniYFY4MOsoBixRsfUbp584NkpspdpghH0Gi)jd8o2xOeioC0jLw(SJaoLLssC0jLw(SSGj7fbJaEAtzoAIXr5j6ijajfGjhihH0Gi)jJJYt0rs8YiHcRM6vSlMKKZneyhReCiqb5IH8tJlLVGsAGvXJyxmjPqbt2lgY1Qu5jaKRJd3QxJ)fkvXCaUxfjQNCvauPrV6WpvEKEaaWkCaNFQ8i9maWKzkb2G4mlbeOxC(PYJ0ZWJjZucSbXzwcOKeo)u5r6z4XgYabuWriniYF6ts6NkpspdpMmtjWgeNzjGa)PYJ0ZaatMPeydIZSeqG48tLhPNHhBideqbhH0Gi)PKKZneyCtujNDXKK4iKge5pzCtujNnKRvPc3GNCE8tLhPNbaghH0Gi)jd8o2xOeioC0jLw(SJaoLLssC0jLw(SSGj7fbJaEAtzoAIXr5j6ijajfGjhihH0Gi)jJJYt0rs8YiHcRM6vSlMKKZneyhReCiqb5IH8tJlLVGsAGvXJyxmjPqbt2lgY1Qu5jaKRJZ4FHsvmhG7vrI6jxfaRWbNBiW4MOso7IjjXrNuA5ZYcMSxemc4PnL5OjghLNOJKaKuaMCGCesdI8NmokprhjXlJekSAQxXUyaXHJqAqK)KXnrLC2fdOxVo3qGrCDHPiH(M2WgY1Qu5bEYjj5CdbgX1fMIekK2g2qUwLkpWtoFaXzUjfqdmI5yAl5KafeMwlEzvctjjn3KcObgXCmTLCsGcctRfVSkHPa615gcmhtBjNeOGW0AXlRsykrA)DiM6n(rpGVKKZneyoM2sojqbHP1IxwLWucB4wsm1B8JEaFF(KKCUHa7yLGdbkixmKFACP8fusdSkEe7IjjfkyYEXqUwLkpbGCDCg)luQI5aCNBkm(xOuOl1dW0CPdgIaO6NI)hWdGv4WPnL5OjwPegI64m(xOufZb4o3uy8VqPqxQhGP5shahYCDQeKgaQ(P4)b8ayfom3KcObgX(YL8JMuaoK56ujinmk2Ufggb2Xz8VqPkMdWDUPW4FHsHUupatZLo4GShGQFk(FapawHdZnPaAGrmhtBjNeOGW0AXlRsykgfB3cdJa74m(xOufZb4o3uy8VqPqxQhGP5shuFhxhNX)cLkMHOdN2uMJMayAU0bWHmxH)sRfbtRfOqaGNM(sh86Cdb2xUKF0KcWHmxNkbPHnKRvPYtyCqMRH)yKJHNKKZneyF5s(rtkahYCDQeKg2qUwLkpn(xOKPEBc1qmc)e)(K4lxkg5y4b0lX1fMIyvk030gjjIRlmfXuiTnIKW)ljrCDHPiMLaksc)VpFaDUHa7lxYpAsb4qMRtLG0WUyaNBsb0aJyF5s(rtkahYCDQeKggfB3cdJa74m(xOuXmefZb4EAtzoAcGP5shkyjAiH6TrDhyeapn9Lo4CdbgX1fMIe6BAd7Ib0RcJ0AXBdm6vm1BtOgYd5d4BAkFMcD1cuq8YiranK6zuAoAcussHrAT4Tbg9kM6Tjud5H87RJZ4FHsfZqumhGlhLNOJK4Lrcfwn1Rayfo490MYC0eJJYt0rsaskatoqC4iKge5pzCtujNnKbcOKKZneyCtujNDX8b0RP(X0cmKFA8eEYjjDAtzoAIvWs0qc1BJ6oWiFa96CdbgX1fMIe6BAdBixRsLhYVKKZneyexxyksOqAByd5AvQ8q(9b0loZnPaAGrmhtBjNeOGW0AXlRsykjjNBiWCmTLCsGcctRfVSkHPeP93HyQ34h9a(sso3qG5yAl5KafeMwlEzvctjSHBjXuVXp6b89jjfkyYEXqUwLkpXtUooJ)fkvmdrXCaUQBgQHaihqUMeVnWOxDapawHddfgsjZC0eW3gy0Z(YLepsawKh4jF4gfgP1I3gy0RIzixRsfqVexxykIvPWsaLKgY1Qu5jmoiZ1WVVooJ)fkvmdrXCaUQ3MGP1aSchCUHat92emTMnuyiLmZrta9QWiTw82aJEft92emT2t4ljHZCtkGgye7lxYpAsb4qMRtLG0WOy7wyyeOpGEXzUjfqdmIPbKBJPebnrFLWeW0LlMIyuSDlmmcus6lxsELx5dEE4CdbM6TjyAnBixRsvmaWhWqbt2lgY1Qu5b864m(xOuXmefZb4QEBcMwdWkCyUjfqdmI9Ll5hnPaCiZ1PsqAyuSDlmmceOcJ0AXBdm6vm1BtW0ApoaFGEXX5gcSVCj)OjfGdzUovcsd7Ib05gcm1BtW0A2qHHuYmhnjj590MYC0edCiZv4V0ArW0Abkea615gcm1BtW0A2qUwLkpHVKKcJ0AXBdm6vm1BtW0ApaaW30u(m1tATncWPcpJsZrtGaDUHat92emTMnKRvPYt45ZNVooJ)fkvmdrXCaUN2uMJMayAU0b1BtW0AHFu(IGP1cuiaWttFPdM6htlWq(PXd5HC4gV4jx85Cdb2xUKF0KcWHmxNkbPHPEJF0hUXRZneyQ3MGP1SHCTkvXh8LxfgP1czM6jF4gVGONfUdGcuqq6BsSHCTkvXh88b05gcm1BtW0A2fRJZ4FHsfZqumhGR6TrDhyeaRWHtBkZrtmWHmxH)sRfbtRfOqa4PnL5OjM6TjyATWpkFrW0AbkeaIZPnL5OjwblrdjuVnQ7aJKK86CdbMJPTKtcuqyAT4LvjmLiT)oet9g)OhWxsY5gcmhtBjNeOGW0AXlRsykHnCljM6n(rpGVpGkmsRfVnWOxXuVnbtR9u(64m(xOuXmefZb4AGg2xNKq53gxaYbKRjXBdm6vhWdGv4aoFXpwjmG4y8VqjZanSVojHYVnUcqZ1GrSkfbDbt2ljbIEMbAyFDscLFBCfGMRbJyQ34h9e(abrpZanSVojHYVnUcqZ1GrSHCTkvEc)ooJ)fkvmdrXCaUUiugQHaihqUMeVnWOxDapawHddfgsjZC0eW3gy0Z(YLepsawKhEXt(IXRcJ0AXBdm6vm1BtOgk(WJbpF(KxfgP1I3gy0RIzixRsfqVE5iKge5pzCtujNnKbciqCaNBbYsKGdQa690MYC0eJJYt0rsaskatUKehH0Gi)jJJYt0rs8YiHcRM6vSHmqaLKWHJoP0YNLfmzViyKpjjfgP1I3gy0RyQ3MqnKNEHx85fVyEtt5ZE)vkCrOuXO0C0eOpFssEjUUWueRsHcPTrsYlX1fMIyvkCqVmjjIRlmfXQuOVPn(aIZBAkFMcD1cuq8YiranK6zuAoAcusY5gcmSPCrdyzAHnCllUa7Qv2Won9L84aaGNC(a6vHrAT4Tbg9kM6Tjud5jEYfFEXlM30u(S3FLcxekvmknhnb6Zhqt9JPfyi)04b8Kd34CdbM6TjyAnBixRsv8j)(a6fhNBiWowj4qGcYfd5NgxkFbL0aRIhXUyssexxykIvPqH02ijHdhDsPLp7iGtzPpGgMGlJ4h91Xz8VqPIzikMdWnGgojqbrA)DiawHdgMGlJ4h74m(xOuXmefZb4o2jLORsegkJhGaSchCUHaJBIk5SlwhNX)cLkMHOyoaxoPj1xMwy6cw6s5dWkCahW5wGSej4GkGN2uMJMyCqbhLG1xOeOxNBiWuVnbtRzxmjjt9JPfyi)04b8KZhqCCUHatH0QV4e7IbehNBiW4MOso7Ib0loC0jLw(SSGj7fbJKKoTPmhnX4O8eDKeGKcWKljXriniYFY4O8eDKeVmsOWQPEf7Ijjv5tdgsBpbkcfmzVyixRsLNaqUy8Yrj4TEg2q8srctxWsxkF2xUK400xYNVooJ)fkvmdrXCaUvYTjTVqjaRWbCaNBbYsKGdQaEAtzoAIXbfCucwFHsGEDUHat92emTMDXKKm1pMwGH8tJhWtoFaXX5gcmfsR(ItSlgqCCUHaJBIk5SlgqV4WrNuA5ZYcMSxemss60MYC0eJJYt0rsaskatUKehH0Gi)jJJYt0rs8YiHcRM6vSlMKuLpnyiT9eOiuWK9IHCTkvEYriniYFY4O8eDKeVmsOWQPEfBixRsvmYVKuLpnyiT9eOiuWK9IHCTkvYR8IN8qopHVCX4LJsWB9mSH4LIeMUGLUu(SVCjXPPVKpFDCg)luQygII5aCjxmKFAeoOeeGv4qLpnyiT9eOiuWK9IHCTkvEIh8KK86Cdbg2uUObSmTWgULfxGD1kByNM(sEca4jNKKZneyyt5IgWY0cB4wwCb2vRSHDA6l5Xbaap58b05gcm1BtW0A2fdOxocPbr(tg3evYzd5AvQ8aEYjjbo3cKLibhu5RJZ4FHsfZqumhGR6jT2grqBdbqoGCnjEBGrV6aEaSchgkmKsM5OjGF5sIhjalYd8GhqfgP1I3gy0RyQ3MqnKNYhqdtWLr8Ja96Cdbg3evYzd5AvQ8ap5KKWX5gcmUjQKZUy(64m(xOuXmefZb4gUdGcuqq6BsaSchiUUWueRsHLac0WeCze)iqNBiWWMYfnGLPf2WTS4cSRwzd700xYtaap5a6fe9md0W(6Kek)24kanxdgX(IFSsyss4WrNuA5ZsIpinAaLKuyKwlEBGrVYda4RJZ4FHsfZqumhGR6TjyAnaRWbNBiWqj9YucmA4e2xOKDXa615gcm1BtW0A2qHHuYmhnjjzQFmTad5NgpIv581Xz8VqPIzikMdWv92emTgGv4ahDsPLpllyYErWiGEpTPmhnX4O8eDKeGKcWKljXriniYFY4MOso7Ijj5Cdbg3evYzxmFa5iKge5pzCuEIosIxgjuy1uVInKRvPYtyCqMRH)4JtL2RP(X0cmKFAKx4jNpGo3qGPEBcMwZgY1Qu5P8behW5wGSej4GQooJ)fkvmdrXCaUQ3g1DGraSch4OtkT8zzbt2lcgb07PnL5OjghLNOJKaKuaMCjjocPbr(tg3evYzxmjjNBiW4MOso7I5dihH0Gi)jJJYt0rs8YiHcRM6vSHCTkvEk)aDUHat92emTMDXasCDHPiwLclbeioN2uMJMyfSenKq92OUdmcioGZTazjsWbvDCg)luQygII5aCvVnQ7aJayfo4CdbgkPxMsW1KnIZsvOKDXKK8IJ6TjudXmmbxgXpkj515gcmUjQKZgY1Qu5j8a6Cdbg3evYzxmjjVo3qGn2jLORsegkJhGSHCTkvEcJdYCn8hFCQ0En1pMwGH8tJ8cF58b05gcSXoPeDvIWqz8aKDX85d4PnL5OjM6TjyATWpkFrW0AbkeaQWiTw82aJEft92emT2t47dOxCMBsb0aJyF5s(rtkahYCDQeKggfB3cdJaLKuyKwlEBGrVIPEBcMw7j891Xz8VqPIzikMdWnj)cxekbyfo4L46ctrSkfwciqocPbr(tg3evYzd5AvQ8aEYjj5LlZgyK6aaaoexMnWiXxUKNWZNKexMnWi1b47dOHj4Yi(XooJ)fkvmdrXCaUYmDq4IqjaRWbVexxykIvPWsabYriniYFY4MOsoBixRsLhWtojjVCz2aJuhaaWH4YSbgj(YL8eE(KK4YSbgPoaFFanmbxgXp2Xz8VqPIzikMdWnC1AHlcLaSch8sCDHPiwLclbeihH0Gi)jJBIk5SHCTkvEap5KK8YLzdmsDaaahIlZgyK4lxYt45tsIlZgyK6a89b0WeCze)yhNX)cLkMHOyoax)2mfAeOGG03K64m(xOuXmefZb4EAtzoAcGP5shuVnHAirLcfsBdapn9LoOWiTw82aJEft92eQH8q(IjOrOXRRPEAauCA6lfF4jNCYlaKZxmbncnEDUHat92OUdmsqUyi)04s5luiTnm1B8JYR85RJZ4FHsfZqumhGR)XEzaSchiUUWuetFtBejH)xsI46ctrmlbuKe(FGN2uMJMyLsW1KDssso3qGrCDHPiHcPTHnKRvPYtJ)fkzQ3MqneJWpXVpj(YLa6CdbgX1fMIekK2g2ftsI46ctrSkfkK2gG4CAtzoAIPEBc1qIkfkK2gjjNBiW4MOsoBixRsLNg)luYuVnHAigHFIFFs8LlbeNtBkZrtSsj4AYojGo3qGXnrLC2qUwLkpj8t87tIVCjGo3qGXnrLC2ftsY5gcSXoPeDvIWqz8aKDXaQWiTwiZup5HCm5hOxfgP1I3gy0R88a8LKW5nnLptHUAbkiEzKiGgs9mknhnb6tscNtBkZrtSsj4AYojGo3qGXnrLC2qUwLkpi8t87tIVCPooJ)fkvmdrXCaUQ3MqnuhNX)cLkMHOyoa35McJ)fkf6s9amnx6qW06x2C7464m(xOuXCq2FyStkrxLimugpabyfo4Cdbg3evYzxSooJ)fkvmhK9XCaUN2uMJMayAU0b(uFI(lgapn9LoGJZneyoM2sojqbHP1IxwLWuI0(7qSlgqCCUHaZX0wYjbkimTw8YQeMsyd3sIDX64m(xOuXCq2hZb4AGg2xNKq53gxaYbKRjXBdm6vhWdGv4GZneyoM2sojqbHP1IxwLWuI0(7qm1B8JEkFaDUHaZX0wYjbkimTw8YQeMsyd3sIPEJF0t5dOxCarpZanSVojHYVnUcqZ1GrSV4hRegqCm(xOKzGg2xNKq53gxbO5AWiwLIGUGj7b6fhq0Zmqd7RtsO8BJRqgzA2x8Jvctsce9md0W(6Kek)24kKrMMnKRvPYd47tsce9md0W(6Kek)24kanxdgXuVXp6j8bcIEMbAyFDscLFBCfGMRbJyd5AvQ8eEabrpZanSVojHYVnUcqZ1GrSV4hReMVooJ)fkvmhK9XCaUCuEIosIxgjuy1uVcGv4G3tBkZrtmokprhjbiPam5aXHJqAqK)KXnrLC2qgiGsso3qGXnrLC2fZhqVo3qG5yAl5KafeMwlEzvctjs7VdXuVXpEaEsso3qG5yAl5KafeMwlEzvctjSHBjXuVXpEaE(KKcfmzVyixRsLN4jxhNX)cLkMdY(yoaxULCslCUHaatZLoOEB0ObeGv4GxNBiWCmTLCsGcctRfVSkHPeP93Hyd5AvQ8q(yWtsY5gcmhtBjNeOGW0AXlRsykHnClj2qUwLkpKpg88b0u)yAbgYpnECiwLdOxocPbr(tg3evYzd5AvQ8a3lj5LJqAqK)KrUyi)0iCqjiBixRsLh4EG44Cdb2XkbhcuqUyi)04s5lOKgyv8i2fdihDsPLp7iGtzPpFDCg)luQyoi7J5aCvVnbtRbyfo8MMYNPEsRTraov4zuAoAceOI(VsykMcPrcWPcpqNBiWuVnbtRzGi)zhNX)cLkMdY(yoax1BJ6oWiawHd4CAtzoAIXN6t0FXa6LJoP0YNLfmzViyKKehH0Gi)jJBIk5SHCTkvEG7LKW50MYC0eJdk4OeS(cLaXHJoP0YNDeWPSusYlhH0Gi)jJCXq(Pr4Gsq2qUwLkpW9aXX5gcSJvcoeOGCXq(PXLYxqjnWQ4rSlgqo6KslF2raNYsF(64m(xOuXCq2hZb4QEBu3bgbWkCWlhH0Gi)jJJYt0rs8YiHcRM6vSHCTkvEcpG4ao3cKLibhub07PnL5OjghLNOJKaKuaMCjjocPbr(tg3evYzd5AvQ8eE(8b0u)yAbgYpnEiFYbKJoP0YNLfmzViyeqCaNBbYsKGdQ64m(xOuXCq2hZb4EAtzoAcGP5sharVyOy7wd5s5Ra4PPV0bVo3qGXnrLC2qUwLkpGhqVo3qGn2jLORsegkJhGSHCTkvEapjjCCUHaBStkrxLimugpazxmFss44Cdbg3evYzxmjjt9JPfyi)04j8LZhqV44Cdb2XkbhcuqUyi)04s5lOKgyv8i2ftsYu)yAbgYpnEcF58b0RZneyexxyksOqAByd5AvQ8aghK5A4xsY5gcmIRlmfj030g2qUwLkpGXbzUg(91Xz8VqPI5GSpMdWvDZqnea5aY1K4Tbg9Qd4bWkCyOWqkzMJMa(2aJE2xUK4rcWI8ap5hOHj4Yi(rGN2uMJMyGOxmuSDRHCP8vDCg)luQyoi7J5aCDrOmudbqoGCnjEBGrV6aEaSchgkmKsM5OjGVnWON9LljEKaSipWd(m4b0WeCze)iWtBkZrtmq0lgk2U1qUu(QooJ)fkvmhK9XCaUQN0ABebTnea5aY1K4Tbg9Qd4bWkCyOWqkzMJMa(2aJE2xUK4rcWI8ap5pMHCTkvanmbxgXpc80MYC0ede9IHITBnKlLVQJZ4FHsfZbzFmhGBanCsGcI0(7qaSchmmbxgXp2Xz8VqPI5GSpMdWnChafOGG03Kayfo4L46ctrSkfwcOKeX1fMIykK2grLc8KKiUUWuetFtBevkWZhqV4WrNuA5ZYcMSxemsscCUfilrcoOssYRP(X0cmKFA8mwHhqVN2uMJMy8P(e9xmjjt9JPfyi)04j8Lts60MYC0eRucdr(a690MYC0eJJYt0rsaskatoqC4iKge5pzCuEIosIxgjuy1uVIDXKKW50MYC0eJJYt0rsaskatoqC4iKge5pzCtujNDX85ZhqVCesdI8NmUjQKZgY1Qu5b8LtscCUfilrcoOssYu)yAbgYpnEeRYbKJqAqK)KXnrLC2fdOxocPbr(tg5IH8tJWbLGSHCTkvEA8Vqjt92eQHye(j(9jXxUKKeoC0jLw(SJaoLL(KKQ8PbdPTNafHcMSxmKRvPYt8KZhqVGONzGg2xNKq53gxbO5AWi2qUwLkpKpjjC4OtkT8zjXhKgnG(64m(xOuXCq2hZb4sUyi)0iCqjiaRWbVexxykIPVPnIKW)ljrCDHPiMcPTrKe(FjjIRlmfXSeqrs4)LKCUHaZX0wYjbkimTw8YQeMsK2FhInKRvPYd5JbpjjNBiWCmTLCsGcctRfVSkHPe2WTKyd5AvQ8q(yWtsYu)yAbgYpnEeRYbKJqAqK)KXnrLC2qgiGaXbCUfilrcoOYhqVCesdI8NmUjQKZgY1Qu5b8LtsIJqAqK)KXnrLC2qgiG(KKQ8PbdPTNafHcMSxmKRvPYt8KRJZ4FHsfZbzFmhGlN0K6ltlmDblDP8byfoGd4ClqwIeCqfWtBkZrtmoOGJsW6luc0RP(X0cmKFA8iwLdOxNBiWowj4qGcYfd5NgxkFbL0aRIhXUyss4WrNuA5Zoc4uw6tsIJoP0YNLfmzViyKKKZneyoAecuFvp7Ib05gcmhncbQVQNnKRvPYtaixmE5Oe8wpdBiEPiHPlyPlLp7lxsCA6l5ZhqVN2uMJMyCuEIoscqsbyYLK4iKge5pzCuEIosIxgjuy1uVInKbcOpjPkFAWqA7jqrOGj7fd5AvQ8eaYfJxokbV1ZWgIxksy6cw6s5Z(YLeNM(s(64m(xOuXCq2hZb4wj3M0(cLaSchWbCUfilrcoOc4PnL5OjghuWrjy9fkb61u)yAbgYpnEeRYb0RZneyhReCiqb5IH8tJlLVGsAGvXJyxmjjC4OtkT8zhbCkl9jjXrNuA5ZYcMSxemssY5gcmhncbQVQNDXa6CdbMJgHa1x1ZgY1Qu5j8LlgVCucERNHneVuKW0fS0LYN9Lljon9L85dO3tBkZrtmokprhjbiPam5ssCesdI8NmokprhjXlJekSAQxXgYab0NKuLpnyiT9eOiuWK9IHCTkvEcF5IXlhLG36zydXlfjmDblDP8zF5sIttFjFDCg)luQyoi7J5aCpTPmhnbW0CPdMclwcnrehGNM(shiUUWueRsH(M2eFYd514FHsM6TjudXi8t87tIVCPyWH46ctrSkf6BAt8j)YRX)cLm)J9Yye(j(9jXxUumYXaG8QWiTwiZup1Xz8VqPI5GSpMdWv92OUdmcGv4G3kFAWqA7jqrOGj7fd5AvQ8u(KK86Cdb2yNuIUkryOmEaYgY1Qu5jmoiZ1WF8XPs71u)yAbgYpnYl8LZhqNBiWg7Ks0vjcdLXdq2fZNpjjVM6htlWq(PjMtBkZrtmtHflHMiIhFo3qGrCDHPiHcPTHnKRvPkgq0Zc3bqbkii9nj2x8JkXqUwLXhayWZd8aGCssM6htlWq(PjMtBkZrtmtHflHMiIhFo3qGrCDHPiH(M2WgY1Qufdi6zH7aOafeK(Me7l(rLyixRY4dam45bEaqoFajUUWueRsHLac0RxC4iKge5pzCtujNDXKK4OtkT8zhbCklbIdhH0Gi)jJCXq(Pr4Gsq2fZNKehDsPLpllyYErWiFa9IdhDsPLp7KYxgGJKeoo3qGXnrLC2ftsYu)yAbgYpnEeRY5tsY5gcmUjQKZgY1Qu5H8aioo3qGn2jLORsegkJhGSlwhNX)cLkMdY(yoa3K8lCrOeGv4GxNBiWiUUWuKqFtByxmjjVCz2aJuhaaWH4YSbgj(YL8eE(KK4YSbgPoaFFanmbxgXp2Xz8VqPI5GSpMdWvMPdcxekbyfo415gcmIRlmfj030g2ftsYlxMnWi1baaCiUmBGrIVCjpHNpjjUmBGrQdW3hqdtWLr8JDCg)luQyoi7J5aCdxTw4IqjaRWbVo3qGrCDHPiH(M2WUyssE5YSbgPoaaGdXLzdms8Ll5j88jjXLzdmsDa((aAycUmIFSJZ4FHsfZbzFmhGRFBMcncuqq6BsDCg)luQyoi7J5aCvVnHAiawHdexxykIvPqFtBKKiUUWuetH02isc)VKeX1fMIywcOij8)sso3qG53MPqJafeK(Me7Ib05gcmIRlmfj030g2ftsYRZneyCtujNnKRvPYtJ)fkz(h7LXi8t87tIVCjGo3qGXnrLC2fZxhNX)cLkMdY(yoax)J9Y64m(xOuXCq2hZb4o3uy8VqPqxQhGP5shcMw)YMBhxhNX)cLkg4qMRtLG0C40MYC0eatZLoOSajEK4QiHcJ0AaEA6lDWRZneyF5s(rtkahYCDQeKg2qUwLkpGXbzUg(JrogEa9sCDHPiwLch0ltsI46ctrSkfkK2gjjIRlmfX030grs4)9jj5Cdb2xUKF0KcWHmxNkbPHnKRvPYdJ)fkzQ3MqneJWpXVpj(YLIrogEa9sCDHPiwLc9nTrsI46ctrmfsBJij8)ssexxykIzjGIKW)7ZNKeoo3qG9Ll5hnPaCiZ1PsqAyxSooJ)fkvmWHmxNkbPjMdWv92emTgGv4WBAkFM6jT2gb4uHNrP5OjqGk6)kHPykKgjaNk8aDUHat92emTMbI8NDCg)luQyGdzUovcstmhGR6TrDhyeaRWbV4CAtzoAIPSajEK4QiHcJ0AjjVo3qGn2jLORsegkJhGSHCTkvEcJdYCn8hFCQ0En1pMwGH8tJ8cF58b05gcSXoPeDvIWqz8aKDX85tsYu)yAbgYpnEeRY1Xz8VqPIboK56ujinXCaUCuEIosIxgjuy1uVcGv4G3tBkZrtmokprhjbiPam5aR8PbdPTNafHcMSxmKRvPYd8GVCaXHJqAqK)KXnrLC2qgiGsso3qGXnrLC2fZhqt9JPfyi)04P8jhqVo3qGrCDHPiH(M2WgY1Qu5bEYjj5CdbgX1fMIekK2g2qUwLkpWtoFssHcMSxmKRvPYt8KRJZ4FHsfdCiZ1PsqAI5aCnqd7RtsO8BJla5aY1K4Tbg9Qd4bWkCahq0Zmqd7RtsO8BJRa0Cnye7l(XkHbehJ)fkzgOH91jju(TXvaAUgmIvPiOlyYEGEXbe9md0W(6Kek)24kKrMM9f)yLWKKarpZanSVojHYVnUczKPzd5AvQ8aE(KKarpZanSVojHYVnUcqZ1Grm1B8JEcFGGONzGg2xNKq53gxbO5AWi2qUwLkpHpqq0Zmqd7RtsO8BJRa0Cnye7l(XkH1Xz8VqPIboK56ujinXCaUUiugQHaihqUMeVnWOxDapawHddfgsjZC0eW3gy0Z(YLepsawKh4baGE96Cdbg3evYzd5AvQ8aEa96Cdb2yNuIUkryOmEaYgY1Qu5b8KKWX5gcSXoPeDvIWqz8aKDX8jjHJZneyCtujNDXKKm1pMwGH8tJNWxoFa9IJZneyhReCiqb5IH8tJlLVGsAGvXJyxmjjt9JPfyi)04j8LZhqdtWLr8J(64m(xOuXahYCDQeKMyoax1nd1qaKdixtI3gy0RoGhaRWHHcdPKzoAc4Bdm6zF5sIhjalYd8aaqVEDUHaJBIk5SHCTkvEapGEDUHaBStkrxLimugpazd5AvQ8aEss44Cdb2yNuIUkryOmEaYUy(KKWX5gcmUjQKZUyssM6htlWq(PXt4lNpGEXX5gcSJvcoeOGCXq(PXLYxqjnWQ4rSlMKKP(X0cmKFA8e(Y5dOHj4Yi(rFDCg)luQyGdzUovcstmhGR6jT2grqBdbqoGCnjEBGrV6aEaSchgkmKsM5OjGVnWON9LljEKaSipWt(b61RZneyCtujNnKRvPYd4b0RZneyJDsj6QeHHY4biBixRsLhWtschNBiWg7Ks0vjcdLXdq2fZNKeoo3qGXnrLC2ftsYu)yAbgYpnEcF58b0loo3qGDSsWHafKlgYpnUu(ckPbwfpIDXKKm1pMwGH8tJNWxoFanmbxgXp6RJZ4FHsfdCiZ1PsqAI5aCdOHtcuqK2FhcGv4GHj4Yi(XooJ)fkvmWHmxNkbPjMdWDStkrxLimugpabyfo4Cdbg3evYzxSooJ)fkvmWHmxNkbPjMdWLCXq(Pr4GsqawHdE96CdbgX1fMIekK2g2qUwLkpWtojjNBiWiUUWuKqFtByd5AvQ8ap58bKJqAqK)KXnrLC2qUwLkpGVC(KK4iKge5pzCtujNnKbcyhNX)cLkg4qMRtLG0eZb4YjnP(Y0ctxWsxkFawHd4ao3cKLibhub80MYC0eJdk4OeS(cLa9615gcSJvcoeOGCXq(PXLYxqjnWQ4rSlMKeoC0jLw(SJaoLL(KK4OtkT8zzbt2lcgjjDAtzoAIvkHHijjNBiWC0ieO(QE2fdOZneyoAecuFvpBixRsLNaqUy8Yrj4TEg2q8srctxWsxkF2xUK400xYNpG44Cdbg3evYzxmGEXHJoP0YNLfmzViyKKehH0Gi)jJJYt0rs8YiHcRM6vSlMKuLpnyiT9eOiuWK9IHCTkvEYriniYFY4O8eDKeVmsOWQPEfBixRsvmYVKuLpnyiT9eOiuWK9IHCTkvYR8IN8qopbGCX4LJsWB9mSH4LIeMUGLUu(SVCjXPPVKpFDCg)luQyGdzUovcstmhGBLCBs7lucWkCahW5wGSej4GkGN2uMJMyCqbhLG1xOeOxVo3qGDSsWHafKlgYpnUu(ckPbwfpIDXKKWHJoP0YNDeWPS0NKehDsPLpllyYErWijPtBkZrtSsjmejj5CdbMJgHa1x1ZUyaDUHaZrJqG6R6zd5AvQ8e(YfJxokbV1ZWgIxksy6cw6s5Z(YLeNM(s(8behNBiW4MOso7Ib0loC0jLw(SSGj7fbJKK4iKge5pzCuEIosIxgjuy1uVIDXKKQ8PbdPTNafHcMSxmKRvPYtocPbr(tghLNOJK4Lrcfwn1Ryd5AvQIr(LKQ8PbdPTNafHcMSxmKRvPsELx8KhY5j8LlgVCucERNHneVuKW0fS0LYN9Lljon9L85RJZ4FHsfdCiZ1PsqAI5aCpTPmhnbW0CPdk7Keb0i4MOsoapn9LoGdhH0Gi)jJBIk5SHmqaLKW50MYC0eJJYt0rsaskatoqo6KslFwwWK9IGrssGZTazjsWbvDCg)luQyGdzUovcstmhGB4oakqbbPVjbWkCG46ctrSkfwciqdtWLr8Ja9cIEMbAyFDscLFBCfGMRbJyFXpwjmjjC4OtkT8zjXhKgnG(aEAtzoAIPStseqJGBIk5DCg)luQyGdzUovcstmhGR6TrDhyeaRWbo6KslFwwWK9IGrapTPmhnX4O8eDKeGKcWKd0u)yAbgYpnECq(KdihH0Gi)jJJYt0rs8YiHcRM6vSHCTkvEcJdYCn8hFCQ0En1pMwGH8tJ8cF58behW5wGSej4GQooJ)fkvmWHmxNkbPjMdWnj)cxekbyfo415gcmIRlmfj030g2ftsYlxMnWi1baaCiUmBGrIVCjpHNpjjUmBGrQdW3hqdtWLr8JapTPmhnXu2jjcOrWnrL8ooJ)fkvmWHmxNkbPjMdWvMPdcxekbyfo415gcmIRlmfj030g2fdioC0jLw(SJaoLLssEDUHa7yLGdbkixmKFACP8fusdSkEe7IbKJoP0YNDeWPS0NKKxUmBGrQdaa4qCz2aJeF5sEcpFssCz2aJuhGVKKZneyCtujNDX8b0WeCze)iWtBkZrtmLDsIaAeCtujVJZ4FHsfdCiZ1PsqAI5aCdxTw4IqjaRWbVo3qGrCDHPiH(M2WUyaXHJoP0YNDeWPSusYRZneyhReCiqb5IH8tJlLVGsAGvXJyxmGC0jLw(SJaoLL(KK8YLzdmsDaaahIlZgyK4lxYt45tsIlZgyK6a8LKCUHaJBIk5SlMpGgMGlJ4hbEAtzoAIPStseqJGBIk5DCg)luQyGdzUovcstmhGRFBMcncuqq6BsDCg)luQyGdzUovcstmhGR6TjudbWkCG46ctrSkf6BAJKeX1fMIykK2grs4)LKiUUWueZsafjH)xsY5gcm)2mfAeOGG03KyxmGo3qGrCDHPiH(M2WUyssEDUHaJBIk5SHCTkvEA8VqjZ)yVmgHFIFFs8Llb05gcmUjQKZUy(64m(xOuXahYCDQeKMyoax)J9Y64m(xOuXahYCDQeKMyoa35McJ)fkf6s9amnx6qW06x2C7464m(xOuXcMw)YM7b1BJ6oWiawHd4m3KcObgXCmTLCsGcctRfVSkHPyuSDlmmcSJZ4FHsflyA9lBUXCaUQBgQHaihqUMeVnWOxDapawHdGON5IqzOgInKRvPYJHCTkvDCg)luQybtRFzZnMdW1fHYqnuhxhNX)cLkM6pyGg2xNKq53gxaYbKRjXBdm6vhWdGv4aoGONzGg2xNKq53gxbO5AWi2x8Jvcdiog)luYmqd7RtsO8BJRa0CnyeRsrqxWK9a9Idi6zgOH91jju(TXviJmn7l(XkHjjbIEMbAyFDscLFBCfYitZgY1Qu5b88jjbIEMbAyFDscLFBCfGMRbJyQ34h9e(abrpZanSVojHYVnUcqZ1GrSHCTkvEcFGGONzGg2xNKq53gxbO5AWi2x8JvcRJZ4FHsft9XCaUCuEIosIxgjuy1uVcGv4G3tBkZrtmokprhjbiPam5aXHJqAqK)KXnrLC2qgiGsso3qGXnrLC2fZhqt9JPfyi)04P8jhqVo3qGrCDHPiH(M2WgY1Qu5bEYjj5CdbgX1fMIekK2g2qUwLkpWtoFssHcMSxmKRvPYt8KRJZ4FHsft9XCaUN2uMJMayAU0bq0lgk2U1qUu(kaEA6lDWRZneyCtujNnKRvPYd4b0RZneyJDsj6QeHHY4biBixRsLhWtschNBiWg7Ks0vjcdLXdq2fZNKeoo3qGXnrLC2ftsYu)yAbgYpnEcF58b0loo3qGDSsWHafKlgYpnUu(ckPbwfpIDXKKm1pMwGH8tJNWxoFa96CdbgX1fMIekK2g2qUwLkpGXbzUg(LKCUHaJ46ctrc9nTHnKRvPYdyCqMRHFFDCg)luQyQpMdW1fHYqnea5aY1K4Tbg9Qd4bWkCyOWqkzMJMa(2aJE2xUK4rcWI8apaa0RHj4Yi(rGN2uMJMyGOxmuSDRHCP8v(64m(xOuXuFmhGR6MHAiaYbKRjXBdm6vhWdGv4WqHHuYmhnb8Tbg9SVCjXJeGf5bEaaOxdtWLr8JapTPmhnXarVyOy7wd5s5R81Xz8VqPIP(yoax1tATnIG2gcGCa5As82aJE1b8ayfomuyiLmZrtaFBGrp7lxs8ibyrEGN8d0RHj4Yi(rGN2uMJMyGOxmuSDRHCP8v(64m(xOuXuFmhGBanCsGcI0(7qaSchmmbxgXp2Xz8VqPIP(yoa3XoPeDvIWqz8aeGv4GZneyCtujNDX64m(xOuXuFmhGl5IH8tJWbLGaSch8615gcmIRlmfjuiTnSHCTkvEGNCsso3qGrCDHPiH(M2WgY1Qu5bEY5dihH0Gi)jJBIk5SHCTkvEaF5a615gcmSPCrdyzAHnCllUa7Qv2Won9L8eaYNCss4m3KcObgXWMYfnGLPf2WTS4cSRwzdJITBHHrG(8jj5Cdbg2uUObSmTWgULfxGD1kByNM(sECaa4E5KK4iKge5pzCtujNnKbciqVM6htlWq(PXJyvojPtBkZrtSsjme5RJZ4FHsft9XCaUCstQVmTW0fS0LYhGv4aoGZTazjsWbvapTPmhnX4GcokbRVqjqVM6htlWq(PXJyvoGEDUHa7yLGdbkixmKFACP8fusdSkEe7IjjHdhDsPLp7iGtzPpjjo6KslFwwWK9IGrssN2uMJMyLsyissY5gcmhncbQVQNDXa6CdbMJgHa1x1ZgY1Qu5jaKlgVEJ14BUjfqdmIHnLlAaltlSHBzXfyxTYggfB3cdJa9fJxokbV1ZWgIxksy6cw6s5Z(YLeNM(s(85dioo3qGXnrLC2fdOxC4OtkT8zzbt2lcgjjXriniYFY4O8eDKeVmsOWQPEf7Ijjv5tdgsBpbkcfmzVyixRsLNCesdI8NmokprhjXlJekSAQxXgY1QufJ8ljv5tdgsBpbkcfmzVyixRsL8kV4jpKZtaixmE5Oe8wpdBiEPiHPlyPlLp7lxsCA6l5ZxhNX)cLkM6J5aCRKBtAFHsawHd4ao3cKLibhub80MYC0eJdk4OeS(cLa9AQFmTad5NgpIv5a615gcSJvcoeOGCXq(PXLYxqjnWQ4rSlMKeoC0jLw(SJaoLL(KK4OtkT8zzbt2lcgjjDAtzoAIvkHHijjNBiWC0ieO(QE2fdOZneyoAecuFvpBixRsLNWxUy86nwJV5MuanWig2uUObSmTWgULfxGD1kByuSDlmmc0xmE5Oe8wpdBiEPiHPlyPlLp7lxsCA6l5ZNpG44Cdbg3evYzxmGEXHJoP0YNLfmzViyKKehH0Gi)jJJYt0rs8YiHcRM6vSlMKuLpnyiT9eOiuWK9IHCTkvEYriniYFY4O8eDKeVmsOWQPEfBixRsvmYVKuLpnyiT9eOiuWK9IHCTkvYR8IN8qopHVCX4LJsWB9mSH4LIeMUGLUu(SVCjXPPVKpFDCg)luQyQpMdW90MYC0eatZLoOStseqJGBIk5a800x6aoCesdI8NmUjQKZgYabuscNtBkZrtmokprhjbiPam5a5OtkT8zzbt2lcgjjbo3cKLibhu1Xz8VqPIP(yoa3WDauGccsFtcGv4aX1fMIyvkSeqGgMGlJ4hb6Cdbg2uUObSmTWgULfxGD1kByNM(sEca5toGEbrpZanSVojHYVnUcqZ1GrSV4hReMKeoC0jLw(SK4dsJgqFapTPmhnXu2jjcOrWnrL8ooJ)fkvm1hZb4QEBcMwdWkCW5gcmusVmLaJgoH9fkzxmGo3qGPEBcMwZgkmKsM5OPooJ)fkvm1hZb4YTKtAHZneayAU0b1BJgnGaSchCUHat92OrdiBixRsLNWdOxNBiWiUUWuKqH02WgY1Qu5b8KKCUHaJ46ctrc9nTHnKRvPYd45dOP(X0cmKFA8iwLRJZ4FHsft9XCaUQ3MGP1aSchEtt5ZupP12iaNk8mknhnbcur)xjmftH0ib4uHhOZneyQ3MGP1mqK)SJZ4FHsft9XCaUQ3g1DGraSch4OtkT8zzbt2lcgb80MYC0eJJYt0rsaskatoqocPbr(tghLNOJK4Lrcfwn1Ryd5AvQ8eEaXbCUfilrcoOQJZ4FHsft9XCaUQ3MGP1aSchEtt5ZupP12iaNk8mknhnbceN30u(m1BJgnGmknhnbc05gcm1BtW0A2qHHuYmhnb0RZneyexxyksOVPnSHCTkvEi)ajUUWueRsH(M2a05gcmSPCrdyzAHnCllUa7Qv2Won9L8eaWtojjNBiWWMYfnGLPf2WTS4cSRwzd700xYJdaaEYb0u)yAbgYpnEeRYjjbIEMbAyFDscLFBCfGMRbJyd5AvQ8qEijz8VqjZanSVojHYVnUcqZ1GrSkfbDbt27dioCesdI8NmUjQKZgYabSJZ4FHsft9XCaUQ3g1DGraSchCUHadL0ltj4AYgXzPkuYUysso3qGDSsWHafKlgYpnUu(ckPbwfpIDXKKCUHaJBIk5SlgqVo3qGn2jLORsegkJhGSHCTkvEcJdYCn8hFCQ0En1pMwGH8tJ8cF58b05gcSXoPeDvIWqz8aKDXKKWX5gcSXoPeDvIWqz8aKDXaIdhH0Gi)jBStkrxLimugpazdzGakjHdhDsPLp7KYxgGJpjjt9JPfyi)04rSkhqIRlmfXQuyjGDCg)luQyQpMdWv92OUdmcGv4WBAkFM6TrJgqgLMJMab615gcm1BJgnGSlMKKP(X0cmKFA8iwLZhqNBiWuVnA0aYuVXp6j8b615gcmIRlmfjuiTnSlMKKZneyexxyksOVPnSlMpGo3qGHnLlAaltlSHBzXfyxTYg2PPVKNaa3lhqVCesdI8NmUjQKZgY1Qu5bEYjjHZPnL5OjghLNOJKaKuaMCGC0jLw(SSGj7fbJ81Xz8VqPIP(yoax1BJ6oWiawHdEDUHadBkx0awMwyd3YIlWUALnSttFjpbaUxojjNBiWWMYfnGLPf2WTS4cSRwzd700xYtaap5a(MMYNPEsRTraov4zuAoAc0hqNBiWiUUWuKqH02WgY1Qu5bUhiX1fMIyvkuiTnaXX5gcmusVmLaJgoH9fkzxmG48MMYNPEB0ObKrP5OjqGCesdI8NmUjQKZgY1Qu5bUhOxocPbr(tg5IH8tJWbLGSHCTkvEG7LKWHJoP0YNDeWPS0xhNX)cLkM6J5aCtYVWfHsawHdEDUHaJ46ctrc9nTHDXKK8YLzdmsDaaahIlZgyK4lxYt45tsIlZgyK6a89b0WeCze)iWtBkZrtmLDsIaAeCtujVJZ4FHsft9XCaUYmDq4IqjaRWbVo3qGrCDHPiH(M2WUyaXHJoP0YNDeWPSusYRZneyhReCiqb5IH8tJlLVGsAGvXJyxmGC0jLw(SJaoLL(KK8YLzdmsDaaahIlZgyK4lxYt45tsIlZgyK6a8LKCUHaJBIk5SlMpGgMGlJ4hbEAtzoAIPStseqJGBIk5DCg)luQyQpMdWnC1AHlcLaSch86CdbgX1fMIe6BAd7Ibeho6KslF2raNYsjjVo3qGDSsWHafKlgYpnUu(ckPbwfpIDXaYrNuA5Zoc4uw6tsYlxMnWi1baaCiUmBGrIVCjpHNpjjUmBGrQdWxsY5gcmUjQKZUy(aAycUmIFe4PnL5OjMYojrancUjQK3Xz8VqPIP(yoax)2mfAeOGG03K64m(xOuXuFmhGR6TjudbWkCG46ctrSkf6BAJKeX1fMIykK2grs4)LKiUUWueZsafjH)xsY5gcm)2mfAeOGG03KyxmGo3qGrCDHPiH(M2WUyssEDUHaJBIk5SHCTkvEA8VqjZ)yVmgHFIFFs8Llb05gcmUjQKZUy(64m(xOuXuFmhGR)XEzDCg)luQyQpMdWDUPW4FHsHUupatZLoemT(LnxOifgXHGdEYbaOh6HGa]] )


end