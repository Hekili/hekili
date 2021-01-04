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


    spec:RegisterPack( "Balance", 20210102, [[dO0)LdqiOIhbvQ4suf0MaLpbvQAuuLofvLvba5vcHzbGUfuPyxO8lqLgguvhdQYYes9mOsMgvHCnqv2gvH6BqLsJJQaoNqKwNqeMhvr3tfSpcvhKQa1cju8qHOAIcru5Icru8rHisNeQuPwPqYmbG6McruANGk(PqevnuHiILsvG0tfQPcQQVcvQKXsvGyVG8xIgSshMYIPspgvtgOlJSzbFgqJMqoTKxRcnBsDBQy3I(nKHdLJleLLR45KmDvDDvA7QOVtv14ju68a06baZNG9l1q4bbFOyq7ji4en(rJh(4HF0m8J0OXT45XqXpGyeumMXpAajO40CiOyXyAl5eumMbOgzGqWhkwHUdNGIf9pMksax4cSErxxgh5axv5C12xOKpw4HRQC4Wfk29w6h3Dc5cfdApbbNOXpA8Whp8JMHFKgnUWv0qX29fHgO44YjYHIfvGGuc5cfdskoumUtVIX0wYPEJKBUfyhfUtVrz51ga7nAa2B04hnEDuDu4o9g5ISeiPIeDu4o9IB61dgeKa7ngPTPxXqMdRJc3PxCtVrUilbsG9(2aKEzf6LBks17J6LdixtY3gG0RyDu4o9IB61dk5GojWEVzsCsPSbWEpTPmxnP61BXiga7fBOtP6TrDhGuV4gX7fBOtM6TrDhGKpwhfUtV4ME9GprfyVydXn1xjWEXDn2lQ3k0B94EvVViQx)dkb2BKmCDHPiwhfUtV4MEJK1os9g5O8eDK69fr9gJvt9QETE11)AQxh0q9g0Kylxn1R3k0lGOBVImWe3)9kQ(ERVxv5C1VLe6Q0a2R)6f1RyIK3dg(9grVroPj1xMUxpyDbmDO8byV1J7b7vDSW8XGI1L6vqWhkgBioYX1Ei4dbh8GGpuSX)cLqXhReCiqPcRM6vqXuAUAcesmqpeCIgc(qXg)lucf7Gq5XkLb04aftP5QjqiXa9qWbxqWhkMsZvtGqIbk24FHsOy)J9IGI5t90uguS3EjUUWuetFtBKjj2VxbHEjUUWueRsP(M20RGqVexxykIvP0f9I6vqOxIRlmfXSeqzsI971huSUssYbHIXdFOhcoEee8HIP0C1eiKyGI5t90uguS3EjUUWuetFtBKjj2VxbHEjUUWueRsP(M20RGqVexxykIvP0f9I6vqOxIRlmfXSeqzsI971xVW6fBOtgEm)J9I6fwV40l2qNSOz(h7fbfB8VqjuS)XErqpeCGhe8HIP0C1eiKyGI5t90ugumo9o3KcObiXCnTLCsIcstRLVOkbQyuAUAcSxbHEXPxo6KslFwwaf9YGr9ki0lo9QWiTw(2aKEft92emTU3d9IxVcc9ItVVPP8zP93HusxtBjNyuAUAcek24FHsOy1BtOgc6HGJhdbFOyknxnbcjgOy(upnLbfp3KcObiXCnTLCsIcstRLVOkbQyuAUAcSxy9YrNuA5ZYcOOxgmQxy9QWiTw(2aKEft92emTU3d9IhuSX)cLqXQ3g1Dasqp0dfdsb7QFi4dbh8GGpuSX)cLqXkK2gPlzoqXuAUAcesmqpeCIgc(qXuAUAcesmqXimOyf9qXg)lucfFAtzUAck(00xckwHrAT8Tbi9kM6TjyADVI3lE9cRxV9ItVVPP8zQ3gnAazuAUAcSxbHEFtt5ZupP12ibNk8mknxnb2RVEfe6vHrAT8Tbi9kM6TjyADVI3B0qXN2itZHGIlL0qe0dbhCbbFOyknxnbcjgOyeguSIEOyJ)fkHIpTPmxnbfFA6lbfRWiTw(2aKEft92eQH6v8EXdk(0gzAoeuCPKCnzNe0dbhpcc(qXuAUAcesmqX8PEAkdk2BV40lhDsPLpllGIEzWOEfe6fNE5iKge5pzCuEIosYxejvy1uVIDX61xVW619gcmUjRKZUyqXg)lucf7sJIMJvce6HGd8GGpumLMRMaHedumFQNMYGIDVHaJBYk5SlguSX)cLqXyOVqj0dbhpgc(qXuAUAcesmqXimOyf9qXg)lucfFAtzUAck(00xckoOrOPxV96T3kFAWqA7jqzOak6Ld5yvQ6f30B043lUPxocPbr(tghLNOJK8frsfwn1Ryd5yvQ61xVWTx8Ig)E91R49g0i00R3E92BLpnyiT9eOmuaf9YHCSkv9IB6nA41lUPxV9Ih(9cG69nnLpRsUnP9fkzuAUAcSxF9IB61BVCucERNHneVuK00fW0HYN9Ldjpn9L61xV4ME5iKge5pzCtwjNnKJvPQxF9c3EXZdGFV(6vqOxocPbr(tg3KvYzd5yvQ6v8ER8PbdPTNaLHcOOxoKJvPQxbHE5iKge5pzCuEIosYxejvy1uVInKJvPQxX7TYNgmK2EcugkGIE5qowLQEfe6fNE5OtkT8zzbu0ldgbfFAJmnhckMJYt0rscskato0dbhCle8HIP0C1eiKyGIryqXk6HIn(xOek(0MYC1eu8PPVeuS3EXPxkYUfggbYihmahY0s0aMwYPEfe6LJqAqK)KroyaoKPLObmTKtSHCSkv96zV45X43lSEXPxocPbr(tg5Gb4qMwIgW0soXgYabSxF9ki0lhDsPLp7iGtzju8PnY0CiOyoOKJsW6luc9qWXdabFOyknxnbcjgOy(upnLbfZriniYFY4MSsoBihRsvVE2B043lSEpTPmxnX4O8eDKKGKcWK3RGqVCesdI8Nmokprhj5lIKkSAQxXgYXQu1RN9gn(qXP5qqXKdgGdzAjAatl5euSX)cLqXKdgGdzAjAatl5e0dbNifc(qXuAUAcesmqX8PEAkdkMJqAqK)KXnzLC2qowLQE9SxpUxy9EAtzUAIXr5j6ijbjfGjVxbHE5iKge5pzCuEIosYxejvy1uVInKJvPQxp71JHItZHGIvORwt)xjq5CDbek24FHsOyf6Q10)vcuoxxaHEi4Gh(qWhkMsZvtGqIbkMp1ttzqXU3qGXnzLC2fdkonhckUsfFUV5QjzKDT8Vosq6S4euSX)cLqXvQ4Z9nxnjJSRL)1rcsNfNGEi4GhEqWhkMsZvtGqIbkMp1ttzqXU3qGXnzLC2fRxbHE5OtkT8zzbu0ldg1lSEpTPmxnX4O8eDKKGKcWK3lSE5iKge5pzCuEIosYxejvy1uVIDX6fwV40lhH0Gi)jJBYk5SlwVW61BVE719gcmIRlmfj130g2qowLQEfVx8WVxbHEDVHaJ46ctrsfsBdBihRsvVI3lE43RVEH1lo9o3KcObiXCnTLCsIcstRLVOkbQyuAUAcSxbHENBsb0aKyUM2sojrbPP1YxuLavmknxnb2lSE92R7neyUM2sojrbPP1YxuLavY0(7qm1B8J9kEV4QxbHEDVHaZ10wYjjkinTw(IQeOsAd3sIPEJFSxX7fx96RxF9ki0R7neyhReCiqj5GH8tJdLVKsAawaaXUy9ki0BOak6Ld5yvQ61ZEJgFOyJ)fkHIVkswp5OGEi4Gx0qWhkMsZvtGqIbkMp1ttzqXN2uMRMyLsAickw9tXFi4GhuSX)cLqXZnLg)luk1L6HI1L6LP5qqXgIGEi4GhUGGpumLMRMaHedumFQNMYGINBsb0aKyF5q(rtkbhYCCReKggfz3cdJaHIv)u8hco4bfB8Vqju8CtPX)cLsDPEOyDPEzAoeum4qMJBLG0a9qWbppcc(qXuAUAcesmqX8PEAkdkEUjfqdqI5AAl5KefKMwlFrvcuXOi7wyyeiuS6NI)qWbpOyJ)fkHINBkn(xOuQl1dfRl1ltZHGIDr2d9qWbp4bbFOyknxnbcjgOyJ)fkHINBkn(xOuQl1dfRl1ltZHGIvp0d9qXGdzoUvcsde8HGdEqWhkMsZvtGqIbkgHbfROhk24FHsO4tBkZvtqXNM(sqXE719gcSVCi)OjLGdzoUvcsdBihRsvVI3lqoiZXeBVr0l(m86fwVE7L46ctrSkLUOxuVcc9sCDHPiwLsfsBtVcc9sCDHPiM(M2itsSFV(6vqOx3BiW(YH8JMucoK54wjinSHCSkv9kEVg)luYuVnHAigjwIFFs(Ld1Be9IpdVEH1R3EjUUWueRsP(M20RGqVexxykIPqABKjj2VxbHEjUUWueZsaLjj2VxF96RxbHEXPx3BiW(YH8JMucoK54wjinSlgu8PnY0CiOyLfi5JKxfjvyKwd9qWjAi4dftP5QjqiXafZN6PPmOyV9ItVN2uMRMyklqYhjVksQWiTUxbHE92R7neyJDsj6QKHHsaaq2qowLQE9SxGCqMJj2Ebq9YPs3R3En1pMwIH8ttVWTxCHFV(6fwVU3qGn2jLORsggkbaazxSE91RVEfe61u)yAjgYpn9kEVrk(qXg)lucfREBu3bib9qWbxqWhkMsZvtGqIbkMp1ttzqXE790MYC1eJJYt0rscskatEVW6TYNgmK2EcugkGIE5qowLQEfVx8Wf(9cRxC6LJqAqK)KXnzLC2qgiG9ki0R7neyCtwjNDX61xVW61u)yAjgYpn96zVEe(9cRxV96EdbgX1fMIK6BAdBihRsvVI3lE43RGqVU3qGrCDHPiPcPTHnKJvPQxX7fp871xVcc9gkGIE5qowLQE9Sx8Whk24FHsOyokprhj5lIKkSAQxb9qWXJGGpumLMRMaHeduSX)cLqXgOH91jjv(TXbkMp1ttzqX40li6zgOH91jjv(TXrcAogqI9f)yLa7fwV40RX)cLmd0W(6KKk)24ibnhdiXQug0fqrFVW61BV40li6zgOH91jjv(TXrkImn7l(Xkb2RGqVGONzGg2xNKu53ghPiY0SHCSkv9kEVWRxF9ki0li6zgOH91jjv(TXrcAogqIPEJFSxp7fx9cRxq0Zmqd7RtsQ8BJJe0CmGeBihRsvVE2lU6fwVGONzGg2xNKu53ghjO5yaj2x8JvcekMdixtY3gG0RGGdEqpeCGhe8HIP0C1eiKyGIn(xOek2bHYqneumFQNMYGIhkmKsK5QPEH17Bdq6zF5qYhjblQxX7fVO7fwVE71BVU3qGXnzLC2qowLQEfVx41lSE92R7neyJDsj6QKHHsaaq2qowLQEfVx41RGqV40R7neyJDsj6QKHHsaaq2fRxF9ki0lo96Edbg3KvYzxSEfe61u)yAjgYpn96zV4c)E91lSE92lo96Edb2Xkbhcusoyi)04q5lPKgGfaqSlwVcc9AQFmTed5NME9SxCHFV(6fwVgMKlI4h71humhqUMKVnaPxbbh8GEi44XqWhkMsZvtGqIbk24FHsOy1nd1qqX8PEAkdkEOWqkrMRM6fwVVnaPN9LdjFKeSOEfVx8IUxy96TxV96Edbg3KvYzd5yvQ6v8EHxVW61BVU3qGn2jLORsggkbaazd5yvQ6v8EHxVcc9ItVU3qGn2jLORsggkbaazxSE91RGqV40R7neyCtwjNDX6vqOxt9JPLyi)00RN9Il871xVW61BV40R7neyhReCiqj5GH8tJdLVKsAawaaXUy9ki0RP(X0smKFA61ZEXf(96Rxy9AysUiIFSxFqXCa5As(2aKEfeCWd6HGdUfc(qXuAUAcesmqXg)lucfREsRTrg02qqX8PEAkdkEOWqkrMRM6fwVVnaPN9LdjFKeSOEfVx884EH1R3E92R7neyCtwjNnKJvPQxX7fE9cRxV96Edb2yNuIUkzyOeaaKnKJvPQxX7fE9ki0lo96Edb2yNuIUkzyOeaaKDX61xVcc9ItVU3qGXnzLC2fRxbHEn1pMwIH8ttVE2lUWVxF9cRxV9ItVU3qGDSsWHaLKdgYpnou(skPbybae7I1RGqVM6htlXq(PPxp7fx43RVEH1RHj5Ii(XE9bfZbKRj5Bdq6vqWbpOhcoEai4dftP5QjqiXafZN6PPmOydtYfr8JqXg)lucfhqdNKOGmT)oe0dbNifc(qXuAUAcesmqX8PEAkdk29gcmUjRKZUyqXg)lucfp2jLORsggkbaaHEi4Gh(qWhkMsZvtGqIbkMp1ttzqXE71BVU3qGrCDHPiPcPTHnKJvPQxX7fp87vqOx3BiWiUUWuKuFtByd5yvQ6v8EXd)E91lSE5iKge5pzCtwjNnKJvPQxX7fx43RVEfe6LJqAqK)KXnzLC2qgiGqXg)lucftoyi)0iDrji0dbh8Wdc(qXuAUAcesmqX8PEAkdkgNEbNBbYsKKdQ6fwVN2uMRMyCqjhLG1xOSxy96TxV96Edb2Xkbhcusoyi)04q5lPKgGfaqSlwVcc9ItVC0jLw(SJaoLL96RxbHE5OtkT8zzbu0ldg1RGqVN2uMRMyLsAiQxbHEDVHaZvJqG6R6zxSEH1R7neyUAecuFvpBihRsvVE2B043Be96TxokbV1ZWgIxksA6cy6q5Z(YHKNM(s96RxF9cRxC619gcmUjRKZUy9cRxV9ItVC0jLw(SSak6LbJ6vqOxocPbr(tghLNOJK8frsfwn1RyxSEfe6TYNgmK2EcugkGIE5qowLQE9SxocPbr(tghLNOJK8frsfwn1Ryd5yvQ6nIE94Efe6TYNgmK2EcugkGIE5qowLQE9WEXZdGFVE2B043Be96TxokbV1ZWgIxksA6cy6q5Z(YHKNM(s96RxFqXg)lucfZjnP(Y0stxathkFOhco4fne8HIP0C1eiKyGI5t90ugumo9co3cKLijhu1lSEpTPmxnX4GsokbRVqzVW61BVE719gcSJvcoeOKCWq(PXHYxsjnalaGyxSEfe6fNE5OtkT8zhbCkl71xVcc9YrNuA5ZYcOOxgmQxbHEpTPmxnXkL0quVcc96EdbMRgHa1x1ZUy9cRx3BiWC1ieO(QE2qowLQE9SxCHFVr0R3E5Oe8wpdBiEPiPPlGPdLp7lhsEA6l1RVE91lSEXPx3BiW4MSso7I1lSE92lo9YrNuA5ZYcOOxgmQxbHE5iKge5pzCuEIosYxejvy1uVIDX6vqO3kFAWqA7jqzOak6Ld5yvQ61ZE5iKge5pzCuEIosYxejvy1uVInKJvPQ3i61J7vqO3kFAWqA7jqzOak6Ld5yvQ61d7fppa(96zV4c)EJOxV9Yrj4TEg2q8srstxathkF2xoK800xQxF96dk24FHsO4k52K2xOe6HGdE4cc(qXuAUAcesmqXimOyf9qXg)lucfFAtzUAck(00xckgNE5iKge5pzCtwjNnKbcyVcc9ItVN2uMRMyCuEIossqsbyY7fwVC0jLw(SSak6LbJ6vqOxW5wGSej5GkO4tBKP5qqXk7KKb0i5MSso0dbh88ii4dftP5QjqiXafZN6PPmOyIRlmfXQuAjG9cRxdtYfr8J9cRxV9cIEMbAyFDssLFBCKGMJbKyFXpwjWEfe6fNE5OtkT8zjXhKgnG96Rxy9EAtzUAIPStsgqJKBYk5qXg)lucfhUdGsuqs6BsqpeCWdEqWhkMsZvtGqIbkMp1ttzqXC0jLw(SSak6LbJ6fwVN2uMRMyCuEIossqsbyY7fwVM6htlXq(PPxXp0RhHFVW6LJqAqK)KXr5j6ijFrKuHvt9k2qowLQE9SxGCqMJj2Ebq9YPs3R3En1pMwIH8ttVWTxCHFV(6fwV40l4ClqwIKCqfuSX)cLqXQ3g1DasqpeCWZJHGpumLMRMaHedumFQNMYGI92R7neyexxyksQVPnSlwVcc96TxUiBasQEp0B09cR3H4ISbij)YH61ZEHxV(6vqOxUiBasQEp0lU61xVW61WKCre)yVW690MYC1etzNKmGgj3KvYHIn(xOekoj)shekHEi4GhUfc(qXuAUAcesmqX8PEAkdk2BVU3qGrCDHPiP(M2WUy9cRxC6LJoP0YNDeWPSSxbHE92R7neyhReCiqj5GH8tJdLVKsAawaaXUy9cRxo6KslF2raNYYE91RGqVE7LlYgGKQ3d9gDVW6DiUiBasYVCOE9Sx41RVEfe6LlYgGKQ3d9IREfe619gcmUjRKZUy96Rxy9AysUiIFSxy9EAtzUAIPStsgqJKBYk5qXg)lucflY0bPdcLqpeCWZdabFOyknxnbcjgOy(upnLbf7Tx3BiWiUUWuKuFtByxSEH1lo9YrNuA5Zoc4uw2RGqVE719gcSJvcoeOKCWq(PXHYxsjnalaGyxSEH1lhDsPLp7iGtzzV(6vqOxV9Yfzdqs17HEJUxy9oexKnaj5xouVE2l861xVcc9Yfzdqs17HEXvVcc96Edbg3KvYzxSE91lSEnmjxeXp2lSEpTPmxnXu2jjdOrYnzLCOyJ)fkHIdxTw6Gqj0dbh8Iui4dfB8VqjuSFBMcnsuqs6BsqXuAUAcesmqpeCIgFi4dftP5QjqiXafZN6PPmOyIRlmfXQuQVPn9ki0lX1fMIykK2gzsI97vqOxIRlmfXSeqzsI97vqOx3BiW8BZuOrIcssFtIDX6fwVU3qGrCDHPiP(M2WUy9ki0R3EDVHaJBYk5SHCSkv96zVg)luY8p2lIrIL43NKF5q9cRx3BiW4MSso7I1RpOyJ)fkHIvVnHAiOhcorJhe8HIn(xOek2)yViOyknxnbcjgOhcorhne8HIP0C1eiKyGIn(xOekEUP04FHsPUupuSUuVmnhckoyA9lAUqp0dfBicc(qWbpi4dftP5QjqiXafJWGIv0dfB8Vqju8PnL5QjO4ttFjOyV96Edb2xoKF0KsWHmh3kbPHnKJvPQxp7fihK5yIT3i6fFgE9ki0R7neyF5q(rtkbhYCCReKg2qowLQE9SxJ)fkzQ3MqneJelXVpj)YH6nIEXNHxVW61BVexxykIvPuFtB6vqOxIRlmfXuiTnYKe73RGqVexxykIzjGYKe73RVE91lSEDVHa7lhYpAsj4qMJBLG0WUy9cR35Muanaj2xoKF0KsWHmh3kbPHrr2TWWiqO4tBKP5qqXGdzos)LwldMwlrHa0dbNOHGpumLMRMaHedumcdkwrpuSX)cLqXN2uMRMGIpn9LGIDVHaJ46ctrs9nTHDX6fwVE7vHrAT8Tbi9kM6Tjud1R496r9cR330u(mf6QLOG8frYaAi1ZO0C1eyVcc9QWiTw(2aKEft92eQH6v8E94E9bfFAJmnhckUaMOHKQ3g1DasqpeCWfe8HIP0C1eiKyGI5t90uguS3EpTPmxnX4O8eDKKGKcWK3lSEXPxocPbr(tg3KvYzdzGa2RGqVU3qGXnzLC2fRxF9cRxV9AQFmTed5NME9Sx4HFVcc9EAtzUAIvat0qs1BJ6oaPE91lSE92R7neyexxyksQVPnSHCSkv9kEVECVcc96EdbgX1fMIKkK2g2qowLQEfVxpUxF9cRxV9ItVZnPaAasmxtBjNKOG00A5lQsGkgLMRMa7vqOx3BiWCnTLCsIcstRLVOkbQKP93HyQ34h7v8EXvVcc96EdbMRPTKtsuqAAT8fvjqL0gULet9g)yVI3lU61xVcc9gkGIE5qowLQE9Sx8Whk24FHsOyokprhj5lIKkSAQxb9qWXJGGpumLMRMaHeduSX)cLqXQBgQHGI5t90ugu8qHHuImxn1lSEFBasp7lhs(ijyr9kEV45r9IB6vHrAT8Tbi9QEJO3HCSkv9cRxV9sCDHPiwLslbSxbHEhYXQu1RN9cKdYCmX2RpOyoGCnjFBasVcco4b9qWbEqWhkMsZvtGqIbkMp1ttzqXU3qGPEBcMwZgkmKsK5QPEH1R3EvyKwlFBasVIPEBcMw3RN9IREfe6fNENBsb0aKyF5q(rtkbhYCCReKggfz3cdJa71xVW61BV407CtkGgGetdi3gtjdAI(kbkbQlhmfXOi7wyyeyVcc9(Ld1Rh2RhbVEfVx3BiWuVnbtRzd5yvQ6nIEJUxF9cR3qbu0lhYXQu1R49cpOyJ)fkHIvVnbtRHEi44XqWhkMsZvtGqIbkMp1ttzqXZnPaAasSVCi)OjLGdzoUvcsdJISBHHrG9cRxfgP1Y3gG0RyQ3MGP19k(HEXvVW61BV40R7neyF5q(rtkbhYCCReKg2fRxy96EdbM6TjyAnBOWqkrMRM6vqOxV9EAtzUAIboK5i9xATmyATefc9cRxV96EdbM6TjyAnBihRsvVE2lU6vqOxfgP1Y3gG0RyQ3MGP19kEVr3lSEFtt5ZupP12ibNk8mknxnb2lSEDVHat92emTMnKJvPQxp7fE96RxF96dk24FHsOy1BtW0AOhco4wi4dftP5QjqiXafJWGIv0dfB8Vqju8PnL5QjO4ttFjOyt9JPLyi)00R496bWVxCtVE7fp87fa1R7neyF5q(rtkbhYCCReKgM6n(XE91lUPxV96EdbM6TjyAnBihRsvVaOEXvVWTxfgP1srM6PE91lUPxV9cIEw4oakrbjPVjXgYXQu1laQx41RVEH1R7neyQ3MGP1Slgu8PnY0CiOy1BtW0APFu(YGP1suia9qWXdabFOyknxnbcjgOy(upnLbfFAtzUAIboK5i9xATmyATefc9cR3tBkZvtm1BtW0APFu(YGP1sui0lSEXP3tBkZvtScyIgsQEBu3bi1RGqVE719gcmxtBjNKOG00A5lQsGkzA)DiM6n(XEfVxC1RGqVU3qG5AAl5KefKMwlFrvcujTHBjXuVXp2R49IRE91lSEvyKwlFBasVIPEBcMw3RN96rqXg)lucfREBu3bib9qWjsHGpumLMRMaHeduSX)cLqXgOH91jjv(TXbkMp1ttzqX407x8JvcSxy9ItVg)luYmqd7RtsQ8BJJe0CmGeRszqxaf99ki0li6zgOH91jjv(TXrcAogqIPEJFSxp7fx9cRxq0Zmqd7RtsQ8BJJe0CmGeBihRsvVE2lUGI5aY1K8Tbi9ki4Gh0dbh8Whc(qXuAUAcesmqXg)lucf7GqzOgckMp1ttzqXdfgsjYC1uVW69Tbi9SVCi5JKGf1R496Tx88OEJOxV9QWiTw(2aKEft92eQH6fa1lEm41RVE91lC7vHrAT8Tbi9QEJO3HCSkv9cRxV96TxocPbr(tg3KvYzdzGa2lSEXPxW5wGSej5GQEH1R3EpTPmxnX4O8eDKKGKcWK3RGqVCesdI8Nmokprhj5lIKkSAQxXgYabSxbHEXPxo6KslFwwaf9YGr96RxbHEvyKwlFBasVIPEBc1q96zVE7fE9cG61BV41Be9(MMYN9(Ru6GqPIrP5QjWE91RVEfe61BVexxykIvPuH020RGqVE7L46ctrSkLUOxuVcc9sCDHPiwLs9nTPxF9cRxC69nnLptHUAjkiFrKmGgs9mknxnb2RGqVU3qGHnLdAaltlTHBzXLyxTYg2PPVuVIFO3OHh(96Rxy96TxfgP1Y3gG0RyQ3MqnuVE2lE43laQxV9IxVr07BAkF27VsPdcLkgLMRMa71xV(6fwVM6htlXq(PPxX7fE43lUPx3BiWuVnbtRzd5yvQ6fa1Rh3RVEH1R3EXPx3BiWowj4qGsYbd5NghkFjL0aSaaIDX6vqOxIRlmfXQuQqAB6vqOxC6LJoP0YNDeWPSSxF9cRxdtYfr8J96dkMdixtY3gG0RGGdEqpeCWdpi4dftP5QjqiXafZN6PPmOydtYfr8JqXg)lucfhqdNKOGmT)oe0dbh8Igc(qXuAUAcesmqX8PEAkdk29gcmUjRKZUyqXg)lucfp2jLORsggkbaaHEi4GhUGGpumLMRMaHedumFQNMYGIXPxW5wGSej5GQEH17PnL5QjghuYrjy9fk7fwVE719gcm1BtW0A2fRxbHEn1pMwIH8ttVI3l8WVxF9cRxC619gcmfsR(ItSlwVW6fNEDVHaJBYk5SlwVW61BV40lhDsPLpllGIEzWOEfe690MYC1eJJYt0rscskatEVcc9YriniYFY4O8eDKKVisQWQPEf7I1RGqVv(0GH02tGYqbu0lhYXQu1RN9gn(9grVE7LJsWB9mSH4LIKMUaMou(SVCi5PPVuV(61huSX)cLqXCstQVmT00fW0HYh6HGdEEee8HIP0C1eiKyGI5t90ugumo9co3cKLijhu1lSEpTPmxnX4GsokbRVqzVW61BVU3qGPEBcMwZUy9ki0RP(X0smKFA6v8EHh(96Rxy9ItVU3qGPqA1xCIDX6fwV40R7neyCtwjNDX6fwVE7fNE5OtkT8zzbu0ldg1RGqVN2uMRMyCuEIossqsbyY7vqOxocPbr(tghLNOJK8frsfwn1RyxSEfe6TYNgmK2EcugkGIE5qowLQE9SxocPbr(tghLNOJK8frsfwn1Ryd5yvQ6nIE94Efe6TYNgmK2EcugkGIE5qowLQE9WEXZdGFVE2lUWV3i61BVCucERNHneVuK00fW0HYN9Ldjpn9L61xV(GIn(xOekUsUnP9fkHEi4Gh8GGpumLMRMaHedumFQNMYGIR8PbdPTNaLHcOOxoKJvPQxp7fp41RGqVE719gcmSPCqdyzAPnCllUe7Qv2Won9L61ZEJgE43RGqVU3qGHnLdAaltlTHBzXLyxTYg2PPVuVIFO3OHh(96Rxy96EdbM6TjyAn7I1lSE92lhH0Gi)jJBYk5SHCSkv9kEVWd)Efe6fCUfilrsoOQxFqXg)lucftoyi)0iDrji0dbh88yi4dftP5QjqiXafB8VqjuS6jT2gzqBdbfZN6PPmO4HcdPezUAQxy9(LdjFKeSOEfVx8GxVW6vHrAT8Tbi9kM6Tjud1RN96r9cRxdtYfr8J9cRxV96Edbg3KvYzd5yvQ6v8EXd)Efe6fNEDVHaJBYk5SlwV(GI5aY1K8Tbi9ki4Gh0dbh8WTqWhkMsZvtGqIbkMp1ttzqXexxykIvP0sa7fwVgMKlI4h7fwVU3qGHnLdAaltlTHBzXLyxTYg2PPVuVE2B0Wd)EH1R3EbrpZanSVojPYVnosqZXasSV4hReyVcc9ItVC0jLw(SK4dsJgWEfe6vHrAT8Tbi9QEfV3O71huSX)cLqXH7aOefKK(Me0dbh88aqWhkMsZvtGqIbkMp1ttzqXU3qGHs6fPKy0WjSVqj7I1lSE92R7neyQ3MGP1SHcdPezUAQxbHEn1pMwIH8ttVI3BKIFV(GIn(xOekw92emTg6HGdErke8HIP0C1eiKyGI5t90ugumhDsPLpllGIEzWOEH1R3EpTPmxnX4O8eDKKGKcWK3RGqVCesdI8NmUjRKZUy9ki0R7neyCtwjNDX61xVW6LJqAqK)KXr5j6ijFrKuHvt9k2qowLQE9SxGCqMJj2Ebq9YPs3R3En1pMwIH8ttVWTx4HFV(6fwVU3qGPEBcMwZgYXQu1RN96r9cRxC6fCUfilrsoOck24FHsOy1BtW0AOhcorJpe8HIP0C1eiKyGI5t90ugumhDsPLpllGIEzWOEH1R3EpTPmxnX4O8eDKKGKcWK3RGqVCesdI8NmUjRKZUy9ki0R7neyCtwjNDX61xVW6LJqAqK)KXr5j6ijFrKuHvt9k2qowLQE9SxpUxy96EdbM6TjyAn7I1lSEjUUWueRsPLa2lSEXP3tBkZvtScyIgsQEBu3bi1lSEXPxW5wGSej5GkOyJ)fkHIvVnQ7aKGEi4enEqWhkMsZvtGqIbkMp1ttzqXU3qGHs6fPKCnzJ8SufkzxSEfe61BV40R6TjudXmmjxeXp2RGqVE719gcmUjRKZgYXQu1RN9cVEH1R7neyCtwjNDX6vqOxV96Edb2yNuIUkzyOeaaKnKJvPQxp7fihK5yITxauVCQ096Txt9JPLyi)00lC7fx43RVEH1R7neyJDsj6QKHHsaaq2fRxF96Rxy9EAtzUAIPEBcMwl9JYxgmTwIcHEH1RcJ0A5Bdq6vm1BtW06E9SxC1RVEH1R3EXP35Muanaj2xoKF0KsWHmh3kbPHrr2TWWiWEfe6vHrAT8Tbi9kM6TjyADVE2lU61huSX)cLqXQ3g1DasqpeCIoAi4dftP5QjqiXafZN6PPmOyV9sCDHPiwLslbSxy9YriniYFY4MSsoBihRsvVI3l8WVxbHE92lxKnajvVh6n6EH17qCr2aKKF5q96zVWRxF9ki0lxKnajvVh6fx96Rxy9AysUiIFek24FHsO4K8lDqOe6HGt04cc(qXuAUAcesmqX8PEAkdk2BVexxykIvP0sa7fwVCesdI8NmUjRKZgYXQu1R49cp87vqOxV9Yfzdqs17HEJUxy9oexKnaj5xouVE2l861xVcc9Yfzdqs17HEXvV(6fwVgMKlI4hHIn(xOekwKPdshekHEi4eThbbFOyknxnbcjgOy(upnLbf7TxIRlmfXQuAjG9cRxocPbr(tg3KvYzd5yvQ6v8EHh(9ki0R3E5ISbiP69qVr3lSEhIlYgGK8lhQxp7fE96RxbHE5ISbiP69qV4QxF9cRxdtYfr8JqXg)lucfhUAT0bHsOhcordpi4dfB8VqjuSFBMcnsuqs6BsqXuAUAcesmqpeCI2JHGpumLMRMaHedumcdkwrpuSX)cLqXN2uMRMGIpn9LGIvyKwlFBasVIPEBc1q9kEVEuVr0BqJqtVE71Xupnakpn9L6fa1lE4JFVWT3OXVxF9grVbncn96Tx3BiWuVnQ7aKKKdgYpnou(sfsBdt9g)yVWTxpQxFqXN2itZHGIvVnHAizLsfsBd0dbNOXTqWhkMsZvtGqIbkMp1ttzqXexxykIPVPnYKe73RGqVexxykIzjGYKe73lSEpTPmxnXkLKRj7K6vqOx3BiWiUUWuKuH02WgYXQu1RN9A8Vqjt92eQHyKyj(9j5xouVW619gcmIRlmfjviTnSlwVcc9sCDHPiwLsfsBtVW6fNEpTPmxnXuVnHAizLsfsBtVcc96Edbg3KvYzd5yvQ61ZEn(xOKPEBc1qmsSe)(K8lhQxy9ItVN2uMRMyLsY1KDs9cRx3BiW4MSsoBihRsvVE2ljwIFFs(Ld1lSEDVHaJBYk5SlwVcc96Edb2yNuIUkzyOeaaKDX6fwVkmsRLIm1t9kEV4Z84EH1R3EvyKwlFBasVQxpp0lU6vqOxC69nnLptHUAjkiFrKmGgs9mknxnb2RVEfe6fNEpTPmxnXkLKRj7K6fwVU3qGXnzLC2qowLQEfVxsSe)(K8lhck24FHsOy)J9IGEi4eThac(qXg)lucfREBc1qqXuAUAcesmqpeCIosHGpumLMRMaHeduSX)cLqXZnLg)luk1L6HI1L6LP5qqXbtRFrZf6HEO4GP1VO5cbFi4Ghe8HIP0C1eiKyGI5t90ugumo9o3KcObiXCnTLCsIcstRLVOkbQyuKDlmmcek24FHsOy1BJ6oajOhcordbFOyknxnbcjgOyJ)fkHIv3mudbfZN6PPmOyq0ZCqOmudXgYXQu1R49oKJvPckMdixtY3gG0RGGdEqpeCWfe8HIn(xOek2bHYqneumLMRMaHed0d9qXQhc(qWbpi4dftP5QjqiXafB8VqjuSbAyFDssLFBCGI5t90ugumo9cIEMbAyFDssLFBCKGMJbKyFXpwjWEH1lo9A8VqjZanSVojPYVnosqZXasSkLbDbu03lSE92lo9cIEMbAyFDssLFBCKIitZ(IFSsG9ki0li6zgOH91jjv(TXrkImnBihRsvVI3l861xVcc9cIEMbAyFDssLFBCKGMJbKyQ34h71ZEXvVW6fe9md0W(6KKk)24ibnhdiXgYXQu1RN9IREH1li6zgOH91jjv(TXrcAogqI9f)yLaHI5aY1K8Tbi9ki4Gh0dbNOHGpumLMRMaHedumFQNMYGI927PnL5QjghLNOJKeKuaM8EH1lo9YriniYFY4MSsoBideWEfe619gcmUjRKZUy96Rxy9AQFmTed5NME9Sxpc)EH1R3EDVHaJ46ctrs9nTHnKJvPQxX7fp87vqOx3BiWiUUWuKuH02WgYXQu1R49Ih(96RxbHEdfqrVCihRsvVE2lE4dfB8VqjumhLNOJK8frsfwn1RGEi4Gli4dftP5QjqiXafJWGIv0dfB8Vqju8PnL5QjO4ttFjOyV96Edbg3KvYzd5yvQ6v8EHxVW61BVU3qGn2jLORsggkbaazd5yvQ6v8EHxVcc9ItVU3qGn2jLORsggkbaazxSE91RGqV40R7neyCtwjNDX6vqOxt9JPLyi)00RN9Il871xVW61BV40R7neyhReCiqj5GH8tJdLVKsAawaaXUy9ki0RP(X0smKFA61ZEXf(96Rxy96Tx3BiWiUUWuKuH02WgYXQu1R49cKdYCmX2RGqVU3qGrCDHPiP(M2WgYXQu1R49cKdYCmX2RpO4tBKP5qqXGOxouKDRHCO8vqpeC8ii4dftP5QjqiXafB8VqjuSdcLHAiOy(upnLbfpuyiLiZvt9cR33gG0Z(YHKpscwuVI3lEr3lSE92RHj5Ii(XEH17PnL5Qjgi6Ldfz3AihkFvV(GI5aY1K8Tbi9ki4Gh0dbh4bbFOyknxnbcjgOyJ)fkHIv3mudbfZN6PPmO4HcdPezUAQxy9(2aKE2xoK8rsWI6v8EXl6EH1R3EnmjxeXp2lSEpTPmxnXarVCOi7wd5q5R61humhqUMKVnaPxbbh8GEi44XqWhkMsZvtGqIbk24FHsOy1tATnYG2gckMp1ttzqXdfgsjYC1uVW69Tbi9SVCi5JKGf1R49INh3lSE92RHj5Ii(XEH17PnL5Qjgi6Ldfz3AihkFvV(GI5aY1K8Tbi9ki4Gh0dbhCle8HIP0C1eiKyGI5t90uguSHj5Ii(rOyJ)fkHIdOHtsuqM2Fhc6HGJhac(qXuAUAcesmqX8PEAkdk29gcmUjRKZUyqXg)lucfp2jLORsggkbaaHEi4ePqWhkMsZvtGqIbkMp1ttzqXE71BVU3qGrCDHPiPcPTHnKJvPQxX7fp87vqOx3BiWiUUWuKuFtByd5yvQ6v8EXd)E91lSE5iKge5pzCtwjNnKJvPQxX7fx43lSE92R7neyyt5GgWY0sB4wwCj2vRSHDA6l1RN9gThHFVcc9ItVZnPaAasmSPCqdyzAPnCllUe7Qv2WOi7wyyeyV(61xVcc96Edbg2uoObSmT0gULfxID1kByNM(s9k(HEJg3IFVcc9YriniYFY4MSsoBideWEH1R3En1pMwIH8ttVI3BKIFVcc9EAtzUAIvkPHOE9bfB8Vqjum5GH8tJ0fLGqpeCWdFi4dftP5QjqiXafZN6PPmOyC6fCUfilrsoOQxy9EAtzUAIXbLCucwFHYEH1R3En1pMwIH8ttVI3BKIFVW61BVU3qGDSsWHaLKdgYpnou(skPbybae7I1RGqV40lhDsPLp7iGtzzV(6vqOxo6KslFwwaf9YGr9ki07PnL5QjwPKgI6vqOx3BiWC1ieO(QE2fRxy96EdbMRgHa1x1ZgYXQu1RN9gn(9grVE71BVrAVaOENBsb0aKyyt5GgWY0sB4wwCj2vRSHrr2TWWiWE91Be96TxokbV1ZWgIxksA6cy6q5Z(YHKNM(s96RxF96Rxy9ItVU3qGXnzLC2fRxy96TxC6LJoP0YNLfqrVmyuVcc9YriniYFY4O8eDKKVisQWQPEf7I1RGqVv(0GH02tGYqbu0lhYXQu1RN9YriniYFY4O8eDKKVisQWQPEfBihRsvVr0Rh3RGqVv(0GH02tGYqbu0lhYXQu1Rh2lEEa871ZEJg)EJOxV9Yrj4TEg2q8srstxathkF2xoK800xQxF96dk24FHsOyoPj1xMwA6cy6q5d9qWbp8GGpumLMRMaHedumFQNMYGIXPxW5wGSej5GQEH17PnL5QjghuYrjy9fk7fwVE71u)yAjgYpn9kEVrk(9cRxV96Edb2Xkbhcusoyi)04q5lPKgGfaqSlwVcc9ItVC0jLw(SJaoLL96RxbHE5OtkT8zzbu0ldg1RGqVN2uMRMyLsAiQxbHEDVHaZvJqG6R6zxSEH1R7neyUAecuFvpBihRsvVE2lUWV3i61BVE7ns7fa17CtkGgGedBkh0awMwAd3YIlXUALnmkYUfggb2RVEJOxV9Yrj4TEg2q8srstxathkF2xoK800xQxF96RxF9cRxC619gcmUjRKZUy9cRxV9ItVC0jLw(SSak6LbJ6vqOxocPbr(tghLNOJK8frsfwn1RyxSEfe6TYNgmK2EcugkGIE5qowLQE9SxocPbr(tghLNOJK8frsfwn1Ryd5yvQ6nIE94Efe6TYNgmK2EcugkGIE5qowLQE9WEXZdGFVE2lUWV3i61BVCucERNHneVuK00fW0HYN9Ldjpn9L61xV(GIn(xOekUsUnP9fkHEi4Gx0qWhkMsZvtGqIbkgHbfROhk24FHsO4tBkZvtqXNM(sqX40lhH0Gi)jJBYk5SHmqa7vqOxC690MYC1eJJYt0rscskatEVW6LJoP0YNLfqrVmyuVcc9co3cKLijhubfFAJmnhckwzNKmGgj3KvYHEi4GhUGGpumLMRMaHedumFQNMYGIjUUWueRsPLa2lSEnmjxeXp2lSEDVHadBkh0awMwAd3YIlXUALnSttFPE9S3O9i87fwVE7fe9md0W(6KKk)24ibnhdiX(IFSsG9ki0lo9YrNuA5ZsIpinAa71xVW690MYC1etzNKmGgj3KvYHIn(xOekoChaLOGK03KGEi4GNhbbFOyknxnbcjgOy(upnLbf7EdbgkPxKsIrdNW(cLSlwVW619gcm1BtW0A2qHHuImxnbfB8VqjuS6TjyAn0dbh8Ghe8HIP0C1eiKyGIn(xOekMBjN0s3BiafZN6PPmOy3BiWuVnA0aYgYXQu1RN9cVEH1R3EDVHaJ46ctrsfsBdBihRsvVI3l86vqOx3BiWiUUWuKuFtByd5yvQ6v8EHxV(6fwVM6htlXq(PPxX7nsXhk29gcY0CiOy1BJgnGqpeCWZJHGpumLMRMaHedumFQNMYGIFtt5ZupP12ibNk8mknxnb2lSEv0)vcuXuinscov47fwVU3qGPEBcMwZar(tOyJ)fkHIvVnbtRHEi4GhUfc(qXuAUAcesmqX8PEAkdkMJoP0YNLfqrVmyuVW690MYC1eJJYt0rscskatEVW6LJqAqK)KXr5j6ijFrKuHvt9k2qowLQE9Sx41lSEXPxW5wGSej5GkOyJ)fkHIvVnQ7aKGEi4GNhac(qXuAUAcesmqX8PEAkdk(nnLpt9KwBJeCQWZO0C1eyVW6fNEFtt5ZuVnA0aYO0C1eyVW619gcm1BtW0A2qHHuImxn1lSE92R7neyexxyksQVPnSHCSkv9kEVECVW6L46ctrSkL6BAtVW619gcmSPCqdyzAPnCllUe7Qv2Won9L61ZEJgE43RGqVU3qGHnLdAaltlTHBzXLyxTYg2PPVuVIFO3OHh(9cRxt9JPLyi)00R49gP43RGqVGONzGg2xNKu53ghjO5yaj2qowLQEfVxpqVcc9A8VqjZanSVojPYVnosqZXasSkLbDbu03RVEH1lo9YriniYFY4MSsoBideqOyJ)fkHIvVnbtRHEi4GxKcbFOyknxnbcjgOy(upnLbf7EdbgkPxKsY1KnYZsvOKDX6vqOx3BiWowj4qGsYbd5NghkFjL0aSaaIDX6vqOx3BiW4MSso7I1lSE92R7neyJDsj6QKHHsaaq2qowLQE9SxGCqMJj2Ebq9YPs3R3En1pMwIH8ttVWTxCHFV(6fwVU3qGn2jLORsggkbaazxSEfe6fNEDVHaBStkrxLmmucaaYUy9cRxC6LJqAqK)Kn2jLORsggkbaazdzGa2RGqV40lhDsPLp7KYxeGtV(6vqOxt9JPLyi)00R49gP43lSEjUUWueRsPLacfB8VqjuS6TrDhGe0dbNOXhc(qXuAUAcesmqX8PEAkdk(nnLpt92OrdiJsZvtG9cRxV96EdbM6TrJgq2fRxbHEn1pMwIH8ttVI3BKIFV(6fwVU3qGPEB0ObKPEJFSxp7fx9cRxV96EdbgX1fMIKkK2g2fRxbHEDVHaJ46ctrs9nTHDX61xVW619gcmSPCqdyzAPnCllUe7Qv2Won9L61ZEJg3IFVW61BVCesdI8NmUjRKZgYXQu1R49Ih(9ki0lo9EAtzUAIXr5j6ijbjfGjVxy9YrNuA5ZYcOOxgmQxFqXg)lucfREBu3bib9qWjA8GGpumLMRMaHedumFQNMYGI92R7neyyt5GgWY0sB4wwCj2vRSHDA6l1RN9gnUf)Efe619gcmSPCqdyzAPnCllUe7Qv2Won9L61ZEJgE43lSEFtt5ZupP12ibNk8mknxnb2RVEH1R7neyexxyksQqAByd5yvQ6v8EXT9cRxIRlmfXQuQqAB6fwV40R7neyOKErkjgnCc7luYUy9cRxC69nnLpt92OrdiJsZvtG9cRxocPbr(tg3KvYzd5yvQ6v8EXT9cRxV9YriniYFYihmKFAKUOeKnKJvPQxX7f32RGqV40lhDsPLp7iGtzzV(GIn(xOekw92OUdqc6HGt0rdbFOyknxnbcjgOy(upnLbf7Tx3BiWiUUWuKuFtByxSEfe61BVCr2aKu9EO3O7fwVdXfzdqs(Ld1RN9cVE91RGqVCr2aKu9EOxC1RVEH1RHj5Ii(XEH17PnL5QjMYojzansUjRKdfB8VqjuCs(Loiuc9qWjACbbFOyknxnbcjgOy(upnLbf7Tx3BiWiUUWuKuFtByxSEH1lo9YrNuA5Zoc4uw2RGqVE719gcSJvcoeOKCWq(PXHYxsjnalaGyxSEH1lhDsPLp7iGtzzV(6vqOxV9Yfzdqs17HEJUxy9oexKnaj5xouVE2l861xVcc9Yfzdqs17HEXvVcc96Edbg3KvYzxSE91lSEnmjxeXp2lSEpTPmxnXu2jjdOrYnzLCOyJ)fkHIfz6G0bHsOhcor7rqWhkMsZvtGqIbkMp1ttzqXE719gcmIRlmfj130g2fRxy9ItVC0jLw(SJaoLL9ki0R3EDVHa7yLGdbkjhmKFACO8LusdWcai2fRxy9YrNuA5Zoc4uw2RVEfe61BVCr2aKu9EO3O7fwVdXfzdqs(Ld1RN9cVE91RGqVCr2aKu9EOxC1RGqVU3qGXnzLC2fRxF9cRxdtYfr8J9cR3tBkZvtmLDsYaAKCtwjhk24FHsO4WvRLoiuc9qWjA4bbFOyJ)fkHI9BZuOrIcssFtckMsZvtGqIb6HGt0Eme8HIP0C1eiKyGI5t90ugumX1fMIyvk130MEfe6L46ctrmfsBJmjX(9ki0lX1fMIywcOmjX(9ki0R7ney(Tzk0irbjPVjXUy9cRx3BiWiUUWuKuFtByxSEfe61BVU3qGXnzLC2qowLQE9SxJ)fkz(h7fXiXs87tYVCOEH1R7neyCtwjNDX61huSX)cLqXQ3Mqne0dbNOXTqWhk24FHsOy)J9IGIP0C1eiKyGEi4eThac(qXuAUAcesmqXg)lucfp3uA8VqPuxQhkwxQxMMdbfhmT(fnxOh6HIDr2dbFi4Ghe8HIP0C1eiKyGI5t90uguS7neyCtwjNDXGIn(xOekEStkrxLmmucaac9qWjAi4dftP5QjqiXafJWGIv0dfB8Vqju8PnL5QjO4ttFjOyC619gcmxtBjNKOG00A5lQsGkzA)Di2fRxy9ItVU3qG5AAl5KefKMwlFrvcujTHBjXUyqXN2itZHGI5t9j6VyqpeCWfe8HIP0C1eiKyGIn(xOek2anSVojPYVnoqX8PEAkdk29gcmxtBjNKOG00A5lQsGkzA)DiM6n(XE9SxpQxy96EdbMRPTKtsuqAAT8fvjqL0gULet9g)yVE2Rh1lSE92lo9cIEMbAyFDssLFBCKGMJbKyFXpwjWEH1lo9A8VqjZanSVojPYVnosqZXasSkLbDbu03lSE92lo9cIEMbAyFDssLFBCKIitZ(IFSsG9ki0li6zgOH91jjv(TXrkImnBihRsvVI3lU61xVcc9cIEMbAyFDssLFBCKGMJbKyQ34h71ZEXvVW6fe9md0W(6KKk)24ibnhdiXgYXQu1RN9cVEH1li6zgOH91jjv(TXrcAogqI9f)yLa71humhqUMKVnaPxbbh8GEi44rqWhkMsZvtGqIbkMp1ttzqXE790MYC1eJJYt0rscskatEVW6fNE5iKge5pzCtwjNnKbcyVcc96Edbg3KvYzxSE91lSE92R7neyUM2sojrbPP1YxuLavY0(7qm1B8J9EOx41RGqVU3qG5AAl5KefKMwlFrvcujTHBjXuVXp27HEHxV(6vqO3qbu0lhYXQu1RN9Ih(qXg)lucfZr5j6ijFrKuHvt9kOhcoWdc(qXuAUAcesmqXg)lucfZTKtAP7neGI5t90uguS3EDVHaZ10wYjjkinTw(IQeOsM2FhInKJvPQxX71JyWRxbHEDVHaZ10wYjjkinTw(IQeOsAd3sInKJvPQxX71JyWRxF9cRxt9JPLyi)00R4h6nsXVxy96TxocPbr(tg3KvYzd5yvQ6v8EXT9ki0R3E5iKge5pzKdgYpnsxucYgYXQu1R49IB7fwV40R7neyhReCiqj5GH8tJdLVKsAawaaXUy9cRxo6KslF2raNYYE91RpOy3BiitZHGIvVnA0ac9qWXJHGpumLMRMaHedumFQNMYGIXP3tBkZvtm(uFI(lwVW61BVC0jLw(SSak6LbJ6vqOxocPbr(tg3KvYzd5yvQ6v8EXT9ki0lo9EAtzUAIXbLCucwFHYEH1lo9YrNuA5Zoc4uw2RGqVE7LJqAqK)Kroyi)0iDrjiBihRsvVI3lUTxy9ItVU3qGDSsWHaLKdgYpnou(skPbybae7I1lSE5OtkT8zhbCkl71xV(GIn(xOekw92OUdqc6HGdUfc(qXuAUAcesmqX8PEAkdk2BVCesdI8Nmokprhj5lIKkSAQxXgYXQu1RN9cVEH1lo9co3cKLijhu1lSE927PnL5QjghLNOJKeKuaM8Efe6LJqAqK)KXnzLC2qowLQE9Sx41RVE91lSEn1pMwIH8ttVI3RhHFVW6LJoP0YNLfqrVmyuVW6fNEbNBbYsKKdQGIn(xOekw92OUdqc6HGJhac(qXuAUAcesmqXimOyf9qXg)lucfFAtzUAck(00xck2BVU3qGXnzLC2qowLQEfVx41lSE92R7neyJDsj6QKHHsaaq2qowLQEfVx41RGqV40R7neyJDsj6QKHHsaaq2fRxF9ki0lo96Edbg3KvYzxSEfe61u)yAjgYpn96zV4c)E91lSE92lo96Edb2Xkbhcusoyi)04q5lPKgGfaqSlwVcc9AQFmTed5NME9SxCHFV(6fwVE719gcmIRlmfjviTnSHCSkv9kEVa5GmhtS9ki0R7neyexxyksQVPnSHCSkv9kEVa5GmhtS96dk(0gzAoeumi6Ldfz3AihkFf0dbNifc(qXuAUAcesmqXg)lucfRUzOgckMp1ttzqXdfgsjYC1uVW69Tbi9SVCi5JKGf1R49INh3lSEnmjxeXp2lSEpTPmxnXarVCOi7wd5q5RGI5aY1K8Tbi9ki4Gh0dbh8Whc(qXuAUAcesmqXg)lucf7GqzOgckMp1ttzqXdfgsjYC1uVW69Tbi9SVCi5JKGf1R49IhUyWRxy9AysUiIFSxy9EAtzUAIbIE5qr2TgYHYxbfZbKRj5Bdq6vqWbpOhco4Hhe8HIP0C1eiKyGIn(xOekw9KwBJmOTHGI5t90ugu8qHHuImxn1lSEFBasp7lhs(ijyr9kEV45X9grVd5yvQ6fwVgMKlI4h7fwVN2uMRMyGOxouKDRHCO8vqXCa5As(2aKEfeCWd6HGdErdbFOyknxnbcjgOy(upnLbfBysUiIFek24FHsO4aA4KefKP93HGEi4GhUGGpumLMRMaHedumFQNMYGI92lX1fMIyvkTeWEfe6L46ctrmfsBJSsjE9ki0lX1fMIy6BAJSsjE96Rxy96TxC6LJoP0YNLfqrVmyuVcc9co3cKLijhu1RGqVE71u)yAjgYpn96zVrk86fwVE790MYC1eJp1NO)I1RGqVM6htlXq(PPxp7fx43RGqVN2uMRMyLsAiQxF9cRxV9EAtzUAIXr5j6ijbjfGjVxy9ItVCesdI8Nmokprhj5lIKkSAQxXUy9ki0lo9EAtzUAIXr5j6ijbjfGjVxy9ItVCesdI8NmUjRKZUy96RxF96Rxy96TxocPbr(tg3KvYzd5yvQ6v8EXf(9ki0l4ClqwIKCqvVcc9AQFmTed5NMEfV3if)EH1lhH0Gi)jJBYk5SlwVW61BVCesdI8NmYbd5NgPlkbzd5yvQ61ZEn(xOKPEBc1qmsSe)(K8lhQxbHEXPxo6KslF2raNYYE91RGqVv(0GH02tGYqbu0lhYXQu1RN9Ih(96Rxy96Txq0Zmqd7RtsQ8BJJe0CmGeBihRsvVI3Rh1RGqV40lhDsPLplj(G0ObSxFqXg)lucfhUdGsuqs6BsqpeCWZJGGpumLMRMaHedumFQNMYGI92lX1fMIy6BAJmjX(9ki0lX1fMIykK2gzsI97vqOxIRlmfXSeqzsI97vqOx3BiWCnTLCsIcstRLVOkbQKP93Hyd5yvQ6v8E9ig86vqOx3BiWCnTLCsIcstRLVOkbQK2WTKyd5yvQ6v8E9ig86vqOxt9JPLyi)00R49gP43lSE5iKge5pzCtwjNnKbcyVW6fNEbNBbYsKKdQ61xVW61BVCesdI8NmUjRKZgYXQu1R49Il87vqOxocPbr(tg3KvYzdzGa2RVEfe6TYNgmK2EcugkGIE5qowLQE9Sx8Whk24FHsOyYbd5NgPlkbHEi4Gh8GGpumLMRMaHedumFQNMYGIXPxW5wGSej5GQEH17PnL5QjghuYrjy9fk7fwVE71u)yAjgYpn9kEVrk(9cRxV96Edb2Xkbhcusoyi)04q5lPKgGfaqSlwVcc9ItVC0jLw(SJaoLL96RxbHE5OtkT8zzbu0ldg1RGqVU3qG5Qriq9v9SlwVW619gcmxncbQVQNnKJvPQxp7nA87nIE92lhLG36zydXlfjnDbmDO8zF5qYttFPE91RVEH1R3EpTPmxnX4O8eDKKGKcWK3RGqVCesdI8Nmokprhj5lIKkSAQxXgYabSxF9ki0BLpnyiT9eOmuaf9YHCSkv96zVrJFVr0R3E5Oe8wpdBiEPiPPlGPdLp7lhsEA6l1RpOyJ)fkHI5KMuFzAPPlGPdLp0dbh88yi4dftP5QjqiXafZN6PPmOyC6fCUfilrsoOQxy9EAtzUAIXbLCucwFHYEH1R3En1pMwIH8ttVI3BKIFVW61BVU3qGDSsWHaLKdgYpnou(skPbybae7I1RGqV40lhDsPLp7iGtzzV(6vqOxo6KslFwwaf9YGr9ki0R7neyUAecuFvp7I1lSEDVHaZvJqG6R6zd5yvQ61ZEXf(9grVE7LJsWB9mSH4LIKMUaMou(SVCi5PPVuV(61xVW61BVN2uMRMyCuEIossqsbyY7vqOxocPbr(tghLNOJK8frsfwn1RydzGa2RVEfe6TYNgmK2EcugkGIE5qowLQE9SxCHFVr0R3E5Oe8wpdBiEPiPPlGPdLp7lhsEA6l1RpOyJ)fkHIRKBtAFHsOhco4HBHGpumLMRMaHedumcdkwrpuSX)cLqXN2uMRMGIpn9LGIjUUWueRsP(M20laQxpqVWTxJ)fkzQ3MqneJelXVpj)YH6nIEXPxIRlmfXQuQVPn9cG61J7fU9A8VqjZ)yVigjwIFFs(Ld1Be9Ipl6EHBVkmsRLIm1tqXN2itZHGInfwKeAIjo0dbh88aqWhkMsZvtGqIbkMp1ttzqXE7TYNgmK2EcugkGIE5qowLQE9SxpQxbHE92R7neyJDsj6QKHHsaaq2qowLQE9SxGCqMJj2Ebq9YPs3R3En1pMwIH8ttVWTxCHFV(6fwVU3qGn2jLORsggkbaazxSE91RVEfe61BVM6htlXq(PP3i690MYC1eZuyrsOjM49cG619gcmIRlmfjviTnSHCSkv9grVGONfUdGsuqs6BsSV4hvYHCSk7fa1B0m41R49Ix043RGqVM6htlXq(PP3i690MYC1eZuyrsOjM49cG619gcmIRlmfj130g2qowLQEJOxq0Zc3bqjkij9nj2x8Jk5qowL9cG6nAg86v8EXlA871xVW6L46ctrSkLwcyVW61BVE7fNE5iKge5pzCtwjNDX6vqOxo6KslF2raNYYEH1lo9YriniYFYihmKFAKUOeKDX61xVcc9YrNuA5ZYcOOxgmQxF9cRxV9ItVC0jLw(StkFrao9ki0lo96Edbg3KvYzxSEfe61u)yAjgYpn9kEVrk(96RxbHEDVHaJBYk5SHCSkv9kEVEGEH1lo96Edb2yNuIUkzyOeaaKDXGIn(xOekw92OUdqc6HGdErke8HIP0C1eiKyGI5t90uguS3EDVHaJ46ctrs9nTHDX6vqOxV9Yfzdqs17HEJUxy9oexKnaj5xouVE2l861xVcc9Yfzdqs17HEXvV(6fwVgMKlI4hHIn(xOekoj)shekHEi4en(qWhkMsZvtGqIbkMp1ttzqXE719gcmIRlmfj130g2fRxbHE92lxKnajvVh6n6EH17qCr2aKKF5q96zVWRxF9ki0lxKnajvVh6fx96Rxy9AysUiIFek24FHsOyrMoiDqOe6HGt04bbFOyknxnbcjgOy(upnLbf7Tx3BiWiUUWuKuFtByxSEfe61BVCr2aKu9EO3O7fwVdXfzdqs(Ld1RN9cVE91RGqVCr2aKu9EOxC1RVEH1RHj5Ii(rOyJ)fkHIdxTw6Gqj0dbNOJgc(qXg)lucf73MPqJefKK(MeumLMRMaHed0dbNOXfe8HIP0C1eiKyGI5t90ugumX1fMIyvk130MEfe6L46ctrmfsBJmjX(9ki0lX1fMIywcOmjX(9ki0R7ney(Tzk0irbjPVjXUy9cRx3BiWiUUWuKuFtByxSEfe61BVU3qGXnzLC2qowLQE9SxJ)fkz(h7fXiXs87tYVCOEH1R7neyCtwjNDX61huSX)cLqXQ3Mqne0dbNO9ii4dfB8VqjuS)XErqXuAUAcesmqpeCIgEqWhkMsZvtGqIbk24FHsO45MsJ)fkL6s9qX6s9Y0CiO4GP1VO5c9qp0dfFsJQqjeCIg)OXhVOJg3cf73MSsGkOyCxEWEqHdUB4ejns0BVWxe1B5GHMV3aA6f3doK54wjin4(EhkYU1qG9QqouV29ro2tG9YfzjqsX6OaWvs9gDKO3ihLN08eyVXLtK3RcW8nX2Rh27J6faFTEbRZsvOSxegn2JME9cxF96fpX6J1rbGRK6fp8Ie9g5O8KMNa7nUCI8EvaMVj2E9qpS3h1la(A96GaV6RQxegn2JME96H(61lEI1hRJcaxj1lErhj6nYr5jnpb2BC5e59QamFtS96HEyVpQxa8161bbE1xvVimAShn961d91Rx8eRpwhfaUsQx8GxKO3ihLN08eyVXLtK3RcW8nX2Rh27J6faFTEbRZsvOSxegn2JME9cxF96fpX6J1r1rH7Yd2dkCWDdNiPrIE7f(IOElhm089gqtV4Eqkyx9J77DOi7wdb2Rc5q9A3h5ypb2lxKLajfRJcaxj1Rhhj6nYr5jnpb2BC5e59QamFtS96H9(OEbWxRxW6Sufk7fHrJ9OPxVW1xVEJwS(yDua4kPEXdVirVrokpP5jWEX9ZnPaAasmpi4(EFuV4(5MuanajMhegLMRMaX996nAX6J1r1rH7Yd2dkCWDdNiPrIE7f(IOElhm089gqtV4ESH4ihx7X99ouKDRHa7vHCOET7JCSNa7LlYsGKI1rbGRK6fErIEJCuEsZtG9I7NBsb0aKyEqW99(OEX9ZnPaAasmpimknxnbI771lEI1hRJcaxj1Rhhj6nYr5jnpb2lUFUjfqdqI5bb337J6f3p3KcObiX8GWO0C1eiUVxV4jwFSoQokCxEWEqHdUB4ejns0BVWxe1B5GHMV3aA6f3Bic337qr2TgcSxfYH61UpYXEcSxUilbskwhfaUsQxCfj6nYr5jnpb2lUFUjfqdqI5bb337J6f3p3KcObiX8GWO0C1eiUVxV4jwFSokaCLuVWls0BKJYtAEcS34YjY7vby(My71d9WEFuVa4R1Rdc8QVQEry0ypA61Rh6RxV4jwFSokaCLuV42irVrokpP5jWEJlNiVxfG5BITxpS3h1la(A9cwNLQqzVimAShn96fU(61lEI1hRJcaxj1lE4hj6nYr5jnpb2BC5e59QamFtS96H9(OEbWxRxW6Sufk7fHrJ9OPxVW1xVEXtS(yDua4kPEXZJIe9g5O8KMNa7nUCI8EvaMVj2E9qpS3h1la(A96GaV6RQxegn2JME96H(61lEI1hRJcaxj1lErAKO3ihLN08eyVXLtK3RcW8nX2Rh27J6faFTEbRZsvOSxegn2JME9cxF96fpX6J1rbGRK6nA8Ie9g5O8KMNa7nUCI8EvaMVj2E9WEFuVa4R1lyDwQcL9IWOXE00Rx46RxV4jwFSokaCLuVr7XrIEJCuEsZtG9gxorEVkaZ3eBVEyVpQxa816fSolvHYEry0ypA61lC91R3OfRpwhvhfUlpypOWb3nCIKgj6Tx4lI6TCWqZ3Ban9I7vpUV3HISBneyVkKd1RDFKJ9eyVCrwcKuSokaCLuV4HFKO3ihLN08eyVXLtK3RcW8nX2Rh6H9(OEbWxRxhe4vFv9IWOXE00Rxp0xVEXtS(yDua4kPEXdVirVrokpP5jWEJlNiVxfG5BITxp0d79r9cGVwVoiWR(Q6fHrJ9OPxVEOVE9INy9X6OaWvs9IxKgj6nYr5jnpb2BC5e59QamFtS96H9(OEbWxRxW6Sufk7fHrJ9OPxVW1xVEXtS(yDuDu4U8G9GchC3WjsAKO3EHViQ3YbdnFVb00lU3fzpUV3HISBneyVkKd1RDFKJ9eyVCrwcKuSokaCLuV4HBJe9g5O8KMNa7nUCI8EvaMVj2E9WEFuVa4R1lyDwQcL9IWOXE00Rx46RxV4sS(yDua4kPEXZdej6nYr5jnpb2BC5e59QamFtS96H9(OEbWxRxW6Sufk7fHrJ9OPxVW1xVEXtS(yDuDu4UDWqZtG9IB714FHYE1L6vSokOySbfknbfJ70RymTLCQ3i5MBb2rH70BuwETbWEJgG9gn(rJxhvhfUtVrUilbsQirhfUtV4ME9GbbjWEJrAB6vmK5W6OWD6f30BKlYsGeyVVnaPxwHE5MIu9(OE5aY1K8Tbi9kwhfUtV4ME9GsoOtcS3BMeNukBaS3tBkZvtQE9wmIbWEXg6uQEBu3bi1lUr8EXg6KPEBu3bi5J1rH70lUPxp4tub2l2qCt9vcSxCxJ9I6Tc9wpUx17lI61)GsG9gjdxxykI1rH70lUP3izTJuVrokprhPEFruVXy1uVQxRxD9VM61bnuVbnj2Yvt96Tc9ci62RidmX9FVIQV367vvox9BjHUknG96VEr9kMi59GHFVr0BKtAs9LP71dwxathkFa2B94EWEvhlmFSoQokJ)fkvmSH4ihx7pCSsWHaLkSAQx1rz8VqPIHneh54AFehGRdcLhRugqJthLX)cLkg2qCKJR9rCaU(h7fbqDLKKdEap8byfo4L46ctrm9nTrMKyFbbIRlmfXQuQVPnccexxykIvP0f9IeeiUUWueZsaLjj23xhLX)cLkg2qCKJR9rCaU(h7fbWkCWlX1fMIy6BAJmjX(ccexxykIvPuFtBeeiUUWueRsPl6fjiqCDHPiMLaktsSVpyydDYWJ5FSxemCWg6KfnZ)yVOokJ)fkvmSH4ihx7J4aCvVnHAiawHd4m3KcObiXCnTLCsIcstRLVOkbQeeWHJoP0YNLfqrVmyKGaokmsRLVnaPxXuVnbtRpGNGaoVPP8zP93HusxtBjNyuAUAcSJY4FHsfdBioYX1(ioax1BJ6oajawHdZnPaAasmxtBjNKOG00A5lQsGkyC0jLw(SSak6LbJGPWiTw(2aKEft92emT(aEDuDu4o9gjJyj(9jWEPtAaS3VCOEFruVg)rtVLQx70kT5QjwhLX)cLQdkK2gPlzoDug)luQoCAtzUAcGP5qhkL0qeapn9LoOWiTw(2aKEft92emTwC8G5fN30u(m1BJgnGmknxnbki8MMYNPEsRTrcov4zuAUAc0NGGcJ0A5Bdq6vm1BtW0AXJUJY4FHsvehG7PnL5QjaMMdDOusUMStcGNM(shuyKwlFBasVIPEBc1qIJxhLX)cLQioaxxAu0CSsGaSch8IdhDsPLpllGIEzWibbC4iKge5pzCuEIosYxejvy1uVIDX8bZ9gcmUjRKZUyDug)luQI4aCXqFHsawHdU3qGXnzLC2fRJY4FHsvehG7PnL5QjaMMdDGJYt0rscskatoapn9Loe0i041BLpnyiT9eOmuaf9YHCSkv4MOXh3WriniYFY4O8eDKKVisQWQPEfBihRsLppeVOX3N4bncnE9w5tdgsBpbkdfqrVCihRsfUjA4HB8Ih(aO30u(Sk52K2xOKrP5QjqF4gVCucERNHneVuK00fW0HYN9Ldjpn9L8HB4iKge5pzCtwjNnKJvPYNhINhaFFccCesdI8NmUjRKZgYXQujELpnyiT9eOmuaf9YHCSkvccCesdI8Nmokprhj5lIKkSAQxXgYXQujELpnyiT9eOmuaf9YHCSkvcc4WrNuA5ZYcOOxgmQJY4FHsvehG7PnL5QjaMMdDGdk5OeS(cLa800x6GxCOi7wyyeiJCWaCitlrdyAjNee4iKge5pzKdgGdzAjAatl5eBihRsLN45X4ddhocPbr(tg5Gb4qMwIgW0soXgYab0NGahDsPLp7iGtzzhLX)cLQioa3RIK1toamnh6a5Gb4qMwIgW0sobWkCGJqAqK)KXnzLC2qowLkpJgFyN2uMRMyCuEIossqsbyYfe4iKge5pzCuEIosYxejvy1uVInKJvPYZOXVJY4FHsvehG7vrY6jhaMMdDqHUAn9FLaLZ1fqawHdCesdI8NmUjRKZgYXQu5Phd70MYC1eJJYt0rscskatUGahH0Gi)jJJYt0rs(IiPcRM6vSHCSkvE6XDug)luQI4aCVkswp5aW0COdvQ4Z9nxnjJSRL)1rcsNfNayfo4Edbg3KvYzxSokCNEn(xOufXb4EvKSEYrbqLg9Qd)u5r6XdGv4ao)u5r6z4Xezkj2G4mlbeMxC(PYJ0ZIMjYusSbXzwcOGao)u5r6zrZgYabuYriniYF6tqW9gcmUjRKZUyccCesdI8NmUjRKZgYXQuHBWdFX)PYJ0ZWJXriniYFYaVJ9fkHHdhDsPLp7iGtzPGahDsPLpllGIEzWiyN2uMRMyCuEIossqsbyYHXriniYFY4O8eDKKVisQWQPEf7Iji4Edb2Xkbhcusoyi)04q5lPKgGfaqSlMGqOak6Ld5yvQ8mA87OWD614FHsvehG7vrY6jhfavA0Ro8tLhPpAawHd48tLhPNfntKPKydIZSeqyEX5NkpspdpMitjXgeNzjGcc48tLhPNHhBideqjhH0Gi)PpbHFQ8i9m8yImLeBqCMLac7NkpsplAMitjXgeNzjGWW5Nkpspdp2qgiGsocPbr(tbb3BiW4MSso7IjiWriniYFY4MSsoBihRsfUbp8f)NkpsplAghH0Gi)jd8o2xOegoC0jLw(SJaoLLccC0jLw(SSak6LbJGDAtzUAIXr5j6ijbjfGjhghH0Gi)jJJYt0rs(IiPcRM6vSlMGG7neyhReCiqj5GH8tJdLVKsAawaaXUyccHcOOxoKJvPYZOXVJY4FHsvehG7vrY6jhfaRWb3BiW4MSso7IjiWrNuA5ZYcOOxgmc2PnL5QjghLNOJKeKuaMCyCesdI8Nmokprhj5lIKkSAQxXUyWWHJqAqK)KXnzLC2fdMxVU3qGrCDHPiP(M2WgYXQujoE4li4EdbgX1fMIKkK2g2qowLkXXdFFWWzUjfqdqI5AAl5KefKMwlFrvcujim3KcObiXCnTLCsIcstRLVOkbQG519gcmxtBjNKOG00A5lQsGkzA)DiM6n(rXXLGG7neyUM2sojrbPP1YxuLavsB4wsm1B8JIJlF(eeCVHa7yLGdbkjhmKFACO8LusdWcai2ftqiuaf9YHCSkvEgn(Dug)luQI4aCNBkn(xOuQl1dW0COdgIaO6NI)hWdGv4WPnL5QjwPKgI6Om(xOufXb4o3uA8VqPuxQhGP5qhahYCCReKgaQ(P4)b8ayfom3KcObiX(YH8JMucoK54wjinmkYUfggb2rz8VqPkIdWDUP04FHsPUupatZHo4IShGQFk(FapawHdZnPaAasmxtBjNKOG00A5lQsGkgfz3cdJa7Om(xOufXb4o3uA8VqPuxQhGP5qhuFhvhLX)cLkMHOdN2uMRMayAo0bWHmhP)sRLbtRLOqaGNM(sh86Edb2xoKF0KsWHmh3kbPHnKJvPYtGCqMJj2iWNHNGG7neyF5q(rtkbhYCCReKg2qowLkpn(xOKPEBc1qmsSe)(K8lhkc8z4bZlX1fMIyvk130gbbIRlmfXuiTnYKe7liqCDHPiMLaktsSVpFWCVHa7lhYpAsj4qMJBLG0WUyWMBsb0aKyF5q(rtkbhYCCReKggfz3cdJa7Om(xOuXmefXb4EAtzUAcGP5qhkGjAiP6TrDhGeapn9Lo4EdbgX1fMIK6BAd7IbZRcJ0A5Bdq6vm1BtOgsCpc2BAkFMcD1suq(IizanK6zuAUAcuqqHrAT8Tbi9kM6TjudjUh7RJY4FHsfZquehGlhLNOJK8frsfwn1Rayfo490MYC1eJJYt0rscskatomC4iKge5pzCtwjNnKbcOGG7neyCtwjNDX8bZRP(X0smKFA8eE4liCAtzUAIvat0qs1BJ6oajFW86EdbgX1fMIK6BAdBihRsL4ESGG7neyexxyksQqAByd5yvQe3J9bZloZnPaAasmxtBjNKOG00A5lQsGkbb3BiWCnTLCsIcstRLVOkbQKP93HyQ34hfhxccU3qG5AAl5KefKMwlFrvcujTHBjXuVXpkoU8jiekGIE5qowLkpXd)okJ)fkvmdrrCaUQBgQHaihqUMKVnaPxDapawHddfgsjYC1eS3gG0Z(YHKpscwK445r4gfgP1Y3gG0RIyihRsfmVexxykIvP0safegYXQu5jqoiZXeRVokJ)fkvmdrrCaUQ3MGP1aSchCVHat92emTMnuyiLiZvtW8QWiTw(2aKEft92emT2tCjiGZCtkGgGe7lhYpAsj4qMJBLG0WOi7wyyeOpyEXzUjfqdqIPbKBJPKbnrFLaLa1LdMIyuKDlmmcuq4lhYd9qpcEI7EdbM6TjyAnBihRsver7dwOak6Ld5yvQehEDug)luQygII4aCvVnbtRbyfom3KcObiX(YH8JMucoK54wjinmkYUfggbctHrAT8Tbi9kM6TjyAT4hWfmV44Edb2xoKF0KsWHmh3kbPHDXG5EdbM6TjyAnBOWqkrMRMee8EAtzUAIboK5i9xATmyATefcW86EdbM6TjyAnBihRsLN4sqqHrAT8Tbi9kM6TjyAT4rd7nnLpt9KwBJeCQWZO0C1eim3BiWuVnbtRzd5yvQ8eE(85RJY4FHsfZquehG7PnL5QjaMMdDq92emTw6hLVmyATefca800x6GP(X0smKFAe3dGpUXlE4dGCVHa7lhYpAsj4qMJBLG0WuVXp6d3419gcm1BtW0A2qowLkaeU8qfgP1srM6jF4gVGONfUdGsuqs6BsSHCSkvai45dM7neyQ3MGP1SlwhLX)cLkMHOioax1BJ6oajawHdN2uMRMyGdzos)LwldMwlrHaStBkZvtm1BtW0APFu(YGP1suiadNtBkZvtScyIgsQEBu3biji419gcmxtBjNKOG00A5lQsGkzA)DiM6n(rXXLGG7neyUM2sojrbPP1YxuLavsB4wsm1B8JIJlFWuyKwlFBasVIPEBcMw7Ph1rz8VqPIzikIdW1anSVojPYVnoaKdixtY3gG0RoGhaRWbC(IFSsGWWX4FHsMbAyFDssLFBCKGMJbKyvkd6cOOxqae9md0W(6KKk)24ibnhdiXuVXp6jUGbIEMbAyFDssLFBCKGMJbKyd5yvQ8exDug)luQygII4aCDqOmudbqoGCnjFBasV6aEaSchgkmKsK5QjyVnaPN9LdjFKeSiX9INhfHxfgP1Y3gG0RyQ3Mqneacpg885ZdvyKwlFBasVkIHCSkvW86LJqAqK)KXnzLC2qgiGWWbCUfilrsoOcM3tBkZvtmokprhjjiPam5ccCesdI8Nmokprhj5lIKkSAQxXgYabuqaho6KslFwwaf9YGr(eeuyKwlFBasVIPEBc1qE6fEaiV4fXBAkF27VsPdcLkgLMRMa95tqWlX1fMIyvkviTnccEjUUWueRsPl6fjiqCDHPiwLs9nTXhmCEtt5ZuORwIcYxejdOHupJsZvtGccU3qGHnLdAaltlTHBzXLyxTYg2PPVK4hIgE47dMxfgP1Y3gG0RyQ3MqnKN4HpaYlEr8MMYN9(Ru6GqPIrP5QjqF(GzQFmTed5NgXHh(4g3BiWuVnbtRzd5yvQaqESpyEXX9gcSJvcoeOKCWq(PXHYxsjnalaGyxmbbIRlmfXQuQqABeeWHJoP0YNDeWPS0hmdtYfr8J(6Om(xOuXmefXb4gqdNKOGmT)oeaRWbdtYfr8JDug)luQygII4aCh7Ks0vjddLaaGaSchCVHaJBYk5SlwhLX)cLkMHOioaxoPj1xMwA6cy6q5dWkCahW5wGSej5GkyN2uMRMyCqjhLG1xOeMx3BiWuVnbtRzxmbbt9JPLyi)0io8W3hmCCVHatH0QV4e7Ibdh3BiW4MSso7IbZloC0jLw(SSak6LbJeeoTPmxnX4O8eDKKGKcWKliWriniYFY4O8eDKKVisQWQPEf7Ijiu5tdgsBpbkdfqrVCihRsLNrJFeE5Oe8wpdBiEPiPPlGPdLp7lhsEA6l5ZxhLX)cLkMHOioa3k52K2xOeGv4aoGZTazjsYbvWoTPmxnX4GsokbRVqjmVU3qGPEBcMwZUyccM6htlXq(PrC4HVpy44EdbMcPvFXj2fdgoU3qGXnzLC2fdMxC4OtkT8zzbu0ldgjiCAtzUAIXr5j6ijbjfGjxqGJqAqK)KXr5j6ijFrKuHvt9k2ftqOYNgmK2EcugkGIE5qowLkp5iKge5pzCuEIosYxejvy1uVInKJvPkcpwqOYNgmK2EcugkGIE5qowLkp0dXZdGVN4c)i8Yrj4TEg2q8srstxathkF2xoK800xYNVokJ)fkvmdrrCaUKdgYpnsxuccWkCOYNgmK2EcugkGIE5qowLkpXdEccEDVHadBkh0awMwAd3YIlXUALnSttFjpJgE4li4Edbg2uoObSmT0gULfxID1kByNM(sIFiA4HVpyU3qGPEBcMwZUyW8YriniYFY4MSsoBihRsL4WdFbbW5wGSej5GkFDug)luQygII4aCvpP12idABiaYbKRj5Bdq6vhWdGv4WqHHuImxnb7lhs(ijyrIJh8GPWiTw(2aKEft92eQH80JGzysUiIFeMx3BiW4MSsoBihRsL44HVGaoU3qGXnzLC2fZxhLX)cLkMHOioa3WDauIcssFtcGv4aX1fMIyvkTeqygMKlI4hH5Edbg2uoObSmT0gULfxID1kByNM(sEgn8WhMxq0Zmqd7RtsQ8BJJe0CmGe7l(XkbkiGdhDsPLplj(G0ObuqqHrAT8Tbi9kXJ2xhLX)cLkMHOioax1BtW0AawHdU3qGHs6fPKy0WjSVqj7IbZR7neyQ3MGP1SHcdPezUAsqWu)yAjgYpnIhP47RJY4FHsfZquehGR6TjyAnaRWbo6KslFwwaf9YGrW8EAtzUAIXr5j6ijbjfGjxqGJqAqK)KXnzLC2ftqW9gcmUjRKZUy(GXriniYFY4O8eDKKVisQWQPEfBihRsLNa5GmhtSaiovAVM6htlXq(PXdHh((G5EdbM6TjyAnBihRsLNEemCaNBbYsKKdQ6Om(xOuXmefXb4QEBu3bibWkCGJoP0YNLfqrVmyemVN2uMRMyCuEIossqsbyYfe4iKge5pzCtwjNDXeeCVHaJBYk5SlMpyCesdI8Nmokprhj5lIKkSAQxXgYXQu5PhdZ9gcm1BtW0A2fdgX1fMIyvkTeqy4CAtzUAIvat0qs1BJ6oajy4ao3cKLijhu1rz8VqPIzikIdWv92OUdqcGv4G7neyOKErkjxt2iplvHs2ftqWloQ3MqneZWKCre)OGGx3BiW4MSsoBihRsLNWdM7neyCtwjNDXee86Edb2yNuIUkzyOeaaKnKJvPYtGCqMJjwaeNkTxt9JPLyi)04H4cFFWCVHaBStkrxLmmucaaYUy(8b70MYC1et92emTw6hLVmyATefcWuyKwlFBasVIPEBcMw7jU8bZloZnPaAasSVCi)OjLGdzoUvcsdJISBHHrGcckmsRLVnaPxXuVnbtR9ex(6Om(xOuXmefXb4MKFPdcLaSch8sCDHPiwLslbeghH0Gi)jJBYk5SHCSkvIdp8fe8YfzdqsDiAydXfzdqs(Ld5j88jiWfzdqsDax(GzysUiIFSJY4FHsfZquehGRithKoiucWkCWlX1fMIyvkTeqyCesdI8NmUjRKZgYXQujo8WxqWlxKnaj1HOHnexKnaj5xoKNWZNGaxKnaj1bC5dMHj5Ii(XokJ)fkvmdrrCaUHRwlDqOeGv4GxIRlmfXQuAjGW4iKge5pzCtwjNnKJvPsC4HVGGxUiBasQdrdBiUiBasYVCipHNpbbUiBasQd4YhmdtYfr8JDug)luQygII4aC9BZuOrIcssFtQJY4FHsfZquehG7PnL5QjaMMdDq92eQHKvkviTna800x6GcJ0A5Bdq6vm1BtOgsCpkIGgHgVoM6Pbq5PPVeacp8X3dJgFFre0i0419gcm1BJ6oajj5GH8tJdLVuH02WuVXp6HEKVokJ)fkvmdrrCaU(h7fbWkCG46ctrm9nTrMKyFbbIRlmfXSeqzsI9HDAtzUAIvkjxt2jji4EdbgX1fMIKkK2g2qowLkpn(xOKPEBc1qmsSe)(K8lhcM7neyexxyksQqAByxmbbIRlmfXQuQqABGHZPnL5QjM6TjudjRuQqABeeCVHaJBYk5SHCSkvEA8Vqjt92eQHyKyj(9j5xoemCoTPmxnXkLKRj7KG5Edbg3KvYzd5yvQ8KelXVpj)YHG5Edbg3KvYzxmbb3BiWg7Ks0vjddLaaGSlgmfgP1srM6jXXN5XW8QWiTw(2aKELNhWLGaoVPP8zk0vlrb5lIKb0qQNrP5QjqFcc4CAtzUAIvkjxt2jbZ9gcmUjRKZgYXQujojwIFFs(Ld1rz8VqPIzikIdWv92eQH6Om(xOuXmefXb4o3uA8VqPuxQhGP5qhcMw)IMBhvhLX)cLkMlY(dJDsj6QKHHsaaqawHdU3qGXnzLC2fRJY4FHsfZfzFehG7PnL5QjaMMdDGp1NO)IbWttFPd44EdbMRPTKtsuqAAT8fvjqLmT)oe7Ibdh3BiWCnTLCsIcstRLVOkbQK2WTKyxSokJ)fkvmxK9rCaUgOH91jjv(TXbGCa5As(2aKE1b8ayfo4EdbMRPTKtsuqAAT8fvjqLmT)oet9g)ONEem3BiWCnTLCsIcstRLVOkbQK2WTKyQ34h90JG5fhq0Zmqd7RtsQ8BJJe0CmGe7l(XkbcdhJ)fkzgOH91jjv(TXrcAogqIvPmOlGIEyEXbe9md0W(6KKk)24ifrMM9f)yLafearpZanSVojPYVnosrKPzd5yvQehx(eearpZanSVojPYVnosqZXasm1B8JEIlyGONzGg2xNKu53ghjO5yaj2qowLkpHhmq0Zmqd7RtsQ8BJJe0CmGe7l(Xkb6RJY4FHsfZfzFehGlhLNOJK8frsfwn1Rayfo490MYC1eJJYt0rscskatomC4iKge5pzCtwjNnKbcOGG7neyCtwjNDX8bZR7neyUM2sojrbPP1YxuLavY0(7qm1B8JhGNGG7neyUM2sojrbPP1YxuLavsB4wsm1B8JhGNpbHqbu0lhYXQu5jE43rz8VqPI5ISpIdWLBjN0s3BiaW0COdQ3gnAabyfo419gcmxtBjNKOG00A5lQsGkzA)Di2qowLkX9ig8eeCVHaZ10wYjjkinTw(IQeOsAd3sInKJvPsCpIbpFWm1pMwIH8tJ4hIu8H5LJqAqK)KXnzLC2qowLkXXTccE5iKge5pzKdgYpnsxucYgYXQujoUfgoU3qGDSsWHaLKdgYpnou(skPbybae7IbJJoP0YNDeWPS0NVokJ)fkvmxK9rCaUQ3g1DasaSchW50MYC1eJp1NO)IbZlhDsPLpllGIEzWibbocPbr(tg3KvYzd5yvQeh3kiGZPnL5QjghuYrjy9fkHHdhDsPLp7iGtzPGGxocPbr(tg5GH8tJ0fLGSHCSkvIJBHHJ7neyhReCiqj5GH8tJdLVKsAawaaXUyW4OtkT8zhbCkl95RJY4FHsfZfzFehGR6TrDhGeaRWbVCesdI8Nmokprhj5lIKkSAQxXgYXQu5j8GHd4ClqwIKCqfmVN2uMRMyCuEIossqsbyYfe4iKge5pzCtwjNnKJvPYt45Zhmt9JPLyi)0iUhHpmo6KslFwwaf9YGrWWbCUfilrsoOQJY4FHsfZfzFehG7PnL5QjaMMdDae9YHISBnKdLVcGNM(sh86Edbg3KvYzd5yvQehEW86Edb2yNuIUkzyOeaaKnKJvPsC4jiGJ7neyJDsj6QKHHsaaq2fZNGaoU3qGXnzLC2ftqWu)yAjgYpnEIl89bZloU3qGDSsWHaLKdgYpnou(skPbybae7IjiyQFmTed5NgpXf((G519gcmIRlmfjviTnSHCSkvIdKdYCmXki4EdbgX1fMIK6BAdBihRsL4a5GmhtS(6Om(xOuXCr2hXb4QUzOgcGCa5As(2aKE1b8ayfomuyiLiZvtWEBasp7lhs(ijyrIJNhdZWKCre)iStBkZvtmq0lhkYU1qou(QokJ)fkvmxK9rCaUoiugQHaihqUMKVnaPxDapawHddfgsjYC1eS3gG0Z(YHKpscwK44Hlg8GzysUiIFe2PnL5Qjgi6Ldfz3AihkFvhLX)cLkMlY(ioax1tATnYG2gcGCa5As(2aKE1b8ayfomuyiLiZvtWEBasp7lhs(ijyrIJNhhXqowLkygMKlI4hHDAtzUAIbIE5qr2TgYHYx1rz8VqPI5ISpIdWnGgojrbzA)DiawHdgMKlI4h7Om(xOuXCr2hXb4gUdGsuqs6BsaSch8sCDHPiwLslbuqG46ctrmfsBJSsjEccexxykIPVPnYkL45dMxC4OtkT8zzbu0ldgjiao3cKLijhuji41u)yAjgYpnEgPWdM3tBkZvtm(uFI(lMGGP(X0smKFA8ex4liCAtzUAIvkPHiFW8EAtzUAIXr5j6ijbjfGjhgoCesdI8Nmokprhj5lIKkSAQxXUycc4CAtzUAIXr5j6ijbjfGjhgoCesdI8NmUjRKZUy(85dMxocPbr(tg3KvYzd5yvQehx4liao3cKLijhujiyQFmTed5NgXJu8HXriniYFY4MSso7IbZlhH0Gi)jJCWq(Pr6Isq2qowLkpn(xOKPEBc1qmsSe)(K8lhsqaho6KslF2raNYsFccv(0GH02tGYqbu0lhYXQu5jE47dMxq0Zmqd7RtsQ8BJJe0CmGeBihRsL4EKGaoC0jLw(SK4dsJgqFDug)luQyUi7J4aCjhmKFAKUOeeGv4GxIRlmfX030gzsI9feiUUWuetH02itsSVGaX1fMIywcOmjX(ccU3qG5AAl5KefKMwlFrvcujt7VdXgYXQujUhXGNGG7neyUM2sojrbPP1YxuLavsB4wsSHCSkvI7rm4jiyQFmTed5NgXJu8HXriniYFY4MSsoBideqy4ao3cKLijhu5dMxocPbr(tg3KvYzd5yvQehx4liWriniYFY4MSsoBideqFccv(0GH02tGYqbu0lhYXQu5jE43rz8VqPI5ISpIdWLtAs9LPLMUaMou(aSchWbCUfilrsoOc2PnL5QjghuYrjy9fkH51u)yAjgYpnIhP4dZR7neyhReCiqj5GH8tJdLVKsAawaaXUycc4WrNuA5Zoc4uw6tqGJoP0YNLfqrVmyKGG7neyUAecuFvp7IbZ9gcmxncbQVQNnKJvPYZOXpcVCucERNHneVuK00fW0HYN9Ldjpn9L85dM3tBkZvtmokprhjjiPam5ccCesdI8Nmokprhj5lIKkSAQxXgYab0NGqLpnyiT9eOmuaf9YHCSkvEgn(r4LJsWB9mSH4LIKMUaMou(SVCi5PPVKVokJ)fkvmxK9rCaUvYTjTVqjaRWbCaNBbYsKKdQGDAtzUAIXbLCucwFHsyEn1pMwIH8tJ4rk(W86Edb2Xkbhcusoyi)04q5lPKgGfaqSlMGaoC0jLw(SJaoLL(ee4OtkT8zzbu0ldgji4EdbMRgHa1x1ZUyWCVHaZvJqG6R6zd5yvQ8ex4hHxokbV1ZWgIxksA6cy6q5Z(YHKNM(s(8bZ7PnL5QjghLNOJKeKuaMCbbocPbr(tghLNOJK8frsfwn1RydzGa6tqOYNgmK2EcugkGIE5qowLkpXf(r4LJsWB9mSH4LIKMUaMou(SVCi5PPVKVokJ)fkvmxK9rCaUN2uMRMayAo0btHfjHMyIdWttFPdexxykIvPuFtBaqEap04FHsM6TjudXiXs87tYVCOiWH46ctrSkL6BAdaYJ9qJ)fkz(h7fXiXs87tYVCOiWNfThQWiTwkYup1rz8VqPI5ISpIdWv92OUdqcGv4G3kFAWqA7jqzOak6Ld5yvQ80Jee86Edb2yNuIUkzyOeaaKnKJvPYtGCqMJjwaeNkTxt9JPLyi)04H4cFFWCVHaBStkrxLmmucaaYUy(8ji41u)yAjgYpnrCAtzUAIzkSij0etCaK7neyexxyksQqAByd5yvQIae9SWDauIcssFtI9f)OsoKJvjakAg8ehVOXxqWu)yAjgYpnrCAtzUAIzkSij0etCaK7neyexxyksQVPnSHCSkvraIEw4oakrbjPVjX(IFujhYXQeafndEIJx047dgX1fMIyvkTeqyE9IdhH0Gi)jJBYk5SlMGahDsPLp7iGtzjmC4iKge5pzKdgYpnsxucYUy(ee4OtkT8zzbu0ldg5dMxC4OtkT8zNu(IaCeeWX9gcmUjRKZUyccM6htlXq(Pr8ifFFccU3qGXnzLC2qowLkX9aWWX9gcSXoPeDvYWqjaai7I1rz8VqPI5ISpIdWnj)shekbyfo419gcmIRlmfj130g2ftqWlxKnaj1HOHnexKnaj5xoKNWZNGaxKnaj1bC5dMHj5Ii(XokJ)fkvmxK9rCaUImDq6GqjaRWbVU3qGrCDHPiP(M2WUyccE5ISbiPoenSH4ISbij)YH8eE(ee4ISbiPoGlFWmmjxeXp2rz8VqPI5ISpIdWnC1APdcLaSch86EdbgX1fMIK6BAd7Iji4LlYgGK6q0WgIlYgGK8lhYt45tqGlYgGK6aU8bZWKCre)yhLX)cLkMlY(ioax)2mfAKOGK03K6Om(xOuXCr2hXb4QEBc1qaSchiUUWueRsP(M2iiqCDHPiMcPTrMKyFbbIRlmfXSeqzsI9feCVHaZVntHgjkij9nj2fdM7neyexxyksQVPnSlMGGx3BiW4MSsoBihRsLNg)luY8p2lIrIL43NKF5qWCVHaJBYk5SlMVokJ)fkvmxK9rCaU(h7f1rz8VqPI5ISpIdWDUP04FHsPUupatZHoemT(fn3oQokJ)fkvmWHmh3kbP5WPnL5QjaMMdDqzbs(i5vrsfgP1a800x6Gx3BiW(YH8JMucoK54wjinSHCSkvIdKdYCmXgb(m8G5L46ctrSkLUOxKGaX1fMIyvkviTnccexxykIPVPnYKe77tqW9gcSVCi)OjLGdzoUvcsdBihRsL4g)luYuVnHAigjwIFFs(Ldfb(m8G5L46ctrSkL6BAJGaX1fMIykK2gzsI9feiUUWueZsaLjj23NpbbCCVHa7lhYpAsj4qMJBLG0WUyDug)luQyGdzoUvcstehGR6TrDhGeaRWbV4CAtzUAIPSajFK8QiPcJ0AbbVU3qGn2jLORsggkbaazd5yvQ8eihK5yIfaXPs71u)yAjgYpnEiUW3hm3BiWg7Ks0vjddLaaGSlMpFccM6htlXq(Pr8if)okJ)fkvmWHmh3kbPjIdWLJYt0rs(IiPcRM6vaSch8EAtzUAIXr5j6ijbjfGjhwLpnyiT9eOmuaf9YHCSkvIJhUWhgoCesdI8NmUjRKZgYabuqW9gcmUjRKZUy(GzQFmTed5Ngp9i8H519gcmIRlmfj130g2qowLkXXdFbb3BiWiUUWuKuH02WgYXQujoE47tqiuaf9YHCSkvEIh(Dug)luQyGdzoUvcstehGRbAyFDssLFBCaihqUMKVnaPxDapawHd4aIEMbAyFDssLFBCKGMJbKyFXpwjqy4y8VqjZanSVojPYVnosqZXasSkLbDbu0dZloGONzGg2xNKu53ghPiY0SV4hReOGai6zgOH91jjv(TXrkImnBihRsL4WZNGai6zgOH91jjv(TXrcAogqIPEJF0tCbde9md0W(6KKk)24ibnhdiXgYXQu5jUGbIEMbAyFDssLFBCKGMJbKyFXpwjWokJ)fkvmWHmh3kbPjIdW1bHYqnea5aY1K8Tbi9Qd4bWkCyOWqkrMRMG92aKE2xoK8rsWIehVOH51R7neyCtwjNnKJvPsC4bZR7neyJDsj6QKHHsaaq2qowLkXHNGaoU3qGn2jLORsggkbaazxmFcc44Edbg3KvYzxmbbt9JPLyi)04jUW3hmV44Edb2Xkbhcusoyi)04q5lPKgGfaqSlMGGP(X0smKFA8ex47dMHj5Ii(rFDug)luQyGdzoUvcstehGR6MHAiaYbKRj5Bdq6vhWdGv4WqHHuImxnb7Tbi9SVCi5JKGfjoErdZRx3BiW4MSsoBihRsL4WdMx3BiWg7Ks0vjddLaaGSHCSkvIdpbbCCVHaBStkrxLmmucaaYUy(eeWX9gcmUjRKZUyccM6htlXq(PXtCHVpyEXX9gcSJvcoeOKCWq(PXHYxsjnalaGyxmbbt9JPLyi)04jUW3hmdtYfr8J(6Om(xOuXahYCCReKMioax1tATnYG2gcGCa5As(2aKE1b8ayfomuyiLiZvtWEBasp7lhs(ijyrIJNhdZRx3BiW4MSsoBihRsL4WdMx3BiWg7Ks0vjddLaaGSHCSkvIdpbbCCVHaBStkrxLmmucaaYUy(eeWX9gcmUjRKZUyccM6htlXq(PXtCHVpyEXX9gcSJvcoeOKCWq(PXHYxsjnalaGyxmbbt9JPLyi)04jUW3hmdtYfr8J(6Om(xOuXahYCCReKMioa3aA4KefKP93HayfoyysUiIFSJY4FHsfdCiZXTsqAI4aCh7Ks0vjddLaaGaSchCVHaJBYk5SlwhLX)cLkg4qMJBLG0eXb4soyi)0iDrjiaRWbVEDVHaJ46ctrsfsBdBihRsL44HVGG7neyexxyksQVPnSHCSkvIJh((GXriniYFY4MSsoBihRsL44cFFccCesdI8NmUjRKZgYabSJY4FHsfdCiZXTsqAI4aC5KMuFzAPPlGPdLpaRWbCaNBbYsKKdQGDAtzUAIXbLCucwFHsyE96Edb2Xkbhcusoyi)04q5lPKgGfaqSlMGaoC0jLw(SJaoLL(ee4OtkT8zzbu0ldgjiCAtzUAIvkPHibb3BiWC1ieO(QE2fdM7neyUAecuFvpBihRsLNrJFeE5Oe8wpdBiEPiPPlGPdLp7lhsEA6l5ZhmCCVHaJBYk5SlgmV4WrNuA5ZYcOOxgmsqGJqAqK)KXr5j6ijFrKuHvt9k2ftqOYNgmK2EcugkGIE5qowLkp5iKge5pzCuEIosYxejvy1uVInKJvPkcpwqOYNgmK2EcugkGIE5qowLkp0dXZdGVNrJFeE5Oe8wpdBiEPiPPlGPdLp7lhsEA6l5ZxhLX)cLkg4qMJBLG0eXb4wj3M0(cLaSchWbCUfilrsoOc2PnL5QjghuYrjy9fkH51R7neyhReCiqj5GH8tJdLVKsAawaaXUycc4WrNuA5Zoc4uw6tqGJoP0YNLfqrVmyKGWPnL5QjwPKgIeeCVHaZvJqG6R6zxmyU3qG5Qriq9v9SHCSkvEIl8JWlhLG36zydXlfjnDbmDO8zF5qYttFjF(GHJ7neyCtwjNDXG5fho6KslFwwaf9YGrccCesdI8Nmokprhj5lIKkSAQxXUyccv(0GH02tGYqbu0lhYXQu5jhH0Gi)jJJYt0rs(IiPcRM6vSHCSkvr4Xccv(0GH02tGYqbu0lhYXQu5HEiEEa89ex4hHxokbV1ZWgIxksA6cy6q5Z(YHKNM(s(81rz8VqPIboK54wjinrCaUN2uMRMayAo0bLDsYaAKCtwjhGNM(shWHJqAqK)KXnzLC2qgiGcc4CAtzUAIXr5j6ijbjfGjhghDsPLpllGIEzWibbW5wGSej5GQokJ)fkvmWHmh3kbPjIdWnChaLOGK03KayfoqCDHPiwLslbeMHj5Ii(ryEbrpZanSVojPYVnosqZXasSV4hReOGaoC0jLw(SK4dsJgqFWoTPmxnXu2jjdOrYnzL8okJ)fkvmWHmh3kbPjIdWv92OUdqcGv4ahDsPLpllGIEzWiyN2uMRMyCuEIossqsbyYHzQFmTed5NgXp4r4dJJqAqK)KXr5j6ijFrKuHvt9k2qowLkpbYbzoMybqCQ0En1pMwIH8tJhIl89bdhW5wGSej5GQokJ)fkvmWHmh3kbPjIdWnj)shekbyfo419gcmIRlmfj130g2ftqWlxKnaj1HOHnexKnaj5xoKNWZNGaxKnaj1bC5dMHj5Ii(ryN2uMRMyk7KKb0i5MSsEhLX)cLkg4qMJBLG0eXb4kY0bPdcLaSch86EdbgX1fMIK6BAd7Ibdho6KslF2raNYsbbVU3qGDSsWHaLKdgYpnou(skPbybae7IbJJoP0YNDeWPS0NGGxUiBasQdrdBiUiBasYVCipHNpbbUiBasQd4sqW9gcmUjRKZUy(GzysUiIFe2PnL5QjMYojzansUjRK3rz8VqPIboK54wjinrCaUHRwlDqOeGv4Gx3BiWiUUWuKuFtByxmy4WrNuA5Zoc4uwki419gcSJvcoeOKCWq(PXHYxsjnalaGyxmyC0jLw(SJaoLL(ee8YfzdqsDiAydXfzdqs(Ld5j88jiWfzdqsDaxccU3qGXnzLC2fZhmdtYfr8JWoTPmxnXu2jjdOrYnzL8okJ)fkvmWHmh3kbPjIdW1VntHgjkij9nPokJ)fkvmWHmh3kbPjIdWv92eQHayfoqCDHPiwLs9nTrqG46ctrmfsBJmjX(ccexxykIzjGYKe7li4EdbMFBMcnsuqs6BsSlgm3BiWiUUWuKuFtByxmbbVU3qGXnzLC2qowLkpn(xOK5FSxeJelXVpj)YHG5Edbg3KvYzxmFDug)luQyGdzoUvcstehGR)XErDug)luQyGdzoUvcstehG7CtPX)cLsDPEaMMdDiyA9lAUDuDug)luQybtRFrZ9G6TrDhGeaRWbCMBsb0aKyUM2sojrbPP1YxuLavmkYUfggb2rz8VqPIfmT(fn3ioax1nd1qaKdixtY3gG0RoGhaRWbq0ZCqOmudXgYXQuj(qowLQokJ)fkvSGP1VO5gXb46GqzOgQJQJY4FHsft9hmqd7RtsQ8BJda5aY1K8Tbi9Qd4bWkCahq0Zmqd7RtsQ8BJJe0CmGe7l(XkbcdhJ)fkzgOH91jjv(TXrcAogqIvPmOlGIEyEXbe9md0W(6KKk)24ifrMM9f)yLafearpZanSVojPYVnosrKPzd5yvQehE(eearpZanSVojPYVnosqZXasm1B8JEIlyGONzGg2xNKu53ghjO5yaj2qowLkpXfmq0Zmqd7RtsQ8BJJe0CmGe7l(Xkb2rz8VqPIP(ioaxokprhj5lIKkSAQxbWkCW7PnL5QjghLNOJKeKuaMCy4WriniYFY4MSsoBideqbb3BiW4MSso7I5dMP(X0smKFA80JWhMx3BiWiUUWuKuFtByd5yvQehp8feCVHaJ46ctrsfsBdBihRsL44HVpbHqbu0lhYXQu5jE43rz8VqPIP(ioa3tBkZvtamnh6ai6Ldfz3AihkFfapn9Lo419gcmUjRKZgYXQujo8G519gcSXoPeDvYWqjaaiBihRsL4Wtqah3BiWg7Ks0vjddLaaGSlMpbbCCVHaJBYk5SlMGGP(X0smKFA8ex47dMxCCVHa7yLGdbkjhmKFACO8LusdWcai2ftqWu)yAjgYpnEIl89bZR7neyexxyksQqAByd5yvQehihK5yIvqW9gcmIRlmfj130g2qowLkXbYbzoMy91rz8VqPIP(ioaxhekd1qaKdixtY3gG0RoGhaRWHHcdPezUAc2Bdq6zF5qYhjblsC8IgMxdtYfr8JWoTPmxnXarVCOi7wd5q5R81rz8VqPIP(ioax1nd1qaKdixtY3gG0RoGhaRWHHcdPezUAc2Bdq6zF5qYhjblsC8IgMxdtYfr8JWoTPmxnXarVCOi7wd5q5R81rz8VqPIP(ioax1tATnYG2gcGCa5As(2aKE1b8ayfomuyiLiZvtWEBasp7lhs(ijyrIJNhdZRHj5Ii(ryN2uMRMyGOxouKDRHCO8v(6Om(xOuXuFehGBanCsIcY0(7qaSchmmjxeXp2rz8VqPIP(ioa3XoPeDvYWqjaaiaRWb3BiW4MSso7I1rz8VqPIP(ioaxYbd5NgPlkbbyfo41R7neyexxyksQqAByd5yvQehp8feCVHaJ46ctrs9nTHnKJvPsC8W3hmocPbr(tg3KvYzd5yvQehx4dZR7neyyt5GgWY0sB4wwCj2vRSHDA6l5z0Ee(cc4m3KcObiXWMYbnGLPL2WTS4sSRwzdJISBHHrG(8ji4Edbg2uoObSmT0gULfxID1kByNM(sIFiACl(ccCesdI8NmUjRKZgYabeMxt9JPLyi)0iEKIVGWPnL5QjwPKgI81rz8VqPIP(ioaxoPj1xMwA6cy6q5dWkCahW5wGSej5GkyN2uMRMyCqjhLG1xOeMxt9JPLyi)0iEKIpmVU3qGDSsWHaLKdgYpnou(skPbybae7IjiGdhDsPLp7iGtzPpbbo6KslFwwaf9YGrccN2uMRMyLsAisqW9gcmxncbQVQNDXG5EdbMRgHa1x1ZgYXQu5z04hHxVrkaAUjfqdqIHnLdAaltlTHBzXLyxTYggfz3cdJa9fHxokbV1ZWgIxksA6cy6q5Z(YHKNM(s(85dgoU3qGXnzLC2fdMxC4OtkT8zzbu0ldgjiWriniYFY4O8eDKKVisQWQPEf7Ijiu5tdgsBpbkdfqrVCihRsLNCesdI8Nmokprhj5lIKkSAQxXgYXQufHhliu5tdgsBpbkdfqrVCihRsLh6H45bW3ZOXpcVCucERNHneVuK00fW0HYN9Ldjpn9L85RJY4FHsft9rCaUvYTjTVqjaRWbCaNBbYsKKdQGDAtzUAIXbLCucwFHsyEn1pMwIH8tJ4rk(W86Edb2Xkbhcusoyi)04q5lPKgGfaqSlMGaoC0jLw(SJaoLL(ee4OtkT8zzbu0ldgjiCAtzUAIvkPHibb3BiWC1ieO(QE2fdM7neyUAecuFvpBihRsLN4c)i86nsbqZnPaAasmSPCqdyzAPnCllUe7Qv2WOi7wyyeOVi8Yrj4TEg2q8srstxathkF2xoK800xYNpFWWX9gcmUjRKZUyW8IdhDsPLpllGIEzWibbocPbr(tghLNOJK8frsfwn1RyxmbHkFAWqA7jqzOak6Ld5yvQ8KJqAqK)KXr5j6ijFrKuHvt9k2qowLQi8ybHkFAWqA7jqzOak6Ld5yvQ8qpeppa(EIl8JWlhLG36zydXlfjnDbmDO8zF5qYttFjF(6Om(xOuXuFehG7PnL5QjaMMdDqzNKmGgj3KvYb4PPV0bC4iKge5pzCtwjNnKbcOGaoN2uMRMyCuEIossqsbyYHXrNuA5ZYcOOxgmsqaCUfilrsoOQJY4FHsft9rCaUH7aOefKK(MeaRWbIRlmfXQuAjGWmmjxeXpcZ9gcmSPCqdyzAPnCllUe7Qv2Won9L8mApcFyEbrpZanSVojPYVnosqZXasSV4hReOGaoC0jLw(SK4dsJgqFWoTPmxnXu2jjdOrYnzL8okJ)fkvm1hXb4QEBcMwdWkCW9gcmusViLeJgoH9fkzxmyU3qGPEBcMwZgkmKsK5QPokJ)fkvm1hXb4YTKtAP7neayAo0b1BJgnGaSchCVHat92OrdiBihRsLNWdMx3BiWiUUWuKuH02WgYXQujo8eeCVHaJ46ctrs9nTHnKJvPsC45dMP(X0smKFAepsXVJY4FHsft9rCaUQ3MGP1aSchEtt5ZupP12ibNk8mknxnbctr)xjqftH0ij4uHhM7neyQ3MGP1mqK)SJY4FHsft9rCaUQ3g1DasaSch4OtkT8zzbu0ldgb70MYC1eJJYt0rscskatomocPbr(tghLNOJK8frsfwn1Ryd5yvQ8eEWWbCUfilrsoOQJY4FHsft9rCaUQ3MGP1aSchEtt5ZupP12ibNk8mknxnbcdN30u(m1BJgnGmknxnbcZ9gcm1BtW0A2qHHuImxnbZR7neyexxyksQVPnSHCSkvI7XWiUUWueRsP(M2aZ9gcmSPCqdyzAPnCllUe7Qv2Won9L8mA4HVGG7neyyt5GgWY0sB4wwCj2vRSHDA6lj(HOHh(Wm1pMwIH8tJ4rk(ccGONzGg2xNKu53ghjO5yaj2qowLkX9accg)luYmqd7RtsQ8BJJe0CmGeRszqxaf9(GHdhH0Gi)jJBYk5SHmqa7Om(xOuXuFehGR6TrDhGeaRWb3BiWqj9IusUMSrEwQcLSlMGG7neyhReCiqj5GH8tJdLVKsAawaaXUyccU3qGXnzLC2fdMx3BiWg7Ks0vjddLaaGSHCSkvEcKdYCmXcG4uP9AQFmTed5Ngpex47dM7neyJDsj6QKHHsaaq2ftqah3BiWg7Ks0vjddLaaGSlgmC4iKge5pzJDsj6QKHHsaaq2qgiGcc4WrNuA5ZoP8fb44tqWu)yAjgYpnIhP4dJ46ctrSkLwcyhLX)cLkM6J4aCvVnQ7aKayfo8MMYNPEB0ObKrP5QjqyEDVHat92Ordi7IjiyQFmTed5NgXJu89bZ9gcm1BJgnGm1B8JEIlyEDVHaJ46ctrsfsBd7Iji4EdbgX1fMIK6BAd7I5dM7neyyt5GgWY0sB4wwCj2vRSHDA6l5z04w8H5LJqAqK)KXnzLC2qowLkXXdFbbCoTPmxnX4O8eDKKGKcWKdJJoP0YNLfqrVmyKVokJ)fkvm1hXb4QEBu3bibWkCWR7neyyt5GgWY0sB4wwCj2vRSHDA6l5z04w8feCVHadBkh0awMwAd3YIlXUALnSttFjpJgE4d7nnLpt9KwBJeCQWZO0C1eOpyU3qGrCDHPiPcPTHnKJvPsCClmIRlmfXQuQqABGHJ7neyOKErkjgnCc7luYUyWW5nnLpt92OrdiJsZvtGW4iKge5pzCtwjNnKJvPsCClmVCesdI8NmYbd5NgPlkbzd5yvQeh3kiGdhDsPLp7iGtzPVokJ)fkvm1hXb4MKFPdcLaSch86EdbgX1fMIK6BAd7Iji4LlYgGK6q0WgIlYgGK8lhYt45tqGlYgGK6aU8bZWKCre)iStBkZvtmLDsYaAKCtwjVJY4FHsft9rCaUImDq6GqjaRWbVU3qGrCDHPiP(M2WUyWWHJoP0YNDeWPSuqWR7neyhReCiqj5GH8tJdLVKsAawaaXUyW4OtkT8zhbCkl9ji4LlYgGK6q0WgIlYgGK8lhYt45tqGlYgGK6aUeeCVHaJBYk5SlMpygMKlI4hHDAtzUAIPStsgqJKBYk5Dug)luQyQpIdWnC1APdcLaSch86EdbgX1fMIK6BAd7Ibdho6KslF2raNYsbbVU3qGDSsWHaLKdgYpnou(skPbybae7IbJJoP0YNDeWPS0NGGxUiBasQdrdBiUiBasYVCipHNpbbUiBasQd4sqW9gcmUjRKZUy(GzysUiIFe2PnL5QjMYojzansUjRK3rz8VqPIP(ioax)2mfAKOGK03K6Om(xOuXuFehGR6TjudbWkCG46ctrSkL6BAJGaX1fMIykK2gzsI9feiUUWueZsaLjj2xqW9gcm)2mfAKOGK03KyxmyU3qGrCDHPiP(M2WUyccEDVHaJBYk5SHCSkvEA8VqjZ)yVigjwIFFs(LdbZ9gcmUjRKZUy(6Om(xOuXuFehGR)XErDug)luQyQpIdWDUP04FHsPUupatZHoemT(fnxOyfgXHGdE4hn0d9qqa]] )


end