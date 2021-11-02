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
        high_winds = 5383, -- 200931
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        owlkin_adept = 5407, -- 354541
        protector_of_the_grove = 3728, -- 209730
        star_burst = 3058, -- 356517
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
        owlkin_frenzy = {
            id = 157228,
            duration = 10,
            max_stack = function () return pvptalent.owlkin_adept.enabled and 2 or 1 end,
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
            duration = 8,
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
        ca_inc = {},
        --[[
            alias = { "incarnation", "celestial_alignment" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            -- duration = function () return talent.incarnation.enabled and 30 or 20 end,
        }, ]]

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

        high_winds = {
            id = 200931,
            duration = 4,
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
            duration = 8,
            max_stack = 8
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 8,
            max_stack = 8,
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
        eclipse.wrath_counter = 0
        removeBuff( "starsurge_empowerment_lunar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
        eclipse.starfire_counter = 0
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
                -- eclipse.reset_stacks()
            elseif buff.eclipse_solar.up then
                eclipse.state = "IN_SOLAR"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_lunar.up then
                eclipse.state = "IN_LUNAR"
                -- eclipse.reset_stacks()
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
                applyBuff( "balance_of_all_things_arcane", nil, 8, 8 )
                applyBuff( "balance_of_all_things_nature", nil, 8, 8 )
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

            if not ( eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" ) then           
                if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )                
                    state:RemoveAuraExpiration( "eclipse_solar" )
                    state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_SOLAR"
                    eclipse.starfire_counter = 0
                    eclipse.wrath_counter = 2
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
                    eclipse.wrath_counter = 0
                    eclipse.starfire_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end
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

    local SinfulHysteriaHandler = setfenv( function ()
        applyBuff( "ravenous_frenzy_sinful_hysteria" )
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
            rawset( buff, "ca_inc", buff.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
            rawset( buff, "ca_inc", buff.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 )
        end

        eclipse.reset()

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
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
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
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
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
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
            cooldown = 20,
            recharge = 20,
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
            cooldown = 20,
            recharge = 20,
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
            cooldown = 20,
            recharge = 20,
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
            cooldown = function () return talent.stellar_drift.enabled and 12 or 0 end,
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
                if buff.warrior_of_elune.up or buff.elunes_wrath.up or buff.owlkin_frenzy.up then return 0 end
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
                elseif buff.owlkin_frenzy.up then
                    removeStack( "owlkin_frenzy" )
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

            impact = function ()
                if not state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end
            end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
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

        enhancedRecheck = true,

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


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20211101, [[diLvwiqiIWJKsPUeuuSjO0NKsXOubNsfAvqH8kPKMLkHBPss2fHFPsQHjLQJrKSmOGNrvPMguv11GQyBqHQVbfkJtkLCovsQ1bvvAEQeDpaAFuv8pOOuQdkLOfcfPhsezIsjWfHQuBukb9rvsezKQKiQtsvjwjrQxQsIWmLsOBQsIYoHIQFQsIQHQschfkkLSuvsKEkQyQqrCvQkPTcfLQVcfLmwOQI9cO)kYGfomLfJQEmvMmqxgzZI6ZqLrRIoTsRgkkfVgaZgLBlf7wYVbnCI64qvYYv8CitxvxxQ2Uk13rLgpuvopvvRNiQ5tv2pPbkfqmbihq7jGyogAhdsjLuTlLadyW3yapyaiN3VmbKJS5aWWra5uwdbKdMAmRCeqoYMFg0abIja5GG9Xra5C(Vmc)E918gZkhDvOTXjWT)zNxSWRXuJzLJUkoBJKUUbuC(nmmBNxgbiVXSYrIhFpqo89L9(sbKhihq7jGyogAhdsjLuTlLadyW3ya)X4a5y9)eoa5WzBKeqoNliiva5bYbKqoGCWuJzLJ0Ofm9fuLMdj)udpnAifg)cnWq7yqkvAvAjDAfocHFvPVknAjiibQbhiZgnWuYAeQ0xLgs60kCeOgVn4OpTznCgIqA8qnC(Dmk92GJEKqL(Q04kLAG3eOg9QihHq24xJBBwJNrinoScsCHgYdDNqVnO(GJ04Q8rd5HUfO3guFWrhfQ0xLgT8gUGAipKZq)w40aZAS)uJnRX(TbPXFsAWDGfonWBhBLrKqL(Q04kZaG0qsW6gcaPXFsAWrEN9rAyAW2)zKgnWH0iZi8T8msJdBwd)WUgNgy1MxJZ91yFnqBtN9wrWoI5xdU7FQbMEL3smrJw1qseJq)AmnAjBXvnu9xOX(TbudeaR8rHk9vPXvMbaPrde9A0M8I78td1yBHAJgihv2SqKgMSmZVgpudEicPrEXD(inGfZVqL(Q0atgYEnWeydPbmRbMYStnWuMDQbMYStnmKgMgizYTgtJF2ca6fQ0xLgx5YurJghwbjUqdmRX(Zl0aZAS)8cn482K3HoQrJbsA0ahsJHqlBP614HAq2WwA0WbB4T)QqVnVqLwLULvbF7jqnWuJzLJ0OLxrlQHZkn4jnYWEbQH9AC(Vmc)E918gZkhDvOTXjWT)zNxSWRXuJzLJUkoBJKUUbuC(nmmBNxgbiVXSYrIhFVkTkT5(fwiH8qoydV9acWwGdbMqY7SpsLgtojnUTznEgPXI0arVgpuJ21G7(NAuqnqV9Aaln6isJF2ca6rxOHuAW9Kkn(tsJ8oOxdyrASinGLgDeDHgyqJnRXFsAGihSa1yrAyfOg(wJnRbp8p1WgsL2C)clKqEihSH3(wb86BBwJNrxuwdbiSsDeL(zlaO)IBJ1jaBxL2C)clKqEihSH3(wb86BBwJNrxuwdbiSsDeL(zlaO)cOmGgi4f3gRtak1fBgWF2ca6fsjonuQJOeFpNX(ZwaqVqkHdczGqULaSp2VWcRe)Sfa0lKsSiXdBOemNAGf6hyhLCWc9t39lSqQ0M7xyHeYd5Gn823kGxFBZA8m6IYAiaHvQJO0pBba9xaLb0abV42yDcqmCXMb8NTaGEbgeNgk1ruIVNZy)zlaOxGbHdczGqULaSp2VWcRe)Sfa0lWGyrIh2qjyo1al0pWok5Gf6NU7xyHuPXKtcrA8ZwaqpsdBink4RH1FyJ9RZym)Aasp5EcuddPbS0OJinqV9A8ZwaqpsOHgCOxJBBwJNrA8qnWFnmKg)j5xdJHGAuebQbsMCRX040kq2w4eQ0M7xyHeYd5Gn823kGxFBZA8m6IYAiaHvQJO0pBba9xaLb0abV42yDcq8)IndiHx9vwMafBHCt)nEgLWRUvFVjbs3RJ88i8QVYYeOGAK9pKXsWbSSYrEEeE1xzzcuGGDgJ(FlCPPZ7xL2C)clKqEihSH3(wb86giSayRugonQ0M7xyHeYd5Gn823kGxZDS)8c2wuYbcOuTFXMb8a5yRmIeSEztQi89EEKJTYisSvcbz245ro2kJiXwjE4F65ro2kJiHv(tfHV)OkTk9vmKZqVgyqdmRX(tnScudtdoVnO(GJ0awAWbt0G7(NAG5lUZxJwOrAyfOgykSLyIgWrdoVn5DinG)jnCxePsBUFHfsaLPIMwb8AUJ9NxSzapqo2kJibRx2KkcFVNh5yRmIeBLqqMnEEKJTYisSvIh(NEEKJTYisyL)ur47pIvEOBHucUJ9NyLqEOBbgeCh7pvPn3VWcjGYurtRaEn6TjVdDbBlk5abepxSzaLy6fLHdosWBmRCucMtgJL(ZTWH88KWbVPYQxulUZpLnYZtcKmXyP3gC0JeO3MSXyakLNNeVXO6fL99HqjEJzLJeuz8mc0Z7a5yRmIeiiZMur4798ihBLrKyReRx245ro2kJiXwjE4F65ro2kJiHv(tfHV)OkT5(fwibuMkAAfWRrVnO(GJUGTfLCGaINl2mGtVOmCWrcEJzLJsWCYyS0FUfoewh8MkRErT4o)u2iSizIXsVn4OhjqVnzJXaukvAvA8gFKR)eOg0nn(143gsJ)K0WCpC0yrAy32YmEgjuPn3VWcbicYSjXtwJkT5(fwOwb8ANXyjZ9lSsSf9xuwdbiuMkAUyZa(BdD5bmGrM7xyj4o2FkCg6t)2qTAUFHLa92K3Heod9PFBOJQ0COhPrlH4TgWsdF3QgC3)e2FnaNn)AyfOgC3)udoVnm4aQHvGAGHw1a(N0WDrKkT5(fwOwb86BBwJNrxuwdb4IsgKU42yDcqKmXyP3gC0JeO3MSXy(if2ds8gJQxGEByWbuqLXZiqpV3yu9c0tmMnjWzZVGkJNrGh98qYeJLEBWrpsGEBYgJ5dguP5qpsdhJSBsdUNuPbN3M8oKgoR04CFnWqRA82GJEKgCpx3PglsJHy0TvVgz4OXFsAG3o2kJinEOg8KgYdLPziqnScudUNR7uJ8Yy0OXd1WzOxL2C)cluRaE9TnRXZOlkRHaCrjhJSB6IBJ1jarYeJLEBWrpsGEBY7q(iLknMDBwJNrA8N2RH7KCaG0yZA4h21WgsJT0W0aNduJhQHDdxqn(tsd0(D7xyPb3tAinmn(zlaOxd6DASin6icuJT0GNEUevA4m0JuPn3VWc1kGxFBZA8m6IYAia3kHZbEXTX6eGYdDlAGWkVd55jp0Ta1R8oKNN8q3c0BdQp4ipp5HUfO3MSXyEEYdDlY9XFcMteRxKNhFpNfolTLtmuJTfcq(EolCwAlNaSp2VWYZtEOBXy3ub7OuEOsY(98UTznEgjwuYGKkTVIinWuAq0aWw40G7(NAiPwETVuonGJgw(PrdjbRBiaKgBPHKA51(s5uPn3VWc1kGxZtdIga2c3fBgWdhKWbVPYQxulUZpLnYZtcheYaHClHdw3qaO0FsjK8o7JeD5Jy575SWzPTCIHASTq(ifEWY3ZzXy3ub7OuEOsY(fd1yBHUe)XkHdEtLvV4MQ)0)455G3uz1lUP6p9py575SWzPTCIUmw(Eolg7MkyhLYdvs2VOlJ9aFpNfJDtfSJs5Hkj7xmuJTf6sPK6QWdgn9IYWbhjqBL7S0PF0tZAEE89Cw4S0woXqn2wOlLskppPWmizIXsNg6PlLsGh8C8i2BBwJNrITs4CGQ0xb81G7(NAyAiPwETVuon(t71yrvBEnmnUIodzJgYd0PbC0G7jvA8NKg5f35RXI0W4H9xJhQbvGQ0M7xyHAfWRLH)cRl2mG89Cw4S0woXqn2wiFKcpypiX0lkdhCKaTvUZsN(rpnR55X3ZzXy3ub7OuEOsY(fd1yBHUukm2vHbmIVNZcEgecY6Ox0LXY3ZzXy3ub7OuEOsY(fD5JEE8qecBEXD(PHASTqxIb8OsljJ56m7jKgCpP)Kgn6OTWPHKG1neasJcYvdUlJPHXyqUA4h214HAG(LX0WzOxJ)K0aznKgwdSxVgWSgscw3qaOwLulV2xkNgod9ivAZ9lSqTc4132SgpJUOSgcqhSUHaqjqc5VCxCBSobOJw2Hd5f35NgQX2cDvsHNRYbHmqi3s4S0woXqn2wOJygPAR2pcOJw2Hd5f35NgQX2cDvsHNRYbHmqi3s4G1neak9NucjVZ(ibyFSFH1v5GqgiKBjCW6gcaL(tkHK3zFKyOgBl0rmJuTv7hXkXylyIUP6fgiisq4BrpYZZbHmqi3s4S0woXqn2wiF26PrgYSNat5f35NgQX2c55n9IYWbhjCeJq)ASesEN9ryDqideYTeolTLtmuJTfYhF3UNNdczGqULWbRBiau6pPesEN9rIHASTq(S1tJmKzpbMYlUZpnuJTf6QKQDppjCWBQS6f1I78tzJuP9vebQXd1aKyMFn(tsJoYWrAaZAiPwETVuon4EsLgD0w40ae25zKgWsJoI0WkqnKh6MQxJoYWrAW9KknSsddeud6MQxJfPHXd7VgpudWLuPn3VWc1kGxFBZA8m6IYAiaDGjhSa3FH1f3gRtaEiV4o)0qn2wiFKcpEEJTGj6MQxyGGiXw(GN2pI9WHdeE1xzzcuqnY(hYyj4aww5iShCqideYTeuJS)HmwcoGLvosmuJTf6sPW4T755G3uz1lUP6p9pyDqideYTeuJS)HmwcoGLvosmuJTf6sPW4ySwpiLuy00lkdhCKaTvUZsN(rpnRD8iwjCqideYTeuJS)HmwcoGLvosmKb6)ONhHx9vwMafiyNXO)3cxA68(XEqch8MkRErT4o)u2ippheYaHClbc2zm6)TWLMoV)KVXF80wTlLyOgBl0Lsjf(F0Z7GdczGqULGNgenaSfoXqgOFppjgZrIFGm2rShoq4vFLLjqXwi30FJNrj8QB13BsG096iShCqideYTeBHCt)nEgLWRUvFVjbs3RJedzG(98m3VWsSfYn934zucV6w99MeiDVosaUiJNrGhp65DGWR(kltGc0Pbc5sGj4WNG50dNgQESoiKbc5wIhonu9eyAl0I78t(gp4X3yqkXqn2wOJEEhoCBZA8msaRuhrPF2ca6bukpVBBwJNrcyL6ik9ZwaqpG((i2d)Sfa0lKsmKb6p5GqgiKB559ZwaqVqkHdczGqULyOgBlKpB90idz2tGP8I78td1yBHUkPA)ON3TnRXZibSsDeL(zlaOhqmG9WpBba9cmigYa9NCqideYT88(zlaOxGbHdczGqULyOgBlKpB90idz2tGP8I78td1yBHUkPA)ON3TnRXZibSsDeL(zlaOhW2pE8ONNdEtLvVaa)ZA1rppEicHnV4o)0qn2wOl575SWzPTCcW(y)clvAm72SgpJ0OJiqnEOgGeZ8RHv(14NTaGEKgwbQHdePb3tQ0GRT)w40idhnSsd8UlFcN10qEGovAZ9lSqTc4132SgpJUOSgcW)CwglHicaAsCT9V42yDcqjqWoJFlqXFolJLqebancQmEgb65LxCNFAOgBlKpyO92984Hie28I78td1yBHUed4P1d4F7xfFpNf)5Smwcrea0iqV5aaJWWrpp(Eol(ZzzSeIiaOrGEZbGp(UTUQdtVOmCWrc0w5olD6h90SggHNJQ0(kI0aVBK9pKX04kFalRCKgyODe5qAWtz4qAyAiPwETVuon6isOsBUFHfQvaVUJO0(uZfL1qasnY(hYyj4aww5Ol2mGoiKbc5wcNL2YjgQX2cDjgAhRdczGqULWbRBiau6pPesEN9rIHASTqxIH2XE42M14zK4pNLXsiIaGMexBFpp(Eol(ZzzSeIiaOrGEZbGp(U9wpm9IYWbhjqBL7S0PF0tZAyeg)4rS32SgpJeBLW5a984Hie28I78td1yBHU03ymvAFfrAWb2zm63cNgxPDE)AGXrKdPbpLHdPHPHKA51(s50OJiHkT5(fwOwb86oIs7tnxuwdbic2zm6)TWLMoV)l2mGhCqideYTeolTLtmuJTf6smowjCWBQS6f3u9N(hSs4G3uz1lQf35NYg555G3uz1lQf35NYgH1bHmqi3s4G1neak9NucjVZ(iXqn2wOlX4ypCBZA8ms4G1neakbsi)LZZZbHmqi3s4S0woXqn2wOlX4h98CWBQS6f3u9N(hShKy6fLHdosG2k3zPt)ONM1W6GqgiKBjCwAlNyOgBl0LyCpp(Eolg7MkyhLYdvs2VyOgBl0LsH)TEapyeHx9vwMafBH(P7E4GsG79wuINySJy575SySBQGDukpujz)IU8rppEicHnV4o)0qn2wOlXaE88i8QVYYeOGAK9pKXsWbSSYryDqideYTeuJS)HmwcoGLvosmuJTfYhm0(rS32SgpJeBLW5aXkbHx9vwMafBHCt)nEgLWRUvFVjbs3RJ88CqideYTeBHCt)nEgLWRUvFVjbs3RJed1yBH8bdT75XdriS5f35NgQX2cDjgAxLULmUMFKgDePHVGzRwGgC3)udj1YR9LYPsBUFHfQvaV(2M14z0fL1qaU4fyYblW9xyDXTX6eG89Cw4S0woXqn2wiFKcpypiX0lkdhCKaTvUZsN(rpnR55X3ZzXy3ub7OuEOsY(fd1yBHUeqPWGadTEW3yeFpNf8mieK1rVOlFS1dT1vHhmIVNZcEgecY6Ox0LpIreE1xzzcuSf6NU7HdkbU3BrjEIXWY3ZzXy3ub7OuEOsY(fD5JEE8qecBEXD(PHASTqxIb845r4vFLLjqb1i7FiJLGdyzLJW6GqgiKBjOgz)dzSeCalRCKyOgBlKkT5(fwOwb86oIs7tnxuwdb4wi30FJNrj8QB13BsG096Ol2mG32SgpJelEbMCWcC)fwyVTznEgj2kHZbQs7RisJzXD(AWtz4qA4arQ0M7xyHAfWR7ikTp1CrzneGOtdeYLatWHpbZPhonu9xSzap4GqgiKBjCwAlNyid0pwjCWBQS6f1I78tzJWEBZA8ms8NZYyjeraqtIRTp2doiKbc5wcEAq0aWw4edzG(98Kymhj(bYyh98CWBQS6f1I78tzJW6GqgiKBjCW6gcaL(tkHK3zFKyid0p2d32SgpJeoyDdbGsGeYF588CqideYTeolTLtmKb6)4rSGWxG6vEhs8RdGTWH9ai8fONymBszMnK4xhaBHZZtI3yu9c0tmMnPmZgsqLXZiqppKmXyP3gC0JeO3M8oKp((iwq4lAGWkVdj(1bWw4WE42M14zKyrjdsEEtVOmCWrcEJzLJsWCYyS0FUfoKNNH(XyjzixA8bWRUDpVBBwJNrchSUHaqjqc5VCEE89CwWZGqqwh9IU8rSsq4vFLLjqXwi30FJNrj8QB13BsG096ippcV6RSmbk2c5M(B8mkHxDR(EtcKUxhH1bHmqi3sSfYn934zucV6w99MeiDVosmuJTfYhF3owj475SWzPTCIUSNhpeHWMxCNFAOgBl0L4F7Q0yY5I0yrAyAm2FsJgeZ4HJ9KgCn)A8qnAmainmgtdyPrhrAGE714NTaGEKgpudEsd2weOgDzn4U)PgsQLx7lLtdRa1qsW6gcaPHvGA0rKg)jPbgkqnqm4RbS0WbQXM1Gh(NA8ZwaqpsdBinGLgDePb6TxJF2ca6rQ0M7xyHAfWR7ikTp1GUaXGpcWF2ca6L6Ind4HBBwJNrcyL6ik9ZwaqVeakfwj(zlaOxGbXqgO)KdczGqULN3HBBwJNrcyL6ik9ZwaqpGs55DBZA8msaRuhrPF2ca6b03hXEGVNZcNL2Yj6YypiHdEtLvV4MQ)0)45X3ZzXy3ub7OuEOsY(fd1yBHA9aEWOPxugo4ibARCNLo9JEAw74La(ZwaqVqkbFpNtG9X(fwy575SySBQGDukpujz)IUSNhFpNfJDtfSJs5Hkj7pH2k3zPt)ONM1eD5JEEoiKbc5wcNL2YjgQX2c1kg85NTaGEHucheYaHClbyFSFHfwj475SWzPTCIUm2ds4G3uz1lQf35NYg55jXTnRXZiHdw3qaOeiH8xUJyLWbVPYQxaG)zTYZZbVPYQxulUZpLnc7TnRXZiHdw3qaOeiH8xoSoiKbc5wchSUHaqP)Ksi5D2hj6YyLWbHmqi3s4S0worxg7Hd89Cwqo2kJOeRx2igQX2c5JuT75X3Zzb5yRmIsiiZgXqn2wiFKQ9JyLy6fLHdosWBmRCucMtgJL(ZTWH88oW3ZzbVXSYrjyozmw6p3chkv23hsGEZbaG4XZJVNZcEJzLJsWCYyS0FUfouYgNvKa9MdaaBRJh98475SaGTahcmrnYqU00q1NOIgCRKjrx(ONhpeHWMxCNFAOgBl0LyODpVBBwJNrcyL6ik9ZwaqpGTFe7TnRXZiXwjCoqvAZ9lSqTc41DeL2NAqxGyWhb4pBba9y4Ind4HBBwJNrcyL6ik9ZwaqVeaIbSs8ZwaqVqkXqgO)KdczGqULN3TnRXZibSsDeL(zlaOhqmG9aFpNfolTLt0LXEqch8MkREXnv)P)XZJVNZIXUPc2rP8qLK9lgQX2c16b8GrtVOmCWrc0w5olD6h90S2Xlb8NTaGEbge89Cob2h7xyHLVNZIXUPc2rP8qLK9l6YEE89Cwm2nvWokLhQKS)eARCNLo9JEAwt0Lp655GqgiKBjCwAlNyOgBluRyWNF2ca6fyq4GqgiKBja7J9lSWkbFpNfolTLt0LXEqch8MkRErT4o)u2ippjUTznEgjCW6gcaLajK)YDeReo4nvw9ca8pRvypibFpNfolTLt0L98KWbVPYQxCt1F6Fo655G3uz1lQf35NYgH92M14zKWbRBiaucKq(lhwheYaHClHdw3qaO0FsjK8o7JeDzSs4GqgiKBjCwAlNOlJ9Wb(EolihBLruI1lBed1yBH8rQ298475SGCSvgrjeKzJyOgBlKps1(rSsm9IYWbhj4nMvokbZjJXs)5w4qEEh475SG3yw5OemNmgl9NBHdLk77djqV5aaq845X3ZzbVXSYrjyozmw6p3chkzJZksGEZbaGT1XJh98475SaGTahcmrnYqU00q1NOIgCRKjrx2ZJhIqyZlUZpnuJTf6sm0UN3TnRXZibSsDeL(zlaOhW2pI92M14zKyReohOkTVIiKggJPb8pPrdyPrhrASp1G0awA4avPn3VWc1kGx3ruAFQbPs3ci3csAyUFHLgSf9AWBicudyPbA)U9lSUMr4wKkT5(fwOwb86PxjZ9lSsSf9xuwdbObPlq)SUhqPUyZaEBZA8msSOKbjvAZ9lSqTc41tVsM7xyLyl6VOSgcqEO9xG(zDpGsDXMbC6fLHdosWBmRCucMtgJL(ZTWHeeE1xzzcuL2C)cluRaE90RK5(fwj2I(lkRHae9Q0Q0sYyUoZEcPb3t6pPrJ)K0OfmK14S3DsJg89CwdUlJPr2ymnG5SgC3)Cln(tsJIW3RHZqVkT5(fwiHbjaVTznEgDrzneGGdznjUlJLYgJLG58f3gRtaEGVNZIFBiUWPsGdzn8BbsJyOgBl0L4CGIgdFT2Uqkpp(Eol(TH4cNkboK1WVfinIHASTqxAUFHLa92K3Hee(ix)P0VnuRTlKc7bYXwzej2kX6LnEEKJTYisGGmBsfHV3ZJCSvgrcR8NkcF)XJy575S43gIlCQe4qwd)wG0i6YyNErz4GJe)2qCHtLahYA43cKgvAjzmxNzpH0G7j9N0ObN3guFWrASin4cN)udNH(TWPb8Mgn482K3H0ylnAXEzJg4TJTYisL2C)clKWGuRaE9TnRXZOlkRHaCXvWHsO3guFWrxCBSobOeKJTYisSvcbz2G9asMyS0Bdo6rc0BtEhYh8G9ngvVab7SemN(tkLHdHEbvgpJa98qYeJLEBWrpsGEBY7q(GXoQs7RisdjbRBiaKgCpPsd71GriKg)PvAGN21OLORqdRa1GTfPrxwdU7FQHKA51(s5uPn3VWcjmi1kGx7G1neak9NucjVZ(Ol2mGsao9fuuWKdeH9WHBBwJNrchSUHaqjqc5VCyLWbHmqi3s4S0woXqgOFpp(EolCwAlNOlFe7b(EolihBLruI1lBed1yBH8bJ75X3Zzb5yRmIsiiZgXqn2wiFW4hXEqIPxugo4ibVXSYrjyozmw6p3chYZJVNZcEJzLJsWCYyS0FUfouQSVpKa9MdaF8TNhFpNf8gZkhLG5KXyP)ClCOKnoRib6nha(47JEE8qecBEXD(PHASTqxkv7yLWbHmqi3s4S0woXqgO)JQ0(kI0Ofoujz)AWD)tnKulV2xkNkT5(fwiHbPwb86XUPc2rP8qLK9FXMbKVNZcNL2YjgQX2c5Ju4rL2xrKgC6vEhsJT0q2kqQzDAalnSY)FUfon(t71GT3esdPWFe5qAyfOgmcH0G7(NA0ahsJ3gC0J0WkqnSxJ)K0GkqnGznmn4az2ObE7yRmI0WEnKc)1aroKgWrdgHqAmuJT1w40WqA8qnk4RXPDVfonEOgdLhcDQbyF2cNgTyVSrd82XwzePsBUFHfsyqQvaVg1R8o0fo)ogLEBWrpcqPUyZaEyO8qOtJNrEE89Cwqo2kJOecYSrmuJTf6sFJLCSvgrITsiiZgSd1yBHUuk8h7BmQEbc2zjyo9Nukdhc9cQmEgbEe7Bdo6f)2qPhMaxYhPW)Rcjtmw6Tbh9OwhQX2cH9a5yRmIeBLSYVN3qn2wOlX5afng(oQs7Risdo9kVdPXd140UjnmnWXG8gtJhQrhrA4ly2QfOsBUFHfsyqQvaVg1R8o0fBgWBBwJNrIfVatoybU)clSoiKbc5wITqUP)gpJs4v3QV3KaP71rIHmq)yj8QVYYeOylKB6VXZOeE1T67njq6EDKkT5(fwiHbPwb8A0Bt2ySl2mGs8gJQxGEIXSjboB(fuz8mce7b(EolqVnzJXedLhcDA8mc7bKmXyP3gC0JeO3MSXyx6BppjMErz4GJe)2qCHtLahYA43cKMJEEVXO6fiyNLG50FsPmCi0lOY4zeiw(EolihBLrucbz2igQX2cDPVXso2kJiXwjeKzdw(EolqVnzJXed1yBHUeJHfjtmw6Tbh9ib6TjBmMpaI)hXEqIPxugo4ibZVZgdLYmI(TWLWX2gze559BdHzWm4pE8HVNZc0Bt2ymXqn2wOwXWrSVn4Ox8BdLEycCjFWJknM1(NAW5jgZgnAbZMFn6isdyPHdudUNuPXq5HqNgpJ0GV)AG(LX0GRTVgz4Orl63zJH0qEGonScudqy1MxJoI0GNYWH0qsTaKqdo)YyA0rKg8ugoKgscw3qainqB5in(t71G7YyAipqNgwb)tA0GZBt2ymvAZ9lSqcdsTc41O3MSXyxSzaFJr1lqpXy2KaNn)cQmEgbILVNZc0Bt2ymXq5HqNgpJWEqIPxugo4ibZVZgdLYmI(TWLWX2gze559BdHzWm4pE8b)pI9Tbh9IFBO0dtGl5JVvPXS2)uJwWqwd)wG0OrhrAW5TjBmMgpudaiswJUSg)jPbFpN1G3Vggdb1OJ2cNgCEBYgJPbS0apAGihSarAahnyecPXqn2wBHtL2C)clKWGuRaEn6TjBm2fBgWPxugo4iXVnex4ujWHSg(TaPblsMyS0Bdo6rc0Bt2ymFa03ypibFpNf)2qCHtLahYA43cKgrxglFpNfO3MSXyIHYdHonEg55D42M14zKaCiRjXDzSu2ySemNXEGVNZc0Bt2ymXqn2wOl9TNhsMyS0Bdo6rc0Bt2ymFWa23yu9c0tmMnjWzZVGkJNrGy575Sa92KngtmuJTf6s8C84rvAjzmxNzpH0G7j9N0OHPbN3guFWrA0rKgCxgtdN1rKgCEBYgJPXd1iBmMgWC(cnScuJoI0GZBdQp4inEOgaqKSgTGHSg(TaPrd0Boa0OlRsBUFHfsyqQvaV(2M14z0fL1qaIEBYgJL4cRpLnglbZ5lUnwNa0q)ySKmKln(0wTFvhKQDmIVNZIFBiUWPsGdzn8BbsJa9MdGJx1b(EolqVnzJXed1yBHWiFJzqYeJLon0tyKeVXO6fONymBsGZMFbvgpJapEvhCqideYTeO3MSXyIHASTqyKVXmizIXsNg6jm6ngvVa9eJztcC28lOY4ze4XR6ai8f5(4pbZjI1lsmuJTfcJWZrSh475Sa92Kngt0L98CqideYTeO3MSXyIHASTqhvP9vePbN3guFWrAWD)tnAbdzn8BbsJgpudaiswJUSg)jPbFpN1G7(NW(RbdI2cNgCEBYgJPrx(3gsdRa1OJin482G6dosdyPb(3QgykSLyIgO3CaG0Ox)Y0a)14Tbh9ivAZ9lSqcdsTc41O3guFWrxSzaVTznEgjahYAsCxglLnglbZzS32SgpJeO3MSXyjUW6tzJXsWCgRe32SgpJelUcouc92G6doYZ7aFpNf8gZkhLG5KXyP)ClCOuzFFib6nha(4Bpp(Eol4nMvokbZjJXs)5w4qjBCwrc0Boa8X3hXIKjgl92GJEKa92Kng7s8h7TnRXZib6TjBmwIlS(u2ySemNvP9vePbIRnnAGGA8N2RHFyxdC0RrJHpn6Y)2qAW7xJoAlCASVggsdM9KggsdzicT8msdyPbJqin(tR0W3AGEZbasd4ObMnD0Rb3tQ0W3TQb6nhaini8jVdPsBUFHfsyqQvaV2an5FVPeIRnnx487yu6Tbh9iaL6IndOe)6aylCyLWC)clHbAY)EtjexBAsGwJHJeBLYSf3575bcFHbAY)EtjexBAsGwJHJeO3CaCPVXccFHbAY)EtjexBAsGwJHJed1yBHU03Q0xPuEi0PgxzqyL3H0yZAiPwETVuonwKgdzG(VqJ)KgsdBinyecPXFALg4rJ3gC0J0ylnAXEzJg4TJTYisdU7FQbh43cVqdgHqA8NwPHuTRb8pPH7Iin2sdR8RbE7yRmI0aoA0L14HAGhnEBWrpsdEkdhsdtJwSx2ObE7yRmIeA0cGvBEngkpe6udW(SfonUsSf4qGAG3nYqU00q1RrVyecPXwAWbYSrd82XwzePsBUFHfsyqQvaVUbcR8o0fo)ogLEBWrpcqPUyZaouEi0PXZiSVn4Ox8BdLEycCjFoCqk8V1dizIXsVn4OhjqVn5DimcdyeFpNfKJTYikX6LnIU8XJTouJTf6iM5GuT(gJQx8C3k1aHfsqLXZiWJyp4GqgiKBjCwAlNyid0pwjaN(ckkyYbIWE42M14zKWbRBiaucKq(lNNNdczGqULWbRBiau6pPesEN9rIHmq)EEs4G3uz1lQf35NYgD0Zdjtmw6Tbh9ib6TjVdD5Hdy8R6aFpNfKJTYikX6LnIUmgHHJhXOds16BmQEXZDRudewibvgpJapEeReKJTYisGGmBsfHV3Z7a5yRmIeBLqqMnEEhihBLrKyRep8p98ihBLrKyReRx2CeReVXO6fiyNLG50FsPmCi0lOY4zeONhFpNfYZ2ahW1yjBCwTUKCNHSrCBSo5dGyapTFe7bKmXyP3gC0JeO3M8o0Ls1ogDqQwFJr1lEUBLAGWcjOY4ze4XJyn0pgljd5sJp4P9RIVNZc0Bt2ymXqn2wimcJFe7bj475SaGTahcmrnYqU00q1NOIgCRKjrx2ZJCSvgrITsiiZgppjCWBQS6fa4FwRoIvc(Eolg7MkyhLYdvs2FcTvUZsN(rpnRj6YQ0(kI0OfcXCnGLgoqn4U)jS)A4mz5TWPsBUFHfsyqQvaVodhhLG5uzFFOl2mGMCYDsoauPn3VWcjmi1kGxFBZA8m6IYAiaDGjhSa3FHvYG0f3gRtakb40xqrbtoqe2BBwJNrchyYblW9xyH9Wb(EolqVnzJXeDzpV3yu9c0tmMnjWzZVGkJNrGEEo4nvw9IAXD(PSrhXEqc(Eolqqg6xhj6YyLGVNZcNL2Yj6YypiXBmQErUp(tWCIy9Ieuz8mc0ZJVNZcNL2Yja7J9lS8XbHmqi3sK7J)emNiwViXqn2wOwBRJyVTznEgj(ZzzSeIiaOjX12h7bjCWBQS6f1I78tzJ88CqideYTeoyDdbGs)jLqY7Sps0LXEGVNZc0Bt2ymXqn2wOlXGNNeVXO6fONymBsGZMFbvgpJapEe7Bdo6f)2qPhMaxYh(EolCwAlNaSp2VWcJAxGXo65XdriS5f35NgQX2cDjFpNfolTLta2h7xyDuL2xrKgsQLx7lLtdyPHduJEXiesdRa1GTfPX(A0L1G7(NAijyDdbGuPn3VWcjmi1kGx7igH(1yjJT4QgQ(l2mG32SgpJeoWKdwG7VWkzqsL2C)clKWGuRaE9woBk7xyDXMb82M14zKWbMCWcC)fwjdsQ0(kI0aVBKHCPrdmfwGAalnCGAWD)tn482KngtJUSgwbQbYUjnYWrJROZq2OHvGAiPwETVuovAZ9lSqcdsTc41uJmKlnjEybEXMbKhIqy36PrgYSNat5f35NgQX2cDPu4XZ7aFpNfYZ2ahW1yjBCwTUKCNHSrCBSoDjgWt7EE89CwipBdCaxJLSXz16sYDgYgXTX6KpaIb80(rS89CwGEBYgJj6Yyp4GqgiKBjCwAlNyOgBlKp4PDppWPVGIcMCGOJQ0xPuEi0PgzMnKgWsJUSgpudFRXBdo6rAWD)ty)1qsT8AFPCAWtBHtdJh2FnEOge(K3H0Wkqnk4Rb8MgNjlVfovAZ9lSqcdsTc41ONymBszMn0fo)ogLEBWrpcqPUyZaouEi0PXZiS)2qPhMaxYhPWdwKmXyP3gC0JeO3M8o0L4pwto5ojhaypW3ZzHZsB5ed1yBH8rQ298KGVNZcNL2Yj6YhvP9vePrleI3ASzn2cTGKgwPbE7yRmI0WkqnyBrASVgDzn4U)PgMgxrNHSrd5b60WkqnAjOj)7nPbhU20OsBUFHfsyqQvaVo3h)jyorSErxSzajhBLrKyRKv(XAYj3j5aalFpNfYZ2ahW1yjBCwTUKCNHSrCBSoDjgWt7ypacFHbAY)EtjexBAsGwJHJe)6aylCEEs4G3uz1lkYnqgCa98qYeJLEBWrpYhmCe7b(Eolg7MkyhLYdvs2VyOgBl0Lx9vDapy00lkdhCKaTvUZsN(rpnRDelFpNfJDtfSJs5Hkj7x0L98KGVNZIXUPc2rP8qLK9l6YhXEqcheYaHClHZsB5eDzpp(Eol(ZzzSeIiaOrGEZbWLsHhS5f35NgQX2cDjgAVDS5f35NgQX2c5JuT3UNNeiyNXVfO4pNLXsiIaGgbvgpJapI9ac2z8Bbk(ZzzSeIiaOrqLXZiqppheYaHClHZsB5ed1yBH8X3TFuL2xrKgMgCEBYgJPXvEr)PgYd0PrVyecPbN3MSXyASinm2qgOFn6YAahn8d7AydPHXd7Vgpud4nnotwJwIUcvAZ9lSqcdsTc41O3MSXyxSza575Saw0FIsY04i5FHLOlJ9aFpNfO3MSXyIHYdHonEg55zOFmwsgYLgFU62pQs3c6nYA0s0vObpLHdPHKG1neasdU7FQbN3MSXyAyfOg)jvAW5Tb1hCKkT5(fwiHbPwb8A0Bt2ySl2mGo4nvw9IAXD(PSryL4ngvVa9eJztcC28lOY4zei2d32SgpJeoyDdbGsGeYF588CqideYTeolTLt0L98475SWzPTCIU8rSoiKbc5wchSUHaqP)Ksi5D2hjgQX2cDjohOOXWhg5OLDWq)ySKmKlnyg80(rS89CwGEBYgJjgQX2cDj(JvcWPVGIcMCGivAZ9lSqcdsTc41O3guFWrxSzaDWBQS6f1I78tzJWE42M14zKWbRBiaucKq(lNNNdczGqULWzPTCIUSNhFpNfolTLt0LpI1bHmqi3s4G1neak9NucjVZ(iXqn2wOlX4y575Sa92Kngt0LXso2kJiXwjR8JvIBBwJNrIfxbhkHEBq9bhHvcWPVGIcMCGivAFfrAW5Tb1hCKgC3)udR04kVO)ud5b60aoASzn8d7Tbud4nnotwJwIUcn4U)Pg(H9rJIW3RHZqVqJwYqqna7nYA0s0vOH9A8NKgubQbmRXFsAGzNQ)0)ObFpN1yZAW5TjBmMgCHDgy1MxJSXyAaZznGJg(HDnSH0awAGbnEBWrpsL2C)clKWGuRaEn6Tb1hC0fBgq(EolGf9NOKJr2KUx0clrx2Z7GeO3M8oKWKtUtYbawjUTznEgjwCfCOe6Tb1hCKN3b(EolCwAlNyOgBl0L4blFpNfolTLt0L98oCGVNZcNL2YjgQX2cDjohOOXWhg5OLDWq)ySKmKlnygF3(rS89Cw4S0worx2ZJVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIHASTqxIZbkAm8HroAzhm0pgljd5sdMX3TFelFpNfJDtfSJs5Hkj7pH2k3zPt)ONM1eD5JyDWBQS6f3u9N(NJhXEajtmw6Tbh9ib6TjBm2L(2Z72M14zKa92KnglXfwFkBmwcMZhpIvIBBwJNrIfxbhkHEBq9bhH9GetVOmCWrIFBiUWPsGdzn8BbsJNhsMyS0Bdo6rc0Bt2ySl99rvAFfrACLbHfsJT0GdKzJg4TJTYisdRa1az3KgTWoJPXvgewAKHJgsQLx7lLtL2C)clKWGuRaEDrCtnqyDXMb8aFpNfKJTYikHGmBed1yBH8HWh56pL(TH88o4oTbhHaedyhYDAdok9BdDjEo655oTbhHa03hXAYj3j5aqL2C)clKWGuRaE9PXYPgiSUyZaEGVNZcYXwzeLqqMnIHASTq(q4JC9Ns)2qEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaG9aFpNfJDtfSJs5Hkj7xmuJTf6s8GLVNZIXUPc2rP8qLK9l6YyLy6fLHdosG2k3zPt)ONM188KGVNZIXUPc2rP8qLK9l6YhvPn3VWcjmi1kGxN7mwQbcRl2mGh475SGCSvgrjeKzJyOgBlKpe(ix)P0Vne2doiKbc5wcNL2YjgQX2c5dEA3ZZbHmqi3s4G1neak9NucjVZ(iXqn2wiFWt7h98o4oTbhHaedyhYDAdok9BdDjEo655oTbhHa03hXAYj3j5aa7b(Eolg7MkyhLYdvs2VyOgBl0L4blFpNfJDtfSJs5Hkj7x0LXkX0lkdhCKaTvUZsN(rpnR55jbFpNfJDtfSJs5Hkj7x0LpQs7RisdmliERbS0qsTavAZ9lSqcdsTc41CTzw4KG5eX6fPsljJ56m7jKgCpP)KgnEOgDePbN3M8oKgBPbhiZgn4EUUtnwKg2RbE04Tbh9OwLsJmC0GUPXVgyODmJgng6PXVgWrd8xdoVnO(GJ0aVBKHCPPHQxd0BoaqQ0M7xyHegKAfWRVTznEgDrzneGO3M8ouARecYS5IBJ1jarYeJLEBWrpsGEBY7q(G)TMzq4COXqpn(t3gRtyKuT3oMbdTFS1mdcNd89CwGEBq9bhLOgzixAAO6tiiZgb6nhayg8)OkTKmMRZSNqAW9K(tA04HAGzn2FQbyF2cNgTWHkj7xL2C)clKWGuRaE9TnRXZOlkRHaK7y)zARuEOsY(V42yDcqPWmizIXsNg6PlXWvDODbgWOdizIXsVn4OhjqVn5DORsQJy0bPA9ngvVab7SemN(tkLHdHEbvgpJaXiPe454XwBxifEWi(Eolg7MkyhLYdvs2VyOgBlKkTVIinWSg7p1yln4az2ObE7yRmI0aoASznkOgCEBY7qAWDzmnY7RXwpudj1YR9LYPHv(BGdPsBUFHfsyqQvaVM7y)5fBgWdKJTYisW6LnPIW375ro2kJiHv(tfHVh7TnRXZiXIsogz30rShEBWrV43gk9We4s(G)EEKJTYisW6LnPTsyWZlV4o)0qn2wOlLQ9JEE89Cwqo2kJOecYSrmuJTf6sZ9lSeO3M8oKGWh56pL(THWY3Zzb5yRmIsiiZgrx2ZJCSvgrITsiiZgSsCBZA8msGEBY7qPTsiiZgpp(EolCwAlNyOgBl0LM7xyjqVn5DibHpY1Fk9BdHvIBBwJNrIfLCmYUjS89Cw4S0woXqn2wOlj8rU(tPFBiS89Cw4S0worx2ZJVNZIXUPc2rP8qLK9l6YyVTznEgj4o2FM2kLhQKSFppjUTznEgjwuYXi7MWY3ZzHZsB5ed1yBH8HWh56pL(THuP9vePbN3M8oKgBwJT0Of7LnAG3o2kJOl0yln4az2ObE7yRmI0awAG)TQXBdo6rAahnEOgYd0PbhiZgnWBhBLrKkT5(fwiHbPwb8A0BtEhsLUfAm2FoDvAZ9lSqcdsTc41tVsM7xyLyl6VOSgcWSXy)50vPvPBHdvs2VgC3)udj1YR9LYPsBUFHfsWdThWXUPc2rP8qLK9FXMbKVNZcNL2YjgQX2c5Ju4rL2xrKgTe0K)9M0GdxBA0G7jvAyVgmcH04pTsd8xdmf2smrd0BoaqAyfOgpuJHYdHo1W04saXGgO3CaOHH0GzpPHH0qgIqlpJ0aoA8BdPX(AGGASVg2m7nH0aZMo61WYpnAyA47w1a9Mdani8jVdHuPn3VWcj4H23kGxBGM8V3ucX1MMlC(Dmk92GJEeGsDXMbKVNZcEJzLJsWCYyS0FUfouQSVpKa9MdGlBlS89CwWBmRCucMtgJL(ZTWHs24SIeO3CaCzBH9GeGWxyGM8V3ucX1MMeO1y4iXVoa2chwjm3VWsyGM8V3ucX1MMeO1y4iXwPmBXD(ypibi8fgOj)7nLqCTPjDsgt8RdGTW55bcFHbAY)EtjexBAsNKXed1yBH8X3h98aHVWan5FVPeIRnnjqRXWrc0BoaU03ybHVWan5FVPeIRnnjqRXWrIHASTqxIhSGWxyGM8V3ucX1MMeO1y4iXVoa2c3rvAFfrAijyDdbG0G7(NAiPwETVuon4EsLgYqeA5zKgwbQb8pPH7Iin4U)PgMgykSLyIg89CwdUNuPbiH8xUTWPsBUFHfsWdTVvaV2bRBiau6pPesEN9rxSzaLaC6lOOGjhic7Hd32SgpJeoyDdbGsGeYF5WkHdczGqULWzPTCIHmq)EE89Cw4S0worx(i2d89CwWBmRCucMtgJL(ZTWHsL99HeO3CaayB55X3ZzbVXSYrjyozmw6p3chkzJZksGEZbaGT1rppEicHnV4o)0qn2wOlLQDSoiKbc5wcNL2YjgQX2c5dg7OkDleI3Ayin(tsJ8oOxdCoqn2sJ)K0W0atHTet0G7wGqUAahn4U)Pg)jPXvc)ZALg89Cwd4Ob39p1W0OTAfronAjOj)7nPbhU20OHvGAW12xJmC0qsT8AFPCASzn2xdUW61GN0OlRHHZ2sdEkdhsJ)K0WbQXI0iV1IojqvAZ9lSqcEO9Tc415(4pbZjI1l6Ind4Hdh475SG3yw5OemNmgl9NBHdLk77djqV5aWhmUNhFpNf8gZkhLG5KXyP)ClCOKnoRib6nha(GXpI9Geo4nvw9IBQ(t)JNNe89Cwm2nvWokLhQKSFrx(4rShaN(ckkyYbI88CqideYTeolTLtmuJTfYh80UN3bh8MkRErT4o)u2iSoiKbc5wchSUHaqP)Ksi5D2hjgQX2c5dEA)4XJEEhaHVWan5FVPeIRnnjqRXWrIHASTq(0wyDqideYTeolTLtmuJTfYhPAhRdEtLvVOi3azWb8ON3wpnYqM9eykV4o)0qn2wOlBlSs4GqgiKBjCwAlNyid0VNNdEtLvVaa)ZAfw(EolaylWHatuJmKlnnu9IUSNNdEtLvV4MQ)0)GLVNZIXUPc2rP8qLK9lgQX2cD5vJLVNZIXUPc2rP8qLK9l6YQ0sYkhX0GZBddoGAWD)tnmnkIRgykSLyIg89CwdRa1qsT8AFPCASOQnVggpS)A8qn4jn6icuL2C)clKGhAFRaETZkhXs89C(IYAiarVnm4aEXMb8aFpNf8gZkhLG5KXyP)ClCOuzFFiXqn2wiFWyc845X3ZzbVXSYrjyozmw6p3chkzJZksmuJTfYhmMaphXEWbHmqi3s4S0woXqn2wiFWyEEhCqideYTeuJmKlnjEybkgQX2c5dgdRe89CwaWwGdbMOgzixAAO6turdUvYKOlJ1bVPYQxaG)zT64rSg6hJLKHCPXha9D7Q0TGEJSgCEBq9bhH0G7(NAyAGPWwIjAW3Zzn47Vgf81G7jvAidHSTWPrgoAiPwETVuonGJgxj2cCiqn4iVZ(ivA3VWcj4H23kGxJEBq9bhDXMb8aFpNf8gZkhLG5KXyP)ClCOuzFFib6nha(Gbpp(Eol4nMvokbZjJXs)5w4qjBCwrc0Boa8bdhXE4Geo4nvw9IAXD(PSrEEg6hJLKHCPXhaX)2pI1bHmqi3s4S0woXqn2wiFWyEEsCBZA8ms4atoybU)clSs4G3uz1laW)Sw55DWbHmqi3sqnYqU0K4HfOyOgBlKpymSsW3ZzbaBboeyIAKHCPPHQprfn4wjtIUmwh8MkREba(N1QJhXEqcq4lY9XFcMteRxK4xhaBHZZtcheYaHClHZsB5edzG(98KWbHmqi3s4G1neak9NucjVZ(iXqgO)JQ0TGEJSgCEBq9bhH0GNYWH0qsW6gcaPsBUFHfsWdTVvaVg92G6do6Ind4bheYaHClHdw3qaO0FsjK8o7Jed1yBHUepyLaC6lOOGjhic7HBBwJNrchSUHaqjqc5VCEEoiKbc5wcNL2YjgQX2cDjEoI92M14zKWbMCWcC)fwhXkbi8f5(4pbZjI1ls8RdGTWH1bVPYQxulUZpLncReGtFbffm5aryjhBLrKyRKv(XAOFmwsgYLgFW)2vPBbWQnVgGWxdW(Sfon(tsdQa1aM14k1UPc2rA0chQKS)l0aSpBHtda2cCiqnOgzixAAO61aoASLg)jPbZqVg4CGAaZAyLg4TJTYisL2C)clKGhAFRaE9TnRXZOlkRHaee(PHWR(oudvp6IBJ1japW3ZzXy3ub7OuEOsY(fd1yBH8bpEEsW3ZzXy3ub7OuEOsY(fD5JypW3ZzbaBboeyIAKHCPPHQprfn4wjtIHASTqxIZbkAm8De7b(EolihBLrucbz2igQX2c5dohOOXWNNhFpNfKJTYikX6LnIHASTq(GZbkAm8DuL2C)clKGhAFRaEnQx5DOlC(Dmk92GJEeGsDXMbCO8qOtJNryFBWrV43gk9We4s(ifghRjNCNKdaS32SgpJeGWpneE13HAO6rQ0M7xyHe8q7BfWRBGWkVdDHZVJrP3gC0JauQl2mGdLhcDA8mc7Bdo6f)2qPhMaxYhP8Tapyn5K7KCaG92M14zKae(PHWR(oudvpsL2C)clKGhAFRaEn6jgZMuMzdDHZVJrP3gC0JauQl2mGdLhcDA8mc7Bdo6f)2qPhMaxYhPW4TouJTfcRjNCNKdaS32SgpJeGWpneE13HAO6rQ0TqiMRbS0WbQb39pH9xdNjlVfovAZ9lSqcEO9Tc41z44OemNk77dDXMb0KtUtYbGknE3id5sJgykSa1G7jvAy8W(RXd1GQNgnmnkIRgykSLyIgC3ceYvdRa1az3Kgz4OHKA51(s5uPn3VWcj4H23kGxtnYqU0K4Hf4fBgWdKJTYisW6LnPIW375ro2kJibcYSjve(EppYXwzejSYFQi89EE89CwWBmRCucMtgJL(ZTWHsL99Hed1yBH8bJjWJNhFpNf8gZkhLG5KXyP)ClCOKnoRiXqn2wiFWyc845zOFmwsgYLgFU62X6GqgiKBjCwAlNyid0pwjaN(ckkyYbIoI9GdczGqULWzPTCIHASTq(47298CqideYTeolTLtmKb6)ONhpeHWU1tJmKzpbMYlUZpnuJTf6sPAxLUfcXBnMf35RbpLHdPrhTfonKulvPn3VWcj4H23kGxN7J)emNiwVOl2mGoiKbc5wcNL2YjgYa9J92M14zKWbMCWcC)fwypyOFmwsgYLgFU62XkHdEtLvVOwCNFkBKNNdEtLvVOwCNFkBewd9JXsYqU0Cj(3(rSs4G3uz1lUP6p9pypiHdEtLvVOwCNFkBKNNdczGqULWbRBiau6pPesEN9rIHmq)hXkb40xqrbtoqKkTKA51(s50G7jvAyVgxD7TQrlrxHghGddYLgn(tR0a)BxJwIUcn4U)Pgscw3qaOJAWD)ty)1GbrBHtJFBin2sdmLbHGSo61WkqnyBrA0L1G7(NAijyDdbG0yZASVgCnKgGeYF5iqvAZ9lSqcEO9Tc4132SgpJUOSgcqhyYblW9xyL4H2FXTX6eGsao9fuuWKdeH92M14zKWbMCWcC)fwypCWq)ySKmKln(C1TJ9aFpNfaSf4qGjQrgYLMgQ(ev0GBLmj6YEEs4G3uz1laW)SwD0ZJVNZcEgecY6Ox0LXY3ZzbpdcbzD0lgQX2cDjFpNfolTLta2h7xyD0ZJhIqy36PrgYSNat5f35NgQX2cDjFpNfolTLta2h7xy555G3uz1lQf35NYgDe7bjCWBQS6f1I78tzJ88oyOFmwsgYLMlX)298aHVi3h)jyorSErIFDaSfUJypCBZA8ms4G1neakbsi)LZZZbHmqi3s4G1neak9NucjVZ(iXqgO)JhvPn3VWcj4H23kGx7igH(1yjJT4QgQ(l2mG32SgpJeoWKdwG7VWkXdTxL2C)clKGhAFRaE9woBk7xyDXMb82M14zKWbMCWcC)fwjEO9Q04n63g7jKgNqUA00DNA0s0vOHnKg4STiqnKPrde5GfOkT5(fwibp0(wb86BBwJNrxuwdbOHKVcA4qUlUnwNaKCSvgrITsSEzdg1wygZ9lSeO3M8oKGWh56pL(THAvcYXwzej2kX6Lny0bmERVXO6fiyNLG50FsPmCi0lOY4zeig57JygZ9lSeCh7pfe(ix)P0VnuRTlWaMbjtmw60qpPs3c6nYAW5Tb1hCesdUNuPXFsAKxCNVglsdJh2FnEOgubEHg5Hkj7xJfPHXd7VgpudQaVqd)WUg2qAyVgxD7TQrlrxHgBPHvAG3o2kJOl0qsT8AFPCAWm0J0Wk4FsJgTvRiYH0aoA4h21GlSZa1aEtJZK1OboKg)PvAOEs1UgTeDfAW9Kkn8d7AWf2zGvBEn482G6dosJcYvL2C)clKGhAFRaEn6Tb1hC0fBgWd8qec7wpnYqM9eykV4o)0qn2wOlXFpVd89Cwm2nvWokLhQKSFXqn2wOlX5afng(WihTSdg6hJLKHCPbZ472pILVNZIXUPc2rP8qLK9l6Yhp65DWq)ySKmKlnTEBZA8msyi5RGgoKdJ475SGCSvgrjeKzJyOgBluRGWxK7J)emNiwViXVoaqPHASTWimiWJpsjv7EEg6hJLKHCPP1BBwJNrcdjFf0WHCyeFpNfKJTYikX6LnIHASTqTccFrUp(tWCIy9Ie)6aaLgQX2cJWGap(iLuTFel5yRmIeBLSYp2dsW3ZzHZsB5eDzppjEJr1lqVnm4akOY4ze4rShoiHdczGqULWzPTCIUSNNdEtLvVaa)ZAfwjCqideYTeuJmKlnjEybk6Yh98CWBQS6f1I78tzJoI9Geo4nvw9IBQ(t)JNNe89Cw4S0worx2ZZq)ySKmKln(C1TF0Z7WBmQEb6THbhqbvgpJaXY3ZzHZsB5eDzSh475Sa92WGdOa9MdGl9TNNH(XyjzixA85QB)4rpp(EolCwAlNOlJvc(Eolg7MkyhLYdvs2VOlJvI3yu9c0BddoGcQmEgbQs7RisJRmiSqASLgTyVSrd82XwzePHvGAGSBsJRKnwU1wyNX04kdclnYWrdj1YR9LYPsBUFHfsWdTVvaVUiUPgiSUyZaEGVNZcYXwzeLy9YgXqn2wiFi8rU(tPFBipVdUtBWriaXa2HCN2GJs)2qxINJEEUtBWria99rSMCYDsoauPn3VWcj4H23kGxFASCQbcRl2mGh475SGCSvgrjwVSrmuJTfYhcFKR)u63gc7bheYaHClHZsB5ed1yBH8bpT755GqgiKBjCW6gcaL(tkHK3zFKyOgBlKp4P9JEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaOsBUFHfsWdTVvaVo3zSudewxSzapW3Zzb5yRmIsSEzJyOgBlKpe(ix)P0Vne2doiKbc5wcNL2YjgQX2c5dEA3ZZbHmqi3s4G1neak9NucjVZ(iXqn2wiFWt7h98o4oTbhHaedyhYDAdok9BdDjEo655oTbhHa03hXAYj3j5aqLgZcI3AalnCGQ0M7xyHe8q7BfWR5AZSWjbZjI1lsL2xrKgCEBY7qA8qnKhOtdoqMnAG3o2kJinGJgCpPsJT0awm)A0I9YgnWBhBLrKgwbQrhrAGzbXBnKhOdPXM1ylnAXEzJg4TJTYisL2C)clKGhAFRaEn6TjVdDXMbKCSvgrITsSEzJNh5yRmIeiiZMur4798ihBLrKWk)PIW375X3ZzbxBMfojyorSErIUmw(EolihBLruI1lBeDzpVd89Cw4S0woXqn2wOln3VWsWDS)uq4JC9Ns)2qy575SWzPTCIU8rvAZ9lSqcEO9Tc41Ch7pvPn3VWcj4H23kGxp9kzUFHvITO)IYAiaZgJ9NtxLwLMZBdQp4inYWrJg4n1q1RrVyecPrhTfonWuylXevAZ9lSqISXy)50be92G6do6IndOetVOmCWrcEJzLJsWCYyS0FUfoKGWR(kltGQ0sYqVg)jPbi81G7(NA8NKgnq0RXVnKgpuddeuJE9ltJ)K0OXWNgG9X(fwASino3xObNEL3H0yOgBlKgnD2VYSLa14HA0yV7uJgiSY7qAa2h7xyPsBUFHfsKng7pNERaEnQx5DOlC(Dmk92GJEeGsDXMbee(IgiSY7qIHASTq(muJTfcJWagWms1wQ0M7xyHezJX(ZP3kGx3aHvEhsLwL2xrKgCEBq9bhPXd1aaIK1OlRXFsA0cgYA43cKgn475SgBwJ91GlSZa1GWN8oKg8ugoKg5Tw05w404pjnkcFVgod9AahnEOgG9gzn4PmCinKeSUHaqQ0M7xyHeOhq0BdQp4Ol2mGtVOmCWrIFBiUWPsGdzn8Bbsd2dKJTYisSvYk)yL4Wb(Eol(TH4cNkboK1WVfinIHASTq(yUFHLG7y)PGWh56pL(THATDHuypqo2kJiXwjE4F65ro2kJiXwjeKzJNh5yRmIeSEztQi89h98475S43gIlCQe4qwd)wG0igQX2c5J5(fwc0BtEhsq4JC9Ns)2qT2UqkShihBLrKyReRx245ro2kJibcYSjve(EppYXwzejSYFQi89hp65jbFpNf)2qCHtLahYA43cKgrx(ON3b(EolCwAlNOl75DBZA8ms4G1neakbsi)L7iwheYaHClHdw3qaO0FsjK8o7JedzG(X6G3uz1lQf35NYgDe7bjCWBQS6fa4FwR88CqideYTeuJmKlnjEybkgQX2c5tBDe7b(EolCwAlNOl75jHdczGqULWzPTCIHmq)hvP9vePrlbn5FVjn4W1Mgn4EsLg)jnKglsJcQH5(9M0aX1MMl0WqAWSN0WqAidrOLNrAalnqCTPrdU7FQbg0aoAKjU0Ob6nhainGJgWsdtdF3QgiU20ObcQXFAVg)jPrrC1aX1MgnSz2BcPbMnD0RHLFA04pTxdexBA0GWN8oesL2C)clKa9Tc41gOj)7nLqCTP5cNFhJsVn4OhbOuxSzaLae(cd0K)9MsiU20KaTgdhj(1bWw4WkH5(fwcd0K)9MsiU20KaTgdhj2kLzlUZh7bjaHVWan5FVPeIRnnPtYyIFDaSfoppq4lmqt(3BkH4Att6KmMyOgBlKp45ONhi8fgOj)7nLqCTPjbAngosGEZbWL(gli8fgOj)7nLqCTPjbAngosmuJTf6sFJfe(cd0K)9MsiU20KaTgdhj(1bWw4uP9veH0qsW6gcaPXM1qsT8AFPCASin6YAahn8d7AydPbiH8xUTWPHKA51(s50G7(NAijyDdbG0Wkqn8d7AydPbpXGC1a)BxJwIUcvAZ9lSqc03kGx7G1neak9NucjVZ(Ol2mGsao9fuuWKdeH9WHBBwJNrchSUHaqjqc5VCyLWbHmqi3s4S0woXqgOFSsm9IYWbhjKNTboGRXs24SADj5odzJNhFpNfolTLt0LpI1q)ySKmKlnxci(3o2d89Cwqo2kJOeRx2igQX2c5JuT75X3Zzb5yRmIsiiZgXqn2wiFKQ9JEE8qecBEXD(PHASTqxkv7yLWbHmqi3s4S0woXqgO)JQ0scwG7VWsJmC0WymnaHpsJ)0EnAmaiKgO(qA8NKFnSHQ28AmuEi0jbQb3tQ04k1UPc2rA0chQKSFnonKgmcH04pTsd8ObICingQX2AlCAahn(tsda8pRvAW3ZznwKggpS)A8qnYgJPbmN1aoAyLFnWBhBLrKglsdJh2FnEOge(K3HuPn3VWcjqFRaE9TnRXZOlkRHaee(PHWR(oudvp6IBJ1japW3ZzXy3ub7OuEOsY(fd1yBH8bpEEsW3ZzXy3ub7OuEOsY(fD5JyLGVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIUm2d89CwaWwGdbMOgzixAAO6turdUvYKyOgBl0L4CGIgdFhXEGVNZcYXwzeLqqMnIHASTq(GZbkAm855X3Zzb5yRmIsSEzJyOgBlKp4CGIgdFEEhKGVNZcYXwzeLy9Ygrx2Ztc(EolihBLrucbz2i6YhXkXBmQEbcYq)6ibvgpJapQsljybU)cln(t71WDsoaqASzn8d7AydPbS)OfK0GCSvgrA8qnGfZVgGWxJ)Kgsd4OXIRGdPXFUin4U)PgCGm0VosL2C)clKa9Tc4132SgpJUOSgcqq4NG9hTGuICSvgrxCBSob4bj475SGCSvgrjeKzJOlJvc(EolihBLruI1lBeD5JEEVXO6fiid9RJeuz8mcuL2C)clKa9Tc41nqyL3HUW53XO0Bdo6rak1fBgWHYdHonEgH9aFpNfKJTYikHGmBed1yBH8zOgBlKNhFpNfKJTYikX6LnIHASTq(muJTfYZ72M14zKae(jy)rliLihBLr0rSdLhcDA8mc7Bdo6f)2qPhMaxYhPWawto5ojhayVTznEgjaHFAi8QVd1q1JuPn3VWcjqFRaEnQx5DOlC(Dmk92GJEeGsDXMbCO8qOtJNrypW3Zzb5yRmIsiiZgXqn2wiFgQX2c55X3Zzb5yRmIsSEzJyOgBlKpd1yBH88UTznEgjaHFc2F0csjYXwzeDe7q5HqNgpJW(2GJEXVnu6HjWL8rkmG1KtUtYba2BBwJNrcq4NgcV67qnu9ivAZ9lSqc03kGxJEIXSjLz2qx487yu6Tbh9iaL6Ind4q5HqNgpJWEGVNZcYXwzeLqqMnIHASTq(muJTfYZJVNZcYXwzeLy9YgXqn2wiFgQX2c55DBZA8msac)eS)OfKsKJTYi6i2HYdHonEgH9Tbh9IFBO0dtGl5JuyCSMCYDsoaWEBZA8msac)0q4vFhQHQhPs7RisJwieZ1awA4a1G7(NW(RHZKL3cNkT5(fwib6BfWRZWXrjyov23h6IndOjNCNKdavAFfrACLylWHa1GJ8o7J0G7(NAyLFnyWcNgub74o1GzOFlCAG3o2kJinScuJF8RXd1GTfPX(A0L1G7(NACfDgYgnScudj1YR9LYPsBUFHfsG(wb8AQrgYLMepSaVyZaE4aFpNfKJTYikHGmBed1yBH8rQ298475SGCSvgrjwVSrmuJTfYhPA)iwheYaHClHZsB5ed1yBH8X3TJ9aFpNfYZ2ahW1yjBCwTUKCNHSrCBSoDjgW)298Ky6fLHdosipBdCaxJLSXz16sYDgYgbHx9vwMapE0ZJVNZc5zBGd4ASKnoRwxsUZq2iUnwN8bqmGXA3ZZbHmqi3s4S0woXqgOFSg6hJLKHCPXNRUDvAFfrAiPwETVuon4U)Pgscw3qaORVsSf4qGAWrEN9rAyfOgGWQnVgWBA4o7tACfDgYgnGJgCpPsdmLbHGSo61GlSZa1GWN8oKg8ugoKgsQLx7lLtdcFY7qivAZ9lSqc03kGxFBZA8m6IYAiaDGjhSa3FHvc9xCBSobOeGtFbffm5aryVTznEgjCGjhSa3FHf2dhCqideYTeuJS)HmwcoGLvosmuJTf6sPW4ySwpiLuy00lkdhCKaTvUZsN(rpnRDelHx9vwMafuJS)HmwcoGLvo6ONNH(XyjzixA8bWRUDShK4ngvVi3h)jyorSErcQmEgb65X3ZzHZsB5eG9X(fw(4GqgiKBjY9XFcMteRxKyOgBluRT1rSGWxG6vEhsmuJTfYhPWawq4lAGWkVdjgQX2c5tBH9ai8fONymBszMnKyOgBlKpTLNNeVXO6fONymBszMnKGkJNrGhXEBZA8ms8NZYyjeraqtIRTp2d89CwaWwGdbMOgzixAAO6turdUvYKOl75jHdEtLvVaa)ZA1rSVn4Ox8BdLEycCjF475SWzPTCcW(y)clmQDbgZZJhIqyZlUZpnuJTf6s(EolCwAlNaSp2VWYZZbVPYQxulUZpLnYZJVNZcEgecY6Ox0LXY3ZzbpdcbzD0lgQX2cDjFpNfolTLta2h7xy16HRgJMErz4GJeYZ2ahW1yjBCwTUKCNHSrq4vFLLjWJhXkbFpNfolTLt0LXEqch8MkRErT4o)u2ippheYaHClHdw3qaO0FsjK8o7JeDzppEicHnV4o)0qn2wOlDqideYTeoyDdbGs)jLqY7SpsmuJTfQvmUNxEXD(PHASTqygmJuTv7xY3ZzHZsB5eG9X(fwhvPn3VWcjqFRaE9TnRXZOlkRHa0bMCWcC)fwj0FXTX6eGsao9fuuWKdeH92M14zKWbMCWcC)fwypCWbHmqi3sqnY(hYyj4aww5iXqn2wOlLcJJXA9GusHrtVOmCWrc0w5olD6h90S2rSeE1xzzcuqnY(hYyj4aww5OJEEg6hJLKHCPXhaV62XEqI3yu9ICF8NG5eX6fjOY4zeONhFpNfolTLta2h7xy5JdczGqULi3h)jyorSErIHASTqT2whXccFbQx5DiXqn2wiFAlSGWx0aHvEhsmuJTfYNRg7bq4lqpXy2KYmBiXqn2wiFKQDppjEJr1lqpXy2KYmBibvgpJapI92M14zK4pNLXsiIaGMexBFSh475SaGTahcmrnYqU00q1NOIgCRKjrx2Ztch8MkREba(N1QJyFBWrV43gk9We4s(W3ZzHZsB5eG9X(fwyu7cmMNhpeHWMxCNFAOgBl0L89Cw4S0wobyFSFHLNNdEtLvVOwCNFkBKNhFpNf8mieK1rVOlJLVNZcEgecY6OxmuJTf6s(EolCwAlNaSp2VWQ1dxngn9IYWbhjKNTboGRXs24SADj5odzJGWR(kltGhpIvc(EolCwAlNOlJ9Geo4nvw9IAXD(PSrEEoiKbc5wchSUHaqP)Ksi5D2hj6YEE8qecBEXD(PHASTqx6GqgiKBjCW6gcaL(tkHK3zFKyOgBluRyCppEicHnV4o)0qn2wimdMrQ2Q9l575SWzPTCcW(y)cRJQ0(kI04pjnWSt1F6F0G7(NAyAiPwETVuon(t71yrvBEnYdSrJROZq2OsBUFHfsG(wb86XUPc2rP8qLK9FXMbKVNZcNL2YjgQX2c5Ju4XZJVNZcNL2Yja7J9lSU03ya7TnRXZiHdm5Gf4(lSsOxL2C)clKa9Tc41oIrOFnwYylUQHQ)Ind4TnRXZiHdm5Gf4(lSsOh7b(EolCwAlNaSp2VWYha9ng88KWbVPYQxCt1F6Fo65X3ZzXy3ub7OuEOsY(fDzS89Cwm2nvWokLhQKSFXqn2wOlV6wDWcSVVqEi3IOKXwCvdvV43gkDBSo16bj475SGNbHGSo6fDzSs8gJQxGEByWbuqLXZiWJQ0M7xyHeOVvaVElNnL9lSUyZaEBZA8ms4atoybU)cRe6vPXSBZA8msJoIa1awAy8lB)LqA8N2RbxREnEOg8Kgi7Ma1idhnKulV2xkNgiOg)P9A8NKFnSHQxdUg6jqnWSPJEn4PmCin(tQrL2C)clKa9Tc4132SgpJUOSgcqKDtPmCsolTL7IBJ1jaLWbHmqi3s4S0woXqgOFppjUTznEgjCW6gcaLajK)YH1bVPYQxulUZpLnYZdC6lOOGjhisL2xresJwieV1yZASLgwPbE7yRmI0Wkqn(zjKgpud2wKg7RrxwdU7FQXv0ziBUqdj1YR9LYPHvGA0sqt(3BsdoCTPrL2C)clKa9Tc415(4pbZjI1l6Indi5yRmIeBLSYpwto5ojhay575SqE2g4aUglzJZQ1LK7mKnIBJ1PlXa(3o2dGWxyGM8V3ucX1MMeO1y4iXVoa2cNNNeo4nvw9IICdKbhWJyVTznEgjq2nLYWj5S0woSh475SySBQGDukpujz)IHASTqxE1x1b8GrtVOmCWrc0w5olD6h90SwRsq4vFLLjqXwOF6UhoOe4EVfL4jg7iw(Eolg7MkyhLYdvs2VOl75jbFpNfJDtfSJs5Hkj7x0LpQs7RisJR8I(tn482Kngtd5b6qASzn482KngtJfvT51OlRsBUFHfsG(wb8A0Bt2ySl2mG89Cwal6prjzACK8VWs0LXY3Zzb6TjBmMyO8qOtJNrQ0M7xyHeOVvaV2zLJyj(EoFrzneGO3ggCaVyZaY3Zzb6THbhqXqn2wOlXd2d89Cwqo2kJOecYSrmuJTfYh845X3Zzb5yRmIsSEzJyOgBlKp45iwd9JXsYqU04Zv3UkDlO3iJ0OLORqdEkdhsdjbRBiaKgD0w404pjnKeSUHaqA4Gf4(lS04HA4ojhaASznKeSUHaqASinm33ngZVggpS)A8qn4jnCg6vPn3VWcjqFRaEn6Tb1hC0fBgqh8MkRErT4o)u2iS32SgpJeoyDdbGsGeYF5W6GqgiKBjCW6gcaL(tkHK3zFKyOgBl0L4bReGtFbffm5aryjhBLrKyRKv(XAOFmwsgYLgFW)2vP9vePbN3MSXyAWD)tn48eJzJgTGzZVgwbQrb1GZBddoGxOb3tQ0OGAW5TjBmMglsJU8fA4h21WgsJT0Of7LnAG3o2kJinYWrJ2Qve5qAahnEOgYd0PXv0ziB0G7jvAy8WBsJRUDnAj6k0aoAyGY2V3KgiU20OXPH0OTAfroKgd1yBTfonGJglsJT0iZwCNVqdmh(Kg)P9A0lqA04pjnqwdPHdwG7VWcPX(TbPbOmsJI6)ymnEOgCEBYgJPbyF2cNgxP2nvWosJw4qLK9FHgCpPsd)WEBa1a9lJPbvGA0L1G7(NAC1T3QHK1idhn(tsdMHEnWXG8gdjuPn3VWcjqFRaEn6TjBm2fBgW3yu9c0tmMnjWzZVGkJNrGyL4ngvVa92WGdOGkJNrGy575Sa92KngtmuEi0PXZiSh475SGCSvgrjwVSrmuJTfYN2cl5yRmIeBLy9YgS89CwipBdCaxJLSXz16sYDgYgXTX60LyapT75X3ZzH8SnWbCnwYgNvRlj3ziBe3gRt(aigWt7yn0pgljd5sJpxD7EEGWxyGM8V3ucX1MMeO1y4iXqn2wiFAlppZ9lSegOj)7nLqCTPjbAngosSvkZwCN)rSoiKbc5wcNL2YjgQX2c5JuTRs7RisdoVnO(GJ04kVO)ud5b6qAyfOgG9gznAj6k0G7jvAiPwETVuonGJg)jPbMDQ(t)Jg89CwJfPHXd7VgpuJSXyAaZznGJg(H92aQHZK1OLORqL2C)clKa9Tc41O3guFWrxSza575Saw0FIsogzt6ErlSeDzpp(EolaylWHatuJmKlnnu9jQOb3kzs0L98475SWzPTCIUm2d89Cwm2nvWokLhQKSFXqn2wOlX5afng(WihTSdg6hJLKHCPbZ472p2QVXO3yu9II4MAGWsqLXZiqSsm9IYWbhjqBL7S0PF0tZAy575SySBQGDukpujz)IUSNhFpNfolTLtmuJTf6sCoqrJHpmYrl7GH(XyjzixAWm(U9JEE89Cwm2nvWokLhQKS)eARCNLo9JEAwt0L98oW3ZzXy3ub7OuEOsY(fd1yBHU0C)clb6TjVdji8rU(tPFBiSizIXsNg6PlBxG)EE89Cwm2nvWokLhQKSFXqn2wOln3VWsWDS)uq4JC9Ns)2qEE32SgpJelEbMCWcC)fwyDqideYTeBHCt)nEgLWRUvFVjbs3RJedzG(Xs4vFLLjqXwi30FJNrj8QB13BsG096OJy575SySBQGDukpujz)IUSNNe89Cwm2nvWokLhQKSFrxgReoiKbc5wIXUPc2rP8qLK9lgYa975jHdEtLvV4MQ)0)C0ZZq)ySKmKln(C1TJLCSvgrITsw5xLgtg)A8qnAmain(tsdEc9AaZAW5THbhqn49Rb6nhaBHtJ91OlRbE1xham)ASLgw5xd82XwzePbF)14k6mKnASO61W4H9xJhQbpPH8aDocuL2C)clKa9Tc41O3guFWrxSzaFJr1lqVnm4akOY4zeiwjMErz4GJe)2qCHtLahYA43cKgSh475Sa92WGdOOl75zOFmwsgYLgFU62pILVNZc0BddoGc0BoaU03ypW3Zzb5yRmIsiiZgrx2ZJVNZcYXwzeLy9Ygrx(iw(EolKNTboGRXs24SADj5odzJ42yD6smGXAh7bheYaHClHZsB5ed1yBH8rQ298K42M14zKWbRBiaucKq(lhwh8MkRErT4o)u2OJQ04n63g7jKgNqUA00DNA0s0vOHnKg4STiqnKPrde5GfOkT5(fwib6BfWRVTznEgDrzneGgs(kOHd5U42yDcqYXwzej2kX6LnyuBHzm3VWsGEBY7qccFKR)u63gQvjihBLrKyReRx2GrhW4T(gJQxGGDwcMt)jLYWHqVGkJNrGyKVpIzm3VWsWDS)uq4JC9Ns)2qT2Ua)XdMbjtmw60qp1A7c8GrVXO6fL99HqjEJzLJeuz8mcuLUf0BK1GZBdQp4in2sdtdmwRiYPbhiZgnWBhBLr0fAacR28AWOxJ91qEGonUIodzJgh(t71yrACAfiJa1G3Vg0(N0OXFsAW5TjBmMgSTinGJg)jPrlrxHpxD7AW2I0idhn482G6do64fAacR28AaVPH7SpPHvACLx0FQH8aDAyfOgm614pjnmE4nPbBlsJtRazKgCEByWbuL2C)clKa9Tc41O3guFWrxSzaLy6fLHdos8BdXfovcCiRHFlqAWEGVNZc5zBGd4ASKnoRwxsUZq2iUnwNUedyS298475SqE2g4aUglzJZQ1LK7mKnIBJ1PlXaEAh7BmQEb6jgZMe4S5xqLXZiWJypqo2kJiXwjeKzdwd9JXsYqU006TnRXZiHHKVcA4qomIVNZcYXwzeLqqMnIHASTqTccFrUp(tWCIy9Ie)6aaLgQX2cJWGap(0wT75ro2kJiXwjwVSbRH(XyjzixAA92M14zKWqYxbnCihgX3Zzb5yRmIsSEzJyOgBluRGWxK7J)emNiwViXVoaqPHASTWimiWJpxD7hXkbFpNfWI(tusMghj)lSeDzSs8gJQxGEByWbuqLXZiqShCqideYTeolTLtmuJTfYhmMNhc2z8Bbk(ZzzSeIiaOrqLXZiqS89Cw8NZYyjeraqJa9MdGl9TVVQdtVOmCWrc0w5olD6h90SggHNJyZlUZpnuJTfYhPAVDS5f35NgQX2cDjgAVDppWPVGIcMCGOJyp4GqgiKBjaylWHati5D2hjgQX2c5dgZZtch8MkREba(N1QJQ0(kI04kdclKgBPrl2lB0aVDSvgrAyfOgi7M04kzJLBTf2zmnUYGWsJmC0qsT8AFPCAyfOgxj2cCiqnW7gzixAAO6vPn3VWcjqFRaEDrCtnqyDXMb8aFpNfKJTYikX6LnIHASTq(q4JC9Ns)2qEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaG92M14zKaz3ukdNKZsB5uPn3VWcjqFRaE9PXYPgiSUyZaEGVNZcYXwzeLy9YgXqn2wiFi8rU(tPFBiSs4G3uz1laW)Sw55DGVNZca2cCiWe1id5stdvFIkAWTsMeDzSo4nvw9ca8pRvh98o4oTbhHaedyhYDAdok9BdDjEo655oTbhHa03EE89Cw4S0worx(iwto5ojhayVTznEgjq2nLYWj5S0woSh475SySBQGDukpujz)IHASTqxEapxfgWOPxugo4ibARCNLo9JEAw7iw(Eolg7MkyhLYdvs2VOl75jbFpNfJDtfSJs5Hkj7x0LpQsBUFHfsG(wb86CNXsnqyDXMb8aFpNfKJTYikX6LnIHASTq(q4JC9Ns)2qyLWbVPYQxaG)zTYZ7aFpNfaSf4qGjQrgYLMgQ(ev0GBLmj6YyDWBQS6fa4FwRo65DWDAdocbigWoK70gCu63g6s8C0ZZDAdocbOV98475SWzPTCIU8rSMCYDsoaWEBZA8msGSBkLHtYzPTCypW3ZzXy3ub7OuEOsY(fd1yBHUepy575SySBQGDukpujz)IUmwjMErz4GJeOTYDw60p6Pznppj475SySBQGDukpujz)IU8rvAFfrAGzbXBnGLgoqvAZ9lSqc03kGxZ1MzHtcMteRxKkTVIin482K3H04HAipqNgCGmB0aVDSvgrxOHKA51(s5040qAWiesJFBin(tR0W0aZAS)udcFKR)Kgmk)AahnGfZVgTyVSrd82XwzePXI0OlRsBUFHfsG(wb8A0BtEh6Indi5yRmIeBLy9YgSsW3ZzXy3ub7OuEOsY(fDzppYXwzejqqMnPIW375ro2kJiHv(tfHV3Z7aFpNfCTzw4KG5eX6fj6YEEizIXsNg6PlBxG)4bReo4nvw9IBQ(t)JNhsMyS0PHE6Y2f4pwh8MkREXnv)P)5iw(EolihBLruI1lBeDzpVd89Cw4S0woXqn2wOln3VWsWDS)uq4JC9Ns)2qy575SWzPTCIU8rvAFfrAGzn2FQb8pPH7Iin4EUUtnwKgBPbhiZgnWBhBLr0fAiPwETVuonGJgpud5b60Of7LnAG3o2kJivAZ9lSqc03kGxZDS)uLUfAm2FoDvAZ9lSqc03kGxp9kzUFHvITO)IYAiaZgJ9Nthih2IEeqmbihOmv0aetaI5sbetaYHkJNrGaXuGCm3VWcihUJ9Na5asi3SY)clGCUIHCg61adAGzn2FQHvGAyAW5Tb1hCKgWsdoyIgC3)udmFXD(A0cnsdRa1atHTet0aoAW5TjVdPb8pPH7IiGCCZ(0Sgqoh0GCSvgrcwVSjve(En880GCSvgrITsiiZgn880GCSvgrITs8W)udppnihBLrKWk)PIW3RXrnWQH8q3cPeCh7p1aRgsOH8q3cmi4o2Fc8bI5yaiMaKdvgpJabIPa5yUFHfqoO3M8oeqoUzFAwdihj0y6fLHdosWBmRCucMtgJL(ZTWHeuz8mcudppnKqdh8MkRErT4o)u2in880qcnqYeJLEBWrpsGEBYgJPbGAiLgEEAiHgVXO6fL99HqjEJzLJeuz8mcudppnoOb5yRmIeiiZMur471WZtdYXwzej2kX6LnA45Pb5yRmIeBL4H)PgEEAqo2kJiHv(tfHVxJJa5W2IsoqGCWdWhiM7BGycqouz8mceiMcKJ5(fwa5GEBq9bhbKJB2NM1aYz6fLHdosWBmRCucMtgJL(ZTWHeuz8mcudSA4G3uz1lQf35NYgPbwnqYeJLEBWrpsGEBYgJPbGAifqoSTOKdeih8a8b(a5aszRZEGycqmxkGycqoM7xybKdcYSjXtwdqouz8mceiMc8bI5yaiMaKdvgpJabIPa54M9PznGC(TH04snoObg0aJ0WC)clb3X(tHZqF63gsJw1WC)clb6TjVdjCg6t)2qACeihZ9lSaYXzmwYC)cReBrpqoSf9PYAiGCGYurdWhiM7BGycqouz8mceiMcKdugihe9a5yUFHfqo32SgpJaY52yDcihKmXyP3gC0JeO3MSXyA4JgsPbwnoOHeA8gJQxGEByWbuqLXZiqn8804ngvVa9eJztcC28lOY4zeOgh1WZtdKmXyP3gC0JeO3MSXyA4Jgyaihqc5Mv(xybKdh6rA0siERbS0W3TQb39pH9xdWzZVgwbQb39p1GZBddoGAyfOgyOvnG)jnCxebKZTnPYAiGCwuYGeWhiMJ)aXeGCOY4zeiqmfihOmqoi6bYXC)clGCUTznEgbKZTX6eqoizIXsVn4OhjqVn5Din8rdPaYbKqUzL)fwa5WHEKgogz3KgCpPsdoVn5DinCwPX5(AGHw14Tbh9in4EUUtnwKgdXOBREnYWrJ)K0aVDSvgrA8qn4jnKhktZqGAyfOgCpx3Pg5LXOrJhQHZqpqo32KkRHaYzrjhJSBc4deZXdqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKJ8q3jCoqHuIgiSY7qA45PH8q3jCoqHucuVY7qA45PH8q3jCoqHuc0BdQp4in880qEO7eohOqkb6TjBmMgEEAip0DcNduiLi3h)jyorSErA45PH8q3IXUPc2rP8qLK9RHNNg89Cw4S0woXqn2winaud(EolCwAlNaSp2VWsdppnUTznEgjwuYGeqoGeYnR8VWcihm72SgpJ04pTxd3j5aaPXM1WpSRHnKgBPHPbohOgpud7gUGA8NKgO972VWsdUN0qAyA8ZwaqVg070yrA0reOgBPbp9CjQ0WzOhbKZTnPYAiGC2kHZbc8bI5yCGycqouz8mceiMcKJ5(fwa5WtdIga2chqoGeYnR8VWcihFfrAGP0GObGTWPb39p1qsT8AFPCAahnS8tJgscw3qain2sdj1YR9LYbKJB2NM1aY5Ggh0qcnCWBQS6f1I78tzJ0WZtdj0WbHmqi3s4G1neak9NucjVZ(irxwJJAGvd(EolCwAlNyOgBlKg(OHu4rdSAW3ZzXy3ub7OuEOsY(fd1yBH04snWFnWQHeA4G3uz1lUP6p9pA45PHdEtLvV4MQ)0)Obwn475SWzPTCIUSgy1GVNZIXUPc2rP8qLK9l6YAGvJdAW3ZzXy3ub7OuEOsY(fd1yBH04snKsknUknWJgyKgtVOmCWrc0w5olD6h90SMGkJNrGA45PbFpNfolTLtmuJTfsJl1qkP0WZtdP04AnqYeJLon0tACPgsjWdE04Ogh1aRg32SgpJeBLW5ab(aXCmgqmbihQmEgbcetbYXn7tZAa5Cqd(EolCwAlNyOgBlKg(OHu4rdSACqdj0y6fLHdosG2k3zPt)ONM1euz8mcudppn475SySBQGDukpujz)IHASTqACPgsHX04Q0adAGrAW3ZzbpdcbzD0l6YAGvd(Eolg7MkyhLYdvs2VOlRXrn880GhIqAGvJ8I78td1yBH04snWaE04Ogy142M14zKyReohiqoGeYnR8VWciNRa(AWD)tnmnKulV2xkNg)P9ASOQnVgMgxrNHSrd5b60aoAW9Kkn(tsJ8I781yrAy8W(RXd1GkqGCm3VWcihz4VWc4deZBlGycqouz8mceiMcKdugihe9a5yUFHfqo32SgpJaY52yDcihhTmnoOXbnYlUZpnuJTfsJRsdPWJgxLgoiKbc5wcNL2YjgQX2cPXrnUwdPAR214OgaQHJwMgh04Gg5f35NgQX2cPXvPHu4rJRsdheYaHClHdw3qaO0FsjK8o7JeG9X(fwACvA4GqgiKBjCW6gcaL(tkHK3zFKyOgBlKgh14AnKQTAxJJAGvdj0ySfmr3u9cdeeji8TOhPHNNgoiKbc5wcNL2YjgQX2cPHpAS1tJmKzpbMYlUZpnuJTfsdppnMErz4GJeoIrOFnwcjVZ(ibvgpJa1aRgoiKbc5wcNL2YjgQX2cPHpA4721WZtdheYaHClHdw3qaO0FsjK8o7Jed1yBH0Whn26PrgYSNat5f35NgQX2cPXvPHuTRHNNgsOHdEtLvVOwCNFkBeqoGeYnR8VWcihjzmxNzpH0G7j9N0OrhTfonKeSUHaqAuqUAWDzmnmgdYvd)WUgpud0VmMgod9A8NKgiRH0WAG961aM1qsW6gca1QKA51(s50WzOhbKZTnPYAiGCCW6gcaLajK)Yb8bI5xnqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKZbnYlUZpnuJTfsdF0qk8OHNNgJTGj6MQxyGGiXwA4Jg4PDnoQbwnoOXbnoObHx9vwMafuJS)HmwcoGLvosdSACqdheYaHClb1i7FiJLGdyzLJed1yBH04snKcJ3UgEEA4G3uz1lUP6p9pAGvdheYaHClb1i7FiJLGdyzLJed1yBH04snKcJJX0OvnoOHusPbgPX0lkdhCKaTvUZsN(rpnRjOY4zeOgh14Ogy1qcnCqideYTeuJS)HmwcoGLvosmKb6xJJA45PbHx9vwMafiyNXO)3cxA68(1aRgh0qcnCWBQS6f1I78tzJ0WZtdheYaHClbc2zm6)TWLMoV)KVXF80wTlLyOgBlKgxQHusH)ACudppnoOHdczGqULGNgenaSfoXqgOFn880qcngZrIFGmMgh1aRgh04GgeE1xzzcuSfYn934zucV6w99MeiDVosdSACqdheYaHClXwi30FJNrj8QB13BsG096iXqgOFn880WC)clXwi30FJNrj8QB13BsG096ib4ImEgbQXrnoQHNNgh0GWR(kltGc0Pbc5sGj4WNG50dNgQEnWQHdczGqUL4HtdvpbM2cT4o)KVXdE8ngKsmuJTfsJJA45PXbnoOXTnRXZibSsDeL(zlaOxda1qkn88042M14zKawPoIs)Sfa0RbGA4BnoQbwnoOXpBba9IxkXqgO)KdczGqULgEEA8ZwaqV4Ls4GqgiKBjgQX2cPHpAS1tJmKzpbMYlUZpnuJTfsJRsdPAxJJA45PXTnRXZibSsDeL(zlaOxda1adAGvJdA8ZwaqV4XGyid0FYbHmqi3sdppn(zlaOx8yq4GqgiKBjgQX2cPHpAS1tJmKzpbMYlUZpnuJTfsJRsdPAxJJA45PXTnRXZibSsDeL(zlaOxda1ODnoQXrnoQHNNgo4nvw9ca8pRvACudppn4HiKgy1iV4o)0qn2winUud(EolCwAlNaSp2VWcihqc5Mv(xybKJVIiqnEOgGeZ8RXFsA0rgosdywdj1YR9LYPb3tQ0OJ2cNgGWopJ0awA0rKgwbQH8q3u9A0rgosdUNuPHvAyGGAq3u9ASinmEy)14HAaUeqo32KkRHaYXbMCWcC)fwaFGyUuTdetaYHkJNrGaXuGCGYa5GOhihZ9lSaY52M14zeqo3gRta5iHgiyNXVfO4pNLXsiIaGgbvgpJa1WZtJ8I78td1yBH0WhnWq7TRHNNg8qesdSAKxCNFAOgBlKgxQbgWJgTQXbnW)214Q0GVNZI)CwglHicaAeO3CaObgPbg04OgEEAW3ZzXFolJLqebanc0Boa0Whn8DBPXvPXbnMErz4GJeOTYDw60p6PznbvgpJa1aJ0apACeihqc5Mv(xybKdMDBwJNrA0reOgpudqIz(1Wk)A8ZwaqpsdRa1WbI0G7jvAW12FlCAKHJgwPbE3LpHZAAipqhqo32KkRHaY5pNLXsiIaGMexBFGpqmxkPaIja5qLXZiqGykqoGeYnR8VWcihFfrAG3nY(hYyACLpGLvosdm0oICin4PmCinmnKulV2xkNgDejaYPSgcihQr2)qglbhWYkhbKJB2NM1aYXbHmqi3s4S0woXqn2winUudm0Ugy1WbHmqi3s4G1neak9NucjVZ(iXqn2winUudm0Ugy14Gg32SgpJe)5Smwcrea0K4A7RHNNg89Cw8NZYyjeraqJa9Mdan8rdF3UgTQXbnMErz4GJeOTYDw60p6PznbvgpJa1aJ0aJRXrnoQbwnUTznEgj2kHZbQHNNg8qesdSAKxCNFAOgBlKgxQHVXya5yUFHfqouJS)HmwcoGLvoc4deZLcdaXeGCOY4zeiqmfihqc5Mv(xybKJVIin4a7mg9BHtJR0oVFnW4iYH0GNYWH0W0qsT8AFPCA0rKaiNYAiGCqWoJr)VfU0059dKJB2NM1aY5GgoiKbc5wcNL2YjgQX2cPXLAGX1aRgsOHdEtLvV4MQ)0)ObwnKqdh8MkRErT4o)u2in880WbVPYQxulUZpLnsdSA4GqgiKBjCW6gcaL(tkHK3zFKyOgBlKgxQbgxdSACqJBBwJNrchSUHaqjqc5VCA45PHdczGqULWzPTCIHASTqACPgyCnoQHNNgo4nvw9IBQ(t)Jgy14GgsOX0lkdhCKaTvUZsN(rpnRjOY4zeOgy1WbHmqi3s4S0woXqn2winUudmUgEEAW3ZzXy3ub7OuEOsY(fd1yBH04snKc)1OvnoObE0aJ0GWR(kltGITq)0DpCqjW9ElkXtmMgh1aRg89Cwm2nvWokLhQKSFrxwJJA45PbpeH0aRg5f35NgQX2cPXLAGb8OHNNgeE1xzzcuqnY(hYyj4aww5inWQHdczGqULGAK9pKXsWbSSYrIHASTqA4JgyODnoQbwnUTznEgj2kHZbQbwnKqdcV6RSmbk2c5M(B8mkHxDR(EtcKUxhPHNNgoiKbc5wITqUP)gpJs4v3QV3KaP71rIHASTqA4JgyODn880GhIqAGvJ8I78td1yBH04snWq7a5yUFHfqoiyNXO)3cxA68(b(aXCP8nqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKdFpNfolTLtmuJTfsdF0qk8ObwnoOHeAm9IYWbhjqBL7S0PF0tZAcQmEgbQHNNg89Cwm2nvWokLhQKSFXqn2winUeqnKcdcmOrRACqdFRbgPbFpNf8mieK1rVOlRXrnAvJdA0wACvAGhnWin475SGNbHGSo6fDznoQbgPbHx9vwMafBH(P7E4GsG79wuINymnWQbFpNfJDtfSJs5Hkj7x0L14OgEEAWdrinWQrEXD(PHASTqACPgyapA45PbHx9vwMafuJS)HmwcoGLvosdSA4GqgiKBjOgz)dzSeCalRCKyOgBleqoGeYnR8VWciNwY4A(rA0rKg(cMTAbAWD)tnKulV2xkhqo32KkRHaYzXlWKdwG7VWc4deZLc)bIja5qLXZiqGykqoM7xybKZwi30FJNrj8QB13BsG096iGCCZ(0Sgqo32SgpJelEbMCWcC)fwAGvJBBwJNrITs4CGa5uwdbKZwi30FJNrj8QB13BsG096iGpqmxk8aetaYHkJNrGaXuGCajKBw5FHfqo(kI0ywCNVg8ugoKgoqeqoL1qa5Gonqixcmbh(emNE40q1dKJB2NM1aY5GgoiKbc5wcNL2YjgYa9RbwnKqdh8MkRErT4o)u2inWQXTnRXZiXFolJLqebanjU2(AGvJdA4GqgiKBj4PbrdaBHtmKb6xdppnKqJXCK4hiJPXrn880WbVPYQxulUZpLnsdSA4GqgiKBjCW6gcaL(tkHK3zFKyid0Vgy14Gg32SgpJeoyDdbGsGeYF50WZtdheYaHClHZsB5edzG(14Ogh1aRgGWxG6vEhs8RdGTWPbwnoObi8fONymBszMnK4xhaBHtdppnKqJ3yu9c0tmMnPmZgsqLXZiqn880ajtmw6Tbh9ib6TjVdPHpA4BnoQbwnaHVObcR8oK4xhaBHtdSACqJBBwJNrIfLmiPHNNgtVOmCWrcEJzLJsWCYyS0FUfoKGkJNrGA45PHH(XyjzixA0Wha14QBxdppnUTznEgjCW6gcaLajK)YPHNNg89CwWZGqqwh9IUSgh1aRgsObHx9vwMafBHCt)nEgLWRUvFVjbs3RJ0WZtdcV6RSmbk2c5M(B8mkHxDR(EtcKUxhPbwnCqideYTeBHCt)nEgLWRUvFVjbs3RJed1yBH0Whn8D7AGvdj0GVNZcNL2Yj6YA45PbpeH0aRg5f35NgQX2cPXLAG)TdKJ5(fwa5Gonqixcmbh(emNE40q1d8bI5sHXbIja5qLXZiqGykqoGeYnR8VWcihm5CrASinmng7pPrdIz8WXEsdUMFnEOgngaKggJPbS0OJinqV9A8ZwaqpsJhQbpPbBlcuJUSgC3)udj1YR9LYPHvGAijyDdbG0Wkqn6isJ)K0adfOgig81awA4a1yZAWd)tn(zlaOhPHnKgWsJoI0a92RXpBba9iGCCZ(0Sgqoh042M14zKawPoIs)Sfa0RHeaQHuAGvdj04NTaGEXJbXqgO)KdczGqULgEEACqJBBwJNrcyL6ik9ZwaqVgaQHuA45PXTnRXZibSsDeL(zlaOxda1W3ACudSACqd(EolCwAlNOlRbwnoOHeA4G3uz1lUP6p9pA45PbFpNfJDtfSJs5Hkj7xmuJTfsJw14Gg4rdmsJPxugo4ibARCNLo9JEAwtqLXZiqnoQXLaQXpBba9IxkbFpNtG9X(fwAGvd(Eolg7MkyhLYdvs2VOlRHNNg89Cwm2nvWokLhQKS)eARCNLo9JEAwt0L14OgEEA4GqgiKBjCwAlNyOgBlKgTQbg0Whn(zlaOx8sjCqideYTeG9X(fwAGvdj0GVNZcNL2Yj6YAGvJdAiHgo4nvw9IAXD(PSrA45PHeACBZA8ms4G1neakbsi)LtJJAGvdj0WbVPYQxaG)zTsdppnCWBQS6f1I78tzJ0aRg32SgpJeoyDdbGsGeYF50aRgoiKbc5wchSUHaqP)Ksi5D2hj6YAGvdj0WbHmqi3s4S0worxwdSACqJdAW3Zzb5yRmIsSEzJyOgBlKg(OHuTRHNNg89Cwqo2kJOecYSrmuJTfsdF0qQ214Ogy1qcnMErz4GJe8gZkhLG5KXyP)ClCibvgpJa1WZtJdAW3ZzbVXSYrjyozmw6p3chkv23hsGEZbGgaQbE0WZtd(Eol4nMvokbZjJXs)5w4qjBCwrc0Boa0aqnAlnoQXrn880GVNZca2cCiWe1id5stdvFIkAWTsMeDznoQHNNg8qesdSAKxCNFAOgBlKgxQbgAxdppnUTznEgjGvQJO0pBba9AaOgTRXrnWQXTnRXZiXwjCoqGCqm4JaY5NTaGEPaYXC)clGC(zlaOxkGpqmxkmgqmbihQmEgbcetbYXC)clGC(zlaOhda54M9PznGCoOXTnRXZibSsDeL(zlaOxdjaudmObwnKqJF2ca6fVuIHmq)jheYaHCln88042M14zKawPoIs)Sfa0RbGAGbnWQXbn475SWzPTCIUSgy14GgsOHdEtLvV4MQ)0)OHNNg89Cwm2nvWokLhQKSFXqn2winAvJdAGhnWinMErz4GJeOTYDw60p6PznbvgpJa14OgxcOg)Sfa0lEmi475CcSp2VWsdSAW3ZzXy3ub7OuEOsY(fDzn880GVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIUSgh1WZtdheYaHClHZsB5ed1yBH0OvnWGg(OXpBba9IhdcheYaHClbyFSFHLgy1qcn475SWzPTCIUSgy14GgsOHdEtLvVOwCNFkBKgEEAiHg32SgpJeoyDdbGsGeYF504Ogy1qcnCWBQS6fa4FwR0aRgh0qcn475SWzPTCIUSgEEAiHgo4nvw9IBQ(t)Jgh1WZtdh8MkRErT4o)u2inWQXTnRXZiHdw3qaOeiH8xonWQHdczGqULWbRBiau6pPesEN9rIUSgy1qcnCqideYTeolTLt0L1aRgh04Gg89Cwqo2kJOeRx2igQX2cPHpAiv7A45PbFpNfKJTYikHGmBed1yBH0WhnKQDnoQbwnKqJPxugo4ibVXSYrjyozmw6p3chsqLXZiqn8804Gg89CwWBmRCucMtgJL(ZTWHsL99HeO3CaObGAGhn880GVNZcEJzLJsWCYyS0FUfouYgNvKa9MdanauJ2sJJACuJJA45PbFpNfaSf4qGjQrgYLMgQ(ev0GBLmj6YA45PbpeH0aRg5f35NgQX2cPXLAGH21WZtJBBwJNrcyL6ik9ZwaqVgaQr7ACudSACBZA8msSvcNdeihed(iGC(zlaOhdaFGyUuTfqmbihQmEgbcetbYbKqUzL)fwa54RicPHXyAa)tA0awA0rKg7tninGLgoqGCm3VWciNoIs7tniGpqmxQRgiMaKdvgpJabIPa5asi3SY)clGCAbKBbjnm3VWsd2IEn4nebQbS0aTF3(fwxZiClcihZ9lSaYz6vYC)cReBrpqoOFw3deZLcih3SpnRbKZTnRXZiXIsgKaYHTOpvwdbKJbjGpqmhdTdetaYHkJNrGaXuGCCZ(0SgqotVOmCWrcEJzLJsWCYyS0FUfoKGWR(kltGa5G(zDpqmxkGCm3VWciNPxjZ9lSsSf9a5Ww0NkRHaYHhApWhiMJbPaIja5qLXZiqGykqoM7xybKZ0RK5(fwj2IEGCyl6tL1qa5GEGpWhihEO9aXeGyUuaXeGCOY4zeiqmfihZ9lSaYzSBQGDukpujz)a5asi3SY)clGCAHdvs2VgC3)udj1YR9LYbKJB2NM1aYHVNZcNL2YjgQX2cPHpAifEa(aXCmaetaYHkJNrGaXuGCm3VWcihd0K)9MsiU20aKJZVJrP3gC0JaI5sbKJB2NM1aYHVNZcEJzLJsWCYyS0FUfouQSVpKa9MdanUuJ2sdSAW3ZzbVXSYrjyozmw6p3chkzJZksGEZbGgxQrBPbwnoOHeAacFHbAY)EtjexBAsGwJHJe)6aylCAGvdj0WC)clHbAY)EtjexBAsGwJHJeBLYSf35RbwnoOHeAacFHbAY)EtjexBAsNKXe)6aylCA45Pbi8fgOj)7nLqCTPjDsgtmuJTfsdF0W3ACudppnaHVWan5FVPeIRnnjqRXWrc0Boa04sn8Tgy1ae(cd0K)9MsiU20KaTgdhjgQX2cPXLAGhnWQbi8fgOj)7nLqCTPjbAngos8RdGTWPXrGCajKBw5FHfqo(kI0OLGM8V3KgC4AtJgCpPsd71GriKg)PvAG)AGPWwIjAGEZbasdRa14HAmuEi0PgMgxcig0a9MdanmKgm7jnmKgYqeA5zKgWrJFBin2xdeuJ91WMzVjKgy20rVgw(PrdtdF3QgO3CaObHp5DieWhiM7BGycqouz8mceiMcKJ5(fwa54G1neak9NucjVZ(iGCajKBw5FHfqo(kI0qsW6gcaPb39p1qsT8AFPCAW9KknKHi0YZinScud4Fsd3frAWD)tnmnWuylXen475SgCpPsdqc5VCBHdih3SpnRbKJeAao9fuuWKdePbwnoOXbnUTznEgjCW6gcaLajK)YPbwnKqdheYaHClHZsB5edzG(1WZtd(EolCwAlNOlRXrnWQXbn475SG3yw5OemNmgl9NBHdLk77djqV5aqda1OT0WZtd(Eol4nMvokbZjJXs)5w4qjBCwrc0Boa0aqnAlnoQHNNg8qesdSAKxCNFAOgBlKgxQHuTRbwnCqideYTeolTLtmuJTfsdF0aJPXrGpqmh)bIja5qLXZiqGykqoM7xybKtUp(tWCIy9IaYbKqUzL)fwa50cH4TggsJ)K0iVd61aNduJT04pjnmnWuylXen4UfiKRgWrdU7FQXFsACLW)SwPbFpN1aoAWD)tnmnARwrKtJwcAY)EtAWHRnnAyfOgCT91idhnKulV2xkNgBwJ91GlSEn4jn6YAy4ST0GNYWH04pjnCGASinYBTOtceih3SpnRbKZbnoOXbn475SG3yw5OemNmgl9NBHdLk77djqV5aqdF0aJRHNNg89CwWBmRCucMtgJL(ZTWHs24SIeO3CaOHpAGX14Ogy14GgsOHdEtLvV4MQ)0)OHNNgsObFpNfJDtfSJs5Hkj7x0L14Ogh1aRgh0aC6lOOGjhisdppnCqideYTeolTLtmuJTfsdF0apTRHNNgh0WbVPYQxulUZpLnsdSA4GqgiKBjCW6gcaL(tkHK3zFKyOgBlKg(ObEAxJJACuJJA45PXbnaHVWan5FVPeIRnnjqRXWrIHASTqA4JgTLgy1WbHmqi3s4S0woXqn2win8rdPAxdSA4G3uz1lkYnqgCa14OgEEAS1tJmKzpbMYlUZpnuJTfsJl1OT0aRgsOHdczGqULWzPTCIHmq)A45PHdEtLvVaa)ZALgy1GVNZca2cCiWe1id5stdvVOlRHNNgo4nvw9IBQ(t)Jgy1GVNZIXUPc2rP8qLK9lgQX2cPXLAC1AGvd(Eolg7MkyhLYdvs2VOld8bI54biMaKdvgpJabIPa5yUFHfqooRCelX3ZzGCCZ(0Sgqoh0GVNZcEJzLJsWCYyS0FUfouQSVpKyOgBlKg(ObgtGhn880GVNZcEJzLJsWCYyS0FUfouYgNvKyOgBlKg(ObgtGhnoQbwnoOHdczGqULWzPTCIHASTqA4Jgymn8804GgoiKbc5wcQrgYLMepSafd1yBH0WhnWyAGvdj0GVNZca2cCiWe1id5stdvFIkAWTsMeDznWQHdEtLvVaa)ZALgh14Ogy1Wq)ySKmKlnA4dGA472bYHVNZPYAiGCqVnm4acKdiHCZk)lSaYrsw5iMgCEByWbudU7FQHPrrC1atHTet0GVNZAyfOgsQLx7lLtJfvT51W4H9xJhQbpPrhrGaFGyoghiMaKdvgpJabIPa5yUFHfqoO3guFWra5asi3SY)clGCAb9gzn482G6docPbpLHdPHKG1neacih3SpnRbKZbnCqideYTeoyDdbGs)jLqY7SpsmuJTfsJl1apAGvdj0aC6lOOGjhisdSACqJBBwJNrchSUHaqjqc5VCA45PHdczGqULWzPTCIHASTqACPg4rJJAGvJBBwJNrchyYblW9xyPXrnWQHeAacFrUp(tWCIy9Ie)6aylCAGvdh8MkRErT4o)u2inWQHeAao9fuuWKdePbwnihBLrKyRKv(1aRgg6hJLKHCPrdF0a)Bh4deZXyaXeGCOY4zeiqmfihOmqoi6bYXC)clGCUTznEgbKZTX6eqoh0GVNZIXUPc2rP8qLK9lgQX2cPHpAGhn880qcn475SySBQGDukpujz)IUSgh1aRgh0GVNZca2cCiWe1id5stdvFIkAWTsMed1yBH04snW5afng(04Ogy14Gg89Cwqo2kJOecYSrmuJTfsdF0aNdu0y4tdppn475SGCSvgrjwVSrmuJTfsdF0aNdu0y4tJJa5asi3SY)clGCAbWQnVgGWxdW(Sfon(tsdQa1aM14k1UPc2rA0chQKS)l0aSpBHtda2cCiqnOgzixAAO61aoASLg)jPbZqVg4CGAaZAyLg4TJTYiciNBBsL1qa5ac)0q4vFhQHQhb8bI5TfqmbihQmEgbcetbYXC)clGCq9kVdbKJB2NM1aYzO8qOtJNrAGvJ3gC0l(THspmbUKg(OHuyCnWQHjNCNKdanWQXTnRXZibi8tdHx9DOgQEeqoo)ogLEBWrpciMlfWhiMF1aXeGCOY4zeiqmfihZ9lSaYPbcR8oeqoUzFAwdiNHYdHonEgPbwnEBWrV43gk9We4sA4Jgs5BbE0aRgMCYDsoa0aRg32SgpJeGWpneE13HAO6ra5487yu6Tbh9iGyUuaFGyUuTdetaYHkJNrGaXuGCm3VWcih0tmMnPmZgcih3SpnRbKZq5HqNgpJ0aRgVn4Ox8BdLEycCjn8rdPW4A0Qgd1yBH0aRgMCYDsoa0aRg32SgpJeGWpneE13HAO6ra5487yu6Tbh9iGyUuaFGyUusbetaYHkJNrGaXuGCm3VWciNmCCucMtL99HaYbKqUzL)fwa50cHyUgWsdhOgC3)e2FnCMS8w4aYXn7tZAa5yYj3j5aa4deZLcdaXeGCOY4zeiqmfihZ9lSaYHAKHCPjXdlqGCajKBw5FHfqo4DJmKlnAGPWcudUNuPHXd7VgpudQEA0W0OiUAGPWwIjAWDlqixnScudKDtAKHJgsQLx7lLdih3SpnRbKZbnihBLrKG1lBsfHVxdppnihBLrKabz2KkcFVgEEAqo2kJiHv(tfHVxdppn475SG3yw5OemNmgl9NBHdLk77djgQX2cPHpAGXe4rdppn475SG3yw5OemNmgl9NBHdLSXzfjgQX2cPHpAGXe4rdppnm0pgljd5sJg(OXv3Ugy1WbHmqi3s4S0woXqgOFnWQHeAao9fuuWKdePXrnWQXbnCqideYTeolTLtmuJTfsdF0W3TRHNNgoiKbc5wcNL2YjgYa9RXrn880GhIqAGvJTEAKHm7jWuEXD(PHASTqACPgs1oWhiMlLVbIja5qLXZiqGykqoM7xybKtUp(tWCIy9IaYbKqUzL)fwa50cH4TgZI781GNYWH0OJ2cNgsQLa54M9PznGCCqideYTeolTLtmKb6xdSACBZA8ms4atoybU)clnWQXbnm0pgljd5sJg(OXv3Ugy1qcnCWBQS6f1I78tzJ0WZtdh8MkRErT4o)u2inWQHH(XyjzixA04snW)214Ogy1qcnCWBQS6f3u9N(hnWQXbnKqdh8MkRErT4o)u2in880WbHmqi3s4G1neak9NucjVZ(iXqgOFnoQbwnKqdWPVGIcMCGiGpqmxk8hiMaKdvgpJabIPa5aLbYbrpqoM7xybKZTnRXZiGCUnwNaYrcnaN(ckkyYbI0aRg32SgpJeoWKdwG7VWsdSACqJdAyOFmwsgYLgn8rJRUDnWQXbn475SaGTahcmrnYqU00q1NOIgCRKjrxwdppnKqdh8MkREba(N1knoQHNNg89CwWZGqqwh9IUSgy1GVNZcEgecY6OxmuJTfsJl1GVNZcNL2Yja7J9lS04OgEEAWdrinWQXwpnYqM9eykV4o)0qn2winUud(EolCwAlNaSp2VWsdppnCWBQS6f1I78tzJ04Ogy14GgsOHdEtLvVOwCNFkBKgEEACqdd9JXsYqU0OXLAG)TRHNNgGWxK7J)emNiwViXVoa2cNgh1aRgh042M14zKWbRBiaucKq(lNgEEA4GqgiKBjCW6gcaL(tkHK3zFKyid0Vgh14iqoGeYnR8VWcihj1YR9LYPb3tQ0WEnU62BvJwIUcnoahgKlnA8NwPb(3UgTeDfAWD)tnKeSUHaqh1G7(NW(RbdI2cNg)2qASLgykdcbzD0RHvGAW2I0OlRb39p1qsW6gcaPXM1yFn4AinajK)YrGa5CBtQSgcihhyYblW9xyL4H2d8bI5sHhGycqouz8mceiMcKJB2NM1aY52M14zKWbMCWcC)fwjEO9a5yUFHfqooIrOFnwYylUQHQh4deZLcJdetaYHkJNrGaXuGCCZ(0Sgqo32SgpJeoWKdwG7VWkXdThihZ9lSaYzlNnL9lSa(aXCPWyaXeGCOY4zeiqmfihOmqoi6bYXC)clGCUTznEgbKZTX6eqoKJTYisSvI1lB0aJ0OT04Anm3VWsGEBY7qccFKR)u63gsJw1qcnihBLrKyReRx2ObgPXbnW4A0QgVXO6fiyNLG50FsPmCi0lOY4zeOgyKg(wJJACTgM7xyj4o2Fki8rU(tPFBinAvJ2fyqJR1ajtmw60qpbKdiHCZk)lSaYbVr)2ypH04eYvJMU7uJwIUcnSH0aNTfbQHmnAGihSabY52Muzneqogs(kOHd5a(aXCPAlGycqouz8mceiMcKJ5(fwa5GEBq9bhbKdiHCZk)lSaYPf0BK1GZBdQp4iKgCpPsJ)K0iV4oFnwKggpS)A8qnOc8cnYdvs2VglsdJh2FnEOgubEHg(HDnSH0WEnU62BvJwIUcn2sdR0aVDSvgrxOHKA51(s50GzOhPHvW)KgnARwrKdPbC0WpSRbxyNbQb8MgNjRrdCin(tR0q9KQDnAj6k0G7jvA4h21GlSZaR28AW5Tb1hCKgfKlqoUzFAwdiNdAWdrinWQXwpnYqM9eykV4o)0qn2winUud8xdppnoObFpNfJDtfSJs5Hkj7xmuJTfsJl1aNdu0y4tdmsdhTmnoOHH(XyjzixA04An8D7ACudSAW3ZzXy3ub7OuEOsY(fDznoQXrn8804Ggg6hJLKHCPrJw142M14zKWqYxbnCiNgyKg89Cwqo2kJOecYSrmuJTfsJw1ae(ICF8NG5eX6fj(1baknuJTLgyKgyqGhn8rdPKQDn880Wq)ySKmKlnA0Qg32SgpJegs(kOHd50aJ0GVNZcYXwzeLy9YgXqn2winAvdq4lY9XFcMteRxK4xhaO0qn2wAGrAGbbE0WhnKsQ214Ogy1GCSvgrITsw5xdSACqdj0GVNZcNL2Yj6YA45PHeA8gJQxGEByWbuqLXZiqnoQbwnoOXbnKqdheYaHClHZsB5eDzn880WbVPYQxaG)zTsdSAiHgoiKbc5wcQrgYLMepSafDznoQHNNgo4nvw9IAXD(PSrACudSACqdj0WbVPYQxCt1F6F0WZtdj0GVNZcNL2Yj6YA45PHH(XyjzixA0WhnU6214OgEEACqJ3yu9c0BddoGcQmEgbQbwn475SWzPTCIUSgy14Gg89CwGEByWbuGEZbGgxQHV1WZtdd9JXsYqU0OHpAC1TRXrnoQHNNg89Cw4S0worxwdSAiHg89Cwm2nvWokLhQKSFrxwdSAiHgVXO6fO3ggCafuz8mce4deZL6QbIja5qLXZiqGykqoM7xybKtrCtnqybKdiHCZk)lSaYXxrKgxzqyH0ylnAXEzJg4TJTYisdRa1az3KgxjBSCRTWoJPXvgewAKHJgsQLx7lLdih3SpnRbKZbn475SGCSvgrjwVSrmuJTfsdF0GWh56pL(TH0WZtJdA4oTbhH0aqnWGgy1yi3Pn4O0VnKgxQbE04OgEEA4oTbhH0aqn8Tgh1aRgMCYDsoaa(aXCm0oqmbihQmEgbcetbYXn7tZAa5Cqd(EolihBLruI1lBed1yBH0Whni8rU(tPFBinWQXbnCqideYTeolTLtmuJTfsdF0apTRHNNgoiKbc5wchSUHaqP)Ksi5D2hjgQX2cPHpAGN214OgEEACqd3Pn4iKgaQbg0aRgd5oTbhL(TH04snWJgh1WZtd3Pn4iKgaQHV14Ogy1WKtUtYbaqoM7xybKZPXYPgiSa(aXCmifqmbihQmEgbcetbYXn7tZAa5Cqd(EolihBLruI1lBed1yBH0Whni8rU(tPFBinWQXbnCqideYTeolTLtmuJTfsdF0apTRHNNgoiKbc5wchSUHaqP)Ksi5D2hjgQX2cPHpAGN214OgEEACqd3Pn4iKgaQbg0aRgd5oTbhL(TH04snWJgh1WZtd3Pn4iKgaQHV14Ogy1WKtUtYbaqoM7xybKtUZyPgiSa(aXCmGbGycqouz8mceiMcKdiHCZk)lSaYbZcI3AalnCGa5yUFHfqoCTzw4KG5eX6fb8bI5yW3aXeGCOY4zeiqmfihZ9lSaYb92K3HaYbKqUzL)fwa54RisdoVn5DinEOgYd0PbhiZgnWBhBLrKgWrdUNuPXwAalMFnAXEzJg4TJTYisdRa1OJinWSG4TgYd0H0yZASLgTyVSrd82XwzebKJB2NM1aYHCSvgrITsSEzJgEEAqo2kJibcYSjve(En880GCSvgrcR8NkcFVgEEAW3ZzbxBMfojyorSErIUSgy1GVNZcYXwzeLy9YgrxwdppnoObFpNfolTLtmuJTfsJl1WC)clb3X(tbHpY1Fk9BdPbwn475SWzPTCIUSghb(aXCmG)aXeGCm3VWcihUJ9Na5qLXZiqGykWhiMJb8aetaYHkJNrGaXuGCm3VWciNPxjZ9lSsSf9a5Ww0NkRHaYjBm2FoDGpWhihdsaXeGyUuaXeGCOY4zeiqmfihOmqoi6bYXC)clGCUTznEgbKZTX6eqoh0GVNZIFBiUWPsGdzn8BbsJyOgBlKgxQbohOOXWNgTQr7cP0WZtd(Eol(TH4cNkboK1WVfinIHASTqACPgM7xyjqVn5DibHpY1Fk9BdPrRA0UqknWQXbnihBLrKyReRx2OHNNgKJTYisGGmBsfHVxdppnihBLrKWk)PIW3RXrnoQbwn475S43gIlCQe4qwd)wG0i6YAGvJPxugo4iXVnex4ujWHSg(TaPrqLXZiqGCajKBw5FHfqosYyUoZEcPb3t6pPrJ)K0OfmK14S3DsJg89CwdUlJPr2ymnG5SgC3)Cln(tsJIW3RHZqpqo32KkRHaYbCiRjXDzSu2ySemNb(aXCmaetaYHkJNrGaXuGCGYa5GOhihZ9lSaY52M14zeqo3gRta5iHgKJTYisSvcbz2ObwnoObsMyS0Bdo6rc0BtEhsdF0apAGvJ3yu9ceSZsWC6pPugoe6fuz8mcudppnqYeJLEBWrpsGEBY7qA4JgymnocKdiHCZk)lSaYrsgZ1z2tin4Es)jnAW5Tb1hCKglsdUW5p1WzOFlCAaVPrdoVn5Din2sJwSx2ObE7yRmIaY52MuzneqolUcouc92G6doc4deZ9nqmbihQmEgbcetbYXC)clGCCW6gcaL(tkHK3zFeqoGeYnR8VWcihFfrAijyDdbG0G7jvAyVgmcH04pTsd80UgTeDfAyfOgSTin6YAWD)tnKulV2xkhqoUzFAwdihj0aC6lOOGjhisdSACqJdACBZA8ms4G1neakbsi)LtdSAiHgoiKbc5wcNL2YjgYa9RHNNg89Cw4S0worxwJJAGvJdAW3Zzb5yRmIsSEzJyOgBlKg(Obgxdppn475SGCSvgrjeKzJyOgBlKg(ObgxJJAGvJdAiHgtVOmCWrcEJzLJsWCYyS0FUfoKGkJNrGA45PbFpNf8gZkhLG5KXyP)ClCOuzFFib6nhaA4Jg(wdppn475SG3yw5OemNmgl9NBHdLSXzfjqV5aqdF0W3ACudppn4HiKgy1iV4o)0qn2winUudPAxdSAiHgoiKbc5wcNL2YjgYa9RXrGpqmh)bIja5qLXZiqGykqoM7xybKdQx5DiGCC(Dmk92GJEeqmxkGCCZ(0Sgqoh0yO8qOtJNrA45PbFpNfKJTYikHGmBed1yBH04sn8Tgy1GCSvgrITsiiZgnWQXqn2winUudPWFnWQXBmQEbc2zjyo9Nukdhc9cQmEgbQXrnWQXBdo6f)2qPhMaxsdF0qk8xJRsdKmXyP3gC0J0OvngQX2cPbwnoOb5yRmIeBLSYVgEEAmuJTfsJl1aNdu0y4tJJa5asi3SY)clGC8vePbNEL3H0ylnKTcKAwNgWsdR8)NBHtJ)0Eny7nH0qk8hroKgwbQbJqin4U)PgnWH04Tbh9inScud714pjnOcudywdtdoqMnAG3o2kJinSxdPWFnqKdPbC0GriKgd1yBTfonmKgpuJc(ACA3BHtJhQXq5HqNAa2NTWPrl2lB0aVDSvgraFGyoEaIja5qLXZiqGykqoM7xybKdQx5DiGCajKBw5FHfqo(kI0GtVY7qA8qnoTBsdtdCmiVX04HA0rKg(cMTAba54M9PznGCUTznEgjw8cm5Gf4(lS0aRgoiKbc5wITqUP)gpJs4v3QV3KaP71rIHmq)AGvdcV6RSmbk2c5M(B8mkHxDR(EtcKUxhb8bI5yCGycqouz8mceiMcKJB2NM1aYrcnEJr1lqpXy2KaNn)cQmEgbQbwnoObFpNfO3MSXyIHYdHonEgPbwnoObsMyS0Bdo6rc0Bt2ymnUudFRHNNgsOX0lkdhCK43gIlCQe4qwd)wG0iOY4zeOgh1WZtJ3yu9ceSZsWC6pPugoe6fuz8mcudSAW3Zzb5yRmIsiiZgXqn2winUudFRbwnihBLrKyRecYSrdSAW3Zzb6TjBmMyOgBlKgxQbgtdSAGKjgl92GJEKa92KngtdFaud8xJJAGvJdAiHgtVOmCWrcMFNngkLze9BHlHJTnYisqLXZiqn88043gsdmJg4pE0Whn475Sa92KngtmuJTfsJw1adACudSA82GJEXVnu6HjWL0WhnWdqoM7xybKd6TjBmgWhiMJXaIja5qLXZiqGykqoM7xybKd6TjBmgqoGeYnR8VWcihmR9p1GZtmMnA0cMn)A0rKgWsdhOgCpPsJHYdHonEgPbF)1a9lJPbxBFnYWrJw0VZgdPH8aDAyfOgGWQnVgDePbpLHdPHKAbiHgC(LX0OJin4PmCinKeSUHaqAG2YrA8N2Rb3LX0qEGonSc(N0ObN3MSXya54M9PznGCEJr1lqpXy2KaNn)cQmEgbQbwn475Sa92KngtmuEi0PXZinWQXbnKqJPxugo4ibZVZgdLYmI(TWLWX2gzejOY4zeOgEEA8BdPbMrd8hpA4Jg4Vgh1aRgVn4Ox8BdLEycCjn8rdFd8bI5TfqmbihQmEgbcetbYXC)clGCqVnzJXaYbKqUzL)fwa5GzT)PgTGHSg(TaPrJoI0GZBt2ymnEOgaqKSgDzn(tsd(EoRbVFnmgcQrhTfon482KngtdyPbE0aroybI0aoAWiesJHAST2chqoUzFAwdiNPxugo4iXVnex4ujWHSg(TaPrqLXZiqnWQbsMyS0Bdo6rc0Bt2ymn8bqn8Tgy14GgsObFpNf)2qCHtLahYA43cKgrxwdSAW3Zzb6TjBmMyO8qOtJNrA45PXbnUTznEgjahYAsCxglLnglbZznWQXbn475Sa92KngtmuJTfsJl1W3A45PbsMyS0Bdo6rc0Bt2ymn8rdmObwnEJr1lqpXy2KaNn)cQmEgbQbwn475Sa92KngtmuJTfsJl1apACuJJACe4deZVAGycqouz8mceiMcKdugihe9a5yUFHfqo32SgpJaY52yDcihd9JXsYqU0OHpA0wTRXvPXbnKQDnWin475S43gIlCQe4qwd)wG0iqV5aqJJACvACqd(EolqVnzJXed1yBH0aJ0W3ACTgizIXsNg6jnWinKqJ3yu9c0tmMnjWzZVGkJNrGACuJRsJdA4GqgiKBjqVnzJXed1yBH0aJ0W3ACTgizIXsNg6jnWinEJr1lqpXy2KaNn)cQmEgbQXrnUknoObi8f5(4pbZjI1lsmuJTfsdmsd8OXrnWQXbn475Sa92Kngt0L1WZtdheYaHClb6TjBmMyOgBlKghbYbKqUzL)fwa5ijJ56m7jKgCpP)Kgnmn482G6dosJoI0G7YyA4SoI0GZBt2ymnEOgzJX0aMZxOHvGA0rKgCEBq9bhPXd1aaIK1OfmK1WVfinAGEZbGgDzGCUTjvwdbKd6TjBmwIlS(u2ySemNb(aXCPAhiMaKdvgpJabIPa5yUFHfqoO3guFWra5asi3SY)clGC8vePbN3guFWrAWD)tnAbdzn8BbsJgpudaiswJUSg)jPbFpN1G7(NW(RbdI2cNgCEBYgJPrx(3gsdRa1OJin482G6dosdyPb(3QgykSLyIgO3CaG0Ox)Y0a)14Tbh9iGCCZ(0Sgqo32SgpJeGdznjUlJLYgJLG5Sgy142M14zKa92KnglXfwFkBmwcMZAGvdj042M14zKyXvWHsO3guFWrA45PXbn475SG3yw5OemNmgl9NBHdLk77djqV5aqdF0W3A45PbFpNf8gZkhLG5KXyP)ClCOKnoRib6nhaA4Jg(wJJAGvdKmXyP3gC0JeO3MSXyACPg4Vgy142M14zKa92KnglXfwFkBmwcMZaFGyUusbetaYHkJNrGaXuGCm3VWcihd0K)9MsiU20aKJZVJrP3gC0JaI5sbKJB2NM1aYrcn(1bWw40aRgsOH5(fwcd0K)9MsiU20KaTgdhj2kLzlUZxdppnaHVWan5FVPeIRnnjqRXWrc0Boa04sn8Tgy1ae(cd0K)9MsiU20KaTgdhjgQX2cPXLA4BGCajKBw5FHfqo(kI0aX1Mgnqqn(t71WpSRbo61OXWNgD5FBin49RrhTfon2xddPbZEsddPHmeHwEgPbS0GriKg)PvA4BnqV5aaPbC0aZMo61G7jvA47w1a9MdaKge(K3Ha(aXCPWaqmbihQmEgbcetbYXC)clGCAGWkVdbKJZVJrP3gC0JaI5sbKJB2NM1aYzO8qOtJNrAGvJ3gC0l(THspmbUKg(OXbnoOHu4VgTQXbnqYeJLEBWrpsGEBY7qAGrAGbnWin475SGCSvgrjwVSr0L14Ogh1OvngQX2cPXrnUwJdAiLgTQXBmQEXZDRudewibvgpJa14Ogy14GgoiKbc5wcNL2YjgYa9RbwnKqdWPVGIcMCGinWQXbnUTznEgjCW6gcaLajK)YPHNNgoiKbc5wchSUHaqP)Ksi5D2hjgYa9RHNNgsOHdEtLvVOwCNFkBKgh1WZtdKmXyP3gC0JeO3M8oKgxQXbnoObgxJRsJdAW3Zzb5yRmIsSEzJOlRbgPbg04Ogh1aJ04GgsPrRA8gJQx8C3k1aHfsqLXZiqnoQXrnWQHeAqo2kJibcYSjve(En8804GgKJTYisSvcbz2OHNNgh0GCSvgrITs8W)udppnihBLrKyReRx2OXrnWQHeA8gJQxGGDwcMt)jLYWHqVGkJNrGA45PbFpNfYZ2ahW1yjBCwTUKCNHSrCBSoPHpaQbgWt7ACudSACqdKmXyP3gC0JeO3M8oKgxQHuTRbgPXbnKsJw14ngvV45UvQbclKGkJNrGACuJJAGvdd9JXsYqU0OHpAGN214Q0GVNZc0Bt2ymXqn2winWinW4ACudSACqdj0GVNZca2cCiWe1id5stdvFIkAWTsMeDzn880GCSvgrITsiiZgn880qcnCWBQS6fa4FwR04Ogy1qcn475SySBQGDukpujz)j0w5olD6h90SMOldKdiHCZk)lSaY5kLYdHo14kdcR8oKgBwdj1YR9LYPXI0yid0)fA8N0qAydPbJqin(tR0apA82GJEKgBPrl2lB0aVDSvgrAWD)tn4a)w4fAWiesJ)0knKQDnG)jnCxePXwAyLFnWBhBLrKgWrJUSgpud8OXBdo6rAWtz4qAyA0I9YgnWBhBLrKqJwaSAZRXq5HqNAa2NTWPXvITahcud8UrgYLMgQEn6fJqin2sdoqMnAG3o2kJiGpqmxkFdetaYHkJNrGaXuGCm3VWciNmCCucMtL99HaYbKqUzL)fwa54RisJwieZ1awA4a1G7(NW(RHZKL3chqoUzFAwdihto5ojhaaFGyUu4pqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKJeAao9fuuWKdePbwnUTznEgjCGjhSa3FHLgy14Ggh0GVNZc0Bt2ymrxwdppnEJr1lqpXy2KaNn)cQmEgbQHNNgo4nvw9IAXD(PSrACudSACqdj0GVNZceKH(1rIUSgy1qcn475SWzPTCIUSgy14GgsOXBmQErUp(tWCIy9Ieuz8mcudppn475SWzPTCcW(y)cln8rdheYaHClrUp(tWCIy9Ied1yBH0OvnAlnoQbwnUTznEgj(ZzzSeIiaOjX12xdSACqdj0WbVPYQxulUZpLnsdppnCqideYTeoyDdbGs)jLqY7Sps0L1aRgh0GVNZc0Bt2ymXqn2winUudmOHNNgsOXBmQEb6jgZMe4S5xqLXZiqnoQXrnWQXBdo6f)2qPhMaxsdF0GVNZcNL2Yja7J9lS0aJ0ODbgtJJA45PbpeH0aRg5f35NgQX2cPXLAW3ZzHZsB5eG9X(fwACeiNBBsL1qa54atoybU)cRKbjGpqmxk8aetaYHkJNrGaXuGCm3VWciNXUPc2rP8qLK9dKdiHCZk)lSaYXxrKgTWHkj7xdU7FQHKA51(s5aYXn7tZAa5W3ZzHZsB5ed1yBH0WhnKcpA45PbFpNfolTLta2h7xyPXLA4721aRg32SgpJeoWKdwG7VWkzqc4deZLcJdetaYHkJNrGaXuGCm3VWcihhXi0VglzSfx1q1dKdiHCZk)lSaYXxrKgsQLx7lLtdyPHduJEXiesdRa1GTfPX(A0L1G7(NAijyDdbGaYXn7tZAa5CBZA8ms4atoybU)cRKbjnWQXbn475SWzPTCcW(y)cln8bqn8D7A45PHeA4G3uz1lUP6p9pACudppn475SySBQGDukpujz)IUSgy1GVNZIXUPc2rP8qLK9lgQX2cPXLAC1A0Qgoyb23xipKBruYylUQHQx8BdLUnwN0OvnoOHeAW3ZzbpdcbzD0l6YAGvdj04ngvVa92WGdOGkJNrGACe4deZLcJbetaYHkJNrGaXuGCCZ(0Sgqo32SgpJeoWKdwG7VWkzqcihZ9lSaYzlNnL9lSa(aXCPAlGycqouz8mceiMcKJ5(fwa5qnYqU0K4HfiqoGeYnR8VWcihFfrAG3nYqU0ObMclqnGLgoqn4U)PgCEBYgJPrxwdRa1az3Kgz4OXv0ziB0WkqnKulV2xkhqoUzFAwdihEicPbwn26PrgYSNat5f35NgQX2cPXLAifE0WZtJdAW3ZzH8SnWbCnwYgNvRlj3ziBe3gRtACPgyapTRHNNg89CwipBdCaxJLSXz16sYDgYgXTX6Kg(aOgyapTRXrnWQbFpNfO3MSXyIUSgy14GgoiKbc5wcNL2YjgQX2cPHpAG)TRHNNgGtFbffm5arACe4deZL6QbIja5qLXZiqGykqoM7xybKd6jgZMuMzdbKJZVJrP3gC0JaI5sbKJB2NM1aYzO8qOtJNrAGvJFBO0dtGlPHpAifE0aRgizIXsVn4OhjqVn5DinUud8xdSAyYj3j5aqdSACqd(EolCwAlNyOgBlKg(OHuTRHNNgsObFpNfolTLt0L14iqoGeYnR8VWciNRukpe6uJmZgsdyPrxwJhQHV14Tbh9in4U)jS)AiPwETVuon4PTWPHXd7VgpudcFY7qAyfOgf81aEtJZKL3chWhiMJH2bIja5qLXZiqGykqoM7xybKtUp(tWCIy9IaYbKqUzL)fwa54RisJwieV1yZASfAbjnSsd82XwzePHvGAW2I0yFn6YAWD)tnmnUIodzJgYd0PHvGA0sqt(3BsdoCTPbih3SpnRbKd5yRmIeBLSYVgy1GVNZc5zBGd4ASKnoRwxsUZq2iUnwN04snWaEAxdSACqdq4lmqt(3BkH4Attc0AmCK4xhaBHtdppnKqdh8MkRErrUbYGdOgEEAGKjgl92GJEKg(Obg04Ogy14Gg89Cwm2nvWokLhQKSFXqn2winUuJRwJRsJdAGhnWinMErz4GJeOTYDw60p6PznbvgpJa14Ogy1GVNZIXUPc2rP8qLK9l6YA45PHeAW3ZzXy3ub7OuEOsY(fDznoQbwnoOHeA4GqgiKBjCwAlNOlRHNNg89Cw8NZYyjeraqJa9MdanUudPWJgy1iV4o)0qn2winUudm0E7AGvJ8I78td1yBH0WhnKQ921WZtdj0ab7m(Taf)5Smwcrea0iOY4zeOgh1aRgh0ab7m(Taf)5Smwcrea0iOY4zeOgEEA4GqgiKBjCwAlNyOgBlKg(OHVBxJJaFGyogKciMaKdvgpJabIPa5yUFHfqoO3MSXya5asi3SY)clGC8vePHPbN3MSXyACLx0FQH8aDA0lgHqAW5TjBmMglsdJnKb6xJUSgWrd)WUg2qAy8W(RXd1aEtJZK1OLORaih3SpnRbKdFpNfWI(tusMghj)lSeDznWQXbn475Sa92KngtmuEi0PXZin880Wq)ySKmKlnA4JgxD7ACe4deZXagaIja5qLXZiqGykqoM7xybKd6TjBmgqoGeYnR8VWciNwqVrwJwIUcn4PmCinKeSUHaqAWD)tn482KngtdRa14pPsdoVnO(GJaYXn7tZAa54G3uz1lQf35NYgPbwnKqJ3yu9c0tmMnjWzZVGkJNrGAGvJdACBZA8ms4G1neakbsi)LtdppnCqideYTeolTLt0L1WZtd(EolCwAlNOlRXrnWQHdczGqULWbRBiau6pPesEN9rIHASTqACPg4CGIgdFAGrA4OLPXbnm0pgljd5sJgxRbEAxJJAGvd(EolqVnzJXed1yBH04snWFnWQHeAao9fuuWKdeb8bI5yW3aXeGCOY4zeiqmfih3SpnRbKJdEtLvVOwCNFkBKgy14Gg32SgpJeoyDdbGsGeYF50WZtdheYaHClHZsB5eDzn880GVNZcNL2Yj6YACudSA4GqgiKBjCW6gcaL(tkHK3zFKyOgBlKgxQbgxdSAW3Zzb6TjBmMOlRbwnihBLrKyRKv(1aRgsOXTnRXZiXIRGdLqVnO(GJ0aRgsOb40xqrbtoqeqoM7xybKd6Tb1hCeWhiMJb8hiMaKdvgpJabIPa5yUFHfqoO3guFWra5asi3SY)clGC8vePbN3guFWrAWD)tnSsJR8I(tnKhOtd4OXM1WpS3gqnG304mznAj6k0G7(NA4h2hnkcFVgod9cnAjdb1aS3iRrlrxHg2RXFsAqfOgWSg)jPbMDQ(t)Jg89CwJnRbN3MSXyAWf2zGvBEnYgJPbmN1aoA4h21WgsdyPbg04Tbh9iGCCZ(0Sgqo89Cwal6prjhJSjDVOfwIUSgEEACqdj0a92K3HeMCYDsoa0aRgsOXTnRXZiXIRGdLqVnO(GJ0WZtJdAW3ZzHZsB5ed1yBH04snWJgy1GVNZcNL2Yj6YA45PXbnoObFpNfolTLtmuJTfsJl1aNdu0y4tdmsdhTmnoOHH(XyjzixA04An8D7ACudSAW3ZzHZsB5eDzn880GVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIHASTqACPg4CGIgdFAGrA4OLPXbnm0pgljd5sJgxRHVBxJJAGvd(Eolg7MkyhLYdvs2FcTvUZsN(rpnRj6YACudSA4G3uz1lUP6p9pACuJJAGvJdAGKjgl92GJEKa92KngtJl1W3A45PXTnRXZib6TjBmwIlS(u2ySemN14Ogh1aRgsOXTnRXZiXIRGdLqVnO(GJ0aRgh0qcnMErz4GJe)2qCHtLahYA43cKgbvgpJa1WZtdKmXyP3gC0JeO3MSXyACPg(wJJaFGyogWdqmbihQmEgbcetbYXC)clGCkIBQbclGCajKBw5FHfqo(kI04kdclKgBPbhiZgnWBhBLrKgwbQbYUjnAHDgtJRmiS0idhnKulV2xkhqoUzFAwdiNdAW3Zzb5yRmIsiiZgXqn2win8rdcFKR)u63gsdppnoOH70gCesda1adAGvJHCN2GJs)2qACPg4rJJA45PH70gCesda1W3ACudSAyYj3j5aa4deZXaghiMaKdvgpJabIPa54M9PznGCoObFpNfKJTYikHGmBed1yBH0Whni8rU(tPFBin8804GgUtBWrinaudmObwngYDAdok9BdPXLAGhnoQHNNgUtBWrinaudFRXrnWQHjNCNKdanWQXbn475SySBQGDukpujz)IHASTqACPg4rdSAW3ZzXy3ub7OuEOsY(fDznWQHeAm9IYWbhjqBL7S0PF0tZAcQmEgbQHNNgsObFpNfJDtfSJs5Hkj7x0L14iqoM7xybKZPXYPgiSa(aXCmGXaIja5qLXZiqGykqoUzFAwdiNdAW3Zzb5yRmIsiiZgXqn2win8rdcFKR)u63gsdSACqdheYaHClHZsB5ed1yBH0WhnWt7A45PHdczGqULWbRBiau6pPesEN9rIHASTqA4Jg4PDnoQHNNgh0WDAdocPbGAGbnWQXqUtBWrPFBinUud8OXrn880WDAdocPbGA4BnoQbwnm5K7KCaObwnoObFpNfJDtfSJs5Hkj7xmuJTfsJl1apAGvd(Eolg7MkyhLYdvs2VOlRbwnKqJPxugo4ibARCNLo9JEAwtqLXZiqn880qcn475SySBQGDukpujz)IUSghbYXC)clGCYDgl1aHfWhiMJH2ciMaKdvgpJabIPa5asi3SY)clGC8vePbMfeV1awAiPwaqoM7xybKdxBMfojyorSEraFGyogUAGycqouz8mceiMcKdugihe9a5yUFHfqo32SgpJaY52yDcihKmXyP3gC0JeO3M8oKg(Ob(RrRAKzq4OXbnAm0tJ)0TX6KgyKgs1E7ACTgyODnoQrRAKzq4OXbn475Sa92G6dokrnYqU00q1NqqMnc0Boa04AnWFnocKdiHCZk)lSaYrsgZ1z2tin4Es)jnA8qn6isdoVn5Din2sdoqMnAW9CDNASinSxd8OXBdo6rTkLgz4ObDtJFnWq7ygnAm0tJFnGJg4VgCEBq9bhPbE3id5stdvVgO3CaGaY52MuzneqoO3M8ouARecYSb4deZ9D7aXeGCOY4zeiqmfihOmqoi6bYXC)clGCUTznEgbKZTX6eqosPX1AGKjglDAON04snWGgxLgh0ODbg0aJ04GgizIXsVn4OhjqVn5DinUknKsJJAGrACqdP0OvnEJr1lqWolbZP)Ksz4qOxqLXZiqnWinKsGhnoQXrnAvJ2fsHhnWin475SySBQGDukpujz)IHASTqa5asi3SY)clGCKKXCDM9esdUN0FsJgpudmRX(tna7Zw40Ofoujz)a5CBtQSgcihUJ9NPTs5Hkj7h4deZ9TuaXeGCOY4zeiqmfihZ9lSaYH7y)jqoGeYnR8VWcihFfrAGzn2FQXwAWbYSrd82XwzePbC0yZAuqn482K3H0G7YyAK3xJTEOgsQLx7lLtdR83ahcih3SpnRbKZbnihBLrKG1lBsfHVxdppnihBLrKWk)PIW3RbwnUTznEgjwuYXi7M04Ogy14GgVn4Ox8BdLEycCjn8rd8xdppnihBLrKG1lBsBLWGgEEAKxCNFAOgBlKgxQHuTRXrn880GVNZcYXwzeLqqMnIHASTqACPgM7xyjqVn5DibHpY1Fk9BdPbwn475SGCSvgrjeKzJOlRHNNgKJTYisSvcbz2ObwnKqJBBwJNrc0BtEhkTvcbz2OHNNg89Cw4S0woXqn2winUudZ9lSeO3M8oKGWh56pL(TH0aRgsOXTnRXZiXIsogz3Kgy1GVNZcNL2YjgQX2cPXLAq4JC9Ns)2qAGvd(EolCwAlNOlRHNNg89Cwm2nvWokLhQKSFrxwdSACBZA8msWDS)mTvkpujz)A45PHeACBZA8msSOKJr2nPbwn475SWzPTCIHASTqA4Jge(ix)P0VneWhiM7BmaetaYHkJNrGaXuGCajKBw5FHfqo(kI0GZBtEhsJnRXwA0I9YgnWBhBLr0fASLgCGmB0aVDSvgrAalnW)w14Tbh9inGJgpud5b60GdKzJg4TJTYicihZ9lSaYb92K3Ha(aXCF7BGycqouz8mceiMcKdiHCZk)lSaYPfAm2FoDGCm3VWciNPxjZ9lSsSf9a5Ww0NkRHaYjBm2FoDGpWhiNSXy)50bIjaXCPaIja5qLXZiqGykqoM7xybKd6Tb1hCeqoGeYnR8VWcihoVnO(GJ0idhnAG3udvVg9IriKgD0w40atHTetaYXn7tZAa5iHgtVOmCWrcEJzLJsWCYyS0FUfoKGWR(kltGaFGyogaIja5qLXZiqGykqoM7xybKdQx5DiGCC(Dmk92GJEeqmxkGCCZ(0SgqoGWx0aHvEhsmuJTfsdF0yOgBlKgyKgyadACTgs1wa5asi3SY)clGCKKHEn(tsdq4Rb39p14pjnAGOxJFBinEOggiOg96xMg)jPrJHpna7J9lS0yrACUVqdo9kVdPXqn2winA6SFLzlbQXd1OXE3PgnqyL3H0aSp2VWc4deZ9nqmbihZ9lSaYPbcR8oeqouz8mceiMc8b(a5GEGycqmxkGycqouz8mceiMcKJ5(fwa5GEBq9bhbKdiHCZk)lSaYXxrKgCEBq9bhPXd1aaIK1OlRXFsA0cgYA43cKgn475SgBwJ91GlSZa1GWN8oKg8ugoKg5Tw05w404pjnkcFVgod9AahnEOgG9gzn4PmCinKeSUHaqa54M9PznGCMErz4GJe)2qCHtLahYA43cKgbvgpJa1aRgh0GCSvgrITsw5xdSAiHgh04Gg89Cw8BdXfovcCiRHFlqAed1yBH0Whnm3VWsWDS)uq4JC9Ns)2qA0QgTlKsdSACqdYXwzej2kXd)tn880GCSvgrITsiiZgn880GCSvgrcwVSjve(EnoQHNNg89Cw8BdXfovcCiRHFlqAed1yBH0Whnm3VWsGEBY7qccFKR)u63gsJw1ODHuAGvJdAqo2kJiXwjwVSrdppnihBLrKabz2KkcFVgEEAqo2kJiHv(tfHVxJJACudppnKqd(Eol(TH4cNkboK1WVfinIUSgh1WZtJdAW3ZzHZsB5eDzn88042M14zKWbRBiaucKq(lNgh1aRgoiKbc5wchSUHaqP)Ksi5D2hjgYa9RbwnCWBQS6f1I78tzJ04Ogy14GgsOHdEtLvVaa)ZALgEEA4GqgiKBjOgzixAs8WcumuJTfsdF0OT04Ogy14Gg89Cw4S0worxwdppnKqdheYaHClHZsB5edzG(14iWhiMJbGycqouz8mceiMcKJ5(fwa5yGM8V3ucX1MgGCC(Dmk92GJEeqmxkGCCZ(0SgqosObi8fgOj)7nLqCTPjbAngos8RdGTWPbwnKqdZ9lSegOj)7nLqCTPjbAngosSvkZwCNVgy14GgsObi8fgOj)7nLqCTPjDsgt8RdGTWPHNNgGWxyGM8V3ucX1MM0jzmXqn2win8rd8OXrn880ae(cd0K)9MsiU20KaTgdhjqV5aqJl1W3AGvdq4lmqt(3BkH4Attc0AmCKyOgBlKgxQHV1aRgGWxyGM8V3ucX1MMeO1y4iXVoa2chqoGeYnR8VWcihFfrA0sqt(3BsdoCTPrdUNuPXFsdPXI0OGAyUFVjnqCTP5cnmKgm7jnmKgYqeA5zKgWsdexBA0G7(NAGbnGJgzIlnAGEZbasd4ObS0W0W3TQbIRnnAGGA8N2RXFsAuexnqCTPrdBM9MqAGzth9Ay5Ngn(t71aX1Mgni8jVdHa(aXCFdetaYHkJNrGaXuGCm3VWcihhSUHaqP)Ksi5D2hbKdiHCZk)lSaYXxresdjbRBiaKgBwdj1YR9LYPXI0OlRbC0WpSRHnKgGeYF52cNgsQLx7lLtdU7FQHKG1neasdRa1WpSRHnKg8edYvd8VDnAj6kaYXn7tZAa5iHgGtFbffm5arAGvJdACqJBBwJNrchSUHaqjqc5VCAGvdj0WbHmqi3s4S0woXqgOFnWQHeAm9IYWbhjKNTboGRXs24SADj5odzJGkJNrGA45PbFpNfolTLt0L14Ogy1Wq)ySKmKlnACjGAG)TRbwnoObFpNfKJTYikX6LnIHASTqA4Jgs1UgEEAW3Zzb5yRmIsiiZgXqn2win8rdPAxJJA45PbpeH0aRg5f35NgQX2cPXLAiv7AGvdj0WbHmqi3s4S0woXqgOFnoc8bI54pqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKZbn475SySBQGDukpujz)IHASTqA4Jg4rdppnKqd(Eolg7MkyhLYdvs2VOlRXrnWQHeAW3ZzXy3ub7OuEOsY(tOTYDw60p6PznrxwdSACqd(EolaylWHatuJmKlnnu9jQOb3kzsmuJTfsJl1aNdu0y4tJJAGvJdAW3Zzb5yRmIsiiZgXqn2win8rdCoqrJHpn880GVNZcYXwzeLy9YgXqn2win8rdCoqrJHpn8804GgsObFpNfKJTYikX6LnIUSgEEAiHg89Cwqo2kJOecYSr0L14Ogy1qcnEJr1lqqg6xhjOY4zeOghbYbKqUzL)fwa5ijybU)clnYWrdJX0ae(in(t71OXaGqAG6dPXFs(1WgQAZRXq5HqNeOgCpPsJRu7MkyhPrlCOsY(140qAWiesJ)0knWJgiYH0yOgBRTWPbC04pjnaW)SwPbFpN1yrAy8W(RXd1iBmMgWCwd4OHv(1aVDSvgrASinmEy)14HAq4tEhciNBBsL1qa5ac)0q4vFhQHQhb8bI54biMaKdvgpJabIPa5aLbYbrpqoM7xybKZTnRXZiGCUnwNaY5GgsObFpNfKJTYikHGmBeDznWQHeAW3Zzb5yRmIsSEzJOlRXrn8804ngvVabzOFDKGkJNrGa5asi3SY)clGCKeSa3FHLg)P9A4ojhain2Sg(HDnSH0a2F0csAqo2kJinEOgWI5xdq4RXFsdPbC0yXvWH04pxKgC3)udoqg6xhbKZTnPYAiGCaHFc2F0csjYXwzeb8bI5yCGycqouz8mceiMcKJ5(fwa50aHvEhcih3SpnRbKZq5HqNgpJ0aRgh0GVNZcYXwzeLqqMnIHASTqA4Jgd1yBH0WZtd(EolihBLruI1lBed1yBH0WhngQX2cPHNNg32SgpJeGWpb7pAbPe5yRmI04Ogy1yO8qOtJNrAGvJ3gC0l(THspmbUKg(OHuyqdSAyYj3j5aqdSACBZA8msac)0q4vFhQHQhbKJZVJrP3gC0JaI5sb8bI5ymGycqouz8mceiMcKJ5(fwa5G6vEhcih3SpnRbKZq5HqNgpJ0aRgh0GVNZcYXwzeLqqMnIHASTqA4Jgd1yBH0WZtd(EolihBLruI1lBed1yBH0WhngQX2cPHNNg32SgpJeGWpb7pAbPe5yRmI04Ogy1yO8qOtJNrAGvJ3gC0l(THspmbUKg(OHuyqdSAyYj3j5aqdSACBZA8msac)0q4vFhQHQhbKJZVJrP3gC0JaI5sb8bI5TfqmbihQmEgbcetbYXC)clGCqpXy2KYmBiGCCZ(0SgqodLhcDA8msdSACqd(EolihBLrucbz2igQX2cPHpAmuJTfsdppn475SGCSvgrjwVSrmuJTfsdF0yOgBlKgEEACBZA8msac)eS)OfKsKJTYisJJAGvJHYdHonEgPbwnEBWrV43gk9We4sA4JgsHX1aRgMCYDsoa0aRg32SgpJeGWpneE13HAO6ra5487yu6Tbh9iGyUuaFGy(vdetaYHkJNrGaXuGCm3VWciNmCCucMtL99HaYbKqUzL)fwa54RisJwieZ1awA4a1G7(NW(RHZKL3chqoUzFAwdihto5ojhaaFGyUuTdetaYHkJNrGaXuGCm3VWcihQrgYLMepSabYbKqUzL)fwa54RisJReBboeOgCK3zFKgC3)udR8Rbdw40Gkyh3Pgmd9BHtd82XwzePHvGA8JFnEOgSTin2xJUSgC3)uJROZq2OHvGAiPwETVuoGCCZ(0Sgqoh04Gg89Cwqo2kJOecYSrmuJTfsdF0qQ21WZtd(EolihBLruI1lBed1yBH0WhnKQDnoQbwnCqideYTeolTLtmuJTfsdF0W3TRbwnoObFpNfYZ2ahW1yjBCwTUKCNHSrCBSoPXLAGb8VDn880qcnMErz4GJeYZ2ahW1yjBCwTUKCNHSrq4vFLLjqnoQXrn880GVNZc5zBGd4ASKnoRwxsUZq2iUnwN0Wha1adyS21WZtd(EolCwAlNyOgBlKg(OHuTd8bI5sjfqmbihQmEgbcetbYbkdKdIEGCm3VWciNBBwJNra5CBSobKJeAao9fuuWKdePbwnUTznEgjCGjhSa3FHLgy14Ggh0WbHmqi3sqnY(hYyj4aww5iXqn2winUudPW4ymnAvJdAiLuAGrAm9IYWbhjqBL7S0PF0tZAcQmEgbQXrnWQbHx9vwMafuJS)HmwcoGLvosJJA45PHH(XyjzixA0Wha14QBxdSACqdj04ngvVi3h)jyorSErcQmEgbQHNNg89Cw4S0wobyFSFHLg(OHdczGqULi3h)jyorSErIHASTqA0QgTLgh1aRgGWxG6vEhsmuJTfsdF0qkmObwnaHVObcR8oKyOgBlKg(OrBPbwnoObi8fONymBszMnKyOgBlKg(OrBPHNNgsOXBmQEb6jgZMuMzdjOY4zeOgh1aRg32SgpJe)5Smwcrea0K4A7RbwnoOHdczGqULGAKHCPjXdlqrxwdppnKqdh8MkREba(N1knoQbwnEBWrV43gk9We4sA4Jg89Cw4S0wobyFSFHLgyKgTlWyA45PbpeH0aRg5f35NgQX2cPXLAW3ZzHZsB5eG9X(fwA45PHdEtLvVOwCNFkBKgEEAW3ZzbpdcbzD0l6YAGvd(Eol4zqiiRJEXqn2winUud(EolCwAlNaSp2VWsJw14GgxTgyKgtVOmCWrc5zBGd4ASKnoRwxsUZq2ii8QVYYeOgh14Ogy1qcn475SWzPTCIUSgy14GgsOHdEtLvVOwCNFkBKgEEA4GqgiKBjCW6gcaL(tkHK3zFKOlRHNNg8qesdSAKxCNFAOgBlKgxQHdczGqULWbRBiau6pPesEN9rIHASTqA0QgyCn880iV4o)0qn2winWmAivB1UgxQbFpNfolTLta2h7xyPXrGCajKBw5FHfqo(kI0qsT8AFPCAWD)tnKeSUHaqxFLylWHa1GJ8o7J0WkqnaHvBEnG30WD2N04k6mKnAahn4EsLgykdcbzD0RbxyNbQbHp5Din4PmCinKulV2xkNge(K3Hqa5CBtQSgcihhyYblW9xyLqpWhiMlfgaIja5qLXZiqGykqoqzGCq0dKJ5(fwa5CBZA8mciNBJ1jGCKqdWPVGIcMCGinWQXTnRXZiHdm5Gf4(lS0aRgh04GgoiKbc5wcQr2)qglbhWYkhjgQX2cPXLAifghJPrRACqdPKsdmsJPxugo4ibARCNLo9JEAwtqLXZiqnoQbwni8QVYYeOGAK9pKXsWbSSYrACudppnm0pgljd5sJg(aOgxD7AGvJdAiHgVXO6f5(4pbZjI1lsqLXZiqn880GVNZcNL2Yja7J9lS0WhnCqideYTe5(4pbZjI1lsmuJTfsJw1OT04Ogy1ae(cuVY7qIHASTqA4JgTLgy1ae(IgiSY7qIHASTqA4JgxTgy14GgGWxGEIXSjLz2qIHASTqA4Jgs1UgEEAiHgVXO6fONymBszMnKGkJNrGACudSACBZA8ms8NZYyjeraqtIRTVgy14Gg89CwaWwGdbMOgzixAAO6turdUvYKOlRHNNgsOHdEtLvVaa)ZALgh1aRgVn4Ox8BdLEycCjn8rd(EolCwAlNaSp2VWsdmsJ2fymn880GhIqAGvJ8I78td1yBH04sn475SWzPTCcW(y)cln880WbVPYQxulUZpLnsdppn475SGNbHGSo6fDznWQbFpNf8mieK1rVyOgBlKgxQbFpNfolTLta2h7xyPrRACqJRwdmsJPxugo4iH8SnWbCnwYgNvRlj3ziBeeE1xzzcuJJACudSAiHg89Cw4S0worxwdSACqdj0WbVPYQxulUZpLnsdppnCqideYTeoyDdbGs)jLqY7Sps0L1WZtdEicPbwnYlUZpnuJTfsJl1WbHmqi3s4G1neak9NucjVZ(iXqn2winAvdmUgEEAWdrinWQrEXD(PHASTqAGz0qQ2QDnUud(EolCwAlNaSp2VWsJJa5CBtQSgcihhyYblW9xyLqpWhiMlLVbIja5qLXZiqGykqoM7xybKZy3ub7OuEOsY(bYbKqUzL)fwa54RisJ)K0aZov)P)rdU7FQHPHKA51(s504pTxJfvT51ipWgnUIodzdqoUzFAwdih(EolCwAlNyOgBlKg(OHu4rdppn475SWzPTCcW(y)clnUudFJbnWQXTnRXZiHdm5Gf4(lSsOh4deZLc)bIja5qLXZiqGykqoUzFAwdiNBBwJNrchyYblW9xyLqVgy14Gg89Cw4S0wobyFSFHLg(aOg(gdA45PHeA4G3uz1lUP6p9pACudppn475SySBQGDukpujz)IUSgy1GVNZIXUPc2rP8qLK9lgQX2cPXLAC1A0Qgoyb23xipKBruYylUQHQx8BdLUnwN0OvnoOHeAW3ZzbpdcbzD0l6YAGvdj04ngvVa92WGdOGkJNrGACeihZ9lSaYXrmc9RXsgBXvnu9aFGyUu4biMaKdvgpJabIPa54M9PznGCUTznEgjCGjhSa3FHvc9a5yUFHfqoB5SPSFHfWhiMlfghiMaKdvgpJabIPa5aLbYbrpqoM7xybKZTnRXZiGCUnwNaYrcnCqideYTeolTLtmKb6xdppnKqJBBwJNrchSUHaqjqc5VCAGvdh8MkRErT4o)u2in880aC6lOOGjhicihqc5Mv(xybKdMDBwJNrA0reOgWsdJFz7VesJ)0En4A1RXd1GN0az3eOgz4OHKA51(s50ab14pTxJ)K8RHnu9AW1qpbQbMnD0RbpLHdPXFsna5CBtQSgcihKDtPmCsolTLd4deZLcJbetaYHkJNrGaXuGCm3VWciNCF8NG5eX6fbKdiHCZk)lSaYXxresJwieV1yZASLgwPbE7yRmI0Wkqn(zjKgpud2wKg7RrxwdU7FQXv0ziBUqdj1YR9LYPHvGA0sqt(3BsdoCTPbih3SpnRbKd5yRmIeBLSYVgy1WKtUtYbGgy1GVNZc5zBGd4ASKnoRwxsUZq2iUnwN04snWa(3Ugy14GgGWxyGM8V3ucX1MMeO1y4iXVoa2cNgEEAiHgo4nvw9IICdKbhqnoQbwnUTznEgjq2nLYWj5S0wonWQXbn475SySBQGDukpujz)IHASTqACPgxTgxLgh0apAGrAm9IYWbhjqBL7S0PF0tZAcQmEgbQrRAiHgeE1xzzcuSf6NU7HdkbU3BrjEIX04Ogy1GVNZIXUPc2rP8qLK9l6YA45PHeAW3ZzXy3ub7OuEOsY(fDznoQbwnoOHeA4G3uz1laW)SwPHNNgoiKbc5wcQrgYLMepSafd1yBH0WhnWq7ACe4deZLQTaIja5qLXZiqGykqoM7xybKd6TjBmgqoGeYnR8VWcihFfrACLx0FQbN3MSXyAipqhsJnRbN3MSXyASOQnVgDzGCCZ(0Sgqo89Cwal6prjzACK8VWs0L1aRg89CwGEBYgJjgkpe604zeWhiMl1vdetaYHkJNrGaXuGCCZ(0Sgqo89CwGEByWbumuJTfsJl1apAGvJdAW3Zzb5yRmIsiiZgXqn2win8rd8OHNNg89Cwqo2kJOeRx2igQX2cPHpAGhnoQbwnm0pgljd5sJg(OXv3oqoM7xybKJZkhXs89Cgih(EoNkRHaYb92WGdiWhiMJH2bIja5qLXZiqGykqoM7xybKd6Tb1hCeqoGeYnR8VWciNwqVrgPrlrxHg8ugoKgscw3qain6OTWPXFsAijyDdbG0WblW9xyPXd1WDsoa0yZAijyDdbG0yrAyUVBmMFnmEy)14HAWtA4m0dKJB2NM1aYXbVPYQxulUZpLnsdSACBZA8ms4G1neakbsi)LtdSA4GqgiKBjCW6gcaL(tkHK3zFKyOgBlKgxQbE0aRgsOb40xqrbtoqKgy1GCSvgrITsw5xdSAyOFmwsgYLgn8rd8VDGpqmhdsbetaYHkJNrGaXuGCm3VWcih0Bt2ymGCajKBw5FHfqo(kI0GZBt2ymn4U)PgCEIXSrJwWS5xdRa1OGAW5THbhWl0G7jvAuqn482KngtJfPrx(cn8d7AydPXwA0I9YgnWBhBLrKgz4OrB1kICinGJgpud5b604k6mKnAW9KknmE4nPXv3UgTeDfAahnmqz73BsdexBA040qA0wTIihsJHAST2cNgWrJfPXwAKzlUZxObMdFsJ)0En6finA8NKgiRH0WblW9xyH0y)2G0augPrr9FmMgpudoVnzJX0aSpBHtJRu7MkyhPrlCOsY(VqdUNuPHFyVnGAG(LX0Gkqn6YAWD)tnU62B1qYAKHJg)jPbZqVg4yqEJHea54M9PznGCEJr1lqpXy2KaNn)cQmEgbQbwnKqJ3yu9c0BddoGcQmEgbQbwn475Sa92KngtmuEi0PXZinWQXbn475SGCSvgrjwVSrmuJTfsdF0OT0aRgKJTYisSvI1lB0aRg89CwipBdCaxJLSXz16sYDgYgXTX6KgxQbgWt7A45PbFpNfYZ2ahW1yjBCwTUKCNHSrCBSoPHpaQbgWt7AGvdd9JXsYqU0OHpAC1TRHNNgGWxyGM8V3ucX1MMeO1y4iXqn2win8rJ2sdppnm3VWsyGM8V3ucX1MMeO1y4iXwPmBXD(ACudSA4GqgiKBjCwAlNyOgBlKg(OHuTd8bI5yadaXeGCOY4zeiqmfihZ9lSaYb92G6docihqc5Mv(xybKJVIin482G6dosJR8I(tnKhOdPHvGAa2BK1OLORqdUNuPHKA51(s50aoA8NKgy2P6p9pAW3ZznwKggpS)A8qnYgJPbmN1aoA4h2BdOgotwJwIUcGCCZ(0Sgqo89Cwal6prjhJSjDVOfwIUSgEEAW3ZzbaBboeyIAKHCPPHQprfn4wjtIUSgEEAW3ZzHZsB5eDznWQXbn475SySBQGDukpujz)IHASTqACPg4CGIgdFAGrA4OLPXbnm0pgljd5sJgxRHVBxJJA0Qg(wdmsJ3yu9II4MAGWsqLXZiqnWQHeAm9IYWbhjqBL7S0PF0tZAcQmEgbQbwn475SySBQGDukpujz)IUSgEEAW3ZzHZsB5ed1yBH04snW5afng(0aJ0WrltJdAyOFmwsgYLgnUwdF3Ugh1WZtd(Eolg7MkyhLYdvs2FcTvUZsN(rpnRj6YA45PXbn475SySBQGDukpujz)IHASTqACPgM7xyjqVn5DibHpY1Fk9BdPbwnqYeJLon0tACPgTlWFn880GVNZIXUPc2rP8qLK9lgQX2cPXLAyUFHLG7y)PGWh56pL(TH0WZtJBBwJNrIfVatoybU)clnWQHdczGqULylKB6VXZOeE1T67njq6EDKyid0Vgy1GWR(kltGITqUP)gpJs4v3QV3KaP71rACudSAW3ZzXy3ub7OuEOsY(fDzn880qcn475SySBQGDukpujz)IUSgy1qcnCqideYTeJDtfSJs5Hkj7xmKb6xdppnKqdh8MkREXnv)P)rJJA45PHH(XyjzixA0WhnU621aRgKJTYisSvYk)aFGyog8nqmbihQmEgbcetbYXC)clGCqVnO(GJaYbKqUzL)fwa5GjJFnEOgngaKg)jPbpHEnGzn482WGdOg8(1a9MdGTWPX(A0L1aV6RdaMFn2sdR8RbE7yRmI0GV)ACfDgYgnwu9Ay8W(RXd1GN0qEGohbcKJB2NM1aY5ngvVa92WGdOGkJNrGAGvdj0y6fLHdos8BdXfovcCiRHFlqAeuz8mcudSACqd(EolqVnm4ak6YA45PHH(XyjzixA0WhnU6214Ogy1GVNZc0BddoGc0Boa04sn8Tgy14Gg89Cwqo2kJOecYSr0L1WZtd(EolihBLruI1lBeDznoQbwn475SqE2g4aUglzJZQ1LK7mKnIBJ1jnUudmGXAxdSACqdheYaHClHZsB5ed1yBH0WhnKQDn880qcnUTznEgjCW6gcaLajK)YPbwnCWBQS6f1I78tzJ04iWhiMJb8hiMaKdvgpJabIPa5aLbYbrpqoM7xybKZTnRXZiGCUnwNaYHCSvgrITsSEzJgyKgTLgxRH5(fwc0BtEhsq4JC9Ns)2qA0QgsOb5yRmIeBLy9YgnWinoObgxJw14ngvVab7SemN(tkLHdHEbvgpJa1aJ0W3ACuJR1WC)clb3X(tbHpY1Fk9BdPrRA0Ua)XJgxRbsMyS0PHEsJw1ODbE0aJ04ngvVOSVpekXBmRCKGkJNrGa5asi3SY)clGCWB0Vn2tinoHC1OP7o1OLORqdBinWzBrGAitJgiYblqGCUTjvwdbKJHKVcA4qoGpqmhd4biMaKdvgpJabIPa5yUFHfqoO3guFWra5asi3SY)clGCAb9gzn482G6dosJT0W0aJ1kICAWbYSrd82XwzeDHgGWQnVgm61yFnKhOtJROZq2OXH)0EnwKgNwbYiqn49RbT)jnA8NKgCEBYgJPbBlsd4OXFsA0s0v4Zv3UgSTinYWrdoVnO(GJoEHgGWQnVgWBA4o7tAyLgx5f9NAipqNgwbQbJEn(tsdJhEtAW2I040kqgPbN3ggCabYXn7tZAa5iHgtVOmCWrIFBiUWPsGdzn8BbsJGkJNrGAGvJdAW3ZzH8SnWbCnwYgNvRlj3ziBe3gRtACPgyaJ1UgEEAW3ZzH8SnWbCnwYgNvRlj3ziBe3gRtACPgyapTRbwnEJr1lqpXy2KaNn)cQmEgbQXrnWQXbnihBLrKyRecYSrdSAyOFmwsgYLgnAvJBBwJNrcdjFf0WHCAGrAW3Zzb5yRmIsiiZgXqn2winAvdq4lY9XFcMteRxK4xhaO0qn2wAGrAGbbE0WhnAR21WZtdYXwzej2kX6LnAGvdd9JXsYqU0OrRACBZA8msyi5RGgoKtdmsd(EolihBLruI1lBed1yBH0OvnaHVi3h)jyorSErIFDaGsd1yBPbgPbge4rdF04QBxJJAGvdj0GVNZcyr)jkjtJJK)fwIUSgy1qcnEJr1lqVnm4akOY4zeOgy14GgoiKbc5wcNL2YjgQX2cPHpAGX0WZtdeSZ43cu8NZYyjeraqJGkJNrGAGvd(Eol(ZzzSeIiaOrGEZbGgxQHV9TgxLgh0y6fLHdosG2k3zPt)ONM1euz8mcudmsd8OXrnWQrEXD(PHASTqA4Jgs1E7AGvJ8I78td1yBH04snWq7TRHNNgGtFbffm5arACudSACqdheYaHClbaBboeycjVZ(iXqn2win8rdmMgEEAiHgo4nvw9ca8pRvACe4deZXaghiMaKdvgpJabIPa5yUFHfqofXn1aHfqoGeYnR8VWcihFfrACLbHfsJT0Of7LnAG3o2kJinScudKDtACLSXYT2c7mMgxzqyPrgoAiPwETVuonScuJReBboeOg4DJmKlnnu9a54M9PznGCoObFpNfKJTYikX6LnIHASTqA4Jge(ix)P0VnKgEEACqd3Pn4iKgaQbg0aRgd5oTbhL(TH04snWJgh1WZtd3Pn4iKgaQHV14Ogy1WKtUtYbGgy142M14zKaz3ukdNKZsB5a(aXCmGXaIja5qLXZiqGykqoUzFAwdiNdAW3Zzb5yRmIsSEzJyOgBlKg(ObHpY1Fk9BdPbwnKqdh8MkREba(N1kn8804Gg89CwaWwGdbMOgzixAAO6turdUvYKOlRbwnCWBQS6fa4FwR04OgEEACqd3Pn4iKgaQbg0aRgd5oTbhL(TH04snWJgh1WZtd3Pn4iKgaQHV1WZtd(EolCwAlNOlRXrnWQHjNCNKdanWQXTnRXZibYUPugojNL2YPbwnoObFpNfJDtfSJs5Hkj7xmuJTfsJl14Gg4rJRsdmObgPX0lkdhCKaTvUZsN(rpnRjOY4zeOgh1aRg89Cwm2nvWokLhQKSFrxwdppnKqd(Eolg7MkyhLYdvs2VOlRXrGCm3VWciNtJLtnqyb8bI5yOTaIja5qLXZiqGykqoUzFAwdiNdAW3Zzb5yRmIsSEzJyOgBlKg(ObHpY1Fk9BdPbwnKqdh8MkREba(N1kn8804Gg89CwaWwGdbMOgzixAAO6turdUvYKOlRbwnCWBQS6fa4FwR04OgEEACqd3Pn4iKgaQbg0aRgd5oTbhL(TH04snWJgh1WZtd3Pn4iKgaQHV1WZtd(EolCwAlNOlRXrnWQHjNCNKdanWQXTnRXZibYUPugojNL2YPbwnoObFpNfJDtfSJs5Hkj7xmuJTfsJl1apAGvd(Eolg7MkyhLYdvs2VOlRbwnKqJPxugo4ibARCNLo9JEAwtqLXZiqn880qcn475SySBQGDukpujz)IUSghbYXC)clGCYDgl1aHfWhiMJHRgiMaKdvgpJabIPa5asi3SY)clGC8vePbMfeV1awA4abYXC)clGC4AZSWjbZjI1lc4deZ9D7aXeGCOY4zeiqmfihZ9lSaYb92K3HaYbKqUzL)fwa54RisdoVn5DinEOgYd0PbhiZgnWBhBLr0fAiPwETVuononKgmcH043gsJ)0knmnWSg7p1GWh56pPbJYVgWrdyX8Rrl2lB0aVDSvgrASin6Ya54M9PznGCihBLrKyReRx2ObwnKqd(Eolg7MkyhLYdvs2VOlRHNNgKJTYisGGmBsfHVxdppnihBLrKWk)PIW3RHNNgh0GVNZcU2mlCsWCIy9IeDzn880ajtmw60qpPXLA0Ua)XJgy1qcnCWBQS6f3u9N(hn880ajtmw60qpPXLA0Ua)1aRgo4nvw9IBQ(t)Jgh1aRg89Cwqo2kJOeRx2i6YA45PXbn475SWzPTCIHASTqACPgM7xyj4o2Fki8rU(tPFBinWQbFpNfolTLt0L14iWhiM7BPaIja5qLXZiqGykqoGeYnR8VWcihFfrAGzn2FQb8pPH7Iin4EUUtnwKgBPbhiZgnWBhBLr0fAiPwETVuonGJgpud5b60Of7LnAG3o2kJiGCm3VWcihUJ9NaFGyUVXaqmbihQmEgbcetbYbKqUzL)fwa50cng7pNoqoM7xybKZ0RK5(fwj2IEGCyl6tL1qa5Kng7pNoWh4dKJ8qoydV9aXeGyUuaXeGCm3VWciha2cCiWesEN9ra5qLXZiqGykWhiMJbGycqouz8mceiMcKdugihe9a5yUFHfqo32SgpJaY52yDciN2bYbKqUzL)fwa5GjNKg32SgpJ0yrAGOxJhQr7AWD)tnkOgO3EnGLgDePXpBba9Ol0qkn4EsLg)jPrEh0RbSinwKgWsJoIUqdmOXM14pjnqKdwGASinScudFRXM1Gh(NAydbKZTnPYAiGCGvQJO0pBba9aFGyUVbIja5qLXZiqGykqoqzGCmqqGCm3VWciNBBwJNra5CBSobKJua54M9PznGC(zlaOx8sjonuQJOeFpN1aRg)Sfa0lEPeoiKbc5wcW(y)clnWQHeA8ZwaqV4LsSiXdBOemNAGf6hyhLCWc9t39lSqa5CBtQSgcihyL6ik9ZwaqpWhiMJ)aXeGCOY4zeiqmfihOmqogiiqoM7xybKZTnRXZiGCUnwNaYbda54M9PznGC(zlaOx8yqCAOuhrj(EoRbwn(zlaOx8yq4GqgiKBja7J9lS0aRgsOXpBba9IhdIfjEydLG5udSq)a7OKdwOF6UFHfciNBBsL1qa5aRuhrPF2ca6b(aXC8aetaYHkJNrGaXuGCGYa5yGGa5yUFHfqo32SgpJaY52MuzneqoWk1ru6NTaGEGCCZ(0SgqoeE1xzzcuSfYn934zucV6w99MeiDVosdppni8QVYYeOGAK9pKXsWbSSYrA45PbHx9vwMafiyNXO)3cxA68(bYbKqUzL)fwa5GjNeI04NTaGEKg2qAuWxdR)Wg7xNXy(1aKEY9eOggsdyPrhrAGE714NTaGEKqdn4qVg32SgpJ04HAG)Ayin(tYVggdb1OicudKm5wJPXPvGSTWjaY52yDcih8h4deZX4aXeGCm3VWciNgiSayRugona5qLXZiqGykWhiMJXaIja5qLXZiqGykqoM7xybKd3X(tGCCZ(0Sgqoh0GCSvgrcwVSjve(En880GCSvgrITsiiZgn880GCSvgrITs8W)udppnihBLrKWk)PIW3RXrGCyBrjhiqos1oWh4d8bY5Mg0clGyogAhds1(vlfghihU2uBHdbKdMvlVsXCFbZVsc)QHgyYjPX2idNxJmC0OnqzQOPnAmeE13Ha1abBinS(dBSNa1WDAfocjuPBXTinWa(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghKcFhfQ0T4wKg(g)QHKG1nnpbQrBMErz4GJe4N2OXd1OntVOmCWrc8JGkJNrGTrJdsHVJcvAvAmRwELI5(cMFLe(vdnWKtsJTrgoVgz4OrBaPS1zFB0yi8QVdbQbc2qAy9h2ypbQH70kCesOs3IBrAGXXVAijyDtZtGAWzBKKgi)1B4tdmJgpuJwSBAaU3lAHLgqzAShoAC46JACqk8DuOs3IBrAGXXVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0aJHF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPrBHF1qsW6MMNa1GZ2ijnq(R3WNgygnEOgTy30aCVx0clnGY0ypC04W1h14agW3rHkDlUfPrBHF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPXvJF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPXvJF1qsW6MMNa1On)Sfa0lKsGFAJgpuJ28ZwaqV4LsGFAJghWa(okuPBXTinUA8Rgscw308eOgT5NTaGEbge4N2OXd1On)Sfa0lEmiWpTrJdyaFhfQ0T4wKgs1o(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghKcFhfQ0T4wKgsjf(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghKcFhfQ0T4wKgsHb8Rgscw308eOgTz6fLHdosGFAJgpuJ2m9IYWbhjWpcQmEgb2gnoif(okuPBXTinKY34xnKeSUP5jqnAZ0lkdhCKa)0gnEOgTz6fLHdosGFeuz8mcSnACqk8DuOs3IBrAifEWVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0qkmo(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghWa(okuPBXTinKcJJF1qsW6MMNa1On)Sfa0lKsGFAJgpuJ28ZwaqV4LsGFAJghWa(okuPBXTinKcJJF1qsW6MMNa1On)Sfa0lWGa)0gnEOgT5NTaGEXJbb(PnACqk8DuOs3IBrAifgd)QHKG1nnpbQrBMErz4GJe4N2OXd1OntVOmCWrc8JGkJNrGTrJdyaFhfQ0T4wKgsHXWVAijyDtZtGA0MF2ca6fsjWpTrJhQrB(zlaOx8sjWpTrJdsHVJcv6wClsdPWy4xnKeSUP5jqnAZpBba9cmiWpTrJhQrB(zlaOx8yqGFAJghWa(okuPvPXSA5vkM7ly(vs4xn0atojn2gz48AKHJgTrEihSH3(2OXq4vFhcudeSH0W6pSXEcud3Pv4iKqLUf3I0W34xnKeSUP5jqnAZpBba9cPe4N2OXd1On)Sfa0lEPe4N2OXbFJVJcv6wClsd8h)QHKG1nnpbQrB(zlaOxGbb(PnA8qnAZpBba9Ihdc8tB04GVX3rHkTknMvlVsXCFbZVsc)QHgyYjPX2idNxJmC0OngKAJgdHx9DiqnqWgsdR)Wg7jqnCNwHJqcv6wClsdPWVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB0WEnW7R8wuJdsHVJcv6wClsdFJF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPbgh)QHKG1nnpbQbNTrsAG8xVHpnWmygnEOgTy30Obc2zDKgqzAShoACaZCuJdsHVJcv6wClsdmo(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghWa(okuPBXTinWy4xnKeSUP5jqn4SnssdK)6n8PbMbZOXd1Of7MgnqWoRJ0aktJ9WrJdyMJACqk8DuOs3IBrAGXWVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0OTWVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I04QXVAijyDtZtGAWzBKKgi)1B4tdmJgpuJwSBAaU3lAHLgqzAShoAC46JACad47OqLUf3I0qkmGF1qsW6MMNa1GZ2ijnq(R3WNgygnEOgTy30aCVx0clnGY0ypC04W1h14Gu47OqLUf3I0adTJF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPbgWa(vdjbRBAEcudoBJK0a5VEdFAGz04HA0IDtdW9ErlS0aktJ9WrJdxFuJdsHVJcv6wClsdmG)4xnKeSUP5jqn4SnssdK)6n8PbMrJhQrl2nna37fTWsdOmn2dhnoC9rnoGb8DuOs3IBrAGb8h)QHKG1nnpbQrBMErz4GJe4N2OXd1OntVOmCWrc8JGkJNrGTrJdsHVJcv6wClsdmGXXVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0adym8Rgscw308eOgTz6fLHdosGFAJgpuJ2m9IYWbhjWpcQmEgb2gnoif(okuPBXTinWWvJF1qsW6MMNa1GZ2ijnq(R3WNgygnEOgTy30aCVx0clnGY0ypC04W1h14agW3rHkDlUfPHVBh)QHKG1nnpbQbNTrsAG8xVHpnWmA8qnAXUPb4EVOfwAaLPXE4OXHRpQXbPW3rHkTknMvlVsXCFbZVsc)QHgyYjPX2idNxJmC0OnzJX(ZP3gngcV67qGAGGnKgw)Hn2tGA4oTchHeQ0T4wKgya)QHKG1nnpbQbNTrsAG8xVHpnWmA8qnAXUPb4EVOfwAaLPXE4OXHRpQXbPW3rHkTknMvlVsXCFbZVsc)QHgyYjPX2idNxJmC0OnOVnAmeE13Ha1abBinS(dBSNa1WDAfocjuPBXTinKc)QHKG1nnpbQrBMErz4GJe4N2OXd1OntVOmCWrc8JGkJNrGTrJdsHVJcv6wClsdFJF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPHusHF1qsW6MMNa1GZ2ijnq(R3WNgygmJgpuJwSBA0ab7SosdOmn2dhnoGzoQXbPW3rHkDlUfPHusHF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkDlUfPHuya)QHKG1nnpbQbNTrsAG8xVHpnWmygnEOgTy30Obc2zDKgqzAShoACaZCuJdsHVJcv6wClsdPWa(vdjbRBAEcuJ2m9IYWbhjWpTrJhQrBMErz4GJe4hbvgpJaBJghKcFhfQ0T4wKgsHXWVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0adya)QHKG1nnpbQbNTrsAG8xVHpnWmA8qnAXUPb4EVOfwAaLPXE4OXHRpQXbmGVJcv6wClsdmGb8Rgscw308eOgTz6fLHdosGFAJgpuJ2m9IYWbhjWpcQmEgb2gnoif(okuPBXTinWGVXVAijyDtZtGA0MPxugo4ib(PnA8qnAZ0lkdhCKa)iOY4zeyB04Gu47OqLUf3I0ad4p(vdjbRBAEcudoBJK0a5VEdFAGz04HA0IDtdW9ErlS0aktJ9WrJdxFuJd(gFhfQ0T4wKgyap4xnKeSUP5jqnAZ0lkdhCKa)0gnEOgTz6fLHdosGFeuz8mcSnACad47OqLUf3I0adym8Rgscw308eOgTz6fLHdosGFAJgpuJ2m9IYWbhjWpcQmEgb2gnoif(okuPBXTinWqBHF1qsW6MMNa1OntVOmCWrc8tB04HA0MPxugo4ib(rqLXZiW2OXbPW3rHkTknMvlVsXCFbZVsc)QHgyYjPX2idNxJmC0On8q7BJgdHx9DiqnqWgsdR)Wg7jqnCNwHJqcv6wClsdPWy4xnKeSUP5jqn4SnssdK)6n8PbMrJhQrl2nna37fTWsdOmn2dhnoC9rno4B8DuOs3IBrAivBHF1qsW6MMNa1GZ2ijnq(R3WNgygnEOgTy30aCVx0clnGY0ypC04W1h14Gu47OqLwL2xAKHZtGAGX0WC)clnyl6rcvAGCqYKdiMlv7yaih5bMxgbKtB32AGPgZkhPrly6lOkDB32ACL7EipnAGbm(fAGH2XGuQ0Q0TDBRHKoTchHWVQ0TDBRXvPrlbbjqn4az2ObMswJqLUTBBnUknK0Pv4iqnEBWrFAZA4meH04HA487yu6Tbh9iHkDB32ACvACLsnWBcuJEvKJqiB8RXTnRXZiKghwbjUqd5HUtO3guFWrACv(OH8q3c0BdQp4OJcv62UT14Q0OL3Wfud5HCg63cNgywJ9NASzn2Vnin(tsdUdSWPbE7yRmIeQ0TDBRXvPXvMbaPHKG1neasJ)K0GJ8o7J0W0GT)ZinAGdPrMr4B5zKgh2Sg(HDnonWQnVgN7RX(AG2Mo7TIGDeZVgC3)udm9kVLyIgTQHKigH(1yA0s2IRAO6VqJ9BdOgiaw5Jcv62UT14Q04kZaG0ObIEnAtEXD(PHASTqTrdKJkBwisdtwM5xJhQbpeH0iV4oFKgWI5xOs32TTgxLgyYq2RbMaBinGznWuMDQbMYStnWuMDQHH0W0ajtU1yA8ZwaqVqLUTBBnUknUYLPIgnoScsCHgywJ9NxObM1y)5fAW5TjVdDuJgdK0OboKgdHw2s1RXd1GSHT0OHd2WB)vHEBEHkTkDB32A0YQGV9eOgyQXSYrA0YROf1WzLg8KgzyVa1WEno)xgHFV(AEJzLJUk024e42)SZlw41yQXSYrxfNTrsx3ako)ggMTZlJaK3yw5iXJVxLwL2C)clKqEihSH3EabylWHati5D2hPs32AGjNKg32SgpJ0yrAGOxJhQr7AWD)tnkOgO3EnGLgDePXpBba9Ol0qkn4EsLg)jPrEh0RbSinwKgWsJoIUqdmOXM14pjnqKdwGASinScudFRXM1Gh(NAydPsBUFHfsipKd2WBFRaE9TnRXZOlkRHaewPoIs)Sfa0FXTX6eGTRsBUFHfsipKd2WBFRaE9TnRXZOlkRHaewPoIs)Sfa0Fbugqde8IBJ1jaL6Ind4pBba9cPeNgk1ruIVNZy)zlaOxiLWbHmqi3sa2h7xyHvIF2ca6fsjwK4HnucMtnWc9dSJsoyH(P7(fwivAZ9lSqc5HCWgE7BfWRVTznEgDrzneGWk1ru6NTaG(lGYaAGGxCBSobigUyZa(ZwaqVadItdL6ikX3ZzS)Sfa0lWGWbHmqi3sa2h7xyHvIF2ca6fyqSiXdBOemNAGf6hyhLCWc9t39lSqQ0TTgyYjHin(zlaOhPHnKgf81W6pSX(1zmMFnaPNCpbQHH0awA0rKgO3En(zlaOhj0qdo0RXTnRXZinEOg4VggsJ)K8RHXqqnkIa1ajtU1yACAfiBlCcvAZ9lSqc5HCWgE7BfWRVTznEgDrzneGWk1ru6NTaG(lGYaAGGxCBSobi(FXMbKWR(kltGITqUP)gpJs4v3QV3KaP71rEEeE1xzzcuqnY(hYyj4aww5ippcV6RSmbkqWoJr)VfU0059RsBUFHfsipKd2WBFRaEDdewaSvkdNgvAZ9lSqc5HCWgE7BfWR5o2FEbBlk5abuQ2VyZaEGCSvgrcwVSjve(EppYXwzej2kHGmB88ihBLrKyRep8p98ihBLrKWk)PIW3FuLwLUT14kgYzOxdmObM1y)PgwbQHPbN3guFWrAaln4GjAWD)tnW8f35Rrl0inScudmf2smrd4ObN3M8oKgW)KgUlIuPn3VWcjGYurtRaEn3X(Zl2mGhihBLrKG1lBsfHV3ZJCSvgrITsiiZgppYXwzej2kXd)tppYXwzejSYFQi89hXkp0Tqkb3X(tSsip0TadcUJ9NQ0M7xyHeqzQOPvaVg92K3HUGTfLCGaINl2mGsm9IYWbhj4nMvokbZjJXs)5w4qEEs4G3uz1lQf35NYg55jbsMyS0Bdo6rc0Bt2ymaLYZtI3yu9IY((qOeVXSYrcQmEgb65DGCSvgrceKztQi89EEKJTYisSvI1lB88ihBLrKyRep8p98ihBLrKWk)PIW3FuL2C)clKaktfnTc41O3guFWrxW2IsoqaXZfBgWPxugo4ibVXSYrjyozmw6p3chcRdEtLvVOwCNFkBewKmXyP3gC0JeO3MSXyakLkTkDB32AG34JC9Na1GUPXVg)2qA8NKgM7HJglsd72wMXZiHkT5(fwiarqMnjEYAuPn3VWc1kGx7mglzUFHvITO)IYAiaHYurZfBgWFBOlpGbmYC)clb3X(tHZqF63gQvZ9lSeO3M8oKWzOp9BdDuLUT1Gd9inAjeV1awA47w1G7(NW(Rb4S5xdRa1G7(NAW5THbhqnScudm0QgW)KgUlIuPn3VWc1kGxFBZA8m6IYAiaxuYG0f3gRtaIKjgl92GJEKa92KngZhPWEqI3yu9c0BddoGcQmEgb659gJQxGEIXSjboB(fuz8mc8ONhsMyS0Bdo6rc0Bt2ymFWGkDBRbh6rA4yKDtAW9Kkn482K3H0WzLgN7RbgAvJ3gC0J0G756o1yrAmeJUT61idhn(tsd82XwzePXd1GN0qEOmndbQHvGAW9CDNAKxgJgnEOgod9Q0M7xyHAfWRVTznEgDrzneGlk5yKDtxCBSobisMyS0Bdo6rc0BtEhYhPuPBBnWSBZA8msJ)0EnCNKdaKgBwd)WUg2qASLgMg4CGA8qnSB4cQXFsAG2VB)cln4EsdPHPXpBba9AqVtJfPrhrGASLg80ZLOsdNHEKkT5(fwOwb86BBwJNrxuwdb4wjCoWlUnwNauEO7eohOqkrdew5Dipp5HUt4CGcPeOEL3H88Kh6oHZbkKsGEBq9bh55jp0DcNduiLa92KngZZtEO7eohOqkrUp(tWCIy9I88Kh6wm2nvWokLhQKSFpp(EolCwAlNyOgBleG89Cw4S0wobyFSFHLN3TnRXZiXIsgKuPBBn8vePbMsdIga2cNgC3)udj1YR9LYPbC0WYpnAijyDdbG0ylnKulV2xkNkT5(fwOwb8AEAq0aWw4UyZaE4Geo4nvw9IAXD(PSrEEs4GqgiKBjCW6gcaL(tkHK3zFKOlFelFpNfolTLtmuJTfYhPWdw(Eolg7MkyhLYdvs2VyOgBl0L4pwjCWBQS6f3u9N(hpph8MkREXnv)P)blFpNfolTLt0LXY3ZzXy3ub7OuEOsY(fDzSh475SySBQGDukpujz)IHASTqxkLuxfEWOPxugo4ibARCNLo9JEAwZZJVNZcNL2YjgQX2cDPus55jfMbjtmw60qpDPuc8GNJhXEBZA8msSvcNduLUT14kGVgC3)udtdj1YR9LYPXFAVglQAZRHPXv0ziB0qEGonGJgCpPsJ)K0iV4oFnwKggpS)A8qnOcuL2C)cluRaETm8xyDXMb8aFpNfolTLtmuJTfYhPWd2dsm9IYWbhjqBL7S0PF0tZAEE89Cwm2nvWokLhQKSFXqn2wOlLcJDvyaJ475SGNbHGSo6fDzS89Cwm2nvWokLhQKSFrx(ONhpeHWMxCNFAOgBl0LyaphXEBZA8msSvcNduLUT1qsgZ1z2tin4Es)jnA0rBHtdjbRBiaKgfKRgCxgtdJXGC1WpSRXd1a9lJPHZqVg)jPbYAinSgyVEnGznKeSUHaqTkPwETVuonCg6rQ0M7xyHAfWRVTznEgDrzneGoyDdbGsGeYF5U42yDcqhTSdhYlUZpnuJTf6QKcpxLdczGqULWzPTCIHASTqhXms1wTFeqhTSdhYlUZpnuJTf6QKcpxLdczGqULWbRBiau6pPesEN9rcW(y)cRRYbHmqi3s4G1neak9NucjVZ(iXqn2wOJygPAR2pIvIXwWeDt1lmqqKGW3IEKNNdczGqULWzPTCIHASTq(S1tJmKzpbMYlUZpnuJTfYZB6fLHdos4igH(1yjK8o7JW6GqgiKBjCwAlNyOgBlKp(UDppheYaHClHdw3qaO0FsjK8o7Jed1yBH8zRNgziZEcmLxCNFAOgBl0vjv7EEs4G3uz1lQf35NYgPs32A4RicuJhQbiXm)A8NKgDKHJ0aM1qsT8AFPCAW9Kkn6OTWPbiSZZinGLgDePHvGAip0nvVgDKHJ0G7jvAyLggiOg0nvVglsdJh2FnEOgGlPsBUFHfQvaV(2M14z0fL1qa6atoybU)cRlUnwNa8qEXD(PHASTq(ifE88gBbt0nvVWabrIT8bpTFe7Hdhi8QVYYeOGAK9pKXsWbSSYryp4GqgiKBjOgz)dzSeCalRCKyOgBl0LsHXB3ZZbVPYQxCt1F6FW6GqgiKBjOgz)dzSeCalRCKyOgBl0LsHXXyTEqkPWOPxugo4ibARCNLo9JEAw74rSs4GqgiKBjOgz)dzSeCalRCKyid0)rppcV6RSmbkqWoJr)VfU0059J9Geo4nvw9IAXD(PSrEEoiKbc5wceSZy0)BHlnDE)jFJ)4PTAxkXqn2wOlLsk8)ON3bheYaHClbpniAaylCIHmq)EEsmMJe)azSJypCGWR(kltGITqUP)gpJs4v3QV3KaP71ryp4GqgiKBj2c5M(B8mkHxDR(EtcKUxhjgYa975zUFHLylKB6VXZOeE1T67njq6EDKaCrgpJapE0Z7aHx9vwMafOtdeYLatWHpbZPhonu9yDqideYTepCAO6jW0wOf35N8nEWJVXGuIHASTqh98oC42M14zKawPoIs)Sfa0dOuEE32SgpJeWk1ru6NTaGEa99rSh(zlaOxiLyid0FYbHmqi3YZ7NTaGEHucheYaHClXqn2wiF26PrgYSNat5f35NgQX2cDvs1(rpVBBwJNrcyL6ik9ZwaqpGya7HF2ca6fyqmKb6p5GqgiKB559ZwaqVadcheYaHClXqn2wiF26PrgYSNat5f35NgQX2cDvs1(rpVBBwJNrcyL6ik9ZwaqpGTF84rpph8MkREba(N1QJEE8qecBEXD(PHASTqxY3ZzHZsB5eG9X(fwQ0TTgy2TznEgPrhrGA8qnajM5xdR8RXpBba9inScudhisdUNuPbxB)TWPrgoAyLg4Dx(eoRPH8aDQ0M7xyHAfWRVTznEgDrzneG)5Smwcrea0K4A7FXTX6eGsGGDg)wGI)CwglHicaAeuz8mc0ZlV4o)0qn2wiFWq7T75XdriS5f35NgQX2cDjgWtRhW)2Vk(Eol(ZzzSeIiaOrGEZbagHHJEE89Cw8NZYyjeraqJa9MdaF8DBDvhMErz4GJeOTYDw60p6PznmcphvPBBn8vePbE3i7FiJPXv(aww5inWq7iYH0GNYWH0W0qsT8AFPCA0rKqL2C)cluRaEDhrP9PMlkRHaKAK9pKXsWbSSYrxSzaDqideYTeolTLtmuJTf6sm0owheYaHClHdw3qaO0FsjK8o7Jed1yBHUedTJ9WTnRXZiXFolJLqebanjU2(EE89Cw8NZYyjeraqJa9MdaF8D7TEy6fLHdosG2k3zPt)ONM1Wim(XJyVTznEgj2kHZb65XdriS5f35NgQX2cDPVXyQ0TTg(kI0GdSZy0VfonUs78(1aJJihsdEkdhsdtdj1YR9LYPrhrcvAZ9lSqTc41DeL2NAUOSgcqeSZy0)BHlnDE)xSzap4GqgiKBjCwAlNyOgBl0LyCSs4G3uz1lUP6p9pyLWbVPYQxulUZpLnYZZbVPYQxulUZpLncRdczGqULWbRBiau6pPesEN9rIHASTqxIXXE42M14zKWbRBiaucKq(lNNNdczGqULWzPTCIHASTqxIXp655G3uz1lUP6p9pypiX0lkdhCKaTvUZsN(rpnRH1bHmqi3s4S0woXqn2wOlX4EE89Cwm2nvWokLhQKSFXqn2wOlLc)B9aEWicV6RSmbk2c9t39WbLa37TOepXyhXY3ZzXy3ub7OuEOsY(fD5JEE8qecBEXD(PHASTqxIb845r4vFLLjqb1i7FiJLGdyzLJW6GqgiKBjOgz)dzSeCalRCKyOgBlKpyO9JyVTznEgj2kHZbIvccV6RSmbk2c5M(B8mkHxDR(EtcKUxh555GqgiKBj2c5M(B8mkHxDR(EtcKUxhjgQX2c5dgA3ZJhIqyZlUZpnuJTf6sm0UkDBRrlzCn)in6isdFbZwTan4U)PgsQLx7lLtL2C)cluRaE9TnRXZOlkRHaCXlWKdwG7VW6IBJ1ja575SWzPTCIHASTq(ifEWEqIPxugo4ibARCNLo9JEAwZZJVNZIXUPc2rP8qLK9lgQX2cDjGsHbbgA9GVXi(Eol4zqiiRJErx(yRhARRcpyeFpNf8mieK1rVOlFeJi8QVYYeOyl0pD3dhucCV3Is8eJHLVNZIXUPc2rP8qLK9l6Yh984Hie28I78td1yBHUed4XZJWR(kltGcQr2)qglbhWYkhH1bHmqi3sqnY(hYyj4aww5iXqn2wivAZ9lSqTc41DeL2NAUOSgcWTqUP)gpJs4v3QV3KaP71rxSzaVTznEgjw8cm5Gf4(lSWEBZA8msSvcNduLUT1WxrKgZI781GNYWH0WbIuPn3VWc1kGx3ruAFQ5IYAiarNgiKlbMGdFcMtpCAO6VyZaEWbHmqi3s4S0woXqgOFSs4G3uz1lQf35NYgH92M14zK4pNLXsiIaGMexBFShCqideYTe80GObGTWjgYa975jXyos8dKXo655G3uz1lQf35NYgH1bHmqi3s4G1neak9NucjVZ(iXqgOFShUTznEgjCW6gcaLajK)Y555GqgiKBjCwAlNyid0)XJybHVa1R8oK4xhaBHd7bq4lqpXy2KYmBiXVoa2cNNNeVXO6fONymBszMnKGkJNrGEEizIXsVn4OhjqVn5DiF89rSGWx0aHvEhs8RdGTWH9WTnRXZiXIsgK88MErz4GJe8gZkhLG5KXyP)ClCippd9JXsYqU04dGxD7EE32SgpJeoyDdbGsGeYF588475SGNbHGSo6fD5JyLGWR(kltGITqUP)gpJs4v3QV3KaP71rEEeE1xzzcuSfYn934zucV6w99MeiDVocRdczGqULylKB6VXZOeE1T67njq6EDKyOgBlKp(UDSsW3ZzHZsB5eDzppEicHnV4o)0qn2wOlX)2vPBBnWKZfPXI0W0yS)KgniMXdh7jn4A(14HA0yaqAymMgWsJoI0a92RXpBba9inEOg8KgSTiqn6YAWD)tnKulV2xkNgwbQHKG1neasdRa1OJin(tsdmuGAGyWxdyPHduJnRbp8p14NTaGEKg2qAaln6isd0BVg)Sfa0JuPn3VWc1kGx3ruAFQbDbIbFeG)Sfa0l1fBgWd32SgpJeWk1ru6NTaGEjaukSs8ZwaqVadIHmq)jheYaHClpVd32SgpJeWk1ru6NTaGEaLYZ72M14zKawPoIs)Sfa0dOVpI9aFpNfolTLt0LXEqch8MkREXnv)P)XZJVNZIXUPc2rP8qLK9lgQX2c16b8GrtVOmCWrc0w5olD6h90S2Xlb8NTaGEHuc(EoNa7J9lSWY3ZzXy3ub7OuEOsY(fDzpp(Eolg7MkyhLYdvs2FcTvUZsN(rpnRj6Yh98CqideYTeolTLtmuJTfQvm4ZpBba9cPeoiKbc5wcW(y)clSsW3ZzHZsB5eDzShKWbVPYQxulUZpLnYZtIBBwJNrchSUHaqjqc5VChXkHdEtLvVaa)ZALNNdEtLvVOwCNFkBe2BBwJNrchSUHaqjqc5VCyDqideYTeoyDdbGs)jLqY7Sps0LXkHdczGqULWzPTCIUm2dh475SGCSvgrjwVSrmuJTfYhPA3ZJVNZcYXwzeLqqMnIHASTq(iv7hXkX0lkdhCKG3yw5OemNmgl9NBHd55DGVNZcEJzLJsWCYyS0FUfouQSVpKa9MdaaXJNhFpNf8gZkhLG5KXyP)ClCOKnoRib6nhaa2whp65X3ZzbaBboeyIAKHCPPHQprfn4wjtIU8rppEicHnV4o)0qn2wOlXq7EE32SgpJeWk1ru6NTaGEaB)i2BBwJNrITs4CGQ0M7xyHAfWR7ikTp1GUaXGpcWF2ca6XWfBgWd32SgpJeWk1ru6NTaGEjaedyL4NTaGEHuIHmq)jheYaHClpVBBwJNrcyL6ik9ZwaqpGya7b(EolCwAlNOlJ9Geo4nvw9IBQ(t)JNhFpNfJDtfSJs5Hkj7xmuJTfQ1d4bJMErz4GJeOTYDw60p6PzTJxc4pBba9cmi475CcSp2VWclFpNfJDtfSJs5Hkj7x0L98475SySBQGDukpujz)j0w5olD6h90SMOlF0ZZbHmqi3s4S0woXqn2wOwXGp)Sfa0lWGWbHmqi3sa2h7xyHvc(EolCwAlNOlJ9Geo4nvw9IAXD(PSrEEsCBZA8ms4G1neakbsi)L7iwjCWBQS6fa4FwRWEqc(EolCwAlNOl75jHdEtLvV4MQ)0)C0ZZbVPYQxulUZpLnc7TnRXZiHdw3qaOeiH8xoSoiKbc5wchSUHaqP)Ksi5D2hj6YyLWbHmqi3s4S0worxg7Hd89Cwqo2kJOeRx2igQX2c5JuT75X3Zzb5yRmIsiiZgXqn2wiFKQ9JyLy6fLHdosWBmRCucMtgJL(ZTWH88oW3ZzbVXSYrjyozmw6p3chkv23hsGEZbaG4XZJVNZcEJzLJsWCYyS0FUfouYgNvKa9MdaaBRJhp65X3ZzbaBboeyIAKHCPPHQprfn4wjtIUSNhpeHWMxCNFAOgBl0LyODpVBBwJNrcyL6ik9ZwaqpGTFe7TnRXZiXwjCoqv62wdFfrinmgtd4FsJgWsJoI0yFQbPbS0WbQsBUFHfQvaVUJO0(udsLUT1OfqUfK0WC)clnyl61G3qeOgWsd0(D7xyDnJWTivAZ9lSqTc41tVsM7xyLyl6VOSgcqdsxG(zDpGsDXMb82M14zKyrjdsQ0M7xyHAfWRNELm3VWkXw0FrzneG8q7Va9Z6EaL6Ind40lkdhCKG3yw5OemNmgl9NBHdji8QVYYeOkT5(fwOwb86PxjZ9lSsSf9xuwdbi6vPvPBBnKKXCDM9esdUN0FsJg)jPrlyiRXzV7Kgn475SgCxgtJSXyAaZzn4U)5wA8NKgfHVxdNHEvAZ9lSqcdsaEBZA8m6IYAiabhYAsCxglLnglbZ5lUnwNa8aFpNf)2qCHtLahYA43cKgXqn2wOlX5afng(ATDHuEE89Cw8BdXfovcCiRHFlqAed1yBHU0C)clb6TjVdji8rU(tPFBOwBxif2dKJTYisSvI1lB88ihBLrKabz2KkcFVNh5yRmIew5pve((JhXY3ZzXVnex4ujWHSg(TaPr0LXo9IYWbhj(TH4cNkboK1WVfinQ0TTgsYyUoZEcPb3t6pPrdoVnO(GJ0yrAWfo)Pgod9BHtd4nnAW5TjVdPXwA0I9YgnWBhBLrKkT5(fwiHbPwb86BBwJNrxuwdb4IRGdLqVnO(GJU42yDcqjihBLrKyRecYSb7bKmXyP3gC0JeO3M8oKp4b7BmQEbc2zjyo9Nukdhc9cQmEgb65HKjgl92GJEKa92K3H8bJDuLUT1WxrKgscw3qain4EsLg2RbJqin(tR0apTRrlrxHgwbQbBlsJUSgC3)udj1YR9LYPsBUFHfsyqQvaV2bRBiau6pPesEN9rxSzaLaC6lOOGjhic7Hd32SgpJeoyDdbGsGeYF5WkHdczGqULWzPTCIHmq)EE89Cw4S0worx(i2d89Cwqo2kJOeRx2igQX2c5dg3ZJVNZcYXwzeLqqMnIHASTq(GXpI9GetVOmCWrcEJzLJsWCYyS0FUfoKNhFpNf8gZkhLG5KXyP)ClCOuzFFib6nha(4Bpp(Eol4nMvokbZjJXs)5w4qjBCwrc0Boa8X3h984Hie28I78td1yBHUuQ2XkHdczGqULWzPTCIHmq)hvPBBn8vePbNEL3H0ylnKTcKAwNgWsdR8)NBHtJ)0Eny7nH0qk8hroKgwbQbJqin4U)PgnWH04Tbh9inScud714pjnOcudywdtdoqMnAG3o2kJinSxdPWFnqKdPbC0GriKgd1yBTfonmKgpuJc(ACA3BHtJhQXq5HqNAa2NTWPrl2lB0aVDSvgrQ0M7xyHegKAfWRr9kVdDHZVJrP3gC0JauQl2mGhgkpe604zKNhFpNfKJTYikHGmBed1yBHU03yjhBLrKyRecYSb7qn2wOlLc)X(gJQxGGDwcMt)jLYWHqVGkJNrGhX(2GJEXVnu6HjWL8rk8)QqYeJLEBWrpQ1HASTqypqo2kJiXwjR875nuJTf6sCoqrJHVJQ0TTg(kI0GtVY7qA8qnoTBsdtdCmiVX04HA0rKg(cMTAbQ0M7xyHegKAfWRr9kVdDXMb82M14zKyXlWKdwG7VWcRdczGqULylKB6VXZOeE1T67njq6EDKyid0pwcV6RSmbk2c5M(B8mkHxDR(EtcKUxhPsBUFHfsyqQvaVg92Kng7IndOeVXO6fONymBsGZMFbvgpJaXEGVNZc0Bt2ymXq5HqNgpJWEajtmw6Tbh9ib6TjBm2L(2ZtIPxugo4iXVnex4ujWHSg(TaP5ON3BmQEbc2zjyo9Nukdhc9cQmEgbILVNZcYXwzeLqqMnIHASTqx6BSKJTYisSvcbz2GLVNZc0Bt2ymXqn2wOlXyyrYeJLEBWrpsGEBYgJ5dG4)rShKy6fLHdosW87SXqPmJOFlCjCSTrgrEE)2qygmd(JhF475Sa92KngtmuJTfQvmCe7Bdo6f)2qPhMaxYh8Os32AGzT)PgCEIXSrJwWS5xJoI0awA4a1G7jvAmuEi0PXZin47VgOFzmn4A7RrgoA0I(D2yinKhOtdRa1aewT51OJin4PmCinKulaj0GZVmMgDePbpLHdPHKG1neasd0wosJ)0En4UmMgYd0PHvW)Kgn482KngtL2C)clKWGuRaEn6TjBm2fBgW3yu9c0tmMnjWzZVGkJNrGy575Sa92KngtmuEi0PXZiShKy6fLHdosW87SXqPmJOFlCjCSTrgrEE)2qygmd(JhFW)JyFBWrV43gk9We4s(4Bv62wdmR9p1OfmK1WVfinA0rKgCEBYgJPXd1aaIK1OlRXFsAW3Zzn49RHXqqn6OTWPbN3MSXyAalnWJgiYblqKgWrdgHqAmuJT1w4uPn3VWcjmi1kGxJEBYgJDXMbC6fLHdos8BdXfovcCiRHFlqAWIKjgl92GJEKa92KngZha9n2dsW3ZzXVnex4ujWHSg(TaPr0LXY3Zzb6TjBmMyO8qOtJNrEEhUTznEgjahYAsCxglLnglbZzSh475Sa92KngtmuJTf6sF75HKjgl92GJEKa92KngZhmG9ngvVa9eJztcC28lOY4zeiw(EolqVnzJXed1yBHUephpEuLUT1qsgZ1z2tin4Es)jnAyAW5Tb1hCKgDePb3LX0WzDePbN3MSXyA8qnYgJPbmNVqdRa1OJin482G6dosJhQbaejRrlyiRHFlqA0a9Mdan6YQ0M7xyHegKAfWRVTznEgDrzneGO3MSXyjUW6tzJXsWC(IBJ1jan0pgljd5sJpTv7x1bPAhJ475S43gIlCQe4qwd)wG0iqV5a44vDGVNZc0Bt2ymXqn2wimY3ygKmXyPtd9egjXBmQEb6jgZMe4S5xqLXZiWJx1bheYaHClb6TjBmMyOgBleg5BmdsMyS0PHEcJEJr1lqpXy2KaNn)cQmEgbE8QoacFrUp(tWCIy9Ied1yBHWi8Ce7b(EolqVnzJXeDzppheYaHClb6TjBmMyOgBl0rv62wdFfrAW5Tb1hCKgC3)uJwWqwd)wG0OXd1aaIK1OlRXFsAW3Zzn4U)jS)AWGOTWPbN3MSXyA0L)TH0Wkqn6isdoVnO(GJ0awAG)TQbMcBjMOb6nhain61VmnWFnEBWrpsL2C)clKWGuRaEn6Tb1hC0fBgWBBwJNrcWHSMe3LXszJXsWCg7TnRXZib6TjBmwIlS(u2ySemNXkXTnRXZiXIRGdLqVnO(GJ88oW3ZzbVXSYrjyozmw6p3chkv23hsGEZbGp(2ZJVNZcEJzLJsWCYyS0FUfouYgNvKa9MdaF89rSizIXsVn4OhjqVnzJXUe)XEBZA8msGEBYgJL4cRpLnglbZzv62wdFfrAG4AtJgiOg)P9A4h21ah9A0y4tJU8VnKg8(1OJ2cNg7RHH0GzpPHH0qgIqlpJ0awAWiesJ)0kn8TgO3CaG0aoAGzth9AW9Kkn8DRAGEZbasdcFY7qQ0M7xyHegKAfWRnqt(3BkH4AtZfo)ogLEBWrpcqPUyZakXVoa2chwjm3VWsyGM8V3ucX1MMeO1y4iXwPmBXD(EEGWxyGM8V3ucX1MMeO1y4ib6nhax6BSGWxyGM8V3ucX1MMeO1y4iXqn2wOl9TkDBRXvkLhcDQXvgew5Din2SgsQLx7lLtJfPXqgO)l04pPH0WgsdgHqA8NwPbE04Tbh9in2sJwSx2ObE7yRmI0G7(NAWb(TWl0GriKg)PvAiv7Aa)tA4UisJT0Wk)AG3o2kJinGJgDznEOg4rJ3gC0J0GNYWH0W0Of7LnAG3o2kJiHgTay1MxJHYdHo1aSpBHtJReBboeOg4DJmKlnnu9A0lgHqASLgCGmB0aVDSvgrQ0M7xyHegKAfWRBGWkVdDHZVJrP3gC0JauQl2mGdLhcDA8mc7Bdo6f)2qPhMaxYNdhKc)B9asMyS0Bdo6rc0BtEhcJWagX3Zzb5yRmIsSEzJOlF8yRd1yBHoIzoivRVXO6fp3TsnqyHeuz8mc8i2doiKbc5wcNL2YjgYa9JvcWPVGIcMCGiShUTznEgjCW6gcaLajK)Y555GqgiKBjCW6gcaL(tkHK3zFKyid0VNNeo4nvw9IAXD(PSrh98qYeJLEBWrpsGEBY7qxE4ag)QoW3Zzb5yRmIsSEzJOlJry44rm6GuT(gJQx8C3k1aHfsqLXZiWJhXkb5yRmIeiiZMur4798oqo2kJiXwjeKzJN3bYXwzej2kXd)tppYXwzej2kX6LnhXkXBmQEbc2zjyo9Nukdhc9cQmEgb65X3ZzH8SnWbCnwYgNvRlj3ziBe3gRt(aigWt7hXEajtmw6Tbh9ib6TjVdDPuTJrhKQ13yu9IN7wPgiSqcQmEgbE8iwd9JXsYqU04dEA)Q475Sa92KngtmuJTfcJW4hXEqc(EolaylWHatuJmKlnnu9jQOb3kzs0L98ihBLrKyRecYSXZtch8MkREba(N1QJyLGVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIUSkDBRHVIinAHqmxdyPHdudU7Fc7VgotwElCQ0M7xyHegKAfWRZWXrjyov23h6IndOjNCNKdavAZ9lSqcdsTc4132SgpJUOSgcqhyYblW9xyLmiDXTX6eGsao9fuuWKdeH92M14zKWbMCWcC)fwypCGVNZc0Bt2ymrx2Z7ngvVa9eJztcC28lOY4zeONNdEtLvVOwCNFkB0rShKGVNZceKH(1rIUmwj475SWzPTCIUm2ds8gJQxK7J)emNiwVibvgpJa98475SWzPTCcW(y)clFCqideYTe5(4pbZjI1lsmuJTfQ126i2BBwJNrI)CwglHicaAsCT9XEqch8MkRErT4o)u2ippheYaHClHdw3qaO0FsjK8o7JeDzSh475Sa92KngtmuJTf6sm45jXBmQEb6jgZMe4S5xqLXZiWJhX(2GJEXVnu6HjWL8HVNZcNL2Yja7J9lSWO2fySJEE8qecBEXD(PHASTqxY3ZzHZsB5eG9X(fwhvPBBn8vePrlCOsY(1G7(NAiPwETVuovAZ9lSqcdsTc41JDtfSJs5Hkj7)IndiFpNfolTLtmuJTfYhPWJNhFpNfolTLta2h7xyDPVBh7TnRXZiHdm5Gf4(lSsgKuPBBn8vePHKA51(s50awA4a1OxmcH0WkqnyBrASVgDzn4U)Pgscw3qaivAZ9lSqcdsTc41oIrOFnwYylUQHQ)Ind4TnRXZiHdm5Gf4(lSsgKWEGVNZcNL2Yja7J9lS8bqF3UNNeo4nvw9IBQ(t)Zrpp(Eolg7MkyhLYdvs2VOlJLVNZIXUPc2rP8qLK9lgQX2cD5v3QdwG99fYd5weLm2IRAO6f)2qPBJ1PwpibFpNf8mieK1rVOlJvI3yu9c0BddoGcQmEgbEuL2C)clKWGuRaE9woBk7xyDXMb82M14zKWbMCWcC)fwjdsQ0TTg(kI0aVBKHCPrdmfwGAalnCGAWD)tn482KngtJUSgwbQbYUjnYWrJROZq2OHvGAiPwETVuovAZ9lSqcdsTc41uJmKlnjEybEXMbKhIqy36PrgYSNat5f35NgQX2cDPu4XZ7aFpNfYZ2ahW1yjBCwTUKCNHSrCBSoDjgWt7EE89CwipBdCaxJLSXz16sYDgYgXTX6KpaIb80(rS89CwGEBYgJj6Yyp4GqgiKBjCwAlNyOgBlKp4F7EEGtFbffm5arhvPBBnUsP8qOtnYmBinGLgDznEOg(wJ3gC0J0G7(NW(RHKA51(s50GN2cNggpS)A8qni8jVdPHvGAuWxd4nnotwElCQ0M7xyHegKAfWRrpXy2KYmBOlC(Dmk92GJEeGsDXMbCO8qOtJNry)THspmbUKpsHhSizIXsVn4OhjqVn5DOlXFSMCYDsoaWEGVNZcNL2YjgQX2c5JuT75jbFpNfolTLt0LpQs32A4RisJwieV1yZASfAbjnSsd82XwzePHvGAW2I0yFn6YAWD)tnmnUIodzJgYd0PHvGA0sqt(3BsdoCTPrL2C)clKWGuRaEDUp(tWCIy9IUyZaso2kJiXwjR8JLVNZc5zBGd4ASKnoRwxsUZq2iUnwNUed4PDShaHVWan5FVPeIRnnjqRXWrIFDaSfoppjCWBQS6ff5gidoGEEizIXsVn4Oh5dgoI9aFpNfJDtfSJs5Hkj7xmuJTf6YR(QoGhmA6fLHdosG2k3zPt)ONM1oILVNZIXUPc2rP8qLK9l6YEEsW3ZzXy3ub7OuEOsY(fD5JypiHdczGqULWzPTCIUSNhFpNf)5Smwcrea0iqV5a4sPWd28I78td1yBHUedT3o28I78td1yBH8rQ2B3ZtceSZ43cu8NZYyjeraqJGkJNrGhXEab7m(Taf)5Smwcrea0iOY4zeONNdczGqULWzPTCIHASTq(472pQs32A4RisdtdoVnzJX04kVO)ud5b60OxmcH0GZBt2ymnwKggBid0VgDznGJg(HDnSH0W4H9xJhQb8MgNjRrlrxHkT5(fwiHbPwb8A0Bt2ySl2mG89Cwal6prjzACK8VWs0LXEGVNZc0Bt2ymXq5HqNgpJ88m0pgljd5sJpxD7hvPBBnAb9gznAj6k0GNYWH0qsW6gcaPb39p1GZBt2ymnScuJ)Kkn482G6dosL2C)clKWGuRaEn6TjBm2fBgqh8MkRErT4o)u2iSs8gJQxGEIXSjboB(fuz8mce7HBBwJNrchSUHaqjqc5VCEEoiKbc5wcNL2Yj6YEE89Cw4S0worx(iwheYaHClHdw3qaO0FsjK8o7Jed1yBHUeNdu0y4dJC0YoyOFmwsgYLgmdEA)iw(EolqVnzJXed1yBHUe)Xkb40xqrbtoqKkT5(fwiHbPwb8A0BdQp4Ol2mGo4nvw9IAXD(PSrypCBZA8ms4G1neakbsi)LZZZbHmqi3s4S0worx2ZJVNZcNL2Yj6YhX6GqgiKBjCW6gcaL(tkHK3zFKyOgBl0LyCS89CwGEBYgJj6YyjhBLrKyRKv(XkXTnRXZiXIRGdLqVnO(GJWkb40xqrbtoqKkDBRHVIin482G6dosdU7FQHvACLx0FQH8aDAahn2Sg(H92aQb8MgNjRrlrxHgC3)ud)W(Orr471WzOxOrlziOgG9gznAj6k0WEn(tsdQa1aM14pjnWSt1F6F0GVNZASzn482KngtdUWodSAZRr2ymnG5SgWrd)WUg2qAalnWGgVn4OhPsBUFHfsyqQvaVg92G6do6IndiFpNfWI(tuYXiBs3lAHLOl75Dqc0BtEhsyYj3j5aaRe32SgpJelUcouc92G6doYZ7aFpNfolTLtmuJTf6s8GLVNZcNL2Yj6YEEhoW3ZzHZsB5ed1yBHUeNdu0y4dJC0YoyOFmwsgYLgmJVB)iw(EolCwAlNOl75X3ZzXy3ub7OuEOsY(tOTYDw60p6PznXqn2wOlX5afng(WihTSdg6hJLKHCPbZ472pILVNZIXUPc2rP8qLK9NqBL7S0PF0tZAIU8rSo4nvw9IBQ(t)ZXJypGKjgl92GJEKa92Kng7sF75DBZA8msGEBYgJL4cRpLnglbZ5JhXkXTnRXZiXIRGdLqVnO(GJWEqIPxugo4iXVnex4ujWHSg(TaPXZdjtmw6Tbh9ib6TjBm2L((OkDBRHVIinUYGWcPXwAWbYSrd82XwzePHvGAGSBsJwyNX04kdclnYWrdj1YR9LYPsBUFHfsyqQvaVUiUPgiSUyZaEGVNZcYXwzeLqqMnIHASTq(q4JC9Ns)2qEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaOsBUFHfsyqQvaV(0y5udewxSzapW3Zzb5yRmIsiiZgXqn2wiFi8rU(tPFBipVdUtBWriaXa2HCN2GJs)2qxINJEEUtBWria99rSMCYDsoaWEGVNZIXUPc2rP8qLK9lgQX2cDjEWY3ZzXy3ub7OuEOsY(fDzSsm9IYWbhjqBL7S0PF0tZAEEsW3ZzXy3ub7OuEOsY(fD5JQ0M7xyHegKAfWRZDgl1aH1fBgWd89Cwqo2kJOecYSrmuJTfYhcFKR)u63gc7bheYaHClHZsB5ed1yBH8bpT755GqgiKBjCW6gcaL(tkHK3zFKyOgBlKp4P9JEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaG9aFpNfJDtfSJs5Hkj7xmuJTf6s8GLVNZIXUPc2rP8qLK9l6YyLy6fLHdosG2k3zPt)ONM188KGVNZIXUPc2rP8qLK9l6YhvPBBn8vePbMfeV1awAiPwGkT5(fwiHbPwb8AU2mlCsWCIy9IuPBBnKKXCDM9esdUN0FsJgpuJoI0GZBtEhsJT0GdKzJgCpx3Pglsd71apA82GJEuRsPrgoAq304xdm0oMrJgd904xd4Ob(RbN3guFWrAG3nYqU00q1Rb6nhaivAZ9lSqcdsTc4132SgpJUOSgcq0BtEhkTvcbz2CXTX6eGizIXsVn4OhjqVn5DiFW)wZmiCo0yONg)PBJ1jmsQ2BhZGH2p2AMbHZb(EolqVnO(GJsuJmKlnnu9jeKzJa9Mdamd(FuLUT1qsgZ1z2tin4Es)jnA8qnWSg7p1aSpBHtJw4qLK9RsBUFHfsyqQvaV(2M14z0fL1qaYDS)mTvkpujz)xCBSobOuygKmXyPtd90Ly4Qo0Uady0bKmXyP3gC0JeO3M8o0vj1rm6GuT(gJQxGGDwcMt)jLYWHqVGkJNrGyKuc8C8yRTlKcpyeFpNfJDtfSJs5Hkj7xmuJTfsLUT1WxrKgywJ9NASLgCGmB0aVDSvgrAahn2SgfudoVn5Din4UmMg591yRhQHKA51(s50Wk)nWHuPn3VWcjmi1kGxZDS)8Ind4bYXwzejy9YMur4798ihBLrKWk)PIW3J92M14zKyrjhJSB6i2dVn4Ox8BdLEycCjFWFppYXwzejy9YM0wjm45LxCNFAOgBl0Ls1(rpp(EolihBLrucbz2igQX2cDP5(fwc0BtEhsq4JC9Ns)2qy575SGCSvgrjeKzJOl75ro2kJiXwjeKzdwjUTznEgjqVn5DO0wjeKzJNhFpNfolTLtmuJTf6sZ9lSeO3M8oKGWh56pL(THWkXTnRXZiXIsogz3ew(EolCwAlNyOgBl0Le(ix)P0Vnew(EolCwAlNOl75X3ZzXy3ub7OuEOsY(fDzS32SgpJeCh7ptBLYdvs2VNNe32SgpJelk5yKDty575SWzPTCIHASTq(q4JC9Ns)2qQ0TTg(kI0GZBtEhsJnRXwA0I9YgnWBhBLr0fASLgCGmB0aVDSvgrAalnW)w14Tbh9inGJgpud5b60GdKzJg4TJTYisL2C)clKWGuRaEn6TjVdPs32A0cng7pNUkT5(fwiHbPwb86PxjZ9lSsSf9xuwdby2yS)C6Q0Q0TTgTWHkj7xdU7FQHKA51(s5uPn3VWcj4H2d4y3ub7OuEOsY(VyZaY3ZzHZsB5ed1yBH8rk8Os32A4RisJwcAY)EtAWHRnnAW9KknSxdgHqA8NwPb(RbMcBjMOb6nhainScuJhQXq5HqNAyACjGyqd0Boa0WqAWSN0WqAidrOLNrAahn(TH0yFnqqn2xdBM9MqAGzth9Ay5Ngnmn8DRAGEZbGge(K3HqQ0M7xyHe8q7BfWRnqt(3BkH4AtZfo)ogLEBWrpcqPUyZaY3ZzbVXSYrjyozmw6p3chkv23hsGEZbWLTfw(Eol4nMvokbZjJXs)5w4qjBCwrc0BoaUSTWEqcq4lmqt(3BkH4Attc0AmCK4xhaBHdReM7xyjmqt(3BkH4Attc0AmCKyRuMT4oFShKae(cd0K)9MsiU20KojJj(1bWw488aHVWan5FVPeIRnnPtYyIHASTq(47JEEGWxyGM8V3ucX1MMeO1y4ib6nhax6BSGWxyGM8V3ucX1MMeO1y4iXqn2wOlXdwq4lmqt(3BkH4Attc0AmCK4xhaBH7OkDBRHVIinKeSUHaqAWD)tnKulV2xkNgCpPsdzicT8msdRa1a(N0WDrKgC3)udtdmf2smrd(EoRb3tQ0aKq(l3w4uPn3VWcj4H23kGx7G1neak9NucjVZ(Ol2mGsao9fuuWKdeH9WHBBwJNrchSUHaqjqc5VCyLWbHmqi3s4S0woXqgOFpp(EolCwAlNOlFe7b(Eol4nMvokbZjJXs)5w4qPY((qc0BoaaST88475SG3yw5OemNmgl9NBHdLSXzfjqV5aaW26ONhpeHWMxCNFAOgBl0Ls1owheYaHClHZsB5ed1yBH8bJDuLUT1OfcXBnmKg)jPrEh0RbohOgBPXFsAyAGPWwIjAWDlqixnGJgC3)uJ)K04kH)zTsd(EoRbC0G7(NAyA0wTIiNgTe0K)9M0GdxBA0Wkqn4A7RrgoAiPwETVuon2Sg7Rbxy9AWtA0L1WWzBPbpLHdPXFsA4a1yrAK3ArNeOkT5(fwibp0(wb86CF8NG5eX6fDXMb8WHd89CwWBmRCucMtgJL(ZTWHsL99HeO3Ca4dg3ZJVNZcEJzLJsWCYyS0FUfouYgNvKa9MdaFW4hXEqch8MkREXnv)P)XZtc(Eolg7MkyhLYdvs2VOlF8i2dGtFbffm5arEEoiKbc5wcNL2YjgQX2c5dEA3Z7GdEtLvVOwCNFkBewheYaHClHdw3qaO0FsjK8o7Jed1yBH8bpTF84rpVdGWxyGM8V3ucX1MMeO1y4iXqn2wiFAlSoiKbc5wcNL2YjgQX2c5JuTJ1bVPYQxuKBGm4aE0ZBRNgziZEcmLxCNFAOgBl0LTfwjCqideYTeolTLtmKb63ZZbVPYQxaG)zTclFpNfaSf4qGjQrgYLMgQErx2ZZbVPYQxCt1F6FWY3ZzXy3ub7OuEOsY(fd1yBHU8QXY3ZzXy3ub7OuEOsY(fDzv62wdjzLJyAW5THbhqn4U)PgMgfXvdmf2smrd(EoRHvGAiPwETVuonwu1MxdJh2FnEOg8KgDebQsBUFHfsWdTVvaV2zLJyj(EoFrzneGO3ggCaVyZaEGVNZcEJzLJsWCYyS0FUfouQSVpKyOgBlKpymbE88475SG3yw5OemNmgl9NBHdLSXzfjgQX2c5dgtGNJyp4GqgiKBjCwAlNyOgBlKpympVdoiKbc5wcQrgYLMepSafd1yBH8bJHvc(EolaylWHatuJmKlnnu9jQOb3kzs0LX6G3uz1laW)SwD8iwd9JXsYqU04dG(UDv62wJwqVrwdoVnO(GJqAWD)tnmnWuylXen475Sg89xJc(AW9KknKHq2w40idhnKulV2xkNgWrJReBboeOgCK3zFKkT7xyHe8q7BfWRrVnO(GJUyZaEGVNZcEJzLJsWCYyS0FUfouQSVpKa9MdaFWGNhFpNf8gZkhLG5KXyP)ClCOKnoRib6nha(GHJypCqch8MkRErT4o)u2ippd9JXsYqU04dG4F7hX6GqgiKBjCwAlNyOgBlKpymppjUTznEgjCGjhSa3FHfwjCWBQS6fa4FwR88o4GqgiKBjOgzixAs8WcumuJTfYhmgwj475SaGTahcmrnYqU00q1NOIgCRKjrxgRdEtLvVaa)ZA1XJypibi8f5(4pbZjI1ls8RdGTW55jHdczGqULWzPTCIHmq)EEs4GqgiKBjCW6gcaL(tkHK3zFKyid0)rv62wJwqVrwdoVnO(GJqAWtz4qAijyDdbGuPn3VWcj4H23kGxJEBq9bhDXMb8GdczGqULWbRBiau6pPesEN9rIHASTqxIhSsao9fuuWKdeH9WTnRXZiHdw3qaOeiH8xoppheYaHClHZsB5ed1yBHUephXEBZA8ms4atoybU)cRJyLae(ICF8NG5eX6fj(1bWw4W6G3uz1lQf35NYgHvcWPVGIcMCGiSKJTYisSvYk)yn0pgljd5sJp4F7Q0TTgTay1Mxdq4RbyF2cNg)jPbvGAaZACLA3ub7inAHdvs2)fAa2NTWPbaBboeOguJmKlnnu9Aahn2sJ)K0GzOxdCoqnGznSsd82XwzePsBUFHfsWdTVvaV(2M14z0fL1qacc)0q4vFhQHQhDXTX6eGh475SySBQGDukpujz)IHASTq(Ghppj475SySBQGDukpujz)IU8rSh475SaGTahcmrnYqU00q1NOIgCRKjXqn2wOlX5afng(oI9aFpNfKJTYikHGmBed1yBH8bNdu0y4ZZJVNZcYXwzeLy9YgXqn2wiFW5afng(oQsBUFHfsWdTVvaVg1R8o0fo)ogLEBWrpcqPUyZaouEi0PXZiSVn4Ox8BdLEycCjFKcJJ1KtUtYba2BBwJNrcq4NgcV67qnu9ivAZ9lSqcEO9Tc41nqyL3HUW53XO0Bdo6rak1fBgWHYdHonEgH9Tbh9IFBO0dtGl5Ju(wGhSMCYDsoaWEBZA8msac)0q4vFhQHQhPsBUFHfsWdTVvaVg9eJztkZSHUW53XO0Bdo6rak1fBgWHYdHonEgH9Tbh9IFBO0dtGl5Juy8whQX2cH1KtUtYba2BBwJNrcq4NgcV67qnu9iv62wJwieZ1awA4a1G7(NW(RHZKL3cNkT5(fwibp0(wb86mCCucMtL99HUyZaAYj3j5aqLUT1aVBKHCPrdmfwGAW9KknmEy)14HAq1tJgMgfXvdmf2smrdUBbc5QHvGAGSBsJmC0qsT8AFPCQ0M7xyHe8q7BfWRPgzixAs8Wc8Ind4bYXwzejy9YMur4798ihBLrKabz2KkcFVNh5yRmIew5pve(Epp(Eol4nMvokbZjJXs)5w4qPY((qIHASTq(GXe4XZJVNZcEJzLJsWCYyS0FUfouYgNvKyOgBlKpymbE88m0pgljd5sJpxD7yDqideYTeolTLtmKb6hReGtFbffm5arhXEWbHmqi3s4S0woXqn2wiF8D7EEoiKbc5wcNL2YjgYa9F0ZJhIqy36PrgYSNat5f35NgQX2cDPuTRs32A0cH4TgZI781GNYWH0OJ2cNgsQLQ0M7xyHe8q7BfWRZ9XFcMteRx0fBgqheYaHClHZsB5edzG(XEBZA8ms4atoybU)clShm0pgljd5sJpxD7yLWbVPYQxulUZpLnYZZbVPYQxulUZpLncRH(XyjzixAUe)B)iwjCWBQS6f3u9N(hShKWbVPYQxulUZpLnYZZbHmqi3s4G1neak9NucjVZ(iXqgO)JyLaC6lOOGjhisLUT1qsT8AFPCAW9KknSxJRU9w1OLORqJdWHb5sJg)PvAG)TRrlrxHgC3)udjbRBia0rn4U)jS)AWGOTWPXVnKgBPbMYGqqwh9AyfOgSTin6YAWD)tnKeSUHaqASzn2xdUgsdqc5VCeOkT5(fwibp0(wb86BBwJNrxuwdbOdm5Gf4(lSs8q7V42yDcqjaN(ckkyYbIWEBZA8ms4atoybU)clShoyOFmwsgYLgFU62XEGVNZca2cCiWe1id5stdvFIkAWTsMeDzppjCWBQS6fa4FwRo65X3ZzbpdcbzD0l6Yy575SGNbHGSo6fd1yBHUKVNZcNL2Yja7J9lSo65XdriSB90idz2tGP8I78td1yBHUKVNZcNL2Yja7J9lS88CWBQS6f1I78tzJoI9Geo4nvw9IAXD(PSrEEhm0pgljd5sZL4F7EEGWxK7J)emNiwViXVoa2c3rShUTznEgjCW6gcaLajK)Y555GqgiKBjCW6gcaL(tkHK3zFKyid0)XJQ0M7xyHe8q7BfWRDeJq)ASKXwCvdv)fBgWBBwJNrchyYblW9xyL4H2RsBUFHfsWdTVvaVElNnL9lSUyZaEBZA8ms4atoybU)cRep0Ev62wd8g9BJ9esJtixnA6UtnAj6k0WgsdC2weOgY0ObICWcuL2C)clKGhAFRaE9TnRXZOlkRHa0qYxbnCi3f3gRtaso2kJiXwjwVSbJAlmJ5(fwc0BtEhsq4JC9Ns)2qTkb5yRmIeBLy9Ygm6agV13yu9ceSZsWC6pPugoe6fuz8mceJ89rmJ5(fwcUJ9NccFKR)u63gQ12fyaZGKjglDAONuPBBnAb9gzn482G6docPb3tQ04pjnYlUZxJfPHXd7VgpudQaVqJ8qLK9RXI0W4H9xJhQbvGxOHFyxdBinSxJRU9w1OLORqJT0WknWBhBLr0fAiPwETVuonyg6rAyf8pPrJ2Qve5qAahn8d7AWf2zGAaVPXzYA0ahsJ)0knupPAxJwIUcn4EsLg(HDn4c7mWQnVgCEBq9bhPrb5QsBUFHfsWdTVvaVg92G6do6Ind4bEicHDRNgziZEcmLxCNFAOgBl0L4VN3b(Eolg7MkyhLYdvs2VyOgBl0L4CGIgdFyKJw2bd9JXsYqU0Gz8D7hXY3ZzXy3ub7OuEOsY(fD5Jh98oyOFmwsgYLMwVTznEgjmK8vqdhYHr89Cwqo2kJOecYSrmuJTfQvq4lY9XFcMteRxK4xhaO0qn2wyege4XhPKQDppd9JXsYqU006TnRXZiHHKVcA4qomIVNZcYXwzeLy9YgXqn2wOwbHVi3h)jyorSErIFDaGsd1yBHryqGhFKsQ2pILCSvgrITsw5h7bj475SWzPTCIUSNNeVXO6fO3ggCafuz8mc8i2dhKWbHmqi3s4S0worx2ZZbVPYQxaG)zTcReoiKbc5wcQrgYLMepSafD5JEEo4nvw9IAXD(PSrhXEqch8MkREXnv)P)XZtc(EolCwAlNOl75zOFmwsgYLgFU62p65D4ngvVa92WGdOGkJNrGy575SWzPTCIUm2d89CwGEByWbuGEZbWL(2ZZq)ySKmKln(C1TF8ONhFpNfolTLt0LXkbFpNfJDtfSJs5Hkj7x0LXkXBmQEb6THbhqbvgpJavPBBn8vePXvgewin2sJwSx2ObE7yRmI0Wkqnq2nPXvYgl3AlSZyACLbHLgz4OHKA51(s5uPn3VWcj4H23kGxxe3udewxSzapW3Zzb5yRmIsSEzJyOgBlKpe(ix)P0VnKN3b3Pn4ieGya7qUtBWrPFBOlXZrpp3Pn4ieG((iwto5ojhaQ0M7xyHe8q7BfWRpnwo1aH1fBgWd89Cwqo2kJOeRx2igQX2c5dHpY1Fk9BdH9GdczGqULWzPTCIHASTq(GN298CqideYTeoyDdbGs)jLqY7SpsmuJTfYh80(rpVdUtBWriaXa2HCN2GJs)2qxINJEEUtBWria99rSMCYDsoauPn3VWcj4H23kGxN7mwQbcRl2mGh475SGCSvgrjwVSrmuJTfYhcFKR)u63gc7bheYaHClHZsB5ed1yBH8bpT755GqgiKBjCW6gcaL(tkHK3zFKyOgBlKp4P9JEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaOs32AGzbXBnGLgoqvAZ9lSqcEO9Tc41CTzw4KG5eX6fPs32A4RisdoVn5DinEOgYd0PbhiZgnWBhBLrKgWrdUNuPXwAalMFnAXEzJg4TJTYisdRa1OJinWSG4TgYd0H0yZASLgTyVSrd82XwzePsBUFHfsWdTVvaVg92K3HUyZaso2kJiXwjwVSXZJCSvgrceKztQi89EEKJTYisyL)ur4798475SGRnZcNemNiwVirxglFpNfKJTYikX6LnIUSN3b(EolCwAlNyOgBl0LM7xyj4o2Fki8rU(tPFBiS89Cw4S0worx(OkT5(fwibp0(wb8AUJ9NQ0M7xyHe8q7BfWRNELm3VWkXw0FrzneGzJX(ZPRsRs32AW5Tb1hCKgz4Ord8MAO61OxmcH0OJ2cNgykSLyIkT5(fwir2yS)C6aIEBq9bhDXMbuIPxugo4ibVXSYrjyozmw6p3chsq4vFLLjqv62wdjzOxJ)K0ae(AWD)tn(tsJgi6143gsJhQHbcQrV(LPXFsA0y4tdW(y)clnwKgN7l0GtVY7qAmuJTfsJMo7xz2sGA8qnAS3DQrdew5Dina7J9lSuPn3VWcjYgJ9NtVvaVg1R8o0fo)ogLEBWrpcqPUyZaccFrdew5DiXqn2wiFgQX2cHryadygPAlvAZ9lSqISXy)50BfWRBGWkVdPsRs32A4RisdoVnO(GJ04HAaarYA0L14pjnAbdzn8BbsJg89CwJnRX(AWf2zGAq4tEhsdEkdhsJ8wl6ClCA8NKgfHVxdNHEnGJgpudWEJSg8ugoKgscw3qaivAZ9lSqc0di6Tb1hC0fBgWPxugo4iXVnex4ujWHSg(TaPb7bYXwzej2kzLFSsC4aFpNf)2qCHtLahYA43cKgXqn2wiFm3VWsWDS)uq4JC9Ns)2qT2UqkShihBLrKyRep8p98ihBLrKyRecYSXZJCSvgrcwVSjve((JEE89Cw8BdXfovcCiRHFlqAed1yBH8XC)clb6TjVdji8rU(tPFBOwBxif2dKJTYisSvI1lB88ihBLrKabz2KkcFVNh5yRmIew5pve((Jh98KGVNZIFBiUWPsGdzn8BbsJOlF0Z7aFpNfolTLt0L98UTznEgjCW6gcaLajK)YDeRdczGqULWbRBiau6pPesEN9rIHmq)yDWBQS6f1I78tzJoI9Geo4nvw9ca8pRvEEoiKbc5wcQrgYLMepSafd1yBH8PToI9aFpNfolTLt0L98KWbHmqi3s4S0woXqgO)JQ0TTg(kI0OLGM8V3KgC4AtJgCpPsJ)KgsJfPrb1WC)EtAG4AtZfAyiny2tAyinKHi0YZinGLgiU20Ob39p1adAahnYexA0a9MdaKgWrdyPHPHVBvdexBA0ab14pTxJ)K0OiUAG4AtJg2m7nH0aZMo61WYpnA8N2RbIRnnAq4tEhcPsBUFHfsG(wb8Ad0K)9MsiU20CHZVJrP3gC0JauQl2mGsacFHbAY)EtjexBAsGwJHJe)6aylCyLWC)clHbAY)EtjexBAsGwJHJeBLYSf35J9GeGWxyGM8V3ucX1MM0jzmXVoa2cNNhi8fgOj)7nLqCTPjDsgtmuJTfYh8C0Zde(cd0K)9MsiU20KaTgdhjqV5a4sFJfe(cd0K)9MsiU20KaTgdhjgQX2cDPVXccFHbAY)EtjexBAsGwJHJe)6aylCQ0TTg(kIqAijyDdbG0yZAiPwETVuonwKgDznGJg(HDnSH0aKq(l3w40qsT8AFPCAWD)tnKeSUHaqAyfOg(HDnSH0GNyqUAG)TRrlrxHkT5(fwib6BfWRDW6gcaL(tkHK3zF0fBgqjaN(ckkyYbIWE4WTnRXZiHdw3qaOeiH8xoSs4GqgiKBjCwAlNyid0pwjMErz4GJeYZ2ahW1yjBCwTUKCNHSXZJVNZcNL2Yj6YhXAOFmwsgYLMlbe)Bh7b(EolihBLruI1lBed1yBH8rQ298475SGCSvgrjeKzJyOgBlKps1(rppEicHnV4o)0qn2wOlLQDSs4GqgiKBjCwAlNyid0)rv62wdjblW9xyPrgoAymMgGWhPXFAVgngaesduFin(tYVg2qvBEngkpe6Ka1G7jvACLA3ub7inAHdvs2VgNgsdgHqA8NwPbE0aroKgd1yBTfonGJg)jPba(N1kn475SglsdJh2FnEOgzJX0aMZAahnSYVg4TJTYisJfPHXd7VgpudcFY7qQ0M7xyHeOVvaV(2M14z0fL1qacc)0q4vFhQHQhDXTX6eGh475SySBQGDukpujz)IHASTq(Ghppj475SySBQGDukpujz)IU8rSsW3ZzXy3ub7OuEOsY(tOTYDw60p6Pznrxg7b(EolaylWHatuJmKlnnu9jQOb3kzsmuJTf6sCoqrJHVJypW3Zzb5yRmIsiiZgXqn2wiFW5afng(88475SGCSvgrjwVSrmuJTfYhCoqrJHppVdsW3Zzb5yRmIsSEzJOl75jbFpNfKJTYikHGmBeD5JyL4ngvVabzOFDKGkJNrGhvPBBnKeSa3FHLg)P9A4ojhain2Sg(HDnSH0a2F0csAqo2kJinEOgWI5xdq4RXFsdPbC0yXvWH04pxKgC3)udoqg6xhPsBUFHfsG(wb86BBwJNrxuwdbii8tW(Jwqkro2kJOlUnwNa8Ge89Cwqo2kJOecYSr0LXkbFpNfKJTYikX6LnIU8rpV3yu9ceKH(1rcQmEgbQsBUFHfsG(wb86giSY7qx487yu6Tbh9iaL6Ind4q5HqNgpJWEGVNZcYXwzeLqqMnIHASTq(muJTfYZJVNZcYXwzeLy9YgXqn2wiFgQX2c55DBZA8msac)eS)OfKsKJTYi6i2HYdHonEgH9Tbh9IFBO0dtGl5JuyaRjNCNKdaS32SgpJeGWpneE13HAO6rQ0M7xyHeOVvaVg1R8o0fo)ogLEBWrpcqPUyZaouEi0PXZiSh475SGCSvgrjeKzJyOgBlKpd1yBH88475SGCSvgrjwVSrmuJTfYNHASTqEE32SgpJeGWpb7pAbPe5yRmIoIDO8qOtJNryFBWrV43gk9We4s(ifgWAYj3j5aa7TnRXZibi8tdHx9DOgQEKkT5(fwib6BfWRrpXy2KYmBOlC(Dmk92GJEeGsDXMbCO8qOtJNrypW3Zzb5yRmIsiiZgXqn2wiFgQX2c55X3Zzb5yRmIsSEzJyOgBlKpd1yBH88UTznEgjaHFc2F0csjYXwzeDe7q5HqNgpJW(2GJEXVnu6HjWL8rkmowto5ojhayVTznEgjaHFAi8QVd1q1JuPBBn8vePrleI5AalnCGAWD)ty)1WzYYBHtL2C)clKa9Tc41z44OemNk77dDXMb0KtUtYbGkDBRHVIinUsSf4qGAWrEN9rAWD)tnSYVgmyHtdQGDCNAWm0VfonWBhBLrKgwbQXp(14HAW2I0yFn6YAWD)tnUIodzJgwbQHKA51(s5uPn3VWcjqFRaEn1id5stIhwGxSzapCGVNZcYXwzeLqqMnIHASTq(iv7EE89Cwqo2kJOeRx2igQX2c5JuTFeRdczGqULWzPTCIHASTq(472XEGVNZc5zBGd4ASKnoRwxsUZq2iUnwNUed4F7EEsm9IYWbhjKNTboGRXs24SADj5odzJGWR(kltGhp65X3ZzH8SnWbCnwYgNvRlj3ziBe3gRt(aigWyT75X3ZzHZsB5ed1yBH8rQ2vPBBn8vePHKA51(s50G7(NAijyDdbGU(kXwGdbQbh5D2hPHvGAacR28AaVPH7SpPXv0ziB0aoAW9KknWugecY6OxdUWodudcFY7qAWtz4qAiPwETVuoni8jVdHuPn3VWcjqFRaE9TnRXZOlkRHa0bMCWcC)fwj0FXTX6eGsao9fuuWKdeH92M14zKWbMCWcC)fwypCWbHmqi3sqnY(hYyj4aww5iXqn2wOlLcJJXA9GusHrtVOmCWrc0w5olD6h90S2rSeE1xzzcuqnY(hYyj4aww5OJEEg6hJLKHCPXhaV62XEqI3yu9ICF8NG5eX6fjOY4zeONhFpNfolTLta2h7xy5JdczGqULi3h)jyorSErIHASTqT2whXccFbQx5DiXqn2wiFKcdybHVObcR8oKyOgBlKpTf2dGWxGEIXSjLz2qIHASTq(0wEEs8gJQxGEIXSjLz2qcQmEgbEe7TnRXZiXFolJLqebanjU2(yp4GqgiKBjOgzixAs8Wcu0L98KWbVPYQxaG)zT6i23gC0l(THspmbUKp89Cw4S0wobyFSFHfg1UaJ55XdriS5f35NgQX2cDjFpNfolTLta2h7xy555G3uz1lQf35NYg55X3ZzbpdcbzD0l6Yy575SGNbHGSo6fd1yBHUKVNZcNL2Yja7J9lSA9WvJrtVOmCWrc5zBGd4ASKnoRwxsUZq2ii8QVYYe4XJyLGVNZcNL2Yj6YypiHdEtLvVOwCNFkBKNNdczGqULWbRBiau6pPesEN9rIUSNhpeHWMxCNFAOgBl0LoiKbc5wchSUHaqP)Ksi5D2hjgQX2c1kg3ZlV4o)0qn2wimdMrQ2Q9l575SWzPTCcW(y)cRJQ0M7xyHeOVvaV(2M14z0fL1qa6atoybU)cRe6V42yDcqjaN(ckkyYbIWEBZA8ms4atoybU)clSho4GqgiKBjOgz)dzSeCalRCKyOgBl0LsHXXyTEqkPWOPxugo4ibARCNLo9JEAw7iwcV6RSmbkOgz)dzSeCalRC0rppd9JXsYqU04dGxD7ypiXBmQErUp(tWCIy9Ieuz8mc0ZJVNZcNL2Yja7J9lS8XbHmqi3sK7J)emNiwViXqn2wOwBRJybHVa1R8oKyOgBlKpTfwq4lAGWkVdjgQX2c5ZvJ9ai8fONymBszMnKyOgBlKps1UNNeVXO6fONymBszMnKGkJNrGhXEBZA8ms8NZYyjeraqtIRTp2d89CwaWwGdbMOgzixAAO6turdUvYKOl75jHdEtLvVaa)ZA1rSVn4Ox8BdLEycCjF475SWzPTCcW(y)clmQDbgZZJhIqyZlUZpnuJTf6s(EolCwAlNaSp2VWYZZbVPYQxulUZpLnYZJVNZcEgecY6Ox0LXY3ZzbpdcbzD0lgQX2cDjFpNfolTLta2h7xy16HRgJMErz4GJeYZ2ahW1yjBCwTUKCNHSrq4vFLLjWJhXkbFpNfolTLt0LXEqch8MkRErT4o)u2ippheYaHClHdw3qaO0FsjK8o7JeDzppEicHnV4o)0qn2wOlDqideYTeoyDdbGs)jLqY7SpsmuJTfQvmUNhpeHWMxCNFAOgBleMbZivB1(L89Cw4S0wobyFSFH1rv62wdFfrA8NKgy2P6p9pAWD)tnmnKulV2xkNg)P9ASOQnVg5b2OXv0ziBuPn3VWcjqFRaE9y3ub7OuEOsY(VyZaY3ZzHZsB5ed1yBH8rk845X3ZzHZsB5eG9X(fwx6BmG92M14zKWbMCWcC)fwj0RsBUFHfsG(wb8AhXi0VglzSfx1q1FXMb82M14zKWbMCWcC)fwj0J9aFpNfolTLta2h7xy5dG(gdEEs4G3uz1lUP6p9ph98475SySBQGDukpujz)IUmw(Eolg7MkyhLYdvs2VyOgBl0LxDRoyb23xipKBruYylUQHQx8BdLUnwNA9Ge89CwWZGqqwh9IUmwjEJr1lqVnm4akOY4ze4rvAZ9lSqc03kGxVLZMY(fwxSzaVTznEgjCGjhSa3FHvc9Q0TTgy2TznEgPrhrGAalnm(LT)sin(t71GRvVgpudEsdKDtGAKHJgsQLx7lLtdeuJ)0En(tYVg2q1Rbxd9eOgy20rVg8ugoKg)j1OsBUFHfsG(wb86BBwJNrxuwdbiYUPugojNL2YDXTX6eGs4GqgiKBjCwAlNyid0VNNe32SgpJeoyDdbGsGeYF5W6G3uz1lQf35NYg55bo9fuuWKdePs32A4RicPrleI3ASzn2sdR0aVDSvgrAyfOg)SesJhQbBlsJ91OlRb39p14k6mKnxOHKA51(s50WkqnAjOj)7nPbhU20OsBUFHfsG(wb86CF8NG5eX6fDXMbKCSvgrITsw5hRjNCNKdaS89CwipBdCaxJLSXz16sYDgYgXTX60Lya)Bh7bq4lmqt(3BkH4Attc0AmCK4xhaBHZZtch8MkRErrUbYGd4rS32SgpJei7Msz4KCwAlh2d89Cwm2nvWokLhQKSFXqn2wOlV6R6aEWOPxugo4ibARCNLo9JEAwRvji8QVYYeOyl0pD3dhucCV3Is8eJDelFpNfJDtfSJs5Hkj7x0L98KGVNZIXUPc2rP8qLK9l6YhXEqch8MkREba(N1kppheYaHClb1id5stIhwGIHASTq(GH2pQs32A4RisJR8I(tn482Kngtd5b6qASzn482KngtJfvT51OlRsBUFHfsG(wb8A0Bt2ySl2mG89Cwal6prjzACK8VWs0LXY3Zzb6TjBmMyO8qOtJNrQ0M7xyHeOVvaV2zLJyj(EoFrzneGO3ggCaVyZaY3Zzb6THbhqXqn2wOlXd2d89Cwqo2kJOecYSrmuJTfYh845X3Zzb5yRmIsSEzJyOgBlKp45iwd9JXsYqU04Zv3UkDBRrlO3iJ0OLORqdEkdhsdjbRBiaKgD0w404pjnKeSUHaqA4Gf4(lS04HA4ojhaASznKeSUHaqASinm33ngZVggpS)A8qn4jnCg6vPn3VWcjqFRaEn6Tb1hC0fBgqh8MkRErT4o)u2iS32SgpJeoyDdbGsGeYF5W6GqgiKBjCW6gcaL(tkHK3zFKyOgBl0L4bReGtFbffm5aryjhBLrKyRKv(XAOFmwsgYLgFW)2vPBBn8vePbN3MSXyAWD)tn48eJzJgTGzZVgwbQrb1GZBddoGxOb3tQ0OGAW5TjBmMglsJU8fA4h21WgsJT0Of7LnAG3o2kJinYWrJ2Qve5qAahnEOgYd0PXv0ziB0G7jvAy8WBsJRUDnAj6k0aoAyGY2V3KgiU20OXPH0OTAfroKgd1yBTfonGJglsJT0iZwCNVqdmh(Kg)P9A0lqA04pjnqwdPHdwG7VWcPX(TbPbOmsJI6)ymnEOgCEBYgJPbyF2cNgxP2nvWosJw4qLK9FHgCpPsd)WEBa1a9lJPbvGA0L1G7(NAC1T3QHK1idhn(tsdMHEnWXG8gdjuPn3VWcjqFRaEn6TjBm2fBgW3yu9c0tmMnjWzZVGkJNrGyL4ngvVa92WGdOGkJNrGy575Sa92KngtmuEi0PXZiSh475SGCSvgrjwVSrmuJTfYN2cl5yRmIeBLy9YgS89CwipBdCaxJLSXz16sYDgYgXTX60LyapT75X3ZzH8SnWbCnwYgNvRlj3ziBe3gRt(aigWt7yn0pgljd5sJpxD7EEGWxyGM8V3ucX1MMeO1y4iXqn2wiFAlppZ9lSegOj)7nLqCTPjbAngosSvkZwCN)rSoiKbc5wcNL2YjgQX2c5JuTRs32A4RisdoVnO(GJ04kVO)ud5b6qAyfOgG9gznAj6k0G7jvAiPwETVuonGJg)jPbMDQ(t)Jg89CwJfPHXd7VgpuJSXyAaZznGJg(H92aQHZK1OLORqL2C)clKa9Tc41O3guFWrxSza575Saw0FIsogzt6ErlSeDzpp(EolaylWHatuJmKlnnu9jQOb3kzs0L98475SWzPTCIUm2d89Cwm2nvWokLhQKSFXqn2wOlX5afng(WihTSdg6hJLKHCPbZ472p2QVXO3yu9II4MAGWsqLXZiqSsm9IYWbhjqBL7S0PF0tZAy575SySBQGDukpujz)IUSNhFpNfolTLtmuJTf6sCoqrJHpmYrl7GH(XyjzixAWm(U9JEE89Cwm2nvWokLhQKS)eARCNLo9JEAwt0L98oW3ZzXy3ub7OuEOsY(fd1yBHU0C)clb6TjVdji8rU(tPFBiSizIXsNg6PlBxG)EE89Cwm2nvWokLhQKSFXqn2wOln3VWsWDS)uq4JC9Ns)2qEE32SgpJelEbMCWcC)fwyDqideYTeBHCt)nEgLWRUvFVjbs3RJedzG(Xs4vFLLjqXwi30FJNrj8QB13BsG096OJy575SySBQGDukpujz)IUSNNe89Cwm2nvWokLhQKSFrxgReoiKbc5wIXUPc2rP8qLK9lgYa975jHdEtLvV4MQ)0)C0ZZq)ySKmKln(C1TJLCSvgrITsw5xLUT1atg)A8qnAmain(tsdEc9AaZAW5THbhqn49Rb6nhaBHtJ91OlRbE1xham)ASLgw5xd82XwzePbF)14k6mKnASO61W4H9xJhQbpPH8aDocuL2C)clKa9Tc41O3guFWrxSzaFJr1lqVnm4akOY4zeiwjMErz4GJe)2qCHtLahYA43cKgSh475Sa92WGdOOl75zOFmwsgYLgFU62pILVNZc0BddoGc0BoaU03ypW3Zzb5yRmIsiiZgrx2ZJVNZcYXwzeLy9Ygrx(iw(EolKNTboGRXs24SADj5odzJ42yD6smGXAh7bheYaHClHZsB5ed1yBH8rQ298K42M14zKWbRBiaucKq(lhwh8MkRErT4o)u2OJQ0TTg4n63g7jKgNqUA00DNA0s0vOHnKg4STiqnKPrde5GfOkT5(fwib6BfWRVTznEgDrzneGgs(kOHd5U42yDcqYXwzej2kX6LnyuBHzm3VWsGEBY7qccFKR)u63gQvjihBLrKyReRx2GrhW4T(gJQxGGDwcMt)jLYWHqVGkJNrGyKVpIzm3VWsWDS)uq4JC9Ns)2qT2Ua)XdMbjtmw60qp1A7c8GrVXO6fL99HqjEJzLJeuz8mcuLUT1Of0BK1GZBdQp4in2sdtdmwRiYPbhiZgnWBhBLr0fAacR28AWOxJ91qEGonUIodzJgh(t71yrACAfiJa1G3Vg0(N0OXFsAW5TjBmMgSTinGJg)jPrlrxHpxD7AW2I0idhn482G6do64fAacR28AaVPH7SpPHvACLx0FQH8aDAyfOgm614pjnmE4nPbBlsJtRazKgCEByWbuL2C)clKa9Tc41O3guFWrxSzaLy6fLHdos8BdXfovcCiRHFlqAWEGVNZc5zBGd4ASKnoRwxsUZq2iUnwNUedyS298475SqE2g4aUglzJZQ1LK7mKnIBJ1PlXaEAh7BmQEb6jgZMe4S5xqLXZiWJypqo2kJiXwjeKzdwd9JXsYqU006TnRXZiHHKVcA4qomIVNZcYXwzeLqqMnIHASTqTccFrUp(tWCIy9Ie)6aaLgQX2cJWGap(0wT75ro2kJiXwjwVSbRH(XyjzixAA92M14zKWqYxbnCihgX3Zzb5yRmIsSEzJyOgBluRGWxK7J)emNiwViXVoaqPHASTWimiWJpxD7hXkbFpNfWI(tusMghj)lSeDzSs8gJQxGEByWbuqLXZiqShCqideYTeolTLtmuJTfYhmMNhc2z8Bbk(ZzzSeIiaOrqLXZiqS89Cw8NZYyjeraqJa9MdGl9TVVQdtVOmCWrc0w5olD6h90SggHNJyZlUZpnuJTfYhPAVDS5f35NgQX2cDjgAVDppWPVGIcMCGOJyp4GqgiKBjaylWHati5D2hjgQX2c5dgZZtch8MkREba(N1QJQ0TTg(kI04kdclKgBPrl2lB0aVDSvgrAyfOgi7M04kzJLBTf2zmnUYGWsJmC0qsT8AFPCAyfOgxj2cCiqnW7gzixAAO6vPn3VWcjqFRaEDrCtnqyDXMb8aFpNfKJTYikX6LnIHASTq(q4JC9Ns)2qEEhCN2GJqaIbSd5oTbhL(THUeph98CN2GJqa67Jyn5K7KCaG92M14zKaz3ukdNKZsB5uPn3VWcjqFRaE9PXYPgiSUyZaEGVNZcYXwzeLy9YgXqn2wiFi8rU(tPFBiSs4G3uz1laW)Sw55DGVNZca2cCiWe1id5stdvFIkAWTsMeDzSo4nvw9ca8pRvh98o4oTbhHaedyhYDAdok9BdDjEo655oTbhHa03EE89Cw4S0worx(iwto5ojhayVTznEgjq2nLYWj5S0woSh475SySBQGDukpujz)IHASTqxEapxfgWOPxugo4ibARCNLo9JEAw7iw(Eolg7MkyhLYdvs2VOl75jbFpNfJDtfSJs5Hkj7x0LpQsBUFHfsG(wb86CNXsnqyDXMb8aFpNfKJTYikX6LnIHASTq(q4JC9Ns)2qyLWbVPYQxaG)zTYZ7aFpNfaSf4qGjQrgYLMgQ(ev0GBLmj6YyDWBQS6fa4FwRo65DWDAdocbigWoK70gCu63g6s8C0ZZDAdocbOV98475SWzPTCIU8rSMCYDsoaWEBZA8msGSBkLHtYzPTCypW3ZzXy3ub7OuEOsY(fd1yBHUepy575SySBQGDukpujz)IUmwjMErz4GJeOTYDw60p6Pznppj475SySBQGDukpujz)IU8rv62wdFfrAGzbXBnGLgoqvAZ9lSqc03kGxZ1MzHtcMteRxKkDBRHVIin482K3H04HAipqNgCGmB0aVDSvgrxOHKA51(s5040qAWiesJFBin(tR0W0aZAS)udcFKR)Kgmk)AahnGfZVgTyVSrd82XwzePXI0OlRsBUFHfsG(wb8A0BtEh6Indi5yRmIeBLy9YgSsW3ZzXy3ub7OuEOsY(fDzppYXwzejqqMnPIW375ro2kJiHv(tfHV3Z7aFpNfCTzw4KG5eX6fj6YEEizIXsNg6PlBxG)4bReo4nvw9IBQ(t)JNhsMyS0PHE6Y2f4pwh8MkREXnv)P)5iw(EolihBLruI1lBeDzpVd89Cw4S0woXqn2wOln3VWsWDS)uq4JC9Ns)2qy575SWzPTCIU8rv62wdFfrAGzn2FQb8pPH7Iin4EUUtnwKgBPbhiZgnWBhBLr0fAiPwETVuonGJgpud5b60Of7LnAG3o2kJivAZ9lSqc03kGxZDS)uLUT1OfAm2FoDvAZ9lSqc03kGxp9kzUFHvITO)IYAiaZgJ9Nth4d8bce]] )
    

end