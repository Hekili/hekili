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


    spec:RegisterPack( "Balance", 20210121, [[dOK1ddqiuIhPksCjHaBcGpbQkgfvLtrvAvcH6vcrZsvu3svKAxq9lqvggPkhdLYYesEgvbtdLQCnqL2gvH6BQIOXHsv5CcHSoHGmpQIUNQW(iv1brPQQfIsQhQkctuiOkxuiOKpkeu5KOuvPvkKAMGQs3uiOu7euXpfcQQHkeuSuvrs9uHAQOK8vuQQySQIKSxG(ljdwPdtzXuXJr1Kb5YiBwWNbLrtQCAjVgqMnHBtL2TOFdz4O44ufYYv8CIMUkxxvTDvPVtv14rPY5buRhuvnFsz)sniBGScmgYoceorPxuSPhBrXgok9ylk2aJpGziWygJdKbJaJtZLaJzTjSKtGXmgWcKbbYkWyj6pCcmw3DmYie8GhS609DWCKl8KL7xyxHs(yHdEYYLdpWyNFjo2VjOdymKDeiCIsVOytp2IInCu6Xwu69KGX2)0HgW44Y9jaJ1vqquc6agdrsoy8tPxwBcl5uVr4n)cQJ(P0B0w(Tb4EJITN7nk9IITo6o6NsVpHolHrYiuh9tP3NUx2FiicQ3yKWMEznzU4o6NsVpDVpHolHrq9E2aJovf6LBss27H6LdmxqQZgy0jXD0pLEF6EFQjx0lb17ptItsPna37RnL5iizV(kmHFUxMHEvYZg5FGr9(063lZqVy5zJ8pWiV4o6NsVpDVS)VOcQxMH4M8QewVSFg701Bf6To4JS3th1R)bLW6nclUOyKeUJ(P07t3Be2gquVpbkFrar9E6OEJzQPozVwVI6ob1RlAOEdcIDLJG61xf6fy0VxDgucFUE1vxV11RSC)IZsc9LcG71FD66L1r4Z(ZQEJS3NGeK8kt0l7VOGLUuEp3BDWhOELavmEXGXIsEsqwbgdrb7loqwbch2azfySXVcLGXsKWgLdzUGXuAocccK1GhiCIcKvGXuAocccK1GXigWyjDGXg)kucg)Atzoccm(1eFcmwYqcH6SbgDsS8SjycrV63lB9cOxF9YsVNjO8WYZgbAGWuAoccQxnTEptq5HLhje2OGMkCyknhbb1R3E106vYqcH6SbgDsS8SjycrV63BuGXV2OsZLaJlPYqe4bchpaYkWyknhbbbYAWyedySKoWyJFfkbJFTPmhbbg)AIpbglziHqD2aJojwE2eQH6v)Ezdm(1gvAUeyCjvCbzVe4bch2dKvGXuAocccK1GX8PoAkdm2xVS0lh9sPLholy6ovWOE106LLE5iKac5pXCu(IaIuNosjzQPoj(Z0R3Eb0RZpeWCtvjh)zaJn(vOem2HgjnavjmWdeoWfKvGXuAocccK1GX8PoAkdm25hcyUPQKJhY1Qu2R(9YMEGXg)kucgZGUcLGhiC8yqwbgtP5iiiqwdgJyaJL0bgB8Rqjy8RnL5iiW4xt8jWyovIE91RVER8OHbjSJGuHcMUtnKRvPS3NUx2GBVpDVCesaH8NyUPQKJhY1Qu2R3EHxVSX(0RxV9(OxovIE91RVER8OHbjSJGuHcMUtnKRvPS3NUx2GBVpDVSfLE9(09YribeYFI5O8fbePoDKsYutDs8qUwLYE92l86Ln2NE96TxnTE5iKac5pXCtvjhpKRvPSx97TYJggKWocsfky6o1qUwLYE106LJqciK)eZr5lcisD6iLKPM6K4HCTkL9QFVvE0WGe2rqQqbt3PgY1Qu2RMwVS0lh9sPLholy6ovWiW4xBuP5sGXCu(IaIuqKe4KdEGW5jbzfymLMJGGaznymIbmwshySXVcLGXV2uMJGaJFnXNaJ91ll9sE0Vyyiim5Ya8qMqHgO0so1RMwVCesaH8NyYLb4HmHcnqPLCcpKRvPSxp7LnpwVEb0ll9YribeYFIjxgGhYek0aLwYj8qgeW96TxnTE5OxkT8Wab8uwcg)AJknxcmMdP4OeQUcLGhiCyFGScmMsZrqqGSgm24xHsWyYLb4HmHcnqPLCcmMp1rtzGXCesaH8NyUPQKJhY1Qu2RN9gLE9cOxocjGq(tmhLViGi1PJusMAQtIhY1Qu2RN9gLE9QP1BOGP7ud5Avk71ZE9WtcgNMlbgtUmapKjuObkTKtGhiCIiqwbgtP5iiiqwdgB8RqjySe9fc6UkHPMVdWGX8PoAkdmMJqciK)eZnvLC8qUwLYE9SxpUxa9YsVV2uMJGWCu(IaIuqKe4K3RMwVCesaH8NyokFrarQthPKm1uNepKRvPSxp71J7fqVV2uMJGWCu(IaIuqKe4K3RMwVHcMUtnKRvPSxp7nk4cgNMlbglrFHGURsyQ57am4bch20dKvGXuAocccK1GXg)kucgxPKp)ZCeKYJ(wEFxfe9wCcmMp1rtzGXo)qaZnvLC8NbmonxcmUsjF(N5iiLh9T8(Uki6T4e4bch2ydKvGXuAocccK1GX8PoAkdm25hcyUPQKJ)m9QP1lh9sPLholy6ovWOEb07RnL5iimhLViGifejbo59cOxocjGq(tmhLViGi1PJusMAQtI)m9cOxw6LJqciK)eZnvLC8NPxa96RxF968dbmXffJKuIFAdEixRszV63lB61RMwVo)qatCrXijLejSbpKRvPSx97Ln961BVa6LLENFsb0aJWoMWsoPqbLjeQtxLWKyknhbb1RMwVZpPaAGryhtyjNuOGYec1PRsysmLMJGG6fqV(615hcyhtyjNuOGYec1PRsysvA3FiS8moq9QFVEOxnTED(Ha2XewYjfkOmHqD6QeMuzd3sclpJduV63Rh61BVE7vtRxNFiGbQsOHGuKldYpnUuEkkPbwb)e(Z0RMwVHcMUtnKRvPSxp7nk9aJn(vOem(ljvDKRe8aHdBrbYkWyknhbbbYAWy(uhnLbg)AtzoccxsLHiWy5nf)aHdBGXg)kucgp)uz8RqPsuYdmwuYtLMlbgBic8aHdBEaKvGXuAocccK1GX8PoAkdmE(jfqdmc7ycl5KcfuMqOoDvctIjp6xmmeeyS8MIFGWHnWyJFfkbJNFQm(vOujk5bglk5PsZLaJDq2bEGWHn2dKvGXuAocccK1GXg)kucgp)uz8RqPsuYdmwuYtLMlbglpWd8aJDq2bYkq4WgiRaJP0CeeeiRbJ5tD0ugySZpeWCtvjh)zaJn(vOemESxkrFPkmuc)adEGWjkqwbgtP5iiiqwdgJyaJL0bgB8Rqjy8RnL5iiW4xt8jWyw615hcyhtyjNuOGYec1PRsysvA3Fi8NPxa9YsVo)qa7ycl5KcfuMqOoDvctQSHBjH)mGXV2OsZLaJ5tDj6(mGhiC8aiRaJP0CeeeiRbJn(vOem2GmMREjL0VnUGX8PoAkdm25hcyhtyjNuOGYec1PRsysvA3FiS8moq96zVSxVa615hcyhtyjNuOGYec1PRsysLnCljS8moq96zVSxVa61xVS0le6WgKXC1lPK(TXvbzUgmcFfhOkH1lGEzPxJFfkXgKXC1lPK(TXvbzUgmcxPkiky6UEb0RVEzPxi0HniJ5Qxsj9BJRshzc8vCGQewVAA9cHoSbzmx9skPFBCv6itGhY1Qu2R(96HE92RMwVqOdBqgZvVKs63gxfK5AWiS8moq96zVEOxa9cHoSbzmx9skPFBCvqMRbJWd5Avk71ZEHBVa6fcDydYyU6Lus)24QGmxdgHVIduLW61lymhyUGuNnWOtcch2apq4WEGScmMsZrqqGSgmMp1rtzGX(691MYCeeMJYxeqKcIKaN8Eb0ll9YribeYFI5MQsoEidc4E10615hcyUPQKJ)m96Txa96RxNFiGDmHLCsHcktiuNUkHjvPD)HWYZ4a17JEHBVAA968dbSJjSKtkuqzcH60vjmPYgULewEghOEF0lC71BVAA9gky6o1qUwLYE9Sx20dm24xHsWyokFrarQthPKm1uNe8aHdCbzfymLMJGGaznymFQJMYaJ91RZpeWoMWsoPqbLjeQtxLWKQ0U)q4HCTkL9QFVShgU9QP1RZpeWoMWsoPqbLjeQtxLWKkB4ws4HCTkL9QFVShgU96Txa9AYBmHIb5NME1)rVrKE9cOxF9YribeYFI5MQsoEixRszV637t2RMwV(6LJqciK)etUmi)0OCqjeEixRszV637t2lGEzPxNFiGbQsOHGuKldYpnUuEkkPbwb)e(Z0lGE5OxkT8Wab8uw2R3E9cgB8Rqjym3sojuo)qam25hcQ0CjWy5zJanqGhiC8yqwbgtP5iiiqwdgZN6OPmW4ZeuEy5rcHnkOPchMsZrqq9cOxjDxLWKyjsGuqtfUEb0RZpeWYZMGjeyiK)em24xHsWy5ztWecWdeopjiRaJP0CeeeiRbJ5tD0ugyml9(AtzoccZN6s09z6fqV(6LJEP0YdNfmDNkyuVAA9YribeYFI5MQsoEixRszV637t2RMwVS07RnL5iimhsXrjuDfk7fqVS0lh9sPLhgiGNYYE1061xVCesaH8NyYLb5NgLdkHWd5Avk7v)EFYEb0ll968dbmqvcneKICzq(PXLYtrjnWk4NWFMEb0lh9sPLhgiGNYYE92RxWyJFfkbJLNnY)aJapq4W(azfymLMJGGaznymFQJMYaJ91lhHeqi)jMJYxeqK60rkjtn1jXd5Avk71ZEHBVa6LLEHMFbHtKIdj7fqV(691MYCeeMJYxeqKcIKaN8E106LJqciK)eZnvLC8qUwLYE9Sx42R3Eb07RnL5iimhsXrjuDfk71BVa61K3ycfdYpn9QFVSNE9cOxo6LslpCwW0DQGr9cOxw6fA(feorkoKem24xHsWy5zJ8pWiWdeoreiRaJP0CeeeiRbJrmGXs6aJn(vOem(1MYCeey8Rj(eySVED(HaMBQk54HCTkL9QFVWTxa96RxNFiGh7Ls0xQcdLWpW4HCTkL9QFVWTxnTEzPxNFiGh7Ls0xQcdLWpW4ptVE7vtRxw615hcyUPQKJ)m96Txa96Rxw615hcyGQeAiif5YG8tJlLNIsAGvWpH)m96Txa96RxNFiGjUOyKKsIe2GhY1Qu2R(9cJdHDn21RMwVo)qatCrXijL4N2GhY1Qu2R(9cJdHDn21RxW4xBuP5sGXqOtnKh9RHCP8KGhiCytpqwbgtP5iiiqwdgB8RqjyS8NHAiWy(uhnLbgpuyiPoZrq9cO3Zgy0HVYLuhsbvuV63lBECVa61yuCDehOEb07RnL5iime6ud5r)AixkpjymhyUGuNnWOtcch2apq4WgBGScmMsZrqqGSgm24xHsWyxekd1qGX8PoAkdmEOWqsDMJG6fqVNnWOdFLlPoKcQOE1Vx28agU9cOxJrX1rCG6fqVV2uMJGWqOtnKh9RHCP8KGXCG5csD2aJojiCyd8aHdBrbYkWyknhbbbYAWyJFfkbJLhje2OccBiWy(uhnLbgpuyiPoZrq9cO3Zgy0HVYLuhsbvuV63lBECVr27qUwLYEb0RXO46ioq9cO3xBkZrqyi0PgYJ(1qUuEsWyoWCbPoBGrNeeoSbEGWHnpaYkWyknhbbbYAWy(uhnLbgBmkUoIdeySXVcLGXb0WjfkOs7(dbEGWHn2dKvGXuAocccK1GX8PoAkdm2xVexumscxPYsG7vtRxIlkgjHLiHnQkvS1RMwVexumscl(PnQkvS1R3Eb0RVEzPxo6LslpCwW0DQGr9QP1l08liCIuCizVAA96RxtEJjumi)00RN9grWTxa96R3xBkZrqy(uxIUptVAA9AYBmHIb5NME9SxpOxVAA9(AtzoccxsLHOE92lGE917RnL5iimhLViGifejbo59cOxw6LJqciK)eZr5lcisD6iLKPM6K4ptVAA9YsVV2uMJGWCu(IaIuqKe4K3lGEzPxocjGq(tm3uvYXFME92R3E92lGE91lhHeqi)jMBQk54HCTkL9QFVEqVE106fA(feorkoKSxnTEn5nMqXG8ttV63BePxVa6LJqciK)eZnvLC8NPxa96RxocjGq(tm5YG8tJYbLq4HCTkL96zVg)kuILNnHAimXoI)psDLl1RMwVS0lh9sPLhgiGNYYE92RMwVvE0WGe2rqQqbt3PgY1Qu2RN9YME96Txa96Rxi0HniJ5Qxsj9BJRcYCnyeEixRszV63l71RMwVS0lh9sPLhoj(GeObQxVGXg)kucgh(dWkuqrIFsGhiCydUGScmMsZrqqGSgmMp1rtzGX(6L4IIrsyXpTrLe7UE106L4IIrsyjsyJkj2D9QP1lXffJKWwcSkj2D9QP1RZpeWoMWsoPqbLjeQtxLWKQ0U)q4HCTkL9QFVShgU9QP1RZpeWoMWsoPqbLjeQtxLWKkB4ws4HCTkL9QFVShgU9QP1RjVXekgKFA6v)EJi96fqVCesaH8NyUPQKJhYGaUxa9YsVqZVGWjsXHK96Txa96RxocjGq(tm3uvYXd5Avk7v)E9GE9QP1lhHeqi)jMBQk54HmiG71BVAA9w5rddsyhbPcfmDNAixRszVE2lB6bgB8Rqjym5YG8tJYbLqGhiCyZJbzfymLMJGGaznymFQJMYaJzPxO5xq4eP4qYEb07RnL5iimhsXrjuDfk7fqV(61xVM8gtOyq(PPx97nI0Rxa96RxNFiGbQsOHGuKldYpnUuEkkPbwb)e(Z0RMwVS0lh9sPLhgiGNYYE92RMwVo)qa7iqiiXxE4ptVa615hcyhbcbj(YdpKRvPSxp7nk96nYE91lhLq)6WmdXljPmrblDP8Wx5sQxt8PE92R3E106TYJggKWocsfky6o1qUwLYE9S3O0R3i71xVCuc9RdZmeVKKYefS0LYdFLlPEnXN61BVAA9YrVuA5HZcMUtfmQxV9cOxF9YsVC0lLwE4SGP7ubJ6vtR3xBkZrqyokFrarkiscCY7vtRxocjGq(tmhLViGi1PJusMAQtIhYGaUxVGXg)kucgZjbjVYektuWsxkpWdeoS9KGScmMsZrqqGSgmMp1rtzGXS0l08liCIuCizVa691MYCeeMdP4OeQUcL9cOxF96RxtEJjumi)00R(9gr61lGE91RZpeWavj0qqkYLb5NgxkpfL0aRGFc)z6vtRxw6LJEP0YddeWtzzVE7vtRxNFiGDeieK4lp8NPxa968dbSJaHGeF5HhY1Qu2RN96b96nYE91lhLq)6WmdXljPmrblDP8Wx5sQxt8PE92R3E106TYJggKWocsfky6o1qUwLYE9SxpOxVr2RVE5Oe6xhMziEjjLjkyPlLh(kxs9AIp1R3E106LJEP0YdNfmDNkyuVE7fqV(6LLE5OxkT8Wzbt3Pcg1RMwVV2uMJGWCu(IaIuqKe4K3RMwVCesaH8NyokFrarQthPKm1uNepKbbCVEbJn(vOemUsUnPDfkbpq4Wg7dKvGXuAocccK1GXigWyjDGXg)kucg)Atzoccm(1eFcmM4IIrs4kvIFAtVrCVSVEHxVg)kuILNnHAimXoI)psDLl1BK9YsVexumscxPs8tB6nI71J7fE9A8Rqj2)yNomXoI)psDLl1BK9QhoQEHxVsgsiu6m5rGXV2OsZLaJnjtegAIjo4bch2IiqwbgtP5iiiqwdgZN6OPmWyF9w5rddsyhbPcfmDNAixRszVE2l71RMwV(615hc4XEPe9LQWqj8dmEixRszVE2lmoe21yxVrCVCQe96RxtEJjumi)00l861d61R3Eb0RZpeWJ9sj6lvHHs4hy8NPxV96TxnTE91RjVXekgKFA6nYEFTPmhbHnjtegAIjEVrCVo)qatCrXijLejSbpKRvPS3i7fcD4WFawHcks8tcFfhiPAixRYEJ4EJcd3E1Vx2IsVE1061K3ycfdYpn9gzVV2uMJGWMKjcdnXeV3iUxNFiGjUOyKKs8tBWd5Avk7nYEHqho8hGvOGIe)KWxXbsQgY1QS3iU3OWWTx97LTO0RxV9cOxIlkgjHRuzjW9cOxF96Rxw6LJqciK)eZnvLC8NPxnTE5OxkT8Wab8uw2lGEzPxocjGq(tm5YG8tJYbLq4ptVE7vtRxo6LslpCwW0DQGr96Txa96Rxw6LJEP0Yd)s5Pd4PxnTEzPxNFiG5MQso(Z0RMwVM8gtOyq(PPx97nI0RxV9QP1RZpeWCtvjhpKRvPSx97L91lGEzPxNFiGh7Ls0xQcdLWpW4pdySXVcLGXYZg5FGrGhiCIspqwbgtP5iiiqwdgZN6OPmWyF968dbmXffJKuIFAd(Z0RMwV(6LRZgyKS3h9gvVa6DiUoBGrQRCPE9Sx42R3E106LRZgyKS3h96HE92lGEngfxhXbcm24xHsW4K8RCrOe8aHtuSbYkWyknhbbbYAWy(uhnLbg7RxNFiGjUOyKKs8tBWFME1061xVCD2aJK9(O3O6fqVdX1zdmsDLl1RN9c3E92RMwVCD2aJK9(Oxp0R3Eb0RXO46ioqGXg)kucgRZebLlcLGhiCIkkqwbgtP5iiiqwdgZN6OPmWyF968dbmXffJKuIFAd(Z0RMwV(6LRZgyKS3h9gvVa6DiUoBGrQRCPE9Sx42R3E106LRZgyKS3h96HE92lGEngfxhXbcm24xHsW4WxiuUiucEGWjkpaYkWyJFfkbJ9BZuOrHcks8tcmMsZrqqGSg8aHtuShiRaJP0CeeeiRbJ5tD0ugymXffJKWvQe)0ME106L4IIrsyjsyJkj2D9QP1lXffJKWwcSkj2D9QP1RZpeW(Tzk0Oqbfj(jH)m9cOxNFiGjUOyKKs8tBWFME1061xVo)qaZnvLC8qUwLYE9SxJFfkX(h70Hj2r8)rQRCPEb0RZpeWCtvjh)z61lySXVcLGXYZMqne4bcNOGliRaJn(vOem2)yNoWyknhbbbYAWdeor5XGScmMsZrqqGSgm24xHsW45NkJFfkvIsEGXIsEQ0CjW4GjeNU5dEGhySHiqwbch2azfymLMJGGaznymIbmwshySXVcLGXV2uMJGaJFnXNaJ91RZpeWx5s(rtQGgYCDQeIg8qUwLYE9SxyCiSRXUEJSx9WS1RMwVo)qaFLl5hnPcAiZ1PsiAWd5Avk71ZEn(vOelpBc1qyIDe)FK6kxQ3i7vpmB9cOxF9sCrXijCLkXpTPxnTEjUOyKewIe2OsIDxVAA9sCrXijSLaRsIDxVE71BVa615hc4RCj)OjvqdzUovcrd(Z0lGENFsb0aJWx5s(rtQGgYCDQeIgm5r)IHHGaJFTrLMlbgdnK5Q8xcHkycHcfcGhiCIcKvGXuAocccK1GXigWyjDGXg)kucg)Atzoccm(1eFcmMLEjUOyKeUsLejSPxa96RxjdjeQZgy0jXYZMqnuV63lC7fqVNjO8Ws0xOqb1PJub0qYdtP5iiOE106vYqcH6SbgDsS8Sjud1R(9(K96fm(1gvAUeyCblrdPKNnY)aJapq44bqwbgtP5iiiqwdgZN6OPmWyF9(AtzoccZr5lcisbrsGtEVa6LLE5iKac5pXCtvjhpKbbCVAA968dbm3uvYXFME92lGE91RjVXekgKFA61ZEHRE9QP17RnL5iiCblrdPKNnY)aJ61BVa61xVo)qatCrXijL4N2GhY1Qu2R(96X9QP1RZpeWexumssjrcBWd5Avk7v)E94E92lGE91ll9o)KcObgHDmHLCsHcktiuNUkHjXuAoccQxnTED(Ha2XewYjfkOmHqD6QeMuL29hclpJduV63Rh6vtRxNFiGDmHLCsHcktiuNUkHjv2WTKWYZ4a1R(96HE92RMwVHcMUtnKRvPSxp7Ln9aJn(vOemMJYxeqK60rkjtn1jbpq4WEGScmMsZrqqGSgm24xHsWy5pd1qGX8PoAkdm2xVdfgsQZCeuVAA968dbmXffJKusKWg8qUwLYE9Sxp0lGEjUOyKeUsLejSPxa9oKRvPSxp7Ln2Rxa9EMGYdlrFHcfuNosfqdjpmLMJGG61BVa69SbgD4RCj1Huqf1R(9Yg717t3RKHec1zdm6K9gzVd5Avk7fqV(6L4IIrs4kvwcCVAA9oKRvPSxp7fghc7ASRxVGXCG5csD2aJojiCyd8aHdCbzfymLMJGGaznymFQJMYaJ91RZpeWYZMGje4Hcdj1zocQxa96RxjdjeQZgy0jXYZMGje96zVEOxnTEzP35NuanWi8vUKF0KkOHmxNkHObtE0VyyiOE92RMwVNjO8Ws0xOqb1PJub0qYdtP5iiOEb0RZpeWexumssjrcBWd5Avk71ZE9qVa6L4IIrs4kvsKWMEb0RZpeWYZMGje4HCTkL96zVpzVa6vYqcH6SbgDsS8SjycrV6)Ox2RxV9cOxF9YsVZpPaAGrybWCBmPkii6QeMcMOCzKeM8OFXWqq9QP17vUuVrqVShC7v)ED(HawE2emHapKRvPS3i7nQE92lGEpBGrh(kxsDifur9QFVWfm24xHsWy5ztWecWdeoEmiRaJP0CeeeiRbJ5tD0ugy88tkGgye(kxYpAsf0qMRtLq0Gjp6xmmeuVa6vYqcH6SbgDsS8SjycrV6)Oxp0lGE91ll968db8vUKF0KkOHmxNkHOb)z6fqVo)qalpBcMqGhkmKuN5iOE1061xVV2uMJGWqdzUk)LqOcMqOqHqVa61xVo)qalpBcMqGhY1Qu2RN96HE106vYqcH6SbgDsS8SjycrV63Bu9cO3ZeuEy5rcHnkOPchMsZrqq9cOxNFiGLNnbtiWd5Avk71ZEHBVE71BVEbJn(vOemwE2emHa8aHZtcYkWyknhbbbYAWyedySKoWyJFfkbJFTPmhbbg)AIpbgBYBmHIb5NME1Vx2NE9(096Rx20R3iUxNFiGVYL8JMubnK56ujeny5zCG61BVpDV(615hcy5ztWec8qUwLYEJ4E9qVWRxjdjekDM8OE927t3RVEHqho8hGvOGIe)KWd5Avk7nI7fU96Txa968dbS8Sjycb(Zag)AJknxcmwE2emHq5hLNkycHcfcGhiCyFGScmMsZrqqGSgmMp1rtzGXV2uMJGWqdzUk)LqOcMqOqHqVa691MYCeewE2emHq5hLNkycHcfc9cOxw691MYCeeUGLOHuYZg5FGr9QP1RVED(Ha2XewYjfkOmHqD6QeMuL29hclpJduV63Rh6vtRxNFiGDmHLCsHcktiuNUkHjv2WTKWYZ4a1R(96HE92lGELmKqOoBGrNelpBcMq0RN9YEGXg)kucglpBK)bgbEGWjIazfymLMJGGaznySXVcLGXgKXC1lPK(TXfmMp1rtzGXS07vCGQewVa6LLEn(vOeBqgZvVKs63gxfK5AWiCLQGOGP76vtRxi0HniJ5Qxsj9BJRcYCnyewEghOE9Sxp0lGEHqh2GmMREjL0VnUkiZ1Gr4HCTkL96zVEamMdmxqQZgy0jbHdBGhiCytpqwbgtP5iiiqwdgB8RqjySlcLHAiWy(uhnLbgpuyiPoZrq9cO3Zgy0HVYLuhsbvuV63RVEzJ96nYE91RKHec1zdm6Ky5ztOgQ3iUx2WWTxV96Tx41RKHec1zdm6K9gzVd5Avk7fqV(61xVCesaH8NyUPQKJhYGaUxa9YsVqZVGWjsXHK9cOxF9(AtzoccZr5lcisbrsGtEVAA9YribeYFI5O8fbePoDKsYutDs8qgeW9QP1ll9YrVuA5HZcMUtfmQxV9QP1RKHec1zdm6Ky5ztOgQxp71xVWT3iUxF9YwVr27zckp85VsLlcLsmLMJGG61BVE7vtRxF9sCrXijCLkjsytVAA96RxIlkgjHRu5GoD9QP1lXffJKWvQe)0ME92lGEzP3ZeuEyj6luOG60rQaAi5HP0CeeuVAA968dbmZuUObQmHYgULfxX8fsBWVM4t9Q)JEJcU61R3Eb0RVELmKqOoBGrNelpBc1q96zVSPxVrCV(6LTEJS3ZeuE4ZFLkxekLyknhbb1R3E92lGEn5nMqXG8ttV63lC1R3NUxNFiGLNnbtiWd5Avk7nI71J71BVa61xVS0RZpeWavj0qqkYLb5NgxkpfL0aRGFc)z6vtRxIlkgjHRujrcB6vtRxw6LJEP0YddeWtzzVE7fqVgJIRJ4a1RxWyoWCbPoBGrNeeoSbEGWHn2azfymLMJGGaznymFQJMYaJngfxhXbcm24xHsW4aA4KcfuPD)Hapq4WwuGScmMsZrqqGSgmMp1rtzGXo)qaZnvLC8Nbm24xHsW4XEPe9LQWqj8dm4bch28aiRaJP0CeeeiRbJ5tD0ugyml9cn)ccNifhs2lGEFTPmhbH5qkokHQRqzVa61xVo)qalpBcMqG)m9QP1RjVXekgKFA6v)EHRE96Txa9YsVo)qalrc5vCc)z6fqVS0RZpeWCtvjh)z6fqV(6LLE5OxkT8Wzbt3Pcg1RMwVV2uMJGWCu(IaIuqKe4K3RMwVCesaH8NyokFrarQthPKm1uNe)z6vtR3kpAyqc7iivOGP7ud5Avk71ZEJsVEJSxF9Yrj0VomZq8ssktuWsxkp8vUK61eFQxV96fm24xHsWyoji5vMqzIcw6s5bEGWHn2dKvGXuAocccK1GX8PoAkdmMLEHMFbHtKIdj7fqVV2uMJGWCifhLq1vOSxa96RxNFiGLNnbtiWFME1061K3ycfdYpn9QFVWvVE92lGEzPxNFiGLiH8koH)m9cOxw615hcyUPQKJ)m9cOxF9YsVC0lLwE4SGP7ubJ6vtR3xBkZrqyokFrarkiscCY7vtRxocjGq(tmhLViGi1PJusMAQtI)m9QP1BLhnmiHDeKkuW0DQHCTkL96zVCesaH8NyokFrarQthPKm1uNepKRvPS3i71J7vtR3kpAyqc7iivOGP7ud5Avk7nc6Ln2NE96zVEqVEJSxF9Yrj0VomZq8ssktuWsxkp8vUK61eFQxV96fm24xHsW4k52K2vOe8aHdBWfKvGXuAocccK1GX8PoAkdmUYJggKWocsfky6o1qUwLYE9Sx2GBVAA96RxNFiGzMYfnqLju2WTS4kMVqAd(1eFQxp7nk4QxVAA968dbmZuUObQmHYgULfxX8fsBWVM4t9Q)JEJcU61R3Eb0RZpeWYZMGje4ptVa61xVCesaH8NyUPQKJhY1Qu2R(9cx96vtRxO5xq4eP4qYE9cgB8Rqjym5YG8tJYbLqGhiCyZJbzfymLMJGGaznySXVcLGXYJecBubHneymFQJMYaJhkmKuN5iOEb07vUK6qkOI6v)EzdU9cOxjdjeQZgy0jXYZMqnuVE2l71lGEngfxhXbQxa96RxNFiG5MQsoEixRszV63lB61RMwVS0RZpeWCtvjh)z61lymhyUGuNnWOtcch2apq4W2tcYkWyknhbbbYAWy(uhnLbgtCrXijCLklbUxa9AmkUoIduVa615hcyMPCrduzcLnCllUI5lK2GFnXN61ZEJcU61lGE91le6WgKXC1lPK(TXvbzUgmcFfhOkH1RMwVS0lh9sPLhoj(GeObQxnTELmKqOoBGrNSx97nQE9cgB8RqjyC4paRqbfj(jbEGWHn2hiRaJP0CeeeiRbJ5tD0ugySZpeWOKoDsfdnCI5kuI)m9cOxF968dbS8SjycbEOWqsDMJG6vtRxtEJjumi)00R(9gr61RxWyJFfkbJLNnbtiapq4WwebYkWyknhbbbYAWy(uhnLbgZrVuA5HZcMUtfmQxa96R3xBkZrqyokFrarkiscCY7vtRxocjGq(tm3uvYXFME10615hcyUPQKJ)m96Txa9YribeYFI5O8fbePoDKsYutDs8qUwLYE9SxyCiSRXUEJ4E5uj61xVM8gtOyq(PPx41lC1RxV9cOxNFiGLNnbtiWd5Avk71ZEzVEb0ll9cn)ccNifhscgB8RqjyS8Sjycb4bcNO0dKvGXuAocccK1GX8PoAkdmMJEP0YdNfmDNkyuVa61xVV2uMJGWCu(IaIuqKe4K3RMwVCesaH8NyUPQKJ)m9QP1RZpeWCtvjh)z61BVa6LJqciK)eZr5lcisD6iLKPM6K4HCTkL96zVECVa615hcy5ztWec8NPxa9sCrXijCLklbUxa9YsVV2uMJGWfSenKsE2i)dmQxa9YsVqZVGWjsXHKGXg)kucglpBK)bgbEGWjk2azfymLMJGGaznymFQJMYaJD(HagL0PtQ4cYg1BjluI)m9QP1RVEzPx5ztOgcBmkUoIduVa6LLEFTPmhbHlyjAiL8Sr(hyuVAA96RxNFiG5MQsoEixRszVE2lC7fqVo)qaZnvLC8NPxnTE91RZpeWJ9sj6lvHHs4hy8qUwLYE9SxyCiSRXUEJ4E5uj61xVM8gtOyq(PPx41Rh0RxV9cOxNFiGh7Ls0xQcdLWpW4ptVE71BVa691MYCeewE2emHq5hLNkycHcfc9cOxjdjeQZgy0jXYZMGje96zVEOxV9cOxF9YsVZpPaAGr4RCj)OjvqdzUovcrdM8OFXWqq9QP1RKHec1zdm6Ky5ztWeIE9Sxp0RxWyJFfkbJLNnY)aJapq4evuGScmMsZrqqGSgmMp1rtzGX(6L4IIrs4kvwcCVa6LJqciK)eZnvLC8qUwLYE1Vx4QxVAA96RxUoBGrYEF0Bu9cO3H46SbgPUYL61ZEHBVE7vtRxUoBGrYEF0Rh61BVa61yuCDehiWyJFfkbJtYVYfHsWdeor5bqwbgtP5iiiqwdgZN6OPmWyF9sCrXijCLklbUxa9YribeYFI5MQsoEixRszV63lC1RxnTE91lxNnWizVp6nQEb07qCD2aJux5s96zVWTxV9QP1lxNnWizVp61d96Txa9AmkUoIdeySXVcLGX6mrq5Iqj4bcNOypqwbgtP5iiiqwdgZN6OPmWyF9sCrXijCLklbUxa9YribeYFI5MQsoEixRszV63lC1RxnTE91lxNnWizVp6nQEb07qCD2aJux5s96zVWTxV9QP1lxNnWizVp61d96Txa9AmkUoIdeySXVcLGXHVqOCrOe8aHtuWfKvGXg)kucg73MPqJcfuK4NeymLMJGGazn4bcNO8yqwbgtP5iiiqwdgJyaJL0bgB8Rqjy8RnL5iiW4xt8jWyjdjeQZgy0jXYZMqnuV63l71BK9gei00RVEDn5rdWQxt8PEJ4Eztp96fE9gLE96T3i7niqOPxF968dbS8Sr(hyKICzq(PXLYtjrcBWYZ4a1l86L961ly8RnQ0CjWy5ztOgsvPsIe2aEGWjQNeKvGXuAocccK1GX8PoAkdmM4IIrsyXpTrLe7UE106L4IIrsylbwLe7UEb07RnL5iiCjvCbzVuVAA968dbmXffJKusKWg8qUwLYE9SxJFfkXYZMqneMyhX)hPUYL6fqVo)qatCrXijLejSb)z6vtRxIlkgjHRujrcB6fqVS07RnL5iiS8SjudPQujrcB6vtRxNFiG5MQsoEixRszVE2RXVcLy5ztOgctSJ4)Jux5s9cOxw691MYCeeUKkUGSxQxa968dbm3uvYXd5Avk71ZEj2r8)rQRCPEb0RZpeWCtvjh)z6vtRxNFiGh7Ls0xQcdLWpW4ptVa6vYqcHsNjpQx97vpSh3lGE91RKHec1zdm6K965JE9qVAA9YsVNjO8Ws0xOqb1PJub0qYdtP5iiOE92RMwVS07RnL5iiCjvCbzVuVa615hcyUPQKJhY1Qu2R(9sSJ4)Jux5sGXg)kucg7FSth4bcNOyFGScm24xHsWy5ztOgcmMsZrqqGSg8aHtureiRaJP0CeeeiRbJn(vOemE(PY4xHsLOKhySOKNknxcmoycXPB(Gh4bghmH40nFqwbch2azfymLMJGGaznymFQJMYaJzP35NuanWiSJjSKtkuqzcH60vjmjM8OFXWqqGXg)kucglpBK)bgbEGWjkqwbgtP5iiiqwdgB8RqjyS8NHAiWy(uhnLbgdHoSlcLHAi8qUwLYE1V3HCTkLGXCG5csD2aJojiCyd8aHJhazfySXVcLGXUiugQHaJP0CeeeiRbpWdmwEGSceoSbYkWyknhbbbYAWy(uhnLbgp)KcObgHVYL8JMubnK56ujenyYJ(fddb1lGE91lXffJKWvQSe4Eb0ll96RxF968db8vUKF0KkOHmxNkHObpKRvPSx97fghc7ASR3i7vpmB9cOxF9sCrXijCLkh0PRxnTEjUOyKeUsLejSPxnTEjUOyKew8tBujXURxV9QP1RZpeWx5s(rtQGgYCDQeIg8qUwLYE1VxJFfkXYZMqneMyhX)hPUYL6nYE1dZwVa61xVexumscxPs8tB6vtRxIlkgjHLiHnQKy31RMwVexumscBjWQKy31R3E92RMwVS0RZpeWx5s(rtQGgYCDQeIg8NPxV9QP1RVED(HaMBQk54ptVAA9(AtzoccZr5lcisbrsGtEVE7fqVCesaH8NyokFrarQthPKm1uNepKbbCVEbJn(vOemwE2i)dmc8aHtuGScmMsZrqqGSgm24xHsWydYyU6Lus)24cgZN6OPmWyw6fcDydYyU6Lus)24QGmxdgHVIduLW6fqVS0RXVcLydYyU6Lus)24QGmxdgHRufefmDxVa61xVS0le6WgKXC1lPK(TXvPJmb(koqvcRxnTEHqh2GmMREjL0VnUkDKjWd5Avk7v)EHBVE7vtRxi0HniJ5Qxsj9BJRcYCnyewEghOE9Sxp0lGEHqh2GmMREjL0VnUkiZ1Gr4HCTkL96zVEOxa9cHoSbzmx9skPFBCvqMRbJWxXbQsyGXCG5csD2aJojiCyd8aHJhazfymLMJGGaznymFQJMYaJ917RnL5iimhLViGifejbo59cOxw6LJqciK)eZnvLC8qgeW9QP1RZpeWCtvjh)z61BVa61K3ycfdYpn96zVSNE9cOxF968dbmXffJKuIFAdEixRszV63lB61RMwVo)qatCrXijLejSbpKRvPSx97Ln961BVAA9gky6o1qUwLYE9Sx20dm24xHsWyokFrarQthPKm1uNe8aHd7bYkWyknhbbbYAWyedySKoWyJFfkbJFTPmhbbg)AIpbg7RxNFiG5MQsoEixRszV63lC7fqV(615hc4XEPe9LQWqj8dmEixRszV63lC7vtRxw615hc4XEPe9LQWqj8dm(Z0R3E106LLED(HaMBQk54ptVAA9AYBmHIb5NME9SxpOxVE7fqV(6LLED(HagOkHgcsrUmi)04s5POKgyf8t4ptVAA9AYBmHIb5NME9SxpOxVE7fqV(615hcyIlkgjPKiHn4HCTkL9QFVW4qyxJD9QP1RZpeWexumssj(Pn4HCTkL9QFVW4qyxJD96fm(1gvAUeyme6ud5r)Aixkpj4bch4cYkWyknhbbbYAWyJFfkbJDrOmudbgZN6OPmW4Hcdj1zocQxa9E2aJo8vUK6qkOI6v)EzlQEb0RVEngfxhXbQxa9(AtzoccdHo1qE0VgYLYt2RxWyoWCbPoBGrNeeoSbEGWXJbzfymLMJGGaznySXVcLGXYFgQHaJ5tD0ugy8qHHK6mhb1lGEpBGrh(kxsDifur9QFVSfvVa61xVgJIRJ4a1lGEFTPmhbHHqNAip6xd5s5j71lymhyUGuNnWOtcch2apq48KGScmMsZrqqGSgm24xHsWy5rcHnQGWgcmMp1rtzGXdfgsQZCeuVa69SbgD4RCj1Huqf1R(9YMh3lGE91RXO46ioq9cO3xBkZrqyi0PgYJ(1qUuEYE9cgZbMli1zdm6KGWHnWdeoSpqwbgtP5iiiqwdgZN6OPmWyJrX1rCGaJn(vOemoGgoPqbvA3FiWdeoreiRaJP0CeeeiRbJ5tD0ugySZpeWCtvjh)zaJn(vOemESxkrFPkmuc)adEGWHn9azfymLMJGGaznymFQJMYaJ91RVED(HaM4IIrskjsydEixRszV63lB61RMwVo)qatCrXijL4N2GhY1Qu2R(9YME96Txa9YribeYFI5MQsoEixRszV63Rh0Rxa96RxNFiGzMYfnqLju2WTS4kMVqAd(1eFQxp7nk2tVE106LLENFsb0aJWmt5IgOYekB4wwCfZxiTbtE0VyyiOE92R3E10615hcyMPCrduzcLnCllUI5lK2GFnXN6v)h9g1tQxVAA9YribeYFI5MQsoEidc4Eb0RVEn5nMqXG8ttV63BePxVAA9(AtzoccxsLHOE9cgB8Rqjym5YG8tJYbLqGhiCyJnqwbgtP5iiiqwdgZN6OPmWyw6fA(feorkoKSxa9(AtzoccZHuCucvxHYEb0RVEn5nMqXG8ttV63BePxVa61xVo)qaduLqdbPixgKFACP8uusdSc(j8NPxnTEzPxo6LslpmqapLL96TxnTE5OxkT8Wzbt3Pcg1RMwVV2uMJGWLuziQxnTED(Ha2rGqqIV8WFMEb0RZpeWocecs8LhEixRszVE2Bu61BK96RxF9gr9gX9o)KcObgHzMYfnqLju2WTS4kMVqAdM8OFXWqq96T3i71xVCuc9RdZmeVKKYefS0LYdFLlPEnXN61BVE71BVa6LLED(HaMBQk54ptVa61xVS0lh9sPLholy6ovWOE106LJqciK)eZr5lcisD6iLKPM6K4ptVAA9w5rddsyhbPcfmDNAixRszVE2lhHeqi)jMJYxeqK60rkjtn1jXd5Avk7nYE94E106TYJggKWocsfky6o1qUwLYEJGEzJ9PxVE2Bu61BK96RxokH(1HzgIxsszIcw6s5HVYLuVM4t96TxVGXg)kucgZjbjVYektuWsxkpWdeoSffiRaJP0CeeeiRbJ5tD0ugyml9cn)ccNifhs2lGEFTPmhbH5qkokHQRqzVa61xVM8gtOyq(PPx97nI0Rxa96RxNFiGbQsOHGuKldYpnUuEkkPbwb)e(Z0RMwVS0lh9sPLhgiGNYYE92RMwVC0lLwE4SGP7ubJ6vtR3xBkZrq4sQme1RMwVo)qa7iqiiXxE4ptVa615hcyhbcbj(YdpKRvPSxp71d61BK96RxF9gr9gX9o)KcObgHzMYfnqLju2WTS4kMVqAdM8OFXWqq96T3i71xVCuc9RdZmeVKKYefS0LYdFLlPEnXN61BVE71BVa6LLED(HaMBQk54ptVa61xVS0lh9sPLholy6ovWOE106LJqciK)eZr5lcisD6iLKPM6K4ptVAA9w5rddsyhbPcfmDNAixRszVE2lhHeqi)jMJYxeqK60rkjtn1jXd5Avk7nYE94E106TYJggKWocsfky6o1qUwLYEJGEzJ9PxVE2Rh0R3i71xVCuc9RdZmeVKKYefS0LYdFLlPEnXN61BVEbJn(vOemUsUnPDfkbpq4WMhazfymLMJGGaznymIbmwshySXVcLGXV2uMJGaJFnXNaJzPxocjGq(tm3uvYXdzqa3RMwVS07RnL5iimhLViGifejbo59cOxo6LslpCwW0DQGr9QP1l08liCIuCijy8RnQ0CjWyP9sQaAuCtvjh8aHdBShiRaJP0CeeeiRbJ5tD0ugymXffJKWvQSe4Eb0RXO46ioq9cOxNFiGzMYfnqLju2WTS4kMVqAd(1eFQxp7nk2tVEb0RVEHqh2GmMREjL0VnUkiZ1Gr4R4avjSE106LLE5OxkT8WjXhKanq96Txa9(AtzocclTxsfqJIBQk5GXg)kucgh(dWkuqrIFsGhiCydUGScmMsZrqqGSgmMp1rtzGXo)qaJs60jvm0WjMRqj(Z0lGED(HawE2emHapuyiPoZrqGXg)kucglpBcMqaEGWHnpgKvGXuAocccK1GX8PoAkdm25hcy5zJanq4HCTkL96zVWTxa96RxNFiGjUOyKKsIe2GhY1Qu2R(9c3E10615hcyIlkgjPe)0g8qUwLYE1Vx42R3Eb0RjVXekgKFA6v)EJi9aJn(vOemMBjNekNFiag78dbvAUeyS8SrGgiWdeoS9KGScmMsZrqqGSgmMp1rtzGXNjO8WYJecBuqtfomLMJGG6fqVs6UkHjXsKaPGMkC9cOxNFiGLNnbtiWqi)jySXVcLGXYZMGjeGhiCyJ9bYkWyknhbbbYAWy(uhnLbgZrVuA5HZcMUtfmQxa9(AtzoccZr5lcisbrsGtEVa6LJqciK)eZr5lcisD6iLKPM6K4HCTkL96zVWTxa9YsVqZVGWjsXHKGXg)kucglpBK)bgbEGWHTicKvGXuAocccK1GX8PoAkdm(mbLhwEKqyJcAQWHP0CeeuVa6LLEptq5HLNnc0aHP0CeeuVa615hcy5ztWec8qHHK6mhb1lGE91RZpeWexumssj(Pn4HCTkL9QFVECVa6L4IIrs4kvIFAtVa615hcyMPCrduzcLnCllUI5lK2GFnXN61ZEJcU61RMwVo)qaZmLlAGktOSHBzXvmFH0g8Rj(uV6)O3OGRE9cOxtEJjumi)00R(9gr61RMwVqOdBqgZvVKs63gxfK5AWi8qUwLYE1Vx2xVAA9A8Rqj2GmMREjL0VnUkiZ1Gr4kvbrbt31R3Eb0ll9YribeYFI5MQsoEidcyWyJFfkbJLNnbtiapq4eLEGScmMsZrqqGSgmMp1rtzGXo)qaJs60jvCbzJ6TKfkXFME10615hcyGQeAiif5YG8tJlLNIsAGvWpH)m9QP1RZpeWCtvjh)z6fqV(615hc4XEPe9LQWqj8dmEixRszVE2lmoe21yxVrCVCQe96RxtEJjumi)00l861d61R3Eb0RZpeWJ9sj6lvHHs4hy8NPxnTEzPxNFiGh7Ls0xQcdLWpW4ptVa6LLE5iKac5pXJ9sj6lvHHs4hy8qgeW9QP1ll9YrVuA5HFP80b80R3E1061K3ycfdYpn9QFVrKE9cOxIlkgjHRuzjWGXg)kucglpBK)bgbEGWjk2azfymLMJGGaznymFQJMYaJptq5HLNnc0aHP0CeeuVa6LLENFsb0aJWx5s(rtQGgYCDQeIgm5r)IHHG6fqV(615hcy5zJanq4ptVAA9AYBmHIb5NME1V3isVE92lGED(HawE2iqdewEghOE9Sxp0lGE91RZpeWexumssjrcBWFME10615hcyIlkgjPe)0g8NPxV9cOxNFiGzMYfnqLju2WTS4kMVqAd(1eFQxp7nQNuVEb0RVE5iKac5pXCtvjhpKRvPSx97Ln96vtRxw691MYCeeMJYxeqKcIKaN8Eb0lh9sPLholy6ovWOE9cgB8RqjyS8Sr(hye4bcNOIcKvGXuAocccK1GX8PoAkdmMLENFsb0aJWx5s(rtQGgYCDQeIgm5r)IHHG6fqV(615hcyMPCrduzcLnCllUI5lK2GFnXN61ZEJ6j1RxnTED(HaMzkx0avMqzd3YIRy(cPn4xt8PE9S3OGRE9cO3ZeuEy5rcHnkOPchMsZrqq96Txa968dbmXffJKusKWg8qUwLYE1V3NSxa9sCrXijCLkjsytVa6LLED(HagL0PtQyOHtmxHs8NPxa9YsVNjO8WYZgbAGWuAoccQxa9YribeYFI5MQsoEixRszV637t2lGE91lhHeqi)jgOkHgcsjzQPojEixRszV637t2RMwVS0lh9sPLhgiGNYYE9cgB8RqjyS8Sr(hye4bcNO8aiRaJP0CeeeiRbJ5tD0ugySVED(HaM4IIrskXpTb)z6vtRxF9Y1zdms27JEJQxa9oexNnWi1vUuVE2lC71BVAA9Y1zdms27JE9qVE7fqVgJIRJ4a1lGEFTPmhbHL2lPcOrXnvLCWyJFfkbJtYVYfHsWdeorXEGScmMsZrqqGSgmMp1rtzGX(615hcyIlkgjPe)0g8NPxa9YsVC0lLwEyGaEkl7vtRxF968dbmqvcneKICzq(PXLYtrjnWk4NWFMEb0lh9sPLhgiGNYYE92RMwV(6LRZgyKS3h9gvVa6DiUoBGrQRCPE9Sx42R3E106LRZgyKS3h96HE10615hcyUPQKJ)m96Txa9AmkUoIduVa691MYCeewAVKkGgf3uvYbJn(vOemwNjckxekbpq4efCbzfymLMJGGaznymFQJMYaJ91RZpeWexumssj(Pn4ptVa6LLE5OxkT8Wab8uw2RMwV(615hcyGQeAiif5YG8tJlLNIsAGvWpH)m9cOxo6LslpmqapLL96TxnTE91lxNnWizVp6nQEb07qCD2aJux5s96zVWTxV9QP1lxNnWizVp61d9QP1RZpeWCtvjh)z61BVa61yuCDehOEb07RnL5iiS0EjvankUPQKdgB8RqjyC4lekxekbpq4eLhdYkWyJFfkbJ9BZuOrHcks8tcmMsZrqqGSg8aHtupjiRaJP0CeeeiRbJ5tD0ugymXffJKWvQe)0ME106L4IIrsyjsyJkj2D9QP1lXffJKWwcSkj2D9QP1RZpeW(Tzk0Oqbfj(jH)m9cOxNFiGjUOyKKs8tBWFME1061xVo)qaZnvLC8qUwLYE9SxJFfkX(h70Hj2r8)rQRCPEb0RZpeWCtvjh)z61lySXVcLGXYZMqne4bcNOyFGScm24xHsWy)JD6aJP0CeeeiRbpq4evebYkWyknhbbbYAWyJFfkbJNFQm(vOujk5bglk5PsZLaJdMqC6Mp4bEGXmdXrUo2bYkq4WgiRaJn(vOemgOkHgcsjzQPojymLMJGGazn4bcNOazfySXVcLGXUiucuLQaACbJP0CeeeiRbpq44bqwbgtP5iiiqwdgB8RqjyS)XoDGX8PoAkdm2xVexumscl(PnQKy31RMwVexumscxPs8tB6vtRxIlkgjHRu5GoD9QP1lXffJKWwcSkj2D96fmwujP4qGXSPh4bch2dKvGXuAocccK1GX8PoAkdm2xVexumscl(PnQKy31RMwVexumscxPs8tB6vtRxIlkgjHRu5GoD9QP1lXffJKWwcSkj2D96Txa9Ym0lMnS)XoD9cOxw6LzOxCuy)JD6aJn(vOem2)yNoWdeoWfKvGXuAocccK1GX8PoAkdmMLENFsb0aJWoMWsoPqbLjeQtxLWKyknhbb1RMwVS0lh9sPLholy6ovWOE106LLELmKqOoBGrNelpBcMq07JEzRxnTEzP3ZeuE40U)qsLJjSKtyknhbbbgB8RqjyS8SjudbEGWXJbzfymLMJGGaznymFQJMYaJNFsb0aJWoMWsoPqbLjeQtxLWKyknhbb1lGE5OxkT8Wzbt3Pcg1lGELmKqOoBGrNelpBcMq07JEzdm24xHsWy5zJ8pWiWd8apW4xAKfkbHtu6ffB6XgBpjySFBYkHjbJz)W()udh2VWjcxeQ3EzLoQ3YLbnxVb00l8bIc2xCWNEhYJ(1qq9krUuV2)qU2rq9Y1zjmsI7OHVvs96XrOEFcu(sZrq9gxUprVsGZZyxVrqVhQx4736fQElzHYErm0yhA61h882RVOyNxChn8TsQx2ylc17tGYxAocQx4Z8tkGgye(Pc(07H6f(m)KcObgHFQWuAoccc(0RVOyNxChDhn7h2)NA4W(for4Iq92lR0r9wUmO56nGMEHpmdXrUo2bF6Dip6xdb1Re5s9A)d5Ahb1lxNLWijUJg(wj1lCJq9(eO8LMJG6f(m)KcObgHFQGp9EOEHpZpPaAGr4NkmLMJGGGp96Jn25f3rdFRK61JJq9(eO8LMJG6f(m)KcObgHFQGp9EOEHpZpPaAGr4NkmLMJGGGp96Jn25f3r3rZ(H9)PgoSFHteUiuV9YkDuVLldAUEdOPx4JHi4tVd5r)AiOELixQx7Fix7iOE56SegjXD0W3kPE9qeQ3NaLV0CeuVWN5NuanWi8tf8P3d1l8z(jfqdmc)uHP0Ceee8PxFSXoV4oA4BLuVWnc17tGYxAocQ34Y9j6vcCEg76ncIGEpuVW3V1Rlc6l(YErm0yhA61xe4TxFSXoV4oA4BLuVpzeQ3NaLV0CeuVXL7t0Re48m21Be07H6f((TEHQ3swOSxedn2HME9bpV96Jn25f3rdFRK6Ln9Iq9(eO8LMJG6nUCFIELaNNXUEJGEpuVW3V1lu9wYcL9IyOXo00Rp45TxFSXoV4oA4BLuVSXErOEFcu(sZrq9gxUprVsGZZyxVrqe07H6f((TEDrqFXx2lIHg7qtV(IaV96Jn25f3rdFRK6LTikc17tGYxAocQ34Y9j6vcCEg76nc69q9cF)wVq1Bjlu2lIHg7qtV(GN3E9Xg78I7OHVvs9gfBrOEFcu(sZrq9gxUprVsGZZyxVrqVhQx4736fQElzHYErm0yhA61h882Rp2yNxChn8TsQ3O84iuVpbkFP5iOEJl3NOxjW5zSR3iO3d1l89B9cvVLSqzVigASdn96dEE71xuSZlUJUJM9d7)tnCy)cNiCrOE7Lv6OElxg0C9gqtVWh5bF6Dip6xdb1Re5s9A)d5Ahb1lxNLWijUJg(wj1lBSfH69jq5lnhb1BC5(e9kbopJD9gbrqVhQx47361fb9fFzVigASdn96lc82Rp2yNxChn8TsQx2Ikc17tGYxAocQ34Y9j6vcCEg76ncIGEpuVW3V1Rlc6l(YErm0yhA61xe4TxFSXoV4oA4BLuVrPxeQ3NaLV0CeuVXL7t0Re48m21Be07H6f((TEHQ3swOSxedn2HME9bpV96Jn25f3r3rZ(H9)PgoSFHteUiuV9YkDuVLldAUEdOPx4JdYo4tVd5r)AiOELixQx7Fix7iOE56SegjXD0W3kPEzJ9fH69jq5lnhb1BC5(e9kbopJD9gb9EOEHVFRxO6TKfk7fXqJDOPxFWZBV(8a78I7OHVvs9YwefH69jq5lnhb1BC5(e9kbopJD9gb9EOEHVFRxO6TKfk7fXqJDOPxFWZBV(yJDEXD0D0SFDzqZrq96X9A8RqzVIsEsChnySKH4GWHn9IcmMzqHsqGXpLEzTjSKt9gH38lOo6NsVrB53gG7nk2EU3O0lk26O7OFk9(e6SegjJqD0pLEF6Ez)HGiOEJrcB6L1K5I7OFk9(09(e6Segb17zdm6uvOxUjjzVhQxoWCbPoBGrNe3r)u69P79PMCrVeuV)mjojL2aCVV2uMJGK96RWe(5Ezg6vjpBK)bg17tRFVmd9ILNnY)aJ8I7OFk9(09Y()IkOEzgIBYRsy9Y(zStxVvO36GpYEpDuV(hucR3iS4IIrs4o6NsVpDVryBar9(eO8fbe17PJ6nMPM6K9A9kQ7euVUOH6nii2vocQxFvOxGr)E1zqj856vxD9wxVYY9lolj0xkaUx)1PRxwhHp7pR6nYEFcsqYRmrVS)Icw6s59CV1bFG6vcuX4f3r3rB8RqPeZmeh56y3dGQeAiiLKPM6KD0g)kukXmdXrUo2f5d45IqjqvQcOXTJ24xHsjMzioY1XUiFap)JD6EwujP4qpytVNRWdFexumscl(PnQKy3PPrCrXijCLkXpTrtJ4IIrs4kvoOtNMgXffJKWwcSkj2DE7On(vOuIzgIJCDSlYhWZ)yNUNRWdFexumscl(PnQKy3PPrCrXijCLkXpTrtJ4IIrs4kvoOtNMgXffJKWwcSkj2DEbWm0lMnS)XoDayHzOxCuy)JD66On(vOuIzgIJCDSlYhWtE2eQHEUcpyz(jfqdmc7ycl5KcfuMqOoDvctQPXch9sPLholy6ovWinnwKmKqOoBGrNelpBcMq8Gnnnwotq5Ht7(djvoMWsoHP0CeeuhTXVcLsmZqCKRJDr(aEYZg5FGrpxHhZpPaAGryhtyjNuOGYec1PRsysaC0lLwE4SGP7ubJaiziHqD2aJojwE2emH4bBD0D0pLEJWIDe)FeuV0lna37vUuVNoQxJFOP3s2R9ALWCeeUJ24xHs5djsyJYHm3oAJFfkLpETPmhb9CAU0JsQme98Rj(0djdjeQZgy0jXYZMGje6ZgaFSCMGYdlpBeObctP5iiinTZeuEy5rcHnkOPchMsZrqqE10KmKqOoBGrNelpBcMqOFuD0g)kukJ8b8ETPmhb9CAU0JsQ4cYEPNFnXNEiziHqD2aJojwE2eQH0NToAJFfkLr(aEo0iPbOkH9CfE4Jfo6LslpCwW0DQGrAASWribeYFI5O8fbePoDKsYutDs8NXlaNFiG5MQso(Z0rB8RqPmYhWJbDfkFUcpC(HaMBQk54HCTkL6ZMED0g)kukJ8b8ETPmhb9CAU0dokFrarkiscCYF(1eF6bNkHpFvE0WGe2rqQqbt3PgY1Qu(0Sb3NMJqciK)eZnvLC8qUwLsVraBSp98(GtLWNVkpAyqc7iivOGP7ud5AvkFA2G7tZwu690CesaH8NyokFrarQthPKm1uNepKRvP0BeWg7tpVAACesaH8NyUPQKJhY1QuQFLhnmiHDeKkuW0DQHCTkLAACesaH8NyokFrarQthPKm1uNepKRvPu)kpAyqc7iivOGP7ud5Avk10yHJEP0YdNfmDNkyuhTXVcLYiFaVxBkZrqpNMl9GdP4OeQUcLp)AIp9WhlKh9lggcctUmapKjuObkTKtAACesaH8NyYLb4HmHcnqPLCcpKRvP0t28y9aWchHeqi)jMCzaEitOqduAjNWdzqa7vtJJEP0YddeWtzzhTXVcLYiFaVVKu1rUpNMl9GCzaEitOqduAjNEUcp4iKac5pXCtvjhpKRvP0ZO0dahHeqi)jMJYxeqK60rkjtn1jXd5Avk9mk900cfmDNAixRsPNE4j7On(vOug5d49LKQoY950CPhs0xiO7QeMA(oa)CfEWribeYFI5MQsoEixRsPNEmawETPmhbH5O8fbePGijWjxtJJqciK)eZr5lcisD6iLKPM6K4HCTkLE6XaETPmhbH5O8fbePGijWjxtluW0DQHCTkLEgfC7On(vOug5d49LKQoY950CPhvk5Z)mhbP8OVL33vbrVfNEUcpC(HaMBQk54pth9tPxJFfkLr(aEFjPQJCLplfOt(4MkbIo2EUcpy5MkbIomByDMuXmio2sGb4JLBQei6WrH1zsfZG4ylbwtJLBQei6WrHhYGawXribeYF6vtZ5hcyUPQKJ)mAACesaH8NyUPQKJhY1Qu(0SPN(3ujq0HzdZribeYFIH(JDfkbWch9sPLhgiGNYsnno6LslpCwW0DQGraETPmhbH5O8fbePGijWjhahHeqi)jMJYxeqK60rkjtn1jXFgnnNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOPfky6o1qUwLspJsVo6NsVg)kukJ8b8(ssvh5kFwkqN8XnvceDr9CfEWYnvceD4OW6mPIzqCSLadWhl3ujq0HzdRZKkMbXXwcSMgl3ujq0HzdpKbbSIJqciK)0RM2nvceDy2W6mPIzqCSLad4MkbIoCuyDMuXmio2sGbWYnvceDy2WdzqaR4iKac5p10C(HaMBQk54pJMghHeqi)jMBQk54HCTkLpnB6P)nvceD4OWCesaH8NyO)yxHsaSWrVuA5Hbc4PSutJJEP0YdNfmDNkyeGxBkZrqyokFrarkiscCYbWribeYFI5O8fbePoDKsYutDs8NrtZ5hcyGQeAiif5YG8tJlLNIsAGvWpH)mAAHcMUtnKRvP0ZO0RJ24xHszKpG3xsQ6ix5Zv4HZpeWCtvjh)z004OxkT8Wzbt3Pcgb41MYCeeMJYxeqKcIKaNCaCesaH8NyokFrarQthPKm1uNe)zaWchHeqi)jMBQk54pdaF(C(HaM4IIrskXpTbpKRvPuF20ttZ5hcyIlkgjPKiHn4HCTkL6ZMEEbWY8tkGgye2XewYjfkOmHqD6QeMutB(jfqdmc7ycl5KcfuMqOoDvctcWNZpeWoMWsoPqbLjeQtxLWKQ0U)qy5zCG03dAAo)qa7ycl5KcfuMqOoDvctQSHBjHLNXbsFp41RMMZpeWavj0qqkYLb5NgxkpfL0aRGFc)z00cfmDNAixRsPNrPxhTXVcLYiFaV5NkJFfkvIsEpNMl9Wq0ZYBk(9GTNRWJxBkZrq4sQme1rB8RqPmYhWB(PY4xHsLOK3ZP5spCq29S8MIFpy75k8y(jfqdmc7ycl5KcfuMqOoDvctIjp6xmmeuhTXVcLYiFaV5NkJFfkvIsEpNMl9qED0D0g)kukXgIE8Atzoc650CPhqdzUk)LqOcMqOqHWZVM4tp858db8vUKF0KkOHmxNkHObpKRvP0tyCiSRXUi1dZMMMZpeWx5s(rtQGgYCDQeIg8qUwLspn(vOelpBc1qyIDe)FK6kxks9WSbWhXffJKWvQe)0gnnIlkgjHLiHnQKy3PPrCrXijSLaRsIDNxVaC(Ha(kxYpAsf0qMRtLq0G)maMFsb0aJWx5s(rtQGgYCDQeIgm5r)IHHG6On(vOuInef5d49Atzoc650CPhfSenKsE2i)dm65xt8PhSqCrXijCLkjsydaFsgsiuNnWOtILNnHAi9HlGZeuEyj6luOG60rQaAi5HP0CeeKMMKHec1zdm6Ky5ztOgs)N0BhTXVcLsSHOiFapokFrarQthPKm1uN85k8W3RnL5iimhLViGifejbo5ayHJqciK)eZnvLC8qgeWAAo)qaZnvLC8NXlaFM8gtOyq(PXt4QNM2RnL5iiCblrdPKNnY)aJ8cWNZpeWexumssj(Pn4HCTkL67XAAo)qatCrXijLejSbpKRvPuFp2laFSm)KcObgHDmHLCsHcktiuNUkHj10C(Ha2XewYjfkOmHqD6QeMuL29hclpJdK(EqtZ5hcyhtyjNuOGYec1PRsysLnCljS8moq67bVAAHcMUtnKRvP0t20RJ24xHsj2quKpGN8NHAON5aZfK6SbgDYhS9CfE4BOWqsDMJG00C(HaM4IIrskjsydEixRsPNEaaXffJKWvQKiHnagY1Qu6jBShGZeuEyj6luOG60rQaAi5HP0CeeKxaNnWOdFLlPoKcQi9zJ9EAjdjeQZgy0jJCixRsjaFexumscxPYsG10gY1Qu6jmoe21yN3oAJFfkLydrr(aEYZMGjepxHh(C(HawE2emHapuyiPoZrqa8jziHqD2aJojwE2emHWtpOPXY8tkGgye(kxYpAsf0qMRtLq0Gjp6xmmeKxnTZeuEyj6luOG60rQaAi5HP0CeeeaNFiGjUOyKKsIe2GhY1Qu6PhaqCrXijCLkjsydaNFiGLNnbtiWd5Avk98jbiziHqD2aJojwE2emHq)hSNxa(yz(jfqdmclaMBJjvbbrxLWuWeLlJKWKh9lggcst7kxkcIa2dU678dbS8SjycbEixRszKr5fWzdm6Wx5sQdPGksF42rB8RqPeBikYhWtE2emH45k8y(jfqdmcFLl5hnPcAiZ1PsiAWKh9lggccGKHec1zdm6Ky5ztWec9F4ba(yX5hc4RCj)OjvqdzUovcrd(ZaW5hcy5ztWec8qHHK6mhbPP571MYCeegAiZv5VecvWecfkea4Z5hcy5ztWec8qUwLsp9GMMKHec1zdm6Ky5ztWec9JcWzckpS8iHWgf0uHdtP5iiiao)qalpBcMqGhY1Qu6jC961BhTXVcLsSHOiFaVxBkZrqpNMl9qE2emHq5hLNkycHcfcp)AIp9WK3ycfdYpn6Z(07P9XMErSZpeWx5s(rtQGgYCDQeIgS8moqEFAFo)qalpBcMqGhY1QugXEicKmKqO0zYJ8(0(Gqho8hGvOGIe)KWd5AvkJy46fGZpeWYZMGje4pthTXVcLsSHOiFap5zJ8pWONRWJxBkZrqyOHmxL)siubtiuOqaWRnL5iiS8SjycHYpkpvWecfkeaWYRnL5iiCblrdPKNnY)aJ00858dbSJjSKtkuqzcH60vjmPkT7pewEghi99GMMZpeWoMWsoPqbLjeQtxLWKkB4wsy5zCG03dEbiziHqD2aJojwE2emHWt2RJ24xHsj2quKpGNbzmx9skPFBCFMdmxqQZgy0jFW2Zv4blxXbQsyayX4xHsSbzmx9skPFBCvqMRbJWvQcIcMUttdcDydYyU6Lus)24QGmxdgHLNXbYtpaacDydYyU6Lus)24QGmxdgHhY1Qu6Ph6On(vOuInef5d45IqzOg6zoWCbPoBGrN8bBpxHhdfgsQZCeeGZgy0HVYLuhsbvK((yJ9I0NKHec1zdm6Ky5ztOgkIzddxVEJajdjeQZgy0jJCixRsjaF(4iKac5pXCtvjhpKbbmawGMFbHtKIdjb471MYCeeMJYxeqKcIKaNCnnocjGq(tmhLViGi1PJusMAQtIhYGawtJfo6LslpCwW0DQGrE10KmKqOoBGrNelpBc1qE6dUrSp2I8mbLh(8xPYfHsjMsZrqqE9QP5J4IIrs4kvsKWgnnFexumscxPYbD600iUOyKeUsL4N24falNjO8Ws0xOqb1PJub0qYdtP5iiinnNFiGzMYfnqLju2WTS4kMVqAd(1eFs)hrbx98cWNKHec1zdm6Ky5ztOgYt20lI9XwKNjO8WN)kvUiukXuAoccYRxaM8gtOyq(PrF4Q3t78dbS8SjycbEixRsze7XEb4JfNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOPrCrXijCLkjsyJMglC0lLwEyGaEkl9cWyuCDehiVD0g)kukXgII8b8cOHtkuqL29h65k8WyuCDehOoAJFfkLydrr(aEJ9sj6lvHHs4h4NRWdNFiG5MQso(Z0rB8RqPeBikYhWJtcsELjuMOGLUuEpxHhSan)ccNifhsc41MYCeeMdP4OeQUcLa858dbS8Sjycb(ZOPzYBmHIb5Ng9HREEbWIZpeWsKqEfNWFgaS48dbm3uvYXFga(yHJEP0YdNfmDNkyKM2RnL5iimhLViGifejbo5AACesaH8NyokFrarQthPKm1uNe)z00Q8OHbjSJGuHcMUtnKRvP0ZO0lsFCuc9RdZmeVKKYefS0LYdFLlPEnXN86TJ24xHsj2quKpGxLCBs7ku(CfEWc08liCIuCijGxBkZrqyoKIJsO6kucWNZpeWYZMGje4pJMMjVXekgKFA0hU65falo)qalrc5vCc)zaWIZpeWCtvjh)za4Jfo6LslpCwW0DQGrAAV2uMJGWCu(IaIuqKe4KRPXribeYFI5O8fbePoDKsYutDs8NrtRYJggKWocsfky6o1qUwLsp5iKac5pXCu(IaIuNosjzQPojEixRszKESMwLhnmiHDeKkuW0DQHCTkLrqeWg7tpp9GEr6JJsOFDyMH4LKuMOGLUuE4RCj1Rj(KxVD0g)kukXgII8b8ixgKFAuoOe65k8OYJggKWocsfky6o1qUwLspzdUAA(C(HaMzkx0avMqzd3YIRy(cPn4xt8jpJcU6PP58dbmZuUObQmHYgULfxX8fsBWVM4t6)ik4QNxao)qalpBcMqG)ma8XribeYFI5MQsoEixRsP(WvpnnO5xq4eP4qsVD0g)kukXgII8b8Khje2OccBON5aZfK6SbgDYhS9CfEmuyiPoZrqaUYLuhsbvK(SbxasgsiuNnWOtILNnHAipzpagJIRJ4abWNZpeWCtvjhpKRvPuF20ttJfNFiG5MQso(Z4TJ24xHsj2quKpGx4paRqbfj(j9CfEqCrXijCLklbgGXO46ioqaC(HaMzkx0avMqzd3YIRy(cPn4xt8jpJcU6bWhe6WgKXC1lPK(TXvbzUgmcFfhOkHPPXch9sPLhoj(GeObsttYqcH6SbgDs9JYBhTXVcLsSHOiFap5ztWeINRWdNFiGrjD6KkgA4eZvOe)za4Z5hcy5ztWec8qHHK6mhbPPzYBmHIb5Ng9Ji982rB8RqPeBikYhWtE2emH45k8GJEP0YdNfmDNkyeaFV2uMJGWCu(IaIuqKe4KRPXribeYFI5MQso(ZOP58dbm3uvYXFgVa4iKac5pXCu(IaIuNosjzQPojEixRsPNW4qyxJDrmNkHptEJjumi)0ebWvpVaC(HawE2emHapKRvP0t2dalqZVGWjsXHKD0g)kukXgII8b8KNnY)aJEUcp4OxkT8Wzbt3PcgbW3RnL5iimhLViGifejbo5AACesaH8NyUPQKJ)mAAo)qaZnvLC8NXlaocjGq(tmhLViGi1PJusMAQtIhY1Qu6PhdW5hcy5ztWec8NbaXffJKWvQSeyaS8AtzoccxWs0qk5zJ8pWiaSan)ccNifhs2rB8RqPeBikYhWtE2i)dm65k8W5hcyusNoPIliBuVLSqj(ZOP5Jf5ztOgcBmkUoIdeawETPmhbHlyjAiL8Sr(hyKMMpNFiG5MQsoEixRsPNWfGZpeWCtvjh)z00858db8yVuI(svyOe(bgpKRvP0tyCiSRXUiMtLWNjVXekgKFAIapONxao)qap2lLOVufgkHFGXFgVEb8AtzocclpBcMqO8JYtfmHqHcbasgsiuNnWOtILNnbti80dEb4JL5NuanWi8vUKF0KkOHmxNkHObtE0VyyiinnjdjeQZgy0jXYZMGjeE6bVD0g)kukXgII8b8sYVYfHYNRWdFexumscxPYsGbWribeYFI5MQsoEixRsP(WvpnnFCD2aJKpIcWqCD2aJux5sEcxVAACD2aJKp8GxagJIRJ4a1rB8RqPeBikYhWtNjckxekFUcp8rCrXijCLklbgahHeqi)jMBQk54HCTkL6dx9008X1zdms(ikadX1zdmsDLl5jC9QPX1zdms(WdEbymkUoIduhTXVcLsSHOiFaVWxiuUiu(CfE4J4IIrs4kvwcmaocjGq(tm3uvYXd5Avk1hU6PP5JRZgyK8ruagIRZgyK6kxYt46vtJRZgyK8Hh8cWyuCDehOoAJFfkLydrr(aE(Tzk0Oqbfj(j1rB8RqPeBikYhW71MYCe0ZP5spKNnHAivLkjsyZZVM4tpKmKqOoBGrNelpBc1q6ZErgei04Z1KhnaREnXNIy20tViik98gzqGqJpNFiGLNnY)aJuKldYpnUuEkjsydwEghOiG982rB8RqPeBikYhWZ)yNUNRWdIlkgjHf)0gvsS700iUOyKe2sGvjXUdWRnL5iiCjvCbzVKMMZpeWexumssjrcBWd5Avk904xHsS8SjudHj2r8)rQRCjao)qatCrXijLejSb)z00iUOyKeUsLejSbalV2uMJGWYZMqnKQsLejSrtZ5hcyUPQKJhY1Qu6PXVcLy5ztOgctSJ4)Jux5say51MYCeeUKkUGSxcGZpeWCtvjhpKRvP0tIDe)FK6kxcGZpeWCtvjh)z00C(HaESxkrFPkmuc)aJ)maKmKqO0zYJ0xpShdWNKHec1zdm6KE(WdAASCMGYdlrFHcfuNosfqdjpmLMJGG8QPXYRnL5iiCjvCbzVeaNFiG5MQsoEixRsP(e7i()i1vUuhTXVcLsSHOiFap5ztOgQJ24xHsj2quKpG38tLXVcLkrjVNtZLEemH40n)o6oAJFfkLyhKDpg7Ls0xQcdLWpWpxHho)qaZnvLC8NPJ24xHsj2bzxKpG3RnL5iONtZLEWN6s09zE(1eF6blo)qa7ycl5KcfuMqOoDvctQs7(dH)mayX5hcyhtyjNuOGYec1PRsysLnClj8NPJ24xHsj2bzxKpGNbzmx9skPFBCFMdmxqQZgy0jFW2Zv4HZpeWoMWsoPqbLjeQtxLWKQ0U)qy5zCG8K9a48dbSJjSKtkuqzcH60vjmPYgULewEghipzpa(ybcDydYyU6Lus)24QGmxdgHVIduLWaWIXVcLydYyU6Lus)24QGmxdgHRufefmDhaFSaHoSbzmx9skPFBCv6itGVIduLW00Gqh2GmMREjL0VnUkDKjWd5Avk13dE10Gqh2GmMREjL0VnUkiZ1Gry5zCG80daGqh2GmMREjL0VnUkiZ1Gr4HCTkLEcxaqOdBqgZvVKs63gxfK5AWi8vCGQeM3oAJFfkLyhKDr(aECu(IaIuNosjzQPo5Zv4HVxBkZrqyokFrarkiscCYbWchHeqi)jMBQk54HmiG10C(HaMBQk54pJxa(C(Ha2XewYjfkOmHqD6QeMuL29hclpJd0d4QP58dbSJjSKtkuqzcH60vjmPYgULewEghOhW1RMwOGP7ud5Avk9Kn96On(vOuIDq2f5d4XTKtcLZpeEonx6H8SrGgONRWdFo)qa7ycl5KcfuMqOoDvctQs7(dHhY1QuQp7HHRMMZpeWoMWsoPqbLjeQtxLWKkB4ws4HCTkL6ZEy46fGjVXekgKFA0)rePhaFCesaH8NyUPQKJhY1QuQ)tQP5JJqciK)etUmi)0OCqjeEixRsP(pjawC(HagOkHgcsrUmi)04s5POKgyf8t4pdao6LslpmqapLLE92rB8RqPe7GSlYhWtE2emH45k84mbLhwEKqyJcAQWHP0CeeeajDxLWKyjsGuqtfoao)qalpBcMqGHq(ZoAJFfkLyhKDr(aEYZg5FGrpxHhS8AtzoccZN6s09za4JJEP0YdNfmDNkyKMghHeqi)jMBQk54HCTkL6)KAAS8AtzoccZHuCucvxHsaSWrVuA5Hbc4PSutZhhHeqi)jMCzq(Pr5Gsi8qUwLs9FsaS48dbmqvcneKICzq(PXLYtrjnWk4NWFgaC0lLwEyGaEkl96TJ24xHsj2bzxKpGN8Sr(hy0Zv4HpocjGq(tmhLViGi1PJusMAQtIhY1Qu6jCbWc08liCIuCijaFV2uMJGWCu(IaIuqKe4KRPXribeYFI5MQsoEixRsPNW1lGxBkZrqyoKIJsO6ku6fGjVXekgKFA0N90dah9sPLholy6ovWiaSan)ccNifhs2rB8RqPe7GSlYhW71MYCe0ZP5spGqNAip6xd5s5jF(1eF6HpNFiG5MQsoEixRsP(WfGpNFiGh7Ls0xQcdLWpW4HCTkL6dxnnwC(HaESxkrFPkmuc)aJ)mE10yX5hcyUPQKJ)mEb4JfNFiGbQsOHGuKldYpnUuEkkPbwb)e(Z4fGpNFiGjUOyKKsIe2GhY1QuQpmoe21yNMMZpeWexumssj(Pn4HCTkL6dJdHDn25TJ24xHsj2bzxKpGN8NHAON5aZfK6SbgDYhS9CfEmuyiPoZrqaoBGrh(kxsDifur6ZMhdWyuCDehiaV2uMJGWqOtnKh9RHCP8KD0g)kukXoi7I8b8CrOmud9mhyUGuNnWOt(GTNRWJHcdj1zoccWzdm6Wx5sQdPGksF28agUamgfxhXbcWRnL5iime6ud5r)AixkpzhTXVcLsSdYUiFap5rcHnQGWg6zoWCbPoBGrN8bBpxHhdfgsQZCeeGZgy0HVYLuhsbvK(S5XroKRvPeGXO46ioqaETPmhbHHqNAip6xd5s5j7On(vOuIDq2f5d4fqdNuOGkT7p0Zv4HXO46ioqD0g)kukXoi7I8b8c)byfkOiXpPNRWdFexumscxPYsG10iUOyKewIe2OQuXMMgXffJKWIFAJQsfBEb4Jfo6LslpCwW0DQGrAAqZVGWjsXHKAA(m5nMqXG8tJNreCb471MYCeeMp1LO7ZOPzYBmHIb5Ngp9GEAAV2uMJGWLuziYlaFV2uMJGWCu(IaIuqKe4KdGfocjGq(tmhLViGi1PJusMAQtI)mAAS8AtzoccZr5lcisbrsGtoaw4iKac5pXCtvjh)z861laFCesaH8NyUPQKJhY1QuQVh0ttdA(feorkoKutZK3ycfdYpn6hr6bGJqciK)eZnvLC8NbGpocjGq(tm5YG8tJYbLq4HCTkLEA8RqjwE2eQHWe7i()i1vUKMglC0lLwEyGaEkl9QPv5rddsyhbPcfmDNAixRsPNSPNxa(Gqh2GmMREjL0VnUkiZ1Gr4HCTkL6ZEAASWrVuA5HtIpibAG82rB8RqPe7GSlYhWJCzq(Pr5GsONRWdFexumscl(PnQKy3PPrCrXijSejSrLe7onnIlkgjHTeyvsS700C(Ha2XewYjfkOmHqD6QeMuL29hcpKRvPuF2ddxnnNFiGDmHLCsHcktiuNUkHjv2WTKWd5Avk1N9WWvtZK3ycfdYpn6hr6bGJqciK)eZnvLC8qgeWaybA(feorkoK0laFCesaH8NyUPQKJhY1QuQVh0ttJJqciK)eZnvLC8qgeWE10Q8OHbjSJGuHcMUtnKRvP0t20RJ24xHsj2bzxKpGhNeK8ktOmrblDP8EUcpybA(feorkoKeWRnL5iimhsXrjuDfkb4ZNjVXekgKFA0pI0dGpNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOPXch9sPLhgiGNYsVAAo)qa7iqiiXxE4pdaNFiGDeieK4lp8qUwLspJsVi9Xrj0VomZq8ssktuWsxkp8vUK61eFYRxnTkpAyqc7iivOGP7ud5Avk9mk9I0hhLq)6WmdXljPmrblDP8Wx5sQxt8jVAAC0lLwE4SGP7ubJ8cWhlC0lLwE4SGP7ubJ00ETPmhbH5O8fbePGijWjxtJJqciK)eZr5lcisD6iLKPM6K4HmiG92rB8RqPe7GSlYhWRsUnPDfkFUcpybA(feorkoKeWRnL5iimhsXrjuDfkb4ZNjVXekgKFA0pI0dGpNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOPXch9sPLhgiGNYsVAAo)qa7iqiiXxE4pdaNFiGDeieK4lp8qUwLsp9GEr6JJsOFDyMH4LKuMOGLUuE4RCj1Rj(KxVAAvE0WGe2rqQqbt3PgY1Qu6Ph0lsFCuc9RdZmeVKKYefS0LYdFLlPEnXN8QPXrVuA5HZcMUtfmYlaFSWrVuA5HZcMUtfmst71MYCeeMJYxeqKcIKaNCnnocjGq(tmhLViGi1PJusMAQtIhYGa2BhTXVcLsSdYUiFaVxBkZrqpNMl9WKmryOjM4p)AIp9G4IIrs4kvIFAteZ(IaJFfkXYZMqneMyhX)hPUYLIKfIlkgjHRuj(PnrShhbg)kuI9p2PdtSJ4)Jux5srQhoQiqYqcHsNjpQJ24xHsj2bzxKpGN8Sr(hy0Zv4HVkpAyqc7iivOGP7ud5Avk9K900858db8yVuI(svyOe(bgpKRvP0tyCiSRXUiMtLWNjVXekgKFAIapONxao)qap2lLOVufgkHFGXFgVE108zYBmHIb5NMiFTPmhbHnjtegAIjEe78dbmXffJKusKWg8qUwLYiHqho8hGvOGIe)KWxXbsQgY1QmIJcdx9zlk900m5nMqXG8ttKV2uMJGWMKjcdnXepID(HaM4IIrskXpTbpKRvPmsi0Hd)byfkOiXpj8vCGKQHCTkJ4OWWvF2IspVaiUOyKeUsLLadWNpw4iKac5pXCtvjh)z004OxkT8Wab8uwcGfocjGq(tm5YG8tJYbLq4pJxnno6LslpCwW0DQGrEb4Jfo6Lslp8lLNoGhnnwC(HaMBQk54pJMMjVXekgKFA0pI0ZRMMZpeWCtvjhpKRvPuF2hawC(HaESxkrFPkmuc)aJ)mD0g)kukXoi7I8b8sYVYfHYNRWdFo)qatCrXijL4N2G)mAA(46SbgjFefGH46SbgPUYL8eUE1046SbgjF4bVamgfxhXbQJ24xHsj2bzxKpGNoteuUiu(CfE4Z5hcyIlkgjPe)0g8NrtZhxNnWi5JOamexNnWi1vUKNW1RMgxNnWi5dp4fGXO46ioqD0g)kukXoi7I8b8cFHq5Iq5Zv4HpNFiGjUOyKKs8tBWFgnnFCD2aJKpIcWqCD2aJux5sEcxVAACD2aJKp8GxagJIRJ4a1rB8RqPe7GSlYhWZVntHgfkOiXpPoAJFfkLyhKDr(aEYZMqn0Zv4bXffJKWvQe)0gnnIlkgjHLiHnQKy3PPrCrXijSLaRsIDNMMZpeW(Tzk0Oqbfj(jH)maC(HaM4IIrskXpTb)z00858dbm3uvYXd5Avk904xHsS)XoDyIDe)FK6kxcGZpeWCtvjh)z82rB8RqPe7GSlYhWZ)yNUoAJFfkLyhKDr(aEZpvg)kuQeL8Eonx6rWeIt387O7On(vOuIdMqC6M)d5zJ8pWONRWdwMFsb0aJWoMWsoPqbLjeQtxLWKyYJ(fddb1rB8RqPehmH40n)iFap5pd1qpZbMli1zdm6Kpy75k8acDyxekd1q4HCTkL6pKRvPSJ24xHsjoycXPB(r(aEUiugQH6O7On(vOuIL3d5zJ8pWONRWJ5NuanWi8vUKF0KkOHmxNkHObtE0Vyyiia(iUOyKeUsLLadGfF(C(Ha(kxYpAsf0qMRtLq0GhY1QuQpmoe21yxK6HzdGpIlkgjHRu5GoDAAexumscxPsIe2OPrCrXijS4N2OsIDNxnnNFiGVYL8JMubnK56ujen4HCTkL6B8RqjwE2eQHWe7i()i1vUuK6HzdGpIlkgjHRuj(PnAAexumsclrcBujXUttJ4IIrsylbwLe7oVE10yX5hc4RCj)OjvqdzUovcrd(Z4vtZNZpeWCtvjh)z00ETPmhbH5O8fbePGijWj3laocjGq(tmhLViGi1PJusMAQtIhYGa2BhTXVcLsS8I8b8miJ5Qxsj9BJ7ZCG5csD2aJo5d2EUcpybcDydYyU6Lus)24QGmxdgHVIduLWaWIXVcLydYyU6Lus)24QGmxdgHRufefmDhaFSaHoSbzmx9skPFBCv6itGVIduLW00Gqh2GmMREjL0VnUkDKjWd5Avk1hUE10Gqh2GmMREjL0VnUkiZ1Gry5zCG80daGqh2GmMREjL0VnUkiZ1Gr4HCTkLE6baqOdBqgZvVKs63gxfK5AWi8vCGQewhTXVcLsS8I8b84O8fbePoDKsYutDYNRWdFV2uMJGWCu(IaIuqKe4KdGfocjGq(tm3uvYXdzqaRP58dbm3uvYXFgVam5nMqXG8tJNSNEa858dbmXffJKuIFAdEixRsP(SPNMMZpeWexumssjrcBWd5Avk1Nn98QPfky6o1qUwLspztVoAJFfkLy5f5d49Atzoc650CPhqOtnKh9RHCP8Kp)AIp9WNZpeWCtvjhpKRvPuF4cWNZpeWJ9sj6lvHHs4hy8qUwLs9HRMglo)qap2lLOVufgkHFGXFgVAAS48dbm3uvYXFgnntEJjumi)04Ph0ZlaFS48dbmqvcneKICzq(PXLYtrjnWk4NWFgnntEJjumi)04Ph0ZlaFo)qatCrXijLejSbpKRvPuFyCiSRXonnNFiGjUOyKKs8tBWd5Avk1hghc7ASZBhTXVcLsS8I8b8CrOmud9mhyUGuNnWOt(GTNRWJHcdj1zoccWzdm6Wx5sQdPGksF2IcGpJrX1rCGa8AtzoccdHo1qE0VgYLYt6TJ24xHsjwEr(aEYFgQHEMdmxqQZgy0jFW2Zv4XqHHK6mhbb4SbgD4RCj1HuqfPpBrbWNXO46ioqaETPmhbHHqNAip6xd5s5j92rB8RqPelViFap5rcHnQGWg6zoWCbPoBGrN8bBpxHhdfgsQZCeeGZgy0HVYLuhsbvK(S5Xa8zmkUoIdeGxBkZrqyi0PgYJ(1qUuEsVD0g)kukXYlYhWlGgoPqbvA3FONRWdJrX1rCG6On(vOuILxKpG3yVuI(svyOe(b(5k8W5hcyUPQKJ)mD0g)kukXYlYhWJCzq(Pr5GsONRWdF(C(HaM4IIrskjsydEixRsP(SPNMMZpeWexumssj(Pn4HCTkL6ZMEEbWribeYFI5MQsoEixRsP(Eqpa(C(HaMzkx0avMqzd3YIRy(cPn4xt8jpJI90ttJL5NuanWimZuUObQmHYgULfxX8fsBWKh9lggcYRxnnNFiGzMYfnqLju2WTS4kMVqAd(1eFs)hr9K6PPXribeYFI5MQsoEidcya(m5nMqXG8tJ(rKEAAV2uMJGWLuziYBhTXVcLsS8I8b84KGKxzcLjkyPlL3Zv4blqZVGWjsXHKaETPmhbH5qkokHQRqjaFM8gtOyq(Pr)ispa(C(HagOkHgcsrUmi)04s5POKgyf8t4pJMglC0lLwEyGaEkl9QPXrVuA5HZcMUtfmst71MYCeeUKkdrAAo)qa7iqiiXxE4pdaNFiGDeieK4lp8qUwLspJsVi95lII45NuanWimZuUObQmHYgULfxX8fsBWKh9lggcYBK(4Oe6xhMziEjjLjkyPlLh(kxs9AIp51RxaS48dbm3uvYXFga(yHJEP0YdNfmDNkyKMghHeqi)jMJYxeqK60rkjtn1jXFgnTkpAyqc7iivOGP7ud5Avk9KJqciK)eZr5lcisD6iLKPM6K4HCTkLr6XAAvE0WGe2rqQqbt3PgY1QugbraBSp98mk9I0hhLq)6WmdXljPmrblDP8Wx5sQxt8jVE7On(vOuILxKpGxLCBs7ku(CfEWc08liCIuCijGxBkZrqyoKIJsO6kucWNjVXekgKFA0pI0dGpNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOPXch9sPLhgiGNYsVAAC0lLwE4SGP7ubJ00ETPmhbHlPYqKMMZpeWocecs8Lh(ZaW5hcyhbcbj(YdpKRvP0tpOxK(8frr88tkGgyeMzkx0avMqzd3YIRy(cPnyYJ(fddb5nsFCuc9RdZmeVKKYefS0LYdFLlPEnXN861lawC(HaMBQk54pdaFSWrVuA5HZcMUtfmstJJqciK)eZr5lcisD6iLKPM6K4pJMwLhnmiHDeKkuW0DQHCTkLEYribeYFI5O8fbePoDKsYutDs8qUwLYi9ynTkpAyqc7iivOGP7ud5AvkJGiGn2NEE6b9I0hhLq)6WmdXljPmrblDP8Wx5sQxt8jVE7On(vOuILxKpG3RnL5iONtZLEiTxsfqJIBQk5p)AIp9GfocjGq(tm3uvYXdzqaRPXYRnL5iimhLViGifejbo5a4OxkT8Wzbt3PcgPPbn)ccNifhs2rB8RqPelViFaVWFawHcks8t65k8G4IIrs4kvwcmaJrX1rCGa48dbmZuUObQmHYgULfxX8fsBWVM4tEgf7PhaFqOdBqgZvVKs63gxfK5AWi8vCGQeMMglC0lLwE4K4dsGgiVaETPmhbHL2lPcOrXnvL8oAJFfkLy5f5d4jpBcMq8CfE48dbmkPtNuXqdNyUcL4pdaNFiGLNnbtiWdfgsQZCeuhTXVcLsS8I8b84wYjHY5hcpNMl9qE2iqd0Zv4HZpeWYZgbAGWd5Avk9eUa858dbmXffJKusKWg8qUwLs9HRMMZpeWexumssj(Pn4HCTkL6dxVam5nMqXG8tJ(rKED0g)kukXYlYhWtE2emH45k84mbLhwEKqyJcAQWHP0CeeeajDxLWKyjsGuqtfoao)qalpBcMqGHq(ZoAJFfkLy5f5d4jpBK)bg9CfEWrVuA5HZcMUtfmcWRnL5iimhLViGifejbo5a4iKac5pXCu(IaIuNosjzQPojEixRsPNWfalqZVGWjsXHKD0g)kukXYlYhWtE2emH45k84mbLhwEKqyJcAQWHP0Ceeeawotq5HLNnc0aHP0CeeeaNFiGLNnbtiWdfgsQZCeeaFo)qatCrXijL4N2GhY1QuQVhdG4IIrs4kvIFAdaNFiGzMYfnqLju2WTS4kMVqAd(1eFYZOGREAAo)qaZmLlAGktOSHBzXvmFH0g8Rj(K(pIcU6bWK3ycfdYpn6hr6PPbHoSbzmx9skPFBCvqMRbJWd5Avk1N9PPz8Rqj2GmMREjL0VnUkiZ1Gr4kvbrbt35falCesaH8NyUPQKJhYGaUJ24xHsjwEr(aEYZg5FGrpxHho)qaJs60jvCbzJ6TKfkXFgnnNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZOP58dbm3uvYXFga(C(HaESxkrFPkmuc)aJhY1Qu6jmoe21yxeZPs4ZK3ycfdYpnrGh0ZlaNFiGh7Ls0xQcdLWpW4pJMglo)qap2lLOVufgkHFGXFgaSWribeYFIh7Ls0xQcdLWpW4HmiG10yHJEP0Yd)s5Pd4XRMMjVXekgKFA0pI0daXffJKWvQSe4oAJFfkLy5f5d4jpBK)bg9CfECMGYdlpBeObctP5iiiaSm)KcObgHVYL8JMubnK56ujenyYJ(fddbbWNZpeWYZgbAGWFgnntEJjumi)0OFePNxao)qalpBeObclpJdKNEaGpNFiGjUOyKKsIe2G)mAAo)qatCrXijL4N2G)mEb48dbmZuUObQmHYgULfxX8fsBWVM4tEg1tQhaFCesaH8NyUPQKJhY1QuQpB6PPXYRnL5iimhLViGifejbo5a4OxkT8Wzbt3Pcg5TJ24xHsjwEr(aEYZg5FGrpxHhSm)KcObgHVYL8JMubnK56ujenyYJ(fddbbWNZpeWmt5IgOYekB4wwCfZxiTb)AIp5zupPEAAo)qaZmLlAGktOSHBzXvmFH0g8Rj(KNrbx9aCMGYdlpsiSrbnv4WuAoccYlaNFiGjUOyKKsIe2GhY1QuQ)tcG4IIrs4kvsKWgaS48dbmkPtNuXqdNyUcL4pdawotq5HLNnc0aHP0CeeeaocjGq(tm3uvYXd5Avk1)jb4JJqciK)eduLqdbPKm1uNepKRvPu)NutJfo6LslpmqapLLE7On(vOuILxKpGxs(vUiu(CfE4Z5hcyIlkgjPe)0g8NrtZhxNnWi5JOamexNnWi1vUKNW1RMgxNnWi5dp4fGXO46ioqaETPmhbHL2lPcOrXnvL8oAJFfkLy5f5d4PZebLlcLpxHh(C(HaM4IIrskXpTb)zaWch9sPLhgiGNYsnnFo)qaduLqdbPixgKFACP8uusdSc(j8Nbah9sPLhgiGNYsVAA(46SbgjFefGH46SbgPUYL8eUE1046SbgjF4bnnNFiG5MQso(Z4fGXO46ioqaETPmhbHL2lPcOrXnvL8oAJFfkLy5f5d4f(cHYfHYNRWdFo)qatCrXijL4N2G)mayHJEP0YddeWtzPMMpNFiGbQsOHGuKldYpnUuEkkPbwb)e(ZaGJEP0YddeWtzPxnnFCD2aJKpIcWqCD2aJux5sEcxVAACD2aJKp8GMMZpeWCtvjh)z8cWyuCDehiaV2uMJGWs7Lub0O4MQsEhTXVcLsS8I8b88BZuOrHcks8tQJ24xHsjwEr(aEYZMqn0Zv4bXffJKWvQe)0gnnIlkgjHLiHnQKy3PPrCrXijSLaRsIDNMMZpeW(Tzk0Oqbfj(jH)maC(HaM4IIrskXpTb)z00858dbm3uvYXd5Avk904xHsS)XoDyIDe)FK6kxcGZpeWCtvjh)z82rB8RqPelViFap)JD66On(vOuILxKpG38tLXVcLkrjVNtZLEemH40nFWd8abb]] )


end