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


    spec:RegisterPack( "Balance", 20210706, [[defYzfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlai7Is)cIyysOogjYYaqptc00OOIRbPyBae9nasghaHZbOI1bqQ5bOCpsu7tc6FqurPdkuyHcL6HqKMOeGUiKQAJsa8riQOAKqurXjPOsRuc5LqurMjKQCtaO0ofk5Naqvdfa0sbGINQuMkfvDvjG2kauPVcrfglaWEPWFL0GjomvlMKESGjd0Lr2Su(mKmALQtRYQbGkEnGmBsDBjA3I(nOHlKJdOslxXZHA6Q66kz7q47uKXdr58cvRxOO5lv2pQnuYW8gBG(tgXcGfdqLkgqvmG0QKsaeGMJsgBF8iYylYda5OiJT0ljJTy7ApdKXwKhxdDqdZBSHHRjqgB7)hHb0ibjQU2ZabGWxzWI6(9LQ9Gij2U2ZabG2UsKIKsq7(xQroB70KYQU2ZazFK9gBQRt)MBAOASb6pzelawmavQyavXasRskbqawqZXyZx)oCm22UsKASTFGGuAOASbs4GXwSDTNbILc4SoqUOIw64SairllaSyaQexexes39efHb0CraiwIbiibYYgu7dlXM8slxeaIfKU7jkcKL3hu0xVglbhtywEilH4bnvFFqrp2YfbGybadvcrqGSSYKceg7tCwq4Z5QAcZsVZsw0Ys0qiQ43h8AqrSaGkKLOHqyXVp41GI6B5IaqSedeWdKLOHco(VeflihJ)7SCnwUhDyw(DIftdmrXc6h0xeMSCraiwaW6arSGuyIaceXYVtSSfDZ9ywCw03)AILs4qS00eYovnXsVRXsC4ILDhmr3ZY(9SCpl4RCPFpj4cRJZIP73zj2a4JH5zbWSGust4)CnlXqFOYskF0YY9OdKfmqxuFlxeaIfaSoqelLq8Zc6AhQ9VouPFjgDSGdu6ZbXS4rr64S8qwuHymlTd1(JzbM64wUiUOyKj89Nazj2U2ZaXsmaGOhlbpzrLyPbxjil(ZY()ryansqIQR9mqai8vgSOUFFPApisITR9mqaOTRePiPe0U)LAKZ2onPSQR9mq2hzVXM(Wp2W8gBGuZx63W8gXsjdZBS5H)GPXggQ9PQsEPXgLUQManITXBelaAyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXgoI0667dk6Xw87tZ1AwkKfLyrbl9yXmwExt5BXVpA4aAP0v1eilDDS8UMY3IFsR9Pcox7Tu6QAcKL(S01XcoI0667dk6Xw87tZ1AwkKfaASbs4WCr)btJTn6XSedi6ZcmzPGaMft3VdxplGZ1Ew8eKft3VZY27JgoGS4jilaeWSa)DAmDyYydHp10ljJTdxDiz8gXQGgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSHJiTU((GIESf)(0UHyPqwuYydKWH5I(dMgBB0JzjOjhbXIPDkzz79PDdXsWtw2VNfacywEFqrpMft7xyNLdZYqAcHNpln4WYVtSG(b9fHjwEilQelrd1Oziqw8eKft7xyNL2P10WYdzj443ydHp10ljJTdxdAYrqgVrSmhdZBSrPRQjqJyBS5H)GPXMknyAa6sugBGeomx0FW0yRaXelXMgmnaDjkwmD)olingiXCZalWHfV90WcsHjciqelxYcsJbsm3mySfM7P5CJTESyglbick98T5HA)RnNyPRJfZyjaHAqOP0gGjciqu93Pko6M7X2vel9zrblQRwZg86Lb7qL(LywkKfLqdlkyrD1A2XrqjCHRTHYyg3ouPFjMfGXI5WIcwmJLaebLE(weu(7Xhw66yjarqPNVfbL)E8HffSOUAnBWRxgSRiwuWI6Q1SJJGs4cxBdLXmUDfXIcw6XI6Q1SJJGs4cxBdLXmUDOs)smlaJfLuIfaelOHfGNLzLudoOil(Y2sx3JJFAo3sPRQjqw66yrD1A2GxVmyhQ0VeZcWyrjLyPRJfLybjSGJiTUU74NybySOKfnOHL(gVrSqJH5n2O0v1eOrSn2cZ90CUXM6Q1SbVEzWouPFjMLczrj0WIcw6XIzSmRKAWbfzXx2w66EC8tZ5wkDvnbYsxhlQRwZoockHlCTnugZ42Hk9lXSamwucqXIcwuxTMDCeucx4ABOmMXTRiw6ZsxhlQqmMffS0ou7FDOs)smlaJfaIgJnqchMl6pyASbaHplMUFNfNfKgdKyUzGLF3FwoCIUNfNfa4sJ9HLObgyboSyANsw(DIL2HA)z5WS4QW1ZYdzHsqJnp8hmn2IG)btJ3iwasdZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im2c0PzPhl9yPDO2)6qL(LywaqSOeAybaXsac1GqtPn41ld2Hk9lXS0NfKWIsaIIzPplkZsGonl9yPhlTd1(xhQ0VeZcaIfLqdlaiwucGfZcaILaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZsFwqclkbikML(SOGfZyz8dSsiO8Toii2si7WpMLUowcqOgeAkTbVEzWouPFjMLcz5YNMiO2FcS2ou7FDOs)smlDDSeGqni0uAdWebeiQ(7ufhDZ9y7qL(LywkKLlFAIGA)jWA7qT)1Hk9lXSaGyrPIzPRJfZyjarqPNVnpu7FT5elDDS4H)GPnateqGO6VtvC0n3JTGh2v1eOXgiHdZf9hmn2qQRdlT)eMft70Vtdll8LOybPWebeiILeAIftNwZIR1qtSehUy5HSG)tRzj44NLFNyb7LelEjCLplWglifMiGaragPXajMBgyj44hBSHWNA6LKXwaMiGarvqchpdgVrSaugM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzS1JL3hu0B)RKQpScEelfYIsOHLUowg)aReckFRdcITxYsHSGMIzPplkyPhl9yPhleWDDrreOLkJIpKRRWbm9mqSOGLES0JLaeQbHMslvgfFixxHdy6zGSdv6xIzbySOeGSyw66yjarqPNVfbL)E8HffSeGqni0uAPYO4d56kCatpdKDOs)smlaJfLaKakwaml9yrjLyb4zzwj1GdkYIVST01944NMZTu6QAcKL(S0NffSyglbiudcnLwQmk(qUUchW0ZazhYbJZsFw6Zsxhl9yHaURlkIaTy4sRP)VevDwQXzrbl9yXmwcqeu65BZd1(xBoXsxhlbiudcnLwmCP10)xIQol141cAoObquSs2Hk9lXSamwusjZHL(S0NLUow6XIzSqa31ffrG2lXHz9UQMQa3LN)QScsiUaXsxhlbiudcnL2lXHz9UQMQa3LN)QScsiUazhYbJZsFwuWspwcqOgeAkTQ0GPbOlrzhYbJZsxhlMXY4bY(duRzPplkyPhl9ybHpNRQjlmRlmv)5sGONfLzrjw66ybHpNRQjlmRlmv)5sGONfLzPGS0NffS0JLFUei6TVs2HCW41aeQbHMsw66y5NlbIE7RKnaHAqOP0ouPFjMLcz5YNMiO2FcS2ou7FDOs)smlaiwuQyw6Zsxhli85CvnzHzDHP6pxce9SOmlaKffS0JLFUei6TpaTd5GXRbiudcnLS01XYpxce92hG2aeQbHMs7qL(LywkKLlFAIGA)jWA7qT)1Hk9lXSaGyrPIzPplDDSGWNZv1KfM1fMQ)Cjq0ZIYSuml9zPplDDSeGiO0Z3cu858KL(gBGeomx0FW0yRaXeilpKfqs7Xz53jwwyhfXcSXcsJbsm3mWIPDkzzHVeflGWLQMybMSSWelEcYs0qiO8zzHDuelM2PKfpzXbbzHqq5ZYHzXvHRNLhYc4rgBi8PMEjzSfaRbycE)btJ3iwacdZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im2mJfmCPvVe0(7ZP1vmrarJLsxvtGS01Xs7qT)1Hk9lXSuilaS4IzPRJfvigZIcwAhQ9VouPFjMfGXcardlaMLESyofZcaIf1vRz)9506kMiGOXIFpaelaplaKL(S01XI6Q1S)(CADfteq0yXVhaILczPGacwaqS0JLzLudoOil(Y2sx3JJFAo3sPRQjqwaEwqdl9n2q4tn9sYy73NtRRyIaIMQj)EJ3iwahdZBSrPRQjqJyBSbs4WCr)btJTcetSG(LrXhY1SaGFatpdelaSymfWSOsn4qS4SG0yGeZndSSWK1yl9sYyJkJIpKRRWbm9mqgBH5EAo3ylaHAqOP0g86Lb7qL(LywaglaSywuWsac1GqtPnateqGO6VtvC0n3JTdv6xIzbySaWIzrbl9ybHpNRQj7VpNwxXebenvt(9S01XI6Q1S)(CADfteq0yXVhaILczPGfZcGzPhlZkPgCqrw8LTLUUhh)0CULsxvtGSa8SaizPpl9zPRJfvigZIcwAhQ9VouPFjMfGXsbbugBE4pyASrLrXhY1v4aMEgiJ3iwkvSH5n2O0v1eOrSn2ajCyUO)GPXwbIjw2GlTM(lrXcaMLACwaKykGzrLAWHyXzbPXajMBgyzHjRXw6LKXggU0A6)lrvNLACJTWCpnNBSfGqni0uAdE9YGDOs)smlaJfajlkyXmwcqeu65Brq5VhFyrblMXsaIGspFBEO2)AZjw66yjarqPNVnpu7FT5elkyjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSamwaKSOGLESGWNZv1KnateqGOkiHJNbw66yjaHAqOP0g86Lb7qL(Lywaglasw6Zsxhlbick98TiO83JpSOGLESyglZkPgCqrw8LTLUUhh)0CULsxvtGSOGLaeQbHMsBWRxgSdv6xIzbySaizPRJf1vRzhhbLWfU2gkJzC7qL(LywaglkzoSayw6XcAyb4zHaURlkIaTxI)zfE4GRGhIlPQkP1S0NffSOUAn74iOeUW12qzmJBxrS0NLUowuHymlkyPDO2)6qL(LywaglaengBE4pyASHHlTM()su1zPg34nILskzyEJnkDvnbAeBJnp8hmn2UehM17QAQcCxE(RYkiH4cKXwyUNMZn2uxTMn41ld2Hk9lXSuilkHgwuWspwmJLzLudoOil(Y2sx3JJFAo3sPRQjqw66yrD1A2XrqjCHRTHYyg3ouPFjMfGXIsaKfaZspwkilaplQRwZQQHqq9c)2vel9zbWS0JLESaOybaXcAyb4zrD1AwvnecQx43UIyPplapleWDDrreO9s8pRWdhCf8qCjvvjTML(SOGf1vRzhhbLWfU2gkJzC7kIL(S01XIkeJzrblTd1(xhQ0VeZcWybGOXyl9sYy7sCywVRQPkWD55VkRGeIlqgVrSucGgM3yJsxvtGgX2ydKWH5I(dMgBMF)WSCywCwg)3PHfs7QWXFIftECwEilLoqelUwZcmzzHjwWV)S8ZLarpMLhYIkXI(scKLvelMUFNfKgdKyUzGfpbzbPWebeiIfpbzzHjw(DIfaMGSG1WNfyYsaKLRXIk83z5NlbIEml(qSatwwyIf87pl)Cjq0Jn2cZ90CUXgcFoxvtwywxyQ(ZLarplkZcazrblMXYpxce92hG2HCW41aeQbHMsw66yPhli85CvnzHzDHP6pxce9SOmlkXsxhli85CvnzHzDHP6pxce9SOmlfKL(SOGLESOUAnBWRxgSRiwuWspwmJLaebLE(weu(7Xhw66yrD1A2XrqjCHRTHYyg3ouPFjMfaZspwqdlaplZkPgCqrw8LTLUUhh)0CULsxvtGS0NfGPml)Cjq0BFLSQRwRcUg)pyYIcwuxTMDCeucx4ABOmMXTRiw66yrD1A2XrqjCHRTHYygVIVST01944NMZTRiw6ZsxhlbiudcnL2GxVmyhQ0VeZcGzbGSuil)Cjq0BFLSbiudcnLwW14)btwuWspwmJLaebLE(28qT)1MtS01XIzSGWNZv1KnateqGOkiHJNbw6ZIcwmJLaebLE(wGIpNNS01XsaIGspFBEO2)AZjwuWccFoxvt2amrabIQGeoEgyrblbiudcnL2amrabIQ)ovXr3Cp2UIyrblMXsac1GqtPn41ld2velkyPhl9yrD1AwkOVimv1R0h7qL(LywkKfLkMLUowuxTMLc6lctvmu7JDOs)smlfYIsfZsFwuWIzSmRKAWbfzvDTNbQcBvxRR)(LOWwkDvnbYsxhl9yrD1Awvx7zGQWw1166VFjkCn9FnKf)EaiwuMf0WsxhlQRwZQ6Apduf2QUwx)9lrHR(e8KS43daXIYSaiyPpl9zPRJf1vRzb6sWHaRuze0enLu(vkPb1ftYUIyPplDDSOcXywuWs7qT)1Hk9lXSamwayXS01XccFoxvtwywxyQ(ZLarplkZsXgByn8XgB)Cjq0RKXMh(dMgBlmvVNkXgVrSuQGgM3yJsxvtGgX2yZd)btJTfMQ3tLyJTWCpnNBSHWNZv1KfM1fMQ)Cjq0ZIzkZcazrblMXYpxce92xj7qoy8Aac1GqtjlDDSGWNZv1KfM1fMQ)Cjq0ZIYSaqwuWspwuxTMn41ld2velkyPhlMXsaIGspFlck)94dlDDSOUAn74iOeUW12qzmJBhQ0VeZcGzPhlOHfGNLzLudoOil(Y2sx3JJFAo3sPRQjqw6ZcWuMLFUei6TpaTQRwRcUg)pyYIcwuxTMDCeucx4ABOmMXTRiw66yrD1A2XrqjCHRTHYygVIVST01944NMZTRiw6ZsxhlbiudcnL2GxVmyhQ0VeZcGzbGSuil)Cjq0BFaAdqOgeAkTGRX)dMSOGLESyglbick98T5HA)RnNyPRJfZybHpNRQjBaMiGarvqchpdS0NffSyglbick98TafFopzrbl9yXmwuxTMn41ld2velDDSyglbick98TiO83JpS0NLUowcqeu65BZd1(xBoXIcwq4Z5QAYgGjciqufKWXZalkyjaHAqOP0gGjciqu93Pko6M7X2velkyXmwcqOgeAkTbVEzWUIyrbl9yPhlQRwZsb9fHPQEL(yhQ0VeZsHSOuXS01XI6Q1SuqFryQIHAFSdv6xIzPqwuQyw6ZIcwmJLzLudoOiRQR9mqvyR6AD93Vef2sPRQjqw66yPhlQRwZQ6Apduf2QUwx)9lrHRP)RHS43daXIYSGgw66yrD1Awvx7zGQWw1166VFjkC1NGNKf)EaiwuMfabl9zPpl9zPRJf1vRzb6sWHaRuze0enLu(vkPb1ftYUIyPRJfvigZIcwAhQ9VouPFjMfGXcalMLUowq4Z5QAYcZ6ct1FUei6zrzwk2ydRHp2y7NlbIEaA8gXsjZXW8gBu6QAc0i2gBGeomx0FW0yRaXeMfxRzb(70WcmzzHjwUNkXSatwcGgBE4pyASTWu9EQeB8gXsj0yyEJnkDvnbAeBJnqchMl6pyASvaPWbsS4H)Gjl6d)SO6ycKfyYc((L)hmrIMqDyJnp8hmn2Mvw9WFWSQp8BSH)5cVrSuYylm3tZ5gBi85CvnzpC1HKXM(WFn9sYyZHKXBelLaKgM3yJsxvtGgX2ylm3tZ5gBZkPgCqrwvx7zGQWw1166VFjkSLaURlkIan2W)CH3iwkzS5H)GPX2SYQh(dMv9HFJn9H)A6LKXMk0FJ3iwkbOmmVXgLUQManITXMh(dMgBZkRE4pyw1h(n20h(RPxsgB434nEJnvO)gM3iwkzyEJnkDvnbAeBJnp8hmn2ghbLWfU2gkJzCJnqchMl6pyASvagkJzCwmD)olingiXCZGXwyUNMZn2uxTMn41ld2Hk9lXSuilkHgJ3iwa0W8gBu6QAc0i2gBE4pyAS5GE0FiOk2KpLgBH4bnvFFqrp2iwkzSfM7P5CJn1vRzvDTNbQcBvxRR)(LOW10)1qw87bGybySaiyrblQRwZQ6Apduf2QUwx)9lrHR(e8KS43daXcWybqWIcw6XIzSacFRd6r)HGQyt(uwb9shfz)la0LOyrblMXIh(dMwh0J(dbvXM8PSc6LokYEzTPpu7plkyPhlMXci8ToOh9hcQIn5tzDNCT9VaqxIILUowaHV1b9O)qqvSjFkR7KRTdv6xIzPqwkil9zPRJfq4BDqp6peufBYNYkOx6Oil(9aqSamwkilkybe(wh0J(dbvXM8PSc6LokYouPFjMfGXcAyrblGW36GE0FiOk2KpLvqV0rr2)caDjkw6BSbs4WCr)btJTcetSedqp6peelBM8PKft7uYI)SOjmMLF3twmhwInmgMNf87bGWS4jilpKLHAdH3zXzbykdqwWVhaIfhZI2FIfhZseeJpvnXcCy5VsIL7zbdz5Ew8zoeeMfaCw4NfV90WIZsbbml43daXcHSOBiSXBeRcAyEJnkDvnbAeBJnp8hmn2cWebeiQ(7ufhDZ9yJnqchMl6pyASvGyIfKcteqGiwmD)olingiXCZalM2PKLiigFQAIfpbzb(70y6WelMUFNfNLydJH5zrD1ASyANswajC8mCjkJTWCpnNBSzglGZ6aTjSgaXSOGLES0Jfe(CUQMSbyIacevbjC8mWIcwmJLaeQbHMsBWRxgSd5GXzPRJf1vRzdE9YGDfXsFwuWspwuxTMv11EgOkSvDTU(7xIcxt)xdzXVhaIfLzbqWsxhlQRwZQ6Apduf2QUwx)9lrHR(e8KS43daXIYSaiyPplDDSOcXywuWs7qT)1Hk9lXSamwuQyw6B8gXYCmmVXgLUQManITXMh(dMgBT1eVcBvsVsYydKWH5I(dMgBfai6ZIJz53jwA3GFwqfaz5sw(DIfNLydJH5zX0LGqtSahwmD)ol)oXcYP4Z5jlQRwJf4WIP73zXzbqaymfyjgGE0Fiiw2m5tjlEcYIj)EwAWHfKgdKyUzGLRXY9SycMplQelRiwCu(LSOsn4qS87elbqwomlTlp8obASfM7P5CJTES0JLESOUAnRQR9mqvyR6AD93VefUM(VgYIFpaelfYcGKLUowuxTMv11EgOkSvDTU(7xIcx9j4jzXVhaILczbqYsFwuWspwmJLaebLE(weu(7Xhw66yXmwuxTMDCeucx4ABOmMXTRiw6ZsFwuWspwaN1bAtynaIzPRJLaeQbHMsBWRxgSdv6xIzPqwqtXS01Xspwcqeu65BZd1(xBoXIcwcqOgeAkTbyIacev)DQIJU5ESDOs)smlfYcAkML(S0NL(S01XspwaHV1b9O)qqvSjFkRGEPJISdv6xIzPqwaeSOGLaeQbHMsBWRxgSdv6xIzPqwuQywuWsaIGspFBsHbQHdil9zPRJfvigZIcwU8PjcQ9NaRTd1(xhQ0VeZcWybqWIcwmJLaeQbHMsBWRxgSd5GXzPRJLaebLE(wGIpNNSOGf1vRzb6sWHaRuze0enLu(2velDDSeGiO0Z3IGYFp(WIcwuxTMDCeucx4ABOmMXTdv6xIzbySaCyrblQRwZoockHlCTnugZ42vKXBel0yyEJnkDvnbAeBJnp8hmn2cEgiDvD1AgBH5EAo3yRhlQRwZQ6Apduf2QUwx)9lrHRP)RHSdv6xIzPqwauw0WsxhlQRwZQ6Apduf2QUwx)9lrHR(e8KSdv6xIzPqwauw0WsFwuWspwcqOgeAkTbVEzWouPFjMLczbqXsxhl9yjaHAqOP0sLrqt0uvHjODOs)smlfYcGIffSyglQRwZc0LGdbwPYiOjAkP8RusdQlMKDfXIcwcqeu65Bbk(CEYsFw6ZIcwC8pUUgbnrdlfQmlfSyJn1vRvtVKm2WVpA4aASbs4WCr)btJnK6zG0SS9(OHdilMUFNfNLKmXsSHXW8SOUAnw8eKfKgdKyUzGLdNO7zXvHRNLhYIkXYctGgVrSaKgM3yJsxvtGgX2yZd)btJn87dEnOiJnqchMl6pyASvaxLrSS9(GxdkcZIP73zXzj2WyyEwuxTglQRNLe(SyANswIGq9LOyPbhwqAmqI5MbwGdliNUeCiqw2IU5ESXwyUNMZn26XI6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqSuilaKLUowuxTMv11EgOkSvDTU(7xIcx9j4jzXVhaILczbGS0NffS0JLaebLE(28qT)1MtS01Xsac1GqtPn41ld2Hk9lXSuilakw66yXmwq4Z5QAYgaRbycE)btwuWIzSeGiO0Z3cu858KLUow6Xsac1GqtPLkJGMOPQctq7qL(LywkKfaflkyXmwuxTMfOlbhcSsLrqt0us5xPKguxmj7kIffSeGiO0Z3cu858KL(S0NffS0JfZybe(22AIxHTkPxjz)la0LOyPRJfZyjaHAqOP0g86Lb7qoyCw66yXmwcqOgeAkTbyIacev)DQIJU5ESDihmol9nEJybOmmVXgLUQManITXMh(dMgB43h8AqrgBGeomx0FW0yRaUkJyz79bVgueMfvQbhIfKcteqGiJTWCpnNBS1JLaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZcWybnSOGfZybCwhOnH1aiMffS0Jfe(CUQMSbyIacevbjC8mWsxhlbiudcnL2GxVmyhQ0VeZcWybnS0NffSGWNZv1KnawdWe8(dMS0NffSyglGW32wt8kSvj9kj7FbGUeflkyjarqPNVnpu7FT5elkyXmwaN1bAtynaIzrbluqFryYEz1Z4SOGfh)JRRrqt0WsHSyofB8gXcqyyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXwpwuxTMDCeucx4ABOmMXTdv6xIzPqwqdlDDSyglQRwZoockHlCTnugZ42vel9zrbl9yrD1AwGUeCiWkvgbnrtjLFLsAqDXKSdv6xIzbySGkaAlDKXsFwuWspwuxTMLc6lctvmu7JDOs)smlfYcQaOT0rglDDSOUAnlf0xeMQ6v6JDOs)smlfYcQaOT0rgl9n2ajCyUO)GPXwbeMO7zbe(SaUMlrXYVtSqjilWglayCeucxywkadLXmoAzbCnxIIfGUeCiqwOYiOjAkP8zboSCjl)oXI2XplOcGSaBS4jlOFqFryYydHp10ljJnq4xhc4UUHkP8XgVrSaogM3yJsxvtGgX2yZd)btJn8kB3qgBH5EAo3yBO2q4DxvtSOGL3hu0B)RKQpScEelfYIsaswuWIhvd7uaiwuWccFoxvtwq4xhc4UUHkP8XgBH4bnvFFqrp2iwkz8gXsPInmVXgLUQManITXMh(dMgBLqy2UHm2cZ90CUX2qTHW7UQMyrblVpOO3(xjvFyf8iwkKfLkOfnSOGfpQg2PaqSOGfe(CUQMSGWVoeWDDdvs5Jn2cXdAQ((GIESrSuY4nILskzyEJnkDvnbAeBJnp8hmn2WpP1(uBAFiJTWCpnNBSnuBi8URQjwuWY7dk6T)vs1hwbpILczrjajlaMLHk9lXSOGfpQg2PaqSOGfe(CUQMSGWVoeWDDdvs5Jn2cXdAQ((GIESrSuY4nILsa0W8gBu6QAc0i2gBE4pyAS1GtGQWwn9FnKXgiHdZf9hmn2kaWyXcmzjaYIP73HRNLGhfDjkJTWCpnNBS5r1WofaY4nILsf0W8gBu6QAc0i2gBE4pyASrLrqt0uvHjOXgiHdZf9hmn2q)YiOjAyj2WeKft7uYIRcxplpKfkFAyXzjjtSeBymmplMUeeAIfpbzb7iiwAWHfKgdKyUzWylm3tZ5gB9yHc6lctw9k9PMeYEw66yHc6lctwmu7tnjK9S01Xcf0xeMSEgVMeYEw66yrD1Awvx7zGQWw1166VFjkCn9FnKDOs)smlfYcGYIgw66yrD1Awvx7zGQWw1166VFjkC1NGNKDOs)smlfYcGYIgw66yXX)46Ae0enSuilaNIzrblbiudcnL2GxVmyhYbJZIcwmJfWzDG2ewdGyw6ZIcw6Xsac1GqtPn41ld2Hk9lXSuilfSyw66yjaHAqOP0g86Lb7qoyCw6ZsxhlQqmMffSC5tteu7pbwBhQ9VouPFjMfGXIsfB8gXsjZXW8gBu6QAc0i2gBE4pyAS1wt8kSvj9kjJnqchMl6pyASvaGOplZHA)zrLAWHyzHVeflinggBH5EAo3ylaHAqOP0g86Lb7qoyCwuWccFoxvt2aynatW7pyYIcw6XIJ)X11iOjAyPqwaofZIcwmJLaebLE(28qT)1MtS01XsaIGspFBEO2)AZjwuWIJ)X11iOjAybySyofZsFwuWIzSeGiO0Z3IGYFp(WIcw6XIzSeGiO0Z3MhQ9V2CILUowcqOgeAkTbyIacev)DQIJU5ESDihmol9zrblMXc4SoqBcRbqSXBelLqJH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgBMXc4SoqBcRbqmlkybHpNRQjBaSgGj49hmzrbl9yPhlo(hxxJGMOHLczb4umlkyPhlQRwZc0LGdbwPYiOjAkP8RusdQlMKDfXsxhlMXsaIGspFlqXNZtw6ZsxhlQRwZQQHqq9c)2velkyrD1AwvnecQx43ouPFjMfGXI6Q1SbVEzWcUg)pyYsFw66y5YNMiO2FcS2ou7FDOs)smlaJf1vRzdE9YGfCn(FWKLUowcqeu65BZd1(xBoXsFwuWspwmJLaebLE(28qT)1MtS01XspwC8pUUgbnrdlaJfZPyw66ybe(22AIxHTkPxjz)la0LOyPplkyPhli85CvnzdWebeiQcs44zGLUowcqOgeAkTbyIacev)DQIJU5ESDihmol9zPVXgiHdZf9hmn2qAmqI5MbwmTtjl(ZcWPyaZsmWaqw6bhn0enS87EYI5umlXadazX097SGuyIace1Nft3VdxplAi(suS8xjXYLSeBnecQx4NfpbzrFjXYkIft3VZcsHjciqelxJL7zXKJzbKWXZabASHWNA6LKXwaSgGj49hmRQq)nEJyPeG0W8gBu6QAc0i2gBH5EAo3ydHpNRQjBaSgGj49hmRQq)n28WFW0ylqAc)NRRU(qLLu(gVrSucqzyEJnkDvnbAeBJTWCpnNBSHWNZv1KnawdWe8(dMvvO)gBE4pyASDzWN0)dMgVrSucqyyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXgf0xeMSxw1R0hwaEwaeSGew8WFW0IFFA3qwczuy9u9VsIfaZIzSqb9fHj7Lv9k9HfGNLESaizbWS8UMY3IHlDf2Q)ovBWHWVLsxvtGSa8Suqw6ZcsyXd)btRPX)DlHmkSEQ(xjXcGzPylazbjSGJiTUU74Nm2ajCyUO)GPXg6J)R0FcZYo0elLRWolXadazXhIfu(Leilr0WcMcWe0ydHp10ljJnhhbaPzJcgVrSuc4yyEJnkDvnbAeBJnp8hmn2WVp41GIm2ajCyUO)GPXwbCvgXY27dEnOimlM2PKLFNyPDO2FwomlUkC9S8qwOeeTS0gkJzCwomlUkC9S8qwOeeTSehUyXhIf)zb4umGzjgyailxYINSG(b9fHj0YcsJbsm3mWI2XpMfpH)onSaiamMcywGdlXHlwmbxAqwGiOj4rSuchILF3tw4oLkMLyGbGSyANswIdxSycU0Gj6Ew2EFWRbfXscnzSfM7P5CJTESOcXywuWYLpnrqT)eyTDO2)6qL(LywaglMdlDDS0Jf1vRzhhbLWfU2gkJzC7qL(LywaglOcG2shzSa8SeOtZspwC8pUUgbnrdliHLcwml9zrblQRwZoockHlCTnugZ42vel9zPplDDS0Jfh)JRRrqt0WcGzbHpNRQjRJJaG0SrbwaEwuxTMLc6lctvmu7JDOs)smlaMfq4BBRjEf2QKELK9Vaq46qL(LSa8SaqlAyPqwusPIzPRJfh)JRRrqt0WcGzbHpNRQjRJJaG0SrbwaEwuxTMLc6lctv9k9XouPFjMfaZci8TT1eVcBvsVsY(xaiCDOs)swaEwaOfnSuilkPuXS0NffSqb9fHj7LvpJZIcw6XIzSOUAnBWRxgSRiw66yXmwExt5BXVpA4aAP0v1eil9zrbl9yPhlMXsac1GqtPn41ld2velDDSeGiO0Z3cu858KffSyglbiudcnLwQmcAIMQkmbTRiw6Zsxhlbick98T5HA)RnNyPplkyPhlMXsaIGspFlck)94dlDDSyglQRwZg86Lb7kILUowC8pUUgbnrdlfYcWPyw6Zsxhl9y5DnLVf)(OHdOLsxvtGSOGf1vRzdE9YGDfXIcw6XI6Q1S43hnCaT43daXcWyPGS01XIJ)X11iOjAyPqwaofZsFw6ZsxhlQRwZg86Lb7kIffSyglQRwZoockHlCTnugZ42velkyXmwExt5BXVpA4aAP0v1eOXBelawSH5n2O0v1eOrSn28WFW0yljt1simn2ajCyUO)GPXwbIjwaWcHjMLlzb9wPpSG(b9fHjw8eKfSJGyb5mUUb4cWsRzbaleMS0GdlingiXCZGXwyUNMZn26XI6Q1SuqFryQQxPp2Hk9lXSuileYOW6P6FLelDDS0JLWUpOimlkZcazrbldf29bfv)RKybySGgw6ZsxhlHDFqrywuMLcYsFwuWIhvd7uaiJ3iwaujdZBSrPRQjqJyBSfM7P5CJTESOUAnlf0xeMQ6v6JDOs)smlfYcHmkSEQ(xjXIcw6Xsac1GqtPn41ld2Hk9lXSuilOPyw66yjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSuilOPyw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr1)kjwaglOHL(S01Xsy3hueMfLzPGS0NffS4r1WofaYyZd)btJTDx3QLqyA8gXcGa0W8gBu6QAc0i2gBH5EAo3yRhlQRwZsb9fHPQEL(yhQ0VeZsHSqiJcRNQ)vsSOGLESeGqni0uAdE9YGDOs)smlfYcAkMLUowcqOgeAkTbyIacev)DQIJU5ESDOs)smlfYcAkML(S01Xspwc7(GIWSOmlaKffSmuy3huu9VsIfGXcAyPplDDSe29bfHzrzwkil9zrblEunStbGm28WFW0yRT06AjeMgVrSaybnmVXgLUQManITXgiHdZf9hmn2qoGOplWKLaOXMh(dMgBM8zo4uHTkPxjz8gXcGMJH5n2O0v1eOrSn28WFW0yd)(0UHm2ajCyUO)GPXwbIjw2EFA3qS8qwIgyGLnO2hwq)G(IWelWHft7uYYLSatDCwqVv6dlOFqFryIfpbzzHjwqoGOplrdmGz5ASCjlO3k9Hf0pOVimzSfM7P5CJnkOVimzVSQxPpS01Xcf0xeMSyO2NAsi7zPRJfkOVimz9mEnjK9S01XI6Q1SM8zo4uHTkPxjzxrSOGf1vRzPG(IWuvVsFSRiw66yPhlQRwZg86Lb7qL(LywaglE4pyAnn(VBjKrH1t1)kjwuWI6Q1SbVEzWUIyPVXBelaIgdZBS5H)GPXMPX)DJnkDvnbAeBJ3iwaeqAyEJnkDvnbAeBJnp8hmn2Mvw9WFWSQp8BSPp8xtVKm2AUw)7ZY4nEJnhsgM3iwkzyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXwpwuxTM9VsYeCYk4qEP6LG0yhQ0VeZcWybva0w6iJfaZsXwLyPRJf1vRz)RKmbNScoKxQEjin2Hk9lXSamw8WFW0IFFA3qwczuy9u9VsIfaZsXwLyrbl9yHc6lct2lR6v6dlDDSqb9fHjlgQ9PMeYEw66yHc6lctwpJxtczpl9zPplkyrD1A2)kjtWjRGd5LQxcsJDfXIcwMvsn4GIS)vsMGtwbhYlvVeKglLUQMan2ajCyUO)GPXgsDDyP9NWSyAN(DAy53jwkGd5Lb)d70WI6Q1yX0P1S0CTMfyRXIP73VKLFNyjjK9SeC8BSHWNA6LKXg4qEz10P11MR1vyRz8gXcGgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSzgluqFryYEzfd1(WIcw6XcoI0667dk6Xw87t7gILczbnSOGL31u(wmCPRWw93PAdoe(Tu6QAcKLUowWrKwxFFqrp2IFFA3qSuilakw6BSbs4WCr)btJnK66Ws7pHzX0o970WY27dEnOiwomlMGZVZsWX)LOybIGgw2EFA3qSCjlO3k9Hf0pOVimzSHWNA6LKX2HkHdvXVp41GImEJyvqdZBSrPRQjqJyBS5H)GPXwaMiGar1FNQ4OBUhBSbs4WCr)btJTcetSGuyIaceXIPDkzXFw0egZYV7jlOPywIbgaYINGSOVKyzfXIP73zbPXajMBgm2cZ90CUXMzSaoRd0MWAaeZIcw6Xspwq4Z5QAYgGjciqufKWXZalkyXmwcqOgeAkTbVEzWoKdgNLUowuxTMn41ld2vel9zrbl9yrD1AwkOVimv1R0h7qL(LywkKfajlDDSOUAnlf0xeMQyO2h7qL(LywkKfajl9zrbl9yXmwMvsn4GISQU2ZavHTQR11F)suylLUQMazPRJf1vRzvDTNbQcBvxRR)(LOW10)1qw87bGyPqwkilDDSOUAnRQR9mqvyR6AD93VefU6tWtYIFpaelfYsbzPplDDSOcXywuWs7qT)1Hk9lXSamwuQywuWIzSeGqni0uAdE9YGDihmol9nEJyzogM3yJsxvtGgX2yZd)btJTXrqjCHRTHYyg3ydKWH5I(dMgBfiMyPamugZ4Sy6(DwqAmqI5MbJTWCpnNBSPUAnBWRxgSdv6xIzPqwucngVrSqJH5n2O0v1eOrSn28WFW0ydVY2nKXwiEqt13hu0JnILsgBH5EAo3yRhld1gcV7QAILUowuxTMLc6lctvmu7JDOs)smlaJLcYIcwOG(IWK9YkgQ9HffSmuPFjMfGXIsMdlky5DnLVfdx6kSv)DQ2GdHFlLUQMazPplky59bf92)kP6dRGhXsHSOK5WcaIfCeP113hu0JzbWSmuPFjMffS0JfkOVimzVS6zCw66yzOs)smlaJfubqBPJmw6BSbs4WCr)btJTcetSSTY2nelxYsKNGu5fybMS4z8F)suS87(ZI(qqywuYCWuaZINGSOjmMft3VZsjCiwEFqrpMfpbzXFw(DIfkbzb2yXzzdQ9Hf0pOVimXI)SOK5WcMcywGdlAcJzzOs)YlrXIJz5HSKWNLDhXLOy5HSmuBi8olGR5suSGER0hwq)G(IWKXBelaPH5n2O0v1eOrSn28WFW0yd)(0CT2ydKWH5I(dMgBiNikILvelBVpnxRzXFwCTML)kjmlRutymll8LOyb9Ih8XXS4jil3ZYHzXvHRNLhYs0adSahw00ZYVtSGJOW5Aw8WFWKf9LelQKgAILDpb1elfWH8s1lbPHfyYcaz59bf9yJTWCpnNBSzglVRP8T4N0AFQGZ1ElLUQMazrbl9yrD1Aw87tZ1A7qTHW7UQMyrbl9ybhrAD99bf9yl(9P5AnlaJLcYsxhlMXYSsQbhuK9VsYeCYk4qEP6LG0yP0v1eil9zPRJL31u(wmCPRWw93PAdoe(Tu6QAcKffSOUAnlf0xeMQyO2h7qL(LywaglfKffSqb9fHj7Lvmu7dlkyrD1Aw87tZ1A7qL(LywaglakwuWcoI0667dk6Xw87tZ1Awkuzwmhw6ZIcw6XIzSmRKAWbfz1Xd(44Att0FjQkk9vgHjlLUQMazPRJL)kjwqUSyoOHLczrD1Aw87tZ1A7qL(LywamlaKL(SOGL3hu0B)RKQpScEelfYcAmEJybOmmVXgLUQManITXMh(dMgB43NMR1gBGeomx0FW0yd54(Dw2EsR9HLc4CTNLfMybMSeazX0oLSmuBi8URQjwuxpl4)0Awm53ZsdoSGEXd(4ywIgyGfpbzbeMO7zzHjwuPgCiwqAbeBzz7pTMLfMyrLAWHybPWebeiIf8LbILF3FwmDAnlrdmWINWFNgw2EFAUwBSfM7P5CJT31u(w8tATpvW5AVLsxvtGSOGf1vRzXVpnxRTd1gcV7QAIffS0JfZyzwj1GdkYQJh8XX1MMO)suvu6RmctwkDvnbYsxhl)vsSGCzXCqdlfYI5WsFwuWY7dk6T)vs1hwbpILczPGgVrSaegM3yJsxvtGgX2yZd)btJn87tZ1AJnqchMl6pyASHCC)olfWH8s1lbPHLfMyz79P5AnlpKfGikILvel)oXI6Q1yrnolUgdzzHVeflBVpnxRzbMSGgwWuaMGywGdlAcJzzOs)YlrzSfM7P5CJTzLudoOi7FLKj4KvWH8s1lbPXsPRQjqwuWcoI0667dk6Xw87tZ1AwkuzwkilkyPhlMXI6Q1S)vsMGtwbhYlvVeKg7kIffSOUAnl(9P5ATDO2q4DxvtS01Xspwq4Z5QAYcoKxwnDADT5ADf2ASOGLESOUAnl(9P5ATDOs)smlaJLcYsxhl4isRRVpOOhBXVpnxRzPqwailky5DnLVf)Kw7tfCU2BP0v1eilkyrD1Aw87tZ1A7qL(LywaglOHL(S0NL(gVrSaogM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzS54FCDncAIgwkKfarXSaGyPhlkvmlaplQRwZ(xjzcozfCiVu9sqAS43daXsFwaqS0Jf1vRzXVpnxRTdv6xIzb4zPGSGewWrKwx3D8tSa8SyglVRP8T4N0AFQGZ1ElLUQMazPplaiw6Xsac1GqtPf)(0CT2ouPFjMfGNLcYcsybhrADD3XpXcWZY7AkFl(jT2Nk4CT3sPRQjqw6ZcaILESacFBBnXRWwL0RKSdv6xIzb4zbnS0NffS0Jf1vRzXVpnxRTRiw66yjaHAqOP0IFFAUwBhQ0VeZsFJnqchMl6pyASHuxhwA)jmlM2PFNgwCw2EFWRbfXYctSy60Awc(ctSS9(0CTMLhYsZ1AwGTgAzXtqwwyILT3h8AqrS8qwaIOiwkGd5LQxcsdl43daXYkYydHp10ljJn87tZ16Qjy(1MR1vyRz8gXsPInmVXgLUQManITXMh(dMgB43h8AqrgBGeomx0FW0yRaXelBVp41GIyX097SuahYlvVeKgwEilaruelRiw(DIf1vRXIP73HRNfneFjkw2EFAUwZYk6VsIfpbzzHjw2EFWRbfXcmzXCamlXggdZZc(9aqyww5FAwmhwEFqrp2ylm3tZ5gBi85CvnzbhYlRMoTU2CTUcBnwuWccFoxvtw87tZ16Qjy(1MR1vyRXIcwmJfe(CUQMShQeouf)(GxdkILUow6XI6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqSuilfKLUowuxTMv11EgOkSvDTU(7xIcx9j4jzXVhaILczPGS0NffSGJiTU((GIESf)(0CTMfGXI5WIcwq4Z5QAYIFFAUwxnbZV2CTUcBnJ3iwkPKH5n2O0v1eOrSn28WFW0yZb9O)qqvSjFkn2cXdAQ((GIESrSuYylm3tZ5gBMXYFbGUeflkyXmw8WFW06GE0FiOk2KpLvqV0rr2lRn9HA)zPRJfq4BDqp6peufBYNYkOx6Oil(9aqSamwkilkybe(wh0J(dbvXM8PSc6LokYouPFjMfGXsbn2ajCyUO)GPXwbIjwWM8PKfmKLF3FwIdxSGIEwkDKXYk6VsIf14SSWxIIL7zXXSO9NyXXSebX4tvtSatw0egZYV7jlfKf87bGWSahwaWzHFwmTtjlfeWSGFpaeMfczr3qgVrSucGgM3yJsxvtGgX2yZd)btJTsimB3qgBH4bnvFFqrp2iwkzSfM7P5CJTHAdH3DvnXIcwEFqrV9VsQ(Wk4rSuil9yPhlkzoSayw6XcoI0667dk6Xw87t7gIfGNfaYcWZI6Q1SuqFryQQxPp2vel9zPplaMLHk9lXS0NfKWspwuIfaZY7AkF7B6YAjeMylLUQMazPplkyPhlbiudcnL2GxVmyhYbJZIcwmJfWzDG2ewdGywuWspwq4Z5QAYgGjciqufKWXZalDDSeGqni0uAdWebeiQ(7ufhDZ9y7qoyCw66yXmwcqeu65BZd1(xBoXsFw66ybhrAD99bf9yl(9PDdXcWyPhl9ybqYcaILESOUAnlf0xeMQ6v6JDfXcWZcazPpl9zb4zPhlkXcGz5DnLV9nDzTectSLsxvtGS0NL(SOGfZyHc6lctwmu7tnjK9S01XspwOG(IWK9YkgQ9HLUow6Xcf0xeMSxwvH)olDDSqb9fHj7Lv9k9HL(SOGfZy5DnLVfdx6kSv)DQ2GdHFlLUQMazPRJf1vRzJMReoGNRR(e88c1OLg7JfHRxelfQmlaenfZsFwuWspwWrKwxFFqrp2IFFA3qSamwuQywaEw6XIsSaywExt5BFtxwlHWeBP0v1eil9zPplkyXX)46Ae0enSuilOPywaqSOUAnl(9P5ATDOs)smlaplasw6ZIcw6XIzSOUAnlqxcoeyLkJGMOPKYVsjnOUys2velDDSqb9fHj7Lvmu7dlDDSyglbick98TafFopzPplkyXmwuxTMDCeucx4ABOmMXR4lBlDDpo(P5C7kYydKWH5I(dMgBayO2q4DwaWcHz7gILRXcsJbsm3mWYHzzihmoAz53PHyXhIfnHXS87EYcAy59bf9ywUKf0BL(Wc6h0xeMyX097SSb)caAzrtyml)UNSOuXSa)DAmDyILlzXZ4SG(b9fHjwGdlRiwEilOHL3hu0JzrLAWHyXzb9wPpSG(b9fHjllfqyIUNLHAdH3zbCnxIIfKtxcoeilOFze0enLu(SSsnHXSCjlBqTpSG(b9fHjJ3iwkvqdZBSrPRQjqJyBS5H)GPXwdobQcB10)1qgBGeomx0FW0yRaXelfaySybMSeazX097W1ZsWJIUeLXwyUNMZn28OAyNcaz8gXsjZXW8gBu6QAc0i2gBWiJnm9gBE4pyASHWNZv1KXgcxViJnZybCwhOnH1aiMffSGWNZv1KnawdWe8(dMSOGLES0Jf1vRzXVpnxRTRiw66yPhlVRP8T4N0AFQGZ1ElLUQMazPRJLaebLE(28qT)1MtS0NL(SOGLESyglQRwZIHA8FbYUIyrblMXI6Q1SbVEzWUIyrbl9yXmwExt5BBRjEf2QKELKLsxvtGS01XI6Q1SbVEzWcUg)pyYsHSeGqni0uABRjEf2QKELKDOs)smlaMfabl9zrbli85Cvnz)9506kMiGOPAYVNffS0JfZyjarqPNVnpu7FT5elDDSeGqni0uAdWebeiQ(7ufhDZ9y7kIffS0Jf1vRzXVpnxRTdv6xIzbySaqw66yXmwExt5BXpP1(ubNR9wkDvnbYsFw6ZIcwEFqrV9VsQ(Wk4rSuilQRwZg86Lbl4A8)GjlaplfBbuS0NLUowuHymlkyPDO2)6qL(LywaglQRwZg86Lbl4A8)Gjl9n2q4tn9sYylawdWe8(dMvhsgVrSucngM3yJsxvtGgX2yZd)btJTaPj8FUU66dvws5BSbs4WCr)btJTcetSG0yGeZndSatwcGSSsnHXS4jil6ljwUNLvelMUFNfKcteqGiJTWCpnNBSHWNZv1KnawdWe8(dMvhsgVrSucqAyEJnkDvnbAeBJTWCpnNBSHWNZv1KnawdWe8(dMvhsgBE4pyASDzWN0)dMgVrSucqzyEJnkDvnbAeBJnp8hmn2OYiOjAQQWe0ydKWH5I(dMgBfiMyb9lJGMOHLydtqwGjlbqwmD)olBVpnxRzzfXINGSGDeeln4WcaCPX(WINGSG0yGeZndgBH5EAo3ytfIXSOGLlFAIGA)jWA7qT)1Hk9lXSamwucnS01XspwuxTMnAUs4aEUU6tWZluJwASpweUErSamwaiAkMLUowuxTMnAUs4aEUU6tWZluJwASpweUErSuOYSaq0uml9zrblQRwZIFFAUwBxrSOGLESeGqni0uAdE9YGDOs)smlfYcAkMLUowaN1bAtynaIzPVXBelLaegM3yJsxvtGgX2yZd)btJn8tATp1M2hYylepOP67dk6XgXsjJTWCpnNBSnuBi8URQjwuWYFLu9HvWJyPqwucnSOGfCeP113hu0JT43N2nelaJfZHffS4r1WofaIffS0Jf1vRzdE9YGDOs)smlfYIsfZsxhlMXI6Q1SbVEzWUIyPVXgiHdZf9hmn2aWqTHW7S00(qSatwwrS8qwkilVpOOhZIP73HRNfKgdKyUzGfv6suS4QW1ZYdzHqw0nelEcYscFwGiOj4rrxIY4nILsahdZBSrPRQjqJyBS5H)GPXwBnXRWwL0RKm2ajCyUO)GPXwbIjwkaq0NLRXYL4dKyXtwq)G(IWelEcYI(sIL7zzfXIP73zXzbaU0yFyjAGbw8eKLya6r)HGyzZKpLgBH5EAo3yJc6lct2lREgNffS4r1WofaIffSOUAnB0CLWb8CD1NGNxOgT0yFSiC9IybySaq0umlkyPhlGW36GE0FiOk2KpLvqV0rr2)caDjkw66yXmwcqeu65BtkmqnCazPRJfCeP113hu0JzPqwail9zrbl9yrD1A2XrqjCHRTHYyg3ouPFjMfGXcWHfael9ybnSa8SmRKAWbfzXx2w66EC8tZ5wkDvnbYsFwuWI6Q1SJJGs4cxBdLXmUDfXsxhlMXI6Q1SJJGs4cxBdLXmUDfXsFwuWspwmJLaeQbHMsBWRxgSRiw66yrD1A2FFoTUIjciAS43daXcWyrj0WIcwAhQ9VouPFjMfGXcalUywuWs7qT)1Hk9lXSuilkvCXS01XIzSGHlT6LG2FFoTUIjciASu6QAcKL(gVrSayXgM3yJsxvtGgX2yZd)btJn87tZ1AJnqchMl6pyASvGyIfNLT3NMR1SaGpPFNLObgyzLAcJzz79P5AnlhMfxpKdgNLvelWHL4Wfl(qS4QW1ZYdzbIGMGhXsmWaqJTWCpnNBSPUAnlmPFhxJOjqr)bt7kIffS0Jf1vRzXVpnxRTd1gcV7QAILUowC8pUUgbnrdlfYcWPyw6B8gXcGkzyEJnkDvnbAeBJnp8hmn2WVpnxRn2ajCyUO)GPXwbCvgXsmWaqwuPgCiwqkmrabIyX097SS9(0CTMfpbz53PKLT3h8AqrgBH5EAo3ylarqPNVnpu7FT5elkyXmwExt5BXpP1(ubNR9wkDvnbYIcw6XccFoxvt2amrabIQGeoEgyPRJLaeQbHMsBWRxgSRiw66yrD1A2GxVmyxrS0NffSeGqni0uAdWebeiQ(7ufhDZ9y7qL(LywaglOcG2shzSa8SeOtZspwC8pUUgbnrdliHf0uml9zrblQRwZIFFAUwBhQ0VeZcWyXCyrblMXc4SoqBcRbqSXBelacqdZBSrPRQjqJyBSfM7P5CJTaebLE(28qT)1MtSOGLESGWNZv1KnateqGOkiHJNbw66yjaHAqOP0g86Lb7kILUowuxTMn41ld2vel9zrblbiudcnL2amrabIQ)ovXr3Cp2ouPFjMfGXcGKffSOUAnl(9P5ATDfXIcwOG(IWK9YQNXzrblMXccFoxvt2dvchQIFFWRbfXIcwmJfWzDG2ewdGyJnp8hmn2WVp41GImEJybWcAyEJnkDvnbAeBJnp8hmn2WVp41GIm2ajCyUO)GPXwbIjw2EFWRbfXIP73zXtwaWN0VZs0adSahwUglXHl0bYcebnbpILyGbGSy6(DwIdxdljHSNLGJFllXqJHSaUkJyjgyail(ZYVtSqjilWgl)oXcaUu(7XhwuxTglxJLT3NMR1SycU0Gj6EwAUwZcS1yboSehUyXhIfyYcaz59bf9yJTWCpnNBSPUAnlmPFhxdAYNkIdFW0UIyPRJLESygl43N2nK1JQHDkaelkyXmwq4Z5QAYEOs4qv87dEnOiw66yPhlQRwZg86Lb7qL(LywaglOHffSOUAnBWRxgSRiw66yPhl9yrD1A2GxVmyhQ0VeZcWybva0w6iJfGNLaDAw6XIJ)X11iOjAybjSuWIzPplkyrD1A2GxVmyxrS01XI6Q1SJJGs4cxBdLXmEfFzBPR7XXpnNBhQ0VeZcWybva0w6iJfGNLaDAw6XIJ)X11iOjAybjSuWIzPplkyrD1A2XrqjCHRTHYygVIVST01944NMZTRiw6ZIcwcqeu65Brq5VhFyPpl9zrbl9ybhrAD99bf9yl(9P5AnlaJLcYsxhli85CvnzXVpnxRRMG5xBUwxHTgl9zPplkyXmwq4Z5QAYEOs4qv87dEnOiwuWspwmJLzLudoOi7FLKj4KvWH8s1lbPXsPRQjqw66ybhrAD99bf9yl(9P5AnlaJLcYsFJ3iwa0CmmVXgLUQManITXMh(dMgBjzQwcHPXgiHdZf9hmn2kqmXcawimXSCjlBqTpSG(b9fHjw8eKfSJGyPaS0AwaWcHjln4WcsJbsm3mySfM7P5CJTESOUAnlf0xeMQyO2h7qL(LywkKfczuy9u9VsILUow6Xsy3hueMfLzbGSOGLHc7(GIQ)vsSamwqdl9zPRJLWUpOimlkZsbzPplkyXJQHDkaKXBelaIgdZBSrPRQjqJyBSfM7P5CJTESOUAnlf0xeMQyO2h7qL(LywkKfczuy9u9VsILUow6Xsy3hueMfLzbGSOGLHc7(GIQ)vsSamwqdl9zPRJLWUpOimlkZsbzPplkyXJQHDkaelkyPhlQRwZoockHlCTnugZ42Hk9lXSamwqdlkyrD1A2XrqjCHRTHYyg3UIyrblMXYSsQbhuKfFzBPR7XXpnNBP0v1eilDDSyglQRwZoockHlCTnugZ42vel9n28WFW0yB31TAjeMgVrSaiG0W8gBu6QAc0i2gBH5EAo3yRhlQRwZsb9fHPkgQ9XouPFjMLczHqgfwpv)RKyrbl9yjaHAqOP0g86Lb7qL(LywkKf0umlDDSeGqni0uAdWebeiQ(7ufhDZ9y7qL(LywkKf0uml9zPRJLESe29bfHzrzwailkyzOWUpOO6FLelaJf0WsFw66yjS7dkcZIYSuqw6ZIcw8OAyNcaXIcw6XI6Q1SJJGs4cxBdLXmUDOs)smlaJf0WIcwuxTMDCeucx4ABOmMXTRiwuWIzSmRKAWbfzXx2w66EC8tZ5wkDvnbYsxhlMXI6Q1SJJGs4cxBdLXmUDfXsFJnp8hmn2AlTUwcHPXBelacOmmVXgLUQManITXgiHdZf9hmn2kqmXcYbe9zbMSG0cOXMh(dMgBM8zo4uHTkPxjz8gXcGacdZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im2WrKwxFFqrp2IFFA3qSuilMdlaMLMgchw6XsPJFAIxr46fXcWZIsfxmliHfawml9zbWS00q4WspwuxTMf)(GxdkQsLrqt0us5xXqTpw87bGybjSyoS03ydKWH5I(dMgBi11HL2FcZIPD63PHLhYYctSS9(0UHy5sw2GAFyX0(f2z5WS4plOHL3hu0JbSsS0GdlecAIZcalg5YsPJFAIZcCyXCyz79bVguelOFze0enLu(SGFpae2ydHp10ljJn87t7gQEzfd1(y8gXcGahdZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im2uIfKWcoI066UJFIfGXcazbaXspwk2cqwaEw6XcoI0667dk6Xw87t7gIfaelkXsFwaEw6XIsSaywExt5BXWLUcB1FNQn4q43sPRQjqwaEwuYIgw6ZsFwamlfBvcnSa8SOUAn74iOeUW12qzmJBhQ0VeBSbs4WCr)btJnK66Ws7pHzX0o970WYdzb5y8FNfW1CjkwkadLXmUXgcFQPxsgBMg)3RxwBdLXmUXBeRcwSH5n2O0v1eOrSn28WFW0yZ04)UXgiHdZf9hmn2kqmXcYX4)olxYYgu7dlOFqFryIf4WY1yjHSS9(0UHyX0P1S0UNLlFilingiXCZalEgVeoKXwyUNMZn26Xcf0xeMS6v6tnjK9S01Xcf0xeMSEgVMeYEwuWccFoxvt2dxdAYrqS0NffS0JL3hu0B)RKQpScEelfYI5WsxhluqFryYQxPp1lRaKLUowAhQ9VouPFjMfGXIsfZsFw66yrD1AwkOVimvXqTp2Hk9lXSamw8WFW0IFFA3qwczuy9u9VsIffSOUAnlf0xeMQyO2h7kILUowOG(IWK9YkgQ9HffSygli85CvnzXVpTBO6Lvmu7dlDDSOUAnBWRxgSdv6xIzbyS4H)GPf)(0UHSeYOW6P6FLelkyXmwq4Z5QAYE4AqtocIffSOUAnBWRxgSdv6xIzbySqiJcRNQ)vsSOGf1vRzdE9YGDfXsxhlQRwZoockHlCTnugZ42velkybHpNRQjRPX)96L12qzmJZsxhlMXccFoxvt2dxdAYrqSOGf1vRzdE9YGDOs)smlfYcHmkSEQ(xjz8gXQGkzyEJnkDvnbAeBJnqchMl6pyASvGyILT3N2nelxJLlzb9wPpSG(b9fHj0YYLSSb1(Wc6h0xeMybMSyoaML3hu0JzboS8qwIgyGLnO2hwq)G(IWKXMh(dMgB43N2nKXBeRccqdZBSrPRQjqJyBSbs4WCr)btJTcGR1)(Sm28WFW0yBwz1d)bZQ(WVXM(WFn9sYyR5A9VplJ34n2AUw)7ZYW8gXsjdZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn22EFWRbfXsdoSucrqLu(SSsnHXSSWxIILydJH5n2cZ90CUXMzSmRKAWbfzvDTNbQcBvxRR)(LOWwc4UUOic04nIfanmVXgLUQManITXMh(dMgB4v2UHm2cXdAQ((GIESrSuYylm3tZ5gBGW3wcHz7gYouPFjMLczzOs)smlaplaeGSGewucqySbs4WCr)btJnK64NLFNybe(Sy6(Dw(DILsi(z5VsILhYIdcYYk)tZYVtSu6iJfW14)btwoml73BzzBLTBiwgQ0VeZs5s)xK(iqwEilL(h2zPecZ2nelGRX)dMgVrSkOH5n28WFW0yRecZ2nKXgLUQManITXB8gB43W8gXsjdZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn2kqmXY27dEnOiwEilaruelRiw(DILc4qEP6LG0WI6Q1y5ASCplMGlnileYIUHyrLAWHyPD5H3Vefl)oXssi7zj44Nf4WYdzbCvgXIk1GdXcsHjciqKXwyUNMZn2Mvsn4GIS)vsMGtwbhYlvVeKglLUQMazrbl9yHc6lct2lREgNffSygl9yPhlQRwZ(xjzcozfCiVu9sqASdv6xIzPqw8WFW0AA8F3siJcRNQ)vsSaywk2QelkyPhluqFryYEzvf(7S01Xcf0xeMSxwXqTpS01Xcf0xeMS6v6tnjK9S0NLUowuxTM9VsYeCYk4qEP6LG0yhQ0VeZsHS4H)GPf)(0UHSeYOW6P6FLelaMLITkXIcw6Xcf0xeMSxw1R0hw66yHc6lctwmu7tnjK9S01Xcf0xeMSEgVMeYEw6ZsFw66yXmwuxTM9VsYeCYk4qEP6LG0yxrS0NLUow6XI6Q1SbVEzWUIyPRJfe(CUQMSbyIacevbjC8mWsFwuWsac1GqtPnateqGO6VtvC0n3JTd5GXzrblbick98T5HA)RnNyPplkyPhlMXsaIGspFlqXNZtw66yjaHAqOP0sLrqt0uvHjODOs)smlfYcGGL(SOGLESOUAnBWRxgSRiw66yXmwcqOgeAkTbVEzWoKdgNL(gVrSaOH5n2O0v1eOrSn28WFW0yZb9O)qqvSjFkn2cXdAQ((GIESrSuYylm3tZ5gBMXci8ToOh9hcQIn5tzf0lDuK9VaqxIIffSyglE4pyADqp6peufBYNYkOx6Oi7L1M(qT)SOGLESyglGW36GE0FiOk2KpL1DY12)caDjkw66ybe(wh0J(dbvXM8PSUtU2ouPFjMLczbnS0NLUowaHV1b9O)qqvSjFkRGEPJIS43daXcWyPGSOGfq4BDqp6peufBYNYkOx6Oi7qL(LywaglfKffSacFRd6r)HGQyt(uwb9shfz)la0LOm2ajCyUO)GPXwbIjwIbOh9hcILnt(uYIPDkz53PHy5WSKqw8WFiiwWM8PeTS4yw0(tS4ywIGy8PQjwGjlyt(uYIP73zbGSahwAKjAyb)EaimlWHfyYIZsbbmlyt(uYcgYYV7pl)oXssMybBYNsw8zoeeMfaCw4NfV90WYV7plyt(uYcHSOBiSXBeRcAyEJnkDvnbAeBJnp8hmn2cWebeiQ(7ufhDZ9yJnqchMl6pyASvGycZcsHjciqelxJfKgdKyUzGLdZYkIf4WsC4IfFiwajC8mCjkwqAmqI5MbwmD)olifMiGarS4jilXHlw8HyrL0qtSyofZsmWaqJTWCpnNBSzglGZ6aTjSgaXSOGLES0Jfe(CUQMSbyIacevbjC8mWIcwmJLaeQbHMsBWRxgSd5GXzrblMXYSsQbhuKnAUs4aEUU6tWZluJwASpwkDvnbYsxhlQRwZg86Lb7kIL(SOGfh)JRRrqt0WcWuMfZPywuWspwuxTMLc6lctv9k9XouPFjMLczrPIzPRJf1vRzPG(IWufd1(yhQ0VeZsHSOuXS0NLUowuHymlkyPDO2)6qL(LywaglkvmlkyXmwcqOgeAkTbVEzWoKdgNL(gVrSmhdZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im26XI6Q1SJJGs4cxBdLXmUDOs)smlfYcAyPRJfZyrD1A2XrqjCHRTHYyg3UIyPplkyXmwuxTMDCeucx4ABOmMXR4lBlDDpo(P5C7kIffS0Jf1vRzb6sWHaRuze0enLu(vkPb1ftYouPFjMfGXcQaOT0rgl9zrbl9yrD1AwkOVimvXqTp2Hk9lXSuilOcG2shzS01XI6Q1SuqFryQQxPp2Hk9lXSuilOcG2shzS01XspwmJf1vRzPG(IWuvVsFSRiw66yXmwuxTMLc6lctvmu7JDfXsFwuWIzS8UMY3IHA8FbYsPRQjqw6BSbs4WCr)btJnKctW7pyYsdoS4AnlGWhZYV7plLoqeMf8Aiw(Dkol(qj6EwgQneENazX0oLSaGXrqjCHzPamugZ4SS7yw0egZYV7jlOHfmfWSmuPF5LOyboS87elafFopzrD1ASCywCv46z5HS0CTMfyRXcCyXZ4SG(b9fHjwomlUkC9S8qwiKfDdzSHWNA6LKXgi8RdbCx3qLu(yJ3iwOXW8gBu6QAc0i2gBWiJnm9gBE4pyASHWNZv1KXgcxViJTESyglQRwZsb9fHPkgQ9XUIyrblMXI6Q1SuqFryQQxPp2vel9zPRJL31u(wmuJ)lqwkDvnbASbs4WCr)btJnKctW7pyYYV7plHDkaeMLRXsC4IfFiwGRhFGeluqFryILhYcm1Xzbe(S870qSahwoujCiw(9dZIP73zzdQX)fiJne(utVKm2aHFfUE8bsvkOVimz8gXcqAyEJnkDvnbAeBJnp8hmn2kHWSDdzSfM7P5CJTHAdH3DvnXIcw6XI6Q1SuqFryQIHAFSdv6xIzPqwgQ0VeZsxhlQRwZsb9fHPQEL(yhQ0VeZsHSmuPFjMLUowq4Z5QAYcc)kC94dKQuqFryIL(SOGLHAdH3DvnXIcwEFqrV9VsQ(Wk4rSuilkbqwuWIhvd7uaiwuWccFoxvtwq4xhc4UUHkP8XgBH4bnvFFqrp2iwkz8gXcqzyEJnkDvnbAeBJnp8hmn2WRSDdzSfM7P5CJTHAdH3DvnXIcw6XI6Q1SuqFryQIHAFSdv6xIzPqwgQ0VeZsxhlQRwZsb9fHPQEL(yhQ0VeZsHSmuPFjMLUowq4Z5QAYcc)kC94dKQuqFryIL(SOGLHAdH3DvnXIcwEFqrV9VsQ(Wk4rSuilkbqwuWIhvd7uaiwuWccFoxvtwq4xhc4UUHkP8XgBH4bnvFFqrp2iwkz8gXcqyyEJnkDvnbAeBJnp8hmn2WpP1(uBAFiJTWCpnNBSnuBi8URQjwuWspwuxTMLc6lctvmu7JDOs)smlfYYqL(Lyw66yrD1AwkOVimv1R0h7qL(LywkKLHk9lXS01XccFoxvtwq4xHRhFGuLc6lctS0NffSmuBi8URQjwuWY7dk6T)vs1hwbpILczrjajlkyXJQHDkaelkybHpNRQjli8RdbCx3qLu(yJTq8GMQVpOOhBelLmEJybCmmVXgLUQManITXMh(dMgBn4eOkSvt)xdzSbs4WCr)btJTcetSuaGXIfyYsaKft3Vdxplbpk6sugBH5EAo3yZJQHDkaKXBelLk2W8gBu6QAc0i2gBE4pyASrLrqt0uvHjOXgiHdZf9hmn2kqmXcYPlbhcKLTOBUhZIP73zXZ4SOHjkwOeUqTZI2X)LOyb9d6lctS4jil)eNLhYI(sIL7zzfXIP73zbaU0yFyXtqwqAmqI5MbJTWCpnNBS1JLESOUAnlf0xeMQyO2h7qL(LywkKfLkMLUowuxTMLc6lctv9k9XouPFjMLczrPIzPplkyjaHAqOP0g86Lb7qL(LywkKLcwmlkyPhlQRwZgnxjCapxx9j45fQrln2hlcxViwagla0CkMLUowmJLzLudoOiB0CLWb8CD1NGNxOgT0yFSeWDDrreil9zPplDDSOUAnB0CLWb8CD1NGNxOgT0yFSiC9IyPqLzbGaQIzPRJLaeQbHMsBWRxgSd5GXzrblo(hxxJGMOHLczb4uSXBelLuYW8gBu6QAc0i2gBWiJnm9gBE4pyASHWNZv1KXgcxViJnZybCwhOnH1aiMffSGWNZv1KnawdWe8(dMSOGLES0JLaeQbHMslvgfFixxHdy6zGSdv6xIzbySOeGeqXcGzPhlkPelaplZkPgCqrw8LTLUUhh)0CULsxvtGS0NffSqa31ffrGwQmk(qUUchW0ZaXsFw66yXX)46Ae0enSuOYSaCkMffS0JfZy5DnLVTTM4vyRs6vswkDvnbYsxhlQRwZg86Lbl4A8)GjlfYsac1GqtPTTM4vyRs6vs2Hk9lXSaywaeS0NffSGWNZv1K93NtRRyIaIMQj)EwuWspwuxTMfOlbhcSsLrqt0us5xPKguxmj7kILUowmJLaebLE(wGIpNNS0NffS8(GIE7FLu9HvWJyPqwuxTMn41ldwW14)btwaEwk2cOyPRJfvigZIcwAhQ9VouPFjMfGXI6Q1SbVEzWcUg)pyYsxhlbick98T5HA)RnNyPRJf1vRzv1qiOEHF7kIffSOUAnRQgcb1l8BhQ0VeZcWyrD1A2GxVmybxJ)hmzbWS0JfGdlaplZkPgCqr2O5kHd456QpbpVqnAPX(yjG76IIiqw6ZsFwuWIzSOUAnBWRxgSRiwuWspwmJLaebLE(28qT)1MtS01Xsac1GqtPnateqGO6VtvC0n3JTRiw66yrfIXSOGL2HA)Rdv6xIzbySeGqni0uAdWebeiQ(7ufhDZ9y7qL(Lywamlasw66yPDO2)6qL(LywqUSOeGOywaglQRwZg86Lbl4A8)Gjl9n2ajCyUO)GPXwbIjwqAmqI5MbwmD)olifMiGarib50LGdbYYw0n3JzXtqwaHj6EwGiOX0CpXcaCPX(WcCyX0oLSeBnecQx4NftWLgKfczr3qSOsn4qSG0yGeZndSqil6gcBSHWNA6LKXwaSgGj49hmR434nILsa0W8gBu6QAc0i2gBE4pyASnockHlCTnugZ4gBGeomx0FW0yRaXel)oXcaUu(7XhwmD)ololingiXCZal)U)SC4eDplTbwYcaCPX(ySfM7P5CJn1vRzdE9YGDOs)smlfYIsOHLUowuxTMn41ldwW14)btwaglfSywuWccFoxvt2aynatW7pywXVXBelLkOH5n2O0v1eOrSn2cZ90CUXgcFoxvt2aynatW7pywXplkyPhlMXI6Q1SbVEzWcUg)pyYsHSuWIzPRJfZyjarqPNVfbL)E8HL(S01XI6Q1SJJGs4cxBdLXmUDfXIcwuxTMDCeucx4ABOmMXTdv6xIzbySaCybWSeGj46EB0qHdtvxFOYskF7FLufHRxelaMLESyglQRwZQQHqq9c)2velkyXmwExt5BXVpA4aAP0v1eil9n28WFW0ylqAc)NRRU(qLLu(gVrSuYCmmVXgLUQManITXwyUNMZn2q4Z5QAYgaRbycE)bZk(n28WFW0y7YGpP)hmnEJyPeAmmVXgLUQManITXgmYydtVXMh(dMgBi85CvnzSHW1lYyZmwcqOgeAkTbVEzWoKdgNLUowmJfe(CUQMSbyIacevbjC8mWIcwcqeu65BZd1(xBoXsxhlGZ6aTjSgaXgBGeomx0FW0ydaxFoxvtSSWeilWKfx903FeMLF3Fwm55ZYdzrLyb7iiqwAWHfKgdKyUzGfmKLF3Fw(Dkol(q5ZIjh)eila4SWplQudoel)ovASHWNA6LKXg2rq1gCQbVEzW4nILsasdZBSrPRQjqJyBS5H)GPXwBnXRWwL0RKm2ajCyUO)GPXwbIjmlfai6ZY1y5sw8Kf0pOVimXINGS8ZrywEil6ljwUNLvelMUFNfa4sJ9bTSG0yGeZndS4jilXa0J(dbXYMjFkn2cZ90CUXgf0xeMSxw9molkyXJQHDkaelkyrD1A2O5kHd456QpbpVqnAPX(yr46fXcWybGMtXSOGLESacFRd6r)HGQyt(uwb9shfz)la0LOyPRJfZyjarqPNVnPWa1WbKL(SOGfe(CUQMSyhbvBWPg86LbwuWspwuxTMDCeucx4ABOmMXTdv6xIzbySaCybaXspwqdlaplZkPgCqrw8LTLUUhh)0CULsxvtGS0NffSOUAn74iOeUW12qzmJBxrS01XIzSOUAn74iOeUW12qzmJBxrS034nILsakdZBSrPRQjqJyBS5H)GPXg(9P5ATXgiHdZf9hmn2kqmXca(K(Dw2EFAUwZs0adywUglBVpnxRz5Wj6EwwrgBH5EAo3ytD1Awys)oUgrtGI(dM2velkyrD1Aw87tZ1A7qTHW7UQMmEJyPeGWW8gBu6QAc0i2gBH5EAo3ytD1Aw87JgoG2Hk9lXSamwqdlkyPhlQRwZsb9fHPkgQ9XouPFjMLczbnS01XI6Q1SuqFryQQxPp2Hk9lXSuilOHL(SOGfh)JRRrqt0WsHSaCk2yZd)btJTGNbsxvxTMXM6Q1QPxsgB43hnCanEJyPeWXW8gBu6QAc0i2gBE4pyASHFFWRbfzSbs4WCr)btJTc4QmcZsmWaqwuPgCiwqkmrabIyzHVefl)oXcsHjciqelbycE)btwEilHDkaelxJfKcteqGiwomlE4xUwhNfxfUEwEilQelbh)gBH5EAo3ylarqPNVnpu7FT5elkybHpNRQjBaMiGarvqchpdSOGLaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZcWybnSOGfZybCwhOnH1aiMffSqb9fHj7LvpJZIcwC8pUUgbnrdlfYI5uSXBelawSH5n2O0v1eOrSn28WFW0yd)(0CT2ydKWH5I(dMgBfiMyz79P5AnlMUFNLTN0AFyPaox7zXtqwsilBVpA4aIwwmTtjljKLT3NMR1SCywwrOLL4Wfl(qSCjlO3k9Hf0pOVimXsdoSaiamMcywGdlpKLObgybaU0yFyX0oLS4QqeelaNIzjgyailWHfhmY)dbXc2KpLSS7ywaeagtbmldv6xEjkwGdlhMLlzPPpu7VLLybFILF3FwwjinS87elyVKyjatW7pyIz5E0HzbmcZssRFCnlpKLT3NMR1SaUMlrXcaghbLWfMLcWqzmJJwwmTtjlXHl0bYc(pTMfkbzzfXIP73zb4umGDCeln4WYVtSOD8Zcknu11yRXwyUNMZn2Ext5BXpP1(ubNR9wkDvnbYIcwmJL31u(w87JgoGwkDvnbYIcwuxTMf)(0CT2ouBi8URQjwuWspwuxTMLc6lctv9k9XouPFjMLczbqWIcwOG(IWK9YQEL(WIcwuxTMnAUs4aEUU6tWZluJwASpweUErSamwaiAkMLUowuxTMnAUs4aEUU6tWZluJwASpweUErSuOYSaq0umlkyXX)46Ae0enSuilaNIzPRJfq4BDqp6peufBYNYkOx6Oi7qL(LywkKfablDDS4H)GP1b9O)qqvSjFkRGEPJISxwB6d1(ZsFwuWsac1GqtPn41ld2Hk9lXSuilkvSXBelaQKH5n2O0v1eOrSn28WFW0yd)(GxdkYydKWH5I(dMgBfiMyz79bVguela4t63zjAGbmlEcYc4QmILyGbGSyANswqAmqI5MbwGdl)oXcaUu(7XhwuxTglhMfxfUEwEilnxRzb2ASahwIdxOdKLGhXsmWaqJTWCpnNBSPUAnlmPFhxdAYNkIdFW0UIyPRJf1vRzb6sWHaRuze0enLu(vkPb1ftYUIyPRJf1vRzdE9YGDfXIcw6XI6Q1SJJGs4cxBdLXmUDOs)smlaJfubqBPJmwaEwc0PzPhlo(hxxJGMOHfKWsblML(SaywkilaplVRP8TjzQwcHPLsxvtGSOGfZyzwj1GdkYIVST01944NMZTu6QAcKffSOUAn74iOeUW12qzmJBxrS01XI6Q1SbVEzWouPFjMfGXcQaOT0rglaplb60S0Jfh)JRRrqt0WcsyPGfZsFw66yrD1A2XrqjCHRTHYygVIVST01944NMZTRiw66yXmwuxTMDCeucx4ABOmMXTRiwuWIzSeGqni0uAhhbLWfU2gkJzC7qoyCw66yXmwcqeu65Brq5VhFyPplDDS44FCDncAIgwkKfGtXSOGfkOVimzVS6zCJ3iwaeGgM3yJsxvtGgX2yZd)btJn87dEnOiJnqchMl6pyASz(jolpKLshiILFNyrLWplWglBVpA4aYIACwWVha6suSCplRiwaURlaKoolxYINXzb9d6lctSOUEwaGln2hwoC(S4QW1ZYdzrLyjAGHabASfM7P5CJT31u(w87JgoGwkDvnbYIcwmJLzLudoOi7FLKj4KvWH8s1lbPXsPRQjqwuWspwuxTMf)(OHdODfXsxhlo(hxxJGMOHLczb4uml9zrblQRwZIFF0Wb0IFpaelaJLcYIcw6XI6Q1SuqFryQIHAFSRiw66yrD1AwkOVimv1R0h7kIL(SOGf1vRzJMReoGNRR(e88c1OLg7JfHRxelaJfacOkMffS0JLaeQbHMsBWRxgSdv6xIzPqwuQyw66yXmwq4Z5QAYgGjciqufKWXZalkyjarqPNVnpu7FT5el9nEJybWcAyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXgf0xeMSxw1R0hwaEwaeSGew8WFW0IFFA3qwczuy9u9VsIfaZIzSqb9fHj7Lv9k9HfGNLESaizbWS8UMY3IHlDf2Q)ovBWHWVLsxvtGSa8Suqw6ZcsyXd)btRPX)DlHmkSEQ(xjXcGzPyR5Ggwqcl4isRR7o(jwamlfBrdlaplVRP8TP)RHWvvx7zGSu6QAc0ydKWH5I(dMgBOp(Vs)jml7qtSuUc7SedmaKfFiwq5xsGSerdlykatqJne(utVKm2CCeaKMnky8gXcGMJH5n2O0v1eOrSn28WFW0yd)(GxdkYydKWH5I(dMgBfWvzelBVp41GIy5swCwauagtbw2GAFyb9d6lctOLfqyIUNfn9SCplrdmWcaCPX(WsVF3Fwoml7EcQjqwuJZcD)onS87elBVpnxRzrFjXcCy53jwIbgawiWPyw0xsS0GdlBVp41GI6JwwaHj6EwGiOX0CpXINSaGpPFNLObgyXtqw00ZYVtS4Qqeel6ljw29eutSS9(OHdOXwyUNMZn2mJLzLudoOi7FLKj4KvWH8s1lbPXsPRQjqwuWspwuxTMnAUs4aEUU6tWZluJwASpweUErSamwaiGQyw66yrD1A2O5kHd456QpbpVqnAPX(yr46fXcWybGOPywuWY7AkFl(jT2Nk4CT3sPRQjqw6ZIcw6Xcf0xeMSxwXqTpSOGfh)JRRrqt0WcGzbHpNRQjRJJaG0SrbwaEwuxTMLc6lctvmu7JDOs)smlaMfq4BBRjEf2QKELK9Vaq46qL(LSa8SaqlAyPqwaefZsxhluqFryYEzvVsFyrblo(hxxJGMOHfaZccFoxvtwhhbaPzJcSa8SOUAnlf0xeMQ6v6JDOs)smlaMfq4BBRjEf2QKELK9Vaq46qL(LSa8SaqlAyPqwaofZsFwuWIzSOUAnlmPFhxJOjqr)bt7kIffSyglVRP8T43hnCaTu6QAcKffS0JLaeQbHMsBWRxgSdv6xIzPqwauS01XcgU0QxcA)9506kMiGOXsPRQjqwuWI6Q1S)(CADfteq0yXVhaIfGXsblilaiw6XYSsQbhuKfFzBPR7XXpnNBP0v1eilaplOHL(SOGL2HA)Rdv6xIzPqwuQ4IzrblTd1(xhQ0VeZcWybGfxml9zrbl9yjaHAqOP0c0LGdbwXr3Cp2ouPFjMLczbqXsxhlMXsaIGspFlqXNZtw6B8gXcGOXW8gBu6QAc0i2gBE4pyASLKPAjeMgBGeomx0FW0yRaXelayHWeZYLSGER0hwq)G(IWelEcYc2rqSGCgx3aCbyP1SaGfctwAWHfKgdKyUzGfpbzb50LGdbYc6xgbnrtjLVXwyUNMZn26XI6Q1SuqFryQQxPp2Hk9lXSuileYOW6P6FLelDDS0JLWUpOimlkZcazrbldf29bfv)RKybySGgw6ZsxhlHDFqrywuMLcYsFwuWIhvd7uaiwuWccFoxvtwSJGQn4udE9YGXBelacinmVXgLUQManITXwyUNMZn26XI6Q1SuqFryQQxPp2Hk9lXSuileYOW6P6FLelkyXmwcqeu65Bbk(CEYsxhl9yrD1AwGUeCiWkvgbnrtjLFLsAqDXKSRiwuWsaIGspFlqXNZtw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr1)kjwaglOHL(S01Xsy3hueMfLzPGS01XI6Q1SbVEzWUIyPplkyXJQHDkaelkybHpNRQjl2rq1gCQbVEzGffS0Jf1vRzhhbLWfU2gkJzC7qL(Lywagl9ybnSaGybGSa8SmRKAWbfzXx2w66EC8tZ5wkDvnbYsFwuWI6Q1SJJGs4cxBdLXmUDfXsxhlMXI6Q1SJJGs4cxBdLXmUDfXsFJnp8hmn22DDRwcHPXBelacOmmVXgLUQManITXwyUNMZn26XI6Q1SuqFryQQxPp2Hk9lXSuileYOW6P6FLelkyXmwcqeu65Bbk(CEYsxhl9yrD1AwGUeCiWkvgbnrtjLFLsAqDXKSRiwuWsaIGspFlqXNZtw6Zsxhl9yjS7dkcZIYSaqwuWYqHDFqr1)kjwaglOHL(S01Xsy3hueMfLzPGS01XI6Q1SbVEzWUIyPplkyXJQHDkaelkybHpNRQjl2rq1gCQbVEzGffS0Jf1vRzhhbLWfU2gkJzC7qL(LywaglOHffSOUAn74iOeUW12qzmJBxrSOGfZyzwj1GdkYIVST01944NMZTu6QAcKLUowmJf1vRzhhbLWfU2gkJzC7kIL(gBE4pyAS1wADTectJ3iwaeqyyEJnkDvnbAeBJnqchMl6pyASvGyIfKdi6ZcmzjaAS5H)GPXMjFMdovyRs6vsgVrSaiWXW8gBu6QAc0i2gBE4pyASHFFA3qgBGeomx0FW0yRaXelBVpTBiwEilrdmWYgu7dlOFqFrycTSG0yGeZndSS7yw0egZYFLel)UNS4SGCm(VZcHmkSEIfn1EwGdlWuhNf0BL(Wc6h0xeMy5WSSIm2cZ90CUXgf0xeMSxw1R0hw66yHc6lctwmu7tnjK9S01Xcf0xeMSEgVMeYEw66yPhlQRwZAYN5Gtf2QKELKDfXsxhl4isRR7o(jwaglfBnh0WIcwmJLaebLE(weu(7Xhw66ybhrADD3XpXcWyPyR5WIcwcqeu65Brq5VhFyPplkyrD1AwkOVimv1R0h7kILUow6XI6Q1SbVEzWouPFjMfGXIh(dMwtJ)7wczuy9u9VsIffSOUAnBWRxgSRiw6B8gXQGfByEJnkDvnbAeBJnqchMl6pyASvGyIfKJX)DwG)onMomXIP9lSZYHz5sw2GAFyb9d6lctOLfKgdKyUzGf4WYdzjAGbwqVv6dlOFqFryYyZd)btJntJ)7gVrSkOsgM3yJsxvtGgX2ydKWH5I(dMgBfaxR)9zzS5H)GPX2SYQh(dMv9HFJn9H)A6LKXwZ16FFwgVXBSfnuawQ6VH5nILsgM3yZd)btJnGUeCiWko6M7XgBu6QAc0i2gVrSaOH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgBfBSbs4WCr)btJnZVtSGWNZv1elhMfm9S8qwkMft3VZsczb)(ZcmzzHjw(5sGOhJwwuIft7uYYVtS0Ub)SatILdZcmzzHj0Ycaz5AS87elykatqwomlEcYsbz5ASOc)Dw8Hm2q4tn9sYydM1fMQ)Cjq0B8gXQGgM3yJsxvtGgX2ydgzS5GGgBE4pyASHWNZv1KXgcxViJnLm2cZ90CUX2pxce92xj7c7QAIffS8ZLarV9vYgGqni0uAbxJ)hmn2q4tn9sYydM1fMQ)Cjq0B8gXYCmmVXgLUQManITXgmYyZbbn28WFW0ydHpNRQjJneUErgBa0ylm3tZ5gB)Cjq0BFaAxyxvtSOGLFUei6TpaTbiudcnLwW14)btJne(utVKm2GzDHP6pxce9gVrSqJH5n2O0v1eOrSn2GrgBoiOXMh(dMgBi85CvnzSHWNA6LKXgmRlmv)5sGO3ylm3tZ5gBeWDDrreO9sCywVRQPkWD55VkRGeIlqS01XcbCxxuebAPYO4d56kCatpdelDDSqa31ffrGwmCP10)xIQol14gBGeomx0FW0yZ87eMy5NlbIEml(qSKWNfF9L(FbxRJZci9u4jqwCmlWKLfMyb)(ZYpxce9yllXqBYJJzXbbVeflkXsj5jMLFNIZIPtRzX1M84ywujwIgQrZqGSCjifrjiLplWglyn8n2q46fzSPKXBelaPH5n28WFW0yRectGUS2GtPXgLUQManITXBelaLH5n2O0v1eOrSn28WFW0yZ04)UXM(sQgan2uQyJTWCpnNBS1JfkOVimz1R0NAsi7zPRJfkOVimzVSIHAFyPRJfkOVimzVSQc)Dw66yHc6lctwpJxtczpl9n2ajCyUO)GPXgaCOGJFwailihJ)7S4jilolBVp41GIybMSSzEwmD)olX6qT)SuaCIfpbzj2WyyEwGdlBVpTBiwG)onMomz8gXcqyyEJnkDvnbAeBJTWCpnNBS1JfkOVimz1R0NAsi7zPRJfkOVimzVSIHAFyPRJfkOVimzVSQc)Dw66yHc6lctwpJxtczpl9zrblrdHWQK104)olkyXmwIgcHfGwtJ)7gBE4pyASzA8F34nIfWXW8gBu6QAc0i2gBH5EAo3yZmwMvsn4GISQU2ZavHTQR11F)suylLUQMazPRJfZyjarqPNVnpu7FT5elDDSygl4isRRVpOOhBXVpnxRzrzwuILUowmJL31u(20)1q4QQR9mqwkDvnbYsxhl9yHc6lctwmu7tnjK9S01Xcf0xeMSxw1R0hw66yHc6lct2lRQWFNLUowOG(IWK1Z41Kq2ZsFJnp8hmn2WVpTBiJ3iwkvSH5n2O0v1eOrSn2cZ90CUX2SsQbhuKv11EgOkSvDTU(7xIcBP0v1eilkyjarqPNVnpu7FT5elkybhrAD99bf9yl(9P5AnlkZIsgBE4pyASHFFWRbfz8gVXBSHGg8btJybWIbOsfdOkwjJnt(KxIcBSHCedamXYCJfY5aAwyX87elxzeCEwAWHf0bsnFPF0XYqa31neilyyjXIVEyP)eilHDprrylxe6DjXI5aOzbPWebnpbYY2vIuwWXZ3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEkHS(wUi07sIfZbqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelObqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelasanlifMiO5jqw2UsKYcoE(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0dGiRVLlc9UKybqbOzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfafGMfKcte08eilO7NlbIERswaa6y5HSGUFUei6TVswaa6yPharwFlxe6DjXcGcqZcsHjcAEcKf09ZLarVfGwaa6y5HSGUFUei6TpaTaa0XspaIS(wUi07sIfabGMfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaoaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKyrPIb0SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXIskbOzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfLaiGMfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6bqK13YfHExsSOeab0SGuyIGMNazbD)Cjq0BvYcaqhlpKf09ZLarV9vYcaqhl9aiY6B5IqVljwucGaAwqkmrqZtGSGUFUei6Ta0caqhlpKf09ZLarV9bOfaGow6PeY6B5IqVljwuQGaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPharwFlxe6DjXIsfeqZcsHjcAEcKf09ZLarVvjlaaDS8qwq3pxce92xjlaaDS0tjK13YfHExsSOubb0SGuyIGMNazbD)Cjq0BbOfaGowEilO7NlbIE7dqlaaDS0dGiRVLlIlc5igayIL5glKZb0SWI53jwUYi48S0GdlOlAOaSu1F0XYqa31neilyyjXIVEyP)eilHDprrylxe6DjXsbb0SGuyIGMNazbD)Cjq0BvYcaqhlpKf09ZLarV9vYcaqhl9aiY6B5IqVljwmhanlifMiO5jqwq3pxce9waAbaOJLhYc6(5sGO3(a0caqhl9aiY6B5IqVljwaoaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKyrPIb0SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxexeYrmaWelZnwiNdOzHfZVtSCLrW5zPbhwqNdj0XYqa31neilyyjXIVEyP)eilHDprrylxe6DjXIsaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yXFwqFa8Ohl9ucz9TCrO3LelfeqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelasanlifMiO5jqw2UsKYcoE(oYyb5ICz5HSGElNLsi4sVWSaJOXF4WspKBFw6PeY6B5IqVljwaKaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPharwFlxe6DjXcGcqZcsHjcAEcKLTRePSGJNVJmwqUixwEilO3YzPecU0lmlWiA8hoS0d52NLEkHS(wUi07sIfafGMfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaeaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKyb4aOzbPWebnpbYY2vIuwWXZ3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEaez9TCrO3LelkbqanlifMiO5jqw2UsKYcoE(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0tjK13YfHExsSOeWbqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelaujanlifMiO5jqw2UsKYcoE(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0tjK13YfHExsSaWccOzbPWebnpbYY2vIuwWXZ3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEaez9TCrO3LelaSGaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKybGObqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelaeqcOzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfacia0SGuyIGMNazz7krkl4457iJfKllpKf0B5SaEio8btwGr04pCyPhs6ZspaIS(wUi07sIfacCa0SGuyIGMNazz7krkl4457iJfKllpKf0B5SaEio8btwGr04pCyPhs6ZspLqwFlxexeYrmaWelZnwiNdOzHfZVtSCLrW5zPbhwqxZ16FFwOJLHaURBiqwWWsIfF9Ws)jqwc7EIIWwUi07sIfacOzbPWebnpbYY2vIuwWXZ3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEkHS(wUiUiKJyaGjwMBSqohqZclMFNy5kJGZZsdoSGo8Jowgc4UUHazbdljw81dl9NazjS7jkcB5IqVljwucqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelfeqZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrO3LelkPeGMfKcte08eilBxjszbhpFhzSGCrUS8qwqVLZsjeCPxywGr04pCyPhYTpl9ucz9TCrO3LelkPeGMfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwucqcOzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfaQeGMfKcte08eilBxjszbhpFhzSGCz5HSGElNfWdXHpyYcmIg)Hdl9qsFw6bqK13YfHExsSaqLa0SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcabiGMfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaybb0SGuyIGMNazz7krkl4457iJfKllpKf0B5SaEio8btwGr04pCyPhs6ZsVcIS(wUi07sIfaAoaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPharwFlxe6DjXcabKaAwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKybGakanlifMiO5jqwq3SsQbhuKfaGowEilOBwj1GdkYcaSu6QAceDS0tjK13YfXfHCedamXYCJfY5aAwyX87elxzeCEwAWHf0Pc9hDSmeWDDdbYcgwsS4Rhw6pbYsy3tue2YfHExsSOeGaqZcsHjcAEcKLTRePSGJNVJmwqUS8qwqVLZc4H4WhmzbgrJ)WHLEiPpl9kiY6B5IqVljwuc4aOzbPWebnpbYY2vIuwWXZ3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEkHS(wUiUiZTmcopbYcGKfp8hmzrF4hB5Im2Igy70KXgYJ8SeBx7zGyPaoRdKlc5rEwkAPJZcGeTSaWIbOsCrCripYZcs39efHb0CripYZcaILyacsGSSb1(WsSjV0YfH8iplaiwq6UNOiqwEFqrF9ASeCmHz5HSeIh0u99bf9ylxeYJ8SaGybadvcrqGSSYKceg7tCwq4Z5QAcZsVZsw0Ys0qiQ43h8AqrSaGkKLOHqyXVp41GI6B5IqEKNfaelXab8azjAOGJ)lrXcYX4)olxJL7rhMLFNyX0atuSG(b9fHjlxeYJ8SaGybaRdeXcsHjciqel)oXYw0n3JzXzrF)RjwkHdXstti7u1el9UglXHlw2DWeDpl73ZY9SGVYL(9KGlSoolMUFNLydGpgMNfaZcsjnH)Z1Sed9HklP8rll3JoqwWaDr9TCripYZcaIfaSoqelLq8Zc6AhQ9VouPFjgDSGdu6ZbXS4rr64S8qwuHymlTd1(JzbM64wUiUiKh5zjgzcF)jqwITR9mqSedai6XsWtwujwAWvcYI)SS)FegqJeKO6ApdeacFLblQ73xQ2dIKy7ApdeaA7krkskbT7FPg5STttkR6ApdK9r2ZfXf5H)Gj2gnuawQ6VYaDj4qGvC0n3J5IqEwm)oXccFoxvtSCywW0ZYdzPywmD)oljKf87plWKLfMy5NlbIEmAzrjwmTtjl)oXs7g8ZcmjwomlWKLfMqllaKLRXYVtSGPambz5WS4jilfKLRXIk83zXhIlYd)btSnAOaSu1FaRmsq4Z5QAcTPxskdZ6ct1FUei6rlcxViLlMlYd)btSnAOaSu1FaRmsq4Z5QAcTPxskdZ6ct1FUei6rlmszheeTiC9Iuwj0EnL)5sGO3QKDHDvnP4NlbIERs2aeQbHMsl4A8)GjxKh(dMyB0qbyPQ)awzKGWNZv1eAtVKugM1fMQ)Cjq0JwyKYoiiAr46fPmar71u(NlbIElaTlSRQjf)Cjq0BbOnaHAqOP0cUg)pyYfH8Sy(DctS8ZLarpMfFiws4ZIV(s)VGR1XzbKEk8eiloMfyYYctSGF)z5NlbIESLLyOn5XXS4GGxIIfLyPK8eZYVtXzX0P1S4AtECmlQelrd1OziqwUeKIOeKYNfyJfSg(CrE4pyITrdfGLQ(dyLrccFoxvtOn9sszywxyQ(ZLarpAHrk7GGOfHRxKYkH2RPmbCxxuebAVehM17QAQcCxE(RYkiH4cuxhbCxxuebAPYO4d56kCatpduxhbCxxuebAXWLwt)FjQ6SuJZf5H)Gj2gnuawQ6pGvgjLqyc0L1gCk5IqEwaGdfC8Zcazb5y8FNfpbzXzz79bVguelWKLnZZIP73zjwhQ9NLcGtS4jilXggdZZcCyz79PDdXc83PX0HjUip8hmX2OHcWsv)bSYiX04)oA1xs1aOYkvmAVMY9OG(IWKvVsFQjHSVRJc6lct2lRyO2NUokOVimzVSQc)9UokOVimz9mEnjK995I8WFWeBJgkalv9hWkJetJ)7O9Ak3Jc6lctw9k9PMeY(UokOVimzVSIHAF66OG(IWK9YQk8376OG(IWK1Z41Kq23xr0qiSkznn(VRWSOHqybO104)oxKh(dMyB0qbyPQ)awzKGFFA3qO9AkB2SsQbhuKv11EgOkSvDTU(7xIc31zwaIGspFBEO2)AZPUoZWrKwxFFqrp2IFFAUwRSsDDM9UMY3M(VgcxvDTNbYsPRQjWUUEuqFryYIHAFQjHSVRJc6lct2lR6v6txhf0xeMSxwvH)Exhf0xeMSEgVMeY((CrE4pyITrdfGLQ(dyLrc(9bVgueAVMYZkPgCqrwvx7zGQWw1166VFjkSIaebLE(28qT)1MtkWrKwxFFqrp2IFFAUwRSsCrCripYZc6JmkSEcKfcbnXz5VsILFNyXdpCy5WS4i8t7QAYYf5H)Gjwzmu7tvL8sUiKNLn6XSedi6ZcmzPGaMft3VdxplGZ1Ew8eKft3VZY27JgoGS4jilaeWSa)DAmDyIlYd)btmGvgji85CvnH20ljLpC1HeAr46fPmoI0667dk6Xw87tZ16cvsrpZExt5BXVpA4aAP0v1eyx37AkFl(jT2Nk4CT3sPRQjW(DD4isRRVpOOhBXVpnxRleGCriplB0JzjOjhbXIPDkzz79PDdXsWtw2VNfacywEFqrpMft7xyNLdZYqAcHNpln4WYVtSG(b9fHjwEilQelrd1Oziqw8eKft7xyNL2P10WYdzj44NlYd)btmGvgji85CvnH20ljLpCnOjhbHweUErkJJiTU((GIESf)(0UHkujUiKNLcetSeBAW0a0LOyX097SG0yGeZndSahw82tdlifMiGarSCjlingiXCZaxKh(dMyaRmsuPbtdqxIcTxt5EMfGiO0Z3MhQ9V2CQRZSaeQbHMsBaMiGar1FNQ4OBUhBxr9vOUAnBWRxgSdv6xIluj0OqD1A2XrqjCHRTHYyg3ouPFjgyMJcZcqeu65Brq5VhF66cqeu65Brq5VhFuOUAnBWRxgSRifQRwZoockHlCTnugZ42vKIEQRwZoockHlCTnugZ42Hk9lXatjLaqOb4Nvsn4GIS4lBlDDpo(P58Uo1vRzdE9YGDOs)smWusPUoLqU4isRR7o(jGPKfnOPpxeYZcae(Sy6(DwCwqAmqI5Mbw(D)z5Wj6EwCwaGln2hwIgyGf4WIPDkz53jwAhQ9NLdZIRcxplpKfkb5I8WFWedyLrse8pyI2RPS6Q1SbVEzWouPFjUqLqJIEMnRKAWbfzXx2w66EC8tZ5DDQRwZoockHlCTnugZ42Hk9lXatjaLc1vRzhhbLWfU2gkJzC7kQFxNkeJv0ou7FDOs)smWaiA4IqEwqQRdlT)eMft70Vtdll8LOybPWebeiILeAIftNwZIR1qtSehUy5HSG)tRzj44NLFNyb7LelEjCLplWglifMiGaragPXajMBgyj44hZf5H)GjgWkJee(CUQMqB6LKYbyIacevbjC8mGweUErkhOt3Rx7qT)1Hk9lXaiLqdakaHAqOP0g86Lb7qL(L4(ixLaef3x5aD6E9AhQ9VouPFjgaPeAaqkbWIbqbiudcnL2amrabIQ)ovXr3Cp2ouPFjUpYvjarX9vy24hyLqq5BDqqSLq2HFCxxac1GqtPn41ld2Hk9lXfE5tteu7pbwBhQ9VouPFjURlaHAqOP0gGjciqu93Pko6M7X2Hk9lXfE5tteu7pbwBhQ9VouPFjgaPuXDDMfGiO0Z3MhQ9V2CQRZd)btBaMiGar1FNQ4OBUhBbpSRQjqUiKNLcetGS8qwajThNLFNyzHDuelWglingiXCZalM2PKLf(suSacxQAIfyYYctS4jilrdHGYNLf2rrSyANsw8KfheKfcbLplhMfxfUEwEilGhXf5H)GjgWkJee(CUQMqB6LKYbWAaMG3FWeTiC9IuU37dk6T)vs1hwbpQqLqtx34hyLqq5BDqqS9YcrtX9v0Rxpc4UUOic0sLrXhY1v4aMEgif96fGqni0uAPYO4d56kCatpdKDOs)smWucqwCxxaIGspFlck)94JIaeQbHMslvgfFixxHdy6zGSdv6xIbMsasafG7PKsa)SsQbhuKfFzBPR7XXpnN3VVcZcqOgeAkTuzu8HCDfoGPNbYoKdgVF)UUEeWDDrreOfdxAn9)LOQZsnUIEMfGiO0Z3MhQ9V2CQRlaHAqOP0IHlTM()su1zPgVwqZbnaIIvYouPFjgykPK50VFxxpZiG76IIiq7L4WSExvtvG7YZFvwbjexG66cqOgeAkTxIdZ6DvnvbUlp)vzfKqCbYoKdgVVIEbiudcnLwvAW0a0LOSd5GX76mB8az)bQ19v0RhcFoxvtwywxyQ(ZLarVYk11HWNZv1KfM1fMQ)Cjq0RCb7RO3pxce9wLSd5GXRbiudcnLDD)Cjq0BvYgGqni0uAhQ0Vex4LpnrqT)eyTDO2)6qL(LyaKsf3VRdHpNRQjlmRlmv)5sGOxzaQO3pxce9waAhYbJxdqOgeAk76(5sGO3cqBac1GqtPDOs)sCHx(0eb1(tG12HA)Rdv6xIbqkvC)Uoe(CUQMSWSUWu9NlbIELlUF)UUaebLE(wGIpNN95I8WFWedyLrccFoxvtOn9ss5FFoTUIjciAQM87rlcxViLnddxA1lbT)(CADfteq0yP0v1eyxx7qT)1Hk9lXfcWIlURtfIXkAhQ9VouPFjgyaenaUN5umasD1A2FFoTUIjciAS43dab8aSFxN6Q1S)(CADfteq0yXVhaQWcciaq9Mvsn4GIS4lBlDDpo(P5CGhn95IqEwkqmXc6xgfFixZca(bm9mqSaWIXuaZIk1GdXIZcsJbsm3mWYctwUip8hmXawzKSWu9EQeTPxsktLrXhY1v4aMEgi0EnLdqOgeAkTbVEzWouPFjgyaSyfbiudcnL2amrabIQ)ovXr3Cp2ouPFjgyaSyf9q4Z5QAY(7ZP1vmrart1KFFxN6Q1S)(CADfteq0yXVhaQWcwmG7nRKAWbfzXx2w66EC8tZ5apGSF)UovigRODO2)6qL(LyGvqafxeYZsbIjw2GlTM(lrXcaMLACwaKykGzrLAWHyXzbPXajMBgyzHjlxKh(dMyaRmswyQEpvI20ljLXWLwt)FjQ6SuJJ2RPCac1GqtPn41ld2Hk9lXadqQWSaebLE(weu(7XhfMfGiO0Z3MhQ9V2CQRlarqPNVnpu7FT5KIaeQbHMsBaMiGar1FNQ4OBUhBhQ0VedmaPIEi85CvnzdWebeiQcs44zORlaHAqOP0g86Lb7qL(LyGbi731fGiO0Z3IGYFp(OONzZkPgCqrw8LTLUUhh)0CUIaeQbHMsBWRxgSdv6xIbgGSRtD1A2XrqjCHRTHYyg3ouPFjgykzoaUhAaEc4UUOic0Ej(Nv4HdUcEiUKQQKw3xH6Q1SJJGs4cxBdLXmUDf1VRtfIXkAhQ9VouPFjgyaenCrE4pyIbSYizHP69ujAtVKu(sCywVRQPkWD55VkRGeIlqO9AkRUAnBWRxgSdv6xIluj0OONzZkPgCqrw8LTLUUhh)0CExN6Q1SJJGs4cxBdLXmUDOs)smWucGaUxbbE1vRzv1qiOEHF7kQpG71dqbGqdWRUAnRQgcb1l8Bxr9bEc4UUOic0Ej(Nv4HdUcEiUKQQKw3xH6Q1SJJGs4cxBdLXmUDf1VRtfIXkAhQ9VouPFjgyaenCriplMF)WSCywCwg)3PHfs7QWXFIftECwEilLoqelUwZcmzzHjwWV)S8ZLarpMLhYIkXI(scKLvelMUFNfKgdKyUzGfpbzbPWebeiIfpbzzHjw(DIfaMGSG1WNfyYsaKLRXIk83z5NlbIEml(qSatwwyIf87pl)Cjq0J5I8WFWedyLrYct17PsmAXA4Jv(NlbIELq71ugHpNRQjlmRlmv)5sGOxzaQWSFUei6Ta0oKdgVgGqni0u211dHpNRQjlmRlmv)5sGOxzL66q4Z5QAYcZ6ct1FUei6vUG9v0tD1A2GxVmyxrk6zwaIGspFlck)94txN6Q1SJJGs4cxBdLXmUDOs)smG7HgGFwj1GdkYIVST01944NMZ7dmL)5sGO3QKvD1AvW14)btfQRwZoockHlCTnugZ42vuxN6Q1SJJGs4cxBdLXmEfFzBPR7XXpnNBxr976cqOgeAkTbVEzWouPFjgWaSWFUei6TkzdqOgeAkTGRX)dMk6zwaIGspFBEO2)AZPUoZq4Z5QAYgGjciqufKWXZqFfMfGiO0Z3cu858SRlarqPNVnpu7FT5Kce(CUQMSbyIacevbjC8mOiaHAqOP0gGjciqu93Pko6M7X2vKcZcqOgeAkTbVEzWUIu0RN6Q1SuqFryQQxPp2Hk9lXfQuXDDQRwZsb9fHPkgQ9XouPFjUqLkUVcZMvsn4GISQU2ZavHTQR11F)su4UUEQRwZQ6Apduf2QUwx)9lrHRP)RHS43daPmA66uxTMv11EgOkSvDTU(7xIcx9j4jzXVhaszar)(DDQRwZc0LGdbwPYiOjAkP8RusdQlMKDf1VRtfIXkAhQ9VouPFjgyaS4Uoe(CUQMSWSUWu9NlbIELlMlYd)btmGvgjlmvVNkXOfRHpw5FUei6biAVMYi85CvnzHzDHP6pxce9MPmavy2pxce9wLSd5GXRbiudcnLDDi85CvnzHzDHP6pxce9kdqf9uxTMn41ld2vKIEMfGiO0Z3IGYFp(01PUAn74iOeUW12qzmJBhQ0Ved4EOb4Nvsn4GIS4lBlDDpo(P58(at5FUei6Ta0QUATk4A8)GPc1vRzhhbLWfU2gkJzC7kQRtD1A2XrqjCHRTHYygVIVST01944NMZTRO(DDbiudcnL2GxVmyhQ0Vedyaw4pxce9waAdqOgeAkTGRX)dMk6zwaIGspFBEO2)AZPUoZq4Z5QAYgGjciqufKWXZqFfMfGiO0Z3cu858urpZuxTMn41ld2vuxNzbick98TiO83Jp976cqeu65BZd1(xBoPaHpNRQjBaMiGarvqchpdkcqOgeAkTbyIacev)DQIJU5ESDfPWSaeQbHMsBWRxgSRif96PUAnlf0xeMQ6v6JDOs)sCHkvCxN6Q1SuqFryQIHAFSdv6xIluPI7RWSzLudoOiRQR9mqvyR6AD93VefURRN6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqkJMUo1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGugq0VF)Uo1vRzb6sWHaRuze0enLu(vkPb1ftYUI66uHySI2HA)Rdv6xIbgalURdHpNRQjlmRlmv)5sGOx5I5IqEwkqmHzX1AwG)onSatwwyIL7PsmlWKLaixKh(dMyaRmswyQEpvI5IqEwkGu4ajw8WFWKf9HFwuDmbYcmzbF)Y)dMirtOomxKh(dMyaRmsMvw9WFWSQp8J20ljLDiHw8px4vwj0EnLr4Z5QAYE4QdjUip8hmXawzKmRS6H)GzvF4hTPxskRc9hT4FUWRSsO9AkpRKAWbfzvDTNbQcBvxRR)(LOWwc4UUOicKlYd)btmGvgjZkRE4pyw1h(rB6LKY4NlIlc5zbPUoS0(tywmTt)onS87elfWH8YG)HDAyrD1ASy60AwAUwZcS1yX097xYYVtSKeYEwco(5I8WFWeBDiPmcFoxvtOn9sszWH8YQPtRRnxRRWwdTiC9IuUN6Q1S)vsMGtwbhYlvVeKg7qL(LyGHkaAlDKb4ITk11PUAn7FLKj4KvWH8s1lbPXouPFjgyE4pyAXVpTBilHmkSEQ(xjb4ITkPOhf0xeMSxw1R0NUokOVimzXqTp1Kq231rb9fHjRNXRjHSVFFfQRwZ(xjzcozfCiVu9sqASRifZkPgCqr2)kjtWjRGd5LQxcsdxeYZcsDDyP9NWSyAN(DAyz79bVguelhMftW53zj44)suSarqdlBVpTBiwUKf0BL(Wc6h0xeM4I8WFWeBDibyLrccFoxvtOn9ss5dvchQIFFWRbfHweUErkBgf0xeMSxwXqTpk6HJiTU((GIESf)(0UHkenkExt5BXWLUcB1FNQn4q43sPRQjWUoCeP113hu0JT43N2nuHaQ(CriplfiMybPWebeiIft7uYI)SOjmMLF3twqtXSedmaKfpbzrFjXYkIft3VZcsJbsm3mWf5H)Gj26qcWkJKamrabIQ)ovXr3CpgTxtzZaN1bAtynaIv0RhcFoxvt2amrabIQGeoEguywac1GqtPn41ld2HCW4DDQRwZg86Lb7kQVIEQRwZsb9fHPQEL(yhQ0VexiGSRtD1AwkOVimvXqTp2Hk9lXfci7RONzZkPgCqrwvx7zGQWw1166VFjkCxN6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqfwWUo1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGkSG976uHySI2HA)Rdv6xIbMsfRWSaeQbHMsBWRxgSd5GX7ZfH8SuGyILcWqzmJZIP73zbPXajMBg4I8WFWeBDibyLrY4iOeUW12qzmJJ2RPS6Q1SbVEzWouPFjUqLqdxeYZsbIjw2wz7gILlzjYtqQ8cSatw8m(VFjkw(D)zrFiimlkzoykGzXtqw0egZIP73zPeoelVpOOhZINGS4pl)oXcLGSaBS4SSb1(Wc6h0xeMyXFwuYCybtbmlWHfnHXSmuPF5LOyXXS8qws4ZYUJ4suS8qwgQneENfW1CjkwqVv6dlOFqFryIlYd)btS1HeGvgj4v2UHqBiEqt13hu0Jvwj0EnL7nuBi8URQPUo1vRzPG(IWufd1(yhQ0VedScQGc6lct2lRyO2hfdv6xIbMsMJI31u(wmCPRWw93PAdoe(Tu6QAcSVI3hu0B)RKQpScEuHkzoaiCeP113hu0Jb8qL(Lyf9OG(IWK9YQNX76gQ0VedmubqBPJS(CripliNikILvelBVpnxRzXFwCTML)kjmlRutymll8LOyb9Ih8XXS4jil3ZYHzXvHRNLhYs0adSahw00ZYVtSGJOW5Aw8WFWKf9LelQKgAILDpb1elfWH8s1lbPHfyYcaz59bf9yUip8hmXwhsawzKGFFAUwJ2RPSzVRP8T4N0AFQGZ1ElLUQMav0tD1Aw87tZ1A7qTHW7UQMu0dhrAD99bf9yl(9P5AnWkyxNzZkPgCqr2)kjtWjRGd5LQxcst)UU31u(wmCPRWw93PAdoe(Tu6QAcuH6Q1SuqFryQIHAFSdv6xIbwbvqb9fHj7Lvmu7Jc1vRzXVpnxRTdv6xIbgGsboI0667dk6Xw87tZ16cv2C6RONzZkPgCqrwD8GpoU20e9xIQIsFLryQR7Vsc5ICnh0uO6Q1S43NMR12Hk9lXagG9v8(GIE7FLu9HvWJkenCriplih3VZY2tATpSuaNR9SSWelWKLailM2PKLHAdH3DvnXI66zb)NwZIj)EwAWHf0lEWhhZs0adS4jilGWeDpllmXIk1GdXcslGyllB)P1SSWelQudoelifMiGarSGVmqS87(ZIPtRzjAGbw8e(70WY27tZ1AUip8hmXwhsawzKGFFAUwJ2RP87AkFl(jT2Nk4CT3sPRQjqfQRwZIFFAUwBhQneE3v1KIEMnRKAWbfz1Xd(44Att0FjQkk9vgHPUU)kjKlY1CqtHMtFfVpOO3(xjvFyf8OclixeYZcYX97SuahYlvVeKgwwyILT3NMR1S8qwaIOiwwrS87elQRwJf14S4AmKLf(suSS9(0CTMfyYcAybtbycIzboSOjmMLHk9lVefxKh(dMyRdjaRmsWVpnxRr71uEwj1GdkY(xjzcozfCiVu9sqAuGJiTU((GIESf)(0CTUqLlOIEMPUAn7FLKj4KvWH8s1lbPXUIuOUAnl(9P5ATDO2q4DxvtDD9q4Z5QAYcoKxwnDADT5ADf2Ak6PUAnl(9P5ATDOs)smWkyxhoI0667dk6Xw87tZ16cbOI31u(w8tATpvW5AVLsxvtGkuxTMf)(0CT2ouPFjgyOPF)(Cripli11HL2FcZIPD63PHfNLT3h8AqrSSWelMoTMLGVWelBVpnxRz5HS0CTMfyRHww8eKLfMyz79bVguelpKfGikILc4qEP6LG0Wc(9aqSSI4I8WFWeBDibyLrccFoxvtOn9ssz87tZ16Qjy(1MR1vyRHweUErk74FCDncAIMcbefdG6PuXaV6Q1S)vsMGtwbhYlvVeKgl(9aq9bq9uxTMf)(0CT2ouPFjg4liYfhrADD3Xpb8M9UMY3IFsR9Pcox7Tu6QAcSpaQxac1GqtPf)(0CT2ouPFjg4liYfhrADD3Xpb8VRP8T4N0AFQGZ1ElLUQMa7dG6bcFBBnXRWwL0RKSdv6xIbE00xrp1vRzXVpnxRTROUUaeQbHMsl(9P5ATDOs)sCFUiKNLcetSS9(GxdkIft3VZsbCiVu9sqAy5HSaerrSSIy53jwuxTglMUFhUEw0q8LOyz79P5AnlRO)kjw8eKLfMyz79bVguelWKfZbWSeBymmpl43daHzzL)PzXCy59bf9yUip8hmXwhsawzKGFFWRbfH2RPmcFoxvtwWH8YQPtRRnxRRWwtbcFoxvtw87tZ16Qjy(1MR1vyRPWme(CUQMShQeouf)(GxdkQRRN6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqfwWUo1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGkSG9vGJiTU((GIESf)(0CTgyMJce(CUQMS43NMR1vtW8RnxRRWwJlc5zPaXelyt(uYcgYYV7plXHlwqrplLoYyzf9xjXIACww4lrXY9S4yw0(tS4ywIGy8PQjwGjlAcJz539KLcYc(9aqywGdla4SWplM2PKLccywWVhacZcHSOBiUip8hmXwhsawzK4GE0FiOk2KpLOnepOP67dk6XkReAVMYM9xaOlrPWmp8hmToOh9hcQIn5tzf0lDuK9YAtFO2)Uoq4BDqp6peufBYNYkOx6Oil(9aqaRGkaHV1b9O)qqvSjFkRGEPJISdv6xIbwb5IqEwaWqTHW7SaGfcZ2nelxJfKgdKyUzGLdZYqoyC0YYVtdXIpelAcJz539Kf0WY7dk6XSCjlO3k9Hf0pOVimXIP73zzd(fa0YIMWyw(DpzrPIzb(70y6WelxYINXzb9d6lctSahwwrS8qwqdlVpOOhZIk1GdXIZc6TsFyb9d6lctwwkGWeDpld1gcVZc4AUefliNUeCiqwq)YiOjAkP8zzLAcJz5sw2GAFyb9d6lctCrE4pyIToKaSYiPecZ2neAdXdAQ((GIESYkH2RP8qTHW7UQMu8(GIE7FLu9HvWJkSxpLmha3dhrAD99bf9yl(9PDdb8ae4vxTMLc6lctv9k9XUI63hWdv6xI7JC7PeGFxt5BFtxwlHWeBP0v1eyFf9cqOgeAkTbVEzWoKdgxHzGZ6aTjSgaXk6HWNZv1KnateqGOkiHJNHUUaeQbHMsBaMiGar1FNQ4OBUhBhYbJ31zwaIGspFBEO2)AZP(DD4isRRVpOOhBXVpTBiG1RhGea1tD1AwkOVimv1R0h7kc4by)(aFpLa87AkF7B6YAjeMylLUQMa73xHzuqFryYIHAFQjHSVRRhf0xeMSxwXqTpDD9OG(IWK9YQk8376OG(IWK9YQEL(0xHzVRP8Ty4sxHT6Vt1gCi8BP0v1eyxN6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lQqLbiAkUVIE4isRRVpOOhBXVpTBiGPuXaFpLa87AkF7B6YAjeMylLUQMa73xHJ)X11iOjAkenfdGuxTMf)(0CT2ouPFjg4bK9v0Zm1vRzb6sWHaRuze0enLu(vkPb1ftYUI66OG(IWK9YkgQ9PRZSaebLE(wGIpNN9vyM6Q1SJJGs4cxBdLXmEfFzBPR7XXpnNBxrCriplfiMyPaaJflWKLailMUFhUEwcEu0LO4I8WFWeBDibyLrsdobQcB10)1qO9Ak7r1WofaIlYd)btS1HeGvgji85CvnH20ljLdG1ambV)Gz1HeAr46fPSzGZ6aTjSgaXkq4Z5QAYgaRbycE)btf96PUAnl(9P5ATDf1117DnLVf)Kw7tfCU2BP0v1eyxxaIGspFBEO2)AZP(9v0Zm1vRzXqn(VazxrkmtD1A2GxVmyxrk6z27AkFBBnXRWwL0RKSu6QAcSRtD1A2GxVmybxJ)hmlmaHAqOP02wt8kSvj9kj7qL(Lyadi6RaHpNRQj7VpNwxXebenvt(9k6zwaIGspFBEO2)AZPUUaeQbHMsBaMiGar1FNQ4OBUhBxrk6PUAnl(9P5ATDOs)smWayxNzVRP8T4N0AFQGZ1ElLUQMa73xX7dk6T)vs1hwbpQq1vRzdE9YGfCn(FWe4l2cO631PcXyfTd1(xhQ0Vedm1vRzdE9YGfCn(FWSpxeYZsbIjwqAmqI5MbwGjlbqwwPMWyw8eKf9Lel3ZYkIft3VZcsHjciqexKh(dMyRdjaRmscKMW)56QRpuzjLpAVMYi85CvnzdG1ambV)Gz1HexKh(dMyRdjaRmsUm4t6)bt0EnLr4Z5QAYgaRbycE)bZQdjUiKNLcetSG(Lrqt0WsSHjilWKLailMUFNLT3NMR1SSIyXtqwWocILgCybaU0yFyXtqwqAmqI5MbUip8hmXwhsawzKqLrqt0uvHjiAVMYQqmwXLpnrqT)eyTDO2)6qL(LyGPeA666PUAnB0CLWb8CD1NGNxOgT0yFSiC9IagartXDDQRwZgnxjCapxx9j45fQrln2hlcxVOcvgGOP4(kuxTMf)(0CT2UIu0laHAqOP0g86Lb7qL(L4crtXDDGZ6aTjSgaX95IqEwaWqTHW7S00(qSatwwrS8qwkilVpOOhZIP73HRNfKgdKyUzGfv6suS4QW1ZYdzHqw0nelEcYscFwGiOj4rrxIIlYd)btS1HeGvgj4N0AFQnTpeAdXdAQ((GIESYkH2RP8qTHW7UQMu8xjvFyf8OcvcnkWrKwxFFqrp2IFFA3qaZCu4r1Wofasrp1vRzdE9YGDOs)sCHkvCxNzQRwZg86Lb7kQpxeYZsbIjwkaq0NLRXYL4dKyXtwq)G(IWelEcYI(sIL7zzfXIP73zXzbaU0yFyjAGbw8eKLya6r)HGyzZKpLCrE4pyIToKaSYiPTM4vyRs6vsO9Aktb9fHj7LvpJRWJQHDkaKc1vRzJMReoGNRR(e88c1OLg7JfHRxeWaiAkwrpq4BDqp6peufBYNYkOx6Oi7FbGUevxNzbick98TjfgOgoGDD4isRRVpOOhxia7RON6Q1SJJGs4cxBdLXmUDOs)smWaoaOEOb4Nvsn4GIS4lBlDDpo(P58(kuxTMDCeucx4ABOmMXTROUoZuxTMDCeucx4ABOmMXTRO(k6zwac1GqtPn41ld2vuxN6Q1S)(CADfteq0yXVhacykHgfTd1(xhQ0VedmawCXkAhQ9VouPFjUqLkU4UoZWWLw9sq7VpNwxXebenwkDvnb2Nlc5zPaXelolBVpnxRzbaFs)olrdmWYk1egZY27tZ1AwomlUEihmolRiwGdlXHlw8HyXvHRNLhYcebnbpILyGbGCrE4pyIToKaSYib)(0CTgTxtz1vRzHj974Aenbk6pyAxrk6PUAnl(9P5ATDO2q4DxvtDDo(hxxJGMOPqGtX95IqEwkGRYiwIbgaYIk1GdXcsHjciqelMUFNLT3NMR1S4jil)oLSS9(GxdkIlYd)btS1HeGvgj43NMR1O9AkhGiO0Z3MhQ9V2CsHzVRP8T4N0AFQGZ1ElLUQMav0dHpNRQjBaMiGarvqchpdDDbiudcnL2GxVmyxrDDQRwZg86Lb7kQVIaeQbHMsBaMiGar1FNQ4OBUhBhQ0VedmubqBPJmGpqNUNJ)X11iOjAqUOP4(kuxTMf)(0CT2ouPFjgyMJcZaN1bAtynaI5I8WFWeBDibyLrc(9bVgueAVMYbick98T5HA)RnNu0dHpNRQjBaMiGarvqchpdDDbiudcnL2GxVmyxrDDQRwZg86Lb7kQVIaeQbHMsBaMiGar1FNQ4OBUhBhQ0VedmaPc1vRzXVpnxRTRifuqFryYEz1Z4kmdHpNRQj7HkHdvXVp41GIuyg4SoqBcRbqmxeYZsbIjw2EFWRbfXIP73zXtwaWN0VZs0adSahwUglXHl0bYcebnbpILyGbGSy6(DwIdxdljHSNLGJFllXqJHSaUkJyjgyail(ZYVtSqjilWgl)oXcaUu(7XhwuxTglxJLT3NMR1SycU0Gj6EwAUwZcS1yboSehUyXhIfyYcaz59bf9yUip8hmXwhsawzKGFFWRbfH2RPS6Q1SWK(DCnOjFQio8bt7kQRRNz43N2nK1JQHDkaKcZq4Z5QAYEOs4qv87dEnOOUUEQRwZg86Lb7qL(LyGHgfQRwZg86Lb7kQRRxp1vRzdE9YGDOs)smWqfaTLoYa(aD6Eo(hxxJGMOb5wWI7RqD1A2GxVmyxrDDQRwZoockHlCTnugZ4v8LTLUUhh)0CUDOs)smWqfaTLoYa(aD6Eo(hxxJGMOb5wWI7RqD1A2XrqjCHRTHYygVIVST01944NMZTRO(kcqeu65Brq5VhF63xrpCeP113hu0JT43NMR1aRGDDi85CvnzXVpnxRRMG5xBUwxHTw)(kmdHpNRQj7HkHdvXVp41GIu0ZSzLudoOi7FLKj4KvWH8s1lbPPRdhrAD99bf9yl(9P5AnWkyFUiKNLcetSaGfctmlxYYgu7dlOFqFryIfpbzb7iiwkalTMfaSqyYsdoSG0yGeZndCrE4pyIToKaSYijjt1simr71uUN6Q1SuqFryQIHAFSdv6xIlKqgfwpv)RK666f29bfHvgGkgkS7dkQ(xjbm00VRlS7dkcRCb7RWJQHDkaexKh(dMyRdjaRms2DDRwcHjAVMY9uxTMLc6lctvmu7JDOs)sCHeYOW6P6FLuxxVWUpOiSYauXqHDFqr1)kjGHM(DDHDFqryLlyFfEunStbGu0tD1A2XrqjCHRTHYyg3ouPFjgyOrH6Q1SJJGs4cxBdLXmUDfPWSzLudoOil(Y2sx3JJFAoVRZm1vRzhhbLWfU2gkJzC7kQpxKh(dMyRdjaRmsAlTUwcHjAVMY9uxTMLc6lctvmu7JDOs)sCHeYOW6P6FLKIEbiudcnL2GxVmyhQ0VexiAkURlaHAqOP0gGjciqu93Pko6M7X2Hk9lXfIMI7311lS7dkcRmavmuy3huu9VscyOPFxxy3huew5c2xHhvd7uaif9uxTMDCeucx4ABOmMXTdv6xIbgAuOUAn74iOeUW12qzmJBxrkmBwj1GdkYIVST01944NMZ76mtD1A2XrqjCHRTHYyg3UI6ZfH8SuGyIfKdi6ZcmzbPfqUip8hmXwhsawzKyYN5Gtf2QKELexeYZcsDDyP9NWSyAN(DAy5HSSWelBVpTBiwUKLnO2hwmTFHDwoml(ZcAy59bf9yaReln4WcHGM4SaWIrUSu64NM4Sahwmhw2EFWRbfXc6xgbnrtjLpl43daH5I8WFWeBDibyLrccFoxvtOn9ssz87t7gQEzfd1(GweUErkJJiTU((GIESf)(0UHk0CaCtdHtVsh)0eVIW1lc4vQ4IrUaS4(aUPHWPN6Q1S43h8AqrvQmcAIMsk)kgQ9XIFpaeY1C6ZfH8SGuxhwA)jmlM2PFNgwEilihJ)7SaUMlrXsbyOmMX5I8WFWeBDibyLrccFoxvtOn9ssztJ)71lRTHYyghTiC9IuwjKloI066UJFcyaea1Rylab(E4isRRVpOOhBXVpTBiaKs9b(Ekb431u(wmCPRWw93PAdoe(Tu6QAce4vYIM(9bCXwLqdWRUAn74iOeUW12qzmJBhQ0VeZfH8SuGyIfKJX)DwUKLnO2hwq)G(IWelWHLRXsczz79PDdXIPtRzPDplx(qwqAmqI5Mbw8mEjCiUip8hmXwhsawzKyA8FhTxt5EuqFryYQxPp1Kq231rb9fHjRNXRjHSxbcFoxvt2dxdAYrq9v079bf92)kP6dRGhvO501rb9fHjREL(uVScWUU2HA)Rdv6xIbMsf3VRtD1AwkOVimvXqTp2Hk9lXaZd)btl(9PDdzjKrH1t1)kjfQRwZsb9fHPkgQ9XUI66OG(IWK9YkgQ9rHzi85CvnzXVpTBO6Lvmu7txN6Q1SbVEzWouPFjgyE4pyAXVpTBilHmkSEQ(xjPWme(CUQMShUg0KJGuOUAnBWRxgSdv6xIbgHmkSEQ(xjPqD1A2GxVmyxrDDQRwZoockHlCTnugZ42vKce(CUQMSMg)3RxwBdLXmExNzi85CvnzpCnOjhbPqD1A2GxVmyhQ0VexiHmkSEQ(xjXfH8SuGyILT3N2nelxJLlzb9wPpSG(b9fHj0YYLSSb1(Wc6h0xeMybMSyoaML3hu0JzboS8qwIgyGLnO2hwq)G(IWexKh(dMyRdjaRmsWVpTBiUiKNLcGR1)(S4I8WFWeBDibyLrYSYQh(dMv9HF0MEjPCZ16FFwCrCriplfGHYygNft3VZcsJbsm3mWf5H)Gj2Qc9x5XrqjCHRTHYyghTxtz1vRzdE9YGDOs)sCHkHgUiKNLcetSedqp6peelBM8PKft7uYI)SOjmMLF3twmhwInmgMNf87bGWS4jilpKLHAdH3zXzbykdqwWVhaIfhZI2FIfhZseeJpvnXcCy5VsIL7zbdz5Ew8zoeeMfaCw4NfV90WIZsbbml43daXcHSOBimxKh(dMyRk0FaRmsCqp6peufBYNs0gIh0u99bf9yLvcTxtz1vRzvDTNbQcBvxRR)(LOW10)1qw87bGagGqH6Q1SQU2ZavHTQR11F)su4Qpbpjl(9aqadqOONzGW36GE0FiOk2KpLvqV0rr2)caDjkfM5H)GP1b9O)qqvSjFkRGEPJISxwB6d1(RONzGW36GE0FiOk2KpL1DY12)caDjQUoq4BDqp6peufBYNY6o5A7qL(L4cly)Uoq4BDqp6peufBYNYkOx6Oil(9aqaRGkaHV1b9O)qqvSjFkRGEPJISdv6xIbgAuacFRd6r)HGQyt(uwb9shfz)la0LO6ZfH8SuGyIfKcteqGiwmD)olingiXCZalM2PKLiigFQAIfpbzb(70y6WelMUFNfNLydJH5zrD1ASyANswajC8mCjkUip8hmXwvO)awzKeGjciqu93Pko6M7XO9AkBg4SoqBcRbqSIE9q4Z5QAYgGjciqufKWXZGcZcqOgeAkTbVEzWoKdgVRtD1A2GxVmyxr9v0tD1Awvx7zGQWw1166VFjkCn9FnKf)EaiLbeDDQRwZQ6Apduf2QUwx)9lrHR(e8KS43daPmGOFxNkeJv0ou7FDOs)smWuQ4(Criplfai6ZIJz53jwA3GFwqfaz5sw(DIfNLydJH5zX0LGqtSahwmD)ol)oXcYP4Z5jlQRwJf4WIP73zXzbqaymfyjgGE0Fiiw2m5tjlEcYIj)EwAWHfKgdKyUzGLRXY9SycMplQelRiwCu(LSOsn4qS87elbqwomlTlp8obYf5H)Gj2Qc9hWkJK2AIxHTkPxjH2RPCVE9uxTMv11EgOkSvDTU(7xIcxt)xdzXVhaQqazxN6Q1SQU2ZavHTQR11F)su4Qpbpjl(9aqfci7RONzbick98TiO83JpDDMPUAn74iOeUW12qzmJBxr97ROh4SoqBcRbqCxxac1GqtPn41ld2Hk9lXfIMI766fGiO0Z3MhQ9V2Csrac1GqtPnateqGO6VtvC0n3JTdv6xIlenf3VF)UUEGW36GE0FiOk2KpLvqV0rr2Hk9lXfciueGqni0uAdE9YGDOs)sCHkvSIaebLE(2KcdudhW(DDQqmwXLpnrqT)eyTDO2)6qL(LyGbiuywac1GqtPn41ld2HCW4DDbick98TafFopvOUAnlqxcoeyLkJGMOPKY3UI66cqeu65Brq5VhFuOUAn74iOeUW12qzmJBhQ0VedmGJc1vRzhhbLWfU2gkJzC7kIlc5zbPEginlBVpA4aYIP73zXzjjtSeBymmplQRwJfpbzbPXajMBgy5Wj6EwCv46z5HSOsSSWeixKh(dMyRk0FaRmscEgiDvD1AOn9ssz87JgoGO9Ak3tD1Awvx7zGQWw1166VFjkCn9FnKDOs)sCHaklA66uxTMv11EgOkSvDTU(7xIcx9j4jzhQ0VexiGYIM(k6fGqni0uAdE9YGDOs)sCHaQUUEbiudcnLwQmcAIMQkmbTdv6xIleqPWm1vRzb6sWHaRuze0enLu(vkPb1ftYUIueGiO0Z3cu858SFFfo(hxxJGMOPqLlyXCriplfWvzelBVp41GIWSy6(DwCwInmgMNf1vRXI66zjHplM2PKLiiuFjkwAWHfKgdKyUzGf4WcYPlbhcKLTOBUhZf5H)Gj2Qc9hWkJe87dEnOi0EnL7PUAnRQR9mqvyR6AD93VefUM(VgYIFpauHaSRtD1Awvx7zGQWw1166VFjkC1NGNKf)EaOcbyFf9cqeu65BZd1(xBo11fGqni0uAdE9YGDOs)sCHaQUoZq4Z5QAYgaRbycE)btfMfGiO0Z3cu858SRRxac1GqtPLkJGMOPQctq7qL(L4cbukmtD1AwGUeCiWkvgbnrtjLFLsAqDXKSRifbick98TafFop73xrpZaHVTTM4vyRs6vs2)caDjQUoZcqOgeAkTbVEzWoKdgVRZSaeQbHMsBaMiGar1FNQ4OBUhBhYbJ3Nlc5zPaUkJyz79bVgueMfvQbhIfKcteqGiUip8hmXwvO)awzKGFFWRbfH2RPCVaeQbHMsBaMiGar1FNQ4OBUhBhQ0Vedm0OWmWzDG2ewdGyf9q4Z5QAYgGjciqufKWXZqxxac1GqtPn41ld2Hk9lXadn9vGWNZv1KnawdWe8(dM9vygi8TT1eVcBvsVsY(xaOlrPiarqPNVnpu7FT5KcZaN1bAtynaIvqb9fHj7LvpJRWX)46Ae0enfAofZfH8SuaHj6EwaHplGR5suS87elucYcSXcaghbLWfMLcWqzmJJwwaxZLOybOlbhcKfQmcAIMskFwGdlxYYVtSOD8ZcQailWglEYc6h0xeM4I8WFWeBvH(dyLrccFoxvtOn9sszq4xhc4UUHkP8XOfHRxKY9uxTMDCeucx4ABOmMXTdv6xIlenDDMPUAn74iOeUW12qzmJBxr9v0tD1AwGUeCiWkvgbnrtjLFLsAqDXKSdv6xIbgQaOT0rwFf9uxTMLc6lctvmu7JDOs)sCHOcG2shzDDQRwZsb9fHPQEL(yhQ0VexiQaOT0rwFUip8hmXwvO)awzKGxz7gcTH4bnvFFqrpwzLq71uEO2q4DxvtkEFqrV9VsQ(Wk4rfQeGuHhvd7uaifi85CvnzbHFDiG76gQKYhZf5H)Gj2Qc9hWkJKsimB3qOnepOP67dk6XkReAVMYd1gcV7QAsX7dk6T)vs1hwbpQqLkOfnk8OAyNcaPaHpNRQjli8RdbCx3qLu(yUip8hmXwvO)awzKGFsR9P20(qOnepOP67dk6XkReAVMYd1gcV7QAsX7dk6T)vs1hwbpQqLaKaEOs)sScpQg2Paqkq4Z5QAYcc)6qa31nujLpMlc5zPaaJflWKLailMUFhUEwcEu0LO4I8WFWeBvH(dyLrsdobQcB10)1qO9Ak7r1WofaIlc5zb9lJGMOHLydtqwmTtjlUkC9S8qwO8PHfNLKmXsSHXW8Sy6sqOjw8eKfSJGyPbhwqAmqI5MbUip8hmXwvO)awzKqLrqt0uvHjiAVMY9OG(IWKvVsFQjHSVRJc6lctwmu7tnjK9DDuqFryY6z8Asi776uxTMv11EgOkSvDTU(7xIcxt)xdzhQ0VexiGYIMUo1vRzvDTNbQcBvxRR)(LOWvFcEs2Hk9lXfcOSOPRZX)46Ae0enfcCkwrac1GqtPn41ld2HCW4kmdCwhOnH1aiUVIEbiudcnL2GxVmyhQ0VexyblURlaHAqOP0g86Lb7qoy8(DDQqmwXLpnrqT)eyTDO2)6qL(LyGPuXCriplfai6ZYCO2FwuPgCiww4lrXcsJbxKh(dMyRk0FaRmsARjEf2QKELeAVMYbiudcnL2GxVmyhYbJRaHpNRQjBaSgGj49hmv0ZX)46Ae0enfcCkwHzbick98T5HA)RnN66cqeu65BZd1(xBoPWX)46Ae0enaZCkUVcZcqeu65Brq5VhFu0ZSaebLE(28qT)1MtDDbiudcnL2amrabIQ)ovXr3Cp2oKdgVVcZaN1bAtynaI5IqEwqAmqI5MbwmTtjl(ZcWPyaZsmWaqw6bhn0enS87EYI5umlXadazX097SGuyIace1Nft3VdxplAi(suS8xjXYLSeBnecQx4NfpbzrFjXYkIft3VZcsHjciqelxJL7zXKJzbKWXZabYf5H)Gj2Qc9hWkJee(CUQMqB6LKYbWAaMG3FWSQc9hTiC9Iu2mWzDG2ewdGyfi85CvnzdG1ambV)GPIE9C8pUUgbnrtHaNIv0tD1AwGUeCiWkvgbnrtjLFLsAqDXKSROUoZcqeu65Bbk(CE2VRtD1AwvnecQx43UIuOUAnRQgcb1l8BhQ0Vedm1vRzdE9YGfCn(FWSFx3LpnrqT)eyTDO2)6qL(LyGPUAnBWRxgSGRX)dMDDbick98T5HA)RnN6RONzbick98T5HA)RnN66654FCDncAIgGzof31bcFBBnXRWwL0RKS)fa6su9v0dHpNRQjBaMiGarvqchpdDDbiudcnL2amrabIQ)ovXr3Cp2oKdgVFFUip8hmXwvO)awzKeinH)Z1vxFOYskF0EnLr4Z5QAYgaRbycE)bZQk0FUip8hmXwvO)awzKCzWN0)dMO9AkJWNZv1KnawdWe8(dMvvO)CriplOp(Vs)jml7qtSuUc7SedmaKfFiwq5xsGSerdlykatqUip8hmXwvO)awzKGWNZv1eAtVKu2XraqA2OaAr46fPmf0xeMSxw1R0hGhqGC9WFW0IFFA3qwczuy9u9VscWMrb9fHj7Lv9k9b47bib87AkFlgU0vyR(7uTbhc)wkDvnbc8fSpY1d)btRPX)DlHmkSEQ(xjb4ITae5IJiTUU74N4IqEwkGRYiw2EFWRbfHzX0oLS87elTd1(ZYHzXvHRNLhYcLGOLL2qzmJZYHzXvHRNLhYcLGOLL4Wfl(qS4plaNIbmlXadaz5sw8Kf0pOVimHwwqAmqI5Mbw0o(XS4j83PHfabGXuaZcCyjoCXIj4sdYcebnbpILs4qS87EYc3PuXSedmaKft7uYsC4IftWLgmr3ZY27dEnOiwsOjUip8hmXwvO)awzKGFFWRbfH2RPCpvigR4YNMiO2FcS2ou7FDOs)smWmNUUEQRwZoockHlCTnugZ42Hk9lXadva0w6id4d0P754FCDncAIgKBblUVc1vRzhhbLWfU2gkJzC7kQF)UUEo(hxxJGMObWi85CvnzDCeaKMnka8QRwZsb9fHPkgQ9XouPFjgWGW32wt8kSvj9kj7FbGW1Hk9lbEaArtHkPuXDDo(hxxJGMObWi85CvnzDCeaKMnka8QRwZsb9fHPQEL(yhQ0Vedyq4BBRjEf2QKELK9Vaq46qL(LapaTOPqLuQ4(kOG(IWK9YQNXv0Zm1vRzdE9YGDf11z27AkFl(9rdhqlLUQMa7ROxpZcqOgeAkTbVEzWUI66cqeu65Bbk(CEQWSaeQbHMslvgbnrtvfMG2vu)UUaebLE(28qT)1Mt9v0ZSaebLE(weu(7XNUoZuxTMn41ld2vuxNJ)X11iOjAke4uC)UUEVRP8T43hnCaTu6QAcuH6Q1SbVEzWUIu0tD1Aw87JgoGw87bGawb76C8pUUgbnrtHaNI73VRtD1A2GxVmyxrkmtD1A2XrqjCHRTHYyg3UIuy27AkFl(9rdhqlLUQMa5IqEwkqmXcawimXSCjlO3k9Hf0pOVimXINGSGDeeliNX1naxawAnlayHWKLgCybPXajMBg4I8WFWeBvH(dyLrssMQLqyI2RPCp1vRzPG(IWuvVsFSdv6xIlKqgfwpv)RK666f29bfHvgGkgkS7dkQ(xjbm00VRlS7dkcRCb7RWJQHDkaexKh(dMyRk0FaRms2DDRwcHjAVMY9uxTMLc6lctv9k9XouPFjUqczuy9u9VssrVaeQbHMsBWRxgSdv6xIlenf31fGqni0uAdWebeiQ(7ufhDZ9y7qL(L4crtX9766f29bfHvgGkgkS7dkQ(xjbm00VRlS7dkcRCb7RWJQHDkaexKh(dMyRk0FaRmsAlTUwcHjAVMY9uxTMLc6lctv9k9XouPFjUqczuy9u9VssrVaeQbHMsBWRxgSdv6xIlenf31fGqni0uAdWebeiQ(7ufhDZ9y7qL(L4crtX9766f29bfHvgGkgkS7dkQ(xjbm00VRlS7dkcRCb7RWJQHDkaexeYZcYbe9zbMSea5I8WFWeBvH(dyLrIjFMdovyRs6vsCriplfiMyz79PDdXYdzjAGbw2GAFyb9d6lctSahwmTtjlxYcm1Xzb9wPpSG(b9fHjw8eKLfMyb5aI(SenWaMLRXYLSGER0hwq)G(IWexKh(dMyRk0FaRmsWVpTBi0EnLPG(IWK9YQEL(01rb9fHjlgQ9PMeY(UokOVimz9mEnjK9DDQRwZAYN5Gtf2QKELKDfPqD1AwkOVimv1R0h7kQRRN6Q1SbVEzWouPFjgyE4pyAnn(VBjKrH1t1)kjfQRwZg86Lb7kQpxKh(dMyRk0FaRmsmn(VZf5H)Gj2Qc9hWkJKzLvp8hmR6d)On9ss5MR1)(S4I4IqEw2EFWRbfXsdoSucrqLu(SSsnHXSSWxIILydJH55I8WFWeBBUw)7Zsz87dEnOi0EnLnBwj1GdkYQ6Apduf2QUwx)9lrHTeWDDrreixeYZcsD8ZYVtSacFwmD)ol)oXsje)S8xjXYdzXbbzzL)Pz53jwkDKXc4A8)GjlhML97TSSTY2neldv6xIzPCP)lsFeilpKLs)d7SucHz7gIfW14)btUip8hmX2MR1)(SaSYibVY2neAdXdAQ((GIESYkH2RPmi8TLqy2UHSdv6xIlCOs)smWdqaICvcqWf5H)Gj22CT(3NfGvgjLqy2UH4I4IqEwkqmXY27dEnOiwEilaruelRiw(DILc4qEP6LG0WI6Q1y5ASCplMGlnileYIUHyrLAWHyPD5H3Vefl)oXssi7zj44Nf4WYdzbCvgXIk1GdXcsHjciqexKh(dMyl(vg)(GxdkcTxt5zLudoOi7FLKj4KvWH8s1lbPrrpkOVimzVS6zCfM1RN6Q1S)vsMGtwbhYlvVeKg7qL(L4c9WFW0AA8F3siJcRNQ)vsaUyRsk6rb9fHj7Lvv4V31rb9fHj7Lvmu7txhf0xeMS6v6tnjK9976uxTM9VsYeCYk4qEP6LG0yhQ0VexOh(dMw87t7gYsiJcRNQ)vsaUyRsk6rb9fHj7Lv9k9PRJc6lctwmu7tnjK9DDuqFryY6z8Asi773VRZm1vRz)RKmbNScoKxQEjin2vu)UUEQRwZg86Lb7kQRdHpNRQjBaMiGarvqchpd9veGqni0uAdWebeiQ(7ufhDZ9y7qoyCfbick98T5HA)RnN6RONzbick98TafFop76cqOgeAkTuze0envvycAhQ0VexiGOVIEQRwZg86Lb7kQRZSaeQbHMsBWRxgSd5GX7ZfH8SuGyILya6r)HGyzZKpLSyANsw(DAiwomljKfp8hcIfSjFkrlloMfT)eloMLiigFQAIfyYc2KpLSy6(DwailWHLgzIgwWVhacZcCybMS4SuqaZc2KpLSGHS87(ZYVtSKKjwWM8PKfFMdbHzbaNf(zXBpnS87(Zc2KpLSqil6gcZf5H)Gj2IFaRmsCqp6peufBYNs0gIh0u99bf9yLvcTxtzZaHV1b9O)qqvSjFkRGEPJIS)fa6sukmZd)btRd6r)HGQyt(uwb9shfzVS20hQ9xrpZaHV1b9O)qqvSjFkR7KRT)fa6suDDGW36GE0FiOk2KpL1DY12Hk9lXfIM(DDGW36GE0FiOk2KpLvqV0rrw87bGawbvacFRd6r)HGQyt(uwb9shfzhQ0VedScQae(wh0J(dbvXM8PSc6LokY(xaOlrXfH8SuGycZcsHjciqelxJfKgdKyUzGLdZYkIf4WsC4IfFiwajC8mCjkwqAmqI5MbwmD)olifMiGarS4jilXHlw8HyrL0qtSyofZsmWaqUip8hmXw8dyLrsaMiGar1FNQ4OBUhJ2RPSzGZ6aTjSgaXk61dHpNRQjBaMiGarvqchpdkmlaHAqOP0g86Lb7qoyCfMnRKAWbfzJMReoGNRR(e88c1OLg7txN6Q1SbVEzWUI6RWX)46Ae0enatzZPyf9uxTMLc6lctv9k9XouPFjUqLkURtD1AwkOVimvXqTp2Hk9lXfQuX976uHySI2HA)Rdv6xIbMsfRWSaeQbHMsBWRxgSd5GX7ZfH8SGuycE)btwAWHfxRzbe(yw(D)zP0bIWSGxdXYVtXzXhkr3ZYqTHW7eilM2PKfamockHlmlfGHYygNLDhZIMWyw(DpzbnSGPaMLHk9lVeflWHLFNybO4Z5jlQRwJLdZIRcxplpKLMR1SaBnwGdlEgNf0pOVimXYHzXvHRNLhYcHSOBiUip8hmXw8dyLrccFoxvtOn9sszq4xhc4UUHkP8XOfHRxKY9uxTMDCeucx4ABOmMXTdv6xIlenDDMPUAn74iOeUW12qzmJBxr9vyM6Q1SJJGs4cxBdLXmEfFzBPR7XXpnNBxrk6PUAnlqxcoeyLkJGMOPKYVsjnOUys2Hk9lXadva0w6iRVIEQRwZsb9fHPkgQ9XouPFjUqubqBPJSUo1vRzPG(IWuvVsFSdv6xIleva0w6iRRRNzQRwZsb9fHPQEL(yxrDDMPUAnlf0xeMQyO2h7kQVcZExt5BXqn(VazP0v1eyFUiKNfKctW7pyYYV7plHDkaeMLRXsC4IfFiwGRhFGeluqFryILhYcm1Xzbe(S870qSahwoujCiw(9dZIP73zzdQX)fiUip8hmXw8dyLrccFoxvtOn9sszq4xHRhFGuLc6lctOfHRxKY9mtD1AwkOVimvXqTp2vKcZuxTMLc6lctv9k9XUI6319UMY3IHA8FbYsPRQjqUip8hmXw8dyLrsjeMTBi0gIh0u99bf9yLvcTxt5HAdH3DvnPON6Q1SuqFryQIHAFSdv6xIlCOs)sCxN6Q1SuqFryQQxPp2Hk9lXfouPFjURdHpNRQjli8RW1JpqQsb9fHP(kgQneE3v1KI3hu0B)RKQpScEuHkbqfEunStbGuGWNZv1Kfe(1HaURBOskFmxKh(dMyl(bSYibVY2neAdXdAQ((GIESYkH2RP8qTHW7UQMu0tD1AwkOVimvXqTp2Hk9lXfouPFjURtD1AwkOVimv1R0h7qL(L4chQ0Ve31HWNZv1Kfe(v46XhivPG(IWuFfd1gcV7QAsX7dk6T)vs1hwbpQqLaOcpQg2Paqkq4Z5QAYcc)6qa31nujLpMlYd)btSf)awzKGFsR9P20(qOnepOP67dk6XkReAVMYd1gcV7QAsrp1vRzPG(IWufd1(yhQ0Vex4qL(L4Uo1vRzPG(IWuvVsFSdv6xIlCOs)sCxhcFoxvtwq4xHRhFGuLc6lct9vmuBi8URQjfVpOO3(xjvFyf8OcvcqQWJQHDkaKce(CUQMSGWVoeWDDdvs5J5IqEwkqmXsbaglwGjlbqwmD)oC9Se8OOlrXf5H)Gj2IFaRmsAWjqvyRM(VgcTxtzpQg2PaqCriplfiMyb50LGdbYYw0n3JzX097S4zCw0WeflucxO2zr74)suSG(b9fHjw8eKLFIZYdzrFjXY9SSIyX097SaaxASpS4jilingiXCZaxKh(dMyl(bSYiHkJGMOPQctq0EnL71tD1AwkOVimvXqTp2Hk9lXfQuXDDQRwZsb9fHPQEL(yhQ0VexOsf3xrac1GqtPn41ld2Hk9lXfwWIv0tD1A2O5kHd456QpbpVqnAPX(yr46fbmaAof31z2SsQbhuKnAUs4aEUU6tWZluJwASpwc4UUOicSF)Uo1vRzJMReoGNRR(e88c1OLg7JfHRxuHkdqavXDDbiudcnL2GxVmyhYbJRWX)46Ae0enfcCkMlc5zPaXelingiXCZalMUFNfKcteqGiKGC6sWHazzl6M7XS4jilGWeDplqe0yAUNybaU0yFyboSyANswITgcb1l8ZIj4sdYcHSOBiwuPgCiwqAmqI5MbwiKfDdH5I8WFWeBXpGvgji85CvnH20ljLdG1ambV)Gzf)OfHRxKYMboRd0MWAaeRaHpNRQjBaSgGj49hmv0Rxac1GqtPLkJIpKRRWbm9mq2Hk9lXatjajGcW9usjGFwj1GdkYIVST01944NMZ7RGaURlkIaTuzu8HCDfoGPNbQFxNJ)X11iOjAkuzGtXk6z27AkFBBnXRWwL0RKSu6QAcSRtD1A2GxVmybxJ)hmlmaHAqOP02wt8kSvj9kj7qL(Lyadi6RaHpNRQj7VpNwxXebenvt(9k6PUAnlqxcoeyLkJGMOPKYVsjnOUys2vuxNzbick98TafFop7R49bf92)kP6dRGhvO6Q1SbVEzWcUg)pyc8fBbuDDQqmwr7qT)1Hk9lXatD1A2GxVmybxJ)hm76cqeu65BZd1(xBo11PUAnRQgcb1l8BxrkuxTMvvdHG6f(Tdv6xIbM6Q1SbVEzWcUg)pyc4EahGFwj1GdkYgnxjCapxx9j45fQrln2hlbCxxueb2VVcZuxTMn41ld2vKIEMfGiO0Z3MhQ9V2CQRlaHAqOP0gGjciqu93Pko6M7X2vuxNkeJv0ou7FDOs)smWcqOgeAkTbyIacev)DQIJU5ESDOs)smGbKDDTd1(xhQ0VeJCrUkbikgyQRwZg86Lbl4A8)GzFUiKNLcetS87ela4s5VhFyX097S4SG0yGeZndS87(ZYHt09S0gyjlaWLg7dxKh(dMyl(bSYizCeucx4ABOmMXr71uwD1A2GxVmyhQ0VexOsOPRtD1A2GxVmybxJ)hmbwblwbcFoxvt2aynatW7pywXpxKh(dMyl(bSYijqAc)NRRU(qLLu(O9AkJWNZv1KnawdWe8(dMv8RONzQRwZg86Lbl4A8)GzHfS4UoZcqeu65Brq5VhF631PUAn74iOeUW12qzmJBxrkuxTMDCeucx4ABOmMXTdv6xIbgWbWbycUU3gnu4Wu11hQSKY3(xjvr46fb4EMPUAnRQgcb1l8Bxrkm7DnLVf)(OHdOLsxvtG95I8WFWeBXpGvgjxg8j9)GjAVMYi85CvnzdG1ambV)Gzf)Cripla46Z5QAILfMazbMS4QN((JWS87(ZIjpFwEilQelyhbbYsdoSG0yGeZndSGHS87(ZYVtXzXhkFwm54NazbaNf(zrLAWHy53PsUip8hmXw8dyLrccFoxvtOn9sszSJGQn4udE9YaAr46fPSzbiudcnL2GxVmyhYbJ31zgcFoxvt2amrabIQGeoEgueGiO0Z3MhQ9V2CQRdCwhOnH1aiMlc5zPaXeMLcae9z5ASCjlEYc6h0xeMyXtqw(5imlpKf9Lel3ZYkIft3VZcaCPX(GwwqAmqI5Mbw8eKLya6r)HGyzZKpLCrE4pyIT4hWkJK2AIxHTkPxjH2RPmf0xeMSxw9mUcpQg2PaqkuxTMnAUs4aEUU6tWZluJwASpweUEradGMtXk6bcFRd6r)HGQyt(uwb9shfz)la0LO66mlarqPNVnPWa1WbSVce(CUQMSyhbvBWPg86Lbf9uxTMDCeucx4ABOmMXTdv6xIbgWba1dna)SsQbhuKfFzBPR7XXpnN3xH6Q1SJJGs4cxBdLXmUDf11zM6Q1SJJGs4cxBdLXmUDf1Nlc5zPaXela4t63zz79P5AnlrdmGz5ASS9(0CTMLdNO7zzfXf5H)Gj2IFaRmsWVpnxRr71uwD1Awys)oUgrtGI(dM2vKc1vRzXVpnxRTd1gcV7QAIlYd)btSf)awzKe8mq6Q6Q1qB6LKY43hnCar71uwD1Aw87JgoG2Hk9lXadnk6PUAnlf0xeMQyO2h7qL(L4crtxN6Q1SuqFryQQxPp2Hk9lXfIM(kC8pUUgbnrtHaNI5IqEwkGRYimlXadazrLAWHybPWebeiILf(suS87elifMiGarSeGj49hmz5HSe2PaqSCnwqkmrabIy5WS4HF5ADCwCv46z5HSOsSeC8Zf5H)Gj2IFaRmsWVp41GIq71uoarqPNVnpu7FT5Kce(CUQMSbyIacevbjC8mOiaHAqOP0gGjciqu93Pko6M7X2Hk9lXadnkmdCwhOnH1aiwbf0xeMSxw9mUch)JRRrqt0uO5umxeYZsbIjw2EFAUwZIP73zz7jT2hwkGZ1Ew8eKLeYY27JgoGOLft7uYsczz79P5AnlhMLveAzjoCXIpelxYc6TsFyb9d6lctS0GdlacaJPaMf4WYdzjAGbwaGln2hwmTtjlUkebXcWPywIbgaYcCyXbJ8)qqSGn5tjl7oMfabGXuaZYqL(LxIIf4WYHz5swA6d1(BzjwWNy539NLvcsdl)oXc2ljwcWe8(dMywUhDywaJWSK06hxZYdzz79P5AnlGR5suSaGXrqjCHzPamugZ4OLft7uYsC4cDGSG)tRzHsqwwrSy6(DwaofdyhhXsdoS87elAh)SGsdvDn2Yf5H)Gj2IFaRmsWVpnxRr71u(DnLVf)Kw7tfCU2BP0v1eOcZExt5BXVpA4aAP0v1eOc1vRzXVpnxRTd1gcV7QAsrp1vRzPG(IWuvVsFSdv6xIleqOGc6lct2lR6v6Jc1vRzJMReoGNRR(e88c1OLg7JfHRxeWaiAkURtD1A2O5kHd456QpbpVqnAPX(yr46fvOYaenfRWX)46Ae0enfcCkURde(wh0J(dbvXM8PSc6LokYouPFjUqarxNh(dMwh0J(dbvXM8PSc6LokYEzTPpu7FFfbiudcnL2GxVmyhQ0VexOsfZfH8SuGyILT3h8AqrSaGpPFNLObgWS4jilGRYiwIbgaYIPDkzbPXajMBgyboS87ela4s5VhFyrD1ASCywCv46z5HS0CTMfyRXcCyjoCHoqwcEelXada5I8WFWeBXpGvgj43h8AqrO9AkRUAnlmPFhxdAYNkIdFW0UI66uxTMfOlbhcSsLrqt0us5xPKguxmj7kQRtD1A2GxVmyxrk6PUAn74iOeUW12qzmJBhQ0VedmubqBPJmGpqNUNJ)X11iOjAqUfS4(aUGa)7AkFBsMQLqyAP0v1eOcZMvsn4GIS4lBlDDpo(P5CfQRwZoockHlCTnugZ42vuxN6Q1SbVEzWouPFjgyOcG2shzaFGoDph)JRRrqt0GClyX976uxTMDCeucx4ABOmMXR4lBlDDpo(P5C7kQRZm1vRzhhbLWfU2gkJzC7ksHzbiudcnL2XrqjCHRTHYyg3oKdgVRZSaebLE(weu(7XN(DDo(hxxJGMOPqGtXkOG(IWK9YQNX5IqEwm)eNLhYsPdeXYVtSOs4NfyJLT3hnCazrnol43daDjkwUNLvela31fashNLlzXZ4SG(b9fHjwuxplaWLg7dlhoFwCv46z5HSOsSenWqGa5I8WFWeBXpGvgj43h8AqrO9Ak)UMY3IFF0Wb0sPRQjqfMnRKAWbfz)RKmbNScoKxQEjink6PUAnl(9rdhq7kQRZX)46Ae0enfcCkUVc1vRzXVpA4aAXVhacyfurp1vRzPG(IWufd1(yxrDDQRwZsb9fHPQEL(yxr9vOUAnB0CLWb8CD1NGNxOgT0yFSiC9IagabufROxac1GqtPn41ld2Hk9lXfQuXDDMHWNZv1KnateqGOkiHJNbfbick98T5HA)RnN6ZfH8SG(4)k9NWSSdnXs5kSZsmWaqw8HybLFjbYsenSGPamb5I8WFWeBXpGvgji85CvnH20ljLDCeaKMnkGweUErktb9fHj7Lv9k9b4beixp8hmT43N2nKLqgfwpv)RKaSzuqFryYEzvVsFa(Easa)UMY3IHlDf2Q)ovBWHWVLsxvtGaFb7JC9WFW0AA8F3siJcRNQ)vsaUyR5GgKloI066UJFcWfBrdW)UMY3M(VgcxvDTNbYsPRQjqUiKNLc4QmILT3h8AqrSCjlolakaJPalBqTpSG(b9fHj0Ycimr3ZIMEwUNLObgybaU0yFyP3V7plhMLDpb1eilQXzHUFNgw(DILT3NMR1SOVKyboS87elXadale4uml6ljwAWHLT3h8Aqr9rllGWeDplqe0yAUNyXtwaWN0VZs0adS4jilA6z53jwCvicIf9Lel7EcQjw2EF0WbKlYd)btSf)awzKGFFWRbfH2RPSzZkPgCqr2)kjtWjRGd5LQxcsJIEQRwZgnxjCapxx9j45fQrln2hlcxViGbqavXDDQRwZgnxjCapxx9j45fQrln2hlcxViGbq0uSI31u(w8tATpvW5AVLsxvtG9v0Jc6lct2lRyO2hfo(hxxJGMObWi85CvnzDCeaKMnka8QRwZsb9fHPkgQ9XouPFjgWGW32wt8kSvj9kj7FbGW1Hk9lbEaArtHaII76OG(IWK9YQEL(OWX)46Ae0enagHpNRQjRJJaG0SrbGxD1AwkOVimv1R0h7qL(LyadcFBBnXRWwL0RKS)facxhQ0Ve4bOfnfcCkUVcZuxTMfM0VJRr0eOO)GPDfPWS31u(w87JgoGwkDvnbQOxac1GqtPn41ld2Hk9lXfcO66WWLw9sq7VpNwxXebenwkDvnbQqD1A2FFoTUIjciAS43dabScwqauVzLudoOil(Y2sx3JJFAoh4rtFfTd1(xhQ0VexOsfxSI2HA)Rdv6xIbgalU4(k6fGqni0uAb6sWHaR4OBUhBhQ0VexiGQRZSaebLE(wGIpNN95IqEwkqmXcawimXSCjlO3k9Hf0pOVimXINGSGDeeliNX1naxawAnlayHWKLgCybPXajMBgyXtqwqoDj4qGSG(Lrqt0us5Zf5H)Gj2IFaRmssYuTect0EnL7PUAnlf0xeMQ6v6JDOs)sCHeYOW6P6FLuxxVWUpOiSYauXqHDFqr1)kjGHM(DDHDFqryLlyFfEunStbGuGWNZv1Kf7iOAdo1GxVmWf5H)Gj2IFaRms2DDRwcHjAVMY9uxTMLc6lctv9k9XouPFjUqczuy9u9VssHzbick98TafFop766PUAnlqxcoeyLkJGMOPKYVsjnOUys2vKIaebLE(wGIpNN9766f29bfHvgGkgkS7dkQ(xjbm00VRlS7dkcRCb76uxTMn41ld2vuFfEunStbGuGWNZv1Kf7iOAdo1GxVmOON6Q1SJJGs4cxBdLXmUDOs)smW6Hgaeab(zLudoOil(Y2sx3JJFAoVVc1vRzhhbLWfU2gkJzC7kQRZm1vRzhhbLWfU2gkJzC7kQpxKh(dMyl(bSYiPT06AjeMO9Ak3tD1AwkOVimv1R0h7qL(L4cjKrH1t1)kjfMfGiO0Z3cu858SRRN6Q1SaDj4qGvQmcAIMsk)kL0G6Ijzxrkcqeu65Bbk(CE2VRRxy3huewzaQyOWUpOO6FLeWqt)UUWUpOiSYfSRtD1A2GxVmyxr9v4r1WofasbcFoxvtwSJGQn4udE9YGIEQRwZoockHlCTnugZ42Hk9lXadnkuxTMDCeucx4ABOmMXTRifMnRKAWbfzXx2w66EC8tZ5DDMPUAn74iOeUW12qzmJBxr95IqEwkqmXcYbe9zbMSea5I8WFWeBXpGvgjM8zo4uHTkPxjXfH8SuGyILT3N2nelpKLObgyzdQ9Hf0pOVimHwwqAmqI5Mbw2DmlAcJz5VsILF3twCwqog)3zHqgfwpXIMAplWHfyQJZc6TsFyb9d6lctSCywwrCrE4pyIT4hWkJe87t7gcTxtzkOVimzVSQxPpDDuqFryYIHAFQjHSVRJc6lctwpJxtczFxxp1vRzn5ZCWPcBvsVsYUI66WrKwx3D8taRyR5GgfMfGiO0Z3IGYFp(01HJiTUU74NawXwZrraIGspFlck)94tFfQRwZsb9fHPQEL(yxrDD9uxTMn41ld2Hk9lXaZd)btRPX)DlHmkSEQ(xjPqD1A2GxVmyxr95IqEwkqmXcYX4)olWFNgthMyX0(f2z5WSCjlBqTpSG(b9fHj0YcsJbsm3mWcCy5HSenWalO3k9Hf0pOVimXf5H)Gj2IFaRmsmn(VZfH8SuaCT(3NfxKh(dMyl(bSYizwz1d)bZQ(WpAtVKuU5A9VplJnCefmILsfdqJ34nmaa]] )


end