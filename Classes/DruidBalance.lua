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


    spec:RegisterPack( "Balance", 20210707.3, [[deLoAfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlaO2fL(feXWKqDmsKLbqEMqLMgfvCnifBdaLVbaACaiDoavSoaunpaL7rIAFcv9piQO0bfkSqHs9qistuOcDriv1gfQGpcrfvJeIkkojfvALsiVeIkYmHuLBcGq7uOKFcGOgkaKLcGGNQuMkfvDvHkARaisFfIkmwaG9sH)kPbtCyQwmj9ybtgOlJSzP8ziz0kvNwLvdGiEnGmBsDBjA3I(nOHlKJdOslxXZHA6Q66kz7q47uKXdr58sW6fkA(sL9JAdLmmVXgO)KrSauXasPIbGfdaTkf3Ibykban2(crKXwKhaYrrgBPxsgBX21EgiJTiVGg6GgM3yddxtGm22)pcdWrcsuDTNbcaJVYGf197lv7brsSDTNbcaVDLifjLG29VuJC22PjLvDTNbY(i7n2uxN(n30q1yd0FYiwaQyaPuXaWIbGwLIBXamLqJXMV(D4ySTDLi1yB)abP0q1ydKWbJTy7ApdelXXzDGCrfT0fybaIwwauXasjUiUiKU7jkcdW5IaWSedqqcKLnO2hwIn5LwUiamliD3tueilVpOOVEnwcoMWS8qwcfcAQ((GIESLlcaZcabQeIGazzLjfim2NcSGWNZv1eMLENLSOLLOHquXVp41GIybahplrdHWIFFWRbf13YfbGzjgiGhilrdfC8Fjkwqog)3z5ASCp6WS87elMgyIIf0pOVimz5IaWSaq0bIybPWebeiILFNyzl6M7XS4SOV)1elLWHyPPjKDQAILExJLcWfl7oyIUNL97z5EwWx5s)EsWfwxGft3VZsSbihdZZcGzbPKMW)5AwIH(qLLu(OLL7rhilyGUO(wUiamlaeDGiwkH4Nf01ou7FDOs)sm6ybhO0NdIzXJI0fy5HSOcXywAhQ9hZcm1fSCrCrXit47pbYsSDTNbILyaGqpwcEYIkXsdUsqw8NL9)JWaCKGevx7zGaW4RmyrD)(s1EqKeBx7zGaWBxjsrsjOD)l1iNTDAszvx7zGSpYEJn9HFSH5n2aPMV0VH5nILsgM3yZd)btJnmu7tvL8sJnkDvnbAeBJ3iwaYW8gBu6QAc0i2gBWiJnm9gBE4pyASHWNZv1KXgcxViJnCeP113hu0JT43NMR1SeplkXIcw6XIzS8UMY3IFF0Wb0sPRQjqw66y5DnLVf)Kw7tfCU2BP0v1eil9zPRJfCeP113hu0JT43NMR1SeplaYydKWH5I(dMgBB0Jzjgq0NfyYsCbmlMUFhUEwaNR9S4jilMUFNLT3hnCazXtqwaeGzb(70y6WKXgcFQPxsgBhU6qY4nIvCnmVXgLUQManITXgmYydtVXMh(dMgBi85CvnzSHW1lYydhrAD99bf9yl(9PDdXs8SOKXgiHdZf9hmn22OhZsqtocIft7uYY27t7gILGNSSFplacWS8(GIEmlM2VWolhMLH0ecpFwAWHLFNyb9d6lctS8qwujwIgQrZqGS4jilM2VWolTtRPHLhYsWXVXgcFQPxsgBhUg0KJGmEJyzogM3yJsxvtGgX2yZd)btJnvAW0a0LOm2ajCyUO)GPXwCIjwInnyAa6suSy6(DwqAmqI5MbwGdlE7PHfKcteqGiwUKfKgdKyUzWylm3tZ5gB9yXmwcqeu65BZd1(xBoXsxhlMXsac1GqtPnateqGO6VtvC0n3JTRiw6ZIcwuxTMn41ld2Hk9lXSeplkHgwuWI6Q1SJJGs4cxBdLXSGDOs)smlaJfZHffSyglbick98TiO83lmS01XsaIGspFlck)9cdlkyrD1A2GxVmyxrSOGf1vRzhhbLWfU2gkJzb7kIffS0Jf1vRzhhbLWfU2gkJzb7qL(LywaglkPelaywqdlaplZkPgCqrw8LTLUUxa)0CULsxvtGS01XI6Q1SbVEzWouPFjMfGXIskXsxhlkXcsybhrADD3XpXcWyrjlAqdl9nEJyHgdZBSrPRQjqJyBSfM7P5CJn1vRzdE9YGDOs)smlXZIsOHffS0JfZyzwj1GdkYIVST019c4NMZTu6QAcKLUowuxTMDCeucx4ABOmMfSdv6xIzbySOeaKffSOUAn74iOeUW12qzmlyxrS0NLUowuHymlkyPDO2)6qL(LywaglacngBGeomx0FW0ydabFwmD)ololingiXCZal)U)SC4eDplolaOLg7dlrdmWcCyX0oLS87elTd1(ZYHzXvHRNLhYcLGgBE4pyASfb)dMgVrSaygM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSfOtZspw6Xs7qT)1Hk9lXSaGzrj0WcaMLaeQbHMsBWRxgSdv6xIzPpliHfLaOfZsFwuMLaDAw6XspwAhQ9VouPFjMfamlkHgwaWSOeGkMfamlbiudcnL2amrabIQ)ovXr3Cp2ouPFjML(SGewucGwml9zrblMXY4hyLqq5BDqqSLq2HFmlDDSeGqni0uAdE9YGDOs)smlXZYLpnrqT)eyTDO2)6qL(Lyw66yjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSeplx(0eb1(tG12HA)Rdv6xIzbaZIsfZsxhlMXsaIGspFBEO2)AZjw66yXd)btBaMiGar1FNQ4OBUhBbpSRQjqJnqchMl6pyASHuxhwA)jmlM2PFNgww4lrXcsHjciqelj0elMoTMfxRHMyPaCXYdzb)NwZsWXpl)oXc2ljw8s4kFwGnwqkmrabIamsJbsm3mWsWXp2ydHp10ljJTamrabIQGeUqgmEJybanmVXgLUQManITXgmYydtVXMh(dMgBi85CvnzSHW1lYyRhlVpOO3(xjvFyf8iwINfLqdlDDSm(bwjeu(wheeBVKL4zbnfZsFwuWspw6XspwiG76IIiqlvgvyixxHdy6zGyrbl9yPhlbiudcnLwQmQWqUUchW0ZazhQ0VeZcWyrjawXS01XsaIGspFlck)9cdlkyjaHAqOP0sLrfgY1v4aMEgi7qL(LywaglkbWaGSayw6XIskXcWZYSsQbhuKfFzBPR7fWpnNBP0v1eil9zPplkyXmwcqOgeAkTuzuHHCDfoGPNbYoKdwGL(S0NLUow6XcbCxxuebAXWLwt)FjQ6SulWIcw6XIzSeGiO0Z3MhQ9V2CILUowcqOgeAkTy4sRP)VevDwQfQX1CqdaTyLSdv6xIzbySOKsMdl9zPplDDS0JfZyHaURlkIaTxIdZ6DvnvbUlp)vzfKqCbILUowcqOgeAkTxIdZ6DvnvbUlp)vzfKqCbYoKdwGL(SOGLESeGqni0uAvPbtdqxIYoKdwGLUowmJLXdK9hOwZsFwuWspw6XccFoxvtwywxyQ(ZLarplkZIsS01XccFoxvtwywxyQ(ZLarplkZsCzPplkyPhl)Cjq0BFLSd5GfQbiudcnLS01XYpxce92xjBac1GqtPDOs)smlXZYLpnrqT)eyTDO2)6qL(LywaWSOuXS0NLUowq4Z5QAYcZ6ct1FUei6zrzwaelkyPhl)Cjq0BFazhYbludqOgeAkzPRJLFUei6TpGSbiudcnL2Hk9lXSeplx(0eb1(tG12HA)Rdv6xIzbaZIsfZsFw66ybHpNRQjlmRlmv)5sGONfLzPyw6ZsFw66yjarqPNVfOcZ5jl9n2ajCyUO)GPXwCIjqwEilGK2lWYVtSSWokIfyJfKgdKyUzGft7uYYcFjkwaHlvnXcmzzHjw8eKLOHqq5ZYc7OiwmTtjlEYIdcYcHGYNLdZIRcxplpKfWJm2q4tn9sYylawdWe8(dMgVrSaOgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSzgly4sREjO93NtRRyIaIglLUQMazPRJL2HA)Rdv6xIzjEwauXfZsxhlQqmMffS0ou7FDOs)smlaJfaHgwaml9yXCkMfamlQRwZ(7ZP1vmrarJf)EaiwaEwael9zPRJf1vRz)9506kMiGOXIFpaelXZsCbOSaGzPhlZkPgCqrw8LTLUUxa)0CULsxvtGSa8SGgw6BSHWNA6LKX2VpNwxXebenvt(9gVrSaogM3yJsxvtGgX2ydKWH5I(dMgBXjMyb9lJkmKRzbG8aMEgiwauXykGzrLAWHyXzbPXajMBgyzHjRXw6LKXgvgvyixxHdy6zGm2cZ90CUXwac1GqtPn41ld2Hk9lXSamwauXSOGLaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZcWybqfZIcw6XccFoxvt2FFoTUIjciAQM87zPRJf1vRz)9506kMiGOXIFpaelXZsClMfaZspwMvsn4GIS4lBlDDVa(P5ClLUQMazb4zbGXsFw6ZsxhlQqmMffS0ou7FDOs)smlaJL4can28WFW0yJkJkmKRRWbm9mqgVrSuQydZBSrPRQjqJyBSbs4WCr)btJT4etSSbxAn9xIIfacl1cSaWWuaZIk1GdXIZcsJbsm3mWYctwJT0ljJnmCP10)xIQol1cgBH5EAo3ylaHAqOP0g86Lb7qL(LywaglamwuWIzSeGiO0Z3IGYFVWWIcwmJLaebLE(28qT)1MtS01XsaIGspFBEO2)AZjwuWsac1GqtPnateqGO6VtvC0n3JTdv6xIzbySaWyrbl9ybHpNRQjBaMiGarvqcxidS01Xsac1GqtPn41ld2Hk9lXSamwayS0NLUowcqeu65Brq5Vxyyrbl9yXmwMvsn4GIS4lBlDDVa(P5ClLUQMazrblbiudcnL2GxVmyhQ0VeZcWybGXsxhlQRwZoockHlCTnugZc2Hk9lXSamwuYCybWS0Jf0WcWZcbCxxuebAVe)Zk8WbxbpexsvvsRzPplkyrD1A2XrqjCHRTHYywWUIyPplDDSOcXywuWs7qT)1Hk9lXSamwaeAm28WFW0yddxAn9)LOQZsTGXBelLuYW8gBu6QAc0i2gBE4pyASDjomR3v1uf4U88xLvqcXfiJTWCpnNBSPUAnBWRxgSdv6xIzjEwucnSOGLESyglZkPgCqrw8LTLUUxa)0CULsxvtGS01XI6Q1SJJGs4cxBdLXSGDOs)smlaJfLaelaMLESexwaEwuxTMvvdHG6f(TRiw6ZcGzPhl9ybaYcaMf0WcWZI6Q1SQAieuVWVDfXsFwaEwiG76IIiq7L4FwHho4k4H4sQQsAnl9zrblQRwZoockHlCTnugZc2vel9zPRJfvigZIcwAhQ9VouPFjMfGXcGqJXw6LKX2L4WSExvtvG7YZFvwbjexGmEJyPeGmmVXgLUQManITXgiHdZf9hmn2m)(Hz5WS4Sm(VtdlK2vHJ)elM8cS8qwkDGiwCTMfyYYctSGF)z5NlbIEmlpKfvIf9LeilRiwmD)olingiXCZalEcYcsHjciqelEcYYctS87elakbzbRHplWKLailxJfv4VZYpxce9yw8HybMSSWel43Fw(5sGOhBSfM7P5CJne(CUQMSWSUWu9NlbIEwuMfaXIcwmJLFUei6TpGSd5GfQbiudcnLS01Xspwq4Z5QAYcZ6ct1FUei6zrzwuILUowq4Z5QAYcZ6ct1FUei6zrzwIll9zrbl9yrD1A2GxVmyxrSOGLESyglbick98TiO83lmS01XI6Q1SJJGs4cxBdLXSGDOs)smlaMLESGgwaEwMvsn4GIS4lBlDDVa(P5ClLUQMazPplatzw(5sGO3(kzvxTwfCn(FWKffSOUAn74iOeUW12qzmlyxrS01XI6Q1SJJGs4cxBdLXSqfFzBPR7fWpnNBxrS0NLUowcqOgeAkTbVEzWouPFjMfaZcGyjEw(5sGO3(kzdqOgeAkTGRX)dMSOGLESyglbick98T5HA)RnNyPRJfZybHpNRQjBaMiGarvqcxidS0NffSyglbick98TavyopzPRJLaebLE(28qT)1MtSOGfe(CUQMSbyIacevbjCHmWIcwcqOgeAkTbyIacev)DQIJU5ESDfXIcwmJLaeQbHMsBWRxgSRiwuWspw6XI6Q1SuqFryQQxPp2Hk9lXSeplkvmlDDSOUAnlf0xeMQyO2h7qL(LywINfLkML(SOGfZyzwj1GdkYQ6Apduf2QUwx)9lrHTu6QAcKLUow6XI6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqSOmlOHLUowuxTMv11EgOkSvDTU(7xIcx9j4jzXVhaIfLzbGYsFw6ZsxhlQRwZc0LGdbwPYiOjAkP8RusdQlMKDfXsFw66yrfIXSOGL2HA)Rdv6xIzbySaOIzPRJfe(CUQMSWSUWu9NlbIEwuMLIn2WA4Jn2(5sGOxjJnp8hmn2(5sGOxjJ3iwkfxdZBSrPRQjqJyBS5H)GPX2pxce9aYylm3tZ5gBi85CvnzHzDHP6pxce9SyMYSaiwuWIzS8ZLarV9vYoKdwOgGqni0uYsxhli85CvnzHzDHP6pxce9SOmlaIffS0Jf1vRzdE9YGDfXIcw6XIzSeGiO0Z3IGYFVWWsxhlQRwZoockHlCTnugZc2Hk9lXSayw6XcAyb4zzwj1GdkYIVST019c4NMZTu6QAcKL(SamLz5NlbIE7diR6Q1QGRX)dMSOGf1vRzhhbLWfU2gkJzb7kILUowuxTMDCeucx4ABOmMfQ4lBlDDVa(P5C7kIL(S01Xsac1GqtPn41ld2Hk9lXSaywaelXZYpxce92hq2aeQbHMsl4A8)GjlkyPhlMXsaIGspFBEO2)AZjw66yXmwq4Z5QAYgGjciqufKWfYal9zrblMXsaIGspFlqfMZtwuWspwmJf1vRzdE9YGDfXsxhlMXsaIGspFlck)9cdl9zPRJLaebLE(28qT)1MtSOGfe(CUQMSbyIacevbjCHmWIcwcqOgeAkTbyIacev)DQIJU5ESDfXIcwmJLaeQbHMsBWRxgSRiwuWspw6XI6Q1SuqFryQQxPp2Hk9lXSeplkvmlDDSOUAnlf0xeMQyO2h7qL(LywINfLkML(SOGfZyzwj1GdkYQ6Apduf2QUwx)9lrHTu6QAcKLUow6XI6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqSOmlOHLUowuxTMv11EgOkSvDTU(7xIcx9j4jzXVhaIfLzbGYsFw6ZsFw66yrD1AwGUeCiWkvgbnrtjLFLsAqDXKSRiw66yrfIXSOGL2HA)Rdv6xIzbySaOIzPRJfe(CUQMSWSUWu9NlbIEwuMLIn2WA4Jn2(5sGOhqgVrSuYCmmVXgLUQManITXgiHdZf9hmn2ItmHzX1AwG)onSatwwyIL7PsmlWKLaOXMh(dMgBlmvVNkXgVrSucngM3yJsxvtGgX2ydKWH5I(dMgBXrkCGelE4pyYI(WplQoMazbMSGVF5)btKOjuh2yZd)btJTzLvp8hmR6d)gB4FUWBelLm2cZ90CUXgcFoxvt2dxDizSPp8xtVKm2Ciz8gXsjaMH5n2O0v1eOrSn2cZ90CUX2SsQbhuKv11EgOkSvDTU(7xIcBjG76IIiqJn8px4nILsgBE4pyASnRS6H)GzvF43ytF4VMEjzSPc934nILsaqdZBSrPRQjqJyBS5H)GPX2SYQh(dMv9HFJn9H)A6LKXg(nEJ3ytf6VH5nILsgM3yJsxvtGgX2yZd)btJTXrqjCHRTHYywWydKWH5I(dMgBXHHYywGft3VZcsJbsm3mySfM7P5CJn1vRzdE9YGDOs)smlXZIsOX4nIfGmmVXgLUQManITXMh(dMgBoOh9hcQIn5tPXwOqqt13hu0JnILsgBH5EAo3ytD1Awvx7zGQWw1166VFjkCn9FnKf)EaiwaglauwuWI6Q1SQU2ZavHTQR11F)su4Qpbpjl(9aqSamwaOSOGLESyglGW36GE0FiOk2KpLvqV0rr2)caDjkwuWIzS4H)GP1b9O)qqvSjFkRGEPJISxwB6d1(ZIcw6XIzSacFRd6r)HGQyt(uw3jxB)la0LOyPRJfq4BDqp6peufBYNY6o5A7qL(LywINL4YsFw66ybe(wh0J(dbvXM8PSc6LokYIFpaelaJL4YIcwaHV1b9O)qqvSjFkRGEPJISdv6xIzbySGgwuWci8ToOh9hcQIn5tzf0lDuK9VaqxIIL(gBGeomx0FW0yloXelXa0J(dbXYMjFkzX0oLS4plAcJz539KfZHLydJH5zb)EaimlEcYYdzzO2q4DwCwaMYaIf87bGyXXSO9NyXXSebX4tvtSahw(RKy5EwWqwUNfFMdbHzbGKf(zXBpnS4SexaZc(9aqSqil6gcB8gXkUgM3yJsxvtGgX2yZd)btJTamrabIQ)ovXr3Cp2ydKWH5I(dMgBXjMybPWebeiIft3VZcsJbsm3mWIPDkzjcIXNQMyXtqwG)onMomXIP73zXzj2WyyEwuxTglM2PKfqcxidxIYylm3tZ5gBMXc4SoqBcRbqmlkyPhl9ybHpNRQjBaMiGarvqcxidSOGfZyjaHAqOP0g86Lb7qoybw66yrD1A2GxVmyxrS0NffS0Jf1vRzvDTNbQcBvxRR)(LOW10)1qw87bGyrzwaOS01XI6Q1SQU2ZavHTQR11F)su4Qpbpjl(9aqSOmlauw6ZsxhlQqmMffS0ou7FDOs)smlaJfLkML(gVrSmhdZBSrPRQjqJyBS5H)GPXwBnfQWwL0RKm2ajCyUO)GPXwCaI(S4yw(DIL2n4NfubqwUKLFNyXzj2WyyEwmDji0elWHft3VZYVtSGCQWCEYI6Q1yboSy6(DwCwaOagtbwIbOh9hcILnt(uYINGSyYVNLgCybPXajMBgy5ASCplMG5ZIkXYkIfhLFjlQudoel)oXsaKLdZs7YdVtGgBH5EAo3yRhl9yPhlQRwZQ6Apduf2QUwx)9lrHRP)RHS43daXs8SaWyPRJf1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGyjEwayS0NffS0JfZyjarqPNVfbL)EHHLUowmJf1vRzhhbLWfU2gkJzb7kIL(S0NffS0JfWzDG2ewdGyw66yjaHAqOP0g86Lb7qL(LywINf0umlDDS0JLaebLE(28qT)1MtSOGLaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZs8SGMIzPpl9zPplDDS0Jfq4BDqp6peufBYNYkOx6Oi7qL(LywINfaklkyjaHAqOP0g86Lb7qL(LywINfLkMffSeGiO0Z3MuyGA4aYsFw66yrfIXSOGLlFAIGA)jWA7qT)1Hk9lXSamwaOSOGfZyjaHAqOP0g86Lb7qoybw66yjarqPNVfOcZ5jlkyrD1AwGUeCiWkvgbnrtjLVDfXsxhlbick98TiO83lmSOGf1vRzhhbLWfU2gkJzb7qL(LywaglahwuWI6Q1SJJGs4cxBdLXSGDfz8gXcngM3yJsxvtGgX2yZd)btJTGNbsxvxTMXwyUNMZn26XI6Q1SQU2ZavHTQR11F)su4A6)Ai7qL(LywINfaOfnS01XI6Q1SQU2ZavHTQR11F)su4Qpbpj7qL(LywINfaOfnS0NffS0JLaeQbHMsBWRxgSdv6xIzjEwaGS01XspwcqOgeAkTuze0envvycAhQ0VeZs8SaazrblMXI6Q1SaDj4qGvQmcAIMsk)kL0G6IjzxrSOGLaebLE(wGkmNNS0NL(SOGfh)JRRrqt0Ws8kZsCl2ytD1A10ljJn87JgoGgBGeomx0FW0ydPEginlBVpA4aYIP73zXzjjtSeBymmplQRwJfpbzbPXajMBgy5Wj6EwCv46z5HSOsSSWeOXBelaMH5n2O0v1eOrSn28WFW0yd)(GxdkYydKWH5I(dMgBXXvzelBVp41GIWSy6(DwCwInmgMNf1vRXI66zjHplM2PKLiiuFjkwAWHfKgdKyUzGf4WcYPlbhcKLTOBUhBSfM7P5CJTESOUAnRQR9mqvyR6AD93VefUM(VgYIFpaelXZcGyPRJf1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGyjEwael9zrbl9yjarqPNVnpu7FT5elDDSeGqni0uAdE9YGDOs)smlXZcaKLUowmJfe(CUQMSbWAaMG3FWKffSyglbick98TavyopzPRJLESeGqni0uAPYiOjAQQWe0ouPFjML4zbaYIcwmJf1vRzb6sWHaRuze0enLu(vkPb1ftYUIyrblbick98TavyopzPpl9zrbl9yXmwaHVTTMcvyRs6vs2)caDjkw66yXmwcqOgeAkTbVEzWoKdwGLUowmJLaeQbHMsBaMiGar1FNQ4OBUhBhYblWsFJ3iwaqdZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn2IJRYiw2EFWRbfHzrLAWHybPWebeiYylm3tZ5gB9yjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSamwqdlkyXmwaN1bAtynaIzrbl9ybHpNRQjBaMiGarvqcxidS01Xsac1GqtPn41ld2Hk9lXSamwqdl9zrbli85CvnzdG1ambV)Gjl9zrblMXci8TT1uOcBvsVsY(xaOlrXIcwcqeu65BZd1(xBoXIcwmJfWzDG2ewdGywuWcf0xeMSxw9SalkyXX)46Ae0enSeplMtXgVrSaOgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzS1Jf1vRzhhbLWfU2gkJzb7qL(LywINf0WsxhlMXI6Q1SJJGs4cxBdLXSGDfXsFwuWspwuxTMfOlbhcSsLrqt0us5xPKguxmj7qL(LywaglOcG2shzS0NffS0Jf1vRzPG(IWufd1(yhQ0VeZs8SGkaAlDKXsxhlQRwZsb9fHPQEL(yhQ0VeZs8SGkaAlDKXsFJnqchMl6pyASfhHj6EwaHplGR5suS87elucYcSXcabhbLWfML4WqzmlGwwaxZLOybOlbhcKfQmcAIMskFwGdlxYYVtSOD8ZcQailWglEYc6h0xeMm2q4tn9sYyde(1HaURBOskFSXBelGJH5n2O0v1eOrSn28WFW0ydVY2nKXwyUNMZn2gQneE3v1elky59bf92)kP6dRGhXs8SOeaJffS4r1WofaIffSGWNZv1Kfe(1HaURBOskFSXwOqqt13hu0JnILsgVrSuQydZBSrPRQjqJyBS5H)GPXwjeMTBiJTWCpnNBSnuBi8URQjwuWY7dk6T)vs1hwbpIL4zrP4ArdlkyXJQHDkaelkybHpNRQjli8RdbCx3qLu(yJTqHGMQVpOOhBelLmEJyPKsgM3yJsxvtGgX2yZd)btJn8tATp1M2hYylm3tZ5gBd1gcV7QAIffS8(GIE7FLu9HvWJyjEwucGXcGzzOs)smlkyXJQHDkaelkybHpNRQjli8RdbCx3qLu(yJTqHGMQVpOOhBelLmEJyPeGmmVXgLUQManITXMh(dMgBn4eOkSvt)xdzSbs4WCr)btJT4amwSatwcGSy6(D46zj4rrxIYylm3tZ5gBEunStbGmEJyPuCnmVXgLUQManITXMh(dMgBuze0envvycASbs4WCr)btJn0VmcAIgwInmbzX0oLS4QW1ZYdzHYNgwCwsYelXggdZZIPlbHMyXtqwWocILgCybPXajMBgm2cZ90CUXwpwOG(IWKvVsFQjHSNLUowOG(IWKfd1(utczplDDSqb9fHjRNfQjHSNLUowuxTMv11EgOkSvDTU(7xIcxt)xdzhQ0VeZs8SaaTOHLUowuxTMv11EgOkSvDTU(7xIcx9j4jzhQ0VeZs8SaaTOHLUowC8pUUgbnrdlXZcWPywuWsac1GqtPn41ld2HCWcSOGfZybCwhOnH1aiML(SOGLESeGqni0uAdE9YGDOs)smlXZsClMLUowcqOgeAkTbVEzWoKdwGL(S01XIkeJzrblx(0eb1(tG12HA)Rdv6xIzbySOuXgVrSuYCmmVXgLUQManITXMh(dMgBT1uOcBvsVsYydKWH5I(dMgBXbi6ZYCO2FwuPgCiww4lrXcsJHXwyUNMZn2cqOgeAkTbVEzWoKdwGffSGWNZv1KnawdWe8(dMSOGLES44FCDncAIgwINfGtXSOGfZyjarqPNVnpu7FT5elDDSeGiO0Z3MhQ9V2CIffS44FCDncAIgwaglMtXS0NffSyglbick98TiO83lmSOGLESyglbick98T5HA)RnNyPRJLaeQbHMsBaMiGar1FNQ4OBUhBhYblWsFwuWIzSaoRd0MWAaeB8gXsj0yyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXMzSaoRd0MWAaeZIcwq4Z5QAYgaRbycE)btwuWspw6XIJ)X11iOjAyjEwaofZIcw6XI6Q1SaDj4qGvQmcAIMsk)kL0G6IjzxrS01XIzSeGiO0Z3cuH58KL(S01XI6Q1SQAieuVWVDfXIcwuxTMvvdHG6f(Tdv6xIzbySOUAnBWRxgSGRX)dMS0NLUowU8PjcQ9NaRTd1(xhQ0VeZcWyrD1A2GxVmybxJ)hmzPRJLaebLE(28qT)1MtS0NffS0JfZyjarqPNVnpu7FT5elDDS0Jfh)JRRrqt0WcWyXCkMLUowaHVTTMcvyRs6vs2)caDjkw6ZIcw6XccFoxvt2amrabIQGeUqgyPRJLaeQbHMsBaMiGar1FNQ4OBUhBhYblWsFw6BSbs4WCr)btJnKgdKyUzGft7uYI)SaCkgWSedmaILEWrdnrdl)UNSyofZsmWaiwmD)olifMiGar9zX097W1ZIgIVefl)vsSCjlXwdHG6f(zXtqw0xsSSIyX097SGuyIaceXY1y5Ewm5ywajCHmqGgBi8PMEjzSfaRbycE)bZQk0FJ3iwkbWmmVXgLUQManITXwyUNMZn2q4Z5QAYgaRbycE)bZQk0FJnp8hmn2cKMW)56QRpuzjLVXBelLaGgM3yJsxvtGgX2ylm3tZ5gBi85CvnzdG1ambV)Gzvf6VXMh(dMgBxg8j9)GPXBelLaOgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSrb9fHj7Lv9k9HfGNfakliHfp8hmT43N2nKLqgfwpv)RKybWSygluqFryYEzvVsFyb4zPhlamwamlVRP8Ty4sxHT6Vt1gCi8BP0v1eilaplXLL(SGew8WFW0AA8F3siJcRNQ)vsSaywk2ciwqcl4isRR7o(jJnqchMl6pyASH(4)k9NWSSdnXs5kSZsmWaiw8HybLFjbYsenSGPambn2q4tn9sYyZXraiA2OGXBelLaogM3yJsxvtGgX2yZd)btJn87dEnOiJnqchMl6pyASfhxLrSS9(GxdkcZIPDkz53jwAhQ9NLdZIRcxplpKfkbrllTHYywGLdZIRcxplpKfkbrllfGlw8HyXFwaofdywIbgaXYLS4jlOFqFrycTSG0yGeZndSOD8JzXt4VtdlauaJPaMf4Wsb4IftWLgKficAcEelLWHy539KfUtPIzjgyaelM2PKLcWflMGlnyIUNLT3h8AqrSKqtgBH5EAo3yRhlQqmMffSC5tteu7pbwBhQ9VouPFjMfGXI5Wsxhl9yrD1A2XrqjCHRTHYywWouPFjMfGXcQaOT0rglaplb60S0Jfh)JRRrqt0WcsyjUfZsFwuWI6Q1SJJGs4cxBdLXSGDfXsFw6Zsxhl9yXX)46Ae0enSaywq4Z5QAY64iaenBuGfGNf1vRzPG(IWufd1(yhQ0VeZcGzbe(22AkuHTkPxjz)laeUouPFjlaplaYIgwINfLuQyw66yXX)46Ae0enSaywq4Z5QAY64iaenBuGfGNf1vRzPG(IWuvVsFSdv6xIzbWSacFBBnfQWwL0RKS)facxhQ0VKfGNfazrdlXZIskvml9zrbluqFryYEz1ZcSOGLESyglQRwZg86Lb7kILUowmJL31u(w87JgoGwkDvnbYsFwuWspw6XIzSeGqni0uAdE9YGDfXsxhlbick98TavyopzrblMXsac1GqtPLkJGMOPQctq7kIL(S01XsaIGspFBEO2)AZjw6ZIcw6XIzSeGiO0Z3IGYFVWWsxhlMXI6Q1SbVEzWUIyPRJfh)JRRrqt0Ws8SaCkML(S01XspwExt5BXVpA4aAP0v1eilkyrD1A2GxVmyxrSOGLESOUAnl(9rdhql(9aqSamwIllDDS44FCDncAIgwINfGtXS0NL(S01XI6Q1SbVEzWUIyrblMXI6Q1SJJGs4cxBdLXSGDfXIcwmJL31u(w87JgoGwkDvnbA8gXcqfByEJnkDvnbAeBJnp8hmn2sYuTectJnqchMl6pyASfNyIfaIqyIz5swqVv6dlOFqFryIfpbzb7iiwqoJRBaooS0AwaicHjln4WcsJbsm3mySfM7P5CJTESOUAnlf0xeMQ6v6JDOs)smlXZcHmkSEQ(xjXsxhl9yjS7dkcZIYSaiwuWYqHDFqr1)kjwaglOHL(S01Xsy3hueMfLzjUS0NffS4r1WofaY4nIfGuYW8gBu6QAc0i2gBH5EAo3yRhlQRwZsb9fHPQEL(yhQ0VeZs8SqiJcRNQ)vsSOGLESeGqni0uAdE9YGDOs)smlXZcAkMLUowcqOgeAkTbyIacev)DQIJU5ESDOs)smlXZcAkML(S01Xspwc7(GIWSOmlaIffSmuy3huu9VsIfGXcAyPplDDSe29bfHzrzwIll9zrblEunStbGm28WFW0yB31TAjeMgVrSaeGmmVXgLUQManITXwyUNMZn26XI6Q1SuqFryQQxPp2Hk9lXSepleYOW6P6FLelkyPhlbiudcnL2GxVmyhQ0VeZs8SGMIzPRJLaeQbHMsBaMiGar1FNQ4OBUhBhQ0VeZs8SGMIzPplDDS0JLWUpOimlkZcGyrbldf29bfv)RKybySGgw6ZsxhlHDFqrywuML4YsFwuWIhvd7uaiJnp8hmn2AlTUwcHPXBelafxdZBSrPRQjqJyBSbs4WCr)btJnKdi6ZcmzjaAS5H)GPXMjFMdovyRs6vsgVrSaK5yyEJnkDvnbAeBJnp8hmn2WVpTBiJnqchMl6pyASfNyILT3N2nelpKLObgyzdQ9Hf0pOVimXcCyX0oLSCjlWuxGf0BL(Wc6h0xeMyXtqwwyIfKdi6Zs0adywUglxYc6TsFyb9d6lctgBH5EAo3yJc6lct2lR6v6dlDDSqb9fHjlgQ9PMeYEw66yHc6lctwplutczplDDSOUAnRjFMdovyRs6vs2velkyrD1AwkOVimv1R0h7kILUow6XI6Q1SbVEzWouPFjMfGXIh(dMwtJ)7wczuy9u9VsIffSOUAnBWRxgSRiw6B8gXcqOXW8gBE4pyASzA8F3yJsxvtGgX24nIfGaygM3yJsxvtGgX2yZd)btJTzLvp8hmR6d)gB6d)10ljJTMR1)(SmEJ3yZHKH5nILsgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzS1Jf1vRz)RKmbNScoKxQEjin2Hk9lXSamwqfaTLoYybWSuSvjw66yrD1A2)kjtWjRGd5LQxcsJDOs)smlaJfp8hmT43N2nKLqgfwpv)RKybWSuSvjwuWspwOG(IWK9YQEL(WsxhluqFryYIHAFQjHSNLUowOG(IWK1Zc1Kq2ZsFw6ZIcwuxTM9VsYeCYk4qEP6LG0yxrSOGLzLudoOi7FLKj4KvWH8s1lbPXsPRQjqJnqchMl6pyASHuxhwA)jmlM2PFNgw(DIL44qEzW)WonSOUAnwmDAnlnxRzb2ASy6(9lz53jwsczplbh)gBi8PMEjzSboKxwnDADT5ADf2AgVrSaKH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgBMXcf0xeMSxwXqTpSOGLESGJiTU((GIESf)(0UHyjEwqdlky5DnLVfdx6kSv)DQ2GdHFlLUQMazPRJfCeP113hu0JT43N2nelXZcaKL(gBGeomx0FW0ydPUoS0(tywmTt)onSS9(GxdkILdZIj487SeC8FjkwGiOHLT3N2nelxYc6TsFyb9d6lctgBi8PMEjzSDOs4qv87dEnOiJ3iwX1W8gBu6QAc0i2gBE4pyASfGjciqu93Pko6M7XgBGeomx0FW0yloXelifMiGarSyANsw8NfnHXS87EYcAkMLyGbqS4jil6ljwwrSy6(DwqAmqI5MbJTWCpnNBSzglGZ6aTjSgaXSOGLES0Jfe(CUQMSbyIacevbjCHmWIcwmJLaeQbHMsBWRxgSd5GfyPRJf1vRzdE9YGDfXsFwuWspwuxTMLc6lctv9k9XouPFjML4zbGXsxhlQRwZsb9fHPkgQ9XouPFjML4zbGXsFwuWspwmJLzLudoOiRQR9mqvyR6AD93Vef2sPRQjqw66yrD1Awvx7zGQWw1166VFjkCn9FnKf)EaiwINL4YsxhlQRwZQ6Apduf2QUwx)9lrHR(e8KS43daXs8Sexw6ZsxhlQqmMffS0ou7FDOs)smlaJfLkMffSyglbiudcnL2GxVmyhYblWsFJ3iwMJH5n2O0v1eOrSn28WFW0yBCeucx4ABOmMfm2ajCyUO)GPXwCIjwIddLXSalMUFNfKgdKyUzWylm3tZ5gBQRwZg86Lb7qL(LywINfLqJXBel0yyEJnkDvnbAeBJnp8hmn2WRSDdzSfke0u99bf9yJyPKXwyUNMZn26XYqTHW7UQMyPRJf1vRzPG(IWufd1(yhQ0VeZcWyjUSOGfkOVimzVSIHAFyrbldv6xIzbySOK5WIcwExt5BXWLUcB1FNQn4q43sPRQjqw6ZIcwEFqrV9VsQ(Wk4rSeplkzoSaGzbhrAD99bf9ywamldv6xIzrbl9yHc6lct2lREwGLUowgQ0VeZcWybva0w6iJL(gBGeomx0FW0yloXelBRSDdXYLSe5jivEbwGjlEw43Vefl)U)SOpeeMfLmhmfWS4jilAcJzX097SuchIL3hu0JzXtqw8NLFNyHsqwGnwCw2GAFyb9d6lctS4plkzoSGPaMf4WIMWywgQ0V8suS4ywEilj8zz3rCjkwEild1gcVZc4AUeflO3k9Hf0pOVimz8gXcGzyEJnkDvnbAeBJnp8hmn2WVpnxRn2ajCyUO)GPXgYjIIyzfXY27tZ1Aw8NfxRz5VscZYk1egZYcFjkwqVcbFCmlEcYY9SCywCv46z5HSenWalWHfn9S87el4ikCUMfp8hmzrFjXIkPHMyz3tqnXsCCiVu9sqAybMSaiwEFqrp2ylm3tZ5gBMXY7AkFl(jT2Nk4CT3sPRQjqwuWspwuxTMf)(0CT2ouBi8URQjwuWspwWrKwxFFqrp2IFFAUwZcWyjUS01XIzSmRKAWbfz)RKmbNScoKxQEjinwkDvnbYsFw66y5DnLVfdx6kSv)DQ2GdHFlLUQMazrblQRwZsb9fHPkgQ9XouPFjMfGXsCzrbluqFryYEzfd1(WIcwuxTMf)(0CT2ouPFjMfGXcaKffSGJiTU((GIESf)(0CTML4vMfZHL(SOGLESyglZkPgCqrwDHGpoU20e9xIQIsFLryYsPRQjqw66y5VsIfKllMdAyjEwuxTMf)(0CT2ouPFjMfaZcGyPplky59bf92)kP6dRGhXs8SGgJ3iwaqdZBSrPRQjqJyBS5H)GPXg(9P5ATXgiHdZf9hmn2qoUFNLTN0AFyjoox7zzHjwGjlbqwmTtjld1gcV7QAIf11Zc(pTMft(9S0GdlOxHGpoMLObgyXtqwaHj6EwwyIfvQbhIfKghXww2(tRzzHjwuPgCiwqkmrabIybFzGy539NftNwZs0adS4j83PHLT3NMR1gBH5EAo3y7DnLVf)Kw7tfCU2BP0v1eilkyrD1Aw87tZ1A7qTHW7UQMyrbl9yXmwMvsn4GIS6cbFCCTPj6VevfL(kJWKLsxvtGS01XYFLelixwmh0Ws8SyoS0NffS8(GIE7FLu9HvWJyjEwIRXBelaQH5n2O0v1eOrSn28WFW0yd)(0CT2ydKWH5I(dMgBih3VZsCCiVu9sqAyzHjw2EFAUwZYdzbiIIyzfXYVtSOUAnwulWIRXqww4lrXY27tZ1AwGjlOHfmfGjiMf4WIMWywgQ0V8sugBH5EAo3yBwj1GdkY(xjzcozfCiVu9sqASu6QAcKffSGJiTU((GIESf)(0CTML4vML4YIcw6XIzSOUAn7FLKj4KvWH8s1lbPXUIyrblQRwZIFFAUwBhQneE3v1elDDS0Jfe(CUQMSGd5LvtNwxBUwxHTglkyPhlQRwZIFFAUwBhQ0VeZcWyjUS01XcoI0667dk6Xw87tZ1AwINfaXIcwExt5BXpP1(ubNR9wkDvnbYIcwuxTMf)(0CT2ouPFjMfGXcAyPpl9zPVXBelGJH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgBo(hxxJGMOHL4zbGwmlayw6XIsfZcWZI6Q1S)vsMGtwbhYlvVeKgl(9aqS0Nfaml9yrD1Aw87tZ1A7qL(LywaEwIlliHfCeP11Dh)elaplMXY7AkFl(jT2Nk4CT3sPRQjqw6ZcaMLESeGqni0uAXVpnxRTdv6xIzb4zjUSGewWrKwx3D8tSa8S8UMY3IFsR9Pcox7Tu6QAcKL(SaGzPhlGW32wtHkSvj9kj7qL(LywaEwqdl9zrbl9yrD1Aw87tZ1A7kILUowcqOgeAkT43NMR12Hk9lXS03ydKWH5I(dMgBi11HL2FcZIPD63PHfNLT3h8AqrSSWelMoTMLGVWelBVpnxRz5HS0CTMfyRHww8eKLfMyz79bVguelpKfGikIL44qEP6LG0Wc(9aqSSIm2q4tn9sYyd)(0CTUAcMFT5ADf2AgVrSuQydZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn2ItmXY27dEnOiwmD)olXXH8s1lbPHLhYcqefXYkILFNyrD1ASy6(D46zrdXxIILT3NMR1SSI(RKyXtqwwyILT3h8AqrSatwmhaZsSHXW8SGFpaeMLv(NMfZHL3hu0Jn2cZ90CUXgcFoxvtwWH8YQPtRRnxRRWwJffSGWNZv1Kf)(0CTUAcMFT5ADf2ASOGfZybHpNRQj7HkHdvXVp41GIyPRJLESOUAnRQR9mqvyR6AD93VefUM(VgYIFpaelXZsCzPRJf1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGyjEwIll9zrbl4isRRVpOOhBXVpnxRzbySyoSOGfe(CUQMS43NMR1vtW8RnxRRWwZ4nILskzyEJnkDvnbAeBJnp8hmn2Cqp6peufBYNsJTqHGMQVpOOhBelLm2cZ90CUXMzS8xaOlrXIcwmJfp8hmToOh9hcQIn5tzf0lDuK9YAtFO2Fw66ybe(wh0J(dbvXM8PSc6LokYIFpaelaJL4YIcwaHV1b9O)qqvSjFkRGEPJISdv6xIzbySexJnqchMl6pyASfNyIfSjFkzbdz539NLcWflOONLshzSSI(RKyrTall8LOy5EwCmlA)jwCmlrqm(u1elWKfnHXS87EYsCzb)EaimlWHfasw4Nft7uYsCbml43daHzHqw0nKXBelLaKH5n2O0v1eOrSn28WFW0yRecZ2nKXwOqqt13hu0JnILsgBH5EAo3yBO2q4DxvtSOGL3hu0B)RKQpScEelXZspw6XIsMdlaMLESGJiTU((GIESf)(0UHyb4zbqSa8SOUAnlf0xeMQ6v6JDfXsFw6ZcGzzOs)sml9zbjS0JfLybWS8UMY3(MUSwcHj2sPRQjqw6ZIcw6Xsac1GqtPn41ld2HCWcSOGfZybCwhOnH1aiMffS0Jfe(CUQMSbyIacevbjCHmWsxhlbiudcnL2amrabIQ)ovXr3Cp2oKdwGLUowmJLaebLE(28qT)1MtS0NLUowWrKwxFFqrp2IFFA3qSamw6XspwaySaGzPhlQRwZsb9fHPQEL(yxrSa8Saiw6ZsFwaEw6XIsSaywExt5BFtxwlHWeBP0v1eil9zPplkyXmwOG(IWKfd1(utczplDDS0JfkOVimzVSIHAFyPRJLESqb9fHj7Lvv4VZsxhluqFryYEzvVsFyPplkyXmwExt5BXWLUcB1FNQn4q43sPRQjqw66yrD1A2O5kHd456QpbpVqnAPX(yr46fXs8kZcGqtXS0NffS0JfCeP113hu0JT43N2nelaJfLkMfGNLESOelaML31u(230L1simXwkDvnbYsFw6ZIcwC8pUUgbnrdlXZcAkMfamlQRwZIFFAUwBhQ0VeZcWZcaJL(SOGLESyglQRwZc0LGdbwPYiOjAkP8RusdQlMKDfXsxhluqFryYEzfd1(WsxhlMXsaIGspFlqfMZtw6ZIcwmJf1vRzhhbLWfU2gkJzHk(Y2sx3lGFAo3UIm2ajCyUO)GPXgabQneENfaIqy2UHy5ASG0yGeZndSCywgYblGww(DAiw8Hyrtyml)UNSGgwEFqrpMLlzb9wPpSG(b9fHjwmD)olBWpoGww0egZYV7jlkvmlWFNgthMy5sw8SalOFqFryIf4WYkILhYcAy59bf9ywuPgCiwCwqVv6dlOFqFryYYsCeMO7zzO2q4DwaxZLOyb50LGdbYc6xgbnrtjLplRutymlxYYgu7dlOFqFryY4nILsX1W8gBu6QAc0i2gBE4pyAS1GtGQWwn9FnKXgiHdZf9hmn2ItmXsCaglwGjlbqwmD)oC9Se8OOlrzSfM7P5CJnpQg2PaqgVrSuYCmmVXgLUQManITXgmYydtVXMh(dMgBi85CvnzSHW1lYyZmwaN1bAtynaIzrbli85CvnzdG1ambV)GjlkyPhl9yrD1Aw87tZ1A7kILUowExt5BXpP1(ubNR9wkDvnbYsxhlbick98T5HA)RnNyPplkyPhlMXI6Q1SyOg)xGSRiwuWIzSOUAnBWRxgSRiwuWspwmJL31u(22AkuHTkPxjzP0v1eilDDSOUAnBWRxgSGRX)dMSeplbiudcnL22AkuHTkPxjzhQ0VeZcGzbGYsFwuWccFoxvt2FFoTUIjciAQM87zrbl9yXmwcqeu65BZd1(xBoXsxhlbiudcnL2amrabIQ)ovXr3Cp2UIyrbl9yrD1Aw87tZ1A7qL(LywaglaILUowmJL31u(w8tATpvW5AVLsxvtGS0NL(SOGL3hu0B)RKQpScEelXZI6Q1SbVEzWcUg)pyYcWZsXwail9zPRJL2HA)Rdv6xIzbySOUAnBWRxgSGRX)dMS03ydHp10ljJTaynatW7pywDiz8gXsj0yyEJnkDvnbAeBJnp8hmn2cKMW)56QRpuzjLVXgiHdZf9hmn2ItmXcsJbsm3mWcmzjaYYk1egZINGSOVKy5EwwrSy6(DwqkmrabIm2cZ90CUXgcFoxvt2aynatW7pywDiz8gXsjaMH5n2O0v1eOrSn2cZ90CUXgcFoxvt2aynatW7pywDizS5H)GPX2LbFs)pyA8gXsjaOH5n2O0v1eOrSn28WFW0yJkJGMOPQctqJnqchMl6pyASfNyIf0VmcAIgwInmbzbMSeazX097SS9(0CTMLvelEcYc2rqS0GdlaOLg7dlEcYcsJbsm3mySfM7P5CJnvigZIcwU8PjcQ9NaRTd1(xhQ0VeZcWyrj0Wsxhl9yrD1A2O5kHd456QpbpVqnAPX(yr46fXcWybqOPyw66yrD1A2O5kHd456QpbpVqnAPX(yr46fXs8kZcGqtXS0NffSOUAnl(9P5ATDfXIcw6Xsac1GqtPn41ld2Hk9lXSeplOPyw66ybCwhOnH1aiML(gVrSucGAyEJnkDvnbAeBJnp8hmn2WpP1(uBAFiJTqHGMQVpOOhBelLm2cZ90CUX2qTHW7UQMyrbl)vs1hwbpIL4zrj0WIcwWrKwxFFqrp2IFFA3qSamwmhwuWIhvd7uaiwuWspwuxTMn41ld2Hk9lXSeplkvmlDDSyglQRwZg86Lb7kIL(gBGeomx0FW0ydGa1gcVZst7dXcmzzfXYdzjUS8(GIEmlMUFhUEwqAmqI5MbwuPlrXIRcxplpKfczr3qS4jilj8zbIGMGhfDjkJ3iwkbCmmVXgLUQManITXMh(dMgBT1uOcBvsVsYydKWH5I(dMgBXjMyjoarFwUglxIpqIfpzb9d6lctS4jil6ljwUNLvelMUFNfNfa0sJ9HLObgyXtqwIbOh9hcILnt(uASfM7P5CJnkOVimzVS6zbwuWIhvd7uaiwuWI6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lIfGXcGqtXSOGLESacFRd6r)HGQyt(uwb9shfz)la0LOyPRJfZyjarqPNVnPWa1WbKLUowWrKwxFFqrpML4zbqS0NffS0Jf1vRzhhbLWfU2gkJzb7qL(LywaglahwaWS0Jf0WcWZYSsQbhuKfFzBPR7fWpnNBP0v1eil9zrblQRwZoockHlCTnugZc2velDDSyglQRwZoockHlCTnugZc2vel9zrbl9yXmwcqOgeAkTbVEzWUIyPRJf1vRz)9506kMiGOXIFpaelaJfLqdlkyPDO2)6qL(LywaglaQ4IzrblTd1(xhQ0VeZs8SOuXfZsxhlMXcgU0QxcA)9506kMiGOXsPRQjqw6ZIcw6XcgU0QxcA)9506kMiGOXsPRQjqw66yjaHAqOP0g86Lb7qL(LywINL4wml9nEJybOInmVXgLUQManITXMh(dMgB43NMR1gBGeomx0FW0yloXelolBVpnxRzbGCs)olrdmWYk1egZY27tZ1AwomlUEihSalRiwGdlfGlw8HyXvHRNLhYcebnbpILyGbqgBH5EAo3ytD1Awys)oUgrtGI(dM2velkyPhlQRwZIFFAUwBhQneE3v1elDDS44FCDncAIgwINfGtXS034nIfGuYW8gBu6QAc0i2gBE4pyASHFFAUwBSbs4WCr)btJT44QmILyGbqSOsn4qSGuyIaceXIP73zz79P5AnlEcYYVtjlBVp41GIm2cZ90CUXwaIGspFBEO2)AZjwuWIzS8UMY3IFsR9Pcox7Tu6QAcKffS0Jfe(CUQMSbyIacevbjCHmWsxhlbiudcnL2GxVmyxrS01XI6Q1SbVEzWUIyPplkyjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSamwqfaTLoYyb4zjqNMLES44FCDncAIgwqclOPyw6ZIcwuxTMf)(0CT2ouPFjMfGXI5WIcwmJfWzDG2ewdGyJ3iwacqgM3yJsxvtGgX2ylm3tZ5gBbick98T5HA)RnNyrbl9ybHpNRQjBaMiGarvqcxidS01Xsac1GqtPn41ld2velDDSOUAnBWRxgSRiw6ZIcwcqOgeAkTbyIacev)DQIJU5ESDOs)smlaJfaglkyrD1Aw87tZ1A7kIffSqb9fHj7LvplWIcwmJfe(CUQMShQeouf)(GxdkIffSyglGZ6aTjSgaXgBE4pyASHFFWRbfz8gXcqX1W8gBu6QAc0i2gBE4pyASHFFWRbfzSbs4WCr)btJT4etSS9(GxdkIft3VZINSaqoPFNLObgyboSCnwkaxOdKficAcEelXadGyX097SuaUgwsczplbh)wwIHgdzbCvgXsmWaiw8NLFNyHsqwGnw(DIfasP83lmSOUAnwUglBVpnxRzXeCPbt09S0CTMfyRXcCyPaCXIpelWKfaXY7dk6XgBH5EAo3ytD1Awys)oUg0Kpveh(GPDfXsxhl9yXmwWVpTBiRhvd7uaiwuWIzSGWNZv1K9qLWHQ43h8AqrS01XspwuxTMn41ld2Hk9lXSamwqdlkyrD1A2GxVmyxrS01Xspw6XI6Q1SbVEzWouPFjMfGXcQaOT0rglaplb60S0Jfh)JRRrqt0WcsyjUfZsFwuWI6Q1SbVEzWUIyPRJf1vRzhhbLWfU2gkJzHk(Y2sx3lGFAo3ouPFjMfGXcQaOT0rglaplb60S0Jfh)JRRrqt0WcsyjUfZsFwuWI6Q1SJJGs4cxBdLXSqfFzBPR7fWpnNBxrS0NffSeGiO0Z3IGYFVWWsFw6ZIcw6XcoI0667dk6Xw87tZ1AwaglXLLUowq4Z5QAYIFFAUwxnbZV2CTUcBnw6ZsFwuWIzSGWNZv1K9qLWHQ43h8AqrSOGLESyglZkPgCqr2)kjtWjRGd5LQxcsJLsxvtGS01XcoI0667dk6Xw87tZ1AwaglXLL(gVrSaK5yyEJnkDvnbAeBJnp8hmn2sYuTectJnqchMl6pyASfNyIfaIqyIz5sw2GAFyb9d6lctS4jilyhbXsCyP1SaqectwAWHfKgdKyUzWylm3tZ5gB9yrD1AwkOVimvXqTp2Hk9lXSepleYOW6P6FLelDDS0JLWUpOimlkZcGyrbldf29bfv)RKybySGgw6ZsxhlHDFqrywuML4YsFwuWIhvd7uaiJ3iwacngM3yJsxvtGgX2ylm3tZ5gB9yrD1AwkOVimvXqTp2Hk9lXSepleYOW6P6FLelDDS0JLWUpOimlkZcGyrbldf29bfv)RKybySGgw6ZsxhlHDFqrywuML4YsFwuWIhvd7uaiwuWspwuxTMDCeucx4ABOmMfSdv6xIzbySGgwuWI6Q1SJJGs4cxBdLXSGDfXIcwmJLzLudoOil(Y2sx3lGFAo3sPRQjqw66yXmwuxTMDCeucx4ABOmMfSRiw6BS5H)GPX2URB1simnEJybiaMH5n2O0v1eOrSn2cZ90CUXwpwuxTMLc6lctvmu7JDOs)smlXZcHmkSEQ(xjXIcw6Xsac1GqtPn41ld2Hk9lXSeplOPyw66yjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSeplOPyw6Zsxhl9yjS7dkcZIYSaiwuWYqHDFqr1)kjwaglOHL(S01Xsy3hueMfLzjUS0NffS4r1WofaIffS0Jf1vRzhhbLWfU2gkJzb7qL(LywaglOHffSOUAn74iOeUW12qzmlyxrSOGfZyzwj1GdkYIVST019c4NMZTu6QAcKLUowmJf1vRzhhbLWfU2gkJzb7kIL(gBE4pyAS1wADTectJ3iwacaAyEJnkDvnbAeBJnqchMl6pyASfNyIfKdi6ZcmzbPXrJnp8hmn2m5ZCWPcBvsVsY4nIfGaOgM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSHJiTU((GIESf)(0UHyjEwmhwamlnneoS0JLsh)0uOIW1lIfGNfLkUywqclaQyw6ZcGzPPHWHLESOUAnl(9bVguuLkJGMOPKYVIHAFS43daXcsyXCyPVXgiHdZf9hmn2qQRdlT)eMft70VtdlpKLfMyz79PDdXYLSSb1(WIP9lSZYHzXFwqdlVpOOhdyLyPbhwie0uGfavmYLLsh)0uGf4WI5WY27dEnOiwq)YiOjAkP8zb)EaiSXgcFQPxsgB43N2nu9YkgQ9X4nIfGaogM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzSPeliHfCeP11Dh)elaJfaXcaMLESuSfqSa8S0JfCeP113hu0JT43N2nelaywuIL(Sa8S0JfLybWS8UMY3IHlDf2Q)ovBWHWVLsxvtGSa8SOKfnS0NL(Saywk2QeAyb4zrD1A2XrqjCHRTHYywWouPFj2ydKWH5I(dMgBi11HL2FcZIPD63PHLhYcYX4)olGR5suSehgkJzbJne(utVKm2mn(VxVS2gkJzbJ3iwXTydZBSrPRQjqJyBS5H)GPXMPX)DJnqchMl6pyASfNyIfKJX)DwUKLnO2hwq)G(IWelWHLRXsczz79PDdXIPtRzPDplx(qwqAmqI5Mbw8SqjCiJTWCpnNBS1JfkOVimz1R0NAsi7zPRJfkOVimz9SqnjK9SOGfe(CUQMShUg0KJGyPplkyPhlVpOO3(xjvFyf8iwINfZHLUowOG(IWKvVsFQxwbelDDS0ou7FDOs)smlaJfLkML(S01XI6Q1SuqFryQIHAFSdv6xIzbyS4H)GPf)(0UHSeYOW6P6FLelkyrD1AwkOVimvXqTp2velDDSqb9fHj7Lvmu7dlkyXmwq4Z5QAYIFFA3q1lRyO2hw66yrD1A2GxVmyhQ0VeZcWyXd)btl(9PDdzjKrH1t1)kjwuWIzSGWNZv1K9W1GMCeelkyrD1A2GxVmyhQ0VeZcWyHqgfwpv)RKyrblQRwZg86Lb7kILUowuxTMDCeucx4ABOmMfSRiwuWccFoxvtwtJ)71lRTHYywGLUowmJfe(CUQMShUg0KJGyrblQRwZg86Lb7qL(LywINfczuy9u9VsY4nIvCvYW8gBu6QAc0i2gBGeomx0FW0yloXelBVpTBiwUglxYc6TsFyb9d6lctOLLlzzdQ9Hf0pOVimXcmzXCamlVpOOhZcCy5HSenWalBqTpSG(b9fHjJnp8hmn2WVpTBiJ3iwXfqgM3yJsxvtGgX2ydKWH5I(dMgBXbxR)9zzS5H)GPX2SYQh(dMv9HFJn9H)A6LKXwZ16FFwgVXBS1CT(3NLH5nILsgM3yJsxvtGgX2yZd)btJn87dEnOiJnqchMl6pyAST9(GxdkILgCyPeIGkP8zzLAcJzzHVeflXggdZBSfM7P5CJnZyzwj1GdkYQ6Apduf2QUwx)9lrHTeWDDrreOXBelazyEJnkDvnbAeBJnp8hmn2WRSDdzSfke0u99bf9yJyPKXwyUNMZn2aHVTecZ2nKDOs)smlXZYqL(LywaEwaeGybjSOea1ydKWH5I(dMgBi1Xpl)oXci8zX097S87elLq8ZYFLelpKfheKLv(NMLFNyP0rglGRX)dMSCyw2V3YY2kB3qSmuPFjMLYL(Vi9rGS8qwk9pSZsjeMTBiwaxJ)hmnEJyfxdZBS5H)GPXwjeMTBiJnkDvnbAeBJ34n2WVH5nILsgM3yJsxvtGgX2yZd)btJn87dEnOiJnqchMl6pyASfNyILT3h8AqrS8qwaIOiwwrS87elXXH8s1lbPHf1vRXY1y5EwmbxAqwiKfDdXIk1GdXs7YdVFjkw(DILKq2ZsWXplWHLhYc4QmIfvQbhIfKcteqGiJTWCpnNBSnRKAWbfz)RKmbNScoKxQEjinwkDvnbYIcw6Xcf0xeMSxw9SalkyXmw6XspwuxTM9VsYeCYk4qEP6LG0yhQ0VeZs8S4H)GP104)ULqgfwpv)RKybWSuSvjwuWspwOG(IWK9YQk83zPRJfkOVimzVSIHAFyPRJfkOVimz1R0NAsi7zPplDDSOUAn7FLKj4KvWH8s1lbPXouPFjML4zXd)btl(9PDdzjKrH1t1)kjwamlfBvIffS0JfkOVimzVSQxPpS01Xcf0xeMSyO2NAsi7zPRJfkOVimz9SqnjK9S0NL(S01XIzSOUAn7FLKj4KvWH8s1lbPXUIyPplDDS0Jf1vRzdE9YGDfXsxhli85CvnzdWebeiQcs4czGL(SOGLaeQbHMsBaMiGar1FNQ4OBUhBhYblWIcwcqeu65BZd1(xBoXsFwuWspwmJLaebLE(wGkmNNS01Xsac1GqtPLkJGMOPQctq7qL(LywINfakl9zrbl9yrD1A2GxVmyxrS01XIzSeGqni0uAdE9YGDihSal9nEJybidZBSrPRQjqJyBS5H)GPXMd6r)HGQyt(uASfke0u99bf9yJyPKXwyUNMZn2mJfq4BDqp6peufBYNYkOx6Oi7FbGUeflkyXmw8WFW06GE0FiOk2KpLvqV0rr2lRn9HA)zrbl9yXmwaHV1b9O)qqvSjFkR7KRT)fa6suS01Xci8ToOh9hcQIn5tzDNCTDOs)smlXZcAyPplDDSacFRd6r)HGQyt(uwb9shfzXVhaIfGXsCzrblGW36GE0FiOk2KpLvqV0rr2Hk9lXSamwIllkybe(wh0J(dbvXM8PSc6LokY(xaOlrzSbs4WCr)btJT4etSedqp6peelBM8PKft7uYYVtdXYHzjHS4H)qqSGn5tjAzXXSO9NyXXSebX4tvtSatwWM8PKft3VZcGyboS0it0Wc(9aqywGdlWKfNL4cywWM8PKfmKLF3Fw(DILKmXc2KpLS4ZCiimlaKSWplE7PHLF3FwWM8PKfczr3qyJ3iwX1W8gBu6QAc0i2gBE4pyASfGjciqu93Pko6M7XgBGeomx0FW0yloXeMfKcteqGiwUglingiXCZalhMLvelWHLcWfl(qSas4cz4suSG0yGeZndSy6(DwqkmrabIyXtqwkaxS4dXIkPHMyXCkMLyGbqgBH5EAo3yZmwaN1bAtynaIzrbl9yPhli85CvnzdWebeiQcs4czGffSyglbiudcnL2GxVmyhYblWIcwmJLzLudoOiB0CLWb8CD1NGNxOgT0yFSu6QAcKLUowuxTMn41ld2vel9zrblo(hxxJGMOHfGPmlMtXSOGLESOUAnlf0xeMQ6v6JDOs)smlXZIsfZsxhlQRwZsb9fHPkgQ9XouPFjML4zrPIzPplDDSOcXywuWs7qT)1Hk9lXSamwuQywuWIzSeGqni0uAdE9YGDihSal9nEJyzogM3yJsxvtGgX2ydgzSHP3yZd)btJne(CUQMm2q46fzS1Jf1vRzhhbLWfU2gkJzb7qL(LywINf0WsxhlMXI6Q1SJJGs4cxBdLXSGDfXsFwuWIzSOUAn74iOeUW12qzmluXx2w66Eb8tZ52velkyPhlQRwZc0LGdbwPYiOjAkP8RusdQlMKDOs)smlaJfubqBPJmw6ZIcw6XI6Q1SuqFryQIHAFSdv6xIzjEwqfaTLoYyPRJf1vRzPG(IWuvVsFSdv6xIzjEwqfaTLoYyPRJLESyglQRwZsb9fHPQEL(yxrS01XIzSOUAnlf0xeMQyO2h7kIL(SOGfZy5DnLVfd14)cKLsxvtGS03ydKWH5I(dMgBifMG3FWKLgCyX1AwaHpMLF3FwkDGiml41qS87ubw8Hs09SmuBi8obYIPDkzbGGJGs4cZsCyOmMfyz3XSOjmMLF3twqdlykGzzOs)YlrXcCy53jwaQWCEYI6Q1y5WS4QW1ZYdzP5AnlWwJf4WINfyb9d6lctSCywCv46z5HSqil6gYydHp10ljJnq4xhc4UUHkP8XgVrSqJH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgB9yXmwuxTMLc6lctvmu7JDfXIcwmJf1vRzPG(IWuvVsFSRiw6ZsxhlVRP8TyOg)xGSu6QAc0ydKWH5I(dMgBifMG3FWKLF3Fwc7uaimlxJLcWfl(qSaxp(ajwOG(IWelpKfyQlWci8z53PHyboSCOs4qS87hMft3VZYguJ)lqgBi8PMEjzSbc)kC94dKQuqFryY4nIfaZW8gBu6QAc0i2gBE4pyASvcHz7gYylm3tZ5gBd1gcV7QAIffS0Jf1vRzPG(IWufd1(yhQ0VeZs8SmuPFjMLUowuxTMLc6lctv9k9XouPFjML4zzOs)smlDDSGWNZv1Kfe(v46XhivPG(IWel9zrbld1gcV7QAIffS8(GIE7FLu9HvWJyjEwucqSOGfpQg2PaqSOGfe(CUQMSGWVoeWDDdvs5Jn2cfcAQ((GIESrSuY4nIfa0W8gBu6QAc0i2gBE4pyASHxz7gYylm3tZ5gBd1gcV7QAIffS0Jf1vRzPG(IWufd1(yhQ0VeZs8SmuPFjMLUowuxTMLc6lctv9k9XouPFjML4zzOs)smlDDSGWNZv1Kfe(v46XhivPG(IWel9zrbld1gcV7QAIffS8(GIE7FLu9HvWJyjEwucqSOGfpQg2PaqSOGfe(CUQMSGWVoeWDDdvs5Jn2cfcAQ((GIESrSuY4nIfa1W8gBu6QAc0i2gBE4pyASHFsR9P20(qgBH5EAo3yBO2q4DxvtSOGLESOUAnlf0xeMQyO2h7qL(LywINLHk9lXS01XI6Q1SuqFryQQxPp2Hk9lXSepldv6xIzPRJfe(CUQMSGWVcxp(aPkf0xeMyPplkyzO2q4DxvtSOGL3hu0B)RKQpScEelXZIsamwuWIhvd7uaiwuWccFoxvtwq4xhc4UUHkP8XgBHcbnvFFqrp2iwkz8gXc4yyEJnkDvnbAeBJnp8hmn2AWjqvyRM(VgYydKWH5I(dMgBXjMyjoaJflWKLailMUFhUEwcEu0LOm2cZ90CUXMhvd7uaiJ3iwkvSH5n2O0v1eOrSn28WFW0yJkJGMOPQctqJnqchMl6pyASfNyIfKtxcoeilBr3CpMft3VZINfyrdtuSqjCHANfTJ)lrXc6h0xeMyXtqw(PalpKf9Lel3ZYkIft3VZcaAPX(WINGSG0yGeZndgBH5EAo3yRhl9yrD1AwkOVimvXqTp2Hk9lXSeplkvmlDDSOUAnlf0xeMQ6v6JDOs)smlXZIsfZsFwuWsac1GqtPn41ld2Hk9lXSeplXTywuWspwuxTMnAUs4aEUU6tWZluJwASpweUErSamwaK5umlDDSyglZkPgCqr2O5kHd456QpbpVqnAPX(yjG76IIiqw6ZsFw66yrD1A2O5kHd456QpbpVqnAPX(yr46fXs8kZcGaGfZsxhlbiudcnL2GxVmyhYblWIcwC8pUUgbnrdlXZcWPyJ3iwkPKH5n2O0v1eOrSn2GrgBy6n28WFW0ydHpNRQjJneUErgBMXc4SoqBcRbqmlkybHpNRQjBaSgGj49hmzrbl9yPhlbiudcnLwQmQWqUUchW0ZazhQ0VeZcWyrjagaKfaZspwusjwaEwMvsn4GIS4lBlDDVa(P5ClLUQMazPplkyHaURlkIaTuzuHHCDfoGPNbIL(S01XIJ)X11iOjAyjELzb4umlkyPhlMXY7AkFBBnfQWwL0RKSu6QAcKLUowuxTMn41ldwW14)btwINLaeQbHMsBBnfQWwL0RKSdv6xIzbWSaqzPplkybHpNRQj7VpNwxXebenvt(9SOGLESOUAnlqxcoeyLkJGMOPKYVsjnOUys2velDDSyglbick98TavyopzPplky59bf92)kP6dRGhXs8SOUAnBWRxgSGRX)dMSa8SuSfaYsxhlQqmMffS0ou7FDOs)smlaJf1vRzdE9YGfCn(FWKLUowcqeu65BZd1(xBoXsxhlQRwZQQHqq9c)2velkyrD1AwvnecQx43ouPFjMfGXI6Q1SbVEzWcUg)pyYcGzPhlahwaEwMvsn4GISrZvchWZ1vFcEEHA0sJ9Xsa31ffrGS0NL(SOGfZyrD1A2GxVmyxrSOGLESyglbick98T5HA)RnNyPRJLaeQbHMsBaMiGar1FNQ4OBUhBxrS01XIkeJzrblTd1(xhQ0VeZcWyjaHAqOP0gGjciqu93Pko6M7X2Hk9lXSaywayS01Xs7qT)1Hk9lXSGCzrjaAXSamwuxTMn41ldwW14)btw6BSbs4WCr)btJT4etSG0yGeZndSy6(DwqkmrabIqcYPlbhcKLTOBUhZINGSact09SarqJP5EIfa0sJ9Hf4WIPDkzj2AieuVWplMGlnileYIUHyrLAWHybPXajMBgyHqw0ne2ydHp10ljJTaynatW7pywXVXBelLaKH5n2O0v1eOrSn28WFW0yBCeucx4ABOmMfm2ajCyUO)GPXwCIjw(DIfasP83lmSy6(DwCwqAmqI5Mbw(D)z5Wj6EwAdSKfa0sJ9Xylm3tZ5gBQRwZg86Lb7qL(LywINfLqdlDDSOUAnBWRxgSGRX)dMSamwIBXSOGfe(CUQMSbWAaMG3FWSIFJ3iwkfxdZBSrPRQjqJyBSfM7P5CJne(CUQMSbWAaMG3FWSIFwuWspwmJf1vRzdE9YGfCn(FWKL4zjUfZsxhlMXsaIGspFlck)9cdl9zPRJf1vRzhhbLWfU2gkJzb7kIffSOUAn74iOeUW12qzmlyhQ0VeZcWyb4WcGzjatW192OHchMQU(qLLu(2)kPkcxViwaml9yXmwuxTMvvdHG6f(TRiwuWIzS8UMY3IFF0Wb0sPRQjqw6BS5H)GPXwG0e(pxxD9HklP8nEJyPK5yyEJnkDvnbAeBJTWCpnNBSHWNZv1KnawdWe8(dMv8BS5H)GPX2LbFs)pyA8gXsj0yyEJnkDvnbAeBJnyKXgMEJnp8hmn2q4Z5QAYydHRxKXMzSeGqni0uAdE9YGDihSalDDSygli85CvnzdWebeiQcs4czGffSeGiO0Z3MhQ9V2CILUowaN1bAtynaIn2ajCyUO)GPXgaP(CUQMyzHjqwGjlU6PV)iml)U)SyYZNLhYIkXc2rqGS0GdlingiXCZalyil)U)S87ubw8HYNfto(jqwaizHFwuPgCiw(DQ0ydHp10ljJnSJGQn4udE9YGXBelLaygM3yJsxvtGgX2yZd)btJT2AkuHTkPxjzSbs4WCr)btJT4etywIdq0NLRXYLS4jlOFqFryIfpbz5NJWS8qw0xsSCplRiwmD)olaOLg7dAzbPXajMBgyXtqwIbOh9hcILnt(uASfM7P5CJnkOVimzVS6zbwuWIhvd7uaiwuWI6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lIfGXcGmNIzrbl9ybe(wh0J(dbvXM8PSc6LokY(xaOlrXsxhlMXsaIGspFBsHbQHdil9zrbli85CvnzXocQ2Gtn41ldSOGLESOUAn74iOeUW12qzmlyhQ0VeZcWyb4WcaMLESGgwaEwMvsn4GIS4lBlDDVa(P5ClLUQMazPplkyrD1A2XrqjCHRTHYywWUIyPRJfZyrD1A2XrqjCHRTHYywWUIyPVXBelLaGgM3yJsxvtGgX2yZd)btJn87tZ1AJnqchMl6pyASfNyIfaYj97SS9(0CTMLObgWSCnw2EFAUwZYHt09SSIm2cZ90CUXM6Q1SWK(DCnIMaf9hmTRiwuWI6Q1S43NMR12HAdH3Dvnz8gXsjaQH5n2O0v1eOrSn2cZ90CUXM6Q1S43hnCaTdv6xIzbySGgwuWspwuxTMLc6lctvmu7JDOs)smlXZcAyPRJf1vRzPG(IWuvVsFSdv6xIzjEwqdl9zrblo(hxxJGMOHL4zb4uSXMh(dMgBbpdKUQUAnJn1vRvtVKm2WVpA4aA8gXsjGJH5n2O0v1eOrSn28WFW0yd)(GxdkYydKWH5I(dMgBXXvzeMLyGbqSOsn4qSGuyIaceXYcFjkw(DIfKcteqGiwcWe8(dMS8qwc7uaiwUglifMiGarSCyw8WVCTUalUkC9S8qwujwco(n2cZ90CUXwaIGspFBEO2)AZjwuWccFoxvt2amrabIQGeUqgyrblbiudcnL2amrabIQ)ovXr3Cp2ouPFjMfGXcAyrblMXc4SoqBcRbqmlkyHc6lct2lREwGffS44FCDncAIgwINfZPyJ3iwaQydZBSrPRQjqJyBS5H)GPXg(9P5ATXgiHdZf9hmn2ItmXY27tZ1AwmD)olBpP1(WsCCU2ZINGSKqw2EF0WbeTSyANswsilBVpnxRz5WSSIqllfGlw8Hy5swqVv6dlOFqFryILgCybGcymfWSahwEilrdmWcaAPX(WIPDkzXvHiiwaofZsmWaiwGdloyK)hcIfSjFkzz3XSaqbmMcywgQ0V8suSahwomlxYstFO2FllXc(el)U)SSsqAy53jwWEjXsaMG3FWeZY9OdZcyeMLKw)4AwEilBVpnxRzbCnxIIfacockHlmlXHHYywaTSyANswkaxOdKf8FAnlucYYkIft3VZcWPya74iwAWHLFNyr74NfuAOQRXwJTWCpnNBS9UMY3IFsR9Pcox7Tu6QAcKffSyglVRP8T43hnCaTu6QAcKffSOUAnl(9P5ATDO2q4DxvtSOGLESOUAnlf0xeMQ6v6JDOs)smlXZcaLffSqb9fHj7Lv9k9HffSOUAnB0CLWb8CD1NGNxOgT0yFSiC9IybySai0umlDDSOUAnB0CLWb8CD1NGNxOgT0yFSiC9IyjELzbqOPywuWIJ)X11iOjAyjEwaofZsxhlGW36GE0FiOk2KpLvqV0rr2Hk9lXSeplauw66yXd)btRd6r)HGQyt(uwb9shfzVS20hQ9NL(SOGLaeQbHMsBWRxgSdv6xIzjEwuQyJ3iwasjdZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn2ItmXY27dEnOiwaiN0VZs0adyw8eKfWvzelXadGyX0oLSG0yGeZndSahw(DIfasP83lmSOUAnwomlUkC9S8qwAUwZcS1yboSuaUqhilbpILyGbqgBH5EAo3ytD1Awys)oUg0Kpveh(GPDfXsxhlQRwZc0LGdbwPYiOjAkP8RusdQlMKDfXsxhlQRwZg86Lb7kIffS0Jf1vRzhhbLWfU2gkJzb7qL(LywaglOcG2shzSa8SeOtZspwC8pUUgbnrdliHL4wml9zbWSexwaEwExt5BtYuTectlLUQMazrblMXYSsQbhuKfFzBPR7fWpnNBP0v1eilkyrD1A2XrqjCHRTHYywWUIyPRJf1vRzdE9YGDOs)smlaJfubqBPJmwaEwc0PzPhlo(hxxJGMOHfKWsClML(S01XI6Q1SJJGs4cxBdLXSqfFzBPR7fWpnNBxrS01XIzSOUAn74iOeUW12qzmlyxrSOGfZyjaHAqOP0oockHlCTnugZc2HCWcS01XIzSeGiO0Z3IGYFVWWsFw66yXX)46Ae0enSeplaNIzrbluqFryYEz1ZcgVrSaeGmmVXgLUQManITXMh(dMgB43h8AqrgBGeomx0FW0yZ8tbwEilLoqel)oXIkHFwGnw2EF0WbKf1cSGFpa0LOy5EwwrSaCxxaiDbwUKfplWc6h0xeMyrD9SaGwASpSC48zXvHRNLhYIkXs0adbc0ylm3tZ5gBVRP8T43hnCaTu6QAcKffSyglZkPgCqr2)kjtWjRGd5LQxcsJLsxvtGSOGLESOUAnl(9rdhq7kILUowC8pUUgbnrdlXZcWPyw6ZIcwuxTMf)(OHdOf)EaiwaglXLffS0Jf1vRzPG(IWufd1(yxrS01XI6Q1SuqFryQQxPp2vel9zrblQRwZgnxjCapxx9j45fQrln2hlcxViwaglacawmlkyPhlbiudcnL2GxVmyhQ0VeZs8SOuXS01XIzSGWNZv1KnateqGOkiHlKbwuWsaIGspFBEO2)AZjw6B8gXcqX1W8gBu6QAc0i2gBWiJnm9gBE4pyASHWNZv1KXgcxViJnkOVimzVSQxPpSa8SaqzbjS4H)GPf)(0UHSeYOW6P6FLelaMfZyHc6lct2lR6v6dlapl9ybGXcGz5DnLVfdx6kSv)DQ2GdHFlLUQMazb4zjUS0NfKWIh(dMwtJ)7wczuy9u9VsIfaZsXwZbnSGewWrKwx3D8tSaywk2IgwaEwExt5Bt)xdHRQU2ZazP0v1eOXgiHdZf9hmn2qF8FL(tyw2HMyPCf2zjgyael(qSGYVKazjIgwWuaMGgBi8PMEjzS54iaenBuW4nIfGmhdZBSrPRQjqJyBS5H)GPXg(9bVguKXgiHdZf9hmn2IJRYiw2EFWRbfXYLS4SaabmMcSSb1(Wc6h0xeMqllGWeDplA6z5EwIgyGfa0sJ9HLE)U)SCyw29eutGSOwGf6(DAy53jw2EFAUwZI(sIf4WYVtSedmakEGtXSOVKyPbhw2EFWRbf1hTSact09SarqJP5EIfpzbGCs)olrdmWINGSOPNLFNyXvHiiw0xsSS7jOMyz79rdhqJTWCpnNBSzglZkPgCqr2)kjtWjRGd5LQxcsJLsxvtGSOGLESOUAnB0CLWb8CD1NGNxOgT0yFSiC9IybySaiayXS01XI6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lIfGXcGqtXSOGL31u(w8tATpvW5AVLsxvtGS0NffS0JfkOVimzVSIHAFyrblo(hxxJGMOHfaZccFoxvtwhhbGOzJcSa8SOUAnlf0xeMQyO2h7qL(LywamlGW32wtHkSvj9kj7FbGW1Hk9lzb4zbqw0Ws8SaqlMLUowOG(IWK9YQEL(WIcwC8pUUgbnrdlaMfe(CUQMSoocarZgfyb4zrD1AwkOVimv1R0h7qL(LywamlGW32wtHkSvj9kj7FbGW1Hk9lzb4zbqw0Ws8SaCkML(SOGfZyrD1Awys)oUgrtGI(dM2velkyXmwExt5BXVpA4aAP0v1eilkyPhlbiudcnL2GxVmyhQ0VeZs8SaazPRJfmCPvVe0(7ZP1vmrarJLsxvtGSOGf1vRz)9506kMiGOXIFpaelaJL4gxwaWS0JLzLudoOil(Y2sx3lGFAo3sPRQjqwaEwqdl9zrblTd1(xhQ0VeZs8SOuXfZIcwAhQ9VouPFjMfGXcGkUyw6ZIcw6Xsac1GqtPfOlbhcSIJU5ESDOs)smlXZcaKLUowmJLaebLE(wGkmNNS034nIfGqJH5n2O0v1eOrSn28WFW0yljt1simn2ajCyUO)GPXwCIjwaicHjMLlzb9wPpSG(b9fHjw8eKfSJGyb5mUUb44WsRzbGieMS0GdlingiXCZalEcYcYPlbhcKf0VmcAIMskFJTWCpnNBS1Jf1vRzPG(IWuvVsFSdv6xIzjEwiKrH1t1)kjw66yPhlHDFqrywuMfaXIcwgkS7dkQ(xjXcWybnS0NLUowc7(GIWSOmlXLL(SOGfpQg2PaqSOGfe(CUQMSyhbvBWPg86LbJ3iwacGzyEJnkDvnbAeBJTWCpnNBS1Jf1vRzPG(IWuvVsFSdv6xIzjEwiKrH1t1)kjwuWIzSeGiO0Z3cuH58KLUow6XI6Q1SaDj4qGvQmcAIMsk)kL0G6IjzxrSOGLaebLE(wGkmNNS0NLUow6Xsy3hueMfLzbqSOGLHc7(GIQ)vsSamwqdl9zPRJLWUpOimlkZsCzPRJf1vRzdE9YGDfXsFwuWIhvd7uaiwuWccFoxvtwSJGQn4udE9YalkyPhlQRwZoockHlCTnugZc2Hk9lXSamw6XcAybaZcGyb4zzwj1GdkYIVST019c4NMZTu6QAcKL(SOGf1vRzhhbLWfU2gkJzb7kILUowmJf1vRzhhbLWfU2gkJzb7kIL(gBE4pyAST76wTectJ3iwacaAyEJnkDvnbAeBJTWCpnNBS1Jf1vRzPG(IWuvVsFSdv6xIzjEwiKrH1t1)kjwuWIzSeGiO0Z3cuH58KLUow6XI6Q1SaDj4qGvQmcAIMsk)kL0G6IjzxrSOGLaebLE(wGkmNNS0NLUow6Xsy3hueMfLzbqSOGLHc7(GIQ)vsSamwqdl9zPRJLWUpOimlkZsCzPRJf1vRzdE9YGDfXsFwuWIhvd7uaiwuWccFoxvtwSJGQn4udE9YalkyPhlQRwZoockHlCTnugZc2Hk9lXSamwqdlkyrD1A2XrqjCHRTHYywWUIyrblMXYSsQbhuKfFzBPR7fWpnNBP0v1eilDDSyglQRwZoockHlCTnugZc2vel9n28WFW0yRT06AjeMgVrSaea1W8gBu6QAc0i2gBGeomx0FW0yloXelihq0NfyYsa0yZd)btJnt(mhCQWwL0RKmEJybiGJH5n2O0v1eOrSn28WFW0yd)(0UHm2ajCyUO)GPXwCIjw2EFA3qS8qwIgyGLnO2hwq)G(IWeAzbPXajMBgyz3XSOjmML)kjw(DpzXzb5y8FNfczuy9elAQ9SahwGPUalO3k9Hf0pOVimXYHzzfzSfM7P5CJnkOVimzVSQxPpS01Xcf0xeMSyO2NAsi7zPRJfkOVimz9SqnjK9S01XspwuxTM1KpZbNkSvj9kj7kILUowWrKwx3D8tSamwk2AoOHffSyglbick98TiO83lmS01XcoI066UJFIfGXsXwZHffSeGiO0Z3IGYFVWWsFwuWI6Q1SuqFryQQxPp2velDDS0Jf1vRzdE9YGDOs)smlaJfp8hmTMg)3TeYOW6P6FLelkyrD1A2GxVmyxrS034nIvCl2W8gBu6QAc0i2gBGeomx0FW0yloXelihJ)7Sa)DAmDyIft7xyNLdZYLSSb1(Wc6h0xeMqllingiXCZalWHLhYs0adSGER0hwq)G(IWKXMh(dMgBMg)3nEJyfxLmmVXgLUQManITXgiHdZf9hmn2IdUw)7ZYyZd)btJTzLvp8hmR6d)gB6d)10ljJTMR1)(SmEJ3ylAOaSu1FdZBelLmmVXMh(dMgBaDj4qGvC0n3Jn2O0v1eOrSnEJybidZBSrPRQjqJyBSbJm2W0BS5H)GPXgcFoxvtgBiC9Im2k2ydKWH5I(dMgBMFNybHpNRQjwomly6z5HSumlMUFNLeYc(9NfyYYctS8ZLarpgTSOelM2PKLFNyPDd(zbMelhMfyYYctOLfaXY1y53jwWuaMGSCyw8eKL4YY1yrf(7S4dzSHWNA6LKXgmRlmv)5sGO34nIvCnmVXgLUQManITXgmYyZbbn28WFW0ydHpNRQjJneUErgBkzSfM7P5CJTFUei6TVs2f2v1elky5NlbIE7RKnaHAqOP0cUg)pyASHWNA6LKXgmRlmv)5sGO34nIL5yyEJnkDvnbAeBJnyKXMdcAS5H)GPXgcFoxvtgBiC9Im2aKXwyUNMZn2(5sGO3(aYUWUQMyrbl)Cjq0BFazdqOgeAkTGRX)dMgBi8PMEjzSbZ6ct1FUei6nEJyHgdZBSrPRQjqJyBSbJm2CqqJnp8hmn2q4Z5QAYydHp10ljJnywxyQ(ZLarVXwyUNMZn2iG76IIiq7L4WSExvtvG7YZFvwbjexGyPRJfc4UUOic0sLrfgY1v4aMEgiw66yHaURlkIaTy4sRP)VevDwQfm2ajCyUO)GPXM53jmXYpxce9yw8HyjHpl(6l9)cUwxGfq6PWtGS4ywGjllmXc(9NLFUei6XwwIH2KxaZIdcEjkwuILsYtml)ovGftNwZIRn5fWSOsSenuJMHaz5sqkIsqkFwGnwWA4BSHW1lYytjJ3iwamdZBS5H)GPXwjeMaDzTbNsJnkDvnbAeBJ3iwaqdZBSrPRQjqJyBS5H)GPXMPX)DJn9LunaASPuXgBH5EAo3yRhluqFryYQxPp1Kq2ZsxhluqFryYEzfd1(WsxhluqFryYEzvf(7S01Xcf0xeMSEwOMeYEw6BSbs4WCr)btJna0qbh)Saiwqog)3zXtqwCw2EFWRbfXcmzzZ8Sy6(DwI1HA)zjo4elEcYsSHXW8Sahw2EFA3qSa)DAmDyY4nIfa1W8gBu6QAc0i2gBH5EAo3yRhluqFryYQxPp1Kq2ZsxhluqFryYEzfd1(WsxhluqFryYEzvf(7S01Xcf0xeMSEwOMeYEw6ZIcwIgcHvjRPX)DwuWIzSeneclGSMg)3n28WFW0yZ04)UXBelGJH5n2O0v1eOrSn2cZ90CUXMzSmRKAWbfzvDTNbQcBvxRR)(LOWwkDvnbYsxhlMXsaIGspFBEO2)AZjw66yXmwWrKwxFFqrp2IFFAUwZIYSOelDDSyglVRP8TP)RHWvvx7zGSu6QAcKLUow6Xcf0xeMSyO2NAsi7zPRJfkOVimzVSQxPpS01Xcf0xeMSxwvH)olDDSqb9fHjRNfQjHSNL(gBE4pyASHFFA3qgVrSuQydZBSrPRQjqJyBSfM7P5CJTzLudoOiRQR9mqvyR6AD93Vef2sPRQjqwuWsaIGspFBEO2)AZjwuWcoI0667dk6Xw87tZ1AwuMfLm28WFW0yd)(GxdkY4nEJ3ydbn4dMgXcqfdiLkgawma0yZKp5LOWgBihXaGqSm3yHCoaNfwm)oXYvgbNNLgCybDGuZx6hDSmeWDDdbYcgwsS4Rhw6pbYsy3tue2YfHExsSyoaCwqkmrqZtGSSDLiLfCH8DKXcYLLhYc6TCwapeh(GjlWiA8hoS0dj9zPNsiRVLlc9UKyXCa4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcAa4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcadGZcsHjcAEcKLTRePSGlKVJmwqUS8qwqVLZc4H4WhmzbgrJ)WHLEiPpl9aeY6B5IqVljwaGaCwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKybacWzbPWebnpbYc6(5sGO3QKfaGowEilO7NlbIE7RKfaGow6biK13YfHExsSaab4SGuyIGMNazbD)Cjq0BbKfaGowEilO7NlbIE7dilaaDS0dqiRVLlc9UKybGcWzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfGdaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwuQyaolifMiO5jqwq3SsQbhuKfaGowEilOBwj1GdkYcaSu6QAceDS0tjK13YfHExsSOKsaCwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKyrjabWzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEacz9TCrO3LelkbiaolifMiO5jqwq3pxce9wLSaa0XYdzbD)Cjq0BFLSaa0XspaHS(wUi07sIfLaeaNfKcte08eilO7NlbIElGSaa0XYdzbD)Cjq0BFazbaOJLEkHS(wUi07sIfLIlaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6biK13YfHExsSOuCb4SGuyIGMNazbD)Cjq0BvYcaqhlpKf09ZLarV9vYcaqhl9ucz9TCrO3LelkfxaolifMiO5jqwq3pxce9wazbaOJLhYc6(5sGO3(aYcaqhl9aeY6B5I4IqoIbaHyzUXc5CaolSy(DILRmcopln4Wc6Igkalv9hDSmeWDDdbYcgwsS4Rhw6pbYsy3tue2YfHExsSexaolifMiO5jqwq3pxce9wLSaa0XYdzbD)Cjq0BFLSaa0XspaHS(wUi07sIfZbGZcsHjcAEcKf09ZLarVfqwaa6y5HSGUFUei6TpGSaa0XspaHS(wUi07sIfGdaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwuQyaolifMiO5jqwq3SsQbhuKfaGowEilOBwj1GdkYcaSu6QAceDS0tjK13YfXfHCedacXYCJfY5aCwyX87elxzeCEwAWHf05qcDSmeWDDdbYcgwsS4Rhw6pbYsy3tue2YfHExsSOeaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow8Nf0hGm6XspLqwFlxe6DjXsCb4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcadGZcsHjcAEcKLTRePSGlKVJmwqUixwEilO3YzPecU0lmlWiA8hoS0d52NLEkHS(wUi07sIfagaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6biK13YfHExsSaab4SGuyIGMNazz7krkl4c57iJfKlYLLhYc6TCwkHGl9cZcmIg)Hdl9qU9zPNsiRVLlc9UKybacWzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfakaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaoaCwqkmrqZtGSSDLiLfCH8DKXcYLLhYc6TCwapeh(GjlWiA8hoS0dj9zPhGqwFlxe6DjXIsacGZcsHjcAEcKLTRePSGlKVJmwqUS8qwqVLZc4H4WhmzbgrJ)WHLEiPpl9ucz9TCrO3LelkbCa4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcGucGZcsHjcAEcKLTRePSGlKVJmwqUS8qwqVLZc4H4WhmzbgrJ)WHLEiPpl9ucz9TCrO3LelakUaCwqkmrqZtGSSDLiLfCH8DKXcYLLhYc6TCwapeh(GjlWiA8hoS0dj9zPhGqwFlxe6DjXcGIlaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaeAa4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXcGayaCwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKybqauaolifMiO5jqw2UsKYcUq(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0dqiRVLlc9UKybqahaolifMiO5jqw2UsKYcUq(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0tjK13YfXfHCedacXYCJfY5aCwyX87elxzeCEwAWHf01CT(3Nf6yziG76gcKfmSKyXxpS0FcKLWUNOiSLlc9UKybqaCwqkmrqZtGSSDLiLfCH8DKXcYLLhYc6TCwapeh(GjlWiA8hoS0dj9zPNsiRVLlIlc5igaeIL5glKZb4SWI53jwUYi48S0GdlOd)OJLHaURBiqwWWsIfF9Ws)jqwc7EIIWwUi07sIfLa4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXsCb4SGuyIGMNazbDZkPgCqrwaa6y5HSGUzLudoOilaWsPRQjq0XspLqwFlxe6DjXIskbWzbPWebnpbYY2vIuwWfY3rglixKllpKf0B5Sucbx6fMfyen(dhw6HC7ZspLqwFlxe6DjXIskbWzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfLayaCwqkmrqZtGSGUzLudoOilaaDS8qwq3SsQbhuKfayP0v1ei6yPNsiRVLlc9UKybqkbWzbPWebnpbYY2vIuwWfY3rglixwEilO3Yzb8qC4dMSaJOXF4WspK0NLEacz9TCrO3LelasjaolifMiO5jqwq3SsQbhuKfaGowEilOBwj1GdkYcaSu6QAceDS0tjK13YfHExsSaiabWzbPWebnpbYc6Mvsn4GISaa0XYdzbDZkPgCqrwaGLsxvtGOJLEkHS(wUi07sIfafxaolifMiO5jqw2UsKYcUq(oYyb5YYdzb9wolGhIdFWKfyen(dhw6HK(S0lUiRVLlc9UKybqMdaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6biK13YfHExsSaiagaNfKcte08eilOBwj1GdkYcaqhlpKf0nRKAWbfzbawkDvnbIow6PeY6B5IqVljwaeaeGZcsHjcAEcKf0nRKAWbfzbaOJLhYc6Mvsn4GISaalLUQMarhl9ucz9TCrCrihXaGqSm3yHCoaNfwm)oXYvgbNNLgCybDQq)rhldbCx3qGSGHLel(6HL(tGSe29efHTCrO3Lelkbqb4SGuyIGMNazz7krkl4c57iJfKllpKf0B5SaEio8btwGr04pCyPhs6ZsV4IS(wUi07sIfLaoaCwqkmrqZtGSSDLiLfCH8DKXcYLLhYc6TCwapeh(GjlWiA8hoS0dj9zPNsiRVLlIlYClJGZtGSaWyXd)btw0h(XwUiJnCefmILsfdiJTOb2onzSH8iplX21EgiwIJZ6a5IqEKNLIw6cSaarllaQyaPexexeYJ8SG0DprryaoxeYJ8SaGzjgGGeilBqTpSeBYlTCripYZcaMfKU7jkcKL3hu0xVglbhtywEilHcbnvFFqrp2YfH8iplaywaiqLqeeilRmPaHX(uGfe(CUQMWS07SKfTSeneIk(9bVguela44zjAiew87dEnOO(wUiKh5zbaZsmqapqwIgk44)suSGCm(VZY1y5E0Hz53jwmnWeflOFqFryYYfH8iplaywai6arSGuyIaceXYVtSSfDZ9ywCw03)AILs4qS00eYovnXsVRXsb4ILDhmr3ZY(9SCpl4RCPFpj4cRlWIP73zj2aKJH5zbWSGust4)CnlXqFOYskF0YY9OdKfmqxuFlxeYJ8SaGzbGOdeXsje)SGU2HA)Rdv6xIrhl4aL(CqmlEuKUalpKfvigZs7qT)ywGPUGLlIlc5rEwIrMW3FcKLy7ApdelXaaHESe8KfvILgCLGS4pl7)hHb4ibjQU2ZabGXxzWI6(9LQ9Gij2U2ZabG3UsKIKsq7(xQroB70KYQU2ZazFK9CrCrE4pyITrdfGLQ(RmqxcoeyfhDZ9yUiKNfZVtSGWNZv1elhMfm9S8qwkMft3VZsczb)(ZcmzzHjw(5sGOhJwwuIft7uYYVtS0Ub)SatILdZcmzzHj0YcGy5AS87elykatqwomlEcYsCz5ASOc)Dw8H4I8WFWeBJgkalv9hWkJee(CUQMqB6LKYWSUWu9NlbIE0IW1ls5I5I8WFWeBJgkalv9hWkJee(CUQMqB6LKYWSUWu9NlbIE0cJu2bbrlcxViLvcTxt5FUei6Tkzxyxvtk(5sGO3QKnaHAqOP0cUg)pyYf5H)Gj2gnuawQ6pGvgji85CvnH20ljLHzDHP6pxce9OfgPSdcIweUErkdi0EnL)5sGO3ci7c7QAsXpxce9wazdqOgeAkTGRX)dMCriplMFNWel)Cjq0JzXhILe(S4RV0)l4ADbwaPNcpbYIJzbMSSWel43Fw(5sGOhBzjgAtEbmloi4LOyrjwkjpXS87ubwmDAnlU2KxaZIkXs0qnAgcKLlbPikbP8zb2ybRHpxKh(dMyB0qbyPQ)awzKGWNZv1eAtVKugM1fMQ)Cjq0JwyKYoiiAr46fPSsO9Akta31ffrG2lXHz9UQMQa3LN)QScsiUa11ra31ffrGwQmQWqUUchW0Za11ra31ffrGwmCP10)xIQol1cCrE4pyITrdfGLQ(dyLrsjeMaDzTbNsUiKNfa0qbh)Saiwqog)3zXtqwCw2EFWRbfXcmzzZ8Sy6(DwI1HA)zjo4elEcYsSHXW8Sahw2EFA3qSa)DAmDyIlYd)btSnAOaSu1FaRmsmn(VJw9LunaQSsfJ2RPCpkOVimz1R0NAsi776OG(IWK9YkgQ9PRJc6lct2lRQWFVRJc6lctwplutczFFUip8hmX2OHcWsv)bSYiX04)oAVMY9OG(IWKvVsFQjHSVRJc6lct2lRyO2NUokOVimzVSQc)9UokOVimz9SqnjK99venecRswtJ)7kmlAiewaznn(VZf5H)Gj2gnuawQ6pGvgj43N2neAVMYMnRKAWbfzvDTNbQcBvxRR)(LOWDDMfGiO0Z3MhQ9V2CQRZmCeP113hu0JT43NMR1kRuxNzVRP8TP)RHWvvx7zGSu6QAcSRRhf0xeMSyO2NAsi776OG(IWK9YQEL(01rb9fHj7Lvv4V31rb9fHjRNfQjHSVpxKh(dMyB0qbyPQ)awzKGFFWRbfH2RP8SsQbhuKv11EgOkSvDTU(7xIcRiarqPNVnpu7FT5KcCeP113hu0JT43NMR1kRexexeYJ8SG(iJcRNazHqqtbw(RKy53jw8Wdhwomloc)0UQMSCrE4pyIvgd1(uvjVKlc5zzJEmlXaI(SatwIlGzX097W1Zc4CTNfpbzX097SS9(OHdilEcYcGamlWFNgthM4I8WFWedyLrccFoxvtOn9ss5dxDiHweUErkJJiTU((GIESf)(0CToELu0ZS31u(w87JgoGwkDvnb219UMY3IFsR9Pcox7Tu6QAcSFxhoI0667dk6Xw87tZ164bexeYZYg9ywcAYrqSyANsw2EFA3qSe8KL97zbqaML3hu0JzX0(f2z5WSmKMq45ZsdoS87elOFqFryILhYIkXs0qnAgcKfpbzX0(f2zPDAnnS8qwco(5I8WFWedyLrccFoxvtOn9ss5dxdAYrqOfHRxKY4isRRVpOOhBXVpTBO4vIlc5zjoXelXMgmnaDjkwmD)olingiXCZalWHfV90WcsHjciqelxYcsJbsm3mWf5H)GjgWkJevAW0a0LOq71uUNzbick98T5HA)RnN66mlaHAqOP0gGjciqu93Pko6M7X2vuFfQRwZg86Lb7qL(L44vcnkuxTMDCeucx4ABOmMfSdv6xIbM5OWSaebLE(weu(7fMUUaebLE(weu(7fgfQRwZg86Lb7ksH6Q1SJJGs4cxBdLXSGDfPON6Q1SJJGs4cxBdLXSGDOs)smWusjamAa(zLudoOil(Y2sx3lGFAoVRtD1A2GxVmyhQ0VedmLuQRtjKloI066UJFcykzrdA6ZfH8SaGGplMUFNfNfKgdKyUzGLF3FwoCIUNfNfa0sJ9HLObgyboSyANsw(DIL2HA)z5WS4QW1ZYdzHsqUip8hmXawzKeb)dMO9AkRUAnBWRxgSdv6xIJxj0OONzZkPgCqrw8LTLUUxa)0CExN6Q1SJJGs4cxBdLXSGDOs)smWucaQqD1A2XrqjCHRTHYywWUI631PcXyfTd1(xhQ0VedmaHgUiKNfK66Ws7pHzX0o970WYcFjkwqkmrabIyjHMyX0P1S4An0elfGlwEil4)0Awco(z53jwWEjXIxcx5ZcSXcsHjciqeGrAmqI5Mbwco(XCrE4pyIbSYibHpNRQj0MEjPCaMiGarvqcxidOfHRxKYb60961ou7FDOs)smawj0aGdqOgeAkTbVEzWouPFjUpYvjaAX9voqNUxV2HA)Rdv6xIbWkHgaSsaQyaCac1GqtPnateqGO6VtvC0n3JTdv6xI7JCvcGwCFfMn(bwjeu(wheeBjKD4h31fGqni0uAdE9YGDOs)sC8x(0eb1(tG12HA)Rdv6xI76cqOgeAkTbyIacev)DQIJU5ESDOs)sC8x(0eb1(tG12HA)Rdv6xIbWkvCxNzbick98T5HA)RnN668WFW0gGjciqu93Pko6M7XwWd7QAcKlc5zjoXeilpKfqs7fy53jwwyhfXcSXcsJbsm3mWIPDkzzHVeflGWLQMybMSSWelEcYs0qiO8zzHDuelM2PKfpzXbbzHqq5ZYHzXvHRNLhYc4rCrE4pyIbSYibHpNRQj0MEjPCaSgGj49hmrlcxViL79(GIE7FLu9HvWJIxj001n(bwjeu(wheeBVmE0uCFf961JaURlkIaTuzuHHCDfoGPNbsrVEbiudcnLwQmQWqUUchW0ZazhQ0VedmLayf31fGiO0Z3IGYFVWOiaHAqOP0sLrfgY1v4aMEgi7qL(LyGPeadac4EkPeWpRKAWbfzXx2w66Eb8tZ597RWSaeQbHMslvgvyixxHdy6zGSd5Gf63VRRhbCxxuebAXWLwt)FjQ6SulOONzbick98T5HA)RnN66cqOgeAkTy4sRP)VevDwQfQX1CqdaTyLSdv6xIbMskzo97311Zmc4UUOic0EjomR3v1uf4U88xLvqcXfOUUaeQbHMs7L4WSExvtvG7YZFvwbjexGSd5Gf6ROxac1GqtPvLgmnaDjk7qoyHUoZgpq2FGADFf96HWNZv1KfM1fMQ)Cjq0RSsDDi85CvnzHzDHP6pxce9kh3(k69ZLarVvj7qoyHAac1Gqtzx3pxce9wLSbiudcnL2Hk9lXXF5tteu7pbwBhQ9VouPFjgaRuX976q4Z5QAYcZ6ct1FUei6vgqk69ZLarVfq2HCWc1aeQbHMYUUFUei6TaYgGqni0uAhQ0Veh)LpnrqT)eyTDO2)6qL(LyaSsf3VRdHpNRQjlmRlmv)5sGOx5I73VRlarqPNVfOcZ5zFUip8hmXawzKGWNZv1eAtVKu(3NtRRyIaIMQj)E0IW1lszZWWLw9sq7VpNwxXebenwkDvnb211ou7FDOs)sC8aQ4I76uHySI2HA)Rdv6xIbgGqdG7zofdGvxTM93NtRRyIaIgl(9aqapG631PUAn7VpNwxXebenw87bGIpUauaCVzLudoOil(Y2sx3lGFAoh4rtFUiKNL4etSG(LrfgY1SaqEatpdelaQymfWSOsn4qS4SG0yGeZndSSWKLlYd)btmGvgjlmvVNkrB6LKYuzuHHCDfoGPNbcTxt5aeQbHMsBWRxgSdv6xIbgGkwrac1GqtPnateqGO6VtvC0n3JTdv6xIbgGkwrpe(CUQMS)(CADfteq0un5331PUAn7VpNwxXebenw87bGIpUfd4EZkPgCqrw8LTLUUxa)0CoWdW63VRtfIXkAhQ9VouPFjgyXfaYfH8SeNyILn4sRP)suSaqyPwGfagMcywuPgCiwCwqAmqI5MbwwyYYf5H)GjgWkJKfMQ3tLOn9sszmCP10)xIQol1cO9AkhGqni0uAdE9YGDOs)smWaykmlarqPNVfbL)EHrHzbick98T5HA)RnN66cqeu65BZd1(xBoPiaHAqOP0gGjciqu93Pko6M7X2Hk9lXadGPOhcFoxvt2amrabIQGeUqg66cqOgeAkTbVEzWouPFjgyaS(DDbick98TiO83lmk6z2SsQbhuKfFzBPR7fWpnNRiaHAqOP0g86Lb7qL(LyGbW66uxTMDCeucx4ABOmMfSdv6xIbMsMdG7HgGNaURlkIaTxI)zfE4GRGhIlPQkP19vOUAn74iOeUW12qzmlyxr976uHySI2HA)Rdv6xIbgGqdxKh(dMyaRmswyQEpvI20ljLVehM17QAQcCxE(RYkiH4ceAVMYQRwZg86Lb7qL(L44vcnk6z2SsQbhuKfFzBPR7fWpnN31PUAn74iOeUW12qzmlyhQ0VedmLaeG7fxGxD1AwvnecQx43UI6d4E9aGay0a8QRwZQQHqq9c)2vuFGNaURlkIaTxI)zfE4GRGhIlPQkP19vOUAn74iOeUW12qzmlyxr976uHySI2HA)Rdv6xIbgGqdxeYZI53pmlhMfNLX)DAyH0UkC8NyXKxGLhYsPdeXIR1SatwwyIf87pl)Cjq0Jz5HSOsSOVKazzfXIP73zbPXajMBgyXtqwqkmrabIyXtqwwyILFNybqjilyn8zbMSeaz5ASOc)Dw(5sGOhZIpelWKLfMyb)(ZYpxce9yUip8hmXawzKSWu9EQeJwSg(yL)5sGOxj0EnLr4Z5QAYcZ6ct1FUei6vgqkm7NlbIElGSd5GfQbiudcnLDD9q4Z5QAYcZ6ct1FUei6vwPUoe(CUQMSWSUWu9NlbIELJBFf9uxTMn41ld2vKIEMfGiO0Z3IGYFVW01PUAn74iOeUW12qzmlyhQ0Ved4EOb4Nvsn4GIS4lBlDDVa(P58(at5FUei6TkzvxTwfCn(FWuH6Q1SJJGs4cxBdLXSGDf11PUAn74iOeUW12qzmluXx2w66Eb8tZ52vu)UUaeQbHMsBWRxgSdv6xIbmGI)NlbIERs2aeQbHMsl4A8)GPIEMfGiO0Z3MhQ9V2CQRZme(CUQMSbyIacevbjCHm0xHzbick98Tavyop76cqeu65BZd1(xBoPaHpNRQjBaMiGarvqcxidkcqOgeAkTbyIacev)DQIJU5ESDfPWSaeQbHMsBWRxgSRif96PUAnlf0xeMQ6v6JDOs)sC8kvCxN6Q1SuqFryQIHAFSdv6xIJxPI7RWSzLudoOiRQR9mqvyR6AD93VefURRN6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqkJMUo1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGugG2VFxN6Q1SaDj4qGvQmcAIMsk)kL0G6Ijzxr976uHySI2HA)Rdv6xIbgGkURdHpNRQjlmRlmv)5sGOx5I5I8WFWedyLrYct17PsmAXA4Jv(NlbIEaH2RPmcFoxvtwywxyQ(ZLarVzkdifM9ZLarVvj7qoyHAac1GqtzxhcFoxvtwywxyQ(ZLarVYasrp1vRzdE9YGDfPONzbick98TiO83lmDDQRwZoockHlCTnugZc2Hk9lXaUhAa(zLudoOil(Y2sx3lGFAoVpWu(NlbIElGSQRwRcUg)pyQqD1A2XrqjCHRTHYywWUI66uxTMDCeucx4ABOmMfQ4lBlDDVa(P5C7kQFxxac1GqtPn41ld2Hk9lXagqX)ZLarVfq2aeQbHMsl4A8)GPIEMfGiO0Z3MhQ9V2CQRZme(CUQMSbyIacevbjCHm0xHzbick98Tavyopv0Zm1vRzdE9YGDf11zwaIGspFlck)9ct)UUaebLE(28qT)1Mtkq4Z5QAYgGjciqufKWfYGIaeQbHMsBaMiGar1FNQ4OBUhBxrkmlaHAqOP0g86Lb7ksrVEQRwZsb9fHPQEL(yhQ0VehVsf31PUAnlf0xeMQyO2h7qL(L44vQ4(kmBwj1GdkYQ6Apduf2QUwx)9lrH766PUAnRQR9mqvyR6AD93VefUM(VgYIFpaKYOPRtD1Awvx7zGQWw1166VFjkC1NGNKf)EaiLbO973VRtD1AwGUeCiWkvgbnrtjLFLsAqDXKSROUovigRODO2)6qL(LyGbOI76q4Z5QAYcZ6ct1FUei6vUyUiKNL4etywCTMf4VtdlWKLfMy5EQeZcmzjaYf5H)GjgWkJKfMQ3tLyUiKNL4ifoqIfp8hmzrF4NfvhtGSatwW3V8)Gjs0eQdZf5H)GjgWkJKzLvp8hmR6d)On9sszhsOf)ZfELvcTxtze(CUQMShU6qIlYd)btmGvgjZkRE4pyw1h(rB6LKYQq)rl(Nl8kReAVMYZkPgCqrwvx7zGQWw1166VFjkSLaURlkIa5I8WFWedyLrYSYQh(dMv9HF0MEjPm(5I4IqEwqQRdlT)eMft70Vtdl)oXsCCiVm4FyNgwuxTglMoTMLMR1SaBnwmD)(LS87eljHSNLGJFUip8hmXwhskJWNZv1eAtVKugCiVSA606AZ16kS1qlcxViL7PUAn7FLKj4KvWH8s1lbPXouPFjgyOcG2shzaUyRsDDQRwZ(xjzcozfCiVu9sqASdv6xIbMh(dMw87t7gYsiJcRNQ)vsaUyRsk6rb9fHj7Lv9k9PRJc6lctwmu7tnjK9DDuqFryY6zHAsi773xH6Q1S)vsMGtwbhYlvVeKg7ksXSsQbhuK9VsYeCYk4qEP6LG0WfH8SGuxhwA)jmlM2PFNgw2EFWRbfXYHzXeC(Dwco(Veflqe0WY27t7gILlzb9wPpSG(b9fHjUip8hmXwhsawzKGWNZv1eAtVKu(qLWHQ43h8AqrOfHRxKYMrb9fHj7Lvmu7JIE4isRRVpOOhBXVpTBO4rJI31u(wmCPRWw93PAdoe(Tu6QAcSRdhrAD99bf9yl(9PDdfpaSpxeYZsCIjwqkmrabIyX0oLS4plAcJz539Kf0umlXadGyXtqw0xsSSIyX097SG0yGeZndCrE4pyIToKaSYijateqGO6VtvC0n3Jr71u2mWzDG2ewdGyf96HWNZv1KnateqGOkiHlKbfMfGqni0uAdE9YGDihSqxN6Q1SbVEzWUI6RON6Q1SuqFryQQxPp2Hk9lXXdW66uxTMLc6lctvmu7JDOs)sC8aS(k6z2SsQbhuKv11EgOkSvDTU(7xIc31PUAnRQR9mqvyR6AD93VefUM(VgYIFpau8XTRtD1Awvx7zGQWw1166VFjkC1NGNKf)EaO4JB)UovigRODO2)6qL(LyGPuXkmlaHAqOP0g86Lb7qoyH(CriplXjMyjomugZcSy6(DwqAmqI5MbUip8hmXwhsawzKmockHlCTnugZcO9AkRUAnBWRxgSdv6xIJxj0WfH8SeNyILTv2UHy5swI8eKkValWKfpl87xIILF3Fw0hccZIsMdMcyw8eKfnHXSy6(DwkHdXY7dk6XS4jil(ZYVtSqjilWglolBqTpSG(b9fHjw8NfLmhwWuaZcCyrtymldv6xEjkwCmlpKLe(SS7iUeflpKLHAdH3zbCnxIIf0BL(Wc6h0xeM4I8WFWeBDibyLrcELTBi0gke0u99bf9yLvcTxt5Ed1gcV7QAQRtD1AwkOVimvXqTp2Hk9lXalUkOG(IWK9YkgQ9rXqL(LyGPK5O4DnLVfdx6kSv)DQ2GdHFlLUQMa7R49bf92)kP6dRGhfVsMdaghrAD99bf9yapuPFjwrpkOVimzVS6zHUUHk9lXadva0w6iRpxeYZcYjIIyzfXY27tZ1Aw8NfxRz5VscZYk1egZYcFjkwqVcbFCmlEcYY9SCywCv46z5HSenWalWHfn9S87el4ikCUMfp8hmzrFjXIkPHMyz3tqnXsCCiVu9sqAybMSaiwEFqrpMlYd)btS1HeGvgj43NMR1O9AkB27AkFl(jT2Nk4CT3sPRQjqf9uxTMf)(0CT2ouBi8URQjf9WrKwxFFqrp2IFFAUwdS421z2SsQbhuK9VsYeCYk4qEP6LG00VR7DnLVfdx6kSv)DQ2GdHFlLUQMavOUAnlf0xeMQyO2h7qL(LyGfxfuqFryYEzfd1(OqD1Aw87tZ1A7qL(LyGbavGJiTU((GIESf)(0CToELnN(k6z2SsQbhuKvxi4JJRnnr)LOQO0xzeM66(RKqUixZbnXRUAnl(9P5ATDOs)smGbuFfVpOO3(xjvFyf8O4rdxeYZcYX97SS9Kw7dlXX5ApllmXcmzjaYIPDkzzO2q4DxvtSOUEwW)P1SyYVNLgCyb9ke8XXSenWalEcYcimr3ZYctSOsn4qSG04i2YY2FAnllmXIk1GdXcsHjciqel4ldel)U)Sy60AwIgyGfpH)onSS9(0CTMlYd)btS1HeGvgj43NMR1O9Ak)UMY3IFsR9Pcox7Tu6QAcuH6Q1S43NMR12HAdH3DvnPONzZkPgCqrwDHGpoU20e9xIQIsFLryQR7Vsc5ICnh0eV50xX7dk6T)vs1hwbpk(4YfH8SGCC)olXXH8s1lbPHLfMyz79P5AnlpKfGikILvel)oXI6Q1yrTalUgdzzHVeflBVpnxRzbMSGgwWuaMGywGdlAcJzzOs)YlrXf5H)Gj26qcWkJe87tZ1A0EnLNvsn4GIS)vsMGtwbhYlvVeKgf4isRRVpOOhBXVpnxRJx54QONzQRwZ(xjzcozfCiVu9sqASRifQRwZIFFAUwBhQneE3v1uxxpe(CUQMSGd5LvtNwxBUwxHTMIEQRwZIFFAUwBhQ0VedS421HJiTU((GIESf)(0CToEaP4DnLVf)Kw7tfCU2BP0v1eOc1vRzXVpnxRTdv6xIbgA63VpxeYZcsDDyP9NWSyAN(DAyXzz79bVguellmXIPtRzj4lmXY27tZ1AwEilnxRzb2AOLfpbzzHjw2EFWRbfXYdzbiIIyjooKxQEjinSGFpaelRiUip8hmXwhsawzKGWNZv1eAtVKug)(0CTUAcMFT5ADf2AOfHRxKYo(hxxJGMOjEaAXa4EkvmWRUAn7FLKj4KvWH8s1lbPXIFpauFaCp1vRzXVpnxRTdv6xIb(4ICXrKwx3D8taVzVRP8T4N0AFQGZ1ElLUQMa7dG7fGqni0uAXVpnxRTdv6xIb(4ICXrKwx3D8ta)7AkFl(jT2Nk4CT3sPRQjW(a4EGW32wtHkSvj9kj7qL(LyGhn9v0tD1Aw87tZ1A7kQRlaHAqOP0IFFAUwBhQ0Ve3Nlc5zjoXelBVp41GIyX097SehhYlvVeKgwEilaruelRiw(DIf1vRXIP73HRNfneFjkw2EFAUwZYk6VsIfpbzzHjw2EFWRbfXcmzXCamlXggdZZc(9aqyww5FAwmhwEFqrpMlYd)btS1HeGvgj43h8AqrO9AkJWNZv1KfCiVSA606AZ16kS1uGWNZv1Kf)(0CTUAcMFT5ADf2AkmdHpNRQj7HkHdvXVp41GI666PUAnRQR9mqvyR6AD93VefUM(VgYIFpau8XTRtD1Awvx7zGQWw1166VFjkC1NGNKf)EaO4JBFf4isRRVpOOhBXVpnxRbM5OaHpNRQjl(9P5AD1em)AZ16kS14IqEwItmXc2KpLSGHS87(Zsb4Ifu0ZsPJmwwr)vsSOwGLf(suSCploMfT)eloMLiigFQAIfyYIMWyw(DpzjUSGFpaeMf4Wcajl8ZIPDkzjUaMf87bGWSqil6gIlYd)btS1HeGvgjoOh9hcQIn5tjAdfcAQ((GIESYkH2RPSz)fa6sukmZd)btRd6r)HGQyt(uwb9shfzVS20hQ9VRde(wh0J(dbvXM8PSc6LokYIFpaeWIRcq4BDqp6peufBYNYkOx6Oi7qL(LyGfxUiKNfacuBi8olaeHWSDdXY1ybPXajMBgy5WSmKdwaTS870qS4dXIMWyw(DpzbnS8(GIEmlxYc6TsFyb9d6lctSy6(Dw2GFCaTSOjmMLF3twuQywG)onMomXYLS4zbwq)G(IWelWHLvelpKf0WY7dk6XSOsn4qS4SGER0hwq)G(IWKLL4imr3ZYqTHW7SaUMlrXcYPlbhcKf0VmcAIMskFwwPMWywUKLnO2hwq)G(IWexKh(dMyRdjaRmskHWSDdH2qHGMQVpOOhRSsO9AkpuBi8URQjfVpOO3(xjvFyf8O471tjZbW9WrKwxFFqrp2IFFA3qapGaE1vRzPG(IWuvVsFSRO(9b8qL(L4(i3Ekb431u(230L1simXwkDvnb2xrVaeQbHMsBWRxgSd5Gfuyg4SoqBcRbqSIEi85CvnzdWebeiQcs4czORlaHAqOP0gGjciqu93Pko6M7X2HCWcDDMfGiO0Z3MhQ9V2CQFxhoI0667dk6Xw87t7gcy96bWaW9uxTMLc6lctv9k9XUIaEa1VpW3tja)UMY3(MUSwcHj2sPRQjW(9vygf0xeMSyO2NAsi7766rb9fHj7Lvmu7txxpkOVimzVSQc)9UokOVimzVSQxPp9vy27AkFlgU0vyR(7uTbhc)wkDvnb21PUAnB0CLWb8CD1NGNxOgT0yFSiC9IIxzaHMI7ROhoI0667dk6Xw87t7gcykvmW3tja)UMY3(MUSwcHj2sPRQjW(9v44FCDncAIM4rtXay1vRzXVpnxRTdv6xIbEawFf9mtD1AwGUeCiWkvgbnrtjLFLsAqDXKSROUokOVimzVSIHAF66mlarqPNVfOcZ5zFfMPUAn74iOeUW12qzmluXx2w66Eb8tZ52vexeYZsCIjwIdWyXcmzjaYIP73HRNLGhfDjkUip8hmXwhsawzK0GtGQWwn9FneAVMYEunStbG4I8WFWeBDibyLrccFoxvtOn9ss5aynatW7pywDiHweUErkBg4SoqBcRbqSce(CUQMSbWAaMG3FWurVEQRwZIFFAUwBxrDDVRP8T4N0AFQGZ1ElLUQMa76cqeu65BZd1(xBo1xrpZuxTMfd14)cKDfPWm1vRzdE9YGDfPONzVRP8TT1uOcBvsVsYsPRQjWUo1vRzdE9YGfCn(FWm(aeQbHMsBBnfQWwL0RKSdv6xIbmaTVce(CUQMS)(CADfteq0un53RONzbick98T5HA)RnN66cqOgeAkTbyIacev)DQIJU5ESDfPON6Q1S43NMR12Hk9lXadqDDM9UMY3IFsR9Pcox7Tu6QAcSFFfVpOO3(xjvFyf8O4vxTMn41ldwW14)btGVylaSFxx7qT)1Hk9lXatD1A2GxVmybxJ)hm7ZfH8SeNyIfKgdKyUzGfyYsaKLvQjmMfpbzrFjXY9SSIyX097SGuyIaceXf5H)Gj26qcWkJKaPj8FUU66dvws5J2RPmcFoxvt2aynatW7pywDiXf5H)Gj26qcWkJKld(K(FWeTxtze(CUQMSbWAaMG3FWS6qIlc5zjoXelOFze0enSeBycYcmzjaYIP73zz79P5AnlRiw8eKfSJGyPbhwaqln2hw8eKfKgdKyUzGlYd)btS1HeGvgjuze0envvycI2RPSkeJvC5tteu7pbwBhQ9VouPFjgykHMUUEQRwZgnxjCapxx9j45fQrln2hlcxViGbi0uCxN6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lkELbeAkUVc1vRzXVpnxRTRif9cqOgeAkTbVEzWouPFjoE0uCxh4SoqBcRbqCFUiKNfacuBi8olnTpelWKLvelpKL4YY7dk6XSy6(D46zbPXajMBgyrLUeflUkC9S8qwiKfDdXINGSKWNficAcEu0LO4I8WFWeBDibyLrc(jT2NAt7dH2qHGMQVpOOhRSsO9AkpuBi8URQjf)vs1hwbpkELqJcCeP113hu0JT43N2neWmhfEunStbGu0tD1A2GxVmyhQ0VehVsf31zM6Q1SbVEzWUI6ZfH8SeNyIL4ae9z5ASCj(ajw8Kf0pOVimXINGSOVKy5EwwrSy6(DwCwaqln2hwIgyGfpbzjgGE0Fiiw2m5tjxKh(dMyRdjaRmsARPqf2QKELeAVMYuqFryYEz1Zck8OAyNcaPqD1A2O5kHd456QpbpVqnAPX(yr46fbmaHMIv0de(wh0J(dbvXM8PSc6LokY(xaOlr11zwaIGspFBsHbQHdyxhoI0667dk6XXdO(k6PUAn74iOeUW12qzmlyhQ0VedmGdaUhAa(zLudoOil(Y2sx3lGFAoVVc1vRzhhbLWfU2gkJzb7kQRZm1vRzhhbLWfU2gkJzb7kQVIEMfGqni0uAdE9YGDf11PUAn7VpNwxXebenw87bGaMsOrr7qT)1Hk9lXadqfxSI2HA)Rdv6xIJxPIlURZmmCPvVe0(7ZP1vmrarJLsxvtG9v0ddxA1lbT)(CADfteq0yP0v1eyxxac1GqtPn41ld2Hk9lXXh3I7ZfH8SeNyIfNLT3NMR1SaqoPFNLObgyzLAcJzz79P5AnlhMfxpKdwGLvelWHLcWfl(qS4QW1ZYdzbIGMGhXsmWaiUip8hmXwhsawzKGFFAUwJ2RPS6Q1SWK(DCnIMaf9hmTRif9uxTMf)(0CT2ouBi8URQPUoh)JRRrqt0epWP4(CriplXXvzelXadGyrLAWHybPWebeiIft3VZY27tZ1Aw8eKLFNsw2EFWRbfXf5H)Gj26qcWkJe87tZ1A0EnLdqeu65BZd1(xBoPWS31u(w8tATpvW5AVLsxvtGk6HWNZv1KnateqGOkiHlKHUUaeQbHMsBWRxgSROUo1vRzdE9YGDf1xrac1GqtPnateqGO6VtvC0n3JTdv6xIbgQaOT0rgWhOt3ZX)46Ae0enix0uCFfQRwZIFFAUwBhQ0VedmZrHzGZ6aTjSgaXCrE4pyIToKaSYib)(GxdkcTxt5aebLE(28qT)1Mtk6HWNZv1KnateqGOkiHlKHUUaeQbHMsBWRxgSROUo1vRzdE9YGDf1xrac1GqtPnateqGO6VtvC0n3JTdv6xIbgatH6Q1S43NMR12vKckOVimzVS6zbfMHWNZv1K9qLWHQ43h8AqrkmdCwhOnH1aiMlc5zjoXelBVp41GIyX097S4jlaKt63zjAGbwGdlxJLcWf6azbIGMGhXsmWaiwmD)olfGRHLKq2ZsWXVLLyOXqwaxLrSedmaIf)z53jwOeKfyJLFNybGuk)9cdlQRwJLRXY27tZ1AwmbxAWeDplnxRzb2ASahwkaxS4dXcmzbqS8(GIEmxKh(dMyRdjaRmsWVp41GIq71uwD1Awys)oUg0Kpveh(GPDf111Zm87t7gY6r1WofasHzi85CvnzpujCOk(9bVguuxxp1vRzdE9YGDOs)smWqJc1vRzdE9YGDf111RN6Q1SbVEzWouPFjgyOcG2shzaFGoDph)JRRrqt0GCJBX9vOUAnBWRxgSROUo1vRzhhbLWfU2gkJzHk(Y2sx3lGFAo3ouPFjgyOcG2shzaFGoDph)JRRrqt0GCJBX9vOUAn74iOeUW12qzmluXx2w66Eb8tZ52vuFfbick98TiO83lm97ROhoI0667dk6Xw87tZ1AGf3Uoe(CUQMS43NMR1vtW8RnxRRWwRFFfMHWNZv1K9qLWHQ43h8Aqrk6z2SsQbhuK9VsYeCYk4qEP6LG001HJiTU((GIESf)(0CTgyXTpxeYZsCIjwaicHjMLlzzdQ9Hf0pOVimXINGSGDeelXHLwZcarimzPbhwqAmqI5MbUip8hmXwhsawzKKKPAjeMO9Ak3tD1AwkOVimvXqTp2Hk9lXXtiJcRNQ)vsDD9c7(GIWkdifdf29bfv)RKagA631f29bfHvoU9v4r1WofaIlYd)btS1HeGvgj7UUvlHWeTxt5EQRwZsb9fHPkgQ9XouPFjoEczuy9u9VsQRRxy3huewzaPyOWUpOO6FLeWqt)UUWUpOiSYXTVcpQg2Paqk6PUAn74iOeUW12qzmlyhQ0Vedm0OqD1A2XrqjCHRTHYywWUIuy2SsQbhuKfFzBPR7fWpnN31zM6Q1SJJGs4cxBdLXSGDf1NlYd)btS1HeGvgjTLwxlHWeTxt5EQRwZsb9fHPkgQ9XouPFjoEczuy9u9VssrVaeQbHMsBWRxgSdv6xIJhnf31fGqni0uAdWebeiQ(7ufhDZ9y7qL(L44rtX9766f29bfHvgqkgkS7dkQ(xjbm00VRlS7dkcRCC7RWJQHDkaKIEQRwZoockHlCTnugZc2Hk9lXadnkuxTMDCeucx4ABOmMfSRifMnRKAWbfzXx2w66Eb8tZ5DDMPUAn74iOeUW12qzmlyxr95IqEwItmXcYbe9zbMSG04ixKh(dMyRdjaRmsm5ZCWPcBvsVsIlc5zbPUoS0(tywmTt)onS8qwwyILT3N2nelxYYgu7dlM2VWolhMf)zbnS8(GIEmGvILgCyHqqtbwauXixwkD8ttbwGdlMdlBVp41GIyb9lJGMOPKYNf87bGWCrE4pyIToKaSYibHpNRQj0MEjPm(9PDdvVSIHAFqlcxViLXrKwxFFqrp2IFFA3qXBoaUPHWPxPJFAkur46fb8kvCXixavCFa30q40tD1Aw87dEnOOkvgbnrtjLFfd1(yXVhac5Ao95IqEwqQRdlT)eMft70VtdlpKfKJX)DwaxZLOyjomugZcCrE4pyIToKaSYibHpNRQj0MEjPSPX)96L12qzmlGweUErkReYfhrADD3XpbmabG7vSfqaFpCeP113hu0JT43N2neawP(aFpLa87AkFlgU0vyR(7uTbhc)wkDvnbc8kzrt)(aUyRsOb4vxTMDCeucx4ABOmMfSdv6xI5IqEwItmXcYX4)olxYYgu7dlOFqFryIf4WY1yjHSS9(0UHyX0P1S0UNLlFilingiXCZalEwOeoexKh(dMyRdjaRmsmn(VJ2RPCpkOVimz1R0NAsi776OG(IWK1Zc1Kq2RaHpNRQj7HRbn5iO(k69(GIE7FLu9HvWJI3C66OG(IWKvVsFQxwbuxx7qT)1Hk9lXatPI731PUAnlf0xeMQyO2h7qL(LyG5H)GPf)(0UHSeYOW6P6FLKc1vRzPG(IWufd1(yxrDDuqFryYEzfd1(OWme(CUQMS43N2nu9YkgQ9PRtD1A2GxVmyhQ0Vedmp8hmT43N2nKLqgfwpv)RKuygcFoxvt2dxdAYrqkuxTMn41ld2Hk9lXaJqgfwpv)RKuOUAnBWRxgSROUo1vRzhhbLWfU2gkJzb7ksbcFoxvtwtJ)71lRTHYywORZme(CUQMShUg0KJGuOUAnBWRxgSdv6xIJNqgfwpv)RK4IqEwItmXY27t7gILRXYLSGER0hwq)G(IWeAz5sw2GAFyb9d6lctSatwmhaZY7dk6XSahwEilrdmWYgu7dlOFqFryIlYd)btS1HeGvgj43N2nexeYZsCW16FFwCrE4pyIToKaSYizwz1d)bZQ(WpAtVKuU5A9VplUiUiKNL4WqzmlWIP73zbPXajMBg4I8WFWeBvH(R84iOeUW12qzmlG2RPS6Q1SbVEzWouPFjoELqdxeYZsCIjwIbOh9hcILnt(uYIPDkzXFw0egZYV7jlMdlXggdZZc(9aqyw8eKLhYYqTHW7S4SamLbel43daXIJzr7pXIJzjcIXNQMyboS8xjXY9SGHSCpl(mhccZcajl8ZI3EAyXzjUaMf87bGyHqw0neMlYd)btSvf6pGvgjoOh9hcQIn5tjAdfcAQ((GIESYkH2RPS6Q1SQU2ZavHTQR11F)su4A6)Ail(9aqadGQqD1Awvx7zGQWw1166VFjkC1NGNKf)EaiGbqv0Zmq4BDqp6peufBYNYkOx6Oi7FbGUeLcZ8WFW06GE0FiOk2KpLvqV0rr2lRn9HA)v0Zmq4BDqp6peufBYNY6o5A7FbGUevxhi8ToOh9hcQIn5tzDNCTDOs)sC8XTFxhi8ToOh9hcQIn5tzf0lDuKf)EaiGfxfGW36GE0FiOk2KpLvqV0rr2Hk9lXadnkaHV1b9O)qqvSjFkRGEPJIS)fa6su95IqEwItmXcsHjciqelMUFNfKgdKyUzGft7uYseeJpvnXINGSa)DAmDyIft3VZIZsSHXW8SOUAnwmTtjlGeUqgUefxKh(dMyRk0FaRmscWebeiQ(7ufhDZ9y0EnLndCwhOnH1aiwrVEi85CvnzdWebeiQcs4czqHzbiudcnL2GxVmyhYbl01PUAnBWRxgSRO(k6PUAnRQR9mqvyR6AD93VefUM(VgYIFpaKYa0Uo1vRzvDTNbQcBvxRR)(LOWvFcEsw87bGugG2VRtfIXkAhQ9VouPFjgykvCFUiKNL4ae9zXXS87elTBWplOcGSCjl)oXIZsSHXW8Sy6sqOjwGdlMUFNLFNyb5uH58Kf1vRXcCyX097S4SaqbmMcSedqp6peelBM8PKfpbzXKFpln4WcsJbsm3mWY1y5EwmbZNfvILvelok)swuPgCiw(DILailhML2LhENa5I8WFWeBvH(dyLrsBnfQWwL0RKq71uUxVEQRwZQ6Apduf2QUwx)9lrHRP)RHS43dafpaRRtD1Awvx7zGQWw1166VFjkC1NGNKf)EaO4by9v0ZSaebLE(weu(7fMUoZuxTMDCeucx4ABOmMfSRO(9v0dCwhOnH1aiURlaHAqOP0g86Lb7qL(L44rtXDD9cqeu65BZd1(xBoPiaHAqOP0gGjciqu93Pko6M7X2Hk9lXXJMI73VFxxpq4BDqp6peufBYNYkOx6Oi7qL(L44bOkcqOgeAkTbVEzWouPFjoELkwraIGspFBsHbQHdy)UovigR4YNMiO2FcS2ou7FDOs)smWaOkmlaHAqOP0g86Lb7qoyHUUaebLE(wGkmNNkuxTMfOlbhcSsLrqt0us5BxrDDbick98TiO83lmkuxTMDCeucx4ABOmMfSdv6xIbgWrH6Q1SJJGs4cxBdLXSGDfXfH8SGupdKMLT3hnCazX097S4SKKjwInmgMNf1vRXINGSG0yGeZndSC4eDplUkC9S8qwujwwycKlYd)btSvf6pGvgjbpdKUQUAn0MEjPm(9rdhq0EnL7PUAnRQR9mqvyR6AD93VefUM(VgYouPFjoEaOfnDDQRwZQ6Apduf2QUwx)9lrHR(e8KSdv6xIJhaArtFf9cqOgeAkTbVEzWouPFjoEayxxVaeQbHMslvgbnrtvfMG2Hk9lXXdavyM6Q1SaDj4qGvQmcAIMsk)kL0G6Ijzxrkcqeu65BbQWCE2VVch)JRRrqt0eVYXTyUiKNL44QmILT3h8AqrywmD)ololXggdZZI6Q1yrD9SKWNft7uYseeQVefln4WcsJbsm3mWcCyb50LGdbYYw0n3J5I8WFWeBvH(dyLrc(9bVgueAVMY9uxTMv11EgOkSvDTU(7xIcxt)xdzXVhakEa11PUAnRQR9mqvyR6AD93VefU6tWtYIFpau8aQVIEbick98T5HA)RnN66cqOgeAkTbVEzWouPFjoEayxNzi85CvnzdG1ambV)GPcZcqeu65BbQWCE211laHAqOP0sLrqt0uvHjODOs)sC8aqfMPUAnlqxcoeyLkJGMOPKYVsjnOUys2vKIaebLE(wGkmNN97RONzGW32wtHkSvj9kj7FbGUevxNzbiudcnL2GxVmyhYbl01zwac1GqtPnateqGO6VtvC0n3JTd5Gf6ZfH8SehxLrSS9(GxdkcZIk1GdXcsHjciqexKh(dMyRk0FaRmsWVp41GIq71uUxac1GqtPnateqGO6VtvC0n3JTdv6xIbgAuyg4SoqBcRbqSIEi85CvnzdWebeiQcs4czORlaHAqOP0g86Lb7qL(LyGHM(kq4Z5QAYgaRbycE)bZ(kmde(22AkuHTkPxjz)la0LOueGiO0Z3MhQ9V2CsHzGZ6aTjSgaXkOG(IWK9YQNfu44FCDncAIM4nNI5IqEwIJWeDplGWNfW1Cjkw(DIfkbzb2ybGGJGs4cZsCyOmMfqllGR5suSa0LGdbYcvgbnrtjLplWHLlz53jw0o(zbvaKfyJfpzb9d6lctCrE4pyITQq)bSYibHpNRQj0MEjPmi8RdbCx3qLu(y0IW1ls5EQRwZoockHlCTnugZc2Hk9lXXJMUoZuxTMDCeucx4ABOmMfSRO(k6PUAnlqxcoeyLkJGMOPKYVsjnOUys2Hk9lXadva0w6iRVIEQRwZsb9fHPkgQ9XouPFjoEubqBPJSUo1vRzPG(IWuvVsFSdv6xIJhva0w6iRpxKh(dMyRk0FaRmsWRSDdH2qHGMQVpOOhRSsO9AkpuBi8URQjfVpOO3(xjvFyf8O4vcGPWJQHDkaKce(CUQMSGWVoeWDDdvs5J5I8WFWeBvH(dyLrsjeMTBi0gke0u99bf9yLvcTxt5HAdH3DvnP49bf92)kP6dRGhfVsX1IgfEunStbGuGWNZv1Kfe(1HaURBOskFmxKh(dMyRk0FaRmsWpP1(uBAFi0gke0u99bf9yLvcTxt5HAdH3DvnP49bf92)kP6dRGhfVsamapuPFjwHhvd7uaifi85CvnzbHFDiG76gQKYhZfH8SehGXIfyYsaKft3Vdxplbpk6suCrE4pyITQq)bSYiPbNavHTA6)Ai0EnL9OAyNcaXfH8SG(Lrqt0WsSHjilM2PKfxfUEwEilu(0WIZssMyj2WyyEwmDji0elEcYc2rqS0GdlingiXCZaxKh(dMyRk0FaRmsOYiOjAQQWeeTxt5EuqFryYQxPp1Kq231rb9fHjlgQ9PMeY(UokOVimz9SqnjK9DDQRwZQ6Apduf2QUwx)9lrHRP)RHSdv6xIJhaArtxN6Q1SQU2ZavHTQR11F)su4Qpbpj7qL(L44bGw00154FCDncAIM4bofRiaHAqOP0g86Lb7qoybfMboRd0MWAae3xrVaeQbHMsBWRxgSdv6xIJpUf31fGqni0uAdE9YGDihSq)UovigR4YNMiO2FcS2ou7FDOs)smWuQyUiKNL4ae9zzou7plQudoell8LOybPXGlYd)btSvf6pGvgjT1uOcBvsVscTxt5aeQbHMsBWRxgSd5GfuGWNZv1KnawdWe8(dMk654FCDncAIM4bofRWSaebLE(28qT)1MtDDbick98T5HA)RnNu44FCDncAIgGzof3xHzbick98TiO83lmk6zwaIGspFBEO2)AZPUUaeQbHMsBaMiGar1FNQ4OBUhBhYbl0xHzGZ6aTjSgaXCriplingiXCZalM2PKf)zb4umGzjgyael9GJgAIgw(DpzXCkMLyGbqSy6(DwqkmrabI6ZIP73HRNfneFjkw(RKy5swITgcb1l8ZINGSOVKyzfXIP73zbPWebeiILRXY9SyYXSas4czGa5I8WFWeBvH(dyLrccFoxvtOn9ss5aynatW7pywvH(JweUErkBg4SoqBcRbqSce(CUQMSbWAaMG3FWurVEo(hxxJGMOjEGtXk6PUAnlqxcoeyLkJGMOPKYVsjnOUys2vuxNzbick98Tavyop731PUAnRQgcb1l8BxrkuxTMvvdHG6f(Tdv6xIbM6Q1SbVEzWcUg)py2VR7YNMiO2FcS2ou7FDOs)smWuxTMn41ldwW14)bZUUaebLE(28qT)1Mt9v0ZSaebLE(28qT)1MtDD9C8pUUgbnrdWmNI76aHVTTMcvyRs6vs2)caDjQ(k6HWNZv1KnateqGOkiHlKHUUaeQbHMsBaMiGar1FNQ4OBUhBhYbl0VpxKh(dMyRk0FaRmscKMW)56QRpuzjLpAVMYi85CvnzdG1ambV)Gzvf6pxKh(dMyRk0FaRmsUm4t6)bt0EnLr4Z5QAYgaRbycE)bZQk0FUiKNf0h)xP)eMLDOjwkxHDwIbgaXIpelO8ljqwIOHfmfGjixKh(dMyRk0FaRmsq4Z5QAcTPxsk74iaenBuaTiC9IuMc6lct2lR6v6dWdqrUE4pyAXVpTBilHmkSEQ(xjbyZOG(IWK9YQEL(a89aya(DnLVfdx6kSv)DQ2GdHFlLUQMab(42h56H)GP104)ULqgfwpv)RKaCXwaHCXrKwx3D8tCriplXXvzelBVp41GIWSyANsw(DIL2HA)z5WS4QW1ZYdzHsq0YsBOmMfy5WS4QW1ZYdzHsq0Ysb4IfFiw8NfGtXaMLyGbqSCjlEYc6h0xeMqllingiXCZalAh)yw8e(70WcafWykGzboSuaUyXeCPbzbIGMGhXsjCiw(DpzH7uQywIbgaXIPDkzPaCXIj4sdMO7zz79bVguelj0exKh(dMyRk0FaRmsWVp41GIq71uUNkeJvC5tteu7pbwBhQ9VouPFjgyMtxxp1vRzhhbLWfU2gkJzb7qL(LyGHkaAlDKb8b609C8pUUgbnrdYnUf3xH6Q1SJJGs4cxBdLXSGDf1VFxxph)JRRrqt0aye(CUQMSoocarZgfaE1vRzPG(IWufd1(yhQ0Vedyq4BBRPqf2QKELK9Vaq46qL(LapGSOjELuQ4Uoh)JRRrqt0aye(CUQMSoocarZgfaE1vRzPG(IWuvVsFSdv6xIbmi8TT1uOcBvsVsY(xaiCDOs)sGhqw0eVskvCFfuqFryYEz1Zck6zM6Q1SbVEzWUI66m7DnLVf)(OHdOLsxvtG9v0RNzbiudcnL2GxVmyxrDDbick98Tavyopvywac1GqtPLkJGMOPQctq7kQFxxaIGspFBEO2)AZP(k6zwaIGspFlck)9ctxNzQRwZg86Lb7kQRZX)46Ae0enXdCkUFxxV31u(w87JgoGwkDvnbQqD1A2GxVmyxrk6PUAnl(9rdhql(9aqalUDDo(hxxJGMOjEGtX9731PUAnBWRxgSRifMPUAn74iOeUW12qzmlyxrkm7DnLVf)(OHdOLsxvtGCriplXjMybGieMywUKf0BL(Wc6h0xeMyXtqwWocIfKZ46gGJdlTMfaIqyYsdoSG0yGeZndCrE4pyITQq)bSYijjt1simr71uUN6Q1SuqFryQQxPp2Hk9lXXtiJcRNQ)vsDD9c7(GIWkdifdf29bfv)RKagA631f29bfHvoU9v4r1WofaIlYd)btSvf6pGvgj7UUvlHWeTxt5EQRwZsb9fHPQEL(yhQ0VehpHmkSEQ(xjPOxac1GqtPn41ld2Hk9lXXJMI76cqOgeAkTbyIacev)DQIJU5ESDOs)sC8OP4(DD9c7(GIWkdifdf29bfv)RKagA631f29bfHvoU9v4r1WofaIlYd)btSvf6pGvgjTLwxlHWeTxt5EQRwZsb9fHPQEL(yhQ0VehpHmkSEQ(xjPOxac1GqtPn41ld2Hk9lXXJMI76cqOgeAkTbyIacev)DQIJU5ESDOs)sC8OP4(DD9c7(GIWkdifdf29bfv)RKagA631f29bfHvoU9v4r1WofaIlc5zb5aI(SatwcGCrE4pyITQq)bSYiXKpZbNkSvj9kjUiKNL4etSS9(0UHy5HSenWalBqTpSG(b9fHjwGdlM2PKLlzbM6cSGER0hwq)G(IWelEcYYctSGCarFwIgyaZY1y5swqVv6dlOFqFryIlYd)btSvf6pGvgj43N2neAVMYuqFryYEzvVsF66OG(IWKfd1(utczFxhf0xeMSEwOMeY(Uo1vRzn5ZCWPcBvsVsYUIuOUAnlf0xeMQ6v6JDf111tD1A2GxVmyhQ0Vedmp8hmTMg)3TeYOW6P6FLKc1vRzdE9YGDf1NlYd)btSvf6pGvgjMg)35I8WFWeBvH(dyLrYSYQh(dMv9HF0MEjPCZ16FFwCrCriplBVp41GIyPbhwkHiOskFwwPMWyww4lrXsSHXW8CrE4pyITnxR)9zPm(9bVgueAVMYMnRKAWbfzvDTNbQcBvxRR)(LOWwc4UUOicKlc5zbPo(z53jwaHplMUFNLFNyPeIFw(RKy5HS4GGSSY)0S87elLoYybCn(FWKLdZY(9ww2wz7gILHk9lXSuU0)fPpcKLhYsP)HDwkHWSDdXc4A8)GjxKh(dMyBZ16FFwawzKGxz7gcTHcbnvFFqrpwzLq71uge(2simB3q2Hk9lXXpuPFjg4beGqUkbq5I8WFWeBBUw)7ZcWkJKsimB3qCrCriplXjMyz79bVguelpKfGikILvel)oXsCCiVu9sqAyrD1ASCnwUNftWLgKfczr3qSOsn4qS0U8W7xIILFNyjjK9SeC8ZcCy5HSaUkJyrLAWHybPWebeiIlYd)btSf)kJFFWRbfH2RP8SsQbhuK9VsYeCYk4qEP6LG0OOhf0xeMSxw9SGcZ61tD1A2)kjtWjRGd5LQxcsJDOs)sC8E4pyAnn(VBjKrH1t1)kjaxSvjf9OG(IWK9YQk8376OG(IWK9YkgQ9PRJc6lctw9k9PMeY((DDQRwZ(xjzcozfCiVu9sqASdv6xIJ3d)btl(9PDdzjKrH1t1)kjaxSvjf9OG(IWK9YQEL(01rb9fHjlgQ9PMeY(UokOVimz9SqnjK99731zM6Q1S)vsMGtwbhYlvVeKg7kQFxxp1vRzdE9YGDf11HWNZv1KnateqGOkiHlKH(kcqOgeAkTbyIacev)DQIJU5ESDihSGIaebLE(28qT)1Mt9v0ZSaebLE(wGkmNNDDbiudcnLwQmcAIMQkmbTdv6xIJhG2xrp1vRzdE9YGDf11zwac1GqtPn41ld2HCWc95IqEwItmXsma9O)qqSSzYNswmTtjl)onelhMLeYIh(dbXc2KpLOLfhZI2FIfhZseeJpvnXcmzbBYNswmD)olaIf4WsJmrdl43daHzboSatwCwIlGzbBYNswWqw(D)z53jwsYelyt(uYIpZHGWSaqYc)S4TNgw(D)zbBYNswiKfDdH5I8WFWeBXpGvgjoOh9hcQIn5tjAdfcAQ((GIESYkH2RPSzGW36GE0FiOk2KpLvqV0rr2)caDjkfM5H)GP1b9O)qqvSjFkRGEPJISxwB6d1(RONzGW36GE0FiOk2KpL1DY12)caDjQUoq4BDqp6peufBYNY6o5A7qL(L44rt)Uoq4BDqp6peufBYNYkOx6Oil(9aqalUkaHV1b9O)qqvSjFkRGEPJISdv6xIbwCvacFRd6r)HGQyt(uwb9shfz)la0LO4IqEwItmHzbPWebeiILRXcsJbsm3mWYHzzfXcCyPaCXIpelGeUqgUeflingiXCZalMUFNfKcteqGiw8eKLcWfl(qSOsAOjwmNIzjgyaexKh(dMyl(bSYijateqGO6VtvC0n3Jr71u2mWzDG2ewdGyf96HWNZv1KnateqGOkiHlKbfMfGqni0uAdE9YGDihSGcZMvsn4GISrZvchWZ1vFcEEHA0sJ9PRtD1A2GxVmyxr9v44FCDncAIgGPS5uSIEQRwZsb9fHPQEL(yhQ0VehVsf31PUAnlf0xeMQyO2h7qL(L44vQ4(DDQqmwr7qT)1Hk9lXatPIvywac1GqtPn41ld2HCWc95IqEwqkmbV)Gjln4WIR1SacFml)U)Su6arywWRHy53PcS4dLO7zzO2q4DcKft7uYcabhbLWfML4WqzmlWYUJzrtyml)UNSGgwWuaZYqL(LxIIf4WYVtSauH58Kf1vRXYHzXvHRNLhYsZ1AwGTglWHfplWc6h0xeMy5WS4QW1ZYdzHqw0nexKh(dMyl(bSYibHpNRQj0MEjPmi8RdbCx3qLu(y0IW1ls5EQRwZoockHlCTnugZc2Hk9lXXJMUoZuxTMDCeucx4ABOmMfSRO(kmtD1A2XrqjCHRTHYywOIVST019c4NMZTRif9uxTMfOlbhcSsLrqt0us5xPKguxmj7qL(LyGHkaAlDK1xrp1vRzPG(IWufd1(yhQ0VehpQaOT0rwxN6Q1SuqFryQQxPp2Hk9lXXJkaAlDK111Zm1vRzPG(IWuvVsFSROUoZuxTMLc6lctvmu7JDf1xHzVRP8TyOg)xGSu6QAcSpxeYZcsHj49hmz539NLWofacZY1yPaCXIpelW1JpqIfkOVimXYdzbM6cSacFw(DAiwGdlhQeoel)(HzX097SSb14)cexKh(dMyl(bSYibHpNRQj0MEjPmi8RW1JpqQsb9fHj0IW1ls5EMPUAnlf0xeMQyO2h7ksHzQRwZsb9fHPQEL(yxr976Ext5BXqn(VazP0v1eixKh(dMyl(bSYiPecZ2neAdfcAQ((GIESYkH2RP8qTHW7UQMu0tD1AwkOVimvXqTp2Hk9lXXpuPFjURtD1AwkOVimv1R0h7qL(L44hQ0Ve31HWNZv1Kfe(v46XhivPG(IWuFfd1gcV7QAsX7dk6T)vs1hwbpkELaKcpQg2Paqkq4Z5QAYcc)6qa31nujLpMlYd)btSf)awzKGxz7gcTHcbnvFFqrpwzLq71uEO2q4Dxvtk6PUAnlf0xeMQyO2h7qL(L44hQ0Ve31PUAnlf0xeMQ6v6JDOs)sC8dv6xI76q4Z5QAYcc)kC94dKQuqFryQVIHAdH3DvnP49bf92)kP6dRGhfVsasHhvd7uaifi85CvnzbHFDiG76gQKYhZf5H)Gj2IFaRmsWpP1(uBAFi0gke0u99bf9yLvcTxt5HAdH3DvnPON6Q1SuqFryQIHAFSdv6xIJFOs)sCxN6Q1SuqFryQQxPp2Hk9lXXpuPFjURdHpNRQjli8RW1JpqQsb9fHP(kgQneE3v1KI3hu0B)RKQpScEu8kbWu4r1WofasbcFoxvtwq4xhc4UUHkP8XCriplXjMyjoaJflWKLailMUFhUEwcEu0LO4I8WFWeBXpGvgjn4eOkSvt)xdH2RPShvd7uaiUiKNL4etSGC6sWHazzl6M7XSy6(Dw8SalAyIIfkHlu7SOD8Fjkwq)G(IWelEcYYpfy5HSOVKy5EwwrSy6(Dwaqln2hw8eKfKgdKyUzGlYd)btSf)awzKqLrqt0uvHjiAVMY96PUAnlf0xeMQyO2h7qL(L44vQ4Uo1vRzPG(IWuvVsFSdv6xIJxPI7RiaHAqOP0g86Lb7qL(L44JBXk6PUAnB0CLWb8CD1NGNxOgT0yFSiC9IagGmNI76mBwj1GdkYgnxjCapxx9j45fQrln2hlbCxxueb2VFxN6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lkELbeaS4UUaeQbHMsBWRxgSd5Gfu44FCDncAIM4bofZfH8SeNyIfKgdKyUzGft3VZcsHjciqesqoDj4qGSSfDZ9yw8eKfqyIUNficAmn3tSaGwASpSahwmTtjlXwdHG6f(zXeCPbzHqw0nelQudoelingiXCZaleYIUHWCrE4pyIT4hWkJee(CUQMqB6LKYbWAaMG3FWSIF0IW1lszZaN1bAtynaIvGWNZv1KnawdWe8(dMk61laHAqOP0sLrfgY1v4aMEgi7qL(LyGPeadac4EkPeWpRKAWbfzXx2w66Eb8tZ59vqa31ffrGwQmQWqUUchW0Za1VRZX)46Ae0enXRmWPyf9m7DnLVTTMcvyRs6vswkDvnb21PUAnBWRxgSGRX)dMXhGqni0uABRPqf2QKELKDOs)smGbO9vGWNZv1K93NtRRyIaIMQj)Ef9uxTMfOlbhcSsLrqt0us5xPKguxmj7kQRZSaebLE(wGkmNN9v8(GIE7FLu9HvWJIxD1A2GxVmybxJ)hmb(ITaWUovigRODO2)6qL(LyGPUAnBWRxgSGRX)dMDDbick98T5HA)RnN66uxTMvvdHG6f(TRifQRwZQQHqq9c)2Hk9lXatD1A2GxVmybxJ)hmbCpGdWpRKAWbfzJMReoGNRR(e88c1OLg7JLaURlkIa73xHzQRwZg86Lb7ksrpZcqeu65BZd1(xBo11fGqni0uAdWebeiQ(7ufhDZ9y7kQRtfIXkAhQ9VouPFjgybiudcnL2amrabIQ)ovXr3Cp2ouPFjgWaSUU2HA)Rdv6xIrUixLaOfdm1vRzdE9YGfCn(FWSpxeYZsCIjw(DIfasP83lmSy6(DwCwqAmqI5Mbw(D)z5Wj6EwAdSKfa0sJ9HlYd)btSf)awzKmockHlCTnugZcO9AkRUAnBWRxgSdv6xIJxj001PUAnBWRxgSGRX)dMalUfRaHpNRQjBaSgGj49hmR4NlYd)btSf)awzKeinH)Z1vxFOYskF0EnLr4Z5QAYgaRbycE)bZk(v0Zm1vRzdE9YGfCn(FWm(4wCxNzbick98TiO83lm976uxTMDCeucx4ABOmMfSRifQRwZoockHlCTnugZc2Hk9lXad4a4ambx3BJgkCyQ66dvws5B)RKQiC9IaCpZuxTMvvdHG6f(TRifM9UMY3IFF0Wb0sPRQjW(CrE4pyIT4hWkJKld(K(FWeTxtze(CUQMSbWAaMG3FWSIFUiKNfas95CvnXYctGSatwC1tF)ryw(D)zXKNplpKfvIfSJGazPbhwqAmqI5MbwWqw(D)z53PcS4dLplMC8tGSaqYc)SOsn4qS87ujxKh(dMyl(bSYibHpNRQj0MEjPm2rq1gCQbVEzaTiC9Iu2SaeQbHMsBWRxgSd5Gf66mdHpNRQjBaMiGarvqcxidkcqeu65BZd1(xBo11boRd0MWAaeZfH8SeNycZsCaI(SCnwUKfpzb9d6lctS4jil)CeMLhYI(sIL7zzfXIP73zbaT0yFqllingiXCZalEcYsma9O)qqSSzYNsUip8hmXw8dyLrsBnfQWwL0RKq71uMc6lct2lREwqHhvd7uaifQRwZgnxjCapxx9j45fQrln2hlcxViGbiZPyf9aHV1b9O)qqvSjFkRGEPJIS)fa6suDDMfGiO0Z3MuyGA4a2xbcFoxvtwSJGQn4udE9YGIEQRwZoockHlCTnugZc2Hk9lXad4aG7HgGFwj1GdkYIVST019c4NMZ7RqD1A2XrqjCHRTHYywWUI66mtD1A2XrqjCHRTHYywWUI6ZfH8SeNyIfaYj97SS9(0CTMLObgWSCnw2EFAUwZYHt09SSI4I8WFWeBXpGvgj43NMR1O9AkRUAnlmPFhxJOjqr)bt7ksH6Q1S43NMR12HAdH3DvnXf5H)Gj2IFaRmscEgiDvD1AOn9ssz87JgoGO9AkRUAnl(9rdhq7qL(LyGHgf9uxTMLc6lctvmu7JDOs)sC8OPRtD1AwkOVimv1R0h7qL(L44rtFfo(hxxJGMOjEGtXCriplXXvzeMLyGbqSOsn4qSGuyIaceXYcFjkw(DIfKcteqGiwcWe8(dMS8qwc7uaiwUglifMiGarSCyw8WVCTUalUkC9S8qwujwco(5I8WFWeBXpGvgj43h8AqrO9AkhGiO0Z3MhQ9V2CsbcFoxvt2amrabIQGeUqgueGqni0uAdWebeiQ(7ufhDZ9y7qL(LyGHgfMboRd0MWAaeRGc6lct2lREwqHJ)X11iOjAI3CkMlc5zjoXelBVpnxRzX097SS9Kw7dlXX5AplEcYsczz79rdhq0YIPDkzjHSS9(0CTMLdZYkcTSuaUyXhILlzb9wPpSG(b9fHjwAWHfakGXuaZcCy5HSenWalaOLg7dlM2PKfxfIGyb4umlXadGyboS4Gr(FiiwWM8PKLDhZcafWykGzzOs)YlrXcCy5WSCjln9HA)TSel4tS87(ZYkbPHLFNyb7LelbycE)btml3JomlGrywsA9JRz5HSS9(0CTMfW1Cjkwai4iOeUWSehgkJzb0YIPDkzPaCHoqwW)P1SqjilRiwmD)olaNIbSJJyPbhw(DIfTJFwqPHQUgB5I8WFWeBXpGvgj43NMR1O9Ak)UMY3IFsR9Pcox7Tu6QAcuHzVRP8T43hnCaTu6QAcuH6Q1S43NMR12HAdH3DvnPON6Q1SuqFryQQxPp2Hk9lXXdqvqb9fHj7Lv9k9rH6Q1SrZvchWZ1vFcEEHA0sJ9XIW1lcyacnf31PUAnB0CLWb8CD1NGNxOgT0yFSiC9IIxzaHMIv44FCDncAIM4bof31bcFRd6r)HGQyt(uwb9shfzhQ0VehpaTRZd)btRd6r)HGQyt(uwb9shfzVS20hQ9VVIaeQbHMsBWRxgSdv6xIJxPI5IqEwItmXY27dEnOiwaiN0VZs0adyw8eKfWvzelXadGyX0oLSG0yGeZndSahw(DIfasP83lmSOUAnwomlUkC9S8qwAUwZcS1yboSuaUqhilbpILyGbqCrE4pyIT4hWkJe87dEnOi0EnLvxTMfM0VJRbn5tfXHpyAxrDDQRwZc0LGdbwPYiOjAkP8RusdQlMKDf11PUAnBWRxgSRif9uxTMDCeucx4ABOmMfSdv6xIbgQaOT0rgWhOt3ZX)46Ae0eni34wCFahxG)DnLVnjt1simTu6QAcuHzZkPgCqrw8LTLUUxa)0CUc1vRzhhbLWfU2gkJzb7kQRtD1A2GxVmyhQ0VedmubqBPJmGpqNUNJ)X11iOjAqUXT4(DDQRwZoockHlCTnugZcv8LTLUUxa)0CUDf11zM6Q1SJJGs4cxBdLXSGDfPWSaeQbHMs74iOeUW12qzmlyhYbl01zwaIGspFlck)9ct)Uoh)JRRrqt0epWPyfuqFryYEz1ZcCriplMFkWYdzP0bIy53jwuj8ZcSXY27JgoGSOwGf87bGUefl3ZYkIfG76caPlWYLS4zbwq)G(IWelQRNfa0sJ9HLdNplUkC9S8qwujwIgyiqGCrE4pyIT4hWkJe87dEnOi0EnLFxt5BXVpA4aAP0v1eOcZMvsn4GIS)vsMGtwbhYlvVeKgf9uxTMf)(OHdODf1154FCDncAIM4bof3xH6Q1S43hnCaT43dabS4QON6Q1SuqFryQIHAFSROUo1vRzPG(IWuvVsFSRO(kuxTMnAUs4aEUU6tWZluJwASpweUEradqaWIv0laHAqOP0g86Lb7qL(L44vQ4UoZq4Z5QAYgGjciqufKWfYGIaebLE(28qT)1Mt95IqEwqF8FL(tyw2HMyPCf2zjgyael(qSGYVKazjIgwWuaMGCrE4pyIT4hWkJee(CUQMqB6LKYoocarZgfqlcxViLPG(IWK9YQEL(a8auKRh(dMw87t7gYsiJcRNQ)vsa2mkOVimzVSQxPpaFpagGFxt5BXWLUcB1FNQn4q43sPRQjqGpU9rUE4pyAnn(VBjKrH1t1)kjaxS1CqdYfhrADD3Xpb4ITOb4Fxt5Bt)xdHRQU2ZazP0v1eixeYZsCCvgXY27dEnOiwUKfNfaiGXuGLnO2hwq)G(IWeAzbeMO7zrtpl3Zs0adSaGwASpS0739NLdZYUNGAcKf1cSq3Vtdl)oXY27tZ1Aw0xsSahw(DILyGbqXdCkMf9Leln4WY27dEnOO(OLfqyIUNficAmn3tS4jlaKt63zjAGbw8eKfn9S87elUkebXI(sILDpb1elBVpA4aYf5H)Gj2IFaRmsWVp41GIq71u2SzLudoOi7FLKj4KvWH8s1lbPrrp1vRzJMReoGNRR(e88c1OLg7JfHRxeWaeaS4Uo1vRzJMReoGNRR(e88c1OLg7JfHRxeWaeAkwX7AkFl(jT2Nk4CT3sPRQjW(k6rb9fHj7Lvmu7Jch)JRRrqt0aye(CUQMSoocarZgfaE1vRzPG(IWufd1(yhQ0Vedyq4BBRPqf2QKELK9Vaq46qL(LapGSOjEaAXDDuqFryYEzvVsFu44FCDncAIgaJWNZv1K1XraiA2OaWRUAnlf0xeMQ6v6JDOs)smGbHVTTMcvyRs6vs2)caHRdv6xc8aYIM4bof3xHzQRwZct63X1iAcu0FW0UIuy27AkFl(9rdhqlLUQMav0laHAqOP0g86Lb7qL(L44bGDDy4sREjO93NtRRyIaIglLUQMavOUAn7VpNwxXebenw87bGawCJlaU3SsQbhuKfFzBPR7fWpnNd8OPVI2HA)Rdv6xIJxPIlwr7qT)1Hk9lXadqfxCFf9cqOgeAkTaDj4qGvC0n3JTdv6xIJha21zwaIGspFlqfMZZ(CriplXjMybGieMywUKf0BL(Wc6h0xeMyXtqwWocIfKZ46gGJdlTMfaIqyYsdoSG0yGeZndS4jiliNUeCiqwq)YiOjAkP85I8WFWeBXpGvgjjzQwcHjAVMY9uxTMLc6lctv9k9XouPFjoEczuy9u9VsQRRxy3huewzaPyOWUpOO6FLeWqt)UUWUpOiSYXTVcpQg2Paqkq4Z5QAYIDeuTbNAWRxg4I8WFWeBXpGvgj7UUvlHWeTxt5EQRwZsb9fHPQEL(yhQ0VehpHmkSEQ(xjPWSaebLE(wGkmNNDD9uxTMfOlbhcSsLrqt0us5xPKguxmj7ksraIGspFlqfMZZ(DD9c7(GIWkdifdf29bfv)RKagA631f29bfHvoUDDQRwZg86Lb7kQVcpQg2Paqkq4Z5QAYIDeuTbNAWRxgu0tD1A2XrqjCHRTHYywWouPFjgy9qdagqa)SsQbhuKfFzBPR7fWpnN3xH6Q1SJJGs4cxBdLXSGDf11zM6Q1SJJGs4cxBdLXSGDf1NlYd)btSf)awzK0wADTect0EnL7PUAnlf0xeMQ6v6JDOs)sC8eYOW6P6FLKcZcqeu65BbQWCE211tD1AwGUeCiWkvgbnrtjLFLsAqDXKSRifbick98Tavyop7311lS7dkcRmGumuy3huu9VscyOPFxxy3huew5421PUAnBWRxgSRO(k8OAyNcaPaHpNRQjl2rq1gCQbVEzqrp1vRzhhbLWfU2gkJzb7qL(LyGHgfQRwZoockHlCTnugZc2vKcZMvsn4GIS4lBlDDVa(P58UoZuxTMDCeucx4ABOmMfSRO(CriplXjMyb5aI(SatwcGCrE4pyIT4hWkJet(mhCQWwL0RK4IqEwItmXY27t7gILhYs0adSSb1(Wc6h0xeMqllingiXCZal7oMfnHXS8xjXYV7jlolihJ)7SqiJcRNyrtTNf4Wcm1fyb9wPpSG(b9fHjwomlRiUip8hmXw8dyLrc(9PDdH2RPmf0xeMSxw1R0NUokOVimzXqTp1Kq231rb9fHjRNfQjHSVRRN6Q1SM8zo4uHTkPxjzxrDD4isRR7o(jGvS1CqJcZcqeu65Brq5Vxy66WrKwx3D8taRyR5OiarqPNVfbL)EHPVc1vRzPG(IWuvVsFSROUUEQRwZg86Lb7qL(LyG5H)GP104)ULqgfwpv)RKuOUAnBWRxgSRO(CriplXjMyb5y8FNf4VtJPdtSyA)c7SCywUKLnO2hwq)G(IWeAzbPXajMBgyboS8qwIgyGf0BL(Wc6h0xeM4I8WFWeBXpGvgjMg)35IqEwIdUw)7ZIlYd)btSf)awzKmRS6H)GzvF4hTPxsk3CT(3NLXB8gga]] )


end