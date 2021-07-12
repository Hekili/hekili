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


    spec:RegisterPack( "Balance", 20210712, [[deLMHfqisvEeePUeejTjsXNGuzusvoLuvRcqvVcqAwqkDlaq7IIFbrmmrQogPKLbGEMqjtJuvCnifBdquFdqOXba15auX6aezEak3JuQ9js6FqKO0bfjSqHcpeIYefkLUiKQSrHsXhHir1iHirXjjvLwPiLxcrImtiv1nbGKDku0pbGudfqWsbGWtvQMkPQ6QcLQTcar(kejmwaG9sP(ROgmXHPAXuYJfmzGUmYMLYNHKrRuoTQwnae1RbOztYTLk7wYVbnCHCCavA5kEoutxLRRKTdHVtQmEiQoVq16fjA(Iy)O2wlB9BVd6hzhtaMoa1kDGOwa0KoaoDGiAaY27x8iYEpYda6Oi79Y7i79y4kVcK9EKhxbDqB9BVJHRjq27B3fHbsibjwUYRabaXFxWG6VTLL5HijgUYRaba3)oKHKoqZ21PqkB7vK2wUYRazoKF27wRxD6BzBzVd6hzhtaMoa1kDGOwa0KoaoDGiA0h7DFDBWXEF)7qM9(2dcsLTL9oiHd27XWvEfiwITZ6b50sBPIZIwaeTSaW0bOwCACAiBZluegiXPbazjfGGeil7qLpSedY7mCAaqwq2MxOiqwoFqrx(BSeCmHz5GSeIhuu(8bfDydNgaKfaeuhebbYYQkkqySpXzbHpVBPiml9EdzqllrdHiJpFWRbfXcamvwIgcHbF(GxdkQVHtdaYskqaFqwIgk447luSGum(TXY3y5p0Hz52iw0nWcflOxq9ryYWPbazbaLdiXcYGfciGel3gXYE0p)HzXzr93Piw6GdXstri)Tuel9(glXHlw2CWcDhlB)XYFSG)UL68IGlSkol6(BJLyaGof6NfGYcYifHV3vSKc1JQ6O6qll)HoqwWa(r9nCAaqwaq5asS0bXhlOR9O2U8qD(xy0XcoqLppeZIhfPIZYbzXcIXS0EuBhMfyPIB40aGSO)H8Jf9d7iwGnwIHY3yjgkFJLyO8nwCmlol4ik8UILB(cq6m27QhFyB9BVdsnFPoB9BhtTS1V9UhUhw27yOYNSf5D27u5wkc0og2NDmbOT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr274isPYNpOOdBWNpnxPyjvw0IfnS0Jf9y5CfvNbF(OGdOHk3srGSKKWY5kQod(iLYNm48TZqLBPiqw6Zsscl4isPYNpOOdBWNpnxPyjvwaO9oiHdZhDpSS33PdZskGOhlWILybuw093gCDSaoF7yXlqw093gl7Npk4aYIxGSaqGYc82Or3Jj7De(KlVJS3FC2HK9zhZyzRF7DQClfbAhd7DyK9oMo7DpCpSS3r4Z7wkYEhHRwK9ooIuQ85dk6Wg85t7hILuzrl7DqchMp6EyzVVthMLGICeel62OIL9ZN2pelbVyz7pwaiqz58bfDyw0T9HnwEmldPieEDS0Gdl3gXc6fuFeMy5GSyrSenuJMHazXlqw0T9HnwAVsrdlhKLGJp7De(KlVJS3FCoOihbzF2XuFS1V9ovULIaTJH9UhUhw27w0GPbWVqzVds4W8r3dl79yhtSedAW0a4xOyr3FBSGSuGe9TcSahw82rdlidwiGasS8flilfirFRG9Ey(JM3T37XIESeGiOYRZupQTl3CILKew0JLaeQaH6ktawiGas5BJY4OF(dBwrS0NfnSyTAntWZFfmd15FHzjvw0cnSOHfRvRzghbvWfo3gQszCZqD(xywagl6dlAyrpwcqeu51zqq1TfFyjjHLaebvEDgeuDBXhw0WI1Q1mbp)vWSIyrdlwRwZmocQGlCUnuLY4MvelAyPhlwRwZmocQGlCUnuLY4MH68VWSamw0slwaGSGgwaEwMvrn4GIm4VAlvElo(O5DdvULIazjjHfRvRzcE(RGzOo)lmlaJfT0ILKew0IfKWcoIuQ8MJpIfGXIwg0Ggw6BF2Xen263ENk3srG2XWEpm)rZ727wRwZe88xbZqD(xywsLfTqdlAyPhl6XYSkQbhuKb)vBPYBXXhnVBOYTueiljjSyTAnZ4iOcUW52qvkJBgQZ)cZcWyrlGilaqwailaplwRwZyPGqq1cFMvelAyXA1AMXrqfCHZTHQug3SIyPpljjS0EuBxEOo)lmlaJfaIg7DqchMp6EyzVdeGhl6(BJfNfKLcKOVvGLBZpwECHUJfNfGWsH9HLObgyboSOBJkwUnIL2JA7y5XS4wW1XYbzHkq7DpCpSS3JG3dl7ZoMazB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS3d0RyPhl9yP9O2U8qD(xywaGSOfAybaYsacvGqDLj45VcMH68VWS0NfKWIwa40zPplAZsGEfl9yPhlTh12LhQZ)cZcaKfTqdlaqw0cGPZcaKLaeQaH6ktawiGas5BJY4OF(dBgQZ)cZsFwqclAbGtNL(SOHf9yz8hmtiO6moii2qi)XhMLKewcqOceQRmbp)vWmuN)fMLuz5RJMiOYpcm3EuBxEOo)lmljjSeGqfiuxzcWcbeqkFBugh9ZFyZqD(xywsLLVoAIGk)iWC7rTD5H68VWSaazrR0zjjHf9yjarqLxNPEuBxU5eljjS4H7HLjaleqaP8TrzC0p)HnGp2TueO9oiHdZhDpSS3rMRclLFeMfDB0Trdll8xOybzWcbeqILcQJfDVsXIRuqDSehUy5GSGVxPyj44JLBJyb7DelEhCvhlWglidwiGasafzPaj6Bfyj44dBVJWNC5DK9EawiGaszqchVc2NDmbI263ENk3srG2XWEhgzVJPZE3d3dl7De(8ULIS3r4QfzV3JL2JA7Yd15FHzjvw0cnSKKWY4pyMqq1zCqqS5lwsLf0Kol9zrdl9yPhl9yHaURpkIanuxu8HCvgoGLxbIfnS0JLESeGqfiuxzOUO4d5QmCalVcKzOo)lmlaJfTaYPZssclbicQ86miO62IpSOHLaeQaH6kd1ffFixLHdy5vGmd15FHzbySOfqgiYcqzPhlAPflaplZQOgCqrg8xTLkVfhF08UHk3srGS0NL(SOHf9yjaHkqOUYqDrXhYvz4awEfiZqoyCw6ZsFwssyPhleWD9rreObdxkfD3xOYZYkolAyPhl6XsaIGkVot9O2UCZjwssyjaHkqOUYGHlLIU7lu5zzfphl9bna401YmuN)fMfGXIwAPpS0NL(SKKWspwcqOceQRmw0GPbWVqzgYbJZsscl6XY4bYCduPyPplAyPhl9yHaURpkIanFHdZ6ClfLbUlVUvxgKq8bIfnSeGqfiuxz(chM15wkkdCxEDRUmiH4dKzihmol9zjjHLESqa31hfrGg8Mdc1rGz4yLHT8bNoQow0WsacvGqDL5GthvhbM)c)O2UCSqdAIfa1YmuN)fML(SKKWspw6XccFE3srgyLxykFZxashlAZIwSKKWccFE3srgyLxykFZxashlAZsSyPplAyPhl38fG0zoTmd5GXZbiubc1vSKKWYnFbiDMtltacvGqDLzOo)lmlPYYxhnrqLFeyU9O2U8qD(xywaGSOv6S0NLKewq4Z7wkYaR8ct5B(cq6yrBwailAyPhl38fG0zoaAgYbJNdqOceQRyjjHLB(cq6mhanbiubc1vMH68VWSKklFD0ebv(rG52JA7Yd15FHzbaYIwPZsFwssybHpVBPidSYlmLV5laPJfTzjDw6ZsFw6ZssclbicQ86magFEVyPpljjS0EuBxEOo)lmlaJfRvRzcE(RGbCn(9WYEhKWH5JUhw27XoMaz5GSaskpol3gXYc7OiwGnwqwkqI(wbw0Trfll8xOybeUSuelWILfMyXlqwIgcbvhllSJIyr3gvS4floiilecQowEmlUfCDSCqwaFYEhHp5Y7i79ayoalW)EyzF2XeaBRF7DQClfbAhd7DyK9oMo7DpCpSS3r4Z7wkYEhHRwK9UESGHlL1xGMBBELkJjcqAmu5wkcKLKewApQTlpuN)fMLuzbGPNoljjS0EuBxEOo)lmlaJfaIgwakl9yrFsNfailwRwZCBZRuzmrasJbFEaqwaEwail9zjjHfRvRzUT5vQmMiaPXGppailPYsSaWSaazPhlZQOgCqrg8xTLkVfhF08UHk3srGSa8SGgw6BVds4W8r3dl7DaK85DlfXYctGSCqwajLhNfVIZYnFbiDyw8cKLaiMfDBuXIo)VVqXsdoS4flO3kAdoVZs0ad27i8jxEhzVFBZRuzmrastwN)N9zhtGJT(T3PYTueODmS3bjCy(O7HL9ESJjwqVUO4d5kwaqpGLxbIfaMoMcywSOgCiwCwqwkqI(wbwwyYyVxEhzVtDrXhYvz4awEfi79W8hnVBVhGqfiuxzcE(RGzOo)lmlaJfaMolAyjaHkqOUYeGfciGu(2Omo6N)WMH68VWSamway6SOHLESGWN3TuK52MxPYyIaKMSo)pwssyXA1AMBBELkJjcqAm4ZdaYsQSeR0zbOS0JLzvudoOid(R2sL3IJpAE3qLBPiqwaEwaYS0NL(SKKWs7rTD5H68VWSamwIfq0E3d3dl7DQlk(qUkdhWYRazF2XuR0T1V9ovULIaTJH9oiHdZhDpSS3JDmXYoCPu09fkwaqSSIZcqgtbmlwudoelolilfirFRallmzS3lVJS3XWLsr39fQ8SSIBVhM)O5D79aeQaH6ktWZFfmd15FHzbySaKzrdl6XsaIGkVodcQUT4dlAyrpwcqeu51zQh12LBoXssclbicQ86m1JA7YnNyrdlbiubc1vMaSqabKY3gLXr)8h2muN)fMfGXcqMfnS0Jfe(8ULImbyHaciLbjC8kWssclbiubc1vMGN)kygQZ)cZcWybiZsFwssyjarqLxNbbv3w8HfnS0Jf9yzwf1GdkYG)QTu5T44JM3nu5wkcKfnSeGqfiuxzcE(RGzOo)lmlaJfGmljjSyTAnZ4iOcUW52qvkJBgQZ)cZcWyrl9HfGYspwqdlapleWD9rreO5l8nRWbhCg8r8fLTiLIL(SOHfRvRzghbvWfo3gQszCZkIL(SKKWs7rTD5H68VWSamwaiAS39W9WYEhdxkfD3xOYZYkU9zhtT0Yw)27u5wkc0og27E4EyzV)fomRZTuug4U86wDzqcXhi79W8hnVBVBTAntWZFfmd15FHzjvw0cnSOHLESOhlZQOgCqrg8xTLkVfhF08UHk3srGSKKWI1Q1mJJGk4cNBdvPmUzOo)lmlaJfTailaLLESelwaEwSwTMXsbHGQf(mRiw6ZcqzPhl9ybiYcaKf0WcWZI1Q1mwkieuTWNzfXsFwaEwiG76JIiqZx4BwHdo4m4J4lkBrkfl9zrdlwRwZmocQGlCUnuLY4Mvel9zjjHL2JA7Yd15FHzbySaq0yVxEhzV)fomRZTuug4U86wDzqcXhi7ZoMAbqB9BVtLBPiq7yyVds4W8r3dl79yhtSmpQTJflQbhILai2EV8oYEhV5GqDeygowzylFWPJQZEpm)rZ7279yjaHkqOUYe88xbZqoyCw0WIESeGiOYRZupQTl3CIfnSGWN3TuK52MxPYyIaKMSo)pwssyjarqLxNPEuBxU5elAyjaHkqOUYeGfciGu(2Omo6N)WMHCW4SOHLESGWN3TuKjaleqaPmiHJxbwssyjaHkqOUYe88xbZqoyCw6ZsFw0Wci8m4v1(Hm3ha8luSOHLESacpd(iLYNCt5dzUpa4xOyjjHf9y5CfvNbFKs5tUP8Hmu5wkcKLKewWrKsLpFqrh2GpFA)qSKklXIL(SOHLESacpthewTFiZ9ba)cfl9zrdl9ybHpVBPiZJZoKyjjHLzvudoOiJLR8kqzyl7kv(2(cf2qLBPiqwssyXX34QCeuhnSKQ2SaCsNLKewSwTMXsbHGQf(mRiw6ZIgw6XsacvGqDLXIgmna(fkZqoyCwssyrpwgpqMBGkfl9zjjHL2JA7Yd15FHzbySOpPBV7H7HL9oEZbH6iWmCSYWw(GthvN9zhtTILT(T3PYTueODmS3bjCy(O7HL9U(3EmlpMfNLXVnAyHuUfC8JyrNhNLdYsNdiXIRuSalwwyIf85hl38fG0Hz5GSyrSO(IazzfXIU)2ybzPaj6BfyXlqwqgSqabKyXlqwwyILBJybGfilyf8ybwSeaz5BSybVnwU5laPdZIpelWILfMybF(XYnFbiDy79W8hnVBVJWN3TuKbw5fMY38fG0XI2Saqw0WIESCZxasN5aOzihmEoaHkqOUILKew6XccFE3srgyLxykFZxashlAZIwSKKWccFE3srgyLxykFZxashlAZsSyPplAyPhlwRwZe88xbZkIfnS0Jf9yjarqLxNbbv3w8HLKewSwTMzCeubx4CBOkLXnd15FHzbOS0Jf0WcWZYSkQbhuKb)vBPYBXXhnVBOYTueil9zbyAZYnFbiDMtlJ1Q1YGRXVhwSOHfRvRzghbvWfo3gQszCZkILKewSwTMzCeubx4CBOkLXZ4VAlvElo(O5DZkIL(SKKWsacvGqDLj45VcMH68VWSauwailPYYnFbiDMtltacvGqDLbCn(9WIfnSOhlwRwZe88xbZkIfnS0Jf9yjarqLxNPEuBxU5eljjSOhli85DlfzcWcbeqkds44vGL(SOHf9yjarqLxNbW4Z7fljjSeGiOYRZupQTl3CIfnSGWN3TuKjaleqaPmiHJxbw0WsacvGqDLjaleqaP8TrzC0p)HnRiw0WIESeGqfiuxzcE(RGzfXIgw6XspwSwTMHcQpctz1Q8XmuN)fMLuzrR0zjjHfRvRzOG6JWugdv(ygQZ)cZsQSOv6S0NfnSOhlZQOgCqrglx5vGYWw2vQ8T9fkSHk3srGSKKWspwSwTMXYvEfOmSLDLkFBFHcNl)wdzWNhaKfTzbnSKKWI1Q1mwUYRaLHTSRu5B7lu4SpbVid(8aGSOnlayw6ZsFwssyXA1Aga)cCiWm1fb1rthvxMkAq9PKmRiw6ZssclTh12LhQZ)cZcWybGPZsscli85DlfzGvEHP8nFbiDSOnlPBVJvWdBVFZxasNw27E4EyzVFZxasNw2NDm1sFS1V9ovULIaTJH9UhUhw2738fG0bq79W8hnVBVJWN3TuKbw5fMY38fG0XIEAZcazrdl6XYnFbiDMtlZqoy8CacvGqDfljjSGWN3TuKbw5fMY38fG0XI2Saqw0WspwSwTMj45VcMvelAyPhl6XsaIGkVodcQUT4dljjSyTAnZ4iOcUW52qvkJBgQZ)cZcqzPhlOHfGNLzvudoOid(R2sL3IJpAE3qLBPiqw6ZcW0MLB(cq6mhanwRwldUg)EyXIgwSwTMzCeubx4CBOkLXnRiwssyXA1AMXrqfCHZTHQugpJ)QTu5T44JM3nRiw6Zssclbiubc1vMGN)kygQZ)cZcqzbGSKkl38fG0zoaAcqOceQRmGRXVhwSOHf9yXA1AMGN)kywrSOHLESOhlbicQ86m1JA7YnNyjjHf9ybHpVBPitawiGaszqchVcS0NfnSOhlbicQ86magFEVyrdl9yrpwSwTMj45VcMveljjSOhlbicQ86miO62IpS0NLKewcqeu51zQh12LBoXIgwq4Z7wkYeGfciGugKWXRalAyjaHkqOUYeGfciGu(2Omo6N)WMvelAyrpwcqOceQRmbp)vWSIyrdl9yPhlwRwZqb1hHPSAv(ygQZ)cZsQSOv6SKKWI1Q1muq9rykJHkFmd15FHzjvw0kDw6ZIgw0JLzvudoOiJLR8kqzyl7kv(2(cf2qLBPiqwssyPhlwRwZy5kVcug2YUsLVTVqHZLFRHm4ZdaYI2SGgwssyXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaqw0Mfaml9zPpl9zjjHfRvRza8lWHaZuxeuhnDuDzQOb1NsYSIyjjHL2JA7Yd15FHzbySaW0zjjHfe(8ULImWkVWu(MVaKow0ML0T3Xk4HT3V5laPdG2NDm1cn263ENk3srG2XWEhKWH5JUhw27XoMWS4kflWBJgwGfllmXYFuhMfyXsa0E3d3dl79fMY)rDy7ZoMAbKT1V9ovULIaTJH9oiHdZhDpSS3JTu4bjw8W9WIf1JpwSCmbYcSyb)3YVhwirrOES9UhUhw27ZQYE4EyLvp(S3X38HZoMAzVhM)O5D7De(8ULImpo7qYEx94lxEhzV7qY(SJPwarB9BVtLBPiq7yyVhM)O5D79zvudoOiJLR8kqzyl7kv(2(cf2qa31hfrG274B(WzhtTS39W9WYEFwv2d3dRS6XN9U6XxU8oYE3c6N9zhtTaW263ENk3srG2XWE3d3dl79zvzpCpSYQhF27QhF5Y7i7D8zF2N9Uf0pB9BhtTS1V9ovULIaTJH9UhUhw27JJGk4cNBdvPmU9oiHdZhDpSS3JndvPmol6(BJfKLcKOVvWEpm)rZ727wRwZe88xbZqD(xywsLfTqJ9zhtaARF7DQClfbAhd7DpCpSS3Dqp6EeugRZNo79q8GIYNpOOdBhtTS3dZF08U9U1Q1mwUYRaLHTSRu5B7lu4C53Aid(8aGSamwaWSOHfRvRzSCLxbkdBzxPY32xOWzFcErg85bazbySaGzrdl9yrpwaHNXb9O7rqzSoF6YGENJIm3ha8luSOHf9yXd3dlJd6r3JGYyD(0Lb9ohfz(k3upQTJfnS0Jf9ybeEgh0JUhbLX68PlVrUYCFaWVqXssclGWZ4GE09iOmwNpD5nYvMH68VWSKklXIL(SKKWci8moOhDpckJ15txg07CuKbFEaqwaglXIfnSacpJd6r3JGYyD(0Lb9ohfzgQZ)cZcWybnSOHfq4zCqp6EeugRZNUmO35OiZ9ba)cfl9T3bjCy(O7HL9ESJjwsbOhDpcILDD(0XIUnQyXpwuegZYT5fl6dlXaMc9Zc(8aGyw8cKLdYYqTHWBS4SamTbil4ZdaYIJzr5hXIJzjcIXVLIyboSCFhXYFSGHS8hl(mpccZcaYl8XI3oAyXzjwaLf85bazHqE0pe2(SJzSS1V9ovULIaTJH9UhUhw27byHaciLVnkJJ(5pS9oiHdZhDpSS3JDmXcYGfciGel6(BJfKLcKOVvGfDBuXseeJFlfXIxGSaVnA09yIfD)TXIZsmGPq)SyTAnw0TrflGeoEf(cL9Ey(JM3T31JfWz9GMcMdGyw0Wspw6XccFE3srMaSqabKYGeoEfyrdl6XsacvGqDLj45VcMHCW4SKKWI1Q1mbp)vWSIyPplAyPhlwRwZy5kVcug2YUsLVTVqHZLFRHm4ZdaYI2SaGzjjHfRvRzSCLxbkdBzxPY32xOWzFcErg85bazrBwaWS0NLKewApQTlpuN)fMfGXIwPZsF7ZoM6JT(T3PYTueODmS39W9WYEVTM4zyltQvr27GeomF09WYEp2arpwCml3gXs7h8XcQailFXYTrS4Sedyk0pl6(ceQJf4WIU)2y52iwqkfFEVyXA1ASahw093glolayGIPalPa0JUhbXYUoF6yXlqw05)XsdoSGSuGe9TcS8nw(JfDW6yXIyzfXIJY)IflQbhILBJyjaYYJzP91J3iq79W8hnVBV3JLES0JfRvRzSCLxbkdBzxPY32xOW5YV1qg85bazjvwaYSKKWI1Q1mwUYRaLHTSRu5B7lu4SpbVid(8aGSKklazw6ZIgw6XIESeGiOYRZGGQBl(Wsscl6XI1Q1mJJGk4cNBdvPmUzfXsFw6ZIgw6Xc4SEqtbZbqmljjSeGqfiuxzcE(RGzOo)lmlPYcAsNLKew6XsaIGkVot9O2UCZjw0WsacvGqDLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NL(S0NLKew6Xci8moOhDpckJ15txg07CuKzOo)lmlPYcaMfnSeGqfiuxzcE(RGzOo)lmlPYIwPZIgwcqeu51zkkmqfCazPpljjS81rteu5hbMBpQTlpuN)fMfGXcaMfnSOhlbiubc1vMGN)kygYbJZssclbicQ86magFEVyrdlwRwZa4xGdbMPUiOoA6O6mRiwssyjarqLxNbbv3w8HfnSyTAnZ4iOcUW52qvkJBgQZ)cZcWyb4WIgwSwTMzCeubx4CBOkLXnRi7ZoMOXw)27u5wkc0og27E4EyzVh8kqQS1Q1S3dZF08U9EpwSwTMXYvEfOmSLDLkFBFHcNl)wdzgQZ)cZsQSaenOHLKewSwTMXYvEfOmSLDLkFBFHcN9j4fzgQZ)cZsQSaenOHL(SOHLESeGqfiuxzcE(RGzOo)lmlPYcqKLKew6XsacvGqDLH6IG6OjBblqZqD(xywsLfGilAyrpwSwTMbWVahcmtDrqD00r1LPIguFkjZkIfnSeGiOYRZay859IL(S0NfnS44BCvocQJgwsvBwIv627wRwlxEhzVJpFuWb0EhKWH5JUhw27iZRaPyz)8rbhqw093glolfPJLyatH(zXA1AS4fililfirFRalpUq3XIBbxhlhKflILfMaTp7ycKT1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEp2U6Iyz)8bVgueMfD)TXIZsmGPq)SyTAnwSwhlf8yr3gvSebHQVqXsdoSGSuGe9TcSahwqk9f4qGSSh9ZFy79W8hnVBV3JfRvRzSCLxbkdBzxPY32xOW5YV1qg85bazjvwailjjSyTAnJLR8kqzyl7kv(2(cfo7tWlYGppailPYcazPplAyPhlbicQ86m1JA7YnNyjjHLaeQaH6ktWZFfmd15FHzjvwaISKKWIESGWN3TuKjaMdWc8VhwSOHf9yjarqLxNbW4Z7fljjS0JLaeQaH6kd1fb1rt2cwGMH68VWSKklarw0WIESyTAndGFboeyM6IG6OPJQltfnO(usMvelAyjarqLxNbW4Z7fl9zPplAyPhl6Xci8mT1epdBzsTkYCFaWVqXsscl6XsacvGqDLj45VcMHCW4SKKWIESeGqfiuxzcWcbeqkFBugh9ZFyZqoyCw6BF2XeiARF7DQClfbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9ESD1fXY(5dEnOimlwudoelidwiGas27H5pAE3EVhlbiubc1vMaSqabKY3gLXr)8h2muN)fMfGXcAyrdl6Xc4SEqtbZbqmlAyPhli85DlfzcWcbeqkds44vGLKewcqOceQRmbp)vWmuN)fMfGXcAyPplAybHpVBPitamhGf4FpSyPplAyrpwaHNPTM4zyltQvrM7da(fkw0WsaIGkVot9O2UCZjw0WIESaoRh0uWCaeZIgwOG6JWK5RSxXzrdlo(gxLJG6OHLuzrFs3(SJja2w)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi79ESyTAnZ4iOcUW52qvkJBgQZ)cZsQSGgwssyrpwSwTMzCeubx4CBOkLXnRiw6ZIgw6XI1Q1ma(f4qGzQlcQJMoQUmv0G6tjzgQZ)cZcWybva005iNL(SOHLESyTAndfuFeMYyOYhZqD(xywsLfubqtNJCwssyXA1AgkO(imLvRYhZqD(xywsLfubqtNJCw6BVds4W8r3dl79ylSq3Xci8ybCnFHILBJyHkqwGnwaq4iOcUWSeBgQszC0Yc4A(cfla(f4qGSqDrqD00r1XcCy5lwUnIfLJpwqfazb2yXlwqVG6JWK9ocFYL3r27GWlpeWD9d1r1HTp7ycCS1V9ovULIaTJH9UhUhw274v1(HS3dZF08U9(qTHWBULIyrdlNpOOZCFhLpyg8jwsLfTaYSOHfpkh2OaGSOHfe(8ULImGWlpeWD9d1r1HT3dXdkkF(GIoSDm1Y(SJPwPBRF7DQClfbAhd7DpCpSS37GWQ9dzVhM)O5D79HAdH3ClfXIgwoFqrN5(okFWm4tSKklAfldAyrdlEuoSrbazrdli85DlfzaHxEiG76hQJQdBVhIhuu(8bfDy7yQL9zhtT0Yw)27u5wkc0og27E4EyzVJpsP8j3u(q27H5pAE3EFO2q4n3srSOHLZhu0zUVJYhmd(elPYIwazwakld15FHzrdlEuoSrbazrdli85DlfzaHxEiG76hQJQdBVhIhuu(8bfDy7yQL9zhtTaOT(T3PYTueODmS39W9WYEVbNaLHTC53Ai7DqchMp6EyzVhBGXKfyXsaKfD)Tbxhlbpk6lu27H5pAE3E3JYHnkaO9zhtTILT(T3PYTueODmS39W9WYEN6IG6OjBblq7DqchMp6EyzVJEDrqD0WsmGfil62OIf3cUowoiluD0WIZsr6yjgWuOFw09fiuhlEbYc2rqS0GdlilfirFRG9Ey(JM3T37XcfuFeMmQv5tUiKFSKKWcfuFeMmyOYNCri)yjjHfkO(imz8kEUiKFSKKWI1Q1mwUYRaLHTSRu5B7lu4C53AiZqD(xywsLfGObnSKKWI1Q1mwUYRaLHTSRu5B7lu4SpbViZqD(xywsLfGObnSKKWIJVXv5iOoAyjvwaoPZIgwcqOceQRmbp)vWmKdgNfnSOhlGZ6bnfmhaXS0NfnS0JLaeQaH6ktWZFfmd15FHzjvwIv6SKKWsacvGqDLj45VcMHCW4S0NLKew(6OjcQ8JaZTh12LhQZ)cZcWyrR0Tp7yQL(yRF7DQClfbAhd7DpCpSS3BRjEg2YKAvK9oiHdZhDpSS3Jnq0JL5rTDSyrn4qSSWFHIfKLc79W8hnVBVhGqfiuxzcE(RGzihmolAybHpVBPitamhGf4FpSyrdl9yXX34QCeuhnSKklaN0zrdl6XsaIGkVot9O2UCZjwssyjarqLxNPEuBxU5elAyXX34QCeuhnSamw0N0zPplAyrpwcqeu51zqq1TfFyrdl9yrpwcqeu51zQh12LBoXssclbiubc1vMaSqabKY3gLXr)8h2mKdgNL(SOHf9ybCwpOPG5ai2(SJPwOXw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9ybCwpOPG5aiMfnSGWN3TuKjaMdWc8VhwSOHLES0JfhFJRYrqD0WsQSaCsNfnS0JfRvRza8lWHaZuxeuhnDuDzQOb1NsYSIyjjHf9yjarqLxNbW4Z7fl9zjjHfRvRzSuqiOAHpZkIfnSyTAnJLccbvl8zgQZ)cZcWyXA1AMGN)kyaxJFpSyPpljjS81rteu5hbMBpQTlpuN)fMfGXI1Q1mbp)vWaUg)EyXssclbicQ86m1JA7YnNyPplAyPhl6XsaIGkVot9O2UCZjwssyPhlo(gxLJG6OHfGXI(KoljjSacptBnXZWwMuRIm3ha8luS0NfnS0Jfe(8ULImbyHaciLbjC8kWssclbiubc1vMaSqabKY3gLXr)8h2mKdgNL(S03EhKWH5JUhw27ilfirFRal62OIf)yb4KoqzjfyGal9GJcQJgwUnVyrFsNLuGbcSO7VnwqgSqabK6ZIU)2GRJffe)fkwUVJy5lwIHccbvl8XIxGSO(IyzfXIU)2ybzWcbeqILVXYFSOZXSas44vGaT3r4tU8oYEpaMdWc8VhwzlOF2NDm1ciBRF7DQClfbAhd79W8hnVBVJWN3TuKjaMdWc8VhwzlOF27E4EyzVhifHV3vzx9OQoQo7ZoMAbeT1V9ovULIaTJH9Ey(JM3T3r4Z7wkYeaZbyb(3dRSf0p7DpCpSS3)k4t53dl7ZoMAbGT1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYENcQpctMVYQv5dlaplaywqclE4EyzWNpTFidHCkSokFFhXcqzrpwOG6JWK5RSAv(WcWZspwaYSauwoxr1zWWLkdB5BJYn4q4ZqLBPiqwaEwIfl9zbjS4H7HLr343MHqofwhLVVJybOSKUbGSGewWrKsL3C8r27GeomF09WYEh9W335hHzzdQJLUvyJLuGbcS4dXck)lcKLiAybtbybAVJWNC5DK9UJJac0Stb7ZoMAbCS1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEp2U6Iyz)8bVgueMfDBuXYTrS0EuBhlpMf3cUowoilubIwwAdvPmolpMf3cUowoilubIwwIdxS4dXIFSaCshOSKcmqGLVyXlwqVG6JWeAzbzPaj6Bfyr54dZIxWBJgwaWaftbmlWHL4Wfl6Glfilqe0e8iw6GdXYT5flCIwPZskWabw0TrflXHlw0bxkWcDhl7Np41GIyPG6S3dZF08U9Epw(6OjcQ8JaZTh12LhQZ)cZcWyrFyjjHLESyTAnZ4iOcUW52qvkJBgQZ)cZcWybva005iNfGNLa9kw6XIJVXv5iOoAybjSeR0zPplAyXA1AMXrqfCHZTHQug3SIyPpl9zjjHLES44BCvocQJgwakli85DlfzCCeqGMDkWcWZI1Q1muq9rykJHkFmd15FHzbOSacptBnXZWwMuRIm3haeNhQZ)IfGNfaAqdlPYIwALoljjS44BCvocQJgwakli85DlfzCCeqGMDkWcWZI1Q1muq9rykRwLpMH68VWSauwaHNPTM4zyltQvrM7daIZd15FXcWZcanOHLuzrlTsNL(SOHfkO(imz(k7vCw0Wspw0JfRvRzcE(RGzfXsscl6XY5kQod(8rbhqdvULIazPplAyPhl9yrpwcqOceQRmbp)vWSIyjjHLaebvEDgaJpVxSOHf9yjaHkqOUYqDrqD0KTGfOzfXsFwssyjarqLxNPEuBxU5el9zrdl9yrpwcqeu51zqq1TfFyjjHf9yXA1AMGN)kywrSKKWIJVXv5iOoAyjvwaoPZsFwssyPhlNRO6m4ZhfCanu5wkcKfnSyTAntWZFfmRiw0WspwSwTMbF(OGdObFEaqwaglXILKewC8nUkhb1rdlPYcWjDw6ZsFwssyXA1AMGN)kywrSOHf9yXA1AMXrqfCHZTHQug3SIyrdl6XY5kQod(8rbhqdvULIaTp7ycW0T1V9ovULIaTJH9UhUhw27fPl3bHL9oiHdZhDpSS3JDmXcakiSWS8flO)Q8Hf0lO(imXIxGSGDeeliLXvnGgBwkflaOGWILgCybzPaj6BfS3dZF08U9EpwSwTMHcQpctz1Q8XmuN)fMLuzHqofwhLVVJyjjHLESe28bfHzrBwailAyzOWMpOO89DelaJf0WsFwssyjS5dkcZI2Selw6ZIgw8OCyJcaAF2XeGAzRF7DQClfbAhd79W8hnVBV3JfRvRzOG6JWuwTkFmd15FHzjvwiKtH1r577iw0WspwcqOceQRmbp)vWmuN)fMLuzbnPZssclbiubc1vMaSqabKY3gLXr)8h2muN)fMLuzbnPZsFwssyPhlHnFqryw0MfaYIgwgkS5dkkFFhXcWybnS0NLKewcB(GIWSOnlXIL(SOHfpkh2OaG27E4EyzVV5QwUdcl7ZoMaeG263ENk3srG2XWEpm)rZ7279yXA1AgkO(imLvRYhZqD(xywsLfc5uyDu((oIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWsacvGqDLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NLKew6XsyZhueMfTzbGSOHLHcB(GIY33rSamwqdl9zjjHLWMpOimlAZsSyPplAyXJYHnkaO9UhUhw27TLsL7GWY(SJjaJLT(T3PYTueODmS3bjCy(O7HL9osbe9ybwSeaT39W9WYExNpZdNmSLj1Qi7ZoMauFS1V9ovULIaTJH9UhUhw274ZN2pK9oiHdZhDpSS3JDmXY(5t7hILdYs0adSSdv(Wc6fuFeMyboSOBJkw(IfyPIZc6VkFyb9cQpctS4fillmXcsbe9yjAGbmlFJLVyb9xLpSGEb1hHj79W8hnVBVtb1hHjZxz1Q8HLKewOG6JWKbdv(Klc5hljjSqb1hHjJxXZfH8JLKewSwTMrNpZdNmSLj1QiZkIfnSyTAndfuFeMYQv5JzfXsscl9yXA1AMGN)kygQZ)cZcWyXd3dlJUXVndHCkSokFFhXIgwSwTMj45VcMvel9Tp7ycq0yRF7DpCpSS31n(TzVtLBPiq7yyF2XeGazB9BVtLBPiq7yyV7H7HL9(SQShUhwz1Jp7D1JVC5DK9EZvQBBw2N9zV7qYw)2XulB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS37XI1Q1m33r6GtLbhY7S(cKgZqD(xywaglOcGMoh5Sauws3OfljjSyTAnZ9DKo4uzWH8oRVaPXmuN)fMfGXIhUhwg85t7hYqiNcRJY33rSauws3OflAyPhluq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yPpl9zrdlwRwZCFhPdovgCiVZ6lqAmRiw0WYSkQbhuK5(oshCQm4qEN1xG0yOYTueO9oiHdZhDpSS3rMRclLFeMfDB0Trdl3gXsSDiVl4xyJgwSwTgl6ELILMRuSaBnw0932xSCBelfH8JLGJp7De(KlVJS3bhY7Y6ELk3CLkdBn7ZoMa0w)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9yHcQpctMVYyOYhw0WspwWrKsLpFqrh2GpFA)qSKklOHfnSCUIQZGHlvg2Y3gLBWHWNHk3srGSKKWcoIuQ85dk6Wg85t7hILuzbiYsF7DqchMp6EyzVJmxfwk)iml62OBJgw2pFWRbfXYJzrhCUnwco((cflqe0WY(5t7hILVyb9xLpSGEb1hHj7De(KlVJS3FufCOm(8bVguK9zhZyzRF7DQClfbAhd7DpCpSS3dWcbeqkFBugh9ZFy7DqchMp6EyzVh7yIfKbleqajw0Trfl(XIIWywUnVybnPZskWabw8cKf1xelRiw093glilfirFRG9Ey(JM3T31JfWz9GMcMdGyw0Wspw6XccFE3srMaSqabKYGeoEfyrdl6XsacvGqDLj45VcMHCW4SKKWI1Q1mbp)vWSIyPplAyPhlwRwZqb1hHPSAv(ygQZ)cZsQSaKzjjHfRvRzOG6JWugdv(ygQZ)cZsQSaKzPplAyPhl6XYSkQbhuKXYvEfOmSLDLkFBFHcBOYTueiljjSyTAnJLR8kqzyl7kv(2(cfox(TgYGppailPYsSyjjHfRvRzSCLxbkdBzxPY32xOWzFcErg85bazjvwIfl9zjjHL2JA7Yd15FHzbySOv6SOHf9yjaHkqOUYe88xbZqoyCw6BF2XuFS1V9ovULIaTJH9UhUhw27JJGk4cNBdvPmU9oiHdZhDpSS3JDmXsSzOkLXzr3FBSGSuGe9Tc27H5pAE3E3A1AMGN)kygQZ)cZsQSOfASp7yIgB9BVtLBPiq7yyV7H7HL9oEvTFi79q8GIYNpOOdBhtTS3dZF08U9EpwgQneEZTueljjSyTAndfuFeMYyOYhZqD(xywaglXIfnSqb1hHjZxzmu5dlAyzOo)lmlaJfT0hw0WY5kQodgUuzylFBuUbhcFgQClfbYsFw0WY5dk6m33r5dMbFILuzrl9Hfail4isPYNpOOdZcqzzOo)lmlAyPhluq9ryY8v2R4SKKWYqD(xywaglOcGMoh5S03EhKWH5JUhw27XoMyzFvTFiw(ILiVaPUpWcSyXR432xOy528Jf1JGWSOL(GPaMfVazrryml6(BJLo4qSC(GIomlEbYIFSCBelubYcSXIZYou5dlOxq9ryIf)yrl9HfmfWSahwuegZYqD(xFHIfhZYbzPGhlBoIVqXYbzzO2q4nwaxZxOyb9xLpSGEb1hHj7ZoMazB9BVtLBPiq7yyV7H7HL9o(8P5kL9oiHdZhDpSS3rkruelRiw2pFAUsXIFS4kfl33rywwLIWyww4VqXc6hp4JJzXlqw(JLhZIBbxhlhKLObgyboSOOJLBJybhrH3vS4H7HflQViwSifuhlBEbQiwITd5DwFbsdlWIfaYY5dk6W27H5pAE3Expwoxr1zWhPu(KbNVDgQClfbYIgw6XI1Q1m4ZNMRuMHAdH3ClfXIgw6XcoIuQ85dk6Wg85tZvkwaglXILKew0JLzvudoOiZ9DKo4uzWH8oRVaPXqLBPiqw6ZssclNRO6my4sLHT8Tr5gCi8zOYTueilAyXA1AgkO(imLXqLpMH68VWSamwIflAyHcQpctMVYyOYhw0WI1Q1m4ZNMRuMH68VWSamwaISOHfCePu5Zhu0Hn4ZNMRuSKQ2SOpS0NfnS0Jf9yzwf1GdkYOIh8XX5MIO7luzuQVlctgQClfbYsscl33rSGuzrFqdlPYI1Q1m4ZNMRuMH68VWSauwail9zrdlNpOOZCFhLpyg8jwsLf0yF2XeiARF7DQClfbAhd7DpCpSS3XNpnxPS3bjCy(O7HL9osXFBSSFKs5dlX25BhllmXcSyjaYIUnQyzO2q4n3srSyTowW3RuSOZ)JLgCyb9Jh8XXSenWalEbYciSq3XYctSyrn4qSGSyl2WY(9kfllmXIf1GdXcYGfciGel4Vcel3MFSO7vkwIgyGfVG3gnSSF(0CLYEpm)rZ727NRO6m4JukFYGZ3odvULIazrdlwRwZGpFAUszgQneEZTuelAyPhl6XYSkQbhuKrfp4JJZnfr3xOYOuFxeMmu5wkcKLKewUVJybPYI(GgwsLf9HL(SOHLZhu0zUVJYhmd(elPYsSSp7ycGT1V9ovULIaTJH9UhUhw274ZNMRu27GeomF09WYEhP4VnwITd5DwFbsdllmXY(5tZvkwoilasuelRiwUnIfRvRXIvCwCfgYYc)fkw2pFAUsXcSybnSGPaSaXSahwuegZYqD(xFHYEpm)rZ727ZQOgCqrM77iDWPYGd5DwFbsJHk3srGSOHfCePu5Zhu0Hn4ZNMRuSKQ2Selw0Wspw0JfRvRzUVJ0bNkdoK3z9finMvelAyXA1Ag85tZvkZqTHWBULIyjjHLESGWN3TuKbCiVlR7vQCZvQmS1yrdl9yXA1Ag85tZvkZqD(xywaglXILKewWrKsLpFqrh2GpFAUsXsQSaqw0WY5kQod(iLYNm48TZqLBPiqw0WI1Q1m4ZNMRuMH68VWSamwqdl9zPpl9Tp7ycCS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYE3X34QCeuhnSKkla40zbaYspw0kDwaEwSwTM5(oshCQm4qEN1xG0yWNhaKL(SaazPhlwRwZGpFAUszgQZ)cZcWZsSybjSGJiLkV54Jyb4zrpwoxr1zWhPu(KbNVDgQClfbYsFwaGS0JLaeQaH6kd(8P5kLzOo)lmlaplXIfKWcoIuQ8MJpIfGNLZvuDg8rkLpzW5BNHk3srGS0Nfail9ybeEM2AINHTmPwfzgQZ)cZcWZcAyPplAyPhlwRwZGpFAUszwrSKKWsacvGqDLbF(0CLYmuN)fML(27GeomF09WYEhzUkSu(ryw0Tr3gnS4SSF(GxdkILfMyr3RuSe8fMyz)8P5kflhKLMRuSaBn0YIxGSSWel7Np41GIy5GSairrSeBhY7S(cKgwWNhaKLvK9ocFYL3r274ZNMRuzDW6YnxPYWwZ(SJPwPBRF7DQClfbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9ESJjw2pFWRbfXIU)2yj2oK3z9finSCqwaKOiwwrSCBelwRwJfD)Tbxhlki(luSSF(0CLILv09DelEbYYctSSF(GxdkIfyXI(auwIbmf6Nf85baXSSQ7vSOpSC(GIoS9Ey(JM3T3r4Z7wkYaoK3L19kvU5kvg2ASOHfe(8ULIm4ZNMRuzDW6YnxPYWwJfnSOhli85DlfzEufCOm(8bVgueljjS0JfRvRzSCLxbkdBzxPY32xOW5YV1qg85bazjvwIfljjSyTAnJLR8kqzyl7kv(2(cfo7tWlYGppailPYsSyPplAybhrkv(8bfDyd(8P5kflaJf9HfnSGWN3TuKbF(0CLkRdwxU5kvg2A2NDm1slB9BVtLBPiq7yyV7H7HL9Ud6r3JGYyD(0zVhIhuu(8bfDy7yQL9Ey(JM3T31JL7da(fkw0WIES4H7HLXb9O7rqzSoF6YGENJImFLBQh12XssclGWZ4GE09iOmwNpDzqVZrrg85bazbySelw0Wci8moOhDpckJ15txg07CuKzOo)lmlaJLyzVds4W8r3dl79yhtSG15thlyil3MFSehUybfDS05iNLv09DelwXzzH)cfl)XIJzr5hXIJzjcIXVLIybwSOimMLBZlwIfl4ZdaIzboSaG8cFSOBJkwIfqzbFEaqmleYJ(HSp7yQfaT1V9ovULIaTJH9UhUhw27Dqy1(HS3dXdkkF(GIoSDm1YEpm)rZ727d1gcV5wkIfnSC(GIoZ9Du(GzWNyjvw6Xspw0sFybOS0JfCePu5Zhu0Hn4ZN2pelaplaKfGNfRvRzOG6JWuwTkFmRiw6ZsFwakld15FHzPpliHLESOflaLLZvuDMt3x5oiSWgQClfbYsFw0WspwcqOceQRmbp)vWmKdgNfnSOhlGZ6bnfmhaXSOHLESGWN3TuKjaleqaPmiHJxbwssyjaHkqOUYeGfciGu(2Omo6N)WMHCW4SKKWIESeGiOYRZupQTl3CIL(SKKWcoIuQ85dk6Wg85t7hIfGXspw6XcqMfail9yXA1AgkO(imLvRYhZkIfGNfaYsFw6ZcWZspw0IfGYY5kQoZP7RChewydvULIazPpl9zrdl6XcfuFeMmyOYNCri)yjjHLESqb1hHjZxzmu5dljjS0JfkO(imz(kBbVnwssyHcQpctMVYQv5dl9zrdl6XY5kQodgUuzylFBuUbhcFgQClfbYssclwRwZenFhCaFxL9j41hYrlf2hdcxTiwsvBwaiAsNL(SOHLESGJiLkF(GIoSbF(0(HybySOv6Sa8S0JfTybOSCUIQZC6(k3bHf2qLBPiqw6ZsFw0WIJVXv5iOoAyjvwqt6SaazXA1Ag85tZvkZqD(xywaEwaYS0NfnS0Jf9yXA1Aga)cCiWm1fb1rthvxMkAq9PKmRiwssyHcQpctMVYyOYhwssyrpwcqeu51zam(8EXsFw0WIESyTAnZ4iOcUW52qvkJNXF1wQ8wC8rZ7MvK9oiHdZhDpSS3bqqTHWBSaGccR2pelFJfKLcKOVvGLhZYqoyC0YYTrdXIpelkcJz528If0WY5dk6WS8flO)Q8Hf0lO(imXIU)2yzhEXg0YIIWywUnVyrR0zbEB0O7XelFXIxXzb9cQpctSahwwrSCqwqdlNpOOdZIf1GdXIZc6VkFyb9cQpctgwITWcDhld1gcVXc4A(cfliL(cCiqwqVUiOoA6O6yzvkcJz5lw2HkFyb9cQpct2NDm1kw263ENk3srG2XWE3d3dl79gCcug2YLFRHS3bjCy(O7HL9ESJjwInWyYcSyjaYIU)2GRJLGhf9fk79W8hnVBV7r5Wgfa0(SJPw6JT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr276Xc4SEqtbZbqmlAybHpVBPitamhGf4FpSyrdl9yPhlwRwZGpFAUszwrSKKWY5kQod(iLYNm48TZqLBPiqwssyjarqLxNPEuBxU5el9zrdl9yrpwSwTMbdv47dKzfXIgw0JfRvRzcE(RGzfXIgw6XIESCUIQZ0wt8mSLj1QidvULIazjjHfRvRzcE(RGbCn(9WILuzjaHkqOUY0wt8mSLj1QiZqD(xywaklayw6ZIgwq4Z7wkYCBZRuzmrastwN)hlAyPhl6XsaIGkVot9O2UCZjwssyjaHkqOUYeGfciGu(2Omo6N)WMvelAyPhlwRwZGpFAUszgQZ)cZcWybGSKKWIESCUIQZGpsP8jdoF7mu5wkcKL(S0NfnSC(GIoZ9Du(GzWNyjvwSwTMj45VcgW143dlwaEws3aezPpljjS0EuBxEOo)lmlaJfRvRzcE(RGbCn(9WIL(27i8jxEhzVhaZbyb(3dRSdj7ZoMAHgB9BVtLBPiq7yyV7H7HL9EGue(ExLD1JQ6O6S3bjCy(O7HL9ESJjwqwkqI(wbwGflbqwwLIWyw8cKf1xel)XYkIfD)TXcYGfciGK9Ey(JM3T3r4Z7wkYeaZbyb(3dRSdj7ZoMAbKT1V9ovULIaTJH9Ey(JM3T3r4Z7wkYeaZbyb(3dRSdj7DpCpSS3)k4t53dl7ZoMAbeT1V9ovULIaTJH9UhUhw27uxeuhnzlybAVds4W8r3dl79yhtSGEDrqD0WsmGfilWILail6(BJL9ZNMRuSSIyXlqwWocILgCybiSuyFyXlqwqwkqI(wb79W8hnVBV)1rteu5hbMBpQTlpuN)fMfGXIwOHLKew6XI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlIfGXcart6SKKWI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlILu1MfaIM0zPplAyXA1Ag85tZvkZkIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWc4SEqtbZbqml9Tp7yQfa2w)27u5wkc0og27E4EyzVJpsP8j3u(q27H4bfLpFqrh2oMAzVhM)O5D79HAdH3ClfXIgwUVJYhmd(elPYIwOHfnSGJiLkF(GIoSbF(0(HybySOpSOHfpkh2OaGSOHLESyTAntWZFfmd15FHzjvw0kDwssyrpwSwTMj45VcMvel9T3bjCy(O7HL9oacQneEJLMYhIfyXYkILdYsSy58bfDyw093gCDSGSuGe9TcSyrFHIf3cUowoileYJ(HyXlqwk4Xcebnbpk6lu2NDm1c4yRF7DQClfbAhd7DpCpSS3BRjEg2YKAvK9oiHdZhDpSS3JDmXsSbIES8nw(c)GelEXc6fuFeMyXlqwuFrS8hlRiw093glolaHLc7dlrdmWIxGSKcqp6Eeel768PZEpm)rZ727uq9ryY8v2R4SOHfpkh2OaGSOHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaJfaIM0zrdl9ybeEgh0JUhbLX68Pld6DokYCFaWVqXsscl6XsaIGkVotrHbQGdiljjSGJiLkF(GIomlPYcazPplAyPhlwRwZmocQGlCUnuLY4MH68VWSamwaoSaazPhlOHfGNLzvudoOid(R2sL3IJpAE3qLBPiqw6ZIgwSwTMzCeubx4CBOkLXnRiwssyrpwSwTMzCeubx4CBOkLXnRiw6ZIgw6XIESeGqfiuxzcE(RGzfXssclwRwZCBZRuzmrasJbFEaqwaglAHgw0Ws7rTD5H68VWSamway6PZIgwApQTlpuN)fMLuzrR0tNLKew0JfmCPS(c0CBZRuzmrasJHk3srGS0NfnS0JfmCPS(c0CBZRuzmrasJHk3srGSKKWsacvGqDLj45VcMH68VWSKklXkDw6BF2XeGPBRF7DQClfbAhd7DpCpSS3XNpnxPS3bjCy(O7HL9ESJjwCw2pFAUsXca6IUnwIgyGLvPimML9ZNMRuS8ywC1qoyCwwrSahwIdxS4dXIBbxhlhKficAcEelPadeS3dZF08U9U1Q1mWIUnCoIMafDpSmRiw0WspwSwTMbF(0CLYmuBi8MBPiwssyXX34QCeuhnSKklaN0zPV9zhtaQLT(T3PYTueODmS39W9WYEhF(0CLYEhKWH5JUhw27X2vxelPadeyXIAWHybzWcbeqIfD)TXY(5tZvkw8cKLBJkw2pFWRbfzVhM)O5D79aebvEDM6rTD5MtSOHf9y5CfvNbFKs5tgC(2zOYTueilAyPhli85DlfzcWcbeqkds44vGLKewcqOceQRmbp)vWSIyjjHfRvRzcE(RGzfXsFw0WsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbySGkaA6CKZcWZsGEfl9yXX34QCeuhnSGewqt6S0NfnSyTAnd(8P5kLzOo)lmlaJf9HfnSOhlGZ6bnfmhaX2NDmbiaT1V9ovULIaTJH9Ey(JM3T3dqeu51zQh12LBoXIgw6XccFE3srMaSqabKYGeoEfyjjHLaeQaH6ktWZFfmRiwssyXA1AMGN)kywrS0NfnSeGqfiuxzcWcbeqkFBugh9ZFyZqD(xywaglazw0WI1Q1m4ZNMRuMvelAyHcQpctMVYEfNfnSOhli85DlfzEufCOm(8bVguelAyrpwaN1dAkyoaIT39W9WYEhF(GxdkY(SJjaJLT(T3PYTueODmS39W9WYEhF(GxdkYEhKWH5JUhw27XoMyz)8bVguel6(BJfVybaDr3glrdmWcCy5BSehUqhilqe0e8iwsbgiWIU)2yjoCnSueYpwco(mSKcfgYc4QlILuGbcS4hl3gXcvGSaBSCBelair1TfFyXA1AS8nw2pFAUsXIo4sbwO7yP5kflWwJf4WsC4IfFiwGflaKLZhu0HT3dZF08U9U1Q1mWIUnCoOiFYiE8dlZkILKew6XIESGpFA)qgpkh2OaGSOHf9ybHpVBPiZJQGdLXNp41GIyjjHLESyTAntWZFfmd15FHzbySGgw0WI1Q1mbp)vWSIyjjHLES0JfRvRzcE(RGzOo)lmlaJfubqtNJCwaEwc0RyPhlo(gxLJG6OHfKWsSsNL(SOHfRvRzcE(RGzfXssclwRwZmocQGlCUnuLY4z8xTLkVfhF08UzOo)lmlaJfubqtNJCwaEwc0RyPhlo(gxLJG6OHfKWsSsNL(SOHfRvRzghbvWfo3gQsz8m(R2sL3IJpAE3SIyPplAyjarqLxNbbv3w8HL(S0NfnS0JfCePu5Zhu0Hn4ZNMRuSamwIfljjSGWN3TuKbF(0CLkRdwxU5kvg2AS0NL(SOHf9ybHpVBPiZJQGdLXNp41GIyrdl9yrpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazjjHfCePu5Zhu0Hn4ZNMRuSamwIfl9Tp7ycq9Xw)27u5wkc0og27E4EyzVxKUChew27GeomF09WYEp2XelaOGWcZYxSSdv(Wc6fuFeMyXlqwWocILyZsPybafewS0GdlilfirFRG9Ey(JM3T37XI1Q1muq9rykJHkFmd15FHzjvwiKtH1r577iwssyPhlHnFqryw0MfaYIgwgkS5dkkFFhXcWybnS0NLKewcB(GIWSOnlXIL(SOHfpkh2OaG2NDmbiAS1V9ovULIaTJH9Ey(JM3T37XI1Q1muq9rykJHkFmd15FHzjvwiKtH1r577iwssyPhlHnFqryw0MfaYIgwgkS5dkkFFhXcWybnS0NLKewcB(GIWSOnlXIL(SOHfpkh2OaGSOHLESyTAnZ4iOcUW52qvkJBgQZ)cZcWybnSOHfRvRzghbvWfo3gQszCZkIfnSOhlZQOgCqrg8xTLkVfhF08UHk3srGSKKWIESyTAnZ4iOcUW52qvkJBwrS03E3d3dl79nx1YDqyzF2XeGazB9BVtLBPiq7yyVhM)O5D79ESyTAndfuFeMYyOYhZqD(xywsLfc5uyDu((oIfnS0JLaeQaH6ktWZFfmd15FHzjvwqt6SKKWsacvGqDLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NLKew6XsyZhueMfTzbGSOHLHcB(GIY33rSamwqdl9zjjHLWMpOimlAZsSyPplAyXJYHnkailAyPhlwRwZmocQGlCUnuLY4MH68VWSamwqdlAyXA1AMXrqfCHZTHQug3SIyrdl6XYSkQbhuKb)vBPYBXXhnVBOYTueiljjSOhlwRwZmocQGlCUnuLY4Mvel9T39W9WYEVTuQChew2NDmbiq0w)27u5wkc0og27GeomF09WYEp2Xelifq0JfyXcYIT27E4EyzVRZN5Htg2YKAvK9zhtacGT1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYEhhrkv(8bfDyd(8P9dXsQSOpSauwAkiCyPhlDo(OjEgHRwelaplALE6SGeway6S0NfGYstbHdl9yXA1Ag85dEnOOm1fb1rthvxgdv(yWNhaKfKWI(WsF7DqchMp6EyzVJmxfwk)iml62OBJgwoillmXY(5t7hILVyzhQ8HfDBFyJLhZIFSGgwoFqrhgOAXsdoSqiOjolamDKklDo(OjolWHf9HL9Zh8AqrSGEDrqD00r1Xc(8aGy7De(KlVJS3XNpTFO8xzmu5J9zhtacCS1V9ovULIaTJH9omYEhtN9UhUhw27i85DlfzVJWvlYExlwqcl4isPYBo(iwaglaKfail9yjDdazb4zPhl4isPYNpOOdBWNpTFiwaGSOfl9zb4zPhlAXcqz5CfvNbdxQmSLVnk3GdHpdvULIazb4zrldAyPpl9zbOSKUrl0WcWZI1Q1mJJGk4cNBdvPmUzOo)lS9oiHdZhDpSS3rMRclLFeMfDB0TrdlhKfKIXVnwaxZxOyj2muLY427i8jxEhzVRB8Bl)vUnuLY42NDmJv6263ENk3srG2XWE3d3dl7DDJFB27GeomF09WYEp2XelifJFBS8fl7qLpSGEb1hHjwGdlFJLcYY(5t7hIfDVsXs7pw(6GSGSuGe9TcS4v8o4q27H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY4v8Cri)yrdli85DlfzECoOihbXsFw0WspwoFqrN5(okFWm4tSKkl6dljjSqb1hHjJAv(K)kdqwssyP9O2U8qD(xywaglALol9zjjHfRvRzOG6JWugdv(ygQZ)cZcWyXd3dld(8P9dziKtH1r577iw0WI1Q1muq9rykJHkFmRiwssyHcQpctMVYyOYhw0WIESGWN3TuKbF(0(HYFLXqLpSKKWI1Q1mbp)vWmuN)fMfGXIhUhwg85t7hYqiNcRJY33rSOHf9ybHpVBPiZJZbf5iiw0WI1Q1mbp)vWmuN)fMfGXcHCkSokFFhXIgwSwTMj45VcMveljjSyTAnZ4iOcUW52qvkJBwrSOHfe(8ULIm6g)2YFLBdvPmoljjSOhli85DlfzECoOihbXIgwSwTMj45VcMH68VWSKkleYPW6O89DK9zhZyPLT(T3PYTueODmS3bjCy(O7HL9ESJjw2pFA)qS8nw(If0Fv(Wc6fuFeMqllFXYou5dlOxq9ryIfyXI(auwoFqrhMf4WYbzjAGbw2HkFyb9cQpct27E4EyzVJpFA)q2NDmJfaT1V9ovULIaTJH9oiHdZhDpSS3JnUsDBZYE3d3dl79zvzpCpSYQhF27QhF5Y7i79MRu32SSp7ZEV5k1TnlB9BhtTS1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEF)8bVgueln4Wsheb1r1XYQuegZYc)fkwIbmf63Epm)rZ7276XYSkQbhuKXYvEfOmSLDLkFBFHcBiG76JIiq7ZoMa0w)27u5wkc0og27E4EyzVJxv7hYEpepOO85dk6W2Xul79W8hnVBVdcpthewTFiZqD(xywsLLH68VWSa8SaqaYcsyrlaS9oiHdZhDpSS3rMJpwUnIfq4XIU)2y52iw6G4JL77iwoiloiilR6Efl3gXsNJCwaxJFpSy5XSS9NHL9v1(HyzOo)lmlDl19rQNaz5GS05xyJLoiSA)qSaUg)EyzF2Xmw263E3d3dl79oiSA)q27u5wkc0og2N9zVJpB9BhtTS1V9ovULIaTJH9UhUhw274Zh8Aqr27GeomF09WYEp2Xel7Np41GIy5GSairrSSIy52iwITd5DwFbsdlwRwJLVXYFSOdUuGSqip6hIflQbhIL2xpE7luSCBelfH8JLGJpwGdlhKfWvxelwudoelidwiGas27H5pAE3EFwf1GdkYCFhPdovgCiVZ6lqAmu5wkcKfnS0JfkO(imz(k7vCw0WIES0JLESyTAnZ9DKo4uzWH8oRVaPXmuN)fMLuzXd3dlJUXVndHCkSokFFhXcqzjDJwSOHLESqb1hHjZxzl4TXsscluq9ryY8vgdv(Wsscluq9ryYOwLp5Iq(XsFwssyXA1AM77iDWPYGd5DwFbsJzOo)lmlPYIhUhwg85t7hYqiNcRJY33rSauws3OflAyPhluq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yPpl9zjjHf9yXA1AM77iDWPYGd5DwFbsJzfXsFwssyPhlwRwZe88xbZkILKewq4Z7wkYeGfciGugKWXRal9zrdlbiubc1vMaSqabKY3gLXr)8h2mKdgNfnSeGiOYRZupQTl3CIL(SOHLESOhlbicQ86magFEVyjjHLaeQaH6kd1fb1rt2cwGMH68VWSKklayw6ZIgw6XI1Q1mbp)vWSIyjjHf9yjaHkqOUYe88xbZqoyCw6BF2XeG263ENk3srG2XWE3d3dl7Dh0JUhbLX68PZEpepOO85dk6W2Xul79W8hnVBVRhlGWZ4GE09iOmwNpDzqVZrrM7da(fkw0WIES4H7HLXb9O7rqzSoF6YGENJImFLBQh12XIgw6XIESacpJd6r3JGYyD(0L3ixzUpa4xOyjjHfq4zCqp6EeugRZNU8g5kZqD(xywsLf0WsFwssybeEgh0JUhbLX68Pld6DokYGppailaJLyXIgwaHNXb9O7rqzSoF6YGENJImd15FHzbySelw0Wci8moOhDpckJ15txg07CuK5(aGFHYEhKWH5JUhw27XoMyjfGE09iiw215thl62OILBJgILhZsbzXd3JGybRZNo0YIJzr5hXIJzjcIXVLIybwSG15thl6(BJfaYcCyPr6OHf85baXSahwGflolXcOSG15thlyil3MFSCBelfPJfSoF6yXN5rqywaqEHpw82rdl3MFSG15thleYJ(HW2NDmJLT(T3PYTueODmS39W9WYEpaleqaP8TrzC0p)HT3bjCy(O7HL9ESJjmlidwiGasS8nwqwkqI(wbwEmlRiwGdlXHlw8HybKWXRWxOybzPaj6Bfyr3FBSGmyHaciXIxGSehUyXhIflsb1XI(KolPadeS3dZF08U9UESaoRh0uWCaeZIgw6Xspwq4Z7wkYeGfciGugKWXRalAyrpwcqOceQRmbp)vWmKdgNfnSOhlZQOgCqrMO57Gd47QSpbV(qoAPW(yOYTueiljjSyTAntWZFfmRiw6ZIgwC8nUkhb1rdlatBw0N0zrdl9yXA1AgkO(imLvRYhZqD(xywsLfTsNLKewSwTMHcQpctzmu5JzOo)lmlPYIwPZsFwssyP9O2U8qD(xywaglALolAyrpwcqOceQRmbp)vWmKdgNL(2NDm1hB9BVtLBPiq7yyVdJS3X0zV7H7HL9ocFE3sr27iC1IS37XI1Q1mJJGk4cNBdvPmUzOo)lmlPYcAyjjHf9yXA1AMXrqfCHZTHQug3SIyPplAyrpwSwTMzCeubx4CBOkLXZ4VAlvElo(O5DZkIfnS0JfRvRza8lWHaZuxeuhnDuDzQOb1NsYmuN)fMfGXcQaOPZrol9zrdl9yXA1AgkO(imLXqLpMH68VWSKklOcGMoh5SKKWI1Q1muq9rykRwLpMH68VWSKklOcGMoh5SKKWspw0JfRvRzOG6JWuwTkFmRiwssyrpwSwTMHcQpctzmu5JzfXsFw0WIESCUIQZGHk89bYqLBPiqw6BVds4W8r3dl7DKblW)EyXsdoS4kflGWdZYT5hlDoGeMf8AiwUnkol(qf6owgQneEJazr3gvSaGWrqfCHzj2muLY4SS5ywuegZYT5flOHfmfWSmuN)1xOyboSCBelagFEVyXA1AS8ywCl46y5GS0CLIfyRXcCyXR4SGEb1hHjwEmlUfCDSCqwiKh9dzVJWNC5DK9oi8YdbCx)qDuDy7ZoMOXw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi79ESOhlwRwZqb1hHPmgQ8XSIyrdl6XI1Q1muq9rykRwLpMvel9zjjHLZvuDgmuHVpqgQClfbAVds4W8r3dl7DKblW)EyXYT5hlHnkaiMLVXsC4IfFiwGRd)Geluq9ryILdYcSuXzbeESCB0qSahwEufCiwUThZIU)2yzhQW3hi7De(KlVJS3bHxgUo8dszkO(imzF2XeiBRF7DQClfbAhd7DpCpSS37GWQ9dzVhM)O5D79HAdH3ClfXIgw6XI1Q1muq9rykJHkFmd15FHzjvwgQZ)cZssclwRwZqb1hHPSAv(ygQZ)cZsQSmuN)fMLKewq4Z7wkYacVmCD4hKYuq9ryIL(SOHLHAdH3ClfXIgwoFqrN5(okFWm4tSKklAbqw0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2oMAzF2XeiARF7DQClfbAhd7DpCpSS3XRQ9dzVhM)O5D79HAdH3ClfXIgw6XI1Q1muq9rykJHkFmd15FHzjvwgQZ)cZssclwRwZqb1hHPSAv(ygQZ)cZsQSmuN)fMLKewq4Z7wkYacVmCD4hKYuq9ryIL(SOHLHAdH3ClfXIgwoFqrN5(okFWm4tSKklAbqw0WIhLdBuaqw0WccFE3srgq4Lhc4U(H6O6W27H4bfLpFqrh2oMAzF2XeaBRF7DQClfbAhd7DpCpSS3XhPu(KBkFi79W8hnVBVpuBi8MBPiw0WspwSwTMHcQpctzmu5JzOo)lmlPYYqD(xywssyXA1AgkO(imLvRYhZqD(xywsLLH68VWSKKWccFE3srgq4LHRd)GuMcQpctS0NfnSmuBi8MBPiw0WY5dk6m33r5dMbFILuzrlGmlAyXJYHnkailAybHpVBPidi8YdbCx)qDuDy79q8GIYNpOOdBhtTSp7ycCS1V9ovULIaTJH9UhUhw27n4eOmSLl)wdzVds4W8r3dl79yhtSeBGXKfyXsaKfD)Tbxhlbpk6lu27H5pAE3E3JYHnkaO9zhtTs3w)27u5wkc0og27E4EyzVtDrqD0KTGfO9oiHdZhDpSS3JDmXcsPVahcKL9OF(dZIU)2yXR4SOGfkwOcUqTXIYX3xOyb9cQpctS4fil3eNLdYI6lIL)yzfXIU)2ybiSuyFyXlqwqwkqI(wb79W8hnVBV3JLESyTAndfuFeMYyOYhZqD(xywsLfTsNLKewSwTMHcQpctz1Q8XmuN)fMLuzrR0zPplAyjaHkqOUYe88xbZqD(xywsLLyLolAyPhlwRwZenFhCaFxL9j41hYrlf2hdcxTiwaglauFsNLKew0JLzvudoOit08DWb8Dv2NGxFihTuyFmeWD9rreil9zPpljjSyTAnt08DWb8Dv2NGxFihTuyFmiC1IyjvTzbGaX0zjjHLaeQaH6ktWZFfmd5GXzrdlo(gxLJG6OHLuzb4KU9zhtT0Yw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9ybCwpOPG5aiMfnSGWN3TuKjaMdWc8VhwSOHLES0JLaeQaH6kd1ffFixLHdy5vGmd15FHzbySOfqgiYcqzPhlAPflaplZQOgCqrg8xTLkVfhF08UHk3srGS0NfnSqa31hfrGgQlk(qUkdhWYRaXsFwssyXX34QCeuhnSKQ2SaCsNfnS0Jf9y5CfvNPTM4zyltQvrgQClfbYssclwRwZe88xbd4A87HflPYsacvGqDLPTM4zyltQvrMH68VWSauwaWS0NfnSGWN3TuK52MxPYyIaKMSo)pw0WspwSwTMbWVahcmtDrqD00r1LPIguFkjZkILKew0JLaebvEDgaJpVxS0NfnSC(GIoZ9Du(GzWNyjvwSwTMj45VcgW143dlwaEws3aezjjHL2JA7Yd15FHzbySyTAntWZFfmGRXVhwSKKWsaIGkVot9O2UCZjwssyXA1AglfecQw4ZSIyrdlwRwZyPGqq1cFMH68VWSamwSwTMj45VcgW143dlwakl9yb4WcWZYSkQbhuKjA(o4a(Uk7tWRpKJwkSpgc4U(OicKL(S0NfnSOhlwRwZe88xbZkIfnS0Jf9yjarqLxNPEuBxU5eljjSeGqfiuxzcWcbeqkFBugh9ZFyZkILKewApQTlpuN)fMfGXsacvGqDLjaleqaP8TrzC0p)Hnd15FHzbOSaKzjjHL2JA7Yd15FHzbPYIwa40zbySyTAntWZFfmGRXVhwS03EhKWH5JUhw27XoMybzPaj6Bfyr3FBSGmyHaciHeKsFboeil7r)8hMfVazbewO7ybIGgDZFelaHLc7dlWHfDBuXsmuqiOAHpw0bxkqwiKh9dXIf1GdXcYsbs03kWcH8OFiS9ocFYL3r27bWCawG)9WkJp7ZoMAbqB9BVtLBPiq7yyV7H7HL9(4iOcUW52qvkJBVds4W8r3dl79yhtSCBelair1TfFyr3FBS4SGSuGe9TcSCB(XYJl0DS0gyhlaHLc7J9Ey(JM3T3TwTMj45VcMH68VWSKklAHgwssyXA1AMGN)kyaxJFpSybySeR0zrdli85DlfzcG5aSa)7HvgF2NDm1kw263ENk3srG2XWEpm)rZ727i85DlfzcG5aSa)7HvgFSOHLESOhlwRwZe88xbd4A87HflPYsSsNLKew0JLaebvEDgeuDBXhw6ZssclwRwZmocQGlCUnuLY4MvelAyXA1AMXrqfCHZTHQug3muN)fMfGXcWHfGYsawGR)mrdfEmLD1JQ6O6m33rzeUArSauw6XIESyTAnJLccbvl8zwrSOHf9y5CfvNbF(OGdOHk3srGS03E3d3dl79aPi89Uk7Qhv1r1zF2Xul9Xw)27u5wkc0og27H5pAE3EhHpVBPitamhGf4FpSY4ZE3d3dl79Vc(u(9WY(SJPwOXw)27u5wkc0og27Wi7DmD27E4EyzVJWN3TuK9ocxTi7D9yjaHkqOUYe88xbZqoyCwssyrpwq4Z7wkYeGfciGugKWXRalAyjarqLxNPEuBxU5eljjSaoRh0uWCaeBVds4W8r3dl7DaK85DlfXYctGSalwCRx93tywUn)yrNxhlhKflIfSJGazPbhwqwkqI(wbwWqwUn)y52O4S4dvhl6C8rGSaG8cFSyrn4qSCBuN9ocFYL3r27yhbLBWjh88xb7ZoMAbKT1V9ovULIaTJH9UhUhw27T1epdBzsTkYEhKWH5JUhw27XoMWSeBGOhlFJLVyXlwqVG6JWelEbYYnpHz5GSO(Iy5pwwrSO7Vnwaclf2h0YcYsbs03kWIxGSKcqp6Eeel768PZEpm)rZ727uq9ryY8v2R4SOHfpkh2OaGSOHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaJfaQpPZIgw6Xci8moOhDpckJ15txg07CuK5(aGFHILKew0JLaebvEDMIcdubhqw6ZIgwq4Z7wkYGDeuUbNCWZFfyrdl9yXA1AMXrqfCHZTHQug3muN)fMfGXcWHfail9ybnSa8SmRIAWbfzWF1wQ8wC8rZ7gQClfbYsFw0WI1Q1mJJGk4cNBdvPmUzfXsscl6XI1Q1mJJGk4cNBdvPmUzfXsF7ZoMAbeT1V9ovULIaTJH9UhUhw274ZNMRu27GeomF09WYEp2XelaOl62yz)8P5kflrdmGz5BSSF(0CLILhxO7yzfzVhM)O5D7DRvRzGfDB4Cenbk6EyzwrSOHfRvRzWNpnxPmd1gcV5wkY(SJPwayB9BVtLBPiq7yyVhM)O5D7DRvRzWNpk4aAgQZ)cZcWybnSOHLESyTAndfuFeMYyOYhZqD(xywsLf0WssclwRwZqb1hHPSAv(ygQZ)cZsQSGgw6ZIgwC8nUkhb1rdlPYcWjD7DpCpSS3dEfiv2A1A27wRwlxEhzVJpFuWb0(SJPwahB9BVtLBPiq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JTRUimlPadeyXIAWHybzWcbeqILf(luSCBelidwiGasSeGf4FpSy5GSe2OaGS8nwqgSqabKy5XS4HB5kvCwCl46y5GSyrSeC8zVhM)O5D79aebvEDM6rTD5MtSOHfe(8ULImbyHaciLbjC8kWIgwcqOceQRmbyHaciLVnkJJ(5pSzOo)lmlaJf0WIgw0JfWz9GMcMdGyw0WcfuFeMmFL9kolAyXX34QCeuhnSKkl6t62NDmby6263ENk3srG2XWE3d3dl7D85tZvk7DqchMp6EyzVh7yIL9ZNMRuSO7Vnw2psP8HLy78TJfVazPGSSF(OGdiAzr3gvSuqw2pFAUsXYJzzfHwwIdxS4dXYxSG(RYhwqVG6JWeln4WcagOykGzboSCqwIgyGfGWsH9HfDBuXIBbrqSaCsNLuGbcSahwCWi)EeelyD(0XYMJzbadumfWSmuN)1xOyboS8yw(ILM6rTDgwIj8iwUn)yzvG0WYTrSG9oILaSa)7HfML)qhMfWimlfTUXvSCqw2pFAUsXc4A(cflaiCeubxywIndvPmoAzr3gvSehUqhil47vkwOcKLvel6(BJfGt6a1XrS0Gdl3gXIYXhlOuqlxHn27H5pAE3E)CfvNbFKs5tgC(2zOYTueilAyrpwoxr1zWNpk4aAOYTueilAyXA1Ag85tZvkZqTHWBULIyrdl9yXA1AgkO(imLvRYhZqD(xywsLfamlAyHcQpctMVYQv5dlAyXA1AMO57Gd47QSpbV(qoAPW(yq4QfXcWybGOjDwssyXA1AMO57Gd47QSpbV(qoAPW(yq4QfXsQAZcart6SOHfhFJRYrqD0WsQSaCsNLKewaHNXb9O7rqzSoF6YGENJImd15FHzjvwaWSKKWIhUhwgh0JUhbLX68Pld6DokY8vUPEuBhl9zrdlbiubc1vMGN)kygQZ)cZsQSOv62NDmbOw263ENk3srG2XWE3d3dl7D85dEnOi7DqchMp6EyzVh7yIL9Zh8AqrSaGUOBJLObgWS4filGRUiwsbgiWIUnQybzPaj6BfyboSCBelair1TfFyXA1AS8ywCl46y5GS0CLIfyRXcCyjoCHoqwcEelPadeS3dZF08U9U1Q1mWIUnCoOiFYiE8dlZkILKewSwTMbWVahcmtDrqD00r1LPIguFkjZkILKewSwTMj45VcMvelAyPhlwRwZmocQGlCUnuLY4MH68VWSamwqfanDoYzb4zjqVILES44BCvocQJgwqclXkDw6ZcqzjwSa8SCUIQZuKUChewgQClfbYIgw0JLzvudoOid(R2sL3IJpAE3qLBPiqw0WI1Q1mJJGk4cNBdvPmUzfXssclwRwZe88xbZqD(xywaglOcGMoh5Sa8SeOxXspwC8nUkhb1rdliHLyLol9zjjHfRvRzghbvWfo3gQsz8m(R2sL3IJpAE3SIyjjHf9yXA1AMXrqfCHZTHQug3SIyrdl6XsacvGqDLzCeubx4CBOkLXnd5GXzjjHf9yjarqLxNbbv3w8HL(SKKWIJVXv5iOoAyjvwaoPZIgwOG6JWK5RSxXTp7ycqaARF7DQClfbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9U(N4SCqw6CajwUnIflcFSaBSSF(OGdilwXzbFEaWVqXYFSSIyb4U(aGQ4S8flEfNf0lO(imXI16ybiSuyFy5X1XIBbxhlhKflILObgceO9Ey(JM3T3pxr1zWNpk4aAOYTueilAyrpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazrdl9yXA1Ag85JcoGMveljjS44BCvocQJgwsLfGt6S0NfnSyTAnd(8rbhqd(8aGSamwIflAyPhlwRwZqb1hHPmgQ8XSIyjjHfRvRzOG6JWuwTkFmRiw6ZIgwSwTMjA(o4a(Uk7tWRpKJwkSpgeUArSamwaiqmDw0WspwcqOceQRmbp)vWmuN)fMLuzrR0zjjHf9ybHpVBPitawiGaszqchVcSOHLaebvEDM6rTD5MtS03(SJjaJLT(T3PYTueODmS3Hr27y6S39W9WYEhHpVBPi7DeUAr27uq9ryY8vwTkFyb4zbaZcsyXd3dld(8P9dziKtH1r577iwakl6XcfuFeMmFLvRYhwaEw6XcqMfGYY5kQodgUuzylFBuUbhcFgQClfbYcWZsSyPpliHfpCpSm6g)2meYPW6O89DelaLL0n6dAybjSGJiLkV54JybOSKUbnSa8SCUIQZu(TgcNTCLxbYqLBPiq7DqchMp6EyzVJE4778JWSSb1Xs3kSXskWabw8HybL)fbYsenSGPaSaT3r4tU8oYE3XrabA2PG9zhtaQp263ENk3srG2XWE3d3dl7D85dEnOi7DqchMp6EyzVhBxDrSSF(GxdkILVyXzbicumfyzhQ8Hf0lO(imHwwaHf6owu0XYFSenWalaHLc7dl9Un)y5XSS5fOIazXkol0FB0WYTrSSF(0CLIf1xelWHLBJyjfyGqQaN0zr9fXsdoSSF(GxdkQpAzbewO7ybIGgDZFelEXca6IUnwIgyGfVazrrhl3gXIBbrqSO(IyzZlqfXY(5JcoG27H5pAE3ExpwMvrn4GIm33r6GtLbhY7S(cKgdvULIazrdl9yXA1AMO57Gd47QSpbV(qoAPW(yq4QfXcWybGaX0zjjHfRvRzIMVdoGVRY(e86d5OLc7JbHRwelaJfaIM0zrdlNRO6m4JukFYGZ3odvULIazPplAyPhluq9ryY8vgdv(WIgwC8nUkhb1rdlaLfe(8ULImoociqZofyb4zXA1AgkO(imLXqLpMH68VWSauwaHNPTM4zyltQvrM7daIZd15FXcWZcanOHLuzbaNoljjSqb1hHjZxz1Q8HfnS44BCvocQJgwakli85DlfzCCeqGMDkWcWZI1Q1muq9rykRwLpMH68VWSauwaHNPTM4zyltQvrM7daIZd15FXcWZcanOHLuzb4Kol9zrdl6XI1Q1mWIUnCoIMafDpSmRiw0WIESCUIQZGpFuWb0qLBPiqw0WspwcqOceQRmbp)vWmuN)fMLuzbiYsscly4sz9fO52MxPYyIaKgdvULIazrdlwRwZCBZRuzmrasJbFEaqwaglXkwSaazPhlZQOgCqrg8xTLkVfhF08UHk3srGSa8SGgw6ZIgwApQTlpuN)fMLuzrR0tNfnS0EuBxEOo)lmlaJfaME6S0NfnS0JLaeQaH6kdGFboeygh9ZFyZqD(xywsLfGiljjSOhlbicQ86magFEVyPV9zhtaIgB9BVtLBPiq7yyV7H7HL9Er6YDqyzVds4W8r3dl79yhtSaGcclmlFXc6VkFyb9cQpctS4filyhbXcszCvdOXMLsXcakiSyPbhwqwkqI(wbw8cKfKsFboeilOxxeuhnDuD27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSKKWspwcB(GIWSOnlaKfnSmuyZhuu((oIfGXcAyPpljjSe28bfHzrBwIfl9zrdlEuoSrbazrdli85DlfzWock3Gto45Vc2NDmbiq2w)27u5wkc0og27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSOHf9yjarqLxNbW4Z7fljjS0JfRvRza8lWHaZuxeuhnDuDzQOb1NsYSIyrdlbicQ86magFEVyPpljjS0JLWMpOimlAZcazrdldf28bfLVVJybySGgw6ZssclHnFqryw0MLyXssclwRwZe88xbZkIL(SOHfpkh2OaGSOHfe(8ULImyhbLBWjh88xbw0WspwSwTMzCeubx4CBOkLXnd15FHzbyS0Jf0WcaKfaYcWZYSkQbhuKb)vBPYBXXhnVBOYTueil9zrdlwRwZmocQGlCUnuLY4MveljjSOhlwRwZmocQGlCUnuLY4Mvel9T39W9WYEFZvTChew2NDmbiq0w)27u5wkc0og27H5pAE3EVhlwRwZqb1hHPSAv(ygQZ)cZsQSqiNcRJY33rSOHf9yjarqLxNbW4Z7fljjS0JfRvRza8lWHaZuxeuhnDuDzQOb1NsYSIyrdlbicQ86magFEVyPpljjS0JLWMpOimlAZcazrdldf28bfLVVJybySGgw6ZssclHnFqryw0MLyXssclwRwZe88xbZkIL(SOHfpkh2OaGSOHfe(8ULImyhbLBWjh88xbw0WspwSwTMzCeubx4CBOkLXnd15FHzbySGgw0WI1Q1mJJGk4cNBdvPmUzfXIgw0JLzvudoOid(R2sL3IJpAE3qLBPiqwssyrpwSwTMzCeubx4CBOkLXnRiw6BV7H7HL9EBPu5oiSSp7ycqaST(T3PYTueODmS3bjCy(O7HL9ESJjwqkGOhlWILaO9UhUhw2768zE4KHTmPwfzF2XeGahB9BVtLBPiq7yyV7H7HL9o(8P9dzVds4W8r3dl79yhtSSF(0(Hy5GSenWal7qLpSGEb1hHj0YcYsbs03kWYMJzrryml33rSCBEXIZcsX43gleYPW6iwuu7yboSalvCwq)v5dlOxq9ryILhZYkYEpm)rZ727uq9ryY8vwTkFyjjHfkO(imzWqLp5Iq(Xsscluq9ryY4v8Cri)yjjHLESyTAnJoFMhozyltQvrMveljjSGJiLkV54JybySKUrFqdlAyrpwcqeu51zqq1TfFyjjHfCePu5nhFelaJL0n6dlAyjarqLxNbbv3w8HL(SOHfRvRzOG6JWuwTkFmRiwssyPhlwRwZe88xbZqD(xywaglE4Eyz0n(TziKtH1r577iw0WI1Q1mbp)vWSIyPV9zhZyLUT(T3PYTueODmS3bjCy(O7HL9ESJjwqkg)2ybEB0O7Xel62(WglpMLVyzhQ8Hf0lO(imHwwqwkqI(wbwGdlhKLObgyb9xLpSGEb1hHj7DpCpSS31n(TzF2XmwAzRF7DQClfbAhd7DqchMp6EyzVhBCL62ML9UhUhw27ZQYE4EyLvp(S3vp(YL3r27nxPUTzzF2N9E0qbyNLF263oMAzRF7DpCpSS3b8lWHaZ4OF(dBVtLBPiq7yyF2XeG263ENk3srG2XWEhgzVJPZE3d3dl7De(8ULIS3r4QfzVNU9oiHdZhDpSS31)gXccFE3srS8ywW0XYbzjDw093glfKf85hlWILfMy5MVaKomAzrlw0Trfl3gXs7h8XcSiwEmlWILfMqllaKLVXYTrSGPaSaz5XS4filXILVXIf82yXhYEhHp5Y7i7DyLxykFZxasN9zhZyzRF7DQClfbAhd7DyK9UdcAV7H7HL9ocFE3sr27iC1IS31YEpm)rZ72738fG0zoTmBooVWu2A1ASOHLB(cq6mNwMaeQaH6kd4A87HflAyrpwU5laPZCAzES5GDug2YDWcFdCHZbyHVzfUhwy7De(KlVJS3HvEHP8nFbiD2NDm1hB9BVtLBPiq7yyVdJS3Dqq7DpCpSS3r4Z7wkYEhHRwK9oaT3dZF08U9(nFbiDMdGMnhNxykBTAnw0WYnFbiDMdGMaeQaH6kd4A87HflAyrpwU5laPZCa08yZb7OmSL7Gf(g4cNdWcFZkCpSW27i8jxEhzVdR8ct5B(cq6Sp7yIgB9BVtLBPiq7yyVdJS3Dqq7DpCpSS3r4Z7wkYEhHp5Y7i7DyLxykFZxasN9Ey(JM3T3jG76JIiqZx4WSo3srzG7YRB1LbjeFGyjjHfc4U(Oic0qDrXhYvz4awEfiwssyHaURpkIany4sPO7(cvEwwXT3bjCy(O7HL9U(3imXYnFbiDyw8HyPGhl(6687dUsfNfq6OWrGS4ywGfllmXc(8JLB(cq6WgwsHsNhhZIdc(fkw0ILoYlml3gfNfDVsXIR05XXSyrSenuJMHaz5lqkIkqQowGnwWk4zVJWvlYExl7ZoMazB9BV7H7HL9Ehewa(vUbNo7DQClfbAhd7ZoMarB9BVtLBPiq7yyV7H7HL9UUXVn7D1xuoaAVRv627H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY8vgdv(Wsscluq9ryY8v2cEBSKKWcfuFeMmEfpxeYpw6BVds4W8r3dl7DGWqbhFSaqwqkg)2yXlqwCw2pFWRbfXcSyzx)SO7VnwI5JA7yj24elEbYsmGPq)Sahw2pFA)qSaVnA09yY(SJja2w)27u5wkc0og27H5pAE3EVhluq9ryYOwLp5Iq(Xsscluq9ryY8vgdv(Wsscluq9ryY8v2cEBSKKWcfuFeMmEfpxeYpw6ZIgwIgcHrlJUXVnw0WIESenecdan6g)2S39W9WYEx343M9zhtGJT(T3PYTueODmS3dZF08U9UESmRIAWbfzSCLxbkdBzxPY32xOWgQClfbYsscl6XsaIGkVot9O2UCZjwssyrpwWrKsLpFqrh2GpFAUsXI2SOfljjSOhlNRO6mLFRHWzlx5vGmu5wkcKLKew6XcfuFeMmyOYNCri)yjjHfkO(imz(kRwLpSKKWcfuFeMmFLTG3gljjSqb1hHjJxXZfH8JL(27E4EyzVJpFA)q2NDm1kDB9BVtLBPiq7yyVhM)O5D79zvudoOiJLR8kqzyl7kv(2(cf2qLBPiqw0WsaIGkVot9O2UCZjw0WcoIuQ85dk6Wg85tZvkw0MfTS39W9WYEhF(GxdkY(Sp7ZEhbn4hw2XeGPdqTshiQv62768P(cf2EhPifaiIP(gtKYbsSWI(3iw(Ui4CS0GdlOdKA(sDOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon0)lIf9biXcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl90c59nCAO)xel6dqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B40q)ViwqdqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B40q)ViwaYajwqgSqqZrGSS)DiJfC86CKZcsLLdYc6VCwaFep(HflWiA8doS0dj9zPharEFdNg6)fXcqeiXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelarGelidwiO5iqwq3nFbiDgTmaa0XYbzbD38fG0zoTmaa0XspaI8(gon0)lIfGiqIfKble0CeilO7MVaKodanaa0XYbzbD38fG0zoaAaaOJLEae59nCAO)xelayGelidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPH(FrSaCasSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNg6)fXIwPdKybzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gon0)lIfT0ciXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelAbqGelidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPH(FrSOvSasSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspaI8(gon0)lIfTIfqIfKble0CeilO7MVaKoJwgaa6y5GSGUB(cq6mNwgaa6yPharEFdNg6)fXIwXciXcYGfcAocKf0DZxasNbGgaa6y5GSGUB(cq6mhanaa0XspTqEFdNg6)fXIw6dqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6bqK33WPH(FrSOL(aKybzWcbnhbYc6U5laPZOLbaGowoilO7MVaKoZPLbaGow6PfY7B40q)Viw0sFasSGmyHGMJazbD38fG0zaObaGowoilO7MVaKoZbqdaaDS0dGiVVHtJtdPifaiIP(gtKYbsSWI(3iw(Ui4CS0GdlOlAOaSZYp0XYqa31peilyyhXIVoyNFeilHnVqrydNg6)fXsSasSGmyHGMJazbD38fG0z0YaaqhlhKf0DZxasN50Yaaqhl9IfY7B40q)Viw0hGelidwiO5iqwq3nFbiDgaAaaOJLdYc6U5laPZCa0aaqhl9IfY7B40q)ViwaoajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHtd9)IyrR0bsSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNgNgsrkaqet9nMiLdKyHf9VrS8DrW5yPbhwqNdj0XYqa31peilyyhXIVoyNFeilHnVqrydNg6)fXIwajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yXpwqpa0Opl90c59nCAO)xelXciXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelazGelidwiO5iqw2)oKXcoEDoYzbPIuz5GSG(lNLoi4sTWSaJOXp4WspKAFw6PfY7B40q)ViwaYajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPharEFdNg6)fXcqeiXcYGfcAocKL9VdzSGJxNJCwqQivwoilO)YzPdcUulmlWiA8doS0dP2NLEAH8(gon0)lIfGiqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B40q)ViwaWajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHtd9)Iyb4aKybzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEae59nCAO)xelAbqGelidwiO5iqw2)oKXcoEDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0tlK33WPH(FrSOfWbiXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelaulGelidwiO5iqw2)oKXcoEDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0tlK33WPH(FrSaWybKybzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEae59nCAO)xelamwajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHtd9)IybGObiXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelaeidKybzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gon0)lIfacGbsSGmyHGMJazz)7qgl4415iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspaI8(gon0)lIfacCasSGmyHGMJazz)7qgl4415iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspTqEFdNgNgsrkaqet9nMiLdKyHf9VrS8DrW5yPbhwqxZvQBBwOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon0)lIfacKybzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEAH8(gononKIuaGiM6BmrkhiXcl6FJy57IGZXsdoSGo8Howgc4U(Hazbd7iw81b78JazjS5fkcB40q)Viw0ciXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelXciXcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvULIarhl90c59nCAO)xelAPfqIfKble0Ceil7FhYybhVoh5SGurQSCqwq)LZsheCPwywGr04hCyPhsTpl90c59nCAO)xelAPfqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B40q)Viw0cidKybzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHk3srGOJLEAH8(gon0)lIfaQfqIfKble0Ceil7FhYybhVoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6bqK33WPH(FrSaqTasSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLBPiq0XspTqEFdNg6)fXcabiqIfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQClfbIow6PfY7B40q)ViwaySasSGmyHGMJazz)7qgl4415iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZsVyH8(gon0)lIfaQpajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPharEFdNg6)fXcabYajwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYTuei6yPNwiVVHtd9)IybGarGelidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5wkceDS0tlK33WPXPHuKcaeXuFJjs5ajwyr)BelFxeCowAWHf0zb9dDSmeWD9dbYcg2rS4Rd25hbYsyZlue2WPH(FrSOfagiXcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9IfY7B40q)Viw0c4aKybzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEAH8(gonon9TlcohbYcqMfpCpSyr94dB40S3Jgy7vK9osJ0Sedx5vGyj2oRhKtdPrAwsBPIZIwaeTSaW0bOwCACAinsZcY28cfHbsCAinsZcaKLuacsGSSdv(WsmiVZWPH0inlaqwq2MxOiqwoFqrx(BSeCmHz5GSeIhuu(8bfDydNgsJ0Saazbab1brqGSSQIceg7tCwq4Z7wkcZsV3qg0Ys0qiY4Zh8AqrSaatLLOHqyWNp41GI6B40qAKMfailPab8bzjAOGJVVqXcsX43glFJL)qhMLBJyr3aluSGEb1hHjdNgsJ0SaazbaLdiXcYGfciGel3gXYE0p)HzXzr93Piw6GdXstri)Tuel9(glXHlw2CWcDhlB)XYFSG)UL68IGlSkol6(BJLyaGof6NfGYcYifHV3vSKc1JQ6O6qll)HoqwWa(r9nCAinsZcaKfauoGelDq8Xc6ApQTlpuN)fgDSGdu5ZdXS4rrQ4SCqwSGymlTh12HzbwQ4gonKgPzbaYI(hYpw0pSJyb2yjgkFJLyO8nwIHY3yXXS4SGJOW7kwU5laPZWPXPH0inlPOk45hbYsmCLxbILuaeqFwcEXIfXsdUkqw8JLT7IWajKGelx5vGaG4Vlyq932YY8qKedx5vGaG7FhYqshOz76uiLT9ksBlx5vGmhYpononpCpSWMOHcWol)0gWVahcmJJ(5pmNgsZI(3iwq4Z7wkILhZcMowoilPZIU)2yPGSGp)ybwSSWel38fG0HrllAXIUnQy52iwA)GpwGfXYJzbwSSWeAzbGS8nwUnIfmfGfilpMfVazjwS8nwSG3gl(qCAE4EyHnrdfGDw(buTrccFE3srOT8osByLxykFZxashAr4QfPD6CAE4EyHnrdfGDw(buTrccFE3srOT8osByLxykFZxashAHrA7GGOfHRwK2AH2VP9nFbiDgTmBooVWu2A1AAU5laPZOLjaHkqOUYaUg)EyPrVB(cq6mAzES5GDug2YDWcFdCHZbyHVzfUhwyonpCpSWMOHcWol)aQ2ibHpVBPi0wEhPnSYlmLV5laPdTWiTDqq0IWvlsBaI2VP9nFbiDgaA2CCEHPS1Q10CZxasNbGMaeQaH6kd4A87HLg9U5laPZaqZJnhSJYWwUdw4BGlCoal8nRW9WcZPH0SO)nctSCZxashMfFiwk4XIVUo)(GRuXzbKokCeiloMfyXYctSGp)y5MVaKoSHLuO05XXS4GGFHIfTyPJ8cZYTrXzr3RuS4kDECmlwelrd1Oziqw(cKIOcKQJfyJfScECAE4EyHnrdfGDw(buTrccFE3srOT8osByLxykFZxashAHrA7GGOfHRwK2AH2VPnbCxFuebA(chM15wkkdCxEDRUmiH4duscbCxFuebAOUO4d5QmCalVcuscbCxFuebAWWLsr39fQ8SSIZP5H7Hf2enua2z5hq1gjDqyb4x5gC640qAwacdfC8XcazbPy8BJfVazXzz)8bVguelWILD9ZIU)2yjMpQTJLyJtS4filXaMc9ZcCyz)8P9dXc82Or3JjonpCpSWMOHcWol)aQ2ir343gAvFr5aO2ALoA)M29OG6JWKrTkFYfH8ljHcQpctMVYyOYNKekO(imz(kBbVTKekO(imz8kEUiKF9508W9WcBIgka7S8dOAJeDJFBO9BA3JcQpctg1Q8jxeYVKekO(imz(kJHkFssOG6JWK5RSf82ssOG6JWKXR45Iq(1xt0qimAz0n(TPrVOHqyaOr343gNMhUhwyt0qbyNLFavBKGpFA)qO9BAR3SkQbhuKXYvEfOmSLDLkFBFHcNKOxaIGkVot9O2UCZPKe9WrKsLpFqrh2GpFAUsPTwjj6DUIQZu(TgcNTCLxbYqLBPiWKKEuq9ryYGHkFYfH8ljHcQpctMVYQv5tscfuFeMmFLTG3wscfuFeMmEfpxeYV(CAE4EyHnrdfGDw(buTrc(8bVgueA)M2ZQOgCqrglx5vGYWw2vQ8T9fkSMaebvEDM6rTD5MtAWrKsLpFqrh2GpFAUsPTwCACAinsZc6HCkSocKfcbnXz5(oILBJyXdhCy5XS4i8x5wkYWP5H7HfwBmu5t2I8oonKMLD6WSKci6XcSyjwaLfD)TbxhlGZ3ow8cKfD)TXY(5JcoGS4filaeOSaVnA09yItZd3dlmq1gji85DlfH2Y7iTFC2HeAr4QfPnoIuQ85dk6Wg85tZvQu1stp9oxr1zWNpk4aAOYTueysY5kQod(iLYNm48TZqLBPiW(jj4isPYNpOOdBWNpnxPsfGCAinl70HzjOihbXIUnQyz)8P9dXsWlw2(JfacuwoFqrhMfDBFyJLhZYqkcHxhln4WYTrSGEb1hHjwoilwelrd1Oziqw8cKfDBFyJL2Ru0WYbzj44JtZd3dlmq1gji85DlfH2Y7iTFCoOihbHweUArAJJiLkF(GIoSbF(0(HsvlonKMLyhtSedAW0a4xOyr3FBSGSuGe9TcSahw82rdlidwiGasS8flilfirFRaNMhUhwyGQnsSObtdGFHcTFt7E6fGiOYRZupQTl3CkjrVaeQaH6ktawiGas5BJY4OF(dBwr91yTAntWZFfmd15FHtvl0OXA1AMXrqfCHZTHQug3muN)fgy6Jg9cqeu51zqq1TfFsscqeu51zqq1TfF0yTAntWZFfmRinwRwZmocQGlCUnuLY4MvKMEwRwZmocQGlCUnuLY4MH68VWatlTaGOb4Nvrn4GIm4VAlvElo(O59KeRvRzcE(RGzOo)lmW0sRKeTqQ4isPYBo(iGPLbnOPpNgsZcqaESO7VnwCwqwkqI(wbwUn)y5Xf6owCwaclf2hwIgyGf4WIUnQy52iwApQTJLhZIBbxhlhKfQa508W9WcduTrse8EyH2VPT1Q1mbp)vWmuN)fovTqJME6nRIAWbfzWF1wQ8wC8rZ7jjwRwZmocQGlCUnuLY4MH68VWatlGiaeGaV1Q1mwkieuTWNzfPXA1AMXrqfCHZTHQug3SI6NK0EuBxEOo)lmWaiA40qAwqMRclLFeMfDB0Trdll8xOybzWcbeqILcQJfDVsXIRuqDSehUy5GSGVxPyj44JLBJyb7DelEhCvhlWglidwiGasafzPaj6Bfyj44dZP5H7HfgOAJee(8ULIqB5DK2byHaciLbjC8kGweUArAhOx1Rx7rTD5H68VWaqTqdamaHkqOUYe88xbZqD(x4(ivTaWP3x7a9QE9ApQTlpuN)fgaQfAaGAbW0bGbiubc1vMaSqabKY3gLXr)8h2muN)fUpsvlaC691O34pyMqq1zCqqSHq(JpCssacvGqDLj45VcMH68VWP(1rteu5hbMBpQTlpuN)fojjaHkqOUYeGfciGu(2Omo6N)WMH68VWP(1rteu5hbMBpQTlpuN)fgaQv6jj6fGiOYRZupQTl3CkjXd3dltawiGas5BJY4OF(dBaFSBPiqonKMLyhtGSCqwajLhNLBJyzHDuelWglilfirFRal62OILf(luSacxwkIfyXYctS4filrdHGQJLf2rrSOBJkw8IfheKfcbvhlpMf3cUowoilGpXP5H7HfgOAJee(8ULIqB5DK2bWCawG)9WcTiC1I0Ux7rTD5H68VWPQfAssg)bZecQoJdcInFLkAsVVME96ra31hfrGgQlk(qUkdhWYRaPPxVaeQaH6kd1ffFixLHdy5vGmd15FHbMwa50tscqeu51zqq1TfF0eGqfiuxzOUO4d5QmCalVcKzOo)lmW0cidebApT0c4Nvrn4GIm4VAlvElo(O59(91OxacvGqDLH6IIpKRYWbS8kqMHCW497NK0JaURpkIany4sPO7(cvEwwX10tVaebvEDM6rTD5Mtjjbiubc1vgmCPu0DFHkplR45yPpObaNUwMH68VWatlT0N(9ts6fGqfiuxzSObtdGFHYmKdgpjrVXdK5gOs1xtVEeWD9rreO5lCywNBPOmWD51T6YGeIpqAcqOceQRmFHdZ6ClfLbUlVUvxgKq8bYmKdgVFsspc4U(Oic0G3CqOocmdhRmSLp40r1PjaHkqOUYCWPJQJaZFHFuBxowObnXcGAzgQZ)c3pjPxpe(8ULImWkVWu(MVaKoT1kjbHpVBPidSYlmLV5laPt7y1xtVB(cq6mAzgYbJNdqOceQRssU5laPZOLjaHkqOUYmuN)fo1VoAIGk)iWC7rTD5H68VWaqTsVFsccFE3srgyLxykFZxasN2autVB(cq6ma0mKdgphGqfiuxLKCZxasNbGMaeQaH6kZqD(x4u)6OjcQ8JaZTh12LhQZ)cda1k9(jji85DlfzGvEHP8nFbiDANE)(9tscqeu51zam(8E1pjP9O2U8qD(xyGzTAntWZFfmGRXVhwCAinlai5Z7wkILfMaz5GSaskpolEfNLB(cq6WS4filbqml62OIfD(FFHILgCyXlwqVv0gCENLObg408W9WcduTrccFE3srOT8os7BBELkJjcqAY68)qlcxTiT1ddxkRVan328kvgteG0yOYTueyss7rTD5H68VWPcW0tpjP9O2U8qD(xyGbq0a0E6t6aqRvRzUT5vQmMiaPXGppaiWdW(jjwRwZCBZRuzmrasJbFEaWuJfaga2Bwf1GdkYG)QTu5T44JM3bE00NtdPzj2XelOxxu8HCflaOhWYRaXcathtbmlwudoelolilfirFRallmz408W9WcduTrYct5)Oo0wEhPn1ffFixLHdy5vGq730oaHkqOUYe88xbZqD(xyGbW01eGqfiuxzcWcbeqkFBugh9ZFyZqD(xyGbW010dHpVBPiZTnVsLXebinzD(FjjwRwZCBZRuzmrasJbFEaWuJv6aT3SkQbhuKb)vBPYBXXhnVd8a5(9tsApQTlpuN)fgyXciYPH0Se7yILD4sPO7luSaGyzfNfGmMcywSOgCiwCwqwkqI(wbwwyYWP5H7HfgOAJKfMY)rDOT8osBmCPu0DFHkplR4O9BAhGqfiuxzcE(RGzOo)lmWaYA0larqLxNbbv3w8rJEbicQ86m1JA7YnNsscqeu51zQh12LBoPjaHkqOUYeGfciGu(2Omo6N)WMH68VWadiRPhcFE3srMaSqabKYGeoEfsscqOceQRmbp)vWmuN)fgya5(jjbicQ86miO62IpA6P3SkQbhuKb)vBPYBXXhnVRjaHkqOUYe88xbZqD(xyGbKtsSwTMzCeubx4CBOkLXnd15FHbMw6dq7HgGNaURpkIanFHVzfo4GZGpIVOSfPu91yTAnZ4iOcUW52qvkJBwr9tsApQTlpuN)fgyaenCAE4EyHbQ2izHP8FuhAlVJ0(lCywNBPOmWD51T6YGeIpqO9BABTAntWZFfmd15FHtvl0OPNEZQOgCqrg8xTLkVfhF08EsI1Q1mJJGk4cNBdvPmUzOo)lmW0cGaTxSaERvRzSuqiOAHpZkQpq71dicardWBTAnJLccbvl8zwr9bEc4U(Oic08f(Mv4Gdod(i(IYwKs1xJ1Q1mJJGk4cNBdvPmUzf1pjP9O2U8qD(xyGbq0WPH0Se7yIL5rTDSyrn4qSeaXCAE4EyHbQ2izHP8FuhAlVJ0gV5GqDeygowzylFWPJQdTFt7Ebiubc1vMGN)kygYbJRrVaebvEDM6rTD5MtAq4Z7wkYCBZRuzmrastwN)xssaIGkVot9O2UCZjnbiubc1vMaSqabKY3gLXr)8h2mKdgxtpe(8ULImbyHaciLbjC8kKKeGqfiuxzcE(RGzihmE)(AaHNbVQ2pK5(aGFHstpq4zWhPu(KBkFiZ9ba)cvsIENRO6m4JukFYnLpKHk3srGjj4isPYNpOOdBWNpTFOuJvFn9aHNPdcR2pK5(aGFHQVMEi85DlfzEC2HusYSkQbhuKXYvEfOmSLDLkFBFHcNK44BCvocQJMu1g4KEsI1Q1mwkieuTWNzf1xtVaeQaH6kJfnyAa8luMHCW4jj6nEGm3avQ(jjTh12LhQZ)cdm9jDonKMf9V9ywEmlolJFB0WcPCl44hXIopolhKLohqIfxPybwSSWel4ZpwU5laPdZYbzXIyr9fbYYkIfD)TXcYsbs03kWIxGSGmyHaciXIxGSSWel3gXcalqwWk4XcSyjaYY3yXcEBSCZxashMfFiwGfllmXc(8JLB(cq6WCAE4EyHbQ2izHP8FuhgTyf8WAFZxasNwO9BAJWN3TuKbw5fMY38fG0Pna1O3nFbiDgaAgYbJNdqOceQRss6HWN3TuKbw5fMY38fG0PTwjji85DlfzGvEHP8nFbiDAhR(A6zTAntWZFfmRin90larqLxNbbv3w8jjXA1AMXrqfCHZTHQug3muN)fgO9qdWpRIAWbfzWF1wQ8wC8rZ79bM238fG0z0YyTATm4A87HLgRvRzghbvWfo3gQszCZkkjXA1AMXrqfCHZTHQugpJ)QTu5T44JM3nRO(jjbiubc1vMGN)kygQZ)cduaM6nFbiDgTmbiubc1vgW143dln6zTAntWZFfmRin90larqLxNPEuBxU5usIEi85DlfzcWcbeqkds44vOVg9cqeu51zam(8ELKeGiOYRZupQTl3CsdcFE3srMaSqabKYGeoEf0eGqfiuxzcWcbeqkFBugh9ZFyZksJEbiubc1vMGN)kywrA61ZA1AgkO(imLvRYhZqD(x4u1k9KeRvRzOG6JWugdv(ygQZ)cNQwP3xJEZQOgCqrglx5vGYWw2vQ8T9fkCsspRvRzSCLxbkdBzxPY32xOW5YV1qg85ba1gnjjwRwZy5kVcug2YUsLVTVqHZ(e8Im4ZdaQnaUF)KeRvRza8lWHaZuxeuhnDuDzQOb1NsYSI6NK0EuBxEOo)lmWay6jji85DlfzGvEHP8nFbiDANoNMhUhwyGQnswyk)h1HrlwbpS238fG0bq0(nTr4Z7wkYaR8ct5B(cq60tBaQrVB(cq6mAzgYbJNdqOceQRssq4Z7wkYaR8ct5B(cq60gGA6zTAntWZFfmRin90larqLxNbbv3w8jjXA1AMXrqfCHZTHQug3muN)fgO9qdWpRIAWbfzWF1wQ8wC8rZ79bM238fG0zaOXA1AzW143dlnwRwZmocQGlCUnuLY4MvusI1Q1mJJGk4cNBdvPmEg)vBPYBXXhnVBwr9tscqOceQRmbp)vWmuN)fgOam1B(cq6ma0eGqfiuxzaxJFpS0ON1Q1mbp)vWSI00tVaebvEDM6rTD5Mtjj6HWN3TuKjaleqaPmiHJxH(A0larqLxNbW4Z7LME6zTAntWZFfmROKe9cqeu51zqq1TfF6NKeGiOYRZupQTl3CsdcFE3srMaSqabKYGeoEf0eGqfiuxzcWcbeqkFBugh9ZFyZksJEbiubc1vMGN)kywrA61ZA1AgkO(imLvRYhZqD(x4u1k9KeRvRzOG6JWugdv(ygQZ)cNQwP3xJEZQOgCqrglx5vGYWw2vQ8T9fkCsspRvRzSCLxbkdBzxPY32xOW5YV1qg85ba1gnjjwRwZy5kVcug2YUsLVTVqHZ(e8Im4ZdaQnaUF)(jjwRwZa4xGdbMPUiOoA6O6YurdQpLKzfLK0EuBxEOo)lmWay6jji85DlfzGvEHP8nFbiDANoNgsZsSJjmlUsXc82OHfyXYctS8h1HzbwSea508W9WcduTrYct5)OomNgsZsSLcpiXIhUhwSOE8XILJjqwGfl4)w(9Wcjkc1J508W9WcduTrYSQShUhwz1Jp0wEhPTdj0IV5dN2AH2VPncFE3srMhNDiXP5H7HfgOAJKzvzpCpSYQhFOT8osBlOFOfFZhoT1cTFt7zvudoOiJLR8kqzyl7kv(2(cf2qa31hfrGCAE4EyHbQ2izwv2d3dRS6XhAlVJ0gFCACAinliZvHLYpcZIUn62OHLBJyj2oK3f8lSrdlwRwJfDVsXsZvkwGTgl6(B7lwUnILIq(XsWXhNMhUhwyJdjTr4Z7wkcTL3rAdoK3L19kvU5kvg2AOfHRwK29SwTM5(oshCQm4qEN1xG0ygQZ)cdmubqtNJCGMUrRKeRvRzUVJ0bNkdoK3z9finMH68VWaZd3dld(8P9dziKtH1r577iGMUrln9OG6JWK5RSAv(KKqb1hHjdgQ8jxeYVKekO(imz8kEUiKF97RXA1AM77iDWPYGd5DwFbsJzfPzwf1GdkYCFhPdovgCiVZ6lqA40qAwqMRclLFeMfDB0Trdl7Np41GIy5XSOdo3glbhFFHIficAyz)8P9dXYxSG(RYhwqVG6JWeNMhUhwyJdjGQnsq4Z7wkcTL3rA)Ok4qz85dEnOi0IWvlsB9OG6JWK5RmgQ8rtpCePu5Zhu0Hn4ZN2puQOrZ5kQodgUuzylFBuUbhcFgQClfbMKGJiLkF(GIoSbF(0(Hsfi2NtdPzj2XelidwiGasSOBJkw8JffHXSCBEXcAsNLuGbcS4filQViwwrSO7VnwqwkqI(wbonpCpSWghsavBKeGfciGu(2Omo6N)WO9BARh4SEqtbZbqSME9q4Z7wkYeGfciGugKWXRGg9cqOceQRmbp)vWmKdgpjXA1AMGN)kywr910ZA1AgkO(imLvRYhZqD(x4ubYjjwRwZqb1hHPmgQ8XmuN)fovGCFn90Bwf1GdkYy5kVcug2YUsLVTVqHtsSwTMXYvEfOmSLDLkFBFHcNl)wdzWNham1yLKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppayQXQFss7rTD5H68VWatR01OxacvGqDLj45VcMHCW4950qAwIDmXsSzOkLXzr3FBSGSuGe9TcCAE4EyHnoKaQ2izCeubx4CBOkLXr7302A1AMGN)kygQZ)cNQwOHtdPzj2Xel7RQ9dXYxSe5fi19bwGflEf)2(cfl3MFSOEeeMfT0hmfWS4filkcJzr3FBS0bhILZhu0HzXlqw8JLBJyHkqwGnwCw2HkFyb9cQpctS4hlAPpSGPaMf4WIIWywgQZ)6luS4ywoilf8yzZr8fkwoild1gcVXc4A(cflO)Q8Hf0lO(imXP5H7Hf24qcOAJe8QA)qOnepOO85dk6WARfA)M29gQneEZTuusI1Q1muq9rykJHkFmd15FHbwS0qb1hHjZxzmu5JMH68VWatl9rZ5kQodgUuzylFBuUbhcFgQClfb2xZ5dk6m33r5dMbFkvT0haioIuQ85dk6WaDOo)lSMEuq9ryY8v2R4jjd15FHbgQaOPZrEFonKMfKsefXYkIL9ZNMRuS4hlUsXY9DeMLvPimMLf(luSG(Xd(4yw8cKL)y5XS4wW1XYbzjAGbwGdlk6y52iwWru4DflE4EyXI6lIflsb1XYMxGkILy7qEN1xG0WcSybGSC(GIomNMhUhwyJdjGQnsWNpnxPq730wVZvuDg8rkLpzW5BNHk3srGA6zTAnd(8P5kLzO2q4n3srA6HJiLkF(GIoSbF(0CLcyXkjrVzvudoOiZ9DKo4uzWH8oRVaPPFsY5kQodgUuzylFBuUbhcFgQClfbQXA1AgkO(imLXqLpMH68VWalwAOG6JWK5RmgQ8rJ1Q1m4ZNMRuMH68VWadiQbhrkv(8bfDyd(8P5kvQARp910tVzvudoOiJkEWhhNBkIUVqLrP(UimLKCFhHurQ6dAs1A1Ag85tZvkZqD(xyGcW(AoFqrN5(okFWm4tPIgonKMfKI)2yz)iLYhwITZ3owwyIfyXsaKfDBuXYqTHWBULIyXADSGVxPyrN)hln4Wc6hp4JJzjAGbw8cKfqyHUJLfMyXIAWHybzXwSHL97vkwwyIflQbhIfKbleqajwWFfiwUn)yr3RuSenWalEbVnAyz)8P5kfNMhUhwyJdjGQnsWNpnxPq730(CfvNbFKs5tgC(2zOYTueOgRvRzWNpnxPmd1gcV5wkstp9Mvrn4GImQ4bFCCUPi6(cvgL67IWusY9DesfPQpOjv9PVMZhu0zUVJYhmd(uQXItdPzbP4VnwITd5DwFbsdllmXY(5tZvkwoilasuelRiwUnIfRvRXIvCwCfgYYc)fkw2pFAUsXcSybnSGPaSaXSahwuegZYqD(xFHItZd3dlSXHeq1gj4ZNMRuO9BApRIAWbfzUVJ0bNkdoK3z9finAWrKsLpFqrh2GpFAUsLQ2Xstp9SwTM5(oshCQm4qEN1xG0ywrASwTMbF(0CLYmuBi8MBPOKKEi85DlfzahY7Y6ELk3CLkdBnn9SwTMbF(0CLYmuN)fgyXkjbhrkv(8bfDyd(8P5kvQauZ5kQod(iLYNm48TZqLBPiqnwRwZGpFAUszgQZ)cdm00VFFonKMfK5QWs5hHzr3gDB0WIZY(5dEnOiwwyIfDVsXsWxyIL9ZNMRuSCqwAUsXcS1qllEbYYctSSF(GxdkILdYcGefXsSDiVZ6lqAybFEaqwwrCAE4EyHnoKaQ2ibHpVBPi0wEhPn(8P5kvwhSUCZvQmS1qlcxTiTD8nUkhb1rtQa40bG90kDG3A1AM77iDWPYGd5DwFbsJbFEaW(aWEwRwZGpFAUszgQZ)cd8XcPIJiLkV54JaE9oxr1zWhPu(KbNVDgQClfb2ha2laHkqOUYGpFAUszgQZ)cd8XcPIJiLkV54Ja(ZvuDg8rkLpzW5BNHk3srG9bG9aHNPTM4zyltQvrMH68VWapA6RPN1Q1m4ZNMRuMvussacvGqDLbF(0CLYmuN)fUpNgsZsSJjw2pFWRbfXIU)2yj2oK3z9finSCqwaKOiwwrSCBelwRwJfD)Tbxhlki(luSSF(0CLILv09DelEbYYctSSF(GxdkIfyXI(auwIbmf6Nf85baXSSQ7vSOpSC(GIomNMhUhwyJdjGQnsWNp41GIq730gHpVBPid4qExw3Ru5MRuzyRPbHpVBPid(8P5kvwhSUCZvQmS10OhcFE3srMhvbhkJpFWRbfLK0ZA1Aglx5vGYWw2vQ8T9fkCU8BnKbFEaWuJvsI1Q1mwUYRaLHTSRu5B7lu4SpbVid(8aGPgR(AWrKsLpFqrh2GpFAUsbm9rdcFE3srg85tZvQSoyD5MRuzyRXPH0Se7yIfSoF6ybdz528JL4WflOOJLoh5SSIUVJyXkoll8xOy5pwCmlk)iwCmlrqm(TuelWIffHXSCBEXsSybFEaqmlWHfaKx4JfDBuXsSakl4ZdaIzHqE0peNMhUhwyJdjGQnsCqp6EeugRZNo0gIhuu(8bfDyT1cTFtB9Upa4xO0ONhUhwgh0JUhbLX68Pld6DokY8vUPEuBxsci8moOhDpckJ15txg07CuKbFEaqGflnGWZ4GE09iOmwNpDzqVZrrMH68VWalwCAinlaiO2q4nwaqbHv7hILVXcYsbs03kWYJzzihmoAz52OHyXhIffHXSCBEXcAy58bfDyw(If0Fv(Wc6fuFeMyr3FBSSdVydAzrryml3MxSOv6SaVnA09yILVyXR4SGEb1hHjwGdlRiwoilOHLZhu0HzXIAWHyXzb9xLpSGEb1hHjdlXwyHUJLHAdH3ybCnFHIfKsFboeilOxxeuhnDuDSSkfHXS8fl7qLpSGEb1hHjonpCpSWghsavBK0bHv7hcTH4bfLpFqrhwBTq730EO2q4n3srAoFqrN5(okFWm4tP2RNw6dq7HJiLkF(GIoSbF(0(HaEac8wRwZqb1hHPSAv(ywr97d0H68VW9rQ90cONRO6mNUVYDqyHnu5wkcSVMEbiubc1vMGN)kygYbJRrpWz9GMcMdGyn9q4Z7wkYeGfciGugKWXRqssacvGqDLjaleqaP8TrzC0p)Hnd5GXts0larqLxNPEuBxU5u)KeCePu5Zhu0Hn4ZN2peW61dida7zTAndfuFeMYQv5Jzfb8aSFFGVNwa9CfvN509vUdclSHk3srG97RrpkO(imzWqLp5Iq(LK0JcQpctMVYyOYNKKEuq9ryY8v2cEBjjuq9ryY8vwTkF6RrVZvuDgmCPYWw(2OCdoe(mu5wkcmjXA1AMO57Gd47QSpbV(qoAPW(yq4QfLQ2aenP3xtpCePu5Zhu0Hn4ZN2peW0kDGVNwa9CfvN509vUdclSHk3srG97RXX34QCeuhnPIM0bGwRwZGpFAUszgQZ)cd8a5(A6PN1Q1ma(f4qGzQlcQJMoQUmv0G6tjzwrjjuq9ryY8vgdv(KKOxaIGkVodGXN3R(A0ZA1AMXrqfCHZTHQugpJ)QTu5T44JM3nRionKMLyhtSeBGXKfyXsaKfD)Tbxhlbpk6luCAE4EyHnoKaQ2iPbNaLHTC53Ai0(nT9OCyJcaYP5H7Hf24qcOAJee(8ULIqB5DK2bWCawG)9Wk7qcTiC1I0wpWz9GMcMdGyni85DlfzcG5aSa)7HLME9SwTMbF(0CLYSIssoxr1zWhPu(KbNVDgQClfbMKeGiOYRZupQTl3CQVME6zTAndgQW3hiZksJEwRwZe88xbZkstp9oxr1zARjEg2YKAvKHk3srGjjwRwZe88xbd4A87HvQbiubc1vM2AINHTmPwfzgQZ)cduaCFni85DlfzUT5vQmMiaPjRZ)ttp9cqeu51zQh12LBoLKeGqfiuxzcWcbeqkFBugh9ZFyZkstpRvRzWNpnxPmd15FHbgats07CfvNbFKs5tgC(2zOYTuey)(AoFqrN5(okFWm4tPATAntWZFfmGRXVhwaF6gGy)KK2JA7Yd15FHbM1Q1mbp)vWaUg)Ey1NtdPzj2XelilfirFRalWILailRsrymlEbYI6lIL)yzfXIU)2ybzWcbeqItZd3dlSXHeq1gjbsr47Dv2vpQQJQdTFtBe(8ULImbWCawG)9Wk7qItZd3dlSXHeq1gjFf8P87HfA)M2i85DlfzcG5aSa)7Hv2HeNgsZsSJjwqVUiOoAyjgWcKfyXsaKfD)TXY(5tZvkwwrS4filyhbXsdoSaewkSpS4fililfirFRaNMhUhwyJdjGQnsOUiOoAYwWceTFt7VoAIGk)iWC7rTD5H68VWatl0KK0ZA1AMO57Gd47QSpbV(qoAPW(yq4QfbmaIM0tsSwTMjA(o4a(Uk7tWRpKJwkSpgeUArPQnart691yTAnd(8P5kLzfPPxacvGqDLj45VcMH68VWPIM0tsaN1dAkyoaI7ZPH0SaGGAdH3yPP8HybwSSIy5GSelwoFqrhMfD)TbxhlilfirFRalw0xOyXTGRJLdYcH8OFiw8cKLcESarqtWJI(cfNMhUhwyJdjGQnsWhPu(KBkFi0gIhuu(8bfDyT1cTFt7HAdH3ClfP5(okFWm4tPQfA0GJiLkF(GIoSbF(0(HaM(OXJYHnkaOMEwRwZe88xbZqD(x4u1k9Ke9SwTMj45VcMvuFonKMLyhtSeBGOhlFJLVWpiXIxSGEb1hHjw8cKf1xel)XYkIfD)TXIZcqyPW(Ws0adS4filPa0JUhbXYUoF6408W9WcBCibuTrsBnXZWwMuRIq730McQpctMVYEfxJhLdBuaqnwRwZenFhCaFxL9j41hYrlf2hdcxTiGbq0KUMEGWZ4GE09iOmwNpDzqVZrrM7da(fQKe9cqeu51zkkmqfCatsWrKsLpFqrhova2xtpRvRzghbvWfo3gQszCZqD(xyGbCaG9qdWpRIAWbfzWF1wQ8wC8rZ791yTAnZ4iOcUW52qvkJBwrjj6zTAnZ4iOcUW52qvkJBwr910tVaeQaH6ktWZFfmROKeRvRzUT5vQmMiaPXGppaiW0cnAApQTlpuN)fgyam9010EuBxEOo)lCQALE6jj6HHlL1xGMBBELkJjcqAmu5wkcSVMEy4sz9fO52MxPYyIaKgdvULIatscqOceQRmbp)vWmuN)fo1yLEFonKMLyhtS4SSF(0CLIfa0fDBSenWalRsryml7NpnxPy5XS4QHCW4SSIyboSehUyXhIf3cUowoilqe0e8iwsbgiWP5H7Hf24qcOAJe85tZvk0(nTTwTMbw0THZr0eOO7HLzfPPN1Q1m4ZNMRuMHAdH3ClfLK44BCvocQJMuboP3NtdPzj2U6IyjfyGalwudoelidwiGasSO7Vnw2pFAUsXIxGSCBuXY(5dEnOionpCpSWghsavBKGpFAUsH2VPDaIGkVot9O2UCZjn6DUIQZGpsP8jdoF7mu5wkcutpe(8ULImbyHaciLbjC8kKKeGqfiuxzcE(RGzfLKyTAntWZFfmRO(AcqOceQRmbyHaciLVnkJJ(5pSzOo)lmWqfanDoYb(a9QEo(gxLJG6ObPIM07RXA1Ag85tZvkZqD(xyGPpA0dCwpOPG5aiMtZd3dlSXHeq1gj4Zh8AqrO9BAhGiOYRZupQTl3Cstpe(8ULImbyHaciLbjC8kKKeGqfiuxzcE(RGzfLKyTAntWZFfmRO(AcqOceQRmbyHaciLVnkJJ(5pSzOo)lmWaYASwTMbF(0CLYSI0qb1hHjZxzVIRrpe(8ULImpQcougF(GxdksJEGZ6bnfmhaXCAinlXoMyz)8bVguel6(BJfVybaDr3glrdmWcCy5BSehUqhilqe0e8iwsbgiWIU)2yjoCnSueYpwco(mSKcfgYc4QlILuGbcS4hl3gXcvGSaBSCBelair1TfFyXA1AS8nw2pFAUsXIo4sbwO7yP5kflWwJf4WsC4IfFiwGflaKLZhu0H508W9WcBCibuTrc(8bVgueA)M2wRwZal62W5GI8jJ4XpSmROKKE6HpFA)qgpkh2OaGA0dHpVBPiZJQGdLXNp41GIss6zTAntWZFfmd15FHbgA0yTAntWZFfmROKKE9SwTMj45VcMH68VWadva005ih4d0R654BCvocQJgKASsVVgRvRzcE(RGzfLKyTAnZ4iOcUW52qvkJNXF1wQ8wC8rZ7MH68VWadva005ih4d0R654BCvocQJgKASsVVgRvRzghbvWfo3gQsz8m(R2sL3IJpAE3SI6RjarqLxNbbv3w8PFFn9WrKsLpFqrh2GpFAUsbSyLKGWN3TuKbF(0CLkRdwxU5kvg2A97Rrpe(8ULImpQcougF(Gxdkstp9Mvrn4GIm33r6GtLbhY7S(cKMKeCePu5Zhu0Hn4ZNMRualw950qAwIDmXcakiSWS8fl7qLpSGEb1hHjw8cKfSJGyj2SukwaqbHfln4WcYsbs03kWP5H7Hf24qcOAJKI0L7GWcTFt7EwRwZqb1hHPmgQ8XmuN)fovc5uyDu((okjPxyZhuewBaQzOWMpOO89DeWqt)KKWMpOiS2XQVgpkh2OaGCAE4EyHnoKaQ2izZvTChewO9BA3ZA1AgkO(imLXqLpMH68VWPsiNcRJY33rjj9cB(GIWAdqndf28bfLVVJagA6NKe28bfH1ow914r5WgfautpRvRzghbvWfo3gQszCZqD(xyGHgnwRwZmocQGlCUnuLY4MvKg9Mvrn4GIm4VAlvElo(O59Ke9SwTMzCeubx4CBOkLXnRO(CAE4EyHnoKaQ2iPTuQChewO9BA3ZA1AgkO(imLXqLpMH68VWPsiNcRJY33rA6fGqfiuxzcE(RGzOo)lCQOj9KKaeQaH6ktawiGas5BJY4OF(dBgQZ)cNkAsVFssVWMpOiS2auZqHnFqr577iGHM(jjHnFqryTJvFnEuoSrba10ZA1AMXrqfCHZTHQug3muN)fgyOrJ1Q1mJJGk4cNBdvPmUzfPrVzvudoOid(R2sL3IJpAEpjrpRvRzghbvWfo3gQszCZkQpNgsZsSJjwqkGOhlWIfKfB508W9WcBCibuTrIoFMhozyltQvrCAinliZvHLYpcZIUn62OHLdYYctSSF(0(Hy5lw2HkFyr32h2y5XS4hlOHLZhu0HbQwS0GdlecAIZcathPYsNJpAIZcCyrFyz)8bVguelOxxeuhnDuDSGppaiMtZd3dlSXHeq1gji85DlfH2Y7iTXNpTFO8xzmu5dAr4QfPnoIuQ85dk6Wg85t7hkv9bOnfeo96C8rt8mcxTiGxR0thPcW07d0MccNEwRwZGpFWRbfLPUiOoA6O6YyOYhd(8aGiv9PpNgsZcYCvyP8JWSOBJUnAy5GSGum(TXc4A(cflXMHQugNtZd3dlSXHeq1gji85DlfH2Y7iT1n(TL)k3gQszC0IWvlsBTqQ4isPYBo(iGbqayV0nae47HJiLkF(GIoSbF(0(HaGA1h47Pfqpxr1zWWLkdB5BJYn4q4ZqLBPiqGxldA63hOPB0cnaV1Q1mJJGk4cNBdvPmUzOo)lmNgsZsSJjwqkg)2y5lw2HkFyb9cQpctSahw(glfKL9ZN2pel6ELIL2FS81bzbzPaj6BfyXR4DWH408W9WcBCibuTrIUXVn0(nT7rb1hHjJAv(Klc5xscfuFeMmEfpxeYpni85DlfzECoOihb1xtVZhu0zUVJYhmd(uQ6tscfuFeMmQv5t(RmatsApQTlpuN)fgyALE)KeRvRzOG6JWugdv(ygQZ)cdmpCpSm4ZN2pKHqofwhLVVJ0yTAndfuFeMYyOYhZkkjHcQpctMVYyOYhn6HWN3TuKbF(0(HYFLXqLpjjwRwZe88xbZqD(xyG5H7HLbF(0(HmeYPW6O89DKg9q4Z7wkY84CqrocsJ1Q1mbp)vWmuN)fgyeYPW6O89DKgRvRzcE(RGzfLKyTAnZ4iOcUW52qvkJBwrAq4Z7wkYOB8Bl)vUnuLY4jj6HWN3TuK5X5GICeKgRvRzcE(RGzOo)lCQeYPW6O89DeNgsZsSJjw2pFA)qS8nw(If0Fv(Wc6fuFeMqllFXYou5dlOxq9ryIfyXI(auwoFqrhMf4WYbzjAGbw2HkFyb9cQpctCAE4EyHnoKaQ2ibF(0(H40qAwInUsDBZItZd3dlSXHeq1gjZQYE4EyLvp(qB5DK2nxPUTzXPXPH0SeBgQszCw093glilfirFRaNMhUhwyJf0pThhbvWfo3gQszC0(nTTwTMj45VcMH68VWPQfA40qAwIDmXska9O7rqSSRZNow0Trfl(XIIWywUnVyrFyjgWuOFwWNhaeZIxGSCqwgQneEJfNfGPnazbFEaqwCmlk)iwCmlrqm(TuelWHL77iw(JfmKL)yXN5rqywaqEHpw82rdlolXcOSGppaileYJ(HWCAE4EyHnwq)aQ2iXb9O7rqzSoF6qBiEqr5Zhu0H1wl0(nTTwTMXYvEfOmSLDLkFBFHcNl)wdzWNhaeyaynwRwZy5kVcug2YUsLVTVqHZ(e8Im4ZdacmaSME6bcpJd6r3JGYyD(0Lb9ohfzUpa4xO0ONhUhwgh0JUhbLX68Pld6DokY8vUPEuBNME6bcpJd6r3JGYyD(0L3ixzUpa4xOssaHNXb9O7rqzSoF6YBKRmd15FHtnw9tsaHNXb9O7rqzSoF6YGENJIm4ZdacSyPbeEgh0JUhbLX68Pld6DokYmuN)fgyOrdi8moOhDpckJ15txg07CuK5(aGFHQpNgsZsSJjwqgSqabKyr3FBSGSuGe9TcSOBJkwIGy8BPiw8cKf4TrJUhtSO7VnwCwIbmf6NfRvRXIUnQybKWXRWxO408W9WcBSG(buTrsawiGas5BJY4OF(dJ2VPTEGZ6bnfmhaXA61dHpVBPitawiGaszqchVcA0laHkqOUYe88xbZqoy8KeRvRzcE(RGzf1xtpRvRzSCLxbkdBzxPY32xOW5YV1qg85ba1gaNKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppaO2a4(jjTh12LhQZ)cdmTsVpNgsZsSbIES4ywUnIL2p4Jfubqw(ILBJyXzjgWuOFw09fiuhlWHfD)TXYTrSGuk(8EXI1Q1yboSO7VnwCwaWaftbwsbOhDpcILDD(0XIxGSOZ)JLgCybzPaj6Bfy5BS8hl6G1XIfXYkIfhL)flwudoel3gXsaKLhZs7RhVrGCAE4EyHnwq)aQ2iPTM4zyltQvrO9BA3RxpRvRzSCLxbkdBzxPY32xOW5YV1qg85batfiNKyTAnJLR8kqzyl7kv(2(cfo7tWlYGppayQa5(A6PxaIGkVodcQUT4tsIEwRwZmocQGlCUnuLY4Mvu)(A6boRh0uWCaeNKeGqfiuxzcE(RGzOo)lCQOj9KKEbicQ86m1JA7YnN0eGqfiuxzcWcbeqkFBugh9ZFyZqD(x4urt6973pjPhi8moOhDpckJ15txg07CuKzOo)lCQaynbiubc1vMGN)kygQZ)cNQwPRjarqLxNPOWavWbSFsYxhnrqLFeyU9O2U8qD(xyGbG1OxacvGqDLj45VcMHCW4jjbicQ86magFEV0yTAndGFboeyM6IG6OPJQZSIsscqeu51zqq1TfF0yTAnZ4iOcUW52qvkJBgQZ)cdmGJgRvRzghbvWfo3gQszCZkItdPzbzEfifl7Npk4aYIU)2yXzPiDSedyk0plwRwJfVazbzPaj6Bfy5Xf6owCl46y5GSyrSSWeiNMhUhwyJf0pGQnscEfiv2A1AOT8osB85JcoGO9BA3ZA1Aglx5vGYWw2vQ8T9fkCU8BnKzOo)lCQardAssSwTMXYvEfOmSLDLkFBFHcN9j4fzgQZ)cNkq0GM(A6fGqfiuxzcE(RGzOo)lCQaXKKEbiubc1vgQlcQJMSfSand15FHtfiQrpRvRza8lWHaZuxeuhnDuDzQOb1NsYSI0eGiOYRZay859QFFno(gxLJG6OjvTJv6CAinlX2vxel7Np41GIWSO7VnwCwIbmf6NfRvRXI16yPGhl62OILiiu9fkwAWHfKLcKOVvGf4WcsPVahcKL9OF(dZP5H7Hf2yb9dOAJe85dEnOi0(nT7zTAnJLR8kqzyl7kv(2(cfox(TgYGppayQamjXA1Aglx5vGYWw2vQ8T9fkC2NGxKbFEaWubyFn9cqeu51zQh12LBoLKeGqfiuxzcE(RGzOo)lCQaXKe9q4Z7wkYeaZbyb(3dln6fGiOYRZay859kjPxacvGqDLH6IG6OjBblqZqD(x4ubIA0ZA1Aga)cCiWm1fb1rthvxMkAq9PKmRinbicQ86magFEV63xtp9aHNPTM4zyltQvrM7da(fQKe9cqOceQRmbp)vWmKdgpjrVaeQaH6ktawiGas5BJY4OF(dBgYbJ3NtdPzj2U6Iyz)8bVgueMflQbhIfKbleqajonpCpSWglOFavBKGpFWRbfH2VPDVaeQaH6ktawiGas5BJY4OF(dBgQZ)cdm0OrpWz9GMcMdGyn9q4Z7wkYeGfciGugKWXRqssacvGqDLj45VcMH68VWadn91GWN3TuKjaMdWc8Vhw91Ohi8mT1epdBzsTkYCFaWVqPjarqLxNPEuBxU5Kg9aN1dAkyoaI1qb1hHjZxzVIRXX34QCeuhnPQpPZPH0SeBHf6owaHhlGR5luSCBelubYcSXcachbvWfMLyZqvkJJwwaxZxOybWVahcKfQlcQJMoQowGdlFXYTrSOC8XcQailWglEXc6fuFeM408W9WcBSG(buTrccFE3srOT8osBq4Lhc4U(H6O6WOfHRwK29SwTMzCeubx4CBOkLXnd15FHtfnjj6zTAnZ4iOcUW52qvkJBwr910ZA1Aga)cCiWm1fb1rthvxMkAq9PKmd15FHbgQaOPZrEFn9SwTMHcQpctzmu5JzOo)lCQOcGMoh5jjwRwZqb1hHPSAv(ygQZ)cNkQaOPZrEFonpCpSWglOFavBKGxv7hcTH4bfLpFqrhwBTq730EO2q4n3srAoFqrN5(okFWm4tPQfqwJhLdBuaqni85DlfzaHxEiG76hQJQdZP5H7Hf2yb9dOAJKoiSA)qOnepOO85dk6WARfA)M2d1gcV5wksZ5dk6m33r5dMbFkvTILbnA8OCyJcaQbHpVBPidi8YdbCx)qDuDyonpCpSWglOFavBKGpsP8j3u(qOnepOO85dk6WARfA)M2d1gcV5wksZ5dk6m33r5dMbFkvTaYaDOo)lSgpkh2OaGAq4Z7wkYacV8qa31puhvhMtdPzj2aJjlWILail6(BdUowcEu0xO408W9WcBSG(buTrsdobkdB5YV1qO9BA7r5WgfaKtdPzb96IG6OHLyalqw0TrflUfCDSCqwO6OHfNLI0XsmGPq)SO7lqOow8cKfSJGyPbhwqwkqI(wbonpCpSWglOFavBKqDrqD0KTGfiA)M29OG6JWKrTkFYfH8ljHcQpctgmu5tUiKFjjuq9ryY4v8Cri)ssSwTMXYvEfOmSLDLkFBFHcNl)wdzgQZ)cNkq0GMKeRvRzSCLxbkdBzxPY32xOWzFcErMH68VWPcenOjjXX34QCeuhnPcCsxtacvGqDLj45VcMHCW4A0dCwpOPG5aiUVMEbiubc1vMGN)kygQZ)cNASspjjaHkqOUYe88xbZqoy8(jjFD0ebv(rG52JA7Yd15FHbMwPZPH0SeBGOhlZJA7yXIAWHyzH)cflilfCAE4EyHnwq)aQ2iPTM4zyltQvrO9BAhGqfiuxzcE(RGzihmUge(8ULImbWCawG)9WstphFJRYrqD0KkWjDn6fGiOYRZupQTl3CkjjarqLxNPEuBxU5KghFJRYrqD0am9j9(A0larqLxNbbv3w8rtp9cqeu51zQh12LBoLKeGqfiuxzcWcbeqkFBugh9ZFyZqoy8(A0dCwpOPG5aiMtdPzbzPaj6Bfyr3gvS4hlaN0bklPadeyPhCuqD0WYT5fl6t6SKcmqGfD)TXcYGfciGuFw093gCDSOG4VqXY9DelFXsmuqiOAHpw8cKf1xelRiw093glidwiGasS8nw(JfDoMfqchVceiNMhUhwyJf0pGQnsq4Z7wkcTL3rAhaZbyb(3dRSf0p0IWvlsB9aN1dAkyoaI1GWN3TuKjaMdWc8VhwA61ZX34QCeuhnPcCsxtpRvRza8lWHaZuxeuhnDuDzQOb1NsYSIss0larqLxNbW4Z7v)KeRvRzSuqiOAHpZksJ1Q1mwkieuTWNzOo)lmWSwTMj45VcgW143dR(jjFD0ebv(rG52JA7Yd15FHbM1Q1mbp)vWaUg)EyLKeGiOYRZupQTl3CQVME6fGiOYRZupQTl3CkjPNJVXv5iOoAaM(KEsci8mT1epdBzsTkYCFaWVq1xtpe(8ULImbyHaciLbjC8kKKeGqfiuxzcWcbeqkFBugh9ZFyZqoy8(9508W9WcBSG(buTrsGue(ExLD1JQ6O6q730gHpVBPitamhGf4FpSYwq)408W9WcBSG(buTrYxbFk)EyH2VPncFE3srMayoalW)EyLTG(XPH0SGE4778JWSSb1Xs3kSXskWabw8HybL)fbYsenSGPaSa508W9WcBSG(buTrccFE3srOT8osBhhbeOzNcOfHRwK2uq9ryY8vwTkFaEams1d3dld(8P9dziKtH1r577iGQhfuFeMmFLvRYhGVhqgONRO6my4sLHT8Tr5gCi8zOYTueiWhR(ivpCpSm6g)2meYPW6O89Deqt3aqKkoIuQ8MJpItdPzj2U6Iyz)8bVgueMfDBuXYTrS0EuBhlpMf3cUowoilubIwwAdvPmolpMf3cUowoilubIwwIdxS4dXIFSaCshOSKcmqGLVyXlwqVG6JWeAzbzPaj6Bfyr54dZIxWBJgwaWaftbmlWHL4Wfl6Glfilqe0e8iw6GdXYT5flCIwPZskWabw0TrflXHlw0bxkWcDhl7Np41GIyPG6408W9WcBSG(buTrc(8bVgueA)M29(6OjcQ8JaZTh12LhQZ)cdm9jjPN1Q1mJJGk4cNBdvPmUzOo)lmWqfanDoYb(a9QEo(gxLJG6ObPgR07RXA1AMXrqfCHZTHQug3SI63pjPNJVXv5iOoAakcFE3srghhbeOzNcaV1Q1muq9rykJHkFmd15FHbki8mT1epdBzsTkYCFaqCEOo)lGhGg0KQwALEsIJVXv5iOoAakcFE3srghhbeOzNcaV1Q1muq9rykRwLpMH68VWafeEM2AINHTmPwfzUpaiopuN)fWdqdAsvlTsVVgkO(imz(k7vCn90ZA1AMGN)kywrjj6DUIQZGpFuWb0qLBPiW(A61tVaeQaH6ktWZFfmROKKaebvEDgaJpVxA0laHkqOUYqDrqD0KTGfOzf1pjjarqLxNPEuBxU5uFn90larqLxNbbv3w8jjrpRvRzcE(RGzfLK44BCvocQJMuboP3pjP35kQod(8rbhqdvULIa1yTAntWZFfmRin9SwTMbF(OGdObFEaqGfRKehFJRYrqD0KkWj9(9tsSwTMj45VcMvKg9SwTMzCeubx4CBOkLXnRin6DUIQZGpFuWb0qLBPiqonKMLyhtSaGcclmlFXc6VkFyb9cQpctS4filyhbXcszCvdOXMLsXcakiSyPbhwqwkqI(wbonpCpSWglOFavBKuKUChewO9BA3ZA1AgkO(imLvRYhZqD(x4ujKtH1r577OKKEHnFqryTbOMHcB(GIY33radn9tscB(GIWAhR(A8OCyJcaYP5H7Hf2yb9dOAJKnx1YDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ00laHkqOUYe88xbZqD(x4urt6jjbiubc1vMaSqabKY3gLXr)8h2muN)fov0KE)KKEHnFqryTbOMHcB(GIY33radn9tscB(GIWAhR(A8OCyJcaYP5H7Hf2yb9dOAJK2sPYDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ00laHkqOUYe88xbZqD(x4urt6jjbiubc1vMaSqabKY3gLXr)8h2muN)fov0KE)KKEHnFqryTbOMHcB(GIY33radn9tscB(GIWAhR(A8OCyJcaYPH0SGuarpwGflbqonpCpSWglOFavBKOZN5Htg2YKAveNgsZsSJjw2pFA)qSCqwIgyGLDOYhwqVG6JWelWHfDBuXYxSalvCwq)v5dlOxq9ryIfVazzHjwqkGOhlrdmGz5BS8flO)Q8Hf0lO(imXP5H7Hf2yb9dOAJe85t7hcTFtBkO(imz(kRwLpjjuq9ryYGHkFYfH8ljHcQpctgVINlc5xsI1Q1m68zE4KHTmPwfzwrASwTMHcQpctz1Q8XSIss6zTAntWZFfmd15FHbMhUhwgDJFBgc5uyDu((osJ1Q1mbp)vWSI6ZP5H7Hf2yb9dOAJeDJFBCAE4EyHnwq)aQ2izwv2d3dRS6XhAlVJ0U5k1TnlononKML9Zh8AqrS0GdlDqeuhvhlRsrymll8xOyjgWuOFonpCpSWMMRu32S0gF(GxdkcTFtB9Mvrn4GImwUYRaLHTSRu5B7luydbCxFuebYPH0SGmhFSCBelGWJfD)TXYTrS0bXhl33rSCqwCqqww19kwUnILoh5SaUg)EyXYJzz7pdl7RQ9dXYqD(xyw6wQ7JupbYYbzPZVWglDqy1(HybCn(9WItZd3dlSP5k1TnlGQnsWRQ9dH2q8GIYNpOOdRTwO9BAdcpthewTFiZqD(x4uhQZ)cd8aeGivTaWCAE4EyHnnxPUTzbuTrshewTFiononKMLyhtSSF(GxdkILdYcGefXYkILBJyj2oK3z9finSyTAnw(gl)XIo4sbYcH8OFiwSOgCiwAF94TVqXYTrSueYpwco(yboSCqwaxDrSyrn4qSGmyHaciXP5H7Hf2GpTXNp41GIq730Ewf1GdkYCFhPdovgCiVZ6lqA00JcQpctMVYEfxJE96zTAnZ9DKo4uzWH8oRVaPXmuN)fovpCpSm6g)2meYPW6O89Deqt3OLMEuq9ryY8v2cEBjjuq9ryY8vgdv(KKqb1hHjJAv(Klc5x)KeRvRzUVJ0bNkdoK3z9finMH68VWP6H7HLbF(0(HmeYPW6O89Deqt3OLMEuq9ryY8vwTkFssOG6JWKbdv(Klc5xscfuFeMmEfpxeYV(9ts0ZA1AM77iDWPYGd5DwFbsJzf1pjPN1Q1mbp)vWSIssq4Z7wkYeGfciGugKWXRqFnbiubc1vMaSqabKY3gLXr)8h2mKdgxtaIGkVot9O2UCZP(A6PxaIGkVodGXN3RKKaeQaH6kd1fb1rt2cwGMH68VWPcG7RPN1Q1mbp)vWSIss0laHkqOUYe88xbZqoy8(CAinlXoMyjfGE09iiw215thl62OILBJgILhZsbzXd3JGybRZNo0YIJzr5hXIJzjcIXVLIybwSG15thl6(BJfaYcCyPr6OHf85baXSahwGflolXcOSG15thlyil3MFSCBelfPJfSoF6yXN5rqywaqEHpw82rdl3MFSG15thleYJ(HWCAE4EyHn4dOAJeh0JUhbLX68PdTH4bfLpFqrhwBTq730wpq4zCqp6EeugRZNUmO35OiZ9ba)cLg98W9WY4GE09iOmwNpDzqVZrrMVYn1JA700tpq4zCqp6EeugRZNU8g5kZ9ba)cvsci8moOhDpckJ15txEJCLzOo)lCQOPFsci8moOhDpckJ15txg07CuKbFEaqGflnGWZ4GE09iOmwNpDzqVZrrMH68VWalwAaHNXb9O7rqzSoF6YGENJIm3ha8luCAinlXoMWSGmyHaciXY3ybzPaj6Bfy5XSSIyboSehUyXhIfqchVcFHIfKLcKOVvGfD)TXcYGfciGelEbYsC4IfFiwSifuhl6t6SKcmqGtZd3dlSbFavBKeGfciGu(2Omo6N)WO9BARh4SEqtbZbqSME9q4Z7wkYeGfciGugKWXRGg9cqOceQRmbp)vWmKdgxJEZQOgCqrMO57Gd47QSpbV(qoAPW(KKyTAntWZFfmRO(AC8nUkhb1rdW0wFsxtpRvRzOG6JWuwTkFmd15FHtvR0tsSwTMHcQpctzmu5JzOo)lCQALE)KK2JA7Yd15FHbMwPRrVaeQaH6ktWZFfmd5GX7ZPH0SGmyb(3dlwAWHfxPybeEywUn)yPZbKWSGxdXYTrXzXhQq3XYqTHWBeil62OIfaeocQGlmlXMHQugNLnhZIIWywUnVybnSGPaMLH68V(cflWHLBJybW4Z7flwRwJLhZIBbxhlhKLMRuSaBnwGdlEfNf0lO(imXYJzXTGRJLdYcH8OFionpCpSWg8buTrccFE3srOT8osBq4Lhc4U(H6O6WOfHRwK29SwTMzCeubx4CBOkLXnd15FHtfnjj6zTAnZ4iOcUW52qvkJBwr91ON1Q1mJJGk4cNBdvPmEg)vBPYBXXhnVBwrA6zTAndGFboeyM6IG6OPJQltfnO(usMH68VWadva005iVVMEwRwZqb1hHPmgQ8XmuN)fovubqtNJ8KeRvRzOG6JWuwTkFmd15FHtfva005ipjPNEwRwZqb1hHPSAv(ywrjj6zTAndfuFeMYyOYhZkQVg9oxr1zWqf((azOYTueyFonKMfKblW)EyXYT5hlHnkaiMLVXsC4IfFiwGRd)Geluq9ryILdYcSuXzbeESCB0qSahwEufCiwUThZIU)2yzhQW3hionpCpSWg8buTrccFE3srOT8osBq4LHRd)GuMcQpctOfHRwK290ZA1AgkO(imLXqLpMvKg9SwTMHcQpctz1Q8XSI6NKCUIQZGHk89bYqLBPiqonpCpSWg8buTrshewTFi0gIhuu(8bfDyT1cTFt7HAdH3ClfPPN1Q1muq9rykJHkFmd15FHtDOo)lCsI1Q1muq9rykRwLpMH68VWPouN)fojbHpVBPidi8YW1HFqktb1hHP(AgQneEZTuKMZhu0zUVJYhmd(uQAbqnEuoSrba1GWN3TuKbeE5HaURFOoQomNMhUhwyd(aQ2ibVQ2peAdXdkkF(GIoS2AH2VP9qTHWBULI00ZA1AgkO(imLXqLpMH68VWPouN)fojXA1AgkO(imLvRYhZqD(x4uhQZ)cNKGWN3TuKbeEz46WpiLPG6JWuFnd1gcV5wksZ5dk6m33r5dMbFkvTaOgpkh2OaGAq4Z7wkYacV8qa31puhvhMtZd3dlSbFavBKGpsP8j3u(qOnepOO85dk6WARfA)M2d1gcV5wkstpRvRzOG6JWugdv(ygQZ)cN6qD(x4KeRvRzOG6JWuwTkFmd15FHtDOo)lCsccFE3srgq4LHRd)GuMcQpct91muBi8MBPinNpOOZCFhLpyg8Pu1ciRXJYHnkaOge(8ULImGWlpeWD9d1r1H50qAwIDmXsSbgtwGflbqw093gCDSe8OOVqXP5H7Hf2GpGQnsAWjqzylx(TgcTFtBpkh2OaGCAinlXoMybP0xGdbYYE0p)Hzr3FBS4vCwuWcflubxO2yr547luSGEb1hHjw8cKLBIZYbzr9fXYFSSIyr3FBSaewkSpS4fililfirFRaNMhUhwyd(aQ2iH6IG6OjBblq0(nT71ZA1AgkO(imLXqLpMH68VWPQv6jjwRwZqb1hHPSAv(ygQZ)cNQwP3xtacvGqDLj45VcMH68VWPgR010ZA1AMO57Gd47QSpbV(qoAPW(yq4QfbmaQpPNKO3SkQbhuKjA(o4a(Uk7tWRpKJwkSpgc4U(OicSF)KeRvRzIMVdoGVRY(e86d5OLc7JbHRwuQAdqGy6jjbiubc1vMGN)kygYbJRXX34QCeuhnPcCsNtdPzj2XelilfirFRal6(BJfKbleqajKGu6lWHazzp6N)WS4filGWcDhlqe0OB(JybiSuyFyboSOBJkwIHccbvl8XIo4sbYcH8OFiwSOgCiwqwkqI(wbwiKh9dH508W9WcBWhq1gji85DlfH2Y7iTdG5aSa)7HvgFOfHRwK26boRh0uWCaeRbHpVBPitamhGf4FpS00RxacvGqDLH6IIpKRYWbS8kqMH68VWatlGmqeO90slGFwf1GdkYG)QTu5T44JM37RHaURpkIanuxu8HCvgoGLxbQFsIJVXv5iOoAsvBGt6A6P35kQotBnXZWwMuRImu5wkcmjXA1AMGN)kyaxJFpSsnaHkqOUY0wt8mSLj1QiZqD(xyGcG7RbHpVBPiZTnVsLXebinzD(FA6zTAndGFboeyM6IG6OPJQltfnO(usMvusIEbicQ86magFEV6R58bfDM77O8bZGpLQ1Q1mbp)vWaUg)Eyb8PBaIjjTh12LhQZ)cdmRvRzcE(RGbCn(9WkjjarqLxNPEuBxU5usI1Q1mwkieuTWNzfPXA1AglfecQw4ZmuN)fgywRwZe88xbd4A87Hfq7bCa(zvudoOit08DWb8Dv2NGxFihTuyFmeWD9rrey)(A0ZA1AMGN)kywrA6PxaIGkVot9O2UCZPKKaeQaH6ktawiGas5BJY4OF(dBwrjjTh12LhQZ)cdSaeQaH6ktawiGas5BJY4OF(dBgQZ)cduGCss7rTD5H68VWivKQwa40bM1Q1mbp)vWaUg)Ey1NtdPzj2Xel3gXcasuDBXhw093glolilfirFRal3MFS84cDhlTb2XcqyPW(WP5H7Hf2GpGQnsghbvWfo3gQszC0(nTTwTMj45VcMH68VWPQfAssSwTMj45VcgW143dlGfR01GWN3TuKjaMdWc8Vhwz8XP5H7Hf2GpGQnscKIW37QSREuvhvhA)M2i85DlfzcG5aSa)7HvgFA6PN1Q1mbp)vWaUg)EyLASspjrVaebvEDgeuDBXN(jjwRwZmocQGlCUnuLY4MvKgRvRzghbvWfo3gQszCZqD(xyGbCaAawGR)mrdfEmLD1JQ6O6m33rzeUAraTNEwRwZyPGqq1cFMvKg9oxr1zWNpk4aAOYTueyFonpCpSWg8buTrYxbFk)EyH2VPncFE3srMayoalW)EyLXhNgsZcas(8ULIyzHjqwGflU1R(7jml3MFSOZRJLdYIfXc2rqGS0GdlilfirFRalyil3MFSCBuCw8HQJfDo(iqwaqEHpwSOgCiwUnQJtZd3dlSbFavBKGWN3TueAlVJ0g7iOCdo5GN)kGweUArARxacvGqDLj45VcMHCW4jj6HWN3TuKjaleqaPmiHJxbnbicQ86m1JA7YnNssaN1dAkyoaI50qAwIDmHzj2arpw(glFXIxSGEb1hHjw8cKLBEcZYbzr9fXYFSSIyr3FBSaewkSpOLfKLcKOVvGfVazjfGE09iiw215thNMhUhwyd(aQ2iPTM4zyltQvrO9BAtb1hHjZxzVIRXJYHnkaOgRvRzIMVdoGVRY(e86d5OLc7JbHRweWaO(KUMEGWZ4GE09iOmwNpDzqVZrrM7da(fQKe9cqeu51zkkmqfCa7RbHpVBPid2rq5gCYbp)vqtpRvRzghbvWfo3gQszCZqD(xyGbCaG9qdWpRIAWbfzWF1wQ8wC8rZ791yTAnZ4iOcUW52qvkJBwrjj6zTAnZ4iOcUW52qvkJBwr950qAwIDmXca6IUnw2pFAUsXs0adyw(gl7NpnxPy5Xf6owwrCAE4EyHn4dOAJe85tZvk0(nTTwTMbw0THZr0eOO7HLzfPXA1Ag85tZvkZqTHWBULI408W9WcBWhq1gjbVcKkBTAn0wEhPn(8rbhq0(nTTwTMbF(OGdOzOo)lmWqJMEwRwZqb1hHPmgQ8XmuN)fov0KKyTAndfuFeMYQv5JzOo)lCQOPVghFJRYrqD0KkWjDonKMLy7QlcZskWabwSOgCiwqgSqabKyzH)cfl3gXcYGfciGelbyb(3dlwoilHnkailFJfKbleqajwEmlE4wUsfNf3cUowoilwelbhFCAE4EyHn4dOAJe85dEnOi0(nTdqeu51zQh12LBoPbHpVBPitawiGaszqchVcAcqOceQRmbyHaciLVnkJJ(5pSzOo)lmWqJg9aN1dAkyoaI1qb1hHjZxzVIRXX34QCeuhnPQpPZPH0Se7yIL9ZNMRuSO7Vnw2psP8HLy78TJfVazPGSSF(OGdiAzr3gvSuqw2pFAUsXYJzzfHwwIdxS4dXYxSG(RYhwqVG6JWeln4WcagOykGzboSCqwIgyGfGWsH9HfDBuXIBbrqSaCsNLuGbcSahwCWi)EeelyD(0XYMJzbadumfWSmuN)1xOyboS8yw(ILM6rTDgwIj8iwUn)yzvG0WYTrSG9oILaSa)7HfML)qhMfWimlfTUXvSCqw2pFAUsXc4A(cflaiCeubxywIndvPmoAzr3gvSehUqhil47vkwOcKLvel6(BJfGt6a1XrS0Gdl3gXIYXhlOuqlxHnCAE4EyHn4dOAJe85tZvk0(nTpxr1zWhPu(KbNVDgQClfbQrVZvuDg85JcoGgQClfbQXA1Ag85tZvkZqTHWBULI00ZA1AgkO(imLvRYhZqD(x4ubWAOG6JWK5RSAv(OXA1AMO57Gd47QSpbV(qoAPW(yq4QfbmaIM0tsSwTMjA(o4a(Uk7tWRpKJwkSpgeUArPQnart6AC8nUkhb1rtQaN0tsaHNXb9O7rqzSoF6YGENJImd15FHtfaNK4H7HLXb9O7rqzSoF6YGENJImFLBQh121xtacvGqDLj45VcMH68VWPQv6CAinlXoMyz)8bVguelaOl62yjAGbmlEbYc4QlILuGbcSOBJkwqwkqI(wbwGdl3gXcasuDBXhwSwTglpMf3cUowoilnxPyb2ASahwIdxOdKLGhXskWabonpCpSWg8buTrc(8bVgueA)M2wRwZal62W5GI8jJ4XpSmROKeRvRza8lWHaZuxeuhnDuDzQOb1NsYSIssSwTMj45VcMvKMEwRwZmocQGlCUnuLY4MH68VWadva005ih4d0R654BCvocQJgKASsVpqJfWFUIQZuKUChewgQClfbQrVzvudoOid(R2sL3IJpAExJ1Q1mJJGk4cNBdvPmUzfLKyTAntWZFfmd15FHbgQaOPZroWhOx1ZX34QCeuhni1yLE)KeRvRzghbvWfo3gQsz8m(R2sL3IJpAE3SIss0ZA1AMXrqfCHZTHQug3SI0OxacvGqDLzCeubx4CBOkLXnd5GXts0larqLxNbbv3w8PFsIJVXv5iOoAsf4KUgkO(imz(k7vConKMf9pXz5GS05asSCBelwe(yb2yz)8rbhqwSIZc(8aGFHIL)yzfXcWD9bavXz5lw8kolOxq9ryIfR1XcqyPW(WYJRJf3cUowoilwelrdmeiqonpCpSWg8buTrc(8bVgueA)M2NRO6m4ZhfCanu5wkcuJEZQOgCqrM77iDWPYGd5DwFbsJMEwRwZGpFuWb0SIssC8nUkhb1rtQaN07RXA1Ag85JcoGg85babwS00ZA1AgkO(imLXqLpMvusI1Q1muq9rykRwLpMvuFnwRwZenFhCaFxL9j41hYrlf2hdcxTiGbqGy6A6fGqfiuxzcE(RGzOo)lCQALEsIEi85DlfzcWcbeqkds44vqtaIGkVot9O2UCZP(CAinlOh((o)imlBqDS0TcBSKcmqGfFiwq5FrGSerdlykalqonpCpSWg8buTrccFE3srOT8osBhhbeOzNcOfHRwK2uq9ryY8vwTkFaEams1d3dld(8P9dziKtH1r577iGQhfuFeMmFLvRYhGVhqgONRO6my4sLHT8Tr5gCi8zOYTueiWhR(ivpCpSm6g)2meYPW6O89Deqt3OpObPIJiLkV54JaA6g0a8NRO6mLFRHWzlx5vGmu5wkcKtdPzj2U6Iyz)8bVguelFXIZcqeOykWYou5dlOxq9rycTSacl0DSOOJL)yjAGbwaclf2hw6DB(XYJzzZlqfbYIvCwO)2OHLBJyz)8P5kflQViwGdl3gXskWaHuboPZI6lILgCyz)8bVguuF0YciSq3Xcebn6M)iw8Ifa0fDBSenWalEbYIIowUnIf3cIGyr9fXYMxGkIL9ZhfCa508W9WcBWhq1gj4Zh8AqrO9BAR3SkQbhuK5(oshCQm4qEN1xG0OPN1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlcyaeiMEsI1Q1mrZ3bhW3vzFcE9HC0sH9XGWvlcyaenPR5CfvNbFKs5tgC(2zOYTueyFn9OG6JWK5RmgQ8rJJVXv5iOoAakcFE3srghhbeOzNcaV1Q1muq9rykJHkFmd15FHbki8mT1epdBzsTkYCFaqCEOo)lGhGg0Kkao9KekO(imz(kRwLpAC8nUkhb1rdqr4Z7wkY44iGan7ua4TwTMHcQpctz1Q8XmuN)fgOGWZ0wt8mSLj1QiZ9baX5H68VaEaAqtQaN07RrpRvRzGfDB4Cenbk6EyzwrA07CfvNbF(OGdOHk3srGA6fGqfiuxzcE(RGzOo)lCQaXKemCPS(c0CBZRuzmrasJHk3srGASwTM52MxPYyIaKgd(8aGalwXca2Bwf1GdkYG)QTu5T44JM3bE00xt7rTD5H68VWPQv6PRP9O2U8qD(xyGbW0tVVMEbiubc1vga)cCiWmo6N)WMH68VWPcets0larqLxNbW4Z7vFonKMLyhtSaGcclmlFXc6VkFyb9cQpctS4filyhbXcszCvdOXMLsXcakiSyPbhwqwkqI(wbw8cKfKsFboeilOxxeuhnDuDCAE4EyHn4dOAJKI0L7GWcTFt7EwRwZqb1hHPSAv(ygQZ)cNkHCkSokFFhLK0lS5dkcRna1muyZhuu((ocyOPFssyZhuew7y1xJhLdBuaqni85DlfzWock3Gto45VcCAE4EyHn4dOAJKnx1YDqyH2VPDpRvRzOG6JWuwTkFmd15FHtLqofwhLVVJ0OxaIGkVodGXN3RKKEwRwZa4xGdbMPUiOoA6O6YurdQpLKzfPjarqLxNbW4Z7v)KKEHnFqryTbOMHcB(GIY33radn9tscB(GIWAhRKeRvRzcE(RGzf1xJhLdBuaqni85DlfzWock3Gto45VcA6zTAnZ4iOcUW52qvkJBgQZ)cdSEObacqGFwf1GdkYG)QTu5T44JM37RXA1AMXrqfCHZTHQug3SIss0ZA1AMXrqfCHZTHQug3SI6ZP5H7Hf2GpGQnsAlLk3bHfA)M29SwTMHcQpctz1Q8XmuN)fovc5uyDu((osJEbicQ86magFEVss6zTAndGFboeyM6IG6OPJQltfnO(usMvKMaebvEDgaJpVx9ts6f28bfH1gGAgkS5dkkFFhbm00pjjS5dkcRDSssSwTMj45VcMvuFnEuoSrba1GWN3TuKb7iOCdo5GN)kOPN1Q1mJJGk4cNBdvPmUzOo)lmWqJgRvRzghbvWfo3gQszCZksJEZQOgCqrg8xTLkVfhF08EsIEwRwZmocQGlCUnuLY4MvuFonKMLyhtSGuarpwGflbqonpCpSWg8buTrIoFMhozyltQvrCAinlXoMyz)8P9dXYbzjAGbw2HkFyb9cQpctOLfKLcKOVvGLnhZIIWywUVJy528IfNfKIXVnwiKtH1rSOO2XcCybwQ4SG(RYhwqVG6JWelpMLveNMhUhwyd(aQ2ibF(0(Hq730McQpctMVYQv5tscfuFeMmyOYNCri)ssOG6JWKXR45Iq(LK0ZA1AgD(mpCYWwMuRImROKeCePu5nhFeWs3OpOrJEbicQ86miO62Ipjj4isPYBo(iGLUrF0eGiOYRZGGQBl(0xJ1Q1muq9rykRwLpMvusspRvRzcE(RGzOo)lmW8W9WYOB8BZqiNcRJY33rASwTMj45VcMvuFonKMLyhtSGum(TXc82Or3Jjw0T9HnwEmlFXYou5dlOxq9rycTSGSuGe9TcSahwoilrdmWc6VkFyb9cQpctCAE4EyHn4dOAJeDJFBCAinlXgxPUTzXP5H7Hf2GpGQnsMvL9W9WkRE8H2Y7iTBUsDBZYEhhrb7yQv6a0(SpBB]] )

end