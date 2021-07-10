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


    spec:RegisterPack( "Balance", 20210709, [[de16BfqikjpcIuxcIK2ej8jivgLuLtjv1Qau1RaOMfKs3ca0UO4xqedte1Xirwga6zcvAAusX1GuSnav8nasghaHZbq06ai18auUhjQ9ju1)GirPdkuYcfk8qiktuOcDrivzJcvWhHir1iHirXjPKsRue5LqKiZesvDtaO0ofk6NaqvdfaYsbGINQuMkLuDvHkARaqL(kejmwaG9sP(ROgmXHPAXK0JfmzGUmYMLYNHKrRuDAvTAaOIxdiZMu3wK2TKFdA4c54aQ0Yv8COMUkxxjBhcFNsmEiQoViSEHsnFPY(rTTs2w3Ed0pYoMamzaQuYaQKbKgaMSsas0aq7TlrezVf5bGCuK9w5PK9wmCTxbYElYtOHoOT1T3WW1ei7T97IWaAKGevx7vGaG4pnyq93(s18qKedx7vGaGBFkYqskOz)s1iLT9Aszvx7vGmhYp7n11RpRTSvT3a9JSJjatgGkLmGkzaPbGjReGujaL9MVUD4yVT9PiZEB)bbPYw1EdKWb7Ty4AVcelXXz9GCsjT0jybqIwwayYaujojojKT7fkcdO5KaGSelqqcKLnO2hwIb5PgojailiB3lueilNpOOl)nwcoMWSCqwcjcAkF(GIoSHtcaYcagkfIGazzvffim2NeSGWN3v1eMLEVHmOLLOHqKXNp41GIybagplrdHWGpFWRbf13WjbazjwiGpilrdfC89fkwqkg)2z5BS8h6WSC7elwgyHIf0lO)imz4KaGSaG1bIybzWcbeiILBNyzl6N)WS4SO)70elPWHyPPjK)QAILEFJLeWfl7oyHUJL9)y5pwWF6sFErWfwNGfl)TZsmaWhlRZcGzbzKMW37AwIL(rvPuDOLL)qhilyG(O(gojailayDGiwsH4Jf01Eu7xEOu)lm6ybhOYNhIzXJI0jy5GSOcXywApQ9dZcS0jmCsaqwS(q(XI1HPelWglXq77SedTVZsm0(oloMfNfCefExZYnFbeDg7n9JpST1T3aPMV0NT1TJPs2w3EZd3dl7nmu7twL8u7nQCvnbAhd7ZoMa0262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nCeP15Zhu0Hn4ZNMR1SeplkXIcw6XIvSCUMQZGpF0Wb0qLRQjqw66y5CnvNbFKw7tgC(2zOYv1eil9zPRJfCeP15Zhu0Hn4ZNMR1Sepla0EdKWH5JUhw2BB0Hzjwq0JfyXsCbmlw(BhUowaNVDS4filw(BNLTZhnCazXlqwaiGzbE70y5XK9gcFYLNs2Bpo7qY(SJzCTTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEdhrAD(8bfDyd(8P9dXs8SOK9giHdZhDpSS32OdZsqtocIfl7uXY25t7hILGxSS)hlaeWSC(GIomlw2)WolpMLH0ecVowAWHLBNyb9c6pctSCqwujwIgQrZqGS4filw2)WolTxRPHLdYsWXN9gcFYLNs2Bpoh0KJGSp7yAn2w3EJkxvtG2XWEZd3dl7nvAW0a0xOS3ajCy(O7HL9wCIjwIbnyAa6luSy5VDwqwSqI1wbwGdlE7OHfKbleqGiw(IfKflKyTvWElm)rZ72B9yXkwcqeu51zQh1(LBoXsxhlwXsac1GqlLjaleqGO8TtzC0p)HnRiw6ZIcwuxTMj45VcMHs9VWSeplkHgwuWI6Q1mJJGk4cNBdvXoHzOu)lmlaJfRHffSyflbicQ86miO62tmS01XsaIGkVodcQU9edlkyrD1AMGN)kywrSOGf1vRzghbvWfo3gQIDcZkIffS0Jf1vRzghbvWfo3gQIDcZqP(xywaglkPelaqwqdlaplZQOgCqrg8xTLoVNaF08UHkxvtGS01XI6Q1mbp)vWmuQ)fMfGXIskXsxhlkXcsybhrADE3XhXcWyrjdAqdl9Tp7yIgBRBVrLRQjq7yyVfM)O5D7n1vRzcE(RGzOu)lmlXZIsOHffS0JfRyzwf1GdkYG)QT059e4JM3nu5QAcKLUowuxTMzCeubx4CBOk2jmdL6FHzbySOeGIfailaKfGNf1vRzu1qiOEHpZkIffSOUAnZ4iOcUW52qvStywrS0NLUowuHymlkyP9O2V8qP(xywaglaen2BGeomF09WYEdabpwS83ololilwiXARal3UFS84cDhlolaOLg7dlrdmWcCyXYovSC7elTh1(XYJzXvHRJLdYcvG2BE4EyzVfbVhw2NDmbo2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVfOxZspw6Xs7rTF5Hs9VWSaazrj0WcaKLaeQbHwktWZFfmdL6FHzPpliHfLaejZsFwuMLa9Aw6XspwApQ9lpuQ)fMfailkHgwaGSOeatMfailbiudcTuMaSqabIY3oLXr)8h2muQ)fML(SGewucqKml9zrblwXY4pyMqq1zCqqSHq(JpmlDDSeGqni0szcE(RGzOu)lmlXZYxhnrqTFeyU9O2V8qP(xyw66yjaHAqOLYeGfciqu(2Pmo6N)WMHs9VWSeplFD0eb1(rG52JA)YdL6FHzbaYIsjZsxhlwXsaIGkVot9O2VCZjw66yXd3dltawiGar5BNY4OF(dBaFSRQjq7nqchMp6EyzVHmxhwA)imlw2PBNgww4VqXcYGfciqelf0clwETMfxRHwyjbCXYbzbFVwZsWXhl3oXc2tjw8u4QowGnwqgSqabIamYIfsS2kWsWXh2EdHp5Ytj7TaSqabIYGeorfSp7ycOSTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYERhlNpOOZCFkLpyg8jwINfLqdlDDSm(dMjeuDgheeB(IL4zbnjZsFwuWspw6XspwiG76JIiqdLgLyixNHdy5vGyrbl9yPhlbiudcTugknkXqUodhWYRazgk1)cZcWyrjGtYS01XsaIGkVodcQU9edlkyjaHAqOLYqPrjgY1z4awEfiZqP(xywaglkbCauSayw6XIskXcWZYSkQbhuKb)vBPZ7jWhnVBOYv1eil9zPplkyXkwcqOgeAPmuAuIHCDgoGLxbYmKdMGL(S0NLUow6XcbCxFuebAWWLwt39fQ8SutWIcw6XIvSeGiOYRZupQ9l3CILUowcqOgeAPmy4sRP7(cvEwQjYX1AqdGizLmdL6FHzbySOKswdl9zPplDDS0JLaeQbHwkJknyAa6luMHCWeS01XIvSmEGm3a1Aw6ZIcw6XspwiG76JIiqZx4WSoxvtzG7YRBLMbjeFGyrblbiudcTuMVWHzDUQMYa3Lx3kndsi(azgYbtWsFw66yPhl9ybHpVRQjdSYlmLV5lGOJfLzrjw66ybHpVRQjdSYlmLV5lGOJfLzjUS0NffS0JLB(ci6mNsMHCWe5aeQbHwkw66y5MVaIoZPKjaHAqOLYmuQ)fML4z5RJMiO2pcm3Eu7xEOu)lmlaqwukzw6Zsxhli85DvnzGvEHP8nFbeDSOmlaKffS0JLB(ci6mhand5GjYbiudcTuS01XYnFbeDMdGMaeQbHwkZqP(xywINLVoAIGA)iWC7rTF5Hs9VWSaazrPKzPplDDSGWN3v1Kbw5fMY38fq0XIYSKml9zPpl9zPRJLaebvEDgGsmVxS0NLUowuHymlkyP9O2V8qP(xywaglQRwZe88xbd4A87HL9giHdZhDpSS3ItmbYYbzbK0EcwUDILf2rrSaBSGSyHeRTcSyzNkww4VqXciCPQjwGfllmXIxGSenecQowwyhfXILDQyXlwCqqwieuDS8ywCv46y5GSa(K9gcFYLNs2BbWCawG)9WY(SJjGW262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nRybdxA1Van3(8ADgteq0yOYv1eilDDS0Eu7xEOu)lmlXZcatozw66yrfIXSOGL2JA)YdL6FHzbySaq0WcGzPhlwtYSaazrD1AMBFEToJjciAm4ZdaXcWZcazPplDDSOUAnZTpVwNXebeng85bGyjEwIlGGfail9yzwf1GdkYG)QT059e4JM3nu5QAcKfGNf0WsF7ne(KlpLS3U9516mMiGOjBX)Z(SJjG0262Bu5QAc0og2BGeomF09WYEloXelOxAuIHCnla4hWYRaXcatgtbmlQudoelolilwiXARallmzS3kpLS3O0Oed56mCalVcK9wy(JM3T3cqOgeAPmbp)vWmuQ)fMfGXcatMffSeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglamzwuWspwq4Z7QAYC7ZR1zmrart2I)hlDDSOUAnZTpVwNXebeng85bGyjEwIBYSayw6XYSkQbhuKb)vBPZ7jWhnVBOYv1eilaplahw6ZsFw66yrfIXSOGL2JA)YdL6FHzbySexaL9MhUhw2BuAuIHCDgoGLxbY(SJPsjBBD7nQCvnbAhd7nqchMp6EyzVfNyILn4sRP7luSaGzPMGfGdMcywuPgCiwCwqwSqI1wbwwyYyVvEkzVHHlTMU7lu5zPMWElm)rZ72BbiudcTuMGN)kygk1)cZcWyb4WIcwSILaebvEDgeuD7jgwuWIvSeGiOYRZupQ9l3CILUowcqeu51zQh1(LBoXIcwcqOgeAPmbyHaceLVDkJJ(5pSzOu)lmlaJfGdlkyPhli85DvnzcWcbeikds4evGLUowcqOgeAPmbp)vWmuQ)fMfGXcWHL(S01XsaIGkVodcQU9edlkyPhlwXYSkQbhuKb)vBPZ7jWhnVBOYv1eilkyjaHAqOLYe88xbZqP(xywaglahw66yrD1AMXrqfCHZTHQyNWmuQ)fMfGXIswdlaMLESGgwaEwiG76JIiqZx4BwHdo4m4J4lkRsAnl9zrblQRwZmocQGlCUnuf7eMvel9zPRJfvigZIcwApQ9lpuQ)fMfGXcarJ9MhUhw2By4sRP7(cvEwQjSp7yQKs2w3EJkxvtG2XWEZd3dl7TVWHzDUQMYa3Lx3kndsi(azVfM)O5D7n1vRzcE(RGzOu)lmlXZIsOHffS0JfRyzwf1GdkYG)QT059e4JM3nu5QAcKLUowuxTMzCeubx4CBOk2jmdL6FHzbySOeazbWS0JL4YcWZI6Q1mQAieuVWNzfXsFwaml9yPhlakwaGSGgwaEwuxTMrvdHG6f(mRiw6ZcWZcbCxFuebA(cFZkCWbNbFeFrzvsRzPplkyrD1AMXrqfCHZTHQyNWSIyPplDDSOcXywuWs7rTF5Hs9VWSamwaiAS3kpLS3(chM15QAkdCxEDR0miH4dK9zhtLaOT1T3OYv1eODmS3ajCy(O7HL9M13FmlpMfNLXVDAyH0UkC8JyXINGLdYsQdeXIR1SalwwyIf85hl38fq0Hz5GSOsSO)IazzfXIL)2zbzXcjwBfyXlqwqgSqabIyXlqwwyILBNybGfilyn8ybwSeaz5BSOcVDwU5lGOdZIpelWILfMybF(XYnFbeDy7TW8hnVBVHWN3v1Kbw5fMY38fq0XIYSaqwuWIvSCZxarN5aOzihmroaHAqOLILUow6XccFExvtgyLxykFZxarhlkZIsS01XccFExvtgyLxykFZxarhlkZsCzPplkyPhlQRwZe88xbZkIffS0JfRyjarqLxNbbv3EIHLUowuxTMzCeubx4CBOk2jmdL6FHzbWS0Jf0WcWZYSkQbhuKb)vBPZ7jWhnVBOYv1eil9zbykZYnFbeDMtjJ6Q1YGRXVhwSOGf1vRzghbvWfo3gQIDcZkILUowuxTMzCeubx4CBOk2jY4VAlDEpb(O5DZkIL(S01Xsac1GqlLj45VcMHs9VWSaywailXZYnFbeDMtjtac1GqlLbCn(9WIffSyflQRwZe88xbZkIffS0JfRyjarqLxNPEu7xU5elDDSyfli85DvnzcWcbeikds4evGL(SOGfRyjarqLxNbOeZ7flDDSeGiOYRZupQ9l3CIffSGWN3v1KjaleqGOmiHtubwuWsac1GqlLjaleqGO8TtzC0p)HnRiwuWIvSeGqni0szcE(RGzfXIcw6XspwuxTMHc6pctz9Q8XmuQ)fML4zrPKzPRJf1vRzOG(JWugd1(ygk1)cZs8SOuYS0NffSyflZQOgCqrgvx7vGYWw2168T)fkSHkxvtGS01XspwuxTMr11EfOmSLDToF7FHcNl)wdzWNhaIfLzbnS01XI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSOmlacw6ZsFw66yrD1AgG(cCiWmLgbTqtkvxMkAq9XMmRiw6ZsxhlTh1(Lhk1)cZcWybGjZsxhli85DvnzGvEHP8nFbeDSOmljBVH1WdBVDZxarNs2BE4EyzVDZxarNs2NDmvkU2w3EJkxvtG2XWEZd3dl7TB(ci6aO9wy(JM3T3q4Z7QAYaR8ct5B(ci6yXkLzbGSOGfRy5MVaIoZPKzihmroaHAqOLILUowq4Z7QAYaR8ct5B(ci6yrzwailkyPhlQRwZe88xbZkIffS0JfRyjarqLxNbbv3EIHLUowuxTMzCeubx4CBOk2jmdL6FHzbWS0Jf0WcWZYSkQbhuKb)vBPZ7jWhnVBOYv1eil9zbykZYnFbeDMdGg1vRLbxJFpSyrblQRwZmocQGlCUnuf7eMvelDDSOUAnZ4iOcUW52qvStKXF1w68Ec8rZ7Mvel9zPRJLaeQbHwktWZFfmdL6FHzbWSaqwINLB(ci6mhanbiudcTugW143dlwuWIvSOUAntWZFfmRiwuWspwSILaebvEDM6rTF5MtS01XIvSGWN3v1KjaleqGOmiHtubw6ZIcwSILaebvEDgGsmVxSOGLESyflQRwZe88xbZkILUowSILaebvEDgeuD7jgw6ZsxhlbicQ86m1JA)YnNyrbli85DvnzcWcbeikds4evGffSeGqni0szcWcbeikF7ugh9ZFyZkIffSyflbiudcTuMGN)kywrSOGLES0Jf1vRzOG(JWuwVkFmdL6FHzjEwukzw66yrD1AgkO)imLXqTpMHs9VWSeplkLml9zrblwXYSkQbhuKr11EfOmSLDToF7FHcBOYv1eilDDS0Jf1vRzuDTxbkdBzxRZ3(xOW5YV1qg85bGyrzwqdlDDSOUAnJQR9kqzyl7AD(2)cfo7tWlYGppaelkZcGGL(S0NL(S01XI6Q1ma9f4qGzkncAHMuQUmv0G6JnzwrS01Xs7rTF5Hs9VWSamwayYS01XccFExvtgyLxykFZxarhlkZsY2Byn8W2B38fq0bq7ZoMkzn2w3EJkxvtG2XWEdKWH5JUhw2BXjMWS4AnlWBNgwGfllmXYFukMfyXsa0EZd3dl7TfMY)rPy7ZoMkHgBRBVrLRQjq7yyVbs4W8r3dl7T4ifEqIfpCpSyr)4JfvhtGSalwW)T87Hfs0eQhBV5H7HL92SQShUhwz9Jp7n8nF4SJPs2BH5pAE3EdHpVRQjZJZoKS30p(YLNs2BoKSp7yQeWX262Bu5QAc0og2BH5pAE3EBwf1GdkYO6AVcug2YUwNV9VqHneWD9rreO9g(MpC2Xuj7npCpSS3MvL9W9WkRF8zVPF8LlpLS3uH(zF2XujaLT1T3OYv1eODmS38W9WYEBwv2d3dRS(XN9M(XxU8uYEdF2N9zVPc9Z262XujBRBVrLRQjq7yyV5H7HL924iOcUW52qvStyVbs4W8r3dl7T4WqvStWIL)2zbzXcjwBfS3cZF08U9M6Q1mbp)vWmuQ)fML4zrj0yF2XeG2w3EJkxvtG2XWEZd3dl7nh0JUhbLXw8j1ElKiOP85dk6W2Xuj7TW8hnVBVPUAnJQR9kqzyl7AD(2)cfox(TgYGppaelaJfablkyrD1Agvx7vGYWw2168T)fkC2NGxKbFEaiwaglacwuWspwSIfq4zCqp6EeugBXN0mON6OiZ9bG(cflkyXkw8W9WY4GE09iOm2IpPzqp1rrMVYn9JA)yrbl9yXkwaHNXb9O7rqzSfFsZ7KRn3ha6luS01Xci8moOhDpckJT4tAENCTzOu)lmlXZsCzPplDDSacpJd6r3JGYyl(KMb9uhfzWNhaIfGXsCzrblGWZ4GE09iOm2IpPzqp1rrMHs9VWSamwqdlkybeEgh0JUhbLXw8jnd6PokYCFaOVqXsF7nqchMp6EyzVfNyILyb6r3JGyzZIpPSyzNkw8JfnHXSC7EXI1WsmGXY6SGppaeMfVaz5GSmuBi8ololatzaYc(8aqS4yw0(rS4ywIGy8RQjwGdl3NsS8hlyil)XIpZJGWSaGZcFS4TJgwCwIlGzbFEaiwiKh9dHTp7ygxBRBVrLRQjq7yyV5H7HL9wawiGar5BNY4OF(dBVbs4W8r3dl7T4etSGmyHaceXIL)2zbzXcjwBfyXYovSebX4xvtS4filWBNglpMyXYF7S4SedySSolQRwJfl7uXciHtuHVqzVfM)O5D7nRybCwpOPG5aiMffS0JLESGWN3v1KjaleqGOmiHtubwuWIvSeGqni0szcE(RGzihmblDDSOUAntWZFfmRiw6ZIcw6XI6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqSOmlacw66yrD1Agvx7vGYWw2168T)fkC2NGxKbFEaiwuMfabl9zPRJfvigZIcwApQ9lpuQ)fMfGXIsjZsF7ZoMwJT1T3OYv1eODmS38W9WYERTMezylt6vr2BGeomF09WYEloarpwCml3oXs7h8XcQailFXYTtS4SedySSolw(ceAHf4WIL)2z52jwqkLyEVyrD1ASahwS83ololacaJPalXc0JUhbXYMfFszXlqwS4)XsdoSGSyHeRTcS8nw(JflW6yrLyzfXIJY)IfvQbhILBNyjaYYJzP91J3jq7TW8hnVBV1JLES0Jf1vRzuDTxbkdBzxRZ3(xOW5YV1qg85bGyjEwaoS01XI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSeplahw6ZIcw6XIvSeGiOYRZGGQBpXWsxhlwXI6Q1mJJGk4cNBdvXoHzfXsFw6ZIcw6Xc4SEqtbZbqmlDDSeGqni0szcE(RGzOu)lmlXZcAsMLUow6XsaIGkVot9O2VCZjwuWsac1GqlLjaleqGO8TtzC0p)HndL6FHzjEwqtYS0NL(S0NLUow6Xci8moOhDpckJT4tAg0tDuKzOu)lmlXZcGGffSeGqni0szcE(RGzOu)lmlXZIsjZIcwcqeu51zkkmqnCazPplDDSOcXywuWYxhnrqTFeyU9O2V8qP(xywaglacwuWIvSeGqni0szcE(RGzihmblDDSeGiOYRZauI59IffSOUAndqFboeyMsJGwOjLQZSIyPRJLaebvEDgeuD7jgwuWI6Q1mJJGk4cNBdvXoHzOu)lmlaJfajlkyrD1AMXrqfCHZTHQyNWSISp7yIgBRBVrLRQjq7yyV5H7HL9wWRaPZQRwZElm)rZ72B9yrD1Agvx7vGYWw2168T)fkCU8BnKzOu)lmlXZcGYGgw66yrD1Agvx7vGYWw2168T)fkC2NGxKzOu)lmlXZcGYGgw6ZIcw6Xsac1GqlLj45VcMHs9VWSeplakw66yPhlbiudcTugkncAHMSkSandL6FHzjEwauSOGfRyrD1AgG(cCiWmLgbTqtkvxMkAq9XMmRiwuWsaIGkVodqjM3lw6ZsFwuWIJVX15iOfAyjELzjUjBVPUATC5PK9g(8rdhq7nqchMp6EyzVHmVcKMLTZhnCazXYF7S4SuKfwIbmwwNf1vRXIxGSGSyHeRTcS84cDhlUkCDSCqwujwwyc0(SJjWX262Bu5QAc0og2BE4EyzVHpFWRbfzVbs4W8r3dl7T44knILTZh8AqrywS83ololXaglRZI6Q1yrDDSuWJfl7uXseeQ)cfln4WcYIfsS2kWcCybP0xGdbYYw0p)HT3cZF08U9wpwuxTMr11EfOmSLDToF7FHcNl)wdzWNhaIL4zbGS01XI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSeplaKL(SOGLESeGiOYRZupQ9l3CILUowcqOgeAPmbp)vWmuQ)fML4zbqXsxhlwXccFExvtMayoalW)EyXIcwSILaebvEDgGsmVxS01XspwcqOgeAPmuAe0cnzvybAgk1)cZs8SaOyrblwXI6Q1ma9f4qGzkncAHMuQUmv0G6JnzwrSOGLaebvEDgGsmVxS0NL(SOGLESyflGWZ0wtImSLj9QiZ9bG(cflDDSyflbiudcTuMGN)kygYbtWsxhlwXsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPV9zhtaLT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXXvAelBNp41GIWSOsn4qSGmyHacezVfM)O5D7TESeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglOHffSyflGZ6bnfmhaXSOGLESGWN3v1KjaleqGOmiHtubw66yjaHAqOLYe88xbZqP(xywaglOHL(SOGfe(8UQMmbWCawG)9WIL(SOGfRybeEM2AsKHTmPxfzUpa0xOyrblbicQ86m1JA)YnNyrblwXc4SEqtbZbqmlkyHc6pctMVYELGffS44BCDocAHgwINfRjz7ZoMacBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS36XI6Q1mJJGk4cNBdvXoHzOu)lmlXZcAyPRJfRyrD1AMXrqfCHZTHQyNWSIyPplkyPhlQRwZa0xGdbMP0iOfAsP6YurdQp2KzOu)lmlaJfubqtQJCw6ZIcw6XI6Q1muq)rykJHAFmdL6FHzjEwqfanPoYzPRJf1vRzOG(JWuwVkFmdL6FHzjEwqfanPoYzPV9giHdZhDpSS3IJWcDhlGWJfW18fkwUDIfQazb2ybaJJGk4cZsCyOk2jqllGR5luSa0xGdbYcLgbTqtkvhlWHLVy52jw0o(ybvaKfyJfVyb9c6pct2Bi8jxEkzVbcV8qa31pukvh2(SJjG0262Bu5QAc0og2BE4EyzVHxv7hYElm)rZ72Bd1gcV7QAIffSC(GIoZ9Pu(GzWNyjEwuc4WIcw8OCyNcaXIcwq4Z7QAYacV8qa31pukvh2ElKiOP85dk6W2Xuj7ZoMkLST1T3OYv1eODmS38W9WYElfcR2pK9wy(JM3T3gQneE3v1elky58bfDM7tP8bZGpXs8SOuCnOHffS4r5WofaIffSGWN3v1KbeE5HaURFOuQoS9wirqt5Zhu0HTJPs2NDmvsjBRBVrLRQjq7yyV5H7HL9g(iT2NCt7dzVfM)O5D7THAdH3DvnXIcwoFqrN5(ukFWm4tSeplkbCybWSmuQ)fMffS4r5WofaIffSGWN3v1KbeE5HaURFOuQoS9wirqt5Zhu0HTJPs2NDmvcG2w3EJkxvtG2XWEZd3dl7TgCcug2YLFRHS3ajCy(O7HL9wCagtwGflbqwS83oCDSe8OOVqzVfM)O5D7npkh2Paq2NDmvkU2w3EJkxvtG2XWEZd3dl7nkncAHMSkSaT3ajCy(O7HL9g6LgbTqdlXawGSyzNkwCv46y5GSq1rdlolfzHLyaJL1zXYxGqlS4filyhbXsdoSGSyHeRTc2BH5pAE3ERhluq)ryYOxLp5Iq(Xsxhluq)ryYGHAFYfH8JLUowOG(JWKXRe5Iq(XsxhlQRwZO6AVcug2YUwNV9VqHZLFRHmdL6FHzjEwaug0WsxhlQRwZO6AVcug2YUwNV9VqHZ(e8ImdL6FHzjEwaug0Wsxhlo(gxNJGwOHL4zbqMmlkyjaHAqOLYe88xbZqoycwuWIvSaoRh0uWCaeZsFwuWspwcqOgeAPmbp)vWmuQ)fML4zjUjZsxhlbiudcTuMGN)kygYbtWsFw66yrfIXSOGLVoAIGA)iWC7rTF5Hs9VWSamwukz7ZoMkzn2w3EJkxvtG2XWEZd3dl7T2AsKHTmPxfzVbs4W8r3dl7T4ae9yzEu7hlQudoell8xOybzXYElm)rZ72BbiudcTuMGN)kygYbtWIcwq4Z7QAYeaZbyb(3dlwuWspwC8nUohbTqdlXZcGmzwuWIvSeGiOYRZupQ9l3CILUowcqeu51zQh1(LBoXIcwC8nUohbTqdlaJfRjzw6ZIcwSILaebvEDgeuD7jgwuWspwSILaebvEDM6rTF5MtS01Xsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPplkyXkwaN1dAkyoaITp7yQeASTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEZkwaN1dAkyoaIzrbli85DvnzcG5aSa)7HflkyPhl9yXX346Ce0cnSeplaYKzrbl9yrD1AgG(cCiWmLgbTqtkvxMkAq9XMmRiw66yXkwcqeu51zakX8EXsFw66yrD1AgvnecQx4ZSIyrblQRwZOQHqq9cFMHs9VWSamwuxTMj45VcgW143dlw6ZsxhlFD0eb1(rG52JA)YdL6FHzbySOUAntWZFfmGRXVhwS01XsaIGkVot9O2VCZjw6ZIcw6XIvSeGiOYRZupQ9l3CILUow6XIJVX15iOfAybySynjZsxhlGWZ0wtImSLj9QiZ9bG(cfl9zrbl9ybHpVRQjtawiGarzqcNOcS01Xsac1GqlLjaleqGO8TtzC0p)Hnd5GjyPpl9T3ajCy(O7HL9gYIfsS2kWILDQyXpwaKjdywIfgaXsp4OHwOHLB3lwSMKzjwyaelw(BNfKbleqGO(Sy5VD46yrdXFHIL7tjw(ILyOHqq9cFS4fil6ViwwrSy5VDwqgSqabIy5BS8hlwCmlGeorfiq7ne(KlpLS3cG5aSa)7Hvwf6N9zhtLao2w3EJkxvtG2XWElm)rZ72Bi85DvnzcG5aSa)7Hvwf6N9MhUhw2Bbst47DD21pQkLQZ(SJPsakBRBVrLRQjq7yyVfM)O5D7ne(8UQMmbWCawG)9WkRc9ZEZd3dl7TVc(u(9WY(SJPsacBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS3OG(JWK5RSEv(WcWZcGGfKWIhUhwg85t7hYqiNcRJY3NsSaywSIfkO)imz(kRxLpSa8S0JfGdlaMLZ1uDgmCPZWw(2PCdoe(mu5QAcKfGNL4YsFwqclE4EyzSm(TBiKtH1r57tjwamljBailiHfCeP15DhFK9giHdZhDpSS3qp89P(ryw2HwyjDf2zjwyael(qSGY)IazjIgwWuawG2Bi8jxEkzV54iaenBuW(SJPsasBRBVrLRQjq7yyV5H7HL9g(8bVguK9giHdZhDpSS3IJR0iw2oFWRbfHzXYovSC7elTh1(XYJzXvHRJLdYcvGOLL2qvStWYJzXvHRJLdYcvGOLLeWfl(qS4hlaYKbmlXcdGy5lw8If0lO)imHwwqwSqI1wbw0o(WS4f82PHfabGXuaZcCyjbCXIf4sdYcebnbpILu4qSC7EXc3PuYSelmaIfl7uXsc4IflWLgSq3XY25dEnOiwkOf7TW8hnVBV1JfvigZIcw(6OjcQ9JaZTh1(Lhk1)cZcWyXAyPRJLESOUAnZ4iOcUW52qvStygk1)cZcWybva0K6iNfGNLa9Aw6XIJVX15iOfAybjSe3KzPplkyrD1AMXrqfCHZTHQyNWSIyPpl9zPRJLES44BCDocAHgwamli85DvnzCCeaIMnkWcWZI6Q1muq)rykJHAFmdL6FHzbWSacptBnjYWwM0RIm3hacNhk1)IfGNfaAqdlXZIskLmlDDS44BCDocAHgwamli85DvnzCCeaIMnkWcWZI6Q1muq)rykRxLpMHs9VWSaywaHNPTMezylt6vrM7daHZdL6FXcWZcanOHL4zrjLsML(SOGfkO)imz(k7vcwuWspwSIf1vRzcE(RGzfXsxhlwXY5AQod(8rdhqdvUQMazPplkyPhl9yXkwcqOgeAPmbp)vWSIyPRJLaebvEDgGsmVxSOGfRyjaHAqOLYqPrql0KvHfOzfXsFw66yjarqLxNPEu7xU5el9zrbl9yXkwcqeu51zqq1TNyyPRJfRyrD1AMGN)kywrS01XIJVX15iOfAyjEwaKjZsFw66yPhlNRP6m4ZhnCanu5QAcKffSOUAntWZFfmRiwuWspwuxTMbF(OHdObFEaiwaglXLLUowC8nUohbTqdlXZcGmzw6ZsFw66yrD1AMGN)kywrSOGfRyrD1AMXrqfCHZTHQyNWSIyrblwXY5AQod(8rdhqdvUQMaTp7ycWKTTU9gvUQMaTJH9MhUhw2BfzjNcHL9giHdZhDpSS3ItmXcawiSWS8flO)Q8Hf0lO)imXIxGSGDeeliLX1nahhwAnlayHWILgCybzXcjwBfS3cZF08U9wpwuxTMHc6pctz9Q8XmuQ)fML4zHqofwhLVpLyPRJLESe29bfHzrzwailkyzOWUpOO89PelaJf0WsFw66yjS7dkcZIYSexw6ZIcw8OCyNcazF2XeGkzBD7nQCvnbAhd7TW8hnVBV1Jf1vRzOG(JWuwVkFmdL6FHzjEwiKtH1r57tjwuWspwcqOgeAPmbp)vWmuQ)fML4zbnjZsxhlbiudcTuMaSqabIY3oLXr)8h2muQ)fML4zbnjZsFw66yPhlHDFqrywuMfaYIcwgkS7dkkFFkXcWybnS0NLUowc7(GIWSOmlXLL(SOGfpkh2Paq2BE4EyzVT76wofcl7ZoMaeG2w3EJkxvtG2XWElm)rZ72B9yrD1AgkO)imL1RYhZqP(xywINfc5uyDu((uIffS0JLaeQbHwktWZFfmdL6FHzjEwqtYS01Xsac1GqlLjaleqGO8TtzC0p)HndL6FHzjEwqtYS0NLUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaK9MhUhw2BTLwNtHWY(SJjaJRT1T3OYv1eODmS3ajCy(O7HL9gsbe9ybwSeaT38W9WYEZIpZdNmSLj9Qi7ZoMa0ASTU9gvUQMaTJH9MhUhw2B4ZN2pK9giHdZhDpSS3ItmXY25t7hILdYs0adSSb1(Wc6f0FeMyboSyzNkw(IfyPtWc6VkFyb9c6pctS4fillmXcsbe9yjAGbmlFJLVyb9xLpSGEb9hHj7TW8hnVBVrb9hHjZxz9Q8HLUowOG(JWKbd1(Klc5hlDDSqb9hHjJxjYfH8JLUowuxTMXIpZdNmSLj9QiZkIffSOUAndf0FeMY6v5JzfXsxhl9yrD1AMGN)kygk1)cZcWyXd3dlJLXVDdHCkSokFFkXIcwuxTMj45VcMvel9Tp7ycq0yBD7npCpSS3Sm(TBVrLRQjq7yyF2XeGahBRBVrLRQjq7yyV5H7HL92SQShUhwz9Jp7n9JVC5PK9wZ16BFw2N9zV5qY262XujBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS36XI6Q1m3NswGtLbhYtv)cKgZqP(xywaglOcGMuh5Sayws2OelDDSOUAnZ9PKf4uzWH8u1VaPXmuQ)fMfGXIhUhwg85t7hYqiNcRJY3NsSayws2OelkyPhluq)ryY8vwVkFyPRJfkO)imzWqTp5Iq(Xsxhluq)ryY4vICri)yPpl9zrblQRwZCFkzbovgCipv9lqAmRiwuWYSkQbhuK5(uYcCQm4qEQ6xG0yOYv1eO9giHdZhDpSS3qMRdlTFeMfl70Ttdl3oXsCCipn4xyNgwuxTglwETMLMR1SaBnwS83(xSC7elfH8JLGJp7ne(KlpLS3ahYtZwETo3CTodBn7ZoMa0262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nRyHc6pctMVYyO2hwuWspwWrKwNpFqrh2GpFA)qSeplOHffSCUMQZGHlDg2Y3oLBWHWNHkxvtGS01XcoI0685dk6Wg85t7hIL4zbqXsF7nqchMp6EyzVHmxhwA)imlw2PBNgw2oFWRbfXYJzXcCUDwco((cflqe0WY25t7hILVyb9xLpSGEb9hHj7ne(KlpLS3EufCOm(8bVguK9zhZ4ABD7nQCvnbAhd7npCpSS3cWcbeikF7ugh9ZFy7nqchMp6EyzVfNyIfKbleqGiwSStfl(XIMWywUDVybnjZsSWaiw8cKf9xelRiwS83olilwiXARG9wy(JM3T3SIfWz9GMcMdGywuWspw6XccFExvtMaSqabIYGeorfyrblwXsac1GqlLj45VcMHCWeS01XI6Q1mbp)vWSIyPplkyPhlQRwZqb9hHPSEv(ygk1)cZs8SaCyPRJf1vRzOG(JWugd1(ygk1)cZs8SaCyPplkyPhlwXYSkQbhuKr11EfOmSLDToF7FHcBOYv1eilDDSOUAnJQR9kqzyl7AD(2)cfox(TgYGppaelXZsCzPRJf1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGyjEwIll9zPRJfvigZIcwApQ9lpuQ)fMfGXIsjZIcwSILaeQbHwktWZFfmd5GjyPV9zhtRX262Bu5QAc0og2BE4EyzVnocQGlCUnuf7e2BGeomF09WYEloXelXHHQyNGfl)TZcYIfsS2kyVfM)O5D7n1vRzcE(RGzOu)lmlXZIsOX(SJjASTU9gvUQMaTJH9MhUhw2B4v1(HS3cjcAkF(GIoSDmvYElm)rZ72B9yzO2q4DxvtS01XI6Q1muq)rykJHAFmdL6FHzbySexwuWcf0FeMmFLXqTpSOGLHs9VWSamwuYAyrblNRP6my4sNHT8Tt5gCi8zOYv1eil9zrblNpOOZCFkLpyg8jwINfLSgwaGSGJiToF(GIomlaMLHs9VWSOGLESqb9hHjZxzVsWsxhldL6FHzbySGkaAsDKZsF7nqchMp6EyzVfNyILTv1(Hy5lwI8cKs)alWIfVsC7FHILB3pw0pccZIswdMcyw8cKfnHXSy5VDwsHdXY5dk6WS4fil(XYTtSqfilWglolBqTpSGEb9hHjw8JfLSgwWuaZcCyrtymldL6F9fkwCmlhKLcESS7i(cflhKLHAdH3zbCnFHIf0Fv(Wc6f0FeMSp7ycCSTU9gvUQMaTJH9MhUhw2B4ZNMR12BGeomF09WYEdPerrSSIyz78P5Anl(XIR1SCFkHzzvAcJzzH)cflOFIGpoMfVaz5pwEmlUkCDSCqwIgyGf4WIMowUDIfCefExZIhUhwSO)IyrL0qlSS7fOMyjooKNQ(finSalwailNpOOdBVfM)O5D7nRy5CnvNbFKw7tgC(2zOYv1eilkyPhlQRwZGpFAUwBgQneE3v1elkyPhl4isRZNpOOdBWNpnxRzbySexw66yXkwMvrn4GIm3NswGtLbhYtv)cKgdvUQMazPplDDSCUMQZGHlDg2Y3oLBWHWNHkxvtGSOGf1vRzOG(JWugd1(ygk1)cZcWyjUSOGfkO)imz(kJHAFyrblQRwZGpFAUwBgk1)cZcWybqXIcwWrKwNpFqrh2GpFAUwZs8kZI1WsFwuWspwSILzvudoOiJorWhhNBAIUVqLrP)0imzOYv1eilDDSCFkXcsLfRbnSeplQRwZGpFAUwBgk1)cZcGzbGS0NffSC(GIoZ9Pu(GzWNyjEwqJ9zhtaLT1T3OYv1eODmS38W9WYEdF(0CT2EdKWH5JUhw2Bif)TZY2rATpSehNVDSSWelWILailw2PILHAdH3DvnXI66ybFVwZIf)pwAWHf0prWhhZs0adS4filGWcDhllmXIk1GdXcYIJydlB3R1SSWelQudoelidwiGarSG)kqSC7(XILxRzjAGbw8cE70WY25tZ1A7TW8hnVBVDUMQZGpsR9jdoF7mu5QAcKffSOUAnd(8P5ATzO2q4DxvtSOGLESyflZQOgCqrgDIGpoo30eDFHkJs)PryYqLRQjqw66y5(uIfKklwdAyjEwSgw6ZIcwoFqrN5(ukFWm4tSeplX1(SJjGW262Bu5QAc0og2BE4EyzVHpFAUwBVbs4W8r3dl7nKI)2zjooKNQ(finSSWelBNpnxRz5GSaerrSSIy52jwuxTglQjyX1yill8xOyz78P5AnlWIf0WcMcWceZcCyrtymldL6F9fk7TW8hnVBVnRIAWbfzUpLSaNkdoKNQ(fingQCvnbYIcwWrKwNpFqrh2GpFAUwZs8kZsCzrbl9yXkwuxTM5(uYcCQm4qEQ6xG0ywrSOGf1vRzWNpnxRnd1gcV7QAILUow6XccFExvtgWH80SLxRZnxRZWwJffS0Jf1vRzWNpnxRndL6FHzbySexw66ybhrAD(8bfDyd(8P5AnlXZcazrblNRP6m4J0AFYGZ3odvUQMazrblQRwZGpFAUwBgk1)cZcWybnS0NL(S03(SJjG0262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nhFJRZrql0Ws8SaisMfail9yrPKzb4zrD1AM7tjlWPYGd5PQFbsJbFEaiw6ZcaKLESOUAnd(8P5ATzOu)lmlaplXLfKWcoI068UJpIfGNfRy5CnvNbFKw7tgC(2zOYv1eil9zbaYspwcqOgeAPm4ZNMR1MHs9VWSa8Sexwqcl4isRZ7o(iwaEwoxt1zWhP1(KbNVDgQCvnbYsFwaGS0Jfq4zARjrg2YKEvKzOu)lmlaplOHL(SOGLESOUAnd(8P5ATzfXsxhlbiudcTug85tZ1AZqP(xyw6BVbs4W8r3dl7nK56Ws7hHzXYoD70WIZY25dEnOiwwyIflVwZsWxyILTZNMR1SCqwAUwZcS1qllEbYYctSSD(GxdkILdYcqefXsCCipv9lqAybFEaiwwr2Bi8jxEkzVHpFAUwNTaRl3CTodBn7ZoMkLST1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXjMyz78bVguelw(BNL44qEQ6xG0WYbzbiIIyzfXYTtSOUAnwS83oCDSOH4VqXY25tZ1Awwr3NsS4fillmXY25dEnOiwGflwdGzjgWyzDwWNhacZYQUxZI1WY5dk6W2BH5pAE3EdHpVRQjd4qEA2YR15MR1zyRXIcwq4Z7QAYGpFAUwNTaRl3CTodBnwuWIvSGWN3v1K5rvWHY4Zh8AqrS01XspwuxTMr11EfOmSLDToF7FHcNl)wdzWNhaIL4zjUS01XI6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqSeplXLL(SOGfCeP15Zhu0Hn4ZNMR1SamwSgwuWccFExvtg85tZ16SfyD5MR1zyRzF2XujLSTU9gvUQMaTJH9MhUhw2BoOhDpckJT4tQ9wirqt5Zhu0HTJPs2BH5pAE3EZkwUpa0xOyrblwXIhUhwgh0JUhbLXw8jnd6PokY8vUPFu7hlDDSacpJd6r3JGYyl(KMb9uhfzWNhaIfGXsCzrblGWZ4GE09iOm2IpPzqp1rrMHs9VWSamwIR9giHdZhDpSS3ItmXc2IpPSGHSC7(Xsc4Ifu0XsQJCwwr3NsSOMGLf(luS8hloMfTFeloMLiig)QAIfyXIMWywUDVyjUSGppaeMf4Wcaol8XILDQyjUaMf85bGWSqip6hY(SJPsa0262Bu5QAc0og2BE4EyzVLcHv7hYElKiOP85dk6W2Xuj7TW8hnVBVnuBi8URQjwuWY5dk6m3Ns5dMbFIL4zPhl9yrjRHfaZspwWrKwNpFqrh2GpFA)qSa8SaqwaEwuxTMHc6pctz9Q8XSIyPpl9zbWSmuQ)fML(SGew6XIsSaywoxt1zolFLtHWcBOYv1eil9zrbl9yjaHAqOLYe88xbZqoycwuWIvSaoRh0uWCaeZIcw6XccFExvtMaSqabIYGeorfyPRJLaeQbHwktawiGar5BNY4OF(dBgYbtWsxhlwXsaIGkVot9O2VCZjw6Zsxhl4isRZNpOOdBWNpTFiwagl9yPhlahwaGS0Jf1vRzOG(JWuwVkFmRiwaEwail9zPplapl9yrjwamlNRP6mNLVYPqyHnu5QAcKL(S0NffSyfluq)ryYGHAFYfH8JLUow6Xcf0FeMmFLXqTpS01XspwOG(JWK5RSk82zPRJfkO)imz(kRxLpS0NffSyflNRP6my4sNHT8Tt5gCi8zOYv1eilDDSOUAnt08PWb8DD2NGxFihT0yFmiC9IyjELzbGOjzw6ZIcw6XcoI0685dk6Wg85t7hIfGXIsjZcWZspwuIfaZY5AQoZz5RCkewydvUQMazPpl9zrblo(gxNJGwOHL4zbnjZcaKf1vRzWNpnxRndL6FHzb4zb4WsFwuWspwSIf1vRza6lWHaZuAe0cnPuDzQOb1hBYSIyPRJfkO)imz(kJHAFyPRJfRyjarqLxNbOeZ7fl9zrblwXI6Q1mJJGk4cNBdvXorg)vBPZ7jWhnVBwr2BGeomF09WYEdad1gcVZcawiSA)qS8nwqwSqI1wbwEmld5Gjqll3onel(qSOjmMLB3lwqdlNpOOdZYxSG(RYhwqVG(JWelw(BNLn4fhqllAcJz529IfLsMf4TtJLhtS8flELGf0lO)imXcCyzfXYbzbnSC(GIomlQudoelolO)Q8Hf0lO)imzyjocl0DSmuBi8olGR5luSGu6lWHazb9sJGwOjLQJLvPjmMLVyzdQ9Hf0lO)imzF2XuP4ABD7nQCvnbAhd7npCpSS3AWjqzylx(TgYEdKWH5JUhw2BXjMyjoaJjlWILailw(BhUowcEu0xOS3cZF08U9MhLd7uai7ZoMkzn2w3EJkxvtG2XWEdgzVHPZEZd3dl7ne(8UQMS3q46fzVzflGZ6bnfmhaXSOGfe(8UQMmbWCawG)9WIffS0JLESOUAnd(8P5ATzfXsxhlNRP6m4J0AFYGZ3odvUQMazPRJLaebvEDM6rTF5MtS0NffS0JfRyrD1AgmuJVpqMvelkyXkwuxTMj45VcMvelkyPhlwXY5AQotBnjYWwM0RImu5QAcKLUowuxTMj45VcgW143dlwINLaeQbHwktBnjYWwM0RImdL6FHzbWSaiyPplkybHpVRQjZTpVwNXebenzl(FSOGLESyflbicQ86m1JA)YnNyPRJLaeQbHwktawiGar5BNY4OF(dBwrSOGLESOUAnd(8P5ATzOu)lmlaJfaYsxhlwXY5AQod(iT2Nm48TZqLRQjqw6ZsFwuWY5dk6m3Ns5dMbFIL4zrD1AMGN)kyaxJFpSyb4zjzdGIL(S01Xs7rTF5Hs9VWSamwuxTMj45VcgW143dlw6BVHWNC5PK9wamhGf4FpSYoKSp7yQeASTU9gvUQMaTJH9MhUhw2Bbst47DD21pQkLQZEdKWH5JUhw2BXjMybzXcjwBfybwSeazzvAcJzXlqw0FrS8hlRiwS83olidwiGar2BH5pAE3EdHpVRQjtamhGf4FpSYoKSp7yQeWX262Bu5QAc0og2BH5pAE3EdHpVRQjtamhGf4FpSYoKS38W9WYE7RGpLFpSSp7yQeGY262Bu5QAc0og2BE4EyzVrPrql0KvHfO9giHdZhDpSS3ItmXc6LgbTqdlXawGSalwcGSy5VDw2oFAUwZYkIfVazb7iiwAWHfa0sJ9HfVazbzXcjwBfS3cZF08U9MkeJzrblFD0eb1(rG52JA)YdL6FHzbySOeAyPRJLESOUAnt08PWb8DD2NGxFihT0yFmiC9IybySaq0KmlDDSOUAnt08PWb8DD2NGxFihT0yFmiC9IyjELzbGOjzw6ZIcwuxTMbF(0CT2SIyrbl9yjaHAqOLYe88xbZqP(xywINf0KmlDDSaoRh0uWCaeZsF7ZoMkbiSTU9gvUQMaTJH9MhUhw2B4J0AFYnTpK9wirqt5Zhu0HTJPs2BH5pAE3EBO2q4DxvtSOGL7tP8bZGpXs8SOeAyrbl4isRZNpOOdBWNpTFiwaglwdlkyXJYHDkaelkyPhlQRwZe88xbZqP(xywINfLsMLUowSIf1vRzcE(RGzfXsF7nqchMp6EyzVbGHAdH3zPP9HybwSSIy5GSexwoFqrhMfl)TdxhlilwiXARalQ0xOyXvHRJLdYcH8OFiw8cKLcESarqtWJI(cL9zhtLaK2w3EJkxvtG2XWEZd3dl7T2AsKHTmPxfzVbs4W8r3dl7T4etSehGOhlFJLVWpiXIxSGEb9hHjw8cKf9xel)XYkIfl)TZIZcaAPX(Ws0adS4filXc0JUhbXYMfFsT3cZF08U9gf0FeMmFL9kblkyXJYHDkaelkyrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGOjzwuWspwaHNXb9O7rqzSfFsZGEQJIm3ha6luS01XIvSeGiOYRZuuyGA4aYsxhl4isRZNpOOdZs8Saqw6ZIcw6XI6Q1mJJGk4cNBdvXoHzOu)lmlaJfajlaqw6XcAyb4zzwf1GdkYG)QT059e4JM3nu5QAcKL(SOGf1vRzghbvWfo3gQIDcZkILUowSIf1vRzghbvWfo3gQIDcZkIL(SOGLESyflbiudcTuMGN)kywrS01XI6Q1m3(8ADgteq0yWNhaIfGXIsOHffS0Eu7xEOu)lmlaJfaMCYSOGL2JA)YdL6FHzjEwuk5KzPRJfRybdxA1Van3(8ADgteq0yOYv1eil9zrbl9ybdxA1Van3(8ADgteq0yOYv1eilDDSeGqni0szcE(RGzOu)lmlXZsCtML(2NDmbyY2w3EJkxvtG2XWEZd3dl7n85tZ1A7nqchMp6EyzVfNyIfNLTZNMR1SaGVOBNLObgyzvAcJzz78P5AnlpMfxpKdMGLvelWHLeWfl(qS4QW1XYbzbIGMGhXsSWai7TW8hnVBVPUAndSOBhNJOjqr3dlZkIffS0Jf1vRzWNpnxRnd1gcV7QAILUowC8nUohbTqdlXZcGmzw6BF2XeGkzBD7nQCvnbAhd7npCpSS3WNpnxRT3ajCy(O7HL9wCCLgXsSWaiwuPgCiwqgSqabIyXYF7SSD(0CTMfVaz52PILTZh8Aqr2BH5pAE3ElarqLxNPEu7xU5elkyXkwoxt1zWhP1(KbNVDgQCvnbYIcw6XccFExvtMaSqabIYGeorfyPRJLaeQbHwktWZFfmRiw66yrD1AMGN)kywrS0NffSeGqni0szcWcbeikF7ugh9ZFyZqP(xywaglOcGMuh5Sa8SeOxZspwC8nUohbTqdliHf0Kml9zrblQRwZGpFAUwBgk1)cZcWyXAyrblwXc4SEqtbZbqS9zhtacqBRBVrLRQjq7yyVfM)O5D7TaebvEDM6rTF5MtSOGLESGWN3v1KjaleqGOmiHtubw66yjaHAqOLYe88xbZkILUowuxTMj45VcMvel9zrblbiudcTuMaSqabIY3oLXr)8h2muQ)fMfGXcWHffSOUAnd(8P5ATzfXIcwOG(JWK5RSxjyrblwXccFExvtMhvbhkJpFWRbfXIcwSIfWz9GMcMdGy7npCpSS3WNp41GISp7ycW4ABD7nQCvnbAhd7npCpSS3WNp41GIS3ajCy(O7HL9wCIjw2oFWRbfXIL)2zXlwaWx0TZs0adSahw(gljGl0bYcebnbpILyHbqSy5VDwsaxdlfH8JLGJpdlXsJHSaUsJyjwyael(XYTtSqfilWgl3oXcaUuD7jgwuxTglFJLTZNMR1SybU0Gf6owAUwZcS1yboSKaUyXhIfyXcaz58bfDy7TW8hnVBVPUAndSOBhNdAYNmIh)WYSIyPRJLESyfl4ZN2pKXJYHDkaelkyXkwq4Z7QAY8Ok4qz85dEnOiw66yPhlQRwZe88xbZqP(xywaglOHffSOUAntWZFfmRiw66yPhl9yrD1AMGN)kygk1)cZcWybva0K6iNfGNLa9Aw6XIJVX15iOfAybjSe3KzPplkyrD1AMGN)kywrS01XI6Q1mJJGk4cNBdvXorg)vBPZ7jWhnVBgk1)cZcWybva0K6iNfGNLa9Aw6XIJVX15iOfAybjSe3KzPplkyrD1AMXrqfCHZTHQyNiJ)QT059e4JM3nRiw6ZIcwcqeu51zqq1TNyyPpl9zrbl9ybhrAD(8bfDyd(8P5AnlaJL4Ysxhli85DvnzWNpnxRZwG1LBUwNHTgl9zPplkyXkwq4Z7QAY8Ok4qz85dEnOiwuWspwSILzvudoOiZ9PKf4uzWH8u1VaPXqLRQjqw66ybhrAD(8bfDyd(8P5AnlaJL4YsF7ZoMa0ASTU9gvUQMaTJH9MhUhw2BfzjNcHL9giHdZhDpSS3ItmXcawiSWS8flBqTpSGEb9hHjw8cKfSJGyjoS0AwaWcHfln4WcYIfsS2kyVfM)O5D7TESOUAndf0FeMYyO2hZqP(xywINfc5uyDu((uILUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaK9zhtaIgBRBVrLRQjq7yyVfM)O5D7TESOUAndf0FeMYyO2hZqP(xywINfc5uyDu((uILUow6Xsy3hueMfLzbGSOGLHc7(GIY3NsSamwqdl9zPRJLWUpOimlkZsCzPplkyXJYHDkaelkyPhlQRwZmocQGlCUnuf7eMHs9VWSamwqdlkyrD1AMXrqfCHZTHQyNWSIyrblwXYSkQbhuKb)vBPZ7jWhnVBOYv1eilDDSyflQRwZmocQGlCUnuf7eMvel9T38W9WYEB31TCkew2NDmbiWX262Bu5QAc0og2BH5pAE3ERhlQRwZqb9hHPmgQ9XmuQ)fML4zHqofwhLVpLyrbl9yjaHAqOLYe88xbZqP(xywINf0KmlDDSeGqni0szcWcbeikF7ugh9ZFyZqP(xywINf0Kml9zPRJLESe29bfHzrzwailkyzOWUpOO89PelaJf0WsFw66yjS7dkcZIYSexw6ZIcw8OCyNcaXIcw6XI6Q1mJJGk4cNBdvXoHzOu)lmlaJf0WIcwuxTMzCeubx4CBOk2jmRiwuWIvSmRIAWbfzWF1w68Ec8rZ7gQCvnbYsxhlwXI6Q1mJJGk4cNBdvXoHzfXsF7npCpSS3AlToNcHL9zhtacOSTU9gvUQMaTJH9giHdZhDpSS3ItmXcsbe9ybwSGS4O9MhUhw2Bw8zE4KHTmPxfzF2XeGacBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS3WrKwNpFqrh2GpFA)qSeplwdlaMLMgchw6XsQJpAsKr46fXcWZIsjNmliHfaMml9zbWS00q4WspwuxTMbF(GxdkktPrql0Ks1LXqTpg85bGybjSynS03EdKWH5JUhw2BiZ1HL2pcZILD62PHLdYYctSSD(0(Hy5lw2GAFyXY(h2z5XS4hlOHLZhu0HbSsS0GdlecAsWcatgPYsQJpAsWcCyXAyz78bVguelOxAe0cnPuDSGppae2EdHp5Ytj7n85t7hk)vgd1(yF2XeGasBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS3uIfKWcoI068UJpIfGXcazbaYspws2aqwaEw6XcoI0685dk6Wg85t7hIfailkXsFwaEw6XIsSaywoxt1zWWLodB5BNYn4q4ZqLRQjqwaEwuYGgw6ZsFwamljBucnSa8SOUAnZ4iOcUW52qvStygk1)cBVbs4W8r3dl7nK56Ws7hHzXYoD70WYbzbPy8BNfW18fkwIddvXoH9gcFYLNs2Bwg)2ZFLBdvXoH9zhZ4MST1T3OYv1eODmS38W9WYEZY43U9giHdZhDpSS3ItmXcsX43olFXYgu7dlOxq)ryIf4WY3yPGSSD(0(HyXYR1S0(JLVoililwiXARalELifoK9wy(JM3T36Xcf0FeMm6v5tUiKFS01Xcf0FeMmELixeYpwuWccFExvtMhNdAYrqS0NffS0JLZhu0zUpLYhmd(elXZI1Wsxhluq)ryYOxLp5VYaKLUowApQ9lpuQ)fMfGXIsjZsFw66yrD1AgkO)imLXqTpMHs9VWSamw8W9WYGpFA)qgc5uyDu((uIffSOUAndf0FeMYyO2hZkILUowOG(JWK5RmgQ9HffSyfli85DvnzWNpTFO8xzmu7dlDDSOUAntWZFfmdL6FHzbyS4H7HLbF(0(HmeYPW6O89PelkyXkwq4Z7QAY84CqtocIffSOUAntWZFfmdL6FHzbySqiNcRJY3NsSOGf1vRzcE(RGzfXsxhlQRwZmocQGlCUnuf7eMvelkybHpVRQjJLXV98x52qvStWsxhlwXccFExvtMhNdAYrqSOGf1vRzcE(RGzOu)lmlXZcHCkSokFFkzF2XmUkzBD7nQCvnbAhd7nqchMp6EyzVfNyILTZN2pelFJLVyb9xLpSGEb9hHj0YYxSSb1(Wc6f0FeMybwSynaMLZhu0HzboSCqwIgyGLnO2hwqVG(JWK9MhUhw2B4ZN2pK9zhZ4cqBRBVrLRQjq7yyVbs4W8r3dl7T4GR13(SS38W9WYEBwv2d3dRS(XN9M(XxU8uYER5A9Tpl7Z(S3AUwF7ZY262XujBRBVrLRQjq7yyV5H7HL9g(8bVguK9giHdZhDpSS32oFWRbfXsdoSKcrqPuDSSknHXSSWFHILyaJL1T3cZF08U9MvSmRIAWbfzuDTxbkdBzxRZ3(xOWgc4U(Oic0(SJjaTTU9gvUQMaTJH9MhUhw2B4v1(HS3cjcAkF(GIoSDmvYElm)rZ72BGWZKcHv7hYmuQ)fML4zzOu)lmlaplaeGSGewucqyVbs4W8r3dl7nK54JLBNybeESy5VDwUDILui(y5(uILdYIdcYYQUxZYTtSK6iNfW143dlwEml7)zyzBvTFiwgk1)cZs6sFFK(jqwoilP(f2zjfcR2pelGRXVhw2NDmJRT1T38W9WYElfcR2pK9gvUQMaTJH9zF2B4Z262XujBRBVrLRQjq7yyV5H7HL9g(8bVguK9giHdZhDpSS3ItmXY25dEnOiwoilaruelRiwUDIL44qEQ6xG0WI6Q1y5BS8hlwGlnileYJ(HyrLAWHyP91J3)cfl3oXsri)yj44Jf4WYbzbCLgXIk1GdXcYGfciqK9wy(JM3T3Mvrn4GIm3NswGtLbhYtv)cKgdvUQMazrbl9yHc6pctMVYELGffSyfl9yPhlQRwZCFkzbovgCipv9lqAmdL6FHzjEw8W9WYyz8B3qiNcRJY3NsSayws2OelkyPhluq)ryY8vwfE7S01Xcf0FeMmFLXqTpS01Xcf0FeMm6v5tUiKFS0NLUowuxTM5(uYcCQm4qEQ6xG0ygk1)cZs8S4H7HLbF(0(HmeYPW6O89PelaMLKnkXIcw6Xcf0FeMmFL1RYhw66yHc6pctgmu7tUiKFS01Xcf0FeMmELixeYpw6ZsFw66yXkwuxTM5(uYcCQm4qEQ6xG0ywrS0NLUow6XI6Q1mbp)vWSIyPRJfe(8UQMmbyHaceLbjCIkWsFwuWsac1GqlLjaleqGO8TtzC0p)Hnd5GjyrblbicQ86m1JA)YnNyPplkyPhlwXsaIGkVodqjM3lw66yjaHAqOLYqPrql0KvHfOzOu)lmlXZcGGL(SOGLESOUAntWZFfmRiw66yXkwcqOgeAPmbp)vWmKdMGL(2NDmbOT1T3OYv1eODmS38W9WYEZb9O7rqzSfFsT3cjcAkF(GIoSDmvYElm)rZ72BwXci8moOhDpckJT4tAg0tDuK5(aqFHIffSyflE4EyzCqp6EeugBXN0mON6OiZx5M(rTFSOGLESyflGWZ4GE09iOm2IpP5DY1M7da9fkw66ybeEgh0JUhbLXw8jnVtU2muQ)fML4zbnS0NLUowaHNXb9O7rqzSfFsZGEQJIm4ZdaXcWyjUSOGfq4zCqp6EeugBXN0mON6OiZqP(xywaglXLffSacpJd6r3JGYyl(KMb9uhfzUpa0xOS3ajCy(O7HL9wCIjwIfOhDpcILnl(KYILDQy52PHy5XSuqw8W9iiwWw8jfTS4yw0(rS4ywIGy8RQjwGflyl(KYIL)2zbGSahwAKfAybFEaimlWHfyXIZsCbmlyl(KYcgYYT7hl3oXsrwybBXNuw8zEeeMfaCw4JfVD0WYT7hlyl(KYcH8OFiS9zhZ4ABD7nQCvnbAhd7npCpSS3cWcbeikF7ugh9ZFy7nqchMp6EyzVfNycZcYGfciqelFJfKflKyTvGLhZYkIf4Wsc4IfFiwajCIk8fkwqwSqI1wbwS83olidwiGarS4filjGlw8HyrL0qlSynjZsSWai7TW8hnVBVzflGZ6bnfmhaXSOGLES0Jfe(8UQMmbyHaceLbjCIkWIcwSILaeQbHwktWZFfmd5GjyrblwXYSkQbhuKjA(u4a(Uo7tWRpKJwASpgQCvnbYsxhlQRwZe88xbZkIL(SOGfhFJRZrql0WcWuMfRjzwuWspwuxTMHc6pctz9Q8XmuQ)fML4zrPKzPRJf1vRzOG(JWugd1(ygk1)cZs8SOuYS0NLUowuHymlkyP9O2V8qP(xywaglkLmlkyXkwcqOgeAPmbp)vWmKdMGL(2NDmTgBRBVrLRQjq7yyVbJS3W0zV5H7HL9gcFExvt2BiC9IS36XI6Q1mJJGk4cNBdvXoHzOu)lmlXZcAyPRJfRyrD1AMXrqfCHZTHQyNWSIyPplkyXkwuxTMzCeubx4CBOk2jY4VAlDEpb(O5DZkIffS0Jf1vRza6lWHaZuAe0cnPuDzQOb1hBYmuQ)fMfGXcQaOj1rol9zrbl9yrD1AgkO)imLXqTpMHs9VWSeplOcGMuh5S01XI6Q1muq)rykRxLpMHs9VWSeplOcGMuh5S01XspwSIf1vRzOG(JWuwVkFmRiw66yXkwuxTMHc6pctzmu7JzfXsFwuWIvSCUMQZGHA89bYqLRQjqw6BVbs4W8r3dl7nKblW)EyXsdoS4AnlGWdZYT7hlPoqeMf8AiwUDkbl(qf6owgQneENazXYovSaGXrqfCHzjomuf7eSS7yw0egZYT7flOHfmfWSmuQ)1xOyboSC7elaLyEVyrD1AS8ywCv46y5GS0CTMfyRXcCyXReSGEb9hHjwEmlUkCDSCqwiKh9dzVHWNC5PK9gi8YdbCx)qPuDy7ZoMOX262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7TESyflQRwZqb9hHPmgQ9XSIyrblwXI6Q1muq)rykRxLpMvel9zPRJLZ1uDgmuJVpqgQCvnbAVbs4W8r3dl7nKblW)EyXYT7hlHDkaeMLVXsc4IfFiwGRd)Geluq)ryILdYcS0jybeESC70qSahwEufCiwU9hZIL)2zzdQX3hi7ne(KlpLS3aHxgUo8dszkO)imzF2Xe4yBD7nQCvnbAhd7npCpSS3sHWQ9dzVfM)O5D7THAdH3DvnXIcw6XI6Q1muq)rykJHAFmdL6FHzjEwgk1)cZsxhlQRwZqb9hHPSEv(ygk1)cZs8SmuQ)fMLUowq4Z7QAYacVmCD4hKYuq)ryIL(SOGLHAdH3DvnXIcwoFqrN5(ukFWm4tSeplkbqwuWIhLd7uaiwuWccFExvtgq4Lhc4U(HsP6W2BHebnLpFqrh2oMkzF2XeqzBD7nQCvnbAhd7npCpSS3WRQ9dzVfM)O5D7THAdH3DvnXIcw6XI6Q1muq)rykJHAFmdL6FHzjEwgk1)cZsxhlQRwZqb9hHPSEv(ygk1)cZs8SmuQ)fMLUowq4Z7QAYacVmCD4hKYuq)ryIL(SOGLHAdH3DvnXIcwoFqrN5(ukFWm4tSeplkbqwuWIhLd7uaiwuWccFExvtgq4Lhc4U(HsP6W2BHebnLpFqrh2oMkzF2XeqyBD7nQCvnbAhd7npCpSS3WhP1(KBAFi7TW8hnVBVnuBi8URQjwuWspwuxTMHc6pctzmu7JzOu)lmlXZYqP(xyw66yrD1AgkO)imL1RYhZqP(xywINLHs9VWS01XccFExvtgq4LHRd)GuMc6pctS0NffSmuBi8URQjwuWY5dk6m3Ns5dMbFIL4zrjGdlkyXJYHDkaelkybHpVRQjdi8YdbCx)qPuDy7TqIGMYNpOOdBhtLSp7yciTTU9gvUQMaTJH9MhUhw2Bn4eOmSLl)wdzVbs4W8r3dl7T4etSehGXKfyXsaKfl)Tdxhlbpk6lu2BH5pAE3EZJYHDkaK9zhtLs2262Bu5QAc0og2BE4EyzVrPrql0KvHfO9giHdZhDpSS3ItmXcsPVahcKLTOF(dZIL)2zXReSOHfkwOcUqTZI2X3xOyb9c6pctS4fil3KGLdYI(lIL)yzfXIL)2zbaT0yFyXlqwqwSqI1wb7TW8hnVBV1JLESOUAndf0FeMYyO2hZqP(xywINfLsMLUowuxTMHc6pctz9Q8XmuQ)fML4zrPKzPplkyjaHAqOLYe88xbZqP(xywINL4MmlkyPhlQRwZenFkCaFxN9j41hYrln2hdcxViwagla0AsMLUowSILzvudoOit08PWb8DD2NGxFihT0yFmeWD9rreil9zPplDDSOUAnt08PWb8DD2NGxFihT0yFmiC9IyjELzbGaQKzPRJLaeQbHwktWZFfmd5Gjyrblo(gxNJGwOHL4zbqMS9zhtLuY262Bu5QAc0og2BWi7nmD2BE4EyzVHWN3v1K9gcxVi7nRybCwpOPG5aiMffSGWN3v1KjaMdWc8VhwSOGLES0JLaeQbHwkdLgLyixNHdy5vGmdL6FHzbySOeWbqXcGzPhlkPelaplZQOgCqrg8xTLoVNaF08UHkxvtGS0NffSqa31hfrGgknkXqUodhWYRaXsFw66yXX346Ce0cnSeVYSaitMffS0JfRy5CnvNPTMezylt6vrgQCvnbYsxhlQRwZe88xbd4A87HflXZsac1GqlLPTMezylt6vrMHs9VWSaywaeS0NffSGWN3v1K52NxRZyIaIMSf)pwuWspwuxTMbOVahcmtPrql0Ks1LPIguFSjZkILUowSILaebvEDgGsmVxS0NffSC(GIoZ9Pu(GzWNyjEwuxTMj45VcgW143dlwaEws2aOyPRJfvigZIcwApQ9lpuQ)fMfGXI6Q1mbp)vWaUg)EyXsxhlbicQ86m1JA)YnNyPRJf1vRzu1qiOEHpZkIffSOUAnJQgcb1l8zgk1)cZcWyrD1AMGN)kyaxJFpSybWS0JfajlaplZQOgCqrMO5tHd476SpbV(qoAPX(yiG76JIiqw6ZsFwuWIvSOUAntWZFfmRiwuWspwSILaebvEDM6rTF5MtS01Xsac1GqlLjaleqGO8TtzC0p)HnRiw66yrfIXSOGL2JA)YdL6FHzbySeGqni0szcWcbeikF7ugh9ZFyZqP(xywamlahw66yP9O2V8qP(xywqQSOeGizwaglQRwZe88xbd4A87Hfl9T3ajCy(O7HL9wCIjwqwSqI1wbwS83olidwiGaribP0xGdbYYw0p)HzXlqwaHf6owGiOXY8hXcaAPX(WcCyXYovSednecQx4JflWLgKfc5r)qSOsn4qSGSyHeRTcSqip6hcBVHWNC5PK9wamhGf4FpSY4Z(SJPsa0262Bu5QAc0og2BE4EyzVnocQGlCUnuf7e2BGeomF09WYEloXel3oXcaUuD7jgwS83ololilwiXARal3UFS84cDhlTbMYcaAPX(yVfM)O5D7n1vRzcE(RGzOu)lmlXZIsOHLUowuxTMj45VcgW143dlwaglXnzwuWccFExvtMayoalW)EyLXN9zhtLIRT1T3OYv1eODmS3cZF08U9gcFExvtMayoalW)EyLXhlkyPhlwXI6Q1mbp)vWaUg)EyXs8Se3KzPRJfRyjarqLxNbbv3EIHL(S01XI6Q1mJJGk4cNBdvXoHzfXIcwuxTMzCeubx4CBOk2jmdL6FHzbySaizbWSeGf46pt0qHhtzx)OQuQoZ9PugHRxelaMLESyflQRwZOQHqq9cFMvelkyXkwoxt1zWNpA4aAOYv1eil9T38W9WYElqAcFVRZU(rvPuD2NDmvYASTU9gvUQMaTJH9wy(JM3T3q4Z7QAYeaZbyb(3dRm(S38W9WYE7RGpLFpSSp7yQeASTU9gvUQMaTJH9gmYEdtN9MhUhw2Bi85DvnzVHW1lYEZkwcqOgeAPmbp)vWmKdMGLUowSIfe(8UQMmbyHaceLbjCIkWIcwcqeu51zQh1(LBoXsxhlGZ6bnfmhaX2BGeomF09WYEdaxFExvtSSWeilWIfx91)9eMLB3pwS41XYbzrLyb7iiqwAWHfKflKyTvGfmKLB3pwUDkbl(q1XIfhFeila4SWhlQudoel3oLAVHWNC5PK9g2rq5gCYbp)vW(SJPsahBRBVrLRQjq7yyV5H7HL9wBnjYWwM0RIS3ajCy(O7HL9wCIjmlXbi6XY3y5lw8If0lO)imXIxGSCZtywoil6Viw(JLvelw(BNfa0sJ9bTSGSyHeRTcS4filXc0JUhbXYMfFsT3cZF08U9gf0FeMmFL9kblkyXJYHDkaelkyrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGwtYSOGLESacpJd6r3JGYyl(KMb9uhfzUpa0xOyPRJfRyjarqLxNPOWa1WbKL(SOGfe(8UQMmyhbLBWjh88xbwuWspwuxTMzCeubx4CBOk2jmdL6FHzbySaizbaYspwqdlaplZQOgCqrg8xTLoVNaF08UHkxvtGS0NffSOUAnZ4iOcUW52qvStywrS01XIvSOUAnZ4iOcUW52qvStywrS03(SJPsakBRBVrLRQjq7yyV5H7HL9g(8P5AT9giHdZhDpSS3ItmXca(IUDw2oFAUwZs0adyw(glBNpnxRz5Xf6owwr2BH5pAE3EtD1Agyr3oohrtGIUhwMvelkyrD1Ag85tZ1AZqTHW7UQMSp7yQeGW262Bu5QAc0og2BH5pAE3EtD1Ag85JgoGMHs9VWSamwqdlkyPhlQRwZqb9hHPmgQ9XmuQ)fML4zbnS01XI6Q1muq)rykRxLpMHs9VWSeplOHL(SOGfhFJRZrql0Ws8Sait2EZd3dl7TGxbsNvxTM9M6Q1YLNs2B4ZhnCaTp7yQeG0262Bu5QAc0og2BE4EyzVHpFWRbfzVbs4W8r3dl7T44kncZsSWaiwuPgCiwqgSqabIyzH)cfl3oXcYGfciqelbyb(3dlwoilHDkaelFJfKbleqGiwEmlE4wUwNGfxfUowoilQelbhF2BH5pAE3ElarqLxNPEu7xU5elkybHpVRQjtawiGarzqcNOcSOGLaeQbHwktawiGar5BNY4OF(dBgk1)cZcWybnSOGfRybCwpOPG5aiMffSqb9hHjZxzVsWIcwC8nUohbTqdlXZI1KS9zhtaMST1T3OYv1eODmS38W9WYEdF(0CT2EdKWH5JUhw2BXjMyz78P5Anlw(BNLTJ0AFyjooF7yXlqwkilBNpA4aIwwSStflfKLTZNMR1S8ywwrOLLeWfl(qS8flO)Q8Hf0lO)imXsdoSaiamMcywGdlhKLObgybaT0yFyXYovS4QqeelaYKzjwyaelWHfhmYVhbXc2IpPSS7ywaeagtbmldL6F9fkwGdlpMLVyPPFu7NHLycpILB3pwwfinSC7elypLyjalW)EyHz5p0HzbmcZsrRBCnlhKLTZNMR1SaUMVqXcaghbvWfML4WqvStGwwSStfljGl0bYc(ETMfQazzfXIL)2zbqMmGDCeln4WYTtSOD8Xcknu11yJ9wy(JM3T3oxt1zWhP1(KbNVDgQCvnbYIcwSILZ1uDg85JgoGgQCvnbYIcwuxTMbF(0CT2muBi8URQjwuWspwuxTMHc6pctz9Q8XmuQ)fML4zbqWIcwOG(JWK5RSEv(WIcwuxTMjA(u4a(Uo7tWRpKJwASpgeUErSamwaiAsMLUowuxTMjA(u4a(Uo7tWRpKJwASpgeUErSeVYSaq0KmlkyXX346Ce0cnSeplaYKzPRJfq4zCqp6EeugBXN0mON6OiZqP(xywINfablDDS4H7HLXb9O7rqzSfFsZGEQJImFLB6h1(XsFwuWsac1GqlLj45VcMHs9VWSeplkLS9zhtaQKT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXjMyz78bVguela4l62zjAGbmlEbYc4knILyHbqSyzNkwqwSqI1wbwGdl3oXcaUuD7jgwuxTglpMfxfUowoilnxRzb2ASahwsaxOdKLGhXsSWai7TW8hnVBVPUAndSOBhNdAYNmIh)WYSIyPRJf1vRza6lWHaZuAe0cnPuDzQOb1hBYSIyPRJf1vRzcE(RGzfXIcw6XI6Q1mJJGk4cNBdvXoHzOu)lmlaJfubqtQJCwaEwc0RzPhlo(gxNJGwOHfKWsCtML(SaywIllaplNRP6mfzjNcHLHkxvtGSOGfRyzwf1GdkYG)QT059e4JM3nu5QAcKffSOUAnZ4iOcUW52qvStywrS01XI6Q1mbp)vWmuQ)fMfGXcQaOj1rolaplb61S0JfhFJRZrql0WcsyjUjZsFw66yrD1AMXrqfCHZTHQyNiJ)QT059e4JM3nRiw66yXkwuxTMzCeubx4CBOk2jmRiwuWIvSeGqni0szghbvWfo3gQIDcZqoycw66yXkwcqeu51zqq1TNyyPplDDS44BCDocAHgwINfazYSOGfkO)imz(k7vc7ZoMaeG2w3EJkxvtG2XWEZd3dl7n85dEnOi7nqchMp6EyzVz9jblhKLuhiILBNyrLWhlWglBNpA4aYIAcwWNha6luS8hlRiwaURpaKoblFXIxjyb9c6pctSOUowaqln2hwECDS4QW1XYbzrLyjAGHabAVfM)O5D7TZ1uDg85JgoGgQCvnbYIcwSILzvudoOiZ9PKf4uzWH8u1VaPXqLRQjqwuWspwuxTMbF(OHdOzfXsxhlo(gxNJGwOHL4zbqMml9zrblQRwZGpF0Wb0GppaelaJL4YIcw6XI6Q1muq)rykJHAFmRiw66yrD1AgkO)imL1RYhZkIL(SOGf1vRzIMpfoGVRZ(e86d5OLg7JbHRxelaJfacOsMffS0JLaeQbHwktWZFfmdL6FHzjEwukzw66yXkwq4Z7QAYeGfciqugKWjQalkyjarqLxNPEu7xU5el9Tp7ycW4ABD7nQCvnbAhd7nyK9gMo7npCpSS3q4Z7QAYEdHRxK9gf0FeMmFL1RYhwaEwaeSGew8W9WYGpFA)qgc5uyDu((uIfaZIvSqb9hHjZxz9Q8HfGNLESaCybWSCUMQZGHlDg2Y3oLBWHWNHkxvtGSa8Sexw6ZcsyXd3dlJLXVDdHCkSokFFkXcGzjzJ1Ggwqcl4isRZ7o(iwamljBqdlaplNRP6mLFRHWzvx7vGmu5QAc0EdKWH5JUhw2BOh((u)iml7qlSKUc7SelmaIfFiwq5FrGSerdlykalq7ne(KlpLS3CCeaIMnkyF2XeGwJT1T3OYv1eODmS38W9WYEdF(GxdkYEdKWH5JUhw2BXXvAelBNp41GIy5lwCwauagtbw2GAFyb9c6pctOLfqyHUJfnDS8hlrdmWcaAPX(WsVB3pwEml7EbQjqwutWc93onSC7elBNpnxRzr)fXcCy52jwIfgafpGmzw0FrS0GdlBNp41GI6JwwaHf6owGiOXY8hXIxSaGVOBNLObgyXlqw00XYTtS4Qqeel6Viw29cutSSD(OHdO9wy(JM3T3SILzvudoOiZ9PKf4uzWH8u1VaPXqLRQjqwuWspwuxTMjA(u4a(Uo7tWRpKJwASpgeUErSamwaiGkzw66yrD1AMO5tHd476SpbV(qoAPX(yq46fXcWybGOjzwuWY5AQod(iT2Nm48TZqLRQjqw6ZIcw6Xcf0FeMmFLXqTpSOGfhFJRZrql0WcGzbHpVRQjJJJaq0SrbwaEwuxTMHc6pctzmu7JzOu)lmlaMfq4zARjrg2YKEvK5(aq48qP(xSa8SaqdAyjEwaejZsxhluq)ryY8vwVkFyrblo(gxNJGwOHfaZccFExvtghhbGOzJcSa8SOUAndf0FeMY6v5JzOu)lmlaMfq4zARjrg2YKEvK5(aq48qP(xSa8SaqdAyjEwaKjZsFwuWIvSOUAndSOBhNJOjqr3dlZkIffSyflNRP6m4ZhnCanu5QAcKffS0JLaeQbHwktWZFfmdL6FHzjEwauS01XcgU0QFbAU9516mMiGOXqLRQjqwuWI6Q1m3(8ADgteq0yWNhaIfGXsCJllaqw6XYSkQbhuKb)vBPZ7jWhnVBOYv1eilaplOHL(SOGL2JA)YdL6FHzjEwuk5KzrblTh1(Lhk1)cZcWybGjNml9zrbl9yjaHAqOLYa0xGdbMXr)8h2muQ)fML4zbqXsxhlwXsaIGkVodqjM3lw6BF2XeGOX262Bu5QAc0og2BE4EyzVvKLCkew2BGeomF09WYEloXelayHWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3aCCyP1SaGfclwAWHfKflKyTvGfVazbP0xGdbYc6LgbTqtkvN9wy(JM3T36XI6Q1muq)rykRxLpMHs9VWSepleYPW6O89PelDDS0JLWUpOimlkZcazrbldf29bfLVpLybySGgw6ZsxhlHDFqrywuML4YsFwuWIhLd7uaiwuWccFExvtgSJGYn4KdE(RG9zhtacCSTU9gvUQMaTJH9wy(JM3T36XI6Q1muq)rykRxLpMHs9VWSepleYPW6O89PelkyXkwcqeu51zakX8EXsxhl9yrD1AgG(cCiWmLgbTqtkvxMkAq9XMmRiwuWsaIGkVodqjM3lw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr57tjwaglOHL(S01Xsy3hueMfLzjUS01XI6Q1mbp)vWSIyPplkyXJYHDkaelkybHpVRQjd2rq5gCYbp)vGffS0Jf1vRzghbvWfo3gQIDcZqP(xywagl9ybnSaazbGSa8SmRIAWbfzWF1w68Ec8rZ7gQCvnbYsFwuWI6Q1mJJGk4cNBdvXoHzfXsxhlwXI6Q1mJJGk4cNBdvXoHzfXsF7npCpSS32DDlNcHL9zhtacOSTU9gvUQMaTJH9wy(JM3T36XI6Q1muq)rykRxLpMHs9VWSepleYPW6O89PelkyXkwcqeu51zakX8EXsxhl9yrD1AgG(cCiWmLgbTqtkvxMkAq9XMmRiwuWsaIGkVodqjM3lw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr57tjwaglOHL(S01Xsy3hueMfLzjUS01XI6Q1mbp)vWSIyPplkyXJYHDkaelkybHpVRQjd2rq5gCYbp)vGffS0Jf1vRzghbvWfo3gQIDcZqP(xywaglOHffSOUAnZ4iOcUW52qvStywrSOGfRyzwf1GdkYG)QT059e4JM3nu5QAcKLUowSIf1vRzghbvWfo3gQIDcZkIL(2BE4EyzV1wADofcl7ZoMaeqyBD7nQCvnbAhd7nqchMp6EyzVfNyIfKci6XcSyjaAV5H7HL9MfFMhozylt6vr2NDmbiG0262Bu5QAc0og2BE4EyzVHpFA)q2BGeomF09WYEloXelBNpTFiwoilrdmWYgu7dlOxq)rycTSGSyHeRTcSS7yw0egZY9Pel3UxS4SGum(TZcHCkSoIfn1owGdlWsNGf0Fv(Wc6f0FeMy5XSSIS3cZF08U9gf0FeMmFL1RYhw66yHc6pctgmu7tUiKFS01Xcf0FeMmELixeYpw66yPhlQRwZyXN5Htg2YKEvKzfXsxhl4isRZ7o(iwagljBSg0WIcwSILaebvEDgeuD7jgw66ybhrADE3XhXcWyjzJ1WIcwcqeu51zqq1TNyyPplkyrD1AgkO)imL1RYhZkILUow6XI6Q1mbp)vWmuQ)fMfGXIhUhwglJF7gc5uyDu((uIffSOUAntWZFfmRiw6BF2XmUjBBD7nQCvnbAhd7nqchMp6EyzVfNyIfKIXVDwG3onwEmXIL9pSZYJz5lw2GAFyb9c6pctOLfKflKyTvGf4WYbzjAGbwq)v5dlOxq)ryYEZd3dl7nlJF72NDmJRs2w3EJkxvtG2XWEdKWH5JUhw2BXbxRV9zzV5H7HL92SQShUhwz9Jp7n9JVC5PK9wZ16BFw2N9zVfnuaMQ6NT1TJPs2w3EZd3dl7nG(cCiWmo6N)W2Bu5QAc0og2NDmbOT1T3OYv1eODmS3Gr2By6S38W9WYEdHpVRQj7neUEr2BjBVbs4W8r3dl7nRVtSGWN3v1elpMfmDSCqwsMfl)TZsbzbF(XcSyzHjwU5lGOdJwwuIfl7uXYTtS0(bFSalILhZcSyzHj0Ycaz5BSC7elykalqwEmlEbYsCz5BSOcVDw8HS3q4tU8uYEdw5fMY38fq0zF2XmU2w3EJkxvtG2XWEdgzV5GG2BE4EyzVHWN3v1K9gcxVi7nLS3cZF08U92nFbeDMtjZUJZlmLvxTglky5MVaIoZPKjaHAqOLYaUg)EyXIcwSILB(ci6mNsMhBoykLHTCkSW3ax4Caw4BwH7Hf2EdHp5Ytj7nyLxykFZxarN9zhtRX262Bu5QAc0og2BWi7nhe0EZd3dl7ne(8UQMS3q46fzVbq7TW8hnVBVDZxarN5aOz3X5fMYQRwJffSCZxarN5aOjaHAqOLYaUg)EyXIcwSILB(ci6mhanp2CWukdB5uyHVbUW5aSW3Sc3dlS9gcFYLNs2BWkVWu(MVaIo7ZoMOX262Bu5QAc0og2BWi7nhe0EZd3dl7ne(8UQMS3q4tU8uYEdw5fMY38fq0zVfM)O5D7nc4U(Oic08fomRZv1ug4U86wPzqcXhiw66yHaURpkIanuAuIHCDgoGLxbILUowiG76JIiqdgU0A6UVqLNLAc7nqchMp6EyzVz9DctSCZxarhMfFiwk4XIVUu)(GR1jybKokCeiloMfyXYctSGp)y5MVaIoSHLyPT4jWS4GGFHIfLyjL8cZYTtjyXYR1S4AlEcmlQelrd1Oziqw(cKIOcKQJfyJfSgE2BiC9IS3uY(SJjWX262BE4EyzVLcHfqFLBWj1EJkxvtG2XW(SJjGY262Bu5QAc0og2BE4EyzVzz8B3Et)fLdG2BkLS9wy(JM3T36Xcf0FeMm6v5tUiKFS01Xcf0FeMmFLXqTpS01Xcf0FeMmFLvH3olDDSqb9hHjJxjYfH8JL(2BGeomF09WYEdanuWXhlaKfKIXVDw8cKfNLTZh8AqrSalw2Solw(BNLy(O2pwIdoXIxGSedySSolWHLTZN2pelWBNglpMSp7yciSTU9gvUQMaTJH9wy(JM3T36Xcf0FeMm6v5tUiKFS01Xcf0FeMmFLXqTpS01Xcf0FeMmFLvH3olDDSqb9hHjJxjYfH8JL(SOGLOHqyuYyz8BNffSyflrdHWaqJLXVD7npCpSS3Sm(TBF2XeqABD7nQCvnbAhd7TW8hnVBVzflZQOgCqrgvx7vGYWw2168T)fkSHkxvtGS01XIvSeGiOYRZupQ9l3CILUowSIfCeP15Zhu0Hn4ZNMR1SOmlkXsxhlwXY5AQot53AiCw11EfidvUQMazPRJLESqb9hHjdgQ9jxeYpw66yHc6pctMVY6v5dlDDSqb9hHjZxzv4TZsxhluq)ryY4vICri)yPV9MhUhw2B4ZN2pK9zhtLs2262Bu5QAc0og2BH5pAE3EBwf1GdkYO6AVcug2YUwNV9VqHnu5QAcKffSeGiOYRZupQ9l3CIffSGJiToF(GIoSbF(0CTMfLzrj7npCpSS3WNp41GISp7Z(S3qqd(HLDmbyYauPKbujdimkzVzXN6luy7nKIybGjMwBmrkhqZclwFNy5tJGZXsdoSGoqQ5l9Howgc4U(Hazbdtjw81bt9JazjS7fkcB4Kq)ViwSganlidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0tjK33WjH(FrSynaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)IybnaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)Iyb4aOzbzWcbnhbYY2NImwWjQZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEae59nCsO)xelakanlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WjH(FrSaOa0SGmyHGMJazbD38fq0zuYaaqhlhKf0DZxarN5uYaaqhl9aiY7B4Kq)ViwauaAwqgSqqZrGSGUB(ci6ma0aaqhlhKf0DZxarN5aObaGow6bqK33WjH(FrSaia0SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNe6)fXcGeqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCsO)xelkLmGMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B4Kq)ViwusjanlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WjH(FrSOeab0SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspaI8(goj0)lIfLaiGMfKble0CeilO7MVaIoJsgaa6y5GSGUB(ci6mNsgaa6yPharEFdNe6)fXIsaeqZcYGfcAocKf0DZxarNbGgaa6y5GSGUB(ci6mhanaa0XspLqEFdNe6)fXIsXfqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9aiY7B4Kq)ViwukUaAwqgSqqZrGSGUB(ci6mkzaaOJLdYc6U5lGOZCkzaaOJLEkH8(goj0)lIfLIlGMfKble0CeilO7MVaIodanaa0XYbzbD38fq0zoaAaaOJLEae59nCsCsifXcatmT2yIuoGMfwS(oXYNgbNJLgCybDrdfGPQ(Howgc4U(Hazbdtjw81bt9JazjS7fkcB4Kq)ViwIlGMfKble0CeilO7MVaIoJsgaa6y5GSGUB(ci6mNsgaa6yPxCrEFdNe6)fXI1aOzbzWcbnhbYc6U5lGOZaqdaaDSCqwq3nFbeDMdGgaa6yPxCrEFdNe6)fXcGeqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCsO)xelkLmGMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B4K4KqkIfaMyATXePCanlSy9DILpncohln4Wc6CiHowgc4U(Hazbdtjw81bt9JazjS7fkcB4Kq)ViwucqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl(Xc6bGh9zPNsiVVHtc9)IyjUaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)Iyb4aOzbzWcbnhbYY2NImwWjQZrolivKklhKf0F5SKcbx6fMfyen(bhw6Hu7ZspLqEFdNe6)fXcWbqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9aiY7B4Kq)ViwauaAwqgSqqZrGSS9PiJfCI6CKZcsfPYYbzb9xolPqWLEHzbgrJFWHLEi1(S0tjK33WjH(FrSaOa0SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNe6)fXcGaqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCsO)xelasanlidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0dGiVVHtc9)IyrjacOzbzWcbnhbYY2NImwWjQZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEkH8(goj0)lIfLaKaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)IybGkbOzbzWcbnhbYY2NImwWjQZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEkH8(goj0)lIfagxanlidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0dGiVVHtc9)IybGXfqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCsO)xelaenaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)IybGahanlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WjH(FrSaqabGMfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6bqK33WjH(FrSaqajGMfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6PeY7B4K4KqkIfaMyATXePCanlSy9DILpncohln4Wc6AUwF7ZcDSmeWD9dbYcgMsS4RdM6hbYsy3lue2WjH(FrSaqanlidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0tjK33WjXjHuelamX0AJjs5aAwyX67elFAeCowAWHf0Hp0XYqa31peilyykXIVoyQFeilHDVqrydNe6)fXIsaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)IyjUaAwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtc9)IyrjLa0SGmyHGMJazz7trgl4e15iNfKksLLdYc6VCwsHGl9cZcmIg)Gdl9qQ9zPNsiVVHtc9)IyrjLa0SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNe6)fXIsahanlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WjH(FrSaqLa0SGmyHGMJazz7trgl4e15iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspaI8(goj0)lIfaQeGMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B4Kq)Viwaiab0SGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNe6)fXcaJlGMfKble0CeilBFkYybNOoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6fxK33WjH(FrSaqRbqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9aiY7B4Kq)ViwaiWbqZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCsO)xelaeqbOzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHkxvtGOJLEkH8(gojojKIybGjMwBmrkhqZclwFNy5tJGZXsdoSGovOFOJLHaURFiqwWWuIfFDWu)iqwc7EHIWgoj0)lIfLaeaAwqgSqqZrGSS9PiJfCI6CKZcsLLdYc6VCwaFep(HflWiA8doS0dj9zPxCrEFdNe6)fXIsasanlidwiO5iqw2(uKXcorDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0tjK33WjXjzTPrW5iqwaoS4H7Hfl6hFydNK9w0aBVMS3qAKMLy4AVcelXXz9GCsinsZsslDcwaKOLfaMmavItItcPrAwq2UxOimGMtcPrAwaGSelqqcKLnO2hwIb5PgojKgPzbaYcY29cfbYY5dk6YFJLGJjmlhKLqIGMYNpOOdB4KqAKMfailayOuiccKLvvuGWyFsWccFExvtyw69gYGwwIgcrgF(GxdkIfay8Senecd(8bVguuFdNesJ0SaazjwiGpilrdfC89fkwqkg)2z5BS8h6WSC7elwgyHIf0lO)imz4KqAKMfailayDGiwqgSqabIy52jw2I(5pmlol6)onXskCiwAAc5VQMyP33yjbCXYUdwO7yz)pw(Jf8NU0NxeCH1jyXYF7Seda8XY6SaywqgPj89UMLyPFuvkvhAz5p0bYcgOpQVHtcPrAwaGSaG1bIyjfIpwqx7rTF5Hs9VWOJfCGkFEiMfpksNGLdYIkeJzP9O2pmlWsNWWjH0inlaqwS(q(XI1HPelWglXq77SedTVZsm0(oloMfNfCefExZYnFbeDgojojKgPzjwvbp)iqwIHR9kqSelae6ZsWlwujwAWvbYIFSSFxegqJeKO6AVceae)PbdQ)2xQMhIKy4AVceaC7trgssbn7xQgPSTxtkR6AVcK5q(XjXj5H7Hf2enuaMQ6NYa9f4qGzC0p)H5KqAwS(oXccFExvtS8ywW0XYbzjzwS83olfKf85hlWILfMy5MVaIomAzrjwSStfl3oXs7h8XcSiwEmlWILfMqllaKLVXYTtSGPaSaz5XS4filXLLVXIk82zXhItYd3dlSjAOamv1paRmsq4Z7QAcTLNskdR8ct5B(ci6qlcxViLtMtYd3dlSjAOamv1paRmsq4Z7QAcTLNskdR8ct5B(ci6qlmszheeTiC9Iuwj0(nLV5lGOZOKz3X5fMYQRwtXnFbeDgLmbiudcTugW143dlfwDZxarNrjZJnhmLYWwofw4BGlCoal8nRW9WcZj5H7Hf2enuaMQ6hGvgji85DvnH2YtjLHvEHP8nFbeDOfgPSdcIweUErkdq0(nLV5lGOZaqZUJZlmLvxTMIB(ci6ma0eGqni0szaxJFpSuy1nFbeDgaAES5GPug2YPWcFdCHZbyHVzfUhwyojKMfRVtyILB(ci6WS4dXsbpw81L63hCToblG0rHJazXXSalwwyIf85hl38fq0HnSelTfpbMfhe8luSOelPKxywUDkblwETMfxBXtGzrLyjAOgndbYYxGuevGuDSaBSG1WJtYd3dlSjAOamv1paRmsq4Z7QAcTLNskdR8ct5B(ci6qlmszheeTiC9Iuwj0(nLjG76JIiqZx4WSoxvtzG7YRBLMbjeFG66iG76JIiqdLgLyixNHdy5vG66iG76JIiqdgU0A6UVqLNLAcojpCpSWMOHcWuv)aSYijfclG(k3GtkNesZcaAOGJpwailifJF7S4filolBNp41GIybwSSzDwS83olX8rTFSehCIfVazjgWyzDwGdlBNpTFiwG3onwEmXj5H7Hf2enuaMQ6hGvgjwg)2rR(lkhavwPKr73uUhf0FeMm6v5tUiKFDDuq)ryY8vgd1(01rb9hHjZxzv4T31rb9hHjJxjYfH8RpNKhUhwyt0qbyQQFawzKyz8BhTFt5Euq)ryYOxLp5Iq(11rb9hHjZxzmu7txhf0FeMmFLvH3Exhf0FeMmELixeYV(kIgcHrjJLXVDfwfnecdanwg)25K8W9WcBIgkatv9dWkJe85t7hcTFtzRMvrn4GImQU2RaLHTSR15B)lu4UoRcqeu51zQh1(LBo11zfoI0685dk6Wg85tZ1ALvQRZQZ1uDMYV1q4SQR9kqgQCvnb211Jc6pctgmu7tUiKFDDuq)ryY8vwVkF66OG(JWK5RSk8276OG(JWKXRe5Iq(1NtYd3dlSjAOamv1paRmsWNp41GIq73uEwf1GdkYO6AVcug2YUwNV9VqHveGiOYRZupQ9l3CsboI0685dk6Wg85tZ1ALvItItcPrAwqpKtH1rGSqiOjbl3NsSC7elE4GdlpMfhH)AxvtgojpCpSWkJHAFYQKNYjH0SSrhMLybrpwGflXfWSy5VD46ybC(2XIxGSy5VDw2oF0WbKfVazbGaMf4TtJLhtCsE4EyHbSYibHpVRQj0wEkP8JZoKqlcxViLXrKwNpFqrh2GpFAUwhVsk6z15AQod(8rdhqdvUQMa76oxt1zWhP1(KbNVDgQCvnb2VRdhrAD(8bfDyd(8P5AD8aKtcPzzJomlbn5iiwSStflBNpTFiwcEXY(FSaqaZY5dk6WSyz)d7S8ywgsti86yPbhwUDIf0lO)imXYbzrLyjAOgndbYIxGSyz)d7S0ETMgwoilbhFCsE4EyHbSYibHpVRQj0wEkP8JZbn5ii0IW1lszCeP15Zhu0Hn4ZN2pu8kXjH0SeNyILyqdMgG(cflw(BNfKflKyTvGf4WI3oAybzWcbeiILVybzXcjwBf4K8W9WcdyLrIknyAa6luO9Bk3ZQaebvEDM6rTF5MtDDwfGqni0szcWcbeikF7ugh9ZFyZkQVc1vRzcE(RGzOu)lC8kHgfQRwZmocQGlCUnuf7eMHs9VWaZAuyvaIGkVodcQU9etxxaIGkVodcQU9eJc1vRzcE(RGzfPqD1AMXrqfCHZTHQyNWSIu0tD1AMXrqfCHZTHQyNWmuQ)fgykPeaena)SkQbhuKb)vBPZ7jWhnV31PUAntWZFfmdL6FHbMsk11PesfhrADE3XhbmLmObn95KqAwaqWJfl)TZIZcYIfsS2kWYT7hlpUq3XIZcaAPX(Ws0adSahwSStfl3oXs7rTFS8ywCv46y5GSqfiNKhUhwyaRmsIG3dl0(nLvxTMj45VcMHs9VWXReAu0ZQzvudoOid(R2sN3tGpAEVRtD1AMXrqfCHZTHQyNWmuQ)fgykbOaGae4vxTMrvdHG6f(mRifQRwZmocQGlCUnuf7eMvu)UovigRO9O2V8qP(xyGbq0WjH0SGmxhwA)imlw2PBNgww4VqXcYGfciqelf0clwETMfxRHwyjbCXYbzbFVwZsWXhl3oXc2tjw8u4QowGnwqgSqabIamYIfsS2kWsWXhMtYd3dlmGvgji85DvnH2YtjLdWcbeikds4evaTiC9IuoqVUxV2JA)YdL6FHbGkHgayac1GqlLj45VcMHs9VW9rQkbisUVYb61961Eu7xEOu)lmauj0aavcGjdadqOgeAPmbyHaceLVDkJJ(5pSzOu)lCFKQsaIK7RWQXFWmHGQZ4GGydH8hF4UUaeQbHwktWZFfmdL6FHJ)RJMiO2pcm3Eu7xEOu)lCxxac1GqlLjaleqGO8TtzC0p)HndL6FHJ)RJMiO2pcm3Eu7xEOu)lmauPK76SkarqLxNPEu7xU5uxNhUhwMaSqabIY3oLXr)8h2a(yxvtGCsinlXjMaz5GSasApbl3oXYc7OiwGnwqwSqI1wbwSStfll8xOybeUu1elWILfMyXlqwIgcbvhllSJIyXYovS4floiilecQowEmlUkCDSCqwaFItYd3dlmGvgji85DvnH2YtjLdG5aSa)7HfAr46fPCVZhu0zUpLYhmd(u8kHMUUXFWmHGQZ4GGyZxXJMK7ROxVEeWD9rreOHsJsmKRZWbS8kqk61laHAqOLYqPrjgY1z4awEfiZqP(xyGPeWj5UUaebvEDgeuD7jgfbiudcTugknkXqUodhWYRazgk1)cdmLaoaka3tjLa(zvudoOid(R2sN3tGpAEVFFfwfGqni0szO0Oed56mCalVcKzihmr)(DD9iG76JIiqdgU0A6UVqLNLAcf9SkarqLxNPEu7xU5uxxac1GqlLbdxAnD3xOYZsnroUwdAaejRKzOu)lmWusjRPF)UUEbiudcTugvAW0a0xOmd5Gj66SA8azUbQ19v0RhbCxFuebA(chM15QAkdCxEDR0miH4dKIaeQbHwkZx4WSoxvtzG7YRBLMbjeFGmd5Gj6311RhcFExvtgyLxykFZxarNYk11HWN3v1Kbw5fMY38fq0PCC7RO3nFbeDgLmd5GjYbiudcTuDD38fq0zuYeGqni0szgk1)ch)xhnrqTFeyU9O2V8qP(xyaOsj3VRdHpVRQjdSYlmLV5lGOtzaQO3nFbeDgaAgYbtKdqOgeAP66U5lGOZaqtac1GqlLzOu)lC8FD0eb1(rG52JA)YdL6FHbGkLC)Uoe(8UQMmWkVWu(MVaIoLtUF)(DDbicQ86maLyEV631PcXyfTh1(Lhk1)cdm1vRzcE(RGbCn(9WItYd3dlmGvgji85DvnH2YtjLV9516mMiGOjBX)dTiC9Iu2kmCPv)c0C7ZR1zmrarJHkxvtGDDTh1(Lhk1)chpato5UovigRO9O2V8qP(xyGbq0a4EwtYaq1vRzU9516mMiGOXGppaeWdW(DDQRwZC7ZR1zmrarJbFEaO4JlGaa2Bwf1GdkYG)QT059e4JM3bE00NtcPzjoXelOxAuIHCnla4hWYRaXcatgtbmlQudoelolilwiXARallmz4K8W9WcdyLrYct5)Ou0wEkPmLgLyixNHdy5vGq73uoaHAqOLYe88xbZqP(xyGbWKveGqni0szcWcbeikF7ugh9ZFyZqP(xyGbWKv0dHpVRQjZTpVwNXebenzl(FDDQRwZC7ZR1zmrarJbFEaO4JBYaU3SkQbhuKb)vBPZ7jWhnVd8aN(976uHySI2JA)YdL6FHbwCbuCsinlXjMyzdU0A6(cflaywQjyb4GPaMfvQbhIfNfKflKyTvGLfMmCsE4EyHbSYizHP8FukAlpLugdxAnD3xOYZsnbA)MYbiudcTuMGN)kygk1)cdmGJcRcqeu51zqq1TNyuyvaIGkVot9O2VCZPUUaebvEDM6rTF5MtkcqOgeAPmbyHaceLVDkJJ(5pSzOu)lmWaok6HWN3v1KjaleqGOmiHtuHUUaeQbHwktWZFfmdL6FHbgWPFxxaIGkVodcQU9eJIEwnRIAWbfzWF1w68Ec8rZ7kcqOgeAPmbp)vWmuQ)fgyaNUo1vRzghbvWfo3gQIDcZqP(xyGPK1a4EOb4jG76JIiqZx4BwHdo4m4J4lkRsADFfQRwZmocQGlCUnuf7eMvu)UovigRO9O2V8qP(xyGbq0Wj5H7HfgWkJKfMY)rPOT8us5VWHzDUQMYa3Lx3kndsi(aH2VPS6Q1mbp)vWmuQ)foELqJIEwnRIAWbfzWF1w68Ec8rZ7DDQRwZmocQGlCUnuf7eMHs9VWatjac4EXf4vxTMrvdHG6f(mRO(aUxpafaenaV6Q1mQAieuVWNzf1h4jG76JIiqZx4BwHdo4m4J4lkRsADFfQRwZmocQGlCUnuf7eMvu)UovigRO9O2V8qP(xyGbq0WjH0Sy99hZYJzXzz8BNgwiTRch)iwS4jy5GSK6arS4AnlWILfMybF(XYnFbeDywoilQel6ViqwwrSy5VDwqwSqI1wbw8cKfKbleqGiw8cKLfMy52jwaybYcwdpwGflbqw(glQWBNLB(ci6WS4dXcSyzHjwWNFSCZxarhMtYd3dlmGvgjlmL)JsXOfRHhw5B(ci6ucTFtze(8UQMmWkVWu(MVaIoLbOcRU5lGOZaqZqoyICac1Gqlvxxpe(8UQMmWkVWu(MVaIoLvQRdHpVRQjdSYlmLV5lGOt542xrp1vRzcE(RGzfPONvbicQ86miO62tmDDQRwZmocQGlCUnuf7eMHs9VWaUhAa(zvudoOid(R2sN3tGpAEVpWu(MVaIoJsg1vRLbxJFpSuOUAnZ4iOcUW52qvStywrDDQRwZmocQGlCUnuf7ez8xTLoVNaF08Uzf1VRlaHAqOLYe88xbZqP(xyadW4V5lGOZOKjaHAqOLYaUg)EyPWk1vRzcE(RGzfPONvbicQ86m1JA)YnN66ScHpVRQjtawiGarzqcNOc9vyvaIGkVodqjM3RUUaebvEDM6rTF5Mtkq4Z7QAYeGfciqugKWjQGIaeQbHwktawiGar5BNY4OF(dBwrkSkaHAqOLYe88xbZksrVEQRwZqb9hHPSEv(ygk1)chVsj31PUAndf0FeMYyO2hZqP(x44vk5(kSAwf1GdkYO6AVcug2YUwNV9VqH766PUAnJQR9kqzyl7AD(2)cfox(TgYGppaKYOPRtD1Agvx7vGYWw2168T)fkC2NGxKbFEaiLbe9731PUAndqFboeyMsJGwOjLQltfnO(ytMvu)UU2JA)YdL6FHbgatURdHpVRQjdSYlmLV5lGOt5K5K8W9WcdyLrYct5)OumAXA4Hv(MVaIoaI2VPmcFExvtgyLxykFZxarNvkdqfwDZxarNrjZqoyICac1GqlvxhcFExvtgyLxykFZxarNYaurp1vRzcE(RGzfPONvbicQ86miO62tmDDQRwZmocQGlCUnuf7eMHs9VWaUhAa(zvudoOid(R2sN3tGpAEVpWu(MVaIodanQRwldUg)EyPqD1AMXrqfCHZTHQyNWSI66uxTMzCeubx4CBOk2jY4VAlDEpb(O5DZkQFxxac1GqlLj45VcMHs9VWagGXFZxarNbGMaeQbHwkd4A87HLcRuxTMj45VcMvKIEwfGiOYRZupQ9l3CQRZke(8UQMmbyHaceLbjCIk0xHvbicQ86maLyEVu0Zk1vRzcE(RGzf11zvaIGkVodcQU9et)UUaebvEDM6rTF5Mtkq4Z7QAYeGfciqugKWjQGIaeQbHwktawiGar5BNY4OF(dBwrkSkaHAqOLYe88xbZksrVEQRwZqb9hHPSEv(ygk1)chVsj31PUAndf0FeMYyO2hZqP(x44vk5(kSAwf1GdkYO6AVcug2YUwNV9VqH766PUAnJQR9kqzyl7AD(2)cfox(TgYGppaKYOPRtD1Agvx7vGYWw2168T)fkC2NGxKbFEaiLbe973VRtD1AgG(cCiWmLgbTqtkvxMkAq9XMmROUU2JA)YdL6FHbgatURdHpVRQjdSYlmLV5lGOt5K5KqAwItmHzX1AwG3onSalwwyIL)OumlWILaiNKhUhwyaRmswyk)hLI5KqAwIJu4bjw8W9WIf9JpwuDmbYcSyb)3YVhwirtOEmNKhUhwyaRmsMvL9W9WkRF8H2YtjLDiHw8nF4uwj0(nLr4Z7QAY84SdjojpCpSWawzKmRk7H7Hvw)4dTLNskRc9dT4B(WPSsO9BkpRIAWbfzuDTxbkdBzxRZ3(xOWgc4U(OicKtYd3dlmGvgjZQYE4EyL1p(qB5PKY4JtItcPzbzUoS0(rywSSt3onSC7elXXH80GFHDAyrD1ASy51AwAUwZcS1yXYF7FXYTtSueYpwco(4K8W9WcBCiPmcFExvtOT8uszWH80SLxRZnxRZWwdTiC9IuUN6Q1m3NswGtLbhYtv)cKgZqP(xyGHkaAsDKd4Knk11PUAnZ9PKf4uzWH8u1VaPXmuQ)fgyE4EyzWNpTFidHCkSokFFkb4KnkPOhf0FeMmFL1RYNUokO)imzWqTp5Iq(11rb9hHjJxjYfH8RFFfQRwZCFkzbovgCipv9lqAmRifZQOgCqrM7tjlWPYGd5PQFbsdNesZcYCDyP9JWSyzNUDAyz78bVguelpMflW52zj447luSarqdlBNpTFiw(If0Fv(Wc6f0FeM4K8W9WcBCibyLrccFExvtOT8us5hvbhkJpFWRbfHweUErkBff0FeMmFLXqTpk6HJiToF(GIoSbF(0(HIhnkoxt1zWWLodB5BNYn4q4ZqLRQjWUoCeP15Zhu0Hn4ZN2pu8aQ(CsinlXjMybzWcbeiIfl7uXIFSOjmMLB3lwqtYSelmaIfVazr)fXYkIfl)TZcYIfsS2kWj5H7Hf24qcWkJKaSqabIY3oLXr)8hgTFtzRaN1dAkyoaIv0RhcFExvtMaSqabIYGeorfuyvac1GqlLj45VcMHCWeDDQRwZe88xbZkQVIEQRwZqb9hHPSEv(ygk1)chpWPRtD1AgkO)imLXqTpMHs9VWXdC6RONvZQOgCqrgvx7vGYWw2168T)fkCxN6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqXh3Uo1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGIpU976uHySI2JA)YdL6FHbMsjRWQaeQbHwktWZFfmd5Gj6ZjH0SeNyIL4WqvStWIL)2zbzXcjwBf4K8W9WcBCibyLrY4iOcUW52qvStG2VPS6Q1mbp)vWmuQ)foELqdNesZsCIjw2wv7hILVyjYlqk9dSalw8kXT)fkwUD)yr)iimlkznykGzXlqw0egZIL)2zjfoelNpOOdZIxGS4hl3oXcvGSaBS4SSb1(Wc6f0FeMyXpwuYAybtbmlWHfnHXSmuQ)1xOyXXSCqwk4XYUJ4luSCqwgQneENfW18fkwq)v5dlOxq)ryItYd3dlSXHeGvgj4v1(HqBirqt5Zhu0Hvwj0(nL7nuBi8URQPUo1vRzOG(JWugd1(ygk1)cdS4QGc6pctMVYyO2hfdL6FHbMswJIZ1uDgmCPZWw(2PCdoe(mu5QAcSVIZhu0zUpLYhmd(u8kznaqCeP15Zhu0Hb8qP(xyf9OG(JWK5RSxj66gk1)cdmubqtQJ8(CsinliLikILvelBNpnxRzXpwCTML7tjmlRstymll8xOyb9te8XXS4fil)XYJzXvHRJLdYs0adSahw00XYTtSGJOW7Aw8W9WIf9xelQKgAHLDVa1elXXH8u1VaPHfyXcaz58bfDyojpCpSWghsawzKGpFAUwJ2VPSvNRP6m4J0AFYGZ3odvUQMav0tD1Ag85tZ1AZqTHW7UQMu0dhrAD(8bfDyd(8P5AnWIBxNvZQOgCqrM7tjlWPYGd5PQFbst)UUZ1uDgmCPZWw(2PCdoe(mu5QAcuH6Q1muq)rykJHAFmdL6FHbwCvqb9hHjZxzmu7Jc1vRzWNpnxRndL6FHbgGsboI0685dk6Wg85tZ164v2A6RONvZQOgCqrgDIGpoo30eDFHkJs)PryQR7(ucPIuTg0eV6Q1m4ZNMR1MHs9VWagG9vC(GIoZ9Pu(GzWNIhnCsinlif)TZY2rATpSehNVDSSWelWILailw2PILHAdH3DvnXI66ybFVwZIf)pwAWHf0prWhhZs0adS4filGWcDhllmXIk1GdXcYIJydlB3R1SSWelQudoelidwiGarSG)kqSC7(XILxRzjAGbw8cE70WY25tZ1AojpCpSWghsawzKGpFAUwJ2VP85AQod(iT2Nm48TZqLRQjqfQRwZGpFAUwBgQneE3v1KIEwnRIAWbfz0jc(44Ctt09fQmk9NgHPUU7tjKks1Aqt8wtFfNpOOZCFkLpyg8P4JlNesZcsXF7SehhYtv)cKgwwyILTZNMR1SCqwaIOiwwrSC7elQRwJf1eS4AmKLf(luSSD(0CTMfyXcAybtbybIzboSOjmMLHs9V(cfNKhUhwyJdjaRmsWNpnxRr73uEwf1GdkYCFkzbovgCipv9lqAuGJiToF(GIoSbF(0CToELJRIEwPUAnZ9PKf4uzWH8u1VaPXSIuOUAnd(8P5ATzO2q4DxvtDD9q4Z7QAYaoKNMT8ADU5ADg2Ak6PUAnd(8P5ATzOu)lmWIBxhoI0685dk6Wg85tZ164bOIZ1uDg8rATpzW5BNHkxvtGkuxTMbF(0CT2muQ)fgyOPF)(CsinliZ1HL2pcZILD62PHfNLTZh8AqrSSWelwETMLGVWelBNpnxRz5GS0CTMfyRHww8cKLfMyz78bVguelhKfGikIL44qEQ6xG0Wc(8aqSSI4K8W9WcBCibyLrccFExvtOT8usz85tZ16SfyD5MR1zyRHweUErk74BCDocAHM4bejda7PuYaV6Q1m3NswGtLbhYtv)cKgd(8aq9bG9uxTMbF(0CT2muQ)fg4JlsfhrADE3Xhb8wDUMQZGpsR9jdoF7mu5QAcSpaSxac1GqlLbF(0CT2muQ)fg4JlsfhrADE3Xhb8NRP6m4J0AFYGZ3odvUQMa7da7bcptBnjYWwM0RImdL6FHbE00xrp1vRzWNpnxRnROUUaeQbHwkd(8P5ATzOu)lCFojKML4etSSD(GxdkIfl)TZsCCipv9lqAy5GSaerrSSIy52jwuxTglw(BhUow0q8xOyz78P5AnlRO7tjw8cKLfMyz78bVguelWIfRbWSedySSol4ZdaHzzv3RzXAy58bfDyojpCpSWghsawzKGpFWRbfH2VPmcFExvtgWH80SLxRZnxRZWwtbcFExvtg85tZ16SfyD5MR1zyRPWke(8UQMmpQcougF(GxdkQRRN6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqXh3Uo1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGIpU9vGJiToF(GIoSbF(0CTgywJce(8UQMm4ZNMR1zlW6YnxRZWwJtcPzjoXelyl(KYcgYYT7hljGlwqrhlPoYzzfDFkXIAcww4VqXYFS4yw0(rS4ywIGy8RQjwGflAcJz529IL4Yc(8aqywGdla4SWhlw2PIL4cywWNhacZcH8OFiojpCpSWghsawzK4GE09iOm2IpPOnKiOP85dk6WkReA)MYwDFaOVqPWkpCpSmoOhDpckJT4tAg0tDuK5RCt)O2VUoq4zCqp6EeugBXN0mON6Oid(8aqalUkaHNXb9O7rqzSfFsZGEQJImdL6FHbwC5KqAwaWqTHW7SaGfcR2pelFJfKflKyTvGLhZYqoyc0YYTtdXIpelAcJz529If0WY5dk6WS8flO)Q8Hf0lO)imXIL)2zzdEXb0YIMWywUDVyrPKzbE70y5XelFXIxjyb9c6pctSahwwrSCqwqdlNpOOdZIk1GdXIZc6VkFyb9c6pctgwIJWcDhld1gcVZc4A(cfliL(cCiqwqV0iOfAsP6yzvAcJz5lw2GAFyb9c6pctCsE4EyHnoKaSYijfcR2peAdjcAkF(GIoSYkH2VP8qTHW7UQMuC(GIoZ9Pu(GzWNIVxpLSga3dhrAD(8bfDyd(8P9db8ae4vxTMHc6pctz9Q8XSI63hWdL6FH7Ju7PeGpxt1zolFLtHWcBOYv1eyFf9cqOgeAPmbp)vWmKdMqHvGZ6bnfmhaXk6HWN3v1KjaleqGOmiHtuHUUaeQbHwktawiGar5BNY4OF(dBgYbt01zvaIGkVot9O2VCZP(DD4isRZNpOOdBWNpTFiG1RhWba2tD1AgkO)imL1RYhZkc4by)(aFpLa85AQoZz5RCkewydvUQMa73xHvuq)ryYGHAFYfH8RRRhf0FeMmFLXqTpDD9OG(JWK5RSk8276OG(JWK5RSEv(0xHvNRP6my4sNHT8Tt5gCi8zOYv1eyxN6Q1mrZNchW31zFcE9HC0sJ9XGW1lkELbiAsUVIE4isRZNpOOdBWNpTFiGPuYaFpLa85AQoZz5RCkewydvUQMa73xHJVX15iOfAIhnjdavxTMbF(0CT2muQ)fg4bo9v0Zk1vRza6lWHaZuAe0cnPuDzQOb1hBYSI66OG(JWK5RmgQ9PRZQaebvEDgGsmVx9vyL6Q1mJJGk4cNBdvXorg)vBPZ7jWhnVBwrCsinlXjMyjoaJjlWILailw(BhUowcEu0xO4K8W9WcBCibyLrsdobkdB5YV1qO9Bk7r5WofaItYd3dlSXHeGvgji85DvnH2YtjLdG5aSa)7Hv2HeAr46fPSvGZ6bnfmhaXkq4Z7QAYeaZbyb(3dlf96PUAnd(8P5ATzf11DUMQZGpsR9jdoF7mu5QAcSRlarqLxNPEu7xU5uFf9SsD1AgmuJVpqMvKcRuxTMj45VcMvKIEwDUMQZ0wtImSLj9QidvUQMa76uxTMj45VcgW143dR4dqOgeAPmT1KidBzsVkYmuQ)fgWaI(kq4Z7QAYC7ZR1zmrart2I)NIEwfGiOYRZupQ9l3CQRlaHAqOLYeGfciqu(2Pmo6N)WMvKIEQRwZGpFAUwBgk1)cdma21z15AQod(iT2Nm48TZqLRQjW(9vC(GIoZ9Pu(GzWNIxD1AMGN)kyaxJFpSa(KnaQ(DDTh1(Lhk1)cdm1vRzcE(RGbCn(9WQpNesZsCIjwqwSqI1wbwGflbqwwLMWyw8cKf9xel)XYkIfl)TZcYGfciqeNKhUhwyJdjaRmscKMW376SRFuvkvhA)MYi85DvnzcG5aSa)7Hv2HeNKhUhwyJdjaRms(k4t53dl0(nLr4Z7QAYeaZbyb(3dRSdjojKML4etSGEPrql0WsmGfilWILailw(BNLTZNMR1SSIyXlqwWocILgCybaT0yFyXlqwqwSqI1wbojpCpSWghsawzKqPrql0KvHfiA)MYQqmwXxhnrqTFeyU9O2V8qP(xyGPeA666PUAnt08PWb8DD2NGxFihT0yFmiC9IagartYDDQRwZenFkCaFxN9j41hYrln2hdcxVO4vgGOj5(kuxTMbF(0CT2SIu0laHAqOLYe88xbZqP(x44rtYDDGZ6bnfmhaX95KqAwaWqTHW7S00(qSalwwrSCqwIllNpOOdZIL)2HRJfKflKyTvGfv6luS4QW1XYbzHqE0pelEbYsbpwGiOj4rrFHItYd3dlSXHeGvgj4J0AFYnTpeAdjcAkF(GIoSYkH2VP8qTHW7UQMuCFkLpyg8P4vcnkWrKwNpFqrh2GpFA)qaZAu4r5Wofasrp1vRzcE(RGzOu)lC8kLCxNvQRwZe88xbZkQpNesZsCIjwIdq0JLVXYx4hKyXlwqVG(JWelEbYI(lIL)yzfXIL)2zXzbaT0yFyjAGbw8cKLyb6r3JGyzZIpPCsE4EyHnoKaSYiPTMezylt6vrO9Bktb9hHjZxzVsOWJYHDkaKc1vRzIMpfoGVRZ(e86d5OLg7JbHRxeWaiAswrpq4zCqp6EeugBXN0mON6OiZ9bG(cvxNvbicQ86mffgOgoGDD4isRZNpOOdhpa7RON6Q1mJJGk4cNBdvXoHzOu)lmWaKaWEOb4Nvrn4GIm4VAlDEpb(O59(kuxTMzCeubx4CBOk2jmROUoRuxTMzCeubx4CBOk2jmRO(k6zvac1GqlLj45VcMvuxN6Q1m3(8ADgteq0yWNhacykHgfTh1(Lhk1)cdmaMCYkApQ9lpuQ)foELso5UoRWWLw9lqZTpVwNXebengQCvnb2xrpmCPv)c0C7ZR1zmrarJHkxvtGDDbiudcTuMGN)kygk1)chFCtUpNesZsCIjwCw2oFAUwZca(IUDwIgyGLvPjmMLTZNMR1S8ywC9qoycwwrSahwsaxS4dXIRcxhlhKficAcEelXcdG4K8W9WcBCibyLrc(8P5AnA)MYQRwZal62X5iAcu09WYSIu0tD1Ag85tZ1AZqTHW7UQM66C8nUohbTqt8aYK7ZjH0SehxPrSelmaIfvQbhIfKbleqGiwS83olBNpnxRzXlqwUDQyz78bVgueNKhUhwyJdjaRmsWNpnxRr73uoarqLxNPEu7xU5KcRoxt1zWhP1(KbNVDgQCvnbQOhcFExvtMaSqabIYGeorf66cqOgeAPmbp)vWSI66uxTMj45VcMvuFfbiudcTuMaSqabIY3oLXr)8h2muQ)fgyOcGMuh5aFGEDphFJRZrql0GurtY9vOUAnd(8P5ATzOu)lmWSgfwboRh0uWCaeZj5H7Hf24qcWkJe85dEnOi0(nLdqeu51zQh1(LBoPOhcFExvtMaSqabIYGeorf66cqOgeAPmbp)vWSI66uxTMj45VcMvuFfbiudcTuMaSqabIY3oLXr)8h2muQ)fgyahfQRwZGpFAUwBwrkOG(JWK5RSxjuyfcFExvtMhvbhkJpFWRbfPWkWz9GMcMdGyojKML4etSSD(GxdkIfl)TZIxSaGVOBNLObgyboS8nwsaxOdKficAcEelXcdGyXYF7SKaUgwkc5hlbhFgwILgdzbCLgXsSWaiw8JLBNyHkqwGnwUDIfaCP62tmSOUAnw(glBNpnxRzXcCPbl0DS0CTMfyRXcCyjbCXIpelWIfaYY5dk6WCsE4EyHnoKaSYibF(GxdkcTFtz1vRzGfD74Cqt(Kr84hwMvuxxpRWNpTFiJhLd7uaifwHWN3v1K5rvWHY4Zh8AqrDD9uxTMj45VcMHs9VWadnkuxTMj45VcMvuxxVEQRwZe88xbZqP(xyGHkaAsDKd8b619C8nUohbTqdsnUj3xH6Q1mbp)vWSI66uxTMzCeubx4CBOk2jY4VAlDEpb(O5DZqP(xyGHkaAsDKd8b619C8nUohbTqdsnUj3xH6Q1mJJGk4cNBdvXorg)vBPZ7jWhnVBwr9veGiOYRZGGQBpX0VVIE4isRZNpOOdBWNpnxRbwC76q4Z7QAYGpFAUwNTaRl3CTodBT(9vyfcFExvtMhvbhkJpFWRbfPONvZQOgCqrM7tjlWPYGd5PQFbstxhoI0685dk6Wg85tZ1AGf3(CsinlXjMybalewyw(ILnO2hwqVG(JWelEbYc2rqSehwAnlayHWILgCybzXcjwBf4K8W9WcBCibyLrsrwYPqyH2VPCp1vRzOG(JWugd1(ygk1)chpHCkSokFFk111lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaiojpCpSWghsawzKS76wofcl0(nL7PUAndf0FeMYyO2hZqP(x44jKtH1r57tPUUEHDFqryLbOIHc7(GIY3Nsadn976c7(GIWkh3(k8OCyNcaPON6Q1mJJGk4cNBdvXoHzOu)lmWqJc1vRzghbvWfo3gQIDcZksHvZQOgCqrg8xTLoVNaF08ExNvQRwZmocQGlCUnuf7eMvuFojpCpSWghsawzK0wADofcl0(nL7PUAndf0FeMYyO2hZqP(x44jKtH1r57tjf9cqOgeAPmbp)vWmuQ)foE0KCxxac1GqlLjaleqGO8TtzC0p)HndL6FHJhnj3VRRxy3huewzaQyOWUpOO89PeWqt)UUWUpOiSYXTVcpkh2Paqk6PUAnZ4iOcUW52qvStygk1)cdm0OqD1AMXrqfCHZTHQyNWSIuy1SkQbhuKb)vBPZ7jWhnV31zL6Q1mJJGk4cNBdvXoHzf1NtcPzjoXelifq0JfyXcYIJCsE4EyHnoKaSYiXIpZdNmSLj9QiojKMfK56Ws7hHzXYoD70WYbzzHjw2oFA)qS8flBqTpSyz)d7S8yw8Jf0WY5dk6WawjwAWHfcbnjybGjJuzj1XhnjyboSynSSD(GxdkIf0lncAHMuQowWNhacZj5H7Hf24qcWkJee(8UQMqB5PKY4ZN2pu(RmgQ9bTiC9IughrAD(8bfDyd(8P9dfV1a4MgcNEPo(OjrgHRxeWRuYjJubyY9bCtdHtp1vRzWNp41GIYuAe0cnPuDzmu7JbFEaiKQ10NtcPzbzUoS0(rywSSt3onSCqwqkg)2zbCnFHIL4WqvStWj5H7Hf24qcWkJee(8UQMqB5PKYwg)2ZFLBdvXobAr46fPSsivCeP15DhFeWaiaSxYgac89WrKwNpFqrh2GpFA)qaqL6d89ucWNRP6my4sNHT8Tt5gCi8zOYv1eiWRKbn97d4KnkHgGxD1AMXrqfCHZTHQyNWmuQ)fMtcPzjoXelifJF7S8flBqTpSGEb9hHjwGdlFJLcYY25t7hIflVwZs7pw(6GSGSyHeRTcS4vIu4qCsE4EyHnoKaSYiXY43oA)MY9OG(JWKrVkFYfH8RRJc6pctgVsKlc5Nce(8UQMmpoh0KJG6RO35dk6m3Ns5dMbFkERPRJc6pctg9Q8j)vgGDDTh1(Lhk1)cdmLsUFxN6Q1muq)rykJHAFmdL6FHbMhUhwg85t7hYqiNcRJY3NskuxTMHc6pctzmu7Jzf11rb9hHjZxzmu7JcRq4Z7QAYGpFA)q5VYyO2NUo1vRzcE(RGzOu)lmW8W9WYGpFA)qgc5uyDu((usHvi85DvnzECoOjhbPqD1AMGN)kygk1)cdmc5uyDu((usH6Q1mbp)vWSI66uxTMzCeubx4CBOk2jmRifi85DvnzSm(TN)k3gQIDIUoRq4Z7QAY84CqtocsH6Q1mbp)vWmuQ)foEc5uyDu((uItcPzjoXelBNpTFiw(glFXc6VkFyb9c6pctOLLVyzdQ9Hf0lO)imXcSyXAamlNpOOdZcCy5GSenWalBqTpSGEb9hHjojpCpSWghsawzKGpFA)qCsinlXbxRV9zXj5H7Hf24qcWkJKzvzpCpSY6hFOT8us5MR13(S4K4KqAwIddvXoblw(BNfKflKyTvGtYd3dlSrf6NYJJGk4cNBdvXobA)MYQRwZe88xbZqP(x44vcnCsinlXjMyjwGE09iiw2S4tklw2PIf)yrtyml3UxSynSedySSol4ZdaHzXlqwoild1gcVZIZcWugGSGppaeloMfTFeloMLiig)QAIf4WY9Pel)XcgYYFS4Z8iimla4SWhlE7OHfNL4cywWNhaIfc5r)qyojpCpSWgvOFawzK4GE09iOm2IpPOnKiOP85dk6WkReA)MYQRwZO6AVcug2YUwNV9VqHZLFRHm4ZdabmaHc1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGagGqrpRaHNXb9O7rqzSfFsZGEQJIm3ha6lukSYd3dlJd6r3JGYyl(KMb9uhfz(k30pQ9trpRaHNXb9O7rqzSfFsZ7KRn3ha6luDDGWZ4GE09iOm2IpP5DY1MHs9VWXh3(DDGWZ4GE09iOm2IpPzqp1rrg85bGawCvacpJd6r3JGYyl(KMb9uhfzgk1)cdm0OaeEgh0JUhbLXw8jnd6PokYCFaOVq1NtcPzjoXelidwiGarSy5VDwqwSqI1wbwSStflrqm(v1elEbYc82PXYJjwS83ololXaglRZI6Q1yXYovSas4ev4luCsE4EyHnQq)aSYijaleqGO8TtzC0p)Hr73u2kWz9GMcMdGyf96HWN3v1KjaleqGOmiHtubfwfGqni0szcE(RGzihmrxN6Q1mbp)vWSI6RON6Q1mQU2RaLHTSR15B)lu4C53Aid(8aqkdi66uxTMr11EfOmSLDToF7FHcN9j4fzWNhaszar)UovigRO9O2V8qP(xyGPuY95KqAwIdq0JfhZYTtS0(bFSGkaYYxSC7elolXaglRZILVaHwyboSy5VDwUDIfKsjM3lwuxTglWHfl)TZIZcGaWykWsSa9O7rqSSzXNuw8cKfl(FS0GdlilwiXARalFJL)yXcSowujwwrS4O8VyrLAWHy52jwcGS8ywAF94DcKtYd3dlSrf6hGvgjT1KidBzsVkcTFt5E96PUAnJQR9kqzyl7AD(2)cfox(TgYGppau8aNUo1vRzuDTxbkdBzxRZ3(xOWzFcErg85bGIh40xrpRcqeu51zqq1TNy66SsD1AMXrqfCHZTHQyNWSI63xrpWz9GMcMdG4UUaeQbHwktWZFfmdL6FHJhnj311larqLxNPEu7xU5KIaeQbHwktawiGar5BNY4OF(dBgk1)chpAsUF)(DD9aHNXb9O7rqzSfFsZGEQJImdL6FHJhqOiaHAqOLYe88xbZqP(x44vkzfbicQ86mffgOgoG976uHySIVoAIGA)iWC7rTF5Hs9VWadqOWQaeQbHwktWZFfmd5Gj66cqeu51zakX8EPqD1AgG(cCiWmLgbTqtkvNzf11fGiOYRZGGQBpXOqD1AMXrqfCHZTHQyNWmuQ)fgyasfQRwZmocQGlCUnuf7eMveNesZcY8kqAw2oF0WbKfl)TZIZsrwyjgWyzDwuxTglEbYcYIfsS2kWYJl0DS4QW1XYbzrLyzHjqojpCpSWgvOFawzKe8kq6S6Q1qB5PKY4ZhnCar73uUN6Q1mQU2RaLHTSR15B)lu4C53AiZqP(x44bug001PUAnJQR9kqzyl7AD(2)cfo7tWlYmuQ)foEaLbn9v0laHAqOLYe88xbZqP(x44buDD9cqOgeAPmuAe0cnzvybAgk1)chpGsHvQRwZa0xGdbMP0iOfAsP6YurdQp2KzfPiarqLxNbOeZ7v)(kC8nUohbTqt8kh3K5KqAwIJR0iw2oFWRbfHzXYF7S4SedySSolQRwJf11XsbpwSStflrqO(luS0GdlilwiXARalWHfKsFboeilBr)8hMtYd3dlSrf6hGvgj4Zh8AqrO9Bk3tD1Agvx7vGYWw2168T)fkCU8BnKbFEaO4byxN6Q1mQU2RaLHTSR15B)lu4SpbVid(8aqXdW(k6fGiOYRZupQ9l3CQRlaHAqOLYe88xbZqP(x44buDDwHWN3v1KjaMdWc8VhwkSkarqLxNbOeZ7vxxVaeQbHwkdLgbTqtwfwGMHs9VWXdOuyL6Q1ma9f4qGzkncAHMuQUmv0G6Jnzwrkcqeu51zakX8E1VVIEwbcptBnjYWwM0RIm3ha6luDDwfGqni0szcE(RGzihmrxNvbiudcTuMaSqabIY3oLXr)8h2mKdMOpNesZsCCLgXY25dEnOimlQudoelidwiGarCsE4EyHnQq)aSYibF(GxdkcTFt5EbiudcTuMaSqabIY3oLXr)8h2muQ)fgyOrHvGZ6bnfmhaXk6HWN3v1KjaleqGOmiHtuHUUaeQbHwktWZFfmdL6FHbgA6RaHpVRQjtamhGf4FpS6RWkq4zARjrg2YKEvK5(aqFHsraIGkVot9O2VCZjfwboRh0uWCaeRGc6pctMVYELqHJVX15iOfAI3AsMtcPzjocl0DSacpwaxZxOy52jwOcKfyJfamocQGlmlXHHQyNaTSaUMVqXcqFboeiluAe0cnPuDSahw(ILBNyr74JfubqwGnw8If0lO)imXj5H7Hf2Oc9dWkJee(8UQMqB5PKYGWlpeWD9dLs1HrlcxViL7PUAnZ4iOcUW52qvStygk1)chpA66SsD1AMXrqfCHZTHQyNWSI6RON6Q1ma9f4qGzkncAHMuQUmv0G6Jnzgk1)cdmubqtQJ8(k6PUAndf0FeMYyO2hZqP(x44rfanPoY76uxTMHc6pctz9Q8XmuQ)foEubqtQJ8(CsE4EyHnQq)aSYibVQ2peAdjcAkF(GIoSYkH2VP8qTHW7UQMuC(GIoZ9Pu(GzWNIxjGJcpkh2Paqkq4Z7QAYacV8qa31pukvhMtYd3dlSrf6hGvgjPqy1(HqBirqt5Zhu0Hvwj0(nLhQneE3v1KIZhu0zUpLYhmd(u8kfxdAu4r5WofasbcFExvtgq4Lhc4U(HsP6WCsE4EyHnQq)aSYibFKw7tUP9HqBirqt5Zhu0Hvwj0(nLhQneE3v1KIZhu0zUpLYhmd(u8kbCa8qP(xyfEuoStbGuGWN3v1KbeE5HaURFOuQomNesZsCagtwGflbqwS83oCDSe8OOVqXj5H7Hf2Oc9dWkJKgCcug2YLFRHq73u2JYHDkaeNesZc6LgbTqdlXawGSyzNkwCv46y5GSq1rdlolfzHLyaJL1zXYxGqlS4filyhbXsdoSGSyHeRTcCsE4EyHnQq)aSYiHsJGwOjRclq0(nL7rb9hHjJEv(Klc5xxhf0FeMmyO2NCri)66OG(JWKXRe5Iq(11PUAnJQR9kqzyl7AD(2)cfox(TgYmuQ)foEaLbnDDQRwZO6AVcug2YUwNV9VqHZ(e8ImdL6FHJhqzqtxNJVX15iOfAIhqMSIaeQbHwktWZFfmd5Gjuyf4SEqtbZbqCFf9cqOgeAPmbp)vWmuQ)fo(4MCxxac1GqlLj45VcMHCWe976uHySIVoAIGA)iWC7rTF5Hs9VWatPK5KqAwIdq0JL5rTFSOsn4qSSWFHIfKflojpCpSWgvOFawzK0wtImSLj9Qi0(nLdqOgeAPmbp)vWmKdMqbcFExvtMayoalW)EyPONJVX15iOfAIhqMScRcqeu51zQh1(LBo11fGiOYRZupQ9l3CsHJVX15iOfAaM1KCFfwfGiOYRZGGQBpXOONvbicQ86m1JA)YnN66cqOgeAPmbyHaceLVDkJJ(5pSzihmrFfwboRh0uWCaeZjH0SGSyHeRTcSyzNkw8JfazYaMLyHbqS0doAOfAy529IfRjzwIfgaXIL)2zbzWcbeiQplw(BhUow0q8xOy5(uILVyjgAieuVWhlEbYI(lILvelw(BNfKbleqGiw(gl)XIfhZciHtubcKtYd3dlSrf6hGvgji85DvnH2YtjLdG5aSa)7Hvwf6hAr46fPSvGZ6bnfmhaXkq4Z7QAYeaZbyb(3dlf9654BCDocAHM4bKjRON6Q1ma9f4qGzkncAHMuQUmv0G6JnzwrDDwfGiOYRZauI59QFxN6Q1mQAieuVWNzfPqD1AgvnecQx4ZmuQ)fgyQRwZe88xbd4A87Hv)UUVoAIGA)iWC7rTF5Hs9VWatD1AMGN)kyaxJFpS66cqeu51zQh1(LBo1xrpRcqeu51zQh1(LBo111ZX346Ce0cnaZAsURdeEM2AsKHTmPxfzUpa0xO6ROhcFExvtMaSqabIYGeorf66cqOgeAPmbyHaceLVDkJJ(5pSzihmr)(CsE4EyHnQq)aSYijqAcFVRZU(rvPuDO9BkJWN3v1KjaMdWc8VhwzvOFCsE4EyHnQq)aSYi5RGpLFpSq73ugHpVRQjtamhGf4FpSYQq)4KqAwqp89P(ryw2HwyjDf2zjwyael(qSGY)IazjIgwWuawGCsE4EyHnQq)aSYibHpVRQj0wEkPSJJaq0Srb0IW1lszkO)imz(kRxLpapGaP6H7HLbF(0(HmeYPW6O89PeGTIc6pctMVY6v5dW3d4a4Z1uDgmCPZWw(2PCdoe(mu5QAce4JBFKQhUhwglJF7gc5uyDu((ucWjBaisfhrADE3XhXjH0SehxPrSSD(GxdkcZILDQy52jwApQ9JLhZIRcxhlhKfQarllTHQyNGLhZIRcxhlhKfQarlljGlw8HyXpwaKjdywIfgaXYxS4flOxq)rycTSGSyHeRTcSOD8HzXl4TtdlacaJPaMf4Wsc4IflWLgKficAcEelPWHy529IfUtPKzjwyaelw2PILeWflwGlnyHUJLTZh8AqrSuqlCsE4EyHnQq)aSYibF(GxdkcTFt5EQqmwXxhnrqTFeyU9O2V8qP(xyGznDD9uxTMzCeubx4CBOk2jmdL6FHbgQaOj1roWhOx3ZX346Ce0cni14MCFfQRwZmocQGlCUnuf7eMvu)(DD9C8nUohbTqdGr4Z7QAY44iaenBua4vxTMHc6pctzmu7JzOu)lmGbHNPTMezylt6vrM7daHZdL6Fb8a0GM4vsPK76C8nUohbTqdGr4Z7QAY44iaenBua4vxTMHc6pctz9Q8XmuQ)fgWGWZ0wtImSLj9QiZ9bGW5Hs9VaEaAqt8kPuY9vqb9hHjZxzVsOONvQRwZe88xbZkQRZQZ1uDg85JgoGgQCvnb2xrVEwfGqni0szcE(RGzf11fGiOYRZauI59sHvbiudcTugkncAHMSkSanRO(DDbicQ86m1JA)YnN6RONvbicQ86miO62tmDDwPUAntWZFfmROUohFJRZrql0epGm5(DD9oxt1zWNpA4aAOYv1eOc1vRzcE(RGzfPON6Q1m4ZhnCan4ZdabS42154BCDocAHM4bKj3VFxN6Q1mbp)vWSIuyL6Q1mJJGk4cNBdvXoHzfPWQZ1uDg85JgoGgQCvnbYjH0SeNyIfaSqyHz5lwq)v5dlOxq)ryIfVazb7iiwqkJRBaooS0AwaWcHfln4WcYIfsS2kWj5H7Hf2Oc9dWkJKISKtHWcTFt5EQRwZqb9hHPSEv(ygk1)chpHCkSokFFk111lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaiojpCpSWgvOFawzKS76wofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PKIEbiudcTuMGN)kygk1)chpAsURlaHAqOLYeGfciqu(2Pmo6N)WMHs9VWXJMK7311lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaiojpCpSWgvOFawzK0wADofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PKIEbiudcTuMGN)kygk1)chpAsURlaHAqOLYeGfciqu(2Pmo6N)WMHs9VWXJMK7311lS7dkcRmavmuy3huu((ucyOPFxxy3huew542xHhLd7uaiojKMfKci6XcSyjaYj5H7Hf2Oc9dWkJel(mpCYWwM0RI4KqAwItmXY25t7hILdYs0adSSb1(Wc6f0FeMyboSyzNkw(IfyPtWc6VkFyb9c6pctS4fillmXcsbe9yjAGbmlFJLVyb9xLpSGEb9hHjojpCpSWgvOFawzKGpFA)qO9Bktb9hHjZxz9Q8PRJc6pctgmu7tUiKFDDuq)ryY4vICri)66uxTMXIpZdNmSLj9QiZksH6Q1muq)rykRxLpMvuxxp1vRzcE(RGzOu)lmW8W9WYyz8B3qiNcRJY3NskuxTMj45VcMvuFojpCpSWgvOFawzKyz8BNtYd3dlSrf6hGvgjZQYE4EyL1p(qB5PKYnxRV9zXjXjH0SSD(GxdkILgCyjfIGsP6yzvAcJzzH)cflXaglRZj5H7Hf20CT(2NLY4Zh8AqrO9BkB1SkQbhuKr11EfOmSLDToF7FHcBiG76JIiqojKMfK54JLBNybeESy5VDwUDILui(y5(uILdYIdcYYQUxZYTtSK6iNfW143dlwEml7)zyzBvTFiwgk1)cZs6sFFK(jqwoilP(f2zjfcR2pelGRXVhwCsE4EyHnnxRV9zbyLrcEvTFi0gse0u(8bfDyLvcTFtzq4zsHWQ9dzgk1)ch)qP(xyGhGaePQeGGtYd3dlSP5A9TplaRmssHWQ9dXjXjH0SeNyILTZh8AqrSCqwaIOiwwrSC7elXXH8u1VaPHf1vRXY3y5pwSaxAqwiKh9dXIk1GdXs7RhV)fkwUDILIq(XsWXhlWHLdYc4knIfvQbhIfKbleqGiojpCpSWg8Pm(8bVgueA)MYZQOgCqrM7tjlWPYGd5PQFbsJIEuq)ryY8v2RekSQxp1vRzUpLSaNkdoKNQ(finMHs9VWX7H7HLXY43UHqofwhLVpLaCYgLu0Jc6pctMVYQWBVRJc6pctMVYyO2NUokO)imz0RYNCri)631PUAnZ9PKf4uzWH8u1VaPXmuQ)foEpCpSm4ZN2pKHqofwhLVpLaCYgLu0Jc6pctMVY6v5txhf0FeMmyO2NCri)66OG(JWKXRe5Iq(1VFxNvQRwZCFkzbovgCipv9lqAmRO(DD9uxTMj45VcMvuxhcFExvtMaSqabIYGeorf6RiaHAqOLYeGfciqu(2Pmo6N)WMHCWekcqeu51zQh1(LBo1xrpRcqeu51zakX8E11fGqni0szO0iOfAYQWc0muQ)foEarFf9uxTMj45VcMvuxNvbiudcTuMGN)kygYbt0NtcPzjoXelXc0JUhbXYMfFszXYovSC70qS8ywkilE4Eeelyl(KIwwCmlA)iwCmlrqm(v1elWIfSfFszXYF7SaqwGdlnYcnSGppaeMf4WcSyXzjUaMfSfFszbdz529JLBNyPilSGT4tkl(mpccZcaol8XI3oAy529JfSfFszHqE0peMtYd3dlSbFawzK4GE09iOm2IpPOnKiOP85dk6WkReA)MYwbcpJd6r3JGYyl(KMb9uhfzUpa0xOuyLhUhwgh0JUhbLXw8jnd6PokY8vUPFu7NIEwbcpJd6r3JGYyl(KM3jxBUpa0xO66aHNXb9O7rqzSfFsZ7KRndL6FHJhn976aHNXb9O7rqzSfFsZGEQJIm4ZdabS4QaeEgh0JUhbLXw8jnd6PokYmuQ)fgyXvbi8moOhDpckJT4tAg0tDuK5(aqFHItcPzjoXeMfKbleqGiw(glilwiXARalpMLvelWHLeWfl(qSas4ev4luSGSyHeRTcSy5VDwqgSqabIyXlqwsaxS4dXIkPHwyXAsMLyHbqCsE4EyHn4dWkJKaSqabIY3oLXr)8hgTFtzRaN1dAkyoaIv0RhcFExvtMaSqabIYGeorfuyvac1GqlLj45VcMHCWekSAwf1GdkYenFkCaFxN9j41hYrln2NUo1vRzcE(RGzf1xHJVX15iOfAaMYwtYk6PUAndf0FeMY6v5JzOu)lC8kLCxN6Q1muq)rykJHAFmdL6FHJxPK731PcXyfTh1(Lhk1)cdmLswHvbiudcTuMGN)kygYbt0NtcPzbzWc8VhwS0GdlUwZci8WSC7(XsQdeHzbVgILBNsWIpuHUJLHAdH3jqwSStflayCeubxywIddvXobl7oMfnHXSC7EXcAybtbmldL6F9fkwGdl3oXcqjM3lwuxTglpMfxfUowoilnxRzb2ASahw8kblOxq)ryILhZIRcxhlhKfc5r)qCsE4EyHn4dWkJee(8UQMqB5PKYGWlpeWD9dLs1HrlcxViL7PUAnZ4iOcUW52qvStygk1)chpA66SsD1AMXrqfCHZTHQyNWSI6RWk1vRzghbvWfo3gQIDIm(R2sN3tGpAE3SIu0tD1AgG(cCiWmLgbTqtkvxMkAq9XMmdL6FHbgQaOj1rEFf9uxTMHc6pctzmu7JzOu)lC8OcGMuh5DDQRwZqb9hHPSEv(ygk1)chpQaOj1rExxpRuxTMHc6pctz9Q8XSI66SsD1AgkO)imLXqTpMvuFfwDUMQZGHA89bYqLRQjW(CsinlidwG)9WILB3pwc7uaimlFJLeWfl(qSaxh(bjwOG(JWelhKfyPtWci8y52PHyboS8Ok4qSC7pMfl)TZYguJVpqCsE4EyHn4dWkJee(8UQMqB5PKYGWldxh(bPmf0FeMqlcxViL7zL6Q1muq)rykJHAFmRifwPUAndf0FeMY6v5Jzf1VR7CnvNbd147dKHkxvtGCsE4EyHn4dWkJKuiSA)qOnKiOP85dk6WkReA)MYd1gcV7QAsrp1vRzOG(JWugd1(ygk1)ch)qP(x4Uo1vRzOG(JWuwVkFmdL6FHJFOu)lCxhcFExvtgq4LHRd)GuMc6pct9vmuBi8URQjfNpOOZCFkLpyg8P4vcGk8OCyNcaPaHpVRQjdi8YdbCx)qPuDyojpCpSWg8byLrcEvTFi0gse0u(8bfDyLvcTFt5HAdH3DvnPON6Q1muq)rykJHAFmdL6FHJFOu)lCxN6Q1muq)rykRxLpMHs9VWXpuQ)fURdHpVRQjdi8YW1HFqktb9hHP(kgQneE3v1KIZhu0zUpLYhmd(u8kbqfEuoStbGuGWN3v1KbeE5HaURFOuQomNKhUhwyd(aSYibFKw7tUP9HqBirqt5Zhu0Hvwj0(nLhQneE3v1KIEQRwZqb9hHPmgQ9XmuQ)fo(Hs9VWDDQRwZqb9hHPSEv(ygk1)ch)qP(x4Uoe(8UQMmGWldxh(bPmf0FeM6RyO2q4DxvtkoFqrN5(ukFWm4tXReWrHhLd7uaifi85DvnzaHxEiG76hkLQdZjH0SeNyIL4amMSalwcGSy5VD46yj4rrFHItYd3dlSbFawzK0GtGYWwU8BneA)MYEuoStbG4KqAwItmXcsPVahcKLTOF(dZIL)2zXReSOHfkwOcUqTZI2X3xOyb9c6pctS4fil3KGLdYI(lIL)yzfXIL)2zbaT0yFyXlqwqwSqI1wbojpCpSWg8byLrcLgbTqtwfwGO9Bk3RN6Q1muq)rykJHAFmdL6FHJxPK76uxTMHc6pctz9Q8XmuQ)foELsUVIaeQbHwktWZFfmdL6FHJpUjRON6Q1mrZNchW31zFcE9HC0sJ9XGW1lcya0AsURZQzvudoOit08PWb8DD2NGxFihT0yFmeWD9rrey)(DDQRwZenFkCaFxN9j41hYrln2hdcxVO4vgGaQK76cqOgeAPmbp)vWmKdMqHJVX15iOfAIhqMmNesZsCIjwqwSqI1wbwS83olidwiGaribP0xGdbYYw0p)HzXlqwaHf6owGiOXY8hXcaAPX(WcCyXYovSednecQx4JflWLgKfc5r)qSOsn4qSGSyHeRTcSqip6hcZj5H7Hf2GpaRmsq4Z7QAcTLNskhaZbyb(3dRm(qlcxViLTcCwpOPG5aiwbcFExvtMayoalW)EyPOxVaeQbHwkdLgLyixNHdy5vGmdL6FHbMsahafG7PKsa)SkQbhuKb)vBPZ7jWhnV3xbbCxFuebAO0Oed56mCalVcu)UohFJRZrql0eVYaYKv0ZQZ1uDM2AsKHTmPxfzOYv1eyxN6Q1mbp)vWaUg)EyfFac1GqlLPTMezylt6vrMHs9VWagq0xbcFExvtMBFEToJjciAYw8)u0tD1AgG(cCiWmLgbTqtkvxMkAq9XMmROUoRcqeu51zakX8E1xX5dk6m3Ns5dMbFkE1vRzcE(RGbCn(9Wc4t2aO66uHySI2JA)YdL6FHbM6Q1mbp)vWaUg)Ey11fGiOYRZupQ9l3CQRtD1AgvnecQx4ZSIuOUAnJQgcb1l8zgk1)cdm1vRzcE(RGbCn(9WcW9aKa)SkQbhuKjA(u4a(Uo7tWRpKJwASpgc4U(OicSFFfwPUAntWZFfmRif9SkarqLxNPEu7xU5uxxac1GqlLjaleqGO8TtzC0p)HnROUovigRO9O2V8qP(xyGfGqni0szcWcbeikF7ugh9ZFyZqP(xyadC66ApQ9lpuQ)fgPIuvcqKmWuxTMj45VcgW143dR(CsinlXjMy52jwaWLQBpXWIL)2zXzbzXcjwBfy529JLhxO7yPnWuwaqln2hojpCpSWg8byLrY4iOcUW52qvStG2VPS6Q1mbp)vWmuQ)foELqtxN6Q1mbp)vWaUg)EybS4MSce(8UQMmbWCawG)9WkJpojpCpSWg8byLrsG0e(ExND9JQsP6q73ugHpVRQjtamhGf4FpSY4trpRuxTMj45VcgW143dR4JBYDDwfGiOYRZGGQBpX0VRtD1AMXrqfCHZTHQyNWSIuOUAnZ4iOcUW52qvStygk1)cdmajGdWcC9NjAOWJPSRFuvkvN5(ukJW1lcW9SsD1AgvnecQx4ZSIuy15AQod(8rdhqdvUQMa7Zj5H7Hf2GpaRms(k4t53dl0(nLr4Z7QAYeaZbyb(3dRm(4KqAwaW1N3v1ellmbYcSyXvF9FpHz529JflEDSCqwujwWoccKLgCybzXcjwBfybdz529JLBNsWIpuDSyXXhbYcaol8XIk1GdXYTtPCsE4EyHn4dWkJee(8UQMqB5PKYyhbLBWjh88xb0IW1lszRcqOgeAPmbp)vWmKdMORZke(8UQMmbyHaceLbjCIkOiarqLxNPEu7xU5uxh4SEqtbZbqmNesZsCIjmlXbi6XY3y5lw8If0lO)imXIxGSCZtywoil6Viw(JLvelw(BNfa0sJ9bTSGSyHeRTcS4filXc0JUhbXYMfFs5K8W9WcBWhGvgjT1KidBzsVkcTFtzkO)imz(k7vcfEuoStbGuOUAnt08PWb8DD2NGxFihT0yFmiC9IagaTMKv0deEgh0JUhbLXw8jnd6PokYCFaOVq11zvaIGkVotrHbQHdyFfi85DvnzWock3Gto45Vck6PUAnZ4iOcUW52qvStygk1)cdmajaShAa(zvudoOid(R2sN3tGpAEVVc1vRzghbvWfo3gQIDcZkQRZk1vRzghbvWfo3gQIDcZkQpNesZsCIjwaWx0TZY25tZ1AwIgyaZY3yz78P5AnlpUq3XYkItYd3dlSbFawzKGpFAUwJ2VPS6Q1mWIUDCoIMafDpSmRifQRwZGpFAUwBgQneE3v1eNKhUhwyd(aSYij4vG0z1vRH2YtjLXNpA4aI2VPS6Q1m4ZhnCandL6FHbgAu0tD1AgkO)imLXqTpMHs9VWXJMUo1vRzOG(JWuwVkFmdL6FHJhn9v44BCDocAHM4bKjZjH0SehxPrywIfgaXIk1GdXcYGfciqell8xOy52jwqgSqabIyjalW)EyXYbzjStbGy5BSGmyHaceXYJzXd3Y16eS4QW1XYbzrLyj44JtYd3dlSbFawzKGpFWRbfH2VPCaIGkVot9O2VCZjfi85DvnzcWcbeikds4evqrac1GqlLjaleqGO8TtzC0p)HndL6FHbgAuyf4SEqtbZbqSckO)imz(k7vcfo(gxNJGwOjERjzojKML4etSSD(0CTMfl)TZY2rATpSehNVDS4filfKLTZhnCarllw2PILcYY25tZ1AwEmlRi0Ysc4IfFiw(If0Fv(Wc6f0FeMyPbhwaeagtbmlWHLdYs0adSaGwASpSyzNkwCvicIfazYSelmaIf4WIdg53JGybBXNuw2DmlacaJPaMLHs9V(cflWHLhZYxS00pQ9ZWsmHhXYT7hlRcKgwUDIfSNsSeGf4FpSWS8h6WSagHzPO1nUMLdYY25tZ1AwaxZxOybaJJGk4cZsCyOk2jqllw2PILeWf6azbFVwZcvGSSIyXYF7SaitgWooILgCy52jw0o(ybLgQ6ASHtYd3dlSbFawzKGpFAUwJ2VP85AQod(iT2Nm48TZqLRQjqfwDUMQZGpF0Wb0qLRQjqfQRwZGpFAUwBgQneE3v1KIEQRwZqb9hHPSEv(ygk1)chpGqbf0FeMmFL1RYhfQRwZenFkCaFxN9j41hYrln2hdcxViGbq0KCxN6Q1mrZNchW31zFcE9HC0sJ9XGW1lkELbiAswHJVX15iOfAIhqMCxhi8moOhDpckJT4tAg0tDuKzOu)lC8aIUopCpSmoOhDpckJT4tAg0tDuK5RCt)O2V(kcqOgeAPmbp)vWmuQ)foELsMtcPzjoXelBNp41GIybaFr3olrdmGzXlqwaxPrSelmaIfl7uXcYIfsS2kWcCy52jwaWLQBpXWI6Q1y5XS4QW1XYbzP5AnlWwJf4Wsc4cDGSe8iwIfgaXj5H7Hf2GpaRmsWNp41GIq73uwD1Agyr3ooh0Kpzep(HLzf11PUAndqFboeyMsJGwOjLQltfnO(ytMvuxN6Q1mbp)vWSIu0tD1AMXrqfCHZTHQyNWmuQ)fgyOcGMuh5aFGEDphFJRZrql0GuJBY9bCCb(Z1uDMISKtHWYqLRQjqfwnRIAWbfzWF1w68Ec8rZ7kuxTMzCeubx4CBOk2jmROUo1vRzcE(RGzOu)lmWqfanPoYb(a96Eo(gxNJGwObPg3K731PUAnZ4iOcUW52qvStKXF1w68Ec8rZ7MvuxNvQRwZmocQGlCUnuf7eMvKcRcqOgeAPmJJGk4cNBdvXoHzihmrxNvbicQ86miO62tm976C8nUohbTqt8aYKvqb9hHjZxzVsWjH0Sy9jblhKLuhiILBNyrLWhlWglBNpA4aYIAcwWNha6luS8hlRiwaURpaKoblFXIxjyb9c6pctSOUowaqln2hwECDS4QW1XYbzrLyjAGHabYj5H7Hf2GpaRmsWNp41GIq73u(CnvNbF(OHdOHkxvtGkSAwf1GdkYCFkzbovgCipv9lqAu0tD1Ag85JgoGMvuxNJVX15iOfAIhqMCFfQRwZGpF0Wb0GppaeWIRIEQRwZqb9hHPmgQ9XSI66uxTMHc6pctz9Q8XSI6RqD1AMO5tHd476SpbV(qoAPX(yq46fbmacOswrVaeQbHwktWZFfmdL6FHJxPK76ScHpVRQjtawiGarzqcNOckcqeu51zQh1(LBo1NtcPzb9W3N6hHzzhAHL0vyNLyHbqS4dXck)lcKLiAybtbybYj5H7Hf2GpaRmsq4Z7QAcTLNsk74iaenBuaTiC9IuMc6pctMVY6v5dWdiqQE4EyzWNpTFidHCkSokFFkbyROG(JWK5RSEv(a89aoa(CnvNbdx6mSLVDk3GdHpdvUQMab(42hP6H7HLXY43UHqofwhLVpLaCYgRbnivCeP15DhFeGt2GgG)CnvNP8BneoR6AVcKHkxvtGCsinlXXvAelBNp41GIy5lwCwauagtbw2GAFyb9c6pctOLfqyHUJfnDS8hlrdmWcaAPX(WsVB3pwEml7EbQjqwutWc93onSC7elBNpnxRzr)fXcCy52jwIfgafpGmzw0FrS0GdlBNp41GI6JwwaHf6owGiOXY8hXIxSaGVOBNLObgyXlqw00XYTtS4Qqeel6Viw29cutSSD(OHdiNKhUhwyd(aSYibF(GxdkcTFtzRMvrn4GIm3NswGtLbhYtv)cKgf9uxTMjA(u4a(Uo7tWRpKJwASpgeUEradGaQK76uxTMjA(u4a(Uo7tWRpKJwASpgeUEradGOjzfNRP6m4J0AFYGZ3odvUQMa7ROhf0FeMmFLXqTpkC8nUohbTqdGr4Z7QAY44iaenBua4vxTMHc6pctzmu7JzOu)lmGbHNPTMezylt6vrM7daHZdL6Fb8a0GM4bej31rb9hHjZxz9Q8rHJVX15iOfAamcFExvtghhbGOzJcaV6Q1muq)rykRxLpMHs9VWageEM2AsKHTmPxfzUpaeopuQ)fWdqdAIhqMCFfwPUAndSOBhNJOjqr3dlZksHvNRP6m4ZhnCanu5QAcurVaeQbHwktWZFfmdL6FHJhq11HHlT6xGMBFEToJjciAmu5QAcuH6Q1m3(8ADgteq0yWNhacyXnUaWEZQOgCqrg8xTLoVNaF08oWJM(kApQ9lpuQ)foELsozfTh1(Lhk1)cdmaMCY9v0laHAqOLYa0xGdbMXr)8h2muQ)foEavxNvbicQ86maLyEV6ZjH0SeNyIfaSqyHz5lwq)v5dlOxq)ryIfVazb7iiwqkJRBaooS0AwaWcHfln4WcYIfsS2kWIxGSGu6lWHazb9sJGwOjLQJtYd3dlSbFawzKuKLCkewO9Bk3tD1AgkO)imL1RYhZqP(x44jKtH1r57tPUUEHDFqryLbOIHc7(GIY3Nsadn976c7(GIWkh3(k8OCyNcaPaHpVRQjd2rq5gCYbp)vGtYd3dlSbFawzKS76wofcl0(nL7PUAndf0FeMY6v5JzOu)lC8eYPW6O89PKcRcqeu51zakX8E111tD1AgG(cCiWmLgbTqtkvxMkAq9XMmRifbicQ86maLyEV6311lS7dkcRmavmuy3huu((ucyOPFxxy3huew5421PUAntWZFfmRO(k8OCyNcaPaHpVRQjd2rq5gCYbp)vqrp1vRzghbvWfo3gQIDcZqP(xyG1dnaqac8ZQOgCqrg8xTLoVNaF08EFfQRwZmocQGlCUnuf7eMvuxNvQRwZmocQGlCUnuf7eMvuFojpCpSWg8byLrsBP15uiSq73uUN6Q1muq)rykRxLpMHs9VWXtiNcRJY3NskSkarqLxNbOeZ7vxxp1vRza6lWHaZuAe0cnPuDzQOb1hBYSIueGiOYRZauI59QFxxVWUpOiSYauXqHDFqr57tjGHM(DDHDFqryLJBxN6Q1mbp)vWSI6RWJYHDkaKce(8UQMmyhbLBWjh88xbf9uxTMzCeubx4CBOk2jmdL6FHbgAuOUAnZ4iOcUW52qvStywrkSAwf1GdkYG)QT059e4JM376SsD1AMXrqfCHZTHQyNWSI6ZjH0SeNyIfKci6XcSyjaYj5H7Hf2GpaRmsS4Z8WjdBzsVkItcPzjoXelBNpTFiwoilrdmWYgu7dlOxq)rycTSGSyHeRTcSS7yw0egZY9Pel3UxS4SGum(TZcHCkSoIfn1owGdlWsNGf0Fv(Wc6f0FeMy5XSSI4K8W9WcBWhGvgj4ZN2peA)MYuq)ryY8vwVkF66OG(JWKbd1(Klc5xxhf0FeMmELixeYVUUEQRwZyXN5Htg2YKEvKzf11HJiToV74JawYgRbnkSkarqLxNbbv3EIPRdhrADE3XhbSKnwJIaebvEDgeuD7jM(kuxTMHc6pctz9Q8XSI666PUAntWZFfmdL6FHbMhUhwglJF7gc5uyDu((usH6Q1mbp)vWSI6ZjH0SeNyIfKIXVDwG3onwEmXIL9pSZYJz5lw2GAFyb9c6pctOLfKflKyTvGf4WYbzjAGbwq)v5dlOxq)ryItYd3dlSbFawzKyz8BNtcPzjo4A9TplojpCpSWg8byLrYSQShUhwz9Jp0wEkPCZ16BFw2B4ikyhtLsgG2N9zBda]] )

end