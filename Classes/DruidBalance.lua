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


    spec:RegisterPack( "Balance", 20210707, [[deLoAfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlai7Is)cIyyIOogjQLbqEMqLMgfvCnifBdqfFdaQXbG05aqzDaOAEak3JezFcv9piQO0bfkSqHs9qistuOcDrivzJcvWhHOIQrcrffNKIkTsrKxcrfzMqQQBcGq7uOKFcGOgkaOLcGGNQuMkfvDvHkARaisFfIkmwaG9sH)kQbtCyQwmj9ybtgOlJSzP8ziz0kvNwLvdGiEnGmBsDBrA3s(nOHlKJdOslxXZHA6Q66kz7q47uKXdr58IW6fkA(sL9JAdLnmVXgO)KrSauYas5KbWjdGTjdWsoUObGzS9jIiJTipaKJIm2kpLm2ITR9kqgBrEcn0bnmVXggUMazST)FegGJeKO6AVceacFPblQ73xQ2dIKy7AVceaA7srkssbT7FQg5STttkP6AVcK9r2BSPUo9BULHQXgO)KrSauYas5KbWjdGTjdqrdaZyZx)oCm22UuKASTFGGuzOASbs4GXwSDTxbIL44SoqoPKw6eSaGrllakzaPmNeNes39cfHb4CsaiwIbiibYYgu7dlXM8ulNeaIfKU7fkcKL3hu0NVglbhtywEilHebnLFFqrp2YjbGybGaLcrqGSSQIceg7tcwq4Z5QAcZsVZsw0Ys0qiY43h8AqrSaGINLOHqyXVp41GI6B5KaqSedeWdKLOHco(VcflihJ)7SCnwUhDyw(DIftdSqXc6f0xeMSCsaiwai6arSGuyHaceXYVtSSfDZ9ywCw03)AILu4qS00eYovnXsVRXsc4ILDhSq3ZY(9SCpl4lDPFVi4cRtWIP73zj2aKJH5zbWSGust4)CnlXqFOQuQE0YY9OdKfmqxuFlNeaIfaIoqelPq8Zc6AhQ9ppuQFfgDSGdu5ZbXS4rr6eS8qwuHymlTd1(Jzbw6ewojoPyuf89Nazj2U2RaXsmaGOplbVyrLyPbxfil(ZY()ryaosqIQR9kqai8LgSOUFFPApisITR9kqaOTlfPijf0U)PAKZ2onPKQR9kq2hzVXM(Wp2W8gBGuZx63W8gXszdZBS5H)GLXggQ9jRsEQXgvUQManITXBelazyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXgoI0687dk6Xw87tZ1AwINfLzrbl9yXmwExt1BXVpA4aAPYv1eilDDS8UMQ3IFsR9jdox7Tu5QAcKL(S01XcoI0687dk6Xw87tZ1AwINfazSHWNC5PKX2HZoKm2ajCyUO)GLX2g9ywIbe9ybwSexaZIP73HRNfW5AplEbYIP73zz79rdhqw8cKfabywG)onMomz8gXkUgM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzSHJiTo)(GIESf)(0UHyjEwu2ydHp5YtjJTdNdAYrqgBGeomx0FWYyBJEmlbn5iiwmTtflBVpTBiwcEXY(9SaiaZY7dk6XSyA)c7SCywgsti86zPbhw(DIf0lOVimXYdzrLyjAOgndbYIxGSyA)c7S0oTMgwEilbh)gVrSmhdZBSrLRQjqJyBS5H)GLXMknyAa6kugBGeomx0FWYyloXelXMgmnaDfkwmD)olingiXCRalWHfV90WcsHfciqelxXcsJbsm3kySfM7P5CJTESyglbicQ86T1HA)ZnNyPRJfZyjaHAqOPYgGfciqu(3Pmo6M7X2vel9zrblQRwZg88vb7qP(vywINfLrdlkyrD1A2XrqfCHZTHQyMWouQFfMfGXI5WIcwmJLaebvE9weu97jgw66yjarqLxVfbv)EIHffSOUAnBWZxfSRiwuWI6Q1SJJGk4cNBdvXmHDfXIcw6XI6Q1SJJGk4cNBdvXmHDOu)kmlaJfLvMfaelOHfGNLzvudoOil(Q2sN3tGFAo3sLRQjqw66yrD1A2GNVkyhk1VcZcWyrzLzPRJfLzbjSGJiToV74NybySOSfnOHL(gVrSqJH5n2OYv1eOrSn2cZ90CUXM6Q1SbpFvWouQFfML4zrz0WIcw6XIzSmRIAWbfzXx1w68Ec8tZ5wQCvnbYsxhlQRwZoocQGlCUnufZe2Hs9RWSamwugaZIcwuxTMDCeubx4CBOkMjSRiw6ZsxhlQqmMffS0ou7FEOu)kmlaJfaHgJnqchMl6pyzSbaHplMUFNfNfKgdKyUvGLF3FwoCHUNfNfa4sJ9HLObgyboSyANkw(DIL2HA)z5WS4QW1ZYdzHkqJnp8hSm2IG)blJ3iwahdZBSrLRQjqJyBSbJm2W0BS5H)GLXgcFoxvtgBiC9Im2c0PzPhl9yPDO2)8qP(vywaqSOmAybaXsac1GqtLn45Rc2Hs9RWS0NfKWIYa0KzPplkXsGonl9yPhlTd1(Nhk1VcZcaIfLrdlaiwugqjZcaILaeQbHMkBawiGar5FNY4OBUhBhk1VcZsFwqclkdqtML(SOGfZyz8dmtiO6Toii2si7WpMLUowcqOgeAQSbpFvWouQFfML4z5QNMiO2Fcm3ou7FEOu)kmlDDSeGqni0uzdWcbeik)7ughDZ9y7qP(vywINLREAIGA)jWC7qT)5Hs9RWSaGyr5KzPRJfZyjarqLxVTou7FU5elDDS4H)GLnaleqGO8VtzC0n3JTGh2v1eOXgcFYLNsgBbyHaceLbjCIkySbs4WCr)blJnK66Ws7pHzX0o970WYcFfkwqkSqabIyPGMyX0P1S4An0eljGlwEil4)0Awco(z53jwWEkXINcx1ZcSXcsHfciqeGrAmqI5wbwco(XgVrSaWgM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzS1JL3hu0B)lLYpmdEelXZIYOHLUowg)aZecQERdcITxXs8SGMKzPplkyPhl9yPhleWDDrreOLsJsmKRZWbS8kqSOGLES0JLaeQbHMklLgLyixNHdy5vGSdL6xHzbySOmWjzw66yjarqLxVfbv)EIHffSeGqni0uzP0Oed56mCalVcKDOu)kmlaJfLboaywaml9yrzLzb4zzwf1GdkYIVQT059e4NMZTu5QAcKL(S0NffSyglbiudcnvwknkXqUodhWYRazhYbtWsFw6Zsxhl9yHaURlkIaTy4sRP)VcvEwQjyrbl9yXmwcqeu51BRd1(NBoXsxhlbiudcnvwmCP10)xHkpl1e54AoObGMSY2Hs9RWSamwuwzZHL(S0NLUow6XIzSqa31ffrG2RWHz9UQMYa3Lx)kndsiUaXsxhlbiudcnv2RWHz9UQMYa3Lx)kndsiUazhYbtWsFwuWspwcqOgeAQSQ0GPbORqzhYbtWsxhlMXY4bY(duRzPplkyPhl9ybHpNRQjlSYlmL)5kGONfLyrzw66ybHpNRQjlSYlmL)5kGONfLyjUS0NffS0JLFUci6TVY2HCWe5aeQbHMkw66y5NRaIE7RSnaHAqOPYouQFfML4z5QNMiO2Fcm3ou7FEOu)kmlaiwuozw6Zsxhli85CvnzHvEHP8pxbe9SOelaIffS0JLFUci6TpGSd5GjYbiudcnvS01XYpxbe92hq2aeQbHMk7qP(vywINLREAIGA)jWC7qT)5Hs9RWSaGyr5KzPplDDSGWNZv1Kfw5fMY)Cfq0ZIsSKml9zPplDDSeGiOYR3cuI58IL(gBi8jxEkzSfaZbybE)blJnqchMl6pyzSfNycKLhYciP9eS87ellSJIyb2ybPXajMBfyX0ovSSWxHIfq4svtSalwwyIfVazjAieu9SSWokIft7uXIxS4GGSqiO6z5WS4QW1ZYdzb8iJ3iwaudZBSrLRQjqJyBSbJm2W0BS5H)GLXgcFoxvtgBiC9Im2mJfmCPvVc0(7ZP1zmrarJLkxvtGS01Xs7qT)5Hs9RWSeplak5KzPRJfvigZIcwAhQ9ppuQFfMfGXcGqdlaMLESyojZcaIf1vRz)9506mMiGOXIFpaelaplaIL(S01XI6Q1S)(CADgteq0yXVhaIL4zjUauwaqS0JLzvudoOil(Q2sN3tGFAo3sLRQjqwaEwqdl9n2q4tU8uYy73NtRZyIaIMSj)EJ3iwamdZBSrLRQjqJyBSvEkzSrPrjgY1z4awEfiJnqchMl6pyzSfNyIf0lnkXqUMfaYdy5vGybqjJPaMfvQbhIfNfKgdKyUvGLfMSgBH5EAo3ylaHAqOPYg88vb7qP(vywaglakzwuWsac1GqtLnaleqGO8VtzC0n3JTdL6xHzbySaOKzrbl9ybHpNRQj7VpNwNXebenzt(9S01XI6Q1S)(CADgteq0yXVhaIL4zjUjZcGzPhlZQOgCqrw8vTLoVNa)0CULkxvtGSa8SaCyPpl9zPRJfvigZIcwAhQ9ppuQFfMfGXsCbWgBE4pyzSrPrjgY1z4awEfiJ3iwkNSH5n2OYv1eOrSn2kpLm2WWLwt)FfQ8SutySbs4WCr)blJT4etSSbxAn9xHIfacl1eSaCWuaZIk1GdXIZcsJbsm3kWYctwJTWCpnNBSfGqni0uzdE(QGDOu)kmlaJfGdlkyXmwcqeu51Brq1VNyyrblMXsaIGkVEBDO2)CZjw66yjarqLxVTou7FU5elkyjaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWSamwaoSOGLESGWNZv1KnaleqGOmiHtubw66yjaHAqOPYg88vb7qP(vywaglahw6ZsxhlbicQ86TiO63tmSOGLESyglZQOgCqrw8vTLoVNa)0CULkxvtGSOGLaeQbHMkBWZxfSdL6xHzbySaCyPRJf1vRzhhbvWfo3gQIzc7qP(vywaglkBoSayw6XcAyb4zHaURlkIaTxH)zfE4GZGhIROSkP1S0NffSOUAn74iOcUW52qvmtyxrS0NLUowuHymlkyPDO2)8qP(vywaglacngBE4pyzSHHlTM()ku5zPMW4nILYkByEJnQCvnbAeBJnp8hSm2UchM17QAkdCxE9R0miH4cKXwyUNMZn2uxTMn45Rc2Hs9RWSeplkJgwuWspwmJLzvudoOil(Q2sN3tGFAo3sLRQjqw66yrD1A2XrqfCHZTHQyMWouQFfMfGXIYaIfaZspwIllaplQRwZQQHqq9c)2vel9zbWS0JLESaGzbaXcAyb4zrD1AwvnecQx43UIyPplapleWDDrreO9k8pRWdhCg8qCfLvjTML(SOGf1vRzhhbvWfo3gQIzc7kIL(S01XIkeJzrblTd1(Nhk1VcZcWybqOXyR8uYy7kCywVRQPmWD51VsZGeIlqgVrSugqgM3yJkxvtGgX2ylm3tZ5gBi85CvnzHvEHP8pxbe9SOelaIffSygl)Cfq0BFazhYbtKdqOgeAQyPRJLESGWNZv1Kfw5fMY)Cfq0ZIsSOmlDDSGWNZv1Kfw5fMY)Cfq0ZIsSexw6ZIcw6XI6Q1SbpFvWUIyrbl9yXmwcqeu51Brq1VNyyPRJf1vRzhhbvWfo3gQIzc7qP(vywaml9ybnSa8SmRIAWbfzXx1w68Ec8tZ5wQCvnbYsFwaMsS8ZvarV9v2QUATm4A8)GflkyrD1A2XrqfCHZTHQyMWUIyPRJf1vRzhhbvWfo3gQIzIm(Q2sN3tGFAo3UIyPplDDSeGqni0uzdE(QGDOu)kmlaMfaXs8S8ZvarV9v2gGqni0uzbxJ)hSyrbl9yXmwcqeu51BRd1(NBoXsxhlMXccFoxvt2aSqabIYGeorfyPplkyXmwcqeu51BbkXCEXsxhlbicQ86T1HA)ZnNyrbli85CvnzdWcbeikds4evGffSeGqni0uzdWcbeik)7ughDZ9y7kIffSyglbiudcnv2GNVkyxrSOGLES0Jf1vRzPG(IWuwVkFSdL6xHzjEwuozw66yrD1AwkOVimLXqTp2Hs9RWSeplkNml9zrblMXYSkQbhuKv11EfOmSLDTo)7xHcBPYv1eilDDS0Jf1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGyrjwqdlDDSOUAnRQR9kqzyl7AD(3Vcfo7tWlYIFpaelkXcaLL(S0NLUowuxTMfORahcmtPrqt0Ks1NPIguxmj7kIL(S01XIkeJzrblTd1(Nhk1VcZcWybqjZsxhli85CvnzHvEHP8pxbe9SOeljBSbs4WCr)blJnZVFywomlolJ)70WcPDv44pXIjpblpKLuhiIfxRzbwSSWel43Fw(5kGOhZYdzrLyrFfbYYkIft3VZcsJbsm3kWIxGSGuyHaceXIxGSSWel)oXcGkqwWA4ZcSyjaYY1yrf(7S8ZvarpMfFiwGfllmXc(9NLFUci6XgByn8XgB)Cfq0RSXMh(dwgBlmLVNsXgVrSuoUgM3yJkxvtGgX2yZd)blJTfMY3tPyJTWCpnNBSHWNZv1Kfw5fMY)Cfq0ZIzkXcGyrblMXYpxbe92xz7qoyICac1GqtflDDSGWNZv1Kfw5fMY)Cfq0ZIsSaiwuWspwuxTMn45Rc2velkyPhlMXsaIGkVElcQ(9edlDDSOUAn74iOcUW52qvmtyhk1VcZcGzPhlOHfGNLzvudoOil(Q2sN3tGFAo3sLRQjqw6ZcWuILFUci6TpGSQRwldUg)pyXIcwuxTMDCeubx4CBOkMjSRiw66yrD1A2XrqfCHZTHQyMiJVQT059e4NMZTRiw6Zsxhlbiudcnv2GNVkyhk1VcZcGzbqSepl)Cfq0BFazdqOgeAQSGRX)dwSOGLESyglbicQ86T1HA)ZnNyPRJfZybHpNRQjBawiGarzqcNOcS0NffSyglbicQ86TaLyoVyrbl9yXmwuxTMn45Rc2velDDSyglbicQ86TiO63tmS0NLUowcqeu51BRd1(NBoXIcwq4Z5QAYgGfciqugKWjQalkyjaHAqOPYgGfciqu(3Pmo6M7X2velkyXmwcqOgeAQSbpFvWUIyrbl9yPhlQRwZsb9fHPSEv(yhk1VcZs8SOCYS01XI6Q1SuqFrykJHAFSdL6xHzjEwuozw6ZIcwmJLzvudoOiRQR9kqzyl7AD(3Vcf2sLRQjqw66yPhlQRwZQ6AVcug2YUwN)9RqHZL)RHS43daXIsSGgw66yrD1Awvx7vGYWw2168VFfkC2NGxKf)EaiwuIfakl9zPpl9zPRJf1vRzb6kWHaZuAe0enPu9zQOb1ftYUIyPRJfvigZIcwAhQ9ppuQFfMfGXcGsMLUowq4Z5QAYcR8ct5FUci6zrjws2ydRHp2y7NRaIEaz8gXszZXW8gBu5QAc0i2gBGeomx0FWYyloXeMfxRzb(70WcSyzHjwUNsXSalwcGgBE4pyzSTWu(EkfB8gXsz0yyEJnQCvnbAeBJnqchMl6pyzSfhPWbsS4H)Gfl6d)SO6ycKfyXc((L)hSqIMqDyJnp8hSm2MvL9WFWkRp8BSH)5cVrSu2ylm3tZ5gBi85CvnzpC2HKXM(WFU8uYyZHKXBelLbogM3yJkxvtGgX2ylm3tZ5gBZQOgCqrwvx7vGYWw2168VFfkSLaURlkIan2W)CH3iwkBS5H)GLX2SQSh(dwz9HFJn9H)C5PKXMk0FJ3iwkdGnmVXgvUQManITXMh(dwgBZQYE4pyL1h(n20h(ZLNsgB434nEJnvO)gM3iwkByEJnQCvnbAeBJnp8hSm2ghbvWfo3gQIzcJnqchMl6pyzSfhgQIzcwmD)olingiXCRGXwyUNMZn2uxTMn45Rc2Hs9RWSeplkJgJ3iwaYW8gBu5QAc0i2gBE4pyzS5GE0FiOm2KpPgBHebnLFFqrp2iwkBSbs4WCr)blJT4etSedqp6peelBM8jLft7uXI)SOjmMLF3lwmhwInmgMNf87bGWS4filpKLHAdH3zXzbykbiwWVhaIfhZI2FIfhZseeJpvnXcCy5VuIL7zbdz5Ew8zoeeMfasw4NfV90WIZsCbml43daXcHSOBiSXwyUNMZn2uxTMv11EfOmSLDTo)7xHcNl)xdzXVhaIfGXcaLffSOUAnRQR9kqzyl7AD(3Vcfo7tWlYIFpaelaJfaklkyPhlMXci8ToOh9hckJn5tAg0tDuK9VaqxHIffSyglE4pyzDqp6peugBYN0mON6Oi7v5M(qT)SOGLESyglGW36GE0FiOm2KpP5DY12)caDfkw66ybe(wh0J(dbLXM8jnVtU2ouQFfML4zjUS0NLUowaHV1b9O)qqzSjFsZGEQJIS43daXcWyjUSOGfq4BDqp6peugBYN0mON6Oi7qP(vywaglOHffSacFRd6r)HGYyt(KMb9uhfz)la0vOyPVXBeR4AyEJnQCvnbAeBJnp8hSm2cWcbeik)7ughDZ9yJnqchMl6pyzSfNyIfKcleqGiwmD)olingiXCRalM2PILiigFQAIfVazb(70y6WelMUFNfNLydJH5zrD1ASyANkwajCIkCfkJTWCpnNBSzglGZ6aTfmhaXSOGLES0Jfe(CUQMSbyHaceLbjCIkWIcwmJLaeQbHMkBWZxfSd5GjyPRJf1vRzdE(QGDfXsFwuWspwuxTMv11EfOmSLDTo)7xHcNl)xdzXVhaIfLybGYsxhlQRwZQ6AVcug2YUwN)9RqHZ(e8IS43daXIsSaqzPplDDSOcXywuWs7qT)5Hs9RWSamwuozw6B8gXYCmmVXgvUQManITXMh(dwgBT1KidBzsVkYydKWH5I(dwgBXbi6XIJz53jwA3GFwqfaz5kw(DIfNLydJH5zX0vGqtSahwmD)ol)oXcYPeZ5flQRwJf4WIP73zXzbGcymfyjgGE0Fiiw2m5tklEbYIj)EwAWHfKgdKyUvGLRXY9SycwplQelRiwCu(vSOsn4qS87elbqwomlTRo8obASfM7P5CJTES0JLESOUAnRQR9kqzyl7AD(3Vcfox(VgYIFpaelXZcWHLUowuxTMv11EfOmSLDTo)7xHcN9j4fzXVhaIL4zb4WsFwuWspwmJLaebvE9weu97jgw66yXmwuxTMDCeubx4CBOkMjSRiw6ZsFwuWspwaN1bAlyoaIzPRJLaeQbHMkBWZxfSdL6xHzjEwqtYS01Xspwcqeu51BRd1(NBoXIcwcqOgeAQSbyHaceL)DkJJU5ESDOu)kmlXZcAsML(S0NL(S01XspwaHV1b9O)qqzSjFsZGEQJISdL6xHzjEwaOSOGLaeQbHMkBWZxfSdL6xHzjEwuozwuWsaIGkVEBrHbQHdil9zPRJfvigZIcwU6PjcQ9NaZTd1(Nhk1VcZcWybGYIcwmJLaeQbHMkBWZxfSd5GjyPRJLaebvE9wGsmNxSOGf1vRzb6kWHaZuAe0enPu92velDDSeGiOYR3IGQFpXWIcwuxTMDCeubx4CBOkMjSdL6xHzbySaWyrblQRwZoocQGlCUnufZe2vKXBel0yyEJn1vRLlpLm2WVpA4aASfM7P5CJTESOUAnRQR9kqzyl7AD(3Vcfox(VgYouQFfML4zbaBrdlDDSOUAnRQR9kqzyl7AD(3Vcfo7tWlYouQFfML4zbaBrdl9zrbl9yjaHAqOPYg88vb7qP(vywINfamlDDS0JLaeQbHMklLgbnrtwfwG2Hs9RWSeplaywuWIzSOUAnlqxboeyMsJGMOjLQptfnOUys2velkyjarqLxVfOeZ5fl9zPplkyXX)46Ce0enSeVsSe3Kn2OYv1eOrSn2ajCyUO)GLXgs9kqAw2EF0WbKft3VZIZsrMyj2WyyEwuxTglEbYcsJbsm3kWYHl09S4QW1ZYdzrLyzHjqJnp8hSm2cEfiDwD1AgVrSaogM3yJkxvtGgX2yZd)blJn87dEnOiJnqchMl6pyzSfhxPrSS9(GxdkcZIP73zXzj2WyyEwuxTglQRNLc(SyANkwIGq9vOyPbhwqAmqI5wbwGdliNUcCiqw2IU5ESXwyUNMZn26XI6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqSeplaILUowuxTMv11EfOmSLDTo)7xHcN9j4fzXVhaIL4zbqS0NffS0JLaebvE926qT)5MtS01Xsac1GqtLn45Rc2Hs9RWSeplayw66yXmwq4Z5QAYgaZbybE)blwuWIzSeGiOYR3cuI58ILUow6Xsac1GqtLLsJGMOjRclq7qP(vywINfamlkyXmwuxTMfORahcmtPrqt0Ks1NPIguxmj7kIffSeGiOYR3cuI58IL(S0NffS0JfZybe(22AsKHTmPxfz)la0vOyPRJfZyjaHAqOPYg88vb7qoycw66yXmwcqOgeAQSbyHaceL)DkJJU5ESDihmbl9nEJybGnmVXgvUQManITXMh(dwgB43h8AqrgBGeomx0FWYyloUsJyz79bVgueMfvQbhIfKcleqGiJTWCpnNBS1JLaeQbHMkBawiGar5FNY4OBUhBhk1VcZcWybnSOGfZybCwhOTG5aiMffS0Jfe(CUQMSbyHaceLbjCIkWsxhlbiudcnv2GNVkyhk1VcZcWybnS0NffSGWNZv1KnaMdWc8(dwS0NffSyglGW32wtImSLj9Qi7FbGUcflkyjarqLxVTou7FU5elkyXmwaN1bAlyoaIzrbluqFryYEv2ReSOGfh)JRZrqt0Ws8SyojB8gXcGAyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXwpwuxTMDCeubx4CBOkMjSdL6xHzjEwqdlDDSyglQRwZoocQGlCUnufZe2vel9zrbl9yrD1AwGUcCiWmLgbnrtkvFMkAqDXKSdL6xHzbySGkaAtDKXsFwuWspwuxTMLc6lctzmu7JDOu)kmlXZcQaOn1rglDDSOUAnlf0xeMY6v5JDOu)kmlXZcQaOn1rgl9n2q4tU8uYyde(5HaURBOuQESXgiHdZf9hSm2IJWcDplGWNfW1Cfkw(DIfQazb2ybGGJGk4cZsCyOkMjqllGR5kuSa0vGdbYcLgbnrtkvplWHLRy53jw0o(zbvaKfyJfVyb9c6lctgVrSaygM3yJkxvtGgX2ylm3tZ5gBd1gcV7QAIffS8(GIE7FPu(HzWJyjEwug4WIcw8OCyNcaXIcwq4Z5QAYcc)8qa31nukvp2yZd)blJn8QA3qgBHebnLFFqrp2iwkB8gXs5KnmVXgvUQManITXwyUNMZn2gQneE3v1elky59bf92)sP8dZGhXs8SOCCTOHffS4r5WofaIffSGWNZv1Kfe(5HaURBOuQESXMh(dwgBPqy1UHm2cjcAk)(GIESrSu24nILYkByEJnQCvnbAeBJTWCpnNBSnuBi8URQjwuWY7dk6T)Ls5hMbpIL4zrzGdlaMLHs9RWSOGfpkh2PaqSOGfe(CUQMSGWppeWDDdLs1Jn28WFWYyd)Kw7tUP9Hm2cjcAk)(GIESrSu24nILYaYW8gBu5QAc0i2gBE4pyzS1GtGYWwU8FnKXgiHdZf9hSm2IdWyXcSyjaYIP73HRNLGhfDfkJTWCpnNBS5r5WofaY4nILYX1W8gBu5QAc0i2gBE4pyzSrPrqt0KvHfOXgiHdZf9hSm2qV0iOjAyj2WcKft7uXIRcxplpKfQEAyXzPitSeBymmplMUceAIfVazb7iiwAWHfKgdKyUvWylm3tZ5gB9yHc6lctw9Q8jxeYEw66yHc6lctwmu7tUiK9S01Xcf0xeMSELixeYEw66yrD1Awvx7vGYWw2168VFfkCU8FnKDOu)kmlXZca2Igw66yrD1Awvx7vGYWw2168VFfkC2NGxKDOu)kmlXZca2Igw66yXX)46Ce0enSeplaSKzrblbiudcnv2GNVkyhYbtWIcwmJfWzDG2cMdGyw6ZIcw6Xsac1GqtLn45Rc2Hs9RWSeplXnzw66yjaHAqOPYg88vb7qoycw6ZsxhlQqmMffSC1tteu7pbMBhQ9ppuQFfMfGXIYjB8gXszZXW8gBu5QAc0i2gBE4pyzS1wtImSLj9QiJnqchMl6pyzSfhGOhlZHA)zrLAWHyzHVcflinggBH5EAo3ylaHAqOPYg88vb7qoycwuWccFoxvt2ayoalW7pyXIcw6XIJ)X15iOjAyjEwayjZIcwmJLaebvE926qT)5MtS01XsaIGkVEBDO2)CZjwuWIJ)X15iOjAybySyojZsFwuWIzSeGiOYR3IGQFpXWIcw6XIzSeGiOYR3whQ9p3CILUowcqOgeAQSbyHaceL)DkJJU5ESDihmbl9zrblMXc4SoqBbZbqSXBelLrJH5n2OYv1eOrSn2GrgBy6n28WFWYydHpNRQjJneUErgBMXc4SoqBbZbqmlkybHpNRQjBamhGf49hSyrbl9yPhlo(hxNJGMOHL4zbGLmlkyPhlQRwZc0vGdbMP0iOjAsP6ZurdQlMKDfXsxhlMXsaIGkVElqjMZlw6ZsxhlQRwZQQHqq9c)2velkyrD1AwvnecQx43ouQFfMfGXI6Q1SbpFvWcUg)pyXsFw66y5QNMiO2Fcm3ou7FEOu)kmlaJf1vRzdE(QGfCn(FWILUowcqeu51BRd1(NBoXsFwuWspwmJLaebvE926qT)5MtS01XspwC8pUohbnrdlaJfZjzw66ybe(22AsKHTmPxfz)la0vOyPplkyPhli85CvnzdWcbeikds4evGLUowcqOgeAQSbyHaceL)DkJJU5ESDihmbl9zPVXgcFYLNsgBbWCawG3FWkRc93ydKWH5I(dwgBingiXCRalM2PIf)zbGLmGzjgyail9GJgAIgw(DVyXCsMLyGbGSy6(DwqkSqabI6ZIP73HRNfneFfkw(lLy5kwITgcb1l8ZIxGSOVIyzfXIP73zbPWcbeiILRXY9SyYXSas4evGanEJyPmWXW8gBu5QAc0i2gBH5EAo3ydHpNRQjBamhGf49hSYQq)n28WFWYylqAc)NRZU(qvPu9gVrSugaByEJnQCvnbAeBJTWCpnNBSHWNZv1KnaMdWc8(dwzvO)gBE4pyzSDvWNY)dwgVrSugGAyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXgf0xeMSxL1RYhwaEwaOSGew8WFWYIFFA3qwczuy9u(VuIfaZIzSqb9fHj7vz9Q8HfGNLESaCybWS8UMQ3IHlDg2Y)oLBWHWVLkxvtGSa8Sexw6ZcsyXd)blRPX)DlHmkSEk)xkXcGzjzlGybjSGJiToV74Nm2q4tU8uYyZXraqA2OGXgiHdZf9hSm2qp8FP(tyw2HMyjDf2zjgyail(qSGYVIazjIgwWuawGgVrSugGzyEJnQCvnbAeBJnp8hSm2WVp41GIm2ajCyUO)GLXwCCLgXY27dEnOimlM2PILFNyPDO2FwomlUkC9S8qwOceTS0gQIzcwomlUkC9S8qwOceTSKaUyXhIf)zbGLmGzjgyailxXIxSGEb9fHj0YcsJbsm3kWI2XpMfVG)onSaqbmMcywGdljGlwmbxAqwGiOj4rSKchILF3lw4oLtMLyGbGSyANkwsaxSycU0Gf6Ew2EFWRbfXsbnzSfM7P5CJTESOcXywuWYvpnrqT)eyUDO2)8qP(vywaglMdlDDS0Jf1vRzhhbvWfo3gQIzc7qP(vywaglOcG2uhzSa8SeOtZspwC8pUohbnrdliHL4Mml9zrblQRwZoocQGlCUnufZe2vel9zPplDDS0Jfh)JRZrqt0WcGzbHpNRQjRJJaG0SrbwaEwuxTMLc6lctzmu7JDOu)kmlaMfq4BBRjrg2YKEvK9Vaq48qP(vSa8SailAyjEwuw5KzPRJfh)JRZrqt0WcGzbHpNRQjRJJaG0SrbwaEwuxTMLc6lctz9Q8XouQFfMfaZci8TT1KidBzsVkY(xaiCEOu)kwaEwaKfnSeplkRCYS0NffSqb9fHj7vzVsWIcw6XIzSOUAnBWZxfSRiw66yXmwExt1BXVpA4aAPYv1eil9zrbl9yPhlMXsac1GqtLn45Rc2velDDSeGiOYR3cuI58IffSyglbiudcnvwkncAIMSkSaTRiw6ZsxhlbicQ86T1HA)ZnNyPplkyPhlMXsaIGkVElcQ(9edlDDSyglQRwZg88vb7kILUowC8pUohbnrdlXZcalzw6Zsxhl9y5DnvVf)(OHdOLkxvtGSOGf1vRzdE(QGDfXIcw6XI6Q1S43hnCaT43daXcWyjUS01XIJ)X15iOjAyjEwayjZsFw6ZsxhlQRwZg88vb7kIffSyglQRwZoocQGlCUnufZe2velkyXmwExt1BXVpA4aAPYv1eOXBelaLSH5n2OYv1eOrSn28WFWYyRit5uiSm2ajCyUO)GLXwCIjwaicHfMLRyb9xLpSGEb9fHjw8cKfSJGyb5mUUb44WsRzbGiewS0GdlingiXCRGXwyUNMZn26XI6Q1SuqFrykRxLp2Hs9RWSepleYOW6P8FPelDDS0JLWUpOimlkXcGyrbldf29bfL)lLybySGgw6ZsxhlHDFqrywuIL4YsFwuWIhLd7uaiJ3iwaszdZBSrLRQjqJyBSfM7P5CJTESOUAnlf0xeMY6v5JDOu)kmlXZcHmkSEk)xkXIcw6Xsac1GqtLn45Rc2Hs9RWSeplOjzw66yjaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWSeplOjzw6Zsxhl9yjS7dkcZIsSaiwuWYqHDFqr5)sjwaglOHL(S01Xsy3hueMfLyjUS0NffS4r5WofaYyZd)blJTDx3YPqyz8gXcqaYW8gBu5QAc0i2gBH5EAo3yRhlQRwZsb9fHPSEv(yhk1VcZs8SqiJcRNY)LsSOGLESeGqni0uzdE(QGDOu)kmlXZcAsMLUowcqOgeAQSbyHaceL)DkJJU5ESDOu)kmlXZcAsML(S01Xspwc7(GIWSOelaIffSmuy3huu(VuIfGXcAyPplDDSe29bfHzrjwIll9zrblEuoStbGm28WFWYyRT06CkewgVrSauCnmVXgvUQManITXgiHdZf9hSm2qoGOhlWILaOXMh(dwgBM8zo4KHTmPxfz8gXcqMJH5n2OYv1eOrSn28WFWYyd)(0UHm2ajCyUO)GLXwCIjw2EFA3qS8qwIgyGLnO2hwqVG(IWelWHft7uXYvSalDcwq)v5dlOxqFryIfVazzHjwqoGOhlrdmGz5ASCflO)Q8Hf0lOVimzSfM7P5CJnkOVimzVkRxLpS01Xcf0xeMSyO2NCri7zPRJfkOVimz9krUiK9S01XI6Q1SM8zo4KHTmPxfzxrSOGf1vRzPG(IWuwVkFSRiw66yPhlQRwZg88vb7qP(vywaglE4pyznn(VBjKrH1t5)sjwuWI6Q1SbpFvWUIyPVXBelaHgdZBS5H)GLXMPX)DJnQCvnbAeBJ3iwac4yyEJnQCvnbAeBJnp8hSm2MvL9WFWkRp8BSPp8NlpLm2AUw)7ZY4nEJnhsgM3iwkByEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXwpwuxTM9VuYeCQm4qEQ6vG0yhk1VcZcWybva0M6iJfaZsYwLzPRJf1vRz)lLmbNkdoKNQEfin2Hs9RWSamw8WFWYIFFA3qwczuy9u(VuIfaZsYwLzrbl9yHc6lct2RY6v5dlDDSqb9fHjlgQ9jxeYEw66yHc6lctwVsKlczpl9zPplkyrD1A2)sjtWPYGd5PQxbsJDfXIcwMvrn4GIS)LsMGtLbhYtvVcKglvUQMan2q4tU8uYydCipnB606CZ16mS1m2ajCyUO)GLXgsDDyP9NWSyAN(DAy53jwIJd5Pb)d70WI6Q1yX0P1S0CTMfyRXIP73VILFNyPiK9SeC8B8gXcqgM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzSzgluqFryYEvgd1(WIcw6XcoI0687dk6Xw87t7gIL4zbnSOGL31u9wmCPZWw(3PCdoe(Tu5QAcKLUowWrKwNFFqrp2IFFA3qSeplayw6BSHWNC5PKX2HQGdLXVp41GIm2ajCyUO)GLXgsDDyP9NWSyAN(DAyz79bVguelhMftW53zj44)kuSarqdlBVpTBiwUIf0Fv(Wc6f0xeMmEJyfxdZBSrLRQjqJyBS5H)GLXwawiGar5FNY4OBUhBSbs4WCr)blJT4etSGuyHaceXIPDQyXFw0egZYV7flOjzwIbgaYIxGSOVIyzfXIP73zbPXajMBfm2cZ90CUXMzSaoRd0wWCaeZIcw6Xspwq4Z5QAYgGfciqugKWjQalkyXmwcqOgeAQSbpFvWoKdMGLUowuxTMn45Rc2vel9zrbl9yrD1AwkOVimL1RYh7qP(vywINfGdlDDSOUAnlf0xeMYyO2h7qP(vywINfGdl9zrbl9yXmwMvrn4GISQU2RaLHTSR15F)kuylvUQMazPRJf1vRzvDTxbkdBzxRZ)(vOW5Y)1qw87bGyjEwIllDDSOUAnRQR9kqzyl7AD(3Vcfo7tWlYIFpaelXZsCzPplDDSOcXywuWs7qT)5Hs9RWSamwuozwuWIzSeGqni0uzdE(QGDihmbl9nEJyzogM3yJkxvtGgX2yZd)blJTXrqfCHZTHQyMWydKWH5I(dwgBXjMyjomufZeSy6(DwqAmqI5wbJTWCpnNBSPUAnBWZxfSdL6xHzjEwugngVrSqJH5n2OYv1eOrSn28WFWYydVQ2nKXwirqt53hu0JnILYgBGeomx0FWYyloXelBRQDdXYvSe5fiLEbwGflEL43Vcfl)U)SOpeeMfLnhmfWS4filAcJzX097SKchIL3hu0JzXlqw8NLFNyHkqwGnwCw2GAFyb9c6lctS4plkBoSGPaMf4WIMWywgk1V6kuS4ywEilf8zz3rCfkwEild1gcVZc4AUcflO)Q8Hf0lOVimzSfM7P5CJTESmuBi8URQjw66yrD1AwkOVimLXqTp2Hs9RWSamwIllkyHc6lct2RYyO2hwuWYqP(vywaglkBoSOGL31u9wmCPZWw(3PCdoe(Tu5QAcKL(SOGL3hu0B)lLYpmdEelXZIYMdlaiwWrKwNFFqrpMfaZYqP(vywuWspwOG(IWK9QSxjyPRJLHs9RWSamwqfaTPoYyPVXBelGJH5n2OYv1eOrSn28WFWYyd)(0CT2ydKWH5I(dwgBiNikILvelBVpnxRzXFwCTML)sjmlRstymll8vOyb9te8XXS4fil3ZYHzXvHRNLhYs0adSahw00ZYVtSGJOW5Aw8WFWIf9velQKgAILDVa1elXXH8u1RaPHfyXcGy59bf9yJTWCpnNBSzglVRP6T4N0AFYGZ1ElvUQMazrbl9yrD1Aw87tZ1A7qTHW7UQMyrbl9ybhrAD(9bf9yl(9P5AnlaJL4YsxhlMXYSkQbhuK9VuYeCQm4qEQ6vG0yPYv1eil9zPRJL31u9wmCPZWw(3PCdoe(Tu5QAcKffSOUAnlf0xeMYyO2h7qP(vywaglXLffSqb9fHj7vzmu7dlkyrD1Aw87tZ1A7qP(vywaglaywuWcoI0687dk6Xw87tZ1AwIxjwmhw6ZIcw6XIzSmRIAWbfz1jc(44Ctt0FfQmk9LgHjlvUQMazPRJL)sjwqUSyoOHL4zrD1Aw87tZ1A7qP(vywamlaIL(SOGL3hu0B)lLYpmdEelXZcAmEJybGnmVXgvUQManITXMh(dwgB43NMR1gBGeomx0FWYyd54(Dw2EsR9HL44CTNLfMybwSeazX0ovSmuBi8URQjwuxpl4)0Awm53ZsdoSG(jc(4ywIgyGfVazbewO7zzHjwuPgCiwqACeBzz7pTMLfMyrLAWHybPWcbeiIf8vbILF3FwmDAnlrdmWIxWFNgw2EFAUwBSfM7P5CJT31u9w8tATpzW5AVLkxvtGSOGf1vRzXVpnxRTd1gcV7QAIffS0JfZyzwf1GdkYQte8XX5MMO)kuzu6lnctwQCvnbYsxhl)LsSGCzXCqdlXZI5WsFwuWY7dk6T)Ls5hMbpIL4zjUgVrSaOgM3yJkxvtGgX2yZd)blJn87tZ1AJnqchMl6pyzSHCC)olXXH8u1RaPHLfMyz79P5AnlpKfGikILvel)oXI6Q1yrnblUgdzzHVcflBVpnxRzbwSGgwWuawGywGdlAcJzzOu)QRqzSfM7P5CJTzvudoOi7FPKj4uzWH8u1RaPXsLRQjqwuWcoI0687dk6Xw87tZ1AwIxjwIllkyPhlMXI6Q1S)LsMGtLbhYtvVcKg7kIffSOUAnl(9P5ATDO2q4DxvtS01Xspwq4Z5QAYcoKNMnDADU5ADg2ASOGLESOUAnl(9P5ATDOu)kmlaJL4Ysxhl4isRZVpOOhBXVpnxRzjEwaelky5DnvVf)Kw7tgCU2BPYv1eilkyrD1Aw87tZ1A7qP(vywaglOHL(S0NL(gVrSaygM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzS54FCDocAIgwINfaAYSaGyPhlkNmlaplQRwZ(xkzcovgCipv9kqAS43daXsFwaqS0Jf1vRzXVpnxRTdL6xHzb4zjUSGewWrKwN3D8tSa8SyglVRP6T4N0AFYGZ1ElvUQMazPplaiw6Xsac1GqtLf)(0CT2ouQFfMfGNL4YcsybhrADE3XpXcWZY7AQEl(jT2Nm4CT3sLRQjqw6ZcaILESacFBBnjYWwM0RISdL6xHzb4zbnS0NffS0Jf1vRzXVpnxRTRiw66yjaHAqOPYIFFAUwBhk1VcZsFJne(KlpLm2WVpnxRZMG1NBUwNHTMXgiHdZf9hSm2qQRdlT)eMft70VtdlolBVp41GIyzHjwmDAnlbFHjw2EFAUwZYdzP5AnlWwdTS4fillmXY27dEnOiwEilaruelXXH8u1RaPHf87bGyzfz8gXs5KnmVXgvUQManITXMh(dwgB43h8AqrgBGeomx0FWYyloXelBVp41GIyX097SehhYtvVcKgwEilaruelRiw(DIf1vRXIP73HRNfneFfkw2EFAUwZYk6VuIfVazzHjw2EFWRbfXcSyXCamlXggdZZc(9aqyww1FAwmhwEFqrp2ylm3tZ5gBi85CvnzbhYtZMoTo3CTodBnwuWccFoxvtw87tZ16Sjy95MR1zyRXIcwmJfe(CUQMShQcoug)(GxdkILUow6XI6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqSeplXLLUowuxTMv11EfOmSLDTo)7xHcN9j4fzXVhaIL4zjUS0NffSGJiTo)(GIESf)(0CTMfGXI5WIcwq4Z5QAYIFFAUwNnbRp3CTodBnJ3iwkRSH5n2OYv1eOrSn28WFWYyZb9O)qqzSjFsn2cjcAk)(GIESrSu2ydKWH5I(dwgBXjMybBYNuwWqw(D)zjbCXck6zj1rglRO)sjwutWYcFfkwUNfhZI2FIfhZseeJpvnXcSyrtyml)UxSexwWVhacZcCybGKf(zX0ovSexaZc(9aqywiKfDdzSfM7P5CJnZy5VaqxHIffSyglE4pyzDqp6peugBYN0mON6Oi7v5M(qT)S01Xci8ToOh9hckJn5tAg0tDuKf)EaiwaglXLffSacFRd6r)HGYyt(KMb9uhfzhk1VcZcWyjUgVrSugqgM3yJkxvtGgX2yZd)blJTuiSA3qgBHebnLFFqrp2iwkBSbs4WCr)blJnacuBi8olaeHWQDdXY1ybPXajMBfy5WSmKdMaTS870qS4dXIMWyw(DVybnS8(GIEmlxXc6VkFyb9c6lctSy6(Dw2GFCaTSOjmMLF3lwuozwG)onMomXYvS4vcwqVG(IWelWHLvelpKf0WY7dk6XSOsn4qS4SG(RYhwqVG(IWKLL4iSq3ZYqTHW7SaUMRqXcYPRahcKf0lncAIMuQEwwLMWywUILnO2hwqVG(IWKXwyUNMZn2gQneE3v1elky59bf92)sP8dZGhXs8S0JLESOS5WcGzPhl4isRZVpOOhBXVpTBiwaEwaelaplQRwZsb9fHPSEv(yxrS0NL(Saywgk1VcZsFwqcl9yrzwamlVRP6TVPRYPqyHTu5QAcKL(SOGLESeGqni0uzdE(QGDihmblkyXmwaN1bAlyoaIzrbl9ybHpNRQjBawiGarzqcNOcS01Xsac1GqtLnaleqGO8VtzC0n3JTd5GjyPRJfZyjarqLxVTou7FU5el9zPRJfCeP153hu0JT43N2nelaJLES0JfGdlaiw6XI6Q1SuqFrykRxLp2velaplaIL(S0NfGNLESOmlaML31u9230v5uiSWwQCvnbYsFw6ZIcwmJfkOVimzXqTp5Iq2Zsxhl9yHc6lct2RYyO2hw66yPhluqFryYEvwf(7S01Xcf0xeMSxL1RYhw6ZIcwmJL31u9wmCPZWw(3PCdoe(Tu5QAcKLUowuxTMnAUu4aEUo7tWRlKJwASpweUErSeVsSai0Kml9zrbl9ybhrAD(9bf9yl(9PDdXcWyr5Kzb4zPhlkZcGz5DnvV9nDvofclSLkxvtGS0NL(SOGfh)JRZrqt0Ws8SGMKzbaXI6Q1S43NMR12Hs9RWSa8SaCyPplkyPhlMXI6Q1SaDf4qGzkncAIMuQ(mv0G6IjzxrS01Xcf0xeMSxLXqTpS01XIzSeGiOYR3cuI58IL(SOGfZyrD1A2XrqfCHZTHQyMiJVQT059e4NMZTRiJ3iwkhxdZBSrLRQjqJyBS5H)GLXwdobkdB5Y)1qgBGeomx0FWYyloXelXbySybwSeazX097W1ZsWJIUcLXwyUNMZn28OCyNcaz8gXszZXW8gBu5QAc0i2gBWiJnm9gBE4pyzSHWNZv1KXgcxViJnZybCwhOTG5aiMffSGWNZv1KnaMdWc8(dwSOGLES0Jf1vRzXVpnxRTRiw66y5DnvVf)Kw7tgCU2BPYv1eilDDSeGiOYR3whQ9p3CIL(SOGLESyglQRwZIHA8FbYUIyrblMXI6Q1SbpFvWUIyrbl9yXmwExt1BBRjrg2YKEvKLkxvtGS01XI6Q1SbpFvWcUg)pyXs8SeGqni0uzBRjrg2YKEvKDOu)kmlaMfakl9zrbli85Cvnz)9506mMiGOjBYVNffS0JfZyjarqLxVTou7FU5elDDSeGqni0uzdWcbeik)7ughDZ9y7kIffS0Jf1vRzXVpnxRTdL6xHzbySaiw66yXmwExt1BXpP1(KbNR9wQCvnbYsFw6ZIcwEFqrV9Vuk)Wm4rSeplQRwZg88vbl4A8)GflapljBbWS0NLUowAhQ9ppuQFfMfGXI6Q1SbpFvWcUg)pyXsFJne(KlpLm2cG5aSaV)Gv2HKXBelLrJH5n2OYv1eOrSn28WFWYylqAc)NRZU(qvPu9gBGeomx0FWYyloXelingiXCRalWILailRstymlEbYI(kIL7zzfXIP73zbPWcbeiYylm3tZ5gBi85CvnzdG5aSaV)Gv2HKXBelLbogM3yJkxvtGgX2ylm3tZ5gBi85CvnzdG5aSaV)Gv2HKXMh(dwgBxf8P8)GLXBelLbWgM3yJkxvtGgX2yZd)blJnkncAIMSkSan2ajCyUO)GLXwCIjwqV0iOjAyj2WcKfyXsaKft3VZY27tZ1AwwrS4filyhbXsdoSaaxASpS4filingiXCRGXwyUNMZn2uHymlky5QNMiO2Fcm3ou7FEOu)kmlaJfLrdlDDS0Jf1vRzJMlfoGNRZ(e86c5OLg7JfHRxelaJfaHMKzPRJf1vRzJMlfoGNRZ(e86c5OLg7JfHRxelXRelacnjZsFwuWI6Q1S43NMR12velkyPhlbiudcnv2GNVkyhk1VcZs8SGMKzPRJfWzDG2cMdGyw6B8gXszaQH5n2OYv1eOrSn28WFWYyd)Kw7tUP9Hm2cjcAk)(GIESrSu2ydKWH5I(dwgBaeO2q4DwAAFiwGflRiwEilXLL3hu0JzX097W1ZcsJbsm3kWIkDfkwCv46z5HSqil6gIfVazPGplqe0e8OORqzSfM7P5CJTHAdH3DvnXIcw(lLYpmdEelXZIYOHffSGJiTo)(GIESf)(0UHybySyoSOGfpkh2PaqSOGLESOUAnBWZxfSdL6xHzjEwuozw66yXmwuxTMn45Rc2vel9nEJyPmaZW8gBu5QAc0i2gBE4pyzS1wtImSLj9QiJnqchMl6pyzSfNyIL4ae9y5ASCf(ajw8If0lOVimXIxGSOVIy5EwwrSy6(DwCwaGln2hwIgyGfVazjgGE0Fiiw2m5tQXwyUNMZn2OG(IWK9QSxjyrblEuoStbGyrblQRwZgnxkCapxN9j41fYrln2hlcxViwaglacnjZIcw6Xci8ToOh9hckJn5tAg0tDuK9VaqxHILUowmJLaebvE92Icdudhqw66ybhrAD(9bf9ywINfaXsFwuWspwuxTMDCeubx4CBOkMjSdL6xHzbySaWybaXspwqdlaplZQOgCqrw8vTLoVNa)0CULkxvtGS0NffSOUAn74iOcUW52qvmtyxrS01XIzSOUAn74iOcUW52qvmtyxrS0NffS0JfZyjaHAqOPYg88vb7kILUowuxTM93NtRZyIaIgl(9aqSamwugnSOGL2HA)ZdL6xHzbySaOKtMffS0ou7FEOu)kmlXZIYjNmlDDSygly4sREfO93NtRZyIaIglvUQMazPplkyPhly4sREfO93NtRZyIaIglvUQMazPRJLaeQbHMkBWZxfSdL6xHzjEwIBYS034nIfGs2W8gBu5QAc0i2gBE4pyzSHFFAUwBSbs4WCr)blJT4etS4SS9(0CTMfaYf97SenWalRstymlBVpnxRz5WS46HCWeSSIyboSKaUyXhIfxfUEwEilqe0e8iwIbgaASfM7P5CJn1vRzHf974Cenbk6pyzxrSOGLESOUAnl(9P5ATDO2q4DxvtS01XIJ)X15iOjAyjEwayjZsFJ3iwaszdZBSrLRQjqJyBS5H)GLXg(9P5ATXgiHdZf9hSm2IJR0iwIbgaYIk1GdXcsHfciqelMUFNLT3NMR1S4fil)ovSS9(GxdkYylm3tZ5gBbicQ86T1HA)ZnNyrblMXY7AQEl(jT2Nm4CT3sLRQjqwuWspwq4Z5QAYgGfciqugKWjQalDDSeGqni0uzdE(QGDfXsxhlQRwZg88vb7kIL(SOGLaeQbHMkBawiGar5FNY4OBUhBhk1VcZcWybva0M6iJfGNLaDAw6XIJ)X15iOjAybjSGMKzPplkyrD1Aw87tZ1A7qP(vywaglMdlkyXmwaN1bAlyoaInEJybiazyEJnQCvnbAeBJTWCpnNBSfGiOYR3whQ9p3CIffS0Jfe(CUQMSbyHaceLbjCIkWsxhlbiudcnv2GNVkyxrS01XI6Q1SbpFvWUIyPplkyjaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWSamwaoSOGf1vRzXVpnxRTRiwuWcf0xeMSxL9kblkyXmwq4Z5QAYEOk4qz87dEnOiwuWIzSaoRd0wWCaeBS5H)GLXg(9bVguKXBelafxdZBSrLRQjqJyBS5H)GLXg(9bVguKXgiHdZf9hSm2ItmXY27dEnOiwmD)olEXca5I(DwIgyGf4WY1yjbCHoqwGiOj4rSedmaKft3VZsc4AyPiK9SeC8BzjgAmKfWvAelXadazXFw(DIfQazb2y53jwaiLQFpXWI6Q1y5ASS9(0CTMftWLgSq3ZsZ1AwGTglWHLeWfl(qSalwaelVpOOhBSfM7P5CJn1vRzHf974Cqt(KrC4dw2velDDS0JfZyb)(0UHSEuoStbGyrblMXccFoxvt2dvbhkJFFWRbfXsxhl9yrD1A2GNVkyhk1VcZcWybnSOGf1vRzdE(QGDfXsxhl9yPhlQRwZg88vb7qP(vywaglOcG2uhzSa8SeOtZspwC8pUohbnrdliHL4Mml9zrblQRwZg88vb7kILUowuxTMDCeubx4CBOkMjY4RAlDEpb(P5C7qP(vywaglOcG2uhzSa8SeOtZspwC8pUohbnrdliHL4Mml9zrblQRwZoocQGlCUnufZez8vTLoVNa)0CUDfXsFwuWsaIGkVElcQ(9edl9zPplkyPhl4isRZVpOOhBXVpnxRzbySexw66ybHpNRQjl(9P5AD2eS(CZ16mS1yPpl9zrblMXccFoxvt2dvbhkJFFWRbfXIcw6XIzSmRIAWbfz)lLmbNkdoKNQEfinwQCvnbYsxhl4isRZVpOOhBXVpnxRzbySexw6B8gXcqMJH5n2OYv1eOrSn28WFWYyRit5uiSm2ajCyUO)GLXwCIjwaicHfMLRyzdQ9Hf0lOVimXIxGSGDeelXHLwZcariSyPbhwqAmqI5wbJTWCpnNBS1Jf1vRzPG(IWugd1(yhk1VcZs8SqiJcRNY)LsS01Xspwc7(GIWSOelaIffSmuy3huu(VuIfGXcAyPplDDSe29bfHzrjwIll9zrblEuoStbGmEJybi0yyEJnQCvnbAeBJTWCpnNBS1Jf1vRzPG(IWugd1(yhk1VcZs8SqiJcRNY)LsS01Xspwc7(GIWSOelaIffSmuy3huu(VuIfGXcAyPplDDSe29bfHzrjwIll9zrblEuoStbGyrbl9yrD1A2XrqfCHZTHQyMWouQFfMfGXcAyrblQRwZoocQGlCUnufZe2velkyXmwMvrn4GIS4RAlDEpb(P5ClvUQMazPRJfZyrD1A2XrqfCHZTHQyMWUIyPVXMh(dwgB7UULtHWY4nIfGaogM3yJkxvtGgX2ylm3tZ5gB9yrD1AwkOVimLXqTp2Hs9RWSepleYOW6P8FPelkyPhlbiudcnv2GNVkyhk1VcZs8SGMKzPRJLaeQbHMkBawiGar5FNY4OBUhBhk1VcZs8SGMKzPplDDS0JLWUpOimlkXcGyrbldf29bfL)lLybySGgw6ZsxhlHDFqrywuIL4YsFwuWIhLd7uaiwuWspwuxTMDCeubx4CBOkMjSdL6xHzbySGgwuWI6Q1SJJGk4cNBdvXmHDfXIcwmJLzvudoOil(Q2sN3tGFAo3sLRQjqw66yXmwuxTMDCeubx4CBOkMjSRiw6BS5H)GLXwBP15uiSmEJybiaSH5n2OYv1eOrSn2ajCyUO)GLXwCIjwqoGOhlWIfKghn28WFWYyZKpZbNmSLj9QiJ3iwacGAyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXgoI0687dk6Xw87t7gIL4zXCybWS00q4WspwsD8ttImcxViwaEwuo5KzbjSaOKzPplaMLMgchw6XI6Q1S43h8AqrzkncAIMuQ(mgQ9XIFpaeliHfZHL(gBi8jxEkzSHFFA3q5RYyO2hJnqchMl6pyzSHuxhwA)jmlM2PFNgwEillmXY27t7gILRyzdQ9Hft7xyNLdZI)SGgwEFqrpgWkZsdoSqiOjblakzKllPo(PjblWHfZHLT3h8AqrSGEPrqt0Ks1Zc(9aqyJ3iwacGzyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXMYSGewWrKwN3D8tSamwaelaiw6XsYwaXcWZspwWrKwNFFqrp2IFFA3qSaGyrzw6ZcWZspwuMfaZY7AQElgU0zyl)7uUbhc)wQCvnbYcWZIYw0WsFw6ZcGzjzRYOHfGNf1vRzhhbvWfo3gQIzc7qP(vyJne(KlpLm2mn(VNVk3gQIzcJnqchMl6pyzSHuxhwA)jmlM2PFNgwEilihJ)7SaUMRqXsCyOkMjmEJyf3KnmVXgvUQManITXMh(dwgBMg)3n2ajCyUO)GLXwCIjwqog)3z5kw2GAFyb9c6lctSahwUglfKLT3N2nelMoTML29SC1dzbPXajMBfyXRePWHm2cZ90CUXwpwOG(IWKvVkFYfHSNLUowOG(IWK1Re5Iq2ZIcwq4Z5QAYE4CqtocIL(SOGLES8(GIE7FPu(HzWJyjEwmhw66yHc6lctw9Q8jFvgqS01Xs7qT)5Hs9RWSamwuozw6ZsxhlQRwZsb9fHPmgQ9XouQFfMfGXIh(dww87t7gYsiJcRNY)LsSOGf1vRzPG(IWugd1(yxrS01Xcf0xeMSxLXqTpSOGfZybHpNRQjl(9PDdLVkJHAFyPRJf1vRzdE(QGDOu)kmlaJfp8hSS43N2nKLqgfwpL)lLyrblMXccFoxvt2dNdAYrqSOGf1vRzdE(QGDOu)kmlaJfczuy9u(VuIffSOUAnBWZxfSRiw66yrD1A2XrqfCHZTHQyMWUIyrbli85Cvnznn(VNVk3gQIzcw66yXmwq4Z5QAYE4CqtocIffSOUAnBWZxfSdL6xHzjEwiKrH1t5)sjJ3iwXvzdZBSrLRQjqJyBSbs4WCr)blJT4etSS9(0UHy5ASCflO)Q8Hf0lOVimHwwUILnO2hwqVG(IWelWIfZbWS8(GIEmlWHLhYs0adSSb1(Wc6f0xeMm28WFWYyd)(0UHmEJyfxazyEJnQCvnbAeBJnp8hSm2MvL9WFWkRp8BSbs4WCr)blJT4GR1)(Sm20h(ZLNsgBnxR)9zz8gVXwZ16FFwgM3iwkByEJnQCvnbAeBJnp8hSm2WVp41GIm2ajCyUO)GLX227dEnOiwAWHLuickLQNLvPjmMLf(kuSeBymmVXwyUNMZn2mJLzvudoOiRQR9kqzyl7AD(3Vcf2sa31ffrGgVrSaKH5n2OYv1eOrSn28WFWYydVQ2nKXwirqt53hu0JnILYgBGeomx0FWYydPo(z53jwaHplMUFNLFNyjfIFw(lLy5HS4GGSSQ)0S87elPoYybCn(FWILdZY(9ww2wv7gILHs9RWSKU0)fPpcKLhYsQ)HDwsHWQDdXc4A8)GLXwyUNMZn2aHVnfcR2nKDOu)kmlXZYqP(vywaEwaeGybjSOma14nIvCnmVXMh(dwgBPqy1UHm2OYv1eOrSnEJ3yd)gM3iwkByEJnQCvnbAeBJnp8hSm2WVp41GIm2ajCyUO)GLXwCIjw2EFWRbfXYdzbiIIyzfXYVtSehhYtvVcKgwuxTglxJL7zXeCPbzHqw0nelQudoelTRo8(vOy53jwkczplbh)SahwEilGR0iwuPgCiwqkSqabIm2cZ90CUX2SkQbhuK9VuYeCQm4qEQ6vG0yPYv1eilkyPhluqFryYEv2ReSOGfZyPhl9yrD1A2)sjtWPYGd5PQxbsJDOu)kmlXZIh(dwwtJ)7wczuy9u(VuIfaZsYwLzrbl9yHc6lct2RYQWFNLUowOG(IWK9QmgQ9HLUowOG(IWKvVkFYfHSNL(S01XI6Q1S)LsMGtLbhYtvVcKg7qP(vywINfp8hSS43N2nKLqgfwpL)lLybWSKSvzwuWspwOG(IWK9QSEv(WsxhluqFryYIHAFYfHSNLUowOG(IWK1Re5Iq2ZsFw6ZsxhlMXI6Q1S)LsMGtLbhYtvVcKg7kIL(S01XspwuxTMn45Rc2velDDSGWNZv1KnaleqGOmiHtubw6ZIcwcqOgeAQSbyHaceL)DkJJU5ESDihmblkyjarqLxVTou7FU5el9zrbl9yXmwcqeu51BbkXCEXsxhlbiudcnvwkncAIMSkSaTdL6xHzjEwaOS0NffS0Jf1vRzdE(QGDfXsxhlMXsac1GqtLn45Rc2HCWeS034nIfGmmVXgvUQManITXMh(dwgBoOh9hckJn5tQXwirqt53hu0JnILYgBGeomx0FWYyloXelXa0J(dbXYMjFszX0ovS870qSCywkilE4peelyt(KIwwCmlA)jwCmlrqm(u1elWIfSjFszX097SaiwGdlnYenSGFpaeMf4WcSyXzjUaMfSjFszbdz539NLFNyPitSGn5tkl(mhccZcajl8ZI3EAy539NfSjFszHqw0ne2ylm3tZ5gBMXci8ToOh9hckJn5tAg0tDuK9VaqxHIffSyglE4pyzDqp6peugBYN0mON6Oi7v5M(qT)SOGLESyglGW36GE0FiOm2KpP5DY12)caDfkw66ybe(wh0J(dbLXM8jnVtU2ouQFfML4zbnS0NLUowaHV1b9O)qqzSjFsZGEQJIS43daXcWyjUSOGfq4BDqp6peugBYN0mON6Oi7qP(vywaglXLffSacFRd6r)HGYyt(KMb9uhfz)la0vOmEJyfxdZBSrLRQjqJyBS5H)GLXwawiGar5FNY4OBUhBSbs4WCr)blJT4etywqkSqabIy5ASG0yGeZTcSCywwrSahwsaxS4dXciHtuHRqXcsJbsm3kWIP73zbPWcbeiIfVazjbCXIpelQKgAIfZjzwIbgaASfM7P5CJnZybCwhOTG5aiMffS0JLESGWNZv1KnaleqGOmiHtubwuWIzSeGqni0uzdE(QGDihmblkyXmwMvrn4GISrZLchWZ1zFcEDHC0sJ9XsLRQjqw66yrD1A2GNVkyxrS0NffS44FCDocAIgwaMsSyojZIcw6XI6Q1SuqFrykRxLp2Hs9RWSeplkNmlDDSOUAnlf0xeMYyO2h7qP(vywINfLtML(S01XIkeJzrblTd1(Nhk1VcZcWyr5KzrblMXsac1GqtLn45Rc2HCWeS034nIL5yyEJnQCvnbAeBJnyKXgMEJnp8hSm2q4Z5QAYydHRxKXwpwuxTMDCeubx4CBOkMjSdL6xHzjEwqdlDDSyglQRwZoocQGlCUnufZe2vel9zrblMXI6Q1SJJGk4cNBdvXmrgFvBPZ7jWpnNBxrSOGLESOUAnlqxboeyMsJGMOjLQptfnOUys2Hs9RWSamwqfaTPoYyPplkyPhlQRwZsb9fHPmgQ9XouQFfML4zbva0M6iJLUowuxTMLc6lctz9Q8XouQFfML4zbva0M6iJLUow6XIzSOUAnlf0xeMY6v5JDfXsxhlMXI6Q1SuqFrykJHAFSRiw6ZIcwmJL31u9wmuJ)lqwQCvnbYsFJne(KlpLm2aHFEiG76gkLQhBSbs4WCr)blJnKclW7pyXsdoS4AnlGWhZYV7plPoqeMf8Aiw(Dkbl(qf6EwgQneENazX0ovSaqWrqfCHzjomufZeSS7yw0egZYV7flOHfmfWSmuQF1vOyboS87elaLyoVyrD1ASCywCv46z5HS0CTMfyRXcCyXReSGEb9fHjwomlUkC9S8qwiKfDdz8gXcngM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzS1JfZyrD1AwkOVimLXqTp2velkyXmwuxTMLc6lctz9Q8XUIyPplDDS8UMQ3IHA8FbYsLRQjqJne(KlpLm2aHFgUE8bszkOVimzSbs4WCr)blJnKclW7pyXYV7plHDkaeMLRXsc4IfFiwGRhFGeluqFryILhYcS0jybe(S870qSahwoufCiw(9dZIP73zzdQX)fiJ3iwahdZBSrLRQjqJyBSfM7P5CJTHAdH3DvnXIcw6XI6Q1SuqFrykJHAFSdL6xHzjEwgk1VcZsxhlQRwZsb9fHPSEv(yhk1VcZs8SmuQFfMLUowq4Z5QAYcc)mC94dKYuqFryIL(SOGLHAdH3DvnXIcwEFqrV9Vuk)Wm4rSeplkdiwuWIhLd7uaiwuWccFoxvtwq4Nhc4UUHsP6XgBE4pyzSLcHv7gYylKiOP87dk6XgXszJ3iwaydZBSrLRQjqJyBSfM7P5CJTHAdH3DvnXIcw6XI6Q1SuqFrykJHAFSdL6xHzjEwgk1VcZsxhlQRwZsb9fHPSEv(yhk1VcZs8SmuQFfMLUowq4Z5QAYcc)mC94dKYuqFryIL(SOGLHAdH3DvnXIcwEFqrV9Vuk)Wm4rSeplkdiwuWIhLd7uaiwuWccFoxvtwq4Nhc4UUHsP6XgBE4pyzSHxv7gYylKiOP87dk6XgXszJ3iwaudZBSrLRQjqJyBSfM7P5CJTHAdH3DvnXIcw6XI6Q1SuqFrykJHAFSdL6xHzjEwgk1VcZsxhlQRwZsb9fHPSEv(yhk1VcZs8SmuQFfMLUowq4Z5QAYcc)mC94dKYuqFryIL(SOGLHAdH3DvnXIcwEFqrV9Vuk)Wm4rSeplkdCyrblEuoStbGyrbli85CvnzbHFEiG76gkLQhBS5H)GLXg(jT2NCt7dzSfse0u(9bf9yJyPSXBelaMH5n2OYv1eOrSn28WFWYyRbNaLHTC5)AiJnqchMl6pyzSfNyIL4amwSalwcGSy6(D46zj4rrxHYylm3tZ5gBEuoStbGmEJyPCYgM3yJkxvtGgX2yZd)blJnkncAIMSkSan2ajCyUO)GLXwCIjwqoDf4qGSSfDZ9ywmD)olELGfnSqXcvWfQDw0o(VcflOxqFryIfVaz5NeS8qw0xrSCplRiwmD)olaWLg7dlEbYcsJbsm3kySfM7P5CJTES0Jf1vRzPG(IWugd1(yhk1VcZs8SOCYS01XI6Q1SuqFrykRxLp2Hs9RWSeplkNml9zrblbiudcnv2GNVkyhk1VcZs8Se3Kzrbl9yrD1A2O5sHd456SpbVUqoAPX(yr46fXcWybqMtYS01XIzSmRIAWbfzJMlfoGNRZ(e86c5OLg7JLaURlkIazPpl9zPRJf1vRzJMlfoGNRZ(e86c5OLg7JfHRxelXRelacaNmlDDSeGqni0uzdE(QGDihmblkyXX)46Ce0enSeplaSKnEJyPSYgM3yJkxvtGgX2ydgzSHP3yZd)blJne(CUQMm2q46fzSzglGZ6aTfmhaXSOGfe(CUQMSbWCawG3FWIffS0JLESeGqni0uzP0Oed56mCalVcKDOu)kmlaJfLboaywaml9yrzLzb4zzwf1GdkYIVQT059e4NMZTu5QAcKL(SOGfc4UUOic0sPrjgY1z4awEfiw6Zsxhlo(hxNJGMOHL4vIfawYSOGLESyglVRP6TT1KidBzsVkYsLRQjqw66yrD1A2GNVkybxJ)hSyjEwcqOgeAQST1KidBzsVkYouQFfMfaZcaLL(SOGfe(CUQMS)(CADgteq0Kn53ZIcw6XI6Q1SaDf4qGzkncAIMuQ(mv0G6IjzxrS01XIzSeGiOYR3cuI58IL(SOGL3hu0B)lLYpmdEelXZI6Q1SbpFvWcUg)pyXcWZsYwamlDDSOcXywuWs7qT)5Hs9RWSamwuxTMn45RcwW14)blw66yjarqLxVTou7FU5elDDSOUAnRQgcb1l8BxrSOGf1vRzv1qiOEHF7qP(vywaglQRwZg88vbl4A8)GflaMLESaWyb4zzwf1GdkYgnxkCapxN9j41fYrln2hlbCxxuebYsFw6ZIcwmJf1vRzdE(QGDfXIcw6XIzSeGiOYR3whQ9p3CILUowcqOgeAQSbyHaceL)DkJJU5ESDfXsxhlQqmMffS0ou7FEOu)kmlaJLaeQbHMkBawiGar5FNY4OBUhBhk1VcZcGzb4WsxhlTd1(Nhk1VcZcYLfLbOjZcWyrD1A2GNVkybxJ)hSyPVXgcFYLNsgBbWCawG3FWkJFJnqchMl6pyzSfNyIfKgdKyUvGft3VZcsHfciqesqoDf4qGSSfDZ9yw8cKfqyHUNficAmn3tSaaxASpSahwmTtflXwdHG6f(zXeCPbzHqw0nelQudoelingiXCRaleYIUHWgVrSugqgM3yJkxvtGgX2yZd)blJTXrqfCHZTHQyMWydKWH5I(dwgBXjMy53jwaiLQFpXWIP73zXzbPXajMBfy539NLdxO7zPnWuwaGln2hJTWCpnNBSPUAnBWZxfSdL6xHzjEwugnS01XI6Q1SbpFvWcUg)pyXcWyjUjZIcwq4Z5QAYgaZbybE)bRm(nEJyPCCnmVXgvUQManITXwyUNMZn2q4Z5QAYgaZbybE)bRm(zrbl9yXmwuxTMn45RcwW14)blwINL4MmlDDSyglbicQ86TiO63tmS0NLUowuxTMDCeubx4CBOkMjSRiwuWI6Q1SJJGk4cNBdvXmHDOu)kmlaJfaglaMLaSax3BJgkCyk76dvLs1B)lLYiC9IybWS0JfZyrD1AwvnecQx43UIyrblMXY7AQEl(9rdhqlvUQMazPVXMh(dwgBbst4)CD21hQkLQ34nILYMJH5n2OYv1eOrSn2cZ90CUXgcFoxvt2ayoalW7pyLXVXMh(dwgBxf8P8)GLXBelLrJH5n2OYv1eOrSn2GrgBy6n28WFWYydHpNRQjJneUErgBMXsac1GqtLn45Rc2HCWeS01XIzSGWNZv1KnaleqGOmiHtubwuWsaIGkVEBDO2)CZjw66ybCwhOTG5ai2ydHp5YtjJnSJGYn4KdE(QGXgiHdZf9hSm2ai1NZv1ellmbYcSyXvp99hHz539NftE9S8qwujwWoccKLgCybPXajMBfybdz539NLFNsWIpu9SyYXpbYcajl8ZIk1GdXYVtPgVrSug4yyEJnQCvnbAeBJnp8hSm2ARjrg2YKEvKXgiHdZf9hSm2ItmHzjoarpwUglxXIxSGEb9fHjw8cKLFocZYdzrFfXY9SSIyX097SaaxASpOLfKgdKyUvGfVazjgGE0Fiiw2m5tQXwyUNMZn2OG(IWK9QSxjyrblEuoStbGyrblQRwZgnxkCapxN9j41fYrln2hlcxViwaglaYCsMffS0Jfq4BDqp6peugBYN0mON6Oi7FbGUcflDDSyglbicQ86TffgOgoGS0NffSGWNZv1Kf7iOCdo5GNVkWIcw6XI6Q1SJJGk4cNBdvXmHDOu)kmlaJfaglaiw6XcAyb4zzwf1GdkYIVQT059e4NMZTu5QAcKL(SOGf1vRzhhbvWfo3gQIzc7kILUowmJf1vRzhhbvWfo3gQIzc7kIL(gVrSugaByEJnQCvnbAeBJnp8hSm2WVpnxRn2ajCyUO)GLXwCIjwaix0VZY27tZ1AwIgyaZY1yz79P5AnlhUq3ZYkYylm3tZ5gBQRwZcl63X5iAcu0FWYUIyrblQRwZIFFAUwBhQneE3v1KXBelLbOgM3ytD1A5YtjJn87JgoGgBu5QAc0i2gBE4pyzSf8kq6S6Q1m2cZ90CUXM6Q1S43hnCaTdL6xHzbySGgwuWspwuxTMLc6lctzmu7JDOu)kmlXZcAyPRJf1vRzPG(IWuwVkFSdL6xHzjEwqdl9zrblo(hxNJGMOHL4zbGLSXBelLbygM3yJkxvtGgX2yZd)blJn87dEnOiJnqchMl6pyzSfhxPrywIbgaYIk1GdXcsHfciqell8vOy53jwqkSqabIyjalW7pyXYdzjStbGy5ASGuyHaceXYHzXd)Y16eS4QW1ZYdzrLyj443ylm3tZ5gBbicQ86T1HA)ZnNyrbli85CvnzdWcbeikds4evGffSeGqni0uzdWcbeik)7ughDZ9y7qP(vywaglOHffSyglGZ6aTfmhaXSOGfkOVimzVk7vcwuWIJ)X15iOjAyjEwmNKnEJybOKnmVXgvUQManITXMh(dwgB43NMR1gBGeomx0FWYyloXelBVpnxRzX097SS9Kw7dlXX5AplEbYsbzz79rdhq0YIPDQyPGSS9(0CTMLdZYkcTSKaUyXhILRyb9xLpSGEb9fHjwAWHfakGXuaZcCy5HSenWalaWLg7dlM2PIfxfIGybGLmlXadazboS4Gr(FiiwWM8jLLDhZcafWykGzzOu)QRqXcCy5WSCfln9HA)TSel4tS87(ZYQaPHLFNyb7PelbybE)blml3JomlGrywkA9JRz5HSS9(0CTMfW1Cfkwai4iOcUWSehgQIzc0YIPDQyjbCHoqwW)P1SqfilRiwmD)olaSKbSJJyPbhw(DIfTJFwqPHQUgBn2cZ90CUX27AQEl(jT2Nm4CT3sLRQjqwuWIzS8UMQ3IFF0Wb0sLRQjqwuWI6Q1S43NMR12HAdH3DvnXIcw6XI6Q1SuqFrykRxLp2Hs9RWSeplauwuWcf0xeMSxL1RYhwuWI6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lIfGXcGqtYS01XI6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lIL4vIfaHMKzrblo(hxNJGMOHL4zbGLmlDDSacFRd6r)HGYyt(KMb9uhfzhk1VcZs8SaqzPRJfp8hSSoOh9hckJn5tAg0tDuK9QCtFO2Fw6ZIcwcqOgeAQSbpFvWouQFfML4zr5KnEJybiLnmVXgvUQManITXMh(dwgB43h8AqrgBGeomx0FWYyloXelBVp41GIybGCr)olrdmGzXlqwaxPrSedmaKft7uXcsJbsm3kWcCy53jwaiLQFpXWI6Q1y5WS4QW1ZYdzP5AnlWwJf4Wsc4cDGSe8iwIbgaASfM7P5CJn1vRzHf974Cqt(KrC4dw2velDDSOUAnlqxboeyMsJGMOjLQptfnOUys2velDDSOUAnBWZxfSRiwuWspwuxTMDCeubx4CBOkMjSdL6xHzbySGkaAtDKXcWZsGonl9yXX)46Ce0enSGewIBYS0NfaZsCzb4z5DnvVTit5uiSSu5QAcKffSyglZQOgCqrw8vTLoVNa)0CULkxvtGSOGf1vRzhhbvWfo3gQIzc7kILUowuxTMn45Rc2Hs9RWSamwqfaTPoYyb4zjqNMLES44FCDocAIgwqclXnzw6ZsxhlQRwZoocQGlCUnufZez8vTLoVNa)0CUDfXsxhlMXI6Q1SJJGk4cNBdvXmHDfXIcwmJLaeQbHMk74iOcUW52qvmtyhYbtWsxhlMXsaIGkVElcQ(9edl9zPRJfh)JRZrqt0Ws8SaWsMffSqb9fHj7vzVsy8gXcqaYW8gBu5QAc0i2gBE4pyzSHFFWRbfzSbs4WCr)blJnZpjy5HSK6arS87elQe(zb2yz79rdhqwutWc(9aqxHIL7zzfXcWDDbG0jy5kw8kblOxqFryIf11ZcaCPX(WYHRNfxfUEwEilQelrdmeiqJTWCpnNBS9UMQ3IFF0Wb0sLRQjqwuWIzSmRIAWbfz)lLmbNkdoKNQEfinwQCvnbYIcw6XI6Q1S43hnCaTRiw66yXX)46Ce0enSeplaSKzPplkyrD1Aw87JgoGw87bGybySexwuWspwuxTMLc6lctzmu7JDfXsxhlQRwZsb9fHPSEv(yxrS0NffSOUAnB0CPWb8CD2NGxxihT0yFSiC9IybySaiaCYSOGLESeGqni0uzdE(QGDOu)kmlXZIYjZsxhlMXccFoxvt2aSqabIYGeorfyrblbicQ86T1HA)ZnNyPVXBelafxdZBSrLRQjqJyBSbJm2W0BS5H)GLXgcFoxvtgBiC9Im2OG(IWK9QSEv(WcWZcaLfKWIh(dww87t7gYsiJcRNY)LsSaywmJfkOVimzVkRxLpSa8S0JfGdlaML31u9wmCPZWw(3PCdoe(Tu5QAcKfGNL4YsFwqclE4pyznn(VBjKrH1t5)sjwamljBnh0WcsybhrADE3XpXcGzjzlAyb4z5DnvVT8FneoR6AVcKLkxvtGgBi8jxEkzS54iainBuWydKWH5I(dwgBOh(Vu)jml7qtSKUc7SedmaKfFiwq5xrGSerdlykalqJ3iwaYCmmVXgvUQManITXMh(dwgB43h8AqrgBGeomx0FWYyloUsJyz79bVguelxXIZcagWykWYgu7dlOxqFrycTSacl09SOPNL7zjAGbwaGln2hw697(ZYHzz3lqnbYIAcwO73PHLFNyz79P5Anl6RiwGdl)oXsmWaW4byjZI(kILgCyz79bVguuF0YciSq3ZcebnMM7jw8IfaYf97SenWalEbYIMEw(DIfxfIGyrFfXYUxGAILT3hnCan2cZ90CUXMzSmRIAWbfz)lLmbNkdoKNQEfinwQCvnbYIcw6XI6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lIfGXcGaWjZsxhlQRwZgnxkCapxN9j41fYrln2hlcxViwaglacnjZIcwExt1BXpP1(KbNR9wQCvnbYsFwuWspwOG(IWK9QmgQ9HffS44FCDocAIgwamli85CvnzDCeaKMnkWcWZI6Q1SuqFrykJHAFSdL6xHzbWSacFBBnjYWwM0RIS)facNhk1VIfGNfazrdlXZcanzw66yHc6lct2RY6v5dlkyXX)46Ce0enSaywq4Z5QAY64iainBuGfGNf1vRzPG(IWuwVkFSdL6xHzbWSacFBBnjYWwM0RIS)facNhk1VIfGNfazrdlXZcalzw6ZIcwmJf1vRzHf974Cenbk6pyzxrSOGfZy5DnvVf)(OHdOLkxvtGSOGLESeGqni0uzdE(QGDOu)kmlXZcaMLUowWWLw9kq7VpNwNXebenwQCvnbYIcwuxTM93NtRZyIaIgl(9aqSamwIBCzbaXspwMvrn4GIS4RAlDEpb(P5ClvUQMazb4zbnS0NffS0ou7FEOu)kmlXZIYjNmlkyPDO2)8qP(vywaglak5KzPplkyPhlbiudcnvwGUcCiWmo6M7X2Hs9RWSeplayw66yXmwcqeu51BbkXCEXsFJ3iwacngM3yJkxvtGgX2yZd)blJTImLtHWYydKWH5I(dwgBXjMybGiewywUIf0Fv(Wc6f0xeMyXlqwWocIfKZ46gGJdlTMfaIqyXsdoSG0yGeZTcS4filiNUcCiqwqV0iOjAsP6n2cZ90CUXwpwuxTMLc6lctz9Q8XouQFfML4zHqgfwpL)lLyPRJLESe29bfHzrjwaelkyzOWUpOO8FPelaJf0WsFw66yjS7dkcZIsSexw6ZIcw8OCyNcaXIcwq4Z5QAYIDeuUbNCWZxfmEJybiGJH5n2OYv1eOrSn2cZ90CUXwpwuxTMLc6lctz9Q8XouQFfML4zHqgfwpL)lLyrblMXsaIGkVElqjMZlw66yPhlQRwZc0vGdbMP0iOjAsP6ZurdQlMKDfXIcwcqeu51BbkXCEXsFw66yPhlHDFqrywuIfaXIcwgkS7dkk)xkXcWybnS0NLUowc7(GIWSOelXLLUowuxTMn45Rc2vel9zrblEuoStbGyrbli85CvnzXock3Gto45RcSOGLESOUAn74iOcUW52qvmtyhk1VcZcWyPhlOHfaelaIfGNLzvudoOil(Q2sN3tGFAo3sLRQjqw6ZIcwuxTMDCeubx4CBOkMjSRiw66yXmwuxTMDCeubx4CBOkMjSRiw6BS5H)GLX2URB5uiSmEJybiaSH5n2OYv1eOrSn2cZ90CUXwpwuxTMLc6lctz9Q8XouQFfML4zHqgfwpL)lLyrblMXsaIGkVElqjMZlw66yPhlQRwZc0vGdbMP0iOjAsP6ZurdQlMKDfXIcwcqeu51BbkXCEXsFw66yPhlHDFqrywuIfaXIcwgkS7dkk)xkXcWybnS0NLUowc7(GIWSOelXLLUowuxTMn45Rc2vel9zrblEuoStbGyrbli85CvnzXock3Gto45RcSOGLESOUAn74iOcUW52qvmtyhk1VcZcWybnSOGf1vRzhhbvWfo3gQIzc7kIffSyglZQOgCqrw8vTLoVNa)0CULkxvtGS01XIzSOUAn74iOcUW52qvmtyxrS03yZd)blJT2sRZPqyz8gXcqaudZBSrLRQjqJyBSbs4WCr)blJT4etSGCarpwGflbqJnp8hSm2m5ZCWjdBzsVkY4nIfGaygM3yJkxvtGgX2yZd)blJn87t7gYydKWH5I(dwgBXjMyz79PDdXYdzjAGbw2GAFyb9c6lctOLfKgdKyUvGLDhZIMWyw(lLy539IfNfKJX)DwiKrH1tSOP2ZcCybw6eSG(RYhwqVG(IWelhMLvKXwyUNMZn2OG(IWK9QSEv(WsxhluqFryYIHAFYfHSNLUowOG(IWK1Re5Iq2Zsxhl9yrD1Awt(mhCYWwM0RISRiw66ybhrADE3XpXcWyjzR5GgwuWIzSeGiOYR3IGQFpXWsxhl4isRZ7o(jwagljBnhwuWsaIGkVElcQ(9edl9zrblQRwZsb9fHPSEv(yxrS01XspwuxTMn45Rc2Hs9RWSamw8WFWYAA8F3siJcRNY)LsSOGf1vRzdE(QGDfXsFJ3iwXnzdZBSrLRQjqJyBSbs4WCr)blJT4etSGCm(VZc83PX0HjwmTFHDwomlxXYgu7dlOxqFrycTSG0yGeZTcSahwEilrdmWc6VkFyb9c6lctgBE4pyzSzA8F34nIvCv2W8gBu5QAc0i2gBE4pyzSnRk7H)GvwF43ydKWH5I(dwgBXbxR)9zzSPp8NlpLm2AUw)7ZY4nEJTOHcWuv)nmVrSu2W8gBE4pyzSb0vGdbMXr3Cp2yJkxvtGgX24nIfGmmVXgvUQManITXgmYydtVXMh(dwgBi85CvnzSHW1lYylzJne(KlpLm2GvEHP8pxbe9gBGeomx0FWYyZ87eli85CvnXYHzbtplpKLKzX097SuqwWV)SalwwyILFUci6XOLfLzX0ovS87elTBWplWIy5WSalwwycTSaiwUgl)oXcMcWcKLdZIxGSexwUglQWFNfFiJ3iwX1W8gBu5QAc0i2gBWiJnhe0yZd)blJne(CUQMm2q46fzSPSXgcFYLNsgBWkVWu(NRaIEJTWCpnNBS9ZvarV9v2UWUQMyrbl)Cfq0BFLTbiudcnvwW14)blJ3iwMJH5n2OYv1eOrSn2GrgBoiOXMh(dwgBi85CvnzSHW1lYydqgBi8jxEkzSbR8ct5FUci6n2cZ90CUX2pxbe92hq2f2v1elky5NRaIE7diBac1GqtLfCn(FWY4nIfAmmVXgvUQManITXgmYyZbbn28WFWYydHpNRQjJne(KlpLm2GvEHP8pxbe9gBiC9Im2u2ydKWH5I(dwgBMFNWel)Cfq0JzXhILc(S4Rp1)l4ADcwaPNcpbYIJzbwSSWel43Fw(5kGOhBzjgAtEcmloi4vOyrzwsjVWS87ucwmDAnlU2KNaZIkXs0qnAgcKLRaPiQaP6zb2ybRHVXwyUNMZn2iG76IIiq7v4WSExvtzG7YRFLMbjexGyPRJfc4UUOic0sPrjgY1z4awEfiw66yHaURlkIaTy4sRP)VcvEwQjmEJybCmmVXMh(dwgBPqyb0v5gCsn2OYv1eOrSnEJybGnmVXgvUQManITXMh(dwgBMg)3n20xr5aOXMYjBSbs4WCr)blJna4qbh)Saiwqog)3zXlqwCw2EFWRbfXcSyzZ8Sy6(DwI1HA)zjo4elEbYsSHXW8Sahw2EFA3qSa)DAmDyYylm3tZ5gB9yHc6lctw9Q8jxeYEw66yHc6lct2RYyO2hw66yHc6lct2RYQWFNLUowOG(IWK1Re5Iq2ZsFJ3iwaudZBSrLRQjqJyBSfM7P5CJTESqb9fHjREv(KlczplDDSqb9fHj7vzmu7dlDDSqb9fHj7vzv4VZsxhluqFryY6vICri7zPplkyjAiewLTMg)3zrblMXs0qiSaYAA8F3yZd)blJntJ)7gVrSaygM3yJkxvtGgX2ylm3tZ5gBMXYSkQbhuKv11EfOmSLDTo)7xHcBPYv1eilDDSyglbicQ86T1HA)ZnNyPRJfZybhrAD(9bf9yl(9P5AnlkXIYS01XIzS8UMQ3w(VgcNvDTxbYsLRQjqw66yPhluqFryYIHAFYfHSNLUowOG(IWK9QSEv(WsxhluqFryYEvwf(7S01Xcf0xeMSELixeYEw6BS5H)GLXg(9PDdz8gXs5KnmVXgvUQManITXwyUNMZn2Mvrn4GISQU2RaLHTSR15F)kuylvUQMazrblbicQ86T1HA)ZnNyrbl4isRZVpOOhBXVpnxRzrjwu2yZd)blJn87dEnOiJ34nEJne0GpyzelaLmGuozaCYahJnt(uxHcBSHCedacXYCJfY5aCwyX87elxAeCEwAWHf0bsnFPF0XYqa31neilyykXIVEyQ)eilHDVqrylNe6FfXI5aWzbPWcbnpbYY2LIuwWjQ3rglixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkJS(woj0)kIfZbGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velObGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velahaolifwiO5jqw2UuKYcor9oYyb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0dqiRVLtc9VIybadWzbPWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkJS(woj0)kIfamaNfKcle08eilO7NRaIERYwaa6y5HSGUFUci6TVYwaa6yPhGqwFlNe6FfXcagGZcsHfcAEcKf09ZvarVfqwaa6y5HSGUFUci6TpGSaa0XspaHS(woj0)kIfakaNfKcle08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6PmY6B5Kq)RiwayaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNYiRVLtc9VIyr5Kb4SGuyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLrwFlNe6FfXIYkdWzbPWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkJS(woj0)kIfLbeaNfKcle08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6biK13YjH(xrSOmGa4SGuyHGMNazbD)Cfq0Bv2caqhlpKf09ZvarV9v2caqhl9aeY6B5Kq)RiwugqaCwqkSqqZtGSGUFUci6TaYcaqhlpKf09ZvarV9bKfaGow6PmY6B5Kq)RiwuoUaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPhGqwFlNe6FfXIYXfGZcsHfcAEcKf09ZvarVvzlaaDS8qwq3pxbe92xzlaaDS0tzK13YjH(xrSOCCb4SGuyHGMNazbD)Cfq0BbKfaGowEilO7NRaIE7dilaaDS0dqiRVLtItc5igaeIL5glKZb4SWI53jwU0i48S0GdlOlAOamv1F0XYqa31neilyykXIVEyQ)eilHDVqrylNe6FfXsCb4SGuyHGMNazbD)Cfq0Bv2caqhlpKf09ZvarV9v2caqhl9aeY6B5Kq)RiwmhaolifwiO5jqwq3pxbe9wazbaOJLhYc6(5kGO3(aYcaqhl9aeY6B5Kq)RiwayaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNYiRVLtc9VIyr5Kb4SGuyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLrwFlNeNeYrmaielZnwiNdWzHfZVtSCPrW5zPbhwqNdj0XYqa31neilyykXIVEyQ)eilHDVqrylNe6FfXIYaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yXFwqpaYOpl9ugz9TCsO)velXfGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velahaolifwiO5jqw2UuKYcor9oYyb5ICz5HSG(lNLui4sVWSaJOXF4WspKBFw6PmY6B5Kq)RiwaoaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPhGqwFlNe6FfXcagGZcsHfcAEcKLTlfPSGtuVJmwqUixwEilO)YzjfcU0lmlWiA8hoS0d52NLEkJS(woj0)kIfamaNfKcle08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6PmY6B5Kq)RiwaOaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNYiRVLtc9VIybGbWzbPWcbnpbYY2LIuwWjQ3rglixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEacz9TCsO)velkdiaolifwiO5jqw2UuKYcor9oYyb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0tzK13YjH(xrSOmadGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velaszaolifwiO5jqw2UuKYcor9oYyb5YYdzb9xolGhIdFWIfyen(dhw6HK(S0tzK13YjH(xrSaO4cWzbPWcbnpbYY2LIuwWjQ3rglixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEacz9TCsO)velakUaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNYiRVLtc9VIybqObGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velac4aWzbPWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkJS(woj0)kIfabqb4SGuyHGMNazz7srkl4e17iJfKllpKf0F5SaEio8blwGr04pCyPhs6ZspaHS(woj0)kIfabWa4SGuyHGMNazz7srkl4e17iJfKllpKf0F5SaEio8blwGr04pCyPhs6ZspLrwFlNeNeYrmaielZnwiNdWzHfZVtSCPrW5zPbhwqxZ16FFwOJLHaURBiqwWWuIfF9Wu)jqwc7EHIWwoj0)kIfabWzbPWcbnpbYY2LIuwWjQ3rglixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkJS(wojojKJyaqiwMBSqohGZclMFNy5sJGZZsdoSGo8Jowgc4UUHazbdtjw81dt9NazjS7fkcB5Kq)RiwugGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velXfGZcsHfcAEcKf0nRIAWbfzbaOJLhYc6Mvrn4GISaalvUQMarhl9ugz9TCsO)velkRmaNfKcle08eilBxkszbNOEhzSGCrUS8qwq)LZskeCPxywGr04pCyPhYTpl9ugz9TCsO)velkRmaNfKcle08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6PmY6B5Kq)Riwug4aWzbPWcbnpbYc6Mvrn4GISaa0XYdzbDZQOgCqrwaGLkxvtGOJLEkJS(woj0)kIfaPmaNfKcle08eilBxkszbNOEhzSGCz5HSG(lNfWdXHpyXcmIg)Hdl9qsFw6biK13YjH(xrSaiLb4SGuyHGMNazbDZQOgCqrwaa6y5HSGUzvudoOilaWsLRQjq0XspLrwFlNe6FfXcGaeaNfKcle08eilOBwf1GdkYcaqhlpKf0nRIAWbfzbawQCvnbIow6PmY6B5Kq)RiwauCb4SGuyHGMNazz7srkl4e17iJfKllpKf0F5SaEio8blwGr04pCyPhs6ZsV4IS(woj0)kIfazoaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPhGqwFlNe6FfXcGaoaCwqkSqqZtGSGUzvudoOilaaDS8qwq3SkQbhuKfayPYv1ei6yPNYiRVLtc9VIybqayaolifwiO5jqwq3SkQbhuKfaGowEilOBwf1GdkYcaSu5QAceDS0tzK13YjXjHCedacXYCJfY5aCwyX87elxAeCEwAWHf0Pc9hDSmeWDDdbYcgMsS4RhM6pbYsy3lue2YjH(xrSOmafGZcsHfcAEcKLTlfPSGtuVJmwqUS8qwq)LZc4H4WhSybgrJ)WHLEiPpl9IlY6B5Kq)RiwugGbWzbPWcbnpbYY2LIuwWjQ3rglixwEilO)Yzb8qC4dwSaJOXF4WspK0NLEkJS(wojojZnncopbYcWHfp8hSyrF4hB5Km2WruWiwkNmGm2Igy70KXgYJ8SeBx7vGyjooRdKtc5rEwsAPtWcagTSaOKbKYCsCsipYZcs39cfHb4CsipYZcaILyacsGSSb1(WsSjp1YjH8iplaiwq6UxOiqwEFqrF(ASeCmHz5HSese0u(9bf9ylNeYJ8SaGybGaLcrqGSSQIceg7tcwq4Z5QAcZsVZsw0Ys0qiY43h8AqrSaGINLOHqyXVp41GI6B5KqEKNfaelXab8azjAOGJ)RqXcYX4)olxJL7rhMLFNyX0aluSGEb9fHjlNeYJ8SaGybGOdeXcsHfciqel)oXYw0n3JzXzrF)RjwsHdXstti7u1el9UgljGlw2DWcDpl73ZY9SGV0L(9IGlSoblMUFNLydqogMNfaZcsjnH)Z1Sed9HQsP6rll3JoqwWaDr9TCsipYZcaIfaIoqelPq8Zc6AhQ9ppuQFfgDSGdu5ZbXS4rr6eS8qwuHymlTd1(Jzbw6ewojojKh5zjgvbF)jqwITR9kqSedai6ZsWlwujwAWvbYI)SS)FegGJeKO6AVceacFPblQ73xQ2dIKy7AVceaA7srkssbT7FQg5STttkP6AVcK9r2ZjXj5H)Gf2gnuaMQ6VsaDf4qGzC0n3J5KqEwm)oXccFoxvtSCywW0ZYdzjzwmD)olfKf87plWILfMy5NRaIEmAzrzwmTtfl)oXs7g8ZcSiwomlWILfMqllaILRXYVtSGPaSaz5WS4filXLLRXIk83zXhItYd)blSnAOamv1FaResq4Z5QAcTLNskbR8ct5FUci6rlcxViLsMtYd)blSnAOamv1FaResq4Z5QAcTLNskbR8ct5FUci6rlmsjheeTiC9Iusz0EnL(5kGO3QSDHDvnP4NRaIERY2aeQbHMkl4A8)GfNKh(dwyB0qbyQQ)awjKGWNZv1eAlpLucw5fMY)Cfq0JwyKsoiiAr46fPeGq71u6NRaIElGSlSRQjf)Cfq0BbKnaHAqOPYcUg)pyXjH8Sy(DctS8ZvarpMfFiwk4ZIV(u)VGR1jybKEk8eiloMfyXYctSGF)z5NRaIESLLyOn5jWS4GGxHIfLzjL8cZYVtjyX0P1S4AtEcmlQelrd1OziqwUcKIOcKQNfyJfSg(CsE4pyHTrdfGPQ(dyLqccFoxvtOT8usjyLxyk)ZvarpAHrk5GGOfHRxKskJ2RPebCxxuebAVchM17QAkdCxE9R0miH4cuxhbCxxuebAP0Oed56mCalVcuxhbCxxuebAXWLwt)FfQ8SutWj5H)Gf2gnuaMQ6pGvcjPqyb0v5gCs5KqEwaGdfC8ZcGyb5y8FNfVazXzz79bVguelWILnZZIP73zjwhQ9NL4GtS4filXggdZZcCyz79PDdXc83PX0Hjojp8hSW2OHcWuv)bSsiX04)oA1xr5aOskNmAVMs9OG(IWKvVkFYfHSVRJc6lct2RYyO2NUokOVimzVkRc)9UokOVimz9krUiK995K8WFWcBJgkatv9hWkHetJ)7O9Ak1Jc6lctw9Q8jxeY(UokOVimzVkJHAF66OG(IWK9QSk8376OG(IWK1Re5Iq23xr0qiSkBnn(VRWSOHqybK104)oNKh(dwyB0qbyQQ)awjKGFFA3qO9Akz2SkQbhuKv11EfOmSLDTo)7xHc31zwaIGkVEBDO2)CZPUoZWrKwNFFqrp2IFFAUwRKYDDM9UMQ3w(VgcNvDTxbYsLRQjWUUEuqFryYIHAFYfHSVRJc6lct2RY6v5txhf0xeMSxLvH)Exhf0xeMSELixeY((CsE4pyHTrdfGPQ(dyLqc(9bVgueAVMsZQOgCqrwvx7vGYWw2168VFfkSIaebvE926qT)5MtkWrKwNFFqrp2IFFAUwRKYCsCsipYZc6HmkSEcKfcbnjy5VuILFNyXdpCy5WS4i8t7QAYYj5H)Gfwjmu7twL8uojKNLn6XSedi6XcSyjUaMft3VdxplGZ1Ew8cKft3VZY27JgoGS4filacWSa)DAmDyItYd)blmGvcji85CvnH2YtjLoC2HeAr46fPeoI0687dk6Xw87tZ164vwrpZExt1BXVpA4aAPYv1eyx37AQEl(jT2Nm4CT3sLRQjW(DD4isRZVpOOhBXVpnxRJhqCsiplB0JzjOjhbXIPDQyz79PDdXsWlw2VNfabywEFqrpMft7xyNLdZYqAcHxpln4WYVtSGEb9fHjwEilQelrd1Oziqw8cKft7xyNL2P10WYdzj44NtYd)blmGvcji85CvnH2YtjLoCoOjhbHweUErkHJiTo)(GIESf)(0UHIxzojKNL4etSeBAW0a0vOyX097SG0yGeZTcSahw82tdlifwiGarSCflingiXCRaNKh(dwyaResuPbtdqxHcTxtPEMfGiOYR3whQ9p3CQRZSaeQbHMkBawiGar5FNY4OBUhBxr9vOUAnBWZxfSdL6xHJxz0OqD1A2XrqfCHZTHQyMWouQFfgyMJcZcqeu51Brq1VNy66cqeu51Brq1VNyuOUAnBWZxfSRifQRwZoocQGlCUnufZe2vKIEQRwZoocQGlCUnufZe2Hs9RWatzLbqOb4Nvrn4GIS4RAlDEpb(P58Uo1vRzdE(QGDOu)kmWuw5UoLrU4isRZ7o(jGPSfnOPpNeYZcae(Sy6(DwCwqAmqI5wbw(D)z5Wf6EwCwaGln2hwIgyGf4WIPDQy53jwAhQ9NLdZIRcxplpKfQa5K8WFWcdyLqse8pyH2RPK6Q1SbpFvWouQFfoELrJIEMnRIAWbfzXx1w68Ec8tZ5DDQRwZoocQGlCUnufZe2Hs9RWatzaSc1vRzhhbvWfo3gQIzc7kQFxNkeJv0ou7FEOu)kmWaeA4KqEwqQRdlT)eMft70Vtdll8vOybPWcbeiILcAIftNwZIR1qtSKaUy5HSG)tRzj44NLFNyb7PelEkCvplWglifwiGaragPXajMBfyj44hZj5H)GfgWkHee(CUQMqB5PKsbyHaceLbjCIkGweUErkfOt3Rx7qT)5Hs9RWaiLrdakaHAqOPYg88vb7qP(v4(ixLbOj3xPaD6E9AhQ9ppuQFfgaPmAaqkdOKbqbiudcnv2aSqabIY)oLXr3Cp2ouQFfUpYvzaAY9vy24hyMqq1BDqqSLq2HFCxxac1GqtLn45Rc2Hs9RWXF1tteu7pbMBhQ9ppuQFfURlaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWXF1tteu7pbMBhQ9ppuQFfgaPCYDDMfGiOYR3whQ9p3CQRZd)blBawiGar5FNY4OBUhBbpSRQjqojKNL4etGS8qwajTNGLFNyzHDuelWglingiXCRalM2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyANkw8IfheKfcbvplhMfxfUEwEilGhXj5H)GfgWkHee(CUQMqB5PKsbWCawG3FWcTiC9IuQ37dk6T)Ls5hMbpkELrtx34hyMqq1BDqqS9Q4rtY9v0Rxpc4UUOic0sPrjgY1z4awEfif96fGqni0uzP0Oed56mCalVcKDOu)kmWug4KCxxaIGkVElcQ(9eJIaeQbHMklLgLyixNHdy5vGSdL6xHbMYahamG7PSYa)SkQbhuKfFvBPZ7jWpnN3VVcZcqOgeAQSuAuIHCDgoGLxbYoKdMOF)UUEeWDDrreOfdxAn9)vOYZsnHIEMfGiOYR3whQ9p3CQRlaHAqOPYIHlTM()ku5zPMihxZbna0Kv2ouQFfgykRS50VFxxpZiG76IIiq7v4WSExvtzG7YRFLMbjexG66cqOgeAQSxHdZ6DvnLbUlV(vAgKqCbYoKdMOVIEbiudcnvwvAW0a0vOSd5Gj66mB8az)bQ19v0RhcFoxvtwyLxyk)ZvarVsk31HWNZv1Kfw5fMY)Cfq0RuC7RO3pxbe9wLTd5GjYbiudcnvDD)Cfq0Bv2gGqni0uzhk1Vch)vpnrqT)eyUDO2)8qP(vyaKYj3VRdHpNRQjlSYlmL)5kGOxjaPO3pxbe9wazhYbtKdqOgeAQ66(5kGO3ciBac1GqtLDOu)kC8x90eb1(tG52HA)ZdL6xHbqkNC)Uoe(CUQMSWkVWu(NRaIELsUF)UUaebvE9wGsmNx95K8WFWcdyLqccFoxvtOT8usPFFoToJjciAYM87rlcxViLmddxA1RaT)(CADgteq0yPYv1eyxx7qT)5Hs9RWXdOKtURtfIXkAhQ9ppuQFfgyacnaUN5KmasD1A2FFoToJjciAS43dab8aQFxN6Q1S)(CADgteq0yXVhak(4cqbq9Mvrn4GIS4RAlDEpb(P5CGhn95KqEwItmXc6LgLyixZca5bS8kqSaOKXuaZIk1GdXIZcsJbsm3kWYctwojp8hSWawjKSWu(EkfTLNskrPrjgY1z4awEfi0EnLcqOgeAQSbpFvWouQFfgyakzfbiudcnv2aSqabIY)oLXr3Cp2ouQFfgyakzf9q4Z5QAY(7ZP1zmrart2KFFxN6Q1S)(CADgteq0yXVhak(4MmG7nRIAWbfzXx1w68Ec8tZ5apWPF)UovigRODO2)8qP(vyGfxamNeYZsCIjw2GlTM(RqXcaHLAcwaoykGzrLAWHyXzbPXajMBfyzHjlNKh(dwyaReswykFpLI2YtjLWWLwt)FfQ8SutG2RPuac1GqtLn45Rc2Hs9RWad4OWSaebvE9weu97jgfMfGiOYR3whQ9p3CQRlarqLxVTou7FU5KIaeQbHMkBawiGar5FNY4OBUhBhk1VcdmGJIEi85CvnzdWcbeikds4evORlaHAqOPYg88vb7qP(vyGbC631fGiOYR3IGQFpXOONzZQOgCqrw8vTLoVNa)0CUIaeQbHMkBWZxfSdL6xHbgWPRtD1A2XrqfCHZTHQyMWouQFfgykBoaUhAaEc4UUOic0Ef(Nv4HdodEiUIYQKw3xH6Q1SJJGk4cNBdvXmHDf1VRtfIXkAhQ9ppuQFfgyacnCsE4pyHbSsizHP89ukAlpLu6kCywVRQPmWD51VsZGeIlqO9AkPUAnBWZxfSdL6xHJxz0OONzZQOgCqrw8vTLoVNa)0CExN6Q1SJJGk4cNBdvXmHDOu)kmWugqaUxCbE1vRzv1qiOEHF7kQpG71dadGqdWRUAnRQgcb1l8Bxr9bEc4UUOic0Ef(Nv4HdodEiUIYQKw3xH6Q1SJJGk4cNBdvXmHDf1VRtfIXkAhQ9ppuQFfgyacnCsiplMF)WSCywCwg)3PHfs7QWXFIftEcwEilPoqelUwZcSyzHjwWV)S8ZvarpMLhYIkXI(kcKLvelMUFNfKgdKyUvGfVazbPWcbeiIfVazzHjw(DIfavGSG1WNfyXsaKLRXIk83z5NRaIEml(qSalwwyIf87pl)Cfq0J5K8WFWcdyLqYct57PumAXA4Jv6NRaIELr71ucHpNRQjlSYlmL)5kGOxjaPWSFUci6TaYoKdMihGqni0u111dHpNRQjlSYlmL)5kGOxjL76q4Z5QAYcR8ct5FUci6vkU9v0tD1A2GNVkyxrk6zwaIGkVElcQ(9etxN6Q1SJJGk4cNBdvXmHDOu)kmG7HgGFwf1GdkYIVQT059e4NMZ7dmL(5kGO3QSvD1AzW14)blfQRwZoocQGlCUnufZe2vuxN6Q1SJJGk4cNBdvXmrgFvBPZ7jWpnNBxr976cqOgeAQSbpFvWouQFfgWak(FUci6TkBdqOgeAQSGRX)dwk6zwaIGkVEBDO2)CZPUoZq4Z5QAYgGfciqugKWjQqFfMfGiOYR3cuI58QRlarqLxVTou7FU5Kce(CUQMSbyHaceLbjCIkOiaHAqOPYgGfciqu(3Pmo6M7X2vKcZcqOgeAQSbpFvWUIu0RN6Q1SuqFrykRxLp2Hs9RWXRCYDDQRwZsb9fHPmgQ9XouQFfoELtUVcZMvrn4GISQU2RaLHTSR15F)ku4UUEQRwZQ6AVcug2YUwN)9RqHZL)RHS43daPeA66uxTMv11EfOmSLDTo)7xHcN9j4fzXVhasjaA)(DDQRwZc0vGdbMP0iOjAsP6ZurdQlMKDf1VRtfIXkAhQ9ppuQFfgyak5Uoe(CUQMSWkVWu(NRaIELsMtYd)blmGvcjlmLVNsXOfRHpwPFUci6beAVMsi85CvnzHvEHP8pxbe9MPeGuy2pxbe9wLTd5GjYbiudcnvDDi85CvnzHvEHP8pxbe9kbif9uxTMn45Rc2vKIEMfGiOYR3IGQFpX01PUAn74iOcUW52qvmtyhk1Vcd4EOb4Nvrn4GIS4RAlDEpb(P58(atPFUci6TaYQUATm4A8)GLc1vRzhhbvWfo3gQIzc7kQRtD1A2XrqfCHZTHQyMiJVQT059e4NMZTRO(DDbiudcnv2GNVkyhk1Vcdyaf)pxbe9wazdqOgeAQSGRX)dwk6zwaIGkVEBDO2)CZPUoZq4Z5QAYgGfciqugKWjQqFfMfGiOYR3cuI58srpZuxTMn45Rc2vuxNzbicQ86TiO63tm976cqeu51BRd1(NBoPaHpNRQjBawiGarzqcNOckcqOgeAQSbyHaceL)DkJJU5ESDfPWSaeQbHMkBWZxfSRif96PUAnlf0xeMY6v5JDOu)kC8kNCxN6Q1SuqFrykJHAFSdL6xHJx5K7RWSzvudoOiRQR9kqzyl7AD(3VcfURRN6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqkHMUo1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGucG2VF)Uo1vRzb6kWHaZuAe0enPu9zQOb1ftYUI66uHySI2HA)ZdL6xHbgGsURdHpNRQjlSYlmL)5kGOxPK5KqEwItmHzX1AwG)onSalwwyIL7PumlWILaiNKh(dwyaReswykFpLI5KqEwIJu4ajw8WFWIf9HFwuDmbYcSybF)Y)dwirtOomNKh(dwyaResMvL9WFWkRp8J2YtjLCiHw8px4vsz0EnLq4Z5QAYE4Sdjojp8hSWawjKmRk7H)GvwF4hTLNskPc9hT4FUWRKYO9AknRIAWbfzvDTxbkdBzxRZ)(vOWwc4UUOicKtYd)blmGvcjZQYE4pyL1h(rB5PKs4NtItc5zbPUoS0(tywmTt)onS87elXXH80G)HDAyrD1ASy60AwAUwZcS1yX097xXYVtSueYEwco(5K8WFWcBDiPecFoxvtOT8usjWH80SPtRZnxRZWwdTiC9IuQN6Q1S)LsMGtLbhYtvVcKg7qP(vyGHkaAtDKb4KTk31PUAn7FPKj4uzWH8u1RaPXouQFfgyE4pyzXVpTBilHmkSEk)xkb4KTkROhf0xeMSxL1RYNUokOVimzXqTp5Iq231rb9fHjRxjYfHSVFFfQRwZ(xkzcovgCipv9kqASRifZQOgCqr2)sjtWPYGd5PQxbsdNeYZcsDDyP9NWSyAN(DAyz79bVguelhMftW53zj44)kuSarqdlBVpTBiwUIf0Fv(Wc6f0xeM4K8WFWcBDibyLqccFoxvtOT8usPdvbhkJFFWRbfHweUErkzgf0xeMSxLXqTpk6HJiTo)(GIESf)(0UHIhnkExt1BXWLodB5FNYn4q43sLRQjWUoCeP153hu0JT43N2nu8a4(CsiplXjMybPWcbeiIft7uXI)SOjmMLF3lwqtYSedmaKfVazrFfXYkIft3VZcsJbsm3kWj5H)Gf26qcWkHKaSqabIY)oLXr3CpgTxtjZaN1bAlyoaIv0RhcFoxvt2aSqabIYGeorfuywac1GqtLn45Rc2HCWeDDQRwZg88vb7kQVIEQRwZsb9fHPSEv(yhk1VchpWPRtD1AwkOVimLXqTp2Hs9RWXdC6RONzZQOgCqrwvx7vGYWw2168VFfkCxN6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqXh3Uo1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGIpU976uHySI2HA)ZdL6xHbMYjRWSaeQbHMkBWZxfSd5Gj6ZjH8SeNyIL4WqvmtWIP73zbPXajMBf4K8WFWcBDibyLqY4iOcUW52qvmtG2RPK6Q1SbpFvWouQFfoELrdNeYZsCIjw2wv7gILRyjYlqk9cSalw8kXVFfkw(D)zrFiimlkBoykGzXlqw0egZIP73zjfoelVpOOhZIxGS4pl)oXcvGSaBS4SSb1(Wc6f0xeMyXFwu2CybtbmlWHfnHXSmuQF1vOyXXS8qwk4ZYUJ4kuS8qwgQneENfW1Cfkwq)v5dlOxqFryItYd)blS1HeGvcj4v1UHqBirqt53hu0Jvsz0EnL6nuBi8URQPUo1vRzPG(IWugd1(yhk1VcdS4QGc6lct2RYyO2hfdL6xHbMYMJI31u9wmCPZWw(3PCdoe(Tu5QAcSVI3hu0B)lLYpmdEu8kBoaiCeP153hu0Jb8qP(vyf9OG(IWK9QSxj66gk1VcdmubqBQJS(CsipliNikILvelBVpnxRzXFwCTML)sjmlRstymll8vOyb9te8XXS4fil3ZYHzXvHRNLhYs0adSahw00ZYVtSGJOW5Aw8WFWIf9velQKgAILDVa1elXXH8u1RaPHfyXcGy59bf9yojp8hSWwhsawjKGFFAUwJ2RPKzVRP6T4N0AFYGZ1ElvUQMav0tD1Aw87tZ1A7qTHW7UQMu0dhrAD(9bf9yl(9P5AnWIBxNzZQOgCqr2)sjtWPYGd5PQxbst)UU31u9wmCPZWw(3PCdoe(Tu5QAcuH6Q1SuqFrykJHAFSdL6xHbwCvqb9fHj7vzmu7Jc1vRzXVpnxRTdL6xHbgawboI0687dk6Xw87tZ164vYC6RONzZQOgCqrwDIGpoo30e9xHkJsFPryQR7Vuc5ICnh0eV6Q1S43NMR12Hs9RWagq9v8(GIE7FPu(HzWJIhnCsiplih3VZY2tATpSehNR9SSWelWILailM2PILHAdH3DvnXI66zb)NwZIj)EwAWHf0prWhhZs0adS4filGWcDpllmXIk1GdXcsJJyllB)P1SSWelQudoelifwiGarSGVkqS87(ZIPtRzjAGbw8c(70WY27tZ1Aojp8hSWwhsawjKGFFAUwJ2RP07AQEl(jT2Nm4CT3sLRQjqfQRwZIFFAUwBhQneE3v1KIEMnRIAWbfz1jc(44Ctt0FfQmk9LgHPUU)sjKlY1Cqt8MtFfVpOO3(xkLFyg8O4JlNeYZcYX97SehhYtvVcKgwwyILT3NMR1S8qwaIOiwwrS87elQRwJf1eS4AmKLf(kuSS9(0CTMfyXcAybtbybIzboSOjmMLHs9RUcfNKh(dwyRdjaResWVpnxRr71uAwf1GdkY(xkzcovgCipv9kqAuGJiTo)(GIESf)(0CToELIRIEMPUAn7FPKj4uzWH8u1RaPXUIuOUAnl(9P5ATDO2q4DxvtDD9q4Z5QAYcoKNMnDADU5ADg2Ak6PUAnl(9P5ATDOu)kmWIBxhoI0687dk6Xw87tZ164bKI31u9w8tATpzW5AVLkxvtGkuxTMf)(0CT2ouQFfgyOPF)(Csipli11HL2FcZIPD63PHfNLT3h8AqrSSWelMoTMLGVWelBVpnxRz5HS0CTMfyRHww8cKLfMyz79bVguelpKfGikIL44qEQ6vG0Wc(9aqSSI4K8WFWcBDibyLqccFoxvtOT8usj87tZ16Sjy95MR1zyRHweUErk54FCDocAIM4bOjdG6PCYaV6Q1S)LsMGtLbhYtvVcKgl(9aq9bq9uxTMf)(0CT2ouQFfg4JlYfhrADE3Xpb8M9UMQ3IFsR9jdox7Tu5QAcSpaQxac1GqtLf)(0CT2ouQFfg4JlYfhrADE3Xpb8VRP6T4N0AFYGZ1ElvUQMa7dG6bcFBBnjYWwM0RISdL6xHbE00xrp1vRzXVpnxRTROUUaeQbHMkl(9P5ATDOu)kCFojKNL4etSS9(GxdkIft3VZsCCipv9kqAy5HSaerrSSIy53jwuxTglMUFhUEw0q8vOyz79P5AnlRO)sjw8cKLfMyz79bVguelWIfZbWSeBymmpl43daHzzv)PzXCy59bf9yojp8hSWwhsawjKGFFWRbfH2RPecFoxvtwWH80SPtRZnxRZWwtbcFoxvtw87tZ16Sjy95MR1zyRPWme(CUQMShQcoug)(GxdkQRRN6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqXh3Uo1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGIpU9vGJiTo)(GIESf)(0CTgyMJce(CUQMS43NMR1ztW6ZnxRZWwJtc5zjoXelyt(KYcgYYV7pljGlwqrplPoYyzf9xkXIAcww4RqXY9S4yw0(tS4ywIGy8PQjwGflAcJz539IL4Yc(9aqywGdlaKSWplM2PIL4cywWVhacZcHSOBiojp8hSWwhsawjK4GE0FiOm2KpPOnKiOP87dk6XkPmAVMsM9xaORqPWmp8hSSoOh9hckJn5tAg0tDuK9QCtFO2)Uoq4BDqp6peugBYN0mON6Oil(9aqalUkaHV1b9O)qqzSjFsZGEQJISdL6xHbwC5KqEwaiqTHW7SaqecR2nelxJfKgdKyUvGLdZYqoyc0YYVtdXIpelAcJz539If0WY7dk6XSCflO)Q8Hf0lOVimXIP73zzd(Xb0YIMWyw(DVyr5Kzb(70y6WelxXIxjyb9c6lctSahwwrS8qwqdlVpOOhZIk1GdXIZc6VkFyb9c6lctwwIJWcDpld1gcVZc4AUcfliNUcCiqwqV0iOjAsP6zzvAcJz5kw2GAFyb9c6lctCsE4pyHToKaSsijfcR2neAdjcAk)(GIESskJ2RP0qTHW7UQMu8(GIE7FPu(HzWJIVxpLnha3dhrAD(9bf9yl(9PDdb8ac4vxTMLc6lctz9Q8XUI63hWdL6xH7JC7PmGFxt1BFtxLtHWcBPYv1eyFf9cqOgeAQSbpFvWoKdMqHzGZ6aTfmhaXk6HWNZv1KnaleqGOmiHtuHUUaeQbHMkBawiGar5FNY4OBUhBhYbt01zwaIGkVEBDO2)CZP(DD4isRZVpOOhBXVpTBiG1RhWba1tD1AwkOVimL1RYh7kc4bu)(aFpLb87AQE7B6QCkewylvUQMa73xHzuqFryYIHAFYfHSVRRhf0xeMSxLXqTpDD9OG(IWK9QSk8376OG(IWK9QSEv(0xHzVRP6Ty4sNHT8Vt5gCi8BPYv1eyxN6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lkELaeAsUVIE4isRZVpOOhBXVpTBiGPCYaFpLb87AQE7B6QCkewylvUQMa73xHJ)X15iOjAIhnjdGuxTMf)(0CT2ouQFfg4bo9v0Zm1vRzb6kWHaZuAe0enPu9zQOb1ftYUI66OG(IWK9QmgQ9PRZSaebvE9wGsmNx9vyM6Q1SJJGk4cNBdvXmrgFvBPZ7jWpnNBxrCsiplXjMyjoaJflWILailMUFhUEwcEu0vO4K8WFWcBDibyLqsdobkdB5Y)1qO9Ak5r5WofaItYd)blS1HeGvcji85CvnH2YtjLcG5aSaV)Gv2HeAr46fPKzGZ6aTfmhaXkq4Z5QAYgaZbybE)blf96PUAnl(9P5ATDf119UMQ3IFsR9jdox7Tu5QAcSRlarqLxVTou7FU5uFf9mtD1AwmuJ)lq2vKcZuxTMn45Rc2vKIEM9UMQ32wtImSLj9QilvUQMa76uxTMn45RcwW14)bR4dqOgeAQST1KidBzsVkYouQFfgWa0(kq4Z5QAY(7ZP1zmrart2KFVIEMfGiOYR3whQ9p3CQRlaHAqOPYgGfciqu(3Pmo6M7X2vKIEQRwZIFFAUwBhk1Vcdma11z27AQEl(jT2Nm4CT3sLRQjW(9v8(GIE7FPu(HzWJIxD1A2GNVkybxJ)hSa(KTa4(DDTd1(Nhk1Vcdm1vRzdE(QGfCn(FWQpNeYZsCIjwqAmqI5wbwGflbqwwLMWyw8cKf9vel3ZYkIft3VZcsHfciqeNKh(dwyRdjaRescKMW)56SRpuvkvpAVMsi85CvnzdG5aSaV)Gv2HeNKh(dwyRdjaResUk4t5)bl0EnLq4Z5QAYgaZbybE)bRSdjojKNL4etSGEPrqt0WsSHfilWILailMUFNLT3NMR1SSIyXlqwWocILgCybaU0yFyXlqwqAmqI5wbojp8hSWwhsawjKqPrqt0KvHfiAVMsQqmwXvpnrqT)eyUDO2)8qP(vyGPmA666PUAnB0CPWb8CD2NGxxihT0yFSiC9IagGqtYDDQRwZgnxkCapxN9j41fYrln2hlcxVO4vcqOj5(kuxTMf)(0CT2UIu0laHAqOPYg88vb7qP(v44rtYDDGZ6aTfmhaX95KqEwaiqTHW7S00(qSalwwrS8qwIllVpOOhZIP73HRNfKgdKyUvGfv6kuS4QW1ZYdzHqw0nelEbYsbFwGiOj4rrxHItYd)blS1HeGvcj4N0AFYnTpeAdjcAk)(GIESskJ2RP0qTHW7UQMu8xkLFyg8O4vgnkWrKwNFFqrp2IFFA3qaZCu4r5Wofasrp1vRzdE(QGDOu)kC8kNCxNzQRwZg88vb7kQpNeYZsCIjwIdq0JLRXYv4dKyXlwqVG(IWelEbYI(kIL7zzfXIP73zXzbaU0yFyjAGbw8cKLya6r)HGyzZKpPCsE4pyHToKaSsiPTMezylt6vrO9Akrb9fHj7vzVsOWJYHDkaKc1vRzJMlfoGNRZ(e86c5OLg7JfHRxeWaeAswrpq4BDqp6peugBYN0mON6Oi7FbGUcvxNzbicQ86TffgOgoGDD4isRZVpOOhhpG6RON6Q1SJJGk4cNBdvXmHDOu)kmWayaOEOb4Nvrn4GIS4RAlDEpb(P58(kuxTMDCeubx4CBOkMjSROUoZuxTMDCeubx4CBOkMjSRO(k6zwac1GqtLn45Rc2vuxN6Q1S)(CADgteq0yXVhacykJgfTd1(Nhk1VcdmaLCYkAhQ9ppuQFfoELto5UoZWWLw9kq7VpNwNXebenwQCvnb2xrpmCPvVc0(7ZP1zmrarJLkxvtGDDbiudcnv2GNVkyhk1VchFCtUpNeYZsCIjwCw2EFAUwZca5I(DwIgyGLvPjmMLT3NMR1SCywC9qoycwwrSahwsaxS4dXIRcxplpKficAcEelXada5K8WFWcBDibyLqc(9P5AnAVMsQRwZcl63X5iAcu0FWYUIu0tD1Aw87tZ1A7qTHW7UQM66C8pUohbnrt8aSK7ZjH8SehxPrSedmaKfvQbhIfKcleqGiwmD)olBVpnxRzXlqw(DQyz79bVgueNKh(dwyRdjaResWVpnxRr71ukarqLxVTou7FU5KcZExt1BXpP1(KbNR9wQCvnbQOhcFoxvt2aSqabIYGeorf66cqOgeAQSbpFvWUI66uxTMn45Rc2vuFfbiudcnv2aSqabIY)oLXr3Cp2ouQFfgyOcG2uhzaFGoDph)JRZrqt0GCrtY9vOUAnl(9P5ATDOu)kmWmhfMboRd0wWCaeZj5H)Gf26qcWkHe87dEnOi0EnLcqeu51BRd1(NBoPOhcFoxvt2aSqabIYGeorf66cqOgeAQSbpFvWUI66uxTMn45Rc2vuFfbiudcnv2aSqabIY)oLXr3Cp2ouQFfgyahfQRwZIFFAUwBxrkOG(IWK9QSxjuygcFoxvt2dvbhkJFFWRbfPWmWzDG2cMdGyojKNL4etSS9(GxdkIft3VZIxSaqUOFNLObgyboSCnwsaxOdKficAcEelXadazX097SKaUgwkczplbh)wwIHgdzbCLgXsmWaqw8NLFNyHkqwGnw(DIfasP63tmSOUAnwUglBVpnxRzXeCPbl09S0CTMfyRXcCyjbCXIpelWIfaXY7dk6XCsE4pyHToKaSsib)(GxdkcTxtj1vRzHf974Cqt(KrC4dw2vuxxpZWVpTBiRhLd7uaifMHWNZv1K9qvWHY43h8AqrDD9uxTMn45Rc2Hs9RWadnkuxTMn45Rc2vuxxVEQRwZg88vb7qP(vyGHkaAtDKb8b609C8pUohbnrdYnUj3xH6Q1SbpFvWUI66uxTMDCeubx4CBOkMjY4RAlDEpb(P5C7qP(vyGHkaAtDKb8b609C8pUohbnrdYnUj3xH6Q1SJJGk4cNBdvXmrgFvBPZ7jWpnNBxr9veGiOYR3IGQFpX0VVIE4isRZVpOOhBXVpnxRbwC76q4Z5QAYIFFAUwNnbRp3CTodBT(9vygcFoxvt2dvbhkJFFWRbfPONzZQOgCqr2)sjtWPYGd5PQxbstxhoI0687dk6Xw87tZ1AGf3(CsiplXjMybGiewywUILnO2hwqVG(IWelEbYc2rqSehwAnlaeHWILgCybPXajMBf4K8WFWcBDibyLqsrMYPqyH2RPup1vRzPG(IWugd1(yhk1VchpHmkSEk)xk111lS7dkcReGumuy3huu(VucyOPFxxy3huewP42xHhLd7uaiojp8hSWwhsawjKS76wofcl0EnL6PUAnlf0xeMYyO2h7qP(v44jKrH1t5)sPUUEHDFqryLaKIHc7(GIY)Lsadn976c7(GIWkf3(k8OCyNcaPON6Q1SJJGk4cNBdvXmHDOu)kmWqJc1vRzhhbvWfo3gQIzc7ksHzZQOgCqrw8vTLoVNa)0CExNzQRwZoocQGlCUnufZe2vuFojp8hSWwhsawjK0wADofcl0EnL6PUAnlf0xeMYyO2h7qP(v44jKrH1t5)sjf9cqOgeAQSbpFvWouQFfoE0KCxxac1GqtLnaleqGO8VtzC0n3JTdL6xHJhnj3VRRxy3huewjaPyOWUpOO8FPeWqt)UUWUpOiSsXTVcpkh2Paqk6PUAn74iOcUW52qvmtyhk1Vcdm0OqD1A2XrqfCHZTHQyMWUIuy2SkQbhuKfFvBPZ7jWpnN31zM6Q1SJJGk4cNBdvXmHDf1Ntc5zjoXelihq0JfyXcsJJCsE4pyHToKaSsiXKpZbNmSLj9QiojKNfK66Ws7pHzX0o970WYdzzHjw2EFA3qSCflBqTpSyA)c7SCyw8Nf0WY7dk6XawzwAWHfcbnjybqjJCzj1XpnjyboSyoSS9(GxdkIf0lncAIMuQEwWVhacZj5H)Gf26qcWkHee(CUQMqB5PKs43N2nu(QmgQ9bTiC9IuchrAD(9bf9yl(9PDdfV5a4MgcNEPo(PjrgHRxeWRCYjJCbuY9bCtdHtp1vRzXVp41GIYuAe0enPu9zmu7Jf)EaiKR50Ntc5zbPUoS0(tywmTt)onS8qwqog)3zbCnxHIL4WqvmtWj5H)Gf26qcWkHee(CUQMqB5PKsMg)3ZxLBdvXmbAr46fPKYixCeP15Dh)eWaeaQxYwab89WrKwNFFqrp2IFFA3qaiL7d89ugWVRP6Ty4sNHT8Vt5gCi8BPYv1eiWRSfn97d4KTkJgGxD1A2XrqfCHZTHQyMWouQFfMtc5zjoXelihJ)7SCflBqTpSGEb9fHjwGdlxJLcYY27t7gIftNwZs7EwU6HSG0yGeZTcS4vIu4qCsE4pyHToKaSsiX04)oAVMs9OG(IWKvVkFYfHSVRJc6lctwVsKlczVce(CUQMShoh0KJG6RO37dk6T)Ls5hMbpkEZPRJc6lctw9Q8jFvgqDDTd1(Nhk1VcdmLtUFxN6Q1SuqFrykJHAFSdL6xHbMh(dww87t7gYsiJcRNY)LskuxTMLc6lctzmu7JDf11rb9fHj7vzmu7JcZq4Z5QAYIFFA3q5RYyO2NUo1vRzdE(QGDOu)kmW8WFWYIFFA3qwczuy9u(VusHzi85CvnzpCoOjhbPqD1A2GNVkyhk1Vcdmczuy9u(VusH6Q1SbpFvWUI66uxTMDCeubx4CBOkMjSRifi85Cvnznn(VNVk3gQIzIUoZq4Z5QAYE4CqtocsH6Q1SbpFvWouQFfoEczuy9u(VuItc5zjoXelBVpTBiwUglxXc6VkFyb9c6lctOLLRyzdQ9Hf0lOVimXcSyXCamlVpOOhZcCy5HSenWalBqTpSGEb9fHjojp8hSWwhsawjKGFFA3qCsiplXbxR)9zXj5H)Gf26qcWkHKzvzp8hSY6d)OT8usPMR1)(S4K4KqEwIddvXmblMUFNfKgdKyUvGtYd)blSvf6VsJJGk4cNBdvXmbAVMsQRwZg88vb7qP(v44vgnCsiplXjMyjgGE0Fiiw2m5tklM2PIf)zrtyml)UxSyoSeBymmpl43daHzXlqwEild1gcVZIZcWucqSGFpaeloMfT)eloMLiigFQAIf4WYFPel3ZcgYY9S4ZCiimlaKSWplE7PHfNL4cywWVhaIfczr3qyojp8hSWwvO)awjK4GE0FiOm2KpPOnKiOP87dk6XkPmAVMsQRwZQ6AVcug2YUwN)9RqHZL)RHS43dabmaQc1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGagavrpZaHV1b9O)qqzSjFsZGEQJIS)fa6kukmZd)blRd6r)HGYyt(KMb9uhfzVk30hQ9xrpZaHV1b9O)qqzSjFsZ7KRT)fa6kuDDGW36GE0FiOm2KpP5DY12Hs9RWXh3(DDGW36GE0FiOm2KpPzqp1rrw87bGawCvacFRd6r)HGYyt(KMb9uhfzhk1Vcdm0Oae(wh0J(dbLXM8jnd6PokY(xaORq1Ntc5zjoXelifwiGarSy6(DwqAmqI5wbwmTtflrqm(u1elEbYc83PX0HjwmD)ololXggdZZI6Q1yX0ovSas4ev4kuCsE4pyHTQq)bSsijaleqGO8VtzC0n3Jr71uYmWzDG2cMdGyf96HWNZv1KnaleqGOmiHtubfMfGqni0uzdE(QGDihmrxN6Q1SbpFvWUI6RON6Q1SQU2RaLHTSR15F)ku4C5)Ail(9aqkbq76uxTMv11EfOmSLDTo)7xHcN9j4fzXVhasjaA)UovigRODO2)8qP(vyGPCY95KqEwIdq0JfhZYVtS0Ub)SGkaYYvS87elolXggdZZIPRaHMyboSy6(Dw(DIfKtjMZlwuxTglWHft3VZIZcafWykWsma9O)qqSSzYNuw8cKft(9S0GdlingiXCRalxJL7zXeSEwujwwrS4O8RyrLAWHy53jwcGSCywAxD4DcKtYd)blSvf6pGvcjT1KidBzsVkcTxtPE96PUAnRQR9kqzyl7AD(3Vcfox(VgYIFpau8aNUo1vRzvDTxbkdBzxRZ)(vOWzFcErw87bGIh40xrpZcqeu51Brq1VNy66mtD1A2XrqfCHZTHQyMWUI63xrpWzDG2cMdG4UUaeQbHMkBWZxfSdL6xHJhnj311larqLxVTou7FU5KIaeQbHMkBawiGar5FNY4OBUhBhk1VchpAsUF)(DD9aHV1b9O)qqzSjFsZGEQJISdL6xHJhGQiaHAqOPYg88vb7qP(v44vozfbicQ86TffgOgoG976uHySIREAIGA)jWC7qT)5Hs9RWadGQWSaeQbHMkBWZxfSd5Gj66cqeu51BbkXCEPqD1AwGUcCiWmLgbnrtkvVDf11fGiOYR3IGQFpXOqD1A2XrqfCHZTHQyMWouQFfgyamfQRwZoocQGlCUnufZe2veNeYZcs9kqAw2EF0WbKft3VZIZsrMyj2WyyEwuxTglEbYcsJbsm3kWYHl09S4QW1ZYdzrLyzHjqojp8hSWwvO)awjKe8kq6S6Q1qB5PKs43hnCar71uQN6Q1SQU2RaLHTSR15F)ku4C5)Ai7qP(v44bWw001PUAnRQR9kqzyl7AD(3Vcfo7tWlYouQFfoEaSfn9v0laHAqOPYg88vb7qP(v44bWDD9cqOgeAQSuAe0enzvybAhk1VchpawHzQRwZc0vGdbMP0iOjAsP6ZurdQlMKDfPiarqLxVfOeZ5v)(kC8pUohbnrt8kf3K5KqEwIJR0iw2EFWRbfHzX097S4SeBymmplQRwJf11ZsbFwmTtflrqO(kuS0GdlingiXCRalWHfKtxboeilBr3CpMtYd)blSvf6pGvcj43h8AqrO9Ak1tD1Awvx7vGYWw2168VFfkCU8FnKf)EaO4buxN6Q1SQU2RaLHTSR15F)ku4SpbVil(9aqXdO(k6fGiOYR3whQ9p3CQRlaHAqOPYg88vb7qP(v44bWDDMHWNZv1KnaMdWc8(dwkmlarqLxVfOeZ5vxxVaeQbHMklLgbnrtwfwG2Hs9RWXdGvyM6Q1SaDf4qGzkncAIMuQ(mv0G6Ijzxrkcqeu51BbkXCE1VVIEMbcFBBnjYWwM0RIS)fa6kuDDMfGqni0uzdE(QGDihmrxNzbiudcnv2aSqabIY)oLXr3Cp2oKdMOpNeYZsCCLgXY27dEnOimlQudoelifwiGarCsE4pyHTQq)bSsib)(GxdkcTxtPEbiudcnv2aSqabIY)oLXr3Cp2ouQFfgyOrHzGZ6aTfmhaXk6HWNZv1KnaleqGOmiHtuHUUaeQbHMkBWZxfSdL6xHbgA6RaHpNRQjBamhGf49hS6RWmq4BBRjrg2YKEvK9VaqxHsraIGkVEBDO2)CZjfMboRd0wWCaeRGc6lct2RYELqHJ)X15iOjAI3CsMtc5zjocl09SacFwaxZvOy53jwOcKfyJfacocQGlmlXHHQyMaTSaUMRqXcqxboeiluAe0enPu9SahwUILFNyr74NfubqwGnw8If0lOVimXj5H)Gf2Qc9hWkHee(CUQMqB5PKsGWppeWDDdLs1JrlcxViL6PUAn74iOcUW52qvmtyhk1VchpA66mtD1A2XrqfCHZTHQyMWUI6RON6Q1SaDf4qGzkncAIMuQ(mv0G6Ijzhk1VcdmubqBQJS(k6PUAnlf0xeMYyO2h7qP(v44rfaTPoY66uxTMLc6lctz9Q8XouQFfoEubqBQJS(CsE4pyHTQq)bSsibVQ2neAdjcAk)(GIESskJ2RP0qTHW7UQMu8(GIE7FPu(HzWJIxzGJcpkh2Paqkq4Z5QAYcc)8qa31nukvpMtYd)blSvf6pGvcjPqy1UHqBirqt53hu0Jvsz0EnLgQneE3v1KI3hu0B)lLYpmdEu8khxlAu4r5WofasbcFoxvtwq4Nhc4UUHsP6XCsE4pyHTQq)bSsib)Kw7tUP9HqBirqt53hu0Jvsz0EnLgQneE3v1KI3hu0B)lLYpmdEu8kdCa8qP(vyfEuoStbGuGWNZv1Kfe(5HaURBOuQEmNeYZsCaglwGflbqwmD)oC9Se8OORqXj5H)Gf2Qc9hWkHKgCcug2YL)RHq71uYJYHDkaeNeYZc6LgbnrdlXgwGSyANkwCv46z5HSq1tdlolfzILydJH5zX0vGqtS4filyhbXsdoSG0yGeZTcCsE4pyHTQq)bSsiHsJGMOjRclq0EnL6rb9fHjREv(KlczFxhf0xeMSyO2NCri776OG(IWK1Re5Iq231PUAnRQR9kqzyl7AD(3Vcfox(VgYouQFfoEaSfnDDQRwZQ6AVcug2YUwN)9RqHZ(e8ISdL6xHJhaBrtxNJ)X15iOjAIhGLSIaeQbHMkBWZxfSd5Gjuyg4SoqBbZbqCFf9cqOgeAQSbpFvWouQFfo(4MCxxac1GqtLn45Rc2HCWe976uHySIREAIGA)jWC7qT)5Hs9RWat5K5KqEwIdq0JL5qT)SOsn4qSSWxHIfKgdojp8hSWwvO)awjK0wtImSLj9Qi0EnLcqOgeAQSbpFvWoKdMqbcFoxvt2ayoalW7pyPONJ)X15iOjAIhGLScZcqeu51BRd1(NBo11fGiOYR3whQ9p3CsHJ)X15iOjAaM5KCFfMfGiOYR3IGQFpXOONzbicQ86T1HA)ZnN66cqOgeAQSbyHaceL)DkJJU5ESDihmrFfMboRd0wWCaeZjH8SG0yGeZTcSyANkw8NfawYaMLyGbGS0doAOjAy539IfZjzwIbgaYIP73zbPWcbeiQplMUFhUEw0q8vOy5VuILRyj2AieuVWplEbYI(kILvelMUFNfKcleqGiwUgl3ZIjhZciHtubcKtYd)blSvf6pGvcji85CvnH2YtjLcG5aSaV)Gvwf6pAr46fPKzGZ6aTfmhaXkq4Z5QAYgaZbybE)blf9654FCDocAIM4byjRON6Q1SaDf4qGzkncAIMuQ(mv0G6IjzxrDDMfGiOYR3cuI58QFxN6Q1SQAieuVWVDfPqD1AwvnecQx43ouQFfgyQRwZg88vbl4A8)Gv)UUREAIGA)jWC7qT)5Hs9RWatD1A2GNVkybxJ)hS66cqeu51BRd1(NBo1xrpZcqeu51BRd1(NBo111ZX)46Ce0enaZCsURde(22AsKHTmPxfz)la0vO6ROhcFoxvt2aSqabIYGeorf66cqOgeAQSbyHaceL)DkJJU5ESDihmr)(CsE4pyHTQq)bSsijqAc)NRZU(qvPu9O9AkHWNZv1KnaMdWc8(dwzvO)CsE4pyHTQq)bSsi5QGpL)hSq71ucHpNRQjBamhGf49hSYQq)5KqEwqp8FP(tyw2HMyjDf2zjgyail(qSGYVIazjIgwWuawGCsE4pyHTQq)bSsibHpNRQj0wEkPKJJaG0Srb0IW1lsjkOVimzVkRxLpapaf56H)GLf)(0UHSeYOW6P8FPeGnJc6lct2RY6v5dW3d4a431u9wmCPZWw(3PCdoe(Tu5QAce4JBFKRh(dwwtJ)7wczuy9u(VucWjBbeYfhrADE3XpXjH8SehxPrSS9(GxdkcZIPDQy53jwAhQ9NLdZIRcxplpKfQarllTHQyMGLdZIRcxplpKfQarlljGlw8HyXFwayjdywIbgaYYvS4flOxqFrycTSG0yGeZTcSOD8JzXl4VtdlauaJPaMf4Wsc4IftWLgKficAcEelPWHy539IfUt5KzjgyailM2PILeWflMGlnyHUNLT3h8AqrSuqtCsE4pyHTQq)bSsib)(GxdkcTxtPEQqmwXvpnrqT)eyUDO2)8qP(vyGzoDD9uxTMDCeubx4CBOkMjSdL6xHbgQaOn1rgWhOt3ZX)46Ce0eni34MCFfQRwZoocQGlCUnufZe2vu)(DD9C8pUohbnrdGr4Z5QAY64iainBua4vxTMLc6lctzmu7JDOu)kmGbHVTTMezylt6vr2)caHZdL6xb8aYIM4vw5K76C8pUohbnrdGr4Z5QAY64iainBua4vxTMLc6lctz9Q8XouQFfgWGW32wtImSLj9Qi7FbGW5Hs9RaEazrt8kRCY9vqb9fHj7vzVsOONzQRwZg88vb7kQRZS31u9w87JgoGwQCvnb2xrVEMfGqni0uzdE(QGDf11fGiOYR3cuI58sHzbiudcnvwkncAIMSkSaTRO(DDbicQ86T1HA)ZnN6RONzbicQ86TiO63tmDDMPUAnBWZxfSROUoh)JRZrqt0epal5(DD9Ext1BXVpA4aAPYv1eOc1vRzdE(QGDfPON6Q1S43hnCaT43dabS42154FCDocAIM4byj3VFxN6Q1SbpFvWUIuyM6Q1SJJGk4cNBdvXmHDfPWS31u9w87JgoGwQCvnbYjH8SeNyIfaIqyHz5kwq)v5dlOxqFryIfVazb7iiwqoJRBaooS0AwaicHfln4WcsJbsm3kWj5H)Gf2Qc9hWkHKImLtHWcTxtPEQRwZsb9fHPSEv(yhk1VchpHmkSEk)xk111lS7dkcReGumuy3huu(VucyOPFxxy3huewP42xHhLd7uaiojp8hSWwvO)awjKS76wofcl0EnL6PUAnlf0xeMY6v5JDOu)kC8eYOW6P8FPKIEbiudcnv2GNVkyhk1VchpAsURlaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWXJMK7311lS7dkcReGumuy3huu(VucyOPFxxy3huewP42xHhLd7uaiojp8hSWwvO)awjK0wADofcl0EnL6PUAnlf0xeMY6v5JDOu)kC8eYOW6P8FPKIEbiudcnv2GNVkyhk1VchpAsURlaHAqOPYgGfciqu(3Pmo6M7X2Hs9RWXJMK7311lS7dkcReGumuy3huu(VucyOPFxxy3huewP42xHhLd7uaiojKNfKdi6XcSyjaYj5H)Gf2Qc9hWkHet(mhCYWwM0RI4KqEwItmXY27t7gILhYs0adSSb1(Wc6f0xeMyboSyANkwUIfyPtWc6VkFyb9c6lctS4fillmXcYbe9yjAGbmlxJLRyb9xLpSGEb9fHjojp8hSWwvO)awjKGFFA3qO9Akrb9fHj7vz9Q8PRJc6lctwmu7tUiK9DDuqFryY6vICri776uxTM1KpZbNmSLj9Qi7ksH6Q1SuqFrykRxLp2vuxxp1vRzdE(QGDOu)kmW8WFWYAA8F3siJcRNY)LskuxTMn45Rc2vuFojp8hSWwvO)awjKyA8FNtYd)blSvf6pGvcjZQYE4pyL1h(rB5PKsnxR)9zXjXjH8SS9(GxdkILgCyjfIGsP6zzvAcJzzHVcflXggdZZj5H)Gf22CT(3NLs43h8AqrO9Akz2SkQbhuKv11EfOmSLDTo)7xHcBjG76IIiqojKNfK64NLFNybe(Sy6(Dw(DILui(z5VuILhYIdcYYQ(tZYVtSK6iJfW14)blwoml73BzzBvTBiwgk1VcZs6s)xK(iqwEilP(h2zjfcR2nelGRX)dwCsE4pyHTnxR)9zbyLqcEvTBi0gse0u(9bf9yLugTxtjq4BtHWQDdzhk1Vch)qP(vyGhqac5QmaLtYd)blST5A9VplaRessHWQDdXjXjH8SeNyILT3h8AqrS8qwaIOiwwrS87elXXH8u1RaPHf1vRXY1y5EwmbxAqwiKfDdXIk1GdXs7QdVFfkw(DILIq2ZsWXplWHLhYc4knIfvQbhIfKcleqGiojp8hSWw8Re(9bVgueAVMsZQOgCqr2)sjtWPYGd5PQxbsJIEuqFryYEv2RekmRxp1vRz)lLmbNkdoKNQEfin2Hs9RWX7H)GL104)ULqgfwpL)lLaCYwLv0Jc6lct2RYQWFVRJc6lct2RYyO2NUokOVimz1RYNCri7731PUAn7FPKj4uzWH8u1RaPXouQFfoEp8hSS43N2nKLqgfwpL)lLaCYwLv0Jc6lct2RY6v5txhf0xeMSyO2NCri776OG(IWK1Re5Iq23VFxNzQRwZ(xkzcovgCipv9kqASRO(DD9uxTMn45Rc2vuxhcFoxvt2aSqabIYGeorf6RiaHAqOPYgGfciqu(3Pmo6M7X2HCWekcqeu51BRd1(NBo1xrpZcqeu51BbkXCE11fGqni0uzP0iOjAYQWc0ouQFfoEaAFf9uxTMn45Rc2vuxNzbiudcnv2GNVkyhYbt0Ntc5zjoXelXa0J(dbXYMjFszX0ovS870qSCywkilE4peelyt(KIwwCmlA)jwCmlrqm(u1elWIfSjFszX097SaiwGdlnYenSGFpaeMf4WcSyXzjUaMfSjFszbdz539NLFNyPitSGn5tkl(mhccZcajl8ZI3EAy539NfSjFszHqw0neMtYd)blSf)awjK4GE0FiOm2KpPOnKiOP87dk6XkPmAVMsMbcFRd6r)HGYyt(KMb9uhfz)la0vOuyMh(dwwh0J(dbLXM8jnd6PokYEvUPpu7VIEMbcFRd6r)HGYyt(KM3jxB)la0vO66aHV1b9O)qqzSjFsZ7KRTdL6xHJhn976aHV1b9O)qqzSjFsZGEQJIS43dabS4Qae(wh0J(dbLXM8jnd6PokYouQFfgyXvbi8ToOh9hckJn5tAg0tDuK9VaqxHItc5zjoXeMfKcleqGiwUglingiXCRalhMLvelWHLeWfl(qSas4ev4kuSG0yGeZTcSy6(DwqkSqabIyXlqwsaxS4dXIkPHMyXCsMLyGbGCsE4pyHT4hWkHKaSqabIY)oLXr3CpgTxtjZaN1bAlyoaIv0RhcFoxvt2aSqabIYGeorfuywac1GqtLn45Rc2HCWekmBwf1GdkYgnxkCapxN9j41fYrln2NUo1vRzdE(QGDf1xHJ)X15iOjAaMsMtYk6PUAnlf0xeMY6v5JDOu)kC8kNCxN6Q1SuqFrykJHAFSdL6xHJx5K731PcXyfTd1(Nhk1VcdmLtwHzbiudcnv2GNVkyhYbt0Ntc5zbPWc8(dwS0GdlUwZci8XS87(ZsQdeHzbVgILFNsWIpuHUNLHAdH3jqwmTtflaeCeubxywIddvXmbl7oMfnHXS87EXcAybtbmldL6xDfkwGdl)oXcqjMZlwuxTglhMfxfUEwEilnxRzb2ASahw8kblOxqFryILdZIRcxplpKfczr3qCsE4pyHT4hWkHee(CUQMqB5PKsGWppeWDDdLs1JrlcxViL6PUAn74iOcUW52qvmtyhk1VchpA66mtD1A2XrqfCHZTHQyMWUI6RWm1vRzhhbvWfo3gQIzIm(Q2sN3tGFAo3UIu0tD1AwGUcCiWmLgbnrtkvFMkAqDXKSdL6xHbgQaOn1rwFf9uxTMLc6lctzmu7JDOu)kC8OcG2uhzDDQRwZsb9fHPSEv(yhk1VchpQaOn1rwxxpZuxTMLc6lctz9Q8XUI66mtD1AwkOVimLXqTp2vuFfM9UMQ3IHA8FbYsLRQjW(CsiplifwG3FWILF3Fwc7uaimlxJLeWfl(qSaxp(ajwOG(IWelpKfyPtWci8z53PHyboSCOk4qS87hMft3VZYguJ)lqCsE4pyHT4hWkHee(CUQMqB5PKsGWpdxp(aPmf0xeMqlcxViL6zM6Q1SuqFrykJHAFSRifMPUAnlf0xeMY6v5JDf1VR7DnvVfd14)cKLkxvtGCsE4pyHT4hWkHKuiSA3qOnKiOP87dk6XkPmAVMsd1gcV7QAsrp1vRzPG(IWugd1(yhk1Vch)qP(v4Uo1vRzPG(IWuwVkFSdL6xHJFOu)kCxhcFoxvtwq4NHRhFGuMc6lct9vmuBi8URQjfVpOO3(xkLFyg8O4vgqk8OCyNcaPaHpNRQjli8ZdbCx3qPu9yojp8hSWw8dyLqcEvTBi0gse0u(9bf9yLugTxtPHAdH3DvnPON6Q1SuqFrykJHAFSdL6xHJFOu)kCxN6Q1SuqFrykRxLp2Hs9RWXpuQFfURdHpNRQjli8ZW1Jpqktb9fHP(kgQneE3v1KI3hu0B)lLYpmdEu8kdifEuoStbGuGWNZv1Kfe(5HaURBOuQEmNKh(dwyl(bSsib)Kw7tUP9HqBirqt53hu0Jvsz0EnLgQneE3v1KIEQRwZsb9fHPmgQ9XouQFfo(Hs9RWDDQRwZsb9fHPSEv(yhk1Vch)qP(v4Uoe(CUQMSGWpdxp(aPmf0xeM6RyO2q4DxvtkEFqrV9Vuk)Wm4rXRmWrHhLd7uaifi85CvnzbHFEiG76gkLQhZjH8SeNyIL4amwSalwcGSy6(D46zj4rrxHItYd)blSf)awjK0GtGYWwU8FneAVMsEuoStbG4KqEwItmXcYPRahcKLTOBUhZIP73zXReSOHfkwOcUqTZI2X)vOyb9c6lctS4fil)KGLhYI(kIL7zzfXIP73zbaU0yFyXlqwqAmqI5wbojp8hSWw8dyLqcLgbnrtwfwGO9Ak1RN6Q1SuqFrykJHAFSdL6xHJx5K76uxTMLc6lctz9Q8XouQFfoELtUVIaeQbHMkBWZxfSdL6xHJpUjRON6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lcyaYCsURZSzvudoOiB0CPWb8CD2NGxxihT0yFSeWDDrrey)(DDQRwZgnxkCapxN9j41fYrln2hlcxVO4vcqa4K76cqOgeAQSbpFvWoKdMqHJ)X15iOjAIhGLmNeYZsCIjwqAmqI5wbwmD)olifwiGarib50vGdbYYw0n3JzXlqwaHf6EwGiOX0CpXcaCPX(WcCyX0ovSeBnecQx4NftWLgKfczr3qSOsn4qSG0yGeZTcSqil6gcZj5H)Gf2IFaResq4Z5QAcTLNskfaZbybE)bRm(rlcxViLmdCwhOTG5aiwbcFoxvt2ayoalW7pyPOxVaeQbHMklLgLyixNHdy5vGSdL6xHbMYahamG7PSYa)SkQbhuKfFvBPZ7jWpnN3xbbCxxuebAP0Oed56mCalVcu)Uoh)JRZrqt0eVsaSKv0ZS31u922AsKHTmPxfzPYv1eyxN6Q1SbpFvWcUg)pyfFac1GqtLTTMezylt6vr2Hs9RWagG2xbcFoxvt2FFoToJjciAYM87v0tD1AwGUcCiWmLgbnrtkvFMkAqDXKSROUoZcqeu51BbkXCE1xX7dk6T)Ls5hMbpkE1vRzdE(QGfCn(FWc4t2cG76uHySI2HA)ZdL6xHbM6Q1SbpFvWcUg)py11fGiOYR3whQ9p3CQRtD1AwvnecQx43UIuOUAnRQgcb1l8Bhk1Vcdm1vRzdE(QGfCn(FWcW9aya)SkQbhuKnAUu4aEUo7tWRlKJwASpwc4UUOicSFFfMPUAnBWZxfSRif9mlarqLxVTou7FU5uxxac1GqtLnaleqGO8VtzC0n3JTROUovigRODO2)8qP(vyGfGqni0uzdWcbeik)7ughDZ9y7qP(vyadC66AhQ9ppuQFfg5ICvgGMmWuxTMn45RcwW14)bR(CsiplXjMy53jwaiLQFpXWIP73zXzbPXajMBfy539NLdxO7zPnWuwaGln2hojp8hSWw8dyLqY4iOcUW52qvmtG2RPK6Q1SbpFvWouQFfoELrtxN6Q1SbpFvWcUg)pybS4MSce(CUQMSbWCawG3FWkJFojp8hSWw8dyLqsG0e(pxND9HQsP6r71ucHpNRQjBamhGf49hSY4xrpZuxTMn45RcwW14)bR4JBYDDMfGiOYR3IGQFpX0VRtD1A2XrqfCHZTHQyMWUIuOUAn74iOcUW52qvmtyhk1VcdmagGdWcCDVnAOWHPSRpuvkvV9VukJW1lcW9mtD1AwvnecQx43UIuy27AQEl(9rdhqlvUQMa7Zj5H)Gf2IFaResUk4t5)bl0EnLq4Z5QAYgaZbybE)bRm(5KqEwai1NZv1ellmbYcSyXvp99hHz539NftE9S8qwujwWoccKLgCybPXajMBfybdz539NLFNsWIpu9SyYXpbYcajl8ZIk1GdXYVtPCsE4pyHT4hWkHee(CUQMqB5PKsyhbLBWjh88vb0IW1lsjZcqOgeAQSbpFvWoKdMORZme(CUQMSbyHaceLbjCIkOiarqLxVTou7FU5uxh4SoqBbZbqmNeYZsCIjmlXbi6XY1y5kw8If0lOVimXIxGS8ZrywEil6RiwUNLvelMUFNfa4sJ9bTSG0yGeZTcS4filXa0J(dbXYMjFs5K8WFWcBXpGvcjT1KidBzsVkcTxtjkOVimzVk7vcfEuoStbGuOUAnB0CPWb8CD2NGxxihT0yFSiC9IagGmNKv0de(wh0J(dbLXM8jnd6PokY(xaORq11zwaIGkVEBrHbQHdyFfi85CvnzXock3Gto45Rck6PUAn74iOcUW52qvmtyhk1VcdmagaQhAa(zvudoOil(Q2sN3tGFAoVVc1vRzhhbvWfo3gQIzc7kQRZm1vRzhhbvWfo3gQIzc7kQpNeYZsCIjwaix0VZY27tZ1AwIgyaZY1yz79P5AnlhUq3ZYkItYd)blSf)awjKGFFAUwJ2RPK6Q1SWI(DCoIMaf9hSSRifQRwZIFFAUwBhQneE3v1eNKh(dwyl(bSsij4vG0z1vRH2YtjLWVpA4aI2RPK6Q1S43hnCaTdL6xHbgAu0tD1AwkOVimLXqTp2Hs9RWXJMUo1vRzPG(IWuwVkFSdL6xHJhn9v44FCDocAIM4byjZjH8SehxPrywIbgaYIk1GdXcsHfciqell8vOy53jwqkSqabIyjalW7pyXYdzjStbGy5ASGuyHaceXYHzXd)Y16eS4QW1ZYdzrLyj44NtYd)blSf)awjKGFFWRbfH2RPuaIGkVEBDO2)CZjfi85CvnzdWcbeikds4evqrac1GqtLnaleqGO8VtzC0n3JTdL6xHbgAuyg4SoqBbZbqSckOVimzVk7vcfo(hxNJGMOjEZjzojKNL4etSS9(0CTMft3VZY2tATpSehNR9S4filfKLT3hnCarllM2PILcYY27tZ1AwomlRi0Ysc4IfFiwUIf0Fv(Wc6f0xeMyPbhwaOagtbmlWHLhYs0adSaaxASpSyANkwCvicIfawYSedmaKf4WIdg5)HGybBYNuw2DmlauaJPaMLHs9RUcflWHLdZYvS00hQ93YsSGpXYV7plRcKgw(DIfSNsSeGf49hSWSCp6WSagHzPO1pUMLhYY27tZ1AwaxZvOybGGJGk4cZsCyOkMjqllM2PILeWf6azb)NwZcvGSSIyX097SaWsgWooILgCy53jw0o(zbLgQ6ASLtYd)blSf)awjKGFFAUwJ2RP07AQEl(jT2Nm4CT3sLRQjqfM9UMQ3IFF0Wb0sLRQjqfQRwZIFFAUwBhQneE3v1KIEQRwZsb9fHPSEv(yhk1Vchpavbf0xeMSxL1RYhfQRwZgnxkCapxN9j41fYrln2hlcxViGbi0KCxN6Q1SrZLchWZ1zFcEDHC0sJ9XIW1lkELaeAswHJ)X15iOjAIhGLCxhi8ToOh9hckJn5tAg0tDuKDOu)kC8a0Uop8hSSoOh9hckJn5tAg0tDuK9QCtFO2)(kcqOgeAQSbpFvWouQFfoELtMtc5zjoXelBVp41GIybGCr)olrdmGzXlqwaxPrSedmaKft7uXcsJbsm3kWcCy53jwaiLQFpXWI6Q1y5WS4QW1ZYdzP5AnlWwJf4Wsc4cDGSe8iwIbgaYj5H)Gf2IFaResWVp41GIq71usD1Awyr)ooh0Kpzeh(GLDf11PUAnlqxboeyMsJGMOjLQptfnOUys2vuxN6Q1SbpFvWUIu0tD1A2XrqfCHZTHQyMWouQFfgyOcG2uhzaFGoDph)JRZrqt0GCJBY9bCCb(31u92ImLtHWYsLRQjqfMnRIAWbfzXx1w68Ec8tZ5kuxTMDCeubx4CBOkMjSROUo1vRzdE(QGDOu)kmWqfaTPoYa(aD6Eo(hxNJGMOb5g3K731PUAn74iOcUW52qvmtKXx1w68Ec8tZ52vuxNzQRwZoocQGlCUnufZe2vKcZcqOgeAQSJJGk4cNBdvXmHDihmrxNzbicQ86TiO63tm976C8pUohbnrt8aSKvqb9fHj7vzVsWjH8Sy(jblpKLuhiILFNyrLWplWglBVpA4aYIAcwWVha6kuSCplRiwaURlaKoblxXIxjyb9c6lctSOUEwaGln2hwoC9S4QW1ZYdzrLyjAGHabYj5H)Gf2IFaResWVp41GIq71u6DnvVf)(OHdOLkxvtGkmBwf1GdkY(xkzcovgCipv9kqAu0tD1Aw87JgoG2vuxNJ)X15iOjAIhGLCFfQRwZIFF0Wb0IFpaeWIRIEQRwZsb9fHPmgQ9XUI66uxTMLc6lctz9Q8XUI6RqD1A2O5sHd456SpbVUqoAPX(yr46fbmabGtwrVaeQbHMkBWZxfSdL6xHJx5K76mdHpNRQjBawiGarzqcNOckcqeu51BRd1(NBo1Ntc5zb9W)L6pHzzhAIL0vyNLyGbGS4dXck)kcKLiAybtbybYj5H)Gf2IFaResq4Z5QAcTLNsk54iainBuaTiC9IuIc6lct2RY6v5dWdqrUE4pyzXVpTBilHmkSEk)xkbyZOG(IWK9QSEv(a89aoa(DnvVfdx6mSL)Dk3GdHFlvUQMab(42h56H)GL104)ULqgfwpL)lLaCYwZbnixCeP15Dh)eGt2IgG)DnvVT8FneoR6AVcKLkxvtGCsiplXXvAelBVp41GIy5kwCwaWagtbw2GAFyb9c6lctOLfqyHUNfn9SCplrdmWcaCPX(WsVF3Fwoml7EbQjqwutWcD)onS87elBVpnxRzrFfXcCy53jwIbgagpalzw0xrS0GdlBVp41GI6JwwaHf6EwGiOX0CpXIxSaqUOFNLObgyXlqw00ZYVtS4Qqeel6Riw29cutSS9(OHdiNKh(dwyl(bSsib)(GxdkcTxtjZMvrn4GIS)LsMGtLbhYtvVcKgf9uxTMnAUu4aEUo7tWRlKJwASpweUEradqa4K76uxTMnAUu4aEUo7tWRlKJwASpweUEradqOjzfVRP6T4N0AFYGZ1ElvUQMa7ROhf0xeMSxLXqTpkC8pUohbnrdGr4Z5QAY64iainBua4vxTMLc6lctzmu7JDOu)kmGbHVTTMezylt6vr2)caHZdL6xb8aYIM4bOj31rb9fHj7vz9Q8rHJ)X15iOjAamcFoxvtwhhbaPzJcaV6Q1SuqFrykRxLp2Hs9RWage(22AsKHTmPxfz)laeopuQFfWdilAIhGLCFfMPUAnlSOFhNJOjqr)bl7ksHzVRP6T43hnCaTu5QAcurVaeQbHMkBWZxfSdL6xHJha31HHlT6vG2FFoToJjciASu5QAcuH6Q1S)(CADgteq0yXVhacyXnUaOEZQOgCqrw8vTLoVNa)0CoWJM(kAhQ9ppuQFfoELtozfTd1(Nhk1VcdmaLCY9v0laHAqOPYc0vGdbMXr3Cp2ouQFfoEaCxNzbicQ86TaLyoV6ZjH8SeNyIfaIqyHz5kwq)v5dlOxqFryIfVazb7iiwqoJRBaooS0AwaicHfln4WcsJbsm3kWIxGSGC6kWHazb9sJGMOjLQNtYd)blSf)awjKuKPCkewO9Ak1tD1AwkOVimL1RYh7qP(v44jKrH1t5)sPUUEHDFqryLaKIHc7(GIY)Lsadn976c7(GIWkf3(k8OCyNcaPaHpNRQjl2rq5gCYbpFvGtYd)blSf)awjKS76wofcl0EnL6PUAnlf0xeMY6v5JDOu)kC8eYOW6P8FPKcZcqeu51BbkXCE111tD1AwGUcCiWmLgbnrtkvFMkAqDXKSRifbicQ86TaLyoV6311lS7dkcReGumuy3huu(VucyOPFxxy3huewP421PUAnBWZxfSRO(k8OCyNcaPaHpNRQjl2rq5gCYbpFvqrp1vRzhhbvWfo3gQIzc7qP(vyG1dnaiab8ZQOgCqrw8vTLoVNa)0CEFfQRwZoocQGlCUnufZe2vuxNzQRwZoocQGlCUnufZe2vuFojp8hSWw8dyLqsBP15uiSq71uQN6Q1SuqFrykRxLp2Hs9RWXtiJcRNY)LskmlarqLxVfOeZ5vxxp1vRzb6kWHaZuAe0enPu9zQOb1ftYUIueGiOYR3cuI58QFxxVWUpOiSsasXqHDFqr5)sjGHM(DDHDFqryLIBxN6Q1SbpFvWUI6RWJYHDkaKce(CUQMSyhbLBWjh88vbf9uxTMDCeubx4CBOkMjSdL6xHbgAuOUAn74iOcUW52qvmtyxrkmBwf1GdkYIVQT059e4NMZ76mtD1A2XrqfCHZTHQyMWUI6ZjH8SeNyIfKdi6XcSyjaYj5H)Gf2IFaResm5ZCWjdBzsVkItc5zjoXelBVpTBiwEilrdmWYgu7dlOxqFrycTSG0yGeZTcSS7yw0egZYFPel)UxS4SGCm(VZcHmkSEIfn1EwGdlWsNGf0Fv(Wc6f0xeMy5WSSI4K8WFWcBXpGvcj43N2neAVMsuqFryYEvwVkF66OG(IWKfd1(KlczFxhf0xeMSELixeY(UUEQRwZAYN5Gtg2YKEvKDf11HJiToV74NawYwZbnkmlarqLxVfbv)EIPRdhrADE3XpbSKTMJIaebvE9weu97jM(kuxTMLc6lctz9Q8XUI666PUAnBWZxfSdL6xHbMh(dwwtJ)7wczuy9u(VusH6Q1SbpFvWUI6ZjH8SeNyIfKJX)DwG)onMomXIP9lSZYHz5kw2GAFyb9c6lctOLfKgdKyUvGf4WYdzjAGbwq)v5dlOxqFryItYd)blSf)awjKyA8FNtc5zjo4A9Vplojp8hSWw8dyLqYSQSh(dwz9HF0wEkPuZ16FFwgVXBya]] )


end