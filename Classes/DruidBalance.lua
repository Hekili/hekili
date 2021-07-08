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


    spec:RegisterPack( "Balance", 20210708, [[devkAfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlac7Is)cIyyIOogjYYaqptOIPrrfxdsX2ai5BaenoaqNdqfRdGuZdq5EKO2Nqv)dIkkDqHIwOqLEieLjkukDrivzJcLIpcrfvJeIkkojfvALIiVeIkYmHuv3eakTtHs(jau1qbGSuaO4PkLPsrvxvOuTvaOsFfIkmwaG9sH)kQbtCyQwmj9ybtgOlJSzP8ziz0kvNwLvdav8Aaz2K62sLDl53GgUqooGkTCfphQPRQRRKTdHVtrgpePZlcRxOW8fP9JAdLmmVXgO)KrSayYauPKbKjdaTkLmaJJsakJTprezSf5bGCuKXw5DKXwCDTxbYylYtOHoOH5n2WW1eiJT9)JWaAKGevx7vGae4RlyrD)(s1EqKexx7vGaeBxhYqshOD)70iNTDAszvx7vGSpsFJn11PFZTmun2a9NmIfatgGkLmGmzaOvPKbyCukogB(63HJX221HmJT9deKkdvJnqchm2IRR9kqSeBN1bYjL0sNGfaiAzbGjdqL4K4Kq2UxOimGMtcqWsmbbjqw2GAFyjUK3z5KaeSGSDVqrGS8(GI(81yj4ycZYdzjKiOP87dk6XwojablayOoiccKLvvuGWyFsWccFoxvtyw6DwYIwwIgcrg)(GxdkIfar8Senecl(9bVguuFlNeGGLyIaEGSenuWX)vOyb5y8FNLRXY9OdZYVtSyAGfkwqVG(IWKLtcqWcawhiIfKbleqGiw(DILTOBUhZIZI((xtS0bhILMMq6PQjw6DnwsaxSS7Gf6Ew2VNL7zbFDl97fbxyDcwmD)olXfaFmnplaMfKrAc)NRzjM6dv1r1JwwUhDGSGb6I6B5KaeSaG1bIyPdIFwqx7qT)5H68RWOJfCGkFoiMfpksNGLhYIkeJzPDO2FmlWsNWASPp8JnmVXgi18L(nmVrSuYW8gBE4pyzSHHAFYQK3zSrLRQjqJ4A8gXcGgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzSHJiTo)(GIESf)(0CTML4zrjwuWspwmJL31u9w87JgoGwQCvnbYsAklVRP6T4N0AFYGZ1ElvUQMazPplPPSGJiTo)(GIESf)(0CTML4zbGgBGeomx0FWYyBJEmlXeIESalwIdGzX097W1Zc4CTNfVazX097SS9(OHdilEbYcabmlWFNgthMm2q4tU8oYy7WzhsgVrSIJH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgB4isRZVpOOhBXVpTBiwINfLm2ajCyUO)GLX2g9ywcAYrqSyANkw2EFA3qSe8IL97zbGaML3hu0JzX0(f2z5WSmKMq41ZsdoS87elOxqFryILhYIkXs0qnAgcKfVazX0(f2zPDAnnS8qwco(n2q4tU8oYy7W5GMCeKXBelZXW8gBu5QAc0iUgBE4pyzSPsdMgGUcLXgiHdZf9hSm2IDmXsCPbtdqxHIft3VZcYIjsm3kWcCyXBpnSGmyHaceXYvSGSyIeZTcgBH5EAo3yRhlMXsaIGkVEBDO2)CZjwstzXmwcqOgeAQSbyHaceL)DkJJU5ESDfXsFwuWI6Q1SbpFvWouNFfML4zrj0WIcwuxTMDCeubx4CBOkgjSd15xHzbySyoSOGfZyjarqLxVfbv)EIHL0uwcqeu51Brq1VNyyrblQRwZg88vb7kIffSOUAn74iOcUW52qvmsyxrSOGLESOUAn74iOcUW52qvmsyhQZVcZcWyrjLybqWcAyb4zzwf1GdkYIVQT059e4NMZTu5QAcKL0uwuxTMn45Rc2H68RWSamwusjwstzrjwqcl4isRZ7o(jwaglkzrdAyPVXBel0yyEJnQCvnbAexJTWCpnNBSPUAnBWZxfSd15xHzjEwucnSOGLESyglZQOgCqrw8vTLoVNa)0CULkxvtGSKMYI6Q1SJJGk4cNBdvXiHDOo)kmlaJfLaKSOGf1vRzhhbvWfo3gQIrc7kIL(SKMYIkeJzrblTd1(NhQZVcZcWybGOXydKWH5I(dwgBai4ZIP73zXzbzXejMBfy539NLdxO7zXzbaT0yFyjAGbwGdlM2PILFNyPDO2FwomlUkC9S8qwOc0yZd)blJTi4FWY4nIfGYW8gBu5QAc0iUgBWiJnm9gBE4pyzSHWNZv1KXgcxViJTaDAw6XspwAhQ9ppuNFfMfablkHgwaeSeGqni0uzdE(QGDOo)kml9zbjSOeamzw6ZIYSeOtZspw6Xs7qT)5H68RWSaiyrj0WcGGfLayYSaiyjaHAqOPYgGfciqu(3Pmo6M7X2H68RWS0NfKWIsaWKzPplkyXmwg)aZecQERdcITesp8JzjnLLaeQbHMkBWZxfSd15xHzjEwU6PjcQ9NaZTd1(NhQZVcZsAklbiudcnv2aSqabIY)oLXr3Cp2ouNFfML4z5QNMiO2Fcm3ou7FEOo)kmlacwukzwstzXmwcqeu51BRd1(NBoXsAklE4pyzdWcbeik)7ughDZ9yl4HDvnbASbs4WCr)blJnK56Ws7pHzX0o970WYcFfkwqgSqabIyPGMyX0P1S4An0eljGlwEil4)0Awco(z53jwWEhXI3bx1ZcSXcYGfciqeGrwmrI5wbwco(XgBi8jxEhzSfGfciqugKWjQGXBelaPH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgB9y59bf92)6O8dZGhXs8SOeAyjnLLXpWmHGQ36GGy7vSeplOjzw6ZIcw6Xspw6XcbCxxuebAPUOed56mCalVcelkyPhl9yjaHAqOPYsDrjgY1z4awEfi7qD(vywaglkbOsML0uwcqeu51Brq1VNyyrblbiudcnvwQlkXqUodhWYRazhQZVcZcWyrjafGKfaZspwusjwaEwMvrn4GIS4RAlDEpb(P5ClvUQMazPpl9zrblMXsac1GqtLL6IsmKRZWbS8kq2HCWeS0NL(SKMYspwiG76IIiqlgU0A6)RqLNLAcwuWspwmJLaebvE926qT)5MtSKMYsac1GqtLfdxAn9)vOYZsnrooMdAaGjRKDOo)kmlaJfLuYCyPpl9zjnLLESeGqni0uzvPbtdqxHYoKdMGL0uwmJLXdK9hOwZsFwuWspw6XcbCxxuebAVchM17QAkdCxE9RUmiH4celkyjaHAqOPYEfomR3v1ug4U86xDzqcXfi7qoycw6ZsAkl9yPhli85CvnzHvEHP8pxbe9SOmlkXsAkli85CvnzHvEHP8pxbe9SOmlXHL(SOGLES8ZvarV9vYoKdMihGqni0uXsAkl)Cfq0BFLSbiudcnv2H68RWSeplx90eb1(tG52HA)Zd15xHzbqWIsjZsFwstzbHpNRQjlSYlmL)5kGONfLzbGSOGLES8ZvarV9bODihmroaHAqOPIL0uw(5kGO3(a0gGqni0uzhQZVcZs8SC1tteu7pbMBhQ9ppuNFfMfablkLml9zjnLfe(CUQMSWkVWu(NRaIEwuMLKzPpl9zPplPPSeGiOYR3cuI58IL(SKMYIkeJzrblTd1(NhQZVcZcWyrD1A2GNVkybxJ)hSm2ajCyUO)GLXwSJjqwEilGK2tWYVtSSWokIfyJfKftKyUvGft7uXYcFfkwaHlvnXcSyzHjw8cKLOHqq1ZYc7OiwmTtflEXIdcYcHGQNLdZIRcxplpKfWJm2q4tU8oYylaMdWc8(dwgVrSaGgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzSzgly4sREfO93NtRZyIaIglvUQMazjnLL2HA)Zd15xHzjEwayYjZsAklQqmMffS0ou7FEOo)kmlaJfaIgwaml9yXCsMfablQRwZ(7ZP1zmrarJf)EaiwaEwail9zjnLf1vRz)9506mMiGOXIFpaelXZsCaGSaiyPhlZQOgCqrw8vTLoVNa)0CULkxvtGSa8SGgw6BSHWNC5DKX2VpNwNXebenzt(9gVrSaogM3yJkxvtGgX1ydKWH5I(dwgBXoMyb96IsmKRzba)awEfiwayYykGzrLAWHyXzbzXejMBfyzHjRXw5DKXg1fLyixNHdy5vGm2cZ90CUXwac1GqtLn45Rc2H68RWSamwayYSOGLaeQbHMkBawiGar5FNY4OBUhBhQZVcZcWybGjZIcw6XccFoxvt2FFoToJjciAYM87zjnLf1vRz)9506mMiGOXIFpaelXZsCsMfaZspwMvrn4GIS4RAlDEpb(P5ClvUQMazb4zbqXsFw6ZsAklQqmMffS0ou7FEOo)kmlaJL4ain28WFWYyJ6IsmKRZWbS8kqgVrSukzdZBSrLRQjqJ4ASbs4WCr)blJTyhtSSbxAn9xHIfaml1eSaOWuaZIk1GdXIZcYIjsm3kWYctwJTY7iJnmCP10)xHkpl1egBH5EAo3ylaHAqOPYg88vb7qD(vywaglakwuWIzSeGiOYR3IGQFpXWIcwmJLaebvE926qT)5MtSKMYsaIGkVEBDO2)CZjwuWsac1GqtLnaleqGO8VtzC0n3JTd15xHzbySaOyrbl9ybHpNRQjBawiGarzqcNOcSKMYsac1GqtLn45Rc2H68RWSamwauS0NL0uwcqeu51Brq1VNyyrbl9yXmwMvrn4GIS4RAlDEpb(P5ClvUQMazrblbiudcnv2GNVkyhQZVcZcWybqXsAklQRwZoocQGlCUnufJe2H68RWSamwuYCybWS0Jf0WcWZcbCxxuebAVc)Zk8WbNbpexrzvsRzPplkyrD1A2XrqfCHZTHQyKWUIyPplPPSOcXywuWs7qT)5H68RWSamwaiAm28WFWYyddxAn9)vOYZsnHXBelLuYW8gBu5QAc0iUgBE4pyzSDfomR3v1ug4U86xDzqcXfiJTWCpnNBSPUAnBWZxfSd15xHzjEwucnSOGLESyglZQOgCqrw8vTLoVNa)0CULkxvtGSKMYI6Q1SJJGk4cNBdvXiHDOo)kmlaJfLailaMLESehwaEwuxTMvvdHG6f(TRiw6ZcGzPhl9ybqYcGGf0WcWZI6Q1SQAieuVWVDfXsFwaEwiG76IIiq7v4FwHho4m4H4kkRsAnl9zrblQRwZoocQGlCUnufJe2vel9zjnLfvigZIcwAhQ9ppuNFfMfGXcarJXw5DKX2v4WSExvtzG7YRF1LbjexGmEJyPeanmVXgvUQManIRXgiHdZf9hSm2m)(Hz5WS4Sm(VtdlK2vHJ)elM8eS8qw6CGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwmD)olilMiXCRalEbYcYGfciqelEbYYctS87elaSazbRHplWILailxJfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhBSfM7P5CJne(CUQMSWkVWu(NRaIEwuMfaYIcwmJLFUci6TpaTd5GjYbiudcnvSKMYspwq4Z5QAYcR8ct5FUci6zrzwuIL0uwq4Z5QAYcR8ct5FUci6zrzwIdl9zrbl9yrD1A2GNVkyxrSOGLESyglbicQ86TiO63tmSKMYI6Q1SJJGk4cNBdvXiHDOo)kmlaMLESGgwaEwMvrn4GIS4RAlDEpb(P5ClvUQMazPplatzw(5kGO3(kzvxTwgCn(FWIffSOUAn74iOcUW52qvmsyxrSKMYI6Q1SJJGk4cNBdvXirgFvBPZ7jWpnNBxrS0NL0uwcqOgeAQSbpFvWouNFfMfaZcazjEw(5kGO3(kzdqOgeAQSGRX)dwSOGLESyglbicQ86T1HA)ZnNyjnLfZybHpNRQjBawiGarzqcNOcS0NffSyglbicQ86TaLyoVyjnLLaebvE926qT)5MtSOGfe(CUQMSbyHaceLbjCIkWIcwcqOgeAQSbyHaceL)DkJJU5ESDfXIcwmJLaeQbHMkBWZxfSRiwuWspw6XI6Q1SuqFrykRxLp2H68RWSeplkLmlPPSOUAnlf0xeMYyO2h7qD(vywINfLsML(SOGfZyzwf1GdkYQ6AVcug2YUwN)9RqHTu5QAcKL0uw6XI6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqSOmlOHL0uwuxTMv11EfOmSLDTo)7xHcN9j4fzXVhaIfLzbaYsFw6ZsAklQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfXsFwstzrfIXSOGL2HA)Zd15xHzbySaWKzjnLfe(CUQMSWkVWu(NRaIEwuMLKn2WA4Jn2(5kGOxjJnp8hSm2(5kGOxjJ3iwkfhdZBSrLRQjqJ4AS5H)GLX2pxbe9a0ylm3tZ5gBi85CvnzHvEHP8pxbe9SyMYSaqwuWIzS8ZvarV9vYoKdMihGqni0uXsAkli85CvnzHvEHP8pxbe9SOmlaKffS0Jf1vRzdE(QGDfXIcw6XIzSeGiOYR3IGQFpXWsAklQRwZoocQGlCUnufJe2H68RWSayw6XcAyb4zzwf1GdkYIVQT059e4NMZTu5QAcKL(SamLz5NRaIE7dqR6Q1YGRX)dwSOGf1vRzhhbvWfo3gQIrc7kIL0uwuxTMDCeubx4CBOkgjY4RAlDEpb(P5C7kIL(SKMYsac1GqtLn45Rc2H68RWSaywailXZYpxbe92hG2aeQbHMkl4A8)GflkyPhlMXsaIGkVEBDO2)CZjwstzXmwq4Z5QAYgGfciqugKWjQal9zrblMXsaIGkVElqjMZlwuWspwmJf1vRzdE(QGDfXsAklMXsaIGkVElcQ(9edl9zjnLLaebvE926qT)5MtSOGfe(CUQMSbyHaceLbjCIkWIcwcqOgeAQSbyHaceL)DkJJU5ESDfXIcwmJLaeQbHMkBWZxfSRiwuWspw6XI6Q1SuqFrykRxLp2H68RWSeplkLmlPPSOUAnlf0xeMYyO2h7qD(vywINfLsML(SOGfZyzwf1GdkYQ6AVcug2YUwN)9RqHTu5QAcKL0uw6XI6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqSOmlOHL0uwuxTMv11EfOmSLDTo)7xHcN9j4fzXVhaIfLzbaYsFw6ZsFwstzrD1AwGUcCiWm1fbnrthvFMkAqDXGSRiwstzrfIXSOGL2HA)Zd15xHzbySaWKzjnLfe(CUQMSWkVWu(NRaIEwuMLKn2WA4Jn2(5kGOhGgVrSuYCmmVXgvUQManIRXgiHdZf9hSm2IDmHzX1AwG)onSalwwyIL7PomlWILaOXMh(dwgBlmLVN6WgVrSucngM3yJkxvtGgX1ydKWH5I(dwgBXwkCGelE4pyXI(WplQoMazbwSGVF5)blKOjuh2yZd)blJTzvzp8hSY6d)gB4FUWBelLm2cZ90CUXgcFoxvt2dNDizSPp8NlVJm2Ciz8gXsjaLH5n2OYv1eOrCn2cZ90CUX2SkQbhuKv11EfOmSLDTo)7xHcBjG76IIiqJn8px4nILsgBE4pyzSnRk7H)GvwF43ytF4pxEhzSPc934nILsasdZBSrLRQjqJ4AS5H)GLX2SQSh(dwz9HFJn9H)C5DKXg(nEJ3ytf6VH5nILsgM3yJkxvtGgX1yZd)blJTXrqfCHZTHQyKWydKWH5I(dwgBXMHQyKGft3VZcYIjsm3kySfM7P5CJn1vRzdE(QGDOo)kmlXZIsOX4nIfanmVXgvUQManIRXMh(dwgBoOh9hckJn5tNXwirqt53hu0JnILsgBH5EAo3ytD1Awvx7vGYWw2168VFfkCU8FnKf)EaiwaglaqwuWI6Q1SQU2RaLHTSR15F)ku4SpbVil(9aqSamwaGSOGLESyglGW36GE0FiOm2KpDzqVZrr2)caDfkwuWIzS4H)GL1b9O)qqzSjF6YGENJISxLB6d1(ZIcw6XIzSacFRd6r)HGYyt(0L3jxB)la0vOyjnLfq4BDqp6peugBYNU8o5A7qD(vywINL4WsFwstzbe(wh0J(dbLXM8Pld6DokYIFpaelaJL4WIcwaHV1b9O)qqzSjF6YGENJISd15xHzbySGgwuWci8ToOh9hckJn5txg07CuK9VaqxHIL(gBGeomx0FWYyl2XelXe0J(dbXYMjF6yX0ovS4plAcJz539IfZHL4cJP5zb)EaimlEbYYdzzO2q4DwCwaMYaKf87bGyXXSO9NyXXSebX4tvtSahw(RJy5EwWqwUNfFMdbHzbaNf(zXBpnS4SehaZc(9aqSqin6gcB8gXkogM3yJkxvtGgX1yZd)blJTaSqabIY)oLXr3Cp2ydKWH5I(dwgBXoMybzWcbeiIft3VZcYIjsm3kWIPDQyjcIXNQMyXlqwG)onMomXIP73zXzjUWyAEwuxTglM2PIfqcNOcxHYylm3tZ5gBMXc4SoqBbZbqmlkyPhl9ybHpNRQjBawiGarzqcNOcSOGfZyjaHAqOPYg88vb7qoycwstzrD1A2GNVkyxrS0NffS0Jf1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGyrzwaGSKMYI6Q1SQU2RaLHTSR15F)ku4SpbVil(9aqSOmlaqw6ZsAklQqmMffS0ou7FEOo)kmlaJfLsML(gVrSmhdZBSrLRQjqJ4AS5H)GLXwBnjYWwM0RIm2ajCyUO)GLXwSbIES4yw(DIL2n4NfubqwUILFNyXzjUWyAEwmDfi0elWHft3VZYVtSGCkXCEXI6Q1yboSy6(DwCwaGagtbwIjOh9hcILnt(0XIxGSyYVNLgCybzXejMBfy5ASCplMG1ZIkXYkIfhLFflQudoel)oXsaKLdZs7QdVtGgBH5EAo3yRhl9yPhlQRwZQ6AVcug2YUwN)9RqHZL)RHS43daXs8SaOyjnLf1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGyjEwauS0NffS0JfZyjarqLxVfbv)EIHL0uwmJf1vRzhhbvWfo3gQIrc7kIL(S0NffS0JfWzDG2cMdGywstzjaHAqOPYg88vb7qD(vywINf0KmlPPS0JLaebvE926qT)5MtSOGLaeQbHMkBawiGar5FNY4OBUhBhQZVcZs8SGMKzPpl9zPplPPS0Jfq4BDqp6peugBYNUmO35Oi7qD(vywINfailkyjaHAqOPYg88vb7qD(vywINfLsMffSeGiOYR3wuyGA4aYsFwstzrfIXSOGLREAIGA)jWC7qT)5H68RWSamwaGSOGfZyjaHAqOPYg88vb7qoycwstzjarqLxVfOeZ5flkyrD1AwGUcCiWm1fbnrthvVDfXsAklbicQ86TiO63tmSOGf1vRzhhbvWfo3gQIrc7qD(vywaglahwuWI6Q1SJJGk4cNBdvXiHDfz8gXcngM3yJkxvtGgX1yZd)blJTGxbsNvxTMXwyUNMZn26XI6Q1SQU2RaLHTSR15F)ku4C5)Ai7qD(vywINfaPfnSKMYI6Q1SQU2RaLHTSR15F)ku4SpbVi7qD(vywINfaPfnS0NffS0JLaeQbHMkBWZxfSd15xHzjEwaKSKMYspwcqOgeAQSuxe0enzvybAhQZVcZs8SaizrblMXI6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzxrSOGLaebvE9wGsmNxS0NL(SOGfh)JRZrqt0Ws8kZsCs2ytD1A5Y7iJn87JgoGgBGeomx0FWYydzEfinlBVpA4aYIP73zXzPitSexymnplQRwJfVazbzXejMBfy5Wf6EwCv46z5HSOsSSWeOXBelaLH5n2OYv1eOrCn28WFWYyd)(GxdkYydKWH5I(dwgBX2vxelBVp41GIWSy6(DwCwIlmMMNf1vRXI66zPGplM2PILiiuFfkwAWHfKftKyUvGf4WcYPRahcKLTOBUhBSfM7P5CJTESOUAnRQR9kqzyl7AD(3Vcfox(VgYIFpaelXZcazjnLf1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGyjEwail9zrbl9yjarqLxVTou7FU5elPPSeGqni0uzdE(QGDOo)kmlXZcGKL0uwmJfe(CUQMSbWCawG3FWIffSyglbicQ86TaLyoVyjnLLESeGqni0uzPUiOjAYQWc0ouNFfML4zbqYIcwmJf1vRzb6kWHaZuxe0enDu9zQOb1fdYUIyrblbicQ86TaLyoVyPpl9zrbl9yXmwaHVTTMezylt6vr2)caDfkwstzXmwcqOgeAQSbpFvWoKdMGL0uwmJLaeQbHMkBawiGar5FNY4OBUhBhYbtWsFJ3iwasdZBSrLRQjqJ4AS5H)GLXg(9bVguKXgiHdZf9hSm2ITRUiw2EFWRbfHzrLAWHybzWcbeiYylm3tZ5gB9yjaHAqOPYgGfciqu(3Pmo6M7X2H68RWSamwqdlkyXmwaN1bAlyoaIzrbl9ybHpNRQjBawiGarzqcNOcSKMYsac1GqtLn45Rc2H68RWSamwqdl9zrbli85CvnzdG5aSaV)Gfl9zrblMXci8TT1KidBzsVkY(xaORqXIcwcqeu51BRd1(NBoXIcwmJfWzDG2cMdGywuWcf0xeMSxL9kblkyXX)46Ce0enSeplMtYgVrSaGgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzS1Jf1vRzhhbvWfo3gQIrc7qD(vywINf0WsAklMXI6Q1SJJGk4cNBdvXiHDfXsFwuWspwuxTMfORahcmtDrqt00r1NPIguxmi7qD(vywaglOcG2ohPS0NffS0Jf1vRzPG(IWugd1(yhQZVcZs8SGkaA7CKYsAklQRwZsb9fHPSEv(yhQZVcZs8SGkaA7CKYsFJnqchMl6pyzSfBHf6EwaHplGR5kuS87elubYcSXcaghbvWfMLyZqvmsGwwaxZvOybORahcKfQlcAIMoQEwGdlxXYVtSOD8ZcQailWglEXc6f0xeMm2q4tU8oYyde(5HaURBOoQESXBelGJH5n2OYv1eOrCn28WFWYydVQ2nKXwyUNMZn2gQneE3v1elky59bf92)6O8dZGhXs8SOeGIffS4r5WofaIffSGWNZv1Kfe(5HaURBOoQESXwirqt53hu0JnILsgVrSukzdZBSrLRQjqJ4AS5H)GLXwhewTBiJTWCpnNBSnuBi8URQjwuWY7dk6T)1r5hMbpIL4zrP4yrdlkyXJYHDkaelkybHpNRQjli8ZdbCx3qDu9yJTqIGMYVpOOhBelLmEJyPKsgM3yJkxvtGgX1yZd)blJn8tATp5M2hYylm3tZ5gBd1gcV7QAIffS8(GIE7FDu(HzWJyjEwucqXcGzzOo)kmlkyXJYHDkaelkybHpNRQjli8ZdbCx3qDu9yJTqIGMYVpOOhBelLmEJyPeanmVXgvUQManIRXMh(dwgBn4eOmSLl)xdzSbs4WCr)blJTydmwSalwcGSy6(D46zj4rrxHYylm3tZ5gBEuoStbGmEJyPuCmmVXgvUQManIRXMh(dwgBuxe0enzvybASbs4WCr)blJn0RlcAIgwIlSazX0ovS4QW1ZYdzHQNgwCwkYelXfgtZZIPRaHMyXlqwWocILgCybzXejMBfm2cZ90CUXwpwOG(IWKvVkFYfH0NL0uwOG(IWKfd1(KlcPplPPSqb9fHjRxjYfH0NL0uwuxTMv11EfOmSLDTo)7xHcNl)xdzhQZVcZs8SaiTOHL0uwuxTMv11EfOmSLDTo)7xHcN9j4fzhQZVcZs8SaiTOHL0uwC8pUohbnrdlXZcWjzwuWsac1GqtLn45Rc2HCWeSOGfZybCwhOTG5aiML(SOGLESeGqni0uzdE(QGDOo)kmlXZsCsML0uwcqOgeAQSbpFvWoKdMGL(SKMYIkeJzrblx90eb1(tG52HA)Zd15xHzbySOuYgVrSuYCmmVXgvUQManIRXMh(dwgBT1KidBzsVkYydKWH5I(dwgBXgi6XYCO2FwuPgCiww4RqXcYIPXwyUNMZn2cqOgeAQSbpFvWoKdMGffSGWNZv1KnaMdWc8(dwSOGLES44FCDocAIgwINfGtYSOGfZyjarqLxVTou7FU5elPPSeGiOYR3whQ9p3CIffS44FCDocAIgwaglMtYS0NffSyglbicQ86TiO63tmSOGLESyglbicQ86T1HA)ZnNyjnLLaeQbHMkBawiGar5FNY4OBUhBhYbtWsFwuWIzSaoRd0wWCaeB8gXsj0yyEJnQCvnbAexJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXMzSaoRd0wWCaeZIcwq4Z5QAYgaZbybE)blwuWspw6XIJ)X15iOjAyjEwaojZIcw6XI6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzxrSKMYIzSeGiOYR3cuI58IL(SKMYI6Q1SQAieuVWVDfXIcwuxTMvvdHG6f(Td15xHzbySOUAnBWZxfSGRX)dwS0NL0uwU6PjcQ9NaZTd1(NhQZVcZcWyrD1A2GNVkybxJ)hSyjnLLaebvE926qT)5MtS0NffS0JfZyjarqLxVTou7FU5elPPS0Jfh)JRZrqt0WcWyXCsML0uwaHVTTMezylt6vr2)caDfkw6ZIcw6XccFoxvt2aSqabIYGeorfyjnLLaeQbHMkBawiGar5FNY4OBUhBhYbtWsFw6BSbs4WCr)blJnKftKyUvGft7uXI)SaCsgWSetmaILEWrdnrdl)UxSyojZsmXaiwmD)olidwiGar9zX097W1ZIgIVcfl)1rSCflXvdHG6f(zXlqw0xrSSIyX097SGmyHaceXY1y5Ewm5ywajCIkqGgBi8jxEhzSfaZbybE)bRSk0FJ3iwkbOmmVXgvUQManIRXwyUNMZn2q4Z5QAYgaZbybE)bRSk0FJnp8hSm2cKMW)56SRpuvhvVXBelLaKgM3yJkxvtGgX1ylm3tZ5gBi85CvnzdG5aSaV)Gvwf6VXMh(dwgBxf8P8)GLXBelLaGgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzSrb9fHj7vz9Q8HfGNfailiHfp8hSS43N2nKLqkfwpL)RJybWSygluqFryYEvwVkFyb4zPhlakwamlVRP6Ty4sNHT8Vt5gCi8BPYv1eilaplXHL(SGew8WFWYAA8F3siLcRNY)1rSayws2cqwqcl4isRZ7o(jJnqchMl6pyzSHE4)68NWSSdnXs3kSZsmXaiw8HybLFfbYsenSGPaSan2q4tU8oYyZXraiA2OGXBelLaogM3yJkxvtGgX1yZd)blJn87dEnOiJnqchMl6pyzSfBxDrSS9(GxdkcZIPDQy53jwAhQ9NLdZIRcxplpKfQarllTHQyKGLdZIRcxplpKfQarlljGlw8HyXFwaojdywIjgaXYvS4flOxqFrycTSGSyIeZTcSOD8JzXl4VtdlaqaJPaMf4Wsc4IftWLgKficAcEelDWHy539IfovPKzjMyaelM2PILeWflMGlnyHUNLT3h8AqrSuqtgBH5EAo3yRhlQqmMffSC1tteu7pbMBhQ9ppuNFfMfGXI5WsAkl9yrD1A2XrqfCHZTHQyKWouNFfMfGXcQaOTZrklaplb60S0Jfh)JRZrqt0WcsyjojZsFwuWI6Q1SJJGk4cNBdvXiHDfXsFw6ZsAkl9yXX)46Ce0enSaywq4Z5QAY64iaenBuGfGNf1vRzPG(IWugd1(yhQZVcZcGzbe(22AsKHTmPxfz)laeopuNFflapla0IgwINfLukzwstzXX)46Ce0enSaywq4Z5QAY64iaenBuGfGNf1vRzPG(IWuwVkFSd15xHzbWSacFBBnjYWwM0RIS)facNhQZVIfGNfaArdlXZIskLml9zrbluqFryYEv2ReSOGLESyglQRwZg88vb7kIL0uwmJL31u9w87JgoGwQCvnbYsFwuWspw6XIzSeGqni0uzdE(QGDfXsAklbicQ86TaLyoVyrblMXsac1GqtLL6IGMOjRclq7kIL(SKMYsaIGkVEBDO2)CZjw6ZIcw6XIzSeGiOYR3IGQFpXWsAklMXI6Q1SbpFvWUIyjnLfh)JRZrqt0Ws8SaCsML(SKMYspwExt1BXVpA4aAPYv1eilkyrD1A2GNVkyxrSOGLESOUAnl(9rdhql(9aqSamwIdlPPS44FCDocAIgwINfGtYS0NL(SKMYI6Q1SbpFvWUIyrblMXI6Q1SJJGk4cNBdvXiHDfXIcwmJL31u9w87JgoGwQCvnbA8gXcGjByEJnQCvnbAexJnp8hSm2kYuUdclJnqchMl6pyzSf7yIfaSqyHz5kwq)v5dlOxqFryIfVazb7iiwqoJRBao2S0AwaWcHfln4WcYIjsm3kySfM7P5CJTESOUAnlf0xeMY6v5JDOo)kmlXZcHukSEk)xhXsAkl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKMYsy3hueMfLzjoS0NffS4r5WofaY4nIfavYW8gBu5QAc0iUgBH5EAo3yRhlQRwZsb9fHPSEv(yhQZVcZs8SqiLcRNY)1rSOGLESeGqni0uzdE(QGDOo)kmlXZcAsML0uwcqOgeAQSbyHaceL)DkJJU5ESDOo)kmlXZcAsML(SKMYspwc7(GIWSOmlaKffSmuy3huu(VoIfGXcAyPplPPSe29bfHzrzwIdl9zrblEuoStbGm28WFWYyB31TChewgVrSaianmVXgvUQManIRXwyUNMZn26XI6Q1SuqFrykRxLp2H68RWSeplesPW6P8FDelkyPhlbiudcnv2GNVkyhQZVcZs8SGMKzjnLLaeQbHMkBawiGar5FNY4OBUhBhQZVcZs8SGMKzPplPPS0JLWUpOimlkZcazrbldf29bfL)RJybySGgw6ZsAklHDFqrywuML4WsFwuWIhLd7uaiJnp8hSm2AlTo3bHLXBelaghdZBSrLRQjqJ4ASbs4WCr)blJnKdi6XcSyjaAS5H)GLXMjFMdozylt6vrgVrSaO5yyEJnQCvnbAexJnp8hSm2WVpTBiJnqchMl6pyzSf7yILT3N2nelpKLObgyzdQ9Hf0lOVimXcCyX0ovSCflWsNGf0Fv(Wc6f0xeMyXlqwwyIfKdi6Xs0adywUglxXc6VkFyb9c6lctgBH5EAo3yJc6lct2RY6v5dlPPSqb9fHjlgQ9jxesFwstzHc6lctwVsKlcPplPPSOUAnRjFMdozylt6vr2velkyrD1AwkOVimL1RYh7kIL0uw6XI6Q1SbpFvWouNFfMfGXIh(dwwtJ)7wcPuy9u(VoIffSOUAnBWZxfSRiw6B8gXcGOXW8gBE4pyzSzA8F3yJkxvtGgX14nIfabugM3yJkxvtGgX1yZd)blJTzvzp8hSY6d)gB6d)5Y7iJTMR1)(SmEJ3yZHKH5nILsgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzS1Jf1vRz)RJmbNkdoK3PEfin2H68RWSamwqfaTDoszbWSKSvjwstzrD1A2)6itWPYGd5DQxbsJDOo)kmlaJfp8hSS43N2nKLqkfwpL)RJybWSKSvjwuWspwOG(IWK9QSEv(WsAkluqFryYIHAFYfH0NL0uwOG(IWK1Re5Iq6ZsFw6ZIcwuxTM9VoYeCQm4qEN6vG0yxrSOGLzvudoOi7FDKj4uzWH8o1RaPXsLRQjqJnqchMl6pyzSHmxhwA)jmlM2PFNgw(DILy7qExW)WonSOUAnwmDAnlnxRzb2ASy6(9Ry53jwkcPplbh)gBi8jxEhzSboK3LnDADU5ADg2AgVrSaOH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgBMXcf0xeMSxLXqTpSOGLESGJiTo)(GIESf)(0UHyjEwqdlky5DnvVfdx6mSL)Dk3GdHFlvUQMazjnLfCeP153hu0JT43N2nelXZcGKL(gBGeomx0FWYydzUoS0(tywmTt)onSS9(GxdkILdZIj487SeC8FfkwGiOHLT3N2nelxXc6VkFyb9c6lctgBi8jxEhzSDOk4qz87dEnOiJ3iwXXW8gBu5QAc0iUgBE4pyzSfGfciqu(3Pmo6M7XgBGeomx0FWYyl2XelidwiGarSyANkw8NfnHXS87EXcAsMLyIbqS4fil6RiwwrSy6(DwqwmrI5wbJTWCpnNBSzglGZ6aTfmhaXSOGLES0Jfe(CUQMSbyHaceLbjCIkWIcwmJLaeQbHMkBWZxfSd5GjyjnLf1vRzdE(QGDfXsFwuWspwuxTMLc6lctz9Q8XouNFfML4zbqXsAklQRwZsb9fHPmgQ9XouNFfML4zbqXsFwuWspwmJLzvudoOiRQR9kqzyl7AD(3Vcf2sLRQjqwstzrD1Awvx7vGYWw2168VFfkCU8FnKf)EaiwINL4WsAklQRwZQ6AVcug2YUwN)9RqHZ(e8IS43daXs8Sehw6ZsAklQqmMffS0ou7FEOo)kmlaJfLsMffSyglbiudcnv2GNVkyhYbtWsFJ3iwMJH5n2OYv1eOrCn28WFWYyBCeubx4CBOkgjm2ajCyUO)GLXwSJjwIndvXiblMUFNfKftKyUvWylm3tZ5gBQRwZg88vb7qD(vywINfLqJXBel0yyEJnQCvnbAexJnp8hSm2WRQDdzSfse0u(9bf9yJyPKXwyUNMZn26XYqTHW7UQMyjnLf1vRzPG(IWugd1(yhQZVcZcWyjoSOGfkOVimzVkJHAFyrbld15xHzbySOK5WIcwExt1BXWLodB5FNYn4q43sLRQjqw6ZIcwEFqrV9Vok)Wm4rSeplkzoSaiybhrAD(9bf9ywamld15xHzrbl9yHc6lct2RYELGL0uwgQZVcZcWybva025iLL(gBGeomx0FWYyl2XelBRQDdXYvSe5fi1DbwGflEL43Vcfl)U)SOpeeMfLmhmfWS4filAcJzX097S0bhIL3hu0JzXlqw8NLFNyHkqwGnwCw2GAFyb9c6lctS4plkzoSGPaMf4WIMWywgQZV6kuS4ywEilf8zz3rCfkwEild1gcVZc4AUcflO)Q8Hf0lOVimz8gXcqzyEJnQCvnbAexJnp8hSm2WVpnxRn2ajCyUO)GLXgYjIIyzfXY27tZ1Aw8NfxRz5VocZYQ0egZYcFfkwq)ebFCmlEbYY9SCywCv46z5HSenWalWHfn9S87el4ikCUMfp8hSyrFfXIkPHMyz3lqnXsSDiVt9kqAybwSaqwEFqrp2ylm3tZ5gBMXY7AQEl(jT2Nm4CT3sLRQjqwuWspwuxTMf)(0CT2ouBi8URQjwuWspwWrKwNFFqrp2IFFAUwZcWyjoSKMYIzSmRIAWbfz)RJmbNkdoK3PEfinwQCvnbYsFwstz5DnvVfdx6mSL)Dk3GdHFlvUQMazrblQRwZsb9fHPmgQ9XouNFfMfGXsCyrbluqFryYEvgd1(WIcwuxTMf)(0CT2ouNFfMfGXcGKffSGJiTo)(GIESf)(0CTML4vMfZHL(SOGLESyglZQOgCqrwDIGpoo30e9xHkJsFDryYsLRQjqwstz5VoIfKllMdAyjEwuxTMf)(0CT2ouNFfMfaZcazPplky59bf92)6O8dZGhXs8SGgJ3iwasdZBSrLRQjqJ4AS5H)GLXg(9P5ATXgiHdZf9hSm2qoUFNLTN0AFyj2ox7zzHjwGflbqwmTtfld1gcV7QAIf11Zc(pTMft(9S0GdlOFIGpoMLObgyXlqwaHf6EwwyIfvQbhIfKfBXww2(tRzzHjwuPgCiwqgSqabIybFvGy539NftNwZs0adS4f83PHLT3NMR1gBH5EAo3y7DnvVf)Kw7tgCU2BPYv1eilkyrD1Aw87tZ1A7qTHW7UQMyrbl9yXmwMvrn4GIS6ebFCCUPj6VcvgL(6IWKLkxvtGSKMYYFDelixwmh0Ws8SyoS0NffS8(GIE7FDu(HzWJyjEwIJXBelaOH5n2OYv1eOrCn28WFWYyd)(0CT2ydKWH5I(dwgBih3VZsSDiVt9kqAyzHjw2EFAUwZYdzbiIIyzfXYVtSOUAnwutWIRXqww4RqXY27tZ1AwGflOHfmfGfiMf4WIMWywgQZV6kugBH5EAo3yBwf1GdkY(xhzcovgCiVt9kqASu5QAcKffSGJiTo)(GIESf)(0CTML4vML4WIcw6XIzSOUAn7FDKj4uzWH8o1RaPXUIyrblQRwZIFFAUwBhQneE3v1elPPS0Jfe(CUQMSGd5DztNwNBUwNHTglkyPhlQRwZIFFAUwBhQZVcZcWyjoSKMYcoI0687dk6Xw87tZ1AwINfaYIcwExt1BXpP1(KbNR9wQCvnbYIcwuxTMf)(0CT2ouNFfMfGXcAyPpl9zPVXBelGJH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgBo(hxNJGMOHL4zbaMmlacw6XIsjZcWZI6Q1S)1rMGtLbhY7uVcKgl(9aqS0Nfabl9yrD1Aw87tZ1A7qD(vywaEwIdliHfCeP15Dh)elaplMXY7AQEl(jT2Nm4CT3sLRQjqw6ZcGGLESeGqni0uzXVpnxRTd15xHzb4zjoSGewWrKwN3D8tSa8S8UMQ3IFsR9jdox7Tu5QAcKL(SaiyPhlGW32wtImSLj9Qi7qD(vywaEwqdl9zrbl9yrD1Aw87tZ1A7kIL0uwcqOgeAQS43NMR12H68RWS03ydKWH5I(dwgBiZ1HL2FcZIPD63PHfNLT3h8AqrSSWelMoTMLGVWelBVpnxRz5HS0CTMfyRHww8cKLfMyz79bVguelpKfGikILy7qEN6vG0Wc(9aqSSIm2q4tU8oYyd)(0CToBcwFU5ADg2AgVrSukzdZBSrLRQjqJ4AS5H)GLXg(9bVguKXgiHdZf9hSm2IDmXY27dEnOiwmD)olX2H8o1RaPHLhYcqefXYkILFNyrD1ASy6(D46zrdXxHILT3NMR1SSI(RJyXlqwwyILT3h8AqrSalwmhaZsCHX08SGFpaeMLv9NMfZHL3hu0Jn2cZ90CUXgcFoxvtwWH8USPtRZnxRZWwJffSGWNZv1Kf)(0CToBcwFU5ADg2ASOGfZybHpNRQj7HQGdLXVp41GIyjnLLESOUAnRQR9kqzyl7AD(3Vcfox(VgYIFpaelXZsCyjnLf1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGyjEwIdl9zrbl4isRZVpOOhBXVpnxRzbySyoSOGfe(CUQMS43NMR1ztW6ZnxRZWwZ4nILskzyEJnQCvnbAexJnp8hSm2Cqp6peugBYNoJTqIGMYVpOOhBelLm2cZ90CUXMzS8xaORqXIcwmJfp8hSSoOh9hckJn5txg07CuK9QCtFO2Fwstzbe(wh0J(dbLXM8Pld6DokYIFpaelaJL4WIcwaHV1b9O)qqzSjF6YGENJISd15xHzbySehJnqchMl6pyzSf7yIfSjF6ybdz539NLeWflOONLohPSSI(RJyrnbll8vOy5EwCmlA)jwCmlrqm(u1elWIfnHXS87EXsCyb)EaimlWHfaCw4Nft7uXsCaml43daHzHqA0nKXBelLaOH5n2OYv1eOrCn28WFWYyRdcR2nKXwirqt53hu0JnILsgBH5EAo3yBO2q4DxvtSOGL3hu0B)RJYpmdEelXZspw6XIsMdlaMLESGJiTo)(GIESf)(0UHyb4zbGSa8SOUAnlf0xeMY6v5JDfXsFw6ZcGzzOo)kml9zbjS0JfLybWS8UMQ3(MUk3bHf2sLRQjqw6ZIcw6Xsac1GqtLn45Rc2HCWeSOGfZybCwhOTG5aiMffS0Jfe(CUQMSbyHaceLbjCIkWsAklbiudcnv2aSqabIY)oLXr3Cp2oKdMGL0uwmJLaebvE926qT)5MtS0NL0uwWrKwNFFqrp2IFFA3qSamw6XspwauSaiyPhlQRwZsb9fHPSEv(yxrSa8Saqw6ZsFwaEw6XIsSaywExt1BFtxL7GWcBPYv1eil9zPplkyXmwOG(IWKfd1(KlcPplPPS0JfkOVimzVkJHAFyjnLLESqb9fHj7vzv4VZsAkluqFryYEvwVkFyPplkyXmwExt1BXWLodB5FNYn4q43sLRQjqwstzrD1A2O56Gd456SpbVUqoAPX(yr46fXs8kZcartYS0NffS0JfCeP153hu0JT43N2nelaJfLsMfGNLESOelaML31u9230v5oiSWwQCvnbYsFw6ZIcwC8pUohbnrdlXZcAsMfablQRwZIFFAUwBhQZVcZcWZcGIL(SOGLESyglQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfXsAkluqFryYEvgd1(WsAklMXsaIGkVElqjMZlw6ZIcwmJf1vRzhhbvWfo3gQIrIm(Q2sN3tGFAo3UIm2ajCyUO)GLXgagQneENfaSqy1UHy5ASGSyIeZTcSCywgYbtGww(DAiw8Hyrtyml)UxSGgwEFqrpMLRyb9xLpSGEb9fHjwmD)olBWp2Gww0egZYV7flkLmlWFNgthMy5kw8kblOxqFryIf4WYkILhYcAy59bf9ywuPgCiwCwq)v5dlOxqFryYYsSfwO7zzO2q4DwaxZvOyb50vGdbYc61fbnrthvplRstymlxXYgu7dlOxqFryY4nILsXXW8gBu5QAc0iUgBE4pyzS1GtGYWwU8FnKXgiHdZf9hSm2IDmXsSbglwGflbqwmD)oC9Se8OORqzSfM7P5CJnpkh2PaqgVrSuYCmmVXgvUQManIRXgmYydtVXMh(dwgBi85CvnzSHW1lYyZmwaN1bAlyoaIzrbli85CvnzdG5aSaV)GflkyPhl9yrD1Aw87tZ1A7kIL0uwExt1BXpP1(KbNR9wQCvnbYsAklbicQ86T1HA)ZnNyPplkyPhlMXI6Q1SyOg)xGSRiwuWIzSOUAnBWZxfSRiwuWspwmJL31u922AsKHTmPxfzPYv1eilPPSOUAnBWZxfSGRX)dwSeplbiudcnv22AsKHTmPxfzhQZVcZcGzbaYsFwuWccFoxvt2FFoToJjciAYM87zrbl9yXmwcqeu51BRd1(NBoXsAklbiudcnv2aSqabIY)oLXr3Cp2UIyrbl9yrD1Aw87tZ1A7qD(vywaglaKL0uwmJL31u9w8tATpzW5AVLkxvtGS0NL(SOGL3hu0B)RJYpmdEelXZI6Q1SbpFvWcUg)pyXcWZsYwajl9zjnLL2HA)Zd15xHzbySOUAnBWZxfSGRX)dwS03ydHp5Y7iJTayoalW7pyLDiz8gXsj0yyEJnQCvnbAexJnp8hSm2cKMW)56SRpuvhvVXgiHdZf9hSm2IDmXcYIjsm3kWcSyjaYYQ0egZIxGSOVIy5EwwrSy6(DwqgSqabIm2cZ90CUXgcFoxvt2ayoalW7pyLDiz8gXsjaLH5n2OYv1eOrCn2cZ90CUXgcFoxvt2ayoalW7pyLDizS5H)GLX2vbFk)pyz8gXsjaPH5n2OYv1eOrCn28WFWYyJ6IGMOjRclqJnqchMl6pyzSf7yIf0RlcAIgwIlSazbwSeazX097SS9(0CTMLvelEbYc2rqS0GdlaOLg7dlEbYcYIjsm3kySfM7P5CJnvigZIcwU6PjcQ9NaZTd1(NhQZVcZcWyrj0WsAkl9yrD1A2O56Gd456SpbVUqoAPX(yr46fXcWybGOjzwstzrD1A2O56Gd456SpbVUqoAPX(yr46fXs8kZcartYS0NffSOUAnl(9P5ATDfXIcw6Xsac1GqtLn45Rc2H68RWSeplOjzwstzbCwhOTG5aiML(gVrSucaAyEJnQCvnbAexJnp8hSm2WpP1(KBAFiJTqIGMYVpOOhBelLm2cZ90CUX2qTHW7UQMyrbl)1r5hMbpIL4zrj0WIcwWrKwNFFqrp2IFFA3qSamwmhwuWIhLd7uaiwuWspwuxTMn45Rc2H68RWSeplkLmlPPSyglQRwZg88vb7kIL(gBGeomx0FWYydad1gcVZst7dXcSyzfXYdzjoS8(GIEmlMUFhUEwqwmrI5wbwuPRqXIRcxplpKfcPr3qS4filf8zbIGMGhfDfkJ3iwkbCmmVXgvUQManIRXMh(dwgBT1KidBzsVkYydKWH5I(dwgBXoMyj2arpwUglxHpqIfVyb9c6lctS4fil6RiwUNLvelMUFNfNfa0sJ9HLObgyXlqwIjOh9hcILnt(0zSfM7P5CJnkOVimzVk7vcwuWIhLd7uaiwuWI6Q1SrZ1bhWZ1zFcEDHC0sJ9XIW1lIfGXcartYSOGLESacFRd6r)HGYyt(0Lb9ohfz)la0vOyjnLfZyjarqLxVTOWa1WbKL0uwWrKwNFFqrpML4zbGS0NffS0Jf1vRzhhbvWfo3gQIrc7qD(vywaglahwaeS0Jf0WcWZYSkQbhuKfFvBPZ7jWpnNBPYv1eil9zrblQRwZoocQGlCUnufJe2velPPSyglQRwZoocQGlCUnufJe2vel9zrbl9yXmwcqOgeAQSbpFvWUIyjnLf1vRz)9506mMiGOXIFpaelaJfLqdlkyPDO2)8qD(vywaglam5KzrblTd1(NhQZVcZs8SOuYjZsAklMXcgU0QxbA)9506mMiGOXsLRQjqw6ZIcw6XcgU0QxbA)9506mMiGOXsLRQjqwstzjaHAqOPYg88vb7qD(vywINL4Kml9nEJybWKnmVXgvUQManIRXMh(dwgB43NMR1gBGeomx0FWYyl2XelolBVpnxRzbaFr)olrdmWYQ0egZY27tZ1AwomlUEihmblRiwGdljGlw8HyXvHRNLhYcebnbpILyIbqgBH5EAo3ytD1Awyr)oohrtGI(dw2velkyPhlQRwZIFFAUwBhQneE3v1elPPS44FCDocAIgwINfGtYS034nIfavYW8gBu5QAc0iUgBE4pyzSHFFAUwBSbs4WCr)blJTy7QlILyIbqSOsn4qSGmyHaceXIP73zz79P5AnlEbYYVtflBVp41GIm2cZ90CUXwaIGkVEBDO2)CZjwuWIzS8UMQ3IFsR9jdox7Tu5QAcKffS0Jfe(CUQMSbyHaceLbjCIkWsAklbiudcnv2GNVkyxrSKMYI6Q1SbpFvWUIyPplkyjaHAqOPYgGfciqu(3Pmo6M7X2H68RWSamwqfaTDoszb4zjqNMLES44FCDocAIgwqclOjzw6ZIcwuxTMf)(0CT2ouNFfMfGXI5WIcwmJfWzDG2cMdGyJ3iwaeGgM3yJkxvtGgX1ylm3tZ5gBbicQ86T1HA)ZnNyrbl9ybHpNRQjBawiGarzqcNOcSKMYsac1GqtLn45Rc2velPPSOUAnBWZxfSRiw6ZIcwcqOgeAQSbyHaceL)DkJJU5ESDOo)kmlaJfaflkyrD1Aw87tZ1A7kIffSqb9fHj7vzVsWIcwmJfe(CUQMShQcoug)(GxdkIffSyglGZ6aTfmhaXgBE4pyzSHFFWRbfz8gXcGXXW8gBu5QAc0iUgBE4pyzSHFFWRbfzSbs4WCr)blJTyhtSS9(GxdkIft3VZIxSaGVOFNLObgyboSCnwsaxOdKficAcEelXedGyX097SKaUgwkcPplbh)wwIPgdzbC1fXsmXaiw8NLFNyHkqwGnw(DIfaCP63tmSOUAnwUglBVpnxRzXeCPbl09S0CTMfyRXcCyjbCXIpelWIfaYY7dk6XgBH5EAo3ytD1Awyr)ooh0Kpzeh(GLDfXsAkl9yXmwWVpTBiRhLd7uaiwuWIzSGWNZv1K9qvWHY43h8AqrSKMYspwuxTMn45Rc2H68RWSamwqdlkyrD1A2GNVkyxrSKMYspw6XI6Q1SbpFvWouNFfMfGXcQaOTZrklaplb60S0Jfh)JRZrqt0WcsyjojZsFwuWI6Q1SbpFvWUIyjnLf1vRzhhbvWfo3gQIrIm(Q2sN3tGFAo3ouNFfMfGXcQaOTZrklaplb60S0Jfh)JRZrqt0WcsyjojZsFwuWI6Q1SJJGk4cNBdvXirgFvBPZ7jWpnNBxrS0NffSeGiOYR3IGQFpXWsFw6ZIcw6XcoI0687dk6Xw87tZ1AwaglXHL0uwq4Z5QAYIFFAUwNnbRp3CTodBnw6ZsFwuWIzSGWNZv1K9qvWHY43h8AqrSOGLESyglZQOgCqr2)6itWPYGd5DQxbsJLkxvtGSKMYcoI0687dk6Xw87tZ1AwaglXHL(gVrSaO5yyEJnQCvnbAexJnp8hSm2kYuUdclJnqchMl6pyzSf7yIfaSqyHz5kw2GAFyb9c6lctS4filyhbXsSzP1SaGfclwAWHfKftKyUvWylm3tZ5gB9yrD1AwkOVimLXqTp2H68RWSeplesPW6P8FDelPPS0JLWUpOimlkZcazrbldf29bfL)RJybySGgw6ZsAklHDFqrywuML4WsFwuWIhLd7uaiJ3iwaengM3yJkxvtGgX1ylm3tZ5gB9yrD1AwkOVimLXqTp2H68RWSeplesPW6P8FDelPPS0JLWUpOimlkZcazrbldf29bfL)RJybySGgw6ZsAklHDFqrywuML4WsFwuWIhLd7uaiwuWspwuxTMDCeubx4CBOkgjSd15xHzbySGgwuWI6Q1SJJGk4cNBdvXiHDfXIcwmJLzvudoOil(Q2sN3tGFAo3sLRQjqwstzXmwuxTMDCeubx4CBOkgjSRiw6BS5H)GLX2URB5oiSmEJybqaLH5n2OYv1eOrCn2cZ90CUXwpwuxTMLc6lctzmu7JDOo)kmlXZcHukSEk)xhXIcw6Xsac1GqtLn45Rc2H68RWSeplOjzwstzjaHAqOPYgGfciqu(3Pmo6M7X2H68RWSeplOjzw6ZsAkl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKMYsy3hueMfLzjoS0NffS4r5WofaIffS0Jf1vRzhhbvWfo3gQIrc7qD(vywaglOHffSOUAn74iOcUW52qvmsyxrSOGfZyzwf1GdkYIVQT059e4NMZTu5QAcKL0uwmJf1vRzhhbvWfo3gQIrc7kIL(gBE4pyzS1wADUdclJ3iwaeqAyEJnQCvnbAexJnqchMl6pyzSf7yIfKdi6XcSybzXwJnp8hSm2m5ZCWjdBzsVkY4nIfabGgM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzSHJiTo)(GIESf)(0UHyjEwmhwamlnneoS0JLoh)0KiJW1lIfGNfLsozwqclamzw6ZcGzPPHWHLESOUAnl(9bVguuM6IGMOPJQpJHAFS43daXcsyXCyPVXgiHdZf9hSm2qMRdlT)eMft70VtdlpKLfMyz79PDdXYvSSb1(WIP9lSZYHzXFwqdlVpOOhdyLyPbhwie0KGfaMmYLLoh)0KGf4WI5WY27dEnOiwqVUiOjA6O6zb)EaiSXgcFYL3rgB43N2nu(QmgQ9X4nIfabogM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzSPeliHfCeP15Dh)elaJfaYcGGLESKSfGSa8S0JfCeP153hu0JT43N2nelacwuIL(Sa8S0JfLybWS8UMQ3IHlDg2Y)oLBWHWVLkxvtGSa8SOKfnS0NL(Sayws2QeAyb4zrD1A2XrqfCHZTHQyKWouNFf2ydKWH5I(dwgBiZ1HL2FcZIPD63PHLhYcYX4)olGR5kuSeBgQIrcJne(KlVJm2mn(VNVk3gQIrcJ3iwXjzdZBSrLRQjqJ4AS5H)GLXMPX)DJnqchMl6pyzSf7yIfKJX)DwUILnO2hwqVG(IWelWHLRXsbzz79PDdXIPtRzPDplx9qwqwmrI5wbw8krhCiJTWCpnNBS1JfkOVimz1RYNCri9zjnLfkOVimz9krUiK(SOGfe(CUQMShoh0KJGyPplkyPhlVpOO3(xhLFyg8iwINfZHL0uwOG(IWKvVkFYxLbilPPS0ou7FEOo)kmlaJfLsML(SKMYI6Q1SuqFrykJHAFSd15xHzbyS4H)GLf)(0UHSesPW6P8FDelkyrD1AwkOVimLXqTp2velPPSqb9fHj7vzmu7dlkyXmwq4Z5QAYIFFA3q5RYyO2hwstzrD1A2GNVkyhQZVcZcWyXd)bll(9PDdzjKsH1t5)6iwuWIzSGWNZv1K9W5GMCeelkyrD1A2GNVkyhQZVcZcWyHqkfwpL)RJyrblQRwZg88vb7kIL0uwuxTMDCeubx4CBOkgjSRiwuWccFoxvtwtJ)75RYTHQyKGL0uwmJfe(CUQMShoh0KJGyrblQRwZg88vb7qD(vywINfcPuy9u(VoY4nIvCuYW8gBu5QAc0iUgBGeomx0FWYyl2XelBVpTBiwUglxXc6VkFyb9c6lctOLLRyzdQ9Hf0lOVimXcSyXCamlVpOOhZcCy5HSenWalBqTpSGEb9fHjJnp8hSm2WVpTBiJ3iwXbGgM3yJkxvtGgX1ydKWH5I(dwgBXgxR)9zzS5H)GLX2SQSh(dwz9HFJn9H)C5DKXwZ16FFwgVXBS1CT(3NLH5nILsgM3yJkxvtGgX1yZd)blJn87dEnOiJnqchMl6pyzST9(GxdkILgCyPdIG6O6zzvAcJzzHVcflXfgtZBSfM7P5CJnZyzwf1GdkYQ6AVcug2YUwN)9RqHTeWDDrreOXBelaAyEJnQCvnbAexJnp8hSm2WRQDdzSfse0u(9bf9yJyPKXwyUNMZn2aHVTdcR2nKDOo)kmlXZYqD(vywaEwaiazbjSOea0ydKWH5I(dwgBiZXpl)oXci8zX097S87elDq8ZYFDelpKfheKLv9NMLFNyPZrklGRX)dwSCyw2V3YY2QA3qSmuNFfMLUL(Vi9rGS8qw68pSZshewTBiwaxJ)hSmEJyfhdZBS5H)GLXwhewTBiJnQCvnbAexJ34n2WVH5nILsgM3yJkxvtGgX1yZd)blJn87dEnOiJnqchMl6pyzSf7yILT3h8AqrS8qwaIOiwwrS87elX2H8o1RaPHf1vRXY1y5EwmbxAqwiKgDdXIk1GdXs7QdVFfkw(DILIq6ZsWXplWHLhYc4QlIfvQbhIfKbleqGiJTWCpnNBSnRIAWbfz)RJmbNkdoK3PEfinwQCvnbYIcw6Xcf0xeMSxL9kblkyXmw6XspwuxTM9VoYeCQm4qEN6vG0yhQZVcZs8S4H)GL104)ULqkfwpL)RJybWSKSvjwuWspwOG(IWK9QSk83zjnLfkOVimzVkJHAFyjnLfkOVimz1RYNCri9zPplPPSOUAn7FDKj4uzWH8o1RaPXouNFfML4zXd)bll(9PDdzjKsH1t5)6iwamljBvIffS0JfkOVimzVkRxLpSKMYcf0xeMSyO2NCri9zjnLfkOVimz9krUiK(S0NL(SKMYIzSOUAn7FDKj4uzWH8o1RaPXUIyPplPPS0Jf1vRzdE(QGDfXsAkli85CvnzdWcbeikds4evGL(SOGLaeQbHMkBawiGar5FNY4OBUhBhYbtWIcwcqeu51BRd1(NBoXsFwuWspwmJLaebvE9wGsmNxSKMYsac1GqtLL6IGMOjRclq7qD(vywINfail9zrbl9yrD1A2GNVkyxrSKMYIzSeGqni0uzdE(QGDihmbl9nEJybqdZBSrLRQjqJ4AS5H)GLXMd6r)HGYyt(0zSfse0u(9bf9yJyPKXwyUNMZn2mJfq4BDqp6peugBYNUmO35Oi7FbGUcflkyXmw8WFWY6GE0FiOm2KpDzqVZrr2RYn9HA)zrbl9yXmwaHV1b9O)qqzSjF6Y7KRT)fa6kuSKMYci8ToOh9hckJn5txENCTDOo)kmlXZcAyPplPPSacFRd6r)HGYyt(0Lb9ohfzXVhaIfGXsCyrblGW36GE0FiOm2KpDzqVZrr2H68RWSamwIdlkybe(wh0J(dbLXM8Pld6DokY(xaORqzSbs4WCr)blJTyhtSetqp6peelBM8PJft7uXYVtdXYHzPGS4H)qqSGn5thAzXXSO9NyXXSebX4tvtSalwWM8PJft3VZcazboS0it0Wc(9aqywGdlWIfNL4aywWM8PJfmKLF3Fw(DILImXc2KpDS4ZCiimla4SWplE7PHLF3FwWM8PJfcPr3qyJ3iwXXW8gBu5QAc0iUgBE4pyzSfGfciqu(3Pmo6M7XgBGeomx0FWYyl2XeMfKbleqGiwUglilMiXCRalhMLvelWHLeWfl(qSas4ev4kuSGSyIeZTcSy6(DwqgSqabIyXlqwsaxS4dXIkPHMyXCsMLyIbqgBH5EAo3yZmwaN1bAlyoaIzrbl9yPhli85CvnzdWcbeikds4evGffSyglbiudcnv2GNVkyhYbtWIcwmJLzvudoOiB0CDWb8CD2NGxxihT0yFSu5QAcKL0uwuxTMn45Rc2vel9zrblo(hxNJGMOHfGPmlMtYSOGLESOUAnlf0xeMY6v5JDOo)kmlXZIsjZsAklQRwZsb9fHPmgQ9XouNFfML4zrPKzPplPPSOcXywuWs7qT)5H68RWSamwukzwuWIzSeGqni0uzdE(QGDihmbl9nEJyzogM3yJkxvtGgX1ydgzSHP3yZd)blJne(CUQMm2q46fzS1Jf1vRzhhbvWfo3gQIrc7qD(vywINf0WsAklMXI6Q1SJJGk4cNBdvXiHDfXsFwuWIzSOUAn74iOcUW52qvmsKXx1w68Ec8tZ52velkyPhlQRwZc0vGdbMPUiOjA6O6ZurdQlgKDOo)kmlaJfubqBNJuw6ZIcw6XI6Q1SuqFrykJHAFSd15xHzjEwqfaTDoszjnLf1vRzPG(IWuwVkFSd15xHzjEwqfaTDoszjnLLESyglQRwZsb9fHPSEv(yxrSKMYIzSOUAnlf0xeMYyO2h7kIL(SOGfZy5DnvVfd14)cKLkxvtGS03ydKWH5I(dwgBidwG3FWILgCyX1AwaHpMLF3Fw6CGiml41qS87ucw8Hk09SmuBi8obYIPDQybaJJGk4cZsSzOkgjyz3XSOjmMLF3lwqdlykGzzOo)QRqXcCy53jwakXCEXI6Q1y5WS4QW1ZYdzP5AnlWwJf4WIxjyb9c6lctSCywCv46z5HSqin6gYydHp5Y7iJnq4Nhc4UUH6O6XgVrSqJH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgB9yXmwuxTMLc6lctzmu7JDfXIcwmJf1vRzPG(IWuwVkFSRiw6ZsAklVRP6TyOg)xGSu5QAc0ydKWH5I(dwgBidwG3FWILF3Fwc7uaimlxJLeWfl(qSaxp(ajwOG(IWelpKfyPtWci8z53PHyboSCOk4qS87hMft3VZYguJ)lqgBi8jxEhzSbc)mC94dKYuqFryY4nIfGYW8gBu5QAc0iUgBE4pyzS1bHv7gYylm3tZ5gBd1gcV7QAIffS0Jf1vRzPG(IWugd1(yhQZVcZs8SmuNFfML0uwuxTMLc6lctz9Q8XouNFfML4zzOo)kmlPPSGWNZv1Kfe(z46XhiLPG(IWel9zrbld1gcV7QAIffS8(GIE7FDu(HzWJyjEwucGSOGfpkh2PaqSOGfe(CUQMSGWppeWDDd1r1Jn2cjcAk)(GIESrSuY4nIfG0W8gBu5QAc0iUgBE4pyzSHxv7gYylm3tZ5gBd1gcV7QAIffS0Jf1vRzPG(IWugd1(yhQZVcZs8SmuNFfML0uwuxTMLc6lctz9Q8XouNFfML4zzOo)kmlPPSGWNZv1Kfe(z46XhiLPG(IWel9zrbld1gcV7QAIffS8(GIE7FDu(HzWJyjEwucGSOGfpkh2PaqSOGfe(CUQMSGWppeWDDd1r1Jn2cjcAk)(GIESrSuY4nIfa0W8gBu5QAc0iUgBE4pyzSHFsR9j30(qgBH5EAo3yBO2q4DxvtSOGLESOUAnlf0xeMYyO2h7qD(vywINLH68RWSKMYI6Q1SuqFrykRxLp2H68RWSepld15xHzjnLfe(CUQMSGWpdxp(aPmf0xeMyPplkyzO2q4DxvtSOGL3hu0B)RJYpmdEelXZIsakwuWIhLd7uaiwuWccFoxvtwq4Nhc4UUH6O6XgBHebnLFFqrp2iwkz8gXc4yyEJnQCvnbAexJnp8hSm2AWjqzylx(VgYydKWH5I(dwgBXoMyj2aJflWILailMUFhUEwcEu0vOm2cZ90CUXMhLd7uaiJ3iwkLSH5n2OYv1eOrCn28WFWYyJ6IGMOjRclqJnqchMl6pyzSf7yIfKtxboeilBr3CpMft3VZIxjyrdluSqfCHANfTJ)RqXc6f0xeMyXlqw(jblpKf9vel3ZYkIft3VZcaAPX(WIxGSGSyIeZTcgBH5EAo3yRhl9yrD1AwkOVimLXqTp2H68RWSeplkLmlPPSOUAnlf0xeMY6v5JDOo)kmlXZIsjZsFwuWsac1GqtLn45Rc2H68RWSeplXjzwuWspwuxTMnAUo4aEUo7tWRlKJwASpweUErSamwaO5KmlPPSyglZQOgCqr2O56Gd456SpbVUqoAPX(yjG76IIiqw6ZsFwstzrD1A2O56Gd456SpbVUqoAPX(yr46fXs8kZcabKjZsAklbiudcnv2GNVkyhYbtWIcwC8pUohbnrdlXZcWjzJ3iwkPKH5n2OYv1eOrCn2GrgBy6n28WFWYydHpNRQjJneUErgBMXc4SoqBbZbqmlkybHpNRQjBamhGf49hSyrbl9yPhlbiudcnvwQlkXqUodhWYRazhQZVcZcWyrjafGKfaZspwusjwaEwMvrn4GIS4RAlDEpb(P5ClvUQMazPplkyHaURlkIaTuxuIHCDgoGLxbIL(SKMYIJ)X15iOjAyjELzb4KmlkyPhlMXY7AQEBBnjYWwM0RISu5QAcKL0uwuxTMn45RcwW14)blwINLaeQbHMkBBnjYWwM0RISd15xHzbWSaazPplkybHpNRQj7VpNwNXebenzt(9SOGLESOUAnlqxboeyM6IGMOPJQptfnOUyq2velPPSyglbicQ86TaLyoVyPplky59bf92)6O8dZGhXs8SOUAnBWZxfSGRX)dwSa8SKSfqYsAklQqmMffS0ou7FEOo)kmlaJf1vRzdE(QGfCn(FWIL0uwcqeu51BRd1(NBoXsAklQRwZQQHqq9c)2velkyrD1AwvnecQx43ouNFfMfGXI6Q1SbpFvWcUg)pyXcGzPhlahwaEwMvrn4GISrZ1bhWZ1zFcEDHC0sJ9Xsa31ffrGS0NL(SOGfZyrD1A2GNVkyxrSOGLESyglbicQ86T1HA)ZnNyjnLLaeQbHMkBawiGar5FNY4OBUhBxrSKMYIkeJzrblTd1(NhQZVcZcWyjaHAqOPYgGfciqu(3Pmo6M7X2H68RWSaywauSKMYs7qT)5H68RWSGCzrjayYSamwuxTMn45RcwW14)blw6BSbs4WCr)blJTyhtSGSyIeZTcSy6(DwqgSqabIqcYPRahcKLTOBUhZIxGSacl09SarqJP5EIfa0sJ9Hf4WIPDQyjUAieuVWplMGlnilesJUHyrLAWHybzXejMBfyHqA0ne2ydHp5Y7iJTayoalW7pyLXVXBelLaOH5n2OYv1eOrCn28WFWYyBCeubx4CBOkgjm2ajCyUO)GLXwSJjw(DIfaCP63tmSy6(DwCwqwmrI5wbw(D)z5Wf6EwAdSJfa0sJ9Xylm3tZ5gBQRwZg88vb7qD(vywINfLqdlPPSOUAnBWZxfSGRX)dwSamwItYSOGfe(CUQMSbWCawG3FWkJFJ3iwkfhdZBSrLRQjqJ4ASfM7P5CJne(CUQMSbWCawG3FWkJFwuWspwmJf1vRzdE(QGfCn(FWIL4zjojZsAklMXsaIGkVElcQ(9edl9zjnLf1vRzhhbvWfo3gQIrc7kIffSOUAn74iOcUW52qvmsyhQZVcZcWyb4WcGzjalW192OHchMYU(qvDu92)6OmcxViwaml9yXmwuxTMvvdHG6f(TRiwuWIzS8UMQ3IFF0Wb0sLRQjqw6BS5H)GLXwG0e(pxND9HQ6O6nEJyPK5yyEJnQCvnbAexJTWCpnNBSHWNZv1KnaMdWc8(dwz8BS5H)GLX2vbFk)pyz8gXsj0yyEJnQCvnbAexJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXMzSeGqni0uzdE(QGDihmblPPSygli85CvnzdWcbeikds4evGffSeGiOYR3whQ9p3CIL0uwaN1bAlyoaIn2ajCyUO)GLXgaU(CUQMyzHjqwGflU6PV)iml)U)SyYRNLhYIkXc2rqGS0GdlilMiXCRalyil)U)S87ucw8HQNfto(jqwaWzHFwuPgCiw(DQZydHp5Y7iJnSJGYn4KdE(QGXBelLaugM3yJkxvtGgX1yZd)blJT2AsKHTmPxfzSbs4WCr)blJTyhtywInq0JLRXYvS4flOxqFryIfVaz5NJWS8qw0xrSCplRiwmD)olaOLg7dAzbzXejMBfyXlqwIjOh9hcILnt(0zSfM7P5CJnkOVimzVk7vcwuWIhLd7uaiwuWI6Q1SrZ1bhWZ1zFcEDHC0sJ9XIW1lIfGXcanNKzrbl9ybe(wh0J(dbLXM8Pld6DokY(xaORqXsAklMXsaIGkVEBrHbQHdil9zrbli85CvnzXock3Gto45RcSOGLESOUAn74iOcUW52qvmsyhQZVcZcWyb4WcGGLESGgwaEwMvrn4GIS4RAlDEpb(P5ClvUQMazPplkyrD1A2XrqfCHZTHQyKWUIyjnLfZyrD1A2XrqfCHZTHQyKWUIyPVXBelLaKgM3yJkxvtGgX1yZd)blJn87tZ1AJnqchMl6pyzSf7yIfa8f97SS9(0CTMLObgWSCnw2EFAUwZYHl09SSIm2cZ90CUXM6Q1SWI(DCoIMaf9hSSRiwuWI6Q1S43NMR12HAdH3Dvnz8gXsjaOH5n2OYv1eOrCn2cZ90CUXM6Q1S43hnCaTd15xHzbySGgwuWspwuxTMLc6lctzmu7JDOo)kmlXZcAyjnLf1vRzPG(IWuwVkFSd15xHzjEwqdl9zrblo(hxNJGMOHL4zb4KSXMh(dwgBbVcKoRUAnJn1vRLlVJm2WVpA4aA8gXsjGJH5n2OYv1eOrCn28WFWYyd)(GxdkYydKWH5I(dwgBX2vxeMLyIbqSOsn4qSGmyHaceXYcFfkw(DIfKbleqGiwcWc8(dwS8qwc7uaiwUglidwiGarSCyw8WVCToblUkC9S8qwujwco(n2cZ90CUXwaIGkVEBDO2)CZjwuWccFoxvt2aSqabIYGeorfyrblbiudcnv2aSqabIY)oLXr3Cp2ouNFfMfGXcAyrblMXc4SoqBbZbqmlkyHc6lct2RYELGffS44FCDocAIgwINfZjzJ3iwamzdZBSrLRQjqJ4AS5H)GLXg(9P5ATXgiHdZf9hSm2IDmXY27tZ1AwmD)olBpP1(WsSDU2ZIxGSuqw2EF0WbeTSyANkwkilBVpnxRz5WSSIqlljGlw8Hy5kwq)v5dlOxqFryILgCybacymfWSahwEilrdmWcaAPX(WIPDQyXvHiiwaojZsmXaiwGdloyK)hcIfSjF6yz3XSaabmMcywgQZV6kuSahwomlxXstFO2FllXc(el)U)SSkqAy53jwWEhXsawG3FWcZY9OdZcyeMLIw)4AwEilBVpnxRzbCnxHIfamocQGlmlXMHQyKaTSyANkwsaxOdKf8FAnlubYYkIft3VZcWjza74iwAWHLFNyr74NfuAOQRXwJTWCpnNBS9UMQ3IFsR9jdox7Tu5QAcKffSyglVRP6T43hnCaTu5QAcKffSOUAnl(9P5ATDO2q4DxvtSOGLESOUAnlf0xeMY6v5JDOo)kmlXZcaKffSqb9fHj7vz9Q8HffSOUAnB0CDWb8CD2NGxxihT0yFSiC9IybySaq0KmlPPSOUAnB0CDWb8CD2NGxxihT0yFSiC9IyjELzbGOjzwuWIJ)X15iOjAyjEwaojZsAklGW36GE0FiOm2KpDzqVZrr2H68RWSeplaqwstzXd)blRd6r)HGYyt(0Lb9ohfzVk30hQ9NL(SOGLaeQbHMkBWZxfSd15xHzjEwukzJ3iwaujdZBSrLRQjqJ4AS5H)GLXg(9bVguKXgiHdZf9hSm2IDmXY27dEnOiwaWx0VZs0adyw8cKfWvxelXedGyX0ovSGSyIeZTcSahw(DIfaCP63tmSOUAnwomlUkC9S8qwAUwZcS1yboSKaUqhilbpILyIbqgBH5EAo3ytD1Awyr)ooh0Kpzeh(GLDfXsAklQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfXsAklQRwZg88vb7kIffS0Jf1vRzhhbvWfo3gQIrc7qD(vywaglOcG2ohPSa8SeOtZspwC8pUohbnrdliHL4Kml9zbWSehwaEwExt1BlYuUdcllvUQMazrblMXYSkQbhuKfFvBPZ7jWpnNBPYv1eilkyrD1A2XrqfCHZTHQyKWUIyjnLf1vRzdE(QGDOo)kmlaJfubqBNJuwaEwc0PzPhlo(hxNJGMOHfKWsCsML(SKMYI6Q1SJJGk4cNBdvXirgFvBPZ7jWpnNBxrSKMYIzSOUAn74iOcUW52qvmsyxrSOGfZyjaHAqOPYoocQGlCUnufJe2HCWeSKMYIzSeGiOYR3IGQFpXWsFwstzXX)46Ce0enSeplaNKzrbluqFryYEv2RegVrSaianmVXgvUQManIRXMh(dwgB43h8AqrgBGeomx0FWYyZ8tcwEilDoqel)oXIkHFwGnw2EF0WbKf1eSGFpa0vOy5EwwrSaCxxaiDcwUIfVsWc6f0xeMyrD9SaGwASpSC46zXvHRNLhYIkXs0adbc0ylm3tZ5gBVRP6T43hnCaTu5QAcKffSyglZQOgCqr2)6itWPYGd5DQxbsJLkxvtGSOGLESOUAnl(9rdhq7kIL0uwC8pUohbnrdlXZcWjzw6ZIcwuxTMf)(OHdOf)EaiwaglXHffS0Jf1vRzPG(IWugd1(yxrSKMYI6Q1SuqFrykRxLp2vel9zrblQRwZgnxhCapxN9j41fYrln2hlcxViwaglaeqMmlkyPhlbiudcnv2GNVkyhQZVcZs8SOuYSKMYIzSGWNZv1KnaleqGOmiHtubwuWsaIGkVEBDO2)CZjw6B8gXcGXXW8gBu5QAc0iUgBWiJnm9gBE4pyzSHWNZv1KXgcxViJnkOVimzVkRxLpSa8SaazbjS4H)GLf)(0UHSesPW6P8FDelaMfZyHc6lct2RY6v5dlapl9ybqXcGz5DnvVfdx6mSL)Dk3GdHFlvUQMazb4zjoS0NfKWIh(dwwtJ)7wcPuy9u(VoIfaZsYwZbnSGewWrKwN3D8tSayws2IgwaEwExt1Bl)xdHZQU2RazPYv1eOXgiHdZf9hSm2qp8FD(tyw2HMyPBf2zjMyael(qSGYVIazjIgwWuawGgBi8jxEhzS54iaenBuW4nIfanhdZBSrLRQjqJ4AS5H)GLXg(9bVguKXgiHdZf9hSm2ITRUiw2EFWRbfXYvS4SaibmMcSSb1(Wc6f0xeMqllGWcDplA6z5EwIgyGfa0sJ9HLE)U)SCyw29cutGSOMGf6(DAy53jw2EFAUwZI(kIf4WYVtSetmakEGtYSOVIyPbhw2EFWRbf1hTSacl09SarqJP5EIfVybaFr)olrdmWIxGSOPNLFNyXvHiiw0xrSS7fOMyz79rdhqJTWCpnNBSzglZQOgCqr2)6itWPYGd5DQxbsJLkxvtGSOGLESOUAnB0CDWb8CD2NGxxihT0yFSiC9IybySaqazYSKMYI6Q1SrZ1bhWZ1zFcEDHC0sJ9XIW1lIfGXcartYSOGL31u9w8tATpzW5AVLkxvtGS0NffS0JfkOVimzVkJHAFyrblo(hxNJGMOHfaZccFoxvtwhhbGOzJcSa8SOUAnlf0xeMYyO2h7qD(vywamlGW32wtImSLj9Qi7FbGW5H68Ryb4zbGw0Ws8SaatML0uwOG(IWK9QSEv(WIcwC8pUohbnrdlaMfe(CUQMSoocarZgfyb4zrD1AwkOVimL1RYh7qD(vywamlGW32wtImSLj9Qi7FbGW5H68Ryb4zbGw0Ws8SaCsML(SOGfZyrD1Awyr)oohrtGI(dw2velkyXmwExt1BXVpA4aAPYv1eilkyPhlbiudcnv2GNVkyhQZVcZs8SaizjnLfmCPvVc0(7ZP1zmrarJLkxvtGSOGf1vRz)9506mMiGOXIFpaelaJL4ehwaeS0JLzvudoOil(Q2sN3tGFAo3sLRQjqwaEwqdl9zrblTd1(NhQZVcZs8SOuYjZIcwAhQ9ppuNFfMfGXcatozw6ZIcw6Xsac1GqtLfORahcmJJU5ESDOo)kmlXZcGKL0uwmJLaebvE9wGsmNxS034nIfarJH5n2OYv1eOrCn28WFWYyRit5oiSm2ajCyUO)GLXwSJjwaWcHfMLRyb9xLpSGEb9fHjw8cKfSJGyb5mUUb4yZsRzbalewS0GdlilMiXCRalEbYcYPRahcKf0RlcAIMoQEJTWCpnNBS1Jf1vRzPG(IWuwVkFSd15xHzjEwiKsH1t5)6iwstzPhlHDFqrywuMfaYIcwgkS7dkk)xhXcWybnS0NL0uwc7(GIWSOmlXHL(SOGfpkh2PaqSOGfe(CUQMSyhbLBWjh88vbJ3iwaeqzyEJnQCvnbAexJTWCpnNBS1Jf1vRzPG(IWuwVkFSd15xHzjEwiKsH1t5)6iwuWIzSeGiOYR3cuI58IL0uw6XI6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzxrSOGLaebvE9wGsmNxS0NL0uw6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjnLLWUpOimlkZsCyjnLf1vRzdE(QGDfXsFwuWIhLd7uaiwuWccFoxvtwSJGYn4KdE(QalkyPhlQRwZoocQGlCUnufJe2H68RWSamw6XcAybqWcazb4zzwf1GdkYIVQT059e4NMZTu5QAcKL(SOGf1vRzhhbvWfo3gQIrc7kIL0uwmJf1vRzhhbvWfo3gQIrc7kIL(gBE4pyzST76wUdclJ3iwaeqAyEJnQCvnbAexJTWCpnNBS1Jf1vRzPG(IWuwVkFSd15xHzjEwiKsH1t5)6iwuWIzSeGiOYR3cuI58IL0uw6XI6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzxrSOGLaebvE9wGsmNxS0NL0uw6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjnLLWUpOimlkZsCyjnLf1vRzdE(QGDfXsFwuWIhLd7uaiwuWccFoxvtwSJGYn4KdE(QalkyPhlQRwZoocQGlCUnufJe2H68RWSamwqdlkyrD1A2XrqfCHZTHQyKWUIyrblMXYSkQbhuKfFvBPZ7jWpnNBPYv1eilPPSyglQRwZoocQGlCUnufJe2vel9n28WFWYyRT06ChewgVrSaia0W8gBu5QAc0iUgBGeomx0FWYyl2Xelihq0JfyXsa0yZd)blJnt(mhCYWwM0RImEJybqGJH5n2OYv1eOrCn28WFWYyd)(0UHm2ajCyUO)GLXwSJjw2EFA3qS8qwIgyGLnO2hwqVG(IWeAzbzXejMBfyz3XSOjmML)6iw(DVyXzb5y8FNfcPuy9elAQ9SahwGLoblO)Q8Hf0lOVimXYHzzfzSfM7P5CJnkOVimzVkRxLpSKMYcf0xeMSyO2NCri9zjnLfkOVimz9krUiK(SKMYspwuxTM1KpZbNmSLj9Qi7kIL0uwWrKwN3D8tSamws2AoOHffSyglbicQ86TiO63tmSKMYcoI068UJFIfGXsYwZHffSeGiOYR3IGQFpXWsFwuWI6Q1SuqFrykRxLp2velPPS0Jf1vRzdE(QGDOo)kmlaJfp8hSSMg)3TesPW6P8FDelkyrD1A2GNVkyxrS034nIvCs2W8gBu5QAc0iUgBGeomx0FWYyl2XelihJ)7Sa)DAmDyIft7xyNLdZYvSSb1(Wc6f0xeMqllilMiXCRalWHLhYs0adSG(RYhwqVG(IWKXMh(dwgBMg)3nEJyfhLmmVXgvUQManIRXgiHdZf9hSm2InUw)7ZYyZd)blJTzvzp8hSY6d)gB6d)5Y7iJTMR1)(SmEJ3ylAOaSt1FdZBelLmmVXMh(dwgBaDf4qGzC0n3Jn2OYv1eOrCnEJybqdZBSrLRQjqJ4ASbJm2W0BS5H)GLXgcFoxvtgBiC9Im2s2ydKWH5I(dwgBMFNybHpNRQjwomly6z5HSKmlMUFNLcYc(9NfyXYctS8ZvarpgTSOelM2PILFNyPDd(zbwelhMfyXYctOLfaYY1y53jwWuawGSCyw8cKL4WY1yrf(7S4dzSHWNC5DKXgSYlmL)5kGO34nIvCmmVXgvUQManIRXgmYyZbbn28WFWYydHpNRQjJneUErgBkzSfM7P5CJTFUci6TVs2f2v1elky5NRaIE7RKnaHAqOPYcUg)pyzSHWNC5DKXgSYlmL)5kGO34nIL5yyEJnQCvnbAexJnyKXMdcAS5H)GLXgcFoxvtgBiC9Im2aOXwyUNMZn2(5kGO3(a0UWUQMyrbl)Cfq0BFaAdqOgeAQSGRX)dwgBi8jxEhzSbR8ct5FUci6nEJyHgdZBSrLRQjqJ4ASbJm2CqqJnp8hSm2q4Z5QAYydHp5Y7iJnyLxyk)ZvarVXwyUNMZn2iG76IIiq7v4WSExvtzG7YRF1LbjexGyjnLfc4UUOic0sDrjgY1z4awEfiwstzHaURlkIaTy4sRP)VcvEwQjm2ajCyUO)GLXM53jmXYpxbe9yw8HyPGpl(678)cUwNGfq6PWtGS4ywGfllmXc(9NLFUci6XwwIP2KNaZIdcEfkwuILoYlml)oLGftNwZIRn5jWSOsSenuJMHaz5kqkIkqQEwGnwWA4BSHW1lYytjJ3iwakdZBS5H)GLXwhewaDvUbNoJnQCvnbAexJ3iwasdZBSrLRQjqJ4AS5H)GLXMPX)DJn9vuoaASPuYgBH5EAo3yRhluqFryYQxLp5Iq6ZsAkluqFryYEvgd1(WsAkluqFryYEvwf(7SKMYcf0xeMSELixesFw6BSbs4WCr)blJna0qbh)Saqwqog)3zXlqwCw2EFWRbfXcSyzZ8Sy6(DwI1HA)zj24elEbYsCHX08Sahw2EFA3qSa)DAmDyY4nIfa0W8gBu5QAc0iUgBH5EAo3yRhluqFryYQxLp5Iq6ZsAkluqFryYEvgd1(WsAkluqFryYEvwf(7SKMYcf0xeMSELixesFw6ZIcwIgcHvjRPX)DwuWIzSeneclaTMg)3n28WFWYyZ04)UXBelGJH5n2OYv1eOrCn2cZ90CUXMzSmRIAWbfzvDTxbkdBzxRZ)(vOWwQCvnbYsAklMXsaIGkVEBDO2)CZjwstzXmwWrKwNFFqrp2IFFAUwZIYSOelPPSyglVRP6TL)RHWzvx7vGSu5QAcKL0uw6Xcf0xeMSyO2NCri9zjnLfkOVimzVkRxLpSKMYcf0xeMSxLvH)olPPSqb9fHjRxjYfH0NL(gBE4pyzSHFFA3qgVrSukzdZBSrLRQjqJ4ASfM7P5CJTzvudoOiRQR9kqzyl7AD(3Vcf2sLRQjqwuWsaIGkVEBDO2)CZjwuWcoI0687dk6Xw87tZ1AwuMfLm28WFWYyd)(GxdkY4nEJ3ydbn4dwgXcGjdqLsgqMmG0ghJnt(uxHcBSHCetamXYCJfY5aAwyX87elxxeCEwAWHf0bsnFPF0XYqa31neilyyhXIVEyN)eilHDVqrylNe6FfXI5aOzbzWcbnpbYY21HmwWjQ3rklixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkH0(woj0)kIfZbqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velObqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velakanlidwiO5jqw2UoKXcor9oszb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0dGiTVLtc9VIybqcOzbzWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkH0(woj0)kIfajGMfKble08eilO7NRaIERswaa6y5HSGUFUci6TVswaa6yPharAFlNe6FfXcGeqZcYGfcAEcKf09ZvarVfGwaa6y5HSGUFUci6TpaTaa0XspaI0(woj0)kIfaiGMfKble08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6Pes7B5Kq)RiwaoaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNsiTVLtc9VIyrPKb0SGmyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLqAFlNe6FfXIskbOzbzWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkH0(woj0)kIfLaiGMfKble08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6bqK23YjH(xrSOeab0SGmyHGMNazbD)Cfq0BvYcaqhlpKf09ZvarV9vYcaqhl9ais7B5Kq)RiwucGaAwqgSqqZtGSGUFUci6Ta0caqhlpKf09ZvarV9bOfaGow6Pes7B5Kq)RiwukoaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPharAFlNe6FfXIsXbqZcYGfcAEcKf09ZvarVvjlaaDS8qwq3pxbe92xjlaaDS0tjK23YjH(xrSOuCa0SGmyHGMNazbD)Cfq0BbOfaGowEilO7NRaIE7dqlaaDS0dGiTVLtItc5iMayIL5glKZb0SWI53jwUUi48S0GdlOlAOaSt1F0XYqa31neilyyhXIVEyN)eilHDVqrylNe6FfXsCa0SGmyHGMNazbD)Cfq0BvYcaqhlpKf09ZvarV9vYcaqhl9ais7B5Kq)RiwmhanlidwiO5jqwq3pxbe9waAbaOJLhYc6(5kGO3(a0caqhl9ais7B5Kq)RiwaoaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNsiTVLtc9VIyrPKb0SGmyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLqAFlNeNeYrmbWelZnwiNdOzHfZVtSCDrW5zPbhwqNdj0XYqa31neilyyhXIVEyN)eilHDVqrylNe6FfXIsaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yXFwqpa8Opl9ucP9TCsO)velXbqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velakanlidwiO5jqw2UoKXcor9oszb5ICz5HSG(lNLoi4sVWSaJOXF4WspKBFw6Pes7B5Kq)RiwauaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPharAFlNe6FfXcGeqZcYGfcAEcKLTRdzSGtuVJuwqUixwEilO)YzPdcU0lmlWiA8hoS0d52NLEkH0(woj0)kIfajGMfKble08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6Pes7B5Kq)RiwaGaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNsiTVLtc9VIyb4aOzbzWcbnpbYY21HmwWjQ3rklixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEaeP9TCsO)velkbqanlidwiO5jqw2UoKXcor9oszb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0tjK23YjH(xrSOeWbqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velaujanlidwiO5jqw2UoKXcor9oszb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0tjK23YjH(xrSaW4aOzbzWcbnpbYY21HmwWjQ3rklixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEaeP9TCsO)velamoaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNsiTVLtc9VIybGObqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velaeqbOzbzWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkH0(woj0)kIfacab0SGmyHGMNazz76qgl4e17iLfKllpKf0F5SaEio8blwGr04pCyPhs6ZspaI0(woj0)kIfacCa0SGmyHGMNazz76qgl4e17iLfKllpKf0F5SaEio8blwGr04pCyPhs6ZspLqAFlNeNeYrmbWelZnwiNdOzHfZVtSCDrW5zPbhwqxZ16FFwOJLHaURBiqwWWoIfF9Wo)jqwc7EHIWwoj0)kIfacOzbzWcbnpbYY21HmwWjQ3rklixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkH0(wojojKJycGjwMBSqohqZclMFNy56IGZZsdoSGo8Jowgc4UUHazbd7iw81d78NazjS7fkcB5Kq)RiwucqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velXbqZcYGfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ucP9TCsO)velkPeGMfKble08eilBxhYybNOEhPSGCrUS8qwq)LZsheCPxywGr04pCyPhYTpl9ucP9TCsO)velkPeGMfKble08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6Pes7B5Kq)RiwucqbOzbzWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkH0(woj0)kIfaQeGMfKble08eilBxhYybNOEhPSGCz5HSG(lNfWdXHpyXcmIg)Hdl9qsFw6bqK23YjH(xrSaqLa0SGmyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLqAFlNe6FfXcabiGMfKble08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6Pes7B5Kq)RiwayCa0SGmyHGMNazz76qgl4e17iLfKllpKf0F5SaEio8blwGr04pCyPhs6ZsV4G0(woj0)kIfaAoaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPharAFlNe6FfXcabuaAwqgSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNsiTVLtc9VIybGasanlidwiO5jqwq3SkQbhuKfaGowEilOBwf1GdkYcaSu5QAceDS0tjK23YjXjHCetamXYCJfY5aAwyX87elxxeCEwAWHf0Pc9hDSmeWDDdbYcg2rS4Rh25pbYsy3lue2YjH(xrSOeaeqZcYGfcAEcKLTRdzSGtuVJuwqUS8qwq)LZc4H4WhSybgrJ)WHLEiPpl9Ids7B5Kq)Riwuc4aOzbzWcbnpbYY21HmwWjQ3rklixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkH0(wojojZTlcopbYcGIfp8hSyrF4hB5Km2Igy70KXgYJ8Sexx7vGyj2oRdKtc5rEwsAPtWcaeTSaWKbOsCsCsipYZcY29cfHb0CsipYZcGGLyccsGSSb1(WsCjVZYjH8iplacwq2UxOiqwEFqrF(ASeCmHz5HSese0u(9bf9ylNeYJ8Saiybad1brqGSSQIceg7tcwq4Z5QAcZsVZsw0Ys0qiY43h8AqrSaiINLOHqyXVp41GI6B5KqEKNfablXeb8azjAOGJ)RqXcYX4)olxJL7rhMLFNyX0aluSGEb9fHjlNeYJ8SaiybaRdeXcYGfciqel)oXYw0n3JzXzrF)Rjw6GdXstti9u1el9UgljGlw2DWcDpl73ZY9SGVUL(9IGlSoblMUFNL4cGpMMNfaZcYinH)Z1Set9HQ6O6rll3JoqwWaDr9TCsipYZcGGfaSoqelDq8Zc6AhQ9ppuNFfgDSGdu5ZbXS4rr6eS8qwuHymlTd1(Jzbw6ewojojKh5zjMvbF)jqwIRR9kqSetae6ZsWlwujwAWvbYI)SS)FegqJeKO6AVceGaFDblQ73xQ2dIK46AVceGy76qgs6aT7FNg5STttkR6AVcK9r6ZjXj5H)Gf2gnua2P6VYaDf4qGzC0n3J5KqEwm)oXccFoxvtSCywW0ZYdzjzwmD)olfKf87plWILfMy5NRaIEmAzrjwmTtfl)oXs7g8ZcSiwomlWILfMqllaKLRXYVtSGPaSaz5WS4filXHLRXIk83zXhItYd)blSnAOaSt1FaRmsq4Z5QAcTL3rkdR8ct5FUci6rlcxViLtMtYd)blSnAOaSt1FaRmsq4Z5QAcTL3rkdR8ct5FUci6rlmszheeTiC9Iuwj0EnL)5kGO3QKDHDvnP4NRaIERs2aeQbHMkl4A8)GfNKh(dwyB0qbyNQ)awzKGWNZv1eAlVJugw5fMY)Cfq0JwyKYoiiAr46fPmar71u(NRaIElaTlSRQjf)Cfq0BbOnaHAqOPYcUg)pyXjH8Sy(DctS8ZvarpMfFiwk4ZIV(o)VGR1jybKEk8eiloMfyXYctSGF)z5NRaIESLLyQn5jWS4GGxHIfLyPJ8cZYVtjyX0P1S4AtEcmlQelrd1OziqwUcKIOcKQNfyJfSg(CsE4pyHTrdfGDQ(dyLrccFoxvtOT8oszyLxyk)ZvarpAHrk7GGOfHRxKYkH2RPmbCxxuebAVchM17QAkdCxE9RUmiH4cuAkbCxxuebAPUOed56mCalVcuAkbCxxuebAXWLwt)FfQ8SutWj5H)Gf2gnua2P6pGvgjDqyb0v5gC64KqEwaqdfC8Zcazb5y8FNfVazXzz79bVguelWILnZZIP73zjwhQ9NLyJtS4filXfgtZZcCyz79PDdXc83PX0Hjojp8hSW2OHcWov)bSYiX04)oA1xr5aOYkLmAVMY9OG(IWKvVkFYfH0pnLc6lct2RYyO2N0ukOVimzVkRc)90ukOVimz9krUiK(95K8WFWcBJgka7u9hWkJetJ)7O9Ak3Jc6lctw9Q8jxes)0ukOVimzVkJHAFstPG(IWK9QSk83ttPG(IWK1Re5Iq63xr0qiSkznn(VRWSOHqybO104)oNKh(dwyB0qbyNQ)awzKGFFA3qO9AkB2SkQbhuKv11EfOmSLDTo)7xHcNMAwaIGkVEBDO2)CZP0uZWrKwNFFqrp2IFFAUwRSsPPM9UMQ3w(VgcNvDTxbYsLRQjW00EuqFryYIHAFYfH0pnLc6lct2RY6v5tAkf0xeMSxLvH)EAkf0xeMSELixes)(CsE4pyHTrdfGDQ(dyLrc(9bVgueAVMYZQOgCqrwvx7vGYWw2168VFfkSIaebvE926qT)5MtkWrKwNFFqrp2IFFAUwRSsCsCsipYZc6HukSEcKfcbnjy5VoILFNyXdpCy5WS4i8t7QAYYj5H)Gfwzmu7twL8oojKNLn6XSeti6XcSyjoaMft3VdxplGZ1Ew8cKft3VZY27JgoGS4filaeWSa)DAmDyItYd)blmGvgji85CvnH2Y7iLpC2HeAr46fPmoI0687dk6Xw87tZ164vsrpZExt1BXVpA4aAPYv1eyA67AQEl(jT2Nm4CT3sLRQjW(PP4isRZVpOOhBXVpnxRJhGCsiplB0JzjOjhbXIPDQyz79PDdXsWlw2VNfacywEFqrpMft7xyNLdZYqAcHxpln4WYVtSGEb9fHjwEilQelrd1Oziqw8cKft7xyNL2P10WYdzj44NtYd)blmGvgji85CvnH2Y7iLpCoOjhbHweUErkJJiTo)(GIESf)(0UHIxjojKNLyhtSexAW0a0vOyX097SGSyIeZTcSahw82tdlidwiGarSCflilMiXCRaNKh(dwyaRmsuPbtdqxHcTxt5EMfGiOYR3whQ9p3Ckn1SaeQbHMkBawiGar5FNY4OBUhBxr9vOUAnBWZxfSd15xHJxj0OqD1A2XrqfCHZTHQyKWouNFfgyMJcZcqeu51Brq1VNystdqeu51Brq1VNyuOUAnBWZxfSRifQRwZoocQGlCUnufJe2vKIEQRwZoocQGlCUnufJe2H68RWatjLaeOb4Nvrn4GIS4RAlDEpb(P580u1vRzdE(QGDOo)kmWusP0uLqU4isRZ7o(jGPKfnOPpNeYZcac(Sy6(DwCwqwmrI5wbw(D)z5Wf6EwCwaqln2hwIgyGf4WIPDQy53jwAhQ9NLdZIRcxplpKfQa5K8WFWcdyLrse8pyH2RPS6Q1SbpFvWouNFfoELqJIEMnRIAWbfzXx1w68Ec8tZ5PPQRwZoocQGlCUnufJe2H68RWatjaPc1vRzhhbvWfo3gQIrc7kQFAQkeJv0ou7FEOo)kmWaiA4KqEwqMRdlT)eMft70Vtdll8vOybzWcbeiILcAIftNwZIR1qtSKaUy5HSG)tRzj44NLFNyb7DelEhCvplWglidwiGaragzXejMBfyj44hZj5H)GfgWkJee(CUQMqB5DKYbyHaceLbjCIkGweUErkhOt3Rx7qT)5H68RWacLqdGiaHAqOPYg88vb7qD(v4(ixLaGj3x5aD6E9AhQ9ppuNFfgqOeAaekbWKbebiudcnv2aSqabIY)oLXr3Cp2ouNFfUpYvjayY9vy24hyMqq1BDqqSLq6HFCAAac1GqtLn45Rc2H68RWXF1tteu7pbMBhQ9ppuNFfonnaHAqOPYgGfciqu(3Pmo6M7X2H68RWXF1tteu7pbMBhQ9ppuNFfgqOuYPPMfGiOYR3whQ9p3Ckn1d)blBawiGar5FNY4OBUhBbpSRQjqojKNLyhtGS8qwajTNGLFNyzHDuelWglilMiXCRalM2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyANkw8IfheKfcbvplhMfxfUEwEilGhXj5H)GfgWkJee(CUQMqB5DKYbWCawG3FWcTiC9IuU37dk6T)1r5hMbpkELqtA64hyMqq1BDqqS9Q4rtY9v0Rxpc4UUOic0sDrjgY1z4awEfif96fGqni0uzPUOed56mCalVcKDOo)kmWucqLCAAaIGkVElcQ(9eJIaeQbHMkl1fLyixNHdy5vGSd15xHbMsakajG7PKsa)SkQbhuKfFvBPZ7jWpnN3VVcZcqOgeAQSuxuIHCDgoGLxbYoKdMOF)00EeWDDrreOfdxAn9)vOYZsnHIEMfGiOYR3whQ9p3CknnaHAqOPYIHlTM()ku5zPMihhZbnaWKvYouNFfgykPK50VFAAVaeQbHMkRknyAa6ku2HCWePPMnEGS)a16(k61JaURlkIaTxHdZ6DvnLbUlV(vxgKqCbsrac1GqtL9kCywVRQPmWD51V6YGeIlq2HCWe9tt71dHpNRQjlSYlmL)5kGOxzLstr4Z5QAYcR8ct5FUci6voo9v07NRaIERs2HCWe5aeQbHMQ00FUci6TkzdqOgeAQSd15xHJ)QNMiO2Fcm3ou7FEOo)kmGqPK7NMIWNZv1Kfw5fMY)Cfq0Rmav07NRaIElaTd5GjYbiudcnvPP)Cfq0BbOnaHAqOPYouNFfo(REAIGA)jWC7qT)5H68RWacLsUFAkcFoxvtwyLxyk)ZvarVYj3VF)00aebvE9wGsmNx9ttvHySI2HA)Zd15xHbM6Q1SbpFvWcUg)pyXj5H)GfgWkJee(CUQMqB5DKY)(CADgteq0Kn53JweUErkBggU0QxbA)9506mMiGOXsLRQjW002HA)Zd15xHJhGjNCAQkeJv0ou7FEOo)kmWaiAaCpZjzaH6Q1S)(CADgteq0yXVhac4by)0u1vRz)9506mMiGOXIFpau8Xbaci6nRIAWbfzXx1w68Ec8tZ5apA6ZjH8Se7yIf0RlkXqUMfa8dy5vGybGjJPaMfvQbhIfNfKftKyUvGLfMSCsE4pyHbSYizHP89uhAlVJuM6IsmKRZWbS8kqO9AkhGqni0uzdE(QGDOo)kmWayYkcqOgeAQSbyHaceL)DkJJU5ESDOo)kmWayYk6HWNZv1K93NtRZyIaIMSj)(0u1vRz)9506mMiGOXIFpau8Xjza3Bwf1GdkYIVQT059e4NMZbEav)(PPQqmwr7qT)5H68RWaloasojKNLyhtSSbxAn9xHIfaml1eSaOWuaZIk1GdXIZcYIjsm3kWYctwojp8hSWawzKSWu(EQdTL3rkJHlTM()ku5zPMaTxt5aeQbHMkBWZxfSd15xHbgGsHzbicQ86TiO63tmkmlarqLxVTou7FU5uAAaIGkVEBDO2)CZjfbiudcnv2aSqabIY)oLXr3Cp2ouNFfgyakf9q4Z5QAYgGfciqugKWjQqAAac1GqtLn45Rc2H68RWadq1pnnarqLxVfbv)EIrrpZMvrn4GIS4RAlDEpb(P5Cfbiudcnv2GNVkyhQZVcdmavAQ6Q1SJJGk4cNBdvXiHDOo)kmWuYCaCp0a8eWDDrreO9k8pRWdhCg8qCfLvjTUVc1vRzhhbvWfo3gQIrc7kQFAQkeJv0ou7FEOo)kmWaiA4K8WFWcdyLrYct57Po0wEhP8v4WSExvtzG7YRF1LbjexGq71uwD1A2GNVkyhQZVchVsOrrpZMvrn4GIS4RAlDEpb(P580u1vRzhhbvWfo3gQIrc7qD(vyGPeabCV4a8QRwZQQHqq9c)2vuFa3RhGeqGgGxD1AwvnecQx43UI6d8eWDDrreO9k8pRWdhCg8qCfLvjTUVc1vRzhhbvWfo3gQIrc7kQFAQkeJv0ou7FEOo)kmWaiA4KqEwm)(Hz5WS4Sm(VtdlK2vHJ)elM8eS8qw6CGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwmD)olilMiXCRalEbYcYGfciqelEbYYctS87elaSazbRHplWILailxJfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhZj5H)GfgWkJKfMY3tDy0I1WhR8pxbe9kH2RPmcFoxvtwyLxyk)ZvarVYauHz)Cfq0BbODihmroaHAqOPknThcFoxvtwyLxyk)ZvarVYkLMIWNZv1Kfw5fMY)Cfq0RCC6RON6Q1SbpFvWUIu0ZSaebvE9weu97jM0u1vRzhhbvWfo3gQIrc7qD(vya3dna)SkQbhuKfFvBPZ7jWpnN3hyk)ZvarVvjR6Q1YGRX)dwkuxTMDCeubx4CBOkgjSRO0u1vRzhhbvWfo3gQIrIm(Q2sN3tGFAo3UI6NMgGqni0uzdE(QGDOo)kmGby8)Cfq0BvYgGqni0uzbxJ)hSu0ZSaebvE926qT)5MtPPMHWNZv1KnaleqGOmiHtuH(kmlarqLxVfOeZ5vAAaIGkVEBDO2)CZjfi85CvnzdWcbeikds4evqrac1GqtLnaleqGO8VtzC0n3JTRifMfGqni0uzdE(QGDfPOxp1vRzPG(IWuwVkFSd15xHJxPKttvxTMLc6lctzmu7JDOo)kC8kLCFfMnRIAWbfzvDTxbkdBzxRZ)(vOWPP9uxTMv11EfOmSLDTo)7xHcNl)xdzXVhasz0KMQUAnRQR9kqzyl7AD(3Vcfo7tWlYIFpaKYaW(9ttvxTMfORahcmtDrqt00r1NPIguxmi7kQFAQkeJv0ou7FEOo)kmWayYPPi85CvnzHvEHP8pxbe9kNmNKh(dwyaRmswykFp1HrlwdFSY)Cfq0dq0EnLr4Z5QAYcR8ct5FUci6ntzaQWSFUci6TkzhYbtKdqOgeAQstr4Z5QAYcR8ct5FUci6vgGk6PUAnBWZxfSRif9mlarqLxVfbv)EIjnvD1A2XrqfCHZTHQyKWouNFfgW9qdWpRIAWbfzXx1w68Ec8tZ59bMY)Cfq0BbOvD1AzW14)blfQRwZoocQGlCUnufJe2vuAQ6Q1SJJGk4cNBdvXirgFvBPZ7jWpnNBxr9ttdqOgeAQSbpFvWouNFfgWam(FUci6Ta0gGqni0uzbxJ)hSu0ZSaebvE926qT)5MtPPMHWNZv1KnaleqGOmiHtuH(kmlarqLxVfOeZ5LIEMPUAnBWZxfSRO0uZcqeu51Brq1VNy6NMgGiOYR3whQ9p3CsbcFoxvt2aSqabIYGeorfueGqni0uzdWcbeik)7ughDZ9y7ksHzbiudcnv2GNVkyxrk61tD1AwkOVimL1RYh7qD(v44vk50u1vRzPG(IWugd1(yhQZVchVsj3xHzZQOgCqrwvx7vGYWw2168VFfkCAAp1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGugnPPQRwZQ6AVcug2YUwN)9RqHZ(e8IS43daPmaSF)(PPQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfLMQcXyfTd1(NhQZVcdmaMCAkcFoxvtwyLxyk)ZvarVYjZjH8Se7ycZIR1Sa)DAybwSSWel3tDywGflbqojp8hSWawzKSWu(EQdZjH8SeBPWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDyojp8hSWawzKmRk7H)GvwF4hTL3rk7qcT4FUWRSsO9AkJWNZv1K9WzhsCsE4pyHbSYizwv2d)bRS(WpAlVJuwf6pAX)CHxzLq71uEwf1GdkYQ6AVcug2YUwN)9RqHTeWDDrreiNKh(dwyaRmsMvL9WFWkRp8J2Y7iLXpNeNeYZcYCDyP9NWSyAN(DAy53jwITd5Db)d70WI6Q1yX0P1S0CTMfyRXIP73VILFNyPiK(SeC8Zj5H)Gf26qsze(CUQMqB5DKYGd5DztNwNBUwNHTgAr46fPCp1vRz)RJmbNkdoK3PEfin2H68RWadva025ifWjBvknvD1A2)6itWPYGd5DQxbsJDOo)kmW8WFWYIFFA3qwcPuy9u(VocWjBvsrpkOVimzVkRxLpPPuqFryYIHAFYfH0pnLc6lctwVsKlcPF)(kuxTM9VoYeCQm4qEN6vG0yxrkMvrn4GIS)1rMGtLbhY7uVcKgojKNfK56Ws7pHzX0o970WY27dEnOiwomlMGZVZsWX)vOybIGgw2EFA3qSCflO)Q8Hf0lOVimXj5H)Gf26qcWkJee(CUQMqB5DKYhQcoug)(GxdkcTiC9Iu2mkOVimzVkJHAFu0dhrAD(9bf9yl(9PDdfpAu8UMQ3IHlDg2Y)oLBWHWVLkxvtGPP4isRZVpOOhBXVpTBO4bK95KqEwIDmXcYGfciqelM2PIf)zrtyml)UxSGMKzjMyaelEbYI(kILvelMUFNfKftKyUvGtYd)blS1HeGvgjbyHaceL)DkJJU5EmAVMYMboRd0wWCaeROxpe(CUQMSbyHaceLbjCIkOWSaeQbHMkBWZxfSd5GjstvxTMn45Rc2vuFf9uxTMLc6lctz9Q8XouNFfoEavAQ6Q1SuqFrykJHAFSd15xHJhq1xrpZMvrn4GISQU2RaLHTSR15F)ku40u1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGIpoPPQRwZQ6AVcug2YUwN)9RqHZ(e8IS43dafFC6NMQcXyfTd1(NhQZVcdmLswHzbiudcnv2GNVkyhYbt0Ntc5zj2XelXMHQyKGft3VZcYIjsm3kWj5H)Gf26qcWkJKXrqfCHZTHQyKaTxtz1vRzdE(QGDOo)kC8kHgojKNLyhtSSTQ2nelxXsKxGu3fybwS4vIF)kuS87(ZI(qqywuYCWuaZIxGSOjmMft3VZshCiwEFqrpMfVazXFw(DIfQazb2yXzzdQ9Hf0lOVimXI)SOK5WcMcywGdlAcJzzOo)QRqXIJz5HSuWNLDhXvOy5HSmuBi8olGR5kuSG(RYhwqVG(IWeNKh(dwyRdjaRmsWRQDdH2qIGMYVpOOhRSsO9Ak3BO2q4DxvtPPQRwZsb9fHPmgQ9XouNFfgyXrbf0xeMSxLXqTpkgQZVcdmLmhfVRP6Ty4sNHT8Vt5gCi8BPYv1eyFfVpOO3(xhLFyg8O4vYCae4isRZVpOOhd4H68RWk6rb9fHj7vzVsKMouNFfgyOcG2ohP95KqEwqoruelRiw2EFAUwZI)S4Anl)1rywwLMWyww4RqXc6Ni4JJzXlqwUNLdZIRcxplpKLObgyboSOPNLFNybhrHZ1S4H)Gfl6Riwujn0el7EbQjwITd5DQxbsdlWIfaYY7dk6XCsE4pyHToKaSYib)(0CTgTxtzZExt1BXpP1(KbNR9wQCvnbQON6Q1S43NMR12HAdH3DvnPOhoI0687dk6Xw87tZ1AGfN0uZMvrn4GIS)1rMGtLbhY7uVcKM(PPVRP6Ty4sNHT8Vt5gCi8BPYv1eOc1vRzPG(IWugd1(yhQZVcdS4OGc6lct2RYyO2hfQRwZIFFAUwBhQZVcdmaPcCeP153hu0JT43NMR1XRS50xrpZMvrn4GIS6ebFCCUPj6VcvgL(6IWuA6FDeYf5AoOjE1vRzXVpnxRTd15xHbma7R49bf92)6O8dZGhfpA4KqEwqoUFNLTN0AFyj2ox7zzHjwGflbqwmTtfld1gcV7QAIf11Zc(pTMft(9S0GdlOFIGpoMLObgyXlqwaHf6EwwyIfvQbhIfKfBXww2(tRzzHjwuPgCiwqgSqabIybFvGy539NftNwZs0adS4f83PHLT3NMR1CsE4pyHToKaSYib)(0CTgTxt531u9w8tATpzW5AVLkxvtGkuxTMf)(0CT2ouBi8URQjf9mBwf1GdkYQte8XX5MMO)kuzu6RlctPP)1rixKR5GM4nN(kEFqrV9Vok)Wm4rXhhojKNfKJ73zj2oK3PEfinSSWelBVpnxRz5HSaerrSSIy53jwuxTglQjyX1yill8vOyz79P5AnlWIf0WcMcWceZcCyrtymld15xDfkojp8hSWwhsawzKGFFAUwJ2RP8SkQbhuK9VoYeCQm4qEN6vG0OahrAD(9bf9yl(9P5AD8khhf9mtD1A2)6itWPYGd5DQxbsJDfPqD1Aw87tZ1A7qTHW7UQMst7HWNZv1KfCiVlB606CZ16mS1u0tD1Aw87tZ1A7qD(vyGfN0uCeP153hu0JT43NMR1XdqfVRP6T4N0AFYGZ1ElvUQMavOUAnl(9P5ATDOo)kmWqt)(95KqEwqMRdlT)eMft70VtdlolBVp41GIyzHjwmDAnlbFHjw2EFAUwZYdzP5AnlWwdTS4fillmXY27dEnOiwEilaruelX2H8o1RaPHf87bGyzfXj5H)Gf26qcWkJee(CUQMqB5DKY43NMR1ztW6ZnxRZWwdTiC9Iu2X)46Ce0enXdatgq0tPKbE1vRz)RJmbNkdoK3PEfinw87bG6di6PUAnl(9P5ATDOo)kmWhhKloI068UJFc4n7DnvVf)Kw7tgCU2BPYv1eyFarVaeQbHMkl(9P5ATDOo)kmWhhKloI068UJFc4Fxt1BXpP1(KbNR9wQCvnb2hq0de(22AsKHTmPxfzhQZVcd8OPVIEQRwZIFFAUwBxrPPbiudcnvw87tZ1A7qD(v4(CsiplXoMyz79bVguelMUFNLy7qEN6vG0WYdzbiIIyzfXYVtSOUAnwmD)oC9SOH4RqXY27tZ1Awwr)1rS4fillmXY27dEnOiwGflMdGzjUWyAEwWVhacZYQ(tZI5WY7dk6XCsE4pyHToKaSYib)(GxdkcTxtze(CUQMSGd5DztNwNBUwNHTMce(CUQMS43NMR1ztW6ZnxRZWwtHzi85CvnzpufCOm(9bVguuAAp1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGIpoPPQRwZQ6AVcug2YUwN)9RqHZ(e8IS43dafFC6RahrAD(9bf9yl(9P5AnWmhfi85CvnzXVpnxRZMG1NBUwNHTgNeYZsSJjwWM8PJfmKLF3FwsaxSGIEw6CKYYk6VoIf1eSSWxHIL7zXXSO9NyXXSebX4tvtSalw0egZYV7flXHf87bGWSahwaWzHFwmTtflXbWSGFpaeMfcPr3qCsE4pyHToKaSYiXb9O)qqzSjF6qBirqt53hu0Jvwj0EnLn7VaqxHsHzE4pyzDqp6peugBYNUmO35Oi7v5M(qT)PPGW36GE0FiOm2KpDzqVZrrw87bGawCuacFRd6r)HGYyt(0Lb9ohfzhQZVcdS4WjH8SaGHAdH3zbalewTBiwUglilMiXCRalhMLHCWeOLLFNgIfFiw0egZYV7flOHL3hu0Jz5kwq)v5dlOxqFryIft3VZYg8JnOLfnHXS87EXIsjZc83PX0HjwUIfVsWc6f0xeMyboSSIy5HSGgwEFqrpMfvQbhIfNf0Fv(Wc6f0xeMSSeBHf6EwgQneENfW1CfkwqoDf4qGSGEDrqt00r1ZYQ0egZYvSSb1(Wc6f0xeM4K8WFWcBDibyLrshewTBi0gse0u(9bf9yLvcTxt5HAdH3DvnP49bf92)6O8dZGhfFVEkzoaUhoI0687dk6Xw87t7gc4biWRUAnlf0xeMY6v5JDf1VpGhQZVc3h52tja)UMQ3(MUk3bHf2sLRQjW(k6fGqni0uzdE(QGDihmHcZaN1bAlyoaIv0dHpNRQjBawiGarzqcNOcPPbiudcnv2aSqabIY)oLXr3Cp2oKdMin1SaebvE926qT)5Mt9ttXrKwNFFqrp2IFFA3qaRxpafGON6Q1SuqFrykRxLp2veWdW(9b(Ekb431u9230v5oiSWwQCvnb2VVcZOG(IWKfd1(KlcPFAApkOVimzVkJHAFst7rb9fHj7vzv4VNMsb9fHj7vz9Q8PVcZExt1BXWLodB5FNYn4q43sLRQjW0u1vRzJMRdoGNRZ(e86c5OLg7JfHRxu8kdq0KCFf9WrKwNFFqrp2IFFA3qatPKb(Ekb431u9230v5oiSWwQCvnb2VVch)JRZrqt0epAsgqOUAnl(9P5ATDOo)kmWdO6RONzQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfLMsb9fHj7vzmu7tAQzbicQ86TaLyoV6RWm1vRzhhbvWfo3gQIrIm(Q2sN3tGFAo3UI4KqEwIDmXsSbglwGflbqwmD)oC9Se8OORqXj5H)Gf26qcWkJKgCcug2YL)RHq71u2JYHDkaeNKh(dwyRdjaRmsq4Z5QAcTL3rkhaZbybE)bRSdj0IW1lszZaN1bAlyoaIvGWNZv1KnaMdWc8(dwk61tD1Aw87tZ1A7kkn9DnvVf)Kw7tgCU2BPYv1eyAAaIGkVEBDO2)CZP(k6zM6Q1SyOg)xGSRifMPUAnBWZxfSRif9m7DnvVTTMezylt6vrwQCvnbMMQUAnBWZxfSGRX)dwXhGqni0uzBRjrg2YKEvKDOo)kmGbG9vGWNZv1K93NtRZyIaIMSj)Ef9mlarqLxVTou7FU5uAAac1GqtLnaleqGO8VtzC0n3JTRif9uxTMf)(0CT2ouNFfgyamn1S31u9w8tATpzW5AVLkxvtG97R49bf92)6O8dZGhfV6Q1SbpFvWcUg)pyb8jBbK9ttBhQ9ppuNFfgyQRwZg88vbl4A8)GvFojKNLyhtSGSyIeZTcSalwcGSSknHXS4fil6RiwUNLvelMUFNfKbleqGiojp8hSWwhsawzKeinH)Z1zxFOQoQE0EnLr4Z5QAYgaZbybE)bRSdjojp8hSWwhsawzKCvWNY)dwO9AkJWNZv1KnaMdWc8(dwzhsCsiplXoMyb96IGMOHL4clqwGflbqwmD)olBVpnxRzzfXIxGSGDeeln4WcaAPX(WIxGSGSyIeZTcCsE4pyHToKaSYiH6IGMOjRclq0EnLvHySIREAIGA)jWC7qT)5H68RWatj0KM2tD1A2O56Gd456SpbVUqoAPX(yr46fbmaIMKttvxTMnAUo4aEUo7tWRlKJwASpweUErXRmartY9vOUAnl(9P5ATDfPOxac1GqtLn45Rc2H68RWXJMKttbN1bAlyoaI7ZjH8SaGHAdH3zPP9HybwSSIy5HSehwEFqrpMft3VdxplilMiXCRalQ0vOyXvHRNLhYcH0OBiw8cKLc(SarqtWJIUcfNKh(dwyRdjaRmsWpP1(KBAFi0gse0u(9bf9yLvcTxt5HAdH3DvnP4Vok)Wm4rXReAuGJiTo)(GIESf)(0UHaM5OWJYHDkaKIEQRwZg88vb7qD(v44vk50uZuxTMn45Rc2vuFojKNLyhtSeBGOhlxJLRWhiXIxSGEb9fHjw8cKf9vel3ZYkIft3VZIZcaAPX(Ws0adS4filXe0J(dbXYMjF64K8WFWcBDibyLrsBnjYWwM0RIq71uMc6lct2RYELqHhLd7uaifQRwZgnxhCapxN9j41fYrln2hlcxViGbq0KSIEGW36GE0FiOm2KpDzqVZrr2)caDfQ0uZcqeu51BlkmqnCattXrKwNFFqrpoEa2xrp1vRzhhbvWfo3gQIrc7qD(vyGbCae9qdWpRIAWbfzXx1w68Ec8tZ59vOUAn74iOcUW52qvmsyxrPPMPUAn74iOcUW52qvmsyxr9v0ZSaeQbHMkBWZxfSRO0u1vRz)9506mMiGOXIFpaeWucnkAhQ9ppuNFfgyam5Kv0ou7FEOo)kC8kLCYPPMHHlT6vG2FFoToJjciASu5QAcSVIEy4sREfO93NtRZyIaIglvUQMattdqOgeAQSbpFvWouNFfo(4KCFojKNLyhtS4SS9(0CTMfa8f97SenWalRstymlBVpnxRz5WS46HCWeSSIyboSKaUyXhIfxfUEwEilqe0e8iwIjgaXj5H)Gf26qcWkJe87tZ1A0EnLvxTMfw0VJZr0eOO)GLDfPON6Q1S43NMR12HAdH3DvnLM64FCDocAIM4boj3Ntc5zj2U6IyjMyaelQudoelidwiGarSy6(Dw2EFAUwZIxGS87uXY27dEnOiojp8hSWwhsawzKGFFAUwJ2RPCaIGkVEBDO2)CZjfM9UMQ3IFsR9jdox7Tu5QAcurpe(CUQMSbyHaceLbjCIkKMgGqni0uzdE(QGDfLMQUAnBWZxfSRO(kcqOgeAQSbyHaceL)DkJJU5ESDOo)kmWqfaTDosb(aD6Eo(hxNJGMOb5IMK7RqD1Aw87tZ1A7qD(vyGzokmdCwhOTG5aiMtYd)blS1HeGvgj43h8AqrO9AkhGiOYR3whQ9p3Csrpe(CUQMSbyHaceLbjCIkKMgGqni0uzdE(QGDfLMQUAnBWZxfSRO(kcqOgeAQSbyHaceL)DkJJU5ESDOo)kmWaukuxTMf)(0CT2UIuqb9fHj7vzVsOWme(CUQMShQcoug)(GxdksHzGZ6aTfmhaXCsiplXoMyz79bVguelMUFNfVybaFr)olrdmWcCy5ASKaUqhilqe0e8iwIjgaXIP73zjbCnSuesFwco(TSetngYc4QlILyIbqS4pl)oXcvGSaBS87ela4s1VNyyrD1ASCnw2EFAUwZIj4sdwO7zP5AnlWwJf4Wsc4IfFiwGflaKL3hu0J5K8WFWcBDibyLrc(9bVgueAVMYQRwZcl63X5GM8jJ4WhSSRO00EMHFFA3qwpkh2PaqkmdHpNRQj7HQGdLXVp41GIst7PUAnBWZxfSd15xHbgAuOUAnBWZxfSRO00E9uxTMn45Rc2H68RWadva025if4d0P754FCDocAIgKBCsUVc1vRzdE(QGDfLMQUAn74iOcUW52qvmsKXx1w68Ec8tZ52H68RWadva025if4d0P754FCDocAIgKBCsUVc1vRzhhbvWfo3gQIrIm(Q2sN3tGFAo3UI6RiarqLxVfbv)EIPFFf9WrKwNFFqrp2IFFAUwdS4KMIWNZv1Kf)(0CToBcwFU5ADg2A97RWme(CUQMShQcoug)(GxdksrpZMvrn4GIS)1rMGtLbhY7uVcKM0uCeP153hu0JT43NMR1alo95KqEwIDmXcawiSWSCflBqTpSGEb9fHjw8cKfSJGyj2S0AwaWcHfln4WcYIjsm3kWj5H)Gf26qcWkJKImL7GWcTxt5EQRwZsb9fHPmgQ9XouNFfoEcPuy9u(VoknTxy3huewzaQyOWUpOO8FDeWqt)00WUpOiSYXPVcpkh2PaqCsE4pyHToKaSYiz31TChewO9Ak3tD1AwkOVimLXqTp2H68RWXtiLcRNY)1rPP9c7(GIWkdqfdf29bfL)RJagA6NMg29bfHvoo9v4r5Wofasrp1vRzhhbvWfo3gQIrc7qD(vyGHgfQRwZoocQGlCUnufJe2vKcZMvrn4GIS4RAlDEpb(P580uZuxTMDCeubx4CBOkgjSRO(CsE4pyHToKaSYiPT06ChewO9Ak3tD1AwkOVimLXqTp2H68RWXtiLcRNY)1rk6fGqni0uzdE(QGDOo)kC8Oj500aeQbHMkBawiGar5FNY4OBUhBhQZVchpAsUFAAVWUpOiSYauXqHDFqr5)6iGHM(PPHDFqryLJtFfEuoStbGu0tD1A2XrqfCHZTHQyKWouNFfgyOrH6Q1SJJGk4cNBdvXiHDfPWSzvudoOil(Q2sN3tGFAopn1m1vRzhhbvWfo3gQIrc7kQpNeYZsSJjwqoGOhlWIfKfB5K8WFWcBDibyLrIjFMdozylt6vrCsipliZ1HL2FcZIPD63PHLhYYctSS9(0UHy5kw2GAFyX0(f2z5WS4plOHL3hu0JbSsS0GdlecAsWcatg5YsNJFAsWcCyXCyz79bVguelOxxe0enDu9SGFpaeMtYd)blS1HeGvgji85CvnH2Y7iLXVpTBO8vzmu7dAr46fPmoI0687dk6Xw87t7gkEZbWnneo96C8ttImcxViGxPKtg5cWK7d4MgcNEQRwZIFFWRbfLPUiOjA6O6ZyO2hl(9aqixZPpNeYZcYCDyP9NWSyAN(DAy5HSGCm(VZc4AUcflXMHQyKGtYd)blS1HeGvgji85CvnH2Y7iLnn(VNVk3gQIrc0IW1lszLqU4isRZ7o(jGbqarVKTae47HJiTo)(GIESf)(0UHaek1h47PeGFxt1BXWLodB5FNYn4q43sLRQjqGxjlA63hWjBvcnaV6Q1SJJGk4cNBdvXiHDOo)kmNeYZsSJjwqog)3z5kw2GAFyb9c6lctSahwUglfKLT3N2nelMoTML29SC1dzbzXejMBfyXReDWH4K8WFWcBDibyLrIPX)D0EnL7rb9fHjREv(KlcPFAkf0xeMSELixesFfi85CvnzpCoOjhb1xrV3hu0B)RJYpmdEu8MtAkf0xeMS6v5t(QmattBhQ9ppuNFfgykLC)0u1vRzPG(IWugd1(yhQZVcdmp8hSS43N2nKLqkfwpL)RJuOUAnlf0xeMYyO2h7kknLc6lct2RYyO2hfMHWNZv1Kf)(0UHYxLXqTpPPQRwZg88vb7qD(vyG5H)GLf)(0UHSesPW6P8FDKcZq4Z5QAYE4CqtocsH6Q1SbpFvWouNFfgyesPW6P8FDKc1vRzdE(QGDfLMQUAn74iOcUW52qvmsyxrkq4Z5QAYAA8FpFvUnufJePPMHWNZv1K9W5GMCeKc1vRzdE(QGDOo)kC8esPW6P8FDeNeYZsSJjw2EFA3qSCnwUIf0Fv(Wc6f0xeMqllxXYgu7dlOxqFryIfyXI5aywEFqrpMf4WYdzjAGbw2GAFyb9c6lctCsE4pyHToKaSYib)(0UH4KqEwInUw)7ZItYd)blS1HeGvgjZQYE4pyL1h(rB5DKYnxR)9zXjXjH8SeBgQIrcwmD)olilMiXCRaNKh(dwyRk0FLhhbvWfo3gQIrc0EnLvxTMn45Rc2H68RWXReA4KqEwIDmXsmb9O)qqSSzYNowmTtfl(ZIMWyw(DVyXCyjUWyAEwWVhacZIxGS8qwgQneENfNfGPmazb)EaiwCmlA)jwCmlrqm(u1elWHL)6iwUNfmKL7zXN5qqywaWzHFw82tdlolXbWSGFpaelesJUHWCsE4pyHTQq)bSYiXb9O)qqzSjF6qBirqt53hu0Jvwj0EnLvxTMv11EfOmSLDTo)7xHcNl)xdzXVhacyaqfQRwZQ6AVcug2YUwN)9RqHZ(e8IS43dabmaOIEMbcFRd6r)HGYyt(0Lb9ohfz)la0vOuyMh(dwwh0J(dbLXM8Pld6DokYEvUPpu7VIEMbcFRd6r)HGYyt(0L3jxB)la0vOstbHV1b9O)qqzSjF6Y7KRTd15xHJpo9ttbHV1b9O)qqzSjF6YGENJIS43dabS4Oae(wh0J(dbLXM8Pld6DokYouNFfgyOrbi8ToOh9hckJn5txg07CuK9VaqxHQpNeYZsSJjwqgSqabIyX097SGSyIeZTcSyANkwIGy8PQjw8cKf4VtJPdtSy6(DwCwIlmMMNf1vRXIPDQybKWjQWvO4K8WFWcBvH(dyLrsawiGar5FNY4OBUhJ2RPSzGZ6aTfmhaXk61dHpNRQjBawiGarzqcNOckmlaHAqOPYg88vb7qoyI0u1vRzdE(QGDf1xrp1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGugaMMQUAnRQR9kqzyl7AD(3Vcfo7tWlYIFpaKYaW(PPQqmwr7qT)5H68RWatPK7ZjH8SeBGOhloMLFNyPDd(zbvaKLRy53jwCwIlmMMNftxbcnXcCyX097S87eliNsmNxSOUAnwGdlMUFNfNfaiGXuGLyc6r)HGyzZKpDS4filM87zPbhwqwmrI5wbwUgl3ZIjy9SOsSSIyXr5xXIk1GdXYVtSeaz5WS0U6W7eiNKh(dwyRk0FaRmsARjrg2YKEveAVMY961tD1Awvx7vGYWw2168VFfkCU8FnKf)EaO4buPPQRwZQ6AVcug2YUwN)9RqHZ(e8IS43dafpGQVIEMfGiOYR3IGQFpXKMAM6Q1SJJGk4cNBdvXiHDf1VVIEGZ6aTfmhaXPPbiudcnv2GNVkyhQZVchpAsonTxaIGkVEBDO2)CZjfbiudcnv2aSqabIY)oLXr3Cp2ouNFfoE0KC)(9tt7bcFRd6r)HGYyt(0Lb9ohfzhQZVchpaurac1GqtLn45Rc2H68RWXRuYkcqeu51BlkmqnCa7NMQcXyfx90eb1(tG52HA)Zd15xHbgauHzbiudcnv2GNVkyhYbtKMgGiOYR3cuI58sH6Q1SaDf4qGzQlcAIMoQE7kknnarqLxVfbv)EIrH6Q1SJJGk4cNBdvXiHDOo)kmWaokuxTMDCeubx4CBOkgjSRiojKNfK5vG0SS9(OHdilMUFNfNLImXsCHX08SOUAnw8cKfKftKyUvGLdxO7zXvHRNLhYIkXYctGCsE4pyHTQq)bSYij4vG0z1vRH2Y7iLXVpA4aI2RPCp1vRzvDTxbkdBzxRZ)(vOW5Y)1q2H68RWXdiTOjnvD1Awvx7vGYWw2168VFfkC2NGxKDOo)kC8aslA6ROxac1GqtLn45Rc2H68RWXditt7fGqni0uzPUiOjAYQWc0ouNFfoEaPcZuxTMfORahcmtDrqt00r1NPIguxmi7ksraIGkVElqjMZR(9v44FCDocAIM4voojZjH8SeBxDrSS9(GxdkcZIP73zXzjUWyAEwuxTglQRNLc(SyANkwIGq9vOyPbhwqwmrI5wbwGdliNUcCiqw2IU5EmNKh(dwyRk0FaRmsWVp41GIq71uUN6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqXdW0u1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGIhG9v0larqLxVTou7FU5uAAac1GqtLn45Rc2H68RWXdittndHpNRQjBamhGf49hSuywaIGkVElqjMZR00EbiudcnvwQlcAIMSkSaTd15xHJhqQWm1vRzb6kWHaZuxe0enDu9zQOb1fdYUIueGiOYR3cuI58QFFf9mde(22AsKHTmPxfz)la0vOstnlaHAqOPYg88vb7qoyI0uZcqOgeAQSbyHaceL)DkJJU5ESDihmrFojKNLy7QlILT3h8AqrywuPgCiwqgSqabI4K8WFWcBvH(dyLrc(9bVgueAVMY9cqOgeAQSbyHaceL)DkJJU5ESDOo)kmWqJcZaN1bAlyoaIv0dHpNRQjBawiGarzqcNOcPPbiudcnv2GNVkyhQZVcdm00xbcFoxvt2ayoalW7py1xHzGW32wtImSLj9Qi7FbGUcLIaebvE926qT)5MtkmdCwhOTG5aiwbf0xeMSxL9kHch)JRZrqt0eV5KmNeYZsSfwO7zbe(SaUMRqXYVtSqfilWglayCeubxywIndvXibAzbCnxHIfGUcCiqwOUiOjA6O6zboSCfl)oXI2XplOcGSaBS4flOxqFryItYd)blSvf6pGvgji85CvnH2Y7iLbHFEiG76gQJQhJweUErk3tD1A2XrqfCHZTHQyKWouNFfoE0KMAM6Q1SJJGk4cNBdvXiHDf1xrp1vRzb6kWHaZuxe0enDu9zQOb1fdYouNFfgyOcG2ohP9v0tD1AwkOVimLXqTp2H68RWXJkaA7CKMMQUAnlf0xeMY6v5JDOo)kC8OcG2ohP95K8WFWcBvH(dyLrcEvTBi0gse0u(9bf9yLvcTxt5HAdH3DvnP49bf92)6O8dZGhfVsakfEuoStbGuGWNZv1Kfe(5HaURBOoQEmNKh(dwyRk0FaRms6GWQDdH2qIGMYVpOOhRSsO9AkpuBi8URQjfVpOO3(xhLFyg8O4vkow0OWJYHDkaKce(CUQMSGWppeWDDd1r1J5K8WFWcBvH(dyLrc(jT2NCt7dH2qIGMYVpOOhRSsO9AkpuBi8URQjfVpOO3(xhLFyg8O4vcqb4H68RWk8OCyNcaPaHpNRQjli8ZdbCx3qDu9yojKNLydmwSalwcGSy6(D46zj4rrxHItYd)blSvf6pGvgjn4eOmSLl)xdH2RPShLd7uaiojKNf0RlcAIgwIlSazX0ovS4QW1ZYdzHQNgwCwkYelXfgtZZIPRaHMyXlqwWocILgCybzXejMBf4K8WFWcBvH(dyLrc1fbnrtwfwGO9Ak3Jc6lctw9Q8jxes)0ukOVimzXqTp5Iq6NMsb9fHjRxjYfH0pnvD1Awvx7vGYWw2168VFfkCU8FnKDOo)kC8aslAstvxTMv11EfOmSLDTo)7xHcN9j4fzhQZVchpG0IM0uh)JRZrqt0epWjzfbiudcnv2GNVkyhYbtOWmWzDG2cMdG4(k6fGqni0uzdE(QGDOo)kC8Xj500aeQbHMkBWZxfSd5Gj6NMQcXyfx90eb1(tG52HA)Zd15xHbMsjZjH8SeBGOhlZHA)zrLAWHyzHVcflilMCsE4pyHTQq)bSYiPTMezylt6vrO9AkhGqni0uzdE(QGDihmHce(CUQMSbWCawG3FWsrph)JRZrqt0epWjzfMfGiOYR3whQ9p3CknnarqLxVTou7FU5Kch)JRZrqt0amZj5(kmlarqLxVfbv)EIrrpZcqeu51BRd1(NBoLMgGqni0uzdWcbeik)7ughDZ9y7qoyI(kmdCwhOTG5aiMtc5zbzXejMBfyX0ovS4plaNKbmlXedGyPhC0qt0WYV7flMtYSetmaIft3VZcYGfciquFwmD)oC9SOH4RqXYFDelxXsC1qiOEHFw8cKf9velRiwmD)olidwiGarSCnwUNftoMfqcNOceiNKh(dwyRk0FaRmsq4Z5QAcTL3rkhaZbybE)bRSk0F0IW1lszZaN1bAlyoaIvGWNZv1KnaMdWc8(dwk61ZX)46Ce0enXdCswrp1vRzb6kWHaZuxe0enDu9zQOb1fdYUIstnlarqLxVfOeZ5v)0u1vRzv1qiOEHF7ksH6Q1SQAieuVWVDOo)kmWuxTMn45RcwW14)bR(PPx90eb1(tG52HA)Zd15xHbM6Q1SbpFvWcUg)pyLMgGiOYR3whQ9p3CQVIEMfGiOYR3whQ9p3CknTNJ)X15iOjAaM5KCAki8TT1KidBzsVkY(xaORq1xrpe(CUQMSbyHaceLbjCIkKMgGqni0uzdWcbeik)7ughDZ9y7qoyI(95K8WFWcBvH(dyLrsG0e(pxND9HQ6O6r71ugHpNRQjBamhGf49hSYQq)5K8WFWcBvH(dyLrYvbFk)pyH2RPmcFoxvt2ayoalW7pyLvH(ZjH8SGE4)68NWSSdnXs3kSZsmXaiw8HybLFfbYsenSGPaSa5K8WFWcBvH(dyLrccFoxvtOT8oszhhbGOzJcOfHRxKYuqFryYEvwVkFaEaiY1d)bll(9PDdzjKsH1t5)6iaBgf0xeMSxL1RYhGVhGcWVRP6Ty4sNHT8Vt5gCi8BPYv1eiWhN(ixp8hSSMg)3TesPW6P8FDeGt2cqKloI068UJFItc5zj2U6Iyz79bVgueMft7uXYVtS0ou7plhMfxfUEwEilubIwwAdvXiblhMfxfUEwEilubIwwsaxS4dXI)SaCsgWSetmaILRyXlwqVG(IWeAzbzXejMBfyr74hZIxWFNgwaGagtbmlWHLeWflMGlnilqe0e8iw6GdXYV7flCQsjZsmXaiwmTtfljGlwmbxAWcDplBVp41GIyPGM4K8WFWcBvH(dyLrc(9bVgueAVMY9uHySIREAIGA)jWC7qT)5H68RWaZCst7PUAn74iOcUW52qvmsyhQZVcdmubqBNJuGpqNUNJ)X15iOjAqUXj5(kuxTMDCeubx4CBOkgjSRO(9tt754FCDocAIgaJWNZv1K1XraiA2OaWRUAnlf0xeMYyO2h7qD(vyadcFBBnjYWwM0RIS)facNhQZVc4bOfnXRKsjNM64FCDocAIgaJWNZv1K1XraiA2OaWRUAnlf0xeMY6v5JDOo)kmGbHVTTMezylt6vr2)caHZd15xb8a0IM4vsPK7RGc6lct2RYELqrpZuxTMn45Rc2vuAQzVRP6T43hnCaTu5QAcSVIE9mlaHAqOPYg88vb7kknnarqLxVfOeZ5LcZcqOgeAQSuxe0enzvybAxr9ttdqeu51BRd1(NBo1xrpZcqeu51Brq1VNystntD1A2GNVkyxrPPo(hxNJGMOjEGtY9tt79UMQ3IFF0Wb0sLRQjqfQRwZg88vb7ksrp1vRzXVpA4aAXVhacyXjn1X)46Ce0enXdCsUF)0u1vRzdE(QGDfPWm1vRzhhbvWfo3gQIrc7ksHzVRP6T43hnCaTu5QAcKtc5zj2XelayHWcZYvSG(RYhwqVG(IWelEbYc2rqSGCgx3aCSzP1SaGfclwAWHfKftKyUvGtYd)blSvf6pGvgjfzk3bHfAVMY9uxTMLc6lctz9Q8XouNFfoEcPuy9u(VoknTxy3huewzaQyOWUpOO8FDeWqt)00WUpOiSYXPVcpkh2PaqCsE4pyHTQq)bSYiz31TChewO9Ak3tD1AwkOVimL1RYh7qD(v44jKsH1t5)6if9cqOgeAQSbpFvWouNFfoE0KCAAac1GqtLnaleqGO8VtzC0n3JTd15xHJhnj3pnTxy3huewzaQyOWUpOO8FDeWqt)00WUpOiSYXPVcpkh2PaqCsE4pyHTQq)bSYiPT06ChewO9Ak3tD1AwkOVimL1RYh7qD(v44jKsH1t5)6if9cqOgeAQSbpFvWouNFfoE0KCAAac1GqtLnaleqGO8VtzC0n3JTd15xHJhnj3pnTxy3huewzaQyOWUpOO8FDeWqt)00WUpOiSYXPVcpkh2PaqCsiplihq0JfyXsaKtYd)blSvf6pGvgjM8zo4KHTmPxfXjH8Se7yILT3N2nelpKLObgyzdQ9Hf0lOVimXcCyX0ovSCflWsNGf0Fv(Wc6f0xeMyXlqwwyIfKdi6Xs0adywUglxXc6VkFyb9c6lctCsE4pyHTQq)bSYib)(0UHq71uMc6lct2RY6v5tAkf0xeMSyO2NCri9ttPG(IWK1Re5Iq6NMQUAnRjFMdozylt6vr2vKc1vRzPG(IWuwVkFSRO00EQRwZg88vb7qD(vyG5H)GL104)ULqkfwpL)RJuOUAnBWZxfSRO(CsE4pyHTQq)bSYiX04)oNKh(dwyRk0FaRmsMvL9WFWkRp8J2Y7iLBUw)7ZItItc5zz79bVgueln4Wsheb1r1ZYQ0egZYcFfkwIlmMMNtYd)blST5A9VplLXVp41GIq71u2SzvudoOiRQR9kqzyl7AD(3Vcf2sa31ffrGCsipliZXpl)oXci8zX097S87elDq8ZYFDelpKfheKLv9NMLFNyPZrklGRX)dwSCyw2V3YY2QA3qSmuNFfMLUL(Vi9rGS8qw68pSZshewTBiwaxJ)hS4K8WFWcBBUw)7ZcWkJe8QA3qOnKiOP87dk6XkReAVMYGW32bHv7gYouNFfo(H68RWapabiYvjaiNKh(dwyBZ16FFwawzK0bHv7gItItc5zj2XelBVp41GIy5HSaerrSSIy53jwITd5DQxbsdlQRwJLRXY9SycU0GSqin6gIfvQbhIL2vhE)kuS87elfH0NLGJFwGdlpKfWvxelQudoelidwiGarCsE4pyHT4xz87dEnOi0EnLNvrn4GIS)1rMGtLbhY7uVcKgf9OG(IWK9QSxjuywVEQRwZ(xhzcovgCiVt9kqASd15xHJ3d)blRPX)DlHukSEk)xhb4KTkPOhf0xeMSxLvH)EAkf0xeMSxLXqTpPPuqFryYQxLp5Iq63pnvD1A2)6itWPYGd5DQxbsJDOo)kC8E4pyzXVpTBilHukSEk)xhb4KTkPOhf0xeMSxL1RYN0ukOVimzXqTp5Iq6NMsb9fHjRxjYfH0VF)0uZuxTM9VoYeCQm4qEN6vG0yxr9tt7PUAnBWZxfSRO0ue(CUQMSbyHaceLbjCIk0xrac1GqtLnaleqGO8VtzC0n3JTd5GjueGiOYR3whQ9p3CQVIEMfGiOYR3cuI58knnaHAqOPYsDrqt0KvHfODOo)kC8aW(k6PUAnBWZxfSRO0uZcqOgeAQSbpFvWoKdMOpNeYZsSJjwIjOh9hcILnt(0XIPDQy53PHy5WSuqw8WFiiwWM8PdTS4yw0(tS4ywIGy8PQjwGflyt(0XIP73zbGSahwAKjAyb)EaimlWHfyXIZsCamlyt(0XcgYYV7pl)oXsrMybBYNow8zoeeMfaCw4NfV90WYV7plyt(0XcH0OBimNKh(dwyl(bSYiXb9O)qqzSjF6qBirqt53hu0Jvwj0EnLnde(wh0J(dbLXM8Pld6DokY(xaORqPWmp8hSSoOh9hckJn5txg07CuK9QCtFO2Ff9mde(wh0J(dbLXM8PlVtU2(xaORqLMccFRd6r)HGYyt(0L3jxBhQZVchpA6NMccFRd6r)HGYyt(0Lb9ohfzXVhacyXrbi8ToOh9hckJn5txg07CuKDOo)kmWIJcq4BDqp6peugBYNUmO35Oi7FbGUcfNeYZsSJjmlidwiGarSCnwqwmrI5wbwomlRiwGdljGlw8HybKWjQWvOybzXejMBfyX097SGmyHaceXIxGSKaUyXhIfvsdnXI5KmlXedG4K8WFWcBXpGvgjbyHaceL)DkJJU5EmAVMYMboRd0wWCaeROxpe(CUQMSbyHaceLbjCIkOWSaeQbHMkBWZxfSd5Gjuy2SkQbhuKnAUo4aEUo7tWRlKJwASpPPQRwZg88vb7kQVch)JRZrqt0amLnNKv0tD1AwkOVimL1RYh7qD(v44vk50u1vRzPG(IWugd1(yhQZVchVsj3pnvfIXkAhQ9ppuNFfgykLScZcqOgeAQSbpFvWoKdMOpNeYZcYGf49hSyPbhwCTMfq4Jz539NLohicZcEnel)oLGfFOcDpld1gcVtGSyANkwaW4iOcUWSeBgQIrcw2DmlAcJz539If0WcMcywgQZV6kuSahw(DIfGsmNxSOUAnwomlUkC9S8qwAUwZcS1yboS4vcwqVG(IWelhMfxfUEwEilesJUH4K8WFWcBXpGvgji85CvnH2Y7iLbHFEiG76gQJQhJweUErk3tD1A2XrqfCHZTHQyKWouNFfoE0KMAM6Q1SJJGk4cNBdvXiHDf1xHzQRwZoocQGlCUnufJez8vTLoVNa)0CUDfPON6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzhQZVcdmubqBNJ0(k6PUAnlf0xeMYyO2h7qD(v44rfaTDosttvxTMLc6lctz9Q8XouNFfoEubqBNJ000EMPUAnlf0xeMY6v5JDfLMAM6Q1SuqFrykJHAFSRO(km7DnvVfd14)cKLkxvtG95KqEwqgSaV)Gfl)U)Se2PaqywUgljGlw8HybUE8bsSqb9fHjwEilWsNGfq4ZYVtdXcCy5qvWHy53pmlMUFNLnOg)xG4K8WFWcBXpGvgji85CvnH2Y7iLbHFgUE8bszkOVimHweUErk3Zm1vRzPG(IWugd1(yxrkmtD1AwkOVimL1RYh7kQFA67AQElgQX)filvUQMa5K8WFWcBXpGvgjDqy1UHqBirqt53hu0Jvwj0EnLhQneE3v1KIEQRwZsb9fHPmgQ9XouNFfo(H68RWPPQRwZsb9fHPSEv(yhQZVch)qD(v40ue(CUQMSGWpdxp(aPmf0xeM6RyO2q4DxvtkEFqrV9Vok)Wm4rXReav4r5WofasbcFoxvtwq4Nhc4UUH6O6XCsE4pyHT4hWkJe8QA3qOnKiOP87dk6XkReAVMYd1gcV7QAsrp1vRzPG(IWugd1(yhQZVch)qD(v40u1vRzPG(IWuwVkFSd15xHJFOo)kCAkcFoxvtwq4NHRhFGuMc6lct9vmuBi8URQjfVpOO3(xhLFyg8O4vcGk8OCyNcaPaHpNRQjli8ZdbCx3qDu9yojp8hSWw8dyLrc(jT2NCt7dH2qIGMYVpOOhRSsO9AkpuBi8URQjf9uxTMLc6lctzmu7JDOo)kC8d15xHttvxTMLc6lctz9Q8XouNFfo(H68RWPPi85CvnzbHFgUE8bszkOVim1xXqTHW7UQMu8(GIE7FDu(HzWJIxjaLcpkh2Paqkq4Z5QAYcc)8qa31nuhvpMtc5zj2XelXgySybwSeazX097W1ZsWJIUcfNKh(dwyl(bSYiPbNaLHTC5)Ai0EnL9OCyNcaXjH8Se7yIfKtxboeilBr3CpMft3VZIxjyrdluSqfCHANfTJ)RqXc6f0xeMyXlqw(jblpKf9vel3ZYkIft3VZcaAPX(WIxGSGSyIeZTcCsE4pyHT4hWkJeQlcAIMSkSar71uUxp1vRzPG(IWugd1(yhQZVchVsjNMQUAnlf0xeMY6v5JDOo)kC8kLCFfbiudcnv2GNVkyhQZVchFCswrp1vRzJMRdoGNRZ(e86c5OLg7JfHRxeWaO5KCAQzZQOgCqr2O56Gd456SpbVUqoAPX(yjG76IIiW(9ttvxTMnAUo4aEUo7tWRlKJwASpweUErXRmabKjNMgGqni0uzdE(QGDihmHch)JRZrqt0epWjzojKNLyhtSGSyIeZTcSy6(DwqgSqabIqcYPRahcKLTOBUhZIxGSacl09SarqJP5EIfa0sJ9Hf4WIPDQyjUAieuVWplMGlnilesJUHyrLAWHybzXejMBfyHqA0neMtYd)blSf)awzKGWNZv1eAlVJuoaMdWc8(dwz8JweUErkBg4SoqBbZbqSce(CUQMSbWCawG3FWsrVEbiudcnvwQlkXqUodhWYRazhQZVcdmLauasa3tjLa(zvudoOil(Q2sN3tGFAoVVcc4UUOic0sDrjgY1z4awEfO(PPo(hxNJGMOjELbojRONzVRP6TT1KidBzsVkYsLRQjW0u1vRzdE(QGfCn(FWk(aeQbHMkBBnjYWwM0RISd15xHbmaSVce(CUQMS)(CADgteq0Kn53RON6Q1SaDf4qGzQlcAIMoQ(mv0G6IbzxrPPMfGiOYR3cuI58QVI3hu0B)RJYpmdEu8QRwZg88vbl4A8)GfWNSfqMMQcXyfTd1(NhQZVcdm1vRzdE(QGfCn(FWknnarqLxVTou7FU5uAQ6Q1SQAieuVWVDfPqD1AwvnecQx43ouNFfgyQRwZg88vbl4A8)GfG7bCa(zvudoOiB0CDWb8CD2NGxxihT0yFSeWDDrrey)(kmtD1A2GNVkyxrk6zwaIGkVEBDO2)CZP00aeQbHMkBawiGar5FNY4OBUhBxrPPQqmwr7qT)5H68RWalaHAqOPYgGfciqu(3Pmo6M7X2H68RWagqLM2ou7FEOo)kmYf5QeamzGPUAnBWZxfSGRX)dw95KqEwIDmXYVtSaGlv)EIHft3VZIZcYIjsm3kWYV7plhUq3ZsBGDSaGwASpCsE4pyHT4hWkJKXrqfCHZTHQyKaTxtz1vRzdE(QGDOo)kC8kHM0u1vRzdE(QGfCn(FWcyXjzfi85CvnzdG5aSaV)Gvg)CsE4pyHT4hWkJKaPj8FUo76dv1r1J2RPmcFoxvt2ayoalW7pyLXVIEMPUAnBWZxfSGRX)dwXhNKttnlarqLxVfbv)EIPFAQ6Q1SJJGk4cNBdvXiHDfPqD1A2XrqfCHZTHQyKWouNFfgyahahGf46EB0qHdtzxFOQoQE7FDugHRxeG7zM6Q1SQAieuVWVDfPWS31u9w87JgoGwQCvnb2NtYd)blSf)awzKCvWNY)dwO9AkJWNZv1KnaMdWc8(dwz8ZjH8SaGRpNRQjwwycKfyXIRE67pcZYV7plM86z5HSOsSGDeeiln4WcYIjsm3kWcgYYV7pl)oLGfFO6zXKJFcKfaCw4NfvQbhILFN64K8WFWcBXpGvgji85CvnH2Y7iLXock3Gto45RcOfHRxKYMfGqni0uzdE(QGDihmrAQzi85CvnzdWcbeikds4evqraIGkVEBDO2)CZP0uWzDG2cMdGyojKNLyhtywInq0JLRXYvS4flOxqFryIfVaz5NJWS8qw0xrSCplRiwmD)olaOLg7dAzbzXejMBfyXlqwIjOh9hcILnt(0Xj5H)Gf2IFaRmsARjrg2YKEveAVMYuqFryYEv2Rek8OCyNcaPqD1A2O56Gd456SpbVUqoAPX(yr46fbmaAojROhi8ToOh9hckJn5txg07CuK9VaqxHkn1SaebvE92IcdudhW(kq4Z5QAYIDeuUbNCWZxfu0tD1A2XrqfCHZTHQyKWouNFfgyaharp0a8ZQOgCqrw8vTLoVNa)0CEFfQRwZoocQGlCUnufJe2vuAQzQRwZoocQGlCUnufJe2vuFojKNLyhtSaGVOFNLT3NMR1SenWaMLRXY27tZ1AwoCHUNLveNKh(dwyl(bSYib)(0CTgTxtz1vRzHf974Cenbk6pyzxrkuxTMf)(0CT2ouBi8URQjojp8hSWw8dyLrsWRaPZQRwdTL3rkJFF0WbeTxtz1vRzXVpA4aAhQZVcdm0OON6Q1SuqFrykJHAFSd15xHJhnPPQRwZsb9fHPSEv(yhQZVchpA6RWX)46Ce0enXdCsMtc5zj2U6IWSetmaIfvQbhIfKbleqGiww4RqXYVtSGmyHaceXsawG3FWILhYsyNcaXY1ybzWcbeiILdZIh(LR1jyXvHRNLhYIkXsWXpNKh(dwyl(bSYib)(GxdkcTxt5aebvE926qT)5Mtkq4Z5QAYgGfciqugKWjQGIaeQbHMkBawiGar5FNY4OBUhBhQZVcdm0OWmWzDG2cMdGyfuqFryYEv2RekC8pUohbnrt8MtYCsiplXoMyz79P5AnlMUFNLTN0AFyj2ox7zXlqwkilBVpA4aIwwmTtflfKLT3NMR1SCywwrOLLeWfl(qSCflO)Q8Hf0lOVimXsdoSaabmMcywGdlpKLObgybaT0yFyX0ovS4QqeelaNKzjMyaelWHfhmY)dbXc2KpDSS7ywaGagtbmld15xDfkwGdlhMLRyPPpu7VLLybFILF3FwwfinS87elyVJyjalW7pyHz5E0HzbmcZsrRFCnlpKLT3NMR1SaUMRqXcaghbvWfMLyZqvmsGwwmTtfljGl0bYc(pTMfQazzfXIP73zb4KmGDCeln4WYVtSOD8Zcknu11ylNKh(dwyl(bSYib)(0CTgTxt531u9w8tATpzW5AVLkxvtGkm7DnvVf)(OHdOLkxvtGkuxTMf)(0CT2ouBi8URQjf9uxTMLc6lctz9Q8XouNFfoEaOckOVimzVkRxLpkuxTMnAUo4aEUo7tWRlKJwASpweUEradGOj50u1vRzJMRdoGNRZ(e86c5OLg7JfHRxu8kdq0KSch)JRZrqt0epWj50uq4BDqp6peugBYNUmO35Oi7qD(v44bGPPE4pyzDqp6peugBYNUmO35Oi7v5M(qT)9veGqni0uzdE(QGDOo)kC8kLmNeYZsSJjw2EFWRbfXca(I(DwIgyaZIxGSaU6IyjMyaelM2PIfKftKyUvGf4WYVtSaGlv)EIHf1vRXYHzXvHRNLhYsZ1AwGTglWHLeWf6azj4rSetmaItYd)blSf)awzKGFFWRbfH2RPS6Q1SWI(DCoOjFYio8bl7kknvD1AwGUcCiWm1fbnrthvFMkAqDXGSRO0u1vRzdE(QGDfPON6Q1SJJGk4cNBdvXiHDOo)kmWqfaTDosb(aD6Eo(hxNJGMOb5gNK7d44a8VRP6Tfzk3bHLLkxvtGkmBwf1GdkYIVQT059e4NMZvOUAn74iOcUW52qvmsyxrPPQRwZg88vb7qD(vyGHkaA7CKc8b609C8pUohbnrdYnoj3pnvD1A2XrqfCHZTHQyKiJVQT059e4NMZTRO0uZuxTMDCeubx4CBOkgjSRifMfGqni0uzhhbvWfo3gQIrc7qoyI0uZcqeu51Brq1VNy6NM64FCDocAIM4bojRGc6lct2RYELGtc5zX8tcwEilDoqel)oXIkHFwGnw2EF0WbKf1eSGFpa0vOy5EwwrSaCxxaiDcwUIfVsWc6f0xeMyrD9SaGwASpSC46zXvHRNLhYIkXs0adbcKtYd)blSf)awzKGFFWRbfH2RP87AQEl(9rdhqlvUQMavy2SkQbhuK9VoYeCQm4qEN6vG0OON6Q1S43hnCaTRO0uh)JRZrqt0epWj5(kuxTMf)(OHdOf)EaiGfhf9uxTMLc6lctzmu7JDfLMQUAnlf0xeMY6v5JDf1xH6Q1SrZ1bhWZ1zFcEDHC0sJ9XIW1lcyaeqMSIEbiudcnv2GNVkyhQZVchVsjNMAgcFoxvt2aSqabIYGeorfueGiOYR3whQ9p3CQpNeYZc6H)RZFcZYo0elDRWolXedGyXhIfu(veilr0WcMcWcKtYd)blSf)awzKGWNZv1eAlVJu2XraiA2OaAr46fPmf0xeMSxL1RYhGhaIC9WFWYIFFA3qwcPuy9u(VocWMrb9fHj7vz9Q8b47bOa87AQElgU0zyl)7uUbhc)wQCvnbc8XPpY1d)blRPX)DlHukSEk)xhb4KTMdAqU4isRZ7o(jaNSfna)7AQEB5)AiCw11EfilvUQMa5KqEwITRUiw2EFWRbfXYvS4SaibmMcSSb1(Wc6f0xeMqllGWcDplA6z5EwIgyGfa0sJ9HLE)U)SCyw29cutGSOMGf6(DAy53jw2EFAUwZI(kIf4WYVtSetmakEGtYSOVIyPbhw2EFWRbf1hTSacl09SarqJP5EIfVybaFr)olrdmWIxGSOPNLFNyXvHiiw0xrSS7fOMyz79rdhqojp8hSWw8dyLrc(9bVgueAVMYMnRIAWbfz)RJmbNkdoK3PEfink6PUAnB0CDWb8CD2NGxxihT0yFSiC9IagabKjNMQUAnB0CDWb8CD2NGxxihT0yFSiC9IagartYkExt1BXpP1(KbNR9wQCvnb2xrpkOVimzVkJHAFu44FCDocAIgaJWNZv1K1XraiA2OaWRUAnlf0xeMYyO2h7qD(vyadcFBBnjYWwM0RIS)facNhQZVc4bOfnXdatonLc6lct2RY6v5Jch)JRZrqt0aye(CUQMSoocarZgfaE1vRzPG(IWuwVkFSd15xHbmi8TT1KidBzsVkY(xaiCEOo)kGhGw0epWj5(kmtD1Awyr)oohrtGI(dw2vKcZExt1BXVpA4aAPYv1eOIEbiudcnv2GNVkyhQZVchpGmnfdxA1RaT)(CADgteq0yPYv1eOc1vRz)9506mMiGOXIFpaeWItCae9Mvrn4GIS4RAlDEpb(P5CGhn9v0ou7FEOo)kC8kLCYkAhQ9ppuNFfgyam5K7ROxac1GqtLfORahcmJJU5ESDOo)kC8aY0uZcqeu51BbkXCE1Ntc5zj2XelayHWcZYvSG(RYhwqVG(IWelEbYc2rqSGCgx3aCSzP1SaGfclwAWHfKftKyUvGfVazb50vGdbYc61fbnrthvpNKh(dwyl(bSYiPit5oiSq71uUN6Q1SuqFrykRxLp2H68RWXtiLcRNY)1rPP9c7(GIWkdqfdf29bfL)RJagA6NMg29bfHvoo9v4r5WofasbcFoxvtwSJGYn4KdE(QaNKh(dwyl(bSYiz31TChewO9Ak3tD1AwkOVimL1RYh7qD(v44jKsH1t5)6ifMfGiOYR3cuI58knTN6Q1SaDf4qGzQlcAIMoQ(mv0G6Ibzxrkcqeu51BbkXCE1pnTxy3huewzaQyOWUpOO8FDeWqt)00WUpOiSYXjnvD1A2GNVkyxr9v4r5WofasbcFoxvtwSJGYn4KdE(QGIEQRwZoocQGlCUnufJe2H68RWaRhAaeae4Nvrn4GIS4RAlDEpb(P58(kuxTMDCeubx4CBOkgjSRO0uZuxTMDCeubx4CBOkgjSRO(CsE4pyHT4hWkJK2sRZDqyH2RPCp1vRzPG(IWuwVkFSd15xHJNqkfwpL)RJuywaIGkVElqjMZR00EQRwZc0vGdbMPUiOjA6O6ZurdQlgKDfPiarqLxVfOeZ5v)00EHDFqryLbOIHc7(GIY)1radn9ttd7(GIWkhN0u1vRzdE(QGDf1xHhLd7uaifi85CvnzXock3Gto45Rck6PUAn74iOcUW52qvmsyhQZVcdm0OqD1A2XrqfCHZTHQyKWUIuy2SkQbhuKfFvBPZ7jWpnNNMAM6Q1SJJGk4cNBdvXiHDf1Ntc5zj2Xelihq0JfyXsaKtYd)blSf)awzKyYN5Gtg2YKEveNeYZsSJjw2EFA3qS8qwIgyGLnO2hwqVG(IWeAzbzXejMBfyz3XSOjmML)6iw(DVyXzb5y8FNfcPuy9elAQ9SahwGLoblO)Q8Hf0lOVimXYHzzfXj5H)Gf2IFaRmsWVpTBi0EnLPG(IWK9QSEv(KMsb9fHjlgQ9jxes)0ukOVimz9krUiK(PP9uxTM1KpZbNmSLj9Qi7kknfhrADE3XpbSKTMdAuywaIGkVElcQ(9etAkoI068UJFcyjBnhfbicQ86TiO63tm9vOUAnlf0xeMY6v5JDfLM2tD1A2GNVkyhQZVcdmp8hSSMg)3TesPW6P8FDKc1vRzdE(QGDf1Ntc5zj2XelihJ)7Sa)DAmDyIft7xyNLdZYvSSb1(Wc6f0xeMqllilMiXCRalWHLhYs0adSG(RYhwqVG(IWeNKh(dwyl(bSYiX04)oNeYZsSX16FFwCsE4pyHT4hWkJKzvzp8hSY6d)OT8os5MR1)(Sm2WruWiwkLmanEJ3Waa]] )


end