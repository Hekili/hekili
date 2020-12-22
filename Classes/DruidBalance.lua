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


    spec:RegisterPack( "Balance", 20201222, [[dOeWGdqicLhbvKCjcvAtG0NGkQgfvvNIQ0QaG8kHWSaq3cQi2fk)ceAyeIJbvAzcjpde10iuLRbISnHi(gurzCeQW5eIY6iuvMhvr3tfSpQchKqf1cjK8qHOAIeQQWfjuvrFKqvvojurkRui1mbG6MeQQk7ee8tcvvvdLqvLwkHkINkutfQWxjurASqfPAVa9xIgSshMYIjvpgvtguxgzZc(mGgnu1PL8AvOztYTjLDl63qgouoUqKwUINtLPRQRRsBxf9DQkJNqQZdqRhamFc2VudIlioaJHTNaHquIeLi4gvurXWv8IcYqgNbg)aIrGXyg)ObKaJttJaJfLPSKtGXygGkKbdIdWyh6oCcmg))yoXheHiW6XF1zCKgeDL2vzFHs(yHhIUsJdrWy9BPECAjOoymS9eieIsKOeb3OIkkgUIxuqgYqcm2UpE0aghxAroym(cgMsqDWyyYXbJXP6vuMYso1R4hZTG7OXP6v8dItA600BurbWEJsKOePJUJgNQ3ihVLajN4RJgNQxCsVIZWWeCVXiLn9kkY0yD04u9It6nYXBjqcU33gG0lRqVCZrUEFuVCa5ks(2aKEhRJgNQxCsVItin0jb37ntItoNna27PnLPRixV(lgXayVydDkDVnU7aK6fN4rVydDYCVnU7aK8Y6OXP6fN0R48jQG7fBiU5(kb2R40XE89wHERhN769Xt96BqjWEf)KRkmhX6OXP6fN0R4F2rQ3ihLNOJuVpEQ3ySAQ31R1RQ(xr9QHgQ3GIeDPROE9xHEbeD7fVbN48Vx813B996kTR6TKqxNcWE9vp(EfL4)IZ4O3i6nYjf5(Yu9koRkGPgLpa7TECoCVUJfMxgySQCVdehGX6i7bXbieWfehGXuA6kcguuGX8PEAkdmw)gcmUjRKZUyGXg)lucgp2jLORtggkbaabFqiefioaJP00vemOOaJryGXo6bJn(xOem(0MY0vey8PPUeySy9QFdbMUPSKtsuqAkL8XxjqNmT)oe7I1l0EfRx9BiW0nLLCsIcstPKp(kb6K2WTKyxmW4tBKPPrGX8P(e9xmWhecqgehGXuA6kcguuGXg)lucgBWg2xNK05ZgnWy(upnLbgRFdbMUPSKtsuqAkL8XxjqNmT)oeZ9g)yVE2R41l0E1VHat3uwYjjkinLs(4ReOtAd3sI5EJFSxp7v86fAV(7vSEHrpZGnSVojPZNnAsytZasSV4hReyVq7vSEn(xOKzWg2xNK05ZgnjSPzajwLYGQaI)7fAV(7vSEHrpZGnSVojPZNnAs8KPyFXpwjWEfe6fg9md2W(6KKoF2OjXtMInKMvPRxp6fY96TxbHEHrpZGnSVojPZNnAsytZasm3B8J96zVqUxO9cJEMbByFDssNpB0KWMMbKydPzv661ZEHuVq7fg9md2W(6KKoF2OjHnndiX(IFSsG96fmMdixrY3gG07aHaUGpieepqCagtPPRiyqrbgZN6PPmWy)9EAtz6kIXr5j6ijHjhGjVxO9kwVCesbJ8LmUjRKZgYGbSxbHE1VHaJBYk5SlwVE7fAV(7v)gcmDtzjNKOG0uk5JVsGozA)DiM7n(XEp0lK6vqOx9BiW0nLLCsIcstPKp(kb6K2WTKyU34h79qVqQxV9ki0BOaI)LdPzv661ZEXveWyJ)fkbJ5O8eDKKpEs6WQPEh4dcbibIdWyknDfbdkkWy(upnLbg7Vx9BiW0nLLCsIcstPKp(kb6KP93HydPzv661JEfpgK6vqOx9BiW0nLLCsIcstPKp(kb6K2WTKydPzv661JEfpgK61BVq71C)ykjgYhn96XHEJmr6fAV(7LJqkyKVKXnzLC2qAwLUE9OxCwVcc96VxocPGr(sgPHH8rJuhLWSH0SkD96rV4SEH2Ry9QFdb2XkHhcwsAyiF0Or5lPKgGfaqSlwVq7LJoP0YNDeWPSSxV96fm24FHsWyULCsj1VHayS(neKPPrGXU3gfAGbFqiejG4amMstxrWGIcmMp1ttzGXI17PnLPRigFQpr)fRxO96Vxo6KslFwwaX)YGr9ki0lhHuWiFjJBYk5SH0SkD96rV4SEfe6vSEpTPmDfX4WsokHRVqzVq7vSE5OtkT8zhbCkl7vqOx)9YrifmYxYinmKpAK6OeMnKMvPRxp6fN1l0EfRx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6fAVC0jLw(SJaoLL96TxVGXg)lucg7EBC3bib(GqaNbIdWyknDfbdkkWy(upnLbg7VxocPGr(sghLNOJK8Xtshwn17ydPzv661ZEHuVq71FVN2uMUIyCuEIossyYbyY7vqOxocPGr(sg3KvYzdPzv661ZEHuVE71BVq71C)ykjgYhn96rVINi9cTxo6KslFwwaX)YGrGXg)lucg7EBC3bib(GqqCaIdWyknDfbdkkWyegySJEWyJ)fkbJpTPmDfbgFAQlbg7Vx9BiW4MSsoBinRsxVE0lK6fAV(7v)gcSXoPeDDYWqjaaiBinRsxVE0lK6vqOxX6v)gcSXoPeDDYWqjaai7I1R3Efe6vSE1VHaJBYk5SlwVcc9AUFmLed5JME9SxilsVE7fAV(7vSE1VHa7yLWdbljnmKpA0O8LusdWcai2fRxbHEn3pMsIH8rtVE2lKfPxV9cTx)9QFdbgXvfMJKoKYg2qAwLUE9OxGCyMMj6Efe6v)gcmIRkmhjv30g2qAwLUE9OxGCyMMj6E9cgFAJmnncmgg9YHI0BnKgLVd8bHqKbIdWyknDfbdkkWyJ)fkbJD3mudbgZN6PPmW4Hcd5WB6kQxO9(2aKE2xAK8rs4I61JEXns6fAVgMKJN4h7fAVN2uMUIyWOxouKERH0O8DGXCa5ks(2aKEhieWf8bHaUIaIdWyknDfbdkkWyJ)fkbJ1qOmudbgZN6PPmW4Hcd5WB6kQxO9(2aKE2xAK8rs4I61JEXfYmi1l0EnmjhpXp2l0EpTPmDfXGrVCOi9wdPr57aJ5aYvK8Tbi9oqiGl4dcbCXfehGXuA6kcguuGXg)lucg7EsPSrgu2qGX8PEAkdmEOWqo8MUI6fAVVnaPN9LgjFKeUOE9OxCJKEJO3H0SkD9cTxdtYXt8J9cT3tBktxrmy0lhksV1qAu(oWyoGCfjFBasVdec4c(Gqa3OaXbymLMUIGbffymFQNMYaJnmjhpXpcgB8VqjyCanCsIcY0(7qGpieWfYG4amMstxrWGIcmMp1ttzGX(7L4QcZrSkLwcyVcc9sCvH5iMdPSrwPe3Efe6L4QcZrm1nTrwPe3E92l0E93Ry9YrNuA5ZYci(xgmQxbHE93R5(XusmKpA61ZEJmi1l0E937PnLPRigFQpr)fRxbHEn3pMsIH8rtVE2lKfPxbHEpTPmDfXkN0quVE7fAV(790MY0veJJYt0rsctoatEVq7vSE5iKcg5lzCuEIosYhpjDy1uVJDX6vqOxX690MY0veJJYt0rsctoatEVq7vSE5iKcg5lzCtwjNDX61BVE71BVq71FVCesbJ8LmUjRKZgsZQ01Rh9czr6vqOxZ9JPKyiF00Rh9gzI0l0E5iKcg5lzCtwjNDX6fAV(7LJqkyKVKrAyiF0i1rjmBinRsxVE2RX)cLm3BtOgIrIM43NKFPr9ki0Ry9YrNuA5Zoc4uw2R3Efe6TYNgmKYEcwgkG4F5qAwLUE9SxCfPxV9cTx)9cJEMbByFDssNpB0KWMMbKydPzv661JEfVEfe6vSE5OtkT8zjXhKcnW96fm24FHsW4WDauIcssDtc8bHaUIhioaJP00vemOOaJ5t90ugyS)EjUQWCetDtBKjj6VxbHEjUQWCeZHu2its0FVcc9sCvH5iMLakts0FVcc9QFdbMUPSKtsuqAkL8XxjqNmT)oeBinRsxVE0R4XGuVcc9QFdbMUPSKtsuqAkL8XxjqN0gULeBinRsxVE0R4XGuVcc9AUFmLed5JME9O3itKEH2lhHuWiFjJBYk5SHmya71BVq71FVCesbJ8LmUjRKZgsZQ01Rh9czr6vqOxocPGr(sg3KvYzdzWa2R3Efe6TYNgmKYEcwgkG4F5qAwLUE9SxCfbm24FHsWysdd5JgPokHbFqiGlKaXbymLMUIGbffymFQNMYaJpTPmDfX4WsokHRVqzVq71FVM7htjXq(OPxp6nYePxO96Vx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6vqOxX6LJoP0YNDeWPSSxV9ki0lhDsPLpllG4FzWOEfe6v)gcmDfcbRUUNDX6fAV63qGPRqiy119SH0SkD96zVrjsVr0R)E5Oe(wpdBiE5iPPkGPgLp7lnsEAQl1R3E92l0E937PnLPRighLNOJKeMCaM8Efe6LJqkyKVKXr5j6ijF8K0Hvt9o2qgmG96TxbHER8PbdPSNGLHci(xoKMvPRxp7nkr6nIE93lhLW36zydXlhjnvbm1O8zFPrYttDPE9cgB8VqjymNuK7ltjnvbm1O8bFqiGBKaIdWyknDfbdkkWy(upnLbgFAtz6kIXHLCucxFHYEH2R)En3pMsIH8rtVE0BKjsVq71FV63qGDSs4HGLKggYhnAu(skPbybae7I1RGqVI1lhDsPLp7iGtzzVE7vqOxo6KslFwwaX)YGr9ki0R(ney6kecwDDp7I1l0E1VHatxHqWQR7zdPzv661ZEHSi9grV(7LJs4B9mSH4LJKMQaMAu(SV0i5PPUuVE71BVq71FVN2uMUIyCuEIossyYbyY7vqOxocPGr(sghLNOJK8Xtshwn17ydzWa2R3Efe6TYNgmKYEcwgkG4F5qAwLUE9SxilsVr0R)E5Oe(wpdBiE5iPPkGPgLp7lnsEAQl1RxWyJ)fkbJRKBtAFHsWhec4IZaXbymLMUIGbffymcdm2rpySX)cLGXN2uMUIaJpn1LaJjUQWCeRsP6M20laQxXrVqSxJ)fkzU3MqneJenXVpj)sJ6nIEfRxIRkmhXQuQUPn9cG6ns6fI9A8VqjZ3ypEgjAIFFs(Lg1Be9kclQEHyVomsPK4n3tGXN2ittJaJnhM4xAIjo4dcbCfhG4amMstxrWGIcmMp1ttzGX(7TYNgmKYEcwgkG4F5qAwLUE9SxXRxbHE93R(neyJDsj66KHHsaaq2qAwLUE9SxGCyMMj6Ebq9YPs1R)En3pMsIH8rtVqSxilsVE7fAV63qGn2jLORtggkbaazxSE92R3Efe61FVM7htjXq(OP3i690MY0veZCyIFPjM49cG6v)gcmIRkmhjDiLnSH0SkD9grVWONfUdGsuqsQBsSV4hDYH0Sk7fa1Bumi1Rh9IBuI0RGqVM7htjXq(OP3i690MY0veZCyIFPjM49cG6v)gcmIRkmhjv30g2qAwLUEJOxy0Zc3bqjkij1nj2x8Jo5qAwL9cG6nkgK61JEXnkr61BVq7L4QcZrSkLwcyVq71FV(7vSE5iKcg5lzCtwjNDX6vqOxo6KslF2raNYYEH2Ry9YrifmYxYinmKpAK6OeMDX61BVcc9YrNuA5ZYci(xgmQxV9cTx)9kwVC0jLw(StkF8ao9ki0Ry9QFdbg3KvYzxSEfe61C)ykjgYhn96rVrMi96TxbHE1VHaJBYk5SH0SkD96rVIJEH2Ry9QFdb2yNuIUozyOeaaKDXaJn(xOem2924Udqc8bHaUrgioaJP00vemOOaJ5t90ugyS)E1VHaJ4QcZrs1nTHDX6vqOx)9YXBdqY17HEJQxO9oehVnaj5xAuVE2lK61BVcc9YXBdqY17HEHCVE7fAVgMKJN4hbJn(xOemojFsnekbFqieLiG4amMstxrWGIcmMp1ttzGX(7v)gcmIRkmhjv30g2fRxbHE93lhVnajxVh6nQEH27qC82aKKFPr96zVqQxV9ki0lhVnajxVh6fY96TxO9AysoEIFem24FHsWy8Mki1qOe8bHqu4cIdWyknDfbdkkWy(upnLbg7Vx9BiWiUQWCKuDtByxSEfe61FVC82aKC9EO3O6fAVdXXBdqs(Lg1RN9cPE92RGqVC82aKC9EOxi3R3EH2RHj54j(rWyJ)fkbJdxLsQHqj4dcHOIcehGXg)lucg7ZMPqJefKK6MeymLMUIGbff4dcHOGmioaJP00vemOOaJ5t90ugymXvfMJyvkv30MEfe6L4QcZrmhszJmjr)9ki0lXvfMJywcOmjr)9ki0R(ney(Szk0irbjPUjXUy9cTx9BiWiUQWCKuDtByxSEfe61FV63qGXnzLC2qAwLUE9SxJ)fkz(g7XZirt87tYV0OEH2R(neyCtwjNDX61lySX)cLGXU3Mqne4dcHOepqCagB8VqjySVXE8GXuA6kcguuGpieIcsG4amMstxrWGIcm24FHsW45MsJ)fkLQY9GXQY9Y00iW4GPup(5c(GpymmfSR6bXbieWfehGXg)lucg7qkBK6KPbgtPPRiyqrb(GqikqCagtPPRiyqrbgJWaJD0dgB8Vqjy8PnLPRiW4ttDjWyhgPuY3gG07yU3MGPu96rV42l0E93Ry9(MIYN5EBuObMrPPRi4Efe69nfLpZ9KszJeEQWZO00veCVE7vqOxhgPuY3gG07yU3MGPu96rVrbgFAJmnncmUCsdrGpieGmioaJP00vemOOaJryGXo6bJn(xOem(0MY0vey8PPUeySdJuk5Bdq6Dm3BtOgQxp6fxW4tBKPPrGXLtYvKDsGpieepqCagtPPRiyqrbgZN6PPmWy)9kwVC0jLw(SSaI)LbJ6vqOxX6LJqkyKVKXr5j6ijF8K0Hvt9o2fRxV9cTx9BiW4MSso7IbgB8VqjySonoAowjqWhecqcehGXuA6kcguuGX8PEAkdmw)gcmUjRKZUyGXg)lucgJH(cLGpieIeqCagtPPRiyqrbgJWaJD0dgB8Vqjy8PnLPRiW4ttDjW4GcHME93R)ER8PbdPSNGLHci(xoKMvPRxCsVrjsV4KE5iKcg5lzCuEIosYhpjDy1uVJnKMvPRxV9cXEXnkr61BVE0BqHqtV(71FVv(0GHu2tWYqbe)lhsZQ01loP3OGuV4KE93lUI0laQ33uu(Sk52K2xOKrPPRi4E92loPx)9Yrj8TEg2q8YrstvatnkF2xAK80uxQxV9It6LJqkyKVKXnzLC2qAwLUE92le7fxXHi96TxbHE5iKcg5lzCtwjNnKMvPRxp6TYNgmKYEcwgkG4F5qAwLUEfe6LJqkyKVKXr5j6ijF8K0Hvt9o2qAwLUE9O3kFAWqk7jyzOaI)LdPzv66vqOxX6LJoP0YNLfq8Vmyey8PnY00iWyokprhjjm5am5GpieWzG4amMstxrWGIcmgHbg7Ohm24FHsW4tBktxrGXNM6sGX(7vSEPi9wyyemJ0WaCitjrdCAjN6vqOxocPGr(sgPHb4qMsIg40soXgsZQ01RN9IBKisVq7vSE5iKcg5lzKggGdzkjAGtl5eBidgWE92RGqVC0jLw(SJaoLLGXN2ittJaJ5WsokHRVqj4dcbXbioaJP00vemOOaJn(xOemM0WaCitjrdCAjNaJ5t90ugymhHuWiFjJBYk5SH0SkD96zVrjsVq790MY0veJJYt0rsctoatEVcc9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVE2BuIagNMgbgtAyaoKPKOboTKtGpieImqCagtPPRiyqrbgB8VqjySdDvk6)kbkNRoGGX8PEAkdmMJqkyKVKXnzLC2qAwLUE9S3iPxO9EAtz6kIXr5j6ijHjhGjVxbHE5iKcg5lzCuEIosYhpjDy1uVJnKMvPRxp7nsaJttJaJDORsr)xjq5C1be8bHaUIaIdWyknDfbdkkWyJ)fkbJR0XN7B6ksgPxl)RMeMolobgZN6PPmWy9BiW4MSso7IbgNMgbgxPJp330vKmsVw(xnjmDwCc8bHaU4cIdWyknDfbdkkWy(upnLbgRFdbg3KvYzxSEfe6LJoP0YNLfq8VmyuVq790MY0veJJYt0rsctoatEVq7LJqkyKVKXr5j6ijF8K0Hvt9o2fRxO9kwVCesbJ8LmUjRKZUy9cTx)96Vx9BiWiUQWCKuDtBydPzv661JEXvKEfe6v)gcmIRkmhjDiLnSH0SkD96rV4ksVE7fAVI17CtkGgGet3uwYjjkinLs(4ReOJrPPRi4Efe6DUjfqdqIPBkl5KefKMsjF8vc0XO00veCVq71FV63qGPBkl5KefKMsjF8vc0jt7VdXCVXp2Rh9c5Efe6v)gcmDtzjNKOG0uk5JVsGoPnCljM7n(XE9Oxi3R3E92RGqV63qGDSs4HGLKggYhnAu(skPbybae7I1RGqVHci(xoKMvPRxp7nkraJn(xOem(6iz9KMd8bHaUrbIdWyknDfbdkkWy(upnLbgFAtz6kIvoPHiWy3pf)bHaUGXg)lucgp3uA8VqPuvUhmwvUxMMgbgBic8bHaUqgehGXuA6kcguuGX8PEAkdmEUjfqdqI9Lg5dnPeEittVsyAyuKElmmcgm29tXFqiGlySX)cLGXZnLg)lukvL7bJvL7LPPrGXWdzA6vctd4dcbCfpqCagtPPRiyqrbgZN6PPmW45MuanajMUPSKtsuqAkL8XxjqhJI0BHHrWGXUFk(dcbCbJn(xOemEUP04FHsPQCpySQCVmnncmwhzp4dcbCHeioaJP00vemOOaJn(xOemEUP04FHsPQCpySQCVmnncm29Gp4dgJnehPPBpioaHaUG4am24FHsW4JvcpeS0Hvt9oWyknDfbdkkWhecrbIdWyJ)fkbJ1qO8yLYaA0aJP00vemOOaFqiazqCagtPPRiyqrbgB8VqjySVXE8GX8PEAkdm2FVexvyoIPUPnYKe93RGqVexvyoIvPuDtB6vqOxIRkmhXQuQJE89ki0lXvfMJywcOmjr)96fmwvjj5WGX4kc4dcbXdehGXuA6kcguuGX8PEAkdm2FVexvyoIPUPnYKe93RGqVexvyoIvPuDtB6vqOxIRkmhXQuQJE89ki0lXvfMJywcOmjr)96TxO9In0jdxMVXE89cTxX6fBOtwumFJ94bJn(xOem23ypEWhecqcehGXuA6kcguuGX8PEAkdmwSENBsb0aKy6MYsojrbPPuYhFLaDmknDfb3RGqVI1lhDsPLpllG4FzWOEfe6vSEDyKsjFBasVJ5EBcMs17HEXTxbHEfR33uu(S0(7qoPUPSKtmknDfbdgB8VqjyS7Tjudb(GqisaXbymLMUIGbffymFQNMYaJNBsb0aKy6MYsojrbPPuYhFLaDmknDfb3l0E5OtkT8zzbe)ldg1l0EDyKsjFBasVJ5EBcMs17HEXfm24FHsWy3BJ7oajWh8bJnebIdqiGlioaJP00vemOOaJryGXo6bJn(xOem(0MY0vey8PPUeyS)E1VHa7lnYhAsj8qMMELW0WgsZQ01RN9cKdZ0mr3Be9kcd3Efe6v)gcSV0iFOjLWdzA6vctdBinRsxVE2RX)cLm3BtOgIrIM43NKFPr9grVIWWTxO96VxIRkmhXQuQUPn9ki0lXvfMJyoKYgzsI(7vqOxIRkmhXSeqzsI(71BVE7fAV63qG9Lg5dnPeEittVsyAyxSEH27CtkGgGe7lnYhAsj8qMMELW0WOi9wyyemy8PnY00iWy4HmnPVsPKbtPKOqa8bHquG4amMstxrWGIcmMp1ttzGX(790MY0veJJYt0rsctoatEVq7vSE5iKcg5lzCtwjNnKbdyVcc9QFdbg3KvYzxSE92l0En3pMsIH8rtVE2lKePxO96Vx9BiWiUQWCKuDtBydPzv661JEJKEfe6v)gcmIRkmhjDiLnSH0SkD96rVrsVE7fAV(7vSENBsb0aKy6MYsojrbPPuYhFLaDmknDfb3RGqV63qGPBkl5KefKMsjF8vc0jt7VdXCVXp2Rh9c5Efe6v)gcmDtzjNKOG0uk5JVsGoPnCljM7n(XE9Oxi3R3Efe6nuaX)YH0SkD96zV4kcySX)cLGXCuEIosYhpjDy1uVd8bHaKbXbymLMUIGbffymFQNMYaJ1VHaZ92emLInuyihEtxr9cTx)96WiLs(2aKEhZ92emLQxp7fY9ki0Ry9o3KcObiX(sJ8HMucpKPPxjmnmksVfggb3R3EH2R)EfR35MuanajMcqUnMtgue9vcucuvAyoIrr6TWWi4Efe69lnQxXTxXds96rV63qG5EBcMsXgsZQ01Be9gvVEbJn(xOem292emLc8bHG4bIdWyknDfbdkkWy(upnLbgp3KcObiX(sJ8HMucpKPPxjmnmksVfggb3l0EDyKsjFBasVJ5EBcMs1Rhh6fY9cTx)9kwV63qG9Lg5dnPeEittVsyAyxSEH2R(neyU3MGPuSHcd5WB6kQxbHE937PnLPRig8qMM0xPuYGPusui0l0E93R(neyU3MGPuSH0SkD96zVqUxbHEDyKsjFBasVJ5EBcMs1Rh9gvVq79nfLpZ9KszJeEQWZO00veCVq7v)gcm3BtWuk2qAwLUE9Sxi1R3E92RxWyJ)fkbJDVnbtPaFqiajqCagtPPRiyqrbgJWaJD0dgB8Vqjy8PnLPRiW4ttDjWyZ9JPKyiF00Rh9koePxCsV(7fxr6fa1R(neyFPr(qtkHhY00ReMgM7n(XE92loPx)9QFdbM7TjykfBinRsxVaOEHCVqSxhgPus8M7PE92loPx)9cJEw4oakrbjPUjXgsZQ01laQxi1R3EH2R(neyU3MGPuSlgy8PnY00iWy3BtWukPpu(YGPusuia(GqisaXbymLMUIGbffymFQNMYaJpTPmDfXGhY0K(kLsgmLsIcHEH27PnLPRiM7TjykL0hkFzWukjke6vqOx)9QFdbMUPSKtsuqAkL8XxjqNmT)oeZ9g)yVE0lK7vqOx9BiW0nLLCsIcstPKp(kb6K2WTKyU34h71JEHCVE7fAVomsPKVnaP3XCVnbtP61ZEfpWyJ)fkbJDVnU7aKaFqiGZaXbymLMUIGbffySX)cLGXUBgQHaJ5t90ugy8qHHC4nDf1l0EFBasp7lns(ijCr96rV4kE9It61HrkL8Tbi9UEJO3H0SkD9cTxdtYXt8J9cTxIRkmhXQuAjGGXCa5ks(2aKEhieWf8bHG4aehGXuA6kcguuGXg)lucgBWg2xNK05ZgnWy(upnLbglwVFXpwjWEH2Ry9A8VqjZGnSVojPZNnAsytZasSkLbvbe)3RGqVWONzWg2xNK05ZgnjSPzajM7n(XE9Sxi3l0EHrpZGnSVojPZNnAsytZasSH0SkD96zVqgmMdixrY3gG07aHaUGpieImqCagtPPRiyqrbgB8VqjySgcLHAiWy(upnLbgpuyihEtxr9cT33gG0Z(sJKpscxuVE0R)EXv86nIE93RdJuk5Bdq6Dm3BtOgQxauV4YGuVE71BVqSxhgPuY3gG076nIEhsZQ01l0E93lhHuWiFjJBYk5SHmya7fAV(790MY0veJJYt0rsctoatEVcc9YrifmYxY4O8eDKKpEs6WQPEhBidgWEfe6vSE5OtkT8zzbe)ldg1R3Efe61HrkL8Tbi9oM7Tjud1RN96VxXRxauV(7f3EJO33uu(S3xLsnekDmknDfb3R3E92RGqV(7L4QcZrSkLoKYMEfe61FVexvyoIvPuh947vqOxIRkmhXQuQUPn96TxO9kwVVPO8zo0vjrb5JNKb0qUNrPPRi4Efe6v)gcmSP0qdCzkPnCllUe7QC2Won1L61Jd9gfKePxV9cTx)96WiLs(2aKEhZ92eQH61ZEXvKEbq96VxC7nIEFtr5ZEFvk1qO0XO00veCVE71BVq71C)ykjgYhn96rVqsKEXj9QFdbM7TjykfBinRsxVaOEJKE92l0E93Ry9QFdb2XkHhcwsAyiF0Or5lPKgGfaqSlwVcc9sCvH5iwLshsztVcc9kwVC0jLw(SJaoLL96TxO9AysoEIFemMdixrY3gG07aHaUGpieWveqCagtPPRiyqrbgZN6PPmWydtYXt8JGXg)lucghqdNKOGmT)oe4dcbCXfehGXuA6kcguuGX8PEAkdmw)gcmUjRKZUyGXg)lucgp2jLORtggkbaabFqiGBuG4amMstxrWGIcmMp1ttzGXN2uMUIyCyjhLW1xOSxO96Vx9BiWCVnbtPyxSEfe61C)ykjgYhn96rVqsKE92l0EfRx9BiWCiL7loXUy9cTxX6v)gcmUjRKZUy9cTx)9kwVC0jLw(SSaI)LbJ6vqO3tBktxrmokprhjjm5am59ki0lhHuWiFjJJYt0rs(4jPdRM6DSlwVcc9w5tdgszpbldfq8VCinRsxVE2BuI0Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxVGXg)lucgZjf5(YustvatnkFWhec4czqCagtPPRiyqrbgZN6PPmW4tBktxrmoSKJs46lu2l0E93R(neyU3MGPuSlwVcc9AUFmLed5JME9OxijsVE7fAVI1R(neyoKY9fNyxSEH2Ry9QFdbg3KvYzxSEH2R)EfRxo6KslFwwaX)YGr9ki07PnLPRighLNOJKeMCaM8Efe6LJqkyKVKXr5j6ijF8K0Hvt9o2fRxbHER8PbdPSNGLHci(xoKMvPRxp7LJqkyKVKXr5j6ijF8K0Hvt9o2qAwLUEJO3iPxbHER8PbdPSNGLHci(xoKMvPRxXTxCfhI0RN9czr6nIE93lhLW36zydXlhjnvbm1O8zFPrYttDPE92RxWyJ)fkbJRKBtAFHsWhec4kEG4amMstxrWGIcmMp1ttzGXv(0GHu2tWYqbe)lhsZQ01RN9IlK6vqOx)9QFdbg2uAObUmL0gULfxIDvoByNM6s96zVrbjr6vqOx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxpo0BuqsKE92l0E1VHaZ92emLIDX6fAVCesbJ8LmUjRKZgsZQ01Rh9cjraJn(xOemM0Wq(OrQJsyWhec4cjqCagtPPRiyqrbgB8VqjyS7jLYgzqzdbgZN6PPmW4Hcd5WB6kQxO9(LgjFKeUOE9OxCHuVq71HrkL8Tbi9oM7Tjud1RN9kE9cTxdtYXt8J9cTx)9QFdbg3KvYzdPzv661JEXvKEfe6vSE1VHaJBYk5SlwVEbJ5aYvK8Tbi9oqiGl4dcbCJeqCagtPPRiyqrbgZN6PPmWyIRkmhXQuAjG9cTxdtYXt8J9cTx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxp7nkijsVq71FVWONzWg2xNK05ZgnjSPzaj2x8JvcSxbHEfRxo6KslFws8bPqdCVcc96WiLs(2aKExVE0Bu96fm24FHsW4WDauIcssDtc8bHaU4mqCagtPPRiyqrbgZN6PPmWy9BiWqj94DsmA4e2xOKDX6fAV(7v)gcm3BtWuk2qHHC4nDf1RGqVM7htjXq(OPxp6nYePxVGXg)lucg7EBcMsb(GqaxXbioaJP00vemOOaJ5t90ugymhDsPLpllG4FzWOEH2R)EpTPmDfX4O8eDKKWKdWK3RGqVCesbJ8LmUjRKZUy9ki0R(neyCtwjNDX61BVq7LJqkyKVKXr5j6ijF8K0Hvt9o2qAwLUE9SxGCyMMj6Ebq9YPs1R)En3pMsIH8rtVqSxijsVE7fAV63qG5EBcMsXgsZQ01RN9kEGXg)lucg7EBcMsb(Gqa3idehGXuA6kcguuGX8PEAkdmMJoP0YNLfq8VmyuVq71FVN2uMUIyCuEIossyYbyY7vqOxocPGr(sg3KvYzxSEfe6v)gcmUjRKZUy96TxO9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVE2BK0l0E1VHaZ92emLIDX6fAVexvyoIvP0sabJn(xOem2924Udqc8bHquIaIdWyknDfbdkkWy(upnLbgRFdbgkPhVtYvKnYZYvOKDX6vqOx)9kwVU3MqneZWKC8e)yVcc96Vx9BiW4MSsoBinRsxVE2lK6fAV63qGXnzLC2fRxbHE93R(neyJDsj66KHHsaaq2qAwLUE9SxGCyMMj6Ebq9YPs1R)En3pMsIH8rtVqSxilsVE7fAV63qGn2jLORtggkbaazxSE92R3EH27PnLPRiM7TjykL0hkFzWukjke6fAVomsPKVnaP3XCVnbtP61ZEHCVE7fAV(7vSENBsb0aKyFPr(qtkHhY00ReMggfP3cdJG7vqOxhgPuY3gG07yU3MGPu96zVqUxVGXg)lucg7EBC3bib(GqikCbXbymLMUIGbffymFQNMYaJ93lXvfMJyvkTeWEH2lhHuWiFjJBYk5SH0SkD96rVqsKEfe61FVC82aKC9EO3O6fAVdXXBdqs(Lg1RN9cPE92RGqVC82aKC9EOxi3R3EH2RHj54j(rWyJ)fkbJtYNudHsWhecrffioaJP00vemOOaJ5t90ugyS)EjUQWCeRsPLa2l0E5iKcg5lzCtwjNnKMvPRxp6fsI0RGqV(7LJ3gGKR3d9gvVq7DioEBasYV0OE9Sxi1R3Efe6LJ3gGKR3d9c5E92l0EnmjhpXpcgB8VqjymEtfKAiuc(GqikidIdWyknDfbdkkWy(upnLbg7VxIRkmhXQuAjG9cTxocPGr(sg3KvYzdPzv661JEHKi9ki0R)E54Tbi569qVr1l0EhIJ3gGK8lnQxp7fs96TxbHE54Tbi569qVqUxV9cTxdtYXt8JGXg)lucghUkLudHsWhecrjEG4am24FHsWyF2mfAKOGKu3KaJP00vemOOaFqiefKaXbymLMUIGbffymcdm2rpySX)cLGXN2uMUIaJpn1LaJDyKsjFBasVJ5EBc1q96rVIxVr0BqHqtV(7vZCpnakpn1L6fI9gLi96T3i6nOqOPx)9QFdbM7TXDhGKK0Wq(OrJYx6qkByU34h7fI9kE96fm(0gzAAeyS7TjudjRu6qkBaFqievKaIdWyknDfbdkkWy(upnLbgtCvH5iM6M2its0FVcc9sCvH5iMLakts0FVq790MY0veRCsUIStQxbHE1VHaJ4QcZrshszdBinRsxVE2RX)cLm3BtOgIrIM43NKFPr9cTx9BiWiUQWCK0Hu2WUy9ki0lXvfMJyvkDiLn9cTxX690MY0veZ92eQHKvkDiLn9ki0R(neyCtwjNnKMvPRxp714FHsM7TjudXirt87tYV0OEH2Ry9EAtz6kIvojxr2j1l0E1VHaJBYk5SH0SkD96zVKOj(9j5xAuVq7v)gcmUjRKZUy9ki0R(neyJDsj66KHHsaaq2fRxO96WiLsI3Cp1Rh9kcls6fAV(71HrkL8Tbi9UE98qVqUxbHEfR33uu(mh6QKOG8XtYaAi3ZO00veCVE7vqOxX690MY0veRCsUIStQxO9QFdbg3KvYzdPzv661JEjrt87tYV0iWyJ)fkbJ9n2Jh8bHqu4mqCagB8VqjyS7TjudbgtPPRiyqrb(GqikXbioaJP00vemOOaJn(xOemEUP04FHsPQCpySQCVmnncmoyk1JFUGp4dghmL6XpxqCacbCbXbymLMUIGbffymFQNMYaJfR35MuanajMUPSKtsuqAkL8XxjqhJI0BHHrWGXg)lucg7EBC3bib(GqikqCagtPPRiyqrbgB8VqjyS7MHAiWy(upnLbgdJEMgcLHAi2qAwLUE9O3H0SkDGXCa5ks(2aKEhieWf8bHaKbXbySX)cLGXAiugQHaJP00vemOOaFWhm29G4aec4cIdWyknDfbdkkWyJ)fkbJnyd7Rts68zJgymFQNMYaJfRxy0Zmyd7Rts68zJMe20mGe7l(Xkb2l0EfRxJ)fkzgSH91jjD(SrtcBAgqIvPmOkG4)EH2R)EfRxy0Zmyd7Rts68zJMepzk2x8JvcSxbHEHrpZGnSVojPZNnAs8KPydPzv661JEHuVE7vqOxy0Zmyd7Rts68zJMe20mGeZ9g)yVE2lK7fAVWONzWg2xNK05ZgnjSPzaj2qAwLUE9Sxi3l0EHrpZGnSVojPZNnAsytZasSV4hReiymhqUIKVnaP3bcbCbFqiefioaJP00vemOOaJ5t90ugyS)EpTPmDfX4O8eDKKWKdWK3l0EfRxocPGr(sg3KvYzdzWa2RGqV63qGXnzLC2fRxV9cTxZ9JPKyiF00RN9kEI0l0E93R(neyexvyosQUPnSH0SkD96rV4ksVcc9QFdbgXvfMJKoKYg2qAwLUE9OxCfPxV9ki0BOaI)LdPzv661ZEXveWyJ)fkbJ5O8eDKKpEs6WQPEh4dcbidIdWyknDfbdkkWyegySJEWyJ)fkbJpTPmDfbgFAQlbg7Vx9BiW4MSsoBinRsxVE0lK6fAV(7v)gcSXoPeDDYWqjaaiBinRsxVE0lK6vqOxX6v)gcSXoPeDDYWqjaai7I1R3Efe6vSE1VHaJBYk5SlwVcc9AUFmLed5JME9SxilsVE7fAV(7vSE1VHa7yLWdbljnmKpA0O8LusdWcai2fRxbHEn3pMsIH8rtVE2lKfPxV9cTx)9QFdbgXvfMJKoKYg2qAwLUE9OxGCyMMj6Efe6v)gcmIRkmhjv30g2qAwLUE9OxGCyMMj6E9cgFAJmnncmgg9YHI0BnKgLVd8bHG4bIdWyknDfbdkkWyJ)fkbJ1qOmudbgZN6PPmW4Hcd5WB6kQxO9(2aKE2xAK8rs4I61JEXnQEH2R)EnmjhpXp2l0EpTPmDfXGrVCOi9wdPr5761lymhqUIKVnaP3bcbCbFqiajqCagtPPRiyqrbgB8VqjyS7MHAiWy(upnLbgpuyihEtxr9cT33gG0Z(sJKpscxuVE0lUr1l0E93RHj54j(XEH27PnLPRigm6LdfP3AinkFxVEbJ5aYvK8Tbi9oqiGl4dcHibehGXuA6kcguuGXg)lucg7EsPSrgu2qGX8PEAkdmEOWqo8MUI6fAVVnaPN9LgjFKeUOE9OxCJKEH2R)EnmjhpXp2l0EpTPmDfXGrVCOi9wdPr5761lymhqUIKVnaP3bcbCbFqiGZaXbymLMUIGbffymFQNMYaJnmjhpXpcgB8VqjyCanCsIcY0(7qGpieehG4amMstxrWGIcmMp1ttzGX63qGXnzLC2fdm24FHsW4XoPeDDYWqjaai4dcHidehGXuA6kcguuGX8PEAkdm2FV(7v)gcmIRkmhjDiLnSH0SkD96rV4ksVcc9QFdbgXvfMJKQBAdBinRsxVE0lUI0R3EH2lhHuWiFjJBYk5SH0SkD96rVqwKEH2R)E1VHadBkn0axMsAd3YIlXUkNnSttDPE9S3Oepr6vqOxX6DUjfqdqIHnLgAGltjTHBzXLyxLZggfP3cdJG71BVE7vqOx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxpo0Bu4mr6vqOxocPGr(sg3KvYzdzWa2l0E93R5(XusmKpA61JEJmr6vqO3tBktxrSYjne1RxWyJ)fkbJjnmKpAK6Oeg8bHaUIaIdWyknDfbdkkWy(upnLbgFAtz6kIXHLCucxFHYEH2R)En3pMsIH8rtVE0BKjsVq71FV63qGDSs4HGLKggYhnAu(skPbybae7I1RGqVI1lhDsPLp7iGtzzVE7vqOxo6KslFwwaX)YGr9ki07PnLPRiw5KgI6vqOx9BiW0vieS66E2fRxO9QFdbMUcHGvx3ZgsZQ01RN9gLi9grV(71FVrwVaOENBsb0aKyytPHg4YusB4wwCj2v5SHrr6TWWi4E92Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxV96TxO9kwV63qGXnzLC2fRxO96VxX6LJoP0YNLfq8VmyuVcc9YrifmYxY4O8eDKKpEs6WQPEh7I1RGqVv(0GHu2tWYqbe)lhsZQ01RN9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVr0BK0RGqVv(0GHu2tWYqbe)lhsZQ01R42lUIdr61ZEJsKEJOx)9Yrj8TEg2q8YrstvatnkF2xAK80uxQxV96fm24FHsWyoPi3xMsAQcyQr5d(GqaxCbXbymLMUIGbffymFQNMYaJpTPmDfX4WsokHRVqzVq71FVM7htjXq(OPxp6nYePxO96Vx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6vqOxX6LJoP0YNDeWPSSxV9ki0lhDsPLpllG4FzWOEfe690MY0veRCsdr9ki0R(ney6kecwDDp7I1l0E1VHatxHqWQR7zdPzv661ZEHSi9grV(71FVrwVaOENBsb0aKyytPHg4YusB4wwCj2v5SHrr6TWWi4E92Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxV96TxO9kwV63qGXnzLC2fRxO96VxX6LJoP0YNLfq8VmyuVcc9YrifmYxY4O8eDKKpEs6WQPEh7I1RGqVv(0GHu2tWYqbe)lhsZQ01RN9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVr0BK0RGqVv(0GHu2tWYqbe)lhsZQ01R42lUIdr61ZEHSi9grV(7LJs4B9mSH4LJKMQaMAu(SV0i5PPUuVE71lySX)cLGXvYTjTVqj4dcbCJcehGXuA6kcguuGXimWyh9GXg)lucgFAtz6kcm(0uxcm2FVI1lhHuWiFjJBYk5SHmya7vqOxX690MY0veJJYt0rsctoatEVq7LJoP0YNLfq8VmyuVEbJpTrMMgbg7StsgqJKBYk5GpieWfYG4amMstxrWGIcmMp1ttzGXexvyoIvP0sa7fAVgMKJN4h7fAV63qGHnLgAGltjTHBzXLyxLZg2PPUuVE2BuINi9cTx)9cJEMbByFDssNpB0KWMMbKyFXpwjWEfe6vSE5OtkT8zjXhKcnW96TxO9EAtz6kI5StsgqJKBYk5GXg)lucghUdGsuqsQBsGpieWv8aXbymLMUIGbffymFQNMYaJ1VHadL0J3jXOHtyFHs2fRxO9QFdbM7TjykfBOWqo8MUIaJn(xOem292emLc8bHaUqcehGXuA6kcguuGX8PEAkdmw)gcm3BJcnWSH0SkD96zVqQxO96Vx9BiWiUQWCK0Hu2WgsZQ01Rh9cPEfe6v)gcmIRkmhjv30g2qAwLUE9Oxi1R3EH2R5(XusmKpA61JEJmraJn(xOemMBjNus9BiagRFdbzAAeyS7TrHgyWhec4gjG4amMstxrWGIcmMp1ttzGXVPO8zUNukBKWtfEgLMUIG7fAVo6)kb6yoKcjHNk89cTx9BiWCVnbtPyWiFjySX)cLGXU3MGPuGpieWfNbIdWyknDfbdkkWy(upnLbgZrNuA5ZYci(xgmQxO9EAtz6kIXr5j6ijHjhGjVxO9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVE2lKaJn(xOem2924Udqc8bHaUIdqCagtPPRiyqrbgZN6PPmW43uu(m3tkLns4PcpJstxrW9cTxX69nfLpZ92OqdmJstxrW9cTx9BiWCVnbtPydfgYH30vuVq71FV63qGrCvH5iP6M2WgsZQ01Rh9gj9cTxIRkmhXQuQUPn9cTx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxp7nkijsVcc9QFdbg2uAObUmL0gULfxIDvoByNM6s96XHEJcsI0l0En3pMsIH8rtVE0BKjsVcc9cJEMbByFDssNpB0KWMMbKydPzv661JEfh9ki0RX)cLmd2W(6KKoF2OjHnndiXQugufq8FVE7fAVI1lhHuWiFjJBYk5SHmyabJn(xOem292emLc8bHaUrgioaJP00vemOOaJ5t90ugyS(neyOKE8ojxr2iplxHs2fRxbHE1VHa7yLWdbljnmKpA0O8LusdWcai2fRxbHE1VHaJBYk5SlwVq71FV63qGn2jLORtggkbaazdPzv661ZEbYHzAMO7fa1lNkvV(71C)ykjgYhn9cXEHSi96TxO9QFdb2yNuIUozyOeaaKDX6vqOxX6v)gcSXoPeDDYWqjaai7I1l0EfRxocPGr(s2yNuIUozyOeaaKnKbdyVcc9kwVC0jLw(StkF8ao96TxbHEn3pMsIH8rtVE0BKjsVq7L4QcZrSkLwciySX)cLGXU3g3DasGpieIseqCagtPPRiyqrbgZN6PPmW43uu(m3BJcnWmknDfb3l0E93R(neyU3gfAGzxSEfe61C)ykjgYhn96rVrMi96TxO9QFdbM7TrHgyM7n(XE9Sxi3l0E93R(neyexvyos6qkByxSEfe6v)gcmIRkmhjv30g2fRxV9cTx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxp7nkCMi9cTx)9YrifmYxY4MSsoBinRsxVE0lUI0RGqVI17PnLPRighLNOJKeMCaM8EH2lhDsPLpllG4FzWOE9cgB8VqjyS7TXDhGe4dcHOWfehGXuA6kcguuGX8PEAkdm2FV63qGHnLgAGltjTHBzXLyxLZg2PPUuVE2Bu4mr6vqOx9BiWWMsdnWLPK2WTS4sSRYzd70uxQxp7nkijsVq79nfLpZ9KszJeEQWZO00veCVE7fAV63qGrCvH5iPdPSHnKMvPRxp6fN1l0EjUQWCeRsPdPSPxO9kwV63qGHs6X7Ky0WjSVqj7I1l0EfR33uu(m3BJcnWmknDfb3l0E5iKcg5lzCtwjNnKMvPRxp6fN1l0E93lhHuWiFjJ0Wq(OrQJsy2qAwLUE9OxCwVcc9kwVC0jLw(SJaoLL96fm24FHsWy3BJ7oajWhecrffioaJP00vemOOaJ5t90ugyS)E1VHaJ4QcZrs1nTHDX6vqOx)9YXBdqY17HEJQxO9oehVnaj5xAuVE2lK61BVcc9YXBdqY17HEHCVE7fAVgMKJN4h7fAVN2uMUIyo7KKb0i5MSsoySX)cLGXj5tQHqj4dcHOGmioaJP00vemOOaJ5t90ugyS)E1VHaJ4QcZrs1nTHDX6fAVI1lhDsPLp7iGtzzVcc96Vx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6fAVC0jLw(SJaoLL96TxbHE93lhVnajxVh6nQEH27qC82aKKFPr96zVqQxV9ki0lhVnajxVh6fY9ki0R(neyCtwjNDX61BVq71WKC8e)yVq790MY0veZzNKmGgj3KvYbJn(xOemgVPcsnekbFqieL4bIdWyknDfbdkkWy(upnLbg7Vx9BiWiUQWCKuDtByxSEH2Ry9YrNuA5Zoc4uw2RGqV(7v)gcSJvcpeSK0Wq(OrJYxsjnalaGyxSEH2lhDsPLp7iGtzzVE7vqOx)9YXBdqY17HEJQxO9oehVnaj5xAuVE2lK61BVcc9YXBdqY17HEHCVcc9QFdbg3KvYzxSE92l0EnmjhpXp2l0EpTPmDfXC2jjdOrYnzLCWyJ)fkbJdxLsQHqj4dcHOGeioaJn(xOem2NntHgjkij1njWyknDfbdkkWhecrfjG4amMstxrWGIcmMp1ttzGXexvyoIvPuDtB6vqOxIRkmhXCiLnYKe93RGqVexvyoIzjGYKe93RGqV63qG5ZMPqJefKK6Me7I1l0E1VHaJ4QcZrs1nTHDX6vqOx)9QFdbg3KvYzdPzv661ZEn(xOK5BShpJenXVpj)sJ6fAV63qGXnzLC2fRxVGXg)lucg7EBc1qGpieIcNbIdWyJ)fkbJ9n2JhmMstxrWGIc8bHquIdqCagtPPRiyqrbgB8Vqjy8CtPX)cLsv5EWyv5EzAAeyCWuQh)CbFWhmgEittVsyAaXbieWfehGXuA6kcguuGXimWyh9GXg)lucgFAtz6kcm(0uxcm2FV63qG9Lg5dnPeEittVsyAydPzv661JEbYHzAMO7nIEfHHBVq71FVexvyoIvPuh947vqOxIRkmhXQu6qkB6vqOxIRkmhXu30gzsI(71BVcc9QFdb2xAKp0Ks4Hmn9kHPHnKMvPRxp614FHsM7TjudXirt87tYV0OEJOxry42l0E93lXvfMJyvkv30MEfe6L4QcZrmhszJmjr)9ki0lXvfMJywcOmjr)96TxV9ki0Ry9QFdb2xAKp0Ks4Hmn9kHPHDXaJpTrMMgbg7SajFK86iPdJukWhecrbIdWyknDfbdkkWy(upnLbg7VxX690MY0veZzbs(i51rshgPu9ki0R)E1VHaBStkrxNmmucaaYgsZQ01RN9cKdZ0mr3laQxovQE93R5(XusmKpA6fI9czr61BVq7v)gcSXoPeDDYWqjaai7I1R3E92RGqVM7htjXq(OPxp6nYebm24FHsWy3BJ7oajWhecqgehGXuA6kcguuGX8PEAkdm2FVN2uMUIyCuEIossyYbyY7fAVv(0GHu2tWYqbe)lhsZQ01Rh9IlKfPxO9kwVCesbJ8LmUjRKZgYGbSxbHE1VHaJBYk5SlwVE7fAVM7htjXq(OPxp7v8ePxO96Vx9BiWiUQWCKuDtBydPzv661JEXvKEfe6v)gcmIRkmhjDiLnSH0SkD96rV4ksVE7vqO3qbe)lhsZQ01RN9IRiGXg)lucgZr5j6ijF8K0Hvt9oWhecIhioaJP00vemOOaJn(xOem2GnSVojPZNnAGX8PEAkdmwSEHrpZGnSVojPZNnAsytZasSV4hReyVq7vSEn(xOKzWg2xNK05ZgnjSPzajwLYGQaI)7fAV(7vSEHrpZGnSVojPZNnAs8KPyFXpwjWEfe6fg9md2W(6KKoF2OjXtMInKMvPRxp6fs96TxbHEHrpZGnSVojPZNnAsytZasm3B8J96zVqUxO9cJEMbByFDssNpB0KWMMbKydPzv661ZEHCVq7fg9md2W(6KKoF2OjHnndiX(IFSsGGXCa5ks(2aKEhieWf8bHaKaXbymLMUIGbffySX)cLGXAiugQHaJ5t90ugy8qHHC4nDf1l0EFBasp7lns(ijCr96rV4gvVq71FV(7v)gcmUjRKZgsZQ01Rh9cPEH2R)E1VHaBStkrxNmmucaaYgsZQ01Rh9cPEfe6vSE1VHaBStkrxNmmucaaYUy96TxbHEfRx9BiW4MSso7I1RGqVM7htjXq(OPxp7fYI0R3EH2R)EfRx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6vqOxZ9JPKyiF00RN9czr61BVq71WKC8e)yVEbJ5aYvK8Tbi9oqiGl4dcHibehGXuA6kcguuGXg)lucg7UzOgcmMp1ttzGXdfgYH30vuVq79Tbi9SV0i5JKWf1Rh9IBu9cTx)96Vx9BiW4MSsoBinRsxVE0lK6fAV(7v)gcSXoPeDDYWqjaaiBinRsxVE0lK6vqOxX6v)gcSXoPeDDYWqjaai7I1R3Efe6vSE1VHaJBYk5SlwVcc9AUFmLed5JME9SxilsVE7fAV(7vSE1VHa7yLWdbljnmKpA0O8LusdWcai2fRxbHEn3pMsIH8rtVE2lKfPxV9cTxdtYXt8J96fmMdixrY3gG07aHaUGpieWzG4amMstxrWGIcm24FHsWy3tkLnYGYgcmMp1ttzGXdfgYH30vuVq79Tbi9SV0i5JKWf1Rh9IBK0l0E93R)E1VHaJBYk5SH0SkD96rVqQxO96Vx9BiWg7Ks01jddLaaGSH0SkD96rVqQxbHEfRx9BiWg7Ks01jddLaaGSlwVE7vqOxX6v)gcmUjRKZUy9ki0R5(XusmKpA61ZEHSi96TxO96VxX6v)gcSJvcpeSK0Wq(OrJYxsjnalaGyxSEfe61C)ykjgYhn96zVqwKE92l0EnmjhpXp2RxWyoGCfjFBasVdec4c(GqqCaIdWyknDfbdkkWy(upnLbgBysoEIFem24FHsW4aA4KefKP93HaFqiezG4amMstxrWGIcmMp1ttzGX63qGXnzLC2fdm24FHsW4XoPeDDYWqjaai4dcbCfbehGXuA6kcguuGX8PEAkdm2FV(7v)gcmIRkmhjDiLnSH0SkD96rV4ksVcc9QFdbgXvfMJKQBAdBinRsxVE0lUI0R3EH2lhHuWiFjJBYk5SH0SkD96rVqwKE92RGqVCesbJ8LmUjRKZgYGbem24FHsWysdd5JgPokHbFqiGlUG4amMstxrWGIcmMp1ttzGXN2uMUIyCyjhLW1xOSxO96Vx)9QFdb2XkHhcwsAyiF0Or5lPKgGfaqSlwVcc9kwVC0jLw(SJaoLL96TxbHE5OtkT8zzbe)ldg1RGqVN2uMUIyLtAiQxbHE1VHatxHqWQR7zxSEH2R(ney6kecwDDpBinRsxVE2BuI0Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxV9cTxX6v)gcmUjRKZUy9cTx)9kwVC0jLw(SSaI)LbJ6vqOxocPGr(sghLNOJK8Xtshwn17yxSEfe6TYNgmKYEcwgkG4F5qAwLUE9SxocPGr(sghLNOJK8Xtshwn17ydPzv66nIEJKEfe6TYNgmKYEcwgkG4F5qAwLUEf3EXvCisVE2BuI0Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxVGXg)lucgZjf5(YustvatnkFWhec4gfioaJP00vemOOaJ5t90ugy8PnLPRighwYrjC9fk7fAV(71FV63qGDSs4HGLKggYhnAu(skPbybae7I1RGqVI1lhDsPLp7iGtzzVE7vqOxo6KslFwwaX)YGr9ki07PnLPRiw5KgI6vqOx9BiW0vieS66E2fRxO9QFdbMUcHGvx3ZgsZQ01RN9czr6nIE93lhLW36zydXlhjnvbm1O8zFPrYttDPE92R3EH2Ry9QFdbg3KvYzxSEH2R)EfRxo6KslFwwaX)YGr9ki0lhHuWiFjJJYt0rs(4jPdRM6DSlwVcc9w5tdgszpbldfq8VCinRsxVE2lhHuWiFjJJYt0rs(4jPdRM6DSH0SkD9grVrsVcc9w5tdgszpbldfq8VCinRsxVIBV4koePxp7fYI0Be96VxokHV1ZWgIxosAQcyQr5Z(sJKNM6s96TxVGXg)lucgxj3M0(cLGpieWfYG4amMstxrWGIcmgHbg7Ohm24FHsW4tBktxrGXNM6sGX(7vSE5iKcg5lzCtwjNnKbdyVcc9kwVN2uMUIyCuEIossyYbyY7fAVC0jLw(SSaI)LbJ61ly8PnY00iWyNDsYaAKCtwjh8bHaUIhioaJP00vemOOaJ5t90ugymXvfMJyvkTeWEH2RHj54j(XEH2R)EHrpZGnSVojPZNnAsytZasSV4hReyVcc9kwVC0jLw(SK4dsHg4E92l0EpTPmDfXC2jjdOrYnzLCWyJ)fkbJd3bqjkij1njWhec4cjqCagtPPRiyqrbgZN6PPmWyo6KslFwwaX)YGr9cT3tBktxrmokprhjjm5am59cTxZ9JPKyiF00Rhh6v8ePxO9YrifmYxY4O8eDKKpEs6WQPEhBinRsxVE2lqomtZeDVaOE5uP61FVM7htjXq(OPxi2lKfPxVGXg)lucg7EBC3bib(Gqa3ibehGXuA6kcguuGX8PEAkdm2FV63qGrCvH5iP6M2WUy9ki0R)E54Tbi569qVr1l0EhIJ3gGK8lnQxp7fs96TxbHE54Tbi569qVqUxV9cTxdtYXt8J9cT3tBktxrmNDsYaAKCtwjhm24FHsW4K8j1qOe8bHaU4mqCagtPPRiyqrbgZN6PPmWy)9QFdbgXvfMJKQBAd7I1l0EfRxo6KslF2raNYYEfe61FV63qGDSs4HGLKggYhnAu(skPbybae7I1l0E5OtkT8zhbCkl71BVcc96VxoEBasUEp0Bu9cT3H44Tbij)sJ61ZEHuVE7vqOxoEBasUEp0lK7vqOx9BiW4MSso7I1R3EH2RHj54j(XEH27PnLPRiMZojzansUjRKdgB8VqjymEtfKAiuc(GqaxXbioaJP00vemOOaJ5t90ugyS)E1VHaJ4QcZrs1nTHDX6fAVI1lhDsPLp7iGtzzVcc96Vx9BiWowj8qWssdd5JgnkFjL0aSaaIDX6fAVC0jLw(SJaoLL96TxbHE93lhVnajxVh6nQEH27qC82aKKFPr96zVqQxV9ki0lhVnajxVh6fY9ki0R(neyCtwjNDX61BVq71WKC8e)yVq790MY0veZzNKmGgj3KvYbJn(xOemoCvkPgcLGpieWnYaXbySX)cLGX(Szk0irbjPUjbgtPPRiyqrb(GqikraXbymLMUIGbffymFQNMYaJjUQWCeRsP6M20RGqVexvyoI5qkBKjj6VxbHEjUQWCeZsaLjj6VxbHE1VHaZNntHgjkij1nj2fRxO9QFdbgXvfMJKQBAd7I1RGqV(7v)gcmUjRKZgsZQ01RN9A8VqjZ3ypEgjAIFFs(Lg1l0E1VHaJBYk5SlwVEbJn(xOem292eQHaFqiefUG4am24FHsWyFJ94bJP00vemOOaFqievuG4amMstxrWGIcm24FHsW45MsJ)fkLQY9GXQY9Y00iW4GPup(5c(Gp4dgFsJRqjieIsKOeb3OIcxWyF2Kvc0bglovCwCceWPbbXFIVE7fh4PElnm089gqtV4C4Hmn9kHPbN37qr6TgcUxhsJ61UpsZEcUxoElbsowhnaUsQ3OeF9g5O8KMNG7nU0I8EDaMVj6Ef3EFuVa4R1lCDwUcL9IWOXE00RFi6Tx)4kAVSoAaCLuV4IR4R3ihLN08eCVXLwK3RdW8nr3R4kU9(OEbWxRxne8vDD9IWOXE00RFX1BV(Xv0EzD0a4kPEXnkXxVrokpP5j4EJlTiVxhG5BIUxXvC79r9cGVwVAi4R666fHrJ9OPx)IR3E9JRO9Y6ObWvs9IlKeF9g5O8KMNG7nU0I8EDaMVj6Ef3EFuVa4R1lCDwUcL9IWOXE00RFi6Tx)4kAVSo6oAXPIZItGaonii(t81BV4ap1BPHHMV3aA6fNdtb7QECEVdfP3Ai4EDinQx7(in7j4E54Tei5yD0a4kPEJeXxVrokpP5j4EJlTiVxhG5BIUxXT3h1la(A9cxNLRqzVimAShn96hIE71FuI2lRJgaxj1lU4k(6nYr5jnpb3loFUjfqdqIHthN37J6fNp3KcObiXWPZO00vemoVx)rjAVSo6oAXPIZItGaonii(t81BV4ap1BPHHMV3aA6fNJnehPPBpoV3HI0BneCVoKg1RDFKM9eCVC8wcKCSoAaCLuVqs81BKJYtAEcUxC(CtkGgGedNooV3h1loFUjfqdqIHtNrPPRiyCEV(Xv0EzD0a4kPEJeXxVrokpP5j4EX5ZnPaAasmC648EFuV485MuanajgoDgLMUIGX596hxr7L1r3rlovCwCceWPbbXFIVE7fh4PElnm089gqtV4Cdr48EhksV1qW96qAuV29rA2tW9YXBjqYX6ObWvs9gL4R3ihLN08eCV485MuanajgoDCEVpQxC(CtkGgGedNoJstxrW48E9JRO9Y6ObWvs9czXxVrokpP5j4EJlTiVxhG5BIUxXvC79r9cGVwVAi4R666fHrJ9OPx)IR3E9JRO9Y6ObWvs9cjXxVrokpP5j4EJlTiVxhG5BIUxXT3h1la(A9cxNLRqzVimAShn96hIE71pUI2lRJgaxj1BKj(6nYr5jnpb3BCPf596amFt09kU9(OEbWxRx46SCfk7fHrJ9OPx)q0BV(Xv0EzD0a4kPEXfYIVEJCuEsZtW9gxArEVoaZ3eDVIR427J6faFTE1qWx111lcJg7rtV(fxV96hxr7L1rdGRK6fxXH4R3ihLN08eCVXLwK3RdW8nr3R427J6faFTEHRZYvOSxegn2JME9drV96hxr7L1rdGRK6nkreF9g5O8KMNG7nU0I8EDaMVj6Ef3EFuVa4R1lCDwUcL9IWOXE00RFi6Tx)4kAVSoAaCLuVrbjXxVrokpP5j4EJlTiVxhG5BIUxXT3h1la(A9cxNLRqzVimAShn96hIE71FuI2lRJUJwCQ4S4eiGtdcI)eF92loWt9wAyO57nGMEX5UhN37qr6TgcUxhsJ61UpsZEcUxoElbsowhnaUsQxCfr81BKJYtAEcU34slY71by(MO7vCf3EFuVa4R1Rgc(QUUEry0ypA61V46Tx)4kAVSoAaCLuV4IR4R3ihLN08eCVXLwK3RdW8nr3R4kU9(OEbWxRxne8vDD9IWOXE00RFX1BV(Xv0EzD0a4kPEXnYeF9g5O8KMNG7nU0I8EDaMVj6Ef3EFuVa4R1lCDwUcL9IWOXE00RFi6Tx)4kAVSo6oAXPIZItGaonii(t81BV4ap1BPHHMV3aA6fNRJShN37qr6TgcUxhsJ61UpsZEcUxoElbsowhnaUsQxCXzIVEJCuEsZtW9gxArEVoaZ3eDVIBVpQxa816fUolxHYEry0ypA61pe92RFilAVSoAaCLuV4koeF9g5O8KMNG7nU0I8EDaMVj6Ef3EFuVa4R1lCDwUcL9IWOXE00RFi6Tx)4kAVSo6oACAAyO5j4EXz9A8VqzVQY9owhnySdJ4GqaxrIcmgBqHsrGX4u9kktzjN6v8J5wWD04u9k(bXjnDA6nQOayVrjsuI0r3rJt1BKJ3sGKt81rJt1loPxXzyycU3yKYMEffzASoACQEXj9g54Teib37Bdq6LvOxU5ixVpQxoGCfjFBasVJ1rJt1loPxXjKg6KG79MjXjNZga790MY0vKRx)fJyaSxSHoLU3g3Das9It8OxSHozU3g3DasEzD04u9It6vC(evW9Ine3CFLa7vC6yp(ERqV1JZD9(4PE9nOeyVIFYvfMJyD04u9It6v8p7i1BKJYt0rQ3hp1Bmwn17616vv)ROE1qd1BqrIU0vuV(RqVaIU9I3GtC(3l(67T(EDL2v9wsORtbyV(QhFVIs8FXzC0Be9g5KICFzQEfNvfWuJYhG9wpohUx3XcZlRJUJ24FHshdBiost3(dhReEiyPdRM6DD0g)lu6yydXrA62hXbiQHq5XkLb0O1rB8VqPJHnehPPBFehGOVXE8auvjj5WhWveawHd(jUQWCetDtBKjj6xqG4QcZrSkLQBAJGaXvfMJyvk1rpEbbIRkmhXSeqzsI(92rB8VqPJHnehPPBFehGOVXE8aSch8tCvH5iM6M2its0VGaXvfMJyvkv30gbbIRkmhXQuQJE8ccexvyoIzjGYKe97fk2qNmCz(g7XdvmSHozrX8n2JVJ24FHshdBiost3(ioar3BtOgcGv4GyZnPaAasmDtzjNKOG0uk5JVsGobbX4OtkT8zzbe)ldgjiiMdJuk5Bdq6Dm3BtWuQd4kii2BkkFwA)DiNu3uwYjgLMUIG7On(xO0XWgIJ00TpIdq0924UdqcGv4WCtkGgGet3uwYjjkinLs(4ReOdkhDsPLpllG4FzWiOomsPKVnaP3XCVnbtPoGBhDhnovVIFkAIFFcUx6Kga79lnQ3hp1RXF00B561oTsz6kI1rB8VqP7GdPSrQtMwhTX)cLUdN2uMUIayAA0HYjnebWttDPdomsPKVnaP3XCVnbtP8axO(f7nfLpZ92OqdmJstxrWccVPO8zUNukBKWtfEgLMUIG9ki4WiLs(2aKEhZ92emLYJO6On(xO0fXbiEAtz6kcGPPrhkNKRi7Ka4PPU0bhgPuY3gG07yU3MqnKh42rB8VqPlIdquNghnhReiaRWb)IXrNuA5ZYci(xgmsqqmocPGr(sghLNOJK8Xtshwn17yxmVq1VHaJBYk5SlwhTX)cLUioarm0xOeGv4G(neyCtwjNDX6On(xO0fXbiEAtz6kcGPPrh4O8eDKKWKdWKdWttDPdbfcn(9x5tdgszpbldfq8VCinRshojkrWjCesbJ8Lmokprhj5JNKoSAQ3XgsZQ05vCXnkr86rqHqJF)v(0GHu2tWYqbe)lhsZQ0HtIcs4e)4kca6nfLpRsUnP9fkzuA6kc2loXphLW36zydXlhjnvbm1O8zFPrYttDjV4eocPGr(sg3KvYzdPzv68kU4koeXRGahHuWiFjJBYk5SH0SkDEu5tdgszpbldfq8VCinRsNGahHuWiFjJJYt0rs(4jPdRM6DSH0SkDEu5tdgszpbldfq8VCinRsNGGyC0jLw(SSaI)LbJ6On(xO0fXbiEAtz6kcGPPrh4WsokHRVqjapn1Lo4xmksVfggbZinmahYus0aNwYjbbocPGr(sgPHb4qMsIg40soXgsZQ05jUrIiqfJJqkyKVKrAyaoKPKOboTKtSHmya9kiWrNuA5Zoc4uw2rB8VqPlIdq86iz9KgattJoqAyaoKPKOboTKtaSch4iKcg5lzCtwjNnKMvPZZOeb6PnLPRighLNOJKeMCaMCbbocPGr(sghLNOJK8Xtshwn17ydPzv68mkr6On(xO0fXbiEDKSEsdGPPrhCORsr)xjq5C1beGv4ahHuWiFjJBYk5SH0SkDEgjqpTPmDfX4O8eDKKWKdWKliWrifmYxY4O8eDKKpEs6WQPEhBinRsNNrshTX)cLUioaXRJK1tAamnn6qLo(CFtxrYi9A5F1KW0zXjawHd63qGXnzLC2fRJgNQxJ)fkDrCaIxhjRN0Ca0PqV7WpvEKECbyfoi2pvEKEgUm8MtInioZsaH6xSFQ8i9SOy4nNeBqCMLakii2pvEKEwuSHmyaLCesbJ8LEfe0VHaJBYk5SlMGahHuWiFjJBYk5SH0SkD4eCfXJFQ8i9mCzCesbJ8Lm47yFHsOIXrNuA5Zoc4uwkiWrNuA5ZYci(xgmc6PnLPRighLNOJKeMCaMCOCesbJ8Lmokprhj5JNKoSAQ3XUycc63qGDSs4HGLKggYhnAu(skPbybae7IjiekG4F5qAwLopJsKoACQEn(xO0fXbiEDKSEsZbqNc9Ud)u5r6JcGv4Gy)u5r6zrXWBoj2G4mlbeQFX(PYJ0ZWLH3CsSbXzwcOGGy)u5r6z4YgYGbuYrifmYx6vq4NkpspdxgEZjXgeNzjGq)PYJ0ZIIH3CsSbXzwciuX(PYJ0ZWLnKbdOKJqkyKVuqq)gcmUjRKZUyccCesbJ8LmUjRKZgsZQ0HtWvep(PYJ0ZIIXrifmYxYGVJ9fkHkghDsPLp7iGtzPGahDsPLpllG4FzWiON2uMUIyCuEIossyYbyYHYrifmYxY4O8eDKKpEs6WQPEh7IjiOFdb2XkHhcwsAyiF0Or5lPKgGfaqSlMGqOaI)LdPzv68mkr6On(xO0fXbiEDKSEsZbWkCq)gcmUjRKZUyccC0jLw(SSaI)LbJGEAtz6kIXr5j6ijHjhGjhkhHuWiFjJJYt0rs(4jPdRM6DSlguX4iKcg5lzCtwjNDXG63V(neyexvyosQUPnSH0SkDEGRicc63qGrCvH5iPdPSHnKMvPZdCfXluXMBsb0aKy6MYsojrbPPuYhFLaDccZnPaAasmDtzjNKOG0uk5JVsGoO(1VHat3uwYjjkinLs(4ReOtM2FhI5EJF0diliOFdbMUPSKtsuqAkL8XxjqN0gULeZ9g)Ohq2Rxbb9BiWowj8qWssdd5JgnkFjL0aSaaIDXeecfq8VCinRsNNrjshTX)cLUioaX5MsJ)fkLQY9amnn6GHia6(P4)bCbyfoCAtz6kIvoPHOoAJ)fkDrCaIZnLg)lukvL7byAA0b4Hmn9kHPbGUFk(FaxawHdZnPaAasSV0iFOjLWdzA6vctdJI0BHHrWD0g)lu6I4aeNBkn(xOuQk3dW00Od6i7bO7NI)hWfGv4WCtkGgGet3uwYjjkinLs(4ReOJrr6TWWi4oAJ)fkDrCaIZnLg)lukvL7byAA0b33r3rB8VqPJzi6WPnLPRiaMMgDaEitt6RukzWukjkea4PPU0b)63qG9Lg5dnPeEittVsyAydPzv68eihMPzIocry4kiOFdb2xAKp0Ks4Hmn9kHPHnKMvPZtJ)fkzU3MqneJenXVpj)sJIqegUq9tCvH5iwLs1nTrqG4QcZrmhszJmjr)ccexvyoIzjGYKe971lu9BiW(sJ8HMucpKPPxjmnSlg05Muanaj2xAKp0Ks4Hmn9kHPHrr6TWWi4oAJ)fkDmdrrCaICuEIosYhpjDy1uVdGv4G)tBktxrmokprhjjm5am5qfJJqkyKVKXnzLC2qgmGcc63qGXnzLC2fZluZ9JPKyiF04jKebQF9BiWiUQWCKuDtBydPzv68isee0VHaJ4QcZrshszdBinRsNhrIxO(fBUjfqdqIPBkl5KefKMsjF8vc0jiOFdbMUPSKtsuqAkL8XxjqNmT)oeZ9g)Ohqwqq)gcmDtzjNKOG0uk5JVsGoPnCljM7n(rpGSxbHqbe)lhsZQ05jUI0rB8VqPJzikIdq092emLcGv4G(neyU3MGPuSHcd5WB6kcQFhgPuY3gG07yU3MGPuEczbbXMBsb0aKyFPr(qtkHhY00ReMggfP3cdJG9c1VyZnPaAasmfGCBmNmOi6ReOeOQ0WCeJI0BHHrWccFPrIR4kEqYd9BiWCVnbtPydPzv6IikVD0g)lu6ygII4aeDVnbtPayfom3KcObiX(sJ8HMucpKPPxjmnmksVfggbd1HrkL8Tbi9oM7TjykLhhGmu)IPFdb2xAKp0Ks4Hmn9kHPHDXGQFdbM7TjykfBOWqo8MUIee8FAtz6kIbpKPj9vkLmykLefcq9RFdbM7TjykfBinRsNNqwqWHrkL8Tbi9oM7TjykLhrb9nfLpZ9KszJeEQWZO00vemu9BiWCVnbtPydPzv68esE96TJ24FHshZquehG4PnLPRiaMMgDW92emLs6dLVmykLefca80ux6G5(XusmKpA8qCicoXpUIaG0VHa7lnYhAsj8qMMELW0WCVXp6fN4x)gcm3BtWuk2qAwLoaeKfxhgPus8M7jV4e)WONfUdGsuqsQBsSH0SkDaii5fQ(neyU3MGPuSlwhTX)cLoMHOioar3BJ7oajawHdN2uMUIyWdzAsFLsjdMsjrHa0tBktxrm3BtWukPpu(YGPusuiii4x)gcmDtzjNKOG0uk5JVsGozA)DiM7n(rpGSGG(ney6MYsojrbPPuYhFLaDsB4wsm3B8JEazVqDyKsjFBasVJ5EBcMs5P41rB8VqPJzikIdq0DZqnea5aYvK8Tbi9Ud4cWkCyOWqo8MUIG(2aKE2xAK8rs4I8axXdN4WiLs(2aKExedPzv6GAysoEIFekXvfMJyvkTeWoAJ)fkDmdrrCaIgSH91jjD(SrdGCa5ks(2aKE3bCbyfoi2x8JvceQyg)luYmyd7Rts68zJMe20mGeRszqvaX)ccWONzWg2xNK05ZgnjSPzajM7n(rpHmuy0Zmyd7Rts68zJMe20mGeBinRsNNqUJ24FHshZquehGOgcLHAiaYbKRi5Bdq6DhWfGv4WqHHC4nDfb9Tbi9SV0i5JKWf5HFCfVi87WiLs(2aKEhZ92eQHaq4YGKxVIRdJuk5Bdq6DrmKMvPdQFocPGr(sg3KvYzdzWac1)PnLPRighLNOJKeMCaMCbbocPGr(sghLNOJK8Xtshwn17ydzWakiighDsPLpllG4FzWiVccomsPKVnaP3XCVnHAip9lEai)4gXBkkF27RsPgcLogLMUIG96vqWpXvfMJyvkDiLncc(jUQWCeRsPo6XliqCvH5iwLs1nTXluXEtr5ZCORsIcYhpjdOHCpJstxrWcc63qGHnLgAGltjTHBzXLyxLZg2PPUKhhIcsI4fQFhgPuY3gG07yU3MqnKN4kcaYpUr8MIYN9(QuQHqPJrPPRiyVEHAUFmLed5JgpGKi4e9BiWCVnbtPydPzv6aqrIxO(ft)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmbbIRkmhXQu6qkBeeeJJoP0YNDeWPS0ludtYXt8JD0g)lu6ygII4aedOHtsuqM2FhcGv4GHj54j(XoAJ)fkDmdrrCaIJDsj66KHHsaaqawHd63qGXnzLC2fRJ24FHshZquehGiNuK7ltjnvbm1O8byfoCAtz6kIXHLCucxFHsO(1VHaZ92emLIDXeem3pMsIH8rJhqseVqft)gcmhs5(ItSlguX0VHaJBYk5Slgu)IXrNuA5ZYci(xgmsq40MY0veJJYt0rsctoatUGahHuWiFjJJYt0rs(4jPdRM6DSlMGqLpnyiL9eSmuaX)YH0SkDEgLir4NJs4B9mSH4LJKMQaMAu(SV0i5PPUKxVD0g)lu6ygII4aeRKBtAFHsawHdN2uMUIyCyjhLW1xOeQF9BiWCVnbtPyxmbbZ9JPKyiF04bKeXluX0VHaZHuUV4e7Ibvm9BiW4MSso7Ib1VyC0jLw(SSaI)LbJeeoTPmDfX4O8eDKKWKdWKliWrifmYxY4O8eDKKpEs6WQPEh7Ijiu5tdgszpbldfq8VCinRsNNCesbJ8Lmokprhj5JNKoSAQ3XgsZQ0frKiiu5tdgszpbldfq8VCinRsN4kU4koeXtilse(5Oe(wpdBiE5iPPkGPgLp7lnsEAQl51BhTX)cLoMHOioarsdd5JgPokHbyfou5tdgszpbldfq8VCinRsNN4cjbb)63qGHnLgAGltjTHBzXLyxLZg2PPUKNrbjree0VHadBkn0axMsAd3YIlXUkNnSttDjpoefKeXlu9BiWCVnbtPyxmOCesbJ8LmUjRKZgsZQ05bKePJ24FHshZquehGO7jLYgzqzdbqoGCfjFBasV7aUaSchgkmKdVPRiOFPrYhjHlYdCHeuhgPuY3gG07yU3MqnKNIhudtYXt8Jq9RFdbg3KvYzdPzv68axreeet)gcmUjRKZUyE7On(xO0XmefXbigUdGsuqsQBsaSchiUQWCeRsPLac1WKC8e)iu9BiWWMsdnWLPK2WTS4sSRYzd70uxYZOGKiq9dJEMbByFDssNpB0KWMMbKyFXpwjqbbX4OtkT8zjXhKcnWccomsPKVnaP35ruE7On(xO0XmefXbi6EBcMsbWkCq)gcmuspENeJgoH9fkzxmO(1VHaZ92emLInuyihEtxrccM7htjXq(OXJiteVD0g)lu6ygII4aeDVnbtPayfoWrNuA5ZYci(xgmcQ)tBktxrmokprhjjm5am5ccCesbJ8LmUjRKZUycc63qGXnzLC2fZluocPGr(sghLNOJK8Xtshwn17ydPzv68eihMPzIgaXPs53C)ykjgYhnIlKeXlu9BiWCVnbtPydPzv68u86On(xO0XmefXbi6EBC3bibWkCGJoP0YNLfq8Vmyeu)N2uMUIyCuEIossyYbyYfe4iKcg5lzCtwjNDXee0VHaJBYk5SlMxOCesbJ8Lmokprhj5JNKoSAQ3XgsZQ05zKav)gcm3BtWuk2fdkXvfMJyvkTeWoAJ)fkDmdrrCaIU3g3DasaSch0VHadL0J3j5kYg5z5kuYUycc(fZ92eQHygMKJN4hfe8RFdbg3KvYzdPzv68esq1VHaJBYk5SlMGGF9BiWg7Ks01jddLaaGSH0SkDEcKdZ0mrdG4uP8BUFmLed5JgXfYI4fQ(neyJDsj66KHHsaaq2fZRxON2uMUIyU3MGPusFO8LbtPKOqaQdJuk5Bdq6Dm3BtWukpHSxO(fBUjfqdqI9Lg5dnPeEittVsyAyuKElmmcwqWHrkL8Tbi9oM7TjykLNq2BhTX)cLoMHOioaXK8j1qOeGv4GFIRkmhXQuAjGq5iKcg5lzCtwjNnKMvPZdijIGGFoEBasUdrbDioEBasYV0ipHKxbboEBasUdq2ludtYXt8JD0g)lu6ygII4aeXBQGudHsawHd(jUQWCeRsPLacLJqkyKVKXnzLC2qAwLopGKicc(54Tbi5oef0H44Tbij)sJ8esEfe44Tbi5oazVqnmjhpXp2rB8VqPJzikIdqmCvkPgcLaSch8tCvH5iwLslbekhHuWiFjJBYk5SH0SkDEajree8ZXBdqYDikOdXXBdqs(Lg5jK8kiWXBdqYDaYEHAysoEIFSJ24FHshZquehGOpBMcnsuqsQBsD0g)lu6ygII4aepTPmDfbW00OdU3MqnKSsPdPSbGNM6shCyKsjFBasVJ5EBc1qEiEreui04xZCpnakpn1Le3OeXBebfcn(1VHaZ924UdqssAyiF0Or5lDiLnm3B8JIR45TJ24FHshZquehGOVXE8aSchiUQWCetDtBKjj6xqG4QcZrmlbuMKOFON2uMUIyLtYvKDscc63qGrCvH5iPdPSHnKMvPZtJ)fkzU3MqneJenXVpj)sJGQFdbgXvfMJKoKYg2ftqG4QcZrSkLoKYgOIDAtz6kI5EBc1qYkLoKYgbb9BiW4MSsoBinRsNNg)luYCVnHAigjAIFFs(LgbvStBktxrSYj5kYojO63qGXnzLC2qAwLopjrt87tYV0iO63qGXnzLC2ftqq)gcSXoPeDDYWqjaai7Ib1HrkLeV5EYdryrcu)omsPKVnaP355bilii2BkkFMdDvsuq(4jzanK7zuA6kc2RGGyN2uMUIyLtYvKDsq1VHaJBYk5SH0SkDEqIM43NKFPrD0g)lu6ygII4aeDVnHAOoAJ)fkDmdrrCaIZnLg)lukvL7byAA0HGPup(52r3rB8VqPJPJS)WyNuIUozyOeaaeGv4G(neyCtwjNDX6On(xO0X0r2hXbiEAtz6kcGPPrh4t9j6Vya80ux6Gy63qGPBkl5KefKMsjF8vc0jt7VdXUyqft)gcmDtzjNKOG0uk5JVsGoPnClj2fRJ24FHshthzFehGObByFDssNpB0aihqUIKVnaP3DaxawHd63qGPBkl5KefKMsjF8vc0jt7VdXCVXp6P4bv)gcmDtzjNKOG0uk5JVsGoPnCljM7n(rpfpO(fdg9md2W(6KKoF2OjHnndiX(IFSsGqfZ4FHsMbByFDssNpB0KWMMbKyvkdQci(hQFXGrpZGnSVojPZNnAs8KPyFXpwjqbby0Zmyd7Rts68zJMepzk2qAwLopGSxbby0Zmyd7Rts68zJMe20mGeZ9g)ONqgkm6zgSH91jjD(SrtcBAgqInKMvPZtibfg9md2W(6KKoF2OjHnndiX(IFSsGE7On(xO0X0r2hXbiYr5j6ijF8K0Hvt9oawHd(pTPmDfX4O8eDKKWKdWKdvmocPGr(sg3KvYzdzWakiOFdbg3KvYzxmVq9RFdbMUPSKtsuqAkL8XxjqNmT)oeZ9g)4bijiOFdbMUPSKtsuqAkL8XxjqN0gULeZ9g)4bi5vqiuaX)YH0SkDEIRiD0g)lu6y6i7J4ae5wYjLu)gcamnn6G7TrHgyawHd(1VHat3uwYjjkinLs(4ReOtM2FhInKMvPZdXJbjbb9BiW0nLLCsIcstPKp(kb6K2WTKydPzv68q8yqYluZ9JPKyiF04XHiteO(5iKcg5lzCtwjNnKMvPZdCMGGFocPGr(sgPHH8rJuhLWSH0SkDEGZGkM(neyhReEiyjPHH8rJgLVKsAawaaXUyq5OtkT8zhbCkl96TJ24FHshthzFehGO7TXDhGeaRWbXoTPmDfX4t9j6Vyq9ZrNuA5ZYci(xgmsqGJqkyKVKXnzLC2qAwLopWzccIDAtz6kIXHLCucxFHsOIXrNuA5Zoc4uwki4NJqkyKVKrAyiF0i1rjmBinRsNh4mOIPFdb2XkHhcwsAyiF0Or5lPKgGfaqSlguo6KslF2raNYsVE7On(xO0X0r2hXbi6EBC3bibWkCWphHuWiFjJJYt0rs(4jPdRM6DSH0SkDEcjO(pTPmDfX4O8eDKKWKdWKliWrifmYxY4MSsoBinRsNNqYRxOM7htjXq(OXdXteOC0jLw(SSaI)LbJ6On(xO0X0r2hXbiEAtz6kcGPPrhGrVCOi9wdPr57a4PPU0b)63qGXnzLC2qAwLopGeu)63qGn2jLORtggkbaazdPzv68asccIPFdb2yNuIUozyOeaaKDX8kiiM(neyCtwjNDXeem3pMsIH8rJNqweVq9lM(neyhReEiyjPHH8rJgLVKsAawaaXUyccM7htjXq(OXtilIxO(1VHaJ4QcZrshszdBinRsNha5Wmnt0cc63qGrCvH5iP6M2WgsZQ05bqomtZeT3oAJ)fkDmDK9rCaIUBgQHaihqUIKVnaP3DaxawHddfgYH30ve03gG0Z(sJKpscxKh4gjqnmjhpXpc90MY0vedg9YHI0BnKgLVRJ24FHshthzFehGOgcLHAiaYbKRi5Bdq6DhWfGv4WqHHC4nDfb9Tbi9SV0i5JKWf5bUqMbjOgMKJN4hHEAtz6kIbJE5qr6TgsJY31rB8VqPJPJSpIdq09KszJmOSHaihqUIKVnaP3DaxawHddfgYH30ve03gG0Z(sJKpscxKh4gjrmKMvPdQHj54j(rON2uMUIyWOxouKERH0O8DD0g)lu6y6i7J4aedOHtsuqM2FhcGv4GHj54j(XoAJ)fkDmDK9rCaIH7aOefKK6MeaRWb)exvyoIvP0safeiUQWCeZHu2iRuIRGaXvfMJyQBAJSsjUEH6xmo6KslFwwaX)YGrcc(n3pMsIH8rJNrgKG6)0MY0veJp1NO)IjiyUFmLed5JgpHSiccN2uMUIyLtAiYlu)N2uMUIyCuEIossyYbyYHkghHuWiFjJJYt0rs(4jPdRM6DSlMGGyN2uMUIyCuEIossyYbyYHkghHuWiFjJBYk5SlMxVEH6NJqkyKVKXnzLC2qAwLopGSiccM7htjXq(OXJiteOCesbJ8LmUjRKZUyq9ZrifmYxYinmKpAK6OeMnKMvPZtJ)fkzU3MqneJenXVpj)sJeeeJJoP0YNDeWPS0RGqLpnyiL9eSmuaX)YH0SkDEIRiEH6hg9md2W(6KKoF2OjHnndiXgsZQ05H4jiighDsPLplj(GuOb2BhTX)cLoMoY(ioarsdd5JgPokHbyfo4N4QcZrm1nTrMKOFbbIRkmhXCiLnYKe9liqCvH5iMLakts0VGG(ney6MYsojrbPPuYhFLaDY0(7qSH0SkDEiEmijiOFdbMUPSKtsuqAkL8XxjqN0gULeBinRsNhIhdsccM7htjXq(OXJiteOCesbJ8LmUjRKZgYGb0lu)CesbJ8LmUjRKZgsZQ05bKfrqGJqkyKVKXnzLC2qgmGEfeQ8PbdPSNGLHci(xoKMvPZtCfPJ24FHshthzFehGiNuK7ltjnvbm1O8byfoCAtz6kIXHLCucxFHsO(n3pMsIH8rJhrMiq9RFdb2XkHhcwsAyiF0Or5lPKgGfaqSlMGGyC0jLw(SJaoLLEfe4OtkT8zzbe)ldgjiOFdbMUcHGvx3ZUyq1VHatxHqWQR7zdPzv68mkrIWphLW36zydXlhjnvbm1O8zFPrYttDjVEH6)0MY0veJJYt0rsctoatUGahHuWiFjJJYt0rs(4jPdRM6DSHmya9kiu5tdgszpbldfq8VCinRsNNrjse(5Oe(wpdBiE5iPPkGPgLp7lnsEAQl5TJ24FHshthzFehGyLCBs7lucWkC40MY0veJdl5OeU(cLq9BUFmLed5JgpImrG6x)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmbbX4OtkT8zhbCkl9kiWrNuA5ZYci(xgmsqq)gcmDfcbRUUNDXGQFdbMUcHGvx3ZgsZQ05jKfjc)CucFRNHneVCK0ufWuJYN9Lgjpn1L86fQ)tBktxrmokprhjjm5am5ccCesbJ8Lmokprhj5JNKoSAQ3XgYGb0RGqLpnyiL9eSmuaX)YH0SkDEczrIWphLW36zydXlhjnvbm1O8zFPrYttDjVD0g)lu6y6i7J4aepTPmDfbW00OdMdt8lnXehGNM6shiUQWCeRsP6M2aGehIRX)cLm3BtOgIrIM43NKFPrrigXvfMJyvkv30gauKiUg)luY8n2JNrIM43NKFPrriclkX1HrkLeV5EQJ24FHshthzFehGO7TXDhGeaRWb)v(0GHu2tWYqbe)lhsZQ05P4ji4x)gcSXoPeDDYWqjaaiBinRsNNa5Wmnt0aiovk)M7htjXq(OrCHSiEHQFdb2yNuIUozyOeaaKDX86vqWV5(XusmKpAI40MY0veZCyIFPjM4ai9BiWiUQWCK0Hu2WgsZQ0fbm6zH7aOefKK6Me7l(rNCinRsauumi5bUrjIGG5(XusmKpAI40MY0veZCyIFPjM4ai9BiWiUQWCKuDtBydPzv6Iag9SWDauIcssDtI9f)OtoKMvjakkgK8a3OeXluIRkmhXQuAjGq97xmocPGr(sg3KvYzxmbbo6KslF2raNYsOIXrifmYxYinmKpAK6OeMDX8kiWrNuA5ZYci(xgmYlu)IXrNuA5ZoP8Xd4iiiM(neyCtwjNDXeem3pMsIH8rJhrMiEfe0VHaJBYk5SH0SkDEioGkM(neyJDsj66KHHsaaq2fRJ24FHshthzFehGys(KAiucWkCWV(neyexvyosQUPnSlMGGFoEBasUdrbDioEBasYV0ipHKxbboEBasUdq2ludtYXt8JD0g)lu6y6i7J4aeXBQGudHsawHd(1VHaJ4QcZrs1nTHDXee8ZXBdqYDikOdXXBdqs(Lg5jK8kiWXBdqYDaYEHAysoEIFSJ24FHshthzFehGy4Qusnekbyfo4x)gcmIRkmhjv30g2ftqWphVnaj3HOGoehVnaj5xAKNqYRGahVnaj3bi7fQHj54j(XoAJ)fkDmDK9rCaI(Szk0irbjPUj1rB8VqPJPJSpIdq092eQHayfoqCvH5iwLs1nTrqG4QcZrmhszJmjr)ccexvyoIzjGYKe9liOFdbMpBMcnsuqsQBsSlgu9BiWiUQWCKuDtByxmbb)63qGXnzLC2qAwLopn(xOK5BShpJenXVpj)sJGQFdbg3KvYzxmVD0g)lu6y6i7J4ae9n2JVJ24FHshthzFehG4CtPX)cLsv5EaMMgDiyk1JFUD0D0g)lu6yWdzA6vctZHtBktxramnn6GZcK8rYRJKomsPa4PPU0b)63qG9Lg5dnPeEittVsyAydPzv68aihMPzIocry4c1pXvfMJyvk1rpEbbIRkmhXQu6qkBeeiUQWCetDtBKjj63RGG(neyFPr(qtkHhY00ReMg2qAwLopm(xOK5EBc1qms0e)(K8lnkcry4c1pXvfMJyvkv30gbbIRkmhXCiLnYKe9liqCvH5iMLakts0VxVccIPFdb2xAKp0Ks4Hmn9kHPHDX6On(xO0XGhY00ReMMioar3BJ7oajawHd(f70MY0veZzbs(i51rshgPucc(1VHaBStkrxNmmucaaYgsZQ05jqomtZenaItLYV5(XusmKpAexilIxO63qGn2jLORtggkbaazxmVEfem3pMsIH8rJhrMiD0g)lu6yWdzA6vcttehGihLNOJK8Xtshwn17ayfo4)0MY0veJJYt0rsctoato0kFAWqk7jyzOaI)LdPzv68axilcuX4iKcg5lzCtwjNnKbdOGG(neyCtwjNDX8c1C)ykjgYhnEkEIa1V(neyexvyosQUPnSH0SkDEGRicc63qGrCvH5iPdPSHnKMvPZdCfXRGqOaI)LdPzv68exr6On(xO0XGhY00ReMMioard2W(6KKoF2ObqoGCfjFBasV7aUaSchedg9md2W(6KKoF2OjHnndiX(IFSsGqfZ4FHsMbByFDssNpB0KWMMbKyvkdQci(hQFXGrpZGnSVojPZNnAs8KPyFXpwjqbby0Zmyd7Rts68zJMepzk2qAwLopGKxbby0Zmyd7Rts68zJMe20mGeZ9g)ONqgkm6zgSH91jjD(SrtcBAgqInKMvPZtidfg9md2W(6KKoF2OjHnndiX(IFSsGD0g)lu6yWdzA6vcttehGOgcLHAiaYbKRi5Bdq6DhWfGv4WqHHC4nDfb9Tbi9SV0i5JKWf5bUrb1VF9BiW4MSsoBinRsNhqcQF9BiWg7Ks01jddLaaGSH0SkDEajbbX0VHaBStkrxNmmucaaYUyEfeet)gcmUjRKZUyccM7htjXq(OXtilIxO(ft)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmbbZ9JPKyiF04jKfXludtYXt8JE7On(xO0XGhY00ReMMioar3nd1qaKdixrY3gG07oGlaRWHHcd5WB6kc6Bdq6zFPrYhjHlYdCJcQF)63qGXnzLC2qAwLopGeu)63qGn2jLORtggkbaazdPzv68asccIPFdb2yNuIUozyOeaaKDX8kiiM(neyCtwjNDXeem3pMsIH8rJNqweVq9lM(neyhReEiyjPHH8rJgLVKsAawaaXUyccM7htjXq(OXtilIxOgMKJN4h92rB8VqPJbpKPPxjmnrCaIUNukBKbLnea5aYvK8Tbi9Ud4cWkCyOWqo8MUIG(2aKE2xAK8rs4I8a3ibQF)63qGXnzLC2qAwLopGeu)63qGn2jLORtggkbaazdPzv68asccIPFdb2yNuIUozyOeaaKDX8kiiM(neyCtwjNDXeem3pMsIH8rJNqweVq9lM(neyhReEiyjPHH8rJgLVKsAawaaXUyccM7htjXq(OXtilIxOgMKJN4h92rB8VqPJbpKPPxjmnrCaIb0Wjjkit7VdbWkCWWKC8e)yhTX)cLog8qMMELW0eXbio2jLORtggkbaabyfoOFdbg3KvYzxSoAJ)fkDm4Hmn9kHPjIdqK0Wq(OrQJsyawHd(9RFdbgXvfMJKoKYg2qAwLopWvebb9BiWiUQWCKuDtBydPzv68axr8cLJqkyKVKXnzLC2qAwLopGSiEfe4iKcg5lzCtwjNnKbdyhTX)cLog8qMMELW0eXbiYjf5(YustvatnkFawHdN2uMUIyCyjhLW1xOeQF)63qGDSs4HGLKggYhnAu(skPbybae7IjiighDsPLp7iGtzPxbbo6KslFwwaX)YGrccN2uMUIyLtAisqq)gcmDfcbRUUNDXGQFdbMUcHGvx3ZgsZQ05zuIeHFokHV1ZWgIxosAQcyQr5Z(sJKNM6sE9cvm9BiW4MSso7Ib1VyC0jLw(SSaI)LbJee4iKcg5lzCuEIosYhpjDy1uVJDXeeQ8PbdPSNGLHci(xoKMvPZtocPGr(sghLNOJK8Xtshwn17ydPzv6IiseeQ8PbdPSNGLHci(xoKMvPtCfxCfhI4zuIeHFokHV1ZWgIxosAQcyQr5Z(sJKNM6sE92rB8VqPJbpKPPxjmnrCaIvYTjTVqjaRWHtBktxrmoSKJs46luc1VF9BiWowj8qWssdd5JgnkFjL0aSaaIDXeeeJJoP0YNDeWPS0RGahDsPLpllG4FzWibHtBktxrSYjnejiOFdbMUcHGvx3ZUyq1VHatxHqWQR7zdPzv68eYIeHFokHV1ZWgIxosAQcyQr5Z(sJKNM6sE9cvm9BiW4MSso7Ib1VyC0jLw(SSaI)LbJee4iKcg5lzCuEIosYhpjDy1uVJDXeeQ8PbdPSNGLHci(xoKMvPZtocPGr(sghLNOJK8Xtshwn17ydPzv6IiseeQ8PbdPSNGLHci(xoKMvPtCfxCfhI4jKfjc)CucFRNHneVCK0ufWuJYN9Lgjpn1L86TJ24FHshdEittVsyAI4aepTPmDfbW00Odo7KKb0i5MSsoapn1Lo4xmocPGr(sg3KvYzdzWakii2PnLPRighLNOJKeMCaMCOC0jLw(SSaI)LbJ82rB8VqPJbpKPPxjmnrCaIH7aOefKK6MeaRWbIRkmhXQuAjGqnmjhpXpc1pm6zgSH91jjD(SrtcBAgqI9f)yLafeeJJoP0YNLeFqk0a7f6PnLPRiMZojzansUjRK3rB8VqPJbpKPPxjmnrCaIU3g3DasaSch4OtkT8zzbe)ldgb90MY0veJJYt0rsctoatouZ9JPKyiF04XbXteOCesbJ8Lmokprhj5JNKoSAQ3XgsZQ05jqomtZenaItLYV5(XusmKpAexilI3oAJ)fkDm4Hmn9kHPjIdqmjFsnekbyfo4x)gcmIRkmhjv30g2ftqWphVnaj3HOGoehVnaj5xAKNqYRGahVnaj3bi7fQHj54j(rON2uMUIyo7KKb0i5MSsEhTX)cLog8qMMELW0eXbiI3ubPgcLaSch8RFdbgXvfMJKQBAd7Ibvmo6KslF2raNYsbb)63qGDSs4HGLKggYhnAu(skPbybae7IbLJoP0YNDeWPS0RGGFoEBasUdrbDioEBasYV0ipHKxbboEBasUdqwqq)gcmUjRKZUyEHAysoEIFe6PnLPRiMZojzansUjRK3rB8VqPJbpKPPxjmnrCaIHRsj1qOeGv4GF9BiWiUQWCKuDtByxmOIXrNuA5Zoc4uwki4x)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmOC0jLw(SJaoLLEfe8ZXBdqYDikOdXXBdqs(Lg5jK8kiWXBdqYDaYcc63qGXnzLC2fZludtYXt8JqpTPmDfXC2jjdOrYnzL8oAJ)fkDm4Hmn9kHPjIdq0NntHgjkij1nPoAJ)fkDm4Hmn9kHPjIdq092eQHayfoqCvH5iwLs1nTrqG4QcZrmhszJmjr)ccexvyoIzjGYKe9liOFdbMpBMcnsuqsQBsSlgu9BiWiUQWCKuDtByxmbb)63qGXnzLC2qAwLopn(xOK5BShpJenXVpj)sJGQFdbg3KvYzxmVD0g)lu6yWdzA6vcttehGOVXE8D0g)lu6yWdzA6vcttehG4CtPX)cLsv5EaMMgDiyk1JFUD0D0g)lu6ybtPE8Z9G7TXDhGeaRWbXMBsb0aKy6MYsojrbPPuYhFLaDmksVfggb3rB8VqPJfmL6Xp3ioar3nd1qaKdixrY3gG07oGlaRWby0Z0qOmudXgsZQ05XqAwLUoAJ)fkDSGPup(5gXbiQHqzOgQJUJ24FHshZ9hmyd7Rts68zJga5aYvK8Tbi9Ud4cWkCqmy0Zmyd7Rts68zJMe20mGe7l(XkbcvmJ)fkzgSH91jjD(SrtcBAgqIvPmOkG4FO(fdg9md2W(6KKoF2OjXtMI9f)yLafeGrpZGnSVojPZNnAs8KPydPzv68asEfeGrpZGnSVojPZNnAsytZasm3B8JEczOWONzWg2xNK05ZgnjSPzaj2qAwLopHmuy0Zmyd7Rts68zJMe20mGe7l(Xkb2rB8VqPJ5(ioarokprhj5JNKoSAQ3bWkCW)PnLPRighLNOJKeMCaMCOIXrifmYxY4MSsoBidgqbb9BiW4MSso7I5fQ5(XusmKpA8u8ebQF9BiWiUQWCKuDtBydPzv68axree0VHaJ4QcZrshszdBinRsNh4kIxbHqbe)lhsZQ05jUI0rB8VqPJ5(ioaXtBktxramnn6am6LdfP3AinkFhapn1Lo4x)gcmUjRKZgsZQ05bKG6x)gcSXoPeDDYWqjaaiBinRsNhqsqqm9BiWg7Ks01jddLaaGSlMxbbX0VHaJBYk5SlMGG5(XusmKpA8eYI4fQFX0VHa7yLWdbljnmKpA0O8LusdWcai2ftqWC)ykjgYhnEczr8c1V(neyexvyos6qkBydPzv68aihMPzIwqq)gcmIRkmhjv30g2qAwLopaYHzAMO92rB8VqPJ5(ioarnekd1qaKdixrY3gG07oGlaRWHHcd5WB6kc6Bdq6zFPrYhjHlYdCJcQFdtYXt8JqpTPmDfXGrVCOi9wdPr5782rB8VqPJ5(ioar3nd1qaKdixrY3gG07oGlaRWHHcd5WB6kc6Bdq6zFPrYhjHlYdCJcQFdtYXt8JqpTPmDfXGrVCOi9wdPr5782rB8VqPJ5(ioar3tkLnYGYgcGCa5ks(2aKE3bCbyfomuyihEtxrqFBasp7lns(ijCrEGBKa1VHj54j(rON2uMUIyWOxouKERH0O8DE7On(xO0XCFehGyanCsIcY0(7qaSchmmjhpXp2rB8VqPJ5(ioaXXoPeDDYWqjaaiaRWb9BiW4MSso7I1rB8VqPJ5(ioarsdd5JgPokHbyfo43V(neyexvyos6qkBydPzv68axree0VHaJ4QcZrs1nTHnKMvPZdCfXluocPGr(sg3KvYzdPzv68aYIa1V(neyytPHg4YusB4wwCj2v5SHDAQl5zuINiccIn3KcObiXWMsdnWLPK2WTS4sSRYzdJI0BHHrWE9kiOFdbg2uAObUmL0gULfxIDvoByNM6sECikCMiccCesbJ8LmUjRKZgYGbeQFZ9JPKyiF04rKjIGWPnLPRiw5KgI82rB8VqPJ5(ioaroPi3xMsAQcyQr5dWkC40MY0veJdl5OeU(cLq9BUFmLed5JgpImrG6x)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmbbX4OtkT8zhbCkl9kiWrNuA5ZYci(xgmsq40MY0veRCsdrcc63qGPRqiy119Slgu9BiW0vieS66E2qAwLopJsKi87pYaqZnPaAasmSP0qdCzkPnCllUe7QC2WOi9wyyeS3i8Zrj8TEg2q8YrstvatnkF2xAK80uxYRxVqft)gcmUjRKZUyq9lghDsPLpllG4FzWibbocPGr(sghLNOJK8Xtshwn17yxmbHkFAWqk7jyzOaI)LdPzv68KJqkyKVKXr5j6ijF8K0Hvt9o2qAwLUiIebHkFAWqk7jyzOaI)LdPzv6exXfxXHiEgLir4NJs4B9mSH4LJKMQaMAu(SV0i5PPUKxVD0g)lu6yUpIdqSsUnP9fkbyfoCAtz6kIXHLCucxFHsO(n3pMsIH8rJhrMiq9RFdb2XkHhcwsAyiF0Or5lPKgGfaqSlMGGyC0jLw(SJaoLLEfe4OtkT8zzbe)ldgjiCAtz6kIvoPHibb9BiW0vieS66E2fdQ(ney6kecwDDpBinRsNNqwKi87pYaqZnPaAasmSP0qdCzkPnCllUe7QC2WOi9wyyeS3i8Zrj8TEg2q8YrstvatnkF2xAK80uxYRxVqft)gcmUjRKZUyq9lghDsPLpllG4FzWibbocPGr(sghLNOJK8Xtshwn17yxmbHkFAWqk7jyzOaI)LdPzv68KJqkyKVKXr5j6ijF8K0Hvt9o2qAwLUiIebHkFAWqk7jyzOaI)LdPzv6exXfxXHiEczrIWphLW36zydXlhjnvbm1O8zFPrYttDjVE7On(xO0XCFehG4PnLPRiaMMgDWzNKmGgj3KvYb4PPU0b)IXrifmYxY4MSsoBidgqbbXoTPmDfX4O8eDKKWKdWKdLJoP0YNLfq8VmyK3oAJ)fkDm3hXbigUdGsuqsQBsaSchiUQWCeRsPLac1WKC8e)iu9BiWWMsdnWLPK2WTS4sSRYzd70uxYZOeprG6hg9md2W(6KKoF2OjHnndiX(IFSsGccIXrNuA5ZsIpifAG9c90MY0veZzNKmGgj3KvY7On(xO0XCFehGO7TjykfaRWb9BiWqj94DsmA4e2xOKDXGQFdbM7TjykfBOWqo8MUI6On(xO0XCFehGi3soPK63qaGPPrhCVnk0adWkCq)gcm3BJcnWSH0SkDEcjO(1VHaJ4QcZrshszdBinRsNhqsqq)gcmIRkmhjv30g2qAwLopGKxOM7htjXq(OXJitKoAJ)fkDm3hXbi6EBcMsbWkC4nfLpZ9KszJeEQWZO00vemuh9FLaDmhsHKWtfEO63qG5EBcMsXGr(YoAJ)fkDm3hXbi6EBC3bibWkCGJoP0YNLfq8Vmye0tBktxrmokprhjjm5am5q5iKcg5lzCuEIosYhpjDy1uVJnKMvPZti1rB8VqPJ5(ioar3BtWukawHdVPO8zUNukBKWtfEgLMUIGHk2BkkFM7TrHgygLMUIGHQFdbM7TjykfBOWqo8MUIG6x)gcmIRkmhjv30g2qAwLopIeOexvyoIvPuDtBGQFdbg2uAObUmL0gULfxIDvoByNM6sEgfKerqq)gcmSP0qdCzkPnCllUe7QC2Won1L84quqseOM7htjXq(OXJitebby0Zmyd7Rts68zJMe20mGeBinRsNhIdbbJ)fkzgSH91jjD(SrtcBAgqIvPmOkG4FVqfJJqkyKVKXnzLC2qgmGD0g)lu6yUpIdq0924UdqcGv4G(neyOKE8ojxr2iplxHs2ftqq)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmbb9BiW4MSso7Ib1V(neyJDsj66KHHsaaq2qAwLopbYHzAMObqCQu(n3pMsIH8rJ4czr8cv)gcSXoPeDDYWqjaai7IjiiM(neyJDsj66KHHsaaq2fdQyCesbJ8LSXoPeDDYWqjaaiBidgqbbX4OtkT8zNu(4bC8kiyUFmLed5JgpImrGsCvH5iwLslbSJ24FHshZ9rCaIU3g3DasaSchEtr5ZCVnk0aZO00vemu)63qG5EBuObMDXeem3pMsIH8rJhrMiEHQFdbM7TrHgyM7n(rpHmu)63qGrCvH5iPdPSHDXee0VHaJ4QcZrs1nTHDX8cv)gcmSP0qdCzkPnCllUe7QC2Won1L8mkCMiq9ZrifmYxY4MSsoBinRsNh4kIGGyN2uMUIyCuEIossyYbyYHYrNuA5ZYci(xgmYBhTX)cLoM7J4aeDVnU7aKayfo4x)gcmSP0qdCzkPnCllUe7QC2Won1L8mkCMicc63qGHnLgAGltjTHBzXLyxLZg2PPUKNrbjrG(MIYN5EsPSrcpv4zuA6kc2lu9BiWiUQWCK0Hu2WgsZQ05bodkXvfMJyvkDiLnqft)gcmuspENeJgoH9fkzxmOI9MIYN5EBuObMrPPRiyOCesbJ8LmUjRKZgsZQ05bodQFocPGr(sgPHH8rJuhLWSH0SkDEGZeeeJJoP0YNDeWPS0BhTX)cLoM7J4aetYNudHsawHd(1VHaJ4QcZrs1nTHDXee8ZXBdqYDikOdXXBdqs(Lg5jK8kiWXBdqYDaYEHAysoEIFe6PnLPRiMZojzansUjRK3rB8VqPJ5(ioar8Mki1qOeGv4GF9BiWiUQWCKuDtByxmOIXrNuA5Zoc4uwki4x)gcSJvcpeSK0Wq(OrJYxsjnalaGyxmOC0jLw(SJaoLLEfe8ZXBdqYDikOdXXBdqs(Lg5jK8kiWXBdqYDaYcc63qGXnzLC2fZludtYXt8JqpTPmDfXC2jjdOrYnzL8oAJ)fkDm3hXbigUkLudHsawHd(1VHaJ4QcZrs1nTHDXGkghDsPLp7iGtzPGGF9BiWowj8qWssdd5JgnkFjL0aSaaIDXGYrNuA5Zoc4uw6vqWphVnaj3HOGoehVnaj5xAKNqYRGahVnaj3biliOFdbg3KvYzxmVqnmjhpXpc90MY0veZzNKmGgj3KvY7On(xO0XCFehGOpBMcnsuqsQBsD0g)lu6yUpIdq092eQHayfoqCvH5iwLs1nTrqG4QcZrmhszJmjr)ccexvyoIzjGYKe9liOFdbMpBMcnsuqsQBsSlgu9BiWiUQWCKuDtByxmbb)63qGXnzLC2qAwLopn(xOK5BShpJenXVpj)sJGQFdbg3KvYzxmVD0g)lu6yUpIdq03yp(oAJ)fkDm3hXbio3uA8VqPuvUhGPPrhcMs94Nl4d(GGa]] )


end