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


    spec:RegisterPack( "Balance", 20210627, [[de1lQeqirWJau5sqsPnrcFcaAusfNsQ0QGKIxbGMfKWTaOQDj4xaKHjICmsvwMusptkrtdsvUgKkBdGsFdsQmoiPQZbaADKQkMhGY9Gu2Ni0)aOI0bjv0cjvQhcjAIKQQCravTrsvv9raQOgjaveNKubRue1lba0mLsWnjvvQDsQk)eGkmuPeAPKQk5PsXujvYvjvOTcaqFfGknwaG2lP8xrnyIdt1IfYJP0Kb6YO2SQ8zimAPQtRy1aa41sPMnf3wO2TKFdA4K0XbOy5Q8COMUsxxvTDi67KOXdj58aY6HuvZxK2pYA6PPlTgqFzn91AsTQxsa2wrDb9aSOhQxVw1AwGuzTgv322rWAnLhZAn62nEzzTgvhid0b10Lwdg(plR10VRkw)aiaf5gVSmGhpX2aIz7)rHbciD7gVSmGVzIrjGIbd9BSbWPVXWOf5gVSCyr1Q1e9hZQdLwKwdOVSM(AnPw1ljaBROUGEaw0d1NeQxRX)Bp80AAMyuQ10pGGCPfP1aYyRwJUDJxwMe939hqk5K)ftsROouqsRj1QEuYuYOS3lemw)qjd4jrNGGmijnqJFKOB2JduYaEsqzVxiyqsw)qWBEEKyDmJjzHKybYA486hcEXbkzapj6xCmejdsYVk2YySFarcs)gpYWys6mboGcsupgzgV(H)hcMeaFIKOEmYaE9d)peC3aLmGNeDIeoGKOES1X7uiibW98TNK5rYSaiMKTNjr5bleKa8wZOI5aLmGNe9BVntckHfsyBMKTNjPrDUzXK4KyMDnmjXWJj5zyunrgMKoZJeGGFs6DWcaxs6NLKzjbpXFZ6fd)ydqKOC2Es0nGdDQlsaijOKnmEh3qIondIkMRffKmlacscU9O2nqjd4jr)2BZKedXlja4Bq0V5JJ9PWaijylx(nqmjUQQbiswijrqmMK3GOFXKaldqbkzkzDwfC9Lbjr3UXlltIoBXwGeRxKeXK8G)cKeFjPFxvS(bqakYnEzzapEITbeZ2)Jcdeq62nEzzaFZeJsafdg63ydGtFJHrlYnEz5WIQvRXm4fRPlTgq(5FZQPln9PNMU0AC7oWsRbdn(LJypwRHlpYWGA6wB10xRA6sRHlpYWGA6wRbQQ1G5vRXT7alTgK(nEKH1Aq6MpR1GvzJjV(HGxCaV(9CJHKejrpsuqshssGK1nCTb86NbEGbU8iddssAkjRB4Ad4Lng)YG382axEKHbjPljPPKGvzJjV(HGxCaV(9CJHKejPvTgqgBVrDhyP10WlMeDcbEsGfjTeGKOC2E4Fjb8M3sIxGKOC2EsAw)mWdKeVajPvascC75t5GzTgK(LlpM1AgC2HS2QPVwQPlTgU8iddQPBTgOQwdMxTg3UdS0Aq634rgwRbPB(SwdwLnM86hcEXb863BoMKejrpTgqgBVrDhyP10WlMeRHDKmjk75IKM1V3CmjwViPFwsAfGKS(HGxmjk7hBpjdMKJnmsVwsEWJKTNjb4TMrfZKSqsIysup(X3XGK4fijk7hBpjVXy4JKfsI1XRwds)YLhZAndoBnSJK1wn9HEA6sRHlpYWGA6wRXT7alTMi(W81EkeAnGm2EJ6oWsRrhXmj6MpmFTNcbjkNTNeuQtaPdLLe4rI)w(ibLWcjSntYuKGsDciDOSAn2Bw(gxRPdjjqIfIKlV2qni638ZzsstjjbsSqObeQScwyHe2MZBpNXQZnlo8vjPljkij6)EbRNNYgoo2NctsIKOh60wn9HonDP1WLhzyqnDR1yVz5BCTMO)7fSEEkB44yFkmjjsIEOJK0usIGymjki5ni638XX(uysagjTIoTgqgBVrDhyP10IWLeLZ2tItck1jG0HYsY27ljdUaWLeNKw8BW(rI6bTKapsu2ZfjBptYBq0VKmys8i4FjzHKWfOwJB3bwAnQWDGL2QPpaRMU0A4YJmmOMU1AGQAnyE1AC7oWsRbPFJhzyTgKU5ZAnwEmK0HKoKm1YNk04ldMFdI(nFCSpfMeapj6Hosa8KyHqdiuzfSEEkB44yFkmjDjbqKOhQpjs6scAKy5Xqshs6qYulFQqJVmy(ni638XX(uysa8KOh6ibWtIETMejaEsSqObeQScwyHe2MZBpNXQZnloCCSpfMKUKais0d1NejDjrbjjqY5dyMrY1gCqqCGr1GxmjPPKyHqdiuzfSEEkB44yFkmjjsYulFQqJVmy(ni638XX(uysstjXcHgqOYkyHfsyBoV9CgRo3S4WXX(uyssKKPw(uHgFzW8Bq0V5JJ9PWKa4jrVKijnLKeiXcrYLxBOge9B(5mjPPK42DGvWclKW2CE75mwDUzXbWb7rgguRbKX2Bu3bwAnO0n2VXxgtIYEE75JKpEkeKGsyHe2MjPGkjr5ymK4gdujjab)KSqsW7ymKyD8sY2ZKG9yMepg(RLe4JeuclKW2marPobKouwsSoEXAni9lxEmR1yHfsyBodYyGkR2QPpuNMU0A4YJmmOMU1AGQAnyE1AC7oWsRbPFJhzyTgKU5ZAnDiz9dbVHDI58cZGdtsIKOh6ijnLKZhWmJKRn4GG4WuKKijOljs6sIcs6qshssGegW8hvvgmWXQaDSBYWdS8YYKKMsIfcnGqLvGJvb6y3KHhy5LLdhh7tHjbyKOhGnjsuqscKyHqdiuzf4yvGo2nz4bwEz5WXoiqK0LefK0HKoKG0VXJmCaw5pMZ7nvBEjbns0JK0usq634rgoaR8hZ59MQnVKGgjTKKUKOGKoKS3uT5nS6fo2bbkBHqdiuzrsAkj7nvBEdREbleAaHkRWXX(uyssKKPw(uHgFzW8Bq0V5JJ9PWKa4jrVKiPljPPKG0VXJmCaw5pMZ7nvBEjbnsALefK0HK9MQnVHT1WXoiqzleAaHklsstjzVPAZByBnyHqdiuzfoo2NctsIKm1YNk04ldMFdI(nFCSpfMeapj6LejDjjnLeK(nEKHdWk)XCEVPAZljOrssK0LK0usSqKC51gAd0nErsxTgqgBVrDhyP1OJygKKfsciBCGiz7zs(yhbtc8rck1jG0HYsIYEUi5JNcbjGWFKHjbwK8XmjEbsI6Xi5Aj5JDemjk75IeViXbbjHrY1sYGjXJG)LKfsc4WAni9lxEmR1ybZwybo7alTvtFOEnDP1WLhzyqnDR1aYy7nQ7alTgDeZKa8XQaDSBibWXbwEzzsAnjmBXKeXp4XK4KGsDciDOSK8XCqRP8ywRHJvb6y3KHhy5LL1AS3S8nUwJfcnGqLvW65PSHJJ9PWKamsAnjsuqIfcnGqLvWclKW2CE75mwDUzXHJJ9PWKamsAnjsstjjcIXKOGK3GOFZhh7tHjbyK0suNwJB3bwAnCSkqh7Mm8alVSS2QPpaOMU0A4YJmmOMU1AazS9g1DGLwJoIzsAGFJH3PqqI(1pcisaSy2IjjIFWJjXjbL6eq6qzj5J5Gwt5XSwdg(ngE3PqKVFeqAn2Bw(gxRXcHgqOYky98u2WXX(uysagjawsuqscKG0VXJmCWclKW2CgKXavwsstjXcHgqOYkyHfsyBoV9CgRo3S4WXX(uysagjawsuqcs)gpYWblSqcBZzqgduzjjnLKiigtIcsEdI(nFCSpfMeGrsROtRXT7alTgm8Bm8UtHiF)iG0wn9PxsA6sRHlpYWGA6wRXT7alTMPW27VEKHZaMVx7podYihlR1yVz5BCTMO)7fSEEkB44yFkmjjsIEOtRP8ywRzkS9(Rhz4mG571(JZGmYXYARM(0tpnDP1WLhzyqnDR142DGLwZEt1Mx90AazS9g1DGLwJU6hmjdMeNKZ3E(iHnEe88LjrPdejlKKyVntIBmKals(yMe86lj7nvBEXKSqsIysmtXGK8vjr5S9KGsDciDOSK4fijOewiHTzs8cKKpMjz7zsATajbBGljWIelijZJKi42tYEt1Mxmj(XKals(yMe86lj7nvBEXAn2Bw(gxRbPFJhz4aSYFmN3BQ28scAK0kjkijbs2BQ28g2wdh7GaLTqObeQSijnLKoKG0VXJmCaw5pMZ7nvBEjbns0JK0usq634rgoaR8hZ59MQnVKGgjTKKUKOGKoKe9FVG1ZtzdFvsstjXcHgqOYky98u2WXX(uysaijTssIKS3uT5nS6fSqObeQScG)Z3bwKOGKoKKajwisU8Ad1GOFZpNjjnLKeibPFJhz4GfwiHT5miJbQSK0LefKKajwisU8AdTb6gVijnLelejxETHAq0V5NZKOGeK(nEKHdwyHe2MZGmgOYsIcsSqObeQScwyHe2MZBpNXQZnlo8vjrbjjqIfcnGqLvW65PSHVkjkiPdjDij6)Eb2AgvmNn)YVWXX(uyssKe9sIK0usI(VxGTMrfZzm04x44yFkmjjsIEjrsxsuqscKC)IFWdbhICJxwodFz3yYB)uiWbU8iddssAkjDij6)EHi34LLZWx2nM82pfcCU89FCaVUTnjOrc6ijnLKO)7fICJxwodFz3yYB)uiWz)SEXb8622KGgjOJKUK0LK0usI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLKUKKMsseeJjrbjVbr)Mpo2NctcWiP1KijnLeK(nEKHdWk)XCEVPAZljOrssARM(0RvnDP1WLhzyqnDR1yVz5BCTgK(nEKHdWk)XCEVPAZljjGgjTsIcssGK9MQnVHvVWXoiqzleAaHklsstjbPFJhz4aSYFmN3BQ28scAK0kjkiPdjr)3ly98u2WxLK0usSqObeQScwppLnCCSpfMeassRKKij7nvBEdBRbleAaHkRa4)8DGfjkiPdjjqIfIKlV2qni638Zzsstjjbsq634rgoyHfsyBodYyGkljDjrbjjqIfIKlV2qBGUXlsstjXcrYLxBOge9B(5mjkibPFJhz4GfwiHT5miJbQSKOGeleAaHkRGfwiHT582ZzS6CZIdFvsuqscKyHqdiuzfSEEkB4RsIcs6qshsI(VxGTMrfZzZV8lCCSpfMKejrVKijnLKO)7fyRzuXCgdn(foo2NctsIKOxsK0LefKKaj3V4h8qWHi34LLZWx2nM82pfcCGlpYWGKKMsshsI(VxiYnEz5m8LDJjV9tHaNlF)hhWRBBtcAKGosstjj6)EHi34LLZWx2nM82pfcC2pRxCaVUTnjOrc6iPljDjPljPPKe9FVq7PapgmZXQqL8fZ1M5Iped6ZHVkjPPKebXysuqYBq0V5JJ9PWKamsAnjsstjbPFJhz4aSYFmN3BQ28scAKKKwJB3bwAn7nvBEBvB10NETutxAnC5rggut3AnUDhyP18XCEwogR1aYy7nQ7alTgDeZysCJHe42ZhjWIKpMjzwogtcSiXcQ1yVz5BCTMO)7fSEEkB4RssAkjwisU8Ad1GOFZpNjrbji9B8idhSWcjSnNbzmqLLefKyHqdiuzfSWcjSnN3EoJvNBwC4RsIcssGeleAaHkRG1ZtzdFvsuqshs6qs0)9cS1mQyoB(LFHJJ9PWKKij6LejPPKe9FVaBnJkMZyOXVWXX(uyssKe9sIKUKOGKei5(f)Ghcoe5gVSCg(YUXK3(PqGdC5rggKK0usUFXp4HGdrUXllNHVSBm5TFke4axEKHbjrbjDij6)EHi34LLZWx2nM82pfcCU89FCaVUTnjjssljjnLKO)7fICJxwodFz3yYB)uiWz)SEXb8622KKijTKKUK0LK0usI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLK0usIGymjki5ni638XX(uysagjTMK2QPp9qpnDP1WLhzyqnDR1aYy7nQ7alTg9hBhqMe3UdSiXm4LKihZGKalsWZ(9DGfGmmIbR142DGLwZ9RSB3bwzZGxTg8EJD10NEAn2Bw(gxRbPFJhz4WGZoK1AmdEZLhZAnoK1wn9Ph600LwdxEKHb10TwJ9MLVX1AUFXp4HGdrUXllNHVSBm5TFke4ady(JQkdQ1G3BSRM(0tRXT7alTM7xz3UdSYMbVAnMbV5YJzTMiOVARM(0dWQPlTgU8iddQPBTg3UdS0AUFLD7oWkBg8Q1yg8MlpM1AWR2QTAnrqF10LM(0ttxAnC5rggut3AnUDhyP1CosUGFC(DCH(aP1aYy7nQ7alTg9)Xf6dejkNTNeuQtaPdLvRXEZY34Anr)3ly98u2WXX(uyssKe9qN2QPVw10LwdxEKHb10TwduvRbZRwJB3bwAni9B8idR1G0nFwRjbsI(VxiYnEz5m8LDJjV9tHaNlF)hh(QKOGKeij6)EHi34LLZWx2nM82pfcC2pRxC4RQ1aYy7nQ7alTgu2Z22ysMhjBptIUH6uxKyVzjj6)EKmysk4sYxLKh8iX4lFK8XSwds)YLhZAn2B2cUFvTvtFTutxAnC5rggut3AnUDhyP14GU6oi5mwPFXAnwGSgoV(HGxSM(0tRXEZY34Anr)3le5gVSCg(YUXK3(PqGZLV)Jd41TTjbyKGEKOGKO)7fICJxwodFz3yYB)uiWz)SEXb8622KamsqpsuqshssGeq4gCqxDhKCgR0V4mOh7i4Wo22tHGefKKajUDhyfCqxDhKCgR0V4mOh7i4Wu5Nzq0VKOGKoKKajGWn4GU6oi5mwPFX5E2nHDSTNcbjPPKac3Gd6Q7GKZyL(fN7z3eoo2NctsIK0ss6ssAkjGWn4GU6oi5mwPFXzqp2rWb8622KamsAjjkibeUbh0v3bjNXk9lod6XocoCCSpfMeGrc6irbjGWn4GU6oi5mwPFXzqp2rWHDSTNcbjD1AazS9g1DGLwJoIzs0jORUdsMKgL(ftIYEUiXxsmmgtY27fjOhj6gQtDrcEDBBmjEbsYcj543X4EsCsagATscEDBBsCmjgFzsCmjQqmEImmjWJKDIzsMLemKKzjXVBqYysaa4Jxs83YhjojTeGKGx32MegvQZXyTvtFONMU0A4YJmmOMU1AC7oWsRXclKW2CE75mwDUzXAnGm2EJ6oWsRrhXmjOewiHTzsuoBpjOuNashkljk75IevigprgMeVajbU98PCWmjkNTNeNeDd1PUij6)EKOSNlsazmqLDkeAn2Bw(gxRPdji9B8idhSWcjSnNbzmqLLefKKajwi0acvwbRNNYgo2bbIK0usI(VxW65PSHVkjDjrbjDij6)EHi34LLZWx2nM82pfcCU89FCaVUTnjOrc6ijnLKO)7fICJxwodFz3yYB)uiWz)SEXb8622KGgjOJKUKKMsseeJjrbjVbr)Mpo2NctcWirVK0wn9HonDP1WLhzyqnDR142DGLwZ7FaLHVmB(fR1aYy7nQ7alTg9pe4jXXKS9mjV5WljiSGKmfjBptItIUH6uxKOCkqOssGhjkNTNKTNjbaiq34fjr)3Je4rIYz7jXjb1dqmBjrNGU6oizsAu6xmjEbsIsFwsEWJeuQtaPdLLK5rYSKOewljrmjFvsCe(uKeXp4XKS9mjwqsgmjVPgCpdQ1yVz5BCTMoK0HKO)7fICJxwodFz3yYB)uiW5Y3)Xb8622KKijOhjPPKe9FVqKB8YYz4l7gtE7Ncbo7N1loGx32MKejb9iPljkiPdjjqIfIKlV2asU2EGosstjjbsI(VxW65PSHVkjDjrbjDib8(dyOGzliMK0usSqObeQScwppLnCCSpfMKejbDjrsAkjDiXcrYLxBOge9B(5mjkiXcHgqOYkyHfsyBoV9CgRo3S4WXX(uyssKe0LejDjPljDjjnLKoKac3Gd6Q7GKZyL(fNb9yhbhoo2NctsIKG6jrbjwi0acvwbRNNYgoo2NctsIKOxsKOGelejxETHITh0apqs6ssAkjtT8Pcn(YG53GOFZhh7tHjbyKG6jrbjjqIfcnGqLvW65PSHJDqGijnLKoKyHi5YRn0gOB8IefKe9FVq7PapgmZXQqL8fZ1g(QK0vB10hGvtxAnC5rggut3AnUDhyP1y9YYMC0)90AS3S8nUwthsI(VxiYnEz5m8LDJjV9tHaNlF)hhoo2NctsIKGEb0rsAkjr)3le5gVSCg(YUXK3(PqGZ(z9Idhh7tHjjrsqVa6iPljkiPdjwi0acvwbRNNYgoo2NctsIKG6ijnLKoKyHqdiuzf4yvOs(YrWcmCCSpfMKejb1rIcssGKO)7fApf4XGzowfQKVyU2mx8HyqFo8vjrbjwisU8AdTb6gViPljDjrbjoEp3KvHk5JKerJKwMKwt0)9YLhZAn41pd8a1AazS9g1DGLwdk9YYgsAw)mWdKeLZ2tItsXkjr3qDQlsI(VhjEbsck1jG0HYsYGlaCjXJG)LKfssetYhZGARM(qDA6sRHlpYWGA6wRXT7alTg86h(FiyTgqgBVrDhyP1O)(XQK0S(H)hcgtIYz7jXjr3qDQlsI(Vhjr)LKcUKOSNlsuHqZuii5bpsqPobKouwsGhjaaNc8yqsAuNBwSwJ9MLVX1AsGeK(nEKHd2B2cUFvsuqshsSqKC51gQbr)MFotsAkjwi0acvwbRNNYgoo2NctsIKG6ijnLKeibPFJhz4GfmBHf4SdSirbjjqIfIKlV2qBGUXlsstjPdjwi0acvwbowfQKVCeSadhh7tHjjrsqDKOGKeij6)EH2tbEmyMJvHk5lMRnZfFig0NdFvsuqIfIKlV2qBGUXls6ssxsuqshssGeq4gE)dOm8LzZV4Wo22tHGK0ussGeleAaHkRG1Ztzdh7GarsAkjjqIfcnGqLvWclKW2CE75mwDUzXHJDqGiPR2QPpuVMU0A4YJmmOMU1AC7oWsRbV(H)hcwRbKX2Bu3bwAn6VFSkjnRF4)HGXKeXp4XKGsyHe2M1AS3S8nUwthsSqObeQScwyHe2MZBpNXQZnloCCSpfMeGrc6irbjjqc49hWqbZwqmjkiPdji9B8idhSWcjSnNbzmqLLK0usSqObeQScwppLnCCSpfMeGrc6iPljkibPFJhz4GfmBHf4SdSiPljkijbsaHB49pGYWxMn)Id7yBpfcsuqIfIKlV2qni638ZzsuqscKaE)bmuWSfetIcsyRzuXCyQSxaPTA6daQPlTgU8iddQPBTgOQwdMxTg3UdS0Aq634rgwRbPB(SwthsI(Vx4CKCb)4874c9bkCCSpfMKejbDKKMsscKe9FVW5i5c(X53Xf6du4RssxsuqshsI(VxO9uGhdM5yvOs(I5AZCXhIb95WXX(uysagjiSGHyhvK0LefK0HKO)7fyRzuXCgdn(foo2NctsIKGWcgIDursAkjr)3lWwZOI5S5x(foo2NctsIKGWcgIDursxTgqgBVrDhyP1O)GfaUKacxsa)3uiiz7zs4cKe4Je9lhjxWpMe9)Xf6dekib8FtHGK2tbEmijCSkujFXCTKapsMIKTNjX44LeewqsGps8IeG3AgvmR1G0VC5XSwdiCZhdy(ZXXCTyTvtF6LKMU0A4YJmmOMU1AC7oWsRb)R3CSwJ9MLVX1Ao(DmU3Jmmjkiz9dbVHDI58cZGdtsIKOhGLefK4QzBpBBtIcsq634rgoac38XaM)CCmxlwRXcK1W51pe8I10NEARM(0tpnDP1WLhzyqnDR142DGLwtmewV5yTg7nlFJR1C87yCVhzysuqY6hcEd7eZ5fMbhMKejrVwgqhjkiXvZ2E22MefKG0VXJmCaeU5Jbm)54yUwSwJfiRHZRFi4fRPp90wn9PxRA6sRHlpYWGA6wRXT7alTg8YgJF5NXpwRXEZY34Anh)og37rgMefKS(HG3WoXCEHzWHjjrs0dWscaj54yFkmjkiXvZ2E22MefKG0VXJmCaeU5Jbm)54yUwSwJfiRHZRFi4fRPp90wn9Pxl10LwdxEKHb10TwJB3bwAnp4z5m8LlF)hR1aYy7nQ7alTg9puFKalsSGKOC2E4FjX6QQtHqRXEZY34AnUA22Z22ARM(0d900LwdxEKHb10TwJB3bwAnCSkujF5iybQ1aYy7nQ7alTgGpwfQKps0nSajrzpxK4rW)sYcjHRLpsCskwjj6gQtDrIYPaHkjXlqsWosMKh8ibL6eq6qz1AS3S8nUwthsyRzuXCW8l)YfJQLK0usyRzuXCadn(LlgvljPPKWwZOI5GxaLlgvljPPKe9FVqKB8YYz4l7gtE7Ncbox((poCCSpfMKejb9cOJK0usI(VxiYnEz5m8LDJjV9tHaN9Z6fhoo2NctsIKGEb0rsAkjoEp3KvHk5JKejbaMejkiXcHgqOYky98u2WXoiqKOGKeib8(dyOGzliMKUKOGKoKyHqdiuzfSEEkB44yFkmjjssltIK0usSqObeQScwppLnCSdcejDjjnLKiigtIcsMA5tfA8LbZVbr)Mpo2NctcWirVK0wn9Ph600LwdxEKHb10TwJB3bwAnV)bug(YS5xSwdiJT3OUdS0A0)qGNKBq0VKeXp4XK8XtHGeuQtTg7nlFJR1yHqdiuzfSEEkB4yheisuqcs)gpYWbly2clWzhyrIcs6qIJ3ZnzvOs(ijrsaGjrIcssGelejxETHAq0V5NZKKMsIfIKlV2qni638ZzsuqIJ3ZnzvOs(ibyKGEjrsxsuqshssGelejxETHAq0V5NZKKMsIfcnGqLvWclKW2CE75mwDUzXHJDqGiPljkijbsaV)agky2cIjrbjjqIfIKlV2asU2EGosstjXcrYLxBajxBpqhjkij6)EHZrYf8JZVJl0hOWXX(uysagjaqsuqs0)9cNJKl4hNFhxOpqHVQ2QPp9aSA6sRHlpYWGA6wRXT7alTglBy8oUj7MbrfZ1Q1aYy7nQ7alTguQtaPdLLeL9CrIVKaatcGKOtClssh4zGk5JKT3lsqVKirN4wKeLZ2tckHfsyBUljkNTh(xsmq8uiizNyMKPir3gie08XljEbsIzkMKVkjkNTNeuclKW2mjZJKzjrPJjbKXavwguRXEZY34Anjqc49hWqbZwqmjkibPFJhz4GfmBHf4SdSirbjDiPdjoEp3KvHk5JKejbaMejkiPdjr)3l0EkWJbZCSkujFXCTzU4dXG(C4RssAkjjqIfIKlV2qBGUXls6ssAkjr)3lezGqqZhVHVkjkij6)EHidecA(4nCCSpfMeGrsRjrcajPdjwyb(NnOESDWC2ndIkMRnStmNr6Mptsxs6ssAkjrqmMefKm1YNk04ldMFdI(nFCSpfMeGrsRjrcajPdjwyb(NnOESDWC2ndIkMRnStmNr6MptsxsstjXcrYLxBOge9B(5mjDjrbjDijbsSqKC51gQbr)MFotsAkjDiXX75MSkujFKamsqVKijnLeq4gE)dOm8LzZV4Wo22tHGKUKOGKoKG0VXJmCWclKW2CgKXavwsstjXcHgqOYkyHfsyBoV9CgRo3S4WXoiqK0LKUARM(0d1PPlTgU8iddQPBTg7nlFJR1KajG3FadfmBbXKOGeK(nEKHdwWSfwGZoWIefK0HKoK449CtwfQKpssKeaysKOGKoKe9FVq7PapgmZXQqL8fZ1M5Iped6ZHVkjPPKKajwisU8AdTb6gViPljPPKe9FVqKbcbnF8g(QKOGKO)7fImqiO5J3WXX(uysagjTmjsaijDiXclW)Sb1JTdMZUzquXCTHDI5ms38zs6ssxsstjjcIXKOGKPw(uHgFzW8Bq0V5JJ9PWKamsAzsKaqs6qIfwG)zdQhBhmNDZGOI5Ad7eZzKU5ZK0LK0usSqKC51gQbr)MFotsxsuqshssGelejxETHAq0V5NZKKMsshsC8EUjRcvYhjaJe0ljsstjbeUH3)akdFz28loSJT9uiiPljkiPdji9B8idhSWcjSnNbzmqLLK0usSqObeQScwyHe2MZBpNXQZnloCSdcejDjPRwJB3bwAntz9R8DGL2QPp9q9A6sRHlpYWGA6wRbQQ1G5vRXT7alTgK(nEKH1Aq6MpR1WwZOI5WuzZV8JeudjOEsaejUDhyfWRFV54aJk2(xoVtmtcajjbsyRzuXCyQS5x(rcQHKoKayjbGKSUHRnGHFtg(YBpNFWJXBGlpYWGKGAiPLK0LearIB3bwbLNV9bgvS9VCENyMeasssHwjbqKGvzJj374L1AazS9g1DGLwdWJ3j2xgtspujjXFBpj6e3IK4htccFkgKev(ibZwybQ1G0VC5XSwJJvBr(AyR2QPp9aGA6sRHlpYWGA6wRXT7alTg86h(FiyTgqgBVrDhyP1O)(XQK0S(H)hcgtIYEUiz7zsEdI(LKbtIhb)ljlKeUarbjVJl0hisgmjEe8VKSqs4cefKae8tIFmj(scamjasIoXTijtrIxKa8wZOIzuqck1jG0HYsIXXlMeVGBpFKG6biMTysGhjab)KOe(nGKarYN1vjjgEmjBVxKqP6Lej6e3IKOSNlsac(jrj8BalaCjPz9d)pemjfuPwJ9MLVX1A6qseeJjrbjtT8Pcn(YG53GOFZhh7tHjbyKGEKKMsshsI(Vx4CKCb)4874c9bkCCSpfMeGrcclyi2rfjOgsS8yiPdjoEp3KvHk5JearsltIKUKOGKO)7fohjxWpo)oUqFGcFvs6ssxsstjPdjoEp3KvHk5Jeascs)gpYWbhR2I81WwsqnKe9FVaBnJkMZyOXVWXX(uysaijGWn8(hqz4lZMFXHDSTX5JJ9Pib1qsRb0rsIKONEjrsAkjoEp3KvHk5Jeascs)gpYWbhR2I81WwsqnKe9FVaBnJkMZMF5x44yFkmjaKeq4gE)dOm8LzZV4Wo2248XX(uKGAiP1a6ijrs0tVKiPljkiHTMrfZHPYEbejkiPdjjqs0)9cwppLn8vjjnLKeizDdxBaV(zGhyGlpYWGK0LefK0HKoKKajwi0acvwbRNNYg(QKKMsIfIKlV2qBGUXlsuqscKyHqdiuzf4yvOs(YrWcm8vjPljPPKyHi5YRnudI(n)CMKUKOGKoKKajwisU8Adi5A7b6ijnLKeij6)EbRNNYg(QKKMsIJ3ZnzvOs(ijrsaGjrsxsstjPdjRB4Ad41pd8adC5rggKefKe9FVG1ZtzdFvsuqshsI(VxaV(zGhyaVUTnjaJKwssAkjoEp3KvHk5JKejbaMejDjPljPPKe9FVG1ZtzdFvsuqscKe9FVW5i5c(X53Xf6du4RsIcssGK1nCTb86NbEGbU8iddQTA6R1K00LwdxEKHb10TwJB3bwAnfRmhdHLwdiJT3OUdS0A0rmtI(newysMIKw4x(rcWBnJkMjXlqsWosMeaN4Mha1)FJHe9BiSi5bpsqPobKouwTg7nlFJR10HKO)7fyRzuXC28l)chh7tHjjrsyuX2)Y5DIzsstjPdj2E)qWysqJKwjrbjhB79dbN3jMjbyKGos6ssAkj2E)qWysqJKwssxsuqIRMT9STT2QPVw1ttxAnC5rggut3An2Bw(gxRPdjr)3lWwZOI5S5x(foo2NctsIKWOIT)LZ7eZKOGKoKyHqdiuzfSEEkB44yFkmjjsc6sIK0usSqObeQScwyHe2MZBpNXQZnloCCSpfMKejbDjrsxsstjPdj2E)qWysqJKwjrbjhB79dbN3jMjbyKGos6ssAkj2E)qWysqJKwssxsuqIRMT9STTwJB3bwAn9U5LJHWsB10xRTQPlTgU8iddQPBTg7nlFJR10HKO)7fyRzuXC28l)chh7tHjjrsyuX2)Y5DIzsuqshsSqObeQScwppLnCCSpfMKejbDjrsAkjwi0acvwblSqcBZ5TNZy15Mfhoo2NctsIKGUKiPljPPK0HeBVFiymjOrsRKOGKJT9(HGZ7eZKamsqhjDjjnLeBVFiymjOrsljPljkiXvZ2E22wRXT7alTM33yYXqyPTA6R1wQPlTgU8iddQPBTgqgBVrDhyP1a4cbEsGfjwqTg3UdS0Au63nWldFz28lwB10xRONMU0A4YJmmOMU1AC7oWsRbV(9MJ1AazS9g1DGLwJoIzsAw)EZXKSqsupOLKgOXpsaERzuXmjWJeL9CrYuKaldqK0c)YpsaERzuXmjEbsYhZKa4cbEsupOftY8izksAHF5hjaV1mQywRXEZY34AnS1mQyomv28l)ijnLe2AgvmhWqJF5Ir1ssAkjS1mQyo4fq5Ir1ssAkjr)3lO0VBGxg(YS5xC4RsIcsI(VxGTMrfZzZV8l8vjjnLKoKe9FVG1Ztzdhh7tHjbyK42DGvq55BFGrfB)lN3jMjrbjr)3ly98u2WxLKUARM(AfDA6sRXT7alTgLNV9AnC5rggut3ARM(AfWQPlTgU8iddQPBTg3UdS0AUFLD7oWkBg8Q1yg8MlpM1AEUXS93xB1wTghYA6stF6PPlTgU8iddQPBTgOQwdMxTg3UdS0Aq634rgwRbPB(SwthsI(VxyNywj8Qm4XEC0uG8foo2NctcWibHfme7OIeasssb9ijnLKO)7f2jMvcVkdEShhnfiFHJJ9PWKamsC7oWkGx)EZXbgvS9VCENyMeasssb9irbjDiHTMrfZHPYMF5hjPPKWwZOI5agA8lxmQwsstjHTMrfZbVakxmQws6ssxsuqs0)9c7eZkHxLbp2JJMcKVWxLefKC)IFWdbh2jMvcVkdEShhnfiFbgW8hvvguRbKX2Bu3bwAnO0n2VXxgtIYEE75JKTNjr)DShB912Zhjr)3JeLJXqYZngsGVhjkNTFks2EMKIr1sI1XRwds)YLhZAnGh7XzLJXKFUXKHVN2QPVw10LwdxEKHb10TwduvRbZRwJB3bwAni9B8idR1G0nFwRjbsyRzuXCyQmgA8JefK0HeSkBm51pe8Id41V3Cmjjsc6irbjRB4Ady43KHV82Z5h8y8g4YJmmijPPKGvzJjV(HGxCaV(9MJjjrsqDK0vRbKX2Bu3bwAnO0n2VXxgtIYEE75JKM1p8)qWKmysucVTNeRJ3PqqcejFK0S(9MJjzksAHF5hjaV1mQywRbPF5YJzTMbrbpoJx)W)dbRTA6RLA6sRHlpYWGA6wRXT7alTglSqcBZ5TNZy15MfR1aYy7nQ7alTgDeZKGsyHe2MjrzpxK4ljggJjz79Ie0Lej6e3IK4fijMPys(QKOC2EsqPobKouwTg7nlFJR1KajG3FadfmBbXKOGKoK0HeK(nEKHdwyHe2MZGmgOYsIcssGeleAaHkRG1Ztzdh7GarsAkjr)3ly98u2WxLKUKOGKoK449CtwfQKpsagjOljsstjbPFJhz4WGOGhNXRF4)HGjPljkiPdjr)3lWwZOI5S5x(foo2NctsIKayjjnLKO)7fyRzuXCgdn(foo2NctsIKayjPljkiPdjjqY9l(bpeCiYnEz5m8LDJjV9tHah4YJmmijPPKe9FVqKB8YYz4l7gtE7Ncbox((poGx32MKejPLKKMss0)9crUXllNHVSBm5TFke4SFwV4aEDBBssKKwssxsstj5ni638XX(uysagj6LejkijbsSqObeQScwppLnCSdcejD1wn9HEA6sRHlpYWGA6wRXT7alTMZrYf8JZVJl0hiTgqgBVrDhyP1OJyMe9)Xf6dejkNTNeuQtaPdLvRXEZY34Anr)3ly98u2WXX(uyssKe9qN2QPp0PPlTgU8iddQPBTg3UdS0AW)6nhR1ybYA486hcEXA6tpTg7nlFJR10HKJFhJ79idtsAkjr)3lWwZOI5mgA8lCCSpfMeGrsljrbjS1mQyomvgdn(rIcsoo2NctcWirp0JefKSUHRnGHFtg(YBpNFWJXBGlpYWGK0LefKS(HG3WoXCEHzWHjjrs0d9ibWtcwLnM86hcEXKaqsoo2NctIcs6qcBnJkMdtL9cisstj54yFkmjaJeewWqSJks6Q1aYy7nQ7alTgDeZK08R3CmjtrIQxGC8yjbwK4fqB)uiiz79LeZGKXKOh6HzlMeVajXWymjkNTNKy4XKS(HGxmjEbsIVKS9mjCbsc8rItsd04hjaV1mQyMeFjrp0JemBXKapsmmgtYXX(utHGehtYcjPGlj9oYPqqYcj543X4Esa)3uiiPf(LFKa8wZOIzTvtFawnDP1WLhzyqnDR142DGLwdE975gJwdiJT3OUdS0AaaYSkjFvsAw)EUXqIVK4gdj7eZys(LHXys(4PqqslaK1phtIxGKmljdMepc(xswijQh0sc8iXWljBptcwLTJBiXT7alsmtXKeXgOss69c0WKO)o2JJMcKpsGfjTsY6hcEXAn2Bw(gxRPdjr)3lGx)EUXeo(DmU3JmmjkiPdjyv2yYRFi4fhWRFp3yibyK0ssstjjbsUFXp4HGd7eZkHxLbp2JJMcKVady(JQkdssxsstjzDdxBad)Mm8L3Eo)GhJ3axEKHbjrbjr)3lWwZOI5mgA8lCCSpfMeGrsljrbjS1mQyomvgdn(rIcsI(VxaV(9CJjCCSpfMeGrcQJefKGvzJjV(HGxCaV(9CJHKerJe0JKUKOGKoKKaj3V4h8qWbdqw)CC(zyENcrgHzIvXCGbm)rvLbjjnLKDIzsqTKGEOJKejj6)Eb863ZnMWXX(uysaijTssxsuqY6hcEd7eZ5fMbhMKejbDARM(qDA6sRHlpYWGA6wRXT7alTg863ZngTgqgBVrDhyP1a4oBpj6VJ94OPa5JKpMjPz975gdjlKK2mRsYxLKTNjj6)EKebejUbdj5JNcbjnRFp3yibwKGosWSfwGysGhjggJj54yFQPqO1yVz5BCTM7x8dEi4WoXSs4vzWJ94OPa5lWaM)OQYGKOGeSkBm51pe8Id41VNBmKKiAK0ssuqshssGKO)7f2jMvcVkdEShhnfiFHVkjkij6)Eb863ZnMWXVJX9EKHjjnLKoKG0VXJmCa8ypoRCmM8ZnMm89irbjDij6)Eb863ZnMWXX(uysagjTKK0usWQSXKx)qWloGx)EUXqsIK0kjkizDdxBaVSX4xg8M3g4YJmmijkij6)Eb863ZnMWXX(uysagjOJKUK0LKUARM(q9A6sRHlpYWGA6wRbQQ1G5vRXT7alTgK(nEKH1Aq6MpR1449CtwfQKpssKeuFsKa4jPdj6LejOgsI(VxyNywj8Qm4XEC0uG8fWRBBtsxsa8K0HKO)7fWRFp3ychh7tHjb1qsljbqKGvzJj374LjPljaEs6qciCdV)bug(YS5xC44yFkmjOgsqhjDjrbjr)3lGx)EUXe(QAnGm2EJ6oWsRbLUX(n(Yysu2ZBpFK4K0S(H)hcMKpMjr5ymKy9pMjPz975gdjlKKNBmKaFpuqIxGK8XmjnRF4)HGjzHK0Mzvs0Fh7XrtbYhj41TTj5RQ1G0VC5XSwdE975gtwjS28ZnMm890wn9ba10LwdxEKHb10TwJB3bwAn41p8)qWAnGm2EJ6oWsRrhXmjnRF4)HGjr5S9KO)o2JJMcKpswijTzwLKVkjBpts0)9ir5S9W)sIbINcbjnRFp3yi5RUtmtIxGK8XmjnRF4)HGjbwKGEaKeDd1PUibVUTnMKFTJHe0JK1pe8I1AS3S8nUwds)gpYWbWJ94SYXyYp3yYW3JefKG0VXJmCaV(9CJjRewB(5gtg(EKOGKeibPFJhz4WGOGhNXRF4)HGjjnLKoKe9FVqKB8YYz4l7gtE7Ncbox((poGx32MKejPLKKMss0)9crUXllNHVSBm5TFke4SFwV4aEDBBssKKwssxsuqcwLnM86hcEXb863ZngsagjOhjkibPFJhz4aE975gtwjS28ZnMm890wn9PxsA6sRHlpYWGA6wRXT7alTgh0v3bjNXk9lwRXcK1W51pe8I10NEAn2Bw(gxRjbs2X2EkeKOGKeiXT7aRGd6Q7GKZyL(fNb9yhbhMk)mdI(LK0usaHBWbD1DqYzSs)IZGESJGd41TTjbyK0ssuqciCdoORUdsoJv6xCg0JDeC44yFkmjaJKwQ1aYy7nQ7alTgDeZKGv6xmjyijBVVKae8tccEjj2rfjF1DIzsIaIKpEkeKmljoMeJVmjoMevigprgMeyrIHXys2EViPLKGx32gtc8ibaGpEjrzpxK0sascEDBBmjmQuNJ1wn9PNEA6sRHlpYWGA6wRXT7alTMyiSEZXAnwGSgoV(HGxSM(0tRXEZY34Anh)og37rgMefKS(HG3WoXCEHzWHjjrs6qshs0d9ibGK0HeSkBm51pe8Id41V3CmjOgsALeudjr)3lWwZOI5S5x(f(QK0LKUKaqsoo2NctsxsaejDirpsaijRB4AdRYPYXqyHdC5rggKKUKOGKoKyHqdiuzfSEEkB4yheisuqscKaE)bmuWSfetIcs6qcs)gpYWblSqcBZzqgduzjjnLeleAaHkRGfwiHT582ZzS6CZIdh7GarsAkjjqIfIKlV2qni638Zzs6ssAkjyv2yYRFi4fhWRFV5ysagjDiPdjawsa8K0HKO)7fyRzuXC28l)cFvsqnK0kjDjPljOgs6qIEKaqsw3W1gwLtLJHWch4YJmmijDjPljkijbsyRzuXCadn(LlgvljPPK0He2AgvmhMkJHg)ijnLKoKWwZOI5Wu5i42tsAkjS1mQyomv28l)iPljkijbsw3W1gWWVjdF5TNZp4X4nWLhzyqsstjj6)Eb1BIHh44MSFwVgBw9BW(fq6MptsIOrsROljs6sIcs6qcwLnM86hcEXb863BoMeGrIEjrcQHKoKOhjaKK1nCTHv5u5yiSWbU8iddssxs6sIcsC8EUjRcvYhjjsc6sIeapjr)3lGx)EUXeoo2NctcQHealjDjrbjDijbsI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLK0usyRzuXCyQmgA8JK0ussGelejxETH2aDJxK0vRbKX2Bu3bwAn6x87yCpj63qy9MJjzEKGsDciDOSKmyso2bbcfKS98XK4htIHXys2EVibDKS(HGxmjtrsl8l)ib4TMrfZKOC2EsAGR(hfKyymMKT3ls0ljsGBpFkhmtYuK4fqKa8wZOIzsGhjFvswijOJK1pe8IjjIFWJjXjPf(LFKa8wZOI5aj6pybGljh)og3tc4)McbjaaNc8yqsa(yvOs(I5Aj5xggJjzksAGg)ib4TMrfZARM(0RvnDP1WLhzyqnDR142DGLwZdEwodF5Y3)XAnGm2EJ6oWsRrhXmj6FO(ibwKybjr5S9W)sI1vvNcHwJ9MLVX1AC1STNTT1wn9Pxl10LwdxEKHb10TwJB3bwAnw2W4DCt2ndIkMRvRbKX2Bu3bwAn6iMjbL6eq6qzjbwKybj5xggJjXlqsmtXKmljFvsuoBpjOewiHTzTg7nlFJR1KajG3FadfmBbXKOGeK(nEKHdwWSfwGZoWIefK0HKO)7fWRFp3ycFvsstjXX75MSkujFKKijOljs6sIcs6qscKe9FVagAW7y5WxLefKKajr)3ly98u2WxLefK0HKeiXcrYLxBOge9B(5mjPPKyHqdiuzfSWcjSnN3EoJvNBwC4RsIcsC8EUjRcvYhjaJe0LejDjrbjRFi4nStmNxygCyssKe9qhjaKelSa)Zgup2oyo7MbrfZ1g2jMZiDZNjjnLKiigtIcsMA5tfA8LbZVbr)Mpo2NctcWiP1KibGKyHf4F2G6X2bZz3miQyU2WoXCgPB(mjD1wn9Ph6PPlTgU8iddQPBTg7nlFJR1KajG3FadfmBbXKOGeK(nEKHdwWSfwGZoWIefK0HKO)7fWRFp3ycFvsstjXX75MSkujFKKijOljs6sIcs6qscKe9FVagAW7y5WxLefKKajr)3ly98u2WxLefK0HKeiXcrYLxBOge9B(5mjPPKyHqdiuzfSWcjSnN3EoJvNBwC4RsIcsC8EUjRcvYhjaJe0LejDjrbjRFi4nStmNxygCyssKKwtIeasIfwG)zdQhBhmNDZGOI5Ad7eZzKU5ZKKMsseeJjrbjtT8Pcn(YG53GOFZhh7tHjbyK0YKibGKyHf4F2G6X2bZz3miQyU2WoXCgPB(mjD1AC7oWsRzkRFLVdS0wn9Ph600LwdxEKHb10TwJB3bwAnCSkujF5iybQ1aYy7nQ7alTgDeZKa8XQqL8rIUHfijWIelijkNTNKM1VNBmK8vjXlqsWosMKh8iPf)gSFK4fijOuNashkRwJ9MLVX1AIGymjkizQLpvOXxgm)ge9B(4yFkmjaJe9qhjPPK0HKO)7fuVjgEGJBY(z9ASz1Vb7xaPB(mjaJKwrxsKKMss0)9cQ3edpWXnz)SEn2S63G9lG0nFMKerJKwrxsK0LefKe9FVaE975gt4RsIcs6qIfcnGqLvW65PSHJJ9PWKKijOljsstjb8(dyOGzliMKUARM(0dWQPlTgU8iddQPBTg3UdS0AWlBm(LFg)yTglqwdNx)qWlwtF6P1yVz5BCTMJFhJ79idtIcs2jMZlmdomjjsIEOJefKGvzJjV(HGxCaV(9MJjbyKGEKOGexnB7zBBsuqshsI(VxW65PSHJJ9PWKKij6LejPPKKajr)3ly98u2WxLKUAnGm2EJ6oWsRr)IFhJ7j5z8JjbwK8vjzHK0ssw)qWlMeLZ2d)ljOuNashkljr8uiiXJG)LKfscJk15ys8cKKcUKarYN1vvNcH2QPp9qDA6sRHlpYWGA6wRXT7alTM3)akdFz28lwRbKX2Bu3bwAn6iMjr)dbEsMhjtHhqMeVib4TMrfZK4fijMPysMLKVkjkNTNeNKw8BW(rI6bTK4fij6e0v3bjtsJs)I1AS3S8nUwdBnJkMdtL9cisuqIRMT9STnjkij6)Eb1BIHh44MSFwVgBw9BW(fq6MptcWiPv0LejkiPdjGWn4GU6oi5mwPFXzqp2rWHDSTNcbjPPKKajwisU8AdfBpObEGKKMscwLnM86hcEXKKijTssxTvtF6H610LwdxEKHb10TwJB3bwAn41VNBmAnGm2EJ6oWsRrhXmjojnRFp3yibWrXBpjQh0sYVmmgtsZ63ZngsgmjU5yheis(QKapsac(jXpMepc(xswijqK8zDvs0jUf1AS3S8nUwt0)9cWI3ECwLplRUdScFvsuqshsI(VxaV(9CJjC87yCVhzysstjXX75MSkujFKKijaWKiPR2QPp9aGA6sRHlpYWGA6wRXT7alTg863ZngTgqgBVrDhyP1O)(XQKOtClsse)GhtckHfsyBMeLZ2tsZ63Zngs8cKKTNlsAw)W)dbR1yVz5BCTglejxETHAq0V5NZKOGKoKG0VXJmCWclKW2CgKXavwsstjXcHgqOYky98u2WxLK0usI(VxW65PSHVkjDjrbjwi0acvwblSqcBZ5TNZy15Mfhoo2NctcWibHfme7OIeudjwEmK0HehVNBYQqL8rcGibDjrsxsuqs0)9c41VNBmHJJ9PWKamsqpsuqscKaE)bmuWSfeRTA6R1K00LwdxEKHb10TwJ9MLVX1ASqKC51gQbr)MFotIcs6qcs)gpYWblSqcBZzqgduzjjnLeleAaHkRG1ZtzdFvsstjj6)EbRNNYg(QK0LefKyHqdiuzfSWcjSnN3EoJvNBwC44yFkmjaJealjkij6)Eb863ZnMWxLefKWwZOI5WuzVaIefKKaji9B8idhgef84mE9d)pemjkijbsaV)agky2cI1AC7oWsRbV(H)hcwB10xR6PPlTgU8iddQPBTg3UdS0AWRF4)HG1AazS9g1DGLwJoIzsAw)W)dbtIYz7jXlsaCu82tI6bTKapsMhjab)aiijqK8zDvs0jUfjr5S9Kae8FKumQwsSoEdKOtdgsc4pwftIoXTij(sY2ZKWfijWhjBptcaGCT9aDKe9FpsMhjnRFp3yirj8BalaCj55gdjW3Jeyrc6rc8iXWymjRFi4fR1yVz5BCTMO)7fGfV94S1W(Lro4bwHVkjPPK0HKeibV(9MJdUA22Z22KOGKeibPFJhz4WGOGhNXRF4)HGjjnLKoKe9FVG1Ztzdhh7tHjbyKGosuqs0)9cwppLn8vjjnLKoKe9FVW5i5c(X53Xf6du44yFkmjaJeewWqSJksqnKy5XqshsC8EUjRcvYhjaIKwMejDjrbjr)3lCosUGFC(DCH(af(QK0LKUKOGeK(nEKHd41VNBmzLWAZp3yYW3JefKGvzJjV(HGxCaV(9CJHeGrsljPljkiPdjjqY9l(bpeCyNywj8Qm4XEC0uG8fyaZFuvzqsstjbRYgtE9dbV4aE975gdjaJKwssxTvtFT2QMU0A4YJmmOMU1AC7oWsRPyL5yiS0AazS9g1DGLwJoIzs0VHWctYuK0an(rcWBnJkMjXlqsWosMe9)3yir)gclsEWJeuQtaPdLvRXEZY34AnDij6)Eb2AgvmNXqJFHJJ9PWKKijmQy7F58oXmjPPK0HeBVFiymjOrsRKOGKJT9(HGZ7eZKamsqhjDjjnLeBVFiymjOrsljPljkiXvZ2E22wB10xRTutxAnC5rggut3An2Bw(gxRPdjr)3lWwZOI5mgA8lCCSpfMKejHrfB)lN3jMjjnLKoKy79dbJjbnsALefKCST3peCENyMeGrc6iPljPPKy79dbJjbnsAjjDjrbjUA22Z22AnUDhyP107MxogclTvtFTIEA6sRHlpYWGA6wRXEZY34AnDij6)Eb2AgvmNXqJFHJJ9PWKKijmQy7F58oXmjkiPdjwi0acvwbRNNYgoo2NctsIKGUKijnLeleAaHkRGfwiHT582ZzS6CZIdhh7tHjjrsqxsK0LK0us6qIT3pemMe0iPvsuqYX2E)qW5DIzsagjOJKUKKMsIT3pemMe0iPLK0LefK4QzBpBBR142DGLwZ7Bm5yiS0wn91k600LwdxEKHb10TwdiJT3OUdS0A0rmtcGle4jbwKGs9NwJB3bwAnk97g4LHVmB(fRTA6RvaRMU0A4YJmmOMU1AGQAnyE1AC7oWsRbPFJhzyTgKU5ZAnyv2yYRFi4fhWRFV5yssKe0JeasYZaHhjDij2XlFaLr6MptcQHe9skjsaejTMejDjbGK8mq4rshsI(VxaV(H)hcoZXQqL8fZ1MXqJFb8622Kaisqps6Q1aYy7nQ7alTgu6g734lJjrzpV98rYcj5JzsAw)EZXKmfjnqJFKOSFS9Kmys8Le0rY6hcEXaupsEWJegjFarsRjHAjj2XlFarc8ib9iPz9d)pemjaFSkujFXCTKGx32gR1G0VC5XSwdE97nhNNkJHg)0wn91kQttxAnC5rggut3AnUDhyP1O88TxRbKX2Bu3bwAn6iMjbW98TNKPiPbA8JeG3Agvmtc8izEKuqsAw)EZXKOCmgsEZsYulKeuQtaPdLLeVakgESwJ9MLVX1A6qcBnJkMdMF5xUyuTKKMscBnJkMdEbuUyuTKOGeK(nEKHddoBnSJKjPljkiPdjRFi4nStmNxygCyssKe0JK0usyRzuXCW8l)YtLBLK0usEdI(nFCSpfMeGrIEjrsxsstjj6)Eb2AgvmNXqJFHJJ9PWKamsC7oWkGx)EZXbgvS9VCENyMefKe9FVaBnJkMZyOXVWxLK0usyRzuXCyQmgA8JefKKaji9B8idhWRFV548uzm04hjPPKe9FVG1Ztzdhh7tHjbyK42DGvaV(9MJdmQy7F58oXmjkijbsq634rgom4S1WosMefKe9FVG1Ztzdhh7tHjbyKWOIT)LZ7eZKOGKO)7fSEEkB4RssAkjr)3lCosUGFC(DCH(af(QKOGeSkBm5EhVmjjsssbaljkiPdjyv2yYRFi4ftcWqJKwssAkjjqY6gU2ag(nz4lV9C(bpgVbU8iddssxsstjjbsq634rgom4S1WosMefKe9FVG1Ztzdhh7tHjjrsyuX2)Y5DIzTvtFTI610LwdxEKHb10TwdiJT3OUdS0A0rmtsZ63BoMK5rYuK0c)YpsaERzuXmkizksAGg)ib4TMrfZKalsqpasY6hcEXKapswijQh0ssd04hjaV1mQywRXT7alTg863BowB10xRaqnDP1WLhzyqnDR1aYy7nQ7alTg9VBmB)91AC7oWsR5(v2T7aRSzWRwJzWBU8ywR55gZ2FFTvB1AEUXS93xtxA6tpnDP1WLhzyqnDR142DGLwdE9d)peSwdiJT3OUdS0AAw)W)dbtYdEKedrYXCTK8ldJXK8XtHGeDd1PU0AS3S8nUwtcKC)IFWdbhICJxwodFz3yYB)uiWbgW8hvvguB10xRA6sRHlpYWGA6wRXT7alTg8VEZXAnwGSgoV(HGxSM(0tRXEZY34AnGWnedH1BooCCSpfMKej54yFkmjOgsATvsaej6H61AazS9g1DGLwdkD8sY2ZKacxsuoBpjBptsmeVKStmtYcjXbbj5x7yiz7zsIDurc4)8DGfjdMK(zdK08R3Cmjhh7tHjj(B2r1mmijlKKyFT9KedH1BoMeW)57alTvtFTutxAnUDhyP1edH1BowRHlpYWGA6wB1wTg8QPln9PNMU0A4YJmmOMU1AC7oWsR5CKCb)4874c9bsRbKX2Bu3bwAn6iMjz7zsaaKRThOJeLZ2tItck1jG0HYsY27ljdUaWLK3bJjPf)gSFAn2Bw(gxRj6)EbRNNYgoo2NctsIKOh60wn91QMU0A4YJmmOMU1AC7oWsRbV(H)hcwRbKX2Bu3bwAn6iMjPz9d)pemjlKK2mRsYxLKTNjr)DShhnfiFKe9FpsMhjZsIs43ascJk15ysI4h8ysEtn4(PqqY2ZKumQwsSoEjbEKSqsa)XQKeXp4XKGsyHe2M1AS3S8nUwZ9l(bpeCyNywj8Qm4XEC0uG8fyaZFuvzqsuqshsyRzuXCyQSxarIcssGKoK0HKO)7f2jMvcVkdEShhnfiFHJJ9PWKKijUDhyfuE(2hyuX2)Y5DIzsaijjf0JefK0He2AgvmhMkhb3EsstjHTMrfZHPYyOXpsstjHTMrfZbZV8lxmQws6ssAkjr)3lStmReEvg8ypoAkq(chh7tHjjrsC7oWkGx)EZXbgvS9VCENyMeasssb9irbjDiHTMrfZHPYMF5hjPPKWwZOI5agA8lxmQwsstjHTMrfZbVakxmQws6ssxsstjjbsI(VxyNywj8Qm4XEC0uG8f(QK0LK0us6qs0)9cwppLn8vjjnLeK(nEKHdwyHe2MZGmgOYssxsuqIfcnGqLvWclKW2CE75mwDUzXHJDqGirbjwisU8Ad1GOFZpNjPljkiPdjjqIfIKlV2qBGUXlsstjXcHgqOYkWXQqL8LJGfy44yFkmjjscQNKUKOGKoKe9FVG1ZtzdFvsstjjbsSqObeQScwppLnCSdcejD1wn91snDP1WLhzyqnDR142DGLwJd6Q7GKZyL(fR1ybYA486hcEXA6tpTg7nlFJR1KajGWn4GU6oi5mwPFXzqp2rWHDSTNcbjkijbsC7oWk4GU6oi5mwPFXzqp2rWHPYpZGOFjrbjDijbsaHBWbD1DqYzSs)IZ9SBc7yBpfcsstjbeUbh0v3bjNXk9lo3ZUjCCSpfMKejbDK0LK0usaHBWbD1DqYzSs)IZGESJGd41TTjbyK0ssuqciCdoORUdsoJv6xCg0JDeC44yFkmjaJKwsIcsaHBWbD1DqYzSs)IZGESJGd7yBpfcTgqgBVrDhyP1OJyMeDc6Q7GKjPrPFXKOSNls2E(ysgmjfKe3UdsMeSs)IrbjoMeJVmjoMevigprgMeyrcwPFXKOC2EsALe4rYJvYhj41TTXKapsGfjojTeGKGv6xmjyijBVVKS9mjfRKeSs)IjXVBqYysaa4Jxs83YhjBVVKGv6xmjmQuNJXARM(qpnDP1WLhzyqnDR142DGLwJfwiHT582ZzS6CZI1AazS9g1DGLwJoIzmjOewiHTzsMhjOuNashkljdMKVkjWJeGGFs8JjbKXav2Pqqck1jG0HYsIYz7jbLWcjSntIxGKae8tIFmjrSbQKe0ljs0jUf1AS3S8nUwtcKaE)bmuWSfetIcs6qshsq634rgoyHfsyBodYyGkljkijbsSqObeQScwppLnCSdcejkijbsUFXp4HGdQ3edpWXnz)SEn2S63G9lWLhzyqsstjj6)EbRNNYg(QK0LefK449CtwfQKpsagjOxsKOGKoKe9FVaBnJkMZMF5x44yFkmjjsIEjrsAkjr)3lWwZOI5mgA8lCCSpfMKejrVKiPljPPK8ge9B(4yFkmjaJe9sIefKKajwi0acvwbRNNYgo2bbIKUARM(qNMU0A4YJmmOMU1AGQAnyE1AC7oWsRbPFJhzyTgKU5ZAnDij6)EHZrYf8JZVJl0hOWXX(uyssKe0rsAkjjqs0)9cNJKl4hNFhxOpqHVkjDjrbjDij6)EH2tbEmyMJvHk5lMRnZfFig0Ndhh7tHjbyKGWcgIDursxsuqshsI(VxGTMrfZzm04x44yFkmjjscclyi2rfjPPKe9FVaBnJkMZMF5x44yFkmjjscclyi2rfjD1AazS9g1DGLwdkHf4SdSi5bpsCJHeq4Ijz79LKyVnJjb)pMKTNbIe)4caxso(DmUNbjrzpxKOF5i5c(XKO)pUqFGiP3XKyymMKT3lsqhjy2Ij54yFQPqqc8iz7zsAd0nErs0)9izWK4rW)sYcj55gdjW3Je4rIxarcWBnJkMjzWK4rW)sYcjHrL6CSwds)YLhZAnGWnFmG5phhZ1I1wn9by10LwdxEKHb10TwJB3bwAnXqy9MJ1AS3S8nUwZXVJX9EKHjrbjRFi4nStmNxygCyssKe9ALefK0HexnB7zBBsuqcs)gpYWbq4MpgW8NJJ5AXK0vRXcK1W51pe8I10NEARM(qDA6sRHlpYWGA6wRXT7alTg8VEZXAn2Bw(gxR543X4EpYWKOGK1pe8g2jMZlmdomjjsIETsIcs6qIRMT9STnjkibPFJhz4aiCZhdy(ZXXCTys6Q1ybYA486hcEXA6tpTvtFOEnDP1WLhzyqnDR142DGLwdEzJXV8Z4hR1yVz5BCTMJFhJ79idtIcsw)qWByNyoVWm4WKKij6byjrbjDiXvZ2E22MefKG0VXJmCaeU5Jbm)54yUwmjD1ASaznCE9dbVyn9PN2QPpaOMU0A4YJmmOMU1AC7oWsR5bplNHVC57)yTgqgBVrDhyP1OJyMe9puFKalsSGKOC2E4FjX6QQtHqRXEZY34AnUA22Z22ARM(0ljnDP1WLhzyqnDR142DGLwdhRcvYxocwGAnGm2EJ6oWsRrhXmjaaNc8yqsAuNBwmjkNTNeVaIedSqqcxWpIEsmoENcbjaV1mQyMeVajzpGizHKyMIjzws(QKOC2EsAXVb7hjEbsck1jG0HYQ1yVz5BCTMoK0HKO)7fyRzuXCgdn(foo2NctsIKOxsKKMss0)9cS1mQyoB(LFHJJ9PWKKij6LejDjrbjwi0acvwbRNNYgoo2NctsIK0YKirbjDij6)Eb1BIHh44MSFwVgBw9BW(fq6MptcWiPv0ljsstjjbsUFXp4HGdQ3edpWXnz)SEn2S63G9lWaM)OQYGK0LKUKKMss0)9cQ3edpWXnz)SEn2S63G9lG0nFMKerJKwrDjrsAkjwi0acvwbRNNYgo2bbIefK449CtwfQKpssKeaysARM(0tpnDP1WLhzyqnDR142DGLwJLnmEh3KDZGOI5A1AazS9g1DGLwJoIzsqPobKouwsuoBpjOewiHTzabaCkWJbjPrDUzXK4fijGWcaxsGi5t5nltsl(ny)ibEKOSNls0TbcbnF8sIs43ascJk15ysI4h8ysqPobKouwsyuPohJ1AS3S8nUwtcKaE)bmuWSfetIcsq634rgoybZwybo7alsuqshsC8EUjRcvYhjjscamjsuqshsI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLK0ussGelejxETH2aDJxK0LK0usSqKC51gQbr)MFotsAkjr)3lezGqqZhVHVkjkij6)EHidecA(4nCCSpfMeGrsRjrcajPdjDibascQHK7x8dEi4G6nXWdCCt2pRxJnR(ny)cmG5pQQmijDjbGK0HelSa)Zgup2oyo7MbrfZ1g2jMZiDZNjPljDjPljkijbsI(VxW65PSHVkjkiPdjjqIfIKlV2qni638ZzsstjXcHgqOYkyHfsyBoV9CgRo3S4WxLK0usIGymjkizQLpvOXxgm)ge9B(4yFkmjaJeleAaHkRGfwiHT582ZzS6CZIdhh7tHjbGKayjjnLKPw(uHgFzW8Bq0V5JJ9PWKGAjrpuFsKamsAnjsaijDiXclW)Sb1JTdMZUzquXCTHDI5ms38zs6ssxTvtF61QMU0A4YJmmOMU1AS3S8nUwtcKaE)bmuWSfetIcsq634rgoybZwybo7alsuqshsC8EUjRcvYhjjscamjsuqshsI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLK0ussGelejxETH2aDJxK0LK0usSqKC51gQbr)MFotsAkjr)3lezGqqZhVHVkjkij6)EHidecA(4nCCSpfMeGrsltIeasshs6qcaKeudj3V4h8qWb1BIHh44MSFwVgBw9BW(fyaZFuvzqs6scajPdjwyb(NnOESDWC2ndIkMRnStmNr6Mptsxs6ssxsuqscKe9FVG1ZtzdFvsuqshssGelejxETHAq0V5NZKKMsIfcnGqLvWclKW2CE75mwDUzXHVkjPPKebXysuqYulFQqJVmy(ni638XX(uysagjwi0acvwblSqcBZ5TNZy15Mfhoo2NctcajbWssAkjtT8Pcn(YG53GOFZhh7tHjb1sIEO(KibyK0YKibGK0HelSa)Zgup2oyo7MbrfZ1g2jMZiDZNjPljD1AC7oWsRzkRFLVdS0wn9Pxl10LwdxEKHb10TwduvRbZRwJB3bwAni9B8idR1G0nFwRjbsSqObeQScwppLnCSdcejPPKKaji9B8idhSWcjSnNbzmqLLefKyHi5YRnudI(n)CMK0usaV)agky2cI1AazS9g1DGLwdaG(nEKHj5JzqsGfjE0yMDymjBVVKO0RLKfssetc2rYGK8GhjOuNashkljyijBVVKS9mqK4hxljkD8YGKaaWhVKeXp4XKS9CSwds)YLhZAnyhjNFWlB98uwTvtF6HEA6sRHlpYWGA6wRXT7alTM3)akdFz28lwRbKX2Bu3bwAn6iMXKO)HapjZJKPiXlsaERzuXmjEbsYEdJjzHKyMIjzws(QKOC2EsAXVb7hkibL6eq6qzjXlqs0jORUdsMKgL(fR1yVz5BCTg2AgvmhMk7fqKOGexnB7zBBsuqs0)9cQ3edpWXnz)SEn2S63G9lG0nFMeGrsROxsKOGKoKac3Gd6Q7GKZyL(fNb9yhbh2X2EkeKKMsscKyHi5YRnuS9Gg4bssxsuqcs)gpYWbSJKZp4LTEEkljkijbsI(Vx4CKCb)4874c9bk8vjjnLKO)7fohjxWpo)oUqFGchh7tHjbyKaajrbjr)3lCosUGFC(DCH(af(QARM(0dDA6sRHlpYWGA6wRXT7alTg863ZngTgqgBVrDhyP1OJyMeahfV9K0S(9CJHe1dAXKmpsAw)EUXqYGlaCj5RQ1yVz5BCTMO)7fGfV94SkFwwDhyf(QKOGKO)7fWRFp3ych)og37rgwB10NEawnDP1WLhzyqnDR1yVz5BCTMO)7fWRFg4bgoo2NctcWibDKOGKoKe9FVaBnJkMZyOXVWXX(uyssKe0rsAkjr)3lWwZOI5S5x(foo2NctsIKGos6sIcsC8EUjRcvYhjjscamjTg3UdS0ASEzzto6)EAnr)3lxEmR1Gx)mWduB10NEOonDP1WLhzyqnDR142DGLwdE9d)peSwdiJT3OUdS0A0F)yvmj6e3IKeXp4XKGsyHe2Mj5JNcbjBptckHfsyBMelSaNDGfjlKeBpBBtY8ibLWcjSntYGjXT73ngGiXJG)LKfssetI1XRwJ9MLVX1ASqKC51gQbr)MFotIcsq634rgoyHfsyBodYyGkljkiXcHgqOYkyHfsyBoV9CgRo3S4WXX(uysagjOJefKKajG3FadfmBbXARM(0d1RPlTgU8iddQPBTg3UdS0AWRFp3y0AazS9g1DGLwJoIzsAw)EUXqIYz7jPzzJXps0F38ws8cKKcssZ6NbEGOGeL9CrsbjPz975gdjdMKVkkibi4Ne)ysMIKw4x(rcWBnJkMjbEKSqsupOLKw8BW(rIYEUiXJGizsaGjrIoXTijWJehu13bjtcwPFXK07ysq9aeZwmjhh7tnfcsGhjdMKPi5zge9RwJ9MLVX1Aw3W1gWlBm(LbV5TbU8iddsIcssGK1nCTb86NbEGbU8iddsIcsI(VxaV(9CJjC87yCVhzysuqshsI(VxGTMrfZzZV8lCCSpfMKejbWsIcsyRzuXCyQS5x(rIcsI(Vxq9My4boUj7N1RXMv)gSFbKU5ZKamsAfDjrsAkjr)3lOEtm8ah3K9Z61yZQFd2Vas38zssensAfDjrIcsC8EUjRcvYhjjscamjsstjbeUbh0v3bjNXk9lod6XocoCCSpfMKejb1tsAkjUDhyfCqxDhKCgR0V4mOh7i4Wu5Nzq0VK0LefKKajwi0acvwbRNNYgo2bbsB10NEaqnDP1WLhzyqnDR142DGLwdE9d)peSwdiJT3OUdS0A0rmtsZ6h(FiysaCu82tI6bTys8cKeWFSkj6e3IKOSNlsqPobKouwsGhjBptcaGCT9aDKe9FpsgmjEe8VKSqsEUXqc89ibEKae8dGGKyDvs0jUf1AS3S8nUwt0)9cWI3EC2Ay)Yih8aRWxLK0usI(VxO9uGhdM5yvOs(I5AZCXhIb95WxLK0usI(VxW65PSHVkjkiPdjr)3lCosUGFC(DCH(afoo2NctcWibHfme7OIeudjwEmK0HehVNBYQqL8rcGiPLjrsxsuqs0)9cNJKl4hNFhxOpqHVkjPPKKajr)3lCosUGFC(DCH(af(QKOGKeiXcHgqOYkCosUGFC(DCH(afo2bbIK0ussGelejxETbKCT9aDK0LK0usC8EUjRcvYhjjscamjsuqcBnJkMdtL9ciTvtFTMKMU0A4YJmmOMU1AC7oWsRbV(H)hcwRbKX2Bu3bwAn66aIKfssS3Mjz7zsIy8sc8rsZ6NbEGKebej41TTNcbjZsYxLeaZFSTnarYuK4fqKa8wZOIzsI(ljT43G9JKbxljEe8VKSqsIysupO1YGAn2Bw(gxRzDdxBaV(zGhyGlpYWGKOGKei5(f)GhcoStmReEvg8ypoAkq(cmG5pQQmijkiPdjr)3lGx)mWdm8vjjnLehVNBYQqL8rsIKaatIKUKOGKO)7fWRFg4bgWRBBtcWiPLKOGKoKe9FVaBnJkMZyOXVWxLK0usI(VxGTMrfZzZV8l8vjPljkij6)Eb1BIHh44MSFwVgBw9BW(fq6MptcWiPvuxsKOGKoKyHqdiuzfSEEkB44yFkmjjsIEjrsAkjjqcs)gpYWblSqcBZzqgduzjrbjwisU8Ad1GOFZpNjPR2QPVw1ttxAnC5rggut3AnUDhyP1Gx)W)dbR1aYy7nQ7alTg93pwLKM1p8)qWKmfjojOoaIzljnqJFKa8wZOIzuqciSaWLedVKmljQh0ssl(ny)iPZ27ljdMKEVanmijrarcpBpFKS9mjnRFp3yiXmftc8iz7zs0jUfteaMejMPysEWJKM1p8)qWDrbjGWcaxsGi5t5nltIxKa4O4TNe1dAjXlqsm8sY2ZK4rqKmjMPys69c0WK0S(zGhOwJ9MLVX1AsGK7x8dEi4WoXSs4vzWJ94OPa5lWaM)OQYGKOGKoKe9FVG6nXWdCCt2pRxJnR(ny)ciDZNjbyK0kQljsstjj6)Eb1BIHh44MSFwVgBw9BW(fq6MptcWiPv0LejkizDdxBaVSX4xg8M3g4YJmmijDjrbjr)3lWwZOI5mgA8lCCSpfMKejb1rIcsyRzuXCyQmgA8JefKKajr)3lalE7Xzv(SS6oWk8vjrbjjqY6gU2aE9ZapWaxEKHbjrbjwi0acvwbRNNYgoo2NctsIKG6irbjDiXcHgqOYk0EkWJbZy15Mfhoo2NctsIKG6ijnLKeiXcrYLxBOnq34fjD1wn91ARA6sRHlpYWGA6wRXT7alTMIvMJHWsRbKX2Bu3bwAn6iMjr)gclmjtrsl8l)ib4TMrfZK4fijyhjtcGtCZdG6)VXqI(newK8GhjOuNashkljEbscaWPapgKeGpwfQKVyUwTg7nlFJR10HKO)7fyRzuXC28l)chh7tHjjrsyuX2)Y5DIzsstjPdj2E)qWysqJKwjrbjhB79dbN3jMjbyKGos6ssAkj2E)qWysqJKwssxsuqIRMT9STnjkibPFJhz4a2rY5h8YwppLvB10xRTutxAnC5rggut3An2Bw(gxRPdjr)3lWwZOI5S5x(foo2NctsIKWOIT)LZ7eZKOGKeiXcrYLxBOnq34fjPPK0HKO)7fApf4XGzowfQKVyU2mx8HyqFo8vjrbjwisU8AdTb6gViPljPPK0HeBVFiymjOrsRKOGKJT9(HGZ7eZKamsqhjDjjnLeBVFiymjOrsljjnLKO)7fSEEkB4RssxsuqIRMT9STnjkibPFJhz4a2rY5h8YwppLvRXT7alTME38YXqyPTA6Rv0ttxAnC5rggut3An2Bw(gxRPdjr)3lWwZOI5S5x(foo2NctsIKWOIT)LZ7eZKOGKeiXcrYLxBOnq34fjPPK0HKO)7fApf4XGzowfQKVyU2mx8HyqFo8vjrbjwisU8AdTb6gViPljPPK0HeBVFiymjOrsRKOGKJT9(HGZ7eZKamsqhjDjjnLeBVFiymjOrsljjnLKO)7fSEEkB4RssxsuqIRMT9STnjkibPFJhz4a2rY5h8YwppLvRXT7alTM33yYXqyPTA6Rv0PPlTgU8iddQPBTgqgBVrDhyP1OJyMeaxiWtcSiXcQ142DGLwJs)UbEz4lZMFXARM(AfWQPlTgU8iddQPBTg3UdS0AWRFV5yTgqgBVrDhyP1OJyMKM1V3CmjlKe1dAjPbA8JeG3AgvmJcsqPobKouws6DmjggJjzNyMKT3lsCsaCpF7jHrfB)ltIHFljWJeyzaIKw4x(rcWBnJkMjzWK8v1AS3S8nUwdBnJkMdtLn)YpsstjHTMrfZbm04xUyuTKKMscBnJkMdEbuUyuTKKMss0)9ck97g4LHVmB(fh(QKOGKO)7fyRzuXC28l)cFvsstjPdjr)3ly98u2WXX(uysagjUDhyfuE(2hyuX2)Y5DIzsuqs0)9cwppLn8vjPR2QPVwrDA6sRHlpYWGA6wRbKX2Bu3bwAn6iMjbW98TNe42ZNYbZKOSFS9KmysMIKgOXpsaERzuXmkibL6eq6qzjbEKSqsupOLKw4x(rcWBnJkM1AC7oWsRr55BV2QPVwr9A6sRHlpYWGA6wRbKX2Bu3bwAn6F3y2(7R142DGLwZ9RSB3bwzZGxTgZG3C5XSwZZnMT)(AR2Q1OESfgh5RMU00NEA6sRXT7alTM2tbEmygRo3SyTgU8iddQPBTvtFTQPlTgU8iddQPBTgOQwdMxTg3UdS0Aq634rgwRbPB(SwtsAnGm2EJ6oWsRrx9mji9B8idtYGjbZljlKKKir5S9KuqsWRVKals(yMK9MQnVyuqIEKOSNls2EMK3C4LeyXKmysGfjFmJcsALK5rY2ZKGzlSajzWK4fijTKK5rseC7jXpwRbPF5YJzTgyL)yoV3uT5vB10xl10LwdxEKHb10TwduvRXbb1AC7oWsRbPFJhzyTgKU5ZAn6P1yVz5BCTM9MQnVHvVWh7rgMefKS3uT5nS6fSqObeQScG)Z3bwAni9lxEmR1aR8hZ59MQnVARM(qpnDP1WLhzyqnDR1av1ACqqTg3UdS0Aq634rgwRbPB(SwtRAn2Bw(gxRzVPAZByBn8XEKHjrbj7nvBEdBRbleAaHkRa4)8DGLwds)YLhZAnWk)XCEVPAZR2QPp0PPlTg3UdS0AIHWQ9u5h8I1A4YJmmOMU1wn9by10LwdxEKHb10TwJB3bwAnkpF71AmtXzlOwJEjP1yVz5BCTMoKWwZOI5G5x(LlgvljPPKWwZOI5Wuzm04hjPPKWwZOI5Wu5i42tsAkjS1mQyo4fq5Ir1ssxTgqgBVrDhyP10IhBD8ssRKa4E(2tIxGK4K0S(H)hcMeyrsJUir5S9KOVbr)sI(3zs8cKeDd1PUibEK0S(9MJjbU98PCWS2QPpuNMU0A4YJmmOMU1AS3S8nUwthsyRzuXCW8l)YfJQLK0usyRzuXCyQmgA8JK0usyRzuXCyQCeC7jjnLe2Agvmh8cOCXOAjPljkir9yKb9ckpF7jrbjjqI6XidTguE(2R142DGLwJYZ3ETvtFOEnDP1WLhzyqnDR1yVz5BCTMei5(f)Ghcoe5gVSCg(YUXK3(PqGdC5rggKK0ussGelejxETHAq0V5NZKKMsscKGvzJjV(HGxCaV(9CJHe0irpsstjjbsw3W1gkF)hJZrUXllh4YJmmijPPK0He2AgvmhWqJF5Ir1ssAkjS1mQyomv28l)ijnLe2AgvmhMkhb3EsstjHTMrfZbVakxmQws6Q142DGLwdE97nhRTA6daQPlTgU8iddQPBTg7nlFJR1C)IFWdbhICJxwodFz3yYB)uiWbU8iddsIcsSqKC51gQbr)MFotIcsWQSXKx)qWloGx)EUXqcAKONwJB3bwAn41p8)qWAR2QTAni5dpWstFTMuR6Le6sQvTgL(vtHaR1a4Qt9l9Pd6dWz9djKOREMKjwfEljp4rcacYp)BwaKKJbm)5yqsWWyMe)VWyFzqsS9EHGXbk5wykMeaR(HeuclK8TmijntmkjbduToQib1sYcjPf(ojGdYbpWIeOkF(cps6aOUK0Pvu1nqj3ctXKG60pKGsyHKVLbjba3BQ28g0laacGKSqsaW9MQnVHvVaaiassNwrv3aLClmftcQt)qckHfs(wgKeaCVPAZBO1aaiasYcjba3BQ28g2wdaGaijDAfvDduYTWumj6PN(HeuclK8Tmija49l(bpeCaaeajzHKaG3V4h8qWbaWaxEKHbbqs6OhQ6gOKBHPys0tp9djOewi5BzqsaW9MQnVb9caGaijlKeaCVPAZBy1laacGK0rpu1nqj3ctXKONE6hsqjSqY3YGKaG7nvBEdTgaabqswija4Et1M3W2AaaeajPJEOQBGsUfMIjrVw1pKGsyHKVLbjbaVFXp4HGdaGaijlKea8(f)Ghcoaag4YJmmiassh9qv3aLClmftIETQFibLWcjFldscaU3uT5nOxaaeajzHKaG7nvBEdREbaqaKKo6HQUbk5wykMe9Av)qckHfs(wgKeaCVPAZBO1aaiasYcjba3BQ28g2wdaGaijD0dvDduYTWumj61s9djOewi5BzqsaW7x8dEi4aaiasYcjbaVFXp4HGdaGbU8iddcGK0Pvu1nqjtjd4Qt9l9Pd6dWz9djKOREMKjwfEljp4rcaQESfgh5lasYXaM)CmijyymtI)xySVmij2EVqW4aLClmftsl1pKGsyHKVLbjba3BQ28g0laacGKSqsaW9MQnVHvVaaiassNwrv3aLClmftc6PFibLWcjFldscaU3uT5n0AaaeajzHKaG7nvBEdBRbaqaKKoTIQUbk5wykMeuV(HeuclK8Tmija49l(bpeCaaeajzHKaG3V4h8qWbaWaxEKHbbqs6OhQ6gOKBHPysaG6hsqjSqY3YGKaG3V4h8qWbaqaKKfscaE)IFWdbhaadC5rggeajPJEOQBGsMsgWvN6x6th0hGZ6hsirx9mjtSk8wsEWJea0HmasYXaM)CmijyymtI)xySVmij2EVqW4aLClmftsl1pKGsyHKVLbjbaVFXp4HGdaGaijlKea8(f)Ghcoaag4YJmmiassh9qv3aLClmftcGv)qckHfs(wgKKMjgLKGbQwhvKGArTKSqsAHVtsme8B(ysGQ85l8iPdQTljD0dvDduYTWumjOE9djOewi5BzqsAMyuscgOADurcQLKfssl8DsahKdEGfjqv(8fEK0bqDjPJEOQBGsUfMIjrp90pKGsyHKVLbjPzIrjjyGQ1rfjOwswijTW3jbCqo4bwKav5Zx4rsha1LKo6HQUbk5wykMe9aG6hsqjSqY3YGK0mXOKemq16OIeuljlKKw47Kaoih8alsGQ85l8iPdG6ssh9qv3aLClmftsR6PFibLWcjFldssZeJssWavRJksqTKSqsAHVtc4GCWdSibQYNVWJKoaQljD0dvDduYTWumjTcy1pKGsyHKVLbjPzIrjjyGQ1rfjOwswijTW3jbCqo4bwKav5Zx4rsha1LKoTIQUbkzkzaxDQFPpDqFaoRFiHeD1ZKmXQWBj5bpsaWNBmB)9bqsogW8NJbjbdJzs8)cJ9LbjX27fcghOKBHPysAv)qckHfs(wgKKMjgLKGbQwhvKGAjzHK0cFNeWb5GhyrcuLpFHhjDauxs6OhQ6gOKPKbC1P(L(0b9b4S(Hes0vptYeRcVLKh8ibaXlasYXaM)CmijyymtI)xySVmij2EVqW4aLClmftc6PFibLWcjFldscaE)IFWdbhaabqswija49l(bpeCaamWLhzyqaKKo6HQUbk5wykMe90t)qckHfs(wgKKMjgLKGbQwhvKGArTKSqsAHVtsme8B(ysGQ85l8iPdQTljD0dvDduYTWumj61Q(HeuclK8TmijntmkjbduToQib1IAjzHK0cFNKyi438XKav5Zx4rshuBxs6OhQ6gOKBHPys0daQFibLWcjFldssZeJssWavRJksqTKSqsAHVtc4GCWdSibQYNVWJKoaQljD0dvDduYuYaU6u)sF6G(aCw)qcj6QNjzIvH3sYdEKaGrqFbqsogW8NJbjbdJzs8)cJ9LbjX27fcghOKBHPys0d1RFibLWcjFldssZeJssWavRJksqTKSqsAHVtc4GCWdSibQYNVWJKoaQljDAjQ6gOKBHPys0daQFibLWcjFldssZeJssWavRJksqTKSqsAHVtc4GCWdSibQYNVWJKoaQljD0dvDduYuY6qSk8wgKealjUDhyrIzWloqjR1OEW3yyTgGd4ir3UXlltI(7(diLmWbCKK8VysAf1HcsAnPw1JsMsg4aosqzVxiyS(Hsg4aosa8KOtqqgKKgOXps0n7XbkzGd4ibWtck79cbdsY6hcEZZJeRJzmjlKelqwdNx)qWloqjdCahjaEs0V4yisgKKFvSLXy)aIeK(nEKHXK0zcCafKOEmYmE9d)pemja(ejr9yKb86h(Fi4UbkzGd4ibWtIorchqsup264DkeKa4E(2tY8izwaetY2ZKO8GfcsaERzuXCGsg4aosa8KOF7TzsqjSqcBZKS9mjnQZnlMeNeZSRHjjgEmjpdJQjYWK0zEKae8tsVdwa4ss)SKmlj4j(BwVy4hBaIeLZ2tIUbCOtDrcajbLSHX74gs0PzquXCTOGKzbqqsWTh1UbkzGd4ibWtI(T3MjjgIxsaW3GOFZhh7tHbqsWwU8BGysCvvdqKSqsIGymjVbr)IjbwgGcuYuYahWrIoRcU(YGKOB34LLjrNTylqI1lsIysEWFbsIVK0VRkw)aiaf5gVSmGhpX2aIz7)rHbciD7gVSmGVzIrjGIbd9BSbWPVXWOf5gVSCyr1sjtj72DGfoOESfgh5lATNc8yWmwDUzXuYahj6QNjbPFJhzysgmjyEjzHKKejkNTNKcscE9LeyrYhZKS3uT5fJcs0JeL9CrY2ZK8MdVKalMKbtcSi5JzuqsRKmps2EMemBHfijdMeVajPLKmpsIGBpj(XuYUDhyHdQhBHXr(cq0aes)gpYWOO8ygnyL)yoV3uT5ffiDZNrljkz3UdSWb1JTW4iFbiAacPFJhzyuuEmJgSYFmN3BQ28IcOkAoiikq6MpJMEOyEOT3uT5nOx4J9idRyVPAZBqVGfcnGqLva8F(oWIs2T7alCq9ylmoYxaIgGq634rggfLhZObR8hZ59MQnVOaQIMdcIcKU5ZO1kkMhA7nvBEdTg(ypYWk2BQ28gAnyHqdiuzfa)NVdSOKD7oWchup2cJJ8fGObOyiSApv(bVykzGJKw8yRJxsALea3Z3Es8cKeNKM1p8)qWKalsA0fjkNTNe9ni6xs0)otIxGKOBOo1fjWJKM1V3CmjWTNpLdMPKD7oWchup2cJJ8fGObiLNV9OWmfNTGOPxsOyEO1HTMrfZbZV8lxmQ20u2AgvmhMkJHg)stzRzuXCyQCeC7ttzRzuXCWlGYfJQTlLSB3bw4G6XwyCKVaenaP88ThfZdToS1mQyoy(LF5Ir1MMYwZOI5Wuzm04xAkBnJkMdtLJGBFAkBnJkMdEbuUyuTDvOEmYGEbLNV9ksq9yKHwdkpF7PKD7oWchup2cJJ8fGObi863BogfZdTeUFXp4HGdrUXllNHVSBm5TFke400eSqKC51gQbr)MFoNMMawLnM86hcEXb863Zng00lnnH1nCTHY3)X4CKB8YYbU8iddMM2HTMrfZbm04xUyuTPPS1mQyomv28l)stzRzuXCyQCeC7ttzRzuXCWlGYfJQTlLSB3bw4G6XwyCKVaenaHx)W)dbJI5H29l(bpeCiYnEz5m8LDJjV9tHaRWcrYLxBOge9B(5ScSkBm51pe8Id41VNBmOPhLmLmWbCKa8OIT)LbjHrYhqKStmtY2ZK42fEKmysCK(y8idhOKD7oWcJggA8lhXEmLmWrsdVys0je4jbwK0sasIYz7H)LeWBEljEbsIYz7jPz9Zapqs8cKKwbijWTNpLdMPKD7oWcJgs)gpYWOO8ygTbNDiJcKU5ZOHvzJjV(HGxCaV(9CJjr9u0jH1nCTb86NbEGbU8iddMMUUHRnGx2y8ldEZBdC5rggSBAkwLnM86hcEXb863ZnMeBLsg4iPHxmjwd7izsu2ZfjnRFV5ysSErs)SK0kajz9dbVysu2p2EsgmjhByKETK8GhjBptcWBnJkMjzHKeXKOE8JVJbjXlqsu2p2EsEJXWhjlKeRJxkz3UdSWaenaH0VXJmmkkpMrBWzRHDKmkq6MpJgwLnM86hcEXb863Boor9OKbos0rmtIU5dZx7PqqIYz7jbL6eq6qzjbEK4VLpsqjSqcBZKmfjOuNashklLSB3bwyaIgGI4dZx7PqGI5HwNeSqKC51gQbr)MFoNMMGfcnGqLvWclKW2CE75mwDUzXHVAxfr)3ly98u2WXX(u4e1dDuYahjTiCjr5S9K4KGsDciDOSKS9(sYGlaCjXjPf)gSFKOEqljWJeL9CrY2ZK8ge9ljdMepc(xswijCbsj72DGfgGObiv4oWcfZdTO)7fSEEkB44yFkCI6HU00iigR4ni638XX(uyG1k6OKbosqPBSFJVmMeL982ZhjF8uiibLWcjSntsbvsIYXyiXngOssac(jzHKG3XyiX64LKTNjb7XmjEm8xljWhjOewiHTzaIsDciDOSKyD8IPKD7oWcdq0aes)gpYWOO8ygnlSqcBZzqgduzrbs38z0S8y60zQLpvOXxgm)ge9B(4yFkmGxp0b4TqObeQScwppLnCCSpfUlQvpuFsDrZYJPtNPw(uHgFzW8Bq0V5JJ9PWaE9qhGxVwtcWBHqdiuzfSWcjSnN3EoJvNBwC44yFkCxuREO(K6QiHZhWmJKRn4GG4aJQbV40uleAaHkRG1Ztzdhh7tHtCQLpvOXxgm)ge9B(4yFkCAQfcnGqLvWclKW2CE75mwDUzXHJJ9PWjo1YNk04ldMFdI(nFCSpfgWRxsPPjyHi5YRnudI(n)Con1T7aRGfwiHT582ZzS6CZIdGd2JmmiLmWrIoIzqswijGSXbIKTNj5JDemjWhjOuNashkljk75IKpEkeKac)rgMeyrYhZK4fijQhJKRLKp2rWKOSNls8IeheKegjxljdMepc(xswijGdtj72DGfgGObiK(nEKHrr5XmAwWSfwGZoWcfiDZNrRZ6hcEd7eZ5fMbhor9qxA65dyMrY1gCqqCyQerxsDv0PtcmG5pQQmyGJvb6y3KHhy5LLttTqObeQScCSkqh7Mm8alVSC44yFkmW0dWMKIeSqObeQScCSkqh7Mm8alVSC4yheOUk60bPFJhz4aSYFmN3BQ28IMEPPi9B8idhGv(J58Et1Mx0AzxfD2BQ28g0lCSdcu2cHgqOYknDVPAZBqVGfcnGqLv44yFkCItT8Pcn(YG53GOFZhh7tHb86Lu30uK(nEKHdWk)XCEVPAZlATQOZEt1M3qRHJDqGYwi0acvwPP7nvBEdTgSqObeQSchh7tHtCQLpvOXxgm)ge9B(4yFkmGxVK6MMI0VXJmCaw5pMZ7nvBErlPUPPwisU8AdTb6gV6sjdCKOJyMeGpwfOJDdjaooWYlltsRjHzlMKi(bpMeNeuQtaPdLLKpMduYUDhyHbiAa6J58SCmkkpMrJJvb6y3KHhy5LLrX8qZcHgqOYky98u2WXX(uyG1AskSqObeQScwyHe2MZBpNXQZnloCCSpfgyTMuAAeeJv8ge9B(4yFkmWAjQJsg4irhXmjnWVXW7uiir)6hbejawmBXKeXp4XK4KGsDciDOSK8XCGs2T7almardqFmNNLJrr5XmAy43y4DNcr((raHI5HMfcnGqLvW65PSHJJ9PWadWQibK(nEKHdwyHe2MZGmgOYMMAHqdiuzfSWcjSnN3EoJvNBwC44yFkmWaSkq634rgoyHfsyBodYyGkBAAeeJv8ge9B(4yFkmWAfDuYUDhyHbiAa6J58SCmkkpMrBkS9(Rhz4mG571(JZGmYXYOyEOf9FVG1Ztzdhh7tHtup0rjdCKOR(btYGjXj58TNpsyJhbpFzsu6arYcjj2BZK4gdjWIKpMjbV(sYEt1MxmjlKKiMeZumijFvsuoBpjOuNashkljEbsckHfsyBMeVaj5Jzs2EMKwlqsWg4scSiXcsY8ijcU9KS3uT5ftIFmjWIKpMjbV(sYEt1MxmLSB3bwyaIgG2BQ28QhkMhAi9B8idhGv(J58Et1Mx0Avrc7nvBEdTgo2bbkBHqdiuzLM2bPFJhz4aSYFmN3BQ28IMEPPi9B8idhGv(J58Et1Mx0AzxfDI(VxW65PSHVAAQfcnGqLvW65PSHJJ9PWaS1e3BQ28g0lyHqdiuzfa)NVdSu0jblejxETHAq0V5NZPPjG0VXJmCWclKW2CgKXav2UksWcrYLxBOnq34vAQfIKlV2qni638Zzfi9B8idhSWcjSnNbzmqLvHfcnGqLvWclKW2CE75mwDUzXHVQIeSqObeQScwppLn8vv0Pt0)9cS1mQyoB(LFHJJ9PWjQxsPPr)3lWwZOI5mgA8lCCSpfor9sQRIeUFXp4HGdrUXllNHVSBm5TFke400or)3le5gVSCg(YUXK3(PqGZLV)Jd41TTrdDPPr)3le5gVSCg(YUXK3(PqGZ(z9Id41TTrdDD7MMg9FVq7PapgmZXQqL8fZ1M5Iped6ZHVA300iigR4ni638XX(uyG1AsPPi9B8idhGv(J58Et1Mx0sIs2T7almardq7nvBEBffZdnK(nEKHdWk)XCEVPAZBcO1QIe2BQ28g0lCSdcu2cHgqOYknfPFJhz4aSYFmN3BQ28IwRk6e9FVG1ZtzdF10uleAaHkRG1Ztzdhh7tHbyRjU3uT5n0AWcHgqOYka(pFhyPOtcwisU8Ad1GOFZpNtttaPFJhz4GfwiHT5miJbQSDvKGfIKlV2qBGUXR0ulejxETHAq0V5NZkq634rgoyHfsyBodYyGkRcleAaHkRGfwiHT582ZzS6CZIdFvfjyHqdiuzfSEEkB4RQOtNO)7fyRzuXC28l)chh7tHtuVKstJ(VxGTMrfZzm04x44yFkCI6LuxfjC)IFWdbhICJxwodFz3yYB)uiWPPDI(VxiYnEz5m8LDJjV9tHaNlF)hhWRBBJg6stJ(VxiYnEz5m8LDJjV9tHaN9Z6fhWRBBJg662TBAA0)9cTNc8yWmhRcvYxmxBMl(qmOph(QPPrqmwXBq0V5JJ9PWaR1Kstr634rgoaR8hZ59MQnVOLeLmWrIoIzmjUXqcC75JeyrYhZKmlhJjbwKybPKD7oWcdq0a0hZ5z5ymkMhAr)3ly98u2Wxnn1crYLxBOge9B(5ScK(nEKHdwyHe2MZGmgOYQWcHgqOYkyHfsyBoV9CgRo3S4Wxvrcwi0acvwbRNNYg(Qk60j6)Eb2AgvmNn)YVWXX(u4e1lP00O)7fyRzuXCgdn(foo2NcNOEj1vrc3V4h8qWHi34LLZWx2nM82pfcCA69l(bpeCiYnEz5m8LDJjV9tHaROt0)9crUXllNHVSBm5TFke4C57)4aEDB7eBzAA0)9crUXllNHVSBm5TFke4SFwV4aEDB7eBz3UPPr)3l0EkWJbZCSkujFXCTzU4dXG(C4RMMgbXyfVbr)Mpo2NcdSwtIsg4ir)X2bKjXT7alsmdEjjYXmijWIe8SFFhybidJyWuYUDhyHbiAa6(v2T7aRSzWlkkpMrZHmkW7n2fn9qX8qdPFJhz4WGZoKPKD7oWcdq0a09RSB3bwzZGxuuEmJwe0xuG3BSlA6HI5H29l(bpeCiYnEz5m8LDJjV9tHahyaZFuvzqkz3UdSWaenaD)k72DGv2m4ffLhZOHxkzkzGJeu6g734lJjrzpV98rY2ZKO)o2JT(A75JKO)7rIYXyi55gdjW3JeLZ2pfjBptsXOAjX64Ls2T7alCWHmAi9B8idJIYJz0ap2JZkhJj)CJjdFpuG0nFgTor)3lStmReEvg8ypoAkq(chh7tHbgclyi2rfatkOxAA0)9c7eZkHxLbp2JJMcKVWXX(uyG52DGvaV(9MJdmQy7F58oXmatkONIoS1mQyomv28l)stzRzuXCadn(LlgvBAkBnJkMdEbuUyuTD7Qi6)EHDIzLWRYGh7XrtbYx4RQ4(f)GhcoStmReEvg8ypoAkq(cmG5pQQmiLmWrckDJ9B8LXKOSN3E(iPz9d)pemjdMeLWB7jX64DkeKarYhjnRFV5ysMIKw4x(rcWBnJkMPKD7oWchCidq0aes)gpYWOO8ygTbrbpoJx)W)dbJcKU5ZOLaBnJkMdtLXqJFk6GvzJjV(HGxCaV(9MJteDkw3W1gWWVjdF5TNZp4X4nWLhzyW0uSkBm51pe8Id41V3CCIOUUuYahj6iMjbLWcjSntIYEUiXxsmmgtY27fjOljs0jUfjXlqsmtXK8vjr5S9KGsDciDOSuYUDhyHdoKbiAaYclKW2CE75mwDUzXOyEOLa49hWqbZwqSIoDq634rgoyHfsyBodYyGkRIeSqObeQScwppLnCSdcuAA0)9cwppLn8v7QOJJ3ZnzvOs(ag6sknfPFJhz4WGOGhNXRF4)HG7QOt0)9cS1mQyoB(LFHJJ9PWjcyttJ(VxGTMrfZzm04x44yFkCIa2Uk6KW9l(bpeCiYnEz5m8LDJjV9tHaNMg9FVqKB8YYz4l7gtE7Ncbox((poGx32oXwMMg9FVqKB8YYz4l7gtE7Ncbo7N1loGx32oXw2nn9ni638XX(uyGPxsksWcHgqOYky98u2WXoiqDPKbos0rmtI()4c9bIeLZ2tck1jG0HYsj72DGfo4qgGObOZrYf8JZVJl0hiump0I(VxW65PSHJJ9PWjQh6OKbos0rmtsZVEZXKmfjQEbYXJLeyrIxaT9tHGKT3xsmdsgtIEOhMTys8cKedJXKOC2EsIHhtY6hcEXK4fij(sY2ZKWfijWhjojnqJFKa8wZOIzs8Le9qpsWSftc8iXWymjhh7tnfcsCmjlKKcUK07iNcbjlKKJFhJ7jb8FtHGKw4x(rcWBnJkMPKD7oWchCidq0ae(xV5yuybYA486hcEXOPhkMhADo(DmU3JmCAA0)9cS1mQyoJHg)chh7tHbwlvWwZOI5Wuzm04NIJJ9PWatp0tX6gU2ag(nz4lV9C(bpgVbU8idd2vX6hcEd7eZ5fMbhor9qpapwLnM86hcEXa84yFkSIoS1mQyomv2lGstpo2NcdmewWqSJQUuYahjaazwLKVkjnRFp3yiXxsCJHKDIzmj)YWymjF8uiiPfaY6NJjXlqsMLKbtIhb)ljlKe1dAjbEKy4LKTNjbRY2XnK42DGfjMPysIydujj9EbAys0Fh7XrtbYhjWIKwjz9dbVykz3UdSWbhYaenaHx)EUXGI5HwNO)7fWRFp3ych)og37rgwrhSkBm51pe8Id41VNBmaRLPPjC)IFWdbh2jMvcVkdEShhnfiFbgW8hvvgSBA66gU2ag(nz4lV9C(bpgVbU8iddQi6)Eb2AgvmNXqJFHJJ9PWaRLkyRzuXCyQmgA8tr0)9c41VNBmHJJ9PWad1PaRYgtE9dbV4aE975gtIOHEDv0jH7x8dEi4GbiRFoo)mmVtHiJWmXQyoWaM)OQYGPP7eZOwul6HUeJ(VxaV(9CJjCCSpfgGT2vX6hcEd7eZ5fMbhor0rjdCKa4oBpj6VJ94OPa5JKpMjPz975gdjlKK2mRsYxLKTNjj6)EKebejUbdj5JNcbjnRFp3yibwKGosWSfwGysGhjggJj54yFQPqqj72DGfo4qgGObi863Zngump0UFXp4HGd7eZkHxLbp2JJMcKVady(JQkdQaRYgtE9dbV4aE975gtIO1sfDsi6)EHDIzLWRYGh7XrtbYx4RQi6)Eb863ZnMWXVJX9EKHtt7G0VXJmCa8ypoRCmM8ZnMm89u0j6)Eb863ZnMWXX(uyG1Y0uSkBm51pe8Id41VNBmj2QI1nCTb8YgJFzWBEBGlpYWGkI(VxaV(9CJjCCSpfgyORB3UuYahjO0n2VXxgtIYEE75JeNKM1p8)qWK8XmjkhJHeR)XmjnRFp3yizHK8CJHe47Hcs8cKKpMjPz9d)pemjlKK2mRsI(7ypoAkq(ibVUTnjFvkz3UdSWbhYaenaH0VXJmmkkpMrdV(9CJjRewB(5gtg(EOaPB(mAoEp3KvHk5lruFsa(o6LeQj6)EHDIzLWRYGh7XrtbYxaVUTDxaFNO)7fWRFp3ychh7tHrnTe1IvzJj374L7c47ac3W7FaLHVmB(fhoo2NcJAqxxfr)3lGx)EUXe(QuYahj6iMjPz9d)pemjkNTNe93XEC0uG8rYcjPnZQK8vjz7zsI(VhjkNTh(xsmq8uiiPz975gdjF1DIzs8cKKpMjPz9d)pemjWIe0dGKOBOo1fj41TTXK8RDmKGEKS(HGxmLSB3bw4GdzaIgGWRF4)HGrX8qdPFJhz4a4XECw5ym5NBmz47PaPFJhz4aE975gtwjS28ZnMm89uKas)gpYWHbrbpoJx)W)dbNM2j6)EHi34LLZWx2nM82pfcCU89FCaVUTDITmnn6)EHi34LLZWx2nM82pfcC2pRxCaVUTDITSRcSkBm51pe8Id41VNBmad9uG0VXJmCaV(9CJjRewB(5gtg(EuYahj6iMjbR0VysWqs2EFjbi4Nee8ssSJks(Q7eZKebejF8uiizwsCmjgFzsCmjQqmEImmjWIedJXKS9ErsljbVUTnMe4rcaaF8sIYEUiPLaKe8622ysyuPohtj72DGfo4qgGObih0v3bjNXk9lgfwGSgoV(HGxmA6HI5Hwc7yBpfcfj42DGvWbD1DqYzSs)IZGESJGdtLFMbr)MMcc3Gd6Q7GKZyL(fNb9yhbhWRBBdSwQaeUbh0v3bjNXk9lod6XocoCCSpfgyTKsg4ir)IFhJ7jr)gcR3CmjZJeuQtaPdLLKbtYXoiqOGKTNpMe)ysmmgtY27fjOJK1pe8IjzksAHF5hjaV1mQyMeLZ2tsdC1)OGedJXKS9ErIEjrcC75t5GzsMIeVaIeG3Agvmtc8i5RsYcjbDKS(HGxmjr8dEmjojTWV8JeG3Agvmhir)blaCj543X4Esa)3uiiba4uGhdscWhRcvYxmxlj)YWymjtrsd04hjaV1mQyMs2T7alCWHmardqXqy9MJrHfiRHZRFi4fJMEOyEOD87yCVhzyfRFi4nStmNxygC4e70rp0dGDWQSXKx)qWloGx)EZXOMwrnr)3lWwZOI5S5x(f(QD7cWJJ9PWDrTD0dGRB4AdRYPYXqyHdC5rggSRIowi0acvwbRNNYgo2bbsrcG3FadfmBbXk6G0VXJmCWclKW2CgKXav20uleAaHkRGfwiHT582ZzS6CZIdh7GaLMMGfIKlV2qni638Z5UPPyv2yYRFi4fhWRFV5yG1PdGfW3j6)Eb2AgvmNn)YVWxf10A3UOMo6bW1nCTHv5u5yiSWbU8idd2TRIeyRzuXCadn(LlgvBAAh2AgvmhMkJHg)st7WwZOI5Wu5i42NMYwZOI5WuzZV8RRIew3W1gWWVjdF5TNZp4X4nWLhzyW00O)7fuVjgEGJBY(z9ASz1Vb7xaPB(CIO1k6sQRIoyv2yYRFi4fhWRFV5yGPxsOMo6bW1nCTHv5u5yiSWbU8idd2TRchVNBYQqL8Li6scWh9FVaE975gt44yFkmQbW2vrNeI(VxO9uGhdM5yvOs(I5AZCXhIb95WxnnLTMrfZHPYyOXV00eSqKC51gAd0nE1Lsg4irhXmj6FO(ibwKybjr5S9W)sI1vvNcbLSB3bw4GdzaIgGEWZYz4lx((pgfZdnxnB7zBBkzGJeDeZKGsDciDOSKalsSGK8ldJXK4fijMPysMLKVkjkNTNeuclKW2mLSB3bw4GdzaIgGSSHX74MSBgevmxlkMhAjaE)bmuWSfeRaPFJhz4GfmBHf4SdSu0j6)Eb863ZnMWxnn1X75MSkujFjIUK6QOtcr)3lGHg8owo8vvKq0)9cwppLn8vv0jblejxETHAq0V5NZPPwi0acvwblSqcBZ5TNZy15Mfh(QkC8EUjRcvYhWqxsDvS(HG3WoXCEHzWHtup0bqlSa)Zgup2oyo7MbrfZ1g2jMZiDZNttJGySIPw(uHgFzW8Bq0V5JJ9PWaR1KaOfwG)zdQhBhmNDZGOI5Ad7eZzKU5ZDPKD7oWchCidq0a0uw)kFhyHI5HwcG3FadfmBbXkq634rgoybZwybo7alfDI(VxaV(9CJj8vttD8EUjRcvYxIOlPUk6Kq0)9cyObVJLdFvfje9FVG1ZtzdFvfDsWcrYLxBOge9B(5CAQfcnGqLvWclKW2CE75mwDUzXHVQchVNBYQqL8bm0LuxfRFi4nStmNxygC4eBnjaAHf4F2G6X2bZz3miQyU2WoXCgPB(CAAeeJvm1YNk04ldMFdI(nFCSpfgyTmjaAHf4F2G6X2bZz3miQyU2WoXCgPB(CxkzGJeDeZKa8XQqL8rIUHfijWIelijkNTNKM1VNBmK8vjXlqsWosMKh8iPf)gSFK4fijOuNashklLSB3bw4GdzaIgG4yvOs(YrWcefZdTiigRyQLpvOXxgm)ge9B(4yFkmW0dDPPDI(Vxq9My4boUj7N1RXMv)gSFbKU5ZaRv0LuAA0)9cQ3edpWXnz)SEn2S63G9lG0nFor0AfDj1vr0)9c41VNBmHVQIowi0acvwbRNNYgoo2NcNi6sknf8(dyOGzliUlLmWrI(f)og3tYZ4htcSi5RsYcjPLKS(HGxmjkNTh(xsqPobKouwsI4PqqIhb)ljlKegvQZXK4fijfCjbIKpRRQofckz3UdSWbhYaenaHx2y8l)m(XOWcK1W51pe8Irtpump0o(DmU3JmSIDI58cZGdNOEOtbwLnM86hcEXb863BogyONcxnB7zBBfDI(VxW65PSHJJ9PWjQxsPPje9FVG1ZtzdF1UuYahj6iMjr)dbEsMhjtHhqMeVib4TMrfZK4fijMPysMLKVkjkNTNeNKw8BW(rI6bTK4fij6e0v3bjtsJs)IPKD7oWchCidq0a07FaLHVmB(fJI5HgBnJkMdtL9cifUA22Z22kI(Vxq9My4boUj7N1RXMv)gSFbKU5ZaRv0LKIoGWn4GU6oi5mwPFXzqp2rWHDSTNcrAAcwisU8AdfBpObEGPPyv2yYRFi4fNyRDPKbos0rmtItsZ63ZngsaCu82tI6bTK8ldJXK0S(9CJHKbtIBo2bbIKVkjWJeGGFs8JjXJG)LKfscejFwxLeDIBrkz3UdSWbhYaenaHx)EUXGI5Hw0)9cWI3ECwLplRUdScFvfDI(VxaV(9CJjC87yCVhz40uhVNBYQqL8LiamPUuYahj6VFSkj6e3IKeXp4XKGsyHe2Mjr5S9K0S(9CJHeVajz75IKM1p8)qWuYUDhyHdoKbiAacV(9CJbfZdnlejxETHAq0V5NZk6G0VXJmCWclKW2CgKXav20uleAaHkRG1ZtzdF100O)7fSEEkB4R2vHfcnGqLvWclKW2CE75mwDUzXHJJ9PWadHfme7Oc1y5X0XX75MSkujFOw0Luxfr)3lGx)EUXeoo2Ncdm0trcG3FadfmBbXuYUDhyHdoKbiAacV(H)hcgfZdnlejxETHAq0V5NZk6G0VXJmCWclKW2CgKXav20uleAaHkRG1ZtzdF100O)7fSEEkB4R2vHfcnGqLvWclKW2CE75mwDUzXHJJ9PWadWQi6)Eb863ZnMWxvbBnJkMdtL9cifjG0VXJmCyquWJZ41p8)qWksa8(dyOGzliMsg4irhXmjnRF4)HGjr5S9K4fjaokE7jr9GwsGhjZJeGGFaeKeis(SUkj6e3IKOC2Esac(pskgvljwhVbs0Pbdjb8hRIjrN4wKeFjz7zs4cKe4JKTNjbaqU2EGosI(VhjZJKM1VNBmKOe(nGfaUK8CJHe47rcSib9ibEKyymMK1pe8IPKD7oWchCidq0aeE9d)pemkMhAr)3lalE7XzRH9lJCWdScF100ojGx)EZXbxnB7zBBfjG0VXJmCyquWJZ41p8)qWPPDI(VxW65PSHJJ9PWadDkI(VxW65PSHVAAANO)7fohjxWpo)oUqFGchh7tHbgclyi2rfQXYJPJJ3ZnzvOs(qTTmPUkI(Vx4CKCb)4874c9bk8v72vbs)gpYWb863ZnMSsyT5NBmz47PaRYgtE9dbV4aE975gdWAzxfDs4(f)GhcoStmReEvg8ypoAkq(cmG5pQQmyAkwLnM86hcEXb863ZngG1YUuYahj6iMjr)gclmjtrsd04hjaV1mQyMeVajb7izs0)FJHe9BiSi5bpsqPobKouwkz3UdSWbhYaenavSYCmewOyEO1j6)Eb2AgvmNXqJFHJJ9PWjYOIT)LZ7eZPPDS9(HGXO1QIJT9(HGZ7eZadDDttT9(HGXO1YUkC1STNTTPKD7oWchCidq0auVBE5yiSqX8qRt0)9cS1mQyoJHg)chh7tHtKrfB)lN3jMtt7y79dbJrRvfhB79dbN3jMbg66MMA79dbJrRLDv4QzBpBBtj72DGfo4qgGObO33yYXqyHI5HwNO)7fyRzuXCgdn(foo2NcNiJk2(xoVtmROJfcnGqLvW65PSHJJ9PWjIUKstTqObeQScwyHe2MZBpNXQZnloCCSpfor0Lu300o2E)qWy0AvXX2E)qW5DIzGHUUPP2E)qWy0AzxfUA22Z22uYahj6iMjbWfc8KalsqP(Js2T7alCWHmardqk97g4LHVmB(ftjdCKGs3y)gFzmjk75TNpswijFmtsZ63BoMKPiPbA8JeL9JTNKbtIVKGosw)qWlgG6rYdEKWi5disAnjuljXoE5disGhjOhjnRF4)HGjb4JvHk5lMRLe8622ykz3UdSWbhYaenaH0VXJmmkkpMrdV(9MJZtLXqJFOaPB(mAyv2yYRFi4fhWRFV54erpa(mq41j2XlFaLr6MpJA0lPKqTTMuxa(mq41j6)Eb86h(Fi4mhRcvYxmxBgdn(fWRBBJArVUuYahj6iMjbW98TNKPiPbA8JeG3Agvmtc8izEKuqsAw)EZXKOCmgsEZsYulKeuQtaPdLLeVakgEmLSB3bw4GdzaIgGuE(2JI5Hwh2Agvmhm)YVCXOAttzRzuXCWlGYfJQvbs)gpYWHbNTg2rYDv0z9dbVHDI58cZGdNi6LMYwZOI5G5x(LNk3AA6Bq0V5JJ9PWatVK6MMg9FVaBnJkMZyOXVWXX(uyG52DGvaV(9MJdmQy7F58oXSIO)7fyRzuXCgdn(f(QPPS1mQyomvgdn(PibK(nEKHd41V3CCEQmgA8lnn6)EbRNNYgoo2Ncdm3UdSc41V3CCGrfB)lN3jMvKas)gpYWHbNTg2rYkI(VxW65PSHJJ9PWaJrfB)lN3jMve9FVG1ZtzdF100O)7fohjxWpo)oUqFGcFvfyv2yY9oE5etkayv0bRYgtE9dbVyGHwltttyDdxBad)Mm8L3Eo)GhJ3axEKHb7MMMas)gpYWHbNTg2rYkI(VxW65PSHJJ9PWjYOIT)LZ7eZuYahj6iMjPz97nhtY8izksAHF5hjaV1mQygfKmfjnqJFKa8wZOIzsGfjOhajz9dbVysGhjlKe1dAjPbA8JeG3Agvmtj72DGfo4qgGObi863BoMsg4ir)7gZ2FFkz3UdSWbhYaenaD)k72DGv2m4ffLhZO9CJz7VpLmLmWrI()4c9bIeLZ2tck1jG0HYsj72DGfoeb9fTZrYf8JZVJl0hiump0I(VxW65PSHJJ9PWjQh6OKbosqzpBBJjzEKS9mj6gQtDrI9MLKO)7rYGjPGljFvsEWJeJV8rYhZuYUDhyHdrqFbiAacPFJhzyuuEmJM9MTG7xffiDZNrlHO)7fICJxwodFz3yYB)uiW5Y3)XHVQIeI(VxiYnEz5m8LDJjV9tHaN9Z6fh(QuYahj6iMjrNGU6oizsAu6xmjk75IeFjXWymjBVxKGEKOBOo1fj41TTXK4fijlKKJFhJ7jXjbyO1kj41TTjXXKy8LjXXKOcX4jYWKaps2jMjzwsWqsMLe)UbjJjbaGpEjXFlFK4K0sascEDBBsyuPohJPKD7oWchIG(cq0aKd6Q7GKZyL(fJclqwdNx)qWlgn9qX8ql6)EHi34LLZWx2nM82pfcCU89FCaVUTnWqpfr)3le5gVSCg(YUXK3(PqGZ(z9Id41TTbg6POtcGWn4GU6oi5mwPFXzqp2rWHDSTNcHIeC7oWk4GU6oi5mwPFXzqp2rWHPYpZGOFv0jbq4gCqxDhKCgR0V4Cp7MWo22tHinfeUbh0v3bjNXk9lo3ZUjCCSpfoXw2nnfeUbh0v3bjNXk9lod6XocoGx32gyTubiCdoORUdsoJv6xCg0JDeC44yFkmWqNcq4gCqxDhKCgR0V4mOh7i4Wo22tHOlLmWrIoIzsqjSqcBZKOC2EsqPobKouwsu2ZfjQqmEImmjEbscC75t5GzsuoBpjoj6gQtDrs0)9irzpxKaYyGk7uiOKD7oWchIG(cq0aKfwiHT582ZzS6CZIrX8qRds)gpYWblSqcBZzqgduzvKGfcnGqLvW65PSHJDqGstJ(VxW65PSHVAxfDI(VxiYnEz5m8LDJjV9tHaNlF)hhWRBBJg6stJ(VxiYnEz5m8LDJjV9tHaN9Z6fhWRBBJg66MMgbXyfVbr)Mpo2Ncdm9sIsg4ir)dbEsCmjBptYBo8scclijtrY2ZK4KOBOo1fjkNceQKe4rIYz7jz7zsaac0nErs0)9ibEKOC2EsCsq9aeZws0jORUdsMKgL(ftIxGKO0NLKh8ibL6eq6qzjzEKmljkH1ssetYxLehHpfjr8dEmjBptIfKKbtYBQb3ZGuYUDhyHdrqFbiAa69pGYWxMn)IrX8qRtNO)7fICJxwodFz3yYB)uiW5Y3)Xb8622jIEPPr)3le5gVSCg(YUXK3(PqGZ(z9Id41TTte96QOtcwisU8Adi5A7b6stti6)EbRNNYg(QDv0b8(dyOGzlion1cHgqOYky98u2WXX(u4erxsPPDSqKC51gQbr)MFoRWcHgqOYkyHfsyBoV9CgRo3S4WXX(u4erxsD72nnTdiCdoORUdsoJv6xCg0JDeC44yFkCIOEfwi0acvwbRNNYgoo2NcNOEjPWcrYLxBOy7bnWdSBA6ulFQqJVmy(ni638XX(uyGH6vKGfcnGqLvW65PSHJDqGst7yHi5YRn0gOB8sr0)9cTNc8yWmhRcvYxmxB4R2Lsg4ibLEzzdjnRFg4bsIYz7jXjPyLKOBOo1fjr)3JeVajbL6eq6qzjzWfaUK4rW)sYcjjIj5Jzqkz3UdSWHiOVaenaz9YYMC0)9qr5XmA41pd8arX8qRt0)9crUXllNHVSBm5TFke4C57)4WXX(u4erVa6stJ(VxiYnEz5m8LDJjV9tHaN9Z6fhoo2NcNi6fqxxfDSqObeQScwppLnCCSpforuxAAhleAaHkRahRcvYxocwGHJJ9PWjI6uKq0)9cTNc8yWmhRcvYxmxBMl(qmOph(QkSqKC51gAd0nE1TRchVNBYQqL8LiATmjkzGJe93pwLKM1p8)qWysuoBpjoj6gQtDrs0)9ij6VKuWLeL9CrIkeAMcbjp4rck1jG0HYsc8iba4uGhdssJ6CZIPKD7oWchIG(cq0aeE9d)pemkMhAjG0VXJmCWEZwW9RQOJfIKlV2qni638Z50uleAaHkRG1Ztzdhh7tHte1LMMas)gpYWbly2clWzhyPiblejxETH2aDJxPPDSqObeQScCSkujF5iybgoo2NcNiQtrcr)3l0EkWJbZCSkujFXCTzU4dXG(C4RQWcrYLxBOnq34v3Uk6KaiCdV)bug(YS5xCyhB7PqKMMGfcnGqLvW65PSHJDqGsttWcHgqOYkyHfsyBoV9CgRo3S4WXoiqDPKbos0F)yvsAw)W)dbJjjIFWJjbLWcjSntj72DGfoeb9fGObi86h(Fiyump06yHqdiuzfSWcjSnN3EoJvNBwC44yFkmWqNIeaV)agky2cIv0bPFJhz4GfwiHT5miJbQSPPwi0acvwbRNNYgoo2Ncdm01vbs)gpYWbly2clWzhy1vrcGWn8(hqz4lZMFXHDSTNcHclejxETHAq0V5NZksa8(dyOGzliwbBnJkMdtL9cikzGJe9hSaWLeq4sc4)McbjBptcxGKaFKOF5i5c(XKO)pUqFGqbjG)BkeK0EkWJbjHJvHk5lMRLe4rYuKS9mjghVKGWcsc8rIxKa8wZOIzkz3UdSWHiOVaenaH0VXJmmkkpMrdeU5Jbm)54yUwmkq6MpJwNO)7fohjxWpo)oUqFGchh7tHteDPPje9FVW5i5c(X53Xf6du4R2vrNO)7fApf4XGzowfQKVyU2mx8HyqFoCCSpfgyiSGHyhvDv0j6)Eb2AgvmNXqJFHJJ9PWjIWcgIDuLMg9FVaBnJkMZMF5x44yFkCIiSGHyhvDPKD7oWchIG(cq0ae(xV5yuybYA486hcEXOPhkMhAh)og37rgwX6hcEd7eZ5fMbhor9aSkC1STNTTvG0VXJmCaeU5Jbm)54yUwmLSB3bw4qe0xaIgGIHW6nhJclqwdNx)qWlgn9qX8q743X4EpYWkw)qWByNyoVWm4WjQxldOtHRMT9STTcK(nEKHdGWnFmG5phhZ1IPKD7oWchIG(cq0aeEzJXV8Z4hJclqwdNx)qWlgn9qX8q743X4EpYWkw)qWByNyoVWm4WjQhGfGhh7tHv4QzBpBBRaPFJhz4aiCZhdy(ZXXCTykzGJe9puFKalsSGKOC2E4FjX6QQtHGs2T7alCic6lardqp4z5m8LlF)hJI5HMRMT9STnLmWrcWhRcvYhj6gwGKOSNls8i4FjzHKW1YhjojfRKeDd1PUir5uGqLK4fijyhjtYdEKGsDciDOSuYUDhyHdrqFbiAaIJvHk5lhblqump06WwZOI5G5x(LlgvBAkBnJkMdyOXVCXOAttzRzuXCWlGYfJQnnn6)EHi34LLZWx2nM82pfcCU89FC44yFkCIOxaDPPr)3le5gVSCg(YUXK3(PqGZ(z9Idhh7tHte9cOln1X75MSkujFjcatsHfcnGqLvW65PSHJDqGuKa49hWqbZwqCxfDSqObeQScwppLnCCSpfoXwMuAQfcnGqLvW65PSHJDqG6MMgbXyftT8Pcn(YG53GOFZhh7tHbMEjrjdCKO)Hapj3GOFjjIFWJj5JNcbjOuNuYUDhyHdrqFbiAa69pGYWxMn)IrX8qZcHgqOYky98u2WXoiqkq634rgoybZwybo7alfDC8EUjRcvYxIaWKuKGfIKlV2qni638Z50ulejxETHAq0V5NZkC8EUjRcvYhWqVK6QOtcwisU8Ad1GOFZpNttTqObeQScwyHe2MZBpNXQZnloCSdcuxfjaE)bmuWSfeRiblejxETbKCT9aDPPwisU8Adi5A7b6ue9FVW5i5c(X53Xf6du44yFkmWaGkI(Vx4CKCb)4874c9bk8vPKbosqPobKouwsu2Zfj(scamjasIoXTijDGNbQKps2EVib9sIeDIBrsuoBpjOewiHT5UKOC2E4FjXaXtHGKDIzsMIeDBGqqZhVK4fijMPys(QKOC2EsqjSqcBZKmpsMLeLoMeqgduzzqkz3UdSWHiOVaenazzdJ3Xnz3miQyUwump0sa8(dyOGzliwbs)gpYWbly2clWzhyPOthhVNBYQqL8LiamjfDI(VxO9uGhdM5yvOs(I5AZCXhIb95WxnnnblejxETH2aDJxDttJ(VxiYaHGMpEdFvfr)3lezGqqZhVHJJ9PWaR1KayhlSa)Zgup2oyo7MbrfZ1g2jMZiDZN72nnncIXkMA5tfA8LbZVbr)Mpo2NcdSwtcGDSWc8pBq9y7G5SBgevmxByNyoJ0nFUBAQfIKlV2qni638Z5Uk6KGfIKlV2qni638Z500ooEp3KvHk5dyOxsPPGWn8(hqz4lZMFXHDSTNcrxfDq634rgoyHfsyBodYyGkBAQfcnGqLvWclKW2CE75mwDUzXHJDqG62Ls2T7alCic6lardqtz9R8DGfkMhAjaE)bmuWSfeRaPFJhz4GfmBHf4SdSu0PJJ3ZnzvOs(seaMKIor)3l0EkWJbZCSkujFXCTzU4dXG(C4RMMMGfIKlV2qBGUXRUPPr)3lezGqqZhVHVQIO)7fImqiO5J3WXX(uyG1YKayhlSa)Zgup2oyo7MbrfZ1g2jMZiDZN72nnncIXkMA5tfA8LbZVbr)Mpo2NcdSwMea7yHf4F2G6X2bZz3miQyU2WoXCgPB(C30ulejxETHAq0V5NZDv0jblejxETHAq0V5NZPPDC8EUjRcvYhWqVKstbHB49pGYWxMn)Id7yBpfIUk6G0VXJmCWclKW2CgKXav20uleAaHkRGfwiHT582ZzS6CZIdh7Ga1TlLmWrcWJ3j2xgtspujjXFBpj6e3IK4htccFkgKev(ibZwybsj72DGfoeb9fGObiK(nEKHrr5XmAowTf5RHTOaPB(mAS1mQyomv28l)qnOEuRB3bwb863BooWOIT)LZ7eZamb2AgvmhMkB(LFOMoawaUUHRnGHFtg(YBpNFWJXBGlpYWGOMw2f162DGvq55BFGrfB)lN3jMbysHwrTyv2yY9oEzkzGJe93pwLKM1p8)qWysu2ZfjBptYBq0VKmys8i4FjzHKWfiki5DCH(arYGjXJG)LKfscxGOGeGGFs8JjXxsaGjbqs0jUfjzks8IeG3AgvmJcsqPobKouwsmoEXK4fC75JeupaXSftc8ibi4NeLWVbKeis(SUkjXWJjz79IekvVKirN4wKeL9CrcqWpjkHFdybGljnRF4)HGjPGkPKD7oWchIG(cq0aeE9d)pemkMhADIGySIPw(uHgFzW8Bq0V5JJ9PWad9st7e9FVW5i5c(X53Xf6du44yFkmWqybdXoQqnwEmDC8EUjRcvYhQTLj1vr0)9cNJKl4hNFhxOpqHVA3UPPDC8EUjRcvYhar634rgo4y1wKVg2IAI(VxGTMrfZzm04x44yFkmabHB49pGYWxMn)Id7yBJZhh7tHAAnGUe1tVKstD8EUjRcvYhar634rgo4y1wKVg2IAI(VxGTMrfZzZV8lCCSpfgGGWn8(hqz4lZMFXHDSTX5JJ9PqnTgqxI6PxsDvWwZOI5WuzVasrNeI(VxW65PSHVAAAcRB4Ad41pd8adC5rggSRIoDsWcHgqOYky98u2Wxnn1crYLxBOnq34LIeSqObeQScCSkujF5iybg(QDttTqKC51gQbr)MFo3vrNeSqKC51gqY12d0LMMq0)9cwppLn8vttD8EUjRcvYxIaWK6MM2zDdxBaV(zGhyGlpYWGkI(VxW65PSHVQIor)3lGx)mWdmGx32gyTmn1X75MSkujFjcatQB300O)7fSEEkB4RQiHO)7fohjxWpo)oUqFGcFvfjSUHRnGx)mWdmWLhzyqkzGJeDeZKOFdHfMKPiPf(LFKa8wZOIzs8cKeSJKjbWjU5bq9)3yir)gclsEWJeuQtaPdLLs2T7alCic6lardqfRmhdHfkMhADI(VxGTMrfZzZV8lCCSpforgvS9VCENyonTJT3pemgTwvCST3peCENygyORBAQT3pemgTw2vHRMT9STnLSB3bw4qe0xaIgG6DZlhdHfkMhADI(VxGTMrfZzZV8lCCSpforgvS9VCENywrhleAaHkRG1Ztzdhh7tHteDjLMAHqdiuzfSWcjSnN3EoJvNBwC44yFkCIOlPUPPDS9(HGXO1QIJT9(HGZ7eZadDDttT9(HGXO1YUkC1STNTTPKD7oWchIG(cq0a07Bm5yiSqX8qRt0)9cS1mQyoB(LFHJJ9PWjYOIT)LZ7eZk6yHqdiuzfSEEkB44yFkCIOlP0uleAaHkRGfwiHT582ZzS6CZIdhh7tHteDj1nnTJT3pemgTwvCST3peCENygyORBAQT3pemgTw2vHRMT9STnLmWrcGle4jbwKybPKD7oWchIG(cq0aKs)UbEz4lZMFXuYahj6iMjPz97nhtYcjr9GwsAGg)ib4TMrfZKapsu2ZfjtrcSmarsl8l)ib4TMrfZK4fijFmtcGle4jr9GwmjZJKPiPf(LFKa8wZOIzkz3UdSWHiOVaenaHx)EZXOyEOXwZOI5WuzZV8lnLTMrfZbm04xUyuTPPS1mQyo4fq5Ir1MMg9FVGs)UbEz4lZMFXHVQIO)7fyRzuXC28l)cF100or)3ly98u2WXX(uyG52DGvq55BFGrfB)lN3jMve9FVG1ZtzdF1UuYUDhyHdrqFbiAas55BpLSB3bw4qe0xaIgGUFLD7oWkBg8IIYJz0EUXS93NsMsg4iPz9d)pemjp4rsmejhZ1sYVmmgtYhpfcs0nuN6Is2T7alC45gZ2FF0WRF4)HGrX8qlH7x8dEi4qKB8YYz4l7gtE7NcboWaM)OQYGuYahjO0XljBptciCjr5S9KS9mjXq8sYoXmjlKeheKKFTJHKTNjj2rfjG)Z3bwKmys6NnqsZVEZXKCCSpfMK4VzhvZWGKSqsI912tsmewV5ysa)NVdSOKD7oWchEUXS93hGObi8VEZXOWcK1W51pe8Irtpump0aHBigcR3CC44yFkCIhh7tHrnT2kQvpupLSB3bw4WZnMT)(aenafdH1BoMsMsg4irhXmjBptcaGCT9aDKOC2EsCsqPobKouws2EFjzWfaUK8oymjT43G9Js2T7alCaVODosUGFC(DCH(aHI5Hw0)9cwppLnCCSpfor9qhLmWrIoIzsAw)W)dbtYcjPnZQK8vjz7zs0Fh7XrtbYhjr)3JK5rYSKOe(nGKWOsDoMKi(bpMK3udUFkeKS9mjfJQLeRJxsGhjlKeWFSkjr8dEmjOewiHTzkz3UdSWb8cq0aeE9d)pemkMhA3V4h8qWHDIzLWRYGh7XrtbYxGbm)rvLbv0HTMrfZHPYEbKIe60j6)EHDIzLWRYGh7XrtbYx44yFkCIUDhyfuE(2hyuX2)Y5DIzaMuqpfDyRzuXCyQCeC7ttzRzuXCyQmgA8lnLTMrfZbZV8lxmQ2UPPr)3lStmReEvg8ypoAkq(chh7tHt0T7aRaE97nhhyuX2)Y5DIzaMuqpfDyRzuXCyQS5x(LMYwZOI5agA8lxmQ20u2Agvmh8cOCXOA72nnnHO)7f2jMvcVkdEShhnfiFHVA300or)3ly98u2WxnnfPFJhz4GfwiHT5miJbQSDvyHqdiuzfSWcjSnN3EoJvNBwC4yheifwisU8Ad1GOFZpN7QOtcwisU8AdTb6gVstTqObeQScCSkujF5iybgoo2NcNiQVRIor)3ly98u2WxnnnbleAaHkRG1Ztzdh7Ga1Lsg4irhXmj6e0v3bjtsJs)IjrzpxKS98XKmyskijUDhKmjyL(fJcsCmjgFzsCmjQqmEImmjWIeSs)Ijr5S9K0kjWJKhRKpsWRBBJjbEKalsCsAjajbR0VysWqs2EFjz7zskwjjyL(ftIF3GKXKaaWhVK4VLps2EFjbR0VysyuPohJPKD7oWchWlardqoORUdsoJv6xmkSaznCE9dbVy00dfZdTeaHBWbD1DqYzSs)IZGESJGd7yBpfcfj42DGvWbD1DqYzSs)IZGESJGdtLFMbr)QOtcGWn4GU6oi5mwPFX5E2nHDSTNcrAkiCdoORUdsoJv6xCUNDt44yFkCIORBAkiCdoORUdsoJv6xCg0JDeCaVUTnWAPcq4gCqxDhKCgR0V4mOh7i4WXX(uyG1sfGWn4GU6oi5mwPFXzqp2rWHDSTNcbLmWrIoIzmjOewiHTzsMhjOuNashkljdMKVkjWJeGGFs8JjbKXav2Pqqck1jG0HYsIYz7jbLWcjSntIxGKae8tIFmjrSbQKe0ljs0jUfPKD7oWchWlardqwyHe2MZBpNXQZnlgfZdTeaV)agky2cIv0Pds)gpYWblSqcBZzqgduzvKGfcnGqLvW65PSHJDqGuKW9l(bpeCq9My4boUj7N1RXMv)gSFPPr)3ly98u2WxTRchVNBYQqL8bm0ljfDI(VxGTMrfZzZV8lCCSpfor9sknn6)Eb2AgvmNXqJFHJJ9PWjQxsDttFdI(nFCSpfgy6LKIeSqObeQScwppLnCSdcuxkzGJeuclWzhyrYdEK4gdjGWftY27ljXEBgtc(FmjBpdej(XfaUKC87yCpdsIYEUir)YrYf8Jjr)FCH(arsVJjXWymjBVxKGosWSftYXX(utHGe4rY2ZK0gOB8IKO)7rYGjXJG)LKfsYZngsGVhjWJeVaIeG3AgvmtYGjXJG)LKfscJk15ykz3UdSWb8cq0aes)gpYWOO8ygnq4MpgW8NJJ5AXOaPB(mADI(Vx4CKCb)4874c9bkCCSpfor0LMMq0)9cNJKl4hNFhxOpqHVAxfDI(VxO9uGhdM5yvOs(I5AZCXhIb95WXX(uyGHWcgIDu1vrNO)7fyRzuXCgdn(foo2NcNiclyi2rvAA0)9cS1mQyoB(LFHJJ9PWjIWcgIDu1Ls2T7alCaVaenafdH1BogfwGSgoV(HGxmA6HI5H2XVJX9EKHvS(HG3WoXCEHzWHtuVwv0XvZ2E22wbs)gpYWbq4MpgW8NJJ5AXDPKD7oWchWlardq4F9MJrHfiRHZRFi4fJMEOyEOD87yCVhzyfRFi4nStmNxygC4e1RvfDC1STNTTvG0VXJmCaeU5Jbm)54yUwCxkz3UdSWb8cq0aeEzJXV8Z4hJclqwdNx)qWlgn9qX8q743X4EpYWkw)qWByNyoVWm4WjQhGvrhxnB7zBBfi9B8idhaHB(yaZFooMRf3Lsg4irhXmj6FO(ibwKybjr5S9W)sI1vvNcbLSB3bw4aEbiAa6bplNHVC57)yump0C1STNTTPKbos0rmtcaWPapgKKg15MftIYz7jXlGiXaleKWf8JONeJJ3PqqcWBnJkMjXlqs2diswijMPysMLKVkjkNTNKw8BW(rIxGKGsDciDOSuYUDhyHd4fGObiowfQKVCeSarX8qRtNO)7fyRzuXCgdn(foo2NcNOEjLMg9FVaBnJkMZMF5x44yFkCI6Luxfwi0acvwbRNNYgoo2NcNyltsrNO)7fuVjgEGJBY(z9ASz1Vb7xaPB(mWAf9sknnH7x8dEi4G6nXWdCCt2pRxJnR(ny)cmG5pQQmy3UPPr)3lOEtm8ah3K9Z61yZQFd2Vas385erRvuxsPPwi0acvwbRNNYgo2bbsHJ3ZnzvOs(seaMeLmWrIoIzsqPobKouwsuoBpjOewiHTzabaCkWJbjPrDUzXK4fijGWcaxsGi5t5nltsl(ny)ibEKOSNls0TbcbnF8sIs43ascJk15ysI4h8ysqPobKouwsyuPohJPKD7oWchWlardqw2W4DCt2ndIkMRffZdTeaV)agky2cIvG0VXJmCWcMTWcC2bwk6449CtwfQKVebGjPOt0)9cTNc8yWmhRcvYxmxBMl(qmOph(QPPjyHi5YRn0gOB8QBAQfIKlV2qni638Z500O)7fImqiO5J3Wxvr0)9crgie08XB44yFkmWAnja2Pdae1C)IFWdbhuVjgEGJBY(z9ASz1Vb7xGbm)rvLb7cWowyb(NnOESDWC2ndIkMRnStmNr6Mp3TBxfje9FVG1ZtzdFvfDsWcrYLxBOge9B(5CAQfcnGqLvWclKW2CE75mwDUzXHVAAAeeJvm1YNk04ldMFdI(nFCSpfgywi0acvwblSqcBZ5TNZy15Mfhoo2NcdqaBA6ulFQqJVmy(ni638XX(uyulQvpuFsaR1KayhlSa)Zgup2oyo7MbrfZ1g2jMZiDZN72Ls2T7alCaVaenanL1VY3bwOyEOLa49hWqbZwqScK(nEKHdwWSfwGZoWsrhhVNBYQqL8LiamjfDI(VxO9uGhdM5yvOs(I5AZCXhIb95WxnnnblejxETH2aDJxDttTqKC51gQbr)MFoNMg9FVqKbcbnF8g(QkI(VxiYaHGMpEdhh7tHbwltcGD6aarn3V4h8qWb1BIHh44MSFwVgBw9BW(fyaZFuvzWUaSJfwG)zdQhBhmNDZGOI5Ad7eZzKU5ZD72vrcr)3ly98u2WxvrNeSqKC51gQbr)MFoNMAHqdiuzfSWcjSnN3EoJvNBwC4RMMgbXyftT8Pcn(YG53GOFZhh7tHbMfcnGqLvWclKW2CE75mwDUzXHJJ9PWaeWMMo1YNk04ldMFdI(nFCSpfg1IA1d1NeWAzsaSJfwG)zdQhBhmNDZGOI5Ad7eZzKU5ZD7sjdCKaaOFJhzys(ygKeyrIhnMzhgtY27ljk9AjzHKeXKGDKmijp4rck1jG0HYscgsY27ljBpdej(X1sIshVmijaa8Xljr8dEmjBphtj72DGfoGxaIgGq634rggfLhZOHDKC(bVS1Ztzrbs38z0sWcHgqOYky98u2WXoiqPPjG0VXJmCWclKW2CgKXavwfwisU8Ad1GOFZpNttbV)agky2cIPKbos0rmJjr)dbEsMhjtrIxKa8wZOIzs8cKK9ggtYcjXmftYSK8vjr5S9K0IFd2puqck1jG0HYsIxGKOtqxDhKmjnk9lMs2T7alCaVaena9(hqz4lZMFXOyEOXwZOI5WuzVasHRMT9STTIO)7fuVjgEGJBY(z9ASz1Vb7xaPB(mWAf9ssrhq4gCqxDhKCgR0V4mOh7i4Wo22tHinnblejxETHITh0apWUkq634rgoGDKC(bVS1ZtzvKq0)9cNJKl4hNFhxOpqHVAAA0)9cNJKl4hNFhxOpqHJJ9PWadaQi6)EHZrYf8JZVJl0hOWxLsg4irhXmjaokE7jPz975gdjQh0IjzEK0S(9CJHKbxa4sYxLs2T7alCaVaenaHx)EUXGI5Hw0)9cWI3ECwLplRUdScFvfr)3lGx)EUXeo(DmU3JmmLSB3bw4aEbiAaY6LLn5O)7HIYJz0WRFg4bII5Hw0)9c41pd8adhh7tHbg6u0j6)Eb2AgvmNXqJFHJJ9PWjIU00O)7fyRzuXC28l)chh7tHteDDv449CtwfQKVebGjrjdCKO)(XQys0jUfjjIFWJjbLWcjSntYhpfcs2EMeuclKW2mjwybo7alswij2E22MK5rckHfsyBMKbtIB3VBmarIhb)ljlKKiMeRJxkz3UdSWb8cq0aeE9d)pemkMhAwisU8Ad1GOFZpNvG0VXJmCWclKW2CgKXavwfwi0acvwblSqcBZ5TNZy15Mfhoo2Ncdm0PibW7pGHcMTGykzGJeDeZK0S(9CJHeLZ2tsZYgJFKO)U5TK4fijfKKM1pd8arbjk75IKcssZ63ZngsgmjFvuqcqWpj(XKmfjTWV8JeG3Agvmtc8izHKOEqljT43G9JeL9CrIhbrYKaatIeDIBrsGhjoOQVdsMeSs)IjP3XKG6biMTysoo2NAkeKapsgmjtrYZmi6xkz3UdSWb8cq0aeE975gdkMhARB4Ad4Lng)YG382axEKHbvKW6gU2aE9ZapWaxEKHbve9FVaE975gt443X4EpYWk6e9FVaBnJkMZMF5x44yFkCIawfS1mQyomv28l)ue9FVG6nXWdCCt2pRxJnR(ny)ciDZNbwROlP00O)7fuVjgEGJBY(z9ASz1Vb7xaPB(CIO1k6ssHJ3ZnzvOs(seaMuAkiCdoORUdsoJv6xCg0JDeC44yFkCIO(0u3UdScoORUdsoJv6xCg0JDeCyQ8Zmi63UksWcHgqOYky98u2WXoiquYahj6iMjPz9d)pemjaokE7jr9GwmjEbsc4pwLeDIBrsu2ZfjOuNashkljWJKTNjbaqU2EGosI(VhjdMepc(xswijp3yib(EKapsac(bqqsSUkj6e3IuYUDhyHd4fGObi86h(Fiyump0I(Vxaw82JZwd7xg5Ghyf(QPPr)3l0EkWJbZCSkujFXCTzU4dXG(C4RMMg9FVG1ZtzdFvfDI(Vx4CKCb)4874c9bkCCSpfgyiSGHyhvOglpMooEp3KvHk5d12YK6Qi6)EHZrYf8JZVJl0hOWxnnnHO)7fohjxWpo)oUqFGcFvfjyHqdiuzfohjxWpo)oUqFGch7GaLMMGfIKlV2asU2EGUUPPoEp3KvHk5lrayskyRzuXCyQSxarjdCKORdiswijXEBMKTNjjIXljWhjnRFg4bsseqKGx32EkeKmljFvsam)X22aejtrIxarcWBnJkMjj6VK0IFd2psgCTK4rW)sYcjjIjr9Gwldsj72DGfoGxaIgGWRF4)HGrX8qBDdxBaV(zGhyGlpYWGks4(f)GhcoStmReEvg8ypoAkq(cmG5pQQmOIor)3lGx)mWdm8vttD8EUjRcvYxIaWK6Qi6)Eb86NbEGb8622aRLk6e9FVaBnJkMZyOXVWxnnn6)Eb2AgvmNn)YVWxTRIO)7fuVjgEGJBY(z9ASz1Vb7xaPB(mWAf1LKIowi0acvwbRNNYgoo2NcNOEjLMMas)gpYWblSqcBZzqgduzvyHi5YRnudI(n)CUlLmWrI(7hRssZ6h(FiysMIeNeuhaXSLKgOXpsaERzuXmkibewa4sIHxsMLe1dAjPf)gSFK0z79LKbtsVxGggKKiGiHNTNps2EMKM1VNBmKyMIjbEKS9mj6e3IjcatIeZumjp4rsZ6h(Fi4UOGeqybGljqK8P8MLjXlsaCu82tI6bTK4fijgEjz7zs8iisMeZumj9EbAysAw)mWdKs2T7alCaVaenaHx)W)dbJI5Hwc3V4h8qWHDIzLWRYGh7XrtbYxGbm)rvLbv0j6)Eb1BIHh44MSFwVgBw9BW(fq6MpdSwrDjLMg9FVG6nXWdCCt2pRxJnR(ny)ciDZNbwROljfRB4Ad4Lng)YG382axEKHb7Qi6)Eb2AgvmNXqJFHJJ9PWjI6uWwZOI5Wuzm04NIeI(Vxaw82JZQ8zz1DGv4RQiH1nCTb86NbEGbU8iddQWcHgqOYky98u2WXX(u4erDk6yHqdiuzfApf4XGzS6CZIdhh7tHte1LMMGfIKlV2qBGUXRUuYahj6iMjr)gclmjtrsl8l)ib4TMrfZK4fijyhjtcGtCZdG6)VXqI(newK8GhjOuNashkljEbscaWPapgKeGpwfQKVyUwkz3UdSWb8cq0auXkZXqyHI5HwNO)7fyRzuXC28l)chh7tHtKrfB)lN3jMtt7y79dbJrRvfhB79dbN3jMbg66MMA79dbJrRLDv4QzBpBBRaPFJhz4a2rY5h8YwppLLs2T7alCaVaena17Mxogclump06e9FVaBnJkMZMF5x44yFkCImQy7F58oXSIeSqKC51gAd0nELM2j6)EH2tbEmyMJvHk5lMRnZfFig0NdFvfwisU8AdTb6gV6MM2X27hcgJwRko227hcoVtmdm01nn127hcgJwlttJ(VxW65PSHVAxfUA22Z22kq634rgoGDKC(bVS1ZtzPKD7oWchWlardqVVXKJHWcfZdTor)3lWwZOI5S5x(foo2NcNiJk2(xoVtmRiblejxETH2aDJxPPDI(VxO9uGhdM5yvOs(I5AZCXhIb95WxvHfIKlV2qBGUXRUPPDS9(HGXO1QIJT9(HGZ7eZadDDttT9(HGXO1Y00O)7fSEEkB4R2vHRMT9STTcK(nEKHdyhjNFWlB98uwkzGJeDeZKa4cbEsGfjwqkz3UdSWb8cq0aKs)UbEz4lZMFXuYahj6iMjPz97nhtYcjr9GwsAGg)ib4TMrfZOGeuQtaPdLLKEhtIHXys2jMjz79IeNea3Z3EsyuX2)YKy43sc8ibwgGiPf(LFKa8wZOIzsgmjFvkz3UdSWb8cq0aeE97nhJI5HgBnJkMdtLn)YV0u2AgvmhWqJF5Ir1MMYwZOI5GxaLlgvBAA0)9ck97g4LHVmB(fh(QkI(VxGTMrfZzZV8l8vtt7e9FVG1Ztzdhh7tHbMB3bwbLNV9bgvS9VCENywr0)9cwppLn8v7sjdCKOJyMea3Z3EsGBpFkhmtIY(X2tYGjzksAGg)ib4TMrfZOGeuQtaPdLLe4rYcjr9GwsAHF5hjaV1mQyMs2T7alCaVaenaP88TNsg4ir)7gZ2FFkz3UdSWb8cq0a09RSB3bwzZGxuuEmJ2ZnMT)(Anyv2QPp9sQvTvB10a]] )


end