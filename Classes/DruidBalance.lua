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


    spec:RegisterPack( "Balance", 20201221, [[dO0AHdqicLhbvuCjcvztG4tqfvJIQYPOkTkaiVsimla0TGks7cv)cKYWGkDmOklti1ZajnnOQY1aPABcr8nOQkJdaQZjeP1rOQmpQQ6EQG9rvLdcvvvleQkpuiktKqvfUiHQk6JeQQ0jHkkzLcjZeQiUjHQQYobj(jHQQQHsOQklfQOupvOMkuHVcvvfJfQQkTxG(lrdwPdtzXKQhJYKb1Lr2SGpdOrtiNwYRvHMnj3Mu2TOFdz4q54cr1Yv8CQmDvDDvA7QOVtvmEcvopaTEaW8jy)sniEG4amg2EcekrJB04Ix0rJhhxamubW4fPGXpGyeymMXoAajW400iWy8zklzeymMbOczWG4am2HUdJaJf9pMt8bnObSErxDodPbnxPDv2xOKnw4HMR0yqdmw)wQhNvcQdgdBpbcLOXnACXl6OXJJlagQqhp8dm2UVi0aghxArgySOcgMsqDWyyYXaJXz6fFMYsg1R4hZTG7OWz6v8dIrA600B04cWEJg3OXTJQJcNP3itKLajN4RJcNPxCAV4)WWeCVXiLn9IpY04Du4m9It7nYezjqcU33gG0lRqVmZrUEFuVmazks(2aKEhVJcNPxCAV4Sjn0jb37ntIroNna27PnLPRixV(koXbyVydDkDVnU7aK6fN6xVydDYDVnU7aK8Y7OWz6fN2l()jQG7fBiM5(kb2l(NXEr9wHERhN769fr96zqjWEf)KPkmhX7OWz6fN2R4F2rQ3idLNOJuVViQ3ySAQ31R1RQ(xr9QHgQ3GIexPROE9vHEbeD7vKbN48Vxr13B996kTR6TKqxNcWE9uVOEXN4)4)4O3i6nYif5(Yu9I)RkGPgLpa7TECoCVUJfMxoySQCVdehGXydXqA62dIdqOGhioaJn2xOemwdHYJvkdOrdmMstxrWG4d8bHs0G4am2yFHsW4JvcpeS0Hvt9oWyknDfbdIpWhekqfehGXuA6kcgeFGXg7lucg7zSxeymBQNMYaJ91lXufMJ4QBAJmjX99ki0lXufMJ4vkv30MEfe6LyQcZr8kL6OxuVcc9smvH5iULaktsCFVEbJvvssgmymE4c(Gqb)aXbymLMUIGbXhymBQNMYaJ91lXufMJ4QBAJmjX99ki0lXufMJ4vkv30MEfe6LyQcZr8kL6OxuVcc9smvH5iULaktsCFVE7fsVydDYXJ7zSxuVq6vSEXg6Khn3ZyViWyJ9fkbJ9m2lc8bHc0bXbymLMUIGbXhymBQNMYaJfR35MuanajUUPSKrsuqAkL8fvjqhNstxrW9ki0Ry9YqNuA5ZZcOOxgmQxbHEfRxhgPuY3gG074U3MGPu9EOx86vqOxX69nfLppT)oKtQBklzeNstxrWGXg7lucg7EBc1qGpiuIeqCagtPPRiyq8bgZM6PPmW45MuanajUUPSKrsuqAkL8fvjqhNstxrW9cPxg6KslFEwaf9YGr9cPxhgPuY3gG074U3MGPu9EOx8aJn2xOem2924Udqc8bFWyykyx1dIdqOGhioaJn2xOem2Hu2i1jtdmMstxrWG4d8bHs0G4amMstxrWG4dmgHbg7Ohm2yFHsW4tBktxrGXNM6sGXomsPKVnaP3XDVnbtP61VEXRxi96RxX69nfLp392OqdmNstxrW9ki07BkkFU7jLYgj8uHNtPPRi4E92RGqVomsPKVnaP3XDVnbtP61VEJgm(0gzAAeyC5KgIaFqOavqCagtPPRiyq8bgJWaJD0dgBSVqjy8PnLPRiW4ttDjWyhgPuY3gG074U3MqnuV(1lEGXN2ittJaJlNKPi7KaFqOGFG4amMstxrWG4dmMn1ttzGX(6vSEzOtkT85zbu0ldg1RGqVI1ldHuWipjNHYt0rs(IiPdRM6D8lwVE7fsV63qGZmzLm(fdm2yFHsWyDAC0CSsGGpiuGoioaJP00vemi(aJzt90ugyS(ne4mtwjJFXaJn2xOemgd9fkbFqOejG4amMstxrWG4dmgHbg7Ohm2yFHsW4tBktxrGXNM6sGXbfcn96RxF9w5tdgszpbldfqrVCinRsxV40EJg3EXP9YqifmYtYzO8eDKKVis6WQPEhFinRsxVE7fA9Ix042R3E9R3GcHME91RVER8PbdPSNGLHcOOxoKMvPRxCAVrd9EXP96Rx8WTxauVVPO85vYSjTVqjNstxrW96TxCAV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE7fN2ldHuWipjNzYkz8H0SkD96TxO1lEayC71BVcc9YqifmYtYzMSsgFinRsxV(1BLpnyiL9eSmuaf9YH0SkD9ki0ldHuWipjNHYt0rs(IiPdRM6D8H0SkD96xVv(0GHu2tWYqbu0lhsZQ01RGqVI1ldDsPLpplGIEzWiW4tBKPPrGXmuEIossyYbyYaFqOG)aXbymLMUIGbXhymcdm2rpySX(cLGXN2uMUIaJpn1LaJ91Ry9sr(TWWiyoPHb4qMsIg40sg1RGqVmesbJ8KCsddWHmLenWPLmIpKMvPRx)7fVib3EH0Ry9YqifmYtYjnmahYus0aNwYi(qgmG96Txi96RxX6LI8BHHrWCh6Qu0)vcuoxDa7vqOxgcPGrEsUdDvk6)kbkNRoGsOIFqhaJlE8H0SkD96FV4HlU9cPxX6LHqkyKNK7qxLI(VsGY5QdOeQ4h0bW4IhFidgWE92RGqVm0jLw(8JaoLLGXN2ittJaJzWsgkHRVqj4dcfamioaJP00vemi(aJn2xOemM0WaCitjrdCAjJaJzt90ugymdHuWipjNzYkz8H0SkD96FVrJBVq690MY0veNHYt0rsctoatwVcc9YqifmYtYzO8eDKKVis6WQPEhFinRsxV(3B04cgNMgbgtAyaoKPKOboTKrGpiuIuqCagtPPRiyq8bgBSVqjySdDvk6)kbkNRoGGXSPEAkdmMHqkyKNKZmzLm(qAwLUE9V3OXTxi9EAtz6kIZq5j6ijHjhGjRxbHEziKcg5j5muEIosYxejDy1uVJpKMvPRx)7nAC7vqOxkYVfggbZjnmahYus0aNwYiW400iWyh6Qu0)vcuoxDabFqOGhUG4amMstxrWG4dm2yFHsW4kDS5(MUIKr(1Y)QjHPZIrGXSPEAkdmw)gcCMjRKXVyGXPPrGXv6yZ9nDfjJ8RL)vtctNfJaFqOGhEG4amMstxrWG4dmMn1ttzGX63qGZmzLm(fRxbHEziKcg5j5mtwjJpKMvPRx)6fpC7fsVI1ldDsPLp)iGtzzVcc9YqNuA5ZZcOOxgmQxi9EAtz6kIZq5j6ijHjhGjRxi9YqifmYtYzO8eDKKVis6WQPEh)I1lKEfRxgcPGrEsoZKvY4xSEH0RVE91R(ne4etvyosQUPn8H0SkD96xV4HBVcc9QFdboXufMJKoKYg(qAwLUE9Rx8WTxV9cPxX6DUjfqdqIRBklzKefKMsjFrvc0XP00veCVcc9o3KcObiX1nLLmsIcstPKVOkb64uA6kcUxi96Rx9BiW1nLLmsIcstPKVOkb6KP93H4U3yh71VEHAVcc9QFdbUUPSKrsuqAkL8fvjqN0gMLe39g7yV(1lu71BVE7vqOx9BiWpwj8qWssdd5HgnkFjL0aSaaIFX6vqO3qbu0lhsZQ01R)9gnUGXg7lucgFDKSEsZb(GqbVObXbymLMUIGbXhymBQNMYaJpTPmDfXlN0qeyS7NI9GqbpWyJ9fkbJNBkn2xOuQk3dgRk3lttJaJneb(GqbpOcIdWyknDfbdIpWy2upnLbgp3KcObiX)sJ8GMucpKPPxjmnCkYVfggbdg7(PypiuWdm2yFHsW45MsJ9fkLQY9GXQY9Y00iWy4Hmn9kHPb8bHcE4hioaJP00vemi(aJzt90ugy8CtkGgGex3uwYijkinLs(IQeOJtr(TWWiyWy3pf7bHcEGXg7lucgp3uASVqPuvUhmwvUxMMgbgRJSh8bHcEqhehGXuA6kcgeFGXg7lucgp3uASVqPuvUhmwvUxMMgbg7EWh8bJHhY00ReMgqCacf8aXbymLMUIGbXhymcdm2rpySX(cLGXN2uMUIaJpn1LaJ91R(ne4FPrEqtkHhY00ReMg(qAwLUE9RxGmyUMjUEJOxC541lKE91lXufMJ4vk1rVOEfe6LyQcZr8kLoKYMEfe6LyQcZrC1nTrMK4(E92RGqV63qG)Lg5bnPeEittVsyA4dPzv661VEn2xOK7EBc1qCsCe7(K8lnQ3i6fxoE9cPxF9smvH5iELs1nTPxbHEjMQWCe3Hu2itsCFVcc9smvH5iULaktsCFVE71BVcc9kwV63qG)Lg5bnPeEittVsyA4xmW4tBKPPrGXolqYhjVos6WiLc8bHs0G4amMstxrWG4dmMn1ttzGX(6vSEpTPmDfXDwGKpsEDK0HrkvVcc96Rx9BiWh7Ks01jddLaaG8H0SkD96FVazWCntC9cG6LrLQxF9AUFmLed5HMEHwVqf3E92lKE1VHaFStkrxNmmucaaYVy96TxV9ki0R5(XusmKhA61VEJuCbJn2xOem2924Udqc8bHcubXbymLMUIGbXhymBQNMYaJ917PnLPRiodLNOJKeMCaMSEH0BLpnyiL9eSmuaf9YH0SkD96xV4bvC7fsVI1ldHuWipjNzYkz8Hmya7vqOx9BiWzMSsg)I1R3EH0R5(XusmKhA61)EXpC7fsV(6v)gcCIPkmhjv30g(qAwLUE9Rx8WTxbHE1VHaNyQcZrshszdFinRsxV(1lE42R3Efe6nuaf9YH0SkD96FV4HlySX(cLGXmuEIosYxejDy1uVd8bHc(bIdWyknDfbdIpWyJ9fkbJnyd7Rts68yJgymBQNMYaJfRxy0Znyd7Rts68yJMe20mGe)l2Xkb2lKEfRxJ9fk5gSH91jjDESrtcBAgqIxPmOkGI(EH0RVEfRxy0Znyd7Rts68yJMuezk(xSJvcSxbHEHrp3GnSVojPZJnAsrKP4dPzv661VEHEVE7vqOxy0Znyd7Rts68yJMe20mGe39g7yV(3lu7fsVWONBWg2xNK05XgnjSPzaj(qAwLUE9VxO2lKEHrp3GnSVojPZJnAsytZas8VyhReiymdqMIKVnaP3bcf8aFqOaDqCagtPPRiyq8bgBSVqjySgcLHAiWy2upnLbgpuyiNitxr9cP33gG0Z)sJKpscxuV(1lEr3lKE91RVE1VHaNzYkz8H0SkD96xVqVxi96Rx9BiWh7Ks01jddLaaG8H0SkD96xVqVxbHEfRx9BiWh7Ks01jddLaaG8lwVE7vqOxX6v)gcCMjRKXVy9ki0R5(XusmKhA61)EHkU96Txi96RxX6v)gc8JvcpeSK0WqEOrJYxsjnalaG4xSEfe61C)ykjgYdn96FVqf3E92lKEnmjteXo2RxWygGmfjFBasVdek4b(GqjsaXbymLMUIGbXhySX(cLGXUBgQHaJzt90ugy8qHHCImDf1lKEFBasp)lns(ijCr96xV4fDVq61xV(6v)gcCMjRKXhsZQ01RF9c9EH0RVE1VHaFStkrxNmmucaaYhsZQ01RF9c9Efe6vSE1VHaFStkrxNmmucaaYVy96TxbHEfRx9BiWzMSsg)I1RGqVM7htjXqEOPx)7fQ42R3EH0RVEfRx9BiWpwj8qWssdd5HgnkFjL0aSaaIFX6vqOxZ9JPKyip00R)9cvC71BVq61WKmre7yVEbJzaYuK8Tbi9oqOGh4dcf8hioaJP00vemi(aJn2xOem29KszJmOSHaJzt90ugy8qHHCImDf1lKEFBasp)lns(ijCr96xV4fj9cPxF96Rx9BiWzMSsgFinRsxV(1l07fsV(6v)gc8XoPeDDYWqjaaiFinRsxV(1l07vqOxX6v)gc8XoPeDDYWqjaai)I1R3Efe6vSE1VHaNzYkz8lwVcc9AUFmLed5HME9VxOIBVE7fsV(6vSE1VHa)yLWdbljnmKhA0O8LusdWcai(fRxbHEn3pMsIH8qtV(3luXTxV9cPxdtYerSJ96fmMbitrY3gG07aHcEGpiuaWG4amMstxrWG4dmMn1ttzGXgMKjIyhbJn2xOemoGggjrbzA)DiWhekrkioaJP00vemi(aJzt90ugyS(ne4mtwjJFXaJn2xOemEStkrxNmmucaac(GqbpCbXbymLMUIGbXhymBQNMYaJ91RVE1VHaNyQcZrshszdFinRsxV(1lE42RGqV63qGtmvH5iP6M2WhsZQ01RF9IhU96Txi9YqifmYtYzMSsgFinRsxV(1luXTxV9ki0ldHuWipjNzYkz8HmyabJn2xOemM0WqEOrQJsyWhek4HhioaJP00vemi(aJzt90ugy8PnLPRiodwYqjC9fk7fsV(61xV63qGFSs4HGLKggYdnAu(skPbybae)I1RGqVI1ldDsPLp)iGtzzVE7vqOxg6KslFEwaf9YGr9ki07PnLPRiE5KgI6vqOx9BiW1vieS66E(fRxi9QFdbUUcHGvx3ZhsZQ01R)9gnU9grV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE71BVq6vSE1VHaNzYkz8lwVq61xVI1ldDsPLpplGIEzWOEfe6LHqkyKNKZq5j6ijFrK0Hvt9o(fRxbHER8PbdPSNGLHcOOxoKMvPRx)7LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUEJO3iPxbHER8PbdPSNGLHcOOxoKMvPRxXRx8aW42R)9gnU9grV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE71lySX(cLGXmsrUVmL0ufWuJYh8bHcErdIdWyknDfbdIpWy2upnLbgFAtz6kIZGLmucxFHYEH0RVE91R(ne4hReEiyjPHH8qJgLVKsAawaaXVy9ki0Ry9YqNuA5Zpc4uw2R3Efe6LHoP0YNNfqrVmyuVcc9EAtz6kIxoPHOEfe6v)gcCDfcbRUUNFX6fsV63qGRRqiy1198H0SkD96FVqf3EJOxF9Yqj8TEo2qSYrstvatnkF(xAK80uxQxV96Txi9kwV63qGZmzLm(fRxi96RxX6LHoP0YNNfqrVmyuVcc9YqifmYtYzO8eDKKVis6WQPEh)I1RGqVv(0GHu2tWYqbu0lhsZQ01R)9YqifmYtYzO8eDKKVis6WQPEhFinRsxVr0BK0RGqVv(0GHu2tWYqbu0lhsZQ01R41lEayC71)EHkU9grV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE71lySX(cLGXvYSjTVqj4dcf8GkioaJP00vemi(aJryGXo6bJn2xOem(0MY0vey8PPUeySVEfRxgcPGrEsoZKvY4dzWa2RGqVI17PnLPRiodLNOJKeMCaMSEH0ldDsPLpplGIEzWOE9cgFAJmnncm2zNKmGgjZKvYaFqOGh(bIdWyknDfbdIpWy2upnLbgtmvH5iELslbSxi9AysMiIDSxi96Rxy0Znyd7Rts68yJMe20mGe)l2Xkb2RGqVI1ldDsPLppj2GuObUxV9cP3tBktxrCNDsYaAKmtwjdm2yFHsW4WDauIcssDtc8bHcEqhehGXuA6kcgeFGXSPEAkdmMHoP0YNNfqrVmyuVq690MY0veNHYt0rsctoatwVq61C)ykjgYdn963HEXpC7fsVmesbJ8KCgkprhj5lIKoSAQ3XhsZQ01R)9cKbZ1mX1laQxgvQE91R5(XusmKhA6fA9cvC71lySX(cLGXU3g3DasGpiuWlsaXbymLMUIGbXhymBQNMYaJ91R(ne4etvyosQUPn8lwVcc96RxMiBasUEp0B09cP3HyISbij)sJ61)EHEVE7vqOxMiBasUEp0lu71BVq61WKmre7yVq690MY0ve3zNKmGgjZKvYaJn2xOemojpsnekbFqOGh(dehGXuA6kcgeFGXSPEAkdm2xV63qGtmvH5iP6M2WVy9cPxX6LHoP0YNFeWPSSxbHE91R(ne4hReEiyjPHH8qJgLVKsAawaaXVy9cPxg6KslF(raNYYE92RGqV(6LjYgGKR3d9gDVq6DiMiBasYV0OE9VxO3R3Efe6LjYgGKR3d9c1Efe6v)gcCMjRKXVy96Txi9AysMiIDSxi9EAtz6kI7StsgqJKzYkzGXg7lucglYubPgcLGpiuWdadIdWyknDfbdIpWy2upnLbg7Rx9BiWjMQWCKuDtB4xSEH0Ry9YqNuA5Zpc4uw2RGqV(6v)gc8JvcpeSK0WqEOrJYxsjnalaG4xSEH0ldDsPLp)iGtzzVE7vqOxF9YezdqY17HEJUxi9oetKnaj5xAuV(3l071BVcc9YezdqY17HEHAVcc9QFdboZKvY4xSE92lKEnmjteXo2lKEpTPmDfXD2jjdOrYmzLmWyJ9fkbJdxLsQHqj4dcf8IuqCagBSVqjyShBMcnsuqsQBsGXuA6kcgeFGpiuIgxqCagtPPRiyq8bgZM6PPmWyIPkmhXRuQUPn9ki0lXufMJ4oKYgzsI77vqOxIPkmhXTeqzsI77vqOx9BiW9yZuOrIcssDtIFX6fsV63qGtmvH5iP6M2WVy9ki0RVE1VHaNzYkz8H0SkD96FVg7luY9m2lItIJy3NKFPr9cPx9BiWzMSsg)I1RxWyJ9fkbJDVnHAiWhekrJhioaJn2xOem2ZyViWyknDfbdIpWhekrhnioaJP00vemi(aJn2xOemEUP0yFHsPQCpySQCVmnncmoyk1lAUGp4dgBicehGqbpqCagtPPRiyq8bgJWaJD0dgBSVqjy8PnLPRiW4ttDjWyF9QFdb(xAKh0Ks4Hmn9kHPHpKMvPRx)7fidMRzIR3i6fxoE9ki0R(ne4FPrEqtkHhY00ReMg(qAwLUE9VxJ9fk5U3MqneNehXUpj)sJ6nIEXLJxVq61xVetvyoIxPuDtB6vqOxIPkmhXDiLnYKe33RGqVetvyoIBjGYKe33R3E92lKE1VHa)lnYdAsj8qMMELW0WVy9cP35Muanaj(xAKh0Ks4Hmn9kHPHtr(TWWiyW4tBKPPrGXWdzAspLsjdMsjrHa4dcLObXbymLMUIGbXhymBQNMYaJ917PnLPRiodLNOJKeMCaMSEH0Ry9YqifmYtYzMSsgFidgWEfe6v)gcCMjRKXVy96Txi9AUFmLed5HME9VxOJBVq61xV63qGtmvH5iP6M2WhsZQ01RF9gj9ki0R(ne4etvyos6qkB4dPzv661VEJKE92lKE91Ry9o3KcObiX1nLLmsIcstPKVOkb64uA6kcUxbHE1VHax3uwYijkinLs(IQeOtM2FhI7EJDSx)6fQ9ki0R(ne46MYsgjrbPPuYxuLaDsBywsC3BSJ96xVqTxV9ki0BOak6LdPzv661)EXdxWyJ9fkbJzO8eDKKVis6WQPEh4dcfOcIdWyknDfbdIpWy2upnLbgRFdbU7TjykfFOWqorMUI6fsV(61HrkL8Tbi9oU7TjykvV(3lu7vqOxX6DUjfqdqI)Lg5bnPeEittVsyA4uKFlmmcUxV9cPxF9kwVZnPaAasCfGmBmNmOi6ReOeOQ0WCeNI8BHHrW9ki07xAuVIxV4h071VE1VHa392emLIpKMvPR3i6n6E9cgBSVqjyS7Tjykf4dcf8dehGXuA6kcgeFGXSPEAkdmEUjfqdqI)Lg5bnPeEittVsyA4uKFlmmcUxi96WiLs(2aKEh392emLQx)o0lu7fsV(6vSE1VHa)lnYdAsj8qMMELW0WVy9cPx9BiWDVnbtP4dfgYjY0vuVcc96R3tBktxrC4HmnPNsPKbtPKOqOxi96Rx9BiWDVnbtP4dPzv661)EHAVcc96WiLs(2aKEh392emLQx)6n6EH07BkkFU7jLYgj8uHNtPPRi4EH0R(ne4U3MGPu8H0SkD96FVqVxV96TxVGXg7lucg7EBcMsb(Gqb6G4amMstxrWG4dmgHbg7Ohm2yFHsW4tBktxrGXNM6sGXM7htjXqEOPx)6faJBV40E91lE42laQx9BiW)sJ8GMucpKPPxjmnC3BSJ96TxCAV(6v)gcC3BtWuk(qAwLUEbq9c1EHwVomsPKIm3t96TxCAV(6fg98WDauIcssDtIpKMvPRxauVqVxV9cPx9BiWDVnbtP4xmW4tBKPPrGXU3MGPuspO8LbtPKOqa8bHsKaIdWyknDfbdIpWy2upnLbgFAtz6kIdpKPj9ukLmykLefc9cP3tBktxrC3BtWukPhu(YGPusui0RGqV(6v)gcCDtzjJKOG0uk5lQsGozA)DiU7n2XE9RxO2RGqV63qGRBklzKefKMsjFrvc0jTHzjXDVXo2RF9c1E92lKEDyKsjFBasVJ7EBcMs1R)9IFGXg7lucg7EBC3bib(Gqb)bIdWyknDfbdIpWyJ9fkbJD3mudbgZM6PPmW4Hcd5ez6kQxi9(2aKE(xAK8rs4I61VEXd)6fN2RdJuk5Bdq6D9grVdPzv66fsVgMKjIyh7fsVetvyoIxP0sabJzaYuK8Tbi9oqOGh4dcfamioaJP00vemi(aJn2xOem2GnSVojPZJnAGXSPEAkdmwSE)IDSsG9cPxX61yFHsUbByFDssNhB0KWMMbK4vkdQcOOVxbHEHrp3GnSVojPZJnAsytZasC3BSJ96FVqTxi9cJEUbByFDssNhB0KWMMbK4dPzv661)EHkymdqMIKVnaP3bcf8aFqOePG4amMstxrWG4dm2yFHsWynekd1qGXSPEAkdmEOWqorMUI6fsVVnaPN)LgjFKeUOE9RxF9Ih(1Be96RxhgPuY3gG074U3MqnuVaOEXJd9E92R3EHwVomsPKVnaP31Be9oKMvPRxi96RxgcPGrEsoZKvY4dzWa2lKE917PnLPRiodLNOJKeMCaMSEfe6LHqkyKNKZq5j6ijFrK0Hvt9o(qgmG9ki0Ry9YqNuA5ZZcOOxgmQxV9ki0RdJuk5Bdq6DC3BtOgQx)71xV4xVaOE91lE9grVVPO85VNkLAiu64uA6kcUxV96TxbHE91lXufMJ4vkDiLn9ki0RVEjMQWCeVsPo6f1RGqVetvyoIxPuDtB61BVq6vSEFtr5ZDORsIcYxejdOHCpNstxrW9ki0R(ne4ytPHg4YusBywwmj2v5SHFAQl1RFh6nAOJBVE7fsV(61HrkL8Tbi9oU7Tjud1R)9IhU9cG61xV41Be9(MIYN)EQuQHqPJtPPRi4E92R3EH0R5(XusmKhA61VEHoU9It7v)gcC3BtWuk(qAwLUEbq9gj96Txi96RxX6v)gc8JvcpeSK0WqEOrJYxsjnalaG4xSEfe6LyQcZr8kLoKYMEfe6vSEzOtkT85hbCkl71BVq61WKmre7iymdqMIKVnaP3bcf8aFqOGhUG4amMstxrWG4dmMn1ttzGXgMKjIyhbJn2xOemoGggjrbzA)DiWhek4HhioaJP00vemi(aJzt90ugyS(ne4mtwjJFXaJn2xOemEStkrxNmmucaac(GqbVObXbymLMUIGbXhymBQNMYaJpTPmDfXzWsgkHRVqzVq61xV63qG7EBcMsXVy9ki0R5(XusmKhA61VEHoU96Txi9kwV63qG7qk3xmIFX6fsVI1R(ne4mtwjJFX6fsV(6vSEzOtkT85zbu0ldg1RGqVN2uMUI4muEIossyYbyY6vqOxgcPGrEsodLNOJK8frshwn174xSEfe6TYNgmKYEcwgkGIE5qAwLUE9V3OXT3i61xVmucFRNJneRCK0ufWuJYN)Lgjpn1L61BVEbJn2xOemMrkY9LPKMQaMAu(GpiuWdQG4amMstxrWG4dmMn1ttzGXN2uMUI4myjdLW1xOSxi96Rx9BiWDVnbtP4xSEfe61C)ykjgYdn96xVqh3E92lKEfRx9BiWDiL7lgXVy9cPxX6v)gcCMjRKXVy9cPxF9kwVm0jLw(8Sak6LbJ6vqO3tBktxrCgkprhjjm5amz9ki0ldHuWipjNHYt0rs(IiPdRM6D8lwVcc9w5tdgszpbldfqrVCinRsxV(3ldHuWipjNHYt0rs(IiPdRM6D8H0SkD9grVrsVcc9w5tdgszpbldfqrVCinRsxVIxV4bGXTx)7fQ42Be96RxgkHV1ZXgIvosAQcyQr5Z)sJKNM6s96TxVGXg7lucgxjZM0(cLGpiuWd)aXbymLMUIGbXhymBQNMYaJR8PbdPSNGLHcOOxoKMvPRx)7fpO3RGqV(6v)gcCSP0qdCzkPnmllMe7QC2Wpn1L61)EJg642RGqV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(DO3OHoU96Txi9QFdbU7Tjykf)I1lKEziKcg5j5mtwjJpKMvPRx)6f64cgBSVqjymPHH8qJuhLWGpiuWd6G4amMstxrWG4dm2yFHsWy3tkLnYGYgcmMn1ttzGXdfgYjY0vuVq69lns(ijCr96xV4b9EH0RdJuk5Bdq6DC3BtOgQx)7f)6fsVgMKjIyh7fsV(6v)gcCMjRKXhsZQ01RF9IhU9ki0Ry9QFdboZKvY4xSE9cgZaKPi5Bdq6DGqbpWhek4fjG4amMstxrWG4dmMn1ttzGXetvyoIxP0sa7fsVgMKjIyh7fsV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(3B0qh3EH0RVEHrp3GnSVojPZJnAsytZas8VyhReyVcc9kwVm0jLw(8KydsHg4Efe61HrkL8Tbi9UE9R3O71lySX(cLGXH7aOefKK6Me4dcf8WFG4amMstxrWG4dmMn1ttzGX63qGJs6f5Ky0WiSVqj)I1lKE91R(ne4U3MGPu8Hcd5ez6kQxbHEn3pMsIH8qtV(1BKIBVEbJn2xOem292emLc8bHcEayqCagtPPRiyq8bgZM6PPmWyg6KslFEwaf9YGr9cPxF9EAtz6kIZq5j6ijHjhGjRxbHEziKcg5j5mtwjJFX6vqOx9BiWzMSsg)I1R3EH0ldHuWipjNHYt0rs(IiPdRM6D8H0SkD96FVazWCntC9cG6LrLQxF9AUFmLed5HMEHwVqh3E92lKE1VHa392emLIpKMvPRx)7f)aJn2xOem292emLc8bHcErkioaJP00vemi(aJzt90ugymdDsPLpplGIEzWOEH0RVEpTPmDfXzO8eDKKWKdWK1RGqVmesbJ8KCMjRKXVy9ki0R(ne4mtwjJFX61BVq6LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUE9V3iPxi9QFdbU7Tjykf)I1lKEjMQWCeVsPLacgBSVqjyS7TXDhGe4dcLOXfehGXuA6kcgeFGXSPEAkdmw)gcCusViNKPiBKNLRqj)I1RGqV(6vSEDVnHAiUHjzIi2XEfe61xV63qGZmzLm(qAwLUE9VxO3lKE1VHaNzYkz8lwVcc96Rx9BiWh7Ks01jddLaaG8H0SkD96FVazWCntC9cG6LrLQxF9AUFmLed5HMEHwVqf3E92lKE1VHaFStkrxNmmucaaYVy96TxV9cP3tBktxrC3BtWukPhu(YGPusui0lKEDyKsjFBasVJ7EBcMs1R)9c1E92lKE91Ry9o3KcObiX)sJ8GMucpKPPxjmnCkYVfggb3RGqVomsPKVnaP3XDVnbtP61)EHAVEbJn2xOem2924Udqc8bHs04bIdWyknDfbdIpWy2upnLbg7RxIPkmhXRuAjG9cPxgcPGrEsoZKvY4dPzv661VEHoU9ki0RVEzISbi569qVr3lKEhIjYgGK8lnQx)7f696TxbHEzISbi569qVqTxV9cPxdtYerSJGXg7lucgNKhPgcLGpiuIoAqCagtPPRiyq8bgZM6PPmWyF9smvH5iELslbSxi9YqifmYtYzMSsgFinRsxV(1l0XTxbHE91ltKnajxVh6n6EH07qmr2aKKFPr96FVqVxV9ki0ltKnajxVh6fQ96Txi9AysMiIDem2yFHsWyrMki1qOe8bHs0qfehGXuA6kcgeFGXSPEAkdm2xVetvyoIxP0sa7fsVmesbJ8KCMjRKXhsZQ01RF9cDC7vqOxF9YezdqY17HEJUxi9oetKnaj5xAuV(3l071BVcc9YezdqY17HEHAVE7fsVgMKjIyhbJn2xOemoCvkPgcLGpiuIg)aXbySX(cLGXESzk0irbjPUjbgtPPRiyq8b(GqjAOdIdWyknDfbdIpWyegySJEWyJ9fkbJpTPmDfbgFAQlbg7WiLs(2aKEh392eQH61VEXVEJO3GcHME91RM5EAauEAQl1l06nAC71BVr0BqHqtV(6v)gcC3BJ7oajjPHH8qJgLV0Hu2WDVXo2l06f)61ly8PnY00iWy3BtOgswP0Hu2a(Gqj6ibehGXuA6kcgeFGXSPEAkdmMyQcZrC1nTrMK4(Efe6LyQcZrClbuMK4(EH07PnLPRiE5KmfzNuVcc9QFdboXufMJKoKYg(qAwLUE9VxJ9fk5U3MqneNehXUpj)sJ6fsV63qGtmvH5iPdPSHFX6vqOxIPkmhXRu6qkB6fsVI17PnLPRiU7TjudjRu6qkB6vqOx9BiWzMSsgFinRsxV(3RX(cLC3BtOgItIJy3NKFPr9cPxX690MY0veVCsMIStQxi9QFdboZKvY4dPzv661)EjXrS7tYV0OEH0R(ne4mtwjJFX6vqOx9BiWh7Ks01jddLaaG8lwVq61HrkLuK5EQx)6fxEK0lKE91RdJuk5Bdq6D96)HEHAVcc9kwVVPO85o0vjrb5lIKb0qUNtPPRi4E92RGqVI17PnLPRiE5KmfzNuVq6v)gcCMjRKXhsZQ01RF9sIJy3NKFPrGXg7lucg7zSxe4dcLOXFG4am2yFHsWy3BtOgcmMstxrWG4d8bHs0ayqCagtPPRiyq8bgBSVqjy8CtPX(cLsv5EWyv5EzAAeyCWuQx0CbFWhmoyk1lAUG4aek4bIdWyknDfbdIpWy2upnLbglwVZnPaAasCDtzjJKOG0uk5lQsGoof53cdJGbJn2xOem2924Udqc8bHs0G4amMstxrWG4dm2yFHsWy3nd1qGXSPEAkdmgg9Cnekd1q8H0SkD96xVdPzv6aJzaYuK8Tbi9oqOGh4dcfOcIdWyJ9fkbJ1qOmudbgtPPRiyq8b(GpyS7bXbiuWdehGXuA6kcgeFGXg7lucgBWg2xNK05XgnWy2upnLbglwVWONBWg2xNK05XgnjSPzaj(xSJvcSxi9kwVg7luYnyd7Rts68yJMe20mGeVszqvaf99cPxF9kwVWONBWg2xNK05XgnPiYu8VyhReyVcc9cJEUbByFDssNhB0KIitXhsZQ01RF9c9E92RGqVWONBWg2xNK05XgnjSPzajU7n2XE9VxO2lKEHrp3GnSVojPZJnAsytZas8H0SkD96FVqTxi9cJEUbByFDssNhB0KWMMbK4FXowjqWygGmfjFBasVdek4b(GqjAqCagtPPRiyq8bgZM6PPmWyF9EAtz6kIZq5j6ijHjhGjRxi9kwVmesbJ8KCMjRKXhYGbSxbHE1VHaNzYkz8lwVE7fsVM7htjXqEOPx)7f)WTxi96Rx9BiWjMQWCKuDtB4dPzv661VEXd3Efe6v)gcCIPkmhjDiLn8H0SkD96xV4HBVE7vqO3qbu0lhsZQ01R)9IhUGXg7lucgZq5j6ijFrK0Hvt9oWhekqfehGXuA6kcgeFGXimWyh9GXg7lucgFAtz6kcm(0uxcm2xV63qGZmzLm(qAwLUE9RxO3lKE91R(ne4JDsj66KHHsaaq(qAwLUE9RxO3RGqVI1R(ne4JDsj66KHHsaaq(fRxV9ki0Ry9QFdboZKvY4xSEfe61C)ykjgYdn96FVqf3E92lKE91Ry9QFdb(XkHhcwsAyip0Or5lPKgGfaq8lwVcc9AUFmLed5HME9VxOIBVE7fsV(6v)gcCIPkmhjDiLn8H0SkD96xVazWCntC9ki0R(ne4etvyosQUPn8H0SkD96xVazWCntC96fm(0gzAAeymm6Ldf53AinkFh4dcf8dehGXuA6kcgeFGXg7lucgRHqzOgcmMn1ttzGXdfgYjY0vuVq69Tbi98V0i5JKWf1RF9Ix09cPxF9AysMiIDSxi9EAtz6kIdJE5qr(TgsJY31RxWygGmfjFBasVdek4b(Gqb6G4amMstxrWG4dm2yFHsWy3nd1qGXSPEAkdmEOWqorMUI6fsVVnaPN)LgjFKeUOE9Rx8IUxi96RxdtYerSJ9cP3tBktxrCy0lhkYV1qAu(UE9cgZaKPi5Bdq6DGqbpWhekrcioaJP00vemi(aJn2xOem29KszJmOSHaJzt90ugy8qHHCImDf1lKEFBasp)lns(ijCr96xV4fj9cPxF9AysMiIDSxi9EAtz6kIdJE5qr(TgsJY31RxWygGmfjFBasVdek4b(Gqb)bIdWyknDfbdIpWy2upnLbgBysMiIDem2yFHsW4aAyKefKP93HaFqOaGbXbymLMUIGbXhymBQNMYaJ1VHaNzYkz8lgySX(cLGXJDsj66KHHsaaqWhekrkioaJP00vemi(aJzt90ugySVE91R(ne4etvyos6qkB4dPzv661VEXd3Efe6v)gcCIPkmhjv30g(qAwLUE9Rx8WTxV9cPxgcPGrEsoZKvY4dPzv661VEHkU9cPxF9QFdbo2uAObUmL0gMLftIDvoB4NM6s96FVrJF42RGqVI17CtkGgGehBkn0axMsAdZYIjXUkNnCkYVfggb3R3E92RGqV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(DO3OXF42RGqVmesbJ8KCMjRKXhYGbSxi96RxZ9JPKyip00RF9gP42RGqVN2uMUI4LtAiQxVGXg7lucgtAyip0i1rjm4dcf8WfehGXuA6kcgeFGXSPEAkdm(0MY0veNblzOeU(cL9cPxF9AUFmLed5HME9R3if3EH0RVE1VHa)yLWdbljnmKhA0O8LusdWcai(fRxbHEfRxg6KslF(raNYYE92RGqVm0jLw(8Sak6LbJ6vqO3tBktxr8Yjne1RGqV63qGRRqiy1198lwVq6v)gcCDfcbRUUNpKMvPRx)7nAC7nIE91RVEJ0Ebq9o3KcObiXXMsdnWLPK2WSSysSRYzdNI8BHHrW96T3i61xVmucFRNJneRCK0ufWuJYN)Lgjpn1L61BVE71BVq6vSE1VHaNzYkz8lwVq61xVI1ldDsPLpplGIEzWOEfe6LHqkyKNKZq5j6ijFrK0Hvt9o(fRxbHER8PbdPSNGLHcOOxoKMvPRx)7LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUEJO3iPxbHER8PbdPSNGLHcOOxoKMvPRxXRx8aW42R)9gnU9grV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE71lySX(cLGXmsrUVmL0ufWuJYh8bHcE4bIdWyknDfbdIpWy2upnLbgFAtz6kIZGLmucxFHYEH0RVEn3pMsIH8qtV(1BKIBVq61xV63qGFSs4HGLKggYdnAu(skPbybae)I1RGqVI1ldDsPLp)iGtzzVE7vqOxg6KslFEwaf9YGr9ki07PnLPRiE5KgI6vqOx9BiW1vieS66E(fRxi9QFdbUUcHGvx3ZhsZQ01R)9cvC7nIE91RVEJ0Ebq9o3KcObiXXMsdnWLPK2WSSysSRYzdNI8BHHrW96T3i61xVmucFRNJneRCK0ufWuJYN)Lgjpn1L61BVE71BVq6vSE1VHaNzYkz8lwVq61xVI1ldDsPLpplGIEzWOEfe6LHqkyKNKZq5j6ijFrK0Hvt9o(fRxbHER8PbdPSNGLHcOOxoKMvPRx)7LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUEJO3iPxbHER8PbdPSNGLHcOOxoKMvPRxXRx8aW42R)9cvC7nIE91ldLW365ydXkhjnvbm1O85FPrYttDPE92RxWyJ9fkbJRKztAFHsWhek4fnioaJP00vemi(aJryGXo6bJn2xOem(0MY0vey8PPUeySVEfRxgcPGrEsoZKvY4dzWa2RGqVI17PnLPRiodLNOJKeMCaMSEH0ldDsPLpplGIEzWOE9cgFAJmnncm2zNKmGgjZKvYaFqOGhubXbymLMUIGbXhymBQNMYaJjMQWCeVsPLa2lKEnmjteXo2lKE1VHahBkn0axMsAdZYIjXUkNn8ttDPE9V3OXpC7fsV(6fg9Cd2W(6KKop2OjHnndiX)IDSsG9ki0Ry9YqNuA5ZtInifAG71BVq690MY0ve3zNKmGgjZKvYaJn2xOemoChaLOGKu3KaFqOGh(bIdWyknDfbdIpWy2upnLbgRFdbokPxKtIrdJW(cL8lwVq6v)gcC3BtWuk(qHHCImDfbgBSVqjyS7Tjykf4dcf8GoioaJP00vemi(aJzt90ugyS(ne4U3gfAG5dPzv661)EHEVq61xV63qGtmvH5iPdPSHpKMvPRx)6f69ki0R(ne4etvyosQUPn8H0SkD96xVqVxV9cPxZ9JPKyip00RF9gP4cgBSVqjymZsgPK63qamw)gcY00iWy3BJcnWGpiuWlsaXbymLMUIGbXhymBQNMYaJFtr5ZDpPu2iHNk8CknDfb3lKED0)vc0XDifscpv47fsV63qG7EBcMsXHrEsWyJ9fkbJDVnbtPaFqOGh(dehGXuA6kcgeFGXSPEAkdmMHoP0YNNfqrVmyuVq690MY0veNHYt0rsctoatwVq6LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUE9VxOdgBSVqjyS7TXDhGe4dcf8aWG4amMstxrWG4dmMn1ttzGXVPO85UNukBKWtfEoLMUIG7fsVI17BkkFU7TrHgyoLMUIG7fsV63qG7EBcMsXhkmKtKPROEH0RVE1VHaNyQcZrs1nTHpKMvPRx)6ns6fsVetvyoIxPuDtB6fsV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(3B0qh3Efe6v)gcCSP0qdCzkPnmllMe7QC2Wpn1L61Vd9gn0XTxi9AUFmLed5HME9R3if3Efe6fg9Cd2W(6KKop2OjHnndiXhsZQ01RF9cG7vqOxJ9fk5gSH91jjDESrtcBAgqIxPmOkGI(E92lKEfRxgcPGrEsoZKvY4dzWacgBSVqjyS7Tjykf4dcf8IuqCagtPPRiyq8bgZM6PPmWy9BiWrj9ICsMISrEwUcL8lwVcc9QFdb(XkHhcwsAyip0Or5lPKgGfaq8lwVcc9QFdboZKvY4xSEH0RVE1VHaFStkrxNmmucaaYhsZQ01R)9cKbZ1mX1laQxgvQE91R5(XusmKhA6fA9cvC71BVq6v)gc8XoPeDDYWqjaai)I1RGqVI1R(ne4JDsj66KHHsaaq(fRxi9kwVmesbJ8K8XoPeDDYWqjaaiFidgWEfe6vSEzOtkT85Nu(IaC61BVcc9AUFmLed5HME9R3if3EH0lXufMJ4vkTeqWyJ9fkbJDVnU7aKaFqOenUG4amMstxrWG4dmMn1ttzGXVPO85U3gfAG5uA6kcUxi96Rx9BiWDVnk0aZVy9ki0R5(XusmKhA61VEJuC71BVq6v)gcC3BJcnWC3BSJ96FVqTxi96Rx9BiWjMQWCK0Hu2WVy9ki0R(ne4etvyosQUPn8lwVE7fsV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(3B04pC7fsV(6LHqkyKNKZmzLm(qAwLUE9Rx8WTxbHEfR3tBktxrCgkprhjjm5amz9cPxg6KslFEwaf9YGr96fm2yFHsWy3BJ7oajWhekrJhioaJP00vemi(aJzt90ugySVE1VHahBkn0axMsAdZYIjXUkNn8ttDPE9V3OXF42RGqV63qGJnLgAGltjTHzzXKyxLZg(PPUuV(3B0qh3EH07BkkFU7jLYgj8uHNtPPRi4E92lKE1VHaNyQcZrshszdFinRsxV(1l(Rxi9smvH5iELshsztVq6vSE1VHahL0lYjXOHryFHs(fRxi9kwVVPO85U3gfAG5uA6kcUxi9YqifmYtYzMSsgFinRsxV(1l(Rxi96RxgcPGrEsoPHH8qJuhLW8H0SkD96xV4VEfe6vSEzOtkT85hbCkl71lySX(cLGXU3g3DasGpiuIoAqCagtPPRiyq8bgZM6PPmWyF9QFdboXufMJKQBAd)I1RGqV(6LjYgGKR3d9gDVq6DiMiBasYV0OE9VxO3R3Efe6LjYgGKR3d9c1E92lKEnmjteXo2lKEpTPmDfXD2jjdOrYmzLmWyJ9fkbJtYJudHsWhekrdvqCagtPPRiyq8bgZM6PPmWyF9QFdboXufMJKQBAd)I1lKEfRxg6KslF(raNYYEfe61xV63qGFSs4HGLKggYdnAu(skPbybae)I1lKEzOtkT85hbCkl71BVcc96RxMiBasUEp0B09cP3HyISbij)sJ61)EHEVE7vqOxMiBasUEp0lu7vqOx9BiWzMSsg)I1R3EH0RHjzIi2XEH07PnLPRiUZojzansMjRKbgBSVqjySitfKAiuc(GqjA8dehGXuA6kcgeFGXSPEAkdm2xV63qGtmvH5iP6M2WVy9cPxX6LHoP0YNFeWPSSxbHE91R(ne4hReEiyjPHH8qJgLVKsAawaaXVy9cPxg6KslF(raNYYE92RGqV(6LjYgGKR3d9gDVq6DiMiBasYV0OE9VxO3R3Efe6LjYgGKR3d9c1Efe6v)gcCMjRKXVy96Txi9AysMiIDSxi9EAtz6kI7StsgqJKzYkzGXg7lucghUkLudHsWhekrdDqCagBSVqjyShBMcnsuqsQBsGXuA6kcgeFGpiuIosaXbymLMUIGbXhymBQNMYaJjMQWCeVsP6M20RGqVetvyoI7qkBKjjUVxbHEjMQWCe3saLjjUVxbHE1VHa3JntHgjkij1nj(fRxi9QFdboXufMJKQBAd)I1RGqV(6v)gcCMjRKXhsZQ01R)9ASVqj3ZyViojoIDFs(Lg1lKE1VHaNzYkz8lwVEbJn2xOem292eQHaFqOen(dehGXg7lucg7zSxeymLMUIGbXh4dcLObWG4amMstxrWG4dm2yFHsW45MsJ9fkLQY9GXQY9Y00iW4GPuVO5c(GpySoYEqCacf8aXbymLMUIGbXhymBQNMYaJ1VHaNzYkz8lgySX(cLGXJDsj66KHHsaaqWhekrdIdWyknDfbdIpWyegySJEWyJ9fkbJpTPmDfbgFAQlbglwV63qGRBklzKefKMsjFrvc0jt7VdXVy9cPxX6v)gcCDtzjJKOG0uk5lQsGoPnmlj(fdm(0gzAAeymBQpr)fd8bHcubXbymLMUIGbXhySX(cLGXgSH91jjDESrdmMn1ttzGX63qGRBklzKefKMsjFrvc0jt7VdXDVXo2R)9IF9cPx9BiW1nLLmsIcstPKVOkb6K2WSK4U3yh71)EXVEH0RVEfRxy0Znyd7Rts68yJMe20mGe)l2Xkb2lKEfRxJ9fk5gSH91jjDESrtcBAgqIxPmOkGI(EH0RVEfRxy0Znyd7Rts68yJMuezk(xSJvcSxbHEHrp3GnSVojPZJnAsrKP4dPzv661VEHAVE7vqOxy0Znyd7Rts68yJMe20mGe39g7yV(3lu7fsVWONBWg2xNK05XgnjSPzaj(qAwLUE9VxO3lKEHrp3GnSVojPZJnAsytZas8VyhReyVEbJzaYuK8Tbi9oqOGh4dcf8dehGXuA6kcgeFGXSPEAkdm2xVN2uMUI4muEIossyYbyY6fsVI1ldHuWipjNzYkz8Hmya7vqOx9BiWzMSsg)I1R3EH0RVE1VHax3uwYijkinLs(IQeOtM2FhI7EJDS3d9c9Efe6v)gcCDtzjJKOG0uk5lQsGoPnmljU7n2XEp0l071BVcc9gkGIE5qAwLUE9Vx8Wfm2yFHsWygkprhj5lIKoSAQ3b(Gqb6G4amMstxrWG4dmMn1ttzGX(6v)gcCDtzjJKOG0uk5lQsGozA)Di(qAwLUE9Rx8Jd9Efe6v)gcCDtzjJKOG0uk5lQsGoPnmlj(qAwLUE9Rx8Jd9E92lKEn3pMsIH8qtV(DO3if3EH0RVEziKcg5j5mtwjJpKMvPRx)6f)1RGqV(6LHqkyKNKtAyip0i1rjmFinRsxV(1l(Rxi9kwV63qGFSs4HGLKggYdnAu(skPbybae)I1lKEzOtkT85hbCkl71BVEbJn2xOemMzjJus9BiagRFdbzAAeyS7TrHgyWhekrcioaJP00vemi(aJzt90ugySy9EAtz6kIZM6t0FX6fsV(6LHoP0YNNfqrVmyuVcc9YqifmYtYzMSsgFinRsxV(1l(RxbHEfR3tBktxrCgSKHs46lu2lKEfRxg6KslF(raNYYEfe61xVmesbJ8KCsdd5HgPokH5dPzv661VEXF9cPxX6v)gc8JvcpeSK0WqEOrJYxsjnalaG4xSEH0ldDsPLp)iGtzzVE71lySX(cLGXU3g3DasGpiuWFG4amMstxrWG4dmMn1ttzGX(6LHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUE9VxO3lKE917PnLPRiodLNOJKeMCaMSEfe6LHqkyKNKZmzLm(qAwLUE9VxO3R3E92lKEn3pMsIH8qtV(1l(HBVq6LHoP0YNNfqrVmyeySX(cLGXU3g3DasGpiuaWG4amMstxrWG4dm2yFHsWy3nd1qGXSPEAkdmEOWqorMUI6fsVVnaPN)LgjFKeUOE9Rx8IKEH0RVEnmjteXo2lKE917PnLPRioBQpr)fRxbHE91R5(XusmKhA61)EHkU9cPxX6v)gcCMjRKXVy96TxbHEziKcg5j5mtwjJpKbdyVE71lymdqMIKVnaP3bcf8aFqOePG4amMstxrWG4dm2yFHsWynekd1qGXSPEAkdmEOWqorMUI6fsVVnaPN)LgjFKeUOE9Rx8Gkh69cPxF9AysMiIDSxi96R3tBktxrC2uFI(lwVcc96RxZ9JPKyip00R)9cvC7fsVI1R(ne4mtwjJFX61BVcc9YqifmYtYzMSsgFidgWE92lKEfRx9BiWpwj8qWssdd5HgnkFjL0aSaaIFX61lymdqMIKVnaP3bcf8aFqOGhUG4amMstxrWG4dm2yFHsWy3tkLnYGYgcmMn1ttzGXdfgYjY0vuVq69Tbi98V0i5JKWf1RF9IxK0Be9oKMvPRxi96RxdtYerSJ9cPxF9EAtz6kIZM6t0FX6vqOxZ9JPKyip00R)9cvC7vqOxgcPGrEsoZKvY4dzWa2R3E9cgZaKPi5Bdq6DGqbpWhek4HhioaJP00vemi(aJzt90ugySHjzIi2rWyJ9fkbJdOHrsuqM2Fhc8bHcErdIdWyknDfbdIpWy2upnLbg7RxIPkmhXRuAjG9ki0lXufMJ4oKYgzLs86vqOxIPkmhXv30gzLs861BVq61xVI1ldDsPLpplGIEzWOEfe61xVM7htjXqEOPx)7nsHEVq61xVN2uMUI4SP(e9xSEfe61C)ykjgYdn96FVqf3Efe690MY0veVCsdr96Txi96R3tBktxrCgkprhjjm5amz9cPxX6LHqkyKNKZq5j6ijFrK0Hvt9o(fRxbHEfR3tBktxrCgkprhjjm5amz9cPxX6LHqkyKNKZmzLm(fRxV96TxV9cPxF9YqifmYtYzMSsgFinRsxV(1luXTxbHEn3pMsIH8qtV(1BKIBVq6LHqkyKNKZmzLm(fRxi96RxgcPGrEsoPHH8qJuhLW8H0SkD96FVg7luYDVnHAiojoIDFs(Lg1RGqVI1ldDsPLp)iGtzzVE7vqO3kFAWqk7jyzOak6LdPzv661)EXd3E92lKE91lm65gSH91jjDESrtcBAgqIpKMvPRx)6f)6vqOxX6LHoP0YNNeBqk0a3RxWyJ9fkbJd3bqjkij1njWhek4bvqCagtPPRiyq8bgZM6PPmWyF9smvH5iU6M2itsCFVcc9smvH5iUdPSrMK4(Efe6LyQcZrClbuMK4(Efe6v)gcCDtzjJKOG0uk5lQsGozA)Di(qAwLUE9Rx8Jd9Efe6v)gcCDtzjJKOG0uk5lQsGoPnmlj(qAwLUE9Rx8Jd9Efe61C)ykjgYdn96xVrkU9cPxgcPGrEsoZKvY4dzWa2R3EH0RVEziKcg5j5mtwjJpKMvPRx)6fQ42RGqVmesbJ8KCMjRKXhYGbSxV9ki0BLpnyiL9eSmuaf9YH0SkD96FV4HlySX(cLGXKggYdnsDucd(Gqbp8dehGXuA6kcgeFGXSPEAkdm(0MY0veNblzOeU(cL9cPxF9AUFmLed5HME9R3if3EH0RVE1VHa)yLWdbljnmKhA0O8LusdWcai(fRxbHEfRxg6KslF(raNYYE92RGqVm0jLw(8Sak6LbJ6vqOx9BiW1vieS66E(fRxi9QFdbUUcHGvx3ZhsZQ01R)9gnU9grV(6LHs4B9CSHyLJKMQaMAu(8V0i5PPUuVE71BVq61xVN2uMUI4muEIossyYbyY6vqOxgcPGrEsodLNOJK8frshwn174dzWa2R3Efe6TYNgmKYEcwgkGIE5qAwLUE9V3OXT3i61xVmucFRNJneRCK0ufWuJYN)Lgjpn1L61lySX(cLGXmsrUVmL0ufWuJYh8bHcEqhehGXuA6kcgeFGXSPEAkdm(0MY0veNblzOeU(cL9cPxF9AUFmLed5HME9R3if3EH0RVE1VHa)yLWdbljnmKhA0O8LusdWcai(fRxbHEfRxg6KslF(raNYYE92RGqVm0jLw(8Sak6LbJ6vqOx9BiW1vieS66E(fRxi9QFdbUUcHGvx3ZhsZQ01R)9cvC7nIE91ldLW365ydXkhjnvbm1O85FPrYttDPE92R3EH0RVEpTPmDfXzO8eDKKWKdWK1RGqVmesbJ8KCgkprhj5lIKoSAQ3XhYGbSxV9ki0BLpnyiL9eSmuaf9YH0SkD96FVqf3EJOxF9Yqj8TEo2qSYrstvatnkF(xAK80uxQxVGXg7lucgxjZM0(cLGpiuWlsaXbymLMUIGbXhymcdm2rpySX(cLGXN2uMUIaJpn1LaJjMQWCeVsP6M20laQxaCVqRxJ9fk5U3MqneNehXUpj)sJ6nIEfRxIPkmhXRuQUPn9cG6ns6fA9ASVqj3ZyViojoIDFs(Lg1Be9Ilp6EHwVomsPKIm3tGXN2ittJaJnhM4pAIjg4dcf8WFG4amMstxrWG4dmMn1ttzGX(6TYNgmKYEcwgkGIE5qAwLUE9Vx8RxbHE91R(ne4JDsj66KHHsaaq(qAwLUE9VxGmyUMjUEbq9YOs1RVEn3pMsIH8qtVqRxOIBVE7fsV63qGp2jLORtggkbaa5xSE92R3Efe61xVM7htjXqEOP3i690MY0ve3CyI)OjMy9cG6v)gcCIPkmhjDiLn8H0SkD9grVWONhUdGsuqsQBs8VyhDYH0Sk7fa1B0CO3RF9Ix042RGqVM7htjXqEOP3i690MY0ve3CyI)OjMy9cG6v)gcCIPkmhjv30g(qAwLUEJOxy0Zd3bqjkij1nj(xSJo5qAwL9cG6nAo071VEXlAC71BVq6LyQcZr8kLwcyVq61xV(6vSEziKcg5j5mtwjJFX6vqOxg6KslF(raNYYEH0Ry9YqifmYtYjnmKhAK6OeMFX61BVcc9YqNuA5ZZcOOxgmQxV9cPxF9kwVm0jLw(8tkFrao9ki0Ry9QFdboZKvY4xSEfe61C)ykjgYdn96xVrkU96TxbHE1VHaNzYkz8H0SkD96xVa4EH0Ry9QFdb(yNuIUozyOeaaKFXaJn2xOem2924Udqc8bHcEayqCagtPPRiyq8bgZM6PPmWyF9QFdboXufMJKQBAd)I1RGqV(6LjYgGKR3d9gDVq6DiMiBasYV0OE9VxO3R3Efe6LjYgGKR3d9c1E92lKEnmjteXocgBSVqjyCsEKAiuc(GqbVifehGXuA6kcgeFGXSPEAkdm2xV63qGtmvH5iP6M2WVy9ki0RVEzISbi569qVr3lKEhIjYgGK8lnQx)7f696TxbHEzISbi569qVqTxV9cPxdtYerSJGXg7lucglYubPgcLGpiuIgxqCagtPPRiyq8bgZM6PPmWyF9QFdboXufMJKQBAd)I1RGqV(6LjYgGKR3d9gDVq6DiMiBasYV0OE9VxO3R3Efe6LjYgGKR3d9c1E92lKEnmjteXocgBSVqjyC4QusnekbFqOenEG4am2yFHsWyp2mfAKOGKu3KaJP00vemi(aFqOeD0G4amMstxrWG4dmMn1ttzGXetvyoIxPuDtB6vqOxIPkmhXDiLnYKe33RGqVetvyoIBjGYKe33RGqV63qG7XMPqJefKK6Me)I1lKE1VHaNyQcZrs1nTHFX6vqOxF9QFdboZKvY4dPzv661)En2xOK7zSxeNehXUpj)sJ6fsV63qGZmzLm(fRxVGXg7lucg7EBc1qGpiuIgQG4am2yFHsWypJ9IaJP00vemi(aFqOen(bIdWyknDfbdIpWyJ9fkbJNBkn2xOuQk3dgRk3lttJaJdMs9IMl4d(Gpy8jnUcLGqjACJgx8IoACbJ9ytwjqhym(h8FC2qbNfue)k(6TxCiI6T0WqZ3Ban9IZHhY00ReMgCEVdf53Ai4EDinQx7(in7j4EzISei54Du4KkPEJw81BKHYtAEcU34slY61by(M46v869r9ItUwVW1z5ku2lcJg7rtV(GM3E9HN48Y7OWjvs9IhEIVEJmuEsZtW9gxArwVoaZ3exVIN417J6fNCTE1qWx111lcJg7rtV(epV96dpX5L3rHtQK6fVOfF9gzO8KMNG7nU0ISEDaMVjUEfpXR3h1lo5A9QHGVQRRxegn2JME9jEE71hEIZlVJcNuj1lEqx81BKHYtAEcU34slY61by(M46v869r9ItUwVW1z5ku2lcJg7rtV(GM3E9HN48Y7O6OW)G)JZgk4SGI4xXxV9IdruVLggA(EdOPxComfSR6X59ouKFRHG71H0OET7J0SNG7LjYsGKJ3rHtQK6nseF9gzO8KMNG7nU0ISEDaMVjUEfVEFuV4KR1lCDwUcL9IWOXE00RpO5TxFrloV8okCsLuV4HN4R3idLN08eCV485Muanajo(xCEVpQxC(CtkGgGeh)lNstxrW48E9fT48Y7O6OW)G)JZgk4SGI4xXxV9IdruVLggA(EdOPxCo2qmKMU948EhkYV1qW96qAuV29rA2tW9YezjqYX7OWjvs9cDXxVrgkpP5j4EX5ZnPaAasC8V48EFuV485Muanajo(xoLMUIGX596dpX5L3rHtQK6nseF9gzO8KMNG7fNp3KcObiXX)IZ79r9IZNBsb0aK44F5uA6kcgN3Rp8eNxEhvhf(h8FC2qbNfue)k(6TxCiI6T0WqZ3Ban9IZneHZ7DOi)wdb3RdPr9A3hPzpb3ltKLajhVJcNuj1B0IVEJmuEsZtW9IZNBsb0aK44FX59(OEX5ZnPaAasC8VCknDfbJZ71hEIZlVJcNuj1lufF9gzO8KMNG7nU0ISEDaMVjUEfpXR3h1lo5A9QHGVQRRxegn2JME9jEE71hEIZlVJcNuj1l0fF9gzO8KMNG7nU0ISEDaMVjUEfVEFuV4KR1lCDwUcL9IWOXE00RpO5TxF4joV8okCsLuVrQ4R3idLN08eCVXLwK1RdW8nX1R417J6fNCTEHRZYvOSxegn2JME9bnV96dpX5L3rHtQK6fpOk(6nYq5jnpb3BCPfz96amFtC9kEIxVpQxCY16vdbFvxxVimAShn96t882Rp8eNxEhfoPsQx8aWIVEJmuEsZtW9gxArwVoaZ3exVIxVpQxCY16fUolxHYEry0ypA61h082Rp8eNxEhfoPsQ3OXv81BKHYtAEcU34slY61by(M46v869r9ItUwVW1z5ku2lcJg7rtV(GM3E9HN48Y7OWjvs9gn0fF9gzO8KMNG7nU0ISEDaMVjUEfVEFuV4KR1lCDwUcL9IWOXE00RpO5TxFrloV8oQok8p4)4SHcolOi(v81BV4qe1BPHHMV3aA6fN7ECEVdf53Ai4EDinQx7(in7j4EzISei54Du4KkPEXdxXxVrgkpP5j4EJlTiRxhG5BIRxXt869r9ItUwVAi4R666fHrJ9OPxFIN3E9HN48Y7OWjvs9IhEIVEJmuEsZtW9gxArwVoaZ3exVIN417J6fNCTE1qWx111lcJg7rtV(epV96dpX5L3rHtQK6fViv81BKHYtAEcU34slY61by(M46v869r9ItUwVW1z5ku2lcJg7rtV(GM3E9HN48Y7O6OW)G)JZgk4SGI4xXxV9IdruVLggA(EdOPxCUoYECEVdf53Ai4EDinQx7(in7j4EzISei54Du4KkPEXlseF9gzO8KMNG7nU0ISEDaMVjUEfVEFuV4KR1lCDwUcL9IWOXE00RpO5TxFqvCE5Du4KkPEXd)j(6nYq5jnpb3BCPfz96amFtC9kE9(OEXjxRx46SCfk7fHrJ9OPxFqZBV(WtCE5DuDu4S0WqZtW9I)61yFHYEvL7D8okWyhgXaHcE4gnym2GcLIaJXz6fFMYsg1R4hZTG7OWz6v8dIrA600B04cWEJg3OXTJQJcNP3itKLajN4RJcNPxCAV4)WWeCVXiLn9IpY04Du4m9It7nYezjqcU33gG0lRqVmZrUEFuVmazks(2aKEhVJcNPxCAV4Sjn0jb37ntIroNna27PnLPRixV(koXbyVydDkDVnU7aK6fN6xVydDYDVnU7aK8Y7OWz6fN2l()jQG7fBiM5(kb2l(NXEr9wHERhN769fr96zqjWEf)KPkmhX7OWz6fN2R4F2rQ3idLNOJuVViQ3ySAQ31R1RQ(xr9QHgQ3GIexPROE9vHEbeD7vKbN48Vxr13B996kTR6TKqxNcWE9uVOEXN4)4)4O3i6nYif5(Yu9I)RkGPgLpa7TECoCVUJfMxEhvhLX(cLoo2qmKMU9h0qO8yLYaA06Om2xO0XXgIH00TpIdq7yLWdblDy1uVRJYyFHshhBigst3(ioanpJ9IaOQssYGpGhUaSch8rmvH5iU6M2itsCVGaXufMJ4vkv30gbbIPkmhXRuQJErccetvyoIBjGYKe37TJYyFHshhBigst3(ioanpJ9Iayfo4JyQcZrC1nTrMK4EbbIPkmhXRuQUPnccetvyoIxPuh9IeeiMQWCe3saLjjU3leSHo54X9m2lcIyydDYJM7zSxuhLX(cLoo2qmKMU9rCaAU3MqneaRWbXMBsb0aK46MYsgjrbPPuYxuLaDccIXqNuA5ZZcOOxgmsqqmhgPuY3gG074U3MGPuhWtqqS3uu(80(7qoPUPSKrCknDfb3rzSVqPJJnedPPBFehGM7TXDhGeaRWH5MuanajUUPSKrsuqAkL8fvjqheg6KslFEwaf9YGrqCyKsjFBasVJ7EBcMsDaVoQokCMEf)uCe7(eCV0jna27xAuVViQxJ9OP3Y1RDALY0veVJYyFHs3bhszJuNmTokJ9fkDhoTPmDfbW00OdLtAicGNM6shCyKsjFBasVJ7EBcMs5hEq8j2BkkFU7TrHgyoLMUIGfeEtr5ZDpPu2iHNk8CknDfb7vqWHrkL8Tbi9oU7TjykLFr3rzSVqPlIdq70MY0veattJouojtr2jbWttDPdomsPKVnaP3XDVnHAi)WRJYyFHsxehGMonoAowjqawHd(eJHoP0YNNfqrVmyKGGymesbJ8KCgkprhj5lIKoSAQ3XVyEHOFdboZKvY4xSokJ9fkDrCaAyOVqjaRWb9BiWzMSsg)I1rzSVqPlIdq70MY0veattJoWq5j6ijHjhGjdGNM6shckeA85RYNgmKYEcwgkGIE5qAwLoCA04ItziKcg5j5muEIosYxejDy1uVJpKMvPZR4Hx0461VGcHgF(Q8PbdPSNGLHcOOxoKMvPdNgn0XP(Wdxa0BkkFELmBs7luYP00veSxCQpgkHV1ZXgIvosAQcyQr5Z)sJKNM6sEXPmesbJ8KCMjRKXhsZQ05v8WdaJRxbbgcPGrEsoZKvY4dPzv68RYNgmKYEcwgkGIE5qAwLobbgcPGrEsodLNOJK8frshwn174dPzv68RYNgmKYEcwgkGIE5qAwLobbXyOtkT85zbu0ldg1rzSVqPlIdq70MY0veattJoWGLmucxFHsaEAQlDWNyuKFlmmcMtAyaoKPKOboTKrccmesbJ8KCsddWHmLenWPLmIpKMvPZF8IeCHigdHuWipjN0WaCitjrdCAjJ4dzWa6fIpXOi)wyyem3HUkf9FLaLZvhqbbgcPGrEsUdDvk6)kbkNRoGsOIFqhaJlE8H0SkD(JhU4crmgcPGrEsUdDvk6)kbkNRoGsOIFqhaJlE8Hmya9kiWqNuA5Zpc4uw2rzSVqPlIdq76iz9KgattJoqAyaoKPKOboTKraSchyiKcg5j5mtwjJpKMvPZ)OXfYPnLPRiodLNOJKeMCaMmbbgcPGrEsodLNOJK8frshwn174dPzv68pAC7Om2xO0fXbODDKSEsdGPPrhCORsr)xjq5C1beGv4adHuWipjNzYkz8H0SkD(hnUqoTPmDfXzO8eDKKWKdWKjiWqifmYtYzO8eDKKVis6WQPEhFinRsN)rJRGaf53cdJG5KggGdzkjAGtlzuhLX(cLUioaTRJK1tAamnn6qLo2CFtxrYi)A5F1KW0zXiawHd63qGZmzLm(fRJcNPxJ9fkDrCaAxhjRN0Ca0PqV7WpvEKE8ayfoi2pvEKEoECrMtInig3saH4tSFQ8i98O5ImNeBqmULakii2pvEKEE08HmyaLmesbJ8KEfe0VHaNzYkz8lMGadHuWipjNzYkz8H0SkD4u8W1VFQ8i9C84mesbJ8KC47yFHsiIXqNuA5Zpc4uwkiWqNuA5ZZcOOxgmcYPnLPRiodLNOJKeMCaMmimesbJ8KCgkprhj5lIKoSAQ3XVycc63qGFSs4HGLKggYdnAu(skPbybae)IjiekGIE5qAwLo)Jg3okCMEn2xO0fXbODDKSEsZbqNc9Ud)u5r6JgGv4Gy)u5r65rZfzoj2GyClbeIpX(PYJ0ZXJlYCsSbX4wcOGGy)u5r654XhYGbuYqifmYt6vq4NkpsphpUiZjXgeJBjGq(PYJ0ZJMlYCsSbX4wcieX(PYJ0ZXJpKbdOKHqkyKNuqq)gcCMjRKXVyccmesbJ8KCMjRKXhsZQ0HtXdx)(PYJ0ZJMZqifmYtYHVJ9fkHigdDsPLp)iGtzPGadDsPLpplGIEzWiiN2uMUI4muEIossyYbyYGWqifmYtYzO8eDKKVis6WQPEh)IjiOFdb(XkHhcwsAyip0Or5lPKgGfaq8lMGqOak6LdPzv68pAC7Om2xO0fXbODDKSEsZbWkCq)gcCMjRKXVyccmesbJ8KCMjRKXhsZQ05hE4crmg6KslF(raNYsbbg6KslFEwaf9YGrqoTPmDfXzO8eDKKWKdWKbHHqkyKNKZq5j6ijFrK0Hvt9o(fdIymesbJ8KCMjRKXVyq85t)gcCIPkmhjv30g(qAwLo)Wdxbb9BiWjMQWCK0Hu2WhsZQ05hE46fIyZnPaAasCDtzjJKOG0uk5lQsGobH5MuanajUUPSKrsuqAkL8fvjqheF63qGRBklzKefKMsjFrvc0jt7VdXDVXo6hufe0VHax3uwYijkinLs(IQeOtAdZsI7EJD0pO61RGG(ne4hReEiyjPHH8qJgLVKsAawaaXVyccHcOOxoKMvPZ)OXTJYyFHsxehG2CtPX(cLsv5EaMMgDWqeaD)uS)aEaSchoTPmDfXlN0quhLX(cLUioaT5MsJ9fkLQY9amnn6a8qMMELW0aq3pf7pGhaRWH5Muanaj(xAKh0Ks4Hmn9kHPHtr(TWWi4okJ9fkDrCaAZnLg7lukvL7byAA0bDK9a09tX(d4bWkCyUjfqdqIRBklzKefKMsjFrvc0XPi)wyyeChLX(cLUioaT5MsJ9fkLQY9amnn6G77O6Om2xO0XneD40MY0veattJoapKPj9ukLmykLefca80ux6Gp9BiW)sJ8GMucpKPPxjmn8H0SkD(dKbZ1mXfbUC8ee0VHa)lnYdAsj8qMMELW0WhsZQ05VX(cLC3BtOgItIJy3NKFPrrGlhpi(iMQWCeVsP6M2iiqmvH5iUdPSrMK4EbbIPkmhXTeqzsI796fI(ne4FPrEqtkHhY00ReMg(fdYCtkGgGe)lnYdAsj8qMMELW0WPi)wyyeChLX(cLoUHOioangkprhj5lIKoSAQ3bWkCW3PnLPRiodLNOJKeMCaMmiIXqifmYtYzMSsgFidgqbb9BiWzMSsg)I5fI5(XusmKhA8h64cXN(ne4etvyosQUPn8H0SkD(fjcc63qGtmvH5iPdPSHpKMvPZViXleFIn3KcObiX1nLLmsIcstPKVOkb6ee0VHax3uwYijkinLs(IQeOtM2FhI7EJD0pOkiOFdbUUPSKrsuqAkL8fvjqN0gMLe39g7OFq1RGqOak6LdPzv68hpC7Om2xO0XnefXbO5EBcMsbWkCq)gcC3BtWuk(qHHCImDfbXNdJuk5Bdq6DC3BtWuk)HQGGyZnPaAas8V0ipOjLWdzA6vctdNI8BHHrWEH4tS5MuanajUcqMnMtgue9vcucuvAyoItr(TWWiybHV0iXt8WpO7N(ne4U3MGPu8H0SkDreT3okJ9fkDCdrrCaAU3MGPuaSchMBsb0aK4FPrEqtkHhY00ReMgof53cdJGH4WiLs(2aKEh392emLYVdqfIpX0VHa)lnYdAsj8qMMELW0WVyq0VHa392emLIpuyiNitxrcc(oTPmDfXHhY0KEkLsgmLsIcbi(0VHa392emLIpKMvPZFOki4WiLs(2aKEh392emLYVOH8MIYN7EsPSrcpv45uA6kcgI(ne4U3MGPu8H0SkD(dDVE92rzSVqPJBikIdq70MY0veattJo4EBcMsj9GYxgmLsIcbaEAQlDWC)ykjgYdn(bGXfN6dpCbq63qG)Lg5bnPeEittVsyA4U3yh9It9PFdbU7TjykfFinRshacQINdJukPiZ9KxCQpy0Zd3bqjkij1nj(qAwLoae09cr)gcC3BtWuk(fRJYyFHsh3quehGM7TXDhGeaRWHtBktxrC4HmnPNsPKbtPKOqaYPnLPRiU7TjykL0dkFzWukjkeee8PFdbUUPSKrsuqAkL8fvjqNmT)oe39g7OFqvqq)gcCDtzjJKOG0uk5lQsGoPnmljU7n2r)GQxiomsPKVnaP3XDVnbtP8h)6Om2xO0XnefXbO5UzOgcGmazks(2aKE3b8ayfomuyiNitxrqEBasp)lns(ijCr(Hh(HtDyKsjFBasVlIH0SkDqmmjteXocHyQcZr8kLwcyhLX(cLoUHOioand2W(6KKop2ObqgGmfjFBasV7aEaSche7l2XkbcrmJ9fk5gSH91jjDESrtcBAgqIxPmOkGIEbby0Znyd7Rts68yJMe20mGe39g7O)qfcm65gSH91jjDESrtcBAgqIpKMvPZFO2rzSVqPJBikIdqtdHYqneazaYuK8Tbi9Ud4bWkCyOWqorMUIG82aKE(xAK8rs4I8ZhE4xe(CyKsjFBasVJ7EBc1qai84q3RxXZHrkL8Tbi9UigsZQ0bXhdHuWipjNzYkz8HmyaH470MY0veNHYt0rsctoatMGadHuWipjNHYt0rs(IiPdRM6D8HmyafeeJHoP0YNNfqrVmyKxbbhgPuY3gG074U3MqnK)(WpaKp8I4nfLp)9uPudHshNstxrWE9ki4JyQcZr8kLoKYgbbFetvyoIxPuh9IeeiMQWCeVsP6M24fIyVPO85o0vjrb5lIKb0qUNtPPRiybb9BiWXMsdnWLPK2WSSysSRYzd)0uxYVdrdDC9cXNdJuk5Bdq6DC3BtOgYF8Wfa5dViEtr5ZFpvk1qO0XP00veSxVqm3pMsIH8qJFqhxCQ(ne4U3MGPu8H0SkDaOiXleFIPFdb(XkHhcwsAyip0Or5lPKgGfaq8lMGaXufMJ4vkDiLnccIXqNuA5Zpc4uw6fIHjzIi2XokJ9fkDCdrrCaAb0Wijkit7VdbWkCWWKmre7yhLX(cLoUHOioaTXoPeDDYWqjaaiaRWb9BiWzMSsg)I1rzSVqPJBikIdqJrkY9LPKMQaMAu(aSchoTPmDfXzWsgkHRVqjeF63qG7EBcMsXVyccM7htjXqEOXpOJRxiIPFdbUdPCFXi(fdIy63qGZmzLm(fdIpXyOtkT85zbu0ldgjiCAtz6kIZq5j6ijHjhGjtqGHqkyKNKZq5j6ijFrK0Hvt9o(ftqOYNgmKYEcwgkGIE5qAwLo)Jg3i8Xqj8TEo2qSYrstvatnkF(xAK80uxYR3okJ9fkDCdrrCaAvYSjTVqjaRWHtBktxrCgSKHs46lucXN(ne4U3MGPu8lMGG5(XusmKhA8d646fIy63qG7qk3xmIFXGiM(ne4mtwjJFXG4tmg6KslFEwaf9YGrccN2uMUI4muEIossyYbyYeeyiKcg5j5muEIosYxejDy1uVJFXeeQ8PbdPSNGLHcOOxoKMvPZFgcPGrEsodLNOJK8frshwn174dPzv6IiseeQ8PbdPSNGLHcOOxoKMvPt8ep8aW46puXncFmucFRNJneRCK0ufWuJYN)Lgjpn1L86TJYyFHsh3quehGgPHH8qJuhLWaSchQ8PbdPSNGLHcOOxoKMvPZF8GUGGp9BiWXMsdnWLPK2WSSysSRYzd)0uxY)OHoUcc63qGJnLgAGltjTHzzXKyxLZg(PPUKFhIg646fI(ne4U3MGPu8lgegcPGrEsoZKvY4dPzv68d642rzSVqPJBikIdqZ9KszJmOSHaidqMIKVnaP3DapawHddfgYjY0veKV0i5JKWf5hEqhIdJuk5Bdq6DC3BtOgYF8dIHjzIi2ri(0VHaNzYkz8H0SkD(HhUccIPFdboZKvY4xmVDug7lu64gII4a0c3bqjkij1njawHdetvyoIxP0saHyysMiIDeI(ne4ytPHg4YusBywwmj2v5SHFAQl5F0qhxi(Grp3GnSVojPZJnAsytZas8VyhReOGGym0jLw(8KydsHgybbhgPuY3gG078lAVDug7lu64gII4a0CVnbtPayfoOFdbokPxKtIrdJW(cL8lgeF63qG7EBcMsXhkmKtKPRibbZ9JPKyip04xKIR3okJ9fkDCdrrCaAU3MGPuaSchyOtkT85zbu0ldgbX3PnLPRiodLNOJKeMCaMmbbgcPGrEsoZKvY4xmbb9BiWzMSsg)I5fcdHuWipjNHYt0rs(IiPdRM6D8H0SkD(dKbZ1mXbGyuP8zUFmLed5HgXd646fI(ne4U3MGPu8H0SkD(JFDug7lu64gII4a0CVnU7aKayfoWqNuA5ZZcOOxgmcIVtBktxrCgkprhjjm5amzccmesbJ8KCMjRKXVycc63qGZmzLm(fZlegcPGrEsodLNOJK8frshwn174dPzv68psGOFdbU7Tjykf)IbHyQcZr8kLwcyhLX(cLoUHOioan3BJ7oajawHd63qGJs6f5KmfzJ8SCfk5xmbbFI5EBc1qCdtYerSJcc(0VHaNzYkz8H0SkD(dDi63qGZmzLm(ftqWN(ne4JDsj66KHHsaaq(qAwLo)bYG5AM4aqmQu(m3pMsIH8qJ4bvC9cr)gc8XoPeDDYWqjaai)I51lKtBktxrC3BtWukPhu(YGPusuiaXHrkL8Tbi9oU7TjykL)q1leFIn3KcObiX)sJ8GMucpKPPxjmnCkYVfggbli4WiLs(2aKEh392emLYFO6TJYyFHsh3quehGwsEKAiucWkCWhXufMJ4vkTeqimesbJ8KCMjRKXhsZQ05h0XvqWhtKnaj3HOHmetKnaj5xAK)q3RGatKnaj3bO6fIHjzIi2XokJ9fkDCdrrCaAImvqQHqjaRWbFetvyoIxP0saHWqifmYtYzMSsgFinRsNFqhxbbFmr2aKChIgYqmr2aKKFPr(dDVccmr2aKChGQxigMKjIyh7Om2xO0XnefXbOfUkLudHsawHd(iMQWCeVsPLacHHqkyKNKZmzLm(qAwLo)GoUcc(yISbi5oenKHyISbij)sJ8h6EfeyISbi5oavVqmmjteXo2rzSVqPJBikIdqZJntHgjkij1nPokJ9fkDCdrrCaAN2uMUIayAA0b3BtOgswP0Hu2aWttDPdomsPKVnaP3XDVnHAi)WVickeA8PzUNgaLNM6sIx046nIGcHgF63qG7EBC3bijjnmKhA0O8LoKYgU7n2rXd)82rzSVqPJBikIdqZZyViawHdetvyoIRUPnYKe3liqmvH5iULaktsCpKtBktxr8YjzkYojbb9BiWjMQWCK0Hu2WhsZQ05VX(cLC3BtOgItIJy3NKFPrq0VHaNyQcZrshszd)IjiqmvH5iELshszdeXoTPmDfXDVnHAizLshszJGG(ne4mtwjJpKMvPZFJ9fk5U3MqneNehXUpj)sJGi2PnLPRiE5KmfzNee9BiWzMSsgFinRsN)K4i29j5xAee9BiWzMSsg)IjiOFdb(yNuIUozyOeaaKFXG4WiLskYCp5hU8ibIphgPuY3gG078)aufee7nfLp3HUkjkiFrKmGgY9CknDfb7vqqStBktxr8YjzkYoji63qGZmzLm(qAwLo)iXrS7tYV0OokJ9fkDCdrrCaAU3MqnuhLX(cLoUHOioaT5MsJ9fkLQY9amnn6qWuQx0C7O6Om2xO0X1r2FyStkrxNmmucaacWkCq)gcCMjRKXVyDug7lu646i7J4a0oTPmDfbW00OdSP(e9xmaEAQlDqm9BiW1nLLmsIcstPKVOkb6KP93H4xmiIPFdbUUPSKrsuqAkL8fvjqN0gMLe)I1rzSVqPJRJSpIdqZGnSVojPZJnAaKbitrY3gG07oGhaRWb9BiW1nLLmsIcstPKVOkb6KP93H4U3yh9h)GOFdbUUPSKrsuqAkL8fvjqN0gMLe39g7O)4heFIbJEUbByFDssNhB0KWMMbK4FXowjqiIzSVqj3GnSVojPZJnAsytZas8kLbvbu0dXNyWONBWg2xNK05XgnPiYu8VyhReOGam65gSH91jjDESrtkImfFinRsNFq1RGam65gSH91jjDESrtcBAgqI7EJD0FOcbg9Cd2W(6KKop2OjHnndiXhsZQ05p0HaJEUbByFDssNhB0KWMMbK4FXowjqVDug7lu646i7J4a0yO8eDKKVis6WQPEhaRWbFN2uMUI4muEIossyYbyYGigdHuWipjNzYkz8Hmyafe0VHaNzYkz8lMxi(0VHax3uwYijkinLs(IQeOtM2FhI7EJD8a0fe0VHax3uwYijkinLs(IQeOtAdZsI7EJD8a09kiekGIE5qAwLo)Xd3okJ9fkDCDK9rCaAmlzKsQFdbaMMgDW92OqdmaRWbF63qGRBklzKefKMsjFrvc0jt7VdXhsZQ05h(XHUGG(ne46MYsgjrbPPuYxuLaDsByws8H0SkD(HFCO7fI5(XusmKhA87qKIleFmesbJ8KCMjRKXhsZQ05h(tqWhdHuWipjN0WqEOrQJsy(qAwLo)WFqet)gc8JvcpeSK0WqEOrJYxsjnalaG4xmim0jLw(8JaoLLE92rzSVqPJRJSpIdqZ924UdqcGv4GyN2uMUI4SP(e9xmi(yOtkT85zbu0ldgjiWqifmYtYzMSsgFinRsNF4pbbXoTPmDfXzWsgkHRVqjeXyOtkT85hbCklfe8XqifmYtYjnmKhAK6OeMpKMvPZp8heX0VHa)yLWdbljnmKhA0O8LusdWcai(fdcdDsPLp)iGtzPxVDug7lu646i7J4a0CVnU7aKayfo4JHqkyKNKZq5j6ijFrK0Hvt9o(qAwLo)HoeFN2uMUI4muEIossyYbyYeeyiKcg5j5mtwjJpKMvPZFO71leZ9JPKyip04h(Hleg6KslFEwaf9YGrDug7lu646i7J4a0C3mudbqgGmfjFBasV7aEaSchgkmKtKPRiiVnaPN)LgjFKeUi)WlsG4ZWKmre7ieFN2uMUI4SP(e9xmbbFM7htjXqEOXFOIleX0VHaNzYkz8lMxbbgcPGrEsoZKvY4dzWa61BhLX(cLoUoY(ioannekd1qaKbitrY3gG07oGhaRWHHcd5ez6kcYBdq65FPrYhjHlYp8Gkh6q8zysMiIDeIVtBktxrC2uFI(lMGGpZ9JPKyip04puXfIy63qGZmzLm(fZRGadHuWipjNzYkz8Hmya9crm9BiWpwj8qWssdd5HgnkFjL0aSaaIFX82rzSVqPJRJSpIdqZ9KszJmOSHaidqMIKVnaP3DapawHddfgYjY0veK3gG0Z)sJKpscxKF4fjrmKMvPdIpdtYerSJq8DAtz6kIZM6t0FXeem3pMsIH8qJ)qfxbbgcPGrEsoZKvY4dzWa61BhLX(cLoUoY(ioaTaAyKefKP93HayfoyysMiIDSJYyFHshxhzFehGw4oakrbjPUjbWkCWhXufMJ4vkTeqbbIPkmhXDiLnYkL4jiqmvH5iU6M2iRuINxi(eJHoP0YNNfqrVmyKGGpZ9JPKyip04FKcDi(oTPmDfXzt9j6VyccM7htjXqEOXFOIRGWPnLPRiE5KgI8cX3PnLPRiodLNOJKeMCaMmiIXqifmYtYzO8eDKKVis6WQPEh)Ijii2PnLPRiodLNOJKeMCaMmiIXqifmYtYzMSsg)I51Rxi(yiKcg5j5mtwjJpKMvPZpOIRGG5(XusmKhA8lsXfcdHuWipjNzYkz8lgeFmesbJ8KCsdd5HgPokH5dPzv683yFHsU7TjudXjXrS7tYV0ibbXyOtkT85hbCkl9kiu5tdgszpbldfqrVCinRsN)4HRxi(Grp3GnSVojPZJnAsytZas8H0SkD(HFccIXqNuA5ZtInifAG92rzSVqPJRJSpIdqJ0WqEOrQJsyawHd(iMQWCexDtBKjjUxqGyQcZrChszJmjX9ccetvyoIBjGYKe3liOFdbUUPSKrsuqAkL8fvjqNmT)oeFinRsNF4hh6cc63qGRBklzKefKMsjFrvc0jTHzjXhsZQ05h(XHUGG5(XusmKhA8lsXfcdHuWipjNzYkz8Hmya9cXhdHuWipjNzYkz8H0SkD(bvCfeyiKcg5j5mtwjJpKbdOxbHkFAWqk7jyzOak6LdPzv68hpC7Om2xO0X1r2hXbOXif5(YustvatnkFawHdN2uMUI4myjdLW1xOeIpZ9JPKyip04xKIleF63qGFSs4HGLKggYdnAu(skPbybae)IjiigdDsPLp)iGtzPxbbg6KslFEwaf9YGrcc63qGRRqiy1198lge9BiW1vieS66E(qAwLo)Jg3i8Xqj8TEo2qSYrstvatnkF(xAK80uxYRxi(oTPmDfXzO8eDKKWKdWKjiWqifmYtYzO8eDKKVis6WQPEhFidgqVccv(0GHu2tWYqbu0lhsZQ05F04gHpgkHV1ZXgIvosAQcyQr5Z)sJKNM6sE7Om2xO0X1r2hXbOvjZM0(cLaSchoTPmDfXzWsgkHRVqjeFM7htjXqEOXVifxi(0VHa)yLWdbljnmKhA0O8LusdWcai(ftqqmg6KslF(raNYsVccm0jLw(8Sak6LbJee0VHaxxHqWQR75xmi63qGRRqiy1198H0SkD(dvCJWhdLW365ydXkhjnvbm1O85FPrYttDjVEH470MY0veNHYt0rsctoatMGadHuWipjNHYt0rs(IiPdRM6D8Hmya9kiu5tdgszpbldfqrVCinRsN)qf3i8Xqj8TEo2qSYrstvatnkF(xAK80uxYBhLX(cLoUoY(ioaTtBktxramnn6G5We)rtmXa4PPU0bIPkmhXRuQUPnaiaS4zSVqj392eQH4K4i29j5xAueIrmvH5iELs1nTbafjINX(cLCpJ9I4K4i29j5xAue4YJw8CyKsjfzUN6Om2xO0X1r2hXbO5EBC3bibWkCWxLpnyiL9eSmuaf9YH0SkD(JFcc(0VHaFStkrxNmmucaaYhsZQ05pqgmxZehaIrLYN5(XusmKhAepOIRxi63qGp2jLORtggkbaa5xmVEfe8zUFmLed5HMioTPmDfXnhM4pAIjgas)gcCIPkmhjDiLn8H0SkDraJEE4oakrbjPUjX)ID0jhsZQeafnh6(Hx04kiyUFmLed5HMioTPmDfXnhM4pAIjgas)gcCIPkmhjv30g(qAwLUiGrppChaLOGKu3K4FXo6KdPzvcGIMdD)WlAC9cHyQcZr8kLwcieF(eJHqkyKNKZmzLm(ftqGHoP0YNFeWPSeIymesbJ8KCsdd5HgPokH5xmVccm0jLw(8Sak6LbJ8cXNym0jLw(8tkFraoccIPFdboZKvY4xmbbZ9JPKyip04xKIRxbb9BiWzMSsgFinRsNFayiIPFdb(yNuIUozyOeaaKFX6Om2xO0X1r2hXbOLKhPgcLaSch8PFdboXufMJKQBAd)Iji4JjYgGK7q0qgIjYgGK8lnYFO7vqGjYgGK7au9cXWKmre7yhLX(cLoUoY(ioanrMki1qOeGv4Gp9BiWjMQWCKuDtB4xmbbFmr2aKChIgYqmr2aKKFPr(dDVccmr2aKChGQxigMKjIyh7Om2xO0X1r2hXbOfUkLudHsawHd(0VHaNyQcZrs1nTHFXee8XezdqYDiAidXezdqs(Lg5p09kiWezdqYDaQEHyysMiIDSJYyFHshxhzFehGMhBMcnsuqsQBsDug7lu646i7J4a0CVnHAiawHdetvyoIxPuDtBeeiMQWCe3Hu2itsCVGaXufMJ4wcOmjX9cc63qG7XMPqJefKK6Me)Ibr)gcCIPkmhjv30g(ftqWN(ne4mtwjJpKMvPZFJ9fk5Eg7fXjXrS7tYV0ii63qGZmzLm(fZBhLX(cLoUoY(ioanpJ9I6Om2xO0X1r2hXbOn3uASVqPuvUhGPPrhcMs9IMBhvhLX(cLoo8qMMELW0C40MY0veattJo4SajFK86iPdJukaEAQlDWN(ne4FPrEqtkHhY00ReMg(qAwLo)aYG5AM4IaxoEq8rmvH5iELsD0lsqGyQcZr8kLoKYgbbIPkmhXv30gzsI79kiOFdb(xAKh0Ks4Hmn9kHPHpKMvPZpJ9fk5U3MqneNehXUpj)sJIaxoEq8rmvH5iELs1nTrqGyQcZrChszJmjX9ccetvyoIBjGYKe371RGGy63qG)Lg5bnPeEittVsyA4xSokJ9fkDC4Hmn9kHPjIdqZ924UdqcGv4GpXoTPmDfXDwGKpsEDK0HrkLGGp9BiWh7Ks01jddLaaG8H0SkD(dKbZ1mXbGyuP8zUFmLed5HgXdQ46fI(ne4JDsj66KHHsaaq(fZRxbbZ9JPKyip04xKIBhLX(cLoo8qMMELW0eXbOXq5j6ijFrK0Hvt9oawHd(oTPmDfXzO8eDKKWKdWKbPYNgmKYEcwgkGIE5qAwLo)WdQ4crmgcPGrEsoZKvY4dzWakiOFdboZKvY4xmVqm3pMsIH8qJ)4hUq8PFdboXufMJKQBAdFinRsNF4HRGG(ne4etvyos6qkB4dPzv68dpC9kiekGIE5qAwLo)Xd3okJ9fkDC4Hmn9kHPjIdqZGnSVojPZJnAaKbitrY3gG07oGhaRWbXGrp3GnSVojPZJnAsytZas8VyhReieXm2xOKBWg2xNK05XgnjSPzajELYGQak6H4tmy0Znyd7Rts68yJMuezk(xSJvcuqag9Cd2W(6KKop2OjfrMIpKMvPZpO7vqag9Cd2W(6KKop2OjHnndiXDVXo6puHaJEUbByFDssNhB0KWMMbK4dPzv68hQqGrp3GnSVojPZJnAsytZas8VyhReyhLX(cLoo8qMMELW0eXbOPHqzOgcGmazks(2aKE3b8ayfomuyiNitxrqEBasp)lns(ijCr(Hx0q85t)gcCMjRKXhsZQ05h0H4t)gc8XoPeDDYWqjaaiFinRsNFqxqqm9BiWh7Ks01jddLaaG8lMxbbX0VHaNzYkz8lMGG5(XusmKhA8hQ46fIpX0VHa)yLWdbljnmKhA0O8LusdWcai(ftqWC)ykjgYdn(dvC9cXWKmre7O3okJ9fkDC4Hmn9kHPjIdqZDZqneazaYuK8Tbi9Ud4bWkCyOWqorMUIG82aKE(xAK8rs4I8dVOH4ZN(ne4mtwjJpKMvPZpOdXN(ne4JDsj66KHHsaaq(qAwLo)GUGGy63qGp2jLORtggkbaa5xmVccIPFdboZKvY4xmbbZ9JPKyip04puX1leFIPFdb(XkHhcwsAyip0Or5lPKgGfaq8lMGG5(XusmKhA8hQ46fIHjzIi2rVDug7lu64WdzA6vcttehGM7jLYgzqzdbqgGmfjFBasV7aEaSchgkmKtKPRiiVnaPN)LgjFKeUi)WlsG4ZN(ne4mtwjJpKMvPZpOdXN(ne4JDsj66KHHsaaq(qAwLo)GUGGy63qGp2jLORtggkbaa5xmVccIPFdboZKvY4xmbbZ9JPKyip04puX1leFIPFdb(XkHhcwsAyip0Or5lPKgGfaq8lMGG5(XusmKhA8hQ46fIHjzIi2rVDug7lu64WdzA6vcttehGwanmsIcY0(7qaSchmmjteXo2rzSVqPJdpKPPxjmnrCaAJDsj66KHHsaaqawHd63qGZmzLm(fRJYyFHshhEittVsyAI4a0inmKhAK6OegGv4GpF63qGtmvH5iPdPSHpKMvPZp8Wvqq)gcCIPkmhjv30g(qAwLo)WdxVqyiKcg5j5mtwjJpKMvPZpOIRxbbgcPGrEsoZKvY4dzWa2rzSVqPJdpKPPxjmnrCaAmsrUVmL0ufWuJYhGv4WPnLPRiodwYqjC9fkH4ZN(ne4hReEiyjPHH8qJgLVKsAawaaXVyccIXqNuA5Zpc4uw6vqGHoP0YNNfqrVmyKGWPnLPRiE5KgIee0VHaxxHqWQR75xmi63qGRRqiy1198H0SkD(hnUr4JHs4B9CSHyLJKMQaMAu(8V0i5PPUKxVqet)gcCMjRKXVyq8jgdDsPLpplGIEzWibbgcPGrEsodLNOJK8frshwn174xmbHkFAWqk7jyzOak6LdPzv68NHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUiIebHkFAWqk7jyzOak6LdPzv6epXdpamU(hnUr4JHs4B9CSHyLJKMQaMAu(8V0i5PPUKxVDug7lu64WdzA6vcttehGwLmBs7lucWkC40MY0veNblzOeU(cLq85t)gc8JvcpeSK0WqEOrJYxsjnalaG4xmbbXyOtkT85hbCkl9kiWqNuA5ZZcOOxgmsq40MY0veVCsdrcc63qGRRqiy1198lge9BiW1vieS66E(qAwLo)HkUr4JHs4B9CSHyLJKMQaMAu(8V0i5PPUKxVqet)gcCMjRKXVyq8jgdDsPLpplGIEzWibbgcPGrEsodLNOJK8frshwn174xmbHkFAWqk7jyzOak6LdPzv68NHqkyKNKZq5j6ijFrK0Hvt9o(qAwLUiIebHkFAWqk7jyzOak6LdPzv6epXdpamU(dvCJWhdLW365ydXkhjnvbm1O85FPrYttDjVE7Om2xO0XHhY00ReMMioaTtBktxramnn6GZojzansMjRKbWttDPd(eJHqkyKNKZmzLm(qgmGccIDAtz6kIZq5j6ijHjhGjdcdDsPLpplGIEzWiVDug7lu64WdzA6vcttehGw4oakrbjPUjbWkCGyQcZr8kLwciedtYerSJq8bJEUbByFDssNhB0KWMMbK4FXowjqbbXyOtkT85jXgKcnWEHCAtz6kI7StsgqJKzYkzDug7lu64WdzA6vcttehGM7TXDhGeaRWbg6KslFEwaf9YGrqoTPmDfXzO8eDKKWKdWKbXC)ykjgYdn(Da)WfcdHuWipjNHYt0rs(IiPdRM6D8H0SkD(dKbZ1mXbGyuP8zUFmLed5HgXdQ46TJYyFHshhEittVsyAI4a0sYJudHsawHd(0VHaNyQcZrs1nTHFXee8XezdqYDiAidXezdqs(Lg5p09kiWezdqYDaQEHyysMiIDeYPnLPRiUZojzansMjRK1rzSVqPJdpKPPxjmnrCaAImvqQHqjaRWbF63qGtmvH5iP6M2WVyqeJHoP0YNFeWPSuqWN(ne4hReEiyjPHH8qJgLVKsAawaaXVyqyOtkT85hbCkl9ki4JjYgGK7q0qgIjYgGK8lnYFO7vqGjYgGK7aufe0VHaNzYkz8lMxigMKjIyhHCAtz6kI7StsgqJKzYkzDug7lu64WdzA6vcttehGw4Qusnekbyfo4t)gcCIPkmhjv30g(fdIym0jLw(8JaoLLcc(0VHa)yLWdbljnmKhA0O8LusdWcai(fdcdDsPLp)iGtzPxbbFmr2aKChIgYqmr2aKKFPr(dDVccmr2aKChGQGG(ne4mtwjJFX8cXWKmre7iKtBktxrCNDsYaAKmtwjRJYyFHshhEittVsyAI4a08yZuOrIcssDtQJYyFHshhEittVsyAI4a0CVnHAiawHdetvyoIxPuDtBeeiMQWCe3Hu2itsCVGaXufMJ4wcOmjX9cc63qG7XMPqJefKK6Me)Ibr)gcCIPkmhjv30g(ftqWN(ne4mtwjJpKMvPZFJ9fk5Eg7fXjXrS7tYV0ii63qGZmzLm(fZBhLX(cLoo8qMMELW0eXbO5zSxuhLX(cLoo8qMMELW0eXbOn3uASVqPuvUhGPPrhcMs9IMBhvhLX(cLoEWuQx0Cp4EBC3bibWkCqS5MuanajUUPSKrsuqAkL8fvjqhNI8BHHrWDug7lu64btPErZnIdqZDZqneazaYuK8Tbi9Ud4bWkCag9Cnekd1q8H0SkD(nKMvPRJYyFHshpyk1lAUrCaAAiugQH6O6Om2xO0XD)bd2W(6KKop2ObqgGmfjFBasV7aEaSchedg9Cd2W(6KKop2OjHnndiX)IDSsGqeZyFHsUbByFDssNhB0KWMMbK4vkdQcOOhIpXGrp3GnSVojPZJnAsrKP4FXowjqbby0Znyd7Rts68yJMuezk(qAwLo)GUxbby0Znyd7Rts68yJMe20mGe39g7O)qfcm65gSH91jjDESrtcBAgqIpKMvPZFOcbg9Cd2W(6KKop2OjHnndiX)IDSsGDug7lu64UpIdqJHYt0rs(IiPdRM6DaSch8DAtz6kIZq5j6ijHjhGjdIymesbJ8KCMjRKXhYGbuqq)gcCMjRKXVyEHyUFmLed5Hg)XpCH4t)gcCIPkmhjv30g(qAwLo)Wdxbb9BiWjMQWCK0Hu2WhsZQ05hE46vqiuaf9YH0SkD(JhUDug7lu64UpIdq70MY0veattJoaJE5qr(TgsJY3bWttDPd(0VHaNzYkz8H0SkD(bDi(0VHaFStkrxNmmucaaYhsZQ05h0feet)gc8XoPeDDYWqjaai)I5vqqm9BiWzMSsg)IjiyUFmLed5Hg)HkUEH4tm9BiWpwj8qWssdd5HgnkFjL0aSaaIFXeem3pMsIH8qJ)qfxVq8PFdboXufMJKoKYg(qAwLo)aYG5AM4ee0VHaNyQcZrs1nTHpKMvPZpGmyUMjoVDug7lu64UpIdqtdHYqneazaYuK8Tbi9Ud4bWkCyOWqorMUIG82aKE(xAK8rs4I8dVOH4ZWKmre7iKtBktxrCy0lhkYV1qAu(oVDug7lu64UpIdqZDZqneazaYuK8Tbi9Ud4bWkCyOWqorMUIG82aKE(xAK8rs4I8dVOH4ZWKmre7iKtBktxrCy0lhkYV1qAu(oVDug7lu64UpIdqZ9KszJmOSHaidqMIKVnaP3DapawHddfgYjY0veK3gG0Z)sJKpscxKF4fjq8zysMiIDeYPnLPRiom6Ldf53AinkFN3okJ9fkDC3hXbOfqdJKOGmT)oeaRWbdtYerSJDug7lu64UpIdqBStkrxNmmucaacWkCq)gcCMjRKXVyDug7lu64UpIdqJ0WqEOrQJsyawHd(8PFdboXufMJKoKYg(qAwLo)Wdxbb9BiWjMQWCKuDtB4dPzv68dpC9cHHqkyKNKZmzLm(qAwLo)GkUq8PFdbo2uAObUmL0gMLftIDvoB4NM6s(hn(HRGGyZnPaAasCSP0qdCzkPnmllMe7QC2WPi)wyyeSxVcc63qGJnLgAGltjTHzzXKyxLZg(PPUKFhIg)HRGadHuWipjNzYkz8HmyaH4ZC)ykjgYdn(fP4kiCAtz6kIxoPHiVDug7lu64UpIdqJrkY9LPKMQaMAu(aSchoTPmDfXzWsgkHRVqjeFM7htjXqEOXVifxi(0VHa)yLWdbljnmKhA0O8LusdWcai(ftqqmg6KslF(raNYsVccm0jLw(8Sak6LbJeeoTPmDfXlN0qKGG(ne46kecwDDp)Ibr)gcCDfcbRUUNpKMvPZ)OXncF(Iua0CtkGgGehBkn0axMsAdZYIjXUkNnCkYVfggb7ncFmucFRNJneRCK0ufWuJYN)Lgjpn1L861leX0VHaNzYkz8lgeFIXqNuA5ZZcOOxgmsqGHqkyKNKZq5j6ijFrK0Hvt9o(ftqOYNgmKYEcwgkGIE5qAwLo)ziKcg5j5muEIosYxejDy1uVJpKMvPlIirqOYNgmKYEcwgkGIE5qAwLoXt8WdaJR)rJBe(yOe(wphBiw5iPPkGPgLp)lnsEAQl51BhLX(cLoU7J4a0QKztAFHsawHdN2uMUI4myjdLW1xOeIpZ9JPKyip04xKIleF63qGFSs4HGLKggYdnAu(skPbybae)IjiigdDsPLp)iGtzPxbbg6KslFEwaf9YGrccN2uMUI4LtAisqq)gcCDfcbRUUNFXGOFdbUUcHGvx3ZhsZQ05puXncF(Iua0CtkGgGehBkn0axMsAdZYIjXUkNnCkYVfggb7ncFmucFRNJneRCK0ufWuJYN)Lgjpn1L861leX0VHaNzYkz8lgeFIXqNuA5ZZcOOxgmsqGHqkyKNKZq5j6ijFrK0Hvt9o(ftqOYNgmKYEcwgkGIE5qAwLo)ziKcg5j5muEIosYxejDy1uVJpKMvPlIirqOYNgmKYEcwgkGIE5qAwLoXt8WdaJR)qf3i8Xqj8TEo2qSYrstvatnkF(xAK80uxYR3okJ9fkDC3hXbODAtz6kcGPPrhC2jjdOrYmzLmaEAQlDWNymesbJ8KCMjRKXhYGbuqqStBktxrCgkprhjjm5amzqyOtkT85zbu0ldg5TJYyFHsh39rCaAH7aOefKK6MeaRWbIPkmhXRuAjGqmmjteXocr)gcCSP0qdCzkPnmllMe7QC2Wpn1L8pA8dxi(Grp3GnSVojPZJnAsytZas8VyhReOGGym0jLw(8KydsHgyVqoTPmDfXD2jjdOrYmzLSokJ9fkDC3hXbO5EBcMsbWkCq)gcCusViNeJggH9fk5xmi63qG7EBcMsXhkmKtKPROokJ9fkDC3hXbOXSKrkP(neayAA0b3BJcnWaSch0VHa392OqdmFinRsN)qhIp9BiWjMQWCK0Hu2WhsZQ05h0fe0VHaNyQcZrs1nTHpKMvPZpO7fI5(XusmKhA8lsXTJYyFHsh39rCaAU3MGPuaSchEtr5ZDpPu2iHNk8CknDfbdXr)xjqh3Huij8uHhI(ne4U3MGPuCyKNSJYyFHsh39rCaAU3g3DasaSchyOtkT85zbu0ldgb50MY0veNHYt0rsctoatgegcPGrEsodLNOJK8frshwn174dPzv68h6Dug7lu64UpIdqZ92emLcGv4WBkkFU7jLYgj8uHNtPPRiyiI9MIYN7EBuObMtPPRiyi63qG7EBcMsXhkmKtKPRii(0VHaNyQcZrs1nTHpKMvPZVibcXufMJ4vkv30gi63qGJnLgAGltjTHzzXKyxLZg(PPUK)rdDCfe0VHahBkn0axMsAdZYIjXUkNn8ttDj)oen0XfI5(XusmKhA8lsXvqag9Cd2W(6KKop2OjHnndiXhsZQ05hawqWyFHsUbByFDssNhB0KWMMbK4vkdQcOO3leXyiKcg5j5mtwjJpKbdyhLX(cLoU7J4a0CVnU7aKayfoOFdbokPxKtYuKnYZYvOKFXee0VHa)yLWdbljnmKhA0O8LusdWcai(ftqq)gcCMjRKXVyq8PFdb(yNuIUozyOeaaKpKMvPZFGmyUMjoaeJkLpZ9JPKyip0iEqfxVq0VHaFStkrxNmmucaaYVyccIPFdb(yNuIUozyOeaaKFXGigdHuWipjFStkrxNmmucaaYhYGbuqqmg6KslF(jLViahVccM7htjXqEOXVifxietvyoIxP0sa7Om2xO0XDFehGM7TXDhGeaRWH3uu(C3BJcnWCknDfbdXN(ne4U3gfAG5xmbbZ9JPKyip04xKIRxi63qG7EBuObM7EJD0FOcXN(ne4etvyos6qkB4xmbb9BiWjMQWCKuDtB4xmVq0VHahBkn0axMsAdZYIjXUkNn8ttDj)Jg)HleFmesbJ8KCMjRKXhsZQ05hE4kii2PnLPRiodLNOJKeMCaMmim0jLw(8Sak6LbJ82rzSVqPJ7(ioan3BJ7oajawHd(0VHahBkn0axMsAdZYIjXUkNn8ttDj)Jg)HRGG(ne4ytPHg4YusBywwmj2v5SHFAQl5F0qhxiVPO85UNukBKWtfEoLMUIG9cr)gcCIPkmhjDiLn8H0SkD(H)GqmvH5iELshszdeX0VHahL0lYjXOHryFHs(fdIyVPO85U3gfAG5uA6kcgcdHuWipjNzYkz8H0SkD(H)G4JHqkyKNKtAyip0i1rjmFinRsNF4pbbXyOtkT85hbCkl92rzSVqPJ7(ioaTK8i1qOeGv4Gp9BiWjMQWCKuDtB4xmbbFmr2aKChIgYqmr2aKKFPr(dDVccmr2aKChGQxigMKjIyhHCAtz6kI7StsgqJKzYkzDug7lu64UpIdqtKPcsnekbyfo4t)gcCIPkmhjv30g(fdIym0jLw(8JaoLLcc(0VHa)yLWdbljnmKhA0O8LusdWcai(fdcdDsPLp)iGtzPxbbFmr2aKChIgYqmr2aKKFPr(dDVccmr2aKChGQGG(ne4mtwjJFX8cXWKmre7iKtBktxrCNDsYaAKmtwjRJYyFHsh39rCaAHRsj1qOeGv4Gp9BiWjMQWCKuDtB4xmiIXqNuA5Zpc4uwki4t)gc8JvcpeSK0WqEOrJYxsjnalaG4xmim0jLw(8JaoLLEfe8XezdqYDiAidXezdqs(Lg5p09kiWezdqYDaQcc63qGZmzLm(fZledtYerSJqoTPmDfXD2jjdOrYmzLSokJ9fkDC3hXbO5XMPqJefKK6MuhLX(cLoU7J4a0CVnHAiawHdetvyoIxPuDtBeeiMQWCe3Hu2itsCVGaXufMJ4wcOmjX9cc63qG7XMPqJefKK6Me)Ibr)gcCIPkmhjv30g(ftqWN(ne4mtwjJpKMvPZFJ9fk5Eg7fXjXrS7tYV0ii63qGZmzLm(fZBhLX(cLoU7J4a08m2lQJYyFHsh39rCaAZnLg7lukvL7byAA0HGPuVO5c(Gpiia]] )


end