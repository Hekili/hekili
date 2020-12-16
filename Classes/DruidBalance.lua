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


    spec:RegisterPack( "Balance", 20201216, [[dOKzzdqicLhbvqUeHuTjq6tqfQrrv6uufRsiQELqywaOBbvGDHYVaHggH4yqLwMqQNbIAAeQY1ar2MqeFJqkghuHCoHOSocvL5rvv3tfSpQQCqcPulKqYdfI0ejuvHlsOQI(iHQkDsOckRuizMaqDtcvvLDcc(jHQQQHsOQklfQGQNkutfQOVsiLySesjTxG(lrdwPdtAXuPhJQjdLlJSzbFgqJgQ60s9AvOztXTPIDl63qgoOooaKLR45uA6Q66Q02vrFNQY4ju58a06baZNG9lzqCbXjymM(eieIwKOfb3OXnsyIGJGeU4cg)actGXWk)OcKaJt1HaJfLA0KtGXWkGgKIbItWyl6oCcmg))WwXheHiW(XFDzCKdeTTZ1OFJs(OHhI22HdrWy3BBECyjOlymM(eieIwKOfb3OXnsyIGJGKiqkAWy9(4rdyCC7ePGX4BmmkbDbJXilhmghQwrPgn5uTIFm3gRIchQwXpio54stT4gjaS2OfjArQOQOWHQnsXRjqYk(QOWHQfhuROnggHvBmYOtTIIuhwffouT4GAJu8AcKWQ91bi9YoulxTKT2hvlhqUHKVoaP3YQOWHQfhuloCYbDsy1EZK4K1QdG1EQtRUgYwR3Mrmawl8qNs7RJ9oaPAXb(vl8qNm7RJ9oajpSkkCOAXb1kAFIASAHhIR2VtG1kAz0hFTDO2(XX2AF8uT(gucSwXp5Mg2sSkkCOAXb1k(NEKQnsr5j6iv7JNQngUN(T1Q1A6)nuToOHQnyiX1UgQwVDOwar3AXRyjo(RfF)12FT225AEnj01AaSwF9JVwrj(VOnoRnIAJuYq2VvtTI2Mgy6q5dWA7hhJvR9yd7HbgBA7BbXjym2qQJBNy0aItqiGliobJPuDnegOOaJrWGXw6bJv(3Oem(uNwDney8PAUeyS3ADVHa7BhYhAsj2qQJBNy0WgYr70wRF1cKJXCuXvBe1kcd3AHwR3AjUPHTeRtPl6XxRGqTe30WwI1P0Im6uRGqTe30WwIzUPoYKe3xRNAfeQ19gcSVDiFOjLydPoUDIrdBihTtBT(vRY)gLm7RtOhIrIJ43NKF7q1grTIWWTwO16TwIBAylX6uAUPo1kiulXnnSLywKrhzsI7RvqOwIBAylX0eqzsI7R1tTEQvqOwXQ19gcSVDiFOjLydPoUDIrd7cdgFQJmvhcm2Qbs(i51sslmzmGpieIgeNGXuQUgcduuGX8PFAAfm2BTIv7PoT6AiMvdK8rYRLKwyYyQvqOwV16Edb2ONuIUwzyOeaaKnKJ2PTw)RfihJ5OIR2iVwo1MA9wRA)rnsyKpAQfI1czrQ1tTqR19gcSrpPeDTYWqjaai7cxRNA9uRGqTQ9h1iHr(OPw)QnYebmw5FJsWy7RJ9oajWhecqgeNGXuQUgcduuGX8PFAAfm2BTN60QRHyCuEIossmYcyYRfATD(0aJm6tyYqde)lhYr70wRF1IlKfPwO1kwTCeYGH8LmUk7KZgsXaSwbHADVHaJRYo5SlCTEQfATQ9h1iHr(OPw)Rv8ePwO16Tw3BiWiUPHTK0CtDyd5ODAR1VAXvKAfeQ19gcmIBAyljTiJoSHC0oT16xT4ksTEQvqO2qde)lhYr70wR)1IRiGXk)BucgZr5j6ijF8K0c3t)wWhecIhiobJPuDnegOOaJv(3OemwXu4VpjP1NooGX8PFAAfmwSAXqptXu4VpjP1Noosm1rbsSV5h7eyTqRvSAv(3OKPyk83NK06thhjM6OajwNYGPbI)RfATERvSAXqptXu4VpjP1Noos8KAyFZp2jWAfeQfd9mftH)(KKwF64iXtQHnKJ2PTw)Qfs16PwbHAXqptXu4VpjP1Noosm1rbsm7R8J16FTqUwO1IHEMIPWFFssRpDCKyQJcKyd5ODAR1)AHCTqRfd9mftH)(KKwF64iXuhfiX(MFStGGXCa5gs(6aKElieWf8bHaKaXjymLQRHWaffySY)gLGXoiug6HaJ5t)00ky8qHHS4vxdvl0AFDasp7Bhs(ijwt16xT4gDTqR1BTER19gcmUk7KZgYr70wRF1cPAHwR3ADVHaB0tkrxRmmucaaYgYr70wRF1cPAfeQvSADVHaB0tkrxRmmucaaYUW16PwbHAfRw3BiW4QSto7cxRGqTQ9h1iHr(OPw)RfYIuRNAHwR3AfRw3BiWo2j2qysYbg5JghkFjL0aSbaIDHRvqOw1(JAKWiF0uR)1czrQ1tTqRvHLC8e)yTEaJ5aYnK81bi9wqiGl4dcHibeNGXuQUgcduuGXk)BucgBVzOhcmMp9ttRGXdfgYIxDnuTqR91bi9SVDi5JKynvRF1IB01cTwV16Tw3BiW4QStoBihTtBT(vlKQfATER19gcSrpPeDTYWqjaaiBihTtBT(vlKQvqOwXQ19gcSrpPeDTYWqjaai7cxRNAfeQvSADVHaJRYo5SlCTcc1Q2FuJeg5JMA9VwilsTEQfATERvSADVHa7yNydHjjhyKpACO8LusdWgai2fUwbHAv7pQrcJ8rtT(xlKfPwp1cTwfwYXt8J16bmMdi3qYxhG0BbHaUGpieenG4emMs11qyGIcmw5FJsWy7tgJoYGrhcmMp9ttRGXdfgYIxDnuTqR91bi9SVDi5JKynvRF1IBKul0A9wR3ADVHaJRYo5SHC0oT16xTqQwO16Tw3BiWg9Ks01kddLaaGSHC0oT16xTqQwbHAfRw3BiWg9Ks01kddLaaGSlCTEQvqOwXQ19gcmUk7KZUW1kiuRA)rnsyKpAQ1)AHSi16PwO16TwXQ19gcSJDIneMKCGr(OXHYxsjnaBaGyx4AfeQvT)OgjmYhn16FTqwKA9ul0AvyjhpXpwRhWyoGCdjFDasVfec4c(GqahbItWykvxdHbkkWy(0pnTcgRWsoEIFemw5FJsW4aA4KefKP(3HaFqiezG4emMs11qyGIcmMp9ttRGXU3qGXvzNC2fgmw5FJsW4rpPeDTYWqjaai4dcbCfbeNGXuQUgcduuGX8PFAAfm2BTER19gcmIBAyljTiJoSHC0oT16xT4ksTcc16EdbgXnnSLKMBQdBihTtBT(vlUIuRNAHwlhHmyiFjJRYo5SHC0oT16xTqwKA9uRGqTCeYGH8LmUk7KZgsXaemw5FJsWyYbg5JgPlkXaFqiGlUG4emMs11qyGIcmMp9ttRGXER1BTU3qGDStSHWKKdmYhnou(skPbydae7cxRGqTIvlhDsPMp7iGtRzTEQvqOwo6KsnFw2aX)YGs1kiu7PoT6AiwBLkIQvqOw3BiWCnieM5AF2fUwO16EdbMRbHWmx7ZgYr70wR)1gTi1grTERLJsSB)m4H4TLKQPbMou(SVDi5PAUuTEQ1tTqRvSADVHaJRYo5SlCTqR1BTIvlhDsPMplBG4FzqPAfeQLJqgmKVKXr5j6ijF8K0c3t)w2fUwbHA78Pbgz0NWKHgi(xoKJ2PTw)RLJqgmKVKXr5j6ijF8K0c3t)w2qoAN2AJO2iPwbHA78Pbgz0NWKHgi(xoKJ2PTwrVwCXrIuR)1gTi1grTERLJsSB)m4H4TLKQPbMou(SVDi5PAUuTEQ1dySY)gLGXCYq2VvJunnW0HYh8bHaUrdItWykvxdHbkkWy(0pnTcg7TwV16Edb2XoXgctsoWiF04q5lPKgGnaqSlCTcc1kwTC0jLA(SJaoTM16PwbHA5Otk18zzde)ldkvRGqTN60QRHyTvQiQwbHADVHaZ1GqyMR9zx4AHwR7neyUgecZCTpBihTtBT(xlKfP2iQ1BTCuID7NbpeVTKunnW0HYN9TdjpvZLQ1tTEQfATIvR7neyCv2jNDHRfATERvSA5Otk18zzde)ldkvRGqTCeYGH8Lmokprhj5JNKw4E63YUW1kiuBNpnWiJ(eMm0aX)YHC0oT16FTCeYGH8Lmokprhj5JNKw4E63YgYr70wBe1gj1kiuBNpnWiJ(eMm0aX)YHC0oT1k61IlosKA9VwilsTruR3A5Oe72pdEiEBjPAAGPdLp7BhsEQMlvRNA9agR8VrjyCNCDs9Buc(GqaxidItWykvxdHbkkWyemySLEWyL)nkbJp1PvxdbgFQMlbg7TwXQLJqgmKVKXvzNC2qkgG1kiuRy1EQtRUgIXr5j6ijXilGjVwO1YrNuQ5ZYgi(xguQwpGXN6it1HaJT6jjdOrYvzNCWhec4kEG4emMs11qyGIcmMp9ttRGXe30WwI1PutaRfATkSKJN4hRfATERfd9mftH)(KKwF64iXuhfiX(MFStG1kiuRy1YrNuQ5ZsIpidAWQ1tTqR9uNwDneZQNKmGgjxLDYbJv(3OemoChaLOGKm3KaFqiGlKaXjymLQRHWaffymF6NMwbJ5Otk18zzde)ldkvl0Ap1PvxdX4O8eDKKyKfWKxl0Av7pQrcJ8rtT(DOwXtKAHwlhHmyiFjJJYt0rs(4jPfUN(TSHC0oT16FTa5ymhvC1g51YP2uR3Av7pQrcJ8rtTqSwilsTEaJv(3Oem2(6yVdqc8bHaUrciobJPuDnegOOaJ5t)00kyS3ADVHaJ4Mg2ssZn1HDHRvqOwV1YXRdqYw7HAJUwO1oehVoaj53ouT(xlKQ1tTcc1YXRdqYw7HAHCTEQfATkSKJN4hRfATN60QRHyw9KKb0i5QStoySY)gLGXj5t6Gqj4dcbCfnG4emMs11qyGIcmMp9ttRGXER19gcmIBAyljn3uh2fUwO1kwTC0jLA(SJaoTM1kiuR3ADVHa7yNydHjjhyKpACO8LusdWgai2fUwO1YrNuQ5Zoc40AwRNAfeQ1BTC86aKS1EO2ORfATdXXRdqs(TdvR)1cPA9uRGqTC86aKS1EOwixRGqTU3qGXvzNC2fUwp1cTwfwYXt8J1cT2tDA11qmREsYaAKCv2jhmw5FJsWy8QjiDqOe8bHaU4iqCcgtP6AimqrbgZN(PPvWyV16EdbgXnnSLKMBQd7cxl0AfRwo6KsnF2raNwZAfeQ1BTU3qGDStSHWKKdmYhnou(skPbydae7cxl0A5Otk18zhbCAnR1tTcc16TwoEDas2ApuB01cT2H441bij)2HQ1)AHuTEQvqOwoEDas2ApulKRvqOw3BiW4QSto7cxRNAHwRcl54j(XAHw7PoT6AiMvpjzansUk7KdgR8VrjyC4AmshekbFqiGBKbItWyL)nkbJ9PZ0OrIcsYCtcmMs11qyGIc8bHq0IaItWykvxdHbkkWy(0pnTcgtCtdBjwNsZn1PwbHAjUPHTeZIm6itsCFTcc1sCtdBjMMaktsCFTcc16EdbMpDMgnsuqsMBsSlCTqR19gcmIBAyljn3uh2fUwbHA9wR7neyCv2jNnKJ2PTw)Rv5FJsMVrF8msCe)(K8BhQwO16EdbgxLDYzx4A9agR8VrjyS91j0db(GqiACbXjySY)gLGX(g9XdgtP6Aimqrb(Gqi6ObXjymLQRHWaffySY)gLGXZnLk)BuknT9bJnT9LP6qGXb1yE8Zf8bFWymkOxZdItqiGliobJv(3Oem2Im6iDj1bmMs11qyGIc8bHq0G4emMs11qyGIcmgbdgBPhmw5FJsW4tDA11qGXNQ5sGXwyYyKVoaP3YSVob1yQ1VAXTwO16TwXQ9vdLpZ(6yqdgJs11qy1kiu7RgkFM9jJrhj20HNrP6AiSA9uRGqTwyYyKVoaP3YSVob1yQ1VAJgm(uhzQoeyCBLkIaFqiazqCcgtP6AimqrbgJGbJT0dgR8Vrjy8PoT6AiW4t1CjWylmzmYxhG0Bz2xNqpuT(vlUGXN6it1HaJBRKBi9KaFqiiEG4emMs11qyGIcmMp9ttRGXERvSA5Otk18zzde)ldkvRGqTIvlhHmyiFjJJYt0rs(4jPfUN(TSlCTEQfATU3qGXvzNC2fgmw5FJsWyxAS0CStGGpieGeiobJPuDnegOOaJ5t)00kyS7neyCv2jNDHbJv(3Oemgg9nkbFqiejG4emMs11qyGIcmgbdgBPhmw5FJsW4tDA11qGXNQ5sGXbdcn16TwV125tdmYOpHjdnq8VCihTtBT4GAJwKAXb1YridgYxY4O8eDKKpEsAH7PFlBihTtBTEQfI1IB0IuRNA9R2GbHMA9wR3A78Pbgz0NWKHgi(xoKJ2PTwCqTrdPAXb16TwCfP2iV2xnu(So56K63OKrP6AiSA9uloOwV1Yrj2TFg8q82ss10athkF23oK8unxQwp1IdQLJqgmKVKXvzNC2qoAN2A9uleRfxCKi16PwbHA5iKbd5lzCv2jNnKJ2PTw)QTZNgyKrFctgAG4F5qoAN2AfeQLJqgmKVKXr5j6ijF8K0c3t)w2qoAN2A9R2oFAGrg9jmzObI)Ld5ODARvqOwXQLJoPuZNLnq8VmOey8PoYuDiWyokprhjjgzbm5GpieenG4emMs11qyGIcmw5FJsW4oT85(QRHKaORM)1rIrNnNaJ5t)00kyS7neyCv2jNDHbJt1HaJ70YN7RUgscGUA(xhjgD2Cc8bHaoceNGXuQUgcduuGX8PFAAfm29gcmUk7KZUW1kiulhHmyiFjJRYo5SHC0oT16xT4ksTqRvSA5Otk18zhbCAnRvqOwo6KsnFw2aX)YGs1cT2tDA11qmokprhjjgzbm51cTwoczWq(sghLNOJK8XtslCp9Bzx4AHwRy1YridgYxY4QSto7cxl0A9wR3ADVHaJ4Mg2ssZn1HnKJ2PTw)QfxrQvqOw3BiWiUPHTK0Im6WgYr70wRF1IRi16PwO1kwTZnPaAasmx1OjNKOGung5JVtGwgLQRHWQvqO25MuanajMRA0KtsuqQgJ8X3jqlJs11qy1cTwV16EdbMRA0KtsuqQgJ8X3jqRm1)oeZ(k)yT(vlKRvqOw3BiWCvJMCsIcs1yKp(obAL6W1Ky2x5hR1VAHCTEQ1tTcc16Edb2XoXgctsoWiF04q5lPKgGnaqSlCTcc1gAG4F5qoAN2A9V2Ofbmw5FJsW4RLK9towWhecrgiobJPuDnegOOaJ5t)00ky8PoT6AiwBLkIaJT)08hec4cgR8Vrjy8CtPY)gLstBFWytBFzQoeySIiWhec4kciobJPuDnegOOaJ5t)00ky8CtkGgGe7BhYhAsj2qQJBNy0Wia0THHjmWy7pn)bHaUGXk)Bucgp3uQ8VrP002hm202xMQdbgJnK642jgnGpieWfxqCcgtP6AimqrbgZN(PPvW45MuanajMRA0KtsuqQgJ8X3jqlJaq3ggMWaJT)08hec4cgR8Vrjy8CtPY)gLstBFWytBFzQoeySlsFWhec4gniobJPuDnegOOaJv(3OemEUPu5FJsPPTpySPTVmvhcm2(Gp4dg7I0heNGqaxqCcgtP6AimqrbgZN(PPvWy3BiW4QSto7cdgR8Vrjy8ONuIUwzyOeaae8bHq0G4emMs11qyGIcmgbdgBPhmw5FJsW4tDA11qGXNQ5sGXIvR7neyUQrtojrbPAmYhFNaTYu)7qSlCTqRvSADVHaZvnAYjjkivJr(47eOvQdxtIDHbJp1rMQdbgZN(t0FHbFqiazqCcgtP6AimqrbgR8VrjySIPWFFssRpDCaJ5t)00kyS7neyUQrtojrbPAmYhFNaTYu)7qm7R8J16FTIxTqR19gcmx1OjNKOGung5JVtGwPoCnjM9v(XA9VwXRwO16TwXQfd9mftH)(KKwF64iXuhfiX(MFStG1cTwXQv5FJsMIPWFFssRpDCKyQJcKyDkdMgi(VwO16TwXQfd9mftH)(KKwF64iXtQH9n)yNaRvqOwm0Zumf(7tsA9PJJepPg2qoAN2A9RwixRNAfeQfd9mftH)(KKwF64iXuhfiXSVYpwR)1c5AHwlg6zkMc)9jjT(0XrIPokqInKJ2PTw)Rfs1cTwm0Zumf(7tsA9PJJetDuGe7B(XobwRhWyoGCdjFDasVfec4c(Gqq8aXjymLQRHWaffymF6NMwbJ9w7PoT6AighLNOJKeJSaM8AHwRy1YridgYxY4QStoBifdWAfeQ19gcmUk7KZUW16PwO16Tw3BiWCvJMCsIcs1yKp(obALP(3Hy2x5hR9qTqQwbHADVHaZvnAYjjkivJr(47eOvQdxtIzFLFS2d1cPA9uRGqTHgi(xoKJ2PTw)RfxraJv(3OemMJYt0rs(4jPfUN(TGpieGeiobJPuDnegOOaJ5t)00kyS3ADVHaZvnAYjjkivJr(47eOvM6FhInKJ2PTw)Qv8yqQwbHADVHaZvnAYjjkivJr(47eOvQdxtInKJ2PTw)Qv8yqQwp1cTw1(JAKWiF0uRFhQnYePwO16TwoczWq(sgxLDYzd5ODAR1VAfn1kiuR3A5iKbd5lzKdmYhnsxuIXgYr70wRF1kAQfATIvR7neyh7eBimj5aJ8rJdLVKsAa2aaXUW1cTwo6KsnF2raNwZA9uRhWyL)nkbJ5AYjJ09gcGXU3qqMQdbgBFDmObd8bHqKaItWykvxdHbkkWy(0pnTcglwTN60QRHy8P)e9x4AHwR3A5Otk18zzde)ldkvRGqTCeYGH8LmUk7KZgYr70wRF1kAQvqOwV1YridgYxYihyKpAKUOeJnKJ2PTw)Qv0ul0AfRw3BiWo2j2qysYbg5JghkFjL0aSbaIDHRfATC0jLA(SJaoTM16PwpGXk)BucgBFDS3bib(Gqq0aItWykvxdHbkkWy(0pnTcg7TwoczWq(sghLNOJK8XtslCp9Bzd5ODAR1)AHuTqR1BTN60QRHyCuEIossmYcyYRvqOwoczWq(sgxLDYzd5ODAR1)AHuTEQ1tTqRvT)OgjmYhn16xTINi1cTwo6KsnFw2aX)YGsGXk)BucgBFDS3bib(GqahbItWykvxdHbkkWyL)nkbJT3m0dbgZN(PPvW4HcdzXRUgQwO1(6aKE23oK8rsSMQ1VAXnsQfATERvHLC8e)yTqR1BTN60QRHy8P)e9x4AfeQ1BTQ9h1iHr(OPw)RfYIul0AfRw3BiW4QSto7cxRNAfeQLJqgmKVKXvzNC2qkgG16PwpGXCa5gs(6aKElieWf8bHqKbItWykvxdHbkkWyL)nkbJDqOm0dbgZN(PPvW4HcdzXRUgQwO1(6aKE23oK8rsSMQ1VAXfYmivl0A9wRcl54j(XAHwR3Ap1PvxdX4t)j6VW1kiuR3Av7pQrcJ8rtT(xlKfPwO1kwTU3qGXvzNC2fUwp1kiulhHmyiFjJRYo5SHumaR1tTqRvSADVHa7yNydHjjhyKpACO8LusdWgai2fUwpGXCa5gs(6aKElieWf8bHaUIaItWykvxdHbkkWyL)nkbJTpzm6idgDiWy(0pnTcgpuyilE11q1cT2xhG0Z(2HKpsI1uT(vlUrsTru7qoAN2AHwR3AvyjhpXpwl0A9w7PoT6AigF6pr)fUwbHAv7pQrcJ8rtT(xlKfPwbHA5iKbd5lzCv2jNnKIbyTEQ1dymhqUHKVoaP3ccbCbFqiGlUG4emMs11qyGIcmMp9ttRGXkSKJN4hbJv(3OemoGgojrbzQ)DiWhec4gniobJPuDnegOOaJ5t)00kyS3AjUPHTeRtPMawRGqTe30WwIzrgDKDkXTwbHAjUPHTeZCtDKDkXTwp1cTwV1kwTC0jLA(SSbI)LbLQvqOwV1Q2FuJeg5JMA9V2ids1cTwV1EQtRUgIXN(t0FHRvqOw1(JAKWiF0uR)1czrQvqO2tDA11qS2kvevRNAHwR3Ap1PvxdX4O8eDKKyKfWKxl0AfRwoczWq(sghLNOJK8XtslCp9Bzx4AfeQvSAp1PvxdX4O8eDKKyKfWKxl0AfRwoczWq(sgxLDYzx4A9uRNA9ul0A9wlhHmyiFjJRYo5SHC0oT16xTqwKAfeQvT)OgjmYhn16xTrMi1cTwoczWq(sgxLDYzx4AHwR3A5iKbd5lzKdmYhnsxuIXgYr70wR)1Q8VrjZ(6e6HyK4i(9j53ouTcc1kwTC0jLA(SJaoTM16PwbHA78Pbgz0NWKHgi(xoKJ2PTw)RfxrQ1tTqR1BTyONPyk83NK06thhjM6Oaj2qoAN2A9RwXRwbHAfRwo6KsnFws8bzqdwTEaJv(3OemoChaLOGKm3KaFqiGlKbXjymLQRHWaffymF6NMwbJ9wlXnnSLyMBQJmjX91kiulXnnSLywKrhzsI7RvqOwIBAylX0eqzsI7RvqOw3BiWCvJMCsIcs1yKp(obALP(3Hyd5ODAR1VAfpgKQvqOw3BiWCvJMCsIcs1yKp(obAL6W1Kyd5ODAR1VAfpgKQvqOw1(JAKWiF0uRF1gzIul0A5iKbd5lzCv2jNnKIbyTEQfATERLJqgmKVKXvzNC2qoAN2A9RwilsTcc1YridgYxY4QStoBifdWA9uRGqTD(0aJm6tyYqde)lhYr70wR)1IRiGXk)BucgtoWiF0iDrjg4dcbCfpqCcgtP6AimqrbgZN(PPvWyV1Q2FuJeg5JMA9R2itKAHwR3ADVHa7yNydHjjhyKpACO8LusdWgai2fUwbHAfRwo6KsnF2raNwZA9uRGqTC0jLA(SSbI)LbLQvqOw3BiWCnieM5AF2fUwO16EdbMRbHWmx7ZgYr70wR)1gTi1grTERLJsSB)m4H4TLKQPbMou(SVDi5PAUuTEQ1tTqR1BTN60QRHyCuEIossmYcyYRvqOwoczWq(sghLNOJK8XtslCp9BzdPyawRNAfeQTZNgyKrFctgAG4F5qoAN2A9V2OfP2iQ1BTCuID7NbpeVTKunnW0HYN9TdjpvZLQ1dySY)gLGXCYq2VvJunnW0HYh8bHaUqceNGXuQUgcduuGX8PFAAfm2BTQ9h1iHr(OPw)QnYePwO16Tw3BiWo2j2qysYbg5JghkFjL0aSbaIDHRvqOwXQLJoPuZNDeWP1Swp1kiulhDsPMplBG4FzqPAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTqwKAJOwV1Yrj2TFg8q82ss10athkF23oK8unxQwp16PwO16T2tDA11qmokprhjjgzbm51kiulhHmyiFjJJYt0rs(4jPfUN(TSHumaR1tTcc125tdmYOpHjdnq8VCihTtBT(xlKfP2iQ1BTCuID7NbpeVTKunnW0HYN9TdjpvZLQ1dySY)gLGXDY1j1Vrj4dcbCJeqCcgtP6AimqrbgJGbJT0dgR8Vrjy8PoT6AiW4t1CjWyIBAylX6uAUPo1g51IJQfI1Q8VrjZ(6e6HyK4i(9j53ouTruRy1sCtdBjwNsZn1P2iV2iPwiwRY)gLmFJ(4zK4i(9j53ouTruRiSORfI1AHjJrIxTpbgFQJmvhcmwTWI)OjM4GpieWv0aItWykvxdHbkkWy(0pnTcg7T2oFAGrg9jmzObI)Ld5ODAR1)AfVAfeQ1BTU3qGn6jLORvggkbaazd5ODAR1)AbYXyoQ4QnYRLtTPwV1Q2FuJeg5JMAHyTqwKA9ul0ADVHaB0tkrxRmmucaaYUW16Pwp1kiuR3Av7pQrcJ8rtTru7PoT6AiMAHf)rtmXRnYR19gcmIBAyljTiJoSHC0oT1grTyONfUdGsuqsMBsSV5hTYHC0oRnYRnAgKQ1VAXnArQvqOw1(JAKWiF0uBe1EQtRUgIPwyXF0et8AJ8ADVHaJ4Mg2ssZn1HnKJ2PT2iQfd9SWDauIcsYCtI9n)OvoKJ2zTrETrZGuT(vlUrlsTEQfATe30WwI1PutaRfATER1BTIvlhHmyiFjJRYo5SlCTcc1YrNuQ5Zoc40Awl0AfRwoczWq(sg5aJ8rJ0fLySlCTEQvqOwo6KsnFw2aX)YGs16PwO16TwXQLJoPuZNDs5JhWPwbHAfRw3BiW4QSto7cxRGqTQ9h1iHr(OPw)QnYePwp1kiuR7neyCv2jNnKJ2PTw)Qfhvl0AfRw3BiWg9Ks01kddLaaGSlmySY)gLGX2xh7DasGpieWfhbItWykvxdHbkkWy(0pnTcg7Tw3BiWiUPHTK0CtDyx4AfeQ1BTC86aKS1EO2ORfATdXXRdqs(TdvR)1cPA9uRGqTC86aKS1EOwixRNAHwRcl54j(rWyL)nkbJtYN0bHsWhec4gzG4emMs11qyGIcmMp9ttRGXER19gcmIBAyljn3uh2fUwbHA9wlhVoajBThQn6AHw7qC86aKKF7q16FTqQwp1kiulhVoajBThQfY16PwO1QWsoEIFemw5FJsWy8QjiDqOe8bHq0IaItWykvxdHbkkWy(0pnTcg7Tw3BiWiUPHTK0CtDyx4AfeQ1BTC86aKS1EO2ORfATdXXRdqs(TdvR)1cPA9uRGqTC86aKS1EOwixRNAHwRcl54j(rWyL)nkbJdxJr6Gqj4dcHOXfeNGXk)Bucg7tNPrJefKK5MeymLQRHWaff4dcHOJgeNGXuQUgcduuGX8PFAAfmM4Mg2sSoLMBQtTcc1sCtdBjMfz0rMK4(AfeQL4Mg2smnbuMK4(AfeQ19gcmF6mnAKOGKm3Kyx4AHwR7neye30WwsAUPoSlCTcc16Tw3BiW4QStoBihTtBT(xRY)gLmFJ(4zK4i(9j53ouTqR19gcmUk7KZUW16bmw5FJsWy7RtOhc8bHq0qgeNGXk)Bucg7B0hpymLQRHWaff4dcHOfpqCcgtP6AimqrbgR8Vrjy8CtPY)gLstBFWytBFzQoeyCqnMh)CbFWhmwreiobHaUG4emMs11qyGIcmgbdgBPhmw5FJsW4tDA11qGXNQ5sGXER19gcSVDiFOjLydPoUDIrdBihTtBT(xlqogZrfxTruRimCRvqOw3BiW(2H8HMuInK642jgnSHC0oT16FTk)BuYSVoHEigjoIFFs(TdvBe1kcd3AHwR3AjUPHTeRtP5M6uRGqTe30WwIzrgDKjjUVwbHAjUPHTettaLjjUVwp16PwO16Edb23oKp0KsSHuh3oXOHDHRfATZnPaAasSVDiFOjLydPoUDIrdJaq3ggMWaJp1rMQdbgJnK6i91gJmOgJefcGpieIgeNGXuQUgcduuGX8PFAAfm2BTN60QRHyCuEIossmYcyYRfATIvlhHmyiFjJRYo5SHumaRvqOw3BiW4QSto7cxRNAHwRA)rnsyKpAQ1)AHKi1cTwV16EdbgXnnSLKMBQdBihTtBT(vBKuRGqTU3qGrCtdBjPfz0HnKJ2PTw)QnsQ1tTqR1BTIv7CtkGgGeZvnAYjjkivJr(47eOLrP6AiSAfeQ19gcmx1OjNKOGung5JVtGwzQ)DiM9v(XA9RwixRGqTU3qG5Qgn5KefKQXiF8Dc0k1HRjXSVYpwRF1c5A9uRGqTHgi(xoKJ2PTw)RfxraJv(3OemMJYt0rs(4jPfUN(TGpieGmiobJPuDnegOOaJ5t)00kyS7ney2xNGAmSHcdzXRUgQwO16TwlmzmYxhG0Bz2xNGAm16FTqUwbHAfR25Muanaj23oKp0KsSHuh3oXOHraOBddty16PwO16TwXQDUjfqdqIzaKRJALbdrFNaLanTdSLyea62WWewTcc1(TdvROxR4bPA9Rw3BiWSVob1yyd5ODARnIAJUwpGXk)BucgBFDcQXa(Gqq8aXjymLQRHWaffymF6NMwbJNBsb0aKyF7q(qtkXgsDC7eJggbGUnmmHvl0ATWKXiFDasVLzFDcQXuRFhQfY1cTwV1kwTU3qG9Td5dnPeBi1XTtmAyx4AHwR7ney2xNGAmSHcdzXRUgQwbHA9w7PoT6Aig2qQJ0xBmYGAmsuiul0A9wR7ney2xNGAmSHC0oT16FTqUwbHATWKXiFDasVLzFDcQXuRF1gDTqR9vdLpZ(KXOJeB6WZOuDnewTqR19gcm7Rtqng2qoAN2A9VwivRNA9uRhWyL)nkbJTVob1yaFqiajqCcgtP6AimqrbgJGbJT0dgR8Vrjy8PoT6AiW4t1CjWy1(JAKWiF0uRF1IJePwCqTERfxrQnYR19gcSVDiFOjLydPoUDIrdZ(k)yTEQfhuR3ADVHaZ(6euJHnKJ2PT2iVwixleR1ctgJeVAFQwp1IdQ1BTyONfUdGsuqsMBsSHC0oT1g51cPA9ul0ADVHaZ(6euJHDHbJp1rMQdbgBFDcQXi9HYxguJrIcbWhecrciobJPuDnegOOaJ5t)00ky8PoT6Aig2qQJ0xBmYGAmsuiul0Ap1PvxdXSVob1yK(q5ldQXirHqTcc16Tw3BiWCvJMCsIcs1yKp(obALP(3Hy2x5hR1VAHCTcc16EdbMRA0KtsuqQgJ8X3jqRuhUMeZ(k)yT(vlKR1tTqR1ctgJ81bi9wM91jOgtT(xR4bgR8VrjyS91XEhGe4dcbrdiobJPuDnegOOaJv(3Oem2EZqpeymF6NMwbJhkmKfV6AOAHw7Rdq6zF7qYhjXAQw)QfxXRwCqTwyYyKVoaP3wBe1oKJ2PTwO1QWsoEIFSwO1sCtdBjwNsnbemMdi3qYxhG0BbHaUGpieWrG4emMs11qyGIcmw5FJsWyftH)(KKwF64agZN(PPvWyXQ9B(Xobwl0AfRwL)nkzkMc)9jjT(0XrIPokqI1PmyAG4)AfeQfd9mftH)(KKwF64iXuhfiXSVYpwR)1c5AHwlg6zkMc)9jjT(0XrIPokqInKJ2PTw)RfYGXCa5gs(6aKElieWf8bHqKbItWykvxdHbkkWyL)nkbJDqOm0dbgZN(PPvW4HcdzXRUgQwO1(6aKE23oK8rsSMQ1VA9wlUIxTruR3ATWKXiFDasVLzFDc9q1g51Ilds16Pwp1cXATWKXiFDasVT2iQDihTtBTqR1BTCeYGH8LmUk7KZgsXaSwO16T2tDA11qmokprhjjgzbm51kiulhHmyiFjJJYt0rs(4jPfUN(TSHumaRvqOwXQLJoPuZNLnq8VmOuTEQvqOwlmzmYxhG0Bz2xNqpuT(xR3AfVAJ8A9wlU1grTVAO8zVVoLoiuAzuQUgcRwp16PwbHA9wlXnnSLyDkTiJo1kiuR3AjUPHTeRtPl6XxRGqTe30WwI1P0CtDQ1tTqRvSAF1q5ZSORrIcYhpjdOHSpJs11qy1kiuR7neyWt7GgSwnsD4A2Cj81y1HDQMlvRFhQnAijsTEQfATER1ctgJ81bi9wM91j0dvR)1IRi1g516TwCRnIAF1q5ZEFDkDqO0YOuDnewTEQ1tTqRvT)OgjmYhn16xTqsKAXb16EdbM91jOgdBihTtBTrETrsTEQfATERvSADVHa7yNydHjjhyKpACO8LusdWgai2fUwbHAjUPHTeRtPfz0PwbHAfRwo6KsnF2raNwZA9ul0AvyjhpXpcgZbKBi5Rdq6TGqaxWhec4kciobJPuDnegOOaJ5t)00kyScl54j(rWyL)nkbJdOHtsuqM6Fhc8bHaU4cItWykvxdHbkkWy(0pnTcg7EdbgxLDYzxyWyL)nkbJh9Ks01kddLaaGGpieWnAqCcgtP6AimqrbgZN(PPvWyV16EdbM91jOgd7cxRGqTQ9h1iHr(OPw)QfsIuRNAHwRy16EdbMfzSFZj2fUwO1kwTU3qGXvzNC2fUwO16TwXQLJoPuZNLnq8VmOuTcc1EQtRUgIXr5j6ijXilGjVwbHA5iKbd5lzCuEIosYhpjTW90VLDHRvqO2oFAGrg9jmzObI)Ld5ODAR1)AJwKAJOwV1Yrj2TFg8q82ss10athkF23oK8unxQwp16bmw5FJsWyozi73QrQMgy6q5d(GqaxidItWykvxdHbkkWy(0pnTcg7Tw3BiWSVob1yyx4AfeQvT)OgjmYhn16xTqsKA9ul0AfRw3BiWSiJ9BoXUW1cTwXQ19gcmUk7KZUW1cTwV1kwTC0jLA(SSbI)LbLQvqO2tDA11qmokprhjjgzbm51kiulhHmyiFjJJYt0rs(4jPfUN(TSlCTcc125tdmYOpHjdnq8VCihTtBT(xlhHmyiFjJJYt0rs(4jPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnq8VCihTtBTIET4IJePw)RfYIuBe16TwokXU9ZGhI3wsQMgy6q5Z(2HKNQ5s16PwpGXk)Bucg3jxNu)gLGpieWv8aXjymLQRHWaffymF6NMwbJ78Pbgz0NWKHgi(xoKJ2PTw)RfxivRGqTER19gcm4PDqdwRgPoCnBUe(AS6WovZLQ1)AJgsIuRGqTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(DO2OHKi16PwO16EdbM91jOgd7cxl0A5iKbd5lzCv2jNnKJ2PTw)QfsIagR8Vrjym5aJ8rJ0fLyGpieWfsG4emMs11qyGIcmw5FJsWy7tgJoYGrhcmMp9ttRGXdfgYIxDnuTqR9Bhs(ijwt16xT4cPAHwRfMmg5Rdq6Tm7RtOhQw)Rv8QfATkSKJN4hRfATER19gcmUk7KZgYr70wRF1IRi1kiuRy16EdbgxLDYzx4A9agZbKBi5Rdq6TGqaxWhec4gjG4emMs11qyGIcmMp9ttRGXe30WwI1PutaRfATkSKJN4hRfATU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB0qsKAHwR3AXqptXu4VpjP1Noosm1rbsSV5h7eyTcc1kwTC0jLA(SK4dYGgSAfeQ1ctgJ81bi92A9R2OR1dySY)gLGXH7aOefKK5Me4dcbCfnG4emMs11qyGIcmMp9ttRGXU3qGHs6XBLW0Wj4Vrj7cxl0A9wR7ney2xNGAmSHcdzXRUgQwbHAv7pQrcJ8rtT(vBKjsTEaJv(3Oem2(6euJb8bHaU4iqCcgtP6AimqrbgZN(PPvWyo6KsnFw2aX)YGs1cTwV1EQtRUgIXr5j6ijXilGjVwbHA5iKbd5lzCv2jNDHRvqOw3BiW4QSto7cxRNAHwlhHmyiFjJJYt0rs(4jPfUN(TSHC0oT16FTa5ymhvC1g51YP2uR3Av7pQrcJ8rtTqSwijsTEQfATU3qGzFDcQXWgYr70wR)1kEGXk)BucgBFDcQXa(Gqa3ideNGXuQUgcduuGX8PFAAfmMJoPuZNLnq8VmOuTqR1BTN60QRHyCuEIossmYcyYRvqOwoczWq(sgxLDYzx4AfeQ19gcmUk7KZUW16PwO1YridgYxY4O8eDKKpEsAH7PFlBihTtBT(xBKul0ADVHaZ(6euJHDHRfATe30WwI1PutabJv(3Oem2(6yVdqc8bHq0IaItWykvxdHbkkWy(0pnTcg7EdbgkPhVvYnKoYZ22OKDHRvqOwV1kwT2xNqpetHLC8e)yTcc16Tw3BiW4QStoBihTtBT(xlKQfATU3qGXvzNC2fUwbHA9wR7neyJEsj6ALHHsaaq2qoAN2A9VwGCmMJkUAJ8A5uBQ1BTQ9h1iHr(OPwiwlKfPwp1cTw3BiWg9Ks01kddLaaGSlCTEQ1tTqR9uNwDneZ(6euJr6dLVmOgJefc1cTwlmzmYxhG0Bz2xNGAm16FTqUwp1cTwV1kwTZnPaAasSVDiFOjLydPoUDIrdJaq3ggMWQvqOwlmzmYxhG0Bz2xNGAm16FTqUwpGXk)BucgBFDS3bib(GqiACbXjymLQRHWaffymF6NMwbJ9wlXnnSLyDk1eWAHwlhHmyiFjJRYo5SHC0oT16xTqsKAfeQ1BTC86aKS1EO2ORfATdXXRdqs(TdvR)1cPA9uRGqTC86aKS1EOwixRNAHwRcl54j(rWyL)nkbJtYN0bHsWhecrhniobJPuDnegOOaJ5t)00kyS3AjUPHTeRtPMawl0A5iKbd5lzCv2jNnKJ2PTw)QfsIuRGqTERLJxhGKT2d1gDTqRDioEDasYVDOA9VwivRNAfeQLJxhGKT2d1c5A9ul0AvyjhpXpcgR8VrjymE1eKoiuc(GqiAidItWykvxdHbkkWy(0pnTcg7TwIBAylX6uQjG1cTwoczWq(sgxLDYzd5ODAR1VAHKi1kiuR3A541bizR9qTrxl0AhIJxhGK8BhQw)Rfs16PwbHA541bizR9qTqUwp1cTwfwYXt8JGXk)BucghUgJ0bHsWhecrlEG4emw5FJsWyF6mnAKOGKm3KaJPuDnegOOaFqienKaXjymLQRHWaffymcgm2spySY)gLGXN60QRHaJpvZLaJTWKXiFDasVLzFDc9q16xTIxTruBWGqtTER1rTpnakpvZLQfI1gTi16P2iQnyqOPwV16EdbM91XEhGKKCGr(OXHYxArgDy2x5hRfI1kE16bm(uhzQoeyS91j0dj7uArgDaFqieDKaItWykvxdHbkkWy(0pnTcgtCtdBjM5M6itsCFTcc1sCtdBjMMaktsCFTqR9uNwDneRTsUH0tQwbHADVHaJ4Mg2sslYOdBihTtBT(xRY)gLm7RtOhIrIJ43NKF7q1cTw3BiWiUPHTK0Im6WUW1kiulXnnSLyDkTiJo1cTwXQ9uNwDneZ(6e6HKDkTiJo1kiuR7neyCv2jNnKJ2PTw)Rv5FJsM91j0dXiXr87tYVDOAHwRy1EQtRUgI1wj3q6jvl0ADVHaJRYo5SHC0oT16FTK4i(9j53ouTqR19gcmUk7KZUW1kiuR7neyJEsj6ALHHsaaq2fUwO1AHjJrIxTpvRF1kclsQfATER1ctgJ81bi92A9)qTqUwbHAfR2xnu(ml6AKOG8XtYaAi7ZOuDnewTEQvqOwXQ9uNwDneRTsUH0tQwO16EdbgxLDYzd5ODAR1VAjXr87tYVDiWyL)nkbJ9n6Jh8bHq0IgqCcgR8VrjyS91j0dbgtP6Aimqrb(GqiACeiobJPuDnegOOaJv(3OemEUPu5FJsPPTpySPTVmvhcmoOgZJFUGp4dghuJ5XpxqCccbCbXjymLQRHWaffymF6NMwbJfR25MuanajMRA0KtsuqQgJ8X3jqlJaq3ggMWaJv(3Oem2(6yVdqc8bHq0G4emMs11qyGIcmw5FJsWy7nd9qGX8PFAAfmgd9mhekd9qSHC0oT16xTd5ODAbJ5aYnK81bi9wqiGl4dcbidItWyL)nkbJDqOm0dbgtP6Aimqrb(GpyS9bXjieWfeNGXuQUgcduuGXk)BucgRyk83NK06thhWy(0pnTcglwTyONPyk83NK06thhjM6Oaj238JDcSwO1kwTk)BuYumf(7tsA9PJJetDuGeRtzW0aX)1cTwV1kwTyONPyk83NK06thhjEsnSV5h7eyTcc1IHEMIPWFFssRpDCK4j1WgYr70wRF1cPA9uRGqTyONPyk83NK06thhjM6OajM9v(XA9Vwixl0AXqptXu4VpjP1Noosm1rbsSHC0oT16FTqUwO1IHEMIPWFFssRpDCKyQJcKyFZp2jqWyoGCdjFDasVfec4c(GqiAqCcgtP6AimqrbgZN(PPvWyV1EQtRUgIXr5j6ijXilGjVwO1kwTCeYGH8LmUk7KZgsXaSwbHADVHaJRYo5SlCTEQfATQ9h1iHr(OPw)Rv8ePwO16Tw3BiWiUPHTK0CtDyd5ODAR1VAXvKAfeQ19gcmIBAyljTiJoSHC0oT16xT4ksTEQvqO2qde)lhYr70wR)1IRiGXk)BucgZr5j6ijF8K0c3t)wWhecqgeNGXuQUgcduuGXiyWyl9GXk)BucgFQtRUgcm(unxcm2BTU3qGXvzNC2qoAN2A9Rwivl0A9wR7neyJEsj6ALHHsaaq2qoAN2A9RwivRGqTIvR7neyJEsj6ALHHsaaq2fUwp1kiuRy16EdbgxLDYzx4AfeQvT)OgjmYhn16FTqwKA9ul0A9wRy16Edb2XoXgctsoWiF04q5lPKgGnaqSlCTcc1Q2FuJeg5JMA9VwilsTEQfATER19gcmIBAyljTiJoSHC0oT16xTa5ymhvC1kiuR7neye30WwsAUPoSHC0oT16xTa5ymhvC16bm(uhzQoeymg6LdbGU9qou(wWhecIhiobJPuDnegOOaJv(3Oem2bHYqpeymF6NMwbJhkmKfV6AOAHw7Rdq6zF7qYhjXAQw)Qf3ORfATERvHLC8e)yTqR9uNwDnedd9YHaq3EihkFBTEaJ5aYnK81bi9wqiGl4dcbibItWykvxdHbkkWyL)nkbJT3m0dbgZN(PPvW4HcdzXRUgQwO1(6aKE23oK8rsSMQ1VAXn6AHwR3AvyjhpXpwl0Ap1PvxdXWqVCia0ThYHY3wRhWyoGCdjFDasVfec4c(GqisaXjymLQRHWaffySY)gLGX2NmgDKbJoeymF6NMwbJhkmKfV6AOAHw7Rdq6zF7qYhjXAQw)Qf3iPwO16TwfwYXt8J1cT2tDA11qmm0lhcaD7HCO8T16bmMdi3qYxhG0BbHaUGpieenG4emMs11qyGIcmMp9ttRGXkSKJN4hbJv(3OemoGgojrbzQ)DiWhec4iqCcgtP6AimqrbgZN(PPvWy3BiW4QSto7cdgR8Vrjy8ONuIUwzyOeaae8bHqKbItWykvxdHbkkWy(0pnTcg7TwV16EdbgXnnSLKwKrh2qoAN2A9RwCfPwbHADVHaJ4Mg2ssZn1HnKJ2PTw)QfxrQ1tTqRLJqgmKVKXvzNC2qoAN2A9RwilsTqR1BTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB0INi1kiuRy1o3KcObiXGN2bnyTAK6W1S5s4RXQdJaq3ggMWQ1tTEQvqOw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)ouB0IgrQvqOwoczWq(sgxLDYzdPyawl0A9wRA)rnsyKpAQ1VAJmrQvqO2tDA11qS2kvevRhWyL)nkbJjhyKpAKUOed8bHaUIaItWykvxdHbkkWy(0pnTcg7Tw1(JAKWiF0uRF1gzIul0A9wR7neyh7eBimj5aJ8rJdLVKsAa2aaXUW1kiuRy1YrNuQ5Zoc40AwRNAfeQLJoPuZNLnq8VmOuTcc1EQtRUgI1wPIOAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTrlsTruR3A9wBKvBKx7CtkGgGedEAh0G1QrQdxZMlHVgRomcaDByycRwp1grTERLJsSB)m4H4TLKQPbMou(SVDi5PAUuTEQ1tTEQfATIvR7neyCv2jNDHRfATERvSA5Otk18zzde)ldkvRGqTCeYGH8Lmokprhj5JNKw4E63YUW1kiuBNpnWiJ(eMm0aX)YHC0oT16FTCeYGH8Lmokprhj5JNKw4E63YgYr70wBe1gj1kiuBNpnWiJ(eMm0aX)YHC0oT1k61IlosKA9V2OfP2iQ1BTCuID7NbpeVTKunnW0HYN9TdjpvZLQ1tTEaJv(3OemMtgY(TAKQPbMou(GpieWfxqCcgtP6AimqrbgZN(PPvWyV1Q2FuJeg5JMA9R2itKAHwR3ADVHa7yNydHjjhyKpACO8LusdWgai2fUwbHAfRwo6KsnF2raNwZA9uRGqTC0jLA(SSbI)LbLQvqO2tDA11qS2kvevRGqTU3qG5AqimZ1(SlCTqR19gcmxdcHzU2NnKJ2PTw)RfYIuBe16TwV1gz1g51o3KcObiXGN2bnyTAK6W1S5s4RXQdJaq3ggMWQ1tTruR3A5Oe72pdEiEBjPAAGPdLp7BhsEQMlvRNA9uRNAHwRy16EdbgxLDYzx4AHwR3AfRwo6KsnFw2aX)YGs1kiulhHmyiFjJJYt0rs(4jPfUN(TSlCTcc125tdmYOpHjdnq8VCihTtBT(xlhHmyiFjJJYt0rs(4jPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnq8VCihTtBTIET4IJePw)RfYIuBe16TwokXU9ZGhI3wsQMgy6q5Z(2HKNQ5s16PwpGXk)Bucg3jxNu)gLGpieWnAqCcgtP6AimqrbgJGbJT0dgR8Vrjy8PoT6AiW4t1CjWyV1kwTCeYGH8LmUk7KZgsXaSwbHAfR2tDA11qmokprhjjgzbm51cTwo6KsnFw2aX)YGs16bm(uhzQoeySvpjzansUk7Kd(GqaxidItWykvxdHbkkWy(0pnTcgtCtdBjwNsnbSwO1QWsoEIFSwO16Edbg80oObRvJuhUMnxcFnwDyNQ5s16FTrlEIul0A9wlg6zkMc)9jjT(0XrIPokqI9n)yNaRvqOwXQLJoPuZNLeFqg0GvRNAHw7PoT6AiMvpjzansUk7KdgR8VrjyC4oakrbjzUjb(GqaxXdeNGXuQUgcduuGX8PFAAfm29gcmuspEReMgob)nkzx4AHwR7ney2xNGAmSHcdzXRUgcmw5FJsWy7RtqngWhec4cjqCcgtP6AimqrbgZN(PPvWy3BiWSVog0GXgYr70wR)1cPAHwR3ADVHaJ4Mg2sslYOdBihTtBT(vlKQvqOw3BiWiUPHTK0CtDyd5ODAR1VAHuTEQfATQ9h1iHr(OPw)QnYebmw5FJsWyUMCYiDVHayS7neKP6qGX2xhdAWaFqiGBKaItWykvxdHbkkWy(0pnTcgZrNuQ5ZYgi(xguQwO1EQtRUgIXr5j6ijXilGjVwO1YridgYxY4O8eDKKpEsAH7PFlBihTtBT(xlKaJv(3Oem2(6yVdqc8bHaUIgqCcgtP6AimqrbgZN(PPvW4xnu(m7tgJosSPdpJs11qy1cTwXQ9vdLpZ(6yqdgJs11qy1cTw3BiWSVob1yydfgYIxDnuTqR1BTU3qGrCtdBjP5M6WgYr70wRF1gj1cTwIBAylX6uAUPo1cTw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnAijsTcc16Edbg80oObRvJuhUMnxcFnwDyNQ5s163HAJgsIul0Av7pQrcJ8rtT(vBKjsTcc1IHEMIPWFFssRpDCKyQJcKyd5ODAR1VAXr1kiuRY)gLmftH)(KKwF64iXuhfiX6ugmnq8FTEQfATIvlhHmyiFjJRYo5SHumabJv(3Oem2(6euJb8bHaU4iqCcgtP6AimqrbgZN(PPvWy3BiWqj94TsUH0rE22gLSlCTcc16Edb2XoXgctsoWiF04q5lPKgGnaqSlCTcc16EdbgxLDYzx4AHwR3ADVHaB0tkrxRmmucaaYgYr70wR)1cKJXCuXvBKxlNAtTERvT)OgjmYhn1cXAHSi16PwO16Edb2ONuIUwzyOeaaKDHRvqOwXQ19gcSrpPeDTYWqjaai7cxl0AfRwoczWq(s2ONuIUwzyOeaaKnKIbyTcc1kwTC0jLA(StkF8ao16PwbHAv7pQrcJ8rtT(vBKjsTqRL4Mg2sSoLAciySY)gLGX2xh7DasGpieWnYaXjymLQRHWaffymF6NMwbJF1q5ZSVog0GXOuDnewTqR1BTU3qGzFDmObJDHRvqOw1(JAKWiF0uRF1gzIuRNAHwR7ney2xhdAWy2x5hR1)AHCTqR1BTU3qGrCtdBjPfz0HDHRvqOw3BiWiUPHTK0CtDyx4A9ul0ADVHadEAh0G1QrQdxZMlHVgRoSt1CPA9V2OfnIul0A9wlhHmyiFjJRYo5SHC0oT16xT4ksTcc1kwTN60QRHyCuEIossmYcyYRfATC0jLA(SSbI)LbLQ1dySY)gLGX2xh7DasGpieIweqCcgtP6AimqrbgZN(PPvWyV16Edbg80oObRvJuhUMnxcFnwDyNQ5s16FTrlAePwbHADVHadEAh0G1QrQdxZMlHVgRoSt1CPA9V2OHKi1cT2xnu(m7tgJosSPdpJs11qy16PwO16EdbgXnnSLKwKrh2qoAN2A9RwrtTqRL4Mg2sSoLwKrNAHwRy16EdbgkPhVvctdNG)gLSlCTqRvSAF1q5ZSVog0GXOuDnewTqRLJqgmKVKXvzNC2qoAN2A9RwrtTqR1BTCeYGH8LmYbg5JgPlkXyd5ODAR1VAfn1kiuRy1YrNuQ5Zoc40AwRhWyL)nkbJTVo27aKaFqienUG4emMs11qyGIcmMp9ttRGXER19gcmIBAyljn3uh2fUwbHA9wlhVoajBThQn6AHw7qC86aKKF7q16FTqQwp1kiulhVoajBThQfY16PwO1QWsoEIFSwO1EQtRUgIz1tsgqJKRYo5GXk)BucgNKpPdcLGpieIoAqCcgtP6AimqrbgZN(PPvWyV16EdbgXnnSLKMBQd7cxl0AfRwo6KsnF2raNwZAfeQ1BTU3qGDStSHWKKdmYhnou(skPbydae7cxl0A5Otk18zhbCAnR1tTcc16TwoEDas2ApuB01cT2H441bij)2HQ1)AHuTEQvqOwoEDas2ApulKRvqOw3BiW4QSto7cxRNAHwRcl54j(XAHw7PoT6AiMvpjzansUk7KdgR8VrjymE1eKoiuc(GqiAidItWykvxdHbkkWy(0pnTcg7Tw3BiWiUPHTK0CtDyx4AHwRy1YrNuQ5Zoc40AwRGqTER19gcSJDIneMKCGr(OXHYxsjnaBaGyx4AHwlhDsPMp7iGtRzTEQvqOwV1YXRdqYw7HAJUwO1oehVoaj53ouT(xlKQ1tTcc1YXRdqYw7HAHCTcc16EdbgxLDYzx4A9ul0AvyjhpXpwl0Ap1PvxdXS6jjdOrYvzNCWyL)nkbJdxJr6Gqj4dcHOfpqCcgR8VrjySpDMgnsuqsMBsGXuQUgcduuGpieIgsG4emMs11qyGIcmMp9ttRGXe30WwI1P0CtDQvqOwIBAylXSiJoYKe3xRGqTe30WwIPjGYKe3xRGqTU3qG5tNPrJefKK5Me7cxl0ADVHaJ4Mg2ssZn1HDHRvqOwV16EdbgxLDYzd5ODAR1)Av(3OK5B0hpJehXVpj)2HQfATU3qGXvzNC2fUwpGXk)BucgBFDc9qGpieIosaXjySY)gLGX(g9XdgtP6Aimqrb(GqiArdiobJPuDnegOOaJv(3OemEUPu5FJsPPTpySPTVmvhcmoOgZJFUGp4dgdpeh54QpiobHaUG4emw5FJsWyhekp2PmGghWykvxdHbkkWhecrdItWyL)nkbJp2j2qyslCp9BbJPuDnegOOaFqiazqCcgtP6AimqrbgR8VrjySVrF8GX8PFAAfm2BTe30WwIzUPoYKe3xRGqTe30WwI1P0CtDQvqOwIBAylX6u6IE81kiulXnnSLyAcOmjX916bm20jj5yGX4kc4dcbXdeNGXuQUgcduuGX8PFAAfm2BTe30WwIzUPoYKe3xRGqTe30WwI1P0CtDQvqOwIBAylX6u6IE81kiulXnnSLyAcOmjX916PwO1cp0jdxMVrF81cTwXQfEOtw0mFJ(4bJv(3Oem23OpEWhecqceNGXuQUgcduuGX8PFAAfmwSANBsb0aKyUQrtojrbPAmYhFNaTmkvxdHvRGqTIvlhDsPMplBG4FzqPAfeQvSATWKXiFDasVLzFDcQXu7HAXTwbHAfR2xnu(Su)7qwPRA0KtmkvxdHbgR8VrjyS91j0db(GqisaXjymLQRHWaffymF6NMwbJNBsb0aKyUQrtojrbPAmYhFNaTmkvxdHvl0A5Otk18zzde)ldkvl0ATWKXiFDasVLzFDcQXu7HAXfmw5FJsWy7RJ9oajWh8bFW4tASnkbHq0IeTi4gnUIhySpDYobAbJfTiAJdhc4WGG4xXxT1It8uTTdmA(AdOPwCm2qQJBNy0GJRDia0ThcRwlYHQvVpYrFcRwoEnbswwffaUtQ2OfF1gPO8KMNWQnUDI0ATaMVkUAf9AFuTa4RwlwF22gL1IGPrF0uRxi6PwV4kopSkkaCNuT4IR4R2ifLN08ewTXTtKwRfW8vXvROl61(OAbWxTwhe21CT1IGPrF0uRxr3tTEXvCEyvua4oPAXnAXxTrkkpP5jSAJBNiTwlG5RIRwrx0R9r1cGVAToiSR5ARfbtJ(OPwVIUNA9IR48WQOaWDs1IlKeF1gPO8KMNWQnUDI0ATaMVkUAf9AFuTa4RwlwF22gL1IGPrF0uRxi6PwV4kopSkQkkrlI24WHaomii(v8vBT4epvB7aJMV2aAQfhJrb9AECCTdbGU9qy1ArouT69ro6ty1YXRjqYYQOaWDs1gjIVAJuuEsZty1g3orATwaZxfxTIETpQwa8vRfRpBBJYArW0OpAQ1le9uR3OfNhwffaUtQwCK4R2ifLN08ewT445MuanajMOvCCTpQwC8CtkGgGet0kJs11qy44A9gT48WQOQOeTiAJdhc4WGG4xXxT1It8uTTdmA(AdOPwCm8qCKJR(44AhcaD7HWQ1ICOA17JC0NWQLJxtGKLvrbG7KQfsIVAJuuEsZty1IJNBsb0aKyIwXX1(OAXXZnPaAasmrRmkvxdHHJR1lUIZdRIca3jvBKi(Qnsr5jnpHvloEUjfqdqIjAfhx7JQfhp3KcObiXeTYOuDnegoUwV4kopSkQkkrlI24WHaomii(v8vBT4epvB7aJMV2aAQfhRichx7qaOBpewTwKdvREFKJ(ewTC8AcKSSkkaCNuTrl(Qnsr5jnpHvloEUjfqdqIjAfhx7JQfhp3KcObiXeTYOuDnegoUwV4kopSkkaCNuTqw8vBKIYtAEcR242jsR1cy(Q4Qv0f9AFuTa4RwRdc7AU2ArW0OpAQ1RO7PwV4kopSkkaCNuTqs8vBKIYtAEcR242jsR1cy(Q4Qv0R9r1cGVATy9zBBuwlcMg9rtTEHONA9IR48WQOaWDs1gzIVAJuuEsZty1g3orATwaZxfxTIETpQwa8vRfRpBBJYArW0OpAQ1le9uRxCfNhwffaUtQwCHS4R2ifLN08ewTXTtKwRfW8vXvROl61(OAbWxTwhe21CT1IGPrF0uRxr3tTEXvCEyvua4oPAXfhj(Qnsr5jnpHvBC7eP1AbmFvC1k61(OAbWxTwS(STnkRfbtJ(OPwVq0tTEXvCEyvua4oPAJweXxTrkkpP5jSAJBNiTwlG5RIRwrV2hvla(Q1I1NTTrzTiyA0hn16fIEQ1lUIZdRIca3jvB0qs8vBKIYtAEcR242jsR1cy(Q4Qv0R9r1cGVATy9zBBuwlcMg9rtTEHONA9gT48WQOQOeTiAJdhc4WGG4xXxT1It8uTTdmA(AdOPwCS9XX1oea62dHvRf5q1Q3h5OpHvlhVMajlRIca3jvlUIi(Qnsr5jnpHvBC7eP1AbmFvC1k6IETpQwa8vR1bHDnxBTiyA0hn16v09uRxCfNhwffaUtQwCXv8vBKIYtAEcR242jsR1cy(Q4Qv0f9AFuTa4RwRdc7AU2ArW0OpAQ1RO7PwV4kopSkkaCNuT4IJeF1gPO8KMNWQnUDI0ATaMVkUAf9AFuTa4RwlwF22gL1IGPrF0uRxi6PwV4kopSkQkkrlI24WHaomii(v8vBT4epvB7aJMV2aAQfh7I0hhx7qaOBpewTwKdvREFKJ(ewTC8AcKSSkkaCNuT4gjIVAJuuEsZty1g3orATwaZxfxTIETpQwa8vRfRpBBJYArW0OpAQ1le9uRxilopSkkaCNuT4kAeF1gPO8KMNWQnUDI0ATaMVkUAf9AFuTa4RwlwF22gL1IGPrF0uRxi6PwV4kopSkQkkCyoWO5jSAfn1Q8VrzTM2(wwffySfM4GqaxrIgmgEqH2qGX4q1kk1OjNQv8J52yvu4q1k(bXjhxAQf3ibG1gTirlsfvffouTrkEnbswXxffouT4GAfTXWiSAJrgDQvuK6WQOWHQfhuBKIxtGewTVoaPx2HA5QLS1(OA5aYnK81bi9wwffouT4GAXHtoOtcR2BMeNSwDaS2tDA11q2A92mIbWAHh6uAFDS3bivloWVAHh6KzFDS3bi5HvrHdvloOwr7tuJvl8qC1(DcSwrlJ(4RTd12po2w7JNQ13GsG1k(j30WwIvrHdvloOwX)0JuTrkkprhPAF8uTXW90VTwTwt)VHQ1bnuTbdjU21q16Td1ci6wlEflXXFT47V2(R12oxZRjHUwdG16RF81kkX)fTXzTruBKsgY(TAQv020athkFawB)4ySAThBypSkQkkL)nkTm4H4ihx9p4Gq5XoLb04urP8VrPLbpeh54QFehG4XoXgctAH7PFBfLY)gLwg8qCKJR(rCaI(g9XdqtNKKJDaxrayho4L4Mg2smZn1rMK4EbbIBAylX6uAUPocce30WwI1P0f94feiUPHTettaLjjU3tfLY)gLwg8qCKJR(rCaI(g9XdWoCWlXnnSLyMBQJmjX9cce30WwI1P0CtDeeiUPHTeRtPl6XliqCtdBjMMaktsCVhOWdDYWL5B0hpuXGh6KfnZ3Op(kkL)nkTm4H4ihx9J4aeTVoHEia2HdIn3KcObiXCvJMCsIcs1yKp(obAfeeJJoPuZNLnq8VmOKGGywyYyKVoaP3YSVob1yoGRGGyVAO8zP(3HSsx1OjNyuQUgcRIs5FJsldEioYXv)ioar7RJ9oaja2HdZnPaAasmx1OjNKOGung5JVtGwOC0jLA(SSbI)LbLGAHjJr(6aKElZ(6euJ5aUvuvu4q1k(P4i(9jSAPtAaS2VDOAF8uTk)rtTTTw9uBJ6AiwfLY)gL2dwKrhPlPovuk)BuApCQtRUgcGP6qhARureapvZLoyHjJr(6aKElZ(6euJXpCH6vSxnu(m7RJbnymkvxdHji8QHYNzFYy0rInD4zuQUgcZJGGfMmg5Rdq6Tm7Rtqng)IUIs5FJsBehG4PoT6AiaMQdDOTsUH0tcGNQ5shSWKXiFDasVLzFDc9q(HBfLY)gL2ioarxAS0CStGaSdh8kghDsPMplBG4FzqjbbX4iKbd5lzCuEIosYhpjTW90VLDH9a19gcmUk7KZUWvuk)BuAJ4aeHrFJsa2HdU3qGXvzNC2fUIs5FJsBehG4PoT6AiaMQdDGJYt0rsIrwatoapvZLoemi041BNpnWiJ(eMm0aX)YHC0oT4GOfbhWridgYxY4O8eDKKpEsAH7PFlBihTtRhrh3OfXJFbdcnE925tdmYOpHjdnq8VCihTtloiAiHd8IRir(RgkFwNCDs9BuYOuDneMhCGxokXU9ZGhI3wsQMgy6q5Z(2HKNQ5sEWbCeYGH8LmUk7KZgYr706r0XfhjIhbboczWq(sgxLDYzd5ODA9RZNgyKrFctgAG4F5qoANwbboczWq(sghLNOJK8XtslCp9Bzd5ODA9RZNgyKrFctgAG4F5qoANwbbX4Otk18zzde)ldkvrP8VrPnIdq8Ajz)Kdat1Ho0PLp3xDnKeaD18Vosm6S5ea7Wb3BiW4QSto7cxrHdvRY)gL2ioaXRLK9towaAnO3E4NopspUaSdhe7NopspdxgE1kHheNPjGq9k2pDEKEw0m8Qvcpiottafee7NopsplA2qkgGsoczWq(spccU3qGXvzNC2fwqGJqgmKVKXvzNC2qoANwCaUI43pDEKEgUmoczWq(sg2D0VrjuX4Otk18zhbCAnfe4Otk18zzde)ldkb9uNwDneJJYt0rsIrwatouoczWq(sghLNOJK8XtslCp9Bzxybb3BiWo2j2qysYbg5JghkFjL0aSbaIDHfecnq8VCihTtR)rlsffouTk)BuAJ4aeVws2p5ybO1GE7HF68i9rdWoCqSF68i9SOz4vReEqCMMac1Ry)05r6z4YWRwj8G4mnbuqqSF68i9mCzdPyak5iKbd5l9ii8tNhPNHldVALWdIZ0eqO)05r6zrZWRwj8G4mnbeQy)05r6z4YgsXauYridgYxki4EdbgxLDYzxybboczWq(sgxLDYzd5ODAXb4kIF)05r6zrZ4iKbd5lzy3r)gLqfJJoPuZNDeWP1uqGJoPuZNLnq8VmOe0tDA11qmokprhjjgzbm5q5iKbd5lzCuEIosYhpjTW90VLDHfeCVHa7yNydHjjhyKpACO8LusdWgai2fwqi0aX)YHC0oT(hTivuk)BuAJ4aeVws2p5ybyho4EdbgxLDYzxybboczWq(sgxLDYzd5ODA9dxrGkghDsPMp7iGtRPGahDsPMplBG4FzqjON60QRHyCuEIossmYcyYHYridgYxY4O8eDKKpEsAH7PFl7cdvmoczWq(sgxLDYzxyOE96EdbgXnnSLKMBQdBihTtRF4kIGG7neye30WwsArgDyd5ODA9dxr8avS5MuanajMRA0KtsuqQgJ8X3jqRGWCtkGgGeZvnAYjjkivJr(47eOfQx3BiWCvJMCsIcs1yKp(obALP(3Hy2x5h9dYccU3qG5Qgn5KefKQXiF8Dc0k1HRjXSVYp6hK94rqW9gcSJDIneMKCGr(OXHYxsjnaBaGyxybHqde)lhYr706F0IurP8VrPnIdqCUPu5FJsPPTpat1HoOicG2FA(Faxa2HdN60QRHyTvQiQIs5FJsBehG4CtPY)gLstBFaMQdDaBi1XTtmAaO9NM)hWfGD4WCtkGgGe7BhYhAsj2qQJBNy0Wia0THHjSkkL)nkTrCaIZnLk)BuknT9byQo0bxK(a0(tZ)d4cWoCyUjfqdqI5Qgn5KefKQXiF8Dc0Yia0THHjSkkL)nkTrCaIZnLk)BuknT9byQo0b7xrvrP8VrPLPi6WPoT6AiaMQdDaBi1r6Rngzqngjkea4PAU0bVU3qG9Td5dnPeBi1XTtmAyd5ODA9hihJ5OIlcry4ki4Edb23oKp0KsSHuh3oXOHnKJ2P1FL)nkz2xNqpeJehXVpj)2HIqegUq9sCtdBjwNsZn1rqG4Mg2smlYOJmjX9cce30WwIPjGYKe37Xdu3BiW(2H8HMuInK642jgnSlm05Muanaj23oKp0KsSHuh3oXOHraOBddtyvuk)BuAzkII4ae5O8eDKKpEsAH7PFla7WbVN60QRHyCuEIossmYcyYHkghHmyiFjJRYo5SHumafeCVHaJRYo5SlShOQ9h1iHr(OXFijcuVU3qGrCtdBjP5M6WgYr706xKii4EdbgXnnSLKwKrh2qoANw)Iepq9k2CtkGgGeZvnAYjjkivJr(47eOvqW9gcmx1OjNKOGung5JVtGwzQ)DiM9v(r)GSGG7neyUQrtojrbPAmYhFNaTsD4Asm7R8J(bzpccHgi(xoKJ2P1FCfPIs5FJsltruehGO91jOgda7Wb3BiWSVob1yydfgYIxDneuVwyYyKVoaP3YSVob1y8hYccIn3KcObiX(2H8HMuInK642jgnmcaDByycZduVIn3KcObiXmaY1rTYGHOVtGsGM2b2smcaDByyctq4Bhs0fDXds(5EdbM91jOgdBihTtBer7PIs5FJsltruehGO91jOgda7WH5Muanaj23oKp0KsSHuh3oXOHraOBddtyqTWKXiFDasVLzFDcQX43bid1RyU3qG9Td5dnPeBi1XTtmAyxyOU3qGzFDcQXWgkmKfV6AibbVN60QRHyydPosFTXidQXirHauVU3qGzFDcQXWgYr706pKfeSWKXiFDasVLzFDcQX4x0qF1q5ZSpzm6iXMo8mkvxdHb19gcm7Rtqng2qoANw)HKhpEQOu(3O0YuefXbiEQtRUgcGP6qhSVob1yK(q5ldQXirHaapvZLoO2FuJeg5Jg)WrIGd8IRirU7neyF7q(qtkXgsDC7eJgM9v(rp4aVU3qGzFDcQXWgYr70g5qw0TWKXiXR2N8Gd8IHEw4oakrbjzUjXgYr70g5qYdu3BiWSVob1yyx4kkL)nkTmfrrCaI2xh7DasaSdho1PvxdXWgsDK(AJrguJrIcbON60QRHy2xNGAmsFO8Lb1yKOqqqWR7neyUQrtojrbPAmYhFNaTYu)7qm7R8J(bzbb3BiWCvJMCsIcs1yKp(obAL6W1Ky2x5h9dYEGAHjJr(6aKElZ(6euJXFXRIs5FJsltruehGO9MHEiaYbKBi5Rdq6ThWfGD4WqHHS4vxdb91bi9SVDi5JKyn5hUIhoWctgJ81bi92igYr70cvHLC8e)iuIBAylX6uQjGvuk)BuAzkII4aevmf(7tsA9PJda5aYnK81bi92d4cWoCqSV5h7eiuXu(3OKPyk83NK06thhjM6OajwNYGPbI)feWqptXu4VpjP1Noosm1rbsm7R8J(dzOyONPyk83NK06thhjM6Oaj2qoANw)HCfLY)gLwMIOioarhekd9qaKdi3qYxhG0BpGla7WHHcdzXRUgc6Rdq6zF7qYhjXAYpV4kEr41ctgJ81bi9wM91j0df54YGKhpIUfMmg5Rdq6TrmKJ2PfQxoczWq(sgxLDYzdPyac17PoT6AighLNOJKeJSaMCbboczWq(sghLNOJK8XtslCp9BzdPyakiighDsPMplBG4FzqjpccwyYyKVoaP3YSVoHEi)9kErUxCJ4vdLp791P0bHslJs11qyE8ii4L4Mg2sSoLwKrhbbVe30WwI1P0f94feiUPHTeRtP5M64bQyVAO8zw01irb5JNKb0q2NrP6Aimbb3BiWGN2bnyTAK6W1S5s4RXQd7unxYVdrdjr8a1RfMmg5Rdq6Tm7RtOhYFCfjY9IBeVAO8zVVoLoiuAzuQUgcZJhOQ9h1iHr(OXpijcoW9gcm7Rtqng2qoAN2ips8a1RyU3qGDStSHWKKdmYhnou(skPbydae7cliqCtdBjwNslYOJGGyC0jLA(SJaoTMEGQWsoEIFSIs5FJsltruehGyanCsIcYu)7qaSdhuyjhpXpwrP8VrPLPikIdqC0tkrxRmmucaacWoCW9gcmUk7KZUWvuk)BuAzkII4ae5KHSFRgPAAGPdLpa7WbVU3qGzFDcQXWUWccQ9h1iHr(OXpijIhOI5EdbMfzSFZj2fgQyU3qGXvzNC2fgQxX4Otk18zzde)ldkjiCQtRUgIXr5j6ijXilGjxqGJqgmKVKXr5j6ijF8K0c3t)w2fwqOZNgyKrFctgAG4F5qoANw)JwKi8Yrj2TFg8q82ss10athkF23oK8unxYJNkkL)nkTmfrrCaIDY1j1Vrja7WbVU3qGzFDcQXWUWccQ9h1iHr(OXpijIhOI5EdbMfzSFZj2fgQyU3qGXvzNC2fgQxX4Otk18zzde)ldkjiCQtRUgIXr5j6ijXilGjxqGJqgmKVKXr5j6ijF8K0c3t)w2fwqOZNgyKrFctgAG4F5qoANw)5iKbd5lzCuEIosYhpjTW90VLnKJ2PnIirqOZNgyKrFctgAG4F5qoANwrx0XfhjI)qwKi8Yrj2TFg8q82ss10athkF23oK8unxYJNkkL)nkTmfrrCaIKdmYhnsxuIbWoCOZNgyKrFctgAG4F5qoANw)XfsccEDVHadEAh0G1QrQdxZMlHVgRoSt1Cj)JgsIii4Edbg80oObRvJuhUMnxcFnwDyNQ5s(DiAijIhOU3qGzFDcQXWUWq5iKbd5lzCv2jNnKJ2P1pijsfLY)gLwMIOioar7tgJoYGrhcGCa5gs(6aKE7bCbyhomuyilE11qq)2HKpsI1KF4cjOwyYyKVoaP3YSVoHEi)fpOkSKJN4hH619gcmUk7KZgYr706hUIiiiM7neyCv2jNDH9urP8VrPLPikIdqmChaLOGKm3KayhoqCtdBjwNsnbeQcl54j(rOU3qGbpTdAWA1i1HRzZLWxJvh2PAUK)rdjrG6fd9mftH)(KKwF64iXuhfiX(MFStGccIXrNuQ5ZsIpidAWeeSWKXiFDasV1VO9urP8VrPLPikIdq0(6euJbGD4G7neyOKE8wjmnCc(BuYUWq96EdbM91jOgdBOWqw8QRHeeu7pQrcJ8rJFrMiEQOu(3O0YuefXbiAFDcQXaWoCGJoPuZNLnq8VmOeuVN60QRHyCuEIossmYcyYfe4iKbd5lzCv2jNDHfeCVHaJRYo5SlShOCeYGH8Lmokprhj5JNKw4E63YgYr706pqogZrfxKZP24vT)OgjmYhnIoKeXdu3BiWSVob1yyd5ODA9x8QOu(3O0YuefXbiAFDS3bibWoCGJoPuZNLnq8VmOeuVN60QRHyCuEIossmYcyYfe4iKbd5lzCv2jNDHfeCVHaJRYo5SlShOCeYGH8Lmokprhj5JNKw4E63YgYr706FKa19gcm7Rtqng2fgkXnnSLyDk1eWkkL)nkTmfrrCaI2xh7DasaSdhCVHadL0J3k5gsh5zBBuYUWccEfZ(6e6HykSKJN4hfe86EdbgxLDYzd5ODA9hsqDVHaJRYo5SlSGGx3BiWg9Ks01kddLaaGSHC0oT(dKJXCuXf5CQnEv7pQrcJ8rJOdzr8a19gcSrpPeDTYWqjaai7c7Xd0tDA11qm7RtqngPpu(YGAmsuia1ctgJ81bi9wM91jOgJ)q2duVIn3KcObiX(2H8HMuInK642jgnmcaDByyctqWctgJ81bi9wM91jOgJ)q2tfLY)gLwMIOioaXK8jDqOeGD4GxIBAylX6uQjGq5iKbd5lzCv2jNnKJ2P1pijIGGxoEDas2drdDioEDasYVDi)HKhbboEDas2dq2dufwYXt8Jvuk)BuAzkII4aeXRMG0bHsa2HdEjUPHTeRtPMacLJqgmKVKXvzNC2qoANw)GKiccE541bizpen0H441bij)2H8hsEee441bizpazpqvyjhpXpwrP8VrPLPikIdqmCngPdcLaSdh8sCtdBjwNsnbekhHmyiFjJRYo5SHC0oT(bjree8YXRdqYEiAOdXXRdqs(Td5pK8iiWXRdqYEaYEGQWsoEIFSIs5FJsltruehGOpDMgnsuqsMBsvuk)BuAzkII4aep1PvxdbWuDOd2xNqpKStPfz0bGNQ5shSWKXiFDasVLzFDc9q(jEremi041rTpnakpvZLe9OfXtebdcnEDVHaZ(6yVdqssoWiF04q5lTiJom7R8JIU45PIs5FJsltruehGOVrF8aSdhiUPHTeZCtDKjjUxqG4Mg2smnbuMK4EON60QRHyTvYnKEsccU3qGrCtdBjPfz0HnKJ2P1FL)nkz2xNqpeJehXVpj)2HG6EdbgXnnSLKwKrh2fwqG4Mg2sSoLwKrhOIDQtRUgIzFDc9qYoLwKrhbb3BiW4QStoBihTtR)k)BuYSVoHEigjoIFFs(TdbvStDA11qS2k5gspjOU3qGXvzNC2qoANw)jXr87tYVDiOU3qGXvzNC2fwqW9gcSrpPeDTYWqjaai7cd1ctgJeVAFYpryrcuVwyYyKVoaP36)bilii2RgkFMfDnsuq(4jzanK9zuQUgcZJGGyN60QRHyTvYnKEsqDVHaJRYo5SHC0oT(rIJ43NKF7qvuk)BuAzkII4aeTVoHEOkkL)nkTmfrrCaIZnLk)BuknT9byQo0HGAmp(5wrvrP8VrPL5I0)WONuIUwzyOeaaeGD4G7neyCv2jNDHROu(3O0YCr6hXbiEQtRUgcGP6qh4t)j6VWa8unx6GyU3qG5Qgn5KefKQXiF8Dc0kt9VdXUWqfZ9gcmx1OjNKOGung5JVtGwPoCnj2fUIs5FJslZfPFehGOIPWFFssRpDCaihqUHKVoaP3Eaxa2HdU3qG5Qgn5KefKQXiF8Dc0kt9VdXSVYp6V4b19gcmx1OjNKOGung5JVtGwPoCnjM9v(r)fpOEfdd9mftH)(KKwF64iXuhfiX(MFStGqft5FJsMIPWFFssRpDCKyQJcKyDkdMgi(hQxXWqptXu4VpjP1Noos8KAyFZp2jqbbm0Zumf(7tsA9PJJepPg2qoANw)GShbbm0Zumf(7tsA9PJJetDuGeZ(k)O)qgkg6zkMc)9jjT(0XrIPokqInKJ2P1Fibfd9mftH)(KKwF64iXuhfiX(MFStGEQOu(3O0YCr6hXbiYr5j6ijF8K0c3t)wa2HdEp1PvxdX4O8eDKKyKfWKdvmoczWq(sgxLDYzdPyaki4EdbgxLDYzxypq96EdbMRA0KtsuqQgJ8X3jqRm1)oeZ(k)4biji4EdbMRA0KtsuqQgJ8X3jqRuhUMeZ(k)4bi5rqi0aX)YHC0oT(JRivuk)BuAzUi9J4ae5AYjJ09gcamvh6G91XGgma2HdEDVHaZvnAYjjkivJr(47eOvM6FhInKJ2P1pXJbjbb3BiWCvJMCsIcs1yKp(obAL6W1Kyd5ODA9t8yqYdu1(JAKWiF043HiteOE5iKbd5lzCv2jNnKJ2P1prJGGxoczWq(sg5aJ8rJ0fLySHC0oT(jAGkM7neyh7eBimj5aJ8rJdLVKsAa2aaXUWq5Otk18zhbCAn94PIs5FJslZfPFehGO91XEhGea7WbXo1PvxdX4t)j6VWq9YrNuQ5ZYgi(xgusqGJqgmKVKXvzNC2qoANw)enccE5iKbd5lzKdmYhnsxuIXgYr706NObQyU3qGDStSHWKKdmYhnou(skPbydae7cdLJoPuZNDeWP10JNkkL)nkTmxK(rCaI2xh7DasaSdh8YridgYxY4O8eDKKpEsAH7PFlBihTtR)qcQ3tDA11qmokprhjjgzbm5ccCeYGH8LmUk7KZgYr706pK84bQA)rnsyKpA8t8ebkhDsPMplBG4FzqPkkL)nkTmxK(rCaI2Bg6HaihqUHKVoaP3Eaxa2HddfgYIxDne0xhG0Z(2HKpsI1KF4gjq9QWsoEIFeQ3tDA11qm(0FI(lSGGx1(JAKWiF04pKfbQyU3qGXvzNC2f2JGahHmyiFjJRYo5SHuma94PIs5FJslZfPFehGOdcLHEiaYbKBi5Rdq6ThWfGD4WqHHS4vxdb91bi9SVDi5JKyn5hUqMbjOEvyjhpXpc17PoT6AigF6pr)fwqWRA)rnsyKpA8hYIavm3BiW4QSto7c7rqGJqgmKVKXvzNC2qkgGEGkM7neyh7eBimj5aJ8rJdLVKsAa2aaXUWEQOu(3O0YCr6hXbiAFYy0rgm6qaKdi3qYxhG0BpGla7WHHcdzXRUgc6Rdq6zF7qYhjXAYpCJKigYr70c1Rcl54j(rOEp1PvxdX4t)j6VWccQ9h1iHr(OXFilIGahHmyiFjJRYo5SHuma94PIs5FJslZfPFehGyanCsIcYu)7qaSdhuyjhpXpwrP8VrPL5I0pIdqmChaLOGKm3Kayho4L4Mg2sSoLAcOGaXnnSLywKrhzNsCfeiUPHTeZCtDKDkX1duVIXrNuQ5ZYgi(xgusqWRA)rnsyKpA8pYGeuVN60QRHy8P)e9xybb1(JAKWiF04pKfrq4uNwDneRTsfrEG69uNwDneJJYt0rsIrwatouX4iKbd5lzCuEIosYhpjTW90VLDHfee7uNwDneJJYt0rsIrwatouX4iKbd5lzCv2jNDH94XduVCeYGH8LmUk7KZgYr706hKfrqqT)OgjmYhn(fzIaLJqgmKVKXvzNC2fgQxoczWq(sg5aJ8rJ0fLySHC0oT(R8VrjZ(6e6HyK4i(9j53oKGGyC0jLA(SJaoTMEee68Pbgz0NWKHgi(xoKJ2P1FCfXduVyONPyk83NK06thhjM6Oaj2qoANw)epbbX4Otk18zjXhKbnyEQOu(3O0YCr6hXbisoWiF0iDrjga7WbVe30WwIzUPoYKe3liqCtdBjMfz0rMK4EbbIBAylX0eqzsI7feCVHaZvnAYjjkivJr(47eOvM6FhInKJ2P1pXJbjbb3BiWCvJMCsIcs1yKp(obAL6W1Kyd5ODA9t8yqsqqT)OgjmYhn(fzIaLJqgmKVKXvzNC2qkgGEG6LJqgmKVKXvzNC2qoANw)GSiccCeYGH8LmUk7KZgsXa0JGqNpnWiJ(eMm0aX)YHC0oT(JRivuk)BuAzUi9J4ae5KHSFRgPAAGPdLpa7WbVQ9h1iHr(OXViteOEDVHa7yNydHjjhyKpACO8LusdWgai2fwqqmo6KsnF2raNwtpccC0jLA(SSbI)LbLeeCVHaZ1GqyMR9zxyOU3qG5AqimZ1(SHC0oT(hTir4LJsSB)m4H4TLKQPbMou(SVDi5PAUKhpq9EQtRUgIXr5j6ijXilGjxqGJqgmKVKXr5j6ijF8K0c3t)w2qkgGEee68Pbgz0NWKHgi(xoKJ2P1)OfjcVCuID7NbpeVTKunnW0HYN9TdjpvZL8urP8VrPL5I0pIdqStUoP(nkbyho4vT)OgjmYhn(fzIa1R7neyh7eBimj5aJ8rJdLVKsAa2aaXUWccIXrNuQ5Zoc40A6rqGJoPuZNLnq8VmOKGG7neyUgecZCTp7cd19gcmxdcHzU2NnKJ2P1FilseE5Oe72pdEiEBjPAAGPdLp7BhsEQMl5XduVN60QRHyCuEIossmYcyYfe4iKbd5lzCuEIosYhpjTW90VLnKIbOhbHoFAGrg9jmzObI)Ld5ODA9hYIeHxokXU9ZGhI3wsQMgy6q5Z(2HKNQ5sEQOu(3O0YCr6hXbiEQtRUgcGP6qhulS4pAIjoapvZLoqCtdBjwNsZn1jYXrIUY)gLm7RtOhIrIJ43NKF7qrigXnnSLyDkn3uNipseDL)nkz(g9XZiXr87tYVDOieHfTOBHjJrIxTpvrP8VrPL5I0pIdq0(6yVdqcGD4G3oFAGrg9jmzObI)Ld5ODA9x8ee86Edb2ONuIUwzyOeaaKnKJ2P1FGCmMJkUiNtTXRA)rnsyKpAeDilIhOU3qGn6jLORvggkbaazxypEee8Q2FuJeg5JMio1PvxdXulS4pAIjEK7EdbgXnnSLKwKrh2qoAN2iWqplChaLOGKm3KyFZpALd5ODg5rZGKF4gTiccQ9h1iHr(OjItDA11qm1cl(JMyIh5U3qGrCtdBjP5M6WgYr70gbg6zH7aOefKK5Me7B(rRCihTZipAgK8d3OfXduIBAylX6uQjGq96vmoczWq(sgxLDYzxybbo6KsnF2raNwtOIXridgYxYihyKpAKUOeJDH9iiWrNuQ5ZYgi(xguYduVIXrNuQ5ZoP8Xd4iiiM7neyCv2jNDHfeu7pQrcJ8rJFrMiEeeCVHaJRYo5SHC0oT(HJGkM7neyJEsj6ALHHsaaq2fUIs5FJslZfPFehGys(KoiucWoCWR7neye30WwsAUPoSlSGGxoEDas2drdDioEDasYVDi)HKhbboEDas2dq2dufwYXt8Jvuk)BuAzUi9J4aeXRMG0bHsa2HdEDVHaJ4Mg2ssZn1HDHfe8YXRdqYEiAOdXXRdqs(Td5pK8iiWXRdqYEaYEGQWsoEIFSIs5FJslZfPFehGy4Amshekbyho419gcmIBAyljn3uh2fwqWlhVoaj7HOHoehVoaj53oK)qYJGahVoaj7bi7bQcl54j(XkkL)nkTmxK(rCaI(0zA0irbjzUjvrP8VrPL5I0pIdq0(6e6HayhoqCtdBjwNsZn1rqG4Mg2smlYOJmjX9cce30WwIPjGYKe3li4EdbMpDMgnsuqsMBsSlmu3BiWiUPHTK0CtDyxybbVU3qGXvzNC2qoANw)v(3OK5B0hpJehXVpj)2HG6EdbgxLDYzxypvuk)BuAzUi9J4ae9n6JVIs5FJslZfPFehG4CtPY)gLstBFaMQdDiOgZJFUvuvuk)BuAzydPoUDIrZHtDA11qamvh6GvdK8rYRLKwyYya4PAU0bVU3qG9Td5dnPeBi1XTtmAyd5ODA9dihJ5OIlcry4c1lXnnSLyDkDrpEbbIBAylX6uArgDeeiUPHTeZCtDKjjU3JGG7neyF7q(qtkXgsDC7eJg2qoANw)u(3OKzFDc9qmsCe)(K8Bhkcry4c1lXnnSLyDkn3uhbbIBAylXSiJoYKe3liqCtdBjMMaktsCVhpccI5Edb23oKp0KsSHuh3oXOHDHROu(3O0YWgsDC7eJMioar7RJ9oaja2HdEf7uNwDneZQbs(i51sslmzmccEDVHaB0tkrxRmmucaaYgYr706pqogZrfxKZP24vT)OgjmYhnIoKfXdu3BiWg9Ks01kddLaaGSlShpccQ9h1iHr(OXVitKkkL)nkTmSHuh3oXOjIdqKJYt0rs(4jPfUN(TaSdh8EQtRUgIXr5j6ijXilGjhANpnWiJ(eMm0aX)YHC0oT(HlKfbQyCeYGH8LmUk7KZgsXauqW9gcmUk7KZUWEGQ2FuJeg5Jg)fprG619gcmIBAyljn3uh2qoANw)Wvebb3BiWiUPHTK0Im6WgYr706hUI4rqi0aX)YHC0oT(JRivuk)BuAzydPoUDIrtehGOIPWFFssRpDCaihqUHKVoaP3Eaxa2HdIHHEMIPWFFssRpDCKyQJcKyFZp2jqOIP8VrjtXu4VpjP1Noosm1rbsSoLbtde)d1RyyONPyk83NK06thhjEsnSV5h7eOGag6zkMc)9jjT(0XrINudBihTtRFqYJGag6zkMc)9jjT(0XrIPokqIzFLF0Fidfd9mftH)(KKwF64iXuhfiXgYr706pKHIHEMIPWFFssRpDCKyQJcKyFZp2jWkkL)nkTmSHuh3oXOjIdq0bHYqpea5aYnK81bi92d4cWoCyOWqw8QRHG(6aKE23oK8rsSM8d3OH61R7neyCv2jNnKJ2P1pib1R7neyJEsj6ALHHsaaq2qoANw)GKGGyU3qGn6jLORvggkbaazxypccI5EdbgxLDYzxybb1(JAKWiF04pKfXduVI5Edb2XoXgctsoWiF04q5lPKgGnaqSlSGGA)rnsyKpA8hYI4bQcl54j(rpvuk)BuAzydPoUDIrtehGO9MHEiaYbKBi5Rdq6ThWfGD4WqHHS4vxdb91bi9SVDi5JKyn5hUrd1Rx3BiW4QStoBihTtRFqcQx3BiWg9Ks01kddLaaGSHC0oT(bjbbXCVHaB0tkrxRmmucaaYUWEeeeZ9gcmUk7KZUWccQ9h1iHr(OXFilIhOEfZ9gcSJDIneMKCGr(OXHYxsjnaBaGyxybb1(JAKWiF04pKfXdufwYXt8JEQOu(3O0YWgsDC7eJMioar7tgJoYGrhcGCa5gs(6aKE7bCbyhomuyilE11qqFDasp7Bhs(ijwt(HBKa1Rx3BiW4QStoBihTtRFqcQx3BiWg9Ks01kddLaaGSHC0oT(bjbbXCVHaB0tkrxRmmucaaYUWEeeeZ9gcmUk7KZUWccQ9h1iHr(OXFilIhOEfZ9gcSJDIneMKCGr(OXHYxsjnaBaGyxybb1(JAKWiF04pKfXdufwYXt8JEQOu(3O0YWgsDC7eJMioaXaA4KefKP(3HayhoOWsoEIFSIs5FJsldBi1XTtmAI4aeh9Ks01kddLaaGaSdhCVHaJRYo5SlCfLY)gLwg2qQJBNy0eXbisoWiF0iDrjga7WbVEDVHaJ4Mg2sslYOdBihTtRF4kIGG7neye30WwsAUPoSHC0oT(HRiEGYridgYxY4QStoBihTtRFqwepccCeYGH8LmUk7KZgsXaSIs5FJsldBi1XTtmAI4ae5KHSFRgPAAGPdLpa7WbVEDVHa7yNydHjjhyKpACO8LusdWgai2fwqqmo6KsnF2raNwtpccC0jLA(SSbI)LbLeeo1PvxdXARurKGG7neyUgecZCTp7cd19gcmxdcHzU2NnKJ2P1)OfjcVCuID7NbpeVTKunnW0HYN9TdjpvZL84bQyU3qGXvzNC2fgQxX4Otk18zzde)ldkjiWridgYxY4O8eDKKpEsAH7PFl7cli05tdmYOpHjdnq8VCihTtR)CeYGH8Lmokprhj5JNKw4E63YgYr70grKii05tdmYOpHjdnq8VCihTtROl64IJeX)OfjcVCuID7NbpeVTKunnW0HYN9TdjpvZL84PIs5FJsldBi1XTtmAI4ae7KRtQFJsa2HdE96Edb2XoXgctsoWiF04q5lPKgGnaqSlSGGyC0jLA(SJaoTMEee4Otk18zzde)ldkjiCQtRUgI1wPIibb3BiWCnieM5AF2fgQ7neyUgecZCTpBihTtR)qwKi8Yrj2TFg8q82ss10athkF23oK8unxYJhOI5EdbgxLDYzxyOEfJJoPuZNLnq8VmOKGahHmyiFjJJYt0rs(4jPfUN(TSlSGqNpnWiJ(eMm0aX)YHC0oT(ZridgYxY4O8eDKKpEsAH7PFlBihTtBerIGqNpnWiJ(eMm0aX)YHC0oTIUOJlose)HSir4LJsSB)m4H4TLKQPbMou(SVDi5PAUKhpvuk)BuAzydPoUDIrtehG4PoT6AiaMQdDWQNKmGgjxLDYb4PAU0bVIXridgYxY4QStoBifdqbbXo1PvxdX4O8eDKKyKfWKdLJoPuZNLnq8VmOKNkkL)nkTmSHuh3oXOjIdqmChaLOGKm3KayhoqCtdBjwNsnbeQcl54j(rOEXqptXu4VpjP1Noosm1rbsSV5h7eOGGyC0jLA(SK4dYGgmpqp1PvxdXS6jjdOrYvzN8kkL)nkTmSHuh3oXOjIdq0(6yVdqcGD4ahDsPMplBG4FzqjON60QRHyCuEIossmYcyYHQ2FuJeg5Jg)oiEIaLJqgmKVKXr5j6ijF8K0c3t)w2qoANw)bYXyoQ4ICo1gVQ9h1iHr(Or0HSiEQOu(3O0YWgsDC7eJMioaXK8jDqOeGD4Gx3BiWiUPHTK0CtDyxybbVC86aKShIg6qC86aKKF7q(djpccC86aKShGShOkSKJN4hHEQtRUgIz1tsgqJKRYo5vuk)BuAzydPoUDIrtehGiE1eKoiucWoCWR7neye30WwsAUPoSlmuX4Otk18zhbCAnfe86Edb2XoXgctsoWiF04q5lPKgGnaqSlmuo6KsnF2raNwtpccE541bizpen0H441bij)2H8hsEee441bizpazbb3BiW4QSto7c7bQcl54j(rON60QRHyw9KKb0i5QStEfLY)gLwg2qQJBNy0eXbigUgJ0bHsa2HdEDVHaJ4Mg2ssZn1HDHHkghDsPMp7iGtRPGGx3BiWo2j2qysYbg5JghkFjL0aSbaIDHHYrNuQ5Zoc40A6rqWlhVoaj7HOHoehVoaj53oK)qYJGahVoaj7bili4EdbgxLDYzxypqvyjhpXpc9uNwDneZQNKmGgjxLDYROu(3O0YWgsDC7eJMioarF6mnAKOGKm3KQOu(3O0YWgsDC7eJMioar7RtOhcGD4aXnnSLyDkn3uhbbIBAylXSiJoYKe3liqCtdBjMMaktsCVGG7ney(0zA0irbjzUjXUWqDVHaJ4Mg2ssZn1HDHfe86EdbgxLDYzd5ODA9x5FJsMVrF8msCe)(K8BhcQ7neyCv2jNDH9urP8VrPLHnK642jgnrCaI(g9XxrP8VrPLHnK642jgnrCaIZnLk)BuknT9byQo0HGAmp(5wrvrP8VrPLfuJ5Xp3d2xh7DasaSdheBUjfqdqI5Qgn5KefKQXiF8Dc0Yia0THHjSkkL)nkTSGAmp(5gXbiAVzOhcGCa5gs(6aKE7bCbyhoGHEMdcLHEi2qoANw)gYr70wrP8VrPLfuJ5Xp3ioarhekd9qvuvuk)BuAz2)GIPWFFssRpDCaihqUHKVoaP3Eaxa2HdIHHEMIPWFFssRpDCKyQJcKyFZp2jqOIP8VrjtXu4VpjP1Noosm1rbsSoLbtde)d1RyyONPyk83NK06thhjEsnSV5h7eOGag6zkMc)9jjT(0XrINudBihTtRFqYJGag6zkMc)9jjT(0XrIPokqIzFLF0Fidfd9mftH)(KKwF64iXuhfiXgYr706pKHIHEMIPWFFssRpDCKyQJcKyFZp2jWkkL)nkTm7hXbiYr5j6ijF8K0c3t)wa2HdEp1PvxdX4O8eDKKyKfWKdvmoczWq(sgxLDYzdPyaki4EdbgxLDYzxypqv7pQrcJ8rJ)INiq96EdbgXnnSLKMBQdBihTtRF4kIGG7neye30WwsArgDyd5ODA9dxr8iieAG4F5qoANw)XvKkkL)nkTm7hXbiEQtRUgcGP6qhWqVCia0ThYHY3cWt1CPdEDVHaJRYo5SHC0oT(bjOEDVHaB0tkrxRmmucaaYgYr706hKeeeZ9gcSrpPeDTYWqjaai7c7rqqm3BiW4QSto7cliO2FuJeg5Jg)HSiEG6vm3BiWo2j2qysYbg5JghkFjL0aSbaIDHfeu7pQrcJ8rJ)qwepq96EdbgXnnSLKwKrh2qoANw)aYXyoQ4eeCVHaJ4Mg2ssZn1HnKJ2P1pGCmMJkopvuk)BuAz2pIdq0bHYqpea5aYnK81bi92d4cWoCyOWqw8QRHG(6aKE23oK8rsSM8d3OH6vHLC8e)i0tDA11qmm0lhcaD7HCO8TEQOu(3O0YSFehGO9MHEiaYbKBi5Rdq6ThWfGD4WqHHS4vxdb91bi9SVDi5JKyn5hUrd1Rcl54j(rON60QRHyyOxoea62d5q5B9urP8VrPLz)ioar7tgJoYGrhcGCa5gs(6aKE7bCbyhomuyilE11qqFDasp7Bhs(ijwt(HBKa1Rcl54j(rON60QRHyyOxoea62d5q5B9urP8VrPLz)ioaXaA4KefKP(3HayhoOWsoEIFSIs5FJslZ(rCaIJEsj6ALHHsaaqa2HdU3qGXvzNC2fUIs5FJslZ(rCaIKdmYhnsxuIbWoCWRx3BiWiUPHTK0Im6WgYr706hUIii4EdbgXnnSLKMBQdBihTtRF4kIhOCeYGH8LmUk7KZgYr706hKfbQx3BiWGN2bnyTAK6W1S5s4RXQd7unxY)OfpreeeBUjfqdqIbpTdAWA1i1HRzZLWxJvhgbGUnmmH5XJGG7neyWt7GgSwnsD4A2Cj81y1HDQMl53HOfnIiiWridgYxY4QStoBifdqOEv7pQrcJ8rJFrMiccN60QRHyTvQiYtfLY)gLwM9J4ae5KHSFRgPAAGPdLpa7WbVQ9h1iHr(OXViteOEDVHa7yNydHjjhyKpACO8LusdWgai2fwqqmo6KsnF2raNwtpccC0jLA(SSbI)LbLeeo1PvxdXARurKGG7neyUgecZCTp7cd19gcmxdcHzU2NnKJ2P1)OfjcVEJSiFUjfqdqIbpTdAWA1i1HRzZLWxJvhgbGUnmmH5jcVCuID7NbpeVTKunnW0HYN9TdjpvZL84XduXCVHaJRYo5SlmuVIXrNuQ5ZYgi(xgusqGJqgmKVKXr5j6ijF8K0c3t)w2fwqOZNgyKrFctgAG4F5qoANw)5iKbd5lzCuEIosYhpjTW90VLnKJ2PnIirqOZNgyKrFctgAG4F5qoANwrx0XfhjI)rlseE5Oe72pdEiEBjPAAGPdLp7BhsEQMl5XtfLY)gLwM9J4ae7KRtQFJsa2HdEv7pQrcJ8rJFrMiq96Edb2XoXgctsoWiF04q5lPKgGnaqSlSGGyC0jLA(SJaoTMEee4Otk18zzde)ldkjiCQtRUgI1wPIibb3BiWCnieM5AF2fgQ7neyUgecZCTpBihTtR)qwKi86nYI85Muanajg80oObRvJuhUMnxcFnwDyea62WWeMNi8Yrj2TFg8q82ss10athkF23oK8unxYJhpqfZ9gcmUk7KZUWq9kghDsPMplBG4FzqjbboczWq(sghLNOJK8XtslCp9BzxybHoFAGrg9jmzObI)Ld5ODA9NJqgmKVKXr5j6ijF8K0c3t)w2qoAN2iIebHoFAGrg9jmzObI)Ld5ODAfDrhxCKi(dzrIWlhLy3(zWdXBljvtdmDO8zF7qYt1CjpEQOu(3O0YSFehG4PoT6AiaMQdDWQNKmGgjxLDYb4PAU0bVIXridgYxY4QStoBifdqbbXo1PvxdX4O8eDKKyKfWKdLJoPuZNLnq8VmOKNkkL)nkTm7hXbigUdGsuqsMBsaSdhiUPHTeRtPMacvHLC8e)iu3BiWGN2bnyTAK6W1S5s4RXQd7unxY)OfprG6fd9mftH)(KKwF64iXuhfiX(MFStGccIXrNuQ5ZsIpidAW8a9uNwDneZQNKmGgjxLDYROu(3O0YSFehGO91jOgda7Wb3BiWqj94TsyA4e83OKDHH6EdbM91jOgdBOWqw8QRHQOu(3O0YSFehGixtozKU3qaGP6qhSVog0GbWoCW9gcm7RJbnySHC0oT(djOEDVHaJ4Mg2sslYOdBihTtRFqsqW9gcmIBAyljn3uh2qoANw)GKhOQ9h1iHr(OXVitKkkL)nkTm7hXbiAFDS3bibWoCGJoPuZNLnq8VmOe0tDA11qmokprhjjgzbm5q5iKbd5lzCuEIosYhpjTW90VLnKJ2P1FivrP8VrPLz)ioar7Rtqnga2HdVAO8z2NmgDKythEgLQRHWGk2RgkFM91XGgmgLQRHWG6EdbM91jOgdBOWqw8QRHG619gcmIBAyljn3uh2qoANw)IeOe30WwI1P0CtDG6Edbg80oObRvJuhUMnxcFnwDyNQ5s(hnKerqW9gcm4PDqdwRgPoCnBUe(AS6WovZL87q0qseOQ9h1iHr(OXVitebbm0Zumf(7tsA9PJJetDuGeBihTtRF4ibbL)nkzkMc)9jjT(0XrIPokqI1PmyAG4FpqfJJqgmKVKXvzNC2qkgGvuk)BuAz2pIdq0(6yVdqcGD4G7neyOKE8wj3q6ipBBJs2fwqW9gcSJDIneMKCGr(OXHYxsjnaBaGyxybb3BiW4QSto7cd1R7neyJEsj6ALHHsaaq2qoANw)bYXyoQ4ICo1gVQ9h1iHr(Or0HSiEG6Edb2ONuIUwzyOeaaKDHfeeZ9gcSrpPeDTYWqjaai7cdvmoczWq(s2ONuIUwzyOeaaKnKIbOGGyC0jLA(StkF8aoEeeu7pQrcJ8rJFrMiqjUPHTeRtPMawrP8VrPLz)ioar7RJ9oaja2HdVAO8z2xhdAWyuQUgcdQx3BiWSVog0GXUWccQ9h1iHr(OXVitepqDVHaZ(6yqdgZ(k)O)qgQx3BiWiUPHTK0Im6WUWccU3qGrCtdBjP5M6WUWEG6Edbg80oObRvJuhUMnxcFnwDyNQ5s(hTOreOE5iKbd5lzCv2jNnKJ2P1pCfrqqStDA11qmokprhjjgzbm5q5Otk18zzde)ldk5PIs5FJslZ(rCaI2xh7DasaSdh86Edbg80oObRvJuhUMnxcFnwDyNQ5s(hTOrebb3BiWGN2bnyTAK6W1S5s4RXQd7unxY)OHKiqF1q5ZSpzm6iXMo8mkvxdH5bQ7neye30WwsArgDyd5ODA9t0aL4Mg2sSoLwKrhOI5EdbgkPhVvctdNG)gLSlmuXE1q5ZSVog0GXOuDneguoczWq(sgxLDYzd5ODA9t0a1lhHmyiFjJCGr(Or6Ism2qoANw)enccIXrNuQ5Zoc40A6PIs5FJslZ(rCaIj5t6Gqja7WbVU3qGrCtdBjP5M6WUWccE541bizpen0H441bij)2H8hsEee441bizpazpqvyjhpXpc9uNwDneZQNKmGgjxLDYROu(3O0YSFehGiE1eKoiucWoCWR7neye30WwsAUPoSlmuX4Otk18zhbCAnfe86Edb2XoXgctsoWiF04q5lPKgGnaqSlmuo6KsnF2raNwtpccE541bizpen0H441bij)2H8hsEee441bizpazbb3BiW4QSto7c7bQcl54j(rON60QRHyw9KKb0i5QStEfLY)gLwM9J4aedxJr6Gqja7WbVU3qGrCtdBjP5M6WUWqfJJoPuZNDeWP1uqWR7neyh7eBimj5aJ8rJdLVKsAa2aaXUWq5Otk18zhbCAn9ii4LJxhGK9q0qhIJxhGK8BhYFi5rqGJxhGK9aKfeCVHaJRYo5SlShOkSKJN4hHEQtRUgIz1tsgqJKRYo5vuk)BuAz2pIdq0NotJgjkijZnPkkL)nkTm7hXbiAFDc9qaSdhiUPHTeRtP5M6iiqCtdBjMfz0rMK4EbbIBAylX0eqzsI7feCVHaZNotJgjkijZnj2fgQ7neye30WwsAUPoSlSGGx3BiW4QStoBihTtR)k)BuY8n6JNrIJ43NKF7qqDVHaJRYo5SlSNkkL)nkTm7hXbi6B0hFfLY)gLwM9J4aeNBkv(3OuAA7dWuDOdb1yE8Zf8bFqqa]] )


end