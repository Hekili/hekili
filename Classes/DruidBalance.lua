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


    spec:RegisterPack( "Balance", 20210629.1, [[de1nDfqikjpcIQUeevAtKWNGuAusvoLuvRcqvVcGAwqQClac7IIFbrmmrQogjYYaqptOstJskUgKITbqY3ai14aG6CaeToavmpaL7rIAFcv9piQO0bfkAHcL6HqKMOqf6IqQQnkubFeIkQgjevuCskP0kfP8siQiZesvUjaeTtHs(jaKAOaGwkaeEQszQus1vfQOTcaj9viQWyba2lL6VIAWehMQftspwWKb6YiBwkFgsgTs1Pvz1aqIxdiZMu3wQSBj)g0WfYXbuPLR45qnDvDDLSDi8DkX4HOCErY6fkmFrSFuBRKT1T3a9NSJfathGkLoGcGasJsPJganabW2BFQiYElYda5Oi7TY7i7Ty7AVcK9wKNsdDqBRBVHHRjq2B7)hHboibjQU2RabiWxxWG6(9LQ5Gij2U2Rabi2UoKIKoqZ(3ProB70KYQU2RazEK92BQRt)wBzRAVb6pzhlaMoavkDafabKgLshnaALaO9MV(D4yVTDDi1EB)abPYw1EdKWb7Ty7AVcelXXzDGCAPTkIfacirhlamDaQeNgNgs39cfHboCAacwIjiibYYgu7dlXM8odNgGGfKU7fkcKL3hu0NVglbhtywEilHubnLFFqrp2WPbiybab1brqGSSQIceg7tkwq4Z5QAcZsVZqg0Xs0qiY43h8AqrSaiINLOHqyWVp41GI6B40aeSeteWdKLOHco(VcflihJ)7SCnwUhTyw(DIfldSqXc6h0xeMmCAacwaq6arSGuyHaceXYVtSSfDZ9ywCw03)AILo4qS00eYovnXsVRXsk4ILDhSq7ZY(9SCpl4RBPFVi4cRtXIL73zj2aOJP1zbWSGust4)CnlXuFOQoQE0XY9OfKfmqxuFdNgGGfaKoqelDq8ZcABhQ9ppuNFfgTSGdu5ZbXS4rr6uS8qwuHymlTd1(Jzbw6ugonoTywf89Nazj2U2RaXsmbGOhlbVyrLyPbxfil(ZY()ryGdsqIQR9kqac81fmOUFFPAoisITR9kqaITRdPiPd0S)DAKZ2onPSQR9kqMhzV9M(Wp2262BGuZx63262XsjBRBV5H)GL9ggQ9jRsEN9gvUQMaTJT9BhlaABD7nQCvnbAhB7nyK9gME7np8hSS3q4Z5QAYEdHRxK9goI0687dk6Xg87tZ1AwINfLyrbl9yXkwExt1BWVpA4aAOYv1eiljjS8UMQ3GFsR9jdox7nu5QAcKL(SKKWcoI0687dk6Xg87tZ1AwINfaAVbs4WCr)bl7Tn6XSeti6ZcSyjUaMfl3VdxplGZ1Ew8cKfl3VZY27JgoGS4filaeWSa)DASCyYEdHp5Y7i7TdNDiz)2XkU2w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzVHJiTo)(GIESb)(0UHyjEwuYEdKWH5I(dw2BB0JzjOjhbXILDQyz79PDdXsWlw2VNfacywEFqrpMfl7xyNLdZYqAcHxpln4WYVtSG(b9fHjwEilQelrd1Oziqw8cKfl7xyNL2P10WYdzj443EdHp5Y7i7TdNdAYrq2VDSSgBRBVrLRQjq7yBV5H)GL9MknyAa6ku2BGeomx0FWYEloXelXMgmnaDfkwSC)olinMiXARalWHfV90WcsHfciqelxXcsJjsS2kyVfM7P5C7TESyflbicQ86n1HA)ZnNyjjHfRyjaHAqOLYeGfciqu(3Pmo6M7XMvel9zrblQRwZe88vbZqD(vywINfLqdlkyrD1AMXrqfCHZTHQyKYmuNFfMfGXI1WIcwSILaebvE9geu97PgwssyjarqLxVbbv)EQHffSOUAntWZxfmRiwuWI6Q1mJJGk4cNBdvXiLzfXIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJfLuIfablOHfGNLzvudoOid(Q2sN3tHFAo3qLRQjqwssyrD1AMGNVkygQZVcZcWyrjLyjjHfLybjSGJiToV74NybySOKbnOHL(2VDSqJT1T3OYv1eODST3cZ90CU9M6Q1mbpFvWmuNFfML4zrj0WIcw6XIvSmRIAWbfzWx1w68Ek8tZ5gQCvnbYssclQRwZmocQGlCUnufJuMH68RWSamwucqZIcwuxTMzCeubx4CBOkgPmRiw6ZssclQqmMffS0ou7FEOo)kmlaJfaIg7nqchMl6pyzVbaHplwUFNfNfKgtKyTvGLF3FwoCH2NfNfa4sJ9HLObgyboSyzNkw(DIL2HA)z5WS4QW1ZYdzHkq7np8hSS3IG)bl73owakBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3c0PzPhl9yPDO2)8qD(vywaeSOeAybqWsac1GqlLj45RcMH68RWS0NfKWIsa40zPplkZsGonl9yPhlTd1(NhQZVcZcGGfLqdlacwucGPZcGGLaeQbHwktawiGar5FNY4OBUhBgQZVcZsFwqclkbGtNL(SOGfRyz8dmtiO6noii2qi7WpMLKewcqOgeAPmbpFvWmuNFfML4z5QNMiO2Fcm3ou7FEOo)kmljjSeGqni0szcWcbeik)7ughDZ9yZqD(vywINLREAIGA)jWC7qT)5H68RWSaiyrP0zjjHfRyjarqLxVPou7FU5eljjS4H)GLjaleqGO8VtzC0n3JnGh2v1eO9giHdZf9hSS3qQRdlT)eMfl70Vtdll8vOybPWcbeiILcAHflNwZIR1qlSKcUy5HSG)tRzj44NLFNyb7DelEhCvplWglifwiGaragPXejwBfyj44hBVHWNC5DK9wawiGarzqcNQc2VDSa02w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzV1JL3hu0B(RJYpmdEelXZIsOHLKewg)aZecQEJdcInxXs8SGM0zPplkyPhl9yPhlwXcbCxxuebAOUOud56mCalVceljjS0JLESeGqni0szOUOud56mCalVcKzOo)kmlaJfLauPZssclbicQ86niO63tnSOGLaeQbHwkd1fLAixNHdy5vGmd15xHzbySOeGcqZcGzPhlkPelaplZQOgCqrg8vTLoVNc)0CUHkxvtGS0NL(SOGfRyjaHAqOLYqDrPgY1z4awEfiZqoykw6ZsFwuWspwSIfc4UUOic0GHlTM()ku5zPMILKewSILaebvE9M6qT)5MtSKKWsac1GqlLbdxAn9)vOYZsnvoUwdAaWPRKzOo)kmlaJfLuYAyPplkyPhlwXcbCxxuebAUchM17QAkdCxE9RUmiH4celjjSeGqni0szUchM17QAkdCxE9RUmiH4cKzihmfl9zrbl9yjaHAqOLYOsdMgGUcLzihmfljjSyflJhiZpqTML(SKKWspw6XccFoxvtgyLxyk)ZvarplkZIsSKKWccFoxvtgyLxyk)ZvarplkZsCzPplkyPhl)Cfq0BELmd5GPYbiudcTuSKKWYpxbe9Mxjtac1GqlLzOo)kmlXZYvpnrqT)eyUDO2)8qD(vywaeSOu6S0NLKewq4Z5QAYaR8ct5FUci6zrzwailkyPhl)Cfq0BEaAgYbtLdqOgeAPyjjHLFUci6npanbiudcTuMH68RWSeplx90eb1(tG52HA)Zd15xHzbqWIsPZsFwssybHpNRQjdSYlmL)5kGONfLzjDw6ZsFwssyjarqLxVbOuZ5fl9T3ajCyUO)GL9wCIjqwEilGK2tXYVtSSWokIfyJfKgtKyTvGfl7uXYcFfkwaHlvnXcSyzHjw8cKLOHqq1ZYc7OiwSStflEXIdcYcHGQNLdZIRcxplpKfWJS3q4tU8oYElaMdWc8(dw2VDSaW2w3EJkxvtG2X2EdgzVHP3EZd)bl7ne(CUQMS3q46fzVzfly4sREfO53NtRZyIaIgdvUQMazjjHL2HA)Zd15xHzjEway6PZssclQqmMffS0ou7FEOo)kmlaJfaIgwaml9yXAsNfablQRwZ87ZP1zmrarJb)EaiwaEwail9zjjHf1vRz(9506mMiGOXGFpaelXZsCbWSaiyPhlZQOgCqrg8vTLoVNc)0CUHkxvtGSa8SGgw6BVHWNC5DK92VpNwNXebenzl(92VDSaK2w3EJkxvtG2X2EdKWH5I(dw2BXjMyb97IsnKRzba9awEfiway6ykGzrLAWHyXzbPXejwBfyzHjJ9w5DK9g1fLAixNHdy5vGS3cZ90CU9wac1GqlLj45RcMH68RWSamway6SOGLaeQbHwktawiGar5FNY4OBUhBgQZVcZcWybGPZIcw6XccFoxvtMFFoToJjciAYw87zjjHf1vRz(9506mMiGOXGFpaelXZsCtNfaZspwMvrn4GIm4RAlDEpf(P5CdvUQMazb4zbqXsFw6ZssclQqmMffS0ou7FEOo)kmlaJL4cOT38WFWYEJ6IsnKRZWbS8kq2VDSukDBRBVrLRQjq7yBVbs4WCr)bl7T4etSSbxAn9xHIfael1uSaOWuaZIk1GdXIZcsJjsS2kWYctg7TY7i7nmCP10)xHkpl1u2BH5EAo3ElaHAqOLYe88vbZqD(vywaglakwuWIvSeGiOYR3GGQFp1WIcwSILaebvE9M6qT)5MtSKKWsaIGkVEtDO2)CZjwuWsac1GqlLjaleqGO8VtzC0n3Jnd15xHzbySaOyrbl9ybHpNRQjtawiGarzqcNQcSKKWsac1GqlLj45RcMH68RWSamwauS0NLKewcqeu51Bqq1VNAyrbl9yXkwMvrn4GIm4RAlDEpf(P5CdvUQMazrblbiudcTuMGNVkygQZVcZcWybqXssclQRwZmocQGlCUnufJuMH68RWSamwuYAybWS0Jf0WcWZcbCxxuebAUc)Zk8WbNbpexrzvsRzPplkyrD1AMXrqfCHZTHQyKYSIyPpljjSOcXywuWs7qT)5H68RWSamwaiAS38WFWYEddxAn9)vOYZsnL9BhlLuY262Bu5QAc0o22BE4pyzVDfomR3v1ug4U86xDzqcXfi7TWCpnNBVPUAntWZxfmd15xHzjEwucnSOGLESyflZQOgCqrg8vTLoVNc)0CUHkxvtGSKKWI6Q1mJJGk4cNBdvXiLzOo)kmlaJfLailaMLESexwaEwuxTMrvdHG6f(nRiw6ZcGzPhl9ybqZcGGf0WcWZI6Q1mQAieuVWVzfXsFwaEwiG76IIiqZv4FwHho4m4H4kkRsAnl9zrblQRwZmocQGlCUnufJuMvel9zjjHfvigZIcwAhQ9ppuNFfMfGXcarJ9w5DK92v4WSExvtzG7YRF1LbjexGSF7yPeaTTU9gvUQMaTJT9giHdZf9hSS3S((Hz5WS4Sm(VtdlK2vHJ)elw8uS8qw6CGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSC)olinMiXARalEbYcsHfciqelEbYYctS87elaSazbRHplWILailxJfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhBVfM7P5C7ne(CUQMmWkVWu(NRaIEwuMfaYIcwSILFUci6npand5GPYbiudcTuSKKWspwq4Z5QAYaR8ct5FUci6zrzwuILKewq4Z5QAYaR8ct5FUci6zrzwIll9zrbl9yrD1AMGNVkywrSOGLESyflbicQ86niO63tnSKKWI6Q1mJJGk4cNBdvXiLzOo)kmlaMLESGgwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPplatzw(5kGO38kzuxTwgCn(FWIffSOUAnZ4iOcUW52qvmszwrSKKWI6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBwrS0NLKewcqOgeAPmbpFvWmuNFfMfaZcazjEw(5kGO38kzcqOgeAPmGRX)dwSOGLESyflbicQ86n1HA)ZnNyjjHfRybHpNRQjtawiGarzqcNQcS0NffSyflbicQ86naLAoVyjjHLaebvE9M6qT)5MtSOGfe(CUQMmbyHaceLbjCQkWIcwcqOgeAPmbyHaceL)DkJJU5ESzfXIcwSILaeQbHwktWZxfmRiwuWspw6XI6Q1muqFrykRxLpMH68RWSeplkLoljjSOUAndf0xeMYyO2hZqD(vywINfLsNL(SOGfRyzwf1GdkYO6AVcug2YUwN)9RqHnu5QAcKLKew6XI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqSOmlOHLKewuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIfLzbaZsFw6ZssclQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfXsFwssyrfIXSOGL2HA)Zd15xHzbySaW0zjjHfe(CUQMmWkVWu(NRaIEwuML0T3WA4JT3(5kGOxj7np8hSS3wykFp1HTF7yPuCTTU9gvUQMaTJT9Mh(dw2BlmLVN6W2BH5EAo3EdHpNRQjdSYlmL)5kGONfRuMfaYIcwSILFUci6nVsMHCWu5aeQbHwkwssybHpNRQjdSYlmL)5kGONfLzbGSOGLESOUAntWZxfmRiwuWspwSILaebvE9geu97PgwssyrD1AMXrqfCHZTHQyKYmuNFfMfaZspwqdlaplZQOgCqrg8vTLoVNc)0CUHkxvtGS0NfGPml)Cfq0BEaAuxTwgCn(FWIffSOUAnZ4iOcUW52qvmszwrSKKWI6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBwrS0NLKewcqOgeAPmbpFvWmuNFfMfaZcazjEw(5kGO38a0eGqni0szaxJ)hSyrbl9yXkwcqeu51BQd1(NBoXssclwXccFoxvtMaSqabIYGeovfyPplkyXkwcqeu51Bak1CEXIcw6XIvSOUAntWZxfmRiwssyXkwcqeu51Bqq1VNAyPpljjSeGiOYR3uhQ9p3CIffSGWNZv1KjaleqGOmiHtvbwuWsac1GqlLjaleqGO8VtzC0n3JnRiwuWIvSeGqni0szcE(QGzfXIcw6XspwuxTMHc6lctz9Q8XmuNFfML4zrP0zjjHf1vRzOG(IWugd1(ygQZVcZs8SOu6S0NffSyflZQOgCqrgvx7vGYWw2168VFfkSHkxvtGSKKWspwuxTMr11EfOmSLDTo)7xHcNl)xdzWVhaIfLzbnSKKWI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqSOmlayw6ZsFw6ZssclQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfXssclQqmMffS0ou7FEOo)kmlaJfaMoljjSGWNZv1Kbw5fMY)Cfq0ZIYSKU9gwdFS92pxbe9a0(TJLswJT1T3OYv1eODST38WFWYEBHP89uh2EdKWH5I(dw2BXjMWS4AnlWFNgwGfllmXY9uhMfyXsa0Elm3tZ52BQRwZe88vbZkILKewcqeu51BQd1(NBoXIcwq4Z5QAYeGfciqugKWPQalkyjaHAqOLYeGfciqu(3Pmo6M7XMvelkyXkwcqOgeAPmbpFvWSIyrbl9yPhlQRwZqb9fHPSEv(ygQZVcZs8SOu6SKKWI6Q1muqFrykJHAFmd15xHzjEwukDw6ZIcwSILzvudoOiJQR9kqzyl7AD(3Vcf2qLRQjqwssyzwf1GdkYO6AVcug2YUwN)9RqHnu5QAcKffS0Jf1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyjEwIlljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZsCzPpl9zjjHf1vRza6kWHaZuxe0cnDu9zQOb1fdYSIyjjHfvigZIcwAhQ9ppuNFfMfGXcat3(TJLsOX262Bu5QAc0o22BGeomx0FWYElosHdKyXd)blw0h(zr1XeilWIf89l)pyHenH6W2BE4pyzVnRk7H)GvwF43Ed)ZfE7yPK9wyUNMZT3q4Z5QAYC4Sdj7n9H)C5DK9Mdj73owkbOSTU9gvUQMaTJT9wyUNMZT3Mvrn4GImQU2RaLHTSR15F)kuydbCxxuebAVH)5cVDSuYEZd)bl7Tzvzp8hSY6d)2B6d)5Y7i7nvO)2VDSucqBBD7nQCvnbAhB7np8hSS3MvL9WFWkRp8BVPp8NlVJS3WV9B)2BQq)TTUDSuY262Bu5QAc0o22BE4pyzVnocQGlCUnufJu2BGeomx0FWYElomufJuSy5(DwqAmrI1wb7TWCpnNBVPUAntWZxfmd15xHzjEwucn2VDSaOT1T3OYv1eODST38WFWYEZb9O)qqzSfF6S3cPcAk)(GIESDSuYElm3tZ52BQRwZO6AVcug2YUwN)9RqHZL)RHm43daXcWybaZIcwuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIfGXcaMffS0JfRybe(gh0J(dbLXw8Pld6DokY8xaORqXIcwSIfp8hSmoOh9hckJT4txg07CuK5QCtFO2FwuWspwSIfq4BCqp6peugBXNU8o5AZFbGUcfljjSacFJd6r)HGYyl(0L3jxBgQZVcZs8Sexw6ZssclGW34GE0FiOm2IpDzqVZrrg87bGybySexwuWci8noOh9hckJT4txg07CuKzOo)kmlaJf0WIcwaHVXb9O)qqzSfF6YGENJIm)fa6kuS03EdKWH5I(dw2BXjMyjMGE0Fiiw2S4thlw2PIf)zrtyml)UxSynSeBymTol43daHzXlqwEild1gcVZIZcWugGSGFpaeloMfT)eloMLiigFQAIf4WYFDel3ZcgYY9S4ZCiimlaOSWplE7PHfNL4cywWVhaIfczr3qy73owX1262Bu5QAc0o22BE4pyzVfGfciqu(3Pmo6M7X2BGeomx0FWYEloXelifwiGarSy5(DwqAmrI1wbwSStflrqm(u1elEbYc83PXYHjwSC)ololXggtRZI6Q1yXYovSas4uv4ku2BH5EAo3EZkwaN1bAkyoaIzrbl9yPhli85CvnzcWcbeikds4uvGffSyflbiudcTuMGNVkygYbtXssclQRwZe88vbZkIL(SOGLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpaelkZcaMLKewuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaIfLzbaZsFwssyrfIXSOGL2HA)Zd15xHzbySOu6S03(TJL1yBD7nQCvnbAhB7np8hSS3ARjvg2YKEvK9giHdZf9hSS3Idq0NfhZYVtS0Ub)SGkaYYvS87elolXggtRZILRaHwyboSy5(Dw(DIfKtPMZlwuxTglWHfl3VZIZcagWykWsmb9O)qqSSzXNow8cKfl(9S0GdlinMiXARalxJL7zXcSEwujwwrS4O8RyrLAWHy53jwcGSCywAxD4Dc0Elm3tZ52B9yPhl9yrD1Agvx7vGYWw2168VFfkCU8FnKb)EaiwINfafljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZcGIL(SOGLESyflbicQ86niO63tnSKKWIvSOUAnZ4iOcUW52qvmszwrS0NL(SOGLESaoRd0uWCaeZssclbiudcTuMGNVkygQZVcZs8SGM0zjjHLESeGiOYR3uhQ9p3CIffSeGqni0szcWcbeik)7ughDZ9yZqD(vywINf0Kol9zPpl9zjjHLESacFJd6r)HGYyl(0Lb9ohfzgQZVcZs8SaGzrblbiudcTuMGNVkygQZVcZs8SOu6SOGLaebvE9MIcdudhqw6ZssclQqmMffSC1tteu7pbMBhQ9ppuNFfMfGXcaMffSyflbiudcTuMGNVkygYbtXssclbicQ86naLAoVyrblQRwZa0vGdbMPUiOfA6O6nRiwssyjarqLxVbbv)EQHffSOUAnZ4iOcUW52qvmszgQZVcZcWybqYIcwuxTMzCeubx4CBOkgPmRi73owOX262Bu5QAc0o22BE4pyzVf8kq6S6Q1S3cZ90CU9wpwuxTMr11EfOmSLDTo)7xHcNl)xdzgQZVcZs8SaOnOHLKewuxTMr11EfOmSLDTo)7xHcN9j4fzgQZVcZs8SaOnOHL(SOGLESeGqni0szcE(QGzOo)kmlXZcGMLKew6Xsac1GqlLH6IGwOjRclqZqD(vywINfanlkyXkwuxTMbORahcmtDrql00r1NPIguxmiZkIffSeGiOYR3auQ58IL(S0NffS44FCDocAHgwIxzwIB62BQRwlxEhzVHFF0Wb0EdKWH5I(dw2Bi1RaPzz79rdhqwSC)ololfzHLydJP1zrD1AS4filinMiXARalhUq7ZIRcxplpKfvILfMaTF7ybOSTU9gvUQMaTJT9Mh(dw2B43h8Aqr2BGeomx0FWYEloU6Iyz79bVgueMfl3VZIZsSHX06SOUAnwuxplf8zXYovSebH6RqXsdoSG0yIeRTcSahwqoDf4qGSSfDZ9y7TWCpnNBV1Jf1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyjEwailjjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZcazPplkyPhlbicQ86n1HA)ZnNyjjHLaeQbHwktWZxfmd15xHzjEwa0SKKWIvSGWNZv1KjaMdWc8(dwSOGfRyjarqLxVbOuZ5fljjS0JLaeQbHwkd1fbTqtwfwGMH68RWSeplaAwuWIvSOUAndqxboeyM6IGwOPJQptfnOUyqMvelkyjarqLxVbOuZ5fl9zPplkyPhlwXci8nT1KkdBzsVkY8xaORqXssclwXsac1GqlLj45RcMHCWuSKKWIvSeGqni0szcWcbeik)7ughDZ9yZqoykw6B)2XcqBBD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9wCC1fXY27dEnOimlQudoelifwiGar2BH5EAo3ERhlbiudcTuMaSqabIY)oLXr3Cp2muNFfMfGXcAyrblwXc4SoqtbZbqmlkyPhli85CvnzcWcbeikds4uvGLKewcqOgeAPmbpFvWmuNFfMfGXcAyPplkybHpNRQjtamhGf49hSyPplkyXkwaHVPTMuzylt6vrM)caDfkwuWsaIGkVEtDO2)CZjwuWIvSaoRd0uWCaeZIcwOG(IWK5QSxPyrblo(hxNJGwOHL4zXAs3(TJfa2262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7TESOUAnZ4iOcUW52qvmszgQZVcZs8SGgwssyXkwuxTMzCeubx4CBOkgPmRiw6ZIcw6XI6Q1maDf4qGzQlcAHMoQ(mv0G6IbzgQZVcZcWybva005iJL(SOGLESOUAndf0xeMYyO2hZqD(vywINfubqtNJmwssyrD1AgkOVimL1RYhZqD(vywINfubqtNJmw6BVbs4WCr)bl7T4iSq7Zci8zbCnxHILFNyHkqwGnwaq4iOcUWSehgQIrk0Xc4AUcflaDf4qGSqDrql00r1ZcCy5kw(DIfTJFwqfazb2yXlwq)G(IWK9gcFYL3r2BGWppeWDDd1r1JTF7ybiTTU9gvUQMaTJT9Mh(dw2B4v1UHS3cZ90CU92qTHW7UQMyrblVpOO38xhLFyg8iwINfLauSOGfpkh2PaqSOGfe(CUQMmGWppeWDDd1r1JT3cPcAk)(GIESDSuY(TJLsPBBD7nQCvnbAhB7np8hSS36GWQDdzVfM7P5C7THAdH3DvnXIcwEFqrV5Vok)Wm4rSeplkfxdAyrblEuoStbGyrbli85CvnzaHFEiG76gQJQhBVfsf0u(9bf9y7yPK9BhlLuY262Bu5QAc0o22BE4pyzVHFsR9j30(q2BH5EAo3EBO2q4DxvtSOGL3hu0B(RJYpmdEelXZIsakwamld15xHzrblEuoStbGyrbli85CvnzaHFEiG76gQJQhBVfsf0u(9bf9y7yPK9BhlLaOT1T3OYv1eODST38WFWYERbNaLHTC5)Ai7nqchMl6pyzVfhGXIfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhlLIRT1T3OYv1eODST38WFWYEJ6IGwOjRclq7nqchMl6pyzVH(Drql0WsSHfilw2PIfxfUEwEilu90WIZsrwyj2WyADwSCfi0clEbYc2rqS0GdlinMiXARG9wyUNMZT36Xcf0xeMm6v5tUiK9SKKWcf0xeMmyO2NCri7zjjHfkOVimz8kvUiK9SKKWI6Q1mQU2RaLHTSR15F)ku4C5)AiZqD(vywINfaTbnSKKWI6Q1mQU2RaLHTSR15F)ku4SpbViZqD(vywINfaTbnSKKWIJ)X15iOfAyjEwaKPZIcwcqOgeAPmbpFvWmKdMIffSyflGZ6anfmhaXS0NffS0JLaeQbHwktWZxfmd15xHzjEwIB6SKKWsac1GqlLj45RcMHCWuS0NLKewuHymlky5QNMiO2Fcm3ou7FEOo)kmlaJfLs3(TJLswJT1T3OYv1eODST38WFWYERTMuzylt6vr2BGeomx0FWYEloarFwMd1(ZIk1GdXYcFfkwqAmT3cZ90CU9wac1GqlLj45RcMHCWuSOGfe(CUQMmbWCawG3FWIffS0Jfh)JRZrql0Ws8SaitNffSyflbicQ86n1HA)ZnNyjjHLaebvE9M6qT)5MtSOGfh)JRZrql0WcWyXAsNL(SOGfRyjarqLxVbbv)EQHffS0JfRyjarqLxVPou7FU5eljjSeGqni0szcWcbeik)7ughDZ9yZqoykw6ZIcwSIfWzDGMcMdGy73owkHgBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS3SIfWzDGMcMdGywuWccFoxvtMayoalW7pyXIcw6XspwC8pUohbTqdlXZcGmDwuWspwuxTMbORahcmtDrql00r1NPIguxmiZkILKewSILaebvE9gGsnNxS0NLKewuxTMrvdHG6f(nRiwuWI6Q1mQAieuVWVzOo)kmlaJf1vRzcE(QGbCn(FWIL(SKKWYvpnrqT)eyUDO2)8qD(vywaglQRwZe88vbd4A8)GfljjSeGiOYR3uhQ9p3CIL(SOGLESyflbicQ86n1HA)ZnNyjjHLES44FCDocAHgwaglwt6SKKWci8nT1KkdBzsVkY8xaORqXsFwuWspwq4Z5QAYeGfciqugKWPQaljjSeGqni0szcWcbeik)7ughDZ9yZqoykw6ZsF7nqchMl6pyzVH0yIeRTcSyzNkw8Nfaz6aMLyIbGS0doAOfAy539IfRjDwIjgaYIL73zbPWcbeiQplwUFhUEw0q8vOy5VoILRyj2AieuVWplEbYI(kILvelwUFNfKcleqGiwUgl3ZIfhZciHtvbc0EdHp5Y7i7TayoalW7pyLvH(B)2XsjaLT1T3OYv1eODST3cZ90CU9gcFoxvtMayoalW7pyLvH(BV5H)GL9wG0e(pxND9HQ6O6TF7yPeG2262Bu5QAc0o22BH5EAo3EdHpNRQjtamhGf49hSYQq)T38WFWYE7QGpL)hSSF7yPea2262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7nkOVimzUkRxLpSa8SaGzbjS4H)GLb)(0UHmeYOW6P8FDelaMfRyHc6lctMRY6v5dlapl9ybqXcGz5DnvVbdx6mSL)Dk3GdHFdvUQMazb4zjUS0NfKWIh(dwglJ)7gczuy9u(VoIfaZs6gaYcsybhrADE3XpzVbs4WCr)bl7n0h)xN)eMLDOfw6wHDwIjgaYIpelO8RiqwIOHfmfGfO9gcFYL3r2BoocasZgfSF7yPeG0262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T44QlILT3h8AqrywSStfl)oXs7qT)SCywCv46z5HSqfi6yPnufJuSCywCv46z5HSqfi6yjfCXIpel(ZcGmDaZsmXaqwUIfVyb9d6lctOJfKgtKyTvGfTJFmlEb)DAybadymfWSahwsbxSybU0GSarqtWJyPdoel)UxSWjkLolXedazXYovSKcUyXcCPbl0(SS9(GxdkILcAXElm3tZ52B9yrfIXSOGLREAIGA)jWC7qT)5H68RWSamwSgwssyPhlQRwZmocQGlCUnufJuMH68RWSamwqfanDoYyb4zjqNMLES44FCDocAHgwqclXnDw6ZIcwuxTMzCeubx4CBOkgPmRiw6ZsFwssyPhlo(hxNJGwOHfaZccFoxvtghhbaPzJcSa8SOUAndf0xeMYyO2hZqD(vywamlGW30wtQmSLj9QiZFbGW5H68Ryb4zbGg0Ws8SOKsPZssclo(hxNJGwOHfaZccFoxvtghhbaPzJcSa8SOUAndf0xeMY6v5JzOo)kmlaMfq4BARjvg2YKEvK5Vaq48qD(vSa8SaqdAyjEwusP0zPplkyHc6lctMRYELIffS0JfRyrD1AMGNVkywrSKKWIvS8UMQ3GFF0Wb0qLRQjqw6ZIcw6XspwSILaeQbHwktWZxfmRiwssyjarqLxVbOuZ5flkyXkwcqOgeAPmuxe0cnzvybAwrS0NLKewcqeu51BQd1(NBoXsFwuWspwSILaebvE9geu97PgwssyXkwuxTMj45RcMveljjS44FCDocAHgwINfaz6S0NLKew6XY7AQEd(9rdhqdvUQMazrblQRwZe88vbZkIffS0Jf1vRzWVpA4aAWVhaIfGXsCzjjHfh)JRZrql0Ws8SaitNL(S0NLKewuxTMj45RcMvelkyXkwuxTMzCeubx4CBOkgPmRiwuWIvS8UMQ3GFF0Wb0qLRQjq73owamDBRBVrLRQjq7yBV5H)GL9wrwYDqyzVbs4WCr)bl7T4etSaGeclmlxXc6TkFyb9d6lctS4filyhbXcYzCDdWXHLwZcasiSyPbhwqAmrI1wb7TWCpnNBV1Jf1vRzOG(IWuwVkFmd15xHzjEwiKrH1t5)6iwssyPhlHDFqrywuMfaYIcwgkS7dkk)xhXcWybnS0NLKewc7(GIWSOmlXLL(SOGfpkh2Paq2VDSaOs2w3EJkxvtG2X2Elm3tZ52B9yrD1AgkOVimL1RYhZqD(vywINfczuy9u(VoIffS0JLaeQbHwktWZxfmd15xHzjEwqt6SKKWsac1GqlLjaleqGO8VtzC0n3Jnd15xHzjEwqt6S0NLKew6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjjHLWUpOimlkZsCzPplkyXJYHDkaK9Mh(dw2B7UUL7GWY(TJfabOT1T3OYv1eODST3cZ90CU9wpwuxTMHc6lctz9Q8XmuNFfML4zHqgfwpL)RJyrbl9yjaHAqOLYe88vbZqD(vywINf0KoljjSeGqni0szcWcbeik)7ughDZ9yZqD(vywINf0Kol9zjjHLESe29bfHzrzwailkyzOWUpOO8FDelaJf0WsFwssyjS7dkcZIYSexw6ZIcw8OCyNcazV5H)GL9wBP15oiSSF7ybW4ABD7nQCvnbAhB7nqchMl6pyzVHCarFwGflbq7np8hSS3S4ZCWjdBzsVkY(TJfaTgBRBVrLRQjq7yBV5H)GL9g(9PDdzVbs4WCr)bl7T4etSS9(0UHy5HSenWalBqTpSG(b9fHjwGdlw2PILRybw6uSGERYhwq)G(IWelEbYYctSGCarFwIgyaZY1y5kwqVv5dlOFqFryYElm3tZ52BuqFryYCvwVkFyjjHfkOVimzWqTp5Iq2ZsscluqFryY4vQCri7zjjHf1vRzS4ZCWjdBzsVkYSIyrblQRwZqb9fHPSEv(ywrSKKWspwuxTMj45RcMH68RWSamw8WFWYyz8F3qiJcRNY)1rSOGf1vRzcE(QGzfXsF73owaen2w3EZd)bl7nlJ)72Bu5QAc0o22VDSaiGY262Bu5QAc0o22BE4pyzVnRk7H)GvwF43EtF4pxEhzV1CT(3NL9B)2BoKSTUDSuY262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7TESOUAnZFDKf4uzWH8o1RaPXmuNFfMfGXcQaOPZrglaML0nkXssclQRwZ8xhzbovgCiVt9kqAmd15xHzbyS4H)GLb)(0UHmeYOW6P8FDelaML0nkXIcw6Xcf0xeMmxL1RYhwssyHc6lctgmu7tUiK9SKKWcf0xeMmELkxeYEw6ZsFwuWI6Q1m)1rwGtLbhY7uVcKgZkIffSmRIAWbfz(RJSaNkdoK3PEfingQCvnbAVbs4WCr)bl7nK66Ws7pHzXYo970WYVtSehhY7c(h2PHf1vRXILtRzP5AnlWwJfl3VFfl)oXsri7zj443EdHp5Y7i7nWH8USLtRZnxRZWwZ(TJfaTTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZkwOG(IWK5QmgQ9HffS0JfCeP153hu0Jn43N2nelXZcAyrblVRP6ny4sNHT8Vt5gCi8BOYv1eiljjSGJiTo)(GIESb)(0UHyjEwa0S03EdKWH5I(dw2Bi11HL2FcZILD63PHLT3h8AqrSCywSaNFNLGJ)RqXcebnSS9(0UHy5kwqVv5dlOFqFryYEdHp5Y7i7TdvbhkJFFWRbfz)2XkU2w3EJkxvtG2X2EZd)bl7TaSqabIY)oLXr3Cp2EdKWH5I(dw2BXjMybPWcbeiIfl7uXI)SOjmMLF3lwqt6SetmaKfVazrFfXYkIfl3VZcsJjsS2kyVfM7P5C7nRybCwhOPG5aiMffS0JLESGWNZv1KjaleqGOmiHtvbwuWIvSeGqni0szcE(QGzihmfljjSOUAntWZxfmRiw6ZIcw6XI6Q1muqFrykRxLpMH68RWSeplakwssyrD1AgkOVimLXqTpMH68RWSeplakw6ZIcw6XIvSmRIAWbfzuDTxbkdBzxRZ)(vOWgQCvnbYssclQRwZO6AVcug2YUwN)9RqHZL)RHm43daXs8SexwssyrD1Agvx7vGYWw2168VFfkC2NGxKb)EaiwINL4YsFwssyrfIXSOGL2HA)Zd15xHzbySOu6SOGfRyjaHAqOLYe88vbZqoykw6B)2XYASTU9gvUQMaTJT9Mh(dw2BJJGk4cNBdvXiL9giHdZf9hSS3ItmXsCyOkgPyXY97SG0yIeRTc2BH5EAo3EtD1AMGNVkygQZVcZs8SOeASF7yHgBRBVrLRQjq7yBV5H)GL9gEvTBi7TqQGMYVpOOhBhlLS3cZ90CU9wpwgQneE3v1eljjSOUAndf0xeMYyO2hZqD(vywaglXLffSqb9fHjZvzmu7dlkyzOo)kmlaJfLSgwuWY7AQEdgU0zyl)7uUbhc)gQCvnbYsFwuWY7dk6n)1r5hMbpIL4zrjRHfabl4isRZVpOOhZcGzzOo)kmlkyPhluqFryYCv2RuSKKWYqD(vywaglOcGMohzS03EdKWH5I(dw2BXjMyzBvTBiwUILiVaPUlWcSyXRu)(vOy539Nf9HGWSOK1GPaMfVazrtymlwUFNLo4qS8(GIEmlEbYI)S87elubYcSXIZYgu7dlOFqFryIf)zrjRHfmfWSahw0egZYqD(vxHIfhZYdzPGpl7oIRqXYdzzO2q4DwaxZvOyb9wLpSG(b9fHj73owakBRBVrLRQjq7yBV5H)GL9g(9P5AT9giHdZf9hSS3qoruelRiw2EFAUwZI)S4Anl)1rywwLMWyww4RqXc6Lk4JJzXlqwUNLdZIRcxplpKLObgyboSOPNLFNybhrHZ1S4H)Gfl6Riwujn0cl7EbQjwIJd5DQxbsdlWIfaYY7dk6X2BH5EAo3EZkwExt1BWpP1(KbNR9gQCvnbYIcw6XI6Q1m43NMR1MHAdH3DvnXIcw6XcoI0687dk6Xg87tZ1AwaglXLLKewSILzvudoOiZFDKf4uzWH8o1RaPXqLRQjqw6ZssclVRP6ny4sNHT8Vt5gCi8BOYv1eilkyrD1AgkOVimLXqTpMH68RWSamwIllkyHc6lctMRYyO2hwuWI6Q1m43NMR1MH68RWSamwa0SOGfCeP153hu0Jn43NMR1SeVYSynS0NffS0JfRyzwf1GdkYOtf8XX5MMO)kuzu6RlctgQCvnbYsscl)1rSGCzXAqdlXZI6Q1m43NMR1MH68RWSaywail9zrblVpOO38xhLFyg8iwINf0y)2XcqBBD7nQCvnbAhB7np8hSS3WVpnxRT3ajCyUO)GL9gYX97SS9Kw7dlXX5ApllmXcSyjaYILDQyzO2q4DxvtSOUEwW)P1SyXVNLgCyb9sf8XXSenWalEbYciSq7ZYctSOsn4qSG04i2WY2FAnllmXIk1GdXcsHfciqel4Rcel)U)Sy50AwIgyGfVG)onSS9(0CT2Elm3tZ52BVRP6n4N0AFYGZ1EdvUQMazrblQRwZGFFAUwBgQneE3v1elkyPhlwXYSkQbhuKrNk4JJZnnr)vOYO0xxeMmu5QAcKLKew(RJyb5YI1GgwINfRHL(SOGL3hu0B(RJYpmdEelXZsCTF7ybGTTU9gvUQMaTJT9Mh(dw2B43NMR12BGeomx0FWYEd54(DwIJd5DQxbsdllmXY27tZ1AwEilaruelRiw(DIf1vRXIAkwCngYYcFfkw2EFAUwZcSybnSGPaSaXSahw0egZYqD(vxHYElm3tZ52BZQOgCqrM)6ilWPYGd5DQxbsJHkxvtGSOGfCeP153hu0Jn43NMR1SeVYSexwuWspwSIf1vRz(RJSaNkdoK3PEfinMvelkyrD1Ag87tZ1AZqTHW7UQMyjjHLESGWNZv1KbCiVlB506CZ16mS1yrbl9yrD1Ag87tZ1AZqD(vywaglXLLKewWrKwNFFqrp2GFFAUwZs8SaqwuWY7AQEd(jT2Nm4CT3qLRQjqwuWI6Q1m43NMR1MH68RWSamwqdl9zPpl9TF7ybiTTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZX)46Ce0cnSepla40zbqWspwukDwaEwuxTM5VoYcCQm4qEN6vG0yWVhaIL(SaiyPhlQRwZGFFAUwBgQZVcZcWZsCzbjSGJiToV74Nyb4zXkwExt1BWpP1(KbNR9gQCvnbYsFwaeS0JLaeQbHwkd(9P5ATzOo)kmlaplXLfKWcoI068UJFIfGNL31u9g8tATpzW5AVHkxvtGS0Nfabl9ybe(M2AsLHTmPxfzgQZVcZcWZcAyPplkyPhlQRwZGFFAUwBwrSKKWsac1GqlLb)(0CT2muNFfML(2BGeomx0FWYEdPUoS0(tywSSt)onS4SS9(GxdkILfMyXYP1Se8fMyz79P5AnlpKLMR1SaBn0XIxGSSWelBVp41GIy5HSaerrSehhY7uVcKgwWVhaILvK9gcFYL3r2B43NMR1zlW6ZnxRZWwZ(TJLsPBBD7nQCvnbAhB7np8hSS3WVp41GIS3ajCyUO)GL9wCIjw2EFWRbfXIL73zjooK3PEfinS8qwaIOiwwrS87elQRwJfl3VdxplAi(kuSS9(0CTMLv0FDelEbYYctSS9(GxdkIfyXI1aywInmMwNf87bGWSSQ)0SynS8(GIES9wyUNMZT3q4Z5QAYaoK3LTCADU5ADg2ASOGfe(CUQMm43NMR1zlW6ZnxRZWwJffSyfli85CvnzoufCOm(9bVgueljjS0Jf1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGyjEwIlljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaelXZsCzPplkybhrAD(9bf9yd(9P5AnlaJfRHffSGWNZv1Kb)(0CToBbwFU5ADg2A2VDSusjBRBVrLRQjq7yBV5H)GL9Md6r)HGYyl(0zVfsf0u(9bf9y7yPK9wyUNMZT3SIL)caDfkwuWIvS4H)GLXb9O)qqzSfF6YGENJImxLB6d1(ZssclGW34GE0FiOm2IpDzqVZrrg87bGybySexwuWci8noOh9hckJT4txg07CuKzOo)kmlaJL4AVbs4WCr)bl7T4etSGT4thlyil)U)SKcUybf9S05iJLv0FDelQPyzHVcfl3ZIJzr7pXIJzjcIXNQMybwSOjmMLF3lwIll43daHzboSaGYc)SyzNkwIlGzb)EaimleYIUHSF7yPeaTTU9gvUQMaTJT9Mh(dw2BDqy1UHS3cPcAk)(GIESDSuYElm3tZ52Bd1gcV7QAIffS8(GIEZFDu(HzWJyjEw6XspwuYAybWS0JfCeP153hu0Jn43N2nelaplaKfGNf1vRzOG(IWuwVkFmRiw6ZsFwamld15xHzPpliHLESOelaML31u9M3Yv5oiSWgQCvnbYsFwuWspwcqOgeAPmbpFvWmKdMIffSyflGZ6anfmhaXSOGLESGWNZv1KjaleqGOmiHtvbwssyjaHAqOLYeGfciqu(3Pmo6M7XMHCWuSKKWIvSeGiOYR3uhQ9p3CIL(SKKWcoI0687dk6Xg87t7gIfGXspw6XcGIfabl9yrD1AgkOVimL1RYhZkIfGNfaYsFw6ZcWZspwuIfaZY7AQEZB5QChewydvUQMazPpl9zrblwXcf0xeMmyO2NCri7zjjHLESqb9fHjZvzmu7dljjS0JfkOVimzUkRc)DwssyHc6lctMRY6v5dl9zrblwXY7AQEdgU0zyl)7uUbhc)gQCvnbYssclQRwZenxhCapxN9j41fYrln2hdcxViwIxzwaiAsNL(SOGLESGJiTo)(GIESb)(0UHybySOu6Sa8S0JfLybWS8UMQ38wUk3bHf2qLRQjqw6ZsFwuWIJ)X15iOfAyjEwqt6SaiyrD1Ag87tZ1AZqD(vywaEwauS0NffS0JfRyrD1AgGUcCiWm1fbTqthvFMkAqDXGmRiwssyHc6lctMRYyO2hwssyXkwcqeu51Bak1CEXsFwuWIvSOUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5MvK9giHdZf9hSS3aqqTHW7SaGecR2nelxJfKgtKyTvGLdZYqoyk0XYVtdXIpelAcJz539If0WY7dk6XSCflO3Q8Hf0pOVimXIL73zzd(Xb0XIMWyw(DVyrP0zb(70y5WelxXIxPyb9d6lctSahwwrS8qwqdlVpOOhZIk1GdXIZc6TkFyb9d6lctgwIJWcTpld1gcVZc4AUcfliNUcCiqwq)UiOfA6O6zzvAcJz5kw2GAFyb9d6lct2VDSukU2w3EJkxvtG2X2EZd)bl7TgCcug2YL)RHS3ajCyUO)GL9wCIjwIdWyXcSyjaYIL73HRNLGhfDfk7TWCpnNBV5r5WofaY(TJLswJT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2BwXc4SoqtbZbqmlkybHpNRQjtamhGf49hSyrbl9yPhlQRwZGFFAUwBwrSKKWspwExt1BWpP1(KbNR9gQCvnbYssclbicQ86n1HA)ZnNyPpl9zrbl9yXkwuxTMbd14)cKzfXIcwSIf1vRzcE(QGzfXIcw6XIvS8UMQ30wtQmSLj9QidvUQMazjjHf1vRzcE(QGbCn(FWIL4zjaHAqOLY0wtQmSLj9QiZqD(vywamlayw6ZIcwq4Z5QAY87ZP1zmrart2IFplkyPhlwXsaIGkVEtDO2)CZjwssyjaHAqOLYeGfciqu(3Pmo6M7XMvelkyPhlQRwZGFFAUwBgQZVcZcWybGSKKWIvS8UMQ3GFsR9jdox7nu5QAcKL(S0NffS8(GIEZFDu(HzWJyjEwuxTMj45RcgW14)blwaEws3aOzPpljjSOcXywuWs7qT)5H68RWSamwuxTMj45RcgW14)blw6BVHWNC5DK9wamhGf49hSYoKSF7yPeASTU9gvUQMaTJT9Mh(dw2Bbst4)CD21hQQJQ3EdKWH5I(dw2BXjMybPXejwBfybwSeazzvAcJzXlqw0xrSCplRiwSC)olifwiGar2BH5EAo3EdHpNRQjtamhGf49hSYoKSF7yPeGY262Bu5QAc0o22BH5EAo3EdHpNRQjtamhGf49hSYoKS38WFWYE7QGpL)hSSF7yPeG2262Bu5QAc0o22BE4pyzVrDrql0KvHfO9giHdZf9hSS3ItmXc63fbTqdlXgwGSalwcGSy5(Dw2EFAUwZYkIfVazb7iiwAWHfa4sJ9HfVazbPXejwBfS3cZ90CU9MkeJzrblx90eb1(tG52HA)Zd15xHzbySOeAyjjHLESOUAnt0CDWb8CD2NGxxihT0yFmiC9IybySaq0KoljjSOUAnt0CDWb8CD2NGxxihT0yFmiC9IyjELzbGOjDw6ZIcwuxTMb)(0CT2SIyrbl9yjaHAqOLYe88vbZqD(vywINf0KoljjSaoRd0uWCaeZsF73owkbGTTU9gvUQMaTJT9Mh(dw2B4N0AFYnTpK9wivqt53hu0JTJLs2BH5EAo3EBO2q4DxvtSOGL)6O8dZGhXs8SOeAyrbl4isRZVpOOhBWVpTBiwaglwdlkyXJYHDkaelkyPhlQRwZe88vbZqD(vywINfLsNLKewSIf1vRzcE(QGzfXsF7nqchMl6pyzVbGGAdH3zPP9HybwSSIy5HSexwEFqrpMfl3VdxplinMiXARalQ0vOyXvHRNLhYcHSOBiw8cKLc(SarqtWJIUcL9BhlLaK2w3EJkxvtG2X2EZd)bl7T2AsLHTmPxfzVbs4WCr)bl7T4etSehGOplxJLRWhiXIxSG(b9fHjw8cKf9vel3ZYkIfl3VZIZcaCPX(Ws0adS4filXe0J(dbXYMfF6S3cZ90CU9gf0xeMmxL9kflkyXJYHDkaelkyrD1AMO56Gd456SpbVUqoAPX(yq46fXcWybGOjDwuWspwaHVXb9O)qqzSfF6YGENJIm)fa6kuSKKWIvSeGiOYR3uuyGA4aYsscl4isRZVpOOhZs8Saqw6ZIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJfajlacw6XcAyb4zzwf1GdkYGVQT059u4NMZnu5QAcKL(SOGf1vRzghbvWfo3gQIrkZkILKewSIf1vRzghbvWfo3gQIrkZkIL(SOGLESyflbiudcTuMGNVkywrSKKWI6Q1m)(CADgteq0yWVhaIfGXIsOHffS0ou7FEOo)kmlaJfaME6SOGL2HA)Zd15xHzjEwuk90zjjHfRybdxA1Rann)DDUPDlgQCvnbYsF73owamDBRBVrLRQjq7yBV5H)GL9g(9P5AT9giHdZf9hSS3ItmXIZY27tZ1Awaqx0VZs0adSSknHXSS9(0CTMLdZIRhYbtXYkIf4Wsk4IfFiwCv46z5HSarqtWJyjMyaO9wyUNMZT3uxTMbw0VJZr0eOO)GLzfXIcw6XI6Q1m43NMR1MHAdH3DvnXssclo(hxNJGwOHL4zbqMol9TF7ybqLSTU9gvUQMaTJT9Mh(dw2B43NMR12BGeomx0FWYEloU6IyjMyailQudoelifwiGarSy5(Dw2EFAUwZIxGS87uXY27dEnOi7TWCpnNBVfGiOYR3uhQ9p3CIffSyflVRP6n4N0AFYGZ1EdvUQMazrbl9ybHpNRQjtawiGarzqcNQcSKKWsac1GqlLj45RcMveljjSOUAntWZxfmRiw6ZIcwcqOgeAPmbyHaceL)DkJJU5ESzOo)kmlaJfubqtNJmwaEwc0PzPhlo(hxNJGwOHfKWcAsNL(SOGf1vRzWVpnxRnd15xHzbySynSOGfRybCwhOPG5ai2(TJfabOT1T3OYv1eODST3cZ90CU9waIGkVEtDO2)CZjwuWspwq4Z5QAYeGfciqugKWPQaljjSeGqni0szcE(QGzfXssclQRwZe88vbZkIL(SOGLaeQbHwktawiGar5FNY4OBUhBgQZVcZcWybqXIcwuxTMb)(0CT2SIyrbluqFryYCv2RuSOGfRybHpNRQjZHQGdLXVp41GIyrblwXc4SoqtbZbqS9Mh(dw2B43h8Aqr2VDSayCTTU9gvUQMaTJT9Mh(dw2B43h8Aqr2BGeomx0FWYEloXelBVp41GIyXY97S4flaOl63zjAGbwGdlxJLuWfAbzbIGMGhXsmXaqwSC)olPGRHLIq2ZsWXVHLyQXqwaxDrSetmaKf)z53jwOcKfyJLFNybavQ(9udlQRwJLRXY27tZ1AwSaxAWcTplnxRzb2ASahwsbxS4dXcSybGS8(GIES9wyUNMZT3uxTMbw0VJZbn5tgXHpyzwrSKKWspwSIf87t7gY4r5WofaIffSyfli85CvnzoufCOm(9bVgueljjS0Jf1vRzcE(QGzOo)kmlaJf0WIcwuxTMj45RcMveljjS0JLESOUAntWZxfmd15xHzbySGkaA6CKXcWZsGonl9yXX)46Ce0cnSGewIB6S0NffSOUAntWZxfmRiwssyrD1AMXrqfCHZTHQyKkJVQT059u4NMZnd15xHzbySGkaA6CKXcWZsGonl9yXX)46Ce0cnSGewIB6S0NffSOUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5Mvel9zrblbicQ86niO63tnS0NL(SOGLESGJiTo)(GIESb)(0CTMfGXsCzjjHfe(CUQMm43NMR1zlW6ZnxRZWwJL(S0NffSyfli85CvnzoufCOm(9bVguelkyPhlwXYSkQbhuK5VoYcCQm4qEN6vG0yOYv1eiljjSGJiTo)(GIESb)(0CTMfGXsCzPV9BhlaAn2w3EJkxvtG2X2EZd)bl7TISK7GWYEdKWH5I(dw2BXjMybajewywUILnO2hwq)G(IWelEbYc2rqSehwAnlaiHWILgCybPXejwBfS3cZ90CU9wpwuxTMHc6lctzmu7JzOo)kmlXZcHmkSEk)xhXsscl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKKWsy3hueMfLzjUS0NffS4r5WofaY(TJfarJT1T3OYv1eODST3cZ90CU9wpwuxTMHc6lctzmu7JzOo)kmlXZcHmkSEk)xhXsscl9yjS7dkcZIYSaqwuWYqHDFqr5)6iwaglOHL(SKKWsy3hueMfLzjUS0NffS4r5WofaIffS0Jf1vRzghbvWfo3gQIrkZqD(vywaglOHffSOUAnZ4iOcUW52qvmszwrSOGfRyzwf1GdkYGVQT059u4NMZnu5QAcKLKewSIf1vRzghbvWfo3gQIrkZkIL(2BE4pyzVT76wUdcl73owaeqzBD7nQCvnbAhB7TWCpnNBV1Jf1vRzOG(IWugd1(ygQZVcZs8SqiJcRNY)1rSOGLESeGqni0szcE(QGzOo)kmlXZcAsNLKewcqOgeAPmbyHaceL)DkJJU5ESzOo)kmlXZcAsNL(SKKWspwc7(GIWSOmlaKffSmuy3huu(VoIfGXcAyPpljjSe29bfHzrzwIll9zrblEuoStbGyrbl9yrD1AMXrqfCHZTHQyKYmuNFfMfGXcAyrblQRwZmocQGlCUnufJuMvelkyXkwMvrn4GIm4RAlDEpf(P5CdvUQMazjjHfRyrD1AMXrqfCHZTHQyKYSIyPV9Mh(dw2BTLwN7GWY(TJfab02w3EJkxvtG2X2EdKWH5I(dw2BXjMyb5aI(SalwqAC0EZd)bl7nl(mhCYWwM0RISF7ybqaST1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2B4isRZVpOOhBWVpTBiwINfRHfaZstdHdl9yPZXpnPYiC9Iyb4zrP0tNfKWcatNL(SaywAAiCyPhlQRwZGFFWRbfLPUiOfA6O6ZyO2hd(9aqSGewSgw6BVbs4WCr)bl7nK66Ws7pHzXYo970WYdzzHjw2EFA3qSCflBqTpSyz)c7SCyw8Nf0WY7dk6XawjwAWHfcbnPybGPJCzPZXpnPyboSynSS9(GxdkIf0VlcAHMoQEwWVhacBVHWNC5DK9g(9PDdLVkJHAFSF7ybqaPT1T3OYv1eODST3Gr2By6T38WFWYEdHpNRQj7neUEr2BkXcsybhrADE3XpXcWybGg0WcGGLESKUbGSa8SGJiTo)(GIESb)(0UHyb4zPhlkXcGz5DnvVbdx6mSL)Dk3GdHFdvUQMazb4zrjdAyPpl9zbWSKUrj0WcWZI6Q1mJJGk4cNBdvXiLzOo)kS9giHdZf9hSS3qQRdlT)eMfl70VtdlpKfKJX)DwaxZvOyjomufJu2Bi8jxEhzVzz8FpFvUnufJu2VDSIB62w3EJkxvtG2X2EZd)bl7nlJ)72BGeomx0FWYEloXelihJ)7SCflBqTpSG(b9fHjwGdlxJLcYY27t7gIflNwZs7EwU6HSG0yIeRTcS4vQo4q2BH5EAo3ERhluqFryYOxLp5Iq2ZsscluqFryY4vQCri7zrbli85CvnzoCoOjhbXsFwuWspwEFqrV5Vok)Wm4rSeplwdljjSqb9fHjJEv(KVkdqwssyPDO2)8qD(vywaglkLol9zjjHf1vRzOG(IWugd1(ygQZVcZcWyXd)bld(9PDdziKrH1t5)6iwuWI6Q1muqFrykJHAFmRiwssyHc6lctMRYyO2hwuWIvSGWNZv1Kb)(0UHYxLXqTpSKKWI6Q1mbpFvWmuNFfMfGXIh(dwg87t7gYqiJcRNY)1rSOGfRybHpNRQjZHZbn5iiwuWI6Q1mbpFvWmuNFfMfGXcHmkSEk)xhXIcwuxTMj45RcMveljjSOUAnZ4iOcUW52qvmszwrSOGfe(CUQMmwg)3ZxLBdvXifljjSyfli85CvnzoCoOjhbXIcwuxTMj45RcMH68RWSepleYOW6P8FDK9BhR4QKT1T3OYv1eODST3ajCyUO)GL9wCIjw2EFA3qSCnwUIf0Bv(Wc6h0xeMqhlxXYgu7dlOFqFryIfyXI1aywEFqrpMf4WYdzjAGbw2GAFyb9d6lct2BE4pyzVHFFA3q2VDSIlaTTU9gvUQMaTJT9giHdZf9hSS3IdUw)7ZYEZd)bl7Tzvzp8hSY6d)2B6d)5Y7i7TMR1)(SSF73ER5A9VplBRBhlLSTU9gvUQMaTJT9Mh(dw2B43h8Aqr2BGeomx0FWYEB79bVgueln4Wsheb1r1ZYQ0egZYcFfkwInmMw3Elm3tZ52BwXYSkQbhuKr11EfOmSLDTo)7xHcBiG76IIiq73owa0262Bu5QAc0o22BE4pyzVHxv7gYElKkOP87dk6X2Xsj7TWCpnNBVbcFthewTBiZqD(vywINLH68RWSa8SaqaYcsyrjaS9giHdZf9hSS3qQJFw(DIfq4ZIL73z53jw6G4NL)6iwEiloiilR6pnl)oXsNJmwaxJ)hSy5WSSFVHLTv1UHyzOo)kmlDl9Fr6Jaz5HS05FyNLoiSA3qSaUg)pyz)2XkU2w3EZd)bl7ToiSA3q2Bu5QAc0o22V9BVHFBRBhlLSTU9gvUQMaTJT9Mh(dw2B43h8Aqr2BGeomx0FWYEloXelBVp41GIy5HSaerrSSIy53jwIJd5DQxbsdlQRwJLRXY9SybU0GSqil6gIfvQbhIL2vhE)kuS87elfHSNLGJFwGdlpKfWvxelQudoelifwiGar2BH5EAo3EBwf1GdkY8xhzbovgCiVt9kqAmu5QAcKffS0JfkOVimzUk7vkwuWIvS0JLESOUAnZFDKf4uzWH8o1RaPXmuNFfML4zXd)blJLX)DdHmkSEk)xhXcGzjDJsSOGLESqb9fHjZvzv4VZsscluqFryYCvgd1(WsscluqFryYOxLp5Iq2ZsFwssyrD1AM)6ilWPYGd5DQxbsJzOo)kmlXZIh(dwg87t7gYqiJcRNY)1rSayws3OelkyPhluqFryYCvwVkFyjjHfkOVimzWqTp5Iq2ZsscluqFryY4vQCri7zPpl9zjjHfRyrD1AM)6ilWPYGd5DQxbsJzfXsFwssyPhlQRwZe88vbZkILKewq4Z5QAYeGfciqugKWPQal9zrblbiudcTuMaSqabIY)oLXr3Cp2mKdMIffSeGiOYR3uhQ9p3CIL(SOGLESyflbicQ86naLAoVyjjHLaeQbHwkd1fbTqtwfwGMH68RWSeplayw6ZIcw6XI6Q1mbpFvWSIyjjHfRyjaHAqOLYe88vbZqoykw6B)2XcG2w3EJkxvtG2X2EZd)bl7nh0J(dbLXw8PZElKkOP87dk6X2Xsj7TWCpnNBVzflGW34GE0FiOm2IpDzqVZrrM)caDfkwuWIvS4H)GLXb9O)qqzSfF6YGENJImxLB6d1(ZIcw6XIvSacFJd6r)HGYyl(0L3jxB(la0vOyjjHfq4BCqp6peugBXNU8o5AZqD(vywINf0WsFwssybe(gh0J(dbLXw8Pld6DokYGFpaelaJL4YIcwaHVXb9O)qqzSfF6YGENJImd15xHzbySexwuWci8noOh9hckJT4txg07CuK5VaqxHYEdKWH5I(dw2BXjMyjMGE0Fiiw2S4thlw2PILFNgILdZsbzXd)HGybBXNo0XIJzr7pXIJzjcIXNQMybwSGT4thlwUFNfaYcCyPrwOHf87bGWSahwGflolXfWSGT4thlyil)U)S87elfzHfSfF6yXN5qqywaqzHFw82tdl)U)SGT4thleYIUHW2VDSIRT1T3OYv1eODST38WFWYElaleqGO8VtzC0n3JT3ajCyUO)GL9wCIjmlifwiGarSCnwqAmrI1wbwomlRiwGdlPGlw8HybKWPQWvOybPXejwBfyXY97SGuyHaceXIxGSKcUyXhIfvsdTWI1KolXedaT3cZ90CU9MvSaoRd0uWCaeZIcw6Xspwq4Z5QAYeGfciqugKWPQalkyXkwcqOgeAPmbpFvWmKdMIffSyflZQOgCqrMO56Gd456SpbVUqoAPX(yOYv1eiljjSOUAntWZxfmRiw6ZIcwC8pUohbTqdlaJfRjDwuWspwuxTMHc6lctz9Q8XmuNFfML4zrP0zjjHf1vRzOG(IWugd1(ygQZVcZs8SOu6S0NLKewuHymlkyPDO2)8qD(vywaglkLolkyXkwcqOgeAPmbpFvWmKdMIL(2VDSSgBRBVrLRQjq7yBVbJS3W0BV5H)GL9gcFoxvt2BiC9IS36XI6Q1mJJGk4cNBdvXiLzOo)kmlXZcAyjjHfRyrD1AMXrqfCHZTHQyKYSIyPplkyXkwuxTMzCeubx4CBOkgPY4RAlDEpf(P5CZkIffS0Jf1vRza6kWHaZuxe0cnDu9zQOb1fdYmuNFfMfGXcQaOPZrgl9zrbl9yrD1AgkOVimLXqTpMH68RWSeplOcGMohzSKKWI6Q1muqFrykRxLpMH68RWSeplOcGMohzSKKWspwSIf1vRzOG(IWuwVkFmRiwssyXkwuxTMHc6lctzmu7JzfXsFwuWIvS8UMQ3GHA8FbYqLRQjqw6BVbs4WCr)bl7nKclW7pyXsdoS4AnlGWhZYV7plDoqeMf8Aiw(Dkfl(qfAFwgQneENazXYovSaGWrqfCHzjomufJuSS7yw0egZYV7flOHfmfWSmuNF1vOyboS87elaLAoVyrD1ASCywCv46z5HS0CTMfyRXcCyXRuSG(b9fHjwomlUkC9S8qwiKfDdzVHWNC5DK9gi8ZdbCx3qDu9y73owOX262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7TESyflQRwZqb9fHPmgQ9XSIyrblwXI6Q1muqFrykRxLpMvel9zjjHL31u9gmuJ)lqgQCvnbAVbs4WCr)bl7nKclW7pyXYV7plHDkaeMLRXsk4IfFiwGRhFGeluqFryILhYcS0Pybe(S870qSahwoufCiw(9dZIL73zzdQX)fi7ne(KlVJS3aHFgUE8bszkOVimz)2XcqzBD7nQCvnbAhB7np8hSS36GWQDdzVfM7P5C7THAdH3DvnXIcw6XI6Q1muqFrykJHAFmd15xHzjEwgQZVcZssclQRwZqb9fHPSEv(ygQZVcZs8SmuNFfMLKewq4Z5QAYac)mC94dKYuqFryIL(SOGLHAdH3DvnXIcwEFqrV5Vok)Wm4rSeplkbqwuWIhLd7uaiwuWccFoxvtgq4Nhc4UUH6O6X2BHubnLFFqrp2owkz)2XcqBBD7nQCvnbAhB7np8hSS3WRQDdzVfM7P5C7THAdH3DvnXIcw6XI6Q1muqFrykJHAFmd15xHzjEwgQZVcZssclQRwZqb9fHPSEv(ygQZVcZs8SmuNFfMLKewq4Z5QAYac)mC94dKYuqFryIL(SOGLHAdH3DvnXIcwEFqrV5Vok)Wm4rSeplkbqwuWIhLd7uaiwuWccFoxvtgq4Nhc4UUH6O6X2BHubnLFFqrp2owkz)2XcaBBD7nQCvnbAhB7np8hSS3WpP1(KBAFi7TWCpnNBVnuBi8URQjwuWspwuxTMHc6lctzmu7JzOo)kmlXZYqD(vywssyrD1AgkOVimL1RYhZqD(vywINLH68RWSKKWccFoxvtgq4NHRhFGuMc6lctS0NffSmuBi8URQjwuWY7dk6n)1r5hMbpIL4zrjaflkyXJYHDkaelkybHpNRQjdi8ZdbCx3qDu9y7TqQGMYVpOOhBhlLSF7ybiTTU9gvUQMaTJT9Mh(dw2Bn4eOmSLl)xdzVbs4WCr)bl7T4etSehGXIfyXsaKfl3Vdxplbpk6ku2BH5EAo3EZJYHDkaK9BhlLs3262Bu5QAc0o22BE4pyzVrDrql0KvHfO9giHdZf9hSS3ItmXcYPRahcKLTOBUhZIL73zXRuSOHfkwOcUqTZI2X)vOyb9d6lctS4fil)KILhYI(kIL7zzfXIL73zbaU0yFyXlqwqAmrI1wb7TWCpnNBV1JLESOUAndf0xeMYyO2hZqD(vywINfLsNLKewuxTMHc6lctz9Q8XmuNFfML4zrP0zPplkyjaHAqOLYe88vbZqD(vywINL4MolkyPhlQRwZenxhCapxN9j41fYrln2hdcxViwagla0AsNLKewSILzvudoOit0CDWb8CD2NGxxihT0yFmeWDDrreil9zPpljjSOUAnt0CDWb8CD2NGxxihT0yFmiC9IyjELzbGa60zjjHLaeQbHwktWZxfmd5GPyrblo(hxNJGwOHL4zbqMU9BhlLuY262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7nRybCwhOPG5aiMffSGWNZv1KjaMdWc8(dwSOGLES0JLaeQbHwkd1fLAixNHdy5vGmd15xHzbySOeGcqZcGzPhlkPelaplZQOgCqrg8vTLoVNc)0CUHkxvtGS0NffSqa31ffrGgQlk1qUodhWYRaXsFwssyXX)46Ce0cnSeVYSaitNffS0JfRy5DnvVPTMuzylt6vrgQCvnbYssclQRwZe88vbd4A8)GflXZsac1GqlLPTMuzylt6vrMH68RWSaywaWS0NffSGWNZv1K53NtRZyIaIMSf)EwuWspwuxTMbORahcmtDrql00r1NPIguxmiZkILKewSILaebvE9gGsnNxS0NffS8(GIEZFDu(HzWJyjEwuxTMj45RcgW14)blwaEws3aOzjjHfvigZIcwAhQ9ppuNFfMfGXI6Q1mbpFvWaUg)pyXssclbicQ86n1HA)ZnNyjjHf1vRzu1qiOEHFZkIffSOUAnJQgcb1l8BgQZVcZcWyrD1AMGNVkyaxJ)hSybWS0JfajlaplZQOgCqrMO56Gd456SpbVUqoAPX(yiG76IIiqw6ZsFwuWIvSOUAntWZxfmRiwuWspwSILaebvE9M6qT)5MtSKKWsac1GqlLjaleqGO8VtzC0n3JnRiwssyrfIXSOGL2HA)Zd15xHzbySeGqni0szcWcbeik)7ughDZ9yZqD(vywamlakwssyPDO2)8qD(vywqUSOeaoDwaglQRwZe88vbd4A8)Gfl9T3ajCyUO)GL9wCIjwqAmrI1wbwSC)olifwiGarib50vGdbYYw0n3JzXlqwaHfAFwGiOXYCpXcaCPX(WcCyXYovSeBnecQx4NflWLgKfczr3qSOsn4qSG0yIeRTcSqil6gcBVHWNC5DK9wamhGf49hSY43(TJLsa0262Bu5QAc0o22BE4pyzVnocQGlCUnufJu2BGeomx0FWYEloXel)oXcaQu97PgwSC)ololinMiXARal)U)SC4cTplTb2XcaCPX(yVfM7P5C7n1vRzcE(QGzOo)kmlXZIsOHLKewuxTMj45RcgW14)blwaglXnDwuWccFoxvtMayoalW7pyLXV9BhlLIRT1T3OYv1eODST3cZ90CU9gcFoxvtMayoalW7pyLXplkyPhlwXI6Q1mbpFvWaUg)pyXs8Se30zjjHfRyjarqLxVbbv)EQHL(SKKWI6Q1mJJGk4cNBdvXiLzfXIcwuxTMzCeubx4CBOkgPmd15xHzbySaizbWSeGf46Et0qHdtzxFOQoQEZFDugHRxelaMLESyflQRwZOQHqq9c)MvelkyXkwExt1BWVpA4aAOYv1eil9T38WFWYElqAc)NRZU(qvDu92VDSuYASTU9gvUQMaTJT9wyUNMZT3q4Z5QAYeaZbybE)bRm(T38WFWYE7QGpL)hSSF7yPeASTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEZkwcqOgeAPmbpFvWmKdMILKewSIfe(CUQMmbyHaceLbjCQkWIcwcqeu51BQd1(NBoXssclGZ6anfmhaX2BGeomx0FWYEdavFoxvtSSWeilWIfx903FeMLF3FwS41ZYdzrLyb7iiqwAWHfKgtKyTvGfmKLF3Fw(Dkfl(q1ZIfh)eilaOSWplQudoel)o1zVHWNC5DK9g2rq5gCYbpFvW(TJLsakBRBVrLRQjq7yBV5H)GL9wBnPYWwM0RIS3ajCyUO)GL9wCIjmlXbi6ZY1y5kw8If0pOVimXIxGS8ZrywEil6RiwUNLvelwUFNfa4sJ9bDSG0yIeRTcS4filXe0J(dbXYMfF6S3cZ90CU9gf0xeMmxL9kflkyXJYHDkaelkyrD1AMO56Gd456SpbVUqoAPX(yq46fXcWybGwt6SOGLESacFJd6r)HGYyl(0Lb9ohfz(la0vOyjjHfRyjarqLxVPOWa1WbKL(SOGfe(CUQMmyhbLBWjh88vbwuWspwuxTMzCeubx4CBOkgPmd15xHzbySaizbqWspwqdlaplZQOgCqrg8vTLoVNc)0CUHkxvtGS0NffSOUAnZ4iOcUW52qvmszwrSKKWIvSOUAnZ4iOcUW52qvmszwrS03(TJLsaABRBVrLRQjq7yBV5H)GL9g(9P5AT9giHdZf9hSS3ItmXca6I(Dw2EFAUwZs0adywUglBVpnxRz5WfAFwwr2BH5EAo3EtD1Agyr)oohrtGI(dwMvelkyrD1Ag87tZ1AZqTHW7UQMSF7yPea2262Bu5QAc0o22BH5EAo3EtD1Ag87JgoGMH68RWSamwqdlkyPhlQRwZqb9fHPmgQ9XmuNFfML4zbnSKKWI6Q1muqFrykRxLpMH68RWSeplOHL(SOGfh)JRZrql0Ws8Sait3EZd)bl7TGxbsNvxTM9M6Q1YL3r2B43hnCaTF7yPeG0262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T44QlcZsmXaqwuPgCiwqkSqabIyzHVcfl)oXcsHfciqelbybE)blwEilHDkaelxJfKcleqGiwomlE4xUwNIfxfUEwEilQelbh)2BH5EAo3ElarqLxVPou7FU5elkybHpNRQjtawiGarzqcNQcSOGLaeQbHwktawiGar5FNY4OBUhBgQZVcZcWybnSOGfRybCwhOPG5ai2(TJfat3262Bu5QAc0o22BE4pyzVHFFAUwBVbs4WCr)bl7T4etSS9(0CTMfl3VZY2tATpSehNR9S4filfKLT3hnCarhlw2PILcYY27tZ1AwomlRi0Xsk4IfFiwUIf0Bv(Wc6h0xeMyPbhwaWagtbmlWHLhYs0adSaaxASpSyzNkwCvicIfaz6SetmaKf4WIdg5)HGybBXNow2DmlayaJPaMLH68RUcflWHLdZYvS00hQ93WsSGpXYV7plRcKgw(DIfS3rSeGf49hSWSCpAXSagHzPO1pUMLhYY27tZ1AwaxZvOybaHJGk4cZsCyOkgPqhlw2PILuWfAbzb)NwZcvGSSIyXY97SaithWooILgCy53jw0o(zbLgQ6ASXElm3tZ52BVRP6n4N0AFYGZ1EdvUQMazrblwXY7AQEd(9rdhqdvUQMazrblQRwZGFFAUwBgQneE3v1elkyPhlQRwZqb9fHPSEv(ygQZVcZs8SaGzrbluqFryYCvwVkFyrblQRwZenxhCapxN9j41fYrln2hdcxViwaglaenPZssclQRwZenxhCapxN9j41fYrln2hdcxViwIxzwaiAsNffS44FCDocAHgwINfaz6SKKWci8noOh9hckJT4txg07CuKzOo)kmlXZcaMLKew8WFWY4GE0FiOm2IpDzqVZrrMRYn9HA)zPplkyjaHAqOLYe88vbZqD(vywINfLs3(TJfavY262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T4etSS9(GxdkIfa0f97SenWaMfVazbC1fXsmXaqwSStflinMiXARalWHLFNybavQ(9udlQRwJLdZIRcxplpKLMR1SaBnwGdlPGl0cYsWJyjMyaO9wyUNMZT3uxTMbw0VJZbn5tgXHpyzwrSKKWI6Q1maDf4qGzQlcAHMoQ(mv0G6IbzwrSKKWI6Q1mbpFvWSIyrbl9yrD1AMXrqfCHZTHQyKYmuNFfMfGXcQaOPZrglaplb60S0Jfh)JRZrql0WcsyjUPZsFwamlXLfGNL31u9MISK7GWYqLRQjqwuWIvSmRIAWbfzWx1w68Ek8tZ5gQCvnbYIcwuxTMzCeubx4CBOkgPmRiwssyrD1AMGNVkygQZVcZcWybva005iJfGNLaDAw6XIJ)X15iOfAybjSe30zPpljjSOUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5MveljjSyflQRwZmocQGlCUnufJuMvelkyXkwcqOgeAPmJJGk4cNBdvXiLzihmfljjSyflbicQ86niO63tnS0NLKewC8pUohbTqdlXZcGmDwuWcf0xeMmxL9kL9BhlacqBRBVrLRQjq7yBV5H)GL9g(9bVguK9giHdZf9hSS3S(KILhYsNdeXYVtSOs4NfyJLT3hnCazrnfl43daDfkwUNLvela31fasNILRyXRuSG(b9fHjwuxplaWLg7dlhUEwCv46z5HSOsSenWqGaT3cZ90CU927AQEd(9rdhqdvUQMazrblwXYSkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkyPhlQRwZGFF0Wb0SIyjjHfh)JRZrql0Ws8SaitNL(SOGf1vRzWVpA4aAWVhaIfGXsCzrbl9yrD1AgkOVimLXqTpMveljjSOUAndf0xeMY6v5JzfXsFwuWI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lIfGXcab0PZIcw6Xsac1GqlLj45RcMH68RWSeplkLoljjSyfli85CvnzcWcbeikds4uvGffSeGiOYR3uhQ9p3CIL(2VDSayCTTU9gvUQMaTJT9gmYEdtV9Mh(dw2Bi85CvnzVHW1lYEJc6lctMRY6v5dlaplaywqclE4pyzWVpTBidHmkSEk)xhXcGzXkwOG(IWK5QSEv(WcWZspwauSaywExt1BWWLodB5FNYn4q43qLRQjqwaEwIll9zbjS4H)GLXY4)UHqgfwpL)RJybWSKUXAqdliHfCeP15Dh)elaML0nOHfGNL31u9MY)1q4SQR9kqgQCvnbAVbs4WCr)bl7n0h)xN)eMLDOfw6wHDwIjgaYIpelO8RiqwIOHfmfGfO9gcFYL3r2BoocasZgfSF7ybqRX262Bu5QAc0o22BE4pyzVHFFWRbfzVbs4WCr)bl7T44QlILT3h8AqrSCflolaAaJPalBqTpSG(b9fHj0XciSq7ZIMEwUNLObgybaU0yFyP3V7plhMLDVa1eilQPyHUFNgw(DILT3NMR1SOVIyboS87elXedaJhqMol6RiwAWHLT3h8Aqr9rhlGWcTplqe0yzUNyXlwaqx0VZs0adS4filA6z53jwCvicIf9vel7EbQjw2EF0Wb0Elm3tZ52BwXYSkQbhuK5VoYcCQm4qEN6vG0yOYv1eilkyPhlQRwZenxhCapxN9j41fYrln2hdcxViwaglaeqNoljjSOUAnt0CDWb8CD2NGxxihT0yFmiC9IybySaq0Kolky5DnvVb)Kw7tgCU2BOYv1eil9zrbl9yHc6lctMRYyO2hwuWIJ)X15iOfAybWSGWNZv1KXXraqA2OalaplQRwZqb9fHPmgQ9XmuNFfMfaZci8nT1KkdBzsVkY8xaiCEOo)kwaEwaObnSepla40zjjHfkOVimzUkRxLpSOGfh)JRZrql0WcGzbHpNRQjJJJaG0SrbwaEwuxTMHc6lctz9Q8XmuNFfMfaZci8nT1KkdBzsVkY8xaiCEOo)kwaEwaObnSeplaY0zPplkyXkwuxTMbw0VJZr0eOO)GLzfXIcwSIL31u9g87JgoGgQCvnbYIcw6Xsac1GqlLj45RcMH68RWSeplaAwssybdxA1Ran)(CADgteq0yOYv1eilkyrD1AMFFoToJjciAm43daXcWyjUXLfabl9yzwf1GdkYGVQT059u4NMZnu5QAcKfGNf0WsFwuWs7qT)5H68RWSeplkLE6SOGL2HA)Zd15xHzbySaW0tNL(SOGLESeGqni0sza6kWHaZ4OBUhBgQZVcZs8SaOzjjHfRyjarqLxVbOuZ5fl9TF7ybq0yBD7nQCvnbAhB7np8hSS3kYsUdcl7nqchMl6pyzVfNyIfaKqyHz5kwqVv5dlOFqFryIfVazb7iiwqoJRBaooS0AwaqcHfln4WcsJjsS2kWIxGSGC6kWHazb97IGwOPJQ3Elm3tZ52B9yrD1AgkOVimL1RYhZqD(vywINfczuy9u(VoILKew6Xsy3hueMfLzbGSOGLHc7(GIY)1rSamwqdl9zjjHLWUpOimlkZsCzPplkyXJYHDkaelkybHpNRQjd2rq5gCYbpFvW(TJfabu2w3EJkxvtG2X2Elm3tZ52B9yrD1AgkOVimL1RYhZqD(vywINfczuy9u(VoIffSyflbicQ86naLAoVyjjHLESOUAndqxboeyM6IGwOPJQptfnOUyqMvelkyjarqLxVbOuZ5fl9zjjHLESe29bfHzrzwailkyzOWUpOO8FDelaJf0WsFwssyjS7dkcZIYSexwssyrD1AMGNVkywrS0NffS4r5WofaIffSGWNZv1Kb7iOCdo5GNVkWIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJLESGgwaeSaqwaEwMvrn4GIm4RAlDEpf(P5CdvUQMazPplkyrD1AMXrqfCHZTHQyKYSIyjjHfRyrD1AMXrqfCHZTHQyKYSIyPV9Mh(dw2B7UUL7GWY(TJfab02w3EJkxvtG2X2Elm3tZ52B9yrD1AgkOVimL1RYhZqD(vywINfczuy9u(VoIffSyflbicQ86naLAoVyjjHLESOUAndqxboeyM6IGwOPJQptfnOUyqMvelkyjarqLxVbOuZ5fl9zjjHLESe29bfHzrzwailkyzOWUpOO8FDelaJf0WsFwssyjS7dkcZIYSexwssyrD1AMGNVkywrS0NffS4r5WofaIffSGWNZv1Kb7iOCdo5GNVkWIcw6XI6Q1mJJGk4cNBdvXiLzOo)kmlaJf0WIcwuxTMzCeubx4CBOkgPmRiwuWIvSmRIAWbfzWx1w68Ek8tZ5gQCvnbYssclwXI6Q1mJJGk4cNBdvXiLzfXsF7np8hSS3AlTo3bHL9BhlacGTTU9gvUQMaTJT9giHdZf9hSS3ItmXcYbe9zbwSeaT38WFWYEZIpZbNmSLj9Qi73owaeqABD7nQCvnbAhB7np8hSS3WVpTBi7nqchMl6pyzVfNyILT3N2nelpKLObgyzdQ9Hf0pOVimHowqAmrI1wbw2DmlAcJz5VoILF3lwCwqog)3zHqgfwpXIMAplWHfyPtXc6TkFyb9d6lctSCywwr2BH5EAo3EJc6lctMRY6v5dljjSqb9fHjdgQ9jxeYEwssyHc6lctgVsLlczpljjS0Jf1vRzS4ZCWjdBzsVkYSIyjjHfCeP15Dh)elaJL0nwdAyrblwXsaIGkVEdcQ(9udljjSGJiToV74NybySKUXAyrblbicQ86niO63tnS0NffSOUAndf0xeMY6v5JzfXsscl9yrD1AMGNVkygQZVcZcWyXd)blJLX)DdHmkSEk)xhXIcwuxTMj45RcMvel9TF7yf30TTU9gvUQMaTJT9giHdZf9hSS3ItmXcYX4)olWFNglhMyXY(f2z5WSCflBqTpSG(b9fHj0XcsJjsS2kWcCy5HSenWalO3Q8Hf0pOVimzV5H)GL9MLX)D73owXvjBRBVrLRQjq7yBVbs4WCr)bl7T4GR1)(SS38WFWYEBwv2d)bRS(WV9M(WFU8oYER5A9Vpl73(T3Igka7u93262XsjBRBV5H)GL9gqxboeyghDZ9y7nQCvnbAhB73owa0262Bu5QAc0o22BWi7nm92BE4pyzVHWNZv1K9gcxVi7T0T3ajCyUO)GL9M13jwq4Z5QAILdZcMEwEilPZIL73zPGSGF)zbwSSWel)Cfq0JrhlkXILDQy53jwA3GFwGfXYHzbwSSWe6ybGSCnw(DIfmfGfilhMfVazjUSCnwuH)ol(q2Bi8jxEhzVbR8ct5FUci6TF7yfxBRBVrLRQjq7yBVbJS3Cqq7np8hSS3q4Z5QAYEdHRxK9Ms2BH5EAo3E7NRaIEZRKzHDvnXIcw(5kGO38kzcqOgeAPmGRX)dw2Bi8jxEhzVbR8ct5FUci6TF7yzn2w3EJkxvtG2X2EdgzV5GG2BE4pyzVHWNZv1K9gcxVi7naAVfM7P5C7TFUci6npanlSRQjwuWYpxbe9MhGMaeQbHwkd4A8)GL9gcFYL3r2BWkVWu(NRaIE73owOX262Bu5QAc0o22BWi7nhe0EZd)bl7ne(CUQMS3q4tU8oYEdw5fMY)Cfq0BVfM7P5C7nc4UUOic0CfomR3v1ug4U86xDzqcXfiwssyHaURlkIanuxuQHCDgoGLxbILKewiG76IIiqdgU0A6)RqLNLAk7nqchMl6pyzVz9DctS8ZvarpMfFiwk4ZIV(o)VGR1PybKEk8eiloMfyXYctSGF)z5NRaIESHLyQT4PWS4GGxHIfLyPJ8cZYVtPyXYP1S4AlEkmlQelrd1OziqwUcKIOcKQNfyJfSg(2BiC9IS3uY(TJfGY262BE4pyzV1bHfqxLBWPZEJkxvtG2X2(TJfG2262Bu5QAc0o22BE4pyzVzz8F3EtFfLdG2BkLU9wyUNMZT36Xcf0xeMm6v5tUiK9SKKWcf0xeMmxLXqTpSKKWcf0xeMmxLvH)oljjSqb9fHjJxPYfHSNL(2BGeomx0FWYEdaouWXplaKfKJX)Dw8cKfNLT3h8AqrSalw2SolwUFNLyDO2FwIdoXIxGSeBymTolWHLT3N2nelWFNglhMSF7ybGTTU9gvUQMaTJT9wyUNMZT36Xcf0xeMm6v5tUiK9SKKWcf0xeMmxLXqTpSKKWcf0xeMmxLvH)oljjSqb9fHjJxPYfHSNL(SOGLOHqyuYyz8FNffSyflrdHWaqJLX)D7np8hSS3Sm(VB)2XcqABD7nQCvnbAhB7TWCpnNBVzflZQOgCqrgvx7vGYWw2168VFfkSHkxvtGSKKWIvSeGiOYR3uhQ9p3CILKewSIfCeP153hu0Jn43NMR1SOmlkXssclwXY7AQEt5)AiCw11EfidvUQMazjjHLESqb9fHjdgQ9jxeYEwssyHc6lctMRY6v5dljjSqb9fHjZvzv4VZsscluqFryY4vQCri7zPV9Mh(dw2B43N2nK9BhlLs3262Bu5QAc0o22BH5EAo3EBwf1GdkYO6AVcug2YUwN)9RqHnu5QAcKffSeGiOYR3uhQ9p3CIffSGJiTo)(GIESb)(0CTMfLzrj7np8hSS3WVp41GISF73(T3qqd(GLDSay6auP0buaeqBVzXN6kuy7nKJycGiwwBSqoh4WclwFNy56IGZZsdoSGwqQ5l9Jwwgc4UUHazbd7iw81d78NazjS7fkcB40qVRiwSgGdlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0tjK13WPHExrSynahwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIybnahwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtd9UIybqbCybPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEaez9nCAO3velaAGdlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSaOboSGuyHGMNazbT)Cfq0BuYaaqllpKf0(ZvarV5vYaaqll9aiY6B40qVRiwa0ahwqkSqqZtGSG2FUci6na0aaqllpKf0(ZvarV5bObaGww6bqK13WPHExrSaGboSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcGe4WcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velkLoWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwusjGdlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSOeaboSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspaIS(gon07kIfLaiWHfKcle08eilO9NRaIEJsgaaAz5HSG2FUci6nVsgaaAzPharwFdNg6DfXIsae4WcsHfcAEcKf0(ZvarVbGgaaAz5HSG2FUci6npanaa0YspLqwFdNg6DfXIsXf4WcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9aiY6B40qVRiwukUahwqkSqqZtGSG2FUci6nkzaaOLLhYcA)5kGO38kzaaOLLEkHS(gon07kIfLIlWHfKcle08eilO9NRaIEdanaa0YYdzbT)Cfq0BEaAaaOLLEaez9nCAO3velkznahwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPharwFdNgNgYrmbqelRnwiNdCyHfRVtSCDrW5zPbhwqB0qbyNQ)OLLHaURBiqwWWoIfF9Wo)jqwc7EHIWgon07kIL4cCybPWcbnpbYcA)5kGO3OKbaGwwEilO9NRaIEZRKbaGww6bqK13WPHExrSynahwqkSqqZtGSG2FUci6na0aaqllpKf0(ZvarV5bObaGww6bqK13WPHExrSaiboSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXIsPdCybPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEkHS(gononKJycGiwwBSqoh4WclwFNy56IGZZsdoSGwhsOLLHaURBiqwWWoIfF9Wo)jqwc7EHIWgon07kIfLaoSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YI)SG(aOrpw6PeY6B40qVRiwIlWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwauahwqkSqqZtGSSDDiLfCQ6DKXcYf5YYdzb9wolDqWLEHzbgrJ)WHLEi3(S0tjK13WPHExrSaOaoSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspaIS(gon07kIfanWHfKcle08eilBxhszbNQEhzSGCrUS8qwqVLZsheCPxywGr04pCyPhYTpl9ucz9nCAO3velaAGdlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSaGboSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcGe4WcsHfcAEcKLTRdPSGtvVJmwqUS8qwqVLZc4H4WhSybgrJ)WHLEiPpl9aiY6B40qVRiwucGahwqkSqqZtGSSDDiLfCQ6DKXcYLLhYc6TCwapeh(GflWiA8hoS0dj9zPNsiRVHtd9UIyrjajWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwaOsahwqkSqqZtGSSDDiLfCQ6DKXcYLLhYc6TCwapeh(GflWiA8hoS0dj9zPNsiRVHtd9UIybGXf4WcsHfcAEcKLTRdPSGtvVJmwqUS8qwqVLZc4H4WhSybgrJ)WHLEiPpl9aiY6B40qVRiwayCboSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcardWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwaiGc4WcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velaeadCybPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEaez9nCAO3velaeqcCybPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEkHS(gononKJycGiwwBSqoh4WclwFNy56IGZZsdoSG2MR1)(SqlldbCx3qGSGHDel(6HD(tGSe29cfHnCAO3velae4WcsHfcAEcKLTRdPSGtvVJmwqUS8qwqVLZc4H4WhSybgrJ)WHLEiPpl9ucz9nCACAihXearSS2yHCoWHfwS(oXY1fbNNLgCybT4hTSmeWDDdbYcg2rS4Rh25pbYsy3lue2WPHExrSOeWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwIlWHfKcle08eilODwf1GdkYaaqllpKf0oRIAWbfzaagQCvnbIww6PeY6B40qVRiwusjGdlifwiO5jqw2UoKYcov9oYyb5ICz5HSGElNLoi4sVWSaJOXF4WspKBFw6PeY6B40qVRiwusjGdlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSOeGc4WcsHfcAEcKf0oRIAWbfzaaOLLhYcANvrn4GImaadvUQMarll9ucz9nCAO3velaujGdlifwiO5jqw2UoKYcov9oYyb5YYdzb9wolGhIdFWIfyen(dhw6HK(S0dGiRVHtd9UIybGkbCybPWcbnpbYcANvrn4GImaa0YYdzbTZQOgCqrgaGHkxvtGOLLEkHS(gon07kIfacqGdlifwiO5jqwq7SkQbhuKbaGwwEilODwf1GdkYaamu5QAceTS0tjK13WPHExrSaW4cCybPWcbnpbYY21HuwWPQ3rglixwEilO3Yzb8qC4dwSaJOXF4WspK0NLEXfz9nCAO3vela0AaoSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspaIS(gon07kIfacOaoSGuyHGMNazbTZQOgCqrgaaAz5HSG2zvudoOidaWqLRQjq0YspLqwFdNg6DfXcab0ahwqkSqqZtGSG2zvudoOidaaTS8qwq7SkQbhuKbayOYv1eiAzPNsiRVHtJtd5iMaiIL1glKZboSWI13jwUUi48S0GdlOvf6pAzziG76gcKfmSJyXxpSZFcKLWUxOiSHtd9UIyrjamWHfKcle08eilBxhszbNQEhzSGCz5HSGElNfWdXHpyXcmIg)Hdl9qsFw6fxK13WPHExrSOeGe4WcsHfcAEcKLTRdPSGtvVJmwqUS8qwqVLZc4H4WhSybgrJ)WHLEiPpl9ucz9nCACAwBxeCEcKfaflE4pyXI(Wp2WPzVHJOGDSukDaAVfnW2Pj7nKh5zj2U2RaXsCCwhiNgYJ8SK2QiwaiGeDSaW0bOsCACAipYZcs39cfHboCAipYZcGGLyccsGSSb1(WsSjVZWPH8iplacwq6UxOiqwEFqrF(ASeCmHz5HSesf0u(9bf9ydNgYJ8Saiybab1brqGSSQIceg7tkwq4Z5QAcZsVZqg0Xs0qiY43h8AqrSaiINLOHqyWVp41GI6B40qEKNfablXeb8azjAOGJ)RqXcYX4)olxJL7rlMLFNyXYaluSG(b9fHjdNgYJ8SaiybaPdeXcsHfciqel)oXYw0n3JzXzrF)Rjw6GdXstti7u1el9UglPGlw2DWcTpl73ZY9SGVUL(9IGlSoflwUFNLydGoMwNfaZcsjnH)Z1Set9HQ6O6rhl3JwqwWaDr9nCAipYZcGGfaKoqelDq8ZcABhQ9ppuNFfgTSGdu5ZbXS4rr6uS8qwuHymlTd1(Jzbw6ugononKh5zjMvbF)jqwITR9kqSetai6XsWlwujwAWvbYI)SS)Feg4GeKO6AVceGaFDbdQ73xQMdIKy7AVceGy76qks6an7FNg5STttkR6AVcK5r2ZPXP5H)Gf2enua2P6VYaDf4qGzC0n3J50qEwS(oXccFoxvtSCywW0ZYdzjDwSC)olfKf87plWILfMy5NRaIEm6yrjwSStfl)oXs7g8ZcSiwomlWILfMqhlaKLRXYVtSGPaSaz5WS4filXLLRXIk83zXhItZd)blSjAOaSt1FaRmsq4Z5QAcDL3rkdR8ct5FUci6rhcxViLtNtZd)blSjAOaSt1FaRmsq4Z5QAcDL3rkdR8ct5FUci6rhmszheeDiC9Iuwj0DnL)5kGO3OKzHDvnP4NRaIEJsMaeQbHwkd4A8)GfNMh(dwyt0qbyNQ)awzKGWNZv1e6kVJugw5fMY)Cfq0JoyKYoii6q46fPmar31u(NRaIEdanlSRQjf)Cfq0BaOjaHAqOLYaUg)pyXPH8Sy9DctS8ZvarpMfFiwk4ZIV(o)VGR1PybKEk8eiloMfyXYctSGF)z5NRaIESHLyQT4PWS4GGxHIfLyPJ8cZYVtPyXYP1S4AlEkmlQelrd1OziqwUcKIOcKQNfyJfSg(CAE4pyHnrdfGDQ(dyLrccFoxvtOR8oszyLxyk)Zvarp6Grk7GGOdHRxKYkHURPmbCxxuebAUchM17QAkdCxE9RUmiH4cuscbCxxuebAOUOud56mCalVcuscbCxxuebAWWLwt)FfQ8SutXP5H)Gf2enua2P6pGvgjDqyb0v5gC640qEwaGdfC8Zcazb5y8FNfVazXzz79bVguelWILnRZIL73zjwhQ9NL4GtS4filXggtRZcCyz79PDdXc83PXYHjonp8hSWMOHcWov)bSYiXY4)o60xr5aOYkLo6UMY9OG(IWKrVkFYfHSpjHc6lctMRYyO2NKekOVimzUkRc)9KekOVimz8kvUiK99508WFWcBIgka7u9hWkJelJ)7O7Ak3Jc6lctg9Q8jxeY(KekOVimzUkJHAFssOG(IWK5QSk83tsOG(IWKXRu5Iq23xr0qimkzSm(VRWQOHqyaOXY4)oNMh(dwyt0qbyNQ)awzKGFFA3qO7AkB1SkQbhuKr11EfOmSLDTo)7xHcNKyvaIGkVEtDO2)CZPKeRWrKwNFFqrp2GFFAUwRSsjjw9UMQ3u(VgcNvDTxbYqLRQjWKKEuqFryYGHAFYfHSpjHc6lctMRY6v5tscf0xeMmxLvH)Escf0xeMmELkxeY((CAE4pyHnrdfGDQ(dyLrc(9bVgue6UMYZQOgCqrgvx7vGYWw2168VFfkSIaebvE9M6qT)5MtkWrKwNFFqrp2GFFAUwRSsCACAipYZc6JmkSEcKfcbnPy5VoILFNyXdpCy5WS4i8t7QAYWP5H)Gfwzmu7twL8oonKNLn6XSeti6ZcSyjUaMfl3VdxplGZ1Ew8cKfl3VZY27JgoGS4filaeWSa)DASCyItZd)blmGvgji85CvnHUY7iLpC2He6q46fPmoI0687dk6Xg87tZ164vsrpRExt1BWVpA4aAOYv1eysY7AQEd(jT2Nm4CT3qLRQjW(jj4isRZVpOOhBWVpnxRJhGCAiplB0JzjOjhbXILDQyz79PDdXsWlw2VNfacywEFqrpMfl7xyNLdZYqAcHxpln4WYVtSG(b9fHjwEilQelrd1Oziqw8cKfl7xyNL2P10WYdzj44NtZd)blmGvgji85CvnHUY7iLpCoOjhbHoeUErkJJiTo)(GIESb)(0UHIxjonKNL4etSeBAW0a0vOyXY97SG0yIeRTcSahw82tdlifwiGarSCflinMiXARaNMh(dwyaRmsuPbtdqxHcDxt5EwfGiOYR3uhQ9p3CkjXQaeQbHwktawiGar5FNY4OBUhBwr9vOUAntWZxfmd15xHJxj0OqD1AMXrqfCHZTHQyKYmuNFfgywJcRcqeu51Bqq1VNAsscqeu51Bqq1VNAuOUAntWZxfmRifQRwZmocQGlCUnufJuMvKIEQRwZmocQGlCUnufJuMH68RWatjLaeOb4Nvrn4GIm4RAlDEpf(P58Ke1vRzcE(QGzOo)kmWusPKeLqU4isRZ7o(jGPKbnOPpNgYZcae(Sy5(DwCwqAmrI1wbw(D)z5WfAFwCwaGln2hwIgyGf4WILDQy53jwAhQ9NLdZIRcxplpKfQa508WFWcdyLrse8pyHURPS6Q1mbpFvWmuNFfoELqJIEwnRIAWbfzWx1w68Ek8tZ5jjQRwZmocQGlCUnufJuMH68RWatjaTc1vRzghbvWfo3gQIrkZkQFsIkeJv0ou7FEOo)kmWaiA40qEwqQRdlT)eMfl70Vtdll8vOybPWcbeiILcAHflNwZIR1qlSKcUy5HSG)tRzj44NLFNyb7DelEhCvplWglifwiGaragPXejwBfyj44hZP5H)GfgWkJee(CUQMqx5DKYbyHaceLbjCQkGoeUErkhOt3Rx7qT)5H68RWacLqdGiaHAqOLYe88vbZqD(v4(ixLaWP3x5aD6E9AhQ9ppuNFfgqOeAaekbW0bebiudcTuMaSqabIY)oLXr3Cp2muNFfUpYvjaC69vy14hyMqq1BCqqSHq2HFCssac1GqlLj45RcMH68RWXF1tteu7pbMBhQ9ppuNFfojjaHAqOLYeGfciqu(3Pmo6M7XMH68RWXF1tteu7pbMBhQ9ppuNFfgqOu6jjwfGiOYR3uhQ9p3CkjXd)bltawiGar5FNY4OBUhBapSRQjqonKNL4etGS8qwajTNILFNyzHDuelWglinMiXARalw2PILf(kuSacxQAIfyXYctS4filrdHGQNLf2rrSyzNkw8IfheKfcbvplhMfxfUEwEilGhXP5H)GfgWkJee(CUQMqx5DKYbWCawG3FWcDiC9IuU37dk6n)1r5hMbpkELqtsY4hyMqq1BCqqS5Q4rt69v0RxpRiG76IIiqd1fLAixNHdy5vGss61laHAqOLYqDrPgY1z4awEfiZqD(vyGPeGk9KKaebvE9geu97PgfbiudcTugQlk1qUodhWYRazgQZVcdmLauaAa3tjLa(zvudoOid(Q2sN3tHFAoVFFfwfGqni0szOUOud56mCalVcKzihmv)(k6zfbCxxuebAWWLwt)FfQ8SutLKyvaIGkVEtDO2)CZPKKaeQbHwkdgU0A6)RqLNLAQCCTg0aGtxjZqD(vyGPKswtFf9SIaURlkIanxHdZ6DvnLbUlV(vxgKqCbkjjaHAqOLYCfomR3v1ug4U86xDzqcXfiZqoyQ(k6fGqni0szuPbtdqxHYmKdMkjXQXdK5hOw3pjPxpe(CUQMmWkVWu(NRaIELvkjbHpNRQjdSYlmL)5kGOx542xrVFUci6nkzgYbtLdqOgeAPss(5kGO3OKjaHAqOLYmuNFfo(REAIGA)jWC7qT)5H68RWacLsVFsccFoxvtgyLxyk)ZvarVYaurVFUci6na0mKdMkhGqni0sLK8ZvarVbGMaeQbHwkZqD(v44V6PjcQ9NaZTd1(NhQZVcdiuk9(jji85CvnzGvEHP8pxbe9kNE)(jjbicQ86naLAoV6ZP5H)GfgWkJee(CUQMqx5DKY)(CADgteq0KT43JoeUErkBfgU0QxbA(9506mMiGOXqLRQjWKK2HA)Zd15xHJhGPNEsIkeJv0ou7FEOo)kmWaiAaCpRjDaH6Q1m)(CADgteq0yWVhac4by)Ke1vRz(9506mMiGOXGFpau8Xfadi6nRIAWbfzWx1w68Ek8tZ5apA6ZPH8SeNyIf0Vlk1qUMfa0dy5vGybGPJPaMfvQbhIfNfKgtKyTvGLfMmCAE4pyHbSYizHP89uh6kVJuM6IsnKRZWbS8kqO7AkhGqni0szcE(QGzOo)kmWay6kcqOgeAPmbyHaceL)DkJJU5ESzOo)kmWay6k6HWNZv1K53NtRZyIaIMSf)(Ke1vRz(9506mMiGOXGFpau8XnDa3Bwf1GdkYGVQT059u4NMZbEav)(jjQqmwr7qT)5H68RWalUaAonKNL4etSSbxAn9xHIfael1uSaOWuaZIk1GdXIZcsJjsS2kWYctgonp8hSWawzKSWu(EQdDL3rkJHlTM()ku5zPMcDxt5aeQbHwktWZxfmd15xHbgGsHvbicQ86niO63tnkSkarqLxVPou7FU5ussaIGkVEtDO2)CZjfbiudcTuMaSqabIY)oLXr3Cp2muNFfgyakf9q4Z5QAYeGfciqugKWPQqssac1GqlLj45RcMH68RWadq1pjjarqLxVbbv)EQrrpRMvrn4GIm4RAlDEpf(P5CfbiudcTuMGNVkygQZVcdmavsI6Q1mJJGk4cNBdvXiLzOo)kmWuYAaCp0a8eWDDrreO5k8pRWdhCg8qCfLvjTUVc1vRzghbvWfo3gQIrkZkQFsIkeJv0ou7FEOo)kmWaiA408WFWcdyLrYct57Po0vEhP8v4WSExvtzG7YRF1LbjexGq31uwD1AMGNVkygQZVchVsOrrpRMvrn4GIm4RAlDEpf(P58Ke1vRzghbvWfo3gQIrkZqD(vyGPeabCV4c8QRwZOQHqq9c)MvuFa3RhGgqGgGxD1AgvnecQx43SI6d8eWDDrreO5k8pRWdhCg8qCfLvjTUVc1vRzghbvWfo3gQIrkZkQFsIkeJv0ou7FEOo)kmWaiA40qEwS((Hz5WS4Sm(VtdlK2vHJ)elw8uS8qw6CGiwCTMfyXYctSGF)z5NRaIEmlpKfvIf9veilRiwSC)olinMiXARalEbYcsHfciqelEbYYctS87elaSazbRHplWILailxJfv4VZYpxbe9yw8HybwSSWel43Fw(5kGOhZP5H)GfgWkJKfMY3tDy0H1WhR8pxbe9kHURPmcFoxvtgyLxyk)ZvarVYauHv)Cfq0BaOzihmvoaHAqOLkjPhcFoxvtgyLxyk)ZvarVYkLKGWNZv1Kbw5fMY)Cfq0RCC7RON6Q1mbpFvWSIu0ZQaebvE9geu97PMKe1vRzghbvWfo3gQIrkZqD(vya3dna)SkQbhuKbFvBPZ7PWpnN3hyk)ZvarVrjJ6Q1YGRX)dwkuxTMzCeubx4CBOkgPmROKe1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SI6NKeGqni0szcE(QGzOo)kmGby8)Cfq0BuYeGqni0szaxJ)hSu0ZQaebvE9M6qT)5MtjjwHWNZv1KjaleqGOmiHtvH(kSkarqLxVbOuZ5vssaIGkVEtDO2)CZjfi85CvnzcWcbeikds4uvqrac1GqlLjaleqGO8VtzC0n3JnRifwfGqni0szcE(QGzfPOxp1vRzOG(IWuwVkFmd15xHJxP0tsuxTMHc6lctzmu7JzOo)kC8kLEFfwnRIAWbfzuDTxbkdBzxRZ)(vOWjj9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhasz0KKOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpaKYa4(9tsuxTMbORahcmtDrql00r1NPIguxmiZkQFsIkeJv0ou7FEOo)kmWay6jji85CvnzGvEHP8pxbe9kNoNMh(dwyaRmswykFp1HrhwdFSY)Cfq0dq0DnLr4Z5QAYaR8ct5FUci6TszaQWQFUci6nkzgYbtLdqOgeAPssq4Z5QAYaR8ct5FUci6vgGk6PUAntWZxfmRif9SkarqLxVbbv)EQjjrD1AMXrqfCHZTHQyKYmuNFfgW9qdWpRIAWbfzWx1w68Ek8tZ59bMY)Cfq0BaOrD1AzW14)blfQRwZmocQGlCUnufJuMvusI6Q1mJJGk4cNBdvXivgFvBPZ7PWpnNBwr9tscqOgeAPmbpFvWmuNFfgWam(FUci6na0eGqni0szaxJ)hSu0ZQaebvE9M6qT)5MtjjwHWNZv1KjaleqGOmiHtvH(kSkarqLxVbOuZ5LIEwPUAntWZxfmROKeRcqeu51Bqq1VNA6NKeGiOYR3uhQ9p3CsbcFoxvtMaSqabIYGeovfueGqni0szcWcbeik)7ughDZ9yZksHvbiudcTuMGNVkywrk61tD1AgkOVimL1RYhZqD(v44vk9Ke1vRzOG(IWugd1(ygQZVchVsP3xHvZQOgCqrgvx7vGYWw2168VFfkCssp1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87bGugnjjQRwZO6AVcug2YUwN)9RqHZ(e8Im43daPmaUF)(jjQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfLKOcXyfTd1(NhQZVcdmaMEsccFoxvtgyLxyk)ZvarVYPZPH8SeNycZIR1Sa)DAybwSSWel3tDywGflbqonp8hSWawzKSWu(EQdJURPS6Q1mbpFvWSIsscqeu51BQd1(NBoPaHpNRQjtawiGarzqcNQckcqOgeAPmbyHaceL)DkJJU5ESzfPWQaeQbHwktWZxfmRif96PUAndf0xeMY6v5JzOo)kC8kLEsI6Q1muqFrykJHAFmd15xHJxP07RWQzvudoOiJQR9kqzyl7AD(3Vcfojzwf1GdkYO6AVcug2YUwN)9RqHv0tD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4JBsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXh3(9tsuxTMbORahcmtDrql00r1NPIguxmiZkkjrfIXkAhQ9ppuNFfgyamDonKNL4ifoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdZP5H)GfgWkJKzvzp8hSY6d)OR8oszhsOd)ZfELvcDxtze(CUQMmho7qItZd)blmGvgjZQYE4pyL1h(rx5DKYQq)rh(Nl8kRe6UMYZQOgCqrgvx7vGYWw2168VFfkSHaURlkIa508WFWcdyLrYSQSh(dwz9HF0vEhPm(5040qEwqQRdlT)eMfl70Vtdl)oXsCCiVl4FyNgwuxTglwoTMLMR1SaBnwSC)(vS87elfHSNLGJFonp8hSWghskJWNZv1e6kVJugCiVlB506CZ16mS1qhcxViL7PUAnZFDKf4uzWH8o1RaPXmuNFfgyOcGMohzaoDJsjjQRwZ8xhzbovgCiVt9kqAmd15xHbMh(dwg87t7gYqiJcRNY)1raoDJsk6rb9fHjZvz9Q8jjHc6lctgmu7tUiK9jjuqFryY4vQCri773xH6Q1m)1rwGtLbhY7uVcKgZksXSkQbhuK5VoYcCQm4qEN6vG0WPH8SGuxhwA)jmlw2PFNgw2EFWRbfXYHzXcC(Dwco(Vcflqe0WY27t7gILRyb9wLpSG(b9fHjonp8hSWghsawzKGWNZv1e6kVJu(qvWHY43h8AqrOdHRxKYwrb9fHjZvzmu7JIE4isRZVpOOhBWVpTBO4rJI31u9gmCPZWw(3PCdoe(nu5QAcmjbhrAD(9bf9yd(9PDdfpGUpNgYZsCIjwqkSqabIyXYovS4plAcJz539If0KolXedazXlqw0xrSSIyXY97SG0yIeRTcCAE4pyHnoKaSYijaleqGO8VtzC0n3Jr31u2kWzDGMcMdGyf96HWNZv1KjaleqGOmiHtvbfwfGqni0szcE(QGzihmvsI6Q1mbpFvWSI6RON6Q1muqFrykRxLpMH68RWXdOssuxTMHc6lctzmu7JzOo)kC8aQ(k6z1SkQbhuKr11EfOmSLDTo)7xHcNKOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpau8XnjrD1Agvx7vGYWw2168VFfkC2NGxKb)EaO4JB)KevigRODO2)8qD(vyGPu6kSkaHAqOLYe88vbZqoyQ(CAiplXjMyjomufJuSy5(DwqAmrI1wbonp8hSWghsawzKmocQGlCUnufJuO7AkRUAntWZxfmd15xHJxj0WPH8SeNyILTv1UHy5kwI8cK6UalWIfVs97xHILF3Fw0hccZIswdMcyw8cKfnHXSy5(Dw6GdXY7dk6XS4fil(ZYVtSqfilWglolBqTpSG(b9fHjw8NfLSgwWuaZcCyrtymld15xDfkwCmlpKLc(SS7iUcflpKLHAdH3zbCnxHIf0Bv(Wc6h0xeM408WFWcBCibyLrcEvTBi0fsf0u(9bf9yLvcDxt5Ed1gcV7QAkjrD1AgkOVimLXqTpMH68RWalUkOG(IWK5QmgQ9rXqD(vyGPK1O4DnvVbdx6mSL)Dk3GdHFdvUQMa7R49bf9M)6O8dZGhfVswdGahrAD(9bf9yapuNFfwrpkOVimzUk7vQKKH68RWadva005iRpNgYZcYjIIyzfXY27tZ1Aw8NfxRz5VocZYQ0egZYcFfkwqVubFCmlEbYY9SCywCv46z5HSenWalWHfn9S87el4ikCUMfp8hSyrFfXIkPHwyz3lqnXsCCiVt9kqAybwSaqwEFqrpMtZd)blSXHeGvgj43NMR1O7AkB17AQEd(jT2Nm4CT3qLRQjqf9uxTMb)(0CT2muBi8URQjf9WrKwNFFqrp2GFFAUwdS4MKy1SkQbhuK5VoYcCQm4qEN6vG00pj5DnvVbdx6mSL)Dk3GdHFdvUQMavOUAndf0xeMYyO2hZqD(vyGfxfuqFryYCvgd1(OqD1Ag87tZ1AZqD(vyGbOvGJiTo)(GIESb)(0CToELTM(k6z1SkQbhuKrNk4JJZnnr)vOYO0xxeMss(RJqUixRbnXRUAnd(9P5ATzOo)kmGbyFfVpOO38xhLFyg8O4rdNgYZcYX97SS9Kw7dlXX5ApllmXcSyjaYILDQyzO2q4DxvtSOUEwW)P1SyXVNLgCyb9sf8XXSenWalEbYciSq7ZYctSOsn4qSG04i2WY2FAnllmXIk1GdXcsHfciqel4Rcel)U)Sy50AwIgyGfVG)onSS9(0CTMtZd)blSXHeGvgj43NMR1O7Ak)UMQ3GFsR9jdox7nu5QAcuH6Q1m43NMR1MHAdH3DvnPONvZQOgCqrgDQGpoo30e9xHkJsFDrykj5Voc5ICTg0eV10xX7dk6n)1r5hMbpk(4YPH8SGCC)olXXH8o1RaPHLfMyz79P5AnlpKfGikILvel)oXI6Q1yrnflUgdzzHVcflBVpnxRzbwSGgwWuawGywGdlAcJzzOo)QRqXP5H)Gf24qcWkJe87tZ1A0DnLNvrn4GIm)1rwGtLbhY7uVcKgf4isRZVpOOhBWVpnxRJx54QONvQRwZ8xhzbovgCiVt9kqAmRifQRwZGFFAUwBgQneE3v1usspe(CUQMmGd5DzlNwNBUwNHTMIEQRwZGFFAUwBgQZVcdS4MKGJiTo)(GIESb)(0CToEaQ4DnvVb)Kw7tgCU2BOYv1eOc1vRzWVpnxRnd15xHbgA63VpNgYZcsDDyP9NWSyzN(DAyXzz79bVguellmXILtRzj4lmXY27tZ1AwEilnxRzb2AOJfVazzHjw2EFWRbfXYdzbiIIyjooK3PEfinSGFpaelRionp8hSWghsawzKGWNZv1e6kVJug)(0CToBbwFU5ADg2AOdHRxKYo(hxNJGwOjEaC6aIEkLoWRUAnZFDKf4uzWH8o1RaPXGFpauFarp1vRzWVpnxRnd15xHb(4ICXrKwN3D8taVvVRP6n4N0AFYGZ1EdvUQMa7di6fGqni0szWVpnxRnd15xHb(4ICXrKwN3D8ta)7AQEd(jT2Nm4CT3qLRQjW(aIEGW30wtQmSLj9QiZqD(vyGhn9v0tD1Ag87tZ1AZkkjjaHAqOLYGFFAUwBgQZVc3Ntd5zjoXelBVp41GIyXY97SehhY7uVcKgwEilaruelRiw(DIf1vRXIL73HRNfneFfkw2EFAUwZYk6VoIfVazzHjw2EFWRbfXcSyXAamlXggtRZc(9aqyww1FAwSgwEFqrpMtZd)blSXHeGvgj43h8AqrO7AkJWNZv1KbCiVlB506CZ16mS1uGWNZv1Kb)(0CToBbwFU5ADg2AkScHpNRQjZHQGdLXVp41GIss6PUAnJQR9kqzyl7AD(3Vcfox(VgYGFpau8XnjrD1Agvx7vGYWw2168VFfkC2NGxKb)EaO4JBFf4isRZVpOOhBWVpnxRbM1OaHpNRQjd(9P5AD2cS(CZ16mS140qEwItmXc2IpDSGHS87(Zsk4Ifu0ZsNJmwwr)1rSOMILf(kuSCploMfT)eloMLiigFQAIfyXIMWyw(DVyjUSGFpaeMf4Wcakl8ZILDQyjUaMf87bGWSqil6gItZd)blSXHeGvgjoOh9hckJT4th6cPcAk)(GIESYkHURPSv)fa6kukSYd)blJd6r)HGYyl(0Lb9ohfzUk30hQ9pjbe(gh0J(dbLXw8Pld6DokYGFpaeWIRcq4BCqp6peugBXNUmO35OiZqD(vyGfxonKNfaeuBi8olaiHWQDdXY1ybPXejwBfy5WSmKdMcDS870qS4dXIMWyw(DVybnS8(GIEmlxXc6TkFyb9d6lctSy5(Dw2GFCaDSOjmMLF3lwukDwG)onwomXYvS4vkwq)G(IWelWHLvelpKf0WY7dk6XSOsn4qS4SGERYhwq)G(IWKHL4iSq7ZYqTHW7SaUMRqXcYPRahcKf0VlcAHMoQEwwLMWywUILnO2hwq)G(IWeNMh(dwyJdjaRms6GWQDdHUqQGMYVpOOhRSsO7AkpuBi8URQjfVpOO38xhLFyg8O471tjRbW9WrKwNFFqrp2GFFA3qapabE1vRzOG(IWuwVkFmRO(9b8qD(v4(i3Ekb431u9M3Yv5oiSWgQCvnb2xrVaeQbHwktWZxfmd5GPuyf4SoqtbZbqSIEi85CvnzcWcbeikds4uvijjaHAqOLYeGfciqu(3Pmo6M7XMHCWujjwfGiOYR3uhQ9p3CQFscoI0687dk6Xg87t7gcy96bOae9uxTMHc6lctz9Q8XSIaEa2VpW3tja)UMQ38wUk3bHf2qLRQjW(9vyff0xeMmyO2NCri7ts6rb9fHjZvzmu7tsspkOVimzUkRc)9KekOVimzUkRxLp9vy17AQEdgU0zyl)7uUbhc)gQCvnbMKOUAnt0CDWb8CD2NGxxihT0yFmiC9IIxzaIM07ROhoI0687dk6Xg87t7gcykLoW3tja)UMQ38wUk3bHf2qLRQjW(9v44FCDocAHM4rt6ac1vRzWVpnxRnd15xHbEavFf9SsD1AgGUcCiWm1fbTqthvFMkAqDXGmROKekOVimzUkJHAFssSkarqLxVbOuZ5vFfwPUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5MveNgYZsCIjwIdWyXcSyjaYIL73HRNLGhfDfkonp8hSWghsawzK0GtGYWwU8Fne6UMYEuoStbG408WFWcBCibyLrccFoxvtOR8os5ayoalW7pyLDiHoeUErkBf4SoqtbZbqSce(CUQMmbWCawG3FWsrVEQRwZGFFAUwBwrjj9Ext1BWpP1(KbNR9gQCvnbMKeGiOYR3uhQ9p3CQFFf9SsD1AgmuJ)lqMvKcRuxTMj45RcMvKIEw9UMQ30wtQmSLj9QidvUQMatsuxTMj45RcgW14)bR4dqOgeAPmT1KkdBzsVkYmuNFfgWa4(kq4Z5QAY87ZP1zmrart2IFVIEwfGiOYR3uhQ9p3CkjjaHAqOLYeGfciqu(3Pmo6M7XMvKIEQRwZGFFAUwBgQZVcdmaMKy17AQEd(jT2Nm4CT3qLRQjW(9v8(GIEZFDu(HzWJIxD1AMGNVkyaxJ)hSa(0na6(jjQqmwr7qT)5H68RWatD1AMGNVkyaxJ)hS6ZPH8SeNyIfKgtKyTvGfyXsaKLvPjmMfVazrFfXY9SSIyXY97SGuyHaceXP5H)Gf24qcWkJKaPj8FUo76dv1r1JURPmcFoxvtMayoalW7pyLDiXP5H)Gf24qcWkJKRc(u(FWcDxtze(CUQMmbWCawG3FWk7qItd5zjoXelOFxe0cnSeBybYcSyjaYIL73zz79P5AnlRiw8cKfSJGyPbhwaGln2hw8cKfKgtKyTvGtZd)blSXHeGvgjuxe0cnzvybIURPSkeJvC1tteu7pbMBhQ9ppuNFfgykHMKKEQRwZenxhCapxN9j41fYrln2hdcxViGbq0KEsI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lkELbiAsVVc1vRzWVpnxRnRif9cqOgeAPmbpFvWmuNFfoE0KEsc4SoqtbZbqCFonKNfaeuBi8olnTpelWILvelpKL4YY7dk6XSy5(D46zbPXejwBfyrLUcflUkC9S8qwiKfDdXIxGSuWNficAcEu0vO408WFWcBCibyLrc(jT2NCt7dHUqQGMYVpOOhRSsO7AkpuBi8URQjf)1r5hMbpkELqJcCeP153hu0Jn43N2neWSgfEuoStbGu0tD1AMGNVkygQZVchVsPNKyL6Q1mbpFvWSI6ZPH8SeNyIL4ae9z5ASCf(ajw8If0pOVimXIxGSOVIy5EwwrSy5(DwCwaGln2hwIgyGfVazjMGE0Fiiw2S4thNMh(dwyJdjaRmsARjvg2YKEve6UMYuqFryYCv2Ruk8OCyNcaPqD1AMO56Gd456SpbVUqoAPX(yq46fbmaIM0v0de(gh0J(dbLXw8Pld6DokY8xaORqLKyvaIGkVEtrHbQHdyscoI0687dk6XXdW(k6PUAnZ4iOcUW52qvmszgQZVcdmajGOhAa(zvudoOid(Q2sN3tHFAoVVc1vRzghbvWfo3gQIrkZkkjXk1vRzghbvWfo3gQIrkZkQVIEwfGqni0szcE(QGzfLKOUAnZVpNwNXebeng87bGaMsOrr7qT)5H68RWadGPNUI2HA)Zd15xHJxP0tpjXkmCPvVc008315M2TyOYv1eyFonKNL4etS4SS9(0CTMfa0f97SenWalRstymlBVpnxRz5WS46HCWuSSIyboSKcUyXhIfxfUEwEilqe0e8iwIjgaYP5H)Gf24qcWkJe87tZ1A0DnLvxTMbw0VJZr0eOO)GLzfPON6Q1m43NMR1MHAdH3DvnLK44FCDocAHM4bKP3Ntd5zjoU6IyjMyailQudoelifwiGarSy5(Dw2EFAUwZIxGS87uXY27dEnOionp8hSWghsawzKGFFAUwJURPCaIGkVEtDO2)CZjfw9UMQ3GFsR9jdox7nu5QAcurpe(CUQMmbyHaceLbjCQkKKeGqni0szcE(QGzfLKOUAntWZxfmRO(kcqOgeAPmbyHaceL)DkJJU5ESzOo)kmWqfanDoYa(aD6Eo(hxNJGwOb5IM07RqD1Ag87tZ1AZqD(vyGznkScCwhOPG5aiMtZd)blSXHeGvgj43h8AqrO7AkhGiOYR3uhQ9p3Csrpe(CUQMmbyHaceLbjCQkKKeGqni0szcE(QGzfLKOUAntWZxfmRO(kcqOgeAPmbyHaceL)DkJJU5ESzOo)kmWaukuxTMb)(0CT2SIuqb9fHjZvzVsPWke(CUQMmhQcoug)(GxdksHvGZ6anfmhaXCAiplXjMyz79bVguelwUFNfVybaDr)olrdmWcCy5ASKcUqlilqe0e8iwIjgaYIL73zjfCnSueYEwco(nSetngYc4QlILyIbGS4pl)oXcvGSaBS87elaOs1VNAyrD1ASCnw2EFAUwZIf4sdwO9zP5AnlWwJf4Wsk4IfFiwGflaKL3hu0J508WFWcBCibyLrc(9bVgue6UMYQRwZal63X5GM8jJ4WhSmROKKEwHFFA3qgpkh2PaqkScHpNRQjZHQGdLXVp41GIss6PUAntWZxfmd15xHbgAuOUAntWZxfmROKKE9uxTMj45RcMH68RWadva005id4d0P754FCDocAHgKBCtVVc1vRzcE(QGzfLKOUAnZ4iOcUW52qvmsLXx1w68Ek8tZ5MH68RWadva005id4d0P754FCDocAHgKBCtVVc1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SI6RiarqLxVbbv)EQPFFf9WrKwNFFqrp2GFFAUwdS4MKGWNZv1Kb)(0CToBbwFU5ADg2A97RWke(CUQMmhQcoug)(GxdksrpRMvrn4GIm)1rwGtLbhY7uVcKMKeCeP153hu0Jn43NMR1alU950qEwItmXcasiSWSCflBqTpSG(b9fHjw8cKfSJGyjoS0AwaqcHfln4WcsJjsS2kWP5H)Gf24qcWkJKISK7GWcDxt5EQRwZqb9fHPmgQ9XmuNFfoEczuy9u(VokjPxy3huewzaQyOWUpOO8FDeWqt)KKWUpOiSYXTVcpkh2PaqCAE4pyHnoKaSYiz31TChewO7Ak3tD1AgkOVimLXqTpMH68RWXtiJcRNY)1rjj9c7(GIWkdqfdf29bfL)RJagA6NKe29bfHvoU9v4r5Wofasrp1vRzghbvWfo3gQIrkZqD(vyGHgfQRwZmocQGlCUnufJuMvKcRMvrn4GIm4RAlDEpf(P58KeRuxTMzCeubx4CBOkgPmRO(CAE4pyHnoKaSYiPT06ChewO7Ak3tD1AgkOVimLXqTpMH68RWXtiJcRNY)1rk6fGqni0szcE(QGzOo)kC8Oj9KKaeQbHwktawiGar5FNY4OBUhBgQZVchpAsVFssVWUpOiSYauXqHDFqr5)6iGHM(jjHDFqryLJBFfEuoStbGu0tD1AMXrqfCHZTHQyKYmuNFfgyOrH6Q1mJJGk4cNBdvXiLzfPWQzvudoOid(Q2sN3tHFAopjXk1vRzghbvWfo3gQIrkZkQpNgYZsCIjwqoGOplWIfKgh508WFWcBCibyLrIfFMdozylt6vrCAipli11HL2FcZILD63PHLhYYctSS9(0UHy5kw2GAFyXY(f2z5WS4plOHL3hu0JbSsS0GdlecAsXcath5YsNJFAsXcCyXAyz79bVguelOFxe0cnDu9SGFpaeMtZd)blSXHeGvgji85CvnHUY7iLXVpTBO8vzmu7d6q46fPmoI0687dk6Xg87t7gkERbWnneo96C8ttQmcxViGxP0th5cW07d4MgcNEQRwZGFFWRbfLPUiOfA6O6ZyO2hd(9aqixRPpNgYZcsDDyP9NWSyzN(DAy5HSGCm(VZc4AUcflXHHQyKItZd)blSXHeGvgji85CvnHUY7iLTm(VNVk3gQIrk0HW1lszLqU4isRZ7o(jGbqdAae9s3aqGhhrAD(9bf9yd(9PDdb89ucWVRP6ny4sNHT8Vt5gCi8BOYv1eiWRKbn97d40nkHgGxD1AMXrqfCHZTHQyKYmuNFfMtd5zjoXelihJ)7SCflBqTpSG(b9fHjwGdlxJLcYY27t7gIflNwZs7EwU6HSG0yIeRTcS4vQo4qCAE4pyHnoKaSYiXY4)o6UMY9OG(IWKrVkFYfHSpjHc6lctgVsLlczVce(CUQMmhoh0KJG6RO37dk6n)1r5hMbpkERjjHc6lctg9Q8jFvgGjjTd1(NhQZVcdmLsVFsI6Q1muqFrykJHAFmd15xHbMh(dwg87t7gYqiJcRNY)1rkuxTMHc6lctzmu7JzfLKqb9fHjZvzmu7JcRq4Z5QAYGFFA3q5RYyO2NKe1vRzcE(QGzOo)kmW8WFWYGFFA3qgczuy9u(VosHvi85CvnzoCoOjhbPqD1AMGNVkygQZVcdmczuy9u(VosH6Q1mbpFvWSIssuxTMzCeubx4CBOkgPmRifi85CvnzSm(VNVk3gQIrQKeRq4Z5QAYC4CqtocsH6Q1mbpFvWmuNFfoEczuy9u(VoItd5zjoXelBVpTBiwUglxXc6TkFyb9d6lctOJLRyzdQ9Hf0pOVimXcSyXAamlVpOOhZcCy5HSenWalBqTpSG(b9fHjonp8hSWghsawzKGFFA3qCAiplXbxR)9zXP5H)Gf24qcWkJKzvzp8hSY6d)OR8os5MR1)(S4040qEwIddvXiflwUFNfKgtKyTvGtZd)blSrf6VYJJGk4cNBdvXif6UMYQRwZe88vbZqD(v44vcnCAiplXjMyjMGE0Fiiw2S4thlw2PIf)zrtyml)UxSynSeBymTol43daHzXlqwEild1gcVZIZcWugGSGFpaeloMfT)eloMLiigFQAIf4WYFDel3ZcgYY9S4ZCiimlaOSWplE7PHfNL4cywWVhaIfczr3qyonp8hSWgvO)awzK4GE0FiOm2IpDOlKkOP87dk6XkRe6UMYQRwZO6AVcug2YUwN)9RqHZL)RHm43dabmaSc1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGagawrpRaHVXb9O)qqzSfF6YGENJIm)fa6kukSYd)blJd6r)HGYyl(0Lb9ohfzUk30hQ9xrpRaHVXb9O)qqzSfF6Y7KRn)fa6kujjGW34GE0FiOm2IpD5DY1MH68RWXh3(jjGW34GE0FiOm2IpDzqVZrrg87bGawCvacFJd6r)HGYyl(0Lb9ohfzgQZVcdm0Oae(gh0J(dbLXw8Pld6DokY8xaORq1Ntd5zjoXelifwiGarSy5(DwqAmrI1wbwSStflrqm(u1elEbYc83PXYHjwSC)ololXggtRZI6Q1yXYovSas4uv4kuCAE4pyHnQq)bSYijaleqGO8VtzC0n3Jr31u2kWzDGMcMdGyf96HWNZv1KjaleqGOmiHtvbfwfGqni0szcE(QGzihmvsI6Q1mbpFvWSI6RON6Q1mQU2RaLHTSR15F)ku4C5)Aid(9aqkdGtsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhaszaC)KevigRODO2)8qD(vyGPu6950qEwIdq0NfhZYVtS0Ub)SGkaYYvS87elolXggtRZILRaHwyboSy5(Dw(DIfKtPMZlwuxTglWHfl3VZIZcagWykWsmb9O)qqSSzXNow8cKfl(9S0GdlinMiXARalxJL7zXcSEwujwwrS4O8RyrLAWHy53jwcGSCywAxD4DcKtZd)blSrf6pGvgjT1KkdBzsVkcDxt5E96PUAnJQR9kqzyl7AD(3Vcfox(VgYGFpau8aQKe1vRzuDTxbkdBzxRZ)(vOWzFcErg87bGIhq1xrpRcqeu51Bqq1VNAssSsD1AMXrqfCHZTHQyKYSI63xrpWzDGMcMdG4KKaeQbHwktWZxfmd15xHJhnPNK0larqLxVPou7FU5KIaeQbHwktawiGar5FNY4OBUhBgQZVchpAsVF)(jj9aHVXb9O)qqzSfF6YGENJImd15xHJhaRiaHAqOLYe88vbZqD(v44vkDfbicQ86nffgOgoG9tsuHySIREAIGA)jWC7qT)5H68RWadaRWQaeQbHwktWZxfmd5GPsscqeu51Bak1CEPqD1AgGUcCiWm1fbTqthvVzfLKeGiOYR3GGQFp1OqD1AMXrqfCHZTHQyKYmuNFfgyasfQRwZmocQGlCUnufJuMveNgYZcs9kqAw2EF0WbKfl3VZIZsrwyj2WyADwuxTglEbYcsJjsS2kWYHl0(S4QW1ZYdzrLyzHjqonp8hSWgvO)awzKe8kq6S6Q1qx5DKY43hnCar31uUN6Q1mQU2RaLHTSR15F)ku4C5)AiZqD(v44b0g0KKOUAnJQR9kqzyl7AD(3Vcfo7tWlYmuNFfoEaTbn9v0laHAqOLYe88vbZqD(v44b0jj9cqOgeAPmuxe0cnzvybAgQZVchpGwHvQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfPiarqLxVbOuZ5v)(kC8pUohbTqt8kh3050qEwIJRUiw2EFWRbfHzXY97S4SeBymTolQRwJf11ZsbFwSStflrqO(kuS0GdlinMiXARalWHfKtxboeilBr3CpMtZd)blSrf6pGvgj43h8AqrO7Ak3tD1Agvx7vGYWw2168VFfkCU8FnKb)EaO4bysI6Q1mQU2RaLHTSR15F)ku4SpbVid(9aqXdW(k6fGiOYR3uhQ9p3CkjjaHAqOLYe88vbZqD(v44b0jjwHWNZv1KjaMdWc8(dwkSkarqLxVbOuZ5vssVaeQbHwkd1fbTqtwfwGMH68RWXdOvyL6Q1maDf4qGzQlcAHMoQ(mv0G6Ibzwrkcqeu51Bak1CE1VVIEwbcFtBnPYWwM0RIm)fa6kujjwfGqni0szcE(QGzihmvsIvbiudcTuMaSqabIY)oLXr3Cp2mKdMQpNgYZsCC1fXY27dEnOimlQudoelifwiGarCAE4pyHnQq)bSYib)(GxdkcDxt5EbiudcTuMaSqabIY)oLXr3Cp2muNFfgyOrHvGZ6anfmhaXk6HWNZv1KjaleqGOmiHtvHKKaeQbHwktWZxfmd15xHbgA6RaHpNRQjtamhGf49hS6RWkq4BARjvg2YKEvK5VaqxHsraIGkVEtDO2)CZjfwboRd0uWCaeRGc6lctMRYELsHJ)X15iOfAI3AsNtd5zjocl0(SacFwaxZvOy53jwOcKfyJfaeocQGlmlXHHQyKcDSaUMRqXcqxboeiluxe0cnDu9SahwUILFNyr74NfubqwGnw8If0pOVimXP5H)Gf2Oc9hWkJee(CUQMqx5DKYGWppeWDDd1r1JrhcxViL7PUAnZ4iOcUW52qvmszgQZVchpAssSsD1AMXrqfCHZTHQyKYSI6RON6Q1maDf4qGzQlcAHMoQ(mv0G6IbzgQZVcdmubqtNJS(k6PUAndf0xeMYyO2hZqD(v44rfanDoYssuxTMHc6lctz9Q8XmuNFfoEubqtNJS(CAE4pyHnQq)bSYibVQ2ne6cPcAk)(GIESYkHURP8qTHW7UQMu8(GIEZFDu(HzWJIxjaLcpkh2Paqkq4Z5QAYac)8qa31nuhvpMtZd)blSrf6pGvgjDqy1UHqxivqt53hu0Jvwj0DnLhQneE3v1KI3hu0B(RJYpmdEu8kfxdAu4r5WofasbcFoxvtgq4Nhc4UUH6O6XCAE4pyHnQq)bSYib)Kw7tUP9Hqxivqt53hu0Jvwj0DnLhQneE3v1KI3hu0B(RJYpmdEu8kbOa8qD(vyfEuoStbGuGWNZv1Kbe(5HaURBOoQEmNgYZsCaglwGflbqwSC)oC9Se8OORqXP5H)Gf2Oc9hWkJKgCcug2YL)RHq31u2JYHDkaeNgYZc63fbTqdlXgwGSyzNkwCv46z5HSq1tdlolfzHLydJP1zXYvGqlS4filyhbXsdoSG0yIeRTcCAE4pyHnQq)bSYiH6IGwOjRclq0DnL7rb9fHjJEv(KlczFscf0xeMmyO2NCri7tsOG(IWKXRu5Iq2NKOUAnJQR9kqzyl7AD(3Vcfox(VgYmuNFfoEaTbnjjQRwZO6AVcug2YUwN)9RqHZ(e8Imd15xHJhqBqtsIJ)X15iOfAIhqMUIaeQbHwktWZxfmd5GPuyf4SoqtbZbqCFf9cqOgeAPmbpFvWmuNFfo(4MEssac1GqlLj45RcMHCWu9tsuHySIREAIGA)jWC7qT)5H68RWatP050qEwIdq0NL5qT)SOsn4qSSWxHIfKgtonp8hSWgvO)awzK0wtQmSLj9Qi0DnLdqOgeAPmbpFvWmKdMsbcFoxvtMayoalW7pyPONJ)X15iOfAIhqMUcRcqeu51BQd1(NBoLKeGiOYR3uhQ9p3CsHJ)X15iOfAaM1KEFfwfGiOYR3GGQFp1OONvbicQ86n1HA)ZnNsscqOgeAPmbyHaceL)DkJJU5ESzihmvFfwboRd0uWCaeZPH8SG0yIeRTcSyzNkw8Nfaz6aMLyIbGS0doAOfAy539IfRjDwIjgaYIL73zbPWcbeiQplwUFhUEw0q8vOy5VoILRyj2AieuVWplEbYI(kILvelwUFNfKcleqGiwUgl3ZIfhZciHtvbcKtZd)blSrf6pGvgji85CvnHUY7iLdG5aSaV)Gvwf6p6q46fPSvGZ6anfmhaXkq4Z5QAYeaZbybE)blf9654FCDocAHM4bKPRON6Q1maDf4qGzQlcAHMoQ(mv0G6IbzwrjjwfGiOYR3auQ58QFsI6Q1mQAieuVWVzfPqD1AgvnecQx43muNFfgyQRwZe88vbd4A8)Gv)KKREAIGA)jWC7qT)5H68RWatD1AMGNVkyaxJ)hSsscqeu51BQd1(NBo1xrpRcqeu51BQd1(NBoLK0ZX)46Ce0cnaZAspjbe(M2AsLHTmPxfz(la0vO6ROhcFoxvtMaSqabIYGeovfsscqOgeAPmbyHaceL)DkJJU5ESzihmv)(CAE4pyHnQq)bSYijqAc)NRZU(qvDu9O7AkJWNZv1KjaMdWc8(dwzvO)CAE4pyHnQq)bSYi5QGpL)hSq31ugHpNRQjtamhGf49hSYQq)50qEwqF8FD(tyw2HwyPBf2zjMyail(qSGYVIazjIgwWuawGCAE4pyHnQq)bSYibHpNRQj0vEhPSJJaG0Srb0HW1lszkOVimzUkRxLpapag56H)GLb)(0UHmeYOW6P8FDeGTIc6lctMRY6v5dW3dqb431u9gmCPZWw(3PCdoe(nu5QAce4JBFKRh(dwglJ)7gczuy9u(VocWPBaiYfhrADE3XpXPH8SehxDrSS9(GxdkcZILDQy53jwAhQ9NLdZIRcxplpKfQarhlTHQyKILdZIRcxplpKfQarhlPGlw8HyXFwaKPdywIjgaYYvS4flOFqFrycDSG0yIeRTcSOD8JzXl4VtdlayaJPaMf4Wsk4IflWLgKficAcEelDWHy539IforP0zjMyailw2PILuWflwGlnyH2NLT3h8AqrSuqlCAE4pyHnQq)bSYib)(GxdkcDxt5EQqmwXvpnrqT)eyUDO2)8qD(vyGznjj9uxTMzCeubx4CBOkgPmd15xHbgQaOPZrgWhOt3ZX)46Ce0cni34MEFfQRwZmocQGlCUnufJuMvu)(jj9C8pUohbTqdGr4Z5QAY44iainBua4vxTMHc6lctzmu7JzOo)kmGbHVPTMuzylt6vrM)caHZd15xb8a0GM4vsP0tsC8pUohbTqdGr4Z5QAY44iainBua4vxTMHc6lctz9Q8XmuNFfgWGW30wtQmSLj9QiZFbGW5H68RaEaAqt8kPu69vqb9fHjZvzVsPONvQRwZe88vbZkkjXQ31u9g87JgoGgQCvnb2xrVEwfGqni0szcE(QGzfLKeGiOYR3auQ58sHvbiudcTugQlcAHMSkSanRO(jjbicQ86n1HA)ZnN6RONvbicQ86niO63tnjjwPUAntWZxfmROKeh)JRZrql0epGm9(jj9Ext1BWVpA4aAOYv1eOc1vRzcE(QGzfPON6Q1m43hnCan43dabS4MK44FCDocAHM4bKP3VFsI6Q1mbpFvWSIuyL6Q1mJJGk4cNBdvXiLzfPWQ31u9g87JgoGgQCvnbYPH8SeNyIfaKqyHz5kwqVv5dlOFqFryIfVazb7iiwqoJRBaooS0AwaqcHfln4WcsJjsS2kWP5H)Gf2Oc9hWkJKISK7GWcDxt5EQRwZqb9fHPSEv(ygQZVchpHmkSEk)xhLK0lS7dkcRmavmuy3huu(VocyOPFssy3huew542xHhLd7uaionp8hSWgvO)awzKS76wUdcl0DnL7PUAndf0xeMY6v5JzOo)kC8eYOW6P8FDKIEbiudcTuMGNVkygQZVchpAspjjaHAqOLYeGfciqu(3Pmo6M7XMH68RWXJM07NK0lS7dkcRmavmuy3huu(VocyOPFssy3huew542xHhLd7uaionp8hSWgvO)awzK0wADUdcl0DnL7PUAndf0xeMY6v5JzOo)kC8eYOW6P8FDKIEbiudcTuMGNVkygQZVchpAspjjaHAqOLYeGfciqu(3Pmo6M7XMH68RWXJM07NK0lS7dkcRmavmuy3huu(VocyOPFssy3huew542xHhLd7uaionKNfKdi6ZcSyjaYP5H)Gf2Oc9hWkJel(mhCYWwM0RI40qEwItmXY27t7gILhYs0adSSb1(Wc6h0xeMyboSyzNkwUIfyPtXc6TkFyb9d6lctS4fillmXcYbe9zjAGbmlxJLRyb9wLpSG(b9fHjonp8hSWgvO)awzKGFFA3qO7Aktb9fHjZvz9Q8jjHc6lctgmu7tUiK9jjuqFryY4vQCri7tsuxTMXIpZbNmSLj9QiZksH6Q1muqFrykRxLpMvussp1vRzcE(QGzOo)kmW8WFWYyz8F3qiJcRNY)1rkuxTMj45RcMvuFonp8hSWgvO)awzKyz8FNtZd)blSrf6pGvgjZQYE4pyL1h(rx5DKYnxR)9zXPXPH8SS9(GxdkILgCyPdIG6O6zzvAcJzzHVcflXggtRZP5H)Gf20CT(3NLY43h8AqrO7AkB1SkQbhuKr11EfOmSLDTo)7xHcBiG76IIiqonKNfK64NLFNybe(Sy5(Dw(DILoi(z5VoILhYIdcYYQ(tZYVtS05iJfW14)blwoml73ByzBvTBiwgQZVcZs3s)xK(iqwEilD(h2zPdcR2nelGRX)dwCAE4pyHnnxR)9zbyLrcEvTBi0fsf0u(9bf9yLvcDxtzq4B6GWQDdzgQZVch)qD(vyGhGae5QeaMtZd)blSP5A9VplaRms6GWQDdXPXPH8SeNyILT3h8AqrS8qwaIOiwwrS87elXXH8o1RaPHf1vRXY1y5EwSaxAqwiKfDdXIk1GdXs7QdVFfkw(DILIq2ZsWXplWHLhYc4QlIfvQbhIfKcleqGionp8hSWg8Rm(9bVgue6UMYZQOgCqrM)6ilWPYGd5DQxbsJIEuqFryYCv2RukSQxp1vRz(RJSaNkdoK3PEfinMH68RWX7H)GLXY4)UHqgfwpL)RJaC6gLu0Jc6lctMRYQWFpjHc6lctMRYyO2NKekOVimz0RYNCri77NKOUAnZFDKf4uzWH8o1RaPXmuNFfoEp8hSm43N2nKHqgfwpL)RJaC6gLu0Jc6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXRu5Iq23VFsIvQRwZ8xhzbovgCiVt9kqAmRO(jj9uxTMj45RcMvusccFoxvtMaSqabIYGeovf6RiaHAqOLYeGfciqu(3Pmo6M7XMHCWukcqeu51BQd1(NBo1xrpRcqeu51Bak1CELKeGqni0szOUiOfAYQWc0muNFfoEaCFf9uxTMj45RcMvusIvbiudcTuMGNVkygYbt1Ntd5zjoXelXe0J(dbXYMfF6yXYovS870qSCywkilE4peelyl(0HowCmlA)jwCmlrqm(u1elWIfSfF6yXY97SaqwGdlnYcnSGFpaeMf4WcSyXzjUaMfSfF6ybdz539NLFNyPilSGT4thl(mhccZcakl8ZI3EAy539NfSfF6yHqw0neMtZd)blSb)awzK4GE0FiOm2IpDOlKkOP87dk6XkRe6UMYwbcFJd6r)HGYyl(0Lb9ohfz(la0vOuyLh(dwgh0J(dbLXw8Pld6DokYCvUPpu7VIEwbcFJd6r)HGYyl(0L3jxB(la0vOssaHVXb9O)qqzSfF6Y7KRnd15xHJhn9tsaHVXb9O)qqzSfF6YGENJIm43dabS4Qae(gh0J(dbLXw8Pld6DokYmuNFfgyXvbi8noOh9hckJT4txg07CuK5VaqxHItd5zjoXeMfKcleqGiwUglinMiXARalhMLvelWHLuWfl(qSas4uv4kuSG0yIeRTcSy5(DwqkSqabIyXlqwsbxS4dXIkPHwyXAsNLyIbGCAE4pyHn4hWkJKaSqabIY)oLXr3CpgDxtzRaN1bAkyoaIv0RhcFoxvtMaSqabIYGeovfuyvac1GqlLj45RcMHCWukSAwf1GdkYenxhCapxN9j41fYrln2NKe1vRzcE(QGzf1xHJ)X15iOfAaM1KUIEQRwZqb9fHPSEv(ygQZVchVsPNKOUAndf0xeMYyO2hZqD(v44vk9(jjQqmwr7qT)5H68RWatP0vyvac1GqlLj45RcMHCWu950qEwqkSaV)Gfln4WIR1SacFml)U)S05arywWRHy53PuS4dvO9zzO2q4DcKfl7uXcachbvWfML4WqvmsXYUJzrtyml)UxSGgwWuaZYqD(vxHIf4WYVtSauQ58If1vRXYHzXvHRNLhYsZ1AwGTglWHfVsXc6h0xeMy5WS4QW1ZYdzHqw0neNMh(dwyd(bSYibHpNRQj0vEhPmi8ZdbCx3qDu9y0HW1ls5EQRwZmocQGlCUnufJuMH68RWXJMKeRuxTMzCeubx4CBOkgPmRO(kSsD1AMXrqfCHZTHQyKkJVQT059u4NMZnRif9uxTMbORahcmtDrql00r1NPIguxmiZqD(vyGHkaA6CK1xrp1vRzOG(IWugd1(ygQZVchpQaOPZrwsI6Q1muqFrykRxLpMH68RWXJkaA6CKLK0Zk1vRzOG(IWuwVkFmROKeRuxTMHc6lctzmu7Jzf1xHvVRP6nyOg)xGmu5QAcSpNgYZcsHf49hSy539NLWofacZY1yjfCXIpelW1JpqIfkOVimXYdzbw6uSacFw(DAiwGdlhQcoel)(HzXY97SSb14)ceNMh(dwyd(bSYibHpNRQj0vEhPmi8ZW1Jpqktb9fHj0HW1ls5EwPUAndf0xeMYyO2hZksHvQRwZqb9fHPSEv(ywr9tsExt1BWqn(VazOYv1eiNMh(dwyd(bSYiPdcR2ne6cPcAk)(GIESYkHURP8qTHW7UQMu0tD1AgkOVimLXqTpMH68RWXpuNFfojrD1AgkOVimL1RYhZqD(v44hQZVcNKGWNZv1Kbe(z46XhiLPG(IWuFfd1gcV7QAsX7dk6n)1r5hMbpkELaOcpkh2Paqkq4Z5QAYac)8qa31nuhvpMtZd)blSb)awzKGxv7gcDHubnLFFqrpwzLq31uEO2q4Dxvtk6PUAndf0xeMYyO2hZqD(v44hQZVcNKOUAndf0xeMY6v5JzOo)kC8d15xHtsq4Z5QAYac)mC94dKYuqFryQVIHAdH3DvnP49bf9M)6O8dZGhfVsauHhLd7uaifi85CvnzaHFEiG76gQJQhZP5H)Gf2GFaRmsWpP1(KBAFi0fsf0u(9bf9yLvcDxt5HAdH3DvnPON6Q1muqFrykJHAFmd15xHJFOo)kCsI6Q1muqFrykRxLpMH68RWXpuNFfojbHpNRQjdi8ZW1Jpqktb9fHP(kgQneE3v1KI3hu0B(RJYpmdEu8kbOu4r5WofasbcFoxvtgq4Nhc4UUH6O6XCAiplXjMyjoaJflWILailwUFhUEwcEu0vO408WFWcBWpGvgjn4eOmSLl)xdHURPShLd7uaionKNL4etSGC6kWHazzl6M7XSy5(Dw8kflAyHIfQGlu7SOD8Ffkwq)G(IWelEbYYpPy5HSOVIy5EwwrSy5(DwaGln2hw8cKfKgtKyTvGtZd)blSb)awzKqDrql0KvHfi6UMY96PUAndf0xeMYyO2hZqD(v44vk9Ke1vRzOG(IWuwVkFmd15xHJxP07RiaHAqOLYe88vbZqD(v44JB6k6PUAnt0CDWb8CD2NGxxihT0yFmiC9IagaTM0tsSAwf1GdkYenxhCapxN9j41fYrln2hdbCxxueb2VFsI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lkELbiGo9KKaeQbHwktWZxfmd5GPu44FCDocAHM4bKPZPH8SeNyIfKgtKyTvGfl3VZcsHfciqesqoDf4qGSSfDZ9yw8cKfqyH2NficASm3tSaaxASpSahwSStflXwdHG6f(zXcCPbzHqw0nelQudoelinMiXARaleYIUHWCAE4pyHn4hWkJee(CUQMqx5DKYbWCawG3FWkJF0HW1lszRaN1bAkyoaIvGWNZv1KjaMdWc8(dwk61laHAqOLYqDrPgY1z4awEfiZqD(vyGPeGcqd4EkPeWpRIAWbfzWx1w68Ek8tZ59vqa31ffrGgQlk1qUodhWYRa1pjXX)46Ce0cnXRmGmDf9S6DnvVPTMuzylt6vrgQCvnbMKOUAntWZxfmGRX)dwXhGqni0szARjvg2YKEvKzOo)kmGbW9vGWNZv1K53NtRZyIaIMSf)Ef9uxTMbORahcmtDrql00r1NPIguxmiZkkjXQaebvE9gGsnNx9v8(GIEZFDu(HzWJIxD1AMGNVkyaxJ)hSa(0na6KevigRODO2)8qD(vyGPUAntWZxfmGRX)dwjjbicQ86n1HA)ZnNssuxTMrvdHG6f(nRifQRwZOQHqq9c)MH68RWatD1AMGNVkyaxJ)hSaCpajWpRIAWbfzIMRdoGNRZ(e86c5OLg7JHaURlkIa73xHvQRwZe88vbZksrpRcqeu51BQd1(NBoLKeGqni0szcWcbeik)7ughDZ9yZkkjrfIXkAhQ9ppuNFfgybiudcTuMaSqabIY)oLXr3Cp2muNFfgWaQKK2HA)Zd15xHrUixLaWPdm1vRzcE(QGbCn(FWQpNgYZsCIjw(DIfauP63tnSy5(DwCwqAmrI1wbw(D)z5WfAFwAdSJfa4sJ9HtZd)blSb)awzKmocQGlCUnufJuO7AkRUAntWZxfmd15xHJxj0KKOUAntWZxfmGRX)dwalUPRaHpNRQjtamhGf49hSY4NtZd)blSb)awzKeinH)Z1zxFOQoQE0DnLr4Z5QAYeaZbybE)bRm(v0Zk1vRzcE(QGbCn(FWk(4MEsIvbicQ86niO63tn9tsuxTMzCeubx4CBOkgPmRifQRwZmocQGlCUnufJuMH68RWadqc4aSax3BIgkCyk76dv1r1B(RJYiC9IaCpRuxTMrvdHG6f(nRifw9UMQ3GFF0Wb0qLRQjW(CAE4pyHn4hWkJKRc(u(FWcDxtze(CUQMmbWCawG3FWkJFonKNfau95CvnXYctGSalwC1tF)ryw(D)zXIxplpKfvIfSJGazPbhwqAmrI1wbwWqw(D)z53PuS4dvplwC8tGSaGYc)SOsn4qS87uhNMh(dwyd(bSYibHpNRQj0vEhPm2rq5gCYbpFvaDiC9Iu2QaeQbHwktWZxfmd5GPssScHpNRQjtawiGarzqcNQckcqeu51BQd1(NBoLKaoRd0uWCaeZPH8SeNycZsCaI(SCnwUIfVyb9d6lctS4fil)CeMLhYI(kIL7zzfXIL73zbaU0yFqhlinMiXARalEbYsmb9O)qqSSzXNoonp8hSWg8dyLrsBnPYWwM0RIq31uMc6lctMRYELsHhLd7uaifQRwZenxhCapxN9j41fYrln2hdcxViGbqRjDf9aHVXb9O)qqzSfF6YGENJIm)fa6kujjwfGiOYR3uuyGA4a2xbcFoxvtgSJGYn4KdE(QGIEQRwZmocQGlCUnufJuMH68RWadqci6HgGFwf1GdkYGVQT059u4NMZ7RqD1AMXrqfCHZTHQyKYSIssSsD1AMXrqfCHZTHQyKYSI6ZPH8SeNyIfa0f97SS9(0CTMLObgWSCnw2EFAUwZYHl0(SSI408WFWcBWpGvgj43NMR1O7AkRUAndSOFhNJOjqr)blZksH6Q1m43NMR1MHAdH3DvnXP5H)Gf2GFaRmscEfiDwD1AOR8osz87JgoGO7AkRUAnd(9rdhqZqD(vyGHgf9uxTMHc6lctzmu7JzOo)kC8OjjrD1AgkOVimL1RYhZqD(v44rtFfo(hxNJGwOjEaz6CAiplXXvxeMLyIbGSOsn4qSGuyHaceXYcFfkw(DIfKcleqGiwcWc8(dwS8qwc7uaiwUglifwiGarSCyw8WVCToflUkC9S8qwujwco(508WFWcBWpGvgj43h8AqrO7AkhGiOYR3uhQ9p3CsbcFoxvtMaSqabIYGeovfueGqni0szcWcbeik)7ughDZ9yZqD(vyGHgfwboRd0uWCaeZPH8SeNyILT3NMR1Sy5(Dw2EsR9HL44CTNfVazPGSS9(OHdi6yXYovSuqw2EFAUwZYHzzfHowsbxS4dXYvSGERYhwq)G(IWeln4WcagWykGzboS8qwIgyGfa4sJ9Hfl7uXIRcrqSaitNLyIbGSahwCWi)peelyl(0XYUJzbadymfWSmuNF1vOyboSCywUILM(qT)gwIf8jw(D)zzvG0WYVtSG9oILaSaV)GfML7rlMfWimlfT(X1S8qw2EFAUwZc4AUcflaiCeubxywIddvXif6yXYovSKcUqlil4)0AwOcKLvelwUFNfaz6a2XrS0Gdl)oXI2XplO0qvxJnCAE4pyHn4hWkJe87tZ1A0DnLFxt1BWpP1(KbNR9gQCvnbQWQ31u9g87JgoGgQCvnbQqD1Ag87tZ1AZqTHW7UQMu0tD1AgkOVimL1RYhZqD(v44bWkOG(IWK5QSEv(OqD1AMO56Gd456SpbVUqoAPX(yq46fbmaIM0tsuxTMjAUo4aEUo7tWRlKJwASpgeUErXRmart6kC8pUohbTqt8aY0tsaHVXb9O)qqzSfF6YGENJImd15xHJhaNK4H)GLXb9O)qqzSfF6YGENJImxLB6d1(3xrac1GqlLj45RcMH68RWXRu6CAiplXjMyz79bVguelaOl63zjAGbmlEbYc4QlILyIbGSyzNkwqAmrI1wbwGdl)oXcaQu97PgwuxTglhMfxfUEwEilnxRzb2ASahwsbxOfKLGhXsmXaqonp8hSWg8dyLrc(9bVgue6UMYQRwZal63X5GM8jJ4WhSmROKe1vRza6kWHaZuxe0cnDu9zQOb1fdYSIssuxTMj45RcMvKIEQRwZmocQGlCUnufJuMH68RWadva005id4d0P754FCDocAHgKBCtVpGJlW)UMQ3uKLChewgQCvnbQWQzvudoOid(Q2sN3tHFAoxH6Q1mJJGk4cNBdvXiLzfLKOUAntWZxfmd15xHbgQaOPZrgWhOt3ZX)46Ce0cni34ME)Ke1vRzghbvWfo3gQIrQm(Q2sN3tHFAo3SIssSsD1AMXrqfCHZTHQyKYSIuyvac1GqlLzCeubx4CBOkgPmd5GPssSkarqLxVbbv)EQPFsIJ)X15iOfAIhqMUckOVimzUk7vkonKNfRpPy5HS05arS87elQe(zb2yz79rdhqwutXc(9aqxHIL7zzfXcWDDbG0Py5kw8kflOFqFryIf11ZcaCPX(WYHRNfxfUEwEilQelrdmeiqonp8hSWg8dyLrc(9bVgue6UMYVRP6n43hnCanu5QAcuHvZQOgCqrM)6ilWPYGd5DQxbsJIEQRwZGFF0Wb0SIssC8pUohbTqt8aY07RqD1Ag87JgoGg87bGawCv0tD1AgkOVimLXqTpMvusI6Q1muqFrykRxLpMvuFfQRwZenxhCapxN9j41fYrln2hdcxViGbqaD6k6fGqni0szcE(QGzOo)kC8kLEsIvi85CvnzcWcbeikds4uvqraIGkVEtDO2)CZP(CAiplOp(Vo)jml7qlS0Tc7SetmaKfFiwq5xrGSerdlykalqonp8hSWg8dyLrccFoxvtOR8oszhhbaPzJcOdHRxKYuqFryYCvwVkFaEamY1d)bld(9PDdziKrH1t5)6iaBff0xeMmxL1RYhGVhGcWVRP6ny4sNHT8Vt5gCi8BOYv1eiWh3(ixp8hSmwg)3neYOW6P8FDeGt3ynOb5IJiToV74NaC6g0a8VRP6nL)RHWzvx7vGmu5QAcKtd5zjoU6Iyz79bVguelxXIZcGgWykWYgu7dlOFqFrycDSacl0(SOPNL7zjAGbwaGln2hw697(ZYHzz3lqnbYIAkwO73PHLFNyz79P5Anl6RiwGdl)oXsmXaW4bKPZI(kILgCyz79bVguuF0XciSq7ZcebnwM7jw8Ifa0f97SenWalEbYIMEw(DIfxfIGyrFfXYUxGAILT3hnCa508WFWcBWpGvgj43h8AqrO7AkB1SkQbhuK5VoYcCQm4qEN6vG0OON6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lcyaeqNEsI6Q1mrZ1bhWZ1zFcEDHC0sJ9XGW1lcyaenPR4DnvVb)Kw7tgCU2BOYv1eyFf9OG(IWK5QmgQ9rHJ)X15iOfAamcFoxvtghhbaPzJcaV6Q1muqFrykJHAFmd15xHbmi8nT1KkdBzsVkY8xaiCEOo)kGhGg0epao9KekOVimzUkRxLpkC8pUohbTqdGr4Z5QAY44iainBua4vxTMHc6lctz9Q8XmuNFfgWGW30wtQmSLj9QiZFbGW5H68RaEaAqt8aY07RWk1vRzGf974Cenbk6pyzwrkS6DnvVb)(OHdOHkxvtGk6fGqni0szcE(QGzOo)kC8a6KemCPvVc087ZP1zmrarJHkxvtGkuxTM53NtRZyIaIgd(9aqalUXfq0Bwf1GdkYGVQT059u4NMZbE00xr7qT)5H68RWXRu6PRODO2)8qD(vyGbW0tVVIEbiudcTugGUcCiWmo6M7XMH68RWXdOtsSkarqLxVbOuZ5vFonKNL4etSaGeclmlxXc6TkFyb9d6lctS4filyhbXcYzCDdWXHLwZcasiSyPbhwqAmrI1wbw8cKfKtxboeilOFxe0cnDu9CAE4pyHn4hWkJKISK7GWcDxt5EQRwZqb9fHPSEv(ygQZVchpHmkSEk)xhLK0lS7dkcRmavmuy3huu(VocyOPFssy3huew542xHhLd7uaifi85CvnzWock3Gto45RcCAE4pyHn4hWkJKDx3YDqyHURPCp1vRzOG(IWuwVkFmd15xHJNqgfwpL)RJuyvaIGkVEdqPMZRKKEQRwZa0vGdbMPUiOfA6O6ZurdQlgKzfPiarqLxVbOuZ5v)KKEHDFqryLbOIHc7(GIY)1radn9tsc7(GIWkh3Ke1vRzcE(QGzf1xHhLd7uaifi85CvnzWock3Gto45Rck6PUAnZ4iOcUW52qvmszgQZVcdSEObqaqGFwf1GdkYGVQT059u4NMZ7RqD1AMXrqfCHZTHQyKYSIssSsD1AMXrqfCHZTHQyKYSI6ZP5H)Gf2GFaRmsAlTo3bHf6UMY9uxTMHc6lctz9Q8XmuNFfoEczuy9u(VosHvbicQ86naLAoVss6PUAndqxboeyM6IGwOPJQptfnOUyqMvKIaebvE9gGsnNx9ts6f29bfHvgGkgkS7dkk)xhbm00pjjS7dkcRCCtsuxTMj45RcMvuFfEuoStbGuGWNZv1Kb7iOCdo5GNVkOON6Q1mJJGk4cNBdvXiLzOo)kmWqJc1vRzghbvWfo3gQIrkZksHvZQOgCqrg8vTLoVNc)0CEsIvQRwZmocQGlCUnufJuMvuFonKNL4etSGCarFwGflbqonp8hSWg8dyLrIfFMdozylt6vrCAiplXjMyz79PDdXYdzjAGbw2GAFyb9d6lctOJfKgtKyTvGLDhZIMWyw(RJy539IfNfKJX)DwiKrH1tSOP2ZcCybw6uSGERYhwq)G(IWelhMLveNMh(dwyd(bSYib)(0UHq31uMc6lctMRY6v5tscf0xeMmyO2NCri7tsOG(IWKXRu5Iq2NK0tD1Agl(mhCYWwM0RImROKeCeP15Dh)eWs3ynOrHvbicQ86niO63tnjj4isRZ7o(jGLUXAueGiOYR3GGQFp10xH6Q1muqFrykRxLpMvussp1vRzcE(QGzOo)kmW8WFWYyz8F3qiJcRNY)1rkuxTMj45RcMvuFonKNL4etSGCm(VZc83PXYHjwSSFHDwomlxXYgu7dlOFqFrycDSG0yIeRTcSahwEilrdmWc6TkFyb9d6lctCAE4pyHn4hWkJelJ)7CAiplXbxR)9zXP5H)Gf2GFaRmsMvL9WFWkRp8JUY7iLBUw)7ZY(TFBBa]] )


end