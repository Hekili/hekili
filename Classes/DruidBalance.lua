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
            id = 33786,
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


    spec:RegisterPack( "Balance", 20211123, [[di156fqikjpcsuxcsK2eK6tKqgLuLtjv1QGG6vqGzbj1TKkP2ff)csyykfogjYYuk6zus10OKsxJe02GG03ukjJtOQCoLsQ1bbX8uk19irTpHk)tOOiDqPsSqHQ8qsGjkuuDrsOAJkLGpcjI0ifkkQtkuKvkvQxkuuyMusXnvkHStHs9tLsOgQsj6OcffXsfkk9uaMQqHRkuvTviruFfsegRujzVc5VIAWehMQftspwWKb6YiBwkFgIgTs1Pvz1qIiEneA2K62I0UL8BqdNsDCsOSCfphQPRQRRKTdOVtjgpKKZlvSEHsMVi2pQJukkgraa9NII9MBSPskP0Mw3SPskm(u4Mra(o2ueaBpGOJKIauEkfbiEU2RafbW27OHoyumIaGHRjqra2)3gJqqbkuDTxbQRXxAWG8(9LQ5GOiEU2Ra11aUufGIuqZ(NQJzA70KYQU2RazEu9rauxN(JPksncaO)uuS3CJnvsjL206MnvsHXN1Uvra81VdNiaaUufeby)abPksncaiHdraINR9kqSeZN1bYDhBiqkvLgw206OMLn3ytL4U5UvWUxijmcH7URzPlGGeilaGAFyjEKNA4U7AwuWUxijqwEFqsF(ASeCmHz5HSe6e0u(9bj9yd3DxZsmlLcbsGSSQIceg7thwa6Z5QAcZsVZqguZI9qaZ43h8AqsS01XXI9qan43h8Aqs9nC3DnlDbi8azXEOGJ)RqYckX4)olxJL7veMLFNyXYalKSO4b9zJjd3DxZYwKJiXIcGfqiIel)oXca7BUhZIZI((xtSKchILMMq1PQjw6Dnw6axSS7GLIEw2VNL7zbFPl97fbxyDhwSC)olXBlUlXGfeWIcinH)Z1S0f9HSsP6rnl3RiqwWiE29nC3DnlBroIelPq8ZIIAhY9ppuQFfwrSGdu5ZbXS4226oS8qwuHymlTd5(Jzbw6ogU7UMLymK)SedykXcSXs80(olXt77SepTVZIJzXzbBtHZ1S8ZvisVH7URzzl2MkAyP3zidQzbLy8Fh1SGsm(VJAwa8(0UH6ZsQdsSKchILHWN(O6z5HSq(OpAyjatv9VRXVpVjcG(WpokgraG2urtumIITsrXicavUQMaJIxeap8hSIayz8FpcaiHdZz)hSIaSLdfC8ZYMSGsm(VZIxGS4Sa49bVgKelWIfaXGfl3VZsSpK7plBbNyXlqwIhSlXGf4WcG3N2nelWFNglhMIaeM7P58ia9yHc6Zgtg9Q8jxeQEwssyHc6ZgtMRYyO2hwssyHc6ZgtMRYQWFNLKewOG(SXKXRo5Iq1ZsFwqZI9qankzSm(VZcAwSIf7HaA20yz8Fp6JI9MrXicavUQMaJIxeap8hSIaGFFA3qracZ90CEeaRyzwf1GdsYO6AVcug2YUwN)9RqInu5QAcKLKewSILaeivE9M6qU)5MtSKKWIvSGTjTo)(GKESb)(0CTMfLzrjwssyXkwExt1Bk)xdHZQU2RazOYv1eiljjS0JfkOpBmzWqTp5Iq1ZsscluqF2yYCvwVkFyjjHfkOpBmzUkRc)DwssyHc6ZgtgV6Klcvpl9JaOVIYbWiakm6JIT1JIreaQCvnbgfViaE4pyfba)(GxdskcqyUNMZJamRIAWbjzuDTxbkdBzxRZ)(viXgQCvnbYcAwcqGu51BQd5(NBoXcAwW2KwNFFqsp2GFFAUwZIYSOuea9vuoagbqHrF0hbaKA(s)rXik2kffJiaE4pyfbad1(KvjpncavUQMaJIx0hf7nJIreaQCvnbgfViaH5EAopcWFPelBZspw2KfeMfp8hSmwg)3nbh)5)sjwqalE4pyzWVpTBitWXF(VuIL(raW)CHpk2kfbWd)bRiabxRZE4pyL1h(JaOp8NlpLIaaTPIMOpk2wpkgraOYv1eyu8IaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiayBsRZVpiPhBWVpnxRzjowuIf0S0JfRy5DnvVb)(OHdOHkxvtGSKKWY7AQEd(jT2Nm4CT3qLRQjqw6ZssclyBsRZVpiPhBWVpnxRzjow2mcaiHdZz)hSIaaGEmlDbQ4SalwSocyXY97W1Zc4CTNfVazXY97Sa49rdhqw8cKLnralWFNglhMIaa0NC5PueGdNDif9rX2AJIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkca2M0687ds6Xg87t7gIL4yrPiaGeomN9FWkcaa6XSe0KdKyXYovSa49PDdXsWlw2VNLnralVpiPhZIL9lSZYHzzinb0RNLgCy53jwu8G(SXelpKfvIf7HA0meilEbYIL9lSZs70AAy5HSeC8hbaOp5YtPiahoh0KdKI(OyRWOyebGkxvtGrXlca0ocaM(iaE4pyfbaOpNRQPiaaD9IIaypeWmYaOrjtkewTBiwssyXEiGzKbqJsg8QA3qSKKWI9qaZidGgLm43h8AqsSKKWI9qaZidGgLm43NMR1SKKWI9qaZidGgLmT10jdBzsVkILKewShcOzCGubx4CBOkwDyjjHf1vRzcE(QGzOu)kmlkZI6Q1mbpFvWaUg)pyXsscla95CvnzoC2HueaqchMZ(pyfbaLSpNRQjw(D)zjStbeXSCnw6axS4dXYvS4SGmaYYdzXbcpqw(DIf89l)pyXILDAiwCw(5kePNf6dSCywwycKLRyrLElevSeC8JJaa0NC5PueGRYidGrFuSrOrXicavUQMaJIxeap8hSIaOsdMgeVczeaqchMZ(pyfbi(XelXJgmniEfswSC)olkOlOiMQalWHfV90WIcGfqiIelxXIc6ckIPkebim3tZ5ra6XspwSILaeivE9M6qU)5MtSKKWIvSeGqni0szcWcierk)7ugBFZ9yZYML(SGMf1vRzcE(QGzOu)kmlXXIskKf0SyflbiqQ86naP637mSKKWsacKkVEdqQ(9odlOzrD1AMGNVkyw2SGMf1vRzghivWfo3gQIvhZYMf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MfLuILUMffYccZYSkQbhKKbFvBPZ7DWpnNBOYv1eiljjSOUAntWZxfmdL6xHzzBwusjwssyrjwqblyBsRZ7o(jw2MfLmkuHS0NL(SGMfG(CUQMmxLrgaJ(OyVvrXicavUQMaJIxeGWCpnNhbOhlQRwZe88vbZqP(vywIJfLuilOzPhlwXYSkQbhKKbFvBPZ7DWpnNBOYv1eiljjSOUAnZ4aPcUW52qvS6ygk1VcZY2SO0wXsxZYMSGWSOUAnJQgcb1l8Bw2SGMf1vRzghivWfo3gQIvhZYML(SKKWIkeJzbnlTd5(Nhk1VcZY2SSPczPplOzbOpNRQjZvzKbWiaGeomN9FWkcWwcFwSC)ololkOlOiMQal)U)SC4srplolB5sJ9Hf7bgyboSyzNkw(DIL2HC)z5WS4QW1ZYdzHkWiaE4pyfbWg(hSI(OyhFrXicavUQMaJIxeaODeam9ra8WFWkcaqFoxvtraa66ffbiqNMLES0JL2HC)ZdL6xHzPRzrjfYsxZsac1GqlLj45RcMHs9RWS0NfuWIsX3gS0NfLzjqNMLES0JL2HC)ZdL6xHzPRzrjfYsxZsac1GqlLjalGqeP8VtzS9n3JnGRX)dwS01SeGqni0szcWcierk)7ugBFZ9yZqP(vyw6ZckyrP4Bdw6ZcAwSILXpWmbKQ34GGydHQd)ywssyjaHAqOLYe88vbZqP(vywIJLREASHA)jWC7qU)5Hs9RWSKKWYSkQbhKKjqAc)NRZy7BUhBOYv1eilOzjaHAqOLYe88vbZqP(vywIJfRVbljjSeGqni0szcWcierk)7ugBFZ9yZqP(vywIJLREASHA)jWC7qU)5Hs9RWS01SO0gSKKWIvSeGaPYR3uhY9p3CkcaiHdZz)hSIaOaxhwA)jmlw2PFNgww4RqYIcGfqiIelf0clwoTMfxRHwyPdCXYdzb)NwZsWXpl)oXc2tjw8u4QEwGnwuaSacrKqGc6ckIPkWsWXpocaqFYLNsracWcierkds4ovi6JI9whfJiau5QAcmkEraG2raW0hbWd)bRiaa95CvnfbaORxueGES0oK7FEOu)kmlXXIskKLKewg)aZeqQEJdcInxXsCSOWnyPplOzPhl9yPhlKIToBBc0qP2DgY1z4awEfiwqZspwcqOgeAPmuQDNHCDgoGLxbYmuQFfMLTzrje6gSKKWsacKkVEdqQ(9odlOzjaHAqOLYqP2DgY1z4awEfiZqP(vyw2MfLqOBfliGLESOKsSGWSmRIAWbjzWx1w68Eh8tZ5gQCvnbYsFw6ZcAwSILaeQbHwkdLA3zixNHdy5vGmd5GDyPpljjSqk26STjqdgU0A6)RqMNLAhwqZspwSILaeivE9M6qU)5MtSKKWsac1GqlLbdxAn9)viZZsTt26wRcJVnuYmuQFfMLTzrjLSww6Zsscl9yjaHAqOLYOsdMgeVcPzihSdljjSyflJhiZpqTML(SGMLES0JfsXwNTnbAUchM17QAkRylV(vAgKaEbIf0S0JLaeQbHwkZv4WSExvtzfB51VsZGeWlqMHCWoSKKWIh(dwMRWHz9UQMYk2YRFLMbjGxGmGh2v1eil9zPpljjS0JfsXwNTnbAW7oi0cbMHJAg2YpCsP6zbnlbiudcTuMhoPu9ey(k8HC)ZwxHk06BQKzOu)kml9zjjHLES0JfG(CUQMmWkVWu(NRqKEwuMfLyjjHfG(CUQMmWkVWu(NRqKEwuMfRZsFwqZspw(5keP38kzgYb7KdqOgeAPyjjHLFUcr6nVsMaeQbHwkZqP(vywIJLREASHA)jWC7qU)5Hs9RWS01SO0gS0NLKewa6Z5QAYaR8ct5FUcr6zrzw2Kf0S0JLFUcr6n)MMHCWo5aeQbHwkwssy5NRqKEZVPjaHAqOLYmuQFfML4y5QNgBO2Fcm3oK7FEOu)kmlDnlkTbl9zjjHfG(CUQMmWkVWu(NRqKEwuMLnyPpl9zPpljjSeGaPYR3GyN58IL(SKKWIkeJzbnlTd5(Nhk1VcZY2SOUAntWZxfmGRX)dwraajCyo7)GveG4htGS8qwajT3HLFNyzHDKelWglkOlOiMQalw2PILf(kKSacxQAIfyXYctS4fil2dbKQNLf2rsSyzNkw8IfheKfcivplhMfxfUEwEilGhfbaOp5YtPiabWCawG3FWk6JITsBefJiau5QAcmkEraG2raW0hbWd)bRiaa95CvnfbaORxueaRybdxA1Ran)(CADgteI0yOYv1eiljjS0oK7FEOu)kmlXXYMBSbljjSOcXywqZs7qU)5Hs9RWSSnlBQqwqal9yXA3GLUMf1vRz(9506mMiePXGFpGilimlBYsFwssyrD1AMFFoToJjcrAm43diYsCSy94JLUMLESmRIAWbjzWx1w68Eh8tZ5gQCvnbYccZIczPFeaqchMZ(pyfbaLSpNRQjwwycKLhYciP9oS4vhw(5kePhZIxGSeaXSyzNkwS43FfswAWHfVyrXx27W5CwShyicaqFYLNsra(9506mMiePjBXVp6JITskffJiau5QAcmkEraajCyo7)GveG4htSO4P2DgY1SSfpGLxbILn3atbmlQudoelolkOlOiMQallmzIauEkfbGsT7mKRZWbS8kqracZ90CEeGaeQbHwktWZxfmdL6xHzzBw2CdwqZsac1GqlLjalGqeP8VtzS9n3JndL6xHzzBw2CdwqZspwa6Z5QAY87ZP1zmrist2IFpljjSOUAnZVpNwNXeHing87bezjowS(gSGaw6XYSkQbhKKbFvBPZ7DWpnNBOYv1eilimliuw6ZsFwqZcqFoxvtMRYidGSKKWIkeJzbnlTd5(Nhk1VcZY2Sy9TkcGh(dwraOu7od56mCalVcu0hfBL2mkgraOYv1eyu8Iaas4WC2)bRiaXpMybaCP10FfswIzxQDybHIPaMfvQbhIfNff0fuetvGLfMmrakpLIaGHlTM()kK5zP2jcqyUNMZJa0JLaeQbHwktWZxfmdL6xHzzBwqOSGMfRyjabsLxVbiv)ENHf0SyflbiqQ86n1HC)ZnNyjjHLaeivE9M6qU)5MtSGMLaeQbHwktawaHis5FNYy7BUhBgk1VcZY2SGqzbnl9ybOpNRQjtawaHiszqc3PcSKKWsac1GqlLj45RcMHs9RWSSnliuw6ZssclbiqQ86naP637mSGMLESyflZQOgCqsg8vTLoV3b)0CUHkxvtGSGMLaeQbHwktWZxfmdL6xHzzBwqOSKKWI6Q1mJdKk4cNBdvXQJzOu)kmlBZIswlliGLESOqwqywifBD22eO5k8pRWdhCg8aEfLvjTML(SGMf1vRzghivWfo3gQIvhZYML(SKKWIkeJzbnlTd5(Nhk1VcZY2SSPczjjHfsXwNTnbAOu7od56mCalVcelOzjaHAqOLYqP2DgY1z4awEfiZqP(vywIJLn3GL(SGMfG(CUQMmxLrgazbnlwXcPyRZ2ManxHdZ6DvnLvSLx)kndsaVaXssclbiudcTuMRWHz9UQMYk2YRFLMbjGxGmdL6xHzjow2CdwssyrfIXSGML2HC)ZdL6xHzzBw2CJiaE4pyfbadxAn9)viZZsTt0hfBLSEumIaqLRQjWO4fbaAhbatFeap8hSIaa0NZv1ueaGUErrauxTMj45RcMHs9RWSehlkPqwqZspwSILzvudoijd(Q2sN37GFAo3qLRQjqwssyrD1AMXbsfCHZTHQy1XmuQFfMLTvMfL20SjliGLESyDwqywuxTMrvdHG6f(nlBw6ZccyPhlXhlDnlkKfeMf1vRzu1qiOEHFZYML(SGWSqk26STjqZv4FwHho4m4b8kkRsAnlOzrD1AMXbsfCHZTHQy1XSSzPpljjSOcXywqZs7qU)5Hs9RWSSnlBQqwssyHuS1zBtGgk1UZqUodhWYRaXcAwcqOgeAPmuQDNHCDgoGLxbYmuQFfocaiHdZz)hSIa0fTfVdMLfMyjMIzsmNfl3VZIc6ckIPkebaOp5YtPiaNIbMdWc8(dwrFuSvYAJIreaQCvnbgfViaE4pyfb4kCywVRQPSIT86xPzqc4fOiaH5EAopcaqFoxvtMtXaZbybE)blwqZcqFoxvtMRYidGrakpLIaCfomR3v1uwXwE9R0mib8cu0hfBLuyumIaqLRQjWO4fbaKWH5S)dwraIFmXYCi3FwuPgCiwcG4iaLNsraW7oi0cbMHJAg2YpCsP6JaeM7P58ia9yjaHAqOLYe88vbZqoyhwqZIvSeGaPYR3uhY9p3CIf0Sa0NZv1K53NtRZyIqKMSf)EwqZspwcqOgeAPmQ0GPbXRqAgYb7WssclwXY4bY8duRzPpljjSeGaPYR3uhY9p3CIf0SeGqni0szcWcierk)7ugBFZ9yZqoyhwqZspwa6Z5QAYeGfqiIugKWDQaljjSeGqni0szcE(QGzihSdl9zPplOzbe(g8QA3qM)ciEfswqZspwaHVb)Kw7tUP9Hm)fq8kKSKKWIvS8UMQ3GFsR9j30(qgQCvnbYssclyBsRZVpiPhBWVpTBiwIJfRZsFwqZci8nPqy1UHm)fq8kKSGMLESa0NZv1K5WzhsSKKWYSkQbhKKr11EfOmSLDTo)7xHeBOYv1eiljjS44FCD2gAHgwItzw26nyjjHfG(CUQMmbybeIiLbjCNkWssclQRwZOQHqq9c)MLnl9zbnlwXcPyRZ2ManxHdZ6DvnLvSLx)kndsaVaXssclKIToBBc0CfomR3v1uwXwE9R0mib8celOzjaHAqOLYCfomR3v1uwXwE9R0mib8cKzOu)kmlXXI13Gf0SyflQRwZe88vbZYMLKewuHymlOzPDi3)8qP(vyw2MfRDJiaE4pyfbaV7GqleygoQzyl)WjLQp6JITsi0OyebGkxvtGrXlcaiHdZz)hSIaeJ9dZYHzXzz8FNgwiTRch)jwS4Dy5HSK6isS4AnlWILfMyb)(ZYpxHi9ywEilQel6Riqww2Sy5(Dwuqxqrmvbw8cKffalGqejw8cKLfMy53jw2SazbRHplWILailxJfv4VZYpxHi9yw8HybwSSWel43Fw(5kePhhbim3tZ5ra6XcqFoxvtgyLxyk)ZvisplwPmlkXcAwSILFUcr6n)MMHCWo5aeQbHwkwssyPhla95CvnzGvEHP8pxHi9SOmlkXsscla95CvnzGvEHP8pxHi9SOmlwNL(SGMLESOUAntWZxfmlBwqZspwSILaeivE9gGu97DgwssyrD1AMXbsfCHZTHQy1XmuQFfMfeWspwuilimlZQOgCqsg8vTLoV3b)0CUHkxvtGS0NLTvMLFUcr6nVsg1vRLbxJ)hSybnlQRwZmoqQGlCUnufRoMLnljjSOUAnZ4aPcUW52qvS6KXx1w68Eh8tZ5MLnl9zjjHLaeQbHwktWZxfmdL6xHzbbSSjlXXYpxHi9Mxjtac1GqlLbCn(FWIf0SyflQRwZe88vbZYMf0S0JfRyjabsLxVPoK7FU5eljjSyfla95CvnzcWcierkds4ovGL(SGMfRyjabsLxVbXoZ5fljjSeGaPYR3uhY9p3CIf0Sa0NZv1KjalGqePmiH7ubwqZsac1GqlLjalGqeP8VtzS9n3JnlBwqZIvSeGqni0szcE(QGzzZcAw6XspwuxTMHc6Zgtz9Q8XmuQFfML4yrPnyjjHf1vRzOG(SXugd1(ygk1VcZsCSO0gS0Nf0SyflZQOgCqsgvx7vGYWw2168VFfsSHkxvtGSKKWspwuxTMr11EfOmSLDTo)7xHeNl)xdzWVhqKfLzrHSKKWI6Q1mQU2RaLHTSR15F)kK4SpbVid(9aISOmlXhl9zPpljjSOUAndIxboeyMsTHwOjLQptfniVyrMLnl9zjjHfvigZcAwAhY9ppuQFfMLTzzZnyjjHfG(CUQMmWkVWu(NRqKEwuMLnyPplOzbOpNRQjZvzKbWiayn8Xra(5kePxPiaE4pyfb4NRqKELI(OyR0wffJiau5QAcmkEra8WFWkcWpxHi9Bgbim3tZ5ra6XcqFoxvtgyLxyk)ZvisplwPmlBYcAwSILFUcr6nVsMHCWo5aeQbHwkwssybOpNRQjdSYlmL)5kePNfLzztwqZspwuxTMj45RcMLnlOzPhlwXsacKkVEdqQ(9odljjSOUAnZ4aPcUW52qvS6ygk1VcZccyPhlkKfeMLzvudoijd(Q2sN37GFAo3qLRQjqw6ZY2kZYpxHi9MFtJ6Q1YGRX)dwSGMf1vRzghivWfo3gQIvhZYMLKewuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYML(SKKWsac1GqlLj45RcMHs9RWSGaw2KL4y5NRqKEZVPjaHAqOLYaUg)pyXcAwSIf1vRzcE(QGzzZcAw6XIvSeGaPYR3uhY9p3CILKewSIfG(CUQMmbybeIiLbjCNkWsFwqZIvSeGaPYR3GyN58If0S0JfRyrD1AMGNVkyw2SKKWIvSeGaPYR3aKQFVZWsFwssyjabsLxVPoK7FU5elOzbOpNRQjtawaHiszqc3PcSGMLaeQbHwktawaHis5FNYy7BUhBw2SGMfRyjaHAqOLYe88vbZYMf0S0JLESOUAndf0NnMY6v5JzOu)kmlXXIsBWssclQRwZqb9zJPmgQ9XmuQFfML4yrPnyPplOzXkwMvrn4GKmQU2RaLHTSR15F)kKydvUQMazjjHLESOUAnJQR9kqzyl7AD(3Vcjox(VgYGFpGilkZIczjjHf1vRzuDTxbkdBzxRZ)(viXzFcErg87bezrzwIpw6ZsFw6ZssclQRwZG4vGdbMPuBOfAsP6ZurdYlwKzzZssclQqmMf0S0oK7FEOu)kmlBZYMBWsscla95CvnzGvEHP8pxHi9SOmlBWsFwqZcqFoxvtMRYidGraWA4JJa8Zvis)MrFuSvk(IIreaQCvnbgfViaGeomN9FWkcq8JjmlUwZc83PHfyXYctSCpLIzbwSeaJa4H)GveGfMY3tP4Opk2kT1rXicavUQMaJIxeaqchMZ(pyfbiMtHdKyXd)blw0h(zr1XeilWIf89l)pyHcnH8Wra8WFWkcWSQSh(dwz9H)ia4FUWhfBLIaeM7P58iaa95CvnzoC2Huea9H)C5PueahsrFuS3CJOyebGkxvtGrXlcqyUNMZJamRIAWbjzuDTxbkdBzxRZ)(viXgsXwNTnbgba)Zf(OyRueap8hSIamRk7H)GvwF4pcG(WFU8ukcGk0)Opk2BQuumIaqLRQjWO4fbWd)bRiaZQYE4pyL1h(JaOp8NlpLIaG)Op6JaOc9pkgrXwPOyebGkxvtGrXlcGh(dwraghivWfo3gQIvNiaGeomN9FWkcWwyOkwDyXY97SOGUGIyQcracZ90CEea1vRzcE(QGzOu)kmlXXIskm6JI9MrXicavUQMaJIxeap8hSIa4GU9FaPm2IpPracDcAk)(GKECuSvkcqyUNMZJaOUAnJQR9kqzyl7AD(3Vcjox(VgYGFpGilBZs8XcAwuxTMr11EfOmSLDTo)7xHeN9j4fzWVhqKLTzj(ybnl9yXkwaHVXbD7)aszSfFsZGEQJKm)fq8kKSGMfRyXd)blJd62)bKYyl(KMb9uhjzUk30hY9Nf0S0JfRybe(gh0T)diLXw8jnVtU28xaXRqYssclGW34GU9FaPm2IpP5DY1MHs9RWSehlwNL(SKKWci8noOB)hqkJT4tAg0tDKKb)Earw2MfRZcAwaHVXbD7)aszSfFsZGEQJKmdL6xHzzBwuilOzbe(gh0T)diLXw8jnd6PosY8xaXRqYs)iaGeomN9FWkcq8Jjw6cOB)hqIfaw8jLfl7uXI)SOjmMLF3lwSwwIhSlXGf87beXS4filpKLHAdH3zXzzBL3Kf87bezXXSO9NyXXSydX4tvtSahw(lLy5EwWqwUNfFMdiHzbLKf(zXBpnS4SyDeWc(9aISqOY(gch9rX26rXicavUQMaJIxeap8hSIaeGfqiIu(3Pm2(M7XraajCyo7)GveG4htSOaybeIiXIL73zrbDbfXufyXYovSydX4tvtS4filWFNglhMyXY97S4SepyxIblQRwJfl7uXciH7uHRqgbim3tZ5raSIfWzDGMcMdGywqZspw6XcqFoxvtMaSacrKYGeUtfybnlwXsac1GqlLj45RcMHCWoSKKWI6Q1mbpFvWSSzPplOzPhlQRwZO6AVcug2YUwN)9RqIZL)RHm43diYIYSeFSKKWI6Q1mQU2RaLHTSR15F)kK4SpbVid(9aISOmlXhl9zjjHfvigZcAwAhY9ppuQFfMLTzrPnybnlbiudcTuMGNVkygk1VcZsCSSvS0p6JIT1gfJiau5QAcmkEra8WFWkcqBnDYWwM0RIIaas4WC2)bRiaBbOIZIJz53jwA3GFwqgaz5kw(DIfNL4b7smyXYvGqlSahwSC)ol)oXsmJoZ5flQRwJf4WIL73zXzj(qaMcS0fq3(pGelaS4tklEbYIf)EwAWHff0fuetvGLRXY9SybwplQellBwCK(vSOsn4qS87elbqwomlTRo8obgbim3tZ5ra6Xspw6XI6Q1mQU2RaLHTSR15F)kK4C5)Aid(9aISehliuwssyrD1Agvx7vGYWw2168VFfsC2NGxKb)EarwIJfekl9zbnl9yXkwcqGu51Bas1V3zyjjHfRyrD1AMXbsfCHZTHQy1XSSzPpl9zbnl9ybCwhOPG5aiMLKewcqOgeAPmbpFvWmuQFfML4yrHBWsscl9yjabsLxVPoK7FU5elOzjaHAqOLYeGfqiIu(3Pm2(M7XMHs9RWSehlkCdw6ZsFw6Zsscl9ybe(gh0T)diLXw8jnd6PosYmuQFfML4yj(ybnlbiudcTuMGNVkygk1VcZsCSO0gSGMLaeivE9MIcdudhqw6Zssclx90yd1(tG52HC)ZdL6xHzzBwIpwqZIvSeGqni0szcE(QGzihSdljjSeGaPYR3GyN58If0SOUAndIxboeyMsTHwOjLQ3SSzjjHLaeivE9gGu97DgwqZI6Q1mJdKk4cNBdvXQJzOu)kmlBZYwZcAwuxTMzCGubx4CBOkwDml7Opk2kmkgraOYv1eyu8Ia4H)GveGGxbsNvxTweGWCpnNhbOhlQRwZO6AVcug2YUwN)9RqIZL)RHmdL6xHzjow2kJczjjHf1vRzuDTxbkdBzxRZ)(viXzFcErMHs9RWSehlBLrHS0Nf0S0JLaeQbHwktWZxfmdL6xHzjow2kwssyPhlbiudcTugk1gAHMSkSandL6xHzjow2kwqZIvSOUAndIxboeyMsTHwOjLQptfniVyrMLnlOzjabsLxVbXoZ5fl9zPplOzXX)46Sn0cnSeNYSy9nIaOUATC5Puea87JgoGraajCyo7)Gveaf4vG0Sa49rdhqwSC)ololfzHL4b7smyrD1AS4filkOlOiMQalhUu0ZIRcxplpKfvILfMaJ(OyJqJIreaQCvnbgfViaE4pyfba)(GxdskcaiHdZz)hSIaeZxP2Sa49bVgKeMfvQbhIffalGqePiaH5EAopcqpwcqOgeAPmbybeIiL)DkJTV5ESzOu)kmlBZIczbnlwXc4SoqtbZbqmlOzPhla95CvnzcWcierkds4ovGLKewcqOgeAPmbpFvWmuQFfMLTzrHS0Nf0Sa0NZv1KjaMdWc8(dwS0Nf0SyflGW30wtNmSLj9QiZFbeVcjlOzjabsLxVPoK7FU5elOzXkwaN1bAkyoaIzbnluqF2yYCv2RoSGMfh)JRZ2ql0WsCSyTBe9rXERIIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkcqpwuxTMzCGubx4CBOkwDmdL6xHzjowuiljjSyflQRwZmoqQGlCUnufRoMLnl9zbnl9yrD1AgeVcCiWmLAdTqtkvFMkAqEXImdL6xHzzBwqganPoQyPplOzPhlQRwZqb9zJPmgQ9XmuQFfML4ybza0K6OILKewuxTMHc6Zgtz9Q8XmuQFfML4ybza0K6OIL(raajCyo7)GveGyoSu0Zci8zbCnxHKLFNyHkqwGnwIzDGubxyw2cdvXQdQzbCnxHKfeVcCiqwOuBOfAsP6zboSCfl)oXI2XplidGSaBS4flkEqF2ykcaqFYLNsraaHFEifBDdLs1JJ(OyhFrXicavUQMaJIxeap8hSIaGxv7gkcqyUNMZJamuBi8URQjwqZY7ds6n)Ls5hMbpIL4yrjeklOzXTZHDkGilOzbOpNRQjdi8ZdPyRBOuQECeGqNGMYVpiPhhfBLI(OyV1rXicavUQMaJIxeap8hSIaKcHv7gkcqyUNMZJamuBi8URQjwqZY7ds6n)Ls5hMbpIL4yrjRBuilOzXTZHDkGilOzbOpNRQjdi8ZdPyRBOuQECeGqNGMYVpiPhhfBLI(OyR0grXicavUQMaJIxeap8hSIaGFsR9j30(qracZ90CEeGHAdH3DvnXcAwEFqsV5Vuk)Wm4rSehlkHqzbbSmuQFfMf0S425WofqKf0Sa0NZv1Kbe(5HuS1nukvpocqOtqt53hK0JJITsrFuSvsPOyebGkxvtGrXlcGh(dwraAWjqzylx(VgkcaiHdZz)hSIaSfGXMfyXsaKfl3Vdxplb32(kKracZ90CEea3oh2PaIrFuSvAZOyebGkxvtGrXlcGh(dwraOuBOfAYQWcmcaiHdZz)hSIaO4P2ql0Ws8Gfilw2PIfxfUEwEilu90WIZsrwyjEWUedwSCfi0clEbYc2bsS0GdlkOlOiMQqeGWCpnNhbOhluqF2yYOxLp5Iq1ZsscluqF2yYGHAFYfHQNLKewOG(SXKXRo5Iq1ZssclQRwZO6AVcug2YUwN)9RqIZL)RHmdL6xHzjow2kJczjjHf1vRzuDTxbkdBzxRZ)(viXzFcErMHs9RWSehlBLrHSKKWIJ)X1zBOfAyjow26nybnlbiudcTuMGNVkygYb7WcAwSIfWzDGMcMdGyw6ZcAw6Xsac1GqlLj45RcMHs9RWSehlwFdwssyjaHAqOLYe88vbZqoyhw6ZssclQqmMf0SC1tJnu7pbMBhY9ppuQFfMLTzrPnI(OyRK1JIreaQCvnbgfViaE4pyfbOTMozylt6vrraajCyo7)GveGTauXzzoK7plQudoell8vizrbDjcqyUNMZJaeGqni0szcE(QGzihSdlOzbOpNRQjtamhGf49hSybnl9yXX)46Sn0cnSehlB9gSGMfRyjabsLxVPoK7FU5eljjSeGaPYR3uhY9p3CIf0S44FCD2gAHgw2MfRDdw6ZcAwSILaeivE9gGu97DgwqZspwSILaeivE9M6qU)5MtSKKWsac1GqlLjalGqeP8VtzS9n3Jnd5GDyPplOzXkwaN1bAkyoaIJ(OyRK1gfJiau5QAcmkEraG2raW0hbWd)bRiaa95CvnfbaORxueaRybCwhOPG5aiMf0Sa0NZv1KjaMdWc8(dwSGMLES0Jfh)JRZ2ql0WsCSS1BWcAw6XI6Q1miEf4qGzk1gAHMuQ(mv0G8Ifzw2SKKWIvSeGaPYR3GyN58IL(SKKWI6Q1mQAieuVWVzzZcAwuxTMrvdHG6f(ndL6xHzzBwuxTMj45RcgW14)blw6ZssclQqmMf0SC1tJnu7pbMBhY9ppuQFfMLTzrD1AMGNVkyaxJ)hSyjjHLaeivE9M6qU)5MtS0Nf0S0JfRyjabsLxVPoK7FU5eljjS0Jfh)JRZ2ql0WY2SyTBWssclGW30wtNmSLj9QiZFbeVcjl9zbnl9ybOpNRQjtawaHiszqc3PcSKKWsac1GqlLjalGqeP8VtzS9n3Jnd5GDyPpl9Jaas4WC2)bRiakOlOiMQalw2PIf)zzR3abS0f8wYsp4OHwOHLF3lwS2nyPl4TKfl3VZIcGfqiIuFwSC)oC9SOH4RqYYFPelxXs80qiOEHFw8cKf9vellBwSC)olkawaHisSCnwUNfloMfqc3PceyeaG(KlpLIaeaZbybE)bRSk0)Opk2kPWOyebGkxvtGrXlcqyUNMZJaa0NZv1KjaMdWc8(dwzvO)ra8WFWkcqG0e(pxND9HSsP6J(OyRecnkgraOYv1eyu8IaeM7P58iaa95CvnzcG5aSaV)Gvwf6Feap8hSIaCvWNY)dwrFuSvARIIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkcaf0NnMmxL1RYhwqywIpwqblE4pyzWVpTBidHkkSEk)xkXccyXkwOG(SXK5QSEv(WccZspwqOSGawExt1BWWLodB5FNYn4q43qLRQjqwqywSol9zbfS4H)GLXY4)UHqffwpL)lLybbSSHztwqblyBsRZ7o(PiaGeomN9FWkcGIJ)l1FcZYo0clPRWolDbVLS4dXcs)kcKfBAybtbybgbaOp5YtPiao2ElPbafI(OyRu8ffJiau5QAcmkEra8WFWkca(9bVgKueaqchMZ(pyfbiMVsTzbW7dEnijmlw2PILFNyPDi3FwomlUkC9S8qwOce1S0gQIvhwomlUkC9S8qwOce1S0bUyXhIf)zzR3abS0f8wYYvS4flkEqF2yc1SOGUGIyQcSOD8JzXl4VtdlXhcWuaZcCyPdCXIf4sdYceinb3MLu4qS87EXcNO0gS0f8wYILDQyPdCXIf4sdwk6zbW7dEnijwkOLiaH5EAopcqpwuHymlOz5QNgBO2Fcm3oK7FEOu)kmlBZI1Ysscl9yrD1AMXbsfCHZTHQy1XmuQFfMLTzbza0K6OIfeMLaDAw6XIJ)X1zBOfAybfSy9nyPplOzrD1AMXbsfCHZTHQy1XSSzPpl9zjjHLES44FCD2gAHgwqala95CvnzCS9wsdakWccZI6Q1muqF2ykJHAFmdL6xHzbbSacFtBnDYWwM0RIm)fqeNhk1VIfeMLnnkKL4yrjL2GLKewC8pUoBdTqdliGfG(CUQMmo2ElPbafybHzrD1AgkOpBmL1RYhZqP(vywqalGW30wtNmSLj9QiZFbeX5Hs9RybHzztJczjowusPnyPplOzHc6ZgtMRYE1Hf0S0JfRyrD1AMGNVkyw2SKKWIvS8UMQ3GFF0Wb0qLRQjqw6ZcAw6XspwSILaeQbHwktWZxfmlBwssyjabsLxVbXoZ5flOzXkwcqOgeAPmuQn0cnzvybAw2S0NLKewcqGu51BQd5(NBoXsFwqZspwSILaeivE9gGu97DgwssyXkwuxTMj45RcMLnljjS44FCD2gAHgwIJLTEdw6Zsscl9y5DnvVb)(OHdOHkxvtGSGMf1vRzcE(QGzzZcAw6XI6Q1m43hnCan43diYY2SyDwssyXX)46Sn0cnSehlB9gS0NL(SKKWI6Q1mbpFvWSSzbnlwXI6Q1mJdKk4cNBdvXQJzzZcAwSIL31u9g87JgoGgQCvnbg9rXwPTokgraOYv1eyu8Ia4H)GveGISKtHWkcaiHdZz)hSIae)yILTiiSWSCflwZQ8HffpOpBmXIxGSGDGelXm76gc2clTMLTiiSyPbhwuqxqrmvHiaH5EAopcqpwuxTMHc6Zgtz9Q8XmuQFfML4yHqffwpL)lLyjjHLESe29bjHzrzw2Kf0Smuy3hKu(VuILTzrHS0NLKewc7(GKWSOmlwNL(SGMf3oh2PaIrFuS3CJOyebGkxvtGrXlcqyUNMZJa0Jf1vRzOG(SXuwVkFmdL6xHzjowiurH1t5)sjwqZspwcqOgeAPmbpFvWmuQFfML4yrHBWssclbiudcTuMaSacrKY)oLX23Cp2muQFfML4yrHBWsFwssyPhlHDFqsywuMLnzbnldf29bjL)lLyzBwuil9zjjHLWUpijmlkZI1zPplOzXTZHDkGyeap8hSIaS76wofcROpk2BQuumIaqLRQjWO4fbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSehleQOW6P8FPelOzPhlbiudcTuMGNVkygk1VcZsCSOWnyjjHLaeQbHwktawaHis5FNYy7BUhBgk1VcZsCSOWnyPpljjS0JLWUpijmlkZYMSGMLHc7(GKY)LsSSnlkKL(SKKWsy3hKeMfLzX6S0Nf0S425WofqmcGh(dwraAlToNcHv0hf7n3mkgraOYv1eyu8Iaas4WC2)bRiaOeqfNfyXsamcGh(dwraS4ZCWjdBzsVkk6JI9MwpkgraOYv1eyu8Ia4H)Gvea87t7gkcaiHdZz)hSIae)yIfaVpTBiwEil2dmWcaO2hwu8G(SXelWHfl7uXYvSalDhwSMv5dlkEqF2yIfVazzHjwqjGkol2dmGz5ASCflwZQ8HffpOpBmfbim3tZ5raOG(SXK5QSEv(WsscluqF2yYGHAFYfHQNLKewOG(SXKXRo5Iq1ZssclQRwZyXN5Gtg2YKEvKzzZcAwuxTMHc6Zgtz9Q8XSSzjjHLESOUAntWZxfmdL6xHzzBw8WFWYyz8F3qOIcRNY)LsSGMf1vRzcE(QGzzZs)Opk2BATrXicGh(dwraSm(VhbGkxvtGrXl6JI9MkmkgraOYv1eyu8Ia4H)GveGzvzp8hSY6d)ra0h(ZLNsraAUw)7Zk6J(iaoKIIruSvkkgraOYv1eyu8IaaTJaGPpcGh(dwraa6Z5QAkcaqxVOia9yrD1AM)sjlWPYGd5PQxbsJzOu)kmlBZcYaOj1rfliGLnmkXssclQRwZ8xkzbovgCipv9kqAmdL6xHzzBw8WFWYGFFA3qgcvuy9u(VuIfeWYggLybnl9yHc6ZgtMRY6v5dljjSqb9zJjdgQ9jxeQEwssyHc6ZgtgV6Klcvpl9zPplOzrD1AM)sjlWPYGd5PQxbsJzzZcAwMvrn4GKm)LswGtLbhYtvVcKgdvUQMaJaas4WC2)bRiakW1HL2FcZILD63PHLFNyjMpKNg8pStdlQRwJflNwZsZ1AwGTglwUF)kw(DILIq1ZsWXFeaG(KlpLIaaoKNMTCADU5ADg2ArFuS3mkgraOYv1eyu8IaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiawXcf0NnMmxLXqTpSGMLESGTjTo)(GKESb)(0UHyjowuilOz5DnvVbdx6mSL)Dk3GdHFdvUQMazjjHfSnP153hK0Jn43N2nelXXYwXs)iaGeomN9FWkcGcCDyP9NWSyzN(DAybW7dEnijwomlwGZVZsWX)vizbcKgwa8(0UHy5kwSMv5dlkEqF2ykcaqFYLNsraoKfCOm(9bVgKu0hfBRhfJiau5QAcmkEra8WFWkcqawaHis5FNYy7BUhhbaKWH5S)dwraIFmXIcGfqiIelw2PIf)zrtyml)UxSOWnyPl4TKfVazrFfXYYMfl3VZIc6ckIPkebim3tZ5raSIfWzDGMcMdGywqZspw6XcqFoxvtMaSacrKYGeUtfybnlwXsac1GqlLj45RcMHCWoSKKWI6Q1mbpFvWSSzPplOzPhlQRwZqb9zJPSEv(ygk1VcZsCSGqzjjHf1vRzOG(SXugd1(ygk1VcZsCSGqzPplOzPhlwXYSkQbhKKr11EfOmSLDTo)7xHeBOYv1eiljjSOUAnJQR9kqzyl7AD(3Vcjox(VgYGFpGilXXI1zjjHf1vRzuDTxbkdBzxRZ)(viXzFcErg87bezjowSol9zjjHfvigZcAwAhY9ppuQFfMLTzrPnybnlwXsac1GqlLj45RcMHCWoS0p6JIT1gfJiau5QAcmkEra8WFWkcaEvTBOiaHobnLFFqspok2kfbim3tZ5ra6XYqTHW7UQMyjjHf1vRzOG(SXugd1(ygk1VcZY2SyDwqZcf0NnMmxLXqTpSGMLHs9RWSSnlkzTSGML31u9gmCPZWw(3PCdoe(nu5QAcKL(SGML3hK0B(lLYpmdEelXXIswllDnlyBsRZVpiPhZccyzOu)kmlOzPhluqF2yYCv2RoSKKWYqP(vyw2MfKbqtQJkw6hbaKWH5S)dwraIFmXcGv1UHy5kwS9cKsValWIfV687xHKLF3Fw0hqcZIswlMcyw8cKfnHXSy5(DwsHdXY7ds6XS4fil(ZYVtSqfilWglolaGAFyrXd6ZgtS4plkzTSGPaMf4WIMWywgk1V6kKS4ywEilf8zz3bEfswEild1gcVZc4AUcjlwZQ8HffpOpBmf9rXwHrXicavUQMaJIxeap8hSIaGxv7gkcaiHdZz)hSIae)yIfaRQDdXYdzz3bsS4SGudvDnlpKLfMyjMIzsmpcqyUNMZJaa0NZv1K5umWCawG3FWIf0SeGqni0szUchM17QAkRylV(vAgKaEbYmKd2Hf0Sqk26STjqZv4WSExvtzfB51VsZGeWlqrFuSrOrXicavUQMaJIxeGWCpnNhbWkwExt1BWpP1(KbNR9gQCvnbYcAw6XI6Q1m43NMR1MHAdH3DvnXcAw6Xc2M0687ds6Xg87tZ1Aw2MfRZssclwXYSkQbhKK5VuYcCQm4qEQ6vG0yOYv1eil9zjjHL31u9gmCPZWw(3PCdoe(nu5QAcKf0SOUAndf0NnMYyO2hZqP(vyw2MfRZcAwOG(SXK5QmgQ9Hf0SOUAnd(9P5ATzOu)kmlBZYwXcAwW2KwNFFqsp2GFFAUwZsCkZI1YsFwqZspwSILzvudoijJUtWhhNBAI(RqMrQVuBmzOYv1eiljjS8xkXckLfRvHSehlQRwZGFFAUwBgk1VcZccyztw6ZcAwEFqsV5Vuk)Wm4rSehlkmcGh(dwraWVpnxRJ(OyVvrXicavUQMaJIxeap8hSIaGFFAUwhbaKWH5S)dwraqjUFNfapP1(WsmFU2ZYctSalwcGSyzNkwgQneE3v1elQRNf8FAnlw87zPbhwSMobFCml2dmWIxGSaclf9SSWelQudoelkiMJnSa4pTMLfMyrLAWHyrbWcierIf8vbILF3FwSCAnl2dmWIxWFNgwa8(0CTocqyUNMZJa8UMQ3GFsR9jdox7nu5QAcKf0SOUAnd(9P5ATzO2q4DxvtSGMLESyflZQOgCqsgDNGpoo30e9xHmJuFP2yYqLRQjqwssy5VuIfuklwRczjowSww6ZcAwEFqsV5Vuk)Wm4rSehlwp6JID8ffJiau5QAcmkEra8WFWkca(9P5ADeaqchMZ(pyfbaL4(DwI5d5PQxbsdllmXcG3NMR1S8qwqKiBww2S87elQRwJf1oS4AmKLf(kKSa49P5AnlWIffYcMcWceZcCyrtymldL6xDfYiaH5EAopcWSkQbhKK5VuYcCQm4qEQ6vG0yOYv1eilOzbBtAD(9bj9yd(9P5AnlXPmlwNf0S0JfRyrD1AM)sjlWPYGd5PQxbsJzzZcAwuxTMb)(0CT2muBi8URQjwssyPhla95CvnzahYtZwoTo3CTodBnwqZspwuxTMb)(0CT2muQFfMLTzX6SKKWc2M0687ds6Xg87tZ1AwIJLnzbnlVRP6n4N0AFYGZ1EdvUQMazbnlQRwZGFFAUwBgk1VcZY2SOqw6ZsFw6h9rXERJIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkcGJ)X1zBOfAyjowIVnyPRzPhlkTblimlQRwZ8xkzbovgCipv9kqAm43diYsFw6Aw6XI6Q1m43NMR1MHs9RWSGWSyDwqblyBsRZ7o(jwqywSIL31u9g8tATpzW5AVHkxvtGS0NLUMLESeGqni0szWVpnxRndL6xHzbHzX6SGcwW2KwN3D8tSGWS8UMQ3GFsR9jdox7nu5QAcKL(S01S0Jfq4BARPtg2YKEvKzOu)kmlimlkKL(SGMLESOUAnd(9P5ATzzZssclbiudcTug87tZ1AZqP(vyw6hbaKWH5S)dwrauGRdlT)eMfl70VtdlolaEFWRbjXYctSy50Awc(ctSa49P5AnlpKLMR1SaBnuZIxGSSWelaEFWRbjXYdzbrISzjMpKNQEfinSGFpGill7iaa9jxEkfba)(0CToBbwFU5ADg2ArFuSvAJOyebGkxvtGrXlcGh(dwraWVp41GKIaas4WC2)bRiaXpMybW7dEnijwSC)olX8H8u1RaPHLhYcIezZYYMLFNyrD1ASy5(D46zrdXxHKfaVpnxRzzz)xkXIxGSSWelaEFWRbjXcSyXAralXd2LyWc(9aIyww1FAwSwwEFqspocqyUNMZJaa0NZv1KbCipnB506CZ16mS1ybnla95CvnzWVpnxRZwG1NBUwNHTglOzXkwa6Z5QAYCil4qz87dEnijwssyPhlQRwZO6AVcug2YUwN)9RqIZL)RHm43diYsCSyDwssyrD1Agvx7vGYWw2168VFfsC2NGxKb)EarwIJfRZsFwqZc2M0687ds6Xg87tZ1Aw2MfRLf0Sa0NZv1Kb)(0CToBbwFU5ADg2ArFuSvsPOyebGkxvtGrXlcGh(dwraCq3(pGugBXN0iaHobnLFFqspok2kfbim3tZ5raSIL)ciEfswqZIvS4H)GLXbD7)aszSfFsZGEQJKmxLB6d5(ZssclGW34GU9FaPm2IpPzqp1rsg87bezzBwSolOzbe(gh0T)diLXw8jnd6PosYmuQFfMLTzX6raajCyo7)GveG4htSGT4tklyil)U)S0bUybj9SK6OILL9FPelQDyzHVcjl3ZIJzr7pXIJzXgIXNQMybwSOjmMLF3lwSol43diIzboSGsYc)SyzNkwSocyb)EarmleQSVHI(OyR0MrXicavUQMaJIxeap8hSIaKcHv7gkcqOtqt53hK0JJITsracZ90CEeGHAdH3DvnXcAwEFqsV5Vuk)Wm4rSehl9yPhlkzTSGaw6Xc2M0687ds6Xg87t7gIfeMLnzbHzrD1AgkOpBmL1RYhZYML(S0NfeWYqP(vyw6ZckyPhlkXccy5DnvV5TCvofclSHkxvtGS0Nf0S0JLaeQbHwktWZxfmd5GDybnlwXc4SoqtbZbqmlOzPhla95CvnzcWcierkds4ovGLKewcqOgeAPmbybeIiL)DkJTV5ESzihSdljjSyflbiqQ86n1HC)ZnNyPpljjSGTjTo)(GKESb)(0UHyzBw6XspwqOS01S0Jf1vRzOG(SXuwVkFmlBwqyw2KL(S0NfeMLESOeliGL31u9M3Yv5uiSWgQCvnbYsFw6ZcAwSIfkOpBmzWqTp5Iq1Zsscl9yHc6ZgtMRYyO2hwssyPhluqF2yYCvwf(7SKKWcf0NnMmxL1RYhw6ZcAwSIL31u9gmCPZWw(3PCdoe(nu5QAcKLKewuxTMXEUu4aEUo7tWRlKTxASpgGUErSeNYSSPc3GL(SGMLESGTjTo)(GKESb)(0UHyzBwuAdwqyw6XIsSGawExt1BElxLtHWcBOYv1eil9zPplOzXX)46Sn0cnSehlkCdw6AwuxTMb)(0CT2muQFfMfeMfekl9zbnl9yXkwuxTMbXRahcmtP2ql0Ks1NPIgKxSiZYMLKewOG(SXK5QmgQ9HLKewSILaeivE9ge7mNxS0Nf0SyflQRwZmoqQGlCUnufRoz8vTLoV3b)0CUzzhbaKWH5S)dwraIzP2q4Dw2IGWQDdXY1yrbDbfXufy5WSmKd2b1S870qS4dXIMWyw(DVyrHS8(GKEmlxXI1SkFyrXd6ZgtSy5(Dwaa)TaQzrtyml)UxSO0gSa)DASCyILRyXRoSO4b9zJjwGdllBwEilkKL3hK0JzrLAWHyXzXAwLpSO4b9zJjdlXCyPONLHAdH3zbCnxHKLygxboeilkEQn0cnPu9SSknHXSCflaGAFyrXd6ZgtrFuSvY6rXicavUQMaJIxeap8hSIa0GtGYWwU8FnueaqchMZ(pyfbi(XelBbySzbwSeazXY97W1ZsWTTVczeGWCpnNhbWTZHDkGy0hfBLS2OyebGkxvtGrXlca0ocaM(iaE4pyfbaOpNRQPiaaD9IIayflGZ6anfmhaXSGMfG(CUQMmbWCawG3FWIf0S0JLESOUAnd(9P5ATzzZssclVRP6n4N0AFYGZ1EdvUQMazjjHLaeivE9M6qU)5MtS0Nf0S0JfRyrD1AgmuJ)lqMLnlOzXkwuxTMj45RcMLnlOzPhlwXY7AQEtBnDYWwM0RImu5QAcKLKewuxTMj45RcgW14)blwIJLaeQbHwktBnDYWwM0RImdL6xHzbbSeFS0Nf0Sa0NZv1K53NtRZyIqKMSf)EwqZspwSILaeivE9M6qU)5MtSKKWsac1GqlLjalGqeP8VtzS9n3JnlBwqZspwuxTMb)(0CT2muQFfMLTzztwssyXkwExt1BWpP1(KbNR9gQCvnbYsFw6ZcAwEFqsV5Vuk)Wm4rSehlQRwZe88vbd4A8)GflimlBy2kw6ZssclQqmMf0S0oK7FEOu)kmlBZI6Q1mbpFvWaUg)pyXs)iaa9jxEkfbiaMdWc8(dwzhsrFuSvsHrXicavUQMaJIxeap8hSIamoqQGlCUnufRoraajCyo7)GveG4htSSfgQIvhwSC)olkOlOiMQqeGWCpnNhbqD1AMGNVkygk1VcZsCSOKczjjHf1vRzcE(QGbCn(FWILTzX6BWcAwa6Z5QAYeaZbybE)bRSdPOpk2kHqJIreaQCvnbgfViaE4pyfbiqAc)NRZU(qwPu9raajCyo7)GveG4htSOGUGIyQcSalwcGSSknHXS4fil6RiwUNLLnlwUFNffalGqePiaH5EAopcaqFoxvtMayoalW7pyLDiXcAw6XI6Q1mbpFvWaUg)pyXsCkZI13GLKewSILaeivE9gGu97Dgw6ZssclQRwZmoqQGlCUnufRoMLnlOzrD1AMXbsfCHZTHQy1XmuQFfMLTzzRzbbSeGf46EJ9qHdtzxFiRuQEZFPugORxeliGLESyflQRwZOQHqq9c)MLnlOzXkwExt1BWVpA4aAOYv1eil9J(OyR0wffJiau5QAcmkEracZ90CEeaG(CUQMmbWCawG3FWk7qkcGh(dwraUk4t5)bROpk2kfFrXicavUQMaJIxeap8hSIaqP2ql0KvHfyeaqchMZ(pyfbi(XelkEQn0cnSepybYcSyjaYIL73zbW7tZ1Aww2S4filyhiXsdoSSLln2hw8cKff0fuetvicqyUNMZJaOcXywqZYvpn2qT)eyUDi3)8qP(vyw2MfLuiljjS0Jf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelBZYMkCdwssyrD1Ag75sHd456SpbVUq2EPX(ya66fXsCkZYMkCdw6ZcAwuxTMb)(0CT2SSzbnl9yjaHAqOLYe88vbZqP(vywIJfRDdwssybCwhOPG5aiML(rFuSvARJIreaQCvnbgfViaE4pyfba)Kw7tUP9HIae6e0u(9bj94OyRueGWCpnNhbyO2q4DxvtSGML)sP8dZGhXsCSOKczbnlyBsRZVpiPhBWVpTBiw2MfRLf0S425WofqKf0S0Jf1vRzcE(QGzOu)kmlXXIsBWssclwXI6Q1mbpFvWSSzPFeaqchMZ(pyfbiMLAdH3zPP9HybwSSSz5HSyDwEFqspMfl3VdxplkOlOiMQalQ0vizXvHRNLhYcHk7Biw8cKLc(SabstWTTVcz0hf7n3ikgraOYv1eyu8Ia4H)GveG2A6KHTmPxffbaKWH5S)dwraIFmXYwaQ4SCnwUcFGelEXIIh0NnMyXlqw0xrSCpllBwSC)ololB5sJ9Hf7bgyXlqw6cOB)hqIfaw8jncqyUNMZJaqb9zJjZvzV6WcAwuxTMXEUu4aEUo7tWRlKTxASpgGUErSSnlBQWnybnl9ybe(gh0T)diLXw8jnd6PosY8xaXRqYssclwXsacKkVEtrHbQHdiljjSGTjTo)(GKEmlXXYMS0Nf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MLTMLUMLESOqwqywMvrn4GKm4RAlDEVd(P5CdvUQMazPplOzrD1AMXbsfCHZTHQy1XSSzjjHfRyrD1AMXbsfCHZTHQy1XSSzPplOzPhlwXsac1GqlLj45RcMLnljjSOUAnZVpNwNXeHing87bezzBwusHSGML2HC)ZdL6xHzzBw2CJnybnlTd5(Nhk1VcZsCSO0gBWssclwXcgU0QxbA(9506mMiePXqLRQjqw6ZcAw6XcgU0QxbA(9506mMiePXqLRQjqwssyjaHAqOLYe88vbZqP(vywIJfRVbl9J(OyVPsrXicavUQMaJIxeap8hSIaGFFAUwhbaKWH5S)dwraIFmXIZcG3NMR1SSfx0VZI9adSSknHXSa49P5AnlhMfxpKd2HLLnlWHLoWfl(qS4QW1ZYdzbcKMGBZsxWBzeGWCpnNhbqD1Agyr)ooBttGS)dwMLnlOzPhlQRwZGFFAUwBgQneE3v1eljjS44FCD2gAHgwIJLTEdw6h9rXEZnJIreaQCvnbgfViaE4pyfba)(0CTocaiHdZz)hSIaeZxP2S0f8wYIk1GdXIcGfqiIelwUFNfaVpnxRzXlqw(DQybW7dEniPiaH5EAopcqacKkVEtDi3)CZjwqZIvS8UMQ3GFsR9jdox7nu5QAcKf0S0JfG(CUQMmbybeIiLbjCNkWssclbiudcTuMGNVkyw2SKKWI6Q1mbpFvWSSzPplOzjaHAqOLYeGfqiIu(3Pm2(M7XMHs9RWSSnlidGMuhvSGWSeOtZspwC8pUoBdTqdlOGffUbl9zbnlQRwZGFFAUwBgk1VcZY2SyTSGMfRybCwhOPG5aio6JI9MwpkgraOYv1eyu8IaeM7P58iabiqQ86n1HC)ZnNybnl9ybOpNRQjtawaHiszqc3PcSKKWsac1GqlLj45RcMLnljjSOUAntWZxfmlBw6ZcAwcqOgeAPmbybeIiL)DkJTV5ESzOu)kmlBZccLf0SOUAnd(9P5ATzzZcAwOG(SXK5QSxDybnlwXcqFoxvtMdzbhkJFFWRbjXcAwSIfWzDGMcMdG4iaE4pyfba)(Gxdsk6JI9MwBumIaqLRQjWO4fbWd)bRia43h8AqsraajCyo7)GveG4htSa49bVgKelwUFNfVyzlUOFNf7bgyboSCnw6axkcKfiqAcUnlDbVLSy5(Dw6axdlfHQNLGJFdlDrJHSaUsTzPl4TKf)z53jwOcKfyJLFNybLmv)ENHf1vRXY1ybW7tZ1AwSaxAWsrplnxRzb2ASahw6axS4dXcSyztwEFqspocqyUNMZJaOUAndSOFhNdAYNmWdFWYSSzjjHLESyfl43N2nKXTZHDkGilOzXkwa6Z5QAYCil4qz87dEnijwssyPhlQRwZe88vbZqP(vyw2MffYcAwuxTMj45RcMLnljjS0JLESOUAntWZxfmdL6xHzzBwqganPoQybHzjqNMLES44FCD2gAHgwqblwFdw6ZcAwuxTMj45RcMLnljjSOUAnZ4aPcUW52qvS6KXx1w68Eh8tZ5MHs9RWSSnlidGMuhvSGWSeOtZspwC8pUoBdTqdlOGfRVbl9zbnlQRwZmoqQGlCUnufRoz8vTLoV3b)0CUzzZsFwqZsacKkVEdqQ(9odl9zPplOzPhlyBsRZVpiPhBWVpnxRzzBwSoljjSa0NZv1Kb)(0CToBbwFU5ADg2AS0NL(SGMfRybOpNRQjZHSGdLXVp41GKybnl9yXkwMvrn4GKm)LswGtLbhYtvVcKgdvUQMazjjHfSnP153hK0Jn43NMR1SSnlwNL(rFuS3uHrXicavUQMaJIxeap8hSIauKLCkewraajCyo7)GveG4htSSfbHfMLRybau7dlkEqF2yIfVazb7ajw2clTMLTiiSyPbhwuqxqrmvHiaH5EAopcqpwuxTMHc6Zgtzmu7JzOu)kmlXXcHkkSEk)xkXsscl9yjS7dscZIYSSjlOzzOWUpiP8FPelBZIczPpljjSe29bjHzrzwSol9zbnlUDoStbeJ(OyVjcnkgraOYv1eyu8IaeM7P58ia9yrD1AgkOpBmLXqTpMHs9RWSehleQOW6P8FPeljjS0JLWUpijmlkZYMSGMLHc7(GKY)LsSSnlkKL(SKKWsy3hKeMfLzX6S0Nf0S425WofqKf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MffYcAwuxTMzCGubx4CBOkwDmlBwqZIvSmRIAWbjzWx1w68Eh8tZ5gQCvnbYssclwXI6Q1mJdKk4cNBdvXQJzzZs)iaE4pyfby31TCkewrFuS3CRIIreaQCvnbgfViaH5EAopcqpwuxTMHc6Zgtzmu7JzOu)kmlXXcHkkSEk)xkXcAw6Xsac1GqlLj45RcMHs9RWSehlkCdwssyjaHAqOLYeGfqiIu(3Pm2(M7XMHs9RWSehlkCdw6Zsscl9yjS7dscZIYSSjlOzzOWUpiP8FPelBZIczPpljjSe29bjHzrzwSol9zbnlUDoStbezbnl9yrD1AMXbsfCHZTHQy1XmuQFfMLTzrHSGMf1vRzghivWfo3gQIvhZYMf0SyflZQOgCqsg8vTLoV3b)0CUHkxvtGSKKWIvSOUAnZ4aPcUW52qvS6yw2S0pcGh(dwraAlToNcHv0hf7nJVOyebGkxvtGrXlcaiHdZz)hSIae)yIfucOIZcSyrbX8iaE4pyfbWIpZbNmSLj9QOOpk2BU1rXicavUQMaJIxeaODeam9ra8WFWkcaqFoxvtraa66ffbaBtAD(9bj9yd(9PDdXsCSyTSGawAAiCyPhlPo(PPtgORxelimlkTXgSGcw2Cdw6ZccyPPHWHLESOUAnd(9bVgKuMsTHwOjLQpJHAFm43diYckyXAzPFeaqchMZ(pyfbqbUoS0(tywSSt)onS8qwwyIfaVpTBiwUIfaqTpSyz)c7SCyw8NffYY7ds6XiqjwAWHfcinDyzZnqPSK64NMoSahwSwwa8(GxdsIffp1gAHMuQEwWVhqehbaOp5YtPia43N2nu(QmgQ9j6JIT13ikgraOYv1eyu8IaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiakXckybBtADE3XpXY2SSjlDnl9yzdZMSGWS0JfSnP153hK0Jn43N2nelDnlkXsFwqyw6XIsSGawExt1BWWLodB5FNYn4q43qLRQjqwqywuYOqw6ZsFwqalByusHSGWSOUAnZ4aPcUW52qvS6ygk1VchbaKWH5S)dwrauGRdlT)eMfl70VtdlpKfuIX)DwaxZvizzlmufRoraa6tU8ukcGLX)98v52qvS6e9rX26kffJiau5QAcmkEra8WFWkcGLX)9iaGeomN9FWkcq8Jjwqjg)3z5kwaa1(WIIh0NnMyboSCnwkilaEFA3qSy50AwA3ZYvpKff0fuetvGfV6KchkcqyUNMZJa0JfkOpBmz0RYNCrO6zjjHfkOpBmz8QtUiu9SGMfG(CUQMmhoh0KdKyPplOzPhlVpiP38xkLFyg8iwIJfRLLKewOG(SXKrVkFYxL3KLKewAhY9ppuQFfMLTzrPnyPpljjSOUAndf0NnMYyO2hZqP(vyw2Mfp8hSm43N2nKHqffwpL)lLybnlQRwZqb9zJPmgQ9XSSzjjHfkOpBmzUkJHAFybnlwXcqFoxvtg87t7gkFvgd1(WssclQRwZe88vbZqP(vyw2Mfp8hSm43N2nKHqffwpL)lLybnlwXcqFoxvtMdNdAYbsSGMf1vRzcE(QGzOu)kmlBZcHkkSEk)xkXcAwuxTMj45RcMLnljjSOUAnZ4aPcUW52qvS6yw2SGMfG(CUQMmwg)3ZxLBdvXQdljjSyfla95CvnzoCoOjhiXcAwuxTMj45RcMHs9RWSehleQOW6P8FPu0hfBRVzumIaqLRQjWO4fbaKWH5S)dwraIFmXcG3N2nelxJLRyXAwLpSO4b9zJjuZYvSaaQ9HffpOpBmXcSyXAralVpiPhZcCy5HSypWalaGAFyrXd6Zgtra8WFWkca(9PDdf9rX26wpkgraOYv1eyu8Iaas4WC2)bRiaBbxR)9zfbWd)bRiaZQYE4pyL1h(JaOp8NlpLIa0CT(3Nv0h9raAUw)7ZkkgrXwPOyebGkxvtGrXlcGh(dwraWVp41GKIaas4WC2)bRiaaEFWRbjXsdoSKcbsPu9SSknHXSSWxHKL4b7smIaeM7P58iawXYSkQbhKKr11EfOmSLDTo)7xHeBifBD22ey0hf7nJIreaQCvnbgfViaE4pyfbaVQ2nueGqNGMYVpiPhhfBLIaeM7P58iaGW3KcHv7gYmuQFfML4yzOu)kmlimlBUjlOGfLIViaGeomN9FWkcGcC8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDuXc4A8)GflhML97nSayvTBiwgk1VcZs6s)NT(iqwEilP(h2zjfcR2nelGRX)dwrFuSTEumIa4H)GveGuiSA3qraOYv1eyu8I(Opca(JIruSvkkgraOYv1eyu8Ia4H)Gvea87dEniPiaGeomN9FWkcq8Jjwa8(GxdsILhYcIezZYYMLFNyjMpKNQEfinSOUAnwUgl3ZIf4sdYcHk7BiwuPgCiwAxD49RqYYVtSueQEwco(zboS8qwaxP2SOsn4qSOaybeIifbim3tZ5raMvrn4GKm)LswGtLbhYtvVcKgdvUQMazbnl9yHc6ZgtMRYE1Hf0Syfl9yPhlQRwZ8xkzbovgCipv9kqAmdL6xHzjow8WFWYyz8F3qOIcRNY)LsSGaw2WOelOzPhluqF2yYCvwf(7SKKWcf0NnMmxLXqTpSKKWcf0NnMm6v5tUiu9S0NLKewuxTM5VuYcCQm4qEQ6vG0ygk1VcZsCS4H)GLb)(0UHmeQOW6P8FPeliGLnmkXcAw6Xcf0NnMmxL1RYhwssyHc6Zgtgmu7tUiu9SKKWcf0NnMmE1jxeQEw6ZsFwssyXkwuxTM5VuYcCQm4qEQ6vG0yw2S0NLKew6XI6Q1mbpFvWSSzjjHfG(CUQMmbybeIiLbjCNkWsFwqZsac1GqlLjalGqeP8VtzS9n3Jnd5GDybnlbiqQ86n1HC)ZnNyPplOzPhlwXsacKkVEdIDMZlwssyjaHAqOLYqP2ql0KvHfOzOu)kmlXXs8XsFwqZspwuxTMj45RcMLnljjSyflbiudcTuMGNVkygYb7Ws)Opk2BgfJiau5QAcmkEra8WFWkcGd62)bKYyl(Kgbi0jOP87ds6XrXwPiaH5EAopcGvSacFJd62)bKYyl(KMb9uhjz(lG4vizbnlwXIh(dwgh0T)diLXw8jnd6PosYCvUPpK7plOzPhlwXci8noOB)hqkJT4tAENCT5VaIxHKLKewaHVXbD7)aszSfFsZ7KRndL6xHzjowuil9zjjHfq4BCq3(pGugBXN0mON6ijd(9aISSnlwNf0SacFJd62)bKYyl(KMb9uhjzgk1VcZY2SyDwqZci8noOB)hqkJT4tAg0tDKK5VaIxHmcaiHdZz)hSIae)yILUa62)bKybGfFszXYovS870qSCywkilE4pGelyl(KIAwCmlA)jwCml2qm(u1elWIfSfFszXY97SSjlWHLgzHgwWVhqeZcCybwS4SyDeWc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdiHzbLKf(zXBpnS87(Zc2IpPSqOY(gch9rX26rXicavUQMaJIxeap8hSIaeGfqiIu(3Pm2(M7XraajCyo7)GveG4htywuaSacrKy5ASOGUGIyQcSCyww2Sahw6axS4dXciH7uHRqYIc6ckIPkWIL73zrbWcierIfVazPdCXIpelQKgAHfRDdw6cElJaeM7P58iawXc4SoqtbZbqmlOzPhl9ybOpNRQjtawaHiszqc3PcSGMfRyjaHAqOLYe88vbZqoyhwqZIvSmRIAWbjzSNlfoGNRZ(e86cz7Lg7JHkxvtGSKKWI6Q1mbpFvWSSzPplOzXX)46Sn0cnSSTYSyTBWcAw6XI6Q1muqF2ykRxLpMHs9RWSehlkTbljjSOUAndf0NnMYyO2hZqP(vywIJfL2GL(SKKWIkeJzbnlTd5(Nhk1VcZY2SO0gSGMfRyjaHAqOLYe88vbZqoyhw6h9rX2AJIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkcqpwuxTMzCGubx4CBOkwDmdL6xHzjowuiljjSyflQRwZmoqQGlCUnufRoMLnl9zbnlwXI6Q1mJdKk4cNBdvXQtgFvBPZ7DWpnNBw2SGMLESOUAndIxboeyMsTHwOjLQptfniVyrMHs9RWSSnlidGMuhvS0Nf0S0Jf1vRzOG(SXugd1(ygk1VcZsCSGmaAsDuXssclQRwZqb9zJPSEv(ygk1VcZsCSGmaAsDuXsscl9yXkwuxTMHc6Zgtz9Q8XSSzjjHfRyrD1AgkOpBmLXqTpMLnl9zbnlwXY7AQEdgQX)fidvUQMazPFeaqchMZ(pyfbqbWc8(dwS0GdlUwZci8XS87(ZsQJiHzbVgILFN6WIpuPONLHAdH3jqwSStflXSoqQGlmlBHHQy1HLDhZIMWyw(DVyrHSGPaMLHs9RUcjlWHLFNybXoZ5flQRwJLdZIRcxplpKLMR1SaBnwGdlE1HffpOpBmXYHzXvHRNLhYcHk7BOiaa9jxEkfbae(5HuS1nukvpo6JITcJIreaQCvnbgfViaq7iay6Ja4H)GveaG(CUQMIaa01lkcqpwSIf1vRzOG(SXugd1(yw2SGMfRyrD1AgkOpBmL1RYhZYML(SKKWY7AQEdgQX)fidvUQMaJaas4WC2)bRiakawG3FWILF3Fwc7uarmlxJLoWfl(qSaxp(ajwOG(SXelpKfyP7Wci8z53PHyboSCil4qS87hMfl3VZcaOg)xGIaa0NC5Pueaq4NHRhFGuMc6ZgtrFuSrOrXicavUQMaJIxeap8hSIaKcHv7gkcqyUNMZJamuBi8URQjwqZspwuxTMHc6Zgtzmu7JzOu)kmlXXYqP(vywssyrD1AgkOpBmL1RYhZqP(vywIJLHs9RWSKKWcqFoxvtgq4NHRhFGuMc6ZgtS0Nf0SmuBi8URQjwqZY7ds6n)Ls5hMbpIL4yrPnzbnlUDoStbezbnla95CvnzaHFEifBDdLs1JJae6e0u(9bj94OyRu0hf7TkkgraOYv1eyu8Ia4H)Gvea8QA3qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjowgk1VcZssclQRwZqb9zJPSEv(ygk1VcZsCSmuQFfMLKewa6Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqsV5Vuk)Wm4rSehlkTjlOzXTZHDkGilOzbOpNRQjdi8ZdPyRBOuQECeGqNGMYVpiPhhfBLI(OyhFrXicavUQMaJIxeap8hSIaGFsR9j30(qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjowgk1VcZssclQRwZqb9zJPSEv(ygk1VcZsCSmuQFfMLKewa6Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqsV5Vuk)Wm4rSehlkHqzbnlUDoStbezbnla95CvnzaHFEifBDdLs1JJae6e0u(9bj94OyRu0hf7TokgraOYv1eyu8Ia4H)GveGgCcug2YL)RHIaas4WC2)bRiaXpMyzlaJnlWILailwUFhUEwcUT9viJaeM7P58iaUDoStbeJ(OyR0grXicavUQMaJIxeap8hSIaqP2ql0KvHfyeaqchMZ(pyfbi(XelXmUcCiqwayFZ9ywSC)olE1HfnSqYcvWfYDw0o(VcjlkEqF2yIfVaz5NoS8qw0xrSCpllBwSC)olB5sJ9HfVazrbDbfXufIaeM7P58ia9yPhlQRwZqb9zJPmgQ9XmuQFfML4yrPnyjjHf1vRzOG(SXuwVkFmdL6xHzjowuAdw6ZcAwcqOgeAPmbpFvWmuQFfML4yX6BWcAw6XI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lILTzztRDdwssyXkwMvrn4GKm2ZLchWZ1zFcEDHS9sJ9Xqk26STjqw6ZsFwssyrD1Ag75sHd456SpbVUq2EPX(ya66fXsCkZYMB1gSKKWI6Q1mbpFvWmuQFfML4yrPnI(OyRKsrXicavUQMaJIxeaODeam9ra8WFWkcaqFoxvtraa66ffbWkwaN1bAkyoaIzbnla95CvnzcG5aSaV)GflOzPhl9yjaHAqOLYqP2DgY1z4awEfiZqP(vyw2MfLqOBfliGLESOKsSGWSmRIAWbjzWx1w68Eh8tZ5gQCvnbYsFwqZcPyRZ2ManuQDNHCDgoGLxbIL(SKKWIJ)X1zBOfAyjoLzzR3Gf0S0JfRy5DnvVPTMozylt6vrgQCvnbYssclQRwZe88vbd4A8)GflXXsac1GqlLPTMozylt6vrMHs9RWSGawIpw6ZcAwaHVbVQ2nKzOu)kmlXXIsBYcAwaHVjfcR2nKzOu)kmlXXs8XcAw6Xci8n4N0AFYnTpKzOu)kmlXXs8XssclwXY7AQEd(jT2NCt7dzOYv1eil9zbnla95Cvnz(9506mMiePjBXVNf0S0JLaeQbHwkdLAdTqtwfwGMLnljjSyflbiqQ86ni2zoVyPplOz59bj9M)sP8dZGhXsCSOUAntWZxfmGRX)dwSGWSSHzRyjjHfvigZcAwAhY9ppuQFfMLTzrD1AMGNVkyaxJ)hSyjjHLaeivE9M6qU)5MtSKKWI6Q1mQAieuVWVzzZcAwuxTMrvdHG6f(ndL6xHzzBwuxTMj45RcgW14)blwqal9yzRzbHzzwf1GdsYypxkCapxN9j41fY2ln2hdPyRZ2MazPpl9zbnlwXI6Q1mbpFvWSSzbnl9yXkwcqGu51BQd5(NBoXssclbiudcTuMaSacrKY)oLX23Cp2SSzjjHfvigZcAwAhY9ppuQFfMLTzjaHAqOLYeGfqiIu(3Pm2(M7XMHs9RWSGawqOSKKWs7qU)5Hs9RWSGszrP4Bdw2Mf1vRzcE(QGbCn(FWIL(raajCyo7)GveG4htSOGUGIyQcSy5(DwuaSacrKqrmJRahcKfa23CpMfVazbewk6zbcKglZ9elB5sJ9Hf4WILDQyjEAieuVWplwGlnileQSVHyrLAWHyrbDbfXufyHqL9neocaqFYLNsracG5aSaV)Gvg)rFuSvAZOyebGkxvtGrXlca0ocaM(iaE4pyfbaOpNRQPiaaD9IIayflGZ6anfmhaXSGMfG(CUQMmbWCawG3FWIf0S0JLESeGqni0szOu7od56mCalVcKzOu)kmlBZIsi0TIfeWspwusjwqywMvrn4GKm4RAlDEVd(P5CdvUQMazPplOzHuS1zBtGgk1UZqUodhWYRaXsFwssyXX)46Sn0cnSeNYSS1BWcAw6XIvS8UMQ30wtNmSLj9QidvUQMazjjHf1vRzcE(QGbCn(FWIL4yjaHAqOLY0wtNmSLj9QiZqP(vywqalXhl9zbnlGW3Gxv7gYmuQFfML4yj(ybnlGW3KcHv7gYmuQFfML4yzRzbnl9ybe(g8tATp5M2hYmuQFfML4yrPnyjjHfRy5DnvVb)Kw7tUP9Hmu5QAcKL(SGMfG(CUQMm)(CADgteI0KT43ZcAw6XI6Q1miEf4qGzk1gAHMuQ(mv0G8Ifzw2SKKWIvSeGaPYR3GyN58IL(SGML3hK0B(lLYpmdEelXXI6Q1mbpFvWaUg)pyXccZYgMTILKewuHymlOzPDi3)8qP(vyw2Mf1vRzcE(QGbCn(FWILKewcqGu51BQd5(NBoXssclQRwZOQHqq9c)MLnlOzrD1AgvnecQx43muQFfMLTzrD1AMGNVkyaxJ)hSybbS0JLTMfeMLzvudoijJ9CPWb8CD2NGxxiBV0yFmKIToBBcKL(S0Nf0SyflQRwZe88vbZYMf0S0JfRyjabsLxVPoK7FU5eljjSeGqni0szcWcierk)7ugBFZ9yZYMLKewuHymlOzPDi3)8qP(vyw2MLaeQbHwktawaHis5FNYy7BUhBgk1VcZccybHYssclQqmMf0S0oK7FEOu)kmlOuwuk(2GLTzrD1AMGNVkyaxJ)hSyPFeaG(KlpLIaeaZbybE)bRm(J(OyRK1JIreaQCvnbgfViaE4pyfbyCGubx4CBOkwDIaas4WC2)bRiaXpMy53jwqjt1V3zyXY97S4SOGUGIyQcS87(ZYHlf9S0gyklB5sJ9jcqyUNMZJaOUAntWZxfmdL6xHzjowusHSKKWI6Q1mbpFvWaUg)pyXY2Sy9nzbnla95CvnzcG5aSaV)Gvg)rFuSvYAJIreaQCvnbgfViaH5EAopcaqFoxvtMayoalW7pyLXplOzPhlQRwZe88vbd4A8)GflXPmlwFtwssyXkwcqGu51Bas1V3zyPpljjSOUAnZ4aPcUW52qvS6yw2SGMf1vRzghivWfo3gQIvhZqP(vyw2MLTMfeWsawGR7n2dfomLD9HSsP6n)LszGUErSGaw6XIvSOUAnJQgcb1l8Bw2SGMfRy5DnvVb)(OHdOHkxvtGS0pcGh(dwracKMW)56SRpKvkvF0hfBLuyumIaqLRQjWO4fbim3tZ5raa6Z5QAYeaZbybE)bRm(Ja4H)GveGRc(u(FWk6JITsi0OyebGkxvtGrXlca0ocaM(iaE4pyfbaOpNRQPiaaD9IIayflbiudcTuMGNVkygYb7WssclwXcqFoxvtMaSacrKYGeUtfybnlbiqQ86n1HC)ZnNyjjHfWzDGMcMdG4iaGeomN9FWkcakzFoxvtSSWeilWIfx903FeMLF3FwS41ZYdzrLyb7ajqwAWHff0fuetvGfmKLF3Fw(DQdl(q1ZIfh)eilOKSWplQudoel)oLgbaOp5YtPiayhiLBWjh88vHOpk2kTvrXicavUQMaJIxeap8hSIa0wtNmSLj9QOiaGeomN9FWkcq8JjmlBbOIZY1y5kw8IffpOpBmXIxGS8ZrywEil6RiwUNLLnlwUFNLTCPX(GAwuqxqrmvbw8cKLUa62)bKybGfFsJaeM7P58iauqF2yYCv2RoSGMf3oh2PaISGMf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelBZYMw7gSGMLESacFJd62)bKYyl(KMb9uhjz(lG4vizjjHfRyjabsLxVPOWa1WbKL(SGMfG(CUQMmyhiLBWjh88vbwqZspwuxTMzCGubx4CBOkwDmdL6xHzzBw2Aw6Aw6XIczbHzzwf1GdsYGVQT059o4NMZnu5QAcKfeWIvSqk26STjqZv4FwHho4m4b8kkRsAnl9zbnlQRwZmoqQGlCUnufRoMLnljjSyflQRwZmoqQGlCUnufRoMLnl9zbnl9yXkwcqGu51BqSZCEXssclbiudcTugk1gAHMSkSandL6xHzjow2Cdw6h9rXwP4lkgraOYv1eyu8Ia4H)Gvea87tZ16iaGeomN9FWkcq8Jjw2Il63zbW7tZ1AwShyaZY1ybW7tZ1AwoCPONLLDeGWCpnNhbqD1Agyr)ooBttGS)dwMLnlOzrD1Ag87tZ1AZqTHW7UQMI(OyR0whfJiau5QAcmkEracZ90CEea1vRzWVpA4aAgk1VcZY2SOqwqZspwuxTMHc6Zgtzmu7JzOu)kmlXXIczjjHf1vRzOG(SXuwVkFmdL6xHzjowuil9zbnlo(hxNTHwOHL4yzR3icGh(dwracEfiDwD1ArauxTwU8ukca(9rdhWOpk2BUrumIaqLRQjWO4fbWd)bRia43h8AqsraajCyo7)GveGy(k1gZsxWBjlQudoelkawaHisSSWxHKLFNyrbWcierILaSaV)GflpKLWofqKLRXIcGfqiIelhMfp8lxR7WIRcxplpKfvILGJ)iaH5EAopcqacKkVEtDi3)CZjwqZcqFoxvtMaSacrKYGeUtfybnlbiudcTuMaSacrKY)oLX23Cp2muQFfMLTzrHSGMfRybCwhOPG5aiMf0Sqb9zJjZvzV6WcAwC8pUoBdTqdlXXI1Ur0hf7nvkkgraOYv1eyu8Ia4H)Gvea87tZ16iaGeomN9FWkcq8Jjwa8(0CTMfl3VZcGN0AFyjMpx7zXlqwkilaEF0Wbe1SyzNkwkilaEFAUwZYHzzzJAw6axS4dXYvSynRYhwu8G(SXeln4Ws8HamfWSahwEil2dmWYwU0yFyXYovS4QqGelB9gS0f8wYcCyXbT9)asSGT4tkl7oML4dbykGzzOu)QRqYcCy5WSCfln9HC)nSeB4tS87(ZYQaPHLFNyb7PelbybE)blml3RimlG2ywkA9JRz5HSa49P5AnlGR5kKSeZ6aPcUWSSfgQIvhuZILDQyPdCPiqwW)P1SqfillBwSC)olB9giWX2S0Gdl)oXI2Xpli1qvxJnracZ90CEeG31u9g8tATpzW5AVHkxvtGSGMfRy5DnvVb)(OHdOHkxvtGSGMf1vRzWVpnxRnd1gcV7QAIf0S0Jf1vRzOG(SXuwVkFmdL6xHzjowIpwqZcf0NnMmxL1RYhwqZI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lILTzztfUbljjSOUAnJ9CPWb8CD2NGxxiBV0yFmaD9IyjoLzztfUblOzXX)46Sn0cnSehlB9gSKKWci8noOB)hqkJT4tAg0tDKKzOu)kmlXXs8XssclE4pyzCq3(pGugBXN0mON6ijZv5M(qU)S0Nf0SeGqni0szcE(QGzOu)kmlXXIsBe9rXEZnJIreaQCvnbgfViaE4pyfba)(GxdskcaiHdZz)hSIae)yIfaVp41GKyzlUOFNf7bgWS4filGRuBw6cElzXYovSOGUGIyQcSahw(DIfuYu97DgwuxTglhMfxfUEwEilnxRzb2ASahw6axkcKLGBZsxWBzeGWCpnNhbqD1Agyr)ooh0KpzGh(GLzzZssclQRwZG4vGdbMPuBOfAsP6ZurdYlwKzzZssclQRwZe88vbZYMf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MfKbqtQJkwqywc0PzPhlo(hxNTHwOHfuWI13GL(SGawSolimlVRP6nfzjNcHLHkxvtGSGMfRyzwf1GdsYGVQT059o4NMZnu5QAcKf0SOUAnZ4aPcUW52qvS6yw2SKKWI6Q1mbpFvWmuQFfMLTzbza0K6OIfeMLaDAw6XIJ)X1zBOfAybfSy9nyPpljjSOUAnZ4aPcUW52qvS6KXx1w68Eh8tZ5MLnljjS0Jf1vRzghivWfo3gQIvhZqP(vyw2Mfp8hSm43N2nKHqffwpL)lLybnlyBsRZ7o(jw2MLnmwlljjSOUAnZ4aPcUW52qvS6ygk1VcZY2S4H)GLXY4)UHqffwpL)lLyjjHfG(CUQMmNIbMdWc8(dwSGMLaeQbHwkZv4WSExvtzfB51VsZGeWlqMHCWoSGMfsXwNTnbAUchM17QAkRylV(vAgKaEbIL(SGMf1vRzghivWfo3gQIvhZYMLKewSIf1vRzghivWfo3gQIvhZYMf0SyflbiudcTuMXbsfCHZTHQy1XmKd2HLKewSILaeivE9gGu97Dgw6Zssclo(hxNTHwOHL4yzR3Gf0Sqb9zJjZvzV6e9rXEtRhfJiau5QAcmkEra8WFWkca(9bVgKueaqchMZ(pyfbigthwEilPoIel)oXIkHFwGnwa8(OHdilQDyb)EaXRqYY9SSSzrXwxarDhwUIfV6WIIh0NnMyrD9SSLln2hwoC9S4QW1ZYdzrLyXEGHabgbim3tZ5raExt1BWVpA4aAOYv1eilOzXkwMvrn4GKm)LswGtLbhYtvVcKgdvUQMazbnl9yrD1Ag87JgoGMLnljjS44FCD2gAHgwIJLTEdw6ZcAwuxTMb)(OHdOb)Earw2MfRZcAw6XI6Q1muqF2ykJHAFmlBwssyrD1AgkOpBmL1RYhZYML(SGMf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelBZYMB1gSGMLESeGqni0szcE(QGzOu)kmlXXIsBWssclwXcqFoxvtMaSacrKYGeUtfybnlbiqQ86n1HC)ZnNyPF0hf7nT2OyebGkxvtGrXlca0ocaM(iaE4pyfbaOpNRQPiaaD9IIaqb9zJjZvz9Q8HfeML4JfuWIh(dwg87t7gYqOIcRNY)LsSGawSIfkOpBmzUkRxLpSGWS0JfekliGL31u9gmCPZWw(3PCdoe(nu5QAcKfeMfRZsFwqblE4pyzSm(VBiurH1t5)sjwqalBySwfYckybBtADE3XpXccyzdJczbHz5DnvVP8FneoR6AVcKHkxvtGraajCyo7)Gveafh)xQ)eMLDOfwsxHDw6cElzXhIfK(veil20WcMcWcmcaqFYLNsraCS9wsdake9rXEtfgfJiau5QAcmkEra8WFWkca(9bVgKueaqchMZ(pyfbiMVsTzbW7dEnijwUIfNLTcbykWcaO2hwu8G(SXeQzbewk6zrtpl3ZI9adSSLln2hw697(ZYHzz3lqnbYIAhwO73PHLFNybW7tZ1Aw0xrSahw(DILUG3Y426nyrFfXsdoSa49bVgKuFuZciSu0ZceinwM7jw8ILT4I(DwShyGfVazrtpl)oXIRcbsSOVIyz3lqnXcG3hnCaJaeM7P58iawXYSkQbhKK5VuYcCQm4qEQ6vG0yOYv1eilOzPhlQRwZypxkCapxN9j41fY2ln2hdqxViw2MLn3QnyjjHf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelBZYMkCdwqZY7AQEd(jT2Nm4CT3qLRQjqw6ZcAw6Xcf0NnMmxLXqTpSGMfh)JRZ2ql0WccybOpNRQjJJT3sAaqbwqywuxTMHc6Zgtzmu7JzOu)kmliGfq4BARPtg2YKEvK5VaI48qP(vSGWSSPrHSehlX3gSKKWcf0NnMmxL1RYhwqZIJ)X1zBOfAybbSa0NZv1KXX2BjnaOalimlQRwZqb9zJPSEv(ygk1VcZccybe(M2A6KHTmPxfz(lGiopuQFflimlBAuilXXYwVbl9zbnlwXI6Q1mWI(DC2MMaz)hSmlBwqZIvS8UMQ3GFF0Wb0qLRQjqwqZspwcqOgeAPmbpFvWmuQFfML4yzRyjjHfmCPvVc087ZP1zmrisJHkxvtGSGMf1vRz(9506mMiePXGFpGilBZI1TolDnl9yzwf1GdsYGVQT059o4NMZnu5QAcKfeMffYsFwqZs7qU)5Hs9RWSehlkTXgSGML2HC)ZdL6xHzzBw2CJnyjjHfWzDGMcMdGyw6ZcAw6Xsac1GqlLbXRahcmJTV5ESzOu)kmlXXYwXssclwXsacKkVEdIDMZlw6h9rXEteAumIaqLRQjWO4fbWd)bRiafzjNcHveaqchMZ(pyfbi(XelBrqyHz5kwSMv5dlkEqF2yIfVazb7ajwIz21neSfwAnlBrqyXsdoSOGUGIyQcS4filXmUcCiqwu8uBOfAsP6JaeM7P58ia9yrD1AgkOpBmL1RYhZqP(vywIJfcvuy9u(VuILKew6Xsy3hKeMfLzztwqZYqHDFqs5)sjw2MffYsFwssyjS7dscZIYSyDw6ZcAwC7CyNciYcAwa6Z5QAYGDGuUbNCWZxfI(OyV5wffJiau5QAcmkEracZ90CEeGESOUAndf0NnMY6v5JzOu)kmlXXcHkkSEk)xkXcAwSILaeivE9ge7mNxSKKWspwuxTMbXRahcmtP2ql0Ks1NPIgKxSiZYMf0SeGaPYR3GyN58IL(SKKWspwc7(GKWSOmlBYcAwgkS7dsk)xkXY2SOqw6ZssclHDFqsywuMfRZssclQRwZe88vbZYML(SGMf3oh2PaISGMfG(CUQMmyhiLBWjh88vbwqZspwuxTMzCGubx4CBOkwDmdL6xHzzBw6XIczPRzztwqywMvrn4GKm4RAlDEVd(P5CdvUQMazPplOzrD1AMXbsfCHZTHQy1XSSzjjHfRyrD1AMXbsfCHZTHQy1XSSzPFeap8hSIaS76wofcROpk2BgFrXicavUQMaJIxeGWCpnNhbOhlQRwZqb9zJPSEv(ygk1VcZsCSqOIcRNY)LsSGMfRyjabsLxVbXoZ5fljjS0Jf1vRzq8kWHaZuQn0cnPu9zQOb5flYSSzbnlbiqQ86ni2zoVyPpljjS0JLWUpijmlkZYMSGMLHc7(GKY)LsSSnlkKL(SKKWsy3hKeMfLzX6SKKWI6Q1mbpFvWSSzPplOzXTZHDkGilOzbOpNRQjd2bs5gCYbpFvGf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MffYcAwuxTMzCGubx4CBOkwDmlBwqZIvSmRIAWbjzWx1w68Eh8tZ5gQCvnbYssclwXI6Q1mJdKk4cNBdvXQJzzZs)iaE4pyfbOT06CkewrFuS3CRJIreaQCvnbgfViaGeomN9FWkcq8JjwqjGkolWILayeap8hSIayXN5Gtg2YKEvu0hfBRVrumIaqLRQjWO4fbWd)bRia43N2nueaqchMZ(pyfbi(XelaEFA3qS8qwShyGfaqTpSO4b9zJjuZIc6ckIPkWYUJzrtyml)LsS87EXIZckX4)oleQOW6jw0u7zboSalDhwSMv5dlkEqF2yILdZYYocqyUNMZJaqb9zJjZvz9Q8Hf0SyflQRwZmoqQGlCUnufRoMLnljjSqb9zJjdgQ9jxeQEwssyHc6ZgtgV6KlcvpljjS0Jf1vRzS4ZCWjdBzsVkYSSzjjHfSnP15Dh)elBZYggRvHSGMfRyjabsLxVbiv)ENHLKewW2KwN3D8tSSnlBySwwqZsacKkVEdqQ(9odl9zbnlQRwZqb9zJPSEv(yw2SKKWspwuxTMj45RcMHs9RWSSnlE4pyzSm(VBiurH1t5)sjwqZI6Q1mbpFvWSSzPF0hfBRRuumIaqLRQjWO4fbaKWH5S)dwraIFmXckX4)olWFNglhMyXY(f2z5WSCflaGAFyrXd6ZgtOMff0fuetvGf4WYdzXEGbwSMv5dlkEqF2ykcGh(dwraSm(Vh9rX26BgfJiau5QAcmkEraajCyo7)GveGTGR1)(SIa4H)GveGzvzp8hSY6d)ra0h(ZLNsraAUw)7Zk6J(ia2dfGPQ(hfJOyRuumIa4H)GveaeVcCiWm2(M7XraOYv1eyu8I(OyVzumIaqLRQjWO4fbaAhbatFeap8hSIaa0NZv1ueaGUErra2icaiHdZz)hSIaeJDIfG(CUQMy5WSGPNLhYYgSy5(Dwkil43FwGfllmXYpxHi9yuZIsSyzNkw(DIL2n4NfyrSCywGfllmHAw2KLRXYVtSGPaSaz5WS4filwNLRXIk83zXhkcaqFYLNsraGvEHP8pxHi9rFuSTEumIaqLRQjWO4fbaAhbWbbJa4H)GveaG(CUQMIaa01lkcGsracZ90CEeGFUcr6nVsMDhNxykRUAnwqZYpxHi9Mxjtac1GqlLbCn(FWIf0Syfl)CfI0BELmh28WukdB5uyH)bUW5aSW)Sc)blCeaG(KlpLIaaR8ct5FUcr6J(OyBTrXicavUQMaJIxeaODeahemcGh(dwraa6Z5QAkcaqxVOiaBgbim3tZ5ra(5keP38BA2DCEHPS6Q1ybnl)CfI0B(nnbiudcTugW14)blwqZIvS8ZvisV530CyZdtPmSLtHf(h4cNdWc)Zk8hSWraa6tU8ukcaSYlmL)5kePp6JITcJIreaQCvnbgfViaq7iaoiyeap8hSIaa0NZv1ueaG(KlpLIaaR8ct5FUcr6JaeM7P58iaKIToBBc0CfomR3v1uwXwE9R0mib8celjjSqk26STjqdLA3zixNHdy5vGyjjHfsXwNTnbAWWLwt)FfY8Su7ebaKWH5S)dwraIXoHjw(5kePhZIpelf8zXxpm1)l4ADhwaPNcpbYIJzbwSSWel43Fw(5kePhByHfa0ZcqFoxvtS8qwSwwCml)o1HfxJHSuebYc2McNRzz3lq9vinraa66ffbWAJ(OyJqJIreap8hSIaKcHfIxLBWjncavUQMaJIx0hf7TkkgraOYv1eyu8Ia4H)GvealJ)7racZ90CEeGESqb9zJjJEv(KlcvpljjSqb9zJjZvzmu7dljjSqb9zJjZvzv4VZsscluqF2yY4vNCrO6zPFea9vuoagbqPnI(Op6JaaKg8bROyV5gBQKskTHsraS4tDfsCeauIUeZg7yk2OKIqyHLyStSCP2W5zPbhwue0MkAueldPyRBiqwWWuIfF9Wu)jqwc7EHKWgUBR5kILnriSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSyDeclkawaP5jqwu0SkQbhKKPRuelpKffnRIAWbjz6kdvUQMavel9ucv9nC3C3OeDjMn2XuSrjfHWclXyNy5sTHZZsdoSOiqQ5l9RiwgsXw3qGSGHPel(6HP(tGSe29cjHnC3wZveliueclkawaP5jqwaCPkGfCN6DuXckLLhYI1SCwapGh(GflqBA8hoS0df9zPNsOQVH72AUIybHIqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyPNsOQVH72AUIyzRqiSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSeFiewuaSasZtGSa4sval4o17OIfuklpKfRz5SaEap8blwG204pCyPhk6ZsVnrvFd3T1CfXs8HqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyPNsOQVH72AUIyzRriSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSS1iewuaSasZtGSOOFUcr6nkz6kfXYdzrr)CfI0BELmDLIyP3MOQVH72AUIyzRriSOaybKMNazrr)CfI0B200vkILhYII(5keP38BA6kfXsVnrvFd3T1CfXIsBGqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyPNsOQVH72AUIyrjLqiSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSO0MiewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6PeQ6B4UTMRiwuY6iewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6PeQ6B4UTMRiwusHiewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6PeQ6B4UTMRiwucHIqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyP3MOQVH72AUIyrjekcHffalG08eilk6NRqKEJsMUsrS8qwu0pxHi9MxjtxPiw6TjQ6B4UTMRiwucHIqyrbWcinpbYII(5keP3SPPRuelpKff9ZvisV5300vkILEkHQ(gUBR5kIfL2keclkawaP5jqwu0SkQbhKKPRuelpKffnRIAWbjz6kdvUQMavel92ev9nC3wZvelkTviewuaSasZtGSOOFUcr6nkz6kfXYdzrr)CfI0BELmDLIyPNsOQVH72AUIyrPTcHWIcGfqAEcKff9ZvisVzttxPiwEilk6NRqKEZVPPRuel92ev9nC3C3OeDjMn2XuSrjfHWclXyNy5sTHZZsdoSOi7HcWuv)veldPyRBiqwWWuIfF9Wu)jqwc7EHKWgUBR5kIfRJqyrbWcinpbYII(5keP3OKPRuelpKff9ZvisV5vY0vkILEwhv9nC3wZvelwlcHffalG08eilk6NRqKEZMMUsrS8qwu0pxHi9MFttxPiw6zDu13WDZDJs0Ly2yhtXgLueclSeJDILl1gopln4WIICiPiwgsXw3qGSGHPel(6HP(tGSe29cjHnC3wZvelkHqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyXFwu8TyRHLEkHQ(gUBR5kIfRJqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyPNsOQVH72AUIybHIqyrbWcinpbYcGlvbSG7uVJkwqPOuwEilwZYzjfcU0lmlqBA8hoS0dL2NLEkHQ(gUBR5kIfekcHffalG08eilkAwf1GdsY0vkILhYIIMvrn4GKmDLHkxvtGkILEBIQ(gUBR5kILTcHWIcGfqAEcKfaxQcyb3PEhvSGsrPS8qwSMLZskeCPxywG204pCyPhkTpl9ucv9nC3wZvelBfcHffalG08eilkAwf1GdsY0vkILhYIIMvrn4GKmDLHkxvtGkILEkHQ(gUBR5kIL4dHWIcGfqAEcKffnRIAWbjz6kfXYdzrrZQOgCqsMUYqLRQjqfXspLqvFd3T1CfXYwJqyrbWcinpbYcGlvbSG7uVJkwqPS8qwSMLZc4b8WhSybAtJ)WHLEOOpl92ev9nC3wZvelkTjcHffalG08eilaUufWcUt9oQybLYYdzXAwolGhWdFWIfOnn(dhw6HI(S0tju13WDBnxrSS5giewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6PeQ6B4UTMRiw2CteclkawaP5jqwaCPkGfCN6DuXckLLhYI1SCwapGh(GflqBA8hoS0df9zPNsOQVH72AUIyztRfHWIcGfqAEcKfaxQcyb3PEhvSGsz5HSynlNfWd4HpyXc0Mg)Hdl9qrFw6TjQ6B4UTMRiw20AriSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSSjcfHWIcGfqAEcKffnRIAWbjz6kfXYdzrrZQOgCqsMUYqLRQjqfXspLqvFd3T1CfXYMBfcHffalG08eilkAwf1GdsY0vkILhYIIMvrn4GKmDLHkxvtGkILEkHQ(gUBR5kILn3AeclkawaP5jqwaCPkGfCN6DuXckLLhYI1SCwapGh(GflqBA8hoS0df9zP3MOQVH72AUIyX6BGqyrbWcinpbYcGlvbSG7uVJkwqPS8qwSMLZc4b8WhSybAtJ)WHLEOOpl9ucv9nC3C3OeDjMn2XuSrjfHWclXyNy5sTHZZsdoSOOMR1)(SueldPyRBiqwWWuIfF9Wu)jqwc7EHKWgUBR5kILnriSOaybKMNazbWLQawWDQ3rflOuwEilwZYzb8aE4dwSaTPXF4Wspu0NLEkHQ(gUBUBuIUeZg7yk2OKIqyHLyStSCP2W5zPbhwue(veldPyRBiqwWWuIfF9Wu)jqwc7EHKWgUBR5kIfLqiSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSyDeclkawaP5jqwu0SkQbhKKPRuelpKffnRIAWbjz6kdvUQMavel9ucv9nC3wZvelkPecHffalG08eilaUufWcUt9oQybLIsz5HSynlNLui4sVWSaTPXF4WspuAFw6PeQ6B4UTMRiwusjeclkawaP5jqwu0SkQbhKKPRuelpKffnRIAWbjz6kdvUQMavel9ucv9nC3wZvelkTjcHffalG08eilaUufWcUt9oQybLIsz5HSynlNLui4sVWSaTPXF4WspuAFw6PeQ6B4UTMRiwuAteclkawaP5jqwu0SkQbhKKPRuelpKffnRIAWbjz6kdvUQMavel9ucv9nC3wZvelkTviewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6PeQ6B4UTMRiw2CteclkawaP5jqwaCPkGfCN6DuXckLLhYI1SCwapGh(GflqBA8hoS0df9zP3MOQVH72AUIyzZnriSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSSP1riSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSSP1IqyrbWcinpbYcGlvbSG7uVJkwqPS8qwSMLZc4b8WhSybAtJ)WHLEOOpl9SoQ6B4UTMRiw2uHiewuaSasZtGSOOzvudoijtxPiwEilkAwf1GdsY0vgQCvnbQiw6TjQ6B4UTMRiw2CRqiSOaybKMNazrrZQOgCqsMUsrS8qwu0SkQbhKKPRmu5QAcurS0tju13WDBnxrSSz8HqyrbWcinpbYIIMvrn4GKmDLIy5HSOOzvudoijtxzOYv1eOIyPNsOQVH7M7gLOlXSXoMInkPiewyjg7elxQnCEwAWHffPc9xrSmKITUHazbdtjw81dt9NazjS7fscB4UTMRiwuARqiSOaybKMNazbWLQawWDQ3rflOuwEilwZYzb8aE4dwSaTPXF4Wspu0NLEwhv9nC3wZvelkfFiewuaSasZtGSa4sval4o17OIfuklpKfRz5SaEap8blwG204pCyPhk6ZspLqvFd3n3DmLAdNNazzRyXd)blw0h(XgU7ia2dSDAkcakJYSepx7vGyjMpRdK7gLrzwIneiLQsdlBADuZYMBSPsC3C3OmkZIc29cjHriC3OmkZsxZsxabjqwaa1(Ws8ip1WDJYOmlDnlky3lKeilVpiPpFnwcoMWS8qwcDcAk)(GKESH7gLrzw6AwIzPuiqcKLvvuGWyF6WcqFoxvtyw6DgYGAwShcyg)(GxdsILUoowShcOb)(GxdsQVH7gLrzw6Aw6cq4bYI9qbh)xHKfuIX)DwUgl3Riml)oXILbwizrXd6ZgtgUBugLzPRzzlYrKyrbWcierILFNybG9n3JzXzrF)RjwsHdXsttO6u1el9UglDGlw2DWsrpl73ZY9SGV0L(9IGlSUdlwUFNL4Tf3LyWccyrbKMW)5Aw6I(qwPu9OML7veilyep7(gUBugLzPRzzlYrKyjfIFwuu7qU)5Hs9RWkIfCGkFoiMf32w3HLhYIkeJzPDi3FmlWs3XWDJYOmlDnlXyi)zjgWuIfyJL4P9DwIN23zjEAFNfhZIZc2McNRz5NRqKEd3nkJYS01SSfBtfnS07mKb1SGsm(VJAwqjg)3rnlaEFA3q9zj1bjwsHdXYq4tFu9S8qwiF0hnSeGPQ(3143N3WDZDJYOmlDPk47pbYs8CTxbILUSLwdlbVyrLyPbxfil(ZY()2yeckqHQR9kqDn(sdgK3VVunhefXZ1EfOUgWLQauKcA2)uDmtBNMuw11EfiZJQN7M72d)blSXEOamv1FLr8kWHaZy7BUhZDJYSeJDIfG(CUQMy5WSGPNLhYYgSy5(Dwkil43FwGfllmXYpxHi9yuZIsSyzNkw(DIL2n4NfyrSCywGfllmHAw2KLRXYVtSGPaSaz5WS4filwNLRXIk83zXhI72d)blSXEOamv1FeOmka6Z5QAc1LNskdR8ct5FUcr6rnqxViL3G72d)blSXEOamv1FeOmka6Z5QAc1LNskdR8ct5FUcr6rn0wzhee1aD9IuwjuFnL)5keP3OKz3X5fMYQRwd9pxHi9gLmbiudcTugW14)bl0w9ZvisVrjZHnpmLYWwofw4FGlCoal8pRWFWcZD7H)Gf2ypuaMQ6pcugfa95CvnH6YtjLHvEHP8pxHi9OgARSdcIAGUErkVjQVMY)CfI0B20S748ctz1vRH(NRqKEZMMaeQbHwkd4A8)GfAR(5keP3SP5WMhMszylNcl8pWfohGf(Nv4pyH5UrzwIXoHjw(5kePhZIpelf8zXxpm1)l4ADhwaPNcpbYIJzbwSSWel43Fw(5kePhByHfa0ZcqFoxvtS8qwSwwCml)o1HfxJHSuebYc2McNRzz3lq9vinC3E4pyHn2dfGPQ(JaLrbqFoxvtOU8uszyLxyk)ZvispQH2k7GGOgORxKYwlQVMYKIToBBc0CfomR3v1uwXwE9R0mib8cuscPyRZ2ManuQDNHCDgoGLxbkjHuS1zBtGgmCP10)xHmpl1oC3E4pyHn2dfGPQ(JaLrrkewiEvUbNuUBp8hSWg7HcWuv)rGYOWY4)oQ1xr5aOYkTbQVMY9OG(SXKrVkFYfHQpjHc6ZgtMRYyO2NKekOpBmzUkRc)9KekOpBmz8QtUiu995U5Urzw2YHco(zztwqjg)3zXlqwCwa8(GxdsIfyXcGyWIL73zj2hY9NLTGtS4filXd2LyWcCybW7t7gIf4VtJLdtC3E4pyHnqBQObbkJclJ)7O(Ak3Jc6Zgtg9Q8jxeQ(KekOpBmzUkJHAFssOG(SXK5QSk83tsOG(SXKXRo5Iq13hT9qankzSm(VJ2k7HaA20yz8FN72d)blSbAtfniqzuGFFA3qOwFfLdGkRquFnLTAwf1GdsYO6AVcug2YUwN)9RqItsSkabsLxVPoK7FU5usIvyBsRZVpiPhBWVpnxRvwPKeRExt1Bk)xdHZQU2RazOYv1eysspkOpBmzWqTp5Iq1NKqb9zJjZvz9Q8jjHc6ZgtMRYQWFpjHc6ZgtgV6KlcvFFUBp8hSWgOnv0GaLrb(9bVgKeQ1xr5aOYke1xt5zvudoijJQR9kqzyl7AD(3VcjgDacKkVEtDi3)CZj0yBsRZVpiPhBWVpnxRvwjUBUBugLzrXrffwpbYcbKMoS8xkXYVtS4HhoSCywCG(PDvnz4U9WFWcRmgQ9jRsEk3Th(dwyeOmkcUwN9WFWkRp8J6YtjLH2urdQX)CHxzLq91u(VuA7EBIWE4pyzSm(VBco(Z)LsiWd)bld(9PDdzco(Z)Ls95UrzwaqpMLUavCwGflwhbSy5(D46zbCU2ZIxGSy5(Dwa8(OHdilEbYYMiGf4VtJLdtC3E4pyHrGYOaOpNRQjuxEkP8HZoKqnqxViLX2KwNFFqsp2GFFAUwhNsO7z17AQEd(9rdhqdvUQMatsExt1BWpP1(KbNR9gQCvnb2pjbBtAD(9bj9yd(9P5ADCBYDJYSaGEmlbn5ajwSStflaEFA3qSe8IL97zzteWY7ds6XSyz)c7SCywgsta96zPbhw(DIffpOpBmXYdzrLyXEOgndbYIxGSyz)c7S0oTMgwEilbh)C3E4pyHrGYOaOpNRQjuxEkP8HZbn5ajud01lszSnP153hK0Jn43N2nuCkXDJYSGs2NZv1el)U)Se2PaIywUglDGlw8Hy5kwCwqgaz5HS4aHhil)oXc((L)hSyXYonelol)CfI0Zc9bwomllmbYYvSOsVfIkwco(XC3E4pyHrGYOaOpNRQjuxEkP8vzKbqud01lsz7HaMrgankzsHWQDdLKypeWmYaOrjdEvTBOKe7HaMrgankzWVp41GKssShcygza0OKb)(0CTojXEiGzKbqJsM2A6KHTmPxfLKypeqZ4aPcUW52qvS6KKOUAntWZxfmdL6xHvwD1AMGNVkyaxJ)hSssa6Z5QAYC4SdjUBuML4htSepAW0G4vizXY97SOGUGIyQcSahw82tdlkawaHisSCflkOlOiMQa3Th(dwyeOmkuPbtdIxHe1xt5E9SkabsLxVPoK7FU5usIvbiudcTuMaSacrKY)oLX23Cp2SS7JwD1AMGNVkygk1VchNskeTvbiqQ86naP637mjjbiqQ86naP637mOvxTMj45RcMLnA1vRzghivWfo3gQIvhZYgDp1vRzghivWfo3gQIvhZqP(v4TvsPUwHi8SkQbhKKbFvBPZ7DWpnNNKOUAntWZxfmdL6xH3wjLssucLITjToV74N2wjJcvy)(Ob6Z5QAYCvgzaK7gLzzlHplwUFNfNff0fuetvGLF3FwoCPONfNLTCPX(WI9adSahwSStfl)oXs7qU)SCywCv46z5HSqfi3Th(dwyeOmkSH)bluFnL7PUAntWZxfmdL6xHJtjfIUNvZQOgCqsg8vTLoV3b)0CEsI6Q1mJdKk4cNBdvXQJzOu)k82kTvD9MiS6Q1mQAieuVWVzzJwD1AMXbsfCHZTHQy1XSS7NKOcXy0Td5(Nhk1VcV9MkSpAG(CUQMmxLrga5UrzwuGRdlT)eMfl70Vtdll8vizrbWcierILcAHflNwZIR1qlS0bUy5HSG)tRzj44NLFNyb7PelEkCvplWglkawaHisiqbDbfXufyj44hZD7H)GfgbkJcG(CUQMqD5PKYbybeIiLbjCNkGAGUErkhOt3Rx7qU)5Hs9RWDTskSRdqOgeAPmbpFvWmuQFfUpkvP4BJ(khOt3Rx7qU)5Hs9RWDTskSRdqOgeAPmbybeIiL)DkJTV5ESbCn(FWQRdqOgeAPmbybeIiL)DkJTV5ESzOu)kCFuQsX3g9rB14hyMas1BCqqSHq1HFCssac1GqlLj45RcMHs9RWXD1tJnu7pbMBhY9ppuQFfojzwf1GdsYeinH)Z1zS9n3JrhGqni0szcE(QGzOu)kCCwFJKKaeQbHwktawaHis5FNYy7BUhBgk1Vch3vpn2qT)eyUDi3)8qP(v4UwPnssSkabsLxVPoK7FU5e3nkZs8JjqwEilGK27WYVtSSWosIfyJff0fuetvGfl7uXYcFfswaHlvnXcSyzHjw8cKf7Has1ZYc7ijwSStflEXIdcYcbKQNLdZIRcxplpKfWJ4U9WFWcJaLrbqFoxvtOU8us5ayoalW7pyHAGUErk3RDi3)8qP(v44usHjjJFGzcivVXbbXMRItHB0hDVE9ifBD22eOHsT7mKRZWbS8kqO7fGqni0szOu7od56mCalVcKzOu)k82kHq3ijjabsLxVbiv)ENbDac1GqlLHsT7mKRZWbS8kqMHs9RWBRecDRqqpLucHNvrn4GKm4RAlDEVd(P58(9rBvac1GqlLHsT7mKRZWbS8kqMHCWo9tsifBD22eObdxAn9)viZZsTd6EwfGaPYR3uhY9p3CkjjaHAqOLYGHlTM()kK5zP2jBDRvHX3gkzgk1VcVTskzT9ts6fGqni0szuPbtdIxH0mKd2jjXQXdK5hOw3hDVEKIToBBc0CfomR3v1uwXwE9R0mib8ce6EbiudcTuMRWHz9UQMYk2YRFLMbjGxGmd5GDss8WFWYCfomR3v1uwXwE9R0mib8cKb8WUQMa73pjPhPyRZ2Man4DheAHaZWrndB5hoPu9OdqOgeAPmpCsP6jW8v4d5(NTUcvO13ujZqP(v4(jj96b0NZv1Kbw5fMY)CfI0RSsjja95CvnzGvEHP8pxHi9kB9(O79ZvisVrjZqoyNCac1GqlvsYpxHi9gLmbiudcTuMHs9RWXD1tJnu7pbMBhY9ppuQFfURvAJ(jja95CvnzGvEHP8pxHi9kVj6E)CfI0B20mKd2jhGqni0sLK8ZvisVzttac1GqlLzOu)kCCx90yd1(tG52HC)ZdL6xH7AL2OFscqFoxvtgyLxyk)ZvisVYB0VF)KKaeivE9ge7mNx9tsuHym62HC)ZdL6xH3wD1AMGNVkyaxJ)hS4Urzwqj7Z5QAILfMaz5HSasAVdlE1HLFUcr6XS4filbqmlw2PIfl(9xHKLgCyXlwu8L9oCoNf7bg4U9WFWcJaLrbqFoxvtOU8us5FFoToJjcrAYw87rnqxViLTcdxA1Ran)(CADgteI0yOYv1eyss7qU)5Hs9RWXT5gBKKOcXy0Td5(Nhk1VcV9Mkeb9S2n6A1vRz(9506mMiePXGFpGicVz)Ke1vRz(9506mMiePXGFpGyCwp(66EZQOgCqsg8vTLoV3b)0CocRW(C3OmlXpMyrXtT7mKRzzlEalVcelBUbMcywuPgCiwCwuqxqrmvbwwyYWD7H)GfgbkJIfMY3tPOU8uszk1UZqUodhWYRaH6RPCac1GqlLj45RcMHs9RWBV5gOdqOgeAPmbybeIiL)DkJTV5ESzOu)k82BUb6Ea95Cvnz(9506mMiePjBXVpjrD1AMFFoToJjcrAm43digN13ab9Mvrn4GKm4RAlDEVd(P5CegH2VpAG(CUQMmxLrgatsuHym62HC)ZdL6xH326Bf3nkZs8JjwaaxAn9xHKLy2LAhwqOykGzrLAWHyXzrbDbfXufyzHjd3Th(dwyeOmkwykFpLI6YtjLXWLwt)FfY8Su7G6RPCVaeQbHwktWZxfmdL6xH3gHI2QaeivE9gGu97Dg0wfGaPYR3uhY9p3CkjjabsLxVPoK7FU5e6aeQbHwktawaHis5FNYy7BUhBgk1VcVncfDpG(CUQMmbybeIiLbjCNkKKeGqni0szcE(QGzOu)k82i0(jjbiqQ86naP637mO7z1SkQbhKKbFvBPZ7DWpnNJoaHAqOLYe88vbZqP(v4TrOjjQRwZmoqQGlCUnufRoMHs9RWBRK1IGEkeHjfBD22eO5k8pRWdhCg8aEfLvjTUpA1vRzghivWfo3gQIvhZYUFsIkeJr3oK7FEOu)k82BQWKesXwNTnbAOu7od56mCalVce6aeQbHwkdLA3zixNHdy5vGmdL6xHJBZn6JgOpNRQjZvzKbq0wrk26STjqZv4WSExvtzfB51VsZGeWlqjjbiudcTuMRWHz9UQMYk2YRFLMbjGxGmdL6xHJBZnssuHym62HC)ZdL6xH3EZn4Urzw6I2I3bZYctSetXmjMZIL73zrbDbfXuf4U9WFWcJaLrbqFoxvtOU8us5tXaZbybE)blud01lsz1vRzcE(QGzOu)kCCkPq09SAwf1GdsYGVQT059o4NMZtsuxTMzCGubx4CBOkwDmdL6xH3wzL20Sjc6zDewD1AgvnecQx43SS7JGEXxxRqewD1AgvnecQx43SS7JWKIToBBc0Cf(Nv4HdodEaVIYQKwJwD1AMXbsfCHZTHQy1XSS7NKOcXy0Td5(Nhk1VcV9MkmjHuS1zBtGgk1UZqUodhWYRaHoaHAqOLYqP2DgY1z4awEfiZqP(vyUBp8hSWiqzuSWu(Ekf1LNskFfomR3v1uwXwE9R0mib8ceQVMYa95CvnzofdmhGf49hSqd0NZv1K5QmYai3nkZs8JjwMd5(ZIk1GdXsaeZD7H)GfgbkJIfMY3tPOU8usz8UdcTqGz4OMHT8dNuQEuFnL7fGqni0szcE(QGzihSdARcqGu51BQd5(NBoHgOpNRQjZVpNwNXeHinzl(9O7fGqni0szuPbtdIxH0mKd2jjXQXdK5hOw3pjjabsLxVPoK7FU5e6aeQbHwktawaHis5FNYy7BUhBgYb7GUhqFoxvtMaSacrKYGeUtfsscqOgeAPmbpFvWmKd2PFF0GW3Gxv7gY8xaXRqIUhi8n4N0AFYnTpK5VaIxHmjXQ31u9g8tATp5M2hYqLRQjWKeSnP153hK0Jn43N2nuCwVpAq4BsHWQDdz(lG4vir3dOpNRQjZHZoKssMvrn4GKmQU2RaLHTSR15F)kK4Keh)JRZ2ql0eNYB9gjja95CvnzcWcierkds4ovijrD1AgvnecQx43SS7J2ksXwNTnbAUchM17QAkRylV(vAgKaEbkjHuS1zBtGMRWHz9UQMYk2YRFLMbjGxGqhGqni0szUchM17QAkRylV(vAgKaEbYmuQFfooRVbARuxTMj45RcMLDsIkeJr3oK7FEOu)k82w7gC3OmlXy)WSCywCwg)3PHfs7QWXFIflEhwEilPoIelUwZcSyzHjwWV)S8ZvispMLhYIkXI(kcKLLnlwUFNff0fuetvGfVazrbWcierIfVazzHjw(DILnlqwWA4ZcSyjaYY1yrf(7S8ZvispMfFiwGfllmXc(9NLFUcr6XC3E4pyHrGYOyHP89ukg1yn8Xk)ZvisVsO(Ak3dOpNRQjdSYlmL)5keP3kLvcTv)CfI0B20mKd2jhGqni0sLK0dOpNRQjdSYlmL)5kePxzLssa6Z5QAYaR8ct5FUcr6v269r3tD1AMGNVkyw2O7zvacKkVEdqQ(9otsI6Q1mJdKk4cNBdvXQJzOu)kmc6PqeEwf1GdsYGVQT059o4NMZ7VTY)CfI0BuYOUATm4A8)GfA1vRzghivWfo3gQIvhZYojrD1AMXbsfCHZTHQy1jJVQT059o4NMZnl7(jjbiudcTuMGNVkygk1VcJGnJ7NRqKEJsMaeQbHwkd4A8)GfARuxTMj45RcMLn6EwfGaPYR3uhY9p3CkjXkG(CUQMmbybeIiLbjCNk0hTvbiqQ86ni2zoVsscqGu51BQd5(NBoHgOpNRQjtawaHiszqc3PcOdqOgeAPmbybeIiL)DkJTV5ESzzJ2QaeQbHwktWZxfmlB096PUAndf0NnMY6v5JzOu)kCCkTrsI6Q1muqF2ykJHAFmdL6xHJtPn6J2QzvudoijJQR9kqzyl7AD(3VcjojPN6Q1mQU2RaLHTSR15F)kK4C5)Aid(9aIkRWKe1vRzuDTxbkdBzxRZ)(viXzFcErg87bevo(63pjrD1AgeVcCiWmLAdTqtkvFMkAqEXIml7(jjQqmgD7qU)5Hs9RWBV5gjja95CvnzGvEHP8pxHi9kVrF0a95CvnzUkJmaYD7H)GfgbkJIfMY3tPyuJ1WhR8pxHi9BI6RPCpG(CUQMmWkVWu(NRqKERuEt0w9ZvisVrjZqoyNCac1GqlvscqFoxvtgyLxyk)ZvisVYBIUN6Q1mbpFvWSSr3ZQaeivE9gGu97DMKe1vRzghivWfo3gQIvhZqP(vye0tHi8SkQbhKKbFvBPZ7DWpnN3FBL)5keP3SPrD1AzW14)bl0QRwZmoqQGlCUnufRoMLDsI6Q1mJdKk4cNBdvXQtgFvBPZ7DWpnNBw29tscqOgeAPmbpFvWmuQFfgbBg3pxHi9MnnbiudcTugW14)bl0wPUAntWZxfmlB09SkabsLxVPoK7FU5usIva95CvnzcWcierkds4ovOpARcqGu51BqSZCEHUNvQRwZe88vbZYojXQaeivE9gGu97DM(jjbiqQ86n1HC)ZnNqd0NZv1KjalGqePmiH7ub0biudcTuMaSacrKY)oLX23Cp2SSrBvac1GqlLj45RcMLn6E9uxTMHc6Zgtz9Q8XmuQFfooL2ijrD1AgkOpBmLXqTpMHs9RWXP0g9rB1SkQbhKKr11EfOmSLDTo)7xHeNK0tD1Agvx7vGYWw2168VFfsCU8FnKb)EarLvysI6Q1mQU2RaLHTSR15F)kK4SpbVid(9aIkhF973pjrD1AgeVcCiWmLAdTqtkvFMkAqEXIml7KevigJUDi3)8qP(v4T3CJKeG(CUQMmWkVWu(NRqKEL3OpAG(CUQMmxLrga5UrzwIFmHzX1AwG)onSalwwyIL7PumlWILai3Th(dwyeOmkwykFpLI5UrzwI5u4ajw8WFWIf9HFwuDmbYcSybF)Y)dwOqtipm3Th(dwyeOmkMvL9WFWkRp8J6YtjLDiHA8px4vwjuFnLb6Z5QAYC4SdjUBp8hSWiqzumRk7H)GvwF4h1LNskRc9h14FUWRSsO(AkpRIAWbjzuDTxbkdBzxRZ)(viXgsXwNTnbYD7H)GfgbkJIzvzp8hSY6d)OU8usz8ZDZDJYSOaxhwA)jmlw2PFNgw(DILy(qEAW)WonSOUAnwSCAnlnxRzb2ASy5(9Ry53jwkcvplbh)C3E4pyHnoKugOpNRQjuxEkPm4qEA2YP15MR1zyRHAGUErk3tD1AM)sjlWPYGd5PQxbsJzOu)k82idGMuhviydJsjjQRwZ8xkzbovgCipv9kqAmdL6xH32d)bld(9PDdziurH1t5)sjeSHrj09OG(SXK5QSEv(KKqb9zJjdgQ9jxeQ(KekOpBmz8QtUiu997JwD1AM)sjlWPYGd5PQxbsJzzJEwf1GdsY8xkzbovgCipv9kqA4UrzwuGRdlT)eMfl70VtdlaEFWRbjXYHzXcC(Dwco(VcjlqG0WcG3N2nelxXI1SkFyrXd6ZgtC3E4pyHnoKqGYOaOpNRQjuxEkP8HSGdLXVp41GKqnqxViLTIc6ZgtMRYyO2h09W2KwNFFqsp2GFFA3qXPq0VRP6ny4sNHT8Vt5gCi8BOYv1eysc2M0687ds6Xg87t7gkUTQp3nkZs8JjwuaSacrKyXYovS4plAcJz539IffUblDbVLS4fil6Riww2Sy5(DwuqxqrmvbUBp8hSWghsiqzueGfqiIu(3Pm2(M7XO(AkBf4SoqtbZbqm6E9a6Z5QAYeGfqiIugKWDQaARcqOgeAPmbpFvWmKd2jjrD1AMGNVkyw29r3tD1AgkOpBmL1RYhZqP(v44qOjjQRwZqb9zJPmgQ9XmuQFfooeAF09SAwf1GdsYO6AVcug2YUwN)9RqItsuxTMr11EfOmSLDTo)7xHeNl)xdzWVhqmoRNKOUAnJQR9kqzyl7AD(3Vcjo7tWlYGFpGyCwVFsIkeJr3oK7FEOu)k82kTbARcqOgeAPmbpFvWmKd2Pp3nkZs8JjwaSQ2nelxXITxGu6fybwS4vNF)kKS87(ZI(asywuYAXuaZIxGSOjmMfl3VZskCiwEFqspMfVazXFw(DIfQazb2yXzbau7dlkEqF2yIf)zrjRLfmfWSahw0egZYqP(vxHKfhZYdzPGpl7oWRqYYdzzO2q4DwaxZvizXAwLpSO4b9zJjUBp8hSWghsiqzuGxv7gc1HobnLFFqspwzLq91uU3qTHW7UQMssuxTMHc6Zgtzmu7JzOu)k82whnf0NnMmxLXqTpOhk1VcVTswl631u9gmCPZWw(3PCdoe(nu5QAcSp63hK0B(lLYpmdEuCkzTDn2M0687ds6XiyOu)km6EuqF2yYCv2RojjdL6xH3gza0K6OQp3nkZs8JjwaSQ2nelpKLDhiXIZcsnu11S8qwwyILykMjXCUBp8hSWghsiqzuGxv7gc1xtzG(CUQMmNIbMdWc8(dwOdqOgeAPmxHdZ6DvnLvSLx)kndsaVazgYb7GMuS1zBtGMRWHz9UQMYk2YRFLMbjGxG4U9WFWcBCiHaLrb(9P5AnQVMYw9UMQ3GFsR9jdox7nu5QAceDp1vRzWVpnxRnd1gcV7QAcDpSnP153hK0Jn43NMR1BB9KeRMvrn4GKm)LswGtLbhYtvVcKM(jjVRP6ny4sNHT8Vt5gCi8BOYv1eiA1vRzOG(SXugd1(ygk1VcVT1rtb9zJjZvzmu7dA1vRzWVpnxRndL6xH3ERqJTjTo)(GKESb)(0CTooLT2(O7z1SkQbhKKr3j4JJZnnr)viZi1xQnMss(lLqPOuRvHXPUAnd(9P5ATzOu)kmc2Sp63hK0B(lLYpmdEuCkK7gLzbL4(Dwa8Kw7dlX85ApllmXcSyjaYILDQyzO2q4DxvtSOUEwW)P1SyXVNLgCyXA6e8XXSypWalEbYciSu0ZYctSOsn4qSOGyo2WcG)0AwwyIfvQbhIffalGqejwWxfiw(D)zXYP1SypWalEb)DAybW7tZ1AUBp8hSWghsiqzuGFFAUwJ6RP87AQEd(jT2Nm4CT3qLRQjq0QRwZGFFAUwBgQneE3v1e6EwnRIAWbjz0Dc(44Ctt0FfYms9LAJPKK)sjukk1AvyCwBF0VpiP38xkLFyg8O4So3nkZckX97SeZhYtvVcKgwwyIfaVpnxRz5HSGir2SSSz53jwuxTglQDyX1yill8vizbW7tZ1AwGflkKfmfGfiMf4WIMWywgk1V6kKC3E4pyHnoKqGYOa)(0CTg1xt5zvudoijZFPKf4uzWH8u1RaPbn2M0687ds6Xg87tZ164u26O7zL6Q1m)LswGtLbhYtvVcKgZYgT6Q1m43NMR1MHAdH3DvnLK0dOpNRQjd4qEA2YP15MR1zyRHUN6Q1m43NMR1MHs9RWBB9KeSnP153hK0Jn43NMR1XTj631u9g8tATpzW5AVHkxvtGOvxTMb)(0CT2muQFfEBf2VFFUBuMff46Ws7pHzXYo970WIZcG3h8AqsSSWelwoTMLGVWelaEFAUwZYdzP5AnlWwd1S4fillmXcG3h8AqsS8qwqKiBwI5d5PQxbsdl43diYYYM72d)blSXHecugfa95CvnH6YtjLXVpnxRZwG1NBUwNHTgQb66fPSJ)X1zBOfAIl(2OR7P0giS6Q1m)LswGtLbhYtvVcKgd(9aI976EQRwZGFFAUwBgk1VcJWwhLITjToV74NqyRExt1BWpP1(KbNR9gQCvnb2VR7fGqni0szWVpnxRndL6xHryRJsX2KwN3D8ti87AQEd(jT2Nm4CT3qLRQjW(DDpq4BARPtg2YKEvKzOu)kmcRW(O7PUAnd(9P5ATzzNKeGqni0szWVpnxRndL6xH7ZDJYSe)yIfaVp41GKyXY97SeZhYtvVcKgwEilisKnllBw(DIf1vRXIL73HRNfneFfswa8(0CTMLL9FPelEbYYctSa49bVgKelWIfRfbSepyxIbl43diIzzv)PzXAz59bj9yUBp8hSWghsiqzuGFFWRbjH6RPmqFoxvtgWH80SLtRZnxRZWwdnqFoxvtg87tZ16Sfy95MR1zyRH2kG(CUQMmhYcoug)(GxdskjPN6Q1mQU2RaLHTSR15F)kK4C5)Aid(9aIXz9Ke1vRzuDTxbkdBzxRZ)(viXzFcErg87beJZ69rJTjTo)(GKESb)(0CTEBRfnqFoxvtg87tZ16Sfy95MR1zyRXDJYSe)yIfSfFszbdz539NLoWfliPNLuhvSSS)lLyrTdll8viz5EwCmlA)jwCml2qm(u1elWIfnHXS87EXI1zb)EarmlWHfusw4Nfl7uXI1ral43diIzHqL9ne3Th(dwyJdjeOmkCq3(pGugBXNuuh6e0u(9bj9yLvc1xtzR(lG4virBLh(dwgh0T)diLXw8jnd6PosYCvUPpK7Fsci8noOB)hqkJT4tAg0tDKKb)EaXTToAq4BCq3(pGugBXN0mON6ijZqP(v4TTo3nkZsml1gcVZYweewTBiwUglkOlOiMQalhMLHCWoOMLFNgIfFiw0egZYV7flkKL3hK0Jz5kwSMv5dlkEqF2yIfl3VZca4VfqnlAcJz539IfL2Gf4VtJLdtSCflE1HffpOpBmXcCyzzZYdzrHS8(GKEmlQudoelolwZQ8HffpOpBmzyjMdlf9SmuBi8olGR5kKSeZ4kWHazrXtTHwOjLQNLvPjmMLRybau7dlkEqF2yI72d)blSXHecugfPqy1UHqDOtqt53hK0JvwjuFnLhQneE3v1e63hK0B(lLYpmdEuC96PK1IGEyBsRZVpiPhBWVpTBieEtewD1AgkOpBmL1RYhZYUFFemuQFfUpkTNsi4DnvV5TCvofclSHkxvtG9r3laHAqOLYe88vbZqoyh0wboRd0uWCaeJUhqFoxvtMaSacrKYGeUtfsscqOgeAPmbybeIiL)DkJTV5ESzihStsIvbiqQ86n1HC)ZnN6NKGTjTo)(GKESb)(0UH2UxpeAx3tD1AgkOpBmL1RYhZYgH3SFFeUNsi4DnvV5TCvofclSHkxvtG97J2kkOpBmzWqTp5Iq1NK0Jc6ZgtMRYyO2NKKEuqF2yYCvwf(7jjuqF2yYCvwVkF6J2Q31u9gmCPZWw(3PCdoe(nu5QAcmjrD1Ag75sHd456SpbVUq2EPX(ya66ffNYBQWn6JUh2M0687ds6Xg87t7gABL2aH7PecExt1BElxLtHWcBOYv1ey)(OD8pUoBdTqtCkCJUwD1Ag87tZ1AZqP(vyegH2hDpRuxTMbXRahcmtP2ql0Ks1NPIgKxSiZYojHc6ZgtMRYyO2NKeRcqGu51BqSZCE1hTvQRwZmoqQGlCUnufRoz8vTLoV3b)0CUzzZDJYSe)yILTam2SalwcGSy5(D46zj422xHK72d)blSXHecugfn4eOmSLl)xdH6RPSBNd7uarUBp8hSWghsiqzua0NZv1eQlpLuoaMdWc8(dwzhsOgORxKYwboRd0uWCaeJgOpNRQjtamhGf49hSq3RN6Q1m43NMR1MLDsY7AQEd(jT2Nm4CT3qLRQjWKKaeivE9M6qU)5Mt9r3Zk1vRzWqn(Vazw2OTsD1AMGNVkyw2O7z17AQEtBnDYWwM0RImu5QAcmjrD1AMGNVkyaxJ)hSIlaHAqOLY0wtNmSLj9QiZqP(vyeeF9rd0NZv1K53NtRZyIqKMSf)E09SkabsLxVPoK7FU5ussac1GqlLjalGqeP8VtzS9n3JnlB09uxTMb)(0CT2muQFfE7ntsS6DnvVb)Kw7tgCU2BOYv1ey)(OFFqsV5Vuk)Wm4rXPUAntWZxfmGRX)dwi8gMTQFsIkeJr3oK7FEOu)k82QRwZe88vbd4A8)GvFUBuML4htSSfgQIvhwSC)olkOlOiMQa3Th(dwyJdjeOmkghivWfo3gQIvhuFnLvxTMj45RcMHs9RWXPKctsuxTMj45RcgW14)bRTT(gOb6Z5QAYeaZbybE)bRSdjUBuML4htSOGUGIyQcSalwcGSSknHXS4fil6RiwUNLLnlwUFNffalGqejUBp8hSWghsiqzueinH)Z1zxFiRuQEuFnLb6Z5QAYeaZbybE)bRSdj09uxTMj45RcgW14)bR4u26BKKyvacKkVEdqQ(9ot)Ke1vRzghivWfo3gQIvhZYgT6Q1mJdKk4cNBdvXQJzOu)k82BnccWcCDVXEOWHPSRpKvkvV5Vukd01lcb9SsD1AgvnecQx43SSrB17AQEd(9rdhqdvUQMa7ZD7H)Gf24qcbkJIRc(u(FWc1xtzG(CUQMmbWCawG3FWk7qI7gLzj(XelkEQn0cnSepybYcSyjaYIL73zbW7tZ1Aww2S4filyhiXsdoSSLln2hw8cKff0fuetvG72d)blSXHecugfuQn0cnzvybI6RPSkeJrF1tJnu7pbMBhY9ppuQFfEBLuyssp1vRzSNlfoGNRZ(e86cz7Lg7JbORx02BQWnssuxTMXEUu4aEUo7tWRlKTxASpgGUErXP8MkCJ(OvxTMb)(0CT2SSr3laHAqOLYe88vbZqP(v44S2nssaN1bAkyoaI7ZDJYSeZsTHW7S00(qSalww2S8qwSolVpiPhZIL73HRNff0fuetvGfv6kKS4QW1ZYdzHqL9nelEbYsbFwGaPj422xHK72d)blSXHecugf4N0AFYnTpeQdDcAk)(GKESYkH6RP8qTHW7UQMq)xkLFyg8O4usHOX2KwNFFqsp2GFFA3qBBTOD7CyNciIUN6Q1mbpFvWmuQFfooL2ijXk1vRzcE(QGzz3N7gLzj(XelBbOIZY1y5k8bsS4flkEqF2yIfVazrFfXY9SSSzXY97S4SSLln2hwShyGfVazPlGU9FajwayXNuUBp8hSWghsiqzu0wtNmSLj9QiuFnLPG(SXK5QSxDqRUAnJ9CPWb8CD2NGxxiBV0yFmaD9I2EtfUb6EGW34GU9FaPm2IpPzqp1rsM)ciEfYKeRcqGu51BkkmqnCatsW2KwNFFqspoUn7JUN6Q1mJdKk4cNBdvXQJzOu)k82BDx3tHi8SkQbhKKbFvBPZ7DWpnN3hT6Q1mJdKk4cNBdvXQJzzNKyL6Q1mJdKk4cNBdvXQJzz3hDpRcqOgeAPmbpFvWSStsuxTM53NtRZyIqKgd(9aIBRKcr3oK7FEOu)k82BUXgOBhY9ppuQFfooL2yJKeRWWLw9kqZVpNwNXeHingQCvnb2hDpmCPvVc087ZP1zmrisJHkxvtGjjbiudcTuMGNVkygk1VchN13Op3nkZs8JjwCwa8(0CTMLT4I(DwShyGLvPjmMfaVpnxRz5WS46HCWoSSSzboS0bUyXhIfxfUEwEilqG0eCBw6cEl5U9WFWcBCiHaLrb(9P5AnQVMYQRwZal63XzBAcK9FWYSSr3tD1Ag87tZ1AZqTHW7UQMssC8pUoBdTqtCB9g95UrzwI5RuBw6cElzrLAWHyrbWcierIfl3VZcG3NMR1S4fil)ovSa49bVgKe3Th(dwyJdjeOmkWVpnxRr91uoabsLxVPoK7FU5eARExt1BWpP1(KbNR9gQCvnbIUhqFoxvtMaSacrKYGeUtfsscqOgeAPmbpFvWSStsuxTMj45RcMLDF0biudcTuMaSacrKY)oLX23Cp2muQFfEBKbqtQJkeoqNUNJ)X1zBOfAqPkCJ(OvxTMb)(0CT2muQFfEBRfTvGZ6anfmhaXC3E4pyHnoKqGYOa)(Gxdsc1xt5aeivE9M6qU)5MtO7b0NZv1KjalGqePmiH7uHKKaeQbHwktWZxfml7Ke1vRzcE(QGzz3hDac1GqlLjalGqeP8VtzS9n3JndL6xH3gHIwD1Ag87tZ1AZYgnf0NnMmxL9QdARa6Z5QAYCil4qz87dEnij0wboRd0uWCaeZDJYSe)yIfaVp41GKyXY97S4flBXf97SypWalWHLRXsh4srGSabstWTzPl4TKfl3VZsh4AyPiu9SeC8ByPlAmKfWvQnlDbVLS4pl)oXcvGSaBS87elOKP637mSOUAnwUglaEFAUwZIf4sdwk6zP5AnlWwJf4Wsh4IfFiwGflBYY7ds6XC3E4pyHnoKqGYOa)(Gxdsc1xtz1vRzGf974Cqt(KbE4dwMLDsspRWVpTBiJBNd7uar0wb0NZv1K5qwWHY43h8Aqsjj9uxTMj45RcMHs9RWBRq0QRwZe88vbZYojPxp1vRzcE(QGzOu)k82idGMuhviCGoDph)JRZ2ql0GsT(g9rRUAntWZxfml7Ke1vRzghivWfo3gQIvNm(Q2sN37GFAo3muQFfEBKbqtQJkeoqNUNJ)X1zBOfAqPwFJ(OvxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYUp6aeivE9gGu97DM(9r3dBtAD(9bj9yd(9P5A92wpjbOpNRQjd(9P5AD2cS(CZ16mS163hTva95CvnzoKfCOm(9bVgKe6EwnRIAWbjz(lLSaNkdoKNQEfinjjyBsRZVpiPhBWVpnxR32695UrzwIFmXYweewywUIfaqTpSO4b9zJjw8cKfSdKyzlS0Aw2IGWILgCyrbDbfXuf4U9WFWcBCiHaLrrrwYPqyH6RPCp1vRzOG(SXugd1(ygk1VchhHkkSEk)xkLK0lS7dscR8MOhkS7dsk)xkTTc7NKe29bjHv269r725WofqK72d)blSXHecugf7UULtHWc1xt5EQRwZqb9zJPmgQ9XmuQFfoocvuy9u(VukjPxy3hKew5nrpuy3hKu(VuABf2pjjS7dscRS17J2TZHDkGi6EQRwZmoqQGlCUnufRoMHs9RWBRq0QRwZmoqQGlCUnufRoMLnARMvrn4GKm4RAlDEVd(P58KeRuxTMzCGubx4CBOkwDml7(C3E4pyHnoKqGYOOT06CkewO(Ak3tD1AgkOpBmLXqTpMHs9RWXrOIcRNY)LsO7fGqni0szcE(QGzOu)kCCkCJKKaeQbHwktawaHis5FNYy7BUhBgk1VchNc3OFssVWUpijSYBIEOWUpiP8FP02kSFssy3hKewzR3hTBNd7uar09uxTMzCGubx4CBOkwDmdL6xH3wHOvxTMzCGubx4CBOkwDmlB0wnRIAWbjzWx1w68Eh8tZ5jjwPUAnZ4aPcUW52qvS6yw295UrzwIFmXckbuXzbwSOGyo3Th(dwyJdjeOmkS4ZCWjdBzsVkI7gLzrbUoS0(tywSSt)onS8qwwyIfaVpTBiwUIfaqTpSyz)c7SCyw8NffYY7ds6XiqjwAWHfcinDyzZnqPSK64NMoSahwSwwa8(GxdsIffp1gAHMuQEwWVhqeZD7H)Gf24qcbkJcG(CUQMqD5PKY43N2nu(QmgQ9b1aD9IugBtAD(9bj9yd(9PDdfN1IGMgcNEPo(PPtgORxecR0gBGs3CJ(iOPHWPN6Q1m43h8Aqszk1gAHMuQ(mgQ9XGFpGik1A7ZDJYSOaxhwA)jmlw2PFNgwEilOeJ)7SaUMRqYYwyOkwD4U9WFWcBCiHaLrbqFoxvtOU8uszlJ)75RYTHQy1b1aD9Iuwjuk2M068UJFA7n76EBy2eH7HTjTo)(GKESb)(0UH6AL6JW9ucbVRP6ny4sNHT8Vt5gCi8BOYv1eicRKrH97JGnmkPqewD1AMXbsfCHZTHQy1XmuQFfM7gLzj(XelOeJ)7SCflaGAFyrXd6ZgtSahwUglfKfaVpTBiwSCAnlT7z5QhYIc6ckIPkWIxDsHdXD7H)Gf24qcbkJclJ)7O(Ak3Jc6Zgtg9Q8jxeQ(KekOpBmz8QtUiu9Ob6Z5QAYC4CqtoqQp6EVpiP38xkLFyg8O4S2KekOpBmz0RYN8v5ntsAhY9ppuQFfEBL2OFsI6Q1muqF2ykJHAFmdL6xH32d)bld(9PDdziurH1t5)sj0QRwZqb9zJPmgQ9XSStsOG(SXK5QmgQ9bTva95CvnzWVpTBO8vzmu7tsI6Q1mbpFvWmuQFfEBp8hSm43N2nKHqffwpL)lLqBfqFoxvtMdNdAYbsOvxTMj45RcMHs9RWBtOIcRNY)LsOvxTMj45RcMLDsI6Q1mJdKk4cNBdvXQJzzJgOpNRQjJLX)98v52qvS6KKyfqFoxvtMdNdAYbsOvxTMj45RcMHs9RWXrOIcRNY)LsC3OmlXpMybW7t7gILRXYvSynRYhwu8G(SXeQz5kwaa1(WIIh0NnMybwSyTiGL3hK0JzboS8qwShyGfaqTpSO4b9zJjUBp8hSWghsiqzuGFFA3qC3OmlBbxR)9zXD7H)Gf24qcbkJIzvzp8hSY6d)OU8us5MR1)(S4U5Urzw2cdvXQdlwUFNff0fuetvG72d)blSrf6VYJdKk4cNBdvXQdQVMYQRwZe88vbZqP(v44usHC3OmlXpMyPlGU9FajwayXNuwSStfl(ZIMWyw(DVyXAzjEWUedwWVhqeZIxGS8qwgQneENfNLTvEtwWVhqKfhZI2FIfhZIneJpvnXcCy5VuIL7zbdz5Ew8zoGeMfusw4NfV90WIZI1ral43diYcHk7Bim3Th(dwyJk0FeOmkCq3(pGugBXNuuh6e0u(9bj9yLvc1xtz1vRzuDTxbkdBzxRZ)(viX5Y)1qg87be3o(qRUAnJQR9kqzyl7AD(3Vcjo7tWlYGFpG42Xh6EwbcFJd62)bKYyl(KMb9uhjz(lG4virBLh(dwgh0T)diLXw8jnd6PosYCvUPpK7p6EwbcFJd62)bKYyl(KM3jxB(lG4vitsaHVXbD7)aszSfFsZ7KRndL6xHJZ69tsaHVXbD7)aszSfFsZGEQJKm43diUT1rdcFJd62)bKYyl(KMb9uhjzgk1VcVTcrdcFJd62)bKYyl(KMb9uhjz(lG4vi7ZDJYSe)yIffalGqejwSC)olkOlOiMQalw2PIfBigFQAIfVazb(70y5WelwUFNfNL4b7smyrD1ASyzNkwajCNkCfsUBp8hSWgvO)iqzueGfqiIu(3Pm2(M7XO(AkBf4SoqtbZbqm6E9a6Z5QAYeGfqiIugKWDQaARcqOgeAPmbpFvWmKd2jjrD1AMGNVkyw29r3tD1Agvx7vGYWw2168VFfsCU8FnKb)EarLJVKe1vRzuDTxbkdBzxRZ)(viXzFcErg87bevo(6NKOcXy0Td5(Nhk1VcVTsBGoaHAqOLYe88vbZqP(v442Q(C3OmlBbOIZIJz53jwA3GFwqgaz5kw(DIfNL4b7smyXYvGqlSahwSC)ol)oXsmJoZ5flQRwJf4WIL73zXzj(qaMcS0fq3(pGelaS4tklEbYIf)EwAWHff0fuetvGLRXY9SybwplQellBwCK(vSOsn4qS87elbqwomlTRo8obYD7H)Gf2Oc9hbkJI2A6KHTmPxfH6RPCVE9uxTMr11EfOmSLDTo)7xHeNl)xdzWVhqmoeAsI6Q1mQU2RaLHTSR15F)kK4SpbVid(9aIXHq7JUNvbiqQ86naP637mjjwPUAnZ4aPcUW52qvS6yw297JUh4SoqtbZbqCssac1GqlLj45RcMHs9RWXPWnss6fGaPYR3uhY9p3CcDac1GqlLjalGqeP8VtzS9n3JndL6xHJtHB0VF)KKEGW34GU9FaPm2IpPzqp1rsMHs9RWXfFOdqOgeAPmbpFvWmuQFfooL2aDacKkVEtrHbQHdy)KKREASHA)jWC7qU)5Hs9RWBhFOTkaHAqOLYe88vbZqoyNKKaeivE9ge7mNxOvxTMbXRahcmtP2ql0Ks1Bw2jjbiqQ86naP637mOvxTMzCGubx4CBOkwDmdL6xH3ERrRUAnZ4aPcUW52qvS6yw2C3OmlkWRaPzbW7JgoGSy5(DwCwkYclXd2LyWI6Q1yXlqwuqxqrmvbwoCPONfxfUEwEilQellmbYD7H)Gf2Oc9hbkJIGxbsNvxTgQlpLug)(OHdiQVMY9uxTMr11EfOmSLDTo)7xHeNl)xdzgk1Vch3wzuysI6Q1mQU2RaLHTSR15F)kK4SpbViZqP(v442kJc7JUxac1GqlLj45RcMHs9RWXTvjj9cqOgeAPmuQn0cnzvybAgk1Vch3wH2k1vRzq8kWHaZuQn0cnPu9zQOb5flYSSrhGaPYR3GyN58QFF0o(hxNTHwOjoLT(gC3OmlX8vQnlaEFWRbjHzXY97S4SepyxIblQRwJf11ZsbFwSStfl2qO(kKS0GdlkOlOiMQalWHLygxboeilaSV5Em3D4pyHnQq)rGYOa)(Gxdsc1xt5EQRwZO6AVcug2YUwN)9RqIZL)RHm43dig3MjjQRwZO6AVcug2YUwN)9RqIZ(e8Im43dig3M9r3RNvbiqQ86n1HC)ZnNssC8pUoBdTqtCkBTB0hDac1GqlLj45RcMHs9RWXTvjjwb0NZv1KjaMdWc8(dwOTkabsLxVbXoZ5vssVaeQbHwkdLAdTqtwfwGMHs9RWXTvOTsD1AgeVcCiWmLAdTqtkvFMkAqEXImlB0biqQ86ni2zoV63hDpRaHVPTMozylt6vrM)ciEfYKeRcqOgeAPmbpFvWmKd2jjXQaeQbHwktawaHis5FNYy7BUhBgYb70N7gLzjMVsTzbW7dEnijmlQudoelkawaHisC3E4pyHnQq)rGYOa)(Gxdsc1xt5EbiudcTuMaSacrKY)oLX23Cp2muQFfEBfI2kWzDGMcMdGy09a6Z5QAYeGfqiIugKWDQqssac1GqlLj45RcMHs9RWBRW(Ob6Z5QAYeaZbybE)bR(OTce(M2A6KHTmPxfz(lG4virhGaPYR3uhY9p3CcTvGZ6anfmhaXOPG(SXK5QSxDq74FCD2gAHM4S2n4UrzwI5WsrplGWNfW1Cfsw(DIfQazb2yjM1bsfCHzzlmufRoOMfW1Cfswq8kWHazHsTHwOjLQNf4WYvS87elAh)SGmaYcSXIxSO4b9zJjUBp8hSWgvO)iqzua0NZv1eQlpLuge(5HuS1nukvpg1aD9IuUN6Q1mJdKk4cNBdvXQJzOu)kCCkmjXk1vRzghivWfo3gQIvhZYUp6EQRwZG4vGdbMPuBOfAsP6ZurdYlwKzOu)k82idGMuhv9r3tD1AgkOpBmLXqTpMHs9RWXHmaAsDuLKOUAndf0NnMY6v5JzOu)kCCidGMuhv95U9WFWcBuH(JaLrbEvTBiuh6e0u(9bj9yLvc1xt5HAdH3DvnH(9bj9M)sP8dZGhfNsiu0UDoStberd0NZv1Kbe(5HuS1nukvpM72d)blSrf6pcugfPqy1UHqDOtqt53hK0JvwjuFnLhQneE3v1e63hK0B(lLYpmdEuCkzDJcr725WofqenqFoxvtgq4NhsXw3qPu9yUBp8hSWgvO)iqzuGFsR9j30(qOo0jOP87ds6XkReQVMYd1gcV7QAc97ds6n)Ls5hMbpkoLqOiyOu)kmA3oh2PaIOb6Z5QAYac)8qk26gkLQhZDJYSSfGXMfyXsaKfl3Vdxplb32(kKC3E4pyHnQq)rGYOObNaLHTC5)AiuFnLD7CyNciYDJYSO4P2ql0Ws8Gfilw2PIfxfUEwEilu90WIZsrwyjEWUedwSCfi0clEbYc2bsS0GdlkOlOiMQa3Th(dwyJk0FeOmkOuBOfAYQWce1xt5EuqF2yYOxLp5Iq1NKqb9zJjdgQ9jxeQ(KekOpBmz8QtUiu9jjQRwZO6AVcug2YUwN)9RqIZL)RHmdL6xHJBRmkmjrD1Agvx7vGYWw2168VFfsC2NGxKzOu)kCCBLrHjjo(hxNTHwOjUTEd0biudcTuMGNVkygYb7G2kWzDGMcMdG4(O7fGqni0szcE(QGzOu)kCCwFJKKaeQbHwktWZxfmd5GD6NKOcXy0x90yd1(tG52HC)ZdL6xH3wPn4Urzw2cqfNL5qU)SOsn4qSSWxHKff0fUBp8hSWgvO)iqzu0wtNmSLj9QiuFnLdqOgeAPmbpFvWmKd2bnqFoxvtMayoalW7pyHUNJ)X1zBOfAIBR3aTvbiqQ86n1HC)ZnNsscqGu51BQd5(NBoH2X)46Sn0cnBBTB0hTvbiqQ86naP637mO7zvacKkVEtDi3)CZPKKaeQbHwktawaHis5FNYy7BUhBgYb70hTvGZ6anfmhaXC3OmlkOlOiMQalw2PIf)zzR3abS0f8wYsp4OHwOHLF3lwS2nyPl4TKfl3VZIcGfqiIuFwSC)oC9SOH4RqYYFPelxXs80qiOEHFw8cKf9vellBwSC)olkawaHisSCnwUNfloMfqc3Pcei3Th(dwyJk0FeOmka6Z5QAc1LNskhaZbybE)bRSk0Fud01lszRaN1bAkyoaIrd0NZv1KjaMdWc8(dwO71ZX)46Sn0cnXT1BGUN6Q1miEf4qGzk1gAHMuQ(mv0G8Ifzw2jjwfGaPYR3GyN58QFsI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWQFsIkeJrF1tJnu7pbMBhY9ppuQFfEB1vRzcE(QGbCn(FWkjjabsLxVPoK7FU5uF09SkabsLxVPoK7FU5ussph)JRZ2ql0ST1Ursci8nT10jdBzsVkY8xaXRq2hDpG(CUQMmbybeIiLbjCNkKKeGqni0szcWcierk)7ugBFZ9yZqoyN(95U9WFWcBuH(JaLrrG0e(pxND9HSsP6r91ugOpNRQjtamhGf49hSYQq)5U9WFWcBuH(JaLrXvbFk)pyH6RPmqFoxvtMayoalW7pyLvH(ZDJYSO44)s9NWSSdTWs6kSZsxWBjl(qSG0VIazXMgwWuawGC3E4pyHnQq)rGYOaOpNRQjuxEkPSJT3sAaqbud01lszkOpBmzUkRxLpiC8Hs9WFWYGFFA3qgcvuy9u(Vucbwrb9zJjZvz9Q8bH7HqrW7AQEdgU0zyl)7uUbhc)gQCvnbIWwVpk1d)blJLX)DdHkkSEk)xkHGnmBIsX2KwN3D8tC3OmlX8vQnlaEFWRbjHzXYovS87elTd5(ZYHzXvHRNLhYcvGOML2qvS6WYHzXvHRNLhYcvGOMLoWfl(qS4plB9giGLUG3swUIfVyrXd6ZgtOMff0fuetvGfTJFmlEb)DAyj(qaMcywGdlDGlwSaxAqwGaPj42SKchILF3lw4eL2GLUG3swSStflDGlwSaxAWsrplaEFWRbjXsbTWD7H)Gf2Oc9hbkJc87dEnijuFnL7PcXy0x90yd1(tG52HC)ZdL6xH32Ats6PUAnZ4aPcUW52qvS6ygk1VcVnYaOj1rfchOt3ZX)46Sn0cnOuRVrF0QRwZmoqQGlCUnufRoMLD)(jj9C8pUoBdTqdca6Z5QAY4y7TKgauaHvxTMHc6Zgtzmu7JzOu)kmcaHVPTMozylt6vrM)ciIZdL6xHWBAuyCkP0gjjo(hxNTHwObba95CvnzCS9wsdakGWQRwZqb9zJPSEv(ygk1VcJaq4BARPtg2YKEvK5VaI48qP(vi8MgfgNskTrF0uqF2yYCv2RoO7zL6Q1mbpFvWSStsS6DnvVb)(OHdOHkxvtG9r3RNvbiudcTuMGNVkyw2jjbiqQ86ni2zoVqBvac1GqlLHsTHwOjRclqZYUFssacKkVEtDi3)CZP(O7zvacKkVEdqQ(9otsIvQRwZe88vbZYojXX)46Sn0cnXT1B0pjP37AQEd(9rdhqdvUQMarRUAntWZxfmlB09uxTMb)(OHdOb)EaXTTEsIJ)X1zBOfAIBR3OF)Ke1vRzcE(QGzzJ2k1vRzghivWfo3gQIvhZYgTvVRP6n43hnCanu5QAcK7gLzj(XelBrqyHz5kwSMv5dlkEqF2yIfVazb7ajwIz21neSfwAnlBrqyXsdoSOGUGIyQcC3E4pyHnQq)rGYOOil5uiSq91uUN6Q1muqF2ykRxLpMHs9RWXrOIcRNY)Lsjj9c7(GKWkVj6Hc7(GKY)LsBRW(jjHDFqsyLTEF0UDoStbe5U9WFWcBuH(JaLrXURB5uiSq91uUN6Q1muqF2ykRxLpMHs9RWXrOIcRNY)LsO7fGqni0szcE(QGzOu)kCCkCJKKaeQbHwktawaHis5FNYy7BUhBgk1VchNc3OFssVWUpijSYBIEOWUpiP8FP02kSFssy3hKewzR3hTBNd7uarUBp8hSWgvO)iqzu0wADofcluFnL7PUAndf0NnMY6v5JzOu)kCCeQOW6P8FPe6EbiudcTuMGNVkygk1VchNc3ijjaHAqOLYeGfqiIu(3Pm2(M7XMHs9RWXPWn6NK0lS7dscR8MOhkS7dsk)xkTTc7NKe29bjHv269r725WofqK7gLzbLaQ4SalwcGC3E4pyHnQq)rGYOWIpZbNmSLj9QiUBuML4htSa49PDdXYdzXEGbwaa1(WIIh0NnMyboSyzNkwUIfyP7WI1SkFyrXd6ZgtS4fillmXckbuXzXEGbmlxJLRyXAwLpSO4b9zJjUBp8hSWgvO)iqzuGFFA3qO(Aktb9zJjZvz9Q8jjHc6Zgtgmu7tUiu9jjuqF2yY4vNCrO6tsuxTMXIpZbNmSLj9QiZYgT6Q1muqF2ykRxLpMLDssp1vRzcE(QGzOu)k82E4pyzSm(VBiurH1t5)sj0QRwZe88vbZYUp3Th(dwyJk0FeOmkSm(VZD7H)Gf2Oc9hbkJIzvzp8hSY6d)OU8us5MR1)(S4U5Urzwa8(GxdsILgCyjfcKsP6zzvAcJzzHVcjlXd2LyWD7H)Gf20CT(3NLY43h8AqsO(AkB1SkQbhKKr11EfOmSLDTo)7xHeBifBD22ei3nkZIcC8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDuXc4A8)GflhML97nSayvTBiwgk1VcZs6s)NT(iqwEilP(h2zjfcR2nelGRX)dwC3E4pyHnnxR)9zHaLrbEvTBiuh6e0u(9bj9yLvc1xtzq4BsHWQDdzgk1Vch3qP(vyeEZnrPkfFC3E4pyHnnxR)9zHaLrrkewTBiUBUBuML4htSa49bVgKelpKfejYMLLnl)oXsmFipv9kqAyrD1ASCnwUNflWLgKfcv23qSOsn4qS0U6W7xHKLFNyPiu9SeC8ZcCy5HSaUsTzrLAWHyrbWcierI72d)blSb)kJFFWRbjH6RP8SkQbhKK5VuYcCQm4qEQ6vG0GUhf0NnMmxL9QdAR61tD1AM)sjlWPYGd5PQxbsJzOu)kCCE4pyzSm(VBiurH1t5)sjeSHrj09OG(SXK5QSk83tsOG(SXK5QmgQ9jjHc6Zgtg9Q8jxeQ((jjQRwZ8xkzbovgCipv9kqAmdL6xHJZd)bld(9PDdziurH1t5)sjeSHrj09OG(SXK5QSEv(KKqb9zJjdgQ9jxeQ(KekOpBmz8QtUiu997NKyL6Q1m)LswGtLbhYtvVcKgZYUFssp1vRzcE(QGzzNKa0NZv1KjalGqePmiH7uH(OdqOgeAPmbybeIiL)DkJTV5ESzihSd6aeivE9M6qU)5Mt9r3ZQaeivE9ge7mNxjjbiudcTugk1gAHMSkSandL6xHJl(6JUN6Q1mbpFvWSStsSkaHAqOLYe88vbZqoyN(C3OmlXpMyPlGU9FajwayXNuwSStfl)onelhMLcYIh(diXc2IpPOMfhZI2FIfhZIneJpvnXcSybBXNuwSC)olBYcCyPrwOHf87beXSahwGflolwhbSGT4tklyil)U)S87elfzHfSfFszXN5asywqjzHFw82tdl)U)SGT4tkleQSVHWC3E4pyHn4hbkJch0T)diLXw8jf1HobnLFFqspwzLq91u2kq4BCq3(pGugBXN0mON6ijZFbeVcjAR8WFWY4GU9FaPm2IpPzqp1rsMRYn9HC)r3Zkq4BCq3(pGugBXN08o5AZFbeVczsci8noOB)hqkJT4tAENCTzOu)kCCkSFsci8noOB)hqkJT4tAg0tDKKb)EaXTToAq4BCq3(pGugBXN0mON6ijZqP(v4TToAq4BCq3(pGugBXN0mON6ijZFbeVcj3nkZs8JjmlkawaHisSCnwuqxqrmvbwomllBwGdlDGlw8HybKWDQWvizrbDbfXufyXY97SOaybeIiXIxGS0bUyXhIfvsdTWI1UblDbVLC3E4pyHn4hbkJIaSacrKY)oLX23Cpg1xtzRaN1bAkyoaIr3RhqFoxvtMaSacrKYGeUtfqBvac1GqlLj45RcMHCWoOTAwf1GdsYypxkCapxN9j41fY2ln2NKe1vRzcE(QGzz3hTJ)X1zBOfA2wzRDd09uxTMHc6Zgtz9Q8XmuQFfooL2ijrD1AgkOpBmLXqTpMHs9RWXP0g9tsuHym62HC)ZdL6xH3wPnqBvac1GqlLj45RcMHCWo95UrzwuaSaV)Gfln4WIR1SacFml)U)SK6isywWRHy53PoS4dvk6zzO2q4DcKfl7uXsmRdKk4cZYwyOkwDyz3XSOjmMLF3lwuilykGzzOu)QRqYcCy53jwqSZCEXI6Q1y5WS4QW1ZYdzP5AnlWwJf4WIxDyrXd6ZgtSCywCv46z5HSqOY(gI72d)blSb)iqzua0NZv1eQlpLuge(5HuS1nukvpg1aD9IuUN6Q1mJdKk4cNBdvXQJzOu)kCCkmjXk1vRzghivWfo3gQIvhZYUpARuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYgDp1vRzq8kWHaZuQn0cnPu9zQOb5flYmuQFfEBKbqtQJQ(O7PUAndf0NnMYyO2hZqP(v44qganPoQssuxTMHc6Zgtz9Q8XmuQFfooKbqtQJQKKEwPUAndf0NnMY6v5JzzNKyL6Q1muqF2ykJHAFml7(OT6DnvVbd14)cKHkxvtG95UrzwuaSaV)Gfl)U)Se2PaIywUglDGlw8HybUE8bsSqb9zJjwEilWs3Hfq4ZYVtdXcCy5qwWHy53pmlwUFNfaqn(VaXD7H)Gf2GFeOmka6Z5QAc1LNskdc)mC94dKYuqF2yc1aD9IuUNvQRwZqb9zJPmgQ9XSSrBL6Q1muqF2ykRxLpMLD)KK31u9gmuJ)lqgQCvnbYD7H)Gf2GFeOmksHWQDdH6qNGMYVpiPhRSsO(AkpuBi8URQj09uxTMHc6Zgtzmu7JzOu)kCCdL6xHtsuxTMHc6Zgtz9Q8XmuQFfoUHs9RWjja95CvnzaHFgUE8bszkOpBm1h9qTHW7UQMq)(GKEZFPu(HzWJItPnr725WofqenqFoxvtgq4NhsXw3qPu9yUBp8hSWg8JaLrbEvTBiuh6e0u(9bj9yLvc1xt5HAdH3DvnHUN6Q1muqF2ykJHAFmdL6xHJBOu)kCsI6Q1muqF2ykRxLpMHs9RWXnuQFfojbOpNRQjdi8ZW1Jpqktb9zJP(OhQneE3v1e63hK0B(lLYpmdEuCkTjA3oh2PaIOb6Z5QAYac)8qk26gkLQhZD7H)Gf2GFeOmkWpP1(KBAFiuh6e0u(9bj9yLvc1xt5HAdH3DvnHUN6Q1muqF2ykJHAFmdL6xHJBOu)kCsI6Q1muqF2ykRxLpMHs9RWXnuQFfojbOpNRQjdi8ZW1Jpqktb9zJP(OhQneE3v1e63hK0B(lLYpmdEuCkHqr725WofqenqFoxvtgq4NhsXw3qPu9yUBuML4htSSfGXMfyXsaKfl3Vdxplb32(kKC3E4pyHn4hbkJIgCcug2YL)RHq91u2TZHDkGi3nkZs8JjwIzCf4qGSaW(M7XSy5(Dw8QdlAyHKfQGlK7SOD8Ffswu8G(SXelEbYYpDy5HSOVIy5Eww2Sy5(Dw2YLg7dlEbYIc6ckIPkWD7H)Gf2GFeOmkOuBOfAYQWce1xt5E9uxTMHc6Zgtzmu7JzOu)kCCkTrsI6Q1muqF2ykRxLpMHs9RWXP0g9rhGqni0szcE(QGzOu)kCCwFd09uxTMXEUu4aEUo7tWRlKTxASpgGUErBVP1UrsIvZQOgCqsg75sHd456SpbVUq2EPX(yifBD22ey)(jjQRwZypxkCapxN9j41fY2ln2hdqxVO4uEZTAJKe1vRzcE(QGzOu)kCCkTb3nkZs8JjwuqxqrmvbwSC)olkawaHisOiMXvGdbYca7BUhZIxGSaclf9SabsJL5EILTCPX(WcCyXYovSepnecQx4NflWLgKfcv23qSOsn4qSOGUGIyQcSqOY(gcZD7H)Gf2GFeOmka6Z5QAc1LNskhaZbybE)bRm(rnqxViLTcCwhOPG5aignqFoxvtMayoalW7pyHUxVaeQbHwkdLA3zixNHdy5vGmdL6xH3wje6wHGEkPecpRIAWbjzWx1w68Eh8tZ59rtk26STjqdLA3zixNHdy5vG6NK44FCD2gAHM4uER3aDpRExt1BARPtg2YKEvKHkxvtGjjQRwZe88vbd4A8)GvCbiudcTuM2A6KHTmPxfzgk1VcJG4RpAq4BWRQDdzgk1VchNsBIge(MuiSA3qMHs9RWXfFO7bcFd(jT2NCt7dzgk1Vchx8LKy17AQEd(jT2NCt7dzOYv1eyF0a95Cvnz(9506mMiePjBXVhDVaeQbHwkdLAdTqtwfwGMLDsIvbiqQ86ni2zoV6J(9bj9M)sP8dZGhfN6Q1mbpFvWaUg)pyHWBy2QKevigJUDi3)8qP(v4TvxTMj45RcgW14)bRKKaeivE9M6qU)5MtjjQRwZOQHqq9c)MLnA1vRzu1qiOEHFZqP(v4TvxTMj45RcgW14)ble0BRr4zvudoijJ9CPWb8CD2NGxxiBV0yFmKIToBBcSFF0wPUAntWZxfmlB09SkabsLxVPoK7FU5ussac1GqlLjalGqeP8VtzS9n3Jnl7KevigJUDi3)8qP(v4TdqOgeAPmbybeIiL)DkJTV5ESzOu)kmcqOjjTd5(Nhk1VcJsrPkfFBST6Q1mbpFvWaUg)py1N72d)blSb)iqzua0NZv1eQlpLuoaMdWc8(dwz8JAGUErkBf4SoqtbZbqmAG(CUQMmbWCawG3FWcDVEbiudcTugk1UZqUodhWYRazgk1VcVTsi0Tcb9usjeEwf1GdsYGVQT059o4NMZ7JMuS1zBtGgk1UZqUodhWYRa1pjXX)46Sn0cnXP8wVb6Ew9UMQ30wtNmSLj9QidvUQMatsuxTMj45RcgW14)bR4cqOgeAPmT10jdBzsVkYmuQFfgbXxF0GW3Gxv7gYmuQFfoU4dni8nPqy1UHmdL6xHJBRr3de(g8tATp5M2hYmuQFfooL2ijXQ31u9g8tATp5M2hYqLRQjW(Ob6Z5QAY87ZP1zmrist2IFp6EQRwZG4vGdbMPuBOfAsP6ZurdYlwKzzNKyvacKkVEdIDMZR(OFFqsV5Vuk)Wm4rXPUAntWZxfmGRX)dwi8gMTkjrfIXOBhY9ppuQFfEB1vRzcE(QGbCn(FWkjjabsLxVPoK7FU5usI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWcb92AeEwf1GdsYypxkCapxN9j41fY2ln2hdPyRZ2Ma73hTvQRwZe88vbZYgDpRcqGu51BQd5(NBoLKeGqni0szcWcierk)7ugBFZ9yZYojrfIXOBhY9ppuQFfE7aeQbHwktawaHis5FNYy7BUhBgk1VcJaeAsIkeJr3oK7FEOu)kmkfLQu8TX2QRwZe88vbd4A8)GvFUBuML4htS87elOKP637mSy5(DwCwuqxqrmvbw(D)z5WLIEwAdmLLTCPX(WD7H)Gf2GFeOmkghivWfo3gQIvhuFnLvxTMj45RcMHs9RWXPKctsuxTMj45RcgW14)bRTT(MOb6Z5QAYeaZbybE)bRm(5U9WFWcBWpcugfbst4)CD21hYkLQh1xtzG(CUQMmbWCawG3FWkJF09uxTMj45RcgW14)bR4u26BMKyvacKkVEdqQ(9ot)Ke1vRzghivWfo3gQIvhZYgT6Q1mJdKk4cNBdvXQJzOu)k82BnccWcCDVXEOWHPSRpKvkvV5Vukd01lcb9SsD1AgvnecQx43SSrB17AQEd(9rdhqdvUQMa7ZD7H)Gf2GFeOmkUk4t5)bluFnLb6Z5QAYeaZbybE)bRm(5Urzwqj7Z5QAILfMazbwS4QN((JWS87(ZIfVEwEilQelyhibYsdoSOGUGIyQcSGHS87(ZYVtDyXhQEwS44NazbLKf(zrLAWHy53PuUBp8hSWg8JaLrbqFoxvtOU8uszSdKYn4KdE(QaQb66fPSvbiudcTuMGNVkygYb7KKyfqFoxvtMaSacrKYGeUtfqhGaPYR3uhY9p3CkjbCwhOPG5aiM7gLzj(XeMLTauXz5ASCflEXIIh0NnMyXlqw(5imlpKf9vel3ZYYMfl3VZYwU0yFqnlkOlOiMQalEbYsxaD7)asSaWIpPC3E4pyHn4hbkJI2A6KHTmPxfH6RPmf0NnMmxL9QdA3oh2PaIOvxTMXEUu4aEUo7tWRlKTxASpgGUErBVP1Ub6EGW34GU9FaPm2IpPzqp1rsM)ciEfYKeRcqGu51BkkmqnCa7JgOpNRQjd2bs5gCYbpFvaDp1vRzghivWfo3gQIvhZqP(v4T36UUNcr4zvudoijd(Q2sN37GFAohbwrk26STjqZv4FwHho4m4b8kkRsADF0QRwZmoqQGlCUnufRoMLDsIvQRwZmoqQGlCUnufRoMLDF09SkabsLxVbXoZ5vssac1GqlLHsTHwOjRclqZqP(v442CJ(C3OmlXpMyzlUOFNfaVpnxRzXEGbmlxJfaVpnxRz5WLIEww2C3E4pyHn4hbkJc87tZ1AuFnLvxTMbw0VJZ20ei7)GLzzJwD1Ag87tZ1AZqTHW7UQM4U9WFWcBWpcugfbVcKoRUAnuxEkPm(9rdhquFnLvxTMb)(OHdOzOu)k82keDp1vRzOG(SXugd1(ygk1VchNctsuxTMHc6Zgtz9Q8XmuQFfoof2hTJ)X1zBOfAIBR3G7gLzjMVsTXS0f8wYIk1GdXIcGfqiIell8viz53jwuaSacrKyjalW7pyXYdzjStbez5ASOaybeIiXYHzXd)Y16oS4QW1ZYdzrLyj44N72d)blSb)iqzuGFFWRbjH6RPCacKkVEtDi3)CZj0a95CvnzcWcierkds4ovaDac1GqlLjalGqeP8VtzS9n3JndL6xH3wHOTcCwhOPG5aignf0NnMmxL9QdAh)JRZ2ql0eN1Ub3nkZs8Jjwa8(0CTMfl3VZcGN0AFyjMpx7zXlqwkilaEF0Wbe1SyzNkwkilaEFAUwZYHzzzJAw6axS4dXYvSynRYhwu8G(SXeln4Ws8HamfWSahwEil2dmWYwU0yFyXYovS4QqGelB9gS0f8wYcCyXbT9)asSGT4tkl7oML4dbykGzzOu)QRqYcCy5WSCfln9HC)nSeB4tS87(ZYQaPHLFNyb7PelbybE)blml3RimlG2ywkA9JRz5HSa49P5AnlGR5kKSeZ6aPcUWSSfgQIvhuZILDQyPdCPiqwW)P1SqfillBwSC)olB9giWX2S0Gdl)oXI2Xpli1qvxJnC3E4pyHn4hbkJc87tZ1AuFnLFxt1BWpP1(KbNR9gQCvnbI2Q31u9g87JgoGgQCvnbIwD1Ag87tZ1AZqTHW7UQMq3tD1AgkOpBmL1RYhZqP(v44Ip0uqF2yYCvwVkFqRUAnJ9CPWb8CD2NGxxiBV0yFmaD9I2EtfUrsI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lkoL3uHBG2X)46Sn0cnXT1BKKacFJd62)bKYyl(KMb9uhjzgk1Vchx8LK4H)GLXbD7)aszSfFsZGEQJKmxLB6d5(3hDac1GqlLj45RcMHs9RWXP0gC3OmlXpMybW7dEnijw2Il63zXEGbmlEbYc4k1MLUG3swSStflkOlOiMQalWHLFNybLmv)ENHf1vRXYHzXvHRNLhYsZ1AwGTglWHLoWLIazj42S0f8wYD7H)Gf2GFeOmkWVp41GKq91uwD1Agyr)ooh0KpzGh(GLzzNKOUAndIxboeyMsTHwOjLQptfniVyrMLDsI6Q1mbpFvWSSr3tD1AMXbsfCHZTHQy1XmuQFfEBKbqtQJkeoqNUNJ)X1zBOfAqPwFJ(iW6i87AQEtrwYPqyzOYv1eiARMvrn4GKm4RAlDEVd(P5C0QRwZmoqQGlCUnufRoMLDsI6Q1mbpFvWmuQFfEBKbqtQJkeoqNUNJ)X1zBOfAqPwFJ(jjQRwZmoqQGlCUnufRoz8vTLoV3b)0CUzzNK0tD1AMXbsfCHZTHQy1XmuQFfEBp8hSm43N2nKHqffwpL)lLqJTjToV74N2EdJ1MKOUAnZ4aPcUW52qvS6ygk1VcVTh(dwglJ)7gcvuy9u(VukjbOpNRQjZPyG5aSaV)Gf6aeQbHwkZv4WSExvtzfB51VsZGeWlqMHCWoOjfBD22eO5kCywVRQPSIT86xPzqc4fO(OvxTMzCGubx4CBOkwDml7KeRuxTMzCGubx4CBOkwDmlB0wfGqni0szghivWfo3gQIvhZqoyNKeRcqGu51Bas1V3z6NK44FCD2gAHM426nqtb9zJjZvzV6WDJYSeJPdlpKLuhrILFNyrLWplWglaEF0WbKf1oSGFpG4viz5Eww2SOyRlGOUdlxXIxDyrXd6ZgtSOUEw2YLg7dlhUEwCv46z5HSOsSypWqGa5U9WFWcBWpcugf43h8AqsO(Ak)UMQ3GFF0Wb0qLRQjq0wnRIAWbjz(lLSaNkdoKNQEfinO7PUAnd(9rdhqZYojXX)46Sn0cnXT1B0hT6Q1m43hnCan43diUT1r3tD1AgkOpBmLXqTpMLDsI6Q1muqF2ykRxLpMLDF0QRwZypxkCapxN9j41fY2ln2hdqxVOT3CR2aDVaeQbHwktWZxfmdL6xHJtPnssScOpNRQjtawaHiszqc3PcOdqGu51BQd5(NBo1N7gLzrXX)L6pHzzhAHL0vyNLUG3sw8HybPFfbYInnSGPaSa5U9WFWcBWpcugfa95CvnH6YtjLDS9wsdakGAGUErktb9zJjZvz9Q8bHJpuQh(dwg87t7gYqOIcRNY)LsiWkkOpBmzUkRxLpiCpekcExt1BWWLodB5FNYn4q43qLRQjqe269rPE4pyzSm(VBiurH1t5)sjeSHXAvikfBtADE3XpHGnmkeHFxt1Bk)xdHZQU2RazOYv1ei3nkZsmFLAZcG3h8AqsSCflolBfcWuGfaqTpSO4b9zJjuZciSu0ZIMEwUNf7bgyzlxASpS0739NLdZYUxGAcKf1oSq3Vtdl)oXcG3NMR1SOVIyboS87elDbVLXT1BWI(kILgCybW7dEniP(OMfqyPONfiqASm3tS4flBXf97SypWalEbYIMEw(DIfxfcKyrFfXYUxGAIfaVpA4aYD7H)Gf2GFeOmkWVp41GKq91u2QzvudoijZFPKf4uzWH8u1RaPbDp1vRzSNlfoGNRZ(e86cz7Lg7JbORx02BUvBKKOUAnJ9CPWb8CD2NGxxiBV0yFmaD9I2EtfUb631u9g8tATpzW5AVHkxvtG9r3Jc6ZgtMRYyO2h0o(hxNTHwObba95CvnzCS9wsdakGWQRwZqb9zJPmgQ9XmuQFfgbGW30wtNmSLj9QiZFbeX5Hs9Rq4nnkmU4BJKekOpBmzUkRxLpOD8pUoBdTqdca6Z5QAY4y7TKgauaHvxTMHc6Zgtz9Q8XmuQFfgbGW30wtNmSLj9QiZFbeX5Hs9Rq4nnkmUTEJ(OTsD1Agyr)ooBttGS)dwMLnARExt1BWVpA4aAOYv1ei6EbiudcTuMGNVkygk1Vch3wLKGHlT6vGMFFoToJjcrAmu5QAceT6Q1m)(CADgteI0yWVhqCBRB9UU3SkQbhKKbFvBPZ7DWpnNJWkSp62HC)ZdL6xHJtPn2aD7qU)5Hs9RWBV5gBKKaoRd0uWCae3hDVaeQbHwkdIxboeygBFZ9yZqP(v442QKeRcqGu51BqSZCE1N7gLzj(XelBrqyHz5kwSMv5dlkEqF2yIfVazb7ajwIz21neSfwAnlBrqyXsdoSOGUGIyQcS4filXmUcCiqwu8uBOfAsP65U9WFWcBWpcugffzjNcHfQVMY9uxTMHc6Zgtz9Q8XmuQFfoocvuy9u(VukjPxy3hKew5nrpuy3hKu(VuABf2pjjS7dscRS17J2TZHDkGiAG(CUQMmyhiLBWjh88vbUBp8hSWg8JaLrXURB5uiSq91uUN6Q1muqF2ykRxLpMHs9RWXrOIcRNY)LsOTkabsLxVbXoZ5vssp1vRzq8kWHaZuQn0cnPu9zQOb5flYSSrhGaPYR3GyN58QFssVWUpijSYBIEOWUpiP8FP02kSFssy3hKewzRNKOUAntWZxfml7(OD7CyNciIgOpNRQjd2bs5gCYbpFvaDp1vRzghivWfo3gQIvhZqP(v4T7PWUEteEwf1GdsYGVQT059o4NMZ7JwD1AMXbsfCHZTHQy1XSStsSsD1AMXbsfCHZTHQy1XSS7ZD7H)Gf2GFeOmkAlToNcHfQVMY9uxTMHc6Zgtz9Q8XmuQFfoocvuy9u(VucTvbiqQ86ni2zoVss6PUAndIxboeyMsTHwOjLQptfniVyrMLn6aeivE9ge7mNx9ts6f29bjHvEt0df29bjL)lL2wH9tsc7(GKWkB9Ke1vRzcE(QGzz3hTBNd7uar0a95CvnzWoqk3Gto45RcO7PUAnZ4aPcUW52qvS6ygk1VcVTcrRUAnZ4aPcUW52qvS6yw2OTAwf1GdsYGVQT059o4NMZtsSsD1AMXbsfCHZTHQy1XSS7ZDJYSe)yIfucOIZcSyjaYD7H)Gf2GFeOmkS4ZCWjdBzsVkI7gLzj(XelaEFA3qS8qwShyGfaqTpSO4b9zJjuZIc6ckIPkWYUJzrtyml)LsS87EXIZckX4)oleQOW6jw0u7zboSalDhwSMv5dlkEqF2yILdZYYM72d)blSb)iqzuGFFA3qO(Aktb9zJjZvz9Q8bTvQRwZmoqQGlCUnufRoMLDscf0NnMmyO2NCrO6tsOG(SXKXRo5Iq1NK0tD1Agl(mhCYWwM0RIml7KeSnP15Dh)02BySwfI2QaeivE9gGu97DMKeSnP15Dh)02BySw0biqQ86naP637m9rRUAndf0NnMY6v5JzzNK0tD1AMGNVkygk1VcVTh(dwglJ)7gcvuy9u(VucT6Q1mbpFvWSS7ZDJYSe)yIfuIX)DwG)onwomXIL9lSZYHz5kwaa1(WIIh0NnMqnlkOlOiMQalWHLhYI9adSynRYhwu8G(SXe3Th(dwyd(rGYOWY4)o3nkZYwW16FFwC3E4pyHn4hbkJIzvzp8hSY6d)OU8us5MR1)(SIaGTPquSvAJnJ(Opkc]] )
    

end