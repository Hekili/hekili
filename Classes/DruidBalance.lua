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


    spec:RegisterPack( "Balance", 20201227, [[dO0QMdqiOIhbvsCjQk0MaQpbvsnkQItrvAvQqYRecZsfQBbvI2fk)cuPHbv1XGQSmHupdQutJQICnqv2gvf13uHuJJQcCoHiToHimpQkDpvW(iQ6GuvqTqIkEOqunrHicxuiIOpker5KuvqALcjZeQeUPqev2jOIFkervdviI0sHkj5Pc1ubv1xPQGySqLKAVG8xcdwPdtzXuPhJQjd4YiBwWNbLrtuoTKxdeZMu3Mk2TOFdz4q54crz5kEojtxvxxL2Uk67uvnEIkDEG06vHy(ez)sneEqWhkgWEccorJF04Jx0rF0m8WhVJg)ifk(bfJGIXmoigmckonhckwoM2sobfJzGQrgae8HIvO7WjOyz)JPIeWfUWQx21LXroWvvoxT9fk5JfE4QkhoCHIDVL(9HMqUqXa2tqWjA8JgF8Io6JMHh(4D047dGIT7ldnqXXLtKdflRaaOeYfkgGuCOyCLELJPTKt9gjXClGokCLEJKG4KJln9g9rFCVrJF043r1rHR0BKlZsyKks0rHR0lUSxFyaacO3yK2MELdzoSokCLEXL9g5YSegb07Bdm6fvOxUPivVpQxoOCnjEBGrVI1rHR0lUSxCvKd6Ka69MjXjLYgq790MYC1KQxpfJyh3l2qNc1BJ6oWOEXLY3l2qNm1BJ6oWiVSokCLEXL96dFIkGEXgIBQVsy96dzSxwVvO36X1QEFzuV(hucR3ij56ctrSokCLEXL9gjNbc1BKJYteiuVVmQ3ySAQx1R1RU(xt96GgQ3GMKB5QPE9uHEbfD7vMbK46Vxz13B99QkNR(TKqxLg0E9xVSELtK8(WWV3i6nYjnP(Y096dRlyPdL)X9wpUgOxfifMxguSUuVcc(qXUi7HGpeCWdc(qXuAUAcasoqX8PEAkdk29gcmUjQKZUyqXg)lucfp2jLORsegkpcOqpeCIgc(qXuAUAcasoqXimOyf9qXg)lucfFAtzUAck(00xckgNEDVHaZ10wYjbkimTw8YQeMsK2FhIDX6fCV40R7neyUM2sojqbHP1IxwLWucB4wsSlgu8PnI0CiOy(uFI(lg0dbhCdbFOyknxnbajhOyJ)fkHInad7RtsO8BJdumFQNMYGIDVHaZ10wYjbkimTw8YQeMsK2FhIPEJdsV(2Rp1l4EDVHaZ10wYjbkimTw8YQeMsyd3sIPEJdsV(2Rp1l4E90lo9cGEMbyyFDscLFBCeaMJbJyFXbPsy9cUxC614FHsMbyyFDscLFBCeaMJbJyvkc6cMSVxW96PxC6fa9mdWW(6Kek)24iKrMM9fhKkH1RKuVaONzag2xNKq53ghHmY0SHCSkv9kFV4UxV9kj1la6zgGH91jju(TXrayogmIPEJdsV(2lU7fCVaONzag2xNKq53ghbG5yWi2qowLQE9Tx41l4EbqpZamSVojHYVnocaZXGrSV4GujSE9cfZbLRjXBdm6vqWbpOhco(ee8HIP0C1eaKCGI5t90ugumo9cm3cGLibhq1l4E90RNEpTPmxnX4O8ebcjaifOjVxW9ItVCesdG8NmUjQKZgYaaTxjPEDVHaJBIk5SlwVE7fCVE619gcmxtBjNeOGW0AXlRsykrA)DiM6noi9EOx41RKuVU3qG5AAl5KafeMwlEzvctjSHBjXuVXbP3d9cVE92RKuVHcMSxmKJvPQxF7fp871luSX)cLqXCuEIaHeVmsOWQPEf0dbh4bbFOyknxnbajhOy(upnLbf7Px3BiWCnTLCsGcctRfVSkHPeP93Hyd5yvQ6v(E9jg86vsQx3BiWCnTLCsGcctRfVSkHPe2WTKyd5yvQ6v(E9jg861BVG71u)yAbgYpn9k)HEJu87fCVE6LJqAaK)KXnrLC2qowLQELV3JUxjPE90lhH0ai)jJCWq(Pr4Isa2qowLQELV3JUxW9ItVU3qGbsLadbiihmKFACO8fusdS6ie7I1l4E5OtkT8zGa6uw2R3E9cfB8Vqjum3soPfU3qak29gcI0CiOy1BJgnaqpeC8zi4dftP5Qjai5afZN6PPmOyC690MYC1eJp1NO)I1l4E90lhDsPLpllyYErWOELK6LJqAaK)KXnrLC2qowLQELV3JUxjPEXP3tBkZvtmoGGJsG6lu2l4EXPxo6KslFgiGoLL9kj1RNE5iKga5pzKdgYpncxucWgYXQu1R89E09cUxC619gcmqQeyiab5GH8tJdLVGsAGvhHyxSEb3lhDsPLpdeqNYYE92RxOyJ)fkHIvVnQ7aJGEi4C0qWhkMsZvtaqYbkMp1ttzqXE6LJqAaK)KXr5jces8YiHcRM6vSHCSkv96BVWRxW9ItVaZTayjsWbu9cUxp9EAtzUAIXr5jcesaqkqtEVss9YrinaYFY4MOsoBihRsvV(2l861BVE7fCVM6htlWq(PPx571NWVxW9YrNuA5ZYcMSxemQxW9ItVaZTayjsWbuqXg)lucfREBu3bgb9qWXhabFOyknxnbajhOyeguSIEOyJ)fkHIpTPmxnbfFA6lbf7Px3BiW4MOsoBihRsvVY3l86fCVE619gcSXoPeDvIWq5raLnKJvPQx57fE9kj1lo96Edb2yNuIUkryO8iGYUy96TxjPEXPx3BiW4MOso7I1RKuVM6htlWq(PPxF7f343R3Eb3RNEXPx3BiWaPsGHaeKdgYpnou(ckPbwDeIDX6vsQxt9JPfyi)00RV9IB871BVG71tVU3qGrCDHPiHcPTHnKJvPQx57fghG5yYTxjPEDVHaJ46ctrc9nTHnKJvPQx57fghG5yYTxVqXN2isZHGIbqVyOi7wd5q5RGEi4ePqWhkMsZvtaqYbk24FHsOy1nd1qqX8PEAkdkEOWqkzMRM6fCVVnWON9LdjEKaOOELVx885Eb3RHj4Yioi9cU3tBkZvtma0lgkYU1qou(kOyoOCnjEBGrVcco4b9qWbp8HGpumLMRMaGKduSX)cLqXoiugQHGI5t90ugu8qHHuYmxn1l4EFBGrp7lhs8ibqr9kFV4HBg86fCVgMGlJ4G0l4EpTPmxnXaqVyOi7wd5q5RGI5GY1K4Tbg9ki4Gh0dbh8Wdc(qXuAUAcasoqXg)lucfREsRTre02qqX8PEAkdkEOWqkzMRM6fCVVnWON9LdjEKaOOELVx885EJO3HCSkv9cUxdtWLrCq6fCVN2uMRMyaOxmuKDRHCO8vqXCq5As82aJEfeCWd6HGdErdbFOyknxnbajhOy(upnLbfBycUmIdcuSX)cLqXb0Wjbkis7Vdb9qWbpCdbFOyknxnbajhOy(upnLbf7PxIRlmfXQuyjO9kj1lX1fMIykK2grLc86vsQxIRlmfX030grLc861BVG71tV40lhDsPLpllyYErWOELK6fyUfalrcoGQxjPE90RP(X0cmKFA613EJu41l4E907PnL5QjgFQpr)fRxjPEn1pMwGH8ttV(2lUXVxjPEpTPmxnXkLWquVE7fCVE690MYC1eJJYteiKaGuGM8Eb3lo9YrinaYFY4O8ebcjEzKqHvt9k2fRxjPEXP3tBkZvtmokprGqcasbAY7fCV40lhH0ai)jJBIk5SlwVE71BVE7fCVE6LJqAaK)KXnrLC2qowLQELVxCJFVss9cm3cGLibhq1RKuVM6htlWq(PPx57nsXVxW9YrinaYFY4MOso7I1l4E90lhH0ai)jJCWq(Pr4Isa2qowLQE9TxJ)fkzQ3MqneJKlXVpj(YH6vsQxC6LJoP0YNbcOtzzVE7vsQ3kFAWqA7jarOGj7fd5yvQ613EXd)E92l4E90la6zgGH91jju(TXrayogmInKJvPQx571N6vsQxC6LJoP0YNLeFqA0a0RxOyJ)fkHId3bubkii9njOhco45tqWhkMsZvtaqYbkMp1ttzqXE6L46ctrm9nTrKKC)ELK6L46ctrmfsBJij5(9kj1lX1fMIywcQij5(9kj1R7neyUM2sojqbHP1IxwLWuI0(7qSHCSkv9kFV(edE9kj1R7neyUM2sojqbHP1IxwLWucB4wsSHCSkv9kFV(edE9kj1RP(X0cmKFA6v(EJu87fCVCesdG8NmUjQKZgYaaTxW9ItVaZTayjsWbu96TxW96PxocPbq(tg3evYzd5yvQ6v(EXn(9kj1lhH0ai)jJBIk5SHmaq71BVss9w5tdgsBpbicfmzVyihRsvV(2lE4dfB8Vqjum5GH8tJWfLaqpeCWdEqWhkMsZvtaqYbkMp1ttzqX40lWClawIeCavVG790MYC1eJdi4OeO(cL9cUxp9AQFmTad5NMELV3if)Eb3RNEDVHadKkbgcqqoyi)04q5lOKgy1ri2fRxjPEXPxo6KslFgiGoLL96TxjPE5OtkT8zzbt2lcg1RKuVU3qG5Qria9v9SlwVG719gcmxncbOVQNnKJvPQxF7nA87nIE90lhLa36zydXlfjmDblDO8zF5qIttFPE92R3Eb3RNEpTPmxnX4O8ebcjaifOjVxjPE5iKga5pzCuEIaHeVmsOWQPEfBida0E92RKuVv(0GH02taIqbt2lgYXQu1RV9gn(9grVE6LJsGB9mSH4LIeMUGLou(SVCiXPPVuVEHIn(xOekMtAs9LPfMUGLou(qpeCWZNHGpumLMRMaGKdumFQNMYGIXPxG5waSej4aQEb37PnL5QjghqWrjq9fk7fCVE61u)yAbgYpn9kFVrk(9cUxp96EdbgivcmeGGCWq(PXHYxqjnWQJqSlwVss9ItVC0jLw(mqaDkl71BVss9YrNuA5ZYcMSxemQxjPEDVHaZvJqa6R6zxSEb3R7neyUAecqFvpBihRsvV(2lUXV3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61BVE7fCVE690MYC1eJJYteiKaGuGM8ELK6LJqAaK)KXr5jces8YiHcRM6vSHmaq71BVss9w5tdgsBpbicfmzVyihRsvV(2lUXV3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61luSX)cLqXvYTjTVqj0dbh8oAi4dftP5Qjai5afJWGIv0dfB8Vqju8PnL5QjO4ttFjOyIRlmfXQuOVPn9Eu96d6fU9A8Vqjt92eQHyKCj(9jXxouVr0lo9sCDHPiwLc9nTP3JQxFUx42RX)cLm)J9YyKCj(9jXxouVr0l(SO7fU9QWiTwiZupbfFAJinhck2uyrsPjM4qpeCWZhabFOyknxnbajhOy(upnLbf7P3kFAWqA7jarOGj7fd5yvQ613E9PELK61tVU3qGn2jLORsegkpcOSHCSkv96BVW4amhtU9Eu9YPs3RNEn1pMwGH8ttVWTxCJFVE7fCVU3qGn2jLORsegkpcOSlwVE71BVss96Pxt9JPfyi)00Be9EAtzUAIzkSiP0et8EpQEDVHaJ46ctrcfsBdBihRsvVr0la6zH7aQafeK(Me7loikXqowL9Eu9gndE9kFV4fn(9kj1RP(X0cmKFA6nIEpTPmxnXmfwKuAIjEVhvVU3qGrCDHPiH(M2WgYXQu1Be9cGEw4oGkqbbPVjX(IdIsmKJvzVhvVrZGxVY3lErJFVE7fCVexxykIvPWsq7fCVE61tV40lhH0ai)jJBIk5SlwVss9YrNuA5Zab0PSSxW9ItVCesdG8NmYbd5NgHlkbyxSE92RKuVC0jLw(SSGj7fbJ61BVG71tV40lhDsPLp7KYxgOtVss9ItVU3qGXnrLC2fRxjPEn1pMwGH8ttVY3BKIFVE7vsQx3BiW4MOsoBihRsvVY3RpOxW9ItVU3qGn2jLORsegkpcOSlguSX)cLqXQ3g1DGrqpeCWlsHGpumLMRMaGKdumFQNMYGI90R7neyexxyksOVPnSlwVss96PxUmBGrQEp0B09cU3H4YSbgj(YH613EHxVE7vsQxUmBGrQEp0lU71BVG71WeCzeheOyJ)fkHItYVWbHsOhcorJpe8HIP0C1eaKCGI5t90uguSNEDVHaJ46ctrc9nTHDX6vsQxp9YLzdms17HEJUxW9oexMnWiXxouV(2l861BVss9YLzdms17HEXDVE7fCVgMGlJ4GafB8VqjuSmtheoiuc9qWjA8GGpumLMRMaGKdumFQNMYGI90R7neyexxyksOVPnSlwVss96PxUmBGrQEp0B09cU3H4YSbgj(YH613EHxVE7vsQxUmBGrQEp0lU71BVG71WeCzeheOyJ)fkHIdxTw4Gqj0dbNOJgc(qXg)lucf73MPqJafeK(MeumLMRMaGKd0dbNOXne8HIP0C1eaKCGI5t90ugumX1fMIyvk030MELK6L46ctrmfsBJij5(9kj1lX1fMIywcQij5(9kj1R7ney(Tzk0iqbbPVjXUy9cUx3BiWiUUWuKqFtByxSELK61tVU3qGXnrLC2qowLQE9TxJ)fkz(h7LXi5s87tIVCOEb3R7neyCtujNDX61luSX)cLqXQ3Mqne0dbNO9ji4dfB8VqjuS)XEzqXuAUAcasoqpeCIgEqWhkMsZvtaqYbk24FHsO45McJ)fkf6s9qX6s9I0CiO4GP1VS5c9qpumafSR(HGpeCWdc(qXg)lucfRqABeUK5aftP5Qjai5a9qWjAi4dftP5Qjai5afJWGIv0dfB8Vqju8PnL5QjO4ttFjOyfgP1I3gy0RyQ3MGP19kFV41l4E90lo9(MMYNPEB0ObGrP5QjGELK69nnLpt9KwBJayQWZO0C1eqVE7vsQxfgP1I3gy0RyQ3MGP19kFVrdfFAJinhckUucdrqpeCWne8HIP0C1eaKCGIryqXk6HIn(xOek(0MYC1eu8PPVeuScJ0AXBdm6vm1BtOgQx57fpO4tBeP5qqXLsW1KDsqpeC8ji4dftP5Qjai5afZN6PPmOyp9ItVC0jLw(SSGj7fbJ6vsQxC6LJqAaK)KXr5jces8YiHcRM6vSlwVE7fCVU3qGXnrLC2fdk24FHsOyxAu0asLWGEi4api4dftP5Qjai5afZN6PPmOy3BiW4MOso7IbfB8Vqjumg6luc9qWXNHGpumLMRMaGKdumcdkwrpuSX)cLqXN2uMRMGIpn9LGIdAeA61tVE6TYNgmK2EcqekyYEXqowLQEXL9gn(9Il7LJqAaK)KXr5jces8YiHcRM6vSHCSkv96Tx42lErJFVE7v(EdAeA61tVE6TYNgmK2EcqekyYEXqowLQEXL9gn86fx2RNEXd)EpQEFtt5ZQKBtAFHsgLMRMa61BV4YE90lhLa36zydXlfjmDblDO8zF5qIttFPE92lUSxocPbq(tg3evYzd5yvQ61BVWTx88b43R3ELK6LJqAaK)KXnrLC2qowLQELV3kFAWqA7jarOGj7fd5yvQ6vsQxocPbq(tghLNiqiXlJekSAQxXgYXQu1R89w5tdgsBpbicfmzVyihRsvVss9ItVC0jLw(SSGj7fbJGIpTrKMdbfZr5jcesaqkqto0dbNJgc(qXuAUAcasoqXimOyf9qXg)lucfFAtzUAck(00xck2tV40lfz3cdJayKdgOdzAbAasl5uVss9YrinaYFYihmqhY0c0aKwYj2qowLQE9Tx88z87fCV40lhH0ai)jJCWaDitlqdqAjNydzaG2R3ELK6LJoP0YNbcOtzju8PnI0CiOyoGGJsG6luc9qWXhabFOyknxnbajhOyJ)fkHIjhmqhY0c0aKwYjOy(upnLbfZrinaYFY4MOsoBihRsvV(2B043l4EpTPmxnX4O8ebcjaifOjVxjPE5iKga5pzCuEIaHeVmsOWQPEfBihRsvV(2B04dfNMdbftoyGoKPfObiTKtqpeCIui4dftP5Qjai5afB8VqjuScD1A6)kHjMRlOqX8PEAkdkMJqAaK)KXnrLC2qowLQE9TxFUxW9EAtzUAIXr5jcesaqkqtEVss9YrinaYFY4O8ebcjEzKqHvt9k2qowLQE9TxFgkonhckwHUAn9FLWeZ1fuOhco4Hpe8HIP0C1eaKCGIn(xOekUsfFUV5QjrKDT8Voca6S4eumFQNMYGIDVHaJBIk5SlguCAoeuCLk(CFZvtIi7A5FDea0zXjOhco4Hhe8HIP0C1eaKCGI5t90uguS7neyCtujNDX6vsQxo6KslFwwWK9IGr9cU3tBkZvtmokprGqcasbAY7fCVCesdG8NmokprGqIxgjuy1uVIDX6fCV40lhH0ai)jJBIk5SlwVG71tVE619gcmIRlmfj030g2qowLQELVx8WVxjPEDVHaJ46ctrcfsBdBihRsvVY3lE43R3Eb3lo9o3KcObgXCnTLCsGcctRfVSkHPyuAUAcOxjPENBsb0aJyUM2sojqbHP1IxwLWumknxnb0l4E90R7neyUM2sojqbHP1IxwLWuI0(7qm1BCq6v(EXDVss96EdbMRPTKtcuqyAT4LvjmLWgULet9ghKELVxC3R3E92RKuVU3qGbsLadbiihmKFACO8fusdS6ie7I1RKuVHcMSxmKJvPQxF7nA8HIn(xOek(Qir9KJc6HGdErdbFOyknxnbajhOy(upnLbfFAtzUAIvkHHiOy1pf)HGdEqXg)lucfp3uy8VqPqxQhkwxQxKMdbfBic6HGdE4gc(qXuAUAcasoqX8PEAkdkEUjfqdmI9Ld5hnPayiZXTsaAyuKDlmmcakw9tXFi4GhuSX)cLqXZnfg)luk0L6HI1L6fP5qqXadzoUvcqd0dbh88ji4dftP5Qjai5afZN6PPmO45MuanWiMRPTKtcuqyAT4LvjmfJISBHHraqXQFk(dbh8GIn(xOekEUPW4FHsHUupuSUuVinhck2fzp0dbh8Ghe8HIP0C1eaKCGIn(xOekEUPW4FHsHUupuSUuVinhckw9qp0dfJneh54Ape8HGdEqWhk24FHsOyqQeyiaHcRM6vqXuAUAcasoqpeCIgc(qXg)lucf7GqjivkcOXbkMsZvtaqYb6HGdUHGpumLMRMaGKduSX)cLqX(h7LbfZN6PPmOyp9sCDHPiM(M2issUFVss9sCDHPiwLc9nTPxjPEjUUWueRsHl6L1RKuVexxykIzjOIKK73RxOyDLKGdafJh(qpeC8ji4dftP5Qjai5afZN6PPmOyp9sCDHPiM(M2issUFVss9sCDHPiwLc9nTPxjPEjUUWueRsHl6L1RKuVexxykIzjOIKK73R3Eb3l2qNm8y(h7L1l4EXPxSHozrZ8p2ldk24FHsOy)J9YGEi4api4dftP5Qjai5afZN6PPmOyC6DUjfqdmI5AAl5KafeMwlEzvctXO0C1eqVss9ItVC0jLw(SSGj7fbJ6vsQxC6vHrAT4Tbg9kM6TjyADVh6fVELK6fNEFtt5Zs7VdPeUM2soXO0C1eauSX)cLqXQ3Mqne0dbhFgc(qXuAUAcasoqX8PEAkdkEUjfqdmI5AAl5KafeMwlEzvctXO0C1eqVG7LJoP0YNLfmzViyuVG7vHrAT4Tbg9kM6TjyADVh6fpOyJ)fkHIvVnQ7aJGEOhk2qee8HGdEqWhkMsZvtaqYbkgHbfROhk24FHsO4tBkZvtqXNM(sqXE619gcSVCi)OjfadzoUvcqdBihRsvV(2lmoaZXKBVr0l(m86vsQx3BiW(YH8JMuamK54wjanSHCSkv96BVg)luYuVnHAigjxIFFs8Ld1Be9IpdVEb3RNEjUUWueRsH(M20RKuVexxykIPqABejj3VxjPEjUUWueZsqfjj3VxV96TxW96Edb2xoKF0KcGHmh3kbOHDX6fCVZnPaAGrSVCi)OjfadzoUvcqdJISBHHraqXN2isZHGIbgYCe(lTwemTwGcbOhcordbFOyknxnbajhOyeguSIEOyJ)fkHIpTPmxnbfFA6lbf7EdbgX1fMIe6BAd7I1l4E90RcJ0AXBdm6vm1BtOgQx571N6fCVVPP8zk0vlqbXlJeb0qQNrP5QjGELK6vHrAT4Tbg9kM6Tjud1R896Z96fk(0grAoeuCblrdjuVnQ7aJGEi4GBi4dftP5Qjai5afZN6PPmOyC6fyUfalrcoGQxW96Pxp9EAtzUAIXr5jcesaqkqtEVG7fNE5iKga5pzCtujNnKbaAVss96Edbg3evYzxSE92l4E90RP(X0cmKFA613EHh(9kj17PnL5QjwblrdjuVnQ7aJ61BVG71tVU3qGrCDHPiH(M2WgYXQu1R896Z9kj1R7neyexxyksOqAByd5yvQ6v(E95E92l4E90lo9o3KcObgXCnTLCsGcctRfVSkHPyuAUAcOxjPEDVHaZ10wYjbkimTw8YQeMsK2FhIPEJdsVY3lU7vsQx3BiWCnTLCsGcctRfVSkHPe2WTKyQ34G0R89I7E92RKuVHcMSxmKJvPQxF7fp871luSX)cLqXCuEIaHeVmsOWQPEf0dbhFcc(qXuAUAcasoqXg)lucfRUzOgckMp1ttzqXdfgsjZC1uVG79Tbg9SVCiXJeaf1R89INp1lUSxfgP1I3gy0R6nIEhYXQu1l4E90lX1fMIyvkSe0ELK6DihRsvV(2lmoaZXKBVEHI5GY1K4Tbg9ki4Gh0dbh4bbFOyknxnbajhOy(upnLbf7EdbM6TjyAnBOWqkzMRM6fCVE6vHrAT4Tbg9kM6TjyADV(2lU7vsQxC6DUjfqdmI9Ld5hnPayiZXTsaAyuKDlmmcOxV9cUxp9ItVZnPaAGrmnOCBmLiOj6ReMaMUCWueJISBHHra9kj17xouV(yV(e86v(EDVHat92emTMnKJvPQ3i6n6E92l4EdfmzVyihRsvVY3l8GIn(xOekw92emTg6HGJpdbFOyknxnbajhOy(upnLbfp3KcObgX(YH8JMuamK54wjanmkYUfggb0l4EvyKwlEBGrVIPEBcMw3R8h6f39cUxp9ItVU3qG9Ld5hnPayiZXTsaAyxSEb3R7neyQ3MGP1SHcdPKzUAQxjPE907PnL5QjgWqMJWFP1IGP1cui0l4E90R7neyQ3MGP1SHCSkv96BV4UxjPEvyKwlEBGrVIPEBcMw3R89gDVG79nnLpt9KwBJayQWZO0C1eqVG719gcm1BtW0A2qowLQE9Tx41R3E92RxOyJ)fkHIvVnbtRHEi4C0qWhkMsZvtaqYbkgHbfROhk24FHsO4tBkZvtqXNM(sqXM6htlWq(PPx571hGFV4YE90lE437r1R7neyF5q(rtkagYCCReGgM6noi96TxCzVE619gcm1BtW0A2qowLQEpQEXDVWTxfgP1czM6PE92lUSxp9cGEw4oGkqbbPVjXgYXQu17r1l861BVG719gcm1BtW0A2fdk(0grAoeuS6TjyATWpkFrW0AbkeGEi44dGGpumLMRMaGKdumFQNMYGIpTPmxnXagYCe(lTwemTwGcHEb37PnL5QjM6TjyATWpkFrW0Abke6fCV407PnL5QjwblrdjuVnQ7aJ6vsQxp96EdbMRPTKtcuqyAT4LvjmLiT)oet9ghKELVxC3RKuVU3qG5AAl5KafeMwlEzvctjSHBjXuVXbPx57f396TxW9QWiTw82aJEft92emTUxF71NGIn(xOekw92OUdmc6HGtKcbFOyknxnbajhOyJ)fkHInad7RtsO8BJdumFQNMYGIXP3V4GujSEb3lo9A8VqjZamSVojHYVnocaZXGrSkfbDbt23RKuVaONzag2xNKq53ghbG5yWiM6noi96BV4UxW9cGEMbyyFDscLFBCeaMJbJyd5yvQ613EXnumhuUMeVnWOxbbh8GEi4Gh(qWhkMsZvtaqYbk24FHsOyhekd1qqX8PEAkdkEOWqkzMRM6fCVVnWON9LdjEKaOOELVxp9INp1Be96PxfgP1I3gy0RyQ3MqnuVhvV4XGxVE71BVWTxfgP1I3gy0R6nIEhYXQu1l4E90RNE5iKga5pzCtujNnKbaAVG7fNEbMBbWsKGdO6fCVE690MYC1eJJYteiKaGuGM8ELK6LJqAaK)KXr5jces8YiHcRM6vSHmaq7vsQxC6LJoP0YNLfmzViyuVE7vsQxfgP1I3gy0RyQ3MqnuV(2RNEHxVhvVE6fVEJO330u(S3FLchekvmknxnb0R3E92RKuVE6L46ctrSkfkK2MELK61tVexxykIvPWf9Y6vsQxIRlmfXQuOVPn96TxW9ItVVPP8zk0vlqbXlJeb0qQNrP5QjGELK619gcmSPCqdqzAHnCllUa7Qv2Won9L6v(d9gn8WVxV9cUxp9QWiTw82aJEft92eQH613EXd)EpQE90lE9grVVPP8zV)kfoiuQyuAUAcOxV96TxW9AQFmTad5NMELVx4HFV4YEDVHat92emTMnKJvPQ3JQxFUxV9cUxp9ItVU3qGbsLadbiihmKFACO8fusdS6ie7I1RKuVexxykIvPqH020RKuV40lhDsPLpdeqNYYE92l4EnmbxgXbPxVqXCq5As82aJEfeCWd6HGdE4bbFOyknxnbajhOy(upnLbfBycUmIdcuSX)cLqXb0Wjbkis7Vdb9qWbVOHGpumLMRMaGKdumFQNMYGIDVHaJBIk5SlguSX)cLqXJDsj6QeHHYJak0dbh8Wne8HIP0C1eaKCGI5t90ugumo9cm3cGLibhq1l4EpTPmxnX4acokbQVqzVG71tVU3qGPEBcMwZUy9kj1RP(X0cmKFA6v(EHh(96TxW9ItVU3qGPqA1xCIDX6fCV40R7neyCtujNDX6fCVE6fNE5OtkT8zzbt2lcg1RKuVN2uMRMyCuEIaHeaKc0K3RKuVCesdG8NmokprGqIxgjuy1uVIDX6vsQ3kFAWqA7jarOGj7fd5yvQ613EJg)EJOxp9YrjWTEg2q8srctxWshkF2xoK400xQxV96fk24FHsOyoPj1xMwy6cw6q5d9qWbpFcc(qXuAUAcasoqX8PEAkdkgNEbMBbWsKGdO6fCVN2uMRMyCabhLa1xOSxW96Px3BiWuVnbtRzxSELK61u)yAbgYpn9kFVWd)E92l4EXPx3BiWuiT6loXUy9cUxC619gcmUjQKZUy9cUxp9ItVC0jLw(SSGj7fbJ6vsQ3tBkZvtmokprGqcasbAY7vsQxocPbq(tghLNiqiXlJekSAQxXUy9kj1BLpnyiT9eGiuWK9IHCSkv96BVCesdG8NmokprGqIxgjuy1uVInKJvPQ3i61N7vsQ3kFAWqA7jarOGj7fd5yvQ61h7fpFa(96BV4g)EJOxp9YrjWTEg2q8srctxWshkF2xoK400xQxV96fk24FHsO4k52K2xOe6HGdEWdc(qXuAUAcasoqX8PEAkdkUYNgmK2EcqekyYEXqowLQE9Tx8GxVss96Px3BiWWMYbnaLPf2WTS4cSRwzd700xQxF7nA4HFVss96Edbg2uoObOmTWgULfxGD1kByNM(s9k)HEJgE43R3Eb3R7neyQ3MGP1SlwVG71tVCesdG8NmUjQKZgYXQu1R89cp87vsQxG5waSej4aQE9cfB8Vqjum5GH8tJWfLaqpeCWZNHGpumLMRMaGKduSX)cLqXQN0ABebTneumFQNMYGIhkmKsM5QPEb37xoK4rcGI6v(EXdE9cUxfgP1I3gy0RyQ3MqnuV(2Rp1l4EnmbxgXbPxW96Px3BiW4MOsoBihRsvVY3lE43RKuV40R7neyCtujNDX61lumhuUMeVnWOxbbh8GEi4G3rdbFOyknxnbajhOy(upnLbftCDHPiwLclbTxW9AycUmIdsVG719gcmSPCqdqzAHnCllUa7Qv2Won9L613EJgE43l4E90la6zgGH91jju(TXrayogmI9fhKkH1RKuV40lhDsPLplj(G0ObOxjPEvyKwlEBGrVQx57n6E9cfB8VqjuC4oGkqbbPVjb9qWbpFae8HIP0C1eaKCGI5t90uguS7neyOKEzkbgnCc7luYUy9cUxp96EdbM6TjyAnBOWqkzMRM6vsQxt9JPfyi)00R89gP43RxOyJ)fkHIvVnbtRHEi4GxKcbFOyknxnbajhOy(upnLbfZrNuA5ZYcMSxemQxW96P3tBkZvtmokprGqcasbAY7vsQxocPbq(tg3evYzxSELK619gcmUjQKZUy96TxW9YrinaYFY4O8ebcjEzKqHvt9k2qowLQE9TxyCaMJj3EpQE5uP71tVM6htlWq(PPx42l8WVxV9cUx3BiWuVnbtRzd5yvQ613E9PEb3lo9cm3cGLibhqbfB8VqjuS6TjyAn0dbNOXhc(qXuAUAcasoqX8PEAkdkMJoP0YNLfmzViyuVG71tVN2uMRMyCuEIaHeaKc0K3RKuVCesdG8NmUjQKZUy9kj1R7neyCtujNDX61BVG7LJqAaK)KXr5jces8YiHcRM6vSHCSkv96BV(CVG719gcm1BtW0A2fRxW9sCDHPiwLclbTxW9ItVN2uMRMyfSenKq92OUdmQxW9ItVaZTayjsWbuqXg)lucfREBu3bgb9qWjA8GGpumLMRMaGKdumFQNMYGIDVHadL0ltj4AYgXzPkuYUy9kj1RNEXPx1BtOgIzycUmIdsVss96Px3BiW4MOsoBihRsvV(2l86fCVU3qGXnrLC2fRxjPE90R7neyJDsj6QeHHYJakBihRsvV(2lmoaZXKBVhvVCQ096Pxt9JPfyi)00lC7f343R3Eb3R7neyJDsj6QeHHYJak7I1R3E92l4EpTPmxnXuVnbtRf(r5lcMwlqHqVG7vHrAT4Tbg9kM6TjyADV(2lU71BVG71tV407CtkGgye7lhYpAsbWqMJBLa0WOi7wyyeqVss9QWiTw82aJEft92emTUxF7f396fk24FHsOy1BJ6oWiOhcorhne8HIP0C1eaKCGI5t90uguSNEjUUWueRsHLG2l4E5iKga5pzCtujNnKJvPQx57fE43RKuVE6LlZgyKQ3d9gDVG7DiUmBGrIVCOE9Tx41R3ELK6LlZgyKQ3d9I7E92l4EnmbxgXbbk24FHsO4K8lCqOe6HGt04gc(qXuAUAcasoqX8PEAkdk2tVexxykIvPWsq7fCVCesdG8NmUjQKZgYXQu1R89cp87vsQxp9YLzdms17HEJUxW9oexMnWiXxouV(2l861BVss9YLzdms17HEXDVE7fCVgMGlJ4GafB8VqjuSmtheoiuc9qWjAFcc(qXuAUAcasoqX8PEAkdk2tVexxykIvPWsq7fCVCesdG8NmUjQKZgYXQu1R89cp87vsQxp9YLzdms17HEJUxW9oexMnWiXxouV(2l861BVss9YLzdms17HEXDVE7fCVgMGlJ4GafB8VqjuC4Q1chekHEi4en8GGpuSX)cLqX(Tzk0iqbbPVjbftP5Qjai5a9qWjAFgc(qXuAUAcasoqXimOyf9qXg)lucfFAtzUAck(00xckwHrAT4Tbg9kM6Tjud1R896t9grVbncn96Pxht90aQ400xQ3JQx8Wh)EHBVrJFVE7nIEdAeA61tVU3qGPEBu3bgjihmKFACO8fkK2gM6noi9c3E9PE9cfFAJinhckw92eQHevkuiTnqpeCI(OHGpumLMRMaGKdumFQNMYGIjUUWuetFtBejj3VxjPEjUUWueZsqfjj3VxW9EAtzUAIvkbxt2j1RKuVU3qGrCDHPiHcPTHnKJvPQxF714FHsM6TjudXi5s87tIVCOEb3R7neyexxyksOqAByxSELK6L46ctrSkfkK2MEb3lo9EAtzUAIPEBc1qIkfkK2MELK619gcmUjQKZgYXQu1RV9A8Vqjt92eQHyKCj(9jXxouVG7fNEpTPmxnXkLGRj7K6fCVU3qGXnrLC2qowLQE9TxsUe)(K4lhQxW96Edbg3evYzxSELK619gcSXoPeDvIWq5raLDX6fCVkmsRfYm1t9kFV4Z85Eb3RNEvyKwlEBGrVQxFp0lU7vsQxC69nnLptHUAbkiEzKiGgs9mknxnb0R3ELK6fNEpTPmxnXkLGRj7K6fCVU3qGXnrLC2qowLQELVxsUe)(K4lhck24FHsOy)J9YGEi4eTpac(qXg)lucfREBc1qqXuAUAcasoqpeCIosHGpumLMRMaGKduSX)cLqXZnfg)luk0L6HI1L6fP5qqXbtRFzZf6HEO4GP1VS5cbFi4Ghe8HIP0C1eaKCGI5t90ugumo9o3KcObgXCnTLCsGcctRfVSkHPyuKDlmmcak24FHsOy1BJ6oWiOhcordbFOyknxnbajhOyJ)fkHIv3mudbfZN6PPmOya0ZCqOmudXgYXQu1R89oKJvPckMdkxtI3gy0RGGdEqpeCWne8HIn(xOek2bHYqneumLMRMaGKd0d9qXQhc(qWbpi4dftP5Qjai5afB8VqjuSbyyFDscLFBCGI5t90ugumo9cGEMbyyFDscLFBCeaMJbJyFXbPsy9cUxC614FHsMbyyFDscLFBCeaMJbJyvkc6cMSVxW96PxC6fa9mdWW(6Kek)24iKrMM9fhKkH1RKuVaONzag2xNKq53ghHmY0SHCSkv9kFVWRxV9kj1la6zgGH91jju(TXrayogmIPEJdsV(2lU7fCVaONzag2xNKq53ghbG5yWi2qowLQE9TxC3l4EbqpZamSVojHYVnocaZXGrSV4GujmOyoOCnjEBGrVcco4b9qWjAi4dftP5Qjai5afZN6PPmOyC6fyUfalrcoGQxW96Pxp9EAtzUAIXr5jcesaqkqtEVG7fNE5iKga5pzCtujNnKbaAVss96Edbg3evYzxSE92l4En1pMwGH8ttV(2RpHFVG71tVU3qGrCDHPiH(M2WgYXQu1R89Ih(9kj1R7neyexxyksOqAByd5yvQ6v(EXd)E92RKuVHcMSxmKJvPQxF7fp871luSX)cLqXCuEIaHeVmsOWQPEf0dbhCdbFOyknxnbajhOyeguSIEOyJ)fkHIpTPmxnbfFA6lbf7Px3BiW4MOsoBihRsvVY3l86fCVE619gcSXoPeDvIWq5raLnKJvPQx57fE9kj1lo96Edb2yNuIUkryO8iGYUy96TxjPEXPx3BiW4MOso7I1RKuVM6htlWq(PPxF7f343R3Eb3RNEXPx3BiWaPsGHaeKdgYpnou(ckPbwDeIDX6vsQxt9JPfyi)00RV9IB871BVG71tVU3qGrCDHPiHcPTHnKJvPQx57fghG5yYTxjPEDVHaJ46ctrc9nTHnKJvPQx57fghG5yYTxVqXN2isZHGIbqVyOi7wd5q5RGEi44tqWhkMsZvtaqYbk24FHsOyhekd1qqX8PEAkdkEOWqkzMRM6fCVVnWON9LdjEKaOOELVx8IUxW96PxdtWLrCq6fCVN2uMRMyaOxmuKDRHCO8v96fkMdkxtI3gy0RGGdEqpeCGhe8HIP0C1eaKCGIn(xOekwDZqneumFQNMYGIhkmKsM5QPEb37Bdm6zF5qIhjakQx57fVO7fCVE61WeCzehKEb37PnL5Qjga6fdfz3AihkFvVEHI5GY1K4Tbg9ki4Gh0dbhFgc(qXuAUAcasoqXg)lucfREsRTre02qqX8PEAkdkEOWqkzMRM6fCVVnWON9LdjEKaOOELVx885Eb3RNEnmbxgXbPxW9EAtzUAIbGEXqr2TgYHYx1RxOyoOCnjEBGrVcco4b9qW5OHGpumLMRMaGKdumFQNMYGInmbxgXbbk24FHsO4aA4KafeP93HGEi44dGGpumLMRMaGKdumFQNMYGIDVHaJBIk5SlguSX)cLqXJDsj6QeHHYJak0dbNifc(qXuAUAcasoqX8PEAkdk2tVE619gcmIRlmfjuiTnSHCSkv9kFV4HFVss96EdbgX1fMIe6BAdBihRsvVY3lE43R3Eb3lhH0ai)jJBIk5SHCSkv9kFV4g)Eb3RNEDVHadBkh0auMwyd3YIlWUALnSttFPE9T3O9j87vsQxC6DUjfqdmIHnLdAaktlSHBzXfyxTYggfz3cdJa61BVE7vsQx3BiWWMYbnaLPf2WTS4cSRwzd700xQx5p0B0hn(9kj1lhH0ai)jJBIk5SHmaq7fCVE61u)yAbgYpn9kFVrk(9kj17PnL5QjwPegI61luSX)cLqXKdgYpncxuca9qWbp8HGpumLMRMaGKdumFQNMYGIXPxG5waSej4aQEb37PnL5QjghqWrjq9fk7fCVE61u)yAbgYpn9kFVrk(9cUxp96EdbgivcmeGGCWq(PXHYxqjnWQJqSlwVss9ItVC0jLw(mqaDkl71BVss9YrNuA5ZYcMSxemQxjPEpTPmxnXkLWquVss96EdbMRgHa0x1ZUy9cUx3BiWC1ieG(QE2qowLQE9T3OXV3i61tVE6ns79O6DUjfqdmIHnLdAaktlSHBzXfyxTYggfz3cdJa61BVr0RNE5Oe4wpdBiEPiHPlyPdLp7lhsCA6l1R3E92R3Eb3lo96Edbg3evYzxSEb3RNEXPxo6KslFwwWK9IGr9kj1lhH0ai)jJJYteiK4Lrcfwn1RyxSELK6TYNgmK2EcqekyYEXqowLQE9TxocPbq(tghLNiqiXlJekSAQxXgYXQu1Be96Z9kj1BLpnyiT9eGiuWK9IHCSkv96J9INpa)E9T3OXV3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61BVEHIn(xOekMtAs9LPfMUGLou(qpeCWdpi4dftP5Qjai5afZN6PPmOyC6fyUfalrcoGQxW9EAtzUAIXbeCucuFHYEb3RNEn1pMwGH8ttVY3BKIFVG71tVU3qGbsLadbiihmKFACO8fusdS6ie7I1RKuV40lhDsPLpdeqNYYE92RKuVC0jLw(SSGj7fbJ6vsQ3tBkZvtSsjme1RKuVU3qG5Qria9v9SlwVG719gcmxncbOVQNnKJvPQxF7f343Be96Pxp9gP9Eu9o3KcObgXWMYbnaLPf2WTS4cSRwzdJISBHHra96T3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61BVE71BVG7fNEDVHaJBIk5SlwVG71tV40lhDsPLpllyYErWOELK6LJqAaK)KXr5jces8YiHcRM6vSlwVss9w5tdgsBpbicfmzVyihRsvV(2lhH0ai)jJJYteiK4Lrcfwn1Ryd5yvQ6nIE95ELK6TYNgmK2EcqekyYEXqowLQE9XEXZhGFV(2lUXV3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61BVEHIn(xOekUsUnP9fkHEi4Gx0qWhkMsZvtaqYbkgHbfROhk24FHsO4tBkZvtqXNM(sqX40lhH0ai)jJBIk5SHmaq7vsQxC690MYC1eJJYteiKaGuGM8Eb3lhDsPLpllyYErWOELK6fyUfalrcoGck(0grAoeuSYojrancUjQKd9qWbpCdbFOyknxnbajhOy(upnLbftCDHPiwLclbTxW9AycUmIdsVG719gcmSPCqdqzAHnCllUa7Qv2Won9L613EJ2NWVxW96Pxa0Zmad7RtsO8BJJaWCmye7loivcRxjPEXPxo6KslFws8bPrdqVE7fCVN2uMRMyk7Keb0i4MOsouSX)cLqXH7aQafeK(Me0dbh88ji4dftP5Qjai5afZN6PPmOy3BiWqj9YucmA4e2xOKDX6fCVU3qGPEBcMwZgkmKsM5QjOyJ)fkHIvVnbtRHEi4Gh8GGpumLMRMaGKdumFQNMYGIDVHat92OrdaBihRsvV(2l86fCVE619gcmIRlmfjuiTnSHCSkv9kFVWRxjPEDVHaJ46ctrc9nTHnKJvPQx57fE96TxW9AQFmTad5NMELV3ifFOyJ)fkHI5wYjTW9gcqXU3qqKMdbfREB0Oba6HGdE(me8HIP0C1eaKCGI5t90ugu8BAkFM6jT2gbWuHNrP5QjGEb3RI(VsykMcPrcGPcFVG719gcm1BtW0AgaYFcfB8VqjuS6TjyAn0dbh8oAi4dftP5Qjai5afZN6PPmOyo6KslFwwWK9IGr9cU3tBkZvtmokprGqcasbAY7fCVCesdG8NmokprGqIxgjuy1uVInKJvPQxF7fE9cUxC6fyUfalrcoGck24FHsOy1BJ6oWiOhco45dGGpumLMRMaGKdumFQNMYGIFtt5ZupP12iaMk8mknxnb0l4EXP330u(m1BJgnamknxnb0l4EDVHat92emTMnuyiLmZvt9cUxp96EdbgX1fMIe6BAdBihRsvVY3Rp3l4EjUUWueRsH(M20l4EDVHadBkh0auMwyd3YIlWUALnSttFPE9T3OHh(9kj1R7neyyt5GgGY0cB4wwCb2vRSHDA6l1R8h6nA4HFVG71u)yAbgYpn9kFVrk(9kj1la6zgGH91jju(TXrayogmInKJvPQx571h0RKuVg)luYmad7RtsO8BJJaWCmyeRsrqxWK996TxW9ItVCesdG8NmUjQKZgYaafk24FHsOy1BtW0AOhco4fPqWhkMsZvtaqYbkMp1ttzqXU3qGHs6LPeCnzJ4SufkzxSELK619gcmqQeyiab5GH8tJdLVGsAGvhHyxSELK619gcmUjQKZUy9cUxp96Edb2yNuIUkryO8iGYgYXQu1RV9cJdWCm527r1lNkDVE61u)yAbgYpn9c3EXn(96TxW96Edb2yNuIUkryO8iGYUy9kj1lo96Edb2yNuIUkryO8iGYUy9cUxC6LJqAaK)Kn2jLORsegkpcOSHmaq7vsQxC6LJoP0YNDs5ld0PxV9kj1RP(X0cmKFA6v(EJu87fCVexxykIvPWsqHIn(xOekw92OUdmc6HGt04dbFOyknxnbajhOy(upnLbf)MMYNPEB0ObGrP5QjGEb3RNEDVHat92Orda7I1RKuVM6htlWq(PPx57nsXVxV9cUx3BiWuVnA0aWuVXbPxF7f39cUxp96EdbgX1fMIekK2g2fRxjPEDVHaJ46ctrc9nTHDX61BVG719gcmSPCqdqzAHnCllUa7Qv2Won9L613EJ(OXVxW96PxocPbq(tg3evYzd5yvQ6v(EXd)ELK6fNEpTPmxnX4O8ebcjaifOjVxW9YrNuA5ZYcMSxemQxVqXg)lucfREBu3bgb9qWjA8GGpumLMRMaGKdumFQNMYGI90R7neyyt5GgGY0cB4wwCb2vRSHDA6l1RV9g9rJFVss96Edbg2uoObOmTWgULfxGD1kByNM(s96BVrdp87fCVVPP8zQN0ABeatfEgLMRMa61BVG719gcmIRlmfjuiTnSHCSkv9kFVhDVG7L46ctrSkfkK2MEb3lo96EdbgkPxMsGrdNW(cLSlwVG7fNEFtt5ZuVnA0aWO0C1eqVG7LJqAaK)KXnrLC2qowLQELV3JUxW96PxocPbq(tg5GH8tJWfLaSHCSkv9kFVhDVss9ItVC0jLw(mqaDkl71luSX)cLqXQ3g1DGrqpeCIoAi4dftP5Qjai5afZN6PPmOyp96EdbgX1fMIe6BAd7I1RKuVE6LlZgyKQ3d9gDVG7DiUmBGrIVCOE9Tx41R3ELK6LlZgyKQ3d9I7E92l4EnmbxgXbPxW9EAtzUAIPStseqJGBIk5qXg)lucfNKFHdcLqpeCIg3qWhkMsZvtaqYbkMp1ttzqXE619gcmIRlmfj030g2fRxW9ItVC0jLw(mqaDkl7vsQxp96EdbgivcmeGGCWq(PXHYxqjnWQJqSlwVG7LJoP0YNbcOtzzVE7vsQxp9YLzdms17HEJUxW9oexMnWiXxouV(2l861BVss9YLzdms17HEXDVss96Edbg3evYzxSE92l4EnmbxgXbPxW9EAtzUAIPStseqJGBIk5qXg)lucflZ0bHdcLqpeCI2NGGpumLMRMaGKdumFQNMYGI90R7neyexxyksOVPnSlwVG7fNE5OtkT8zGa6uw2RKuVE619gcmqQeyiab5GH8tJdLVGsAGvhHyxSEb3lhDsPLpdeqNYYE92RKuVE6LlZgyKQ3d9gDVG7DiUmBGrIVCOE9Tx41R3ELK6LlZgyKQ3d9I7ELK619gcmUjQKZUy96TxW9AycUmIdsVG790MYC1etzNKiGgb3evYHIn(xOekoC1AHdcLqpeCIgEqWhk24FHsOy)2mfAeOGG03KGIP0C1eaKCGEi4eTpdbFOyknxnbajhOy(upnLbftCDHPiwLc9nTPxjPEjUUWuetH02issUFVss9sCDHPiMLGkssUFVss96EdbMFBMcncuqq6BsSlwVG719gcmIRlmfj030g2fRxjPE90R7neyCtujNnKJvPQxF714FHsM)XEzmsUe)(K4lhQxW96Edbg3evYzxSE9cfB8VqjuS6Tjudb9qWj6Jgc(qXg)lucf7FSxgumLMRMaGKd0dbNO9bqWhkMsZvtaqYbk24FHsO45McJ)fkf6s9qX6s9I0CiO4GP1VS5c9qpumWqMJBLa0abFi4Ghe8HIP0C1eaKCGIryqXk6HIn(xOek(0MYC1eu8PPVeuSNEDVHa7lhYpAsbWqMJBLa0WgYXQu1R89cJdWCm52Be9IpdVEb3RNEjUUWueRsHl6L1RKuVexxykIvPqH020RKuVexxykIPVPnIKK73R3ELK619gcSVCi)OjfadzoUvcqdBihRsvVY3RX)cLm1BtOgIrYL43NeF5q9grV4ZWRxW96PxIRlmfXQuOVPn9kj1lX1fMIykK2grsY97vsQxIRlmfXSeursY971BVE7vsQxC619gcSVCi)OjfadzoUvcqd7IbfFAJinhckwzbs8iXvrcfgP1qpeCIgc(qXuAUAcasoqX8PEAkdk2tV407PnL5QjMYcK4rIRIekmsR7vsQxp96Edb2yNuIUkryO8iGYgYXQu1RV9cJdWCm527r1lNkDVE61u)yAbgYpn9c3EXn(96TxW96Edb2yNuIUkryO8iGYUy96TxV9kj1RP(X0cmKFA6v(EJu8HIn(xOekw92OUdmc6HGdUHGpumLMRMaGKdumFQNMYGIXPxG5waSej4aQEb3RNE907PnL5QjghLNiqibaPan59cU3kFAWqA7jarOGj7fd5yvQ6v(EXd343l4EXPxocPbq(tg3evYzdzaG2RKuVU3qGXnrLC2fRxV9cUxt9JPfyi)00RV96t43l4E90R7neyexxyksOVPnSHCSkv9kFV4HFVss96EdbgX1fMIekK2g2qowLQELVx8WVxV9kj1BOGj7fd5yvQ613EXd)E9cfB8VqjumhLNiqiXlJekSAQxb9qWXNGGpumLMRMaGKduSX)cLqXgGH91jju(TXbkMp1ttzqX40la6zgGH91jju(TXrayogmI9fhKkH1l4EXPxJ)fkzgGH91jju(TXrayogmIvPiOlyY(Eb3RNEXPxa0Zmad7RtsO8BJJqgzA2xCqQewVss9cGEMbyyFDscLFBCeYitZgYXQu1R89cVE92RKuVaONzag2xNKq53ghbG5yWiM6noi96BV4UxW9cGEMbyyFDscLFBCeaMJbJyd5yvQ613EXDVG7fa9mdWW(6Kek)24iamhdgX(IdsLWGI5GY1K4Tbg9ki4Gh0dbh4bbFOyknxnbajhOyJ)fkHIDqOmudbfZN6PPmO4HcdPKzUAQxW9(2aJE2xoK4rcGI6v(EXl6Eb3RNE90R7neyCtujNnKJvPQx57fE9cUxp96Edb2yNuIUkryO8iGYgYXQu1R89cVELK6fNEDVHaBStkrxLimuEeqzxSE92RKuV40R7neyCtujNDX6vsQxt9JPfyi)00RV9IB871BVG71tV40R7neyGujWqacYbd5NghkFbL0aRocXUy9kj1RP(X0cmKFA613EXn(96TxW9AycUmIdsVEHI5GY1K4Tbg9ki4Gh0dbhFgc(qXuAUAcasoqXg)lucfRUzOgckMp1ttzqXdfgsjZC1uVG79Tbg9SVCiXJeaf1R89Ix09cUxp96Px3BiW4MOsoBihRsvVY3l86fCVE619gcSXoPeDvIWq5raLnKJvPQx57fE9kj1lo96Edb2yNuIUkryO8iGYUy96TxjPEXPx3BiW4MOso7I1RKuVM6htlWq(PPxF7f343R3Eb3RNEXPx3BiWaPsGHaeKdgYpnou(ckPbwDeIDX6vsQxt9JPfyi)00RV9IB871BVG71WeCzehKE9cfZbLRjXBdm6vqWbpOhcohne8HIP0C1eaKCGIn(xOekw9KwBJiOTHGI5t90ugu8qHHuYmxn1l4EFBGrp7lhs8ibqr9kFV45Z9cUxp96Px3BiW4MOsoBihRsvVY3l86fCVE619gcSXoPeDvIWq5raLnKJvPQx57fE9kj1lo96Edb2yNuIUkryO8iGYUy96TxjPEXPx3BiW4MOso7I1RKuVM6htlWq(PPxF7f343R3Eb3RNEXPx3BiWaPsGHaeKdgYpnou(ckPbwDeIDX6vsQxt9JPfyi)00RV9IB871BVG71WeCzehKE9cfZbLRjXBdm6vqWbpOhco(ai4dftP5Qjai5afZN6PPmOydtWLrCqGIn(xOekoGgojqbrA)DiOhcorke8HIP0C1eaKCGI5t90uguS7neyCtujNDXGIn(xOekEStkrxLimuEeqHEi4Gh(qWhkMsZvtaqYbkMp1ttzqXE61tVU3qGrCDHPiHcPTHnKJvPQx57fp87vsQx3BiWiUUWuKqFtByd5yvQ6v(EXd)E92l4E5iKga5pzCtujNnKJvPQx57f343R3ELK6LJqAaK)KXnrLC2qgaOqXg)lucftoyi)0iCrja0dbh8Wdc(qXuAUAcasoqX8PEAkdkgNEbMBbWsKGdO6fCVN2uMRMyCabhLa1xOSxW96Pxp96EdbgivcmeGGCWq(PXHYxqjnWQJqSlwVss9ItVC0jLw(mqaDkl71BVss9YrNuA5ZYcMSxemQxjPEpTPmxnXkLWquVss96EdbMRgHa0x1ZUy9cUx3BiWC1ieG(QE2qowLQE9T3OXV3i61tVCucCRNHneVuKW0fS0HYN9Ldjon9L61BVE7fCV40R7neyCtujNDX6fCVE6fNE5OtkT8zzbt2lcg1RKuVCesdG8NmokprGqIxgjuy1uVIDX6vsQ3kFAWqA7jarOGj7fd5yvQ613E5iKga5pzCuEIaHeVmsOWQPEfBihRsvVr0Rp3RKuVv(0GH02taIqbt2lgYXQu1Rp2lE(a8713EJg)EJOxp9YrjWTEg2q8srctxWshkF2xoK400xQxV96fk24FHsOyoPj1xMwy6cw6q5d9qWbVOHGpumLMRMaGKdumFQNMYGIXPxG5waSej4aQEb37PnL5QjghqWrjq9fk7fCVE61tVU3qGbsLadbiihmKFACO8fusdS6ie7I1RKuV40lhDsPLpdeqNYYE92RKuVC0jLw(SSGj7fbJ6vsQ3tBkZvtSsjme1RKuVU3qG5Qria9v9SlwVG719gcmxncbOVQNnKJvPQxF7f343Be96PxokbU1ZWgIxksy6cw6q5Z(YHeNM(s96TxV9cUxC619gcmUjQKZUy9cUxp9ItVC0jLw(SSGj7fbJ6vsQxocPbq(tghLNiqiXlJekSAQxXUy9kj1BLpnyiT9eGiuWK9IHCSkv96BVCesdG8NmokprGqIxgjuy1uVInKJvPQ3i61N7vsQ3kFAWqA7jarOGj7fd5yvQ61h7fpFa(96BV4g)EJOxp9YrjWTEg2q8srctxWshkF2xoK400xQxV96fk24FHsO4k52K2xOe6HGdE4gc(qXuAUAcasoqXimOyf9qXg)lucfFAtzUAck(00xckgNE5iKga5pzCtujNnKbaAVss9ItVN2uMRMyCuEIaHeaKc0K3l4E5OtkT8zzbt2lcg1RKuVaZTayjsWbuqXN2isZHGIv2jjcOrWnrLCOhco45tqWhkMsZvtaqYbkMp1ttzqXexxykIvPWsq7fCVgMGlJ4G0l4E90la6zgGH91jju(TXrayogmI9fhKkH1RKuV40lhDsPLplj(G0ObOxV9cU3tBkZvtmLDsIaAeCtujhk24FHsO4WDavGccsFtc6HGdEWdc(qXuAUAcasoqX8PEAkdkMJoP0YNLfmzViyuVG790MYC1eJJYteiKaGuGM8Eb3RP(X0cmKFA6v(d96t43l4E5iKga5pzCuEIaHeVmsOWQPEfBihRsvV(2lmoaZXKBVhvVCQ096Pxt9JPfyi)00lC7f343R3Eb3lo9cm3cGLibhqbfB8VqjuS6TrDhye0dbh88zi4dftP5Qjai5afZN6PPmOyp96EdbgX1fMIe6BAd7I1RKuVE6LlZgyKQ3d9gDVG7DiUmBGrIVCOE9Tx41R3ELK6LlZgyKQ3d9I7E92l4EnmbxgXbPxW9EAtzUAIPStseqJGBIk5qXg)lucfNKFHdcLqpeCW7OHGpumLMRMaGKdumFQNMYGI90R7neyexxyksOVPnSlwVG7fNE5OtkT8zGa6uw2RKuVE619gcmqQeyiab5GH8tJdLVGsAGvhHyxSEb3lhDsPLpdeqNYYE92RKuVE6LlZgyKQ3d9gDVG7DiUmBGrIVCOE9Tx41R3ELK6LlZgyKQ3d9I7ELK619gcmUjQKZUy96TxW9AycUmIdsVG790MYC1etzNKiGgb3evYHIn(xOekwMPdchekHEi4GNpac(qXuAUAcasoqX8PEAkdk2tVU3qGrCDHPiH(M2WUy9cUxC6LJoP0YNbcOtzzVss96Px3BiWaPsGHaeKdgYpnou(ckPbwDeIDX6fCVC0jLw(mqaDkl71BVss96PxUmBGrQEp0B09cU3H4YSbgj(YH613EHxVE7vsQxUmBGrQEp0lU7vsQx3BiW4MOso7I1R3Eb3RHj4Yioi9cU3tBkZvtmLDsIaAeCtujhk24FHsO4WvRfoiuc9qWbVifc(qXg)lucf73MPqJafeK(MeumLMRMaGKd0dbNOXhc(qXuAUAcasoqX8PEAkdkM46ctrSkf6BAtVss9sCDHPiMcPTrKKC)ELK6L46ctrmlbvKKC)ELK619gcm)2mfAeOGG03KyxSEb3R7neyexxyksOVPnSlwVss96Px3BiW4MOsoBihRsvV(2RX)cLm)J9YyKCj(9jXxouVG719gcmUjQKZUy96fk24FHsOy1BtOgc6HGt04bbFOyJ)fkHI9p2ldkMsZvtaqYb6HGt0rdbFOyknxnbajhOyJ)fkHINBkm(xOuOl1dfRl1lsZHGIdMw)YMl0d9qpu8jnQcLqWjA8JgF8IoA4bf73MSsykOyFi(W4QGJpu4ejls0BVWxg1B5GHMV3aA6fxdmK54wjan46EhkYU1qa9QqouV29ro2ta9YLzjmsX6OWfvs9gDKO3ihLN08eqVXLtK3Rc08n52Rp27J6fxCTEbQZsvOSxegn2JME9axV96bp56L1rHlQK6fp8Ie9g5O8KMNa6nUCI8EvGMVj3E9rFS3h1lU4A96GaU6RQxegn2JME94JE71dEY1lRJcxuj1lErhj6nYr5jnpb0BC5e59QanFtU96J(yVpQxCX161bbC1xvVimAShn96Xh92Rh8KRxwhfUOsQx8GxKO3ihLN08eqVXLtK3Rc08n52Rp27J6fxCTEbQZsvOSxegn2JME9axV96bp56L1r1r5dXhgxfC8HcNizrIE7f(YOElhm089gqtV4Aakyx9JR7DOi7wdb0Rc5q9A3h5ypb0lxMLWifRJcxuj1Rphj6nYr5jnpb0BC5e59QanFtU96J9(OEXfxRxG6Sufk7fHrJ9OPxpW1BVEIwUEzDu4IkPEXdVirVrokpP5jGEX1ZnPaAGrmC146EFuV465MuanWigUAgLMRMaW196jA56L1r1r5dXhgxfC8HcNizrIE7f(YOElhm089gqtV4ASH4ihx7X19ouKDRHa6vHCOET7JCSNa6LlZsyKI1rHlQK6fErIEJCuEsZta9IRNBsb0aJy4QX19(OEX1ZnPaAGrmC1mknxnbGR71dEY1lRJcxuj1Rphj6nYr5jnpb0lUEUjfqdmIHRgx37J6fxp3KcObgXWvZO0C1eaUUxp4jxVSoQokFi(W4QGJpu4ejls0BVWxg1B5GHMV3aA6fxBicx37qr2TgcOxfYH61UpYXEcOxUmlHrkwhfUOsQxChj6nYr5jnpb0lUEUjfqdmIHRgx37J6fxp3KcObgXWvZO0C1eaUUxp4jxVSokCrLuVWls0BKJYtAEcO34YjY7vbA(MC71h9XEFuV4IR1Rdc4QVQEry0ypA61Jp6Txp4jxVSokCrLuVhDKO3ihLN08eqVXLtK3Rc08n52Rp27J6fxCTEbQZsvOSxegn2JME9axV96bp56L1rHlQK6fp8Je9g5O8KMNa6nUCI8EvGMVj3E9XEFuV4IR1lqDwQcL9IWOXE00Rh46Txp4jxVSokCrLuV45trIEJCuEsZta9gxorEVkqZ3KBV(Op27J6fxCTEDqax9v1lcJg7rtVE8rV96bp56L1rHlQK6fVins0BKJYtAEcO34YjY7vbA(MC71h79r9IlUwVa1zPku2lcJg7rtVEGR3E9GNC9Y6OWfvs9gnErIEJCuEsZta9gxorEVkqZ3KBV(yVpQxCX16fOolvHYEry0ypA61dC92Rh8KRxwhfUOsQ3O95irVrokpP5jGEJlNiVxfO5BYTxFS3h1lU4A9cuNLQqzVimAShn96bUE71t0Y1lRJQJYhIpmUk44dforYIe92l8Lr9woyO57nGMEX1Qhx37qr2TgcOxfYH61UpYXEcOxUmlHrkwhfUOsQx8Wps0BKJYtAEcO34YjY7vbA(MC71h9XEFuV4IR1Rdc4QVQEry0ypA61Jp6Txp4jxVSokCrLuV4HxKO3ihLN08eqVXLtK3Rc08n52Rp6J9(OEXfxRxheWvFv9IWOXE00RhF0BVEWtUEzDu4IkPEXlsJe9g5O8KMNa6nUCI8EvGMVj3E9XEFuV4IR1lqDwQcL9IWOXE00Rh46Txp4jxVSoQokFi(W4QGJpu4ejls0BVWxg1B5GHMV3aA6fx7IShx37qr2TgcOxfYH61UpYXEcOxUmlHrkwhfUOsQx8o6irVrokpP5jGEJlNiVxfO5BYTxFS3h1lU4A9cuNLQqzVimAShn96bUE71dULRxwhfUOsQx88brIEJCuEsZta9gxorEVkqZ3KBV(yVpQxCX16fOolvHYEry0ypA61dC92Rh8KRxwhvhLpuhm08eqVhDVg)lu2RUuVI1rbfJnOqPjOyCLELJPTKt9gjXClGokCLEJKG4KJln9g9rFCVrJF043r1rHR0BKlZsyKks0rHR0lUSxFyaacO3yK2MELdzoSokCLEXL9g5YSegb07Bdm6fvOxUPivVpQxoOCnjEBGrVI1rHR0lUSxCvKd6Ka69MjXjLYgq790MYC1KQxpfJyh3l2qNc1BJ6oWOEXLY3l2qNm1BJ6oWiVSokCLEXL96dFIkGEXgIBQVsy96dzSxwVvO36X1QEFzuV(hucR3ij56ctrSokCLEXL9gjNbc1BKJYteiuVVmQ3ySAQx1R1RU(xt96GgQ3GMKB5QPE9uHEbfD7vMbK46Vxz13B99QkNR(TKqxLg0E9xVSELtK8(WWV3i6nYjnP(Y096dRlyPdL)X9wpUgOxfifMxwhvhLX)cLkg2qCKJR9haPsGHaekSAQx1rz8VqPIHneh54AFehGRdcLGuPiGgNokJ)fkvmSH4ihx7J4aC9p2l7yDLKGdCap8pUch8qCDHPiM(M2issUVKeX1fMIyvk030gjjIRlmfXQu4IEzssexxykIzjOIKK77TJY4FHsfdBioYX1(ioax)J9YoUch8qCDHPiM(M2issUVKeX1fMIyvk030gjjIRlmfXQu4IEzssexxykIzjOIKK77fm2qNm8y(h7LbghSHozrZ8p2lRJY4FHsfdBioYX1(ioax1BtOg64kCaN5MuanWiMRPTKtcuqyAT4LvjmLKeoC0jLw(SSGj7fbJKKWrHrAT4Tbg9kM6TjyA9b8KKW5nnLplT)oKs4AAl5eJsZvtaDug)luQyydXroU2hXb4QEBu3bgDCfom3KcObgXCnTLCsGcctRfVSkHPaZrNuA5ZYcMSxemcScJ0AXBdm6vm1BtW06d41r1rHR0BKKYL43Na6LoPb0E)YH69Lr9A8hn9wQETtR0MRMyDug)luQoOqABeUK50rz8VqP6WPnL5QPJtZHoukHHOJpn9LoOWiTw82aJEft92emTwE8a7bN30u(m1BJgnamknxnbij9MMYNPEsRTramv4zuAUAcWRKKcJ0AXBdm6vm1BtW0A5JUJY4FHsvehG7PnL5QPJtZHoukbxt2jD8PPV0bfgP1I3gy0RyQ3MqnK841rz8VqPkIdW1LgfnGujSJRWbp4WrNuA5ZYcMSxemsschocPbq(tghLNiqiXlJekSAQxXUyEb7Edbg3evYzxSokJ)fkvrCaUyOVq5Xv4G7neyCtujNDX6Om(xOufXb4EAtzUA640COdCuEIaHeaKc0KF8PPV0HGgHgpEQ8PbdPTNaeHcMSxmKJvPcxgn(4socPbq(tghLNiqiXlJekSAQxXgYXQu51hXlA89kFqJqJhpv(0GH02taIqbt2lgYXQuHlJgE4sp4H)r9MMYNvj3M0(cLmknxnb4fx6HJsGB9mSH4LIeMUGLou(SVCiXPPVKxCjhH0ai)jJBIk5SHCSkvE9r88b47vsIJqAaK)KXnrLC2qowLk5R8PbdPTNaeHcMSxmKJvPssIJqAaK)KXr5jces8YiHcRM6vSHCSkvYx5tdgsBpbicfmzVyihRsLKeoC0jLw(SSGj7fbJ6Om(xOufXb4EAtzUA640COdCabhLa1xO84ttFPdEWHISBHHramYbd0HmTanaPLCssIJqAaK)KroyGoKPfObiTKtSHCSkv(INpJpyC4iKga5pzKdgOdzAbAasl5eBidauVssC0jLw(mqaDkl7Om(xOufXb4EvKOEY540COdKdgOdzAbAasl50Xv4ahH0ai)jJBIk5SHCSkv(gn(GpTPmxnX4O8ebcjaifOjxsIJqAaK)KXr5jces8YiHcRM6vSHCSkv(gn(Dug)luQI4aCVksup5CCAo0bf6Q10)vctmxxqpUch4iKga5pzCtujNnKJvPYxFg8PnL5QjghLNiqibaPan5ssCesdG8NmokprGqIxgjuy1uVInKJvPYxFUJY4FHsvehG7vrI6jNJtZHouPIp33C1KiYUw(xhbaDwC64kCW9gcmUjQKZUyDu4k9A8VqPkIdW9Qir9KJ6yLg9Qd)uji0J3Xv4ao)uji0ZWJjZucSbXzwckyp48tLGqplAMmtjWgeNzjOss48tLGqplA2qgaOcocPbq(tVssU3qGXnrLC2ftsIJqAaK)KXnrLC2qowLkCjE4l)pvcc9m8yCesdG8NmG7yFHsW4WrNuA5Zab0PSusIJoP0YNLfmzViye4tBkZvtmokprGqcasbAYbZrinaYFY4O8ebcjEzKqHvt9k2ftsY9gcmqQeyiab5GH8tJdLVGsAGvhHyxmjPqbt2lgYXQu5B043rHR0RX)cLQioa3RIe1toQJvA0Ro8tLGqF0hxHd48tLGqplAMmtjWgeNzjOG9GZpvcc9m8yYmLaBqCMLGkjHZpvcc9m8ydzaGk4iKga5p9kj9tLGqpdpMmtjWgeNzjOG)PsqONfntMPeydIZSeuW48tLGqpdp2qgaOcocPbq(tjj3BiW4MOso7IjjXrinaYFY4MOsoBihRsfUep8L)NkbHEw0mocPbq(tgWDSVqjyC4OtkT8zGa6uwkjXrNuA5ZYcMSxemc8PnL5QjghLNiqibaPan5G5iKga5pzCuEIaHeVmsOWQPEf7Ijj5EdbgivcmeGGCWq(PXHYxqjnWQJqSlMKuOGj7fd5yvQ8nA87Om(xOufXb4EvKOEYrDCfo4Edbg3evYzxmjjo6KslFwwWK9IGrGpTPmxnX4O8ebcjaifOjhmhH0ai)jJJYteiK4Lrcfwn1RyxmW4WrinaYFY4MOso7Ib2Jh3BiWiUUWuKqFtByd5yvQKhp8LKCVHaJ46ctrcfsBdBihRsL84HVxW4m3KcObgXCnTLCsGcctRfVSkHPKKMBsb0aJyUM2sojqbHP1IxwLWuG94EdbMRPTKtcuqyAT4LvjmLiT)oet9ghe5XTKK7neyUM2sojqbHP1IxwLWucB4wsm1BCqKh3E9kj5EdbgivcmeGGCWq(PXHYxqjnWQJqSlMKuOGj7fd5yvQ8nA87Om(xOufXb4o3uy8VqPqxQ)40COdgIow9tX)d4DCfoCAtzUAIvkHHOokJ)fkvrCaUZnfg)luk0L6ponh6aWqMJBLa0CS6NI)hW74kCyUjfqdmI9Ld5hnPayiZXTsaAyuKDlmmcOJY4FHsvehG7CtHX)cLcDP(JtZHo4IS)y1pf)pG3Xv4WCtkGgyeZ10wYjbkimTw8YQeMIrr2TWWiGokJ)fkvrCaUZnfg)luk0L6ponh6G67O6Om(xOuXmeD40MYC10XP5qhagYCe(lTwemTwGcHJpn9Lo4X9gcSVCi)OjfadzoUvcqdBihRsLVW4amhtUrGpdpjj3BiW(YH8JMuamK54wjanSHCSkv(A8Vqjt92eQHyKCj(9jXxoue4ZWdShIRlmfXQuOVPnssexxykIPqABejj3xsI46ctrmlbvKKCFVEb7Edb2xoKF0KcGHmh3kbOHDXap3KcObgX(YH8JMuamK54wjanmkYUfggb0rz8VqPIzikIdW90MYC10XP5qhkyjAiH6TrDhy0XNM(shCVHaJ46ctrc9nTHDXa7rHrAT4Tbg9kM6TjudjVpb(nnLptHUAbkiEzKiGgs9mknxnbijPWiTw82aJEft92eQHK3N92rz8VqPIzikIdWLJYteiK4Lrcfwn1RoUchWbyUfalrcoGcShpN2uMRMyCuEIaHeaKc0KdghocPbq(tg3evYzdzaGkj5Edbg3evYzxmVG9yQFmTad5NgFHh(ssN2uMRMyfSenKq92OUdmYlypU3qGrCDHPiH(M2WgYXQujVplj5EdbgX1fMIekK2g2qowLk59zVG9GZCtkGgyeZ10wYjbkimTw8YQeMssY9gcmxtBjNeOGW0AXlRsykrA)DiM6noiYJBjj3BiWCnTLCsGcctRfVSkHPe2WTKyQ34GipU9kjfkyYEXqowLkFXdFVDug)luQygII4aCv3mudDmhuUMeVnWOxDaVJRWHHcdPKzUAc8Bdm6zF5qIhjaksE88jCPcJ0AXBdm6vrmKJvPcShIRlmfXQuyjOssd5yvQ8fghG5yY1BhLX)cLkMHOioax1BtW06JRWb3BiWuVnbtRzdfgsjZC1eypkmsRfVnWOxXuVnbtR9f3ss4m3KcObgX(YH8JMuamK54wjanmkYUfggb4fShCMBsb0aJyAq52ykrqt0xjmbmD5GPigfz3cdJaKK(YH8rF0NGN8U3qGPEBcMwZgYXQufr0EbhkyYEXqowLk5HxhLX)cLkMHOioax1BtW06JRWH5MuanWi2xoKF0KcGHmh3kbOHrr2TWWiaWkmsRfVnWOxXuVnbtRL)aUb7bh3BiW(YH8JMuamK54wjanSlgy3BiWuVnbtRzdfgsjZC1KKKNtBkZvtmGHmhH)sRfbtRfOqaSh3BiWuVnbtRzd5yvQ8f3sskmsRfVnWOxXuVnbtRLpAWVPP8zQN0ABeatfEgLMRMaa7EdbM6TjyAnBihRsLVWZRxVDug)luQygII4aCpTPmxnDCAo0b1BtW0AHFu(IGP1cuiC8PPV0bt9JPfyi)0iVpaFCPh8W)OCVHa7lhYpAsbWqMJBLa0WuVXbXlU0J7neyQ3MGP1SHCSkvhfU9rfgP1czM6jV4spaONfUdOcuqq6BsSHCSkvhf88c29gcm1BtW0A2fRJY4FHsfZquehGR6TrDhy0Xv4WPnL5QjgWqMJWFP1IGP1cuia(0MYC1et92emTw4hLViyATafcGX50MYC1eRGLOHeQ3g1DGrssECVHaZ10wYjbkimTw8YQeMsK2FhIPEJdI84wsY9gcmxtBjNeOGW0AXlRsykHnCljM6noiYJBVGvyKwlEBGrVIPEBcMw7Rp1rz8VqPIzikIdW1amSVojHYVnohZbLRjXBdm6vhW74kCaNV4GujmW4y8VqjZamSVojHYVnocaZXGrSkfbDbt2ljbGEMbyyFDscLFBCeaMJbJyQ34G4lUbdGEMbyyFDscLFBCeaMJbJyd5yvQ8f3Dug)luQygII4aCDqOmudDmhuUMeVnWOxDaVJRWHHcdPKzUAc8Bdm6zF5qIhjaksEp45tr4rHrAT4Tbg9kM6TjudDu4XGNxV(OcJ0AXBdm6vrmKJvPcShpCesdG8NmUjQKZgYaafmoaZTayjsWbuG9CAtzUAIXr5jcesaqkqtUKehH0ai)jJJYteiK4Lrcfwn1RydzaGkjHdhDsPLpllyYErWiVsskmsRfVnWOxXuVnHAiF9aVJYdEr8MMYN9(Ru4GqPIrP5QjaVELK8qCDHPiwLcfsBJKKhIRlmfXQu4IEzssexxykIvPqFtB8cgN30u(mf6QfOG4LrIaAi1ZO0C1eGKK7neyyt5GgGY0cB4wwCb2vRSHDA6lj)HOHh(Eb7rHrAT4Tbg9kM6Tjud5lE4FuEWlI30u(S3FLchekvmknxnb41lyt9JPfyi)0ip8Whx6EdbM6TjyAnBihRs1r5ZEb7bh3BiWaPsGHaeKdgYpnou(ckPbwDeIDXKKiUUWueRsHcPTrscho6KslFgiGoLLEbBycUmIdI3okJ)fkvmdrrCaUb0Wjbkis7VdDCfoyycUmIdshLX)cLkMHOioa3XoPeDvIWq5ra94kCW9gcmUjQKZUyDug)luQygII4aC5KMuFzAHPlyPdL)Xv4aoaZTayjsWbuGpTPmxnX4acokbQVqjypU3qGPEBcMwZUyssM6htlWq(PrE4HVxW44EdbMcPvFXj2fdmoU3qGXnrLC2fdShC4OtkT8zzbt2lcgjjDAtzUAIXr5jcesaqkqtUKehH0ai)jJJYteiK4Lrcfwn1RyxmjPkFAWqA7jarOGj7fd5yvQ8nA8JWdhLa36zydXlfjmDblDO8zF5qIttFjVE7Om(xOuXmefXb4wj3M0(cLhxHd4am3cGLibhqb(0MYC1eJdi4OeO(cLG94EdbM6TjyAn7IjjzQFmTad5Ng5Hh(EbJJ7neykKw9fNyxmW44Edbg3evYzxmWEWHJoP0YNLfmzViyKK0PnL5QjghLNiqibaPan5ssCesdG8NmokprGqIxgjuy1uVIDXKKQ8PbdPTNaeHcMSxmKJvPYxocPbq(tghLNiqiXlJekSAQxXgYXQufHpljv5tdgsBpbicfmzVyihRsLp6J45dW3xCJFeE4Oe4wpdBiEPiHPlyPdLp7lhsCA6l51BhLX)cLkMHOioaxYbd5NgHlkboUchQ8PbdPTNaeHcMSxmKJvPYx8GNKKh3BiWWMYbnaLPf2WTS4cSRwzd700xY3OHh(ssU3qGHnLdAaktlSHBzXfyxTYg2PPVK8hIgE47fS7neyQ3MGP1SlgypCesdG8NmUjQKZgYXQujp8WxscyUfalrcoGYBhLX)cLkMHOioax1tATnIG2g6yoOCnjEBGrV6aEhxHddfgsjZC1e4VCiXJeafjpEWdScJ0AXBdm6vm1BtOgYxFcSHj4YioiG94Edbg3evYzd5yvQKhp8LKWX9gcmUjQKZUyE7Om(xOuXmefXb4gUdOcuqq6BshxHdexxykIvPWsqbBycUmIdcy3BiWWMYbnaLPf2WTS4cSRwzd700xY3OHh(G9aGEMbyyFDscLFBCeaMJbJyFXbPsyss4WrNuA5ZsIpinAaKKuyKwlEBGrVs(O92rz8VqPIzikIdWv92emT(4kCW9gcmusVmLaJgoH9fkzxmWECVHat92emTMnuyiLmZvtssM6htlWq(Pr(ifFVDug)luQygII4aCvVnbtRpUch4OtkT8zzbt2lcgb2ZPnL5QjghLNiqibaPan5ssCesdG8NmUjQKZUyssU3qGXnrLC2fZlyocPbq(tghLNiqiXlJekSAQxXgYXQu5lmoaZXK7rXPs7Xu)yAbgYpn(i8W3ly3BiWuVnbtRzd5yvQ81NaJdWClawIeCavhLX)cLkMHOioax1BJ6oWOJRWbo6KslFwwWK9IGrG9CAtzUAIXr5jcesaqkqtUKehH0ai)jJBIk5SlMKK7neyCtujNDX8cMJqAaK)KXr5jces8YiHcRM6vSHCSkv(6ZGDVHat92emTMDXatCDHPiwLclbfmoN2uMRMyfSenKq92OUdmcmoaZTayjsWbuDug)luQygII4aCvVnQ7aJoUchCVHadL0ltj4AYgXzPkuYUyssEWr92eQHygMGlJ4Gij5X9gcmUjQKZgYXQu5l8a7Edbg3evYzxmjjpU3qGn2jLORsegkpcOSHCSkv(cJdWCm5EuCQ0Em1pMwGH8tJpIB89c29gcSXoPeDvIWq5raLDX86f8PnL5QjM6TjyATWpkFrW0AbkeaRWiTw82aJEft92emT2xC7fShCMBsb0aJyF5q(rtkagYCCReGggfz3cdJaKKuyKwlEBGrVIPEBcMw7lU92rz8VqPIzikIdWnj)chekpUch8qCDHPiwLclbfmhH0ai)jJBIk5SHCSkvYdp8LK8WLzdmsDiAWdXLzdms8Ld5l88kjXLzdmsDa3EbBycUmIdshLX)cLkMHOioaxzMoiCqO84kCWdX1fMIyvkSeuWCesdG8NmUjQKZgYXQujp8WxsYdxMnWi1HObpexMnWiXxoKVWZRKexMnWi1bC7fSHj4YioiDug)luQygII4aCdxTw4Gq5Xv4GhIRlmfXQuyjOG5iKga5pzCtujNnKJvPsE4HVKKhUmBGrQdrdEiUmBGrIVCiFHNxjjUmBGrQd42lydtWLrCq6Om(xOuXmefXb463MPqJafeK(MuhLX)cLkMHOioa3tBkZvthNMdDq92eQHevkuiTnhFA6lDqHrAT4Tbg9kM6TjudjVpfrqJqJhht90aQ400x6OWdF89XOX3BebncnECVHat92OUdmsqoyi)04q5luiTnm1BCq8rFYBhLX)cLkMHOioax)J9YoUchiUUWuetFtBejj3xsI46ctrmlbvKKCFWN2uMRMyLsW1KDsssU3qGrCDHPiHcPTHnKJvPYxJ)fkzQ3MqneJKlXVpj(YHa7EdbgX1fMIekK2g2ftsI46ctrSkfkK2gW4CAtzUAIPEBc1qIkfkK2gjj3BiW4MOsoBihRsLVg)luYuVnHAigjxIFFs8LdbgNtBkZvtSsj4AYojWU3qGXnrLC2qowLkFj5s87tIVCiWU3qGXnrLC2ftsY9gcSXoPeDvIWq5raLDXaRWiTwiZupjp(mFgShfgP1I3gy0R89aULKW5nnLptHUAbkiEzKiGgs9mknxnb4vscNtBkZvtSsj4AYojWU3qGXnrLC2qowLk5j5s87tIVCOokJ)fkvmdrrCaUQ3MqnuhLX)cLkMHOioa35McJ)fkf6s9hNMdDiyA9lBUDuDug)luQyUi7pm2jLORsegkpcOhxHdU3qGXnrLC2fRJY4FHsfZfzFehG7PnL5QPJtZHoWN6t0FXo(00x6aoU3qG5AAl5KafeMwlEzvctjs7VdXUyGXX9gcmxtBjNeOGW0AXlRsykHnClj2fRJY4FHsfZfzFehGRbyyFDscLFBCoMdkxtI3gy0RoG3Xv4G7neyUM2sojqbHP1IxwLWuI0(7qm1BCq81Na7EdbMRPTKtcuqyAT4LvjmLWgULet9gheF9jWEWba9mdWW(6Kek)24iamhdgX(IdsLWaJJX)cLmdWW(6Kek)24iamhdgXQue0fmzpyp4aGEMbyyFDscLFBCeYitZ(IdsLWKKaqpZamSVojHYVnoczKPzd5yvQKh3ELKaqpZamSVojHYVnocaZXGrm1BCq8f3GbqpZamSVojHYVnocaZXGrSHCSkv(cpWaONzag2xNKq53ghbG5yWi2xCqQeM3okJ)fkvmxK9rCaUCuEIaHeVmsOWQPE1Xv4aoaZTayjsWbuG9450MYC1eJJYteiKaGuGMCW4WrinaYFY4MOsoBidaujj3BiW4MOso7I5fSh3BiWCnTLCsGcctRfVSkHPeP93HyQ34GCaEssU3qG5AAl5KafeMwlEzvctjSHBjXuVXb5a88kjfkyYEXqowLkFXdFVDug)luQyUi7J4aC5wYjTW9gchNMdDq92OrdWXv4Gh3BiWCnTLCsGcctRfVSkHPeP93Hyd5yvQK3NyWtsY9gcmxtBjNeOGW0AXlRsykHnClj2qowLk59jg88c2u)yAbgYpnYFisXhShocPbq(tg3evYzd5yvQK)OLK8WrinaYFYihmKFAeUOeGnKJvPs(JgmoU3qGbsLadbiihmKFACO8fusdS6ie7IbMJoP0YNbcOtzPxVDug)luQyUi7J4aCvVnQ7aJoUchW50MYC1eJp1NO)Ib2dhDsPLpllyYErWijjocPbq(tg3evYzd5yvQK)OLKW50MYC1eJdi4OeO(cLGXHJoP0YNbcOtzPKKhocPbq(tg5GH8tJWfLaSHCSkvYF0GXX9gcmqQeyiab5GH8tJdLVGsAGvhHyxmWC0jLw(mqaDkl96TJY4FHsfZfzFehGR6TrDhy0Xv4GhocPbq(tghLNiqiXlJekSAQxXgYXQu5l8aJdWClawIeCafypN2uMRMyCuEIaHeaKc0KljXrinaYFY4MOsoBihRsLVWZRxWM6htlWq(PrEFcFWC0jLw(SSGj7fbJaJdWClawIeCavhLX)cLkMlY(ioa3tBkZvthNMdDaa9IHISBnKdLV64ttFPdECVHaJBIk5SHCSkvYdpWECVHaBStkrxLimuEeqzd5yvQKhEss44Edb2yNuIUkryO8iGYUyELKWX9gcmUjQKZUyssM6htlWq(PXxCJVxWEWX9gcmqQeyiab5GH8tJdLVGsAGvhHyxmjjt9JPfyi)04lUX3lypU3qGrCDHPiHcPTHnKJvPsEyCaMJjxjj3BiWiUUWuKqFtByd5yvQKhghG5yY1BhLX)cLkMlY(ioax1nd1qhZbLRjXBdm6vhW74kCyOWqkzMRMa)2aJE2xoK4rcGIKhpFgSHj4YioiGpTPmxnXaqVyOi7wd5q5R6Om(xOuXCr2hXb46GqzOg6yoOCnjEBGrV6aEhxHddfgsjZC1e43gy0Z(YHepsauK84HBg8aBycUmIdc4tBkZvtma0lgkYU1qou(QokJ)fkvmxK9rCaUQN0ABebTn0XCq5As82aJE1b8oUchgkmKsM5QjWVnWON9LdjEKaOi5XZNJyihRsfydtWLrCqaFAtzUAIbGEXqr2TgYHYx1rz8VqPI5ISpIdWnGgojqbrA)DOJRWbdtWLrCq6Om(xOuXCr2hXb4gUdOcuqq6BshxHdEiUUWueRsHLGkjrCDHPiMcPTruPapjjIRlmfX030grLc88c2doC0jLw(SSGj7fbJKKaMBbWsKGdOKK8yQFmTad5NgFJu4b2ZPnL5QjgFQpr)ftsYu)yAbgYpn(IB8LKoTPmxnXkLWqKxWEoTPmxnX4O8ebcjaifOjhmoCesdG8NmokprGqIxgjuy1uVIDXKKW50MYC1eJJYteiKaGuGMCW4WrinaYFY4MOso7I51RxWE4iKga5pzCtujNnKJvPsECJVKeWClawIeCaLKKP(X0cmKFAKpsXhmhH0ai)jJBIk5SlgypCesdG8NmYbd5NgHlkbyd5yvQ814FHsM6TjudXi5s87tIVCijjC4OtkT8zGa6uw6vsQYNgmK2EcqekyYEXqowLkFXdFVG9aGEMbyyFDscLFBCeaMJbJyd5yvQK3NKKWHJoP0YNLeFqA0a4TJY4FHsfZfzFehGl5GH8tJWfLahxHdEiUUWuetFtBejj3xsI46ctrmfsBJij5(ssexxykIzjOIKK7lj5EdbMRPTKtcuqyAT4LvjmLiT)oeBihRsL8(edEssU3qG5AAl5KafeMwlEzvctjSHBjXgYXQujVpXGNKKP(X0cmKFAKpsXhmhH0ai)jJBIk5SHmaqbJdWClawIeCaLxWE4iKga5pzCtujNnKJvPsECJVKehH0ai)jJBIk5SHmaq9kjv5tdgsBpbicfmzVyihRsLV4HFhLX)cLkMlY(ioaxoPj1xMwy6cw6q5FCfoGdWClawIeCaf4tBkZvtmoGGJsG6luc2JP(X0cmKFAKpsXhSh3BiWaPsGHaeKdgYpnou(ckPbwDeIDXKKWHJoP0YNbcOtzPxjjo6KslFwwWK9IGrssU3qG5Qria9v9Slgy3BiWC1ieG(QE2qowLkFJg)i8WrjWTEg2q8srctxWshkF2xoK400xYRxWEoTPmxnX4O8ebcjaifOjxsIJqAaK)KXr5jces8YiHcRM6vSHmaq9kjv5tdgsBpbicfmzVyihRsLVrJFeE4Oe4wpdBiEPiHPlyPdLp7lhsCA6l5TJY4FHsfZfzFehGBLCBs7luECfoGdWClawIeCaf4tBkZvtmoGGJsG6luc2JP(X0cmKFAKpsXhSh3BiWaPsGHaeKdgYpnou(ckPbwDeIDXKKWHJoP0YNbcOtzPxjjo6KslFwwWK9IGrssU3qG5Qria9v9Slgy3BiWC1ieG(QE2qowLkFXn(r4HJsGB9mSH4LIeMUGLou(SVCiXPPVKxVG9CAtzUAIXr5jcesaqkqtUKehH0ai)jJJYteiK4Lrcfwn1RydzaG6vsQYNgmK2EcqekyYEXqowLkFXn(r4HJsGB9mSH4LIeMUGLou(SVCiXPPVK3okJ)fkvmxK9rCaUN2uMRMoonh6GPWIKstmXp(00x6aX1fMIyvk030MJYh4Jg)luYuVnHAigjxIFFs8LdfboexxykIvPqFtBokF2hn(xOK5FSxgJKlXVpj(YHIaFw0(OcJ0AHmt9uhLX)cLkMlY(ioax1BJ6oWOJRWbpv(0GH02taIqbt2lgYXQu5Rpjj5X9gcSXoPeDvIWq5raLnKJvPYxyCaMJj3JItL2JP(X0cmKFA8rCJVxWU3qGn2jLORsegkpcOSlMxVssEm1pMwGH8tteN2uMRMyMclsknXe)OCVHaJ46ctrcfsBdBihRsveaONfUdOcuqq6BsSV4GOed5yvEurZGN84fn(ssM6htlWq(PjItBkZvtmtHfjLMyIFuU3qGrCDHPiH(M2WgYXQufba6zH7aQafeK(Me7loikXqowLhv0m4jpErJVxWexxykIvPWsqb7XdoCesdG8NmUjQKZUyssC0jLw(mqaDklbJdhH0ai)jJCWq(Pr4Isa2fZRKehDsPLpllyYErWiVG9GdhDsPLp7KYxgOJKeoU3qGXnrLC2ftsYu)yAbgYpnYhP47vsY9gcmUjQKZgYXQujVpamoU3qGn2jLORsegkpcOSlwhLX)cLkMlY(ioa3K8lCqO84kCWJ7neyexxyksOVPnSlMKKhUmBGrQdrdEiUmBGrIVCiFHNxjjUmBGrQd42lydtWLrCq6Om(xOuXCr2hXb4kZ0bHdcLhxHdECVHaJ46ctrc9nTHDXKK8WLzdmsDiAWdXLzdms8Ld5l88kjXLzdmsDa3EbBycUmIdshLX)cLkMlY(ioa3WvRfoiuECfo4X9gcmIRlmfj030g2ftsYdxMnWi1HObpexMnWiXxoKVWZRKexMnWi1bC7fSHj4YioiDug)luQyUi7J4aC9BZuOrGccsFtQJY4FHsfZfzFehGR6TjudDCfoqCDHPiwLc9nTrsI46ctrmfsBJij5(ssexxykIzjOIKK7lj5EdbMFBMcncuqq6BsSlgy3BiWiUUWuKqFtByxmjjpU3qGXnrLC2qowLkFn(xOK5FSxgJKlXVpj(YHa7Edbg3evYzxmVDug)luQyUi7J4aC9p2lRJY4FHsfZfzFehG7CtHX)cLcDP(JtZHoemT(Ln3oQokJ)fkvmGHmh3kbO5WPnL5QPJtZHoOSajEK4QiHcJ06Jpn9Lo4X9gcSVCi)OjfadzoUvcqdBihRsL8W4amhtUrGpdpWEiUUWueRsHl6LjjrCDHPiwLcfsBJKeX1fMIy6BAJij5(ELKCVHa7lhYpAsbWqMJBLa0WgYXQujVX)cLm1BtOgIrYL43NeF5qrGpdpWEiUUWueRsH(M2ijrCDHPiMcPTrKKCFjjIRlmfXSeursY996vsch3BiW(YH8JMuamK54wjanSlwhLX)cLkgWqMJBLa0eXb4QEBu3bgDCfo4bNtBkZvtmLfiXJexfjuyKwlj5X9gcSXoPeDvIWq5raLnKJvPYxyCaMJj3JItL2JP(X0cmKFA8rCJVxWU3qGn2jLORsegkpcOSlMxVssM6htlWq(Pr(if)okJ)fkvmGHmh3kbOjIdWLJYteiK4Lrcfwn1RoUchWbyUfalrcoGcShpN2uMRMyCuEIaHeaKc0KdUYNgmK2EcqekyYEXqowLk5Xd34dghocPbq(tg3evYzdzaGkj5Edbg3evYzxmVGn1pMwGH8tJV(e(G94EdbgX1fMIe6BAdBihRsL84HVKK7neyexxyksOqAByd5yvQKhp89kjfkyYEXqowLkFXdFVDug)luQyadzoUvcqtehGRbyyFDscLFBCoMdkxtI3gy0RoG3Xv4aoaONzag2xNKq53ghbG5yWi2xCqQegyCm(xOKzag2xNKq53ghbG5yWiwLIGUGj7b7bha0Zmad7RtsO8BJJqgzA2xCqQeMKea6zgGH91jju(TXriJmnBihRsL8WZRKea6zgGH91jju(TXrayogmIPEJdIV4gma6zgGH91jju(TXrayogmInKJvPYxCdga9mdWW(6Kek)24iamhdgX(IdsLW6Om(xOuXagYCCReGMioaxhekd1qhZbLRjXBdm6vhW74kCyOWqkzMRMa)2aJE2xoK4rcGIKhVOb7XJ7neyCtujNnKJvPsE4b2J7neyJDsj6QeHHYJakBihRsL8Wtsch3BiWg7Ks0vjcdLhbu2fZRKeoU3qGXnrLC2ftsYu)yAbgYpn(IB89c2doU3qGbsLadbiihmKFACO8fusdS6ie7IjjzQFmTad5NgFXn(EbBycUmIdI3okJ)fkvmGHmh3kbOjIdWvDZqn0XCq5As82aJE1b8oUchgkmKsM5QjWVnWON9LdjEKaOi5XlAWE84Edbg3evYzd5yvQKhEG94Edb2yNuIUkryO8iGYgYXQujp8KKWX9gcSXoPeDvIWq5raLDX8kjHJ7neyCtujNDXKKm1pMwGH8tJV4gFVG9GJ7neyGujWqacYbd5NghkFbL0aRocXUyssM6htlWq(PXxCJVxWgMGlJ4G4TJY4FHsfdyiZXTsaAI4aCvpP12icABOJ5GY1K4Tbg9Qd4DCfomuyiLmZvtGFBGrp7lhs8ibqrYJNpd2Jh3BiW4MOsoBihRsL8WdSh3BiWg7Ks0vjcdLhbu2qowLk5HNKeoU3qGn2jLORsegkpcOSlMxjjCCVHaJBIk5SlMKKP(X0cmKFA8f347fShCCVHadKkbgcqqoyi)04q5lOKgy1ri2ftsYu)yAbgYpn(IB89c2WeCzeheVDug)luQyadzoUvcqtehGBanCsGcI0(7qhxHdgMGlJ4G0rz8VqPIbmK54wjanrCaUJDsj6QeHHYJa6Xv4G7neyCtujNDX6Om(xOuXagYCCReGMioaxYbd5NgHlkboUch84X9gcmIRlmfjuiTnSHCSkvYJh(ssU3qGrCDHPiH(M2WgYXQujpE47fmhH0ai)jJBIk5SHCSkvYJB89kjXrinaYFY4MOsoBida0okJ)fkvmGHmh3kbOjIdWLtAs9LPfMUGLou(hxHd4am3cGLibhqb(0MYC1eJdi4OeO(cLG94X9gcmqQeyiab5GH8tJdLVGsAGvhHyxmjjC4OtkT8zGa6uw6vsIJoP0YNLfmzViyKK0PnL5QjwPegIKKCVHaZvJqa6R6zxmWU3qG5Qria9v9SHCSkv(gn(r4HJsGB9mSH4LIeMUGLou(SVCiXPPVKxVGXX9gcmUjQKZUyG9GdhDsPLpllyYErWijjocPbq(tghLNiqiXlJekSAQxXUyssv(0GH02taIqbt2lgYXQu5lhH0ai)jJJYteiK4Lrcfwn1Ryd5yvQIWNLKQ8PbdPTNaeHcMSxmKJvPYh9r88b47B04hHhokbU1ZWgIxksy6cw6q5Z(YHeNM(sE92rz8VqPIbmK54wjanrCaUvYTjTVq5Xv4aoaZTayjsWbuGpTPmxnX4acokbQVqjypECVHadKkbgcqqoyi)04q5lOKgy1ri2ftscho6KslFgiGoLLELK4OtkT8zzbt2lcgjjDAtzUAIvkHHijj3BiWC1ieG(QE2fdS7neyUAecqFvpBihRsLV4g)i8WrjWTEg2q8srctxWshkF2xoK400xYRxW44Edbg3evYzxmWEWHJoP0YNLfmzViyKKehH0ai)jJJYteiK4Lrcfwn1RyxmjPkFAWqA7jarOGj7fd5yvQ8LJqAaK)KXr5jces8YiHcRM6vSHCSkvr4Zssv(0GH02taIqbt2lgYXQu5J(iE(a89f34hHhokbU1ZWgIxksy6cw6q5Z(YHeNM(sE92rz8VqPIbmK54wjanrCaUN2uMRMoonh6GYojrancUjQKF8PPV0bC4iKga5pzCtujNnKbaQKeoN2uMRMyCuEIaHeaKc0KdMJoP0YNLfmzViyKKeWClawIeCavhLX)cLkgWqMJBLa0eXb4gUdOcuqq6BshxHdexxykIvPWsqbBycUmIdcypaONzag2xNKq53ghbG5yWi2xCqQeMKeoC0jLw(SK4dsJgaVGpTPmxnXu2jjcOrWnrL8okJ)fkvmGHmh3kbOjIdWv92OUdm64kCGJoP0YNLfmzViye4tBkZvtmokprGqcasbAYbBQFmTad5Ng5p4t4dMJqAaK)KXr5jces8YiHcRM6vSHCSkv(cJdWCm5EuCQ0Em1pMwGH8tJpIB89cghG5waSej4aQokJ)fkvmGHmh3kbOjIdWnj)chekpUch84EdbgX1fMIe6BAd7Ijj5HlZgyK6q0GhIlZgyK4lhYx45vsIlZgyK6aU9c2WeCzeheWN2uMRMyk7Keb0i4MOsEhLX)cLkgWqMJBLa0eXb4kZ0bHdcLhxHdECVHaJ46ctrc9nTHDXaJdhDsPLpdeqNYsjjpU3qGbsLadbiihmKFACO8fusdS6ie7IbMJoP0YNbcOtzPxjjpCz2aJuhIg8qCz2aJeF5q(cpVssCz2aJuhWTKK7neyCtujNDX8c2WeCzeheWN2uMRMyk7Keb0i4MOsEhLX)cLkgWqMJBLa0eXb4gUATWbHYJRWbpU3qGrCDHPiH(M2WUyGXHJoP0YNbcOtzPKKh3BiWaPsGHaeKdgYpnou(ckPbwDeIDXaZrNuA5Zab0PS0RKKhUmBGrQdrdEiUmBGrIVCiFHNxjjUmBGrQd4wsY9gcmUjQKZUyEbBycUmIdc4tBkZvtmLDsIaAeCtujVJY4FHsfdyiZXTsaAI4aC9BZuOrGccsFtQJY4FHsfdyiZXTsaAI4aCvVnHAOJRWbIRlmfXQuOVPnssexxykIPqABejj3xsI46ctrmlbvKKCFjj3BiW8BZuOrGccsFtIDXa7EdbgX1fMIe6BAd7Ijj5X9gcmUjQKZgYXQu5RX)cLm)J9YyKCj(9jXxoey3BiW4MOso7I5TJY4FHsfdyiZXTsaAI4aC9p2lRJY4FHsfdyiZXTsaAI4aCNBkm(xOuOl1FCAo0HGP1VS52r1rz8VqPIfmT(Ln3dQ3g1DGrhxHd4m3KcObgXCnTLCsGcctRfVSkHPyuKDlmmcOJY4FHsflyA9lBUrCaUQBgQHoMdkxtI3gy0RoG3Xv4aa6zoiugQHyd5yvQKFihRsvhLX)cLkwW06x2CJ4aCDqOmud1r1rz8VqPIP(dgGH91jju(TX5yoOCnjEBGrV6aEhxHd4aGEMbyyFDscLFBCeaMJbJyFXbPsyGXX4FHsMbyyFDscLFBCeaMJbJyvkc6cMShShCaqpZamSVojHYVnoczKPzFXbPsyssaONzag2xNKq53ghHmY0SHCSkvYdpVssaONzag2xNKq53ghbG5yWiM6noi(IBWaONzag2xNKq53ghbG5yWi2qowLkFXnya0Zmad7RtsO8BJJaWCmye7loivcRJY4FHsft9rCaUCuEIaHeVmsOWQPE1Xv4aoaZTayjsWbuG9450MYC1eJJYteiKaGuGMCW4WrinaYFY4MOsoBidaujj3BiW4MOso7I5fSP(X0cmKFA81NWhSh3BiWiUUWuKqFtByd5yvQKhp8LKCVHaJ46ctrcfsBdBihRsL84HVxjPqbt2lgYXQu5lE47TJY4FHsft9rCaUN2uMRMoonh6aa6fdfz3AihkF1XNM(sh84Edbg3evYzd5yvQKhEG94Edb2yNuIUkryO8iGYgYXQujp8KKWX9gcSXoPeDvIWq5raLDX8kjHJ7neyCtujNDXKKm1pMwGH8tJV4gFVG9GJ7neyGujWqacYbd5NghkFbL0aRocXUyssM6htlWq(PXxCJVxWECVHaJ46ctrcfsBdBihRsL8W4amhtUssU3qGrCDHPiH(M2WgYXQujpmoaZXKR3okJ)fkvm1hXb46GqzOg6yoOCnjEBGrV6aEhxHddfgsjZC1e43gy0Z(YHepsauK84fnypgMGlJ4Ga(0MYC1eda9IHISBnKdLVYBhLX)cLkM6J4aCv3mudDmhuUMeVnWOxDaVJRWHHcdPKzUAc8Bdm6zF5qIhjaksE8IgShdtWLrCqaFAtzUAIbGEXqr2TgYHYx5TJY4FHsft9rCaUQN0ABebTn0XCq5As82aJE1b8oUchgkmKsM5QjWVnWON9LdjEKaOi5XZNb7XWeCzeheWN2uMRMyaOxmuKDRHCO8vE7Om(xOuXuFehGBanCsGcI0(7qhxHdgMGlJ4G0rz8VqPIP(ioa3XoPeDvIWq5ra94kCW9gcmUjQKZUyDug)luQyQpIdWLCWq(Pr4IsGJRWbpECVHaJ46ctrcfsBdBihRsL84HVKK7neyexxyksOVPnSHCSkvYJh(EbZrinaYFY4MOsoBihRsL84gFWECVHadBkh0auMwyd3YIlWUALnSttFjFJ2NWxscN5MuanWig2uoObOmTWgULfxGD1kByuKDlmmcWRxjj3BiWWMYbnaLPf2WTS4cSRwzd700xs(drF04ljXrinaYFY4MOsoBidauWEm1pMwGH8tJ8rk(ssN2uMRMyLsyiYBhLX)cLkM6J4aC5KMuFzAHPlyPdL)Xv4aoaZTayjsWbuGpTPmxnX4acokbQVqjypM6htlWq(Pr(ifFWECVHadKkbgcqqoyi)04q5lOKgy1ri2ftscho6KslFgiGoLLELK4OtkT8zzbt2lcgjjDAtzUAIvkHHijj3BiWC1ieG(QE2fdS7neyUAecqFvpBihRsLVrJFeE8ePh1CtkGgyedBkh0auMwyd3YIlWUALnmkYUfggb4ncpCucCRNHneVuKW0fS0HYN9Ldjon9L861lyCCVHaJBIk5Slgyp4WrNuA5ZYcMSxemssIJqAaK)KXr5jces8YiHcRM6vSlMKuLpnyiT9eGiuWK9IHCSkv(YrinaYFY4O8ebcjEzKqHvt9k2qowLQi8zjPkFAWqA7jarOGj7fd5yvQ8rFepFa((gn(r4HJsGB9mSH4LIeMUGLou(SVCiXPPVKxVDug)luQyQpIdWTsUnP9fkpUchWbyUfalrcoGc8PnL5QjghqWrjq9fkb7Xu)yAbgYpnYhP4d2J7neyGujWqacYbd5NghkFbL0aRocXUyss4WrNuA5Zab0PS0RKehDsPLpllyYErWijPtBkZvtSsjmejj5EdbMRgHa0x1ZUyGDVHaZvJqa6R6zd5yvQ8f34hHhpr6rn3KcObgXWMYbnaLPf2WTS4cSRwzdJISBHHraEJWdhLa36zydXlfjmDblDO8zF5qIttFjVE9cgh3BiW4MOso7Ib2doC0jLw(SSGj7fbJKK4iKga5pzCuEIaHeVmsOWQPEf7Ijjv5tdgsBpbicfmzVyihRsLVCesdG8NmokprGqIxgjuy1uVInKJvPkcFwsQYNgmK2EcqekyYEXqowLkF0hXZhGVV4g)i8WrjWTEg2q8srctxWshkF2xoK400xYR3okJ)fkvm1hXb4EAtzUA640COdk7Keb0i4MOs(XNM(shWHJqAaK)KXnrLC2qgaOss4CAtzUAIXr5jcesaqkqtoyo6KslFwwWK9IGrssaZTayjsWbuDug)luQyQpIdWnChqfOGG03KoUchiUUWueRsHLGc2WeCzeheWU3qGHnLdAaktlSHBzXfyxTYg2PPVKVr7t4d2da6zgGH91jju(TXrayogmI9fhKkHjjHdhDsPLplj(G0ObWl4tBkZvtmLDsIaAeCtujVJY4FHsft9rCaUQ3MGP1hxHdU3qGHs6LPey0WjSVqj7Ib29gcm1BtW0A2qHHuYmxn1rz8VqPIP(ioaxULCslCVHWXP5qhuVnA0aCCfo4EdbM6TrJga2qowLkFHhypU3qGrCDHPiHcPTHnKJvPsE4jj5EdbgX1fMIe6BAdBihRsL8WZlyt9JPfyi)0iFKIFhLX)cLkM6J4aCvVnbtRpUchEtt5ZupP12iaMk8mknxnbawr)xjmftH0ibWuHhS7neyQ3MGP1maK)SJY4FHsft9rCaUQ3g1DGrhxHdC0jLw(SSGj7fbJaFAtzUAIXr5jcesaqkqtoyocPbq(tghLNiqiXlJekSAQxXgYXQu5l8aJdWClawIeCavhLX)cLkM6J4aCvVnbtRpUchEtt5ZupP12iaMk8mknxnbagN30u(m1BJgnamknxnba29gcm1BtW0A2qHHuYmxnb2J7neyexxyksOVPnSHCSkvY7ZGjUUWueRsH(M2a29gcmSPCqdqzAHnCllUa7Qv2Won9L8nA4HVKK7neyyt5GgGY0cB4wwCb2vRSHDA6lj)HOHh(Gn1pMwGH8tJ8rk(ssaONzag2xNKq53ghbG5yWi2qowLk59bssg)luYmad7RtsO8BJJaWCmyeRsrqxWK9EbJdhH0ai)jJBIk5SHmaq7Om(xOuXuFehGR6TrDhy0Xv4G7neyOKEzkbxt2iolvHs2ftsY9gcmqQeyiab5GH8tJdLVGsAGvhHyxmjj3BiW4MOso7Ib2J7neyJDsj6QeHHYJakBihRsLVW4amhtUhfNkTht9JPfyi)04J4gFVGDVHaBStkrxLimuEeqzxmjjCCVHaBStkrxLimuEeqzxmW4WrinaYFYg7Ks0vjcdLhbu2qgaOss4WrNuA5ZoP8Lb64vsYu)yAbgYpnYhP4dM46ctrSkfwcAhLX)cLkM6J4aCvVnQ7aJoUchEtt5ZuVnA0aWO0C1eaypU3qGPEB0ObGDXKKm1pMwGH8tJ8rk(Eb7EdbM6TrJgaM6noi(IBWECVHaJ46ctrcfsBd7Ijj5EdbgX1fMIe6BAd7I5fS7neyyt5GgGY0cB4wwCb2vRSHDA6l5B0hn(G9WrinaYFY4MOsoBihRsL84HVKeoN2uMRMyCuEIaHeaKc0KdMJoP0YNLfmzViyK3okJ)fkvm1hXb4QEBu3bgDCfo4X9gcmSPCqdqzAHnCllUa7Qv2Won9L8n6JgFjj3BiWWMYbnaLPf2WTS4cSRwzd700xY3OHh(GFtt5ZupP12iaMk8mknxnb4fS7neyexxyksOqAByd5yvQK)ObtCDHPiwLcfsBdyCCVHadL0ltjWOHtyFHs2fdmoVPP8zQ3gnAayuAUAcamhH0ai)jJBIk5SHCSkvYF0G9WrinaYFYihmKFAeUOeGnKJvPs(Jwscho6KslFgiGoLLE7Om(xOuXuFehGBs(foiuECfo4X9gcmIRlmfj030g2ftsYdxMnWi1HObpexMnWiXxoKVWZRKexMnWi1bC7fSHj4YioiGpTPmxnXu2jjcOrWnrL8okJ)fkvm1hXb4kZ0bHdcLhxHdECVHaJ46ctrc9nTHDXaJdhDsPLpdeqNYsjjpU3qGbsLadbiihmKFACO8fusdS6ie7IbMJoP0YNbcOtzPxjjpCz2aJuhIg8qCz2aJeF5q(cpVssCz2aJuhWTKK7neyCtujNDX8c2WeCzeheWN2uMRMyk7Keb0i4MOsEhLX)cLkM6J4aCdxTw4Gq5Xv4Gh3BiWiUUWuKqFtByxmW4WrNuA5Zab0PSusYJ7neyGujWqacYbd5NghkFbL0aRocXUyG5OtkT8zGa6uw6vsYdxMnWi1HObpexMnWiXxoKVWZRKexMnWi1bClj5Edbg3evYzxmVGnmbxgXbb8PnL5QjMYojrancUjQK3rz8VqPIP(ioax)2mfAeOGG03K6Om(xOuXuFehGR6TjudDCfoqCDHPiwLc9nTrsI46ctrmfsBJij5(ssexxykIzjOIKK7lj5EdbMFBMcncuqq6BsSlgy3BiWiUUWuKqFtByxmjjpU3qGXnrLC2qowLkFn(xOK5FSxgJKlXVpj(YHa7Edbg3evYzxmVDug)luQyQpIdW1)yVSokJ)fkvm1hXb4o3uy8VqPqxQ)40COdbtRFzZfkwHrCi4Gh(rd9qpeea]] )


end