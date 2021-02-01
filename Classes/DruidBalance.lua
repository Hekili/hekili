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


    spec:RegisterPack( "Balance", 20210131, [[d8u9oeqikv9ifIUeaL2eL4tquzukuNsv0QaOQxPqAwquUfLIQDj4xaKHjs6yukTma4zuQyAusPRri12aO4BesY4iKuNtKswhLkX8aq3JqSprQoievTqrkEiLKMiLkPlsiXgPuu8rfcuNuKsTsrIxsPOKMjLk1nviqANus8tkfLyOke0sviGNQGPsjvxLsk2QcbIVcqfJfGkTxc(ROgmPdt1IfYJPyYaDzKnROpdOrRkDAPwnLIs9AvHzt0TfQDl53GgoKoUcHwUkphQPR01vvBhcFNqnEkfopez9ukY8fX(rTGTcwxya0xsWkaivayBQ2AhBdaivBfvaiTegwKqjHbu38WbscdLhtcdPXLEziHbuhjj0bfSUWag(pdjm8Ulk2UaiabS33FuWaJbeUJ)sFByzoFUac3Xgajme9B5M2LqKWaOVKGvaqQaW2uT1o2gSnTeT1AN0syW)7l8egg6yRkm82GGujejmasyJWWihjRPXLEziwTR3Vb5ug5iznfV((HeR2XwKXkasfa2YPWPmYrYQvF9ciHTlCkJCKSAZzf5bbjqwhGs)ynnKhh4ug5iz1MZQvF9cibY66hqAZ9KvJJjmRlKvdsgjLx)asloWPmYrYQnN1rakgIGaz9xfzim2pKyfHFThjjmRJ7afqgROhHiJx)W)diXQnpDwrpcraV(H)hq6zGtzKJKvBoRipcydYk6rghVDbKvaNZ3xw7jR9ICyw3xIvXhSaYQOyKnkMcCkJCKSAZzDeu)bXQvHfc4dI19LyDaTVEXS6Sk7DLeRXWJyDkjB0rsI1X9KvKGFwFDWc5wwF7L1Ezf3XF56fb)yjsSkU3xwtJnliV1zDuwTkjj82UKvKx2aRyQwKXAVihiR4hn6ZGWGSXlwW6cdG00)YvW6cwXwbRlm4MTHLWagk9lhrESWavEKKafsJWkyfaiyDHbQ8ijbkKgHbiQWaMwHb3SnSegq4x7rssyaHl)KWagLKY86hqAXb8630LswtNvBz1cRJz1Ewxxs1gWRFs4bgOYJKeiRjjSUUKQnGxsk9ldE9Cdu5rscK1NSMKWkgLKY86hqAXb8630LswtNvaimGWVC5XKWqJZoKegajS5A0THLWWaTywrEOOWkSy1oJYQ4EFH)LvWRNlREbYQ4EFzDy9tcpqw9cKvamkRW9LoXnMewbRyhbRlmqLhjjqH0imarfgW0km4MTHLWac)ApsscdiC5NegWOKuMx)asloGx)M9rSMoR2kmGWVC5XKWqJZgj5iiHbqcBUgDByjmmqlMvJKCeeRIFPI1H1VzFeRgVy9TxwbWOSU(bKwmRIFBZlRnM1JKecVwwNWJ19LyvumYgftSUqwJiwrpAs3rGcRGvSwbRlmqLhjjqH0imyUEPRDHHXSApRgicQ8Advd8DZtNynjHv7z1aHsqO4kyGfc4dkVVugJ2xV4WhL1NSAH1O)CgmEUlt4Jkm4MTHLWqeDy6E0fqHbqcBUgDByjmynyI1i6W09OlGSkU3xwnoRWJvFU0XQvHfc4dI1Uy14cRGveTG1fgOYJKeOqAegCZ2WsyafUnSegmxV01UWq0Fodgp3LjCuS3fM10z12ufgajS5A0THLWWieUSkU3xwnoR7RVS24c5wwDwhHFj2pwrpOryfScGrW6cdu5rscuincdquHbmTcdUzByjmGWV2JKKWacx(jHbd1swhZ6yw7APdfk9LaZZg47Mpk27cZQnNvBfnR2CwnqOeekUcgp3LjCuS3fM1NSciwTvuNkRpzvewnulzDmRJzTRLouO0xcmpBGVB(OyVlmR2CwTv0SAZz1waKkR2CwnqOeekUcgyHa(GY7lLXO91loCuS3fM1NSciwTvuNkRpznjHvdekbHIRGXZDzchf7DHznDw7APdfk9LaZZg47Mpk27cZAscRgiuccfxbdSqaFq59LYy0(6fhok27cZA6S21shku6lbMNnW3nFuS3fMvBoR2MkRjjSApRgicQ8Advd8DZtNegq4xU8ysyWaleWhugKWivgHbqcBUgDByjmyvxA(sFjmRIFP9Low)4UaYQvHfc4dI1ckMvXTuYQlLqXSIe8Z6czfVTuYQXXlR7lXk2Jjw9y4VwwHtwTkSqaFqJAvKhqPDzy144flScwrujyDHbQ8ijbkKgHbiQWaMwHb3SnSegq4x7rssyaHl)KWWywTNvAe)nkkbgOyuKoYLz4bwEziwtsy1aHsqO4kqXOiDKlZWdS8YqHJI9UWScqwTfWKkRwy1EwnqOeekUcumksh5Ym8alVmu4ihejwFYAscRgicQ8Adpq6AVegq4xU8ysyWaMnWcS3gwcdGe2Cn62WsyWAWeiRlKvqs6iX6(sS(XoqIv4KvRI8akTldRIFPI1pUlGScc)rsIvyX6htcRGve1cwxyGkpssGcPryO8ysyGIrr6ixMHhy5LHegajS5A0THLWG1GjwfLyuKoYLSAZYbwEziwbqQyYGznIMWJy1z1QipGs7YW6htbHbZ1lDTlmyGqjiuCfmEUlt4OyVlmRaKvaKkRwy1aHsqO4kyGfc4dkVVugJ2xV4WrXExywbiRaivwtsyD2aF38rXExywbiR2rujm4MTHLWafJI0rUmdpWYldjScwjTeSUWavEKKafsJWq5XKWag(LsA3UaMVFescdGe2Cn62WsyWAWeRdWVusBxazDe4hHeRagmzWSgrt4rS6SAvKhqPDzy9JPGWG56LU2fgmqOeekUcgp3LjCuS3fMvaYkGHvlSApRi8R9ijfmWcb8bLbjmsLH1KewnqOeekUcgyHa(GY7lLXO91loCuS3fMvaYkGHvlSIWV2JKuWaleWhugKWivgwtsyD2aF38rXExywbiRaq0cdUzByjmGHFPK2TlG57hHKWkyfBtvW6cdu5rscuincdLhtcdDHn3F9ijLhXVx7podsiAdjm4MTHLWqxyZ9xpss5r871(JZGeI2qcdMRx6Axyi6pNbJN7Ye(OcRGvS1wbRlmqLhjjqH0imyUEPRDHHXSIWV2JKuaw5pMY711dAzvewTL1Kewr4x7rskaR8ht5966bTSkcR2H1NSAH1XSg9NZGXZDzcFuwtsy1aHsqO4ky8CxMWrXExywhLvaWA6SUxxpOnS2gmqOeekUcG)Z3gwSAH1XSApRgicQ8Advd8DZtNynjHv7zfHFThjPGbwiGpOmiHrQmS(KvlSApRgicQ8Adpq6AVynjHvdebvETHQb(U5PtSAHve(1EKKcgyHa(GYGegPYWQfwnqOeekUcgyHa(GY7lLXO91lo8rz1cR2ZQbcLGqXvW45UmHpkRwyDmRJzn6pNbYiBumLL)YVWrXExywtNvBtL1KewJ(ZzGmYgftzmu6x4OyVlmRPZQTPY6twTWQ9SE)IMWdifICPxgkdNzxkZ7BxaXbQ8ijbYAscRJzn6pNHix6LHYWz2LY8(2fqCU89FuaVU5bRIWQOznjH1O)CgICPxgkdNzxkZ7BxaXz)mErb86MhSkcRIM1NS(K1KewJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWhL1NSMKW6Sb(U5JI9UWScqwbqQSMKWkc)ApssbyL)ykVxxpOLvrynvHb3SnSeg2RRh0ARWaiHnxJUnSegS(BJzTXS6SE((shRK0JGNVeRIDKyDHSg7piwDPKvyX6htSIxFzDVUEqlM1fYAeXQSlcK1pkRI79LvRI8akTldREbYQvHfc4dIvVaz9Jjw3xIvauGSILWLvyXQbK1EYAeCFzDVUEqlMv)iwHfRFmXkE9L1966bTyHvWk2cabRlmqLhjjqH0imyUEPRDHbe(1EKKcWk)XuEVUEqlRIWQDy1cR2Z6ED9G2WAB4ihePSbcLGqXfRjjSoM1O)CgmEUlt4JYAscRgiuccfxbJN7Yeok27cZ6OScawtN1966bTHfabdekbHIRa4)8THfRwyDmR2ZQbIGkV2q1aF380jwtsy1Ewr4x7rskyGfc4dkdsyKkdRpz1cR2ZQbIGkV2WdKU2lwtsy1arqLxBOAGVBE6eRwyfHFThjPGbwiGpOmiHrQmSAHvdekbHIRGbwiGpO8(szmAF9IdFuwTWQ9SAGqjiuCfmEUlt4JYQfwhZ6ywJ(ZzGmYgftz5V8lCuS3fM10z12uznjH1O)CgiJSrXugdL(fok27cZA6SABQS(KvlSApR3VOj8asHix6LHYWz2LY8(2fqCGkpssGSMKW6ywJ(ZziYLEzOmCMDPmVVDbeNlF)hfWRBEWQiSkAwtsyn6pNHix6LHYWz2LY8(2fqC2pJxuaVU5bRIWQOz9jRpz9jRjjSg9NZWJUapcmtXOqX0ft1MPIoGTnrHpkRjjSoBGVB(OyVlmRaKvaKkRjjSIWV2JKuaw5pMY711dAzvewtvyWnBdlHH966bTaqyfSIT2rW6cdu5rscuincdMRx6Axyi6pNbJN7Ye(OSMKWQbIGkV2q1aF380jwTWkc)ApssbdSqaFqzqcJuzy1cRgiuccfxbdSqaFq59LYy0(6fh(OSAHv7z1aHsqO4ky8CxMWhLvlSoM1XSg9NZazKnkMYYF5x4OyVlmRPZQTPYAscRr)5mqgzJIPmgk9lCuS3fM10z12uz9jRwy1EwVFrt4bKcrU0ldLHZSlL59TlG4avEKKaznjH17x0eEaPqKl9Yqz4m7szEF7cioqLhjjqwTW6ywJ(ZziYLEzOmCMDPmVVDbeNlF)hfWRBEWA6SAhwtsyn6pNHix6LHYWz2LY8(2fqC2pJxuaVU5bRPZQDy9jRpznjH1O)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rznjH1zd8DZhf7DHzfGScGufgCZ2Wsy4JPCVumwyaKWMRr3gwcdwdMWS6sjRW9LowHfRFmXAVumMvyXQbuyfSITwRG1fgOYJKeOqAegajS5A0THLWGDLmniXQB2gwSkB8YAKJjqwHfR4E)(2WcqscyJfgCZ2Wsy4(v2nBdRSSXRWaEV2ScwXwHbZ1lDTlmGWV2JKuOXzhscdYgV5YJjHbhscRGvSv0cwxyGkpssGcPryWC9sx7cd3VOj8asHix6LHYWz2LY8(2fqCGgXFJIsGcd49AZkyfBfgCZ2Wsy4(v2nBdRSSXRWGSXBU8ysyic6RWkyfBbmcwxyGkpssGcPryWnBdlHH7xz3SnSYYgVcdYgV5YJjHb8kScRWqe0xbRlyfBfSUWavEKKafsJWG56LU2fgI(ZzW45UmHpQWGB2gwcdNJGk4hNNhv2escdGe2Cn62WsyWM5OYMqIvX9(YQvrEaL2LryfScaeSUWavEKKafsJWaevyatRWGB2gwcdi8R9ijjmGWLFsyWEwJ(ZziYLEzOmCMDPmVVDbeNlF)hf(OSAHv7zn6pNHix6LHYWz2LY8(2fqC2pJxu4JkmGWVC5XKWG56TG7hvyaKWMRr3gwcdw9LmpWS2tw3xIvZ1lRr)5K1gZAbxw)OSoHhRsFPJ1pMewbRyhbRlmqLhjjqH0imyUEPRDHHO)CgICPxgkdNzxkZ7BxaX5Y3)rb86MhScqwTwwTWA0FodrU0ldLHZSlL59TlG4SFgVOaEDZdwbiRwlRwyDmR2ZkiCdoOJUnckJf7xCg0JDGuyBZJUaYQfwTNv3SnScoOJUnckJf7xCg0JDGuOR8u2aFxwTW6ywTNvq4gCqhDBeugl2V48l5YW2MhDbK1KewbHBWbD0TrqzSy)IZVKldhf7DHznDwTdRpznjHvq4gCqhDBeugl2V4mOh7aPaEDZdwbiR2HvlScc3Gd6OBJGYyX(fNb9yhifok27cZkazv0SAHvq4gCqhDBeugl2V4mOh7aPW2MhDbK1NcdUzByjm4Go62iOmwSFXcdgKmskV(bKwSGvSvyfSI1kyDHbQ8ijbkKgHbZ1lDTlmmMve(1EKKcgyHa(GYGegPYWQfwTNvdekbHIRGXZDzch5GiXAscRr)5my8CxMWhL1NSAH1XSg9NZqKl9Yqz4m7szEF7ciox((pkGx38Gvryv0SMKWA0FodrU0ldLHZSlL59TlG4SFgVOaEDZdwfHvrZ6twtsyD2aF38rXExywbiR2MQWGB2gwcdgyHa(GY7lLXO91lwyaKWMRr3gwcdwdMy1QWcb8bXkiHsfyxazfwSIrQmS(rzvCVVSAvKhqPDzyfwSAazfESgHeRI9E7ciRleiTV0XQ4EFz1z1C9YA0FofwbRiAbRlme9NZC5XKWaE9tcpqHbZ1lDTlmmM1O)CgICPxgkdNzxkZ7BxaX5Y3)rHJI9UWSMoRwBq0SMKWA0FodrU0ldLHZSlL59TlG4SFgVOWrXExywtNvRniAwFYQfwD8EUmJcfthRPlcRPvQSAH1XSAGqjiuCfmEUlt4OyVlmRPZQOI1KewhZQbcLGqXvGIrHIPlhblWWrXExywtNvrfRwy1EwJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWhLvlSAGiOYRn8aPR9I1NS(uyGkpssGcPryaKWMRr3gwcdw1ldjzDy9tcpqwf37lRscJzDF9IvadRyYGz9OyVRUaYQxGS6rW)Y6czf8hJY6W6h(FajSWGB2gwcdgVmKmh9NtHvWkagbRlmqLhjjqH0imyUEPRDHH1LuTb8ssPFzWRNBGkpssGSAHvmTBxaXbmucZGxpxwTWA0Fod41VPlLbqO4syWnBdlHb8630LsHvWkIkbRlmqLhjjqH0imyUEPRDHb7zfHFThjPG56TG7hLvlSoMvdebvETHQb(U5PtSMKWQbcLGqXvW45UmHJI9UWSMoRIkwtsy1Ewr4x7rskyaZgyb2BdlwTWQ9SAGiOYRn8aPR9I1KewhZQbcLGqXvGIrHIPlhblWWrXExywtNvrfRwy1EwJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWhLvlSAGiOYRn8aPR9I1NS(uyWnBdlHb86h(FajHbqcBUgDByjmyx)XOSoS(H)hqcZQ4EFzDFjwnxVSg9Ntw9cK1iAcpI1pUlGSAvyHa(GewbRiQfSUWavEKKafsJWG56LU2fggZQbcLGqXvWaleWhuEFPmgTVEXHJI9UWScqwfnRwy1EwbVFdgky2aIz1cRJzfHFThjPGbwiGpOmiHrQmSMKWQbcLGqXvW45UmHJI9UWScqwfnRpz1cRi8R9ijfmGzdSa7THfRpz1cRoEpxMrHIPJ10z1AtLvlSAGiOYRnunW3npDIvlSApRG3VbdfmBaXcdUzByjmGx)W)dijmasyZ1OBdlHb76pgL1H1p8)asywJOj8iwTkSqaFqcRGvslbRlmqLhjjqH0imarfgW0km4MTHLWac)ApsscdiC5NeggZA0Fodgp3LjCuS3fM10zv0SAH1XSg9NZW5iOc(X55rLnHu4OyVlmRPZQOznjHv7zn6pNHZrqf8JZZJkBcPWhL1NSMKWQ9Sg9NZGXZDzcFuwFYQfwhZQ9Sg9NZWJUapcmtXOqX0ft1MPIoGTnrHpkRpz1cRJzn6pNbYiBumLXqPFHJI9UWSMoRanGHy3gSMKWA0FodKr2Oykl)LFHJI9UWSMoRanGHy3gS(uyaHF5YJjHbq4MpAe)9rXuTyHbqcBUgDByjmyxHfYTSccxwb)xxazDFjwPcKv4KvRI8akTldYyf8FDbK1hDbEeiRumkumDXuTScpw7I19Lyv64LvGgqwHtw9IvrXiBumjScwX2ufSUWavEKKafsJWG56LU2fgoAEe(1JKeRwyD9diTHTJP8cZGnXA6SAlGHvlS6OzZlzEWQfwr4x7rskac38rJ4VpkMQflm4MTHLWa(xZ(iHbdsgjLx)aslwWk2kScwXwBfSUWavEKKafsJWG56LU2fgoAEe(1JKeRwyD9diTHTJP8cZGnXA6SARDcIMvlS6OzZlzEWQfwr4x7rskac38rJ4VpkMQflm4MTHLWqmewZ(iHbdsgjLx)aslwWk2kScwXwaiyDHbQ8ijbkKgHbZ1lDTlmC08i8RhjjwTW66hqAdBht5fMbBI10z1wadRJY6rXExywTWQJMnVK5bRwyfHFThjPaiCZhnI)(OyQwSWGB2gwcd4LKs)YtPFKWGbjJKYRFaPflyfBfwbRyRDeSUWavEKKafsJWG56LU2fgC0S5LmpegCZ2WsyycpdLHZC57)iHbqcBUgDByjmyZaTcRW)IBqI19Ly1C9YA0FozfESk(Lkwrc(zfewi3Y6RJGyLk4h4lRogL1fYk(FajHvWk2ATcwxyGkpssGcPryWC9sx7cdJzLmYgftHUYEHeRjjSsgzJIPagk9l3v2wwtsyLmYgftb5V8l3v2wwFYQfwhZQ9SAGiOYRnunW3npDI1KewbVFdgky2aIznjH1XS649CzgfkMowbiRPLOz1cRJzfHFThjPG56TG7hL1KewD8EUmJcfthRaKv7KkRjjSIWV2JKuOXzhsS(KvlSoMve(1EKKcgyHa(GYGegPYWQfwTNvdekbHIRGbwiGpO8(szmAF9IdFuwtsy1Ewr4x7rskyGfc4dkdsyKkdRwy1EwnqOeekUcgp3Lj8rz9jRpz9jRwyDmRgiuccfxbJN7Yeok27cZA6SANuznjHvW73GHcMnGywtsy1X75YmkumDSMoRPvQSAHvdekbHIRGXZDzcFuwTW6ywnqOeekUcumkumD5iybgok27cZkaz1nBdRaE9B2hfiBqM)s5TJjwtsy1Ewnqeu51gEG01EX6twtsyTRLouO0xcmpBGVB(OyVlmRaKvBtL1NSAH1XScc3Gd6OBJGYyX(fNb9yhifok27cZA6SATSMKWQ9SAGiOYRnuK5Gs4bY6tHb3SnSegM)dPmCMj5ViHbqcBUgDByjmyZaffwJOj8iwDwnxVSkUlqOywHhRDHBqIvVyvumYgftcRGvSv0cwxyGkpssGcPryWC9sx7cdJzLmYgftb5V8lxKnwwtsyLmYgftbmu6xUiBSSMKWkzKnkMcEHuUiBSSMKWA0FodrU0ldLHZSlL59TlG4C57)OWrXExywtNvRniAwtsyn6pNHix6LHYWz2LY8(2fqC2pJxu4OyVlmRPZQ1genRjjS649CzgfkMowtN10kvwTWQbcLGqXvW45UmHJCqKy1cR2Zk49BWqbZgqmRpz1cRJz1aHsqO4ky8CxMWrXExywtNv7KkRjjSAGqjiuCfmEUlt4ihejwFYAscRDT0HcL(sG5zd8DZhf7DHzfGSABQcdUzByjmqXOqX0LJGfOWaiHnxJUnSegeLyuOy6yncwGSk(LkwH)f3GeREXQOyKnkMyfESAvKhqPDzyTXS6rW)YkCznIy9JjWaRdocI1j8y1QipGs7YiScwXwaJG1fgOYJKeOqAegmxV01UWG9ScE)gmuWSbeZQfwr4x7rskyaZgyb2BdlwTW6ywhZQJ3ZLzuOy6ynDwtRuz1cRJzn6pNHhDbEeyMIrHIPlMQntfDaBBIcFuwtsy1Ewnqeu51gEG01EX6twtsyn6pNHijeck)4n8rz1cRr)5mejHqq5hVHJI9UWScqwbqQSokRJz1alWFVb0JmnMYUSbwXuTHTJPmcx(jwFY6twtsyTRLouO0xcmpBGVB(OyVlmRaKvaKkRJY6ywnWc83Ba9itJPSlBGvmvBy7ykJWLFI1NSMKWQbIGkV2q1aF380jwFYQfwhZQ9SAGiOYRnunW3npDI1Kewr4x7rskyGfc4dkdsyKkdRjjSAGqjiuCfmWcb8bL3xkJr7RxC4ihejwFkm4MTHLWGHKeEBxMDzdSIPAfgajS5A0THLWGvrEaL2LHvXVuXQVSMwPokRogLvX9(c)lRsiUlGSUDmXAxSMgjeck)4Lv4XQn7pEzfwSAGqjiuCXQ4xQyTGlRYU6ciRFuwf37lRwfwiGpiHvWk2kQeSUWavEKKafsJWG56LU2fgSNvW73GHcMnGywTWkc)Apssbdy2alWEByXQfwhZ6ywD8EUmJcfthRPZAALkRwyDmRr)5m8OlWJaZumkumDXuTzQOdyBtu4JYAscR2ZQbIGkV2WdKU2lwFYAscRr)5mejHqq5hVHpkRwyn6pNHijeck)4nCuS3fMvaYQDsL1rzDmRgyb(7nGEKPXu2LnWkMQnSDmLr4YpX6twFYAscRDT0HcL(sG5zd8DZhf7DHzfGSANuzDuwhZQbwG)EdOhzAmLDzdSIPAdBhtzeU8tS(K1Kewnqeu51gQg47MNoX6twTW6ywTNvdebvETHQb(U5PtSMKWkc)ApssbdSqaFqzqcJuzynjHvdekbHIRGbwiGpO8(szmAF9Idh5GiX6tHb3SnSeg6Y4x5BdlHvWk2kQfSUWavEKKafsJWaevyatRWGB2gwcdi8R9ijjmGWLFsyGmYgftHUYYF5hRaEwf1SciwDZ2WkGx)M9rbYgK5VuE7yI1rz1EwjJSrXuORS8x(XkGNvadRaIv3SnScIpFFdKniZFP82XeRJYAQbaWkGyfJssz(1XljmGWVC5XKWGJrhH0nqgHbqcBUgDByjmyx)XOSoS(H)hqcZQ4xQyDFjwNnW3L1gZQhb)lRlKvQargRZJkBcjwBmREe8VSUqwPcezSIe8ZQFeR(YAAL6OS6yuw7IvVyvumYgftScpwTkYdO0UmSkD8Iz1l4(shRI6rXKblScwX20sW6cdu5rscuincdMRx6AxyymRDT0HcL(sG5zd8DZhf7DHzfGSATSMKW6ywJ(Zz4Ceub)488OYMqkCuS3fMvaYkqdyi2TbRaEwnulzDmRoEpxMrHIPJvaXQDsL1NSAH1O)CgohbvWpoppQSjKcFuwFY6twtsyDmRoEpxMrHIPJ1rzfHFThjPGJrhH0nqgwb8Sg9NZazKnkMYyO0VWrXExywhLvq4gM)dPmCMj5VOW2Mh48rXExSc4zfabrZA6SAlasL1KewD8EUmJcfthRJYkc)ApssbhJocPBGmSc4zn6pNbYiBumLL)YVWrXExywhLvq4gM)dPmCMj5VOW2Mh48rXExSc4zfabrZA6SAlasL1NSAHvYiBumf6k7fsSAH1XSoMv7z1aHsqO4ky8CxMWhL1Kewnqeu51gEG01EXQfwTNvdekbHIRafJcftxocwGHpkRpznjHvdebvETHQb(U5PtS(KvlSoMv7z1arqLxBabv7lshRjjSApRr)5my8CxMWhL1KewD8EUmJcfthRPZAALkRpznjH1O)CgmEUlt4OyVlmRPZQOMvlSApRr)5mCocQGFCEEuztif(OcdUzByjmGx)W)dijScwbaPkyDHbQ8ijbkKgHbZ1lDTlmmM1O)CgiJSrXuw(l)cFuwtsyDmRMx)asywfHvaWQfwpY86hqkVDmXkazv0S(K1KewnV(bKWSkcR2H1NSAHvhnBEjZdHb3SnSegksCogclHvWkaWwbRlmqLhjjqH0imyUEPRDHHXSg9NZazKnkMYYF5x4JYAscRJz186hqcZQiScawTW6rMx)as5TJjwbiRIM1NSMKWQ51pGeMvry1oS(KvlS6OzZlzEim4MTHLWWRlN5yiSewbRaaaiyDHbQ8ijbkKgHbZ1lDTlmmM1O)CgiJSrXuw(l)cFuwtsyDmRMx)asywfHvaWQfwpY86hqkVDmXkazv0S(K1KewnV(bKWSkcR2H1NSAHvhnBEjZdHb3SnSegMFPmhdHLWkyfayhbRlmqLhjjqH0imasyZ1OBdlHbahOOWkSy1aYA0Fzf9GgmRIBPKvyjrI1iI1pMazTlCdsSA3)YpwffJSrXKWGB2gwcdI97A4LHZmj)fjScwbawRG1fgOYJKeOqAegmxV01UWazKnkMcDLL)YpwtsyLmYgftbmu6xUiBSSMKWkzKnkMcEHuUiBSSMKWA0FodI97A4LHZmj)ff(OSAH1O)CgiJSrXuw(l)cFuwtsyDmRr)5my8CxMWrXExywbiRUzByfeF((giBqM)s5TJjwTWA0Fodgp3Lj8rz9PWGB2gwcd41VzFKWaiHnxJUnSegSgmX6W63SpI1fYk6bnSoaL(XQOyKnkMyfESk(Lkw7Iv7(x(XQOyKnkMewbRaarlyDHb3SnSegeF((kmqLhjjqH0iScwbaagbRlmqLhjjqH0im4MTHLWW9RSB2gwzzJxHbzJ3C5XKWW0LY99(cRWkm4qsW6cwXwbRlmqLhjjqH0imarfgW0km4MTHLWac)ApsscdiC5NeggZA0FodBhtIHxLbpYJJ6cKUWrXExywbiRanGHy3gSokRPgSL1KewJ(Zzy7ysm8Qm4rECuxG0fok27cZkaz1nBdRaE9B2hfiBqM)s5TJjwhL1ud2YQfwhZkzKnkMcDLL)YpwtsyLmYgftbmu6xUiBSSMKWkzKnkMcEHuUiBSS(K1NSAH1O)Cg2oMedVkdEKhh1fiDHpkRwy9(fnHhqkSDmjgEvg8ipoQlq6c0i(BuucuyaHF5YJjHbWJ84S4wkZtxkZW5uyaKWMRr3gwcdw1LMV0xcZQ4xAFPJ19Ly1UEKhB818shRr)5KvXTuY60LswHZjRI79Tlw3xI1ISXYQXXRWkyfaiyDHbQ8ijbkKgHbiQWaMwHb3SnSegq4x7rssyaHl)KWG9SsgzJIPqxzmu6hRwyDmRyuskZRFaPfhWRFZ(iwtNvrZQfwxxs1gWWVmdN59LYt4r4nqLhjjqwtsyfJsszE9diT4aE9B2hXA6SkQy9PWac)YLhtcdnWcEugV(H)hqsyaKWMRr3gwcdw1LMV0xcZQ4xAFPJ1H1p8)asS2ywfdV9LvJJ3UaYkebDSoS(n7JyTlwT7F5hRIIr2OysyfSIDeSUWavEKKafsJWG56LU2fggZkc)ApssbdSqaFqzqcJuzy1cR2ZQbcLGqXvW45UmHJCqKynjH1O)CgmEUlt4JY6twTW6ywD8EUmJcfthRaKvrNkRjjSIWV2JKuObwWJY41p8)asS(KvlSoM1O)CgiJSrXuw(l)chf7DHznDwbmSMKWA0FodKr2OykJHs)chf7DHznDwbmS(KvlSoMv7z9(fnHhqke5sVmugoZUuM33UaIdu5rscK1KewJ(ZziYLEzOmCMDPmVVDbeNlF)hfWRBEWA6SAhwtsyn6pNHix6LHYWz2LY8(2fqC2pJxuaVU5bRPZQDy9jRjjSoBGVB(OyVlmRaKvBtvyWnBdlHbdSqaFq59LYy0(6flmasyZ1OBdlHbRbtSAvyHa(Gyv8lvS6lRscJzDF9IvrNkRoEpxYkkumDS6fiRYUiw)OSkU3xwTkYdO0UmSkU3x4FzvcXDbKvN1pMewbRyTcwxyGkpssGcPryWnBdlHb8VM9rcdgKmskV(bKwSGvSvyaKWMRr3gwcdwdMyf)RzFeRDXkQxGuCByv8lvS6lR2ATyYGz9OyVRUaYk8yvsymRI79L1y4rSU(bKwmREbYApzTxwfd)sqwNUuYkCoznIMWJyLQLUUaY6(sSwKnwwffJSrXKWG56LU2fggZ6rZJWVEKKynjH1O)CgiJSrXugdL(fok27cZkaz1oSAHvYiBumf6kJHs)y1cRhf7DHzfGSAR1YQfwxxs1gWWVmdN59LYt4r4nqLhjjqwFYQfwx)asBy7ykVWmytSMoR2ATSAZzfJsszE9diTywhL1JI9UWSAH1XSsgzJIPqxzVqI1Kewpk27cZkazfObme72G1NcRGveTG1fgOYJKeOqAegmxV01UWWywJ(ZzaV(nDPmC08i8RhjjwTW6ywXOKuMx)asloGx)MUuYkaz1oSMKWQ9SE)IMWdif2oMedVkdEKhh1fiDbAe)nkkbY6twtsyDDjvBad)YmCM3xkpHhH3avEKKaz1cRr)5mqgzJIPmgk9lCuS3fMvaYQDy1cRKr2Oyk0vgdL(XQfwJ(ZzaV(nDPmCuS3fMvaYQOIvlSIrjPmV(bKwCaV(nDPK10fHvRL1NSAH1XSApR3VOj8asbjsg)CCEkjA7cygOSJrXuGgXFJIsGSMKW62XeRawwTwrZA6Sg9NZaE9B6sz4OyVlmRJYkay9jRwyD9diTHTJP8cZGnXA6SkAHb3SnSegWRFtxkfgajS5A0THLWGnReHY6hL1H1VPlLS6lRUuY62XeM1FjjmM1pUlGSA3iz8ZXS6fiR9YAJz1JG)L1fYk6bnScpwL0Y6(sSIrjt7swDZ2WIvzxeRrKekM1xVaLeR21J84OUaPJvyXkayD9diTyHvWkagbRlmqLhjjqH0imyUEPRDHH7x0eEaPW2XKy4vzWJ84OUaPlqJ4VrrjqwTWkgLKY86hqAXb8630LswtxewTdRwyDmR2ZA0FodBhtIHxLbpYJJ6cKUWhLvlSg9NZaE9B6sz4O5r4xpssSMKW6ywr4x7rskaEKhNf3szE6szgoNSAH1XSg9NZaE9B6sz4OyVlmRaKv7WAscRyuskZRFaPfhWRFtxkznDwbaRwyDDjvBaVKu6xg865gOYJKeiRwyn6pNb8630LYWrXExywbiRIM1NS(K1NcdUzByjmGx)MUukmasyZ1OBdlHbaNEFz1UEKhh1fiDS(XeRdRFtxkzDHS(Giuw)OSUVeRr)5K1iKy1LyiRFCxazDy9B6sjRWIvrZkMmWceZk8yvsymRhf7D1fqHvWkIkbRlmqLhjjqH0imarfgW0km4MTHLWac)ApsscdiC5NegC8EUmJcfthRPZQOovwT5SoMvBtLvapRr)5mSDmjgEvg8ipoQlq6c41npy9jR2CwhZA0Fod41VPlLHJI9UWSc4z1oSciwXOKuMFD8sS(KvBoRJzfeUH5)qkdNzs(lkCuS3fMvapRIM1NSAH1O)CgWRFtxkdFuHbe(LlpMegWRFtxkZIH1MNUuMHZPWaiHnxJUnSegSQlnFPVeMvXV0(shRoRdRF4)bKy9Jjwf3sjRg)Jjwhw)MUuY6czD6sjRW5ezS6fiRFmX6W6h(FajwxiRpicLv76rECuxG0XkEDZdw)OcRGve1cwxyGkpssGcPryWC9sx7cdi8R9ijfapYJZIBPmpDPmdNtwTWkc)Apssb8630LYSyyT5PlLz4CYQfwTNve(1EKKcnWcEugV(H)hqI1KewhZA0FodrU0ldLHZSlL59TlG4C57)OaEDZdwtNv7WAscRr)5me5sVmugoZUuM33UaIZ(z8Ic41npynDwTdRpz1cRyuskZRFaPfhWRFtxkzfGSATcdUzByjmGx)W)dijmasyZ1OBdlHbRbtSoS(H)hqIvX9(YQD9ipoQlq6yDHS(Giuw)OSUVeRr)5KvX9(c)lRsiUlGSoS(nDPK1p62XeREbY6htSoS(H)hqIvyXQ1okRPbI8wNv86Mhyw)12swTwwx)aslwyfSsAjyDHbQ8ijbkKgHb3SnSegCqhDBeugl2VyHbdsgjLx)aslwWk2kmasyZ1OBdlHbRbtSIf7xmRyiR7RVSIe8ZkqAzn2TbRF0TJjwJqI1pUlGS2lRoMvPVeRoMvuig3rsIvyXQKWyw3xVy1oSIx38aZk8y1M9hVSk(LkwTZOSIx38aZkzd0(iHbZ1lDTlmypRBBE0fqwTWQ9S6MTHvWbD0TrqzSy)IZGESdKcDLNYg47YAscRGWn4Go62iOmwSFXzqp2bsb86MhScqwTdRwyfeUbh0r3gbLXI9lod6XoqkCuS3fMvaYQDewbRyBQcwxyGkpssGcPryWnBdlHHyiSM9rcdgKmskV(bKwSGvSvyaKWMRr3gwcdJa08i8lRXqyn7JyTNSAvKhqPDzyTXSEKdIeRWJ19LoIv)iwLegZ6(6fRIM11pG0IzTlwT7F5hRIIr2OyIvX9(YkgUtwHhRscJzDF9IvBtLv4(sN4gtS2fREHeRIIr2OykWQDfwi3Y6rZJWVSc(VUaY6JUapcKvkgfkMUyQww9cKvqyHClRqe0zCuwDmQWG56LU2fgoAEe(1JKeRwyD9diTHTJP8cZGnXA6SoMvBTwwhL1XSIrjPmV(bKwCaV(n7JyfWZQTbrZ6twFYkGyfJsszE9diTywhL1JI9UWSAH1XSoMvdekbHIRGXZDzch5GiXQfwTNvW73GHcMnGywTW6ywr4x7rskyGfc4dkdsyKkdRjjSAGqjiuCfmWcb8bL3xkJr7RxC4ihejwtsy1Ewnqeu51gQg47MNoX6twtsyfJsszE9diT4aE9B2hXkazDmRIMvapRJz1wwhL11LuTHvCx5yiSWbQ8ijbY6twFYAscRJzLmYgftHUYyO0pwtsyDmRKr2Oyk0vocUVSMKWkzKnkMcDLL)YpwFYQfwTN11LuTbm8lZWzEFP8eEeEdu5rscK1KewJ(Zza96y4b2Um7NXR2Kr)sSFbeU8tSMUiScarNkRpz1cRJzfJsszE9diT4aE9B2hXkaz12uzfWZ6ywTL1rzDDjvByf3vogclCGkpssGS(K1NSAHvhVNlZOqX0XA6Sk6uz1MZA0Fod41VPlLHJI9UWSc4zfWW6twTW6ywTN1O)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rznjHvYiBumf6kJHs)ynjHv7z1arqLxB4bsx7fRpz1cRoA28sMhS(uyfSIT2kyDHbQ8ijbkKgHbZ1lDTlm4OzZlzEim4MTHLWWeEgkdN5Y3)rcdGe2Cn62WsyWAWeRtyXkSy1aYQ4EFH)LvJJI2fqHvWk2cabRlmqLhjjqH0imyUEPRDHHO)CgmEUlt4Jkm4MTHLWW5iOc(X55rLnHKWaiHnxJUnSegSgmX68OYMqIvyXQbezSUVnMvXTuYQ)xySVTXLsKyv2fX6hLvX9(YQXfwbRyRDeSUWavEKKafsJWG56LU2fgSNvW73GHcMnGywTWkc)Apssbdy2alWEByXQfwhZA0Fod41VPlLHpkRjjS649CzgfkMowtNvrNkRpz1cR2ZA0FodyOeVTHcFuwTWQ9Sg9NZGXZDzcFuwTW6ywTNvdebvETHQb(U5PtSMKWkc)ApssbdSqaFqzqcJuzynjHvdekbHIRGbwiGpO8(szmAF9IdFuwtsyTRLouO0xcmpBGVB(OyVlmRaKvaKkRJY6ywnWc83Ba9itJPSlBGvmvBy7ykJWLFI1NS(uyWnBdlHbdjj82Um7Ygyft1kmasyZ1OBdlHbRbtSAvKhqPDzyfwSAaz9xscJzfj4NvJxSk7IyTxw)OSkU3xwTkSqaFqSkU3x4FzvcXDbKvNvJJxHvWk2ATcwxyGkpssGcPryWC9sx7cd2Zk49BWqbZgqmRwyfHFThjPGbmBGfyVnSy1cRJzn6pNb8630LYWhL1KewD8EUmJcfthRPZQOtL1NSAHv7zn6pNbmuI32qHpkRwy1EwJ(ZzW45UmHpkRwyDmR2ZQbIGkV2q1aF380jwtsyfHFThjPGbwiGpOmiHrQmSMKWQbcLGqXvWaleWhuEFPmgTVEXHpkRjjS21shku6lbMNnW3nFuS3fMvaYQbcLGqXvWaleWhuEFPmgTVEXHJI9UWSokRagwtsyTRLouO0xcmpBGVB(OyVlmRawwTvuNkRaKv7KkRJY6ywnWc83Ba9itJPSlBGvmvBy7ykJWLFI1NS(uyWnBdlHHUm(v(2WsyfSITIwW6cdu5rscuincdMRx6AxyORLouO0xcmpBGVB(OyVlmRaKvBfnRjjSoM1O)CgqVogEGTlZ(z8Qnz0Ve7xaHl)eRaKvai6uznjH1O)CgqVogEGTlZ(z8Qnz0Ve7xaHl)eRPlcRaq0PY6twTWA0Fod41VPlLHpkRwyDmRgiuccfxbJN7Yeok27cZA6Sk6uznjHvW73GHcMnGywFkm4MTHLWafJcftxocwGcdGe2Cn62WsyWAWeRWIvdiRI79L1H1VPlLS(rz1lqwXocI1j8yDe(Ly)ewbRylGrW6cdu5rscuincdUzByjmGxsk9lpL(rcdgKmskV(bKwSGvSvyaKWMRr3gwcdJa08i8lRtPFeRWI1pkRlKv7W66hqAXSkU3x4FzTldGmoRruxaz1JG)L1fYkzd0(iw9cK1cUScrqNXrr7cOWG56LU2fgoAEe(1JKeRwyD7ykVWmytSMoR2kAwTWkgLKY86hqAXb863SpIvaYQ1YQfwD0S5Lmpy1cRJzn6pNbJN7Yeok27cZA6SABQSMKWQ9Sg9NZGXZDzcFuwFkScwXwrLG1fgOYJKeOqAegmxV01UWazKnkMcDL9cjwTWQJMnVK5bRwyn6pNb0RJHhy7YSFgVAtg9lX(fq4YpXkazfaIovwTW6ywbHBWbD0TrqzSy)IZGESdKcBBE0fqwtsy1Ewnqeu51gkYCqj8aznjHvmkjL51pG0IznDwbaRpfgCZ2Wsyy(pKYWzMK)IegajS5A0THLWG1GjmR2mqrH1EYAx4gKy1lwffJSrXeREbYQSlI1Ez9JYQ4EFz1zDe(Ly)yf9Ggw9cKvKh0r3gbX6Gy)IfwbRyROwW6cdu5rscuincdMRx6Axyi6pNbyr7loJsNHq3gwHpkRwyDmRr)5mGx)MUugoAEe(1JKeRjjS649CzgfkMowtN10kvwFkm4MTHLWaE9B6sPWaiHnxJUnSegSgmXQxSclAFzf9Ggw)LKWywhw)MUuYAJz1Lh5GiX6hLv4XksWpR(rS6rW)Y6czfIGoJJYQJrfwbRyBAjyDHbQ8ijbkKgHbZ1lDTlmyGiOYRnunW3npDIvlSoMve(1EKKcgyHa(GYGegPYWAscRgiuccfxbJN7Ye(OSMKWA0Fodgp3Lj8rz9jRwy1aHsqO4kyGfc4dkVVugJ2xV4WrXExywbiRanGHy3gSc4z1qTK1XS649CzgfkMowbeRIovwFYQfwJ(ZzaV(nDPmCuS3fMvaYQ1YQfwTNvW73GHcMnGyHb3SnSegWRFtxkfgajS5A0THLWGD9hJYQJrznIMWJy1QWcb8bXQ4EFzDy9B6sjREbY6(sfRdRF4)bKewbRaGufSUWavEKKafsJWG56LU2fgmqeu51gQg47MNoXQfwhZkc)ApssbdSqaFqzqcJuzynjHvdekbHIRGXZDzcFuwtsyn6pNbJN7Ye(OS(KvlSAGqjiuCfmWcb8bL3xkJr7RxC4OyVlmRaKvadRwyn6pNb8630LYWhLvlSsgzJIPqxzVqIvlSApRi8R9ijfAGf8OmE9d)pGeRwy1EwbVFdgky2aIfgCZ2WsyaV(H)hqsyfScaSvW6cdu5rscuincdMRx6Axyi6pNbyr7loBKKFzenUHv4JYAscRJz1EwXRFZ(OGJMnVK5bRwy1Ewr4x7rsk0al4rz86h(FajwtsyDmRr)5my8CxMWrXExywbiRIMvlSg9NZGXZDzcFuwtsyDmRr)5mCocQGFCEEuztifok27cZkazfObme72GvapRgQLSoMvhVNlZOqX0XkGy1oPY6twTWA0FodNJGk4hNNhv2esHpkRpz9jRwyfHFThjPaE9B6szwmS280LYmCoz1cRyuskZRFaPfhWRFtxkzfGSAhwFYQfwhZQ9SE)IMWdif2oMedVkdEKhh1fiDbAe)nkkbYAscRyuskZRFaPfhWRFtxkzfGSAhwFkm4MTHLWaE9d)pGKWaiHnxJUnSegSgmX6W6h(Fajwf37lREXkSO9Lv0dAyfESIe8JCGScrqNXrz1XOSkU3xwrc(pwlYglRghVbwrEjgYk4pgfZQJrz1xw3xIvQazfozDFjwrq1(I0XA0FozTNSoS(nDPKvXWVeSwwNUuYkCozfwSATScpwLegZ66hqAXcRGvaaaeSUWavEKKafsJWG56LU2fggZkzKnkMcDL9cjwTWQbcLGqXvW45UmHJI9UWSMoRIovwtsyDmRMx)asywfHvaWQfwpY86hqkVDmXkazv0S(K1KewnV(bKWSkcR2H1NSAHvhnBEjZdHb3SnSegksCogclHbqcBUgDByjmynyI1yiSWSc(VUaYQD)l)y9xscJzfIGoJJI2fqwhh7ifrSwebIz186fqcZQ4EFz1X75swJHWc)uyfScaSJG1fgOYJKeOqAegmxV01UWWywjJSrXuORSxiXQfwnqOeekUcgp3LjCuS3fM10zv0PYAscRJz186hqcZQiScawTW6rMx)as5TJjwbiRIM1NSMKWQ51pGeMvry1oS(KvlS6OzZlzEim4MTHLWWRlN5yiSewbRaaRvW6cdu5rscuincdMRx6AxyymRKr2Oyk0v2lKy1cRgiuccfxbJN7Yeok27cZA6Sk6uznjH1XSAE9diHzvewbaRwy9iZRFaP82XeRaKvrZ6twtsy186hqcZQiSAhwFYQfwD0S5LmpegCZ2Wsyy(LYCmewcRGvaGOfSUWavEKKafsJWaiHnxJUnSegSgmXkGduuyf8FDbKv7(x(XQOyKnkMegCZ2WsyqSFxdVmCMj5ViHvWkaaWiyDHbQ8ijbkKgHbiQWaMwHb3SnSegq4x7rssyaHl)KWagLKY86hqAXb863SpI10z1AzDuwNsi8yDmRXoEPdPmcx(jwb8SABQPYkGyfaPY6twhL1PecpwhZA0Fod41p8)aszkgfkMUyQ2mgk9lGx38GvaXQ1Y6tHbe(LlpMegWRFZ(OCxzmu6NWkyfaiQeSUWavEKKafsJWG56LU2fgiJSrXuq(l)YfzJL1KewjJSrXuWlKYfzJLvlSIWV2JKuOXzJKCeeRjjSg9NZazKnkMYyO0VWrXExywbiRUzByfWRFZ(OazdY8xkVDmXQfwJ(ZzGmYgftzmu6x4JYAscRKr2Oyk0vgdL(XQfwTNve(1EKKc41VzFuURmgk9J1KewJ(ZzW45UmHJI9UWScqwDZ2WkGx)M9rbYgK5VuE7yIvlSApRi8R9ijfAC2ijhbXQfwJ(ZzW45UmHJI9UWScqwjBqM)s5TJjwTWA0Fodgp3Lj8rznjH1O)CgohbvWpoppQSjKcFuwTWkgLKY8RJxI10zn1aGHvlSoMvmkjL51pG0IzfGIWQDynjHv7zDDjvBad)YmCM3xkpHhH3avEKKaz9jRjjSApRi8R9ijfAC2ijhbXQfwJ(ZzW45UmHJI9UWSMoRKniZFP82XKWGB2gwcdIpFFfgajS5A0THLWG1GjwbCoFFzTlwhGs)yvumYgftScpw3xIvPJxwhw)M9rSkgwlRZEzTRfYQZQvrEaL2LH1O)CgewbRaarTG1fgOYJKeOqAegajS5A0THLWG1Gjwhw)M9rS2tw7Iv7(x(XQOyKnkMqgRDX6au6hRIIr2OyIvyXQ1okRRFaPfZk8yDHSIEqdRdqPFSkkgzJIjHb3SnSegWRFZ(iHvWkaiTeSUWavEKKafsJWGB2gwcd3VYUzByLLnEfgajS5A0THLWGnJlL779fgKnEZLhtcdtxk337lScRWW0LY99(cwxWk2kyDHbQ8ijbkKgHbZ1lDTlmypR3VOj8asHix6LHYWz2LY8(2fqCGgXFJIsGcdUzByjmGx)W)dijmasyZ1OBdlHHH1p8)asSoHhRXqeumvlR)ssymRFCxaznnqK36cRGvaGG1fgOYJKeOqAegCZ2Wsya)RzFKWGbjJKYRFaPflyfBfgajS5A0THLWGvD8Y6(sSccxwf37lR7lXAmeVSUDmX6cz1bbz9xBlzDFjwJDBWk4)8THfRnM13EdSo8RzFeRhf7DHzn(l3gv2eiRlK1yFnVSgdH1SpIvW)5BdlHbZ1lDTlmac3qmewZ(OWrXExywtN1JI9UWSc4zfaaGvaXQTIAHvWk2rW6cdUzByjmedH1SpsyGkpssGcPryfwHb8kyDbRyRG1fgOYJKeOqAegmxV01UWW9lAcpGuy7ysm8Qm4rECuxG0fOr83OOeiRwyDmRKr2Oyk0v2lKy1cR2Z6ywhZA0FodBhtIHxLbpYJJ6cKUWrXExywtNvGgWqSBdwhL1ud2YQfwhZkzKnkMcDLJG7lRjjSsgzJIPqxzmu6hRjjSsgzJIPG8x(LlYglRpznjH1O)Cg2oMedVkdEKhh1fiDHJI9UWSMoRUzByfWRFZ(OazdY8xkVDmX6OSMAWwwTW6ywjJSrXuORS8x(XAscRKr2OykGHs)YfzJL1KewjJSrXuWlKYfzJL1NS(K1KewTN1O)Cg2oMedVkdEKhh1fiDHpkRpznjH1XSg9NZGXZDzcFuwtsyfHFThjPGbwiGpOmiHrQmS(KvlSAGqjiuCfmWcb8bL3xkJr7RxC4ihejwFkm4MTHLWaE9d)pGKWaiHnxJUnSegSQlnFPVeMvXV0(shRdRF4)bKyTiceZ6cznIy9JjqwxiRpicL1pkR7lXQD9ipoQlq6yn6pNScpwxiRG)yuwJOj8iwnWcb8bjScwbacwxyGkpssGcPryWnBdlHbh0r3gbLXI9lwyWGKrs51pG0IfSITcdGe2Cn62WsyWAWeRipOJUncI1bX(fZQ4xQyDFPJyTXSwqwDZ2iiwXI9lgzS6ywL(sS6ywrHyChjjwHfRyX(fZQ4EFzfaScpwNKy6yfVU5bMv4XkSy1z1oJYkwSFXSIHSUV(Y6(sSwKywXI9lMv)UgbHz1M9hVS6ZLow3xFzfl2VywjBG2hHfgmxV01UWG9Scc3Gd6OBJGYyX(fNb9yhif228OlGSAHv7z1nBdRGd6OBJGYyX(fNb9yhif6kpLnW3LvlSoMv7zfeUbh0r3gbLXI9lo)sUmST5rxaznjHvq4gCqhDBeugl2V48l5YWrXExywtNvrZ6twtsyfeUbh0r3gbLXI9lod6XoqkGx38GvaYQDy1cRGWn4Go62iOmwSFXzqp2bsHJI9UWScqwTdRwyfeUbh0r3gbLXI9lod6XoqkST5rxafwbRyhbRlmqLhjjqH0imyUEPRDHHXSIWV2JKuWaleWhugKWivgwTWQ9SAGqjiuCfmEUlt4ihejwtsyn6pNbJN7Ye(OS(KvlS649CzgfkMowbiRwBQSAH1XSg9NZazKnkMYYF5x4OyVlmRPZQTPYAscRr)5mqgzJIPmgk9lCuS3fM10z12uz9jRjjSoBGVB(OyVlmRaKvBtvyWnBdlHbdSqaFq59LYy0(6flmasyZ1OBdlHbRbtywTkSqaFqS2twnoRnM1pkRWJvKGFw9JyfKWivMUaYQvrEaL2LHvX9(YQvHfc4dIvVazfj4Nv)iwJijumRwBQS6yuHvWkwRG1fgOYJKeOqAegGOcdyAfgCZ2WsyaHFThjjHbeU8tcdJzn6pNbJN7Yeok27cZA6SkAwTW6ywJ(Zz4Ceub)488OYMqkCuS3fM10zv0SMKWQ9Sg9NZW5iOc(X55rLnHu4JY6twtsy1EwJ(ZzW45UmHpkRjjS649CzgfkMowbiR2jvwFYQfwhZQ9Sg9NZWJUapcmtXOqX0ft1MPIoGTnrHpkRjjS649CzgfkMowbiR2jvwFYQfwhZA0FodKr2OykJHs)chf7DHznDwbAadXUnynjH1O)CgiJSrXuw(l)chf7DHznDwbAadXUny9PWac)YLhtcdGWnF0i(7JIPAXcdGe2Cn62WsyyeGMhHFzfeUyw)LKWywTkYdO0UmS(6ywLegZ6(6fRIMvmzWSEuS3vxargR7lXkcQ2xKowJ(ZjRWJ19Ly9bsx7fRr)5K1gZQhb)lRlK1PlLScNtw9cKvVqIvrXiBumXAJz1JG)L1fYkzd0(iHvWkIwW6cdu5rscuincdMRx6Axy4O5r4xpssSAH11pG0g2oMYlmd2eRPZQTaGvlSoMvhnBEjZdwTWkc)Apssbq4MpAe)9rXuTywFkm4MTHLWqmewZ(iHbdsgjLx)aslwWk2kScwbWiyDHbQ8ijbkKgHbZ1lDTlmC08i8RhjjwTW66hqAdBht5fMbBI10z1waWQfwhZQJMnVK5bRwyfHFThjPaiCZhnI)(OyQwmRpfgCZ2Wsya)RzFKWGbjJKYRFaPflyfBfwbRiQeSUWavEKKafsJWG56LU2fgoAEe(1JKeRwyD9diTHTJP8cZGnXA6SAlGHvlSoMvhnBEjZdwTWkc)Apssbq4MpAe)9rXuTywFkm4MTHLWaEjP0V8u6hjmyqYiP86hqAXcwXwHvWkIAbRlmqLhjjqH0imyUEPRDHbhnBEjZdHb3SnSegMWZqz4mx((psyaKWMRr3gwcdwdMy1MbAfwHfRgqwf37l8VSACu0UakScwjTeSUWavEKKafsJWG56LU2fgI(ZzW45UmHpQWGB2gwcdNJGk4hNNhv2escdGe2Cn62WsyWAWeR7lX6iiuTViDS6rTSxKyfwSAazv8BBEzTXSgrt4rSAvKhqPDzewbRyBQcwxyGkpssGcPryWC9sx7cdJzDmRr)5mqgzJIPmgk9lCuS3fM10z12uznjH1O)CgiJSrXuw(l)chf7DHznDwTnvwFYQfwnqOeekUcgp3LjCuS3fM10z1oPYQfwhZA0FodOxhdpW2Lz)mE1Mm6xI9lGWLFIvaYkaS2uznjHv7z9(fnHhqkGEDm8aBxM9Z4vBYOFj2VanI)gfLaz9jRpznjH1O)CgqVogEGTlZ(z8Qnz0Ve7xaHl)eRPlcRaquLkRjjSAGqjiuCfmEUlt4ihejwTW6ywD8EUmJcfthRPZAALkRjjSIWV2JKuOXzhsS(uyWnBdlHbkgfkMUCeSafgajS5A0THLWG1GjwTzTlWJazDaTVEXSkU3xwhGs)yvumYgftS6fiRJWVe7hR)ssymRsiUlGS6S(XKWkyfBTvW6cdu5rscuincdMRx6AxyWEwbVFdgky2aIz1cRi8R9ijfmGzdSa7THfRwyDmRoEpxMrHIPJ10znTsLvlSoM1O)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rznjHv7z1arqLxB4bsx7fRpznjHvdebvETHQb(U5PtSMKWkc)ApssHgNDiXAscRr)5mejHqq5hVHpkRwyn6pNHijeck)4nCuS3fMvaYkasL1rzDmRJznTyfWZ69lAcpGua96y4b2Um7NXR2Kr)sSFbAe)nkkbY6twhL1XSAGf4V3a6rMgtzx2aRyQ2W2XugHl)eRpz9jRpz1cR2ZA0Fodgp3Lj8rz1cRJz1Ewnqeu51gQg47MNoXAscRgiuccfxbdSqaFq59LYy0(6fh(OSMKWAxlDOqPVeyE2aF38rXExywbiRgiuccfxbdSqaFq59LYy0(6fhok27cZ6OScyynjH1Uw6qHsFjW8Sb(U5JI9UWScyz1wrDQScqwbqQSokRJz1alWFVb0JmnMYUSbwXuTHTJPmcx(jwFY6tHb3SnSegmKKWB7YSlBGvmvRWaiHnxJUnSegSgmXQvrEaL2LHvX9(YQvHfc4dIvVazfewi3YkebDIVEjwhHFj2pHvWk2cabRlmqLhjjqH0imyUEPRDHb7zf8(nyOGzdiMvlSIWV2JKuWaMnWcS3gwSAH1XS649CzgfkMowtN10kvwTW6ywJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWhL1KewTNvdebvETHhiDTxS(K1Kewnqeu51gQg47MNoXAscRi8R9ijfAC2HeRjjSg9NZqKecbLF8g(OSAH1O)CgIKqiO8J3WrXExywbiR2jvwhL1XSoM10IvapR3VOj8asb0RJHhy7YSFgVAtg9lX(fOr83OOeiRpzDuwhZQbwG)EdOhzAmLDzdSIPAdBhtzeU8tS(K1NS(KvlSApRr)5my8CxMWhLvlSoMv7z1arqLxBOAGVBE6eRjjSAGqjiuCfmWcb8bL3xkJr7RxC4JYAscRDT0HcL(sG5zd8DZhf7DHzfGSAGqjiuCfmWcb8bL3xkJr7RxC4OyVlmRJYkGH1Kew7APdfk9LaZZg47Mpk27cZkGLvBf1PYkaz1oPY6OSoMvdSa)9gqpY0yk7Ygyft1g2oMYiC5Ny9jRpfgCZ2WsyOlJFLVnSewbRyRDeSUWavEKKafsJWaevyatRWGB2gwcdi8R9ijjmGWLFsyWEwnqOeekUcgp3LjCKdIeRjjSApRi8R9ijfmWcb8bLbjmsLHvlSAGiOYRnunW3npDI1KewbVFdgky2aIfgq4xU8ysya7iO8eEzJN7YimasyZ1OBdlHHrq8R9ijX6htGSclw9Ow2Btyw3xFzvSxlRlK1iIvSJGazDcpwTkYdO0UmSIHSUV(Y6(siXQFuTSk2XlbYQn7pEznIMWJyDFPyHvWk2ATcwxyGkpssGcPryWC9sx7cdKr2Oyk0v2lKy1cRoA28sMhSAH1O)CgqVogEGTlZ(z8Qnz0Ve7xaHl)eRaKvayTPYQfwhZkiCdoOJUnckJf7xCg0JDGuyBZJUaYAscR2ZQbIGkV2qrMdkHhiRpz1cRi8R9ijfWockpHx245UmcdUzByjmm)hsz4mtYFrcdGe2Cn62WsyWAWeMvBgOOWApzTlw9IvrXiBumXQxGSUxtywxiRYUiw7L1pkRI79L1r4xI9dzSAvKhqPDzy1lqwrEqhDBeeRdI9lwyfSITIwW6cdu5rscuincdMRx6Axyi6pNbyr7loJsNHq3gwHpkRwyn6pNb8630LYWrZJWVEKKegCZ2WsyaV(nDPuyaKWMRr3gwcdwdMyfw0(Y6W630LswrpObZApzDy9B6sjRnUqUL1pQWkyfBbmcwxyi6pN5YJjHb86NeEGcdu5rscuincdUzByjmy8YqYC0FofgmxV01UWq0Fod41pj8adhf7DHzfGSkAwTW6ywJ(ZzGmYgftzmu6x4OyVlmRPZQOznjH1O)CgiJSrXuw(l)chf7DHznDwfnRpz1cRoEpxMrHIPJ10znTsvyfSITIkbRlmqLhjjqH0imyUEPRDHH1LuTb8ssPFzWRNBGkpssGSAHvmTBxaXbmucZGxpxwTWA0Fod41VPlLbqO4syWnBdlHb8630LsHvWk2kQfSUWavEKKafsJWG56LU2fgmqeu51gQg47MNoXQfwr4x7rskyGfc4dkdsyKkdRwy1aHsqO4kyGfc4dkVVugJ2xV4WrXExywbiRIMvlSApRG3VbdfmBaXcdUzByjmGx)W)dijmasyZ1OBdlHb76pgfZQJrznIMWJy1QWcb8bX6h3fqw3xIvRcleWheRgyb2BdlwxiRMxY8G1EYQvHfc4dI1gZQB2VlLiXQhb)lRlK1iIvJJxHvWk2MwcwxyGkpssGcPryWC9sx7cdRlPAd4LKs)YGxp3avEKKaz1cR2Z66sQ2aE9tcpWavEKKaz1cRr)5mGx)MUugoAEe(1JKeRwyDmRr)5mqgzJIPS8x(fok27cZA6Scyy1cRKr2Oyk0vw(l)y1cRr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jwbiRaq0PYAscRr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jwtxewbGOtLvlS649CzgfkMowtN10kvwtsyfeUbh0r3gbLXI9lod6XoqkCuS3fM10zvuZAscRUzByfCqhDBeugl2V4mOh7aPqx5PSb(US(KvlSApRgiuccfxbJN7YeoYbrsyWnBdlHb8630LsHbqcBUgDByjmynyI1H1VPlLSkU3xwXljL(Xk41ZLvVazTGSoS(jHhiYyv8lvSwqwhw)MUuYAJz9JImwrc(z1pI1Uy1U)LFSkkgzJIjKXk6bnSoc)sSFSk(Lkw9iicI10kvwDmkRWJvhe13gbXkwSFXS(6ywf1JIjdM1JI9U6ciRWJ1gZAxSoLnW3vyfScasvW6cdu5rscuincdMRx6Axyi6pNbyr7loBKKFzenUHv4JYAscRr)5m8OlWJaZumkumDXuTzQOdyBtu4JYAscRr)5my8CxMWhLvlSoM1O)CgohbvWpoppQSjKchf7DHzfGSc0agIDBWkGNvd1swhZQJ3ZLzuOy6yfqSANuz9jRwyn6pNHZrqf8JZZJkBcPWhL1KewTN1O)CgohbvWpoppQSjKcFuwTWQ9SAGqjiuCfohbvWpoppQSjKch5GiXAscR2ZQbIGkV2acQ2xKowFYAscRoEpxMrHIPJ10znTsLvlSsgzJIPqxzVqsyWnBdlHb86h(FajHbqcBUgDByjmynyIvmMvyr7lROh0Gz1lqwb)XOS6yuwf)sfRwf5buAxgwHhR7lXkcQ2xKowJ(ZjRnMvpc(xwxiRtxkzfoNScpwrc(roqwnokRogvyfScaSvW6cdu5rscuincdMRx6AxyyDjvBaV(jHhyGkpssGSAHv7z9(fnHhqkSDmjgEvg8ipoQlq6c0i(BuucKvlSoM1O)CgWRFs4bg(OSMKWQJ3ZLzuOy6ynDwtRuz9jRwyn6pNb86NeEGb86MhScqwTdRwyDmRr)5mqgzJIPmgk9l8rznjH1O)CgiJSrXuw(l)cFuwFYQfwJ(Zza96y4b2Um7NXR2Kr)sSFbeU8tScqwbGOkvwTW6ywnqOeekUcgp3LjCuS3fM10z12uznjHv7zfHFThjPGbwiGpOmiHrQmSAHvdebvETHQb(U5PtS(uyWnBdlHb86h(FajHbqcBUgDByjmy9djwxiRX(dI19LynIWlRWjRdRFs4bYAesSIx38OlGS2lRFuwhXFBEirI1UyDak9JvrXiBumXA0FzDe(Ly)yTX1YQhb)lRlK1iIv0dAmeOWkyfaaabRlmqLhjjqH0imyUEPRDHb7z9(fnHhqkSDmjgEvg8ipoQlq6c0i(BuucKvlSoM1O)CgqVogEGTlZ(z8Qnz0Ve7xaHl)eRaKvaiQsL1KewJ(Zza96y4b2Um7NXR2Kr)sSFbeU8tScqwbGOtLvlSUUKQnGxsk9ldE9Cdu5rscK1NSAH1O)CgiJSrXugdL(fok27cZA6SkQy1cRKr2Oyk0vgdL(XQfwTN1O)CgGfTV4mkDgcDByf(OSAHv7zDDjvBaV(jHhyGkpssGSAHvdekbHIRGXZDzchf7DHznDwfvSAH1XSAGqjiuCfE0f4rGzmAF9Idhf7DHznDwfvSMKWQ9SAGiOYRn8aPR9I1NcdUzByjmGx)W)dijmasyZ1OBdlHbRbtSoS(H)hqI1UyDak9JvrXiBumHmwbHfYTSkPL1Ezf9GgwhHFj2pwhVV(YAJz91lqjbYAesSs9(shR7lX6W630LswLDrScpw3xIvhJMEALkRYUiwNWJ1H1p8)asprgRGWc5wwHiOt81lXQxSclAFzf9Ggw9cKvjTSUVeREeebXQSlI1xVaLeRdRFs4bkScwba2rW6cdu5rscuincdMRx6AxyymRr)5mqgzJIPS8x(f(OSMKW6ywnV(bKWSkcRaGvlSEK51pGuE7yIvaYQOz9jRjjSAE9diHzvewTdRpz1cRoA28sMhSAHve(1EKKcyhbLNWlB8CxgHb3SnSegksCogclHbqcBUgDByjmynyI1yiSWSc(VUaYQD)l)yvumYgftScpwrc(roqwH7lDIBmXkebDghLvZRFajSWkyfayTcwxyGkpssGcPryWC9sx7cdJzn6pNbYiBumLL)YVWhLvlSApRgicQ8Adpq6AVynjH1XSg9NZWJUapcmtXOqX0ft1MPIoGTnrHpkRwy1arqLxB4bsx7fRpznjH1XSAE9diHzvewbaRwy9iZRFaP82XeRaKvrZ6twtsy186hqcZQiSAhwtsyn6pNbJN7Ye(OS(KvlS6OzZlzEWQfwr4x7rskGDeuEcVSXZDzegCZ2Wsy41LZCmewcRGvaGOfSUWavEKKafsJWG56LU2fggZA0FodKr2Oykl)LFHpkRwy1Ewnqeu51gEG01EXAscRJzn6pNHhDbEeyMIrHIPlMQntfDaBBIcFuwTWQbIGkV2WdKU2lwFYAscRJz186hqcZQiScawTW6rMx)as5TJjwbiRIM1NSMKWQ51pGeMvry1oSMKWA0Fodgp3Lj8rz9jRwy1rZMxY8GvlSIWV2JKua7iO8eEzJN7Yim4MTHLWW8lL5yiSewbRaaaJG1fgOYJKeOqAegajS5A0THLWG1GjwbCGIcRWIvdOWGB2gwcdI97A4LHZmj)fjScwbaIkbRlmqLhjjqH0imyUEPRDHbYiBumf6kl)LFSMKWkzKnkMcyO0VCr2yznjHvYiBumf8cPCr2yznjH1O)Cge731WldNzs(lk8rz1cRr)5mqgzJIPS8x(f(OSMKW6ywJ(ZzW45UmHJI9UWScqwDZ2Wki(89nq2Gm)LYBhtSAH1O)CgmEUlt4JY6tHb3SnSegWRFZ(iHbqcBUgDByjmynyI1H1VzFeRlKv0dAyDak9JvrXiBumHmwTkYdO0UmS(6ywLegZ62XeR7RxS6Sc4C((YkzdY8xIvjnxwHhRWsIeR29V8JvrXiBumXAJz9JkScwbaIAbRlmqLhjjqH0imasyZ1OBdlHbRbtSc4C((YkCFPtCJjwf)2MxwBmRDX6au6hRIIr2OyczSAvKhqPDzyfESUqwrpOHv7(x(XQOyKnkMegCZ2Wsyq857RWkyfaKwcwxyGkpssGcPryWnBdlHH7xz3SnSYYgVcdGe2Cn62WsyWMXLY99(cdYgV5YJjHHPlL779fwHvya9idmoYxbRlyfBfSUWGB2gwcdp6c8iWmgTVEXcdu5rscuincRGvaGG1fgOYJKeOqAegGOcdyAfgCZ2WsyaHFThjjHbeU8tcdPkmGWVC5XKWaSYFmL3RRh0kmasyZ1OBdlHbR)sSIWV2JKeRnMvmTSUqwtLvX9(YAbzfV(YkSy9Jjw3RRh0IrgR2YQ4xQyDFjwN9HxwHfXAJzfwS(XeYyfaS2tw3xIvmzGfiRnMvVaz1oS2twJG7lR(rcRGvSJG1fgOYJKeOqAegGOcdoiOWGB2gwcdi8R9ijjmGWLFsyWwHbe(LlpMegGv(JP8ED9GwHbZ1lDTlmSxxpOnS2g(ypssSAH1966bTH12GbcLGqXva8F(2WsyfSI1kyDHbQ8ijbkKgHbiQWGdckm4MTHLWac)ApsscdiC5NegaGWac)YLhtcdWk)XuEVUEqRWG56LU2fg2RRh0gwae(ypssSAH1966bTHfabdekbHIRa4)8THLWkyfrlyDHb3SnSegIHW6rx5j8IfgOYJKeOqAewbRayeSUWavEKKafsJWGB2gwcdIpFFfgKDrzdOWGTPkmasyZ1OBdlHHr4rghVScawbCoFFz1lqwDwhw)W)diXkSyDW6SkU3xwTsd8Dz1MXjw9cK10arERZk8yDy9B2hXkCFPtCJjHbZ1lDTlmmMvYiBumfK)YVCr2yznjHvYiBumf6kl)LFSMKWkzKnkMcDLJG7lRjjSsgzJIPGxiLlYglRpfwbRiQeSUWavEKKafsJWG56LU2fggZkzKnkMcYF5xUiBSSMKWkzKnkMcDLL)YpwtsyLmYgftHUYrW9L1KewjJSrXuWlKYfzJL1NSAHv0JqeSni(89LvlSApROhHiaGG4Z3xHb3SnSegeF((kScwrulyDHbQ8ijbkKgHbZ1lDTlmypR3VOj8asHix6LHYWz2LY8(2fqCGkpssGSMKWQ9SAGiOYRnunW3npDI1KewTNvmkjL51pG0Id41VPlLSkcR2YAscR2Z66sQ2q57)iCoYLEzOavEKKafgCZ2WsyaV(n7JewbRKwcwxyGkpssGcPryWC9sx7cd3VOj8asHix6LHYWz2LY8(2fqCGkpssGSAHvdebvETHQb(U5PtSAHvmkjL51pG0Id41VPlLSkcR2km4MTHLWaE9d)pGKWkScRWac6WnSeScasfa2MQTaWocdI9R6ciwyaWb5hbSsABLrW2fwz16VeRDmk8wwNWJvKdKM(xUihRhnI)(iqwXWyIv)VWyFjqwnVEbKWbof7UlIvaJDHvRcle0TeiRdDSvzfJuTUnyfWY6cz1U)oRGnIg3WIvikD(cpwhdONSoga24zGtXU7Iy1wBTlSAvyHGULazf5UFrt4bKcaUihRlKvK7(fnHhqka4gOYJKeiYX6yBTXZaNID3fXQT2Axy1QWcbDlbYkYTxxpOnyBaWf5yDHSIC711dAdRTbaxKJ1X2AJNbof7UlIvBbGDHvRcle0TeiRi39lAcpGuaWf5yDHSIC3VOj8asba3avEKKarowhBRnEg4uS7UiwTfa2fwTkSqq3sGSIC711dAd2gaCrowxiRi3ED9G2WABaWf5yDST24zGtXU7Iy1wayxy1QWcbDlbYkYTxxpOnaGaGlYX6czf52RRh0gwaeaCrowhBRnEg4uS7UiwT1o2fwTkSqq3sGSIC3VOj8asbaxKJ1fYkYD)IMWdifaCdu5rsce5yDmaSXZaNcNcGdYpcyL02kJGTlSYQ1Fjw7yu4TSoHhRih6rgyCKVihRhnI)(iqwXWyIv)VWyFjqwnVEbKWbof7UlIv7yxy1QWcbDlbYkYTxxpOnyBaWf5yDHSIC711dAdRTbaxKJ1XaWgpdCk2DxeRwRDHvRcle0TeiRi3ED9G2aacaUihRlKvKBVUEqBybqaWf5yDmaSXZaNID3fXQO2UWQvHfc6wcKvK7(fnHhqka4ICSUqwrU7x0eEaPaGBGkpssGihRJT1gpdCk2DxeRPLDHvRcle0TeiRi39lAcpGuaWf5yDHSIC3VOj8asba3avEKKarowhBRnEg4u4uaCq(raRK2wzeSDHvwT(lXAhJcVL1j8yf5CiHCSE0i(7JazfdJjw9)cJ9Laz186fqch4uS7UiwTJDHvRcle0TeiRi39lAcpGuaWf5yDHSIC3VOj8asba3avEKKarowhBRnEg4uS7UiwfTDHvRcle0TeiRdDSvzfJuTUnyfWcyzDHSA3FN1yi4x(XScrPZx4X6ya7twhBRnEg4uS7Uiwfv2fwTkSqq3sGSo0XwLvms162GvalRlKv7(7Sc2iACdlwHO05l8yDmGEY6yBTXZaNID3fXQTPAxy1QWcbDlbY6qhBvwXivRBdwbSSUqwT7VZkyJOXnSyfIsNVWJ1Xa6jRJT1gpdCk2DxeR2AT2fwTkSqq3sGSo0XwLvms162GvalGL1fYQD)DwJHGF5hZkeLoFHhRJbSpzDST24zGtXU7Iy120YUWQvHfc6wcK1Ho2QSIrQw3gScyzDHSA3FNvWgrJByXkeLoFHhRJb0twhBRnEg4uS7UiwbGT2fwTkSqq3sGSo0XwLvms162GvalRlKv7(7Sc2iACdlwHO05l8yDmGEY6yBTXZaNID3fXkaam2fwTkSqq3sGSo0XwLvms162GvalRlKv7(7Sc2iACdlwHO05l8yDmGEY6yayJNbofofahKFeWkPTvgbBxyLvR)sS2XOWBzDcpwrUPlL779rowpAe)9rGSIHXeR(FHX(sGSAE9ciHdCk2DxeRaWUWQvHfc6wcK1Ho2QSIrQw3gScyzDHSA3FNvWgrJByXkeLoFHhRJb0twhBRnEg4u4uaCq(raRK2wzeSDHvwT(lXAhJcVL1j8yf5WlYX6rJ4VpcKvmmMy1)lm2xcKvZRxajCGtXU7Iy1wBTlSAvyHGULazDOJTkRyKQ1TbRawalRlKv7(7Sgdb)YpMvikD(cpwhdyFY6yBTXZaNID3fXQTaWUWQvHfc6wcK1Ho2QSIrQw3gScybSSUqwT7VZAme8l)ywHO05l8yDmG9jRJT1gpdCk2DxeRaiv7cRwfwiOBjqwh6yRYkgPADBWkGL1fYQD)DwbBenUHfRqu68fESogqpzDST24zGtHtbWb5hbSsABLrW2fwz16VeRDmk8wwNWJvKlc6lYX6rJ4VpcKvmmMy1)lm2xcKvZRxajCGtXU7Iy1wrTDHvRcle0TeiRdDSvzfJuTUnyfWY6cz1U)oRGnIg3WIvikD(cpwhdONSo2o24zGtXU7Iy120YUWQvHfc6wcK1Ho2QSIrQw3gScyzDHSA3FNvWgrJByXkeLoFHhRJb0twhBRnEg4u4us7yu4TeiRagwDZ2WIvzJxCGtrya9GZwscdJCKSMgx6LHy1UE)gKtzKJK1u867hsSAhBrgRaivaylNcNYihjRw91lGe2UWPmYrYQnNvKheKazDak9J10qECGtzKJKvBoRw91lGeiRRFaPn3twnoMWSUqwnizKuE9diT4aNYihjR2CwhbOyiccK1FvKHWy)qIve(1EKKWSoUduazSIEeImE9d)pGeR280zf9ieb86h(FaPNboLroswT5SI8iGniROhzC82fqwbCoFFzTNS2lYHzDFjwfFWciRIIr2OykWPmYrYQnN1rq9heRwfwiGpiw3xI1b0(6fZQZQS3vsSgdpI1PKSrhjjwh3twrc(z91blKBz9Txw7LvCh)LRxe8JLiXQ4EFznn2SG8wN1rz1QKKWB7swrEzdSIPArgR9ICGSIF0OpdCkCkUzByHdOhzGXr(kYJUapcmJr7RxmNYiz16VeRi8R9ijXAJzftlRlK1uzvCVVSwqwXRVSclw)yI1966bTyKXQTSk(Lkw3xI1zF4LvyrS2ywHfRFmHmwbaR9K19LyftgybYAJz1lqwTdR9K1i4(YQFeNIB2gw4a6rgyCKVJkcGq4x7rsczLhtIaR8ht5966bTidHl)KiPYP4MTHfoGEKbgh57OIaie(1EKKqw5XKiWk)XuEVUEqlYGOI4GGidHl)Ki2ISEkYED9G2GTHp2JKKL966bTbBdgiuccfxbW)5Bdlof3SnSWb0JmW4iFhveaHWV2JKeYkpMebw5pMY711dArgeveheeziC5NebaiRNISxxpOnaGWh7rsYYED9G2aacgiuccfxbW)5Bdlof3SnSWb0JmW4iFhveafdH1JUYt4fZPmswhHhzC8YkayfW589LvVaz1zDy9d)pGeRWI1bRZQ4EFz1knW3LvBgNy1lqwtde5ToRWJ1H1VzFeRW9LoXnM4uCZ2WchqpYaJJ8DuraK4Z3xKj7IYgqrSnvK1trgtgzJIPG8x(LlYgBsczKnkMcDLL)YVKeYiBumf6khb33KeYiBumf8cPCr2yFYP4MTHfoGEKbgh57OIaiXNVViRNImMmYgftb5V8lxKn2KeYiBumf6kl)LFjjKr2Oyk0vocUVjjKr2Oyk4fs5ISX(0c6ric2geF((AXE0Jqeaqq857lNIB2gw4a6rgyCKVJkcGWRFZ(iK1trS)(fnHhqke5sVmugoZUuM33UaItsS3arqLxBOAGVBE6usI9yuskZRFaPfhWRFtxkfX2Ke7xxs1gkF)hHZrU0ldfOYJKeiNIB2gw4a6rgyCKVJkcGWRF4)bKqwpf5(fnHhqke5sVmugoZUuM33UaITyGiOYRnunW3npDYcgLKY86hqAXb8630LsrSLtHtzKJKvrXgK5VeiRec6qI1TJjw3xIv3SWJ1gZQJWBPhjPaNIB2gwyrWqPF5iYJ5ugjRd0Izf5HIcRWIv7mkRI79f(xwbVEUS6fiRI79L1H1pj8az1lqwbWOSc3x6e3yItXnBdlSii8R9ijHSYJjrAC2HeYq4YpjcgLKY86hqAXb8630LY0T1Yy7xxs1gWRFs4bgOYJKeysY6sQ2aEjP0Vm41ZnqLhjjWNjjyuskZRFaPfhWRFtxkthaCkJK1bAXSAKKJGyv8lvSoS(n7Jy14fRV9YkagL11pG0Izv8BBEzTXSEKKq41Y6eESUVeRIIr2OyI1fYAeXk6rt6ocKtXnBdl8OIaie(1EKKqw5XKinoBKKJGqgcx(jrWOKuMx)asloGx)M9rPBlNYiz1AWeRr0HP7rxazvCVVSACwHhR(CPJvRcleWheRDXQX5uCZ2WcpQiakIomDp6ciY6PiJT3arqLxBOAGVBE6usI9giuccfxbdSqaFq59LYy0(6fh(OpTe9NZGXZDzcFuoLrY6ieUSkU3xwnoR7RVS24c5wwDwhHFj2pwrpOHtXnBdl8OIaiu42Wcz9uKO)CgmEUlt4OyVlC62MkNYiz1QU08L(sywf)s7lDS(XDbKvRcleWheRfumRIBPKvxkHIzfj4N1fYkEBPKvJJxw3xIvShtS6XWFTScNSAvyHa(Gg1QipGs7YWQXXlMtXnBdl8OIaie(1EKKqw5XKigyHa(GYGegPYGmeU8tIyOwoECxlDOqPVeyE2aF38rXExyBUTI2MBGqjiuCfmEUlt4OyVl8taRTI6uFkIHA54XDT0HcL(sG5zd8DZhf7DHT52kABUTaivBUbcLGqXvWaleWhuEFPmgTVEXHJI9UWpbS2kQt9zsIbcLGqXvW45UmHJI9UWP31shku6lbMNnW3nFuS3fojXaHsqO4kyGfc4dkVVugJ2xV4WrXEx407APdfk9LaZZg47Mpk27cBZTn1Ke7nqeu51gQg47MNoXPmswTgmbY6czfKKosSUVeRFSdKyfoz1QipGs7YWQ4xQy9J7ciRGWFKKyfwS(XeNIB2gw4rfbqi8R9ijHSYJjrmGzdSa7THfYq4YpjYy7Pr83OOeyGIrr6ixMHhy5LHssmqOeekUcumksh5Ym8alVmu4OyVlmaTfWKQf7nqOeekUcumksh5Ym8alVmu4ihePNjjgicQ8Adpq6AV4ugjRwdMyvuIrr6ixYQnlhy5LHyfaPIjdM1iAcpIvNvRI8akTldRFmf4uCZ2WcpQia6JPCVumYkpMeHIrr6ixMHhy5LHqwpfXaHsqO4ky8CxMWrXExyacGuTyGqjiuCfmWcb8bL3xkJr7RxC4OyVlmabqQjjZg47Mpk27cdq7iQ4ugjRwdMyDa(LsA7ciRJa)iKyfWGjdM1iAcpIvNvRI8akTldRFmf4uCZ2WcpQia6JPCVumYkpMebd)sjTBxaZ3pcjK1trmqOeekUcgp3LjCuS3fgGagl2JWV2JKuWaleWhugKWivMKedekbHIRGbwiGpO8(szmAF9Idhf7DHbiGXcc)ApssbdSqaFqzqcJuzssMnW3nFuS3fgGaq0CkUzByHhvea9XuUxkgzLhtI0f2C)1JKuEe)ET)4miHOneY6Pir)5my8CxMWhLtzKSA93gZAJz1z989LowjPhbpFjwf7iX6czn2FqS6sjRWI1pMyfV(Y6ED9GwmRlK1iIvzxeiRFuwf37lRwf5buAxgw9cKvRcleWheREbY6htSUVeRaOazflHlRWIvdiR9K1i4(Y6ED9GwmR(rSclw)yIv86lR711dAXCkUzByHhveaTxxpO1wK1trgJWV2JKuaw5pMY711dAfX2Kee(1EKKcWk)XuEVUEqRi25PLXr)5my8CxMWhnjXaHsqO4ky8CxMWrXEx4rbq6711dAd2gmqOeekUcG)Z3gwwgBVbIGkV2q1aF380PKe7r4x7rskyGfc4dkdsyKkZtl2BGiOYRn8aPR9kjXarqLxBOAGVBE6Kfe(1EKKcgyHa(GYGegPYyXaHsqO4kyGfc4dkVVugJ2xV4Wh1I9giuccfxbJN7Ye(Owgpo6pNbYiBumLL)YVWrXEx40Tn1KKO)CgiJSrXugdL(fok27cNUTP(0I93VOj8asHix6LHYWz2LY8(2fqCsY4O)CgICPxgkdNzxkZ7BxaX5Y3)rb86MhIi6KKO)CgICPxgkdNzxkZ7BxaXz)mErb86MhIi6NptsI(Zz4rxGhbMPyuOy6IPAZurhW2MOWh9zsYSb(U5JI9UWaeaPMKGWV2JKuaw5pMY711dAfjvof3SnSWJkcG2RRh0caK1trq4x7rskaR8ht5966bTIyhl2VxxpOnyB4ihePSbcLGqXvsY4O)CgmEUlt4JMKyGqjiuCfmEUlt4OyVl8Oai9966bTbaemqOeekUcG)Z3gwwgBVbIGkV2q1aF380PKe7r4x7rskyGfc4dkdsyKkZtl2BGiOYRn8aPR9kjXarqLxBOAGVBE6Kfe(1EKKcgyHa(GYGegPYyXaHsqO4kyGfc4dkVVugJ2xV4Wh1I9giuccfxbJN7Ye(Owgpo6pNbYiBumLL)YVWrXEx40Tn1KKO)CgiJSrXugdL(fok27cNUTP(0I93VOj8asHix6LHYWz2LY8(2fqCsY4O)CgICPxgkdNzxkZ7BxaX5Y3)rb86MhIi6KKO)CgICPxgkdNzxkZ7BxaXz)mErb86MhIi6NpFMKe9NZWJUapcmtXOqX0ft1MPIoGTnrHpAsYSb(U5JI9UWaeaPMKGWV2JKuaw5pMY711dAfjvoLrYQ1GjmRUuYkCFPJvyX6htS2lfJzfwSAa5uCZ2WcpQia6JPCVumgz9uKO)CgmEUlt4JMKyGiOYRnunW3npDYcc)ApssbdSqaFqzqcJuzSyGqjiuCfmWcb8bL3xkJr7RxC4JAXEdekbHIRGXZDzcFulJhh9NZazKnkMYYF5x4OyVlC62MAss0FodKr2OykJHs)chf7DHt32uFAX(7x0eEaPqKl9Yqz4m7szEF7cioj5(fnHhqke5sVmugoZUuM33UaITmo6pNHix6LHYWz2LY8(2fqCU89FuaVU5r62jjj6pNHix6LHYWz2LY8(2fqC2pJxuaVU5r6255ZKKO)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rtsMnW3nFuS3fgGaivoLrYQDLmniXQB2gwSkB8YAKJjqwHfR4E)(2WcqscyJ5uCZ2WcpQia6(v2nBdRSSXlYkpMeXHeYW71MveBrwpfbHFThjPqJZoK4uCZ2WcpQia6(v2nBdRSSXlYkpMejc6lYW71MveBrwpf5(fnHhqke5sVmugoZUuM33UaId0i(BuucKtXnBdl8OIaO7xz3SnSYYgViR8yse8YPWPmswTQlnFPVeMvXV0(shR7lXQD9ip24R5LowJ(ZjRIBPK1PlLScNtwf37BxSUVeRfzJLvJJxof3SnSWbhsIGWV2JKeYkpMeb8ipolULY80LYmCorgcx(jrgh9NZW2XKy4vzWJ84OUaPlCuS3fgGanGHy3gJMAW2KKO)Cg2oMedVkdEKhh1fiDHJI9UWa0nBdRaE9B2hfiBqM)s5TJPrtnyRLXKr2Oyk0vw(l)ssiJSrXuadL(LlYgBsczKnkMcEHuUiBSpFAj6pNHTJjXWRYGh5XrDbsx4JA5(fnHhqkSDmjgEvg8ipoQlq6c0i(BuucKtzKSAvxA(sFjmRIFP9Lowhw)W)diXAJzvm82xwnoE7ciRqe0X6W63SpI1Uy1U)LFSkkgzJIjof3SnSWbhsJkcGq4x7rsczLhtI0al4rz86h(FajKHWLFse7jJSrXuORmgk9ZYymkjL51pG0Id41VzFu6I2Y6sQ2ag(Lz4mVVuEcpcVbQ8ijbMKGrjPmV(bKwCaV(n7Jsxu9KtzKSAnyIvRcleWheRIFPIvFzvsymR7RxSk6uz1X75swrHIPJvVazv2fX6hLvX9(YQvrEaL2LHvX9(c)lRsiUlGS6S(XeNIB2gw4GdPrfbqgyHa(GY7lLXO91lgz9uKXi8R9ijfmWcb8bLbjmsLXI9giuccfxbJN7YeoYbrkjj6pNbJN7Ye(OpTm2X75YmkumDau0PMKGWV2JKuObwWJY41p8)aspTmo6pNbYiBumLL)YVWrXEx40bmjjr)5mqgzJIPmgk9lCuS3foDaZtlJT)(fnHhqke5sVmugoZUuM33UaItsI(ZziYLEzOmCMDPmVVDbeNlF)hfWRBEKUDssI(ZziYLEzOmCMDPmVVDbeN9Z4ffWRBEKUDEMKmBGVB(OyVlmaTnvoLrYQ1GjwX)A2hXAxSI6fif3gwf)sfR(YQTwlMmywpk27QlGScpwLegZQ4EFzngEeRRFaPfZQxGS2tw7LvXWVeK1PlLScNtwJOj8iwPAPRlGSUVeRfzJLvrXiBumXP4MTHfo4qAurae(xZ(iKzqYiP86hqAXIylY6PiJpAEe(1JKuss0FodKr2OykJHs)chf7DHbODSqgzJIPqxzmu6NLJI9UWa0wR1Y6sQ2ag(Lz4mVVuEcpcVbQ8ijb(0Y6hqAdBht5fMbBkDBTwBogLKY86hqAXJEuS3f2YyYiBumf6k7fsjjhf7DHbiqdyi2TXtoLrYQnReHY6hL1H1VPlLS6lRUuY62XeM1FjjmM1pUlGSA3iz8ZXS6fiR9YAJz1JG)L1fYk6bnScpwL0Y6(sSIrjt7swDZ2WIvzxeRrKekM1xVaLeR21J84OUaPJvyXkayD9diTyof3SnSWbhsJkcGWRFtxkrwpfzC0Fod41VPlLHJMhHF9ijzzmgLKY86hqAXb8630LsaANKe7VFrt4bKcBhtIHxLbpYJJ6cKUanI)gfLaFMKSUKQnGHFzgoZ7lLNWJWBGkpssGwI(ZzGmYgftzmu6x4OyVlmaTJfYiBumf6kJHs)Se9NZaE9B6sz4OyVlmafvwWOKuMx)asloGx)MUuMUiw7tlJT)(fnHhqkirY4NJZtjrBxaZaLDmkMc0i(Buucmjz7ycWcyTwrNE0Fod41VPlLHJI9UWJcGNww)asBy7ykVWmytPlAoLrYkGtVVSAxpYJJ6cKow)yI1H1VPlLSUqwFqekRFuw3xI1O)CYAesS6smK1pUlGSoS(nDPKvyXQOzftgybIzfESkjmM1JI9U6ciNIB2gw4GdPrfbq41VPlLiRNIC)IMWdif2oMedVkdEKhh1fiDbAe)nkkbAbJsszE9diT4aE9B6sz6IyhlJTp6pNHTJjXWRYGh5XrDbsx4JAj6pNb8630LYWrZJWVEKKssgJWV2JKua8ipolULY80LYmCoTmo6pNb8630LYWrXExyaANKemkjL51pG0Id41VPlLPdalRlPAd4LKs)YGxp3avEKKaTe9NZaE9B6sz4OyVlmaf9ZNp5ugjRw1LMV0xcZQ4xAFPJvN1H1p8)asS(XeRIBPKvJ)XeRdRFtxkzDHSoDPKv4CImw9cK1pMyDy9d)pGeRlK1heHYQD9ipoQlq6yfVU5bRFuof3SnSWbhsJkcGq4x7rsczLhtIGx)MUuMfdRnpDPmdNtKHWLFsehVNlZOqX0LUOovB(yBtfWh9NZW2XKy4vzWJ84OUaPlGx384PnFC0Fod41VPlLHJI9UWaE7ayXOKuMFD8spT5JbHBy(pKYWzMK)Ichf7DHb8I(PLO)CgWRFtxkdFuoLrYQ1Gjwhw)W)diXQ4EFz1UEKhh1fiDSUqwFqekRFuw3xI1O)CYQ4EFH)Lvje3fqwhw)MUuY6hD7yIvVaz9Jjwhw)W)diXkSy1AhL10arERZkEDZdmR)ABjRwlRRFaPfZP4MTHfo4qAuraeE9d)pGeY6Pii8R9ijfapYJZIBPmpDPmdNtli8R9ijfWRFtxkZIH1MNUuMHZPf7r4x7rsk0al4rz86h(FaPKKXr)5me5sVmugoZUuM33UaIZLV)Jc41nps3ojjr)5me5sVmugoZUuM33UaIZ(z8Ic41nps3opTGrjPmV(bKwCaV(nDPeGwlNYiz1AWeRyX(fZkgY6(6lRib)ScKwwJDBW6hD7yI1iKy9J7ciR9YQJzv6lXQJzffIXDKKyfwSkjmM191lwTdR41npWScpwTz)XlRIFPIv7mkR41npWSs2aTpItXnBdlCWH0OIaih0r3gbLXI9lgzgKmskV(bKwSi2ISEkI9BBE0fql27MTHvWbD0TrqzSy)IZGESdKcDLNYg47MKac3Gd6OBJGYyX(fNb9yhifWRBEaq7ybeUbh0r3gbLXI9lod6XoqkCuS3fgG2HtzKSocqZJWVSgdH1SpI1EYQvrEaL2LH1gZ6roisScpw3x6iw9JyvsymR7RxSkAwx)aslM1Uy1U)LFSkkgzJIjwf37lRy4ozfESkjmM191lwTnvwH7lDIBmXAxS6fsSkkgzJIPaR2vyHClRhnpc)Yk4)6ciRp6c8iqwPyuOy6IPAz1lqwbHfYTScrqNXrz1XOCkUzByHdoKgveafdH1SpczgKmskV(bKwSi2ISEkYrZJWVEKKSS(bK2W2XuEHzWMsFSTw7OJXOKuMx)asloGx)M9raEBdI(5talgLKY86hqAXJEuS3f2Y4XgiuccfxbJN7YeoYbrYI9G3VbdfmBaXwgJWV2JKuWaleWhugKWivMKedekbHIRGbwiGpO8(szmAF9Idh5GiLKyVbIGkV2q1aF380PNjjyuskZRFaPfhWRFZ(iaow0a(X2o66sQ2WkURCmew4avEKKaF(mjzmzKnkMcDLXqPFjjJjJSrXuORCeCFtsiJSrXuORS8x(90I9RlPAdy4xMHZ8(s5j8i8gOYJKeyss0FodOxhdpW2Lz)mE1Mm6xI9lGWLFkDraGOt9PLXyuskZRFaPfhWRFZ(iaABQa(X2o66sQ2WkURCmew4avEKKaF(0IJ3ZLzuOy6sx0PAZJ(ZzaV(nDPmCuS3fgWdyEAzS9r)5m8OlWJaZumkumDXuTzQOdyBtu4JMKqgzJIPqxzmu6xsI9gicQ8Adpq6AVEAXrZMxY84jNYiz1AWeRtyXkSy1aYQ4EFH)LvJJI2fqof3SnSWbhsJkcGMWZqz4mx((pcz9uehnBEjZdoLrYQ1GjwNhv2esSclwnGiJ19TXSkULsw9)cJ9TnUuIeRYUiw)OSkU3xwnoNIB2gw4GdPrfbqNJGk4hNNhv2esiRNIe9NZGXZDzcFuoLrYQ1GjwTkYdO0UmSclwnGS(ljHXSIe8ZQXlwLDrS2lRFuwf37lRwfwiGpiwf37l8VSkH4UaYQZQXXlNIB2gw4GdPrfbqgss4TDz2LnWkMQfz9ue7bVFdgky2aITGWV2JKuWaMnWcS3gwwgh9NZaE9B6sz4JMK449CzgfkMU0fDQpTyF0FodyOeVTHcFul2h9NZGXZDzcFulJT3arqLxBOAGVBE6uscc)ApssbdSqaFqzqcJuzssmqOeekUcgyHa(GY7lLXO91lo8rts6APdfk9LaZZg47Mpk27cdqaK6OJnWc83Ba9itJPSlBGvmvBy7ykJWLF65tof3SnSWbhsJkcG6Y4x5BdlK1trSh8(nyOGzdi2cc)Apssbdy2alWEByzzC0Fod41VPlLHpAsIJ3ZLzuOy6sx0P(0I9r)5mGHs82gk8rTyF0Fodgp3Lj8rTm2EdebvETHQb(U5Ptjji8R9ijfmWcb8bLbjmsLjjXaHsqO4kyGfc4dkVVugJ2xV4WhnjPRLouO0xcmpBGVB(OyVlmanqOeekUcgyHa(GY7lLXO91loCuS3fEuatssxlDOqPVeyE2aF38rXExyalG1wrDQa0oPo6ydSa)9gqpY0yk7Ygyft1g2oMYiC5NE(KtzKSAnyIvyXQbKvX9(Y6W630Lsw)OS6fiRyhbX6eESoc)sSFCkUzByHdoKgvearXOqX0LJGfiY6PiDT0HcL(sG5zd8DZhf7DHbOTIojzC0FodOxhdpW2Lz)mE1Mm6xI9lGWLFcGaq0PMKe9NZa61XWdSDz2pJxTjJ(Ly)ciC5Nsxeai6uFAj6pNb8630LYWh1YydekbHIRGXZDzchf7DHtx0PMKaE)gmuWSbe)KtzKSocqZJWVSoL(rSclw)OSUqwTdRRFaPfZQ4EFH)L1UmaY4SgrDbKvpc(xwxiRKnq7Jy1lqwl4YkebDghfTlGCkUzByHdoKgveaHxsk9lpL(riZGKrs51pG0IfXwK1troAEe(1JKKLTJP8cZGnLUTI2cgLKY86hqAXb863SpcGwRfhnBEjZdlJJ(ZzW45UmHJI9UWPBBQjj2h9NZGXZDzcF0NCkJKvRbtywTzGIcR9K1UWniXQxSkkgzJIjw9cKvzxeR9Y6hLvX9(YQZ6i8lX(Xk6bnS6fiRipOJUncI1bX(fZP4MTHfo4qAura08FiLHZmj)fHSEkczKnkMcDL9cjloA28sMhwI(Zza96y4b2Um7NXR2Kr)sSFbeU8taeaIovlJbHBWbD0TrqzSy)IZGESdKcBBE0fWKe7nqeu51gkYCqj8atsWOKuMx)asloDa8KtzKSAnyIvVyfw0(Yk6bnS(ljHXSoS(nDPK1gZQlpYbrI1pkRWJvKGFw9Jy1JG)L1fYkebDghLvhJYP4MTHfo4qAuraeE9B6sjY6Pir)5malAFXzu6me62Wk8rTmo6pNb8630LYWrZJWVEKKssC8EUmJcftx6PvQp5ugjR21FmkRogL1iAcpIvRcleWheRI79L1H1VPlLS6fiR7lvSoS(H)hqItXnBdlCWH0OIai8630LsK1trmqeu51gQg47MNozzmc)ApssbdSqaFqzqcJuzssmqOeekUcgp3Lj8rtsI(ZzW45UmHp6tlgiuccfxbdSqaFq59LYy0(6fhok27cdqGgWqSBdaVHA5yhVNlZOqX0byfDQpTe9NZaE9B6sz4OyVlmaTwl2dE)gmuWSbeZP4MTHfo4qAuraeE9d)pGeY6PigicQ8Advd8DZtNSmgHFThjPGbwiGpOmiHrQmjjgiuccfxbJN7Ye(Ojjr)5my8CxMWh9PfdekbHIRGbwiGpO8(szmAF9Idhf7DHbiGXs0Fod41VPlLHpQfYiBumf6k7fswShHFThjPqdSGhLXRF4)bKSyp49BWqbZgqmNYiz1AWeRdRF4)bKyvCVVS6fRWI2xwrpOHv4XksWpYbYkebDghLvhJYQ4EFzfj4)yTiBSSAC8gyf5LyiRG)yumRogLvFzDFjwPcKv4K19Lyfbv7lshRr)5K1EY6W630Lswfd)sWAzD6sjRW5KvyXQ1Yk8yvsymRRFaPfZP4MTHfo4qAuraeE9d)pGeY6Pir)5malAFXzJK8lJOXnScF0KKX2Jx)M9rbhnBEjZdl2JWV2JKuObwWJY41p8)asjjJJ(ZzW45UmHJI9UWau0wI(ZzW45UmHpAsY4O)CgohbvWpoppQSjKchf7DHbiqdyi2TbG3qTCSJ3ZLzuOy6aS2j1NwI(Zz4Ceub)488OYMqk8rF(0cc)Apssb8630LYSyyT5PlLz4CAbJsszE9diT4aE9B6sjaTZtlJT)(fnHhqkSDmjgEvg8ipoQlq6c0i(BuucmjbJsszE9diT4aE9B6sjaTZtoLrYQ1GjwJHWcZk4)6ciR29V8J1FjjmMvic6mokAxazDCSJueXAreiMvZRxajmRI79LvhVNlzngcl8tof3SnSWbhsJkcGksCogclK1trgtgzJIPqxzVqYIbcLGqXvW45UmHJI9UWPl6utsgBE9diHfbawoY86hqkVDmbqr)mjX86hqclIDEAXrZMxY8GtXnBdlCWH0OIaOxxoZXqyHSEkYyYiBumf6k7fswmqOeekUcgp3LjCuS3foDrNAsYyZRFajSiaWYrMx)as5TJjak6NjjMx)asyrSZtloA28sMhCkUzByHdoKgvean)szogclK1trgtgzJIPqxzVqYIbcLGqXvW45UmHJI9UWPl6utsgBE9diHfbawoY86hqkVDmbqr)mjX86hqclIDEAXrZMxY8GtzKSAnyIvahOOWk4)6ciR29V8JvrXiBumXP4MTHfo4qAuraKy)UgEz4mtYFrCkUzByHdoKgveaHWV2JKeYkpMebV(n7JYDLXqPFidHl)KiyuskZRFaPfhWRFZ(O0T2rNsi8gh74LoKYiC5Na82MAQawaK6ZrNsi8gh9NZaE9d)pGuMIrHIPlMQnJHs)c41npaSw7toLrYQ1GjwbCoFFzTlwhGs)yvumYgftScpw3xIvPJxwhw)M9rSkgwlRZEzTRfYQZQvrEaL2LH1O)Cg4uCZ2WchCinQias857lY6PiKr2Oyki)LF5ISXMKqgzJIPGxiLlYgRfe(1EKKcnoBKKJGssI(ZzGmYgftzmu6x4OyVlmaDZ2WkGx)M9rbYgK5VuE7yYs0FodKr2OykJHs)cF0KeYiBumf6kJHs)Sypc)Apssb863Spk3vgdL(LKe9NZGXZDzchf7DHbOB2gwb863Spkq2Gm)LYBhtwShHFThjPqJZgj5iilr)5my8CxMWrXExyas2Gm)LYBhtwI(ZzW45UmHpAss0FodNJGk4hNNhv2esHpQfmkjL5xhVu6PgamwgJrjPmV(bKwmafXojj2VUKQnGHFzgoZ7lLNWJWBGkpssGptsShHFThjPqJZgj5iilr)5my8CxMWrXEx40jBqM)s5TJjoLrYQ1Gjwhw)M9rS2tw7Iv7(x(XQOyKnkMqgRDX6au6hRIIr2OyIvyXQ1okRRFaPfZk8yDHSIEqdRdqPFSkkgzJIjof3SnSWbhsJkcGWRFZ(ioLrYQnJlL7795uCZ2WchCinQia6(v2nBdRSSXlYkpMez6s5(EFofoLrYQnZrLnHeRI79LvRI8akTldNIB2gw4qe0xrohbvWpoppQSjKqwpfj6pNbJN7Ye(OCkJKvR(sMhyw7jR7lXQ56L1O)CYAJzTGlRFuwNWJvPV0X6htCkUzByHdrqFhveaHWV2JKeYkpMeXC9wW9JImeU8tIyF0FodrU0ldLHZSlL59TlG4C57)OWh1I9r)5me5sVmugoZUuM33UaIZ(z8IcFuof3SnSWHiOVJkcGCqhDBeugl2VyKzqYiP86hqAXIylY6Pir)5me5sVmugoZUuM33UaIZLV)Jc41npaO1Aj6pNHix6LHYWz2LY8(2fqC2pJxuaVU5baTwlJTheUbh0r3gbLXI9lod6XoqkST5rxaTyVB2gwbh0r3gbLXI9lod6Xoqk0vEkBGVRLX2dc3Gd6OBJGYyX(fNFjxg228OlGjjGWn4Go62iOmwSFX5xYLHJI9UWPBNNjjGWn4Go62iOmwSFXzqp2bsb86Mha0owaHBWbD0TrqzSy)IZGESdKchf7DHbOOTac3Gd6OBJGYyX(fNb9yhif228OlGp5ugjRwdMy1QWcb8bXkiHsfyxazfwSIrQmS(rzvCVVSAvKhqPDzyfwSAazfESgHeRI9E7ciRleiTV0XQ4EFz1z1C9YA0Fo5uCZ2WchIG(oQiaYaleWhuEFPmgTVEXiRNImgHFThjPGbwiGpOmiHrQmwS3aHsqO4ky8CxMWroisjjr)5my8CxMWh9PLXr)5me5sVmugoZUuM33UaIZLV)Jc41nper0jjr)5me5sVmugoZUuM33UaIZ(z8Ic41nper0ptsMnW3nFuS3fgG2MkNYiz1QEzijRdRFs4bYQ4EFzvsymR7RxScyyftgmRhf7D1fqw9cKvpc(xwxiRG)yuwhw)W)diH5uCZ2WchIG(oQiaY4LHK5O)CISYJjrWRFs4bISEkY4O)CgICPxgkdNzxkZ7BxaX5Y3)rHJI9UWPBTbrNKe9NZqKl9Yqz4m7szEF7cio7NXlkCuS3foDRni6NwC8EUmJcftx6IKwPAzSbcLGqXvW45UmHJI9UWPlQssgBGqjiuCfOyuOy6YrWcmCuS3foDrLf7J(Zz4rxGhbMPyuOy6IPAZurhW2MOWh1IbIGkV2WdKU2RNp5uCZ2WchIG(oQiacV(nDPez9uK1LuTb8ssPFzWRNBGkpssGwW0UDbehWqjmdE9CTe9NZaE9B6szaekU4ugjR21FmkRdRF4)bKWSkU3xw3xIvZ1lRr)5KvVaznIMWJy9J7ciRwfwiGpiof3SnSWHiOVJkcGWRF4)bKqwpfXEe(1EKKcMR3cUFulJnqeu51gQg47MNoLKyGqjiuCfmEUlt4OyVlC6IQKe7r4x7rskyaZgyb2Bdll2BGiOYRn8aPR9kjzSbcLGqXvGIrHIPlhblWWrXEx40fvwSp6pNHhDbEeyMIrHIPlMQntfDaBBIcFulgicQ8Adpq6AVE(KtzKSAx)XOSoS(H)hqcZAenHhXQvHfc4dItXnBdlCic67OIai86h(FajK1trgBGqjiuCfmWcb8bL3xkJr7RxC4OyVlmafTf7bVFdgky2aITmgHFThjPGbwiGpOmiHrQmjjgiuccfxbJN7Yeok27cdqr)0cc)Apssbdy2alWEBy90IJ3ZLzuOy6s3At1IbIGkV2q1aF380jl2dE)gmuWSbeZPmswTRWc5wwbHlRG)RlGSUVeRubYkCYQvrEaL2LbzSc(VUaY6JUapcKvkgfkMUyQwwHhRDX6(sSkD8YkqdiRWjREXQOyKnkM4uCZ2WchIG(oQiacHFThjjKvEmjciCZhnI)(OyQwmYq4YpjY4O)CgmEUlt4OyVlC6I2Y4O)CgohbvWpoppQSjKchf7DHtx0jj2h9NZW5iOc(X55rLnHu4J(mjX(O)CgmEUlt4J(0Yy7J(Zz4rxGhbMPyuOy6IPAZurhW2MOWh9PLXr)5mqgzJIPmgk9lCuS3foDGgWqSBJKKO)CgiJSrXuw(l)chf7DHthObme724jNIB2gw4qe03rfbq4Fn7JqMbjJKYRFaPflITiRNIC08i8RhjjlRFaPnSDmLxygSP0TfWyXrZMxY8Wcc)Apssbq4MpAe)9rXuTyof3SnSWHiOVJkcGIHWA2hHmdsgjLx)aslweBrwpf5O5r4xpssww)asBy7ykVWmytPBRDcI2IJMnVK5Hfe(1EKKcGWnF0i(7JIPAXCkUzByHdrqFhveaHxsk9lpL(riZGKrs51pG0IfXwK1troAEe(1JKKL1pG0g2oMYlmd2u62cyg9OyVlSfhnBEjZdli8R9ijfaHB(Or83hft1I5ugjR2mqRWk8V4gKyDFjwnxVSg9NtwHhRIFPIvKGFwbHfYTS(6iiwPc(b(YQJrzDHSI)hqItXnBdlCic67OIaOj8mugoZLV)JqwpfXrZMxY8GtzKSAZaffwJOj8iwDwnxVSkUlqOywHhRDHBqIvVyvumYgftCkUzByHdrqFhvean)hsz4mtYFriRNImMmYgftHUYEHusczKnkMcyO0VCxzBtsiJSrXuq(l)YDLT9PLX2BGiOYRnunW3npDkjb8(nyOGzdiojzSJ3ZLzuOy6ayAjAlJr4x7rskyUEl4(rtsC8EUmJcfthaTtQjji8R9ijfAC2H0tlJr4x7rskyGfc4dkdsyKkJf7nqOeekUcgyHa(GY7lLXO91lo8rtsShHFThjPGbwiGpOmiHrQmwS3aHsqO4ky8CxMWh95ZNwgBGqjiuCfmEUlt4OyVlC62j1KeW73GHcMnG4KehVNlZOqX0LEALQfdekbHIRGXZDzcFulJnqOeekUcumkumD5iybgok27cdq3SnSc41VzFuGSbz(lL3oMssS3arqLxB4bsx71ZKKUw6qHsFjW8Sb(U5JI9UWa02uFAzmiCdoOJUnckJf7xCg0JDGu4OyVlC6wBsI9gicQ8AdfzoOeEGp5ugjRIsmkumDSgblqwf)sfRW)IBqIvVyvumYgftScpwTkYdO0UmS2yw9i4FzfUSgrS(XeyG1bhbX6eESAvKhqPDz4uCZ2WchIG(oQiaIIrHIPlhblqK1trgtgzJIPG8x(LlYgBsczKnkMcyO0VCr2ytsiJSrXuWlKYfzJnjj6pNHix6LHYWz2LY8(2fqCU89Fu4OyVlC6wBq0jjr)5me5sVmugoZUuM33UaIZ(z8Ichf7DHt3AdIojXX75YmkumDPNwPAXaHsqO4ky8CxMWroiswSh8(nyOGzdi(PLXgiuccfxbJN7Yeok27cNUDsnjXaHsqO4ky8CxMWroispts6APdfk9LaZZg47Mpk27cdqBtLtzKSAvKhqPDzyv8lvS6lRPvQJYQJrzvCVVW)YQeI7ciRBhtS2fRPrcHGYpEzfESAZ(JxwHfRgiuccfxSk(Lkwl4YQSRUaY6hLvX9(YQvHfc4dItXnBdlCic67OIaidjj82Um7Ygyft1ISEkI9G3VbdfmBaXwq4x7rskyaZgyb2BdllJh749CzgfkMU0tRuTmo6pNHhDbEeyMIrHIPlMQntfDaBBIcF0Ke7nqeu51gEG01E9mjj6pNHijeck)4n8rTe9NZqKecbLF8gok27cdqaK6OJnWc83Ba9itJPSlBGvmvBy7ykJWLF65ZKKUw6qHsFjW8Sb(U5JI9UWaeaPo6ydSa)9gqpY0yk7Ygyft1g2oMYiC5NEMKyGiOYRnunW3npD6PLX2BGiOYRnunW3npDkjbHFThjPGbwiGpOmiHrQmjjgiuccfxbdSqaFq59LYy0(6fhoYbr6jNIB2gw4qe03rfbqDz8R8THfY6Pi2dE)gmuWSbeBbHFThjPGbmBGfyVnSSmESJ3ZLzuOy6spTs1Y4O)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rtsS3arqLxB4bsx71ZKKO)CgIKqiO8J3Wh1s0Fodrsieu(XB4OyVlmaTtQJo2alWFVb0JmnMYUSbwXuTHTJPmcx(PNpts6APdfk9LaZZg47Mpk27cdq7K6OJnWc83Ba9itJPSlBGvmvBy7ykJWLF6zsIbIGkV2q1aF380PNwgBVbIGkV2q1aF380PKee(1EKKcgyHa(GYGegPYKKyGqjiuCfmWcb8bL3xkJr7RxC4ihePNCkJKv76pgL1H1p8)asywf)sfR7lX6Sb(US2yw9i4FzDHSsfiYyDEuztiXAJz1JG)L1fYkvGiJvKGFw9Jy1xwtRuhLvhJYAxS6fRIIr2OyIv4XQvrEaL2LHvPJxmREb3x6yvupkMmyof3SnSWHiOVJkcGq4x7rsczLhtI4y0riDdKbziC5NeHmYgftHUYYF5hGxudyDZ2WkGx)M9rbYgK5VuE7yAu7jJSrXuORS8x(b4bmaw3SnScIpFFdKniZFP82X0OPgaaGfJssz(1XlXP4MTHfoeb9DuraeE9d)pGeY6PiJ7APdfk9LaZZg47Mpk27cdqRnjzC0FodNJGk4hNNhv2esHJI9UWaeObme72aWBOwo2X75YmkumDaw7K6tlr)5mCocQGFCEEuztif(OpFMKm2X75YmkumDJIWV2JKuWXOJq6gidGp6pNbYiBumLXqPFHJI9UWJcc3W8FiLHZmj)ff228aNpk27cWdGGOt3waKAsIJ3ZLzuOy6gfHFThjPGJrhH0nqgaF0FodKr2Oykl)LFHJI9UWJcc3W8FiLHZmj)ff228aNpk27cWdGGOt3waK6tlKr2Oyk0v2lKSmES9giuccfxbJN7Ye(OjjgicQ8Adpq6AVSyVbcLGqXvGIrHIPlhblWWh9zsIbIGkV2q1aF380PNwgBVbIGkV2acQ2xKUKe7J(ZzW45UmHpAsIJ3ZLzuOy6spTs9zss0Fodgp3LjCuS3foDrTf7J(Zz4Ceub)488OYMqk8r5uCZ2WchIG(oQiaQiX5yiSqwpfzC0FodKr2Oykl)LFHpAsYyZRFajSiaWYrMx)as5TJjak6NjjMx)asyrSZtloA28sMhCkUzByHdrqFhvea96YzogclK1trgh9NZazKnkMYYF5x4JMKm286hqclcaSCK51pGuE7ycGI(zsI51pGewe780IJMnVK5bNIB2gw4qe03rfbqZVuMJHWcz9uKXr)5mqgzJIPS8x(f(OjjJnV(bKWIaalhzE9diL3oMaOOFMKyE9diHfXopT4OzZlzEWPmswbCGIcRWIvdiRr)Lv0dAWSkULswHLejwJiw)ycK1UWniXQD)l)yvumYgftCkUzByHdrqFhveaj2VRHxgoZK8xeNYiz1AWeRdRFZ(iwxiROh0W6au6hRIIr2OyIv4XQ4xQyTlwT7F5hRIIr2OyItXnBdlCic67OIai863Spcz9ueYiBumf6kl)LFjjKr2OykGHs)YfzJnjHmYgftbVqkxKn2KKO)Cge731WldNzs(lk8rTe9NZazKnkMYYF5x4JMKmo6pNbJN7Yeok27cdq3SnScIpFFdKniZFP82XKLO)CgmEUlt4J(KtXnBdlCic67OIaiXNVVCkUzByHdrqFhveaD)k7MTHvw24fzLhtImDPCFVpNcNYizDy9d)pGeRt4XAmebft1Y6VKegZ6h3fqwtde5ToNIB2gw4W0LY99(IGx)W)diHSEkI93VOj8asHix6LHYWz2LY8(2fqCGgXFJIsGCkJKvR64L19LyfeUSkU3xw3xI1yiEzD7yI1fYQdcY6V2wY6(sSg72GvW)5BdlwBmRV9gyD4xZ(iwpk27cZA8xUnQSjqwxiRX(AEzngcRzFeRG)Z3gwCkUzByHdtxk337pQiac)RzFeYmizKuE9diTyrSfz9ueq4gIHWA2hfok27cN(rXExyapaaaG1wrnNIB2gw4W0LY99(JkcGIHWA2hXPWPmswTQlnFPVeMvXV0(shRdRF4)bKyTiceZ6cznIy9JjqwxiRpicL1pkR7lXQD9ipoQlq6yn6pNScpwxiRG)yuwJOj8iwnWcb8bXP4MTHfoGxrWRF4)bKqwpf5(fnHhqkSDmjgEvg8ipoQlq6c0i(Buuc0YyYiBumf6k7fswSF84O)Cg2oMedVkdEKhh1fiDHJI9UWPd0agIDBmAQbBTmMmYgftHUYrW9njHmYgftHUYyO0VKeYiBumfK)YVCr2yFMKe9NZW2XKy4vzWJ84OUaPlCuS3foD3SnSc41VzFuGSbz(lL3oMgn1GTwgtgzJIPqxz5V8ljHmYgftbmu6xUiBSjjKr2Oyk4fs5ISX(8zsI9r)5mSDmjgEvg8ipoQlq6cF0NjjJJ(ZzW45UmHpAscc)ApssbdSqaFqzqcJuzEAXaHsqO4kyGfc4dkVVugJ2xV4Wroisp5ugjRwdMyf5bD0TrqSoi2Vywf)sfR7lDeRnM1cYQB2gbXkwSFXiJvhZQ0xIvhZkkeJ7ijXkSyfl2Vywf37lRaGv4X6KethR41npWScpwHfRoR2zuwXI9lMvmK191xw3xI1IeZkwSFXS631iimR2S)4LvFU0X6(6lRyX(fZkzd0(imNIB2gw4aEhvea5Go62iOmwSFXiZGKrs51pG0IfXwK1trSheUbh0r3gbLXI9lod6XoqkST5rxaTyVB2gwbh0r3gbLXI9lod6Xoqk0vEkBGVRLX2dc3Gd6OBJGYyX(fNFjxg228OlGjjGWn4Go62iOmwSFX5xYLHJI9UWPl6NjjGWn4Go62iOmwSFXzqp2bsb86Mha0owaHBWbD0TrqzSy)IZGESdKchf7DHbODSac3Gd6OBJGYyX(fNb9yhif228OlGCkJKvRbtywTkSqaFqS2twnoRnM1pkRWJvKGFw9JyfKWivMUaYQvrEaL2LHvX9(YQvHfc4dIvVazfj4Nv)iwJijumRwBQS6yuof3SnSWb8oQiaYaleWhuEFPmgTVEXiRNImgHFThjPGbwiGpOmiHrQmwS3aHsqO4ky8CxMWroisjjr)5my8CxMWh9PfhVNlZOqX0bqRnvlJJ(ZzGmYgftz5V8lCuS3foDBtnjj6pNbYiBumLXqPFHJI9UWPBBQptsMnW3nFuS3fgG2MkNYizDeGMhHFzfeUyw)LKWywTkYdO0UmS(6ywLegZ6(6fRIMvmzWSEuS3vxargR7lXkcQ2xKowJ(ZjRWJ19Ly9bsx7fRr)5K1gZQhb)lRlK1PlLScNtw9cKvVqIvrXiBumXAJz1JG)L1fYkzd0(iof3SnSWb8oQiacHFThjjKvEmjciCZhnI)(OyQwmYq4YpjY4O)CgmEUlt4OyVlC6I2Y4O)CgohbvWpoppQSjKchf7DHtx0jj2h9NZW5iOc(X55rLnHu4J(mjX(O)CgmEUlt4JMK449CzgfkMoaANuFAzS9r)5m8OlWJaZumkumDXuTzQOdyBtu4JMK449CzgfkMoaANuFAzC0FodKr2OykJHs)chf7DHthObme72ijj6pNbYiBumLL)YVWrXEx40bAadXUnEYP4MTHfoG3rfbqXqyn7JqMbjJKYRFaPflITiRNIC08i8RhjjlRFaPnSDmLxygSP0Tfawg7OzZlzEybHFThjPaiCZhnI)(OyQw8tof3SnSWb8oQiac)RzFeYmizKuE9diTyrSfz9uKJMhHF9ijzz9diTHTJP8cZGnLUTaWYyhnBEjZdli8R9ijfaHB(Or83hft1IFYP4MTHfoG3rfbq4LKs)YtPFeYmizKuE9diTyrSfz9uKJMhHF9ijzz9diTHTJP8cZGnLUTaglJD0S5LmpSGWV2JKuaeU5JgXFFumvl(jNYiz1AWeR2mqRWkSy1aYQ4EFH)LvJJI2fqof3SnSWb8oQiaAcpdLHZC57)iK1trC0S5Lmp4ugjRwdMyDFjwhbHQ9fPJvpQL9IeRWIvdiRIFBZlRnM1iAcpIvRI8akTldNIB2gw4aEhveaDocQGFCEEuztiHSEks0Fodgp3Lj8r5ugjRwdMy1M1UapcK1b0(6fZQ4EFzDak9JvrXiBumXQxGSoc)sSFS(ljHXSkH4UaYQZ6htCkUzByHd4DuraefJcftxocwGiRNImEC0FodKr2OykJHs)chf7DHt32utsI(ZzGmYgftz5V8lCuS3foDBt9PfdekbHIRGXZDzchf7DHt3oPAzC0FodOxhdpW2Lz)mE1Mm6xI9lGWLFcGaWAtnjX(7x0eEaPa61XWdSDz2pJxTjJ(Ly)c0i(Buuc85ZKKO)CgqVogEGTlZ(z8Qnz0Ve7xaHl)u6IaarvQjjgiuccfxbJN7YeoYbrYYyhVNlZOqX0LEALAscc)ApssHgNDi9KtzKSAnyIvRI8akTldRI79LvRcleWheREbYkiSqULvic6eF9sSoc)sSFCkUzByHd4DuraKHKeEBxMDzdSIPArwpfXEW73GHcMnGyli8R9ijfmGzdSa7THLLXoEpxMrHIPl90kvlJJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWhnjXEdebvETHhiDTxptsmqeu51gQg47MNoLKGWV2JKuOXzhsjjr)5mejHqq5hVHpQLO)CgIKqiO8J3WrXExyacGuhD840cWF)IMWdifqVogEGTlZ(z8Qnz0Ve7xGgXFJIsGphDSbwG)EdOhzAmLDzdSIPAdBhtzeU8tpF(0I9r)5my8CxMWh1Yy7nqeu51gQg47MNoLKyGqjiuCfmWcb8bL3xkJr7RxC4JMK01shku6lbMNnW3nFuS3fgGgiuccfxbdSqaFq59LYy0(6fhok27cpkGjjPRLouO0xcmpBGVB(OyVlmGfWAROovacGuhDSbwG)EdOhzAmLDzdSIPAdBhtzeU8tpFYP4MTHfoG3rfbqDz8R8THfY6Pi2dE)gmuWSbeBbHFThjPGbmBGfyVnSSm2X75YmkumDPNwPAzC0Fodp6c8iWmfJcftxmvBMk6a22ef(Ojj2BGiOYRn8aPR96zsIbIGkV2q1aF380PKee(1EKKcno7qkjj6pNHijeck)4n8rTe9NZqKecbLF8gok27cdq7K6OJhNwa(7x0eEaPa61XWdSDz2pJxTjJ(Ly)c0i(Buuc85OJnWc83Ba9itJPSlBGvmvBy7ykJWLF65ZNwSp6pNbJN7Ye(OwgBVbIGkV2q1aF380PKedekbHIRGbwiGpO8(szmAF9IdF0KKUw6qHsFjW8Sb(U5JI9UWa0aHsqO4kyGfc4dkVVugJ2xV4WrXEx4rbmjjDT0HcL(sG5zd8DZhf7DHbSawBf1Pcq7K6OJnWc83Ba9itJPSlBGvmvBy7ykJWLF65toLrY6ii(1EKKy9JjqwHfREul7TjmR7RVSk2RL1fYAeXk2rqGSoHhRwf5buAxgwXqw3xFzDFjKy1pQwwf74Laz1M9hVSgrt4rSUVumNIB2gw4aEhveaHWV2JKeYkpMeb7iO8eEzJN7YGmeU8tIyVbcLGqXvW45UmHJCqKssShHFThjPGbwiGpOmiHrQmwmqeu51gQg47MNoLKaE)gmuWSbeZPmswTgmHz1MbkkS2tw7IvVyvumYgftS6fiR71eM1fYQSlI1Ez9JYQ4EFzDe(Ly)qgRwf5buAxgw9cKvKh0r3gbX6Gy)I5uCZ2WchW7OIaO5)qkdNzs(lcz9ueYiBumf6k7fswC0S5LmpSe9NZa61XWdSDz2pJxTjJ(Ly)ciC5NaiaS2uTmgeUbh0r3gbLXI9lod6XoqkST5rxatsS3arqLxBOiZbLWd8Pfe(1EKKcyhbLNWlB8CxgoLrYQ1GjwHfTVSoS(nDPKv0dAWS2twhw)MUuYAJlKBz9JYP4MTHfoG3rfbq41VPlLiRNIe9NZaSO9fNrPZqOBdRWh1s0Fod41VPlLHJMhHF9ijXP4MTHfoG3rfbqgVmKmh9NtKvEmjcE9tcpqK1trI(ZzaV(jHhy4OyVlmafTLXr)5mqgzJIPmgk9lCuS3foDrNKe9NZazKnkMYYF5x4OyVlC6I(PfhVNlZOqX0LEALkNIB2gw4aEhveaHx)MUuISEkY6sQ2aEjP0Vm41ZnqLhjjqlyA3UaIdyOeMbVEUwI(ZzaV(nDPmacfxCkJKv76pgfZQJrznIMWJy1QWcb8bX6h3fqw3xIvRcleWheRgyb2BdlwxiRMxY8G1EYQvHfc4dI1gZQB2VlLiXQhb)lRlK1iIvJJxof3SnSWb8oQiacV(H)hqcz9uedebvETHQb(U5Ptwq4x7rskyGfc4dkdsyKkJfdekbHIRGbwiGpO8(szmAF9Idhf7DHbOOTyp49BWqbZgqmNYiz1AWeRdRFtxkzvCVVSIxsk9JvWRNlREbYAbzDy9tcpqKXQ4xQyTGSoS(nDPK1gZ6hfzSIe8ZQFeRDXQD)l)yvumYgftiJv0dAyDe(Ly)yv8lvS6rqeeRPvQS6yuwHhRoiQVncIvSy)Iz91XSkQhftgmRhf7D1fqwHhRnM1UyDkBGVlNIB2gw4aEhveaHx)MUuISEkY6sQ2aEjP0Vm41ZnqLhjjql2VUKQnGx)KWdmqLhjjqlr)5mGx)MUugoAEe(1JKKLXr)5mqgzJIPS8x(fok27cNoGXczKnkMcDLL)Yplr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jacarNAss0FodOxhdpW2Lz)mE1Mm6xI9lGWLFkDraGOt1IJ3ZLzuOy6spTsnjbeUbh0r3gbLXI9lod6XoqkCuS3foDrDsIB2gwbh0r3gbLXI9lod6Xoqk0vEkBGV7tl2BGqjiuCfmEUlt4ihejoLrYQ1GjwXywHfTVSIEqdMvVazf8hJYQJrzv8lvSAvKhqPDzyfESUVeRiOAFr6yn6pNS2yw9i4FzDHSoDPKv4CYk8yfj4h5az14OS6yuof3SnSWb8oQiacV(H)hqcz9uKO)CgGfTV4Srs(Lr04gwHpAss0Fodp6c8iWmfJcftxmvBMk6a22ef(Ojjr)5my8CxMWh1Y4O)CgohbvWpoppQSjKchf7DHbiqdyi2TbG3qTCSJ3ZLzuOy6aS2j1NwI(Zz4Ceub)488OYMqk8rtsSp6pNHZrqf8JZZJkBcPWh1I9giuccfxHZrqf8JZZJkBcPWroisjj2BGiOYRnGGQ9fP7zsIJ3ZLzuOy6spTs1czKnkMcDL9cjoLrYQ1pKyDHSg7piw3xI1icVScNSoS(jHhiRriXkEDZJUaYAVS(rzDe)T5Hejw7I1bO0pwffJSrXeRr)L1r4xI9J1gxlREe8VSUqwJiwrpOXqGCkUzByHd4DuraeE9d)pGeY6PiRlPAd41pj8adu5rsc0I93VOj8asHTJjXWRYGh5XrDbsxGgXFJIsGwgh9NZaE9tcpWWhnjXX75YmkumDPNwP(0s0Fod41pj8ad41npaODSmo6pNbYiBumLXqPFHpAss0FodKr2Oykl)LFHp6tlr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jacarvQwgBGqjiuCfmEUlt4OyVlC62MAsI9i8R9ijfmWcb8bLbjmsLXIbIGkV2q1aF380PNCkJKvRbtSoS(H)hqI1UyDak9JvrXiBumHmwbHfYTSkPL1Ezf9GgwhHFj2pwhVV(YAJz91lqjbYAesSs9(shR7lX6W630LswLDrScpw3xIvhJMEALkRYUiwNWJ1H1p8)asprgRGWc5wwHiOt81lXQxSclAFzf9Ggw9cKvjTSUVeREeebXQSlI1xVaLeRdRFs4bYP4MTHfoG3rfbq41p8)asiRNIy)9lAcpGuy7ysm8Qm4rECuxG0fOr83OOeOLXr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jacarvQjjr)5mGEDm8aBxM9Z4vBYOFj2Vacx(jacarNQL1LuTb8ssPFzWRNBGkpssGpTe9NZazKnkMYyO0VWrXEx40fvwiJSrXuORmgk9ZI9r)5malAFXzu6me62Wk8rTy)6sQ2aE9tcpWavEKKaTyGqjiuCfmEUlt4OyVlC6IklJnqOeekUcp6c8iWmgTVEXHJI9UWPlQssS3arqLxB4bsx71toLrYQ1GjwJHWcZk4)6ciR29V8JvrXiBumXk8yfj4h5azfUV0jUXeRqe0zCuwnV(bKWCkUzByHd4DuraurIZXqyHSEkY4O)CgiJSrXuw(l)cF0KKXMx)asyraGLJmV(bKYBhtau0ptsmV(bKWIyNNwC0S5LmpSGWV2JKua7iO8eEzJN7YWP4MTHfoG3rfbqVUCMJHWcz9uKXr)5mqgzJIPS8x(f(OwS3arqLxB4bsx7vsY4O)CgE0f4rGzkgfkMUyQ2mv0bSTjk8rTyGiOYRn8aPR96zsYyZRFajSiaWYrMx)as5TJjak6NjjMx)asyrStss0Fodgp3Lj8rFAXrZMxY8Wcc)ApssbSJGYt4LnEUldNIB2gw4aEhvean)szogclK1trgh9NZazKnkMYYF5x4JAXEdebvETHhiDTxjjJJ(Zz4rxGhbMPyuOy6IPAZurhW2MOWh1IbIGkV2WdKU2RNjjJnV(bKWIaalhzE9diL3oMaOOFMKyE9diHfXojjr)5my8CxMWh9PfhnBEjZdli8R9ijfWockpHx245UmCkJKvRbtSc4affwHfRgqof3SnSWb8oQiasSFxdVmCMj5VioLrYQ1Gjwhw)M9rSUqwrpOH1bO0pwffJSrXeYy1QipGs7YW6RJzvsymRBhtSUVEXQZkGZ57lRKniZFjwL0CzfEScljsSA3)YpwffJSrXeRnM1pkNIB2gw4aEhveaHx)M9riRNIqgzJIPqxz5V8ljHmYgftbmu6xUiBSjjKr2Oyk4fs5ISXMKe9NZGy)UgEz4mtYFrHpQLO)CgiJSrXuw(l)cF0KKXr)5my8CxMWrXExya6MTHvq857BGSbz(lL3oMSe9NZGXZDzcF0NCkJKvRbtSc4C((YkCFPtCJjwf)2MxwBmRDX6au6hRIIr2OyczSAvKhqPDzyfESUqwrpOHv7(x(XQOyKnkM4uCZ2WchW7OIaiXNVVCkJKvBgxk337ZP4MTHfoG3rfbq3VYUzByLLnErw5XKitxk337lmGrjJGvSnvaiScRGaa]] )


end