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


    spec:RegisterPack( "Balance", 20210708.1, [[deLfCfqikjpcIuxcIK2ej8jivgLuLtjv1Qau1RaOMfKs3sev2ff)cIyyaWXirwga6zcvAAusX1GuSnas9naIgNikohGkwhajZdq5EKO2Nqv)dIeLoOqrluOWdHOmrHk0fHuLnkubFeIevJeIefNKskTsrKxcrImtiv1nbiODkuQFcqOgQiQAPae4PkLPsjvxvOI2kaH0xHiHXkIs7Ls9xrnyIdt1IjPhlyYaDzKnlLpdjJwP60QA1aeIxdiZMu3wK2TKFdA4c54aQ0Yv8COMUkxxjBhcFNsmEiQoViSEHsMVuz)O2wjBRBVb6hzhBacaaQeaaKaizmkLmwtYe34AVDjIi7TipaKJIS3kpLS3IHR9kq2BrEcn0bTTU9ggUMazVTFxegqHeKO6AVcuYH)0Gb1F7lvZdrsmCTxbk52(uKHKuqZ(LQrkB71KYQU2RazoKF2BQRxFwBzRAVb6hzhBacaaQeaaKaizmkLmwtYexLS381Tdh7TTpfz2B7piiv2Q2BGeoyVfdx7vGyjooRhKtkPLobljdAzbGaaGkXjXjHSDVqryafNuYXsmbbjqw2GAFyjgKNA4Ksowq2UxOiqwoFqrx(BSeCmHz5GSese0u(8bfDydNuYXcGakfIGazzvffim2NeSGWN3v1eMLEVHmOLLOHqKXNp41GIyj5INLOHqyWNp41GI6B4KsowIjc4dYs0qbhFFHIfKIXVDw(gl)Homl3oXILbwOyb9c6pctgoPKJfaHoqelidwiGarSC7elBr)8hMfNf9FNMyjfoelnnH8xvtS07BSKaUyz3bl0DSS)hl)Xc(tx6ZlcUW6eSy5VDwIbG4yADwamliJ0e(ExZsm1pQkLQdTS8h6azbd0h13WjLCSai0bIyjfIpwqx7rTF5Hs9VWOJfCGkFEiMfpksNGLdYIkeJzP9O2pmlWsNWWjLCSy9H8JfRdtjwGnwIH23zjgAFNLyO9DwCmlol4ik8UMLB(ci6mCsCsXSk45hbYsmCTxbILyM8OplbVyrLyPbxfil(XY(DryafsqIQR9kqjh(tdgu)TVunpejXW1EfOKB7trgssbn7xQgPSTxtkR6AVcK5q(zVPF8HTTU9gi18L(STUDSvY262BE4EyzVHHAFYQKNAVrLRQjq7yyF2XgG2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVHJiToF(GIoSbF(0CTML4zrjwuWspwSILZ1uDg85JgoGgQCvnbYsxhlNRP6m4J0AFYGZ3odvUQMazPplDDSGJiToF(GIoSbF(0CTML4zbG2BGeomF09WYEBJomlXeIESalwIlGzXYF7W1Xc48TJfVazXYF7SSD(OHdilEbYcabmlWBNglpMS3q4tU8uYE7Xzhs2NDSJRT1T3OYv1eODmS3Gr2By6S38W9WYEdHpVRQj7neUEr2B4isRZNpOOdBWNpTFiwINfLS3ajCy(O7HL92gDywcAYrqSyzNkw2oFA)qSe8IL9)ybGaMLZhu0HzXY(h2z5XSmKMq41XsdoSC7elOxq)ryILdYIkXs0qnAgcKfVazXY(h2zP9AnnSCqwco(S3q4tU8uYE7X5GMCeK9zhBRX262Bu5QAc0og2BE4EyzVPsdMgG(cL9giHdZhDpSS3ItmXsmObtdqFHIfl)TZcYIjsS2kWcCyXBhnSGmyHaceXYxSGSyIeRTc2BH5pAE3ERhlwXsaIGkVot9O2VCZjw66yXkwcqOgeAPmbyHaceLVDkJJ(5pSzfXsFwuWI6Q1mbp)vWmuQ)fML4zrj0WIcwuxTMzCeubx4CBOkwjmdL6FHzbySynSOGfRyjarqLxNbbv3EIHLUowcqeu51zqq1TNyyrblQRwZe88xbZkIffSOUAnZ4iOcUW52qvSsywrSOGLESOUAnZ4iOcUW52qvSsygk1)cZcWyrjLyj5ybnSa8SmRIAWbfzWF1w68Ec8rZ7gQCvnbYsxhlQRwZe88xbZqP(xywaglkPelDDSOeliHfCeP15DhFelaJfLmObnS03(SJnASTU9gvUQMaTJH9wy(JM3T3uxTMj45VcMHs9VWSeplkHgwuWspwSILzvudoOid(R2sN3tGpAE3qLRQjqw66yrD1AMXrqfCHZTHQyLWmuQ)fMfGXIsaswuWI6Q1mJJGk4cNBdvXkHzfXsFw66yrfIXSOGL2JA)YdL6FHzbySaq0yVbs4W8r3dl7TKhESy5VDwCwqwmrI1wbwUD)y5Xf6owCws(Lg7dlrdmWcCyXYovSC7elTh1(XYJzXvHRJLdYcvG2BE4EyzVfbVhw2NDSb02w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVfOxZspw6Xs7rTF5Hs9VWSKCSOeAyj5yjaHAqOLYe88xbZqP(xyw6ZcsyrPKbaS0NfLzjqVMLES0JL2JA)YdL6FHzj5yrj0WsYXIsaeaSKCSeGqni0szcWcbeikF7ugh9ZFyZqP(xyw6ZcsyrPKbaS0NffSyflJ)GzcbvNXbbXgc5p(WS01Xsac1GqlLj45VcMHs9VWSeplFD0eb1(rG52JA)YdL6FHzPRJLaeQbHwktawiGar5BNY4OF(dBgk1)cZs8S81rteu7hbMBpQ9lpuQ)fMLKJfLaalDDSyflbicQ86m1JA)YnNyPRJfpCpSmbyHaceLVDkJJ(5pSb8XUQMaT3ajCy(O7HL9gYCDyP9JWSyzNUDAyzH)cflidwiGarSuqlSy51AwCTgAHLeWflhKf89AnlbhFSC7elypLyXtHR6yb2ybzWcbeicWilMiXARalbhFy7ne(KlpLS3cWcbeikds4evW(SJnG0262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7TESC(GIoZ9Pu(GzWNyjEwucnS01XY4pyMqq1zCqqS5lwINf0aaw6ZIcw6Xspw6XcbCxFuebAO0Oed56mCalVcelkyPhl9yjaHAqOLYqPrjgY1z4awEfiZqP(xywaglkbObalDDSeGiOYRZGGQBpXWIcwcqOgeAPmuAuIHCDgoGLxbYmuQ)fMfGXIsaAajlaMLESOKsSa8SmRIAWbfzWF1w68Ec8rZ7gQCvnbYsFw6ZIcwSILaeQbHwkdLgLyixNHdy5vGmd5GjyPpl9zPRJLESqa31hfrGgmCP10DFHkpl1eSOGLESyflbicQ86m1JA)YnNyPRJLaeQbHwkdgU0A6UVqLNLAICCTg0KmaqjZqP(xywaglkPK1WsFw6Zsxhl9yjaHAqOLYOsdMgG(cLzihmblDDSyflJhiZnqTML(SOGLES0Jfc4U(Oic08fomRZv1ug4U86wPzqcXhiwuWsac1GqlL5lCywNRQPmWD51TsZGeIpqMHCWeS0NLUow6Xspwq4Z7QAYaR8ct5B(ci6yrzwuILUowq4Z7QAYaR8ct5B(ci6yrzwIll9zrbl9y5MVaIoZPKzihmroaHAqOLILUowU5lGOZCkzcqOgeAPmdL6FHzjEw(6OjcQ9JaZTh1(Lhk1)cZsYXIsaGL(S01XccFExvtgyLxykFZxarhlkZcazrbl9y5MVaIoZbqZqoyICac1GqlflDDSCZxarN5aOjaHAqOLYmuQ)fML4z5RJMiO2pcm3Eu7xEOu)lmljhlkbaw6Zsxhli85DvnzGvEHP8nFbeDSOmlaGL(S0NL(S01XsaIGkVodqjM3lw6ZsxhlQqmMffS0Eu7xEOu)lmlaJf1vRzcE(RGbCn(9WYEdKWH5JUhw2BXjMaz5GSasApbl3oXYc7OiwGnwqwmrI1wbwSStfll8xOybeUu1elWILfMyXlqwIgcbvhllSJIyXYovS4floiilecQowEmlUkCDSCqwaFYEdHp5Ytj7TayoalW)EyzF2XozSTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEZkwWWLw9lqZTpVwNXebengQCvnbYsxhlTh1(Lhk1)cZs8Saqaaaw66yrfIXSOGL2JA)YdL6FHzbySaq0WcGzPhlwdayj5yrD1AMBFEToJjciAm4ZdaXcWZcazPplDDSOUAnZTpVwNXebeng85bGyjEwIBYWsYXspwMvrn4GIm4VAlDEpb(O5DdvUQMazb4zbnS03EdHp5Ytj7TBFEToJjciAYw8)Sp7ydCSTU9gvUQMaTJH9giHdZhDpSS3ItmXc6LgLyixZcG4bS8kqSaqaGPaMfvQbhIfNfKftKyTvGLfMm2BLNs2BuAuIHCDgoGLxbYElm)rZ72BbiudcTuMGN)kygk1)cZcWybGaGffSeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglaeaSOGLESGWN3v1K52NxRZyIaIMSf)pw66yrD1AMBFEToJjciAm4ZdaXs8SexaWcGzPhlZQOgCqrg8xTLoVNaF08UHkxvtGSa8SaOzPpl9zPRJfvigZIcwApQ9lpuQ)fMfGXsCbK2BE4EyzVrPrjgY1z4awEfi7Zo2kbaBRBVrLRQjq7yyVbs4W8r3dl7T4etSSbxAnDFHIfabl1eSaOXuaZIk1GdXIZcYIjsS2kWYctg7TYtj7nmCP10DFHkpl1e2BH5pAE3ElaHAqOLYe88xbZqP(xywaglaAwuWIvSeGiOYRZGGQBpXWIcwSILaebvEDM6rTF5MtS01XsaIGkVot9O2VCZjwuWsac1GqlLjaleqGO8TtzC0p)HndL6FHzbySaOzrbl9ybHpVRQjtawiGarzqcNOcS01Xsac1GqlLj45VcMHs9VWSamwa0S0NLUowcqeu51zqq1TNyyrbl9yXkwMvrn4GIm4VAlDEpb(O5DdvUQMazrblbiudcTuMGN)kygk1)cZcWybqZsxhlQRwZmocQGlCUnufReMHs9VWSamwuYAybWS0Jf0WcWZcbCxFuebA(cFZkCWbNbFeFrzvsRzPplkyrD1AMXrqfCHZTHQyLWSIyPplDDSOcXywuWs7rTF5Hs9VWSamwaiAS38W9WYEddxAnD3xOYZsnH9zhBLuY262Bu5QAc0og2BE4EyzV9fomRZv1ug4U86wPzqcXhi7TW8hnVBVPUAntWZFfmdL6FHzjEwucnSOGLESyflZQOgCqrg8xTLoVNaF08UHkxvtGS01XI6Q1mJJGk4cNBdvXkHzOu)lmlaJfLailaMLESexwaEwuxTMrvdHG6f(mRiw6ZcGzPhl9ybqYsYXcAyb4zrD1AgvnecQx4ZSIyPplapleWD9rreO5l8nRWbhCg8r8fLvjTML(SOGf1vRzghbvWfo3gQIvcZkIL(S01XIkeJzrblTh1(Lhk1)cZcWybGOXER8uYE7lCywNRQPmWD51TsZGeIpq2NDSvcG2w3EJkxvtG2XWEdKWH5JUhw2BwF)XS8ywCwg)2PHfs7QWXpIflEcwoilPoqelUwZcSyzHjwWNFSCZxarhMLdYIkXI(lcKLvelw(BNfKftKyTvGfVazbzWcbeiIfVazzHjwUDIfawGSG1WJfyXsaKLVXIk82z5MVaIoml(qSalwwyIf85hl38fq0HT3cZF08U9gcFExvtgyLxykFZxarhlkZcazrblwXYnFbeDMdGMHCWe5aeQbHwkw66yPhli85DvnzGvEHP8nFbeDSOmlkXsxhli85DvnzGvEHP8nFbeDSOmlXLL(SOGLESOUAntWZFfmRiwuWspwSILaebvEDgeuD7jgw66yrD1AMXrqfCHZTHQyLWmuQ)fMfaZspwqdlaplZQOgCqrg8xTLoVNaF08UHkxvtGS0NfGPml38fq0zoLmQRwldUg)EyXIcwuxTMzCeubx4CBOkwjmRiw66yrD1AMXrqfCHZTHQyLiJ)QT059e4JM3nRiw6ZsxhlbiudcTuMGN)kygk1)cZcGzbGSepl38fq0zoLmbiudcTugW143dlwuWIvSOUAntWZFfmRiwuWspwSILaebvEDM6rTF5MtS01XIvSGWN3v1KjaleqGOmiHtubw6ZIcwSILaebvEDgGsmVxS01XsaIGkVot9O2VCZjwuWccFExvtMaSqabIYGeorfyrblbiudcTuMaSqabIY3oLXr)8h2SIyrblwXsac1GqlLj45VcMvelkyPhl9yrD1AgkO)imL1RYhZqP(xywINfLaalDDSOUAndf0FeMYyO2hZqP(xywINfLaal9zrblwXYSkQbhuKr11EfOmSLDToF7FHcBOYv1eilDDS0Jf1vRzuDTxbkdBzxRZ3(xOW5YV1qg85bGyrzwqdlDDSOUAnJQR9kqzyl7AD(2)cfo7tWlYGppaelkZsYWsFw6ZsxhlQRwZa0xGdbMP0iOfAsP6YurdQpwKzfXsFw66yP9O2V8qP(xywaglaeaS01XccFExvtgyLxykFZxarhlkZcaS3WA4HT3U5lGOtj7npCpSS3U5lGOtj7Zo2kfxBRBVrLRQjq7yyV5H7HL92nFbeDa0Elm)rZ72Bi85DvnzGvEHP8nFbeDSyLYSaqwuWIvSCZxarN5uYmKdMihGqni0sXsxhli85DvnzGvEHP8nFbeDSOmlaKffS0Jf1vRzcE(RGzfXIcw6XIvSeGiOYRZGGQBpXWsxhlQRwZmocQGlCUnufReMHs9VWSayw6XcAyb4zzwf1GdkYG)QT059e4JM3nu5QAcKL(SamLz5MVaIoZbqJ6Q1YGRXVhwSOGf1vRzghbvWfo3gQIvcZkILUowuxTMzCeubx4CBOkwjY4VAlDEpb(O5DZkIL(S01Xsac1GqlLj45VcMHs9VWSaywailXZYnFbeDMdGMaeQbHwkd4A87HflkyXkwuxTMj45VcMvelkyPhlwXsaIGkVot9O2VCZjw66yXkwq4Z7QAYeGfciqugKWjQal9zrblwXsaIGkVodqjM3lwuWspwSIf1vRzcE(RGzfXsxhlwXsaIGkVodcQU9edl9zPRJLaebvEDM6rTF5MtSOGfe(8UQMmbyHaceLbjCIkWIcwcqOgeAPmbyHaceLVDkJJ(5pSzfXIcwSILaeQbHwktWZFfmRiwuWspw6XI6Q1muq)rykRxLpMHs9VWSeplkbaw66yrD1AgkO)imLXqTpMHs9VWSeplkbaw6ZIcwSILzvudoOiJQR9kqzyl7AD(2)cf2qLRQjqw66yPhlQRwZO6AVcug2YUwNV9VqHZLFRHm4ZdaXIYSGgw66yrD1Agvx7vGYWw2168T)fkC2NGxKbFEaiwuMLKHL(S0NL(S01XI6Q1ma9f4qGzkncAHMuQUmv0G6JfzwrS01Xs7rTF5Hs9VWSamwaiayPRJfe(8UQMmWkVWu(MVaIowuMfayVH1WdBVDZxarhaTp7yRK1yBD7nQCvnbAhd7nqchMp6EyzVfNycZIR1SaVDAybwSSWel)rPywGflbq7npCpSS3wyk)hLITp7yReASTU9gvUQMaTJH9giHdZhDpSS3IJu4bjw8W9WIf9JpwuDmbYcSyb)3YVhwirtOES9MhUhw2BZQYE4EyL1p(S3W38HZo2kzVfM)O5D7ne(8UQMmpo7qYEt)4lxEkzV5qY(SJTsaABRBVrLRQjq7yyVfM)O5D7TzvudoOiJQR9kqzyl7AD(2)cf2qa31hfrG2B4B(WzhBLS38W9WYEBwv2d3dRS(XN9M(XxU8uYEtf6N9zhBLaK2w3EJkxvtG2XWEZd3dl7TzvzpCpSY6hF2B6hF5Ytj7n8zF2N9Mk0pBRBhBLSTU9gvUQMaTJH9MhUhw2BJJGk4cNBdvXkH9giHdZhDpSS3IddvXkblw(BNfKftKyTvWElm)rZ72BQRwZe88xbZqP(xywINfLqJ9zhBaABD7nQCvnbAhd7npCpSS3Cqp6EeugBXNu7TqIGMYNpOOdBhBLS3cZF08U9M6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqSamwsgwuWI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSamwsgwuWspwSIfq4zCqp6EeugBXN0mON6OiZ9bG(cflkyXkw8W9WY4GE09iOm2IpPzqp1rrMVYn9JA)yrbl9yXkwaHNXb9O7rqzSfFsZ7KRn3ha6luS01Xci8moOhDpckJT4tAENCTzOu)lmlXZsCzPplDDSacpJd6r3JGYyl(KMb9uhfzWNhaIfGXsCzrblGWZ4GE09iOm2IpPzqp1rrMHs9VWSamwqdlkybeEgh0JUhbLXw8jnd6PokYCFaOVqXsF7nqchMp6EyzVfNyILyc6r3JGyzZIpPSyzNkw8JfnHXSC7EXI1WsmGX06SGppaeMfVaz5GSmuBi8ololatzaYc(8aqS4yw0(rS4ywIGy8RQjwGdl3NsS8hlyil)XIpZJGWSaiYcFS4TJgwCwIlGzbFEaiwiKh9dHTp7yhxBRBVrLRQjq7yyV5H7HL9wawiGar5BNY4OF(dBVbs4W8r3dl7T4etSGmyHaceXIL)2zbzXejwBfyXYovSebX4xvtS4filWBNglpMyXYF7S4SedymTolQRwJfl7uXciHtuHVqzVfM)O5D7nRybCwpOPG5aiMffS0JLESGWN3v1KjaleqGOmiHtubwuWIvSeGqni0szcE(RGzihmblDDSOUAntWZFfmRiw6ZIcw6XI6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqSOmljdlDDSOUAnJQR9kqzyl7AD(2)cfo7tWlYGppaelkZsYWsFw66yrfIXSOGL2JA)YdL6FHzbySOeayPV9zhBRX262Bu5QAc0og2BE4EyzV1wtImSLj9Qi7nqchMp6EyzVfhGOhloMLBNyP9d(ybvaKLVy52jwCwIbmMwNflFbcTWcCyXYF7SC7eliLsmVxSOUAnwGdlw(BNfNLKbWykWsmb9O7rqSSzXNuw8cKfl(FS0GdlilMiXARalFJL)yXcSowujwwrS4O8VyrLAWHy52jwcGS8ywAF94Dc0Elm)rZ72B9yPhl9yrD1Agvx7vGYWw2168T)fkCU8BnKbFEaiwINfanlDDSOUAnJQR9kqzyl7AD(2)cfo7tWlYGppaelXZcGML(SOGLESyflbicQ86miO62tmS01XIvSOUAnZ4iOcUW52qvSsywrS0NL(SOGLESaoRh0uWCaeZsxhlbiudcTuMGN)kygk1)cZs8SGgaWsxhl9yjarqLxNPEu7xU5elkyjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSeplObaS0NL(S0NLUow6Xci8moOhDpckJT4tAg0tDuKzOu)lmlXZsYWIcwcqOgeAPmbp)vWmuQ)fML4zrjaWIcwcqeu51zkkmqnCazPplDDSOcXywuWYxhnrqTFeyU9O2V8qP(xywagljdlkyXkwcqOgeAPmbp)vWmKdMGLUowcqeu51zakX8EXIcwuxTMbOVahcmtPrql0Ks1zwrS01XsaIGkVodcQU9edlkyrD1AMXrqfCHZTHQyLWmuQ)fMfGXcWHffSOUAnZ4iOcUW52qvSsywr2NDSrJT1T3OYv1eODmS38W9WYEl4vG0z1vRzVfM)O5D7TESOUAnJQR9kqzyl7AD(2)cfox(TgYmuQ)fML4zbqAqdlDDSOUAnJQR9kqzyl7AD(2)cfo7tWlYmuQ)fML4zbqAqdl9zrbl9yjaHAqOLYe88xbZqP(xywINfajlDDS0JLaeQbHwkdLgbTqtwfwGMHs9VWSeplaswuWIvSOUAndqFboeyMsJGwOjLQltfnO(yrMvelkyjarqLxNbOeZ7fl9zPplkyXX346Ce0cnSeVYSexayVPUATC5PK9g(8rdhq7nqchMp6EyzVHmVcKMLTZhnCazXYF7S4SuKfwIbmMwNf1vRXIxGSGSyIeRTcS84cDhlUkCDSCqwujwwyc0(SJnG2262Bu5QAc0og2BE4EyzVHpFWRbfzVbs4W8r3dl7T44knILTZh8AqrywS83ololXagtRZI6Q1yrDDSuWJfl7uXseeQ)cfln4WcYIjsS2kWcCybP0xGdbYYw0p)HT3cZF08U9wpwuxTMr11EfOmSLDToF7FHcNl)wdzWNhaIL4zbGS01XI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSeplaKL(SOGLESeGiOYRZupQ9l3CILUowcqOgeAPmbp)vWmuQ)fML4zbqYsxhlwXccFExvtMayoalW)EyXIcwSILaebvEDgGsmVxS01XspwcqOgeAPmuAe0cnzvybAgk1)cZs8SaizrblwXI6Q1ma9f4qGzkncAHMuQUmv0G6JfzwrSOGLaebvEDgGsmVxS0NL(SOGLESyflGWZ0wtImSLj9QiZ9bG(cflDDSyflbiudcTuMGN)kygYbtWsxhlwXsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPV9zhBaPT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXXvAelBNp41GIWSOsn4qSGmyHacezVfM)O5D7TESeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglOHffSyflGZ6bnfmhaXSOGLESGWN3v1KjaleqGOmiHtubw66yjaHAqOLYe88xbZqP(xywaglOHL(SOGfe(8UQMmbWCawG)9WIL(SOGfRybeEM2AsKHTmPxfzUpa0xOyrblbicQ86m1JA)YnNyrblwXc4SEqtbZbqmlkyHc6pctMVYELGffS44BCDocAHgwINfRba2NDStgBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS36XI6Q1mJJGk4cNBdvXkHzOu)lmlXZcAyPRJfRyrD1AMXrqfCHZTHQyLWSIyPplkyPhlQRwZa0xGdbMP0iOfAsP6YurdQpwKzOu)lmlaJfubqtQJCw6ZIcw6XI6Q1muq)rykJHAFmdL6FHzjEwqfanPoYzPRJf1vRzOG(JWuwVkFmdL6FHzjEwqfanPoYzPV9giHdZhDpSS3IJWcDhlGWJfW18fkwUDIfQazb2ybqGJGk4cZsCyOkwjqllGR5luSa0xGdbYcLgbTqtkvhlWHLVy52jw0o(ybvaKfyJfVyb9c6pct2Bi8jxEkzVbcV8qa31pukvh2(SJnWX262Bu5QAc0og2BE4EyzVHxv7hYElm)rZ72Bd1gcV7QAIffSC(GIoZ9Pu(GzWNyjEwucqZIcw8OCyNcaXIcwq4Z7QAYacV8qa31pukvh2ElKiOP85dk6W2Xwj7Zo2kbaBRBVrLRQjq7yyV5H7HL9wkewTFi7TW8hnVBVnuBi8URQjwuWY5dk6m3Ns5dMbFIL4zrP4AqdlkyXJYHDkaelkybHpVRQjdi8YdbCx)qPuDy7TqIGMYNpOOdBhBLSp7yRKs2w3EJkxvtG2XWEZd3dl7n8rATp5M2hYElm)rZ72Bd1gcV7QAIffSC(GIoZ9Pu(GzWNyjEwucqZcGzzOu)lmlkyXJYHDkaelkybHpVRQjdi8YdbCx)qPuDy7TqIGMYNpOOdBhBLSp7yReaTTU9gvUQMaTJH9MhUhw2Bn4eOmSLl)wdzVbs4W8r3dl7T4am2SalwcGSy5VD46yj4rrFHYElm)rZ72BEuoStbGSp7yRuCTTU9gvUQMaTJH9MhUhw2BuAe0cnzvybAVbs4W8r3dl7n0lncAHgwIbSazXYovS4QW1XYbzHQJgwCwkYclXagtRZILVaHwyXlqwWocILgCybzXejwBfS3cZF08U9wpwOG(JWKrVkFYfH8JLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JLUowuxTMr11EfOmSLDToF7FHcNl)wdzgk1)cZs8SainOHLUowuxTMr11EfOmSLDToF7FHcN9j4fzgk1)cZs8SainOHLUowC8nUohbTqdlXZcWbaSOGLaeQbHwktWZFfmd5GjyrblwXc4SEqtbZbqml9zrbl9yjaHAqOLYe88xbZqP(xywINL4caw66yjaHAqOLYe88xbZqoycw6ZsxhlQqmMffS81rteu7hbMBpQ9lpuQ)fMfGXIsaW(SJTswJT1T3OYv1eODmS38W9WYERTMezylt6vr2BGeomF09WYEloarpwMh1(XIk1GdXYc)fkwqwmT3cZF08U9wac1GqlLj45VcMHCWeSOGfe(8UQMmbWCawG)9WIffS0JfhFJRZrql0Ws8SaCaalkyXkwcqeu51zQh1(LBoXsxhlbicQ86m1JA)YnNyrblo(gxNJGwOHfGXI1aaw6ZIcwSILaebvEDgeuD7jgwuWspwSILaebvEDM6rTF5MtS01Xsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPplkyXkwaN1dAkyoaITp7yReASTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEZkwaN1dAkyoaIzrbli85DvnzcG5aSa)7HflkyPhl9yXX346Ce0cnSeplahaWIcw6XI6Q1ma9f4qGzkncAHMuQUmv0G6JfzwrS01XIvSeGiOYRZauI59IL(S01XI6Q1mQAieuVWNzfXIcwuxTMrvdHG6f(mdL6FHzbySOUAntWZFfmGRXVhwS0NLUow(6OjcQ9JaZTh1(Lhk1)cZcWyrD1AMGN)kyaxJFpSyPRJLaebvEDM6rTF5MtS0NffS0JfRyjarqLxNPEu7xU5elDDS0JfhFJRZrql0WcWyXAaalDDSacptBnjYWwM0RIm3ha6luS0NffS0Jfe(8UQMmbyHaceLbjCIkWsxhlbiudcTuMaSqabIY3oLXr)8h2mKdMGL(S03EdKWH5JUhw2BilMiXARalw2PIf)yb4aaaZsmXjpl9GJgAHgwUDVyXAaalXeN8Sy5VDwqgSqabI6ZIL)2HRJfne)fkwUpLy5lwIHgcb1l8XIxGSO)IyzfXIL)2zbzWcbeiILVXYFSyXXSas4evGaT3q4tU8uYElaMdWc8VhwzvOF2NDSvcqBBD7nQCvnbAhd7TW8hnVBVHWN3v1KjaMdWc8VhwzvOF2BE4EyzVfinHV31zx)OQuQo7Zo2kbiTTU9gvUQMaTJH9wy(JM3T3q4Z7QAYeaZbyb(3dRSk0p7npCpSS3(k4t53dl7Zo2kLm2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVrb9hHjZxz9Q8HfGNLKHfKWIhUhwg85t7hYqiNcRJY3NsSaywSIfkO)imz(kRxLpSa8S0JfanlaMLZ1uDgmCPZWw(2PCdoe(mu5QAcKfGNL4YsFwqclE4EyzSm(TBiKtH1r57tjwamlaWaqwqcl4isRZ7o(i7nqchMp6EyzVHE47t9JWSSdTWs6kSZsmXjpl(qSGY)IazjIgwWuawG2Bi8jxEkzV54OKNMnkyF2XwjGJT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXXvAelBNp41GIWSyzNkwUDIL2JA)y5XS4QW1XYbzHkq0YsBOkwjy5XS4QW1XYbzHkq0Ysc4IfFiw8JfGdaamlXeN8S8flEXc6f0FeMqllilMiXARalAhFyw8cE70WsYaymfWSahwsaxSybU0GSarqtWJyjfoel3UxSWDkbawIjo5zXYovSKaUyXcCPbl0DSSD(GxdkILcAXElm)rZ72B9yrfIXSOGLVoAIGA)iWC7rTF5Hs9VWSamwSgw66yPhlQRwZmocQGlCUnufReMHs9VWSamwqfanPoYzb4zjqVMLES44BCDocAHgwqclXfaS0NffSOUAnZ4iOcUW52qvSsywrS0NL(S01XspwC8nUohbTqdlaMfe(8UQMmook5PzJcSa8SOUAndf0FeMYyO2hZqP(xywamlGWZ0wtImSLj9QiZ9bGW5Hs9Vyb4zbGg0Ws8SOKsaGLUowC8nUohbTqdlaMfe(8UQMmook5PzJcSa8SOUAndf0FeMY6v5JzOu)lmlaMfq4zARjrg2YKEvK5(aq48qP(xSa8SaqdAyjEwusjaWsFwuWcf0FeMmFL9kblkyPhlwXI6Q1mbp)vWSIyPRJfRy5CnvNbF(OHdOHkxvtGS0NffS0JLESyflbiudcTuMGN)kywrS01XsaIGkVodqjM3lwuWIvSeGqni0szO0iOfAYQWc0SIyPplDDSeGiOYRZupQ9l3CIL(SOGLESyflbicQ86miO62tmS01XIvSOUAntWZFfmRiw66yXX346Ce0cnSeplahaWsFw66yPhlNRP6m4ZhnCanu5QAcKffSOUAntWZFfmRiwuWspwuxTMbF(OHdObFEaiwaglXLLUowC8nUohbTqdlXZcWbaS0NL(S01XI6Q1mbp)vWSIyrblwXI6Q1mJJGk4cNBdvXkHzfXIcwSILZ1uDg85JgoGgQCvnbAF2XgGaW262Bu5QAc0og2BE4EyzVvKLCkew2BGeomF09WYEloXelacHWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3aCCyP1SaieclwAWHfKftKyTvWElm)rZ72B9yrD1AgkO)imL1RYhZqP(xywINfc5uyDu((uILUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaK9zhBaQKT1T3OYv1eODmS3cZF08U9wpwuxTMHc6pctz9Q8XmuQ)fML4zHqofwhLVpLyrbl9yjaHAqOLYe88xbZqP(xywINf0aaw66yjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSeplObaS0NLUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaK9MhUhw2B7UULtHWY(SJnabOT1T3OYv1eODmS3cZF08U9wpwuxTMHc6pctz9Q8XmuQ)fML4zHqofwhLVpLyrbl9yjaHAqOLYe88xbZqP(xywINf0aaw66yjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSeplObaS0NLUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaK9MhUhw2BTLwNtHWY(SJnaJRT1T3OYv1eODmS3ajCy(O7HL9gsbe9ybwSeaT38W9WYEZIpZdNmSLj9Qi7Zo2a0ASTU9gvUQMaTJH9MhUhw2B4ZN2pK9giHdZhDpSS3ItmXY25t7hILdYs0adSSb1(Wc6f0FeMyboSyzNkw(IfyPtWc6VkFyb9c6pctS4fillmXcsbe9yjAGbmlFJLVyb9xLpSGEb9hHj7TW8hnVBVrb9hHjZxz9Q8HLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JLUowuxTMXIpZdNmSLj9QiZkIffSOUAndf0FeMY6v5JzfXsxhl9yrD1AMGN)kygk1)cZcWyXd3dlJLXVDdHCkSokFFkXIcwuxTMj45VcMvel9Tp7ydq0yBD7npCpSS3Sm(TBVrLRQjq7yyF2XgGaABRBVrLRQjq7yyV5H7HL92SQShUhwz9Jp7n9JVC5PK9wZ16BFw2N9zV5qY262XwjBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS36XI6Q1m3NswGtLbhYtv)cKgZqP(xywaglOcGMuh5SaywaGrjw66yrD1AM7tjlWPYGd5PQFbsJzOu)lmlaJfpCpSm4ZN2pKHqofwhLVpLybWSaaJsSOGLESqb9hHjZxz9Q8HLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JL(S0NffSOUAnZ9PKf4uzWH8u1VaPXSIyrblZQOgCqrM7tjlWPYGd5PQFbsJHkxvtG2BGeomF09WYEdzUoS0(rywSSt3onSC7elXXH80GFHDAyrD1ASy51AwAUwZcS1yXYF7FXYTtSueYpwco(S3q4tU8uYEdCipnB516CZ16mS1Sp7ydqBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS3SIfkO)imz(kJHAFyrbl9ybhrAD(8bfDyd(8P9dXs8SGgwuWY5AQodgU0zylF7uUbhcFgQCvnbYsxhl4isRZNpOOdBWNpTFiwINfajl9T3ajCy(O7HL9gYCDyP9JWSyzNUDAyz78bVguelpMflW52zj447luSarqdlBNpTFiw(If0Fv(Wc6f0FeMS3q4tU8uYE7rvWHY4Zh8Aqr2NDSJRT1T3OYv1eODmS38W9WYElaleqGO8TtzC0p)HT3ajCy(O7HL9wCIjwqgSqabIyXYovS4hlAcJz529If0aawIjo5zXlqw0FrSSIyXYF7SGSyIeRTc2BH5pAE3EZkwaN1dAkyoaIzrbl9yPhli85DvnzcWcbeikds4evGffSyflbiudcTuMGN)kygYbtWsxhlQRwZe88xbZkIL(SOGLESOUAndf0FeMY6v5JzOu)lmlXZcGMLUowuxTMHc6pctzmu7JzOu)lmlXZcGML(SOGLESyflZQOgCqrgvx7vGYWw2168T)fkSHkxvtGS01XI6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqSeplXLLUowuxTMr11EfOmSLDToF7FHcN9j4fzWNhaIL4zjUS0NLUowuHymlkyP9O2V8qP(xywaglkbawuWIvSeGqni0szcE(RGzihmbl9Tp7yBn2w3EJkxvtG2XWEZd3dl7TXrqfCHZTHQyLWEdKWH5JUhw2BXjMyjomufReSy5VDwqwmrI1wb7TW8hnVBVPUAntWZFfmdL6FHzjEwucn2NDSrJT1T3OYv1eODmS38W9WYEdVQ2pK9wirqt5Zhu0HTJTs2BH5pAE3ERhld1gcV7QAILUowuxTMHc6pctzmu7JzOu)lmlaJL4YIcwOG(JWK5RmgQ9HffSmuQ)fMfGXIswdlky5CnvNbdx6mSLVDk3GdHpdvUQMazPplky58bfDM7tP8bZGpXs8SOK1WsYXcoI0685dk6WSaywgk1)cZIcw6Xcf0FeMmFL9kblDDSmuQ)fMfGXcQaOj1rol9T3ajCy(O7HL9wCIjw2wv7hILVyjYlqk9dSalw8kXT)fkwUD)yr)iimlkznykGzXlqw0egZIL)2zjfoelNpOOdZIxGS4hl3oXcvGSaBS4SSb1(Wc6f0FeMyXpwuYAybtbmlWHfnHXSmuQ)1xOyXXSCqwk4XYUJ4luSCqwgQneENfW18fkwq)v5dlOxq)ryY(SJnG2262Bu5QAc0og2BE4EyzVHpFAUwBVbs4W8r3dl7nKsefXYkILTZNMR1S4hlUwZY9PeMLvPjmMLf(luSG(jc(4yw8cKL)y5XS4QW1XYbzjAGbwGdlA6y52jwWru4DnlE4EyXI(lIfvsdTWYUxGAIL44qEQ6xG0WcSybGSC(GIoS9wy(JM3T3SILZ1uDg8rATpzW5BNHkxvtGSOGLESOUAnd(8P5ATzO2q4DxvtSOGLESGJiToF(GIoSbF(0CTMfGXsCzPRJfRyzwf1GdkYCFkzbovgCipv9lqAmu5QAcKL(S01XY5AQodgU0zylF7uUbhcFgQCvnbYIcwuxTMHc6pctzmu7JzOu)lmlaJL4YIcwOG(JWK5RmgQ9HffSOUAnd(8P5ATzOu)lmlaJfajlkybhrAD(8bfDyd(8P5AnlXRmlwdl9zrbl9yXkwMvrn4GIm6ebFCCUPj6(cvgL(tJWKHkxvtGS01XY9PelivwSg0Ws8SOUAnd(8P5ATzOu)lmlaMfaYsFwuWY5dk6m3Ns5dMbFIL4zbn2NDSbK2w3EJkxvtG2XWEZd3dl7n85tZ1A7nqchMp6EyzVHu83olBhP1(WsCC(2XYctSalwcGSyzNkwgQneE3v1elQRJf89Anlw8)yPbhwq)ebFCmlrdmWIxGSacl0DSSWelQudoeliloInSSDVwZYctSOsn4qSGmyHaceXc(RaXYT7hlwETMLObgyXl4TtdlBNpnxRT3cZF08U925AQod(iT2Nm48TZqLRQjqwuWI6Q1m4ZNMR1MHAdH3DvnXIcw6XIvSmRIAWbfz0jc(44Ctt09fQmk9NgHjdvUQMazPRJL7tjwqQSynOHL4zXAyPplky58bfDM7tP8bZGpXs8Sex7Zo2jJT1T3OYv1eODmS38W9WYEdF(0CT2EdKWH5JUhw2Bif)TZsCCipv9lqAyzHjw2oFAUwZYbzbiIIyzfXYTtSOUAnwutWIRXqww4VqXY25tZ1AwGflOHfmfGfiMf4WIMWywgk1)6lu2BH5pAE3EBwf1GdkYCFkzbovgCipv9lqAmu5QAcKffSGJiToF(GIoSbF(0CTML4vML4YIcw6XIvSOUAnZ9PKf4uzWH8u1VaPXSIyrblQRwZGpFAUwBgQneE3v1elDDS0Jfe(8UQMmGd5PzlVwNBUwNHTglkyPhlQRwZGpFAUwBgk1)cZcWyjUS01XcoI0685dk6Wg85tZ1AwINfaYIcwoxt1zWhP1(KbNVDgQCvnbYIcwuxTMbF(0CT2muQ)fMfGXcAyPpl9zPV9zhBGJT1T3OYv1eODmS3Gr2By6S38W9WYEdHpVRQj7neUEr2Bo(gxNJGwOHL4zjzaaljhl9yrjaWcWZI6Q1m3NswGtLbhYtv)cKgd(8aqS0NLKJLESOUAnd(8P5ATzOu)lmlaplXLfKWcoI068UJpIfGNfRy5CnvNbFKw7tgC(2zOYv1eil9zj5yPhlbiudcTug85tZ1AZqP(xywaEwIlliHfCeP15DhFelaplNRP6m4J0AFYGZ3odvUQMazPpljhl9ybeEM2AsKHTmPxfzgk1)cZcWZcAyPplkyPhlQRwZGpFAUwBwrS01Xsac1GqlLbF(0CT2muQ)fML(2BGeomF09WYEdzUoS0(rywSSt3onS4SSD(GxdkILfMyXYR1Se8fMyz78P5AnlhKLMR1SaBn0YIxGSSWelBNp41GIy5GSaerrSehhYtv)cKgwWNhaILvK9gcFYLNs2B4ZNMR1zlW6YnxRZWwZ(SJTsaW262Bu5QAc0og2BE4EyzVHpFWRbfzVbs4W8r3dl7T4etSSD(GxdkIfl)TZsCCipv9lqAy5GSaerrSSIy52jwuxTglw(BhUow0q8xOyz78P5AnlRO7tjw8cKLfMyz78bVguelWIfRbWSedymTol4ZdaHzzv3RzXAy58bfDy7TW8hnVBVHWN3v1KbCipnB516CZ16mS1yrbli85DvnzWNpnxRZwG1LBUwNHTglkyXkwq4Z7QAY8Ok4qz85dEnOiw66yPhlQRwZO6AVcug2YUwNV9VqHZLFRHm4ZdaXs8Sexw66yrD1Agvx7vGYWw2168T)fkC2NGxKbFEaiwINL4YsFwuWcoI0685dk6Wg85tZ1AwaglwdlkybHpVRQjd(8P5AD2cSUCZ16mS1Sp7yRKs2w3EJkxvtG2XWEZd3dl7nh0JUhbLXw8j1ElKiOP85dk6W2Xwj7TW8hnVBVzfl3ha6luSOGfRyXd3dlJd6r3JGYyl(KMb9uhfz(k30pQ9JLUowaHNXb9O7rqzSfFsZGEQJIm4ZdaXcWyjUSOGfq4zCqp6EeugBXN0mON6OiZqP(xywaglX1EdKWH5JUhw2BXjMybBXNuwWqwUD)yjbCXck6yj1rolRO7tjwutWYc)fkw(JfhZI2pIfhZseeJFvnXcSyrtyml3UxSexwWNhacZcCybqKf(yXYovSexaZc(8aqywiKh9dzF2XwjaABD7nQCvnbAhd7npCpSS3sHWQ9dzVfse0u(8bfDy7yRK9wy(JM3T3gQneE3v1elky58bfDM7tP8bZGpXs8S0JLESOK1WcGzPhl4isRZNpOOdBWNpTFiwaEwailaplQRwZqb9hHPSEv(ywrS0NL(Saywgk1)cZsFwqcl9yrjwamlNRP6mNLVYPqyHnu5QAcKL(SOGLESeGqni0szcE(RGzihmblkyXkwaN1dAkyoaIzrbl9ybHpVRQjtawiGarzqcNOcS01Xsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPRJfRyjarqLxNPEu7xU5el9zPRJfCeP15Zhu0Hn4ZN2pelaJLES0Jfanljhl9yrD1AgkO)imL1RYhZkIfGNfaYsFw6ZcWZspwuIfaZY5AQoZz5RCkewydvUQMazPpl9zrblwXcf0FeMmyO2NCri)yPRJLESqb9hHjZxzmu7dlDDS0JfkO)imz(kRcVDw66yHc6pctMVY6v5dl9zrblwXY5AQodgU0zylF7uUbhcFgQCvnbYsxhlQRwZenFkCaFxN9j41hYrln2hdcxViwIxzwaiAaal9zrbl9ybhrAD(8bfDyd(8P9dXcWyrjaWcWZspwuIfaZY5AQoZz5RCkewydvUQMazPpl9zrblo(gxNJGwOHL4zbnaGLKJf1vRzWNpnxRndL6FHzb4zbqZsFwuWspwSIf1vRza6lWHaZuAe0cnPuDzQOb1hlYSIyPRJfkO)imz(kJHAFyPRJfRyjarqLxNbOeZ7fl9zrblwXI6Q1mJJGk4cNBdvXkrg)vBPZ7jWhnVBwr2BGeomF09WYEdqa1gcVZcGqiSA)qS8nwqwmrI1wbwEmld5Gjqll3onel(qSOjmMLB3lwqdlNpOOdZYxSG(RYhwqVG(JWelw(BNLn4fhqllAcJz529IfLaalWBNglpMy5lw8kblOxq)ryIf4WYkILdYcAy58bfDywuPgCiwCwq)v5dlOxq)ryYWsCewO7yzO2q4DwaxZxOybP0xGdbYc6LgbTqtkvhlRstymlFXYgu7dlOxq)ryY(SJTsX1262Bu5QAc0og2BE4EyzV1GtGYWwU8BnK9giHdZhDpSS3ItmXsCagBwGflbqwS83oCDSe8OOVqzVfM)O5D7npkh2Paq2NDSvYASTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEZkwaN1dAkyoaIzrbli85DvnzcG5aSa)7HflkyPhl9yrD1Ag85tZ1AZkILUowoxt1zWhP1(KbNVDgQCvnbYsxhlbicQ86m1JA)YnNyPplkyPhlwXI6Q1myOgFFGmRiwuWIvSOUAntWZFfmRiwuWspwSILZ1uDM2AsKHTmPxfzOYv1eilDDSOUAntWZFfmGRXVhwSeplbiudcTuM2AsKHTmPxfzgk1)cZcGzjzyPplkybHpVRQjZTpVwNXebenzl(FSOGLESyflbicQ86m1JA)YnNyPRJLaeQbHwktawiGar5BNY4OF(dBwrSOGLESOUAnd(8P5ATzOu)lmlaJfaYsxhlwXY5AQod(iT2Nm48TZqLRQjqw6ZsFwuWY5dk6m3Ns5dMbFIL4zrD1AMGN)kyaxJFpSyb4zbagajl9zPRJL2JA)YdL6FHzbySOUAntWZFfmGRXVhwS03EdHp5Ytj7TayoalW)EyLDizF2Xwj0yBD7nQCvnbAhd7npCpSS3cKMW376SRFuvkvN9giHdZhDpSS3ItmXcYIjsS2kWcSyjaYYQ0egZIxGSO)Iy5pwwrSy5VDwqgSqabIS3cZF08U9gcFExvtMayoalW)EyLDizF2XwjaTT1T3OYv1eODmS3cZF08U9gcFExvtMayoalW)EyLDizV5H7HL92xbFk)EyzF2XwjaPT1T3OYv1eODmS38W9WYEJsJGwOjRclq7nqchMp6EyzVfNyIf0lncAHgwIbSazbwSeazXYF7SSD(0CTMLvelEbYc2rqS0Gdlj)sJ9HfVazbzXejwBfS3cZF08U9MkeJzrblFD0eb1(rG52JA)YdL6FHzbySOeAyPRJLESOUAnt08PWb8DD2NGxFihT0yFmiC9IybySaq0aaw66yrD1AMO5tHd476SpbV(qoAPX(yq46fXs8kZcardayPplkyrD1Ag85tZ1AZkIffS0JLaeQbHwktWZFfmdL6FHzjEwqdayPRJfWz9GMcMdGyw6BF2XwPKX262Bu5QAc0og2BE4EyzVHpsR9j30(q2BHebnLpFqrh2o2kzVfM)O5D7THAdH3DvnXIcwUpLYhmd(elXZIsOHffSGJiToF(GIoSbF(0(HybySynSOGfpkh2PaqSOGLESOUAntWZFfmdL6FHzjEwucaS01XIvSOUAntWZFfmRiw6BVbs4W8r3dl7nabuBi8olnTpelWILvelhKL4YY5dk6WSy5VD46ybzXejwBfyrL(cflUkCDSCqwiKh9dXIxGSuWJficAcEu0xOSp7yReWX262Bu5QAc0og2BE4EyzV1wtImSLj9Qi7nqchMp6EyzVfNyIL4ae9y5BS8f(bjw8If0lO)imXIxGSO)Iy5pwwrSy5VDwCws(Lg7dlrdmWIxGSetqp6EeelBw8j1Elm)rZ72Buq)ryY8v2ReSOGfpkh2PaqSOGf1vRzIMpfoGVRZ(e86d5OLg7JbHRxelaJfaIgaWIcw6Xci8moOhDpckJT4tAg0tDuK5(aqFHILUowSILaebvEDMIcdudhqw66ybhrAD(8bfDywINfaYsFwuWspwuxTMzCeubx4CBOkwjmdL6FHzbySaCyj5yPhlOHfGNLzvudoOid(R2sN3tGpAE3qLRQjqw6ZIcwuxTMzCeubx4CBOkwjmRiw66yXkwuxTMzCeubx4CBOkwjmRiw6ZIcw6XIvSeGqni0szcE(RGzfXsxhlQRwZC7ZR1zmrarJbFEaiwaglkHgwuWs7rTF5Hs9VWSamwaiaaalkyP9O2V8qP(xywINfLaaayPRJfRybdxA1Van3(8ADgteq0yOYv1eil9zrbl9ybdxA1Van3(8ADgteq0yOYv1eilDDSeGqni0szcE(RGzOu)lmlXZsCbal9Tp7ydqayBD7nQCvnbAhd7npCpSS3WNpnxRT3ajCy(O7HL9wCIjwCw2oFAUwZcG4IUDwIgyGLvPjmMLTZNMR1S8ywC9qoycwwrSahwsaxS4dXIRcxhlhKficAcEelXeN82BH5pAE3EtD1Agyr3oohrtGIUhwMvelkyPhlQRwZGpFAUwBgQneE3v1elDDS44BCDocAHgwINfGdayPV9zhBaQKT1T3OYv1eODmS38W9WYEdF(0CT2EdKWH5JUhw2BXXvAelXeN8SOsn4qSGmyHaceXIL)2zz78P5AnlEbYYTtflBNp41GIS3cZF08U9waIGkVot9O2VCZjwuWIvSCUMQZGpsR9jdoF7mu5QAcKffS0Jfe(8UQMmbyHaceLbjCIkWsxhlbiudcTuMGN)kywrS01XI6Q1mbp)vWSIyPplkyjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSamwqfanPoYzb4zjqVMLES44BCDocAHgwqclObaS0NffSOUAnd(8P5ATzOu)lmlaJfRHffSyflGZ6bnfmhaX2NDSbiaTTU9gvUQMaTJH9wy(JM3T3cqeu51zQh1(LBoXIcw6XccFExvtMaSqabIYGeorfyPRJLaeQbHwktWZFfmRiw66yrD1AMGN)kywrS0NffSeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglaAwuWI6Q1m4ZNMR1MvelkyHc6pctMVYELGffSyfli85DvnzEufCOm(8bVguelkyXkwaN1dAkyoaIT38W9WYEdF(GxdkY(SJnaJRT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXjMyz78bVguelw(BNfVybqCr3olrdmWcCy5BSKaUqhilqe0e8iwIjo5zXYF7SKaUgwkc5hlbhFgwIPgdzbCLgXsmXjpl(XYTtSqfilWgl3oXcGOuD7jgwuxTglFJLTZNMR1SybU0Gf6owAUwZcS1yboSKaUyXhIfyXcaz58bfDy7TW8hnVBVPUAndSOBhNdAYNmIh)WYSIyPRJLESyfl4ZN2pKXJYHDkaelkyXkwq4Z7QAY8Ok4qz85dEnOiw66yPhlQRwZe88xbZqP(xywaglOHffSOUAntWZFfmRiw66yPhl9yrD1AMGN)kygk1)cZcWybva0K6iNfGNLa9Aw6XIJVX15iOfAybjSexaWsFwuWI6Q1mbp)vWSIyPRJf1vRzghbvWfo3gQIvIm(R2sN3tGpAE3muQ)fMfGXcQaOj1rolaplb61S0JfhFJRZrql0WcsyjUaGL(SOGf1vRzghbvWfo3gQIvIm(R2sN3tGpAE3SIyPplkyjarqLxNbbv3EIHL(S0NffS0JfCeP15Zhu0Hn4ZNMR1SamwIllDDSGWN3v1KbF(0CToBbwxU5ADg2AS0NL(SOGfRybHpVRQjZJQGdLXNp41GIyrbl9yXkwMvrn4GIm3NswGtLbhYtv)cKgdvUQMazPRJfCeP15Zhu0Hn4ZNMR1SamwIll9Tp7ydqRX262Bu5QAc0og2BE4EyzVvKLCkew2BGeomF09WYEloXelacHWcZYxSSb1(Wc6f0FeMyXlqwWocIL4WsRzbqiewS0GdlilMiXARG9wy(JM3T36XI6Q1muq)rykJHAFmdL6FHzjEwiKtH1r57tjw66yPhlHDFqrywuMfaYIcwgkS7dkkFFkXcWybnS0NLUowc7(GIWSOmlXLL(SOGfpkh2Paq2NDSbiASTU9gvUQMaTJH9wy(JM3T36XI6Q1muq)rykJHAFmdL6FHzjEwiKtH1r57tjw66yPhlHDFqrywuMfaYIcwgkS7dkkFFkXcWybnS0NLUowc7(GIWSOmlXLL(SOGfpkh2PaqSOGLESOUAnZ4iOcUW52qvSsygk1)cZcWybnSOGf1vRzghbvWfo3gQIvcZkIffSyflZQOgCqrg8xTLoVNaF08UHkxvtGS01XIvSOUAnZ4iOcUW52qvSsywrS03EZd3dl7TDx3YPqyzF2XgGaABRBVrLRQjq7yyVfM)O5D7TESOUAndf0FeMYyO2hZqP(xywINfc5uyDu((uIffS0JLaeQbHwktWZFfmdL6FHzjEwqdayPRJLaeQbHwktawiGar5BNY4OF(dBgk1)cZs8SGgaWsFw66yPhlHDFqrywuMfaYIcwgkS7dkkFFkXcWybnS0NLUowc7(GIWSOmlXLL(SOGfpkh2PaqSOGLESOUAnZ4iOcUW52qvSsygk1)cZcWybnSOGf1vRzghbvWfo3gQIvcZkIffSyflZQOgCqrg8xTLoVNaF08UHkxvtGS01XIvSOUAnZ4iOcUW52qvSsywrS03EZd3dl7T2sRZPqyzF2XgGasBRBVrLRQjq7yyVbs4W8r3dl7T4etSGuarpwGfliloAV5H7HL9MfFMhozylt6vr2NDSbyYyBD7nQCvnbAhd7nyK9gMo7npCpSS3q4Z7QAYEdHRxK9goI0685dk6Wg85t7hIL4zXAybWS00q4WspwsD8rtImcxViwaEwucaaGfKWcabal9zbWS00q4WspwuxTMbF(GxdkktPrql0Ks1LXqTpg85bGybjSynS03EdKWH5JUhw2BiZ1HL2pcZILD62PHLdYYctSSD(0(Hy5lw2GAFyXY(h2z5XS4hlOHLZhu0HbSsS0GdlecAsWcabasLLuhF0KGf4WI1WY25dEnOiwqV0iOfAsP6ybFEaiS9gcFYLNs2B4ZN2pu(RmgQ9X(SJnabo2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVPeliHfCeP15DhFelaJfaYsYXspwaGbGSa8S0JfCeP15Zhu0Hn4ZN2peljhlkXsFwaEw6XIsSaywoxt1zWWLodB5BNYn4q4ZqLRQjqwaEwuYGgw6ZsFwamlaWOeAyb4zrD1AMXrqfCHZTHQyLWmuQ)f2EdKWH5JUhw2BiZ1HL2pcZILD62PHLdYcsX43olGR5luSehgQIvc7ne(KlpLS3Sm(TN)k3gQIvc7Zo2Xfa2w3EJkxvtG2XWEZd3dl7nlJF72BGeomF09WYEloXelifJF7S8flBqTpSGEb9hHjwGdlFJLcYY25t7hIflVwZs7pw(6GSGSyIeRTcS4vIu4q2BH5pAE3ERhluq)ryYOxLp5Iq(Xsxhluq)ryY4vICri)yrbli85DvnzECoOjhbXsFwuWspwoFqrN5(ukFWm4tSeplwdlDDSqb9hHjJEv(K)kdqw66yP9O2V8qP(xywaglkbaw6ZsxhlQRwZqb9hHPmgQ9XmuQ)fMfGXIhUhwg85t7hYqiNcRJY3NsSOGf1vRzOG(JWugd1(ywrS01Xcf0FeMmFLXqTpSOGfRybHpVRQjd(8P9dL)kJHAFyPRJf1vRzcE(RGzOu)lmlaJfpCpSm4ZN2pKHqofwhLVpLyrblwXccFExvtMhNdAYrqSOGf1vRzcE(RGzOu)lmlaJfc5uyDu((uIffSOUAntWZFfmRiw66yrD1AMXrqfCHZTHQyLWSIyrbli85DvnzSm(TN)k3gQIvcw66yXkwq4Z7QAY84CqtocIffSOUAntWZFfmdL6FHzjEwiKtH1r57tj7Zo2XvjBRBVrLRQjq7yyVbs4W8r3dl7T4etSSD(0(Hy5BS8flO)Q8Hf0lO)imHww(ILnO2hwqVG(JWelWIfRbWSC(GIomlWHLdYs0adSSb1(Wc6f0FeMS38W9WYEdF(0(HSp7yhxaABD7nQCvnbAhd7nqchMp6EyzVfhCT(2NL9MhUhw2BZQYE4EyL1p(S30p(YLNs2BnxRV9zzF2N9wZ16BFw2w3o2kzBD7nQCvnbAhd7npCpSS3WNp41GIS3ajCy(O7HL9225dEnOiwAWHLuickLQJLvPjmMLf(luSedymTU9wy(JM3T3SILzvudoOiJQR9kqzyl7AD(2)cf2qa31hfrG2NDSbOT1T3OYv1eODmS38W9WYEdVQ2pK9wirqt5Zhu0HTJTs2BH5pAE3EdeEMuiSA)qMHs9VWSepldL6FHzb4zbGaKfKWIsjJ9giHdZhDpSS3qMJpwUDIfq4XIL)2z52jwsH4JL7tjwoiloiilR6Enl3oXsQJCwaxJFpSy5XSS)NHLTv1(HyzOu)lmlPl99r6Naz5GSK6xyNLuiSA)qSaUg)EyzF2XoU2w3EZd3dl7TuiSA)q2Bu5QAc0og2N9zVHpBRBhBLSTU9gvUQMaTJH9MhUhw2B4Zh8Aqr2BGeomF09WYEloXelBNp41GIy5GSaerrSSIy52jwIJd5PQFbsdlQRwJLVXYFSybU0GSqip6hIfvQbhIL2xpE)luSC7elfH8JLGJpwGdlhKfWvAelQudoelidwiGar2BH5pAE3EBwf1GdkYCFkzbovgCipv9lqAmu5QAcKffS0JfkO)imz(k7vcwuWIvS0JLESOUAnZ9PKf4uzWH8u1VaPXmuQ)fML4zXd3dlJLXVDdHCkSokFFkXcGzbagLyrbl9yHc6pctMVYQWBNLUowOG(JWK5RmgQ9HLUowOG(JWKrVkFYfH8JL(S01XI6Q1m3NswGtLbhYtv)cKgZqP(xywINfpCpSm4ZN2pKHqofwhLVpLybWSaaJsSOGLESqb9hHjZxz9Q8HLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JL(S0NLUowSIf1vRzUpLSaNkdoKNQ(finMvel9zPRJLESOUAntWZFfmRiw66ybHpVRQjtawiGarzqcNOcS0NffSeGqni0szcWcbeikF7ugh9ZFyZqoycwuWsaIGkVot9O2VCZjw6ZIcw6XIvSeGiOYRZauI59ILUowcqOgeAPmuAe0cnzvybAgk1)cZs8SKmS0NffS0Jf1vRzcE(RGzfXsxhlwXsac1GqlLj45VcMHCWeS03(SJnaTTU9gvUQMaTJH9MhUhw2BoOhDpckJT4tQ9wirqt5Zhu0HTJTs2BH5pAE3EZkwaHNXb9O7rqzSfFsZGEQJIm3ha6luSOGfRyXd3dlJd6r3JGYyl(KMb9uhfz(k30pQ9JffS0JfRybeEgh0JUhbLXw8jnVtU2CFaOVqXsxhlGWZ4GE09iOm2IpP5DY1MHs9VWSeplOHL(S01Xci8moOhDpckJT4tAg0tDuKbFEaiwaglXLffSacpJd6r3JGYyl(KMb9uhfzgk1)cZcWyjUSOGfq4zCqp6EeugBXN0mON6OiZ9bG(cL9giHdZhDpSS3ItmXsmb9O7rqSSzXNuwSStfl3onelpMLcYIhUhbXc2IpPOLfhZI2pIfhZseeJFvnXcSybBXNuwS83olaKf4WsJSqdl4ZdaHzboSalwCwIlGzbBXNuwWqwUD)y52jwkYclyl(KYIpZJGWSaiYcFS4TJgwUD)ybBXNuwiKh9dHTp7yhxBRBVrLRQjq7yyV5H7HL9wawiGar5BNY4OF(dBVbs4W8r3dl7T4etywqgSqabIy5BSGSyIeRTcS8ywwrSahwsaxS4dXciHtuHVqXcYIjsS2kWIL)2zbzWcbeiIfVazjbCXIpelQKgAHfRbaSetCYBVfM)O5D7nRybCwpOPG5aiMffS0JLESGWN3v1KjaleqGOmiHtubwuWIvSeGqni0szcE(RGzihmblkyXkwMvrn4GImrZNchW31zFcE9HC0sJ9XqLRQjqw66yrD1AMGN)kywrS0NffS44BCDocAHgwaMYSynaGffS0Jf1vRzOG(JWuwVkFmdL6FHzjEwucaS01XI6Q1muq)rykJHAFmdL6FHzjEwucaS0NLUowuHymlkyP9O2V8qP(xywaglkbawuWIvSeGqni0szcE(RGzihmbl9Tp7yBn2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzV1Jf1vRzghbvWfo3gQIvcZqP(xywINf0WsxhlwXI6Q1mJJGk4cNBdvXkHzfXsFwuWIvSOUAnZ4iOcUW52qvSsKXF1w68Ec8rZ7MvelkyPhlQRwZa0xGdbMP0iOfAsP6YurdQpwKzOu)lmlaJfubqtQJCw6ZIcw6XI6Q1muq)rykJHAFmdL6FHzjEwqfanPoYzPRJf1vRzOG(JWuwVkFmdL6FHzjEwqfanPoYzPRJLESyflQRwZqb9hHPSEv(ywrS01XIvSOUAndf0FeMYyO2hZkIL(SOGfRy5CnvNbd147dKHkxvtGS03EdKWH5JUhw2BidwG)9WILgCyX1AwaHhMLB3pwsDGiml41qSC7ucw8Hk0DSmuBi8obYILDQybqGJGk4cZsCyOkwjyz3XSOjmMLB3lwqdlykGzzOu)RVqXcCy52jwakX8EXI6Q1y5XS4QW1XYbzP5AnlWwJf4WIxjyb9c6pctS8ywCv46y5GSqip6hYEdHp5Ytj7nq4Lhc4U(HsP6W2NDSrJT1T3OYv1eODmS3Gr2By6S38W9WYEdHpVRQj7neUEr2B9yXkwuxTMHc6pctzmu7JzfXIcwSIf1vRzOG(JWuwVkFmRiw6ZsxhlNRP6myOgFFGmu5QAc0EdKWH5JUhw2BidwG)9WILB3pwc7uaimlFJLeWfl(qSaxh(bjwOG(JWelhKfyPtWci8y52PHyboS8Ok4qSC7pMfl)TZYguJVpq2Bi8jxEkzVbcVmCD4hKYuq)ryY(SJnG2262Bu5QAc0og2BE4EyzVLcHv7hYElm)rZ72Bd1gcV7QAIffS0Jf1vRzOG(JWugd1(ygk1)cZs8SmuQ)fMLUowuxTMHc6pctz9Q8XmuQ)fML4zzOu)lmlDDSGWN3v1KbeEz46WpiLPG(JWel9zrbld1gcV7QAIffSC(GIoZ9Pu(GzWNyjEwucGSOGfpkh2PaqSOGfe(8UQMmGWlpeWD9dLs1HT3cjcAkF(GIoSDSvY(SJnG0262Bu5QAc0og2BE4EyzVHxv7hYElm)rZ72Bd1gcV7QAIffS0Jf1vRzOG(JWugd1(ygk1)cZs8SmuQ)fMLUowuxTMHc6pctz9Q8XmuQ)fML4zzOu)lmlDDSGWN3v1KbeEz46WpiLPG(JWel9zrbld1gcV7QAIffSC(GIoZ9Pu(GzWNyjEwucGSOGfpkh2PaqSOGfe(8UQMmGWlpeWD9dLs1HT3cjcAkF(GIoSDSvY(SJDYyBD7nQCvnbAhd7npCpSS3WhP1(KBAFi7TW8hnVBVnuBi8URQjwuWspwuxTMHc6pctzmu7JzOu)lmlXZYqP(xyw66yrD1AgkO)imL1RYhZqP(xywINLHs9VWS01XccFExvtgq4LHRd)GuMc6pctS0NffSmuBi8URQjwuWY5dk6m3Ns5dMbFIL4zrjanlkyXJYHDkaelkybHpVRQjdi8YdbCx)qPuDy7TqIGMYNpOOdBhBLSp7ydCSTU9gvUQMaTJH9MhUhw2Bn4eOmSLl)wdzVbs4W8r3dl7T4etSehGXMfyXsaKfl)Tdxhlbpk6lu2BH5pAE3EZJYHDkaK9zhBLaGT1T3OYv1eODmS38W9WYEJsJGwOjRclq7nqchMp6EyzVfNyIfKsFboeilBr)8hMfl)TZIxjyrdluSqfCHANfTJVVqXc6f0FeMyXlqwUjblhKf9xel)XYkIfl)TZsYV0yFyXlqwqwmrI1wb7TW8hnVBV1JLESOUAndf0FeMYyO2hZqP(xywINfLaalDDSOUAndf0FeMY6v5JzOu)lmlXZIsaGL(SOGLaeQbHwktWZFfmdL6FHzjEwIlayrbl9yrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGwdayPRJfRyzwf1GdkYenFkCaFxN9j41hYrln2hdbCxFuebYsFw6ZsxhlQRwZenFkCaFxN9j41hYrln2hdcxViwIxzwaiGeaS01Xsac1GqlLj45VcMHCWeSOGfhFJRZrql0Ws8SaCaG9zhBLuY262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nRybCwpOPG5aiMffSGWN3v1KjaMdWc8VhwSOGLES0JLaeQbHwkdLgLyixNHdy5vGmdL6FHzbySOeGgqYcGzPhlkPelaplZQOgCqrg8xTLoVNaF08UHkxvtGS0NffSqa31hfrGgknkXqUodhWYRaXsFw66yXX346Ce0cnSeVYSaCaalkyPhlwXY5AQotBnjYWwM0RImu5QAcKLUowuxTMj45VcgW143dlwINLaeQbHwktBnjYWwM0RImdL6FHzbWSKmS0NffSGWN3v1K52NxRZyIaIMSf)pwuWspwuxTMbOVahcmtPrql0Ks1LPIguFSiZkILUowSILaebvEDgGsmVxS0NffSC(GIoZ9Pu(GzWNyjEwuxTMj45VcgW143dlwaEwaGbqYsxhlQqmMffS0Eu7xEOu)lmlaJf1vRzcE(RGbCn(9WILUowcqeu51zQh1(LBoXsxhlQRwZOQHqq9cFMvelkyrD1AgvnecQx4ZmuQ)fMfGXI6Q1mbp)vWaUg)EyXcGzPhlahwaEwMvrn4GImrZNchW31zFcE9HC0sJ9Xqa31hfrGS0NL(SOGfRyrD1AMGN)kywrSOGLESyflbicQ86m1JA)YnNyPRJLaeQbHwktawiGar5BNY4OF(dBwrS01XIkeJzrblTh1(Lhk1)cZcWyjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSaywa0S01Xs7rTF5Hs9VWSGuzrPKbaSamwuxTMj45VcgW143dlw6BVbs4W8r3dl7T4etSGSyIeRTcSy5VDwqgSqabIqcsPVahcKLTOF(dZIxGSacl0DSarqJL5pILKFPX(WcCyXYovSednecQx4JflWLgKfc5r)qSOsn4qSGSyIeRTcSqip6hcBVHWNC5PK9wamhGf4FpSY4Z(SJTsa0262Bu5QAc0og2BE4EyzVnocQGlCUnufRe2BGeomF09WYEloXel3oXcGOuD7jgwS83ololilMiXARal3UFS84cDhlTbMYsYV0yFS3cZF08U9M6Q1mbp)vWmuQ)fML4zrj0WsxhlQRwZe88xbd4A87HflaJL4cawuWccFExvtMayoalW)EyLXN9zhBLIRT1T3OYv1eODmS3cZF08U9gcFExvtMayoalW)EyLXhlkyPhlwXI6Q1mbp)vWaUg)EyXs8SexaWsxhlwXsaIGkVodcQU9edl9zPRJf1vRzghbvWfo3gQIvcZkIffSOUAnZ4iOcUW52qvSsygk1)cZcWyb4WcGzjalW1FMOHcpMYU(rvPuDM7tPmcxViwaml9yXkwuxTMrvdHG6f(mRiwuWIvSCUMQZGpF0Wb0qLRQjqw6BV5H7HL9wG0e(ExND9JQsP6Sp7yRK1yBD7nQCvnbAhd7TW8hnVBVHWN3v1KjaMdWc8Vhwz8zV5H7HL92xbFk)EyzF2Xwj0yBD7nQCvnbAhd7nyK9gMo7npCpSS3q4Z7QAYEdHRxK9MvSeGqni0szcE(RGzihmblDDSyfli85DvnzcWcbeikds4evGffSeGiOYRZupQ9l3CILUowaN1dAkyoaIT3ajCy(O7HL9gGO(8UQMyzHjqwGflU6R)7jml3UFSyXRJLdYIkXc2rqGS0GdlilMiXARalyil3UFSC7ucw8HQJflo(iqwaezHpwuPgCiwUDk1EdHp5Ytj7nSJGYn4KdE(RG9zhBLa02w3EJkxvtG2XWEZd3dl7T2AsKHTmPxfzVbs4W8r3dl7T4etywIdq0JLVXYxS4flOxq)ryIfVaz5MNWSCqw0FrS8hlRiwS83olj)sJ9bTSGSyIeRTcS4filXe0JUhbXYMfFsT3cZF08U9gf0FeMmFL9kblkyXJYHDkaelkyrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGwdayrbl9ybeEgh0JUhbLXw8jnd6PokYCFaOVqXsxhlwXsaIGkVotrHbQHdil9zrbli85DvnzWock3Gto45VcSOGLESOUAnZ4iOcUW52qvSsygk1)cZcWyb4WsYXspwqdlaplZQOgCqrg8xTLoVNaF08UHkxvtGS0NffSOUAnZ4iOcUW52qvSsywrS01XIvSOUAnZ4iOcUW52qvSsywrS03(SJTsasBRBVrLRQjq7yyV5H7HL9g(8P5AT9giHdZhDpSS3ItmXcG4IUDw2oFAUwZs0adyw(glBNpnxRz5Xf6owwr2BH5pAE3EtD1Agyr3oohrtGIUhwMvelkyrD1Ag85tZ1AZqTHW7UQMSp7yRuYyBD7nQCvnbAhd7TW8hnVBVPUAnd(8rdhqZqP(xywaglOHffS0Jf1vRzOG(JWugd1(ygk1)cZs8SGgw66yrD1AgkO)imL1RYhZqP(xywINf0WsFwuWIJVX15iOfAyjEwaoaWEZd3dl7TGxbsNvxTM9M6Q1YLNs2B4ZhnCaTp7yReWX262Bu5QAc0og2BE4EyzVHpFWRbfzVbs4W8r3dl7T44kncZsmXjplQudoelidwiGarSSWFHILBNybzWcbeiILaSa)7HflhKLWofaILVXcYGfciqelpMfpClxRtWIRcxhlhKfvILGJp7TW8hnVBVfGiOYRZupQ9l3CIffSGWN3v1KjaleqGOmiHtubwuWsac1GqlLjaleqGO8TtzC0p)HndL6FHzbySGgwuWIvSaoRh0uWCaeZIcwOG(JWK5RSxjyrblo(gxNJGwOHL4zXAaG9zhBacaBRBVrLRQjq7yyV5H7HL9g(8P5AT9giHdZhDpSS3ItmXY25tZ1AwS83olBhP1(WsCC(2XIxGSuqw2oF0WbeTSyzNkwkilBNpnxRz5XSSIqlljGlw8Hy5lwq)v5dlOxq)ryILgCyjzamMcywGdlhKLObgyj5xASpSyzNkwCvicIfGdayjM4KNf4WIdg53JGybBXNuw2DmljdGXuaZYqP(xFHIf4WYJz5lwA6h1(zyj2WJy529JLvbsdl3oXc2tjwcWc8Vhwyw(dDywaJWSu06gxZYbzz78P5AnlGR5luSaiWrqfCHzjomufReOLfl7uXsc4cDGSGVxRzHkqwwrSy5VDwaoaaWooILgCy52jw0o(ybLgQ6ASXElm)rZ72BNRP6m4J0AFYGZ3odvUQMazrblwXY5AQod(8rdhqdvUQMazrblQRwZGpFAUwBgQneE3v1elkyPhlQRwZqb9hHPSEv(ygk1)cZs8SKmSOGfkO)imz(kRxLpSOGf1vRzIMpfoGVRZ(e86d5OLg7JbHRxelaJfaIgaWsxhlQRwZenFkCaFxN9j41hYrln2hdcxViwIxzwaiAaalkyXX346Ce0cnSeplahaWsxhlGWZ4GE09iOm2IpPzqp1rrMHs9VWSepljdlDDS4H7HLXb9O7rqzSfFsZGEQJImFLB6h1(XsFwuWsac1GqlLj45VcMHs9VWSeplkba7Zo2aujBRBVrLRQjq7yyV5H7HL9g(8bVguK9giHdZhDpSS3ItmXY25dEnOiwaex0TZs0adyw8cKfWvAelXeN8SyzNkwqwmrI1wbwGdl3oXcGOuD7jgwuxTglpMfxfUowoilnxRzb2ASahwsaxOdKLGhXsmXjV9wy(JM3T3uxTMbw0TJZbn5tgXJFyzwrS01XI6Q1ma9f4qGzkncAHMuQUmv0G6JfzwrS01XI6Q1mbp)vWSIyrbl9yrD1AMXrqfCHZTHQyLWmuQ)fMfGXcQaOj1rolaplb61S0JfhFJRZrql0WcsyjUaGL(SaywIllaplNRP6mfzjNcHLHkxvtGSOGfRyzwf1GdkYG)QT059e4JM3nu5QAcKffSOUAnZ4iOcUW52qvSsywrS01XI6Q1mbp)vWmuQ)fMfGXcQaOj1rolaplb61S0JfhFJRZrql0WcsyjUaGL(S01XI6Q1mJJGk4cNBdvXkrg)vBPZ7jWhnVBwrS01XIvSOUAnZ4iOcUW52qvSsywrSOGfRyjaHAqOLYmocQGlCUnufReMHCWeS01XIvSeGiOYRZGGQBpXWsFw66yXX346Ce0cnSeplahaWIcwOG(JWK5RSxjSp7ydqaABD7nQCvnbAhd7npCpSS3WNp41GIS3ajCy(O7HL9M1NeSCqwsDGiwUDIfvcFSaBSSD(OHdilQjybFEaOVqXYFSSIyb4U(aq6eS8flELGf0lO)imXI66yj5xASpS846yXvHRJLdYIkXs0adbc0Elm)rZ72BNRP6m4ZhnCanu5QAcKffSyflZQOgCqrM7tjlWPYGd5PQFbsJHkxvtGSOGLESOUAnd(8rdhqZkILUowC8nUohbTqdlXZcWbaS0NffSOUAnd(8rdhqd(8aqSamwIllkyPhlQRwZqb9hHPmgQ9XSIyPRJf1vRzOG(JWuwVkFmRiw6ZIcwuxTMjA(u4a(Uo7tWRpKJwASpgeUErSamwaiGeaSOGLESeGqni0szcE(RGzOu)lmlXZIsaGLUowSIfe(8UQMmbyHaceLbjCIkWIcwcqeu51zQh1(LBoXsF7Zo2amU2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVrb9hHjZxz9Q8HfGNLKHfKWIhUhwg85t7hYqiNcRJY3NsSaywSIfkO)imz(kRxLpSa8S0JfanlaMLZ1uDgmCPZWw(2PCdoe(mu5QAcKfGNL4YsFwqclE4EyzSm(TBiKtH1r57tjwamlaWynOHfKWcoI068UJpIfaZcamOHfGNLZ1uDMYV1q4SQR9kqgQCvnbAVbs4W8r3dl7n0dFFQFeMLDOfwsxHDwIjo5zXhIfu(xeilr0WcMcWc0EdHp5Ytj7nhhL80Srb7Zo2a0ASTU9gvUQMaTJH9MhUhw2B4Zh8Aqr2BGeomF09WYEloUsJyz78bVguelFXIZcGeWykWYgu7dlOxq)rycTSacl0DSOPJL)yjAGbws(Lg7dl9UD)y5XSS7fOMazrnbl0F70WYTtSSD(0CTMf9xelWHLBNyjM4KpEGdayr)fXsdoSSD(GxdkQpAzbewO7ybIGglZFelEXcG4IUDwIgyGfVazrthl3oXIRcrqSO)Iyz3lqnXY25JgoG2BH5pAE3EZkwMvrn4GIm3NswGtLbhYtv)cKgdvUQMazrbl9yrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGasaWsxhlQRwZenFkCaFxN9j41hYrln2hdcxViwaglaenaGffSCUMQZGpsR9jdoF7mu5QAcKL(SOGLESqb9hHjZxzmu7dlkyXX346Ce0cnSaywq4Z7QAY44OKNMnkWcWZI6Q1muq)rykJHAFmdL6FHzbWSacptBnjYWwM0RIm3hacNhk1)IfGNfaAqdlXZsYaaw66yHc6pctMVY6v5dlkyXX346Ce0cnSaywq4Z7QAY44OKNMnkWcWZI6Q1muq)rykRxLpMHs9VWSaywaHNPTMezylt6vrM7daHZdL6FXcWZcanOHL4zb4aaw6ZIcwSIf1vRzGfD74Cenbk6EyzwrSOGfRy5CnvNbF(OHdOHkxvtGSOGLESeGqni0szcE(RGzOu)lmlXZcGKLUowWWLw9lqZTpVwNXebengQCvnbYIcwuxTM52NxRZyIaIgd(8aqSamwIBCzj5yPhlZQOgCqrg8xTLoVNaF08UHkxvtGSa8SGgw6ZIcwApQ9lpuQ)fML4zrjaaawuWs7rTF5Hs9VWSamwaiaaal9zrbl9yjaHAqOLYa0xGdbMXr)8h2muQ)fML4zbqYsxhlwXsaIGkVodqjM3lw6BF2XgGOX262Bu5QAc0og2BE4EyzVvKLCkew2BGeomF09WYEloXelacHWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3aCCyP1SaieclwAWHfKftKyTvGfVazbP0xGdbYc6LgbTqtkvN9wy(JM3T36XI6Q1muq)rykRxLpMHs9VWSepleYPW6O89PelDDS0JLWUpOimlkZcazrbldf29bfLVpLybySGgw6ZsxhlHDFqrywuML4YsFwuWIhLd7uaiwuWccFExvtgSJGYn4KdE(RG9zhBacOTTU9gvUQMaTJH9wy(JM3T36XI6Q1muq)rykRxLpMHs9VWSepleYPW6O89PelkyXkwcqeu51zakX8EXsxhl9yrD1AgG(cCiWmLgbTqtkvxMkAq9XImRiwuWsaIGkVodqjM3lw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr57tjwaglOHL(S01Xsy3hueMfLzjUS01XI6Q1mbp)vWSIyPplkyXJYHDkaelkybHpVRQjd2rq5gCYbp)vGffS0Jf1vRzghbvWfo3gQIvcZqP(xywagl9ybnSKCSaqwaEwMvrn4GIm4VAlDEpb(O5DdvUQMazPplkyrD1AMXrqfCHZTHQyLWSIyPRJfRyrD1AMXrqfCHZTHQyLWSIyPV9MhUhw2B7UULtHWY(SJnabK2w3EJkxvtG2XWElm)rZ72B9yrD1AgkO)imL1RYhZqP(xywINfc5uyDu((uIffSyflbicQ86maLyEVyPRJLESOUAndqFboeyMsJGwOjLQltfnO(yrMvelkyjarqLxNbOeZ7fl9zPRJLESe29bfHzrzwailkyzOWUpOO89PelaJf0WsFw66yjS7dkcZIYSexw66yrD1AMGN)kywrS0NffS4r5WofaIffSGWN3v1Kb7iOCdo5GN)kWIcw6XI6Q1mJJGk4cNBdvXkHzOu)lmlaJf0WIcwuxTMzCeubx4CBOkwjmRiwuWIvSmRIAWbfzWF1w68Ec8rZ7gQCvnbYsxhlwXI6Q1mJJGk4cNBdvXkHzfXsF7npCpSS3AlToNcHL9zhBaMm2w3EJkxvtG2XWEdKWH5JUhw2BXjMybPaIESalwcG2BE4EyzVzXN5Htg2YKEvK9zhBacCSTU9gvUQMaTJH9MhUhw2B4ZN2pK9giHdZhDpSS3ItmXY25t7hILdYs0adSSb1(Wc6f0FeMqllilMiXARal7oMfnHXSCFkXYT7flolifJF7SqiNcRJyrtTJf4WcS0jyb9xLpSGEb9hHjwEmlRi7TW8hnVBVrb9hHjZxz9Q8HLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JLUow6XI6Q1mw8zE4KHTmPxfzwrS01XcoI068UJpIfGXcamwdAyrblwXsaIGkVodcQU9edlDDSGJiToV74JybySaaJ1WIcwcqeu51zqq1TNyyPplkyrD1AgkO)imL1RYhZkILUow6XI6Q1mbp)vWmuQ)fMfGXIhUhwglJF7gc5uyDu((uIffSOUAntWZFfmRiw6BF2XoUaW262Bu5QAc0og2BGeomF09WYEloXelifJF7SaVDAS8yIfl7FyNLhZYxSSb1(Wc6f0FeMqllilMiXARalWHLdYs0adSG(RYhwqVG(JWK9MhUhw2Bwg)2Tp7yhxLSTU9gvUQMaTJH9giHdZhDpSS3IdUwF7ZYEZd3dl7TzvzpCpSY6hF2B6hF5Ytj7TMR13(SSp7ZElAOamv1pBRBhBLSTU9MhUhw2Ba9f4qGzC0p)HT3OYv1eODmSp7ydqBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS3aG9giHdZhDpSS3S(oXccFExvtS8ywW0XYbzbaSy5VDwkil4ZpwGfllmXYnFbeDy0YIsSyzNkwUDIL2p4JfyrS8ywGfllmHwwailFJLBNybtbybYYJzXlqwIllFJfv4TZIpK9gcFYLNs2BWkVWu(MVaIo7Zo2X1262Bu5QAc0og2BWi7nhe0EZd3dl7ne(8UQMS3q46fzVPK9wy(JM3T3U5lGOZCkzwyxvtSOGLB(ci6mNsMaeQbHwkd4A87HflkyXkwU5lGOZCkzES5GPug2YPWcFdCHZbyHVzfUhwy7ne(KlpLS3GvEHP8nFbeD2NDSTgBRBVrLRQjq7yyVbJS3Cqq7npCpSS3q4Z7QAYEdHRxK9gaT3cZF08U92nFbeDMdGMf2v1elky5MVaIoZbqtac1GqlLbCn(9WIffSyfl38fq0zoaAES5GPug2YPWcFdCHZbyHVzfUhwy7ne(KlpLS3GvEHP8nFbeD2NDSrJT1T3OYv1eODmS3Gr2BoiO9MhUhw2Bi85DvnzVHWNC5PK9gSYlmLV5lGOZElm)rZ72BeWD9rreO5lCywNRQPmWD51TsZGeIpqS01XcbCxFuebAO0Oed56mCalVcelDDSqa31hfrGgmCP10DFHkpl1e2BGeomF09WYEZ67eMy5MVaIoml(qSuWJfFDP(9bxRtWciDu4iqwCmlWILfMybF(XYnFbeDydlXuBXtGzXbb)cflkXsk5fMLBNsWILxRzX1w8eywujwIgQrZqGS8fifrfivhlWglyn8S3q46fzVPK9zhBaTT1T38W9WYElfclG(k3GtQ9gvUQMaTJH9zhBaPT1T3OYv1eODmS38W9WYEZY43U9M(lkhaT3uca2BH5pAE3ERhluq)ryYOxLp5Iq(Xsxhluq)ryY8vgd1(Wsxhluq)ryY8vwfE7S01Xcf0FeMmELixeYpw6BVbs4W8r3dl7TKFOGJpwailifJF7S4filolBNp41GIybwSSzDwS83olX(rTFSehCIfVazjgWyADwGdlBNpTFiwG3onwEmzF2XozSTU9gvUQMaTJH9wy(JM3T36Xcf0FeMm6v5tUiKFS01Xcf0FeMmFLXqTpS01Xcf0FeMmFLvH3olDDSqb9hHjJxjYfH8JL(SOGLOHqyuYyz8BNffSyflrdHWaqJLXVD7npCpSS3Sm(TBF2Xg4yBD7nQCvnbAhd7TW8hnVBVzflZQOgCqrgvx7vGYWw2168T)fkSHkxvtGS01XIvSeGiOYRZupQ9l3CILUowSIfCeP15Zhu0Hn4ZNMR1SOmlkXsxhlwXY5AQot53AiCw11EfidvUQMazPRJLESqb9hHjdgQ9jxeYpw66yHc6pctMVY6v5dlDDSqb9hHjZxzv4TZsxhluq)ryY4vICri)yPV9MhUhw2B4ZN2pK9zhBLaGT1T3OYv1eODmS3cZF08U92SkQbhuKr11EfOmSLDToF7FHcBOYv1eilkyjarqLxNPEu7xU5elkybhrAD(8bfDyd(8P5AnlkZIs2BE4EyzVHpFWRbfzF2N9zVHGg8dl7ydqaaqLaaGeajJ9MfFQVqHT3qkIjGGyBTXgPCaflSy9DILpncohln4Wc6aPMV0h6yziG76hcKfmmLyXxhm1pcKLWUxOiSHtc9)IyXAauSGmyHGMJazz7trgl4e15iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspLqEFdNe6)fXI1aOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPNsiVVHtc9)IybnakwqgSqqZrGSGUzvudoOitYIowoilOBwf1GdkYKSgQCvnbIow6PeY7B4Kq)Viwa0akwqgSqqZrGSS9PiJfCI6CKZcsLLdYc6VCwaFep(HflWiA8doS0dj9zPharEFdNe6)fXcGeqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspLqEFdNe6)fXcGeqXcYGfcAocKf0DZxarNrjtYIowoilO7MVaIoZPKjzrhl9aiY7B4Kq)ViwaKakwqgSqqZrGSGUB(ci6ma0KSOJLdYc6U5lGOZCa0KSOJLEae59nCsO)xeljdGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJLEkH8(goj0)lIfGdGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJLEkH8(goj0)lIfLaaGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJLEkH8(goj0)lIfLucqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspLqEFdNe6)fXIsaeqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspaI8(goj0)lIfLaiGIfKble0CeilO7MVaIoJsMKfDSCqwq3nFbeDMtjtYIow6bqK33WjH(FrSOeabuSGmyHGMJazbD38fq0zaOjzrhlhKf0DZxarN5aOjzrhl9uc59nCsO)xelkfxaflidwiO5iqwq3SkQbhuKjzrhlhKf0nRIAWbfzswdvUQMarhl9aiY7B4Kq)ViwukUakwqgSqqZrGSGUB(ci6mkzsw0XYbzbD38fq0zoLmjl6yPNsiVVHtc9)IyrP4cOybzWcbnhbYc6U5lGOZaqtYIowoilO7MVaIoZbqtYIow6bqK33WjXjHuetabX2AJns5akwyX67elFAeCowAWHf0fnuaMQ6h6yziG76hcKfmmLyXxhm1pcKLWUxOiSHtc9)IyjUakwqgSqqZrGSGUB(ci6mkzsw0XYbzbD38fq0zoLmjl6yPxCrEFdNe6)fXI1aOybzWcbnhbYc6U5lGOZaqtYIowoilO7MVaIoZbqtYIow6fxK33WjH(FrSaCauSGmyHGMJazbDZQOgCqrMKfDSCqwq3SkQbhuKjznu5QAceDS0tjK33WjH(FrSOeaauSGmyHGMJazbDZQOgCqrMKfDSCqwq3SkQbhuKjznu5QAceDS0tjK33WjXjHuetabX2AJns5akwyX67elFAeCowAWHf05qcDSmeWD9dbYcgMsS4RdM6hbYsy3lue2WjH(FrSOeGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJf)yb9aeJ(S0tjK33WjH(FrSexaflidwiO5iqwq3SkQbhuKjzrhlhKf0nRIAWbfzswdvUQMarhl9uc59nCsO)xelaAaflidwiO5iqw2(uKXcorDoYzbPIuz5GSG(lNLui4sVWSaJOXp4WspKAFw6PeY7B4Kq)Viwa0akwqgSqqZrGSGUzvudoOitYIowoilOBwf1GdkYKSgQCvnbIow6bqK33WjH(FrSaibuSGmyHGMJazz7trgl4e15iNfKksLLdYc6VCwsHGl9cZcmIg)Gdl9qQ9zPNsiVVHtc9)IybqcOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPNsiVVHtc9)IyjzauSGmyHGMJazbDZQOgCqrMKfDSCqwq3SkQbhuKjznu5QAceDS0tjK33WjH(FrSaCauSGmyHGMJazz7trgl4e15iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspaI8(goj0)lIfLaiGIfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6PeY7B4Kq)Viwuc4aOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPNsiVVHtc9)IybGkbOybzWcbnhbYY2NImwWjQZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEkH8(goj0)lIfagxaflidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0dGiVVHtc9)IybGXfqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspLqEFdNe6)fXcardGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJLEkH8(goj0)lIfacObuSGmyHGMJazbDZQOgCqrMKfDSCqwq3SkQbhuKjznu5QAceDS0tjK33WjH(FrSaWKbqXcYGfcAocKLTpfzSGtuNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9aiY7B4Kq)ViwaiWbqXcYGfcAocKLTpfzSGtuNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9uc59nCsCsifXeqqST2yJuoGIfwS(oXYNgbNJLgCybDnxRV9zHowgc4U(Hazbdtjw81bt9JazjS7fkcB4Kq)ViwaiGIfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6PeY7B4K4KqkIjGGyBTXgPCaflSy9DILpncohln4Wc6Wh6yziG76hcKfmmLyXxhm1pcKLWUxOiSHtc9)IyrjaflidwiO5iqwq3SkQbhuKjzrhlhKf0nRIAWbfzswdvUQMarhl9uc59nCsO)xelXfqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspLqEFdNe6)fXIskbOybzWcbnhbYY2NImwWjQZrolivKklhKf0F5SKcbx6fMfyen(bhw6Hu7ZspLqEFdNe6)fXIskbOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPNsiVVHtc9)IyrjanGIfKble0CeilOBwf1GdkYKSOJLdYc6Mvrn4GImjRHkxvtGOJLEkH8(goj0)lIfaQeGIfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6bqK33WjH(FrSaqLauSGmyHGMJazbDZQOgCqrMKfDSCqwq3SkQbhuKjznu5QAceDS0tjK33WjH(FrSaqacOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPNsiVVHtc9)IybGXfqXcYGfcAocKLTpfzSGtuNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9IlY7B4Kq)ViwaO1aOybzWcbnhbYc6Mvrn4GImjl6y5GSGUzvudoOitYAOYv1ei6yPharEFdNe6)fXcab0akwqgSqqZrGSGUzvudoOitYIowoilOBwf1GdkYKSgQCvnbIow6PeY7B4Kq)ViwaiGeqXcYGfcAocKf0nRIAWbfzsw0XYbzbDZQOgCqrMK1qLRQjq0XspLqEFdNeNesrmbeeBRn2iLdOyHfRVtS8PrW5yPbhwqNk0p0XYqa31peilyykXIVoyQFeilHDVqrydNe6)fXIsjdGIfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6fxK33WjH(FrSOeWbqXcYGfcAocKLTpfzSGtuNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9uc59nCsCswBAeCocKfanlE4EyXI(Xh2WjzVHJOGDSvcaa0ElAGTxt2BinsZsmCTxbIL44SEqojKgPzjPLobljdAzbGaaGkXjXjH0inliB3luegqXjH0inljhlXeeKazzdQ9HLyqEQHtcPrAwsowq2UxOiqwoFqrx(BSeCmHz5GSese0u(8bfDydNesJ0SKCSaiGsHiiqwwvrbcJ9jbli85DvnHzP3BidAzjAiez85dEnOiwsU4zjAieg85dEnOO(gojKgPzj5yjMiGpilrdfC89fkwqkg)2z5BS8h6WSC7elwgyHIf0lO)imz4KqAKMLKJfaHoqelidwiGarSC7elBr)8hMfNf9FNMyjfoelnnH8xvtS07BSKaUyz3bl0DSS)hl)Xc(tx6ZlcUW6eSy5VDwIbG4yADwamliJ0e(ExZsm1pQkLQdTS8h6azbd0h13WjH0inljhlacDGiwsH4Jf01Eu7xEOu)lm6ybhOYNhIzXJI0jy5GSOcXywApQ9dZcS0jmCsinsZsYXI1hYpwSomLyb2yjgAFNLyO9DwIH23zXXS4SGJOW7AwU5lGOZWjXjH0inlXSk45hbYsmCTxbILyM8OplbVyrLyPbxfil(XY(DryafsqIQR9kqjh(tdgu)TVunpejXW1EfOKB7trgssbn7xQgPSTxtkR6AVcK5q(XjXj5H7Hf2enuaMQ6NYa9f4qGzC0p)H5KqAwS(oXccFExvtS8ywW0XYbzbaSy5VDwkil4ZpwGfllmXYnFbeDy0YIsSyzNkwUDIL2p4JfyrS8ywGfllmHwwailFJLBNybtbybYYJzXlqwIllFJfv4TZIpeNKhUhwyt0qbyQQFawzKGWN3v1eAlpLugw5fMY38fq0HweUErkdaojpCpSWMOHcWuv)aSYibHpVRQj0wEkPmSYlmLV5lGOdTWiLDqq0IW1lszLq73u(MVaIoJsMf2v1KIB(ci6mkzcqOgeAPmGRXVhwkS6MVaIoJsMhBoykLHTCkSW3ax4Caw4BwH7HfMtYd3dlSjAOamv1paRmsq4Z7QAcTLNskdR8ct5B(ci6qlmszheeTiC9IugGO9BkFZxarNbGMf2v1KIB(ci6ma0eGqni0szaxJFpSuy1nFbeDgaAES5GPug2YPWcFdCHZbyHVzfUhwyojKMfRVtyILB(ci6WS4dXsbpw81L63hCToblG0rHJazXXSalwwyIf85hl38fq0HnSetTfpbMfhe8luSOelPKxywUDkblwETMfxBXtGzrLyjAOgndbYYxGuevGuDSaBSG1WJtYd3dlSjAOamv1paRmsq4Z7QAcTLNskdR8ct5B(ci6qlmszheeTiC9Iuwj0(nLjG76JIiqZx4WSoxvtzG7YRBLMbjeFG66iG76JIiqdLgLyixNHdy5vG66iG76JIiqdgU0A6UVqLNLAcojpCpSWMOHcWuv)aSYijfclG(k3GtkNesZsYpuWXhlaKfKIXVDw8cKfNLTZh8AqrSalw2Solw(BNLy)O2pwIdoXIxGSedymTolWHLTZN2pelWBNglpM4K8W9WcBIgkatv9dWkJelJF7Ov)fLdGkReaq73uUhf0FeMm6v5tUiKFDDuq)ryY8vgd1(01rb9hHjZxzv4T31rb9hHjJxjYfH8RpNKhUhwyt0qbyQQFawzKyz8BhTFt5Euq)ryYOxLp5Iq(11rb9hHjZxzmu7txhf0FeMmFLvH3Exhf0FeMmELixeYV(kIgcHrjJLXVDfwfnecdanwg)25K8W9WcBIgkatv9dWkJe85t7hcTFtzRMvrn4GImQU2RaLHTSR15B)lu4UoRcqeu51zQh1(LBo11zfoI0685dk6Wg85tZ1ALvQRZQZ1uDMYV1q4SQR9kqgQCvnb211Jc6pctgmu7tUiKFDDuq)ryY8vwVkF66OG(JWK5RSk8276OG(JWKXRe5Iq(1NtYd3dlSjAOamv1paRmsWNp41GIq73uEwf1GdkYO6AVcug2YUwNV9VqHveGiOYRZupQ9l3CsboI0685dk6Wg85tZ1ALvItItcPrAwqpKtH1rGSqiOjbl3NsSC7elE4GdlpMfhH)AxvtgojpCpSWkJHAFYQKNYjH0SSrhMLycrpwGflXfWSy5VD46ybC(2XIxGSy5VDw2oF0WbKfVazbGaMf4TtJLhtCsE4EyHbSYibHpVRQj0wEkP8JZoKqlcxViLXrKwNpFqrh2GpFAUwhVsk6z15AQod(8rdhqdvUQMa76oxt1zWhP1(KbNVDgQCvnb2VRdhrAD(8bfDyd(8P5AD8aKtcPzzJomlbn5iiwSStflBNpTFiwcEXY(FSaqaZY5dk6WSyz)d7S8ywgsti86yPbhwUDIf0lO)imXYbzrLyjAOgndbYIxGSyz)d7S0ETMgwoilbhFCsE4EyHbSYibHpVRQj0wEkP8JZbn5ii0IW1lszCeP15Zhu0Hn4ZN2pu8kXjH0SeNyILyqdMgG(cflw(BNfKftKyTvGf4WI3oAybzWcbeiILVybzXejwBf4K8W9WcdyLrIknyAa6luO9Bk3ZQaebvEDM6rTF5MtDDwfGqni0szcWcbeikF7ugh9ZFyZkQVc1vRzcE(RGzOu)lC8kHgfQRwZmocQGlCUnufReMHs9VWaZAuyvaIGkVodcQU9etxxaIGkVodcQU9eJc1vRzcE(RGzfPqD1AMXrqfCHZTHQyLWSIu0tD1AMXrqfCHZTHQyLWmuQ)fgykPuYHgGFwf1GdkYG)QT059e4JM376uxTMj45VcMHs9VWatjL66ucPIJiToV74JaMsg0GM(Csinljp8yXYF7S4SGSyIeRTcSC7(XYJl0DS4SK8ln2hwIgyGf4WILDQy52jwApQ9JLhZIRcxhlhKfQa5K8W9WcdyLrse8EyH2VPS6Q1mbp)vWmuQ)foELqJIEwnRIAWbfzWF1w68Ec8rZ7DDQRwZmocQGlCUnufReMHs9VWatjaPc1vRzghbvWfo3gQIvcZkQFxNkeJv0Eu7xEOu)lmWaiA4KqAwqMRdlTFeMfl70Ttdll8xOybzWcbeiILcAHflVwZIR1qlSKaUy5GSGVxRzj44JLBNyb7PelEkCvhlWglidwiGaragzXejwBfyj44dZj5H7HfgWkJee(8UQMqB5PKYbyHaceLbjCIkGweUErkhOx3Rx7rTF5Hs9VWjNsOj5cqOgeAPmbp)vWmuQ)fUpsvPKba9voqVUxV2JA)YdL6FHtoLqtYPeabqYfGqni0szcWcbeikF7ugh9ZFyZqP(x4(ivLsga0xHvJ)GzcbvNXbbXgc5p(WDDbiudcTuMGN)kygk1)ch)xhnrqTFeyU9O2V8qP(x4UUaeQbHwktawiGar5BNY4OF(dBgk1)ch)xhnrqTFeyU9O2V8qP(x4Ktja01zvaIGkVot9O2VCZPUopCpSmbyHaceLVDkJJ(5pSb8XUQMa5KqAwItmbYYbzbK0EcwUDILf2rrSaBSGSyIeRTcSyzNkww4VqXciCPQjwGfllmXIxGSenecQowwyhfXILDQyXlwCqqwieuDS8ywCv46y5GSa(eNKhUhwyaRmsq4Z7QAcTLNskhaZbyb(3dl0IW1ls5ENpOOZCFkLpyg8P4vcnDDJ)GzcbvNXbbXMVIhnaOVIE96ra31hfrGgknkXqUodhWYRaPOxVaeQbHwkdLgLyixNHdy5vGmdL6FHbMsaAa01fGiOYRZGGQBpXOiaHAqOLYqPrjgY1z4awEfiZqP(xyGPeGgqc4EkPeWpRIAWbfzWF1w68Ec8rZ797RWQaeQbHwkdLgLyixNHdy5vGmd5Gj63VRRhbCxFuebAWWLwt39fQ8SutOONvbicQ86m1JA)YnN66cqOgeAPmy4sRP7(cvEwQjYX1AqtYaaLmdL6FHbMskzn97311laHAqOLYOsdMgG(cLzihmrxNvJhiZnqTUVIE9iG76JIiqZx4WSoxvtzG7YRBLMbjeFGueGqni0sz(chM15QAkdCxEDR0miH4dKzihmr)UUE9q4Z7QAYaR8ct5B(ci6uwPUoe(8UQMmWkVWu(MVaIoLJBFf9U5lGOZOKzihmroaHAqOLQR7MVaIoJsMaeQbHwkZqP(x44)6OjcQ9JaZTh1(Lhk1)cNCkbG(DDi85DvnzGvEHP8nFbeDkdqf9U5lGOZaqZqoyICac1Gqlvx3nFbeDgaAcqOgeAPmdL6FHJ)RJMiO2pcm3Eu7xEOu)lCYPea631HWN3v1Kbw5fMY38fq0Pma63VFxxaIGkVodqjM3R(DDQqmwr7rTF5Hs9VWatD1AMGN)kyaxJFpS4K8W9WcdyLrccFExvtOT8us5BFEToJjciAYw8)qlcxViLTcdxA1Van3(8ADgteq0yOYv1eyxx7rTF5Hs9VWXdqaaGUovigRO9O2V8qP(xyGbq0a4Ewdaso1vRzU9516mMiGOXGppaeWdW(DDQRwZC7ZR1zmrarJbFEaO4JBYKC9Mvrn4GIm4VAlDEpb(O5DGhn95KqAwItmXc6LgLyixZcG4bS8kqSaqaGPaMfvQbhIfNfKftKyTvGLfMmCsE4EyHbSYizHP8FukAlpLuMsJsmKRZWbS8kqO9BkhGqni0szcE(RGzOu)lmWaiaueGqni0szcWcbeikF7ugh9ZFyZqP(xyGbqaOOhcFExvtMBFEToJjciAYw8)66uxTM52NxRZyIaIgd(8aqXhxaa4EZQOgCqrg8xTLoVNaF08oWdO73VRtfIXkApQ9lpuQ)fgyXfqYjH0SeNyILn4sRP7luSaiyPMGfanMcywuPgCiwCwqwmrI1wbwwyYWj5H7HfgWkJKfMY)rPOT8uszmCP10DFHkpl1eO9BkhGqni0szcE(RGzOu)lmWa0kSkarqLxNbbv3EIrHvbicQ86m1JA)YnN66cqeu51zQh1(LBoPiaHAqOLYeGfciqu(2Pmo6N)WMHs9VWadqROhcFExvtMaSqabIYGeorf66cqOgeAPmbp)vWmuQ)fgya6(DDbicQ86miO62tmk6z1SkQbhuKb)vBPZ7jWhnVRiaHAqOLYe88xbZqP(xyGbO76uxTMzCeubx4CBOkwjmdL6FHbMswdG7HgGNaURpkIanFHVzfo4GZGpIVOSkP19vOUAnZ4iOcUW52qvSsywr976uHySI2JA)YdL6FHbgardNKhUhwyaRmswyk)hLI2YtjL)chM15QAkdCxEDR0miH4deA)MYQRwZe88xbZqP(x44vcnk6z1SkQbhuKb)vBPZ7jWhnV31PUAnZ4iOcUW52qvSsygk1)cdmLaiG7fxGxD1AgvnecQx4ZSI6d4E9aKjhAaE1vRzu1qiOEHpZkQpWta31hfrGMVW3SchCWzWhXxuwL06(kuxTMzCeubx4CBOkwjmRO(DDQqmwr7rTF5Hs9VWadGOHtcPzX67pMLhZIZY43onSqAxfo(rSyXtWYbzj1bIyX1AwGfllmXc(8JLB(ci6WSCqwujw0FrGSSIyXYF7SGSyIeRTcS4filidwiGarS4fillmXYTtSaWcKfSgESalwcGS8nwuH3ol38fq0HzXhIfyXYctSGp)y5MVaIomNKhUhwyaRmswyk)hLIrlwdpSY38fq0PeA)MYi85DvnzGvEHP8nFbeDkdqfwDZxarNbGMHCWe5aeQbHwQUUEi85DvnzGvEHP8nFbeDkRuxhcFExvtgyLxykFZxarNYXTVIEQRwZe88xbZksrpRcqeu51zqq1TNy66uxTMzCeubx4CBOkwjmdL6FHbCp0a8ZQOgCqrg8xTLoVNaF08EFGP8nFbeDgLmQRwldUg)EyPqD1AMXrqfCHZTHQyLWSI66uxTMzCeubx4CBOkwjY4VAlDEpb(O5DZkQFxxac1GqlLj45VcMHs9VWagGXFZxarNrjtac1GqlLbCn(9WsHvQRwZe88xbZksrpRcqeu51zQh1(LBo11zfcFExvtMaSqabIYGeorf6RWQaebvEDgGsmVxDDbicQ86m1JA)YnNuGWN3v1KjaleqGOmiHtubfbiudcTuMaSqabIY3oLXr)8h2SIuyvac1GqlLj45VcMvKIE9uxTMHc6pctz9Q8XmuQ)foELaqxN6Q1muq)rykJHAFmdL6FHJxja0xHvZQOgCqrgvx7vGYWw2168T)fkCxxp1vRzuDTxbkdBzxRZ3(xOW5YV1qg85bGugnDDQRwZO6AVcug2YUwNV9VqHZ(e8Im4ZdaPCY0VFxN6Q1ma9f4qGzkncAHMuQUmv0G6Jfzwr976ApQ9lpuQ)fgyaeaDDi85DvnzGvEHP8nFbeDkdaojpCpSWawzKSWu(pkfJwSgEyLV5lGOdGO9BkJWN3v1Kbw5fMY38fq0zLYauHv38fq0zuYmKdMihGqni0s11HWN3v1Kbw5fMY38fq0Pmav0tD1AMGN)kywrk6zvaIGkVodcQU9etxN6Q1mJJGk4cNBdvXkHzOu)lmG7HgGFwf1GdkYG)QT059e4JM37dmLV5lGOZaqJ6Q1YGRXVhwkuxTMzCeubx4CBOkwjmROUo1vRzghbvWfo3gQIvIm(R2sN3tGpAE3SI631fGqni0szcE(RGzOu)lmGby838fq0zaOjaHAqOLYaUg)EyPWk1vRzcE(RGzfPONvbicQ86m1JA)YnN66ScHpVRQjtawiGarzqcNOc9vyvaIGkVodqjM3lf9SsD1AMGN)kywrDDwfGiOYRZGGQBpX0VRlarqLxNPEu7xU5Kce(8UQMmbyHaceLbjCIkOiaHAqOLYeGfciqu(2Pmo6N)WMvKcRcqOgeAPmbp)vWSIu0RN6Q1muq)rykRxLpMHs9VWXRea66uxTMHc6pctzmu7JzOu)lC8kbG(kSAwf1GdkYO6AVcug2YUwNV9VqH766PUAnJQR9kqzyl7AD(2)cfox(TgYGppaKYOPRtD1Agvx7vGYWw2168T)fkC2NGxKbFEaiLtM(9731PUAndqFboeyMsJGwOjLQltfnO(yrMvuxx7rTF5Hs9VWadGaORdHpVRQjdSYlmLV5lGOtzaWjH0SeNycZIR1SaVDAybwSSWel)rPywGflbqojpCpSWawzKSWu(pkfZjH0SehPWdsS4H7Hfl6hFSO6ycKfyXc(VLFpSqIMq9yojpCpSWawzKmRk7H7Hvw)4dTLNsk7qcT4B(WPSsO9BkJWN3v1K5XzhsCsE4EyHbSYizwv2d3dRS(XhAlpLuwf6hAX38HtzLq73uEwf1GdkYO6AVcug2YUwNV9VqHneWD9rreiNKhUhwyaRmsMvL9W9WkRF8H2YtjLXhNeNesZcYCDyP9JWSyzNUDAy52jwIJd5Pb)c70WI6Q1yXYR1S0CTMfyRXIL)2)ILBNyPiKFSeC8Xj5H7Hf24qsze(8UQMqB5PKYGd5PzlVwNBUwNHTgAr46fPCp1vRzUpLSaNkdoKNQ(finMHs9VWadva0K6ihWaWOuxN6Q1m3NswGtLbhYtv)cKgZqP(xyG5H7HLbF(0(HmeYPW6O89PeGbGrjf9OG(JWK5RSEv(01rb9hHjdgQ9jxeYVUokO)imz8krUiKF97RqD1AM7tjlWPYGd5PQFbsJzfPywf1GdkYCFkzbovgCipv9lqA4KqAwqMRdlTFeMfl70TtdlBNp41GIy5XSybo3olbhFFHIficAyz78P9dXYxSG(RYhwqVG(JWeNKhUhwyJdjaRmsq4Z7QAcTLNsk)Ok4qz85dEnOi0IW1lszROG(JWK5RmgQ9rrpCeP15Zhu0Hn4ZN2pu8OrX5AQodgU0zylF7uUbhcFgQCvnb21HJiToF(GIoSbF(0(HIhq2NtcPzjoXelidwiGarSyzNkw8JfnHXSC7EXcAaalXeN8S4fil6ViwwrSy5VDwqwmrI1wbojpCpSWghsawzKeGfciqu(2Pmo6N)WO9BkBf4SEqtbZbqSIE9q4Z7QAYeGfciqugKWjQGcRcqOgeAPmbp)vWmKdMORtD1AMGN)kywr9v0tD1AgkO)imL1RYhZqP(x44b0DDQRwZqb9hHPmgQ9XmuQ)foEaDFf9SAwf1GdkYO6AVcug2YUwNV9VqH76uxTMr11EfOmSLDToF7FHcNl)wdzWNhak(421PUAnJQR9kqzyl7AD(2)cfo7tWlYGppau8XTFxNkeJv0Eu7xEOu)lmWucakSkaHAqOLYe88xbZqoyI(CsinlXjMyjomufReSy5VDwqwmrI1wbojpCpSWghsawzKmocQGlCUnufReO9BkRUAntWZFfmdL6FHJxj0WjH0SeNyILTv1(Hy5lwI8cKs)alWIfVsC7FHILB3pw0pccZIswdMcyw8cKfnHXSy5VDwsHdXY5dk6WS4fil(XYTtSqfilWglolBqTpSGEb9hHjw8JfLSgwWuaZcCyrtymldL6F9fkwCmlhKLcESS7i(cflhKLHAdH3zbCnFHIf0Fv(Wc6f0FeM4K8W9WcBCibyLrcEvTFi0gse0u(8bfDyLvcTFt5Ed1gcV7QAQRtD1AgkO)imLXqTpMHs9VWalUkOG(JWK5RmgQ9rXqP(xyGPK1O4CnvNbdx6mSLVDk3GdHpdvUQMa7R48bfDM7tP8bZGpfVswtYHJiToF(GIomGhk1)cROhf0FeMmFL9krx3qP(xyGHkaAsDK3NtcPzbPerrSSIyz78P5Anl(XIR1SCFkHzzvAcJzzH)cflOFIGpoMfVaz5pwEmlUkCDSCqwIgyGf4WIMowUDIfCefExZIhUhwSO)IyrL0qlSS7fOMyjooKNQ(finSalwailNpOOdZj5H7Hf24qcWkJe85tZ1A0(nLT6CnvNbFKw7tgC(2zOYv1eOIEQRwZGpFAUwBgQneE3v1KIE4isRZNpOOdBWNpnxRbwC76SAwf1GdkYCFkzbovgCipv9lqA631DUMQZGHlDg2Y3oLBWHWNHkxvtGkuxTMHc6pctzmu7JzOu)lmWIRckO)imz(kJHAFuOUAnd(8P5ATzOu)lmWaKkWrKwNpFqrh2GpFAUwhVYwtFf9SAwf1GdkYOte8XX5MMO7luzu6pnctDD3NsivKQ1GM4vxTMbF(0CT2muQ)fgWaSVIZhu0zUpLYhmd(u8OHtcPzbP4VDw2osR9HL448TJLfMybwSeazXYovSmuBi8URQjwuxhl471AwS4)XsdoSG(jc(4ywIgyGfVazbewO7yzHjwuPgCiwqwCeByz7ETMLfMyrLAWHybzWcbeiIf8xbILB3pwS8AnlrdmWIxWBNgw2oFAUwZj5H7Hf24qcWkJe85tZ1A0(nLpxt1zWhP1(KbNVDgQCvnbQqD1Ag85tZ1AZqTHW7UQMu0ZQzvudoOiJorWhhNBAIUVqLrP)0im11DFkHurQwdAI3A6R48bfDM7tP8bZGpfFC5KqAwqk(BNL44qEQ6xG0WYctSSD(0CTMLdYcqefXYkILBNyrD1ASOMGfxJHSSWFHILTZNMR1SalwqdlykalqmlWHfnHXSmuQ)1xO4K8W9WcBCibyLrc(8P5AnA)MYZQOgCqrM7tjlWPYGd5PQFbsJcCeP15Zhu0Hn4ZNMR1XRCCv0Zk1vRzUpLSaNkdoKNQ(finMvKc1vRzWNpnxRnd1gcV7QAQRRhcFExvtgWH80SLxRZnxRZWwtrp1vRzWNpnxRndL6FHbwC76WrKwNpFqrh2GpFAUwhpavCUMQZGpsR9jdoF7mu5QAcuH6Q1m4ZNMR1MHs9VWadn973NtcPzbzUoS0(rywSSt3onS4SSD(GxdkILfMyXYR1Se8fMyz78P5AnlhKLMR1SaBn0YIxGSSWelBNp41GIy5GSaerrSehhYtv)cKgwWNhaILveNKhUhwyJdjaRmsq4Z7QAcTLNskJpFAUwNTaRl3CTodBn0IW1lszhFJRZrql0eFYaGKRNsaa4vxTM5(uYcCQm4qEQ6xG0yWNhaQFY1tD1Ag85tZ1AZqP(xyGpUivCeP15DhFeWB15AQod(iT2Nm48TZqLRQjW(jxVaeQbHwkd(8P5ATzOu)lmWhxKkoI068UJpc4pxt1zWhP1(KbNVDgQCvnb2p56bcptBnjYWwM0RImdL6FHbE00xrp1vRzWNpnxRnROUUaeQbHwkd(8P5ATzOu)lCFojKML4etSSD(GxdkIfl)TZsCCipv9lqAy5GSaerrSSIy52jwuxTglw(BhUow0q8xOyz78P5AnlRO7tjw8cKLfMyz78bVguelWIfRbWSedymTol4ZdaHzzv3RzXAy58bfDyojpCpSWghsawzKGpFWRbfH2VPmcFExvtgWH80SLxRZnxRZWwtbcFExvtg85tZ16SfyD5MR1zyRPWke(8UQMmpQcougF(GxdkQRRN6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqXh3Uo1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGIpU9vGJiToF(GIoSbF(0CTgywJce(8UQMm4ZNMR1zlW6YnxRZWwJtcPzjoXelyl(KYcgYYT7hljGlwqrhlPoYzzfDFkXIAcww4VqXYFS4yw0(rS4ywIGy8RQjwGflAcJz529IL4Yc(8aqywGdlaISWhlw2PIL4cywWNhacZcH8OFiojpCpSWghsawzK4GE09iOm2IpPOnKiOP85dk6WkReA)MYwDFaOVqPWkpCpSmoOhDpckJT4tAg0tDuK5RCt)O2VUoq4zCqp6EeugBXN0mON6Oid(8aqalUkaHNXb9O7rqzSfFsZGEQJImdL6FHbwC5KqAwaeqTHW7SaiecR2pelFJfKftKyTvGLhZYqoyc0YYTtdXIpelAcJz529If0WY5dk6WS8flO)Q8Hf0lO)imXIL)2zzdEXb0YIMWywUDVyrjaWc82PXYJjw(IfVsWc6f0FeMyboSSIy5GSGgwoFqrhMfvQbhIfNf0Fv(Wc6f0FeMmSehHf6owgQneENfW18fkwqk9f4qGSGEPrql0Ks1XYQ0egZYxSSb1(Wc6f0FeM4K8W9WcBCibyLrskewTFi0gse0u(8bfDyLvcTFt5HAdH3DvnP48bfDM7tP8bZGpfFVEkznaUhoI0685dk6Wg85t7hc4biWRUAndf0FeMY6v5Jzf1VpGhk1)c3hP2tjaFUMQZCw(kNcHf2qLRQjW(k6fGqni0szcE(RGzihmHcRaN1dAkyoaIv0dHpVRQjtawiGarzqcNOcDDbiudcTuMaSqabIY3oLXr)8h2mKdMORZQaebvEDM6rTF5Mt976WrKwNpFqrh2GpFA)qaRxpaDY1tD1AgkO)imL1RYhZkc4by)(aFpLa85AQoZz5RCkewydvUQMa73xHvuq)ryYGHAFYfH8RRRhf0FeMmFLXqTpDD9OG(JWK5RSk8276OG(JWK5RSEv(0xHvNRP6my4sNHT8Tt5gCi8zOYv1eyxN6Q1mrZNchW31zFcE9HC0sJ9XGW1lkELbiAaqFf9WrKwNpFqrh2GpFA)qatjaa89ucWNRP6mNLVYPqyHnu5QAcSFFfo(gxNJGwOjE0aGKtD1Ag85tZ1AZqP(xyGhq3xrpRuxTMbOVahcmtPrql0Ks1LPIguFSiZkQRJc6pctMVYyO2NUoRcqeu51zakX8E1xHvQRwZmocQGlCUnufRez8xTLoVNaF08UzfXjH0SeNyIL4am2SalwcGSy5VD46yj4rrFHItYd3dlSXHeGvgjn4eOmSLl)wdH2VPShLd7uaiojpCpSWghsawzKGWN3v1eAlpLuoaMdWc8VhwzhsOfHRxKYwboRh0uWCaeRaHpVRQjtamhGf4FpSu0RN6Q1m4ZNMR1Mvux35AQod(iT2Nm48TZqLRQjWUUaebvEDM6rTF5Mt9v0Zk1vRzWqn((azwrkSsD1AMGN)kywrk6z15AQotBnjYWwM0RImu5QAcSRtD1AMGN)kyaxJFpSIpaHAqOLY0wtImSLj9QiZqP(xyaNm9vGWN3v1K52NxRZyIaIMSf)pf9SkarqLxNPEu7xU5uxxac1GqlLjaleqGO8TtzC0p)HnRif9uxTMbF(0CT2muQ)fgyaSRZQZ1uDg8rATpzW5BNHkxvtG97R48bfDM7tP8bZGpfV6Q1mbp)vWaUg)Eyb8aWai7311Eu7xEOu)lmWuxTMj45VcgW143dR(CsinlXjMybzXejwBfybwSeazzvAcJzXlqw0FrS8hlRiwS83olidwiGarCsE4EyHnoKaSYijqAcFVRZU(rvPuDO9BkJWN3v1KjaMdWc8VhwzhsCsE4EyHnoKaSYi5RGpLFpSq73ugHpVRQjtamhGf4FpSYoK4KqAwItmXc6LgbTqdlXawGSalwcGSy5VDw2oFAUwZYkIfVazb7iiwAWHLKFPX(WIxGSGSyIeRTcCsE4EyHnoKaSYiHsJGwOjRclq0(nLvHySIVoAIGA)iWC7rTF5Hs9VWatj0011tD1AMO5tHd476SpbV(qoAPX(yq46fbmaIga01PUAnt08PWb8DD2NGxFihT0yFmiC9IIxzaIga0xH6Q1m4ZNMR1MvKIEbiudcTuMGN)kygk1)chpAaqxh4SEqtbZbqCFojKMfabuBi8olnTpelWILvelhKL4YY5dk6WSy5VD46ybzXejwBfyrL(cflUkCDSCqwiKh9dXIxGSuWJficAcEu0xO4K8W9WcBCibyLrc(iT2NCt7dH2qIGMYNpOOdRSsO9BkpuBi8URQjf3Ns5dMbFkELqJcCeP15Zhu0Hn4ZN2peWSgfEuoStbGu0tD1AMGN)kygk1)chVsaORZk1vRzcE(RGzf1NtcPzjoXelXbi6XY3y5l8dsS4flOxq)ryIfVazr)fXYFSSIyXYF7S4SK8ln2hwIgyGfVazjMGE09iiw2S4tkNKhUhwyJdjaRmsARjrg2YKEveA)MYuq)ryY8v2Rek8OCyNcaPqD1AMO5tHd476SpbV(qoAPX(yq46fbmaIgaOOhi8moOhDpckJT4tAg0tDuK5(aqFHQRZQaebvEDMIcdudhWUoCeP15Zhu0HJhG9v0tD1AMXrqfCHZTHQyLWmuQ)fgyaNKRhAa(zvudoOid(R2sN3tGpAEVVc1vRzghbvWfo3gQIvcZkQRZk1vRzghbvWfo3gQIvcZkQVIEwfGqni0szcE(RGzf11PUAnZTpVwNXebeng85bGaMsOrr7rTF5Hs9VWadGaaakApQ9lpuQ)foELaaa66ScdxA1Van3(8ADgteq0yOYv1eyFf9WWLw9lqZTpVwNXebengQCvnb21fGqni0szcE(RGzOu)lC8Xfa95KqAwItmXIZY25tZ1Awaex0TZs0adSSknHXSSD(0CTMLhZIRhYbtWYkIf4Wsc4IfFiwCv46y5GSarqtWJyjM4KNtYd3dlSXHeGvgj4ZNMR1O9BkRUAndSOBhNJOjqr3dlZksrp1vRzWNpnxRnd1gcV7QAQRZX346Ce0cnXdCaqFojKML44knILyItEwuPgCiwqgSqabIyXYF7SSD(0CTMfVaz52PILTZh8AqrCsE4EyHnoKaSYibF(0CTgTFt5aebvEDM6rTF5MtkS6CnvNbFKw7tgC(2zOYv1eOIEi85DvnzcWcbeikds4evORlaHAqOLYe88xbZkQRtD1AMGN)kywr9veGqni0szcWcbeikF7ugh9ZFyZqP(xyGHkaAsDKd8b619C8nUohbTqdsfnaOVc1vRzWNpnxRndL6FHbM1OWkWz9GMcMdGyojpCpSWghsawzKGpFWRbfH2VPCaIGkVot9O2VCZjf9q4Z7QAYeGfciqugKWjQqxxac1GqlLj45VcMvuxN6Q1mbp)vWSI6RiaHAqOLYeGfciqu(2Pmo6N)WMHs9VWadqRqD1Ag85tZ1AZksbf0FeMmFL9kHcRq4Z7QAY8Ok4qz85dEnOifwboRh0uWCaeZjH0SeNyILTZh8AqrSy5VDw8IfaXfD7SenWalWHLVXsc4cDGSarqtWJyjM4KNfl)TZsc4AyPiKFSeC8zyjMAmKfWvAelXeN8S4hl3oXcvGSaBSC7elaIs1TNyyrD1AS8nw2oFAUwZIf4sdwO7yP5AnlWwJf4Wsc4IfFiwGflaKLZhu0H5K8W9WcBCibyLrc(8bVgueA)MYQRwZal62X5GM8jJ4XpSmROUUEwHpFA)qgpkh2PaqkScHpVRQjZJQGdLXNp41GI666PUAntWZFfmdL6FHbgAuOUAntWZFfmROUUE9uxTMj45VcMHs9VWadva0K6ih4d0R754BCDocAHgKACbqFfQRwZe88xbZkQRtD1AMXrqfCHZTHQyLiJ)QT059e4JM3ndL6FHbgQaOj1roWhOx3ZX346Ce0cni14cG(kuxTMzCeubx4CBOkwjY4VAlDEpb(O5DZkQVIaebvEDgeuD7jM(9v0dhrAD(8bfDyd(8P5AnWIBxhcFExvtg85tZ16SfyD5MR1zyR1VVcRq4Z7QAY8Ok4qz85dEnOif9SAwf1GdkYCFkzbovgCipv9lqA66WrKwNpFqrh2GpFAUwdS42NtcPzjoXelacHWcZYxSSb1(Wc6f0FeMyXlqwWocIL4WsRzbqiewS0GdlilMiXARaNKhUhwyJdjaRmskYsofcl0(nL7PUAndf0FeMYyO2hZqP(x44jKtH1r57tPUUEHDFqryLbOIHc7(GIY3Nsadn976c7(GIWkh3(k8OCyNcaXj5H7Hf24qcWkJKDx3YPqyH2VPCp1vRzOG(JWugd1(ygk1)chpHCkSokFFk111lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaif9uxTMzCeubx4CBOkwjmdL6FHbgAuOUAnZ4iOcUW52qvSsywrkSAwf1GdkYG)QT059e4JM376SsD1AMXrqfCHZTHQyLWSI6Zj5H7Hf24qcWkJK2sRZPqyH2VPCp1vRzOG(JWugd1(ygk1)chpHCkSokFFkPOxac1GqlLj45VcMHs9VWXJga01fGqni0szcWcbeikF7ugh9ZFyZqP(x44rda6311lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaif9uxTMzCeubx4CBOkwjmdL6FHbgAuOUAnZ4iOcUW52qvSsywrkSAwf1GdkYG)QT059e4JM376SsD1AMXrqfCHZTHQyLWSI6ZjH0SeNyIfKci6XcSybzXrojpCpSWghsawzKyXN5Htg2YKEveNesZcYCDyP9JWSyzNUDAy5GSSWelBNpTFiw(ILnO2hwSS)HDwEml(XcAy58bfDyaReln4WcHGMeSaqaGuzj1XhnjyboSynSSD(GxdkIf0lncAHMuQowWNhacZj5H7Hf24qcWkJee(8UQMqB5PKY4ZN2pu(RmgQ9bTiC9IughrAD(8bfDyd(8P9dfV1a4MgcNEPo(OjrgHRxeWReaaasfGaOpGBAiC6PUAnd(8bVguuMsJGwOjLQlJHAFm4ZdaHuTM(CsinliZ1HL2pcZILD62PHLdYcsX43olGR5luSehgQIvcojpCpSWghsawzKGWN3v1eAlpLu2Y43E(RCBOkwjqlcxViLvcPIJiToV74JagatUEaWaqGVhoI0685dk6Wg85t7hk5uQpW3tjaFUMQZGHlDg2Y3oLBWHWNHkxvtGaVsg00VpGbGrj0a8QRwZmocQGlCUnufReMHs9VWCsinlXjMybPy8BNLVyzdQ9Hf0lO)imXcCy5BSuqw2oFA)qSy51AwA)XYxhKfKftKyTvGfVsKchItYd3dlSXHeGvgjwg)2r73uUhf0FeMm6v5tUiKFDDuq)ryY4vICri)uGWN3v1K5X5GMCeuFf9oFqrN5(ukFWm4tXBnDDuq)ryYOxLp5VYaSRR9O2V8qP(xyGPea631PUAndf0FeMYyO2hZqP(xyG5H7HLbF(0(HmeYPW6O89PKc1vRzOG(JWugd1(ywrDDuq)ryY8vgd1(OWke(8UQMm4ZN2pu(RmgQ9PRtD1AMGN)kygk1)cdmpCpSm4ZN2pKHqofwhLVpLuyfcFExvtMhNdAYrqkuxTMj45VcMHs9VWaJqofwhLVpLuOUAntWZFfmROUo1vRzghbvWfo3gQIvcZksbcFExvtglJF75VYTHQyLORZke(8UQMmpoh0KJGuOUAntWZFfmdL6FHJNqofwhLVpL4KqAwItmXY25t7hILVXYxSG(RYhwqVG(JWeAz5lw2GAFyb9c6pctSalwSgaZY5dk6WSahwoilrdmWYgu7dlOxq)ryItYd3dlSXHeGvgj4ZN2peNesZsCW16BFwCsE4EyHnoKaSYizwv2d3dRS(XhAlpLuU5A9TplojojKML4WqvSsWIL)2zbzXejwBf4K8W9WcBuH(P84iOcUW52qvSsG2VPS6Q1mbp)vWmuQ)foELqdNesZsCIjwIjOhDpcILnl(KYILDQyXpw0egZYT7flwdlXagtRZc(8aqyw8cKLdYYqTHW7S4SamLbil4ZdaXIJzr7hXIJzjcIXVQMyboSCFkXYFSGHS8hl(mpccZcGil8XI3oAyXzjUaMf85bGyHqE0peMtYd3dlSrf6hGvgjoOhDpckJT4tkAdjcAkF(GIoSYkH2VPS6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqalzuOUAnJQR9kqzyl7AD(2)cfo7tWlYGppaeWsgf9SceEgh0JUhbLXw8jnd6PokYCFaOVqPWkpCpSmoOhDpckJT4tAg0tDuK5RCt)O2pf9SceEgh0JUhbLXw8jnVtU2CFaOVq11bcpJd6r3JGYyl(KM3jxBgk1)chFC731bcpJd6r3JGYyl(KMb9uhfzWNhacyXvbi8moOhDpckJT4tAg0tDuKzOu)lmWqJcq4zCqp6EeugBXN0mON6OiZ9bG(cvFojKML4etSGmyHaceXIL)2zbzXejwBfyXYovSebX4xvtS4filWBNglpMyXYF7S4SedymTolQRwJfl7uXciHtuHVqXj5H7Hf2Oc9dWkJKaSqabIY3oLXr)8hgTFtzRaN1dAkyoaIv0RhcFExvtMaSqabIYGeorfuyvac1GqlLj45VcMHCWeDDQRwZe88xbZkQVIEQRwZO6AVcug2YUwNV9VqHZLFRHm4ZdaPCY01PUAnJQR9kqzyl7AD(2)cfo7tWlYGppaKYjt)UovigRO9O2V8qP(xyGPea6ZjH0SehGOhloMLBNyP9d(ybvaKLVy52jwCwIbmMwNflFbcTWcCyXYF7SC7eliLsmVxSOUAnwGdlw(BNfNLKbWykWsmb9O7rqSSzXNuw8cKfl(FS0GdlilMiXARalFJL)yXcSowujwwrS4O8VyrLAWHy52jwcGS8ywAF94DcKtYd3dlSrf6hGvgjT1KidBzsVkcTFt5E96PUAnJQR9kqzyl7AD(2)cfox(TgYGppau8a6Uo1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGIhq3xrpRcqeu51zqq1TNy66SsD1AMXrqfCHZTHQyLWSI63xrpWz9GMcMdG4UUaeQbHwktWZFfmdL6FHJhnaORRxaIGkVot9O2VCZjfbiudcTuMaSqabIY3oLXr)8h2muQ)foE0aG(97311deEgh0JUhbLXw8jnd6PokYmuQ)fo(Krrac1GqlLj45VcMHs9VWXReaueGiOYRZuuyGA4a2VRtfIXk(6OjcQ9JaZTh1(Lhk1)cdSKrHvbiudcTuMGN)kygYbt01fGiOYRZauI59sH6Q1ma9f4qGzkncAHMuQoZkQRlarqLxNbbv3EIrH6Q1mJJGk4cNBdvXkHzOu)lmWaokuxTMzCeubx4CBOkwjmRiojKMfK5vG0SSD(OHdilw(BNfNLISWsmGX06SOUAnw8cKfKftKyTvGLhxO7yXvHRJLdYIkXYctGCsE4EyHnQq)aSYij4vG0z1vRH2YtjLXNpA4aI2VPCp1vRzuDTxbkdBzxRZ3(xOW5YV1qMHs9VWXdinOPRtD1Agvx7vGYWw2168T)fkC2NGxKzOu)lC8asdA6ROxac1GqlLj45VcMHs9VWXdi766fGqni0szO0iOfAYQWc0muQ)foEaPcRuxTMbOVahcmtPrql0Ks1LPIguFSiZksraIGkVodqjM3R(9v44BCDocAHM4voUaGtcPzjoUsJyz78bVgueMfl)TZIZsmGX06SOUAnwuxhlf8yXYovSebH6VqXsdoSGSyIeRTcSahwqk9f4qGSSf9ZFyojpCpSWgvOFawzKGpFWRbfH2VPCp1vRzuDTxbkdBzxRZ3(xOW5YV1qg85bGIhGDDQRwZO6AVcug2YUwNV9VqHZ(e8Im4Zdafpa7ROxaIGkVot9O2VCZPUUaeQbHwktWZFfmdL6FHJhq21zfcFExvtMayoalW)EyPWQaebvEDgGsmVxDD9cqOgeAPmuAe0cnzvybAgk1)chpGuHvQRwZa0xGdbMP0iOfAsP6YurdQpwKzfPiarqLxNbOeZ7v)(k6zfi8mT1KidBzsVkYCFaOVq11zvac1GqlLj45VcMHCWeDDwfGqni0szcWcbeikF7ugh9ZFyZqoyI(CsinlXXvAelBNp41GIWSOsn4qSGmyHaceXj5H7Hf2Oc9dWkJe85dEnOi0(nL7fGqni0szcWcbeikF7ugh9ZFyZqP(xyGHgfwboRh0uWCaeROhcFExvtMaSqabIYGeorf66cqOgeAPmbp)vWmuQ)fgyOPVce(8UQMmbWCawG)9WQVcRaHNPTMezylt6vrM7da9fkfbicQ86m1JA)YnNuyf4SEqtbZbqSckO)imz(k7vcfo(gxNJGwOjERbaCsinlXryHUJfq4Xc4A(cfl3oXcvGSaBSaiWrqfCHzjomufReOLfW18fkwa6lWHazHsJGwOjLQJf4WYxSC7elAhFSGkaYcSXIxSGEb9hHjojpCpSWgvOFawzKGWN3v1eAlpLugeE5HaURFOuQomAr46fPCp1vRzghbvWfo3gQIvcZqP(x44rtxNvQRwZmocQGlCUnufReMvuFf9uxTMbOVahcmtPrql0Ks1LPIguFSiZqP(xyGHkaAsDK3xrp1vRzOG(JWugd1(ygk1)chpQaOj1rExN6Q1muq)rykRxLpMHs9VWXJkaAsDK3NtYd3dlSrf6hGvgj4v1(HqBirqt5Zhu0Hvwj0(nLhQneE3v1KIZhu0zUpLYhmd(u8kbOv4r5WofasbcFExvtgq4Lhc4U(HsP6WCsE4EyHnQq)aSYijfcR2peAdjcAkF(GIoSYkH2VP8qTHW7UQMuC(GIoZ9Pu(GzWNIxP4AqJcpkh2Paqkq4Z7QAYacV8qa31pukvhMtYd3dlSrf6hGvgj4J0AFYnTpeAdjcAkF(GIoSYkH2VP8qTHW7UQMuC(GIoZ9Pu(GzWNIxjanGhk1)cRWJYHDkaKce(8UQMmGWlpeWD9dLs1H5KqAwIdWyZcSyjaYIL)2HRJLGhf9fkojpCpSWgvOFawzK0GtGYWwU8BneA)MYEuoStbG4KqAwqV0iOfAyjgWcKfl7uXIRcxhlhKfQoAyXzPilSedymTolw(ceAHfVazb7iiwAWHfKftKyTvGtYd3dlSrf6hGvgjuAe0cnzvybI2VPCpkO)imz0RYNCri)66OG(JWKbd1(Klc5xxhf0FeMmELixeYVUo1vRzuDTxbkdBzxRZ3(xOW5YV1qMHs9VWXdinOPRtD1Agvx7vGYWw2168T)fkC2NGxKzOu)lC8asdA66C8nUohbTqt8ahaOiaHAqOLYe88xbZqoycfwboRh0uWCae3xrVaeQbHwktWZFfmdL6FHJpUaORlaHAqOLYe88xbZqoyI(DDQqmwXxhnrqTFeyU9O2V8qP(xyGPea4KqAwIdq0JL5rTFSOsn4qSSWFHIfKftojpCpSWgvOFawzK0wtImSLj9Qi0(nLdqOgeAPmbp)vWmKdMqbcFExvtMayoalW)EyPONJVX15iOfAIh4aafwfGiOYRZupQ9l3CQRlarqLxNPEu7xU5KchFJRZrql0amRba9vyvaIGkVodcQU9eJIEwfGiOYRZupQ9l3CQRlaHAqOLYeGfciqu(2Pmo6N)WMHCWe9vyf4SEqtbZbqmNesZcYIjsS2kWILDQyXpwaoaaWSetCYZsp4OHwOHLB3lwSgaWsmXjplw(BNfKbleqGO(Sy5VD46yrdXFHIL7tjw(ILyOHqq9cFS4fil6ViwwrSy5VDwqgSqabIy5BS8hlwCmlGeorfiqojpCpSWgvOFawzKGWN3v1eAlpLuoaMdWc8VhwzvOFOfHRxKYwboRh0uWCaeRaHpVRQjtamhGf4FpSu0RNJVX15iOfAIh4aaf9uxTMbOVahcmtPrql0Ks1LPIguFSiZkQRZQaebvEDgGsmVx976uxTMrvdHG6f(mRifQRwZOQHqq9cFMHs9VWatD1AMGN)kyaxJFpS63191rteu7hbMBpQ9lpuQ)fgyQRwZe88xbd4A87HvxxaIGkVot9O2VCZP(k6zvaIGkVot9O2VCZPUUEo(gxNJGwObywda66aHNPTMezylt6vrM7da9fQ(k6HWN3v1KjaleqGOmiHtuHUUaeQbHwktawiGar5BNY4OF(dBgYbt0VpNKhUhwyJk0paRmscKMW376SRFuvkvhA)MYi85DvnzcG5aSa)7Hvwf6hNKhUhwyJk0paRms(k4t53dl0(nLr4Z7QAYeaZbyb(3dRSk0pojKMf0dFFQFeMLDOfwsxHDwIjo5zXhIfu(xeilr0WcMcWcKtYd3dlSrf6hGvgji85DvnH2YtjLDCuYtZgfqlcxViLPG(JWK5RSEv(a8jds1d3dld(8P9dziKtH1r57tjaBff0FeMmFL1RYhGVhGgWNRP6my4sNHT8Tt5gCi8zOYv1eiWh3(ivpCpSmwg)2neYPW6O89PeGbGbGivCeP15DhFeNesZsCCLgXY25dEnOimlw2PILBNyP9O2pwEmlUkCDSCqwOceTS0gQIvcwEmlUkCDSCqwOceTSKaUyXhIf)yb4aaaZsmXjplFXIxSGEb9hHj0YcYIjsS2kWI2XhMfVG3onSKmagtbmlWHLeWflwGlnilqe0e8iwsHdXYT7flCNsaGLyItEwSStfljGlwSaxAWcDhlBNp41GIyPGw4K8W9WcBuH(byLrc(8bVgueA)MY9uHySIVoAIGA)iWC7rTF5Hs9VWaZA666PUAnZ4iOcUW52qvSsygk1)cdmubqtQJCGpqVUNJVX15iOfAqQXfa9vOUAnZ4iOcUW52qvSsywr97311ZX346Ce0cnagHpVRQjJJJsEA2OaWRUAndf0FeMYyO2hZqP(xyadcptBnjYWwM0RIm3hacNhk1)c4bObnXRKsaORZX346Ce0cnagHpVRQjJJJsEA2OaWRUAndf0FeMY6v5JzOu)lmGbHNPTMezylt6vrM7daHZdL6Fb8a0GM4vsja0xbf0FeMmFL9kHIEwPUAntWZFfmROUoRoxt1zWNpA4aAOYv1eyFf96zvac1GqlLj45VcMvuxxaIGkVodqjM3lfwfGqni0szO0iOfAYQWc0SI631fGiOYRZupQ9l3CQVIEwfGiOYRZGGQBpX01zL6Q1mbp)vWSI66C8nUohbTqt8aha0VRR35AQod(8rdhqdvUQMavOUAntWZFfmRif9uxTMbF(OHdObFEaiGf3UohFJRZrql0epWba9731PUAntWZFfmRifwPUAnZ4iOcUW52qvSsywrkS6CnvNbF(OHdOHkxvtGCsinlXjMybqiewyw(If0Fv(Wc6f0FeMyXlqwWocIfKY46gGJdlTMfaHqyXsdoSGSyIeRTcCsE4EyHnQq)aSYiPil5uiSq73uUN6Q1muq)rykRxLpMHs9VWXtiNcRJY3NsDD9c7(GIWkdqfdf29bfLVpLagA631f29bfHvoU9v4r5WofaItYd3dlSrf6hGvgj7UULtHWcTFt5EQRwZqb9hHPSEv(ygk1)chpHCkSokFFkPOxac1GqlLj45VcMHs9VWXJga01fGqni0szcWcbeikF7ugh9ZFyZqP(x44rda6311lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaiojpCpSWgvOFawzK0wADofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PKIEbiudcTuMGN)kygk1)chpAaqxxac1GqlLjaleqGO8TtzC0p)HndL6FHJhnaOFxxVWUpOiSYauXqHDFqr57tjGHM(DDHDFqryLJBFfEuoStbG4KqAwqkGOhlWILaiNKhUhwyJk0paRmsS4Z8WjdBzsVkItcPzjoXelBNpTFiwoilrdmWYgu7dlOxq)ryIf4WILDQy5lwGLoblO)Q8Hf0lO)imXIxGSSWelifq0JLObgWS8nw(If0Fv(Wc6f0FeM4K8W9WcBuH(byLrc(8P9dH2VPmf0FeMmFL1RYNUokO)imzWqTp5Iq(11rb9hHjJxjYfH8RRtD1Agl(mpCYWwM0RImRifQRwZqb9hHPSEv(ywrDD9uxTMj45VcMHs9VWaZd3dlJLXVDdHCkSokFFkPqD1AMGN)kywr95K8W9WcBuH(byLrILXVDojpCpSWgvOFawzKmRk7H7Hvw)4dTLNsk3CT(2NfNeNesZY25dEnOiwAWHLuickLQJLvPjmMLf(luSedymToNKhUhwytZ16BFwkJpFWRbfH2VPSvZQOgCqrgvx7vGYWw2168T)fkSHaURpkIa5KqAwqMJpwUDIfq4XIL)2z52jwsH4JL7tjwoiloiilR6Enl3oXsQJCwaxJFpSy5XSS)NHLTv1(HyzOu)lmlPl99r6Naz5GSK6xyNLuiSA)qSaUg)EyXj5H7Hf20CT(2NfGvgj4v1(HqBirqt5Zhu0Hvwj0(nLbHNjfcR2pKzOu)lC8dL6FHbEacqKQsjdNKhUhwytZ16BFwawzKKcHv7hItItcPzjoXelBNp41GIy5GSaerrSSIy52jwIJd5PQFbsdlQRwJLVXYFSybU0GSqip6hIfvQbhIL2xpE)luSC7elfH8JLGJpwGdlhKfWvAelQudoelidwiGarCsE4EyHn4tz85dEnOi0(nLNvrn4GIm3NswGtLbhYtv)cKgf9OG(JWK5RSxjuyvVEQRwZCFkzbovgCipv9lqAmdL6FHJ3d3dlJLXVDdHCkSokFFkbyayusrpkO)imz(kRcV9UokO)imz(kJHAF66OG(JWKrVkFYfH8RFxN6Q1m3NswGtLbhYtv)cKgZqP(x449W9WYGpFA)qgc5uyDu((ucWaWOKIEuq)ryY8vwVkF66OG(JWKbd1(Klc5xxhf0FeMmELixeYV(976SsD1AM7tjlWPYGd5PQFbsJzf1VRRN6Q1mbp)vWSI66q4Z7QAYeGfciqugKWjQqFfbiudcTuMaSqabIY3oLXr)8h2mKdMqraIGkVot9O2VCZP(k6zvaIGkVodqjM3RUUaeQbHwkdLgbTqtwfwGMHs9VWXNm9v0tD1AMGN)kywrDDwfGqni0szcE(RGzihmrFojKML4etSetqp6EeelBw8jLfl7uXYTtdXYJzPGS4H7rqSGT4tkAzXXSO9JyXXSebX4xvtSalwWw8jLfl)TZcazboS0il0Wc(8aqywGdlWIfNL4cywWw8jLfmKLB3pwUDILISWc2IpPS4Z8iimlaISWhlE7OHLB3pwWw8jLfc5r)qyojpCpSWg8byLrId6r3JGYyl(KI2qIGMYNpOOdRSsO9BkBfi8moOhDpckJT4tAg0tDuK5(aqFHsHvE4EyzCqp6EeugBXN0mON6OiZx5M(rTFk6zfi8moOhDpckJT4tAENCT5(aqFHQRdeEgh0JUhbLXw8jnVtU2muQ)foE00VRdeEgh0JUhbLXw8jnd6PokYGppaeWIRcq4zCqp6EeugBXN0mON6OiZqP(xyGfxfGWZ4GE09iOm2IpPzqp1rrM7da9fkojKML4etywqgSqabIy5BSGSyIeRTcS8ywwrSahwsaxS4dXciHtuHVqXcYIjsS2kWIL)2zbzWcbeiIfVazjbCXIpelQKgAHfRbaSetCYZj5H7Hf2GpaRmscWcbeikF7ugh9ZFy0(nLTcCwpOPG5aiwrVEi85DvnzcWcbeikds4evqHvbiudcTuMGN)kygYbtOWQzvudoOit08PWb8DD2NGxFihT0yF66uxTMj45VcMvuFfo(gxNJGwObykBnaqrp1vRzOG(JWuwVkFmdL6FHJxja01PUAndf0FeMYyO2hZqP(x44vca976uHySI2JA)YdL6FHbMsaqHvbiudcTuMGN)kygYbt0NtcPzbzWc8VhwS0GdlUwZci8WSC7(XsQdeHzbVgILBNsWIpuHUJLHAdH3jqwSStflacCeubxywIddvXkbl7oMfnHXSC7EXcAybtbmldL6F9fkwGdl3oXcqjM3lwuxTglpMfxfUowoilnxRzb2ASahw8kblOxq)ryILhZIRcxhlhKfc5r)qCsE4EyHn4dWkJee(8UQMqB5PKYGWlpeWD9dLs1HrlcxViL7PUAnZ4iOcUW52qvSsygk1)chpA66SsD1AMXrqfCHZTHQyLWSI6RWk1vRzghbvWfo3gQIvIm(R2sN3tGpAE3SIu0tD1AgG(cCiWmLgbTqtkvxMkAq9XImdL6FHbgQaOj1rEFf9uxTMHc6pctzmu7JzOu)lC8OcGMuh5DDQRwZqb9hHPSEv(ygk1)chpQaOj1rExxpRuxTMHc6pctz9Q8XSI66SsD1AgkO)imLXqTpMvuFfwDUMQZGHA89bYqLRQjW(CsinlidwG)9WILB3pwc7uaimlFJLeWfl(qSaxh(bjwOG(JWelhKfyPtWci8y52PHyboS8Ok4qSC7pMfl)TZYguJVpqCsE4EyHn4dWkJee(8UQMqB5PKYGWldxh(bPmf0FeMqlcxViL7zL6Q1muq)rykJHAFmRifwPUAndf0FeMY6v5Jzf1VR7CnvNbd147dKHkxvtGCsE4EyHn4dWkJKuiSA)qOnKiOP85dk6WkReA)MYd1gcV7QAsrp1vRzOG(JWugd1(ygk1)ch)qP(x4Uo1vRzOG(JWuwVkFmdL6FHJFOu)lCxhcFExvtgq4LHRd)GuMc6pct9vmuBi8URQjfNpOOZCFkLpyg8P4vcGk8OCyNcaPaHpVRQjdi8YdbCx)qPuDyojpCpSWg8byLrcEvTFi0gse0u(8bfDyLvcTFt5HAdH3DvnPON6Q1muq)rykJHAFmdL6FHJFOu)lCxN6Q1muq)rykRxLpMHs9VWXpuQ)fURdHpVRQjdi8YW1HFqktb9hHP(kgQneE3v1KIZhu0zUpLYhmd(u8kbqfEuoStbGuGWN3v1KbeE5HaURFOuQomNKhUhwyd(aSYibFKw7tUP9HqBirqt5Zhu0Hvwj0(nLhQneE3v1KIEQRwZqb9hHPmgQ9XmuQ)fo(Hs9VWDDQRwZqb9hHPSEv(ygk1)ch)qP(x4Uoe(8UQMmGWldxh(bPmf0FeM6RyO2q4DxvtkoFqrN5(ukFWm4tXReGwHhLd7uaifi85DvnzaHxEiG76hkLQdZjH0SeNyIL4am2SalwcGSy5VD46yj4rrFHItYd3dlSbFawzK0GtGYWwU8BneA)MYEuoStbG4KqAwItmXcsPVahcKLTOF(dZIL)2zXReSOHfkwOcUqTZI2X3xOyb9c6pctS4fil3KGLdYI(lIL)yzfXIL)2zj5xASpS4fililMiXARaNKhUhwyd(aSYiHsJGwOjRclq0(nL71tD1AgkO)imLXqTpMHs9VWXRea66uxTMHc6pctz9Q8XmuQ)foELaqFfbiudcTuMGN)kygk1)chFCbGIEQRwZenFkCaFxN9j41hYrln2hdcxViGbqRbaDDwnRIAWbfzIMpfoGVRZ(e86d5OLg7JHaURpkIa73VRtD1AMO5tHd476SpbV(qoAPX(yq46ffVYaeqcGUUaeQbHwktWZFfmd5Gju44BCDocAHM4boaGtcPzjoXelilMiXARalw(BNfKbleqGiKGu6lWHazzl6N)WS4filGWcDhlqe0yz(Jyj5xASpSahwSStflXqdHG6f(yXcCPbzHqE0pelQudoelilMiXARaleYJ(HWCsE4EyHn4dWkJee(8UQMqB5PKYbWCawG)9WkJp0IW1lszRaN1dAkyoaIvGWN3v1KjaMdWc8Vhwk61laHAqOLYqPrjgY1z4awEfiZqP(xyGPeGgqc4EkPeWpRIAWbfzWF1w68Ec8rZ79vqa31hfrGgknkXqUodhWYRa1VRZX346Ce0cnXRmWbak6z15AQotBnjYWwM0RImu5QAcSRtD1AMGN)kyaxJFpSIpaHAqOLY0wtImSLj9QiZqP(xyaNm9vGWN3v1K52NxRZyIaIMSf)pf9uxTMbOVahcmtPrql0Ks1LPIguFSiZkQRZQaebvEDgGsmVx9vC(GIoZ9Pu(GzWNIxD1AMGN)kyaxJFpSaEayaKDDQqmwr7rTF5Hs9VWatD1AMGN)kyaxJFpS66cqeu51zQh1(LBo11PUAnJQgcb1l8zwrkuxTMrvdHG6f(mdL6FHbM6Q1mbp)vWaUg)Eyb4EahGFwf1GdkYenFkCaFxN9j41hYrln2hdbCxFueb2VVcRuxTMj45VcMvKIEwfGiOYRZupQ9l3CQRlaHAqOLYeGfciqu(2Pmo6N)WMvuxNkeJv0Eu7xEOu)lmWcqOgeAPmbyHaceLVDkJJ(5pSzOu)lmGb0DDTh1(Lhk1)cJurQkLmaayQRwZe88xbd4A87HvFojKML4etSC7elaIs1TNyyXYF7S4SGSyIeRTcSC7(XYJl0DS0gyklj)sJ9HtYd3dlSbFawzKmocQGlCUnufReO9BkRUAntWZFfmdL6FHJxj001PUAntWZFfmGRXVhwalUaqbcFExvtMayoalW)EyLXhNKhUhwyd(aSYijqAcFVRZU(rvPuDO9BkJWN3v1KjaMdWc8Vhwz8PONvQRwZe88xbd4A87Hv8XfaDDwfGiOYRZGGQBpX0VRtD1AMXrqfCHZTHQyLWSIuOUAnZ4iOcUW52qvSsygk1)cdmGdGdWcC9NjAOWJPSRFuvkvN5(ukJW1lcW9SsD1AgvnecQx4ZSIuy15AQod(8rdhqdvUQMa7Zj5H7Hf2GpaRms(k4t53dl0(nLr4Z7QAYeaZbyb(3dRm(4KqAwae1N3v1ellmbYcSyXvF9FpHz529JflEDSCqwujwWoccKLgCybzXejwBfybdz529JLBNsWIpuDSyXXhbYcGil8XIk1GdXYTtPCsE4EyHn4dWkJee(8UQMqB5PKYyhbLBWjh88xb0IW1lszRcqOgeAPmbp)vWmKdMORZke(8UQMmbyHaceLbjCIkOiarqLxNPEu7xU5uxh4SEqtbZbqmNesZsCIjmlXbi6XY3y5lw8If0lO)imXIxGSCZtywoil6Viw(JLvelw(BNLKFPX(GwwqwmrI1wbw8cKLyc6r3JGyzZIpPCsE4EyHn4dWkJK2AsKHTmPxfH2VPmf0FeMmFL9kHcpkh2PaqkuxTMjA(u4a(Uo7tWRpKJwASpgeUEradGwdau0deEgh0JUhbLXw8jnd6PokYCFaOVq11zvaIGkVotrHbQHdyFfi85DvnzWock3Gto45Vck6PUAnZ4iOcUW52qvSsygk1)cdmGtY1dna)SkQbhuKb)vBPZ7jWhnV3xH6Q1mJJGk4cNBdvXkHzf11zL6Q1mJJGk4cNBdvXkHzf1NtcPzjoXelaIl62zz78P5AnlrdmGz5BSSD(0CTMLhxO7yzfXj5H7Hf2GpaRmsWNpnxRr73uwD1Agyr3oohrtGIUhwMvKc1vRzWNpnxRnd1gcV7QAItYd3dlSbFawzKe8kq6S6Q1qB5PKY4ZhnCar73uwD1Ag85JgoGMHs9VWadnk6PUAndf0FeMYyO2hZqP(x44rtxN6Q1muq)rykRxLpMHs9VWXJM(kC8nUohbTqt8ahaWjH0SehxPrywIjo5zrLAWHybzWcbeiILf(luSC7elidwiGarSeGf4FpSy5GSe2PaqS8nwqgSqabIy5XS4HB5ADcwCv46y5GSOsSeC8Xj5H7Hf2GpaRmsWNp41GIq73uoarqLxNPEu7xU5Kce(8UQMmbyHaceLbjCIkOiaHAqOLYeGfciqu(2Pmo6N)WMHs9VWadnkScCwpOPG5aiwbf0FeMmFL9kHchFJRZrql0eV1aaojKML4etSSD(0CTMfl)TZY2rATpSehNVDS4filfKLTZhnCarllw2PILcYY25tZ1AwEmlRi0Ysc4IfFiw(If0Fv(Wc6f0FeMyPbhwsgaJPaMf4WYbzjAGbws(Lg7dlw2PIfxfIGyb4aawIjo5zboS4Gr(9iiwWw8jLLDhZsYaymfWSmuQ)1xOyboS8yw(ILM(rTFgwIn8iwUD)yzvG0WYTtSG9uILaSa)7HfML)qhMfWimlfTUX1SCqw2oFAUwZc4A(cflacCeubxywIddvXkbAzXYovSKaUqhil471AwOcKLvelw(BNfGdaaSJJyPbhwUDIfTJpwqPHQUgB4K8W9WcBWhGvgj4ZNMR1O9BkFUMQZGpsR9jdoF7mu5QAcuHvNRP6m4ZhnCanu5QAcuH6Q1m4ZNMR1MHAdH3DvnPON6Q1muq)rykRxLpMHs9VWXNmkOG(JWK5RSEv(OqD1AMO5tHd476SpbV(qoAPX(yq46fbmaIga01PUAnt08PWb8DD2NGxFihT0yFmiC9IIxzaIgaOWX346Ce0cnXdCaqxhi8moOhDpckJT4tAg0tDuKzOu)lC8jtxNhUhwgh0JUhbLXw8jnd6PokY8vUPFu7xFfbiudcTuMGN)kygk1)chVsaGtcPzjoXelBNp41GIybqCr3olrdmGzXlqwaxPrSetCYZILDQybzXejwBfyboSC7elaIs1TNyyrD1AS8ywCv46y5GS0CTMfyRXcCyjbCHoqwcEelXeN8CsE4EyHn4dWkJe85dEnOi0(nLvxTMbw0TJZbn5tgXJFyzwrDDQRwZa0xGdbMP0iOfAsP6YurdQpwKzf11PUAntWZFfmRif9uxTMzCeubx4CBOkwjmdL6FHbgQaOj1roWhOx3ZX346Ce0cni14cG(aoUa)5AQotrwYPqyzOYv1eOcRMvrn4GIm4VAlDEpb(O5DfQRwZmocQGlCUnufReMvuxN6Q1mbp)vWmuQ)fgyOcGMuh5aFGEDphFJRZrql0GuJla631PUAnZ4iOcUW52qvSsKXF1w68Ec8rZ7MvuxNvQRwZmocQGlCUnufReMvKcRcqOgeAPmJJGk4cNBdvXkHzihmrxNvbicQ86miO62tm976C8nUohbTqt8ahaOGc6pctMVYELGtcPzX6tcwoilPoqel3oXIkHpwGnw2oF0WbKf1eSGppa0xOy5pwwrSaCxFaiDcw(IfVsWc6f0FeMyrDDSK8ln2hwECDS4QW1XYbzrLyjAGHabYj5H7Hf2GpaRmsWNp41GIq73u(CnvNbF(OHdOHkxvtGkSAwf1GdkYCFkzbovgCipv9lqAu0tD1Ag85JgoGMvuxNJVX15iOfAIh4aG(kuxTMbF(OHdObFEaiGfxf9uxTMHc6pctzmu7Jzf11PUAndf0FeMY6v5Jzf1xH6Q1mrZNchW31zFcE9HC0sJ9XGW1lcyaeqcaf9cqOgeAPmbp)vWmuQ)foELaqxNvi85DvnzcWcbeikds4evqraIGkVot9O2VCZP(CsinlOh((u)iml7qlSKUc7SetCYZIpelO8ViqwIOHfmfGfiNKhUhwyd(aSYibHpVRQj0wEkPSJJsEA2OaAr46fPmf0FeMmFL1RYhGpzqQE4EyzWNpTFidHCkSokFFkbyROG(JWK5RSEv(a89a0a(CnvNbdx6mSLVDk3GdHpdvUQMab(42hP6H7HLXY43UHqofwhLVpLamamwdAqQ4isRZ7o(iadadAa(Z1uDMYV1q4SQR9kqgQCvnbYjH0SehxPrSSD(GxdkILVyXzbqcymfyzdQ9Hf0lO)imHwwaHf6ow00XYFSenWalj)sJ9HLE3UFS8yw29cutGSOMGf6VDAy52jw2oFAUwZI(lIf4WYTtSetCYhpWbaSO)IyPbhw2oFWRbf1hTSacl0DSarqJL5pIfVybqCr3olrdmWIxGSOPJLBNyXvHiiw0FrSS7fOMyz78rdhqojpCpSWg8byLrc(8bVgueA)MYwnRIAWbfzUpLSaNkdoKNQ(fink6PUAnt08PWb8DD2NGxFihT0yFmiC9IagabKaORtD1AMO5tHd476SpbV(qoAPX(yq46fbmaIgaO4CnvNbFKw7tgC(2zOYv1eyFf9OG(JWK5RmgQ9rHJVX15iOfAamcFExvtghhL80SrbGxD1AgkO)imLXqTpMHs9VWageEM2AsKHTmPxfzUpaeopuQ)fWdqdAIpzaqxhf0FeMmFL1RYhfo(gxNJGwObWi85DvnzCCuYtZgfaE1vRzOG(JWuwVkFmdL6FHbmi8mT1KidBzsVkYCFaiCEOu)lGhGg0epWba9vyL6Q1mWIUDCoIMafDpSmRifwDUMQZGpF0Wb0qLRQjqf9cqOgeAPmbp)vWmuQ)foEazxhgU0QFbAU9516mMiGOXqLRQjqfQRwZC7ZR1zmrarJbFEaiGf34MC9Mvrn4GIm4VAlDEpb(O5DGhn9v0Eu7xEOu)lC8kbaaOO9O2V8qP(xyGbqaaG(k6fGqni0sza6lWHaZ4OF(dBgk1)chpGSRZQaebvEDgGsmVx95KqAwItmXcGqiSWS8flO)Q8Hf0lO)imXIxGSGDeeliLX1nahhwAnlacHWILgCybzXejwBfyXlqwqk9f4qGSGEPrql0Ks1Xj5H7Hf2GpaRmskYsofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PuxxVWUpOiSYauXqHDFqr57tjGHM(DDHDFqryLJBFfEuoStbGuGWN3v1Kb7iOCdo5GN)kWj5H7Hf2GpaRms2DDlNcHfA)MY9uxTMHc6pctz9Q8XmuQ)foEc5uyDu((usHvbicQ86maLyEV666PUAndqFboeyMsJGwOjLQltfnO(yrMvKIaebvEDgGsmVx9766f29bfHvgGkgkS7dkkFFkbm00VRlS7dkcRCC76uxTMj45VcMvuFfEuoStbGuGWN3v1Kb7iOCdo5GN)kOON6Q1mJJGk4cNBdvXkHzOu)lmW6HMKdGa)SkQbhuKb)vBPZ7jWhnV3xH6Q1mJJGk4cNBdvXkHzf11zL6Q1mJJGk4cNBdvXkHzf1NtYd3dlSbFawzK0wADofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PKcRcqeu51zakX8E111tD1AgG(cCiWmLgbTqtkvxMkAq9XImRifbicQ86maLyEV6311lS7dkcRmavmuy3huu((ucyOPFxxy3huew5421PUAntWZFfmRO(k8OCyNcaPaHpVRQjd2rq5gCYbp)vqrp1vRzghbvWfo3gQIvcZqP(xyGHgfQRwZmocQGlCUnufReMvKcRMvrn4GIm4VAlDEpb(O59UoRuxTMzCeubx4CBOkwjmRO(CsinlXjMybPaIESalwcGCsE4EyHn4dWkJel(mpCYWwM0RI4KqAwItmXY25t7hILdYs0adSSb1(Wc6f0FeMqllilMiXARal7oMfnHXSCFkXYT7flolifJF7SqiNcRJyrtTJf4WcS0jyb9xLpSGEb9hHjwEmlRiojpCpSWg8byLrc(8P9dH2VPmf0FeMmFL1RYNUokO)imzWqTp5Iq(11rb9hHjJxjYfH8RRRN6Q1mw8zE4KHTmPxfzwrDD4isRZ7o(iGbaJ1GgfwfGiOYRZGGQBpX01HJiToV74JagamwJIaebvEDgeuD7jM(kuxTMHc6pctz9Q8XSI666PUAntWZFfmdL6FHbMhUhwglJF7gc5uyDu((usH6Q1mbp)vWSI6ZjH0SeNyIfKIXVDwG3onwEmXIL9pSZYJz5lw2GAFyb9c6pctOLfKftKyTvGf4WYbzjAGbwq)v5dlOxq)ryItYd3dlSbFawzKyz8BNtcPzjo4A9TplojpCpSWg8byLrYSQShUhwz9Jp0wEkPCZ16BFw2N9zBda]] )


end