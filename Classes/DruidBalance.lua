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
            duration = 10,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
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
            duration = 10,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
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
                applyBuff( "balance_of_all_things_arcane", nil, 5, 10 )
                applyBuff( "balance_of_all_things_nature", nil, 5, 10 )
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
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 10 ) end
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
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 10 ) end
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
            texture = 538771,

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


    spec:RegisterPack( "Balance", 20201220, [[dO0qHdqicLhbvk5seQYMaXNGkvgfvLtrvAvaqELqywaOBbvk2fQ(fiPHbvCmOklti5zGuMguv5AqLSnHi(guPQXbvv5CcrADeQkZJQQUNkyFuv5Gqvv1cHQYdfIYejuvHlsOQI(iHQQCsOsPSsHuZeaQBsOQQStqIFsOQQAOeQQ0sHQQINkutfKQVcvvLgluPuTxG(lrdwPdtAXuQhJYKb1Lr2SGpdOrtiNwYRvHMnf3Ms2TOFdz4q54cr1Yv8CQmDvDDvA7QOVtvmEcvopaTEaW8jy)sniEGqhmgwFcekrHtu4GxurHdhNif)Ic)Ggy8digbgJPSJkqcmovlcmgFQrtgbgJPaAqkmi0bJDO7WiWyr)J5eFqfQaRx01MZqwq1vwxJ(fkzJgEO6klgubJTVL5XTLG2GXW6tGqjkCIch8IkkC44eP4xu4hEGX69fHgW44YkYaJfvWWucAdgdtogymUvV4tnAYOEf)yUfChnUvVIFqmYYMMEJcha2Bu4efoD0D04w9gzI0ei5eFD04w9IB6f)hgMG7ngz0Px8rQfVJg3QxCtVrMinbsW9(6aKEzf6LPoY17J6LbiZqYxhG074D04w9IB6f)dzHoj4EVzsmY50bWEp1PuBd561xXjoa7fBOtP71XDhGuV4g)6fBOtU71XDhGKxEhnUvV4MEX)prfCVydXu3xjWEX)o6lQ3k0B94oxVViQxpdkb2R4NmtH5iEhnUvV4MEf)tps9gzO8eDK69fr9gJvt9UE1En1)gQxl0q9gmK4kBd1RVk0lGOBVIu4e399kQ(ERVxxzDnVMe66ma2RN6f1l(e)h)h69grVrgzi3xQPx8FtbmTO8byV1J7G71DSW8YbJnL7DGqhmgBigYYwFqOdcf8aHoySY(cLGXwiuESszanwGXuQ2gcgeFGpiuIce6GXk7lucgFSs4HGLoSAQ3bgtPABiyq8b(GqbAGqhmMs12qWG4dmwzFHsWypJ(IaJzt90ukySVEjMPWCe3CtDKjjUVxbHEjMPWCeVsP5M60RGqVeZuyoIxP0g9I6vqOxIzkmhX1eqzsI771lySPssYGbJXdhWhek4hi0bJPuTnemi(aJzt90ukySVEjMPWCe3CtDKjjUVxbHEjMPWCeVsP5M60RGqVeZuyoIxP0g9I6vqOxIzkmhX1eqzsI771BVq6fBOtoECpJ(I6fsVI1l2qN8O4Eg9fbgRSVqjySNrFrGpiuWfi0bJPuTnemi(aJzt90ukySy9o3KcObiXTvJMmsIcs1yKVOkb64uQ2gcUxbHEfRxg6KsnFEwaf9YGs9ki0Ry96WiJr(6aKEh396euJP3d9IxVcc9kwVVAO85P(3HCsB1OjJ4uQ2gcgmwzFHsWy3RtOgc8bHsKacDWykvBdbdIpWy2upnLcgp3KcObiXTvJMmsIcs1yKVOkb64uQ2gcUxi9YqNuQ5ZZcOOxguQxi96WiJr(6aKEh396euJP3d9IhySY(cLGXUxh3DasGp4dgdtb9AEqOdcf8aHoySY(cLGXoKrhPnPwGXuQ2gcgeFGpiuIce6GXuQ2gcgeFGXimWyh9GXk7lucgFQtP2gcm(unxcm2HrgJ81bi9oU71jOgtV(1lE9cPxF9kwVVAO85UxhdAG5uQ2gcUxbHEF1q5ZDpzm6iHNk8CkvBdb3R3Efe61HrgJ81bi9oU71jOgtV(1BuGXN6it1IaJlNure4dcfObcDWykvBdbdIpWyegySJEWyL9fkbJp1PuBdbgFQMlbg7WiJr(6aKEh396eQH61VEXdm(uhzQweyC5KmdPNe4dcf8de6GXuQ2gcgeFGXSPEAkfm2xVI1ldDsPMpplGIEzqPEfe6vSEziKbg5j5muEIosYxejDy1uVJFX61BVq61(gcCMkRKXVyGXk7lucgBtJJMJvce8bHcUaHoymLQTHGbXhymBQNMsbJTVHaNPYkz8lgySY(cLGXyOVqj4dcLibe6GXuQ2gcgeFGXimWyh9GXk7lucgFQtP2gcm(unxcmoyqOPxF96R3kFAWqg9jyzOak6LdzPv66f30Bu40lUPxgczGrEsodLNOJK8frshwn174dzPv661BVqTx8IcNE92RF9gmi00RVE91BLpnyiJ(eSmuaf9YHS0kD9IB6nkC1lUPxF9Iho9cG69vdLpVsMoP(fk5uQ2gcUxV9IB61xVmucFRNJneRCKunfW0IYN)LfjpvZL61BV4MEziKbg5j5mvwjJpKLwPRxV9c1EXd)HtVE7vqOxgczGrEsotLvY4dzPv661VER8Pbdz0NGLHcOOxoKLwPRxbHEziKbg5j5muEIosYxejDy1uVJpKLwPRx)6TYNgmKrFcwgkGIE5qwALUEfe6vSEzOtk185zbu0ldkbgFQJmvlcmMHYt0rsctoatg4dcfCpi0bJPuTnemi(aJryGXo6bJv2xOem(uNsTney8PAUeySVEfRxkYVfggbZjlmahsns0aNAYOEfe6LHqgyKNKtwyaoKAKObo1Kr8HS0kD96FV4fj40lKEfRxgczGrEsozHb4qQrIg4utgXhsHbSxV9cPxF9kwVuKFlmmcM7qxJH(VsGY5AdyVcc9YqidmYtYDORrwz46kuYhYsR01R)9Iho40lKEfRxgczGrEsUdDnYkdxxHs(qkmG96TxbHEzOtk185hbCknbJp1rMQfbgZGLmucxFHsWhek4pqOdgtPABiyq8bgRSVqjymzHb4qQrIg4utgbgZM6PPuWygczGrEsotLvY4dzPv661)EJcNEH07PoLABiodLNOJKeMCaMSEfe6LHqgyKNKZq5j6ijFrK0Hvt9o(qwALUE9V3OWbmovlcmMSWaCi1irdCQjJaFqOePGqhmMs12qWG4dmwzFHsWyh6Am0)vcuoxBabJzt90ukymdHmWipjNPYkz8HS0kD96FVrHtVq69uNsTneNHYt0rsctoatwVcc9YqidmYtYzO8eDKKVis6WQPEhFilTsxV(3Bu40RGqVuKFlmmcMtwyaoKAKObo1KrGXPArGXo01yO)ReOCU2ac(GqbpCaHoymLQTHGbXhySY(cLGXv6yZ9vBdjJ8RM)1sctNfJaJzt90ukyS9ne4mvwjJFXaJt1IaJR0XM7R2gsg5xn)RLeMolgb(Gqbp8aHoymLQTHGbXhymBQNMsbJTVHaNPYkz8lwVcc9YqidmYtYzQSsgFilTsxV(1lE40lKEfRxg6KsnF(raNsZEfe6LHoPuZNNfqrVmOuVq69uNsTneNHYt0rsctoatwVq6LHqgyKNKZq5j6ijFrK0Hvt9o(fRxi9kwVmeYaJ8KCMkRKXVy9cPxF96Rx7BiWjMPWCK0CtD4dzPv661VEXdNEfe61(gcCIzkmhjDiJo8HS0kD96xV4HtVE7fsVI17CtkGgGe3wnAYijkivJr(IQeOJtPABi4Efe6DUjfqdqIBRgnzKefKQXiFrvc0XPuTneCVq61xV23qGBRgnzKefKQXiFrvc0jt9VdXDVYo2RF9cTEfe61(gcCB1OjJKOGung5lQsGoPomnjU7v2XE9RxO1R3E92RGqV23qGFSs4HGLKfgYdnwu(skPbybae)I1RGqVHcOOxoKLwPRx)7nkCaJv2xOem(6iz9KLd8bHcErbcDWykvBdbdIpWy2upnLcgFQtP2gIxoPIiWy3pf7bHcEGXk7lucgp3uQSVqP0uUhm2uUxMQfbgRic8bHcEqde6GXuQ2gcgeFGXSPEAkfmEUjfqdqI)Lf5bnPeEi1YUsyA4uKFlmmcgm29tXEqOGhySY(cLGXZnLk7luknL7bJnL7LPArGXWdPw2vctd4dcf8WpqOdgtPABiyq8bgZM6PPuW45MuanajUTA0KrsuqQgJ8fvjqhNI8BHHrWGXUFk2dcf8aJv2xOemEUPuzFHsPPCpySPCVmvlcm2gPp4dcf8Wfi0bJPuTnemi(aJv2xOemEUPuzFHsPPCpySPCVmvlcm29Gp4dgdpKAzxjmnGqhek4bcDWykvBdbdIpWyegySJEWyL9fkbJp1PuBdbgFQMlbg7Rx7BiW)YI8GMucpKAzxjmn8HS0kD96xVazWClvC9grV4WXRxi96RxIzkmhXRuAJEr9ki0lXmfMJ4vkDiJo9ki0lXmfMJ4MBQJmjX996TxbHETVHa)llYdAsj8qQLDLW0WhYsR01RF9QSVqj396eQH4K4i29j5xwuVr0loC86fsV(6LyMcZr8kLMBQtVcc9smtH5iUdz0rMK4(Efe6LyMcZrCnbuMK4(E92R3Efe6vSETVHa)llYdAsj8qQLDLW0WVyGXN6it1IaJDAGKpsEDK0Hrgd4dcLOaHoymLQTHGbXhymBQNMsbJ91Ry9EQtP2gI70ajFK86iPdJmMEfe61xV23qGp6jLORtggkbaa5dzPv661)EbYG5wQ46fa1lJktV(6vD)OgjgYdn9c1EHgo96Txi9AFdb(ONuIUozyOeaaKFX61BVE7vqOx19JAKyip00RF9gP4agRSVqjyS71XDhGe4dcfObcDWykvBdbdIpWy2upnLcg7R3tDk12qCgkprhjjm5amz9cP3kFAWqg9jyzOak6LdzPv661VEXdA40lKEfRxgczGrEsotLvY4dPWa2RGqV23qGZuzLm(fRxV9cPx19JAKyip00R)9IF40lKE91R9ne4eZuyosAUPo8HS0kD96xV4HtVcc9AFdboXmfMJKoKrh(qwALUE9Rx8WPxV9ki0BOak6LdzPv661)EXdhWyL9fkbJzO8eDKKVis6WQPEh4dcf8de6GXuQ2gcgeFGXk7lucgRWk2xNK05rhlWy2upnLcglwVWONRWk2xNK05rhljSAPaj(xSJvcSxi9kwVk7luYvyf7Rts68OJLewTuGeVszWuaf99cPxF9kwVWONRWk2xNK05rhlPisn8VyhReyVcc9cJEUcRyFDssNhDSKIi1WhYsR01RF9IRE92RGqVWONRWk2xNK05rhljSAPajU7v2XE9VxO1lKEHrpxHvSVojPZJowsy1sbs8HS0kD96FVqRxi9cJEUcRyFDssNhDSKWQLcK4FXowjqWygGmdjFDasVdek4b(GqbxGqhmMs12qWG4dmwzFHsWylekd1qGXSPEAkfmEOWqorQTH6fsVVoaPN)LfjFKeUOE9Rx8IQxi96RxF9AFdbotLvY4dzPv661VEXvVq61xV23qGp6jLORtggkbaa5dzPv661VEXvVcc9kwV23qGp6jLORtggkbaa5xSE92RGqVI1R9ne4mvwjJFX6vqOx19JAKyip00R)9cnC61BVq61xVI1R9ne4hReEiyjzHH8qJfLVKsAawaaXVy9ki0R6(rnsmKhA61)EHgo96Txi9QysMiIDSxVGXmazgs(6aKEhiuWd8bHsKacDWykvBdbdIpWyL9fkbJD3mudbgZM6PPuW4Hcd5eP2gQxi9(6aKE(xwK8rs4I61VEXlQEH0RVE91R9ne4mvwjJpKLwPRx)6fx9cPxF9AFdb(ONuIUozyOeaaKpKLwPRx)6fx9ki0Ry9AFdb(ONuIUozyOeaaKFX61BVcc9kwV23qGZuzLm(fRxbHEv3pQrIH8qtV(3l0WPxV9cPxF9kwV23qGFSs4HGLKfgYdnwu(skPbybae)I1RGqVQ7h1iXqEOPx)7fA40R3EH0RIjzIi2XE9cgZaKzi5Rdq6DGqbpWhek4EqOdgtPABiyq8bgRSVqjyS7jJrhzWOdbgZM6PPuW4Hcd5eP2gQxi9(6aKE(xwK8rs4I61VEXls6fsV(61xV23qGZuzLm(qwALUE9RxC1lKE91R9ne4JEsj66KHHsaaq(qwALUE9RxC1RGqVI1R9ne4JEsj66KHHsaaq(fRxV9ki0Ry9AFdbotLvY4xSEfe6vD)OgjgYdn96FVqdNE92lKE91Ry9AFdb(XkHhcwswyip0yr5lPKgGfaq8lwVcc9QUFuJed5HME9VxOHtVE7fsVkMKjIyh71lymdqMHKVoaP3bcf8aFqOG)aHoymLQTHGbXhymBQNMsbJvmjteXocgRSVqjyCanmsIcYu)7qGpiuIuqOdgtPABiyq8bgZM6PPuWy7BiWzQSsg)IbgRSVqjy8ONuIUozyOeaae8bHcE4acDWykvBdbdIpWy2upnLcg7RxF9AFdboXmfMJKoKrh(qwALUE9Rx8WPxbHETVHaNyMcZrsZn1HpKLwPRx)6fpC61BVq6LHqgyKNKZuzLm(qwALUE9RxOHtVE7vqOxgczGrEsotLvY4dPWacgRSVqjymzHH8qJ0gLWGpiuWdpqOdgtPABiyq8bgZM6PPuW4tDk12qCgSKHs46lu2lKE91RVETVHa)yLWdbljlmKhASO8LusdWcai(fRxbHEfRxg6KsnF(raNsZE92RGqVm0jLA(8Sak6LbL6vqO3tDk12q8Yjve1RGqV23qGBBqiyZ198lwVq61(gcCBdcbBUUNpKLwPRx)7nkC6nIE91ldLW365ydXkhjvtbmTO85FzrYt1CPE92R3EH0Ry9AFdbotLvY4xSEH0RVEfRxg6KsnFEwaf9YGs9ki0ldHmWipjNHYt0rs(IiPdRM6D8lwVcc9w5tdgYOpbldfqrVCilTsxV(3ldHmWipjNHYt0rs(IiPdRM6D8HS0kD9grVrsVcc9w5tdgYOpbldfqrVCilTsxVIxV4H)WPx)7nkC6nIE91ldLW365ydXkhjvtbmTO85FzrYt1CPE92RxWyL9fkbJzKHCFPgPAkGPfLp4dcf8Ice6GXuQ2gcgeFGXSPEAkfm(uNsTneNblzOeU(cL9cPxF96Rx7BiWpwj8qWsYcd5HglkFjL0aSaaIFX6vqOxX6LHoPuZNFeWP0SxV9ki0ldDsPMpplGIEzqPEfe69uNsTneVCsfr9ki0R9ne42gec2CDp)I1lKETVHa32GqWMR75dzPv661)EHgo9grV(6LHs4B9CSHyLJKQPaMwu(8VSi5PAUuVE71BVq6vSETVHaNPYkz8lwVq61xVI1ldDsPMpplGIEzqPEfe6LHqgyKNKZq5j6ijFrK0Hvt9o(fRxbHER8Pbdz0NGLHcOOxoKLwPRx)7LHqgyKNKZq5j6ijFrK0Hvt9o(qwALUEJO3iPxbHER8Pbdz0NGLHcOOxoKLwPRxXRx8WF40R)9cnC6nIE91ldLW365ydXkhjvtbmTO85FzrYt1CPE92RxWyL9fkbJRKPtQFHsWhek4bnqOdgtPABiyq8bgJWaJD0dgRSVqjy8PoLABiW4t1CjWyF9kwVmeYaJ8KCMkRKXhsHbSxbHEfR3tDk12qCgkprhjjm5amz9cPxg6KsnFEwaf9YGs96fm(uhzQweyStpjzansMkRKb(Gqbp8de6GXuQ2gcgeFGXSPEAkfmMyMcZr8kLAcyVq6vXKmre7yVq61xVWONRWk2xNK05rhljSAPaj(xSJvcSxbHEfRxg6KsnFEsSbzqdCVE7fsVN6uQTH4o9KKb0izQSsgySY(cLGXH7aOefKK5Me4dcf8Wfi0bJPuTnemi(aJzt90ukymdDsPMpplGIEzqPEH07PoLABiodLNOJKeMCaMSEH0R6(rnsmKhA61Vd9IF40lKEziKbg5j5muEIosYxejDy1uVJpKLwPRx)7fidMBPIRxauVmQm96Rx19JAKyip00lu7fA40RxWyL9fkbJDVoU7aKaFqOGxKacDWykvBdbdIpWy2upnLcg7Rx7BiWjMPWCK0CtD4xSEfe61xVmr6aKC9EO3O6fsVdXePdqs(Lf1R)9IRE92RGqVmr6aKC9EOxO1R3EH0RIjzIi2XEH07PoLABiUtpjzansMkRKbgRSVqjyCsEKwiuc(GqbpCpi0bJPuTnemi(aJzt90ukySVETVHaNyMcZrsZn1HFX6fsVI1ldDsPMp)iGtPzVcc96Rx7BiWpwj8qWsYcd5HglkFjL0aSaaIFX6fsVm0jLA(8JaoLM96TxbHE91ltKoajxVh6nQEH07qmr6aKKFzr96FV4QxV9ki0ltKoajxVh6fA9ki0R9ne4mvwjJFX61BVq6vXKmre7yVq69uNsTne3PNKmGgjtLvYaJv2xOemwKAcslekbFqOGh(de6GXuQ2gcgeFGXSPEAkfm2xV23qGtmtH5iP5M6WVy9cPxX6LHoPuZNFeWP0SxbHE91R9ne4hReEiyjzHH8qJfLVKsAawaaXVy9cPxg6KsnF(raNsZE92RGqV(6LjshGKR3d9gvVq6DiMiDasYVSOE9VxC1R3Efe6LjshGKR3d9cTEfe61(gcCMkRKXVy96Txi9QysMiIDSxi9EQtP2gI70tsgqJKPYkzGXk7lucghUgJ0cHsWhek4fPGqhmwzFHsWyp6mfAKOGKm3KaJPuTnemi(aFqOefoGqhmMs12qWG4dmMn1ttPGXeZuyoIxP0CtD6vqOxIzkmhXDiJoYKe33RGqVeZuyoIRjGYKe33RGqV23qG7rNPqJefKK5Me)I1lKETVHaNyMcZrsZn1HFX6vqOxF9AFdbotLvY4dzPv661)Ev2xOK7z0xeNehXUpj)YI6fsV23qGZuzLm(fRxVGXk7lucg7EDc1qGpiuIcpqOdgRSVqjySNrFrGXuQ2gcgeFGpiuIkkqOdgtPABiyq8bgRSVqjy8CtPY(cLst5EWyt5EzQweyCqnMx0CbFWhmwrei0bHcEGqhmMs12qWG4dmgHbg7OhmwzFHsW4tDk12qGXNQ5sGX(61(gc8VSipOjLWdPw2vctdFilTsxV(3lqgm3sfxVr0loC86vqOx7BiW)YI8GMucpKAzxjmn8HS0kD96FVk7luYDVoHAiojoIDFs(Lf1Be9IdhVEH0RVEjMPWCeVsP5M60RGqVeZuyoI7qgDKjjUVxbHEjMPWCextaLjjUVxV96Txi9AFdb(xwKh0Ks4Hul7kHPHFX6fsVZnPaAas8VSipOjLWdPw2vctdNI8BHHrWGXN6it1IaJHhsTKEkJrguJrIcbWhekrbcDWykvBdbdIpWy2upnLcg7R3tDk12qCgkprhjjm5amz9cPxX6LHqgyKNKZuzLm(qkmG9ki0R9ne4mvwjJFX61BVq6vD)OgjgYdn96FV4cNEH0RVETVHaNyMcZrsZn1HpKLwPRx)6ns6vqOx7BiWjMPWCK0Hm6WhYsR01RF9gj96Txi96RxX6DUjfqdqIBRgnzKefKQXiFrvc0XPuTneCVcc9AFdbUTA0KrsuqQgJ8fvjqNm1)oe39k7yV(1l06vqOx7BiWTvJMmsIcs1yKVOkb6K6W0K4Uxzh71VEHwVE7vqO3qbu0lhYsR01R)9IhoGXk7lucgZq5j6ijFrK0Hvt9oWhekqde6GXuQ2gcgeFGXSPEAkfm2(gcC3Rtqng(qHHCIuBd1lKE91RdJmg5Rdq6DC3RtqnME9VxO1RGqVI17CtkGgGe)llYdAsj8qQLDLW0WPi)wyyeCVE7fsV(6vSENBsb0aK4gaz6OozWq0xjqjqtzH5iof53cdJG7vqO3VSOEfVEXpC1RF9AFdbU71jOgdFilTsxVr0Bu96fmwzFHsWy3RtqngWhek4hi0bJPuTnemi(aJzt90uky8CtkGgGe)llYdAsj8qQLDLW0WPi)wyyeCVq61HrgJ81bi9oU71jOgtV(DOxO1lKE91Ry9AFdb(xwKh0Ks4Hul7kHPHFX6fsV23qG7EDcQXWhkmKtKABOEfe61xVN6uQTH4WdPwspLXidQXirHqVq61xV23qG7EDcQXWhYsR01R)9cTEfe61HrgJ81bi9oU71jOgtV(1Bu9cP3xnu(C3tgJos4PcpNs12qW9cPx7BiWDVob1y4dzPv661)EXvVE71BVEbJv2xOem296euJb8bHcUaHoymLQTHGbXhymcdm2rpySY(cLGXN6uQTHaJpvZLaJv3pQrIH8qtV(1l(dNEXn96Rx8WPxauV23qG)Lf5bnPeEi1YUsyA4Uxzh71BV4ME91R9ne4UxNGAm8HS0kD9cG6fA9c1EDyKXifPUN61BV4ME91lm65H7aOefKK5MeFilTsxVaOEXvVE7fsV23qG7EDcQXWVyGXN6it1IaJDVob1yKEq5ldQXirHa4dcLibe6GXuQ2gcgeFGXSPEAkfm(uNsTnehEi1s6Pmgzqngjke6fsVN6uQTH4UxNGAmspO8Lb1yKOqOxbHE91R9ne42QrtgjrbPAmYxuLaDYu)7qC3RSJ96xVqRxbHETVHa3wnAYijkivJr(IQeOtQdttI7ELDSx)6fA96Txi96WiJr(6aKEh396euJPx)7f)aJv2xOem2964Udqc8bHcUhe6GXuQ2gcgeFGXk7lucg7UzOgcmMn1ttPGXdfgYjsTnuVq691bi98VSi5JKWf1RF9Ih(1lUPxhgzmYxhG076nIEhYsR01lKEvmjteXo2lKEjMPWCeVsPMacgZaKzi5Rdq6DGqbpWhek4pqOdgtPABiyq8bgRSVqjyScRyFDssNhDSaJzt90ukySy9(f7yLa7fsVI1RY(cLCfwX(6KKop6yjHvlfiXRugmfqrFVcc9cJEUcRyFDssNhDSKWQLcK4Uxzh71)EHwVq6fg9CfwX(6KKop6yjHvlfiXhYsR01R)9cnWygGmdjFDasVdek4b(GqjsbHoymLQTHGbXhySY(cLGXwiugQHaJzt90uky8qHHCIuBd1lKEFDasp)lls(ijCr96xV(6fp8R3i61xVomYyKVoaP3XDVoHAOEbq9Ihhx96TxV9c1EDyKXiFDasVR3i6DilTsxVq61xVmeYaJ8KCMkRKXhsHbSxi96R3tDk12qCgkprhjjm5amz9ki0ldHmWipjNHYt0rs(IiPdRM6D8Huya7vqOxX6LHoPuZNNfqrVmOuVE7vqOxhgzmYxhG074UxNqnuV(3RVEXVEbq96Rx86nIEF1q5ZFpvkTqO0XPuTneCVE71BVcc96RxIzkmhXRu6qgD6vqOxF9smtH5iELsB0lQxbHEjMPWCeVsP5M60R3EH0Ry9(QHYN7qxJefKVisgqd5EoLQTHG7vqOx7BiWXMYcnWLAK6W0SysSRXPd)unxQx)o0Bu4cNE92lKE91RdJmg5Rdq6DC3RtOgQx)7fpC6fa1RVEXR3i69vdLp)9uP0cHshNs12qW96TxV9cPx19JAKyip00RF9IlC6f30R9ne4UxNGAm8HS0kD9cG6ns61BVq61xVI1R9ne4hReEiyjzHH8qJfLVKsAawaaXVy9ki0lXmfMJ4vkDiJo9ki0Ry9YqNuQ5Zpc4uA2R3EH0RIjzIi2rWygGmdjFDasVdek4b(GqbpCaHoymLQTHGbXhymBQNMsbJvmjteXocgRSVqjyCanmsIcYu)7qGpiuWdpqOdgtPABiyq8bgZM6PPuWy7BiWzQSsg)IbgRSVqjy8ONuIUozyOeaae8bHcErbcDWykvBdbdIpWy2upnLcgFQtP2gIZGLmucxFHYEH0RVETVHa396euJHFX6vqOx19JAKyip00RF9IlC61BVq6vSETVHa3HmUVye)I1lKEfRx7BiWzQSsg)I1lKE91Ry9YqNuQ5ZZcOOxguQxbHEp1PuBdXzO8eDKKWKdWK1RGqVmeYaJ8KCgkprhj5lIKoSAQ3XVy9ki0BLpnyiJ(eSmuaf9YHS0kD96FVrHtVr0RVEzOe(wphBiw5iPAkGPfLp)llsEQMl1R3E9cgRSVqjymJmK7l1ivtbmTO8bFqOGh0aHoymLQTHGbXhymBQNMsbJp1PuBdXzWsgkHRVqzVq61xV23qG7EDcQXWVy9ki0R6(rnsmKhA61VEXfo96Txi9kwV23qG7qg3xmIFX6fsVI1R9ne4mvwjJFX6fsV(6vSEzOtk185zbu0ldk1RGqVN6uQTH4muEIossyYbyY6vqOxgczGrEsodLNOJK8frshwn174xSEfe6TYNgmKrFcwgkGIE5qwALUE9VxgczGrEsodLNOJK8frshwn174dzPv66nIEJKEfe6TYNgmKrFcwgkGIE5qwALUEfVEXd)HtV(3l0WP3i61xVmucFRNJneRCKunfW0IYN)LfjpvZL61BVEbJv2xOemUsMoP(fkbFqOGh(bcDWykvBdbdIpWy2upnLcgx5tdgYOpbldfqrVCilTsxV(3lE4QxbHE91R9ne4ytzHg4snsDyAwmj2140HFQMl1R)9gfUWPxbHETVHahBkl0axQrQdtZIjXUgNo8t1CPE97qVrHlC61BVq61(gcC3Rtqng(fRxi9YqidmYtYzQSsgFilTsxV(1lUWbmwzFHsWyYcd5HgPnkHbFqOGhUaHoymLQTHGbXhySY(cLGXUNmgDKbJoeymBQNMsbJhkmKtKABOEH07xwK8rs4I61VEXdx9cPxhgzmYxhG074UxNqnuV(3l(1lKEvmjteXo2lKE91R9ne4mvwjJpKLwPRx)6fpC6vqOxX61(gcCMkRKXVy96fmMbiZqYxhG07aHcEGpiuWlsaHoymLQTHGbXhymBQNMsbJjMPWCeVsPMa2lKEvmjteXo2lKETVHahBkl0axQrQdtZIjXUgNo8t1CPE9V3OWfo9cPxF9cJEUcRyFDssNhDSKWQLcK4FXowjWEfe6vSEzOtk185jXgKbnW9ki0RdJmg5Rdq6D96xVr1RxWyL9fkbJd3bqjkijZnjWhek4H7bHoymLQTHGbXhymBQNMsbJTVHahL0lYjXOHryFHs(fRxi96Rx7BiWDVob1y4dfgYjsTnuVcc9QUFuJed5HME9R3ifNE9cgRSVqjyS71jOgd4dcf8WFGqhmMs12qWG4dmMn1ttPGXm0jLA(8Sak6LbL6fsV(69uNsTneNHYt0rsctoatwVcc9YqidmYtYzQSsg)I1RGqV23qGZuzLm(fRxV9cPxgczGrEsodLNOJK8frshwn174dzPv661)EbYG5wQ46fa1lJktV(6vD)OgjgYdn9c1EXfo96Txi9AFdbU71jOgdFilTsxV(3l(bgRSVqjyS71jOgd4dcf8IuqOdgtPABiyq8bgZM6PPuWyg6KsnFEwaf9YGs9cPxF9EQtP2gIZq5j6ijHjhGjRxbHEziKbg5j5mvwjJFX6vqOx7BiWzQSsg)I1R3EH0ldHmWipjNHYt0rs(IiPdRM6D8HS0kD96FVrsVq61(gcC3Rtqng(fRxi9smtH5iELsnbemwzFHsWy3RJ7oajWhekrHdi0bJPuTnemi(aJzt90ukyS9ne4OKErojZq6iplxHs(fRxbHE91Ry96EDc1qCftYerSJ9ki0RVETVHaNPYkz8HS0kD96FV4Qxi9AFdbotLvY4xSEfe61xV23qGp6jLORtggkbaa5dzPv661)EbYG5wQ46fa1lJktV(6vD)OgjgYdn9c1EHgo96Txi9AFdb(ONuIUozyOeaaKFX61BVE7fsVN6uQTH4UxNGAmspO8Lb1yKOqOxi96WiJr(6aKEh396euJPx)7fA96Txi96RxX6DUjfqdqI)Lf5bnPeEi1YUsyA4uKFlmmcUxbHEDyKXiFDasVJ7EDcQX0R)9cTE9cgRSVqjyS71XDhGe4dcLOWde6GXuQ2gcgeFGXSPEAkfm2xVeZuyoIxPuta7fsVmeYaJ8KCMkRKXhYsR01RF9IlC6vqOxF9YePdqY17HEJQxi9oetKoaj5xwuV(3lU61BVcc9YePdqY17HEHwVE7fsVkMKjIyhbJv2xOemojpslekbFqOevuGqhmMs12qWG4dmMn1ttPGX(6LyMcZr8kLAcyVq6LHqgyKNKZuzLm(qwALUE9RxCHtVcc96RxMiDasUEp0Bu9cP3HyI0bij)YI61)EXvVE7vqOxMiDasUEp0l061BVq6vXKmre7iySY(cLGXIutqAHqj4dcLOGgi0bJPuTnemi(aJzt90ukySVEjMPWCeVsPMa2lKEziKbg5j5mvwjJpKLwPRx)6fx40RGqV(6LjshGKR3d9gvVq6DiMiDasYVSOE9VxC1R3Efe6LjshGKR3d9cTE92lKEvmjteXocgRSVqjyC4AmslekbFqOef(bcDWyL9fkbJ9OZuOrIcsYCtcmMs12qWG4d8bHsu4ce6GXuQ2gcgeFGXimWyh9GXk7lucgFQtP2gcm(unxcm2HrgJ81bi9oU71jud1RF9IF9grVbdcn96Rxl190aO8unxQxO2Bu40R3EJO3GbHME91R9ne4Uxh3DassYcd5HglkFPdz0H7ELDSxO2l(1RxW4tDKPArGXUxNqnKSsPdz0b8bHsurci0bJPuTnemi(aJzt90ukymXmfMJ4MBQJmjX99ki0lXmfMJ4AcOmjX99cP3tDk12q8YjzgspPEfe61(gcCIzkmhjDiJo8HS0kD96FVk7luYDVoHAiojoIDFs(Lf1lKETVHaNyMcZrshYOd)I1RGqVeZuyoIxP0Hm60lKEfR3tDk12qC3RtOgswP0Hm60RGqV23qGZuzLm(qwALUE9VxL9fk5UxNqneNehXUpj)YI6fsVI17PoLABiE5KmdPNuVq61(gcCMkRKXhYsR01R)9sIJy3NKFzr9cPx7BiWzQSsg)I1RGqV23qGp6jLORtggkbaa5xSEH0RdJmgPi19uV(1lo8iPxi96RxhgzmYxhG0761)d9cTEfe6vSEF1q5ZDORrIcYxejdOHCpNs12qW96TxbHEfR3tDk12q8YjzgspPEH0R9ne4mvwjJpKLwPRx)6LehXUpj)YIaJv2xOem2ZOViWhekrH7bHoySY(cLGXUxNqneymLQTHGbXh4dcLOWFGqhmMs12qWG4dmwzFHsW45MsL9fkLMY9GXMY9YuTiW4GAmVO5c(GpyCqnMx0CbHoiuWde6GXuQ2gcgeFGXSPEAkfmwSENBsb0aK42QrtgjrbPAmYxuLaDCkYVfggbdgRSVqjyS71XDhGe4dcLOaHoymLQTHGbXhySY(cLGXUBgQHaJzt90ukymm65wiugQH4dzPv661VEhYsR0bgZaKzi5Rdq6DGqbpWhekqde6GXk7lucgBHqzOgcmMs12qWG4d8bFWy3dcDqOGhi0bJPuTnemi(aJv2xOemwHvSVojPZJowGXSPEAkfmwSEHrpxHvSVojPZJowsy1sbs8VyhReyVq6vSEv2xOKRWk2xNK05rhljSAPajELYGPak67fsV(6vSEHrpxHvSVojPZJowsrKA4FXowjWEfe6fg9CfwX(6KKop6yjfrQHpKLwPRx)6fx96TxbHEHrpxHvSVojPZJowsy1sbsC3RSJ96FVqRxi9cJEUcRyFDssNhDSKWQLcK4dzPv661)EHwVq6fg9CfwX(6KKop6yjHvlfiX)IDSsGGXmazgs(6aKEhiuWd8bHsuGqhmMs12qWG4dmMn1ttPGX(69uNsTneNHYt0rsctoatwVq6vSEziKbg5j5mvwjJpKcdyVcc9AFdbotLvY4xSE92lKEv3pQrIH8qtV(3l(HtVq61xV23qGtmtH5iP5M6WhYsR01RF9Iho9ki0R9ne4eZuyos6qgD4dzPv661VEXdNE92RGqVHcOOxoKLwPRx)7fpCaJv2xOemMHYt0rs(IiPdRM6DGpiuGgi0bJPuTnemi(aJryGXo6bJv2xOem(uNsTney8PAUeySVETVHaNPYkz8HS0kD96xV4Qxi96Rx7BiWh9Ks01jddLaaG8HS0kD96xV4QxbHEfRx7BiWh9Ks01jddLaaG8lwVE7vqOxX61(gcCMkRKXVy9ki0R6(rnsmKhA61)EHgo96Txi96RxX61(gc8JvcpeSKSWqEOXIYxsjnalaG4xSEfe6vD)OgjgYdn96FVqdNE92lKE91R9ne4eZuyos6qgD4dzPv661VEbYG5wQ46vqOx7BiWjMPWCK0CtD4dzPv661VEbYG5wQ461ly8PoYuTiWyy0lhkYV1qwu(oWhek4hi0bJPuTnemi(aJv2xOem2cHYqneymBQNMsbJhkmKtKABOEH07Rdq65FzrYhjHlQx)6fVO6fsV(6vXKmre7yVq69uNsTnehg9YHI8BnKfLVRxVGXmazgs(6aKEhiuWd8bHcUaHoymLQTHGbXhySY(cLGXUBgQHaJzt90uky8qHHCIuBd1lKEFDasp)lls(ijCr96xV4fvVq61xVkMKjIyh7fsVN6uQTH4WOxouKFRHSO8D96fmMbiZqYxhG07aHcEGpiuIeqOdgtPABiyq8bgRSVqjyS7jJrhzWOdbgZM6PPuW4Hcd5eP2gQxi9(6aKE(xwK8rs4I61VEXls6fsV(6vXKmre7yVq69uNsTnehg9YHI8BnKfLVRxVGXmazgs(6aKEhiuWd8bHcUhe6GXuQ2gcgeFGXSPEAkfmwXKmre7iySY(cLGXb0Wijkit9Vdb(Gqb)bcDWykvBdbdIpWy2upnLcgBFdbotLvY4xmWyL9fkbJh9Ks01jddLaaGGpiuIuqOdgtPABiyq8bgZM6PPuWyF96Rx7BiWjMPWCK0Hm6WhYsR01RF9Iho9ki0R9ne4eZuyosAUPo8HS0kD96xV4HtVE7fsVmeYaJ8KCMkRKXhYsR01RF9cnC6fsV(61(gcCSPSqdCPgPomnlMe7AC6WpvZL61)EJc)WPxbHEfR35Muanajo2uwObUuJuhMMftIDnoD4uKFlmmcUxV96TxbHETVHahBkl0axQrQdtZIjXUgNo8t1CPE97qVrH7XPxbHEziKbg5j5mvwjJpKcdyVq61xVQ7h1iXqEOPx)6nsXPxbHEp1PuBdXlNuruVEbJv2xOemMSWqEOrAJsyWhek4Hdi0bJPuTnemi(aJzt90uky8PoLABiodwYqjC9fk7fsV(6vD)OgjgYdn96xVrko9cPxF9AFdb(XkHhcwswyip0yr5lPKgGfaq8lwVcc9kwVm0jLA(8JaoLM96TxbHEzOtk185zbu0ldk1RGqVN6uQTH4LtQiQxbHETVHa32GqWMR75xSEH0R9ne42gec2CDpFilTsxV(3Bu40Be96RxF9gP9cG6DUjfqdqIJnLfAGl1i1HPzXKyxJthof53cdJG71BVr0RVEzOe(wphBiw5iPAkGPfLp)llsEQMl1R3E92R3EH0Ry9AFdbotLvY4xSEH0RVEfRxg6KsnFEwaf9YGs9ki0ldHmWipjNHYt0rs(IiPdRM6D8lwVcc9w5tdgYOpbldfqrVCilTsxV(3ldHmWipjNHYt0rs(IiPdRM6D8HS0kD9grVrsVcc9w5tdgYOpbldfqrVCilTsxVIxV4H)WPx)7nkC6nIE91ldLW365ydXkhjvtbmTO85FzrYt1CPE92RxWyL9fkbJzKHCFPgPAkGPfLp4dcf8Wde6GXuQ2gcgeFGXSPEAkfm(uNsTneNblzOeU(cL9cPxF9QUFuJed5HME9R3ifNEH0RVETVHa)yLWdbljlmKhASO8LusdWcai(fRxbHEfRxg6KsnF(raNsZE92RGqVm0jLA(8Sak6LbL6vqO3tDk12q8Yjve1RGqV23qGBBqiyZ198lwVq61(gcCBdcbBUUNpKLwPRx)7fA40Be96RxF9gP9cG6DUjfqdqIJnLfAGl1i1HPzXKyxJthof53cdJG71BVr0RVEzOe(wphBiw5iPAkGPfLp)llsEQMl1R3E92R3EH0Ry9AFdbotLvY4xSEH0RVEfRxg6KsnFEwaf9YGs9ki0ldHmWipjNHYt0rs(IiPdRM6D8lwVcc9w5tdgYOpbldfqrVCilTsxV(3ldHmWipjNHYt0rs(IiPdRM6D8HS0kD9grVrsVcc9w5tdgYOpbldfqrVCilTsxVIxV4H)WPx)7fA40Be96RxgkHV1ZXgIvosQMcyAr5Z)YIKNQ5s96TxVGXk7lucgxjtNu)cLGpiuWlkqOdgtPABiyq8bgJWaJD0dgRSVqjy8PoLABiW4t1CjWyF9kwVmeYaJ8KCMkRKXhsHbSxbHEfR3tDk12qCgkprhjjm5amz9cPxg6KsnFEwaf9YGs96fm(uhzQweyStpjzansMkRKb(GqbpObcDWykvBdbdIpWy2upnLcgtmtH5iELsnbSxi9QysMiIDSxi9AFdbo2uwObUuJuhMMftIDnoD4NQ5s96FVrHF40lKE91lm65kSI91jjDE0XscRwkqI)f7yLa7vqOxX6LHoPuZNNeBqg0a3R3EH07PoLABiUtpjzansMkRKbgRSVqjyC4oakrbjzUjb(Gqbp8de6GXuQ2gcgeFGXSPEAkfm2(gcCusViNeJggH9fk5xSEH0R9ne4UxNGAm8Hcd5eP2gcmwzFHsWy3RtqngWhek4HlqOdgtPABiyq8bgZM6PPuWy7BiWDVog0aZhYsR01R)9IREH0RVETVHaNyMcZrshYOdFilTsxV(1lU6vqOx7BiWjMPWCK0CtD4dzPv661VEXvVE7fsVQ7h1iXqEOPx)6nsXbmwzFHsWyMMmYiTVHayS9neKPArGXUxhdAGbFqOGxKacDWykvBdbdIpWy2upnLcg)QHYN7EYy0rcpv45uQ2gcUxi96O)ReOJ7qgKeEQW3lKETVHa396euJHdJ8KGXk7lucg7EDcQXa(GqbpCpi0bJPuTnemi(aJzt90ukymdDsPMpplGIEzqPEH07PoLABiodLNOJKeMCaMSEH0ldHmWipjNHYt0rs(IiPdRM6D8HS0kD96FV4cmwzFHsWy3RJ7oajWhek4H)aHoymLQTHGbXhymBQNMsbJF1q5ZDpzm6iHNk8CkvBdb3lKEfR3xnu(C3RJbnWCkvBdb3lKETVHa396euJHpuyiNi12q9cPxF9AFdboXmfMJKMBQdFilTsxV(1BK0lKEjMPWCeVsP5M60lKETVHahBkl0axQrQdtZIjXUgNo8t1CPE9V3OWfo9ki0R9ne4ytzHg4snsDyAwmj2140HFQMl1RFh6nkCHtVq6vD)OgjgYdn96xVrko9ki0lm65kSI91jjDE0XscRwkqIpKLwPRx)6f)1RGqVk7luYvyf7Rts68OJLewTuGeVszWuaf996Txi9kwVmeYaJ8KCMkRKXhsHbemwzFHsWy3RtqngWhek4fPGqhmMs12qWG4dmMn1ttPGX23qGJs6f5KmdPJ8SCfk5xSEfe61(gc8JvcpeSKSWqEOXIYxsjnalaG4xSEfe61(gcCMkRKXVy9cPxF9AFdb(ONuIUozyOeaaKpKLwPRx)7fidMBPIRxauVmQm96Rx19JAKyip00lu7fA40R3EH0R9ne4JEsj66KHHsaaq(fRxbHEfRx7BiWh9Ks01jddLaaG8lwVq6vSEziKbg5j5JEsj66KHHsaaq(qkmG9ki0Ry9YqNuQ5ZpP8fb40R3Efe6vD)OgjgYdn96xVrko9cPxIzkmhXRuQjGGXk7lucg7EDC3bib(GqjkCaHoymLQTHGbXhymBQNMsbJF1q5ZDVog0aZPuTneCVq61xV23qG7EDmObMFX6vqOx19JAKyip00RF9gP40R3EH0R9ne4UxhdAG5Uxzh71)EHwVq61xV23qGtmtH5iPdz0HFX6vqOx7BiWjMPWCK0CtD4xSE92lKETVHahBkl0axQrQdtZIjXUgNo8t1CPE9V3OW940lKE91ldHmWipjNPYkz8HS0kD96xV4HtVcc9kwVN6uQTH4muEIossyYbyY6fsVm0jLA(8Sak6LbL61lySY(cLGXUxh3DasGpiuIcpqOdgtPABiyq8bgZM6PPuWyF9AFdbo2uwObUuJuhMMftIDnoD4NQ5s96FVrH7XPxbHETVHahBkl0axQrQdtZIjXUgNo8t1CPE9V3OWfo9cP3xnu(C3tgJos4PcpNs12qW96Txi9AFdboXmfMJKoKrh(qwALUE9RxCFVq6LyMcZr8kLoKrNEH0Ry9AFdbokPxKtIrdJW(cL8lwVq6vSEF1q5ZDVog0aZPuTneCVq6LHqgyKNKZuzLm(qwALUE9RxCFVq61xVmeYaJ8KCYcd5HgPnkH5dzPv661VEX99ki0Ry9YqNuQ5Zpc4uA2RxWyL9fkbJDVoU7aKaFqOevuGqhmMs12qWG4dmMn1ttPGX(61(gcCIzkmhjn3uh(fRxbHE91ltKoajxVh6nQEH07qmr6aKKFzr96FV4QxV9ki0ltKoajxVh6fA96Txi9QysMiIDSxi9EQtP2gI70tsgqJKPYkzGXk7lucgNKhPfcLGpiuIcAGqhmMs12qWG4dmMn1ttPGX(61(gcCIzkmhjn3uh(fRxi9kwVm0jLA(8JaoLM9ki0RVETVHa)yLWdbljlmKhASO8LusdWcai(fRxi9YqNuQ5Zpc4uA2R3Efe61xVmr6aKC9EO3O6fsVdXePdqs(Lf1R)9IRE92RGqVmr6aKC9EOxO1RGqV23qGZuzLm(fRxV9cPxftYerSJ9cP3tDk12qCNEsYaAKmvwjdmwzFHsWyrQjiTqOe8bHsu4hi0bJPuTnemi(aJzt90ukySVETVHaNyMcZrsZn1HFX6fsVI1ldDsPMp)iGtPzVcc96Rx7BiWpwj8qWsYcd5HglkFjL0aSaaIFX6fsVm0jLA(8JaoLM96TxbHE91ltKoajxVh6nQEH07qmr6aKKFzr96FV4QxV9ki0ltKoajxVh6fA9ki0R9ne4mvwjJFX61BVq6vXKmre7yVq69uNsTne3PNKmGgjtLvYaJv2xOemoCngPfcLGpiuIcxGqhmwzFHsWyp6mfAKOGKm3KaJPuTnemi(aFqOevKacDWykvBdbdIpWy2upnLcgtmtH5iELsZn1PxbHEjMPWCe3Hm6itsCFVcc9smtH5iUMaktsCFVcc9AFdbUhDMcnsuqsMBs8lwVq61(gcCIzkmhjn3uh(fRxbHE91R9ne4mvwjJpKLwPRx)7vzFHsUNrFrCsCe7(K8llQxi9AFdbotLvY4xSE9cgRSVqjyS71judb(GqjkCpi0bJv2xOem2ZOViWykvBdbdIpWhekrH)aHoymLQTHGbXhySY(cLGXZnLk7luknL7bJnL7LPArGXb1yErZf8bFWyBK(Gqhek4bcDWykvBdbdIpWy2upnLcgBFdbotLvY4xmWyL9fkbJh9Ks01jddLaaGGpiuIce6GXuQ2gcgeFGXimWyh9GXk7lucgFQtP2gcm(unxcmwSETVHa3wnAYijkivJr(IQeOtM6FhIFX6fsVI1R9ne42QrtgjrbPAmYxuLaDsDyAs8lgy8PoYuTiWy2uFI(lg4dcfObcDWykvBdbdIpWyL9fkbJvyf7Rts68OJfymBQNMsbJTVHa3wnAYijkivJr(IQeOtM6FhI7ELDSx)7f)6fsV23qGBRgnzKefKQXiFrvc0j1HPjXDVYo2R)9IF9cPxF9kwVWONRWk2xNK05rhljSAPaj(xSJvcSxi9kwVk7luYvyf7Rts68OJLewTuGeVszWuaf99cPxF9kwVWONRWk2xNK05rhlPisn8VyhReyVcc9cJEUcRyFDssNhDSKIi1WhYsR01RF9cTE92RGqVWONRWk2xNK05rhljSAPajU7v2XE9VxO1lKEHrpxHvSVojPZJowsy1sbs8HS0kD96FV4Qxi9cJEUcRyFDssNhDSKWQLcK4FXowjWE9cgZaKzi5Rdq6DGqbpWhek4hi0bJPuTnemi(aJzt90ukySVEp1PuBdXzO8eDKKWKdWK1lKEfRxgczGrEsotLvY4dPWa2RGqV23qGZuzLm(fRxV9cPxF9AFdbUTA0KrsuqQgJ8fvjqNm1)oe39k7yVh6fx9ki0R9ne42QrtgjrbPAmYxuLaDsDyAsC3RSJ9EOxC1R3Efe6nuaf9YHS0kD96FV4HdySY(cLGXmuEIosYxejDy1uVd8bHcUaHoymLQTHGbXhymBQNMsbJ91R9ne42QrtgjrbPAmYxuLaDYu)7q8HS0kD96xV4hhx9ki0R9ne42QrtgjrbPAmYxuLaDsDyAs8HS0kD96xV4hhx96Txi9QUFuJed5HME97qVrko9cPxF9YqidmYtYzQSsgFilTsxV(1lUVxbHE91ldHmWipjNSWqEOrAJsy(qwALUE9RxCFVq6vSETVHa)yLWdbljlmKhASO8LusdWcai(fRxi9YqNuQ5Zpc4uA2R3E9cgRSVqjymttgzK23qam2(gcYuTiWy3RJbnWGpiuIeqOdgtPABiyq8bgZM6PPuWyX69uNsTneNn1NO)I1lKE91ldDsPMpplGIEzqPEfe6LHqgyKNKZuzLm(qwALUE9RxCFVcc9kwVN6uQTH4myjdLW1xOSxi9kwVm0jLA(8JaoLM9ki0RVEziKbg5j5KfgYdnsBucZhYsR01RF9I77fsVI1R9ne4hReEiyjzHH8qJfLVKsAawaaXVy9cPxg6KsnF(raNsZE92RxWyL9fkbJDVoU7aKaFqOG7bHoymLQTHGbXhymBQNMsbJ91ldHmWipjNHYt0rs(IiPdRM6D8HS0kD96FV4Qxi96R3tDk12qCgkprhjjm5amz9ki0ldHmWipjNPYkz8HS0kD96FV4QxV96Txi9QUFuJed5HME9Rx8dNEH0ldDsPMpplGIEzqjWyL9fkbJDVoU7aKaFqOG)aHoymLQTHGbXhySY(cLGXUBgQHaJzt90uky8qHHCIuBd1lKEFDasp)lls(ijCr96xV4fj9cPxF9QysMiIDSxi96R3tDk12qC2uFI(lwVcc96Rx19JAKyip00R)9cnC6fsVI1R9ne4mvwjJFX61BVcc9YqidmYtYzQSsgFifgWE92RxWygGmdjFDasVdek4b(GqjsbHoymLQTHGbXhySY(cLGXwiugQHaJzt90uky8qHHCIuBd1lKEFDasp)lls(ijCr96xV4bnoU6fsV(6vXKmre7yVq61xVN6uQTH4SP(e9xSEfe61xVQ7h1iXqEOPx)7fA40lKEfRx7BiWzQSsg)I1R3Efe6LHqgyKNKZuzLm(qkmG96Txi9kwV23qGFSs4HGLKfgYdnwu(skPbybae)I1RxWygGmdjFDasVdek4b(GqbpCaHoymLQTHGbXhySY(cLGXUNmgDKbJoeymBQNMsbJhkmKtKABOEH07Rdq65FzrYhjHlQx)6fViP3i6DilTsxVq61xVkMKjIyh7fsV(69uNsTneNn1NO)I1RGqVQ7h1iXqEOPx)7fA40RGqVmeYaJ8KCMkRKXhsHbSxV96fmMbiZqYxhG07aHcEGpiuWdpqOdgtPABiyq8bgZM6PPuWyftYerSJGXk7lucghqdJKOGm1)oe4dcf8Ice6GXuQ2gcgeFGXSPEAkfm2xVeZuyoIxPuta7vqOxIzkmhXDiJoYkL41RGqVeZuyoIBUPoYkL41R3EH0RVEfRxg6KsnFEwaf9YGs9ki0RVEv3pQrIH8qtV(3BKIREH0RVEp1PuBdXzt9j6Vy9ki0R6(rnsmKhA61)EHgo9ki07PoLABiE5KkI61BVq61xVN6uQTH4muEIossyYbyY6fsVI1ldHmWipjNHYt0rs(IiPdRM6D8lwVcc9kwVN6uQTH4muEIossyYbyY6fsVI1ldHmWipjNPYkz8lwVE71BVE7fsV(6LHqgyKNKZuzLm(qwALUE9RxOHtVcc9QUFuJed5HME9R3ifNEH0ldHmWipjNPYkz8lwVq61xVmeYaJ8KCYcd5HgPnkH5dzPv661)Ev2xOK7EDc1qCsCe7(K8llQxbHEfRxg6KsnF(raNsZE92RGqVv(0GHm6tWYqbu0lhYsR01R)9Iho96Txi96Rxy0Zvyf7Rts68OJLewTuGeFilTsxV(1l(1RGqVI1ldDsPMppj2GmObUxVGXk7lucghUdGsuqsMBsGpiuWdAGqhmMs12qWG4dmMn1ttPGX(6LyMcZrCZn1rMK4(Efe6LyMcZrChYOJmjX99ki0lXmfMJ4AcOmjX99ki0R9ne42QrtgjrbPAmYxuLaDYu)7q8HS0kD96xV4hhx9ki0R9ne42QrtgjrbPAmYxuLaDsDyAs8HS0kD96xV4hhx9ki0R6(rnsmKhA61VEJuC6fsVmeYaJ8KCMkRKXhsHbSxV9cPxF9YqidmYtYzQSsgFilTsxV(1l0WPxbHEziKbg5j5mvwjJpKcdyVE7vqO3kFAWqg9jyzOak6LdzPv661)EXdhWyL9fkbJjlmKhAK2Oeg8bHcE4hi0bJPuTnemi(aJzt90uky8PoLABiodwYqjC9fk7fsV(6vD)OgjgYdn96xVrko9cPxF9AFdb(XkHhcwswyip0yr5lPKgGfaq8lwVcc9kwVm0jLA(8JaoLM96TxbHEzOtk185zbu0ldk1RGqV23qGBBqiyZ198lwVq61(gcCBdcbBUUNpKLwPRx)7nkC6nIE91ldLW365ydXkhjvtbmTO85FzrYt1CPE92R3EH0RVEp1PuBdXzO8eDKKWKdWK1RGqVmeYaJ8KCgkprhj5lIKoSAQ3XhsHbSxV9ki0BLpnyiJ(eSmuaf9YHS0kD96FVrHtVr0RVEzOe(wphBiw5iPAkGPfLp)llsEQMl1RxWyL9fkbJzKHCFPgPAkGPfLp4dcf8Wfi0bJPuTnemi(aJzt90uky8PoLABiodwYqjC9fk7fsV(6vD)OgjgYdn96xVrko9cPxF9AFdb(XkHhcwswyip0yr5lPKgGfaq8lwVcc9kwVm0jLA(8JaoLM96TxbHEzOtk185zbu0ldk1RGqV23qGBBqiyZ198lwVq61(gcCBdcbBUUNpKLwPRx)7fA40Be96RxgkHV1ZXgIvosQMcyAr5Z)YIKNQ5s96TxV9cPxF9EQtP2gIZq5j6ijHjhGjRxbHEziKbg5j5muEIosYxejDy1uVJpKcdyVE7vqO3kFAWqg9jyzOak6LdzPv661)EHgo9grV(6LHs4B9CSHyLJKQPaMwu(8VSi5PAUuVEbJv2xOemUsMoP(fkbFqOGxKacDWykvBdbdIpWyegySJEWyL9fkbJp1PuBdbgFQMlbgtmtH5iELsZn1PxauV4VEHAVk7luYDVoHAiojoIDFs(Lf1Be9kwVeZuyoIxP0CtD6fa1BK0lu7vzFHsUNrFrCsCe7(K8llQ3i6fhEu9c1EDyKXifPUNaJp1rMQfbgRomXV0etmWhek4H7bHoymLQTHGbXhymBQNMsbJ91BLpnyiJ(eSmuaf9YHS0kD96FV4xVcc96Rx7BiWh9Ks01jddLaaG8HS0kD96FVazWClvC9cG6LrLPxF9QUFuJed5HMEHAVqdNE92lKETVHaF0tkrxNmmucaaYVy96TxV9ki0RVEv3pQrIH8qtVr07PoLABiU6We)stmX6fa1R9ne4eZuyos6qgD4dzPv66nIEHrppChaLOGKm3K4FXo6KdzPv2laQ3O44Qx)6fVOWPxbHEv3pQrIH8qtVr07PoLABiU6We)stmX6fa1R9ne4eZuyosAUPo8HS0kD9grVWONhUdGsuqsMBs8VyhDYHS0k7fa1BuCC1RF9Ixu40R3EH0lXmfMJ4vk1eWEH0RVE91Ry9YqidmYtYzQSsg)I1RGqVm0jLA(8JaoLM9cPxX6LHqgyKNKtwyip0iTrjm)I1R3Efe6LHoPuZNNfqrVmOuVE7fsV(6vSEzOtk185Nu(IaC6vqOxX61(gcCMkRKXVy9ki0R6(rnsmKhA61VEJuC61BVcc9AFdbotLvY4dzPv661VEXF9cPxX61(gc8rpPeDDYWqjaai)IbgRSVqjyS71XDhGe4dcf8WFGqhmMs12qWG4dmMn1ttPGX(61(gcCIzkmhjn3uh(fRxbHE91ltKoajxVh6nQEH07qmr6aKKFzr96FV4QxV9ki0ltKoajxVh6fA96Txi9QysMiIDemwzFHsW4K8iTqOe8bHcErki0bJPuTnemi(aJzt90ukySVETVHaNyMcZrsZn1HFX6vqOxF9YePdqY17HEJQxi9oetKoaj5xwuV(3lU61BVcc9YePdqY17HEHwVE7fsVkMKjIyhbJv2xOemwKAcslekbFqOefoGqhmMs12qWG4dmMn1ttPGX(61(gcCIzkmhjn3uh(fRxbHE91ltKoajxVh6nQEH07qmr6aKKFzr96FV4QxV9ki0ltKoajxVh6fA96Txi9QysMiIDemwzFHsW4W1yKwiuc(Gqjk8aHoySY(cLGXE0zk0irbjzUjbgtPABiyq8b(GqjQOaHoymLQTHGbXhymBQNMsbJjMPWCeVsP5M60RGqVeZuyoI7qgDKjjUVxbHEjMPWCextaLjjUVxbHETVHa3JotHgjkijZnj(fRxi9AFdboXmfMJKMBQd)I1RGqV(61(gcCMkRKXhYsR01R)9QSVqj3ZOViojoIDFs(Lf1lKETVHaNPYkz8lwVEbJv2xOem296eQHaFqOef0aHoySY(cLGXEg9fbgtPABiyq8b(Gqjk8de6GXuQ2gcgeFGXk7lucgp3uQSVqP0uUhm2uUxMQfbghuJ5fnxWh8bFW4tACfkbHsu4efo4ffErcyShDYkb6aJX)I)J)bk42GI4pXxV9cDruVLfgA(EdOPxCh8qQLDLW0G76DOi)wdb3Rdzr9Q3hzPpb3ltKMajhVJgaxj1BuIVEJmuEsZtW9gxwrwVoaZxfxVIxVpQxa8v7fUolxHYEry0OpA61hu92Rp8eNxEhnaUsQx8Wt81BKHYtAEcU34YkY61by(Q46v8eVEFuVa4R2Rfc(AUUEry0OpA61N45TxF4joV8oAaCLuV4fL4R3idLN08eCVXLvK1RdW8vX1R4jE9(OEbWxTxle81CD9IWOrF00RpXZBV(WtCE5D0a4kPEXdxIVEJmuEsZtW9gxwrwVoaZxfxVIxVpQxa8v7fUolxHYEry0OpA61hu92Rp8eNxEhDhn(x8F8pqb3gue)j(6TxOlI6TSWqZ3Ban9I7GPGEnpUR3HI8BneCVoKf1REFKL(eCVmrAcKC8oAaCLuVrI4R3idLN08eCVXLvK1RdW8vX1R417J6faF1EHRZYvOSxegn6JME9bvV96lkX5L3rdGRK6fp8eF9gzO8KMNG7f3n3KcObiXXTJ769r9I7MBsb0aK4425uQ2gcg31RVOeNxEhDhn(x8F8pqb3gue)j(6TxOlI6TSWqZ3Ban9I7WgIHSS1h317qr(TgcUxhYI6vVpYsFcUxMinbsoEhnaUsQxCj(6nYq5jnpb3lUBUjfqdqIJBh317J6f3n3KcObiXXTZPuTnemURxF4joV8oAaCLuVrI4R3idLN08eCV4U5MuanajoUDCxVpQxC3CtkGgGeh3oNs12qW4UE9HN48Y7O7OX)I)J)bk42GI4pXxV9cDruVLfgA(EdOPxCNIiCxVdf53Ai4EDilQx9(il9j4EzI0ei54D0a4kPEJs81BKHYtAEcUxC3CtkGgGeh3oUR3h1lUBUjfqdqIJBNtPABiyCxV(WtCE5D0a4kPEHM4R3idLN08eCVXLvK1RdW8vX1R4jE9(OEbWxTxle81CD9IWOrF00RpXZBV(WtCE5D0a4kPEXL4R3idLN08eCVXLvK1RdW8vX1R417J6faF1EHRZYvOSxegn6JME9bvV96dpX5L3rdGRK6nsfF9gzO8KMNG7nUSISEDaMVkUEfVEFuVa4R2lCDwUcL9IWOrF00RpO6TxF4joV8oAaCLuV4bnXxVrgkpP5j4EJlRiRxhG5RIRxXt869r9cGVAVwi4R566fHrJ(OPxFIN3E9HN48Y7ObWvs9Ih(t81BKHYtAEcU34YkY61by(Q46v869r9cGVAVW1z5ku2lcJg9rtV(GQ3E9HN48Y7ObWvs9gfoIVEJmuEsZtW9gxwrwVoaZxfxVIxVpQxa8v7fUolxHYEry0OpA61hu92Rp8eNxEhnaUsQ3OWL4R3idLN08eCVXLvK1RdW8vX1R417J6faF1EHRZYvOSxegn6JME9bvV96lkX5L3r3rJ)f)h)duWTbfXFIVE7f6IOEllm089gqtV4o3J76DOi)wdb3Rdzr9Q3hzPpb3ltKMajhVJgaxj1lE4i(6nYq5jnpb3BCzfz96amFvC9kEIxVpQxa8v71cbFnxxVimA0hn96t882Rp8eNxEhnaUsQx8Wt81BKHYtAEcU34YkY61by(Q46v8eVEFuVa4R2Rfc(AUUEry0OpA61N45TxF4joV8oAaCLuV4fPIVEJmuEsZtW9gxwrwVoaZxfxVIxVpQxa8v7fUolxHYEry0OpA61hu92Rp8eNxEhDhn(x8F8pqb3gue)j(6TxOlI6TSWqZ3Ban9I7Sr6J76DOi)wdb3Rdzr9Q3hzPpb3ltKMajhVJgaxj1lErI4R3idLN08eCVXLvK1RdW8vX1R417J6faF1EHRZYvOSxegn6JME9bvV96dAIZlVJgaxj1lE4EXxVrgkpP5j4EJlRiRxhG5RIRxXR3h1la(Q9cxNLRqzVimA0hn96dQE71hEIZlVJUJg3MfgAEcUxCFVk7lu2RPCVJ3rdg7WigiuWdNOaJXguOmeymUvV4tnAYOEf)yUfChnUvVIFqmYYMMEJcha2Bu4efoD0D04w9gzI0ei5eFD04w9IB6f)hgMG7ngz0Px8rQfVJg3QxCtVrMinbsW9(6aKEzf6LPoY17J6LbiZqYxhG074D04w9IB6f)dzHoj4EVzsmY50bWEp1PuBd561xXjoa7fBOtP71XDhGuV4g)6fBOtU71XDhGKxEhnUvV4MEX)prfCVydXu3xjWEX)o6lQ3k0B94oxVViQxpdkb2R4NmtH5iEhnUvV4MEf)tps9gzO8eDK69fr9gJvt9UE1En1)gQxl0q9gmK4kBd1RVk0lGOBVIu4e399kQ(ERVxxzDnVMe66ma2RN6f1l(e)h)h69grVrgzi3xQPx8FtbmTO8byV1J7G71DSW8Y7O7Ov2xO0XXgIHSS1)GfcLhRugqJvhTY(cLoo2qmKLT(rCaQhReEiyPdRM6DD0k7lu64ydXqw26hXbO6z0xeanvssg8b8WbGv4GpIzkmhXn3uhzsI7feiMPWCeVsP5M6iiqmtH5iELsB0lsqGyMcZrCnbuMK4EVD0k7lu64ydXqw26hXbO6z0xeaRWbFeZuyoIBUPoYKe3liqmtH5iELsZn1rqGyMcZr8kL2OxKGaXmfMJ4AcOmjX9EHGn0jhpUNrFrqedBOtEuCpJ(I6Ov2xO0XXgIHSS1pIdq196eQHayfoi2CtkGgGe3wnAYijkivJr(IQeOtqqmg6KsnFEwaf9YGsccI5WiJr(6aKEh396euJ5aEccI9QHYNN6FhYjTvJMmItPABi4oAL9fkDCSHyilB9J4auDVoU7aKayfom3KcObiXTvJMmsIcs1yKVOkb6GWqNuQ5ZZcOOxgucIdJmg5Rdq6DC3RtqnMd41r3rJB1R4NIJy3NG7LoPbWE)YI69fr9QShn9wUE1tTmQTH4D0k7lu6o4qgDK2KA1rRSVqP7WPoLABiaMQfDOCsfra8unx6GdJmg5Rdq6DC3Rtqng)WdIpXE1q5ZDVog0aZPuTneSGWRgkFU7jJrhj8uHNtPABiyVccomYyKVoaP3XDVob1y8lQoAL9fkDrCaQN6uQTHayQw0HYjzgspjaEQMlDWHrgJ81bi9oU71jud5hED0k7lu6I4auTPXrZXkbcWkCWNym0jLA(8Sak6LbLeeeJHqgyKNKZq5j6ijFrK0Hvt9o(fZle7BiWzQSsg)I1rRSVqPlIdqfd9fkbyfoyFdbotLvY4xSoAL9fkDrCaQN6uQTHayQw0bgkprhjjm5amza8unx6qWGqJpFv(0GHm6tWYqbu0lhYsR0HBIchCddHmWipjNHYt0rs(IiPdRM6D8HS0kDEfp8IchV(fmi04ZxLpnyiJ(eSmuaf9YHS0kD4MOWfUXhE4aGE1q5ZRKPtQFHsoLQTHG9IB8Xqj8TEo2qSYrs1uatlkF(xwK8unxYlUHHqgyKNKZuzLm(qwALoVIhE4pC8kiWqidmYtYzQSsgFilTsNFv(0GHm6tWYqbu0lhYsR0jiWqidmYtYzO8eDKKVis6WQPEhFilTsNFv(0GHm6tWYqbu0lhYsR0jiigdDsPMpplGIEzqPoAL9fkDrCaQN6uQTHayQw0bgSKHs46lucWt1CPd(eJI8BHHrWCYcdWHuJenWPMmsqGHqgyKNKtwyaoKAKObo1Kr8HS0kD(JxKGdeXyiKbg5j5KfgGdPgjAGtnzeFifgqVq8jgf53cdJG5o01yO)ReOCU2akiWqidmYtYDORrwz46kuYhYsR05pE4GdeXyiKbg5j5o01iRmCDfk5dPWa6vqGHoPuZNFeWP0SJwzFHsxehG61rY6jlaMQfDGSWaCi1irdCQjJayfoWqidmYtYzQSsgFilTsN)rHdKtDk12qCgkprhjjm5amzccmeYaJ8KCgkprhj5lIKoSAQ3XhYsR05Fu40rRSVqPlIdq96iz9Kfat1Io4qxJH(VsGY5AdiaRWbgczGrEsotLvY4dzPv68pkCGCQtP2gIZq5j6ijHjhGjtqGHqgyKNKZq5j6ijFrK0Hvt9o(qwALo)JchbbkYVfggbZjlmahsns0aNAYOoAL9fkDrCaQxhjRNSayQw0HkDS5(QTHKr(vZ)AjHPZIraSchSVHaNPYkz8lwhnUvVk7lu6I4auVoswpz5aOZGE3HFQ8i94bWkCqSFQ8i9C84IuNeBqmUMacXNy)u5r65rXfPoj2GyCnbuqqSFQ8i98O4dPWakziKbg5j9kiyFdbotLvY4xmbbgczGrEsotLvY4dzPv6Wn4HJF)u5r654XziKbg5j5W3r)cLqeJHoPuZNFeWP0uqGHoPuZNNfqrVmOeKtDk12qCgkprhjjm5amzqyiKbg5j5muEIosYxejDy1uVJFXeeSVHa)yLWdbljlmKhASO8LusdWcai(ftqiuaf9YHS0kD(hfoD04w9QSVqPlIdq96iz9KLdGod6Dh(PYJ0hfaRWbX(PYJ0ZJIlsDsSbX4AcieFI9tLhPNJhxK6KydIX1eqbbX(PYJ0ZXJpKcdOKHqgyKN0RGWpvEKEoECrQtInigxtaH8tLhPNhfxK6KydIX1eqiI9tLhPNJhFifgqjdHmWipPGG9ne4mvwjJFXeeyiKbg5j5mvwjJpKLwPd3Gho(9tLhPNhfNHqgyKNKdFh9lucrmg6KsnF(raNstbbg6KsnFEwaf9YGsqo1PuBdXzO8eDKKWKdWKbHHqgyKNKZq5j6ijFrK0Hvt9o(ftqW(gc8JvcpeSKSWqEOXIYxsjnalaG4xmbHqbu0lhYsR05Fu40rRSVqPlIdq96iz9KLdGv4G9ne4mvwjJFXeeyiKbg5j5mvwjJpKLwPZp8WbIym0jLA(8JaoLMccm0jLA(8Sak6LbLGCQtP2gIZq5j6ijHjhGjdcdHmWipjNHYt0rs(IiPdRM6D8lgeXyiKbg5j5mvwjJFXG4ZN9ne4eZuyosAUPo8HS0kD(Hhocc23qGtmtH5iPdz0HpKLwPZp8WXleXMBsb0aK42QrtgjrbPAmYxuLaDccZnPaAasCB1OjJKOGung5lQsGoi(SVHa3wnAYijkivJr(IQeOtM6FhI7ELD0pOjiyFdbUTA0KrsuqQgJ8fvjqNuhMMe39k7OFqZRxbb7BiWpwj8qWsYcd5HglkFjL0aSaaIFXeecfqrVCilTsN)rHthTY(cLUioa15MsL9fkLMY9amvl6GIia6(Py)b8ayfoCQtP2gIxoPIOoAL9fkDrCaQZnLk7luknL7byQw0b4Hul7kHPbGUFk2FapawHdZnPaAas8VSipOjLWdPw2vctdNI8BHHrWD0k7lu6I4auNBkv2xOuAk3dWuTOd2i9bO7NI9hWdGv4WCtkGgGe3wnAYijkivJr(IQeOJtr(TWWi4oAL9fkDrCaQZnLk7luknL7byQw0b33r3rRSVqPJRi6WPoLABiaMQfDaEi1s6Pmgzqngjkea4PAU0bF23qG)Lf5bnPeEi1YUsyA4dzPv68hidMBPIlcC44jiyFdb(xwKh0Ks4Hul7kHPHpKLwPZFL9fk5UxNqneNehXUpj)YIIahoEq8rmtH5iELsZn1rqGyMcZrChYOJmjX9cceZuyoIRjGYKe371le7BiW)YI8GMucpKAzxjmn8lgK5Muanaj(xwKh0Ks4Hul7kHPHtr(TWWi4oAL9fkDCfrrCaQmuEIosYxejDy1uVdGv4GVtDk12qCgkprhjjm5amzqeJHqgyKNKZuzLm(qkmGcc23qGZuzLm(fZle19JAKyip04pUWbIp7BiWjMPWCK0CtD4dzPv68lseeSVHaNyMcZrshYOdFilTsNFrIxi(eBUjfqdqIBRgnzKefKQXiFrvc0jiyFdbUTA0KrsuqQgJ8fvjqNm1)oe39k7OFqtqW(gcCB1OjJKOGung5lQsGoPomnjU7v2r)GMxbHqbu0lhYsR05pE40rRSVqPJRikIdq196euJbGv4G9ne4UxNGAm8Hcd5eP2gcIphgzmYxhG074UxNGAm(dnbbXMBsb0aK4FzrEqtkHhsTSReMgof53cdJG9cXNyZnPaAasCdGmDuNmyi6ReOeOPSWCeNI8BHHrWccFzrIN4HF4Yp7BiWDVob1y4dzPv6IikVD0k7lu64kII4auDVob1yayfom3KcObiX)YI8GMucpKAzxjmnCkYVfggbdXHrgJ81bi9oU71jOgJFhGgeFIzFdb(xwKh0Ks4Hul7kHPHFXGyFdbU71jOgdFOWqorQTHee8DQtP2gIdpKAj9ugJmOgJefcq8zFdbU71jOgdFilTsN)qtqWHrgJ81bi9oU71jOgJFrb5vdLp39KXOJeEQWZPuTneme7BiWDVob1y4dzPv68hxE96TJwzFHshxruehG6PoLABiaMQfDW96euJr6bLVmOgJefca8unx6G6(rnsmKhA8d)HdUXhE4aGSVHa)llYdAsj8qQLDLW0WDVYo6f34Z(gcC3Rtqng(qwALoae0ephgzmsrQ7jV4gFWONhUdGsuqsMBs8HS0kDaiC5fI9ne4UxNGAm8lwhTY(cLoUIOioav3RJ7oajawHdN6uQTH4WdPwspLXidQXirHaKtDk12qC3RtqngPhu(YGAmsuiii4Z(gcCB1OjJKOGung5lQsGozQ)DiU7v2r)GMGG9ne42QrtgjrbPAmYxuLaDsDyAsC3RSJ(bnVqCyKXiFDasVJ7EDcQX4p(1rRSVqPJRikIdq1DZqneazaYmK81bi9Ud4bWkCyOWqorQTHG86aKE(xwK8rs4I8dp8d34WiJr(6aKExedzPv6GOysMiIDecXmfMJ4vk1eWoAL9fkDCfrrCaQkSI91jjDE0XcGmazgs(6aKE3b8ayfoi2xSJvceIyk7luYvyf7Rts68OJLewTuGeVszWuaf9ccWONRWk2xNK05rhljSAPajU7v2r)Hgey0Zvyf7Rts68OJLewTuGeFilTsN)qRJwzFHshxruehGQfcLHAiaYaKzi5Rdq6DhWdGv4WqHHCIuBdb51bi98VSi5JKWf5Np8WVi85WiJr(6aKEh396eQHaq4XXLxVINdJmg5Rdq6DrmKLwPdIpgczGrEsotLvY4dPWacX3PoLABiodLNOJKeMCaMmbbgczGrEsodLNOJK8frshwn174dPWakiigdDsPMpplGIEzqjVccomYyKVoaP3XDVoHAi)9HFaiF4fXRgkF(7PsPfcLooLQTHG96vqWhXmfMJ4vkDiJocc(iMPWCeVsPn6fjiqmtH5iELsZn1XleXE1q5ZDORrIcYxejdOHCpNs12qWcc23qGJnLfAGl1i1HPzXKyxJth(PAUKFhIcx44fIphgzmYxhG074UxNqnK)4HdaYhEr8QHYN)EQuAHqPJtPABiyVEHOUFuJed5Hg)Wfo4g7BiWDVob1y4dzPv6aqrIxi(eZ(gc8JvcpeSKSWqEOXIYxsjnalaG4xmbbIzkmhXRu6qgDeeeJHoPuZNFeWP00leftYerSJD0k7lu64kII4audOHrsuqM6FhcGv4GIjzIi2XoAL9fkDCfrrCaQJEsj66KHHsaaqawHd23qGZuzLm(fRJwzFHshxruehGkJmK7l1ivtbmTO8byfoCQtP2gIZGLmucxFHsi(SVHa396euJHFXeeu3pQrIH8qJF4chVqeZ(gcChY4(Ir8lgeXSVHaNPYkz8lgeFIXqNuQ5ZZcOOxgusq4uNsTneNHYt0rsctoatMGadHmWipjNHYt0rs(IiPdRM6D8lMGqLpnyiJ(eSmuaf9YHS0kD(hfor4JHs4B9CSHyLJKQPaMwu(8VSi5PAUKxVD0k7lu64kII4auRKPtQFHsawHdN6uQTH4myjdLW1xOeIp7BiWDVob1y4xmbb19JAKyip04hUWXleXSVHa3HmUVye)Ibrm7BiWzQSsg)IbXNym0jLA(8Sak6LbLeeo1PuBdXzO8eDKKWKdWKjiWqidmYtYzO8eDKKVis6WQPEh)Ijiu5tdgYOpbldfqrVCilTsN)meYaJ8KCgkprhj5lIKoSAQ3XhYsR0frKiiu5tdgYOpbldfqrVCilTsN4jE4H)WXFOHte(yOe(wphBiw5iPAkGPfLp)llsEQMl51BhTY(cLoUIOioavYcd5HgPnkHbyfou5tdgYOpbldfqrVCilTsN)4HlbbF23qGJnLfAGl1i1HPzXKyxJth(PAUK)rHlCeeSVHahBkl0axQrQdtZIjXUgNo8t1Cj)oefUWXle7BiWDVob1y4xmimeYaJ8KCMkRKXhYsR05hUWPJwzFHshxruehGQ7jJrhzWOdbqgGmdjFDasV7aEaSchgkmKtKABiiFzrYhjHlYp8WfehgzmYxhG074UxNqnK)4heftYerSJq8zFdbotLvY4dzPv68dpCeeeZ(gcCMkRKXVyE7Ov2xO0XvefXbOgUdGsuqsMBsaSchiMPWCeVsPMacrXKmre7ie7BiWXMYcnWLAK6W0SysSRXPd)unxY)OWfoq8bJEUcRyFDssNhDSKWQLcK4FXowjqbbXyOtk185jXgKbnWccomYyKVoaP35xuE7Ov2xO0XvefXbO6EDcQXaWkCW(gcCusViNeJggH9fk5xmi(SVHa396euJHpuyiNi12qccQ7h1iXqEOXVifhVD0k7lu64kII4auDVob1yayfoWqNuQ5ZZcOOxgucIVtDk12qCgkprhjjm5amzccmeYaJ8KCMkRKXVycc23qGZuzLm(fZlegczGrEsodLNOJK8frshwn174dzPv68hidMBPIdaXOY4tD)OgjgYdnIhUWXle7BiWDVob1y4dzPv68h)6Ov2xO0XvefXbO6EDC3bibWkCGHoPuZNNfqrVmOeeFN6uQTH4muEIossyYbyYeeyiKbg5j5mvwjJFXeeSVHaNPYkz8lMximeYaJ8KCgkprhj5lIKoSAQ3XhYsR05FKaX(gcC3Rtqng(fdcXmfMJ4vk1eWoAL9fkDCfrrCaQUxh3DasaSchSVHahL0lYjzgsh5z5kuYVycc(eZ96eQH4kMKjIyhfe8zFdbotLvY4dzPv68hxqSVHaNPYkz8lMGGp7BiWh9Ks01jddLaaG8HS0kD(dKbZTuXbGyuz8PUFuJed5HgXdA44fI9ne4JEsj66KHHsaaq(fZRxiN6uQTH4UxNGAmspO8Lb1yKOqaIdJmg5Rdq6DC3Rtqng)HMxi(eBUjfqdqI)Lf5bnPeEi1YUsyA4uKFlmmcwqWHrgJ81bi9oU71jOgJ)qZBhTY(cLoUIOioa1K8iTqOeGv4GpIzkmhXRuQjGqyiKbg5j5mvwjJpKLwPZpCHJGGpMiDasUdrbziMiDasYVSi)XLxbbMiDasUdqZleftYerSJD0k7lu64kII4aufPMG0cHsawHd(iMPWCeVsPMacHHqgyKNKZuzLm(qwALo)Wfocc(yI0bi5oefKHyI0bij)YI8hxEfeyI0bi5oanVqumjteXo2rRSVqPJRikIdqnCngPfcLaSch8rmtH5iELsnbecdHmWipjNPYkz8HS0kD(HlCee8XePdqYDikidXePdqs(Lf5pU8kiWePdqYDaAEHOysMiIDSJwzFHshxruehGQhDMcnsuqsMBsD0k7lu64kII4aup1PuBdbWuTOdUxNqnKSsPdz0bGNQ5shCyKXiFDasVJ7EDc1q(HFremi04ZsDpnakpvZLeVOWXBebdcn(SVHa3964Udqsswyip0yr5lDiJoC3RSJIh(5TJwzFHshxruehGQNrFraSchiMPWCe3CtDKjjUxqGyMcZrCnbuMK4EiN6uQTH4LtYmKEscc23qGtmtH5iPdz0HpKLwPZFL9fk5UxNqneNehXUpj)YIGyFdboXmfMJKoKrh(ftqGyMcZr8kLoKrhiIDQtP2gI7EDc1qYkLoKrhbb7BiWzQSsgFilTsN)k7luYDVoHAiojoIDFs(LfbrStDk12q8Yjzgspji23qGZuzLm(qwALo)jXrS7tYVSii23qGZuzLm(ftqW(gc8rpPeDDYWqjaai)IbXHrgJuK6EYpC4rceFomYyKVoaP35)bOjii2RgkFUdDnsuq(IizanK75uQ2gc2RGGyN6uQTH4LtYmKEsqSVHaNPYkz8HS0kD(rIJy3NKFzrD0k7lu64kII4auDVoHAOoAL9fkDCfrrCaQZnLk7luknL7byQw0HGAmVO52r3rRSVqPJBJ0)WONuIUozyOeaaeGv4G9ne4mvwjJFX6Ov2xO0XTr6hXbOEQtP2gcGPArhyt9j6Vya8unx6Gy23qGBRgnzKefKQXiFrvc0jt9VdXVyqeZ(gcCB1OjJKOGung5lQsGoPomnj(fRJwzFHsh3gPFehGQcRyFDssNhDSaidqMHKVoaP3DapawHd23qGBRgnzKefKQXiFrvc0jt9VdXDVYo6p(bX(gcCB1OjJKOGung5lQsGoPomnjU7v2r)Xpi(edg9CfwX(6KKop6yjHvlfiX)IDSsGqetzFHsUcRyFDssNhDSKWQLcK4vkdMcOOhIpXGrpxHvSVojPZJowsrKA4FXowjqbby0Zvyf7Rts68OJLuePg(qwALo)GMxbby0Zvyf7Rts68OJLewTuGe39k7O)qdcm65kSI91jjDE0XscRwkqIpKLwPZFCbbg9CfwX(6KKop6yjHvlfiX)IDSsGE7Ov2xO0XTr6hXbOYq5j6ijFrK0Hvt9oawHd(o1PuBdXzO8eDKKWKdWKbrmgczGrEsotLvY4dPWakiyFdbotLvY4xmVq8zFdbUTA0KrsuqQgJ8fvjqNm1)oe39k74bCjiyFdbUTA0KrsuqQgJ8fvjqNuhMMe39k74bC5vqiuaf9YHS0kD(JhoD0k7lu642i9J4auzAYiJ0(gcamvl6G71XGgyawHd(SVHa3wnAYijkivJr(IQeOtM6FhIpKLwPZp8JJlbb7BiWTvJMmsIcs1yKVOkb6K6W0K4dzPv68d)44Yle19JAKyip043Hifhi(yiKbg5j5mvwjJpKLwPZpCVGGpgczGrEsozHH8qJ0gLW8HS0kD(H7HiM9ne4hReEiyjzHH8qJfLVKsAawaaXVyqyOtk185hbCkn96TJwzFHsh3gPFehGQ71XDhGeaRWbXo1PuBdXzt9j6Vyq8XqNuQ5ZZcOOxgusqGHqgyKNKZuzLm(qwALo)W9ccIDQtP2gIZGLmucxFHsiIXqNuQ5Zpc4uAki4JHqgyKNKtwyip0iTrjmFilTsNF4EiIzFdb(XkHhcwswyip0yr5lPKgGfaq8lgeg6KsnF(raNstVE7Ov2xO0XTr6hXbO6EDC3bibWkCWhdHmWipjNHYt0rs(IiPdRM6D8HS0kD(Jli(o1PuBdXzO8eDKKWKdWKjiWqidmYtYzQSsgFilTsN)4YRxiQ7h1iXqEOXp8dhim0jLA(8Sak6LbL6Ov2xO0XTr6hXbO6UzOgcGmazgs(6aKE3b8ayfomuyiNi12qqEDasp)lls(ijCr(HxKaXNIjzIi2ri(o1PuBdXzt9j6Vycc(u3pQrIH8qJ)qdhiIzFdbotLvY4xmVccmeYaJ8KCMkRKXhsHb0R3oAL9fkDCBK(rCaQwiugQHaidqMHKVoaP3DapawHddfgYjsTneKxhG0Z)YIKpscxKF4bnoUG4tXKmre7ieFN6uQTH4SP(e9xmbbFQ7h1iXqEOXFOHdeXSVHaNPYkz8lMxbbgczGrEsotLvY4dPWa6fIy23qGFSs4HGLKfgYdnwu(skPbybae)I5TJwzFHsh3gPFehGQ7jJrhzWOdbqgGmdjFDasV7aEaSchgkmKtKABiiVoaPN)LfjFKeUi)WlsIyilTsheFkMKjIyhH47uNsTneNn1NO)IjiOUFuJed5Hg)HgoccmeYaJ8KCMkRKXhsHb0R3oAL9fkDCBK(rCaQb0Wijkit9VdbWkCqXKmre7yhTY(cLoUns)ioa1WDauIcsYCtcGv4GpIzkmhXRuQjGcceZuyoI7qgDKvkXtqGyMcZrCZn1rwPepVq8jgdDsPMpplGIEzqjbbFQ7h1iXqEOX)ifxq8DQtP2gIZM6t0FXeeu3pQrIH8qJ)qdhbHtDk12q8Yjve5fIVtDk12qCgkprhjjm5amzqeJHqgyKNKZq5j6ijFrK0Hvt9o(ftqqStDk12qCgkprhjjm5amzqeJHqgyKNKZuzLm(fZRxVq8XqidmYtYzQSsgFilTsNFqdhbb19JAKyip04xKIdegczGrEsotLvY4xmi(yiKbg5j5KfgYdnsBucZhYsR05VY(cLC3RtOgItIJy3NKFzrccIXqNuQ5Zpc4uA6vqOYNgmKrFcwgkGIE5qwALo)XdhVq8bJEUcRyFDssNhDSKWQLcK4dzPv68d)eeeJHoPuZNNeBqg0a7TJwzFHsh3gPFehGkzHH8qJ0gLWaSch8rmtH5iU5M6itsCVGaXmfMJ4oKrhzsI7feiMPWCextaLjjUxqW(gcCB1OjJKOGung5lQsGozQ)Di(qwALo)WpoUeeSVHa3wnAYijkivJr(IQeOtQdttIpKLwPZp8JJlbb19JAKyip04xKIdegczGrEsotLvY4dPWa6fIpgczGrEsotLvY4dzPv68dA4iiWqidmYtYzQSsgFifgqVccv(0GHm6tWYqbu0lhYsR05pE40rRSVqPJBJ0pIdqLrgY9LAKQPaMwu(aScho1PuBdXzWsgkHRVqjeFQ7h1iXqEOXVifhi(SVHa)yLWdbljlmKhASO8LusdWcai(ftqqmg6KsnF(raNstVccm0jLA(8Sak6LbLeeSVHa32GqWMR75xmi23qGBBqiyZ198HS0kD(hfor4JHs4B9CSHyLJKQPaMwu(8VSi5PAUKxVq8DQtP2gIZq5j6ijHjhGjtqGHqgyKNKZq5j6ijFrK0Hvt9o(qkmGEfeQ8Pbdz0NGLHcOOxoKLwPZ)OWjcFmucFRNJneRCKunfW0IYN)LfjpvZL82rRSVqPJBJ0pIdqTsMoP(fkbyfoCQtP2gIZGLmucxFHsi(u3pQrIH8qJFrkoq8zFdb(XkHhcwswyip0yr5lPKgGfaq8lMGGym0jLA(8JaoLMEfeyOtk185zbu0ldkjiyFdbUTbHGnx3ZVyqSVHa32GqWMR75dzPv68hA4eHpgkHV1ZXgIvosQMcyAr5Z)YIKNQ5sE9cX3PoLABiodLNOJKeMCaMmbbgczGrEsodLNOJK8frshwn174dPWa6vqOYNgmKrFcwgkGIE5qwALo)Hgor4JHs4B9CSHyLJKQPaMwu(8VSi5PAUK3oAL9fkDCBK(rCaQN6uQTHayQw0b1Hj(LMyIbWt1CPdeZuyoIxP0CtDaq4pXtzFHsU71judXjXrS7tYVSOieJyMcZr8kLMBQdaksepL9fk5Eg9fXjXrS7tYVSOiWHhL45WiJrksDp1rRSVqPJBJ0pIdq1964UdqcGv4GVkFAWqg9jyzOak6LdzPv68h)ee8zFdb(ONuIUozyOeaaKpKLwPZFGmyULkoaeJkJp19JAKyip0iEqdhVqSVHaF0tkrxNmmucaaYVyE9ki4tD)OgjgYdnrCQtP2gIRomXV0etmaK9ne4eZuyos6qgD4dzPv6Iag98WDauIcsYCtI)f7OtoKLwjakkoU8dVOWrqqD)OgjgYdnrCQtP2gIRomXV0etmaK9ne4eZuyosAUPo8HS0kDraJEE4oakrbjzUjX)ID0jhYsReaffhx(Hxu44fcXmfMJ4vk1eqi(8jgdHmWipjNPYkz8lMGadDsPMp)iGtPjeXyiKbg5j5KfgYdnsBucZVyEfeyOtk185zbu0ldk5fIpXyOtk185Nu(IaCeeeZ(gcCMkRKXVyccQ7h1iXqEOXVifhVcc23qGZuzLm(qwALo)WFqeZ(gc8rpPeDDYWqjaai)I1rRSVqPJBJ0pIdqnjpslekbyfo4Z(gcCIzkmhjn3uh(ftqWhtKoaj3HOGmetKoaj5xwK)4YRGatKoaj3bO5fIIjzIi2XoAL9fkDCBK(rCaQIutqAHqjaRWbF23qGtmtH5iP5M6WVycc(yI0bi5oefKHyI0bij)YI8hxEfeyI0bi5oanVqumjteXo2rRSVqPJBJ0pIdqnCngPfcLaSch8zFdboXmfMJKMBQd)Iji4JjshGK7quqgIjshGK8llYFC5vqGjshGK7a08crXKmre7yhTY(cLoUns)ioavp6mfAKOGKm3K6Ov2xO0XTr6hXbO6EDc1qaSchiMPWCeVsP5M6iiqmtH5iUdz0rMK4EbbIzkmhX1eqzsI7feSVHa3JotHgjkijZnj(fdI9ne4eZuyosAUPo8lMGGp7BiWzQSsgFilTsN)k7luY9m6lItIJy3NKFzrqSVHaNPYkz8lM3oAL9fkDCBK(rCaQEg9f1rRSVqPJBJ0pIdqDUPuzFHsPPCpat1IoeuJ5fn3o6oAL9fkDC4Hul7kHP5WPoLABiaMQfDWPbs(i51rshgzma8unx6Gp7BiW)YI8GMucpKAzxjmn8HS0kD(bKbZTuXfboC8G4JyMcZr8kL2OxKGaXmfMJ4vkDiJocceZuyoIBUPoYKe37vqW(gc8VSipOjLWdPw2vctdFilTsNFk7luYDVoHAiojoIDFs(LffboC8G4JyMcZr8kLMBQJGaXmfMJ4oKrhzsI7feiMPWCextaLjjU3RxbbXSVHa)llYdAsj8qQLDLW0WVyD0k7lu64WdPw2vcttehGQ71XDhGeaRWbFIDQtP2gI70ajFK86iPdJmgbbF23qGp6jLORtggkbaa5dzPv68hidMBPIdaXOY4tD)OgjgYdnIh0WXle7BiWh9Ks01jddLaaG8lMxVccQ7h1iXqEOXVifNoAL9fkDC4Hul7kHPjIdqLHYt0rs(IiPdRM6DaSch8DQtP2gIZq5j6ijHjhGjdsLpnyiJ(eSmuaf9YHS0kD(Hh0WbIymeYaJ8KCMkRKXhsHbuqW(gcCMkRKXVyEHOUFuJed5Hg)XpCG4Z(gcCIzkmhjn3uh(qwALo)Wdhbb7BiWjMPWCK0Hm6WhYsR05hE44vqiuaf9YHS0kD(JhoD0k7lu64WdPw2vcttehGQcRyFDssNhDSaidqMHKVoaP3DapawHdIbJEUcRyFDssNhDSKWQLcK4FXowjqiIPSVqjxHvSVojPZJowsy1sbs8kLbtbu0dXNyWONRWk2xNK05rhlPisn8VyhReOGam65kSI91jjDE0XskIudFilTsNF4YRGam65kSI91jjDE0XscRwkqI7ELD0FObbg9CfwX(6KKop6yjHvlfiXhYsR05p0GaJEUcRyFDssNhDSKWQLcK4FXowjWoAL9fkDC4Hul7kHPjIdq1cHYqneazaYmK81bi9Ud4bWkCyOWqorQTHG86aKE(xwK8rs4I8dVOG4ZN9ne4mvwjJpKLwPZpCbXN9ne4JEsj66KHHsaaq(qwALo)WLGGy23qGp6jLORtggkbaa5xmVccIzFdbotLvY4xmbb19JAKyip04p0WXleFIzFdb(XkHhcwswyip0yr5lPKgGfaq8lMGG6(rnsmKhA8hA44fIIjzIi2rVD0k7lu64WdPw2vcttehGQ7MHAiaYaKzi5Rdq6DhWdGv4WqHHCIuBdb51bi98VSi5JKWf5hErbXNp7BiWzQSsgFilTsNF4cIp7BiWh9Ks01jddLaaG8HS0kD(HlbbXSVHaF0tkrxNmmucaaYVyEfeeZ(gcCMkRKXVyccQ7h1iXqEOXFOHJxi(eZ(gc8JvcpeSKSWqEOXIYxsjnalaG4xmbb19JAKyip04p0WXleftYerSJE7Ov2xO0XHhsTSReMMioav3tgJoYGrhcGmazgs(6aKE3b8ayfomuyiNi12qqEDasp)lls(ijCr(HxKaXNp7BiWzQSsgFilTsNF4cIp7BiWh9Ks01jddLaaG8HS0kD(HlbbXSVHaF0tkrxNmmucaaYVyEfeeZ(gcCMkRKXVyccQ7h1iXqEOXFOHJxi(eZ(gc8JvcpeSKSWqEOXIYxsjnalaG4xmbb19JAKyip04p0WXleftYerSJE7Ov2xO0XHhsTSReMMioa1aAyKefKP(3HayfoOysMiIDSJwzFHshhEi1YUsyAI4auh9Ks01jddLaaGaSchSVHaNPYkz8lwhTY(cLoo8qQLDLW0eXbOswyip0iTrjmaRWbF(SVHaNyMcZrshYOdFilTsNF4HJGG9ne4eZuyosAUPo8HS0kD(HhoEHWqidmYtYzQSsgFilTsNFqdhVccmeYaJ8KCMkRKXhsHbSJwzFHshhEi1YUsyAI4auzKHCFPgPAkGPfLpaRWHtDk12qCgSKHs46lucXNp7BiWpwj8qWsYcd5HglkFjL0aSaaIFXeeeJHoPuZNFeWP00RGadDsPMpplGIEzqjbHtDk12q8YjvejiyFdbUTbHGnx3ZVyqSVHa32GqWMR75dzPv68pkCIWhdLW365ydXkhjvtbmTO85FzrYt1CjVEHiM9ne4mvwjJFXG4tmg6KsnFEwaf9YGsccmeYaJ8KCgkprhj5lIKoSAQ3XVyccv(0GHm6tWYqbu0lhYsR05pdHmWipjNHYt0rs(IiPdRM6D8HS0kDrejccv(0GHm6tWYqbu0lhYsR0jEIhE4pC8pkCIWhdLW365ydXkhjvtbmTO85FzrYt1CjVE7Ov2xO0XHhsTSReMMioa1kz6K6xOeGv4WPoLABiodwYqjC9fkH4ZN9ne4hReEiyjzHH8qJfLVKsAawaaXVyccIXqNuQ5Zpc4uA6vqGHoPuZNNfqrVmOKGWPoLABiE5KkIeeSVHa32GqWMR75xmi23qGBBqiyZ198HS0kD(dnCIWhdLW365ydXkhjvtbmTO85FzrYt1CjVEHiM9ne4mvwjJFXG4tmg6KsnFEwaf9YGsccmeYaJ8KCgkprhj5lIKoSAQ3XVyccv(0GHm6tWYqbu0lhYsR05pdHmWipjNHYt0rs(IiPdRM6D8HS0kDrejccv(0GHm6tWYqbu0lhYsR0jEIhE4pC8hA4eHpgkHV1ZXgIvosQMcyAr5Z)YIKNQ5sE92rRSVqPJdpKAzxjmnrCaQN6uQTHayQw0bNEsYaAKmvwjdGNQ5sh8jgdHmWipjNPYkz8Huyafee7uNsTneNHYt0rsctoatgeg6KsnFEwaf9YGsE7Ov2xO0XHhsTSReMMioa1WDauIcsYCtcGv4aXmfMJ4vk1eqikMKjIyhH4dg9CfwX(6KKop6yjHvlfiX)IDSsGccIXqNuQ5ZtInidAG9c5uNsTne3PNKmGgjtLvY6Ov2xO0XHhsTSReMMioav3RJ7oajawHdm0jLA(8Sak6LbLGCQtP2gIZq5j6ijHjhGjdI6(rnsmKhA87a(HdegczGrEsodLNOJK8frshwn174dzPv68hidMBPIdaXOY4tD)OgjgYdnIh0WXBhTY(cLoo8qQLDLW0eXbOMKhPfcLaSch8zFdboXmfMJKMBQd)Iji4JjshGK7quqgIjshGK8llYFC5vqGjshGK7a08crXKmre7iKtDk12qCNEsYaAKmvwjRJwzFHshhEi1YUsyAI4aufPMG0cHsawHd(SVHaNyMcZrsZn1HFXGigdDsPMp)iGtPPGGp7BiWpwj8qWsYcd5HglkFjL0aSaaIFXGWqNuQ5Zpc4uA6vqWhtKoaj3HOGmetKoaj5xwK)4YRGatKoaj3bOjiyFdbotLvY4xmVqumjteXoc5uNsTne3PNKmGgjtLvY6Ov2xO0XHhsTSReMMioa1W1yKwiucWkCWN9ne4eZuyosAUPo8lgeXyOtk185hbCknfe8zFdb(XkHhcwswyip0yr5lPKgGfaq8lgeg6KsnF(raNstVcc(yI0bi5oefKHyI0bij)YI8hxEfeyI0bi5oanbb7BiWzQSsg)I5fIIjzIi2riN6uQTH4o9KKb0izQSswhTY(cLoo8qQLDLW0eXbO6rNPqJefKK5MuhTY(cLoo8qQLDLW0eXbO6EDc1qaSchiMPWCeVsP5M6iiqmtH5iUdz0rMK4EbbIzkmhX1eqzsI7feSVHa3JotHgjkijZnj(fdI9ne4eZuyosAUPo8lMGGp7BiWzQSsgFilTsN)k7luY9m6lItIJy3NKFzrqSVHaNPYkz8lM3oAL9fkDC4Hul7kHPjIdq1ZOVOoAL9fkDC4Hul7kHPjIdqDUPuzFHsPPCpat1IoeuJ5fn3o6oAL9fkD8GAmVO5EW964UdqcGv4GyZnPaAasCB1OjJKOGung5lQsGoof53cdJG7Ov2xO0XdQX8IMBehGQ7MHAiaYaKzi5Rdq6DhWdGv4am65wiugQH4dzPv68BilTsxhTY(cLoEqnMx0CJ4auTqOmud1r3rRSVqPJ7(dkSI91jjDE0XcGmazgs(6aKE3b8ayfoigm65kSI91jjDE0XscRwkqI)f7yLaHiMY(cLCfwX(6KKop6yjHvlfiXRugmfqrpeFIbJEUcRyFDssNhDSKIi1W)IDSsGccWONRWk2xNK05rhlPisn8HS0kD(HlVccWONRWk2xNK05rhljSAPajU7v2r)Hgey0Zvyf7Rts68OJLewTuGeFilTsN)qdcm65kSI91jjDE0XscRwkqI)f7yLa7Ov2xO0XDFehGkdLNOJK8frshwn17ayfo47uNsTneNHYt0rsctoatgeXyiKbg5j5mvwjJpKcdOGG9ne4mvwjJFX8crD)OgjgYdn(JF4aXN9ne4eZuyosAUPo8HS0kD(Hhocc23qGtmtH5iPdz0HpKLwPZp8WXRGqOak6LdzPv68hpC6Ov2xO0XDFehG6PoLABiaMQfDag9YHI8BnKfLVdGNQ5sh8zFdbotLvY4dzPv68dxq8zFdb(ONuIUozyOeaaKpKLwPZpCjiiM9ne4JEsj66KHHsaaq(fZRGGy23qGZuzLm(ftqqD)OgjgYdn(dnC8cXNy23qGFSs4HGLKfgYdnwu(skPbybae)IjiOUFuJed5Hg)HgoEH4Z(gcCIzkmhjDiJo8HS0kD(bKbZTuXjiyFdboXmfMJKMBQdFilTsNFazWClvCE7Ov2xO0XDFehGQfcLHAiaYaKzi5Rdq6DhWdGv4WqHHCIuBdb51bi98VSi5JKWf5hErbXNIjzIi2riN6uQTH4WOxouKFRHSO8DE7Ov2xO0XDFehGQ7MHAiaYaKzi5Rdq6DhWdGv4WqHHCIuBdb51bi98VSi5JKWf5hErbXNIjzIi2riN6uQTH4WOxouKFRHSO8DE7Ov2xO0XDFehGQ7jJrhzWOdbqgGmdjFDasV7aEaSchgkmKtKABiiVoaPN)LfjFKeUi)WlsG4tXKmre7iKtDk12qCy0lhkYV1qwu(oVD0k7lu64UpIdqnGggjrbzQ)DiawHdkMKjIyh7Ov2xO0XDFehG6ONuIUozyOeaaeGv4G9ne4mvwjJFX6Ov2xO0XDFehGkzHH8qJ0gLWaSch85Z(gcCIzkmhjDiJo8HS0kD(Hhocc23qGtmtH5iP5M6WhYsR05hE44fcdHmWipjNPYkz8HS0kD(bnCG4Z(gcCSPSqdCPgPomnlMe7AC6WpvZL8pk8dhbbXMBsb0aK4ytzHg4snsDyAwmj2140Htr(TWWiyVEfeSVHahBkl0axQrQdtZIjXUgNo8t1Cj)oefUhhbbgczGrEsotLvY4dPWacXN6(rnsmKhA8lsXrq4uNsTneVCsfrE7Ov2xO0XDFehGkJmK7l1ivtbmTO8byfoCQtP2gIZGLmucxFHsi(u3pQrIH8qJFrkoq8zFdb(XkHhcwswyip0yr5lPKgGfaq8lMGGym0jLA(8JaoLMEfeyOtk185zbu0ldkjiCQtP2gIxoPIibb7BiWTnieS56E(fdI9ne42gec2CDpFilTsN)rHte(8fPaO5Muanajo2uwObUuJuhMMftIDnoD4uKFlmmc2Be(yOe(wphBiw5iPAkGPfLp)llsEQMl51RxiIzFdbotLvY4xmi(eJHoPuZNNfqrVmOKGadHmWipjNHYt0rs(IiPdRM6D8lMGqLpnyiJ(eSmuaf9YHS0kD(ZqidmYtYzO8eDKKVis6WQPEhFilTsxerIGqLpnyiJ(eSmuaf9YHS0kDIN4Hh(dh)JcNi8Xqj8TEo2qSYrs1uatlkF(xwK8unxYR3oAL9fkDC3hXbOwjtNu)cLaScho1PuBdXzWsgkHRVqjeFQ7h1iXqEOXVifhi(SVHa)yLWdbljlmKhASO8LusdWcai(ftqqmg6KsnF(raNstVccm0jLA(8Sak6LbLeeo1PuBdXlNurKGG9ne42gec2CDp)IbX(gcCBdcbBUUNpKLwPZFOHte(8fPaO5Muanajo2uwObUuJuhMMftIDnoD4uKFlmmc2Be(yOe(wphBiw5iPAkGPfLp)llsEQMl51RxiIzFdbotLvY4xmi(eJHoPuZNNfqrVmOKGadHmWipjNHYt0rs(IiPdRM6D8lMGqLpnyiJ(eSmuaf9YHS0kD(ZqidmYtYzO8eDKKVis6WQPEhFilTsxerIGqLpnyiJ(eSmuaf9YHS0kDIN4Hh(dh)Hgor4JHs4B9CSHyLJKQPaMwu(8VSi5PAUKxVD0k7lu64UpIdq9uNsTneat1Io40tsgqJKPYkza8unx6GpXyiKbg5j5mvwjJpKcdOGGyN6uQTH4muEIossyYbyYGWqNuQ5ZZcOOxguYBhTY(cLoU7J4aud3bqjkijZnjawHdeZuyoIxPutaHOysMiIDeI9ne4ytzHg4snsDyAwmj2140HFQMl5Fu4hoq8bJEUcRyFDssNhDSKWQLcK4FXowjqbbXyOtk185jXgKbnWEHCQtP2gI70tsgqJKPYkzD0k7lu64UpIdq196euJbGv4G9ne4OKErojgnmc7luYVyqSVHa396euJHpuyiNi12qD0k7lu64UpIdqLPjJms7BiaWuTOdUxhdAGbyfoyFdbU71XGgy(qwALo)XfeF23qGtmtH5iPdz0HpKLwPZpCjiyFdboXmfMJKMBQdFilTsNF4Yle19JAKyip04xKIthTY(cLoU7J4auDVob1yayfo8QHYN7EYy0rcpv45uQ2gcgIJ(VsGoUdzqs4Pcpe7BiWDVob1y4WipzhTY(cLoU7J4auDVoU7aKayfoWqNuQ5ZZcOOxgucYPoLABiodLNOJKeMCaMmimeYaJ8KCgkprhj5lIKoSAQ3XhYsR05pU6Ov2xO0XDFehGQ71jOgdaRWHxnu(C3tgJos4PcpNs12qWqe7vdLp396yqdmNs12qWqSVHa396euJHpuyiNi12qq8zFdboXmfMJKMBQdFilTsNFrceIzkmhXRuAUPoqSVHahBkl0axQrQdtZIjXUgNo8t1Cj)Jcx4iiyFdbo2uwObUuJuhMMftIDnoD4NQ5s(DikCHde19JAKyip04xKIJGam65kSI91jjDE0XscRwkqIpKLwPZp8NGGY(cLCfwX(6KKop6yjHvlfiXRugmfqrVxiIXqidmYtYzQSsgFifgWoAL9fkDC3hXbO6EDC3bibWkCW(gcCusViNKziDKNLRqj)IjiyFdb(XkHhcwswyip0yr5lPKgGfaq8lMGG9ne4mvwjJFXG4Z(gc8rpPeDDYWqjaaiFilTsN)azWClvCaigvgFQ7h1iXqEOr8GgoEHyFdb(ONuIUozyOeaaKFXeeeZ(gc8rpPeDDYWqjaai)IbrmgczGrEs(ONuIUozyOeaaKpKcdOGGym0jLA(8tkFraoEfeu3pQrIH8qJFrkoqiMPWCeVsPMa2rRSVqPJ7(ioav3RJ7oajawHdVAO85UxhdAG5uQ2gcgIp7BiWDVog0aZVyccQ7h1iXqEOXVifhVqSVHa396yqdm39k7O)qdIp7BiWjMPWCK0Hm6WVycc23qGtmtH5iP5M6WVyEHyFdbo2uwObUuJuhMMftIDnoD4NQ5s(hfUhhi(yiKbg5j5mvwjJpKLwPZp8WrqqStDk12qCgkprhjjm5amzqyOtk185zbu0ldk5TJwzFHsh39rCaQUxh3DasaSch8zFdbo2uwObUuJuhMMftIDnoD4NQ5s(hfUhhbb7BiWXMYcnWLAK6W0SysSRXPd)unxY)OWfoqE1q5ZDpzm6iHNk8CkvBdb7fI9ne4eZuyos6qgD4dzPv68d3dHyMcZr8kLoKrhiIzFdbokPxKtIrdJW(cL8lgeXE1q5ZDVog0aZPuTnemegczGrEsotLvY4dzPv68d3dXhdHmWipjNSWqEOrAJsy(qwALo)W9ccIXqNuQ5Zpc4uA6TJwzFHsh39rCaQj5rAHqjaRWbF23qGtmtH5iP5M6WVycc(yI0bi5oefKHyI0bij)YI8hxEfeyI0bi5oanVqumjteXoc5uNsTne3PNKmGgjtLvY6Ov2xO0XDFehGQi1eKwiucWkCWN9ne4eZuyosAUPo8lgeXyOtk185hbCknfe8zFdb(XkHhcwswyip0yr5lPKgGfaq8lgeg6KsnF(raNstVcc(yI0bi5oefKHyI0bij)YI8hxEfeyI0bi5oanbb7BiWzQSsg)I5fIIjzIi2riN6uQTH4o9KKb0izQSswhTY(cLoU7J4audxJrAHqjaRWbF23qGtmtH5iP5M6WVyqeJHoPuZNFeWP0uqWN9ne4hReEiyjzHH8qJfLVKsAawaaXVyqyOtk185hbCkn9ki4JjshGK7quqgIjshGK8llYFC5vqGjshGK7a0eeSVHaNPYkz8lMxikMKjIyhHCQtP2gI70tsgqJKPYkzD0k7lu64UpIdq1JotHgjkijZnPoAL9fkDC3hXbO6EDc1qaSchiMPWCeVsP5M6iiqmtH5iUdz0rMK4EbbIzkmhX1eqzsI7feSVHa3JotHgjkijZnj(fdI9ne4eZuyosAUPo8lMGGp7BiWzQSsgFilTsN)k7luY9m6lItIJy3NKFzrqSVHaNPYkz8lM3oAL9fkDC3hXbO6z0xuhTY(cLoU7J4auNBkv2xOuAk3dWuTOdb1yErZf8bFqqa]] )


end