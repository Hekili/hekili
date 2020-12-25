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


    spec:RegisterPack( "Balance", 20201225, [[dOedHdqicLhbvKCjQcAtG0NGkkJIQYPOkTkaiVsimla0TGkIDHYVargguLJbvAzcPEgiQPrvixdeABufQVbvunoQc4CcrzDcryEufDpvW(iuDqQculeQkpuiQMOqeHlker0hfIOCsOIuwPqYmbG6McruzNGGFkervdviI0sPkq8uHAQqf(kvbsJfQiv7fO)s0Gv6Wuwmj9yunzqDzKnl4ZaA0eYPL8AvOztQBtIDl63qgouoUqKwUINtLPRQRRsBxf9DQQgpuvDEaA9aG5tW(LAqCbXbymS9eieIgVOXd3OJgImCHiKXdY4cg)aIrGXyg)ObKaJttHaJXNPTKtGXygGAKbdIdWyh6oCcmw0)yUibKGeW6fDvzCKcKCLYvBFHs(yHhsUsHdjWy1BPFCAjOkymS9eieIgVOXd3OJgImCHiKXlApgm2UVi0aghxkroySOcgMsqvWyyYXbJXP6fFM2so1BKeZTG7OWP6nscItkQ00B0qeG9gnErJxhvhfovVrUilbsUirhfovV4KE9GHHj4EJrAB6fFKPW6OWP6fN0BKlYsGeCVVnaPxwHE5MJC9(OE5aY1K8Tbi9owhfovV4KE9GqkOtcU3BMeNCoBaS3tBktvtUE9vmIbWEXg6u6EBC3bi1lor8EXg6K5EBC3bi5L1rHt1loPxp4tub3l2qCZ9vcSxpOJ9I6Tc9wpoZ17lI61)GsG9gjjxxyoI1rHt1loP3i5SJuVrokprhPEFruVXy1uVRxRxD9VM6vbnuVbnH)svt96Rc9ci62RidoXzFVIQV3671vkx9BjHUonG96VEr9IVi59GXrVr0BKtAY9LP71dwxatfkFa2B94m4EDhlmVmWyD5EhioaJXgIJuuThehGqaxqCagB8Vqjy8XkHhcw6WQPEhymLMQMGbXh4dcHObXbySX)cLGXkiuESszankGXuAQAcgeFGpieGmioaJP0u1emi(aJn(xOem2)yViWy(upnLbg7RxIRlmhX030gzs4)7vqOxIRlmhXQuQVPn9ki0lX1fMJyvkvrVOEfe6L46cZrmlbuMe()E9cgRRKKCyWyCXd8bHGhbIdWyknvnbdIpWy(upnLbg7RxIRlmhX030gzs4)7vqOxIRlmhXQuQVPn9ki0lX1fMJyvkvrVOEfe6L46cZrmlbuMe()E92l0EXg6KHlZ)yVOEH2Ry9In0jlAM)XErGXg)lucg7FSxe4dcbicIdWyknvnbdIpWy(upnLbglwVZnPaAasmvtBjNKOG00A5lQsGogLMQMG7vqOxX6LJoP0YNLfqrVmyuVcc9kwVomsRLVnaP3XCVnbtR79qV42RGqVI17BAkFwA)DiNu10wYjgLMQMGbJn(xOem292eQHaFqi4XG4amMstvtWG4dmMp1ttzGXZnPaAasmvtBjNKOG00A5lQsGogLMQMG7fAVC0jLw(SSak6LbJ6fAVomsRLVnaP3XCVnbtR79qV4cgB8VqjyS7TXDhGe4d(GXWuWU6hehGqaxqCagB8VqjySdPTrQsMcymLMQMGbXh4dcHObXbymLMQMGbXhymcdm2rpySX)cLGXN2uMQMaJpn9LaJDyKwlFBasVJ5EBcMw3R49IBVq71xVI17BAkFM7TrJgygLMQMG7vqO330u(m3tATns4PcpJstvtW96TxbHEDyKwlFBasVJ5EBcMw3R49gny8PnY0uiW4Yjneb(GqaYG4amMstvtWG4dmgHbg7Ohm24FHsW4tBktvtGXNM(sGXomsRLVnaP3XCVnHAOEfVxCbJpTrMMcbgxojxt2jb(GqWJaXbymLMQMGbXhymFQNMYaJ91Ry9YrNuA5ZYcOOxgmQxbHEfRxocPHr(tghLNOJK8frshwn17yxSE92l0EvVHaJBYk5SlgySX)cLGXQ04O5yLabFqiarqCagtPPQjyq8bgZN6PPmWy1BiW4MSso7IbgB8Vqjymg6luc(GqWJbXbymLMQMGbXhymcdm2rpySX)cLGXN2uMQMaJpn9LaJdAeA61xV(6TYNgmK2EcwgkGIE5qkwLUEXj9gnE9It6LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE92lK6f3OXRxV9kEVbncn96RxF9w5tdgsBpbldfqrVCifRsxV4KEJgI9It61xV4IxVaOEFtt5ZQKBtAFHsgLMQMG71BV4KE91lhLW36zydXlhjnDbmvO8zFPqYttFPE92loPxocPHr(tg3KvYzdPyv661BVqQxC9a41R3Efe6LJqAyK)KXnzLC2qkwLUEfV3kFAWqA7jyzOak6LdPyv66vqOxocPHr(tghLNOJK8frshwn17ydPyv66v8ER8PbdPTNGLHcOOxoKIvPRxbHEfRxo6KslFwwaf9YGrGXN2ittHaJ5O8eDKKWKdWKd(GqaNdIdWyknvnbdIpWyegySJEWyJ)fkbJpTPmvnbgFA6lbg7RxX6LI0BHHrWmsbdWHmTenWPLCQxbHE5iKgg5pzKcgGdzAjAGtl5eBifRsxVE2lUEmE9cTxX6LJqAyK)KrkyaoKPLOboTKtSHmya71BVcc9YrNuA5Zoc4uwcgFAJmnfcmMdl5OeU(cLGpie8aG4amMstvtWG4dm24FHsWysbdWHmTenWPLCcmMp1ttzGXCesdJ8NmUjRKZgsXQ01RN9gnE9cT3tBktvtmokprhjjm5am59ki0lhH0Wi)jJJYt0rs(IiPdRM6DSHuSkD96zVrJhyCAkeymPGb4qMwIg40sob(GqiYaXbymLMQMGbXhySX)cLGXo0vRP)ReOCUQacgZN6PPmWyocPHr(tg3KvYzdPyv661ZE94EH27PnLPQjghLNOJKeMCaM8Efe6LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE9Sxpgmonfcm2HUAn9FLaLZvfqWhec4IhioaJP0u1emi(aJn(xOemUshFUVPQjzKET8Vksy6S4eymFQNMYaJvVHaJBYk5SlgyCAkeyCLo(CFtvtYi9A5FvKW0zXjWhec4IlioaJP0u1emi(aJ5t90ugyS6neyCtwjNDX6vqOxo6KslFwwaf9YGr9cT3tBktvtmokprhjjm5am59cTxocPHr(tghLNOJK8frshwn17yxSEH2Ry9YrinmYFY4MSso7I1l0E91RVEvVHaJ46cZrs9nTHnKIvPRxX7fx86vqOx1BiWiUUWCK0H02WgsXQ01R49IlE96TxO9kwVZnPaAasmvtBjNKOG00A5lQsGogLMQMG7vqO35MuanajMQPTKtsuqAAT8fvjqhJstvtW9cTxF9QEdbMQPTKtsuqAAT8fvjqNmT)oeZ9g)yVI3lK7vqOx1BiWunTLCsIcstRLVOkb6K2WTKyU34h7v8EHCVE71BVcc9QEdb2XkHhcwskyi)0Oq5lPKgGfaqSlwVcc9gkGIE5qkwLUE9S3OXdm24FHsW4RJK1tkoWhec4gnioaJP0u1emi(aJ5t90ugy8PnLPQjw5KgIaJD)u8hec4cgB8Vqjy8CtPX)cLsD5EWyD5EzAkeySHiWhec4czqCagtPPQjyq8bgZN6PPmW45Muanaj2xkKF0Ks4Hmf1kHPHrr6TWWiyWy3pf)bHaUGXg)lucgp3uA8VqPuxUhmwxUxMMcbgdpKPOwjmnGpieW1JaXbymLMQMGbXhymFQNMYaJNBsb0aKyQM2sojrbPP1YxuLaDmksVfggbdg7(P4pieWfm24FHsW45MsJ)fkL6Y9GX6Y9Y0uiWyvK9GpieWfIG4amMstvtWG4dm24FHsW45MsJ)fkL6Y9GX6Y9Y0uiWy3d(Gpym8qMIALW0aIdqiGlioaJP0u1emi(aJryGXo6bJn(xOem(0MYu1ey8PPVeySVEvVHa7lfYpAsj8qMIALW0WgsXQ01R49cKdZum83Be9Ihd3EH2RVEjUUWCeRsPk6f1RGqVexxyoIvP0H020RGqVexxyoIPVPnYKW)3R3Efe6v9gcSVui)OjLWdzkQvctdBifRsxVI3RX)cLm3BtOgIr4N43NKFPq9grV4XWTxO96RxIRlmhXQuQVPn9ki0lX1fMJyoK2gzs4)7vqOxIRlmhXSeqzs4)71BVE7vqOxX6v9gcSVui)OjLWdzkQvctd7IbgFAJmnfcm2zbs(i51rshgP1GpieIgehGXuAQAcgeFGX8PEAkdm2xVI17PnLPQjMZcK8rYRJKomsR7vqOxF9QEdb2yNuIUozyOeaaKnKIvPRxp7fihMPy4VxauVCQ096RxZ9JPLyi)00lK6fY41R3EH2R6neyJDsj66KHHsaaq2fRxV96TxbHEn3pMwIH8ttVI3BKHhySX)cLGXU3g3DasGpieGmioaJP0u1emi(aJ5t90ugySVEpTPmvnX4O8eDKKWKdWK3l0ER8PbdPTNGLHcOOxoKIvPRxX7fxiJxVq7vSE5iKgg5pzCtwjNnKbdyVcc9QEdbg3KvYzxSE92l0En3pMwIH8ttVE2RhHxVq71xVQ3qGrCDH5iP(M2WgsXQ01R49IlE9ki0R6neyexxyos6qABydPyv66v8EXfVE92RGqVHcOOxoKIvPRxp7fx8aJn(xOemMJYt0rs(IiPdRM6DGpie8iqCagtPPQjyq8bgB8VqjySbByFDssNFBuaJ5t90ugySy9cJEMbByFDssNFBuKWMIbKyFXpwjWEH2Ry9A8VqjZGnSVojPZVnksytXasSkLbDbu03l0E91Ry9cJEMbByFDssNFBuKIitZ(IFSsG9ki0lm6zgSH91jjD(TrrkImnBifRsxVI3le71BVcc9cJEMbByFDssNFBuKWMIbKyU34h71ZEHCVq7fg9md2W(6KKo)2OiHnfdiXgsXQ01RN9c5EH2lm6zgSH91jjD(TrrcBkgqI9f)yLabJ5aY1K8Tbi9oqiGl4dcbicIdWyknvnbdIpWyJ)fkbJvqOmudbgZN6PPmW4Hcd5ezQAQxO9(2aKE2xkK8rs4I6v8EXn6EH2RVE91R6neyCtwjNnKIvPRxX7fI9cTxF9QEdb2yNuIUozyOeaaKnKIvPRxX7fI9ki0Ry9QEdb2yNuIUozyOeaaKDX61BVcc9kwVQ3qGXnzLC2fRxbHEn3pMwIH8ttVE2lKXRxV9cTxF9kwVQ3qGDSs4HGLKcgYpnku(skPbybae7I1RGqVM7htlXq(PPxp7fY41R3EH2RHj5Ii(XE9cgZbKRj5Bdq6DGqaxWhecEmioaJP0u1emi(aJn(xOem2DZqneymFQNMYaJhkmKtKPQPEH27Bdq6zFPqYhjHlQxX7f3O7fAV(61xVQ3qGXnzLC2qkwLUEfVxi2l0E91R6neyJDsj66KHHsaaq2qkwLUEfVxi2RGqVI1R6neyJDsj66KHHsaaq2fRxV9ki0Ry9QEdbg3KvYzxSEfe61C)yAjgYpn96zVqgVE92l0E91Ry9QEdb2XkHhcwskyi)0Oq5lPKgGfaqSlwVcc9AUFmTed5NME9SxiJxVE7fAVgMKlI4h71lymhqUMKVnaP3bcbCbFqiGZbXbymLMQMGbXhySX)cLGXUN0ABKbTneymFQNMYaJhkmKtKPQPEH27Bdq6zFPqYhjHlQxX7fxpUxO96RxF9QEdbg3KvYzdPyv66v8EHyVq71xVQ3qGn2jLORtggkbaazdPyv66v8EHyVcc9kwVQ3qGn2jLORtggkbaazxSE92RGqVI1R6neyCtwjNDX6vqOxZ9JPLyi)00RN9cz861BVq71xVI1R6neyhReEiyjPGH8tJcLVKsAawaaXUy9ki0R5(X0smKFA61ZEHmE96TxO9AysUiIFSxVGXCa5As(2aKEhieWf8bHGhaehGXuAQAcgeFGX8PEAkdm2WKCre)iySX)cLGXb0Wjjkit7Vdb(GqiYaXbymLMQMGbXhymFQNMYaJvVHaJBYk5SlgySX)cLGXJDsj66KHHsaaqWhec4IhioaJP0u1emi(aJ5t90ugySVE91R6neyexxyos6qABydPyv66v8EXfVEfe6v9gcmIRlmhj130g2qkwLUEfVxCXRxV9cTxocPHr(tg3KvYzdPyv66v8EHmE96TxbHE5iKgg5pzCtwjNnKbdiySX)cLGXKcgYpnsvucd(GqaxCbXbymLMQMGbXhymFQNMYaJpTPmvnX4WsokHRVqzVq71xV(6v9gcSJvcpeSKuWq(PrHYxsjnalaGyxSEfe6vSE5OtkT8zhbCkl71BVcc9YrNuA5ZYcOOxgmQxbHEpTPmvnXkN0quVcc9QEdbMQgHG1x3ZUy9cTx1BiWu1ieS(6E2qkwLUE9S3OXR3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVE7fAVI1R6neyCtwjNDX6fAV(6vSE5OtkT8zzbu0ldg1RGqVCesdJ8Nmokprhj5lIKoSAQ3XUy9ki0BLpnyiT9eSmuaf9YHuSkD96zVCesdJ8Nmokprhj5lIKoSAQ3XgsXQ01Be96X9ki0BLpnyiT9eSmuaf9YHuSkD96H9IRhaVE9S3OXR3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVEbJn(xOemMtAY9LPLMUaMku(GpieWnAqCagtPPQjyq8bgZN6PPmW4tBktvtmoSKJs46lu2l0E91RVEvVHa7yLWdbljfmKFAuO8LusdWcai2fRxbHEfRxo6KslF2raNYYE92RGqVC0jLw(SSak6LbJ6vqO3tBktvtSYjne1RGqVQ3qGPQriy919SlwVq7v9gcmvncbRVUNnKIvPRxp7fY41Be96RxokHV1ZWgIxosA6cyQq5Z(sHKNM(s96TxV9cTxX6v9gcmUjRKZUy9cTxF9kwVC0jLw(SSak6LbJ6vqOxocPHr(tghLNOJK8frshwn17yxSEfe6TYNgmK2EcwgkGIE5qkwLUE9SxocPHr(tghLNOJK8frshwn17ydPyv66nIE94Efe6TYNgmK2EcwgkGIE5qkwLUE9WEX1dGxVE2lKXR3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVEbJn(xOemUsUnP9fkbFqiGlKbXbymLMQMGbXhymcdm2rpySX)cLGXN2uMQMaJpn9LaJ91Ry9YrinmYFY4MSsoBidgWEfe6vSEpTPmvnX4O8eDKKWKdWK3l0E5OtkT8zzbu0ldg1RxW4tBKPPqGXo7KKb0i5MSso4dcbC9iqCagtPPQjyq8bgZN6PPmWyIRlmhXQuAjG9cTxdtYfr8J9cTxF9cJEMbByFDssNFBuKWMIbKyFXpwjWEfe6vSE5OtkT8zjXhKgnW96TxO9EAtzQAI5StsgqJKBYk5GXg)lucghUdGsuqs6BsGpieWfIG4amMstvtWG4dmMp1ttzGXC0jLw(SSak6LbJ6fAVN2uMQMyCuEIossyYbyY7fAVM7htlXq(PPxXp0RhHxVq7LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE9SxGCyMIH)Ebq9YPs3RVEn3pMwIH8ttVqQxiJxVEbJn(xOem2924Udqc8bHaUEmioaJP0u1emi(aJ5t90ugySVEvVHaJ46cZrs9nTHDX6vqOxF9YfzdqY17HEJUxO9oexKnaj5xkuVE2le71BVcc9YfzdqY17HEHCVE7fAVgMKlI4h7fAVN2uMQMyo7KKb0i5MSsoySX)cLGXj5xQGqj4dcbCX5G4amMstvtWG4dmMp1ttzGX(6v9gcmIRlmhj130g2fRxO9kwVC0jLw(SJaoLL9ki0RVEvVHa7yLWdbljfmKFAuO8LusdWcai2fRxO9YrNuA5Zoc4uw2R3Efe61xVCr2aKC9EO3O7fAVdXfzdqs(Lc1RN9cXE92RGqVCr2aKC9EOxi3RGqVQ3qGXnzLC2fRxV9cTxdtYfr8J9cT3tBktvtmNDsYaAKCtwjhm24FHsWyrMoivqOe8bHaUEaqCagtPPQjyq8bgZN6PPmWyF9QEdbgX1fMJK6BAd7I1l0EfRxo6KslF2raNYYEfe61xVQ3qGDSs4HGLKcgYpnku(skPbybae7I1l0E5OtkT8zhbCkl71BVcc96RxUiBasUEp0B09cT3H4ISbij)sH61ZEHyVE7vqOxUiBasUEp0lK7vqOx1BiW4MSso7I1R3EH2RHj5Ii(XEH27PnLPQjMZojzansUjRKdgB8VqjyC4Q1sfekbFqiGBKbIdWyJ)fkbJ9BZuOrIcssFtcmMstvtWG4d8bHq04bIdWyknvnbdIpWy(upnLbgtCDH5iwLs9nTPxbHEjUUWCeZH02itc)FVcc9sCDH5iMLaktc)FVcc9QEdbMFBMcnsuqs6BsSlwVq7v9gcmIRlmhj130g2fRxbHE91R6neyCtwjNnKIvPRxp714FHsM)XErmc)e)(K8lfQxO9QEdbg3KvYzxSE9cgB8VqjyS7Tjudb(GqiACbXbySX)cLGX(h7fbgtPPQjyq8b(Gqi6ObXbymLMQMGbXhySX)cLGXZnLg)luk1L7bJ1L7LPPqGXbtRFrZf8bFWydrG4aec4cIdWyknvnbdIpWyegySJEWyJ)fkbJpTPmvnbgFA6lbg7Rx1BiW(sH8JMucpKPOwjmnSHuSkD96zVa5Wmfd)9grV4XWTxbHEvVHa7lfYpAsj8qMIALW0WgsXQ01RN9A8VqjZ92eQHye(j(9j5xkuVr0lEmC7fAV(6L46cZrSkL6BAtVcc9sCDH5iMdPTrMe()Efe6L46cZrmlbuMe()E92R3EH2R6neyFPq(rtkHhYuuReMg2fRxO9o3KcObiX(sH8JMucpKPOwjmnmksVfggbdgFAJmnfcmgEitr6V0AzW0AjkeaFqienioaJP0u1emi(aJ5t90ugySVEpTPmvnX4O8eDKKWKdWK3l0EfRxocPHr(tg3KvYzdzWa2RGqVQ3qGXnzLC2fRxV9cTxZ9JPLyi)00RN9cr86fAV(6v9gcmIRlmhj130g2qkwLUEfVxpUxbHEvVHaJ46cZrshsBdBifRsxVI3Rh3R3EH2RVEfR35MuanajMQPTKtsuqAAT8fvjqhJstvtW9ki0R6neyQM2sojrbPP1YxuLaDY0(7qm3B8J9kEVqUxbHEvVHat10wYjjkinTw(IQeOtAd3sI5EJFSxX7fY96TxbHEdfqrVCifRsxVE2lU4bgB8VqjymhLNOJK8frshwn17aFqiazqCagtPPQjyq8bgB8VqjyS7MHAiWy(upnLbgpuyiNitvt9cT33gG0Z(sHKpscxuVI3lUEuV4KEDyKwlFBasVR3i6DifRsxVq71xVexxyoIvP0sa7vqO3HuSkD96zVa5Wmfd)96fmMdixtY3gG07aHaUGpie8iqCagtPPQjyq8bgZN6PPmWy1BiWCVnbtRzdfgYjYu1uVq71xVomsRLVnaP3XCVnbtR71ZEHCVcc9kwVZnPaAasSVui)OjLWdzkQvctdJI0BHHrW96TxO96RxX6DUjfqdqIPbKBJ5KbnrFLaLa1LcMJyuKElmmcUxbHE)sH61d71JGyVI3R6neyU3MGP1SHuSkD9grVr3R3EH2BOak6LdPyv66v8EHiySX)cLGXU3MGP1GpieGiioaJP0u1emi(aJ5t90ugy8CtkGgGe7lfYpAsj8qMIALW0WOi9wyyeCVq71HrAT8Tbi9oM7TjyADVIFOxi3l0E91Ry9QEdb2xkKF0Ks4Hmf1kHPHDX6fAVQ3qG5EBcMwZgkmKtKPQPEfe61xVN2uMQMyWdzks)LwldMwlrHqVq71xVQ3qG5EBcMwZgsXQ01RN9c5Efe61HrAT8Tbi9oM7TjyADVI3B09cT330u(m3tATns4PcpJstvtW9cTx1BiWCVnbtRzdPyv661ZEHyVE71BVEbJn(xOem292emTg8bHGhdIdWyknvnbdIpWyegySJEWyJ)fkbJpTPmvnbgFA6lbgBUFmTed5NMEfVxpaE9It61xV4IxVaOEvVHa7lfYpAsj8qMIALW0WCVXp2R3EXj96Rx1BiWCVnbtRzdPyv66fa1lK7fs96WiTwkYCp1R3EXj96Rxy0Zc3bqjkij9nj2qkwLUEbq9cXE92l0EvVHaZ92emTMDXaJpTrMMcbg7EBcMwl9JYxgmTwIcbWhec4CqCagtPPQjyq8bgZN6PPmW4tBktvtm4HmfP)sRLbtRLOqOxO9EAtzQAI5EBcMwl9JYxgmTwIcHEfe61xVQ3qGPAAl5KefKMwlFrvc0jt7VdXCVXp2R49c5Efe6v9gcmvtBjNKOG00A5lQsGoPnCljM7n(XEfVxi3R3EH2RdJ0A5Bdq6Dm3BtW06E9Sxpcm24FHsWy3BJ7oajWhecEaqCagtPPQjyq8bgB8VqjySbByFDssNFBuaJ5t90ugySy9(f)yLa7fAVI1RX)cLmd2W(6KKo)2OiHnfdiXQug0fqrFVcc9cJEMbByFDssNFBuKWMIbKyU34h71ZEHCVq7fg9md2W(6KKo)2OiHnfdiXgsXQ01RN9czWyoGCnjFBasVdec4c(GqiYaXbymLMQMGbXhySX)cLGXkiugQHaJ5t90ugy8qHHCImvn1l0EFBasp7lfs(ijCr9kEV(6fxpQ3i61xVomsRLVnaP3XCVnHAOEbq9IldI96TxV9cPEDyKwlFBasVR3i6DifRsxVq71xV(6LJqAyK)KXnzLC2qgmG9cTxF9EAtzQAIXr5j6ijHjhGjVxbHE5iKgg5pzCuEIosYxejDy1uVJnKbdyVcc9kwVC0jLw(SSak6LbJ61BVcc96WiTw(2aKEhZ92eQH61ZE91le7fa1RVEXT3i69nnLp79xPubHshJstvtW96TxV9ki0RVEjUUWCeRsPdPTPxbHE91lX1fMJyvkvrVOEfe6L46cZrSkL6BAtVE7fAVI17BAkFMdD1suq(IizanK7zuAQAcUxbHEvVHadBkf0axMwAd3YIlXUANnSttFPEf)qVrdr861BVq71xVomsRLVnaP3XCVnHAOE9SxCXRxauV(6f3EJO330u(S3FLsfekDmknvnb3R3E92l0En3pMwIH8ttVI3leXRxCsVQ3qG5EBcMwZgsXQ01laQxpUxV9cTxF9kwVQ3qGDSs4HGLKcgYpnku(skPbybae7I1RGqVexxyoIvP0H020RGqVI1lhDsPLp7iGtzzVE7fAVgMKlI4h71lymhqUMKVnaP3bcbCbFqiGlEG4amMstvtWG4dmMp1ttzGXgMKlI4hbJn(xOemoGgojrbzA)DiWhec4IlioaJP0u1emi(aJ5t90ugyS6neyCtwjNDXaJn(xOemEStkrxNmmucaac(Gqa3ObXbymLMQMGbXhymFQNMYaJpTPmvnX4WsokHRVqzVq71xVQ3qG5EBcMwZUy9ki0R5(X0smKFA6v8EHiE96TxO9kwVQ3qG5qA3xCIDX6fAVI1R6neyCtwjNDX6fAV(6vSE5OtkT8zzbu0ldg1RGqVN2uMQMyCuEIossyYbyY7vqOxocPHr(tghLNOJK8frshwn17yxSEfe6TYNgmK2EcwgkGIE5qkwLUE9S3OXR3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVEbJn(xOemMtAY9LPLMUaMku(GpieWfYG4amMstvtWG4dmMp1ttzGXN2uMQMyCyjhLW1xOSxO96Rx1BiWCVnbtRzxSEfe61C)yAjgYpn9kEVqeVE92l0EfRx1BiWCiT7loXUy9cTxX6v9gcmUjRKZUy9cTxF9kwVC0jLw(SSak6LbJ6vqO3tBktvtmokprhjjm5am59ki0lhH0Wi)jJJYt0rs(IiPdRM6DSlwVcc9w5tdgsBpbldfqrVCifRsxVE2lhH0Wi)jJJYt0rs(IiPdRM6DSHuSkD9grVECVcc9w5tdgsBpbldfqrVCifRsxVEyV46bWRxp7fY41Be96RxokHV1ZWgIxosA6cyQq5Z(sHKNM(s96TxVGXg)lucgxj3M0(cLGpieW1JaXbymLMQMGbXhymFQNMYaJR8PbdPTNGLHcOOxoKIvPRxp7fxi2RGqV(6v9gcmSPuqdCzAPnCllUe7QD2Won9L61ZEJgI41RGqVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVIFO3OHiE96TxO9QEdbM7TjyAn7I1l0E5iKgg5pzCtwjNnKIvPRxX7fI4bgB8VqjymPGH8tJufLWGpieWfIG4amMstvtWG4dm24FHsWy3tATnYG2gcmMp1ttzGXdfgYjYu1uVq79lfs(ijCr9kEV4cXEH2RdJ0A5Bdq6Dm3BtOgQxp71J6fAVgMKlI4h7fAV(6v9gcmUjRKZgsXQ01R49IlE9ki0Ry9QEdbg3KvYzxSE9cgZbKRj5Bdq6DGqaxWhec46XG4amMstvtWG4dmMp1ttzGXexxyoIvP0sa7fAVgMKlI4h7fAVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVE2B0qeVEH2RVEHrpZGnSVojPZVnksytXasSV4hReyVcc9kwVC0jLw(SK4dsJg4Efe61HrAT8Tbi9UEfV3O71lySX)cLGXH7aOefKK(Me4dcbCX5G4amMstvtWG4dmMp1ttzGXQ3qGHs6f5Ky0WjSVqj7I1l0E91R6neyU3MGP1SHcd5ezQAQxbHEn3pMwIH8ttVI3BKHxVEbJn(xOem292emTg8bHaUEaqCagtPPQjyq8bgZN6PPmWyo6KslFwwaf9YGr9cTxF9EAtzQAIXr5j6ijHjhGjVxbHE5iKgg5pzCtwjNDX6vqOx1BiW4MSso7I1R3EH2lhH0Wi)jJJYt0rs(IiPdRM6DSHuSkD96zVa5Wmfd)9cG6LtLUxF9AUFmTed5NMEHuVqeVE92l0EvVHaZ92emTMnKIvPRxp71JaJn(xOem292emTg8bHaUrgioaJP0u1emi(aJ5t90ugymhDsPLpllGIEzWOEH2RVEpTPmvnX4O8eDKKWKdWK3RGqVCesdJ8NmUjRKZUy9ki0R6neyCtwjNDX61BVq7LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE9SxpUxO9QEdbM7TjyAn7I1l0EjUUWCeRsPLacgB8VqjyS7TXDhGe4dcHOXdehGXuAQAcgeFGX8PEAkdmw9gcmusViNKRjBKNLRqj7I1RGqV(6vSEDVnHAiMHj5Ii(XEfe61xVQ3qGXnzLC2qkwLUE9Sxi2l0EvVHaJBYk5SlwVcc96Rx1BiWg7Ks01jddLaaGSHuSkD96zVa5Wmfd)9cG6LtLUxF9AUFmTed5NMEHuVqgVE92l0EvVHaBStkrxNmmucaaYUy96TxV9cT3tBktvtm3BtW0APFu(YGP1sui0l0EDyKwlFBasVJ5EBcMw3RN9c5E92l0E91Ry9o3KcObiX(sH8JMucpKPOwjmnmksVfggb3RGqVomsRLVnaP3XCVnbtR71ZEHCVEbJn(xOem2924Udqc8bHq04cIdWyknvnbdIpWy(upnLbg7RxIRlmhXQuAjG9cTxocPHr(tg3KvYzdPyv66v8EHiE9ki0RVE5ISbi569qVr3l0EhIlYgGK8lfQxp7fI96TxbHE5ISbi569qVqUxV9cTxdtYfr8JGXg)lucgNKFPccLGpieIoAqCagtPPQjyq8bgZN6PPmWyF9sCDH5iwLslbSxO9YrinmYFY4MSsoBifRsxVI3leXRxbHE91lxKnajxVh6n6EH27qCr2aKKFPq96zVqSxV9ki0lxKnajxVh6fY96TxO9AysUiIFem24FHsWyrMoivqOe8bHq0qgehGXuAQAcgeFGX8PEAkdm2xVexxyoIvP0sa7fAVCesdJ8NmUjRKZgsXQ01R49cr86vqOxF9YfzdqY17HEJUxO9oexKnaj5xkuVE2le71BVcc9YfzdqY17HEHCVE7fAVgMKlI4hbJn(xOemoC1APccLGpieI2JaXbySX)cLGX(Tzk0irbjPVjbgtPPQjyq8b(GqiAicIdWyknvnbdIpWyegySJEWyJ)fkbJpTPmvnbgFA6lbg7WiTw(2aKEhZ92eQH6v8E9OEJO3GgHME91RI5EAauEA6l1lK6nA861BVr0BqJqtV(6v9gcm3BJ7oajjPGH8tJcLV0H02WCVXp2lK61J61ly8PnY0uiWy3BtOgswP0H02a(GqiApgehGXuAQAcgeFGX8PEAkdmM46cZrm9nTrMe()Efe6L46cZrmlbuMe()EH27PnLPQjw5KCnzNuVcc9QEdbgX1fMJKoK2g2qkwLUE9SxJ)fkzU3MqneJWpXVpj)sH6fAVQ3qGrCDH5iPdPTHDX6vqOxIRlmhXQu6qAB6fAVI17PnLPQjM7TjudjRu6qAB6vqOx1BiW4MSsoBifRsxVE2RX)cLm3BtOgIr4N43NKFPq9cTxX690MYu1eRCsUMStQxO9QEdbg3KvYzdPyv661ZEj8t87tYVuOEH2R6neyCtwjNDX6vqOx1BiWg7Ks01jddLaaGSlwVq71HrATuK5EQxX7fpMh3l0E91RdJ0A5Bdq6D965HEHCVcc9kwVVPP8zo0vlrb5lIKb0qUNrPPQj4E92RGqVI17PnLPQjw5KCnzNuVq7v9gcmUjRKZgsXQ01R49s4N43NKFPqGXg)lucg7FSxe4dcHOX5G4am24FHsWy3BtOgcmMstvtWG4d8bHq0EaqCagtPPQjyq8bgB8Vqjy8CtPX)cLsD5EWyD5EzAkeyCW06x0CbFWhmoyA9lAUG4aec4cIdWyknvnbdIpWy(upnLbglwVZnPaAasmvtBjNKOG00A5lQsGogfP3cdJGbJn(xOem2924Udqc8bHq0G4amMstvtWG4dm24FHsWy3nd1qGX8PEAkdmgg9mfekd1qSHuSkD9kEVdPyv6aJ5aY1K8Tbi9oqiGl4dcbidIdWyJ)fkbJvqOmudbgtPPQjyq8b(GpyS7bXbieWfehGXuAQAcgeFGXg)lucgBWg2xNK053gfWy(upnLbglwVWONzWg2xNK053gfjSPyaj2x8JvcSxO9kwVg)luYmyd7Rts68BJIe2umGeRszqxaf99cTxF9kwVWONzWg2xNK053gfPiY0SV4hReyVcc9cJEMbByFDssNFBuKIitZgsXQ01R49cXE92RGqVWONzWg2xNK053gfjSPyajM7n(XE9Sxi3l0EHrpZGnSVojPZVnksytXasSHuSkD96zVqUxO9cJEMbByFDssNFBuKWMIbKyFXpwjqWyoGCnjFBasVdec4c(GqiAqCagtPPQjyq8bgZN6PPmWyF9EAtzQAIXr5j6ijHjhGjVxO9kwVCesdJ8NmUjRKZgYGbSxbHEvVHaJBYk5SlwVE7fAVM7htlXq(PPxp71JWRxO96Rx1BiWiUUWCKuFtBydPyv66v8EXfVEfe6v9gcmIRlmhjDiTnSHuSkD9kEV4IxVE7vqO3qbu0lhsXQ01RN9IlEGXg)lucgZr5j6ijFrK0Hvt9oWhecqgehGXuAQAcgeFGXimWyh9GXg)lucgFAtzQAcm(00xcm2xVQ3qGXnzLC2qkwLUEfVxi2l0E91R6neyJDsj66KHHsaaq2qkwLUEfVxi2RGqVI1R6neyJDsj66KHHsaaq2fRxV9ki0Ry9QEdbg3KvYzxSEfe61C)yAjgYpn96zVqgVE92l0E91Ry9QEdb2XkHhcwskyi)0Oq5lPKgGfaqSlwVcc9AUFmTed5NME9SxiJxVE7fAV(6v9gcmIRlmhjDiTnSHuSkD9kEVa5Wmfd)9ki0R6neyexxyosQVPnSHuSkD9kEVa5Wmfd)96fm(0gzAkeymm6LdfP3AifkFh4dcbpcehGXuAQAcgeFGXg)lucgRGqzOgcmMp1ttzGXdfgYjYu1uVq79Tbi9SVui5JKWf1R49IB09cTxF9AysUiIFSxO9EAtzQAIbJE5qr6TgsHY31RxWyoGCnjFBasVdec4c(GqaIG4amMstvtWG4dm24FHsWy3nd1qGX8PEAkdmEOWqorMQM6fAVVnaPN9LcjFKeUOEfVxCJUxO96RxdtYfr8J9cT3tBktvtmy0lhksV1qku(UE9cgZbKRj5Bdq6DGqaxWhecEmioaJP0u1emi(aJn(xOem29KwBJmOTHaJ5t90ugy8qHHCImvn1l0EFBasp7lfs(ijCr9kEV46X9cTxF9AysUiIFSxO9EAtzQAIbJE5qr6TgsHY31RxWyoGCnjFBasVdec4c(GqaNdIdWyknvnbdIpWy(upnLbgBysUiIFem24FHsW4aA4KefKP93HaFqi4baXbymLMQMGbXhymFQNMYaJvVHaJBYk5SlgySX)cLGXJDsj66KHHsaaqWhecrgioaJP0u1emi(aJ5t90ugySVE91R6neyexxyos6qABydPyv66v8EXfVEfe6v9gcmIRlmhj130g2qkwLUEfVxCXRxV9cTxocPHr(tg3KvYzdPyv66v8EHmE9cTxF9QEdbg2ukObUmT0gULfxID1oByNM(s96zVr7r41RGqVI17CtkGgGedBkf0axMwAd3YIlXUANnmksVfggb3R3E92RGqVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVIFO3OX541RGqVCesdJ8NmUjRKZgYGbSxO96RxZ9JPLyi)00R49gz41RGqVN2uMQMyLtAiQxVGXg)lucgtkyi)0ivrjm4dcbCXdehGXuAQAcgeFGX8PEAkdm(0MYu1eJdl5OeU(cL9cTxF9AUFmTed5NMEfV3idVEH2RVEvVHa7yLWdbljfmKFAuO8LusdWcai2fRxbHEfRxo6KslF2raNYYE92RGqVC0jLw(SSak6LbJ6vqO3tBktvtSYjne1RGqVQ3qGPQriy919SlwVq7v9gcmvncbRVUNnKIvPRxp7nA86nIE91RVEJSEbq9o3KcObiXWMsbnWLPL2WTS4sSR2zdJI0BHHrW96T3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVE71BVq7vSEvVHaJBYk5SlwVq71xVI1lhDsPLpllGIEzWOEfe6LJqAyK)KXr5j6ijFrK0Hvt9o2fRxbHER8PbdPTNGLHcOOxoKIvPRxp7LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUEJOxpUxbHER8PbdPTNGLHcOOxoKIvPRxpSxC9a41RN9gnE9grV(6LJs4B9mSH4LJKMUaMku(SVui5PPVuVE71lySX)cLGXCstUVmT00fWuHYh8bHaU4cIdWyknvnbdIpWy(upnLbgFAtzQAIXHLCucxFHYEH2RVEn3pMwIH8ttVI3BKHxVq71xVQ3qGDSs4HGLKcgYpnku(skPbybae7I1RGqVI1lhDsPLp7iGtzzVE7vqOxo6KslFwwaf9YGr9ki07PnLPQjw5KgI6vqOx1BiWu1ieS(6E2fRxO9QEdbMQgHG1x3ZgsXQ01RN9cz86nIE91RVEJSEbq9o3KcObiXWMsbnWLPL2WTS4sSR2zdJI0BHHrW96T3i61xVCucFRNHneVCK00fWuHYN9Lcjpn9L61BVE71BVq7vSEvVHaJBYk5SlwVq71xVI1lhDsPLpllGIEzWOEfe6LJqAyK)KXr5j6ijFrK0Hvt9o2fRxbHER8PbdPTNGLHcOOxoKIvPRxp7LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUEJOxpUxbHER8PbdPTNGLHcOOxoKIvPRxpSxC9a41RN9cz86nIE91lhLW36zydXlhjnDbmvO8zFPqYttFPE92RxWyJ)fkbJRKBtAFHsWhec4gnioaJP0u1emi(aJryGXo6bJn(xOem(0MYu1ey8PPVeySVEfRxocPHr(tg3KvYzdzWa2RGqVI17PnLPQjghLNOJKeMCaM8EH2lhDsPLpllGIEzWOE9cgFAJmnfcm2zNKmGgj3KvYbFqiGlKbXbymLMQMGbXhymFQNMYaJjUUWCeRsPLa2l0EnmjxeXp2l0EvVHadBkf0axMwAd3YIlXUANnSttFPE9S3O9i86fAV(6fg9md2W(6KKo)2OiHnfdiX(IFSsG9ki0Ry9YrNuA5ZsIpinAG71BVq790MYu1eZzNKmGgj3KvYbJn(xOemoChaLOGK03KaFqiGRhbIdWyknvnbdIpWy(upnLbgREdbgkPxKtIrdNW(cLSlwVq7v9gcm3BtW0A2qHHCImvnbgB8VqjyS7TjyAn4dcbCHiioaJP0u1emi(aJ5t90ugyS6neyU3gnAGzdPyv661ZEHyVq71xVQ3qGrCDH5iPdPTHnKIvPRxX7fI9ki0R6neyexxyosQVPnSHuSkD9kEVqSxV9cTxZ9JPLyi)00R49gz4bgB8Vqjym3soPLQ3qamw9gcY0uiWy3BJgnWGpieW1JbXbymLMQMGbXhymFQNMYaJFtt5ZCpP12iHNk8mknvnb3l0ED0)vc0XCinscpv47fAVQ3qG5EBcMwZGr(tWyJ)fkbJDVnbtRbFqiGlohehGXuAQAcgeFGX8PEAkdmMJoP0YNLfqrVmyuVq790MYu1eJJYt0rsctoatEVq7LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE9SxicgB8VqjyS7TXDhGe4dcbC9aG4amMstvtWG4dmMp1ttzGXVPP8zUN0ABKWtfEgLMQMG7fAVI17BAkFM7TrJgygLMQMG7fAVQ3qG5EBcMwZgkmKtKPQPEH2RVEvVHaJ46cZrs9nTHnKIvPRxX71J7fAVexxyoIvPuFtB6fAVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVE2B0qeVEfe6v9gcmSPuqdCzAPnCllUe7QD2Won9L6v8d9gneXRxO9AUFmTed5NMEfV3idVEfe6fg9md2W(6KKo)2OiHnfdiXgsXQ01R496b6vqOxJ)fkzgSH91jjD(TrrcBkgqIvPmOlGI(E92l0EfRxocPHr(tg3KvYzdzWacgB8VqjyS7TjyAn4dcbCJmqCagtPPQjyq8bgZN6PPmWy1BiWqj9ICsUMSrEwUcLSlwVcc9QEdb2XkHhcwskyi)0Oq5lPKgGfaqSlwVcc9QEdbg3KvYzxSEH2RVEvVHaBStkrxNmmucaaYgsXQ01RN9cKdZum83laQxov6E91R5(X0smKFA6fs9cz861BVq7v9gcSXoPeDDYWqjaai7I1RGqVI1R6neyJDsj66KHHsaaq2fRxO9kwVCesdJ8NSXoPeDDYWqjaaiBidgWEfe6vSE5OtkT8zNu(IaC61BVcc9AUFmTed5NMEfV3idVEH2lX1fMJyvkTeqWyJ)fkbJDVnU7aKaFqienEG4amMstvtWG4dmMp1ttzGXVPP8zU3gnAGzuAQAcUxO96Rx1BiWCVnA0aZUy9ki0R5(X0smKFA6v8EJm861BVq7v9gcm3BJgnWm3B8J96zVqUxO96Rx1BiWiUUWCK0H02WUy9ki0R6neyexxyosQVPnSlwVE7fAVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVE2B04C86fAV(6LJqAyK)KXnzLC2qkwLUEfVxCXRxbHEfR3tBktvtmokprhjjm5am59cTxo6KslFwwaf9YGr96fm24FHsWy3BJ7oajWhecrJlioaJP0u1emi(aJ5t90ugySVEvVHadBkf0axMwAd3YIlXUANnSttFPE9S3OX541RGqVQ3qGHnLcAGltlTHBzXLyxTZg2PPVuVE2B0qeVEH27BAkFM7jT2gj8uHNrPPQj4E92l0EvVHaJ46cZrshsBdBifRsxVI3loVxO9sCDH5iwLshsBtVq7vSEvVHadL0lYjXOHtyFHs2fRxO9kwVVPP8zU3gnAGzuAQAcUxO9YrinmYFY4MSsoBifRsxVI3loVxO96RxocPHr(tgPGH8tJufLWSHuSkD9kEV48Efe6vSE5OtkT8zhbCkl71lySX)cLGXU3g3DasGpieIoAqCagtPPQjyq8bgZN6PPmWyF9QEdbgX1fMJK6BAd7I1RGqV(6LlYgGKR3d9gDVq7DiUiBasYVuOE9Sxi2R3Efe6LlYgGKR3d9c5E92l0EnmjxeXp2l0EpTPmvnXC2jjdOrYnzLCWyJ)fkbJtYVubHsWhecrdzqCagtPPQjyq8bgZN6PPmWyF9QEdbgX1fMJK6BAd7I1l0EfRxo6KslF2raNYYEfe61xVQ3qGDSs4HGLKcgYpnku(skPbybae7I1l0E5OtkT8zhbCkl71BVcc96RxUiBasUEp0B09cT3H4ISbij)sH61ZEHyVE7vqOxUiBasUEp0lK7vqOx1BiW4MSso7I1R3EH2RHj5Ii(XEH27PnLPQjMZojzansUjRKdgB8VqjySithKkiuc(GqiApcehGXuAQAcgeFGX8PEAkdm2xVQ3qGrCDH5iP(M2WUy9cTxX6LJoP0YNDeWPSSxbHE91R6neyhReEiyjPGH8tJcLVKsAawaaXUy9cTxo6KslF2raNYYE92RGqV(6LlYgGKR3d9gDVq7DiUiBasYVuOE9Sxi2R3Efe6LlYgGKR3d9c5Efe6v9gcmUjRKZUy96TxO9AysUiIFSxO9EAtzQAI5StsgqJKBYk5GXg)lucghUATubHsWhecrdrqCagB8VqjySFBMcnsuqs6BsGXuAQAcgeFGpieI2JbXbymLMQMGbXhymFQNMYaJjUUWCeRsP(M20RGqVexxyoI5qABKjH)VxbHEjUUWCeZsaLjH)VxbHEvVHaZVntHgjkij9nj2fRxO9QEdbgX1fMJK6BAd7I1RGqV(6v9gcmUjRKZgsXQ01RN9A8VqjZ)yVigHFIFFs(Lc1l0EvVHaJBYk5SlwVEbJn(xOem292eQHaFqienohehGXg)lucg7FSxeymLMQMGbXh4dcHO9aG4amMstvtWG4dm24FHsW45MsJ)fkL6Y9GX6Y9Y0uiW4GP1VO5c(GpySkYEqCacbCbXbymLMQMGbXhymFQNMYaJvVHaJBYk5SlgySX)cLGXJDsj66KHHsaaqWhecrdIdWyknvnbdIpWyegySJEWyJ)fkbJpTPmvnbgFA6lbglwVQ3qGPAAl5KefKMwlFrvc0jt7VdXUy9cTxX6v9gcmvtBjNKOG00A5lQsGoPnClj2fdm(0gzAkeymFQpr)fd8bHaKbXbymLMQMGbXhySX)cLGXgSH91jjD(TrbmMp1ttzGXQ3qGPAAl5KefKMwlFrvc0jt7VdXCVXp2RN96r9cTx1BiWunTLCsIcstRLVOkb6K2WTKyU34h71ZE9OEH2RVEfRxy0Zmyd7Rts68BJIe2umGe7l(Xkb2l0EfRxJ)fkzgSH91jjD(TrrcBkgqIvPmOlGI(EH2RVEfRxy0Zmyd7Rts68BJIuezA2x8JvcSxbHEHrpZGnSVojPZVnksrKPzdPyv66v8EHCVE7vqOxy0Zmyd7Rts68BJIe2umGeZ9g)yVE2lK7fAVWONzWg2xNK053gfjSPyaj2qkwLUE9Sxi2l0EHrpZGnSVojPZVnksytXasSV4hReyVEbJ5aY1K8Tbi9oqiGl4dcbpcehGXuAQAcgeFGX8PEAkdm2xVN2uMQMyCuEIossyYbyY7fAVI1lhH0Wi)jJBYk5SHmya7vqOx1BiW4MSso7I1R3EH2RVEvVHat10wYjjkinTw(IQeOtM2FhI5EJFS3d9cXEfe6v9gcmvtBjNKOG00A5lQsGoPnCljM7n(XEp0le71BVcc9gkGIE5qkwLUE9SxCXdm24FHsWyokprhj5lIKoSAQ3b(GqaIG4amMstvtWG4dmMp1ttzGX(6v9gcmvtBjNKOG00A5lQsGozA)Di2qkwLUEfVxpIbXEfe6v9gcmvtBjNKOG00A5lQsGoPnClj2qkwLUEfVxpIbXE92l0En3pMwIH8ttVIFO3idVEH2RVE5iKgg5pzCtwjNnKIvPRxX7fN3RGqV(6LJqAyK)Krkyi)0ivrjmBifRsxVI3loVxO9kwVQ3qGDSs4HGLKcgYpnku(skPbybae7I1l0E5OtkT8zhbCkl71BVEbJn(xOemMBjN0s1BiagREdbzAkeyS7TrJgyWhecEmioaJP0u1emi(aJ5t90ugySy9EAtzQAIXN6t0FX6fAV(6LJoP0YNLfqrVmyuVcc9YrinmYFY4MSsoBifRsxVI3loVxbHEfR3tBktvtmoSKJs46lu2l0EfRxo6KslF2raNYYEfe61xVCesdJ8Nmsbd5NgPkkHzdPyv66v8EX59cTxX6v9gcSJvcpeSKuWq(PrHYxsjnalaGyxSEH2lhDsPLp7iGtzzVE71lySX)cLGXU3g3DasGpieW5G4amMstvtWG4dmMp1ttzGX(6LJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUE9Sxi2l0E917PnLPQjghLNOJKeMCaM8Efe6LJqAyK)KXnzLC2qkwLUE9Sxi2R3E92l0En3pMwIH8ttVI3RhHxVq7LJoP0YNLfqrVmyeySX)cLGXU3g3DasGpie8aG4amMstvtWG4dmgHbg7Ohm24FHsW4tBktvtGXNM(sGX(6v9gcmUjRKZgsXQ01R49cXEH2RVEvVHaBStkrxNmmucaaYgsXQ01R49cXEfe6vSEvVHaBStkrxNmmucaaYUy96TxbHEfRx1BiW4MSso7I1RGqVM7htlXq(PPxp7fY41R3EH2RVEfRx1BiWowj8qWssbd5NgfkFjL0aSaaIDX6vqOxZ9JPLyi)00RN9cz861BVq71xVQ3qGrCDH5iPdPTHnKIvPRxX7fihMPy4VxbHEvVHaJ46cZrs9nTHnKIvPRxX7fihMPy4VxVGXN2ittHaJHrVCOi9wdPq57aFqiezG4amMstvtWG4dm24FHsWy3nd1qGX8PEAkdmEOWqorMQM6fAVVnaPN9LcjFKeUOEfVxC94EH2RHj5Ii(XEH27PnLPQjgm6LdfP3AifkFhymhqUMKVnaP3bcbCbFqiGlEG4amMstvtWG4dm24FHsWyfekd1qGX8PEAkdmEOWqorMQM6fAVVnaPN9LcjFKeUOEfVxCHmdI9cTxdtYfr8J9cT3tBktvtmy0lhksV1qku(oWyoGCnjFBasVdec4c(GqaxCbXbymLMQMGbXhySX)cLGXUN0ABKbTneymFQNMYaJhkmKtKPQPEH27Bdq6zFPqYhjHlQxX7fxpU3i6DifRsxVq71WKCre)yVq790MYu1edg9YHI0BnKcLVdmMdixtY3gG07aHaUGpieWnAqCagtPPQjyq8bgZN6PPmWydtYfr8JGXg)lucghqdNKOGmT)oe4dcbCHmioaJP0u1emi(aJ5t90ugySVEjUUWCeRsPLa2RGqVexxyoI5qABKvkXTxbHEjUUWCetFtBKvkXTxV9cTxF9kwVC0jLw(SSak6LbJ6vqOxF9AUFmTed5NME9S3idI9cTxF9EAtzQAIXN6t0FX6vqOxZ9JPLyi)00RN9cz86vqO3tBktvtSYjne1R3EH2RVEpTPmvnX4O8eDKKWKdWK3l0EfRxocPHr(tghLNOJK8frshwn17yxSEfe6vSEpTPmvnX4O8eDKKWKdWK3l0EfRxocPHr(tg3KvYzxSE92R3E92l0E91lhH0Wi)jJBYk5SHuSkD9kEVqgVEfe61C)yAjgYpn9kEVrgE9cTxocPHr(tg3KvYzxSEH2RVE5iKgg5pzKcgYpnsvucZgsXQ01RN9A8VqjZ92eQHye(j(9j5xkuVcc9kwVC0jLw(SJaoLL96TxbHER8PbdPTNGLHcOOxoKIvPRxp7fx861BVq71xVWONzWg2xNK053gfjSPyaj2qkwLUEfVxpQxbHEfRxo6KslFws8bPrdCVEbJn(xOemoChaLOGK03KaFqiGRhbIdWyknvnbdIpWy(upnLbg7RxIRlmhX030gzs4)7vqOxIRlmhXCiTnYKW)3RGqVexxyoIzjGYKW)3RGqVQ3qGPAAl5KefKMwlFrvc0jt7VdXgsXQ01R496rmi2RGqVQ3qGPAAl5KefKMwlFrvc0jTHBjXgsXQ01R496rmi2RGqVM7htlXq(PPxX7nYWRxO9YrinmYFY4MSsoBidgWE92l0E91lhH0Wi)jJBYk5SHuSkD9kEVqgVEfe6LJqAyK)KXnzLC2qgmG96TxbHER8PbdPTNGLHcOOxoKIvPRxp7fx8aJn(xOemMuWq(PrQIsyWhec4crqCagtPPQjyq8bgZN6PPmW4tBktvtmoSKJs46lu2l0E91R5(X0smKFA6v8EJm86fAV(6v9gcSJvcpeSKuWq(PrHYxsjnalaGyxSEfe6vSE5OtkT8zhbCkl71BVcc9YrNuA5ZYcOOxgmQxbHEvVHatvJqW6R7zxSEH2R6neyQAecwFDpBifRsxVE2B041Be96RxokHV1ZWgIxosA6cyQq5Z(sHKNM(s96TxV9cTxF9EAtzQAIXr5j6ijHjhGjVxbHE5iKgg5pzCuEIosYxejDy1uVJnKbdyVE7vqO3kFAWqA7jyzOak6LdPyv661ZEJgVEJOxF9Yrj8TEg2q8YrstxatfkF2xkK800xQxVGXg)lucgZjn5(Y0stxatfkFWhec46XG4amMstvtWG4dmMp1ttzGXN2uMQMyCyjhLW1xOSxO96RxZ9JPLyi)00R49gz41l0E91R6neyhReEiyjPGH8tJcLVKsAawaaXUy9ki0Ry9YrNuA5Zoc4uw2R3Efe6LJoP0YNLfqrVmyuVcc9QEdbMQgHG1x3ZUy9cTx1BiWu1ieS(6E2qkwLUE9SxiJxVr0RVE5Oe(wpdBiE5iPPlGPcLp7lfsEA6l1R3E92l0E917PnLPQjghLNOJKeMCaM8Efe6LJqAyK)KXr5j6ijFrK0Hvt9o2qgmG96TxbHER8PbdPTNGLHcOOxoKIvPRxp7fY41Be96RxokHV1ZWgIxosA6cyQq5Z(sHKNM(s96fm24FHsW4k52K2xOe8bHaU4CqCagtPPQjyq8bgJWaJD0dgB8Vqjy8PnLPQjW4ttFjWyIRlmhXQuQVPn9cG61d0lK614FHsM7TjudXi8t87tYVuOEJOxX6L46cZrSkL6BAtVaOE94EHuVg)luY8p2lIr4N43NKFPq9grV4XIUxi1RdJ0APiZ9ey8PnY0uiWyZHfjLMyId(GqaxpaioaJP0u1emi(aJ5t90ugySVER8PbdPTNGLHcOOxoKIvPRxp71J6vqOxF9QEdb2yNuIUozyOeaaKnKIvPRxp7fihMPy4VxauVCQ096RxZ9JPLyi)00lK6fY41R3EH2R6neyJDsj66KHHsaaq2fRxV96TxbHE91R5(X0smKFA6nIEpTPmvnXmhwKuAIjEVaOEvVHaJ46cZrshsBdBifRsxVr0lm6zH7aOefKK(Me7l(rNCifRYEbq9gndI9kEV4gnE9ki0R5(X0smKFA6nIEpTPmvnXmhwKuAIjEVaOEvVHaJ46cZrs9nTHnKIvPR3i6fg9SWDauIcssFtI9f)OtoKIvzVaOEJMbXEfVxCJgVE92l0EjUUWCeRsPLa2l0E91RVEfRxocPHr(tg3KvYzxSEfe6LJoP0YNDeWPSSxO9kwVCesdJ8Nmsbd5NgPkkHzxSE92RGqVC0jLw(SSak6LbJ61BVq71xVI1lhDsPLp7KYxeGtVcc9kwVQ3qGXnzLC2fRxbHEn3pMwIH8ttVI3BKHxVE7vqOx1BiW4MSsoBifRsxVI3RhOxO9kwVQ3qGn2jLORtggkbaazxmWyJ)fkbJDVnU7aKaFqiGBKbIdWyknvnbdIpWy(upnLbg7Rx1BiWiUUWCKuFtByxSEfe61xVCr2aKC9EO3O7fAVdXfzdqs(Lc1RN9cXE92RGqVCr2aKC9EOxi3R3EH2RHj5Ii(rWyJ)fkbJtYVubHsWhecrJhioaJP0u1emi(aJ5t90ugySVEvVHaJ46cZrs9nTHDX6vqOxF9YfzdqY17HEJUxO9oexKnaj5xkuVE2le71BVcc9YfzdqY17HEHCVE7fAVgMKlI4hbJn(xOemwKPdsfekbFqienUG4amMstvtWG4dmMp1ttzGX(6v9gcmIRlmhj130g2fRxbHE91lxKnajxVh6n6EH27qCr2aKKFPq96zVqSxV9ki0lxKnajxVh6fY96TxO9AysUiIFem24FHsW4WvRLkiuc(Gqi6ObXbySX)cLGX(Tzk0irbjPVjbgtPPQjyq8b(GqiAidIdWyknvnbdIpWy(upnLbgtCDH5iwLs9nTPxbHEjUUWCeZH02itc)FVcc9sCDH5iMLaktc)FVcc9QEdbMFBMcnsuqs6BsSlwVq7v9gcmIRlmhj130g2fRxbHE91R6neyCtwjNnKIvPRxp714FHsM)XErmc)e)(K8lfQxO9QEdbg3KvYzxSE9cgB8VqjyS7Tjudb(GqiApcehGXg)lucg7FSxeymLMQMGbXh4dcHOHiioaJP0u1emi(aJn(xOemEUP04FHsPUCpySUCVmnfcmoyA9lAUGp4d(GXN04kuccHOXlA8Wn6OJgm2VnzLaDGXEq9G9GabCAqiswKO3EXHiQ3sbdnFVb00lodEitrTsyAWz9ouKERHG71HuOET7JuSNG7LlYsGKJ1rbGRK6n6irVrokpP5j4EJlLiVxhG5B4VxpS3h1la(A9cxNLRqzVimAShn96dsE71hU43lRJcaxj1lU4gj6nYr5jnpb3BCPe596amFd)96HEyVpQxa816vbbF1xxVimAShn96Zd92RpCXVxwhfaUsQxCJos0BKJYtAEcU34sjY71by(g(71d9WEFuVa4R1Rcc(QVUEry0ypA61Nh6TxF4IFVSokaCLuV4cXirVrokpP5j4EJlLiVxhG5B4VxpS3h1la(A9cxNLRqzVimAShn96dsE71hU43lRJQJYdQhSheiGtdcrYIe92loer9wkyO57nGMEXzWuWU6hN17qr6TgcUxhsH61UpsXEcUxUilbsowhfaUsQxpos0BKJYtAEcU34sjY71by(g(71d79r9cGVwVW1z5ku2lcJg7rtV(GK3E9fn(9Y6OaWvs9IlUrIEJCuEsZtW9IZMBsb0aKy40Xz9(OEXzZnPaAasmC6mknvnbJZ61x043lRJQJYdQhSheiGtdcrYIe92loer9wkyO57nGMEXzydXrkQ2JZ6DOi9wdb3RdPq9A3hPypb3lxKLajhRJcaxj1leJe9g5O8KMNG7fNn3KcObiXWPJZ69r9IZMBsb0aKy40zuAQAcgN1RpCXVxwhfaUsQxpos0BKJYtAEcUxC2CtkGgGedNooR3h1loBUjfqdqIHtNrPPQjyCwV(Wf)EzDuDuEq9G9GabCAqiswKO3EXHiQ3sbdnFVb00loZqeoR3HI0BneCVoKc1RDFKI9eCVCrwcKCSokaCLuVrhj6nYr5jnpb3loBUjfqdqIHthN17J6fNn3KcObiXWPZO0u1emoRxF4IFVSokaCLuVEuKO3ihLN08eCVXLsK3RdW8n83Rh6H9(OEbWxRxfe8vFD9IWOXE00Rpp0BV(Wf)EzDua4kPE94irVrokpP5j4EJlLiVxhG5B4VxpS3h1la(A9cxNLRqzVimAShn96dsE71hU43lRJcaxj1BKfj6nYr5jnpb3BCPe596amFd)96H9(OEbWxRx46SCfk7fHrJ9OPxFqYBV(Wf)EzDua4kPEXfYrIEJCuEsZtW9gxkrEVoaZ3WFVEOh27J6faFTEvqWx911lcJg7rtV(8qV96dx87L1rbGRK6fxpqKO3ihLN08eCVXLsK3RdW8n83Rh27J6faFTEHRZYvOSxegn2JME9bjV96dx87L1rbGRK6nA8Ie9g5O8KMNG7nUuI8EDaMVH)E9WEFuVa4R1lCDwUcL9IWOXE00Rpi5TxF4IFVSokaCLuVrdXirVrokpP5j4EJlLiVxhG5B4VxpS3h1la(A9cxNLRqzVimAShn96dsE71x043lRJQJYdQhSheiGtdcrYIe92loer9wkyO57nGMEXzUhN17qr6TgcUxhsH61UpsXEcUxUilbsowhfaUsQxCXls0BKJYtAEcU34sjY71by(g(71d9WEFuVa4R1Rcc(QVUEry0ypA61Nh6TxF4IFVSokaCLuV4IBKO3ihLN08eCVXLsK3RdW8n83Rh6H9(OEbWxRxfe8vFD9IWOXE00Rpp0BV(Wf)EzDua4kPEXnYIe9g5O8KMNG7nUuI8EDaMVH)E9WEFuVa4R1lCDwUcL9IWOXE00Rpi5TxF4IFVSoQokpOEWEqGaoniejls0BV4qe1BPGHMV3aA6fNPIShN17qr6TgcUxhsH61UpsXEcUxUilbsowhfaUsQxCX5rIEJCuEsZtW9gxkrEVoaZ3WFVEyVpQxa816fUolxHYEry0ypA61hK82RpiJFVSokaCLuV46bIe9g5O8KMNG7nUuI8EDaMVH)E9WEFuVa4R1lCDwUcL9IWOXE00Rpi5TxF4IFVSoQokCAkyO5j4EX59A8VqzV6Y9owhfym2GcLMaJXP6fFM2so1BKeZTG7OWP6nscItkQ00B0qeG9gnErJxhvhfovVrUilbsUirhfovV4KE9GHHj4EJrAB6fFKPW6OWP6fN0BKlYsGeCVVnaPxwHE5MJC9(OE5aY1K8Tbi9owhfovV4KE9GqkOtcU3BMeNCoBaS3tBktvtUE9vmIbWEXg6u6EBC3bi1lor8EXg6K5EBC3bi5L1rHt1loPxp4tub3l2qCZ9vcSxpOJ9I6Tc9wpoZ17lI61)GsG9gjjxxyoI1rHt1loP3i5SJuVrokprhPEFruVXy1uVRxRxD9VM6vbnuVbnH)svt96Rc9ci62RidoXzFVIQV3671vkx9BjHUonG96VEr9IVi59GXrVr0BKtAY9LP71dwxatfkFa2B94m4EDhlmVSoQokJ)fkDmSH4ifv7pCSs4HGLoSAQ31rz8VqPJHnehPOAFehGKccLhRugqJshLX)cLog2qCKIQ9rCas(h7fbqDLKKdFax8ayfo4J46cZrm9nTrMe(FbbIRlmhXQuQVPnccexxyoIvPuf9IeeiUUWCeZsaLjH)3BhLX)cLog2qCKIQ9rCas(h7fbWkCWhX1fMJy6BAJmj8)ccexxyoIvPuFtBeeiUUWCeRsPk6fjiqCDH5iMLaktc)VxOydDYWL5FSxeuXWg6KfnZ)yVOokJ)fkDmSH4ifv7J4aKCVnHAiawHdIn3KcObiXunTLCsIcstRLVOkb6eeeJJoP0YNLfqrVmyKGGyomsRLVnaP3XCVnbtRpGRGGyVPP8zP93HCsvtBjNyuAQAcUJY4FHshdBiosr1(ioaj3BJ7oajawHdZnPaAasmvtBjNKOG00A5lQsGoOC0jLw(SSak6LbJG6WiTw(2aKEhZ92emT(aUDuDu4u9gjj(j(9j4EPtAaS3VuOEFruVg)rtVLRx70kTPQjwhLX)cLUdoK2gPkzkDug)lu6oCAtzQAcGPPqhkN0qeapn9Lo4WiTw(2aKEhZ92emTwCCH6tS30u(m3BJgnWmknvnbli8MMYN5EsRTrcpv4zuAQAc2RGGdJ0A5Bdq6Dm3BtW0AXJUJY4FHsxehG0PnLPQjaMMcDOCsUMStcGNM(shCyKwlFBasVJ5EBc1qIJBhLX)cLUioajvAC0CSsGaSch8jghDsPLpllGIEzWibbX4iKgg5pzCuEIosYxejDy1uVJDX8cv9gcmUjRKZUyDug)lu6I4aKWqFHsawHdQ3qGXnzLC2fRJY4FHsxehG0PnLPQjaMMcDGJYt0rsctoatoapn9Loe0i04ZxLpnyiT9eSmuaf9YHuSkD4KOXdNWrinmYFY4O8eDKKVis6WQPEhBifRsNxpe3OXZR4bncn(8v5tdgsBpbldfqrVCifRshojAiIt8HlEaO30u(Sk52K2xOKrPPQjyV4eFCucFRNHneVCK00fWuHYN9Lcjpn9L8It4iKgg5pzCtwjNnKIvPZRhIRhapVccCesdJ8NmUjRKZgsXQ0jELpnyiT9eSmuaf9YHuSkDccCesdJ8Nmokprhj5lIKoSAQ3XgsXQ0jELpnyiT9eSmuaf9YHuSkDccIXrNuA5ZYcOOxgmQJY4FHsxehG0PnLPQjaMMcDGdl5OeU(cLa800x6GpXOi9wyyemJuWaCitlrdCAjNee4iKgg5pzKcgGdzAjAGtl5eBifRsNN46X4bvmocPHr(tgPGb4qMwIg40soXgYGb0RGahDsPLp7iGtzzhLX)cLUioaPRJK1tkamnf6aPGb4qMwIg40sobWkCGJqAyK)KXnzLC2qkwLopJgpON2uMQMyCuEIossyYbyYfe4iKgg5pzCuEIosYxejDy1uVJnKIvPZZOXRJY4FHsxehG01rY6jfaMMcDWHUAn9FLaLZvfqawHdCesdJ8NmUjRKZgsXQ05Phd90MYu1eJJYt0rsctoatUGahH0Wi)jJJYt0rs(IiPdRM6DSHuSkDE6XDug)lu6I4aKUoswpPaW0uOdv64Z9nvnjJ0RL)vrctNfNayfoOEdbg3KvYzxSokCQEn(xO0fXbiDDKSEsXbqNg9Ud)u5r6XfGv4Gy)u5r6z4Yezoj2G4mlbeQpX(PYJ0ZIMjYCsSbXzwcOGGy)u5r6zrZgYGbuYrinmYF6vqq9gcmUjRKZUyccCesdJ8NmUjRKZgsXQ0HtWfpX)PYJ0ZWLXrinmYFYGVJ9fkHkghDsPLp7iGtzPGahDsPLpllGIEzWiON2uMQMyCuEIossyYbyYHYrinmYFY4O8eDKKVis6WQPEh7IjiOEdb2XkHhcwskyi)0Oq5lPKgGfaqSlMGqOak6LdPyv68mA86OWP614FHsxehG01rY6jfhaDA07o8tLhPpAawHdI9tLhPNfntK5KydIZSeqO(e7NkpspdxMiZjXgeNzjGccI9tLhPNHlBidgqjhH0Wi)PxbHFQ8i9mCzImNeBqCMLac9NkpsplAMiZjXgeNzjGqf7Nkpspdx2qgmGsocPHr(tbb1BiW4MSso7IjiWrinmYFY4MSsoBifRshobx8e)NkpsplAghH0Wi)jd(o2xOeQyC0jLw(SJaoLLccC0jLw(SSak6LbJGEAtzQAIXr5j6ijHjhGjhkhH0Wi)jJJYt0rs(IiPdRM6DSlMGG6neyhReEiyjPGH8tJcLVKsAawaaXUyccHcOOxoKIvPZZOXRJY4FHsxehG01rY6jfhaRWb1BiW4MSso7IjiWrNuA5ZYcOOxgmc6PnLPQjghLNOJKeMCaMCOCesdJ8Nmokprhj5lIKoSAQ3XUyqfJJqAyK)KXnzLC2fdQpFQ3qGrCDH5iP(M2WgsXQ0joU4jiOEdbgX1fMJKoK2g2qkwLoXXfpVqfBUjfqdqIPAAl5KefKMwlFrvc0jim3KcObiXunTLCsIcstRLVOkb6G6t9gcmvtBjNKOG00A5lQsGozA)DiM7n(rXHSGG6neyQM2sojrbPP1YxuLaDsB4wsm3B8JIdzVEfeuVHa7yLWdbljfmKFAuO8LusdWcai2ftqiuaf9YHuSkDEgnEDug)lu6I4aKMBkn(xOuQl3dW0uOdgIaO7NI)hWfGv4WPnLPQjw5KgI6Om(xO0fXbin3uA8VqPuxUhGPPqhGhYuuReMga6(P4)bCbyfom3KcObiX(sH8JMucpKPOwjmnmksVfggb3rz8VqPlIdqAUP04FHsPUCpattHoOIShGUFk(FaxawHdZnPaAasmvtBjNKOG00A5lQsGogfP3cdJG7Om(xO0fXbin3uA8VqPuxUhGPPqhCFhvhLX)cLoMHOdN2uMQMayAk0b4HmfP)sRLbtRLOqaGNM(sh8PEdb2xkKF0Ks4Hmf1kHPHnKIvPZtGCyMIH)iWJHRGG6neyFPq(rtkHhYuuReMg2qkwLopn(xOK5EBc1qmc)e)(K8lfkc8y4c1hX1fMJyvk130gbbIRlmhXCiTnYKW)liqCDH5iMLaktc)VxVqvVHa7lfYpAsj8qMIALW0WUyqNBsb0aKyFPq(rtkHhYuuReMggfP3cdJG7Om(xO0XmefXbiXr5j6ijFrK0Hvt9oawHd(oTPmvnX4O8eDKKWKdWKdvmocPHr(tg3KvYzdzWakiOEdbg3KvYzxmVqn3pMwIH8tJNqepO(uVHaJ46cZrs9nTHnKIvPtCpwqq9gcmIRlmhjDiTnSHuSkDI7XEH6tS5MuanajMQPTKtsuqAAT8fvjqNGG6neyQM2sojrbPP1YxuLaDY0(7qm3B8JIdzbb1BiWunTLCsIcstRLVOkb6K2WTKyU34hfhYEfecfqrVCifRsNN4IxhLX)cLoMHOioaj3nd1qaKdixtY3gG07oGlaRWHHcd5ezQAc6Bdq6zFPqYhjHlsCC9iCIdJ0A5Bdq6DrmKIvPdQpIRlmhXQuAjGccdPyv68eihMPy43BhLX)cLoMHOioaj3BtW0AawHdQ3qG5EBcMwZgkmKtKPQjO(CyKwlFBasVJ5EBcMw7jKfeeBUjfqdqI9Lc5hnPeEitrTsyAyuKElmmc2luFIn3KcObiX0aYTXCYGMOVsGsG6sbZrmksVfggbli8Lc5HEOhbrXvVHaZ92emTMnKIvPlIO9cnuaf9YHuSkDIdXokJ)fkDmdrrCasU3MGP1aSchMBsb0aKyFPq(rtkHhYuuReMggfP3cdJGH6WiTw(2aKEhZ92emTw8dqgQpXuVHa7lfYpAsj8qMIALW0WUyqvVHaZ92emTMnuyiNitvtcc(oTPmvnXGhYuK(lTwgmTwIcbO(uVHaZ92emTMnKIvPZtili4WiTw(2aKEhZ92emTw8OH(MMYN5EsRTrcpv4zuAQAcgQ6neyU3MGP1SHuSkDEcrVE92rz8VqPJzikIdq60MYu1eattHo4EBcMwl9JYxgmTwIcbaEA6lDWC)yAjgYpnI7bWdN4dx8aqQ3qG9Lc5hnPeEitrTsyAyU34h9It8PEdbM7TjyAnBifRshacYEOdJ0APiZ9KxCIpy0Zc3bqjkij9nj2qkwLoaee9cv9gcm3BtW0A2fRJY4FHshZquehGK7TXDhGeaRWHtBktvtm4HmfP)sRLbtRLOqa6PnLPQjM7TjyAT0pkFzW0Ajkeee8PEdbMQPTKtsuqAAT8fvjqNmT)oeZ9g)O4qwqq9gcmvtBjNKOG00A5lQsGoPnCljM7n(rXHSxOomsRLVnaP3XCVnbtR90J6Om(xO0XmefXbizWg2xNK053gfaYbKRj5Bdq6DhWfGv4GyFXpwjqOIz8VqjZGnSVojPZVnksytXasSkLbDbu0liaJEMbByFDssNFBuKWMIbKyU34h9eYqHrpZGnSVojPZVnksytXasSHuSkDEc5okJ)fkDmdrrCaskiugQHaihqUMKVnaP3DaxawHddfgYjYu1e03gG0Z(sHKpscxK4(W1JIWNdJ0A5Bdq6Dm3BtOgcaHldIE96HomsRLVnaP3fXqkwLoO(8XrinmYFY4MSsoBidgqO(oTPmvnX4O8eDKKWKdWKliWrinmYFY4O8eDKKVis6WQPEhBidgqbbX4OtkT8zzbu0ldg5vqWHrAT8Tbi9oM7Tjud5PpicG8HBeVPP8zV)kLkiu6yuAQAc2RxbbFexxyoIvP0H02ii4J46cZrSkLQOxKGaX1fMJyvk130gVqf7nnLpZHUAjkiFrKmGgY9mknvnbliOEdbg2ukObUmT0gULfxID1oByNM(sIFiAiINxO(CyKwlFBasVJ5EBc1qEIlEaiF4gXBAkF27VsPccLogLMQMG96fQ5(X0smKFAehI4HtuVHaZ92emTMnKIvPda5XEH6tm1BiWowj8qWssbd5NgfkFjL0aSaaIDXeeiUUWCeRsPdPTrqqmo6KslF2raNYsVqnmjxeXp6TJY4FHshZquehGuanCsIcY0(7qaSchmmjxeXp2rz8VqPJzikIdqAStkrxNmmucaacWkCq9gcmUjRKZUyDug)lu6ygII4aK4KMCFzAPPlGPcLpaRWHtBktvtmoSKJs46luc1N6neyU3MGP1SlMGG5(X0smKFAehI45fQyQ3qG5qA3xCIDXGkM6neyCtwjNDXG6tmo6KslFwwaf9YGrccN2uMQMyCuEIossyYbyYfe4iKgg5pzCuEIosYxejDy1uVJDXeeQ8PbdPTNGLHcOOxoKIvPZZOXlcFCucFRNHneVCK00fWuHYN9Lcjpn9L86TJY4FHshZquehGuLCBs7lucWkC40MYu1eJdl5OeU(cLq9PEdbM7TjyAn7IjiyUFmTed5NgXHiEEHkM6neyoK29fNyxmOIPEdbg3KvYzxmO(eJJoP0YNLfqrVmyKGWPnLPQjghLNOJKeMCaMCbbocPHr(tghLNOJK8frshwn17yxmbHkFAWqA7jyzOak6LdPyv68KJqAyK)KXr5j6ijFrK0Hvt9o2qkwLUi8ybHkFAWqA7jyzOak6LdPyv68qpexpaEEcz8IWhhLW36zydXlhjnDbmvO8zFPqYttFjVE7Om(xO0XmefXbirkyi)0ivrjmaRWHkFAWqA7jyzOak6LdPyv68exiki4t9gcmSPuqdCzAPnCllUe7QD2Won9L8mAiINGG6neyytPGg4Y0sB4wwCj2v7SHDA6lj(HOHiEEHQEdbM7TjyAn7IbLJqAyK)KXnzLC2qkwLoXHiEDug)lu6ygII4aKCpP12idABiaYbKRj5Bdq6DhWfGv4WqHHCImvnb9lfs(ijCrIJleH6WiTw(2aKEhZ92eQH80JGAysUiIFeQp1BiW4MSsoBifRsN44INGGyQ3qGXnzLC2fZBhLX)cLoMHOioaPWDauIcssFtcGv4aX1fMJyvkTeqOgMKlI4hHQEdbg2ukObUmT0gULfxID1oByNM(sEgneXdQpy0Zmyd7Rts68BJIe2umGe7l(XkbkiighDsPLplj(G0ObwqWHrAT8Tbi9oXJ2BhLX)cLoMHOioaj3BtW0AawHdQ3qGHs6f5Ky0WjSVqj7Ib1N6neyU3MGP1SHcd5ezQAsqWC)yAjgYpnIhz45TJY4FHshZquehGK7TjyAnaRWbo6KslFwwaf9YGrq9DAtzQAIXr5j6ijHjhGjxqGJqAyK)KXnzLC2ftqq9gcmUjRKZUyEHYrinmYFY4O8eDKKVis6WQPEhBifRsNNa5Wmfd)aiovAFM7htlXq(PXdHiEEHQEdbM7TjyAnBifRsNNEuhLX)cLoMHOioaj3BJ7oajawHdC0jLw(SSak6LbJG670MYu1eJJYt0rsctoatUGahH0Wi)jJBYk5SlMGG6neyCtwjNDX8cLJqAyK)KXr5j6ijFrK0Hvt9o2qkwLop9yOQ3qG5EBcMwZUyqjUUWCeRsPLa2rz8VqPJzikIdqY924UdqcGv4G6neyOKErojxt2iplxHs2ftqWNyU3MqneZWKCre)OGGp1BiW4MSsoBifRsNNqeQ6neyCtwjNDXee8PEdb2yNuIUozyOeaaKnKIvPZtGCyMIHFaeNkTpZ9JPLyi)04HqgpVqvVHaBStkrxNmmucaaYUyE9c90MYu1eZ92emTw6hLVmyATefcqDyKwlFBasVJ5EBcMw7jK9c1NyZnPaAasSVui)OjLWdzkQvctdJI0BHHrWccomsRLVnaP3XCVnbtR9eYE7Om(xO0XmefXbiLKFPccLaSch8rCDH5iwLslbekhH0Wi)jJBYk5SHuSkDIdr8ee8XfzdqYDiAOdXfzdqs(Lc5je9kiWfzdqYDaYEHAysUiIFSJY4FHshZquehGKithKkiucWkCWhX1fMJyvkTeqOCesdJ8NmUjRKZgsXQ0joeXtqWhxKnaj3HOHoexKnaj5xkKNq0RGaxKnaj3bi7fQHj5Ii(XokJ)fkDmdrrCasHRwlvqOeGv4GpIRlmhXQuAjGq5iKgg5pzCtwjNnKIvPtCiINGGpUiBasUdrdDiUiBasYVuipHOxbbUiBasUdq2ludtYfr8JDug)lu6ygII4aK8BZuOrIcssFtQJY4FHshZquehG0PnLPQjaMMcDW92eQHKvkDiTna800x6GdJ0A5Bdq6Dm3BtOgsCpkIGgHgFkM7Pbq5PPVKhgnEEJiOrOXN6neyU3g3Dasssbd5NgfkFPdPTH5EJF0d9iVDug)lu6ygII4aK8p2lcGv4aX1fMJy6BAJmj8)ccexxyoIzjGYKW)d90MYu1eRCsUMStsqq9gcmIRlmhjDiTnSHuSkDEA8VqjZ92eQHye(j(9j5xkeu1BiWiUUWCK0H02WUyccexxyoIvP0H02avStBktvtm3BtOgswP0H02iiOEdbg3KvYzdPyv6804FHsM7TjudXi8t87tYVuiOIDAtzQAIvojxt2jbv9gcmUjRKZgsXQ05jHFIFFs(Lcbv9gcmUjRKZUyccQ3qGn2jLORtggkbaazxmOomsRLIm3tIJhZJH6ZHrAT8Tbi9oppazbbXEtt5ZCORwIcYxejdOHCpJstvtWEfee70MYu1eRCsUMStcQ6neyCtwjNnKIvPtCc)e)(K8lfQJY4FHshZquehGK7Tjud1rz8VqPJzikIdqAUP04FHsPUCpattHoemT(fn3oQokJ)fkDmvK9hg7Ks01jddLaaGaSchuVHaJBYk5SlwhLX)cLoMkY(ioaPtBktvtamnf6aFQpr)fdGNM(shet9gcmvtBjNKOG00A5lQsGozA)Di2fdQyQ3qGPAAl5KefKMwlFrvc0jTHBjXUyDug)lu6yQi7J4aKmyd7Rts68BJca5aY1K8Tbi9Ud4cWkCq9gcmvtBjNKOG00A5lQsGozA)DiM7n(rp9iOQ3qGPAAl5KefKMwlFrvc0jTHBjXCVXp6Phb1NyWONzWg2xNK053gfjSPyaj2x8JvceQyg)luYmyd7Rts68BJIe2umGeRszqxaf9q9jgm6zgSH91jjD(TrrkImn7l(XkbkiaJEMbByFDssNFBuKIitZgsXQ0joK9kiaJEMbByFDssNFBuKWMIbKyU34h9eYqHrpZGnSVojPZVnksytXasSHuSkDEcrOWONzWg2xNK053gfjSPyaj2x8Jvc0BhLX)cLoMkY(ioajokprhj5lIKoSAQ3bWkCW3PnLPQjghLNOJKeMCaMCOIXrinmYFY4MSsoBidgqbb1BiW4MSso7I5fQp1BiWunTLCsIcstRLVOkb6KP93HyU34hparbb1BiWunTLCsIcstRLVOkb6K2WTKyU34hparVccHcOOxoKIvPZtCXRJY4FHshtfzFehGe3soPLQ3qaGPPqhCVnA0adWkCWN6neyQM2sojrbPP1YxuLaDY0(7qSHuSkDI7rmikiOEdbMQPTKtsuqAAT8fvjqN0gULeBifRsN4EedIEHAUFmTed5NgXpez4b1hhH0Wi)jJBYk5SHuSkDIJZfe8XrinmYFYifmKFAKQOeMnKIvPtCCouXuVHa7yLWdbljfmKFAuO8LusdWcai2fdkhDsPLp7iGtzPxVDug)lu6yQi7J4aKCVnU7aKayfoi2PnLPQjgFQpr)fdQpo6KslFwwaf9YGrccCesdJ8NmUjRKZgsXQ0jooxqqStBktvtmoSKJs46lucvmo6KslF2raNYsbbFCesdJ8Nmsbd5NgPkkHzdPyv6ehNdvm1BiWowj8qWssbd5NgfkFjL0aSaaIDXGYrNuA5Zoc4uw61BhLX)cLoMkY(ioaj3BJ7oajawHd(4iKgg5pzCuEIosYxejDy1uVJnKIvPZtic13PnLPQjghLNOJKeMCaMCbbocPHr(tg3KvYzdPyv68eIE9c1C)yAjgYpnI7r4bLJoP0YNLfqrVmyuhLX)cLoMkY(ioaPtBktvtamnf6am6LdfP3AifkFhapn9Lo4t9gcmUjRKZgsXQ0joeH6t9gcSXoPeDDYWqjaaiBifRsN4quqqm1BiWg7Ks01jddLaaGSlMxbbXuVHaJBYk5SlMGG5(X0smKFA8eY45fQpXuVHa7yLWdbljfmKFAuO8LusdWcai2ftqWC)yAjgYpnEcz88c1N6neyexxyos6qABydPyv6ehihMPy4xqq9gcmIRlmhj130g2qkwLoXbYHzkg(92rz8VqPJPISpIdqYDZqnea5aY1K8Tbi9Ud4cWkCyOWqorMQMG(2aKE2xkK8rs4IehxpgQHj5Ii(rON2uMQMyWOxouKERHuO8DDug)lu6yQi7J4aKuqOmudbqoGCnjFBasV7aUaSchgkmKtKPQjOVnaPN9LcjFKeUiXXfYmic1WKCre)i0tBktvtmy0lhksV1qku(UokJ)fkDmvK9rCasUN0ABKbTnea5aY1K8Tbi9Ud4cWkCyOWqorMQMG(2aKE2xkK8rs4IehxpoIHuSkDqnmjxeXpc90MYu1edg9YHI0BnKcLVRJY4FHshtfzFehGuanCsIcY0(7qaSchmmjxeXp2rz8VqPJPISpIdqkChaLOGK03Kayfo4J46cZrSkLwcOGaX1fMJyoK2gzLsCfeiUUWCetFtBKvkX1luFIXrNuA5ZYcOOxgmsqWN5(X0smKFA8mYGiuFN2uMQMy8P(e9xmbbZ9JPLyi)04jKXtq40MYu1eRCsdrEH670MYu1eJJYt0rsctoatouX4iKgg5pzCuEIosYxejDy1uVJDXeee70MYu1eJJYt0rsctoatouX4iKgg5pzCtwjNDX861luFCesdJ8NmUjRKZgsXQ0joKXtqWC)yAjgYpnIhz4bLJqAyK)KXnzLC2fdQpocPHr(tgPGH8tJufLWSHuSkDEA8VqjZ92eQHye(j(9j5xkKGGyC0jLw(SJaoLLEfeQ8PbdPTNGLHcOOxoKIvPZtCXZluFWONzWg2xNK053gfjSPyaj2qkwLoX9ibbX4OtkT8zjXhKgnWE7Om(xO0Xur2hXbirkyi)0ivrjmaRWbFexxyoIPVPnYKW)liqCDH5iMdPTrMe(FbbIRlmhXSeqzs4)feuVHat10wYjjkinTw(IQeOtM2FhInKIvPtCpIbrbb1BiWunTLCsIcstRLVOkb6K2WTKydPyv6e3JyquqWC)yAjgYpnIhz4bLJqAyK)KXnzLC2qgmGEH6JJqAyK)KXnzLC2qkwLoXHmEccCesdJ8NmUjRKZgYGb0RGqLpnyiT9eSmuaf9YHuSkDEIlEDug)lu6yQi7J4aK4KMCFzAPPlGPcLpaRWHtBktvtmoSKJs46luc1N5(X0smKFAepYWdQp1BiWowj8qWssbd5NgfkFjL0aSaaIDXeeeJJoP0YNDeWPS0RGahDsPLpllGIEzWibb1BiWu1ieS(6E2fdQ6neyQAecwFDpBifRsNNrJxe(4Oe(wpdBiE5iPPlGPcLp7lfsEA6l51luFN2uMQMyCuEIossyYbyYfe4iKgg5pzCuEIosYxejDy1uVJnKbdOxbHkFAWqA7jyzOak6LdPyv68mA8IWhhLW36zydXlhjnDbmvO8zFPqYttFjVDug)lu6yQi7J4aKQKBtAFHsawHdN2uMQMyCyjhLW1xOeQpZ9JPLyi)0iEKHhuFQ3qGDSs4HGLKcgYpnku(skPbybae7IjiighDsPLp7iGtzPxbbo6KslFwwaf9YGrccQ3qGPQriy919Slgu1BiWu1ieS(6E2qkwLopHmEr4JJs4B9mSH4LJKMUaMku(SVui5PPVKxVq9DAtzQAIXr5j6ijHjhGjxqGJqAyK)KXr5j6ijFrK0Hvt9o2qgmGEfeQ8PbdPTNGLHcOOxoKIvPZtiJxe(4Oe(wpdBiE5iPPlGPcLp7lfsEA6l5TJY4FHshtfzFehG0PnLPQjaMMcDWCyrsPjM4a800x6aX1fMJyvk130gaKhWdn(xOK5EBc1qmc)e)(K8lfkcXiUUWCeRsP(M2aG8yp04FHsM)XErmc)e)(K8lfkc8yr7HomsRLIm3tDug)lu6yQi7J4aKCVnU7aKayfo4RYNgmK2EcwgkGIE5qkwLop9ibbFQ3qGn2jLORtggkbaazdPyv68eihMPy4haXPs7ZC)yAjgYpnEiKXZlu1BiWg7Ks01jddLaaGSlMxVcc(m3pMwIH8tteN2uMQMyMdlsknXehaPEdbgX1fMJKoK2g2qkwLUiGrplChaLOGK03KyFXp6KdPyvcGIMbrXXnA8eem3pMwIH8tteN2uMQMyMdlsknXehaPEdbgX1fMJK6BAdBifRsxeWONfUdGsuqs6BsSV4hDYHuSkbqrZGO44gnEEHsCDH5iwLslbeQpFIXrinmYFY4MSso7IjiWrNuA5Zoc4uwcvmocPHr(tgPGH8tJufLWSlMxbbo6KslFwwaf9YGrEH6tmo6KslF2jLViahbbXuVHaJBYk5SlMGG5(X0smKFAepYWZRGG6neyCtwjNnKIvPtCpauXuVHaBStkrxNmmucaaYUyDug)lu6yQi7J4aKsYVubHsawHd(uVHaJ46cZrs9nTHDXee8XfzdqYDiAOdXfzdqs(Lc5je9kiWfzdqYDaYEHAysUiIFSJY4FHshtfzFehGKithKkiucWkCWN6neyexxyosQVPnSlMGGpUiBasUdrdDiUiBasYVuipHOxbbUiBasUdq2ludtYfr8JDug)lu6yQi7J4aKcxTwQGqjaRWbFQ3qGrCDH5iP(M2WUycc(4ISbi5oen0H4ISbij)sH8eIEfe4ISbi5oazVqnmjxeXp2rz8VqPJPISpIdqYVntHgjkij9nPokJ)fkDmvK9rCasU3MqneaRWbIRlmhXQuQVPnccexxyoI5qABKjH)xqG46cZrmlbuMe(Fbb1BiW8BZuOrIcssFtIDXGQEdbgX1fMJK6BAd7Iji4t9gcmUjRKZgsXQ05PX)cLm)J9Iye(j(9j5xkeu1BiW4MSso7I5TJY4FHshtfzFehGK)XErDug)lu6yQi7J4aKMBkn(xOuQl3dW0uOdbtRFrZTJQJY4FHshdEitrTsyAoCAtzQAcGPPqhCwGKpsEDK0HrAnapn9Lo4t9gcSVui)OjLWdzkQvctdBifRsN4a5Wmfd)rGhdxO(iUUWCeRsPk6fjiqCDH5iwLshsBJGaX1fMJy6BAJmj8)EfeuVHa7lfYpAsj8qMIALW0WgsXQ0jUX)cLm3BtOgIr4N43NKFPqrGhdxO(iUUWCeRsP(M2iiqCDH5iMdPTrMe(FbbIRlmhXSeqzs4)96vqqm1BiW(sH8JMucpKPOwjmnSlwhLX)cLog8qMIALW0eXbi5EBC3bibWkCWNyN2uMQMyolqYhjVos6WiTwqWN6neyJDsj66KHHsaaq2qkwLopbYHzkg(bqCQ0(m3pMwIH8tJhcz88cv9gcSXoPeDDYWqjaai7I51RGG5(X0smKFAepYWRJY4FHshdEitrTsyAI4aK4O8eDKKVis6WQPEhaRWbFN2uMQMyCuEIossyYbyYHw5tdgsBpbldfqrVCifRsN44cz8GkghH0Wi)jJBYk5SHmyafeuVHaJBYk5SlMxOM7htlXq(PXtpcpO(uVHaJ46cZrs9nTHnKIvPtCCXtqq9gcmIRlmhjDiTnSHuSkDIJlEEfecfqrVCifRsNN4IxhLX)cLog8qMIALW0eXbizWg2xNK053gfaYbKRj5Bdq6DhWfGv4GyWONzWg2xNK053gfjSPyaj2x8JvceQyg)luYmyd7Rts68BJIe2umGeRszqxaf9q9jgm6zgSH91jjD(TrrkImn7l(XkbkiaJEMbByFDssNFBuKIitZgsXQ0joe9kiaJEMbByFDssNFBuKWMIbKyU34h9eYqHrpZGnSVojPZVnksytXasSHuSkDEczOWONzWg2xNK053gfjSPyaj2x8JvcSJY4FHshdEitrTsyAI4aKuqOmudbqoGCnjFBasV7aUaSchgkmKtKPQjOVnaPN9LcjFKeUiXXnAO(8PEdbg3KvYzdPyv6ehIq9PEdb2yNuIUozyOeaaKnKIvPtCikiiM6neyJDsj66KHHsaaq2fZRGGyQ3qGXnzLC2ftqWC)yAjgYpnEcz88c1NyQ3qGDSs4HGLKcgYpnku(skPbybae7IjiyUFmTed5NgpHmEEHAysUiIF0BhLX)cLog8qMIALW0eXbi5UzOgcGCa5As(2aKE3bCbyfomuyiNitvtqFBasp7lfs(ijCrIJB0q95t9gcmUjRKZgsXQ0joeH6t9gcSXoPeDDYWqjaaiBifRsN4quqqm1BiWg7Ks01jddLaaGSlMxbbXuVHaJBYk5SlMGG5(X0smKFA8eY45fQpXuVHa7yLWdbljfmKFAuO8LusdWcai2ftqWC)yAjgYpnEcz88c1WKCre)O3okJ)fkDm4Hmf1kHPjIdqY9KwBJmOTHaihqUMKVnaP3DaxawHddfgYjYu1e03gG0Z(sHKpscxK446Xq95t9gcmUjRKZgsXQ0joeH6t9gcSXoPeDDYWqjaaiBifRsN4quqqm1BiWg7Ks01jddLaaGSlMxbbXuVHaJBYk5SlMGG5(X0smKFA8eY45fQpXuVHa7yLWdbljfmKFAuO8LusdWcai2ftqWC)yAjgYpnEcz88c1WKCre)O3okJ)fkDm4Hmf1kHPjIdqkGgojrbzA)DiawHdgMKlI4h7Om(xO0XGhYuuReMMioaPXoPeDDYWqjaaiaRWb1BiW4MSso7I1rz8VqPJbpKPOwjmnrCasKcgYpnsvucdWkCWNp1BiWiUUWCK0H02WgsXQ0joU4jiOEdbgX1fMJK6BAdBifRsN44INxOCesdJ8NmUjRKZgsXQ0joKXZRGahH0Wi)jJBYk5SHmya7Om(xO0XGhYuuReMMioajoPj3xMwA6cyQq5dWkC40MYu1eJdl5OeU(cLq95t9gcSJvcpeSKuWq(PrHYxsjnalaGyxmbbX4OtkT8zhbCkl9kiWrNuA5ZYcOOxgmsq40MYu1eRCsdrccQ3qGPQriy919Slgu1BiWu1ieS(6E2qkwLopJgVi8Xrj8TEg2q8YrstxatfkF2xkK800xYRxOIPEdbg3KvYzxmO(eJJoP0YNLfqrVmyKGahH0Wi)jJJYt0rs(IiPdRM6DSlMGqLpnyiT9eSmuaf9YHuSkDEYrinmYFY4O8eDKKVis6WQPEhBifRsxeESGqLpnyiT9eSmuaf9YHuSkDEOhIRhappJgVi8Xrj8TEg2q8YrstxatfkF2xkK800xYR3okJ)fkDm4Hmf1kHPjIdqQsUnP9fkbyfoCAtzQAIXHLCucxFHsO(8PEdb2XkHhcwskyi)0Oq5lPKgGfaqSlMGGyC0jLw(SJaoLLEfe4OtkT8zzbu0ldgjiCAtzQAIvoPHibb1BiWu1ieS(6E2fdQ6neyQAecwFDpBifRsNNqgVi8Xrj8TEg2q8YrstxatfkF2xkK800xYRxOIPEdbg3KvYzxmO(eJJoP0YNLfqrVmyKGahH0Wi)jJJYt0rs(IiPdRM6DSlMGqLpnyiT9eSmuaf9YHuSkDEYrinmYFY4O8eDKKVis6WQPEhBifRsxeESGqLpnyiT9eSmuaf9YHuSkDEOhIRhappHmEr4JJs4B9mSH4LJKMUaMku(SVui5PPVKxVDug)lu6yWdzkQvcttehG0PnLPQjaMMcDWzNKmGgj3KvYb4PPV0bFIXrinmYFY4MSsoBidgqbbXoTPmvnX4O8eDKKWKdWKdLJoP0YNLfqrVmyK3okJ)fkDm4Hmf1kHPjIdqkChaLOGK03KayfoqCDH5iwLslbeQHj5Ii(rO(GrpZGnSVojPZVnksytXasSV4hReOGGyC0jLw(SK4dsJgyVqpTPmvnXC2jjdOrYnzL8okJ)fkDm4Hmf1kHPjIdqY924UdqcGv4ahDsPLpllGIEzWiON2uMQMyCuEIossyYbyYHAUFmTed5NgXp4r4bLJqAyK)KXr5j6ijFrK0Hvt9o2qkwLopbYHzkg(bqCQ0(m3pMwIH8tJhcz882rz8VqPJbpKPOwjmnrCasj5xQGqjaRWbFQ3qGrCDH5iP(M2WUycc(4ISbi5oen0H4ISbij)sH8eIEfe4ISbi5oazVqnmjxeXpc90MYu1eZzNKmGgj3KvY7Om(xO0XGhYuuReMMioajrMoivqOeGv4Gp1BiWiUUWCKuFtByxmOIXrNuA5Zoc4uwki4t9gcSJvcpeSKuWq(PrHYxsjnalaGyxmOC0jLw(SJaoLLEfe8XfzdqYDiAOdXfzdqs(Lc5je9kiWfzdqYDaYccQ3qGXnzLC2fZludtYfr8JqpTPmvnXC2jjdOrYnzL8okJ)fkDm4Hmf1kHPjIdqkC1APccLaSch8PEdbgX1fMJK6BAd7Ibvmo6KslF2raNYsbbFQ3qGDSs4HGLKcgYpnku(skPbybae7IbLJoP0YNDeWPS0RGGpUiBasUdrdDiUiBasYVuipHOxbbUiBasUdqwqq9gcmUjRKZUyEHAysUiIFe6PnLPQjMZojzansUjRK3rz8VqPJbpKPOwjmnrCas(Tzk0irbjPVj1rz8VqPJbpKPOwjmnrCasU3MqneaRWbIRlmhXQuQVPnccexxyoI5qABKjH)xqG46cZrmlbuMe(Fbb1BiW8BZuOrIcssFtIDXGQEdbgX1fMJK6BAd7Iji4t9gcmUjRKZgsXQ05PX)cLm)J9Iye(j(9j5xkeu1BiW4MSso7I5TJY4FHshdEitrTsyAI4aK8p2lQJY4FHshdEitrTsyAI4aKMBkn(xOuQl3dW0uOdbtRFrZTJQJY4FHshlyA9lAUhCVnU7aKayfoi2CtkGgGet10wYjjkinTw(IQeOJrr6TWWi4okJ)fkDSGP1VO5gXbi5UzOgcGCa5As(2aKE3bCbyfoaJEMccLHAi2qkwLoXhsXQ01rz8VqPJfmT(fn3ioajfekd1qDuDug)lu6yU)GbByFDssNFBuaihqUMKVnaP3DaxawHdIbJEMbByFDssNFBuKWMIbKyFXpwjqOIz8VqjZGnSVojPZVnksytXasSkLbDbu0d1NyWONzWg2xNK053gfPiY0SV4hReOGam6zgSH91jjD(TrrkImnBifRsN4q0RGam6zgSH91jjD(TrrcBkgqI5EJF0tidfg9md2W(6KKo)2OiHnfdiXgsXQ05jKHcJEMbByFDssNFBuKWMIbKyFXpwjWokJ)fkDm3hXbiXr5j6ijFrK0Hvt9oawHd(oTPmvnX4O8eDKKWKdWKdvmocPHr(tg3KvYzdzWakiOEdbg3KvYzxmVqn3pMwIH8tJNEeEq9PEdbgX1fMJK6BAdBifRsN44INGG6neyexxyos6qABydPyv6ehx88kiekGIE5qkwLopXfVokJ)fkDm3hXbiDAtzQAcGPPqhGrVCOi9wdPq57a4PPV0bFQ3qGXnzLC2qkwLoXHiuFQ3qGn2jLORtggkbaazdPyv6ehIccIPEdb2yNuIUozyOeaaKDX8kiiM6neyCtwjNDXeem3pMwIH8tJNqgpVq9jM6neyhReEiyjPGH8tJcLVKsAawaaXUyccM7htlXq(PXtiJNxO(uVHaJ46cZrshsBdBifRsN4a5Wmfd)ccQ3qGrCDH5iP(M2WgsXQ0joqomtXWV3okJ)fkDm3hXbiPGqzOgcGCa5As(2aKE3bCbyfomuyiNitvtqFBasp7lfs(ijCrIJB0q9zysUiIFe6PnLPQjgm6LdfP3AifkFN3okJ)fkDm3hXbi5UzOgcGCa5As(2aKE3bCbyfomuyiNitvtqFBasp7lfs(ijCrIJB0q9zysUiIFe6PnLPQjgm6LdfP3AifkFN3okJ)fkDm3hXbi5EsRTrg02qaKdixtY3gG07oGlaRWHHcd5ezQAc6Bdq6zFPqYhjHlsCC9yO(mmjxeXpc90MYu1edg9YHI0BnKcLVZBhLX)cLoM7J4aKcOHtsuqM2FhcGv4GHj5Ii(XokJ)fkDm3hXbin2jLORtggkbaabyfoOEdbg3KvYzxSokJ)fkDm3hXbirkyi)0ivrjmaRWbF(uVHaJ46cZrshsBdBifRsN44INGG6neyexxyosQVPnSHuSkDIJlEEHYrinmYFY4MSsoBifRsN4qgpO(uVHadBkf0axMwAd3YIlXUANnSttFjpJ2JWtqqS5Muanajg2ukObUmT0gULfxID1oByuKElmmc2Rxbb1BiWWMsbnWLPL2WTS4sSR2zd700xs8drJZXtqGJqAyK)KXnzLC2qgmGq9zUFmTed5NgXJm8eeoTPmvnXkN0qK3okJ)fkDm3hXbiXjn5(Y0stxatfkFawHdN2uMQMyCyjhLW1xOeQpZ9JPLyi)0iEKHhuFQ3qGDSs4HGLKcgYpnku(skPbybae7IjiighDsPLp7iGtzPxbbo6KslFwwaf9YGrccN2uMQMyLtAisqq9gcmvncbRVUNDXGQEdbMQgHG1x3ZgsXQ05z04fHpFrgaAUjfqdqIHnLcAGltlTHBzXLyxTZggfP3cdJG9gHpokHV1ZWgIxosA6cyQq5Z(sHKNM(sE96fQyQ3qGXnzLC2fdQpX4OtkT8zzbu0ldgjiWrinmYFY4O8eDKKVis6WQPEh7Ijiu5tdgsBpbldfqrVCifRsNNCesdJ8Nmokprhj5lIKoSAQ3XgsXQ0fHhliu5tdgsBpbldfqrVCifRsNh6H46bWZZOXlcFCucFRNHneVCK00fWuHYN9Lcjpn9L86TJY4FHshZ9rCasvYTjTVqjaRWHtBktvtmoSKJs46luc1N5(X0smKFAepYWdQp1BiWowj8qWssbd5NgfkFjL0aSaaIDXeeeJJoP0YNDeWPS0RGahDsPLpllGIEzWibHtBktvtSYjnejiOEdbMQgHG1x3ZUyqvVHatvJqW6R7zdPyv68eY4fHpFrgaAUjfqdqIHnLcAGltlTHBzXLyxTZggfP3cdJG9gHpokHV1ZWgIxosA6cyQq5Z(sHKNM(sE96fQyQ3qGXnzLC2fdQpX4OtkT8zzbu0ldgjiWrinmYFY4O8eDKKVis6WQPEh7Ijiu5tdgsBpbldfqrVCifRsNNCesdJ8Nmokprhj5lIKoSAQ3XgsXQ0fHhliu5tdgsBpbldfqrVCifRsNh6H46bWZtiJxe(4Oe(wpdBiE5iPPlGPcLp7lfsEA6l51BhLX)cLoM7J4aKoTPmvnbW0uOdo7KKb0i5MSsoapn9Lo4tmocPHr(tg3KvYzdzWakii2PnLPQjghLNOJKeMCaMCOC0jLw(SSak6LbJ82rz8VqPJ5(ioaPWDauIcssFtcGv4aX1fMJyvkTeqOgMKlI4hHQEdbg2ukObUmT0gULfxID1oByNM(sEgThHhuFWONzWg2xNK053gfjSPyaj2x8Jvcuqqmo6KslFws8bPrdSxON2uMQMyo7KKb0i5MSsEhLX)cLoM7J4aKCVnbtRbyfoOEdbgkPxKtIrdNW(cLSlgu1BiWCVnbtRzdfgYjYu1uhLX)cLoM7J4aK4wYjTu9gcamnf6G7TrJgyawHdQ3qG5EB0ObMnKIvPZtic1N6neyexxyos6qABydPyv6ehIccQ3qGrCDH5iP(M2WgsXQ0joe9c1C)yAjgYpnIhz41rz8VqPJ5(ioaj3BtW0AawHdVPP8zUN0ABKWtfEgLMQMGH6O)ReOJ5qAKeEQWdv9gcm3BtW0AgmYF2rz8VqPJ5(ioaj3BJ7oajawHdC0jLw(SSak6LbJGEAtzQAIXr5j6ijHjhGjhkhH0Wi)jJJYt0rs(IiPdRM6DSHuSkDEcXokJ)fkDm3hXbi5EBcMwdWkC4nnLpZ9KwBJeEQWZO0u1emuXEtt5ZCVnA0aZO0u1emu1BiWCVnbtRzdfgYjYu1euFQ3qGrCDH5iP(M2WgsXQ0jUhdL46cZrSkL6BAdu1BiWWMsbnWLPL2WTS4sSR2zd700xYZOHiEccQ3qGHnLcAGltlTHBzXLyxTZg2PPVK4hIgI4b1C)yAjgYpnIhz4jiaJEMbByFDssNFBuKWMIbKydPyv6e3diiy8VqjZGnSVojPZVnksytXasSkLbDbu07fQyCesdJ8NmUjRKZgYGbSJY4FHshZ9rCasU3g3DasaSchuVHadL0lYj5AYg5z5kuYUyccQ3qGDSs4HGLKcgYpnku(skPbybae7IjiOEdbg3KvYzxmO(uVHaBStkrxNmmucaaYgsXQ05jqomtXWpaItL2N5(X0smKFA8qiJNxOQ3qGn2jLORtggkbaazxmbbXuVHaBStkrxNmmucaaYUyqfJJqAyK)Kn2jLORtggkbaazdzWakiighDsPLp7KYxeGJxbbZ9JPLyi)0iEKHhuIRlmhXQuAjGDug)lu6yUpIdqY924UdqcGv4WBAkFM7TrJgygLMQMGH6t9gcm3BJgnWSlMGG5(X0smKFAepYWZlu1BiWCVnA0aZCVXp6jKH6t9gcmIRlmhjDiTnSlMGG6neyexxyosQVPnSlMxOQ3qGHnLcAGltlTHBzXLyxTZg2PPVKNrJZXdQpocPHr(tg3KvYzdPyv6ehx8eee70MYu1eJJYt0rsctoatouo6KslFwwaf9YGrE7Om(xO0XCFehGK7TXDhGeaRWbFQ3qGHnLcAGltlTHBzXLyxTZg2PPVKNrJZXtqq9gcmSPuqdCzAPnCllUe7QD2Won9L8mAiIh030u(m3tATns4PcpJstvtWEHQEdbgX1fMJKoK2g2qkwLoXX5qjUUWCeRsPdPTbQyQ3qGHs6f5Ky0WjSVqj7IbvS30u(m3BJgnWmknvnbdLJqAyK)KXnzLC2qkwLoXX5q9XrinmYFYifmKFAKQOeMnKIvPtCCUGGyC0jLw(SJaoLLE7Om(xO0XCFehGus(LkiucWkCWN6neyexxyosQVPnSlMGGpUiBasUdrdDiUiBasYVuipHOxbbUiBasUdq2ludtYfr8JqpTPmvnXC2jjdOrYnzL8okJ)fkDm3hXbijY0bPccLaSch8PEdbgX1fMJK6BAd7Ibvmo6KslF2raNYsbbFQ3qGDSs4HGLKcgYpnku(skPbybae7IbLJoP0YNDeWPS0RGGpUiBasUdrdDiUiBasYVuipHOxbbUiBasUdqwqq9gcmUjRKZUyEHAysUiIFe6PnLPQjMZojzansUjRK3rz8VqPJ5(ioaPWvRLkiucWkCWN6neyexxyosQVPnSlguX4OtkT8zhbCklfe8PEdb2XkHhcwskyi)0Oq5lPKgGfaqSlguo6KslF2raNYsVcc(4ISbi5oen0H4ISbij)sH8eIEfe4ISbi5oazbb1BiW4MSso7I5fQHj5Ii(rON2uMQMyo7KKb0i5MSsEhLX)cLoM7J4aK8BZuOrIcssFtQJY4FHshZ9rCasU3MqneaRWbIRlmhXQuQVPnccexxyoI5qABKjH)xqG46cZrmlbuMe(Fbb1BiW8BZuOrIcssFtIDXGQEdbgX1fMJK6BAd7Iji4t9gcmUjRKZgsXQ05PX)cLm)J9Iye(j(9j5xkeu1BiW4MSso7I5TJY4FHshZ9rCas(h7f1rz8VqPJ5(ioaP5MsJ)fkL6Y9amnf6qW06x0CbJDyehec4Ix0Gp4dcc]] )


end