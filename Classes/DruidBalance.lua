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


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20210629, [[dev5AfqikKhbrvxcIkTjs4tqQmkPkNsQQvbOQxbqnliLUfau7Is)cIyysOogjQLbGEMqLMgfkUgKITbqQVbOIXbq4CaeToasMhGY9ir2NeY)GOIshuOOfkuQhcrAIcvOlcPQ2Oqf8riQOAKqurXjPqPvku1lHOImtiv5Maq0ofk5NaqQHcaAPaq4PkLPsHQRkurBfas6RquHXcaSxk6VsAWehMQftspwWKb6YiBwkFgsgTs1Pv1QbGeVgqMnPUTuz3I(nOHlKJdOslxXZHA6QCDLSDi8Dky8quoVeSEHcZxI2pQnv204MBG(rMXcGfdqLlgqdqaPv5IrdangaAUDfIiZTipaKJIm3sVJm3ITR9mqMBrEbn0bnnU5ggUMazUTFxegqHeKO6Apdeag)DblQ)2xQ2hIKy7ApdeaE77qks6aT7xNg5STxtkP6ApdK9q2zUPUE9zSPPQ5gOFKzSayXau5Ib0aeqAvUy0aW4AmMB(62HJ5223HuZT9heKstvZnqchm3ITR9mqSehN1dYXh)kjwaiGeTSaWIbOYC8C8iD3tuegqXXdGzjMGGeilBqTpSeBY7SC8aywq6UNOiqwoFqrx9BSeCmHz5GSeke0u98bfDylhpaMfaeuhebbYYktkqySpfybHpVRQjml9ElzrllrdHOIpFWRbfXcaUiwIgcHfF(GxdkQVLJhaZsmraFqwIgk447tuSGCm(TZY3y5p0Hz52jwmmWeflOFq)ryYYXdGzbaPdeXcsHjciqel3oXYw0p)HzXzr)3Pjw6GdXstti7v1el9(glfGlw2DWeDhl7)XYFSG)UL(8KGlSUalg(BNLydGoMgNfaZcsjnHV31Set9Jk7O8qll)HoqwWa9r9TC8aywaq6arS0bXhlOR9O2V6qD(Ny0XcoqPppeZIhfPlWYbzrfIXS0Eu7hMfyQly5454JzMWZpcKLy7ApdelXeaIESe8KfvILgCLGS4hl73fHbuibjQU2ZabGXFxWI6V9LQ9Hij2U2ZabG3(oKIKoq7(1ProB71KsQU2ZazpKDMB6hFytJBUbsnFPptJBglLnnU5MhUhMMByO2NQk5DMBu6QAc0m2MNzSaOPXn3O0v1eOzSn3GrMBy6m38W9W0CdHpVRQjZneUErMB4isRRNpOOdBXNpnxRzPiwuMffS0JfJy5CnLNfF(OHdOLsxvtGSuwYY5Akpl(iT2Nk48TZsPRQjqw6Zszjl4isRRNpOOdBXNpnxRzPiwaO5giHdZhDpmn32OdZsmHOplWKL4cywm83oCDSaoF7yXtqwm83olBNpA4aYINGSaqaZc82PXWJjZne(utVJm3EC1HK5zgR4AACZnkDvnbAgBZnyK5gMoZnpCpmn3q4Z7QAYCdHRxK5goI0665dk6Ww85t7hILIyrzZnqchMp6EyAUTrhMLGMCeelg2PKLTZN2pelbpzz)pwaiGz58bfDywmS)HDwEmldPjeEES0Gdl3oXc6h0FeMy5GSOsSenuJMHazXtqwmS)HDwAVwtdlhKLGJpZne(utVJm3ECnOjhbzEMXYymnU5gLUQManJT5MhUhMMBQ0GPbOprzUbs4W8r3dtZT4etSeBAW0a0NOyXWF7SG0yIeJndSahw82rdlifMiGarS8jlinMiXyZG5wy(JM3n36XIrSeGiO0ZZMpQ9R2CILYswmILaeQbHgsBaMiGar1BNQ4OF(dBxrS0NffSOUAnBWRFgSd15FIzPiwugnSOGf1vRzhhbLWfU2gkJrb7qD(NywaglgdlkyXiwcqeu65zrq5TxyyPSKLaebLEEweuE7fgwuWI6Q1SbV(zWUIyrblQRwZoockHlCTnugJc2velkyPhlQRwZoockHlCTnugJc2H68pXSamwuwzwaWSGgwaEwMvsn4GIS4pBlDDVa(O5DlLUQMazPSKf1vRzdE9ZGDOo)tmlaJfLvMLYswuMfKWcoI066UJpIfGXIYw0Ggw6BEMXcnMg3CJsxvtGMX2Clm)rZ7MBQRwZg86Nb7qD(NywkIfLrdlkyPhlgXYSsQbhuKf)zBPR7fWhnVBP0v1eilLLSOUAn74iOeUW12qzmkyhQZ)eZcWyrzGdlkyrD1A2XrqjCHRTHYyuWUIyPplLLSOcXywuWs7rTF1H68pXSamwaiAm3ajCy(O7HP5gaeESy4VDwCwqAmrIXMbwUD)y5Xj6owCwaGln2hwIgyGf4WIHDkz52jwApQ9JLhZIRcxhlhKfkbn38W9W0ClcEpmnpZybOnnU5gLUQManJT5gmYCdtN5MhUhMMBi85DvnzUHW1lYClqVMLES0JL2JA)Qd15FIzbaZIYOHfamlbiudcnK2Gx)myhQZ)eZsFwqclkdikML(SOelb61S0JLES0Eu7xDOo)tmlaywugnSaGzrzawmlaywcqOgeAiTbyIacevVDQIJ(5pSDOo)tml9zbjSOmGOyw6ZIcwmILXFWkHGYZ6GGylHShFywklzjaHAqOH0g86Nb7qD(NywkILppAIGA)iWA7rTF1H68pXSuwYsac1GqdPnateqGO6TtvC0p)HTd15FIzPiw(8OjcQ9JaRTh1(vhQZ)eZcaMfLlMLYswmILaebLEE28rTF1MtSuwYIhUhM2amrabIQ3ovXr)8h2c(yxvtGMBGeomF09W0CdPUoS0(rywmSt3onSSWFIIfKcteqGiwsObwm8AnlUwdnWsb4ILdYc(ETMLGJpwUDIfS3rS4DWvESaBSGuyIacebyKgtKySzGLGJpS5gcFQP3rMBbyIacevbjCHmyEMXc4yACZnkDvnbAgBZnyK5gMoZnpCpmn3q4Z7QAYCdHRxK5wpwoFqrN9(oQEWk4tSuelkJgwklzz8hSsiO8Soii2(jlfXcAkML(SOGLES0JLESyeleWD9rreOL6IkmKRRWbm9mqSuwYspw6Xsac1GqdPL6IkmKRRWbm9mq2H68pXSamwugqxmlLLSeGiO0ZZIGYBVWWIcwcqOgeAiTuxuHHCDfoGPNbYouN)jMfGXIYaAGdlaMLESOSYSa8SmRKAWbfzXF2w66Eb8rZ7wkDvnbYsFw6ZIcwmILaeQbHgsl1fvyixxHdy6zGSd5GfyPpl9zrbl9yXiwiG76JIiqlgU0A6UprvNLAbwklzXiwcqeu65zZh1(vBoXszjlbiudcnKwmCP10DFIQol1c14AmObquSY2H68pXSamwuwzJHL(SOGLESyeleWD9rreO9tCywNRQPkWD55T6QGeIpqSuwYsac1GqdP9tCywNRQPkWD55T6QGeIpq2HCWcS0NffS0JLaeQbHgsRknyAa6tu2HCWcSuwYIrSmEGS3a1Aw6Zszjl9yPhli85DvnzHzDHP6nFceDSOelkZszjli85DvnzHzDHP6nFceDSOelXLL(SOGLESCZNarN9u2oKdwOgGqni0qYszjl38jq0zpLTbiudcnK2H68pXSuelFE0eb1(rG12JA)Qd15FIzbaZIYfZsFwklzbHpVRQjlmRlmvV5tGOJfLybGSOGLESCZNarN9aODihSqnaHAqOHKLYswU5tGOZEa0gGqni0qAhQZ)eZsrS85rteu7hbwBpQ9RouN)jMfamlkxml9zPSKfe(8UQMSWSUWu9MpbIowuILIzPpl9zPSKLaebLEEwGkmVNS03CdKWH5JUhMMBXjMaz5GSasAVal3oXYc7OiwGnwqAmrIXMbwmStjll8NOybeUu1elWKLfMyXtqwIgcbLhllSJIyXWoLS4jloiileckpwEmlUkCDSCqwaFYCdHp107iZTaynatW)EyAEMXcqyACZnkDvnbAgBZnyK5gMoZnpCpmn3q4Z7QAYCdHRxK5MrSGHlT6NG2BFETUIjciASu6QAcKLYswApQ9RouN)jMLIybGfxmlLLSOcXywuWs7rTF1H68pXSamwaiAybWS0JfJPywaWSOUAn7TpVwxXebenw85bGyb4zbGS0NLYswuxTM92NxRRyIaIgl(8aqSuelXfqWcaMLESmRKAWbfzXF2w66Eb8rZ7wkDvnbYcWZcAyPV5gcFQP3rMB3(8ADfteq0un4)zEMXcqAACZnkDvnbAgBZnqchMp6EyAUfNyIf0VlQWqUMfa0dy6zGybGfJPaMfvQbhIfNfKgtKySzGLfMSMBP3rMBuxuHHCDfoGPNbYClm)rZ7MBbiudcnK2Gx)myhQZ)eZcWybGfZIcwcqOgeAiTbyIacevVDQIJ(5pSDOo)tmlaJfawmlkyPhli85DvnzV9516kMiGOPAW)JLYswuxTM92NxRRyIaIgl(8aqSuelXTywaml9yzwj1GdkYI)ST019c4JM3Tu6QAcKfGNfanl9zPplLLSOcXywuWs7rTF1H68pXSamwIlWXCZd3dtZnQlQWqUUchW0ZazEMXs5InnU5gLUQManJT5giHdZhDpmn3ItmXYgCP109jkwaqSulWcGgtbmlQudoelolinMiXyZallmzn3sVJm3WWLwt39jQ6SulyUfM)O5DZTaeQbHgsBWRFgSd15FIzbySaOzrblgXsaIGspplckV9cdlkyXiwcqeu65zZh1(vBoXszjlbick98S5JA)QnNyrblbiudcnK2amrabIQ3ovXr)8h2ouN)jMfGXcGMffS0Jfe(8UQMSbyIacevbjCHmWszjlbiudcnK2Gx)myhQZ)eZcWybqZsFwklzjarqPNNfbL3EHHffS0JfJyzwj1GdkYI)ST019c4JM3Tu6QAcKffSeGqni0qAdE9ZGDOo)tmlaJfanlLLSOUAn74iOeUW12qzmkyhQZ)eZcWyrzJHfaZspwqdlapleWD9rreO9t8nRWbhCf8r8jvvjTML(SOGf1vRzhhbLWfU2gkJrb7kIL(SuwYIkeJzrblTh1(vhQZ)eZcWybGOXCZd3dtZnmCP10DFIQol1cMNzSuwztJBUrPRQjqZyBU5H7HP52N4WSoxvtvG7YZB1vbjeFGm3cZF08U5M6Q1SbV(zWouN)jMLIyrz0WIcw6XIrSmRKAWbfzXF2w66Eb8rZ7wkDvnbYszjlQRwZoockHlCTnugJc2H68pXSamwugGSayw6XsCzb4zrD1AwvnecQx4ZUIyPplaMLES0JfGdlaywqdlaplQRwZQQHqq9cF2vel9zb4zHaURpkIaTFIVzfo4GRGpIpPQkP1S0NffSOUAn74iOeUW12qzmkyxrS0NLYswuHymlkyP9O2V6qD(NywaglaenMBP3rMBFIdZ6CvnvbUlpVvxfKq8bY8mJLYa004MBu6QAc0m2MBGeomF09W0CZ47pMLhZIZY43onSqAxfo(rSyWlWYbzPZbIyX1AwGjllmXc(8JLB(ei6WSCqwujw0FsGSSIyXWF7SG0yIeJndS4jilifMiGarS4jillmXYTtSaWeKfSgESatwcGS8nwuH3ol38jq0HzXhIfyYYctSGp)y5MpbIoS5wy(JM3n3q4Z7QAYcZ6ct1B(ei6yrjwailkyXiwU5tGOZEa0oKdwOgGqni0qYszjl9ybHpVRQjlmRlmvV5tGOJfLyrzwklzbHpVRQjlmRlmvV5tGOJfLyjUS0NffS0Jf1vRzdE9ZGDfXIcw6XIrSeGiO0ZZIGYBVWWszjlQRwZoockHlCTnugJc2H68pXSayw6XcAyb4zzwj1GdkYI)ST019c4JM3Tu6QAcKL(SamLy5MpbIo7PSvD1AvW143dtwuWI6Q1SJJGs4cxBdLXOGDfXszjlQRwZoockHlCTnugJcv8NTLUUxaF08UDfXsFwklzjaHAqOH0g86Nb7qD(NywamlaKLIy5MpbIo7PSnaHAqOH0cUg)EyYIcw6XIrSeGiO0ZZMpQ9R2CILYswmIfe(8UQMSbyIacevbjCHmWsFwuWIrSeGiO0ZZcuH59KLYswcqeu65zZh1(vBoXIcwq4Z7QAYgGjciqufKWfYalkyjaHAqOH0gGjciqu92Pko6N)W2velkyXiwcqOgeAiTbV(zWUIyrbl9yPhlQRwZsb9hHPQEL(yhQZ)eZsrSOCXSuwYI6Q1Suq)ryQIHAFSd15FIzPiwuUyw6ZIcwmILzLudoOiRQR9mqvyR6AD92)ef2sPRQjqwklzPhlQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaXIsSGgwklzrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwuIfabl9zPplLLSOUAnlqFcoeyL6IGgOPJYRsjnO(yq2vel9zPSKfvigZIcwApQ9RouN)jMfGXcalMLYswq4Z7QAYcZ6ct1B(ei6yrjwk2CdRHh2C7MpbIoLn38W9W0CBHP6Fuh28mJLYX104MBu6QAc0m2MBE4EyAUTWu9pQdBUfM)O5DZne(8UQMSWSUWu9MpbIowmsjwailkyXiwU5tGOZEkBhYbludqOgeAizPSKfe(8UQMSWSUWu9MpbIowuIfaYIcw6XI6Q1SbV(zWUIyrbl9yXiwcqeu65zrq5TxyyPSKf1vRzhhbLWfU2gkJrb7qD(Nywaml9ybnSa8SmRKAWbfzXF2w66Eb8rZ7wkDvnbYsFwaMsSCZNarN9aOvD1AvW143dtwuWI6Q1SJJGs4cxBdLXOGDfXszjlQRwZoockHlCTnugJcv8NTLUUxaF08UDfXsFwklzjaHAqOH0g86Nb7qD(NywamlaKLIy5MpbIo7bqBac1GqdPfCn(9WKffS0JfJyjarqPNNnFu7xT5elLLSyeli85DvnzdWebeiQcs4czGL(SOGfJyjarqPNNfOcZ7jlkyPhlgXI6Q1SbV(zWUIyPSKfJyjarqPNNfbL3EHHL(SuwYsaIGsppB(O2VAZjwuWccFExvt2amrabIQGeUqgyrblbiudcnK2amrabIQ3ovXr)8h2UIyrblgXsac1GqdPn41pd2velkyPhl9yrD1AwkO)imv1R0h7qD(NywkIfLlMLYswuxTMLc6pctvmu7JDOo)tmlfXIYfZsFwuWIrSmRKAWbfzvDTNbQcBvxRR3(NOWwkDvnbYszjl9yrD1Awvx7zGQWw1166T)jkCn9BnKfFEaiwuIf0WszjlQRwZQ6Apduf2QUwxV9prHR(e8KS4ZdaXIsSaiyPpl9zPplLLSOUAnlqFcoeyL6IGgOPJYRsjnO(yq2velLLSOcXywuWs7rTF1H68pXSamwayXSuwYccFExvtwywxyQEZNarhlkXsXMByn8WMB38jq0bqZZmwkBmMg3CJsxvtGMX2CZd3dtZTfMQ)rDyZnqchMp6EyAUfNycZIR1SaVDAybMSSWel)rDywGjlbqZTW8hnVBUPUAnBWRFgSRiwklzjarqPNNnFu7xT5elkybHpVRQjBaMiGarvqcxidSOGLaeQbHgsBaMiGar1BNQ4OF(dBxrSOGfJyjaHAqOH0g86Nb7kIffS0JLESOUAnlf0FeMQ6v6JDOo)tmlfXIYfZszjlQRwZsb9hHPkgQ9XouN)jMLIyr5IzPplkyXiwMvsn4GISQU2ZavHTQR11B)tuylLUQMazPSKLzLudoOiRQR9mqvyR6AD92)ef2sPRQjqwuWspwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaILIyjUSuwYI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuelXLL(S0NLYswuxTMfOpbhcSsDrqd00r5vPKguFmi7kILYswuHymlkyP9O2V6qD(NywaglaSyZZmwkJgtJBUrPRQjqZyBUbs4W8r3dtZT4ifEqIfpCpmzr)4JfvhtGSatwW)T87Hjs0eQhBU5H7HP52SYQhUhMv9JpZn8nF4mJLYMBH5pAE3CdHpVRQj7JRoKm30p(QP3rMBoKmpZyPmG204MBu6QAc0m2MBH5pAE3CBwj1GdkYQ6Apduf2QUwxV9prHTeWD9rreO5g(MpCMXszZnpCpmn3Mvw9W9WSQF8zUPF8vtVJm3uH(zEMXszGJPXn3O0v1eOzSn38W9W0CBwz1d3dZQ(XN5M(Xxn9oYCdFMN5zUPc9Z04MXsztJBUrPRQjqZyBU5H7HP524iOeUW12qzmkyUbs4W8r3dtZT4WqzmkWIH)2zbPXejgBgm3cZF08U5M6Q1SbV(zWouN)jMLIyrz0yEMXcGMg3CJsxvtGMX2CZd3dtZnh0JUhbvXg8PZCluiOP65dk6WMXszZTW8hnVBUPUAnRQR9mqvyR6AD92)efUM(TgYIppaelaJfablkyrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwaglacwuWspwmIfq4zDqp6EeufBWNUkO35Oi79bG(eflkyXiw8W9W06GE09iOk2GpDvqVZrr2pRn9JA)yrbl9yXiwaHN1b9O7rqvSbF6Q7KRT3ha6tuSuwYci8SoOhDpcQIn4txDNCTDOo)tmlfXsCzPplLLSacpRd6r3JGQyd(0vb9ohfzXNhaIfGXsCzrblGWZ6GE09iOk2GpDvqVZrr2H68pXSamwqdlkybeEwh0JUhbvXg8PRc6DokYEFaOprXsFZnqchMp6EyAUfNyILyc6r3JGyzZGpDSyyNsw8JfnHXSC7EYIXWsSHX04SGppaeMfpbz5GSmuBi8ololatjaYc(8aqS4yw0(rS4ywIGy8RQjwGdl33rS8hlyil)XIpZJGWSaGYcFS4TJgwCwIlGzbFEaiwiKf9dHnpZyfxtJBUrPRQjqZyBU5H7HP5waMiGar1BNQ4OF(dBUbs4W8r3dtZT4etSGuyIaceXIH)2zbPXejgBgyXWoLSebX4xvtS4jilWBNgdpMyXWF7S4SeBymnolQRwJfd7uYciHlKHprzUfM)O5DZnJybCwpOnH1aiMffS0JLESGWN3v1KnateqGOkiHlKbwuWIrSeGqni0qAdE9ZGDihSalLLSOUAnBWRFgSRiw6ZIcw6XI6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqSOelacwklzrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwuIfabl9zPSKfvigZIcwApQ9RouN)jMfGXIYfZsFZZmwgJPXn3O0v1eOzSn38W9W0CRTMcvyRs6vsMBGeomF09W0CloarFwCml3oXs7h8XcQailFYYTtS4SeBymnolg(eeAGf4WIH)2z52jwqovyEpzrD1ASahwm83ololacaJPalXe0JUhbXYMbF6yXtqwm4)XsdoSG0yIeJndS8nw(JfdW8yrLyzfXIJY)KfvQbhILBNyjaYYJzP95J3jqZTW8hnVBU1JLES0Jf1vRzvDTNbQcBvxRR3(NOW10V1qw85bGyPiwa0SuwYI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuelaAw6ZIcw6XIrSeGiO0ZZIGYBVWWszjlgXI6Q1SJJGs4cxBdLXOGDfXsFw6ZIcw6Xc4SEqBcRbqmlLLSeGqni0qAdE9ZGDOo)tmlfXcAkMLYsw6XsaIGsppB(O2VAZjwuWsac1GqdPnateqGO6TtvC0p)HTd15FIzPiwqtXS0NL(S0NLYsw6Xci8SoOhDpcQIn4txf07CuKDOo)tmlfXcGGffSeGqni0qAdE9ZGDOo)tmlfXIYfZIcwcqeu65ztkmqnCazPplLLSOcXywuWYNhnrqTFeyT9O2V6qD(NywaglacwuWIrSeGqni0qAdE9ZGDihSalLLSeGiO0ZZcuH59KffSOUAnlqFcoeyL6IGgOPJYZUIyPSKLaebLEEweuE7fgwuWI6Q1SJJGs4cxBdLXOGDOo)tmlaJfajlkyrD1A2XrqjCHRTHYyuWUImpZyHgtJBUrPRQjqZyBU5H7HP5wWZaPRQRwZClm)rZ7MB9yrD1Awvx7zGQWw1166T)jkCn9BnKDOo)tmlfXcWXIgwklzrD1Awvx7zGQWw1166T)jkC1NGNKDOo)tmlfXcWXIgw6ZIcw6Xsac1GqdPn41pd2H68pXSuelahwklzPhlbiudcnKwQlcAGMQkmbTd15FIzPiwaoSOGfJyrD1AwG(eCiWk1fbnqthLxLsAq9XGSRiwuWsaIGspplqfM3tw6ZsFwuWIJVX11iObAyPiLyjUfBUPUATA6DK5g(8rdhqZnqchMp6EyAUHupdKMLTZhnCazXWF7S4SKKbwInmMgNf1vRXINGSG0yIeJndS84eDhlUkCDSCqwujwwyc08mJfG204MBu6QAc0m2MBE4EyAUHpFWRbfzUbs4W8r3dtZT44QlILTZh8Aqrywm83ololXggtJZI6Q1yrDDSKWJfd7uYseeQ)efln4WcsJjsm2mWcCyb50NGdbYYw0p)Hn3cZF08U5wpwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaILIybGSuwYI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuelaKL(SOGLESeGiO0ZZMpQ9R2CILYswcqOgeAiTbV(zWouN)jMLIyb4WszjlgXccFExvt2aynatW)EyYIcwmILaebLEEwGkmVNSuwYspwcqOgeAiTuxe0anvvycAhQZ)eZsrSaCyrblgXI6Q1Sa9j4qGvQlcAGMokVkL0G6JbzxrSOGLaebLEEwGkmVNS0NL(SOGLESyelGWZ2wtHkSvj9kj79bG(eflLLSyelbiudcnK2Gx)myhYblWszjlgXsac1GqdPnateqGO6TtvC0p)HTd5GfyPV5zglGJPXn3O0v1eOzSn38W9W0CdF(GxdkYCdKWH5JUhMMBXXvxelBNp41GIWSOsn4qSGuyIacezUfM)O5DZTESeGqni0qAdWebeiQE7ufh9ZFy7qD(NywaglOHffSyelGZ6bTjSgaXSOGLESGWN3v1KnateqGOkiHlKbwklzjaHAqOH0g86Nb7qD(NywaglOHL(SOGfe(8UQMSbWAaMG)9WKL(SOGfJybeE22AkuHTkPxjzVpa0NOyrblbick98S5JA)QnNyrblgXc4SEqBcRbqmlkyHc6pct2pREwGffS44BCDncAGgwkIfJPyZZmwactJBUrPRQjqZyBUbJm3W0zU5H7HP5gcFExvtMBiC9Im36XI6Q1SJJGs4cxBdLXOGDOo)tmlfXcAyPSKfJyrD1A2XrqjCHRTHYyuWUIyPplkyPhlQRwZc0NGdbwPUiObA6O8QusdQpgKDOo)tmlaJfubqBNJmw6ZIcw6XI6Q1Suq)ryQIHAFSd15FIzPiwqfaTDoYyPSKf1vRzPG(JWuvVsFSd15FIzPiwqfaTDoYyPV5giHdZhDpmn3IJWeDhlGWJfW18jkwUDIfkbzb2ybaHJGs4cZsCyOmgfqllGR5tuSa0NGdbYc1fbnqthLhlWHLpz52jw0o(ybvaKfyJfpzb9d6pctMBi8PMEhzUbcV6qa31puhLh28mJfG004MBu6QAc0m2MBE4EyAUHxz7hYClm)rZ7MBd1gcV7QAIffSC(GIo79Du9GvWNyPiwugqZIcw8OAyNcaXIcwq4Z7QAYccV6qa31puhLh2CluiOP65dk6WMXszZZmwkxSPXn3O0v1eOzSn38W9W0CRdcZ2pK5wy(JM3n3gQneE3v1elky58bfD277O6bRGpXsrSOCCTOHffS4r1WofaIffSGWN3v1KfeE1HaURFOokpS5wOqqt1Zhu0HnJLYMNzSuwztJBUrPRQjqZyBU5H7HP5g(iT2NAt7dzUfM)O5DZTHAdH3DvnXIcwoFqrN9(oQEWk4tSuelkdOzbWSmuN)jMffS4r1WofaIffSGWN3v1KfeE1HaURFOokpS5wOqqt1Zhu0HnJLYMNzSugGMg3CJsxvtGMX2CZd3dtZTgCcuf2QPFRHm3ajCy(O7HP5wCaglwGjlbqwm83oCDSe8OOprzUfM)O5DZnpQg2PaqMNzSuoUMg3CJsxvtGMX2CZd3dtZnQlcAGMQkmbn3ajCy(O7HP5g63fbnqdlXgMGSyyNswCv46y5GSq5rdloljzGLydJPXzXWNGqdS4jilyhbXsdoSG0yIeJndMBH5pAE3CRhluq)ryYQxPp1Kq2Xszjluq)ryYIHAFQjHSJLYswOG(JWK1Zc1Kq2XszjlQRwZQ6Apduf2QUwxV9prHRPFRHSd15FIzPiwaow0WszjlQRwZQ6Apduf2QUwxV9prHR(e8KSd15FIzPiwaow0Wszjlo(gxxJGgOHLIybqwmlkyjaHAqOH0g86Nb7qoybwuWIrSaoRh0MWAaeZsFwuWspwcqOgeAiTbV(zWouN)jMLIyjUfZszjlbiudcnK2Gx)myhYblWsFwklzrfIXSOGLppAIGA)iWA7rTF1H68pXSamwuUyZZmwkBmMg3CJsxvtGMX2CZd3dtZT2AkuHTkPxjzUbs4W8r3dtZT4ae9zzEu7hlQudoell8NOybPX0Clm)rZ7MBbiudcnK2Gx)myhYblWIcwq4Z7QAYgaRbyc(3dtwuWspwC8nUUgbnqdlfXcGSywuWIrSeGiO0ZZMpQ9R2CILYswcqeu65zZh1(vBoXIcwC8nUUgbnqdlaJfJPyw6ZIcwmILaebLEEweuE7fgwuWspwmILaebLEE28rTF1MtSuwYsac1GqdPnateqGO6TtvC0p)HTd5GfyPplkyXiwaN1dAtynaInpZyPmAmnU5gLUQManJT5gmYCdtN5MhUhMMBi85DvnzUHW1lYCZiwaN1dAtynaIzrbli85DvnzdG1amb)7HjlkyPhl9yXX346Ae0anSuelaYIzrbl9yrD1AwG(eCiWk1fbnqthLxLsAq9XGSRiwklzXiwcqeu65zbQW8EYsFwklzrD1AwvnecQx4ZUIyrblQRwZQQHqq9cF2H68pXSamwuxTMn41pdwW143dtw6ZszjlFE0eb1(rG12JA)Qd15FIzbySOUAnBWRFgSGRXVhMSuwYsaIGsppB(O2VAZjw6ZIcw6XIrSeGiO0ZZMpQ9R2CILYsw6XIJVX11iObAybySymfZszjlGWZ2wtHkSvj9kj79bG(efl9zrbl9ybHpVRQjBaMiGarvqcxidSuwYsac1GqdPnateqGO6TtvC0p)HTd5GfyPpl9n3ajCy(O7HP5gsJjsm2mWIHDkzXpwaKfdywIjgaYsp4OHgOHLB3twmMIzjMyailg(BNfKcteqGO(Sy4VD46yrdXFIIL77iw(KLyRHqq9cFS4jil6pjwwrSy4VDwqkmrabIy5BS8hlgCmlGeUqgiqZne(utVJm3cG1amb)7Hzvf6N5zglLb0Mg3CJsxvtGMX2Clm)rZ7MBi85DvnzdG1amb)7Hzvf6N5MhUhMMBbst47DD11pQSJYZ8mJLYahtJBUrPRQjqZyBUfM)O5DZne(8UQMSbWAaMG)9WSQc9ZCZd3dtZTpd(K(9W08mJLYactJBUrPRQjqZyBUbJm3W0zU5H7HP5gcFExvtMBiC9Im3OG(JWK9ZQEL(WcWZcGGfKWIhUhMw85t7hYsiJcRJQ33rSaywmIfkO)imz)SQxPpSa8S0JfanlaMLZ1uEwmCPRWw92PAdoe(Su6QAcKfGNL4YsFwqclE4EyAnm(TBjKrH1r177iwamlfBbiliHfCeP11DhFK5giHdZhDpmn3qF89D(ryw2HgyPBf2zjMyail(qSGY)KazjIgwWuaMGMBi8PMEhzU54iainBuW8mJLYastJBUrPRQjqZyBU5H7HP5g(8bVguK5giHdZhDpmn3IJRUiw2oFWRbfHzXWoLSC7elTh1(XYJzXvHRJLdYcLGOLL2qzmkWYJzXvHRJLdYcLGOLLcWfl(qS4hlaYIbmlXedaz5tw8Kf0pO)imHwwqAmrIXMbw0o(WS4j82PHfabGXuaZcCyPaCXIb4sdYcebnbpILo4qSC7EYcxQCXSetmaKfd7uYsb4IfdWLgmr3XY25dEnOiwsObZTW8hnVBU1JfvigZIcw(8OjcQ9JaRTh1(vhQZ)eZcWyXyyPSKLESOUAn74iOeUW12qzmkyhQZ)eZcWybva025iJfGNLa9Aw6XIJVX11iObAybjSe3IzPplkyrD1A2XrqjCHRTHYyuWUIyPpl9zPSKLES44BCDncAGgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQIHAFSd15FIzbWSacpBBnfQWwL0RKS3hacxhQZ)KfGNfaArdlfXIYkxmlLLS44BCDncAGgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQQxPp2H68pXSaywaHNTTMcvyRs6vs27daHRd15FYcWZcaTOHLIyrzLlML(SOGfkO)imz)S6zbwuWspwmIf1vRzdE9ZGDfXszjlgXY5Akpl(8rdhqlLUQMazPplkyPhl9yXiwcqOgeAiTbV(zWUIyPSKLaebLEEwGkmVNSOGfJyjaHAqOH0sDrqd0uvHjODfXsFwklzjarqPNNnFu7xT5el9zrbl9yXiwcqeu65zrq5TxyyPSKfJyrD1A2Gx)myxrSuwYIJVX11iObAyPiwaKfZsFwklzPhlNRP8S4ZhnCaTu6QAcKffSOUAnBWRFgSRiwuWspwuxTMfF(OHdOfFEaiwaglXLLYswC8nUUgbnqdlfXcGSyw6ZsFwklzrD1A2Gx)myxrSOGfJyrD1A2XrqjCHRTHYyuWUIyrblgXY5Akpl(8rdhqlLUQManpZybWInnU5gLUQManJT5MhUhMMBjzO2bHP5giHdZhDpmn3ItmXcasimXS8jlO3k9Hf0pO)imXINGSGDeeliNX1nahhwAnlaiHWKLgCybPXejgBgm3cZF08U5wpwuxTMLc6pctv9k9XouN)jMLIyHqgfwhvVVJyPSKLESe29bfHzrjwailkyzOWUpOO69DelaJf0WsFwklzjS7dkcZIsSexw6ZIcw8OAyNcazEMXcGkBACZnkDvnbAgBZTW8hnVBU1Jf1vRzPG(JWuvVsFSd15FIzPiwiKrH1r177iwuWspwcqOgeAiTbV(zWouN)jMLIybnfZszjlbiudcnK2amrabIQ3ovXr)8h2ouN)jMLIybnfZsFwklzPhlHDFqrywuIfaYIcwgkS7dkQEFhXcWybnS0NLYswc7(GIWSOelXLL(SOGfpQg2PaqMBE4EyAUT76wTdctZZmwaeGMg3CJsxvtGMX2Clm)rZ7MB9yrD1AwkO)imv1R0h7qD(NywkIfczuyDu9(oIffS0JLaeQbHgsBWRFgSd15FIzPiwqtXSuwYsac1GqdPnateqGO6TtvC0p)HTd15FIzPiwqtXS0NLYsw6Xsy3hueMfLybGSOGLHc7(GIQ33rSamwqdl9zPSKLWUpOimlkXsCzPplkyXJQHDkaK5MhUhMMBTLwx7GW08mJfaJRPXn3O0v1eOzSn3ajCy(O7HP5gYbe9zbMSean38W9W0CZGpZdNkSvj9kjZZmwa0ymnU5gLUQManJT5MhUhMMB4ZN2pK5giHdZhDpmn3ItmXY25t7hILdYs0adSSb1(Wc6h0FeMyboSyyNsw(KfyQlWc6TsFyb9d6pctS4jillmXcYbe9zjAGbmlFJLpzb9wPpSG(b9hHjZTW8hnVBUrb9hHj7Nv9k9HLYswOG(JWKfd1(utczhlLLSqb9hHjRNfQjHSJLYswuxTM1GpZdNkSvj9kj7kIffSOUAnlf0FeMQ6v6JDfXszjl9yrD1A2Gx)myhQZ)eZcWyXd3dtRHXVDlHmkSoQEFhXIcwuxTMn41pd2vel9npZybq0yACZnpCpmn3mm(TBUrPRQjqZyBEMXcGaAtJBUrPRQjqZyBU5H7HP52SYQhUhMv9JpZn9JVA6DK5wZ16BFwMN5zU5qY04MXsztJBUrPRQjqZyBUbJm3W0zU5H7HP5gcFExvtMBiC9Im36XI6Q1S33rgGtwbhY7u)eKg7qD(NywaglOcG2ohzSaywk2QmlLLSOUAn79DKb4KvWH8o1pbPXouN)jMfGXIhUhMw85t7hYsiJcRJQ33rSaywk2QmlkyPhluq)ryY(zvVsFyPSKfkO)imzXqTp1Kq2Xszjluq)ryY6zHAsi7yPpl9zrblQRwZEFhzaozfCiVt9tqASRiwuWYSsQbhuK9(oYaCYk4qEN6NG0yP0v1eO5giHdZhDpmn3qQRdlTFeMfd70Ttdl3oXsCCiVl4xyNgwuxTglgETMLMR1SaBnwm83(NSC7eljHSJLGJpZne(utVJm3ahY7QgETU2CTUcBnZZmwa004MBu6QAc0m2MBWiZnmDMBE4EyAUHWN3v1K5gcxViZnJyHc6pct2pRyO2hwuWspwWrKwxpFqrh2IpFA)qSuelOHffSCUMYZIHlDf2Q3ovBWHWNLsxvtGSuwYcoI0665dk6Ww85t7hILIyb4WsFZnqchMp6EyAUHuxhwA)imlg2PBNgw2oFWRbfXYJzXaCUDwco((eflqe0WY25t7hILpzb9wPpSG(b9hHjZne(utVJm3EujCOk(8bVguK5zgR4AACZnkDvnbAgBZnpCpmn3cWebeiQE7ufh9ZFyZnqchMp6EyAUfNyIfKcteqGiwmStjl(XIMWywUDpzbnfZsmXaqw8eKf9NelRiwm83olinMiXyZG5wy(JM3n3mIfWz9G2ewdGywuWspw6XccFExvt2amrabIQGeUqgyrblgXsac1GqdPn41pd2HCWcSuwYI6Q1SbV(zWUIyPplkyPhlQRwZsb9hHPQEL(yhQZ)eZsrSaOzPSKf1vRzPG(JWufd1(yhQZ)eZsrSaOzPplkyPhlgXYSsQbhuKv11EgOkSvDTUE7FIcBP0v1eilLLSOUAnRQR9mqvyR6AD92)efUM(TgYIppaelfXsCzPSKf1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGyPiwIll9zPSKfvigZIcwApQ9RouN)jMfGXIYfZIcwmILaeQbHgsBWRFgSd5GfyPV5zglJX04MBu6QAc0m2MBE4EyAUnockHlCTnugJcMBGeomF09W0CloXelXHHYyuGfd)TZcsJjsm2myUfM)O5DZn1vRzdE9ZGDOo)tmlfXIYOX8mJfAmnU5gLUQManJT5MhUhMMB4v2(Hm3cfcAQE(GIoSzSu2Clm)rZ7MB9yzO2q4DxvtSuwYI6Q1Suq)ryQIHAFSd15FIzbySexwuWcf0FeMSFwXqTpSOGLH68pXSamwu2yyrblNRP8Sy4sxHT6Tt1gCi8zP0v1eil9zrblNpOOZEFhvpyf8jwkIfLngwaWSGJiTUE(GIomlaMLH68pXSOGLESqb9hHj7NvplWszjld15FIzbySGkaA7CKXsFZnqchMp6EyAUfNyILTv2(Hy5twI8eK6(alWKfplC7FIILB3pw0pccZIYgdMcyw8eKfnHXSy4VDw6GdXY5dk6WS4jil(XYTtSqjilWglolBqTpSG(b9hHjw8JfLngwWuaZcCyrtymld15F(jkwCmlhKLeESS7i(eflhKLHAdH3zbCnFIIf0BL(Wc6h0FeMmpZybOnnU5gLUQManJT5MhUhMMB4ZNMR1MBGeomF09W0Cd5errSSIyz78P5Anl(XIR1SCFhHzzLAcJzzH)eflOxHGpoMfpbz5pwEmlUkCDSCqwIgyGf4WIMowUDIfCefExZIhUhMSO)KyrL0qdSS7jOMyjooK3P(jinSatwailNpOOdBUfM)O5DZnJy5CnLNfFKw7tfC(2zP0v1eilkyPhlQRwZIpFAUwBhQneE3v1elkyPhl4isRRNpOOdBXNpnxRzbySexwklzXiwMvsn4GIS33rgGtwbhY7u)eKglLUQMazPplLLSCUMYZIHlDf2Q3ovBWHWNLsxvtGSOGf1vRzPG(JWufd1(yhQZ)eZcWyjUSOGfkO)imz)SIHAFyrblQRwZIpFAUwBhQZ)eZcWyb4WIcwWrKwxpFqrh2IpFAUwZsrkXIXWsFwuWspwmILzLudoOiRUqWhhxBAIUprvrP)UimzP0v1eilLLSCFhXcYLfJbnSuelQRwZIpFAUwBhQZ)eZcGzbGS0NffSC(GIo79Du9GvWNyPiwqJ5zglGJPXn3O0v1eOzSn38W9W0CdF(0CT2CdKWH5JUhMMBih)TZY2rATpSehNVDSSWelWKLailg2PKLHAdH3DvnXI66ybFVwZIb)pwAWHf0RqWhhZs0adS4jilGWeDhllmXIk1GdXcsJJyllB3R1SSWelQudoelifMiGarSG)mqSC7(XIHxRzjAGbw8eE70WY25tZ1AZTW8hnVBUDUMYZIpsR9PcoF7Su6QAcKffSOUAnl(8P5ATDO2q4DxvtSOGLESyelZkPgCqrwDHGpoU20eDFIQIs)DryYsPRQjqwklz5(oIfKllgdAyPiwmgw6ZIcwoFqrN9(oQEWk4tSuelX18mJfGW04MBu6QAc0m2MBE4EyAUHpFAUwBUbs4W8r3dtZnKJ)2zjooK3P(jinSSWelBNpnxRz5GSaerrSSIy52jwuxTglQfyX1yill8NOyz78P5AnlWKf0WcMcWeeZcCyrtymld15F(jkZTW8hnVBUnRKAWbfzVVJmaNScoK3P(jinwkDvnbYIcwWrKwxpFqrh2IpFAUwZsrkXsCzrbl9yXiwuxTM9(oYaCYk4qEN6NG0yxrSOGf1vRzXNpnxRTd1gcV7QAILYsw6XccFExvtwWH8UQHxRRnxRRWwJffS0Jf1vRzXNpnxRTd15FIzbySexwklzbhrAD98bfDyl(8P5AnlfXcazrblNRP8S4J0AFQGZ3olLUQMazrblQRwZIpFAUwBhQZ)eZcWybnS0NL(S038mJfG004MBu6QAc0m2MBWiZnmDMBE4EyAUHWN3v1K5gcxViZnhFJRRrqd0WsrSaikMfaml9yr5Izb4zrD1A277idWjRGd5DQFcsJfFEaiw6ZcaMLESOUAnl(8P5ATDOo)tmlaplXLfKWcoI066UJpIfGNfJy5CnLNfFKw7tfC(2zP0v1eil9zbaZspwcqOgeAiT4ZNMR12H68pXSa8Sexwqcl4isRR7o(iwaEwoxt5zXhP1(ubNVDwkDvnbYsFwaWS0Jfq4zBRPqf2QKELKDOo)tmlaplOHL(SOGLESOUAnl(8P5ATDfXszjlbiudcnKw85tZ1A7qD(Nyw6BUbs4W8r3dtZnK66Ws7hHzXWoD70WIZY25dEnOiwwyIfdVwZsWxyILTZNMR1SCqwAUwZcS1qllEcYYctSSD(GxdkILdYcqefXsCCiVt9tqAybFEaiwwrMBi8PMEhzUHpFAUwxnaZR2CTUcBnZZmwkxSPXn3O0v1eOzSn38W9W0CdF(GxdkYCdKWH5JUhMMBXjMyz78bVguelg(BNL44qEN6NG0WYbzbiIIyzfXYTtSOUAnwm83oCDSOH4prXY25tZ1Awwr33rS4jillmXY25dEnOiwGjlgdGzj2WyACwWNhacZYkVxZIXWY5dk6WMBH5pAE3CdHpVRQjl4qEx1WR11MR1vyRXIcwq4Z7QAYIpFAUwxnaZR2CTUcBnwuWIrSGWN3v1K9rLWHQ4Zh8AqrSuwYspwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaILIyjUSuwYI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuelXLL(SOGfCeP11Zhu0HT4ZNMR1SamwmgwuWccFExvtw85tZ16QbyE1MR1vyRzEMXszLnnU5gLUQManJT5MhUhMMBoOhDpcQIn4tN5wOqqt1Zhu0HnJLYMBH5pAE3CZiwUpa0NOyrblgXIhUhMwh0JUhbvXg8PRc6DokY(zTPFu7hlLLSacpRd6r3JGQyd(0vb9ohfzXNhaIfGXsCzrblGWZ6GE09iOk2GpDvqVZrr2H68pXSamwIR5giHdZhDpmn3ItmXc2GpDSGHSC7(Xsb4Ifu0XsNJmwwr33rSOwGLf(tuS8hloMfTFeloMLiig)QAIfyYIMWywUDpzjUSGppaeMf4Wcakl8XIHDkzjUaMf85bGWSqil6hY8mJLYa004MBu6QAc0m2MBE4EyAU1bHz7hYCluiOP65dk6WMXszZTW8hnVBUnuBi8URQjwuWY5dk6S33r1dwbFILIyPhl9yrzJHfaZspwWrKwxpFqrh2IpFA)qSa8SaqwaEwuxTMLc6pctv9k9XUIyPpl9zbWSmuN)jML(SGew6XIYSaywoxt5zpdFw7GWeBP0v1eil9zrbl9yjaHAqOH0g86Nb7qoybwuWIrSaoRh0MWAaeZIcw6XccFExvt2amrabIQGeUqgyPSKLaeQbHgsBaMiGar1BNQ4OF(dBhYblWszjlgXsaIGsppB(O2VAZjw6Zszjl4isRRNpOOdBXNpTFiwagl9yPhlaAwaWS0Jf1vRzPG(JWuvVsFSRiwaEwail9zPplapl9yrzwamlNRP8SNHpRDqyITu6QAcKL(S0NffSyeluq)ryYIHAFQjHSJLYsw6Xcf0FeMSFwXqTpSuwYspwOG(JWK9ZQk82zPSKfkO)imz)SQxPpS0NffSyelNRP8Sy4sxHT6Tt1gCi8zP0v1eilLLSOUAnB08DWb8DD1NGNFOgT0yFSiC9IyPiLybGOPyw6ZIcw6XcoI0665dk6Ww85t7hIfGXIYfZcWZspwuMfaZY5Akp7z4ZAheMylLUQMazPpl9zrblo(gxxJGgOHLIybnfZcaMf1vRzXNpnxRTd15FIzb4zbqZsFwuWspwmIf1vRzb6tWHaRuxe0anDuEvkPb1hdYUIyPSKfkO)imz)SIHAFyPSKfJyjarqPNNfOcZ7jl9zrblgXI6Q1SJJGs4cxBdLXOqf)zBPR7fWhnVBxrMBGeomF09W0Cdab1gcVZcasimB)qS8nwqAmrIXMbwEmld5Gfqll3onel(qSOjmMLB3twqdlNpOOdZYNSGER0hwq)G(JWelg(BNLn4fhqllAcJz529KfLlMf4TtJHhtS8jlEwGf0pO)imXcCyzfXYbzbnSC(GIomlQudoelolO3k9Hf0pO)imzzjoct0DSmuBi8olGR5tuSGC6tWHazb97IGgOPJYJLvQjmMLpzzdQ9Hf0pO)imzEMXs54AACZnkDvnbAgBZnpCpmn3AWjqvyRM(TgYCdKWH5JUhMMBXjMyjoaJflWKLailg(BhUowcEu0NOm3cZF08U5Mhvd7uaiZZmwkBmMg3CJsxvtGMX2CdgzUHPZCZd3dtZne(8UQMm3q46fzUzelGZ6bTjSgaXSOGfe(8UQMSbWAaMG)9WKffS0JLESOUAnl(8P5ATDfXszjl9y5CnLNfFKw7tfC(2zP0v1eilLLSeGiO0ZZMpQ9R2CIL(S0NffS0JfJyrD1AwmuJVpq2velkyXiwuxTMn41pd2velkyPhlgXY5AkpBBnfQWwL0RKSu6QAcKLYswuxTMn41pdwW143dtwkILaeQbHgsBBnfQWwL0RKSd15FIzbWSaiyPplkybHpVRQj7TpVwxXebenvd(FSOGLESyelbick98S5JA)QnNyPSKLaeQbHgsBaMiGar1BNQ4OF(dBxrSOGLESOUAnl(8P5ATDOo)tmlaJfaYszjlgXY5Akpl(iT2Nk48TZsPRQjqw6ZsFwuWY5dk6S33r1dwbFILIyrD1A2Gx)mybxJFpmzb4zPylWHL(SuwYIkeJzrblTh1(vhQZ)eZcWyrD1A2Gx)mybxJFpmzPV5gcFQP3rMBbWAaMG)9WS6qY8mJLYOX04MBu6QAc0m2MBE4EyAUfinHV31vx)OYokpZnqchMp6EyAUfNyIfKgtKySzGfyYsaKLvQjmMfpbzr)jXYFSSIyXWF7SGuyIacezUfM)O5DZne(8UQMSbWAaMG)9WS6qY8mJLYaAtJBUrPRQjqZyBUfM)O5DZne(8UQMSbWAaMG)9WS6qYCZd3dtZTpd(K(9W08mJLYahtJBUrPRQjqZyBU5H7HP5g1fbnqtvfMGMBGeomF09W0CloXelOFxe0anSeBycYcmzjaYIH)2zz78P5AnlRiw8eKfSJGyPbhwaGln2hw8eKfKgtKySzWClm)rZ7MBQqmMffS85rteu7hbwBpQ9RouN)jMfGXIYOHLYsw6XI6Q1SrZ3bhW31vFcE(HA0sJ9XIW1lIfGXcartXSuwYI6Q1SrZ3bhW31vFcE(HA0sJ9XIW1lILIuIfaIMIzPplkyrD1Aw85tZ1A7kIffS0JLaeQbHgsBWRFgSd15FIzPiwqtXSuwYc4SEqBcRbqml9npZyPmGW04MBu6QAc0m2MBE4EyAUHpsR9P20(qMBHcbnvpFqrh2mwkBUfM)O5DZTHAdH3DvnXIcwUVJQhSc(elfXIYOHffSGJiTUE(GIoSfF(0(HybySymSOGfpQg2PaqSOGLESOUAnBWRFgSd15FIzPiwuUywklzXiwuxTMn41pd2vel9n3ajCy(O7HP5gacQneENLM2hIfyYYkILdYsCz58bfDywm83oCDSG0yIeJndSOsFIIfxfUowoileYI(HyXtqws4Xcebnbpk6tuMNzSugqAACZnkDvnbAgBZnpCpmn3ARPqf2QKELK5giHdZhDpmn3ItmXsCaI(S8nw(e)GelEYc6h0FeMyXtqw0FsS8hlRiwm83ololaWLg7dlrdmWINGSetqp6EeelBg8PZClm)rZ7MBuq)ryY(z1ZcSOGfpQg2PaqSOGf1vRzJMVdoGVRR(e88d1OLg7JfHRxelaJfaIMIzrbl9ybeEwh0JUhbvXg8PRc6DokYEFaOprXszjlgXsaIGsppBsHbQHdilLLSGJiTUE(GIomlfXcazPplkyPhlQRwZoockHlCTnugJc2H68pXSamwaKSaGzPhlOHfGNLzLudoOil(Z2sx3lGpAE3sPRQjqw6ZIcwuxTMDCeucx4ABOmgfSRiwklzXiwuxTMDCeucx4ABOmgfSRiw6ZIcw6XIrSeGqni0qAdE9ZGDfXszjlQRwZE7ZR1vmrarJfFEaiwaglkJgwuWs7rTF1H68pXSamwayXfZIcwApQ9RouN)jMLIyr5IlMLYswmIfmCPv)e028Z11M2nyP0v1eil9npZybWInnU5gLUQManJT5MhUhMMB4ZNMR1MBGeomF09W0CloXelolBNpnxRzbaDs3olrdmWYk1egZY25tZ1AwEmlUEihSalRiwGdlfGlw8HyXvHRJLdYcebnbpILyIbGMBH5pAE3CtD1Awys3oUgrtGIUhM2velkyPhlQRwZIpFAUwBhQneE3v1elLLS44BCDncAGgwkIfazXS038mJfav204MBu6QAc0m2MBE4EyAUHpFAUwBUbs4W8r3dtZT44QlILyIbGSOsn4qSGuyIaceXIH)2zz78P5AnlEcYYTtjlBNp41GIm3cZF08U5waIGsppB(O2VAZjwuWIrSCUMYZIpsR9PcoF7Su6QAcKffS0Jfe(8UQMSbyIacevbjCHmWszjlbiudcnK2Gx)myxrSuwYI6Q1SbV(zWUIyPplkyjaHAqOH0gGjciqu92Pko6N)W2H68pXSamwqfaTDoYyb4zjqVMLES44BCDncAGgwqclOPyw6ZIcwuxTMfF(0CT2ouN)jMfGXIXWIcwmIfWz9G2ewdGyZZmwaeGMg3CJsxvtGMX2Clm)rZ7MBbick98S5JA)QnNyrbl9ybHpVRQjBaMiGarvqcxidSuwYsac1GqdPn41pd2velLLSOUAnBWRFgSRiw6ZIcwcqOgeAiTbyIacevVDQIJ(5pSDOo)tmlaJfanlkyrD1Aw85tZ1A7kIffSqb9hHj7NvplWIcwmIfe(8UQMSpQeoufF(GxdkIffSyelGZ6bTjSgaXMBE4EyAUHpFWRbfzEMXcGX104MBu6QAc0m2MBE4EyAUHpFWRbfzUbs4W8r3dtZT4etSSD(GxdkIfd)TZINSaGoPBNLObgyboS8nwkaxOdKficAcEelXedazXWF7SuaUgwsczhlbhFwwIPgdzbC1fXsmXaqw8JLBNyHsqwGnwUDIfauP82lmSOUAnw(glBNpnxRzXaCPbt0DS0CTMfyRXcCyPaCXIpelWKfaYY5dk6WMBH5pAE3CtD1Awys3oUg0Kpvep(HPDfXszjl9yXiwWNpTFiRhvd7uaiwuWIrSGWN3v1K9rLWHQ4Zh8AqrSuwYspwuxTMn41pd2H68pXSamwqdlkyrD1A2Gx)myxrSuwYspw6XI6Q1SbV(zWouN)jMfGXcQaOTZrglaplb61S0JfhFJRRrqd0WcsyjUfZsFwuWI6Q1SbV(zWUIyPSKf1vRzhhbLWfU2gkJrHk(Z2sx3lGpAE3ouN)jMfGXcQaOTZrglaplb61S0JfhFJRRrqd0WcsyjUfZsFwuWI6Q1SJJGs4cxBdLXOqf)zBPR7fWhnVBxrS0NffSeGiO0ZZIGYBVWWsFw6ZIcw6XcoI0665dk6Ww85tZ1AwaglXLLYswq4Z7QAYIpFAUwxnaZR2CTUcBnw6ZsFwuWIrSGWN3v1K9rLWHQ4Zh8AqrSOGLESyelZkPgCqr277idWjRGd5DQFcsJLsxvtGSuwYcoI0665dk6Ww85tZ1AwaglXLL(MNzSaOXyACZnkDvnbAgBZnpCpmn3sYqTdctZnqchMp6EyAUfNyIfaKqyIz5tw2GAFyb9d6pctS4jilyhbXsCyP1SaGectwAWHfKgtKySzWClm)rZ7MB9yrD1AwkO)imvXqTp2H68pXSueleYOW6O69DelLLS0JLWUpOimlkXcazrbldf29bfvVVJybySGgw6ZszjlHDFqrywuIL4YsFwuWIhvd7uaiZZmwaenMg3CJsxvtGMX2Clm)rZ7MB9yrD1AwkO)imvXqTp2H68pXSueleYOW6O69DelLLS0JLWUpOimlkXcazrbldf29bfvVVJybySGgw6ZszjlHDFqrywuIL4YsFwuWIhvd7uaiwuWspwuxTMDCeucx4ABOmgfSd15FIzbySGgwuWI6Q1SJJGs4cxBdLXOGDfXIcwmILzLudoOil(Z2sx3lGpAE3sPRQjqwklzXiwuxTMDCeucx4ABOmgfSRiw6BU5H7HP52URB1oimnpZybqaTPXn3O0v1eOzSn3cZF08U5wpwuxTMLc6pctvmu7JDOo)tmlfXcHmkSoQEFhXIcw6Xsac1GqdPn41pd2H68pXSuelOPywklzjaHAqOH0gGjciqu92Pko6N)W2H68pXSuelOPyw6Zszjl9yjS7dkcZIsSaqwuWYqHDFqr177iwaglOHL(SuwYsy3hueMfLyjUS0NffS4r1WofaIffS0Jf1vRzhhbLWfU2gkJrb7qD(NywaglOHffSOUAn74iOeUW12qzmkyxrSOGfJyzwj1GdkYI)ST019c4JM3Tu6QAcKLYswmIf1vRzhhbLWfU2gkJrb7kIL(MBE4EyAU1wADTdctZZmwae4yACZnkDvnbAgBZnqchMp6EyAUfNyIfKdi6ZcmzbPXrZnpCpmn3m4Z8WPcBvsVsY8mJfabeMg3CJsxvtGMX2CdgzUHPZCZd3dtZne(8UQMm3q46fzUHJiTUE(GIoSfF(0(HyPiwmgwamlnneoS0JLohF0uOIW1lIfGNfLlUywqclaSyw6ZcGzPPHWHLESOUAnl(8bVguuL6IGgOPJYRIHAFS4ZdaXcsyXyyPV5giHdZhDpmn3qQRdlTFeMfd70TtdlhKLfMyz78P9dXYNSSb1(WIH9pSZYJzXpwqdlNpOOddyLzPbhwie0uGfawmYLLohF0uGf4WIXWY25dEnOiwq)UiObA6O8ybFEaiS5gcFQP3rMB4ZN2pu9ZkgQ9X8mJfabKMg3CJsxvtGMX2CdgzUHPZCZd3dtZne(8UQMm3q46fzUPmliHfCeP11DhFelaJfaArdlayw6XsXwaYcWZcoI0665dk6Ww85t7hIfGNLESOmlaMLZ1uEwmCPRWw92PAdoe(Su6QAcKfGNfLTOHL(S0NfaZsXwLrdlaplQRwZoockHlCTnugJc2H68pXMBGeomF09W0CdPUoS0(rywmSt3onSCqwqog)2zbCnFIIL4WqzmkyUHWNA6DK5MHXV96N12qzmkyEMXkUfBACZnkDvnbAgBZnpCpmn3mm(TBUbs4W8r3dtZT4etSGCm(TZYNSSb1(Wc6h0FeMyboS8nwsilBNpTFiwm8AnlT)y5ZdYcsJjsm2mWINf6GdzUfM)O5DZTESqb9hHjREL(utczhlLLSqb9hHjRNfQjHSJffSGWN3v1K9X1GMCeel9zrbl9y58bfD277O6bRGpXsrSymSuwYcf0FeMS6v6t9ZkazPSKL2JA)Qd15FIzbySOCXS0NLYswuxTMLc6pctvmu7JDOo)tmlaJfpCpmT4ZN2pKLqgfwhvVVJyrblQRwZsb9hHPkgQ9XUIyPSKfkO)imz)SIHAFyrblgXccFExvtw85t7hQ(zfd1(WszjlQRwZg86Nb7qD(NywaglE4EyAXNpTFilHmkSoQEFhXIcwmIfe(8UQMSpUg0KJGyrblQRwZg86Nb7qD(NywagleYOW6O69DelkyrD1A2Gx)myxrSuwYI6Q1SJJGs4cxBdLXOGDfXIcwq4Z7QAYAy8BV(zTnugJcSuwYIrSGWN3v1K9X1GMCeelkyrD1A2Gx)myhQZ)eZsrSqiJcRJQ33rMNzSIRYMg3CJsxvtGMX2CdKWH5JUhMMBXjMyz78P9dXY3y5twqVv6dlOFq)rycTS8jlBqTpSG(b9hHjwGjlgdGz58bfDywGdlhKLObgyzdQ9Hf0pO)imzU5H7HP5g(8P9dzEMXkUa004MBu6QAc0m2MBGeomF09W0Clo4A9TplZnpCpmn3Mvw9W9WSQF8zUPF8vtVJm3AUwF7ZY8mpZTMR13(SmnUzSu204MBu6QAc0m2MBE4EyAUHpFWRbfzUbs4W8r3dtZTTZh8AqrS0GdlDqeuhLhlRutymll8NOyj2WyACZTW8hnVBUzelZkPgCqrwvx7zGQWw1166T)jkSLaURpkIanpZybqtJBUrPRQjqZyBU5H7HP5gELTFiZTqHGMQNpOOdBglLn3cZF08U5gi8SDqy2(HSd15FIzPiwgQZ)eZcWZcabiliHfLbeMBGeomF09W0CdPo(y52jwaHhlg(BNLBNyPdIpwUVJy5GS4GGSSY71SC7elDoYybCn(9WKLhZY(Fww2wz7hILH68pXS0T03hPFcKLdYsNFHDw6GWS9dXc4A87HP5zgR4AACZnpCpmn36GWS9dzUrPRQjqZyBEMN5g(mnUzSu204MBu6QAc0m2MBE4EyAUHpFWRbfzUbs4W8r3dtZT4etSSD(GxdkILdYcqefXYkILBNyjooK3P(jinSOUAnw(gl)XIb4sdYcHSOFiwuPgCiwAF(49prXYTtSKeYowco(yboSCqwaxDrSOsn4qSGuyIacezUfM)O5DZTzLudoOi79DKb4KvWH8o1pbPXsPRQjqwuWspwOG(JWK9ZQNfyrblgXspw6XI6Q1S33rgGtwbhY7u)eKg7qD(NywkIfpCpmTgg)2TeYOW6O69DelaMLITkZIcw6Xcf0FeMSFwvH3olLLSqb9hHj7Nvmu7dlLLSqb9hHjREL(utczhl9zPSKf1vRzVVJmaNScoK3P(jin2H68pXSuelE4EyAXNpTFilHmkSoQEFhXcGzPyRYSOGLESqb9hHj7Nv9k9HLYswOG(JWKfd1(utczhlLLSqb9hHjRNfQjHSJL(S0NLYswmIf1vRzVVJmaNScoK3P(jin2vel9zPSKLESOUAnBWRFgSRiwklzbHpVRQjBaMiGarvqcxidS0NffSeGqni0qAdWebeiQE7ufh9ZFy7qoybwuWsaIGsppB(O2VAZjw6ZIcw6XIrSeGiO0ZZcuH59KLYswcqOgeAiTuxe0anvvycAhQZ)eZsrSaiyPplkyPhlQRwZg86Nb7kILYswmILaeQbHgsBWRFgSd5GfyPV5zglaAACZnkDvnbAgBZnpCpmn3Cqp6EeufBWNoZTqHGMQNpOOdBglLn3cZF08U5MrSacpRd6r3JGQyd(0vb9ohfzVpa0NOyrblgXIhUhMwh0JUhbvXg8PRc6DokY(zTPFu7hlkyPhlgXci8SoOhDpcQIn4txDNCT9(aqFIILYswaHN1b9O7rqvSbF6Q7KRTd15FIzPiwqdl9zPSKfq4zDqp6EeufBWNUkO35Oil(8aqSamwIllkybeEwh0JUhbvXg8PRc6DokYouN)jMfGXsCzrblGWZ6GE09iOk2GpDvqVZrr27da9jkZnqchMp6EyAUfNyILyc6r3JGyzZGpDSyyNswUDAiwEmljKfpCpcIfSbF6qlloMfTFeloMLiig)QAIfyYc2GpDSy4VDwailWHLgzGgwWNhacZcCybMS4SexaZc2GpDSGHSC7(XYTtSKKbwWg8PJfFMhbHzbaLf(yXBhnSC7(Xc2GpDSqil6hcBEMXkUMg3CJsxvtGMX2CZd3dtZTamrabIQ3ovXr)8h2CdKWH5JUhMMBXjMWSGuyIaceXY3ybPXejgBgy5XSSIyboSuaUyXhIfqcxidFIIfKgtKySzGfd)TZcsHjciqelEcYsb4IfFiwujn0algtXSetma0Clm)rZ7MBgXc4SEqBcRbqmlkyPhl9ybHpVRQjBaMiGarvqcxidSOGfJyjaHAqOH0g86Nb7qoybwuWIrSmRKAWbfzJMVdoGVRR(e88d1OLg7JLsxvtGSuwYI6Q1SbV(zWUIyPplkyXX346Ae0anSamwmMIzrbl9yrD1AwkO)imv1R0h7qD(NywkIfLlMLYswuxTMLc6pctvmu7JDOo)tmlfXIYfZsFwklzrfIXSOGL2JA)Qd15FIzbySOCXSOGfJyjaHAqOH0g86Nb7qoybw6BEMXYymnU5gLUQManJT5gmYCdtN5MhUhMMBi85DvnzUHW1lYCRhlQRwZoockHlCTnugJc2H68pXSuelOHLYswmIf1vRzhhbLWfU2gkJrb7kIL(SOGfJyrD1A2XrqjCHRTHYyuOI)ST019c4JM3TRiwuWspwuxTMfOpbhcSsDrqd00r5vPKguFmi7qD(NywaglOcG2ohzS0NffS0Jf1vRzPG(JWufd1(yhQZ)eZsrSGkaA7CKXszjlQRwZsb9hHPQEL(yhQZ)eZsrSGkaA7CKXszjl9yXiwuxTMLc6pctv9k9XUIyPSKfJyrD1AwkO)imvXqTp2vel9zrblgXY5AkplgQX3hilLUQMazPV5giHdZhDpmn3qkmb)7Hjln4WIR1Sacpml3UFS05arywWRHy52PcS4dLO7yzO2q4DcKfd7uYcachbLWfML4WqzmkWYUJzrtyml3UNSGgwWuaZYqD(NFIIf4WYTtSauH59Kf1vRXYJzXvHRJLdYsZ1AwGTglWHfplWc6h0FeMy5XS4QW1XYbzHqw0pK5gcFQP3rMBGWRoeWD9d1r5HnpZyHgtJBUrPRQjqZyBUbJm3W0zU5H7HP5gcFExvtMBiC9Im36XIrSOUAnlf0FeMQyO2h7kIffSyelQRwZsb9hHPQEL(yxrS0NLYswoxt5zXqn((azP0v1eO5giHdZhDpmn3qkmb)7Hjl3UFSe2Paqyw(glfGlw8HybUo8dsSqb9hHjwoilWuxGfq4XYTtdXcCy5rLWHy52Fmlg(BNLnOgFFGm3q4tn9oYCdeEv46WpivPG(JWK5zglaTPXn3O0v1eOzSn38W9W0CRdcZ2pK5wy(JM3n38OAyNcaXIcwq4Z7QAYccV6qa31puhLh2CluiOP65dk6WMXszZZmwahtJBUrPRQjqZyBU5H7HP5gELTFiZTW8hnVBU5r1WofaIffSGWN3v1KfeE1HaURFOokpS5wOqqt1Zhu0HnJLYMNzSaeMg3CJsxvtGMX2CZd3dtZn8rATp1M2hYClm)rZ7MBEunStbGyrbli85DvnzbHxDiG76hQJYdBUfke0u98bfDyZyPS5zglaPPXn3O0v1eOzSn38W9W0CRbNavHTA63AiZnqchMp6EyAUfNyIL4amwSatwcGSy4VD46yj4rrFIYClm)rZ7MBEunStbGmpZyPCXMg3CJsxvtGMX2CZd3dtZnQlcAGMQkmbn3ajCy(O7HP5wCIjwqo9j4qGSSf9ZFywm83olEwGfnmrXcLWfQDw0o((eflOFq)ryIfpbz5McSCqw0FsS8hlRiwm83olaWLg7dlEcYcsJjsm2myUfM)O5DZTES0Jf1vRzPG(JWufd1(yhQZ)eZsrSOCXSuwYI6Q1Suq)ryQQxPp2H68pXSuelkxml9zrblbiudcnK2Gx)myhQZ)eZsrSe3Izrbl9yrD1A2O57Gd476Qpbp)qnAPX(yr46fXcWybGgtXSuwYIrSmRKAWbfzJMVdoGVRR(e88d1OLg7JLaURpkIazPpl9zPSKf1vRzJMVdoGVRR(e88d1OLg7JfHRxelfPelae4umlLLSeGqni0qAdE9ZGDihSalkyXX346Ae0anSuelaYInpZyPSYMg3CJsxvtGMX2CdgzUHPZCZd3dtZne(8UQMm3q46fzUzelGZ6bTjSgaXSOGfe(8UQMSbWAaMG)9WKffS0JLESeGqni0qAPUOcd56kCatpdKDOo)tmlaJfLb0ahwaml9yrzLzb4zzwj1GdkYI)ST019c4JM3Tu6QAcKL(SOGfc4U(Oic0sDrfgY1v4aMEgiw6Zszjlo(gxxJGgOHLIuIfazXSOGLESyelNRP8ST1uOcBvsVsYsPRQjqwklzrD1A2Gx)mybxJFpmzPiwcqOgeAiTT1uOcBvsVsYouN)jMfaZcGGL(SOGfe(8UQMS3(8ADfteq0un4)XIcw6XI6Q1Sa9j4qGvQlcAGMokVkL0G6JbzxrSuwYIrSeGiO0ZZcuH59KL(SOGLZhu0zVVJQhSc(elfXI6Q1SbV(zWcUg)EyYcWZsXwGdlLLSOcXywuWs7rTF1H68pXSamwuxTMn41pdwW143dtwklzjarqPNNnFu7xT5elLLSOUAnRQgcb1l8zxrSOGf1vRzv1qiOEHp7qD(NywaglQRwZg86Nbl4A87HjlaMLESaizb4zzwj1GdkYgnFhCaFxx9j45hQrln2hlbCxFuebYsFw6ZIcwmIf1vRzdE9ZGDfXIcw6XIrSeGiO0ZZMpQ9R2CILYswcqOgeAiTbyIacevVDQIJ(5pSDfXszjlQqmMffS0Eu7xDOo)tmlaJLaeQbHgsBaMiGar1BNQ4OF(dBhQZ)eZcGzbqZszjlTh1(vhQZ)eZcYLfLbefZcWyrD1A2Gx)mybxJFpmzPV5giHdZhDpmn3ItmXcsJjsm2mWIH)2zbPWebeicjiN(eCiqw2I(5pmlEcYcimr3XcebngM)iwaGln2hwGdlg2PKLyRHqq9cFSyaU0GSqil6hIfvQbhIfKgtKySzGfczr)qyZne(utVJm3cG1amb)7HzfFMNzSugGMg3CJsxvtGMX2CZd3dtZTXrqjCHRTHYyuWCdKWH5JUhMMBXjMy52jwaqLYBVWWIH)2zXzbPXejgBgy529JLhNO7yPnWowaGln2hZTW8hnVBUPUAnBWRFgSd15FIzPiwugnSuwYI6Q1SbV(zWcUg)EyYcWyjUfZIcwq4Z7QAYgaRbyc(3dZk(mpZyPCCnnU5gLUQManJT5wy(JM3n3q4Z7QAYgaRbyc(3dZk(yrbl9yXiwuxTMn41pdwW143dtwkIL4wmlLLSyelbick98SiO82lmS0NLYswuxTMDCeucx4ABOmgfSRiwuWI6Q1SJJGs4cxBdLXOGDOo)tmlaJfajlaMLambx)zJgk8yQ66hv2r5zVVJQiC9IybWS0JfJyrD1AwvnecQx4ZUIyrblgXY5Akpl(8rdhqlLUQMazPV5MhUhMMBbst47DD11pQSJYZ8mJLYgJPXn3O0v1eOzSn3cZF08U5gcFExvt2aynatW)EywXN5MhUhMMBFg8j97HP5zglLrJPXn3O0v1eOzSn3GrMBy6m38W9W0CdHpVRQjZneUErMBgXsac1GqdPn41pd2HCWcSuwYIrSGWN3v1KnateqGOkiHlKbwuWsaIGsppB(O2VAZjwklzbCwpOnH1ai2CdKWH5JUhMMBaO6Z7QAILfMazbMS4QV(VNWSC7(XIbppwoilQelyhbbYsdoSG0yIeJndSGHSC7(XYTtfyXhkpwm44JazbaLf(yrLAWHy52PoZne(utVJm3WocQ2Gtn41pdMNzSugqBACZnkDvnbAgBZnpCpmn3ARPqf2QKELK5giHdZhDpmn3ItmHzjoarFw(glFYINSG(b9hHjw8eKLBEcZYbzr)jXYFSSIyXWF7SaaxASpOLfKgtKySzGfpbzjMGE09iiw2m4tN5wy(JM3n3OG(JWK9ZQNfyrblEunStbGyrblQRwZgnFhCaFxx9j45hQrln2hlcxViwagla0ykMffS0Jfq4zDqp6EeufBWNUkO35Oi79bG(eflLLSyelbick98SjfgOgoGS0NffSGWN3v1Kf7iOAdo1Gx)mWIcw6XI6Q1SJJGs4cxBdLXOGDOo)tmlaJfajlayw6XcAyb4zzwj1GdkYI)ST019c4JM3Tu6QAcKL(SOGf1vRzhhbLWfU2gkJrb7kILYswmIf1vRzhhbLWfU2gkJrb7kIL(MNzSug4yACZnkDvnbAgBZnpCpmn3WNpnxRn3ajCy(O7HP5wCIjwaqN0TZY25tZ1AwIgyaZY3yz78P5Anlpor3XYkYClm)rZ7MBQRwZct62X1iAcu09W0UIyrblQRwZIpFAUwBhQneE3v1K5zglLbeMg3CJsxvtGMX2Clm)rZ7MBQRwZIpF0Wb0ouN)jMfGXcAyrbl9yrD1AwkO)imvXqTp2H68pXSuelOHLYswuxTMLc6pctv9k9XouN)jMLIybnS0NffS44BCDncAGgwkIfazXMBE4EyAUf8mq6Q6Q1m3uxTwn9oYCdF(OHdO5zglLbKMg3CJsxvtGMX2CZd3dtZn85dEnOiZnqchMp6EyAUfhxDrywIjgaYIk1GdXcsHjciqell8NOy52jwqkmrabIyjatW)EyYYbzjStbGy5BSGuyIaceXYJzXd3Y16cS4QW1XYbzrLyj44ZClm)rZ7MBbick98S5JA)QnNyrbli85DvnzdWebeiQcs4czGffSeGqni0qAdWebeiQE7ufh9ZFy7qD(NywaglOHffSyelGZ6bTjSgaXMNzSayXMg3CJsxvtGMX2CZd3dtZn85tZ1AZnqchMp6EyAUfNyILTZNMR1Sy4VDw2osR9HL448TJfpbzjHSSD(OHdiAzXWoLSKqw2oFAUwZYJzzfHwwkaxS4dXYNSGER0hwq)G(JWeln4WcGaWykGzboSCqwIgyGfa4sJ9Hfd7uYIRcrqSailMLyIbGSahwCWi)Eeelyd(0XYUJzbqaymfWSmuN)5NOyboS8yw(KLM(rTFwwIf8iwUD)yzLG0WYTtSG9oILamb)7HjML)qhMfWimljTUX1SCqw2oFAUwZc4A(eflaiCeucxywIddLXOaAzXWoLSuaUqhil471AwOeKLvelg(BNfazXa2XrS0Gdl3oXI2XhlO0qvxJTMBH5pAE3C7CnLNfFKw7tfC(2zP0v1eilkyXiwoxt5zXNpA4aAP0v1eilkyrD1Aw85tZ1A7qTHW7UQMyrbl9yrD1AwkO)imv1R0h7qD(NywkIfablkyHc6pct2pR6v6dlkyrD1A2O57Gd476Qpbp)qnAPX(yr46fXcWybGOPywklzrD1A2O57Gd476Qpbp)qnAPX(yr46fXsrkXcartXSOGfhFJRRrqd0WsrSailMLYswaHN1b9O7rqvSbF6QGENJISd15FIzPiwaeSuwYIhUhMwh0JUhbvXg8PRc6DokY(zTPFu7hl9zrblbiudcnK2Gx)myhQZ)eZsrSOCXMNzSaOYMg3CJsxvtGMX2CZd3dtZn85dEnOiZnqchMp6EyAUfNyILTZh8AqrSaGoPBNLObgWS4jilGRUiwIjgaYIHDkzbPXejgBgyboSC7elaOs5TxyyrD1AS8ywCv46y5GS0CTMfyRXcCyPaCHoqwcEelXedan3cZF08U5M6Q1SWKUDCnOjFQiE8dt7kILYswuxTMfOpbhcSsDrqd00r5vPKguFmi7kILYswuxTMn41pd2velkyPhlQRwZoockHlCTnugJc2H68pXSamwqfaTDoYyb4zjqVMLES44BCDncAGgwqclXTyw6ZcGzjUSa8SCUMYZMKHAheMwkDvnbYIcwmILzLudoOil(Z2sx3lGpAE3sPRQjqwuWI6Q1SJJGs4cxBdLXOGDfXszjlQRwZg86Nb7qD(NywaglOcG2ohzSa8SeOxZspwC8nUUgbnqdliHL4wml9zPSKf1vRzhhbLWfU2gkJrHk(Z2sx3lGpAE3UIyPSKfJyrD1A2XrqjCHRTHYyuWUIyrblgXsac1GqdPDCeucx4ABOmgfSd5GfyPSKfJyjarqPNNfbL3EHHL(SuwYIJVX11iObAyPiwaKfZIcwOG(JWK9ZQNfmpZybqaAACZnkDvnbAgBZnpCpmn3WNp41GIm3ajCy(O7HP5MXNcSCqw6CGiwUDIfvcFSaBSSD(OHdilQfybFEaOprXYFSSIyb4U(aq6cS8jlEwGf0pO)imXI66ybaU0yFy5X5XIRcxhlhKfvILObgceO5wy(JM3n3oxt5zXNpA4aAP0v1eilkyXiwMvsn4GIS33rgGtwbhY7u)eKglLUQMazrbl9yrD1Aw85JgoG2velLLS44BCDncAGgwkIfazXS0NffSOUAnl(8rdhql(8aqSamwIllkyPhlQRwZsb9hHPkgQ9XUIyPSKf1vRzPG(JWuvVsFSRiw6ZIcwuxTMnA(o4a(UU6tWZpuJwASpweUErSamwaiWPywuWspwcqOgeAiTbV(zWouN)jMLIyr5IzPSKfJybHpVRQjBaMiGarvqcxidSOGLaebLEE28rTF1MtS038mJfaJRPXn3O0v1eOzSn3GrMBy6m38W9W0CdHpVRQjZneUErMBuq)ryY(zvVsFyb4zbqWcsyXd3dtl(8P9dzjKrH1r177iwamlgXcf0FeMSFw1R0hwaEw6XcGMfaZY5AkplgU0vyRE7uTbhcFwkDvnbYcWZsCzPpliHfpCpmTgg)2TeYOW6O69DelaMLITgdAybjSGJiTUU74JybWSuSfnSa8SCUMYZM(TgcxvDTNbYsPRQjqZnqchMp6EyAUH(4778JWSSdnWs3kSZsmXaqw8HybL)jbYsenSGPambn3q4tn9oYCZXraqA2OG5zglaAmMg3CJsxvtGMX2CZd3dtZn85dEnOiZnqchMp6EyAUfhxDrSSD(GxdkILpzXzb4aymfyzdQ9Hf0pO)imHwwaHj6ow00XYFSenWalaWLg7dl9UD)y5XSS7jOMazrTal0F70WYTtSSD(0CTMf9NelWHLBNyjMyayraYIzr)jXsdoSSD(GxdkQpAzbeMO7ybIGgdZFelEYca6KUDwIgyGfpbzrthl3oXIRcrqSO)Kyz3tqnXY25JgoGMBH5pAE3CZiwMvsn4GIS33rgGtwbhY7u)eKglLUQMazrbl9yrD1A2O57Gd476Qpbp)qnAPX(yr46fXcWybGaNIzPSKf1vRzJMVdoGVRR(e88d1OLg7JfHRxelaJfaIMIzrblNRP8S4J0AFQGZ3olLUQMazPplkyPhluq)ryY(zfd1(WIcwC8nUUgbnqdlaMfe(8UQMSoocasZgfyb4zrD1AwkO)imvXqTp2H68pXSaywaHNTTMcvyRs6vs27daHRd15FYcWZcaTOHLIybqumlLLSqb9hHj7Nv9k9HffS44BCDncAGgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQQxPp2H68pXSaywaHNTTMcvyRs6vs27daHRd15FYcWZcaTOHLIybqwml9zrblgXI6Q1SWKUDCnIMafDpmTRiwuWIrSCUMYZIpF0Wb0sPRQjqwuWspwcqOgeAiTbV(zWouN)jMLIyb4Wszjly4sR(jO92NxRRyIaIglLUQMazrblQRwZE7ZR1vmrarJfFEaiwaglXnUSaGzPhlZkPgCqrw8NTLUUxaF08ULsxvtGSa8SGgw6ZIcwApQ9RouN)jMLIyr5IlMffS0Eu7xDOo)tmlaJfawCXS0NffS0JLaeQbHgslqFcoeyfh9ZFy7qD(NywkIfGdlLLSyelbick98SavyEpzPV5zglaIgtJBUrPRQjqZyBU5H7HP5wsgQDqyAUbs4W8r3dtZT4etSaGectmlFYc6TsFyb9d6pctS4jilyhbXcYzCDdWXHLwZcasimzPbhwqAmrIXMbw8eKfKtFcoeilOFxe0anDuEMBH5pAE3CRhlQRwZsb9hHPQEL(yhQZ)eZsrSqiJcRJQ33rSuwYspwc7(GIWSOelaKffSmuy3huu9(oIfGXcAyPplLLSe29bfHzrjwIll9zrblEunStbGyrbli85DvnzXocQ2Gtn41pdMNzSaiG204MBu6QAc0m2MBH5pAE3CRhlQRwZsb9hHPQEL(yhQZ)eZsrSqiJcRJQ33rSOGfJyjarqPNNfOcZ7jlLLS0Jf1vRzb6tWHaRuxe0anDuEvkPb1hdYUIyrblbick98SavyEpzPplLLS0JLWUpOimlkXcazrbldf29bfvVVJybySGgw6ZszjlHDFqrywuIL4YszjlQRwZg86Nb7kIL(SOGfpQg2PaqSOGfe(8UQMSyhbvBWPg86NbwuWspwuxTMDCeucx4ABOmgfSd15FIzbyS0Jf0WcaMfaYcWZYSsQbhuKf)zBPR7fWhnVBP0v1eil9zrblQRwZoockHlCTnugJc2velLLSyelQRwZoockHlCTnugJc2vel9n38W9W0CB31TAheMMNzSaiWX04MBu6QAc0m2MBH5pAE3CRhlQRwZsb9hHPQEL(yhQZ)eZsrSqiJcRJQ33rSOGfJyjarqPNNfOcZ7jlLLS0Jf1vRzb6tWHaRuxe0anDuEvkPb1hdYUIyrblbick98SavyEpzPplLLS0JLWUpOimlkXcazrbldf29bfvVVJybySGgw6ZszjlHDFqrywuIL4YszjlQRwZg86Nb7kIL(SOGfpQg2PaqSOGfe(8UQMSyhbvBWPg86NbwuWspwuxTMDCeucx4ABOmgfSd15FIzbySGgwuWI6Q1SJJGs4cxBdLXOGDfXIcwmILzLudoOil(Z2sx3lGpAE3sPRQjqwklzXiwuxTMDCeucx4ABOmgfSRiw6BU5H7HP5wBP11oimnpZybqaHPXn3O0v1eOzSn3ajCy(O7HP5wCIjwqoGOplWKLaO5MhUhMMBg8zE4uHTkPxjzEMXcGastJBUrPRQjqZyBU5H7HP5g(8P9dzUbs4W8r3dtZT4etSSD(0(Hy5GSenWalBqTpSG(b9hHj0YcsJjsm2mWYUJzrtyml33rSC7EYIZcYX43oleYOW6iw0u7yboSatDbwqVv6dlOFq)ryILhZYkYClm)rZ7MBuq)ryY(zvVsFyPSKfkO)imzXqTp1Kq2Xszjluq)ryY6zHAsi7yPSKLESOUAnRbFMhovyRs6vs2velLLSGJiTUU74JybySuS1yqdlkyXiwcqeu65zrq5TxyyPSKfCeP11DhFelaJLITgdlkyjarqPNNfbL3EHHL(SOGf1vRzPG(JWuvVsFSRiwklzPhlQRwZg86Nb7qD(NywaglE4EyAnm(TBjKrH1r177iwuWI6Q1SbV(zWUIyPV5zgR4wSPXn3O0v1eOzSn3ajCy(O7HP5wCIjwqog)2zbE70y4Xelg2)WolpMLpzzdQ9Hf0pO)imHwwqAmrIXMbwGdlhKLObgyb9wPpSG(b9hHjZnpCpmn3mm(TBEMXkUkBACZnkDvnbAgBZnqchMp6EyAUfhCT(2NL5MhUhMMBZkRE4Eyw1p(m30p(QP3rMBnxRV9zzEMN5w0qbyNQFMg3mwkBACZnpCpmn3a6tWHaR4OF(dBUrPRQjqZyBEMXcGMg3CJsxvtGMX2CdgzUHPZCZd3dtZne(8UQMm3q46fzUvS5giHdZhDpmn3m(oXccFExvtS8ywW0XYbzPywm83oljKf85hlWKLfMy5MpbIomAzrzwmStjl3oXs7h8XcmjwEmlWKLfMqllaKLVXYTtSGPambz5XS4jilXLLVXIk82zXhYCdHp107iZnywxyQEZNarN5zgR4AACZnkDvnbAgBZnyK5MdcAU5H7HP5gcFExvtMBiC9Im3u2Clm)rZ7MB38jq0zpLTlSRQjwuWYnFceD2tzBac1GqdPfCn(9W0CdHp107iZnywxyQEZNarN5zglJX04MBu6QAc0m2MBWiZnhe0CZd3dtZne(8UQMm3q46fzUbqZTW8hnVBUDZNarN9aODHDvnXIcwU5tGOZEa0gGqni0qAbxJFpmn3q4tn9oYCdM1fMQ38jq0zEMXcnMg3CJsxvtGMX2CdgzU5GGMBE4EyAUHWN3v1K5gcFQP3rMBWSUWu9MpbIoZTW8hnVBUra31hfrG2pXHzDUQMQa3LN3QRcsi(aXszjleWD9rreOL6IkmKRRWbm9mqSuwYcbCxFuebAXWLwt39jQ6SulyUbs4W8r3dtZnJVtyILB(ei6WS4dXscpw81153hCTUalG0rHJazXXSatwwyIf85hl38jq0HTSetTbVaMfhe8tuSOmlDKNywUDQalgETMfxBWlGzrLyjAOgndbYYNGueLGuESaBSG1WZCdHRxK5MYMNzSa0Mg3CZd3dtZToimb6ZAdoDMBu6QAc0m2MNzSaoMg3CJsxvtGMX2CZd3dtZndJF7MB6pPAa0Ct5In3cZF08U5wpwOG(JWKvVsFQjHSJLYswOG(JWK9ZkgQ9HLYswOG(JWK9ZQk82zPSKfkO)imz9SqnjKDS03CdKWH5JUhMMBaWHco(ybGSGCm(TZINGS4SSD(GxdkIfyYYMXzXWF7SeRh1(XsCWjw8eKLydJPXzboSSD(0(HybE70y4XK5zglaHPXn3O0v1eOzSn3cZF08U5wpwOG(JWKvVsFQjHSJLYswOG(JWK9ZkgQ9HLYswOG(JWK9ZQk82zPSKfkO)imz9SqnjKDS0NffSenecRYwdJF7SOGfJyjAiewaAnm(TBU5H7HP5MHXVDZZmwastJBUrPRQjqZyBUfM)O5DZnJyzwj1GdkYQ6Apduf2QUwxV9prHTu6QAcKLYswmILaebLEE28rTF1MtSuwYIrSGJiTUE(GIoSfF(0CTMfLyrzwklzXiwoxt5zt)wdHRQU2ZazP0v1eilLLS0JfkO)imzXqTp1Kq2Xszjluq)ryY(zvVsFyPSKfkO)imz)SQcVDwklzHc6pctwplutczhl9n38W9W0CdF(0(HmpZyPCXMg3CJsxvtGMX2Clm)rZ7MBZkPgCqrwvx7zGQWw1166T)jkSLsxvtGSOGLaebLEE28rTF1MtSOGfCeP11Zhu0HT4ZNMR1SOelkBU5H7HP5g(8bVguK5zEMN5gcAWpmnJfalgGkxmGgGahZnd(KFIcBUHCetaeXYyJfY5akwyX47elFxeCowAWHf0bsnFPp0XYqa31peilyyhXIVoyNFeilHDprrylhp69jXIXaOybPWebnhbYY23HuwWfYZrglixwoilO3Yzb8r84hMSaJOXp4WspK0NLEkJS(woE07tIfJbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TC8O3NelObqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TC8O3NelaAaflifMiO5iqw2(oKYcUqEoYyb5YYbzb9wolGpIh)WKfyen(bhw6HK(S0dGiRVLJh9(Kyb4aOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(woE07tIfGdGIfKcte0CeilO7MpbIoRYwaa6y5GSGUB(ei6SNYwaa6yPharwFlhp69jXcWbqXcsHjcAocKf0DZNarNfGwaa6y5GSGUB(ei6ShaTaa0XspaIS(woE07tIfabGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B54rVpjwaKakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLJh9(Kyr5IbuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXIYkdOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(woE07tIfLbiGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6bqK13YXJEFsSOmabuSGuyIGMJazbD38jq0zv2caqhlhKf0DZNarN9u2caqhl9aiY6B54rVpjwugGakwqkmrqZrGSGUB(ei6Sa0caqhlhKf0DZNarN9aOfaGow6PmY6B54rVpjwuoUakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPharwFlhp69jXIYXfqXcsHjcAocKf0DZNarNvzlaaDSCqwq3nFceD2tzlaaDS0tzK13YXJEFsSOCCbuSGuyIGMJazbD38jq0zbOfaGowoilO7MpbIo7bqlaaDS0dGiRVLJh9(KyrzJbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9aiY6B5454roIjaIyzSXc5CaflSy8DILVlcohln4Wc6Igka7u9dDSmeWD9dbYcg2rS4Rd25hbYsy3tue2YXJEFsSexaflifMiO5iqwq3nFceDwLTaa0XYbzbD38jq0zpLTaa0XspaIS(woE07tIfJbqXcsHjcAocKf0DZNarNfGwaa6y5GSGUB(ei6ShaTaa0XspaIS(woE07tIfajGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B54rVpjwuUyaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YXZXJCetaeXYyJfY5akwyX47elFxeCowAWHf05qcDSmeWD9dbYcg2rS4Rd25hbYsy3tue2YXJEFsSOmGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow8Jf0han6XspLrwFlhp69jXsCbuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXcGgqXcsHjcAocKLTVdPSGlKNJmwqUixwoilO3YzPdcU0lmlWiA8doS0d52NLEkJS(woE07tIfanGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6bqK13YXJEFsSaCauSGuyIGMJazz77qkl4c55iJfKlYLLdYc6TCw6GGl9cZcmIg)Gdl9qU9zPNYiRVLJh9(Kyb4aOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(woE07tIfabGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B54rVpjwaKakwqkmrqZrGSS9DiLfCH8CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPharwFlhp69jXIYaeqXcsHjcAocKLTVdPSGlKNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9ugz9TC8O3NelkdibuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXcavgqXcsHjcAocKLTVdPSGlKNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9ugz9TC8O3NelamUakwqkmrqZrGSS9DiLfCH8CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPharwFlhp69jXcaJlGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B54rVpjwaiAauSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXcab0akwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLJh9(KybGacaflifMiO5iqw2(oKYcUqEoYyb5YYbzb9wolGpIh)WKfyen(bhw6HK(S0dGiRVLJh9(KybGasaflifMiO5iqw2(oKYcUqEoYyb5YYbzb9wolGpIh)WKfyen(bhw6HK(S0tzK13YXZXJCetaeXYyJfY5akwyX47elFxeCowAWHf01CT(2Nf6yziG76hcKfmSJyXxhSZpcKLWUNOiSLJh9(KybGakwqkmrqZrGSS9DiLfCH8CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPNYiRVLJNJh5iMaiILXglKZbuSWIX3jw(Ui4CS0GdlOdFOJLHaURFiqwWWoIfFDWo)iqwc7EIIWwoE07tIfLbuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXsCbuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlhp69jXIYkdOybPWebnhbYY23HuwWfYZrglixKllhKf0B5S0bbx6fMfyen(bhw6HC7ZspLrwFlhp69jXIYkdOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(woE07tIfLb0akwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLJh9(KybGkdOybPWebnhbYY23HuwWfYZrglixwoilO3Yzb8r84hMSaJOXp4WspK0NLEaez9TC8O3NelauzaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YXJEFsSaqacOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(woE07tIfagxaflifMiO5iqw2(oKYcUqEoYyb5YYbzb9wolGpIh)WKfyen(bhw6HK(S0lUiRVLJh9(KybGgdGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6bqK13YXJEFsSaqanGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B54rVpjwaiWbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TC8C8ihXearSm2yHCoGIfwm(oXY3fbNJLgCybDQq)qhldbCx)qGSGHDel(6GD(rGSe29efHTC8O3NelkdiauSGuyIGMJazz77qkl4c55iJfKllhKf0B5Sa(iE8dtwGr04hCyPhs6ZsV4IS(woE07tIfLbKakwqkmrqZrGSS9DiLfCH8CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPNYiRVLJNJ3y7IGZrGSaOzXd3dtw0p(WwoEZnCefmJLYfdqZTOb2EnzUH8iplX21EgiwIJZ6b54rEKNL4xjXcabKOLfawmavMJNJh5rEwq6UNOimGIJh5rEwaWSetqqcKLnO2hwIn5DwoEKh5zbaZcs39efbYY5dk6QFJLGJjmlhKLqHGMQNpOOdB54rEKNfamlaiOoiccKLvMuGWyFkWccFExvtyw69wYIwwIgcrfF(GxdkIfaCrSenecl(8bVguuFlhpYJ8SaGzjMiGpilrdfC89jkwqog)2z5BS8h6WSC7elggyIIf0pO)imz54rEKNfamlaiDGiwqkmrabIy52jw2I(5pmlol6)onXshCiwAAczVQMyP33yPaCXYUdMO7yz)pw(Jf83T0NNeCH1fyXWF7SeBa0X04SaywqkPj89UMLyQFuzhLhAz5p0bYcgOpQVLJh5rEwaWSaG0bIyPdIpwqx7rTF1H68pXOJfCGsFEiMfpksxGLdYIkeJzP9O2pmlWuxWYXZXJ8iplXmt45hbYsSDTNbILycarpwcEYIkXsdUsqw8JL97IWakKGevx7zGaW4Vlyr93(s1(qKeBx7zGaWBFhsrshOD)60iNT9Asjvx7zGShYooEoEpCpmX2OHcWov)ucOpbhcSIJ(5pmhpYZIX3jwq4Z7QAILhZcMowoilfZIH)2zjHSGp)ybMSSWel38jq0HrllkZIHDkz52jwA)GpwGjXYJzbMSSWeAzbGS8nwUDIfmfGjilpMfpbzjUS8nwuH3ol(qC8E4EyITrdfGDQ(byLqccFExvtOn9osjywxyQEZNarhAr46fPuXC8E4EyITrdfGDQ(byLqccFExvtOn9osjywxyQEZNarhAHrk5GGOfHRxKskJ2VP0nFceDwLTlSRQjf38jq0zv2gGqni0qAbxJFpm549W9WeBJgka7u9dWkHee(8UQMqB6DKsWSUWu9MpbIo0cJuYbbrlcxViLaiA)Ms38jq0zbODHDvnP4MpbIolaTbiudcnKwW143dtoEKNfJVtyILB(ei6WS4dXscpw81153hCTUalG0rHJazXXSatwwyIf85hl38jq0HTSetTbVaMfhe8tuSOmlDKNywUDQalgETMfxBWlGzrLyjAOgndbYYNGueLGuESaBSG1WJJ3d3dtSnAOaSt1paResq4Z7QAcTP3rkbZ6ct1B(ei6qlmsjheeTiC9Iusz0(nLiG76JIiq7N4WSoxvtvG7YZB1vbjeFGkljG76JIiql1fvyixxHdy6zGkljG76JIiqlgU0A6UprvNLAboEpCpmX2OHcWov)aSsiPdctG(S2GthhpYZcaCOGJpwailihJF7S4jilolBNp41GIybMSSzCwm83olX6rTFSehCIfpbzj2WyACwGdlBNpTFiwG3ongEmXX7H7Hj2gnua2P6hGvcjgg)2rR(tQgavs5Ir73uQhf0FeMS6v6tnjKDLLuq)ryY(zfd1(uwsb9hHj7Nvv4Txwsb9hHjRNfQjHSRphVhUhMyB0qbyNQFawjKyy8BhTFtPEuq)ryYQxPp1Kq2vwsb9hHj7Nvmu7tzjf0FeMSFwvH3Ezjf0FeMSEwOMeYU(kIgcHvzRHXVDfgfneclaTgg)2549W9WeBJgka7u9dWkHe85t7hcTFtjJMvsn4GISQU2ZavHTQR11B)tu4YsJcqeu65zZh1(vBovwAeoI0665dk6Ww85tZ1ALuUS0OZ1uE20V1q4QQR9mqwkDvnbww2Jc6pctwmu7tnjKDLLuq)ryY(zvVsFklPG(JWK9ZQk82llPG(JWK1Zc1Kq21NJ3d3dtSnAOaSt1paResWNp41GIq73uAwj1GdkYQ6Apduf2QUwxV9prHveGiO0ZZMpQ9R2CsboI0665dk6Ww85tZ1ALuMJNJh5rEwqFKrH1rGSqiOPal33rSC7elE4GdlpMfhH)AxvtwoEpCpmXkHHAFQQK3XXJ8SSrhMLycrFwGjlXfWSy4VD46ybC(2XINGSy4VDw2oF0WbKfpbzbGaMf4TtJHhtC8E4EyIbSsibHpVRQj0MEhP0JRoKqlcxViLWrKwxpFqrh2IpFAUwxKYk6z05Akpl(8rdhqlLUQMallpxt5zXhP1(ubNVDwkDvnb2VSehrAD98bfDyl(8P5ADraKJh5zzJomlbn5iiwmStjlBNpTFiwcEYY(FSaqaZY5dk6WSyy)d7S8ywgsti88yPbhwUDIf0pO)imXYbzrLyjAOgndbYINGSyy)d7S0ETMgwoilbhFC8E4EyIbSsibHpVRQj0MEhP0JRbn5ii0IW1lsjCeP11Zhu0HT4ZN2purkZXJ8SeNyILytdMgG(eflg(BNfKgtKySzGf4WI3oAybPWebeiILpzbPXejgBg449W9WedyLqIknyAa6tuO9Bk1ZOaebLEE28rTF1MtLLgfGqni0qAdWebeiQE7ufh9ZFy7kQVc1vRzdE9ZGDOo)tCrkJgfQRwZoockHlCTnugJc2H68pXaZyuyuaIGspplckV9ctzzaIGspplckV9cJc1vRzdE9ZGDfPqD1A2XrqjCHRTHYyuWUIu0tD1A2XrqjCHRTHYyuWouN)jgykRmagna)SsQbhuKf)zBPR7fWhnVxwQUAnBWRFgSd15FIbMYkxwQmYfhrADD3XhbmLTObn954rEwaGWJfd)TZIZcsJjsm2mWYT7hlpor3XIZcaCPX(Ws0adSahwmStjl3oXs7rTFS8ywCv46y5GSqjihVhUhMyaResIG3dt0(nLuxTMn41pd2H68pXfPmAu0ZOzLudoOil(Z2sx3lGpAEVSuD1A2XrqjCHRTHYyuWouN)jgykdCuOUAn74iOeUW12qzmkyxr9llvHySI2JA)Qd15FIbgardhpYZcsDDyP9JWSyyNUDAyzH)eflifMiGarSKqdSy41AwCTgAGLcWflhKf89AnlbhFSC7elyVJyX7GR8yb2ybPWebeicWinMiXyZalbhFyoEpCpmXawjKGWN3v1eAtVJukateqGOkiHlKb0IW1lsPa96E9ApQ9RouN)jgaRmAaWbiudcnK2Gx)myhQZ)e3h5QmGO4(kfOx3Rx7rTF1H68pXayLrdawzawmaoaHAqOH0gGjciqu92Pko6N)W2H68pX9rUkdikUVcJg)bReckpRdcITeYE8HlldqOgeAiTbV(zWouN)jUOppAIGA)iWA7rTF1H68pXLLbiudcnK2amrabIQ3ovXr)8h2ouN)jUOppAIGA)iWA7rTF1H68pXayLlUS0OaebLEE28rTF1MtLLE4EyAdWebeiQE7ufh9ZFyl4JDvnbYXJ8SeNycKLdYciP9cSC7ellSJIyb2ybPXejgBgyXWoLSSWFIIfq4svtSatwwyIfpbzjAieuESSWokIfd7uYINS4GGSqiO8y5XS4QW1XYbzb8joEpCpmXawjKGWN3v1eAtVJukawdWe8VhMOfHRxKs9oFqrN9(oQEWk4tfPmAklh)bReckpRdcITFweAkUVIE96zebCxFuebAPUOcd56kCatpduzzVEbiudcnKwQlQWqUUchW0ZazhQZ)edmLb0fxwgGiO0ZZIGYBVWOiaHAqOH0sDrfgY1v4aMEgi7qD(NyGPmGg4a4EkRmWpRKAWbfzXF2w66Eb8rZ797RWOaeQbHgsl1fvyixxHdy6zGSd5Gf63xrpJiG76JIiqlgU0A6UprvNLAHYsJcqeu65zZh1(vBovwgGqni0qAXWLwt39jQ6SuluJRXGgarXkBhQZ)edmLv2y6RONreWD9rreO9tCywNRQPkWD55T6QGeIpqLLbiudcnK2pXHzDUQMQa3LN3QRcsi(azhYbl0xrVaeQbHgsRknyAa6tu2HCWcLLgnEGS3a16(LL96HWN3v1KfM1fMQ38jq0PKYLLi85DvnzHzDHP6nFceDkf3(k6DZNarNvz7qoyHAac1Gqdzz5nFceDwLTbiudcnK2H68pXf95rteu7hbwBpQ9RouN)jgaRCX9llr4Z7QAYcZ6ct1B(ei6ucGk6DZNarNfG2HCWc1aeQbHgYYYB(ei6Sa0gGqni0qAhQZ)ex0NhnrqTFeyT9O2V6qD(NyaSYf3VSeHpVRQjlmRlmvV5tGOtPI73VSmarqPNNfOcZ7zFoEpCpmXawjKGWN3v1eAtVJu62NxRRyIaIMQb)p0IW1lsjJWWLw9tq7TpVwxXebenwkDvnbww2Eu7xDOo)tCraS4IllvHySI2JA)Qd15FIbgardG7zmfdGvxTM92NxRRyIaIgl(8aqapa7xwQUAn7TpVwxXebenw85bGkkUacaCVzLudoOil(Z2sx3lGpAEh4rtFoEKNL4etSG(DrfgY1SaGEatpdelaSymfWSOsn4qS4SG0yIeJndSSWKLJ3d3dtmGvcjlmv)J6qB6DKsuxuHHCDfoGPNbcTFtPaeQbHgsBWRFgSd15FIbgalwrac1GqdPnateqGO6TtvC0p)HTd15FIbgalwrpe(8UQMS3(8ADfteq0un4)vwQUAn7TpVwxXebenw85bGkkUfd4EZkPgCqrw8NTLUUxaF08oWdO73VSufIXkApQ9RouN)jgyXf4WXJ8SeNyILn4sRP7tuSaGyPwGfanMcywuPgCiwCwqAmrIXMbwwyYYX7H7HjgWkHKfMQ)rDOn9osjmCP10DFIQol1cO9BkfGqni0qAdE9ZGDOo)tmWa0kmkarqPNNfbL3EHrHrbick98S5JA)QnNkldqeu65zZh1(vBoPiaHAqOH0gGjciqu92Pko6N)W2H68pXadqROhcFExvt2amrabIQGeUqgkldqOgeAiTbV(zWouN)jgya6(LLbick98SiO82lmk6z0SsQbhuKf)zBPR7fWhnVRiaHAqOH0g86Nb7qD(NyGbOllvxTMDCeucx4ABOmgfSd15FIbMYgdG7HgGNaURpkIaTFIVzfo4GRGpIpPQkP19vOUAn74iOeUW12qzmkyxr9llvHySI2JA)Qd15FIbgardhVhUhMyaReswyQ(h1H207iL(ehM15QAQcCxEERUkiH4deA)MsQRwZg86Nb7qD(N4Iugnk6z0SsQbhuKf)zBPR7fWhnVxwQUAn74iOeUW12qzmkyhQZ)edmLbiG7fxGxD1AwvnecQx4ZUI6d4E9aoay0a8QRwZQQHqq9cF2vuFGNaURpkIaTFIVzfo4GRGpIpPQkP19vOUAn74iOeUW12qzmkyxr9llvHySI2JA)Qd15FIbgardhpYZIX3FmlpMfNLXVDAyH0UkC8JyXGxGLdYsNdeXIR1SatwwyIf85hl38jq0Hz5GSOsSO)KazzfXIH)2zbPXejgBgyXtqwqkmrabIyXtqwwyILBNybGjilyn8ybMSeaz5BSOcVDwU5tGOdZIpelWKLfMybF(XYnFceDyoEpCpmXawjKSWu9pQdJwSgEyLU5tGOtz0(nLq4Z7QAYcZ6ct1B(ei6ucGkm6MpbIolaTd5GfQbiudcnKLL9q4Z7QAYcZ6ct1B(ei6us5Yse(8UQMSWSUWu9MpbIoLIBFf9uxTMn41pd2vKIEgfGiO0ZZIGYBVWuwQUAn74iOeUW12qzmkyhQZ)ed4EOb4Nvsn4GIS4pBlDDVa(O59(atPB(ei6SkBvxTwfCn(9WuH6Q1SJJGs4cxBdLXOGDfvwQUAn74iOeUW12qzmkuXF2w66Eb8rZ72vu)YYaeQbHgsBWRFgSd15FIbmal6MpbIoRY2aeQbHgsl4A87HPIEgfGiO0ZZMpQ9R2CQS0ie(8UQMSbyIacevbjCHm0xHrbick98SavyEplldqeu65zZh1(vBoPaHpVRQjBaMiGarvqcxidkcqOgeAiTbyIacevVDQIJ(5pSDfPWOaeQbHgsBWRFgSRif96PUAnlf0FeMQ6v6JDOo)tCrkxCzP6Q1Suq)ryQIHAFSd15FIls5I7RWOzLudoOiRQR9mqvyR6AD92)efUSSN6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqkHMYs1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGucq0VFzP6Q1Sa9j4qGvQlcAGMokVkL0G6Jbzxr9llvHySI2JA)Qd15FIbgalUSeHpVRQjlmRlmvV5tGOtPI549W9WedyLqYct1)OomAXA4Hv6MpbIoaI2VPecFExvtwywxyQEZNarNrkbqfgDZNarNvz7qoyHAac1GqdzzjcFExvtwywxyQEZNarNsaurp1vRzdE9ZGDfPONrbick98SiO82lmLLQRwZoockHlCTnugJc2H68pXaUhAa(zLudoOil(Z2sx3lGpAEVpWu6MpbIolaTQRwRcUg)EyQqD1A2XrqjCHRTHYyuWUIklvxTMDCeucx4ABOmgfQ4pBlDDVa(O5D7kQFzzac1GqdPn41pd2H68pXagGfDZNarNfG2aeQbHgsl4A87HPIEgfGiO0ZZMpQ9R2CQS0ie(8UQMSbyIacevbjCHm0xHrbick98SavyEpv0Zi1vRzdE9ZGDfvwAuaIGspplckV9ct)YYaebLEE28rTF1Mtkq4Z7QAYgGjciqufKWfYGIaeQbHgsBaMiGar1BNQ4OF(dBxrkmkaHAqOH0g86Nb7ksrVEQRwZsb9hHPQEL(yhQZ)exKYfxwQUAnlf0FeMQyO2h7qD(N4IuU4(kmAwj1GdkYQ6Apduf2QUwxV9prHll7PUAnRQR9mqvyR6AD92)efUM(TgYIppaKsOPSuD1Awvx7zGQWw1166T)jkC1NGNKfFEaiLae973VSuD1AwG(eCiWk1fbnqthLxLsAq9XGSROYsvigRO9O2V6qD(NyGbWIllr4Z7QAYcZ6ct1B(ei6uQyoEKNL4etywCTMf4TtdlWKLfMy5pQdZcmzjaYX7H7HjgWkHKfMQ)rDy0(nLuxTMn41pd2vuzzaIGsppB(O2VAZjfi85DvnzdWebeiQcs4czqrac1GqdPnateqGO6TtvC0p)HTRifgfGqni0qAdE9ZGDfPOxp1vRzPG(JWuvVsFSd15FIls5IllvxTMLc6pctvmu7JDOo)tCrkxCFfgnRKAWbfzvDTNbQcBvxRR3(NOWLLZkPgCqrwvx7zGQWw1166T)jkSIEQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdavuCllvxTMv11EgOkSvDTUE7FIcx9j4jzXNhaQO42VFzP6Q1Sa9j4qGvQlcAGMokVkL0G6JbzxrLLQqmwr7rTF1H68pXadGfZXJ8SehPWdsS4H7Hjl6hFSO6ycKfyYc(VLFpmrIMq9yoEpCpmXawjKmRS6H7Hzv)4dTP3rk5qcT4B(WPKYO9BkHWN3v1K9XvhsC8E4EyIbSsizwz1d3dZQ(XhAtVJusf6hAX38HtjLr73uAwj1GdkYQ6Apduf2QUwxV9prHTeWD9rreihVhUhMyaResMvw9W9WSQF8H207iLWhhphpYZcsDDyP9JWSyyNUDAy52jwIJd5Db)c70WI6Q1yXWR1S0CTMfyRXIH)2)KLBNyjjKDSeC8XX7H7Hj26qsje(8UQMqB6DKsGd5DvdVwxBUwxHTgAr46fPup1vRzVVJmaNScoK3P(jin2H68pXadva025idWfBvUSuD1A277idWjRGd5DQFcsJDOo)tmW8W9W0IpFA)qwczuyDu9(ocWfBvwrpkO)imz)SQxPpLLuq)ryYIHAFQjHSRSKc6pctwplutczx)(kuxTM9(oYaCYk4qEN6NG0yxrkMvsn4GIS33rgGtwbhY7u)eKgoEKNfK66Ws7hHzXWoD70WY25dEnOiwEmlgGZTZsWX3NOybIGgw2oFA)qS8jlO3k9Hf0pO)imXX7H7Hj26qcWkHee(8UQMqB6DKspQeoufF(GxdkcTiC9IuYikO)imz)SIHAFu0dhrAD98bfDyl(8P9dveAuCUMYZIHlDf2Q3ovBWHWNLsxvtGLL4isRRNpOOdBXNpTFOIao954rEwItmXcsHjciqelg2PKf)yrtyml3UNSGMIzjMyailEcYI(tILvelg(BNfKgtKySzGJ3d3dtS1HeGvcjbyIacevVDQIJ(5pmA)MsgboRh0MWAaeROxpe(8UQMSbyIacevbjCHmOWOaeQbHgsBWRFgSd5GfklvxTMn41pd2vuFf9uxTMLc6pctv9k9XouN)jUiaDzP6Q1Suq)ryQIHAFSd15FIlcq3xrpJMvsn4GISQU2ZavHTQR11B)tu4Ys1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkkULLQRwZQ6Apduf2QUwxV9prHR(e8KS4ZdavuC7xwQcXyfTh1(vhQZ)edmLlwHrbiudcnK2Gx)myhYbl0NJh5zjoXelXHHYyuGfd)TZcsJjsm2mWX7H7Hj26qcWkHKXrqjCHRTHYyuaTFtj1vRzdE9ZGDOo)tCrkJgoEKNL4etSSTY2pelFYsKNGu3hybMS4zHB)tuSC7(XI(rqywu2yWuaZINGSOjmMfd)TZshCiwoFqrhMfpbzXpwUDIfkbzb2yXzzdQ9Hf0pO)imXIFSOSXWcMcywGdlAcJzzOo)ZprXIJz5GSKWJLDhXNOy5GSmuBi8olGR5tuSGER0hwq)G(JWehVhUhMyRdjaResWRS9dH2qHGMQNpOOdRKYO9Bk1BO2q4DxvtLLQRwZsb9hHPkgQ9XouN)jgyXvbf0FeMSFwXqTpkgQZ)edmLngfNRP8Sy4sxHT6Tt1gCi8zP0v1eyFfNpOOZEFhvpyf8PIu2yaW4isRRNpOOdd4H68pXk6rb9hHj7NvpluwouN)jgyOcG2ohz954rEwqoruelRiw2oFAUwZIFS4Anl33rywwPMWyww4prXc6vi4JJzXtqw(JLhZIRcxhlhKLObgyboSOPJLBNybhrH31S4H7Hjl6pjwujn0al7EcQjwIJd5DQFcsdlWKfaYY5dk6WC8E4EyIToKaSsibF(0CTgTFtjJoxt5zXhP1(ubNVDwkDvnbQON6Q1S4ZNMR12HAdH3DvnPOhoI0665dk6Ww85tZ1AGf3YsJMvsn4GIS33rgGtwbhY7u)eKM(LLNRP8Sy4sxHT6Tt1gCi8zP0v1eOc1vRzPG(JWufd1(yhQZ)edS4QGc6pct2pRyO2hfQRwZIpFAUwBhQZ)edmGJcCeP11Zhu0HT4ZNMR1fPKX0xrpJMvsn4GIS6cbFCCTPj6(evfL(7IWuz59DeYf5AmOPi1vRzXNpnxRTd15FIbma7R48bfD277O6bRGpveA44rEwqo(BNLTJ0AFyjooF7yzHjwGjlbqwmStjld1gcV7QAIf11Xc(ETMfd(FS0GdlOxHGpoMLObgyXtqwaHj6owwyIfvQbhIfKghXww2UxRzzHjwuPgCiwqkmrabIyb)zGy529JfdVwZs0adS4j82PHLTZNMR1C8E4EyIToKaSsibF(0CTgTFtPZ1uEw8rATpvW5BNLsxvtGkuxTMfF(0CT2ouBi8URQjf9mAwj1GdkYQle8XX1MMO7tuvu6VlctLL33rixKRXGMImM(koFqrN9(oQEWk4tffxoEKNfKJ)2zjooK3P(jinSSWelBNpnxRz5GSaerrSSIy52jwuxTglQfyX1yill8NOyz78P5AnlWKf0WcMcWeeZcCyrtymld15F(jkoEpCpmXwhsawjKGpFAUwJ2VP0SsQbhuK9(oYaCYk4qEN6NG0OahrAD98bfDyl(8P5ADrkfxf9msD1A277idWjRGd5DQFcsJDfPqD1Aw85tZ1A7qTHW7UQMkl7HWN3v1KfCiVRA416AZ16kS1u0tD1Aw85tZ1A7qD(NyGf3YsCeP11Zhu0HT4ZNMR1fbqfNRP8S4J0AFQGZ3olLUQMavOUAnl(8P5ATDOo)tmWqt)(954rEwqQRdlTFeMfd70TtdlolBNp41GIyzHjwm8AnlbFHjw2oFAUwZYbzP5AnlWwdTS4jillmXY25dEnOiwoilaruelXXH8o1pbPHf85bGyzfXX7H7Hj26qcWkHee(8UQMqB6DKs4ZNMR1vdW8QnxRRWwdTiC9IuYX346Ae0anfbikga3t5IbE1vRzVVJmaNScoK3P(jinw85bG6dG7PUAnl(8P5ATDOo)tmWhxKloI066UJpc4n6CnLNfFKw7tfC(2zP0v1eyFaCVaeQbHgsl(8P5ATDOo)tmWhxKloI066UJpc4pxt5zXhP1(ubNVDwkDvnb2ha3deE22AkuHTkPxjzhQZ)ed8OPVIEQRwZIpFAUwBxrLLbiudcnKw85tZ1A7qD(N4(C8iplXjMyz78bVguelg(BNL44qEN6NG0WYbzbiIIyzfXYTtSOUAnwm83oCDSOH4prXY25tZ1Awwr33rS4jillmXY25dEnOiwGjlgdGzj2WyACwWNhacZYkVxZIXWY5dk6WC8E4EyIToKaSsibF(GxdkcTFtje(8UQMSGd5DvdVwxBUwxHTMce(8UQMS4ZNMR1vdW8QnxRRWwtHri85DvnzFujCOk(8bVguuzzp1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkkULLQRwZQ6Apduf2QUwxV9prHR(e8KS4ZdavuC7RahrAD98bfDyl(8P5AnWmgfi85DvnzXNpnxRRgG5vBUwxHTghpYZsCIjwWg8PJfmKLB3pwkaxSGIow6CKXYk6(oIf1cSSWFIIL)yXXSO9JyXXSebX4xvtSatw0egZYT7jlXLf85bGWSahwaqzHpwmStjlXfWSGppaeMfczr)qC8E4EyIToKaSsiXb9O7rqvSbF6qBOqqt1Zhu0Hvsz0(nLm6(aqFIsHrE4EyADqp6EeufBWNUkO35Oi7N1M(rTFLLGWZ6GE09iOk2GpDvqVZrrw85bGawCvacpRd6r3JGQyd(0vb9ohfzhQZ)edS4YXJ8SaGGAdH3zbajeMTFiw(glinMiXyZalpMLHCWcOLLBNgIfFiw0egZYT7jlOHLZhu0Hz5twqVv6dlOFq)ryIfd)TZYg8IdOLfnHXSC7EYIYfZc82PXWJjw(KfplWc6h0FeMyboSSIy5GSGgwoFqrhMfvQbhIfNf0BL(Wc6h0FeMSSehHj6owgQneENfW18jkwqo9j4qGSG(Drqd00r5XYk1egZYNSSb1(Wc6h0FeM449W9WeBDibyLqsheMTFi0gke0u98bfDyLugTFtPHAdH3DvnP48bfD277O6bRGpvuVEkBmaUhoI0665dk6Ww85t7hc4biWRUAnlf0FeMQ6v6JDf1VpGhQZ)e3h52tzaFUMYZEg(S2bHj2sPRQjW(k6fGqni0qAdE9ZGDihSGcJaN1dAtynaIv0dHpVRQjBaMiGarvqcxidLLbiudcnK2amrabIQ3ovXr)8h2oKdwOS0OaebLEE28rTF1Mt9llXrKwxpFqrh2IpFA)qaRxpanaUN6Q1Suq)ryQQxPp2veWdW(9b(Ekd4Z1uE2ZWN1oimXwkDvnb2VVcJOG(JWKfd1(utczxzzpkO)imz)SIHAFkl7rb9hHj7Nvv4Txwsb9hHj7Nv9k9PVcJoxt5zXWLUcB1BNQn4q4ZsPRQjWYs1vRzJMVdoGVRR(e88d1OLg7JfHRxurkbq0uCFf9WrKwxpFqrh2IpFA)qat5Ib(Ekd4Z1uE2ZWN1oimXwkDvnb2VVchFJRRrqd0ueAkgaRUAnl(8P5ATDOo)tmWdO7RONrQRwZc0NGdbwPUiObA6O8QusdQpgKDfvwsb9hHj7Nvmu7tzPrbick98SavyEp7RWi1vRzhhbLWfU2gkJrHk(Z2sx3lGpAE3UI44rEwItmXsCaglwGjlbqwm83oCDSe8OOprXX7H7Hj26qcWkHKgCcuf2QPFRHq73uYJQHDkaehVhUhMyRdjaResq4Z7QAcTP3rkfaRbyc(3dZQdj0IW1lsjJaN1dAtynaIvGWN3v1KnawdWe8VhMk61tD1Aw85tZ1A7kQSS35Akpl(iT2Nk48TZsPRQjWYYaebLEE28rTF1Mt97RONrQRwZIHA89bYUIuyK6Q1SbV(zWUIu0ZOZ1uE22AkuHTkPxjzP0v1eyzP6Q1SbV(zWcUg)Eywuac1GqdPTTMcvyRs6vs2H68pXagq0xbcFExvt2BFETUIjciAQg8)u0ZOaebLEE28rTF1MtLLbiudcnK2amrabIQ3ovXr)8h2UIu0tD1Aw85tZ1A7qD(NyGbWYsJoxt5zXhP1(ubNVDwkDvnb2VVIZhu0zVVJQhSc(urQRwZg86Nbl4A87HjWxSf40VSufIXkApQ9RouN)jgyQRwZg86Nbl4A87HzFoEKNL4etSG0yIeJndSatwcGSSsnHXS4jil6pjw(JLvelg(BNfKcteqGioEpCpmXwhsawjKeinHV31vx)OYokp0(nLq4Z7QAYgaRbyc(3dZQdjoEpCpmXwhsawjK8zWN0VhMO9BkHWN3v1KnawdWe8VhMvhsC8iplXjMyb97IGgOHLydtqwGjlbqwm83olBNpnxRzzfXINGSGDeeln4WcaCPX(WINGSG0yIeJndC8E4EyIToKaSsiH6IGgOPQctq0(nLuHySIppAIGA)iWA7rTF1H68pXatz0uw2tD1A2O57Gd476Qpbp)qnAPX(yr46fbmaIMIllvxTMnA(o4a(UU6tWZpuJwASpweUErfPeartX9vOUAnl(8P5ATDfPOxac1GqdPn41pd2H68pXfHMIllbN1dAtynaI7ZXJ8SaGGAdH3zPP9HybMSSIy5GSexwoFqrhMfd)TdxhlinMiXyZalQ0NOyXvHRJLdYcHSOFiw8eKLeESarqtWJI(efhVhUhMyRdjaResWhP1(uBAFi0gke0u98bfDyLugTFtPHAdH3DvnP4(oQEWk4tfPmAuGJiTUE(GIoSfF(0(HaMXOWJQHDkaKIEQRwZg86Nb7qD(N4IuU4YsJuxTMn41pd2vuFoEKNL4etSehGOplFJLpXpiXINSG(b9hHjw8eKf9Nel)XYkIfd)TZIZcaCPX(Ws0adS4jilXe0JUhbXYMbF6449W9WeBDibyLqsBnfQWwL0RKq73uIc6pct2pREwqHhvd7uaifQRwZgnFhCaFxx9j45hQrln2hlcxViGbq0uSIEGWZ6GE09iOk2GpDvqVZrr27da9jQYsJcqeu65ztkmqnCallXrKwxpFqrhUia2xrp1vRzhhbLWfU2gkJrb7qD(NyGbibW9qdWpRKAWbfzXF2w66Eb8rZ79vOUAn74iOeUW12qzmkyxrLLgPUAn74iOeUW12qzmkyxr9v0ZOaeQbHgsBWRFgSROYs1vRzV9516kMiGOXIppaeWugnkApQ9RouN)jgyaS4Iv0Eu7xDOo)tCrkxCXLLgHHlT6NG2MFUU20UblLUQMa7ZXJ8SeNyIfNLTZNMR1SaGoPBNLObgyzLAcJzz78P5AnlpMfxpKdwGLvelWHLcWfl(qS4QW1XYbzbIGMGhXsmXaqoEpCpmXwhsawjKGpFAUwJ2VPK6Q1SWKUDCnIMafDpmTRif9uxTMfF(0CT2ouBi8URQPYshFJRRrqd0ueGS4(C8iplXXvxelXedazrLAWHybPWebeiIfd)TZY25tZ1Aw8eKLBNsw2oFWRbfXX7H7Hj26qcWkHe85tZ1A0(nLcqeu65zZh1(vBoPWOZ1uEw8rATpvW5BNLsxvtGk6HWN3v1KnateqGOkiHlKHYYaeQbHgsBWRFgSROYs1vRzdE9ZGDf1xrac1GqdPnateqGO6TtvC0p)HTd15FIbgQaOTZrgWhOx3ZX346Ae0anix0uCFfQRwZIpFAUwBhQZ)edmJrHrGZ6bTjSgaXC8E4EyIToKaSsibF(GxdkcTFtPaebLEE28rTF1Mtk6HWN3v1KnateqGOkiHlKHYYaeQbHgsBWRFgSROYs1vRzdE9ZGDf1xrac1GqdPnateqGO6TtvC0p)HTd15FIbgGwH6Q1S4ZNMR12vKckO)imz)S6zbfgHWN3v1K9rLWHQ4Zh8AqrkmcCwpOnH1aiMJh5zjoXelBNp41GIyXWF7S4jlaOt62zjAGbwGdlFJLcWf6azbIGMGhXsmXaqwm83olfGRHLKq2XsWXNLLyQXqwaxDrSetmaKf)y52jwOeKfyJLBNybavkV9cdlQRwJLVXY25tZ1AwmaxAWeDhlnxRzb2ASahwkaxS4dXcmzbGSC(GIomhVhUhMyRdjaResWNp41GIq73usD1Awys3oUg0Kpvep(HPDfvw2Zi85t7hY6r1WofasHri85DvnzFujCOk(8bVguuzzp1vRzdE9ZGDOo)tmWqJc1vRzdE9ZGDfvw2RN6Q1SbV(zWouN)jgyOcG2ohzaFGEDphFJRRrqd0GCJBX9vOUAnBWRFgSROYs1vRzhhbLWfU2gkJrHk(Z2sx3lGpAE3ouN)jgyOcG2ohzaFGEDphFJRRrqd0GCJBX9vOUAn74iOeUW12qzmkuXF2w66Eb8rZ72vuFfbick98SiO82lm97ROhoI0665dk6Ww85tZ1AGf3Yse(8UQMS4ZNMR1vdW8QnxRRWwRFFfgHWN3v1K9rLWHQ4Zh8Aqrk6z0SsQbhuK9(oYaCYk4qEN6NG0uwIJiTUE(GIoSfF(0CTgyXTphpYZsCIjwaqcHjMLpzzdQ9Hf0pO)imXINGSGDeelXHLwZcasimzPbhwqAmrIXMboEpCpmXwhsawjKKKHAheMO9Bk1tD1AwkO)imvXqTp2H68pXfriJcRJQ33rLL9c7(GIWkbqfdf29bfvVVJagA6xwg29bfHvkU9v4r1WofaIJ3d3dtS1HeGvcj7UUv7GWeTFtPEQRwZsb9hHPkgQ9XouN)jUiczuyDu9(oQSSxy3huewjaQyOWUpOO69DeWqt)YYWUpOiSsXTVcpQg2Paqk6PUAn74iOeUW12qzmkyhQZ)edm0OqD1A2XrqjCHRTHYyuWUIuy0SsQbhuKf)zBPR7fWhnVxwAK6Q1SJJGs4cxBdLXOGDf1NJ3d3dtS1HeGvcjTLwx7GWeTFtPEQRwZsb9hHPkgQ9XouN)jUiczuyDu9(osrVaeQbHgsBWRFgSd15FIlcnfxwgGqni0qAdWebeiQE7ufh9ZFy7qD(N4IqtX9ll7f29bfHvcGkgkS7dkQEFhbm00VSmS7dkcRuC7RWJQHDkaKIEQRwZoockHlCTnugJc2H68pXadnkuxTMDCeucx4ABOmgfSRifgnRKAWbfzXF2w66Eb8rZ7LLgPUAn74iOeUW12qzmkyxr954rEwItmXcYbe9zbMSG04ihVhUhMyRdjaResm4Z8WPcBvsVsIJh5zbPUoS0(rywmSt3onSCqwwyILTZN2pelFYYgu7dlg2)WolpMf)ybnSC(GIomGvMLgCyHqqtbwayXixw6C8rtbwGdlgdlBNp41GIyb97IGgOPJYJf85bGWC8E4EyIToKaSsibHpVRQj0MEhPe(8P9dv)SIHAFqlcxViLWrKwxpFqrh2IpFA)qfzmaUPHWPxNJpAkur46fb8kxCXixawCFa30q40tD1Aw85dEnOOk1fbnqthLxfd1(yXNhac5Am954rEwqQRdlTFeMfd70TtdlhKfKJXVDwaxZNOyjomugJcC8E4EyIToKaSsibHpVRQj0MEhPKHXV96N12qzmkGweUErkPmYfhrADD3XhbmaArdaUxXwac84isRRNpOOdBXNpTFiGVNYa(CnLNfdx6kSvVDQ2GdHplLUQMabELTOPFFaxSvz0a8QRwZoockHlCTnugJc2H68pXC8iplXjMyb5y8BNLpzzdQ9Hf0pO)imXcCy5BSKqw2oFA)qSy41AwA)XYNhKfKgtKySzGfpl0bhIJ3d3dtS1HeGvcjgg)2r73uQhf0FeMS6v6tnjKDLLuq)ryY6zHAsi7uGWN3v1K9X1GMCeuFf9oFqrN9(oQEWk4tfzmLLuq)ryYQxPp1pRaSSS9O2V6qD(NyGPCX9llvxTMLc6pctvmu7JDOo)tmW8W9W0IpFA)qwczuyDu9(osH6Q1Suq)ryQIHAFSROYskO)imz)SIHAFuyecFExvtw85t7hQ(zfd1(uwQUAnBWRFgSd15FIbMhUhMw85t7hYsiJcRJQ33rkmcHpVRQj7JRbn5iifQRwZg86Nb7qD(NyGriJcRJQ33rkuxTMn41pd2vuzP6Q1SJJGs4cxBdLXOGDfPaHpVRQjRHXV96N12qzmkuwAecFExvt2hxdAYrqkuxTMn41pd2H68pXfriJcRJQ33rC8iplXjMyz78P9dXY3y5twqVv6dlOFq)rycTS8jlBqTpSG(b9hHjwGjlgdGz58bfDywGdlhKLObgyzdQ9Hf0pO)imXX7H7Hj26qcWkHe85t7hIJh5zjo4A9TploEpCpmXwhsawjKmRS6H7Hzv)4dTP3rk1CT(2NfhphpYZsCyOmgfyXWF7SG0yIeJndC8E4EyITQq)uACeucx4ABOmgfq73usD1A2Gx)myhQZ)exKYOHJh5zjoXelXe0JUhbXYMbF6yXWoLS4hlAcJz529KfJHLydJPXzbFEaimlEcYYbzzO2q4DwCwaMsaKf85bGyXXSO9JyXXSebX4xvtSahwUVJy5pwWqw(JfFMhbHzbaLf(yXBhnS4SexaZc(8aqSqil6hcZX7H7Hj2Qc9dWkHeh0JUhbvXg8PdTHcbnvpFqrhwjLr73usD1Awvx7zGQWw1166T)jkCn9BnKfFEaiGbiuOUAnRQR9mqvyR6AD92)efU6tWtYIppaeWaek6zei8SoOhDpcQIn4txf07CuK9(aqFIsHrE4EyADqp6EeufBWNUkO35Oi7N1M(rTFk6zei8SoOhDpcQIn4txDNCT9(aqFIQSeeEwh0JUhbvXg8PRUtU2ouN)jUO42VSeeEwh0JUhbvXg8PRc6DokYIppaeWIRcq4zDqp6EeufBWNUkO35Oi7qD(NyGHgfGWZ6GE09iOk2GpDvqVZrr27da9jQ(C8iplXjMybPWebeiIfd)TZcsJjsm2mWIHDkzjcIXVQMyXtqwG3ongEmXIH)2zXzj2WyACwuxTglg2PKfqcxidFIIJ3d3dtSvf6hGvcjbyIacevVDQIJ(5pmA)MsgboRh0MWAaeROxpe(8UQMSbyIacevbjCHmOWOaeQbHgsBWRFgSd5GfklvxTMn41pd2vuFf9uxTMv11EgOkSvDTUE7FIcxt)wdzXNhasjarzP6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqkbi6xwQcXyfTh1(vhQZ)edmLlUphpYZsCaI(S4ywUDIL2p4Jfubqw(KLBNyXzj2WyACwm8ji0alWHfd)TZYTtSGCQW8EYI6Q1yboSy4VDwCwaeagtbwIjOhDpcILnd(0XINGSyW)JLgCybPXejgBgy5BS8hlgG5XIkXYkIfhL)jlQudoel3oXsaKLhZs7ZhVtGC8E4EyITQq)aSsiPTMcvyRs6vsO9Bk1Rxp1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkcqxwQUAnRQR9mqvyR6AD92)efU6tWtYIppaura6(k6zuaIGspplckV9ctzPrQRwZoockHlCTnugJc2vu)(k6boRh0MWAaexwgGqni0qAdE9ZGDOo)tCrOP4YYEbick98S5JA)QnNueGqni0qAdWebeiQE7ufh9ZFy7qD(N4IqtX973VSShi8SoOhDpcQIn4txf07CuKDOo)tCracfbiudcnK2Gx)myhQZ)exKYfRiarqPNNnPWa1WbSFzPkeJv85rteu7hbwBpQ9RouN)jgyacfgfGqni0qAdE9ZGDihSqzzaIGspplqfM3tfQRwZc0NGdbwPUiObA6O8SROYYaebLEEweuE7fgfQRwZoockHlCTnugJc2H68pXadqQqD1A2XrqjCHRTHYyuWUI44rEwqQNbsZY25JgoGSy4VDwCwsYalXggtJZI6Q1yXtqwqAmrIXMbwECIUJfxfUowoilQellmbYX7H7Hj2Qc9dWkHKGNbsxvxTgAtVJucF(OHdiA)Ms9uxTMv11EgOkSvDTUE7FIcxt)wdzhQZ)exeWXIMYs1vRzvDTNbQcBvxRR3(NOWvFcEs2H68pXfbCSOPVIEbiudcnK2Gx)myhQZ)exeWPSSxac1GqdPL6IGgOPQctq7qD(N4IaokmsD1AwG(eCiWk1fbnqthLxLsAq9XGSRifbick98SavyEp73xHJVX11iObAksP4wmhpYZsCC1fXY25dEnOimlg(BNfNLydJPXzrD1ASOUows4XIHDkzjcc1FIILgCybPXejgBgyboSGC6tWHazzl6N)WC8E4EyITQq)aSsibF(GxdkcTFtPEQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaveallvxTMv11EgOkSvDTUE7FIcx9j4jzXNhaQia2xrVaebLEE28rTF1MtLLbiudcnK2Gx)myhQZ)exeWPS0ie(8UQMSbWAaMG)9WuHrbick98SavyEpll7fGqni0qAPUiObAQQWe0ouN)jUiGJcJuxTMfOpbhcSsDrqd00r5vPKguFmi7ksraIGspplqfM3Z(9v0Ziq4zBRPqf2QKELK9(aqFIQS0OaeQbHgsBWRFgSd5GfklnkaHAqOH0gGjciqu92Pko6N)W2HCWc954rEwIJRUiw2oFWRbfHzrLAWHybPWebeiIJ3d3dtSvf6hGvcj4Zh8AqrO9Bk1laHAqOH0gGjciqu92Pko6N)W2H68pXadnkmcCwpOnH1aiwrpe(8UQMSbyIacevbjCHmuwgGqni0qAdE9ZGDOo)tmWqtFfi85DvnzdG1amb)7HzFfgbcpBBnfQWwL0RKS3ha6tukcqeu65zZh1(vBoPWiWz9G2ewdGyfuq)ryY(z1ZckC8nUUgbnqtrgtXC8iplXryIUJfq4Xc4A(efl3oXcLGSaBSaGWrqjCHzjomugJcOLfW18jkwa6tWHazH6IGgOPJYJf4WYNSC7elAhFSGkaYcSXINSG(b9hHjoEpCpmXwvOFawjKGWN3v1eAtVJuceE1HaURFOokpmAr46fPup1vRzhhbLWfU2gkJrb7qD(N4IqtzPrQRwZoockHlCTnugJc2vuFf9uxTMfOpbhcSsDrqd00r5vPKguFmi7qD(NyGHkaA7CK1xrp1vRzPG(JWufd1(yhQZ)exeQaOTZrwzP6Q1Suq)ryQQxPp2H68pXfHkaA7CK1NJ3d3dtSvf6hGvcj4v2(HqBOqqt1Zhu0Hvsz0(nLgQneE3v1KIZhu0zVVJQhSc(urkdOv4r1WofasbcFExvtwq4vhc4U(H6O8WC8E4EyITQq)aSsiPdcZ2peAdfcAQE(GIoSskJ2VP0qTHW7UQMuC(GIo79Du9GvWNks54ArJcpQg2Paqkq4Z7QAYccV6qa31puhLhMJ3d3dtSvf6hGvcj4J0AFQnTpeAdfcAQE(GIoSskJ2VP0qTHW7UQMuC(GIo79Du9GvWNkszanGhQZ)eRWJQHDkaKce(8UQMSGWRoeWD9d1r5H54rEwIdWyXcmzjaYIH)2HRJLGhf9jkoEpCpmXwvOFawjK0GtGQWwn9BneA)MsEunStbG44rEwq)UiObAyj2WeKfd7uYIRcxhlhKfkpAyXzjjdSeBymnolg(eeAGfpbzb7iiwAWHfKgtKySzGJ3d3dtSvf6hGvcjuxe0anvvycI2VPupkO)imz1R0NAsi7klPG(JWKfd1(utczxzjf0FeMSEwOMeYUYs1vRzvDTNbQcBvxRR3(NOW10V1q2H68pXfbCSOPSuD1Awvx7zGQWw1166T)jkC1NGNKDOo)tCrahlAklD8nUUgbnqtraYIveGqni0qAdE9ZGDihSGcJaN1dAtynaI7ROxac1GqdPn41pd2H68pXff3IlldqOgeAiTbV(zWoKdwOFzPkeJv85rteu7hbwBpQ9RouN)jgykxmhpYZsCaI(SmpQ9JfvQbhILf(tuSG0yYX7H7Hj2Qc9dWkHK2AkuHTkPxjH2VPuac1GqdPn41pd2HCWckq4Z7QAYgaRbyc(3dtf9C8nUUgbnqtraYIvyuaIGsppB(O2VAZPYYaebLEE28rTF1MtkC8nUUgbnqdWmMI7RWOaebLEEweuE7fgf9mkarqPNNnFu7xT5uzzac1GqdPnateqGO6TtvC0p)HTd5Gf6RWiWz9G2ewdGyoEKNfKgtKySzGfd7uYIFSailgWSetmaKLEWrdnqdl3UNSymfZsmXaqwm83olifMiGar9zXWF7W1XIgI)efl33rS8jlXwdHG6f(yXtqw0FsSSIyXWF7SGuyIaceXY3y5pwm4ywajCHmqGC8E4EyITQq)aSsibHpVRQj0MEhPuaSgGj4FpmRQq)qlcxViLmcCwpOnH1aiwbcFExvt2aynatW)EyQOxphFJRRrqd0ueGSyf9uxTMfOpbhcSsDrqd00r5vPKguFmi7kQS0OaebLEEwGkmVN9llvxTMvvdHG6f(SRifQRwZQQHqq9cF2H68pXatD1A2Gx)mybxJFpm7xw(5rteu7hbwBpQ9RouN)jgyQRwZg86Nbl4A87HzzzaIGsppB(O2VAZP(k6zuaIGsppB(O2VAZPYYEo(gxxJGgObygtXLLGWZ2wtHkSvj9kj79bG(evFf9q4Z7QAYgGjciqufKWfYqzzac1GqdPnateqGO6TtvC0p)HTd5Gf63NJ3d3dtSvf6hGvcjbst47DD11pQSJYdTFtje(8UQMSbWAaMG)9WSQc9JJ3d3dtSvf6hGvcjFg8j97HjA)Msi85DvnzdG1amb)7Hzvf6hhpYZc6JVVZpcZYo0alDRWolXedazXhIfu(Neilr0WcMcWeKJ3d3dtSvf6hGvcji85DvnH207iLCCeaKMnkGweUErkrb9hHj7Nv9k9b4beixpCpmT4ZN2pKLqgfwhvVVJaSruq)ryY(zvVsFa(EaAaFUMYZIHlDf2Q3ovBWHWNLsxvtGaFC7JC9W9W0Ay8B3siJcRJQ33raUylarU4isRR7o(ioEKNL44QlILTZh8AqrywmStjl3oXs7rTFS8ywCv46y5GSqjiAzPnugJcS8ywCv46y5GSqjiAzPaCXIpel(XcGSyaZsmXaqw(Kfpzb9d6pctOLfKgtKySzGfTJpmlEcVDAybqaymfWSahwkaxSyaU0GSarqtWJyPdoel3UNSWLkxmlXedazXWoLSuaUyXaCPbt0DSSD(GxdkILeAGJ3d3dtSvf6hGvcj4Zh8AqrO9Bk1tfIXk(8OjcQ9JaRTh1(vhQZ)edmJPSSN6Q1SJJGs4cxBdLXOGDOo)tmWqfaTDoYa(a96Eo(gxxJGgOb5g3I7RqD1A2XrqjCHRTHYyuWUI63VSSNJVX11iObAamcFExvtwhhbaPzJcaV6Q1Suq)ryQIHAFSd15FIbmi8ST1uOcBvsVsYEFaiCDOo)tGhGw0uKYkxCzPJVX11iObAamcFExvtwhhbaPzJcaV6Q1Suq)ryQQxPp2H68pXageE22AkuHTkPxjzVpaeUouN)jWdqlAkszLlUVckO)imz)S6zbf9msD1A2Gx)myxrLLgDUMYZIpF0Wb0sPRQjW(k61ZOaeQbHgsBWRFgSROYYaebLEEwGkmVNkmkaHAqOH0sDrqd0uvHjODf1VSmarqPNNnFu7xT5uFf9mkarqPNNfbL3EHPS0i1vRzdE9ZGDfvw64BCDncAGMIaKf3VSS35Akpl(8rdhqlLUQMavOUAnBWRFgSRif9uxTMfF(OHdOfFEaiGf3YshFJRRrqd0ueGS4(9llvxTMn41pd2vKcJuxTMDCeucx4ABOmgfSRifgDUMYZIpF0Wb0sPRQjqoEKNL4etSaGectmlFYc6TsFyb9d6pctS4jilyhbXcYzCDdWXHLwZcasimzPbhwqAmrIXMboEpCpmXwvOFawjKKKHAheMO9Bk1tD1AwkO)imv1R0h7qD(N4IiKrH1r177OYYEHDFqryLaOIHc7(GIQ33radn9lld7(GIWkf3(k8OAyNcaXX7H7Hj2Qc9dWkHKDx3QDqyI2VPup1vRzPG(JWuvVsFSd15FIlIqgfwhvVVJu0laHAqOH0g86Nb7qD(N4IqtXLLbiudcnK2amrabIQ3ovXr)8h2ouN)jUi0uC)YYEHDFqryLaOIHc7(GIQ33radn9lld7(GIWkf3(k8OAyNcaXX7H7Hj2Qc9dWkHK2sRRDqyI2VPup1vRzPG(JWuvVsFSd15FIlIqgfwhvVVJu0laHAqOH0g86Nb7qD(N4IqtXLLbiudcnK2amrabIQ3ovXr)8h2ouN)jUi0uC)YYEHDFqryLaOIHc7(GIQ33radn9lld7(GIWkf3(k8OAyNcaXXJ8SGCarFwGjlbqoEpCpmXwvOFawjKyWN5Htf2QKELehpYZsCIjw2oFA)qSCqwIgyGLnO2hwq)G(JWelWHfd7uYYNSatDbwqVv6dlOFq)ryIfpbzzHjwqoGOplrdmGz5BS8jlO3k9Hf0pO)imXX7H7Hj2Qc9dWkHe85t7hcTFtjkO)imz)SQxPpLLuq)ryYIHAFQjHSRSKc6pctwplutczxzP6Q1Sg8zE4uHTkPxjzxrkuxTMLc6pctv9k9XUIkl7PUAnBWRFgSd15FIbMhUhMwdJF7wczuyDu9(osH6Q1SbV(zWUI6ZX7H7Hj2Qc9dWkHedJF7C8E4EyITQq)aSsizwz1d3dZQ(XhAtVJuQ5A9TploEoEKNLTZh8AqrS0GdlDqeuhLhlRutymll8NOyj2WyACoEpCpmX2MR13(SucF(GxdkcTFtjJMvsn4GISQU2ZavHTQR11B)tuylbCxFuebYXJ8SGuhFSC7elGWJfd)TZYTtS0bXhl33rSCqwCqqww59AwUDILohzSaUg)EyYYJzz)pllBRS9dXYqD(Nyw6w67J0pbYYbzPZVWolDqy2(HybCn(9WKJ3d3dtST5A9TplaResWRS9dH2qHGMQNpOOdRKYO9BkbcpBheMTFi7qD(N4IgQZ)ed8aeGixLbeC8E4EyITnxRV9zbyLqsheMTFioEoEKNL4etSSD(GxdkILdYcqefXYkILBNyjooK3P(jinSOUAnw(gl)XIb4sdYcHSOFiwuPgCiwAF(49prXYTtSKeYowco(yboSCqwaxDrSOsn4qSGuyIaceXX7H7Hj2IpLWNp41GIq73uAwj1GdkYEFhzaozfCiVt9tqAu0Jc6pct2pREwqHr96PUAn79DKb4KvWH8o1pbPXouN)jUipCpmTgg)2TeYOW6O69DeGl2QSIEuq)ryY(zvfE7LLuq)ryY(zfd1(uwsb9hHjREL(utczx)Ys1vRzVVJmaNScoK3P(jin2H68pXf5H7HPfF(0(HSeYOW6O69DeGl2QSIEuq)ryY(zvVsFklPG(JWKfd1(utczxzjf0FeMSEwOMeYU(9llnsD1A277idWjRGd5DQFcsJDf1VSSN6Q1SbV(zWUIklr4Z7QAYgGjciqufKWfYqFfbiudcnK2amrabIQ3ovXr)8h2oKdwqraIGsppB(O2VAZP(k6zuaIGspplqfM3ZYYaeQbHgsl1fbnqtvfMG2H68pXfbi6RON6Q1SbV(zWUIklnkaHAqOH0g86Nb7qoyH(C8iplXjMyjMGE09iiw2m4thlg2PKLBNgILhZsczXd3JGybBWNo0YIJzr7hXIJzjcIXVQMybMSGn4thlg(BNfaYcCyPrgOHf85bGWSahwGjlolXfWSGn4thlyil3UFSC7eljzGfSbF6yXN5rqywaqzHpw82rdl3UFSGn4thleYI(HWC8E4EyIT4dWkHeh0JUhbvXg8PdTHcbnvpFqrhwjLr73uYiq4zDqp6EeufBWNUkO35Oi79bG(eLcJ8W9W06GE09iOk2GpDvqVZrr2pRn9JA)u0Ziq4zDqp6EeufBWNU6o5A79bG(evzji8SoOhDpcQIn4txDNCTDOo)tCrOPFzji8SoOhDpcQIn4txf07CuKfFEaiGfxfGWZ6GE09iOk2GpDvqVZrr2H68pXalUkaHN1b9O7rqvSbF6QGENJIS3ha6tuC8iplXjMWSGuyIaceXY3ybPXejgBgy5XSSIyboSuaUyXhIfqcxidFIIfKgtKySzGfd)TZcsHjciqelEcYsb4IfFiwujn0algtXSetmaKJ3d3dtSfFawjKeGjciqu92Pko6N)WO9Bkze4SEqBcRbqSIE9q4Z7QAYgGjciqufKWfYGcJcqOgeAiTbV(zWoKdwqHrZkPgCqr2O57Gd476Qpbp)qnAPX(uwQUAnBWRFgSRO(kC8nUUgbnqdWmMIv0tD1AwkO)imv1R0h7qD(N4IuU4Ys1vRzPG(JWufd1(yhQZ)exKYf3VSufIXkApQ9RouN)jgykxScJcqOgeAiTbV(zWoKdwOphpYZcsHj4FpmzPbhwCTMfq4Hz529JLohicZcEnel3ovGfFOeDhld1gcVtGSyyNswaq4iOeUWSehgkJrbw2DmlAcJz529Kf0WcMcywgQZ)8tuSahwUDIfGkmVNSOUAnwEmlUkCDSCqwAUwZcS1yboS4zbwq)G(JWelpMfxfUowoileYI(H449W9WeBXhGvcji85DvnH207iLaHxDiG76hQJYdJweUErk1tD1A2XrqjCHRTHYyuWouN)jUi0uwAK6Q1SJJGs4cxBdLXOGDf1xHrQRwZoockHlCTnugJcv8NTLUUxaF08UDfPON6Q1Sa9j4qGvQlcAGMokVkL0G6JbzhQZ)edmubqBNJS(k6PUAnlf0FeMQyO2h7qD(N4IqfaTDoYklvxTMLc6pctv9k9XouN)jUiubqBNJSYYEgPUAnlf0FeMQ6v6JDfvwAK6Q1Suq)ryQIHAFSRO(km6CnLNfd147dKLsxvtG954rEwqkmb)7Hjl3UFSe2Paqyw(glfGlw8HybUo8dsSqb9hHjwoilWuxGfq4XYTtdXcCy5rLWHy52Fmlg(BNLnOgFFG449W9WeBXhGvcji85DvnH207iLaHxfUo8dsvkO)imHweUErk1Zi1vRzPG(JWufd1(yxrkmsD1AwkO)imv1R0h7kQFz55AkplgQX3hilLUQMa549W9WeBXhGvcjDqy2(HqBOqqt1Zhu0Hvsz0(nL6PUAnlf0FeMQyO2h7qD(N4IgQZ)exwQUAnlf0FeMQ6v6JDOo)tCrd15FIllr4Z7QAYccVkCD4hKQuq)ryQVIHAdH3DvnP48bfD277O6bRGpvKYaeTFtjpQg2Paqkq4Z7QAYccV6qa31puhLhMJ3d3dtSfFawjKGxz7hcTHcbnvpFqrhwjLr73uQN6Q1Suq)ryQIHAFSd15FIlAOo)tCzP6Q1Suq)ryQQxPp2H68pXfnuN)jUSeHpVRQjli8QW1HFqQsb9hHP(kgQneE3v1KIZhu0zVVJQhSc(urkdq0(nL8OAyNcaPaHpVRQjli8QdbCx)qDuEyoEpCpmXw8byLqc(iT2NAt7dH2qHGMQNpOOdRKYO9Bk1tD1AwkO)imvXqTp2H68pXfnuN)jUSuD1AwkO)imv1R0h7qD(N4IgQZ)exwIWN3v1KfeEv46WpivPG(JWuFfd1gcV7QAsX5dk6S33r1dwbFQiLb0O9Bk5r1WofasbcFExvtwq4vhc4U(H6O8WC8iplXjMyjoaJflWKLailg(BhUowcEu0NO449W9WeBXhGvcjn4eOkSvt)wdH2VPKhvd7uaioEKNL4etSGC6tWHazzl6N)WSy4VDw8SalAyIIfkHlu7SOD89jkwq)G(JWelEcYYnfy5GSO)Ky5pwwrSy4VDwaGln2hw8eKfKgtKySzGJ3d3dtSfFawjKqDrqd0uvHjiA)Ms96PUAnlf0FeMQyO2h7qD(N4IuU4Ys1vRzPG(JWuvVsFSd15FIls5I7RiaHAqOH0g86Nb7qD(N4IIBXk6PUAnB08DWb8DD1NGNFOgT0yFSiC9IaganMIllnAwj1GdkYgnFhCaFxx9j45hQrln2hlbCxFueb2VFzP6Q1SrZ3bhW31vFcE(HA0sJ9XIW1lQiLaiWP4YYaeQbHgsBWRFgSd5Gfu44BCDncAGMIaKfZXJ8SeNyIfKgtKySzGfd)TZcsHjciqesqo9j4qGSSf9ZFyw8eKfqyIUJficAmm)rSaaxASpSahwmStjlXwdHG6f(yXaCPbzHqw0pelQudoelinMiXyZaleYI(HWC8E4EyIT4dWkHee(8UQMqB6DKsbWAaMG)9WSIp0IW1lsjJaN1dAtynaIvGWN3v1KnawdWe8VhMk61laHAqOH0sDrfgY1v4aMEgi7qD(NyGPmGg4a4EkRmWpRKAWbfzXF2w66Eb8rZ79vqa31hfrGwQlQWqUUchW0Za1VS0X346Ae0anfPeGSyf9m6CnLNTTMcvyRs6vswkDvnbwwQUAnBWRFgSGRXVhMffGqni0qABRPqf2QKELKDOo)tmGbe9vGWN3v1K92NxRRyIaIMQb)pf9uxTMfOpbhcSsDrqd00r5vPKguFmi7kQS0OaebLEEwGkmVN9vC(GIo79Du9GvWNksD1A2Gx)mybxJFpmb(ITaNYsvigRO9O2V6qD(NyGPUAnBWRFgSGRXVhMLLbick98S5JA)QnNklvxTMvvdHG6f(SRifQRwZQQHqq9cF2H68pXatD1A2Gx)mybxJFpmbCpajWpRKAWbfzJMVdoGVRR(e88d1OLg7JLaURpkIa73xHrQRwZg86Nb7ksrpJcqeu65zZh1(vBovwgGqni0qAdWebeiQE7ufh9ZFy7kQSufIXkApQ9RouN)jgybiudcnK2amrabIQ3ovXr)8h2ouN)jgWa6YY2JA)Qd15FIrUixLbefdm1vRzdE9ZGfCn(9WSphpYZsCIjwUDIfauP82lmSy4VDwCwqAmrIXMbwUD)y5Xj6owAdSJfa4sJ9HJ3d3dtSfFawjKmockHlCTnugJcO9BkPUAnBWRFgSd15FIlsz0uwQUAnBWRFgSGRXVhMalUfRaHpVRQjBaSgGj4FpmR4JJ3d3dtSfFawjKeinHV31vx)OYokp0(nLq4Z7QAYgaRbyc(3dZk(u0Zi1vRzdE9ZGfCn(9WSO4wCzPrbick98SiO82lm9llvxTMDCeucx4ABOmgfSRifQRwZoockHlCTnugJc2H68pXadqc4ambx)zJgk8yQ66hv2r5zVVJQiC9IaCpJuxTMvvdHG6f(SRifgDUMYZIpF0Wb0sPRQjW(C8E4EyIT4dWkHKpd(K(9WeTFtje(8UQMSbWAaMG)9WSIpoEKNfau95DvnXYctGSatwC1x)3tywUD)yXGNhlhKfvIfSJGazPbhwqAmrIXMbwWqwUD)y52PcS4dLhlgC8rGSaGYcFSOsn4qSC7uhhVhUhMyl(aSsibHpVRQj0MEhPe2rq1gCQbV(zaTiC9IuYOaeQbHgsBWRFgSd5GfklncHpVRQjBaMiGarvqcxidkcqeu65zZh1(vBovwcoRh0MWAaeZXJ8SeNycZsCaI(S8nw(Kfpzb9d6pctS4jil38eMLdYI(tIL)yzfXIH)2zbaU0yFqllinMiXyZalEcYsmb9O7rqSSzWNooEpCpmXw8byLqsBnfQWwL0RKq73uIc6pct2pREwqHhvd7uaifQRwZgnFhCaFxx9j45hQrln2hlcxViGbqJPyf9aHN1b9O7rqvSbF6QGENJIS3ha6tuLLgfGiO0ZZMuyGA4a2xbcFExvtwSJGQn4udE9ZGIEQRwZoockHlCTnugJc2H68pXadqcG7HgGFwj1GdkYI)ST019c4JM37RqD1A2XrqjCHRTHYyuWUIklnsD1A2XrqjCHRTHYyuWUI6ZXJ8SeNyIfa0jD7SSD(0CTMLObgWS8nw2oFAUwZYJt0DSSI449W9WeBXhGvcj4ZNMR1O9BkPUAnlmPBhxJOjqr3dt7ksH6Q1S4ZNMR12HAdH3DvnXX7H7Hj2IpaRescEgiDvD1AOn9osj85JgoGO9BkPUAnl(8rdhq7qD(NyGHgf9uxTMLc6pctvmu7JDOo)tCrOPSuD1AwkO)imv1R0h7qD(N4IqtFfo(gxxJGgOPiazXC8iplXXvxeMLyIbGSOsn4qSGuyIaceXYc)jkwUDIfKcteqGiwcWe8VhMSCqwc7uaiw(glifMiGarS8yw8WTCTUalUkCDSCqwujwco(449W9WeBXhGvcj4Zh8AqrO9BkfGiO0ZZMpQ9R2CsbcFExvt2amrabIQGeUqgueGqni0qAdWebeiQE7ufh9ZFy7qD(NyGHgfgboRh0MWAaeZXJ8SeNyILTZNMR1Sy4VDw2osR9HL448TJfpbzjHSSD(OHdiAzXWoLSKqw2oFAUwZYJzzfHwwkaxS4dXYNSGER0hwq)G(JWeln4WcGaWykGzboSCqwIgyGfa4sJ9Hfd7uYIRcrqSailMLyIbGSahwCWi)Eeelyd(0XYUJzbqaymfWSmuN)5NOyboS8yw(KLM(rTFwwIf8iwUD)yzLG0WYTtSG9oILamb)7HjML)qhMfWimljTUX1SCqw2oFAUwZc4A(eflaiCeucxywIddLXOaAzXWoLSuaUqhil471AwOeKLvelg(BNfazXa2XrS0Gdl3oXI2XhlO0qvxJTC8E4EyIT4dWkHe85tZ1A0(nLoxt5zXhP1(ubNVDwkDvnbQWOZ1uEw85JgoGwkDvnbQqD1Aw85tZ1A7qTHW7UQMu0tD1AwkO)imv1R0h7qD(N4IaekOG(JWK9ZQEL(OqD1A2O57Gd476Qpbp)qnAPX(yr46fbmaIMIllvxTMnA(o4a(UU6tWZpuJwASpweUErfPeartXkC8nUUgbnqtraYIllbHN1b9O7rqvSbF6QGENJISd15FIlcquw6H7HP1b9O7rqvSbF6QGENJISFwB6h1(1xrac1GqdPn41pd2H68pXfPCXC8iplXjMyz78bVguelaOt62zjAGbmlEcYc4QlILyIbGSyyNswqAmrIXMbwGdl3oXcaQuE7fgwuxTglpMfxfUowoilnxRzb2ASahwkaxOdKLGhXsmXaqoEpCpmXw8byLqc(8bVgueA)MsQRwZct62X1GM8PI4XpmTROYs1vRzb6tWHaRuxe0anDuEvkPb1hdYUIklvxTMn41pd2vKIEQRwZoockHlCTnugJc2H68pXadva025id4d0R754BCDncAGgKBClUpGJlWFUMYZMKHAheMwkDvnbQWOzLudoOil(Z2sx3lGpAExH6Q1SJJGs4cxBdLXOGDfvwQUAnBWRFgSd15FIbgQaOTZrgWhOx3ZX346Ae0ani34wC)Ys1vRzhhbLWfU2gkJrHk(Z2sx3lGpAE3UIklnsD1A2XrqjCHRTHYyuWUIuyuac1GqdPDCeucx4ABOmgfSd5GfklnkarqPNNfbL3EHPFzPJVX11iObAkcqwSckO)imz)S6zboEKNfJpfy5GS05arSC7elQe(yb2yz78rdhqwulWc(8aqFIIL)yzfXcWD9bG0fy5tw8SalOFq)ryIf11XcaCPX(WYJZJfxfUowoilQelrdmeiqoEpCpmXw8byLqc(8bVgueA)MsNRP8S4ZhnCaTu6QAcuHrZkPgCqr277idWjRGd5DQFcsJIEQRwZIpF0Wb0UIklD8nUUgbnqtraYI7RqD1Aw85JgoGw85bGawCv0tD1AwkO)imvXqTp2vuzP6Q1Suq)ryQQxPp2vuFfQRwZgnFhCaFxx9j45hQrln2hlcxViGbqGtXk6fGqni0qAdE9ZGDOo)tCrkxCzPri85DvnzdWebeiQcs4czqraIGsppB(O2VAZP(C8iplOp((o)iml7qdS0Tc7SetmaKfFiwq5FsGSerdlykatqoEpCpmXw8byLqccFExvtOn9osjhhbaPzJcOfHRxKsuq)ryY(zvVsFaEabY1d3dtl(8P9dzjKrH1r177iaBef0FeMSFw1R0hGVhGgWNRP8Sy4sxHT6Tt1gCi8zP0v1eiWh3(ixpCpmTgg)2TeYOW6O69DeGl2AmOb5IJiTUU74JaCXw0a8NRP8SPFRHWvvx7zGSu6QAcKJh5zjoU6Iyz78bVguelFYIZcWbWykWYgu7dlOFq)rycTSact0DSOPJL)yjAGbwaGln2hw6D7(XYJzz3tqnbYIAbwO)2PHLBNyz78P5Anl6pjwGdl3oXsmXaWIaKfZI(tILgCyz78bVguuF0Ycimr3XcebngM)iw8Kfa0jD7SenWalEcYIMowUDIfxfIGyr)jXYUNGAILTZhnCa549W9WeBXhGvcj4Zh8AqrO9Bkz0SsQbhuK9(oYaCYk4qEN6NG0OON6Q1SrZ3bhW31vFcE(HA0sJ9XIW1lcyae4uCzP6Q1SrZ3bhW31vFcE(HA0sJ9XIW1lcyaenfR4CnLNfFKw7tfC(2zP0v1eyFf9OG(JWK9ZkgQ9rHJVX11iObAamcFExvtwhhbaPzJcaV6Q1Suq)ryQIHAFSd15FIbmi8ST1uOcBvsVsYEFaiCDOo)tGhGw0ueGO4YskO)imz)SQxPpkC8nUUgbnqdGr4Z7QAY64iainBua4vxTMLc6pctv9k9XouN)jgWGWZ2wtHkSvj9kj79bGW1H68pbEaArtraYI7RWi1vRzHjD74Aenbk6EyAxrkm6CnLNfF(OHdOLsxvtGk6fGqni0qAdE9ZGDOo)tCraNYsmCPv)e0E7ZR1vmrarJLsxvtGkuxTM92NxRRyIaIgl(8aqalUXfa3Bwj1GdkYI)ST019c4JM3bE00xr7rTF1H68pXfPCXfRO9O2V6qD(NyGbWIlUVIEbiudcnKwG(eCiWko6N)W2H68pXfbCklnkarqPNNfOcZ7zFoEKNL4etSaGectmlFYc6TsFyb9d6pctS4jilyhbXcYzCDdWXHLwZcasimzPbhwqAmrIXMbw8eKfKtFcoeilOFxe0anDuEC8E4EyIT4dWkHKKmu7GWeTFtPEQRwZsb9hHPQEL(yhQZ)exeHmkSoQEFhvw2lS7dkcReavmuy3huu9(ocyOPFzzy3huewP42xHhvd7uaifi85DvnzXocQ2Gtn41pdC8E4EyIT4dWkHKDx3QDqyI2VPup1vRzPG(JWuvVsFSd15FIlIqgfwhvVVJuyuaIGspplqfM3ZYYEQRwZc0NGdbwPUiObA6O8QusdQpgKDfPiarqPNNfOcZ7z)YYEHDFqryLaOIHc7(GIQ33radn9lld7(GIWkf3Ys1vRzdE9ZGDf1xHhvd7uaifi85DvnzXocQ2Gtn41pdk6PUAn74iOeUW12qzmkyhQZ)edSEObadqGFwj1GdkYI)ST019c4JM37RqD1A2XrqjCHRTHYyuWUIklnsD1A2XrqjCHRTHYyuWUI6ZX7H7Hj2IpaResAlTU2bHjA)Ms9uxTMLc6pctv9k9XouN)jUiczuyDu9(osHrbick98SavyEpll7PUAnlqFcoeyL6IGgOPJYRsjnO(yq2vKIaebLEEwGkmVN9ll7f29bfHvcGkgkS7dkQEFhbm00VSmS7dkcRuCllvxTMn41pd2vuFfEunStbGuGWN3v1Kf7iOAdo1Gx)mOON6Q1SJJGs4cxBdLXOGDOo)tmWqJc1vRzhhbLWfU2gkJrb7ksHrZkPgCqrw8NTLUUxaF08EzPrQRwZoockHlCTnugJc2vuFoEKNL4etSGCarFwGjlbqoEpCpmXw8byLqIbFMhovyRs6vsC8iplXjMyz78P9dXYbzjAGbw2GAFyb9d6pctOLfKgtKySzGLDhZIMWywUVJy529KfNfKJXVDwiKrH1rSOP2XcCybM6cSGER0hwq)G(JWelpMLvehVhUhMyl(aSsibF(0(Hq73uIc6pct2pR6v6tzjf0FeMSyO2NAsi7klPG(JWK1Zc1Kq2vw2tD1Awd(mpCQWwL0RKSROYsCeP11DhFeWk2AmOrHrbick98SiO82lmLL4isRR7o(iGvS1yueGiO0ZZIGYBVW0xH6Q1Suq)ryQQxPp2vuzzp1vRzdE9ZGDOo)tmW8W9W0Ay8B3siJcRJQ33rkuxTMn41pd2vuFoEKNL4etSGCm(TZc82PXWJjwmS)HDwEmlFYYgu7dlOFq)rycTSG0yIeJndSahwoilrdmWc6TsFyb9d6pctC8E4EyIT4dWkHedJF7C8iplXbxRV9zXX7H7Hj2IpaResMvw9W9WSQF8H207iLAUwF7ZY8mptta]] )


end