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


    spec:RegisterPack( "Balance", 20210629.4, [[deLyzfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlaO2fL(feXWKqDmsulda9mjqtJIkUgKITbq03ai14ai5CaewhGkMhGY9ir2Ne0)GOIshuOWcfk1dHinrjaDriv1gLa4Jqur1iHOIItsrLwPeYlHOImtiv5Maq0ofk6NaqQHcaAPaq4PkLPsrvxvcOTcaj9viQWyba2lf(RKgmXHPAXK0JfmzGUmYMLYNHKrRuDAvTAaiXRbKztQBlr7w0VbnCHCCavA5kEoutxLRRKTdHVtrgpeLZluTEHsMVuz)O2qzdZBSb6hzetawmavUyajabewLb0fRS5ain2U4rKXwKhaYrrgBPxsgBX21EgiJTipUg6GgM3yddxtGm22VlcdCqcsuDTNbcaJ)YGf1F7lv7drsSDTNbcaV9LifjLG29RuJC22RjLuDTNbYEi7m2uxV(m30q1yd0pYiMaSyaQCXasaciSkdOlwzZbGgB(62HJX22xIuJT9heKsdvJnqchm2ITR9mqSuaN1dYfv0kjwaiGaTSaWIbOYCrCriD3tueg4WfbGzjgGGeilBqTpSeBYlTCraywq6UNOiqwoFqrx9BSeCmHz5GSeIh0u98bfDylxeaMfaeujebbYYktkqySpXzbHpVRQjml9ElzrllrdHOIpFWRbfXcaUqwIgcHfF(GxdkQVLlcaZsmqaFqwIgk447tuSGCm(TZY3y5p0Hz52jwmnWeflOFq)ryYYfbGzbaPdeXcsHjciqel3oXYw0p)HzXzr)3PjwkHdXstti7v1el9(glXHlw2DWeDhl7)XYFSG)YL(8KGlSoolM(BNLydGogMNfaZcsjnHV31Sed9JklP8qll)HoqwWa9r9TCraywaq6arSucXhlOR9O2V6qL(Ny0XcoqPppeZIhfPJZYbzrfIXS0Eu7hMfyQJB5I4IIrMWZpcKLy7ApdelXaaIESe8KfvILgCLGS4hl73fHboibjQU2ZabGXFzWI6V9LQ9Hij2U2ZabG3(sKIKsq7(vQroB71KsQU2ZazpKDgB6hFydZBSbsnFPpdZBetLnmVXMhUhMgByO2NQk5LgBu6QAc0i2gNrmbOH5n2O0v1eOrSn2GrgBy6m28W9W0ydHpVRQjJneUErgB4isRRNpOOdBXNpnxRzPqwuMffS0JfZy5CnLNfF(OHdOLsxvtGS01XY5Akpl(iT2Nk48TZsPRQjqw6Zsxhl4isRRNpOOdBXNpnxRzPqwaOXgiHdZhDpmn22OdZsmGOplWKLccywm93oCDSaoF7yXtqwm93olBNpA4aYINGSaqaZc82PX0JjJne(utVKm2EC1HKXzeZcAyEJnkDvnbAeBJnyKXgMoJnpCpmn2q4Z7QAYydHRxKXgoI0665dk6Ww85t7hILczrzJnqchMp6EyASTrhMLGMCeelM2PKLTZN2pelbpzz)pwaiGz58bfDywmT)HDwEmldPjeEES0Gdl3oXc6h0FeMy5GSOsSenuJMHazXtqwmT)HDwAVwtdlhKLGJpJne(utVKm2ECnOjhbzCgX0CmmVXgLUQManITXMhUhMgBQ0GPbOprzSbs4W8r3dtJTcetSeBAW0a0NOyX0F7SG0yGeZndSahw82rdlifMiGarS8jlingiXCZGXwy(JM3n26XIzSeGiO0ZZMpQ9R2CILUowmJLaeQbHMsBaMiGar1BNQ4OF(dBxrS0NffSOUAnBWRFgSdv6FIzPqwugnSOGf1vRzhhbLWfU2gkJvC7qL(NywaglMdlkyXmwcqeu65zrq5ThFyPRJLaebLEEweuE7XhwuWI6Q1SbV(zWUIyrblQRwZoockHlCTnugR42velkyPhlQRwZoockHlCTnugR42Hk9pXSamwuwzwaWSGgwaEwMvsn4GIS4pBlDDpo(O5DlLUQMazPRJf1vRzdE9ZGDOs)tmlaJfLvMLUowuMfKWcoI066UJpIfGXIYw0Ggw6BCgXengM3yJsxvtGgX2ylm)rZ7gBQRwZg86Nb7qL(NywkKfLrdlkyPhlMXYSsQbhuKf)zBPR7XXhnVBP0v1eilDDSOUAn74iOeUW12qzSIBhQ0)eZcWyrzanlkyrD1A2XrqjCHRTHYyf3UIyPplDDSOcXywuWs7rTF1Hk9pXSamwaiAm2ajCy(O7HPXgaeESy6VDwCwqAmqI5MbwUD)y5Xj6owCwaGln2hwIgyGf4WIPDkz52jwApQ9JLhZIRcxhlhKfkbn28W9W0ylcEpmnoJycinmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYylqVMLES0JL2JA)Qdv6FIzbaZIYOHfamlbiudcnL2Gx)myhQ0)eZsFwqclkdOkML(SOelb61S0JLES0Eu7xDOs)tmlaywugnSaGzrzawmlaywcqOgeAkTbyIacevVDQIJ(5pSDOs)tml9zbjSOmGQyw6ZIcwmJLXFWkHGYZ6GGylHShFyw66yjaHAqOP0g86Nb7qL(NywkKLppAIGA)iWA7rTF1Hk9pXS01Xsac1GqtPnateqGO6TtvC0p)HTdv6FIzPqw(8OjcQ9JaRTh1(vhQ0)eZcaMfLlMLUowmJLaebLEE28rTF1MtS01XIhUhM2amrabIQ3ovXr)8h2c(yxvtGgBGeomF09W0ydPUoS0(rywmTt3onSSWFIIfKcteqGiwsOjwm9AnlUwdnXsC4ILdYc(ETMLGJpwUDIfSxsS4LWvESaBSGuyIacebyKgdKyUzGLGJpSXgcFQPxsgBbyIacevbjC8myCgXeqByEJnkDvnbAeBJnyKXgMoJnpCpmn2q4Z7QAYydHRxKXwpwoFqrN9(sQEWk4tSuilkJgw66yz8hSsiO8Soii2(jlfYcAkML(SOGLES0JLESygleWD9rreOLkJIpKRRWbm9mqS01Xspw6Xsac1GqtPLkJIpKRRWbm9mq2Hk9pXSamwugqwmlDDSeGiO0ZZIGYBp(WIcwcqOgeAkTuzu8HCDfoGPNbYouP)jMfGXIYasanlaMLESOSYSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFw6ZIcwmJLaeQbHMslvgfFixxHdy6zGSd5GXzPpl9zrbl9yXmwiG76JIiqlgU0A6UprvNLACw66yXmwcqeu65zZh1(vBoXsxhlbiudcnLwmCP10DFIQol142Hk9pXSamwuwzZHL(SOGLESygleWD9rreO9tCywNRQPkWD55TkRGeIpqS01Xsac1GqtP9tCywNRQPkWD55TkRGeIpq2HCW4S0NffS0JLaeQbHMsRknyAa6tu2HCW4S01XIzSmEGS3a1Aw6Zsxhl9yPhli85DvnzHzDHP6nFceDSOelkZsxhli85DvnzHzDHP6nFceDSOelfKL(SOGLESCZNarN9u2oKdgVgGqni0uYsxhl38jq0zpLTbiudcnL2Hk9pXSuilFE0eb1(rG12JA)Qdv6FIzbaZIYfZsFw66ybHpVRQjlmRlmvV5tGOJfLybGSOGLESCZNarN9aODihmEnaHAqOPKLUowU5tGOZEa0gGqni0uAhQ0)eZsHS85rteu7hbwBpQ9RouP)jMfamlkxml9zPRJfe(8UQMSWSUWu9MpbIowuILIzPpl9zPRJLaebLEEwGIpVNS03ydKWH5JUhMgBfiMaz5GSasApol3oXYc7OiwGnwqAmqI5MbwmTtjll8NOybeUu1elWKLfMyXtqwIgcbLhllSJIyX0oLS4jloiileckpwEmlUkCDSCqwaFYydHp10ljJTaynatW)EyACgXeqzyEJnkDvnbAeBJnyKXgMoJnpCpmn2q4Z7QAYydHRxKXMzSGHlT6NG2BFETUIjciASu6QAcKLUowApQ9RouP)jMLczbGfxmlDDSOcXywuWs7rTF1Hk9pXSamwaiAybWS0JfZPywaWSOUAn7TpVwxXebenw85bGyb4zbGS0NLUowuxTM92NxRRyIaIgl(8aqSuilfeqXcaMLESmRKAWbfzXF2w66EC8rZ7wkDvnbYcWZcAyPVXgcFQPxsgB3(8ADfteq0un5)zCgXeqyyEJnkDvnbAeBJnqchMp6EyASvGyIf0Vmk(qUMfa0dy6zGybGfJPaMfvQbhIfNfKgdKyUzGLfMSgBPxsgBuzu8HCDfoGPNbYylm)rZ7gBbiudcnL2Gx)myhQ0)eZcWybGfZIcwcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlaJfawmlkyPhli85DvnzV9516kMiGOPAY)JLUowuxTM92NxRRyIaIgl(8aqSuilfSywaml9yzwj1GdkYI)ST01944JM3Tu6QAcKfGNfajl9zPplDDSOcXywuWs7rTF1Hk9pXSamwkiG2yZd3dtJnQmk(qUUchW0ZazCgXu5InmVXgLUQManITXgiHdZhDpmn2kqmXYgCP109jkwaqSuJZcGetbmlQudoelolingiXCZallmzn2sVKm2WWLwt39jQ6SuJBSfM)O5DJTaeQbHMsBWRFgSdv6FIzbySaizrblMXsaIGspplckV94dlkyXmwcqeu65zZh1(vBoXsxhlbick98S5JA)QnNyrblbiudcnL2amrabIQ3ovXr)8h2ouP)jMfGXcGKffS0Jfe(8UQMSbyIacevbjC8mWsxhlbiudcnL2Gx)myhQ0)eZcWybqYsFw66yjarqPNNfbL3E8HffS0JfZyzwj1GdkYI)ST01944JM3Tu6QAcKffSeGqni0uAdE9ZGDOs)tmlaJfajlDDSOUAn74iOeUW12qzSIBhQ0)eZcWyrzZHfaZspwqdlapleWD9rreO9t8nRWbhCf8r8jvvjTML(SOGf1vRzhhbLWfU2gkJvC7kIL(S01XIkeJzrblTh1(vhQ0)eZcWybGOXyZd3dtJnmCP10DFIQol14gNrmvwzdZBSrPRQjqJyBS5H7HPX2N4WSoxvtvG7YZBvwbjeFGm2cZF08UXM6Q1SbV(zWouP)jMLczrz0WIcw6XIzSmRKAWbfzXF2w66EC8rZ7wkDvnbYsxhlQRwZoockHlCTnugR42Hk9pXSamwugGSayw6Xsbzb4zrD1AwvnecQx4ZUIyPplaMLES0JfanlaywqdlaplQRwZQQHqq9cF2vel9zb4zHaURpkIaTFIVzfo4GRGpIpPQkP1S0NffSOUAn74iOeUW12qzSIBxrS0NLUowuHymlkyP9O2V6qL(NywaglaengBPxsgBFIdZ6CvnvbUlpVvzfKq8bY4mIPYa0W8gBu6QAc0i2gBGeomF09W0yZ87pMLhZIZY43onSqAxfo(rSyYJZYbzP0bIyX1AwGjllmXc(8JLB(ei6WSCqwujw0FsGSSIyX0F7SG0yGeZndS4jilifMiGarS4jillmXYTtSaWeKfSgESatwcGS8nwuH3ol38jq0HzXhIfyYYctSGp)y5MpbIoSXwy(JM3n2q4Z7QAYcZ6ct1B(ei6yrjwailkyXmwU5tGOZEa0oKdgVgGqni0uYsxhl9ybHpVRQjlmRlmvV5tGOJfLyrzw66ybHpVRQjlmRlmvV5tGOJfLyPGS0NffS0Jf1vRzdE9ZGDfXIcw6XIzSeGiO0ZZIGYBp(WsxhlQRwZoockHlCTnugR42Hk9pXSayw6XcAyb4zzwj1GdkYI)ST01944JM3Tu6QAcKL(SamLy5MpbIo7PSvD1AvW143dtwuWI6Q1SJJGs4cxBdLXkUDfXsxhlQRwZoockHlCTnugR4v8NTLUUhhF08UDfXsFw66yjaHAqOP0g86Nb7qL(NywamlaKLcz5MpbIo7PSnaHAqOP0cUg)EyYIcw6XIzSeGiO0ZZMpQ9R2CILUowmJfe(8UQMSbyIacevbjC8mWsFwuWIzSeGiO0ZZcu859KLUowcqeu65zZh1(vBoXIcwq4Z7QAYgGjciqufKWXZalkyjaHAqOP0gGjciqu92Pko6N)W2velkyXmwcqOgeAkTbV(zWUIyrbl9yPhlQRwZsb9hHPQEL(yhQ0)eZsHSOCXS01XI6Q1Suq)ryQIHAFSdv6FIzPqwuUyw6ZIcwmJLzLudoOiRQR9mqvyR6AD92)ef2sPRQjqw66yPhlQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaXIsSGgw66yrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwuIfafl9zPplDDSOUAnlqFcoeyLkJGMOPKYRsjnO(yr2vel9zPRJfvigZIcwApQ9RouP)jMfGXcalMLUowq4Z7QAYcZ6ct1B(ei6yrjwk2ydRHh2y7MpbIoLn28W9W0yBHP6Fuj24mIPYf0W8gBu6QAc0i2gBE4EyASTWu9pQeBSfM)O5DJne(8UQMSWSUWu9MpbIowmtjwailkyXmwU5tGOZEkBhYbJxdqOgeAkzPRJfe(8UQMSWSUWu9MpbIowuIfaYIcw6XI6Q1SbV(zWUIyrbl9yXmwcqeu65zrq5ThFyPRJf1vRzhhbLWfU2gkJvC7qL(Nywaml9ybnSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFwaMsSCZNarN9aOvD1AvW143dtwuWI6Q1SJJGs4cxBdLXkUDfXsxhlQRwZoockHlCTnugR4v8NTLUUhhF08UDfXsFw66yjaHAqOP0g86Nb7qL(NywamlaKLcz5MpbIo7bqBac1GqtPfCn(9WKffS0JfZyjarqPNNnFu7xT5elDDSygli85DvnzdWebeiQcs44zGL(SOGfZyjarqPNNfO4Z7jlkyPhlMXI6Q1SbV(zWUIyPRJfZyjarqPNNfbL3E8HL(S01XsaIGsppB(O2VAZjwuWccFExvt2amrabIQGeoEgyrblbiudcnL2amrabIQ3ovXr)8h2UIyrblMXsac1GqtPn41pd2velkyPhl9yrD1AwkO)imv1R0h7qL(NywkKfLlMLUowuxTMLc6pctvmu7JDOs)tmlfYIYfZsFwuWIzSmRKAWbfzvDTNbQcBvxRR3(NOWwkDvnbYsxhl9yrD1Awvx7zGQWw1166T)jkCn9BnKfFEaiwuIf0WsxhlQRwZQ6Apduf2QUwxV9prHR(e8KS4ZdaXIsSaOyPpl9zPplDDSOUAnlqFcoeyLkJGMOPKYRsjnO(yr2velDDSOcXywuWs7rTF1Hk9pXSamwayXS01XccFExvtwywxyQEZNarhlkXsXgByn8WgB38jq0bqJZiMkBogM3yJsxvtGgX2ydKWH5JUhMgBfiMWS4AnlWBNgwGjllmXYFujMfyYsa0yZd3dtJTfMQ)rLyJZiMkJgdZBSrPRQjqJyBSbs4W8r3dtJTcifEqIfpCpmzr)4JfvhtGSatwW)T87Hjs0eQhBS5H7HPX2SYQhUhMv9JpJn8nF4mIPYgBH5pAE3ydHpVRQj7JRoKm20p(QPxsgBoKmoJyQmG0W8gBu6QAc0i2gBH5pAE3yBwj1GdkYQ6Apduf2QUwxV9prHTeWD9rreOXg(MpCgXuzJnpCpmn2Mvw9W9WSQF8zSPF8vtVKm2uH(zCgXuzaTH5n2O0v1eOrSn28W9W0yBwz1d3dZQ(XNXM(Xxn9sYydFgNXzSPc9ZW8gXuzdZBSrPRQjqJyBS5H7HPX24iOeUW12qzSIBSbs4W8r3dtJTcWqzSIZIP)2zbPXajMBgm2cZF08UXM6Q1SbV(zWouP)jMLczrz0yCgXeGgM3yJsxvtGgX2yZd3dtJnh0JUhbvXM8P0ylepOP65dk6WgXuzJTW8hnVBSPUAnRQR9mqvyR6AD92)efUM(TgYIppaelaJfaflkyrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwaglakwuWspwmJfq4zDqp6EeufBYNYkOx6Oi79bG(eflkyXmw8W9W06GE09iOk2KpLvqV0rr2pRn9JA)yrbl9yXmwaHN1b9O7rqvSjFkR7KRT3ha6tuS01Xci8SoOhDpcQIn5tzDNCTDOs)tmlfYsbzPplDDSacpRd6r3JGQyt(uwb9shfzXNhaIfGXsbzrblGWZ6GE09iOk2KpLvqV0rr2Hk9pXSamwqdlkybeEwh0JUhbvXM8PSc6LokYEFaOprXsFJnqchMp6EyASvGyILya6r3JGyzZKpLSyANsw8JfnHXSC7EYI5WsSHXW8SGppaeMfpbz5GSmuBi8ololatjaYc(8aqS4yw0(rS4ywIGy8RQjwGdl3xsS8hlyil)XIpZJGWSaGYcFS4TJgwCwkiGzbFEaiwiKf9dHnoJywqdZBSrPRQjqJyBS5H7HPXwaMiGar1BNQ4OF(dBSbs4W8r3dtJTcetSGuyIaceXIP)2zbPXajMBgyX0oLSebX4xvtS4jilWBNgtpMyX0F7S4SeBymmplQRwJft7uYciHJNHprzSfM)O5DJnZybCwpOnH1aiMffS0JLESGWN3v1KnateqGOkiHJNbwuWIzSeGqni0uAdE9ZGDihmolDDSOUAnBWRFgSRiw6ZIcw6XI6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqSOelakw66yrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwuIfafl9zPRJfvigZIcwApQ9RouP)jMfGXIYfZsFJZiMMJH5n2O0v1eOrSn28W9W0yRTM4vyRs6vsgBGeomF09W0yRaarFwCml3oXs7h8XcQailFYYTtS4SeBymmplM(eeAIf4WIP)2z52jwqofFEpzrD1ASahwm93ololakaJPalXa0JUhbXYMjFkzXtqwm5)XsdoSG0yGeZndS8nw(JftW8yrLyzfXIJY)KfvQbhILBNyjaYYJzP95J3jqJTW8hnVBS1JLES0Jf1vRzvDTNbQcBvxRR3(NOW10V1qw85bGyPqwaKS01XI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuilasw6ZIcw6XIzSeGiO0ZZIGYBp(WsxhlMXI6Q1SJJGs4cxBdLXkUDfXsFw6ZIcw6Xc4SEqBcRbqmlDDSeGqni0uAdE9ZGDOs)tmlfYcAkMLUow6XsaIGsppB(O2VAZjwuWsac1GqtPnateqGO6TtvC0p)HTdv6FIzPqwqtXS0NL(S0NLUow6Xci8SoOhDpcQIn5tzf0lDuKDOs)tmlfYcGIffSeGqni0uAdE9ZGDOs)tmlfYIYfZIcwcqeu65ztkmqnCazPplDDSOcXywuWYNhnrqTFeyT9O2V6qL(NywaglakwuWIzSeGqni0uAdE9ZGDihmolDDSeGiO0ZZcu859KffSOUAnlqFcoeyLkJGMOPKYZUIyPRJLaebLEEweuE7XhwuWI6Q1SJJGs4cxBdLXkUDOs)tmlaJfablkyrD1A2XrqjCHRTHYyf3UImoJyIgdZBSrPRQjqJyBS5H7HPXwWZaPRQRwZylm)rZ7gB9yrD1Awvx7zGQWw1166T)jkCn9BnKDOs)tmlfYcG2Igw66yrD1Awvx7zGQWw1166T)jkC1NGNKDOs)tmlfYcG2Igw6ZIcw6Xsac1GqtPn41pd2Hk9pXSuilaAw66yPhlbiudcnLwQmcAIMQkmbTdv6FIzPqwa0SOGfZyrD1AwG(eCiWkvgbnrtjLxLsAq9XISRiwuWsaIGspplqXN3tw6ZsFwuWIJVX11iOjAyPqLyPGfBSPUATA6LKXg(8rdhqJnqchMp6EyASHupdKMLTZhnCazX0F7S4SKKjwInmgMNf1vRXINGSG0yGeZndS84eDhlUkCDSCqwujwwyc04mIjG0W8gBu6QAc0i2gBE4EyASHpFWRbfzSbs4W8r3dtJTc4QmILTZh8Aqrywm93ololXggdZZI6Q1yrDDSKWJft7uYseeQ)efln4WcsJbsm3mWcCyb50NGdbYYw0p)Hn2cZF08UXwpwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaILczbGS01XI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuilaKL(SOGLESeGiO0ZZMpQ9R2CILUowcqOgeAkTbV(zWouP)jMLczbqZsxhlMXccFExvt2aynatW)EyYIcwmJLaebLEEwGIpVNS01XspwcqOgeAkTuze0envvycAhQ0)eZsHSaOzrblMXI6Q1Sa9j4qGvQmcAIMskVkL0G6JfzxrSOGLaebLEEwGIpVNS0NL(SOGLESyglGWZ2wt8kSvj9kj79bG(eflDDSyglbiudcnL2Gx)myhYbJZsxhlMXsac1GqtPnateqGO6TtvC0p)HTd5GXzPVXzetaTH5n2O0v1eOrSn28W9W0ydF(GxdkYydKWH5JUhMgBfWvzelBNp41GIWSOsn4qSGuyIacezSfM)O5DJTESeGqni0uAdWebeiQE7ufh9ZFy7qL(NywaglOHffSyglGZ6bTjSgaXSOGLESGWN3v1KnateqGOkiHJNbw66yjaHAqOP0g86Nb7qL(NywaglOHL(SOGfe(8UQMSbWAaMG)9WKL(SOGfZybeE22AIxHTkPxjzVpa0NOyrblbick98S5JA)QnNyrblMXc4SEqBcRbqmlkyHc6pct2pREgNffS44BCDncAIgwkKfZPyJZiMakdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im26XI6Q1SJJGs4cxBdLXkUDOs)tmlfYcAyPRJfZyrD1A2XrqjCHRTHYyf3UIyPplkyPhlQRwZc0NGdbwPYiOjAkP8QusdQpwKDOs)tmlaJfubqBPJmw6ZIcw6XI6Q1Suq)ryQIHAFSdv6FIzPqwqfaTLoYyPRJf1vRzPG(JWuvVsFSdv6FIzPqwqfaTLoYyPVXgiHdZhDpmn2kGWeDhlGWJfW18jkwUDIfkbzb2ybaHJGs4cZsbyOmwXrllGR5tuSa0NGdbYcvgbnrtjLhlWHLpz52jw0o(ybvaKfyJfpzb9d6pctgBi8PMEjzSbcV6qa31pujLh24mIjGWW8gBu6QAc0i2gBE4EyASHxz7hYylm)rZ7gBd1gcV7QAIffSC(GIo79Lu9GvWNyPqwugqYIcw8OAyNcaXIcwq4Z7QAYccV6qa31pujLh2ylepOP65dk6WgXuzJZiMkxSH5n2O0v1eOrSn28W9W0yRecZ2pKXwy(JM3n2gQneE3v1elky58bfD27lP6bRGpXsHSOCbTOHffS4r1WofaIffSGWN3v1KfeE1HaURFOskpSXwiEqt1Zhu0HnIPYgNrmvwzdZBSrPRQjqJyBS5H7HPXg(iT2NAt7dzSfM)O5DJTHAdH3DvnXIcwoFqrN9(sQEWk4tSuilkdizbWSmuP)jMffS4r1WofaIffSGWN3v1KfeE1HaURFOskpSXwiEqt1Zhu0HnIPYgNrmvgGgM3yJsxvtGgX2yZd3dtJTgCcuf2QPFRHm2ajCy(O7HPXwbagtwGjlbqwm93oCDSe8OOprzSfM)O5DJnpQg2PaqgNrmvUGgM3yJsxvtGgX2yZd3dtJnQmcAIMQkmbn2ajCy(O7HPXg6xgbnrdlXgMGSyANswCv46y5GSq5rdloljzILydJH5zX0NGqtS4jilyhbXsdoSG0yGeZndgBH5pAE3yRhluq)ryYQxPp1Kq2Xsxhluq)ryYIHAFQjHSJLUowOG(JWK1Z41Kq2XsxhlQRwZQ6Apduf2QUwxV9prHRPFRHSdv6FIzPqwa0w0WsxhlQRwZQ6Apduf2QUwxV9prHR(e8KSdv6FIzPqwa0w0Wsxhlo(gxxJGMOHLczbqumlkyjaHAqOP0g86Nb7qoyCwuWIzSaoRh0MWAaeZsFwuWspwcqOgeAkTbV(zWouP)jMLczPGfZsxhlbiudcnL2Gx)myhYbJZsFw66yrfIXSOGLppAIGA)iWA7rTF1Hk9pXSamwuUyJZiMkBogM3yJsxvtGgX2yZd3dtJT2AIxHTkPxjzSbs4W8r3dtJTcae9zzEu7hlQudoell8NOybPXWylm)rZ7gBbiudcnL2Gx)myhYbJZIcwq4Z7QAYgaRbyc(3dtwuWspwC8nUUgbnrdlfYcGOywuWIzSeGiO0ZZMpQ9R2CILUowcqeu65zZh1(vBoXIcwC8nUUgbnrdlaJfZPyw6ZIcwmJLaebLEEweuE7XhwuWspwmJLaebLEE28rTF1MtS01Xsac1GqtPnateqGO6TtvC0p)HTd5GXzPplkyXmwaN1dAtynaInoJyQmAmmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYyZmwaN1dAtynaIzrbli85DvnzdG1amb)7HjlkyPhl9yXX346Ae0enSuilaIIzrbl9yrD1AwG(eCiWkvgbnrtjLxLsAq9XISRiw66yXmwcqeu65zbk(8EYsFw66yrD1AwvnecQx4ZUIyrblQRwZQQHqq9cF2Hk9pXSamwuxTMn41pdwW143dtw6ZsxhlFE0eb1(rG12JA)Qdv6FIzbySOUAnBWRFgSGRXVhMS01XsaIGsppB(O2VAZjw6ZIcw6XIzSeGiO0ZZMpQ9R2CILUow6XIJVX11iOjAybySyofZsxhlGWZ2wt8kSvj9kj79bG(efl9zrbl9ybHpVRQjBaMiGarvqchpdS01Xsac1GqtPnateqGO6TtvC0p)HTd5GXzPpl9n2ajCy(O7HPXgsJbsm3mWIPDkzXpwaefdywIbgaYsp4OHMOHLB3twmNIzjgyailM(BNfKcteqGO(Sy6VD46yrdXFIIL7ljw(KLyRHqq9cFS4jil6pjwwrSy6VDwqkmrabIy5BS8hlMCmlGeoEgiqJne(utVKm2cG1amb)7Hzvf6NXzetLbKgM3yJsxvtGgX2ylm)rZ7gBi85DvnzdG1amb)7Hzvf6NXMhUhMgBbst47DD11pQSKYZ4mIPYaAdZBSrPRQjqJyBSfM)O5DJne(8UQMSbWAaMG)9WSQc9ZyZd3dtJTpd(K(9W04mIPYakdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2OG(JWK9ZQEL(WcWZcGIfKWIhUhMw85t7hYsiJcRJQ3xsSaywmJfkO)imz)SQxPpSa8S0JfajlaMLZ1uEwmCPRWw92PAdoe(Su6QAcKfGNLcYsFwqclE4EyAnn(TBjKrH1r17ljwamlfBbiliHfCeP11DhFKXgiHdZhDpmn2qF89L(ryw2HMyPCf2zjgyail(qSGY)KazjIgwWuaMGgBi8PMEjzS54iainBuW4mIPYacdZBSrPRQjqJyBS5H7HPXg(8bVguKXgiHdZhDpmn2kGRYiw2oFWRbfHzX0oLSC7elTh1(XYJzXvHRJLdYcLGOLL2qzSIZYJzXvHRJLdYcLGOLL4Wfl(qS4hlaIIbmlXadaz5tw8Kf0pO)imHwwqAmqI5Mbw0o(WS4j82PHfafGXuaZcCyjoCXIj4sdYcebnbpILs4qSC7EYc3PCXSedmaKft7uYsC4IftWLgmr3XY25dEnOiwsOjJTW8hnVBS1JfvigZIcw(8OjcQ9JaRTh1(vhQ0)eZcWyXCyPRJLESOUAn74iOeUW12qzSIBhQ0)eZcWybva0w6iJfGNLa9Aw6XIJVX11iOjAybjSuWIzPplkyrD1A2XrqjCHRTHYyf3UIyPpl9zPRJLES44BCDncAIgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQIHAFSdv6FIzbWSacpBBnXRWwL0RKS3hacxhQ0)KfGNfaArdlfYIYkxmlDDS44BCDncAIgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQQxPp2Hk9pXSaywaHNTTM4vyRs6vs27daHRdv6FYcWZcaTOHLczrzLlML(SOGfkO)imz)S6zCwuWspwmJf1vRzdE9ZGDfXsxhlMXY5Akpl(8rdhqlLUQMazPplkyPhl9yXmwcqOgeAkTbV(zWUIyPRJLaebLEEwGIpVNSOGfZyjaHAqOP0sLrqt0uvHjODfXsFw66yjarqPNNnFu7xT5el9zrbl9yXmwcqeu65zrq5ThFyPRJfZyrD1A2Gx)myxrS01XIJVX11iOjAyPqwaefZsFw66yPhlNRP8S4ZhnCaTu6QAcKffSOUAnBWRFgSRiwuWspwuxTMfF(OHdOfFEaiwaglfKLUowC8nUUgbnrdlfYcGOyw6ZsFw66yrD1A2Gx)myxrSOGfZyrD1A2XrqjCHRTHYyf3UIyrblMXY5Akpl(8rdhqlLUQManoJycWInmVXgLUQManITXMhUhMgBjzQwcHPXgiHdZhDpmn2kqmXcasimXS8jlO3k9Hf0pO)imXINGSGDeeliNX1naxawAnlaiHWKLgCybPXajMBgm2cZF08UXwpwuxTMLc6pctv9k9XouP)jMLczHqgfwhvVVKyPRJLESe29bfHzrjwailkyzOWUpOO69LelaJf0WsFw66yjS7dkcZIsSuqw6ZIcw8OAyNcazCgXeGkByEJnkDvnbAeBJTW8hnVBS1Jf1vRzPG(JWuvVsFSdv6FIzPqwiKrH1r17ljwuWspwcqOgeAkTbV(zWouP)jMLczbnfZsxhlbiudcnL2amrabIQ3ovXr)8h2ouP)jMLczbnfZsFw66yPhlHDFqrywuIfaYIcwgkS7dkQEFjXcWybnS0NLUowc7(GIWSOelfKL(SOGfpQg2PaqgBE4EyAST76wTectJZiMaeGgM3yJsxvtGgX2ylm)rZ7gB9yrD1AwkO)imv1R0h7qL(NywkKfczuyDu9(sIffS0JLaeQbHMsBWRFgSdv6FIzPqwqtXS01Xsac1GqtPnateqGO6TtvC0p)HTdv6FIzPqwqtXS0NLUow6Xsy3hueMfLybGSOGLHc7(GIQ3xsSamwqdl9zPRJLWUpOimlkXsbzPplkyXJQHDkaKXMhUhMgBTLwxlHW04mIjalOH5n2O0v1eOrSn2ajCy(O7HPXgYbe9zbMSean28W9W0yZKpZdNkSvj9kjJZiMa0CmmVXgLUQManITXMhUhMgB4ZN2pKXgiHdZhDpmn2kqmXY25t7hILdYs0adSSb1(Wc6h0FeMyboSyANsw(KfyQJZc6TsFyb9d6pctS4jillmXcYbe9zjAGbmlFJLpzb9wPpSG(b9hHjJTW8hnVBSrb9hHj7Nv9k9HLUowOG(JWKfd1(utczhlDDSqb9hHjRNXRjHSJLUowuxTM1KpZdNkSvj9kj7kIffSOUAnlf0FeMQ6v6JDfXsxhl9yrD1A2Gx)myhQ0)eZcWyXd3dtRPXVDlHmkSoQEFjXIcwuxTMn41pd2vel9noJycq0yyEJnpCpmn2mn(TBSrPRQjqJyBCgXeGasdZBSrPRQjqJyBS5H7HPX2SYQhUhMv9JpJn9JVA6LKXwZ16BFwgNXzS5qYW8gXuzdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im26XI6Q1S3xsMGtwbhYlv)eKg7qL(NywaglOcG2shzSaywk2QmlDDSOUAn79LKj4KvWH8s1pbPXouP)jMfGXIhUhMw85t7hYsiJcRJQ3xsSaywk2QmlkyPhluq)ryY(zvVsFyPRJfkO)imzXqTp1Kq2Xsxhluq)ryY6z8Asi7yPpl9zrblQRwZEFjzcozfCiVu9tqASRiwuWYSsQbhuK9(sYeCYk4qEP6NG0yP0v1eOXgiHdZhDpmn2qQRdlTFeMft70Ttdl3oXsbCiVm4xyNgwuxTglMETMLMR1SaBnwm93(NSC7eljHSJLGJpJne(utVKm2ahYlRMETU2CTUcBnJZiMa0W8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnZyHc6pct2pRyO2hwuWspwWrKwxpFqrh2IpFA)qSuilOHffSCUMYZIHlDf2Q3ovBWHWNLsxvtGS01XcoI0665dk6Ww85t7hILczbqZsFJnqchMp6EyASHuxhwA)imlM2PBNgw2oFWRbfXYJzXeCUDwco((eflqe0WY25t7hILpzb9wPpSG(b9hHjJne(utVKm2EujCOk(8bVguKXzeZcAyEJnkDvnbAeBJnpCpmn2cWebeiQE7ufh9ZFyJnqchMp6EyASvGyIfKcteqGiwmTtjl(XIMWywUDpzbnfZsmWaqw8eKf9NelRiwm93olingiXCZGXwy(JM3n2mJfWz9G2ewdGywuWspw6XccFExvt2amrabIQGeoEgyrblMXsac1GqtPn41pd2HCW4S01XI6Q1SbV(zWUIyPplkyPhlQRwZsb9hHPQEL(yhQ0)eZsHSaizPRJf1vRzPG(JWufd1(yhQ0)eZsHSaizPplkyPhlMXYSsQbhuKv11EgOkSvDTUE7FIcBP0v1eilDDSOUAnRQR9mqvyR6AD92)efUM(TgYIppaelfYsbzPRJf1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGyPqwkil9zPRJfvigZIcwApQ9RouP)jMfGXIYfZIcwmJLaeQbHMsBWRFgSd5GXzPVXzetZXW8gBu6QAc0i2gBE4EyASnockHlCTnugR4gBGeomF09W0yRaXelfGHYyfNft)TZcsJbsm3mySfM)O5DJn1vRzdE9ZGDOs)tmlfYIYOX4mIjAmmVXgLUQManITXMhUhMgB4v2(Hm2cXdAQE(GIoSrmv2ylm)rZ7gB9yzO2q4DxvtS01XI6Q1Suq)ryQIHAFSdv6FIzbySuqwuWcf0FeMSFwXqTpSOGLHk9pXSamwu2CyrblNRP8Sy4sxHT6Tt1gCi8zP0v1eil9zrblNpOOZEFjvpyf8jwkKfLnhwaWSGJiTUE(GIomlaMLHk9pXSOGLESqb9hHj7NvpJZsxhldv6FIzbySGkaAlDKXsFJnqchMp6EyASvGyILTv2(Hy5twI8eKk)alWKfpJF7FIILB3pw0pccZIYMdMcyw8eKfnHXSy6VDwkHdXY5dk6WS4jil(XYTtSqjilWglolBqTpSG(b9hHjw8JfLnhwWuaZcCyrtymldv6F(jkwCmlhKLeESS7i(eflhKLHAdH3zbCnFIIf0BL(Wc6h0FeMmoJycinmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yd5errSSIyz78P5Anl(XIR1SCFjHzzLAcJzzH)eflOx8GpoMfpbz5pwEmlUkCDSCqwIgyGf4WIMowUDIfCefExZIhUhMSO)KyrL0qtSS7jOMyPaoKxQ(jinSatwailNpOOdBSfM)O5DJnZy5CnLNfFKw7tfC(2zP0v1eilkyPhlQRwZIpFAUwBhQneE3v1elkyPhl4isRRNpOOdBXNpnxRzbySuqw66yXmwMvsn4GIS3xsMGtwbhYlv)eKglLUQMazPplDDSCUMYZIHlDf2Q3ovBWHWNLsxvtGSOGf1vRzPG(JWufd1(yhQ0)eZcWyPGSOGfkO)imz)SIHAFyrblQRwZIpFAUwBhQ0)eZcWybqZIcwWrKwxpFqrh2IpFAUwZsHkXI5WsFwuWspwmJLzLudoOiRoEWhhxBAIUprvrP)YimzP0v1eilDDSCFjXcYLfZbnSuilQRwZIpFAUwBhQ0)eZcGzbGS0NffSC(GIo79Lu9GvWNyPqwqJXzetaTH5n2O0v1eOrSn28W9W0ydF(0CT2ydKWH5JUhMgBih)TZY2rATpSuaNVDSSWelWKLailM2PKLHAdH3DvnXI66ybFVwZIj)pwAWHf0lEWhhZs0adS4jilGWeDhllmXIk1GdXcslGyllB3R1SSWelQudoelifMiGarSG)mqSC7(XIPxRzjAGbw8eE70WY25tZ1AJTW8hnVBSDUMYZIpsR9PcoF7Su6QAcKffSOUAnl(8P5ATDO2q4DxvtSOGLESyglZkPgCqrwD8GpoU20eDFIQIs)LryYsPRQjqw66y5(sIfKllMdAyPqwmhw6ZIcwoFqrN9(sQEWk4tSuilf04mIjGYW8gBu6QAc0i2gBE4EyASHpFAUwBSbs4W8r3dtJnKJ)2zPaoKxQ(jinSSWelBNpnxRz5GSaerrSSIy52jwuxTglQXzX1yill8NOyz78P5AnlWKf0WcMcWeeZcCyrtymldv6F(jkJTW8hnVBSnRKAWbfzVVKmbNScoKxQ(jinwkDvnbYIcwWrKwxpFqrh2IpFAUwZsHkXsbzrbl9yXmwuxTM9(sYeCYk4qEP6NG0yxrSOGf1vRzXNpnxRTd1gcV7QAILUow6XccFExvtwWH8YQPxRRnxRRWwJffS0Jf1vRzXNpnxRTdv6FIzbySuqw66ybhrAD98bfDyl(8P5AnlfYcazrblNRP8S4J0AFQGZ3olLUQMazrblQRwZIpFAUwBhQ0)eZcWybnS0NL(S034mIjGWW8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnhFJRRrqt0WsHSaOkMfaml9yr5Izb4zrD1A27ljtWjRGd5LQFcsJfFEaiw6ZcaMLESOUAnl(8P5ATDOs)tmlaplfKfKWcoI066UJpIfGNfZy5CnLNfFKw7tfC(2zP0v1eil9zbaZspwcqOgeAkT4ZNMR12Hk9pXSa8Suqwqcl4isRR7o(iwaEwoxt5zXhP1(ubNVDwkDvnbYsFwaWS0Jfq4zBRjEf2QKELKDOs)tmlaplOHL(SOGLESOUAnl(8P5ATDfXsxhlbiudcnLw85tZ1A7qL(Nyw6BSbs4W8r3dtJnK66Ws7hHzX0oD70WIZY25dEnOiwwyIftVwZsWxyILTZNMR1SCqwAUwZcS1qllEcYYctSSD(GxdkILdYcqefXsbCiVu9tqAybFEaiwwrgBi8PMEjzSHpFAUwxnbZR2CTUcBnJZiMkxSH5n2O0v1eOrSn28W9W0ydF(GxdkYydKWH5JUhMgBfiMyz78bVguelM(BNLc4qEP6NG0WYbzbiIIyzfXYTtSOUAnwm93oCDSOH4prXY25tZ1Awwr3xsS4jillmXY25dEnOiwGjlMdGzj2WyyEwWNhacZYkVxZI5WY5dk6WgBH5pAE3ydHpVRQjl4qEz10R11MR1vyRXIcwq4Z7QAYIpFAUwxnbZR2CTUcBnwuWIzSGWN3v1K9rLWHQ4Zh8AqrS01XspwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaILczPGS01XI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSuilfKL(SOGfCeP11Zhu0HT4ZNMR1SamwmhwuWccFExvtw85tZ16QjyE1MR1vyRzCgXuzLnmVXgLUQManITXMhUhMgBoOhDpcQIn5tPXwiEqt1Zhu0HnIPYgBH5pAE3yZmwUpa0NOyrblMXIhUhMwh0JUhbvXM8PSc6LokY(zTPFu7hlDDSacpRd6r3JGQyt(uwb9shfzXNhaIfGXsbzrblGWZ6GE09iOk2KpLvqV0rr2Hk9pXSamwkOXgiHdZhDpmn2kqmXc2KpLSGHSC7(XsC4Ifu0XsPJmwwr3xsSOgNLf(tuS8hloMfTFeloMLiig)QAIfyYIMWywUDpzPGSGppaeMf4Wcakl8XIPDkzPGaMf85bGWSqil6hY4mIPYa0W8gBu6QAc0i2gBE4EyASvcHz7hYylepOP65dk6WgXuzJTW8hnVBSnuBi8URQjwuWY5dk6S3xs1dwbFILczPhl9yrzZHfaZspwWrKwxpFqrh2IpFA)qSa8SaqwaEwuxTMLc6pctv9k9XUIyPpl9zbWSmuP)jML(SGew6XIYSaywoxt5zptFwlHWeBP0v1eil9zrbl9yjaHAqOP0g86Nb7qoyCwuWIzSaoRh0MWAaeZIcw6XccFExvt2amrabIQGeoEgyPRJLaeQbHMsBaMiGar1BNQ4OF(dBhYbJZsxhlMXsaIGsppB(O2VAZjw6Zsxhl4isRRNpOOdBXNpTFiwagl9yPhlaswaWS0Jf1vRzPG(JWuvVsFSRiwaEwail9zPplapl9yrzwamlNRP8SNPpRLqyITu6QAcKL(S0NffSygluq)ryYIHAFQjHSJLUow6Xcf0FeMSFwXqTpS01XspwOG(JWK9ZQk82zPRJfkO)imz)SQxPpS0NffSyglNRP8Sy4sxHT6Tt1gCi8zP0v1eilDDSOUAnB08LWb8DD1NGNFOgT0yFSiC9IyPqLybGOPyw6ZIcw6XcoI0665dk6Ww85t7hIfGXIYfZcWZspwuMfaZY5Akp7z6ZAjeMylLUQMazPpl9zrblo(gxxJGMOHLczbnfZcaMf1vRzXNpnxRTdv6FIzb4zbqYsFwuWspwmJf1vRzb6tWHaRuze0enLuEvkPb1hlYUIyPRJfkO)imz)SIHAFyPRJfZyjarqPNNfO4Z7jl9zrblMXI6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrgBGeomF09W0ydab1gcVZcasimB)qS8nwqAmqI5MbwEmld5GXrll3onel(qSOjmMLB3twqdlNpOOdZYNSGER0hwq)G(JWelM(BNLn4vaqllAcJz529KfLlMf4TtJPhtS8jlEgNf0pO)imXcCyzfXYbzbnSC(GIomlQudoelolO3k9Hf0pO)imzzPact0DSmuBi8olGR5tuSGC6tWHazb9lJGMOPKYJLvQjmMLpzzdQ9Hf0pO)imzCgXu5cAyEJnkDvnbAeBJnpCpmn2AWjqvyRM(TgYydKWH5JUhMgBfiMyPaaJjlWKLailM(BhUowcEu0NOm2cZF08UXMhvd7uaiJZiMkBogM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSzglGZ6bTjSgaXSOGfe(8UQMSbWAaMG)9WKffS0JLESOUAnl(8P5ATDfXsxhl9y5CnLNfFKw7tfC(2zP0v1eilDDSeGiO0ZZMpQ9R2CIL(S0NffS0JfZyrD1AwmuJVpq2velkyXmwuxTMn41pd2velkyPhlMXY5AkpBBnXRWwL0RKSu6QAcKLUowuxTMn41pdwW143dtwkKLaeQbHMsBBnXRWwL0RKSdv6FIzbWSaOyPplkybHpVRQj7TpVwxXebenvt(FSOGLESyglbick98S5JA)QnNyPRJLaeQbHMsBaMiGar1BNQ4OF(dBxrSOGLESOUAnl(8P5ATDOs)tmlaJfaYsxhlMXY5Akpl(iT2Nk48TZsPRQjqw6ZsFwuWY5dk6S3xs1dwbFILczrD1A2Gx)mybxJFpmzb4zPylGML(S01XIkeJzrblTh1(vhQ0)eZcWyrD1A2Gx)mybxJFpmzPVXgcFQPxsgBbWAaMG)9WS6qY4mIPYOXW8gBu6QAc0i2gBE4EyASfinHV31vx)OYskpJnqchMp6EyASvGyIfKgdKyUzGfyYsaKLvQjmMfpbzr)jXYFSSIyX0F7SGuyIacezSfM)O5DJne(8UQMSbWAaMG)9WS6qY4mIPYasdZBSrPRQjqJyBSfM)O5DJne(8UQMSbWAaMG)9WS6qYyZd3dtJTpd(K(9W04mIPYaAdZBSrPRQjqJyBS5H7HPXgvgbnrtvfMGgBGeomF09W0yRaXelOFze0enSeBycYcmzjaYIP)2zz78P5AnlRiw8eKfSJGyPbhwaGln2hw8eKfKgdKyUzWylm)rZ7gBQqmMffS85rteu7hbwBpQ9RouP)jMfGXIYOHLUow6XI6Q1SrZxchW31vFcE(HA0sJ9XIW1lIfGXcartXS01XI6Q1SrZxchW31vFcE(HA0sJ9XIW1lILcvIfaIMIzPplkyrD1Aw85tZ1A7kIffS0JLaeQbHMsBWRFgSdv6FIzPqwqtXS01Xc4SEqBcRbqml9noJyQmGYW8gBu6QAc0i2gBE4EyASHpsR9P20(qgBH4bnvpFqrh2iMkBSfM)O5DJTHAdH3DvnXIcwUVKQhSc(elfYIYOHffSGJiTUE(GIoSfF(0(HybySyoSOGfpQg2PaqSOGLESOUAnBWRFgSdv6FIzPqwuUyw66yXmwuxTMn41pd2vel9n2ajCy(O7HPXgacQneENLM2hIfyYYkILdYsbz58bfDywm93oCDSG0yGeZndSOsFIIfxfUowoileYI(HyXtqws4Xcebnbpk6tugNrmvgqyyEJnkDvnbAeBJnpCpmn2ARjEf2QKELKXgiHdZhDpmn2kqmXsbaI(S8nw(e)GelEYc6h0FeMyXtqw0FsS8hlRiwm93ololaWLg7dlrdmWINGSedqp6EeelBM8P0ylm)rZ7gBuq)ryY(z1Z4SOGfpQg2PaqSOGf1vRzJMVeoGVRR(e88d1OLg7JfHRxelaJfaIMIzrbl9ybeEwh0JUhbvXM8PSc6LokYEFaOprXsxhlMXsaIGsppBsHbQHdilDDSGJiTUE(GIomlfYcazPplkyPhlQRwZoockHlCTnugR42Hk9pXSamwaeSaGzPhlOHfGNLzLudoOil(Z2sx3JJpAE3sPRQjqw6ZIcwuxTMDCeucx4ABOmwXTRiw66yXmwuxTMDCeucx4ABOmwXTRiw6ZIcw6XIzSeGqni0uAdE9ZGDfXsxhlQRwZE7ZR1vmrarJfFEaiwaglkJgwuWs7rTF1Hk9pXSamwayXfZIcwApQ9RouP)jMLczr5IlMLUowmJfmCPv)e028Z11M2nzP0v1eil9noJycWInmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yRaXelolBNpnxRzbaDs3olrdmWYk1egZY25tZ1AwEmlUEihmolRiwGdlXHlw8HyXvHRJLdYcebnbpILyGbGgBH5pAE3ytD1Awys3oUgrtGIUhM2velkyPhlQRwZIpFAUwBhQneE3v1elDDS44BCDncAIgwkKfarXS034mIjav2W8gBu6QAc0i2gBE4EyASHpFAUwBSbs4W8r3dtJTc4QmILyGbGSOsn4qSGuyIaceXIP)2zz78P5AnlEcYYTtjlBNp41GIm2cZF08UXwaIGsppB(O2VAZjwuWIzSCUMYZIpsR9PcoF7Su6QAcKffS0Jfe(8UQMSbyIacevbjC8mWsxhlbiudcnL2Gx)myxrS01XI6Q1SbV(zWUIyPplkyjaHAqOP0gGjciqu92Pko6N)W2Hk9pXSamwqfaTLoYyb4zjqVMLES44BCDncAIgwqclOPyw6ZIcwuxTMfF(0CT2ouP)jMfGXI5WIcwmJfWz9G2ewdGyJZiMaeGgM3yJsxvtGgX2ylm)rZ7gBbick98S5JA)QnNyrbl9ybHpVRQjBaMiGarvqchpdS01Xsac1GqtPn41pd2velDDSOUAnBWRFgSRiw6ZIcwcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlaJfajlkyrD1Aw85tZ1A7kIffSqb9hHj7NvpJZIcwmJfe(8UQMSpQeoufF(GxdkIffSyglGZ6bTjSgaXgBE4EyASHpFWRbfzCgXeGf0W8gBu6QAc0i2gBE4EyASHpFWRbfzSbs4W8r3dtJTcetSSD(GxdkIft)TZINSaGoPBNLObgyboS8nwIdxOdKficAcEelXadazX0F7SehUgwsczhlbhFwwIHgdzbCvgXsmWaqw8JLBNyHsqwGnwUDIfauP82JpSOUAnw(glBNpnxRzXeCPbt0DS0CTMfyRXcCyjoCXIpelWKfaYY5dk6WgBH5pAE3ytD1Awys3oUg0Kpvep(HPDfXsxhl9yXmwWNpTFiRhvd7uaiwuWIzSGWN3v1K9rLWHQ4Zh8AqrS01XspwuxTMn41pd2Hk9pXSamwqdlkyrD1A2Gx)myxrS01Xspw6XI6Q1SbV(zWouP)jMfGXcQaOT0rglaplb61S0JfhFJRRrqt0WcsyPGfZsFwuWI6Q1SbV(zWUIyPRJf1vRzhhbLWfU2gkJv8k(Z2sx3JJpAE3ouP)jMfGXcQaOT0rglaplb61S0JfhFJRRrqt0WcsyPGfZsFwuWI6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrS0NffSeGiO0ZZIGYBp(WsFw6ZIcw6XcoI0665dk6Ww85tZ1AwaglfKLUowq4Z7QAYIpFAUwxnbZR2CTUcBnw6ZsFwuWIzSGWN3v1K9rLWHQ4Zh8AqrSOGLESyglZkPgCqr27ljtWjRGd5LQFcsJLsxvtGS01XcoI0665dk6Ww85tZ1AwaglfKL(gNrmbO5yyEJnkDvnbAeBJnpCpmn2sYuTectJnqchMp6EyASvGyIfaKqyIz5tw2GAFyb9d6pctS4jilyhbXsbyP1SaGectwAWHfKgdKyUzWylm)rZ7gB9yrD1AwkO)imvXqTp2Hk9pXSuileYOW6O69LelDDS0JLWUpOimlkXcazrbldf29bfvVVKybySGgw6ZsxhlHDFqrywuILcYsFwuWIhvd7uaiJZiMaengM3yJsxvtGgX2ylm)rZ7gB9yrD1AwkO)imvXqTp2Hk9pXSuileYOW6O69LelDDS0JLWUpOimlkXcazrbldf29bfvVVKybySGgw6ZsxhlHDFqrywuILcYsFwuWIhvd7uaiwuWspwuxTMDCeucx4ABOmwXTdv6FIzbySGgwuWI6Q1SJJGs4cxBdLXkUDfXIcwmJLzLudoOil(Z2sx3JJpAE3sPRQjqw66yXmwuxTMDCeucx4ABOmwXTRiw6BS5H7HPX2URB1simnoJycqaPH5n2O0v1eOrSn2cZF08UXwpwuxTMLc6pctvmu7JDOs)tmlfYcHmkSoQEFjXIcw6Xsac1GqtPn41pd2Hk9pXSuilOPyw66yjaHAqOP0gGjciqu92Pko6N)W2Hk9pXSuilOPyw6Zsxhl9yjS7dkcZIsSaqwuWYqHDFqr17ljwaglOHL(S01Xsy3hueMfLyPGS0NffS4r1WofaIffS0Jf1vRzhhbLWfU2gkJvC7qL(NywaglOHffSOUAn74iOeUW12qzSIBxrSOGfZyzwj1GdkYI)ST01944JM3Tu6QAcKLUowmJf1vRzhhbLWfU2gkJvC7kIL(gBE4EyAS1wADTectJZiMaeqByEJnkDvnbAeBJnqchMp6EyASvGyIfKdi6ZcmzbPfqJnpCpmn2m5Z8WPcBvsVsY4mIjabugM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSHJiTUE(GIoSfF(0(HyPqwmhwamlnneoS0JLshF0eVIW1lIfGNfLlUywqclaSyw6ZcGzPPHWHLESOUAnl(8bVguuLkJGMOPKYRIHAFS4ZdaXcsyXCyPVXgiHdZhDpmn2qQRdlTFeMft70TtdlhKLfMyz78P9dXYNSSb1(WIP9pSZYJzXpwqdlNpOOddyLzPbhwie0eNfawmYLLshF0eNf4WI5WY25dEnOiwq)YiOjAkP8ybFEaiSXgcFQPxsgB4ZN2pu9ZkgQ9X4mIjabegM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSPmliHfCeP11DhFelaJfaArdlayw6XsXwaYcWZcoI0665dk6Ww85t7hIfGNLESOmlaMLZ1uEwmCPRWw92PAdoe(Su6QAcKfGNfLTOHL(S0NfaZsXwLrdlaplQRwZoockHlCTnugR42Hk9pXgBGeomF09W0ydPUoS0(rywmTt3onSCqwqog)2zbCnFIILcWqzSIBSHWNA6LKXMPXV96N12qzSIBCgXSGfByEJnkDvnbAeBJnpCpmn2mn(TBSbs4W8r3dtJTcetSGCm(TZYNSSb1(Wc6h0FeMyboS8nwsilBNpTFiwm9AnlT)y5ZdYcsJbsm3mWINXlHdzSfM)O5DJTESqb9hHjREL(utczhlDDSqb9hHjRNXRjHSJffSGWN3v1K9X1GMCeel9zrbl9y58bfD27lP6bRGpXsHSyoS01Xcf0FeMS6v6t9ZkazPRJL2JA)Qdv6FIzbySOCXS0NLUowuxTMLc6pctvmu7JDOs)tmlaJfpCpmT4ZN2pKLqgfwhvVVKyrblQRwZsb9hHPkgQ9XUIyPRJfkO)imz)SIHAFyrblMXccFExvtw85t7hQ(zfd1(WsxhlQRwZg86Nb7qL(NywaglE4EyAXNpTFilHmkSoQEFjXIcwmJfe(8UQMSpUg0KJGyrblQRwZg86Nb7qL(NywagleYOW6O69LelkyrD1A2Gx)myxrS01XI6Q1SJJGs4cxBdLXkUDfXIcwq4Z7QAYAA8BV(zTnugR4S01XIzSGWN3v1K9X1GMCeelkyrD1A2Gx)myhQ0)eZsHSqiJcRJQ3xsgNrmlOYgM3yJsxvtGgX2ydKWH5JUhMgBfiMyz78P9dXY3y5twqVv6dlOFq)rycTS8jlBqTpSG(b9hHjwGjlMdGz58bfDywGdlhKLObgyzdQ9Hf0pO)imzS5H7HPXg(8P9dzCgXSGa0W8gBu6QAc0i2gBGeomF09W0yRa4A9TplJnpCpmn2Mvw9W9WSQF8zSPF8vtVKm2AUwF7ZY4moJTMR13(SmmVrmv2W8gBu6QAc0i2gBE4EyASHpFWRbfzSbs4W8r3dtJTTZh8AqrS0GdlLqeujLhlRutymll8NOyj2WyyEJTW8hnVBSzglZkPgCqrwvx7zGQWw1166T)jkSLaURpkIanoJycqdZBSrPRQjqJyBS5H7HPXgELTFiJTq8GMQNpOOdBetLn2cZF08UXgi8SLqy2(HSdv6FIzPqwgQ0)eZcWZcabiliHfLbugBGeomF09W0ydPo(y52jwaHhlM(BNLBNyPeIpwUVKy5GS4GGSSY71SC7elLoYybCn(9WKLhZY(Fww2wz7hILHk9pXSuU03hPFcKLdYsPFHDwkHWS9dXc4A87HPXzeZcAyEJnpCpmn2kHWS9dzSrPRQjqJyBCgNXg(mmVrmv2W8gBu6QAc0i2gBE4EyASHpFWRbfzSbs4W8r3dtJTcetSSD(GxdkILdYcqefXYkILBNyPaoKxQ(jinSOUAnw(gl)XIj4sdYcHSOFiwuPgCiwAF(49prXYTtSKeYowco(yboSCqwaxLrSOsn4qSGuyIacezSfM)O5DJTzLudoOi79LKj4KvWH8s1pbPXsPRQjqwuWspwOG(JWK9ZQNXzrblMXspw6XI6Q1S3xsMGtwbhYlv)eKg7qL(NywkKfpCpmTMg)2TeYOW6O69LelaMLITkZIcw6Xcf0FeMSFwvH3olDDSqb9hHj7Nvmu7dlDDSqb9hHjREL(utczhl9zPRJf1vRzVVKmbNScoKxQ(jin2Hk9pXSuilE4EyAXNpTFilHmkSoQEFjXcGzPyRYSOGLESqb9hHj7Nv9k9HLUowOG(JWKfd1(utczhlDDSqb9hHjRNXRjHSJL(S0NLUowmJf1vRzVVKmbNScoKxQ(jin2vel9zPRJLESOUAnBWRFgSRiw66ybHpVRQjBaMiGarvqchpdS0NffSeGqni0uAdWebeiQE7ufh9ZFy7qoyCwuWsaIGsppB(O2VAZjw6ZIcw6XIzSeGiO0ZZcu859KLUowcqOgeAkTuze0envvycAhQ0)eZsHSaOyPplkyPhlQRwZg86Nb7kILUowmJLaeQbHMsBWRFgSd5GXzPVXzetaAyEJnkDvnbAeBJnpCpmn2Cqp6EeufBYNsJTq8GMQNpOOdBetLn2cZF08UXMzSacpRd6r3JGQyt(uwb9shfzVpa0NOyrblMXIhUhMwh0JUhbvXM8PSc6LokY(zTPFu7hlkyPhlMXci8SoOhDpcQIn5tzDNCT9(aqFIILUowaHN1b9O7rqvSjFkR7KRTdv6FIzPqwqdl9zPRJfq4zDqp6EeufBYNYkOx6Oil(8aqSamwkilkybeEwh0JUhbvXM8PSc6LokYouP)jMfGXsbzrblGWZ6GE09iOk2KpLvqV0rr27da9jkJnqchMp6EyASvGyILya6r3JGyzZKpLSyANswUDAiwEmljKfpCpcIfSjFkrlloMfTFeloMLiig)QAIfyYc2KpLSy6VDwailWHLgzIgwWNhacZcCybMS4SuqaZc2KpLSGHSC7(XYTtSKKjwWM8PKfFMhbHzbaLf(yXBhnSC7(Xc2KpLSqil6hcBCgXSGgM3yJsxvtGgX2yZd3dtJTamrabIQ3ovXr)8h2ydKWH5JUhMgBfiMWSGuyIaceXY3ybPXajMBgy5XSSIyboSehUyXhIfqchpdFIIfKgdKyUzGft)TZcsHjciqelEcYsC4IfFiwujn0elMtXSedma0ylm)rZ7gBMXc4SEqBcRbqmlkyPhl9ybHpVRQjBaMiGarvqchpdSOGfZyjaHAqOP0g86Nb7qoyCwuWIzSmRKAWbfzJMVeoGVRR(e88d1OLg7JLsxvtGS01XI6Q1SbV(zWUIyPplkyXX346Ae0enSamwmNIzrbl9yrD1AwkO)imv1R0h7qL(NywkKfLlMLUowuxTMLc6pctvmu7JDOs)tmlfYIYfZsFw66yrfIXSOGL2JA)Qdv6FIzbySOCXSOGfZyjaHAqOP0g86Nb7qoyCw6BCgX0CmmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYyRhlQRwZoockHlCTnugR42Hk9pXSuilOHLUowmJf1vRzhhbLWfU2gkJvC7kIL(SOGfZyrD1A2XrqjCHRTHYyfVI)ST01944JM3TRiwuWspwuxTMfOpbhcSsLrqt0us5vPKguFSi7qL(NywaglOcG2shzS0NffS0Jf1vRzPG(JWufd1(yhQ0)eZsHSGkaAlDKXsxhlQRwZsb9hHPQEL(yhQ0)eZsHSGkaAlDKXsxhl9yXmwuxTMLc6pctv9k9XUIyPRJfZyrD1AwkO)imvXqTp2vel9zrblMXY5AkplgQX3hilLUQMazPVXgiHdZhDpmn2qkmb)7Hjln4WIR1Sacpml3UFSu6arywWRHy52P4S4dLO7yzO2q4DcKft7uYcachbLWfMLcWqzSIZYUJzrtyml3UNSGgwWuaZYqL(NFIIf4WYTtSau859Kf1vRXYJzXvHRJLdYsZ1AwGTglWHfpJZc6h0FeMy5XS4QW1XYbzHqw0pKXgcFQPxsgBGWRoeWD9dvs5HnoJyIgdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im26XIzSOUAnlf0FeMQyO2h7kIffSyglQRwZsb9hHPQEL(yxrS0NLUowoxt5zXqn((azP0v1eOXgiHdZhDpmn2qkmb)7Hjl3UFSe2Paqyw(glXHlw8HybUo8dsSqb9hHjwoilWuhNfq4XYTtdXcCy5rLWHy52FmlM(BNLnOgFFGm2q4tn9sYydeEv46WpivPG(JWKXzetaPH5n2O0v1eOrSn28W9W0yRecZ2pKXwy(JM3n2gQneE3v1elkyPhlQRwZsb9hHPkgQ9XouP)jMLczzOs)tmlDDSOUAnlf0FeMQ6v6JDOs)tmlfYYqL(Nyw66ybHpVRQjli8QW1HFqQsb9hHjw6ZIcwgQneE3v1elky58bfD27lP6bRGpXsHSOmazrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetaTH5n2O0v1eOrSn28W9W0ydVY2pKXwy(JM3n2gQneE3v1elkyPhlQRwZsb9hHPkgQ9XouP)jMLczzOs)tmlDDSOUAnlf0FeMQ6v6JDOs)tmlfYYqL(Nyw66ybHpVRQjli8QW1HFqQsb9hHjw6ZIcwgQneE3v1elky58bfD27lP6bRGpXsHSOmazrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetaLH5n2O0v1eOrSn28W9W0ydFKw7tTP9Hm2cZF08UX2qTHW7UQMyrbl9yrD1AwkO)imvXqTp2Hk9pXSuildv6FIzPRJf1vRzPG(JWuvVsFSdv6FIzPqwgQ0)eZsxhli85DvnzbHxfUo8dsvkO)imXsFwuWYqTHW7UQMyrblNpOOZEFjvpyf8jwkKfLbKSOGfpQg2PaqSOGfe(8UQMSGWRoeWD9dvs5Hn2cXdAQE(GIoSrmv24mIjGWW8gBu6QAc0i2gBE4EyAS1GtGQWwn9BnKXgiHdZhDpmn2kqmXsbagtwGjlbqwm93oCDSe8OOprzSfM)O5DJnpQg2PaqgNrmvUydZBSrPRQjqJyBS5H7HPXgvgbnrtvfMGgBGeomF09W0yRaXeliN(eCiqw2I(5pmlM(BNfpJZIgMOyHs4c1olAhFFIIf0pO)imXINGSCtCwoil6pjw(JLvelM(BNfa4sJ9HfpbzbPXajMBgm2cZF08UXwpw6XI6Q1Suq)ryQIHAFSdv6FIzPqwuUyw66yrD1AwkO)imv1R0h7qL(NywkKfLlML(SOGLaeQbHMsBWRFgSdv6FIzPqwkyXSOGLESOUAnB08LWb8DD1NGNFOgT0yFSiC9IybySaqZPyw66yXmwMvsn4GISrZxchW31vFcE(HA0sJ9Xsa31hfrGS0NL(S01XI6Q1SrZxchW31vFcE(HA0sJ9XIW1lILcvIfacOlMLUowcqOgeAkTbV(zWoKdgNffS44BCDncAIgwkKfarXgNrmvwzdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2mJfWz9G2ewdGywuWccFExvt2aynatW)EyYIcw6XspwcqOgeAkTuzu8HCDfoGPNbYouP)jMfGXIYasanlaMLESOSYSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFwuWcbCxFuebAPYO4d56kCatpdel9zPRJfhFJRRrqt0WsHkXcGOywuWspwmJLZ1uE22AIxHTkPxjzP0v1eilDDSOUAnBWRFgSGRXVhMSuilbiudcnL22AIxHTkPxjzhQ0)eZcGzbqXsFwuWccFExvt2BFETUIjciAQM8)yrbl9yrD1AwG(eCiWkvgbnrtjLxLsAq9XISRiw66yXmwcqeu65zbk(8EYsFwuWY5dk6S3xs1dwbFILczrD1A2Gx)mybxJFpmzb4zPylGMLUowuHymlkyP9O2V6qL(NywaglQRwZg86Nbl4A87HjlDDSeGiO0ZZMpQ9R2CILUowuxTMvvdHG6f(SRiwuWI6Q1SQAieuVWNDOs)tmlaJf1vRzdE9ZGfCn(9WKfaZspwaeSa8SmRKAWbfzJMVeoGVRR(e88d1OLg7JLaURpkIazPpl9zrblMXI6Q1SbV(zWUIyrbl9yXmwcqeu65zZh1(vBoXsxhlbiudcnL2amrabIQ3ovXr)8h2UIyPRJfvigZIcwApQ9RouP)jMfGXsac1GqtPnateqGO6TtvC0p)HTdv6FIzbWSaizPRJL2JA)Qdv6FIzb5YIYaQIzbySOUAnBWRFgSGRXVhMS03ydKWH5JUhMgBfiMybPXajMBgyX0F7SGuyIaceHeKtFcoeilBr)8hMfpbzbeMO7ybIGgtZFelaWLg7dlWHft7uYsS1qiOEHpwmbxAqwiKf9dXIk1GdXcsJbsm3mWcHSOFiSXgcFQPxsgBbWAaMG)9WSIpJZiMkdqdZBSrPRQjqJyBS5H7HPX24iOeUW12qzSIBSbs4W8r3dtJTcetSC7elaOs5ThFyX0F7S4SG0yGeZndSC7(XYJt0DS0gyjlaWLg7JXwy(JM3n2uxTMn41pd2Hk9pXSuilkJgw66yrD1A2Gx)mybxJFpmzbySuWIzrbli85DvnzdG1amb)7HzfFgNrmvUGgM3yJsxvtGgX2ylm)rZ7gBi85DvnzdG1amb)7HzfFSOGLESyglQRwZg86Nbl4A87HjlfYsblMLUowmJLaebLEEweuE7Xhw6ZsxhlQRwZoockHlCTnugR42velkyrD1A2XrqjCHRTHYyf3ouP)jMfGXcGGfaZsaMGR)SrdfEmvD9JklP8S3xsveUErSayw6XIzSOUAnRQgcb1l8zxrSOGfZy5CnLNfF(OHdOLsxvtGS03yZd3dtJTaPj89UU66hvws5zCgXuzZXW8gBu6QAc0i2gBH5pAE3ydHpVRQjBaSgGj4FpmR4ZyZd3dtJTpd(K(9W04mIPYOXW8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnZyjaHAqOP0g86Nb7qoyCw66yXmwq4Z7QAYgGjciqufKWXZalkyjarqPNNnFu7xT5elDDSaoRh0MWAaeBSbs4W8r3dtJnau95DvnXYctGSatwC1x)3tywUD)yXKNhlhKfvIfSJGazPbhwqAmqI5MbwWqwUD)y52P4S4dLhlMC8rGSaGYcFSOsn4qSC7uPXgcFQPxsgByhbvBWPg86NbJZiMkdinmVXgLUQManITXMhUhMgBT1eVcBvsVsYydKWH5JUhMgBfiMWSuaGOplFJLpzXtwq)G(JWelEcYYnpHz5GSO)Ky5pwwrSy6VDwaGln2h0YcsJbsm3mWINGSedqp6EeelBM8P0ylm)rZ7gBuq)ryY(z1Z4SOGfpQg2PaqSOGf1vRzJMVeoGVRR(e88d1OLg7JfHRxelaJfaAofZIcw6Xci8SoOhDpcQIn5tzf0lDuK9(aqFIILUowmJLaebLEE2Kcdudhqw6ZIcwq4Z7QAYIDeuTbNAWRFgyrbl9yrD1A2XrqjCHRTHYyf3ouP)jMfGXcGGfaml9ybnSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFwuWI6Q1SJJGs4cxBdLXkUDfXsxhlMXI6Q1SJJGs4cxBdLXkUDfXsFJZiMkdOnmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yRaXelaOt62zz78P5AnlrdmGz5BSSD(0CTMLhNO7yzfzSfM)O5DJn1vRzHjD74Aenbk6EyAxrSOGf1vRzXNpnxRTd1gcV7QAY4mIPYakdZBSrPRQjqJyBSfM)O5DJn1vRzXNpA4aAhQ0)eZcWybnSOGLESOUAnlf0FeMQyO2h7qL(NywkKf0WsxhlQRwZsb9hHPQEL(yhQ0)eZsHSGgw6ZIcwC8nUUgbnrdlfYcGOyJnpCpmn2cEgiDvD1AgBQRwRMEjzSHpF0Wb04mIPYacdZBSrPRQjqJyBS5H7HPXg(8bVguKXgiHdZhDpmn2kGRYimlXadazrLAWHybPWebeiILf(tuSC7elifMiGarSeGj4Fpmz5GSe2PaqS8nwqkmrabIy5XS4HB5ADCwCv46y5GSOsSeC8zSfM)O5DJTaebLEE28rTF1MtSOGfe(8UQMSbyIacevbjC8mWIcwcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlaJf0WIcwmJfWz9G2ewdGyJZiMaSydZBSrPRQjqJyBS5H7HPXg(8P5ATXgiHdZhDpmn2kqmXY25tZ1Awm93olBhP1(WsbC(2XINGSKqw2oF0WbeTSyANswsilBNpnxRz5XSSIqllXHlw8Hy5twqVv6dlOFq)ryILgCybqbymfWSahwoilrdmWcaCPX(WIPDkzXvHiiwaefZsmWaqwGdloyKFpcIfSjFkzz3XSaOamMcywgQ0)8tuSahwEmlFYst)O2pllXeEel3UFSSsqAy52jwWEjXsaMG)9WeZYFOdZcyeMLKw34AwoilBNpnxRzbCnFIIfaeockHlmlfGHYyfhTSyANswIdxOdKf89AnlucYYkIft)TZcGOya74iwAWHLBNyr74JfuAOQRXwJTW8hnVBSDUMYZIpsR9PcoF7Su6QAcKffSyglNRP8S4ZhnCaTu6QAcKffSOUAnl(8P5ATDO2q4DxvtSOGLESOUAnlf0FeMQ6v6JDOs)tmlfYcGIffSqb9hHj7Nv9k9HffSOUAnB08LWb8DD1NGNFOgT0yFSiC9IybySaq0umlDDSOUAnB08LWb8DD1NGNFOgT0yFSiC9IyPqLybGOPywuWIJVX11iOjAyPqwaefZsxhlGWZ6GE09iOk2KpLvqV0rr2Hk9pXSuilakw66yXd3dtRd6r3JGQyt(uwb9shfz)S20pQ9JL(SOGLaeQbHMsBWRFgSdv6FIzPqwuUyJZiMauzdZBSrPRQjqJyBS5H7HPXg(8bVguKXgiHdZhDpmn2kqmXY25dEnOiwaqN0TZs0adyw8eKfWvzelXadazX0oLSG0yGeZndSahwUDIfauP82JpSOUAnwEmlUkCDSCqwAUwZcS1yboSehUqhilbpILyGbGgBH5pAE3ytD1Awys3oUg0Kpvep(HPDfXsxhlQRwZc0NGdbwPYiOjAkP8QusdQpwKDfXsxhlQRwZg86Nb7kIffS0Jf1vRzhhbLWfU2gkJvC7qL(NywaglOcG2shzSa8SeOxZspwC8nUUgbnrdliHLcwml9zbWSuqwaEwoxt5ztYuTectlLUQMazrblMXYSsQbhuKf)zBPR7XXhnVBP0v1eilkyrD1A2XrqjCHRTHYyf3UIyPRJf1vRzdE9ZGDOs)tmlaJfubqBPJmwaEwc0RzPhlo(gxxJGMOHfKWsblML(S01XI6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrS01XIzSOUAn74iOeUW12qzSIBxrSOGfZyjaHAqOP0oockHlCTnugR42HCW4S01XIzSeGiO0ZZIGYBp(WsFw66yXX346Ae0enSuilaIIzrbluq)ryY(z1Z4gNrmbianmVXgLUQManITXMhUhMgB4Zh8AqrgBGeomF09W0yZ8tCwoilLoqel3oXIkHpwGnw2oF0WbKf14SGppa0NOy5pwwrSaCxFaiDCw(KfpJZc6h0FeMyrDDSaaxASpS848yXvHRJLdYIkXs0adbc0ylm)rZ7gBNRP8S4ZhnCaTu6QAcKffSyglZkPgCqr27ljtWjRGd5LQFcsJLsxvtGSOGLESOUAnl(8rdhq7kILUowC8nUUgbnrdlfYcGOyw6ZIcwuxTMfF(OHdOfFEaiwaglfKffS0Jf1vRzPG(JWufd1(yxrS01XI6Q1Suq)ryQQxPp2vel9zrblQRwZgnFjCaFxx9j45hQrln2hlcxViwaglaeqxmlkyPhlbiudcnL2Gx)myhQ0)eZsHSOCXS01XIzSGWN3v1KnateqGOkiHJNbwuWsaIGsppB(O2VAZjw6BCgXeGf0W8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnkO)imz)SQxPpSa8SaOybjS4H7HPfF(0(HSeYOW6O69LelaMfZyHc6pct2pR6v6dlapl9ybqYcGz5CnLNfdx6kSvVDQ2GdHplLUQMazb4zPGS0NfKWIhUhMwtJF7wczuyDu9(sIfaZsXwZbnSGewWrKwx3D8rSaywk2IgwaEwoxt5zt)wdHRQU2ZazP0v1eOXgiHdZhDpmn2qF89L(ryw2HMyPCf2zjgyail(qSGY)KazjIgwWuaMGgBi8PMEjzS54iainBuW4mIjanhdZBSrPRQjqJyBS5H7HPXg(8bVguKXgiHdZhDpmn2kGRYiw2oFWRbfXYNS4SaObmMcSSb1(Wc6h0FeMqllGWeDhlA6y5pwIgyGfa4sJ9HLE3UFS8yw29eutGSOgNf6VDAy52jw2oFAUwZI(tIf4WYTtSedmaSqarXSO)KyPbhw2oFWRbf1hTSact0DSarqJP5pIfpzbaDs3olrdmWINGSOPJLBNyXvHiiw0FsSS7jOMyz78rdhqJTW8hnVBSzglZkPgCqr27ljtWjRGd5LQFcsJLsxvtGSOGLESOUAnB08LWb8DD1NGNFOgT0yFSiC9IybySaqaDXS01XI6Q1SrZxchW31vFcE(HA0sJ9XIW1lIfGXcartXSOGLZ1uEw8rATpvW5BNLsxvtGS0NffS0JfkO)imz)SIHAFyrblo(gxxJGMOHfaZccFExvtwhhbaPzJcSa8SOUAnlf0FeMQyO2h7qL(NywamlGWZ2wt8kSvj9kj79bGW1Hk9pzb4zbGw0WsHSaOkMLUowOG(JWK9ZQEL(WIcwC8nUUgbnrdlaMfe(8UQMSoocasZgfyb4zrD1AwkO)imv1R0h7qL(NywamlGWZ2wt8kSvj9kj79bGW1Hk9pzb4zbGw0WsHSaikML(SOGfZyrD1Awys3oUgrtGIUhM2velkyXmwoxt5zXNpA4aAP0v1eilkyPhlbiudcnL2Gx)myhQ0)eZsHSaOzPRJfmCPv)e0E7ZR1vmrarJLsxvtGSOGf1vRzV9516kMiGOXIppaelaJLcwqwaWS0JLzLudoOil(Z2sx3JJpAE3sPRQjqwaEwqdl9zrblTh1(vhQ0)eZsHSOCXfZIcwApQ9RouP)jMfGXcalUyw6ZIcw6Xsac1GqtPfOpbhcSIJ(5pSDOs)tmlfYcGMLUowmJLaebLEEwGIpVNS034mIjarJH5n2O0v1eOrSn28W9W0yljt1simn2ajCy(O7HPXwbIjwaqcHjMLpzb9wPpSG(b9hHjw8eKfSJGyb5mUUb4cWsRzbajeMS0GdlingiXCZalEcYcYPpbhcKf0VmcAIMskpJTW8hnVBS1Jf1vRzPG(JWuvVsFSdv6FIzPqwiKrH1r17ljw66yPhlHDFqrywuIfaYIcwgkS7dkQEFjXcWybnS0NLUowc7(GIWSOelfKL(SOGfpQg2PaqSOGfe(8UQMSyhbvBWPg86NbJZiMaeqAyEJnkDvnbAeBJTW8hnVBS1Jf1vRzPG(JWuvVsFSdv6FIzPqwiKrH1r17ljwuWIzSeGiO0ZZcu859KLUow6XI6Q1Sa9j4qGvQmcAIMskVkL0G6JfzxrSOGLaebLEEwGIpVNS0NLUow6Xsy3hueMfLybGSOGLHc7(GIQ3xsSamwqdl9zPRJLWUpOimlkXsbzPRJf1vRzdE9ZGDfXsFwuWIhvd7uaiwuWccFExvtwSJGQn4udE9ZalkyPhlQRwZoockHlCTnugR42Hk9pXSamw6XcAybaZcazb4zzwj1GdkYI)ST01944JM3Tu6QAcKL(SOGf1vRzhhbLWfU2gkJvC7kILUowmJf1vRzhhbLWfU2gkJvC7kIL(gBE4EyAST76wTectJZiMaeqByEJnkDvnbAeBJTW8hnVBS1Jf1vRzPG(JWuvVsFSdv6FIzPqwiKrH1r17ljwuWIzSeGiO0ZZcu859KLUow6XI6Q1Sa9j4qGvQmcAIMskVkL0G6JfzxrSOGLaebLEEwGIpVNS0NLUow6Xsy3hueMfLybGSOGLHc7(GIQ3xsSamwqdl9zPRJLWUpOimlkXsbzPRJf1vRzdE9ZGDfXsFwuWIhvd7uaiwuWccFExvtwSJGQn4udE9ZalkyPhlQRwZoockHlCTnugR42Hk9pXSamwqdlkyrD1A2XrqjCHRTHYyf3UIyrblMXYSsQbhuKf)zBPR7XXhnVBP0v1eilDDSyglQRwZoockHlCTnugR42vel9n28W9W0yRT06AjeMgNrmbiGYW8gBu6QAc0i2gBGeomF09W0yRaXelihq0NfyYsa0yZd3dtJnt(mpCQWwL0RKmoJycqaHH5n2O0v1eOrSn28W9W0ydF(0(Hm2ajCy(O7HPXwbIjw2oFA)qSCqwIgyGLnO2hwq)G(JWeAzbPXajMBgyz3XSOjmML7ljwUDpzXzb5y8BNfczuyDelAQDSahwGPoolO3k9Hf0pO)imXYJzzfzSfM)O5DJnkO)imz)SQxPpS01Xcf0FeMSyO2NAsi7yPRJfkO)imz9mEnjKDS01XspwuxTM1KpZdNkSvj9kj7kILUowWrKwx3D8rSamwk2AoOHffSyglbick98SiO82JpS01XcoI066UJpIfGXsXwZHffSeGiO0ZZIGYBp(WsFwuWI6Q1Suq)ryQQxPp2velDDS0Jf1vRzdE9ZGDOs)tmlaJfpCpmTMg)2TeYOW6O69LelkyrD1A2Gx)myxrS034mIzbl2W8gBu6QAc0i2gBGeomF09W0yRaXelihJF7SaVDAm9yIft7FyNLhZYNSSb1(Wc6h0FeMqllingiXCZalWHLdYs0adSGER0hwq)G(JWKXMhUhMgBMg)2noJywqLnmVXgLUQManITXgiHdZhDpmn2kaUwF7ZYyZd3dtJTzLvpCpmR6hFgB6hF10ljJTMR13(SmoJZylAOaSu1pdZBetLnmVXMhUhMgBa9j4qGvC0p)Hn2O0v1eOrSnoJycqdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2k2ydKWH5JUhMgBMFNybHpVRQjwEmly6y5GSumlM(BNLeYc(8JfyYYctSCZNarhgTSOmlM2PKLBNyP9d(ybMelpMfyYYctOLfaYY3y52jwWuaMGS8yw8eKLcYY3yrfE7S4dzSHWNA6LKXgmRlmvV5tGOZ4mIzbnmVXgLUQManITXgmYyZbbn28W9W0ydHpVRQjJneUErgBkBSfM)O5DJTB(ei6SNY2f2v1elky5MpbIo7PSnaHAqOP0cUg)EyASHWNA6LKXgmRlmvV5tGOZ4mIP5yyEJnkDvnbAeBJnyKXMdcAS5H7HPXgcFExvtgBiC9Im2aOXwy(JM3n2U5tGOZEa0UWUQMyrbl38jq0zpaAdqOgeAkTGRXVhMgBi8PMEjzSbZ6ct1B(ei6moJyIgdZBSrPRQjqJyBSbJm2CqqJnpCpmn2q4Z7QAYydHp10ljJnywxyQEZNarNXwy(JM3n2iG76JIiq7N4WSoxvtvG7YZBvwbjeFGyPRJfc4U(Oic0sLrXhY1v4aMEgiw66yHaURpkIaTy4sRP7(evDwQXn2ajCy(O7HPXM53jmXYnFceDyw8HyjHhl(6k97dUwhNfq6OWrGS4ywGjllmXc(8JLB(ei6WwwIH2KhhZIdc(jkwuMLsYtml3ofNftVwZIRn5XXSOsSenuJMHaz5tqkIsqkpwGnwWA4zSHW1lYytzJZiMasdZBS5H7HPXwjeMa9zTbNsJnkDvnbAeBJZiMaAdZBSrPRQjqJyBS5H7HPXMPXVDJn9NunaASPCXgBH5pAE3yRhluq)ryYQxPp1Kq2Xsxhluq)ryY(zfd1(Wsxhluq)ryY(zvfE7S01Xcf0FeMSEgVMeYow6BSbs4W8r3dtJna4qbhFSaqwqog)2zXtqwCw2oFWRbfXcmzzZ8Sy6VDwI5JA)yPa4elEcYsSHXW8Sahw2oFA)qSaVDAm9yY4mIjGYW8gBu6QAc0i2gBH5pAE3yRhluq)ryYQxPp1Kq2Xsxhluq)ryY(zfd1(Wsxhluq)ryY(zvfE7S01Xcf0FeMSEgVMeYow6ZIcwIgcHvzRPXVDwuWIzSeneclaTMg)2n28W9W0yZ043UXzetaHH5n2O0v1eOrSn2cZF08UXMzSmRKAWbfzvDTNbQcBvxRR3(NOWwkDvnbYsxhlMXsaIGsppB(O2VAZjw66yXmwWrKwxpFqrh2IpFAUwZIsSOmlDDSyglNRP8SPFRHWvvx7zGSu6QAcKLUow6Xcf0FeMSyO2NAsi7yPRJfkO)imz)SQxPpS01Xcf0FeMSFwvH3olDDSqb9hHjRNXRjHSJL(gBE4EyASHpFA)qgNrmvUydZBSrPRQjqJyBSfM)O5DJTzLudoOiRQR9mqvyR6AD92)ef2sPRQjqwuWsaIGsppB(O2VAZjwuWcoI0665dk6Ww85tZ1AwuIfLn28W9W0ydF(GxdkY4moJZydbn4hMgXeGfdqLlgqcqaHTGgBM8j)ef2yd5igaiIP5gtKZboSWI53jw(Yi4CS0GdlOdKA(sFOJLHaURFiqwWWsIfFDWs)iqwc7EIIWwUi07tIfZb4WcsHjcAocKLTVePSGJNNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9ugz9TCrO3NelMdWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwqdWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwaKahwqkmrqZrGSS9LiLfC88CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPharwFlxe69jXcGg4WcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO3NelaAGdlifMiO5iqwq3nFceDwLTaa0XYbzbD38jq0zpLTaa0XspaIS(wUi07tIfanWHfKcte0CeilO7MpbIolaTaa0XYbzbD38jq0zpaAbaOJLEaez9TCrO3NelakGdlifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfHEFsSaiaoSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe69jXIYfdCybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(wUi07tIfLvg4WcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO3NelkdqGdlifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0dGiRVLlc9(KyrzacCybPWebnhbYc6U5tGOZQSfaGowoilO7MpbIo7PSfaGow6bqK13YfHEFsSOmaboSGuyIGMJazbD38jq0zbOfaGowoilO7MpbIo7bqlaaDS0tzK13YfHEFsSOCbboSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspaIS(wUi07tIfLliWHfKcte0CeilO7MpbIoRYwaa6y5GSGUB(ei6SNYwaa6yPNYiRVLlc9(Kyr5ccCybPWebnhbYc6U5tGOZcqlaaDSCqwq3nFceD2dGwaa6yPharwFlxexeYrmaqetZnMiNdCyHfZVtS8LrW5yPbhwqx0qbyPQFOJLHaURFiqwWWsIfFDWs)iqwc7EIIWwUi07tILccCybPWebnhbYc6U5tGOZQSfaGowoilO7MpbIo7PSfaGow6bqK13YfHEFsSyoahwqkmrqZrGSGUB(ei6Sa0caqhlhKf0DZNarN9aOfaGow6bqK13YfHEFsSaiaoSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe69jXIYfdCybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(wUiUiKJyaGiMMBmroh4WclMFNy5lJGZXsdoSGohsOJLHaURFiqwWWsIfFDWs)iqwc7EIIWwUi07tIfLboSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XIFSG(aOrpw6PmY6B5IqVpjwkiWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwaKahwqkmrqZrGSS9LiLfC88CKXcYf5YYbzb9wolLqWLEHzbgrJFWHLEi3(S0tzK13YfHEFsSaiboSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspaIS(wUi07tIfanWHfKcte0CeilBFjszbhpphzSGCrUSCqwqVLZsjeCPxywGr04hCyPhYTpl9ugz9TCrO3NelaAGdlifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfHEFsSaOaoSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe69jXcGa4WcsHjcAocKLTVePSGJNNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9aiY6B5IqVpjwugGahwqkmrqZrGSS9LiLfC88CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPNYiRVLlc9(KyrzabWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwaOYahwqkmrqZrGSS9LiLfC88CKXcYLLdYc6TCwaFep(HjlWiA8doS0dj9zPNYiRVLlc9(KybGfe4WcsHjcAocKLTVePSGJNNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9aiY6B5IqVpjwaybboSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe69jXcardWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwaiGe4WcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO3NelaeqbCybPWebnhbYY2xIuwWXZZrglixwoilO3Yzb8r84hMSaJOXp4WspK0NLEaez9TCrO3NelaeqaCybPWebnhbYY2xIuwWXZZrglixwoilO3Yzb8r84hMSaJOXp4WspK0NLEkJS(wUiUiKJyaGiMMBmroh4WclMFNy5lJGZXsdoSGUMR13(SqhldbCx)qGSGHLel(6GL(rGSe29efHTCrO3Nelae4WcsHjcAocKLTVePSGJNNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9ugz9TCrCrihXaarmn3yICoWHfwm)oXYxgbNJLgCybD4dDSmeWD9dbYcgwsS4Rdw6hbYsy3tue2YfHEFsSOmWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwkiWHfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5IqVpjwuwzGdlifMiO5iqw2(sKYcoEEoYyb5ICz5GSGElNLsi4sVWSaJOXp4WspKBFw6PmY6B5IqVpjwuwzGdlifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfHEFsSOmGe4WcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO3NelauzGdlifMiO5iqw2(sKYcoEEoYyb5YYbzb9wolGpIh)WKfyen(bhw6HK(S0dGiRVLlc9(KybGkdCybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(wUi07tIfacqGdlifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfHEFsSaWccCybPWebnhbYY2xIuwWXZZrglixwoilO3Yzb8r84hMSaJOXp4WspK0NLEfez9TCrO3Nela0CaoSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspaIS(wUi07tIfaciboSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe69jXcab0ahwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlIlc5igaiIP5gtKZboSWI53jw(Yi4CS0GdlOtf6h6yziG76hcKfmSKyXxhS0pcKLWUNOiSLlc9(KyrzafWHfKcte0CeilBFjszbhpphzSGCz5GSGElNfWhXJFyYcmIg)Gdl9qsFw6vqK13YfHEFsSOmGa4WcsHjcAocKLTVePSGJNNJmwqUSCqwqVLZc4J4XpmzbgrJFWHLEiPpl9ugz9TCrCrMBzeCocKfajlE4EyYI(Xh2YfzSfnW2RjJnKh5zj2U2ZaXsbCwpixeYJ8Su0kjwaiGaTSaWIbOYCrCripYZcs39efHboCripYZcaMLyacsGSSb1(WsSjV0YfH8iplaywq6UNOiqwoFqrx9BSeCmHz5GSeIh0u98bfDylxeYJ8SaGzbabvcrqGSSYKceg7tCwq4Z7QAcZsV3sw0Ys0qiQ4Zh8AqrSaGlKLOHqyXNp41GI6B5IqEKNfamlXab8bzjAOGJVprXcYX43olFJL)qhMLBNyX0atuSG(b9hHjlxeYJ8SaGzbaPdeXcsHjciqel3oXYw0p)HzXzr)3PjwkHdXstti7v1el9(glXHlw2DWeDhl7)XYFSG)YL(8KGlSoolM(BNLydGogMNfaZcsjnHV31Sed9JklP8qll)HoqwWa9r9TCripYZcaMfaKoqelLq8Xc6ApQ9RouP)jgDSGdu6ZdXS4rr64SCqwuHymlTh1(HzbM64wUiUiKh5zjgzcp)iqwITR9mqSedai6XsWtwujwAWvcYIFSSFxeg4GeKO6Apdeag)LblQ)2xQ2hIKy7ApdeaE7lrkskbT7xPg5STxtkP6ApdK9q2XfXf5H7Hj2gnuawQ6Nsa9j4qGvC0p)H5IqEwm)oXccFExvtS8ywW0XYbzPywm93oljKf85hlWKLfMy5MpbIomAzrzwmTtjl3oXs7h8XcmjwEmlWKLfMqllaKLVXYTtSGPambz5XS4jilfKLVXIk82zXhIlYd3dtSnAOaSu1paResq4Z7QAcTPxskbZ6ct1B(ei6qlcxViLkMlYd3dtSnAOaSu1paResq4Z7QAcTPxskbZ6ct1B(ei6qlmsjheeTiC9Iusz0(nLU5tGOZQSDHDvnP4MpbIoRY2aeQbHMsl4A87HjxKhUhMyB0qbyPQFawjKGWN3v1eAtVKucM1fMQ38jq0HwyKsoiiAr46fPear73u6MpbIolaTlSRQjf38jq0zbOnaHAqOP0cUg)EyYfH8Sy(DctSCZNarhMfFiws4XIVUs)(GR1XzbKokCeiloMfyYYctSGp)y5MpbIoSLLyOn5XXS4GGFIIfLzPK8eZYTtXzX0R1S4AtECmlQelrd1Oziqw(eKIOeKYJfyJfSgECrE4EyITrdfGLQ(byLqccFExvtOn9ssjywxyQEZNarhAHrk5GGOfHRxKskJ2VPebCxFuebA)ehM15QAQcCxEERYkiH4duxhbCxFuebAPYO4d56kCatpduxhbCxFuebAXWLwt39jQ6SuJZf5H7Hj2gnuawQ6hGvcjLqyc0N1gCk5IqEwaGdfC8Xcazb5y8BNfpbzXzz78bVguelWKLnZZIP)2zjMpQ9JLcGtS4jilXggdZZcCyz78P9dXc82PX0JjUipCpmX2OHcWsv)aSsiX043oA1Fs1aOskxmA)Ms9OG(JWKvVsFQjHSRRJc6pct2pRyO2NUokO)imz)SQcV9UokO)imz9mEnjKD95I8W9WeBJgkalv9dWkHetJF7O9Bk1Jc6pctw9k9PMeYUUokO)imz)SIHAF66OG(JWK9ZQk8276OG(JWK1Z41Kq21xr0qiSkBnn(TRWSOHqybO1043oxKhUhMyB0qbyPQFawjKGpFA)qO9Bkz2SsQbhuKv11EgOkSvDTUE7FIc31zwaIGsppB(O2VAZPUoZWrKwxpFqrh2IpFAUwRKYDDMDUMYZM(TgcxvDTNbYsPRQjWUUEuq)ryYIHAFQjHSRRJc6pct2pR6v6txhf0FeMSFwvH3Exhf0FeMSEgVMeYU(CrE4EyITrdfGLQ(byLqc(8bVgueA)MsZkPgCqrwvx7zGQWw1166T)jkSIaebLEE28rTF1MtkWrKwxpFqrh2IpFAUwRKYCrCripYZc6JmkSocKfcbnXz5(sILBNyXdhCy5XS4i8x7QAYYf5H7Hjwjmu7tvL8sUiKNLn6WSedi6ZcmzPGaMft)TdxhlGZ3ow8eKft)TZY25JgoGS4jilaeWSaVDAm9yIlYd3dtmGvcji85DvnH20ljLEC1HeAr46fPeoI0665dk6Ww85tZ16cvwrpZoxt5zXNpA4aAP0v1eyx35Akpl(iT2Nk48TZsPRQjW(DD4isRRNpOOdBXNpnxRleGCriplB0HzjOjhbXIPDkzz78P9dXsWtw2)JfacywoFqrhMft7FyNLhZYqAcHNhln4WYTtSG(b9hHjwoilQelrd1Oziqw8eKft7FyNL2R10WYbzj44JlYd3dtmGvcji85DvnH20ljLECnOjhbHweUErkHJiTUE(GIoSfF(0(HkuzUiKNLcetSeBAW0a0NOyX0F7SG0yGeZndSahw82rdlifMiGarS8jlingiXCZaxKhUhMyaResuPbtdqFIcTFtPEMfGiO0ZZMpQ9R2CQRZSaeQbHMsBaMiGar1BNQ4OF(dBxr9vOUAnBWRFgSdv6FIluz0OqD1A2XrqjCHRTHYyf3ouP)jgyMJcZcqeu65zrq5ThF66cqeu65zrq5ThFuOUAnBWRFgSRifQRwZoockHlCTnugR42vKIEQRwZoockHlCTnugR42Hk9pXatzLbWOb4Nvsn4GIS4pBlDDpo(O59Uo1vRzdE9ZGDOs)tmWuw5UoLrU4isRR7o(iGPSfnOPpxeYZcaeESy6VDwCwqAmqI5MbwUD)y5Xj6owCwaGln2hwIgyGf4WIPDkz52jwApQ9JLhZIRcxhlhKfkb5I8W9WedyLqse8EyI2VPK6Q1SbV(zWouP)jUqLrJIEMnRKAWbfzXF2w66EC8rZ7DDQRwZoockHlCTnugR42Hk9pXatzaTc1vRzhhbLWfU2gkJvC7kQFxNkeJv0Eu7xDOs)tmWaiA4IqEwqQRdlTFeMft70Ttdll8NOybPWebeiILeAIftVwZIR1qtSehUy5GSGVxRzj44JLBNyb7LelEjCLhlWglifMiGaragPXajMBgyj44dZf5H7HjgWkHee(8UQMqB6LKsbyIacevbjC8mGweUErkfOx3Rx7rTF1Hk9pXayLrdaoaHAqOP0g86Nb7qL(N4(ixLbuf3xPa96E9ApQ9RouP)jgaRmAaWkdWIbWbiudcnL2amrabIQ3ovXr)8h2ouP)jUpYvzavX9vy24pyLqq5zDqqSLq2JpCxxac1GqtPn41pd2Hk9pXf(5rteu7hbwBpQ9RouP)jURlaHAqOP0gGjciqu92Pko6N)W2Hk9pXf(5rteu7hbwBpQ9RouP)jgaRCXDDMfGiO0ZZMpQ9R2CQRZd3dtBaMiGar1BNQ4OF(dBbFSRQjqUiKNLcetGSCqwajThNLBNyzHDuelWglingiXCZalM2PKLf(tuSacxQAIfyYYctS4jilrdHGYJLf2rrSyANsw8KfheKfcbLhlpMfxfUowoilGpXf5H7HjgWkHee(8UQMqB6LKsbWAaMG)9WeTiC9IuQ35dk6S3xs1dwbFQqLrtx34pyLqq5zDqqS9ZcrtX9v0RxpZiG76JIiqlvgfFixxHdy6zG6661laHAqOP0sLrXhY1v4aMEgi7qL(NyGPmGS4UUaebLEEweuE7XhfbiudcnLwQmk(qUUchW0ZazhQ0)edmLbKaAa3tzLb(zLudoOil(Z2sx3JJpAEVFFfMfGqni0uAPYO4d56kCatpdKDihmE)(k6zgbCxFuebAXWLwt39jQ6SuJ31zwaIGsppB(O2VAZPUUaeQbHMslgU0A6UprvNLAC7qL(NyGPSYMtFf9mJaURpkIaTFIdZ6CvnvbUlpVvzfKq8bQRlaHAqOP0(jomRZv1uf4U88wLvqcXhi7qoy8(k6fGqni0uAvPbtdqFIYoKdgVRZSXdK9gOw3VRRxpe(8UQMSWSUWu9MpbIoLuURdHpVRQjlmRlmvV5tGOtPc2xrVB(ei6SkBhYbJxdqOgeAk76U5tGOZQSnaHAqOP0ouP)jUWppAIGA)iWA7rTF1Hk9pXayLlUFxhcFExvtwywxyQEZNarNsaurVB(ei6Sa0oKdgVgGqni0u21DZNarNfG2aeQbHMs7qL(N4c)8OjcQ9JaRTh1(vhQ0)edGvU4(DDi85DvnzHzDHP6nFceDkvC)(DDbick98SafFEp7Zf5H7HjgWkHee(8UQMqB6LKs3(8ADfteq0un5)HweUErkzggU0QFcAV9516kMiGOXsPRQjWUU2JA)Qdv6FIleGfxCxNkeJv0Eu7xDOs)tmWaiAaCpZPyaS6Q1S3(8ADfteq0yXNhac4by)Uo1vRzV9516kMiGOXIppauHfeqbG7nRKAWbfzXF2w66EC8rZ7apA6ZfH8SuGyIf0Vmk(qUMfa0dy6zGybGfJPaMfvQbhIfNfKgdKyUzGLfMSCrE4EyIbSsizHP6FujAtVKuIkJIpKRRWbm9mqO9BkfGqni0uAdE9ZGDOs)tmWayXkcqOgeAkTbyIacevVDQIJ(5pSDOs)tmWayXk6HWN3v1K92NxRRyIaIMQj)VUo1vRzV9516kMiGOXIppauHfSya3Bwj1GdkYI)ST01944JM3bEaz)(DDQqmwr7rTF1Hk9pXaRGaAUiKNLcetSSbxAnDFIIfael14SaiXuaZIk1GdXIZcsJbsm3mWYctwUipCpmXawjKSWu9pQeTPxskHHlTMU7tu1zPghTFtPaeQbHMsBWRFgSdv6FIbgGuHzbick98SiO82JpkmlarqPNNnFu7xT5uxxaIGsppB(O2VAZjfbiudcnL2amrabIQ3ovXr)8h2ouP)jgyasf9q4Z7QAYgGjciqufKWXZqxxac1GqtPn41pd2Hk9pXadq2VRlarqPNNfbL3E8rrpZMvsn4GIS4pBlDDpo(O5DfbiudcnL2Gx)myhQ0)edmazxN6Q1SJJGs4cxBdLXkUDOs)tmWu2CaCp0a8eWD9rreO9t8nRWbhCf8r8jvvjTUVc1vRzhhbLWfU2gkJvC7kQFxNkeJv0Eu7xDOs)tmWaiA4I8W9WedyLqYct1)Os0MEjP0N4WSoxvtvG7YZBvwbjeFGq73usD1A2Gx)myhQ0)exOYOrrpZMvsn4GIS4pBlDDpo(O59Uo1vRzhhbLWfU2gkJvC7qL(NyGPmabCVcc8QRwZQQHqq9cF2vuFa3RhGgaJgGxD1AwvnecQx4ZUI6d8eWD9rreO9t8nRWbhCf8r8jvvjTUVc1vRzhhbLWfU2gkJvC7kQFxNkeJv0Eu7xDOs)tmWaiA4IqEwm)(Jz5XS4Sm(TtdlK2vHJFelM84SCqwkDGiwCTMfyYYctSGp)y5MpbIomlhKfvIf9NeilRiwm93olingiXCZalEcYcsHjciqelEcYYctSC7elambzbRHhlWKLailFJfv4TZYnFceDyw8HybMSSWel4ZpwU5tGOdZf5H7HjgWkHKfMQ)rLy0I1WdR0nFceDkJ2VPecFExvtwywxyQEZNarNsauHz38jq0zbODihmEnaHAqOPSRRhcFExvtwywxyQEZNarNsk31HWN3v1KfM1fMQ38jq0Pub7RON6Q1SbV(zWUIu0ZSaebLEEweuE7XNUo1vRzhhbLWfU2gkJvC7qL(Nya3dna)SsQbhuKf)zBPR7XXhnV3hykDZNarNvzR6Q1QGRXVhMkuxTMDCeucx4ABOmwXTROUo1vRzhhbLWfU2gkJv8k(Z2sx3JJpAE3UI631fGqni0uAdE9ZGDOs)tmGbyH38jq0zv2gGqni0uAbxJFpmv0ZSaebLEE28rTF1MtDDMHWN3v1KnateqGOkiHJNH(kmlarqPNNfO4Z7zxxaIGsppB(O2VAZjfi85DvnzdWebeiQcs44zqrac1GqtPnateqGO6TtvC0p)HTRifMfGqni0uAdE9ZGDfPOxp1vRzPG(JWuvVsFSdv6FIlu5I76uxTMLc6pctvmu7JDOs)tCHkxCFfMnRKAWbfzvDTNbQcBvxRR3(NOWDD9uxTMv11EgOkSvDTUE7FIcxt)wdzXNhasj001PUAnRQR9mqvyR6AD92)efU6tWtYIppaKsaQ(976uxTMfOpbhcSsLrqt0us5vPKguFSi7kQFxNkeJv0Eu7xDOs)tmWayXDDi85DvnzHzDHP6nFceDkvmxKhUhMyaReswyQ(hvIrlwdpSs38jq0bq0(nLq4Z7QAYcZ6ct1B(ei6mtjaQWSB(ei6SkBhYbJxdqOgeAk76q4Z7QAYcZ6ct1B(ei6ucGk6PUAnBWRFgSRif9mlarqPNNfbL3E8PRtD1A2XrqjCHRTHYyf3ouP)jgW9qdWpRKAWbfzXF2w66EC8rZ79bMs38jq0zbOvD1AvW143dtfQRwZoockHlCTnugR42vuxN6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxr976cqOgeAkTbV(zWouP)jgWaSWB(ei6Sa0gGqni0uAbxJFpmv0ZSaebLEE28rTF1MtDDMHWN3v1KnateqGOkiHJNH(kmlarqPNNfO4Z7PIEMPUAnBWRFgSROUoZcqeu65zrq5ThF631fGiO0ZZMpQ9R2CsbcFExvt2amrabIQGeoEgueGqni0uAdWebeiQE7ufh9ZFy7ksHzbiudcnL2Gx)myxrk61tD1AwkO)imv1R0h7qL(N4cvU4Uo1vRzPG(JWufd1(yhQ0)exOYf3xHzZkPgCqrwvx7zGQWw1166T)jkCxxp1vRzvDTNbQcBvxRR3(NOW10V1qw85bGucnDDQRwZQ6Apduf2QUwxV9prHR(e8KS4ZdaPeGQF)(DDQRwZc0NGdbwPYiOjAkP8QusdQpwKDf11PcXyfTh1(vhQ0)edmawCxhcFExvtwywxyQEZNarNsfZfH8SuGycZIR1SaVDAybMSSWel)rLywGjlbqUipCpmXawjKSWu9pQeZfH8SuaPWdsS4H7Hjl6hFSO6ycKfyYc(VLFpmrIMq9yUipCpmXawjKmRS6H7Hzv)4dTPxsk5qcT4B(WPKYO9BkHWN3v1K9XvhsCrE4EyIbSsizwz1d3dZQ(XhAtVKusf6hAX38HtjLr73uAwj1GdkYQ6Apduf2QUwxV9prHTeWD9rreixKhUhMyaResMvw9W9WSQF8H20ljLWhxexeYZcsDDyP9JWSyANUDAy52jwkGd5Lb)c70WI6Q1yX0R1S0CTMfyRXIP)2)KLBNyjjKDSeC8Xf5H7Hj26qsje(8UQMqB6LKsGd5LvtVwxBUwxHTgAr46fPup1vRzVVKmbNScoKxQ(jin2Hk9pXadva0w6idWfBvURtD1A27ljtWjRGd5LQFcsJDOs)tmW8W9W0IpFA)qwczuyDu9(scWfBvwrpkO)imz)SQxPpDDuq)ryYIHAFQjHSRRJc6pctwpJxtczx)(kuxTM9(sYeCYk4qEP6NG0yxrkMvsn4GIS3xsMGtwbhYlv)eKgUiKNfK66Ws7hHzX0oD70WY25dEnOiwEmlMGZTZsWX3NOybIGgw2oFA)qS8jlO3k9Hf0pO)imXf5H7Hj26qcWkHee(8UQMqB6LKspQeoufF(GxdkcTiC9IuYmkO)imz)SIHAFu0dhrAD98bfDyl(8P9dviAuCUMYZIHlDf2Q3ovBWHWNLsxvtGDD4isRRNpOOdBXNpTFOcb095IqEwkqmXcsHjciqelM2PKf)yrtyml3UNSGMIzjgyailEcYI(tILvelM(BNfKgdKyUzGlYd3dtS1HeGvcjbyIacevVDQIJ(5pmA)MsMboRh0MWAaeROxpe(8UQMSbyIacevbjC8mOWSaeQbHMsBWRFgSd5GX76uxTMn41pd2vuFf9uxTMLc6pctv9k9XouP)jUqazxN6Q1Suq)ryQIHAFSdv6FIleq2xrpZMvsn4GISQU2ZavHTQR11B)tu4Uo1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkSGDDQRwZQ6Apduf2QUwxV9prHR(e8KS4Zdavyb731PcXyfTh1(vhQ0)edmLlwHzbiudcnL2Gx)myhYbJ3Nlc5zPaXelfGHYyfNft)TZcsJbsm3mWf5H7Hj26qcWkHKXrqjCHRTHYyfhTFtj1vRzdE9ZGDOs)tCHkJgUiKNLcetSSTY2pelFYsKNGu5hybMS4z8B)tuSC7(XI(rqywu2CWuaZINGSOjmMft)TZsjCiwoFqrhMfpbzXpwUDIfkbzb2yXzzdQ9Hf0pO)imXIFSOS5WcMcywGdlAcJzzOs)ZprXIJz5GSKWJLDhXNOy5GSmuBi8olGR5tuSGER0hwq)G(JWexKhUhMyRdjaResWRS9dH2q8GMQNpOOdRKYO9Bk1BO2q4DxvtDDQRwZsb9hHPkgQ9XouP)jgyfubf0FeMSFwXqTpkgQ0)edmLnhfNRP8Sy4sxHT6Tt1gCi8zP0v1eyFfNpOOZEFjvpyf8Pcv2CaW4isRRNpOOdd4Hk9pXk6rb9hHj7NvpJ31nuP)jgyOcG2shz95IqEwqoruelRiw2oFAUwZIFS4Anl3xsywwPMWyww4prXc6fp4JJzXtqw(JLhZIRcxhlhKLObgyboSOPJLBNybhrH31S4H7Hjl6pjwujn0el7EcQjwkGd5LQFcsdlWKfaYY5dk6WCrE4EyIToKaSsibF(0CTgTFtjZoxt5zXhP1(ubNVDwkDvnbQON6Q1S4ZNMR12HAdH3DvnPOhoI0665dk6Ww85tZ1AGvWUoZMvsn4GIS3xsMGtwbhYlv)eKM(DDNRP8Sy4sxHT6Tt1gCi8zP0v1eOc1vRzPG(JWufd1(yhQ0)edScQGc6pct2pRyO2hfQRwZIpFAUwBhQ0)edmaTcCeP11Zhu0HT4ZNMR1fQK50xrpZMvsn4GIS64bFCCTPj6(evfL(lJWux39LeYf5AoOPq1vRzXNpnxRTdv6FIbma7R48bfD27lP6bRGpviA4IqEwqo(BNLTJ0AFyPaoF7yzHjwGjlbqwmTtjld1gcV7QAIf11Xc(ETMft(FS0GdlOx8GpoMLObgyXtqwaHj6owwyIfvQbhIfKwaXww2UxRzzHjwuPgCiwqkmrabIyb)zGy529JftVwZs0adS4j82PHLTZNMR1CrE4EyIToKaSsibF(0CTgTFtPZ1uEw8rATpvW5BNLsxvtGkuxTMfF(0CT2ouBi8URQjf9mBwj1GdkYQJh8XX1MMO7tuvu6VmctDD3xsixKR5GMcnN(koFqrN9(sQEWk4tfwqUiKNfKJ)2zPaoKxQ(jinSSWelBNpnxRz5GSaerrSSIy52jwuxTglQXzX1yill8NOyz78P5AnlWKf0WcMcWeeZcCyrtymldv6F(jkUipCpmXwhsawjKGpFAUwJ2VP0SsQbhuK9(sYeCYk4qEP6NG0OahrAD98bfDyl(8P5ADHkvqf9mtD1A27ljtWjRGd5LQFcsJDfPqD1Aw85tZ1A7qTHW7UQM666HWN3v1KfCiVSA616AZ16kS1u0tD1Aw85tZ1A7qL(NyGvWUoCeP11Zhu0HT4ZNMR1fcqfNRP8S4J0AFQGZ3olLUQMavOUAnl(8P5ATDOs)tmWqt)(95IqEwqQRdlTFeMft70TtdlolBNp41GIyzHjwm9AnlbFHjw2oFAUwZYbzP5AnlWwdTS4jillmXY25dEnOiwoilaruelfWH8s1pbPHf85bGyzfXf5H7Hj26qcWkHee(8UQMqB6LKs4ZNMR1vtW8QnxRRWwdTiC9IuYX346Ae0enfcOkga3t5IbE1vRzVVKmbNScoKxQ(jinw85bG6dG7PUAnl(8P5ATDOs)tmWxqKloI066UJpc4n7CnLNfFKw7tfC(2zP0v1eyFaCVaeQbHMsl(8P5ATDOs)tmWxqKloI066UJpc4pxt5zXhP1(ubNVDwkDvnb2ha3deE22AIxHTkPxjzhQ0)ed8OPVIEQRwZIpFAUwBxrDDbiudcnLw85tZ1A7qL(N4(CriplfiMyz78bVguelM(BNLc4qEP6NG0WYbzbiIIyzfXYTtSOUAnwm93oCDSOH4prXY25tZ1Awwr3xsS4jillmXY25dEnOiwGjlMdGzj2WyyEwWNhacZYkVxZI5WY5dk6WCrE4EyIToKaSsibF(GxdkcTFtje(8UQMSGd5LvtVwxBUwxHTMce(8UQMS4ZNMR1vtW8QnxRRWwtHzi85DvnzFujCOk(8bVguuxxp1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkSGDDQRwZQ6Apduf2QUwxV9prHR(e8KS4Zdavyb7RahrAD98bfDyl(8P5AnWmhfi85DvnzXNpnxRRMG5vBUwxHTgxeYZsbIjwWM8PKfmKLB3pwIdxSGIowkDKXYk6(sIf14SSWFIIL)yXXSO9JyXXSebX4xvtSatw0egZYT7jlfKf85bGWSahwaqzHpwmTtjlfeWSGppaeMfczr)qCrE4EyIToKaSsiXb9O7rqvSjFkrBiEqt1Zhu0Hvsz0(nLm7(aqFIsHzE4EyADqp6EeufBYNYkOx6Oi7N1M(rTFDDGWZ6GE09iOk2KpLvqV0rrw85bGawbvacpRd6r3JGQyt(uwb9shfzhQ0)edScYfH8SaGGAdH3zbajeMTFiw(glingiXCZalpMLHCW4OLLBNgIfFiw0egZYT7jlOHLZhu0Hz5twqVv6dlOFq)ryIft)TZYg8kaOLfnHXSC7EYIYfZc82PX0Jjw(KfpJZc6h0FeMyboSSIy5GSGgwoFqrhMfvQbhIfNf0BL(Wc6h0FeMSSuaHj6owgQneENfW18jkwqo9j4qGSG(Lrqt0us5XYk1egZYNSSb1(Wc6h0FeM4I8W9WeBDibyLqsjeMTFi0gIh0u98bfDyLugTFtPHAdH3DvnP48bfD27lP6bRGpvyVEkBoaUhoI0665dk6Ww85t7hc4biWRUAnlf0FeMQ6v6JDf1VpGhQ0)e3h52tzaFUMYZEM(SwcHj2sPRQjW(k6fGqni0uAdE9ZGDihmUcZaN1dAtynaIv0dHpVRQjBaMiGarvqchpdDDbiudcnL2amrabIQ3ovXr)8h2oKdgVRZSaebLEE28rTF1Mt976WrKwxpFqrh2IpFA)qaRxpajaUN6Q1Suq)ryQQxPp2veWdW(9b(Ekd4Z1uE2Z0N1simXwkDvnb2VVcZOG(JWKfd1(utczxxxpkO)imz)SIHAF666rb9hHj7Nvv4T31rb9hHj7Nv9k9PVcZoxt5zXWLUcB1BNQn4q4ZsPRQjWUo1vRzJMVeoGVRR(e88d1OLg7JfHRxuHkbq0uCFf9WrKwxpFqrh2IpFA)qat5Ib(Ekd4Z1uE2Z0N1simXwkDvnb2VVchFJRRrqt0uiAkgaRUAnl(8P5ATDOs)tmWdi7RONzQRwZc0NGdbwPYiOjAkP8QusdQpwKDf11rb9hHj7Nvmu7txNzbick98SafFEp7RWm1vRzhhbLWfU2gkJv8k(Z2sx3JJpAE3UI4IqEwkqmXsbagtwGjlbqwm93oCDSe8OOprXf5H7Hj26qcWkHKgCcuf2QPFRHq73uYJQHDkaexKhUhMyRdjaResq4Z7QAcTPxskfaRbyc(3dZQdj0IW1lsjZaN1dAtynaIvGWN3v1KnawdWe8VhMk61tD1Aw85tZ1A7kQRR35Akpl(iT2Nk48TZsPRQjWUUaebLEE28rTF1Mt97RONzQRwZIHA89bYUIuyM6Q1SbV(zWUIu0ZSZ1uE22AIxHTkPxjzP0v1eyxN6Q1SbV(zWcUg)Eywyac1GqtPTTM4vyRs6vs2Hk9pXagq1xbcFExvt2BFETUIjciAQM8)u0ZSaebLEE28rTF1MtDDbiudcnL2amrabIQ3ovXr)8h2UIu0tD1Aw85tZ1A7qL(NyGbWUoZoxt5zXhP1(ubNVDwkDvnb2VVIZhu0zVVKQhSc(uHQRwZg86Nbl4A87HjWxSfq3VRtfIXkApQ9RouP)jgyQRwZg86Nbl4A87HzFUiKNLcetSG0yGeZndSatwcGSSsnHXS4jil6pjw(JLvelM(BNfKcteqGiUipCpmXwhsawjKeinHV31vx)OYskp0(nLq4Z7QAYgaRbyc(3dZQdjUipCpmXwhsawjK8zWN0VhMO9BkHWN3v1KnawdWe8VhMvhsCriplfiMyb9lJGMOHLydtqwGjlbqwm93olBNpnxRzzfXINGSGDeeln4WcaCPX(WINGSG0yGeZndCrE4EyIToKaSsiHkJGMOPQctq0(nLuHySIppAIGA)iWA7rTF1Hk9pXatz0011tD1A2O5lHd476Qpbp)qnAPX(yr46fbmaIMI76uxTMnA(s4a(UU6tWZpuJwASpweUErfQeartX9vOUAnl(8P5ATDfPOxac1GqtPn41pd2Hk9pXfIMI76aN1dAtynaI7ZfH8SaGGAdH3zPP9HybMSSIy5GSuqwoFqrhMft)TdxhlingiXCZalQ0NOyXvHRJLdYcHSOFiw8eKLeESarqtWJI(efxKhUhMyRdjaResWhP1(uBAFi0gIh0u98bfDyLugTFtPHAdH3DvnP4(sQEWk4tfQmAuGJiTUE(GIoSfF(0(HaM5OWJQHDkaKIEQRwZg86Nb7qL(N4cvU4UoZuxTMn41pd2vuFUiKNLcetSuaGOplFJLpXpiXINSG(b9hHjw8eKf9Nel)XYkIft)TZIZcaCPX(Ws0adS4jilXa0JUhbXYMjFk5I8W9WeBDibyLqsBnXRWwL0RKq73uIc6pct2pREgxHhvd7uaifQRwZgnFjCaFxx9j45hQrln2hlcxViGbq0uSIEGWZ6GE09iOk2KpLvqV0rr27da9jQUoZcqeu65ztkmqnCa76WrKwxpFqrhUqa2xrp1vRzhhbLWfU2gkJvC7qL(NyGbiaW9qdWpRKAWbfzXF2w66EC8rZ79vOUAn74iOeUW12qzSIBxrDDMPUAn74iOeUW12qzSIBxr9v0ZSaeQbHMsBWRFgSROUo1vRzV9516kMiGOXIppaeWugnkApQ9RouP)jgyaS4Iv0Eu7xDOs)tCHkxCXDDMHHlT6NG2MFUU20UjlLUQMa7ZfH8SuGyIfNLTZNMR1SaGoPBNLObgyzLAcJzz78P5AnlpMfxpKdgNLvelWHL4Wfl(qS4QW1XYbzbIGMGhXsmWaqUipCpmXwhsawjKGpFAUwJ2VPK6Q1SWKUDCnIMafDpmTRif9uxTMfF(0CT2ouBi8URQPUohFJRRrqt0uiGO4(CriplfWvzelXadazrLAWHybPWebeiIft)TZY25tZ1Aw8eKLBNsw2oFWRbfXf5H7Hj26qcWkHe85tZ1A0(nLcqeu65zZh1(vBoPWSZ1uEw8rATpvW5BNLsxvtGk6HWN3v1KnateqGOkiHJNHUUaeQbHMsBWRFgSROUo1vRzdE9ZGDf1xrac1GqtPnateqGO6TtvC0p)HTdv6FIbgQaOT0rgWhOx3ZX346Ae0enix0uCFfQRwZIpFAUwBhQ0)edmZrHzGZ6bTjSgaXCrE4EyIToKaSsibF(GxdkcTFtPaebLEE28rTF1Mtk6HWN3v1KnateqGOkiHJNHUUaeQbHMsBWRFgSROUo1vRzdE9ZGDf1xrac1GqtPnateqGO6TtvC0p)HTdv6FIbgGuH6Q1S4ZNMR12vKckO)imz)S6zCfMHWN3v1K9rLWHQ4Zh8AqrkmdCwpOnH1aiMlc5zPaXelBNp41GIyX0F7S4jlaOt62zjAGbwGdlFJL4Wf6azbIGMGhXsmWaqwm93olXHRHLKq2XsWXNLLyOXqwaxLrSedmaKf)y52jwOeKfyJLBNybavkV94dlQRwJLVXY25tZ1AwmbxAWeDhlnxRzb2ASahwIdxS4dXcmzbGSC(GIomxKhUhMyRdjaResWNp41GIq73usD1Awys3oUg0Kpvep(HPDf111Zm85t7hY6r1WofasHzi85DvnzFujCOk(8bVguuxxp1vRzdE9ZGDOs)tmWqJc1vRzdE9ZGDf111RN6Q1SbV(zWouP)jgyOcG2shzaFGEDphFJRRrqt0GClyX9vOUAnBWRFgSROUo1vRzhhbLWfU2gkJv8k(Z2sx3JJpAE3ouP)jgyOcG2shzaFGEDphFJRRrqt0GClyX9vOUAn74iOeUW12qzSIxXF2w66EC8rZ72vuFfbick98SiO82Jp97ROhoI0665dk6Ww85tZ1AGvWUoe(8UQMS4ZNMR1vtW8QnxRRWwRFFfMHWN3v1K9rLWHQ4Zh8Aqrk6z2SsQbhuK9(sYeCYk4qEP6NG001HJiTUE(GIoSfF(0CTgyfSpxeYZsbIjwaqcHjMLpzzdQ9Hf0pO)imXINGSGDeelfGLwZcasimzPbhwqAmqI5MbUipCpmXwhsawjKKKPAjeMO9Bk1tD1AwkO)imvXqTp2Hk9pXfsiJcRJQ3xsDD9c7(GIWkbqfdf29bfvVVKagA631f29bfHvQG9v4r1WofaIlYd3dtS1HeGvcj7UUvlHWeTFtPEQRwZsb9hHPkgQ9XouP)jUqczuyDu9(sQRRxy3huewjaQyOWUpOO69LeWqt)UUWUpOiSsfSVcpQg2Paqk6PUAn74iOeUW12qzSIBhQ0)edm0OqD1A2XrqjCHRTHYyf3UIuy2SsQbhuKf)zBPR7XXhnV31zM6Q1SJJGs4cxBdLXkUDf1NlYd3dtS1HeGvcjTLwxlHWeTFtPEQRwZsb9hHPkgQ9XouP)jUqczuyDu9(ssrVaeQbHMsBWRFgSdv6FIlenf31fGqni0uAdWebeiQE7ufh9ZFy7qL(N4crtX9766f29bfHvcGkgkS7dkQEFjbm00VRlS7dkcRub7RWJQHDkaKIEQRwZoockHlCTnugR42Hk9pXadnkuxTMDCeucx4ABOmwXTRifMnRKAWbfzXF2w66EC8rZ7DDMPUAn74iOeUW12qzSIBxr95IqEwkqmXcYbe9zbMSG0cixKhUhMyRdjaResm5Z8WPcBvsVsIlc5zbPUoS0(rywmTt3onSCqwwyILTZN2pelFYYgu7dlM2)WolpMf)ybnSC(GIomGvMLgCyHqqtCwayXixwkD8rtCwGdlMdlBNp41GIyb9lJGMOPKYJf85bGWCrE4EyIToKaSsibHpVRQj0MEjPe(8P9dv)SIHAFqlcxViLWrKwxpFqrh2IpFA)qfAoaUPHWPxPJpAIxr46fb8kxCXixawCFa30q40tD1Aw85dEnOOkvgbnrtjLxfd1(yXNhac5Ao95IqEwqQRdlTFeMft70TtdlhKfKJXVDwaxZNOyPamugR4CrE4EyIToKaSsibHpVRQj0MEjPKPXV96N12qzSIJweUErkPmYfhrADD3XhbmaArdaUxXwac84isRRNpOOdBXNpTFiGVNYa(CnLNfdx6kSvVDQ2GdHplLUQMabELTOPFFaxSvz0a8QRwZoockHlCTnugR42Hk9pXCriplfiMyb5y8BNLpzzdQ9Hf0pO)imXcCy5BSKqw2oFA)qSy61AwA)XYNhKfKgdKyUzGfpJxchIlYd3dtS1HeGvcjMg)2r73uQhf0FeMS6v6tnjKDDDuq)ryY6z8Asi7uGWN3v1K9X1GMCeuFf9oFqrN9(sQEWk4tfAoDDuq)ryYQxPp1pRaSRR9O2V6qL(NyGPCX976uxTMLc6pctvmu7JDOs)tmW8W9W0IpFA)qwczuyDu9(ssH6Q1Suq)ryQIHAFSROUokO)imz)SIHAFuygcFExvtw85t7hQ(zfd1(01PUAnBWRFgSdv6FIbMhUhMw85t7hYsiJcRJQ3xskmdHpVRQj7JRbn5iifQRwZg86Nb7qL(NyGriJcRJQ3xskuxTMn41pd2vuxN6Q1SJJGs4cxBdLXkUDfPaHpVRQjRPXV96N12qzSI31zgcFExvt2hxdAYrqkuxTMn41pd2Hk9pXfsiJcRJQ3xsCriplfiMyz78P9dXY3y5twqVv6dlOFq)rycTS8jlBqTpSG(b9hHjwGjlMdGz58bfDywGdlhKLObgyzdQ9Hf0pO)imXf5H7Hj26qcWkHe85t7hIlc5zPa4A9TplUipCpmXwhsawjKmRS6H7Hzv)4dTPxsk1CT(2NfxexeYZsbyOmwXzX0F7SG0yGeZndCrE4EyITQq)uACeucx4ABOmwXr73usD1A2Gx)myhQ0)exOYOHlc5zPaXelXa0JUhbXYMjFkzX0oLS4hlAcJz529KfZHLydJH5zbFEaimlEcYYbzzO2q4DwCwaMsaKf85bGyXXSO9JyXXSebX4xvtSahwUVKy5pwWqw(JfFMhbHzbaLf(yXBhnS4SuqaZc(8aqSqil6hcZf5H7Hj2Qc9dWkHeh0JUhbvXM8PeTH4bnvpFqrhwjLr73usD1Awvx7zGQWw1166T)jkCn9BnKfFEaiGbOuOUAnRQR9mqvyR6AD92)efU6tWtYIppaeWauk6zgi8SoOhDpcQIn5tzf0lDuK9(aqFIsHzE4EyADqp6EeufBYNYkOx6Oi7N1M(rTFk6zgi8SoOhDpcQIn5tzDNCT9(aqFIQRdeEwh0JUhbvXM8PSUtU2ouP)jUWc2VRdeEwh0JUhbvXM8PSc6LokYIppaeWkOcq4zDqp6EeufBYNYkOx6Oi7qL(NyGHgfGWZ6GE09iOk2KpLvqV0rr27da9jQ(CriplfiMybPWebeiIft)TZcsJbsm3mWIPDkzjcIXVQMyXtqwG3onMEmXIP)2zXzj2WyyEwuxTglM2PKfqchpdFIIlYd3dtSvf6hGvcjbyIacevVDQIJ(5pmA)MsMboRh0MWAaeROxpe(8UQMSbyIacevbjC8mOWSaeQbHMsBWRFgSd5GX76uxTMn41pd2vuFf9uxTMv11EgOkSvDTUE7FIcxt)wdzXNhasjavxN6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqkbO631PcXyfTh1(vhQ0)edmLlUpxeYZsbaI(S4ywUDIL2p4Jfubqw(KLBNyXzj2WyyEwm9ji0elWHft)TZYTtSGCk(8EYI6Q1yboSy6VDwCwauagtbwIbOhDpcILnt(uYINGSyY)JLgCybPXajMBgy5BS8hlMG5XIkXYkIfhL)jlQudoel3oXsaKLhZs7ZhVtGCrE4EyITQq)aSsiPTM4vyRs6vsO9Bk1Rxp1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkeq21PUAnRQR9mqvyR6AD92)efU6tWtYIppauHaY(k6zwaIGspplckV94txNzQRwZoockHlCTnugR42vu)(k6boRh0MWAae31fGqni0uAdE9ZGDOs)tCHOP4UUEbick98S5JA)QnNueGqni0uAdWebeiQE7ufh9ZFy7qL(N4crtX973VRRhi8SoOhDpcQIn5tzf0lDuKDOs)tCHakfbiudcnL2Gx)myhQ0)exOYfRiarqPNNnPWa1WbSFxNkeJv85rteu7hbwBpQ9RouP)jgyakfMfGqni0uAdE9ZGDihmExxaIGspplqXN3tfQRwZc0NGdbwPYiOjAkP8SROUUaebLEEweuE7XhfQRwZoockHlCTnugR42Hk9pXadqOqD1A2XrqjCHRTHYyf3UI4IqEwqQNbsZY25JgoGSy6VDwCwsYelXggdZZI6Q1yXtqwqAmqI5MbwECIUJfxfUowoilQellmbYf5H7Hj2Qc9dWkHKGNbsxvxTgAtVKucF(OHdiA)Ms9uxTMv11EgOkSvDTUE7FIcxt)wdzhQ0)exiG2IMUo1vRzvDTNbQcBvxRR3(NOWvFcEs2Hk9pXfcOTOPVIEbiudcnL2Gx)myhQ0)exiGURRxac1GqtPLkJGMOPQctq7qL(N4cb0kmtD1AwG(eCiWkvgbnrtjLxLsAq9XISRifbick98SafFEp73xHJVX11iOjAkuPcwmxeYZsbCvgXY25dEnOimlM(BNfNLydJH5zrD1ASOUows4XIPDkzjcc1FIILgCybPXajMBgyboSGC6tWHazzl6N)WCrE4EyITQq)aSsibF(GxdkcTFtPEQRwZQ6Apduf2QUwxV9prHRPFRHS4Zdavia76uxTMv11EgOkSvDTUE7FIcx9j4jzXNhaQqa2xrVaebLEE28rTF1MtDDbiudcnL2Gx)myhQ0)exiGURZme(8UQMSbWAaMG)9WuHzbick98SafFEp766fGqni0uAPYiOjAQQWe0ouP)jUqaTcZuxTMfOpbhcSsLrqt0us5vPKguFSi7ksraIGspplqXN3Z(9v0Zmq4zBRjEf2QKELK9(aqFIQRZSaeQbHMsBWRFgSd5GX76mlaHAqOP0gGjciqu92Pko6N)W2HCW495IqEwkGRYiw2oFWRbfHzrLAWHybPWebeiIlYd3dtSvf6hGvcj4Zh8AqrO9Bk1laHAqOP0gGjciqu92Pko6N)W2Hk9pXadnkmdCwpOnH1aiwrpe(8UQMSbyIacevbjC8m01fGqni0uAdE9ZGDOs)tmWqtFfi85DvnzdG1amb)7HzFfMbcpBBnXRWwL0RKS3ha6tukcqeu65zZh1(vBoPWmWz9G2ewdGyfuq)ryY(z1Z4kC8nUUgbnrtHMtXCriplfqyIUJfq4Xc4A(efl3oXcLGSaBSaGWrqjCHzPamugR4OLfW18jkwa6tWHazHkJGMOPKYJf4WYNSC7elAhFSGkaYcSXINSG(b9hHjUipCpmXwvOFawjKGWN3v1eAtVKuceE1HaURFOskpmAr46fPup1vRzhhbLWfU2gkJvC7qL(N4crtxNzQRwZoockHlCTnugR42vuFf9uxTMfOpbhcSsLrqt0us5vPKguFSi7qL(NyGHkaAlDK1xrp1vRzPG(JWufd1(yhQ0)exiQaOT0rwxN6Q1Suq)ryQQxPp2Hk9pXfIkaAlDK1NlYd3dtSvf6hGvcj4v2(HqBiEqt1Zhu0Hvsz0(nLgQneE3v1KIZhu0zVVKQhSc(uHkdiv4r1WofasbcFExvtwq4vhc4U(HkP8WCrE4EyITQq)aSsiPecZ2peAdXdAQE(GIoSskJ2VP0qTHW7UQMuC(GIo79Lu9GvWNku5cArJcpQg2Paqkq4Z7QAYccV6qa31pujLhMlYd3dtSvf6hGvcj4J0AFQnTpeAdXdAQE(GIoSskJ2VP0qTHW7UQMuC(GIo79Lu9GvWNkuzajGhQ0)eRWJQHDkaKce(8UQMSGWRoeWD9dvs5H5IqEwkaWyYcmzjaYIP)2HRJLGhf9jkUipCpmXwvOFawjK0GtGQWwn9BneA)MsEunStbG4IqEwq)YiOjAyj2WeKft7uYIRcxhlhKfkpAyXzjjtSeBymmplM(eeAIfpbzb7iiwAWHfKgdKyUzGlYd3dtSvf6hGvcjuze0envvycI2VPupkO)imz1R0NAsi766OG(JWKfd1(utczxxhf0FeMSEgVMeYUUo1vRzvDTNbQcBvxRR3(NOW10V1q2Hk9pXfcOTOPRtD1Awvx7zGQWw1166T)jkC1NGNKDOs)tCHaAlA66C8nUUgbnrtHaIIveGqni0uAdE9ZGDihmUcZaN1dAtynaI7ROxac1GqtPn41pd2Hk9pXfwWI76cqOgeAkTbV(zWoKdgVFxNkeJv85rteu7hbwBpQ9RouP)jgykxmxeYZsbaI(SmpQ9JfvQbhILf(tuSG0yWf5H7Hj2Qc9dWkHK2AIxHTkPxjH2VPuac1GqtPn41pd2HCW4kq4Z7QAYgaRbyc(3dtf9C8nUUgbnrtHaIIvywaIGsppB(O2VAZPUUaebLEE28rTF1MtkC8nUUgbnrdWmNI7RWSaebLEEweuE7Xhf9mlarqPNNnFu7xT5uxxac1GqtPnateqGO6TtvC0p)HTd5GX7RWmWz9G2ewdGyUiKNfKgdKyUzGft7uYIFSaikgWSedmaKLEWrdnrdl3UNSyofZsmWaqwm93olifMiGar9zX0F7W1XIgI)efl3xsS8jlXwdHG6f(yXtqw0FsSSIyX0F7SGuyIaceXY3y5pwm5ywajC8mqGCrE4EyITQq)aSsibHpVRQj0MEjPuaSgGj4FpmRQq)qlcxViLmdCwpOnH1aiwbcFExvt2aynatW)EyQOxphFJRRrqt0uiGOyf9uxTMfOpbhcSsLrqt0us5vPKguFSi7kQRZSaebLEEwGIpVN976uxTMvvdHG6f(SRifQRwZQQHqq9cF2Hk9pXatD1A2Gx)mybxJFpm73195rteu7hbwBpQ9RouP)jgyQRwZg86Nbl4A87HzxxaIGsppB(O2VAZP(k6zwaIGsppB(O2VAZPUUEo(gxxJGMObyMtXDDGWZ2wt8kSvj9kj79bG(evFf9q4Z7QAYgGjciqufKWXZqxxac1GqtPnateqGO6TtvC0p)HTd5GX73NlYd3dtSvf6hGvcjbst47DD11pQSKYdTFtje(8UQMSbWAaMG)9WSQc9JlYd3dtSvf6hGvcjFg8j97HjA)Msi85DvnzdG1amb)7Hzvf6hxeYZc6JVV0pcZYo0elLRWolXadazXhIfu(Neilr0WcMcWeKlYd3dtSvf6hGvcji85DvnH20ljLCCeaKMnkGweUErkrb9hHj7Nv9k9b4buixpCpmT4ZN2pKLqgfwhvVVKaSzuq)ryY(zvVsFa(EasaFUMYZIHlDf2Q3ovBWHWNLsxvtGaFb7JC9W9W0AA8B3siJcRJQ3xsaUylarU4isRR7o(iUiKNLc4QmILTZh8AqrywmTtjl3oXs7rTFS8ywCv46y5GSqjiAzPnugR4S8ywCv46y5GSqjiAzjoCXIpel(XcGOyaZsmWaqw(Kfpzb9d6pctOLfKgdKyUzGfTJpmlEcVDAybqbymfWSahwIdxSycU0GSarqtWJyPeoel3UNSWDkxmlXadazX0oLSehUyXeCPbt0DSSD(GxdkILeAIlYd3dtSvf6hGvcj4Zh8AqrO9Bk1tfIXk(8OjcQ9JaRTh1(vhQ0)edmZPRRN6Q1SJJGs4cxBdLXkUDOs)tmWqfaTLoYa(a96Eo(gxxJGMOb5wWI7RqD1A2XrqjCHRTHYyf3UI63VRRNJVX11iOjAamcFExvtwhhbaPzJcaV6Q1Suq)ryQIHAFSdv6FIbmi8ST1eVcBvsVsYEFaiCDOs)tGhGw0uOYkxCxNJVX11iOjAamcFExvtwhhbaPzJcaV6Q1Suq)ryQQxPp2Hk9pXageE22AIxHTkPxjzVpaeUouP)jWdqlAkuzLlUVckO)imz)S6zCf9mtD1A2Gx)myxrDDMDUMYZIpF0Wb0sPRQjW(k61ZSaeQbHMsBWRFgSROUUaebLEEwGIpVNkmlaHAqOP0sLrqt0uvHjODf1VRlarqPNNnFu7xT5uFf9mlarqPNNfbL3E8PRZm1vRzdE9ZGDf1154BCDncAIMcbef3VRR35Akpl(8rdhqlLUQMavOUAnBWRFgSRif9uxTMfF(OHdOfFEaiGvWUohFJRRrqt0uiGO4(976uxTMn41pd2vKcZuxTMDCeucx4ABOmwXTRifMDUMYZIpF0Wb0sPRQjqUiKNLcetSaGectmlFYc6TsFyb9d6pctS4jilyhbXcYzCDdWfGLwZcasimzPbhwqAmqI5MbUipCpmXwvOFawjKKKPAjeMO9Bk1tD1AwkO)imv1R0h7qL(N4cjKrH1r17lPUUEHDFqryLaOIHc7(GIQ3xsadn976c7(GIWkvW(k8OAyNcaXf5H7Hj2Qc9dWkHKDx3QLqyI2VPup1vRzPG(JWuvVsFSdv6FIlKqgfwhvVVKu0laHAqOP0g86Nb7qL(N4crtXDDbiudcnL2amrabIQ3ovXr)8h2ouP)jUq0uC)UUEHDFqryLaOIHc7(GIQ3xsadn976c7(GIWkvW(k8OAyNcaXf5H7Hj2Qc9dWkHK2sRRLqyI2VPup1vRzPG(JWuvVsFSdv6FIlKqgfwhvVVKu0laHAqOP0g86Nb7qL(N4crtXDDbiudcnL2amrabIQ3ovXr)8h2ouP)jUq0uC)UUEHDFqryLaOIHc7(GIQ3xsadn976c7(GIWkvW(k8OAyNcaXfH8SGCarFwGjlbqUipCpmXwvOFawjKyYN5Htf2QKELexeYZsbIjw2oFA)qSCqwIgyGLnO2hwq)G(JWelWHft7uYYNSatDCwqVv6dlOFq)ryIfpbzzHjwqoGOplrdmGz5BS8jlO3k9Hf0pO)imXf5H7Hj2Qc9dWkHe85t7hcTFtjkO)imz)SQxPpDDuq)ryYIHAFQjHSRRJc6pctwpJxtczxxN6Q1SM8zE4uHTkPxjzxrkuxTMLc6pctv9k9XUI666PUAnBWRFgSdv6FIbMhUhMwtJF7wczuyDu9(ssH6Q1SbV(zWUI6Zf5H7Hj2Qc9dWkHetJF7CrE4EyITQq)aSsizwz1d3dZQ(XhAtVKuQ5A9TplUiUiKNLTZh8AqrS0GdlLqeujLhlRutymll8NOyj2WyyEUipCpmX2MR13(SucF(GxdkcTFtjZMvsn4GISQU2ZavHTQR11B)tuylbCxFuebYfH8SGuhFSC7elGWJft)TZYTtSucXhl3xsSCqwCqqww59AwUDILshzSaUg)EyYYJzz)pllBRS9dXYqL(Nywkx67J0pbYYbzP0VWolLqy2(HybCn(9WKlYd3dtST5A9TplaResWRS9dH2q8GMQNpOOdRKYO9BkbcpBjeMTFi7qL(N4chQ0)ed8aeGixLbuCrE4EyITnxRV9zbyLqsjeMTFiUiUiKNLcetSSD(GxdkILdYcqefXYkILBNyPaoKxQ(jinSOUAnw(gl)XIj4sdYcHSOFiwuPgCiwAF(49prXYTtSKeYowco(yboSCqwaxLrSOsn4qSGuyIaceXf5H7Hj2IpLWNp41GIq73uAwj1GdkYEFjzcozfCiVu9tqAu0Jc6pct2pREgxHz96PUAn79LKj4KvWH8s1pbPXouP)jUqpCpmTMg)2TeYOW6O69LeGl2QSIEuq)ryY(zvfE7DDuq)ryY(zfd1(01rb9hHjREL(utczx)Uo1vRzVVKmbNScoKxQ(jin2Hk9pXf6H7HPfF(0(HSeYOW6O69LeGl2QSIEuq)ryY(zvVsF66OG(JWKfd1(utczxxhf0FeMSEgVMeYU(976mtD1A27ljtWjRGd5LQFcsJDf1VRRN6Q1SbV(zWUI66q4Z7QAYgGjciqufKWXZqFfbiudcnL2amrabIQ3ovXr)8h2oKdgxraIGsppB(O2VAZP(k6zwaIGspplqXN3ZUUaeQbHMslvgbnrtvfMG2Hk9pXfcO6RON6Q1SbV(zWUI66mlaHAqOP0g86Nb7qoy8(CriplfiMyjgGE09iiw2m5tjlM2PKLBNgILhZsczXd3JGybBYNs0YIJzr7hXIJzjcIXVQMybMSGn5tjlM(BNfaYcCyPrMOHf85bGWSahwGjlolfeWSGn5tjlyil3UFSC7eljzIfSjFkzXN5rqywaqzHpw82rdl3UFSGn5tjleYI(HWCrE4EyIT4dWkHeh0JUhbvXM8PeTH4bnvpFqrhwjLr73uYmq4zDqp6EeufBYNYkOx6Oi79bG(eLcZ8W9W06GE09iOk2KpLvqV0rr2pRn9JA)u0Zmq4zDqp6EeufBYNY6o5A79bG(evxhi8SoOhDpcQIn5tzDNCTDOs)tCHOPFxhi8SoOhDpcQIn5tzf0lDuKfFEaiGvqfGWZ6GE09iOk2KpLvqV0rr2Hk9pXaRGkaHN1b9O7rqvSjFkRGEPJIS3ha6tuCriplfiMWSGuyIaceXY3ybPXajMBgy5XSSIyboSehUyXhIfqchpdFIIfKgdKyUzGft)TZcsHjciqelEcYsC4IfFiwujn0elMtXSedmaKlYd3dtSfFawjKeGjciqu92Pko6N)WO9Bkzg4SEqBcRbqSIE9q4Z7QAYgGjciqufKWXZGcZcqOgeAkTbV(zWoKdgxHzZkPgCqr2O5lHd476Qpbp)qnAPX(01PUAnBWRFgSRO(kC8nUUgbnrdWmNIv0tD1AwkO)imv1R0h7qL(N4cvU4Uo1vRzPG(JWufd1(yhQ0)exOYf3VRtfIXkApQ9RouP)jgykxScZcqOgeAkTbV(zWoKdgVpxeYZcsHj4FpmzPbhwCTMfq4Hz529JLshicZcEnel3ofNfFOeDhld1gcVtGSyANswaq4iOeUWSuagkJvCw2DmlAcJz529Kf0WcMcywgQ0)8tuSahwUDIfGIpVNSOUAnwEmlUkCDSCqwAUwZcS1yboS4zCwq)G(JWelpMfxfUowoileYI(H4I8W9WeBXhGvcji85DvnH20ljLaHxDiG76hQKYdJweUErk1tD1A2XrqjCHRTHYyf3ouP)jUq001zM6Q1SJJGs4cxBdLXkUDf1xHzQRwZoockHlCTnugR4v8NTLUUhhF08UDfPON6Q1Sa9j4qGvQmcAIMskVkL0G6JfzhQ0)edmubqBPJS(k6PUAnlf0FeMQyO2h7qL(N4crfaTLoY66uxTMLc6pctv9k9XouP)jUqubqBPJSUUEMPUAnlf0FeMQ6v6JDf11zM6Q1Suq)ryQIHAFSRO(km7CnLNfd147dKLsxvtG95IqEwqkmb)7Hjl3UFSe2Paqyw(glXHlw8HybUo8dsSqb9hHjwoilWuhNfq4XYTtdXcCy5rLWHy52FmlM(BNLnOgFFG4I8W9WeBXhGvcji85DvnH20ljLaHxfUo8dsvkO)imHweUErk1Zm1vRzPG(JWufd1(yxrkmtD1AwkO)imv1R0h7kQFx35AkplgQX3hilLUQMa5I8W9WeBXhGvcjLqy2(HqBiEqt1Zhu0Hvsz0(nLgQneE3v1KIEQRwZsb9hHPkgQ9XouP)jUWHk9pXDDQRwZsb9hHPQEL(yhQ0)ex4qL(N4Uoe(8UQMSGWRcxh(bPkf0FeM6RyO2q4DxvtkoFqrN9(sQEWk4tfQmav4r1WofasbcFExvtwq4vhc4U(HkP8WCrE4EyIT4dWkHe8kB)qOnepOP65dk6WkPmA)Msd1gcV7QAsrp1vRzPG(JWufd1(yhQ0)ex4qL(N4Uo1vRzPG(JWuvVsFSdv6FIlCOs)tCxhcFExvtwq4vHRd)GuLc6pct9vmuBi8URQjfNpOOZEFjvpyf8PcvgGk8OAyNcaPaHpVRQjli8QdbCx)qLuEyUipCpmXw8byLqc(iT2NAt7dH2q8GMQNpOOdRKYO9BknuBi8URQjf9uxTMLc6pctvmu7JDOs)tCHdv6FI76uxTMLc6pctv9k9XouP)jUWHk9pXDDi85DvnzbHxfUo8dsvkO)im1xXqTHW7UQMuC(GIo79Lu9GvWNkuzaPcpQg2Paqkq4Z7QAYccV6qa31pujLhMlc5zPaXelfaymzbMSeazX0F7W1XsWJI(efxKhUhMyl(aSsiPbNavHTA63Ai0(nL8OAyNcaXfH8SuGyIfKtFcoeilBr)8hMft)TZINXzrdtuSqjCHANfTJVprXc6h0FeMyXtqwUjolhKf9Nel)XYkIft)TZcaCPX(WINGSG0yGeZndCrE4EyIT4dWkHeQmcAIMQkmbr73uQxp1vRzPG(JWufd1(yhQ0)exOYf31PUAnlf0FeMQ6v6JDOs)tCHkxCFfbiudcnL2Gx)myhQ0)exyblwrp1vRzJMVeoGVRR(e88d1OLg7JfHRxeWaO5uCxNzZkPgCqr2O5lHd476Qpbp)qnAPX(yjG76JIiW(976uxTMnA(s4a(UU6tWZpuJwASpweUErfQeab0f31fGqni0uAdE9ZGDihmUchFJRRrqt0uiGOyUiKNLcetSG0yGeZndSy6VDwqkmrabIqcYPpbhcKLTOF(dZINGSact0DSarqJP5pIfa4sJ9Hf4WIPDkzj2AieuVWhlMGlnileYI(HyrLAWHybPXajMBgyHqw0peMlYd3dtSfFawjKGWN3v1eAtVKukawdWe8VhMv8HweUErkzg4SEqBcRbqSce(8UQMSbWAaMG)9WurVEbiudcnLwQmk(qUUchW0ZazhQ0)edmLbKaAa3tzLb(zLudoOil(Z2sx3JJpAEVVcc4U(Oic0sLrXhY1v4aMEgO(DDo(gxxJGMOPqLaefRONzNRP8ST1eVcBvsVsYsPRQjWUo1vRzdE9ZGfCn(9WSWaeQbHMsBBnXRWwL0RKSdv6FIbmGQVce(8UQMS3(8ADfteq0un5)PON6Q1Sa9j4qGvQmcAIMskVkL0G6JfzxrDDMfGiO0ZZcu859SVIZhu0zVVKQhSc(uHQRwZg86Nbl4A87HjWxSfq31PcXyfTh1(vhQ0)edm1vRzdE9ZGfCn(9WSRlarqPNNnFu7xT5uxN6Q1SQAieuVWNDfPqD1AwvnecQx4ZouP)jgyQRwZg86Nbl4A87HjG7bia(zLudoOiB08LWb8DD1NGNFOgT0yFSeWD9rrey)(kmtD1A2Gx)myxrk6zwaIGsppB(O2VAZPUUaeQbHMsBaMiGar1BNQ4OF(dBxrDDQqmwr7rTF1Hk9pXalaHAqOP0gGjciqu92Pko6N)W2Hk9pXagq211Eu7xDOs)tmYf5QmGQyGPUAnBWRFgSGRXVhM95IqEwkqmXYTtSaGkL3E8Hft)TZIZcsJbsm3mWYT7hlpor3XsBGLSaaxASpCrE4EyIT4dWkHKXrqjCHRTHYyfhTFtj1vRzdE9ZGDOs)tCHkJMUo1vRzdE9ZGfCn(9WeyfSyfi85DvnzdG1amb)7HzfFCrE4EyIT4dWkHKaPj89UU66hvws5H2VPecFExvt2aynatW)EywXNIEMPUAnBWRFgSGRXVhMfwWI76mlarqPNNfbL3E8PFxN6Q1SJJGs4cxBdLXkUDfPqD1A2XrqjCHRTHYyf3ouP)jgyacahGj46pB0qHhtvx)OYskp79LufHRxeG7zM6Q1SQAieuVWNDfPWSZ1uEw85JgoGwkDvnb2NlYd3dtSfFawjK8zWN0VhMO9BkHWN3v1KnawdWe8VhMv8XfH8SaGQpVRQjwwycKfyYIR(6)EcZYT7hlM88y5GSOsSGDeeiln4WcsJbsm3mWcgYYT7hl3ofNfFO8yXKJpcKfauw4JfvQbhILBNk5I8W9WeBXhGvcji85DvnH20ljLWocQ2Gtn41pdOfHRxKsMfGqni0uAdE9ZGDihmExNzi85DvnzdWebeiQcs44zqraIGsppB(O2VAZPUoWz9G2ewdGyUiKNLcetywkaq0NLVXYNS4jlOFq)ryIfpbz5MNWSCqw0FsS8hlRiwm93olaWLg7dAzbPXajMBgyXtqwIbOhDpcILnt(uYf5H7Hj2IpaResARjEf2QKELeA)Msuq)ryY(z1Z4k8OAyNcaPqD1A2O5lHd476Qpbp)qnAPX(yr46fbmaAofROhi8SoOhDpcQIn5tzf0lDuK9(aqFIQRZSaebLEE2KcdudhW(kq4Z7QAYIDeuTbNAWRFgu0tD1A2XrqjCHRTHYyf3ouP)jgyacaCp0a8ZkPgCqrw8NTLUUhhF08EFfQRwZoockHlCTnugR42vuxNzQRwZoockHlCTnugR42vuFUiKNLcetSaGoPBNLTZNMR1SenWaMLVXY25tZ1AwECIUJLvexKhUhMyl(aSsibF(0CTgTFtj1vRzHjD74Aenbk6EyAxrkuxTMfF(0CT2ouBi8URQjUipCpmXw8byLqsWZaPRQRwdTPxskHpF0WbeTFtj1vRzXNpA4aAhQ0)edm0OON6Q1Suq)ryQIHAFSdv6FIlenDDQRwZsb9hHPQEL(yhQ0)exiA6RWX346Ae0enfcikMlc5zPaUkJWSedmaKfvQbhIfKcteqGiww4prXYTtSGuyIaceXsaMG)9WKLdYsyNcaXY3ybPWebeiILhZIhULR1XzXvHRJLdYIkXsWXhxKhUhMyl(aSsibF(GxdkcTFtPaebLEE28rTF1Mtkq4Z7QAYgGjciqufKWXZGIaeQbHMsBaMiGar1BNQ4OF(dBhQ0)edm0OWmWz9G2ewdGyUiKNLcetSSD(0CTMft)TZY2rATpSuaNVDS4jiljKLTZhnCarllM2PKLeYY25tZ1AwEmlRi0YsC4IfFiw(Kf0BL(Wc6h0FeMyPbhwauagtbmlWHLdYs0adSaaxASpSyANswCvicIfarXSedmaKf4WIdg53JGybBYNsw2DmlakaJPaMLHk9p)eflWHLhZYNS00pQ9ZYsmHhXYT7hlReKgwUDIfSxsSeGj4FpmXS8h6WSagHzjP1nUMLdYY25tZ1AwaxZNOybaHJGs4cZsbyOmwXrllM2PKL4Wf6azbFVwZcLGSSIyX0F7SaikgWooILgCy52jw0o(ybLgQ6ASLlYd3dtSfFawjKGpFAUwJ2VP05Akpl(iT2Nk48TZsPRQjqfMDUMYZIpF0Wb0sPRQjqfQRwZIpFAUwBhQneE3v1KIEQRwZsb9hHPQEL(yhQ0)exiGsbf0FeMSFw1R0hfQRwZgnFjCaFxx9j45hQrln2hlcxViGbq0uCxN6Q1SrZxchW31vFcE(HA0sJ9XIW1lQqLaiAkwHJVX11iOjAkequCxhi8SoOhDpcQIn5tzf0lDuKDOs)tCHaQUopCpmToOhDpcQIn5tzf0lDuK9ZAt)O2V(kcqOgeAkTbV(zWouP)jUqLlMlc5zPaXelBNp41GIybaDs3olrdmGzXtqwaxLrSedmaKft7uYcsJbsm3mWcCy52jwaqLYBp(WI6Q1y5XS4QW1XYbzP5AnlWwJf4WsC4cDGSe8iwIbgaYf5H7Hj2IpaResWNp41GIq73usD1Awys3oUg0Kpvep(HPDf11PUAnlqFcoeyLkJGMOPKYRsjnO(yr2vuxN6Q1SbV(zWUIu0tD1A2XrqjCHRTHYyf3ouP)jgyOcG2shzaFGEDphFJRRrqt0GClyX9bCbb(Z1uE2KmvlHW0sPRQjqfMnRKAWbfzXF2w66EC8rZ7kuxTMDCeucx4ABOmwXTROUo1vRzdE9ZGDOs)tmWqfaTLoYa(a96Eo(gxxJGMOb5wWI731PUAn74iOeUW12qzSIxXF2w66EC8rZ72vuxNzQRwZoockHlCTnugR42vKcZcqOgeAkTJJGs4cxBdLXkUDihmExNzbick98SiO82Jp976C8nUUgbnrtHaIIvqb9hHj7NvpJZfH8Sy(jolhKLshiILBNyrLWhlWglBNpA4aYIACwWNha6tuS8hlRiwaURpaKoolFYINXzb9d6pctSOUowaGln2hwECES4QW1XYbzrLyjAGHabYf5H7Hj2IpaResWNp41GIq73u6CnLNfF(OHdOLsxvtGkmBwj1GdkYEFjzcozfCiVu9tqAu0tD1Aw85JgoG2vuxNJVX11iOjAkequCFfQRwZIpF0Wb0IppaeWkOIEQRwZsb9hHPkgQ9XUI66uxTMLc6pctv9k9XUI6RqD1A2O5lHd476Qpbp)qnAPX(yr46fbmacOlwrVaeQbHMsBWRFgSdv6FIlu5I76mdHpVRQjBaMiGarvqchpdkcqeu65zZh1(vBo1Nlc5zb9X3x6hHzzhAILYvyNLyGbGS4dXck)tcKLiAybtbycYf5H7Hj2IpaResq4Z7QAcTPxsk54iainBuaTiC9IuIc6pct2pR6v6dWdOqUE4EyAXNpTFilHmkSoQEFjbyZOG(JWK9ZQEL(a89aKa(CnLNfdx6kSvVDQ2GdHplLUQMab(c2h56H7HP1043ULqgfwhvVVKaCXwZbnixCeP11DhFeGl2IgG)CnLNn9BneUQ6ApdKLsxvtGCriplfWvzelBNp41GIy5twCwa0agtbw2GAFyb9d6pctOLfqyIUJfnDS8hlrdmWcaCPX(WsVB3pwEml7EcQjqwuJZc93onSC7elBNpnxRzr)jXcCy52jwIbgawiGOyw0FsS0GdlBNp41GI6JwwaHj6owGiOX08hXINSaGoPBNLObgyXtqw00XYTtS4Qqeel6pjw29eutSSD(OHdixKhUhMyl(aSsibF(GxdkcTFtjZMvsn4GIS3xsMGtwbhYlv)eKgf9uxTMnA(s4a(UU6tWZpuJwASpweUEradGa6I76uxTMnA(s4a(UU6tWZpuJwASpweUEradGOPyfNRP8S4J0AFQGZ3olLUQMa7ROhf0FeMSFwXqTpkC8nUUgbnrdGr4Z7QAY64iainBua4vxTMLc6pctvmu7JDOs)tmGbHNTTM4vyRs6vs27daHRdv6Fc8a0IMcbuf31rb9hHj7Nv9k9rHJVX11iOjAamcFExvtwhhbaPzJcaV6Q1Suq)ryQQxPp2Hk9pXageE22AIxHTkPxjzVpaeUouP)jWdqlAkequCFfMPUAnlmPBhxJOjqr3dt7ksHzNRP8S4ZhnCaTu6QAcurVaeQbHMsBWRFgSdv6FIleq31HHlT6NG2BFETUIjciASu6QAcuH6Q1S3(8ADfteq0yXNhacyfSGa4EZkPgCqrw8NTLUUhhF08oWJM(kApQ9RouP)jUqLlUyfTh1(vhQ0)edmawCX9v0laHAqOP0c0NGdbwXr)8h2ouP)jUqaDxNzbick98SafFEp7ZfH8SuGyIfaKqyIz5twqVv6dlOFq)ryIfpbzb7iiwqoJRBaUaS0AwaqcHjln4WcsJbsm3mWINGSGC6tWHazb9lJGMOPKYJlYd3dtSfFawjKKKPAjeMO9Bk1tD1AwkO)imv1R0h7qL(N4cjKrH1r17lPUUEHDFqryLaOIHc7(GIQ3xsadn976c7(GIWkvW(k8OAyNcaPaHpVRQjl2rq1gCQbV(zGlYd3dtSfFawjKS76wTect0(nL6PUAnlf0FeMQ6v6JDOs)tCHeYOW6O69LKcZcqeu65zbk(8E211tD1AwG(eCiWkvgbnrtjLxLsAq9XISRifbick98SafFEp7311lS7dkcReavmuy3huu9(scyOPFxxy3huewPc21PUAnBWRFgSRO(k8OAyNcaPaHpVRQjl2rq1gCQbV(zqrp1vRzhhbLWfU2gkJvC7qL(NyG1dnayac8ZkPgCqrw8NTLUUhhF08EFfQRwZoockHlCTnugR42vuxNzQRwZoockHlCTnugR42vuFUipCpmXw8byLqsBP11simr73uQN6Q1Suq)ryQQxPp2Hk9pXfsiJcRJQ3xskmlarqPNNfO4Z7zxxp1vRzb6tWHaRuze0enLuEvkPb1hlYUIueGiO0ZZcu859SFxxVWUpOiSsauXqHDFqr17ljGHM(DDHDFqryLkyxN6Q1SbV(zWUI6RWJQHDkaKce(8UQMSyhbvBWPg86Nbf9uxTMDCeucx4ABOmwXTdv6FIbgAuOUAn74iOeUW12qzSIBxrkmBwj1GdkYI)ST01944JM376mtD1A2XrqjCHRTHYyf3UI6ZfH8SuGyIfKdi6ZcmzjaYf5H7Hj2IpaResm5Z8WPcBvsVsIlc5zPaXelBNpTFiwoilrdmWYgu7dlOFq)rycTSG0yGeZndSS7yw0egZY9Lel3UNS4SGCm(TZcHmkSoIfn1owGdlWuhNf0BL(Wc6h0FeMy5XSSI4I8W9WeBXhGvcj4ZN2peA)Msuq)ryY(zvVsF66OG(JWKfd1(utczxxhf0FeMSEgVMeYUUUEQRwZAYN5Htf2QKELKDf11HJiTUU74JawXwZbnkmlarqPNNfbL3E8PRdhrADD3XhbSITMJIaebLEEweuE7XN(kuxTMLc6pctv9k9XUI666PUAnBWRFgSdv6FIbMhUhMwtJF7wczuyDu9(ssH6Q1SbV(zWUI6ZfH8SuGyIfKJXVDwG3onMEmXIP9pSZYJz5tw2GAFyb9d6pctOLfKgdKyUzGf4WYbzjAGbwqVv6dlOFq)ryIlYd3dtSfFawjKyA8BNlc5zPa4A9TplUipCpmXw8byLqYSYQhUhMv9Jp0MEjPuZ16BFwgB4ikyetLlgGgNXzya]] )


end