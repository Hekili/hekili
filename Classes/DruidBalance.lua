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
        else state:RunHandle( "wild_growth" ) end
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


    spec:RegisterPack( "Balance", 20201214, [[dOuFvdqicLhbvqUeuv1MaPprOkgfvPtrvSkHO6vcHzbeDlOcSlu(fqQHbv6yqvwMqQNbImnOQY1GkABcr8nOczCqfQZjeP1rOQmpQQ6EQG9rvLdsOk1cHQYdfIYejuLKlsOkP(iHQQCsOckRuizMaH6MeQQk7ei5NeQQQgkHQkTucvjEQqnvquFfQGQXsOQI9c4VenyLomPftLEmQMmuUmYMf8zGA0eYPL61QqZMIBtf7w0VHmCqDCGqwUINtPPRQRRsBxf9DQkJNqLZdcRhiy(eSFjdGhaKbIX0Naav04gnU4fnE4hdpCmKWd)WraXpeWeqmSYpQGjG4uDiGy8Pgn5eqmScHbPyaqgi2IUdNaIf9pSv8bAqdUFrxxgh5aAB7Cn63OKpA4bTTD4Ggi292Mhhwc4ceJPpbaQOXnACXlA8WpgE4yiHh(fjaX69fHgG442jYaIf1yyuc4ceJrwoqmouT4tnAYPAfVAUnwffouTIxrCYXLMAXd)azTrJB04wrvrHdvBKjstWKv8vrHdvloOwXBmmcR2yKrNAXhPoSkkCOAXb1gzI0emHv7Rdy6LDOwUAjBTpQwoeCdjFDatVLvrHdvloOwXlKd6KWQ9MjXjRvhiQ9uNwDnKTwVnJyGSw4HoL2xh7Dat1Id8Rw4Hoz2xh7DatEyvu4q1IdQv8(e1y1cpexTFNGRfh(OVOA7qT9lES1(IOA9nOeCTIxZnnSLyvu4q1IdQv8p9ivBKHYt0rQ2xevBmCp9BRvR10)BOADqdvBWqIRDnuTE7qTqGU1ksXsXZxRO(RT)ATTZ18AsOR1arT(6xuT4t8FXBixBe1gzKHSFRMAfVnn40HYhK12V4bRw7Xg2ddi2023cazGy4H4ihx9bGmaOWdaYaXk)Buce7Gq5XoLb04aetP6Aima8b8aGkAaideR8Vrjq8XoXgctAH7PFlqmLQRHWaWhWdakibazGykvxdHbGpGyL)nkbI9n6lciMp9ttRaXERL4Mg2smZn1rMK4(AfeQL4Mg2sSoLMBQtTcc1sCtdBjwNsx0lQwbHAjUPHTettiKjjUVwpaXMojjhdigpCbEaqHFaqgiMs11qya4diMp9ttRaXERL4Mg2smZn1rMK4(AfeQL4Mg2sSoLMBQtTcc1sCtdBjwNsx0lQwbHAjUPHTettiKjjUVwp1cTw4Hoz4X8n6lQwO1kwTWdDYIM5B0xeqSY)gLaX(g9fb8aGcNaqgiMs11qya4diMp9ttRaXIv7CtkGgWeZvnAYjjkivJr(I6eSLrP6AiSAfeQvSA5Otk18zzdw0ldkvRGqTIvRfMmg5Rdy6Tm7RtqnMApulE1kiuRy1(QHYNL6FhYkDvJMCIrP6AimGyL)nkbITVoHEiGhaurcaKbIPuDnega(aI5t)00kq8CtkGgWeZvnAYjjkivJr(I6eSLrP6AiSAHwlhDsPMplBWIEzqPAHwRfMmg5Rdy6Tm7RtqnMApulEaXk)BuceBFDS3bmb8apqmgf0R5bGmaOWdaYaXk)BuceBrgDKUK6aetP6Aima8b8aGkAaidetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGylmzmYxhW0Bz2xNGAm16xT4vl0A9wRy1(QHYNzFDmObJrP6AiSAfeQ9vdLpZ(KXOJeB6WZOuDnewTEQvqOwlmzmYxhW0Bz2xNGAm16xTrdeFQJmvhciUTsfrapaOGeaKbIPuDnega(aIrWaXw6bIv(3Oei(uNwDneq8PAUeqSfMmg5Rdy6Tm7RtOhQw)QfpG4tDKP6qaXTvYnKEsapaOWpaidetP6Aima8beZN(PPvGyV1kwTC0jLA(SSbl6LbLQvqOwXQLJqgmKVKXr5j6ijFrK0c3t)w2fUwp1cTw3BiW4QSto7cdeR8VrjqSlnwAo2jyGhau4eaYaXuQUgcdaFaX8PFAAfi29gcmUk7KZUWaXk)BucedJ(gLapaOIeaidetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjG4GbHMA9wR3A78Pbgz0NWKHgSOxoKJ2PTwCqTrJBT4GA5iKbd5lzCuEIosYxejTW90VLnKJ2PTwp1c6AXlACR1tT(vBWGqtTER1BTD(0aJm6tyYqdw0lhYr70wloO2OXzT4GA9wlE4wBKx7RgkFwNCDs9BuYOuDnewTEQfhuR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRNAXb1YridgYxY4QStoBihTtBTEQf01Ihog3A9uRGqTCeYGH8LmUk7KZgYr70wRF125tdmYOpHjdnyrVCihTtBTcc1YridgYxY4O8eDKKVisAH7PFlBihTtBT(vBNpnWiJ(eMm0Gf9YHC0oT1kiuRy1YrNuQ5ZYgSOxguci(uhzQoeqmhLNOJKeJSqKCGhau4iaidetP6Aima8beR8VrjqCNw(CF11qsq0vZ)6iXOZMtaX8PFAAfi29gcmUk7KZUWaXP6qaXDA5Z9vxdjbrxn)RJeJoBob8aGchdazGyL)nkbIVws2p5ybIPuDnega(aEaqfPaqgiMs11qya4diMp9ttRaXN60QRHyTvQici2(tZFaqHhqSY)gLaXZnLk)BuknT9bInT9LP6qaXkIaEaqHhUaqgiMs11qya4diMp9ttRaXZnPaAatSVDiFOjLydPoUDIrdJar3ggMWaIT)08hau4beR8Vrjq8CtPY)gLstBFGytBFzQoeqm2qQJBNy0a8aGcp8aGmqmLQRHWaWhqmF6NMwbINBsb0aMyUQrtojrbPAmYxuNGTmceDByycdi2(tZFaqHhqSY)gLaXZnLk)BuknT9bInT9LP6qaXUi9bEaqHx0aqgiMs11qya4diw5FJsG45MsL)nkLM2(aXM2(YuDiGy7d8apqm2qQJBNy0aazaqHhaKbIPuDnega(aIrWaXw6bIv(3Oei(uNwDneq8PAUeqS3ADVHa7BhYhAsj2qQJBNy0WgYr70wRF1cMJXCuXvBe1IldVAHwR3AjUPHTeRtPl6fvRGqTe30WwI1P0Im6uRGqTe30WwIzUPoYKe3xRNAfeQ19gcSVDiFOjLydPoUDIrdBihTtBT(vRY)gLm7RtOhIrIJ43NKF7q1grT4YWRwO16TwIBAylX6uAUPo1kiulXnnSLywKrhzsI7RvqOwIBAylX0eczsI7R1tTEQvqOwXQ19gcSVDiFOjLydPoUDIrd7cdeFQJmvhci2Qbs(i51sslmzmapaOIgaYaXuQUgcdaFaX8PFAAfi2BTIv7PoT6AiMvdK8rYRLKwyYyQvqOwV16Edb2ONuIUwzyOeeGGnKJ2PTw)RfmhJ5OIR2iVwo1MA9wRA)rnsyKpAQf01cjCR1tTqR19gcSrpPeDTYWqjiab7cxRNA9uRGqTQ9h1iHr(OPw)QnsXfiw5FJsGy7RJ9oGjGhauqcaYaXuQUgcdaFaX8PFAAfi2BTN60QRHyCuEIossmYcrYRfATD(0aJm6tyYqdw0lhYr70wRF1IhKWTwO1kwTCeYGH8LmUk7KZgsXGOwbHADVHaJRYo5SlCTEQfATQ9h1iHr(OPw)Rf)WTwO16Tw3BiWiUPHTK0CtDyd5ODAR1VAXd3AfeQ19gcmIBAyljTiJoSHC0oT16xT4HBTEQvqO2qdw0lhYr70wR)1IhUaXk)BuceZr5j6ijFrK0c3t)wGhau4haKbIPuDnega(aIv(3OeiwXu4VpjP1NooaX8PFAAfiwSAXqptXu4VpjP1Noosm1rbtSV5h7eCTqRvSAv(3OKPyk83NK06thhjM6OGjwNYGPbl6RfATERvSAXqptXu4VpjP1NoosrKAyFZp2j4AfeQfd9mftH)(KKwF64ifrQHnKJ2PTw)QfN16PwbHAXqptXu4VpjP1Noosm1rbtm7R8J16FTqQwO1IHEMIPWFFssRpDCKyQJcMyd5ODAR1)AHuTqRfd9mftH)(KKwF64iXuhfmX(MFStWaXCi4gs(6aMElaOWd4bafobGmqmLQRHWaWhqSY)gLaXoiug6HaI5t)00kq8qHHSIuxdvl0AFDatp7Bhs(ijwt16xT4fDTqR1BTER19gcmUk7KZgYr70wRF1IZAHwR3ADVHaB0tkrxRmmuccqWgYr70wRF1IZAfeQvSADVHaB0tkrxRmmuccqWUW16PwbHAfRw3BiW4QSto7cxRGqTQ9h1iHr(OPw)Rfs4wRNAHwR3AfRw3BiWo2j2qysYbg5JghkFjL0aUbbIDHRvqOw1(JAKWiF0uR)1cjCR1tTqRvHLCre)yTEaI5qWnK81bm9waqHhWdaQibaYaXuQUgcdaFaXk)BuceBVzOhciMp9ttRaXdfgYksDnuTqR91bm9SVDi5JKynvRF1Ix01cTwV16Tw3BiW4QStoBihTtBT(vloRfATER19gcSrpPeDTYWqjiabBihTtBT(vloRvqOwXQ19gcSrpPeDTYWqjiab7cxRNAfeQvSADVHaJRYo5SlCTcc1Q2FuJeg5JMA9VwiHBTEQfATERvSADVHa7yNydHjjhyKpACO8Lusd4gei2fUwbHAv7pQrcJ8rtT(xlKWTwp1cTwfwYfr8J16biMdb3qYxhW0BbafEapaOWraqgiMs11qya4diw5FJsGy7tgJoYGrhciMp9ttRaXdfgYksDnuTqR91bm9SVDi5JKynvRF1IxKul0A9wR3ADVHaJRYo5SHC0oT16xT4SwO16Tw3BiWg9Ks01kddLGaeSHC0oT16xT4SwbHAfRw3BiWg9Ks01kddLGaeSlCTEQvqOwXQ19gcmUk7KZUW1kiuRA)rnsyKpAQ1)AHeU16PwO16TwXQ19gcSJDIneMKCGr(OXHYxsjnGBqGyx4AfeQvT)OgjmYhn16FTqc3A9ul0AvyjxeXpwRhGyoeCdjFDatVfau4b8aGchdazGykvxdHbGpGy(0pnTceRWsUiIFeiw5FJsG4aA4KefKP(3HaEaqfPaqgiMs11qya4diMp9ttRaXU3qGXvzNC2fgiw5FJsG4rpPeDTYWqjiabWdak8WfaYaXuQUgcdaFaX8PFAAfi2BTER19gcmIBAyljTiJoSHC0oT16xT4HBTcc16EdbgXnnSLKMBQdBihTtBT(vlE4wRNAHwlhHmyiFjJRYo5SHC0oT16xTqc3A9uRGqTCeYGH8LmUk7KZgsXGaiw5FJsGyYbg5JgPlkXaEaqHhEaqgiMs11qya4diMp9ttRaXER1BTU3qGDStSHWKKdmYhnou(skPbCdce7cxRGqTIvlhDsPMp7ietRzTEQvqOwo6KsnFw2Gf9YGs1kiu7PoT6AiwBLkIQvqOw3BiWCnieM5AF2fUwO16EdbMRbHWmx7ZgYr70wR)1gnU1grTERLJsSB)m4H4TLKQPbNou(SVDi5PAUuTEQ1tTqRvSADVHaJRYo5SlCTqR1BTIvlhDsPMplBWIEzqPAfeQLJqgmKVKXr5j6ijFrK0c3t)w2fUwbHA78Pbgz0NWKHgSOxoKJ2PTw)RLJqgmKVKXr5j6ijFrK0c3t)w2qoAN2AJO2iPwbHA78Pbgz0NWKHgSOxoKJ2PTw8Vw8WX4wR)1gnU1grTERLJsSB)m4H4TLKQPbNou(SVDi5PAUuTEQ1dqSY)gLaXCYq2VvJunn40HYh4bafErdazGykvxdHbGpGy(0pnTce7TwV16Edb2XoXgctsoWiF04q5lPKgWniqSlCTcc1kwTC0jLA(SJqmTM16PwbHA5Otk18zzdw0ldkvRGqTN60QRHyTvQiQwbHADVHaZ1GqyMR9zx4AHwR7neyUgecZCTpBihTtBT(xlKWT2iQ1BTCuID7NbpeVTKunn40HYN9TdjpvZLQ1tTEQfATIvR7neyCv2jNDHRfATERvSA5Otk18zzdw0ldkvRGqTCeYGH8Lmokprhj5lIKw4E63YUW1kiuBNpnWiJ(eMm0Gf9YHC0oT16FTCeYGH8Lmokprhj5lIKw4E63YgYr70wBe1gj1kiuBNpnWiJ(eMm0Gf9YHC0oT1I)1Ihog3A9VwiHBTruR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRNA9aeR8VrjqCNCDs9Buc8aGcpibazGykvxdHbGpGyemqSLEGyL)nkbIp1PvxdbeFQMlbe7TwXQLJqgmKVKXvzNC2qkge1kiuRy1EQtRUgIXr5j6ijXilejVwO1YrNuQ5ZYgSOxguQwpaXN6it1HaIT6jjdOrYvzNCGhau4HFaqgiMs11qya4diMp9ttRaXe30WwI1PutiQfATkSKlI4hRfATERfd9mftH)(KKwF64iXuhfmX(MFStW1kiuRy1YrNuQ5ZsIpidAWQ1tTqR9uNwDneZQNKmGgjxLDYbIv(3OeioChiKOGKm3KaEaqHhobGmqmLQRHWaWhqmF6NMwbI5Otk18zzdw0ldkvl0Ap1PvxdX4O8eDKKyKfIKxl0Av7pQrcJ8rtT(DOw8d3AHwlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT16FTG5ymhvC1g51YP2uR3Av7pQrcJ8rtTGUwiHBTEaIv(3Oei2(6yVdyc4bafErcaKbIPuDnega(aI5t)00kqS3ADVHaJ4Mg2ssZn1HDHRvqOwV1YfPdyYw7HAJUwO1oexKoGj53ouT(xloR1tTcc1YfPdyYw7HAHuTEQfATkSKlI4hRfATN60QRHyw9KKb0i5QStoqSY)gLaXj5t6GqjWdak8WraqgiMs11qya4diMp9ttRaXER19gcmIBAyljn3uh2fUwO1kwTC0jLA(SJqmTM1kiuR3ADVHa7yNydHjjhyKpACO8Lusd4gei2fUwO1YrNuQ5ZocX0AwRNAfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1IZA9uRGqTCr6aMS1EOwivRGqTU3qGXvzNC2fUwp1cTwfwYfr8J1cT2tDA11qmREsYaAKCv2jhiw5FJsGyrQjiDqOe4bafE4yaidetP6Aima8beZN(PPvGyV16EdbgXnnSLKMBQd7cxl0AfRwo6KsnF2riMwZAfeQ1BTU3qGDStSHWKKdmYhnou(skPbCdce7cxl0A5Otk18zhHyAnR1tTcc16TwUiDat2ApuB01cT2H4I0bmj)2HQ1)AXzTEQvqOwUiDat2ApulKQvqOw3BiW4QSto7cxRNAHwRcl5Ii(XAHw7PoT6AiMvpjzansUk7KdeR8VrjqC4AmshekbEaqHxKcazGyL)nkbI9PZ0OrIcsYCtciMs11qya4d4bav04cazGykvxdHbGpGy(0pnTcetCtdBjwNsZn1PwbHAjUPHTeZIm6itsCFTcc1sCtdBjMMqitsCFTcc16EdbMpDMgnsuqsMBsSlCTqR19gcmIBAyljn3uh2fUwbHA9wR7neyCv2jNnKJ2PTw)Rv5FJsMVrFrmsCe)(K8BhQwO16EdbgxLDYzx4A9aeR8VrjqS91j0db8aGkA8aGmqSY)gLaX(g9fbetP6Aima8b8aGk6ObGmqmLQRHWaWhqSY)gLaXZnLk)BuknT9bInT9LP6qaXb1yErZf4bEGyfraqgau4bazGykvxdHbGpGyemqSLEGyL)nkbIp1PvxdbeFQMlbe7Tw3BiW(2H8HMuInK642jgnSHC0oT16FTG5ymhvC1grT4YWRwbHADVHa7BhYhAsj2qQJBNy0WgYr70wR)1Q8VrjZ(6e6HyK4i(9j53ouTrulUm8QfATERL4Mg2sSoLMBQtTcc1sCtdBjMfz0rMK4(AfeQL4Mg2smnHqMK4(A9uRNAHwR7neyF7q(qtkXgsDC7eJg2fUwO1o3KcObmX(2H8HMuInK642jgnmceDByycdi(uhzQoeqm2qQJ0xBmYGAmsuia8aGkAaidetP6Aima8beZN(PPvGyV1EQtRUgIXr5j6ijXilejVwO1kwTCeYGH8LmUk7KZgsXGOwbHADVHaJRYo5SlCTEQfATQ9h1iHr(OPw)RfN4wl0A9wR7neye30WwsAUPoSHC0oT16xTrsTcc16EdbgXnnSLKwKrh2qoAN2A9R2iPwp1cTwV1kwTZnPaAatmx1OjNKOGung5lQtWwgLQRHWQvqOw3BiWCvJMCsIcs1yKVOobBLP(3Hy2x5hLNQ5s16xTqc3AfeQ19gcmx1OjNKOGung5lQtWwPoCnjM9v(r5PAUuT(vlKWTwp1kiuBObl6Ld5ODAR1)AXdxGyL)nkbI5O8eDKKVisAH7PFlWdakibazGykvxdHbGpGy(0pnTce7EdbM91jOgdBOWqwrQRHQfATER1ctgJ81bm9wM91jOgtT(xlKQvqOwXQDUjfqdyI9Td5dnPeBi1XTtmAyei62WWewTEQfATERvSANBsb0aMygi46OwzWq03jyjyt7aBjgbIUnmmHvRGqTF7q1I)1IF4Sw)Q19gcm7Rtqng2qoAN2AJO2OR1dqSY)gLaX2xNGAmapaOWpaidetP6Aima8beZN(PPvG45MuanGj23oKp0KsSHuh3oXOHrGOBddty1cTwlmzmYxhW0Bz2xNGAm163HAHuTqR1BTIvR7neyF7q(qtkXgsDC7eJg2fUwO16EdbM91jOgdBOWqwrQRHQvqOwV1EQtRUgIHnK6i91gJmOgJefc1cTwV16EdbM91jOgdBihTtBT(xlKQvqOwlmzmYxhW0Bz2xNGAm16xTrxl0AF1q5ZSpzm6iXMo8mkvxdHvl0ADVHaZ(6euJHnKJ2PTw)RfN16Pwp16biw5FJsGy7RtqngGhau4eaYaXuQUgcdaFaXiyGyl9aXk)BuceFQtRUgci(unxciwT)OgjmYhn16xT4yCRfhuR3AXd3AJ8ADVHa7BhYhAsj2qQJBNy0WSVYpwRNAXb16Tw3BiWSVob1yyd5ODARnYRfs1c6ATWKXifP2NQ1tT4GA9wlg6zH7aHefKK5MeBihTtBTrET4Swp1cTw3BiWSVob1yyxyG4tDKP6qaX2xNGAmsFO8Lb1yKOqa4bavKaazGykvxdHbGpGy(0pnTceFQtRUgIHnK6i91gJmOgJefc1cT2tDA11qm7RtqngPpu(YGAmsuiuRGqTER19gcmx1OjNKOGung5lQtWwzQ)DiM9v(r5PAUuT(vlKWTwbHADVHaZvnAYjjkivJr(I6eSvQdxtIzFLFuEQMlvRF1cjCR1tTqR1ctgJ81bm9wM91jOgtT(xl(beR8VrjqS91XEhWeWdakCeaKbIPuDnega(aIv(3Oei2EZqpeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)Qfp8RwCqTwyYyKVoGP3wBe1oKJ2PTwO1QWsUiIFSwO1sCtdBjwNsnHaiMdb3qYxhW0BbafEapaOWXaqgiMs11qya4diw5FJsGyftH)(KKwF64aeZN(PPvGyXQ9B(Xobxl0AfRwL)nkzkMc)9jjT(0XrIPokyI1PmyAWI(AfeQfd9mftH)(KKwF64iXuhfmXSVYpwR)1cPAHwlg6zkMc)9jjT(0XrIPokyInKJ2PTw)RfsaXCi4gs(6aMElaOWd4bavKcazGykvxdHbGpGyL)nkbIDqOm0dbeZN(PPvG4HcdzfPUgQwO1(6aME23oK8rsSMQ1VA9wlE4xTruR3ATWKXiFDatVLzFDc9q1g51IhdN16Pwp1c6ATWKXiFDatVT2iQDihTtBTqR1BTCeYGH8LmUk7KZgsXGOwO16T2tDA11qmokprhjjgzHi51kiulhHmyiFjJJYt0rs(IiPfUN(TSHumiQvqOwXQLJoPuZNLnyrVmOuTEQvqOwlmzmYxhW0Bz2xNqpuT(xR3AXVAJ8A9wlE1grTVAO8zVVoLoiuAzuQUgcRwp16PwbHA9wlXnnSLyDkTiJo1kiuR3AjUPHTeRtPl6fvRGqTe30WwI1P0CtDQ1tTqRvSAF1q5ZSORrIcYxejdOHSpJs11qy1kiuR7neyWt7GgSwnsD4A2Cj81y1HDQMlvRFhQnACIBTEQfATER1ctgJ81bm9wM91j0dvR)1IhU1g516Tw8QnIAF1q5ZEFDkDqO0YOuDnewTEQ1tTqRvT)OgjmYhn16xT4e3AXb16EdbM91jOgdBihTtBTrETrsTEQfATERvSADVHa7yNydHjjhyKpACO8Lusd4gei2fUwbHAjUPHTeRtPfz0PwbHAfRwo6KsnF2riMwZA9ul0AvyjxeXpceZHGBi5Rdy6TaGcpGhau4HlaKbIPuDnega(aI5t)00kqScl5Ii(rGyL)nkbIdOHtsuqM6Fhc4bafE4bazGykvxdHbGpGy(0pnTce7EdbgxLDYzxyGyL)nkbIh9Ks01kddLGaeapaOWlAaidetP6Aima8beZN(PPvGyV16EdbM91jOgd7cxRGqTQ9h1iHr(OPw)QfN4wRNAHwRy16EdbMfzSFZj2fUwO1kwTU3qGXvzNC2fUwO16TwXQLJoPuZNLnyrVmOuTcc1EQtRUgIXr5j6ijXilejVwbHA5iKbd5lzCuEIosYxejTW90VLDHRvqO2oFAGrg9jmzObl6Ld5ODAR1)AJg3AJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16biw5FJsGyozi73QrQMgC6q5d8aGcpibazGykvxdHbGpGy(0pnTce7Tw3BiWSVob1yyx4AfeQvT)OgjmYhn16xT4e3A9ul0AfRw3BiWSiJ9BoXUW1cTwXQ19gcmUk7KZUW1cTwV1kwTC0jLA(SSbl6LbLQvqO2tDA11qmokprhjjgzHi51kiulhHmyiFjJJYt0rs(IiPfUN(TSlCTcc125tdmYOpHjdnyrVCihTtBT(xlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnyrVCihTtBT4FT4HJXTw)Rfs4wBe16TwokXU9ZGhI3wsQMgC6q5Z(2HKNQ5s16PwpaXk)Buce3jxNu)gLapaOWd)aGmqmLQRHWaWhqmF6NMwbI78Pbgz0NWKHgSOxoKJ2PTw)RfpCwRGqTER19gcm4PDqdwRgPoCnBUe(AS6WovZLQ1)AJgN4wRGqTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(DO2OXjU16PwO16EdbM91jOgd7cxl0A5iKbd5lzCv2jNnKJ2PTw)QfN4ceR8Vrjqm5aJ8rJ0fLyapaOWdNaqgiMs11qya4diw5FJsGy7tgJoYGrhciMp9ttRaXdfgYksDnuTqR9Bhs(ijwt16xT4HZAHwRfMmg5Rdy6Tm7RtOhQw)Rf)QfATkSKlI4hRfATER19gcmUk7KZgYr70wRF1IhU1kiuRy16EdbgxLDYzx4A9aeZHGBi5Rdy6TaGcpGhau4fjaqgiMs11qya4diMp9ttRaXe30WwI1PutiQfATkSKlI4hRfATU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB04e3AHwR3AXqptXu4VpjP1Noosm1rbtSV5h7eCTcc1kwTC0jLA(SK4dYGgSAfeQ1ctgJ81bm92A9R2OR1dqSY)gLaXH7aHefKK5MeWdak8WraqgiMs11qya4diMp9ttRaXU3qGHs6fzLW0Wj4Vrj7cxl0A9wR7ney2xNGAmSHcdzfPUgQwbHAv7pQrcJ8rtT(vBKIBTEaIv(3Oei2(6euJb4bafE4yaidetP6Aima8beZN(PPvGyo6KsnFw2Gf9YGs1cTwV1EQtRUgIXr5j6ijXilejVwbHA5iKbd5lzCv2jNDHRvqOw3BiW4QSto7cxRNAHwlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT16FTG5ymhvC1g51YP2uR3Av7pQrcJ8rtTGUwCIBTEQfATU3qGzFDcQXWgYr70wR)1IFaXk)BuceBFDcQXa8aGcVifaYaXuQUgcdaFaX8PFAAfiMJoPuZNLnyrVmOuTqR1BTN60QRHyCuEIossmYcrYRvqOwoczWq(sgxLDYzx4AfeQ19gcmUk7KZUW16PwO1YridgYxY4O8eDKKVisAH7PFlBihTtBT(xBKul0ADVHaZ(6euJHDHRfATe30WwI1PutiaIv(3Oei2(6yVdyc4bav04cazGykvxdHbGpGy(0pnTce7EdbgkPxKvYnKoYZ22OKDHRvqOwV1kwT2xNqpetHLCre)yTcc16Tw3BiW4QStoBihTtBT(xloRfATU3qGXvzNC2fUwbHA9wR7neyJEsj6ALHHsqac2qoAN2A9VwWCmMJkUAJ8A5uBQ1BTQ9h1iHr(OPwqxlKWTwp1cTw3BiWg9Ks01kddLGaeSlCTEQ1tTqR9uNwDneZ(6euJr6dLVmOgJefc1cTwlmzmYxhW0Bz2xNGAm16FTqQwp1cTwV1kwTZnPaAatSVDiFOjLydPoUDIrdJar3ggMWQvqOwlmzmYxhW0Bz2xNGAm16FTqQwpaXk)BuceBFDS3bmb8aGkA8aGmqmLQRHWaWhqmF6NMwbI9wlXnnSLyDk1eIAHwlhHmyiFjJRYo5SHC0oT16xT4e3AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1IZA9uRGqTCr6aMS1EOwivRNAHwRcl5Ii(rGyL)nkbItYN0bHsGhaurhnaKbIPuDnega(aI5t)00kqS3AjUPHTeRtPMqul0A5iKbd5lzCv2jNnKJ2PTw)QfN4wRGqTERLlshWKT2d1gDTqRDiUiDatYVDOA9VwCwRNAfeQLlshWKT2d1cPA9ul0AvyjxeXpceR8VrjqSi1eKoiuc8aGkAibazGykvxdHbGpGy(0pnTce7TwIBAylX6uQje1cTwoczWq(sgxLDYzd5ODAR1VAXjU1kiuR3A5I0bmzR9qTrxl0AhIlshWK8BhQw)RfN16PwbHA5I0bmzR9qTqQwp1cTwfwYfr8JaXk)BucehUgJ0bHsGhaurJFaqgiw5FJsGyF6mnAKOGKm3KaIPuDnega(aEaqfnobGmqmLQRHWaWhqmcgi2spqSY)gLaXN60QRHaIpvZLaITWKXiFDatVLzFDc9q16xT4xTruBWGqtTER1rTpnqipvZLQf01gnU16P2iQnyqOPwV16EdbM91XEhWKKCGr(OXHYxArgDy2x5hRf01IF16bi(uhzQoeqS91j0dj7uArgDaEaqfDKaazGykvxdHbGpGy(0pnTcetCtdBjM5M6itsCFTcc1sCtdBjMMqitsCFTqR9uNwDneRTsUH0tQwbHADVHaJ4Mg2sslYOdBihTtBT(xRY)gLm7RtOhIrIJ43NKF7q1cTw3BiWiUPHTK0Im6WUW1kiulXnnSLyDkTiJo1cTwXQ9uNwDneZ(6e6HKDkTiJo1kiuR7neyCv2jNnKJ2PTw)Rv5FJsM91j0dXiXr87tYVDOAHwRy1EQtRUgI1wj3q6jvl0ADVHaJRYo5SHC0oT16FTK4i(9j53ouTqR19gcmUk7KZUW1kiuR7neyJEsj6ALHHsqac2fUwO1AHjJrksTpvRF1IllsQfATER1ctgJ81bm92A9)qTqQwbHAfR2xnu(ml6AKOG8frYaAi7ZOuDnewTEQvqOwXQ9uNwDneRTsUH0tQwO16EdbgxLDYzd5ODAR1VAjXr87tYVDiGyL)nkbI9n6lc4bav04iaideR8VrjqS91j0dbetP6Aima8b8aGkACmaKbIPuDnega(aIv(3OeiEUPu5FJsPPTpqSPTVmvhcioOgZlAUapWdehuJ5fnxaidak8aGmqmLQRHWaWhqmF6NMwbIfR25MuanGjMRA0KtsuqQgJ8f1jylJar3ggMWaIv(3Oei2(6yVdyc4bav0aqgiMs11qya4diw5FJsGy7nd9qaX8PFAAfigd9mhekd9qSHC0oT16xTd5ODAbI5qWnK81bm9waqHhWdakibazGyL)nkbIDqOm0dbetP6Aima8b8apqS9bGmaOWdaYaXuQUgcdaFaXk)BuceRyk83NK06thhGy(0pnTcelwTyONPyk83NK06thhjM6OGj238JDcUwO1kwTk)BuYumf(7tsA9PJJetDuWeRtzW0Gf91cTwV1kwTyONPyk83NK06thhPisnSV5h7eCTcc1IHEMIPWFFssRpDCKIi1WgYr70wRF1IZA9uRGqTyONPyk83NK06thhjM6OGjM9v(XA9Vwivl0AXqptXu4VpjP1Noosm1rbtSHC0oT16FTqQwO1IHEMIPWFFssRpDCKyQJcMyFZp2jyGyoeCdjFDatVfau4b8aGkAaidetP6Aima8beZN(PPvGyV1EQtRUgIXr5j6ijXilejVwO1kwTCeYGH8LmUk7KZgsXGOwbHADVHaJRYo5SlCTEQfATQ9h1iHr(OPw)Rf)WTwO16Tw3BiWiUPHTK0CtDyd5ODAR1VAXd3AfeQ19gcmIBAyljTiJoSHC0oT16xT4HBTEQvqO2qdw0lhYr70wR)1IhUaXk)BuceZr5j6ijFrK0c3t)wGhauqcaYaXuQUgcdaFaXiyGyl9aXk)BuceFQtRUgci(unxci2BTU3qGXvzNC2qoAN2A9RwCwl0A9wR7neyJEsj6ALHHsqac2qoAN2A9RwCwRGqTIvR7neyJEsj6ALHHsqac2fUwp1kiuRy16EdbgxLDYzx4AfeQvT)OgjmYhn16FTqc3A9ul0A9wRy16Edb2XoXgctsoWiF04q5lPKgWniqSlCTcc1Q2FuJeg5JMA9VwiHBTEQfATER19gcmIBAyljTiJoSHC0oT16xTG5ymhvC1kiuR7neye30WwsAUPoSHC0oT16xTG5ymhvC16bi(uhzQoeqmg6LdbIU9qou(wGhau4haKbIPuDnega(aIv(3Oei2bHYqpeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)QfVORfATERvHLCre)yTqR9uNwDnedd9YHar3EihkFBTEaI5qWnK81bm9waqHhWdakCcazGykvxdHbGpGyL)nkbIT3m0dbeZN(PPvG4HcdzfPUgQwO1(6aME23oK8rsSMQ1VAXl6AHwR3AvyjxeXpwl0Ap1PvxdXWqVCiq0ThYHY3wRhGyoeCdjFDatVfau4b8aGksaGmqmLQRHWaWhqSY)gLaX2NmgDKbJoeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)QfViPwO16TwfwYfr8J1cT2tDA11qmm0lhceD7HCO8T16biMdb3qYxhW0BbafEapaOWraqgiMs11qya4diMp9ttRaXkSKlI4hbIv(3OeioGgojrbzQ)DiGhau4yaidetP6Aima8beZN(PPvGy3BiW4QSto7cdeR8Vrjq8ONuIUwzyOeeGa4bavKcazGykvxdHbGpGy(0pnTce7TwV16EdbgXnnSLKwKrh2qoAN2A9Rw8WTwbHADVHaJ4Mg2ssZn1HnKJ2PTw)QfpCR1tTqRLJqgmKVKXvzNC2qoAN2A9RwiHBTqR1BTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB04hU1kiuRy1o3KcObmXGN2bnyTAK6W1S5s4RXQdJar3ggMWQ1tTEQvqOw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)ouB04iCRvqOwoczWq(sgxLDYzdPyqul0A9wRA)rnsyKpAQ1VAJuCRvqO2tDA11qS2kvevRhGyL)nkbIjhyKpAKUOed4bafE4cazGykvxdHbGpGy(0pnTce7Tw1(JAKWiF0uRF1gP4wl0A9wR7neyh7eBimj5aJ8rJdLVKsAa3GaXUW1kiuRy1YrNuQ5ZocX0AwRNAfeQLJoPuZNLnyrVmOuTcc1EQtRUgI1wPIOAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTrJBTruR3A9wBKwBKx7CtkGgWedEAh0G1QrQdxZMlHVgRomceDByycRwp1grTERLJsSB)m4H4TLKQPbNou(SVDi5PAUuTEQ1tTEQfATIvR7neyCv2jNDHRfATERvSA5Otk18zzdw0ldkvRGqTCeYGH8Lmokprhj5lIKw4E63YUW1kiuBNpnWiJ(eMm0Gf9YHC0oT16FTCeYGH8Lmokprhj5lIKw4E63YgYr70wBe1gj1kiuBNpnWiJ(eMm0Gf9YHC0oT1I)1Ihog3A9V2OXT2iQ1BTCuID7NbpeVTKunn40HYN9TdjpvZLQ1tTEaIv(3OeiMtgY(TAKQPbNou(apaOWdpaidetP6Aima8beZN(PPvGyV1Q2FuJeg5JMA9R2if3AHwR3ADVHa7yNydHjjhyKpACO8Lusd4gei2fUwbHAfRwo6KsnF2riMwZA9uRGqTC0jLA(SSbl6LbLQvqO2tDA11qS2kvevRGqTU3qG5AqimZ1(SlCTqR19gcmxdcHzU2NnKJ2PTw)Rfs4wBe16TwV1gP1g51o3KcObmXGN2bnyTAK6W1S5s4RXQdJar3ggMWQ1tTruR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRNA9uRNAHwRy16EdbgxLDYzx4AHwR3AfRwo6KsnFw2Gf9YGs1kiulhHmyiFjJJYt0rs(IiPfUN(TSlCTcc125tdmYOpHjdnyrVCihTtBT(xlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnyrVCihTtBT4FT4HJXTw)Rfs4wBe16TwokXU9ZGhI3wsQMgC6q5Z(2HKNQ5s16PwpaXk)Buce3jxNu)gLapaOWlAaidetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGyV1kwTCeYGH8LmUk7KZgsXGOwbHAfR2tDA11qmokprhjjgzHi51cTwo6KsnFw2Gf9YGs16bi(uhzQoeqSvpjzansUk7Kd8aGcpibazGykvxdHbGpGy(0pnTcetCtdBjwNsnHOwO1QWsUiIFSwO16Edbg80oObRvJuhUMnxcFnwDyNQ5s16FTrJF4wl0A9wlg6zkMc)9jjT(0XrIPokyI9n)yNGRvqOwXQLJoPuZNLeFqg0GvRNAHw7PoT6AiMvpjzansUk7KdeR8VrjqC4oqirbjzUjb8aGcp8daYaXuQUgcdaFaX8PFAAfi29gcmusViReMgob)nkzx4AHwR7ney2xNGAmSHcdzfPUgciw5FJsGy7RtqngGhau4HtaidetP6Aima8beZN(PPvGy3BiWSVog0GXgYr70wR)1IZAHwR3ADVHaJ4Mg2sslYOdBihTtBT(vloRvqOw3BiWiUPHTK0CtDyd5ODAR1VAXzTEQfATQ9h1iHr(OPw)QnsXfiw5FJsGyUMCYiDVHaqS7neKP6qaX2xhdAWaEaqHxKaazGykvxdHbGpGy(0pnTceZrNuQ5ZYgSOxguQwO1EQtRUgIXr5j6ijXilejVwO1YridgYxY4O8eDKKVisAH7PFlBihTtBT(xlobIv(3Oei2(6yVdyc4bafE4iaidetP6Aima8beZN(PPvG4xnu(m7tgJosSPdpJs11qy1cTwXQ9vdLpZ(6yqdgJs11qy1cTw3BiWSVob1yydfgYksDnuTqR1BTU3qGrCtdBjP5M6WgYr70wRF1gj1cTwIBAylX6uAUPo1cTw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnACIBTcc16Edbg80oObRvJuhUMnxcFnwDyNQ5s163HAJgN4wl0Av7pQrcJ8rtT(vBKIBTcc1IHEMIPWFFssRpDCKyQJcMyd5ODAR1VAXX1kiuRY)gLmftH)(KKwF64iXuhfmX6ugmnyrFTEQfATIvlhHmyiFjJRYo5SHumiaIv(3Oei2(6euJb4bafE4yaidetP6Aima8beZN(PPvGy3BiWqj9ISsUH0rE22gLSlCTcc16Edb2XoXgctsoWiF04q5lPKgWniqSlCTcc16EdbgxLDYzx4AHwR3ADVHaB0tkrxRmmuccqWgYr70wR)1cMJXCuXvBKxlNAtTERvT)OgjmYhn1c6AHeU16PwO16Edb2ONuIUwzyOeeGGDHRvqOwXQ19gcSrpPeDTYWqjiab7cxl0AfRwoczWq(s2ONuIUwzyOeeGGnKIbrTcc1kwTC0jLA(StkFrqm16PwbHAv7pQrcJ8rtT(vBKIBTqRL4Mg2sSoLAcbqSY)gLaX2xh7DatapaOWlsbGmqmLQRHWaWhqmF6NMwbIF1q5ZSVog0GXOuDnewTqR1BTU3qGzFDmObJDHRvqOw1(JAKWiF0uRF1gP4wRNAHwR7ney2xhdAWy2x5hR1)AHuTqR1BTU3qGrCtdBjPfz0HDHRvqOw3BiWiUPHTK0CtDyx4A9ul0ADVHadEAh0G1QrQdxZMlHVgRoSt1CPA9V2OXr4wl0A9wlhHmyiFjJRYo5SHC0oT16xT4HBTcc1kwTN60QRHyCuEIossmYcrYRfATC0jLA(SSbl6LbLQ1dqSY)gLaX2xh7DatapaOIgxaidetP6Aima8beZN(PPvGyV16Edbg80oObRvJuhUMnxcFnwDyNQ5s16FTrJJWTwbHADVHadEAh0G1QrQdxZMlHVgRoSt1CPA9V2OXjU1cT2xnu(m7tgJosSPdpJs11qy16PwO16EdbgXnnSLKwKrh2qoAN2A9RwCuTqRL4Mg2sSoLwKrNAHwRy16EdbgkPxKvctdNG)gLSlCTqRvSAF1q5ZSVog0GXOuDnewTqRLJqgmKVKXvzNC2qoAN2A9RwCuTqR1BTCeYGH8LmYbg5JgPlkXyd5ODAR1VAXr1kiuRy1YrNuQ5ZocX0AwRhGyL)nkbITVo27aMaEaqfnEaqgiMs11qya4diMp9ttRaXER19gcmIBAyljn3uh2fUwbHA9wlxKoGjBThQn6AHw7qCr6aMKF7q16FT4Swp1kiulxKoGjBThQfs16PwO1QWsUiIFSwO1EQtRUgIz1tsgqJKRYo5aXk)BuceNKpPdcLapaOIoAaidetP6Aima8beZN(PPvGyV16EdbgXnnSLKMBQd7cxl0AfRwo6KsnF2riMwZAfeQ1BTU3qGDStSHWKKdmYhnou(skPbCdce7cxl0A5Otk18zhHyAnR1tTcc16TwUiDat2ApuB01cT2H4I0bmj)2HQ1)AXzTEQvqOwUiDat2ApulKQvqOw3BiW4QSto7cxRNAHwRcl5Ii(XAHw7PoT6AiMvpjzansUk7KdeR8VrjqSi1eKoiuc8aGkAibazGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AHwRy1YrNuQ5ZocX0AwRGqTER19gcSJDIneMKCGr(OXHYxsjnGBqGyx4AHwlhDsPMp7ietRzTEQvqOwV1YfPdyYw7HAJUwO1oexKoGj53ouT(xloR1tTcc1YfPdyYw7HAHuTcc16EdbgxLDYzx4A9ul0AvyjxeXpwl0Ap1PvxdXS6jjdOrYvzNCGyL)nkbIdxJr6GqjWdaQOXpaideR8VrjqSpDMgnsuqsMBsaXuQUgcdaFapaOIgNaqgiMs11qya4diMp9ttRaXe30WwI1P0CtDQvqOwIBAylXSiJoYKe3xRGqTe30WwIPjeYKe3xRGqTU3qG5tNPrJefKK5Me7cxl0ADVHaJ4Mg2ssZn1HDHRvqOwV16EdbgxLDYzd5ODAR1)Av(3OK5B0xeJehXVpj)2HQfATU3qGXvzNC2fUwpaXk)BuceBFDc9qapaOIosaGmqSY)gLaX(g9fbetP6Aima8b8aGkACeaKbIPuDnega(aIv(3OeiEUPu5FJsPPTpqSPTVmvhcioOgZlAUapWde7I0haYaGcpaidetP6Aima8beZN(PPvGy3BiW4QSto7cdeR8Vrjq8ONuIUwzyOeeGa4bav0aqgiMs11qya4digbdeBPhiw5FJsG4tDA11qaXNQ5saXIvR7neyUQrtojrbPAmYxuNGTYu)7qSlCTqRvSADVHaZvnAYjjkivJr(I6eSvQdxtIDHbIp1rMQdbeZN(t0FHbEaqbjaidetP6Aima8beR8VrjqSIPWFFssRpDCaI5t)00kqS7neyUQrtojrbPAmYxuNGTYu)7qm7R8JYt1CPA9Vw8d3AHwR7neyUQrtojrbPAmYxuNGTsD4Asm7R8JYt1CPA9Vw8d3AHwR3AfRwm0Zumf(7tsA9PJJetDuWe7B(Xobxl0AfRwL)nkzkMc)9jjT(0XrIPokyI1PmyAWI(AHwR3AfRwm0Zumf(7tsA9PJJuePg238JDcUwbHAXqptXu4VpjP1NoosrKAyd5ODAR1VAHuTEQvqOwm0Zumf(7tsA9PJJetDuWeZ(k)yT(xlKQfATyONPyk83NK06thhjM6OGj2qoAN2A9VwCwl0AXqptXu4VpjP1Noosm1rbtSV5h7eCTEaI5qWnK81bm9waqHhWdak8daYaXuQUgcdaFaX8PFAAfi2BTN60QRHyCuEIossmYcrYRfATIvlhHmyiFjJRYo5SHumiQvqOw3BiW4QSto7cxRNAHwR3ADVHaZvnAYjjkivJr(I6eSvM6FhIDHRvqOw3BiWCvJMCsIcs1yKVOobBL6W1Kyx4A9uRGqTHgSOxoKJ2PTw)RfpCbIv(3OeiMJYt0rs(IiPfUN(TapaOWjaKbIPuDnega(aI5t)00kqS3ADVHaZvnAYjjkivJr(I6eSvM6FhInKJ2PTw)Qf)y4SwbHADVHaZvnAYjjkivJr(I6eSvQdxtInKJ2PTw)Qf)y4Swp1cTw1(JAKWiF0uRFhQnsXTwO16TwoczWq(sgxLDYzd5ODAR1VAXr1kiuR3A5iKbd5lzKdmYhnsxuIXgYr70wRF1IJQfATIvR7neyh7eBimj5aJ8rJdLVKsAa3GaXUW1cTwo6KsnF2riMwZA9uRhGyL)nkbI5AYjJ09gcaXU3qqMQdbeBFDmObd4bavKaazGykvxdHbGpGy(0pnTcelwTN60QRHy8P)e9x4AHwR3A5Otk18zzdw0ldkvRGqTCeYGH8LmUk7KZgYr70wRF1IJQvqOwV1YridgYxYihyKpAKUOeJnKJ2PTw)Qfhvl0AfRw3BiWo2j2qysYbg5JghkFjL0aUbbIDHRfATC0jLA(SJqmTM16PwpaXk)BuceBFDS3bmb8aGchbazGykvxdHbGpGy(0pnTce7TwoczWq(sghLNOJK8frslCp9Bzd5ODAR1)AXzTqR1BTN60QRHyCuEIossmYcrYRvqOwoczWq(sgxLDYzd5ODAR1)AXzTEQ1tTqRvT)OgjmYhn16xT4hU1cTwo6KsnFw2Gf9YGsaXk)BuceBFDS3bmb8aGchdazGykvxdHbGpGyL)nkbIT3m0dbeZN(PPvG4HcdzfPUgQwO1(6aME23oK8rsSMQ1VAXlsQfATERvHLCre)yTqR1BTN60QRHy8P)e9x4AfeQ1BTQ9h1iHr(OPw)Rfs4wl0AfRw3BiW4QSto7cxRNAfeQLJqgmKVKXvzNC2qkge16PwpaXCi4gs(6aMElaOWd4bavKcazGykvxdHbGpGyL)nkbIDqOm0dbeZN(PPvG4HcdzfPUgQwO1(6aME23oK8rsSMQ1VAXdsmCwl0A9wRcl5Ii(XAHwR3Ap1PvxdX4t)j6VW1kiuR3Av7pQrcJ8rtT(xlKWTwO1kwTU3qGXvzNC2fUwp1kiulhHmyiFjJRYo5SHumiQ1tTqRvSADVHa7yNydHjjhyKpACO8Lusd4gei2fUwpaXCi4gs(6aMElaOWd4bafE4cazGykvxdHbGpGyL)nkbITpzm6idgDiGy(0pnTcepuyiRi11q1cT2xhW0Z(2HKpsI1uT(vlErsTru7qoAN2AHwR3AvyjxeXpwl0A9w7PoT6AigF6pr)fUwbHAv7pQrcJ8rtT(xlKWTwbHA5iKbd5lzCv2jNnKIbrTEQ1dqmhcUHKVoGP3cak8aEaqHhEaqgiMs11qya4diMp9ttRaXkSKlI4hbIv(3OeioGgojrbzQ)DiGhau4fnaKbIPuDnega(aI5t)00kqS3AjUPHTeRtPMquRGqTe30WwIzrgDKDkXRwbHAjUPHTeZCtDKDkXRwp1cTwV1kwTC0jLA(SSbl6LbLQvqOwV1Q2FuJeg5JMA9V2ifN1cTwV1EQtRUgIXN(t0FHRvqOw1(JAKWiF0uR)1cjCRvqO2tDA11qS2kvevRNAHwR3Ap1PvxdX4O8eDKKyKfIKxl0AfRwoczWq(sghLNOJK8frslCp9Bzx4AfeQvSAp1PvxdX4O8eDKKyKfIKxl0AfRwoczWq(sgxLDYzx4A9uRNA9ul0A9wlhHmyiFjJRYo5SHC0oT16xTqc3AfeQvT)OgjmYhn16xTrkU1cTwoczWq(sgxLDYzx4AHwR3A5iKbd5lzKdmYhnsxuIXgYr70wR)1Q8VrjZ(6e6HyK4i(9j53ouTcc1kwTC0jLA(SJqmTM16PwbHA78Pbgz0NWKHgSOxoKJ2PTw)RfpCR1tTqR1BTyONPyk83NK06thhjM6OGj2qoAN2A9Rw8RwbHAfRwo6KsnFws8bzqdwTEaIv(3OeioChiKOGKm3KaEaqHhKaGmqmLQRHWaWhqmF6NMwbI9wlXnnSLyMBQJmjX91kiulXnnSLywKrhzsI7RvqOwIBAylX0eczsI7RvqOw3BiWCvJMCsIcs1yKVOobBLP(3Hyd5ODAR1VAXpgoRvqOw3BiWCvJMCsIcs1yKVOobBL6W1Kyd5ODAR1VAXpgoRvqOw1(JAKWiF0uRF1gP4wl0A5iKbd5lzCv2jNnKIbrTEQfATERLJqgmKVKXvzNC2qoAN2A9RwiHBTcc1YridgYxY4QStoBifdIA9uRGqTD(0aJm6tyYqdw0lhYr70wR)1IhUaXk)BucetoWiF0iDrjgWdak8WpaidetP6Aima8beZN(PPvGyV1Q2FuJeg5JMA9R2if3AHwR3ADVHa7yNydHjjhyKpACO8Lusd4gei2fUwbHAfRwo6KsnF2riMwZA9uRGqTC0jLA(SSbl6LbLQvqOw3BiWCnieM5AF2fUwO16EdbMRbHWmx7ZgYr70wR)1gnU1grTERLJsSB)m4H4TLKQPbNou(SVDi5PAUuTEQ1tTqR1BTN60QRHyCuEIossmYcrYRvqOwoczWq(sghLNOJK8frslCp9BzdPyquRNAfeQTZNgyKrFctgAWIE5qoAN2A9V2OXT2iQ1BTCuID7NbpeVTKunn40HYN9TdjpvZLQ1dqSY)gLaXCYq2VvJunn40HYh4bafE4eaYaXuQUgcdaFaX8PFAAfi2BTQ9h1iHr(OPw)QnsXTwO16Tw3BiWo2j2qysYbg5JghkFjL0aUbbIDHRvqOwXQLJoPuZNDeIP1Swp1kiulhDsPMplBWIEzqPAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTqc3AJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16PwO16T2tDA11qmokprhjjgzHi51kiulhHmyiFjJJYt0rs(IiPfUN(TSHumiQ1tTcc125tdmYOpHjdnyrVCihTtBT(xlKWT2iQ1BTCuID7NbpeVTKunn40HYN9TdjpvZLQ1dqSY)gLaXDY1j1VrjWdak8IeaidetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGyIBAylX6uAUPo1g51IJRf01Q8VrjZ(6e6HyK4i(9j53ouTruRy1sCtdBjwNsZn1P2iV2iPwqxRY)gLmFJ(IyK4i(9j53ouTrulUSORf01AHjJrksTpbeFQJmvhciwTWIFPjM4apaOWdhbazGykvxdHbGpGy(0pnTce7T2oFAGrg9jmzObl6Ld5ODAR1)AXVAfeQ1BTU3qGn6jLORvggkbbiyd5ODAR1)AbZXyoQ4QnYRLtTPwV1Q2FuJeg5JMAbDTqc3A9ul0ADVHaB0tkrxRmmuccqWUW16Pwp1kiuR3Av7pQrcJ8rtTru7PoT6AiMAHf)stmXRnYR19gcmIBAyljTiJoSHC0oT1grTyONfUdesuqsMBsSV5hTYHC0oRnYRnAgoR1VAXlACRvqOw1(JAKWiF0uBe1EQtRUgIPwyXV0et8AJ8ADVHaJ4Mg2ssZn1HnKJ2PT2iQfd9SWDGqIcsYCtI9n)OvoKJ2zTrETrZWzT(vlErJBTEQfATe30WwI1PutiQfATER1BTIvlhHmyiFjJRYo5SlCTcc1YrNuQ5ZocX0Awl0AfRwoczWq(sg5aJ8rJ0fLySlCTEQvqOwo6KsnFw2Gf9YGs16PwO16TwXQLJoPuZNDs5lcIPwbHAfRw3BiW4QSto7cxRGqTQ9h1iHr(OPw)QnsXTwp1kiuR7neyCv2jNnKJ2PTw)Qfhxl0AfRw3BiWg9Ks01kddLGaeSlmqSY)gLaX2xh7DatapaOWdhdazGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1IZA9uRGqTCr6aMS1EOwivRNAHwRcl5Ii(rGyL)nkbItYN0bHsGhau4fPaqgiMs11qya4diMp9ttRaXER19gcmIBAyljn3uh2fUwbHA9wlxKoGjBThQn6AHw7qCr6aMKF7q16FT4Swp1kiulxKoGjBThQfs16PwO1QWsUiIFeiw5FJsGyrQjiDqOe4bav04cazGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1IZA9uRGqTCr6aMS1EOwivRNAHwRcl5Ii(rGyL)nkbIdxJr6GqjWdaQOXdaYaXk)Buce7tNPrJefKK5MeqmLQRHWaWhWdaQOJgaYaXuQUgcdaFaX8PFAAfiM4Mg2sSoLMBQtTcc1sCtdBjMfz0rMK4(AfeQL4Mg2smnHqMK4(AfeQ19gcmF6mnAKOGKm3Kyx4AHwR7neye30WwsAUPoSlCTcc16Tw3BiW4QStoBihTtBT(xRY)gLmFJ(IyK4i(9j53ouTqR19gcmUk7KZUW16biw5FJsGy7RtOhc4bav0qcaYaXk)Buce7B0xeqmLQRHWaWhWdaQOXpaidetP6Aima8beR8Vrjq8CtPY)gLstBFGytBFzQoeqCqnMx0CbEGh4bIpPX2OeaurJB04Ix04gPaX(0j7eSfighU4T4fqHdduI)eF1wlKfr12oWO5RnGMAfpydPoUDIrJ4P2Har3EiSATihQw9(ih9jSA5I0emzzvuG4oPAJw8vBKHYtAEcR242jYQ1cr(Q4Qf)R9r1cIVATy9zBBuwlcMg9rtTEbTNA9IN48WQOaXDs1IhEIVAJmuEsZty1g3orwTwiYxfxT4p(x7JQfeF1ADqyxZ1wlcMg9rtTEXFp16fpX5HvrbI7KQfVOfF1gzO8KMNWQnUDISATqKVkUAXF8V2hvli(Q16GWUMRTwemn6JMA9I)EQ1lEIZdRIce3jvlE4u8vBKHYtAEcR242jYQ1cr(Q4Qf)R9r1cIVATy9zBBuwlcMg9rtTEbTNA9IN48WQOQOWHlElEbu4WaL4pXxT1czruTTdmA(AdOPwXdgf0R5fp1oei62dHvRf5q1Q3h5OpHvlxKMGjlRIce3jvBKi(QnYq5jnpHvBC7ez1AHiFvC1I)1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEJwCEyvuvu4WfVfVakCyGs8N4R2AHSiQ22bgnFTb0uR4bEioYXvFXtTdbIU9qy1ArouT69ro6ty1YfPjyYYQOaXDs1ItXxTrgkpP5jSAfpZnPaAatmXpINAFuTIN5MuanGjM4hgLQRHWep16fpX5HvrbI7KQnseF1gzO8KMNWQv8m3KcObmXe)iEQ9r1kEMBsb0aMyIFyuQUgct8uRx8eNhwfvffoCXBXlGchgOe)j(QTwilIQTDGrZxBan1kEuejEQDiq0ThcRwlYHQvVpYrFcRwUinbtwwffiUtQ2OfF1gzO8KMNWQv8m3KcObmXe)iEQ9r1kEMBsb0aMyIFyuQUgct8uRx8eNhwffiUtQwij(QnYq5jnpHvBC7ez1AHiFvC1I)4FTpQwq8vR1bHDnxBTiyA0hn16f)9uRx8eNhwffiUtQwCk(QnYq5jnpHvBC7ez1AHiFvC1I)1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXtCEyvuG4oPAJuXxTrgkpP5jSAJBNiRwle5RIRw8V2hvli(Q1I1NTTrzTiyA0hn16f0EQ1lEIZdRIce3jvlEqs8vBKHYtAEcR242jYQ1cr(Q4Qf)X)AFuTG4RwRdc7AU2ArW0OpAQ1l(7PwV4jopSkkqCNuT4HJfF1gzO8KMNWQnUDISATqKVkUAX)AFuTG4RwlwF22gL1IGPrF0uRxq7PwV4jopSkkqCNuTrJR4R2idLN08ewTXTtKvRfI8vXvl(x7JQfeF1AX6Z22OSwemn6JMA9cAp16fpX5HvrbI7KQnACk(QnYq5jnpHvBC7ez1AHiFvC1I)1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEJwCEyvuvu4WfVfVakCyGs8N4R2AHSiQ22bgnFTb0uR4X(INAhceD7HWQ1ICOA17JC0NWQLlstWKLvrbI7KQfpCfF1gzO8KMNWQnUDISATqKVkUAXF8V2hvli(Q16GWUMRTwemn6JMA9I)EQ1lEIZdRIce3jvlE4j(QnYq5jnpHvBC7ez1AHiFvC1I)4FTpQwq8vR1bHDnxBTiyA0hn16f)9uRx8eNhwffiUtQw8WXIVAJmuEsZty1g3orwTwiYxfxT4FTpQwq8vRfRpBBJYArW0OpAQ1lO9uRx8eNhwfvffoCXBXlGchgOe)j(QTwilIQTDGrZxBan1kECr6lEQDiq0ThcRwlYHQvVpYrFcRwUinbtwwffiUtQw8IeXxTrgkpP5jSAJBNiRwle5RIRw8V2hvli(Q1I1NTTrzTiyA0hn16f0EQ1lKeNhwffiUtQw8WrIVAJmuEsZty1g3orwTwiYxfxT4FTpQwq8vRfRpBBJYArW0OpAQ1lO9uRx8eNhwfvffomhy08ewT4OAv(3OSwtBFlRIci2ctCaqHhUrdedpOqBiGyCOAXNA0Kt1kE1CBSkkCOAfVI4KJln1Ih(bYAJg3OXTIQIchQ2itKMGjR4RIchQwCqTI3yyewTXiJo1IpsDyvu4q1IdQnYePjycR2xhW0l7qTC1s2AFuTCi4gs(6aMElRIchQwCqTIxih0jHv7ntItwRoqu7PoT6AiBTEBgXazTWdDkTVo27aMQfh4xTWdDYSVo27aM8WQOWHQfhuR49jQXQfEiUA)obxlo8rFr12HA7x8yR9fr16Bqj4AfVMBAylXQOWHQfhuR4F6rQ2idLNOJuTViQ2y4E63wRwRP)3q16GgQ2GHex7AOA92HAHaDRvKILINVwr9xB)1ABNR51KqxRbIA91VOAXN4)I3qU2iQnYidz)wn1kEBAWPdLpiRTFXdwT2JnShwfvfLY)gLwg8qCKJR(hCqO8yNYaACQOu(3O0YGhIJCC1pIdG(yNydHjTW90VTIs5FJsldEioYXv)ioaAFJ(IaPPtsYXoGhUGSdh8sCtdBjM5M6itsCVGaXnnSLyDkn3uhbbIBAylX6u6IErcce30WwIPjeYKe37PIs5FJsldEioYXv)ioaAFJ(Iazho4L4Mg2smZn1rMK4EbbIBAylX6uAUPocce30WwI1P0f9IeeiUPHTettiKjjU3du4Hoz4X8n6lcQyWdDYIM5B0xufLY)gLwg8qCKJR(rCa02xNqpei7WbXMBsb0aMyUQrtojrbPAmYxuNGTccIXrNuQ5ZYgSOxgusqqmlmzmYxhW0Bz2xNGAmhWtqqSxnu(Su)7qwPRA0KtmkvxdHvrP8VrPLbpeh54QFehaT91XEhWei7WH5MuanGjMRA0KtsuqQgJ8f1jyluo6KsnFw2Gf9YGsqTWKXiFDatVLzFDcQXCaVkQkkCOAfVwCe)(ewT0jnqu73ouTViQwL)OP22wREQTrDneRIs5FJs7blYOJ0LuNkkL)nkTho1PvxdbYuDOdTvQicKNQ5shSWKXiFDatVLzFDcQX4hEq9k2RgkFM91XGgmgLQRHWeeE1q5ZSpzm6iXMo8mkvxdH5rqWctgJ81bm9wM91jOgJFrxrP8VrPnIdG(uNwDneit1Ho0wj3q6jbYt1CPdwyYyKVoGP3YSVoHEi)WRIs5FJsBehaTlnwAo2jyq2HdEfJJoPuZNLnyrVmOKGGyCeYGH8Lmokprhj5lIKw4E63YUWEG6EdbgxLDYzx4kkL)nkTrCa0WOVrji7Wb3BiW4QSto7cxrP8VrPnIdG(uNwDneit1HoWr5j6ijXilejhKNQ5shcgeA86TZNgyKrFctgAWIE5qoANwCq04Id4iKbd5lzCuEIosYxejTW90VLnKJ2P1d(Jx046XVGbHgVE78Pbgz0NWKHgSOxoKJ2PfhenoXbEXd3i)vdLpRtUoP(nkzuQUgcZdoWlhLy3(zWdXBljvtdoDO8zF7qYt1Cjp4aoczWq(sgxLDYzd5ODA9G)4HJX1JGahHmyiFjJRYo5SHC0oT(15tdmYOpHjdnyrVCihTtRGahHmyiFjJJYt0rs(IiPfUN(TSHC0oT(15tdmYOpHjdnyrVCihTtRGGyC0jLA(SSbl6LbLQOu(3O0gXbqFTKSFYbKP6qh60YN7RUgscIUA(xhjgD2CcKD4G7neyCv2jNDHROWHQv5FJsBeha91sY(jhliTg0Bp8tNhPhpq2HdI9tNhPNHhtKALWdIZ0ecOEf7NopsplAMi1kHheNPjeccI9tNhPNfnBifdcjhHmyiFPhbb3BiW4QSto7cliWridgYxY4QStoBihTtloapC97NopspdpghHmyiFjd7o63OeQyC0jLA(SJqmTMccC0jLA(SSbl6LbLGEQtRUgIXr5j6ijXilejhkhHmyiFjJJYt0rs(IiPfUN(TSlSGG7neyh7eBimj5aJ8rJdLVKsAa3GaXUWccHgSOxoKJ2P1)OXTIchQwL)nkTrCa0xlj7NCSG0AqV9WpDEK(Obzhoi2pDEKEw0mrQvcpiottiG6vSF68i9m8yIuReEqCMMqiii2pDEKEgESHumiKCeYGH8LEee(PZJ0ZWJjsTs4bXzAcb0F68i9SOzIuReEqCMMqavSF68i9m8ydPyqi5iKbd5lfeCVHaJRYo5SlSGahHmyiFjJRYo5SHC0oT4a8W1VF68i9SOzCeYGH8LmS7OFJsOIXrNuQ5ZocX0AkiWrNuQ5ZYgSOxguc6PoT6AighLNOJKeJSqKCOCeYGH8Lmokprhj5lIKw4E63YUWccU3qGDStSHWKKdmYhnou(skPbCdce7clieAWIE5qoANw)Jg3kkL)nkTrCa0xlj7NCSvuk)BuAJ4aONBkv(3OuAA7dYuDOdkIaP9NM)hWdKD4WPoT6AiwBLkIQOu(3O0gXbqp3uQ8VrP002hKP6qhWgsDC7eJgqA)P5)b8azhom3KcObmX(2H8HMuInK642jgnmceDByycRIs5FJsBeha9CtPY)gLstBFqMQdDWfPpiT)08)aEGSdhMBsb0aMyUQrtojrbPAmYxuNGTmceDByycRIs5FJsBeha9CtPY)gLstBFqMQdDW(vuvuk)BuAzkIoCQtRUgcKP6qhWgsDK(AJrguJrIcbqEQMlDWR7neyF7q(qtkXgsDC7eJg2qoANw)bZXyoQ4IaxgEccU3qG9Td5dnPeBi1XTtmAyd5ODA9x5FJsM91j0dXiXr87tYVDOiWLHhuVe30WwI1P0CtDeeiUPHTeZIm6itsCVGaXnnSLyAcHmjX9E8a19gcSVDiFOjLydPoUDIrd7cdDUjfqdyI9Td5dnPeBi1XTtmAyei62WWewfLY)gLwMIOioaAokprhj5lIKw4E63cYoCW7PoT6AighLNOJKeJSqKCOIXridgYxY4QStoBifdcbb3BiW4QSto7c7bQA)rnsyKpA8hN4c1R7neye30WwsAUPoSHC0oT(fjccU3qGrCtdBjPfz0HnKJ2P1ViXduVIn3KcObmXCvJMCsIcs1yKVOobBfeCVHaZvnAYjjkivJr(I6eSvM6FhIzFLFuEQMl5hKWvqW9gcmx1OjNKOGung5lQtWwPoCnjM9v(r5PAUKFqcxpccHgSOxoKJ2P1F8WTIs5FJsltruehaT91jOgdi7Wb3BiWSVob1yydfgYksDneuVwyYyKVoGP3YSVob1y8hsccIn3KcObmX(2H8HMuInK642jgnmceDByycZduVIn3KcObmXmqW1rTYGHOVtWsWM2b2smceDByyctq4Bhc)XF8dN(5EdbM91jOgdBihTtBer7PIs5FJsltruehaT91jOgdi7WH5MuanGj23oKp0KsSHuh3oXOHrGOBddtyqTWKXiFDatVLzFDcQX43bib1RyU3qG9Td5dnPeBi1XTtmAyxyOU3qGzFDcQXWgkmKvK6AibbVN60QRHyydPosFTXidQXirHauVU3qGzFDcQXWgYr706pKeeSWKXiFDatVLzFDcQX4x0qF1q5ZSpzm6iXMo8mkvxdHb19gcm7Rtqng2qoANw)XPhpEQOu(3O0YuefXbqFQtRUgcKP6qhSVob1yK(q5ldQXirHaipvZLoO2FuJeg5Jg)WX4Id8IhUrU7neyF7q(qtkXgsDC7eJgM9v(rp4aVU3qGzFDcQXWgYr70g5qc)TWKXifP2N8Gd8IHEw4oqirbjzUjXgYr70g540du3BiWSVob1yyx4kkL)nkTmfrrCa02xh7DatGSdho1PvxdXWgsDK(AJrguJrIcbON60QRHy2xNGAmsFO8Lb1yKOqqqWR7neyUQrtojrbPAmYxuNGTYu)7qm7R8JYt1Cj)GeUccU3qG5Qgn5KefKQXiFrDc2k1HRjXSVYpkpvZL8ds46bQfMmg5Rdy6Tm7Rtqng)XVkkL)nkTmfrrCa02Bg6HajhcUHKVoGP3Eapq2HddfgYksDne0xhW0Z(2HKpsI1KF4HF4almzmYxhW0BJyihTtlufwYfr8JqjUPHTeRtPMqurP8VrPLPikIdGwXu4VpjP1NooGKdb3qYxhW0BpGhi7WbX(MFStWqft5FJsMIPWFFssRpDCKyQJcMyDkdMgSOxqad9mftH)(KKwF64iXuhfmXSVYp6pKGIHEMIPWFFssRpDCKyQJcMyd5ODA9hsvuk)BuAzkII4aODqOm0dbsoeCdjFDatV9aEGSdhgkmKvK6AiOVoGPN9TdjFKeRj)8Ih(fHxlmzmYxhW0Bz2xNqpuKJhdNE8G)wyYyKVoGP3gXqoANwOE5iKbd5lzCv2jNnKIbbuVN60QRHyCuEIossmYcrYfe4iKbd5lzCuEIosYxejTW90VLnKIbHGGyC0jLA(SSbl6LbL8iiyHjJr(6aMElZ(6e6H83l(f5EXlIxnu(S3xNshekTmkvxdH5XJGGxIBAylX6uArgDee8sCtdBjwNsx0lsqG4Mg2sSoLMBQJhOI9QHYNzrxJefKVisgqdzFgLQRHWeeCVHadEAh0G1QrQdxZMlHVgRoSt1Cj)oenoX1duVwyYyKVoGP3YSVoHEi)Xd3i3lEr8QHYN9(6u6GqPLrP6AimpEGQ2FuJeg5Jg)WjU4a3BiWSVob1yyd5ODAJ8iXduVI5Edb2XoXgctsoWiF04q5lPKgWniqSlSGaXnnSLyDkTiJoccIXrNuQ5ZocX0A6bQcl5Ii(XkkL)nkTmfrrCa0b0Wjjkit9VdbYoCqHLCre)yfLY)gLwMIOioa6rpPeDTYWqjiabi7Wb3BiW4QSto7cxrP8VrPLPikIdGMtgY(TAKQPbNou(GSdh86EdbM91jOgd7cliO2FuJeg5Jg)WjUEGkM7neywKX(nNyxyOI5EdbgxLDYzxyOEfJJoPuZNLnyrVmOKGWPoT6AighLNOJKeJSqKCbboczWq(sghLNOJK8frslCp9BzxybHoFAGrg9jmzObl6Ld5ODA9pACJWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEQOu(3O0YuefXbq3jxNu)gLGSdh86EdbM91jOgd7cliO2FuJeg5Jg)WjUEGkM7neywKX(nNyxyOI5EdbgxLDYzxyOEfJJoPuZNLnyrVmOKGWPoT6AighLNOJKeJSqKCbboczWq(sghLNOJK8frslCp9BzxybHoFAGrg9jmzObl6Ld5ODA9NJqgmKVKXr5j6ijFrK0c3t)w2qoAN2iIebHoFAGrg9jmzObl6Ld5ODAXF8hpCmU(djCJWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEQOu(3O0YuefXbqtoWiF0iDrjgi7WHoFAGrg9jmzObl6Ld5ODA9hpCki419gcm4PDqdwRgPoCnBUe(AS6WovZL8pACIRGG7neyWt7GgSwnsD4A2Cj81y1HDQMl53HOXjUEG6EdbM91jOgd7cdLJqgmKVKXvzNC2qoANw)WjUvuk)BuAzkII4aOTpzm6idgDiqYHGBi5Rdy6ThWdKD4WqHHSIuxdb9Bhs(ijwt(HhoHAHjJr(6aMElZ(6e6H8h)GQWsUiIFeQx3BiW4QStoBihTtRF4HRGGyU3qGXvzNC2f2tfLY)gLwMIOioa6WDGqIcsYCtcKD4aXnnSLyDk1ecOkSKlI4hH6Edbg80oObRvJuhUMnxcFnwDyNQ5s(hnoXfQxm0Zumf(7tsA9PJJetDuWe7B(XobliighDsPMplj(GmObtqWctgJ81bm9w)I2tfLY)gLwMIOioaA7Rtqngq2HdU3qGHs6fzLW0Wj4Vrj7cd1R7ney2xNGAmSHcdzfPUgsqqT)OgjmYhn(fP46PIs5FJsltruehaT91jOgdi7Wbo6KsnFw2Gf9YGsq9EQtRUgIXr5j6ijXilejxqGJqgmKVKXvzNC2fwqW9gcmUk7KZUWEGYridgYxY4O8eDKKVisAH7PFlBihTtR)G5ymhvCroNAJx1(JAKWiF0G)4expqDVHaZ(6euJHnKJ2P1F8RIs5FJsltruehaT91XEhWei7Wbo6KsnFw2Gf9YGsq9EQtRUgIXr5j6ijXilejxqGJqgmKVKXvzNC2fwqW9gcmUk7KZUWEGYridgYxY4O8eDKKVisAH7PFlBihTtR)rcu3BiWSVob1yyxyOe30WwI1PutiQOu(3O0YuefXbqBFDS3bmbYoCW9gcmusViRKBiDKNTTrj7cli4vm7RtOhIPWsUiIFuqWR7neyCv2jNnKJ2P1FCc19gcmUk7KZUWccEDVHaB0tkrxRmmuccqWgYr706pyogZrfxKZP24vT)OgjmYhn4pKW1du3BiWg9Ks01kddLGaeSlShpqp1PvxdXSVob1yK(q5ldQXirHaulmzmYxhW0Bz2xNGAm(djpq9k2CtkGgWe7BhYhAsj2qQJBNy0Wiq0THHjmbblmzmYxhW0Bz2xNGAm(djpvuk)BuAzkII4aOtYN0bHsq2HdEjUPHTeRtPMqaLJqgmKVKXvzNC2qoANw)WjUccE5I0bmzpen0H4I0bmj)2H8hNEee4I0bmzpajpqvyjxeXpwrP8VrPLPikIdGwKAcshekbzho4L4Mg2sSoLAcbuoczWq(sgxLDYzd5ODA9dN4ki4LlshWK9q0qhIlshWK8BhYFC6rqGlshWK9aK8avHLCre)yfLY)gLwMIOioa6W1yKoiucYoCWlXnnSLyDk1ecOCeYGH8LmUk7KZgYr706hoXvqWlxKoGj7HOHoexKoGj53oK)40JGaxKoGj7bi5bQcl5Ii(XkkL)nkTmfrrCa0(0zA0irbjzUjvrP8VrPLPikIdG(uNwDneit1HoyFDc9qYoLwKrhqEQMlDWctgJ81bm9wM91j0d5h(frWGqJxh1(0aH8unxc)Jgxpremi0419gcm7RJ9oGjj5aJ8rJdLV0Im6WSVYpI)4NNkkL)nkTmfrrCa0(g9fbYoCG4Mg2smZn1rMK4EbbIBAylX0eczsI7HEQtRUgI1wj3q6jji4EdbgXnnSLKwKrh2qoANw)v(3OKzFDc9qmsCe)(K8BhcQ7neye30WwsArgDyxybbIBAylX6uArgDGk2PoT6AiM91j0dj7uArgDeeCVHaJRYo5SHC0oT(R8VrjZ(6e6HyK4i(9j53oeuXo1PvxdXARKBi9KG6EdbgxLDYzd5ODA9NehXVpj)2HG6EdbgxLDYzxybb3BiWg9Ks01kddLGaeSlmulmzmsrQ9j)WLfjq9AHjJr(6aMER)hGKGGyVAO8zw01irb5lIKb0q2NrP6AimpccIDQtRUgI1wj3q6jb19gcmUk7KZgYr706hjoIFFs(TdvrP8VrPLPikIdG2(6e6HQOu(3O0YuefXbqp3uQ8VrP002hKP6qhcQX8IMBfvfLY)gLwMls)dJEsj6ALHHsqacq2HdU3qGXvzNC2fUIs5FJslZfPFeha9PoT6AiqMQdDGp9NO)cdYt1CPdI5EdbMRA0KtsuqQgJ8f1jyRm1)oe7cdvm3BiWCvJMCsIcs1yKVOobBL6W1Kyx4kkL)nkTmxK(rCa0kMc)9jjT(0XbKCi4gs(6aME7b8azho4EdbMRA0KtsuqQgJ8f1jyRm1)oeZ(k)O8unxYF8dxOU3qG5Qgn5KefKQXiFrDc2k1HRjXSVYpkpvZL8h)WfQxXWqptXu4VpjP1Noosm1rbtSV5h7emuXu(3OKPyk83NK06thhjM6OGjwNYGPbl6H6vmm0Zumf(7tsA9PJJuePg238JDcwqad9mftH)(KKwF64ifrQHnKJ2P1pi5rqad9mftH)(KKwF64iXuhfmXSVYp6pKGIHEMIPWFFssRpDCKyQJcMyd5ODA9hNqXqptXu4VpjP1Noosm1rbtSV5h7eSNkkL)nkTmxK(rCa0CuEIosYxejTW90VfKD4G3tDA11qmokprhjjgzHi5qfJJqgmKVKXvzNC2qkgeccU3qGXvzNC2f2duVU3qG5Qgn5KefKQXiFrDc2kt9VdXUWccU3qG5Qgn5KefKQXiFrDc2k1HRjXUWEeecnyrVCihTtR)4HBfLY)gLwMls)ioaAUMCYiDVHait1HoyFDmObdKD4Gx3BiWCvJMCsIcs1yKVOobBLP(3Hyd5ODA9d)y4uqW9gcmx1OjNKOGung5lQtWwPoCnj2qoANw)Wpgo9avT)OgjmYhn(DisXfQxoczWq(sgxLDYzd5ODA9dhji4LJqgmKVKroWiF0iDrjgBihTtRF4iOI5Edb2XoXgctsoWiF04q5lPKgWniqSlmuo6KsnF2riMwtpEQOu(3O0YCr6hXbqBFDS3bmbYoCqStDA11qm(0FI(lmuVC0jLA(SSbl6LbLee4iKbd5lzCv2jNnKJ2P1pCKGGxoczWq(sg5aJ8rJ0fLySHC0oT(HJGkM7neyh7eBimj5aJ8rJdLVKsAa3GaXUWq5Otk18zhHyAn94PIs5FJslZfPFehaT91XEhWei7WbVCeYGH8Lmokprhj5lIKw4E63YgYr706poH69uNwDneJJYt0rsIrwisUGahHmyiFjJRYo5SHC0oT(JtpEGQ2FuJeg5Jg)WpCHYrNuQ5ZYgSOxguQIs5FJslZfPFehaT9MHEiqYHGBi5Rdy6ThWdKD4WqHHSIuxdb91bm9SVDi5JKyn5hErcuVkSKlI4hH69uNwDneJp9NO)cli4vT)OgjmYhn(djCHkM7neyCv2jNDH9iiWridgYxY4QStoBifdcpEQOu(3O0YCr6hXbq7GqzOhcKCi4gs(6aME7b8azhomuyiRi11qqFDatp7Bhs(ijwt(HhKy4eQxfwYfr8Jq9EQtRUgIXN(t0FHfe8Q2FuJeg5Jg)HeUqfZ9gcmUk7KZUWEee4iKbd5lzCv2jNnKIbHhOI5Edb2XoXgctsoWiF04q5lPKgWniqSlSNkkL)nkTmxK(rCa02NmgDKbJoei5qWnK81bm92d4bYoCyOWqwrQRHG(6aME23oK8rsSM8dVijIHC0oTq9QWsUiIFeQ3tDA11qm(0FI(lSGGA)rnsyKpA8hs4kiWridgYxY4QStoBifdcpEQOu(3O0YCr6hXbqhqdNKOGm1)oei7WbfwYfr8Jvuk)BuAzUi9J4aOd3bcjkijZnjq2HdEjUPHTeRtPMqiiqCtdBjMfz0r2PepbbIBAylXm3uhzNs88a1RyC0jLA(SSbl6LbLee8Q2FuJeg5Jg)JuCc17PoT6AigF6pr)fwqqT)OgjmYhn(djCfeo1PvxdXARurKhOEp1PvxdX4O8eDKKyKfIKdvmoczWq(sghLNOJK8frslCp9BzxybbXo1PvxdX4O8eDKKyKfIKdvmoczWq(sgxLDYzxypE8a1lhHmyiFjJRYo5SHC0oT(bjCfeu7pQrcJ8rJFrkUq5iKbd5lzCv2jNDHH6LJqgmKVKroWiF0iDrjgBihTtR)k)BuYSVoHEigjoIFFs(TdjiighDsPMp7ietRPhbHoFAGrg9jmzObl6Ld5ODA9hpC9a1lg6zkMc)9jjT(0XrIPokyInKJ2P1p8tqqmo6KsnFws8bzqdMNkkL)nkTmxK(rCa0KdmYhnsxuIbYoCWlXnnSLyMBQJmjX9cce30WwIzrgDKjjUxqG4Mg2smnHqMK4Ebb3BiWCvJMCsIcs1yKVOobBLP(3Hyd5ODA9d)y4uqW9gcmx1OjNKOGung5lQtWwPoCnj2qoANw)Wpgofeu7pQrcJ8rJFrkUq5iKbd5lzCv2jNnKIbHhOE5iKbd5lzCv2jNnKJ2P1piHRGahHmyiFjJRYo5SHumi8ii05tdmYOpHjdnyrVCihTtR)4HBfLY)gLwMls)ioaAozi73QrQMgC6q5dYoCWRA)rnsyKpA8lsXfQx3BiWo2j2qysYbg5JghkFjL0aUbbIDHfeeJJoPuZNDeIP10JGahDsPMplBWIEzqjbb3BiWCnieM5AF2fgQ7neyUgecZCTpBihTtR)rJBeE5Oe72pdEiEBjPAAWPdLp7BhsEQMl5XduVN60QRHyCuEIossmYcrYfe4iKbd5lzCuEIosYxejTW90VLnKIbHhbHoFAGrg9jmzObl6Ld5ODA9pACJWlhLy3(zWdXBljvtdoDO8zF7qYt1Cjpvuk)BuAzUi9J4aO7KRtQFJsq2HdEv7pQrcJ8rJFrkUq96Edb2XoXgctsoWiF04q5lPKgWniqSlSGGyC0jLA(SJqmTMEee4Otk18zzdw0ldkji4EdbMRbHWmx7ZUWqDVHaZ1GqyMR9zd5ODA9hs4gHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8a17PoT6AighLNOJKeJSqKCbboczWq(sghLNOJK8frslCp9BzdPyq4rqOZNgyKrFctgAWIE5qoANw)HeUr4LJsSB)m4H4TLKQPbNou(SVDi5PAUKNkkL)nkTmxK(rCa0N60QRHazQo0b1cl(LMyIdYt1CPde30WwI1P0CtDICCm(R8VrjZ(6e6HyK4i(9j53oueIrCtdBjwNsZn1jYJe8x5FJsMVrFrmsCe)(K8BhkcCzrJ)wyYyKIu7tvuk)BuAzUi9J4aOTVo27aMazho4TZNgyKrFctgAWIE5qoANw)XpbbVU3qGn6jLORvggkbbiyd5ODA9hmhJ5OIlY5uB8Q2FuJeg5Jg8hs46bQ7neyJEsj6ALHHsqac2f2JhbbVQ9h1iHr(OjItDA11qm1cl(LMyIh5U3qGrCtdBjPfz0HnKJ2Pncm0Zc3bcjkijZnj238Jw5qoANrE0mC6hErJRGGA)rnsyKpAI4uNwDnetTWIFPjM4rU7neye30WwsAUPoSHC0oTrGHEw4oqirbjzUjX(MF0khYr7mYJMHt)WlAC9aL4Mg2sSoLAcbuVEfJJqgmKVKXvzNC2fwqGJoPuZNDeIP1eQyCeYGH8LmYbg5JgPlkXyxypccC0jLA(SSbl6LbL8a1RyC0jLA(StkFrqmccI5EdbgxLDYzxybb1(JAKWiF04xKIRhbb3BiW4QStoBihTtRF4yOI5Edb2ONuIUwzyOeeGGDHROu(3O0YCr6hXbqNKpPdcLGSdh86EdbgXnnSLKMBQd7cli4LlshWK9q0qhIlshWK8BhYFC6rqGlshWK9aK8avHLCre)yfLY)gLwMls)ioaArQjiDqOeKD4Gx3BiWiUPHTK0CtDyxybbVCr6aMShIg6qCr6aMKF7q(JtpccCr6aMShGKhOkSKlI4hROu(3O0YCr6hXbqhUgJ0bHsq2HdEDVHaJ4Mg2ssZn1HDHfe8YfPdyYEiAOdXfPdys(Td5po9iiWfPdyYEasEGQWsUiIFSIs5FJslZfPFehaTpDMgnsuqsMBsvuk)BuAzUi9J4aOTVoHEiq2Hde30WwI1P0CtDeeiUPHTeZIm6itsCVGaXnnSLyAcHmjX9ccU3qG5tNPrJefKK5Me7cd19gcmIBAyljn3uh2fwqWR7neyCv2jNnKJ2P1FL)nkz(g9fXiXr87tYVDiOU3qGXvzNC2f2tfLY)gLwMls)ioaAFJ(IQOu(3O0YCr6hXbqp3uQ8VrP002hKP6qhcQX8IMBfvfLY)gLwg2qQJBNy0C4uNwDneit1Hoy1ajFK8AjPfMmgqEQMlDWR7neyF7q(qtkXgsDC7eJg2qoANw)aZXyoQ4IaxgEq9sCtdBjwNsx0lsqG4Mg2sSoLwKrhbbIBAylXm3uhzsI79ii4Edb23oKp0KsSHuh3oXOHnKJ2P1pL)nkz2xNqpeJehXVpj)2HIaxgEq9sCtdBjwNsZn1rqG4Mg2smlYOJmjX9cce30WwIPjeYKe37XJGGyU3qG9Td5dnPeBi1XTtmAyx4kkL)nkTmSHuh3oXOjIdG2(6yVdycKD4GxXo1PvxdXSAGKpsETK0ctgJGGx3BiWg9Ks01kddLGaeSHC0oT(dMJXCuXf5CQnEv7pQrcJ8rd(djC9a19gcSrpPeDTYWqjiab7c7XJGGA)rnsyKpA8lsXTIs5FJsldBi1XTtmAI4aO5O8eDKKVisAH7PFli7WbVN60QRHyCuEIossmYcrYH25tdmYOpHjdnyrVCihTtRF4bjCHkghHmyiFjJRYo5SHumieeCVHaJRYo5SlShOQ9h1iHr(OXF8dxOEDVHaJ4Mg2ssZn1HnKJ2P1p8WvqW9gcmIBAyljTiJoSHC0oT(HhUEeecnyrVCihTtR)4HBfLY)gLwg2qQJBNy0eXbqRyk83NK06thhqYHGBi5Rdy6ThWdKD4GyyONPyk83NK06thhjM6OGj238JDcgQyk)BuYumf(7tsA9PJJetDuWeRtzW0Gf9q9kgg6zkMc)9jjT(0XrkIud7B(XobliGHEMIPWFFssRpDCKIi1WgYr706ho9iiGHEMIPWFFssRpDCKyQJcMy2x5h9hsqXqptXu4VpjP1Noosm1rbtSHC0oT(djOyONPyk83NK06thhjM6OGj238JDcUIs5FJsldBi1XTtmAI4aODqOm0dbsoeCdjFDatV9aEGSdhgkmKvK6AiOVoGPN9TdjFKeRj)WlAOE96EdbgxLDYzd5ODA9dNq96Edb2ONuIUwzyOeeGGnKJ2P1pCkiiM7neyJEsj6ALHHsqac2f2JGGyU3qGXvzNC2fwqqT)OgjmYhn(djC9a1RyU3qGDStSHWKKdmYhnou(skPbCdce7cliO2FuJeg5Jg)HeUEGQWsUiIF0tfLY)gLwg2qQJBNy0eXbqBVzOhcKCi4gs(6aME7b8azhomuyiRi11qqFDatp7Bhs(ijwt(Hx0q9619gcmUk7KZgYr706hoH619gcSrpPeDTYWqjiabBihTtRF4uqqm3BiWg9Ks01kddLGaeSlShbbXCVHaJRYo5SlSGGA)rnsyKpA8hs46bQxXCVHa7yNydHjjhyKpACO8Lusd4gei2fwqqT)OgjmYhn(djC9avHLCre)ONkkL)nkTmSHuh3oXOjIdG2(KXOJmy0HajhcUHKVoGP3Eapq2HddfgYksDne0xhW0Z(2HKpsI1KF4fjq9619gcmUk7KZgYr706hoH619gcSrpPeDTYWqjiabBihTtRF4uqqm3BiWg9Ks01kddLGaeSlShbbXCVHaJRYo5SlSGGA)rnsyKpA8hs46bQxXCVHa7yNydHjjhyKpACO8Lusd4gei2fwqqT)OgjmYhn(djC9avHLCre)ONkkL)nkTmSHuh3oXOjIdGoGgojrbzQ)Diq2HdkSKlI4hROu(3O0YWgsDC7eJMioa6rpPeDTYWqjiabi7Wb3BiW4QSto7cxrP8VrPLHnK642jgnrCa0KdmYhnsxuIbYoCWRx3BiWiUPHTK0Im6WgYr706hE4ki4EdbgXnnSLKMBQdBihTtRF4HRhOCeYGH8LmUk7KZgYr706hKW1JGahHmyiFjJRYo5SHumiQOu(3O0YWgsDC7eJMioaAozi73QrQMgC6q5dYoCWRx3BiWo2j2qysYbg5JghkFjL0aUbbIDHfeeJJoPuZNDeIP10JGahDsPMplBWIEzqjbHtDA11qS2kveji4EdbMRbHWmx7ZUWqDVHaZ1GqyMR9zd5ODA9pACJWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEGkM7neyCv2jNDHH6vmo6KsnFw2Gf9YGsccCeYGH8Lmokprhj5lIKw4E63YUWccD(0aJm6tyYqdw0lhYr706phHmyiFjJJYt0rs(IiPfUN(TSHC0oTrejccD(0aJm6tyYqdw0lhYr70I)4pE4yC9pACJWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEQOu(3O0YWgsDC7eJMioa6o56K63OeKD4GxVU3qGDStSHWKKdmYhnou(skPbCdce7cliighDsPMp7ietRPhbbo6KsnFw2Gf9YGsccN60QRHyTvQisqW9gcmxdcHzU2NDHH6EdbMRbHWmx7ZgYr706pKWncVCuID7NbpeVTKunn40HYN9TdjpvZL84bQyU3qGXvzNC2fgQxX4Otk18zzdw0ldkjiWridgYxY4O8eDKKVisAH7PFl7cli05tdmYOpHjdnyrVCihTtR)CeYGH8Lmokprhj5lIKw4E63YgYr70grKii05tdmYOpHjdnyrVCihTtl(J)4HJX1FiHBeE5Oe72pdEiEBjPAAWPdLp7BhsEQMl5XtfLY)gLwg2qQJBNy0eXbqFQtRUgcKP6qhS6jjdOrYvzNCqEQMlDWRyCeYGH8LmUk7KZgsXGqqqStDA11qmokprhjjgzHi5q5Otk18zzdw0ldk5PIs5FJsldBi1XTtmAI4aOd3bcjkijZnjq2Hde30WwI1PutiGQWsUiIFeQxm0Zumf(7tsA9PJJetDuWe7B(XobliighDsPMplj(GmObZd0tDA11qmREsYaAKCv2jVIs5FJsldBi1XTtmAI4aOTVo27aMazhoWrNuQ5ZYgSOxguc6PoT6AighLNOJKeJSqKCOQ9h1iHr(OXVd4hUq5iKbd5lzCuEIosYxejTW90VLnKJ2P1FWCmMJkUiNtTXRA)rnsyKpAWFiHRNkkL)nkTmSHuh3oXOjIdGojFshekbzho419gcmIBAyljn3uh2fwqWlxKoGj7HOHoexKoGj53oK)40JGaxKoGj7bi5bQcl5Ii(rON60QRHyw9KKb0i5QStEfLY)gLwg2qQJBNy0eXbqlsnbPdcLGSdh86EdbgXnnSLKMBQd7cdvmo6KsnF2riMwtbbVU3qGDStSHWKKdmYhnou(skPbCdce7cdLJoPuZNDeIP10JGGxUiDat2drdDiUiDatYVDi)XPhbbUiDat2dqsqW9gcmUk7KZUWEGQWsUiIFe6PoT6AiMvpjzansUk7KxrP8VrPLHnK642jgnrCa0HRXiDqOeKD4Gx3BiWiUPHTK0CtDyxyOIXrNuQ5ZocX0Aki419gcSJDIneMKCGr(OXHYxsjnGBqGyxyOC0jLA(SJqmTMEee8YfPdyYEiAOdXfPdys(Td5po9iiWfPdyYEasccU3qGXvzNC2f2dufwYfr8Jqp1PvxdXS6jjdOrYvzN8kkL)nkTmSHuh3oXOjIdG2NotJgjkijZnPkkL)nkTmSHuh3oXOjIdG2(6e6HazhoqCtdBjwNsZn1rqG4Mg2smlYOJmjX9cce30WwIPjeYKe3li4EdbMpDMgnsuqsMBsSlmu3BiWiUPHTK0CtDyxybbVU3qGXvzNC2qoANw)v(3OK5B0xeJehXVpj)2HG6EdbgxLDYzxypvuk)BuAzydPoUDIrtehaTVrFrvuk)BuAzydPoUDIrteha9CtPY)gLstBFqMQdDiOgZlAUvuvuk)BuAzb1yErZ9G91XEhWei7WbXMBsb0aMyUQrtojrbPAmYxuNGTmceDByycRIs5FJsllOgZlAUrCa02Bg6HajhcUHKVoGP3Eapq2HdyON5GqzOhInKJ2P1VHC0oTvuk)BuAzb1yErZnIdG2bHYqpufvfLY)gLwM9pOyk83NK06thhqYHGBi5Rdy6ThWdKD4GyyONPyk83NK06thhjM6OGj238JDcgQyk)BuYumf(7tsA9PJJetDuWeRtzW0Gf9q9kgg6zkMc)9jjT(0XrkIud7B(XobliGHEMIPWFFssRpDCKIi1WgYr706ho9iiGHEMIPWFFssRpDCKyQJcMy2x5h9hsqXqptXu4VpjP1Noosm1rbtSHC0oT(djOyONPyk83NK06thhjM6OGj238JDcUIs5FJslZ(rCa0CuEIosYxejTW90VfKD4G3tDA11qmokprhjjgzHi5qfJJqgmKVKXvzNC2qkgeccU3qGXvzNC2f2du1(JAKWiF04p(HluVU3qGrCtdBjP5M6WgYr706hE4ki4EdbgXnnSLKwKrh2qoANw)WdxpccHgSOxoKJ2P1F8WTIs5FJslZ(rCa0N60QRHazQo0bm0lhceD7HCO8TG8unx6Gx3BiW4QStoBihTtRF4eQx3BiWg9Ks01kddLGaeSHC0oT(HtbbXCVHaB0tkrxRmmuccqWUWEeeeZ9gcmUk7KZUWccQ9h1iHr(OXFiHRhOEfZ9gcSJDIneMKCGr(OXHYxsjnGBqGyxybb1(JAKWiF04pKW1duVU3qGrCtdBjPfz0HnKJ2P1pWCmMJkobb3BiWiUPHTK0CtDyd5ODA9dmhJ5OIZtfLY)gLwM9J4aODqOm0dbsoeCdjFDatV9aEGSdhgkmKvK6AiOVoGPN9TdjFKeRj)WlAOEvyjxeXpc9uNwDnedd9YHar3EihkFRNkkL)nkTm7hXbqBVzOhcKCi4gs(6aME7b8azhomuyiRi11qqFDatp7Bhs(ijwt(Hx0q9QWsUiIFe6PoT6Aigg6LdbIU9qou(wpvuk)BuAz2pIdG2(KXOJmy0HajhcUHKVoGP3Eapq2HddfgYksDne0xhW0Z(2HKpsI1KF4fjq9QWsUiIFe6PoT6Aigg6LdbIU9qou(wpvuk)BuAz2pIdGoGgojrbzQ)Diq2HdkSKlI4hROu(3O0YSFeha9ONuIUwzyOeeGaKD4G7neyCv2jNDHROu(3O0YSFehan5aJ8rJ0fLyGSdh8619gcmIBAyljTiJoSHC0oT(HhUccU3qGrCtdBjP5M6WgYr706hE46bkhHmyiFjJRYo5SHC0oT(bjCH619gcm4PDqdwRgPoCnBUe(AS6WovZL8pA8dxbbXMBsb0aMyWt7GgSwnsD4A2Cj81y1HrGOBddtyE8ii4Edbg80oObRvJuhUMnxcFnwDyNQ5s(DiACeUccCeYGH8LmUk7KZgsXGaQx1(JAKWiF04xKIRGWPoT6AiwBLkI8urP8VrPLz)ioaAozi73QrQMgC6q5dYoCWRA)rnsyKpA8lsXfQx3BiWo2j2qysYbg5JghkFjL0aUbbIDHfeeJJoPuZNDeIP10JGahDsPMplBWIEzqjbHtDA11qS2kveji4EdbMRbHWmx7ZUWqDVHaZ1GqyMR9zd5ODA9pACJWR3inYNBsb0aMyWt7GgSwnsD4A2Cj81y1HrGOBddtyEIWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpE8avm3BiW4QSto7cd1RyC0jLA(SSbl6LbLee4iKbd5lzCuEIosYxejTW90VLDHfe68Pbgz0NWKHgSOxoKJ2P1FoczWq(sghLNOJK8frslCp9Bzd5ODAJisee68Pbgz0NWKHgSOxoKJ2Pf)XF8WX46F04gHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8urP8VrPLz)ioa6o56K63OeKD4Gx1(JAKWiF04xKIluVU3qGDStSHWKKdmYhnou(skPbCdce7cliighDsPMp7ietRPhbbo6KsnFw2Gf9YGsccN60QRHyTvQisqW9gcmxdcHzU2NDHH6EdbMRbHWmx7ZgYr706pKWncVEJ0iFUjfqdyIbpTdAWA1i1HRzZLWxJvhgbIUnmmH5jcVCuID7NbpeVTKunn40HYN9TdjpvZL84XduXCVHaJRYo5SlmuVIXrNuQ5ZYgSOxgusqGJqgmKVKXr5j6ijFrK0c3t)w2fwqOZNgyKrFctgAWIE5qoANw)5iKbd5lzCuEIosYxejTW90VLnKJ2PnIirqOZNgyKrFctgAWIE5qoANw8h)XdhJR)qc3i8Yrj2TFg8q82ss10GthkF23oK8unxYJNkkL)nkTm7hXbqFQtRUgcKP6qhS6jjdOrYvzNCqEQMlDWRyCeYGH8LmUk7KZgsXGqqqStDA11qmokprhjjgzHi5q5Otk18zzdw0ldk5PIs5FJslZ(rCa0H7aHefKK5Mei7WbIBAylX6uQjeqvyjxeXpc19gcm4PDqdwRgPoCnBUe(AS6WovZL8pA8dxOEXqptXu4VpjP1Noosm1rbtSV5h7eSGGyC0jLA(SK4dYGgmpqp1PvxdXS6jjdOrYvzN8kkL)nkTm7hXbqBFDcQXaYoCW9gcmusViReMgob)nkzxyOU3qGzFDcQXWgkmKvK6AOkkL)nkTm7hXbqZ1KtgP7neazQo0b7RJbnyGSdhCVHaZ(6yqdgBihTtR)4eQx3BiWiUPHTK0Im6WgYr706hofeCVHaJ4Mg2ssZn1HnKJ2P1pC6bQA)rnsyKpA8lsXTIs5FJslZ(rCa02xh7DatGSdh4Otk18zzdw0ldkb9uNwDneJJYt0rsIrwisouoczWq(sghLNOJK8frslCp9Bzd5ODA9hNvuk)BuAz2pIdG2(6euJbKD4WRgkFM9jJrhj20HNrP6AimOI9QHYNzFDmObJrP6AimOU3qGzFDcQXWgkmKvK6AiOEDVHaJ4Mg2ssZn1HnKJ2P1VibkXnnSLyDkn3uhOU3qGbpTdAWA1i1HRzZLWxJvh2PAUK)rJtCfeCVHadEAh0G1QrQdxZMlHVgRoSt1Cj)oenoXfQA)rnsyKpA8lsXvqad9mftH)(KKwF64iXuhfmXgYr706howqq5FJsMIPWFFssRpDCKyQJcMyDkdMgSO3duX4iKbd5lzCv2jNnKIbrfLY)gLwM9J4aOTVo27aMazho4EdbgkPxKvYnKoYZ22OKDHfeCVHa7yNydHjjhyKpACO8Lusd4gei2fwqW9gcmUk7KZUWq96Edb2ONuIUwzyOeeGGnKJ2P1FWCmMJkUiNtTXRA)rnsyKpAWFiHRhOU3qGn6jLORvggkbbiyxybbXCVHaB0tkrxRmmuccqWUWqfJJqgmKVKn6jLORvggkbbiydPyqiiighDsPMp7KYxeeJhbb1(JAKWiF04xKIluIBAylX6uQjevuk)BuAz2pIdG2(6yVdycKD4WRgkFM91XGgmgLQRHWG619gcm7RJbnySlSGGA)rnsyKpA8lsX1du3BiWSVog0GXSVYp6pKG619gcmIBAyljTiJoSlSGG7neye30WwsAUPoSlShOU3qGbpTdAWA1i1HRzZLWxJvh2PAUK)rJJWfQxoczWq(sgxLDYzd5ODA9dpCfee7uNwDneJJYt0rsIrwisouo6KsnFw2Gf9YGsEQOu(3O0YSFehaT91XEhWei7WbVU3qGbpTdAWA1i1HRzZLWxJvh2PAUK)rJJWvqW9gcm4PDqdwRgPoCnBUe(AS6WovZL8pACIl0xnu(m7tgJosSPdpJs11qyEG6EdbgXnnSLKwKrh2qoANw)WrqjUPHTeRtPfz0bQyU3qGHs6fzLW0Wj4Vrj7cdvSxnu(m7RJbnymkvxdHbLJqgmKVKXvzNC2qoANw)Wrq9YridgYxYihyKpAKUOeJnKJ2P1pCKGGyC0jLA(SJqmTMEQOu(3O0YSFehaDs(KoiucYoCWR7neye30WwsAUPoSlSGGxUiDat2drdDiUiDatYVDi)XPhbbUiDat2dqYdufwYfr8Jqp1PvxdXS6jjdOrYvzN8kkL)nkTm7hXbqlsnbPdcLGSdh86EdbgXnnSLKMBQd7cdvmo6KsnF2riMwtbbVU3qGDStSHWKKdmYhnou(skPbCdce7cdLJoPuZNDeIP10JGGxUiDat2drdDiUiDatYVDi)XPhbbUiDat2dqsqW9gcmUk7KZUWEGQWsUiIFe6PoT6AiMvpjzansUk7KxrP8VrPLz)ioa6W1yKoiucYoCWR7neye30WwsAUPoSlmuX4Otk18zhHyAnfe86Edb2XoXgctsoWiF04q5lPKgWniqSlmuo6KsnF2riMwtpccE5I0bmzpen0H4I0bmj)2H8hNEee4I0bmzpajbb3BiW4QSto7c7bQcl5Ii(rON60QRHyw9KKb0i5QStEfLY)gLwM9J4aO9PZ0OrIcsYCtQIs5FJslZ(rCa02xNqpei7WbIBAylX6uAUPocce30WwIzrgDKjjUxqG4Mg2smnHqMK4Ebb3BiW8PZ0OrIcsYCtIDHH6EdbgXnnSLKMBQd7cli419gcmUk7KZgYr706VY)gLmFJ(IyK4i(9j53oeu3BiW4QSto7c7PIs5FJslZ(rCa0(g9fvrP8VrPLz)ioa65MsL)nkLM2(Gmvh6qqnMx0CbEGhaa]] )


end