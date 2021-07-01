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


    spec:RegisterPack( "Balance", 20210701, [[deLRzfqikkpcIQUeevAtKWNGuzusvoLuvRcqvVcGAwqkDlac7Is)cIyysOogjQLbGEMeOPrrfxdsX2ai13aiACaqohGkwhajZdq5EKi7tc6FqurPdkuyHcL6HqKMOeGUiKQSrja(ievunsiQO4KuuPvkH8siQiZesvDtaO0ofk6Naqvdfa0sbGINQuMkfvDvjG2kauPVcrfglaWEPWFL0GjomvlMKESGjd0Lr2Su(mKmALQtRQvdav8Aaz2K62s0Uf9BqdxihhqLwUINd10v56kz7q47uKXdr58cvRxOK5lv2pQnu2W8gBG(rgXeGfdqLlgqwSY2IbqaeavqZXy7IhrgBrEaihfzSLEjzSfBx7zGm2I84AOdAyEJnmCnbYyB)UimGcjir11Egiab(ldwu)TVuTpejX21EgiaX2xIuKucA3VsnYzBVMus11Egi7HSZytD96ZCtdvJnq)iJycWIbOYfdilwzBXaiacGaiAm281TdhJTTVePgB7piiLgQgBGeoySfBx7zGyPaoRhKlQOvsSuWIrllaSyaQmxexes39efHbuCracwIbiibYYgu7dlXM8slxeGGfKU7jkcKLZhu0v)glbhtywoilH4bnvpFqrh2YfbiybadvcrqGSSYKceg7tCwq4Z7QAcZsV3sw0Ys0qiQ4Zh8AqrSaikKLOHqyXNp41GI6B5IaeSedeWhKLOHco((eflihJF7S8nw(dDywUDIftdmrXc6f0FeMSCracwaW6arSGuyIaceXYTtSSf9ZFywCw0)DAILs4qS00eYEvnXsVVXsC4ILDhmr3XY(FS8hl4VCPppj4cRJZIP)2zj2a4JH5zbWSGust47DnlXq)OYskp0YYFOdKfmqFuFlxeGGfaSoqelLq8Xc6ApQ9RouP)jgDSGdu6ZdXS4rr64SCqwuHymlTh1(HzbM64wUiUOyKj88Jazj2U2ZaXsmaGOplbpzrLyPbxjil(XY(DryafsqIQR9mqac8xgSO(BFPAFisITR9mqaITVePiPe0UFLAKZ2EnPKQR9mq2dzNXM(Xh2W8gBGuZx6ZW8gXuzdZBS5H7HPXggQ9PQsEPXgLUQManITXzetaAyEJnkDvnbAeBJnyKXgMoJnpCpmn2q4Z7QAYydHRxKXgoI0665dk6Ww85tZ1AwkKfLzrbl9yXmwoxt5zXNpA4aAP0v1eilDDSCUMYZIpsR9PcoF7Su6QAcKL(S01XcoI0665dk6Ww85tZ1AwkKfaASbs4W8r3dtJTn6WSedi6XcmzPGaMft)TdxhlGZ3ow8eKft)TZY25JgoGS4jilaeWSaVDAm9yYydHp10ljJThxDizCgXSGgM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSHJiTUE(GIoSfF(0(HyPqwu2ydKWH5JUhMgBB0HzjOjhbXIPDkzz78P9dXsWtw2)JfacywoFqrhMft7FyNLhZYqAcHNhln4WYTtSGEb9hHjwoilQelrd1Oziqw8eKft7FyNL2R10WYbzj44ZydHp10ljJThxdAYrqgNrmnhdZBSrPRQjqJyBS5H7HPXMknyAa6tugBGeomF09W0yRaXelXMgmna9jkwm93olingiXCZalWHfVD0WcsHjciqelFYcsJbsm3mySfM)O5DJTESyglbick98S5JA)QnNyPRJfZyjaHAqOP0gGjciqu92Pko6N)W2vel9zrblQRwZg86Nb7qL(NywkKfLrdlkyrD1A2XrqjCHRTHYyf3ouP)jMfGXI5WIcwmJLaebLEEweuE7Xhw66yjarqPNNfbL3E8HffSOUAnBWRFgSRiwuWI6Q1SJJGs4cxBdLXkUDfXIcw6XI6Q1SJJGs4cxBdLXkUDOs)tmlaJfLvMfablOHfGNLzLudoOil(Z2sx3JJpAE3sPRQjqw66yrD1A2Gx)myhQ0)eZcWyrzLzPRJfLzbjSGJiTUU74JybySOSfnOHL(gNrmrJH5n2O0v1eOrSn2cZF08UXM6Q1SbV(zWouP)jMLczrz0WIcw6XIzSmRKAWbfzXF2w66EC8rZ7wkDvnbYsxhlQRwZoockHlCTnugR42Hk9pXSamwugqYIcwuxTMDCeucx4ABOmwXTRiw6ZsxhlQqmMffS0Eu7xDOs)tmlaJfaIgJnqchMp6EyASbaHhlM(BNfNfKgdKyUzGLB3pwECIUJfNfa4sJ9HLObgyboSyANswUDIL2JA)y5XS4QW1XYbzHsqJnpCpmn2IG3dtJZiMaAdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2c0RzPhl9yP9O2V6qL(NywaeSOmAybqWsac1GqtPn41pd2Hk9pXS0NfKWIYaOIzPplkXsGEnl9yPhlTh1(vhQ0)eZcGGfLrdlacwugGfZcGGLaeQbHMsBaMiGar1BNQ4OF(dBhQ0)eZsFwqclkdGkML(SOGfZyz8hSsiO8Soii2si7XhMLUowcqOgeAkTbV(zWouP)jMLcz5ZJMiO2pcS2Eu7xDOs)tmlDDSeGqni0uAdWebeiQE7ufh9ZFy7qL(NywkKLppAIGA)iWA7rTF1Hk9pXSaiyr5IzPRJfZyjarqPNNnFu7xT5elDDS4H7HPnateqGO6TtvC0p)HTGp2v1eOXgiHdZhDpmn2qQRdlTFeMft70Ttdll8NOybPWebeiILeAIftVwZIR1qtSehUy5GSGVxRzj44JLBNyb7LelEjCLhlWglifMiGaragPXajMBgyj44dBSHWNA6LKXwaMiGarvqchpdgNrmbKgM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzS1JLZhu0zVVKQhSc(elfYIYOHLUowg)bReckpRdcITFYsHSGMIzPplkyPhl9yPhlMXcbCxFuebAPYO4d56kCatpdelDDS0JLESeGqni0uAPYO4d56kCatpdKDOs)tmlaJfLb0fZsxhlbick98SiO82JpSOGLaeQbHMslvgfFixxHdy6zGSdv6FIzbySOmGgqYcGzPhlkRmlaplZkPgCqrw8NTLUUhhF08ULsxvtGS0NL(SOGfZyjaHAqOP0sLrXhY1v4aMEgi7qoyCw6ZsFwuWspwmJfc4U(Oic0IHlTMU7tu1zPgNLUowmJLaebLEE28rTF1MtS01Xsac1GqtPfdxAnD3NOQZsnUDOs)tmlaJfLv2CyPplkyPhlMXcbCxFuebA)ehM15QAQcCxEERYkiH4delDDSeGqni0uA)ehM15QAQcCxEERYkiH4dKDihmol9zrbl9yjaHAqOP0QsdMgG(eLDihmolDDSyglJhi7nqTML(S01Xspw6XccFExvtwywxyQEZNarhlkXIYS01XccFExvtwywxyQEZNarhlkXsbzPplkyPhl38jq0zpLTd5GXRbiudcnLS01XYnFceD2tzBac1GqtPDOs)tmlfYYNhnrqTFeyT9O2V6qL(NywaeSOCXS0NLUowq4Z7QAYcZ6ct1B(ei6yrjwailkyPhl38jq0zpaAhYbJxdqOgeAkzPRJLB(ei6ShaTbiudcnL2Hk9pXSuilFE0eb1(rG12JA)Qdv6FIzbqWIYfZsFw66ybHpVRQjlmRlmvV5tGOJfLyPyw6ZsFw66yjarqPNNfO4Z7jl9n2ajCy(O7HPXwbIjqwoilGK2JZYTtSSWokIfyJfKgdKyUzGft7uYYc)jkwaHlvnXcmzzHjw8eKLOHqq5XYc7OiwmTtjlEYIdcYcHGYJLhZIRcxhlhKfWNm2q4tn9sYylawdWe8VhMgNrmbqgM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSzgly4sR(jO92NxRRyIaIglLUQMazPRJL2JA)Qdv6FIzPqwayXfZsxhlQqmMffS0Eu7xDOs)tmlaJfaIgwaml9yXCkMfablQRwZE7ZR1vmrarJfFEaiwaEwail9zPRJf1vRzV9516kMiGOXIppaelfYsbbqSaiyPhlZkPgCqrw8NTLUUhhF08ULsxvtGSa8SGgw6BSHWNA6LKX2TpVwxXebenvt(FgNrmbogM3yJsxvtGgX2ydKWH5JUhMgBfiMyb9kJIpKRzba)aMEgiwayXykGzrLAWHyXzbPXajMBgyzHjRXw6LKXgvgfFixxHdy6zGm2cZF08UXwac1GqtPn41pd2Hk9pXSamwayXSOGLaeQbHMsBaMiGar1BNQ4OF(dBhQ0)eZcWybGfZIcw6XccFExvt2BFETUIjciAQM8)yPRJf1vRzV9516kMiGOXIppaelfYsblMfaZspwMvsn4GIS4pBlDDpo(O5DlLUQMazb4zbqZsFw6ZsxhlQqmMffS0Eu7xDOs)tmlaJLccin28W9W0yJkJIpKRRWbm9mqgNrmvUydZBSrPRQjqJyBSbs4W8r3dtJTcetSSbxAnDFIIfaml14SaOXuaZIk1GdXIZcsJbsm3mWYctwJT0ljJnmCP10DFIQol14gBH5pAE3ylaHAqOP0g86Nb7qL(NywaglaAwuWIzSeGiO0ZZIGYBp(WIcwmJLaebLEE28rTF1MtS01XsaIGsppB(O2VAZjwuWsac1GqtPnateqGO6TtvC0p)HTdv6FIzbySaOzrbl9ybHpVRQjBaMiGarvqchpdS01Xsac1GqtPn41pd2Hk9pXSamwa0S0NLUowcqeu65zrq5ThFyrbl9yXmwMvsn4GIS4pBlDDpo(O5DlLUQMazrblbiudcnL2Gx)myhQ0)eZcWybqZsxhlQRwZoockHlCTnugR42Hk9pXSamwu2CybWS0Jf0WcWZcbCxFuebA)eFZkCWbxbFeFsvvsRzPplkyrD1A2XrqjCHRTHYyf3UIyPplDDSOcXywuWs7rTF1Hk9pXSamwaiAm28W9W0yddxAnD3NOQZsnUXzetLv2W8gBu6QAc0i2gBE4EyAS9jomRZv1uf4U88wLvqcXhiJTW8hnVBSPUAnBWRFgSdv6FIzPqwugnSOGLESyglZkPgCqrw8NTLUUhhF08ULsxvtGS01XI6Q1SJJGs4cxBdLXkUDOs)tmlaJfLbilaMLESuqwaEwuxTMvvdHG6f(SRiw6ZcGzPhl9ybqYcGGf0WcWZI6Q1SQAieuVWNDfXsFwaEwiG76JIiq7N4BwHdo4k4J4tQQsAnl9zrblQRwZoockHlCTnugR42vel9zPRJfvigZIcwApQ9RouP)jMfGXcarJXw6LKX2N4WSoxvtvG7YZBvwbjeFGmoJyQmanmVXgLUQManITXgiHdZhDpmn2m)(Jz5XS4Sm(TtdlK2vHJFelM84SCqwkDGiwCTMfyYYctSGp)y5MpbIomlhKfvIf9NeilRiwm93olingiXCZalEcYcsHjciqelEcYYctSC7elambzbRHhlWKLailFJfv4TZYnFceDyw8HybMSSWel4ZpwU5tGOdBSfM)O5DJne(8UQMSWSUWu9MpbIowuIfaYIcwmJLB(ei6ShaTd5GXRbiudcnLS01Xspwq4Z7QAYcZ6ct1B(ei6yrjwuMLUowq4Z7QAYcZ6ct1B(ei6yrjwkil9zrbl9yrD1A2Gx)myxrSOGLESyglbick98SiO82JpS01XI6Q1SJJGs4cxBdLXkUDOs)tmlaMLESGgwaEwMvsn4GIS4pBlDDpo(O5DlLUQMazPplatjwU5tGOZEkBvxTwfCn(9WKffSOUAn74iOeUW12qzSIBxrS01XI6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrS0NLUowcqOgeAkTbV(zWouP)jMfaZcazPqwU5tGOZEkBdqOgeAkTGRXVhMSOGLESyglbick98S5JA)QnNyPRJfZybHpVRQjBaMiGarvqchpdS0NffSyglbick98SafFEpzPRJLaebLEE28rTF1MtSOGfe(8UQMSbyIacevbjC8mWIcwcqOgeAkTbyIacevVDQIJ(5pSDfXIcwmJLaeQbHMsBWRFgSRiwuWspw6XI6Q1Suq)ryQQxPp2Hk9pXSuilkxmlDDSOUAnlf0FeMQyO2h7qL(NywkKfLlML(SOGfZyzwj1GdkYQ6Apduf2QUwxV9prHTu6QAcKLUow6XI6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqSOelOHLUowuxTMv11EgOkSvDTUE7FIcx9j4jzXNhaIfLybaXsFw6ZsxhlQRwZc0NGdbwPYiOjAkP8QusdQpwKDfXsFw66yrfIXSOGL2JA)Qdv6FIzbySaWIzPRJfe(8UQMSWSUWu9MpbIowuILIn2WA4Hn2U5tGOtzJnpCpmn2wyQ(hvInoJyQCbnmVXgLUQManITXMhUhMgBlmv)JkXgBH5pAE3ydHpVRQjlmRlmvV5tGOJfZuIfaYIcwmJLB(ei6SNY2HCW41aeQbHMsw66ybHpVRQjlmRlmvV5tGOJfLybGSOGLESOUAnBWRFgSRiwuWspwmJLaebLEEweuE7Xhw66yrD1A2XrqjCHRTHYyf3ouP)jMfaZspwqdlaplZkPgCqrw8NTLUUhhF08ULsxvtGS0NfGPel38jq0zpaAvxTwfCn(9WKffSOUAn74iOeUW12qzSIBxrS01XI6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrS0NLUowcqOgeAkTbV(zWouP)jMfaZcazPqwU5tGOZEa0gGqni0uAbxJFpmzrbl9yXmwcqeu65zZh1(vBoXsxhlMXccFExvt2amrabIQGeoEgyPplkyXmwcqeu65zbk(8EYIcw6XIzSOUAnBWRFgSRiw66yXmwcqeu65zrq5ThFyPplDDSeGiO0ZZMpQ9R2CIffSGWN3v1KnateqGOkiHJNbwuWsac1GqtPnateqGO6TtvC0p)HTRiwuWIzSeGqni0uAdE9ZGDfXIcw6XspwuxTMLc6pctv9k9XouP)jMLczr5IzPRJf1vRzPG(JWufd1(yhQ0)eZsHSOCXS0NffSyglZkPgCqrwvx7zGQWw1166T)jkSLsxvtGS01XspwuxTMv11EgOkSvDTUE7FIcxt)wdzXNhaIfLybnS01XI6Q1SQU2ZavHTQR11B)tu4Qpbpjl(8aqSOelaiw6ZsFw6ZsxhlQRwZc0NGdbwPYiOjAkP8QusdQpwKDfXsxhlQqmMffS0Eu7xDOs)tmlaJfawmlDDSGWN3v1KfM1fMQ38jq0XIsSuSXgwdpSX2nFceDa04mIPYMJH5n2O0v1eOrSn2ajCy(O7HPXwbIjmlUwZc82PHfyYYctS8hvIzbMSean28W9W0yBHP6Fuj24mIPYOXW8gBu6QAc0i2gBGeomF09W0yRasHhKyXd3dtw0p(yr1XeilWKf8Fl)EyIenH6XgBE4EyASnRS6H7Hzv)4ZydFZhoJyQSXwy(JM3n2q4Z7QAY(4QdjJn9JVA6LKXMdjJZiMkdOnmVXgLUQManITXwy(JM3n2Mvsn4GISQU2ZavHTQR11B)tuylbCxFuebASHV5dNrmv2yZd3dtJTzLvpCpmR6hFgB6hF10ljJnvOFgNrmvgqAyEJnkDvnbAeBJnpCpmn2Mvw9W9WSQF8zSPF8vtVKm2WNXzCgBQq)mmVrmv2W8gBu6QAc0i2gBE4EyASnockHlCTnugR4gBGeomF09W0yRamugR4Sy6VDwqAmqI5MbJTW8hnVBSPUAnBWRFgSdv6FIzPqwugngNrmbOH5n2O0v1eOrSn28W9W0yZb9O7rqvSjFkn2cXdAQE(GIoSrmv2ylm)rZ7gBQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaXcWybaXIcwuxTMv11EgOkSvDTUE7FIcx9j4jzXNhaIfGXcaIffS0JfZybeEwh0JUhbvXM8PSc6LokYEFaOprXIcwmJfpCpmToOhDpcQIn5tzf0lDuK9ZAt)O2pwuWspwmJfq4zDqp6EeufBYNY6o5A79bG(eflDDSacpRd6r3JGQyt(uw3jxBhQ0)eZsHSuqw6ZsxhlGWZ6GE09iOk2KpLvqV0rrw85bGybySuqwuWci8SoOhDpcQIn5tzf0lDuKDOs)tmlaJf0WIcwaHN1b9O7rqvSjFkRGEPJIS3ha6tuS03ydKWH5JUhMgBfiMyjgGE09iiw2m5tjlM2PKf)yrtyml3UNSyoSeBymmpl4ZdaHzXtqwoild1gcVZIZcWucGSGppaeloMfTFeloMLiig)QAIf4WY9Lel)XcgYYFS4Z8iimla4SWhlE7OHfNLccywWNhaIfczr)qyJZiMf0W8gBu6QAc0i2gBE4EyASfGjciqu92Pko6N)WgBGeomF09W0yRaXelifMiGarSy6VDwqAmqI5MbwmTtjlrqm(v1elEcYc82PX0Jjwm93ololXggdZZI6Q1yX0oLSas44z4tugBH5pAE3yZmwaN1dAtynaIzrbl9yPhli85DvnzdWebeiQcs44zGffSyglbiudcnL2Gx)myhYbJZsxhlQRwZg86Nb7kIL(SOGLESOUAnRQR9mqvyR6AD92)efUM(TgYIppaelkXcaILUowuxTMv11EgOkSvDTUE7FIcx9j4jzXNhaIfLybaXsFw66yrfIXSOGL2JA)Qdv6FIzbySOCXS034mIP5yyEJnkDvnbAeBJnpCpmn2ARjEf2QKELKXgiHdZhDpmn2kaq0JfhZYTtS0(bFSGkaYYNSC7elolXggdZZIPpbHMyboSy6VDwUDIfKtXN3twuxTglWHft)TZIZcacWykWsma9O7rqSSzYNsw8eKft(FS0GdlingiXCZalFJL)yXempwujwwrS4O8pzrLAWHy52jwcGS8ywAF(4Dc0ylm)rZ7gB9yPhl9yrD1Awvx7zGQWw1166T)jkCn9BnKfFEaiwkKfanlDDSOUAnRQR9mqvyR6AD92)efU6tWtYIppaelfYcGML(SOGLESyglbick98SiO82JpS01XIzSOUAn74iOeUW12qzSIBxrS0NL(SOGLESaoRh0MWAaeZsxhlbiudcnL2Gx)myhQ0)eZsHSGMIzPRJLESeGiO0ZZMpQ9R2CIffSeGqni0uAdWebeiQE7ufh9ZFy7qL(NywkKf0uml9zPpl9zPRJLESacpRd6r3JGQyt(uwb9shfzhQ0)eZsHSaGyrblbiudcnL2Gx)myhQ0)eZsHSOCXSOGLaebLEE2Kcdudhqw6ZsxhlQqmMffS85rteu7hbwBpQ9RouP)jMfGXcaIffSyglbiudcnL2Gx)myhYbJZsxhlbick98SafFEpzrblQRwZc0NGdbwPYiOjAkP8SRiw66yjarqPNNfbL3E8HffSOUAn74iOeUW12qzSIBhQ0)eZcWyb4WIcwuxTMDCeucx4ABOmwXTRiJZiMOXW8gBu6QAc0i2gBE4EyASf8mq6Q6Q1m2cZF08UXwpwuxTMv11EgOkSvDTUE7FIcxt)wdzhQ0)eZsHSaiTOHLUowuxTMv11EgOkSvDTUE7FIcx9j4jzhQ0)eZsHSaiTOHL(SOGLESeGqni0uAdE9ZGDOs)tmlfYcGKLUow6Xsac1GqtPLkJGMOPQctq7qL(NywkKfajlkyXmwuxTMfOpbhcSsLrqt0us5vPKguFSi7kIffSeGiO0ZZcu859KL(S0NffS44BCDncAIgwkujwkyXgBQRwRMEjzSHpF0Wb0ydKWH5JUhMgBi1ZaPzz78rdhqwm93ololjzILydJH5zrD1AS4jilingiXCZalpor3XIRcxhlhKfvILfManoJycOnmVXgLUQManITXMhUhMgB4Zh8AqrgBGeomF09W0yRaUkJyz78bVgueMft)TZIZsSHXW8SOUAnwuxhlj8yX0oLSebH6prXsdoSG0yGeZndSahwqo9j4qGSSf9ZFyJTW8hnVBS1Jf1vRzvDTNbQcBvxRR3(NOW10V1qw85bGyPqwailDDSOUAnRQR9mqvyR6AD92)efU6tWtYIppaelfYcazPplkyPhlbick98S5JA)QnNyPRJLaeQbHMsBWRFgSdv6FIzPqwaKS01XIzSGWN3v1KnawdWe8VhMSOGfZyjarqPNNfO4Z7jlDDS0JLaeQbHMslvgbnrtvfMG2Hk9pXSuilaswuWIzSOUAnlqFcoeyLkJGMOPKYRsjnO(yr2velkyjarqPNNfO4Z7jl9zPplkyPhlMXci8ST1eVcBvsVsYEFaOprXsxhlMXsac1GqtPn41pd2HCW4S01XIzSeGqni0uAdWebeiQE7ufh9ZFy7qoyCw6BCgXeqAyEJnkDvnbAeBJnpCpmn2WNp41GIm2ajCy(O7HPXwbCvgXY25dEnOimlQudoelifMiGargBH5pAE3yRhlbiudcnL2amrabIQ3ovXr)8h2ouP)jMfGXcAyrblMXc4SEqBcRbqmlkyPhli85DvnzdWebeiQcs44zGLUowcqOgeAkTbV(zWouP)jMfGXcAyPplkybHpVRQjBaSgGj4FpmzPplkyXmwaHNTTM4vyRs6vs27da9jkwuWsaIGsppB(O2VAZjwuWIzSaoRh0MWAaeZIcwOG(JWK9ZQNXzrblo(gxxJGMOHLczXCk24mIjaYW8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJTESOUAn74iOeUW12qzSIBhQ0)eZsHSGgw66yXmwuxTMDCeucx4ABOmwXTRiw6ZIcw6XI6Q1Sa9j4qGvQmcAIMskVkL0G6JfzhQ0)eZcWybva0w6iJL(SOGLESOUAnlf0FeMQyO2h7qL(NywkKfubqBPJmw66yrD1AwkO)imv1R0h7qL(NywkKfubqBPJmw6BSbs4W8r3dtJTcimr3Xci8ybCnFIILBNyHsqwGnwaW4iOeUWSuagkJvC0Yc4A(efla9j4qGSqLrqt0us5XcCy5twUDIfTJpwqfazb2yXtwqVG(JWKXgcFQPxsgBGWRoeWD9dvs5HnoJycCmmVXgLUQManITXMhUhMgB4v2(Hm2cZF08UX2qTHW7UQMyrblNpOOZEFjvpyf8jwkKfLb0SOGfpQg2PaqSOGfe(8UQMSGWRoeWD9dvs5Hn2cXdAQE(GIoSrmv24mIPYfByEJnkDvnbAeBJnpCpmn2kHWS9dzSfM)O5DJTHAdH3DvnXIcwoFqrN9(sQEWk4tSuilkxqlAyrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetLv2W8gBu6QAc0i2gBE4EyASHpsR9P20(qgBH5pAE3yBO2q4DxvtSOGLZhu0zVVKQhSc(elfYIYaAwamldv6FIzrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetLbOH5n2O0v1eOrSn28W9W0yRbNavHTA63AiJnqchMp6EyASvaGXKfyYsaKft)Tdxhlbpk6tugBH5pAE3yZJQHDkaKXzetLlOH5n2O0v1eOrSn28W9W0yJkJGMOPQctqJnqchMp6EyASHELrqt0WsSHjilM2PKfxfUowoiluE0WIZssMyj2WyyEwm9ji0elEcYc2rqS0GdlingiXCZGXwy(JM3n26Xcf0FeMS6v6tnjKDS01Xcf0FeMSyO2NAsi7yPRJfkO)imz9mEnjKDS01XI6Q1SQU2ZavHTQR11B)tu4A63Ai7qL(NywkKfaPfnS01XI6Q1SQU2ZavHTQR11B)tu4Qpbpj7qL(NywkKfaPfnS01XIJVX11iOjAyPqwaofZIcwcqOgeAkTbV(zWoKdgNffSyglGZ6bTjSgaXS0NffS0JLaeQbHMsBWRFgSdv6FIzPqwkyXS01Xsac1GqtPn41pd2HCW4S0NLUowuHymlky5ZJMiO2pcS2Eu7xDOs)tmlaJfLl24mIPYMJH5n2O0v1eOrSn28W9W0yRTM4vyRs6vsgBGeomF09W0yRaarpwMh1(XIk1GdXYc)jkwqAmm2cZF08UXwac1GqtPn41pd2HCW4SOGfe(8UQMSbWAaMG)9WKffS0JfhFJRRrqt0WsHSaCkMffSyglbick98S5JA)QnNyPRJLaebLEE28rTF1MtSOGfhFJRRrqt0WcWyXCkML(SOGfZyjarqPNNfbL3E8HffS0JfZyjarqPNNnFu7xT5elDDSeGqni0uAdWebeiQE7ufh9ZFy7qoyCw6ZIcwmJfWz9G2ewdGyJZiMkJgdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2mJfWz9G2ewdGywuWccFExvt2aynatW)EyYIcw6XspwC8nUUgbnrdlfYcWPywuWspwuxTMfOpbhcSsLrqt0us5vPKguFSi7kILUowmJLaebLEEwGIpVNS0NLUowuxTMvvdHG6f(SRiwuWI6Q1SQAieuVWNDOs)tmlaJf1vRzdE9ZGfCn(9WKL(S01XYNhnrqTFeyT9O2V6qL(NywaglQRwZg86Nbl4A87HjlDDSeGiO0ZZMpQ9R2CIL(SOGLESyglbick98S5JA)QnNyPRJLES44BCDncAIgwaglMtXS01Xci8ST1eVcBvsVsYEFaOprXsFwuWspwq4Z7QAYgGjciqufKWXZalDDSeGqni0uAdWebeiQE7ufh9ZFy7qoyCw6ZsFJnqchMp6EyASH0yGeZndSyANsw8JfGtXaMLyGbGS0doAOjAy529KfZPywIbgaYIP)2zbPWebeiQplM(BhUow0q8NOy5(sILpzj2AieuVWhlEcYI(tILvelM(BNfKcteqGiw(gl)XIjhZciHJNbc0ydHp10ljJTaynatW)EywvH(zCgXuzaTH5n2O0v1eOrSn2cZF08UXgcFExvt2aynatW)EywvH(zS5H7HPXwG0e(ExxD9JklP8moJyQmG0W8gBu6QAc0i2gBH5pAE3ydHpVRQjBaSgGj4FpmRQq)m28W9W0y7ZGpPFpmnoJyQmaYW8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnkO)imz)SQxPpSa8SaGybjS4H7HPfF(0(HSeYOW6O69LelaMfZyHc6pct2pR6v6dlapl9ybqZcGz5CnLNfdx6kSvVDQ2GdHplLUQMazb4zPGS0NfKWIhUhMwtJF7wczuyDu9(sIfaZsXwaYcsybhrADD3XhzSbs4W8r3dtJn0dFFPFeMLDOjwkxHDwIbgaYIpelO8pjqwIOHfmfGjOXgcFQPxsgBoocasZgfmoJyQmWXW8gBu6QAc0i2gBE4EyASHpFWRbfzSbs4W8r3dtJTc4QmILTZh8AqrywmTtjl3oXs7rTFS8ywCv46y5GSqjiAzPnugR4S8ywCv46y5GSqjiAzjoCXIpel(XcWPyaZsmWaqw(Kfpzb9c6pctOLfKgdKyUzGfTJpmlEcVDAybabymfWSahwIdxSycU0GSarqtWJyPeoel3UNSWDkxmlXadazX0oLSehUyXeCPbt0DSSD(GxdkILeAYylm)rZ7gB9yrfIXSOGLppAIGA)iWA7rTF1Hk9pXSamwmhw66yPhlQRwZoockHlCTnugR42Hk9pXSamwqfaTLoYyb4zjqVMLES44BCDncAIgwqclfSyw6ZIcwuxTMDCeucx4ABOmwXTRiw6ZsFw66yPhlo(gxxJGMOHfaZccFExvtwhhbaPzJcSa8SOUAnlf0FeMQyO2h7qL(NywamlGWZ2wt8kSvj9kj79bGW1Hk9pzb4zbGw0WsHSOSYfZsxhlo(gxxJGMOHfaZccFExvtwhhbaPzJcSa8SOUAnlf0FeMQ6v6JDOs)tmlaMfq4zBRjEf2QKELK9(aq46qL(NSa8SaqlAyPqwuw5IzPplkyHc6pct2pREgNffS0JfZyrD1A2Gx)myxrS01XIzSCUMYZIpF0Wb0sPRQjqw6ZIcw6XspwmJLaeQbHMsBWRFgSRiw66yjarqPNNfO4Z7jlkyXmwcqOgeAkTuze0envvycAxrS0NLUowcqeu65zZh1(vBoXsFwuWspwmJLaebLEEweuE7Xhw66yXmwuxTMn41pd2velDDS44BCDncAIgwkKfGtXS0NLUow6XY5Akpl(8rdhqlLUQMazrblQRwZg86Nb7kIffS0Jf1vRzXNpA4aAXNhaIfGXsbzPRJfhFJRRrqt0WsHSaCkML(S0NLUowuxTMn41pd2velkyXmwuxTMDCeucx4ABOmwXTRiwuWIzSCUMYZIpF0Wb0sPRQjqJZiMaSydZBSrPRQjqJyBS5H7HPXwsMQLqyASbs4W8r3dtJTcetSaGfctmlFYc6VsFyb9c6pctS4jilyhbXcYzCDdWfGLwZcawimzPbhwqAmqI5MbJTW8hnVBS1Jf1vRzPG(JWuvVsFSdv6FIzPqwiKrH1r17ljw66yPhlHDFqrywuIfaYIcwgkS7dkQEFjXcWybnS0NLUowc7(GIWSOelfKL(SOGfpQg2PaqgNrmbOYgM3yJsxvtGgX2ylm)rZ7gB9yrD1AwkO)imv1R0h7qL(NywkKfczuyDu9(sIffS0JLaeQbHMsBWRFgSdv6FIzPqwqtXS01Xsac1GqtPnateqGO6TtvC0p)HTdv6FIzPqwqtXS0NLUow6Xsy3hueMfLybGSOGLHc7(GIQ3xsSamwqdl9zPRJLWUpOimlkXsbzPplkyXJQHDkaKXMhUhMgB7UUvlHW04mIjabOH5n2O0v1eOrSn2cZF08UXwpwuxTMLc6pctv9k9XouP)jMLczHqgfwhvVVKyrbl9yjaHAqOP0g86Nb7qL(NywkKf0umlDDSeGqni0uAdWebeiQE7ufh9ZFy7qL(NywkKf0uml9zPRJLESe29bfHzrjwailkyzOWUpOO69LelaJf0WsFw66yjS7dkcZIsSuqw6ZIcw8OAyNcazS5H7HPXwBP11simnoJycWcAyEJnkDvnbAeBJnqchMp6EyASHCarpwGjlbqJnpCpmn2m5Z8WPcBvsVsY4mIjanhdZBSrPRQjqJyBS5H7HPXg(8P9dzSbs4W8r3dtJTcetSSD(0(Hy5GSenWalBqTpSGEb9hHjwGdlM2PKLpzbM64SG(R0hwqVG(JWelEcYYctSGCarpwIgyaZY3y5twq)v6dlOxq)ryYylm)rZ7gBuq)ryY(zvVsFyPRJfkO)imzXqTp1Kq2Xsxhluq)ryY6z8Asi7yPRJf1vRzn5Z8WPcBvsVsYUIyrblQRwZsb9hHPQEL(yxrS01XspwuxTMn41pd2Hk9pXSamw8W9W0AA8B3siJcRJQ3xsSOGf1vRzdE9ZGDfXsFJZiMaengM3yZd3dtJntJF7gBu6QAc0i2gNrmbiG2W8gBu6QAc0i2gBE4EyASnRS6H7Hzv)4Zyt)4RMEjzS1CT(2NLXzCgBoKmmVrmv2W8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJTESOUAn79LKj4KvWH8s1pbPXouP)jMfGXcQaOT0rglaMLITkZsxhlQRwZEFjzcozfCiVu9tqASdv6FIzbyS4H7HPfF(0(HSeYOW6O69LelaMLITkZIcw6Xcf0FeMSFw1R0hw66yHc6pctwmu7tnjKDS01Xcf0FeMSEgVMeYow6ZsFwuWI6Q1S3xsMGtwbhYlv)eKg7kIffSmRKAWbfzVVKmbNScoKxQ(jinwkDvnbASbs4W8r3dtJnK66Ws7hHzX0oD70WYTtSuahYld(f2PHf1vRXIPxRzP5AnlWwJft)T)jl3oXssi7yj44ZydHp10ljJnWH8YQPxRRnxRRWwZ4mIjanmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYyZmwOG(JWK9ZkgQ9HffS0JfCeP11Zhu0HT4ZN2pelfYcAyrblNRP8Sy4sxHT6Tt1gCi8zP0v1eilDDSGJiTUE(GIoSfF(0(HyPqwaKS03ydKWH5JUhMgBi11HL2pcZIPD62PHLTZh8AqrS8ywmbNBNLGJVprXcebnSSD(0(Hy5twq)v6dlOxq)ryYydHp10ljJThvchQIpFWRbfzCgXSGgM3yJsxvtGgX2yZd3dtJTamrabIQ3ovXr)8h2ydKWH5JUhMgBfiMybPWebeiIft7uYIFSOjmMLB3twqtXSedmaKfpbzr)jXYkIft)TZcsJbsm3mySfM)O5DJnZybCwpOnH1aiMffS0JLESGWN3v1KnateqGOkiHJNbwuWIzSeGqni0uAdE9ZGDihmolDDSOUAnBWRFgSRiw6ZIcw6XI6Q1Suq)ryQQxPp2Hk9pXSuilaAw66yrD1AwkO)imvXqTp2Hk9pXSuilaAw6ZIcw6XIzSmRKAWbfzvDTNbQcBvxRR3(NOWwkDvnbYsxhlQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaXsHSuqw66yrD1Awvx7zGQWw1166T)jkC1NGNKfFEaiwkKLcYsFw66yrfIXSOGL2JA)Qdv6FIzbySOCXSOGfZyjaHAqOP0g86Nb7qoyCw6BCgX0CmmVXgLUQManITXMhUhMgBJJGs4cxBdLXkUXgiHdZhDpmn2kqmXsbyOmwXzX0F7SG0yGeZndgBH5pAE3ytD1A2Gx)myhQ0)eZsHSOmAmoJyIgdZBSrPRQjqJyBS5H7HPXgELTFiJTq8GMQNpOOdBetLn2cZF08UXwpwgQneE3v1elDDSOUAnlf0FeMQyO2h7qL(NywaglfKffSqb9hHj7Nvmu7dlkyzOs)tmlaJfLnhwuWY5AkplgU0vyRE7uTbhcFwkDvnbYsFwuWY5dk6S3xs1dwbFILczrzZHfabl4isRRNpOOdZcGzzOs)tmlkyPhluq)ryY(z1Z4S01XYqL(NywaglOcG2shzS03ydKWH5JUhMgBfiMyzBLTFiw(KLipbPYpWcmzXZ43(NOy529Jf9JGWSOS5GPaMfpbzrtymlM(BNLs4qSC(GIomlEcYIFSC7elucYcSXIZYgu7dlOxq)ryIf)yrzZHfmfWSahw0egZYqL(NFIIfhZYbzjHhl7oIprXYbzzO2q4DwaxZNOyb9xPpSGEb9hHjJZiMaAdZBSrPRQjqJyBS5H7HPXg(8P5ATXgiHdZhDpmn2qoruelRiw2oFAUwZIFS4Anl3xsywwPMWyww4prXc6hp4JJzXtqw(JLhZIRcxhlhKLObgyboSOPJLBNybhrH31S4H7Hjl6pjwujn0el7EcQjwkGd5LQFcsdlWKfaYY5dk6WgBH5pAE3yZmwoxt5zXhP1(ubNVDwkDvnbYIcw6XI6Q1S4ZNMR12HAdH3DvnXIcw6XcoI0665dk6Ww85tZ1AwaglfKLUowmJLzLudoOi79LKj4KvWH8s1pbPXsPRQjqw6ZsxhlNRP8Sy4sxHT6Tt1gCi8zP0v1eilkyrD1AwkO)imvXqTp2Hk9pXSamwkilkyHc6pct2pRyO2hwuWI6Q1S4ZNMR12Hk9pXSamwaKSOGfCeP11Zhu0HT4ZNMR1SuOsSyoS0NffS0JfZyzwj1GdkYQJh8XX1MMO7tuvu6VmctwkDvnbYsxhl3xsSGCzXCqdlfYI6Q1S4ZNMR12Hk9pXSaywail9zrblNpOOZEFjvpyf8jwkKf0yCgXeqAyEJnkDvnbAeBJnpCpmn2WNpnxRn2ajCy(O7HPXgYXF7SSDKw7dlfW5BhllmXcmzjaYIPDkzzO2q4DxvtSOUowW3R1SyY)JLgCyb9Jh8XXSenWalEcYcimr3XYctSOsn4qSG0ci2YY29AnllmXIk1GdXcsHjciqel4pdel3UFSy61AwIgyGfpH3onSSD(0CT2ylm)rZ7gBNRP8S4J0AFQGZ3olLUQMazrblQRwZIpFAUwBhQneE3v1elkyPhlMXYSsQbhuKvhp4JJRnnr3NOQO0FzeMSu6QAcKLUowUVKyb5YI5GgwkKfZHL(SOGLZhu0zVVKQhSc(elfYsbnoJycGmmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yd54VDwkGd5LQFcsdllmXY25tZ1AwoilaruelRiwUDIf1vRXIACwCngYYc)jkw2oFAUwZcmzbnSGPambXSahw0egZYqL(NFIYylm)rZ7gBZkPgCqr27ljtWjRGd5LQFcsJLsxvtGSOGfCeP11Zhu0HT4ZNMR1SuOsSuqwuWspwmJf1vRzVVKmbNScoKxQ(jin2velkyrD1Aw85tZ1A7qTHW7UQMyPRJLESGWN3v1KfCiVSA616AZ16kS1yrbl9yrD1Aw85tZ1A7qL(NywaglfKLUowWrKwxpFqrh2IpFAUwZsHSaqwuWY5Akpl(iT2Nk48TZsPRQjqwuWI6Q1S4ZNMR12Hk9pXSamwqdl9zPpl9noJycCmmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYyZX346Ae0enSuilaOIzbqWspwuUywaEwuxTM9(sYeCYk4qEP6NG0yXNhaIL(SaiyPhlQRwZIpFAUwBhQ0)eZcWZsbzbjSGJiTUU74Jyb4zXmwoxt5zXhP1(ubNVDwkDvnbYsFwaeS0JLaeQbHMsl(8P5ATDOs)tmlaplfKfKWcoI066UJpIfGNLZ1uEw8rATpvW5BNLsxvtGS0Nfabl9ybeE22AIxHTkPxjzhQ0)eZcWZcAyPplkyPhlQRwZIpFAUwBxrS01Xsac1GqtPfF(0CT2ouP)jML(gBGeomF09W0ydPUoS0(rywmTt3onS4SSD(GxdkILfMyX0R1Se8fMyz78P5AnlhKLMR1SaBn0YINGSSWelBNp41GIy5GSaerrSuahYlv)eKgwWNhaILvKXgcFQPxsgB4ZNMR1vtW8QnxRRWwZ4mIPYfByEJnkDvnbAeBJnpCpmn2WNp41GIm2ajCy(O7HPXwbIjw2oFWRbfXIP)2zPaoKxQ(jinSCqwaIOiwwrSC7elQRwJft)TdxhlAi(tuSSD(0CTMLv09LelEcYYctSSD(GxdkIfyYI5aywInmgMNf85bGWSSY71SyoSC(GIoSXwy(JM3n2q4Z7QAYcoKxwn9ADT5ADf2ASOGfe(8UQMS4ZNMR1vtW8QnxRRWwJffSygli85DvnzFujCOk(8bVguelDDS0Jf1vRzvDTNbQcBvxRR3(NOW10V1qw85bGyPqwkilDDSOUAnRQR9mqvyR6AD92)efU6tWtYIppaelfYsbzPplkybhrAD98bfDyl(8P5AnlaJfZHffSGWN3v1KfF(0CTUAcMxT5ADf2AgNrmvwzdZBSrPRQjqJyBS5H7HPXMd6r3JGQyt(uASfIh0u98bfDyJyQSXwy(JM3n2mJL7da9jkwuWIzS4H7HP1b9O7rqvSjFkRGEPJISFwB6h1(XsxhlGWZ6GE09iOk2KpLvqV0rrw85bGybySuqwuWci8SoOhDpcQIn5tzf0lDuKDOs)tmlaJLcASbs4W8r3dtJTcetSGn5tjlyil3UFSehUybfDSu6iJLv09LelQXzzH)efl)XIJzr7hXIJzjcIXVQMybMSOjmMLB3twkil4ZdaHzboSaGZcFSyANswkiGzbFEaimleYI(HmoJyQmanmVXgLUQManITXMhUhMgBLqy2(Hm2cXdAQE(GIoSrmv2ylm)rZ7gBd1gcV7QAIffSC(GIo79Lu9GvWNyPqw6Xspwu2CybWS0JfCeP11Zhu0HT4ZN2pelaplaKfGNf1vRzPG(JWuvVsFSRiw6ZsFwamldv6FIzPpliHLESOmlaMLZ1uE2Z0N1simXwkDvnbYsFwuWspwcqOgeAkTbV(zWoKdgNffSyglGZ6bTjSgaXSOGLESGWN3v1KnateqGOkiHJNbw66yjaHAqOP0gGjciqu92Pko6N)W2HCW4S01XIzSeGiO0ZZMpQ9R2CIL(S01XcoI0665dk6Ww85t7hIfGXspw6XcGMfabl9yrD1AwkO)imv1R0h7kIfGNfaYsFw6ZcWZspwuMfaZY5Akp7z6ZAjeMylLUQMazPpl9zrblMXcf0FeMSyO2NAsi7yPRJLESqb9hHj7Nvmu7dlDDS0JfkO)imz)SQcVDw66yHc6pct2pR6v6dl9zrblMXY5AkplgU0vyRE7uTbhcFwkDvnbYsxhlQRwZgnFjCaFxx9j45hQrln2hlcxViwkujwaiAkML(SOGLESGJiTUE(GIoSfF(0(HybySOCXSa8S0JfLzbWSCUMYZEM(SwcHj2sPRQjqw6ZsFwuWIJVX11iOjAyPqwqtXSaiyrD1Aw85tZ1A7qL(NywaEwa0S0NffS0JfZyrD1AwG(eCiWkvgbnrtjLxLsAq9XISRiw66yHc6pct2pRyO2hw66yXmwcqeu65zbk(8EYsFwuWIzSOUAn74iOeUW12qzSIxXF2w66EC8rZ72vKXgiHdZhDpmn2aWqTHW7SaGfcZ2pelFJfKgdKyUzGLhZYqoyC0YYTtdXIpelAcJz529Kf0WY5dk6WS8jlO)k9Hf0lO)imXIP)2zzdEfa0YIMWywUDpzr5IzbE70y6XelFYINXzb9c6pctSahwwrSCqwqdlNpOOdZIk1GdXIZc6VsFyb9c6pctwwkGWeDhld1gcVZc4A(efliN(eCiqwqVYiOjAkP8yzLAcJz5tw2GAFyb9c6pctgNrmvUGgM3yJsxvtGgX2yZd3dtJTgCcuf2QPFRHm2ajCy(O7HPXwbIjwkaWyYcmzjaYIP)2HRJLGhf9jkJTW8hnVBS5r1WofaY4mIPYMJH5n2O0v1eOrSn2GrgBy6m28W9W0ydHpVRQjJneUErgBMXc4SEqBcRbqmlkybHpVRQjBaSgGj4Fpmzrbl9yPhlQRwZIpFAUwBxrS01Xspwoxt5zXhP1(ubNVDwkDvnbYsxhlbick98S5JA)QnNyPpl9zrbl9yXmwuxTMfd147dKDfXIcwmJf1vRzdE9ZGDfXIcw6XIzSCUMYZ2wt8kSvj9kjlLUQMazPRJf1vRzdE9ZGfCn(9WKLczjaHAqOP02wt8kSvj9kj7qL(Nywamlaiw6ZIcwq4Z7QAYE7ZR1vmrart1K)hlkyPhlMXsaIGsppB(O2VAZjw66yjaHAqOP0gGjciqu92Pko6N)W2velkyPhlQRwZIpFAUwBhQ0)eZcWybGS01XIzSCUMYZIpsR9PcoF7Su6QAcKL(S0NffSC(GIo79Lu9GvWNyPqwuxTMn41pdwW143dtwaEwk2cizPplDDSOcXywuWs7rTF1Hk9pXSamwuxTMn41pdwW143dtw6BSHWNA6LKXwaSgGj4FpmRoKmoJyQmAmmVXgLUQManITXMhUhMgBbst47DD11pQSKYZydKWH5JUhMgBfiMybPXajMBgybMSeazzLAcJzXtqw0FsS8hlRiwm93olifMiGargBH5pAE3ydHpVRQjBaSgGj4FpmRoKmoJyQmG2W8gBu6QAc0i2gBH5pAE3ydHpVRQjBaSgGj4FpmRoKm28W9W0y7ZGpPFpmnoJyQmG0W8gBu6QAc0i2gBE4EyASrLrqt0uvHjOXgiHdZhDpmn2kqmXc6vgbnrdlXgMGSatwcGSy6VDw2oFAUwZYkIfpbzb7iiwAWHfa4sJ9HfpbzbPXajMBgm2cZF08UXMkeJzrblFE0eb1(rG12JA)Qdv6FIzbySOmAyPRJLESOUAnB08LWb8DD1NGNFOgT0yFSiC9IybySaq0umlDDSOUAnB08LWb8DD1NGNFOgT0yFSiC9IyPqLybGOPyw6ZIcwuxTMfF(0CT2UIyrbl9yjaHAqOP0g86Nb7qL(NywkKf0umlDDSaoRh0MWAaeZsFJZiMkdGmmVXgLUQManITXMhUhMgB4J0AFQnTpKXwiEqt1Zhu0HnIPYgBH5pAE3yBO2q4DxvtSOGL7lP6bRGpXsHSOmAyrbl4isRRNpOOdBXNpTFiwaglMdlkyXJQHDkaelkyPhlQRwZg86Nb7qL(NywkKfLlMLUowmJf1vRzdE9ZGDfXsFJnqchMp6EyASbGHAdH3zPP9HybMSSIy5GSuqwoFqrhMft)TdxhlingiXCZalQ0NOyXvHRJLdYcHSOFiw8eKLeESarqtWJI(eLXzetLbogM3yJsxvtGgX2yZd3dtJT2AIxHTkPxjzSbs4W8r3dtJTcetSuaGOhlFJLpXpiXINSGEb9hHjw8eKf9Nel)XYkIft)TZIZcaCPX(Ws0adS4jilXa0JUhbXYMjFkn2cZF08UXgf0FeMSFw9molkyXJQHDkaelkyrD1A2O5lHd476Qpbp)qnAPX(yr46fXcWybGOPywuWspwaHN1b9O7rqvSjFkRGEPJIS3ha6tuS01XIzSeGiO0ZZMuyGA4aYsxhl4isRRNpOOdZsHSaqw6ZIcw6XI6Q1SJJGs4cxBdLXkUDOs)tmlaJfGdlacw6XcAyb4zzwj1GdkYI)ST01944JM3Tu6QAcKL(SOGf1vRzhhbLWfU2gkJvC7kILUowmJf1vRzhhbLWfU2gkJvC7kIL(SOGLESyglbiudcnL2Gx)myxrS01XI6Q1S3(8ADfteq0yXNhaIfGXIYOHffS0Eu7xDOs)tmlaJfawCXSOGL2JA)Qdv6FIzPqwuU4IzPRJfZybdxA1pbTn)CDTPDtwkDvnbYsFJZiMaSydZBSrPRQjqJyBS5H7HPXg(8P5ATXgiHdZhDpmn2kqmXIZY25tZ1AwaWN0TZs0adSSsnHXSSD(0CTMLhZIRhYbJZYkIf4WsC4IfFiwCv46y5GSarqtWJyjgyaOXwy(JM3n2uxTMfM0TJRr0eOO7HPDfXIcw6XI6Q1S4ZNMR12HAdH3DvnXsxhlo(gxxJGMOHLczb4uml9noJycqLnmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yRaUkJyjgyailQudoelifMiGarSy6VDw2oFAUwZINGSC7uYY25dEnOiJTW8hnVBSfGiO0ZZMpQ9R2CIffSyglNRP8S4J0AFQGZ3olLUQMazrbl9ybHpVRQjBaMiGarvqchpdS01Xsac1GqtPn41pd2velDDSOUAnBWRFgSRiw6ZIcwcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlaJfubqBPJmwaEwc0RzPhlo(gxxJGMOHfKWcAkML(SOGf1vRzXNpnxRTdv6FIzbySyoSOGfZybCwpOnH1ai24mIjabOH5n2O0v1eOrSn2cZF08UXwaIGsppB(O2VAZjwuWspwq4Z7QAYgGjciqufKWXZalDDSeGqni0uAdE9ZGDfXsxhlQRwZg86Nb7kIL(SOGLaeQbHMsBaMiGar1BNQ4OF(dBhQ0)eZcWybqZIcwuxTMfF(0CT2UIyrbluq)ryY(z1Z4SOGfZybHpVRQj7JkHdvXNp41GIyrblMXc4SEqBcRbqSXMhUhMgB4Zh8AqrgNrmbybnmVXgLUQManITXMhUhMgB4Zh8AqrgBGeomF09W0yRaXelBNp41GIyX0F7S4jla4t62zjAGbwGdlFJL4Wf6azbIGMGhXsmWaqwm93olXHRHLKq2XsWXNLLyOXqwaxLrSedmaKf)y52jwOeKfyJLBNybaxkV94dlQRwJLVXY25tZ1AwmbxAWeDhlnxRzb2ASahwIdxS4dXcmzbGSC(GIoSXwy(JM3n2uxTMfM0TJRbn5tfXJFyAxrS01XspwmJf85t7hY6r1WofaIffSygli85DvnzFujCOk(8bVguelDDS0Jf1vRzdE9ZGDOs)tmlaJf0WIcwuxTMn41pd2velDDS0JLESOUAnBWRFgSdv6FIzbySGkaAlDKXcWZsGEnl9yXX346Ae0enSGewkyXS0NffSOUAnBWRFgSRiw66yrD1A2XrqjCHRTHYyfVI)ST01944JM3Tdv6FIzbySGkaAlDKXcWZsGEnl9yXX346Ae0enSGewkyXS0NffSOUAn74iOeUW12qzSIxXF2w66EC8rZ72vel9zrblbick98SiO82JpS0NL(SOGLESGJiTUE(GIoSfF(0CTMfGXsbzPRJfe(8UQMS4ZNMR1vtW8QnxRRWwJL(S0NffSygli85DvnzFujCOk(8bVguelkyPhlMXYSsQbhuK9(sYeCYk4qEP6NG0yP0v1eilDDSGJiTUE(GIoSfF(0CTMfGXsbzPVXzetaAogM3yJsxvtGgX2yZd3dtJTKmvlHW0ydKWH5JUhMgBfiMybaleMyw(KLnO2hwqVG(JWelEcYc2rqSuawAnlayHWKLgCybPXajMBgm2cZF08UXwpwuxTMLc6pctvmu7JDOs)tmlfYcHmkSoQEFjXsxhl9yjS7dkcZIsSaqwuWYqHDFqr17ljwaglOHL(S01Xsy3hueMfLyPGS0NffS4r1WofaY4mIjarJH5n2O0v1eOrSn2cZF08UXwpwuxTMLc6pctvmu7JDOs)tmlfYcHmkSoQEFjXsxhl9yjS7dkcZIsSaqwuWYqHDFqr17ljwaglOHL(S01Xsy3hueMfLyPGS0NffS4r1WofaIffS0Jf1vRzhhbLWfU2gkJvC7qL(NywaglOHffSOUAn74iOeUW12qzSIBxrSOGfZyzwj1GdkYI)ST01944JM3Tu6QAcKLUowmJf1vRzhhbLWfU2gkJvC7kIL(gBE4EyAST76wTectJZiMaeqByEJnkDvnbAeBJTW8hnVBS1Jf1vRzPG(JWufd1(yhQ0)eZsHSqiJcRJQ3xsSOGLESeGqni0uAdE9ZGDOs)tmlfYcAkMLUowcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlfYcAkML(S01Xspwc7(GIWSOelaKffSmuy3huu9(sIfGXcAyPplDDSe29bfHzrjwkil9zrblEunStbGyrbl9yrD1A2XrqjCHRTHYyf3ouP)jMfGXcAyrblQRwZoockHlCTnugR42velkyXmwMvsn4GIS4pBlDDpo(O5DlLUQMazPRJfZyrD1A2XrqjCHRTHYyf3UIyPVXMhUhMgBTLwxlHW04mIjabKgM3yJsxvtGgX2ydKWH5JUhMgBfiMyb5aIESatwqAb0yZd3dtJnt(mpCQWwL0RKmoJycqaKH5n2O0v1eOrSn2GrgBy6m28W9W0ydHpVRQjJneUErgB4isRRNpOOdBXNpTFiwkKfZHfaZstdHdl9yP0XhnXRiC9Iyb4zr5IlMfKWcalML(SaywAAiCyPhlQRwZIpFWRbfvPYiOjAkP8QyO2hl(8aqSGewmhw6BSbs4W8r3dtJnK66Ws7hHzX0oD70WYbzzHjw2oFA)qS8jlBqTpSyA)d7S8yw8Jf0WY5dk6WawzwAWHfcbnXzbGfJCzP0XhnXzboSyoSSD(GxdkIf0RmcAIMskpwWNhacBSHWNA6LKXg(8P9dv)SIHAFmoJycqGJH5n2O0v1eOrSn2GrgBy6m28W9W0ydHpVRQjJneUErgBkZcsybhrADD3XhXcWybGw0WcGGLESuSfGSa8SGJiTUE(GIoSfF(0(Hyb4zPhlkZcGz5CnLNfdx6kSvVDQ2GdHplLUQMazb4zrzlAyPpl9zbWSuSvz0WcWZI6Q1SJJGs4cxBdLXkUDOs)tSXgiHdZhDpmn2qQRdlTFeMft70TtdlhKfKJXVDwaxZNOyPamugR4gBi8PMEjzSzA8BV(zTnugR4gNrmlyXgM3yJsxvtGgX2yZd3dtJntJF7gBGeomF09W0yRaXelihJF7S8jlBqTpSGEb9hHjwGdlFJLeYY25t7hIftVwZs7pw(8GSG0yGeZndS4z8s4qgBH5pAE3yRhluq)ryYQxPp1Kq2Xsxhluq)ryY6z8Asi7yrbli85DvnzFCnOjhbXsFwuWspwoFqrN9(sQEWk4tSuilMdlDDSqb9hHjREL(u)Scqw66yP9O2V6qL(Nywaglkxml9zPRJf1vRzPG(JWufd1(yhQ0)eZcWyXd3dtl(8P9dzjKrH1r17ljwuWI6Q1Suq)ryQIHAFSRiw66yHc6pct2pRyO2hwuWIzSGWN3v1KfF(0(HQFwXqTpS01XI6Q1SbV(zWouP)jMfGXIhUhMw85t7hYsiJcRJQ3xsSOGfZybHpVRQj7JRbn5iiwuWI6Q1SbV(zWouP)jMfGXcHmkSoQEFjXIcwuxTMn41pd2velDDSOUAn74iOeUW12qzSIBxrSOGfe(8UQMSMg)2RFwBdLXkolDDSygli85DvnzFCnOjhbXIcwuxTMn41pd2Hk9pXSuileYOW6O69LKXzeZcQSH5n2O0v1eOrSn2ajCy(O7HPXwbIjw2oFA)qS8nw(Kf0FL(Wc6f0FeMqllFYYgu7dlOxq)ryIfyYI5aywoFqrhMf4WYbzjAGbw2GAFyb9c6pctgBE4EyASHpFA)qgNrmlianmVXgLUQManITXgiHdZhDpmn2kaUwF7ZYyZd3dtJTzLvpCpmR6hFgB6hF10ljJTMR13(SmoJZyR5A9TpldZBetLnmVXgLUQManITXMhUhMgB4Zh8AqrgBGeomF09W0yB78bVgueln4Wsjebvs5XYk1egZYc)jkwInmgM3ylm)rZ7gBMXYSsQbhuKv11EgOkSvDTUE7FIcBjG76JIiqJZiMa0W8gBu6QAc0i2gBE4EyASHxz7hYylepOP65dk6WgXuzJTW8hnVBSbcpBjeMTFi7qL(NywkKLHk9pXSa8SaqaYcsyrzaKXgiHdZhDpmn2qQJpwUDIfq4XIP)2z52jwkH4JL7ljwoiloiilR8Enl3oXsPJmwaxJFpmz5XSS)NLLTv2(HyzOs)tmlLl99r6Naz5GSu6xyNLsimB)qSaUg)EyACgXSGgM3yZd3dtJTsimB)qgBu6QAc0i2gNXzSHpdZBetLnmVXgLUQManITXMhUhMgB4Zh8AqrgBGeomF09W0yRaXelBNp41GIy5GSaerrSSIy52jwkGd5LQFcsdlQRwJLVXYFSycU0GSqil6hIfvQbhIL2NpE)tuSC7eljHSJLGJpwGdlhKfWvzelQudoelifMiGargBH5pAE3yBwj1GdkYEFjzcozfCiVu9tqASu6QAcKffS0JfkO)imz)S6zCwuWIzS0JLESOUAn79LKj4KvWH8s1pbPXouP)jMLczXd3dtRPXVDlHmkSoQEFjXcGzPyRYSOGLESqb9hHj7Nvv4TZsxhluq)ryY(zfd1(Wsxhluq)ryYQxPp1Kq2XsFw66yrD1A27ljtWjRGd5LQFcsJDOs)tmlfYIhUhMw85t7hYsiJcRJQ3xsSaywk2QmlkyPhluq)ryY(zvVsFyPRJfkO)imzXqTp1Kq2Xsxhluq)ryY6z8Asi7yPpl9zPRJfZyrD1A27ljtWjRGd5LQFcsJDfXsFw66yPhlQRwZg86Nb7kILUowq4Z7QAYgGjciqufKWXZal9zrblbiudcnL2amrabIQ3ovXr)8h2oKdgNffSeGiO0ZZMpQ9R2CIL(SOGLESyglbick98SafFEpzPRJLaeQbHMslvgbnrtvfMG2Hk9pXSuilaiw6ZIcw6XI6Q1SbV(zWUIyPRJfZyjaHAqOP0g86Nb7qoyCw6BCgXeGgM3yJsxvtGgX2yZd3dtJnh0JUhbvXM8P0ylepOP65dk6WgXuzJTW8hnVBSzglGWZ6GE09iOk2KpLvqV0rr27da9jkwuWIzS4H7HP1b9O7rqvSjFkRGEPJISFwB6h1(XIcw6XIzSacpRd6r3JGQyt(uw3jxBVpa0NOyPRJfq4zDqp6EeufBYNY6o5A7qL(NywkKf0WsFw66ybeEwh0JUhbvXM8PSc6LokYIppaelaJLcYIcwaHN1b9O7rqvSjFkRGEPJISdv6FIzbySuqwuWci8SoOhDpcQIn5tzf0lDuK9(aqFIYydKWH5JUhMgBfiMyjgGE09iiw2m5tjlM2PKLBNgILhZsczXd3JGybBYNs0YIJzr7hXIJzjcIXVQMybMSGn5tjlM(BNfaYcCyPrMOHf85bGWSahwGjlolfeWSGn5tjlyil3UFSC7eljzIfSjFkzXN5rqywaWzHpw82rdl3UFSGn5tjleYI(HWgNrmlOH5n2O0v1eOrSn28W9W0ylateqGO6TtvC0p)Hn2ajCy(O7HPXwbIjmlifMiGarS8nwqAmqI5MbwEmlRiwGdlXHlw8HybKWXZWNOybPXajMBgyX0F7SGuyIaceXINGSehUyXhIfvsdnXI5umlXadan2cZF08UXMzSaoRh0MWAaeZIcw6Xspwq4Z7QAYgGjciqufKWXZalkyXmwcqOgeAkTbV(zWoKdgNffSyglZkPgCqr2O5lHd476Qpbp)qnAPX(yP0v1eilDDSOUAnBWRFgSRiw6ZIcwC8nUUgbnrdlatjwmNIzrbl9yrD1AwkO)imv1R0h7qL(NywkKfLlMLUowuxTMLc6pctvmu7JDOs)tmlfYIYfZsFw66yrfIXSOGL2JA)Qdv6FIzbySOCXSOGfZyjaHAqOP0g86Nb7qoyCw6BCgX0CmmVXgLUQManITXgmYydtNXMhUhMgBi85DvnzSHW1lYyRhlQRwZoockHlCTnugR42Hk9pXSuilOHLUowmJf1vRzhhbLWfU2gkJvC7kIL(SOGfZyrD1A2XrqjCHRTHYyfVI)ST01944JM3TRiwuWspwuxTMfOpbhcSsLrqt0us5vPKguFSi7qL(NywaglOcG2shzS0NffS0Jf1vRzPG(JWufd1(yhQ0)eZsHSGkaAlDKXsxhlQRwZsb9hHPQEL(yhQ0)eZsHSGkaAlDKXsxhl9yXmwuxTMLc6pctv9k9XUIyPRJfZyrD1AwkO)imvXqTp2vel9zrblMXY5AkplgQX3hilLUQMazPVXgiHdZhDpmn2qkmb)7Hjln4WIR1Sacpml3UFSu6arywWRHy52P4S4dLO7yzO2q4DcKft7uYcaghbLWfMLcWqzSIZYUJzrtyml3UNSGgwWuaZYqL(NFIIf4WYTtSau859Kf1vRXYJzXvHRJLdYsZ1AwGTglWHfpJZc6f0FeMy5XS4QW1XYbzHqw0pKXgcFQPxsgBGWRoeWD9dvs5HnoJyIgdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im26XIzSOUAnlf0FeMQyO2h7kIffSyglQRwZsb9hHPQEL(yxrS0NLUowoxt5zXqn((azP0v1eOXgiHdZhDpmn2qkmb)7Hjl3UFSe2Paqyw(glXHlw8HybUo8dsSqb9hHjwoilWuhNfq4XYTtdXcCy5rLWHy52FmlM(BNLnOgFFGm2q4tn9sYydeEv46WpivPG(JWKXzetaTH5n2O0v1eOrSn28W9W0yRecZ2pKXwy(JM3n2gQneE3v1elkyPhlQRwZsb9hHPkgQ9XouP)jMLczzOs)tmlDDSOUAnlf0FeMQ6v6JDOs)tmlfYYqL(Nyw66ybHpVRQjli8QW1HFqQsb9hHjw6ZIcwgQneE3v1elky58bfD27lP6bRGpXsHSOmazrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetaPH5n2O0v1eOrSn28W9W0ydVY2pKXwy(JM3n2gQneE3v1elkyPhlQRwZsb9hHPkgQ9XouP)jMLczzOs)tmlDDSOUAnlf0FeMQ6v6JDOs)tmlfYYqL(Nyw66ybHpVRQjli8QW1HFqQsb9hHjw6ZIcwgQneE3v1elky58bfD27lP6bRGpXsHSOmazrblEunStbGyrbli85DvnzbHxDiG76hQKYdBSfIh0u98bfDyJyQSXzetaKH5n2O0v1eOrSn28W9W0ydFKw7tTP9Hm2cZF08UX2qTHW7UQMyrbl9yrD1AwkO)imvXqTp2Hk9pXSuildv6FIzPRJf1vRzPG(JWuvVsFSdv6FIzPqwgQ0)eZsxhli85DvnzbHxfUo8dsvkO)imXsFwuWYqTHW7UQMyrblNpOOZEFjvpyf8jwkKfLb0SOGfpQg2PaqSOGfe(8UQMSGWRoeWD9dvs5Hn2cXdAQE(GIoSrmv24mIjWXW8gBu6QAc0i2gBE4EyAS1GtGQWwn9BnKXgiHdZhDpmn2kqmXsbagtwGjlbqwm93oCDSe8OOprzSfM)O5DJnpQg2PaqgNrmvUydZBSrPRQjqJyBS5H7HPXgvgbnrtvfMGgBGeomF09W0yRaXeliN(eCiqw2I(5pmlM(BNfpJZIgMOyHs4c1olAhFFIIf0lO)imXINGSCtCwoil6pjw(JLvelM(BNfa4sJ9HfpbzbPXajMBgm2cZF08UXwpw6XI6Q1Suq)ryQIHAFSdv6FIzPqwuUyw66yrD1AwkO)imv1R0h7qL(NywkKfLlML(SOGLaeQbHMsBWRFgSdv6FIzPqwkyXSOGLESOUAnB08LWb8DD1NGNFOgT0yFSiC9IybySaqZPyw66yXmwMvsn4GISrZxchW31vFcE(HA0sJ9Xsa31hfrGS0NL(S01XI6Q1SrZxchW31vFcE(HA0sJ9XIW1lILcvIfacilMLUowcqOgeAkTbV(zWoKdgNffS44BCDncAIgwkKfGtXgNrmvwzdZBSrPRQjqJyBSbJm2W0zS5H7HPXgcFExvtgBiC9Im2mJfWz9G2ewdGywuWccFExvt2aynatW)EyYIcw6XspwcqOgeAkTuzu8HCDfoGPNbYouP)jMfGXIYaAajlaMLESOSYSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFwuWcbCxFuebAPYO4d56kCatpdel9zPRJfhFJRRrqt0WsHkXcWPywuWspwmJLZ1uE22AIxHTkPxjzP0v1eilDDSOUAnBWRFgSGRXVhMSuilbiudcnL22AIxHTkPxjzhQ0)eZcGzbaXsFwuWccFExvt2BFETUIjciAQM8)yrbl9yrD1AwG(eCiWkvgbnrtjLxLsAq9XISRiw66yXmwcqeu65zbk(8EYsFwuWY5dk6S3xs1dwbFILczrD1A2Gx)mybxJFpmzb4zPylGKLUowuHymlkyP9O2V6qL(NywaglQRwZg86Nbl4A87HjlDDSeGiO0ZZMpQ9R2CILUowuxTMvvdHG6f(SRiwuWI6Q1SQAieuVWNDOs)tmlaJf1vRzdE9ZGfCn(9WKfaZspwaoSa8SmRKAWbfzJMVeoGVRR(e88d1OLg7JLaURpkIazPpl9zrblMXI6Q1SbV(zWUIyrbl9yXmwcqeu65zZh1(vBoXsxhlbiudcnL2amrabIQ3ovXr)8h2UIyPRJfvigZIcwApQ9RouP)jMfGXsac1GqtPnateqGO6TtvC0p)HTdv6FIzbWSaOzPRJL2JA)Qdv6FIzb5YIYaOIzbySOUAnBWRFgSGRXVhMS03ydKWH5JUhMgBfiMybPXajMBgyX0F7SGuyIaceHeKtFcoeilBr)8hMfpbzbeMO7ybIGgtZFelaWLg7dlWHft7uYsS1qiOEHpwmbxAqwiKf9dXIk1GdXcsJbsm3mWcHSOFiSXgcFQPxsgBbWAaMG)9WSIpJZiMkdqdZBSrPRQjqJyBS5H7HPX24iOeUW12qzSIBSbs4W8r3dtJTcetSC7ela4s5ThFyX0F7S4SG0yGeZndSC7(XYJt0DS0gyjlaWLg7JXwy(JM3n2uxTMn41pd2Hk9pXSuilkJgw66yrD1A2Gx)mybxJFpmzbySuWIzrbli85DvnzdG1amb)7HzfFgNrmvUGgM3yJsxvtGgX2ylm)rZ7gBi85DvnzdG1amb)7HzfFSOGLESyglQRwZg86Nbl4A87HjlfYsblMLUowmJLaebLEEweuE7Xhw6ZsxhlQRwZoockHlCTnugR42velkyrD1A2XrqjCHRTHYyf3ouP)jMfGXcWHfaZsaMGR)SrdfEmvD9JklP8S3xsveUErSayw6XIzSOUAnRQgcb1l8zxrSOGfZy5CnLNfF(OHdOLsxvtGS03yZd3dtJTaPj89UU66hvws5zCgXuzZXW8gBu6QAc0i2gBH5pAE3ydHpVRQjBaSgGj4FpmR4ZyZd3dtJTpd(K(9W04mIPYOXW8gBu6QAc0i2gBWiJnmDgBE4EyASHWN3v1KXgcxViJnZyjaHAqOP0g86Nb7qoyCw66yXmwq4Z7QAYgGjciqufKWXZalkyjarqPNNnFu7xT5elDDSaoRh0MWAaeBSbs4W8r3dtJnaC95DvnXYctGSatwC1x)3tywUD)yXKNhlhKfvIfSJGazPbhwqAmqI5MbwWqwUD)y52P4S4dLhlMC8rGSaGZcFSOsn4qSC7uPXgcFQPxsgByhbvBWPg86NbJZiMkdOnmVXgLUQManITXMhUhMgBT1eVcBvsVsYydKWH5JUhMgBfiMWSuaGOhlFJLpzXtwqVG(JWelEcYYnpHz5GSO)Ky5pwwrSy6VDwaGln2h0YcsJbsm3mWINGSedqp6EeelBM8P0ylm)rZ7gBuq)ryY(z1Z4SOGfpQg2PaqSOGf1vRzJMVeoGVRR(e88d1OLg7JfHRxelaJfaAofZIcw6Xci8SoOhDpcQIn5tzf0lDuK9(aqFIILUowmJLaebLEE2Kcdudhqw6ZIcwq4Z7QAYIDeuTbNAWRFgyrbl9yrD1A2XrqjCHRTHYyf3ouP)jMfGXcWHfabl9ybnSa8SmRKAWbfzXF2w66EC8rZ7wkDvnbYsFwuWI6Q1SJJGs4cxBdLXkUDfXsxhlMXI6Q1SJJGs4cxBdLXkUDfXsFJZiMkdinmVXgLUQManITXMhUhMgB4ZNMR1gBGeomF09W0yRaXela4t62zz78P5AnlrdmGz5BSSD(0CTMLhNO7yzfzSfM)O5DJn1vRzHjD74Aenbk6EyAxrSOGf1vRzXNpnxRTd1gcV7QAY4mIPYaidZBSrPRQjqJyBSfM)O5DJn1vRzXNpA4aAhQ0)eZcWybnSOGLESOUAnlf0FeMQyO2h7qL(NywkKf0WsxhlQRwZsb9hHPQEL(yhQ0)eZsHSGgw6ZIcwC8nUUgbnrdlfYcWPyJnpCpmn2cEgiDvD1AgBQRwRMEjzSHpF0Wb04mIPYahdZBSrPRQjqJyBS5H7HPXg(8bVguKXgiHdZhDpmn2kGRYimlXadazrLAWHybPWebeiILf(tuSC7elifMiGarSeGj4Fpmz5GSe2PaqS8nwqkmrabIy5XS4HB5ADCwCv46y5GSOsSeC8zSfM)O5DJTaebLEE28rTF1MtSOGfe(8UQMSbyIacevbjC8mWIcwcqOgeAkTbyIacevVDQIJ(5pSDOs)tmlaJf0WIcwmJfWz9G2ewdGywuWcf0FeMSFw9molkyXX346Ae0enSuilMtXgNrmbyXgM3yJsxvtGgX2yZd3dtJn85tZ1AJnqchMp6EyASvGyILTZNMR1Sy6VDw2osR9HLc48TJfpbzjHSSD(OHdiAzX0oLSKqw2oFAUwZYJzzfHwwIdxS4dXYNSG(R0hwqVG(JWeln4WcacWykGzboSCqwIgyGfa4sJ9Hft7uYIRcrqSaCkMLyGbGSahwCWi)Eeelyt(uYYUJzbabymfWSmuP)5NOyboS8yw(KLM(rTFwwIj8iwUD)yzLG0WYTtSG9sILamb)7HjML)qhMfWimljTUX1SCqw2oFAUwZc4A(eflayCeucxywkadLXkoAzX0oLSehUqhil471AwOeKLvelM(BNfGtXa2XrS0Gdl3oXI2XhlO0qvxJTgBH5pAE3y7CnLNfFKw7tfC(2zP0v1eilkyXmwoxt5zXNpA4aAP0v1eilkyrD1Aw85tZ1A7qTHW7UQMyrbl9yrD1AwkO)imv1R0h7qL(NywkKfaelkyHc6pct2pR6v6dlkyrD1A2O5lHd476Qpbp)qnAPX(yr46fXcWybGOPyw66yrD1A2O5lHd476Qpbp)qnAPX(yr46fXsHkXcartXSOGfhFJRRrqt0WsHSaCkMLUowaHN1b9O7rqvSjFkRGEPJISdv6FIzPqwaqS01XIhUhMwh0JUhbvXM8PSc6LokY(zTPFu7hl9zrblbiudcnL2Gx)myhQ0)eZsHSOCXgNrmbOYgM3yJsxvtGgX2yZd3dtJn85dEnOiJnqchMp6EyASvGyILTZh8AqrSaGpPBNLObgWS4jilGRYiwIbgaYIPDkzbPXajMBgyboSC7ela4s5ThFyrD1AS8ywCv46y5GS0CTMfyRXcCyjoCHoqwcEelXadan2cZF08UXM6Q1SWKUDCnOjFQiE8dt7kILUowuxTMfOpbhcSsLrqt0us5vPKguFSi7kILUowuxTMn41pd2velkyPhlQRwZoockHlCTnugR42Hk9pXSamwqfaTLoYyb4zjqVMLES44BCDncAIgwqclfSyw6ZcGzPGSa8SCUMYZMKPAjeMwkDvnbYIcwmJLzLudoOil(Z2sx3JJpAE3sPRQjqwuWI6Q1SJJGs4cxBdLXkUDfXsxhlQRwZg86Nb7qL(NywaglOcG2shzSa8SeOxZspwC8nUUgbnrdliHLcwml9zPRJf1vRzhhbLWfU2gkJv8k(Z2sx3JJpAE3UIyPRJfZyrD1A2XrqjCHRTHYyf3UIyrblMXsac1GqtPDCeucx4ABOmwXTd5GXzPRJfZyjarqPNNfbL3E8HL(S01XIJVX11iOjAyPqwaofZIcwOG(JWK9ZQNXnoJycqaAyEJnkDvnbAeBJnpCpmn2WNp41GIm2ajCy(O7HPXM5N4SCqwkDGiwUDIfvcFSaBSSD(OHdilQXzbFEaOprXYFSSIyb4U(aq64S8jlEgNf0lO)imXI66ybaU0yFy5X5XIRcxhlhKfvILObgceOXwy(JM3n2oxt5zXNpA4aAP0v1eilkyXmwMvsn4GIS3xsMGtwbhYlv)eKglLUQMazrbl9yrD1Aw85JgoG2velDDS44BCDncAIgwkKfGtXS0NffSOUAnl(8rdhql(8aqSamwkilkyPhlQRwZsb9hHPkgQ9XUIyPRJf1vRzPG(JWuvVsFSRiw6ZIcwuxTMnA(s4a(UU6tWZpuJwASpweUErSamwaiGSywuWspwcqOgeAkTbV(zWouP)jMLczr5IzPRJfZybHpVRQjBaMiGarvqchpdSOGLaebLEE28rTF1MtS034mIjalOH5n2O0v1eOrSn2GrgBy6m28W9W0ydHpVRQjJneUErgBuq)ryY(zvVsFyb4zbaXcsyXd3dtl(8P9dzjKrH1r17ljwamlMXcf0FeMSFw1R0hwaEw6XcGMfaZY5AkplgU0vyRE7uTbhcFwkDvnbYcWZsbzPpliHfpCpmTMg)2TeYOW6O69LelaMLITMdAybjSGJiTUU74JybWSuSfnSa8SCUMYZM(TgcxvDTNbYsPRQjqJnqchMp6EyASHE47l9JWSSdnXs5kSZsmWaqw8HybL)jbYsenSGPambn2q4tn9sYyZXraqA2OGXzetaAogM3yJsxvtGgX2yZd3dtJn85dEnOiJnqchMp6EyASvaxLrSSD(GxdkILpzXzbqcymfyzdQ9Hf0lO)imHwwaHj6ow00XYFSenWalaWLg7dl9UD)y5XSS7jOMazrnol0F70WYTtSSD(0CTMf9NelWHLBNyjgyayHaNIzr)jXsdoSSD(GxdkQpAzbeMO7ybIGgtZFelEYca(KUDwIgyGfpbzrthl3oXIRcrqSO)Kyz3tqnXY25JgoGgBH5pAE3yZmwMvsn4GIS3xsMGtwbhYlv)eKglLUQMazrbl9yrD1A2O5lHd476Qpbp)qnAPX(yr46fXcWybGaYIzPRJf1vRzJMVeoGVRR(e88d1OLg7JfHRxelaJfaIMIzrblNRP8S4J0AFQGZ3olLUQMazPplkyPhluq)ryY(zfd1(WIcwC8nUUgbnrdlaMfe(8UQMSoocasZgfyb4zrD1AwkO)imvXqTp2Hk9pXSaywaHNTTM4vyRs6vs27daHRdv6FYcWZcaTOHLczbavmlDDSqb9hHj7Nv9k9HffS44BCDncAIgwamli85DvnzDCeaKMnkWcWZI6Q1Suq)ryQQxPp2Hk9pXSaywaHNTTM4vyRs6vs27daHRdv6FYcWZcaTOHLczb4uml9zrblMXI6Q1SWKUDCnIMafDpmTRiwuWIzSCUMYZIpF0Wb0sPRQjqwuWspwcqOgeAkTbV(zWouP)jMLczbqYsxhly4sR(jO92NxRRyIaIglLUQMazrblQRwZE7ZR1vmrarJfFEaiwaglfSGSaiyPhlZkPgCqrw8NTLUUhhF08ULsxvtGSa8SGgw6ZIcwApQ9RouP)jMLczr5IlMffS0Eu7xDOs)tmlaJfawCXS0NffS0JLaeQbHMslqFcoeyfh9ZFy7qL(NywkKfajlDDSyglbick98SafFEpzPVXzetaIgdZBSrPRQjqJyBS5H7HPXwsMQLqyASbs4W8r3dtJTcetSaGfctmlFYc6VsFyb9c6pctS4jilyhbXcYzCDdWfGLwZcawimzPbhwqAmqI5Mbw8eKfKtFcoeilOxze0enLuEgBH5pAE3yRhlQRwZsb9hHPQEL(yhQ0)eZsHSqiJcRJQ3xsS01Xspwc7(GIWSOelaKffSmuy3huu9(sIfGXcAyPplDDSe29bfHzrjwkil9zrblEunStbGyrbli85DvnzXocQ2Gtn41pdgNrmbiG2W8gBu6QAc0i2gBH5pAE3yRhlQRwZsb9hHPQEL(yhQ0)eZsHSqiJcRJQ3xsSOGfZyjarqPNNfO4Z7jlDDS0Jf1vRzb6tWHaRuze0enLuEvkPb1hlYUIyrblbick98SafFEpzPplDDS0JLWUpOimlkXcazrbldf29bfvVVKybySGgw6ZsxhlHDFqrywuILcYsxhlQRwZg86Nb7kIL(SOGfpQg2PaqSOGfe(8UQMSyhbvBWPg86NbwuWspwuxTMDCeucx4ABOmwXTdv6FIzbyS0Jf0WcGGfaYcWZYSsQbhuKf)zBPR7XXhnVBP0v1eil9zrblQRwZoockHlCTnugR42velDDSyglQRwZoockHlCTnugR42vel9n28W9W0yB31TAjeMgNrmbiG0W8gBu6QAc0i2gBH5pAE3yRhlQRwZsb9hHPQEL(yhQ0)eZsHSqiJcRJQ3xsSOGfZyjarqPNNfO4Z7jlDDS0Jf1vRzb6tWHaRuze0enLuEvkPb1hlYUIyrblbick98SafFEpzPplDDS0JLWUpOimlkXcazrbldf29bfvVVKybySGgw6ZsxhlHDFqrywuILcYsxhlQRwZg86Nb7kIL(SOGfpQg2PaqSOGfe(8UQMSyhbvBWPg86NbwuWspwuxTMDCeucx4ABOmwXTdv6FIzbySGgwuWI6Q1SJJGs4cxBdLXkUDfXIcwmJLzLudoOil(Z2sx3JJpAE3sPRQjqw66yXmwuxTMDCeucx4ABOmwXTRiw6BS5H7HPXwBP11simnoJycqaKH5n2O0v1eOrSn2ajCy(O7HPXwbIjwqoGOhlWKLaOXMhUhMgBM8zE4uHTkPxjzCgXeGahdZBSrPRQjqJyBS5H7HPXg(8P9dzSbs4W8r3dtJTcetSSD(0(Hy5GSenWalBqTpSGEb9hHj0YcsJbsm3mWYUJzrtyml3xsSC7EYIZcYX43oleYOW6iw0u7yboSatDCwq)v6dlOxq)ryILhZYkYylm)rZ7gBuq)ryY(zvVsFyPRJfkO)imzXqTp1Kq2Xsxhluq)ryY6z8Asi7yPRJLESOUAnRjFMhovyRs6vs2velDDSGJiTUU74JybySuS1CqdlkyXmwcqeu65zrq5ThFyPRJfCeP11DhFelaJLITMdlkyjarqPNNfbL3E8HL(SOGf1vRzPG(JWuvVsFSRiw66yPhlQRwZg86Nb7qL(NywaglE4EyAnn(TBjKrH1r17ljwuWI6Q1SbV(zWUIyPVXzeZcwSH5n2O0v1eOrSn2ajCy(O7HPXwbIjwqog)2zbE70y6XelM2)WolpMLpzzdQ9Hf0lO)imHwwqAmqI5MbwGdlhKLObgyb9xPpSGEb9hHjJnpCpmn2mn(TBCgXSGkByEJnkDvnbAeBJnqchMp6EyASvaCT(2NLXMhUhMgBZkRE4Eyw1p(m20p(QPxsgBnxRV9zzCgNXw0qbyPQFgM3iMkByEJnpCpmn2a6tWHaR4OF(dBSrPRQjqJyBCgXeGgM3yJsxvtGgX2ydgzSHPZyZd3dtJne(8UQMm2q46fzSvSXgiHdZhDpmn2m)oXccFExvtS8ywW0XYbzPywm93oljKf85hlWKLfMy5MpbIomAzrzwmTtjl3oXs7h8XcmjwEmlWKLfMqllaKLVXYTtSGPambz5XS4jilfKLVXIk82zXhYydHp10ljJnywxyQEZNarNXzeZcAyEJnkDvnbAeBJnyKXMdcAS5H7HPXgcFExvtgBiC9Im2u2ylm)rZ7gB38jq0zpLTlSRQjwuWYnFceD2tzBac1GqtPfCn(9W0ydHp10ljJnywxyQEZNarNXzetZXW8gBu6QAc0i2gBWiJnhe0yZd3dtJne(8UQMm2q46fzSbqJTW8hnVBSDZNarN9aODHDvnXIcwU5tGOZEa0gGqni0uAbxJFpmn2q4tn9sYydM1fMQ38jq0zCgXengM3yJsxvtGgX2ydgzS5GGgBE4EyASHWN3v1KXgcFQPxsgBWSUWu9MpbIoJTW8hnVBSra31hfrG2pXHzDUQMQa3LN3QScsi(aXsxhleWD9rreOLkJIpKRRWbm9mqS01XcbCxFuebAXWLwt39jQ6SuJBSbs4W8r3dtJnZVtyILB(ei6WS4dXscpw81v63hCToolG0rHJazXXSatwwyIf85hl38jq0HTSedTjpoMfhe8tuSOmlLKNywUDkolMETMfxBYJJzrLyjAOgndbYYNGueLGuESaBSG1WZydHRxKXMYgNrmb0gM3yZd3dtJTsimb6ZAdoLgBu6QAc0i2gNrmbKgM3yJsxvtGgX2yZd3dtJntJF7gB6pPAa0yt5In2cZF08UXwpwOG(JWKvVsFQjHSJLUowOG(JWK9ZkgQ9HLUowOG(JWK9ZQk82zPRJfkO)imz9mEnjKDS03ydKWH5JUhMgBaWHco(ybGSGCm(TZINGS4SSD(GxdkIfyYYM5zX0F7SeZh1(XsbWjw8eKLydJH5zboSSD(0(HybE70y6XKXzetaKH5n2O0v1eOrSn2cZF08UXwpwOG(JWKvVsFQjHSJLUowOG(JWK9ZkgQ9HLUowOG(JWK9ZQk82zPRJfkO)imz9mEnjKDS0NffSenecRYwtJF7SOGfZyjAiewaAnn(TBS5H7HPXMPXVDJZiMahdZBSrPRQjqJyBSfM)O5DJnZyzwj1GdkYQ6Apduf2QUwxV9prHTu6QAcKLUowmJLaebLEE28rTF1MtS01XIzSGJiTUE(GIoSfF(0CTMfLyrzw66yXmwoxt5zt)wdHRQU2ZazP0v1eilDDS0JfkO)imzXqTp1Kq2Xsxhluq)ryY(zvVsFyPRJfkO)imz)SQcVDw66yHc6pctwpJxtczhl9n28W9W0ydF(0(HmoJyQCXgM3yJsxvtGgX2ylm)rZ7gBZkPgCqrwvx7zGQWw1166T)jkSLsxvtGSOGLaebLEE28rTF1MtSOGfCeP11Zhu0HT4ZNMR1SOelkBS5H7HPXg(8bVguKXzCgNXgcAWpmnIjalgGkxmGgGahR5ySzYN8tuyJnKJyaGjMMBmrohqXclMFNy5lJGZXsdoSGoqQ5l9Howgc4U(Hazbdljw81bl9JazjS7jkcB5Iq)pjwmhaflifMiO5iqw2(sKYcoEEoYyb5YYbzb9xolGpIh)WKfyen(bhw6HK(S0tzK13YfH(FsSyoakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KybnakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KybqdOybPWebnhbYY2xIuwWXZZrglixwoilO)Yzb8r84hMSaJOXp4WspK0NLEaez9TCrO)NelasaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfH(FsSaibuSGuyIGMJazbD38jq0zv2caqhlhKf0DZNarN9u2caqhl9aiY6B5Iq)pjwaKakwqkmrqZrGSGUB(ei6Sa0caqhlhKf0DZNarN9aOfaGow6bqK13YfH(FsSaGauSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe6)jXcWbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO)NelkxmGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5Iq)pjwuwzaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfH(FsSOmabuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspaIS(wUi0)tIfLbiGIfKcte0CeilO7MpbIoRYwaa6y5GSGUB(ei6SNYwaa6yPharwFlxe6)jXIYaeqXcsHjcAocKf0DZNarNfGwaa6y5GSGUB(ei6ShaTaa0XspLrwFlxe6)jXIYfeqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9aiY6B5Iq)pjwuUGakwqkmrqZrGSGUB(ei6SkBbaOJLdYc6U5tGOZEkBbaOJLEkJS(wUi0)tIfLliGIfKcte0CeilO7MpbIolaTaa0XYbzbD38jq0zpaAbaOJLEaez9TCrCrihXaatmn3yICoGIfwm)oXYxgbNJLgCybDrdfGLQ(Howgc4U(Hazbdljw81bl9JazjS7jkcB5Iq)pjwkiGIfKcte0CeilO7MpbIoRYwaa6y5GSGUB(ei6SNYwaa6yPharwFlxe6)jXI5aOybPWebnhbYc6U5tGOZcqlaaDSCqwq3nFceD2dGwaa6yPharwFlxe6)jXcWbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO)NelkxmGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5I4IqoIbaMyAUXe5CaflSy(DILVmcohln4Wc6CiHowgc4U(Hazbdljw81bl9JazjS7jkcB5Iq)pjwugqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl(Xc6bGh9zPNYiRVLlc9)KyPGakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KybqdOybPWebnhbYY2xIuwWXZZrglixKllhKf0F5Sucbx6fMfyen(bhw6HC7ZspLrwFlxe6)jXcGgqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9aiY6B5Iq)pjwaKakwqkmrqZrGSS9LiLfC88CKXcYf5YYbzb9xolLqWLEHzbgrJFWHLEi3(S0tzK13YfH(FsSaibuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe6)jXcacqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO)NelahaflifMiO5iqw2(sKYcoEEoYyb5YYbzb9xolGpIh)WKfyen(bhw6HK(S0dGiRVLlc9)KyrzacOybPWebnhbYY2xIuwWXZZrglixwoilO)Yzb8r84hMSaJOXp4WspK0NLEkJS(wUi0)tIfLboakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KybGkdOybPWebnhbYY2xIuwWXZZrglixwoilO)Yzb8r84hMSaJOXp4WspK0NLEkJS(wUi0)tIfawqaflifMiO5iqw2(sKYcoEEoYyb5YYbzb9xolGpIh)WKfyen(bhw6HK(S0dGiRVLlc9)KybGfeqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO)NelaenakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KybGaAaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfH(FsSaqaeGIfKcte0CeilBFjszbhpphzSGCz5GSG(lNfWhXJFyYcmIg)Gdl9qsFw6bqK13YfH(FsSaqGdGIfKcte0CeilBFjszbhpphzSGCz5GSG(lNfWhXJFyYcmIg)Gdl9qsFw6PmY6B5I4IqoIbaMyAUXe5CaflSy(DILVmcohln4Wc6AUwF7ZcDSmeWD9dbYcgwsS4Rdw6hbYsy3tue2YfH(FsSaqaflifMiO5iqw2(sKYcoEEoYyb5YYbzb9xolGpIh)WKfyen(bhw6HK(S0tzK13YfXfHCedamX0CJjY5akwyX87elFzeCowAWHf0Hp0XYqa31peilyyjXIVoyPFeilHDprrylxe6)jXIYakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KyPGakwqkmrqZrGSGUzLudoOilaaDSCqwq3SsQbhuKfayP0v1ei6yPNYiRVLlc9)KyrzLbuSGuyIGMJazz7lrkl4455iJfKlYLLdYc6VCwkHGl9cZcmIg)Gdl9qU9zPNYiRVLlc9)KyrzLbuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe6)jXIYaAaflifMiO5iqwq3SsQbhuKfaGowoilOBwj1GdkYcaSu6QAceDS0tzK13YfH(FsSaqLbuSGuyIGMJazz7lrkl4455iJfKllhKf0F5Sa(iE8dtwGr04hCyPhs6ZspaIS(wUi0)tIfaQmGIfKcte0CeilOBwj1GdkYcaqhlhKf0nRKAWbfzbawkDvnbIow6PmY6B5Iq)pjwaiabuSGuyIGMJazbDZkPgCqrwaa6y5GSGUzLudoOilaWsPRQjq0XspLrwFlxe6)jXcaliGIfKcte0CeilBFjszbhpphzSGCz5GSG(lNfWhXJFyYcmIg)Gdl9qsFw6vqK13YfH(FsSaqZbqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9aiY6B5Iq)pjwaiGgqXcsHjcAocKf0nRKAWbfzbaOJLdYc6Mvsn4GISaalLUQMarhl9ugz9TCrO)NelaeqcOybPWebnhbYc6Mvsn4GISaa0XYbzbDZkPgCqrwaGLsxvtGOJLEkJS(wUiUiKJyaGjMMBmrohqXclMFNy5lJGZXsdoSGovOFOJLHaURFiqwWWsIfFDWs)iqwc7EIIWwUi0)tIfLbqakwqkmrqZrGSS9LiLfC88CKXcYLLdYc6VCwaFep(HjlWiA8doS0dj9zPxbrwFlxe6)jXIYahaflifMiO5iqw2(sKYcoEEoYyb5YYbzb9xolGpIh)WKfyen(bhw6HK(S0tzK13YfXfzULrW5iqwa0S4H7Hjl6hFylxKXw0aBVMm2qEKNLy7ApdelfWz9GCripYZsrRKyPGfJwwayXauzUiUiKh5zbP7EIIWakUiKh5zbqWsmabjqw2GAFyj2KxA5IqEKNfabliD3tueilNpOOR(nwcoMWSCqwcXdAQE(GIoSLlc5rEwaeSaGHkHiiqwwzsbcJ9joli85DvnHzP3BjlAzjAiev85dEnOiwaefYs0qiS4Zh8Aqr9TCripYZcGGLyGa(GSenuWX3NOyb5y8BNLVXYFOdZYTtSyAGjkwqVG(JWKLlc5rEwaeSaG1bIybPWebeiILBNyzl6N)WS4SO)70elLWHyPPjK9QAILEFJL4Wfl7oyIUJL9)y5pwWF5sFEsWfwhNft)TZsSbWhdZZcGzbPKMW37AwIH(rLLuEOLL)qhilyG(O(wUiKh5zbqWcawhiILsi(ybDTh1(vhQ0)eJowWbk95Hyw8OiDCwoilQqmML2JA)WSatDClxexeYJ8SeJmHNFeilX21EgiwIbae9zj4jlQeln4kbzXpw2VlcdOqcsuDTNbcqG)YGf1F7lv7drsSDTNbcqS9LifjLG29RuJC22RjLuDTNbYEi74I4I8W9WeBJgkalv9tjG(eCiWko6N)WCriplMFNybHpVRQjwEmly6y5GSumlM(BNLeYc(8JfyYYctSCZNarhgTSOmlM2PKLBNyP9d(ybMelpMfyYYctOLfaYY3y52jwWuaMGS8yw8eKLcYY3yrfE7S4dXf5H7Hj2gnuawQ6hGvcji85DvnH20ljLGzDHP6nFceDOfHRxKsfZf5H7Hj2gnuawQ6hGvcji85DvnH20ljLGzDHP6nFceDOfgPKdcIweUErkPmA)Ms38jq0zv2UWUQMuCZNarNvzBac1GqtPfCn(9WKlYd3dtSnAOaSu1paResq4Z7QAcTPxskbZ6ct1B(ei6qlmsjheeTiC9IucGO9BkDZNarNfG2f2v1KIB(ei6Sa0gGqni0uAbxJFpm5IqEwm)oHjwU5tGOdZIpelj8yXxxPFFW164SashfocKfhZcmzzHjwWNFSCZNarh2Ysm0M84ywCqWprXIYSusEIz52P4Sy61AwCTjpoMfvILOHA0meilFcsrucs5XcSXcwdpUipCpmX2OHcWsv)aSsibHpVRQj0MEjPemRlmvV5tGOdTWiLCqq0IW1lsjLr73uIaURpkIaTFIdZ6CvnvbUlpVvzfKq8bQRJaURpkIaTuzu8HCDfoGPNbQRJaURpkIaTy4sRP7(evDwQX5I8W9WeBJgkalv9dWkHKsimb6ZAdoLCriplaWHco(ybGSGCm(TZINGS4SSD(GxdkIfyYYM5zX0F7SeZh1(XsbWjw8eKLydJH5zboSSD(0(HybE70y6XexKhUhMyB0qbyPQFawjKyA8BhT6pPAaujLlgTFtPEuq)ryYQxPp1Kq211rb9hHj7Nvmu7txhf0FeMSFwvH3Exhf0FeMSEgVMeYU(CrE4EyITrdfGLQ(byLqIPXVD0(nL6rb9hHjREL(utczxxhf0FeMSFwXqTpDDuq)ryY(zvfE7DDuq)ryY6z8Asi76RiAiewLTMg)2vyw0qiSa0AA8BNlYd3dtSnAOaSu1paResWNpTFi0(nLmBwj1GdkYQ6Apduf2QUwxV9prH76mlarqPNNnFu7xT5uxNz4isRRNpOOdBXNpnxRvs5UoZoxt5zt)wdHRQU2ZazP0v1eyxxpkO)imzXqTp1Kq211rb9hHj7Nv9k9PRJc6pct2pRQWBVRJc6pctwpJxtczxFUipCpmX2OHcWsv)aSsibF(GxdkcTFtPzLudoOiRQR9mqvyR6AD92)efwraIGsppB(O2VAZjf4isRRNpOOdBXNpnxRvszUiUiKh5zb9qgfwhbYcHGM4SCFjXYTtS4HdoS8ywCe(RDvnz5I8W9WeRegQ9PQsEjxeYZYgDywIbe9ybMSuqaZIP)2HRJfW5BhlEcYIP)2zz78rdhqw8eKfacywG3onMEmXf5H7HjgWkHee(8UQMqB6LKspU6qcTiC9IuchrAD98bfDyl(8P5ADHkRONzNRP8S4ZhnCaTu6QAcSR7CnLNfFKw7tfC(2zP0v1ey)UoCeP11Zhu0HT4ZNMR1fcqUiKNLn6WSe0KJGyX0oLSSD(0(Hyj4jl7)XcabmlNpOOdZIP9pSZYJzzinHWZJLgCy52jwqVG(JWelhKfvILOHA0meilEcYIP9pSZs71AAy5GSeC8Xf5H7HjgWkHee(8UQMqB6LKspUg0KJGqlcxViLWrKwxpFqrh2IpFA)qfQmxeYZsbIjwInnyAa6tuSy6VDwqAmqI5MbwGdlE7OHfKcteqGiw(KfKgdKyUzGlYd3dtmGvcjQ0GPbOprH2VPupZcqeu65zZh1(vBo11zwac1GqtPnateqGO6TtvC0p)HTRO(kuxTMn41pd2Hk9pXfQmAuOUAn74iOeUW12qzSIBhQ0)edmZrHzbick98SiO82JpDDbick98SiO82JpkuxTMn41pd2vKc1vRzhhbLWfU2gkJvC7ksrp1vRzhhbLWfU2gkJvC7qL(NyGPSYac0a8ZkPgCqrw8NTLUUhhF08ExN6Q1SbV(zWouP)jgykRCxNYixCeP11DhFeWu2Ig00Nlc5zbacpwm93ololingiXCZal3UFS84eDhlolaWLg7dlrdmWcCyX0oLSC7elTh1(XYJzXvHRJLdYcLGCrE4EyIbSsijcEpmr73usD1A2Gx)myhQ0)exOYOrrpZMvsn4GIS4pBlDDpo(O59Uo1vRzhhbLWfU2gkJvC7qL(NyGPmGuH6Q1SJJGs4cxBdLXkUDf1VRtfIXkApQ9RouP)jgyaenCripli11HL2pcZIPD62PHLf(tuSGuyIaceXscnXIPxRzX1AOjwIdxSCqwW3R1SeC8XYTtSG9sIfVeUYJfyJfKcteqGiaJ0yGeZndSeC8H5I8W9WedyLqccFExvtOn9ssPamrabIQGeoEgqlcxViLc0R71R9O2V6qL(NyaHYObqeGqni0uAdE9ZGDOs)tCFKRYaOI7RuGEDVETh1(vhQ0)ediugnacLbyXaIaeQbHMsBaMiGar1BNQ4OF(dBhQ0)e3h5QmaQ4(kmB8hSsiO8Soii2si7XhURlaHAqOP0g86Nb7qL(N4c)8OjcQ9JaRTh1(vhQ0)e31fGqni0uAdWebeiQE7ufh9ZFy7qL(N4c)8OjcQ9JaRTh1(vhQ0)ediuU4UoZcqeu65zZh1(vBo115H7HPnateqGO6TtvC0p)HTGp2v1eixeYZsbIjqwoilGK2JZYTtSSWokIfyJfKgdKyUzGft7uYYc)jkwaHlvnXcmzzHjw8eKLOHqq5XYc7OiwmTtjlEYIdcYcHGYJLhZIRcxhlhKfWN4I8W9WedyLqccFExvtOn9ssPaynatW)EyIweUErk178bfD27lP6bRGpvOYOPRB8hSsiO8Soii2(zHOP4(k61RNzeWD9rreOLkJIpKRRWbm9mqDD96fGqni0uAPYO4d56kCatpdKDOs)tmWugqxCxxaIGspplckV94JIaeQbHMslvgfFixxHdy6zGSdv6FIbMYaAajG7PSYa)SsQbhuKf)zBPR7XXhnV3VVcZcqOgeAkTuzu8HCDfoGPNbYoKdgVFFf9mJaURpkIaTy4sRP7(evDwQX76mlarqPNNnFu7xT5uxxac1GqtPfdxAnD3NOQZsnUDOs)tmWuwzZPVIEMra31hfrG2pXHzDUQMQa3LN3QScsi(a11fGqni0uA)ehM15QAQcCxEERYkiH4dKDihmEFf9cqOgeAkTQ0GPbOprzhYbJ31z24bYEduR7311RhcFExvtwywxyQEZNarNsk31HWN3v1KfM1fMQ38jq0Pub7RO3nFceDwLTd5GXRbiudcnLDD38jq0zv2gGqni0uAhQ0)ex4NhnrqTFeyT9O2V6qL(NyaHYf3VRdHpVRQjlmRlmvV5tGOtjaQO3nFceDwaAhYbJxdqOgeAk76U5tGOZcqBac1GqtPDOs)tCHFE0eb1(rG12JA)Qdv6FIbekxC)Uoe(8UQMSWSUWu9MpbIoLkUF)UUaebLEEwGIpVN95I8W9WedyLqccFExvtOn9ssPBFETUIjciAQM8)qlcxViLmddxA1pbT3(8ADfteq0yP0v1eyxx7rTF1Hk9pXfcWIlURtfIXkApQ9RouP)jgyaenaUN5umGqD1A2BFETUIjciAS4Zdab8aSFxN6Q1S3(8ADfteq0yXNhaQWccGae9Mvsn4GIS4pBlDDpo(O5DGhn95IqEwkqmXc6vgfFixZca(bm9mqSaWIXuaZIk1GdXIZcsJbsm3mWYctwUipCpmXawjKSWu9pQeTPxskrLrXhY1v4aMEgi0(nLcqOgeAkTbV(zWouP)jgyaSyfbiudcnL2amrabIQ3ovXr)8h2ouP)jgyaSyf9q4Z7QAYE7ZR1vmrart1K)xxN6Q1S3(8ADfteq0yXNhaQWcwmG7nRKAWbfzXF2w66EC8rZ7apGUF)UovigRO9O2V6qL(NyGvqajxeYZsbIjw2GlTMUprXcaMLACwa0ykGzrLAWHyXzbPXajMBgyzHjlxKhUhMyaReswyQ(hvI20ljLWWLwt39jQ6SuJJ2VPuac1GqtPn41pd2Hk9pXadqRWSaebLEEweuE7XhfMfGiO0ZZMpQ9R2CQRlarqPNNnFu7xT5KIaeQbHMsBaMiGar1BNQ4OF(dBhQ0)edmaTIEi85DvnzdWebeiQcs44zORlaHAqOP0g86Nb7qL(NyGbO731fGiO0ZZIGYBp(OONzZkPgCqrw8NTLUUhhF08UIaeQbHMsBWRFgSdv6FIbgGURtD1A2XrqjCHRTHYyf3ouP)jgykBoaUhAaEc4U(Oic0(j(Mv4GdUc(i(KQQKw3xH6Q1SJJGs4cxBdLXkUDf1VRtfIXkApQ9RouP)jgyaenCrE4EyIbSsizHP6FujAtVKu6tCywNRQPkWD55TkRGeIpqO9BkPUAnBWRFgSdv6FIluz0OONzZkPgCqrw8NTLUUhhF08ExN6Q1SJJGs4cxBdLXkUDOs)tmWugGaUxbbE1vRzv1qiOEHp7kQpG71dqciqdWRUAnRQgcb1l8zxr9bEc4U(Oic0(j(Mv4GdUc(i(KQQKw3xH6Q1SJJGs4cxBdLXkUDf1VRtfIXkApQ9RouP)jgyaenCriplMF)XS8ywCwg)2PHfs7QWXpIftECwoilLoqelUwZcmzzHjwWNFSCZNarhMLdYIkXI(tcKLvelM(BNfKgdKyUzGfpbzbPWebeiIfpbzzHjwUDIfaMGSG1WJfyYsaKLVXIk82z5MpbIoml(qSatwwyIf85hl38jq0H5I8W9WedyLqYct1)OsmAXA4Hv6MpbIoLr73ucHpVRQjlmRlmvV5tGOtjaQWSB(ei6Sa0oKdgVgGqni0u211dHpVRQjlmRlmvV5tGOtjL76q4Z7QAYcZ6ct1B(ei6uQG9v0tD1A2Gx)myxrk6zwaIGspplckV94txN6Q1SJJGs4cxBdLXkUDOs)tmG7HgGFwj1GdkYI)ST01944JM37dmLU5tGOZQSvD1AvW143dtfQRwZoockHlCTnugR42vuxN6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxr976cqOgeAkTbV(zWouP)jgWaSWB(ei6SkBdqOgeAkTGRXVhMk6zwaIGsppB(O2VAZPUoZq4Z7QAYgGjciqufKWXZqFfMfGiO0ZZcu859SRlarqPNNnFu7xT5Kce(8UQMSbyIacevbjC8mOiaHAqOP0gGjciqu92Pko6N)W2vKcZcqOgeAkTbV(zWUIu0RN6Q1Suq)ryQQxPp2Hk9pXfQCXDDQRwZsb9hHPkgQ9XouP)jUqLlUVcZMvsn4GISQU2ZavHTQR11B)tu4UUEQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaPeA66uxTMv11EgOkSvDTUE7FIcx9j4jzXNhasjau)(DDQRwZc0NGdbwPYiOjAkP8QusdQpwKDf1VRtfIXkApQ9RouP)jgyaS4Uoe(8UQMSWSUWu9MpbIoLkMlYd3dtmGvcjlmv)JkXOfRHhwPB(ei6aiA)Msi85DvnzHzDHP6nFceDMPeavy2nFceDwLTd5GXRbiudcnLDDi85DvnzHzDHP6nFceDkbqf9uxTMn41pd2vKIEMfGiO0ZZIGYBp(01PUAn74iOeUW12qzSIBhQ0)ed4EOb4Nvsn4GIS4pBlDDpo(O59(atPB(ei6Sa0QUATk4A87HPc1vRzhhbLWfU2gkJvC7kQRtD1A2XrqjCHRTHYyfVI)ST01944JM3TRO(DDbiudcnL2Gx)myhQ0)edyaw4nFceDwaAdqOgeAkTGRXVhMk6zwaIGsppB(O2VAZPUoZq4Z7QAYgGjciqufKWXZqFfMfGiO0ZZcu859urpZuxTMn41pd2vuxNzbick98SiO82Jp976cqeu65zZh1(vBoPaHpVRQjBaMiGarvqchpdkcqOgeAkTbyIacevVDQIJ(5pSDfPWSaeQbHMsBWRFgSRif96PUAnlf0FeMQ6v6JDOs)tCHkxCxN6Q1Suq)ryQIHAFSdv6FIlu5I7RWSzLudoOiRQR9mqvyR6AD92)efURRN6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqkHMUo1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGuca1VF)Uo1vRzb6tWHaRuze0enLuEvkPb1hlYUI66uHySI2JA)Qdv6FIbgalURdHpVRQjlmRlmvV5tGOtPI5IqEwkqmHzX1AwG3onSatwwyIL)OsmlWKLaixKhUhMyaReswyQ(hvI5IqEwkGu4bjw8W9WKf9JpwuDmbYcmzb)3YVhMirtOEmxKhUhMyaResMvw9W9WSQF8H20ljLCiHw8nF4usz0(nLq4Z7QAY(4QdjUipCpmXawjKmRS6H7Hzv)4dTPxskPc9dT4B(WPKYO9BknRKAWbfzvDTNbQcBvxRR3(NOWwc4U(OicKlYd3dtmGvcjZkRE4Eyw1p(qB6LKs4JlIlc5zbPUoS0(rywmTt3onSC7elfWH8YGFHDAyrD1ASy61AwAUwZcS1yX0F7FYYTtSKeYowco(4I8W9WeBDiPecFExvtOn9ssjWH8YQPxRRnxRRWwdTiC9IuQN6Q1S3xsMGtwbhYlv)eKg7qL(NyGHkaAlDKb4ITk31PUAn79LKj4KvWH8s1pbPXouP)jgyE4EyAXNpTFilHmkSoQEFjb4ITkROhf0FeMSFw1R0NUokO)imzXqTp1Kq211rb9hHjRNXRjHSRFFfQRwZEFjzcozfCiVu9tqASRifZkPgCqr27ljtWjRGd5LQFcsdxeYZcsDDyP9JWSyANUDAyz78bVguelpMftW52zj447tuSarqdlBNpTFiw(Kf0FL(Wc6f0FeM4I8W9WeBDibyLqccFExvtOn9ssPhvchQIpFWRbfHweUErkzgf0FeMSFwXqTpk6HJiTUE(GIoSfF(0(Hkenkoxt5zXWLUcB1BNQn4q4ZsPRQjWUoCeP11Zhu0HT4ZN2puHaY(CriplfiMybPWebeiIft7uYIFSOjmMLB3twqtXSedmaKfpbzr)jXYkIft)TZcsJbsm3mWf5H7Hj26qcWkHKamrabIQ3ovXr)8hgTFtjZaN1dAtynaIv0RhcFExvt2amrabIQGeoEguywac1GqtPn41pd2HCW4DDQRwZg86Nb7kQVIEQRwZsb9hHPQEL(yhQ0)exiGURtD1AwkO)imvXqTp2Hk9pXfcO7RONzZkPgCqrwvx7zGQWw1166T)jkCxN6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqfwWUo1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGkSG976uHySI2JA)Qdv6FIbMYfRWSaeQbHMsBWRFgSd5GX7ZfH8SuGyILcWqzSIZIP)2zbPXajMBg4I8W9WeBDibyLqY4iOeUW12qzSIJ2VPK6Q1SbV(zWouP)jUqLrdxeYZsbIjw2wz7hILpzjYtqQ8dSatw8m(T)jkwUD)yr)iimlkBoykGzXtqw0egZIP)2zPeoelNpOOdZINGS4hl3oXcLGSaBS4SSb1(Wc6f0FeMyXpwu2CybtbmlWHfnHXSmuP)5NOyXXSCqws4XYUJ4tuSCqwgQneENfW18jkwq)v6dlOxq)ryIlYd3dtS1HeGvcj4v2(HqBiEqt1Zhu0Hvsz0(nL6nuBi8URQPUo1vRzPG(JWufd1(yhQ0)edScQGc6pct2pRyO2hfdv6FIbMYMJIZ1uEwmCPRWw92PAdoe(Su6QAcSVIZhu0zVVKQhSc(uHkBoacCeP11Zhu0Hb8qL(Nyf9OG(JWK9ZQNX76gQ0)edmubqBPJS(CripliNikILvelBNpnxRzXpwCTML7ljmlRutymll8NOyb9Jh8XXS4jil)XYJzXvHRJLdYs0adSahw00XYTtSGJOW7Aw8W9WKf9NelQKgAILDpb1elfWH8s1pbPHfyYcaz58bfDyUipCpmXwhsawjKGpFAUwJ2VPKzNRP8S4J0AFQGZ3olLUQMav0tD1Aw85tZ1A7qTHW7UQMu0dhrAD98bfDyl(8P5AnWkyxNzZkPgCqr27ljtWjRGd5LQFcst)UUZ1uEwmCPRWw92PAdoe(Su6QAcuH6Q1Suq)ryQIHAFSdv6FIbwbvqb9hHj7Nvmu7Jc1vRzXNpnxRTdv6FIbgGuboI0665dk6Ww85tZ16cvYC6RONzZkPgCqrwD8GpoU20eDFIQIs)LryQR7(sc5ICnh0uO6Q1S4ZNMR12Hk9pXagG9vC(GIo79Lu9GvWNkenCriplih)TZY2rATpSuaNVDSSWelWKLailM2PKLHAdH3DvnXI66ybFVwZIj)pwAWHf0pEWhhZs0adS4jilGWeDhllmXIk1GdXcslGyllB3R1SSWelQudoelifMiGarSG)mqSC7(XIPxRzjAGbw8eE70WY25tZ1AUipCpmXwhsawjKGpFAUwJ2VP05Akpl(iT2Nk48TZsPRQjqfQRwZIpFAUwBhQneE3v1KIEMnRKAWbfz1Xd(44Att09jQkk9xgHPUU7ljKlY1CqtHMtFfNpOOZEFjvpyf8PclixeYZcYXF7SuahYlv)eKgwwyILTZNMR1SCqwaIOiwwrSC7elQRwJf14S4AmKLf(tuSSD(0CTMfyYcAybtbycIzboSOjmMLHk9p)efxKhUhMyRdjaResWNpnxRr73uAwj1GdkYEFjzcozfCiVu9tqAuGJiTUE(GIoSfF(0CTUqLkOIEMPUAn79LKj4KvWH8s1pbPXUIuOUAnl(8P5ATDO2q4DxvtDD9q4Z7QAYcoKxwn9ADT5ADf2Ak6PUAnl(8P5ATDOs)tmWkyxhoI0665dk6Ww85tZ16cbOIZ1uEw8rATpvW5BNLsxvtGkuxTMfF(0CT2ouP)jgyOPF)(Cripli11HL2pcZIPD62PHfNLTZh8AqrSSWelMETMLGVWelBNpnxRz5GS0CTMfyRHww8eKLfMyz78bVguelhKfGikILc4qEP6NG0Wc(8aqSSI4I8W9WeBDibyLqccFExvtOn9ssj85tZ16QjyE1MR1vyRHweUErk54BCDncAIMcbqfdi6PCXaV6Q1S3xsMGtwbhYlv)eKgl(8aq9be9uxTMfF(0CT2ouP)jg4liYfhrADD3Xhb8MDUMYZIpsR9PcoF7Su6QAcSpGOxac1GqtPfF(0CT2ouP)jg4liYfhrADD3Xhb8NRP8S4J0AFQGZ3olLUQMa7di6bcpBBnXRWwL0RKSdv6FIbE00xrp1vRzXNpnxRTROUUaeQbHMsl(8P5ATDOs)tCFUiKNLcetSSD(GxdkIft)TZsbCiVu9tqAy5GSaerrSSIy52jwuxTglM(BhUow0q8NOyz78P5AnlRO7ljw8eKLfMyz78bVguelWKfZbWSeBymmpl4ZdaHzzL3RzXCy58bfDyUipCpmXwhsawjKGpFWRbfH2VPecFExvtwWH8YQPxRRnxRRWwtbcFExvtw85tZ16QjyE1MR1vyRPWme(8UQMSpQeoufF(GxdkQRRN6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqfwWUo1vRzvDTNbQcBvxRR3(NOWvFcEsw85bGkSG9vGJiTUE(GIoSfF(0CTgyMJce(8UQMS4ZNMR1vtW8QnxRRWwJlc5zPaXelyt(uYcgYYT7hlXHlwqrhlLoYyzfDFjXIACww4prXYFS4yw0(rS4ywIGy8RQjwGjlAcJz529KLcYc(8aqywGdla4SWhlM2PKLccywWNhacZcHSOFiUipCpmXwhsawjK4GE09iOk2KpLOnepOP65dk6WkPmA)MsMDFaOprPWmpCpmToOhDpcQIn5tzf0lDuK9ZAt)O2VUoq4zDqp6EeufBYNYkOx6Oil(8aqaRGkaHN1b9O7rqvSjFkRGEPJISdv6FIbwb5IqEwaWqTHW7SaGfcZ2pelFJfKgdKyUzGLhZYqoyC0YYTtdXIpelAcJz529Kf0WY5dk6WS8jlO)k9Hf0lO)imXIP)2zzdEfa0YIMWywUDpzr5IzbE70y6XelFYINXzb9c6pctSahwwrSCqwqdlNpOOdZIk1GdXIZc6VsFyb9c6pctwwkGWeDhld1gcVZc4A(efliN(eCiqwqVYiOjAkP8yzLAcJz5tw2GAFyb9c6pctCrE4EyIToKaSsiPecZ2peAdXdAQE(GIoSskJ2VP0qTHW7UQMuC(GIo79Lu9GvWNkSxpLnha3dhrAD98bfDyl(8P9db8ae4vxTMLc6pctv9k9XUI63hWdv6FI7JC7PmGpxt5zptFwlHWeBP0v1eyFf9cqOgeAkTbV(zWoKdgxHzGZ6bTjSgaXk6HWN3v1KnateqGOkiHJNHUUaeQbHMsBaMiGar1BNQ4OF(dBhYbJ31zwaIGsppB(O2VAZP(DD4isRRNpOOdBXNpTFiG1RhGgq0tD1AwkO)imv1R0h7kc4by)(aFpLb85Akp7z6ZAjeMylLUQMa73xHzuq)ryYIHAFQjHSRRRhf0FeMSFwXqTpDD9OG(JWK9ZQk8276OG(JWK9ZQEL(0xHzNRP8Sy4sxHT6Tt1gCi8zP0v1eyxN6Q1SrZxchW31vFcE(HA0sJ9XIW1lQqLaiAkUVIE4isRRNpOOdBXNpTFiGPCXaFpLb85Akp7z6ZAjeMylLUQMa73xHJVX11iOjAkenfdiuxTMfF(0CT2ouP)jg4b09v0Zm1vRzb6tWHaRuze0enLuEvkPb1hlYUI66OG(JWK9ZkgQ9PRZSaebLEEwGIpVN9vyM6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrCriplfiMyPaaJjlWKLailM(BhUowcEu0NO4I8W9WeBDibyLqsdobQcB10V1qO9Bk5r1WofaIlYd3dtS1HeGvcji85DvnH20ljLcG1amb)7Hz1HeAr46fPKzGZ6bTjSgaXkq4Z7QAYgaRbyc(3dtf96PUAnl(8P5ATDf1117CnLNfFKw7tfC(2zP0v1eyxxaIGsppB(O2VAZP(9v0Zm1vRzXqn((azxrkmtD1A2Gx)myxrk6z25AkpBBnXRWwL0RKSu6QAcSRtD1A2Gx)mybxJFpmlmaHAqOP02wt8kSvj9kj7qL(NyadG6RaHpVRQj7TpVwxXebenvt(Fk6zwaIGsppB(O2VAZPUUaeQbHMsBaMiGar1BNQ4OF(dBxrk6PUAnl(8P5ATDOs)tmWayxNzNRP8S4J0AFQGZ3olLUQMa73xX5dk6S3xs1dwbFQq1vRzdE9ZGfCn(9We4l2ci731PcXyfTh1(vhQ0)edm1vRzdE9ZGfCn(9WSpxeYZsbIjwqAmqI5MbwGjlbqwwPMWyw8eKf9Nel)XYkIft)TZcsHjciqexKhUhMyRdjaRescKMW376QRFuzjLhA)Msi85DvnzdG1amb)7Hz1HexKhUhMyRdjaRes(m4t63dt0(nLq4Z7QAYgaRbyc(3dZQdjUiKNLcetSGELrqt0WsSHjilWKLailM(BNLTZNMR1SSIyXtqwWocILgCybaU0yFyXtqwqAmqI5MbUipCpmXwhsawjKqLrqt0uvHjiA)MsQqmwXNhnrqTFeyT9O2V6qL(NyGPmA666PUAnB08LWb8DD1NGNFOgT0yFSiC9IagartXDDQRwZgnFjCaFxx9j45hQrln2hlcxVOcvcGOP4(kuxTMfF(0CT2UIu0laHAqOP0g86Nb7qL(N4crtXDDGZ6bTjSgaX95IqEwaWqTHW7S00(qSatwwrSCqwkilNpOOdZIP)2HRJfKgdKyUzGfv6tuS4QW1XYbzHqw0pelEcYscpwGiOj4rrFIIlYd3dtS1HeGvcj4J0AFQnTpeAdXdAQE(GIoSskJ2VP0qTHW7UQMuCFjvpyf8PcvgnkWrKwxpFqrh2IpFA)qaZCu4r1Wofasrp1vRzdE9ZGDOs)tCHkxCxNzQRwZg86Nb7kQpxeYZsbIjwkaq0JLVXYN4hKyXtwqVG(JWelEcYI(tIL)yzfXIP)2zXzbaU0yFyjAGbw8eKLya6r3JGyzZKpLCrE4EyIToKaSsiPTM4vyRs6vsO9Bkrb9hHj7NvpJRWJQHDkaKc1vRzJMVeoGVRR(e88d1OLg7JfHRxeWaiAkwrpq4zDqp6EeufBYNYkOx6Oi79bG(evxNzbick98SjfgOgoGDD4isRRNpOOdxia7RON6Q1SJJGs4cxBdLXkUDOs)tmWaoaIEOb4Nvsn4GIS4pBlDDpo(O59(kuxTMDCeucx4ABOmwXTROUoZuxTMDCeucx4ABOmwXTRO(k6zwac1GqtPn41pd2vuxN6Q1S3(8ADfteq0yXNhacykJgfTh1(vhQ0)edmawCXkApQ9RouP)jUqLlU4UoZWWLw9tqBZpxxBA3KLsxvtG95IqEwkqmXIZY25tZ1AwaWN0TZs0adSSsnHXSSD(0CTMLhZIRhYbJZYkIf4WsC4IfFiwCv46y5GSarqtWJyjgyaixKhUhMyRdjaResWNpnxRr73usD1Awys3oUgrtGIUhM2vKIEQRwZIpFAUwBhQneE3v1uxNJVX11iOjAke4uCFUiKNLc4QmILyGbGSOsn4qSGuyIaceXIP)2zz78P5AnlEcYYTtjlBNp41GI4I8W9WeBDibyLqc(8P5AnA)Msbick98S5JA)QnNuy25Akpl(iT2Nk48TZsPRQjqf9q4Z7QAYgGjciqufKWXZqxxac1GqtPn41pd2vuxN6Q1SbV(zWUI6RiaHAqOP0gGjciqu92Pko6N)W2Hk9pXadva0w6id4d0R754BCDncAIgKlAkUVc1vRzXNpnxRTdv6FIbM5OWmWz9G2ewdGyUipCpmXwhsawjKGpFWRbfH2VPuaIGsppB(O2VAZjf9q4Z7QAYgGjciqufKWXZqxxac1GqtPn41pd2vuxN6Q1SbV(zWUI6RiaHAqOP0gGjciqu92Pko6N)W2Hk9pXadqRqD1Aw85tZ1A7ksbf0FeMSFw9mUcZq4Z7QAY(Os4qv85dEnOifMboRh0MWAaeZfH8SuGyILTZh8AqrSy6VDw8Kfa8jD7SenWalWHLVXsC4cDGSarqtWJyjgyailM(BNL4W1Wssi7yj44ZYsm0yilGRYiwIbgaYIFSC7elucYcSXYTtSaGlL3E8Hf1vRXY3yz78P5AnlMGlnyIUJLMR1SaBnwGdlXHlw8HybMSaqwoFqrhMlYd3dtS1HeGvcj4Zh8AqrO9BkPUAnlmPBhxdAYNkIh)W0UI666zg(8P9dz9OAyNcaPWme(8UQMSpQeoufF(GxdkQRRN6Q1SbV(zWouP)jgyOrH6Q1SbV(zWUI6661tD1A2Gx)myhQ0)edmubqBPJmGpqVUNJVX11iOjAqUfS4(kuxTMn41pd2vuxN6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBhQ0)edmubqBPJmGpqVUNJVX11iOjAqUfS4(kuxTMDCeucx4ABOmwXR4pBlDDpo(O5D7kQVIaebLEEweuE7XN(9v0dhrAD98bfDyl(8P5AnWkyxhcFExvtw85tZ16QjyE1MR1vyR1VVcZq4Z7QAY(Os4qv85dEnOif9mBwj1GdkYEFjzcozfCiVu9tqA66WrKwxpFqrh2IpFAUwdSc2Nlc5zPaXelayHWeZYNSSb1(Wc6f0FeMyXtqwWocILcWsRzbaleMS0GdlingiXCZaxKhUhMyRdjaRessYuTect0(nL6PUAnlf0FeMQyO2h7qL(N4cjKrH1r17lPUUEHDFqryLaOIHc7(GIQ3xsadn976c7(GIWkvW(k8OAyNcaXf5H7Hj26qcWkHKDx3QLqyI2VPup1vRzPG(JWufd1(yhQ0)exiHmkSoQEFj111lS7dkcReavmuy3huu9(scyOPFxxy3huewPc2xHhvd7uaif9uxTMDCeucx4ABOmwXTdv6FIbgAuOUAn74iOeUW12qzSIBxrkmBwj1GdkYI)ST01944JM376mtD1A2XrqjCHRTHYyf3UI6Zf5H7Hj26qcWkHK2sRRLqyI2VPup1vRzPG(JWufd1(yhQ0)exiHmkSoQEFjPOxac1GqtPn41pd2Hk9pXfIMI76cqOgeAkTbyIacevVDQIJ(5pSDOs)tCHOP4(DD9c7(GIWkbqfdf29bfvVVKagA631f29bfHvQG9v4r1Wofasrp1vRzhhbLWfU2gkJvC7qL(NyGHgfQRwZoockHlCTnugR42vKcZMvsn4GIS4pBlDDpo(O59UoZuxTMDCeucx4ABOmwXTRO(CriplfiMyb5aIESatwqAbKlYd3dtS1HeGvcjM8zE4uHTkPxjXfH8SGuxhwA)imlM2PBNgwoillmXY25t7hILpzzdQ9Hft7FyNLhZIFSGgwoFqrhgWkZsdoSqiOjolaSyKllLo(OjolWHfZHLTZh8AqrSGELrqt0us5Xc(8aqyUipCpmXwhsawjKGWN3v1eAtVKucF(0(HQFwXqTpOfHRxKs4isRRNpOOdBXNpTFOcnha30q40R0XhnXRiC9IaELlUyKlalUpGBAiC6PUAnl(8bVguuLkJGMOPKYRIHAFS4ZdaHCnN(Cripli11HL2pcZIPD62PHLdYcYX43olGR5tuSuagkJvCUipCpmXwhsawjKGWN3v1eAtVKuY043E9ZABOmwXrlcxViLug5IJiTUU74JagaTObq0RylabECeP11Zhu0HT4ZN2peW3tzaFUMYZIHlDf2Q3ovBWHWNLsxvtGaVYw00VpGl2QmAaE1vRzhhbLWfU2gkJvC7qL(NyUiKNLcetSGCm(TZYNSSb1(Wc6f0FeMyboS8nwsilBNpTFiwm9AnlT)y5ZdYcsJbsm3mWINXlHdXf5H7Hj26qcWkHetJF7O9Bk1Jc6pctw9k9PMeYUUokO)imz9mEnjKDkq4Z7QAY(4AqtocQVIENpOOZEFjvpyf8PcnNUokO)imz1R0N6Nva211Eu7xDOs)tmWuU4(DDQRwZsb9hHPkgQ9XouP)jgyE4EyAXNpTFilHmkSoQEFjPqD1AwkO)imvXqTp2vuxhf0FeMSFwXqTpkmdHpVRQjl(8P9dv)SIHAF66uxTMn41pd2Hk9pXaZd3dtl(8P9dzjKrH1r17ljfMHWN3v1K9X1GMCeKc1vRzdE9ZGDOs)tmWiKrH1r17ljfQRwZg86Nb7kQRtD1A2XrqjCHRTHYyf3UIuGWN3v1K1043E9ZABOmwX76mdHpVRQj7JRbn5iifQRwZg86Nb7qL(N4cjKrH1r17ljUiKNLcetSSD(0(Hy5BS8jlO)k9Hf0lO)imHww(KLnO2hwqVG(JWelWKfZbWSC(GIomlWHLdYs0adSSb1(Wc6f0FeM4I8W9WeBDibyLqc(8P9dXfH8SuaCT(2NfxKhUhMyRdjaResMvw9W9WSQF8H20ljLAUwF7ZIlIlc5zPamugR4Sy6VDwqAmqI5MbUipCpmXwvOFknockHlCTnugR4O9BkPUAnBWRFgSdv6FIluz0WfH8SuGyILya6r3JGyzZKpLSyANsw8JfnHXSC7EYI5WsSHXW8SGppaeMfpbz5GSmuBi8ololatjaYc(8aqS4yw0(rS4ywIGy8RQjwGdl3xsS8hlyil)XIpZJGWSaGZcFS4TJgwCwkiGzbFEaiwiKf9dH5I8W9WeBvH(byLqId6r3JGQyt(uI2q8GMQNpOOdRKYO9BkPUAnRQR9mqvyR6AD92)efUM(TgYIppaeWaqkuxTMv11EgOkSvDTUE7FIcx9j4jzXNhacyaif9mdeEwh0JUhbvXM8PSc6LokYEFaOprPWmpCpmToOhDpcQIn5tzf0lDuK9ZAt)O2pf9mdeEwh0JUhbvXM8PSUtU2EFaOpr11bcpRd6r3JGQyt(uw3jxBhQ0)exyb731bcpRd6r3JGQyt(uwb9shfzXNhacyfubi8SoOhDpcQIn5tzf0lDuKDOs)tmWqJcq4zDqp6EeufBYNYkOx6Oi79bG(evFUiKNLcetSGuyIaceXIP)2zbPXajMBgyX0oLSebX4xvtS4jilWBNgtpMyX0F7S4SeBymmplQRwJft7uYciHJNHprXf5H7Hj2Qc9dWkHKamrabIQ3ovXr)8hgTFtjZaN1dAtynaIv0RhcFExvt2amrabIQGeoEguywac1GqtPn41pd2HCW4DDQRwZg86Nb7kQVIEQRwZQ6Apduf2QUwxV9prHRPFRHS4ZdaPeaQRtD1Awvx7zGQWw1166T)jkC1NGNKfFEaiLaq976uHySI2JA)Qdv6FIbMYf3Nlc5zPaarpwCml3oXs7h8XcQailFYYTtS4SeBymmplM(eeAIf4WIP)2z52jwqofFEpzrD1ASahwm93ololaiaJPalXa0JUhbXYMjFkzXtqwm5)XsdoSG0yGeZndS8nw(JftW8yrLyzfXIJY)KfvQbhILBNyjaYYJzP95J3jqUipCpmXwvOFawjK0wt8kSvj9kj0(nL61RN6Q1SQU2ZavHTQR11B)tu4A63Ail(8aqfcO76uxTMv11EgOkSvDTUE7FIcx9j4jzXNhaQqaDFf9mlarqPNNfbL3E8PRZm1vRzhhbLWfU2gkJvC7kQFFf9aN1dAtynaI76cqOgeAkTbV(zWouP)jUq0uCxxVaebLEE28rTF1MtkcqOgeAkTbyIacevVDQIJ(5pSDOs)tCHOP4(97311deEwh0JUhbvXM8PSc6LokYouP)jUqaKIaeQbHMsBWRFgSdv6FIlu5IveGiO0ZZMuyGA4a2VRtfIXk(8OjcQ9JaRTh1(vhQ0)edmaKcZcqOgeAkTbV(zWoKdgVRlarqPNNfO4Z7Pc1vRzb6tWHaRuze0enLuE2vuxxaIGspplckV94Jc1vRzhhbLWfU2gkJvC7qL(NyGbCuOUAn74iOeUW12qzSIBxrCripli1ZaPzz78rdhqwm93ololjzILydJH5zrD1AS4jilingiXCZalpor3XIRcxhlhKfvILfMa5I8W9WeBvH(byLqsWZaPRQRwdTPxskHpF0WbeTFtPEQRwZQ6Apduf2QUwxV9prHRPFRHSdv6FIleqArtxN6Q1SQU2ZavHTQR11B)tu4Qpbpj7qL(N4cbKw00xrVaeQbHMsBWRFgSdv6FIleq211laHAqOP0sLrqt0uvHjODOs)tCHasfMPUAnlqFcoeyLkJGMOPKYRsjnO(yr2vKIaebLEEwGIpVN97RWX346Ae0enfQublMlc5zPaUkJyz78bVgueMft)TZIZsSHXW8SOUAnwuxhlj8yX0oLSebH6prXsdoSG0yGeZndSahwqo9j4qGSSf9ZFyUipCpmXwvOFawjKGpFWRbfH2VPup1vRzvDTNbQcBvxRR3(NOW10V1qw85bGkeGDDQRwZQ6Apduf2QUwxV9prHR(e8KS4Zdavia7ROxaIGsppB(O2VAZPUUaeQbHMsBWRFgSdv6FIleq21zgcFExvt2aynatW)EyQWSaebLEEwGIpVNDD9cqOgeAkTuze0envvycAhQ0)exiGuHzQRwZc0NGdbwPYiOjAkP8QusdQpwKDfPiarqPNNfO4Z7z)(k6zgi8ST1eVcBvsVsYEFaOpr11zwac1GqtPn41pd2HCW4DDMfGqni0uAdWebeiQE7ufh9ZFy7qoy8(CriplfWvzelBNp41GIWSOsn4qSGuyIaceXf5H7Hj2Qc9dWkHe85dEnOi0(nL6fGqni0uAdWebeiQE7ufh9ZFy7qL(NyGHgfMboRh0MWAaeROhcFExvt2amrabIQGeoEg66cqOgeAkTbV(zWouP)jgyOPVce(8UQMSbWAaMG)9WSVcZaHNTTM4vyRs6vs27da9jkfbick98S5JA)QnNuyg4SEqBcRbqSckO)imz)S6zCfo(gxxJGMOPqZPyUiKNLcimr3Xci8ybCnFIILBNyHsqwGnwaW4iOeUWSuagkJvC0Yc4A(efla9j4qGSqLrqt0us5XcCy5twUDIfTJpwqfazb2yXtwqVG(JWexKhUhMyRk0paResq4Z7QAcTPxskbcV6qa31pujLhgTiC9IuQN6Q1SJJGs4cxBdLXkUDOs)tCHOPRZm1vRzhhbLWfU2gkJvC7kQVIEQRwZc0NGdbwPYiOjAkP8QusdQpwKDOs)tmWqfaTLoY6RON6Q1Suq)ryQIHAFSdv6FIleva0w6iRRtD1AwkO)imv1R0h7qL(N4crfaTLoY6Zf5H7Hj2Qc9dWkHe8kB)qOnepOP65dk6WkPmA)Msd1gcV7QAsX5dk6S3xs1dwbFQqLb0k8OAyNcaPaHpVRQjli8QdbCx)qLuEyUipCpmXwvOFawjKucHz7hcTH4bnvpFqrhwjLr73uAO2q4DxvtkoFqrN9(sQEWk4tfQCbTOrHhvd7uaifi85DvnzbHxDiG76hQKYdZf5H7Hj2Qc9dWkHe8rATp1M2hcTH4bnvpFqrhwjLr73uAO2q4DxvtkoFqrN9(sQEWk4tfQmGgWdv6FIv4r1WofasbcFExvtwq4vhc4U(HkP8WCriplfaymzbMSeazX0F7W1XsWJI(efxKhUhMyRk0paResAWjqvyRM(TgcTFtjpQg2PaqCriplOxze0enSeBycYIPDkzXvHRJLdYcLhnS4SKKjwInmgMNftFccnXINGSGDeeln4WcsJbsm3mWf5H7Hj2Qc9dWkHeQmcAIMQkmbr73uQhf0FeMS6v6tnjKDDDuq)ryYIHAFQjHSRRJc6pctwpJxtczxxN6Q1SQU2ZavHTQR11B)tu4A63Ai7qL(N4cbKw001PUAnRQR9mqvyR6AD92)efU6tWtYouP)jUqaPfnDDo(gxxJGMOPqGtXkcqOgeAkTbV(zWoKdgxHzGZ6bTjSgaX9v0laHAqOP0g86Nb7qL(N4clyXDDbiudcnL2Gx)myhYbJ3VRtfIXk(8OjcQ9JaRTh1(vhQ0)edmLlMlc5zPaarpwMh1(XIk1GdXYc)jkwqAm4I8W9WeBvH(byLqsBnXRWwL0RKq73ukaHAqOP0g86Nb7qoyCfi85DvnzdG1amb)7HPIEo(gxxJGMOPqGtXkmlarqPNNnFu7xT5uxxaIGsppB(O2VAZjfo(gxxJGMObyMtX9vywaIGspplckV94JIEMfGiO0ZZMpQ9R2CQRlaHAqOP0gGjciqu92Pko6N)W2HCW49vyg4SEqBcRbqmxeYZcsJbsm3mWIPDkzXpwaofdywIbgaYsp4OHMOHLB3twmNIzjgyailM(BNfKcteqGO(Sy6VD46yrdXFIIL7ljw(KLyRHqq9cFS4jil6pjwwrSy6VDwqkmrabIy5BS8hlMCmlGeoEgiqUipCpmXwvOFawjKGWN3v1eAtVKukawdWe8VhMvvOFOfHRxKsMboRh0MWAaeRaHpVRQjBaSgGj4Fpmv0RNJVX11iOjAke4uSIEQRwZc0NGdbwPYiOjAkP8QusdQpwKDf11zwaIGspplqXN3Z(DDQRwZQQHqq9cF2vKc1vRzv1qiOEHp7qL(NyGPUAnBWRFgSGRXVhM976(8OjcQ9JaRTh1(vhQ0)edm1vRzdE9ZGfCn(9WSRlarqPNNnFu7xT5uFf9mlarqPNNnFu7xT5uxxphFJRRrqt0amZP4Uoq4zBRjEf2QKELK9(aqFIQVIEi85DvnzdWebeiQcs44zORlaHAqOP0gGjciqu92Pko6N)W2HCW497Zf5H7Hj2Qc9dWkHKaPj89UU66hvws5H2VPecFExvt2aynatW)EywvH(Xf5H7Hj2Qc9dWkHKpd(K(9WeTFtje(8UQMSbWAaMG)9WSQc9Jlc5zb9W3x6hHzzhAILYvyNLyGbGS4dXck)tcKLiAybtbycYf5H7Hj2Qc9dWkHee(8UQMqB6LKsoocasZgfqlcxViLOG(JWK9ZQEL(a8aiKRhUhMw85t7hYsiJcRJQ3xsa2mkO)imz)SQxPpaFpanGpxt5zXWLUcB1BNQn4q4ZsPRQjqGVG9rUE4EyAnn(TBjKrH1r17ljaxSfGixCeP11DhFexeYZsbCvgXY25dEnOimlM2PKLBNyP9O2pwEmlUkCDSCqwOeeTS0gkJvCwEmlUkCDSCqwOeeTSehUyXhIf)yb4umGzjgyailFYINSGEb9hHj0YcsJbsm3mWI2XhMfpH3onSaGamMcywGdlXHlwmbxAqwGiOj4rSuchILB3tw4oLlMLyGbGSyANswIdxSycU0Gj6ow2oFWRbfXscnXf5H7Hj2Qc9dWkHe85dEnOi0(nL6PcXyfFE0eb1(rG12JA)Qdv6FIbM5011tD1A2XrqjCHRTHYyf3ouP)jgyOcG2shzaFGEDphFJRRrqt0GClyX9vOUAn74iOeUW12qzSIBxr97311ZX346Ae0enagHpVRQjRJJaG0SrbGxD1AwkO)imvXqTp2Hk9pXageE22AIxHTkPxjzVpaeUouP)jWdqlAkuzLlURZX346Ae0enagHpVRQjRJJaG0SrbGxD1AwkO)imv1R0h7qL(NyadcpBBnXRWwL0RKS3hacxhQ0)e4bOfnfQSYf3xbf0FeMSFw9mUIEMPUAnBWRFgSROUoZoxt5zXNpA4aAP0v1eyFf96zwac1GqtPn41pd2vuxxaIGspplqXN3tfMfGqni0uAPYiOjAQQWe0UI631fGiO0ZZMpQ9R2CQVIEMfGiO0ZZIGYBp(01zM6Q1SbV(zWUI66C8nUUgbnrtHaNI73117CnLNfF(OHdOLsxvtGkuxTMn41pd2vKIEQRwZIpF0Wb0IppaeWkyxNJVX11iOjAke4uC)(DDQRwZg86Nb7ksHzQRwZoockHlCTnugR42vKcZoxt5zXNpA4aAP0v1eixeYZsbIjwaWcHjMLpzb9xPpSGEb9hHjw8eKfSJGyb5mUUb4cWsRzbaleMS0GdlingiXCZaxKhUhMyRk0paRessYuTect0(nL6PUAnlf0FeMQ6v6JDOs)tCHeYOW6O69LuxxVWUpOiSsauXqHDFqr17ljGHM(DDHDFqryLkyFfEunStbG4I8W9WeBvH(byLqYURB1simr73uQN6Q1Suq)ryQQxPp2Hk9pXfsiJcRJQ3xsk6fGqni0uAdE9ZGDOs)tCHOP4UUaeQbHMsBaMiGar1BNQ4OF(dBhQ0)exiAkUFxxVWUpOiSsauXqHDFqr17ljGHM(DDHDFqryLkyFfEunStbG4I8W9WeBvH(byLqsBP11simr73uQN6Q1Suq)ryQQxPp2Hk9pXfsiJcRJQ3xsk6fGqni0uAdE9ZGDOs)tCHOP4UUaeQbHMsBaMiGar1BNQ4OF(dBhQ0)exiAkUFxxVWUpOiSsauXqHDFqr17ljGHM(DDHDFqryLkyFfEunStbG4IqEwqoGOhlWKLaixKhUhMyRk0paResm5Z8WPcBvsVsIlc5zPaXelBNpTFiwoilrdmWYgu7dlOxq)ryIf4WIPDkz5twGPoolO)k9Hf0lO)imXINGSSWelihq0JLObgWS8nw(Kf0FL(Wc6f0FeM4I8W9WeBvH(byLqc(8P9dH2VPef0FeMSFw1R0NUokO)imzXqTp1Kq211rb9hHjRNXRjHSRRtD1Awt(mpCQWwL0RKSRifQRwZsb9hHPQEL(yxrDD9uxTMn41pd2Hk9pXaZd3dtRPXVDlHmkSoQEFjPqD1A2Gx)myxr95I8W9WeBvH(byLqIPXVDUipCpmXwvOFawjKmRS6H7Hzv)4dTPxsk1CT(2NfxexeYZY25dEnOiwAWHLsicQKYJLvQjmMLf(tuSeBymmpxKhUhMyBZ16BFwkHpFWRbfH2VPKzZkPgCqrwvx7zGQWw1166T)jkSLaURpkIa5IqEwqQJpwUDIfq4XIP)2z52jwkH4JL7ljwoiloiilR8Enl3oXsPJmwaxJFpmz5XSS)NLLTv2(HyzOs)tmlLl99r6Naz5GSu6xyNLsimB)qSaUg)EyYf5H7Hj22CT(2NfGvcj4v2(HqBiEqt1Zhu0Hvsz0(nLaHNTecZ2pKDOs)tCHdv6FIbEacqKRYaiUipCpmX2MR13(SaSsiPecZ2pexexeYZsbIjw2oFWRbfXYbzbiIIyzfXYTtSuahYlv)eKgwuxTglFJL)yXeCPbzHqw0pelQudoelTpF8(NOy52jwsczhlbhFSahwoilGRYiwuPgCiwqkmrabI4I8W9WeBXNs4Zh8AqrO9BknRKAWbfzVVKmbNScoKxQ(jink6rb9hHj7NvpJRWSE9uxTM9(sYeCYk4qEP6NG0yhQ0)exOhUhMwtJF7wczuyDu9(scWfBvwrpkO)imz)SQcV9UokO)imz)SIHAF66OG(JWKvVsFQjHSRFxN6Q1S3xsMGtwbhYlv)eKg7qL(N4c9W9W0IpFA)qwczuyDu9(scWfBvwrpkO)imz)SQxPpDDuq)ryYIHAFQjHSRRJc6pctwpJxtczx)(DDMPUAn79LKj4KvWH8s1pbPXUI6311tD1A2Gx)myxrDDi85DvnzdWebeiQcs44zOVIaeQbHMsBaMiGar1BNQ4OF(dBhYbJRiarqPNNnFu7xT5uFf9mlarqPNNfO4Z7zxxac1GqtPLkJGMOPQctq7qL(N4cbq9v0tD1A2Gx)myxrDDMfGqni0uAdE9ZGDihmEFUiKNLcetSedqp6EeelBM8PKft7uYYTtdXYJzjHS4H7rqSGn5tjAzXXSO9JyXXSebX4xvtSatwWM8PKft)TZcazboS0it0Wc(8aqywGdlWKfNLccywWM8PKfmKLB3pwUDILKmXc2KpLS4Z8iimla4SWhlE7OHLB3pwWM8PKfczr)qyUipCpmXw8byLqId6r3JGQyt(uI2q8GMQNpOOdRKYO9Bkzgi8SoOhDpcQIn5tzf0lDuK9(aqFIsHzE4EyADqp6EeufBYNYkOx6Oi7N1M(rTFk6zgi8SoOhDpcQIn5tzDNCT9(aqFIQRdeEwh0JUhbvXM8PSUtU2ouP)jUq00VRdeEwh0JUhbvXM8PSc6LokYIppaeWkOcq4zDqp6EeufBYNYkOx6Oi7qL(NyGvqfGWZ6GE09iOk2KpLvqV0rr27da9jkUiKNLcetywqkmrabIy5BSG0yGeZndS8ywwrSahwIdxS4dXciHJNHprXcsJbsm3mWIP)2zbPWebeiIfpbzjoCXIpelQKgAIfZPywIbgaYf5H7Hj2IpaRescWebeiQE7ufh9ZFy0(nLmdCwpOnH1aiwrVEi85DvnzdWebeiQcs44zqHzbiudcnL2Gx)myhYbJRWSzLudoOiB08LWb8DD1NGNFOgT0yF66uxTMn41pd2vuFfo(gxxJGMObykzofRON6Q1Suq)ryQQxPp2Hk9pXfQCXDDQRwZsb9hHPkgQ9XouP)jUqLlUFxNkeJv0Eu7xDOs)tmWuUyfMfGqni0uAdE9ZGDihmEFUiKNfKctW)EyYsdoS4AnlGWdZYT7hlLoqeMf8AiwUDkol(qj6owgQneENazX0oLSaGXrqjCHzPamugR4SS7yw0egZYT7jlOHfmfWSmuP)5NOyboSC7elafFEpzrD1AS8ywCv46y5GS0CTMfyRXcCyXZ4SGEb9hHjwEmlUkCDSCqwiKf9dXf5H7Hj2IpaResq4Z7QAcTPxskbcV6qa31pujLhgTiC9IuQN6Q1SJJGs4cxBdLXkUDOs)tCHOPRZm1vRzhhbLWfU2gkJvC7kQVcZuxTMDCeucx4ABOmwXR4pBlDDpo(O5D7ksrp1vRzb6tWHaRuze0enLuEvkPb1hlYouP)jgyOcG2shz9v0tD1AwkO)imvXqTp2Hk9pXfIkaAlDK11PUAnlf0FeMQ6v6JDOs)tCHOcG2shzDD9mtD1AwkO)imv1R0h7kQRZm1vRzPG(JWufd1(yxr9vy25AkplgQX3hilLUQMa7ZfH8SGuyc(3dtwUD)yjStbGWS8nwIdxS4dXcCD4hKyHc6pctSCqwGPoolGWJLBNgIf4WYJkHdXYT)ywm93olBqn((aXf5H7Hj2IpaResq4Z7QAcTPxskbcVkCD4hKQuq)rycTiC9IuQNzQRwZsb9hHPkgQ9XUIuyM6Q1Suq)ryQQxPp2vu)UUZ1uEwmuJVpqwkDvnbYf5H7Hj2IpaReskHWS9dH2q8GMQNpOOdRKYO9BknuBi8URQjf9uxTMLc6pctvmu7JDOs)tCHdv6FI76uxTMLc6pctv9k9XouP)jUWHk9pXDDi85DvnzbHxfUo8dsvkO)im1xXqTHW7UQMuC(GIo79Lu9GvWNkuzaQWJQHDkaKce(8UQMSGWRoeWD9dvs5H5I8W9WeBXhGvcj4v2(HqBiEqt1Zhu0Hvsz0(nLgQneE3v1KIEQRwZsb9hHPkgQ9XouP)jUWHk9pXDDQRwZsb9hHPQEL(yhQ0)ex4qL(N4Uoe(8UQMSGWRcxh(bPkf0FeM6RyO2q4DxvtkoFqrN9(sQEWk4tfQmav4r1WofasbcFExvtwq4vhc4U(HkP8WCrE4EyIT4dWkHe8rATp1M2hcTH4bnvpFqrhwjLr73uAO2q4Dxvtk6PUAnlf0FeMQyO2h7qL(N4chQ0)e31PUAnlf0FeMQ6v6JDOs)tCHdv6FI76q4Z7QAYccVkCD4hKQuq)ryQVIHAdH3DvnP48bfD27lP6bRGpvOYaAfEunStbGuGWN3v1KfeE1HaURFOskpmxeYZsbIjwkaWyYcmzjaYIP)2HRJLGhf9jkUipCpmXw8byLqsdobQcB10V1qO9Bk5r1WofaIlc5zPaXeliN(eCiqw2I(5pmlM(BNfpJZIgMOyHs4c1olAhFFIIf0lO)imXINGSCtCwoil6pjw(JLvelM(BNfa4sJ9HfpbzbPXajMBg4I8W9WeBXhGvcjuze0envvycI2VPuVEQRwZsb9hHPkgQ9XouP)jUqLlURtD1AwkO)imv1R0h7qL(N4cvU4(kcqOgeAkTbV(zWouP)jUWcwSIEQRwZgnFjCaFxx9j45hQrln2hlcxViGbqZP4UoZMvsn4GISrZxchW31vFcE(HA0sJ9Xsa31hfrG9731PUAnB08LWb8DD1NGNFOgT0yFSiC9IkujacilURlaHAqOP0g86Nb7qoyCfo(gxxJGMOPqGtXCriplfiMybPXajMBgyX0F7SGuyIaceHeKtFcoeilBr)8hMfpbzbeMO7ybIGgtZFelaWLg7dlWHft7uYsS1qiOEHpwmbxAqwiKf9dXIk1GdXcsJbsm3mWcHSOFimxKhUhMyl(aSsibHpVRQj0MEjPuaSgGj4FpmR4dTiC9IuYmWz9G2ewdGyfi85DvnzdG1amb)7HPIE9cqOgeAkTuzu8HCDfoGPNbYouP)jgykdObKaUNYkd8ZkPgCqrw8NTLUUhhF08EFfeWD9rreOLkJIpKRRWbm9mq976C8nUUgbnrtHkbCkwrpZoxt5zBRjEf2QKELKLsxvtGDDQRwZg86Nbl4A87HzHbiudcnL22AIxHTkPxjzhQ0)edyauFfi85DvnzV9516kMiGOPAY)trp1vRzb6tWHaRuze0enLuEvkPb1hlYUI66mlarqPNNfO4Z7zFfNpOOZEFjvpyf8PcvxTMn41pdwW143dtGVylGSRtfIXkApQ9RouP)jgyQRwZg86Nbl4A87HzxxaIGsppB(O2VAZPUo1vRzv1qiOEHp7ksH6Q1SQAieuVWNDOs)tmWuxTMn41pdwW143dta3d4a8ZkPgCqr2O5lHd476Qpbp)qnAPX(yjG76JIiW(9vyM6Q1SbV(zWUIu0ZSaebLEE28rTF1MtDDbiudcnL2amrabIQ3ovXr)8h2UI66uHySI2JA)Qdv6FIbwac1GqtPnateqGO6TtvC0p)HTdv6FIbmGURR9O2V6qL(NyKlYvzauXatD1A2Gx)mybxJFpm7ZfH8SuGyILBNybaxkV94dlM(BNfNfKgdKyUzGLB3pwECIUJL2alzbaU0yF4I8W9WeBXhGvcjJJGs4cxBdLXkoA)MsQRwZg86Nb7qL(N4cvgnDDQRwZg86Nbl4A87HjWkyXkq4Z7QAYgaRbyc(3dZk(4I8W9WeBXhGvcjbst47DD11pQSKYdTFtje(8UQMSbWAaMG)9WSIpf9mtD1A2Gx)mybxJFpmlSGf31zwaIGspplckV94t)Uo1vRzhhbLWfU2gkJvC7ksH6Q1SJJGs4cxBdLXkUDOs)tmWaoaoatW1F2OHcpMQU(rLLuE27lPkcxVia3Zm1vRzv1qiOEHp7ksHzNRP8S4ZhnCaTu6QAcSpxKhUhMyl(aSsi5ZGpPFpmr73ucHpVRQjBaSgGj4FpmR4Jlc5zbaxFExvtSSWeilWKfx91)9eMLB3pwm55XYbzrLyb7iiqwAWHfKgdKyUzGfmKLB3pwUDkol(q5XIjhFeila4SWhlQudoel3ovYf5H7Hj2IpaResq4Z7QAcTPxskHDeuTbNAWRFgqlcxViLmlaHAqOP0g86Nb7qoy8UoZq4Z7QAYgGjciqufKWXZGIaebLEE28rTF1MtDDGZ6bTjSgaXCriplfiMWSuaGOhlFJLpzXtwqVG(JWelEcYYnpHz5GSO)Ky5pwwrSy6VDwaGln2h0YcsJbsm3mWINGSedqp6EeelBM8PKlYd3dtSfFawjK0wt8kSvj9kj0(nLOG(JWK9ZQNXv4r1WofasH6Q1SrZxchW31vFcE(HA0sJ9XIW1lcya0Ckwrpq4zDqp6EeufBYNYkOx6Oi79bG(evxNzbick98SjfgOgoG9vGWN3v1Kf7iOAdo1Gx)mOON6Q1SJJGs4cxBdLXkUDOs)tmWaoaIEOb4Nvsn4GIS4pBlDDpo(O59(kuxTMDCeucx4ABOmwXTROUoZuxTMDCeucx4ABOmwXTRO(CriplfiMybaFs3olBNpnxRzjAGbmlFJLTZNMR1S84eDhlRiUipCpmXw8byLqc(8P5AnA)MsQRwZct62X1iAcu09W0UIuOUAnl(8P5ATDO2q4DxvtCrE4EyIT4dWkHKGNbsxvxTgAtVKucF(OHdiA)MsQRwZIpF0Wb0ouP)jgyOrrp1vRzPG(JWufd1(yhQ0)exiA66uxTMLc6pctv9k9XouP)jUq00xHJVX11iOjAke4umxeYZsbCvgHzjgyailQudoelifMiGarSSWFIILBNybPWebeiILamb)7HjlhKLWofaILVXcsHjciqelpMfpClxRJZIRcxhlhKfvILGJpUipCpmXw8byLqc(8bVgueA)Msbick98S5JA)QnNuGWN3v1KnateqGOkiHJNbfbiudcnL2amrabIQ3ovXr)8h2ouP)jgyOrHzGZ6bTjSgaXkOG(JWK9ZQNXv44BCDncAIMcnNI5IqEwkqmXY25tZ1Awm93olBhP1(WsbC(2XINGSKqw2oF0WbeTSyANswsilBNpnxRz5XSSIqllXHlw8Hy5twq)v6dlOxq)ryILgCybabymfWSahwoilrdmWcaCPX(WIPDkzXvHiiwaofZsmWaqwGdloyKFpcIfSjFkzz3XSaGamMcywgQ0)8tuSahwEmlFYst)O2pllXeEel3UFSSsqAy52jwWEjXsaMG)9WeZYFOdZcyeMLKw34AwoilBNpnxRzbCnFIIfamockHlmlfGHYyfhTSyANswIdxOdKf89AnlucYYkIft)TZcWPya74iwAWHLBNyr74JfuAOQRXwUipCpmXw8byLqc(8P5AnA)MsNRP8S4J0AFQGZ3olLUQMavy25Akpl(8rdhqlLUQMavOUAnl(8P5ATDO2q4Dxvtk6PUAnlf0FeMQ6v6JDOs)tCHaifuq)ryY(zvVsFuOUAnB08LWb8DD1NGNFOgT0yFSiC9IagartXDDQRwZgnFjCaFxx9j45hQrln2hlcxVOcvcGOPyfo(gxxJGMOPqGtXDDGWZ6GE09iOk2KpLvqV0rr2Hk9pXfcG668W9W06GE09iOk2KpLvqV0rr2pRn9JA)6RiaHAqOP0g86Nb7qL(N4cvUyUiKNLcetSSD(GxdkIfa8jD7SenWaMfpbzbCvgXsmWaqwmTtjlingiXCZalWHLBNybaxkV94dlQRwJLhZIRcxhlhKLMR1SaBnwGdlXHl0bYsWJyjgyaixKhUhMyl(aSsibF(GxdkcTFtj1vRzHjD74Aqt(ur84hM2vuxN6Q1Sa9j4qGvQmcAIMskVkL0G6JfzxrDDQRwZg86Nb7ksrp1vRzhhbLWfU2gkJvC7qL(NyGHkaAlDKb8b619C8nUUgbnrdYTGf3hWfe4pxt5ztYuTectlLUQMavy2SsQbhuKf)zBPR7XXhnVRqD1A2XrqjCHRTHYyf3UI66uxTMn41pd2Hk9pXadva0w6id4d0R754BCDncAIgKBblUFxN6Q1SJJGs4cxBdLXkEf)zBPR7XXhnVBxrDDMPUAn74iOeUW12qzSIBxrkmlaHAqOP0oockHlCTnugR42HCW4DDMfGiO0ZZIGYBp(0VRZX346Ae0enfcCkwbf0FeMSFw9moxeYZI5N4SCqwkDGiwUDIfvcFSaBSSD(OHdilQXzbFEaOprXYFSSIyb4U(aq64S8jlEgNf0lO)imXI66ybaU0yFy5X5XIRcxhlhKfvILObgceixKhUhMyl(aSsibF(GxdkcTFtPZ1uEw85JgoGwkDvnbQWSzLudoOi79LKj4KvWH8s1pbPrrp1vRzXNpA4aAxrDDo(gxxJGMOPqGtX9vOUAnl(8rdhql(8aqaRGk6PUAnlf0FeMQyO2h7kQRtD1AwkO)imv1R0h7kQVc1vRzJMVeoGVRR(e88d1OLg7JfHRxeWaiGSyf9cqOgeAkTbV(zWouP)jUqLlURZme(8UQMSbyIacevbjC8mOiarqPNNnFu7xT5uFUiKNf0dFFPFeMLDOjwkxHDwIbgaYIpelO8pjqwIOHfmfGjixKhUhMyl(aSsibHpVRQj0MEjPKJJaG0Srb0IW1lsjkO)imz)SQxPpapac56H7HPfF(0(HSeYOW6O69LeGnJc6pct2pR6v6dW3dqd4Z1uEwmCPRWw92PAdoe(Su6QAce4lyFKRhUhMwtJF7wczuyDu9(scWfBnh0GCXrKwx3D8raUylAa(Z1uE20V1q4QQR9mqwkDvnbYfH8SuaxLrSSD(GxdkILpzXzbqcymfyzdQ9Hf0lO)imHwwaHj6ow00XYFSenWalaWLg7dl9UD)y5XSS7jOMazrnol0F70WYTtSSD(0CTMf9NelWHLBNyjgyayHaNIzr)jXsdoSSD(GxdkQpAzbeMO7ybIGgtZFelEYca(KUDwIgyGfpbzrthl3oXIRcrqSO)Kyz3tqnXY25JgoGCrE4EyIT4dWkHe85dEnOi0(nLmBwj1GdkYEFjzcozfCiVu9tqAu0tD1A2O5lHd476Qpbp)qnAPX(yr46fbmacilURtD1A2O5lHd476Qpbp)qnAPX(yr46fbmaIMIvCUMYZIpsR9PcoF7Su6QAcSVIEuq)ryY(zfd1(OWX346Ae0enagHpVRQjRJJaG0SrbGxD1AwkO)imvXqTp2Hk9pXageE22AIxHTkPxjzVpaeUouP)jWdqlAkeavCxhf0FeMSFw1R0hfo(gxxJGMObWi85DvnzDCeaKMnka8QRwZsb9hHPQEL(yhQ0)edyq4zBRjEf2QKELK9(aq46qL(NapaTOPqGtX9vyM6Q1SWKUDCnIMafDpmTRifMDUMYZIpF0Wb0sPRQjqf9cqOgeAkTbV(zWouP)jUqazxhgU0QFcAV9516kMiGOXsPRQjqfQRwZE7ZR1vmrarJfFEaiGvWcci6nRKAWbfzXF2w66EC8rZ7apA6RO9O2V6qL(N4cvU4Iv0Eu7xDOs)tmWayXf3xrVaeQbHMslqFcoeyfh9ZFy7qL(N4cbKDDMfGiO0ZZcu859SpxeYZsbIjwaWcHjMLpzb9xPpSGEb9hHjw8eKfSJGyb5mUUb4cWsRzbaleMS0GdlingiXCZalEcYcYPpbhcKf0RmcAIMskpUipCpmXw8byLqssMQLqyI2VPup1vRzPG(JWuvVsFSdv6FIlKqgfwhvVVK666f29bfHvcGkgkS7dkQEFjbm00VRlS7dkcRub7RWJQHDkaKce(8UQMSyhbvBWPg86NbUipCpmXw8byLqYURB1simr73uQN6Q1Suq)ryQQxPp2Hk9pXfsiJcRJQ3xskmlarqPNNfO4Z7zxxp1vRzb6tWHaRuze0enLuEvkPb1hlYUIueGiO0ZZcu859SFxxVWUpOiSsauXqHDFqr17ljGHM(DDHDFqryLkyxN6Q1SbV(zWUI6RWJQHDkaKce(8UQMSyhbvBWPg86Nbf9uxTMDCeucx4ABOmwXTdv6FIbwp0aiaiWpRKAWbfzXF2w66EC8rZ79vOUAn74iOeUW12qzSIBxrDDMPUAn74iOeUW12qzSIBxr95I8W9WeBXhGvcjTLwxlHWeTFtPEQRwZsb9hHPQEL(yhQ0)exiHmkSoQEFjPWSaebLEEwGIpVNDD9uxTMfOpbhcSsLrqt0us5vPKguFSi7ksraIGspplqXN3Z(DD9c7(GIWkbqfdf29bfvVVKagA631f29bfHvQGDDQRwZg86Nb7kQVcpQg2Paqkq4Z7QAYIDeuTbNAWRFgu0tD1A2XrqjCHRTHYyf3ouP)jgyOrH6Q1SJJGs4cxBdLXkUDfPWSzLudoOil(Z2sx3JJpAEVRZm1vRzhhbLWfU2gkJvC7kQpxeYZsbIjwqoGOhlWKLaixKhUhMyl(aSsiXKpZdNkSvj9kjUiKNLcetSSD(0(Hy5GSenWalBqTpSGEb9hHj0YcsJbsm3mWYUJzrtyml3xsSC7EYIZcYX43oleYOW6iw0u7yboSatDCwq)v6dlOxq)ryILhZYkIlYd3dtSfFawjKGpFA)qO9Bkrb9hHj7Nv9k9PRJc6pctwmu7tnjKDDDuq)ryY6z8Asi7666PUAnRjFMhovyRs6vs2vuxhoI066UJpcyfBnh0OWSaebLEEweuE7XNUoCeP11DhFeWk2Aokcqeu65zrq5ThF6RqD1AwkO)imv1R0h7kQRRN6Q1SbV(zWouP)jgyE4EyAnn(TBjKrH1r17ljfQRwZg86Nb7kQpxeYZsbIjwqog)2zbE70y6XelM2)WolpMLpzzdQ9Hf0lO)imHwwqAmqI5MbwGdlhKLObgyb9xPpSGEb9hHjUipCpmXw8byLqIPXVDUiKNLcGR13(S4I8W9WeBXhGvcjZkRE4Eyw1p(qB6LKsnxRV9zzSHJOGrmvUyaACgNHb]] )


end