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


    spec:RegisterPack( "Balance", 20210117, [[dO02PdqiOWJGssUervzta8jOKQrrv6uuvwLkO8kHIzbiDlOuLDHYVavAyevogu0YaepdkX0GsLRbQY2iQQ(MkOACqjLZjukRtOeMhvr3tOAFufoiuQQwiukpuOunrHsu5IcLO4JcLiDsOuvALQaZekjUPqjkTtqf)uOevnuHselfkjLNkKPcQQVcLQIXcLKQ9cYFjmyLomLftfpgvtgOlJSzbFgugnr50sETk0Sj1TPs7w0VHmCO64cL0Yv8CsMUQUUkTDv03PQA8ev58aQ1RcY8jY(LAimHGpueO9eeCaICabt5WeZdNHPCyIDy3Hdf9aJtqr4g)ObJGIsZLGIWMPTKtqr4gWAKbcbFOif6oCcks2)4QybCHlS6LDDyCKlCvL7vBFHs(yHhUQYLdxOiNBPFSVjKdueO9eeCaICabt5WeZdNHPCyIDabkYUVm0affvUXouKSceKsihOiqsXHIWQ6fBM2so1BSCZTa7dWQ69alV2aCVyE4aTxGihqWSpOpaRQ3yxMLWivSOpaRQxSxVy)GGeyVriTn9InYCz9byv9I96n2LzjmcS33gy0lQqVCtrQEFuVCG5As82aJEfRpaRQxSxVy1ix0jb27ntItkLna37PnL5OjvVElgXaAV4dDkuVnQ7aJ6f75rV4dDYuVnQ7aJ8X6dWQ6f71l2)jQa7fFiUP(kH1l2NXEz9wHERhRR69Lr96FqjSEJLHRlCfX6dWQ6f71BSS2rQ3yhLNOJuVVmQ3i8AQx1R1RU(xt96IgQ3GMKx5OPE9wHEbgD7vMbMy9Vxz13B99Qk3R(TKqxLg4E9xVSEXwS8y)WV3y6n2jnP(Y09I9RlyPlLpq7TESoyVQJfUpguKUuVcc(qr4dXrUo2dbFi4Gje8HIm(xOek6yLGdbku41uVckIsZrtGqyd6HGdqGGpuKX)cLqrUiuESsranUqruAoAcecBqpeCWce8HIO0C0eie2GIm(xOekY)yVmOi(upnLbf5TxIRlCfX030grsY77vsQxIRlCfXQuOVPn9kj1lX1fUIyvkCqVSELK6L46cxrmlbwKK8(E9bfPRKeCqOimLd6HGd2bbFOiknhnbcHnOi(upnLbf5TxIRlCfX030grsY77vsQxIRlCfXQuOVPn9kj1lX1fUIyvkCqVSELK6L46cxrmlbwKK8(E91lGEXh6KHjZ)yVSEb0lg9Ip0jdim)J9YGIm(xOekY)yVmOhcoWdc(qruAoAcecBqr8PEAkdkcJENBsb0aJyoM2sojqbHP1IxwLWumknhnb2RKuVy0lhDsPLpllyYErWOELK6fJEv4KwlEBGrVIPEBcMw3B8EXSxjPEXO330u(S0(7qkHJPTKtmknhnbcfz8VqjuK6Tjudb9qWr(HGpueLMJMaHWgueFQNMYGIMBsb0aJyoM2sojqbHP1IxwLWumknhnb2lGE5OtkT8zzbt2lcg1lGEv4KwlEBGrVIPEBcMw3B8EXekY4FHsOi1BJ6oWiOh6HIaPGD1pe8HGdMqWhkY4FHsOifsBJWHmxOiknhnbcHnOhcoabc(qruAoAcecBqriCOif9qrg)lucfDAtzoAck600xcksHtAT4Tbg9kM6TjyADVE0lM9cOxV9IrVVPP8zQ3gnAazuAoAcSxjPEFtt5ZupP12iaNk8mknhnb2RVELK6vHtAT4Tbg9kM6TjyADVE0lqGIoTrKMlbfvkHHiOhcoybc(qruAoAcecBqriCOif9qrg)lucfDAtzoAck600xcksHtAT4Tbg9kM6Tjud1Rh9Iju0PnI0CjOOsj4AYojOhcoyhe8HIO0C0eie2GI4t90uguK3EXOxo6KslFwwWK9IGr9kj1lg9YriniYFY4O8eDKeVmsOWRPEf7I3RVEb0RZneyCtujNDXHIm(xOekYHgfnhReg0dbh4bbFOiknhnbcHnOi(upnLbf5Cdbg3evYzxCOiJ)fkHIWrFHsOhcoYpe8HIO0C0eie2GIq4qrk6HIm(xOek60MYC0eu0PPVeueNkDVE71BVv(0GJ02tGIqbt2lgY1Qu1l2RxmHxVyVE5iKge5pzCtujNnKRvPQxF9c3EXeRjxV(6nEVCQ096TxV9w5tdosBpbkcfmzVyixRsvVyVEXeE9I96ftGixVyVE5iKge5pzCuEIosIxgju41uVInKRvPQxF9c3EXeRjxV(6vsQxocPbr(tg3evYzd5AvQ61JER8PbhPTNafHcMSxmKRvPQxjPE5iKge5pzCuEIosIxgju41uVInKRvPQxp6TYNgCK2EcuekyYEXqUwLQELK6fJE5OtkT8zzbt2lcgbfDAJinxckIJYt0rsaskGto0dbNdhc(qruAoAcecBqriCOif9qrg)lucfDAtzoAck600xckYBVy0lfR3chNazKloWdzAbAatl5uVss9YriniYFYixCGhY0c0aMwYj2qUwLQE9SxmLF56fqVy0lhH0Gi)jJCXbEitlqdyAjNydzGa3RVELK6LJoP0YNDe4PSek60grAUeuehuWrjy9fkHEi4G1GGpueLMJMaHWguKX)cLqrKloWdzAbAatl5eueFQNMYGI4iKge5pzCtujNnKRvPQxp7fiY1lGE5iKge5pzCuEIosIxgju41uVInKRvPQxp7fiY1RKuVHcMSxmKRvPQxp7flhouuAUeue5Id8qMwGgW0sob9qWj2GGpueLMJMaHWguKX)cLqrk0vRP)ReMyUoadfXN6PPmOiocPbr(tg3evYzd5AvQ61ZEL)Eb0lg9EAtzoAIXr5j6ijajfWjVxjPE5iKge5pzCuEIosIxgju41uVInKRvPQxp7v(7fqVN2uMJMyCuEIoscqsbCY7vsQ3qbt2lgY1Qu1RN9ce4bfLMlbfPqxTM(VsyI56am0dbhmLdc(qruAoAcecBqrg)lucfvPIp33C0KiwVw(xxbiDwCckIp1ttzqro3qGXnrLC2fhkknxckQsfFUV5OjrSET8VUcq6S4e0dbhmXec(qruAoAcecBqr8PEAkdkY5gcmUjQKZU49kj1lhDsPLpllyYErWOEb07PnL5OjghLNOJKaKuaN8Eb0lhH0Gi)jJJYt0rs8YiHcVM6vSlEVa6fJE5iKge5pzCtujNDX7fqVE71BVo3qGrCDHRiH(M2WgY1Qu1Rh9IPC9kj1RZneyexx4ksOqAByd5AvQ61JEXuUE91lGEXO35MuanWiMJPTKtcuqyAT4LvjmfJsZrtG9kj17CtkGgyeZX0wYjbkimTw8YQeMIrP5OjWEb0R3EDUHaZX0wYjbkimTw8YQeMsK2FhIPEJFSxp6fl9kj1RZneyoM2sojqbHP1IxwLWucB4wsm1B8J96rVyPxF96RxjPEDUHa7yLGdbkixCKFACP8fusdS6qe7I3RKuVHcMSxmKRvPQxp7fiYbfz8Vqju0vrI6jxf0dbhmbce8HIO0C0eie2GI4t90ugu0PnL5OjwPegIGIu)u8hcoycfz8Vqju0CtHX)cLcDPEOiDPErAUeuKHiOhcoyIfi4dfrP5OjqiSbfXN6PPmOO5MuanWi2xUKF0KcWHmxNkbPHrX6TWXjqOi1pf)HGdMqrg)lucfn3uy8VqPqxQhksxQxKMlbfboK56ujinqpeCWe7GGpueLMJMaHWgueFQNMYGIMBsb0aJyoM2sojqbHP1IxwLWumkwVfoobcfP(P4peCWekY4FHsOO5McJ)fkf6s9qr6s9I0CjOihK9qpeCWeEqWhkIsZrtGqydkY4FHsOO5McJ)fkf6s9qr6s9I0CjOi1d9qpue4qMRtLG0abFi4Gje8HIO0C0eie2GIq4qrk6HIm(xOek60MYC0eu0PPVeuK3EDUHa7lxYpAsb4qMRtLG0WgY1Qu1Rh9cJdYCn51Bm9khdZEb0R3EjUUWveRsHd6L1RKuVexx4kIvPqH020RKuVexx4kIPVPnIKK33RVELK615gcSVCj)OjfGdzUovcsdBixRsvVE0RX)cLm1BtOgIrYJ43NeF5s9gtVYXWSxa96TxIRlCfXQuOVPn9kj1lX1fUIykK2grsY77vsQxIRlCfXSeyrsY771xV(6vsQxm615gcSVCj)OjfGdzUovcsd7IdfDAJinxckszbs8iXvrcfoP1qpeCace8HIO0C0eie2GI4t90ugu0BAkFM6jT2gb4uHNrP5OjWEb0RI(VsykMcPrcWPcFVa615gcm1BtW0AgiYFcfz8VqjuK6TjyAn0dbhSabFOiknhnbcHnOi(upnLbf5Txm690MYC0etzbs8iXvrcfoP19kj1R3EDUHaBStkrxLimuEiGzd5AvQ61ZEHXbzUM869W6LtLUxV9AQFmTah5NMEHBVyrUE91lGEDUHaBStkrxLimuEiGzx8E91RVELK61u)yAboYpn96rVXMCqrg)lucfPEBu3bgb9qWb7GGpueLMJMaHWgueFQNMYGI827PnL5OjghLNOJKaKuaN8Eb0BLpn4iT9eOiuWK9IHCTkv96rVyIf56fqVy0lhH0Gi)jJBIk5SHmqG7vsQxNBiW4MOso7I3RVEb0RP(X0cCKFA61ZEXo56fqVE715gcmIRlCfj030g2qUwLQE9OxmLRxjPEDUHaJ46cxrcfsBdBixRsvVE0lMY1RVELK6nuWK9IHCTkv96zVykhuKX)cLqrCuEIosIxgju41uVc6HGd8GGpueLMJMaHWguKX)cLqrgOH)1jju(TXfkIp1ttzqry0li6zgOH)1jju(TXvaAUgmI9f)yLW6fqVy0RX)cLmd0W)6Kek)24kanxdgXQue0fmzFVa61BVy0li6zgOH)1jju(TXviJmn7l(XkH1RKuVGONzGg(xNKq53gxHmY0SHCTkv96rVWRxF9kj1li6zgOH)1jju(TXvaAUgmIPEJFSxp7fl9cOxq0Zmqd)RtsO8BJRa0CnyeBixRsvVE2lw6fqVGONzGg(xNKq53gxbO5AWi2x8JvcdkIdmxtI3gy0RGGdMqpeCKFi4dfrP5OjqiSbfz8VqjuKlcLHAiOi(upnLbfnuyiLmZrt9cO33gy0Z(YLepsawuVE0lMaPxa96TxV96Cdbg3evYzd5AvQ61JEHxVa61BVo3qGn2jLORsegkpeWSHCTkv96rVWRxjPEXOxNBiWg7Ks0vjcdLhcy2fVxF9kj1lg96Cdbg3evYzx8ELK61u)yAboYpn96zVyrUE91lGE92lg96Cdb2XkbhcuqU4i)04s5lOKgy1Hi2fVxjPEn1pMwGJ8ttVE2lwKRxF9cOxdxWLr8J96dkIdmxtI3gy0RGGdMqpeCoCi4dfrP5OjqiSbfz8VqjuK6MHAiOi(upnLbfnuyiLmZrt9cO33gy0Z(YLepsawuVE0lMaPxa96TxV96Cdbg3evYzd5AvQ61JEHxVa61BVo3qGn2jLORsegkpeWSHCTkv96rVWRxjPEXOxNBiWg7Ks0vjcdLhcy2fVxF9kj1lg96Cdbg3evYzx8ELK61u)yAboYpn96zVyrUE91lGE92lg96Cdb2XkbhcuqU4i)04s5lOKgy1Hi2fVxjPEn1pMwGJ8ttVE2lwKRxF9cOxdxWLr8J96dkIdmxtI3gy0RGGdMqpeCWAqWhkIsZrtGqydkY4FHsOi1tATnIG2gckIp1ttzqrdfgsjZC0uVa69Tbg9SVCjXJeGf1Rh9IP83lGE92R3EDUHaJBIk5SHCTkv96rVWRxa96TxNBiWg7Ks0vjcdLhcy2qUwLQE9Ox41RKuVy0RZneyJDsj6QeHHYdbm7I3RVELK6fJEDUHaJBIk5SlEVss9AQFmTah5NME9SxSixV(6fqVE7fJEDUHa7yLGdbkixCKFACP8fusdS6qe7I3RKuVM6htlWr(PPxp7flY1RVEb0RHl4Yi(XE9bfXbMRjXBdm6vqWbtOhcoXge8HIO0C0eie2GI4t90uguKHl4Yi(rOiJ)fkHIcOHtcuqK2Fhc6HGdMYbbFOiknhnbcHnOi(upnLbf5Cdbg3evYzxCOiJ)fkHIg7Ks0vjcdLhcyOhcoyIje8HIO0C0eie2GI4t90uguK3E92RZneyexx4ksOqAByd5AvQ61JEXuUELK615gcmIRlCfj030g2qUwLQE9OxmLRxF9cOxocPbr(tg3evYzd5AvQ61JEXIC96RxjPE5iKge5pzCtujNnKbcmuKX)cLqrKloYpnchucc9qWbtGabFOiknhnbcHnOi(upnLbfHrVGZTazjsWbv9cO3tBkZrtmoOGJsW6lu2lGE92R3EDUHa7yLGdbkixCKFACP8fusdS6qe7I3RKuVy0lhDsPLp7iWtzzV(6vsQxo6KslFwwWK9IGr9kj17PnL5OjwPegI6vsQxNBiWC0ieO(QE2fVxa96CdbMJgHa1x1ZgY1Qu1RN9ce56nME92lhLG36z4dXlfjmDblDP8zF5sIttFPE91RVEb0lg96Cdbg3evYzx8Eb0R3EXOxo6KslFwwWK9IGr9kj1lhH0Gi)jJJYt0rs8YiHcVM6vSlEVss9w5tdosBpbkcfmzVyixRsvVE2lhH0Gi)jJJYt0rs8YiHcVM6vSHCTkv9gtVYFVss9w5tdosBpbkcfmzVyixRsvVYxVyI1KRxp7fiY1Bm96TxokbV1ZWhIxksy6cw6s5Z(YLeNM(s96RxFqrg)lucfXjnP(Y0ctxWsxkFOhcoyIfi4dfrP5OjqiSbfXN6PPmOim6fCUfilrcoOQxa9EAtzoAIXbfCucwFHYEb0R3E92RZneyhReCiqb5IJ8tJlLVGsAGvhIyx8ELK6fJE5OtkT8zhbEkl71xVss9YrNuA5ZYcMSxemQxjPEpTPmhnXkLWquVss96CdbMJgHa1x1ZU49cOxNBiWC0ieO(QE2qUwLQE9SxSixVX0R3E5Oe8wpdFiEPiHPlyPlLp7lxsCA6l1RVE91lGEXOxNBiW4MOso7I3lGE92lg9YrNuA5ZYcMSxemQxjPE5iKge5pzCuEIosIxgju41uVIDX7vsQ3kFAWrA7jqrOGj7fd5AvQ61ZE5iKge5pzCuEIosIxgju41uVInKRvPQ3y6v(7vsQ3kFAWrA7jqrOGj7fd5AvQ6v(6ftSMC96zVyrUEJPxV9Yrj4TEg(q8srctxWsxkF2xUK400xQxF96dkY4FHsOOk52K2xOe6HGdMyhe8HIO0C0eie2GIq4qrk6HIm(xOek60MYC0eu0PPVeueg9YriniYFY4MOsoBide4ELK6fJEpTPmhnX4O8eDKeGKc4K3lGE5OtkT8zzbt2lcg1RKuVGZTazjsWbvqrN2isZLGIu2jjcOrWnrLCOhcoycpi4dfrP5OjqiSbfXN6PPmOiIRlCfXQuyjW9cOxdxWLr8J9cOxV9cIEMbA4FDscLFBCfGMRbJyFXpwjSELK6fJE5OtkT8zjXhKgnG96Rxa9EAtzoAIPStseqJGBIk5qrg)lucffUdWcuqq6BsqpeCWu(HGpueLMJMaHWgueFQNMYGI4OtkT8zzbt2lcg1lGEpTPmhnX4O8eDKeGKc4K3lGEn1pMwGJ8ttVEeVxStUEb0lhH0Gi)jJJYt0rs8YiHcVM6vSHCTkv96zVW4GmxtE9Ey9YPs3R3En1pMwGJ8ttVWTxSixV(6fqVy0l4ClqwIeCqfuKX)cLqrQ3g1DGrqpeCW8WHGpueLMJMaHWgueFQNMYGI82RZneyexx4ksOVPnSlEVss96TxUmBGrQEJ3lq6fqVdXLzdms8Ll1RN9cVE91RKuVCz2aJu9gVxS0RVEb0RHl4Yi(XEb07PnL5OjMYojrancUjQKdfz8Vqjuus(fUiuc9qWbtSge8HIO0C0eie2GI4t90uguK3EDUHaJ46cxrc9nTHDX7fqVy0lhDsPLp7iWtzzVss96TxNBiWowj4qGcYfh5NgxkFbL0aRoeXU49cOxo6KslF2rGNYYE91RKuVE7LlZgyKQ349cKEb07qCz2aJeF5s96zVWRxF9kj1lxMnWivVX7fl9kj1RZneyCtujNDX71xVa61WfCze)yVa690MYC0etzNKiGgb3evYHIm(xOeksMPdcxekHEi4GzSbbFOiknhnbcHnOi(upnLbf5TxNBiWiUUWvKqFtByx8Eb0lg9YrNuA5Zoc8uw2RKuVE715gcSJvcoeOGCXr(PXLYxqjnWQdrSlEVa6LJoP0YNDe4PSSxF9kj1R3E5YSbgP6nEVaPxa9oexMnWiXxUuVE2l861xVss9YLzdms1B8EXsVss96Cdbg3evYzx8E91lGEnCbxgXp2lGEpTPmhnXu2jjcOrWnrLCOiJ)fkHIcxTw4Iqj0dbhGihe8HIm(xOekYVntHgbkii9njOiknhnbcHnOhcoabti4dfrP5OjqiSbfXN6PPmOiIRlCfXQuOVPn9kj1lX1fUIykK2grsY77vsQxIRlCfXSeyrsY77vsQxNBiW8BZuOrGccsFtIDX7fqVo3qGrCDHRiH(M2WU49kj1R3EDUHaJBIk5SHCTkv96zVg)luY8p2lJrYJ43NeF5s9cOxNBiW4MOso7I3RpOiJ)fkHIuVnHAiOhcoabiqWhkY4FHsOi)J9YGIO0C0eie2GEi4aeSabFOiknhnbcHnOiJ)fkHIMBkm(xOuOl1dfPl1lsZLGIcMw)YMl0d9qrgIGGpeCWec(qruAoAcecBqriCOif9qrg)lucfDAtzoAck600xckYBVo3qG9Ll5hnPaCiZ1PsqAyd5AvQ61ZEHXbzUM86nMELJHzVss96Cdb2xUKF0KcWHmxNkbPHnKRvPQxp714FHsM6TjudXi5r87tIVCPEJPx5yy2lGE92lX1fUIyvk030MELK6L46cxrmfsBJij599kj1lX1fUIywcSij5996RxF9cOxNBiW(YL8JMuaoK56ujinSlEVa6DUjfqdmI9Ll5hnPaCiZ1PsqAyuSElCCcek60grAUeue4qMRWFP1IGP1cuia9qWbiqWhkIsZrtGqydkcHdfPOhkY4FHsOOtBkZrtqrNM(sqro3qGrCDHRiH(M2WU49cOxV9QWjTw82aJEft92eQH61JEXUEb07BAkFMcD1cuq8YiranK6zuAoAcSxjPEv4KwlEBGrVIPEBc1q96rVYFV(GIoTrKMlbfvWs0qc1BJ6oWiOhcoybc(qruAoAcecBqr8PEAkdkYBVN2uMJMyCuEIoscqsbCY7fqVy0lhH0Gi)jJBIk5SHmqG7vsQxNBiW4MOso7I3RVEb0R3En1pMwGJ8ttVE2l8KRxjPEpTPmhnXkyjAiH6TrDhyuV(6fqVE715gcmIRlCfj030g2qUwLQE9Ox5VxjPEDUHaJ46cxrcfsBdBixRsvVE0R83RVEb0R3EXO35MuanWiMJPTKtcuqyAT4LvjmfJsZrtG9kj1RZneyoM2sojqbHP1IxwLWuI0(7qm1B8J96rVyPxjPEDUHaZX0wYjbkimTw8YQeMsyd3sIPEJFSxp6fl96RxjPEdfmzVyixRsvVE2lMYbfz8VqjuehLNOJK4LrcfEn1RGEi4GDqWhkIsZrtGqydkY4FHsOi1nd1qqr8PEAkdkYBVdfgsjZC0uVss96CdbgX1fUIekK2g2qUwLQE9SxS0lGEjUUWveRsHcPTPxa9oKRvPQxp7ftSRxa9(MMYNPqxTafeVmseqdPEgLMJMa71xVa69Tbg9SVCjXJeGf1Rh9Ij21l2RxfoP1I3gy0R6nMEhY1Qu1lGE92lX1fUIyvkSe4ELK6DixRsvVE2lmoiZ1KxV(GI4aZ1K4Tbg9ki4Gj0dbh4bbFOiknhnbcHnOi(upnLbf5TxNBiWuVnbtRzdfgsjZC0uVa61BVkCsRfVnWOxXuVnbtR71ZEXsVss9IrVZnPaAGrSVCj)OjfGdzUovcsdJI1BHJtG96RxjPEFtt5ZuORwGcIxgjcOHupJsZrtG9cOxNBiWiUUWvKqH02WgY1Qu1RN9ILEb0lX1fUIyvkuiTn9cOxNBiWuVnbtRzd5AvQ61ZEp8Eb0RcN0AXBdm6vm1BtW06E9iEVyxV(6fqVE7fJENBsb0aJyAG52ykrqt0xjmbmD5IRigfR3chNa7vsQ3VCPELVEXo41Rh96CdbM6TjyAnBixRsvVX0lq61xVa69Tbg9SVCjXJeGf1Rh9cpOiJ)fkHIuVnbtRHEi4i)qWhkIsZrtGqydkIp1ttzqrZnPaAGrSVCj)OjfGdzUovcsdJI1BHJtG9cOxfoP1I3gy0RyQ3MGP196r8EXsVa61BVy0RZneyF5s(rtkahYCDQeKg2fVxa96CdbM6TjyAnBOWqkzMJM6vsQxV9EAtzoAIboK5k8xATiyATafc9cOxV96CdbM6TjyAnBixRsvVE2lw6vsQxfoP1I3gy0RyQ3MGP196rVaPxa9(MMYNPEsRTraov4zuAoAcSxa96CdbM6TjyAnBixRsvVE2l861xV(61huKX)cLqrQ3MGP1qpeCoCi4dfrP5OjqiSbfHWHIu0dfz8Vqju0PnL5OjOOttFjOit9JPf4i)00Rh9I1KRxSxVE7ft569W615gcSVCj)OjfGdzUovcsdt9g)yV(6f71R3EDUHat92emTMnKRvPQ3dRxS0lC7vHtATqMPEQxF9I961BVGONfUdWcuqq6BsSHCTkv9Ey9cVE91lGEDUHat92emTMDXHIoTrKMlbfPEBcMwl8JYxemTwGcbOhcoyni4dfrP5OjqiSbfXN6PPmOOtBkZrtmWHmxH)sRfbtRfOqOxa9EAtzoAIPEBcMwl8JYxemTwGcHEb0lg9EAtzoAIvWs0qc1BJ6oWOELK61BVo3qG5yAl5KafeMwlEzvctjs7VdXuVXp2Rh9ILELK615gcmhtBjNeOGW0AXlRsykHnCljM6n(XE9OxS0RVEb0RcN0AXBdm6vm1BtW06E9SxSdkY4FHsOi1BJ6oWiOhcoXge8HIO0C0eie2GIm(xOekYan8VojHYVnUqr8PEAkdkcJE)IFSsy9cOxm614FHsMbA4FDscLFBCfGMRbJyvkc6cMSVxjPEbrpZan8VojHYVnUcqZ1Grm1B8J96zVyPxa9cIEMbA4FDscLFBCfGMRbJyd5AvQ61ZEXcuehyUMeVnWOxbbhmHEi4GPCqWhkIsZrtGqydkY4FHsOixekd1qqr8PEAkdkAOWqkzMJM6fqVVnWON9LljEKaSOE9OxV9Ij21Bm96TxfoP1I3gy0RyQ3MqnuVhwVyYGxV(61xVWTxfoP1I3gy0R6nMEhY1Qu1lGE92R3E5iKge5pzCtujNnKbcCVa6fJEbNBbYsKGdQ6fqVE790MYC0eJJYt0rsaskGtEVss9YriniYFY4O8eDKeVmsOWRPEfBide4ELK6fJE5OtkT8zzbt2lcg1RVELK6vHtAT4Tbg9kM6Tjud1RN96Tx417H1R3EXS3y69nnLp79xPWfHsfJsZrtG96RxF9kj1R3EjUUWveRsHcPTPxjPE92lX1fUIyvkCqVSELK6L46cxrSkf6BAtV(6fqVy07BAkFMcD1cuq8YiranK6zuAoAcSxjPEDUHadFkx0awMwyd3YIlWVALnSttFPE9iEVabEY1RVEb0R3Ev4KwlEBGrVIPEBc1q96zVykxVhwVE7fZEJP330u(S3FLcxekvmknhnb2RVE91lGEn1pMwGJ8ttVE0l8KRxSxVo3qGPEBcMwZgY1Qu17H1R83RVEb0R3EXOxNBiWowj4qGcYfh5NgxkFbL0aRoeXU49kj1lX1fUIyvkuiTn9kj1lg9YrNuA5Zoc8uw2RVEb0RHl4Yi(XE9bfXbMRjXBdm6vqWbtOhcoyIje8HIO0C0eie2GI4t90uguKHl4Yi(rOiJ)fkHIcOHtcuqK2Fhc6HGdMabc(qruAoAcecBqr8PEAkdkY5gcmUjQKZU4qrg)lucfn2jLORsegkpeWqpeCWelqWhkIsZrtGqydkIp1ttzqry0l4ClqwIeCqvVa690MYC0eJdk4OeS(cL9cOxV96CdbM6TjyAn7I3RKuVM6htlWr(PPxp6fEY1RVEb0lg96CdbMcPvFXj2fVxa9IrVo3qGXnrLC2fVxa96Txm6LJoP0YNLfmzViyuVss9EAtzoAIXr5j6ijajfWjVxjPE5iKge5pzCuEIosIxgju41uVIDX7vsQ3kFAWrA7jqrOGj7fd5AvQ61ZEbIC9gtVE7LJsWB9m8H4LIeMUGLUu(SVCjXPPVuV(61huKX)cLqrCstQVmTW0fS0LYh6HGdMyhe8HIO0C0eie2GI4t90ugueg9co3cKLibhu1lGEpTPmhnX4GcokbRVqzVa61BVo3qGPEBcMwZU49kj1RP(X0cCKFA61JEHNC96Rxa9IrVo3qGPqA1xCIDX7fqVy0RZneyCtujNDX7fqVE7fJE5OtkT8zzbt2lcg1RKuVN2uMJMyCuEIoscqsbCY7vsQxocPbr(tghLNOJK4LrcfEn1Ryx8ELK6TYNgCK2EcuekyYEXqUwLQE9SxocPbr(tghLNOJK4LrcfEn1Ryd5AvQ6nMEL)ELK6TYNgCK2EcuekyYEXqUwLQELVEXeRjxVE2lwKR3y61BVCucERNHpeVuKW0fS0LYN9Lljon9L61xV(GIm(xOekQsUnP9fkHEi4Gj8GGpueLMJMaHWgueFQNMYGIQ8PbhPTNafHcMSxmKRvPQxp7ft41RKuVE715gcm8PCrdyzAHnCllUa)Qv2Won9L61ZEbc8KRxjPEDUHadFkx0awMwyd3YIlWVALnSttFPE9iEVabEY1RVEb0RZneyQ3MGP1SlEVa61BVCesdI8NmUjQKZgY1Qu1Rh9cp56vsQxW5wGSej4GQE9bfz8Vqjue5IJ8tJWbLGqpeCWu(HGpueLMJMaHWguKX)cLqrQN0ABebTneueFQNMYGIgkmKsM5OPEb07xUK4rcWI61JEXeE9cOxfoP1I3gy0RyQ3MqnuVE2l21lGEnCbxgXp2lGE92RZneyCtujNnKRvPQxp6ft56vsQxm615gcmUjQKZU496dkIdmxtI3gy0RGGdMqpeCW8WHGpueLMJMaHWgueFQNMYGIiUUWveRsHLa3lGEnCbxgXp2lGEDUHadFkx0awMwyd3YIlWVALnSttFPE9SxGap56fqVE7fe9md0W)6Kek)24kanxdgX(IFSsy9kj1lg9YrNuA5ZsIpinAa7vsQxfoP1I3gy0R61JEbsV(GIm(xOekkChGfOGG03KGEi4Gjwdc(qruAoAcecBqr8PEAkdkY5gcmusVmLaNgoH)fkzx8Eb0R3EDUHat92emTMnuyiLmZrt9kj1RP(X0cCKFA61JEJn561huKX)cLqrQ3MGP1qpeCWm2GGpueLMJMaHWgueFQNMYGI4OtkT8zzbt2lcg1lGE927PnL5OjghLNOJKaKuaN8ELK6LJqAqK)KXnrLC2fVxjPEDUHaJBIk5SlEV(6fqVCesdI8NmokprhjXlJek8AQxXgY1Qu1RN9cJdYCn517H1lNkDVE71u)yAboYpn9c3EHNC96Rxa96CdbM6TjyAnBixRsvVE2l21lGEXOxW5wGSej4GkOiJ)fkHIuVnbtRHEi4ae5GGpueLMJMaHWgueFQNMYGI4OtkT8zzbt2lcg1lGE927PnL5OjghLNOJKaKuaN8ELK6LJqAqK)KXnrLC2fVxjPEDUHaJBIk5SlEV(6fqVCesdI8NmokprhjXlJek8AQxXgY1Qu1RN9k)9cOxNBiWuVnbtRzx8Eb0lX1fUIyvkSe4Eb0lg9EAtzoAIvWs0qc1BJ6oWOEb0lg9co3cKLibhubfz8VqjuK6TrDhye0dbhGGje8HIO0C0eie2GI4t90uguKZneyOKEzkbxt2iolvHs2fVxjPE92lg9QEBc1qmdxWLr8J9kj1R3EDUHaJBIk5SHCTkv96zVWRxa96Cdbg3evYzx8ELK61BVo3qGn2jLORsegkpeWSHCTkv96zVW4GmxtE9Ey9YPs3R3En1pMwGJ8ttVWTxSixV(6fqVo3qGn2jLORsegkpeWSlEV(61xVa690MYC0et92emTw4hLViyATafc9cOxfoP1I3gy0RyQ3MGP196zVyPxF9cOxV9IrVZnPaAGrSVCj)OjfGdzUovcsdJI1BHJtG9kj1RcN0AXBdm6vm1BtW06E9SxS0RpOiJ)fkHIuVnQ7aJGEi4aeGabFOiknhnbcHnOi(upnLbf5TxIRlCfXQuyjW9cOxocPbr(tg3evYzd5AvQ61JEHNC9kj1R3E5YSbgP6nEVaPxa9oexMnWiXxUuVE2l861xVss9YLzdms1B8EXsV(6fqVgUGlJ4hHIm(xOekkj)cxekHEi4aeSabFOiknhnbcHnOi(upnLbf5TxIRlCfXQuyjW9cOxocPbr(tg3evYzd5AvQ61JEHNC9kj1R3E5YSbgP6nEVaPxa9oexMnWiXxUuVE2l861xVss9YLzdms1B8EXsV(6fqVgUGlJ4hHIm(xOeksMPdcxekHEi4aeSdc(qruAoAcecBqr8PEAkdkYBVexx4kIvPWsG7fqVCesdI8NmUjQKZgY1Qu1Rh9cp56vsQxV9YLzdms1B8EbsVa6DiUmBGrIVCPE9Sx41RVELK6LlZgyKQ349ILE91lGEnCbxgXpcfz8Vqjuu4Q1cxekHEi4ae4bbFOiJ)fkHI8BZuOrGccsFtckIsZrtGqyd6HGdqKFi4dfrP5OjqiSbfHWHIu0dfz8Vqju0PnL5OjOOttFjOifoP1I3gy0RyQ3MqnuVE0l21Bm9g0i00R3EDn1tdWIttFPEpSEXuo56fU9ce561xVX0BqJqtVE715gcm1BJ6oWib5IJ8tJlLVqH02WuVXp2lC7f761hu0PnI0CjOi1BtOgsuPqH02a9qWbihoe8HIO0C0eie2GI4t90ugueX1fUIy6BAJij599kj1lX1fUIywcSij599cO3tBkZrtSsj4AYoPELK615gcmIRlCfjuiTnSHCTkv96zVg)luYuVnHAigjpIFFs8Ll1lGEDUHaJ46cxrcfsBd7I3RKuVexx4kIvPqH020lGEXO3tBkZrtm1BtOgsuPqH020RKuVo3qGXnrLC2qUwLQE9SxJ)fkzQ3MqneJKhXVpj(YL6fqVy07PnL5OjwPeCnzNuVa615gcmUjQKZgY1Qu1RN9sYJ43NeF5s9cOxNBiW4MOso7I3RKuVo3qGn2jLORsegkpeWSlEVa6vHtATqMPEQxp6voM83lGE92RcN0AXBdm6v96z8EXsVss9IrVVPP8zk0vlqbXlJeb0qQNrP5OjWE91RKuVy07PnL5OjwPeCnzNuVa615gcmUjQKZgY1Qu1Rh9sYJ43NeF5sqrg)lucf5FSxg0dbhGG1GGpuKX)cLqrQ3MqneueLMJMaHWg0dbhGeBqWhkIsZrtGqydkY4FHsOO5McJ)fkf6s9qr6s9I0CjOOGP1VS5c9qpuuW06x2CHGpeCWec(qruAoAcecBqr8PEAkdkcJENBsb0aJyoM2sojqbHP1IxwLWumkwVfoobcfz8VqjuK6TrDhye0dbhGabFOiknhnbcHnOiJ)fkHIu3mudbfXN6PPmOiq0ZCrOmudXgY1Qu1Rh9oKRvPckIdmxtI3gy0RGGdMqpeCWce8HIm(xOekYfHYqneueLMJMaHWg0d9qrQhc(qWbti4dfrP5OjqiSbfz8VqjuKbA4FDscLFBCHI4t90ugueg9cIEMbA4FDscLFBCfGMRbJyFXpwjSEb0lg9A8VqjZan8VojHYVnUcqZ1GrSkfbDbt23lGE92lg9cIEMbA4FDscLFBCfYitZ(IFSsy9kj1li6zgOH)1jju(TXviJmnBixRsvVE0l861xVss9cIEMbA4FDscLFBCfGMRbJyQ34h71ZEXsVa6fe9md0W)6Kek)24kanxdgXgY1Qu1RN9ILEb0li6zgOH)1jju(TXvaAUgmI9f)yLWGI4aZ1K4Tbg9ki4Gj0dbhGabFOiknhnbcHnOi(upnLbf5T3tBkZrtmokprhjbiPao59cOxm6LJqAqK)KXnrLC2qgiW9kj1RZneyCtujNDX71xVa61u)yAboYpn96zVyNC9cOxV96CdbgX1fUIe6BAdBixRsvVE0lMY1RKuVo3qGrCDHRiHcPTHnKRvPQxp6ft561xVss9gkyYEXqUwLQE9SxmLdkY4FHsOiokprhjXlJek8AQxb9qWblqWhkIsZrtGqydkcHdfPOhkY4FHsOOtBkZrtqrNM(sqrE715gcmUjQKZgY1Qu1Rh9cVEb0R3EDUHaBStkrxLimuEiGzd5AvQ61JEHxVss9IrVo3qGn2jLORsegkpeWSlEV(6vsQxm615gcmUjQKZU49kj1RP(X0cCKFA61ZEXIC96Rxa96Txm615gcSJvcoeOGCXr(PXLYxqjnWQdrSlEVss9AQFmTah5NME9SxSixV(6fqVE715gcmIRlCfjuiTnSHCTkv96rVW4GmxtE9kj1RZneyexx4ksOVPnSHCTkv96rVW4GmxtE96dk60grAUeuei6fdfR3AixkFf0dbhSdc(qruAoAcecBqrg)lucf5IqzOgckIp1ttzqrdfgsjZC0uVa69Tbg9SVCjXJeGf1Rh9Ijq6fqVE71WfCze)yVa690MYC0ede9IHI1BnKlLVQxFqrCG5As82aJEfeCWe6HGd8GGpueLMJMaHWguKX)cLqrQBgQHGI4t90ugu0qHHuYmhn1lGEFBGrp7lxs8ibyr96rVycKEb0R3EnCbxgXp2lGEpTPmhnXarVyOy9wd5s5R61huehyUMeVnWOxbbhmHEi4i)qWhkIsZrtGqydkY4FHsOi1tATnIG2gckIp1ttzqrdfgsjZC0uVa69Tbg9SVCjXJeGf1Rh9IP83lGE92RHl4Yi(XEb07PnL5Ojgi6fdfR3AixkFvV(GI4aZ1K4Tbg9ki4Gj0dbNdhc(qruAoAcecBqr8PEAkdkYWfCze)iuKX)cLqrb0Wjbkis7Vdb9qWbRbbFOiknhnbcHnOi(upnLbf5Cdbg3evYzxCOiJ)fkHIg7Ks0vjcdLhcyOhcoXge8HIO0C0eie2GI4t90uguK3E92RZneyexx4ksOqAByd5AvQ61JEXuUELK615gcmIRlCfj030g2qUwLQE9OxmLRxF9cOxocPbr(tg3evYzd5AvQ61JEXIC9cOxV96Cdbg(uUObSmTWgULfxGF1kByNM(s96zVab7KRxjPEXO35MuanWig(uUObSmTWgULfxGF1kByuSElCCcSxF96RxjPEDUHadFkx0awMwyd3YIlWVALnSttFPE9iEVa5WLRxjPE5iKge5pzCtujNnKbcCVa61BVM6htlWr(PPxp6n2KRxjPEpTPmhnXkLWquV(GIm(xOekICXr(Pr4GsqOhcoykhe8HIO0C0eie2GI4t90ugueg9co3cKLibhu1lGEpTPmhnX4GcokbRVqzVa61BVM6htlWr(PPxp6n2KRxa96TxNBiWowj4qGcYfh5NgxkFbL0aRoeXU49kj1lg9YrNuA5Zoc8uw2RVELK6LJoP0YNLfmzViyuVss9EAtzoAIvkHHOELK615gcmhncbQVQNDX7fqVo3qG5Oriq9v9SHCTkv96zVarUEJPxV96T3yR3dR35MuanWig(uUObSmTWgULfxGF1kByuSElCCcSxF9gtVE7LJsWB9m8H4LIeMUGLUu(SVCjXPPVuV(61xV(6fqVy0RZneyCtujNDX7fqVE7fJE5OtkT8zzbt2lcg1RKuVCesdI8NmokprhjXlJek8AQxXU49kj1BLpn4iT9eOiuWK9IHCTkv96zVCesdI8NmokprhjXlJek8AQxXgY1Qu1Bm9k)9kj1BLpn4iT9eOiuWK9IHCTkv9kF9IjwtUE9SxGixVX0R3E5Oe8wpdFiEPiHPlyPlLp7lxsCA6l1RVE9bfz8VqjueN0K6ltlmDblDP8HEi4GjMqWhkIsZrtGqydkIp1ttzqry0l4ClqwIeCqvVa690MYC0eJdk4OeS(cL9cOxV9AQFmTah5NME9O3ytUEb0R3EDUHa7yLGdbkixCKFACP8fusdS6qe7I3RKuVy0lhDsPLp7iWtzzV(6vsQxo6KslFwwWK9IGr9kj17PnL5OjwPegI6vsQxNBiWC0ieO(QE2fVxa96CdbMJgHa1x1ZgY1Qu1RN9If56nME92R3EJTEpSENBsb0aJy4t5IgWY0cB4wwCb(vRSHrX6TWXjWE91Bm96TxokbV1ZWhIxksy6cw6s5Z(YLeNM(s96RxF96Rxa9IrVo3qGXnrLC2fVxa96Txm6LJoP0YNLfmzViyuVss9YriniYFY4O8eDKeVmsOWRPEf7I3RKuVv(0GJ02tGIqbt2lgY1Qu1RN9YriniYFY4O8eDKeVmsOWRPEfBixRsvVX0R83RKuVv(0GJ02tGIqbt2lgY1Qu1R81lMyn561ZEXIC9gtVE7LJsWB9m8H4LIeMUGLUu(SVCjXPPVuV(61huKX)cLqrvYTjTVqj0dbhmbce8HIO0C0eie2GIq4qrk6HIm(xOek60MYC0eu0PPVeueg9YriniYFY4MOsoBide4ELK6fJEpTPmhnX4O8eDKeGKc4K3lGE5OtkT8zzbt2lcg1RKuVGZTazjsWbvqrN2isZLGIu2jjcOrWnrLCOhcoyIfi4dfrP5OjqiSbfXN6PPmOiIRlCfXQuyjW9cOxdxWLr8J9cOxNBiWWNYfnGLPf2WTS4c8Rwzd700xQxp7fiyNC9cOxV9cIEMbA4FDscLFBCfGMRbJyFXpwjSELK6fJE5OtkT8zjXhKgnG96Rxa9EAtzoAIPStseqJGBIk5qrg)lucffUdWcuqq6BsqpeCWe7GGpueLMJMaHWgueFQNMYGICUHadL0ltjWPHt4FHs2fVxa96CdbM6TjyAnBOWqkzMJMGIm(xOeks92emTg6HGdMWdc(qruAoAcecBqr8PEAkdkY5gcm1BJgnGSHCTkv96zVWRxa96TxNBiWiUUWvKqH02WgY1Qu1Rh9cVELK615gcmIRlCfj030g2qUwLQE9Ox41RVEb0RP(X0cCKFA61JEJn5GIm(xOekIBjN0cNBiaf5CdbrAUeuK6TrJgqOhcoyk)qWhkIsZrtGqydkIp1ttzqrVPP8zQN0ABeGtfEgLMJMa7fqVk6)kHPykKgjaNk89cOxNBiWuVnbtRzGi)juKX)cLqrQ3MGP1qpeCW8WHGpueLMJMaHWgueFQNMYGI4OtkT8zzbt2lcg1lGEpTPmhnX4O8eDKeGKc4K3lGE5iKge5pzCuEIosIxgju41uVInKRvPQxp7fE9cOxm6fCUfilrcoOckY4FHsOi1BJ6oWiOhcoyI1GGpueLMJMaHWgueFQNMYGIEtt5ZupP12iaNk8mknhnb2lGEXO330u(m1BJgnGmknhnb2lGEDUHat92emTMnuyiLmZrt9cOxV96CdbgX1fUIe6BAdBixRsvVE0R83lGEjUUWveRsH(M20lGEDUHadFkx0awMwyd3YIlWVALnSttFPE9SxGap56vsQxNBiWWNYfnGLPf2WTS4c8Rwzd700xQxpI3lqGNC9cOxt9JPf4i)00Rh9gBY1RKuVGONzGg(xNKq53gxbO5AWi2qUwLQE9OxSwVss9A8VqjZan8VojHYVnUcqZ1GrSkfbDbt23RVEb0lg9YriniYFY4MOsoBideyOiJ)fkHIuVnbtRHEi4GzSbbFOiknhnbcHnOi(upnLbf5CdbgkPxMsW1KnIZsvOKDX7vsQxNBiWowj4qGcYfh5NgxkFbL0aRoeXU49kj1RZneyCtujNDX7fqVE715gcSXoPeDvIWq5HaMnKRvPQxp7fghK5AYR3dRxov6E92RP(X0cCKFA6fU9If561xVa615gcSXoPeDvIWq5HaMDX7vsQxm615gcSXoPeDvIWq5HaMDX7fqVy0lhH0Gi)jBStkrxLimuEiGzdzGa3RKuVy0lhDsPLp7KYxgWtV(6vsQxt9JPf4i)00Rh9gBY1lGEjUUWveRsHLadfz8VqjuK6TrDhye0dbhGihe8HIO0C0eie2GI4t90ugu0BAkFM6TrJgqgLMJMa7fqVE715gcm1BJgnGSlEVss9AQFmTah5NME9O3ytUE91lGEDUHat92Ordit9g)yVE2lw6fqVE715gcmIRlCfjuiTnSlEVss96CdbgX1fUIe6BAd7I3RVEb0RZney4t5IgWY0cB4wwCb(vRSHDA6l1RN9cKdxUEb0R3E5iKge5pzCtujNnKRvPQxp6ft56vsQxm690MYC0eJJYt0rsaskGtEVa6LJoP0YNLfmzViyuV(GIm(xOeks92OUdmc6HGdqWec(qruAoAcecBqr8PEAkdkYBVo3qGHpLlAaltlSHBzXf4xTYg2PPVuVE2lqoC56vsQxNBiWWNYfnGLPf2WTS4c8Rwzd700xQxp7fiWtUEb07BAkFM6jT2gb4uHNrP5OjWE91lGEDUHaJ46cxrcfsBdBixRsvVE07H3lGEjUUWveRsHcPTPxa9IrVo3qGHs6LPe40Wj8Vqj7I3lGEXO330u(m1BJgnGmknhnb2lGE5iKge5pzCtujNnKRvPQxp69W7fqVE7LJqAqK)KrU4i)0iCqjiBixRsvVE07H3RKuVy0lhDsPLp7iWtzzV(GIm(xOeks92OUdmc6HGdqace8HIO0C0eie2GI4t90uguK3EDUHaJ46cxrc9nTHDX7vsQxV9YLzdms1B8EbsVa6DiUmBGrIVCPE9Sx41RVELK6LlZgyKQ349ILE91lGEnCbxgXp2lGEpTPmhnXu2jjcOrWnrLCOiJ)fkHIsYVWfHsOhcoablqWhkIsZrtGqydkIp1ttzqrE715gcmIRlCfj030g2fVxa9IrVC0jLw(SJapLL9kj1R3EDUHa7yLGdbkixCKFACP8fusdS6qe7I3lGE5OtkT8zhbEkl71xVss96TxUmBGrQEJ3lq6fqVdXLzdms8Ll1RN9cVE91RKuVCz2aJu9gVxS0RKuVo3qGXnrLC2fVxF9cOxdxWLr8J9cO3tBkZrtmLDsIaAeCtujhkY4FHsOizMoiCrOe6HGdqWoi4dfrP5OjqiSbfXN6PPmOiV96CdbgX1fUIe6BAd7I3lGEXOxo6KslF2rGNYYELK61BVo3qGDSsWHafKloYpnUu(ckPbwDiIDX7fqVC0jLw(SJapLL96RxjPE92lxMnWivVX7fi9cO3H4YSbgj(YL61ZEHxV(6vsQxUmBGrQEJ3lw6vsQxNBiW4MOso7I3RVEb0RHl4Yi(XEb07PnL5OjMYojrancUjQKdfz8Vqjuu4Q1cxekHEi4ae4bbFOiJ)fkHI8BZuOrGccsFtckIsZrtGqyd6HGdqKFi4dfrP5OjqiSbfXN6PPmOiIRlCfXQuOVPn9kj1lX1fUIykK2grsY77vsQxIRlCfXSeyrsY77vsQxNBiW8BZuOrGccsFtIDX7fqVo3qGrCDHRiH(M2WU49kj1R3EDUHaJBIk5SHCTkv96zVg)luY8p2lJrYJ43NeF5s9cOxNBiW4MOso7I3RpOiJ)fkHIuVnHAiOhcoa5WHGpuKX)cLqr(h7LbfrP5OjqiSb9qWbiyni4dfrP5OjqiSbfz8Vqju0CtHX)cLcDPEOiDPErAUeuuW06x2CHEOhkYbzpe8HGdMqWhkIsZrtGqydkIp1ttzqro3qGXnrLC2fhkY4FHsOOXoPeDvIWq5Hag6HGdqGGpueLMJMaHWguechksrpuKX)cLqrN2uMJMGIon9LGIWOxNBiWCmTLCsGcctRfVSkHPeP93Hyx8Eb0lg96CdbMJPTKtcuqyAT4LvjmLWgULe7IdfDAJinxckIp1NO)Id9qWblqWhkIsZrtGqydkY4FHsOid0W)6Kek)24cfXN6PPmOiNBiWCmTLCsGcctRfVSkHPeP93HyQ34h71ZEXUEb0RZneyoM2sojqbHP1IxwLWucB4wsm1B8J96zVyxVa61BVy0li6zgOH)1jju(TXvaAUgmI9f)yLW6fqVy0RX)cLmd0W)6Kek)24kanxdgXQue0fmzFVa61BVy0li6zgOH)1jju(TXviJmn7l(XkH1RKuVGONzGg(xNKq53gxHmY0SHCTkv96rVyPxF9kj1li6zgOH)1jju(TXvaAUgmIPEJFSxp7fl9cOxq0Zmqd)RtsO8BJRa0CnyeBixRsvVE2l86fqVGONzGg(xNKq53gxbO5AWi2x8JvcRxFqrCG5As82aJEfeCWe6HGd2bbFOiknhnbcHnOi(upnLbf5T3tBkZrtmokprhjbiPao59cOxm6LJqAqK)KXnrLC2qgiW9kj1RZneyCtujNDX71xVa61BVo3qG5yAl5KafeMwlEzvctjs7VdXuVXp2B8EHxVss96CdbMJPTKtcuqyAT4LvjmLWgULet9g)yVX7fE96RxjPEdfmzVyixRsvVE2lMYbfz8VqjuehLNOJK4LrcfEn1RGEi4api4dfrP5OjqiSbfXN6PPmOiV96CdbMJPTKtcuqyAT4LvjmLiT)oeBixRsvVE0l2XGxVss96CdbMJPTKtcuqyAT4LvjmLWgULeBixRsvVE0l2XGxV(6fqVM6htlWr(PPxpI3BSjxVa61BVCesdI8NmUjQKZgY1Qu1Rh9E49kj1R3E5iKge5pzKloYpnchucYgY1Qu1Rh9E49cOxm615gcSJvcoeOGCXr(PXLYxqjnWQdrSlEVa6LJoP0YNDe4PSSxF96dkY4FHsOiULCslCUHauKZneeP5sqrQ3gnAaHEi4i)qWhkIsZrtGqydkIp1ttzqrVPP8zQN0ABeGtfEgLMJMa7fqVk6)kHPykKgjaNk89cOxNBiWuVnbtRzGi)juKX)cLqrQ3MGP1qpeCoCi4dfrP5OjqiSbfXN6PPmOim690MYC0eJp1NO)I3lGE92lhDsPLpllyYErWOELK6LJqAqK)KXnrLC2qUwLQE9O3dVxjPEXO3tBkZrtmoOGJsW6lu2lGEXOxo6KslF2rGNYYELK61BVCesdI8NmYfh5NgHdkbzd5AvQ61JEp8Eb0lg96Cdb2XkbhcuqU4i)04s5lOKgy1Hi2fVxa9YrNuA5Zoc8uw2RVE9bfz8VqjuK6TrDhye0dbhSge8HIO0C0eie2GI4t90uguK3E5iKge5pzCuEIosIxgju41uVInKRvPQxp7fE9cOxm6fCUfilrcoOQxa96T3tBkZrtmokprhjbiPao59kj1lhH0Gi)jJBIk5SHCTkv96zVWRxF9cO3tBkZrtmoOGJsW6lu2RVEb0RP(X0cCKFA61JEXo56fqVC0jLw(SSGj7fbJ6fqVy0l4ClqwIeCqfuKX)cLqrQ3g1DGrqpeCIni4dfrP5OjqiSbfHWHIu0dfz8Vqju0PnL5OjOOttFjOiV96Cdbg3evYzd5AvQ61JEHxVa61BVo3qGn2jLORsegkpeWSHCTkv96rVWRxjPEXOxNBiWg7Ks0vjcdLhcy2fVxF9kj1lg96Cdbg3evYzx8E91lGE92lg96Cdb2XkbhcuqU4i)04s5lOKgy1Hi2fVxF9cOxV96CdbgX1fUIekK2g2qUwLQE9OxyCqMRjVELK615gcmIRlCfj030g2qUwLQE9OxyCqMRjVE9bfDAJinxckce9IHI1BnKlLVc6HGdMYbbFOiknhnbcHnOiJ)fkHIu3mudbfXN6PPmOOHcdPKzoAQxa9(2aJE2xUK4rcWI61JEXu(7fqVgUGlJ4h7fqVN2uMJMyGOxmuSERHCP8vqrCG5As82aJEfeCWe6HGdMycbFOiknhnbcHnOiJ)fkHICrOmudbfXN6PPmOOHcdPKzoAQxa9(2aJE2xUK4rcWI61JEXelm41lGEnCbxgXp2lGEpTPmhnXarVyOy9wd5s5RGI4aZ1K4Tbg9ki4Gj0dbhmbce8HIO0C0eie2GIm(xOeks9KwBJiOTHGI4t90ugu0qHHuYmhn1lGEFBGrp7lxs8ibyr96rVyk)9gtVd5AvQ6fqVgUGlJ4h7fqVN2uMJMyGOxmuSERHCP8vqrCG5As82aJEfeCWe6HGdMybc(qruAoAcecBqr8PEAkdkYWfCze)iuKX)cLqrb0Wjbkis7Vdb9qWbtSdc(qruAoAcecBqr8PEAkdkYBVexx4kIvPWsG7vsQxIRlCfXuiTnIkfy2RKuVexx4kIPVPnIkfy2RVEb0R3EXOxo6KslFwwWK9IGr9kj1l4ClqwIeCqvVss96Txt9JPf4i)00RN9gBWRxa96T3tBkZrtm(uFI(lEVss9AQFmTah5NME9SxSixVss9EAtzoAIvkHHOE91lGE927PnL5OjghLNOJKaKuaN8Eb0lg9YriniYFY4O8eDKeVmsOWRPEf7I3RKuVy07PnL5OjghLNOJKaKuaN8Eb0lg9YriniYFY4MOso7I3RVE91RVEb0R3E5iKge5pzCtujNnKRvPQxp6flY1RKuVGZTazjsWbv9kj1RP(X0cCKFA61JEJn56fqVCesdI8NmUjQKZU49cOxV9YriniYFYixCKFAeoOeKnKRvPQxp714FHsM6TjudXi5r87tIVCPELK6fJE5OtkT8zhbEkl71xVss9w5tdosBpbkcfmzVyixRsvVE2lMY1RVEb0R3EbrpZan8VojHYVnUcqZ1GrSHCTkv96rVyxVss9IrVC0jLw(SK4dsJgWE9bfz8Vqjuu4oalqbbPVjb9qWbt4bbFOiknhnbcHnOi(upnLbf5TxIRlCfX030grsY77vsQxIRlCfXuiTnIKK33RKuVexx4kIzjWIKK33RKuVo3qG5yAl5KafeMwlEzvctjs7VdXgY1Qu1Rh9IDm41RKuVo3qG5yAl5KafeMwlEzvctjSHBjXgY1Qu1Rh9IDm41RKuVM6htlWr(PPxp6n2KRxa9YriniYFY4MOsoBide4Eb0lg9co3cKLibhu1RVEb0R3E5iKge5pzCtujNnKRvPQxp6flY1RKuVCesdI8NmUjQKZgYabUxF9kj1BLpn4iT9eOiuWK9IHCTkv96zVykhuKX)cLqrKloYpnchucc9qWbt5hc(qruAoAcecBqr8PEAkdkcJEbNBbYsKGdQ6fqVN2uMJMyCqbhLG1xOSxa96TxV9AQFmTah5NME9O3ytUEb0R3EDUHa7yLGdbkixCKFACP8fusdS6qe7I3RKuVy0lhDsPLp7iWtzzV(6vsQxNBiWC0ieO(QE2fVxa96CdbMJgHa1x1ZgY1Qu1RN9ce56nME92lhLG36z4dXlfjmDblDP8zF5sIttFPE91RVELK6TYNgCK2EcuekyYEXqUwLQE9SxGixVX0R3E5Oe8wpdFiEPiHPlyPlLp7lxsCA6l1RVELK6LJoP0YNLfmzViyuV(6fqVE7fJE5OtkT8zzbt2lcg1RKuVN2uMJMyCuEIoscqsbCY7vsQxocPbr(tghLNOJK4LrcfEn1RydzGa3RpOiJ)fkHI4KMuFzAHPlyPlLp0dbhmpCi4dfrP5OjqiSbfXN6PPmOim6fCUfilrcoOQxa9EAtzoAIXbfCucwFHYEb0R3E92RP(X0cCKFA61JEJn56fqVE715gcSJvcoeOGCXr(PXLYxqjnWQdrSlEVss9IrVC0jLw(SJapLL96RxjPEDUHaZrJqG6R6zx8Eb0RZneyoAecuFvpBixRsvVE2lwKR3y61BVCucERNHpeVuKW0fS0LYN9Lljon9L61xV(6vsQ3kFAWrA7jqrOGj7fd5AvQ61ZEXIC9gtVE7LJsWB9m8H4LIeMUGLUu(SVCjXPPVuV(6vsQxo6KslFwwWK9IGr96Rxa96Txm6LJoP0YNLfmzViyuVss9EAtzoAIXr5j6ijajfWjVxjPE5iKge5pzCuEIosIxgju41uVInKbcCV(GIm(xOekQsUnP9fkHEi4Gjwdc(qruAoAcecBqriCOif9qrg)lucfDAtzoAck600xckI46cxrSkf6BAtVhwVyTEHBVg)luYuVnHAigjpIFFs8Ll1Bm9IrVexx4kIvPqFtB69W6v(7fU9A8VqjZ)yVmgjpIFFs8Ll1Bm9khdi9c3Ev4KwlKzQNGIoTrKMlbfzk8yj0erCOhcoygBqWhkIsZrtGqydkIp1ttzqrE7TYNgCK2EcuekyYEXqUwLQE9SxSRxjPE92RZneyJDsj6QeHHYdbmBixRsvVE2lmoiZ1KxVhwVCQ096Txt9JPf4i)00lC7flY1RVEb0RZneyJDsj6QeHHYdbm7I3RVE91RKuVE71u)yAboYpn9gtVN2uMJMyMcpwcnreV3dRxNBiWiUUWvKqH02WgY1Qu1Bm9cIEw4oalqbbPVjX(IFujgY1QS3dRxGWGxVE0lMarUELK61u)yAboYpn9gtVN2uMJMyMcpwcnreV3dRxNBiWiUUWvKqFtByd5AvQ6nMEbrplChGfOGG03KyFXpQed5Av27H1lqyWRxp6ftGixV(6fqVexx4kIvPWsG7fqVE71BVy0lhH0Gi)jJBIk5SlEVss9YrNuA5Zoc8uw2lGEXOxocPbr(tg5IJ8tJWbLGSlEV(6vsQxo6KslFwwWK9IGr96Rxa96Txm6LJoP0YNDs5ld4PxjPEXOxNBiW4MOso7I3RKuVM6htlWr(PPxp6n2KRxF9kj1RZneyCtujNnKRvPQxp6fR1lGEXOxNBiWg7Ks0vjcdLhcy2fhkY4FHsOi1BJ6oWiOhcoaroi4dfrP5OjqiSbfXN6PPmOiV96CdbgX1fUIe6BAd7I3RKuVE7LlZgyKQ349cKEb07qCz2aJeF5s96zVWRxF9kj1lxMnWivVX7fl96Rxa9A4cUmIFekY4FHsOOK8lCrOe6HGdqWec(qruAoAcecBqr8PEAkdkYBVo3qGrCDHRiH(M2WU49kj1R3E5YSbgP6nEVaPxa9oexMnWiXxUuVE2l861xVss9YLzdms1B8EXsV(6fqVgUGlJ4hHIm(xOeksMPdcxekHEi4aeGabFOiknhnbcHnOi(upnLbf5TxNBiWiUUWvKqFtByx8ELK61BVCz2aJu9gVxG0lGEhIlZgyK4lxQxp7fE96RxjPE5YSbgP6nEVyPxF9cOxdxWLr8Jqrg)lucffUATWfHsOhcoablqWhkY4FHsOi)2mfAeOGG03KGIO0C0eie2GEi4aeSdc(qruAoAcecBqr8PEAkdkI46cxrSkf6BAtVss9sCDHRiMcPTrKK8(ELK6L46cxrmlbwKK8(ELK615gcm)2mfAeOGG03Kyx8Eb0RZneyexx4ksOVPnSlEVss96TxNBiW4MOsoBixRsvVE2RX)cLm)J9YyK8i(9jXxUuVa615gcmUjQKZU496dkY4FHsOi1BtOgc6HGdqGhe8HIm(xOekY)yVmOiknhnbcHnOhcoar(HGpueLMJMaHWguKX)cLqrZnfg)luk0L6HI0L6fP5sqrbtRFzZf6HEOhk6KgvHsi4ae5acMYHjMycf53MSsykOiSpy)y1Gd2x4elnw0BVWxg1B5IJMV3aA6fRdoK56ujiny9EhkwV1qG9QqUuV29rU2tG9YLzjmsX6dWkvs9ILyrVXokpP5jWEJk3yVxfW5BYRx5R3h1lw5A9cwNLQqzViCAShn96fU(61lMYZhRpaRuj1lMajw0BSJYtAEcS3OYn27vbC(M86v(KVEFuVyLR1Rlc8QVQEr40ypA61R85RxVykpFS(aSsLuVyILyrVXokpP5jWEJk3yVxfW5BYRx5t(69r9IvUwVUiWR(Q6fHtJ9OPxVYNVE9IP88X6dWkvs9IP8hl6n2r5jnpb2Bu5g79QaoFtE9kF9(OEXkxRxW6Sufk7fHtJ9OPxVW1xVEXuE(y9b9byFW(XQbhSVWjwASO3EHVmQ3YfhnFVb00lwhKc2v)y9EhkwV1qG9QqUuV29rU2tG9YLzjmsX6dWkvs9k)XIEJDuEsZtG9gvUXEVkGZ3KxVYxVpQxSY16fSolvHYEr40ypA61lC91RxGipFS(aSsLuVyIzSO3yhLN08eyVy95MuanWigwDSEVpQxS(CtkGgyedRoJsZrtGy9E9ce55J1h0hG9b7hRgCW(cNyPXIE7f(YOElxC089gqtVyD8H4ixh7X69ouSERHa7vHCPET7JCTNa7LlZsyKI1hGvQK6fEXIEJDuEsZtG9I1NBsb0aJyy1X69(OEX6ZnPaAGrmS6mknhnbI171lMYZhRpaRuj1R8hl6n2r5jnpb2lwFUjfqdmIHvhR37J6fRp3KcObgXWQZO0C0eiwVxVykpFS(G(aSpy)y1Gd2x4elnw0BVWxg1B5IJMV3aA6fRBicR37qX6TgcSxfYL61UpY1EcSxUmlHrkwFawPsQxSel6n2r5jnpb2lwFUjfqdmIHvhR37J6fRp3KcObgXWQZO0C0eiwVxVykpFS(aSsLuVWlw0BSJYtAEcS3OYn27vbC(M86v(KVEFuVyLR1Rlc8QVQEr40ypA61R85RxVykpFS(aSsLuVhESO3yhLN08eyVrLBS3Rc48n51R817J6fRCTEbRZsvOSxeon2JME9cxF96ft55J1hGvQK6ft5If9g7O8KMNa7nQCJ9EvaNVjVELVEFuVyLR1lyDwQcL9IWPXE00Rx46RxVykpFS(aSsLuVyIDXIEJDuEsZtG9gvUXEVkGZ3KxVYN817J6fRCTEDrGx9v1lcNg7rtVELpF96ft55J1hGvQK6fZylw0BSJYtAEcS3OYn27vbC(M86v(69r9IvUwVG1zPku2lcNg7rtVEHRVE9IP88X6dWkvs9cemJf9g7O8KMNa7nQCJ9EvaNVjVELVEFuVyLR1lyDwQcL9IWPXE00Rx46RxVykpFS(aSsLuVar(Jf9g7O8KMNa7nQCJ9EvaNVjVELVEFuVyLR1lyDwQcL9IWPXE00Rx46RxVarE(y9b9byFW(XQbhSVWjwASO3EHVmQ3YfhnFVb00lwx9y9EhkwV1qG9QqUuV29rU2tG9YLzjmsX6dWkvs9IPCXIEJDuEsZtG9gvUXEVkGZ3KxVYN817J6fRCTEDrGx9v1lcNg7rtVELpF96ft55J1hGvQK6ftmJf9g7O8KMNa7nQCJ9EvaNVjVELp5R3h1lw5A96IaV6RQxeon2JME9kF(61lMYZhRpaRuj1lMXwSO3yhLN08eyVrLBS3Rc48n51R817J6fRCTEbRZsvOSxeon2JME9cxF96ft55J1h0hG9b7hRgCW(cNyPXIE7f(YOElxC089gqtVyDhK9y9EhkwV1qG9QqUuV29rU2tG9YLzjmsX6dWkvs9Ijwlw0BSJYtAEcS3OYn27vbC(M86v(69r9IvUwVG1zPku2lcNg7rtVEHRVE9If55J1hGvQK6fZylw0BSJYtAEcS3OYn27vbC(M86v(69r9IvUwVG1zPku2lcNg7rtVEHRVE9IP88X6d6dW(6IJMNa79W714FHYE1L6vS(aOi8bfknbfHv1l2mTLCQ3y5MBb2hGv17bwETb4EX8WbAVaroGGzFqFawvVXUmlHrQyrFawvVyVEX(bbjWEJqAB6fBK5Y6dWQ6f71BSlZsyeyVVnWOxuHE5MIu9(OE5aZ1K4Tbg9kwFawvVyVEXQrUOtcS3BMeNukBaU3tBkZrtQE9wmIb0EXh6uOEBu3bg1l2ZJEXh6KPEBu3bg5J1hGv1l2RxS)tub2l(qCt9vcRxSpJ9Y6Tc9wpwx17lJ61)Gsy9gldxx4kI1hGv1l2R3yzTJuVXokprhPEFzuVr41uVQxRxD9VM61fnuVbnjVYrt96Tc9cm62RmdmX6FVYQV367vvUx9BjHUknW96VEz9ITy5X(HFVX0BStAs9LP7f7xxWsxkFG2B9yDWEvhlCFS(G(aJ)fkvm8H4ixh7JFSsWHafk8AQx1hy8VqPIHpeh56yFmXHRlcLhRueqJBFGX)cLkg(qCKRJ9XehU(h7LbuDLKGdght5aAfI7L46cxrm9nTrKK8EjjIRlCfXQuOVPnssexx4kIvPWb9YKKiUUWveZsGfjjV3xFGX)cLkg(qCKRJ9XehU(h7Lb0ke3lX1fUIy6BAJij59ssexx4kIvPqFtBKKiUUWveRsHd6LjjrCDHRiMLalssEVpa4dDYWK5FSxgamWh6KbeM)XEz9bg)luQy4dXrUo2htC4QEBc1qaTcXXyUjfqdmI5yAl5KafeMwlEzvctjjHbhDsPLpllyYErWijjmu4KwlEBGrVIPEBcMwhhtjjmEtt5Zs7VdPeoM2soXO0C0eyFGX)cLkg(qCKRJ9XehUQ3g1DGraTcXNBsb0aJyoM2sojqbHP1IxwLWua4OtkT8zzbt2lcgbqHtAT4Tbg9kM6TjyADCm7d6dWQ6nwg5r87tG9sN0aCVF5s9(YOEn(JMElvV2PvAZrtS(aJ)fkvXviTnchYC7dm(xOuf)0MYC0eqtZLIxkHHiGEA6lfxHtAT4Tbg9kM6TjyAThycWlgVPP8zQ3gnAazuAoAcus6nnLpt9KwBJaCQWZO0C0eOpjjfoP1I3gy0RyQ3MGP1EaK(aJ)fkvXehUN2uMJMaAAUu8sj4AYojGEA6lfxHtAT4Tbg9kM6Tjud5bM9bg)luQIjoCDOrrZXkHb0ke3lgC0jLw(SSGj7fbJKKWGJqAqK)KXr5j6ijEzKqHxt9k2f3haNBiW4MOso7I3hy8VqPkM4Wfh9fkbAfI7Cdbg3evYzx8(aJ)fkvXehUN2uMJMaAAUuCokprhjbiPao5a900xkoNkTxVv(0GJ02tGIqbt2lgY1QuH9WeEypocPbr(tg3evYzd5AvQ8jFyI1KZxCovAVER8PbhPTNafHcMSxmKRvPc7Hj8WEyce5WECesdI8NmokprhjXlJek8AQxXgY1Qu5t(WeRjNpjjocPbr(tg3evYzd5AvQ8OYNgCK2EcuekyYEXqUwLkjjocPbr(tghLNOJK4LrcfEn1Ryd5AvQ8OYNgCK2EcuekyYEXqUwLkjjm4OtkT8zzbt2lcg1hy8VqPkM4W90MYC0eqtZLIZbfCucwFHsGEA6lf3lguSElCCcKrU4apKPfObmTKtssCesdI8NmYfh4HmTanGPLCInKRvPYtmLF5aGbhH0Gi)jJCXbEitlqdyAjNydzGa7tsIJoP0YNDe4PSSpW4FHsvmXH7vrI6jxGMMlfNCXbEitlqdyAjNaAfIZriniYFY4MOsoBixRsLNaroaCesdI8NmokprhjXlJek8AQxXgY1Qu5jqKtskuWK9IHCTkvEILdVpW4FHsvmXH7vrI6jxGMMlfxHUAn9FLWeZ1byGwH4CesdI8NmUjQKZgY1Qu5P8daJtBkZrtmokprhjbiPao5ssCesdI8NmokprhjXlJek8AQxXgY1Qu5P8d40MYC0eJJYt0rsaskGtUKuOGj7fd5AvQ8eiWRpW4FHsvmXH7vrI6jxGMMlfVsfFUV5OjrSET8VUcq6S4eqRqCNBiW4MOso7I3hGv1RX)cLQyId3RIe1tUkGQ0Oxf)NkpspMaTcXX4NkpspdtMmtjWheNzjWa8IXpvEKEgqyYmLaFqCMLaljHXpvEKEgqydzGal4iKge5p9jj5Cdbg3evYzxCjjocPbr(tg3evYzd5AvQWEykNh)u5r6zyY4iKge5pzG3X(cLaWGJoP0YNDe4PSusIJoP0YNLfmzViyeGtBkZrtmokprhjbiPao5a4iKge5pzCuEIosIxgju41uVIDXLKCUHa7yLGdbkixCKFACP8fusdS6qe7IljfkyYEXqUwLkpbIC9byv9A8VqPkM4W9Qir9KRcOkn6vX)PYJ0deGwH4y8tLhPNbeMmtjWheNzjWa8IXpvEKEgMmzMsGpioZsGLKW4Nkpspdt2qgiWcocPbr(tFss)u5r6zyYKzkb(G4mlbgWpvEKEgqyYmLaFqCMLadaJFQ8i9mmzdzGal4iKge5pLKCUHaJBIk5SlUKehH0Gi)jJBIk5SHCTkvypmLZJFQ8i9mGW4iKge5pzG3X(cLaWGJoP0YNDe4PSusIJoP0YNLfmzViyeGtBkZrtmokprhjbiPao5a4iKge5pzCuEIosIxgju41uVIDXLKCUHa7yLGdbkixCKFACP8fusdS6qe7IljfkyYEXqUwLkpbIC9bg)luQIjoCVksup5QaAfI7Cdbg3evYzxCjjo6KslFwwWK9IGraoTPmhnX4O8eDKeGKc4KdGJqAqK)KXr5j6ijEzKqHxt9k2fhagCesdI8NmUjQKZU4a8615gcmIRlCfj030g2qUwLkpWuojjNBiWiUUWvKqH02WgY1Qu5bMY5dagZnPaAGrmhtBjNeOGW0AXlRsykjP5MuanWiMJPTKtcuqyAT4LvjmfaVo3qG5yAl5KafeMwlEzvctjs7VdXuVXp6bwKKCUHaZX0wYjbkimTw8YQeMsyd3sIPEJF0dS4ZNKKZneyhReCiqb5IJ8tJlLVGsAGvhIyxCjPqbt2lgY1Qu5jqKRpW4FHsvmXH7CtHX)cLcDPEGMMlf3qeqv)u8poMaTcXpTPmhnXkLWquFGX)cLQyId35McJ)fkf6s9annxko4qMRtLG0au1pf)JJjqRq85MuanWi2xUKF0KcWHmxNkbPHrX6TWXjW(aJ)fkvXehUZnfg)luk0L6bAAUuChK9av9tX)4yc0keFUjfqdmI5yAl5KafeMwlEzvctXOy9w44eyFGX)cLQyId35McJ)fkf6s9annxkU67d6dm(xOuXmef)0MYC0eqtZLIdoK5k8xATiyATafca900xkUxNBiW(YL8JMuaoK56ujinSHCTkvEcJdYCn5fJCmmLKCUHa7lxYpAsb4qMRtLG0WgY1Qu5PX)cLm1BtOgIrYJ43NeF5sXihdtaEjUUWveRsH(M2ijrCDHRiMcPTrKK8EjjIRlCfXSeyrsY795dGZneyF5s(rtkahYCDQeKg2fhWCtkGgye7lxYpAsb4qMRtLG0WOy9w44eyFGX)cLkMHOyId3tBkZrtannxkEblrdjuVnQ7aJa6PPVuCNBiWiUUWvKqFtByxCaEv4KwlEBGrVIPEBc1qEGDaEtt5ZuORwGcIxgjcOHupJsZrtGsskCsRfVnWOxXuVnHAipKFF9bg)luQygIIjoC5O8eDKeVmsOWRPEfqRqCVN2uMJMyCuEIoscqsbCYbGbhH0Gi)jJBIk5SHmqGLKCUHaJBIk5SlUpaEn1pMwGJ8tJNWtojPtBkZrtScwIgsOEBu3bg5dGxNBiWiUUWvKqFtByd5AvQ8q(LKCUHaJ46cxrcfsBdBixRsLhYVpaEXyUjfqdmI5yAl5KafeMwlEzvctjj5CdbMJPTKtcuqyAT4LvjmLiT)oet9g)OhyrsY5gcmhtBjNeOGW0AXlRsykHnCljM6n(rpWIpjPqbt2lgY1Qu5jMY1hy8VqPIzikM4WvDZqneq5aZ1K4Tbg9Q4yc0ke37qHHuYmhnjj5CdbgX1fUIekK2g2qUwLkpXcaIRlCfXQuOqABamKRvPYtmXoaVPP8zk0vlqbXlJeb0qQNrP5OjqFaEBGrp7lxs8ibyrEGj2H9u4KwlEBGrVkMHCTkva8sCDHRiwLclbwsAixRsLNW4GmxtE(6dm(xOuXmeftC4QEBcMwd0ke3RZneyQ3MGP1SHcdPKzoAcGxfoP1I3gy0RyQ3MGP1EIfjjmMBsb0aJyF5s(rtkahYCDQeKggfR3chNa9jj9MMYNPqxTafeVmseqdPEgLMJMab4CdbgX1fUIekK2g2qUwLkpXcaIRlCfXQuOqABa4CdbM6TjyAnBixRsLNhoafoP1I3gy0RyQ3MGP1Eeh78bWlgZnPaAGrmnWCBmLiOj6ReMaMUCXveJI1BHJtGssF5sYN8HDWZdNBiWuVnbtRzd5AvQIbi(a82aJE2xUK4rcWI8aE9bg)luQygIIjoCvVnbtRbAfIp3KcObgX(YL8JMuaoK56ujinmkwVfoobcqHtAT4Tbg9kM6TjyAThXXcaVy4Cdb2xUKF0KcWHmxNkbPHDXb4CdbM6TjyAnBOWqkzMJMKK8EAtzoAIboK5k8xATiyATafca86CdbM6TjyAnBixRsLNyrssHtAT4Tbg9kM6TjyAThabWBAkFM6jT2gb4uHNrP5Ojqao3qGPEBcMwZgY1Qu5j885ZxFGX)cLkMHOyId3tBkZrtannxkU6TjyATWpkFrW0Abkea6PPVuCt9JPf4i)04bwtoSNxmL7WCUHa7lxYpAsb4qMRtLG0WuVXp6d7515gcm1BtW0A2qUwLQddlYNcN0AHmt9KpSNxq0Zc3bybkii9nj2qUwLQddE(a4CdbM6TjyAn7I3hy8VqPIzikM4Wv92OUdmcOvi(PnL5Ojg4qMRWFP1IGP1cuia40MYC0et92emTw4hLViyATafcaW40MYC0eRGLOHeQ3g1DGrssEDUHaZX0wYjbkimTw8YQeMsK2FhIPEJF0dSij5CdbMJPTKtcuqyAT4LvjmLWgULet9g)OhyXhafoP1I3gy0RyQ3MGP1EID9bg)luQygIIjoCnqd)RtsO8BJlq5aZ1K4Tbg9Q4yc0kehJV4hRegamm(xOKzGg(xNKq53gxbO5AWiwLIGUGj7LKarpZan8VojHYVnUcqZ1Grm1B8JEIfaGONzGg(xNKq53gxbO5AWi2qUwLkpXsFGX)cLkMHOyIdxxekd1qaLdmxtI3gy0RIJjqRq8HcdPKzoAcWBdm6zF5sIhjalYdVyIDX4vHtAT4Tbg9kM6TjudDyyYGNpFYNcN0AXBdm6vXmKRvPcGxVCesdI8NmUjQKZgYabgagGZTazjsWbva8EAtzoAIXr5j6ijajfWjxsIJqAqK)KXr5j6ijEzKqHxt9k2qgiWssyWrNuA5ZYcMSxemYNKKcN0AXBdm6vm1BtOgYtVW7W8IzmVPP8zV)kfUiuQyuAoAc0NpjjVexx4kIvPqH02ij5L46cxrSkfoOxMKeX1fUIyvk030gFaW4nnLptHUAbkiEzKiGgs9mknhnbkj5Cdbg(uUObSmTWgULfxGF1kByNM(sEehiWtoFa8QWjTw82aJEft92eQH8et5omVygZBAkF27VsHlcLkgLMJMa95dGP(X0cCKFA8aEYH9CUHat92emTMnKRvP6WKFFa8IHZneyhReCiqb5IJ8tJlLVGsAGvhIyxCjjIRlCfXQuOqABKKWGJoP0YNDe4PS0hadxWLr8J(6dm(xOuXmeftC4gqdNeOGiT)oeqRqCdxWLr8J9bg)luQygIIjoCh7Ks0vjcdLhcyGwH4o3qGXnrLC2fVpW4FHsfZqumXHlN0K6ltlmDblDP8bAfIJb4ClqwIeCqfGtBkZrtmoOGJsW6lucWRZneyQ3MGP1SlUKKP(X0cCKFA8aEY5dago3qGPqA1xCIDXbGHZneyCtujNDXb4fdo6KslFwwWK9IGrssN2uMJMyCuEIoscqsbCYLK4iKge5pzCuEIosIxgju41uVIDXLKQ8PbhPTNafHcMSxmKRvPYtGixmE5Oe8wpdFiEPiHPlyPlLp7lxsCA6l5ZxFGX)cLkMHOyId3k52K2xOeOviogGZTazjsWbvaoTPmhnX4GcokbRVqjaVo3qGPEBcMwZU4ssM6htlWr(PXd4jNpay4CdbMcPvFXj2fhago3qGXnrLC2fhGxm4OtkT8zzbt2lcgjjDAtzoAIXr5j6ijajfWjxsIJqAqK)KXr5j6ijEzKqHxt9k2fxsQYNgCK2EcuekyYEXqUwLkp5iKge5pzCuEIosIxgju41uVInKRvPkg5xsQYNgCK2EcuekyYEXqUwLk5t(WeRjNNyrUy8Yrj4TEg(q8srctxWsxkF2xUK400xYNV(aJ)fkvmdrXehUKloYpnchucc0keVYNgCK2EcuekyYEXqUwLkpXeEssEDUHadFkx0awMwyd3YIlWVALnSttFjpbc8KtsY5gcm8PCrdyzAHnCllUa)Qv2Won9L8ioqGNC(a4CdbM6TjyAn7IdWlhH0Gi)jJBIk5SHCTkvEap5KKaNBbYsKGdQ81hy8VqPIzikM4Wv9KwBJiOTHakhyUMeVnWOxfhtGwH4dfgsjZC0eGVCjXJeGf5bMWdGcN0AXBdm6vm1BtOgYtSdGHl4Yi(raEDUHaJBIk5SHCTkvEGPCssy4Cdbg3evYzxCF9bg)luQygIIjoCd3bybkii9njGwH4exx4kIvPWsGby4cUmIFeGZney4t5IgWY0cB4wwCb(vRSHDA6l5jqGNCa8cIEMbA4FDscLFBCfGMRbJyFXpwjmjjm4OtkT8zjXhKgnGsskCsRfVnWOx5bq81hy8VqPIzikM4Wv92emTgOviUZneyOKEzkbonCc)luYU4a86CdbM6TjyAnBOWqkzMJMKKm1pMwGJ8tJhXMC(6dm(xOuXmeftC4QEBcMwd0keNJoP0YNLfmzViyeaVN2uMJMyCuEIoscqsbCYLK4iKge5pzCtujNDXLKCUHaJBIk5SlUpaCesdI8NmokprhjXlJek8AQxXgY1Qu5jmoiZ1K3HXPs71u)yAboYpnYh8KZhaNBiWuVnbtRzd5AvQ8e7aGb4ClqwIeCqvFGX)cLkMHOyIdx1BJ6oWiGwH4C0jLw(SSGj7fbJa490MYC0eJJYt0rsaskGtUKehH0Gi)jJBIk5SlUKKZneyCtujNDX9bGJqAqK)KXr5j6ijEzKqHxt9k2qUwLkpLFao3qGPEBcMwZU4aiUUWveRsHLadaJtBkZrtScwIgsOEBu3bgbadW5wGSej4GQ(aJ)fkvmdrXehUQ3g1DGraTcXDUHadL0ltj4AYgXzPkuYU4ssEXq92eQHygUGlJ4hLK86Cdbg3evYzd5AvQ8eEaCUHaJBIk5SlUKKxNBiWg7Ks0vjcdLhcy2qUwLkpHXbzUM8omovAVM6htlWr(Pr(WIC(a4Cdb2yNuIUkryO8qaZU4(8b40MYC0et92emTw4hLViyATafcau4KwlEBGrVIPEBcMw7jw8bWlgZnPaAGrSVCj)OjfGdzUovcsdJI1BHJtGsskCsRfVnWOxXuVnbtR9el(6dm(xOuXmeftC4MKFHlcLaTcX9sCDHRiwLclbgahH0Gi)jJBIk5SHCTkvEap5KK8YLzdmsfhiagIlZgyK4lxYt45tsIlZgyKkow8bWWfCze)yFGX)cLkMHOyIdxzMoiCrOeOviUxIRlCfXQuyjWa4iKge5pzCtujNnKRvPYd4jNKKxUmBGrQ4abWqCz2aJeF5sEcpFssCz2aJuXXIpagUGlJ4h7dm(xOuXmeftC4gUATWfHsGwH4EjUUWveRsHLadGJqAqK)KXnrLC2qUwLkpGNCssE5YSbgPIdeadXLzdms8Ll5j88jjXLzdmsfhl(ay4cUmIFSpW4FHsfZqumXHRFBMcncuqq6Bs9bg)luQygIIjoCpTPmhnb00CP4Q3MqnKOsHcPTbONM(sXv4KwlEBGrVIPEBc1qEGDXe0i0411upnalon9LommLto5diY5lMGgHgVo3qGPEBu3bgjixCKFACP8fkK2gM6n(r5d781hy8VqPIzikM4W1)yVmGwH4exx4kIPVPnIKK3ljrCDHRiMLalssEpGtBkZrtSsj4AYojjjNBiWiUUWvKqH02WgY1Qu5PX)cLm1BtOgIrYJ43NeF5saCUHaJ46cxrcfsBd7IljrCDHRiwLcfsBdamoTPmhnXuVnHAirLcfsBJKKZneyCtujNnKRvPYtJ)fkzQ3MqneJKhXVpj(YLaGXPnL5OjwPeCnzNeaNBiW4MOsoBixRsLNK8i(9jXxUeaNBiW4MOso7Ilj5Cdb2yNuIUkryO8qaZU4au4KwlKzQN8qoM8dWRcN0AXBdm6vEghlssy8MMYNPqxTafeVmseqdPEgLMJMa9jjHXPnL5OjwPeCnzNeaNBiW4MOsoBixRsLhK8i(9jXxUuFGX)cLkMHOyIdx1BtOgQpW4FHsfZqumXH7CtHX)cLcDPEGMMlfpyA9lBU9b9bg)luQyoi7Jp2jLORsegkpeWaTcXDUHaJBIk5SlEFGX)cLkMdY(yId3tBkZrtannxkoFQpr)fhONM(sXXW5gcmhtBjNeOGW0AXlRsykrA)Di2fhago3qG5yAl5KafeMwlEzvctjSHBjXU49bg)luQyoi7JjoCnqd)RtsO8BJlq5aZ1K4Tbg9Q4yc0ke35gcmhtBjNeOGW0AXlRsykrA)DiM6n(rpXoao3qG5yAl5KafeMwlEzvctjSHBjXuVXp6j2bWlgGONzGg(xNKq53gxbO5AWi2x8Jvcdagg)luYmqd)RtsO8BJRa0CnyeRsrqxWK9a8Ibi6zgOH)1jju(TXviJmn7l(XkHjjbIEMbA4FDscLFBCfYitZgY1Qu5bw8jjbIEMbA4FDscLFBCfGMRbJyQ34h9elaarpZan8VojHYVnUcqZ1GrSHCTkvEcpaGONzGg(xNKq53gxbO5AWi2x8JvcZxFGX)cLkMdY(yIdxokprhjXlJek8AQxb0ke37PnL5OjghLNOJKaKuaNCayWriniYFY4MOsoBideyjjNBiW4MOso7I7dGxNBiWCmTLCsGcctRfVSkHPeP93HyQ34hJdpjjNBiWCmTLCsGcctRfVSkHPe2WTKyQ34hJdpFssHcMSxmKRvPYtmLRpW4FHsfZbzFmXHl3soPfo3qaOP5sXvVnA0ac0ke3RZneyoM2sojqbHP1IxwLWuI0(7qSHCTkvEGDm4jj5CdbMJPTKtcuqyAT4LvjmLWgULeBixRsLhyhdE(ayQFmTah5NgpIhBYbWlhH0Gi)jJBIk5SHCTkvEC4ssE5iKge5pzKloYpnchucYgY1Qu5XHdadNBiWowj4qGcYfh5NgxkFbL0aRoeXU4a4OtkT8zhbEkl95RpW4FHsfZbzFmXHR6TjyAnqRq830u(m1tATncWPcpJsZrtGau0)vctXuinsaov4b4CdbM6TjyAnde5p7dm(xOuXCq2htC4QEBu3bgb0kehJtBkZrtm(uFI(loaVC0jLw(SSGj7fbJKK4iKge5pzCtujNnKRvPYJdxscJtBkZrtmoOGJsW6lucado6KslF2rGNYsjjVCesdI8NmYfh5NgHdkbzd5AvQ84WbGHZneyhReCiqb5IJ8tJlLVGsAGvhIyxCaC0jLw(SJapLL(81hy8VqPI5GSpM4Wv92OUdmcOviUxocPbr(tghLNOJK4LrcfEn1Ryd5AvQ8eEaWaCUfilrcoOcG3tBkZrtmokprhjbiPao5ssCesdI8NmUjQKZgY1Qu5j88b40MYC0eJdk4OeS(cL(ayQFmTah5NgpWo5aWrNuA5ZYcMSxemcagGZTazjsWbv9bg)luQyoi7JjoCpTPmhnb00CP4GOxmuSERHCP8va900xkUxNBiW4MOsoBixRsLhWdGxNBiWg7Ks0vjcdLhcy2qUwLkpGNKego3qGn2jLORsegkpeWSlUpjjmCUHaJBIk5SlUpaEXW5gcSJvcoeOGCXr(PXLYxqjnWQdrSlUpaEDUHaJ46cxrcfsBdBixRsLhW4GmxtEsso3qGrCDHRiH(M2WgY1Qu5bmoiZ1KNV(aJ)fkvmhK9XehUQBgQHakhyUMeVnWOxfhtGwH4dfgsjZC0eG3gy0Z(YLepsawKhyk)amCbxgXpc40MYC0ede9IHI1BnKlLVQpW4FHsfZbzFmXHRlcLHAiGYbMRjXBdm6vXXeOvi(qHHuYmhnb4Tbg9SVCjXJeGf5bMyHbpagUGlJ4hbCAtzoAIbIEXqX6TgYLYx1hy8VqPI5GSpM4Wv9KwBJiOTHakhyUMeVnWOxfhtGwH4dfgsjZC0eG3gy0Z(YLepsawKhyk)XmKRvPcGHl4Yi(raN2uMJMyGOxmuSERHCP8v9bg)luQyoi7JjoCdOHtcuqK2FhcOviUHl4Yi(X(aJ)fkvmhK9XehUH7aSafeK(MeqRqCVexx4kIvPWsGLKiUUWvetH02iQuGPKeX1fUIy6BAJOsbM(a4fdo6KslFwwWK9IGrssGZTazjsWbvssEn1pMwGJ8tJNXg8a490MYC0eJp1NO)IljzQFmTah5NgpXICssN2uMJMyLsyiYhaVN2uMJMyCuEIoscqsbCYbGbhH0Gi)jJJYt0rs8YiHcVM6vSlUKegN2uMJMyCuEIoscqsbCYbGbhH0Gi)jJBIk5SlUpF(a4LJqAqK)KXnrLC2qUwLkpWICssGZTazjsWbvssM6htlWr(PXJytoaCesdI8NmUjQKZU4a8YriniYFYixCKFAeoOeKnKRvPYtJ)fkzQ3MqneJKhXVpj(YLKKWGJoP0YNDe4PS0NKuLpn4iT9eOiuWK9IHCTkvEIPC(a4fe9md0W)6Kek)24kanxdgXgY1Qu5b2jjHbhDsPLplj(G0Ob0xFGX)cLkMdY(yIdxYfh5NgHdkbbAfI7L46cxrm9nTrKK8EjjIRlCfXuiTnIKK3ljrCDHRiMLalssEVKKZneyoM2sojqbHP1IxwLWuI0(7qSHCTkvEGDm4jj5CdbMJPTKtcuqyAT4LvjmLWgULeBixRsLhyhdEssM6htlWr(PXJytoaCesdI8NmUjQKZgYabgagGZTazjsWbv(a4LJqAqK)KXnrLC2qUwLkpWICssCesdI8NmUjQKZgYab2NKuLpn4iT9eOiuWK9IHCTkvEIPC9bg)luQyoi7JjoC5KMuFzAHPlyPlLpqRqCmaNBbYsKGdQaCAtzoAIXbfCucwFHsaE9AQFmTah5NgpIn5a415gcSJvcoeOGCXr(PXLYxqjnWQdrSlUKegC0jLw(SJapLL(KKCUHaZrJqG6R6zxCao3qG5Oriq9v9SHCTkvEce5IXlhLG36z4dXlfjmDblDP8zF5sIttFjF(KKQ8PbhPTNafHcMSxmKRvPYtGixmE5Oe8wpdFiEPiHPlyPlLp7lxsCA6l5tsIJoP0YNLfmzViyKpaEXGJoP0YNLfmzViyKK0PnL5OjghLNOJKaKuaNCjjocPbr(tghLNOJK4LrcfEn1RydzGa7RpW4FHsfZbzFmXHBLCBs7luc0kehdW5wGSej4GkaN2uMJMyCqbhLG1xOeGxVM6htlWr(PXJytoaEDUHa7yLGdbkixCKFACP8fusdS6qe7IljHbhDsPLp7iWtzPpjjNBiWC0ieO(QE2fhGZneyoAecuFvpBixRsLNyrUy8Yrj4TEg(q8srctxWsxkF2xUK400xYNpjPkFAWrA7jqrOGj7fd5AvQ8elYfJxokbV1ZWhIxksy6cw6s5Z(YLeNM(s(KK4OtkT8zzbt2lcg5dGxm4OtkT8zzbt2lcgjjDAtzoAIXr5j6ijajfWjxsIJqAqK)KXr5j6ijEzKqHxt9k2qgiW(6dm(xOuXCq2htC4EAtzoAcOP5sXnfESeAIioqpn9LItCDHRiwLc9nT5WWAYNX)cLm1BtOgIrYJ43NeF5sXGbX1fUIyvk030Mdt(LpJ)fkz(h7LXi5r87tIVCPyKJbe5tHtATqMPEQpW4FHsfZbzFmXHR6TrDhyeqRqCVv(0GJ02tGIqbt2lgY1Qu5j2jj515gcSXoPeDvIWq5HaMnKRvPYtyCqMRjVdJtL2RP(X0cCKFAKpSiNpao3qGn2jLORsegkpeWSlUpFssEn1pMwGJ8ttmN2uMJMyMcpwcnre)WCUHaJ46cxrcfsBdBixRsvmGONfUdWcuqq6BsSV4hvIHCTkpmGWGNhyce5KKm1pMwGJ8ttmN2uMJMyMcpwcnre)WCUHaJ46cxrc9nTHnKRvPkgq0Zc3bybkii9nj2x8JkXqUwLhgqyWZdmbIC(aqCDHRiwLclbgGxVyWriniYFY4MOso7IljXrNuA5Zoc8uwcadocPbr(tg5IJ8tJWbLGSlUpjjo6KslFwwWK9IGr(a4fdo6KslF2jLVmGhjjmCUHaJBIk5SlUKKP(X0cCKFA8i2KZNKKZneyCtujNnKRvPYdSgamCUHaBStkrxLimuEiGzx8(aJ)fkvmhK9XehUj5x4IqjqRqCVo3qGrCDHRiH(M2WU4ssE5YSbgPIdeadXLzdms8Ll5j88jjXLzdmsfhl(ay4cUmIFSpW4FHsfZbzFmXHRmtheUiuc0ke3RZneyexx4ksOVPnSlUKKxUmBGrQ4abWqCz2aJeF5sEcpFssCz2aJuXXIpagUGlJ4h7dm(xOuXCq2htC4gUATWfHsGwH4EDUHaJ46cxrc9nTHDXLK8YLzdmsfhiagIlZgyK4lxYt45tsIlZgyKkow8bWWfCze)yFGX)cLkMdY(yIdx)2mfAeOGG03K6dm(xOuXCq2htC4QEBc1qaTcXjUUWveRsH(M2ijrCDHRiMcPTrKK8EjjIRlCfXSeyrsY7LKCUHaZVntHgbkii9nj2fhGZneyexx4ksOVPnSlUKKxNBiW4MOsoBixRsLNg)luY8p2lJrYJ43NeF5saCUHaJBIk5SlUV(aJ)fkvmhK9XehU(h7L1hy8VqPI5GSpM4WDUPW4FHsHUupqtZLIhmT(Ln3(G(aJ)fkvmWHmxNkbPj(PnL5OjGMMlfxzbs8iXvrcfoP1a900xkUxNBiW(YL8JMuaoK56ujinSHCTkvEaJdYCn5fJCmmb4L46cxrSkfoOxMKeX1fUIyvkuiTnssexx4kIPVPnIKK37tsY5gcSVCj)OjfGdzUovcsdBixRsLhg)luYuVnHAigjpIFFs8LlfJCmmb4L46cxrSkf6BAJKeX1fUIykK2grsY7LKiUUWveZsGfjjV3NpjjmCUHa7lxYpAsb4qMRtLG0WU49bg)luQyGdzUovcstmXHR6TjyAnqRq830u(m1tATncWPcpJsZrtGau0)vctXuinsaov4b4CdbM6TjyAnde5p7dm(xOuXahYCDQeKMyIdx1BJ6oWiGwH4EX40MYC0etzbs8iXvrcfoP1ssEDUHaBStkrxLimuEiGzd5AvQ8eghK5AY7W4uP9AQFmTah5Ng5dlY5dGZneyJDsj6QeHHYdbm7I7ZNKKP(X0cCKFA8i2KRpW4FHsfdCiZ1PsqAIjoC5O8eDKeVmsOWRPEfqRqCVN2uMJMyCuEIoscqsbCYbu5tdosBpbkcfmzVyixRsLhyIf5aGbhH0Gi)jJBIk5SHmqGLKCUHaJBIk5SlUpaM6htlWr(PXtStoaEDUHaJ46cxrc9nTHnKRvPYdmLtsY5gcmIRlCfjuiTnSHCTkvEGPC(KKcfmzVyixRsLNykxFGX)cLkg4qMRtLG0etC4AGg(xNKq53gxGYbMRjXBdm6vXXeOviogGONzGg(xNKq53gxbO5AWi2x8Jvcdagg)luYmqd)RtsO8BJRa0CnyeRsrqxWK9a8Ibi6zgOH)1jju(TXviJmn7l(XkHjjbIEMbA4FDscLFBCfYitZgY1Qu5b88jjbIEMbA4FDscLFBCfGMRbJyQ34h9elaarpZan8VojHYVnUcqZ1GrSHCTkvEIfaGONzGg(xNKq53gxbO5AWi2x8JvcRpW4FHsfdCiZ1PsqAIjoCDrOmudbuoWCnjEBGrVkoMaTcXhkmKsM5OjaVnWON9LljEKaSipWeia8615gcmUjQKZgY1Qu5b8a415gcSXoPeDvIWq5HaMnKRvPYd4jjHHZneyJDsj6QeHHYdbm7I7tscdNBiW4MOso7IljzQFmTah5NgpXIC(a4fdNBiWowj4qGcYfh5NgxkFbL0aRoeXU4ssM6htlWr(PXtSiNpagUGlJ4h91hy8VqPIboK56ujinXehUQBgQHakhyUMeVnWOxfhtGwH4dfgsjZC0eG3gy0Z(YLepsawKhyceaE96Cdbg3evYzd5AvQ8aEa86Cdb2yNuIUkryO8qaZgY1Qu5b8KKWW5gcSXoPeDvIWq5HaMDX9jjHHZneyCtujNDXLKm1pMwGJ8tJNyroFa8IHZneyhReCiqb5IJ8tJlLVGsAGvhIyxCjjt9JPf4i)04jwKZhadxWLr8J(6dm(xOuXahYCDQeKMyIdx1tATnIG2gcOCG5As82aJEvCmbAfIpuyiLmZrtaEBGrp7lxs8ibyrEGP8dWRxNBiW4MOsoBixRsLhWdGxNBiWg7Ks0vjcdLhcy2qUwLkpGNKego3qGn2jLORsegkpeWSlUpjjmCUHaJBIk5SlUKKP(X0cCKFA8elY5dGxmCUHa7yLGdbkixCKFACP8fusdS6qe7IljzQFmTah5NgpXIC(ay4cUmIF0xFGX)cLkg4qMRtLG0etC4gqdNeOGiT)oeqRqCdxWLr8J9bg)luQyGdzUovcstmXH7yNuIUkryO8qad0ke35gcmUjQKZU49bg)luQyGdzUovcstmXHl5IJ8tJWbLGaTcX9615gcmIRlCfjuiTnSHCTkvEGPCsso3qGrCDHRiH(M2WgY1Qu5bMY5dahH0Gi)jJBIk5SHCTkvEGf58jjXriniYFY4MOsoBide4(aJ)fkvmWHmxNkbPjM4WLtAs9LPfMUGLUu(aTcXXaCUfilrcoOcWPnL5OjghuWrjy9fkb41RZneyhReCiqb5IJ8tJlLVGsAGvhIyxCjjm4OtkT8zhbEkl9jjXrNuA5ZYcMSxemss60MYC0eRucdrsso3qG5Oriq9v9SloaNBiWC0ieO(QE2qUwLkpbICX4LJsWB9m8H4LIeMUGLUu(SVCjXPPVKpFaWW5gcmUjQKZU4a8IbhDsPLpllyYErWijjocPbr(tghLNOJK4LrcfEn1RyxCjPkFAWrA7jqrOGj7fd5AvQ8KJqAqK)KXr5j6ijEzKqHxt9k2qUwLQyKFjPkFAWrA7jqrOGj7fd5AvQKp5dtSMCEce5IXlhLG36z4dXlfjmDblDP8zF5sIttFjF(6dm(xOuXahYCDQeKMyId3k52K2xOeOviogGZTazjsWbvaoTPmhnX4GcokbRVqjaVEDUHa7yLGdbkixCKFACP8fusdS6qe7IljHbhDsPLp7iWtzPpjjo6KslFwwWK9IGrssN2uMJMyLsyissY5gcmhncbQVQNDXb4CdbMJgHa1x1ZgY1Qu5jwKlgVCucERNHpeVuKW0fS0LYN9Lljon9L85dago3qGXnrLC2fhGxm4OtkT8zzbt2lcgjjXriniYFY4O8eDKeVmsOWRPEf7Iljv5tdosBpbkcfmzVyixRsLNCesdI8NmokprhjXlJek8AQxXgY1QufJ8ljv5tdosBpbkcfmzVyixRsL8jFyI1KZtSixmE5Oe8wpdFiEPiHPlyPlLp7lxsCA6l5ZxFGX)cLkg4qMRtLG0etC4EAtzoAcOP5sXv2jjcOrWnrLCGEA6lfhdocPbr(tg3evYzdzGaljHXPnL5OjghLNOJKaKuaNCaC0jLw(SSGj7fbJKKaNBbYsKGdQ6dm(xOuXahYCDQeKMyId3WDawGccsFtcOvioX1fUIyvkSeyagUGlJ4hb4fe9md0W)6Kek)24kanxdgX(IFSsyssyWrNuA5ZsIpinAa9b40MYC0etzNKiGgb3evY7dm(xOuXahYCDQeKMyIdx1BJ6oWiGwH4C0jLw(SSGj7fbJaCAtzoAIXr5j6ijajfWjhGP(X0cCKFA8io2jhaocPbr(tghLNOJK4LrcfEn1Ryd5AvQ8eghK5AY7W4uP9AQFmTah5Ng5dlY5dagGZTazjsWbv9bg)luQyGdzUovcstmXHBs(fUiuc0ke3RZneyexx4ksOVPnSlUKKxUmBGrQ4abWqCz2aJeF5sEcpFssCz2aJuXXIpagUGlJ4hbCAtzoAIPStseqJGBIk59bg)luQyGdzUovcstmXHRmtheUiuc0ke3RZneyexx4ksOVPnSloam4OtkT8zhbEklLK86Cdb2XkbhcuqU4i)04s5lOKgy1Hi2fhahDsPLp7iWtzPpjjVCz2aJuXbcGH4YSbgj(YL8eE(KK4YSbgPIJfjjNBiW4MOso7I7dGHl4Yi(raN2uMJMyk7Keb0i4MOsEFGX)cLkg4qMRtLG0etC4gUATWfHsGwH4EDUHaJ46cxrc9nTHDXbGbhDsPLp7iWtzPKKxNBiWowj4qGcYfh5NgxkFbL0aRoeXU4a4OtkT8zhbEkl9jj5LlZgyKkoqamexMnWiXxUKNWZNKexMnWivCSij5Cdbg3evYzxCFamCbxgXpc40MYC0etzNKiGgb3evY7dm(xOuXahYCDQeKMyIdx)2mfAeOGG03K6dm(xOuXahYCDQeKMyIdx1BtOgcOvioX1fUIyvk030gjjIRlCfXuiTnIKK3ljrCDHRiMLalssEVKKZney(Tzk0iqbbPVjXU4aCUHaJ46cxrc9nTHDXLK86Cdbg3evYzd5AvQ804FHsM)XEzmsEe)(K4lxcGZneyCtujNDX91hy8VqPIboK56ujinXehU(h7L1hy8VqPIboK56ujinXehUZnfg)luk0L6bAAUu8GP1VS52h0hy8VqPIfmT(Ln34Q3g1DGraTcXXyUjfqdmI5yAl5KafeMwlEzvctXOy9w44eyFGX)cLkwW06x2CJjoCv3mudbuoWCnjEBGrVkoMaTcXbrpZfHYqneBixRsLhd5AvQ6dm(xOuXcMw)YMBmXHRlcLHAO(G(aJ)fkvm1h3an8VojHYVnUaLdmxtI3gy0RIJjqRqCmarpZan8VojHYVnUcqZ1GrSV4hRegamm(xOKzGg(xNKq53gxbO5AWiwLIGUGj7b4fdq0Zmqd)RtsO8BJRqgzA2x8Jvctsce9md0W)6Kek)24kKrMMnKRvPYd45tsce9md0W)6Kek)24kanxdgXuVXp6jwaaIEMbA4FDscLFBCfGMRbJyd5AvQ8elaarpZan8VojHYVnUcqZ1GrSV4hRewFGX)cLkM6JjoC5O8eDKeVmsOWRPEfqRqCVN2uMJMyCuEIoscqsbCYbGbhH0Gi)jJBIk5SHmqGLKCUHaJBIk5SlUpaM6htlWr(PXtStoaEDUHaJ46cxrc9nTHnKRvPYdmLtsY5gcmIRlCfjuiTnSHCTkvEGPC(KKcfmzVyixRsLNykxFGX)cLkM6JjoCpTPmhnb00CP4GOxmuSERHCP8va900xkUxNBiW4MOsoBixRsLhWdGxNBiWg7Ks0vjcdLhcy2qUwLkpGNKego3qGn2jLORsegkpeWSlUpjjmCUHaJBIk5SlUKKP(X0cCKFA8elY5dGxmCUHa7yLGdbkixCKFACP8fusdS6qe7IljzQFmTah5NgpXIC(a415gcmIRlCfjuiTnSHCTkvEaJdYCn5jj5CdbgX1fUIe6BAdBixRsLhW4GmxtE(6dm(xOuXuFmXHRlcLHAiGYbMRjXBdm6vXXeOvi(qHHuYmhnb4Tbg9SVCjXJeGf5bMabGxdxWLr8JaoTPmhnXarVyOy9wd5s5R81hy8VqPIP(yIdx1nd1qaLdmxtI3gy0RIJjqRq8HcdPKzoAcWBdm6zF5sIhjalYdmbcaVgUGlJ4hbCAtzoAIbIEXqX6TgYLYx5RpW4FHsft9XehUQN0ABebTneq5aZ1K4Tbg9Q4yc0keFOWqkzMJMa82aJE2xUK4rcWI8at5hGxdxWLr8JaoTPmhnXarVyOy9wd5s5R81hy8VqPIP(yId3aA4KafeP93HaAfIB4cUmIFSpW4FHsft9XehUJDsj6QeHHYdbmqRqCNBiW4MOso7I3hy8VqPIP(yIdxYfh5NgHdkbbAfI71RZneyexx4ksOqAByd5AvQ8at5KKCUHaJ46cxrc9nTHnKRvPYdmLZhaocPbr(tg3evYzd5AvQ8alYbWRZney4t5IgWY0cB4wwCb(vRSHDA6l5jqWo5KKWyUjfqdmIHpLlAaltlSHBzXf4xTYggfR3chNa95tsY5gcm8PCrdyzAHnCllUa)Qv2Won9L8ioqoC5KK4iKge5pzCtujNnKbcmaVM6htlWr(PXJytojPtBkZrtSsjme5RpW4FHsft9XehUCstQVmTW0fS0LYhOviogGZTazjsWbvaoTPmhnX4GcokbRVqjaVM6htlWr(PXJytoaEDUHa7yLGdbkixCKFACP8fusdS6qe7IljHbhDsPLp7iWtzPpjjo6KslFwwWK9IGrssN2uMJMyLsyissY5gcmhncbQVQNDXb4CdbMJgHa1x1ZgY1Qu5jqKlgVEJTdBUjfqdmIHpLlAaltlSHBzXf4xTYggfR3chNa9fJxokbV1ZWhIxksy6cw6s5Z(YLeNM(s(85dago3qGXnrLC2fhGxm4OtkT8zzbt2lcgjjXriniYFY4O8eDKeVmsOWRPEf7Iljv5tdosBpbkcfmzVyixRsLNCesdI8NmokprhjXlJek8AQxXgY1QufJ8ljv5tdosBpbkcfmzVyixRsL8jFyI1KZtGixmE5Oe8wpdFiEPiHPlyPlLp7lxsCA6l5ZxFGX)cLkM6JjoCRKBtAFHsGwH4yao3cKLibhub40MYC0eJdk4OeS(cLa8AQFmTah5NgpIn5a415gcSJvcoeOGCXr(PXLYxqjnWQdrSlUKegC0jLw(SJapLL(KK4OtkT8zzbt2lcgjjDAtzoAIvkHHijjNBiWC0ieO(QE2fhGZneyoAecuFvpBixRsLNyrUy86n2oS5MuanWig(uUObSmTWgULfxGF1kByuSElCCc0xmE5Oe8wpdFiEPiHPlyPlLp7lxsCA6l5ZNpay4Cdbg3evYzxCaEXGJoP0YNLfmzViyKKehH0Gi)jJJYt0rs8YiHcVM6vSlUKuLpn4iT9eOiuWK9IHCTkvEYriniYFY4O8eDKeVmsOWRPEfBixRsvmYVKuLpn4iT9eOiuWK9IHCTkvYN8HjwtopXICX4LJsWB9m8H4LIeMUGLUu(SVCjXPPVKpF9bg)luQyQpM4W90MYC0eqtZLIRStseqJGBIk5a900xkogCesdI8NmUjQKZgYabwscJtBkZrtmokprhjbiPao5a4OtkT8zzbt2lcgjjbo3cKLibhu1hy8VqPIP(yId3WDawGccsFtcOvioX1fUIyvkSeyagUGlJ4hb4Cdbg(uUObSmTWgULfxGF1kByNM(sEceStoaEbrpZan8VojHYVnUcqZ1GrSV4hReMKegC0jLw(SK4dsJgqFaoTPmhnXu2jjcOrWnrL8(aJ)fkvm1htC4QEBcMwd0ke35gcmusVmLaNgoH)fkzxCao3qGPEBcMwZgkmKsM5OP(aJ)fkvm1htC4YTKtAHZneaAAUuC1BJgnGaTcXDUHat92OrdiBixRsLNWdGxNBiWiUUWvKqH02WgY1Qu5b8KKCUHaJ46cxrc9nTHnKRvPYd45dGP(X0cCKFA8i2KRpW4FHsft9XehUQ3MGP1aTcXFtt5ZupP12iaNk8mknhnbcqr)xjmftH0ib4uHhGZneyQ3MGP1mqK)SpW4FHsft9XehUQ3g1DGraTcX5OtkT8zzbt2lcgb40MYC0eJJYt0rsaskGtoaocPbr(tghLNOJK4LrcfEn1Ryd5AvQ8eEaWaCUfilrcoOQpW4FHsft9XehUQ3MGP1aTcXFtt5ZupP12iaNk8mknhnbcaJ30u(m1BJgnGmknhnbcW5gcm1BtW0A2qHHuYmhnbWRZneyexx4ksOVPnSHCTkvEi)aiUUWveRsH(M2aW5gcm8PCrdyzAHnCllUa)Qv2Won9L8eiWtojjNBiWWNYfnGLPf2WTS4c8Rwzd700xYJ4abEYbWu)yAboYpnEeBYjjbIEMbA4FDscLFBCfGMRbJyd5AvQ8aRjjz8VqjZan8VojHYVnUcqZ1GrSkfbDbt27dagCesdI8NmUjQKZgYabUpW4FHsft9XehUQ3g1DGraTcXDUHadL0ltj4AYgXzPkuYU4sso3qGDSsWHafKloYpnUu(ckPbwDiIDXLKCUHaJBIk5SloaVo3qGn2jLORsegkpeWSHCTkvEcJdYCn5DyCQ0En1pMwGJ8tJ8Hf58bW5gcSXoPeDvIWq5HaMDXLKWW5gcSXoPeDvIWq5HaMDXbGbhH0Gi)jBStkrxLimuEiGzdzGaljHbhDsPLp7KYxgWJpjjt9JPf4i)04rSjhaIRlCfXQuyjW9bg)luQyQpM4Wv92OUdmcOvi(BAkFM6TrJgqgLMJMab415gcm1BJgnGSlUKKP(X0cCKFA8i2KZhaNBiWuVnA0aYuVXp6jwa415gcmIRlCfjuiTnSlUKKZneyexx4ksOVPnSlUpao3qGHpLlAaltlSHBzXf4xTYg2PPVKNa5WLdGxocPbr(tg3evYzd5AvQ8at5KKW40MYC0eJJYt0rsaskGtoao6KslFwwWK9IGr(6dm(xOuXuFmXHR6TrDhyeqRqCVo3qGHpLlAaltlSHBzXf4xTYg2PPVKNa5WLtsY5gcm8PCrdyzAHnCllUa)Qv2Won9L8eiWtoaVPP8zQN0ABeGtfEgLMJMa9bW5gcmIRlCfjuiTnSHCTkvEC4aiUUWveRsHcPTbago3qGHs6LPe40Wj8Vqj7IdaJ30u(m1BJgnGmknhnbcGJqAqK)KXnrLC2qUwLkpoCaE5iKge5pzKloYpnchucYgY1Qu5XHljHbhDsPLp7iWtzPV(aJ)fkvm1htC4MKFHlcLaTcX96CdbgX1fUIe6BAd7Ilj5LlZgyKkoqamexMnWiXxUKNWZNKexMnWivCS4dGHl4Yi(raN2uMJMyk7Keb0i4MOsEFGX)cLkM6JjoCLz6GWfHsGwH4EDUHaJ46cxrc9nTHDXbGbhDsPLp7iWtzPKKxNBiWowj4qGcYfh5NgxkFbL0aRoeXU4a4OtkT8zhbEkl9jj5LlZgyKkoqamexMnWiXxUKNWZNKexMnWivCSij5Cdbg3evYzxCFamCbxgXpc40MYC0etzNKiGgb3evY7dm(xOuXuFmXHB4Q1cxekbAfI715gcmIRlCfj030g2fhagC0jLw(SJapLLssEDUHa7yLGdbkixCKFACP8fusdS6qe7IdGJoP0YNDe4PS0NKKxUmBGrQ4abWqCz2aJeF5sEcpFssCz2aJuXXIKKZneyCtujNDX9bWWfCze)iGtBkZrtmLDsIaAeCtujVpW4FHsft9XehU(Tzk0iqbbPVj1hy8VqPIP(yIdx1BtOgcOvioX1fUIyvk030gjjIRlCfXuiTnIKK3ljrCDHRiMLalssEVKKZney(Tzk0iqbbPVjXU4aCUHaJ46cxrc9nTHDXLK86Cdbg3evYzd5AvQ804FHsM)XEzmsEe)(K4lxcGZneyCtujNDX91hy8VqPIP(yIdx)J9Y6dm(xOuXuFmXH7CtHX)cLcDPEGMMlfpyA9lBUqrkCIdbhmLdiqp0dbba]] )


end