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


    spec:RegisterPack( "Balance", 20210123, [[daL5ceqiHOhjsXLGq0MOeFsKsnkvjNsk1QGqYRKsAwaKBriP2LGFPkvdtK0XesTmaQNjeAAusY1iKABsjQVrijJtijoNuISoiempvPCpcX(eP6GqOAHcjEiLuMOqs5IqOSriKQpcHu0jfPKvks8sHKentPe6MqiLyNus8tHKegQqs1sfss9uPyQus1vjKyRqiL6Rqi0yHqkCwiKsAVe8xrnyshMQftPEmftgOlJSzP6ZaA0QItRy1cjj9AamBIUTqTBj)g0WH0XLsWYv65qnDvUUQA7q03juJxi48qW6PKuZxe7h1crlyDHgq)ibRa4ubC0PgnGJyiArfGtfWIkHMdbusOb1na4ajHMYJjHMO4sVmKqdQJGe6GcwxObd)RHeAEUdfJi8(7aN75BhmW43Xt8x63alZ697D8eBExOX(pYlTkbBHgq)ibRa4ubC0PgnGJyiArv0r0QSkHg)FpWvOPzITMqZZacsLGTqdiHncnPjnSgfx6LHynQT)bKtjnPH1u867lcSc4iciwbCQaoAofoL0KgwT2JxajmIaNsAsdRIAwrCqqcK1gO0xwJc5XboL0Kgwf1SAThVasGSE(cKU80z14ycZ6bz1GGrs5ZxG0HdCkPjnSkQznQMIHijqw)vrgcJ9fbwr6742scZ6RjqbaXk6siZ4Zx8FbsSkQtNv0LqgWNV4)cKAh4ustAyvuZkIJeoGSIUKXX3uazfrC97H1PZ6CPnM17Hyv8clGSIyg5GIPaNsAsdRIAwr0IdaXQ1GfsiaeR3dXAd6SZHz1zvo3jjwJHlXAxsrySLeRVMoRia)S(4GvAFS(mhRZXkEI)YZlc(Xseyv8CpSgLOkqCRZARSAnss4BCjRiUCawXuDaI15sBqwXamOTdcnYbFybRl0asD)lpbRlyLOfSUqJBUbwcnyO03Sn5Xcnu52scuikcNGvaSG1fAOYTLeOqueAGOcny6eACZnWsObPVJBljHgKU8tcnyuskZNVaPdhWNVDxkznDwJMvlS(I1iz9CjvxaF(kHlyGk3wsGSMKW65sQUa(iP03m4o9lqLBljqwBZAscRyuskZNVaPdhWNVDxkznDwbSqdiHn7GEdSeAAOdZkIdrmwHfRrSvwfp3d8FScUt)y1lqwfp3dRnNVs4cYQxGSc4wzfEp0kEWKqdsFZLhtcndo7qs4eSsefSUqdvUTKafIIqdevObtNqJBUbwcni9DCBjj0G0LFsObJssz(8fiD4a(8TplXA6SgTqdiHn7GEdSeAAOdZQrsosIvXpuXAZ5BFwIvJxS(mhRaUvwpFbshMvXpJ5H1bZ6sscPxhRD4Y69qSIyg5GIjwpiR2eROl1PDjqHgK(MlpMeAgC2ijhjjCcwXQeSUqdvUTKafIIqdiHn7GEdSeAefmXQnTyAbykGSkEUhwnoRWLvVF0YQ1GfsiaeRtXQXfAm7C0oUqZlwJKvdejvEDHAa(C5UtSMKWAKSAGqjiuCfmWcjeakFpugJo7C4WhL12SAHv7FVhmEEkt4Jk04MBGLqJnTyAbykGcNGveTG1fAOYTLeOqueAajSzh0BGLqtuhESkEUhwnoR3JFSo4kTpwDwJ6Fj2xwrxOrOXn3alHgu4nWsOXSZr74cn2)Epy88uMWsX(uywtN1Otv4eSsllyDHgQCBjbkefHgiQqdMoHg3CdSeAq6742ssObPl)KqJHgjRVy9fRtD0IcL(rG5(a85Ylf7tHzvuZA0IMvrnRgiuccfxbJNNYewk2NcZABwFN1OJkPYABwfHvdnswFX6lwN6Offk9JaZ9b4ZLxk2NcZQOM1OfnRIAwJgWPYQOMvdekbHIRGbwiHaq57HYy0zNdhwk2NcZABwFN1OJkPYABwtsy1aHsqO4ky88uMWsX(uywtN1PoArHs)iWCFa(C5LI9PWSMKWQbcLGqXvWalKqaO89qzm6SZHdlf7tHznDwN6Offk9JaZ9b4ZLxk2NcZQOM1OtL1KewJKvdejvEDHAa(C5UtcnGe2Sd6nWsOXAU08L(rywf)q3dTS(XtbKvRblKqaiwlOywfpsjRUucfZkcWpRhKv8nsjRghFSEpeRypMy1JH)6yf2z1AWcjeaQvRH4VNwLHvJJpSqdsFZLhtcngyHecaLbjmcLr4eSIOsW6cnu52scuikcnquHgmDcnU5gyj0G03XTLKqdsx(jHMxSgjRul8huucmqXOiSKlZWfS8YqSMKWQbcLGqXvGIrryjxMHly5LHclf7tHz9nwJULtLvlSgjRgiuccfxbkgfHLCzgUGLxgkSKdIaRTznjHvdejvEDbaqyhVeAajSzh0BGLqJOGjqwpiRGK0rG17Hy9JDGeRWoRwdXFpTkdRIFOI1pEkGScc)2sIvyX6htcni9nxEmj0yaZgybo3alHtWkrfbRl0qLBljqHOi0asyZoO3alHgrbtSIyXOiSKlznQIfS8YqSc4uXKbZQn1HlXQZQ1q83tRYW6htbHMYJjHgkgfHLCzgUGLxgsOXSZr74cngiuccfxbJNNYewk2NcZ6BSc4uz1cRgiuccfxbdSqcbGY3dLXOZohoSuSpfM13yfWPYAscR9b4ZLxk2NcZ6BSgrrLqJBUbwcnumkcl5YmCblVmKWjyLwsW6cnu52scuikcnGe2Sd6nWsOruWeRnWVus3uaznQ(BJaRTmMmywTPoCjwDwTgI)EAvgw)yki0uEmj0GHFPKUBkG59BJGqJzNJ2XfAmqOeekUcgppLjSuSpfM13yTLz1cRrYksFh3wsbdSqcbGYGegHYWAscRgiuccfxbdSqcbGY3dLXOZohoSuSpfM13yTLz1cRi9DCBjfmWcjeakdsyekdRjjS2hGpxEPyFkmRVXkGfTqJBUbwcny4xkP7McyE)2iiCcwj6ufSUqdvUTKafIIqJzNJ2XfAS)9EW45PmHpQqt5XKqZuyZ(p3ws5w4719JZGeYXqcnU5gyj0mf2S)ZTLuUf(ED)4miHCmKWjyLOJwW6cnu52scuikcnGe2Sd6nWsOruWeMvxkzfEp0YkSy9JjwNJIXSclwnGcnMDoAhxOX(37bJNNYe(OSMKWQbIKkVUqnaFUC3jwTWksFh3wsbdSqcbGYGegHYWQfwnqOeekUcgyHecaLVhkJrNDoC4JYQfwJKvdekbHIRGXZtzcFuwTW6lwFXQ9V3dKroOykl)LVHLI9PWSMoRrNkRjjSA)79azKdkMYyO03WsX(uywtN1OtL12SAH1izD)f1Hlqky7sVmug2ZUuMVNPaIdu52scK1Kew3FrD4cKc2U0ldLH9SlL57zkG4avUTKaz1cRVy1(37bBx6LHYWE2LY89mfqCU87VuaFUbawtN1iYAscR2)Epy7sVmug2ZUuMVNPaIZ(A8Ic4ZnaWA6SgrwBZABwtsy1(37baMcCjWmfJcftBmvxMkAbownf(OSMKWAFa(C5LI9PWS(gRaovHg3CdSeA(ykphfJfobRenGfSUqdvUTKafIIqdiHn7GEdSeAIAKzajwDZnWIv5GpwTDmbYkSyfp33VbwVljGdwOXn3alHM9xz3CdSYYbFcn4BhZjyLOfAm7C0oUqdsFh3wsHbNDij0ih8LlpMeACijCcwj6ikyDHgQCBjbkefHgZohTJl0S)I6WfifSDPxgkd7zxkZ3ZuaXbQf(dkkbk0GVDmNGvIwOXn3alHM9xz3CdSYYbFcnYbF5YJjHgBOFcNGvI2QeSUqdvUTKafIIqJBUbwcn7VYU5gyLLd(eAKd(YLhtcn4t4eoHgBOFcwxWkrlyDHgQCBjbkefHgqcB2b9gyj0GOVuz1iWQ45Ey1Ai(7PvzeAm7C0oUqJ9V3dgppLj8rfACZnWsOzDKub)4CFPYQrq4eScGfSUqdvUTKafIIqdevObtNqJBUbwcni9DCBjj0G0LFsOjswT)9EW2LEzOmSNDPmFptbeNl)(lf(OSAH1iz1(37bBx6LHYWE2LY89mfqC2xJxu4Jk0asyZoO3alHgR9qgaWSoDwVhIvZohR2)EN1bZAbpw)OS2HlRs)OL1pMeAq6BU8ysOXSZvW7JkCcwjIcwxOHk3wsGcrrOXn3alHgh0rVbjLXI9nwOXSZr74cn2)Epy7sVmug2ZUuMVNPaIZLF)Lc4ZnaW6BSAvSAHv7FVhSDPxgkd7zxkZ3ZuaXzFnErb85gay9nwTkwTW6lwJKvq4fCqh9gKugl234mOh7aPWngaMciRwynswDZnWk4Go6niPmwSVXzqp2bsHPYD5a85y1cRVynswbHxWbD0BqszSyFJZpKld3yaykGSMKWki8coOJEdskJf7BC(HCzyPyFkmRPZAezTnRjjSccVGd6O3GKYyX(gNb9yhifWNBaG13ynISAHvq4fCqh9gKugl234mOh7aPWsX(uywFJvrZQfwbHxWbD0BqszSyFJZGESdKc3yaykGS2wOXGGrs5ZxG0HfSs0cNGvSkbRl0qLBljqHOi0asyZoO3alHgrbtSAnyHecaXkiHsf4uazfwSIrOmS(rzv8CpSAne)90QmSclwnGScxwTrGvX(CtbK1dcKUhAzv8CpS6SA25y1(37cnMDoAhxO5fRi9DCBjfmWcjeakdsyekdRwynswnqOeekUcgppLjSKdIaRjjSA)79GXZtzcFuwBZQfwFXQ9V3d2U0ldLH9SlL57zkG4C53FPa(CdaSkcRIM1KewT)9EW2LEzOmSNDPmFptbeN914ffWNBaGvryv0S2M1Kew7dWNlVuSpfM13yn6ufACZnWsOXalKqaO89qzm6SZHfobRiAbRl0qLBljqHOi04MBGLqJXldjZ2)ExOXSZr74cnVy1(37bBx6LHYWE2LY89mfqCU87VuyPyFkmRPZQvfenRjjSA)79GTl9Yqzyp7sz(EMcio7RXlkSuSpfM10z1QcIM12SAHvhFRlZOqX0YA6IWAlLkRwy9fRgiuccfxbJNNYewk2NcZA6SkQynjH1xSAGqjiuCfOyuOyAZ2WcmSuSpfM10zvuXQfwJKv7FVhaykWLaZumkumTXuDzQOf4y1u4JYQfwnqKu51faaHD8I12S2wOX(375YJjHg85ReUGcnGe2Sd6nWsOXAEzijRnNVs4cYQ45EyvsymR3JxS2YSIjdM1LI9PMciREbYQBd)hRhKvWFmkRnNV4)cKWcNGvAzbRl0qLBljqHOi0y25ODCHMZLuDb8rsPVzWD6xGk3wsGSAHvmD3uaXbmucZG70pwTWQ9V3d4Z3UlLbqO4sOXn3alHg85B3LsHtWkIkbRl0qLBljqHOi0asyZoO3alHMO2pgL1MZx8Fbsywfp3dR3dXQzNJv7FVZQxGSAtD4sS(XtbKvRblKqaiHgZohTJl0ejRi9DCBjfm7Cf8(OSAH1xSAGiPYRludWNl3DI1KewnqOeekUcgppLjSuSpfM10zvuXAscRrYksFh3wsbdy2alW5gyXQfwJKvdejvEDbaqyhVynjH1xSAGqjiuCfOyuOyAZ2WcmSuSpfM10zvuXQfwJKv7FVhaykWLaZumkumTXuDzQOf4y1u4JYQfwnqKu51faaHD8I12S2wOXn3alHg85l(VajHtWkrfbRl0qLBljqHOi0asyZoO3alHMO2pgL1MZx8FbsywTPoCjwTgSqcbGeAm7C0oUqZlwnqOeekUcgyHecaLVhkJrNDoCyPyFkmRVXQOz1cRrYk4(hWqbZgqmRwy9fRi9DCBjfmWcjeakdsyekdRjjSAGqjiuCfmEEktyPyFkmRVXQOzTnRwyfPVJBlPGbmBGf4CdSyTnRwy1X36YmkumTSMoRwvQSAHvdejvEDHAa(C5UtSAH1izfC)dyOGzdiwOXn3alHg85l(VajHtWkTKG1fAOYTLeOqueAGOcny6eACZnWsObPVJBljHgKU8tcnVy1(37bJNNYewk2NcZA6SkAwTW6lwT)9EyDKub)4CFPYQriSuSpfM10zv0SMKWAKSA)79W6iPc(X5(sLvJq4JYABwtsynswT)9EW45PmHpkRTz1cRVynswT)9EaGPaxcmtXOqX0gt1LPIwGJvtHpkRTz1cRVy1(37bYihumLXqPVHLI9PWSMoRanGHypcSMKWQ9V3dKroOykl)LVHLI9PWSMoRanGHypcS2wObKWMDqVbwcnrnyL2hRGWJvW)ofqwVhIvQazf2z1Ai(7PvzaeRG)DkGScWuGlbYkfJcftBmvhRWL1Py9EiwLo(yfObKvyNvVyfXmYbftcni9nxEmj0acV8sTWFwkMQdlCcwj6ufSUqdvUTKafIIqJBUbwcn4F1NLeAm7C0oUqZs9LWpUTKy1cRNVaPlCtmLpygCiwtN1OBzwTWQJMnpKbawTWksFh3wsbq4LxQf(ZsXuDyHgdcgjLpFbshwWkrlCcwj6OfSUqdvUTKafIIqJBUbwcnXqy1NLeAm7C0oUqZs9LWpUTKy1cRNVaPlCtmLpygCiwtN1OJyq0SAHvhnBEidaSAHvK(oUTKcGWlVul8NLIP6WcngemskF(cKoSGvIw4eSs0awW6cnu52scuikcnU5gyj0Gpsk9n3L(scnMDoAhxOzP(s4h3wsSAH1ZxG0fUjMYhmdoeRPZA0TmRTY6sX(uywTWQJMnpKbawTWksFh3wsbq4LxQf(ZsXuDyHgdcgjLpFbshwWkrlCcwj6ikyDHgQCBjbkefHgqcB2b9gyj0GOdTcRW)HhqI17Hy1SZXQ9V3zfUSk(Hkwra(zfewP9X6JJKyLk4h4dRogL1dYk(VajHgZohTJl04OzZdzaqOXn3alHMoCnug2ZLF)LeobReTvjyDHgQCBjbkefHgqcB2b9gyj0GOdrmwTPoCjwDwn7CSkEkqOywHlRtHhqIvVyfXmYbftcnMDoAhxO5fRKroOykmv2leynjHvYihumfWqPV5PYrZAscRKroOyki)LV5PYrZABwTW6lwJKvdejvEDHAa(C5UtSMKWk4(hWqbZgqmRjjS(IvhFRlZOqX0Y6BS2sIMvlS(IvK(oUTKcMDUcEFuwtsy1X36YmkumTS(gRrmvwtsyfPVJBlPWGZoKyTnRwy9fRi9DCBjfmWcjeakdsyekdRwynswnqOeekUcgyHecaLVhkJrNDoC4JYAscRrYksFh3wsbdSqcbGYGegHYWQfwJKvdekbHIRGXZtzcFuwBZABwBZQfwFXQbcLGqXvW45PmHLI9PWSMoRrmvwtsyfC)dyOGzdiM1KewD8TUmJcftlRPZAlLkRwy1aHsqO4ky88uMWhLvlS(IvdekbHIRafJcftB2gwGHLI9PWS(gRU5gyfWNV9zPafbY8pkFtmXAscRrYQbIKkVUaaiSJxS2M1KewN6Offk9JaZ9b4ZLxk2NcZ6BSgDQS2MvlS(Ivq4fCqh9gKugl234mOh7aPWsX(uywtNvRI1KewJKvdejvEDHImlucxqwBl04MBGLqt)ViKH9mj)fjCcwjArlyDHgQCBjbkefHgqcB2b9gyj0GyXOqX0YQnSazv8dvSc)hEajw9IveZihumXkCz1Ai(7PvzyDWS62W)Xk8y1My9JjWaRnosI1oCz1Ai(7PvzeAm7C0oUqZlwjJCqXuq(lFZffHJ1KewjJCqXuadL(MlkchRjjSsg5GIPGxiKlkchRjjSA)79GTl9Yqzyp7sz(EMciox(9xkSuSpfM10z1QcIM1KewT)9EW2LEzOmSNDPmFptbeN914ffwk2NcZA6SAvbrZAscRo(wxMrHIPL10zTLsLvlSAGqjiuCfmEEktyjhebwTWAKScU)bmuWSbeZABwTW6lwnqOeekUcgppLjSuSpfM10znIPYAscRgiuccfxbJNNYewYbrG12SMKW6uhTOqPFeyUpaFU8sX(uywFJ1OtvOXn3alHgkgfkM2SnSafobReDllyDHgQCBjbkefHgqcB2b9gyj0yne)90QmSk(Hkw9J1wk1wz1XOSkEUh4)yvcXtbK1BIjwNI1OiHqq5hFScxwJQ(XhRWIvdekbHIlwf)qfRf8yvo1uaz9JYQ45Ey1AWcjeasOXSZr74cnrYk4(hWqbZgqmRwyfPVJBlPGbmBGf4CdSy1cRVy9fRo(wxMrHIPL10zTLsLvlS(Iv7FVhaykWLaZumkumTXuDzQOf4y1u4JYAscRrYQbIKkVUaaiSJxS2M1KewT)9EWwcHGYp(cFuwTWQ9V3d2sieu(XxyPyFkmRVXkGtL1wz9fRgyb(NlGUKzWu2LdWkMQlCtmLr6YpXABwBZAscRtD0IcL(rG5(a85Ylf7tHz9nwbCQS2kRVy1alW)Cb0LmdMYUCawXuDHBIPmsx(jwBZAscRgisQ86c1a85YDNyTnRwy9fRrYQbIKkVUqnaFUC3jwtsyfPVJBlPGbwiHaqzqcJqzynjHvdekbHIRGbwiHaq57HYy0zNdhwYbrG12cnU5gyj0yijHVXLzxoaRyQoHtWkrlQeSUqdvUTKafIIqJzNJ2XfAIKvW9pGHcMnGywTWksFh3wsbdy2alW5gyXQfwFX6lwD8TUmJcftlRPZAlLkRwy9fR2)EpaWuGlbMPyuOyAJP6YurlWXQPWhL1KewJKvdejvEDbaqyhVyTnRjjSA)79GTecbLF8f(OSAHv7FVhSLqiO8JVWsX(uywFJ1iMkRTY6lwnWc8pxaDjZGPSlhGvmvx4MykJ0LFI12S2M1KewN6Offk9JaZ9b4ZLxk2NcZ6BSgXuzTvwFXQbwG)5cOlzgmLD5aSIP6c3etzKU8tS2M1KewnqKu51fQb4ZL7oXABwTW6lwJKvdejvEDHAa(C5UtSMKWksFh3wsbdSqcbGYGegHYWAscRgiuccfxbdSqcbGY3dLXOZohoSKdIaRTfACZnWsOzkJVLFdSeobReDurW6cnu52scuikcnquHgmDcnU5gyj0G03XTLKqdsx(jHgYihumfMkl)LVSIOynQW67S6MBGvaF(2NLcueiZ)O8nXeRTYAKSsg5GIPWuz5V8LvefRTmRVZQBUbwbXRFpbkcK5Fu(MyI1wzn1aGz9DwXOKuMFC8rcnGe2Sd6nWsOjQ9JrzT58f)xGeMvXpuX69qS2hGphRdMv3g(pwpiRubciw7lvwncSoywDB4)y9GSsfiGyfb4NvFjw9J1wk1wz1XOSofREXkIzKdkMyfUSAne)90QmSkD8Hz1l49qlRrLwXKbl0G03C5XKqJJrJ602qgHtWkr3scwxOHk3wsGcrrOXSZr74cnVyDQJwuO0pcm3hGpxEPyFkmRVXQvXAscRVy1(37H1rsf8JZ9LkRgHWsX(uywFJvGgWqShbwruSAOrY6lwD8TUmJcftlRVZAetL12SAHv7FVhwhjvWpo3xQSAecFuwBZABwtsy9fRo(wxMrHIPL1wzfPVJBlPGJrJ602qgwruSA)79azKdkMYyO03WsX(uywBLvq4f6)fHmSNj5VOWngaW5LI9PyfrXkGdIM10znAaNkRjjS64BDzgfkMwwBLvK(oUTKcognQtBdzyfrXQ9V3dKroOykl)LVHLI9PWS2kRGWl0)lczyptYFrHBmaGZlf7tXkIIvahenRPZA0aovwBZQfwjJCqXuyQSxiWQfwFX6lwJKvdekbHIRGXZtzcFuwtsy1arsLxxaae2XlwTWAKSAGqjiuCfOyuOyAZ2Wcm8rzTnRjjSAGiPYRludWNl3DI12SAH1xSgjRgisQ86ciP6EqyznjH1iz1(37bJNNYe(OSMKWQJV1LzuOyAznDwBPuzTnRjjSA)79GXZtzclf7tHznDwJkSAH1iz1(37H1rsf8JZ9LkRgHWhvOXn3alHg85l(VajHtWkaovbRl0qLBljqHOi0y25ODCHMxSA)79azKdkMYYF5B4JYAscRVy184lqcZQiScywTW6sMhFbs5BIjwFJvrZABwtsy184lqcZQiSgrwBZQfwD0S5Hmai04MBGLqtrIZXqyjCcwbWrlyDHgQCBjbkefHgZohTJl08Iv7FVhiJCqXuw(lFdFuwtsy9fRMhFbsywfHvaZQfwxY84lqkFtmX6BSkAwBZAscRMhFbsywfH1iYABwTWQJMnpKbaHg3CdSeAECzphdHLWjyfadybRl0qLBljqHOi0y25ODCHMxSA)79azKdkMYYF5B4JYAscRVy184lqcZQiScywTW6sMhFbs5BIjwFJvrZABwtsy184lqcZQiSgrwBZQfwD0S5Hmai04MBGLqt)lL5yiSeobRa4ikyDHgQCBjbkefHgqcB2b9gyj0GicrmwHfRgqwT)hROl0Gzv8iLScljcSAtS(XeiRtHhqI1w8x(YkIzKdkMeACZnWsOrSV7a3mSNj5ViHtWka2QeSUqdvUTKafIIqdiHn7GEdSeAefmXAZ5BFwI1dYk6cnS2aL(YkIzKdkMyfUSk(HkwNI1w8x(YkIzKdkMeAm7C0oUqdzKdkMctLL)YxwtsyLmYbftbmu6BUOiCSMKWkzKdkMcEHqUOiCSMKWQ9V3dI9Dh4MH9mj)ff(OSAHv7FVhiJCqXuw(lFdFuwtsy9fR2)Epy88uMWsX(uywFJv3CdScIx)EcueiZ)O8nXeRwy1(37bJNNYe(OS2wOXn3alHg85BFws4eScGfTG1fACZnWsOr863JqdvUTKafIIWjyfa3YcwxOHk3wsGcrrOXn3alHM9xz3CdSYYbFcnYbF5YJjHMUlL3Z(foHtOXHKG1fSs0cwxOHk3wsGcrrObIk0GPtOXn3alHgK(oUTKeAq6Ypj08Iv7FVhUjMed3kdUKhBpfiTHLI9PWS(gRanGHypcS2kRPgIM1KewT)9E4MysmCRm4sES9uG0gwk2NcZ6BS6MBGvaF(2NLcueiZ)O8nXeRTYAQHOz1cRVyLmYbftHPYYF5lRjjSsg5GIPagk9nxueowtsyLmYbftbVqixueowBZABwTWQ9V3d3etIHBLbxYJTNcK2WhLvlSU)I6WfifUjMed3kdUKhBpfiTbQf(dkkbk0asyZoO3alHgR5sZx6hHzv8dDp0Y69qSg1wYJn(zEOLv7FVZQ4rkzT7sjRWENvXZ9mfR3dXArr4y144tObPV5YJjHgWL84S4rkZDxkZWEx4eScGfSUqdvUTKafIIqdevObtNqJBUbwcni9DCBjj0G0LFsOjswjJCqXuyQmgk9LvlS(IvmkjL5ZxG0Hd4Z3(SeRPZQOz1cRNlP6cy4xMH989q5oCj8fOYTLeiRjjSIrjPmF(cKoCaF(2NLynDwfvS2wObKWMDqVbwcnwZLMV0pcZQ4h6EOL1MZx8FbsSoywfd37HvJJVPaYkejTS2C(2NLyDkwBXF5lRiMroOysObPV5YJjHMbybxkJpFX)fijCcwjIcwxOHk3wsGcrrObKWMDqVbwcnIcMy1AWcjeaIvXpuXQFSkjmM17XlwfDQS64BDjROqX0YQxGSkNIy9JYQ45Ey1Ai(7Pvzyv8CpW)XQeINciRoRFmj0y25ODCHMxSI03XTLuWalKqaOmiHrOmSAH1iz1aHsqO4ky88uMWsoicSMKWQ9V3dgppLj8rzTnRwy9fRo(wxMrHIPL13yv0PYAscRi9DCBjfgGfCPm(8f)xGeRTz1cRVy1(37bYihumLL)Y3WsX(uywtN1wM1KewT)9EGmYbftzmu6ByPyFkmRPZAlZABwTW6lwJK19xuhUaPGTl9Yqzyp7sz(EMcioqLBljqwtsy1(37bBx6LHYWE2LY89mfqCU87VuaFUbawtN1iYAscR2)Epy7sVmug2ZUuMVNPaIZ(A8Ic4ZnaWA6SgrwBZAscR9b4ZLxk2NcZ6BSgDQcnU5gyj0yGfsiau(EOmgD25WcNGvSkbRl0qLBljqHOi04MBGLqd(x9zjHgdcgjLpFbshwWkrl0y25ODCHMxSUuFj8JBljwtsy1(37bYihumLXqPVHLI9PWS(gRrKvlSsg5GIPWuzmu6lRwyDPyFkmRVXA0wfRwy9Cjvxad)YmSNVhk3HlHVavUTKazTnRwy98fiDHBIP8bZGdXA6SgTvXQOMvmkjL5ZxG0HzTvwxk2NcZQfwFXkzKdkMctL9cbwtsyDPyFkmRVXkqdyi2JaRTfAajSzh0BGLqJOGjwX)QplX6uSI6fifpgwf)qfR(XA0wfMmywxk2NAkGScxwLegZQ45EyngUeRNVaPdZQxGSoDwNJvXWVeK1UlLSc7DwTPoCjwP6ODkGSEpeRffHJveZihumjCcwr0cwxOHk3wsGcrrObKWMDqVbwcnrvsekRFuwBoF7UuYQFS6sjR3etyw)LKWyw)4PaYAlIGXxhZQxGSohRdMv3g(pwpiROl0WkCzvshR3dXkgLmJlz1n3alwLtrSAtsOywF8cusSg1wYJTNcKwwHfRaM1ZxG0HfAm7C0oUqZlwT)9EaF(2DPmSuFj8JBljwTW6lwXOKuMpFbshoGpF7UuY6BSgrwtsynsw3FrD4cKc3etIHBLbxYJTNcK2a1c)bfLazTnRjjSEUKQlGHFzg2Z3dL7WLWxGk3wsGSAHv7FVhiJCqXugdL(gwk2NcZ6BSgrwTWkzKdkMctLXqPVSAHv7FVhWNVDxkdlf7tHz9nwfvSAHvmkjL5ZxG0Hd4Z3UlLSMUiSAvS2MvlS(I1izD)f1HlqkirW4RJZDjr3uaZaLtmkMcul8huucK1KewVjMyfrYQvjAwtNv7FVhWNVDxkdlf7tHzTvwbmRTz1cRNVaPlCtmLpygCiwtNvrl04MBGLqd(8T7sPWjyLwwW6cnu52scuikcnGe2Sd6nWsObrCUhwJAl5X2tbslRFmXAZ5B3LswpiRaqekRFuwVhIv7FVZQncS6smK1pEkGS2C(2DPKvyXQOzftgybIzfUSkjmM1LI9PMcOqJzNJ2XfA2FrD4cKc3etIHBLbxYJTNcK2a1c)bfLaz1cRyuskZNVaPdhWNVDxkznDrynISAH1xSgjR2)EpCtmjgUvgCjp2EkqAdFuwTWQ9V3d4Z3UlLHL6lHFCBjXAscRVyfPVJBlPa4sECw8iL5UlLzyVZQfwFXQ9V3d4Z3UlLHLI9PWS(gRrK1KewXOKuMpFbshoGpF7UuYA6ScywTW65sQUa(iP03m4o9lqLBljqwTWQ9V3d4Z3UlLHLI9PWS(gRIM12S2M12cnU5gyj0GpF7UukCcwrujyDHgQCBjbkefHgiQqdMoHg3CdSeAq6742ssObPl)KqJJV1LzuOyAznDwJkPYQOM1xSgDQSIOy1(37HBIjXWTYGl5X2tbsBaFUbawBZQOM1xSA)79a(8T7szyPyFkmRikwJiRVZkgLKY8JJpI12SkQz9fRGWl0)lczyptYFrHLI9PWSIOyv0S2MvlSA)79a(8T7sz4Jk0asyZoO3alHgR5sZx6hHzv8dDp0YQZAZ5l(Vajw)yIvXJuYQX)yI1MZ3UlLSEqw7UuYkS3beREbY6htS2C(I)lqI1dYkaeHYAuBjp2EkqAzfFUbaw)Ocni9nxEmj0GpF7UuMfdRl3DPmd7DHtWkrfbRl0qLBljqHOi0asyZoO3alHgrbtS2C(I)lqIvXZ9WAuBjp2EkqAz9GScarOS(rz9EiwT)9oRIN7b(pwLq8uazT58T7sjRF0BIjw9cK1pMyT58f)xGeRWIvRQvwJceXToR4ZnaGz9x3iz1Qy98fiDyHgZohTJl0G03XTLuaCjpolEKYC3LYmS3z1cRi9DCBjfWNVDxkZIH1L7UuMH9oRwynswr6742skmal4sz85l(Vajwtsy9fR2)Epy7sVmug2ZUuMVNPaIZLF)Lc4ZnaWA6Sgrwtsy1(37bBx6LHYWE2LY89mfqC2xJxuaFUbawtN1iYABwTWkgLKY85lq6Wb85B3LswFJvRsOXn3alHg85l(VajHtWkTKG1fAOYTLeOqueACZnWsOXbD0BqszSyFJfAmiyKu(8fiDybReTqJzNJ2XfAIK1BmamfqwTWAKS6MBGvWbD0BqszSyFJZGESdKctL7Yb4ZXAscRGWl4Go6niPmwSVXzqp2bsb85gay9nwJiRwyfeEbh0rVbjLXI9nod6XoqkSuSpfM13ynIcnGe2Sd6nWsOruWeRyX(gZkgY694hRia)ScKowJ9iW6h9MyIvBey9JNciRZXQJzv6hXQJzffIXJTKyfwSkjmM17XlwJiR4ZnaGzfUSgv9Jpwf)qfRrSvwXNBaaZkfb0zjHtWkrNQG1fAOYTLeOqueACZnWsOjgcR(SKqJbbJKYNVaPdlyLOfAm7C0oUqZs9LWpUTKy1cRNVaPlCtmLpygCiwtN1xSgTvXARS(IvmkjL5ZxG0Hd4Z3(SeRikwJoiAwBZABwFNvmkjL5ZxG0HzTvwxk2NcZQfwFX6lwnqOeekUcgppLjSKdIaRwynswb3)agky2aIz1cRVyfPVJBlPGbwiHaqzqcJqzynjHvdekbHIRGbwiHaq57HYy0zNdhwYbrG1KewJKvdejvEDHAa(C5UtS2M1KewXOKuMpFbshoGpF7ZsS(gRVyv0SIOy9fRrZARSEUKQlCINkhdHfoqLBljqwBZABwtsy9fRKroOykmvgdL(YAscRVyLmYbftHPY2W7H1KewjJCqXuyQS8x(YABwTWAKSEUKQlGHFzg2Z3dL7WLWxGk3wsGSMKWQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI10fHval6uzTnRwy9fRyuskZNVaPdhWNV9zjwFJ1OtLvefRVynAwBL1ZLuDHt8u5yiSWbQCBjbYABwBZQfwD8TUmJcftlRPZQOtLvrnR2)EpGpF7Uugwk2NcZkII1wM12SAH1xSgjR2)EpaWuGlbMPyuOyAJP6YurlWXQPWhL1KewjJCqXuyQmgk9L1KewJKvdejvEDbaqyhVyTnRwy1rZMhYaaRTfAajSzh0BGLqtun1xc)WAmew9zjwNoRwdXFpTkdRdM1LCqeyfUSEp0sS6lXQKWywVhVyv0SE(cKomRtXAl(lFzfXmYbftSkEUhwXWRZkCzvsymR3JxSgDQScVhAfpyI1Py1leyfXmYbftbwJAWkTpwxQVe(HvW)ofqwbykWLazLIrHIPnMQJvVazfewP9XkejTghLvhJkCcwj6OfSUqdvUTKafIIqdiHn7GEdSeAefmXAhwSclwnGSkEUh4)y14OOtbuOXSZr74cnoA28qgaeACZnWsOPdxdLH9C53FjHtWkrdybRl0qLBljqHOi0asyZoO3alHgrbtS2xQSAeyfwSAabeR3ZGzv8iLS6)dg73yCPebwLtrS(rzv8CpSACHgZohTJl0y)79GXZtzcFuHg3CdSeAwhjvWpo3xQSAeeobReDefSUqdvUTKafIIqdiHn7GEdSeAefmXQ1q83tRYWkSy1aY6VKegZkcWpRgVyvofX6CS(rzv8CpSAnyHecaXQ45EG)JvjepfqwDwno(eAm7C0oUqtKScU)bmuWSbeZQfwr6742skyaZgybo3alwTW6lwT)9EaF(2DPm8rznjHvhFRlZOqX0YA6Sk6uzTnRwynswT)9EadL4Bmu4JYQfwJKv7FVhmEEkt4JYQfwFXAKSAGiPYRludWNl3DI1Kewr6742skyGfsiaugKWiugwtsy1aHsqO4kyGfsiau(EOmgD25WHpkRjjSo1rlku6hbM7dWNlVuSpfM13yfWPYARS(IvdSa)ZfqxYmyk7Ybyft1fUjMYiD5NyTnRTfACZnWsOXqscFJlZUCawXuDcNGvI2QeSUqdvUTKafIIqJzNJ2XfAIKvW9pGHcMnGywTWksFh3wsbdy2alW5gyXQfwFXQ9V3d4Z3UlLHpkRjjS64BDzgfkMwwtNvrNkRTz1cRrYQ9V3dyOeFJHcFuwTWAKSA)79GXZtzcFuwTW6lwJKvdejvEDHAa(C5UtSMKWksFh3wsbdSqcbGYGegHYWAscRgiuccfxbdSqcbGY3dLXOZoho8rznjH1PoArHs)iWCFa(C5LI9PWS(gRgiuccfxbdSqcbGY3dLXOZohoSuSpfM1wzTLznjH1PoArHs)iWCFa(C5LI9PWSIizn6OsQS(gRrmvwBL1xSAGf4FUa6sMbtzxoaRyQUWnXugPl)eRTzTTqJBUbwcntz8T8BGLWjyLOfTG1fAOYTLeOqueAajSzh0BGLqJOGjwHfRgqwfp3dRnNVDxkz9JYQxGSIDKeRD4YAu)lX(k0y25ODCHMPoArHs)iWCFa(C5LI9PWS(gRrlAwtsy9fR2)EpGUtmCbhxM9141yYOFj23asx(jwFJval6uznjHv7FVhq3jgUGJlZ(A8Amz0Ve7BaPl)eRPlcRaw0PYABwTWQ9V3d4Z3UlLHpkRwy9fRgiuccfxbJNNYewk2NcZA6Sk6uznjHvW9pGHcMnGywBl04MBGLqdfJcftB2gwGcNGvIULfSUqdvUTKafIIqJBUbwcn4JKsFZDPVKqJbbJKYNVaPdlyLOfAm7C0oUqZs9LWpUTKy1cR3et5dMbhI10znArZQfwXOKuMpFbshoGpF7ZsS(gRwfRwy1rZMhYaaRwy9fR2)Epy88uMWsX(uywtN1OtL1KewJKv7FVhmEEkt4JYABHgqcB2b9gyj0evt9LWpS2L(sSclw)OSEqwJiRNVaPdZQ45EG)J1PmVBCwTPPaYQBd)hRhKvkcOZsS6fiRf8yfIKwJJIofqHtWkrlQeSUqdvUTKafIIqdiHn7GEdSeAefmHzfrhIySoDwNcpGeREXkIzKdkMy1lqwLtrSohRFuwfp3dRoRr9Ve7lROl0WQxGSI4Go6nijwBe7BSqJzNJ2XfAiJCqXuyQSxiWQfwD0S5HmaWQfwT)9EaDNy4coUm7RXRXKr)sSVbKU8tS(gRaw0PYQfwFXki8coOJEdskJf7BCg0JDGu4gdatbK1KewJKvdejvEDHImlucxqwtsyfJssz(8fiDywtNvaZABHg3CdSeA6)fHmSNj5ViHtWkrhveSUqdvUTKafIIqdiHn7GEdSeAefmXQxScl6EyfDHgw)LKWywBoF7UuY6Gz1Ll5GiW6hLv4YkcWpR(sS62W)X6bzfIKwJJYQJrfAm7C0oUqJ9V3dWIUhCgLwdHEdScFuwTW6lwT)9EaF(2DPmSuFj8JBljwtsy1X36YmkumTSMoRTuQS2wOXn3alHg85B3LsHtWkr3scwxOHk3wsGcrrObKWMDqVbwcnrTFmkRogLvBQdxIvRblKqaiwfp3dRnNVDxkz1lqwVhQyT58f)xGKqJzNJ2XfAmqKu51fQb4ZL7oXQfwFXksFh3wsbdSqcbGYGegHYWAscRgiuccfxbJNNYe(OSMKWQ9V3dgppLj8rzTnRwy1aHsqO4kyGfsiau(EOmgD25WHLI9PWS(gRanGHypcSIOy1qJK1xS64BDzgfkMwwFNvrNkRTz1cR2)EpGpF7Uugwk2NcZ6BSAvSAH1izfC)dyOGzdiwOXn3alHg85B3LsHtWkaovbRl0qLBljqHOi0y25ODCHgdejvEDHAa(C5UtSAH1xSI03XTLuWalKqaOmiHrOmSMKWQbcLGqXvW45PmHpkRjjSA)79GXZtzcFuwBZQfwnqOeekUcgyHecaLVhkJrNDoCyPyFkmRVXAlZQfwT)9EaF(2DPm8rz1cRKroOykmv2ley1cRrYksFh3wsHbybxkJpFX)fiXQfwJKvW9pGHcMnGyHg3CdSeAWNV4)cKeobRa4OfSUqdvUTKafIIqdiHn7GEdSeAefmXAZ5l(Vajwfp3dREXkSO7Hv0fAyfUSIa8N2GScrsRXrz1XOSkEUhwra(xwlkchRghFbwrCjgYk4pgfZQJrz1pwVhIvQazf2z9Eiwrs19GWYQ9V3zD6S2C(2DPKvXWVeSow7UuYkS3zfwSAvScxwLegZ65lq6WcnMDoAhxOX(37byr3doBKKVzKdEGv4JYAscRVynswXNV9zPGJMnpKbawTWAKSI03XTLuyawWLY4Zx8FbsSMKW6lwT)9EW45PmHLI9PWS(gRIMvlSA)79GXZtzcFuwtsy9fR2)EpSosQGFCUVuz1iewk2NcZ6BSc0agI9iWkIIvdnswFXQJV1LzuOyAz9DwJyQS2MvlSA)79W6iPc(X5(sLvJq4JYABwBZQfwr6742skGpF7UuMfdRl3DPmd7DwTWkgLKY85lq6Wb85B3LswFJ1iYABwTW6lwJK19xuhUaPWnXKy4wzWL8y7PaPnqTWFqrjqwtsyfJssz(8fiD4a(8T7sjRVXAezTTqJBUbwcn4Zx8FbscNGvamGfSUqdvUTKafIIqdiHn7GEdSeAefmXAmewywb)7uazTf)LVS(ljHXScrsRXrrNciRVIDeSjwlIaXSAE8ciHzv8CpS64BDjRXqyHBl0y25ODCHMxSsg5GIPWuzVqGvlSAGqjiuCfmEEktyPyFkmRPZQOtL1KewFXQ5XxGeMvryfWSAH1Lmp(cKY3etS(gRIM12SMKWQ5XxGeMvrynIS2MvlS6OzZdzaqOXn3alHMIeNJHWs4eScGJOG1fAOYTLeOqueAm7C0oUqZlwjJCqXuyQSxiWQfwnqOeekUcgppLjSuSpfM10zv0PYAscRVy184lqcZQiScywTW6sMhFbs5BIjwFJvrZABwtsy184lqcZQiSgrwBZQfwD0S5Hmai04MBGLqZJl75yiSeobRayRsW6cnu52scuikcnMDoAhxO5fRKroOykmv2ley1cRgiuccfxbJNNYewk2NcZA6Sk6uznjH1xSAE8fiHzvewbmRwyDjZJVaP8nXeRVXQOzTnRjjSAE8fiHzvewJiRTz1cRoA28qgaeACZnWsOP)LYCmewcNGvaSOfSUqdvUTKafIIqdiHn7GEdSeAefmXkIieXyf8VtbK1w8x(YkIzKdkMeACZnWsOrSV7a3mSNj5ViHtWkaULfSUqdvUTKafIIqdevObtNqJBUbwcni9DCBjj0G0LFsObJssz(8fiD4a(8TplXA6SAvS2kRDjeUS(I1yhF0IqgPl)eRikwJo1uz9DwbCQS2M1wzTlHWL1xSA)79a(8f)xGuMIrHIPnMQlJHsFd4ZnaW67SAvS2wObPV5YJjHg85BFwkpvgdL(kCcwbWIkbRl0qLBljqHOi0asyZoO3alHgrbtSIiU(9W6uS2aL(YkIzKdkMyfUSEpeRshFS2C(2NLyvmSow7ZX6uhKvNvRH4VNwLHv7FVheAm7C0oUqdzKdkMcYF5BUOiCSMKWkzKdkMcEHqUOiCSAHvK(oUTKcdoBKKJKynjHv7FVhiJCqXugdL(gwk2NcZ6BS6MBGvaF(2NLcueiZ)O8nXeRwy1(37bYihumLXqPVHpkRjjSsg5GIPWuzmu6lRwynswr6742skGpF7Zs5PYyO0xwtsy1(37bJNNYewk2NcZ6BS6MBGvaF(2NLcueiZ)O8nXeRwynswr6742skm4SrsosIvlSA)79GXZtzclf7tHz9nwPiqM)r5BIjwTWQ9V3dgppLj8rznjHv7FVhwhjvWpo3xQSAecFuwTWkgLKY8JJpI10zn1qlZQfwFXkgLKY85lq6WS(MiSgrwtsynswpxs1fWWVmd757HYD4s4lqLBljqwBZAscRrYksFh3wsHbNnsYrsSAHv7FVhmEEktyPyFkmRPZkfbY8pkFtmj04MBGLqJ41VhHtWkaoQiyDHgQCBjbkefHgqcB2b9gyj0ikyI1MZ3(SeRtN1PyTf)LVSIyg5GIjaX6uS2aL(YkIzKdkMyfwSAvTY65lq6WScxwpiROl0WAdu6lRiMroOysOXn3alHg85BFws4eScGBjbRl0qLBljqHOi0asyZoO3alHgeDxkVN9l04MBGLqZ(RSBUbwz5GpHg5GVC5XKqt3LY7z)cNWj00DP8E2VG1fSs0cwxOHk3wsGcrrObKWMDqVbwcnnNV4)cKyTdxwJHiPyQow)LKWyw)4PaYAuGiU1fAm7C0oUqtKSU)I6WfifSDPxgkd7zxkZ3ZuaXbQf(dkkbk04MBGLqd(8f)xGKWjyfalyDHgQCBjbkefHg3CdSeAW)Qplj0yqWiP85lq6WcwjAHgZohTJl0acVqmew9zPWsX(uywtN1LI9PWcnGe2Sd6nWsOXAo(y9EiwbHhRIN7Hvj54J1BIjwxk2NAkGcNGvIOG1fACZnWsOjgcR(SKqdvUTKafIIWjCcn4tW6cwjAbRl0qLBljqHOi0asyZoO3alHgR5sZx6hHzv8dDp0YAZ5l(VajwlIaXSEqwTjw)ycK1dYkaeHY6hL17HynQTKhBpfiTSA)7DwHlRhKvWFmkR2uhUeRgyHecaj0y25ODCHM9xuhUaPWnXKy4wzWL8y7PaPnqTWFqrjqwTW6lwjJCqXuyQSxiWQfwJK1xS(Iv7FVhUjMed3kdUKhBpfiTHLI9PWSMoRanGHypcS2kRPgIMvlS(IvYihumfMkBdVhwtsyLmYbftHPYyO0xwtsyLmYbftb5V8nxueowBZAscR2)EpCtmjgUvgCjp2EkqAdlf7tHznDwDZnWkGpF7ZsbkcK5Fu(MyI1wzn1q0SAH1xSsg5GIPWuz5V8L1KewjJCqXuadL(MlkchRjjSsg5GIPGxiKlkchRTzTnRjjSgjR2)EpCtmjgUvgCjp2EkqAdFuwBZAscRVy1(37bJNNYe(OSMKWksFh3wsbdSqcbGYGegHYWABwTWQbcLGqXvWalKqaO89qzm6SZHdl5GiWABHg3CdSeAWNV4)cKeobRaybRl0qLBljqHOi04MBGLqJd6O3GKYyX(gl0yqWiP85lq6WcwjAHgZohTJl0ejRGWl4Go6niPmwSVXzqp2bsHBmamfqwTWAKS6MBGvWbD0BqszSyFJZGESdKctL7Yb4ZXQfwFXAKSccVGd6O3GKYyX(gNFixgUXaWuaznjHvq4fCqh9gKugl2348d5YWsX(uywtNvrZABwtsyfeEbh0rVbjLXI9nod6XoqkGp3aaRVXAez1cRGWl4Go6niPmwSVXzqp2bsHLI9PWS(gRrKvlSccVGd6O3GKYyX(gNb9yhifUXaWuafAajSzh0BGLqJOGjwrCqh9gKeRnI9nMvXpuX69qlX6GzTGS6MBqsSIf7BmGy1XSk9Jy1XSIcX4XwsSclwXI9nMvXZ9WkGzfUS2jX0Yk(CdaywHlRWIvN1i2kRyX(gZkgY694hR3dXArIzfl23yw9DhKeM1OQF8XQ3pAz9E8JvSyFJzLIa6Sew4eSsefSUqdvUTKafIIqdiHn7GEdSeAefmHz1AWcjeaI1PZQXzDWS(rzfUSIa8ZQVeRGegHYmfqwTgI)EAvgwfp3dRwdwiHaqS6fiRia)S6lXQnjHIz1QsLvhJk0y25ODCHMxSI03XTLuWalKqaOmiHrOmSAH1iz1aHsqO4ky88uMWsoicSMKWQ9V3dgppLj8rzTnRwy1X36YmkumTS(gRwvQSAH1xSA)79azKdkMYYF5ByPyFkmRPZA0PYAscR2)Epqg5GIPmgk9nSuSpfM10zn6uzTnRjjS2hGpxEPyFkmRVXA0Pk04MBGLqJbwiHaq57HYy0zNdlCcwXQeSUqdvUTKafIIqdevObtNqJBUbwcni9DCBjj0G0LFsO5fR2)Epy88uMWsX(uywtNvrZQfwFXQ9V3dRJKk4hN7lvwncHLI9PWSMoRIM1KewJKv7FVhwhjvWpo3xQSAecFuwBZAscRrYQ9V3dgppLj8rznjHvhFRlZOqX0Y6BSgXuzTnRwy9fRrYQ9V3damf4sGzkgfkM2yQUmv0cCSAk8rznjHvhFRlZOqX0Y6BSgXuzTnRwy9fR2)Epqg5GIPmgk9nSuSpfM10zfObme7rG1KewT)9EGmYbftz5V8nSuSpfM10zfObme7rG12cnGe2Sd6nWsOjQM6lHFyfeEyw)LKWywTgI)EAvgwFCmRscJz9E8IvrZkMmywxk2NAkGaI17Hyfjv3dclR2)ENv4Y69qScac74fR2)EN1bZQBd)hRhK1UlLSc7Dw9cKvVqGveZihumX6Gz1TH)J1dYkfb0zjHgK(MlpMeAaHxEPw4plft1HfobRiAbRl0qLBljqHOi04MBGLqtmew9zjHgZohTJl0SuFj8JBljwTW65lq6c3et5dMbhI10znAaZQfwFXQJMnpKbawTWksFh3wsbq4LxQf(ZsXuDywBl0yqWiP85lq6WcwjAHtWkTSG1fAOYTLeOqueACZnWsOb)R(SKqJzNJ2XfAwQVe(XTLeRwy98fiDHBIP8bZGdXA6SgnGz1cRVy1rZMhYaaRwyfPVJBlPai8Yl1c)zPyQomRTfAmiyKu(8fiDybReTWjyfrLG1fAOYTLeOqueACZnWsObFKu6BUl9LeAm7C0oUqZs9LWpUTKy1cRNVaPlCtmLpygCiwtN1OBzwTW6lwD0S5HmaWQfwr6742skacV8sTWFwkMQdZABHgdcgjLpFbshwWkrlCcwjQiyDHgQCBjbkefHgqcB2b9gyj0ikyIveDOvyfwSAazv8CpW)XQXrrNcOqJzNJ2XfAC0S5Hmai04MBGLqthUgkd75YV)scNGvAjbRl0qLBljqHOi0asyZoO3alHgrbtSEpeRiAt19GWYQBpY5qGvyXQbKvXpJ5H1bZQn1HlXQ1q83tRYi0y25ODCHg7FVhmEEkt4Jk04MBGLqZ6iPc(X5(sLvJGWjyLOtvW6cnu52scuikcnGe2Sd6nWsOruWeRrvof4sGS2Go7Cywfp3dRnqPVSIyg5GIjw9cK1O(xI9L1FjjmMvjepfqwDw)ysOXSZr74cnVy9fR2)Epqg5GIPmgk9nSuSpfM10zn6uznjHv7FVhiJCqXuw(lFdlf7tHznDwJovwBZQfwnqOeekUcgppLjSuSpfM10znIPYQfwFXQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI13yfWwvQSMKWAKSU)I6Wfifq3jgUGJlZ(A8Amz0Ve7BGAH)GIsGS2M12SMKWQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI10fHvalQsL1KewnqOeekUcgppLjSKdIaRwy9fRo(wxMrHIPL10zTLsL1Kewr6742skm4SdjwBl04MBGLqdfJcftB2gwGcNGvIoAbRl0qLBljqHOi0asyZoO3alHgrbtSAne)90QmSkEUhwTgSqcbGy1lqwbHvAFScrsR4DoI1O(xI9vOXSZr74cnrYk4(hWqbZgqmRwyfPVJBlPGbmBGf4CdSy1cRVy1X36YmkumTSMoRTuQSAH1xSA)79aatbUeyMIrHIPnMQltfTahRMcFuwtsynswnqKu51faaHD8I12SMKWQbIKkVUqnaFUC3jwtsyfPVJBlPWGZoKynjHv7FVhSLqiO8JVWhLvlSA)79GTecbLF8fwk2NcZ6BSc4uzTvwFX6lwBjwruSU)I6Wfifq3jgUGJlZ(A8Amz0Ve7BGAH)GIsGS2M1wz9fRgyb(NlGUKzWu2LdWkMQlCtmLr6YpXABwBZABwTWAKSA)79GXZtzcFuwTW6lwJKvdejvEDHAa(C5UtSMKWQbcLGqXvWalKqaO89qzm6SZHdFuwtsyDQJwuO0pcm3hGpxEPyFkmRVXQbcLGqXvWalKqaO89qzm6SZHdlf7tHzTvwBzwtsyDQJwuO0pcm3hGpxEPyFkmRiswJoQKkRVXkGtL1wz9fRgyb(NlGUKzWu2LdWkMQlCtmLr6YpXABwBl04MBGLqJHKe(gxMD5aSIP6eobRenGfSUqdvUTKafIIqJzNJ2XfAIKvW9pGHcMnGywTWksFh3wsbdy2alW5gyXQfwFXQJV1LzuOyAznDwBPuz1cRVy1(37baMcCjWmfJcftBmvxMkAbownf(OSMKWAKSAGiPYRlaac74fRTznjHvdejvEDHAa(C5UtSMKWksFh3wsHbNDiXAscR2)EpylHqq5hFHpkRwy1(37bBjeck)4lSuSpfM13ynIPYARS(I1xS2sSIOyD)f1HlqkGUtmCbhxM9141yYOFj23a1c)bfLazTnRTY6lwnWc8pxaDjZGPSlhGvmvx4MykJ0LFI12S2M12SAH1iz1(37bJNNYe(OSAH1xSgjRgisQ86c1a85YDNynjHvdekbHIRGbwiHaq57HYy0zNdh(OSMKW6uhTOqPFeyUpaFU8sX(uywFJvdekbHIRGbwiHaq57HYy0zNdhwk2NcZARS2YSMKW6uhTOqPFeyUpaFU8sX(uywrKSgDujvwFJ1iMkRTY6lwnWc8pxaDjZGPSlhGvmvx4MykJ0LFI12S2wOXn3alHMPm(w(nWs4eSs0ruW6cnu52scuikcnquHgmDcnU5gyj0G03XTLKqdsx(jHMiz1aHsqO4ky88uMWsoicSMKWAKSI03XTLuWalKqaOmiHrOmSAHvdejvEDHAa(C5UtSMKWk4(hWqbZgqSqdiHn7GEdSeAq023XTLeRFmbYkSy1Th5CdHz9E8JvXEDSEqwTjwXoscK1oCz1Ai(7Pvzyfdz9E8J17HqGvFP6yvSJpcK1OQF8XQn1HlX69qXcni9nxEmj0GDKuUd3SXZtzeobReTvjyDHgQCBjbkefHgqcB2b9gyj0ikycZkIoeXyD6SofREXkIzKdkMy1lqwVDimRhKv5ueRZX6hLvXZ9WAu)lX(ciwTgI)EAvgw9cKveh0rVbjXAJyFJfAm7C0oUqdzKdkMctL9cbwTWQJMnpKbawTWQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI13yfWwvQSAH1xSccVGd6O3GKYyX(gNb9yhifUXaWuaznjH1iz1arsLxxOiZcLWfK12SAHvK(oUTKcyhjL7WnB88ugHg3CdSeA6)fHmSNj5ViHtWkrlAbRl0qLBljqHOi0asyZoO3alHgrbtScl6EyT58T7sjROl0GzD6S2C(2DPK1bxP9X6hvOXSZr74cn2)Epal6EWzuAne6nWk8rz1cR2)EpGpF7UugwQVe(XTLKqJBUbwcn4Z3UlLcNGvIULfSUqdvUTKafIIqJBUbwcngVmKmB)7DHgZohTJl0y)79a(8vcxWWsX(uywFJvrZQfwFXQ9V3dKroOykJHsFdlf7tHznDwfnRjjSA)79azKdkMYYF5ByPyFkmRPZQOzTnRwy1X36YmkumTSMoRTuQcn2)EpxEmj0GpFLWfu4eSs0IkbRl0qLBljqHOi0y25ODCHMZLuDb8rsPVzWD6xGk3wsGSAHvmD3uaXbmucZG70pwTWQ9V3d4Z3UlLbqO4sOXn3alHg85B3LsHtWkrhveSUqdvUTKafIIqdiHn7GEdSeAIA)yumRogLvBQdxIvRblKqaiw)4PaY69qSAnyHecaXQbwGZnWI1dYQ5HmaW60z1AWcjeaI1bZQBUVlLiWQBd)hRhKvBIvJJpHgZohTJl0yGiPYRludWNl3DIvlSI03XTLuWalKqaOmiHrOmSAHvdekbHIRGbwiHaq57HYy0zNdhwk2NcZ6BSkAwTWAKScU)bmuWSbel04MBGLqd(8f)xGKWjyLOBjbRl0qLBljqHOi0asyZoO3alHgrbtS2C(2DPKvXZ9Wk(iP0xwb3PFS6fiRfK1MZxjCbbeRIFOI1cYAZ5B3LswhmRFuaXkcWpR(sSofRT4V8LveZihumbiwrxOH1O(xI9LvXpuXQBdrsS2sPYQJrzfUS6GO(nijwXI9nM1hhZAuPvmzWSUuSp1uazfUSoywNI1UCa(CcnMDoAhxO5CjvxaFKu6BgCN(fOYTLeiRwynswpxs1fWNVs4cgOYTLeiRwy1(37b85B3LYWs9LWpUTKy1cRVy1(37bYihumLL)Y3WsX(uywtN1wMvlSsg5GIPWuz5V8LvlSA)79a6oXWfCCz2xJxJjJ(LyFdiD5Ny9nwbSOtL1KewT)9EaDNy4coUm7RXRXKr)sSVbKU8tSMUiScyrNkRwy1X36YmkumTSMoRTuQSMKWki8coOJEdskJf7BCg0JDGuyPyFkmRPZAuH1KewDZnWk4Go6niPmwSVXzqp2bsHPYD5a85yTnRwynswnqOeekUcgppLjSKdIGqJBUbwcn4Z3UlLcNGvaCQcwxOHk3wsGcrrObKWMDqVbwcnIcMyfJzfw09Wk6cnyw9cKvWFmkRogLvXpuXQ1q83tRYWkCz9Eiwrs19GWYQ9V3zDWS62W)X6bzT7sjRWENv4YkcWFAdYQXrz1XOcnMDoAhxOX(37byr3doBKKVzKdEGv4JYAscR2)EpaWuGlbMPyuOyAJP6YurlWXQPWhL1KewT)9EW45PmHpkRwy9fR2)EpSosQGFCUVuz1iewk2NcZ6BSc0agI9iWkIIvdnswFXQJV1LzuOyAz9DwJyQS2MvlSA)79W6iPc(X5(sLvJq4JYAscRrYQ9V3dRJKk4hN7lvwncHpkRwynswnqOeekUcRJKk4hN7lvwncHLCqeynjH1iz1arsLxxajv3dclRTznjHvhFRlZOqX0YA6S2sPYQfwjJCqXuyQSxii04MBGLqd(8f)xGKWjyfahTG1fAOYTLeOqueAajSzh0BGLqJ1xey9GSg7aqSEpeR2e(yf2zT58vcxqwTrGv85gaMciRZX6hL1w4pgaKiW6uS2aL(YkIzKdkMy1(FSg1)sSVSo46y1TH)J1dYQnXk6cngcuOXSZr74cnNlP6c4ZxjCbdu52scKvlSgjR7VOoCbsHBIjXWTYGl5X2tbsBGAH)GIsGSAH1xSA)79a(8vcxWWhL1KewD8TUmJcftlRPZAlLkRTz1cR2)EpGpFLWfmGp3aaRVXAez1cRVy1(37bYihumLXqPVHpkRjjSA)79azKdkMYYF5B4JYABwTWQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI13yfWIQuz1cRVy1aHsqO4ky88uMWsX(uywtN1OtL1KewJKvK(oUTKcgyHecaLbjmcLHvlSAGiPYRludWNl3DI12cnU5gyj0GpFX)fijCcwbWawW6cnu52scuikcnGe2Sd6nWsOruWeRnNV4)cKyDkwBGsFzfXmYbftaIvqyL2hRs6yDowrxOH1O(xI9L1x3JFSoywF8cusGSAJaR0Cp0Y69qS2C(2DPKv5ueRWL17Hy1XOP3sPYQCkI1oCzT58f)xGuBaXkiSs7JvisAfVZrS6fRWIUhwrxOHvVazvshR3dXQBdrsSkNIy9XlqjXAZ5ReUGcnMDoAhxOjsw3FrD4cKc3etIHBLbxYJTNcK2a1c)bfLaz1cRVy1(37b0DIHl44YSVgVgtg9lX(gq6YpX6BScyrvQSMKWQ9V3dO7edxWXLzFnEnMm6xI9nG0LFI13yfWIovwTW65sQUa(iP03m4o9lqLBljqwBZQfwT)9EGmYbftzmu6ByPyFkmRPZQOIvlSsg5GIPWuzmu6lRwynswT)9Eaw09GZO0Ai0BGv4JYQfwJK1ZLuDb85ReUGbQCBjbYQfwnqOeekUcgppLjSuSpfM10zvuXQfwFXQbcLGqXvaGPaxcmJrNDoCyPyFkmRPZQOI1KewJKvdejvEDbaqyhVyTTqJBUbwcn4Zx8FbscNGvaCefSUqdvUTKafIIqdiHn7GEdSeAefmXAmewywb)7uazTf)LVSIyg5GIjwHlRia)PniRW7HwXdMyfIKwJJYQ5XxGewOXSZr74cnVy1(37bYihumLL)Y3WhL1KewFXQ5XxGeMvryfWSAH1Lmp(cKY3etS(gRIM12SMKWQ5XxGeMvrynIS2MvlS6OzZdzaGvlSI03XTLua7iPChUzJNNYi04MBGLqtrIZXqyjCcwbWwLG1fAOYTLeOqueAm7C0oUqZlwT)9EGmYbftz5V8n8rz1cRrYQbIKkVUaaiSJxSMKW6lwT)9EaGPaxcmtXOqX0gt1LPIwGJvtHpkRwy1arsLxxaae2XlwBZAscRVy184lqcZQiScywTW6sMhFbs5BIjwFJvrZABwtsy184lqcZQiSgrwtsy1(37bJNNYe(OS2MvlS6OzZdzaGvlSI03XTLua7iPChUzJNNYi04MBGLqZJl75yiSeobRayrlyDHgQCBjbkefHgZohTJl08Iv7FVhiJCqXuw(lFdFuwTWAKSAGiPYRlaac74fRjjS(Iv7FVhaykWLaZumkumTXuDzQOf4y1u4JYQfwnqKu51faaHD8I12SMKW6lwnp(cKWSkcRaMvlSUK5XxGu(MyI13yv0S2M1Kewnp(cKWSkcRrK1KewT)9EW45PmHpkRTz1cRoA28qgay1cRi9DCBjfWosk3HB245PmcnU5gyj00)szogclHtWkaULfSUqdvUTKafIIqdiHn7GEdSeAefmXkIieXyfwSAafACZnWsOrSV7a3mSNj5ViHtWkawujyDHgQCBjbkefHgqcB2b9gyj0ikyI1MZ3(SeRhKv0fAyTbk9LveZihumbiwTgI)EAvgwFCmRscJz9MyI17XlwDwrex)EyLIaz(hXQK6hRWLvyjrG1w8x(YkIzKdkMyDWS(rfAm7C0oUqdzKdkMctLL)YxwtsyLmYbftbmu6BUOiCSMKWkzKdkMcEHqUOiCSMKWQ9V3dI9Dh4MH9mj)ff(OSAHv7FVhiJCqXuw(lFdFuwtsy9fR2)Epy88uMWsX(uywFJv3CdScIx)EcueiZ)O8nXeRwy1(37bJNNYe(OS2wOXn3alHg85BFws4eScGJkcwxOHk3wsGcrrObKWMDqVbwcnIcMyfrC97Hv49qR4btSk(zmpSoywNI1gO0xwrmJCqXeGy1Ai(7PvzyfUSEqwrxOH1w8x(YkIzKdkMeACZnWsOr863JWjyfa3scwxOHk3wsGcrrObKWMDqVbwcni6UuEp7xOXn3alHM9xz3CdSYYbFcnYbF5YJjHMUlL3Z(foHtObDjdm22pbRlyLOfSUqJBUbwcnamf4sGzm6SZHfAOYTLeOqueobRaybRl04MBGLqtmewamvUd3yHgQCBjbkefHtWkruW6cnu52scuikcnU5gyj0iE97rOrofLnGcnrNQqJzNJ2XfAEXkzKdkMcYF5BUOiCSMKWkzKdkMctLL)YxwtsyLmYbftHPY2W7H1KewjJCqXuWleYffHJ12cnGe2Sd6nWsOjQVKXXhRaMveX1Vhw9cKvN1MZx8FbsSclwBSoRIN7HvRmaFowr0DIvVaznkqe36ScxwBoF7ZsScVhAfpys4eSIvjyDHgQCBjbkefHgZohTJl08IvYihumfK)Y3Crr4ynjHvYihumfMkl)LVSMKWkzKdkMctLTH3dRjjSsg5GIPGxiKlkchRTz1cROlHmeDq863dRwynswrxczaWbXRFpcnU5gyj0iE97r4eSIOfSUqdvUTKafIIqJzNJ2XfAIK19xuhUaPGTl9Yqzyp7sz(EMcioqLBljqwtsynswnqKu51fQb4ZL7oXAscRrYkgLKY85lq6Wb85B3LswfH1OznjH1iz9CjvxO87VeoB7sVmuGk3wsGcnU5gyj0GpF7ZscNGvAzbRl0qLBljqHOi0y25ODCHM9xuhUaPGTl9Yqzyp7sz(EMcioqLBljqwTWQbIKkVUqnaFUC3jwTWkgLKY85lq6Wb85B3LswfH1OfACZnWsObF(I)lqs4eoHtObjT4bwcwbWPc4OtnAahTqJyFRPaIfAqer8OARKwwbrtebwz16peRtmkCpw7WL10gK6(xEPnRl1c)zjqwXWyIv)FWy)iqwnpEbKWboLwCkI1wgrGvRblK0EeiRntS1yfJqDEeyfrY6bzTf)oRGdYbpWIvikT(bxwF9EBwFb4i0oWP0ItrSgD0icSAnyHK2JaznT3FrD4cKciAK2SEqwt79xuhUaPaIgbQCBjbM2S(cWrODGtHtbreXJQTsAzfenreyLvR)qSoXOW9yTdxwtB0LmWyB)sBwxQf(ZsGSIHXeR()GX(rGSAE8ciHdCkT4ueRIgrGvRblK0EeiRP9(lQdxGuarJ0M1dYAAV)I6Wfifq0iqLBljW0M1xrhH2boLwCkI1wgrGvRblK0EeiRP9(lQdxGuarJ0M1dYAAV)I6Wfifq0iqLBljW0M1xrhH2bofoferepQ2kPLvq0erGvwT(dX6eJc3J1oCznTDiL2SUul8NLazfdJjw9)bJ9Jaz184fqch4uAXPiwJiIaRwdwiP9iqwt79xuhUaPaIgPnRhK10E)f1HlqkGOrGk3wsGPnRVIocTdCkT4ueRIgrGvRblK0EeiRntS1yfJqDEeyfrIiz9GS2IFN1yi4x(XScrP1p4Y6lezBwFfDeAh4uAXPiwfvicSAnyHK2JazTzITgRyeQZJaRiswpiRT43zfCqo4bwScrP1p4Y6R3BZ6ROJq7aNslofXA0PIiWQ1GfsApcK1Mj2ASIrOopcSIiz9GS2IFNvWb5GhyXkeLw)GlRVEVnRVIocTdCkT4ueRrBvicSAnyHK2JazTzITgRyeQZJaRisejRhK1w87Sgdb)YpMvikT(bxwFHiBZ6ROJq7aNslofXA0TeIaRwdwiP9iqwBMyRXkgH68iWkIK1dYAl(DwbhKdEGfRquA9dUS(692S(k6i0oWP0ItrSc4Orey1AWcjThbYAZeBnwXiuNhbwrKSEqwBXVZk4GCWdSyfIsRFWL1xV3M1xrhH2boLwCkIva3YicSAnyHK2JazTzITgRyeQZJaRiswpiRT43zfCqo4bwScrP1p4Y6R3BZ6lahH2bofoferepQ2kPLvq0erGvwT(dX6eJc3J1oCznTXxAZ6sTWFwcKvmmMy1)hm2pcKvZJxajCGtPfNIyn6Orey1AWcjThbYAZeBnwXiuNhbwrKiswpiRT43zngc(LFmRquA9dUS(cr2M1xrhH2boLwCkI1ObmIaRwdwiP9iqwBMyRXkgH68iWkIerY6bzTf)oRXqWV8JzfIsRFWL1xiY2S(k6i0oWP0ItrSc4urey1AWcjThbYAZeBnwXiuNhbwrKSEqwBXVZk4GCWdSyfIsRFWL1xV3M1xrhH2bofoferepQ2kPLvq0erGvwT(dX6eJc3J1oCznTTH(L2SUul8NLazfdJjw9)bJ9Jaz184fqch4uAXPiwJoQGiWQ1GfsApcK1Mj2ASIrOopcSIiz9GS2IFNvWb5GhyXkeLw)GlRVEVnRVIyeAh4uAXPiwJULqey1AWcjThbYAZeBnwXiuNhbwrKSEqwBXVZk4GCWdSyfIsRFWL1xV3M1xrhH2bofoL0kgfUhbYAlZQBUbwSkh8HdCkcnyuYiyLOtfWcnOlSpssOjnPH1O4sVmeRrT9pGCkPjnSMIxFFrGvahraXkGtfWrZPWPKM0WQ1E8ciHre4ustAyvuZkIdcsGS2aL(YAuipoWPKM0WQOMvR94fqcK1ZxG0LNoRghtywpiRgemskF(cKoCGtjnPHvrnRr1umejbY6VkYqySViWksFh3wsywFnbkaiwrxczgF(I)lqIvrD6SIUeYa(8f)xGu7aNsAsdRIAwrCKWbKv0Lmo(MciRiIRFpSoDwNlTXSEpeRIxybKveZihumf4ustAyvuZkIwCaiwTgSqcbGy9EiwBqNDomRoRY5ojXAmCjw7skcJTKy910zfb4N1hhSs7J1N5yDowXt8xEErWpwIaRIN7H1OevbIBDwBLvRrscFJlzfXLdWkMQdqSoxAdYkgGbTDGtHtXn3alCaDjdm22praykWLaZy0zNdZPKM0W6lRGO10QnRw)HyfPVJBljwhmRy6y9GSMkRIN7H1cYk(8JvyX6htSE7uaqhgqSgnRIFOI17HyTpl(yfweRdMvyX6htaIvaZ60z9EiwXKbwGSoyw9cK1iY60z1gEpS6lf4ustAy1n3alCaDjdm22Vwf5DK(oUTKau5XKiWk)Xu(2PaGoaH0LFsKu5ustAy1n3alCaDjdm22Vwf5DK(oUTKau5XKiWk)Xu(2PaGoabrfXbbbesx(jrUDkaOleD4XXz0fAcEHGLBNca6crhmqOeekUcG)1VbwCkPjnS6MBGfoGUKbgB7xRI8osFh3wsaQ8yseyL)ykF7uaqhGGOI4GGacPl)KiVUDkaOla4WJJZOl0e8cbl3ofa0faCWaHsqO4ka(x)gy1grbyof3CdSWb0LmWyB)AvK3JHWcGPYD4gZPKgwJ6lzC8XkGzfrC97HvVaz1zT58f)xGeRWI1gRZQ45Ey1kdWNJveDNy1lqwJceXToRWL1MZ3(SeRW7HwXdM4uCZnWchqxYaJT9RvrEx863dGKtrzdOirNkGMUiViJCqXuq(lFZffHljHmYbftHPYYF5BsczKdkMctLTH3tsczKdkMcEHqUOiCT5uCZnWchqxYaJT9RvrEx863dGMUiViJCqXuq(lFZffHljHmYbftHPYYF5BsczKdkMctLTH3tsczKdkMcEHqUOiCTTGUeYq0bXRFpwIeDjKbaheV(9WP4MBGfoGUKbgB7xRI8o(8TplbOPlsK7VOoCbsbBx6LHYWE2LY89mfqCssKgisQ86c1a85YDNssIeJssz(8fiD4a(8T7sPirNKe55sQUq53FjC22LEzOavUTKa5uCZnWchqxYaJT9RvrEhF(I)lqcqtxK9xuhUaPGTl9Yqzyp7sz(EMci2IbIKkVUqnaFUC3jlyuskZNVaPdhWNVDxkfjAofoL0KgwrSiqM)rGSsiPfbwVjMy9EiwDZbxwhmRosFKUTKcCkU5gyHfbdL(MTjpMtjnS2qhMvehIySclwJyRSkEUh4)yfCN(XQxGSkEUhwBoFLWfKvVazfWTYk8EOv8Gjof3CdSWIG03XTLeGkpMezWzhsacPl)KiyuskZNVaPdhWNVDxktpAlVI8CjvxaF(kHlyGk3wsGjjNlP6c4JKsFZG70VavUTKaBNKGrjPmF(cKoCaF(2DPmDaZPKgwBOdZQrsosIvXpuXAZ5BFwIvJxS(mhRaUvwpFbshMvXpJ5H1bZ6sscPxhRD4Y69qSIyg5GIjwpiR2eROl1PDjqof3CdSWTkY7i9DCBjbOYJjrgC2ijhjbiKU8tIGrjPmF(cKoCaF(2NLspAoL0WQOGjwTPftlatbKvXZ9WQXzfUS69JwwTgSqcbGyDkwnoNIBUbw4wf5DBAX0cWuab00f5vKgisQ86c1a85YDNssI0aHsqO4kyGfsiau(EOmgD25WHpABl2)Epy88uMWhLtjnSg1HhRIN7HvJZ694hRdUs7JvN1O(xI9Lv0fA4uCZnWc3QiVJcVbwaA6Iy)79GXZtzclf7tHtp6u5usdRwZLMV0pcZQ4h6EOL1pEkGSAnyHecaXAbfZQ4rkz1LsOywra(z9GSIVrkz144J17Hyf7XeREm8xhRWoRwdwiHaqTAne)90QmSAC8H5uCZnWc3QiVJ03XTLeGkpMeXalKqaOmiHrOmacPl)KigAKVEn1rlku6hbM7dWNlVuSpfwuhTOf1giuccfxbJNNYewk2Nc3grgDuj12IyOr(61uhTOqPFeyUpaFU8sX(uyrD0IwuhnGtvuBGqjiuCfmWcjeakFpugJo7C4WsX(u42iYOJkP2ojXaHsqO4ky88uMWsX(u40N6Offk9JaZ9b4ZLxk2NcNKyGqjiuCfmWcjeakFpugJo7C4WsX(u40N6Offk9JaZ9b4ZLxk2NclQJo1KKinqKu51fQb4ZL7oXPKgwffmbY6bzfKKocSEpeRFSdKyf2z1Ai(7Pvzyv8dvS(XtbKvq43wsSclw)yItXn3alCRI8osFh3wsaQ8ysedy2alW5gybiKU8tI8ksQf(dkkbgOyuewYLz4cwEzOKedekbHIRafJIWsUmdxWYldfwk2Nc)w0TCQwI0aHsqO4kqXOiSKlZWfS8YqHLCqeANKyGiPYRlaac74fNsAyvuWeRiwmkcl5swJQyblVmeRaovmzWSAtD4sS6SAne)90QmS(XuGtXn3alCRI8(ht55OyavEmjcfJIWsUmdxWYldbOPlIbcLGqXvW45PmHLI9PWVb4uTyGqjiuCfmWcjeakFpugJo7C4WsX(u43aCQjj9b4ZLxk2Nc)wefvCkPHvrbtS2a)sjDtbK1O6VncS2YyYGz1M6WLy1z1Ai(7Pvzy9JPaNIBUbw4wf59pMYZrXaQ8ysem8lL0DtbmVFBea00fXaHsqO4ky88uMWsX(u43AzlrI03XTLuWalKqaOmiHrOmjjgiuccfxbdSqcbGY3dLXOZohoSuSpf(Tw2csFh3wsbdSqcbGYGegHYKK0hGpxEPyFk8Baw0CkU5gyHBvK3)ykphfdOYJjrMcB2)52sk3cFVUFCgKqogcqtxe7FVhmEEkt4JYPKM0W6lRGO10QnRw)zWSoywDwx)EOLvs62W1pIvXocSEqwJDaiwDPKvyX6htSIp)y92PaGomRhKvBIv5ueiRFuwfp3dRwdXFpTkdREbYQ1GfsiaeREbY6htSEpeRaUazflHhRWIvdiRtNvB49W6TtbaDyw9LyfwS(XeR4ZpwVDkaOdZPKM0WQBUbw4wf59pMYZrXyaHLWdlYTtbaDrdOPlYlK(oUTKcWk)Xu(2PaGorIojbPVJBlPaSYFmLVDkaOtKi22Yl7FVhmEEkt4JMKyGqjiuCfmEEktyPyFkCRao9BNca6crhmqOeekUcG)1VbwwEfPbIKkVUqnaFUC3PKKir6742skyGfsiaugKWiuM2wI0arsLxxaae2XRKedejvEDHAa(C5Utwq6742skyGfsiaugKWiuglgiuccfxbdSqcbGY3dLXOZoho8rTePbcLGqXvW45PmHpQLxVS)9EGmYbftz5V8nSuSpfo9OtnjX(37bYihumLXqPVHLI9PWPhDQTTe5(lQdxGuW2LEzOmSNDPmFptbeNK8Y(37bBx6LHYWE2LY89mfqCU87VuaFUbareDsI9V3d2U0ldLH9SlL57zkG4SVgVOa(CdaIi62TtsS)9EaGPaxcmtXOqX0gt1LPIwGJvtHpA7KK(a85Ylf7tHFdWPYPKM0WQBUbw4wf59pMYZrXyaHLWdlYTtbaDagqtxeK(oUTKcWk)Xu(2PaGorIOLiVDkaOleDyjheHSbcLGqXvsYl7FVhmEEkt4JMKyGqjiuCfmEEktyPyFkCRao9BNca6caoyGqjiuCfa)RFdSS8ksdejvEDHAa(C5UtjjrI03XTLuWalKqaOmiHrOmTTePbIKkVUaaiSJxjjgisQ86c1a85YDNSG03XTLuWalKqaOmiHrOmwmqOeekUcgyHecaLVhkJrNDoC4JAjsdekbHIRGXZtzcFulVEz)79azKdkMYYF5ByPyFkC6rNAsI9V3dKroOykJHsFdlf7tHtp6uBBjY9xuhUaPGTl9Yqzyp7sz(EMcioj5L9V3d2U0ldLH9SlL57zkG4C53FPa(CdaIi6Ke7FVhSDPxgkd7zxkZ3ZuaXzFnErb85gaer0TB3ojX(37baMcCjWmfJcftBmvxMkAbownf(Ojj9b4ZLxk2Nc)gGtLtjnSkkycZQlLScVhAzfwS(XeRZrXywHfRgqof3CdSWTkY7FmLNJIXaA6Iy)79GXZtzcF0KedejvEDHAa(C5Utwq6742skyGfsiaugKWiuglgiuccfxbdSqcbGY3dLXOZoho8rTePbcLGqXvW45PmHpQLxVS)9EGmYbftz5V8nSuSpfo9OtnjX(37bYihumLXqPVHLI9PWPhDQTTe5(lQdxGuW2LEzOmSNDPmFptbeNKS)I6WfifSDPxgkd7zxkZ3ZuaXwEz)79GTl9Yqzyp7sz(EMciox(9xkGp3aq6rmjX(37bBx6LHYWE2LY89mfqC2xJxuaFUbG0Jy72jj2)EpaWuGlbMPyuOyAJP6YurlWXQPWhnjPpaFU8sX(u43aCQCkPH1OgzgqIv3CdSyvo4JvBhtGSclwXZ99BG17sc4G5uCZnWc3QiVV)k7MBGvwo4dqLhtI4qcq4BhZjs0aA6IG03XTLuyWzhsCkU5gyHBvK33FLDZnWklh8bOYJjrSH(bi8TJ5ejAanDr2FrD4cKc2U0ldLH9SlL57zkG4a1c)bfLa5uCZnWc3QiVV)k7MBGvwo4dqLhtIGpofoL0WQ1CP5l9JWSk(HUhAz9EiwJAl5Xg)mp0YQ9V3zv8iLS2DPKvyVZQ45EMI17HyTOiCSAC8XP4MBGfo4qseK(oUTKau5XKiGl5XzXJuM7UuMH9oGq6YpjYl7FVhUjMed3kdUKhBpfiTHLI9PWVb0agI9i0AQHOtsS)9E4MysmCRm4sES9uG0gwk2Nc)MBUbwb85BFwkqrGm)JY3etTMAiAlViJCqXuyQS8x(MKqg5GIPagk9nxueUKeYihumf8cHCrr4A32I9V3d3etIHBLbxYJTNcK2Wh1Y(lQdxGu4MysmCRm4sES9uG0gOw4pOOeiNsAy1AU08L(rywf)q3dTS2C(I)lqI1bZQy4EpSAC8nfqwHiPL1MZ3(SeRtXAl(lFzfXmYbftCkU5gyHdoKAvK3r6742scqLhtImal4sz85l(VajaH0LFsKijJCqXuyQmgk91YlmkjL5ZxG0Hd4Z3(Su6I2Y5sQUag(LzypFpuUdxcFbQCBjbMKGrjPmF(cKoCaF(2NLsxu1MtjnSkkyIvRblKqaiwf)qfR(XQKWywVhVyv0PYQJV1LSIcftlREbYQCkI1pkRIN7HvRH4VNwLHvXZ9a)hRsiEkGS6S(XeNIBUbw4GdPwf5DdSqcbGY3dLXOZohgqtxKxi9DCBjfmWcjeakdsyekJLinqOeekUcgppLjSKdIqsI9V3dgppLj8rBB5LJV1LzuOyAFt0PMKG03XTLuyawWLY4Zx8FbsTT8Y(37bYihumLL)Y3WsX(u40B5Ke7FVhiJCqXugdL(gwk2NcNEl32YRi3FrD4cKc2U0ldLH9SlL57zkG4Ke7FVhSDPxgkd7zxkZ3ZuaX5YV)sb85gaspIjj2)Epy7sVmug2ZUuMVNPaIZ(A8Ic4ZnaKEeBNK0hGpxEPyFk8BrNkNsAyvuWeR4F1NLyDkwr9cKIhdRIFOIv)ynARctgmRlf7tnfqwHlRscJzv8CpSgdxI1ZxG0Hz1lqwNoRZXQy4xcYA3LswH9oR2uhUeRuD0ofqwVhI1IIWXkIzKdkM4uCZnWchCi1QiVJ)vFwcqgemskF(cKoSirdOPlYRL6lHFCBjLKy)79azKdkMYyO03WsX(u43IOfYihumfMkJHsFTSuSpf(TOTklNlP6cy4xMH989q5oCj8fOYTLeyBlNVaPlCtmLpygCO0J2Qe1yuskZNVaPd36sX(uylViJCqXuyQSxiKKSuSpf(nGgWqShH2CkPH1OkjcL1pkRnNVDxkz1pwDPK1BIjmR)ssymRF8uazTfrW4RJz1lqwNJ1bZQBd)hRhKv0fAyfUSkPJ17HyfJsMXLS6MBGfRYPiwTjjumRpEbkjwJAl5X2tbslRWIvaZ65lq6WCkU5gyHdoKAvK3XNVDxkb00f5L9V3d4Z3UlLHL6lHFCBjz5fgLKY85lq6Wb85B3LY3IyssK7VOoCbsHBIjXWTYGl5X2tbsBGAH)GIsGTtsoxs1fWWVmd757HYD4s4lqLBljql2)Epqg5GIPmgk9nSuSpf(TiAHmYbftHPYyO0xl2)EpGpF7Uugwk2Nc)MOYcgLKY85lq6Wb85B3LY0fXQAB5vK7VOoCbsbjcgFDCUlj6McygOCIrXuGAH)GIsGjj3etisePvj60T)9EaF(2DPmSuSpfUva32Y5lq6c3et5dMbhkDrZPKgwreN7H1O2sES9uG0Y6htS2C(2DPK1dYkaeHY6hL17Hy1(37SAJaRUedz9JNciRnNVDxkzfwSkAwXKbwGywHlRscJzDPyFQPaYP4MBGfo4qQvrEhF(2DPeqtxK9xuhUaPWnXKy4wzWL8y7PaPnqTWFqrjqlyuskZNVaPdhWNVDxktxKiA5vK2)EpCtmjgUvgCjp2EkqAdFul2)EpGpF7UugwQVe(XTLusYlK(oUTKcGl5XzXJuM7UuMH9ULx2)EpGpF7Uugwk2Nc)wetsWOKuMpFbshoGpF7UuMoGTCUKQlGpsk9ndUt)cu52sc0I9V3d4Z3UlLHLI9PWVj62TBZPKgwTMlnFPFeMvXp09qlRoRnNV4)cKy9JjwfpsjRg)JjwBoF7UuY6bzT7sjRWEhqS6fiRFmXAZ5l(VajwpiRaqekRrTL8y7PaPLv85gay9JYP4MBGfo4qQvrEhPVJBljavEmjc(8T7szwmSUC3LYmS3besx(jrC8TUmJcftB6rLuf1VIoveL9V3d3etIHBLbxYJTNcK2a(CdaTf1VS)9EaF(2DPmSuSpfgrfrejgLKY8JJpQTO(fi8c9)Iqg2ZK8xuyPyFkmIs0TTy)79a(8T7sz4JYPKgwffmXAZ5l(Vajwfp3dRrTL8y7PaPL1dYkaeHY6hL17Hy1(37SkEUh4)yvcXtbK1MZ3UlLS(rVjMy1lqw)yI1MZx8FbsSclwTQwznkqe36SIp3aaM1FDJKvRI1ZxG0H5uCZnWchCi1QiVJpFX)fibOPlcsFh3wsbWL84S4rkZDxkZWE3csFh3wsb85B3LYSyyD5UlLzyVBjsK(oUTKcdWcUugF(I)lqkj5L9V3d2U0ldLH9SlL57zkG4C53FPa(CdaPhXKe7FVhSDPxgkd7zxkZ3ZuaXzFnErb85gaspITTGrjPmF(cKoCaF(2DP8nRItjnSkkyIvSyFJzfdz9E8JveGFwbshRXEey9JEtmXQncS(XtbK15y1XSk9Jy1XSIcX4XwsSclwLegZ694fRrKv85gaWScxwJQ(XhRIFOI1i2kR4ZnaGzLIa6SeNIBUbw4GdPwf5Dh0rVbjLXI9ngqgemskF(cKoSirdOPlsK3yaykGwI0n3aRGd6O3GKYyX(gNb9yhifMk3LdWNljbeEbh0rVbjLXI9nod6XoqkGp3aWBr0ci8coOJEdskJf7BCg0JDGuyPyFk8BrKtjnSgvt9LWpSgdHvFwI1PZQ1q83tRYW6GzDjhebwHlR3dTeR(sSkjmM17XlwfnRNVaPdZ6uS2I)YxwrmJCqXeRIN7Hvm86ScxwLegZ694fRrNkRW7HwXdMyDkw9cbwrmJCqXuG1OgSs7J1L6lHFyf8VtbKvaMcCjqwPyuOyAJP6y1lqwbHvAFScrsRXrz1XOCkU5gyHdoKAvK3JHWQplbidcgjLpFbshwKOb00fzP(s4h3wswoFbsx4MykFWm4qP)kARQ1xyuskZNVaPdhWNV9zjev0br3UnIeJssz(8fiD4wxk2NcB51ldekbHIRGXZtzcl5GiyjsW9pGHcMnGylVq6742skyGfsiaugKWiuMKedekbHIRGbwiHaq57HYy0zNdhwYbrijjsdejvEDHAa(C5UtTtsWOKuMpFbshoGpF7ZsV9s0iQxr365sQUWjEQCmew4avUTKaB3oj5fzKdkMctLXqPVjjViJCqXuyQSn8EssiJCqXuyQS8x(22sKNlP6cy4xMH989q5oCj8fOYTLeysI9V3dO7edxWXLzFnEnMm6xI9nG0LFkDraSOtTTLxyuskZNVaPdhWNV9zP3Iove1ROB9Cjvx4epvogclCGk3wsGTBBXX36YmkumTPl6uf12)EpGpF7Uugwk2NcJOA52wEfP9V3damf4sGzkgfkM2yQUmv0cCSAk8rtsiJCqXuyQmgk9njjsdejvEDbaqyhVABXrZMhYaqBoL0WQOGjw7WIvyXQbKvXZ9a)hRghfDkGCkU5gyHdoKAvK37W1qzypx(9xcqtxehnBEidaCkPHvrbtS2xQSAeyfwSAabeR3ZGzv8iLS6)dg73yCPebwLtrS(rzv8CpSACof3CdSWbhsTkY7RJKk4hN7lvwncaA6Iy)79GXZtzcFuoL0WQOGjwTgI)EAvgwHfRgqw)LKWywra(z14fRYPiwNJ1pkRIN7HvRblKqaiwfp3d8FSkH4PaYQZQXXhNIBUbw4GdPwf5Ddjj8nUm7Ybyft1bOPlsKG7FadfmBaXwq6742skyaZgybo3allVS)9EaF(2DPm8rtsC8TUmJcftB6Io12wI0(37bmuIVXqHpQLiT)9EW45PmHpQLxrAGiPYRludWNl3DkjbPVJBlPGbwiHaqzqcJqzssmqOeekUcgyHecaLVhkJrNDoC4JMKm1rlku6hbM7dWNlVuSpf(naNARVmWc8pxaDjZGPSlhGvmvx4MykJ0LFQDBof3CdSWbhsTkY7tz8T8BGfGMUircU)bmuWSbeBbPVJBlPGbmBGf4CdSS8Y(37b85B3LYWhnjXX36YmkumTPl6uBBjs7FVhWqj(gdf(OwI0(37bJNNYe(OwEfPbIKkVUqnaFUC3PKeK(oUTKcgyHecaLbjmcLjjXaHsqO4kyGfsiau(EOmgD25WHpAsYuhTOqPFeyUpaFU8sX(u43mqOeekUcgyHecaLVhkJrNDoCyPyFkCRTCsYuhTOqPFeyUpaFU8sX(uyejIm6OsQVfXuB9LbwG)5cOlzgmLD5aSIP6c3etzKU8tTBZPKgwffmXkSy1aYQ45EyT58T7sjRFuw9cKvSJKyTdxwJ6Fj2xof3CdSWbhsTkY7umkumTzBybcOPlYuhTOqPFeyUpaFU8sX(u43Iw0jjVS)9EaDNy4coUm7RXRXKr)sSVbKU8tVbyrNAsI9V3dO7edxWXLzFnEnMm6xI9nG0LFkDraSOtTTf7FVhWNVDxkdFulVmqOeekUcgppLjSuSpfoDrNAsc4(hWqbZgqCBoL0WAun1xc)WAx6lXkSy9JY6bznISE(cKomRIN7b(pwNY8UXz1MMciRUn8FSEqwPiGolXQxGSwWJvisAnok6ua5uCZnWchCi1QiVJpsk9n3L(saYGGrs5ZxG0HfjAanDrwQVe(XTLKLBIP8bZGdLE0I2cgLKY85lq6Wb85BFw6nRYIJMnpKbalVS)9EW45PmHLI9PWPhDQjjrA)79GXZtzcF02CkPHvrbtywr0HigRtN1PWdiXQxSIyg5GIjw9cKv5ueRZX6hLvXZ9WQZAu)lX(Yk6cnS6fiRioOJEdsI1gX(gZP4MBGfo4qQvrEV)xeYWEMK)Ia00fHmYbftHPYEHGfhnBEidawS)9EaDNy4coUm7RXRXKr)sSVbKU8tVbyrNQLxGWl4Go6niPmwSVXzqp2bsHBmamfWKKinqKu51fkYSqjCbtsWOKuMpFbshoDa3MtjnSkkyIvVyfw09Wk6cnS(ljHXS2C(2DPK1bZQlxYbrG1pkRWLveGFw9Ly1TH)J1dYkejTghLvhJYP4MBGfo4qQvrEhF(2DPeqtxe7FVhGfDp4mkTgc9gyf(OwEz)79a(8T7szyP(s4h3wsjjo(wxMrHIPn9wk12CkPH1O2pgLvhJYQn1HlXQ1GfsiaeRIN7H1MZ3UlLS6fiR3dvS2C(I)lqItXn3alCWHuRI8o(8T7sjGMUigisQ86c1a85YDNS8cPVJBlPGbwiHaqzqcJqzssmqOeekUcgppLj8rtsS)9EW45PmHpABlgiuccfxbdSqcbGY3dLXOZohoSuSpf(nGgWqShbeLHg5lhFRlZOqX0IifDQTTy)79a(8T7szyPyFk8BwLLib3)agky2aI5uCZnWchCi1QiVJpFX)fibOPlIbIKkVUqnaFUC3jlVq6742skyGfsiaugKWiuMKedekbHIRGXZtzcF0Ke7FVhmEEkt4J22IbcLGqXvWalKqaO89qzm6SZHdlf7tHFRLTy)79a(8T7sz4JAHmYbftHPYEHGLir6742skmal4sz85l(VajlrcU)bmuWSbeZPKgwffmXAZ5l(Vajwfp3dREXkSO7Hv0fAyfUSIa8N2GScrsRXrz1XOSkEUhwra(xwlkchRghFbwrCjgYk4pgfZQJrz1pwVhIvQazf2z9Eiwrs19GWYQ9V3zD6S2C(2DPKvXWVeSow7UuYkS3zfwSAvScxwLegZ65lq6WCkU5gyHdoKAvK3XNV4)cKa00fX(37byr3doBKKVzKdEGv4JMK8ks85BFwk4OzZdzaWsKi9DCBjfgGfCPm(8f)xGusYl7FVhmEEktyPyFk8BI2I9V3dgppLj8rtsEz)79W6iPc(X5(sLvJqyPyFk8BanGHypcikdnYxo(wxMrHIPfrgXuBBX(37H1rsf8JZ9LkRgHWhTDBli9DCBjfWNVDxkZIH1L7UuMH9UfmkjL5ZxG0Hd4Z3UlLVfX2wEf5(lQdxGu4MysmCRm4sES9uG0gOw4pOOeyscgLKY85lq6Wb85B3LY3IyBoL0WQOGjwJHWcZk4FNciRT4V8L1FjjmMvisAnok6uaz9vSJGnXAreiMvZJxajmRIN7HvhFRlzngclCBof3CdSWbhsTkY7fjohdHfGMUiViJCqXuyQSxiyXaHsqO4ky88uMWsX(u40fDQjjVmp(cKWIayllzE8fiLVjMEt0Ttsmp(cKWIeX2wC0S5HmaWP4MBGfo4qQvrE)XL9CmewaA6I8ImYbftHPYEHGfdekbHIRGXZtzclf7tHtx0PMK8Y84lqclcGTSK5XxGu(My6nr3ojX84lqclseBBXrZMhYaaNIBUbw4GdPwf59(xkZXqybOPlYlYihumfMk7fcwmqOeekUcgppLjSuSpfoDrNAsYlZJVajSia2YsMhFbs5BIP3eD7KeZJVajSirSTfhnBEidaCkPHvrbtSIicrmwb)7uazTf)LVSIyg5GIjof3CdSWbhsTkY7I9Dh4MH9mj)fXP4MBGfo4qQvrEhPVJBljavEmjc(8TplLNkJHsFbesx(jrWOKuMpFbshoGpF7ZsPBvT2Lq4(k2XhTiKr6YpHOIo1urKao12T2Lq4(Y(37b85l(VaPmfJcftBmvxgdL(gWNBaarAvT5usdRIcMyfrC97H1PyTbk9LveZihumXkCz9EiwLo(yT58TplXQyyDS2NJ1PoiRoRwdXFpTkdR2)EpWP4MBGfo4qQvrEx863dGMUiKroOyki)LV5IIWLKqg5GIPGxiKlkcNfK(oUTKcdoBKKJKssS)9EGmYbftzmu6ByPyFk8BU5gyfWNV9zPafbY8pkFtmzX(37bYihumLXqPVHpAsczKdkMctLXqPVwIePVJBlPa(8TplLNkJHsFtsS)9EW45PmHLI9PWV5MBGvaF(2NLcueiZ)O8nXKLir6742skm4SrsosYI9V3dgppLjSuSpf(nkcK5Fu(MyYI9V3dgppLj8rtsS)9EyDKub)4CFPYQri8rTGrjPm)44Jsp1qlB5fgLKY85lq6WVjsetsI8Cjvxad)YmSNVhk3HlHVavUTKaBNKejsFh3wsHbNnsYrswS)9EW45PmHLI9PWPtrGm)JY3etCkPHvrbtS2C(2NLyD6SofRT4V8LveZihumbiwNI1gO0xwrmJCqXeRWIvRQvwpFbshMv4Y6bzfDHgwBGsFzfXmYbftCkU5gyHdoKAvK3XNV9zjoL0WkIUlL3Z(5uCZnWchCi1QiVV)k7MBGvwo4dqLhtI0DP8E2pNcNsAyfrFPYQrGvXZ9WQ1q83tRYWP4MBGfoyd9tK1rsf8JZ9LkRgbanDrS)9EW45PmHpkNsAy1ApKbamRtN17Hy1SZXQ9V3zDWSwWJ1pkRD4YQ0pAz9Jjof3CdSWbBOFTkY7i9DCBjbOYJjrm7Cf8(OacPl)KirA)79GTl9Yqzyp7sz(EMciox(9xk8rTeP9V3d2U0ldLH9SlL57zkG4SVgVOWhLtXn3alCWg6xRI8Ud6O3GKYyX(gdidcgjLpFbshwKOb00fX(37bBx6LHYWE2LY89mfqCU87VuaFUbG3Skl2)Epy7sVmug2ZUuMVNPaIZ(A8Ic4Zna8Mvz5vKGWl4Go6niPmwSVXzqp2bsHBmamfqlr6MBGvWbD0BqszSyFJZGESdKctL7Yb4Zz5vKGWl4Go6niPmwSVX5hYLHBmamfWKeq4fCqh9gKugl2348d5YWsX(u40Jy7Keq4fCqh9gKugl234mOh7aPa(CdaVfrlGWl4Go6niPmwSVXzqp2bsHLI9PWVjAlGWl4Go6niPmwSVXzqp2bsHBmamfW2CkPHvrbtSAnyHecaXkiHsf4uazfwSIrOmS(rzv8CpSAne)90QmSclwnGScxwTrGvX(CtbK1dcKUhAzv8CpS6SA25y1(37CkU5gyHd2q)AvK3nWcjeakFpugJo7CyanDrEH03XTLuWalKqaOmiHrOmwI0aHsqO4ky88uMWsoicjj2)Epy88uMWhTTLx2)Epy7sVmug2ZUuMVNPaIZLF)Lc4ZnaiIOtsS)9EW2LEzOmSNDPmFptbeN914ffWNBaqer3ojPpaFU8sX(u43IovoL0WQ18YqswBoFLWfKvXZ9WQKWywVhVyTLzftgmRlf7tnfqw9cKv3g(pwpiRG)yuwBoFX)fiH5uCZnWchSH(1QiVB8YqYS9V3bu5XKi4ZxjCbb00f5L9V3d2U0ldLH9SlL57zkG4C53FPWsX(u40TQGOtsS)9EW2LEzOmSNDPmFptbeN914ffwk2NcNUvfeDBlo(wxMrHIPnDrAPuT8YaHsqO4ky88uMWsX(u40fvjjVmqOeekUcumkumTzBybgwk2NcNUOYsK2)EpaWuGlbMPyuOyAJP6YurlWXQPWh1IbIKkVUaaiSJxTBZP4MBGfoyd9RvrEhF(2DPeqtxKZLuDb8rsPVzWD6xGk3wsGwW0DtbehWqjmdUt)Sy)79a(8T7szaekU4usdRrTFmkRnNV4)cKWSkEUhwVhIvZohR2)ENvVaz1M6WLy9JNciRwdwiHaqCkU5gyHd2q)AvK3XNV4)cKa00fjsK(oUTKcMDUcEFulVmqKu51fQb4ZL7oLKyGqjiuCfmEEktyPyFkC6IQKKir6742skyaZgybo3allrAGiPYRlaac74vsYldekbHIRafJcftB2gwGHLI9PWPlQSeP9V3damf4sGzkgfkM2yQUmv0cCSAk8rTyGiPYRlaac74v72CkPH1O2pgL1MZx8FbsywTPoCjwTgSqcbG4uCZnWchSH(1QiVJpFX)fibOPlYldekbHIRGbwiHaq57HYy0zNdhwk2Nc)MOTej4(hWqbZgqSLxi9DCBjfmWcjeakdsyektsIbcLGqXvW45PmHLI9PWVj62wq6742skyaZgybo3aR2wC8TUmJcftB6wvQwmqKu51fQb4ZL7ozjsW9pGHcMnGyoL0WAudwP9Xki8yf8VtbK17HyLkqwHDwTgI)EAvgaXk4FNciRamf4sGSsXOqX0gt1XkCzDkwVhIvPJpwbAazf2z1lwrmJCqXeNIBUbw4Gn0Vwf5DK(oUTKau5XKiGWlVul8NLIP6WacPl)KiVS)9EW45PmHLI9PWPlAlVS)9EyDKub)4CFPYQriSuSpfoDrNKeP9V3dRJKk4hN7lvwncHpA7KKiT)9EW45PmHpABlVI0(37baMcCjWmfJcftBmvxMkAbownf(OTT8Y(37bYihumLXqPVHLI9PWPd0agI9iKKy)79azKdkMYYF5ByPyFkC6anGHypcT5uCZnWchSH(1QiVJ)vFwcqgemskF(cKoSirdOPlYs9LWpUTKSC(cKUWnXu(GzWHsp6w2IJMnpKbali9DCBjfaHxEPw4plft1H5uCZnWchSH(1QiVhdHvFwcqgemskF(cKoSirdOPlYs9LWpUTKSC(cKUWnXu(GzWHsp6igeTfhnBEidawq6742skacV8sTWFwkMQdZP4MBGfoyd9RvrEhFKu6BUl9LaKbbJKYNVaPdls0aA6ISuFj8JBljlNVaPlCtmLpygCO0JULBDPyFkSfhnBEidawq6742skacV8sTWFwkMQdZPKgwr0HwHv4)WdiX69qSA25y1(37Scxwf)qfRia)SccR0(y9XrsSsf8d8HvhJY6bzf)xGeNIBUbw4Gn0Vwf59oCnug2ZLF)La00fXrZMhYaaNsAyfrhIySAtD4sS6SA25yv8uGqXScxwNcpGeREXkIzKdkM4uCZnWchSH(1QiV3)lczyptYFraA6I8ImYbftHPYEHqsczKdkMcyO038u5OtsiJCqXuq(lFZtLJUTLxrAGiPYRludWNl3DkjbC)dyOGzdioj5LJV1LzuOyAFRLeTLxi9DCBjfm7Cf8(Ojjo(wxMrHIP9TiMAscsFh3wsHbNDi12YlK(oUTKcgyHecaLbjmcLXsKgiuccfxbdSqcbGY3dLXOZoho8rtsIePVJBlPGbwiHaqzqcJqzSePbcLGqXvW45PmHpA72TT8YaHsqO4ky88uMWsX(u40JyQjjG7FadfmBaXjjo(wxMrHIPn9wkvlgiuccfxbJNNYe(OwEzGqjiuCfOyuOyAZ2WcmSuSpf(n3CdSc4Z3(SuGIaz(hLVjMssI0arsLxxaae2XR2jjtD0IcL(rG5(a85Ylf7tHFl6uBB5fi8coOJEdskJf7BCg0JDGuyPyFkC6wvssKgisQ86cfzwOeUGT5usdRiwmkumTSAdlqwf)qfRW)HhqIvVyfXmYbftScxwTgI)EAvgwhmRUn8FScpwTjw)ycmWAJJKyTdxwTgI)EAvgof3CdSWbBOFTkY7umkumTzBybcOPlYlYihumfK)Y3Crr4ssiJCqXuadL(MlkcxsczKdkMcEHqUOiCjj2)Epy7sVmug2ZUuMVNPaIZLF)Lclf7tHt3QcIojX(37bBx6LHYWE2LY89mfqC2xJxuyPyFkC6wvq0jjo(wxMrHIPn9wkvlgiuccfxbJNNYewYbrWsKG7FadfmBaXTT8YaHsqO4ky88uMWsX(u40JyQjjgiuccfxbJNNYewYbrODsYuhTOqPFeyUpaFU8sX(u43IovoL0WQ1q83tRYWQ4hQy1pwBPuBLvhJYQ45EG)JvjepfqwVjMyDkwJIecbLF8XkCznQ6hFSclwnqOeekUyv8dvSwWJv5utbK1pkRIN7HvRblKqaiof3CdSWbBOFTkY7gss4BCz2LdWkMQdqtxKib3)agky2aITG03XTLuWaMnWcCUbwwE9YX36YmkumTP3sPA5L9V3damf4sGzkgfkM2yQUmv0cCSAk8rtsI0arsLxxaae2XR2jj2)EpylHqq5hFHpQf7FVhSLqiO8JVWsX(u43aCQT(YalW)Cb0LmdMYUCawXuDHBIPmsx(P2TtsM6Offk9JaZ9b4ZLxk2Nc)gGtT1xgyb(NlGUKzWu2LdWkMQlCtmLr6Yp1ojXarsLxxOgGpxU7uBlVI0arsLxxOgGpxU7uscsFh3wsbdSqcbGYGegHYKKyGqjiuCfmWcjeakFpugJo7C4WsoicT5uCZnWchSH(1QiVpLX3YVbwaA6Iej4(hWqbZgqSfK(oUTKcgWSbwGZnWYYRxo(wxMrHIPn9wkvlVS)9EaGPaxcmtXOqX0gt1LPIwGJvtHpAssKgisQ86caGWoE1ojX(37bBjeck)4l8rTy)79GTecbLF8fwk2Nc)wetT1xgyb(NlGUKzWu2LdWkMQlCtmLr6Yp1UDsYuhTOqPFeyUpaFU8sX(u43IyQT(YalW)Cb0LmdMYUCawXuDHBIPmsx(P2jjgisQ86c1a85YDNAB5vKgisQ86c1a85YDNssq6742skyGfsiaugKWiuMKedekbHIRGbwiHaq57HYy0zNdhwYbrOnNsAynQ9JrzT58f)xGeMvXpuX69qS2hGphRdMv3g(pwpiRubciw7lvwncSoywDB4)y9GSsfiGyfb4NvFjw9J1wk1wz1XOSofREXkIzKdkMyfUSAne)90QmSkD8Hz1l49qlRrLwXKbZP4MBGfoyd9RvrEhPVJBljavEmjIJrJ602qgaH0LFseYihumfMkl)LViQOcI0n3aRa(8TplfOiqM)r5BIPwJKmYbftHPYYF5lIQLrKU5gyfeV(9eOiqM)r5BIPwtnayejgLKY8JJpItXn3alCWg6xRI8o(8f)xGeGMUiVM6Offk9JaZ9b4ZLxk2Nc)MvLK8Y(37H1rsf8JZ9LkRgHWsX(u43aAadXEequgAKVC8TUmJcftlImIP22I9V3dRJKk4hN7lvwncHpA72jjVC8TUmJcftBRi9DCBjfCmAuN2gYGOS)9EGmYbftzmu6ByPyFkCRGWl0)lczyptYFrHBmaGZlf7tHOaCq0PhnGtnjXX36YmkumTTI03XTLuWXOrDABidIY(37bYihumLL)Y3WsX(u4wbHxO)xeYWEMK)Ic3yaaNxk2Ncrb4GOtpAaNABlKroOykmv2leS86vKgiuccfxbJNNYe(OjjgisQ86caGWoEzjsdekbHIRafJcftB2gwGHpA7KedejvEDHAa(C5UtTT8ksdejvEDbKuDpiSjjrA)79GXZtzcF0KehFRlZOqX0MElLA7Ke7FVhmEEktyPyFkC6rflrA)79W6iPc(X5(sLvJq4JYP4MBGfoyd9RvrEViX5yiSa00f5L9V3dKroOykl)LVHpAsYlZJVajSia2YsMhFbs5BIP3eD7KeZJVajSirSTfhnBEidaCkU5gyHd2q)AvK3FCzphdHfGMUiVS)9EGmYbftz5V8n8rtsEzE8fiHfbWwwY84lqkFtm9MOBNKyE8fiHfjITT4OzZdzaGtXn3alCWg6xRI8E)lL5yiSa00f5L9V3dKroOykl)LVHpAsYlZJVajSia2YsMhFbs5BIP3eD7KeZJVajSirSTfhnBEidaCkPHveriIXkSy1aYQ9)yfDHgmRIhPKvyjrGvBI1pMazDk8asS2I)YxwrmJCqXeNIBUbw4Gn0Vwf5DX(UdCZWEMK)I4usdRIcMyT58TplX6bzfDHgwBGsFzfXmYbftScxwf)qfRtXAl(lFzfXmYbftCkU5gyHd2q)AvK3XNV9zjanDriJCqXuyQS8x(MKqg5GIPagk9nxueUKeYihumf8cHCrr4ssS)9EqSV7a3mSNj5VOWh1I9V3dKroOykl)LVHpAsYl7FVhmEEktyPyFk8BU5gyfeV(9eOiqM)r5BIjl2)Epy88uMWhTnNIBUbw4Gn0Vwf5DXRFpCkU5gyHd2q)AvK33FLDZnWklh8bOYJjr6UuEp7NtHtjnS2C(I)lqI1oCzngIKIP6y9xscJz9JNciRrbI4wNtXn3alCO7s59SFrWNV4)cKa00fjY9xuhUaPGTl9Yqzyp7sz(EMcioqTWFqrjqoL0WQ1C8X69qSccpwfp3dRsYXhR3etSUuSp1ua5uCZnWch6UuEp7VvrEh)R(SeGmiyKu(8fiDyrIgqtxeq4fIHWQplfwk2NcN(sX(uyof3CdSWHUlL3Z(BvK3JHWQplXPWPKgwTMlnFPFeMvXp09qlRnNV4)cKyTiceZ6bz1My9JjqwpiRaqekRFuwVhI1O2sES9uG0YQ9V3zfUSEqwb)XOSAtD4sSAGfsiaeNIBUbw4a(ebF(I)lqcqtxK9xuhUaPWnXKy4wzWL8y7PaPnqTWFqrjqlViJCqXuyQSxiyjYxVS)9E4MysmCRm4sES9uG0gwk2NcNoqdyi2JqRPgI2YlYihumfMkBdVNKeYihumfMkJHsFtsiJCqXuq(lFZffHRDsI9V3d3etIHBLbxYJTNcK2WsX(u40DZnWkGpF7ZsbkcK5Fu(MyQ1udrB5fzKdkMctLL)Y3KeYihumfWqPV5IIWLKqg5GIPGxiKlkcx72jjrA)79WnXKy4wzWL8y7PaPn8rBNK8Y(37bJNNYe(Ojji9DCBjfmWcjeakdsyektBlgiuccfxbdSqcbGY3dLXOZohoSKdIqBoL0WQOGjwrCqh9gKeRnI9nMvXpuX69qlX6GzTGS6MBqsSIf7BmGy1XSk9Jy1XSIcX4XwsSclwXI9nMvXZ9WkGzfUS2jX0Yk(CdaywHlRWIvN1i2kRyX(gZkgY694hR3dXArIzfl23yw9DhKeM1OQF8XQ3pAz9E8JvSyFJzLIa6SeMtXn3alCaFTkY7oOJEdskJf7BmGmiyKu(8fiDyrIgqtxKibHxWbD0BqszSyFJZGESdKc3yaykGwI0n3aRGd6O3GKYyX(gNb9yhifMk3LdWNZYRibHxWbD0BqszSyFJZpKld3yaykGjjGWl4Go6niPmwSVX5hYLHLI9PWPl62jjGWl4Go6niPmwSVXzqp2bsb85gaElIwaHxWbD0BqszSyFJZGESdKclf7tHFlIwaHxWbD0BqszSyFJZGESdKc3yaykGCkPHvrbtywTgSqcbGyD6SACwhmRFuwHlRia)S6lXkiHrOmtbKvRH4VNwLHvXZ9WQ1GfsiaeREbYkcWpR(sSAtsOywTQuz1XOCkU5gyHd4RvrE3alKqaO89qzm6SZHb00f5fsFh3wsbdSqcbGYGegHYyjsdekbHIRGXZtzcl5GiKKy)79GXZtzcF02wC8TUmJcft7BwvQwEz)79azKdkMYYF5ByPyFkC6rNAsI9V3dKroOykJHsFdlf7tHtp6uBNK0hGpxEPyFk8BrNkNsAynQM6lHFyfeEyw)LKWywTgI)EAvgwFCmRscJz9E8IvrZkMmywxk2NAkGaI17Hyfjv3dclR2)ENv4Y69qScac74fR2)EN1bZQBd)hRhK1UlLSc7Dw9cKvVqGveZihumX6Gz1TH)J1dYkfb0zjof3CdSWb81QiVJ03XTLeGkpMebeE5LAH)SumvhgqiD5Ne5L9V3dgppLjSuSpfoDrB5L9V3dRJKk4hN7lvwncHLI9PWPl6KKiT)9EyDKub)4CFPYQri8rBNKeP9V3dgppLj8rtsC8TUmJcft7Brm12wEfP9V3damf4sGzkgfkM2yQUmv0cCSAk8rtsC8TUmJcft7Brm12wEz)79azKdkMYyO03WsX(u40bAadXEessS)9EGmYbftz5V8nSuSpfoDGgWqShH2CkU5gyHd4RvrEpgcR(SeGmiyKu(8fiDyrIgqtxKL6lHFCBjz58fiDHBIP8bZGdLE0a2YlhnBEidawq6742skacV8sTWFwkMQd3MtXn3alCaFTkY74F1NLaKbbJKYNVaPdls0aA6ISuFj8JBljlNVaPlCtmLpygCO0JgWwE5OzZdzaWcsFh3wsbq4LxQf(ZsXuD42CkU5gyHd4RvrEhFKu6BUl9LaKbbJKYNVaPdls0aA6ISuFj8JBljlNVaPlCtmLpygCO0JULT8YrZMhYaGfK(oUTKcGWlVul8NLIP6WT5usdRIcMyfrhAfwHfRgqwfp3d8FSACu0PaYP4MBGfoGVwf59oCnug2ZLF)La00fXrZMhYaaNsAyvuWeR3dXkI2uDpiSS62JCoeyfwSAazv8ZyEyDWSAtD4sSAne)90QmCkU5gyHd4RvrEFDKub)4CFPYQraqtxe7FVhmEEkt4JYPKgwffmXAuLtbUeiRnOZohMvXZ9WAdu6lRiMroOyIvVaznQ)LyFz9xscJzvcXtbKvN1pM4uCZnWchWxRI8ofJcftB2gwGaA6I86L9V3dKroOykJHsFdlf7tHtp6utsS)9EGmYbftz5V8nSuSpfo9OtTTfdekbHIRGXZtzclf7tHtpIPA5L9V3dO7edxWXLzFnEnMm6xI9nG0LF6naBvPMKe5(lQdxGuaDNy4coUm7RXRXKr)sSVbQf(dkkb2UDsI9V3dO7edxWXLzFnEnMm6xI9nG0LFkDraSOk1KedekbHIRGXZtzcl5Giy5LJV1LzuOyAtVLsnjbPVJBlPWGZoKAZPKgwffmXQ1q83tRYWQ45Ey1AWcjeaIvVazfewP9XkejTI35iwJ6Fj2xof3CdSWb81QiVBijHVXLzxoaRyQoanDrIeC)dyOGzdi2csFh3wsbdy2alW5gyz5LJV1LzuOyAtVLs1Yl7FVhaykWLaZumkumTXuDzQOf4y1u4JMKePbIKkVUaaiSJxTtsmqKu51fQb4ZL7oLKG03XTLuyWzhsjj2)EpylHqq5hFHpQf7FVhSLqiO8JVWsX(u43aCQT(6vlHO2FrD4cKcO7edxWXLzFnEnMm6xI9nqTWFqrjW2T(YalW)Cb0LmdMYUCawXuDHBIPmsx(P2TBBjs7FVhmEEkt4JA5vKgisQ86c1a85YDNssmqOeekUcgyHecaLVhkJrNDoC4JMKm1rlku6hbM7dWNlVuSpf(ndekbHIRGbwiHaq57HYy0zNdhwk2Nc3AlNKm1rlku6hbM7dWNlVuSpfgrIiJoQK6Bao1wFzGf4FUa6sMbtzxoaRyQUWnXugPl)u72CkU5gyHd4RvrEFkJVLFdSa00fjsW9pGHcMnGyli9DCBjfmGzdSaNBGLLxo(wxMrHIPn9wkvlVS)9EaGPaxcmtXOqX0gt1LPIwGJvtHpAssKgisQ86caGWoE1ojXarsLxxOgGpxU7uscsFh3wsHbNDiLKy)79GTecbLF8f(OwS)9EWwcHGYp(clf7tHFlIP26RxTeIA)f1HlqkGUtmCbhxM9141yYOFj23a1c)bfLaB36ldSa)ZfqxYmyk7Ybyft1fUjMYiD5NA3UTLiT)9EW45PmHpQLxrAGiPYRludWNl3DkjXaHsqO4kyGfsiau(EOmgD25WHpAsYuhTOqPFeyUpaFU8sX(u43mqOeekUcgyHecaLVhkJrNDoCyPyFkCRTCsYuhTOqPFeyUpaFU8sX(uyejIm6OsQVfXuB9LbwG)5cOlzgmLD5aSIP6c3etzKU8tTBZPKgwr023XTLeRFmbYkSy1Th5CdHz9E8JvXEDSEqwTjwXoscK1oCz1Ai(7Pvzyfdz9E8J17HqGvFP6yvSJpcK1OQF8XQn1HlX69qXCkU5gyHd4RvrEhPVJBljavEmjc2rs5oCZgppLbqiD5NejsdekbHIRGXZtzcl5GiKKejsFh3wsbdSqcbGYGegHYyXarsLxxOgGpxU7usc4(hWqbZgqmNsAyvuWeMveDiIX60zDkw9IveZihumXQxGSE7qywpiRYPiwNJ1pkRIN7H1O(xI9fqSAne)90QmS6fiRioOJEdsI1gX(gZP4MBGfoGVwf59(Frid7zs(lcqtxeYihumfMk7fcwC0S5HmayX(37b0DIHl44YSVgVgtg9lX(gq6Yp9gGTQuT8ceEbh0rVbjLXI9nod6XoqkCJbGPaMKePbIKkVUqrMfkHlyBli9DCBjfWosk3HB245PmCkPHvrbtScl6EyT58T7sjROl0GzD6S2C(2DPK1bxP9X6hLtXn3alCaFTkY74Z3UlLaA6Iy)79aSO7bNrP1qO3aRWh1I9V3d4Z3UlLHL6lHFCBjXP4MBGfoGVwf5DJxgsMT)9oGkpMebF(kHliGMUi2)EpGpFLWfmSuSpf(nrB5L9V3dKroOykJHsFdlf7tHtx0jj2)Epqg5GIPS8x(gwk2NcNUOBBXX36YmkumTP3sPYP4MBGfoGVwf5D85B3LsanDroxs1fWhjL(Mb3PFbQCBjbAbt3nfqCadLWm4o9ZI9V3d4Z3UlLbqO4ItjnSg1(XOywDmkR2uhUeRwdwiHaqS(XtbK17Hy1AWcjeaIvdSaNBGfRhKvZdzaG1PZQ1GfsiaeRdMv3CFxkrGv3g(pwpiR2eRghFCkU5gyHd4RvrEhF(I)lqcqtxedejvEDHAa(C5Utwq6742skyGfsiaugKWiuglgiuccfxbdSqcbGY3dLXOZohoSuSpf(nrBjsW9pGHcMnGyoL0WQOGjwBoF7UuYQ45EyfFKu6lRG70pw9cK1cYAZ5ReUGaIvXpuXAbzT58T7sjRdM1pkGyfb4NvFjwNI1w8x(YkIzKdkMaeROl0WAu)lX(YQ4hQy1THijwBPuz1XOScxwDqu)gKeRyX(gZ6JJznQ0kMmywxk2NAkGScxwhmRtXAxoaFoof3CdSWb81QiVJpF7UucOPlY5sQUa(iP03m4o9lqLBljqlrEUKQlGpFLWfmqLBljql2)EpGpF7UugwQVe(XTLKLx2)Epqg5GIPS8x(gwk2NcNElBHmYbftHPYYF5Rf7FVhq3jgUGJlZ(A8Amz0Ve7BaPl)0Baw0PMKy)79a6oXWfCCz2xJxJjJ(LyFdiD5Nsxeal6uT44BDzgfkM20BPutsaHxWbD0BqszSyFJZGESdKclf7tHtpQKK4MBGvWbD0BqszSyFJZGESdKctL7Yb4Z12sKgiuccfxbJNNYewYbrGtjnSkkyIvmMvyr3dROl0Gz1lqwb)XOS6yuwf)qfRwdXFpTkdRWL17Hyfjv3dclR2)EN1bZQBd)hRhK1UlLSc7DwHlRia)PniRghLvhJYP4MBGfoGVwf5D85l(VajanDrS)9Eaw09GZgj5Bg5Ghyf(Ojj2)EpaWuGlbMPyuOyAJP6YurlWXQPWhnjX(37bJNNYe(OwEz)79W6iPc(X5(sLvJqyPyFk8BanGHypcikdnYxo(wxMrHIPfrgXuBBX(37H1rsf8JZ9LkRgHWhnjjs7FVhwhjvWpo3xQSAecFulrAGqjiuCfwhjvWpo3xQSAecl5GiKKePbIKkVUasQUhe22jjo(wxMrHIPn9wkvlKroOykmv2le4usdRwFrG1dYASdaX69qSAt4JvyN1MZxjCbz1gbwXNBaykGSohRFuwBH)yaqIaRtXAdu6lRiMroOyIv7)XAu)lX(Y6GRJv3g(pwpiR2eROl0yiqof3CdSWb81QiVJpFX)fibOPlY5sQUa(8vcxWavUTKaTe5(lQdxGu4MysmCRm4sES9uG0gOw4pOOeOLx2)EpGpFLWfm8rtsC8TUmJcftB6TuQTTy)79a(8vcxWa(CdaVfrlVS)9EGmYbftzmu6B4JMKy)79azKdkMYYF5B4J22I9V3dO7edxWXLzFnEnMm6xI9nG0LF6nalQs1YldekbHIRGXZtzclf7tHtp6utsIePVJBlPGbwiHaqzqcJqzSyGiPYRludWNl3DQnNsAyvuWeRnNV4)cKyDkwBGsFzfXmYbftaIvqyL2hRs6yDowrxOH1O(xI9L1x3JFSoywF8cusGSAJaR0Cp0Y69qS2C(2DPKv5ueRWL17Hy1XOP3sPYQCkI1oCzT58f)xGuBaXkiSs7JvisAfVZrS6fRWIUhwrxOHvVazvshR3dXQBdrsSkNIy9XlqjXAZ5ReUGCkU5gyHd4RvrEhF(I)lqcqtxKi3FrD4cKc3etIHBLbxYJTNcK2a1c)bfLaT8Y(37b0DIHl44YSVgVgtg9lX(gq6Yp9gGfvPMKy)79a6oXWfCCz2xJxJjJ(LyFdiD5NEdWIovlNlP6c4JKsFZG70VavUTKaBBX(37bYihumLXqPVHLI9PWPlQSqg5GIPWuzmu6RLiT)9Eaw09GZO0Ai0BGv4JAjYZLuDb85ReUGbQCBjbAXaHsqO4ky88uMWsX(u40fvwEzGqjiuCfaykWLaZy0zNdhwk2NcNUOkjjsdejvEDbaqyhVAZPKgwffmXAmewywb)7uazTf)LVSIyg5GIjwHlRia)PniRW7HwXdMyfIKwJJYQ5XxGeMtXn3alCaFTkY7fjohdHfGMUiVS)9EGmYbftz5V8n8rtsEzE8fiHfbWwwY84lqkFtm9MOBNKyE8fiHfjITT4OzZdzaWcsFh3wsbSJKYD4MnEEkdNIBUbw4a(AvK3FCzphdHfGMUiVS)9EGmYbftz5V8n8rTePbIKkVUaaiSJxjjVS)9EaGPaxcmtXOqX0gt1LPIwGJvtHpQfdejvEDbaqyhVANK8Y84lqclcGTSK5XxGu(My6nr3ojX84lqclsetsS)9EW45PmHpABloA28qgaSG03XTLua7iPChUzJNNYWP4MBGfoGVwf59(xkZXqybOPlYl7FVhiJCqXuw(lFdFulrAGiPYRlaac74vsYl7FVhaykWLaZumkumTXuDzQOf4y1u4JAXarsLxxaae2XR2jjVmp(cKWIayllzE8fiLVjMEt0Ttsmp(cKWIeXKe7FVhmEEkt4J22IJMnpKbali9DCBjfWosk3HB245PmCkPHvrbtSIicrmwHfRgqof3CdSWb81QiVl23DGBg2ZK8xeNsAyvuWeRnNV9zjwpiROl0WAdu6lRiMroOycqSAne)90QmS(4ywLegZ6nXeR3JxS6SIiU(9WkfbY8pIvj1pwHlRWsIaRT4V8LveZihumX6Gz9JYP4MBGfoGVwf5D85BFwcqtxeYihumfMkl)LVjjKroOykGHsFZffHljHmYbftbVqixueUKe7FVhe77oWnd7zs(lk8rTy)79azKdkMYYF5B4JMK8Y(37bJNNYewk2Nc)MBUbwbXRFpbkcK5Fu(MyYI9V3dgppLj8rBZPKgwffmXkI463dRW7HwXdMyv8ZyEyDWSofRnqPVSIyg5GIjaXQ1q83tRYWkCz9GSIUqdRT4V8LveZihumXP4MBGfoGVwf5DXRFpCkPHveDxkVN9ZP4MBGfoGVwf599xz3CdSYYbFaQ8ysKUlL3Z(foHtqaa]] )


end