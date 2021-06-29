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


    spec:RegisterPack( "Balance", 20210629.2, [[devoDfqikjpcIQUeevAtKWNGuAusvoLuvRcqvVcGAwqQClaO2ff)cIyyIuDmsKLbGEMqLMgLuCnifBdGW3auX4ai6CaKSoasnpaL7rIAFcv9piQO0bfkAHcL6HqKMOqf6IqQQnkubFeIkQgjevuCskP0kfP8siQiZesvUjaeTtHs(jaKAOaGwkaeEQszQus1vfQOTcaj9viQWyba2lL6VIAWehMQftspwWKb6YiBwkFgsgTs1Pvz1aqIxdiZMu3wQSBj)g0WfYXbuPLR45qnDvDDLSDi8DkX4HOCErY6fkmFrSFuBRKT1T3a9NSJfathGkLoGaGakJskznaI4An2BFQiYElYda5Oi7TY7i7Ty7AVcK9wKNsdDqBRBVHHRjq2B7)hHb0ibjQU2RabGXxxWG6(9LQ5Gij2U2RabG3UoKIKoqZ(3ProB70KYQU2RazEK92BQRt)wBzRAVb6pzhlaMoavkDababugLuYAaeXvj7nF97WXEB76qQ92(bcsLTQ9giHd2BX21EfiwIJZ6a50sBvelaeqHoway6aujononKU7fkcdO50aWSetqqcKLnO2hwIn5DgonamliD3lueilVpOOpFnwcoMWS8qwcPcAk)(GIESHtdaZcacQdIGazzvffim2NuSGWNZv1eMLENHmOJLOHqKXVp41GIybahplrdHWGFFWRbf13WPbGzjMiGhilrdfC8Ffkwqog)3z5ASCpAXS87elwgyHIf0pOVimz40aWSaG0bIybPWcbeiILFNyzl6M7XS4SOV)1elDWHyPPjKDQAILExJLuWfl7oyH2NL97z5EwWx3s)ErWfwNIfl3VZsSbqhtRZcGzbPKMW)5AwIP(qvDu9OJL7rlilyGUO(gonamlaiDGiw6G4Nf02ou7FEOo)kmAzbhOYNdIzXJI0Py5HSOcXywAhQ9hZcS0PmCACAXSk47pbYsSDTxbILycarpwcEXIkXsdUkqw8NL9)JWaAKGevx7vGaW4RlyqD)(s1CqKeBx7vGaWBxhsrshOz)70iNTDAszvx7vGmpYE7n9HFST1T3aPMV0VT1TJLs2w3EZd)bl7nmu7twL8o7nQCvnbAhB73owa0262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7nCeP153hu0Jn43NMR1SeplkXIcw6XIvS8UMQ3GFF0Wb0qLRQjqwssy5DnvVb)Kw7tgCU2BOYv1eil9zjjHfCeP153hu0Jn43NMR1Sepla0EdKWH5I(dw2BB0JzjMq0NfyXsCbmlwUFhUEwaNR9S4filwUFNLT3hnCazXlqwaiGzb(70y5WK9gcFYL3r2Bho7qY(TJvCTTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEdhrAD(9bf9yd(9PDdXs8SOK9giHdZf9hSS32OhZsqtocIfl7uXY27t7gILGxSSFplaeWS8(GIEmlw2VWolhMLH0ecVEwAWHLFNyb9d6lctS8qwujwIgQrZqGS4filw2VWolTtRPHLhYsWXV9gcFYL3r2Bhoh0KJGSF7yzn2w3EJkxvtG2X2EZd)bl7nvAW0a0vOS3ajCyUO)GL9wCIjwInnyAa6kuSy5(DwqAmrI1wbwGdlE7PHfKcleqGiwUIfKgtKyTvWElm3tZ52B9yXkwcqeu51BQd1(NBoXssclwXsac1GqlLjaleqGO8VtzC0n3JnRiw6ZIcwuxTMj45RcMH68RWSeplkHgwuWI6Q1mJJGk4cNBdvXiLzOo)kmlaJfRHffSyflbicQ86niO63tnSKKWsaIGkVEdcQ(9udlkyrD1AMGNVkywrSOGf1vRzghbvWfo3gQIrkZkIffS0Jf1vRzghbvWfo3gQIrkZqD(vywaglkPelaywqdlaplZQOgCqrg8vTLoVNc)0CUHkxvtGSKKWI6Q1mbpFvWmuNFfMfGXIskXssclkXcsybhrADE3XpXcWyrjdAqdl9TF7yHgBRBVrLRQjq7yBVfM7P5C7n1vRzcE(QGzOo)kmlXZIsOHffS0JfRyzwf1GdkYGVQT059u4NMZnu5QAcKLKewuxTMzCeubx4CBOkgPmd15xHzbySOeWHffSOUAnZ4iOcUW52qvmszwrS0NLKewuHymlkyPDO2)8qD(vywaglaen2BGeomx0FWYEdacFwSC)ololinMiXARal)U)SC4cTplolaWLg7dlrdmWcCyXYovS87elTd1(ZYHzXvHRNLhYcvG2BE4pyzVfb)dw2VDSae2w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzVfOtZspw6Xs7qT)5H68RWSaGzrj0WcaMLaeQbHwktWZxfmd15xHzPpliHfLaKPZsFwuMLaDAw6XspwAhQ9ppuNFfMfamlkHgwaWSOeatNfamlbiudcTuMaSqabIY)oLXr3Cp2muNFfML(SGewucqMol9zrblwXY4hyMqq1BCqqSHq2HFmljjSeGqni0szcE(QGzOo)kmlXZYvpnrqT)eyUDO2)8qD(vywssyjaHAqOLYeGfciqu(3Pmo6M7XMH68RWSeplx90eb1(tG52HA)Zd15xHzbaZIsPZssclwXsaIGkVEtDO2)CZjwssyXd)bltawiGar5FNY4OBUhBapSRQjq7nqchMl6pyzVHuxhwA)jmlw2PFNgww4RqXcsHfciqelf0clwoTMfxRHwyjfCXYdzb)NwZsWXpl)oXc27iw8o4QEwGnwqkSqabIamsJjsS2kWsWXp2EdHp5Y7i7TaSqabIYGeovfSF7ybCSTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYERhlVpOO38xhLFyg8iwINfLqdljjSm(bMjeu9gheeBUIL4zbnPZsFwuWspw6XspwSIfc4UUOic0qDrPgY1z4awEfiwssyPhl9yjaHAqOLYqDrPgY1z4awEfiZqD(vywaglkbisNLKewcqeu51Bqq1VNAyrblbiudcTugQlk1qUodhWYRazgQZVcZcWyrjabWHfaZspwusjwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPpl9zrblwXsac1GqlLH6IsnKRZWbS8kqMHCWuS0NL(SOGLESyfleWDDrreObdxAn9)vOYZsnfljjSyflbicQ86n1HA)ZnNyjjHLaeQbHwkdgU0A6)RqLNLAQCCTg0aitxjZqD(vywaglkPK1WsFwuWspwSIfc4UUOic0CfomR3v1ug4U86xDzqcXfiwssyjaHAqOLYCfomR3v1ug4U86xDzqcXfiZqoykw6ZIcw6Xsac1GqlLrLgmnaDfkZqoykwssyXkwgpqMFGAnl9zjjHLES0Jfe(CUQMmWkVWu(NRaIEwuMfLyjjHfe(CUQMmWkVWu(NRaIEwuML4YsFwuWspw(5kGO38kzgYbtLdqOgeAPyjjHLFUci6nVsMaeQbHwkZqD(vywINLREAIGA)jWC7qT)5H68RWSaGzrP0zPpljjSGWNZv1Kbw5fMY)Cfq0ZIYSaqwuWspw(5kGO38a0mKdMkhGqni0sXsscl)Cfq0BEaAcqOgeAPmd15xHzjEwU6PjcQ9NaZTd1(NhQZVcZcaMfLsNL(SKKWccFoxvtgyLxyk)ZvarplkZs6S0NL(SKKWsaIGkVEdqPMZlw6BVbs4WCr)bl7T4etGS8qwajTNILFNyzHDuelWglinMiXARalw2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyzNkw8IfheKfcbvplhMfxfUEwEilGhzVHWNC5DK9wamhGf49hSSF7ybiTTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZkwWWLw9kqZVpNwNXebengQCvnbYssclTd1(NhQZVcZs8SaW0tNLKewuHymlkyPDO2)8qD(vywaglaenSayw6XI1KolaywuxTM53NtRZyIaIgd(9aqSa8Saqw6ZssclQRwZ87ZP1zmrarJb)EaiwINL4cizbaZspwMvrn4GIm4RAlDEpf(P5CdvUQMazb4zbnS03EdHp5Y7i7TFFoToJjciAYw87TF7ybOSTU9gvUQMaTJT9giHdZf9hSS3ItmXc63fLAixZca6bS8kqSaW0XuaZIk1GdXIZcsJjsS2kWYctg7TY7i7nQlk1qUodhWYRazVfM7P5C7TaeQbHwktWZxfmd15xHzbySaW0zrblbiudcTuMaSqabIY)oLXr3Cp2muNFfMfGXcatNffS0Jfe(CUQMm)(CADgteq0KT43ZssclQRwZ87ZP1zmrarJb)EaiwINL4MolaMLESmRIAWbfzWx1w68Ek8tZ5gQCvnbYcWZcGGL(S0NLKewuHymlkyPDO2)8qD(vywaglXf4yV5H)GL9g1fLAixNHdy5vGSF7yPu62w3EJkxvtG2X2EdKWH5I(dw2BXjMyzdU0A6VcflaiwQPybqGPaMfvQbhIfNfKgtKyTvGLfMm2BL3r2By4sRP)VcvEwQPS3cZ90CU9wac1GqlLj45RcMH68RWSamwaeSOGfRyjarqLxVbbv)EQHffSyflbicQ86n1HA)ZnNyjjHLaebvE9M6qT)5MtSOGLaeQbHwktawiGar5FNY4OBUhBgQZVcZcWybqWIcw6XccFoxvtMaSqabIYGeovfyjjHLaeQbHwktWZxfmd15xHzbySaiyPpljjSeGiOYR3GGQFp1WIcw6XIvSmRIAWbfzWx1w68Ek8tZ5gQCvnbYIcwcqOgeAPmbpFvWmuNFfMfGXcGGLKewuxTMzCeubx4CBOkgPmd15xHzbySOK1WcGzPhlOHfGNfc4UUOic0Cf(Nv4HdodEiUIYQKwZsFwuWI6Q1mJJGk4cNBdvXiLzfXsFwssyrfIXSOGL2HA)Zd15xHzbySaq0yV5H)GL9ggU0A6)RqLNLAk73owkPKT1T3OYv1eODST38WFWYE7kCywVRQPmWD51V6YGeIlq2BH5EAo3EtD1AMGNVkygQZVcZs8SOeAyrbl9yXkwMvrn4GIm4RAlDEpf(P5CdvUQMazjjHf1vRzghbvWfo3gQIrkZqD(vywaglkbqwaml9yjUSa8SOUAnJQgcb1l8BwrS0NfaZspw6XcWHfamlOHfGNf1vRzu1qiOEHFZkIL(Sa8Sqa31ffrGMRW)ScpCWzWdXvuwL0Aw6ZIcwuxTMzCeubx4CBOkgPmRiw6ZssclQqmMffS0ou7FEOo)kmlaJfaIg7TY7i7TRWHz9UQMYa3Lx)QldsiUaz)2XsjaABD7nQCvnbAhB7nqchMl6pyzVz99dZYHzXzz8FNgwiTRch)jwS4Py5HS05arS4AnlWILfMyb)(ZYpxbe9ywEilQel6RiqwwrSy5(DwqAmrI1wbw8cKfKcleqGiw8cKLfMy53jwaybYcwdFwGflbqwUglQWFNLFUci6XS4dXcSyzHjwWV)S8Zvarp2Elm3tZ52Bi85CvnzGvEHP8pxbe9SOmlaKffSyfl)Cfq0BEaAgYbtLdqOgeAPyjjHLESGWNZv1Kbw5fMY)Cfq0ZIYSOeljjSGWNZv1Kbw5fMY)Cfq0ZIYSexw6ZIcw6XI6Q1mbpFvWSIyrbl9yXkwcqeu51Bqq1VNAyjjHf1vRzghbvWfo3gQIrkZqD(vywaml9ybnSa8SmRIAWbfzWx1w68Ek8tZ5gQCvnbYsFwaMYS8ZvarV5vYOUATm4A8)GflkyrD1AMXrqfCHZTHQyKYSIyjjHf1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SIyPpljjSeGqni0szcE(QGzOo)kmlaMfaYs8S8ZvarV5vYeGqni0szaxJ)hSyrbl9yXkwcqeu51BQd1(NBoXssclwXccFoxvtMaSqabIYGeovfyPplkyXkwcqeu51Bak1CEXssclbicQ86n1HA)ZnNyrbli85CvnzcWcbeikds4uvGffSeGqni0szcWcbeik)7ughDZ9yZkIffSyflbiudcTuMGNVkywrSOGLES0Jf1vRzOG(IWuwVkFmd15xHzjEwukDwssyrD1AgkOVimLXqTpMH68RWSeplkLol9zrblwXYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjS0Jf1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyrzwqdljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelkZcGKL(S0NLKewuxTMbORahcmtDrql00r1NPIguxmiZkIL(SKKWIkeJzrblTd1(NhQZVcZcWybGPZsscli85CvnzGvEHP8pxbe9SOmlPBVH1WhBV9ZvarVs2BE4pyzVTWu(EQdB)2XsP4ABD7nQCvnbAhB7np8hSS3wykFp1HT3cZ90CU9gcFoxvtgyLxyk)ZvarplwPmlaKffSyfl)Cfq0BELmd5GPYbiudcTuSKKWccFoxvtgyLxyk)ZvarplkZcazrbl9yrD1AMGNVkywrSOGLESyflbicQ86niO63tnSKKWI6Q1mJJGk4cNBdvXiLzOo)kmlaMLESGgwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPplatzw(5kGO38a0OUATm4A8)GflkyrD1AMXrqfCHZTHQyKYSIyjjHf1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SIyPpljjSeGqni0szcE(QGzOo)kmlaMfaYs8S8ZvarV5bOjaHAqOLYaUg)pyXIcw6XIvSeGiOYR3uhQ9p3CILKewSIfe(CUQMmbyHaceLbjCQkWsFwuWIvSeGiOYR3auQ58IffS0JfRyrD1AMGNVkywrSKKWIvSeGiOYR3GGQFp1WsFwssyjarqLxVPou7FU5elkybHpNRQjtawiGarzqcNQcSOGLaeQbHwktawiGar5FNY4OBUhBwrSOGfRyjaHAqOLYe88vbZkIffS0JLESOUAndf0xeMY6v5JzOo)kmlXZIsPZssclQRwZqb9fHPmgQ9XmuNFfML4zrP0zPplkyXkwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelkZcAyjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGyrzwaKS0NL(S0NLKewuxTMbORahcmtDrql00r1NPIguxmiZkILKewuHymlkyPDO2)8qD(vywaglamDwssybHpNRQjdSYlmL)5kGONfLzjD7nSg(y7TFUci6bO9BhlLSgBRBVrLRQjq7yBV5H)GL92ct57PoS9giHdZf9hSS3ItmHzX1AwG)onSalwwyIL7PomlWILaO9wyUNMZT3uxTMj45RcMveljjSeGiOYR3uhQ9p3CIffSGWNZv1KjaleqGOmiHtvbwuWsac1GqlLjaleqGO8VtzC0n3JnRiwuWIvSeGqni0szcE(QGzfXIcw6XspwuxTMHc6lctz9Q8XmuNFfML4zrP0zjjHf1vRzOG(IWugd1(ygQZVcZs8SOu6S0NffSyflZQOgCqrgvx7vGYWw2168VFfkSHkxvtGSKKWYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eilkyPhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SexwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINL4YsFw6ZssclQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfXssclQqmMffS0ou7FEOo)kmlaJfaMU9BhlLqJT1T3OYv1eODST3ajCyUO)GL9wCKchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1HT38WFWYEBwv2d)bRS(WV9g(Nl82Xsj7TWCpnNBVHWNZv1K5Wzhs2B6d)5Y7i7nhs2VDSucqyBD7nQCvnbAhB7TWCpnNBVnRIAWbfzuDTxbkdBzxRZ)(vOWgc4UUOic0Ed)ZfE7yPK9Mh(dw2BZQYE4pyL1h(T30h(ZL3r2BQq)TF7yPeWX262Bu5QAc0o22BE4pyzVnRk7H)GvwF43EtF4pxEhzVHF73(T3uH(BBD7yPKT1T3OYv1eODST38WFWYEBCeubx4CBOkgPS3ajCyUO)GL9wCyOkgPyXY97SG0yIeRTc2BH5EAo3EtD1AMGNVkygQZVcZs8SOeASF7ybqBRBVrLRQjq7yBV5H)GL9Md6r)HGYyl(0zVfsf0u(9bf9y7yPK9wyUNMZT3uxTMr11EfOmSLDTo)7xHcNl)xdzWVhaIfGXcGKffSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelaJfajlkyPhlwXci8noOh9hckJT4txg07CuK5VaqxHIffSyflE4pyzCqp6peugBXNUmO35OiZv5M(qT)SOGLESyflGW34GE0FiOm2IpD5DY1M)caDfkwssybe(gh0J(dbLXw8PlVtU2muNFfML4zjUS0NLKewaHVXb9O)qqzSfF6YGENJIm43daXcWyjUSOGfq4BCqp6peugBXNUmO35OiZqD(vywaglOHffSacFJd6r)HGYyl(0Lb9ohfz(la0vOyPV9giHdZf9hSS3ItmXsmb9O)qqSSzXNowSStfl(ZIMWyw(DVyXAyj2WyADwWVhacZIxGS8qwgQneENfNfGPmazb)EaiwCmlA)jwCmlrqm(u1elWHL)6iwUNfmKL7zXN5qqywaqzHFw82tdlolXfWSGFpaeleYIUHW2VDSIRT1T3OYv1eODST38WFWYElaleqGO8VtzC0n3JT3ajCyUO)GL9wCIjwqkSqabIyXY97SG0yIeRTcSyzNkwIGy8PQjw8cKf4VtJLdtSy5(DwCwInmMwNf1vRXILDQybKWPQWvOS3cZ90CU9MvSaoRd0uWCaeZIcw6Xspwq4Z5QAYeGfciqugKWPQalkyXkwcqOgeAPmbpFvWmKdMILKewuxTMj45RcMvel9zrbl9yrD1Agvx7vGYWw2168VFfkCU8FnKb)EaiwuMfajljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelkZcGKL(SKKWIkeJzrblTd1(NhQZVcZcWyrP0zPV9BhlRX262Bu5QAc0o22BE4pyzV1wtQmSLj9Qi7nqchMl6pyzVfhGOploMLFNyPDd(zbvaKLRy53jwCwInmMwNflxbcTWcCyXY97S87eliNsnNxSOUAnwGdlwUFNfNfajGXuGLyc6r)HGyzZIpDS4filw87zPbhwqAmrI1wbwUgl3ZIfy9SOsSSIyXr5xXIk1GdXYVtSeaz5WS0U6W7eO9wyUNMZT36Xspw6XI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqSeplacwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINfabl9zrbl9yXkwcqeu51Bqq1VNAyjjHfRyrD1AMXrqfCHZTHQyKYSIyPpl9zrbl9ybCwhOPG5aiMLKewcqOgeAPmbpFvWmuNFfML4zbnPZsscl9yjarqLxVPou7FU5elkyjaHAqOLYeGfciqu(3Pmo6M7XMH68RWSeplOjDw6ZsFw6Zsscl9ybe(gh0J(dbLXw8Pld6DokYmuNFfML4zbqYIcwcqOgeAPmbpFvWmuNFfML4zrP0zrblbicQ86nffgOgoGS0NLKewuHymlky5QNMiO2Fcm3ou7FEOo)kmlaJfajlkyXkwcqOgeAPmbpFvWmKdMILKewcqeu51Bak1CEXIcwuxTMbORahcmtDrql00r1BwrSKKWsaIGkVEdcQ(9udlkyrD1AMXrqfCHZTHQyKYmuNFfMfGXcGIffSOUAnZ4iOcUW52qvmszwr2VDSqJT1T3OYv1eODST38WFWYEl4vG0z1vRzVfM7P5C7TESOUAnJQR9kqzyl7AD(3Vcfox(VgYmuNFfML4zb4yqdljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYmuNFfML4zb4yqdl9zrbl9yjaHAqOLYe88vbZqD(vywINfGdljjS0JLaeQbHwkd1fbTqtwfwGMH68RWSeplahwuWIvSOUAndqxboeyM6IGwOPJQptfnOUyqMvelkyjarqLxVbOuZ5fl9zPplkyXX)46Ce0cnSeVYSe30T3uxTwU8oYEd)(OHdO9giHdZf9hSS3qQxbsZY27JgoGSy5(DwCwkYclXggtRZI6Q1yXlqwqAmrI1wbwoCH2NfxfUEwEilQellmbA)2XcqyBD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9wCC1fXY27dEnOimlwUFNfNLydJP1zrD1ASOUEwk4ZILDQyjcc1xHILgCybPXejwBfyboSGC6kWHazzl6M7X2BH5EAo3ERhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SaqwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINfaYsFwuWspwcqeu51BQd1(NBoXssclbiudcTuMGNVkygQZVcZs8SaCyjjHfRybHpNRQjtamhGf49hSyrblwXsaIGkVEdqPMZlwssyPhlbiudcTugQlcAHMSkSand15xHzjEwaoSOGfRyrD1AgGUcCiWm1fbTqthvFMkAqDXGmRiwuWsaIGkVEdqPMZlw6ZsFwuWspwSIfq4BARjvg2YKEvK5VaqxHILKewSILaeQbHwktWZxfmd5GPyjjHfRyjaHAqOLYeGfciqu(3Pmo6M7XMHCWuS03(TJfWX262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T44QlILT3h8AqrywuPgCiwqkSqabIS3cZ90CU9wpwcqOgeAPmbyHaceL)DkJJU5ESzOo)kmlaJf0WIcwSIfWzDGMcMdGywuWspwq4Z5QAYeGfciqugKWPQaljjSeGqni0szcE(QGzOo)kmlaJf0WsFwuWccFoxvtMayoalW7pyXsFwuWIvSacFtBnPYWwM0RIm)fa6kuSOGLaebvE9M6qT)5MtSOGfRybCwhOPG5aiMffSqb9fHjZvzVsXIcwC8pUohbTqdlXZI1KU9BhlaPT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2B9yrD1AMXrqfCHZTHQyKYmuNFfML4zbnSKKWIvSOUAnZ4iOcUW52qvmszwrS0NffS0Jf1vRza6kWHaZuxe0cnDu9zQOb1fdYmuNFfMfGXcQaOPZrgl9zrbl9yrD1AgkOVimLXqTpMH68RWSeplOcGMohzSKKWI6Q1muqFrykRxLpMH68RWSeplOcGMohzS03EdKWH5I(dw2BXryH2Nfq4Zc4AUcfl)oXcvGSaBSaGWrqfCHzjomufJuOJfW1Cfkwa6kWHazH6IGwOPJQNf4WYvS87elAh)SGkaYcSXIxSG(b9fHj7ne(KlVJS3aHFEiG76gQJQhB)2XcqzBD7nQCvnbAhB7np8hSS3WRQDdzVfM7P5C7THAdH3DvnXIcwEFqrV5Vok)Wm4rSeplkbiyrblEuoStbGyrbli85CvnzaHFEiG76gQJQhBVfsf0u(9bf9y7yPK9BhlLs3262Bu5QAc0o22BE4pyzV1bHv7gYElm3tZ52Bd1gcV7QAIffS8(GIEZFDu(HzWJyjEwukUg0WIcw8OCyNcaXIcwq4Z5QAYac)8qa31nuhvp2ElKkOP87dk6X2Xsj73owkPKT1T3OYv1eODST38WFWYEd)Kw7tUP9HS3cZ90CU92qTHW7UQMyrblVpOO38xhLFyg8iwINfLaeSaywgQZVcZIcw8OCyNcaXIcwq4Z5QAYac)8qa31nuhvp2ElKkOP87dk6X2Xsj73owkbqBRBVrLRQjq7yBV5H)GL9wdobkdB5Y)1q2BGeomx0FWYEloaJflWILailwUFhUEwcEu0vOS3cZ90CU9MhLd7uai73owkfxBRBVrLRQjq7yBV5H)GL9g1fbTqtwfwG2BGeomx0FWYEd97IGwOHLydlqwSStflUkC9S8qwO6PHfNLISWsSHX06Sy5kqOfw8cKfSJGyPbhwqAmrI1wb7TWCpnNBV1JfkOVimz0RYNCri7zjjHfkOVimzWqTp5Iq2ZsscluqFryY4vQCri7zjjHf1vRzuDTxbkdBzxRZ)(vOW5Y)1qMH68RWSeplahdAyjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErMH68RWSeplahdAyjjHfh)JRZrql0Ws8SaOsNffSeGqni0szcE(QGzihmflkyXkwaN1bAkyoaIzPplkyPhlbiudcTuMGNVkygQZVcZs8Se30zjjHLaeQbHwktWZxfmd5GPyPpljjSOcXywuWYvpnrqT)eyUDO2)8qD(vywaglkLU9BhlLSgBRBVrLRQjq7yBV5H)GL9wBnPYWwM0RIS3ajCyUO)GL9wCaI(SmhQ9NfvQbhILf(kuSG0yAVfM7P5C7TaeQbHwktWZxfmd5GPyrbli85CvnzcG5aSaV)GflkyPhlo(hxNJGwOHL4zbqLolkyXkwcqeu51BQd1(NBoXssclbicQ86n1HA)ZnNyrblo(hxNJGwOHfGXI1Kol9zrblwXsaIGkVEdcQ(9udlkyPhlwXsaIGkVEtDO2)CZjwssyjaHAqOLYeGfciqu(3Pmo6M7XMHCWuS0NffSyflGZ6anfmhaX2VDSucn2w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzVzflGZ6anfmhaXSOGfe(CUQMmbWCawG3FWIffS0JLES44FCDocAHgwINfav6SOGLESOUAndqxboeyM6IGwOPJQptfnOUyqMveljjSyflbicQ86naLAoVyPpljjSOUAnJQgcb1l8BwrSOGf1vRzu1qiOEHFZqD(vywaglQRwZe88vbd4A8)Gfl9zjjHLREAIGA)jWC7qT)5H68RWSamwuxTMj45RcgW14)blwssyjarqLxVPou7FU5el9zrbl9yXkwcqeu51BQd1(NBoXsscl9yXX)46Ce0cnSamwSM0zjjHfq4BARjvg2YKEvK5VaqxHIL(SOGLESGWNZv1KjaleqGOmiHtvbwssyjaHAqOLYeGfciqu(3Pmo6M7XMHCWuS0NL(2BGeomx0FWYEdPXejwBfyXYovS4plaQ0bmlXedazPhC0ql0WYV7flwt6SetmaKfl3VZcsHfciquFwSC)oC9SOH4RqXYFDelxXsS1qiOEHFw8cKf9velRiwSC)olifwiGarSCnwUNfloMfqcNQceO9gcFYL3r2BbWCawG3FWkRc93(TJLsacBRBVrLRQjq7yBVfM7P5C7ne(CUQMmbWCawG3FWkRc93EZd)bl7TaPj8FUo76dv1r1B)2XsjGJT1T3OYv1eODST3cZ90CU9gcFoxvtMayoalW7pyLvH(BV5H)GL92vbFk)pyz)2XsjaPT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2BuqFryYCvwVkFyb4zbqYcsyXd)bld(9PDdziKrH1t5)6iwamlwXcf0xeMmxL1RYhwaEw6XcGGfaZY7AQEdgU0zyl)7uUbhc)gQCvnbYcWZsCzPpliHfp8hSmwg)3neYOW6P8FDelaML0naKfKWcoI068UJFYEdKWH5I(dw2BOp(Vo)jml7qlS0Tc7SetmaKfFiwq5xrGSerdlykalq7ne(KlVJS3CCeaKMnky)2XsjaLT1T3OYv1eODST38WFWYEd)(GxdkYEdKWH5I(dw2BXXvxelBVp41GIWSyzNkw(DIL2HA)z5WS4QW1ZYdzHkq0XsBOkgPy5WS4QW1ZYdzHkq0Xsk4IfFiw8Nfav6aMLyIbGSCflEXc6h0xeMqhlinMiXARalAh)yw8c(70WcGeWykGzboSKcUyXcCPbzbIGMGhXshCiw(DVyHtukDwIjgaYILDQyjfCXIf4sdwO9zz79bVguelf0I9wyUNMZT36XIkeJzrblx90eb1(tG52HA)Zd15xHzbySynSKKWspwuxTMzCeubx4CBOkgPmd15xHzbySGkaA6CKXcWZsGonl9yXX)46Ce0cnSGewIB6S0NffSOUAnZ4iOcUW52qvmszwrS0NL(SKKWspwC8pUohbTqdlaMfe(CUQMmoocasZgfyb4zrD1AgkOVimLXqTpMH68RWSaywaHVPTMuzylt6vrM)caHZd15xXcWZcanOHL4zrjLsNLKewC8pUohbTqdlaMfe(CUQMmoocasZgfyb4zrD1AgkOVimL1RYhZqD(vywamlGW30wtQmSLj9QiZFbGW5H68Ryb4zbGg0Ws8SOKsPZsFwuWcf0xeMmxL9kflkyPhlwXI6Q1mbpFvWSIyjjHfRy5DnvVb)(OHdOHkxvtGS0NffS0JLESyflbiudcTuMGNVkywrSKKWsaIGkVEdqPMZlwuWIvSeGqni0szOUiOfAYQWc0SIyPpljjSeGiOYR3uhQ9p3CIL(SOGLESyflbicQ86niO63tnSKKWIvSOUAntWZxfmRiwssyXX)46Ce0cnSeplaQ0zPpljjS0JL31u9g87JgoGgQCvnbYIcwuxTMj45RcMvelkyPhlQRwZGFF0Wb0GFpaelaJL4Yssclo(hxNJGwOHL4zbqLol9zPpljjSOUAntWZxfmRiwuWIvSOUAnZ4iOcUW52qvmszwrSOGfRy5DnvVb)(OHdOHkxvtG2VDSay62w3EJkxvtG2X2EZd)bl7TISK7GWYEdKWH5I(dw2BXjMybajewywUIf0Bv(Wc6h0xeMyXlqwWocIfKZ46gGJdlTMfaKqyXsdoSG0yIeRTc2BH5EAo3ERhlQRwZqb9fHPSEv(ygQZVcZs8SqiJcRNY)1rSKKWspwc7(GIWSOmlaKffSmuy3huu(VoIfGXcAyPpljjSe29bfHzrzwIll9zrblEuoStbGSF7ybqLSTU9gvUQMaTJT9wyUNMZT36XI6Q1muqFrykRxLpMH68RWSepleYOW6P8FDelkyPhlbiudcTuMGNVkygQZVcZs8SGM0zjjHLaeQbHwktawiGar5FNY4OBUhBgQZVcZs8SGM0zPpljjS0JLWUpOimlkZcazrbldf29bfL)RJybySGgw6ZssclHDFqrywuML4YsFwuWIhLd7uai7np8hSS32DDl3bHL9BhlacqBRBVrLRQjq7yBVfM7P5C7TESOUAndf0xeMY6v5JzOo)kmlXZcHmkSEk)xhXIcw6Xsac1GqlLj45RcMH68RWSeplOjDwssyjaHAqOLYeGfciqu(3Pmo6M7XMH68RWSeplOjDw6Zsscl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKKWsy3hueMfLzjUS0NffS4r5WofaYEZd)bl7T2sRZDqyz)2XcGX1262Bu5QAc0o22BGeomx0FWYEd5aI(SalwcG2BE4pyzVzXN5Gtg2YKEvK9BhlaAn2w3EJkxvtG2X2EZd)bl7n87t7gYEdKWH5I(dw2BXjMyz79PDdXYdzjAGbw2GAFyb9d6lctSahwSStflxXcS0Pyb9wLpSG(b9fHjw8cKLfMyb5aI(SenWaMLRXYvSGERYhwq)G(IWK9wyUNMZT3OG(IWK5QSEv(WsscluqFryYGHAFYfHSNLKewOG(IWKXRu5Iq2ZssclQRwZyXN5Gtg2YKEvKzfXIcwuxTMHc6lctz9Q8XSIyjjHLESOUAntWZxfmd15xHzbyS4H)GLXY4)UHqgfwpL)RJyrblQRwZe88vbZkIL(2VDSaiASTU9Mh(dw2Bwg)3T3OYv1eODSTF7ybqaHT1T3OYv1eODST38WFWYEBwv2d)bRS(WV9M(WFU8oYER5A9Vpl73(T3CizBD7yPKT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2B9yrD1AM)6ilWPYGd5DQxbsJzOo)kmlaJfubqtNJmwamlPBuILKewuxTM5VoYcCQm4qEN6vG0ygQZVcZcWyXd)bld(9PDdziKrH1t5)6iwamlPBuIffS0JfkOVimzUkRxLpSKKWcf0xeMmyO2NCri7zjjHfkOVimz8kvUiK9S0NL(SOGf1vRz(RJSaNkdoK3PEfinMvelkyzwf1GdkY8xhzbovgCiVt9kqAmu5QAc0EdKWH5I(dw2Bi11HL2FcZILD63PHLFNyjooK3f8pStdlQRwJflNwZsZ1AwGTglwUF)kw(DILIq2ZsWXV9gcFYL3r2BGd5DzlNwNBUwNHTM9BhlaABD7nQCvnbAhB7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MvSqb9fHjZvzmu7dlkyPhl4isRZVpOOhBWVpTBiwINf0WIcwExt1BWWLodB5FNYn4q43qLRQjqwssybhrAD(9bf9yd(9PDdXs8SaCyPV9giHdZf9hSS3qQRdlT)eMfl70VtdlBVp41GIy5WSybo)olbh)xHIficAyz79PDdXYvSGERYhwq)G(IWK9gcFYL3r2BhQcoug)(GxdkY(TJvCTTU9gvUQMaTJT9Mh(dw2BbyHaceL)DkJJU5ES9giHdZf9hSS3ItmXcsHfciqelw2PIf)zrtyml)UxSGM0zjMyailEbYI(kILvelwUFNfKgtKyTvWElm3tZ52BwXc4SoqtbZbqmlkyPhl9ybHpNRQjtawiGarzqcNQcSOGfRyjaHAqOLYe88vbZqoykwssyrD1AMGNVkywrS0NffS0Jf1vRzOG(IWuwVkFmd15xHzjEwaeSKKWI6Q1muqFrykJHAFmd15xHzjEwaeS0NffS0JfRyzwf1GdkYO6AVcug2YUwN)9RqHnu5QAcKLKewuxTMr11EfOmSLDTo)7xHcNl)xdzWVhaIL4zjUSKKWI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqSeplXLL(SKKWIkeJzrblTd1(NhQZVcZcWyrP0zrblwXsac1GqlLj45RcMHCWuS03(TJL1yBD7nQCvnbAhB7np8hSS3ghbvWfo3gQIrk7nqchMl6pyzVfNyIL4WqvmsXIL73zbPXejwBfS3cZ90CU9M6Q1mbpFvWmuNFfML4zrj0y)2Xcn2w3EJkxvtG2X2EZd)bl7n8QA3q2BHubnLFFqrp2owkzVfM7P5C7TESmuBi8URQjwssyrD1AgkOVimLXqTpMH68RWSamwIllkyHc6lctMRYyO2hwuWYqD(vywaglkznSOGL31u9gmCPZWw(3PCdoe(nu5QAcKL(SOGL3hu0B(RJYpmdEelXZIswdlaywWrKwNFFqrpMfaZYqD(vywuWspwOG(IWK5QSxPyjjHLH68RWSamwqfanDoYyPV9giHdZf9hSS3ItmXY2QA3qSCflrEbsDxGfyXIxP(9RqXYV7pl6dbHzrjRbtbmlEbYIMWywSC)olDWHy59bf9yw8cKf)z53jwOcKfyJfNLnO2hwq)G(IWel(ZIswdlykGzboSOjmMLH68RUcfloMLhYsbFw2DexHILhYYqTHW7SaUMRqXc6TkFyb9d6lct2VDSae2w3EJkxvtG2X2EZd)bl7n87tZ1A7nqchMl6pyzVHCIOiwwrSS9(0CTMf)zX1Aw(RJWSSknHXSSWxHIf0lvWhhZIxGSCplhMfxfUEwEilrdmWcCyrtpl)oXcoIcNRzXd)blw0xrSOsAOfw29cutSehhY7uVcKgwGflaKL3hu0JT3cZ90CU9MvS8UMQ3GFsR9jdox7nu5QAcKffS0Jf1vRzWVpnxRnd1gcV7QAIffS0JfCeP153hu0Jn43NMR1SamwIlljjSyflZQOgCqrM)6ilWPYGd5DQxbsJHkxvtGS0NLKewExt1BWWLodB5FNYn4q43qLRQjqwuWI6Q1muqFrykJHAFmd15xHzbySexwuWcf0xeMmxLXqTpSOGf1vRzWVpnxRnd15xHzbySaCyrbl4isRZVpOOhBWVpnxRzjELzXAyPplkyPhlwXYSkQbhuKrNk4JJZnnr)vOYO0xxeMmu5QAcKLKew(RJyb5YI1GgwINf1vRzWVpnxRnd15xHzbWSaqw6ZIcwEFqrV5Vok)Wm4rSeplOX(TJfWX262Bu5QAc0o22BE4pyzVHFFAUwBVbs4WCr)bl7nKJ73zz7jT2hwIJZ1EwwyIfyXsaKfl7uXYqTHW7UQMyrD9SG)tRzXIFpln4Wc6Lk4JJzjAGbw8cKfqyH2NLfMyrLAWHybPXrSHLT)0AwwyIfvQbhIfKcleqGiwWxfiw(D)zXYP1SenWalEb)DAyz79P5AT9wyUNMZT3Ext1BWpP1(KbNR9gQCvnbYIcwuxTMb)(0CT2muBi8URQjwuWspwSILzvudoOiJovWhhNBAI(RqLrPVUimzOYv1eiljjS8xhXcYLfRbnSeplwdl9zrblVpOO38xhLFyg8iwINL4A)2XcqABD7nQCvnbAhB7np8hSS3WVpnxRT3ajCyUO)GL9gYX97SehhY7uVcKgwwyILT3NMR1S8qwaIOiwwrS87elQRwJf1uS4AmKLf(kuSS9(0CTMfyXcAybtbybIzboSOjmMLH68RUcL9wyUNMZT3Mvrn4GIm)1rwGtLbhY7uVcKgdvUQMazrbl4isRZVpOOhBWVpnxRzjELzjUSOGLESyflQRwZ8xhzbovgCiVt9kqAmRiwuWI6Q1m43NMR1MHAdH3DvnXsscl9ybHpNRQjd4qEx2YP15MR1zyRXIcw6XI6Q1m43NMR1MH68RWSamwIlljjSGJiTo)(GIESb)(0CTML4zbGSOGL31u9g8tATpzW5AVHkxvtGSOGf1vRzWVpnxRnd15xHzbySGgw6ZsFw6B)2XcqzBD7nQCvnbAhB7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MJ)X15iOfAyjEwaKPZcaMLESOu6Sa8SOUAnZFDKf4uzWH8o1RaPXGFpael9zbaZspwuxTMb)(0CT2muNFfMfGNL4YcsybhrADE3XpXcWZIvS8UMQ3GFsR9jdox7nu5QAcKL(SaGzPhlbiudcTug87tZ1AZqD(vywaEwIlliHfCeP15Dh)elaplVRP6n4N0AFYGZ1EdvUQMazPplayw6Xci8nT1KkdBzsVkYmuNFfMfGNf0WsFwuWspwuxTMb)(0CT2SIyjjHLaeQbHwkd(9P5ATzOo)kml9T3ajCyUO)GL9gsDDyP9NWSyzN(DAyXzz79bVguellmXILtRzj4lmXY27tZ1AwEilnxRzb2AOJfVazzHjw2EFWRbfXYdzbiIIyjooK3PEfinSGFpaelRi7ne(KlVJS3WVpnxRZwG1NBUwNHTM9BhlLs3262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T4etSS9(GxdkIfl3VZsCCiVt9kqAy5HSaerrSSIy53jwuxTglwUFhUEw0q8vOyz79P5AnlRO)6iw8cKLfMyz79bVguelWIfRbWSeBymTol43daHzzv)PzXAy59bf9y7TWCpnNBVHWNZv1KbCiVlB506CZ16mS1yrbli85CvnzWVpnxRZwG1NBUwNHTglkyXkwq4Z5QAYCOk4qz87dEnOiwssyPhlQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SexwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINL4YsFwuWcoI0687dk6Xg87tZ1AwaglwdlkybHpNRQjd(9P5AD2cS(CZ16mS1SF7yPKs2w3EJkxvtG2X2EZd)bl7nh0J(dbLXw8PZElKkOP87dk6X2Xsj7TWCpnNBVzfl)fa6kuSOGfRyXd)blJd6r)HGYyl(0Lb9ohfzUk30hQ9NLKewaHVXb9O)qqzSfF6YGENJIm43daXcWyjUSOGfq4BCqp6peugBXNUmO35OiZqD(vywaglX1EdKWH5I(dw2BXjMybBXNowWqw(D)zjfCXck6zPZrglRO)6iwutXYcFfkwUNfhZI2FIfhZseeJpvnXcSyrtyml)UxSexwWVhacZcCybaLf(zXYovSexaZc(9aqywiKfDdz)2XsjaABD7nQCvnbAhB7np8hSS36GWQDdzVfsf0u(9bf9y7yPK9wyUNMZT3gQneE3v1elky59bf9M)6O8dZGhXs8S0JLESOK1WcGzPhl4isRZVpOOhBWVpTBiwaEwailaplQRwZqb9fHPSEv(ywrS0NL(SaywgQZVcZsFwqcl9yrjwamlVRP6nVLRYDqyHnu5QAcKL(SOGLESeGqni0szcE(QGzihmflkyXkwaN1bAkyoaIzrbl9ybHpNRQjtawiGarzqcNQcSKKWsac1GqlLjaleqGO8VtzC0n3Jnd5GPyjjHfRyjarqLxVPou7FU5el9zjjHfCeP153hu0Jn43N2nelaJLES0Jfablayw6XI6Q1muqFrykRxLpMvelaplaKL(S0NfGNLESOelaML31u9M3Yv5oiSWgQCvnbYsFw6ZIcwSIfkOVimzWqTp5Iq2Zsscl9yHc6lctMRYyO2hwssyPhluqFryYCvwf(7SKKWcf0xeMmxL1RYhw6ZIcwSIL31u9gmCPZWw(3PCdoe(nu5QAcKLKewuxTMjAUo4aEUo7tWRlKJwASpgeUErSeVYSaq0Kol9zrbl9ybhrAD(9bf9yd(9PDdXcWyrP0zb4zPhlkXcGz5DnvV5TCvUdclSHkxvtGS0NL(SOGfh)JRZrql0Ws8SGM0zbaZI6Q1m43NMR1MH68RWSa8SaiyPplkyPhlwXI6Q1maDf4qGzQlcAHMoQ(mv0G6IbzwrSKKWcf0xeMmxLXqTpSKKWIvSeGiOYR3auQ58IL(SOGfRyrD1AMXrqfCHZTHQyKkJVQT059u4NMZnRi7nqchMl6pyzVbGGAdH3zbajewTBiwUglinMiXARalhMLHCWuOJLFNgIfFiw0egZYV7flOHL3hu0Jz5kwqVv5dlOFqFryIfl3VZYg8JdOJfnHXS87EXIsPZc83PXYHjwUIfVsXc6h0xeMyboSSIy5HSGgwEFqrpMfvQbhIfNf0Bv(Wc6h0xeMmSehHfAFwgQneENfW1CfkwqoDf4qGSG(Drql00r1ZYQ0egZYvSSb1(Wc6h0xeMSF7yPuCTTU9gvUQMaTJT9Mh(dw2Bn4eOmSLl)xdzVbs4WCr)bl7T4etSehGXIfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhlLSgBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3SIfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcw6XspwuxTMb)(0CT2SIyjjHLES8UMQ3GFsR9jdox7nu5QAcKLKewcqeu51BQd1(NBoXsFw6ZIcw6XIvSOUAndgQX)fiZkIffSyflQRwZe88vbZkIffS0JfRy5DnvVPTMuzylt6vrgQCvnbYssclQRwZe88vbd4A8)GflXZsac1GqlLPTMuzylt6vrMH68RWSaywaKS0NffSGWNZv1K53NtRZyIaIMSf)EwuWspwSILaebvE9M6qT)5MtSKKWsac1GqlLjaleqGO8VtzC0n3JnRiwuWspwuxTMb)(0CT2muNFfMfGXcazjjHfRy5DnvVb)Kw7tgCU2BOYv1eil9zPplky59bf9M)6O8dZGhXs8SOUAntWZxfmGRX)dwSa8SKUb4WsFwssyrfIXSOGL2HA)Zd15xHzbySOUAntWZxfmGRX)dwS03EdHp5Y7i7TayoalW7pyLDiz)2Xsj0yBD7nQCvnbAhB7np8hSS3cKMW)56SRpuvhvV9giHdZf9hSS3ItmXcsJjsS2kWcSyjaYYQ0egZIxGSOVIy5EwwrSy5(DwqkSqabIS3cZ90CU9gcFoxvtMayoalW7pyLDiz)2XsjaHT1T3OYv1eODST3cZ90CU9gcFoxvtMayoalW7pyLDizV5H)GL92vbFk)pyz)2XsjGJT1T3OYv1eODST38WFWYEJ6IGwOjRclq7nqchMl6pyzVfNyIf0VlcAHgwInSazbwSeazXY97SS9(0CTMLvelEbYc2rqS0GdlaWLg7dlEbYcsJjsS2kyVfM7P5C7nvigZIcwU6PjcQ9NaZTd1(NhQZVcZcWyrj0Wsscl9yrD1AMO56Gd456SpbVUqoAPX(yq46fXcWybGOjDwssyrD1AMO56Gd456SpbVUqoAPX(yq46fXs8kZcart6S0NffSOUAnd(9P5ATzfXIcw6Xsac1GqlLj45RcMH68RWSeplOjDwssybCwhOPG5aiML(2VDSucqABD7nQCvnbAhB7np8hSS3WpP1(KBAFi7TqQGMYVpOOhBhlLS3cZ90CU92qTHW7UQMyrbl)1r5hMbpIL4zrj0WIcwWrKwNFFqrp2GFFA3qSamwSgwuWIhLd7uaiwuWspwuxTMj45RcMH68RWSeplkLoljjSyflQRwZe88vbZkIL(2BGeomx0FWYEdab1gcVZst7dXcSyzfXYdzjUS8(GIEmlwUFhUEwqAmrI1wbwuPRqXIRcxplpKfczr3qS4filf8zbIGMGhfDfk73owkbOSTU9gvUQMaTJT9Mh(dw2BT1KkdBzsVkYEdKWH5I(dw2BXjMyjoarFwUglxHpqIfVyb9d6lctS4fil6RiwUNLvelwUFNfNfa4sJ9HLObgyXlqwIjOh9hcILnl(0zVfM7P5C7nkOVimzUk7vkwuWIhLd7uaiwuWI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lIfGXcart6SOGLESacFJd6r)HGYyl(0Lb9ohfz(la0vOyjjHfRyjarqLxVPOWa1WbKLKewWrKwNFFqrpML4zbGS0NffS0Jf1vRzghbvWfo3gQIrkZqD(vywaglakwaWS0Jf0WcWZYSkQbhuKbFvBPZ7PWpnNBOYv1eil9zrblQRwZmocQGlCUnufJuMveljjSyflQRwZmocQGlCUnufJuMvel9zrbl9yXkwcqOgeAPmbpFvWSIyjjHf1vRz(9506mMiGOXGFpaelaJfLqdlkyPDO2)8qD(vywaglam90zrblTd1(NhQZVcZs8SOu6PZssclwXcgU0QxbAA(76Ct7wmu5QAcKL(2VDSay62w3EJkxvtG2X2EZd)bl7n87tZ1A7nqchMl6pyzVfNyIfNLT3NMR1SaGUOFNLObgyzvAcJzz79P5AnlhMfxpKdMILvelWHLuWfl(qS4QW1ZYdzbIGMGhXsmXaq7TWCpnNBVPUAndSOFhNJOjqr)blZkIffS0Jf1vRzWVpnxRnd1gcV7QAILKewC8pUohbTqdlXZcGkDw6B)2XcGkzBD7nQCvnbAhB7np8hSS3WVpnxRT3ajCyUO)GL9wCC1fXsmXaqwuPgCiwqkSqabIyXY97SS9(0CTMfVaz53PILT3h8Aqr2BH5EAo3ElarqLxVPou7FU5elkyXkwExt1BWpP1(KbNR9gQCvnbYIcw6XccFoxvtMaSqabIYGeovfyjjHLaeQbHwktWZxfmRiwssyrD1AMGNVkywrS0NffSeGqni0szcWcbeik)7ughDZ9yZqD(vywaglOcGMohzSa8SeOtZspwC8pUohbTqdliHf0Kol9zrblQRwZGFFAUwBgQZVcZcWyXAyrblwXc4SoqtbZbqS9BhlacqBRBVrLRQjq7yBVfM7P5C7TaebvE9M6qT)5MtSOGLESGWNZv1KjaleqGOmiHtvbwssyjaHAqOLYe88vbZkILKewuxTMj45RcMvel9zrblbiudcTuMaSqabIY)oLXr3Cp2muNFfMfGXcGGffSOUAnd(9P5ATzfXIcwOG(IWK5QSxPyrblwXccFoxvtMdvbhkJFFWRbfXIcwSIfWzDGMcMdGy7np8hSS3WVp41GISF7ybW4ABD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9wCIjw2EFWRbfXIL73zXlwaqx0VZs0adSahwUglPGl0cYcebnbpILyIbGSy5(DwsbxdlfHSNLGJFdlXuJHSaU6IyjMyail(ZYVtSqfilWgl)oXcaQu97PgwuxTglxJLT3NMR1SybU0GfAFwAUwZcS1yboSKcUyXhIfyXcaz59bf9y7TWCpnNBVPUAndSOFhNdAYNmIdFWYSIyjjHLESyfl43N2nKXJYHDkaelkyXkwq4Z5QAYCOk4qz87dEnOiwssyPhlQRwZe88vbZqD(vywaglOHffSOUAntWZxfmRiwssyPhl9yrD1AMGNVkygQZVcZcWybva005iJfGNLaDAw6XIJ)X15iOfAybjSe30zPplkyrD1AMGNVkywrSKKWI6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBgQZVcZcWybva005iJfGNLaDAw6XIJ)X15iOfAybjSe30zPplkyrD1AMXrqfCHZTHQyKkJVQT059u4NMZnRiw6ZIcwcqeu51Bqq1VNAyPpl9zrbl9ybhrAD(9bf9yd(9P5AnlaJL4Ysscli85CvnzWVpnxRZwG1NBUwNHTgl9zPplkyXkwq4Z5QAYCOk4qz87dEnOiwuWspwSILzvudoOiZFDKf4uzWH8o1RaPXqLRQjqwssybhrAD(9bf9yd(9P5AnlaJL4YsF73owa0ASTU9gvUQMaTJT9Mh(dw2Bfzj3bHL9giHdZf9hSS3ItmXcasiSWSCflBqTpSG(b9fHjw8cKfSJGyjoS0AwaqcHfln4WcsJjsS2kyVfM7P5C7TESOUAndf0xeMYyO2hZqD(vywINfczuy9u(VoILKew6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjjHLWUpOimlkZsCzPplkyXJYHDkaK9BhlaIgBRBVrLRQjq7yBVfM7P5C7TESOUAndf0xeMYyO2hZqD(vywINfczuy9u(VoILKew6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjjHLWUpOimlkZsCzPplkyXJYHDkaelkyPhlQRwZmocQGlCUnufJuMH68RWSamwqdlkyrD1AMXrqfCHZTHQyKYSIyrblwXYSkQbhuKbFvBPZ7PWpnNBOYv1eiljjSyflQRwZmocQGlCUnufJuMvel9T38WFWYEB31TChew2VDSaiGW262Bu5QAc0o22BH5EAo3ERhlQRwZqb9fHPmgQ9XmuNFfML4zHqgfwpL)RJyrbl9yjaHAqOLYe88vbZqD(vywINf0KoljjSeGqni0szcWcbeik)7ughDZ9yZqD(vywINf0Kol9zjjHLESe29bfHzrzwailkyzOWUpOO8FDelaJf0WsFwssyjS7dkcZIYSexw6ZIcw8OCyNcaXIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJf0WIcwuxTMzCeubx4CBOkgPmRiwuWIvSmRIAWbfzWx1w68Ek8tZ5gQCvnbYssclwXI6Q1mJJGk4cNBdvXiLzfXsF7np8hSS3AlTo3bHL9BhlacCSTU9gvUQMaTJT9giHdZf9hSS3ItmXcYbe9zbwSG04O9Mh(dw2Bw8zo4KHTmPxfz)2XcGasBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3WrKwNFFqrp2GFFA3qSeplwdlaMLMgchw6XsNJFAsLr46fXcWZIsPNoliHfaMol9zbWS00q4WspwuxTMb)(GxdkktDrql00r1NXqTpg87bGybjSynS03EdKWH5I(dw2Bi11HL2FcZILD63PHLhYYctSS9(0UHy5kw2GAFyXY(f2z5WS4plOHL3hu0JbSsS0GdlecAsXcath5YsNJFAsXcCyXAyz79bVguelOFxe0cnDu9SGFpae2EdHp5Y7i7n87t7gkFvgd1(y)2XcGakBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3uIfKWcoI068UJFIfGXcanOHfaml9yjDdazb4zbhrAD(9bf9yd(9PDdXcWZspwuIfaZY7AQEdgU0zyl)7uUbhc)gQCvnbYcWZIsg0WsFw6ZcGzjDJsOHfGNf1vRzghbvWfo3gQIrkZqD(vy7nqchMl6pyzVHuxhwA)jmlw2PFNgwEilihJ)7SaUMRqXsCyOkgPS3q4tU8oYEZY4)E(QCBOkgPSF7yf30TTU9gvUQMaTJT9Mh(dw2Bwg)3T3ajCyUO)GL9wCIjwqog)3z5kw2GAFyb9d6lctSahwUglfKLT3N2nelwoTML29SC1dzbPXejwBfyXRuDWHS3cZ90CU9wpwOG(IWKrVkFYfHSNLKewOG(IWKXRu5Iq2ZIcwq4Z5QAYC4CqtocIL(SOGLES8(GIEZFDu(HzWJyjEwSgwssyHc6lctg9Q8jFvgGSKKWs7qT)5H68RWSamwukDw6ZssclQRwZqb9fHPmgQ9XmuNFfMfGXIh(dwg87t7gYqiJcRNY)1rSOGf1vRzOG(IWugd1(ywrSKKWcf0xeMmxLXqTpSOGfRybHpNRQjd(9PDdLVkJHAFyjjHf1vRzcE(QGzOo)kmlaJfp8hSm43N2nKHqgfwpL)RJyrblwXccFoxvtMdNdAYrqSOGf1vRzcE(QGzOo)kmlaJfczuy9u(VoIffSOUAntWZxfmRiwssyrD1AMXrqfCHZTHQyKYSIyrbli85CvnzSm(VNVk3gQIrkwssyXkwq4Z5QAYC4CqtocIffSOUAntWZxfmd15xHzjEwiKrH1t5)6i73owXvjBRBVrLRQjq7yBVbs4WCr)bl7T4etSS9(0UHy5ASCflO3Q8Hf0pOVimHowUILnO2hwq)G(IWelWIfRbWS8(GIEmlWHLhYs0adSSb1(Wc6h0xeMS38WFWYEd)(0UHSF7yfxaABD7nQCvnbAhB7nqchMl6pyzVfhCT(3NL9Mh(dw2BZQYE4pyL1h(T30h(ZL3r2BnxR)9zz)2V9wZ16FFw2w3owkzBD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9227dEnOiwAWHLoicQJQNLvPjmMLf(kuSeBymTU9wyUNMZT3SILzvudoOiJQR9kqzyl7AD(3Vcf2qa31ffrG2VDSaOT1T3OYv1eODST38WFWYEdVQ2nK9wivqt53hu0JTJLs2BH5EAo3Ede(MoiSA3qMH68RWSepld15xHzb4zbGaKfKWIsas7nqchMl6pyzVHuh)S87elGWNfl3VZYVtS0bXpl)1rS8qwCqqww1FAw(DILohzSaUg)pyXYHzz)EdlBRQDdXYqD(vyw6w6)I0hbYYdzPZ)WolDqy1UHybCn(FWY(TJvCTTU9Mh(dw2BDqy1UHS3OYv1eODSTF73Ed)2w3owkzBD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9wCIjw2EFWRbfXYdzbiIIyzfXYVtSehhY7uVcKgwuxTglxJL7zXcCPbzHqw0nelQudoelTRo8(vOy53jwkczplbh)SahwEilGRUiwuPgCiwqkSqabIS3cZ90CU92SkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkyPhluqFryYCv2RuSOGfRyPhl9yrD1AM)6ilWPYGd5DQxbsJzOo)kmlXZIh(dwglJ)7gczuy9u(VoIfaZs6gLyrbl9yHc6lctMRYQWFNLKewOG(IWK5QmgQ9HLKewOG(IWKrVkFYfHSNL(SKKWI6Q1m)1rwGtLbhY7uVcKgZqD(vywINfp8hSm43N2nKHqgfwpL)RJybWSKUrjwuWspwOG(IWK5QSEv(WsscluqFryYGHAFYfHSNLKewOG(IWKXRu5Iq2ZsFw6ZssclwXI6Q1m)1rwGtLbhY7uVcKgZkIL(SKKWspwuxTMj45RcMveljjSGWNZv1KjaleqGOmiHtvbw6ZIcwcqOgeAPmbyHaceL)DkJJU5ESzihmflkyjarqLxVPou7FU5el9zrbl9yXkwcqeu51Bak1CEXssclbiudcTugQlcAHMSkSand15xHzjEwaKS0NffS0Jf1vRzcE(QGzfXssclwXsac1GqlLj45RcMHCWuS03(TJfaTTU9gvUQMaTJT9Mh(dw2BoOh9hckJT4tN9wivqt53hu0JTJLs2BH5EAo3EZkwaHVXb9O)qqzSfF6YGENJIm)fa6kuSOGfRyXd)blJd6r)HGYyl(0Lb9ohfzUk30hQ9NffS0JfRybe(gh0J(dbLXw8PlVtU28xaORqXssclGW34GE0FiOm2IpD5DY1MH68RWSeplOHL(SKKWci8noOh9hckJT4txg07CuKb)EaiwaglXLffSacFJd6r)HGYyl(0Lb9ohfzgQZVcZcWyjUSOGfq4BCqp6peugBXNUmO35OiZFbGUcL9giHdZf9hSS3ItmXsmb9O)qqSSzXNowSStfl)onelhMLcYIh(dbXc2IpDOJfhZI2FIfhZseeJpvnXcSybBXNowSC)olaKf4WsJSqdl43daHzboSalwCwIlGzbBXNowWqw(D)z53jwkYclyl(0XIpZHGWSaGYc)S4TNgw(D)zbBXNowiKfDdHTF7yfxBRBVrLRQjq7yBV5H)GL9wawiGar5FNY4OBUhBVbs4WCr)bl7T4etywqkSqabIy5ASG0yIeRTcSCywwrSahwsbxS4dXciHtvHRqXcsJjsS2kWIL73zbPWcbeiIfVazjfCXIpelQKgAHfRjDwIjgaAVfM7P5C7nRybCwhOPG5aiMffS0JLESGWNZv1KjaleqGOmiHtvbwuWIvSeGqni0szcE(QGzihmflkyXkwMvrn4GImrZ1bhWZ1zFcEDHC0sJ9XqLRQjqwssyrD1AMGNVkywrS0NffS44FCDocAHgwaglwt6SOGLESOUAndf0xeMY6v5JzOo)kmlXZIsPZssclQRwZqb9fHPmgQ9XmuNFfML4zrP0zPpljjSOcXywuWs7qT)5H68RWSamwukDwuWIvSeGqni0szcE(QGzihmfl9TF7yzn2w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1Jf1vRzghbvWfo3gQIrkZqD(vywINf0WssclwXI6Q1mJJGk4cNBdvXiLzfXsFwuWIvSOUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5MvelkyPhlQRwZa0vGdbMPUiOfA6O6ZurdQlgKzOo)kmlaJfubqtNJmw6ZIcw6XI6Q1muqFrykJHAFmd15xHzjEwqfanDoYyjjHf1vRzOG(IWuwVkFmd15xHzjEwqfanDoYyjjHLESyflQRwZqb9fHPSEv(ywrSKKWIvSOUAndf0xeMYyO2hZkIL(SOGfRy5DnvVbd14)cKHkxvtGS03EdKWH5I(dw2BifwG3FWILgCyX1AwaHpMLF3Fw6CGiml41qS87ukw8Hk0(SmuBi8obYILDQybaHJGk4cZsCyOkgPyz3XSOjmMLF3lwqdlykGzzOo)QRqXcCy53jwak1CEXI6Q1y5WS4QW1ZYdzP5AnlWwJf4WIxPyb9d6lctSCywCv46z5HSqil6gYEdHp5Y7i7nq4Nhc4UUH6O6X2VDSqJT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2B9yXkwuxTMHc6lctzmu7JzfXIcwSIf1vRzOG(IWuwVkFmRiw6ZssclVRP6nyOg)xGmu5QAc0EdKWH5I(dw2BifwG3FWILF3Fwc7uaimlxJLuWfl(qSaxp(ajwOG(IWelpKfyPtXci8z53PHyboSCOk4qS87hMfl3VZYguJ)lq2Bi8jxEhzVbc)mC94dKYuqFryY(TJfGW262Bu5QAc0o22BE4pyzV1bHv7gYElm3tZ52Bd1gcV7QAIffS0Jf1vRzOG(IWugd1(ygQZVcZs8SmuNFfMLKewuxTMHc6lctz9Q8XmuNFfML4zzOo)kmljjSGWNZv1Kbe(z46XhiLPG(IWel9zrbld1gcV7QAIffS8(GIEZFDu(HzWJyjEwucGSOGfpkh2PaqSOGfe(CUQMmGWppeWDDd1r1JT3cPcAk)(GIESDSuY(TJfWX262Bu5QAc0o22BE4pyzVHxv7gYElm3tZ52Bd1gcV7QAIffS0Jf1vRzOG(IWugd1(ygQZVcZs8SmuNFfMLKewuxTMHc6lctz9Q8XmuNFfML4zzOo)kmljjSGWNZv1Kbe(z46XhiLPG(IWel9zrbld1gcV7QAIffS8(GIEZFDu(HzWJyjEwucGSOGfpkh2PaqSOGfe(CUQMmGWppeWDDd1r1JT3cPcAk)(GIESDSuY(TJfG0262Bu5QAc0o22BE4pyzVHFsR9j30(q2BH5EAo3EBO2q4DxvtSOGLESOUAndf0xeMYyO2hZqD(vywINLH68RWSKKWI6Q1muqFrykRxLpMH68RWSepld15xHzjjHfe(CUQMmGWpdxp(aPmf0xeMyPplkyzO2q4DxvtSOGL3hu0B(RJYpmdEelXZIsacwuWIhLd7uaiwuWccFoxvtgq4Nhc4UUH6O6X2BHubnLFFqrp2owkz)2XcqzBD7nQCvnbAhB7np8hSS3AWjqzylx(VgYEdKWH5I(dw2BXjMyjoaJflWILailwUFhUEwcEu0vOS3cZ90CU9MhLd7uai73owkLUT1T3OYv1eODST38WFWYEJ6IGwOjRclq7nqchMl6pyzVfNyIfKtxboeilBr3CpMfl3VZIxPyrdluSqfCHANfTJ)RqXc6h0xeMyXlqw(jflpKf9vel3ZYkIfl3VZcaCPX(WIxGSG0yIeRTc2BH5EAo3ERhl9yrD1AgkOVimLXqTpMH68RWSeplkLoljjSOUAndf0xeMY6v5JzOo)kmlXZIsPZsFwuWsac1GqlLj45RcMH68RWSeplXnDwuWspwuxTMjAUo4aEUo7tWRlKJwASpgeUErSamwaO1KoljjSyflZQOgCqrMO56Gd456SpbVUqoAPX(yiG76IIiqw6ZsFwssyrD1AMO56Gd456SpbVUqoAPX(yq46fXs8kZcaboPZssclbiudcTuMGNVkygYbtXIcwC8pUohbTqdlXZcGkD73owkPKT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2BwXc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrbl9yPhlbiudcTugQlk1qUodhWYRazgQZVcZcWyrjabWHfaZspwusjwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPplkyHaURlkIanuxuQHCDgoGLxbIL(SKKWIJ)X15iOfAyjELzbqLolkyPhlwXY7AQEtBnPYWwM0RImu5QAcKLKewuxTMj45RcgW14)blwINLaeQbHwktBnPYWwM0RImd15xHzbWSaizPplkybHpNRQjZVpNwNXebenzl(9SOGLESOUAndqxboeyM6IGwOPJQptfnOUyqMveljjSyflbicQ86naLAoVyPplky59bf9M)6O8dZGhXs8SOUAntWZxfmGRX)dwSa8SKUb4WssclQqmMffS0ou7FEOo)kmlaJf1vRzcE(QGbCn(FWILKewcqeu51BQd1(NBoXssclQRwZOQHqq9c)MvelkyrD1AgvnecQx43muNFfMfGXI6Q1mbpFvWaUg)pyXcGzPhlakwaEwMvrn4GImrZ1bhWZ1zFcEDHC0sJ9Xqa31ffrGS0NL(SOGfRyrD1AMGNVkywrSOGLESyflbicQ86n1HA)ZnNyjjHLaeQbHwktawiGar5FNY4OBUhBwrSKKWIkeJzrblTd1(NhQZVcZcWyjaHAqOLYeGfciqu(3Pmo6M7XMH68RWSaywaeSKKWs7qT)5H68RWSGCzrjaz6SamwuxTMj45RcgW14)blw6BVbs4WCr)bl7T4etSG0yIeRTcSy5(DwqkSqabIqcYPRahcKLTOBUhZIxGSacl0(SarqJL5EIfa4sJ9Hf4WILDQyj2AieuVWplwGlnileYIUHyrLAWHybPXejwBfyHqw0ne2EdHp5Y7i7TayoalW7pyLXV9BhlLaOT1T3OYv1eODST38WFWYEBCeubx4CBOkgPS3ajCyUO)GL9wCIjw(DIfauP63tnSy5(DwCwqAmrI1wbw(D)z5WfAFwAdSJfa4sJ9XElm3tZ52BQRwZe88vbZqD(vywINfLqdljjSOUAntWZxfmGRX)dwSamwIB6SOGfe(CUQMmbWCawG3FWkJF73owkfxBRBVrLRQjq7yBVfM7P5C7ne(CUQMmbWCawG3FWkJFwuWspwSIf1vRzcE(QGbCn(FWIL4zjUPZssclwXsaIGkVEdcQ(9udl9zjjHf1vRzghbvWfo3gQIrkZkIffSOUAnZ4iOcUW52qvmszgQZVcZcWybqXcGzjalW19MOHchMYU(qvDu9M)6OmcxViwaml9yXkwuxTMrvdHG6f(nRiwuWIvS8UMQ3GFF0Wb0qLRQjqw6BV5H)GL9wG0e(pxND9HQ6O6TF7yPK1yBD7nQCvnbAhB7TWCpnNBVHWNZv1KjaMdWc8(dwz8BV5H)GL92vbFk)pyz)2Xsj0yBD7nQCvnbAhB7nyK9gME7np8hSS3q4Z5QAYEdHRxK9MvSeGqni0szcE(QGzihmfljjSyfli85CvnzcWcbeikds4uvGffSeGiOYR3uhQ9p3CILKewaN1bAkyoaIT3ajCyUO)GL9gaQ(CUQMyzHjqwGflU6PV)iml)U)SyXRNLhYIkXc2rqGS0GdlinMiXARalyil)U)S87ukw8HQNflo(jqwaqzHFwuPgCiw(DQZEdHp5Y7i7nSJGYn4KdE(QG9BhlLae2w3EJkxvtG2X2EZd)bl7T2AsLHTmPxfzVbs4WCr)bl7T4etywIdq0NLRXYvS4flOFqFryIfVaz5NJWS8qw0xrSCplRiwSC)olaWLg7d6ybPXejwBfyXlqwIjOh9hcILnl(0zVfM7P5C7nkOVimzUk7vkwuWIhLd7uaiwuWI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lIfGXcaTM0zrbl9ybe(gh0J(dbLXw8Pld6DokY8xaORqXssclwXsaIGkVEtrHbQHdil9zrbli85CvnzWock3Gto45RcSOGLESOUAnZ4iOcUW52qvmszgQZVcZcWybqXcaMLESGgwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPplkyrD1AMXrqfCHZTHQyKYSIyjjHfRyrD1AMXrqfCHZTHQyKYSIyPV9BhlLao2w3EJkxvtG2X2EZd)bl7n87tZ1A7nqchMl6pyzVfNyIfa0f97SS9(0CTMLObgWSCnw2EFAUwZYHl0(SSIS3cZ90CU9M6Q1mWI(DCoIMaf9hSmRiwuWI6Q1m43NMR1MHAdH3Dvnz)2XsjaPT1T3OYv1eODST3cZ90CU9M6Q1m43hnCand15xHzbySGgwuWspwuxTMHc6lctzmu7JzOo)kmlXZcAyjjHf1vRzOG(IWuwVkFmd15xHzjEwqdl9zrblo(hxNJGwOHL4zbqLU9Mh(dw2BbVcKoRUAn7n1vRLlVJS3WVpA4aA)2XsjaLT1T3OYv1eODST38WFWYEd)(GxdkYEdKWH5I(dw2BXXvxeMLyIbGSOsn4qSGuyHaceXYcFfkw(DIfKcleqGiwcWc8(dwS8qwc7uaiwUglifwiGarSCyw8WVCToflUkC9S8qwujwco(T3cZ90CU9waIGkVEtDO2)CZjwuWccFoxvtMaSqabIYGeovfyrblbiudcTuMaSqabIY)oLXr3Cp2muNFfMfGXcAyrblwXc4SoqtbZbqS9BhlaMUT1T3OYv1eODST38WFWYEd)(0CT2EdKWH5I(dw2BXjMyz79P5AnlwUFNLTN0AFyjoox7zXlqwkilBVpA4aIowSStflfKLT3NMR1SCywwrOJLuWfl(qSCflO3Q8Hf0pOVimXsdoSaibmMcywGdlpKLObgybaU0yFyXYovS4QqeelaQ0zjMyailWHfhmY)dbXc2IpDSS7ywaKagtbmld15xDfkwGdlhMLRyPPpu7VHLybFILF3FwwfinS87elyVJyjalW7pyHz5E0IzbmcZsrRFCnlpKLT3NMR1SaUMRqXcachbvWfML4WqvmsHowSStflPGl0cYc(pTMfQazzfXIL73zbqLoGDCeln4WYVtSOD8Zcknu11yJ9wyUNMZT3Ext1BWpP1(KbNR9gQCvnbYIcwSIL31u9g87JgoGgQCvnbYIcwuxTMb)(0CT2muBi8URQjwuWspwuxTMHc6lctz9Q8XmuNFfML4zbqYIcwOG(IWK5QSEv(WIcwuxTMjAUo4aEUo7tWRlKJwASpgeUErSamwaiAsNLKewuxTMjAUo4aEUo7tWRlKJwASpgeUErSeVYSaq0KolkyXX)46Ce0cnSeplaQ0zjjHfq4BCqp6peugBXNUmO35OiZqD(vywINfajljjS4H)GLXb9O)qqzSfF6YGENJImxLB6d1(ZsFwuWsac1GqlLj45RcMH68RWSeplkLU9BhlaQKT1T3OYv1eODST38WFWYEd)(GxdkYEdKWH5I(dw2BXjMyz79bVguelaOl63zjAGbmlEbYc4QlILyIbGSyzNkwqAmrI1wbwGdl)oXcaQu97PgwuxTglhMfxfUEwEilnxRzb2ASahwsbxOfKLGhXsmXaq7TWCpnNBVPUAndSOFhNdAYNmIdFWYSIyjjHf1vRza6kWHaZuxe0cnDu9zQOb1fdYSIyjjHf1vRzcE(QGzfXIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJfubqtNJmwaEwc0PzPhlo(hxNJGwOHfKWsCtNL(SaywIllaplVRP6nfzj3bHLHkxvtGSOGfRyzwf1GdkYGVQT059u4NMZnu5QAcKffSOUAnZ4iOcUW52qvmszwrSKKWI6Q1mbpFvWmuNFfMfGXcQaOPZrglaplb60S0Jfh)JRZrql0WcsyjUPZsFwssyrD1AMXrqfCHZTHQyKkJVQT059u4NMZnRiwssyXkwuxTMzCeubx4CBOkgPmRiwuWIvSeGqni0szghbvWfo3gQIrkZqoykwssyXkwcqeu51Bqq1VNAyPpljjS44FCDocAHgwINfav6SOGfkOVimzUk7vk73owaeG2w3EJkxvtG2X2EZd)bl7n87dEnOi7nqchMl6pyzVz9jflpKLohiILFNyrLWplWglBVpA4aYIAkwWVha6kuSCplRiwaURlaKoflxXIxPyb9d6lctSOUEwaGln2hwoC9S4QW1ZYdzrLyjAGHabAVfM7P5C7T31u9g87JgoGgQCvnbYIcwSILzvudoOiZFDKf4uzWH8o1RaPXqLRQjqwuWspwuxTMb)(OHdOzfXssclo(hxNJGwOHL4zbqLol9zrblQRwZGFF0Wb0GFpaelaJL4YIcw6XI6Q1muqFrykJHAFmRiwssyrD1AgkOVimL1RYhZkIL(SOGf1vRzIMRdoGNRZ(e86c5OLg7JbHRxelaJfacCsNffS0JLaeQbHwktWZxfmd15xHzjEwukDwssyXkwq4Z5QAYeGfciqugKWPQalkyjarqLxVPou7FU5el9TF7ybW4ABD7nQCvnbAhB7nyK9gME7np8hSS3q4Z5QAYEdHRxK9gf0xeMmxL1RYhwaEwaKSGew8WFWYGFFA3qgczuy9u(VoIfaZIvSqb9fHjZvz9Q8HfGNLESaiybWS8UMQ3GHlDg2Y)oLBWHWVHkxvtGSa8Sexw6ZcsyXd)blJLX)DdHmkSEk)xhXcGzjDJ1Ggwqcl4isRZ7o(jwamlPBqdlaplVRP6nL)RHWzvx7vGmu5QAc0EdKWH5I(dw2BOp(Vo)jml7qlS0Tc7SetmaKfFiwq5xrGSerdlykalq7ne(KlVJS3CCeaKMnky)2XcGwJT1T3OYv1eODST38WFWYEd)(GxdkYEdKWH5I(dw2BXXvxelBVp41GIy5kwCwaoagtbw2GAFyb9d6lctOJfqyH2Nfn9SCplrdmWcaCPX(WsVF3Fwoml7EbQjqwutXcD)onS87elBVpnxRzrFfXcCy53jwIjgagpGkDw0xrS0GdlBVp41GI6JowaHfAFwGiOXYCpXIxSaGUOFNLObgyXlqw00ZYVtS4Qqeel6Riw29cutSS9(OHdO9wyUNMZT3SILzvudoOiZFDKf4uzWH8o1RaPXqLRQjqwuWspwuxTMjAUo4aEUo7tWRlKJwASpgeUErSamwaiWjDwssyrD1AMO56Gd456SpbVUqoAPX(yq46fXcWybGOjDwuWY7AQEd(jT2Nm4CT3qLRQjqw6ZIcw6Xcf0xeMmxLXqTpSOGfh)JRZrql0WcGzbHpNRQjJJJaG0SrbwaEwuxTMHc6lctzmu7JzOo)kmlaMfq4BARjvg2YKEvK5Vaq48qD(vSa8SaqdAyjEwaKPZsscluqFryYCvwVkFyrblo(hxNJGwOHfaZccFoxvtghhbaPzJcSa8SOUAndf0xeMY6v5JzOo)kmlaMfq4BARjvg2YKEvK5Vaq48qD(vSa8SaqdAyjEwauPZsFwuWIvSOUAndSOFhNJOjqr)blZkIffSyflVRP6n43hnCanu5QAcKffS0JLaeQbHwktWZxfmd15xHzjEwaoSKKWcgU0QxbA(9506mMiGOXqLRQjqwuWI6Q1m)(CADgteq0yWVhaIfGXsCJllayw6XYSkQbhuKbFvBPZ7PWpnNBOYv1eilaplOHL(SOGL2HA)Zd15xHzjEwuk90zrblTd1(NhQZVcZcWybGPNol9zrbl9yjaHAqOLYa0vGdbMXr3Cp2muNFfML4zb4WssclwXsaIGkVEdqPMZlw6B)2XcGOX262Bu5QAc0o22BE4pyzVvKLChew2BGeomx0FWYEloXelaiHWcZYvSGERYhwq)G(IWelEbYc2rqSGCgx3aCCyP1SaGeclwAWHfKgtKyTvGfVazb50vGdbYc63fbTqthvV9wyUNMZT36XI6Q1muqFrykRxLpMH68RWSepleYOW6P8FDeljjS0JLWUpOimlkZcazrbldf29bfL)RJybySGgw6ZssclHDFqrywuML4YsFwuWIhLd7uaiwuWccFoxvtgSJGYn4KdE(QG9BhlaciSTU9gvUQMaTJT9wyUNMZT36XI6Q1muqFrykRxLpMH68RWSepleYOW6P8FDelkyXkwcqeu51Bak1CEXsscl9yrD1AgGUcCiWm1fbTqthvFMkAqDXGmRiwuWsaIGkVEdqPMZlw6Zsscl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKKWsy3hueMfLzjUSKKWI6Q1mbpFvWSIyPplkyXJYHDkaelkybHpNRQjd2rq5gCYbpFvGffS0Jf1vRzghbvWfo3gQIrkZqD(vywagl9ybnSaGzbGSa8SmRIAWbfzWx1w68Ek8tZ5gQCvnbYsFwuWI6Q1mJJGk4cNBdvXiLzfXssclwXI6Q1mJJGk4cNBdvXiLzfXsF7np8hSS32DDl3bHL9BhlacCSTU9gvUQMaTJT9wyUNMZT36XI6Q1muqFrykRxLpMH68RWSepleYOW6P8FDelkyXkwcqeu51Bak1CEXsscl9yrD1AgGUcCiWm1fbTqthvFMkAqDXGmRiwuWsaIGkVEdqPMZlw6Zsscl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKKWsy3hueMfLzjUSKKWI6Q1mbpFvWSIyPplkyXJYHDkaelkybHpNRQjd2rq5gCYbpFvGffS0Jf1vRzghbvWfo3gQIrkZqD(vywaglOHffSOUAnZ4iOcUW52qvmszwrSOGfRyzwf1GdkYGVQT059u4NMZnu5QAcKLKewSIf1vRzghbvWfo3gQIrkZkIL(2BE4pyzV1wADUdcl73owaeqABD7nQCvnbAhB7nqchMl6pyzVfNyIfKdi6ZcSyjaAV5H)GL9MfFMdozylt6vr2VDSaiGY262Bu5QAc0o22BE4pyzVHFFA3q2BGeomx0FWYEloXelBVpTBiwEilrdmWYgu7dlOFqFrycDSG0yIeRTcSS7yw0egZYFDel)UxS4SGCm(VZcHmkSEIfn1EwGdlWsNIf0Bv(Wc6h0xeMy5WSSIS3cZ90CU9gf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmELkxeYEwssyPhlQRwZyXN5Gtg2YKEvKzfXsscl4isRZ7o(jwaglPBSg0WIcwSILaebvE9geu97PgwssybhrADE3XpXcWyjDJ1WIcwcqeu51Bqq1VNAyPplkyrD1AgkOVimL1RYhZkILKew6XI6Q1mbpFvWmuNFfMfGXIh(dwglJ)7gczuy9u(VoIffSOUAntWZxfmRiw6B)2XkUPBBD7nQCvnbAhB7nqchMl6pyzVfNyIfKJX)DwG)onwomXIL9lSZYHz5kw2GAFyb9d6lctOJfKgtKyTvGf4WYdzjAGbwqVv5dlOFqFryYEZd)bl7nlJ)72VDSIRs2w3EJkxvtG2X2EdKWH5I(dw2BXbxR)9zzV5H)GL92SQSh(dwz9HF7n9H)C5DK9wZ16FFw2V9BVfnua2P6VT1TJLs2w3EZd)bl7nGUcCiWmo6M7X2Bu5QAc0o22VDSaOT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2BPBVbs4WCr)bl7nRVtSGWNZv1elhMfm9S8qwsNfl3VZsbzb)(ZcSyzHjw(5kGOhJowuIfl7uXYVtS0Ub)SalILdZcSyzHj0Xcaz5AS87elykalqwomlEbYsCz5ASOc)Dw8HS3q4tU8oYEdw5fMY)Cfq0B)2XkU2w3EJkxvtG2X2EdgzV5GG2BE4pyzVHWNZv1K9gcxVi7nLS3cZ90CU92pxbe9MxjZc7QAIffS8ZvarV5vYeGqni0szaxJ)hSS3q4tU8oYEdw5fMY)Cfq0B)2XYASTU9gvUQMaTJT9gmYEZbbT38WFWYEdHpNRQj7neUEr2Ba0Elm3tZ52B)Cfq0BEaAwyxvtSOGLFUci6npanbiudcTugW14)bl7ne(KlVJS3GvEHP8pxbe92VDSqJT1T3OYv1eODST3Gr2BoiO9Mh(dw2Bi85CvnzVHWNC5DK9gSYlmL)5kGO3Elm3tZ52BeWDDrreO5kCywVRQPmWD51V6YGeIlqSKKWcbCxxuebAOUOud56mCalVceljjSqa31ffrGgmCP10)xHkpl1u2BGeomx0FWYEZ67eMy5NRaIEml(qSuWNfF9D(FbxRtXci9u4jqwCmlWILfMyb)(ZYpxbe9ydlXuBXtHzXbbVcflkXsh5fMLFNsXILtRzX1w8uywujwIgQrZqGSCfifrfivplWglyn8T3q46fzVPK9BhlaHT1T38WFWYERdclGUk3GtN9gvUQMaTJT9BhlGJT1T3OYv1eODST38WFWYEZY4)U9M(kkhaT3ukD7TWCpnNBV1JfkOVimz0RYNCri7zjjHfkOVimzUkJHAFyjjHfkOVimzUkRc)DwssyHc6lctgVsLlczpl9T3ajCyUO)GL9gaCOGJFwailihJ)7S4filolBVp41GIybwSSzDwSC)olX6qT)SehCIfVazj2WyADwGdlBVpTBiwG)onwomz)2XcqABD7nQCvnbAhB7TWCpnNBV1JfkOVimz0RYNCri7zjjHfkOVimzUkJHAFyjjHfkOVimzUkRc)DwssyHc6lctgVsLlczpl9zrblrdHWOKXY4)olkyXkwIgcHbGglJ)72BE4pyzVzz8F3(TJfGY262Bu5QAc0o22BH5EAo3EZkwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHfRyjarqLxVPou7FU5eljjSyfl4isRZVpOOhBWVpnxRzrzwuILKewSIL31u9MY)1q4SQR9kqgQCvnbYsscl9yHc6lctgmu7tUiK9SKKWcf0xeMmxL1RYhwssyHc6lctMRYQWFNLKewOG(IWKXRu5Iq2ZsF7np8hSS3WVpTBi73owkLUT1T3OYv1eODST3cZ90CU92SkQbhuKr11EfOmSLDTo)7xHcBOYv1eilkyjarqLxVPou7FU5elkybhrAD(9bf9yd(9P5AnlkZIs2BE4pyzVHFFWRbfz)2V9BVHGg8bl7ybW0bOsPdiaiGYOK9MfFQRqHT3qoIjaIyzTXc5CanlSy9DILRlcopln4WcAbPMV0pAzziG76gcKfmSJyXxpSZFcKLWUxOiSHtd9UIyXAa0SGuyHGMNazz76qkl4u17iJfKllpKf0B5SaEio8blwGr04pCyPhs6ZspLqwFdNg6DfXI1aOzbPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEkHS(gon07kIf0aOzbPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEkHS(gon07kIfabGMfKcle08eilBxhszbNQEhzSGCz5HSGElNfWdXHpyXcmIg)Hdl9qsFw6bqK13WPHExrSaCa0SGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcWbqZcsHfcAEcKf0(ZvarVrjdaaTS8qwq7pxbe9MxjdaaTS0dGiRVHtd9UIyb4aOzbPWcbnpbYcA)5kGO3aqdaaTS8qwq7pxbe9MhGgaaAzPharwFdNg6DfXcGeqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velakanlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSOu6aAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIyrjLa0SGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXIsaeqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9aiY6B40qVRiwucGaAwqkSqqZtGSG2FUci6nkzaaOLLhYcA)5kGO38kzaaOLLEaez9nCAO3velkbqanlifwiO5jqwq7pxbe9gaAaaOLLhYcA)5kGO38a0aaqll9ucz9nCAO3velkfxanlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0dGiRVHtd9UIyrP4cOzbPWcbnpbYcA)5kGO3OKbaGwwEilO9NRaIEZRKbaGww6PeY6B40qVRiwukUaAwqkSqqZtGSG2FUci6na0aaqllpKf0(ZvarV5bObaGww6bqK13WPHExrSOK1aOzbPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEaez9nCACAihXearSS2yHCoGMfwS(oXY1fbNNLgCybTrdfGDQ(Jwwgc4UUHazbd7iw81d78NazjS7fkcB40qVRiwIlGMfKcle08eilO9NRaIEJsgaaAz5HSG2FUci6nVsgaaAzPharwFdNg6DfXI1aOzbPWcbnpbYcA)5kGO3aqdaaTS8qwq7pxbe9MhGgaaAzPharwFdNg6DfXcGcqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velkLoGMfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B4040qoIjaIyzTXc5CanlSy9DILRlcopln4WcADiHwwgc4UUHazbd7iw81d78NazjS7fkcB40qVRiwucqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll(Zc6dGg9yPNsiRVHtd9UIyjUaAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIybqaOzbPWcbnpbYY21HuwWPQ3rglixKllpKf0B5S0bbx6fMfyen(dhw6HC7ZspLqwFdNg6DfXcGaqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9aiY6B40qVRiwaoaAwqkSqqZtGSSDDiLfCQ6DKXcYf5YYdzb9wolDqWLEHzbgrJ)WHLEi3(S0tjK13WPHExrSaCa0SGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcGeqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velakanlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0dGiRVHtd9UIyrjacOzbPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEkHS(gon07kIfLauaAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIybGkbOzbPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEkHS(gon07kIfagxanlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0dGiRVHtd9UIybGXfqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velaenaAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIybGacanlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSaqajGMfKcle08eilBxhszbNQEhzSGCz5HSGElNfWdXHpyXcmIg)Hdl9qsFw6bqK13WPHExrSaqafGMfKcle08eilBxhszbNQEhzSGCz5HSGElNfWdXHpyXcmIg)Hdl9qsFw6PeY6B4040qoIjaIyzTXc5CanlSy9DILRlcopln4WcABUw)7ZcTSmeWDDdbYcg2rS4Rh25pbYsy3lue2WPHExrSaqanlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0tjK13WPXPHCetaeXYAJfY5aAwyX67elxxeCEwAWHf0IF0YYqa31neilyyhXIVEyN)eilHDVqrydNg6DfXIsaAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIyjUaAwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIyrjLa0SGuyHGMNazz76qkl4u17iJfKlYLLhYc6TCw6GGl9cZcmIg)Hdl9qU9zPNsiRVHtd9UIyrjLa0SGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXIsacanlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSaqLa0SGuyHGMNazz76qkl4u17iJfKllpKf0B5SaEio8blwGr04pCyPhs6ZspaIS(gon07kIfaQeGMfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwaiab0SGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcaJlGMfKcle08eilBxhszbNQEhzSGCz5HSGElNfWdXHpyXcmIg)Hdl9qsFw6fxK13WPHExrSaqRbqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9aiY6B40qVRiwaiGaqZcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velae4aOzbPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEkHS(gononKJycGiwwBSqohqZclwFNy56IGZZsdoSGwvO)OLLHaURBiqwWWoIfF9Wo)jqwc7EHIWgon07kIfLaKaAwqkSqqZtGSSDDiLfCQ6DKXcYLLhYc6TCwapeh(GflWiA8hoS0dj9zPxCrwFdNg6DfXIsakanlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0tjK13WPXPzTDrW5jqwaeS4H)Gfl6d)ydNM9goIc2XsP0bO9w0aBNMS3qEKNLy7AVcelXXzDGCAipYZsARIybGak0XcathGkXPXPH8ipliD3luegqZPH8iplaywIjiibYYgu7dlXM8odNgYJ8SaGzbP7EHIaz59bf95RXsWXeMLhYsivqt53hu0JnCAipYZcaMfaeuhebbYYQkkqySpPybHpNRQjml9odzqhlrdHiJFFWRbfXcaoEwIgcHb)(GxdkQVHtd5rEwaWSeteWdKLOHco(VcflihJ)7SCnwUhTyw(DIfldSqXc6h0xeMmCAipYZcaMfaKoqelifwiGarS87elBr3CpMfNf99VMyPdoelnnHStvtS07ASKcUyz3bl0(SSFpl3Zc(6w63lcUW6uSy5(DwIna6yADwamliL0e(pxZsm1hQQJQhDSCpAbzbd0f13WPH8iplaywaq6arS0bXplOTDO2)8qD(vy0YcoqLpheZIhfPtXYdzrfIXS0ou7pMfyPtz4040qEKNLywf89Nazj2U2RaXsmbGOhlbVyrLyPbxfil(ZY()ryansqIQR9kqay81fmOUFFPAoisITR9kqa4TRdPiPd0S)DAKZ2onPSQR9kqMhzpNgNMh(dwyt0qbyNQ)kd0vGdbMXr3CpMtd5zX67eli85CvnXYHzbtplpKL0zXY97SuqwWV)SalwwyILFUci6XOJfLyXYovS87elTBWplWIy5WSalwwycDSaqwUgl)oXcMcWcKLdZIxGSexwUglQWFNfFionp8hSWMOHcWov)bSYibHpNRQj0vEhPmSYlmL)5kGOhDiC9IuoDonp8hSWMOHcWov)bSYibHpNRQj0vEhPmSYlmL)5kGOhDWiLDqq0HW1lszLq31u(NRaIEJsMf2v1KIFUci6nkzcqOgeAPmGRX)dwCAE4pyHnrdfGDQ(dyLrccFoxvtOR8oszyLxyk)Zvarp6Grk7GGOdHRxKYaeDxt5FUci6na0SWUQMu8ZvarVbGMaeQbHwkd4A8)GfNgYZI13jmXYpxbe9yw8HyPGpl(678)cUwNIfq6PWtGS4ywGfllmXc(9NLFUci6XgwIP2INcZIdcEfkwuILoYlml)oLIflNwZIRT4PWSOsSenuJMHaz5kqkIkqQEwGnwWA4ZP5H)Gf2enua2P6pGvgji85CvnHUY7iLHvEHP8pxbe9OdgPSdcIoeUErkRe6UMYeWDDrreO5kCywVRQPmWD51V6YGeIlqjjeWDDrreOH6IsnKRZWbS8kqjjeWDDrreObdxAn9)vOYZsnfNMh(dwyt0qbyNQ)awzK0bHfqxLBWPJtd5zbaouWXplaKfKJX)Dw8cKfNLT3h8AqrSalw2SolwUFNLyDO2FwIdoXIxGSeBymTolWHLT3N2nelWFNglhM408WFWcBIgka7u9hWkJelJ)7OtFfLdGkRu6O7Ak3Jc6lctg9Q8jxeY(KekOVimzUkJHAFssOG(IWK5QSk83tsOG(IWKXRu5Iq23NtZd)blSjAOaSt1FaRmsSm(VJURPCpkOVimz0RYNCri7tsOG(IWK5QmgQ9jjHc6lctMRYQWFpjHc6lctgVsLlczFFfrdHWOKXY4)UcRIgcHbGglJ)7CAE4pyHnrdfGDQ(dyLrc(9PDdHURPSvZQOgCqrgvx7vGYWw2168VFfkCsIvbicQ86n1HA)ZnNssSchrAD(9bf9yd(9P5ATYkLKy17AQEt5)AiCw11EfidvUQMats6rb9fHjdgQ9jxeY(KekOVimzUkRxLpjjuqFryYCvwf(7jjuqFryY4vQCri77ZP5H)Gf2enua2P6pGvgj43h8AqrO7AkpRIAWbfzuDTxbkdBzxRZ)(vOWkcqeu51BQd1(NBoPahrAD(9bf9yd(9P5ATYkXPXPH8iplOpYOW6jqwie0KIL)6iw(DIfp8WHLdZIJWpTRQjdNMh(dwyLXqTpzvY740qEw2OhZsmHOplWIL4cywSC)oC9Saox7zXlqwSC)olBVpA4aYIxGSaqaZc83PXYHjonp8hSWawzKGWNZv1e6kVJu(WzhsOdHRxKY4isRZVpOOhBWVpnxRJxjf9S6DnvVb)(OHdOHkxvtGjjVRP6n4N0AFYGZ1EdvUQMa7NKGJiTo)(GIESb)(0CToEaYPH8SSrpMLGMCeelw2PILT3N2nelbVyz)EwaiGz59bf9ywSSFHDwomldPjeE9S0Gdl)oXc6h0xeMy5HSOsSenuJMHazXlqwSSFHDwANwtdlpKLGJFonp8hSWawzKGWNZv1e6kVJu(W5GMCee6q46fPmoI0687dk6Xg87t7gkEL40qEwItmXsSPbtdqxHIfl3VZcsJjsS2kWcCyXBpnSGuyHaceXYvSG0yIeRTcCAE4pyHbSYirLgmnaDfk0DnL7zvaIGkVEtDO2)CZPKeRcqOgeAPmbyHaceL)DkJJU5ESzf1xH6Q1mbpFvWmuNFfoELqJc1vRzghbvWfo3gQIrkZqD(vyGznkSkarqLxVbbv)EQjjjarqLxVbbv)EQrH6Q1mbpFvWSIuOUAnZ4iOcUW52qvmszwrk6PUAnZ4iOcUW52qvmszgQZVcdmLucaJgGFwf1GdkYGVQT059u4NMZtsuxTMj45RcMH68RWatjLssuc5IJiToV74NaMsg0GM(CAiplaq4ZIL73zXzbPXejwBfy539NLdxO9zXzbaU0yFyjAGbwGdlw2PILFNyPDO2FwomlUkC9S8qwOcKtZd)blmGvgjrW)Gf6UMYQRwZe88vbZqD(v44vcnk6z1SkQbhuKbFvBPZ7PWpnNNKOUAnZ4iOcUW52qvmszgQZVcdmLaokuxTMzCeubx4CBOkgPmRO(jjQqmwr7qT)5H68RWadGOHtd5zbPUoS0(tywSSt)onSSWxHIfKcleqGiwkOfwSCAnlUwdTWsk4ILhYc(pTMLGJFw(DIfS3rS4DWv9SaBSGuyHacebyKgtKyTvGLGJFmNMh(dwyaRmsq4Z5QAcDL3rkhGfciqugKWPQa6q46fPCGoDVETd1(NhQZVcdGvcna4aeQbHwktWZxfmd15xH7JCvcqMEFLd0P71RDO2)8qD(vyaSsObaReathahGqni0szcWcbeik)7ughDZ9yZqD(v4(ixLaKP3xHvJFGzcbvVXbbXgczh(XjjbiudcTuMGNVkygQZVch)vpnrqT)eyUDO2)8qD(v4KKaeQbHwktawiGar5FNY4OBUhBgQZVch)vpnrqT)eyUDO2)8qD(vyaSsPNKyvaIGkVEtDO2)CZPKep8hSmbyHaceL)DkJJU5ESb8WUQMa50qEwItmbYYdzbK0Ekw(DILf2rrSaBSG0yIeRTcSyzNkww4RqXciCPQjwGfllmXIxGSenecQEwwyhfXILDQyXlwCqqwieu9SCywCv46z5HSaEeNMh(dwyaRmsq4Z5QAcDL3rkhaZbybE)bl0HW1ls5EVpOO38xhLFyg8O4vcnjjJFGzcbvVXbbXMRIhnP3xrVE9SIaURlkIanuxuQHCDgoGLxbkjPxVaeQbHwkd1fLAixNHdy5vGmd15xHbMsaI0tscqeu51Bqq1VNAueGqni0szOUOud56mCalVcKzOo)kmWucqaCaCpLuc4Nvrn4GIm4RAlDEpf(P58(9vyvac1GqlLH6IsnKRZWbS8kqMHCWu97RONveWDDrreObdxAn9)vOYZsnvsIvbicQ86n1HA)ZnNsscqOgeAPmy4sRP)VcvEwQPYX1AqdGmDLmd15xHbMskzn9v0Zkc4UUOic0CfomR3v1ug4U86xDzqcXfOKKaeQbHwkZv4WSExvtzG7YRF1LbjexGmd5GP6ROxac1GqlLrLgmnaDfkZqoyQKeRgpqMFGAD)KKE9q4Z5QAYaR8ct5FUci6vwPKee(CUQMmWkVWu(NRaIELJBFf9(5kGO3OKzihmvoaHAqOLkj5NRaIEJsMaeQbHwkZqD(v44V6PjcQ9NaZTd1(NhQZVcdGvk9(jji85CvnzGvEHP8pxbe9kdqf9(5kGO3aqZqoyQCac1GqlvsYpxbe9gaAcqOgeAPmd15xHJ)QNMiO2Fcm3ou7FEOo)kmawP07NKGWNZv1Kbw5fMY)Cfq0RC697NKeGiOYR3auQ58QpNMh(dwyaRmsq4Z5QAcDL3rk)7ZP1zmrart2IFp6q46fPSvy4sREfO53NtRZyIaIgdvUQMatsAhQ9ppuNFfoEaME6jjQqmwr7qT)5H68RWadGObW9SM0bWQRwZ87ZP1zmrarJb)EaiGhG9tsuxTM53NtRZyIaIgd(9aqXhxajaU3SkQbhuKbFvBPZ7PWpnNd8OPpNgYZsCIjwq)UOud5AwaqpGLxbIfaMoMcywuPgCiwCwqAmrI1wbwwyYWP5H)GfgWkJKfMY3tDOR8oszQlk1qUodhWYRaHURPCac1GqlLj45RcMH68RWadGPRiaHAqOLYeGfciqu(3Pmo6M7XMH68RWadGPROhcFoxvtMFFoToJjciAYw87tsuxTM53NtRZyIaIgd(9aqXh30bCVzvudoOid(Q2sN3tHFAoh4be97NKOcXyfTd1(NhQZVcdS4cC40qEwItmXYgCP10FfkwaqSutXcGatbmlQudoelolinMiXARallmz408WFWcdyLrYct57Po0vEhPmgU0A6)RqLNLAk0DnLdqOgeAPmbpFvWmuNFfgyacfwfGiOYR3GGQFp1OWQaebvE9M6qT)5MtjjbicQ86n1HA)ZnNueGqni0szcWcbeik)7ughDZ9yZqD(vyGbiu0dHpNRQjtawiGarzqcNQcjjbiudcTuMGNVkygQZVcdmar)KKaebvE9geu97Pgf9SAwf1GdkYGVQT059u4NMZveGqni0szcE(QGzOo)kmWaejjQRwZmocQGlCUnufJuMH68RWatjRbW9qdWta31ffrGMRW)ScpCWzWdXvuwL06(kuxTMzCeubx4CBOkgPmRO(jjQqmwr7qT)5H68RWadGOHtZd)blmGvgjlmLVN6qx5DKYxHdZ6DvnLbUlV(vxgKqCbcDxtz1vRzcE(QGzOo)kC8kHgf9SAwf1GdkYGVQT059u4NMZtsuxTMzCeubx4CBOkgPmd15xHbMsaeW9IlWRUAnJQgcb1l8Bwr9bCVEahamAaE1vRzu1qiOEHFZkQpWta31ffrGMRW)ScpCWzWdXvuwL06(kuxTMzCeubx4CBOkgPmRO(jjQqmwr7qT)5H68RWadGOHtd5zX67hMLdZIZY4)onSqAxfo(tSyXtXYdzPZbIyX1AwGfllmXc(9NLFUci6XS8qwujw0xrGSSIyXY97SG0yIeRTcS4filifwiGarS4fillmXYVtSaWcKfSg(SalwcGSCnwuH)ol)Cfq0JzXhIfyXYctSGF)z5NRaIEmNMh(dwyaRmswykFp1HrhwdFSY)Cfq0Re6UMYi85CvnzGvEHP8pxbe9kdqfw9ZvarVbGMHCWu5aeQbHwQKKEi85CvnzGvEHP8pxbe9kRusccFoxvtgyLxyk)ZvarVYXTVIEQRwZe88vbZksrpRcqeu51Bqq1VNAssuxTMzCeubx4CBOkgPmd15xHbCp0a8ZQOgCqrg8vTLoVNc)0CEFGP8pxbe9gLmQRwldUg)pyPqD1AMXrqfCHZTHQyKYSIssuxTMzCeubx4CBOkgPY4RAlDEpf(P5CZkQFssac1GqlLj45RcMH68RWagGX)ZvarVrjtac1GqlLbCn(FWsrpRcqeu51BQd1(NBoLKyfcFoxvtMaSqabIYGeovf6RWQaebvE9gGsnNxjjbicQ86n1HA)ZnNuGWNZv1KjaleqGOmiHtvbfbiudcTuMaSqabIY)oLXr3Cp2SIuyvac1GqlLj45RcMvKIE9uxTMHc6lctz9Q8XmuNFfoELspjrD1AgkOVimLXqTpMH68RWXRu69vy1SkQbhuKr11EfOmSLDTo)7xHcNK0tD1Agvx7vGYWw2168VFfkCU8FnKb)EaiLrtsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqkdi73pjrD1AgGUcCiWm1fbTqthvFMkAqDXGmRO(jjQqmwr7qT)5H68RWadGPNKGWNZv1Kbw5fMY)Cfq0RC6CAE4pyHbSYizHP89uhgDyn8Xk)Zvarpar31ugHpNRQjdSYlmL)5kGO3kLbOcR(5kGO3OKzihmvoaHAqOLkjbHpNRQjdSYlmL)5kGOxzaQON6Q1mbpFvWSIu0ZQaebvE9geu97PMKe1vRzghbvWfo3gQIrkZqD(vya3dna)SkQbhuKbFvBPZ7PWpnN3hyk)ZvarVbGg1vRLbxJ)hSuOUAnZ4iOcUW52qvmszwrjjQRwZmocQGlCUnufJuz8vTLoVNc)0CUzf1pjjaHAqOLYe88vbZqD(vyadW4)5kGO3aqtac1GqlLbCn(FWsrpRcqeu51BQd1(NBoLKyfcFoxvtMaSqabIYGeovf6RWQaebvE9gGsnNxk6zL6Q1mbpFvWSIssSkarqLxVbbv)EQPFssaIGkVEtDO2)CZjfi85CvnzcWcbeikds4uvqrac1GqlLjaleqGO8VtzC0n3JnRifwfGqni0szcE(QGzfPOxp1vRzOG(IWuwVkFmd15xHJxP0tsuxTMHc6lctzmu7JzOo)kC8kLEFfwnRIAWbfzuDTxbkdBzxRZ)(vOWjj9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhasz0KKOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaKYaY(97NKOUAndqxboeyM6IGwOPJQptfnOUyqMvusIkeJv0ou7FEOo)kmWay6jji85CvnzGvEHP8pxbe9kNoNgYZsCIjmlUwZc83PHfyXYctSCp1HzbwSea508WFWcdyLrYct57Pom6UMYQRwZe88vbZkkjjarqLxVPou7FU5Kce(CUQMmbyHaceLbjCQkOiaHAqOLYeGfciqu(3Pmo6M7XMvKcRcqOgeAPmbpFvWSIu0RN6Q1muqFrykRxLpMH68RWXRu6jjQRwZqb9fHPmgQ9XmuNFfoELsVVcRMvrn4GImQU2RaLHTSR15F)ku4KKzvudoOiJQR9kqzyl7AD(3Vcfwrp1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGIpUjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43dafFC73pjrD1AgGUcCiWm1fbTqthvFMkAqDXGmROKevigRODO2)8qD(vyGbW050qEwIJu4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOomNMh(dwyaRmsMvL9WFWkRp8JUY7iLDiHo8px4vwj0DnLr4Z5QAYC4Sdjonp8hSWawzKmRk7H)GvwF4hDL3rkRc9hD4FUWRSsO7AkpRIAWbfzuDTxbkdBzxRZ)(vOWgc4UUOicKtZd)blmGvgjZQYE4pyL1h(rx5DKY4NtJtd5zbPUoS0(tywSSt)onS87elXXH8UG)HDAyrD1ASy50AwAUwZcS1yXY97xXYVtSueYEwco(508WFWcBCiPmcFoxvtOR8oszWH8USLtRZnxRZWwdDiC9IuUN6Q1m)1rwGtLbhY7uVcKgZqD(vyGHkaA6CKb40nkLKOUAnZFDKf4uzWH8o1RaPXmuNFfgyE4pyzWVpTBidHmkSEk)xhb40nkPOhf0xeMmxL1RYNKekOVimzWqTp5Iq2NKqb9fHjJxPYfHSVFFfQRwZ8xhzbovgCiVt9kqAmRifZQOgCqrM)6ilWPYGd5DQxbsdNgYZcsDDyP9NWSyzN(DAyz79bVguelhMflW53zj44)kuSarqdlBVpTBiwUIf0Bv(Wc6h0xeM408WFWcBCibyLrccFoxvtOR8os5dvbhkJFFWRbfHoeUErkBff0xeMmxLXqTpk6HJiTo)(GIESb)(0UHIhnkExt1BWWLodB5FNYn4q43qLRQjWKeCeP153hu0Jn43N2nu8aN(CAiplXjMybPWcbeiIfl7uXI)SOjmMLF3lwqt6SetmaKfVazrFfXYkIfl3VZcsJjsS2kWP5H)Gf24qcWkJKaSqabIY)oLXr3CpgDxtzRaN1bAkyoaIv0RhcFoxvtMaSqabIYGeovfuyvac1GqlLj45RcMHCWujjQRwZe88vbZkQVIEQRwZqb9fHPSEv(ygQZVchpGijrD1AgkOVimLXqTpMH68RWXdi6RONvZQOgCqrgvx7vGYWw2168VFfkCsI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqXh3Ke1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGIpU9tsuHySI2HA)Zd15xHbMsPRWQaeQbHwktWZxfmd5GP6ZPH8SeNyIL4WqvmsXIL73zbPXejwBf408WFWcBCibyLrY4iOcUW52qvmsHURPS6Q1mbpFvWmuNFfoELqdNgYZsCIjw2wv7gILRyjYlqQ7cSalw8k1VFfkw(D)zrFiimlkznykGzXlqw0egZIL73zPdoelVpOOhZIxGS4pl)oXcvGSaBS4SSb1(Wc6h0xeMyXFwuYAybtbmlWHfnHXSmuNF1vOyXXS8qwk4ZYUJ4kuS8qwgQneENfW1CfkwqVv5dlOFqFryItZd)blSXHeGvgj4v1UHqxivqt53hu0Jvwj0DnL7nuBi8URQPKe1vRzOG(IWugd1(ygQZVcdS4QGc6lctMRYyO2hfd15xHbMswJI31u9gmCPZWw(3PCdoe(nu5QAcSVI3hu0B(RJYpmdEu8kznayCeP153hu0Jb8qD(vyf9OG(IWK5QSxPssgQZVcdmubqtNJS(CAipliNikILvelBVpnxRzXFwCTML)6imlRstymll8vOyb9sf8XXS4fil3ZYHzXvHRNLhYs0adSahw00ZYVtSGJOW5Aw8WFWIf9velQKgAHLDVa1elXXH8o1RaPHfyXcaz59bf9yonp8hSWghsawzKGFFAUwJURPSvVRP6n4N0AFYGZ1EdvUQMav0tD1Ag87tZ1AZqTHW7UQMu0dhrAD(9bf9yd(9P5AnWIBsIvZQOgCqrM)6ilWPYGd5DQxbst)KK31u9gmCPZWw(3PCdoe(nu5QAcuH6Q1muqFrykJHAFmd15xHbwCvqb9fHjZvzmu7Jc1vRzWVpnxRnd15xHbgWrboI0687dk6Xg87tZ164v2A6RONvZQOgCqrgDQGpoo30e9xHkJsFDrykj5Voc5ICTg0eV6Q1m43NMR1MH68RWagG9v8(GIEZFDu(HzWJIhnCAiplih3VZY2tATpSehNR9SSWelWILailw2PILHAdH3DvnXI66zb)NwZIf)EwAWHf0lvWhhZs0adS4filGWcTpllmXIk1GdXcsJJydlB)P1SSWelQudoelifwiGarSGVkqS87(ZILtRzjAGbw8c(70WY27tZ1Aonp8hSWghsawzKGFFAUwJURP87AQEd(jT2Nm4CT3qLRQjqfQRwZGFFAUwBgQneE3v1KIEwnRIAWbfz0Pc(44Ctt0FfQmk91fHPKK)6iKlY1Aqt8wtFfVpOO38xhLFyg8O4JlNgYZcYX97SehhY7uVcKgwwyILT3NMR1S8qwaIOiwwrS87elQRwJf1uS4AmKLf(kuSS9(0CTMfyXcAybtbybIzboSOjmMLH68RUcfNMh(dwyJdjaRmsWVpnxRr31uEwf1GdkY8xhzbovgCiVt9kqAuGJiTo)(GIESb)(0CToELJRIEwPUAnZFDKf4uzWH8o1RaPXSIuOUAnd(9P5ATzO2q4Dxvtjj9q4Z5QAYaoK3LTCADU5ADg2Ak6PUAnd(9P5ATzOo)kmWIBscoI0687dk6Xg87tZ164bOI31u9g8tATpzW5AVHkxvtGkuxTMb)(0CT2muNFfgyOPF)(CAipli11HL2FcZILD63PHfNLT3h8AqrSSWelwoTMLGVWelBVpnxRz5HS0CTMfyRHow8cKLfMyz79bVguelpKfGikIL44qEN6vG0Wc(9aqSSI408WFWcBCibyLrccFoxvtOR8osz87tZ16Sfy95MR1zyRHoeUErk74FCDocAHM4bKPdG7Pu6aV6Q1m)1rwGtLbhY7uVcKgd(9aq9bW9uxTMb)(0CT2muNFfg4JlYfhrADE3Xpb8w9UMQ3GFsR9jdox7nu5QAcSpaUxac1GqlLb)(0CT2muNFfg4JlYfhrADE3Xpb8VRP6n4N0AFYGZ1EdvUQMa7dG7bcFtBnPYWwM0RImd15xHbE00xrp1vRzWVpnxRnROKKaeQbHwkd(9P5ATzOo)kCFonKNL4etSS9(GxdkIfl3VZsCCiVt9kqAy5HSaerrSSIy53jwuxTglwUFhUEw0q8vOyz79P5AnlRO)6iw8cKLfMyz79bVguelWIfRbWSeBymTol43daHzzv)PzXAy59bf9yonp8hSWghsawzKGFFWRbfHURPmcFoxvtgWH8USLtRZnxRZWwtbcFoxvtg87tZ16Sfy95MR1zyRPWke(CUQMmhQcoug)(GxdkkjPN6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqXh3Ke1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGIpU9vGJiTo)(GIESb)(0CTgywJce(CUQMm43NMR1zlW6ZnxRZWwJtd5zjoXelyl(0XcgYYV7plPGlwqrplDoYyzf9xhXIAkww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz539IL4Yc(9aqywGdlaOSWplw2PIL4cywWVhacZcHSOBionp8hSWghsawzK4GE0FiOm2IpDOlKkOP87dk6XkRe6UMYw9xaORqPWkp8hSmoOh9hckJT4txg07CuK5QCtFO2)Keq4BCqp6peugBXNUmO35Oid(9aqalUkaHVXb9O)qqzSfF6YGENJImd15xHbwC50qEwaqqTHW7SaGecR2nelxJfKgtKyTvGLdZYqoyk0XYVtdXIpelAcJz539If0WY7dk6XSCflO3Q8Hf0pOVimXIL73zzd(Xb0XIMWyw(DVyrP0zb(70y5WelxXIxPyb9d6lctSahwwrS8qwqdlVpOOhZIk1GdXIZc6TkFyb9d6lctgwIJWcTpld1gcVZc4AUcfliNUcCiqwq)UiOfA6O6zzvAcJz5kw2GAFyb9d6lctCAE4pyHnoKaSYiPdcR2ne6cPcAk)(GIESYkHURP8qTHW7UQMu8(GIEZFDu(HzWJIVxpLSga3dhrAD(9bf9yd(9PDdb8ae4vxTMHc6lctz9Q8XSI63hWd15xH7JC7PeGFxt1BElxL7GWcBOYv1eyFf9cqOgeAPmbpFvWmKdMsHvGZ6anfmhaXk6HWNZv1KjaleqGOmiHtvHKKaeQbHwktawiGar5FNY4OBUhBgYbtLKyvaIGkVEtDO2)CZP(jj4isRZVpOOhBWVpTBiG1RhGaa3tD1AgkOVimL1RYhZkc4by)(aFpLa87AQEZB5QChewydvUQMa73xHvuqFryYGHAFYfHSpjPhf0xeMmxLXqTpjj9OG(IWK5QSk83tsOG(IWK5QSEv(0xHvVRP6ny4sNHT8Vt5gCi8BOYv1eysI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lkELbiAsVVIE4isRZVpOOhBWVpTBiGPu6aFpLa87AQEZB5QChewydvUQMa73xHJ)X15iOfAIhnPdGvxTMb)(0CT2muNFfg4be9v0Zk1vRza6kWHaZuxe0cnDu9zQOb1fdYSIssOG(IWK5QmgQ9jjXQaebvE9gGsnNx9vyL6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBwrCAiplXjMyjoaJflWILailwUFhUEwcEu0vO408WFWcBCibyLrsdobkdB5Y)1qO7Ak7r5WofaItZd)blSXHeGvgji85CvnHUY7iLdG5aSaV)Gv2He6q46fPSvGZ6anfmhaXkq4Z5QAYeaZbybE)blf96PUAnd(9P5ATzfLK07DnvVb)Kw7tgCU2BOYv1eyssaIGkVEtDO2)CZP(9v0Zk1vRzWqn(VazwrkSsD1AMGNVkywrk6z17AQEtBnPYWwM0RImu5QAcmjrD1AMGNVkyaxJ)hSIpaHAqOLY0wtQmSLj9QiZqD(vyadi7RaHpNRQjZVpNwNXebenzl(9k6zvaIGkVEtDO2)CZPKKaeQbHwktawiGar5FNY4OBUhBwrk6PUAnd(9P5ATzOo)kmWaysIvVRP6n4N0AFYGZ1EdvUQMa73xX7dk6n)1r5hMbpkE1vRzcE(QGbCn(FWc4t3aC6NKOcXyfTd1(NhQZVcdm1vRzcE(QGbCn(FWQpNgYZsCIjwqAmrI1wbwGflbqwwLMWyw8cKf9vel3ZYkIfl3VZcsHfciqeNMh(dwyJdjaRmscKMW)56SRpuvhvp6UMYi85CvnzcG5aSaV)Gv2HeNMh(dwyJdjaRmsUk4t5)bl0DnLr4Z5QAYeaZbybE)bRSdjonKNL4etSG(Drql0WsSHfilWILailwUFNLT3NMR1SSIyXlqwWocILgCybaU0yFyXlqwqAmrI1wbonp8hSWghsawzKqDrql0KvHfi6UMYQqmwXvpnrqT)eyUDO2)8qD(vyGPeAss6PUAnt0CDWb8CD2NGxxihT0yFmiC9Iagart6jjQRwZenxhCapxN9j41fYrln2hdcxVO4vgGOj9(kuxTMb)(0CT2SIu0laHAqOLYe88vbZqD(v44rt6jjGZ6anfmhaX950qEwaqqTHW7S00(qSalwwrS8qwIllVpOOhZIL73HRNfKgtKyTvGfv6kuS4QW1ZYdzHqw0nelEbYsbFwGiOj4rrxHItZd)blSXHeGvgj4N0AFYnTpe6cPcAk)(GIESYkHURP8qTHW7UQMu8xhLFyg8O4vcnkWrKwNFFqrp2GFFA3qaZAu4r5Wofasrp1vRzcE(QGzOo)kC8kLEsIvQRwZe88vbZkQpNgYZsCIjwIdq0NLRXYv4dKyXlwq)G(IWelEbYI(kIL7zzfXIL73zXzbaU0yFyjAGbw8cKLyc6r)HGyzZIpDCAE4pyHnoKaSYiPTMuzylt6vrO7Aktb9fHjZvzVsPWJYHDkaKc1vRzIMRdoGNRZ(e86c5OLg7JbHRxeWaiAsxrpq4BCqp6peugBXNUmO35OiZFbGUcvsIvbicQ86nffgOgoGjj4isRZVpOOhhpa7RON6Q1mJJGk4cNBdvXiLzOo)kmWaua4EOb4Nvrn4GIm4RAlDEpf(P58(kuxTMzCeubx4CBOkgPmROKeRuxTMzCeubx4CBOkgPmRO(k6zvac1GqlLj45RcMvusI6Q1m)(CADgteq0yWVhacykHgfTd1(NhQZVcdmaME6kAhQ9ppuNFfoELsp9KeRWWLw9kqtZFxNBA3IHkxvtG950qEwItmXIZY27tZ1Awaqx0VZs0adSSknHXSS9(0CTMLdZIRhYbtXYkIf4Wsk4IfFiwCv46z5HSarqtWJyjMyaiNMh(dwyJdjaRmsWVpnxRr31uwD1Agyr)oohrtGI(dwMvKIEQRwZGFFAUwBgQneE3v1usIJ)X15iOfAIhqLEFonKNL44QlILyIbGSOsn4qSGuyHaceXIL73zz79P5AnlEbYYVtflBVp41GI408WFWcBCibyLrc(9P5An6UMYbicQ86n1HA)ZnNuy17AQEd(jT2Nm4CT3qLRQjqf9q4Z5QAYeGfciqugKWPQqssac1GqlLj45RcMvusI6Q1mbpFvWSI6RiaHAqOLYeGfciqu(3Pmo6M7XMH68RWadva005id4d0P754FCDocAHgKlAsVVc1vRzWVpnxRnd15xHbM1OWkWzDGMcMdGyonp8hSWghsawzKGFFWRbfHURPCaIGkVEtDO2)CZjf9q4Z5QAYeGfciqugKWPQqssac1GqlLj45RcMvusI6Q1mbpFvWSI6RiaHAqOLYeGfciqu(3Pmo6M7XMH68RWadqOqD1Ag87tZ1AZksbf0xeMmxL9kLcRq4Z5QAYCOk4qz87dEnOifwboRd0uWCaeZPH8SeNyILT3h8AqrSy5(Dw8Ifa0f97SenWalWHLRXsk4cTGSarqtWJyjMyailwUFNLuW1Wsri7zj443Wsm1yilGRUiwIjgaYI)S87elubYcSXYVtSaGkv)EQHf1vRXY1yz79P5AnlwGlnyH2NLMR1SaBnwGdlPGlw8HybwSaqwEFqrpMtZd)blSXHeGvgj43h8AqrO7AkRUAndSOFhNdAYNmIdFWYSIss6zf(9PDdz8OCyNcaPWke(CUQMmhQcoug)(GxdkkjPN6Q1mbpFvWmuNFfgyOrH6Q1mbpFvWSIss61tD1AMGNVkygQZVcdmubqtNJmGpqNUNJ)X15iOfAqUXn9(kuxTMj45RcMvusI6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBgQZVcdmubqtNJmGpqNUNJ)X15iOfAqUXn9(kuxTMzCeubx4CBOkgPY4RAlDEpf(P5CZkQVIaebvE9geu97PM(9v0dhrAD(9bf9yd(9P5AnWIBsccFoxvtg87tZ16Sfy95MR1zyR1VVcRq4Z5QAYCOk4qz87dEnOif9SAwf1GdkY8xhzbovgCiVt9kqAssWrKwNFFqrp2GFFAUwdS42Ntd5zjoXelaiHWcZYvSSb1(Wc6h0xeMyXlqwWocIL4WsRzbajewS0GdlinMiXARaNMh(dwyJdjaRmskYsUdcl0DnL7PUAndf0xeMYyO2hZqD(v44jKrH1t5)6OKKEHDFqryLbOIHc7(GIY)1radn9tsc7(GIWkh3(k8OCyNcaXP5H)Gf24qcWkJKDx3YDqyHURPCp1vRzOG(IWugd1(ygQZVchpHmkSEk)xhLK0lS7dkcRmavmuy3huu(VocyOPFssy3huew542xHhLd7uaif9uxTMzCeubx4CBOkgPmd15xHbgAuOUAnZ4iOcUW52qvmszwrkSAwf1GdkYGVQT059u4NMZtsSsD1AMXrqfCHZTHQyKYSI6ZP5H)Gf24qcWkJK2sRZDqyHURPCp1vRzOG(IWugd1(ygQZVchpHmkSEk)xhPOxac1GqlLj45RcMH68RWXJM0tscqOgeAPmbyHaceL)DkJJU5ESzOo)kC8Oj9(jj9c7(GIWkdqfdf29bfL)RJagA6NKe29bfHvoU9v4r5Wofasrp1vRzghbvWfo3gQIrkZqD(vyGHgfQRwZmocQGlCUnufJuMvKcRMvrn4GIm4RAlDEpf(P58KeRuxTMzCeubx4CBOkgPmRO(CAiplXjMyb5aI(SalwqACKtZd)blSXHeGvgjw8zo4KHTmPxfXPH8SGuxhwA)jmlw2PFNgwEillmXY27t7gILRyzdQ9Hfl7xyNLdZI)SGgwEFqrpgWkXsdoSqiOjflamDKllDo(PjflWHfRHLT3h8AqrSG(Drql00r1Zc(9aqyonp8hSWghsawzKGWNZv1e6kVJug)(0UHYxLXqTpOdHRxKY4isRZVpOOhBWVpTBO4Tga30q40RZXpnPYiC9IaELspDKlatVpGBAiC6PUAnd(9bVguuM6IGwOPJQpJHAFm43daHCTM(CAipli11HL2FcZILD63PHLhYcYX4)olGR5kuSehgQIrkonp8hSWghsawzKGWNZv1e6kVJu2Y4)E(QCBOkgPqhcxViLvc5IJiToV74NaganOba3lDdabECeP153hu0Jn43N2neW3tja)UMQ3GHlDg2Y)oLBWHWVHkxvtGaVsg00VpGt3OeAaE1vRzghbvWfo3gQIrkZqD(vyonKNL4etSGCm(VZYvSSb1(Wc6h0xeMyboSCnwkilBVpTBiwSCAnlT7z5QhYcsJjsS2kWIxP6GdXP5H)Gf24qcWkJelJ)7O7Ak3Jc6lctg9Q8jxeY(KekOVimz8kvUiK9kq4Z5QAYC4CqtocQVIEVpOO38xhLFyg8O4TMKekOVimz0RYN8vzaMK0ou7FEOo)kmWuk9(jjQRwZqb9fHPmgQ9XmuNFfgyE4pyzWVpTBidHmkSEk)xhPqD1AgkOVimLXqTpMvuscf0xeMmxLXqTpkScHpNRQjd(9PDdLVkJHAFssuxTMj45RcMH68RWaZd)bld(9PDdziKrH1t5)6ifwHWNZv1K5W5GMCeKc1vRzcE(QGzOo)kmWiKrH1t5)6ifQRwZe88vbZkkjrD1AMXrqfCHZTHQyKYSIuGWNZv1KXY4)E(QCBOkgPssScHpNRQjZHZbn5iifQRwZe88vbZqD(v44jKrH1t5)6ionKNL4etSS9(0UHy5ASCflO3Q8Hf0pOVimHowUILnO2hwq)G(IWelWIfRbWS8(GIEmlWHLhYs0adSSb1(Wc6h0xeM408WFWcBCibyLrc(9PDdXPH8SehCT(3NfNMh(dwyJdjaRmsMvL9WFWkRp8JUY7iLBUw)7ZItJtd5zjomufJuSy5(DwqAmrI1wbonp8hSWgvO)kpocQGlCUnufJuO7AkRUAntWZxfmd15xHJxj0WPH8SeNyILyc6r)HGyzZIpDSyzNkw8NfnHXS87EXI1WsSHX06SGFpaeMfVaz5HSmuBi8ololatzaYc(9aqS4yw0(tS4ywIGy8PQjwGdl)1rSCplyil3ZIpZHGWSaGYc)S4TNgwCwIlGzb)EaiwiKfDdH508WFWcBuH(dyLrId6r)HGYyl(0HUqQGMYVpOOhRSsO7AkRUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaeWaKkuxTMr11EfOmSLDTo)7xHcN9j4fzWVhacyasf9Sce(gh0J(dbLXw8Pld6DokY8xaORqPWkp8hSmoOh9hckJT4txg07CuK5QCtFO2Ff9Sce(gh0J(dbLXw8PlVtU28xaORqLKacFJd6r)HGYyl(0L3jxBgQZVchFC7NKacFJd6r)HGYyl(0Lb9ohfzWVhacyXvbi8noOh9hckJT4txg07CuKzOo)kmWqJcq4BCqp6peugBXNUmO35OiZFbGUcvFonKNL4etSGuyHaceXIL73zbPXejwBfyXYovSebX4tvtS4filWFNglhMyXY97S4SeBymTolQRwJfl7uXciHtvHRqXP5H)Gf2Oc9hWkJKaSqabIY)oLXr3CpgDxtzRaN1bAkyoaIv0RhcFoxvtMaSqabIYGeovfuyvac1GqlLj45RcMHCWujjQRwZe88vbZkQVIEQRwZO6AVcug2YUwN)9RqHZL)RHm43daPmGmjrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiLbK9tsuHySI2HA)Zd15xHbMsP3Ntd5zjoarFwCml)oXs7g8ZcQailxXYVtS4SeBymTolwUceAHf4WIL73z53jwqoLAoVyrD1ASahwSC)ololasaJPalXe0J(dbXYMfF6yXlqwS43ZsdoSG0yIeRTcSCnwUNflW6zrLyzfXIJYVIfvQbhILFNyjaYYHzPD1H3jqonp8hSWgvO)awzK0wtQmSLj9Qi0DnL71RN6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqXdissuxTMr11EfOmSLDTo)7xHcN9j4fzWVhakEarFf9SkarqLxVbbv)EQjjXk1vRzghbvWfo3gQIrkZkQFFf9aN1bAkyoaItscqOgeAPmbpFvWmuNFfoE0KEssVaebvE9M6qT)5MtkcqOgeAPmbyHaceL)DkJJU5ESzOo)kC8Oj9(97NK0de(gh0J(dbLXw8Pld6DokYmuNFfoEaPIaeQbHwktWZxfmd15xHJxP0veGiOYR3uuyGA4a2pjrfIXkU6PjcQ9NaZTd1(NhQZVcdmaPcRcqOgeAPmbpFvWmKdMkjjarqLxVbOuZ5Lc1vRza6kWHaZuxe0cnDu9MvussaIGkVEdcQ(9uJc1vRzghbvWfo3gQIrkZqD(vyGbOuOUAnZ4iOcUW52qvmszwrCAipli1RaPzz79rdhqwSC)ololfzHLydJP1zrD1AS4filinMiXARalhUq7ZIRcxplpKfvILfMa508WFWcBuH(dyLrsWRaPZQRwdDL3rkJFF0WbeDxt5EQRwZO6AVcug2YUwN)9RqHZL)RHmd15xHJh4yqtsI6Q1mQU2RaLHTSR15F)ku4SpbViZqD(v44bog00xrVaeQbHwktWZxfmd15xHJh4KK0laHAqOLYqDrql0KvHfOzOo)kC8ahfwPUAndqxboeyM6IGwOPJQptfnOUyqMvKIaebvE9gGsnNx97RWX)46Ce0cnXRCCtNtd5zjoU6Iyz79bVgueMfl3VZIZsSHX06SOUAnwuxplf8zXYovSebH6RqXsdoSG0yIeRTcSahwqoDf4qGSSfDZ9yonp8hSWgvO)awzKGFFWRbfHURPCp1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGIhGjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43dafpa7ROxaIGkVEtDO2)CZPKKaeQbHwktWZxfmd15xHJh4KKyfcFoxvtMayoalW7pyPWQaebvE9gGsnNxjj9cqOgeAPmuxe0cnzvybAgQZVchpWrHvQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfPiarqLxVbOuZ5v)(k6zfi8nT1KkdBzsVkY8xaORqLKyvac1GqlLj45RcMHCWujjwfGqni0szcWcbeik)7ughDZ9yZqoyQ(CAiplXXvxelBVp41GIWSOsn4qSGuyHaceXP5H)Gf2Oc9hWkJe87dEnOi0DnL7fGqni0szcWcbeik)7ughDZ9yZqD(vyGHgfwboRd0uWCaeROhcFoxvtMaSqabIYGeovfsscqOgeAPmbpFvWmuNFfgyOPVce(CUQMmbWCawG3FWQVcRaHVPTMuzylt6vrM)caDfkfbicQ86n1HA)ZnNuyf4SoqtbZbqSckOVimzUk7vkfo(hxNJGwOjERjDonKNL4iSq7Zci8zbCnxHILFNyHkqwGnwaq4iOcUWSehgQIrk0Xc4AUcflaDf4qGSqDrql00r1ZcCy5kw(DIfTJFwqfazb2yXlwq)G(IWeNMh(dwyJk0FaRmsq4Z5QAcDL3rkdc)8qa31nuhvpgDiC9IuUN6Q1mJJGk4cNBdvXiLzOo)kC8OjjXk1vRzghbvWfo3gQIrkZkQVIEQRwZa0vGdbMPUiOfA6O6ZurdQlgKzOo)kmWqfanDoY6RON6Q1muqFrykJHAFmd15xHJhva005iljrD1AgkOVimL1RYhZqD(v44rfanDoY6ZP5H)Gf2Oc9hWkJe8QA3qOlKkOP87dk6XkRe6UMYd1gcV7QAsX7dk6n)1r5hMbpkELaek8OCyNcaPaHpNRQjdi8ZdbCx3qDu9yonp8hSWgvO)awzK0bHv7gcDHubnLFFqrpwzLq31uEO2q4DxvtkEFqrV5Vok)Wm4rXRuCnOrHhLd7uaifi85CvnzaHFEiG76gQJQhZP5H)Gf2Oc9hWkJe8tATp5M2hcDHubnLFFqrpwzLq31uEO2q4DxvtkEFqrV5Vok)Wm4rXReGaWd15xHv4r5WofasbcFoxvtgq4Nhc4UUH6O6XCAiplXbySybwSeazXY97W1ZsWJIUcfNMh(dwyJk0FaRmsAWjqzylx(VgcDxtzpkh2PaqCAiplOFxe0cnSeBybYILDQyXvHRNLhYcvpnS4SuKfwInmMwNflxbcTWIxGSGDeeln4WcsJjsS2kWP5H)Gf2Oc9hWkJeQlcAHMSkSar31uUhf0xeMm6v5tUiK9jjuqFryYGHAFYfHSpjHc6lctgVsLlczFsI6Q1mQU2RaLHTSR15F)ku4C5)AiZqD(v44bog0KKOUAnJQR9kqzyl7AD(3Vcfo7tWlYmuNFfoEGJbnjjo(hxNJGwOjEav6kcqOgeAPmbpFvWmKdMsHvGZ6anfmhaX9v0laHAqOLYe88vbZqD(v44JB6jjbiudcTuMGNVkygYbt1pjrfIXkU6PjcQ9NaZTd1(NhQZVcdmLsNtd5zjoarFwMd1(ZIk1GdXYcFfkwqAm508WFWcBuH(dyLrsBnPYWwM0RIq31uoaHAqOLYe88vbZqoykfi85CvnzcG5aSaV)GLIEo(hxNJGwOjEav6kSkarqLxVPou7FU5ussaIGkVEtDO2)CZjfo(hxNJGwObywt69vyvaIGkVEdcQ(9uJIEwfGiOYR3uhQ9p3CkjjaHAqOLYeGfciqu(3Pmo6M7XMHCWu9vyf4SoqtbZbqmNgYZcsJjsS2kWILDQyXFwauPdywIjgaYsp4OHwOHLF3lwSM0zjMyailwUFNfKcleqGO(Sy5(D46zrdXxHIL)6iwUILyRHqq9c)S4fil6RiwwrSy5(DwqkSqabIy5ASCplwCmlGeovfiqonp8hSWgvO)awzKGWNZv1e6kVJuoaMdWc8(dwzvO)OdHRxKYwboRd0uWCaeRaHpNRQjtamhGf49hSu0RNJ)X15iOfAIhqLUIEQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfLKyvaIGkVEdqPMZR(jjQRwZOQHqq9c)MvKc1vRzu1qiOEHFZqD(vyGPUAntWZxfmGRX)dw9tsU6PjcQ9NaZTd1(NhQZVcdm1vRzcE(QGbCn(FWkjjarqLxVPou7FU5uFf9SkarqLxVPou7FU5ussph)JRZrql0amRj9Keq4BARjvg2YKEvK5VaqxHQVIEi85CvnzcWcbeikds4uvijjaHAqOLYeGfciqu(3Pmo6M7XMHCWu97ZP5H)Gf2Oc9hWkJKaPj8FUo76dv1r1JURPmcFoxvtMayoalW7pyLvH(ZP5H)Gf2Oc9hWkJKRc(u(FWcDxtze(CUQMmbWCawG3FWkRc9Ntd5zb9X)15pHzzhAHLUvyNLyIbGS4dXck)kcKLiAybtbybYP5H)Gf2Oc9hWkJee(CUQMqx5DKYoocasZgfqhcxViLPG(IWK5QSEv(a8asKRh(dwg87t7gYqiJcRNY)1ra2kkOVimzUkRxLpaFpabGFxt1BWWLodB5FNYn4q43qLRQjqGpU9rUE4pyzSm(VBiKrH1t5)6iaNUbGixCeP15Dh)eNgYZsCC1fXY27dEnOimlw2PILFNyPDO2FwomlUkC9S8qwOceDS0gQIrkwomlUkC9S8qwOceDSKcUyXhIf)zbqLoGzjMyailxXIxSG(b9fHj0XcsJjsS2kWI2XpMfVG)onSaibmMcywGdlPGlwSaxAqwGiOj4rS0bhILF3lw4eLsNLyIbGSyzNkwsbxSybU0GfAFw2EFWRbfXsbTWP5H)Gf2Oc9hWkJe87dEnOi0DnL7PcXyfx90eb1(tG52HA)Zd15xHbM1KK0tD1AMXrqfCHZTHQyKYmuNFfgyOcGMohzaFGoDph)JRZrql0GCJB69vOUAnZ4iOcUW52qvmszwr97NK0ZX)46Ce0cnagHpNRQjJJJaG0SrbGxD1AgkOVimLXqTpMH68RWage(M2AsLHTmPxfz(laeopuNFfWdqdAIxjLspjXX)46Ce0cnagHpNRQjJJJaG0SrbGxD1AgkOVimL1RYhZqD(vyadcFtBnPYWwM0RIm)facNhQZVc4bObnXRKsP3xbf0xeMmxL9kLIEwPUAntWZxfmROKeRExt1BWVpA4aAOYv1eyFf96zvac1GqlLj45RcMvussaIGkVEdqPMZlfwfGqni0szOUiOfAYQWc0SI6NKeGiOYR3uhQ9p3CQVIEwfGiOYR3GGQFp1KKyL6Q1mbpFvWSIssC8pUohbTqt8aQ07NK07DnvVb)(OHdOHkxvtGkuxTMj45RcMvKIEQRwZGFF0Wb0GFpaeWIBsIJ)X15iOfAIhqLE)(jjQRwZe88vbZksHvQRwZmocQGlCUnufJuMvKcRExt1BWVpA4aAOYv1eiNgYZsCIjwaqcHfMLRyb9wLpSG(b9fHjw8cKfSJGyb5mUUb44WsRzbajewS0GdlinMiXARaNMh(dwyJk0FaRmskYsUdcl0DnL7PUAndf0xeMY6v5JzOo)kC8eYOW6P8FDussVWUpOiSYauXqHDFqr5)6iGHM(jjHDFqryLJBFfEuoStbG408WFWcBuH(dyLrYURB5oiSq31uUN6Q1muqFrykRxLpMH68RWXtiJcRNY)1rk6fGqni0szcE(QGzOo)kC8Oj9KKaeQbHwktawiGar5FNY4OBUhBgQZVchpAsVFssVWUpOiSYauXqHDFqr5)6iGHM(jjHDFqryLJBFfEuoStbG408WFWcBuH(dyLrsBP15oiSq31uUN6Q1muqFrykRxLpMH68RWXtiJcRNY)1rk6fGqni0szcE(QGzOo)kC8Oj9KKaeQbHwktawiGar5FNY4OBUhBgQZVchpAsVFssVWUpOiSYauXqHDFqr5)6iGHM(jjHDFqryLJBFfEuoStbG40qEwqoGOplWILaiNMh(dwyJk0FaRmsS4ZCWjdBzsVkItd5zjoXelBVpTBiwEilrdmWYgu7dlOFqFryIf4WILDQy5kwGLoflO3Q8Hf0pOVimXIxGSSWelihq0NLObgWSCnwUIf0Bv(Wc6h0xeM408WFWcBuH(dyLrc(9PDdHURPmf0xeMmxL1RYNKekOVimzWqTp5Iq2NKqb9fHjJxPYfHSpjrD1Agl(mhCYWwM0RImRifQRwZqb9fHPSEv(ywrjj9uxTMj45RcMH68RWaZd)blJLX)DdHmkSEk)xhPqD1AMGNVkywr9508WFWcBuH(dyLrILX)Donp8hSWgvO)awzKmRk7H)GvwF4hDL3rk3CT(3NfNgNgYZY27dEnOiwAWHLoicQJQNLvPjmMLf(kuSeBymToNMh(dwytZ16FFwkJFFWRbfHURPSvZQOgCqrgvx7vGYWw2168VFfkSHaURlkIa50qEwqQJFw(DIfq4ZIL73z53jw6G4NL)6iwEiloiilR6pnl)oXsNJmwaxJ)hSy5WSSFVHLTv1UHyzOo)kmlDl9Fr6Jaz5HS05FyNLoiSA3qSaUg)pyXP5H)Gf20CT(3NfGvgj4v1UHqxivqt53hu0Jvwj0DnLbHVPdcR2nKzOo)kC8d15xHbEacqKRsasonp8hSWMMR1)(SaSYiPdcR2neNgNgYZsCIjw2EFWRbfXYdzbiIIyzfXYVtSehhY7uVcKgwuxTglxJL7zXcCPbzHqw0nelQudoelTRo8(vOy53jwkczplbh)SahwEilGRUiwuPgCiwqkSqabI408WFWcBWVY43h8AqrO7AkpRIAWbfz(RJSaNkdoK3PEfink6rb9fHjZvzVsPWQE9uxTM5VoYcCQm4qEN6vG0ygQZVchVh(dwglJ)7gczuy9u(VocWPBusrpkOVimzUkRc)9KekOVimzUkJHAFssOG(IWKrVkFYfHSVFsI6Q1m)1rwGtLbhY7uVcKgZqD(v449WFWYGFFA3qgczuy9u(VocWPBusrpkOVimzUkRxLpjjuqFryYGHAFYfHSpjHc6lctgVsLlczF)(jjwPUAnZFDKf4uzWH8o1RaPXSI6NK0tD1AMGNVkywrjji85CvnzcWcbeikds4uvOVIaeQbHwktawiGar5FNY4OBUhBgYbtPiarqLxVPou7FU5uFf9SkarqLxVbOuZ5vssac1GqlLH6IGwOjRclqZqD(v44bK9v0tD1AMGNVkywrjjwfGqni0szcE(QGzihmvFonKNL4etSetqp6peelBw8PJfl7uXYVtdXYHzPGS4H)qqSGT4th6yXXSO9NyXXSebX4tvtSalwWw8PJfl3VZcazboS0il0Wc(9aqywGdlWIfNL4cywWw8PJfmKLF3Fw(DILISWc2IpDS4ZCiimlaOSWplE7PHLF3FwWw8PJfczr3qyonp8hSWg8dyLrId6r)HGYyl(0HUqQGMYVpOOhRSsO7AkBfi8noOh9hckJT4txg07CuK5VaqxHsHvE4pyzCqp6peugBXNUmO35OiZv5M(qT)k6zfi8noOh9hckJT4txENCT5VaqxHkjbe(gh0J(dbLXw8PlVtU2muNFfoE00pjbe(gh0J(dbLXw8Pld6DokYGFpaeWIRcq4BCqp6peugBXNUmO35OiZqD(vyGfxfGW34GE0FiOm2IpDzqVZrrM)caDfkonKNL4etywqkSqabIy5ASG0yIeRTcSCywwrSahwsbxS4dXciHtvHRqXcsJjsS2kWIL73zbPWcbeiIfVazjfCXIpelQKgAHfRjDwIjgaYP5H)Gf2GFaRmscWcbeik)7ughDZ9y0DnLTcCwhOPG5aiwrVEi85CvnzcWcbeikds4uvqHvbiudcTuMGNVkygYbtPWQzvudoOit0CDWb8CD2NGxxihT0yFssuxTMj45RcMvuFfo(hxNJGwObywt6k6PUAndf0xeMY6v5JzOo)kC8kLEsI6Q1muqFrykJHAFmd15xHJxP07NKOcXyfTd1(NhQZVcdmLsxHvbiudcTuMGNVkygYbt1Ntd5zbPWc8(dwS0GdlUwZci8XS87(ZsNdeHzbVgILFNsXIpuH2NLHAdH3jqwSStflaiCeubxywIddvXifl7oMfnHXS87EXcAybtbmld15xDfkwGdl)oXcqPMZlwuxTglhMfxfUEwEilnxRzb2ASahw8kflOFqFryILdZIRcxplpKfczr3qCAE4pyHn4hWkJee(CUQMqx5DKYGWppeWDDd1r1JrhcxViL7PUAnZ4iOcUW52qvmszgQZVchpAssSsD1AMXrqfCHZTHQyKYSI6RWk1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SIu0tD1AgGUcCiWm1fbTqthvFMkAqDXGmd15xHbgQaOPZrwFf9uxTMHc6lctzmu7JzOo)kC8OcGMohzjjQRwZqb9fHPSEv(ygQZVchpQaOPZrwsspRuxTMHc6lctz9Q8XSIssSsD1AgkOVimLXqTpMvuFfw9UMQ3GHA8FbYqLRQjW(CAiplifwG3FWILF3Fwc7uaimlxJLuWfl(qSaxp(ajwOG(IWelpKfyPtXci8z53PHyboSCOk4qS87hMfl3VZYguJ)lqCAE4pyHn4hWkJee(CUQMqx5DKYGWpdxp(aPmf0xeMqhcxViL7zL6Q1muqFrykJHAFmRifwPUAndf0xeMY6v5Jzf1pj5DnvVbd14)cKHkxvtGCAE4pyHn4hWkJKoiSA3qOlKkOP87dk6XkRe6UMYd1gcV7QAsrp1vRzOG(IWugd1(ygQZVch)qD(v4Ke1vRzOG(IWuwVkFmd15xHJFOo)kCsccFoxvtgq4NHRhFGuMc6lct9vmuBi8URQjfVpOO38xhLFyg8O4vcGk8OCyNcaPaHpNRQjdi8ZdbCx3qDu9yonp8hSWg8dyLrcEvTBi0fsf0u(9bf9yLvcDxt5HAdH3DvnPON6Q1muqFrykJHAFmd15xHJFOo)kCsI6Q1muqFrykRxLpMH68RWXpuNFfojbHpNRQjdi8ZW1Jpqktb9fHP(kgQneE3v1KI3hu0B(RJYpmdEu8kbqfEuoStbGuGWNZv1Kbe(5HaURBOoQEmNMh(dwyd(bSYib)Kw7tUP9Hqxivqt53hu0Jvwj0DnLhQneE3v1KIEQRwZqb9fHPmgQ9XmuNFfo(H68RWjjQRwZqb9fHPSEv(ygQZVch)qD(v4Kee(CUQMmGWpdxp(aPmf0xeM6RyO2q4DxvtkEFqrV5Vok)Wm4rXReGqHhLd7uaifi85CvnzaHFEiG76gQJQhZPH8SeNyIL4amwSalwcGSy5(D46zj4rrxHItZd)blSb)awzK0GtGYWwU8Fne6UMYEuoStbG40qEwItmXcYPRahcKLTOBUhZIL73zXRuSOHfkwOcUqTZI2X)vOyb9d6lctS4fil)KILhYI(kIL7zzfXIL73zbaU0yFyXlqwqAmrI1wbonp8hSWg8dyLrc1fbTqtwfwGO7Ak3RN6Q1muqFrykJHAFmd15xHJxP0tsuxTMHc6lctz9Q8XmuNFfoELsVVIaeQbHwktWZxfmd15xHJpUPRON6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lcya0AspjXQzvudoOit0CDWb8CD2NGxxihT0yFmeWDDrrey)(jjQRwZenxhCapxN9j41fYrln2hdcxVO4vgGaN0tscqOgeAPmbpFvWmKdMsHJ)X15iOfAIhqLoNgYZsCIjwqAmrI1wbwSC)olifwiGarib50vGdbYYw0n3JzXlqwaHfAFwGiOXYCpXcaCPX(WcCyXYovSeBnecQx4NflWLgKfczr3qSOsn4qSG0yIeRTcSqil6gcZP5H)Gf2GFaRmsq4Z5QAcDL3rkhaZbybE)bRm(rhcxViLTcCwhOPG5aiwbcFoxvtMayoalW7pyPOxVaeQbHwkd1fLAixNHdy5vGmd15xHbMsacGdG7PKsa)SkQbhuKbFvBPZ7PWpnN3xbbCxxuebAOUOud56mCalVcu)Keh)JRZrql0eVYaQ0v0ZQ31u9M2AsLHTmPxfzOYv1eysI6Q1mbpFvWaUg)pyfFac1GqlLPTMuzylt6vrMH68RWagq2xbcFoxvtMFFoToJjciAYw87v0tD1AgGUcCiWm1fbTqthvFMkAqDXGmROKeRcqeu51Bak1CE1xX7dk6n)1r5hMbpkE1vRzcE(QGbCn(FWc4t3aCssuHySI2HA)Zd15xHbM6Q1mbpFvWaUg)pyLKeGiOYR3uhQ9p3CkjrD1AgvnecQx43SIuOUAnJQgcb1l8BgQZVcdm1vRzcE(QGbCn(FWcW9aua)SkQbhuKjAUo4aEUo7tWRlKJwASpgc4UUOicSFFfwPUAntWZxfmRif9SkarqLxVPou7FU5ussac1GqlLjaleqGO8VtzC0n3JnROKevigRODO2)8qD(vyGfGqni0szcWcbeik)7ughDZ9yZqD(vyadissAhQ9ppuNFfg5ICvcqMoWuxTMj45RcgW14)bR(CAiplXjMy53jwaqLQFp1WIL73zXzbPXejwBfy539NLdxO9zPnWowaGln2honp8hSWg8dyLrY4iOcUW52qvmsHURPS6Q1mbpFvWmuNFfoELqtsI6Q1mbpFvWaUg)pybS4MUce(CUQMmbWCawG3FWkJFonp8hSWg8dyLrsG0e(pxND9HQ6O6r31ugHpNRQjtamhGf49hSY4xrpRuxTMj45RcgW14)bR4JB6jjwfGiOYR3GGQFp10pjrD1AMXrqfCHZTHQyKYSIuOUAnZ4iOcUW52qvmszgQZVcdmafGdWcCDVjAOWHPSRpuvhvV5VokJW1lcW9SsD1AgvnecQx43SIuy17AQEd(9rdhqdvUQMa7ZP5H)Gf2GFaRmsUk4t5)bl0DnLr4Z5QAYeaZbybE)bRm(50qEwaq1NZv1ellmbYcSyXvp99hHz539NflE9S8qwujwWoccKLgCybPXejwBfybdz539NLFNsXIpu9SyXXpbYcakl8ZIk1GdXYVtDCAE4pyHn4hWkJee(CUQMqx5DKYyhbLBWjh88vb0HW1lszRcqOgeAPmbpFvWmKdMkjXke(CUQMmbyHaceLbjCQkOiarqLxVPou7FU5usc4SoqtbZbqmNgYZsCIjmlXbi6ZY1y5kw8If0pOVimXIxGS8ZrywEil6RiwUNLvelwUFNfa4sJ9bDSG0yIeRTcS4filXe0J(dbXYMfF6408WFWcBWpGvgjT1KkdBzsVkcDxtzkOVimzUk7vkfEuoStbGuOUAnt0CDWb8CD2NGxxihT0yFmiC9IagaTM0v0de(gh0J(dbLXw8Pld6DokY8xaORqLKyvaIGkVEtrHbQHdyFfi85CvnzWock3Gto45Rck6PUAnZ4iOcUW52qvmszgQZVcdmafaUhAa(zvudoOid(Q2sN3tHFAoVVc1vRzghbvWfo3gQIrkZkkjXk1vRzghbvWfo3gQIrkZkQpNgYZsCIjwaqx0VZY27tZ1AwIgyaZY1yz79P5AnlhUq7ZYkItZd)blSb)awzKGFFAUwJURPS6Q1mWI(DCoIMaf9hSmRifQRwZGFFAUwBgQneE3v1eNMh(dwyd(bSYij4vG0z1vRHUY7iLXVpA4aIURPS6Q1m43hnCand15xHbgAu0tD1AgkOVimLXqTpMH68RWXJMKe1vRzOG(IWuwVkFmd15xHJhn9v44FCDocAHM4buPZPH8SehxDrywIjgaYIk1GdXcsHfciqell8vOy53jwqkSqabIyjalW7pyXYdzjStbGy5ASGuyHaceXYHzXd)Y16uS4QW1ZYdzrLyj44NtZd)blSb)awzKGFFWRbfHURPCaIGkVEtDO2)CZjfi85CvnzcWcbeikds4uvqrac1GqlLjaleqGO8VtzC0n3Jnd15xHbgAuyf4SoqtbZbqmNgYZsCIjw2EFAUwZIL73zz7jT2hwIJZ1Ew8cKLcYY27JgoGOJfl7uXsbzz79P5AnlhMLve6yjfCXIpelxXc6TkFyb9d6lctS0GdlasaJPaMf4WYdzjAGbwaGln2hwSStflUkebXcGkDwIjgaYcCyXbJ8)qqSGT4thl7oMfajGXuaZYqD(vxHIf4WYHz5kwA6d1(ByjwWNy539NLvbsdl)oXc27iwcWc8(dwywUhTywaJWSu06hxZYdzz79P5AnlGR5kuSaGWrqfCHzjomufJuOJfl7uXsk4cTGSG)tRzHkqwwrSy5(DwauPdyhhXsdoS87elAh)SGsdvDn2WP5H)Gf2GFaRmsWVpnxRr31u(DnvVb)Kw7tgCU2BOYv1eOcRExt1BWVpA4aAOYv1eOc1vRzWVpnxRnd1gcV7QAsrp1vRzOG(IWuwVkFmd15xHJhqQGc6lctMRY6v5Jc1vRzIMRdoGNRZ(e86c5OLg7JbHRxeWaiAspjrD1AMO56Gd456SpbVUqoAPX(yq46ffVYaenPRWX)46Ce0cnXdOspjbe(gh0J(dbLXw8Pld6DokYmuNFfoEazsIh(dwgh0J(dbLXw8Pld6DokYCvUPpu7FFfbiudcTuMGNVkygQZVchVsPZPH8SeNyILT3h8AqrSaGUOFNLObgWS4filGRUiwIjgaYILDQybPXejwBfyboS87elaOs1VNAyrD1ASCywCv46z5HS0CTMfyRXcCyjfCHwqwcEelXeda508WFWcBWpGvgj43h8AqrO7AkRUAndSOFhNdAYNmIdFWYSIssuxTMbORahcmtDrql00r1NPIguxmiZkkjrD1AMGNVkywrk6PUAnZ4iOcUW52qvmszgQZVcdmubqtNJmGpqNUNJ)X15iOfAqUXn9(aoUa)7AQEtrwYDqyzOYv1eOcRMvrn4GIm4RAlDEpf(P5CfQRwZmocQGlCUnufJuMvusI6Q1mbpFvWmuNFfgyOcGMohzaFGoDph)JRZrql0GCJB69tsuxTMzCeubx4CBOkgPY4RAlDEpf(P5CZkkjXk1vRzghbvWfo3gQIrkZksHvbiudcTuMXrqfCHZTHQyKYmKdMkjXQaebvE9geu97PM(jjo(hxNJGwOjEav6kOG(IWK5QSxP40qEwS(KILhYsNdeXYVtSOs4NfyJLT3hnCazrnfl43daDfkwUNLvela31fasNILRyXRuSG(b9fHjwuxplaWLg7dlhUEwCv46z5HSOsSenWqGa508WFWcBWpGvgj43h8AqrO7Ak)UMQ3GFF0Wb0qLRQjqfwnRIAWbfz(RJSaNkdoK3PEfink6PUAnd(9rdhqZkkjXX)46Ce0cnXdOsVVc1vRzWVpA4aAWVhacyXvrp1vRzOG(IWugd1(ywrjjQRwZqb9fHPSEv(ywr9vOUAnt0CDWb8CD2NGxxihT0yFmiC9IagaboPROxac1GqlLj45RcMH68RWXRu6jjwHWNZv1KjaleqGOmiHtvbfbicQ86n1HA)ZnN6ZPH8SG(4)68NWSSdTWs3kSZsmXaqw8HybLFfbYsenSGPaSa508WFWcBWpGvgji85CvnHUY7iLDCeaKMnkGoeUErktb9fHjZvz9Q8b4bKixp8hSm43N2nKHqgfwpL)RJaSvuqFryYCvwVkFa(Eaca)UMQ3GHlDg2Y)oLBWHWVHkxvtGaFC7JC9WFWYyz8F3qiJcRNY)1raoDJ1GgKloI068UJFcWPBqdW)UMQ3u(VgcNvDTxbYqLRQjqonKNL44QlILT3h8AqrSCflolahaJPalBqTpSG(b9fHj0XciSq7ZIMEwUNLObgybaU0yFyP3V7plhMLDVa1eilQPyHUFNgw(DILT3NMR1SOVIyboS87elXedaJhqLol6RiwAWHLT3h8Aqr9rhlGWcTplqe0yzUNyXlwaqx0VZs0adS4filA6z53jwCvicIf9vel7EbQjw2EF0WbKtZd)blSb)awzKGFFWRbfHURPSvZQOgCqrM)6ilWPYGd5DQxbsJIEQRwZenxhCapxN9j41fYrln2hdcxViGbqGt6jjQRwZenxhCapxN9j41fYrln2hdcxViGbq0KUI31u9g8tATpzW5AVHkxvtG9v0Jc6lctMRYyO2hfo(hxNJGwObWi85CvnzCCeaKMnka8QRwZqb9fHPmgQ9XmuNFfgWGW30wtQmSLj9QiZFbGW5H68RaEaAqt8aY0tsOG(IWK5QSEv(OWX)46Ce0cnagHpNRQjJJJaG0SrbGxD1AgkOVimL1RYhZqD(vyadcFtBnPYWwM0RIm)facNhQZVc4bObnXdOsVVcRuxTMbw0VJZr0eOO)GLzfPWQ31u9g87JgoGgQCvnbQOxac1GqlLj45RcMH68RWXdCssWWLw9kqZVpNwNXebengQCvnbQqD1AMFFoToJjciAm43dabS4gxaCVzvudoOid(Q2sN3tHFAoh4rtFfTd1(NhQZVchVsPNUI2HA)Zd15xHbgatp9(k6fGqni0sza6kWHaZ4OBUhBgQZVchpWjjXQaebvE9gGsnNx950qEwItmXcasiSWSCflO3Q8Hf0pOVimXIxGSGDeeliNX1nahhwAnlaiHWILgCybPXejwBfyXlqwqoDf4qGSG(Drql00r1ZP5H)Gf2GFaRmskYsUdcl0DnL7PUAndf0xeMY6v5JzOo)kC8eYOW6P8FDussVWUpOiSYauXqHDFqr5)6iGHM(jjHDFqryLJBFfEuoStbGuGWNZv1Kb7iOCdo5GNVkWP5H)Gf2GFaRms2DDl3bHf6UMY9uxTMHc6lctz9Q8XmuNFfoEczuy9u(VosHvbicQ86naLAoVss6PUAndqxboeyM6IGwOPJQptfnOUyqMvKIaebvE9gGsnNx9ts6f29bfHvgGkgkS7dkk)xhbm00pjjS7dkcRCCtsuxTMj45RcMvuFfEuoStbGuGWNZv1Kb7iOCdo5GNVkOON6Q1mJJGk4cNBdvXiLzOo)kmW6Hgamab(zvudoOid(Q2sN3tHFAoVVc1vRzghbvWfo3gQIrkZkkjXk1vRzghbvWfo3gQIrkZkQpNMh(dwyd(bSYiPT06ChewO7Ak3tD1AgkOVimL1RYhZqD(v44jKrH1t5)6ifwfGiOYR3auQ58kjPN6Q1maDf4qGzQlcAHMoQ(mv0G6Ibzwrkcqeu51Bak1CE1pjPxy3huewzaQyOWUpOO8FDeWqt)KKWUpOiSYXnjrD1AMGNVkywr9v4r5WofasbcFoxvtgSJGYn4KdE(QGIEQRwZmocQGlCUnufJuMH68RWadnkuxTMzCeubx4CBOkgPmRifwnRIAWbfzWx1w68Ek8tZ5jjwPUAnZ4iOcUW52qvmszwr950qEwItmXcYbe9zbwSea508WFWcBWpGvgjw8zo4KHTmPxfXPH8SeNyILT3N2nelpKLObgyzdQ9Hf0pOVimHowqAmrI1wbw2DmlAcJz5VoILF3lwCwqog)3zHqgfwpXIMAplWHfyPtXc6TkFyb9d6lctSCywwrCAE4pyHn4hWkJe87t7gcDxtzkOVimzUkRxLpjjuqFryYGHAFYfHSpjHc6lctgVsLlczFssp1vRzS4ZCWjdBzsVkYSIssWrKwN3D8talDJ1GgfwfGiOYR3GGQFp1KKGJiToV74Naw6gRrraIGkVEdcQ(9utFfQRwZqb9fHPSEv(ywrjj9uxTMj45RcMH68RWaZd)blJLX)DdHmkSEk)xhPqD1AMGNVkywr950qEwItmXcYX4)olWFNglhMyXY(f2z5WSCflBqTpSG(b9fHj0XcsJjsS2kWcCy5HSenWalO3Q8Hf0pOVimXP5H)Gf2GFaRmsSm(VZPH8SehCT(3NfNMh(dwyd(bSYizwv2d)bRS(Wp6kVJuU5A9Vpl73(TTb]] )


end