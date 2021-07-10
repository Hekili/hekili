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


    spec:RegisterPack( "Balance", 20210710, [[deLEIfqikjpcIuxcIK2ej8jivgLuLtjv1Qau1RauMfKs3ca0UO4xqedtKQJrISma0ZekAAusX1GuSnav8naHghGGZbiY6ae18aKUhjQ9js6FqKO0bfjSqHcpeIYefkLUiKQSrHsXhHir1iHirXjPKsRuKYlHirMjKQ6MaqYofk5NaqQHca1sbGWtvQMkLuDvHs1wbGiFfIeglaWEPu)vudM4WuTys6XcMmqxgzZs5ZqYOvkNwvRgaI61a0Sj1TLk7wYVbnCHCCavA5kEoutxLRRKTdHVtjgpevNxOA9IenFrSFuBRKT1T3b9JSJfathGkLoquP0nkznaeGXeizVFXJi79ipaOJIS3lVJS3JHR9kq27rECn0bTTU9ogUMazVVDxegiJeKO6AVceae)DbdQ)2wQMhIKy4AVceaC)7qgs6anBxNgPSTxtkR6AVcK5q(zVRUE9zTLTQ9oOFKDSay6auP0bIkLUrjRbGaeGkzV7RBdo277FhYS33EqqQSvT3bjCWEpgU2RaXsSDwpiNwAlDCwukD0YcathGkXPXPHSnVqryGmNgaKLuacsGSSd1(WsmiVZWPbazbzBEHIaz58bfD5VXsWXeMLdYsiEqt5Zhu0HnCAaqwaqqDqeeilRQOaHX(eNfe(8UQMWS07nKbTSeneIm(8bVguelaWuzjAieg85dEnOO(gonailPab8bzjAOGJVVqXcsX43glFJL)qhMLBJyXYaluSGEb9hHjdNgaKfauoGelidwiGasSCBel7r)8hMfNf9FNMyPdoelnnH8xvtS07BSehUyzZbl0DSS9hl)Xc(7w6ZlcUW64Sy5VnwIba6uyDwagliJ0e(ExZsk0pQQJQdTS8h6azbd4h13WPbazbaLdiXsheFSGU2JA7Yd15FHrhl4av(8qmlEuKoolhKfvigZs7rTDywGLoUHtdaYI1hYpwSoSJyb2yjgAFJLyO9nwIH23yXXS4SGJOW7AwU5laPZyVRF8HTTU9oi18L(STUDSuY2627E4EyzVJHAFYQK3zVtLRQjq7yyF2XcG2w3ENkxvtG2XWEhgzVJPZE3d3dl7De(8UQMS3r46fzVJJiToF(GIoSbF(0CTMLuzrjwuWspwSILZ1uDg85JgoGgQCvnbYssclNRP6m4J0AFYGZ3odvUQMazPpljjSGJiToF(GIoSbF(0CTMLuzbG27GeomF09WYEFNomlPaIESalwIjWyXYFBW1Xc48TJfVazXYFBSSF(OHdilEbYcabglWBJglpMS3r4tU8oYE)Xzhs2NDSIPT1T3PYv1eODmS3Hr27y6S39W9WYEhHpVRQj7DeUEr274isRZNpOOdBWNpTFiwsLfLS3bjCy(O7HL9(oDywcAYrqSyzJkw2pFA)qSe8ILT)ybGaJLZhu0HzXY2h2y5XSmKMq41XsdoSCBelOxq)ryILdYIkXs0qnAgcKfVazXY2h2yP9AnnSCqwco(S3r4tU8oYE)X5GMCeK9zhlRX2627u5QAc0og27E4EyzVRsdMga)cL9oiHdZhDpSS3JDmXsmObtdGFHIfl)TXcYsbsS2kWcCyXBhnSGmyHaciXYxSGSuGeRTc27H5pAE3EVhlwXsaIGkVot9O2UCZjwssyXkwcqOgeAPmbyHaciLVnkJJ(5pSzfXsFwuWI6Q1mbp)vWmuN)fMLuzrj0WIcwuxTMzCeubx4CBOkLXnd15FHzbOSynSOGfRyjarqLxNbbv3w8HLKewcqeu51zqq1TfFyrblQRwZe88xbZkIffSOUAnZ4iOcUW52qvkJBwrSOGLESOUAnZ4iOcUW52qvkJBgQZ)cZcqzrjLybaYcAyb4zzwf1GdkYG)QT05T44JM3nu5QAcKLKewuxTMj45VcMH68VWSauwusjwssyrjwqcl4isRZBo(iwaklkzqdAyPV9zhl0yBD7DQCvnbAhd79W8hnVBVRUAntWZFfmd15FHzjvwucnSOGLESyflZQOgCqrg8xTLoVfhF08UHkxvtGSKKWI6Q1mJJGk4cNBdvPmUzOo)lmlaLfLaISaazbGSa8SOUAnJQgcb1l8zwrSOGf1vRzghbvWfo3gQszCZkIL(SKKWIkeJzrblTh12LhQZ)cZcqzbGOXEhKWH5JUhw27ay4XIL)2yXzbzPajwBfy528JLhxO7yXzbaV0yFyjAGbwGdlw2OILBJyP9O2owEmlUkCDSCqwOc0E3d3dl79i49WY(SJfWX2627u5QAc0og27Wi7DmD27E4EyzVJWN3v1K9ocxVi79a9Aw6XspwApQTlpuN)fMfailkHgwaGSeGqni0szcE(RGzOo)lml9zbjSOeqiDw6ZIYSeOxZspw6Xs7rTD5H68VWSaazrj0WcaKfLay6SaazjaHAqOLYeGfciGu(2Omo6N)WMH68VWS0NfKWIsaH0zPplkyXkwg)bZecQoJdcIneYF8HzjjHLaeQbHwktWZFfmd15FHzjvw(6OjcQ9JaZTh12LhQZ)cZssclbiudcTuMaSqabKY3gLXr)8h2muN)fMLuz5RJMiO2pcm3EuBxEOo)lmlaqwukDwssyXkwcqeu51zQh12LBoXssclE4EyzcWcbeqkFBugh9ZFyd4JDvnbAVds4W8r3dl7DK56Ws7hHzXYgDB0WYc)fkwqgSqabKyPGwyXYR1S4An0clXHlwoil471Awco(y52iwWEhXI3bx1XcSXcYGfciGeWqwkqI1wbwco(W27i8jxEhzVhGfciGugKWXRG9zhlGOT1T3PYv1eODmS3Hr27y6S39W9WYEhHpVRQj7DeUEr279yP9O2U8qD(xywsLfLqdljjSm(dMjeuDgheeB(ILuzbnPZsFwuWspw6XspwiG76JIiqd1ffFixNHdy5vGyrbl9yPhlbiudcTugQlk(qUodhWYRazgQZ)cZcqzrjGt6SKKWsaIGkVodcQUT4dlkyjaHAqOLYqDrXhY1z4awEfiZqD(xywaklkbCaISamw6XIskXcWZYSkQbhuKb)vBPZBXXhnVBOYv1eil9zPplkyXkwcqOgeAPmuxu8HCDgoGLxbYmKdgNL(S0NLKew6XcbCxFuebAWWLwt39fQ8SuJZIcw6XIvSeGiOYRZupQTl3CILKewcqOgeAPmy4sRP7(cvEwQXZX0AqdqiDLmd15FHzbOSOKswdl9zPpljjS0JLaeQbHwkJknyAa8luMHCW4SKKWIvSmEGm3a1Aw6ZIcw6XspwiG76JIiqZx4WSoxvtzG7YRB1LbjeFGyrblbiudcTuMVWHzDUQMYa3Lx3Qldsi(azgYbJZsFwssyPhleWD9rreObV5GqleygoQzylFWPJQJffSeGqni0szo40r1rG5VWpQTlht0GMycqLmd15FHzPpljjS0JLESGWN3v1Kbw5fMY38fG0XIYSOeljjSGWN3v1Kbw5fMY38fG0XIYSetw6ZIcw6XYnFbiDMtjZqoy8Cac1GqlfljjSCZxasN5uYeGqni0szgQZ)cZsQS81rteu7hbMBpQTlpuN)fMfailkLol9zjjHfe(8UQMmWkVWu(MVaKowuMfaYIcw6XYnFbiDMdGMHCW45aeQbHwkwssy5MVaKoZbqtac1GqlLzOo)lmlPYYxhnrqTFeyU9O2U8qD(xywaGSOu6S0NLKewq4Z7QAYaR8ct5B(cq6yrzwsNL(S0NL(SKKWsaIGkVodGXN3lw6ZssclQqmMffS0EuBxEOo)lmlaLf1vRzcE(RGbCn(9WYEhKWH5JUhw27XoMaz5GSasApol3gXYc7OiwGnwqwkqI1wbwSSrfll8xOybeUu1elWILfMyXlqwIgcbvhllSJIyXYgvS4floiilecQowEmlUkCDSCqwaFYEhHp5Y7i79ayoalW)EyzF2XciyBD7DQCvnbAhd7DyK9oMo7DpCpSS3r4Z7QAYEhHRxK9UvSGHlT6xGMBBEToJjcqAmu5QAcKLKewApQTlpuN)fMLuzbGPNoljjSOcXywuWs7rTD5H68VWSauwaiAybyS0JfRjDwaGSOUAnZTnVwNXebing85bazb4zbGS0NLKewuxTM52MxRZyIaKgd(8aGSKklXeiWcaKLESmRIAWbfzWF1w68wC8rZ7gQCvnbYcWZcAyPV9oiHdZhDpSS3bqYN3v1ellmbYYbzbK0ECw8kol38fG0HzXlqwcGywSSrflw8)(cfln4WIxSGEROn48olrdmyVJWNC5DK9(TnVwNXebinzl(F2NDSas2w3ENkxvtG2XWEhKWH5JUhw27XoMyb96IIpKRzba9awEfiway6ykGzrLAWHyXzbzPajwBfyzHjJ9E5DK9o1ffFixNHdy5vGS3dZF08U9Eac1GqlLj45VcMH68VWSauway6SOGLaeQbHwktawiGas5BJY4OF(dBgQZ)cZcqzbGPZIcw6XccFExvtMBBEToJjcqAYw8)yjjHf1vRzUT516mMiaPXGppailPYsmtNfGXspwMvrn4GIm4VAlDElo(O5DdvUQMazb4zb4WsFw6ZssclQqmMffS0EuBxEOo)lmlaLLyceT39W9WYEN6IIpKRZWbS8kq2NDSukDBRBVtLRQjq7yyVds4W8r3dl79yhtSSdxAnDFHIfael14SaCWuaZIk1GdXIZcYsbsS2kWYctg79Y7i7DmCP10DFHkpl1427H5pAE3EpaHAqOLYe88xbZqD(xywaklahwuWIvSeGiOYRZGGQBl(WIcwSILaebvEDM6rTD5MtSKKWsaIGkVot9O2UCZjwuWsac1GqlLjaleqaP8TrzC0p)Hnd15FHzbOSaCyrbl9ybHpVRQjtawiGaszqchVcSKKWsac1GqlLj45VcMH68VWSauwaoS0NLKewcqeu51zqq1TfFyrbl9yXkwMvrn4GIm4VAlDElo(O5DdvUQMazrblbiudcTuMGN)kygQZ)cZcqzb4WssclQRwZmocQGlCUnuLY4MH68VWSauwuYAybyS0Jf0WcWZcbCxFuebA(cFZkCWbNbFeFrzvsRzPplkyrD1AMXrqfCHZTHQug3SIyPpljjSOcXywuWs7rTD5H68VWSauwaiAS39W9WYEhdxAnD3xOYZsnU9zhlLuY2627u5QAc0og27E4EyzV)fomRZv1ug4U86wDzqcXhi79W8hnVBVRUAntWZFfmd15FHzjvwucnSOGLESyflZQOgCqrg8xTLoVfhF08UHkxvtGSKKWI6Q1mJJGk4cNBdvPmUzOo)lmlaLfLailaJLESetwaEwuxTMrvdHG6f(mRiw6ZcWyPhl9ybiYcaKf0WcWZI6Q1mQAieuVWNzfXsFwaEwiG76JIiqZx4BwHdo4m4J4lkRsAnl9zrblQRwZmocQGlCUnuLY4Mvel9zjjHfvigZIcwApQTlpuN)fMfGYcarJ9E5DK9(x4WSoxvtzG7YRB1LbjeFGSp7yPeaTTU9ovUQMaTJH9oiHdZhDpSS3JDmXY8O2owuPgCiwcGy79Y7i7D8MdcTqGz4OMHT8bNoQo79W8hnVBV3JLaeQbHwktWZFfmd5GXzrblwXsaIGkVot9O2UCZjwuWccFExvtMBBEToJjcqAYw8)yjjHLaebvEDM6rTD5MtSOGLaeQbHwktawiGas5BJY4OF(dBgYbJZIcw6XccFExvtMaSqabKYGeoEfyjjHLaeQbHwktWZFfmd5GXzPpl9zrblGWZGxv7hYCFaWVqXIcw6Xci8m4J0AFYnTpK5(aGFHILKewSILZ1uDg8rATp5M2hYqLRQjqwssybhrAD(8bfDyd(8P9dXsQSetw6ZIcw6Xci8mDqy1(Hm3ha8luS0NffS0Jfe(8UQMmpo7qILKewMvrn4GImQU2RaLHTSR15B7luydvUQMazjjHfhFJRZrql0WsQkZcqkDwssyrD1AgvnecQx4ZSIyPplkyPhlbiudcTugvAW0a4xOmd5GXzjjHfRyz8azUbQ1S0NLKewuHymlkyP9O2U8qD(xywaklwt627E4EyzVJ3CqOfcmdh1mSLp40r1zF2XsPyABD7DQCvnbAhd7DqchMp6EyzVB9ThZYJzXzz8BJgwiTRch)iwS4Xz5GS05asS4AnlWILfMybF(XYnFbiDywoilQel6ViqwwrSy5VnwqwkqI1wbw8cKfKbleqajw8cKLfMy52iwaybYcwdpwGflbqw(glQWBJLB(cq6WS4dXcSyzHjwWNFSCZxash2Epm)rZ727i85DvnzGvEHP8nFbiDSOmlaKffSyfl38fG0zoaAgYbJNdqOgeAPyjjHLESGWN3v1Kbw5fMY38fG0XIYSOeljjSGWN3v1Kbw5fMY38fG0XIYSetw6ZIcw6XI6Q1mbp)vWSIyrbl9yXkwcqeu51zqq1TfFyjjHf1vRzghbvWfo3gQszCZqD(xywagl9ybnSa8SmRIAWbfzWF1w68wC8rZ7gQCvnbYsFwaQYSCZxasN5uYOUATm4A87HflkyrD1AMXrqfCHZTHQug3SIyjjHf1vRzghbvWfo3gQsz8m(R2sN3IJpAE3SIyPpljjSeGqni0szcE(RGzOo)lmlaJfaYsQSCZxasN5uYeGqni0szaxJFpSyrblwXI6Q1mbp)vWSIyrbl9yXkwcqeu51zQh12LBoXssclwXccFExvtMaSqabKYGeoEfyPplkyXkwcqeu51zam(8EXssclbicQ86m1JA7YnNyrbli85DvnzcWcbeqkds44vGffSeGqni0szcWcbeqkFBugh9ZFyZkIffSyflbiudcTuMGN)kywrSOGLES0Jf1vRzOG(JWuwVkFmd15FHzjvwukDwssyrD1AgkO)imLXqTpMH68VWSKklkLol9zrblwXYSkQbhuKr11EfOmSLDToFBFHcBOYv1eiljjS0Jf1vRzuDTxbkdBzxRZ32xOW5YV1qg85bazrzwqdljjSOUAnJQR9kqzyl7AD(2(cfo7tWlYGppailkZcqGL(S0NLKewuxTMbWVahcmtDrql00r1LPIguFkjZkIL(SKKWs7rTD5H68VWSauway6SKKWccFExvtgyLxykFZxashlkZs627yn8W2738fG0PK9UhUhw2738fG0PK9zhlLSgBRBVtLRQjq7yyV7H7HL9(nFbiDa0Epm)rZ727i85DvnzGvEHP8nFbiDSyLYSaqwuWIvSCZxasN5uYmKdgphGqni0sXsscli85DvnzGvEHP8nFbiDSOmlaKffS0Jf1vRzcE(RGzfXIcw6XIvSeGiOYRZGGQBl(WssclQRwZmocQGlCUnuLY4MH68VWSamw6XcAyb4zzwf1GdkYG)QT05T44JM3nu5QAcKL(SauLz5MVaKoZbqJ6Q1YGRXVhwSOGf1vRzghbvWfo3gQszCZkILKewuxTMzCeubx4CBOkLXZ4VAlDElo(O5DZkIL(SKKWsac1GqlLj45VcMH68VWSamwailPYYnFbiDMdGMaeQbHwkd4A87HflkyXkwuxTMj45VcMvelkyPhlwXsaIGkVot9O2UCZjwssyXkwq4Z7QAYeGfciGugKWXRal9zrblwXsaIGkVodGXN3lwuWspwSIf1vRzcE(RGzfXssclwXsaIGkVodcQUT4dl9zjjHLaebvEDM6rTD5MtSOGfe(8UQMmbyHaciLbjC8kWIcwcqOgeAPmbyHaciLVnkJJ(5pSzfXIcwSILaeQbHwktWZFfmRiwuWspw6XI6Q1muq)rykRxLpMH68VWSKklkLoljjSOUAndf0FeMYyO2hZqD(xywsLfLsNL(SOGfRyzwf1GdkYO6AVcug2YUwNVTVqHnu5QAcKLKew6XI6Q1mQU2RaLHTSR15B7lu4C53Aid(8aGSOmlOHLKewuxTMr11EfOmSLDToFBFHcN9j4fzWNhaKfLzbiWsFw6ZsFwssyrD1Aga)cCiWm1fbTqthvxMkAq9PKmRiwssyP9O2U8qD(xywaklamDwssybHpVRQjdSYlmLV5laPJfLzjD7DSgEy79B(cq6aO9zhlLqJT1T3PYv1eODmS3bjCy(O7HL9ESJjmlUwZc82OHfyXYctS8h1HzbwSeaT39W9WYEFHP8Fuh2(SJLsahBRBVtLRQjq7yyVds4W8r3dl79ylfEqIfpCpSyr)4JfvhtGSalwW)T87Hfs0eQhBV7H7HL9(SQShUhwz9Jp7D8nF4SJLs27H5pAE3EhHpVRQjZJZoKS31p(YL3r27oKSp7yPeq02627u5QAc0og27H5pAE3EFwf1GdkYO6AVcug2YUwNVTVqHneWD9rreO9o(MpC2Xsj7DpCpSS3NvL9W9WkRF8zVRF8LlVJS3vH(zF2XsjGGT1T3PYv1eODmS39W9WYEFwv2d3dRS(XN9U(XxU8oYEhF2N9zVRc9Z262XsjBRBVtLRQjq7yyV7H7HL9(4iOcUW52qvkJBVds4W8r3dl79yZqvkJZIL)2ybzPajwBfS3dZF08U9U6Q1mbp)vWmuN)fMLuzrj0yF2XcG2w3ENkxvtG2XWE3d3dl7Dh0JUhbLXw8PZEpepOP85dk6W2Xsj79W8hnVBVRUAnJQR9kqzyl7AD(2(cfox(TgYGppailaLfGalkyrD1Agvx7vGYWw2168T9fkC2NGxKbFEaqwaklabwuWspwSIfq4zCqp6EeugBXNUmO35OiZ9ba)cflkyXkw8W9WY4GE09iOm2IpDzqVZrrMVYn9JA7yrbl9yXkwaHNXb9O7rqzSfF6YBKRn3ha8luSKKWci8moOhDpckJT4txEJCTzOo)lmlPYsmzPpljjSacpJd6r3JGYyl(0Lb9ohfzWNhaKfGYsmzrblGWZ4GE09iOm2IpDzqVZrrMH68VWSauwqdlkybeEgh0JUhbLXw8Pld6DokYCFaWVqXsF7DqchMp6EyzVh7yILua6r3JGyz3IpDSyzJkw8JfnHXSCBEXI1WsmGPW6SGppaiMfVaz5GSmuBi8glolavzaYc(8aGS4yw0(rS4ywIGy8RQjwGdl33rS8hlyil)XIpZJGWSaG8cFS4TJgwCwIjWybFEaqwiKh9dHTp7yftBRBVtLRQjq7yyV7H7HL9EawiGas5BJY4OF(dBVds4W8r3dl79yhtSGmyHaciXIL)2ybzPajwBfyXYgvSebX4xvtS4filWBJglpMyXYFBS4SedykSolQRwJflBuXciHJxHVqzVhM)O5D7DRybCwpOPG5aiMffS0JLESGWN3v1KjaleqaPmiHJxbwuWIvSeGqni0szcE(RGzihmoljjSOUAntWZFfmRiw6ZIcw6XI6Q1mQU2RaLHTSR15B7lu4C53Aid(8aGSOmlabwssyrD1Agvx7vGYWw2168T9fkC2NGxKbFEaqwuMfGal9zjjHfvigZIcwApQTlpuN)fMfGYIsPZsF7ZowwJT1T3PYv1eODmS39W9WYEVTM4zylt6vr27GeomF09WYEp2arpwCml3gXs7h8XcQailFXYTrS4SedykSolw(ceAHf4WIL)2y52iwqkfFEVyrD1ASahwS83glolabGHPalPa0JUhbXYUfF6yXlqwS4)XsdoSGSuGeRTcS8nw(JflW6yrLyzfXIJY)IfvQbhILBJyjaYYJzP91J3iq79W8hnVBV3JLES0Jf1vRzuDTxbkdBzxRZ32xOW5YV1qg85bazjvwaoSKKWI6Q1mQU2RaLHTSR15B7lu4SpbVid(8aGSKklahw6ZIcw6XIvSeGiOYRZGGQBl(WssclwXI6Q1mJJGk4cNBdvPmUzfXsFw6ZIcw6Xc4SEqtbZbqmljjSeGqni0szcE(RGzOo)lmlPYcAsNLKew6XsaIGkVot9O2UCZjwuWsac1GqlLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NL(S0NLKew6Xci8moOhDpckJT4txg07CuKzOo)lmlPYcqGffSeGqni0szcE(RGzOo)lmlPYIsPZIcwcqeu51zkkmqnCazPpljjSOcXywuWYxhnrqTFeyU9O2U8qD(xywaklabwuWIvSeGqni0szcE(RGzihmoljjSeGiOYRZay859IffSOUAndGFboeyM6IGwOPJQZSIyjjHLaebvEDgeuDBXhwuWI6Q1mJJGk4cNBdvPmUzOo)lmlaLfGelkyrD1AMXrqfCHZTHQug3SISp7yHgBRBVtLRQjq7yyV7H7HL9EWRaPZQRwZEpm)rZ7279yrD1Agvx7vGYWw2168T9fkCU8BnKzOo)lmlPYcq0GgwssyrD1Agvx7vGYWw2168T9fkC2NGxKzOo)lmlPYcq0Ggw6ZIcw6Xsac1GqlLj45VcMH68VWSKklarwssyPhlbiudcTugQlcAHMSkSand15FHzjvwaISOGfRyrD1Aga)cCiWm1fbTqthvxMkAq9PKmRiwuWsaIGkVodGXN3lw6ZsFwuWIJVX15iOfAyjvLzjMPBVRUATC5DK9o(8rdhq7DqchMp6EyzVJmVcKML9ZhnCazXYFBS4SuKfwIbmfwNf1vRXIxGSGSuGeRTcS84cDhlUkCDSCqwujwwyc0(SJfWX2627u5QAc0og27E4EyzVJpFWRbfzVds4W8r3dl79y7QlIL9Zh8AqrywS83glolXaMcRZI6Q1yrDDSuWJflBuXseeQ)cfln4WcYsbsS2kWcCybP0xGdbYYE0p)HT3dZF08U9EpwuxTMr11EfOmSLDToFBFHcNl)wdzWNhaKLuzbGSKKWI6Q1mQU2RaLHTSR15B7lu4SpbVid(8aGSKklaKL(SOGLESeGiOYRZupQTl3CILKewcqOgeAPmbp)vWmuN)fMLuzbiYssclwXccFExvtMayoalW)EyXIcwSILaebvEDgaJpVxSKKWspwcqOgeAPmuxe0cnzvybAgQZ)cZsQSaezrblwXI6Q1ma(f4qGzQlcAHMoQUmv0G6tjzwrSOGLaebvEDgaJpVxS0NL(SOGLESyflGWZ0wt8mSLj9QiZ9ba)cfljjSyflbiudcTuMGN)kygYbJZssclwXsac1GqlLjaleqaP8TrzC0p)Hnd5GXzPV9zhlGOT1T3PYv1eODmS39W9WYEhF(GxdkYEhKWH5JUhw27X2vxel7Np41GIWSOsn4qSGmyHacizVhM)O5D79ESeGqni0szcWcbeqkFBugh9ZFyZqD(xywaklOHffSyflGZ6bnfmhaXSOGLESGWN3v1KjaleqaPmiHJxbwssyjaHAqOLYe88xbZqD(xywaklOHL(SOGfe(8UQMmbWCawG)9WIL(SOGfRybeEM2AINHTmPxfzUpa4xOyrblbicQ86m1JA7YnNyrblwXc4SEqtbZbqmlkyHc6pctMVYEfNffS44BCDocAHgwsLfRjD7ZowabBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS37XI6Q1mJJGk4cNBdvPmUzOo)lmlPYcAyjjHfRyrD1AMXrqfCHZTHQug3SIyPplkyPhlQRwZa4xGdbMPUiOfA6O6YurdQpLKzOo)lmlaLfubqtNJCw6ZIcw6XI6Q1muq)rykJHAFmd15FHzjvwqfanDoYzjjHf1vRzOG(JWuwVkFmd15FHzjvwqfanDoYzPV9oiHdZhDpSS3JTWcDhlGWJfW18fkwUnIfQazb2ybaHJGk4cZsSzOkLXrllGR5luSa4xGdbYc1fbTqthvhlWHLVy52iw0o(ybvaKfyJfVyb9c6pct27i8jxEhzVdcV8qa31puhvh2(SJfqY2627u5QAc0og27E4EyzVJxv7hYEpm)rZ727d1gcV5QAIffSC(GIoZ9Du(GzWNyjvwuc4WIcw8OCyJcaYIcwq4Z7QAYacV8qa31puhvh2EpepOP85dk6W2Xsj7ZowkLUT1T3PYv1eODmS39W9WYEVdcR2pK9Ey(JM3T3hQneEZv1elky58bfDM77O8bZGpXsQSOumnOHffS4r5WgfaKffSGWN3v1KbeE5HaURFOoQoS9EiEqt5Zhu0HTJLs2NDSusjBRBVtLRQjq7yyV7H7HL9o(iT2NCt7dzVhM)O5D79HAdH3CvnXIcwoFqrN5(okFWm4tSKklkbCybySmuN)fMffS4r5WgfaKffSGWN3v1KbeE5HaURFOoQoS9EiEqt5Zhu0HTJLs2NDSucG2w3ENkxvtG2XWE3d3dl79gCcug2YLFRHS3bjCy(O7HL9ESbglwGflbqwS83gCDSe8OOVqzVhM)O5D7Dpkh2OaG2NDSukM2w3ENkxvtG2XWE3d3dl7DQlcAHMSkSaT3bjCy(O7HL9o61fbTqdlXawGSyzJkwCv46y5GSq1rdlolfzHLyatH1zXYxGqlS4filyhbXsdoSGSuGeRTc27H5pAE3EVhluq)ryYOxLp5Iq(Xsscluq)ryYGHAFYfH8JLKewOG(JWKXR45Iq(XssclQRwZO6AVcug2YUwNVTVqHZLFRHmd15FHzjvwaIg0WssclQRwZO6AVcug2YUwNVTVqHZ(e8Imd15FHzjvwaIg0Wssclo(gxNJGwOHLuzbiLolkyjaHAqOLYe88xbZqoyCwuWIvSaoRh0uWCaeZsFwuWspwcqOgeAPmbp)vWmuN)fMLuzjMPZssclbiudcTuMGN)kygYbJZsFwssyrfIXSOGLVoAIGA)iWC7rTD5H68VWSauwukD7Zowkzn2w3ENkxvtG2XWE3d3dl792AINHTmPxfzVds4W8r3dl79yde9yzEuBhlQudoell8xOybzPWEpm)rZ727biudcTuMGN)kygYbJZIcwq4Z7QAYeaZbyb(3dlwuWspwC8nUohbTqdlPYcqkDwuWIvSeGiOYRZupQTl3CILKewcqeu51zQh12LBoXIcwC8nUohbTqdlaLfRjDw6ZIcwSILaebvEDgeuDBXhwuWspwSILaebvEDM6rTD5MtSKKWsac1GqlLjaleqaP8TrzC0p)Hnd5GXzPplkyXkwaN1dAkyoaITp7yPeASTU9ovUQMaTJH9omYEhtN9UhUhw27i85DvnzVJW1lYE3kwaN1dAkyoaIzrbli85DvnzcG5aSa)7HflkyPhl9yXX346Ce0cnSKklaP0zrbl9yrD1Aga)cCiWm1fbTqthvxMkAq9PKmRiwssyXkwcqeu51zam(8EXsFwssyrD1AgvnecQx4ZSIyrblQRwZOQHqq9cFMH68VWSauwuxTMj45VcgW143dlw6ZssclFD0eb1(rG52JA7Yd15FHzbOSOUAntWZFfmGRXVhwSKKWsaIGkVot9O2UCZjw6ZIcw6XIvSeGiOYRZupQTl3CILKew6XIJVX15iOfAybOSynPZssclGWZ0wt8mSLj9QiZ9ba)cfl9zrbl9ybHpVRQjtawiGaszqchVcSKKWsac1GqlLjaleqaP8TrzC0p)Hnd5GXzPpl9T3bjCy(O7HL9oYsbsS2kWILnQyXpwasPdmwsbgaZsp4OHwOHLBZlwSM0zjfyamlw(BJfKbleqaP(Sy5Vn46yrdXFHIL77iw(ILyOHqq9cFS4fil6ViwwrSy5VnwqgSqabKy5BS8hlwCmlGeoEfiq7De(KlVJS3dG5aSa)7Hvwf6N9zhlLao2w3ENkxvtG2XWEpm)rZ727i85DvnzcG5aSa)7Hvwf6N9UhUhw27bst47DD21pQQJQZ(SJLsarBRBVtLRQjq7yyVhM)O5D7De(8UQMmbWCawG)9WkRc9ZE3d3dl79Vc(u(9WY(SJLsabBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS3PG(JWK5RSEv(WcWZcqGfKWIhUhwg85t7hYqiNcRJY33rSamwSIfkO)imz(kRxLpSa8S0JfGdlaJLZ1uDgmCPZWw(2OCdoe(mu5QAcKfGNLyYsFwqclE4EyzSm(TziKtH1r577iwaglPBailiHfCeP15nhFK9oiHdZhDpSS3rp89D(ryw2GwyPBf2yjfyaml(qSGY)IazjIgwWuawG27i8jxEhzV74iamn7uW(SJLsajBRBVtLRQjq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JTRUiw2pFWRbfHzXYgvSCBelTh12XYJzXvHRJLdYcvGOLL2qvkJZYJzXvHRJLdYcvGOLL4Wfl(qS4hlaP0bglPadGz5lw8If0lO)imHwwqwkqI1wbw0o(WS4f82OHfGaWWuaZcCyjoCXIf4sdYcebnbpILo4qSCBEXcNOu6SKcmaMflBuXsC4IflWLgSq3XY(5dEnOiwkOf79W8hnVBV3JfvigZIcw(6OjcQ9JaZTh12LhQZ)cZcqzXAyjjHLESOUAnZ4iOcUW52qvkJBgQZ)cZcqzbva005iNfGNLa9Aw6XIJVX15iOfAybjSeZ0zPplkyrD1AMXrqfCHZTHQug3SIyPpl9zjjHLES44BCDocAHgwagli85DvnzCCeaMMDkWcWZI6Q1muq)rykJHAFmd15FHzbySacptBnXZWwM0RIm3haeNhQZ)IfGNfaAqdlPYIskLoljjS44BCDocAHgwagli85DvnzCCeaMMDkWcWZI6Q1muq)rykRxLpMH68VWSamwaHNPTM4zylt6vrM7daIZd15FXcWZcanOHLuzrjLsNL(SOGfkO)imz(k7vCwuWspwSIf1vRzcE(RGzfXssclwXY5AQod(8rdhqdvUQMazPplkyPhl9yXkwcqOgeAPmbp)vWSIyjjHLaebvEDgaJpVxSOGfRyjaHAqOLYqDrql0KvHfOzfXsFwssyjarqLxNPEuBxU5el9zrbl9yXkwcqeu51zqq1TfFyjjHfRyrD1AMGN)kywrSKKWIJVX15iOfAyjvwasPZsFwssyPhlNRP6m4ZhnCanu5QAcKffSOUAntWZFfmRiwuWspwuxTMbF(OHdObFEaqwaklXKLKewC8nUohbTqdlPYcqkDw6ZsFwssyrD1AMGN)kywrSOGfRyrD1AMXrqfCHZTHQug3SIyrblwXY5AQod(8rdhqdvUQMaTp7ybW0TTU9ovUQMaTJH9UhUhw27fzj3bHL9oiHdZhDpSS3JDmXcakiSWS8flO)Q8Hf0lO)imXIxGSGDeeliLX1nGfBwAnlaOGWILgCybzPajwBfS3dZF08U9EpwuxTMHc6pctz9Q8XmuN)fMLuzHqofwhLVVJyjjHLESe28bfHzrzwailkyzOWMpOO89DelaLf0WsFwssyjS5dkcZIYSetw6ZIcw8OCyJcaAF2XcGkzBD7DQCvnbAhd79W8hnVBV3Jf1vRzOG(JWuwVkFmd15FHzjvwiKtH1r577iwuWspwcqOgeAPmbp)vWmuN)fMLuzbnPZssclbiudcTuMaSqabKY3gLXr)8h2muN)fMLuzbnPZsFwssyPhlHnFqrywuMfaYIcwgkS5dkkFFhXcqzbnS0NLKewcB(GIWSOmlXKL(SOGfpkh2OaG27E4EyzVV56wUdcl7ZowaeG2w3ENkxvtG2XWEpm)rZ7279yrD1AgkO)imL1RYhZqD(xywsLfc5uyDu((oIffS0JLaeQbHwktWZFfmd15FHzjvwqt6SKKWsac1GqlLjaleqaP8TrzC0p)Hnd15FHzjvwqt6S0NLKew6XsyZhueMfLzbGSOGLHcB(GIY33rSauwqdl9zjjHLWMpOimlkZsmzPplkyXJYHnkaO9UhUhw27TLwN7GWY(SJfaJPT1T3PYv1eODmS3bjCy(O7HL9osbe9ybwSeaT39W9WYE3IpZdNmSLj9Qi7Zowa0ASTU9ovUQMaTJH9UhUhw274ZN2pK9oiHdZhDpSS3JDmXY(5t7hILdYs0adSSd1(Wc6f0FeMyboSyzJkw(IfyPJZc6VkFyb9c6pctS4fillmXcsbe9yjAGbmlFJLVyb9xLpSGEb9hHj79W8hnVBVtb9hHjZxz9Q8HLKewOG(JWKbd1(Klc5hljjSqb9hHjJxXZfH8JLKewuxTMXIpZdNmSLj9QiZkIffSOUAndf0FeMY6v5JzfXsscl9yrD1AMGN)kygQZ)cZcqzXd3dlJLXVndHCkSokFFhXIcwuxTMj45VcMvel9Tp7ybq0yBD7DpCpSS3Tm(TzVtLRQjq7yyF2XcGahBRBVtLRQjq7yyV7H7HL9(SQShUhwz9Jp7D9JVC5DK9EZ16BBw2N9zV7qY262XsjBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS37XI6Q1m33rwGtLbhY7u)cKgZqD(xywaklOcGMoh5Samws3OeljjSOUAnZ9DKf4uzWH8o1VaPXmuN)fMfGYIhUhwg85t7hYqiNcRJY33rSamws3OelkyPhluq)ryY8vwVkFyjjHfkO)imzWqTp5Iq(Xsscluq)ryY4v8Cri)yPpl9zrblQRwZCFhzbovgCiVt9lqAmRiwuWYSkQbhuK5(oYcCQm4qEN6xG0yOYv1eO9oiHdZhDpSS3rMRdlTFeMflB0Trdl3gXsSDiVl4xyJgwuxTglwETMLMR1SaBnwS832xSCBelfH8JLGJp7De(KlVJS3bhY7YwETo3CTodBn7Zowa02627u5QAc0og27Wi7DmD27E4EyzVJWN3v1K9ocxVi7DRyHc6pctMVYyO2hwuWspwWrKwNpFqrh2GpFA)qSKklOHffSCUMQZGHlDg2Y3gLBWHWNHkxvtGSKKWcoI0685dk6Wg85t7hILuzbiYsF7DqchMp6EyzVJmxhwA)imlw2OBJgw2pFWRbfXYJzXcCUnwco((cflqe0WY(5t7hILVyb9xLpSGEb9hHj7De(KlVJS3FufCOm(8bVguK9zhRyABD7DQCvnbAhd7DpCpSS3dWcbeqkFBugh9ZFy7DqchMp6EyzVh7yIfKbleqajwSSrfl(XIMWywUnVybnPZskWayw8cKf9xelRiwS83glilfiXARG9Ey(JM3T3TIfWz9GMcMdGywuWspw6XccFExvtMaSqabKYGeoEfyrblwXsac1GqlLj45VcMHCW4SKKWI6Q1mbp)vWSIyPplkyPhlQRwZqb9hHPSEv(ygQZ)cZsQSaCyjjHf1vRzOG(JWugd1(ygQZ)cZsQSaCyPplkyPhlwXYSkQbhuKr11EfOmSLDToFBFHcBOYv1eiljjSOUAnJQR9kqzyl7AD(2(cfox(TgYGppailPYsmzjjHf1vRzuDTxbkdBzxRZ32xOWzFcErg85bazjvwIjl9zjjHfvigZIcwApQTlpuN)fMfGYIsPZIcwSILaeQbHwktWZFfmd5GXzPV9zhlRX2627u5QAc0og27E4EyzVpocQGlCUnuLY427GeomF09WYEp2XelXMHQugNfl)TXcYsbsS2kyVhM)O5D7D1vRzcE(RGzOo)lmlPYIsOX(SJfASTU9ovUQMaTJH9UhUhw274v1(HS3dXdAkF(GIoSDSuYEpm)rZ7279yzO2q4nxvtSKKWI6Q1muq)rykJHAFmd15FHzbOSetwuWcf0FeMmFLXqTpSOGLH68VWSauwuYAyrblNRP6my4sNHT8Tr5gCi8zOYv1eil9zrblNpOOZCFhLpyg8jwsLfLSgwaGSGJiToF(GIomlaJLH68VWSOGLESqb9hHjZxzVIZsscld15FHzbOSGkaA6CKZsF7DqchMp6EyzVh7yIL9v1(Hy5lwI8cK6(alWIfVIFBFHILBZpw0pccZIswdMcyw8cKfnHXSy5Vnw6GdXY5dk6WS4fil(XYTrSqfilWglol7qTpSGEb9hHjw8JfLSgwWuaZcCyrtymld15F9fkwCmlhKLcESS5i(cflhKLHAdH3ybCnFHIf0Fv(Wc6f0FeMSp7ybCSTU9ovUQMaTJH9UhUhw274ZNMR127GeomF09WYEhPerrSSIyz)8P5Anl(XIR1SCFhHzzvAcJzzH)cflOF8GpoMfVaz5pwEmlUkCDSCqwIgyGf4WIMowUnIfCefExZIhUhwSO)IyrL0qlSS5fOMyj2oK3P(finSalwailNpOOdBVhM)O5D7DRy5CnvNbFKw7tgC(2zOYv1eilkyPhlQRwZGpFAUwBgQneEZv1elkyPhl4isRZNpOOdBWNpnxRzbOSetwssyXkwMvrn4GIm33rwGtLbhY7u)cKgdvUQMazPpljjSCUMQZGHlDg2Y3gLBWHWNHkxvtGSOGf1vRzOG(JWugd1(ygQZ)cZcqzjMSOGfkO)imz(kJHAFyrblQRwZGpFAUwBgQZ)cZcqzbiYIcwWrKwNpFqrh2GpFAUwZsQkZI1WsFwuWspwSILzvudoOiJoEWhhNBAIUVqLrP)UimzOYv1eiljjSCFhXcsLfRbnSKklQRwZGpFAUwBgQZ)cZcWybGS0NffSC(GIoZ9Du(GzWNyjvwqJ9zhlGOT1T3PYv1eODmS39W9WYEhF(0CT2EhKWH5JUhw27if)TXY(rATpSeBNVDSSWelWILailw2OILHAdH3CvnXI66ybFVwZIf)pwAWHf0pEWhhZs0adS4filGWcDhllmXIk1GdXcYITydl73R1SSWelQudoelidwiGasSG)kqSCB(XILxRzjAGbw8cEB0WY(5tZ1A79W8hnVBVFUMQZGpsR9jdoF7mu5QAcKffSOUAnd(8P5ATzO2q4nxvtSOGLESyflZQOgCqrgD8Gpoo30eDFHkJs)DryYqLRQjqwssy5(oIfKklwdAyjvwSgw6ZIcwoFqrN5(okFWm4tSKklX0(SJfqW2627u5QAc0og27E4EyzVJpFAUwBVds4W8r3dl7DKI)2yj2oK3P(finSSWel7NpnxRz5GSairrSSIy52iwuxTglQXzX1yill8xOyz)8P5AnlWIf0WcMcWceZcCyrtymld15F9fk79W8hnVBVpRIAWbfzUVJSaNkdoK3P(fingQCvnbYIcwWrKwNpFqrh2GpFAUwZsQkZsmzrbl9yXkwuxTM5(oYcCQm4qEN6xG0ywrSOGf1vRzWNpnxRnd1gcV5QAILKew6XccFExvtgWH8USLxRZnxRZWwJffS0Jf1vRzWNpnxRnd15FHzbOSetwssybhrAD(8bfDyd(8P5AnlPYcazrblNRP6m4J0AFYGZ3odvUQMazrblQRwZGpFAUwBgQZ)cZcqzbnS0NL(S03(SJfqY2627u5QAc0og27Wi7DmD27E4EyzVJWN3v1K9ocxVi7DhFJRZrql0WsQSaesNfail9yrP0zb4zrD1AM77ilWPYGd5DQFbsJbFEaqw6ZcaKLESOUAnd(8P5ATzOo)lmlaplXKfKWcoI068MJpIfGNfRy5CnvNbFKw7tgC(2zOYv1eil9zbaYspwcqOgeAPm4ZNMR1MH68VWSa8Setwqcl4isRZBo(iwaEwoxt1zWhP1(KbNVDgQCvnbYsFwaGS0Jfq4zARjEg2YKEvKzOo)lmlaplOHL(SOGLESOUAnd(8P5ATzfXssclbiudcTug85tZ1AZqD(xyw6BVds4W8r3dl7DK56Ws7hHzXYgDB0WIZY(5dEnOiwwyIflVwZsWxyIL9ZNMR1SCqwAUwZcS1qllEbYYctSSF(GxdkILdYcGefXsSDiVt9lqAybFEaqwwr27i8jxEhzVJpFAUwNTaRl3CTodBn7ZowkLUT1T3PYv1eODmS39W9WYEhF(GxdkYEhKWH5JUhw27XoMyz)8bVguelw(BJLy7qEN6xG0WYbzbqIIyzfXYTrSOUAnwS83gCDSOH4VqXY(5tZ1Awwr33rS4fillmXY(5dEnOiwGflwdWyjgWuyDwWNhaeZYQUxZI1WY5dk6W27H5pAE3EhHpVRQjd4qEx2YR15MR1zyRXIcwq4Z7QAYGpFAUwNTaRl3CTodBnwuWIvSGWN3v1K5rvWHY4Zh8AqrSKKWspwuxTMr11EfOmSLDToFBFHcNl)wdzWNhaKLuzjMSKKWI6Q1mQU2RaLHTSR15B7lu4SpbVid(8aGSKklXKL(SOGfCeP15Zhu0Hn4ZNMR1SauwSgwuWccFExvtg85tZ16SfyD5MR1zyRzF2XsjLSTU9ovUQMaTJH9UhUhw27oOhDpckJT4tN9EiEqt5Zhu0HTJLs27H5pAE3E3kwUpa4xOyrblwXIhUhwgh0JUhbLXw8Pld6DokY8vUPFuBhljjSacpJd6r3JGYyl(0Lb9ohfzWNhaKfGYsmzrblGWZ4GE09iOm2IpDzqVZrrMH68VWSauwIP9oiHdZhDpSS3JDmXc2IpDSGHSCB(XsC4Ifu0XsNJCwwr33rSOgNLf(luS8hloMfTFeloMLiig)QAIfyXIMWywUnVyjMSGppaiMf4WcaYl8XILnQyjMaJf85baXSqip6hY(SJLsa02627u5QAc0og27E4EyzV3bHv7hYEpepOP85dk6W2Xsj79W8hnVBVpuBi8MRQjwuWY5dk6m33r5dMbFILuzPhl9yrjRHfGXspwWrKwNpFqrh2GpFA)qSa8SaqwaEwuxTMHc6pctz9Q8XSIyPpl9zbySmuN)fML(SGew6XIsSamwoxt1zolFL7GWcBOYv1eil9zrbl9yjaHAqOLYe88xbZqoyCwuWIvSaoRh0uWCaeZIcw6XccFExvtMaSqabKYGeoEfyjjHLaeQbHwktawiGas5BJY4OF(dBgYbJZssclwXsaIGkVot9O2UCZjw6Zsscl4isRZNpOOdBWNpTFiwakl9yPhlahwaGS0Jf1vRzOG(JWuwVkFmRiwaEwail9zPplapl9yrjwaglNRP6mNLVYDqyHnu5QAcKL(S0NffSyfluq)ryYGHAFYfH8JLKew6Xcf0FeMmFLXqTpSKKWspwOG(JWK5RSk82yjjHfkO)imz(kRxLpS0NffSyflNRP6my4sNHT8Tr5gCi8zOYv1eiljjSOUAnt08DWb8DD2NGxFihT0yFmiC9IyjvLzbGOjDw6ZIcw6XcoI0685dk6Wg85t7hIfGYIsPZcWZspwuIfGXY5AQoZz5RChewydvUQMazPpl9zrblo(gxNJGwOHLuzbnPZcaKf1vRzWNpnxRnd15FHzb4zb4WsFwuWspwSIf1vRza8lWHaZuxe0cnDuDzQOb1NsYSIyjjHfkO)imz(kJHAFyjjHfRyjarqLxNbW4Z7fl9zrblwXI6Q1mJJGk4cNBdvPmEg)vBPZBXXhnVBwr27GeomF09WYEhab1gcVXcakiSA)qS8nwqwkqI1wbwEmld5GXrll3gnel(qSOjmMLBZlwqdlNpOOdZYxSG(RYhwqVG(JWelw(BJLD4fBqllAcJz528IfLsNf4TrJLhtS8flEfNf0lO)imXcCyzfXYbzbnSC(GIomlQudoelolO)Q8Hf0lO)imzyj2cl0DSmuBi8glGR5luSGu6lWHazb96IGwOPJQJLvPjmMLVyzhQ9Hf0lO)imzF2XsPyABD7DQCvnbAhd7DpCpSS3BWjqzylx(TgYEhKWH5JUhw27XoMyj2aJflWILailw(BdUowcEu0xOS3dZF08U9UhLdBuaq7Zowkzn2w3ENkxvtG2XWEhgzVJPZE3d3dl7De(8UQMS3r46fzVBflGZ6bnfmhaXSOGfe(8UQMmbWCawG)9WIffS0JLESOUAnd(8P5ATzfXssclNRP6m4J0AFYGZ3odvUQMazjjHLaebvEDM6rTD5MtS0NffS0JfRyrD1AgmuJVpqMvelkyXkwuxTMj45VcMvelkyPhlwXY5AQotBnXZWwM0RImu5QAcKLKewuxTMj45VcgW143dlwsLLaeQbHwktBnXZWwM0RImd15FHzbySaeyPplkybHpVRQjZTnVwNXebinzl(FSOGLESyflbicQ86m1JA7YnNyjjHLaeQbHwktawiGas5BJY4OF(dBwrSOGLESOUAnd(8P5ATzOo)lmlaLfaYssclwXY5AQod(iT2Nm48TZqLRQjqw6ZsFwuWY5dk6m33r5dMbFILuzrD1AMGN)kyaxJFpSyb4zjDdqKL(SKKWs7rTD5H68VWSauwuxTMj45VcgW143dlw6BVJWNC5DK9EamhGf4FpSYoKSp7yPeASTU9ovUQMaTJH9UhUhw27bst47DD21pQQJQZEhKWH5JUhw27XoMybzPajwBfybwSeazzvAcJzXlqw0FrS8hlRiwS83glidwiGas27H5pAE3EhHpVRQjtamhGf4FpSYoKSp7yPeWX2627u5QAc0og27H5pAE3EhHpVRQjtamhGf4FpSYoKS39W9WYE)RGpLFpSSp7yPeq02627u5QAc0og27E4EyzVtDrql0KvHfO9oiHdZhDpSS3JDmXc61fbTqdlXawGSalwcGSy5Vnw2pFAUwZYkIfVazb7iiwAWHfa8sJ9HfVazbzPajwBfS3dZF08U9UkeJzrblFD0eb1(rG52JA7Yd15FHzbOSOeAyjjHLESOUAnt08DWb8DD2NGxFihT0yFmiC9IybOSaq0KoljjSOUAnt08DWb8DD2NGxFihT0yFmiC9IyjvLzbGOjDw6ZIcwuxTMbF(0CT2SIyrbl9yjaHAqOLYe88xbZqD(xywsLf0KoljjSaoRh0uWCaeZsF7ZowkbeSTU9ovUQMaTJH9UhUhw274J0AFYnTpK9EiEqt5Zhu0HTJLs27H5pAE3EFO2q4nxvtSOGL77O8bZGpXsQSOeAyrbl4isRZNpOOdBWNpTFiwaklwdlkyXJYHnkailkyPhlQRwZe88xbZqD(xywsLfLsNLKewSIf1vRzcE(RGzfXsF7DqchMp6EyzVdGGAdH3yPP9HybwSSIy5GSetwoFqrhMfl)TbxhlilfiXARalQ0xOyXvHRJLdYcH8OFiw8cKLcESarqtWJI(cL9zhlLas2w3ENkxvtG2XWE3d3dl792AINHTmPxfzVds4W8r3dl79yhtSeBGOhlFJLVWpiXIxSGEb9hHjw8cKf9xel)XYkIfl)TXIZcaEPX(Ws0adS4filPa0JUhbXYUfF6S3dZF08U9of0FeMmFL9kolkyXJYHnkailkyrD1AMO57Gd476SpbV(qoAPX(yq46fXcqzbGOjDwuWspwaHNXb9O7rqzSfF6YGENJIm3ha8luSKKWIvSeGiOYRZuuyGA4aYsscl4isRZNpOOdZsQSaqw6ZIcw6XI6Q1mJJGk4cNBdvPmUzOo)lmlaLfGelaqw6XcAyb4zzwf1GdkYG)QT05T44JM3nu5QAcKL(SOGf1vRzghbvWfo3gQszCZkILKewSIf1vRzghbvWfo3gQszCZkIL(SOGLESyflbiudcTuMGN)kywrSKKWI6Q1m328ADgteG0yWNhaKfGYIsOHffS0EuBxEOo)lmlaLfaME6SOGL2JA7Yd15FHzjvwuk90zjjHfRybdxA1Van328ADgteG0yOYv1eil9zrbl9ybdxA1Van328ADgteG0yOYv1eiljjSeGqni0szcE(RGzOo)lmlPYsmtNL(2NDSay62w3ENkxvtG2XWE3d3dl7D85tZ1A7DqchMp6EyzVh7yIfNL9ZNMR1SaGUOBJLObgyzvAcJzz)8P5AnlpMfxpKdgNLvelWHL4Wfl(qS4QW1XYbzbIGMGhXskWay79W8hnVBVRUAndSOBdNJOjqr3dlZkIffS0Jf1vRzWNpnxRnd1gcV5QAILKewC8nUohbTqdlPYcqkDw6BF2XcGkzBD7DQCvnbAhd7DpCpSS3XNpnxRT3bjCy(O7HL9ESD1fXskWaywuPgCiwqgSqabKyXYFBSSF(0CTMfVaz52OIL9Zh8Aqr27H5pAE3EparqLxNPEuBxU5elkyXkwoxt1zWhP1(KbNVDgQCvnbYIcw6XccFExvtMaSqabKYGeoEfyjjHLaeQbHwktWZFfmRiwssyrD1AMGN)kywrS0NffSeGqni0szcWcbeqkFBugh9ZFyZqD(xywaklOcGMoh5Sa8SeOxZspwC8nUohbTqdliHf0Kol9zrblQRwZGpFAUwBgQZ)cZcqzXAyrblwXc4SEqtbZbqS9zhlacqBRBVtLRQjq7yyVhM)O5D79aebvEDM6rTD5MtSOGLESGWN3v1KjaleqaPmiHJxbwssyjaHAqOLYe88xbZkILKewuxTMj45VcMvel9zrblbiudcTuMaSqabKY3gLXr)8h2muN)fMfGYcWHffSOUAnd(8P5ATzfXIcwOG(JWK5RSxXzrblwXccFExvtMhvbhkJpFWRbfXIcwSIfWz9GMcMdGy7DpCpSS3XNp41GISp7ybWyABD7DQCvnbAhd7DpCpSS3XNp41GIS3bjCy(O7HL9ESJjw2pFWRbfXIL)2yXlwaqx0TXs0adSahw(glXHl0bYcebnbpILuGbWSy5VnwIdxdlfH8JLGJpdlPqJHSaU6Iyjfyaml(XYTrSqfilWgl3gXcasuDBXhwuxTglFJL9ZNMR1SybU0Gf6owAUwZcS1yboSehUyXhIfyXcaz58bfDy79W8hnVBVRUAndSOBdNdAYNmIh)WYSIyjjHLESyfl4ZN2pKXJYHnkailkyXkwq4Z7QAY8Ok4qz85dEnOiwssyPhlQRwZe88xbZqD(xywaklOHffSOUAntWZFfmRiwssyPhl9yrD1AMGN)kygQZ)cZcqzbva005iNfGNLa9Aw6XIJVX15iOfAybjSeZ0zPplkyrD1AMGN)kywrSKKWI6Q1mJJGk4cNBdvPmEg)vBPZBXXhnVBgQZ)cZcqzbva005iNfGNLa9Aw6XIJVX15iOfAybjSeZ0zPplkyrD1AMXrqfCHZTHQugpJ)QT05T44JM3nRiw6ZIcwcqeu51zqq1TfFyPpl9zrbl9ybhrAD(8bfDyd(8P5AnlaLLyYsscli85DvnzWNpnxRZwG1LBUwNHTgl9zPplkyXkwq4Z7QAY8Ok4qz85dEnOiwuWspwSILzvudoOiZ9DKf4uzWH8o1VaPXqLRQjqwssybhrAD(8bfDyd(8P5AnlaLLyYsF7Zowa0ASTU9ovUQMaTJH9UhUhw27fzj3bHL9oiHdZhDpSS3JDmXcakiSWS8fl7qTpSGEb9hHjw8cKfSJGyj2S0AwaqbHfln4WcYsbsS2kyVhM)O5D79ESOUAndf0FeMYyO2hZqD(xywsLfc5uyDu((oILKew6XsyZhueMfLzbGSOGLHcB(GIY33rSauwqdl9zjjHLWMpOimlkZsmzPplkyXJYHnkaO9zhlaIgBRBVtLRQjq7yyVhM)O5D79ESOUAndf0FeMYyO2hZqD(xywsLfc5uyDu((oILKew6XsyZhueMfLzbGSOGLHcB(GIY33rSauwqdl9zjjHLWMpOimlkZsmzPplkyXJYHnkailkyPhlQRwZmocQGlCUnuLY4MH68VWSauwqdlkyrD1AMXrqfCHZTHQug3SIyrblwXYSkQbhuKb)vBPZBXXhnVBOYv1eiljjSyflQRwZmocQGlCUnuLY4Mvel9T39W9WYEFZ1TChew2NDSaiWX2627u5QAc0og27H5pAE3EVhlQRwZqb9hHPmgQ9XmuN)fMLuzHqofwhLVVJyrbl9yjaHAqOLYe88xbZqD(xywsLf0KoljjSeGqni0szcWcbeqkFBugh9ZFyZqD(xywsLf0Kol9zjjHLESe28bfHzrzwailkyzOWMpOO89DelaLf0WsFwssyjS5dkcZIYSetw6ZIcw8OCyJcaYIcw6XI6Q1mJJGk4cNBdvPmUzOo)lmlaLf0WIcwuxTMzCeubx4CBOkLXnRiwuWIvSmRIAWbfzWF1w68wC8rZ7gQCvnbYssclwXI6Q1mJJGk4cNBdvPmUzfXsF7DpCpSS3BlTo3bHL9zhlaceTTU9ovUQMaTJH9oiHdZhDpSS3JDmXcsbe9ybwSGSyR9UhUhw27w8zE4KHTmPxfzF2XcGabBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS3XrKwNpFqrh2GpFA)qSKklwdlaJLMgchw6XsNJpAINr46fXcWZIsPNoliHfaMol9zbyS00q4WspwuxTMbF(GxdkktDrql00r1LXqTpg85bazbjSynS03EhKWH5JUhw27iZ1HL2pcZILn62OHLdYYctSSF(0(Hy5lw2HAFyXY2h2y5XS4hlOHLZhu0HbMsS0GdlecAIZcathPYsNJpAIZcCyXAyz)8bVguelOxxe0cnDuDSGppai2EhHp5Y7i7D85t7hk)vgd1(yF2XcGajBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS3vIfKWcoI068MJpIfGYcazbaYspws3aqwaEw6XcoI0685dk6Wg85t7hIfailkXsFwaEw6XIsSamwoxt1zWWLodB5BJYn4q4ZqLRQjqwaEwuYGgw6ZsFwaglPBucnSa8SOUAnZ4iOcUW52qvkJBgQZ)cBVds4W8r3dl7DK56Ws7hHzXYgDB0WYbzbPy8BJfW18fkwIndvPmU9ocFYL3r27wg)2YFLBdvPmU9zhRyMUT1T3PYv1eODmS39W9WYE3Y43M9oiHdZhDpSS3JDmXcsX43glFXYou7dlOxq)ryIf4WY3yPGSSF(0(HyXYR1S0(JLVoililfiXARalEfVdoK9Ey(JM3T37Xcf0FeMm6v5tUiKFSKKWcf0FeMmEfpxeYpwuWccFExvtMhNdAYrqS0NffS0JLZhu0zUVJYhmd(elPYI1Wsscluq)ryYOxLp5VYaKLKewApQTlpuN)fMfGYIsPZsFwssyrD1AgkO)imLXqTpMH68VWSauw8W9WYGpFA)qgc5uyDu((oIffSOUAndf0FeMYyO2hZkILKewOG(JWK5RmgQ9HffSyfli85DvnzWNpTFO8xzmu7dljjSOUAntWZFfmd15FHzbOS4H7HLbF(0(HmeYPW6O89DelkyXkwq4Z7QAY84CqtocIffSOUAntWZFfmd15FHzbOSqiNcRJY33rSOGf1vRzcE(RGzfXssclQRwZmocQGlCUnuLY4MvelkybHpVRQjJLXVT8x52qvkJZssclwXccFExvtMhNdAYrqSOGf1vRzcE(RGzOo)lmlPYcHCkSokFFhzF2XkMkzBD7DQCvnbAhd7DqchMp6EyzVh7yIL9ZN2pelFJLVyb9xLpSGEb9hHj0YYxSSd1(Wc6f0FeMybwSynaJLZhu0HzboSCqwIgyGLDO2hwqVG(JWK9UhUhw274ZN2pK9zhRycqBRBVtLRQjq7yyVds4W8r3dl79yJR132SS39W9WYEFwv2d3dRS(XN9U(XxU8oYEV5A9Tnl7Z(S3BUwFBZY262XsjBRBVtLRQjq7yyV7H7HL9o(8bVguK9oiHdZhDpSS33pFWRbfXsdoS0brqDuDSSknHXSSWFHILyatH1T3dZF08U9UvSmRIAWbfzuDTxbkdBzxRZ32xOWgc4U(Oic0(SJfaTTU9ovUQMaTJH9UhUhw274v1(HS3dXdAkF(GIoSDSuYEpm)rZ727GWZ0bHv7hYmuN)fMLuzzOo)lmlaplaeGSGewuciyVds4W8r3dl7DK54JLBJybeESy5VnwUnILoi(y5(oILdYIdcYYQUxZYTrS05iNfW143dlwEmlB)zyzFvTFiwgQZ)cZs3sFFK(jqwoilD(f2yPdcR2pelGRXVhw2NDSIPT1T39W9WYEVdcR2pK9ovUQMaTJH9zF274Z262XsjBRBVtLRQjq7yyV7H7HL9o(8bVguK9oiHdZhDpSS3JDmXY(5dEnOiwoilasuelRiwUnILy7qEN6xG0WI6Q1y5BS8hlwGlnileYJ(HyrLAWHyP91J3(cfl3gXsri)yj44Jf4WYbzbC1fXIk1GdXcYGfciGK9Ey(JM3T3Nvrn4GIm33rwGtLbhY7u)cKgdvUQMazrbl9yHc6pctMVYEfNffSyfl9yPhlQRwZCFhzbovgCiVt9lqAmd15FHzjvw8W9WYyz8BZqiNcRJY33rSamws3OelkyPhluq)ryY8vwfEBSKKWcf0FeMmFLXqTpSKKWcf0FeMm6v5tUiKFS0NLKewuxTM5(oYcCQm4qEN6xG0ygQZ)cZsQS4H7HLbF(0(HmeYPW6O89DelaJL0nkXIcw6Xcf0FeMmFL1RYhwssyHc6pctgmu7tUiKFSKKWcf0FeMmEfpxeYpw6ZsFwssyXkwuxTM5(oYcCQm4qEN6xG0ywrS0NLKew6XI6Q1mbp)vWSIyjjHfe(8UQMmbyHaciLbjC8kWsFwuWsac1GqlLjaleqaP8TrzC0p)Hnd5GXzrblbicQ86m1JA7YnNyPplkyPhlwXsaIGkVodGXN3lwssyjaHAqOLYqDrql0KvHfOzOo)lmlPYcqGL(SOGLESOUAntWZFfmRiwssyXkwcqOgeAPmbp)vWmKdgNL(2NDSaOT1T3PYv1eODmS39W9WYE3b9O7rqzSfF6S3dXdAkF(GIoSDSuYEpm)rZ727wXci8moOhDpckJT4txg07CuK5(aGFHIffSyflE4EyzCqp6EeugBXNUmO35OiZx5M(rTDSOGLESyflGWZ4GE09iOm2IpD5nY1M7da(fkwssybeEgh0JUhbLXw8PlVrU2muN)fMLuzbnS0NLKewaHNXb9O7rqzSfF6YGENJIm4ZdaYcqzjMSOGfq4zCqp6EeugBXNUmO35OiZqD(xywaklXKffSacpJd6r3JGYyl(0Lb9ohfzUpa4xOS3bjCy(O7HL9ESJjwsbOhDpcILDl(0XILnQy52OHy5XSuqw8W9iiwWw8PdTS4yw0(rS4ywIGy8RQjwGflyl(0XIL)2ybGSahwAKfAybFEaqmlWHfyXIZsmbglyl(0XcgYYT5hl3gXsrwybBXNow8zEeeMfaKx4JfVD0WYT5hlyl(0XcH8OFiS9zhRyABD7DQCvnbAhd7DpCpSS3dWcbeqkFBugh9ZFy7DqchMp6EyzVh7ycZcYGfciGelFJfKLcKyTvGLhZYkIf4WsC4IfFiwajC8k8fkwqwkqI1wbwS83glidwiGasS4filXHlw8HyrL0qlSynPZskWay79W8hnVBVBflGZ6bnfmhaXSOGLES0Jfe(8UQMmbyHaciLbjC8kWIcwSILaeQbHwktWZFfmd5GXzrblwXYSkQbhuKjA(o4a(Uo7tWRpKJwASpgQCvnbYssclQRwZe88xbZkIL(SOGfhFJRZrql0WcqvMfRjDwuWspwuxTMHc6pctz9Q8XmuN)fMLuzrP0zjjHf1vRzOG(JWugd1(ygQZ)cZsQSOu6S0NLKewuHymlkyP9O2U8qD(xywaklkLolkyXkwcqOgeAPmbp)vWmKdgNL(2NDSSgBRBVtLRQjq7yyVdJS3X0zV7H7HL9ocFExvt27iC9IS37XI6Q1mJJGk4cNBdvPmUzOo)lmlPYcAyjjHfRyrD1AMXrqfCHZTHQug3SIyPplkyXkwuxTMzCeubx4CBOkLXZ4VAlDElo(O5DZkIffS0Jf1vRza8lWHaZuxe0cnDuDzQOb1NsYmuN)fMfGYcQaOPZrol9zrbl9yrD1AgkO)imLXqTpMH68VWSKklOcGMoh5SKKWI6Q1muq)rykRxLpMH68VWSKklOcGMoh5SKKWspwSIf1vRzOG(JWuwVkFmRiwssyXkwuxTMHc6pctzmu7JzfXsFwuWIvSCUMQZGHA89bYqLRQjqw6BVds4W8r3dl7DKblW)EyXsdoS4AnlGWdZYT5hlDoGeMf8AiwUnkol(qf6owgQneEJazXYgvSaGWrqfCHzj2muLY4SS5yw0egZYT5flOHfmfWSmuN)1xOyboSCBelagFEVyrD1AS8ywCv46y5GS0CTMfyRXcCyXR4SGEb9hHjwEmlUkCDSCqwiKh9dzVJWNC5DK9oi8YdbCx)qDuDy7ZowOX2627u5QAc0og27Wi7DmD27E4EyzVJWN3v1K9ocxVi79ESyflQRwZqb9hHPmgQ9XSIyrblwXI6Q1muq)rykRxLpMvel9zjjHLZ1uDgmuJVpqgQCvnbAVds4W8r3dl7DKblW)EyXYT5hlHnkaiMLVXsC4IfFiwGRd)Geluq)ryILdYcS0XzbeESCB0qSahwEufCiwUThZIL)2yzhQX3hi7De(KlVJS3bHxgUo8dszkO)imzF2Xc4yBD7DQCvnbAhd7DpCpSS37GWQ9dzVhM)O5D79HAdH3CvnXIcw6XI6Q1muq)rykJHAFmd15FHzjvwgQZ)cZssclQRwZqb9hHPSEv(ygQZ)cZsQSmuN)fMLKewq4Z7QAYacVmCD4hKYuq)ryIL(SOGLHAdH3CvnXIcwoFqrN5(okFWm4tSKklkbqwuWIhLdBuaqwuWccFExvtgq4Lhc4U(H6O6W27H4bnLpFqrh2owkzF2XciABD7DQCvnbAhd7DpCpSS3XRQ9dzVhM)O5D79HAdH3CvnXIcw6XI6Q1muq)rykJHAFmd15FHzjvwgQZ)cZssclQRwZqb9hHPSEv(ygQZ)cZsQSmuN)fMLKewq4Z7QAYacVmCD4hKYuq)ryIL(SOGLHAdH3CvnXIcwoFqrN5(okFWm4tSKklkbqwuWIhLdBuaqwuWccFExvtgq4Lhc4U(H6O6W27H4bnLpFqrh2owkzF2XciyBD7DQCvnbAhd7DpCpSS3XhP1(KBAFi79W8hnVBVpuBi8MRQjwuWspwuxTMHc6pctzmu7JzOo)lmlPYYqD(xywssyrD1AgkO)imL1RYhZqD(xywsLLH68VWSKKWccFExvtgq4LHRd)GuMc6pctS0NffSmuBi8MRQjwuWY5dk6m33r5dMbFILuzrjGdlkyXJYHnkailkybHpVRQjdi8YdbCx)qDuDy79q8GMYNpOOdBhlLSp7ybKSTU9ovUQMaTJH9UhUhw27n4eOmSLl)wdzVds4W8r3dl79yhtSeBGXIfyXsaKfl)Tbxhlbpk6lu27H5pAE3E3JYHnkaO9zhlLs32627u5QAc0og27E4EyzVtDrql0KvHfO9oiHdZhDpSS3JDmXcsPVahcKL9OF(dZIL)2yXR4SOHfkwOcUqTXI2X3xOyb9c6pctS4fil3eNLdYI(lIL)yzfXIL)2ybaV0yFyXlqwqwkqI1wb79W8hnVBV3JLESOUAndf0FeMYyO2hZqD(xywsLfLsNLKewuxTMHc6pctz9Q8XmuN)fMLuzrP0zPplkyjaHAqOLYe88xbZqD(xywsLLyMolkyPhlQRwZenFhCaFxN9j41hYrln2hdcxViwakla0AsNLKewSILzvudoOit08DWb8DD2NGxFihT0yFmeWD9rreil9zPpljjSOUAnt08DWb8DD2NGxFihT0yFmiC9IyjvLzbGaX0zjjHLaeQbHwktWZFfmd5GXzrblo(gxNJGwOHLuzbiLU9zhlLuY2627u5QAc0og27Wi7DmD27E4EyzVJWN3v1K9ocxVi7DRybCwpOPG5aiMffSGWN3v1KjaMdWc8VhwSOGLES0JLaeQbHwkd1ffFixNHdy5vGmd15FHzbOSOeWbiYcWyPhlkPelaplZQOgCqrg8xTLoVfhF08UHkxvtGS0NffSqa31hfrGgQlk(qUodhWYRaXsFwssyXX346Ce0cnSKQYSaKsNffS0JfRy5CnvNPTM4zylt6vrgQCvnbYssclQRwZe88xbd4A87HflPYsac1GqlLPTM4zylt6vrMH68VWSamwacS0NffSGWN3v1K52MxRZyIaKMSf)pwuWspwuxTMbWVahcmtDrql00r1LPIguFkjZkILKewSILaebvEDgaJpVxS0NffSC(GIoZ9Du(GzWNyjvwuxTMj45VcgW143dlwaEws3aezjjHfvigZIcwApQTlpuN)fMfGYI6Q1mbp)vWaUg)EyXssclbicQ86m1JA7YnNyjjHf1vRzu1qiOEHpZkIffSOUAnJQgcb1l8zgQZ)cZcqzrD1AMGN)kyaxJFpSybyS0JfGelaplZQOgCqrMO57Gd476SpbV(qoAPX(yiG76JIiqw6ZsFwuWIvSOUAntWZFfmRiwuWspwSILaebvEDM6rTD5MtSKKWsac1GqlLjaleqaP8TrzC0p)HnRiwssyrfIXSOGL2JA7Yd15FHzbOSeGqni0szcWcbeqkFBugh9ZFyZqD(xywaglahwssyP9O2U8qD(xywqQSOeqiDwaklQRwZe88xbd4A87Hfl9T3bjCy(O7HL9ESJjwqwkqI1wbwS83glidwiGasibP0xGdbYYE0p)HzXlqwaHf6owGiOXY8hXcaEPX(WcCyXYgvSednecQx4JflWLgKfc5r)qSOsn4qSGSuGeRTcSqip6hcBVJWNC5DK9EamhGf4FpSY4Z(SJLsa02627u5QAc0og27E4EyzVpocQGlCUnuLY427GeomF09WYEp2Xel3gXcasuDBXhwS83glolilfiXARal3MFS84cDhlTb2XcaEPX(yVhM)O5D7D1vRzcE(RGzOo)lmlPYIsOHLKewuxTMj45VcgW143dlwaklXmDwuWccFExvtMayoalW)EyLXN9zhlLIPT1T3PYv1eODmS3dZF08U9ocFExvtMayoalW)EyLXhlkyPhlwXI6Q1mbp)vWaUg)EyXsQSeZ0zjjHfRyjarqLxNbbv3w8HL(SKKWI6Q1mJJGk4cNBdvPmUzfXIcwuxTMzCeubx4CBOkLXnd15FHzbOSaKybySeGf46pt0qHhtzx)OQoQoZ9DugHRxelaJLESyflQRwZOQHqq9cFMvelkyXkwoxt1zWNpA4aAOYv1eil9T39W9WYEpqAcFVRZU(rvDuD2NDSuYASTU9ovUQMaTJH9Ey(JM3T3r4Z7QAYeaZbyb(3dRm(S39W9WYE)RGpLFpSSp7yPeASTU9ovUQMaTJH9omYEhtN9UhUhw27i85DvnzVJW1lYE3kwcqOgeAPmbp)vWmKdgNLKewSIfe(8UQMmbyHaciLbjC8kWIcwcqeu51zQh12LBoXssclGZ6bnfmhaX27GeomF09WYEhajFExvtSSWeilWIfx91)9eMLBZpwS41XYbzrLyb7iiqwAWHfKLcKyTvGfmKLBZpwUnkol(q1XIfhFeilaiVWhlQudoel3g1zVJWNC5DK9o2rq5gCYbp)vW(SJLsahBRBVtLRQjq7yyV7H7HL9EBnXZWwM0RIS3bjCy(O7HL9ESJjmlXgi6XY3y5lw8If0lO)imXIxGSCZtywoil6Viw(JLvelw(BJfa8sJ9bTSGSuGeRTcS4filPa0JUhbXYUfF6S3dZF08U9of0FeMmFL9kolkyXJYHnkailkyrD1AMO57Gd476SpbV(qoAPX(yq46fXcqzbGwt6SOGLESacpJd6r3JGYyl(0Lb9ohfzUpa4xOyjjHfRyjarqLxNPOWa1WbKL(SOGfe(8UQMmyhbLBWjh88xbwuWspwuxTMzCeubx4CBOkLXnd15FHzbOSaKybaYspwqdlaplZQOgCqrg8xTLoVfhF08UHkxvtGS0NffSOUAnZ4iOcUW52qvkJBwrSKKWIvSOUAnZ4iOcUW52qvkJBwrS03(SJLsarBRBVtLRQjq7yyV7H7HL9o(8P5AT9oiHdZhDpSS3JDmXca6IUnw2pFAUwZs0adyw(gl7NpnxRz5Xf6owwr27H5pAE3ExD1Agyr3gohrtGIUhwMvelkyrD1Ag85tZ1AZqTHWBUQMSp7yPeqW2627u5QAc0og27H5pAE3ExD1Ag85JgoGMH68VWSauwqdlkyPhlQRwZqb9hHPmgQ9XmuN)fMLuzbnSKKWI6Q1muq)rykRxLpMH68VWSKklOHL(SOGfhFJRZrql0WsQSaKs3E3d3dl79GxbsNvxTM9U6Q1YL3r274ZhnCaTp7yPeqY2627u5QAc0og27E4EyzVJpFWRbfzVds4W8r3dl79y7QlcZskWaywuPgCiwqgSqabKyzH)cfl3gXcYGfciGelbyb(3dlwoilHnkailFJfKbleqajwEmlE4wUwhNfxfUowoilQelbhF27H5pAE3EparqLxNPEuBxU5elkybHpVRQjtawiGaszqchVcSOGLaeQbHwktawiGas5BJY4OF(dBgQZ)cZcqzbnSOGfRybCwpOPG5aiMffSqb9hHjZxzVIZIcwC8nUohbTqdlPYI1KU9zhlaMUT1T3PYv1eODmS39W9WYEhF(0CT2EhKWH5JUhw27XoMyz)8P5Anlw(BJL9J0AFyj2oF7yXlqwkil7NpA4aIwwSSrflfKL9ZNMR1S8ywwrOLL4Wfl(qS8flO)Q8Hf0lO)imXsdoSaeagMcywGdlhKLObgybaV0yFyXYgvS4QqeelaP0zjfyamlWHfhmYVhbXc2IpDSS5ywacadtbmld15F9fkwGdlpMLVyPPFuBNHLybpILBZpwwfinSCBelyVJyjalW)EyHz5p0HzbmcZsrRBCnlhKL9ZNMR1SaUMVqXcachbvWfMLyZqvkJJwwSSrflXHl0bYc(ETMfQazzfXIL)2ybiLoWCCeln4WYTrSOD8Xcknu11yJ9Ey(JM3T3pxt1zWhP1(KbNVDgQCvnbYIcwSILZ1uDg85JgoGgQCvnbYIcwuxTMbF(0CT2muBi8MRQjwuWspwuxTMHc6pctz9Q8XmuN)fMLuzbiWIcwOG(JWK5RSEv(WIcwuxTMjA(o4a(Uo7tWRpKJwASpgeUErSauwaiAsNLKewuxTMjA(o4a(Uo7tWRpKJwASpgeUErSKQYSaq0KolkyXX346Ce0cnSKklaP0zjjHfq4zCqp6EeugBXNUmO35OiZqD(xywsLfGaljjS4H7HLXb9O7rqzSfF6YGENJImFLB6h12XsFwuWsac1GqlLj45VcMH68VWSKklkLU9zhlaQKT1T3PYv1eODmS39W9WYEhF(GxdkYEhKWH5JUhw27XoMyz)8bVguelaOl62yjAGbmlEbYc4QlILuGbWSyzJkwqwkqI1wbwGdl3gXcasuDBXhwuxTglpMfxfUowoilnxRzb2ASahwIdxOdKLGhXskWay79W8hnVBVRUAndSOBdNdAYNmIh)WYSIyjjHf1vRza8lWHaZuxe0cnDuDzQOb1NsYSIyjjHf1vRzcE(RGzfXIcw6XI6Q1mJJGk4cNBdvPmUzOo)lmlaLfubqtNJCwaEwc0RzPhlo(gxNJGwOHfKWsmtNL(SamwIjlaplNRP6mfzj3bHLHkxvtGSOGfRyzwf1GdkYG)QT05T44JM3nu5QAcKffSOUAnZ4iOcUW52qvkJBwrSKKWI6Q1mbp)vWmuN)fMfGYcQaOPZrolaplb61S0JfhFJRZrql0WcsyjMPZsFwssyrD1AMXrqfCHZTHQugpJ)QT05T44JM3nRiwssyXkwuxTMzCeubx4CBOkLXnRiwuWIvSeGqni0szghbvWfo3gQszCZqoyCwssyXkwcqeu51zqq1TfFyPpljjS44BCDocAHgwsLfGu6SOGfkO)imz(k7vC7ZowaeG2w3ENkxvtG2XWE3d3dl7D85dEnOi7DqchMp6EyzVB9jolhKLohqILBJyrLWhlWgl7NpA4aYIACwWNha8luS8hlRiwaURpaOoolFXIxXzb9c6pctSOUowaWln2hwECDS4QW1XYbzrLyjAGHabAVhM)O5D79Z1uDg85JgoGgQCvnbYIcwSILzvudoOiZ9DKf4uzWH8o1VaPXqLRQjqwuWspwuxTMbF(OHdOzfXssclo(gxNJGwOHLuzbiLol9zrblQRwZGpF0Wb0GppailaLLyYIcw6XI6Q1muq)rykJHAFmRiwssyrD1AgkO)imL1RYhZkIL(SOGf1vRzIMVdoGVRZ(e86d5OLg7JbHRxelaLfacetNffS0JLaeQbHwktWZFfmd15FHzjvwukDwssyXkwq4Z7QAYeGfciGugKWXRalkyjarqLxNPEuBxU5el9Tp7ybWyABD7DQCvnbAhd7DyK9oMo7DpCpSS3r4Z7QAYEhHRxK9of0FeMmFL1RYhwaEwacSGew8W9WYGpFA)qgc5uyDu((oIfGXIvSqb9hHjZxz9Q8HfGNLESaCybySCUMQZGHlDg2Y3gLBWHWNHkxvtGSa8Setw6ZcsyXd3dlJLXVndHCkSokFFhXcWyjDJ1Ggwqcl4isRZBo(iwaglPBqdlaplNRP6mLFRHWzvx7vGmu5QAc0EhKWH5JUhw27Oh((o)imlBqlS0TcBSKcmaMfFiwq5FrGSerdlykalq7De(KlVJS3DCeaMMDkyF2XcGwJT1T3PYv1eODmS39W9WYEhF(GxdkYEhKWH5JUhw27X2vxel7Np41GIy5lwCwaIadtbw2HAFyb9c6pctOLfqyHUJfnDS8hlrdmWcaEPX(WsVBZpwEmlBEbQjqwuJZc93gnSCBel7NpnxRzr)fXcCy52iwsbgaNkqkDw0FrS0Gdl7Np41GI6JwwaHf6owGiOXY8hXIxSaGUOBJLObgyXlqw00XYTrS4Qqeel6Viw28cutSSF(OHdO9Ey(JM3T3TILzvudoOiZ9DKf4uzWH8o1VaPXqLRQjqwuWspwuxTMjA(o4a(Uo7tWRpKJwASpgeUErSauwaiqmDwssyrD1AMO57Gd476SpbV(qoAPX(yq46fXcqzbGOjDwuWY5AQod(iT2Nm48TZqLRQjqw6ZIcw6Xcf0FeMmFLXqTpSOGfhFJRZrql0WcWybHpVRQjJJJaW0StbwaEwuxTMHc6pctzmu7JzOo)lmlaJfq4zARjEg2YKEvK5(aG48qD(xSa8SaqdAyjvwacPZsscluq)ryY8vwVkFyrblo(gxNJGwOHfGXccFExvtghhbGPzNcSa8SOUAndf0FeMY6v5JzOo)lmlaJfq4zARjEg2YKEvK5(aG48qD(xSa8SaqdAyjvwasPZsFwuWIvSOUAndSOBdNJOjqr3dlZkIffSyflNRP6m4ZhnCanu5QAcKffS0JLaeQbHwktWZFfmd15FHzjvwaISKKWcgU0QFbAUT516mMiaPXqLRQjqwuWI6Q1m328ADgteG0yWNhaKfGYsmJjlaqw6XYSkQbhuKb)vBPZBXXhnVBOYv1eilaplOHL(SOGL2JA7Yd15FHzjvwuk90zrblTh12LhQZ)cZcqzbGPNol9zrbl9yjaHAqOLYa4xGdbMXr)8h2muN)fMLuzbiYssclwXsaIGkVodGXN3lw6BF2XcGOX2627u5QAc0og27E4EyzVxKLChew27GeomF09WYEp2XelaOGWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3awSzP1SaGcclwAWHfKLcKyTvGfVazbP0xGdbYc61fbTqthvN9Ey(JM3T37XI6Q1muq)rykRxLpMH68VWSKkleYPW6O89DeljjS0JLWMpOimlkZcazrbldf28bfLVVJybOSGgw6ZssclHnFqrywuMLyYsFwuWIhLdBuaqwuWccFExvtgSJGYn4KdE(RG9zhlacCSTU9ovUQMaTJH9Ey(JM3T37XI6Q1muq)rykRxLpMH68VWSKkleYPW6O89DelkyXkwcqeu51zam(8EXsscl9yrD1Aga)cCiWm1fbTqthvxMkAq9PKmRiwuWsaIGkVodGXN3lw6Zsscl9yjS5dkcZIYSaqwuWYqHnFqr577iwaklOHL(SKKWsyZhueMfLzjMSKKWI6Q1mbp)vWSIyPplkyXJYHnkailkybHpVRQjd2rq5gCYbp)vGffS0Jf1vRzghbvWfo3gQszCZqD(xywakl9ybnSaazbGSa8SmRIAWbfzWF1w68wC8rZ7gQCvnbYsFwuWI6Q1mJJGk4cNBdvPmUzfXssclwXI6Q1mJJGk4cNBdvPmUzfXsF7DpCpSS33CDl3bHL9zhlaceTTU9ovUQMaTJH9Ey(JM3T37XI6Q1muq)rykRxLpMH68VWSKkleYPW6O89DelkyXkwcqeu51zam(8EXsscl9yrD1Aga)cCiWm1fbTqthvxMkAq9PKmRiwuWsaIGkVodGXN3lw6Zsscl9yjS5dkcZIYSaqwuWYqHnFqr577iwaklOHL(SKKWsyZhueMfLzjMSKKWI6Q1mbp)vWSIyPplkyXJYHnkailkybHpVRQjd2rq5gCYbp)vGffS0Jf1vRzghbvWfo3gQszCZqD(xywaklOHffSOUAnZ4iOcUW52qvkJBwrSOGfRyzwf1GdkYG)QT05T44JM3nu5QAcKLKewSIf1vRzghbvWfo3gQszCZkIL(27E4EyzV3wADUdcl7ZowaeiyBD7DQCvnbAhd7DqchMp6EyzVh7yIfKci6XcSyjaAV7H7HL9UfFMhozylt6vr2NDSaiqY2627u5QAc0og27E4EyzVJpFA)q27GeomF09WYEp2Xel7NpTFiwoilrdmWYou7dlOxq)rycTSGSuGeRTcSS5yw0egZY9Del3MxS4SGum(TXcHCkSoIfn1owGdlWshNf0Fv(Wc6f0FeMy5XSSIS3dZF08U9of0FeMmFL1RYhwssyHc6pctgmu7tUiKFSKKWcf0FeMmEfpxeYpwssyPhlQRwZyXN5Htg2YKEvKzfXsscl4isRZBo(iwaklPBSg0WIcwSILaebvEDgeuDBXhwssybhrADEZXhXcqzjDJ1WIcwcqeu51zqq1TfFyPplkyrD1AgkO)imL1RYhZkILKew6XI6Q1mbp)vWmuN)fMfGYIhUhwglJFBgc5uyDu((oIffSOUAntWZFfmRiw6BF2XkMPBBD7DQCvnbAhd7DqchMp6EyzVh7yIfKIXVnwG3gnwEmXILTpSXYJz5lw2HAFyb9c6pctOLfKLcKyTvGf4WYbzjAGbwq)v5dlOxq)ryYE3d3dl7DlJFB2NDSIPs2w3ENkxvtG2XWEhKWH5JUhw27XgxRVTzzV7H7HL9(SQShUhwz9Jp7D9JVC5DK9EZ16BBw2N9zVhnua2P6NT1TJLs2w3E3d3dl7Da)cCiWmo6N)W27u5QAc0og2NDSaOT1T3PYv1eODmS3Hr27y6S39W9WYEhHpVRQj7DeUEr27PBVds4W8r3dl7DRVrSGWN3v1elpMfmDSCqwsNfl)TXsbzbF(XcSyzHjwU5laPdJwwuIflBuXYTrS0(bFSalILhZcSyzHj0Ycaz5BSCBelykalqwEmlEbYsmz5BSOcVnw8HS3r4tU8oYEhw5fMY38fG0zF2XkM2w3ENkxvtG2XWEhgzV7GG27E4EyzVJWN3v1K9ocxVi7DLS3dZF08U9(nFbiDMtjZMJZlmLvxTglky5MVaKoZPKjaHAqOLYaUg)EyXIcwSILB(cq6mNsMhBoyhLHTChSW3ax4Caw4BwH7Hf2EhHp5Y7i7DyLxykFZxasN9zhlRX2627u5QAc0og27Wi7Dhe0E3d3dl7De(8UQMS3r46fzVdq79W8hnVBVFZxasN5aOzZX5fMYQRwJffSCZxasN5aOjaHAqOLYaUg)EyXIcwSILB(cq6mhanp2CWokdB5oyHVbUW5aSW3Sc3dlS9ocFYL3r27WkVWu(MVaKo7ZowOX2627u5QAc0og27Wi7Dhe0E3d3dl7De(8UQMS3r4tU8oYEhw5fMY38fG0zVhM)O5D7Dc4U(Oic08fomRZv1ug4U86wDzqcXhiwssyHaURpkIanuxu8HCDgoGLxbILKewiG76JIiqdgU0A6UVqLNLAC7DqchMp6EyzVB9nctSCZxashMfFiwk4XIVUo)(GR1XzbKokCeiloMfyXYctSGp)y5MVaKoSHLuOT4XXS4GGFHIfLyPJ8cZYTrXzXYR1S4AlECmlQelrd1Oziqw(cKIOcKQJfyJfSgE27iC9IS3vY(SJfWX2627E4EyzV3bHfGFLBWPZENkxvtG2XW(SJfq02627u5QAc0og27E4EyzVBz8BZEx)fLdG27kLU9Ey(JM3T37Xcf0FeMm6v5tUiKFSKKWcf0FeMmFLXqTpSKKWcf0FeMmFLvH3gljjSqb9hHjJxXZfH8JL(27GeomF09WYEhapuWXhlaKfKIXVnw8cKfNL9Zh8AqrSalw2Tolw(BJLy9O2owInoXIxGSedykSolWHL9ZN2pelWBJglpMSp7ybeSTU9ovUQMaTJH9Ey(JM3T37Xcf0FeMm6v5tUiKFSKKWcf0FeMmFLXqTpSKKWcf0FeMmFLvH3gljjSqb9hHjJxXZfH8JL(SOGLOHqyuYyz8BJffSyflrdHWaqJLXVn7DpCpSS3Tm(TzF2XcizBD7DQCvnbAhd79W8hnVBVBflZQOgCqrgvx7vGYWw2168T9fkSHkxvtGSKKWIvSeGiOYRZupQTl3CILKewSIfCeP15Zhu0Hn4ZNMR1SOmlkXssclwXY5AQot53AiCw11EfidvUQMazjjHLESqb9hHjdgQ9jxeYpwssyHc6pctMVY6v5dljjSqb9hHjZxzv4TXsscluq)ryY4v8Cri)yPV9UhUhw274ZN2pK9zhlLs32627u5QAc0og27H5pAE3EFwf1GdkYO6AVcug2YUwNVTVqHnu5QAcKffSeGiOYRZupQTl3CIffSGJiToF(GIoSbF(0CTMfLzrj7DpCpSS3XNp41GISp7Z(S3rqd(HLDSay6auP0bIPdKS3T4t9fkS9osrkaqelRnwiLdKzHfRVrS8DrW5yPbhwqhi18L(qhldbCx)qGSGHDel(6GD(rGSe28cfHnCAO)xelwdqMfKble0Ceil7FhYybhVoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6PeY7B40q)ViwSgGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WPH(FrSGgGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WPH(FrSaCaYSGmyHGMJazz)7qgl4415iNfKklhKf0F5Sa(iE8dlwGr04hCyPhs6ZspaI8(gon0)lIfGiqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwaIazwqgSqqZrGSGUB(cq6mkzaaOJLdYc6U5laPZCkzaaOJLEae59nCAO)xelarGmlidwiO5iqwq3nFbiDgaAaaOJLdYc6U5laPZCa0aaqhl9aiY7B40q)ViwacazwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtd9)IybibKzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHkxvtGOJLEkH8(gon0)lIfLshiZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCAO)xelkPeqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwucGazwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtd9)IyrPycKzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHkxvtGOJLEae59nCAO)xelkftGmlidwiO5iqwq3nFbiDgLmaa0XYbzbD38fG0zoLmaa0XspaI8(gon0)lIfLIjqMfKble0CeilO7MVaKodanaa0XYbzbD38fG0zoaAaaOJLEkH8(gon0)lIfLSgGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0dGiVVHtd9)IyrjRbiZcYGfcAocKf0DZxasNrjdaaDSCqwq3nFbiDMtjdaaDS0tjK33WPH(FrSOK1aKzbzWcbnhbYc6U5laPZaqdaaDSCqwq3nFbiDMdGgaa6yPharEFdNgNgsrkaqelRnwiLdKzHfRVrS8DrW5yPbhwqx0qbyNQFOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon0)lILycKzbzWcbnhbYc6U5laPZOKbaGowoilO7MVaKoZPKbaGow6ftK33WPH(FrSynazwqgSqqZrGSGUB(cq6ma0aaqhlhKf0DZxasN5aObaGow6ftK33WPH(FrSaKaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNg6)fXIsPdKzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHkxvtGOJLEkH8(gononKIuaGiwwBSqkhiZclwFJy57IGZXsdoSGohsOJLHaURFiqwWWoIfFDWo)iqwcBEHIWgon0)lIfLaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XIFSGEaOrFw6PeY7B40q)ViwIjqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwaoazwqgSqqZrGSS)DiJfC86CKZcsfPYYbzb9xolDqWLEHzbgrJFWHLEi1(S0tjK33WPH(FrSaCaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspaI8(gon0)lIfGiqMfKble0Ceil7FhYybhVoh5SGurQSCqwq)LZsheCPxywGr04hCyPhsTpl9uc59nCAO)xelarGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WPH(FrSaeaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNg6)fXcqciZcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9aiY7B40q)ViwucGazwqgSqqZrGSS)DiJfC86CKZcsLLdYc6VCwaFep(HflWiA8doS0dj9zPNsiVVHtd9)IyrjGeqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwaOsazwqgSqqZrGSS)DiJfC86CKZcsLLdYc6VCwaFep(HflWiA8doS0dj9zPNsiVVHtd9)IybGXeiZcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9aiY7B40q)ViwaymbYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNg6)fXcardqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwaiWbiZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCAO)xelaeiaKzbzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEae59nCAO)xelaeibKzbzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEkH8(gononKIuaGiwwBSqkhiZclwFJy57IGZXsdoSGUMR132SqhldbCx)qGSGHDel(6GD(rGSe28cfHnCAO)xelaeiZcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9uc59nCACAifPaarSS2yHuoqMfwS(gXY3fbNJLgCybD4dDSmeWD9dbYcg2rS4Rd25hbYsyZlue2WPH(FrSOeqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwIjqMfKble0CeilOBwf1GdkYaaqhlhKf0nRIAWbfzaagQCvnbIow6PeY7B40q)ViwusjGmlidwiO5iqw2)oKXcoEDoYzbPIuz5GSG(lNLoi4sVWSaJOXp4WspKAFw6PeY7B40q)ViwusjGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WPH(FrSOeWbiZcYGfcAocKf0nRIAWbfzaaOJLdYc6Mvrn4GImaadvUQMarhl9uc59nCAO)xelaujGmlidwiO5iqw2)oKXcoEDoYzbPYYbzb9xolGpIh)WIfyen(bhw6HK(S0dGiVVHtd9)IybGkbKzbzWcbnhbYc6Mvrn4GImaa0XYbzbDZQOgCqrgaGHkxvtGOJLEkH8(gon0)lIfacqGmlidwiO5iqwq3SkQbhuKbaGowoilOBwf1GdkYaamu5QAceDS0tjK33WPH(FrSaWycKzbzWcbnhbYY(3HmwWXRZrolivwoilO)Yzb8r84hwSaJOXp4WspK0NLEXe59nCAO)xela0AaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspaI8(gon0)lIfacCaYSGmyHGMJazbDZQOgCqrgaa6y5GSGUzvudoOidaWqLRQjq0XspLqEFdNg6)fXcabIazwqgSqqZrGSGUzvudoOidaaDSCqwq3SkQbhuKbayOYv1ei6yPNsiVVHtJtdPifaiIL1glKYbYSWI13iw(Ui4CS0GdlOtf6h6yziG76hcKfmSJyXxhSZpcKLWMxOiSHtd9)IyrjGaqMfKble0Ceil7FhYybhVoh5SGuz5GSG(lNfWhXJFyXcmIg)Gdl9qsFw6ftK33WPH(FrSOeqciZcYGfcAocKL9VdzSGJxNJCwqQSCqwq)LZc4J4XpSybgrJFWHLEiPpl9uc59nCACAwBxeCocKfGdlE4EyXI(Xh2WPzVhnW2Rj7DKgPzjgU2RaXsSDwpiNgsJ0SK2shNfLshTSaW0bOsCACAinsZcY28cfHbYCAinsZcaKLuacsGSSd1(WsmiVZWPH0inlaqwq2MxOiqwoFqrx(BSeCmHz5GSeIh0u(8bfDydNgsJ0Saazbab1brqGSSQIceg7tCwq4Z7QAcZsV3qg0Ys0qiY4Zh8AqrSaatLLOHqyWNp41GI6B40qAKMfailPab8bzjAOGJVVqXcsX43glFJL)qhMLBJyXYaluSGEb9hHjdNgsJ0SaazbaLdiXcYGfciGel3gXYE0p)HzXzr)3Pjw6GdXstti)v1el9(glXHlw2CWcDhlB)XYFSG)UL(8IGlSoolw(BJLyaGofwNfGXcYinHV31SKc9JQ6O6qll)HoqwWa(r9nCAinsZcaKfauoGelDq8Xc6ApQTlpuN)fgDSGdu5ZdXS4rr64SCqwuHymlTh12Hzbw64gonKgPzbaYI1hYpwSoSJyb2yjgAFJLyO9nwIH23yXXS4SGJOW7AwU5laPZWPXPH0inlPOk45hbYsmCTxbILuaGrFwcEXIkXsdUkqw8JLT7IWazKGevx7vGaG4Vlyq932s18qKedx7vGaG7FhYqshOz760iLT9Aszvx7vGmhYpononpCpSWMOHcWov)ugWVahcmJJ(5pmNgsZI13iwq4Z7QAILhZcMowoilPZIL)2yPGSGp)ybwSSWel38fG0HrllkXILnQy52iwA)GpwGfXYJzbwSSWeAzbGS8nwUnIfmfGfilpMfVazjMS8nwuH3gl(qCAE4EyHnrdfGDQ(bmLrccFExvtOT8oszyLxykFZxashAr46fPC6CAE4EyHnrdfGDQ(bmLrccFExvtOT8oszyLxykFZxashAHrk7GGOfHRxKYkH2VP8nFbiDgLmBooVWuwD1AkU5laPZOKjaHAqOLYaUg)EyPWQB(cq6mkzES5GDug2YDWcFdCHZbyHVzfUhwyonpCpSWMOHcWov)aMYibHpVRQj0wEhPmSYlmLV5laPdTWiLDqq0IW1lszaI2VP8nFbiDgaA2CCEHPS6Q1uCZxasNbGMaeQbHwkd4A87HLcRU5laPZaqZJnhSJYWwUdw4BGlCoal8nRW9WcZPH0Sy9nctSCZxashMfFiwk4XIVUo)(GR1XzbKokCeiloMfyXYctSGp)y5MVaKoSHLuOT4XXS4GGFHIfLyPJ8cZYTrXzXYR1S4AlECmlQelrd1Oziqw(cKIOcKQJfyJfSgECAE4EyHnrdfGDQ(bmLrccFExvtOT8oszyLxykFZxashAHrk7GGOfHRxKYkH2VPmbCxFuebA(chM15QAkdCxEDRUmiH4duscbCxFuebAOUO4d56mCalVcuscbCxFuebAWWLwt39fQ8SuJZP5H7Hf2enua2P6hWugjDqyb4x5gC640qAwaWdfC8XcazbPy8BJfVazXzz)8bVguelWILDRZIL)2yjwpQTJLyJtS4filXaMcRZcCyz)8P9dXc82OXYJjonpCpSWMOHcWov)aMYiXY43gA1Fr5aOYkLoA)MY9OG(JWKrVkFYfH8ljHc6pctMVYyO2NKekO)imz(kRcVTKekO)imz8kEUiKF9508W9WcBIgka7u9dykJelJFBO9Bk3Jc6pctg9Q8jxeYVKekO)imz(kJHAFssOG(JWK5RSk82ssOG(JWKXR45Iq(1xr0qimkzSm(TPWQOHqyaOXY43gNMhUhwyt0qbyNQFatzKGpFA)qO9BkB1SkQbhuKr11EfOmSLDToFBFHcNKyvaIGkVot9O2UCZPKeRWrKwNpFqrh2GpFAUwRSsjjwDUMQZu(TgcNvDTxbYqLRQjWKKEuq)ryYGHAFYfH8ljHc6pctMVY6v5tscf0FeMmFLvH3wscf0FeMmEfpxeYV(CAE4EyHnrdfGDQ(bmLrc(8bVgueA)MYZQOgCqrgvx7vGYWw2168T9fkSIaebvEDM6rTD5MtkWrKwNpFqrh2GpFAUwRSsCACAinsZc6HCkSocKfcbnXz5(oILBJyXdhCy5XS4i8x7QAYWP5H7Hfwzmu7twL8oonKMLD6WSKci6XcSyjMaJfl)TbxhlGZ3ow8cKfl)TXY(5JgoGS4filaeySaVnAS8yItZd3dlmWugji85DvnH2Y7iLFC2HeAr46fPmoI0685dk6Wg85tZ16uvsrpRoxt1zWNpA4aAOYv1eysY5AQod(iT2Nm48TZqLRQjW(jj4isRZNpOOdBWNpnxRtfGCAinl70HzjOjhbXILnQyz)8P9dXsWlw2(JfacmwoFqrhMflBFyJLhZYqAcHxhln4WYTrSGEb9hHjwoilQelrd1Oziqw8cKflBFyJL2R10WYbzj44JtZd3dlmWugji85DvnH2Y7iLFCoOjhbHweUErkJJiToF(GIoSbF(0(HsvjonKMLyhtSedAW0a4xOyXYFBSGSuGeRTcSahw82rdlidwiGasS8flilfiXARaNMhUhwyGPmsuPbtdGFHcTFt5EwfGiOYRZupQTl3CkjXQaeQbHwktawiGas5BJY4OF(dBwr9vOUAntWZFfmd15FHtvj0OqD1AMXrqfCHZTHQug3muN)fgOwJcRcqeu51zqq1TfFsscqeu51zqq1TfFuOUAntWZFfmRifQRwZmocQGlCUnuLY4MvKIEQRwZmocQGlCUnuLY4MH68VWavjLaGOb4Nvrn4GIm4VAlDElo(O59Ke1vRzcE(RGzOo)lmqvsPKeLqQ4isRZBo(iGQKbnOPpNgsZcagESy5VnwCwqwkqI1wbwUn)y5Xf6owCwaWln2hwIgyGf4WILnQy52iwApQTJLhZIRcxhlhKfQa508W9WcdmLrse8EyH2VPS6Q1mbp)vWmuN)fovLqJIEwnRIAWbfzWF1w68wC8rZ7jjQRwZmocQGlCUnuLY4MH68VWavjGiaeGaV6Q1mQAieuVWNzfPqD1AMXrqfCHZTHQug3SI6NKOcXyfTh12LhQZ)cduaIgonKMfK56Ws7hHzXYgDB0WYc)fkwqgSqabKyPGwyXYR1S4An0clXHlwoil471Awco(y52iwWEhXI3bx1XcSXcYGfciGeWqwkqI1wbwco(WCAE4EyHbMYibHpVRQj0wEhPCawiGaszqchVcOfHRxKYb61961EuBxEOo)lmauj0aadqOgeAPmbp)vWmuN)fUpsvjGq69voqVUxV2JA7Yd15FHbGkHgaOsamDayac1GqlLjaleqaP8TrzC0p)Hnd15FH7JuvciKEFfwn(dMjeuDgheeBiK)4dNKeGqni0szcE(RGzOo)lCQFD0eb1(rG52JA7Yd15FHtscqOgeAPmbyHaciLVnkJJ(5pSzOo)lCQFD0eb1(rG52JA7Yd15FHbGkLEsIvbicQ86m1JA7YnNss8W9WYeGfciGu(2Omo6N)WgWh7QAcKtdPzj2XeilhKfqs7Xz52iwwyhfXcSXcYsbsS2kWILnQyzH)cflGWLQMybwSSWelEbYs0qiO6yzHDuelw2OIfVyXbbzHqq1XYJzXvHRJLdYc4tCAE4EyHbMYibHpVRQj0wEhPCamhGf4FpSqlcxViL71EuBxEOo)lCQkHMKKXFWmHGQZ4GGyZxPIM07ROxVEeWD9rreOH6IIpKRZWbS8kqk61laHAqOLYqDrXhY1z4awEfiZqD(xyGQeWj9KKaebvEDgeuDBXhfbiudcTugQlk(qUodhWYRazgQZ)cduLaoarG1tjLa(zvudoOid(R2sN3IJpAEVFFfwfGqni0szOUO4d56mCalVcKzihmE)(jj9iG76JIiqdgU0A6UVqLNLACf9SkarqLxNPEuBxU5ussac1GqlLbdxAnD3xOYZsnEoMwdAacPRKzOo)lmqvsjRPF)KKEbiudcTugvAW0a4xOmd5GXtsSA8azUbQ19v0RhbCxFuebA(chM15QAkdCxEDRUmiH4dKIaeQbHwkZx4WSoxvtzG7YRB1LbjeFGmd5GX7NK0JaURpkIan4nheAHaZWrndB5doDuDkcqOgeAPmhC6O6iW8x4h12LJjAqtmbOsMH68VW9ts61dHpVRQjdSYlmLV5laPtzLssq4Z7QAYaR8ct5B(cq6uoM9v07MVaKoJsMHCW45aeQbHwQKKB(cq6mkzcqOgeAPmd15FHt9RJMiO2pcm3EuBxEOo)lmauP07NKGWN3v1Kbw5fMY38fG0Pmav07MVaKodand5GXZbiudcTujj38fG0zaOjaHAqOLYmuN)fo1VoAIGA)iWC7rTD5H68VWaqLsVFsccFExvtgyLxykFZxasNYP3VF)KKaebvEDgaJpVx9tsuHySI2JA7Yd15FHbQ6Q1mbp)vWaUg)EyXPH0SaGKpVRQjwwycKLdYciP94S4vCwU5laPdZIxGSeaXSyzJkwS4)9fkwAWHfVyb9wrBW5DwIgyGtZd3dlmWugji85DvnH2Y7iLVT516mMiaPjBX)dTiC9Iu2kmCPv)c0CBZR1zmrasJHkxvtGjjTh12LhQZ)cNkatp9KevigRO9O2U8qD(xyGcq0aSEwt6aq1vRzUT516mMiaPXGppaiWdW(jjQRwZCBZR1zmrasJbFEaWuJjqaa2Bwf1GdkYG)QT05T44JM3bE00NtdPzj2XelOxxu8HCnlaOhWYRaXcathtbmlQudoelolilfiXARallmz408W9WcdmLrYct5)Oo0wEhPm1ffFixNHdy5vGq73uoaHAqOLYe88xbZqD(xyGcW0veGqni0szcWcbeqkFBugh9ZFyZqD(xyGcW0v0dHpVRQjZTnVwNXebinzl(FjjQRwZCBZR1zmrasJbFEaWuJz6aR3SkQbhuKb)vBPZBXXhnVd8aN(9tsuHySI2JA7Yd15FHbAmbICAinlXoMyzhU0A6(cflaiwQXzb4GPaMfvQbhIfNfKLcKyTvGLfMmCAE4EyHbMYizHP8FuhAlVJugdxAnD3xOYZsnoA)MYbiudcTuMGN)kygQZ)cduGJcRcqeu51zqq1TfFuyvaIGkVot9O2UCZPKKaebvEDM6rTD5MtkcqOgeAPmbyHaciLVnkJJ(5pSzOo)lmqbok6HWN3v1KjaleqaPmiHJxHKKaeQbHwktWZFfmd15FHbkWPFssaIGkVodcQUT4JIEwnRIAWbfzWF1w68wC8rZ7kcqOgeAPmbp)vWmuN)fgOaNKe1vRzghbvWfo3gQszCZqD(xyGQK1aSEOb4jG76JIiqZx4BwHdo4m4J4lkRsADFfQRwZmocQGlCUnuLY4Mvu)KevigRO9O2U8qD(xyGcq0WP5H7HfgykJKfMY)rDOT8os5VWHzDUQMYa3Lx3Qldsi(aH2VPS6Q1mbp)vWmuN)fovLqJIEwnRIAWbfzWF1w68wC8rZ7jjQRwZmocQGlCUnuLY4MH68VWavjacSEXe4vxTMrvdHG6f(mRO(aRxpGiaenaV6Q1mQAieuVWNzf1h4jG76JIiqZx4BwHdo4m4J4lkRsADFfQRwZmocQGlCUnuLY4Mvu)KevigRO9O2U8qD(xyGcq0WPH0Se7yIL5rTDSOsn4qSeaXCAE4EyHbMYizHP8FuhAlVJugV5GqleygoQzylFWPJQdTFt5EbiudcTuMGN)kygYbJRWQaebvEDM6rTD5Mtkq4Z7QAYCBZR1zmrast2I)xssaIGkVot9O2UCZjfbiudcTuMaSqabKY3gLXr)8h2mKdgxrpe(8UQMmbyHaciLbjC8kKKeGqni0szcE(RGzihmE)(kaHNbVQ2pK5(aGFHsrpq4zWhP1(KBAFiZ9ba)cvsIvNRP6m4J0AFYnTpKHkxvtGjj4isRZNpOOdBWNpTFOuJzFf9aHNPdcR2pK5(aGFHQVIEi85DvnzEC2HusYSkQbhuKr11EfOmSLDToFBFHcNK44BCDocAHMuvgiLEsI6Q1mQAieuVWNzf1xrVaeQbHwkJknyAa8luMHCW4jjwnEGm3a16(jjQqmwr7rTD5H68VWa1AsNtdPzX6BpMLhZIZY43gnSqAxfo(rSyXJZYbzPZbKyX1AwGfllmXc(8JLB(cq6WSCqwujw0FrGSSIyXYFBSGSuGeRTcS4filidwiGasS4fillmXYTrSaWcKfSgESalwcGS8nwuH3gl38fG0HzXhIfyXYctSGp)y5MVaKomNMhUhwyGPmswyk)h1HrlwdpSY38fG0PeA)MYi85DvnzGvEHP8nFbiDkdqfwDZxasNbGMHCW45aeQbHwQKKEi85DvnzGvEHP8nFbiDkRusccFExvtgyLxykFZxasNYXSVIEQRwZe88xbZksrpRcqeu51zqq1TfFssuxTMzCeubx4CBOkLXnd15FHbwp0a8ZQOgCqrg8xTLoVfhF08EFGQ8nFbiDgLmQRwldUg)EyPqD1AMXrqfCHZTHQug3SIssuxTMzCeubx4CBOkLXZ4VAlDElo(O5DZkQFssac1GqlLj45VcMH68VWadGPEZxasNrjtac1GqlLbCn(9WsHvQRwZe88xbZksrpRcqeu51zQh12LBoLKyfcFExvtMaSqabKYGeoEf6RWQaebvEDgaJpVxjjbicQ86m1JA7YnNuGWN3v1KjaleqaPmiHJxbfbiudcTuMaSqabKY3gLXr)8h2SIuyvac1GqlLj45VcMvKIE9uxTMHc6pctz9Q8XmuN)fovLspjrD1AgkO)imLXqTpMH68VWPQu69vy1SkQbhuKr11EfOmSLDToFBFHcNK0tD1Agvx7vGYWw2168T9fkCU8BnKbFEaqLrtsI6Q1mQU2RaLHTSR15B7lu4SpbVid(8aGkde63pjrD1Aga)cCiWm1fbTqthvxMkAq9PKmRO(jjTh12LhQZ)cduaMEsccFExvtgyLxykFZxasNYPZP5H7HfgykJKfMY)rDy0I1WdR8nFbiDaeTFtze(8UQMmWkVWu(MVaKoRugGkS6MVaKoJsMHCW45aeQbHwQKee(8UQMmWkVWu(MVaKoLbOIEQRwZe88xbZksrpRcqeu51zqq1TfFssuxTMzCeubx4CBOkLXnd15FHbwp0a8ZQOgCqrg8xTLoVfhF08EFGQ8nFbiDgaAuxTwgCn(9WsH6Q1mJJGk4cNBdvPmUzfLKOUAnZ4iOcUW52qvkJNXF1w68wC8rZ7Mvu)KKaeQbHwktWZFfmd15FHbgat9MVaKodanbiudcTugW143dlfwPUAntWZFfmRif9SkarqLxNPEuBxU5usIvi85DvnzcWcbeqkds44vOVcRcqeu51zam(8EPONvQRwZe88xbZkkjXQaebvEDgeuDBXN(jjbicQ86m1JA7YnNuGWN3v1KjaleqaPmiHJxbfbiudcTuMaSqabKY3gLXr)8h2SIuyvac1GqlLj45VcMvKIE9uxTMHc6pctz9Q8XmuN)fovLspjrD1AgkO)imLXqTpMH68VWPQu69vy1SkQbhuKr11EfOmSLDToFBFHcNK0tD1Agvx7vGYWw2168T9fkCU8BnKbFEaqLrtsI6Q1mQU2RaLHTSR15B7lu4SpbVid(8aGkde63VFsI6Q1ma(f4qGzQlcAHMoQUmv0G6tjzwrjjTh12LhQZ)cduaMEsccFExvtgyLxykFZxasNYPZPH0Se7ycZIR1SaVnAybwSSWel)rDywGflbqonpCpSWatzKSWu(pQdZPH0SeBPWdsS4H7Hfl6hFSO6ycKfyXc(VLFpSqIMq9yonpCpSWatzKmRk7H7Hvw)4dTL3rk7qcT4B(WPSsO9BkJWN3v1K5XzhsCAE4EyHbMYizwv2d3dRS(XhAlVJuwf6hAX38HtzLq73uEwf1GdkYO6AVcug2YUwNVTVqHneWD9rreiNMhUhwyGPmsMvL9W9WkRF8H2Y7iLXhNgNgsZcYCDyP9JWSyzJUnAy52iwITd5Db)cB0WI6Q1yXYR1S0CTMfyRXIL)2(ILBJyPiKFSeC8XP5H7Hf24qsze(8UQMqB5DKYGd5DzlVwNBUwNHTgAr46fPCp1vRzUVJSaNkdoK3P(finMH68VWafva005ihyPBukjrD1AM77ilWPYGd5DQFbsJzOo)lmq9W9WYGpFA)qgc5uyDu((ocyPBusrpkO)imz(kRxLpjjuq)ryYGHAFYfH8ljHc6pctgVINlc5x)(kuxTM5(oYcCQm4qEN6xG0ywrkMvrn4GIm33rwGtLbhY7u)cKgonKMfK56Ws7hHzXYgDB0WY(5dEnOiwEmlwGZTXsWX3xOybIGgw2pFA)qS8flO)Q8Hf0lO)imXP5H7Hf24qcykJee(8UQMqB5DKYpQcougF(GxdkcTiC9Iu2kkO)imz(kJHAFu0dhrAD(8bfDyd(8P9dLkAuCUMQZGHlDg2Y3gLBWHWNHkxvtGjj4isRZNpOOdBWNpTFOubI950qAwIDmXcYGfciGelw2OIf)yrtyml3MxSGM0zjfyamlEbYI(lILvelw(BJfKLcKyTvGtZd3dlSXHeWugjbyHaciLVnkJJ(5pmA)MYwboRh0uWCaeROxpe(8UQMmbyHaciLbjC8kOWQaeQbHwktWZFfmd5GXtsuxTMj45VcMvuFf9uxTMHc6pctz9Q8XmuN)fovGtsI6Q1muq)rykJHAFmd15FHtf40xrpRMvrn4GImQU2RaLHTSR15B7lu4Ke1vRzuDTxbkdBzxRZ32xOW5YV1qg85batnMjjQRwZO6AVcug2YUwNVTVqHZ(e8Im4ZdaMAm7NKOcXyfTh12LhQZ)cduLsxHvbiudcTuMGN)kygYbJ3NtdPzj2XelXMHQugNfl)TXcYsbsS2kWP5H7Hf24qcykJKXrqfCHZTHQughTFtz1vRzcE(RGzOo)lCQkHgonKMLyhtSSVQ2pelFXsKxGu3hybwS4v8B7luSCB(XI(rqywuYAWuaZIxGSOjmMfl)TXshCiwoFqrhMfVazXpwUnIfQazb2yXzzhQ9Hf0lO)imXIFSOK1WcMcywGdlAcJzzOo)RVqXIJz5GSuWJLnhXxOy5GSmuBi8glGR5luSG(RYhwqVG(JWeNMhUhwyJdjGPmsWRQ9dH2q8GMYNpOOdRSsO9Bk3BO2q4nxvtjjQRwZqb9hHPmgQ9XmuN)fgOXubf0FeMmFLXqTpkgQZ)cduLSgfNRP6my4sNHT8Tr5gCi8zOYv1eyFfNpOOZCFhLpyg8PuvYAaG4isRZNpOOddSH68VWk6rb9hHjZxzVINKmuN)fgOOcGMoh5950qAwqkruelRiw2pFAUwZIFS4Anl33rywwLMWyww4VqXc6hp4JJzXlqw(JLhZIRcxhlhKLObgyboSOPJLBJybhrH31S4H7Hfl6Viwujn0clBEbQjwITd5DQFbsdlWIfaYY5dk6WCAE4EyHnoKaMYibF(0CTgTFtzRoxt1zWhP1(KbNVDgQCvnbQON6Q1m4ZNMR1MHAdH3CvnPOhoI0685dk6Wg85tZ1AGgZKeRMvrn4GIm33rwGtLbhY7u)cKM(jjNRP6my4sNHT8Tr5gCi8zOYv1eOc1vRzOG(JWugd1(ygQZ)cd0yQGc6pctMVYyO2hfQRwZGpFAUwBgQZ)cduGOcCeP15Zhu0Hn4ZNMR1PQS10xrpRMvrn4GIm64bFCCUPj6(cvgL(7IWusY9DesfPAnOjv1vRzWNpnxRnd15FHbga7R48bfDM77O8bZGpLkA40qAwqk(BJL9J0AFyj2oF7yzHjwGflbqwSSrfld1gcV5QAIf11Xc(ETMfl(FS0GdlOF8GpoMLObgyXlqwaHf6owwyIfvQbhIfKfBXgw2VxRzzHjwuPgCiwqgSqabKyb)vGy528JflVwZs0adS4f82OHL9ZNMR1CAE4EyHnoKaMYibF(0CTgTFt5Z1uDg8rATpzW5BNHkxvtGkuxTMbF(0CT2muBi8MRQjf9SAwf1GdkYOJh8XX5MMO7luzu6Vlctjj33rivKQ1GMuTM(koFqrN5(okFWm4tPgtonKMfKI)2yj2oK3P(finSSWel7NpnxRz5GSairrSSIy52iwuxTglQXzX1yill8xOyz)8P5AnlWIf0WcMcWceZcCyrtymld15F9fkonpCpSWghsatzKGpFAUwJ2VP8SkQbhuK5(oYcCQm4qEN6xG0OahrAD(8bfDyd(8P5ADQkhtf9SsD1AM77ilWPYGd5DQFbsJzfPqD1Ag85tZ1AZqTHWBUQMss6HWN3v1KbCiVlB516CZ16mS1u0tD1Ag85tZ1AZqD(xyGgZKeCeP15Zhu0Hn4ZNMR1PcqfNRP6m4J0AFYGZ3odvUQMavOUAnd(8P5ATzOo)lmqrt)(950qAwqMRdlTFeMflB0Trdlol7Np41GIyzHjwS8AnlbFHjw2pFAUwZYbzP5AnlWwdTS4fillmXY(5dEnOiwoilasuelX2H8o1VaPHf85bazzfXP5H7Hf24qcykJee(8UQMqB5DKY4ZNMR1zlW6YnxRZWwdTiC9Iu2X346Ce0cnPcesha2tP0bE1vRzUVJSaNkdoK3P(fing85ba7da7PUAnd(8P5ATzOo)lmWhtKkoI068MJpc4T6CnvNbFKw7tgC(2zOYv1eyFayVaeQbHwkd(8P5ATzOo)lmWhtKkoI068MJpc4pxt1zWhP1(KbNVDgQCvnb2ha2deEM2AINHTmPxfzgQZ)cd8OPVIEQRwZGpFAUwBwrjjbiudcTug85tZ1AZqD(x4(CAinlXoMyz)8bVguelw(BJLy7qEN6xG0WYbzbqIIyzfXYTrSOUAnwS83gCDSOH4VqXY(5tZ1Awwr33rS4fillmXY(5dEnOiwGflwdWyjgWuyDwWNhaeZYQUxZI1WY5dk6WCAE4EyHnoKaMYibF(GxdkcTFtze(8UQMmGd5DzlVwNBUwNHTMce(8UQMm4ZNMR1zlW6YnxRZWwtHvi85DvnzEufCOm(8bVguussp1vRzuDTxbkdBzxRZ32xOW5YV1qg85batnMjjQRwZO6AVcug2YUwNVTVqHZ(e8Im4ZdaMAm7RahrAD(8bfDyd(8P5AnqTgfi85DvnzWNpnxRZwG1LBUwNHTgNgsZsSJjwWw8PJfmKLBZpwIdxSGIow6CKZYk6(oIf14SSWFHIL)yXXSO9JyXXSebX4xvtSalw0egZYT5flXKf85baXSahwaqEHpwSSrflXeySGppaiMfc5r)qCAE4EyHnoKaMYiXb9O7rqzSfF6qBiEqt5Zhu0Hvwj0(nLT6(aGFHsHvE4EyzCqp6EeugBXNUmO35OiZx5M(rTDjjGWZ4GE09iOm2IpDzqVZrrg85babAmvacpJd6r3JGYyl(0Lb9ohfzgQZ)cd0yYPH0SaGGAdH3ybafewTFiw(glilfiXARalpMLHCW4OLLBJgIfFiw0egZYT5flOHLZhu0Hz5lwq)v5dlOxq)ryIfl)TXYo8InOLfnHXSCBEXIsPZc82OXYJjw(IfVIZc6f0FeMyboSSIy5GSGgwoFqrhMfvQbhIfNf0Fv(Wc6f0FeMmSeBHf6owgQneEJfW18fkwqk9f4qGSGEDrql00r1XYQ0egZYxSSd1(Wc6f0FeM408W9WcBCibmLrshewTFi0gIh0u(8bfDyLvcTFt5HAdH3CvnP48bfDM77O8bZGpLAVEkznaRhoI0685dk6Wg85t7hc4biWRUAndf0FeMY6v5Jzf1VpWgQZ)c3hP2tjGDUMQZCw(k3bHf2qLRQjW(k6fGqni0szcE(RGzihmUcRaN1dAkyoaIv0dHpVRQjtawiGaszqchVcjjbiudcTuMaSqabKY3gLXr)8h2mKdgpjXQaebvEDM6rTD5Mt9tsWrKwNpFqrh2GpFA)qaTxpGdaSN6Q1muq)rykRxLpMveWdW(9b(EkbSZ1uDMZYx5oiSWgQCvnb2VVcROG(JWKbd1(Klc5xsspkO)imz(kJHAFss6rb9hHjZxzv4TLKqb9hHjZxz9Q8PVcRoxt1zWWLodB5BJYn4q4ZqLRQjWKe1vRzIMVdoGVRZ(e86d5OLg7JbHRxuQkdq0KEFf9WrKwNpFqrh2GpFA)qavP0b(EkbSZ1uDMZYx5oiSWgQCvnb2VVchFJRZrql0KkAshaQUAnd(8P5ATzOo)lmWdC6RONvQRwZa4xGdbMPUiOfA6O6YurdQpLKzfLKqb9hHjZxzmu7tsIvbicQ86magFEV6RWk1vRzghbvWfo3gQsz8m(R2sN3IJpAE3SI40qAwIDmXsSbglwGflbqwS83gCDSe8OOVqXP5H7Hf24qcykJKgCcug2YLFRHq73u2JYHnkaiNMhUhwyJdjGPmsq4Z7QAcTL3rkhaZbyb(3dRSdj0IW1lszRaN1dAkyoaIvGWN3v1KjaMdWc8Vhwk61tD1Ag85tZ1AZkkj5CnvNbFKw7tgC(2zOYv1eyssaIGkVot9O2UCZP(k6zL6Q1myOgFFGmRifwPUAntWZFfmRif9S6CnvNPTM4zylt6vrgQCvnbMKOUAntWZFfmGRXVhwPgGqni0szARjEg2YKEvKzOo)lmWac9vGWN3v1K52MxRZyIaKMSf)pf9SkarqLxNPEuBxU5ussac1GqlLjaleqaP8TrzC0p)HnRif9uxTMbF(0CT2muN)fgOamjXQZ1uDg8rATpzW5BNHkxvtG97R48bfDM77O8bZGpLQ6Q1mbp)vWaUg)Eyb8PBaI9tsApQTlpuN)fgOQRwZe88xbd4A87HvFonKMLyhtSGSuGeRTcSalwcGSSknHXS4fil6Viw(JLvelw(BJfKbleqajonpCpSWghsatzKeinHV31zx)OQoQo0(nLr4Z7QAYeaZbyb(3dRSdjonpCpSWghsatzK8vWNYVhwO9BkJWN3v1KjaMdWc8VhwzhsCAinlXoMyb96IGwOHLyalqwGflbqwS83gl7NpnxRzzfXIxGSGDeeln4WcaEPX(WIxGSGSuGeRTcCAE4EyHnoKaMYiH6IGwOjRclq0(nLvHySIVoAIGA)iWC7rTD5H68VWavj0KK0tD1AMO57Gd476SpbV(qoAPX(yq46fbuaIM0tsuxTMjA(o4a(Uo7tWRpKJwASpgeUErPQmart69vOUAnd(8P5ATzfPOxac1GqlLj45VcMH68VWPIM0tsaN1dAkyoaI7ZPH0SaGGAdH3yPP9HybwSSIy5GSetwoFqrhMfl)TbxhlilfiXARalQ0xOyXvHRJLdYcH8OFiw8cKLcESarqtWJI(cfNMhUhwyJdjGPmsWhP1(KBAFi0gIh0u(8bfDyLvcTFt5HAdH3CvnP4(okFWm4tPQeAuGJiToF(GIoSbF(0(HaQ1OWJYHnkaOIEQRwZe88xbZqD(x4uvk9KeRuxTMj45VcMvuFonKMLyhtSeBGOhlFJLVWpiXIxSGEb9hHjw8cKf9xel)XYkIfl)TXIZcaEPX(Ws0adS4filPa0JUhbXYUfF6408W9WcBCibmLrsBnXZWwM0RIq73uMc6pctMVYEfxHhLdBuaqfQRwZenFhCaFxN9j41hYrln2hdcxViGcq0KUIEGWZ4GE09iOm2IpDzqVZrrM7da(fQKeRcqeu51zkkmqnCatsWrKwNpFqrhova2xrp1vRzghbvWfo3gQszCZqD(xyGcKaG9qdWpRIAWbfzWF1w68wC8rZ79vOUAnZ4iOcUW52qvkJBwrjjwPUAnZ4iOcUW52qvkJBwr9v0ZQaeQbHwktWZFfmROKe1vRzUT516mMiaPXGppaiqvcnkApQTlpuN)fgOam90v0EuBxEOo)lCQkLE6jjwHHlT6xGMBBEToJjcqAmu5QAcSVIEy4sR(fO52MxRZyIaKgdvUQMatscqOgeAPmbp)vWmuN)fo1yMEFonKMLyhtS4SSF(0CTMfa0fDBSenWalRstyml7NpnxRz5XS46HCW4SSIyboSehUyXhIfxfUowoilqe0e8iwsbgaZP5H7Hf24qcykJe85tZ1A0(nLvxTMbw0THZr0eOO7HLzfPON6Q1m4ZNMR1MHAdH3CvnLK44BCDocAHMubsP3NtdPzj2U6IyjfyamlQudoelidwiGasSy5Vnw2pFAUwZIxGSCBuXY(5dEnOionpCpSWghsatzKGpFAUwJ2VPCaIGkVot9O2UCZjfwDUMQZGpsR9jdoF7mu5QAcurpe(8UQMmbyHaciLbjC8kKKeGqni0szcE(RGzfLKOUAntWZFfmRO(kcqOgeAPmbyHaciLVnkJJ(5pSzOo)lmqrfanDoYb(a96Eo(gxNJGwObPIM07RqD1Ag85tZ1AZqD(xyGAnkScCwpOPG5aiMtZd3dlSXHeWugj4Zh8AqrO9BkhGiOYRZupQTl3Csrpe(8UQMmbyHaciLbjC8kKKeGqni0szcE(RGzfLKOUAntWZFfmRO(kcqOgeAPmbyHaciLVnkJJ(5pSzOo)lmqbokuxTMbF(0CT2SIuqb9hHjZxzVIRWke(8UQMmpQcougF(GxdksHvGZ6bnfmhaXCAinlXoMyz)8bVguelw(BJfVybaDr3glrdmWcCy5BSehUqhilqe0e8iwsbgaZIL)2yjoCnSueYpwco(mSKcngYc4QlILuGbWS4hl3gXcvGSaBSCBelair1TfFyrD1AS8nw2pFAUwZIf4sdwO7yP5AnlWwJf4WsC4IfFiwGflaKLZhu0H508W9WcBCibmLrc(8bVgueA)MYQRwZal62W5GM8jJ4XpSmROKKEwHpFA)qgpkh2OaGkScHpVRQjZJQGdLXNp41GIss6PUAntWZFfmd15FHbkAuOUAntWZFfmROKKE9uxTMj45VcMH68VWafva005ih4d0R754BCDocAHgKAmtVVc1vRzcE(RGzfLKOUAnZ4iOcUW52qvkJNXF1w68wC8rZ7MH68VWafva005ih4d0R754BCDocAHgKAmtVVc1vRzghbvWfo3gQsz8m(R2sN3IJpAE3SI6RiarqLxNbbv3w8PFFf9WrKwNpFqrh2GpFAUwd0yMKGWN3v1KbF(0CToBbwxU5ADg2A97RWke(8UQMmpQcougF(GxdksrpRMvrn4GIm33rwGtLbhY7u)cKMKeCeP15Zhu0Hn4ZNMR1anM950qAwIDmXcakiSWS8fl7qTpSGEb9hHjw8cKfSJGyj2S0AwaqbHfln4WcYsbsS2kWP5H7Hf24qcykJKISK7GWcTFt5EQRwZqb9hHPmgQ9XmuN)fovc5uyDu((okjPxyZhuewzaQyOWMpOO89Deqrt)KKWMpOiSYXSVcpkh2OaGCAE4EyHnoKaMYizZ1TChewO9Bk3tD1AgkO)imLXqTpMH68VWPsiNcRJY33rjj9cB(GIWkdqfdf28bfLVVJakA6NKe28bfHvoM9v4r5Wgfaurp1vRzghbvWfo3gQszCZqD(xyGIgfQRwZmocQGlCUnuLY4MvKcRMvrn4GIm4VAlDElo(O59KeRuxTMzCeubx4CBOkLXnRO(CAE4EyHnoKaMYiPT06ChewO9Bk3tD1AgkO)imLXqTpMH68VWPsiNcRJY33rk6fGqni0szcE(RGzOo)lCQOj9KKaeQbHwktawiGas5BJY4OF(dBgQZ)cNkAsVFssVWMpOiSYauXqHnFqr577iGIM(jjHnFqryLJzFfEuoSrbav0tD1AMXrqfCHZTHQug3muN)fgOOrH6Q1mJJGk4cNBdvPmUzfPWQzvudoOid(R2sN3IJpAEpjXk1vRzghbvWfo3gQszCZkQpNgsZsSJjwqkGOhlWIfKfB508W9WcBCibmLrIfFMhozylt6vrCAinliZ1HL2pcZILn62OHLdYYctSSF(0(Hy5lw2HAFyXY2h2y5XS4hlOHLZhu0HbMsS0GdlecAIZcathPYsNJpAIZcCyXAyz)8bVguelOxxe0cnDuDSGppaiMtZd3dlSXHeWugji85DvnH2Y7iLXNpTFO8xzmu7dAr46fPmoI0685dk6Wg85t7hkvRbynneo96C8rt8mcxViGxP0thPcW07dSMgcNEQRwZGpFWRbfLPUiOfA6O6YyO2hd(8aGivRPpNgsZcYCDyP9JWSyzJUnAy5GSGum(TXc4A(cflXMHQugNtZd3dlSXHeWugji85DvnH2Y7iLTm(TL)k3gQszC0IW1lszLqQ4isRZBo(iGcqayV0nae47HJiToF(GIoSbF(0(HaGk1h47PeWoxt1zWWLodB5BJYn4q4ZqLRQjqGxjdA63hyPBucnaV6Q1mJJGk4cNBdvPmUzOo)lmNgsZsSJjwqkg)2y5lw2HAFyb9c6pctSahw(glfKL9ZN2pelwETML2FS81bzbzPajwBfyXR4DWH408W9WcBCibmLrILXVn0(nL7rb9hHjJEv(Klc5xscf0FeMmEfpxeYpfi85DvnzECoOjhb1xrVZhu0zUVJYhmd(uQwtscf0FeMm6v5t(RmatsApQTlpuN)fgOkLE)Ke1vRzOG(JWugd1(ygQZ)cdupCpSm4ZN2pKHqofwhLVVJuOUAndf0FeMYyO2hZkkjHc6pctMVYyO2hfwHWN3v1KbF(0(HYFLXqTpjjQRwZe88xbZqD(xyG6H7HLbF(0(HmeYPW6O89DKcRq4Z7QAY84CqtocsH6Q1mbp)vWmuN)fgOeYPW6O89DKc1vRzcE(RGzfLKOUAnZ4iOcUW52qvkJBwrkq4Z7QAYyz8Bl)vUnuLY4jjwHWN3v1K5X5GMCeKc1vRzcE(RGzOo)lCQeYPW6O89DeNgsZsSJjw2pFA)qS8nw(If0Fv(Wc6f0FeMqllFXYou7dlOxq)ryIfyXI1amwoFqrhMf4WYbzjAGbw2HAFyb9c6pctCAE4EyHnoKaMYibF(0(H40qAwInUwFBZItZd3dlSXHeWugjZQYE4EyL1p(qB5DKYnxRVTzXPXPH0SeBgQszCwS83glilfiXARaNMhUhwyJk0pLhhbvWfo3gQszC0(nLvxTMj45VcMH68VWPQeA40qAwIDmXska9O7rqSSBXNowSSrfl(XIMWywUnVyXAyjgWuyDwWNhaeZIxGSCqwgQneEJfNfGQmazbFEaqwCmlA)iwCmlrqm(v1elWHL77iw(JfmKL)yXN5rqywaqEHpw82rdlolXeySGppaileYJ(HWCAE4EyHnQq)aMYiXb9O7rqzSfF6qBiEqt5Zhu0Hvwj0(nLvxTMr11EfOmSLDToFBFHcNl)wdzWNhaeOabfQRwZO6AVcug2YUwNVTVqHZ(e8Im4ZdacuGGIEwbcpJd6r3JGYyl(0Lb9ohfzUpa4xOuyLhUhwgh0JUhbLXw8Pld6DokY8vUPFuBNIEwbcpJd6r3JGYyl(0L3ixBUpa4xOssaHNXb9O7rqzSfF6YBKRnd15FHtnM9tsaHNXb9O7rqzSfF6YGENJIm4Zdac0yQaeEgh0JUhbLXw8Pld6DokYmuN)fgOOrbi8moOhDpckJT4txg07CuK5(aGFHQpNgsZsSJjwqgSqabKyXYFBSGSuGeRTcSyzJkwIGy8RQjw8cKf4TrJLhtSy5VnwCwIbmfwNf1vRXILnQybKWXRWxO408W9WcBuH(bmLrsawiGas5BJY4OF(dJ2VPSvGZ6bnfmhaXk61dHpVRQjtawiGaszqchVckSkaHAqOLYe88xbZqoy8Ke1vRzcE(RGzf1xrp1vRzuDTxbkdBzxRZ32xOW5YV1qg85bavgiKKOUAnJQR9kqzyl7AD(2(cfo7tWlYGppaOYaH(jjQqmwr7rTD5H68VWavP07ZPH0SeBGOhloMLBJyP9d(ybvaKLVy52iwCwIbmfwNflFbcTWcCyXYFBSCBeliLIpVxSOUAnwGdlw(BJfNfGaWWuGLua6r3JGyz3IpDS4filw8)yPbhwqwkqI1wbw(gl)XIfyDSOsSSIyXr5FXIk1GdXYTrSeaz5XS0(6XBeiNMhUhwyJk0pGPmsARjEg2YKEveA)MY961tD1Agvx7vGYWw2168T9fkCU8BnKbFEaWubojjQRwZO6AVcug2YUwNVTVqHZ(e8Im4ZdaMkWPVIEwfGiOYRZGGQBl(KKyL6Q1mJJGk4cNBdvPmUzf1VVIEGZ6bnfmhaXjjbiudcTuMGN)kygQZ)cNkAspjPxaIGkVot9O2UCZjfbiudcTuMaSqabKY3gLXr)8h2muN)fov0KE)(9ts6bcpJd6r3JGYyl(0Lb9ohfzgQZ)cNkqqrac1GqlLj45VcMH68VWPQu6kcqeu51zkkmqnCa7NKOcXyfFD0eb1(rG52JA7Yd15FHbkqqHvbiudcTuMGN)kygYbJNKeGiOYRZay859sH6Q1ma(f4qGzQlcAHMoQoZkkjjarqLxNbbv3w8rH6Q1mJJGk4cNBdvPmUzOo)lmqbskuxTMzCeubx4CBOkLXnRionKMfK5vG0SSF(OHdilw(BJfNLISWsmGPW6SOUAnw8cKfKLcKyTvGLhxO7yXvHRJLdYIkXYctGCAE4EyHnQq)aMYij4vG0z1vRH2Y7iLXNpA4aI2VPCp1vRzuDTxbkdBzxRZ32xOW5YV1qMH68VWPcenOjjrD1Agvx7vGYWw2168T9fkC2NGxKzOo)lCQardA6ROxac1GqlLj45VcMH68VWPcets6fGqni0szOUiOfAYQWc0muN)fovGOcRuxTMbWVahcmtDrql00r1LPIguFkjZksraIGkVodGXN3R(9v44BCDocAHMuvoMPZPH0SeBxDrSSF(GxdkcZIL)2yXzjgWuyDwuxTglQRJLcESyzJkwIGq9xOyPbhwqwkqI1wbwGdliL(cCiqw2J(5pmNMhUhwyJk0pGPmsWNp41GIq73uUN6Q1mQU2RaLHTSR15B7lu4C53Aid(8aGPcWKe1vRzuDTxbkdBzxRZ32xOWzFcErg85batfG9v0larqLxNPEuBxU5ussac1GqlLj45VcMH68VWPcetsScHpVRQjtamhGf4FpSuyvaIGkVodGXN3RKKEbiudcTugQlcAHMSkSand15FHtfiQWk1vRza8lWHaZuxe0cnDuDzQOb1NsYSIueGiOYRZay859QFFf9SceEM2AINHTmPxfzUpa4xOssSkaHAqOLYe88xbZqoy8KeRcqOgeAPmbyHaciLVnkJJ(5pSzihmEFonKMLy7QlIL9Zh8AqrywuPgCiwqgSqabK408W9WcBuH(bmLrc(8bVgueA)MY9cqOgeAPmbyHaciLVnkJJ(5pSzOo)lmqrJcRaN1dAkyoaIv0dHpVRQjtawiGaszqchVcjjbiudcTuMGN)kygQZ)cdu00xbcFExvtMayoalW)Ey1xHvGWZ0wt8mSLj9QiZ9ba)cLIaebvEDM6rTD5MtkScCwpOPG5aiwbf0FeMmFL9kUchFJRZrql0KQ1KoNgsZsSfwO7ybeESaUMVqXYTrSqfilWglaiCeubxywIndvPmoAzbCnFHIfa)cCiqwOUiOfA6O6yboS8fl3gXI2XhlOcGSaBS4flOxq)ryItZd3dlSrf6hWugji85DvnH2Y7iLbHxEiG76hQJQdJweUErk3tD1AMXrqfCHZTHQug3muN)fov0KKyL6Q1mJJGk4cNBdvPmUzf1xrp1vRza8lWHaZuxe0cnDuDzQOb1NsYmuN)fgOOcGMoh59v0tD1AgkO)imLXqTpMH68VWPIkaA6CKNKOUAndf0FeMY6v5JzOo)lCQOcGMoh59508W9WcBuH(bmLrcEvTFi0gIh0u(8bfDyLvcTFt5HAdH3CvnP48bfDM77O8bZGpLQsahfEuoSrbavGWN3v1KbeE5HaURFOoQomNMhUhwyJk0pGPms6GWQ9dH2q8GMYNpOOdRSsO9BkpuBi8MRQjfNpOOZCFhLpyg8PuvkMg0OWJYHnkaOce(8UQMmGWlpeWD9d1r1H508W9WcBuH(bmLrc(iT2NCt7dH2q8GMYNpOOdRSsO9BkpuBi8MRQjfNpOOZCFhLpyg8Puvc4aSH68VWk8OCyJcaQaHpVRQjdi8YdbCx)qDuDyonKMLydmwSalwcGSy5Vn46yj4rrFHItZd3dlSrf6hWugjn4eOmSLl)wdH2VPShLdBuaqonKMf0RlcAHgwIbSazXYgvS4QW1XYbzHQJgwCwkYclXaMcRZILVaHwyXlqwWocILgCybzPajwBf408W9WcBuH(bmLrc1fbTqtwfwGO9Bk3Jc6pctg9Q8jxeYVKekO)imzWqTp5Iq(LKqb9hHjJxXZfH8ljrD1Agvx7vGYWw2168T9fkCU8BnKzOo)lCQardAssuxTMr11EfOmSLDToFBFHcN9j4fzgQZ)cNkq0GMKehFJRZrql0KkqkDfbiudcTuMGN)kygYbJRWkWz9GMcMdG4(k6fGqni0szcE(RGzOo)lCQXm9KKaeQbHwktWZFfmd5GX7NKOcXyfFD0eb1(rG52JA7Yd15FHbQsPZPH0SeBGOhlZJA7yrLAWHyzH)cflilfCAE4EyHnQq)aMYiPTM4zylt6vrO9BkhGqni0szcE(RGzihmUce(8UQMmbWCawG)9WsrphFJRZrql0KkqkDfwfGiOYRZupQTl3CkjjarqLxNPEuBxU5KchFJRZrql0auRj9(kSkarqLxNbbv3w8rrpRcqeu51zQh12LBoLKeGqni0szcWcbeqkFBugh9ZFyZqoy8(kScCwpOPG5aiMtdPzbzPajwBfyXYgvS4hlaP0bglPadGzPhC0ql0WYT5flwt6SKcmaMfl)TXcYGfciGuFwS83gCDSOH4VqXY9DelFXsm0qiOEHpw8cKf9xelRiwS83glidwiGasS8nw(JfloMfqchVceiNMhUhwyJk0pGPmsq4Z7QAcTL3rkhaZbyb(3dRSk0p0IW1lszRaN1dAkyoaIvGWN3v1KjaMdWc8Vhwk61ZX346Ce0cnPcKsxrp1vRza8lWHaZuxe0cnDuDzQOb1NsYSIssSkarqLxNbW4Z7v)Ke1vRzu1qiOEHpZksH6Q1mQAieuVWNzOo)lmqvxTMj45VcgW143dR(jjFD0eb1(rG52JA7Yd15FHbQ6Q1mbp)vWaUg)EyLKeGiOYRZupQTl3CQVIEwfGiOYRZupQTl3CkjPNJVX15iOfAaQ1KEsci8mT1epdBzsVkYCFaWVq1xrpe(8UQMmbyHaciLbjC8kKKeGqni0szcWcbeqkFBugh9ZFyZqoy8(9508W9WcBuH(bmLrsG0e(ExND9JQ6O6q73ugHpVRQjtamhGf4FpSYQq)408W9WcBuH(bmLrYxbFk)EyH2VPmcFExvtMayoalW)EyLvH(XPH0SGE4778JWSSbTWs3kSXskWayw8HybL)fbYsenSGPaSa508W9WcBuH(bmLrccFExvtOT8oszhhbGPzNcOfHRxKYuq)ryY8vwVkFaEGas1d3dld(8P9dziKtH1r577iGzff0FeMmFL1RYhGVhWbyNRP6my4sNHT8Tr5gCi8zOYv1eiWhZ(ivpCpSmwg)2meYPW6O89DeWs3aqKkoI068MJpItdPzj2U6Iyz)8bVgueMflBuXYTrS0EuBhlpMfxfUowoilubIwwAdvPmolpMfxfUowoilubIwwIdxS4dXIFSaKshySKcmaMLVyXlwqVG(JWeAzbzPajwBfyr74dZIxWBJgwacadtbmlWHL4WflwGlnilqe0e8iw6GdXYT5flCIsPZskWaywSSrflXHlwSaxAWcDhl7Np41GIyPGw408W9WcBuH(bmLrc(8bVgueA)MY9uHySIVoAIGA)iWC7rTD5H68VWa1Ass6PUAnZ4iOcUW52qvkJBgQZ)cduubqtNJCGpqVUNJVX15iOfAqQXm9(kuxTMzCeubx4CBOkLXnRO(9ts654BCDocAHgGHWN3v1KXXrayA2PaWRUAndf0FeMYyO2hZqD(xyGbcptBnXZWwM0RIm3haeNhQZ)c4bObnPQKsPNK44BCDocAHgGHWN3v1KXXrayA2PaWRUAndf0FeMY6v5JzOo)lmWaHNPTM4zylt6vrM7daIZd15Fb8a0GMuvsP07RGc6pctMVYEfxrpRuxTMj45VcMvusIvNRP6m4ZhnCanu5QAcSVIE9SkaHAqOLYe88xbZkkjjarqLxNbW4Z7LcRcqOgeAPmuxe0cnzvybAwr9tscqeu51zQh12LBo1xrpRcqeu51zqq1TfFssSsD1AMGN)kywrjjo(gxNJGwOjvGu69ts6DUMQZGpF0Wb0qLRQjqfQRwZe88xbZksrp1vRzWNpA4aAWNhaeOXmjXX346Ce0cnPcKsVF)Ke1vRzcE(RGzfPWk1vRzghbvWfo3gQszCZksHvNRP6m4ZhnCanu5QAcKtdPzj2XelaOGWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3awSzP1SaGcclwAWHfKLcKyTvGtZd3dlSrf6hWugjfzj3bHfA)MY9uxTMHc6pctz9Q8XmuN)fovc5uyDu((okjPxyZhuewzaQyOWMpOO89Deqrt)KKWMpOiSYXSVcpkh2OaGCAE4EyHnQq)aMYizZ1TChewO9Bk3tD1AgkO)imL1RYhZqD(x4ujKtH1r577if9cqOgeAPmbp)vWmuN)fov0KEssac1GqlLjaleqaP8TrzC0p)Hnd15FHtfnP3pjPxyZhuewzaQyOWMpOO89Deqrt)KKWMpOiSYXSVcpkh2OaGCAE4EyHnQq)aMYiPT06ChewO9Bk3tD1AgkO)imL1RYhZqD(x4ujKtH1r577if9cqOgeAPmbp)vWmuN)fov0KEssac1GqlLjaleqaP8TrzC0p)Hnd15FHtfnP3pjPxyZhuewzaQyOWMpOO89Deqrt)KKWMpOiSYXSVcpkh2OaGCAinlifq0JfyXsaKtZd3dlSrf6hWugjw8zE4KHTmPxfXPH0Se7yIL9ZN2pelhKLObgyzhQ9Hf0lO)imXcCyXYgvS8flWshNf0Fv(Wc6f0FeMyXlqwwyIfKci6Xs0adyw(glFXc6VkFyb9c6pctCAE4EyHnQq)aMYibF(0(Hq73uMc6pctMVY6v5tscf0FeMmyO2NCri)ssOG(JWKXR45Iq(LKOUAnJfFMhozylt6vrMvKc1vRzOG(JWuwVkFmROKKEQRwZe88xbZqD(xyG6H7HLXY43MHqofwhLVVJuOUAntWZFfmRO(CAE4EyHnQq)aMYiXY43gNMhUhwyJk0pGPmsMvL9W9WkRF8H2Y7iLBUwFBZItJtdPzz)8bVgueln4Wsheb1r1XYQ0egZYc)fkwIbmfwNtZd3dlSP5A9TnlLXNp41GIq73u2QzvudoOiJQR9kqzyl7AD(2(cf2qa31hfrGCAinliZXhl3gXci8yXYFBSCBelDq8XY9DelhKfheKLvDVMLBJyPZrolGRXVhwS8yw2(ZWY(QA)qSmuN)fMLUL((i9tGSCqw68lSXshewTFiwaxJFpS408W9WcBAUwFBZcykJe8QA)qOnepOP85dk6WkReA)MYGWZ0bHv7hYmuN)fo1H68VWapabisvjGaNMhUhwytZ16BBwatzK0bHv7hItJtdPzj2Xel7Np41GIy5GSairrSSIy52iwITd5DQFbsdlQRwJLVXYFSybU0GSqip6hIfvQbhIL2xpE7luSCBelfH8JLGJpwGdlhKfWvxelQudoelidwiGasCAE4EyHn4tz85dEnOi0(nLNvrn4GIm33rwGtLbhY7u)cKgf9OG(JWK5RSxXvyvVEQRwZCFhzbovgCiVt9lqAmd15FHt1d3dlJLXVndHCkSokFFhbS0nkPOhf0FeMmFLvH3wscf0FeMmFLXqTpjjuq)ryYOxLp5Iq(1pjrD1AM77ilWPYGd5DQFbsJzOo)lCQE4EyzWNpTFidHCkSokFFhbS0nkPOhf0FeMmFL1RYNKekO)imzWqTp5Iq(LKqb9hHjJxXZfH8RF)KeRuxTM5(oYcCQm4qEN6xG0ywr9ts6PUAntWZFfmROKee(8UQMmbyHaciLbjC8k0xrac1GqlLjaleqaP8TrzC0p)Hnd5GXveGiOYRZupQTl3CQVIEwfGiOYRZay859kjjaHAqOLYqDrql0KvHfOzOo)lCQaH(k6PUAntWZFfmROKeRcqOgeAPmbp)vWmKdgVpNgsZsSJjwsbOhDpcILDl(0XILnQy52OHy5XSuqw8W9iiwWw8PdTS4yw0(rS4ywIGy8RQjwGflyl(0XIL)2ybGSahwAKfAybFEaqmlWHfyXIZsmbglyl(0XcgYYT5hl3gXsrwybBXNow8zEeeMfaKx4JfVD0WYT5hlyl(0XcH8OFimNMhUhwyd(aMYiXb9O7rqzSfF6qBiEqt5Zhu0Hvwj0(nLTceEgh0JUhbLXw8Pld6DokYCFaWVqPWkpCpSmoOhDpckJT4txg07CuK5RCt)O2of9SceEgh0JUhbLXw8PlVrU2CFaWVqLKacpJd6r3JGYyl(0L3ixBgQZ)cNkA6NKacpJd6r3JGYyl(0Lb9ohfzWNhaeOXubi8moOhDpckJT4txg07CuKzOo)lmqJPcq4zCqp6EeugBXNUmO35OiZ9ba)cfNgsZsSJjmlidwiGasS8nwqwkqI1wbwEmlRiwGdlXHlw8HybKWXRWxOybzPajwBfyXYFBSGmyHaciXIxGSehUyXhIfvsdTWI1KolPadG508W9WcBWhWugjbyHaciLVnkJJ(5pmA)MYwboRh0uWCaeROxpe(8UQMmbyHaciLbjC8kOWQaeQbHwktWZFfmd5GXvy1SkQbhuKjA(o4a(Uo7tWRpKJwASpjjQRwZe88xbZkQVchFJRZrql0auLTM0v0tD1AgkO)imL1RYhZqD(x4uvk9Ke1vRzOG(JWugd1(ygQZ)cNQsP3pjrfIXkApQTlpuN)fgOkLUcRcqOgeAPmbp)vWmKdgVpNgsZcYGf4FpSyPbhwCTMfq4Hz528JLohqcZcEnel3gfNfFOcDhld1gcVrGSyzJkwaq4iOcUWSeBgQszCw2CmlAcJz528If0WcMcywgQZ)6luSahwUnIfaJpVxSOUAnwEmlUkCDSCqwAUwZcS1yboS4vCwqVG(JWelpMfxfUowoileYJ(H408W9WcBWhWugji85DvnH2Y7iLbHxEiG76hQJQdJweUErk3tD1AMXrqfCHZTHQug3muN)fov0KKyL6Q1mJJGk4cNBdvPmUzf1xHvQRwZmocQGlCUnuLY4z8xTLoVfhF08UzfPON6Q1ma(f4qGzQlcAHMoQUmv0G6tjzgQZ)cduubqtNJ8(k6PUAndf0FeMYyO2hZqD(x4urfanDoYtsuxTMHc6pctz9Q8XmuN)fovubqtNJ8KKEwPUAndf0FeMY6v5JzfLKyL6Q1muq)rykJHAFmRO(kS6CnvNbd147dKHkxvtG950qAwqgSa)7Hfl3MFSe2OaGyw(glXHlw8HybUo8dsSqb9hHjwoilWshNfq4XYTrdXcCy5rvWHy52Emlw(BJLDOgFFG408W9WcBWhWugji85DvnH2Y7iLbHxgUo8dszkO)imHweUErk3Zk1vRzOG(JWugd1(ywrkSsD1AgkO)imL1RYhZkQFsY5AQodgQX3hidvUQMa508W9WcBWhWugjDqy1(HqBiEqt5Zhu0Hvwj0(nLhQneEZv1KIEQRwZqb9hHPmgQ9XmuN)fo1H68VWjjQRwZqb9hHPSEv(ygQZ)cN6qD(x4Kee(8UQMmGWldxh(bPmf0FeM6RyO2q4nxvtkoFqrN5(okFWm4tPQeav4r5WgfaubcFExvtgq4Lhc4U(H6O6WCAE4EyHn4dykJe8QA)qOnepOP85dk6WkReA)MYd1gcV5QAsrp1vRzOG(JWugd1(ygQZ)cN6qD(x4Ke1vRzOG(JWuwVkFmd15FHtDOo)lCsccFExvtgq4LHRd)GuMc6pct9vmuBi8MRQjfNpOOZCFhLpyg8PuvcGk8OCyJcaQaHpVRQjdi8YdbCx)qDuDyonpCpSWg8bmLrc(iT2NCt7dH2q8GMYNpOOdRSsO9BkpuBi8MRQjf9uxTMHc6pctzmu7JzOo)lCQd15FHtsuxTMHc6pctz9Q8XmuN)fo1H68VWjji85DvnzaHxgUo8dszkO)im1xXqTHWBUQMuC(GIoZ9Du(GzWNsvjGJcpkh2OaGkq4Z7QAYacV8qa31puhvhMtdPzj2XelXgySybwSeazXYFBW1XsWJI(cfNMhUhwyd(aMYiPbNaLHTC53Ai0(nL9OCyJcaYPH0Se7yIfKsFboeil7r)8hMfl)TXIxXzrdluSqfCHAJfTJVVqXc6f0FeMyXlqwUjolhKf9xel)XYkIfl)TXcaEPX(WIxGSGSuGeRTcCAE4EyHn4dykJeQlcAHMSkSar73uUxp1vRzOG(JWugd1(ygQZ)cNQsPNKOUAndf0FeMY6v5JzOo)lCQkLEFfbiudcTuMGN)kygQZ)cNAmtxrp1vRzIMVdoGVRZ(e86d5OLg7JbHRxeqbO1KEsIvZQOgCqrMO57Gd476SpbV(qoAPX(yiG76JIiW(9tsuxTMjA(o4a(Uo7tWRpKJwASpgeUErPQmabIPNKeGqni0szcE(RGzihmUchFJRZrql0KkqkDonKMLyhtSGSuGeRTcSy5VnwqgSqabKqcsPVahcKL9OF(dZIxGSacl0DSarqJL5pIfa8sJ9Hf4WILnQyjgAieuVWhlwGlnileYJ(HyrLAWHybzPajwBfyHqE0peMtZd3dlSbFatzKGWN3v1eAlVJuoaMdWc8Vhwz8HweUErkBf4SEqtbZbqSce(8UQMmbWCawG)9WsrVEbiudcTugQlk(qUodhWYRazgQZ)cduLaoarG1tjLa(zvudoOid(R2sN3IJpAEVVcc4U(Oic0qDrXhY1z4awEfO(jjo(gxNJGwOjvLbsPRONvNRP6mT1epdBzsVkYqLRQjWKe1vRzcE(RGbCn(9Wk1aeQbHwktBnXZWwM0RImd15FHbgqOVce(8UQMm328ADgteG0KT4)PON6Q1ma(f4qGzQlcAHMoQUmv0G6tjzwrjjwfGiOYRZay859QVIZhu0zUVJYhmd(uQQRwZe88xbd4A87HfWNUbiMKOcXyfTh12LhQZ)cdu1vRzcE(RGbCn(9WkjjarqLxNPEuBxU5usI6Q1mQAieuVWNzfPqD1AgvnecQx4ZmuN)fgOQRwZe88xbd4A87HfW6bKa(zvudoOit08DWb8DD2NGxFihT0yFmeWD9rrey)(kSsD1AMGN)kywrk6zvaIGkVot9O2UCZPKKaeQbHwktawiGas5BJY4OF(dBwrjjQqmwr7rTD5H68VWanaHAqOLYeGfciGu(2Omo6N)WMH68VWad4KK0EuBxEOo)lmsfPQeqiDGQUAntWZFfmGRXVhw950qAwIDmXYTrSaGev3w8Hfl)TXIZcYsbsS2kWYT5hlpUq3XsBGDSaGxASpCAE4EyHn4dykJKXrqfCHZTHQughTFtz1vRzcE(RGzOo)lCQkHMKe1vRzcE(RGbCn(9WcOXmDfi85DvnzcG5aSa)7HvgFCAE4EyHn4dykJKaPj89Uo76hv1r1H2VPmcFExvtMayoalW)EyLXNIEwPUAntWZFfmGRXVhwPgZ0tsSkarqLxNbbv3w8PFsI6Q1mJJGk4cNBdvPmUzfPqD1AMXrqfCHZTHQug3muN)fgOajGfGf46pt0qHhtzx)OQoQoZ9DugHRxeW6zL6Q1mQAieuVWNzfPWQZ1uDg85JgoGgQCvnb2NtZd3dlSbFatzK8vWNYVhwO9BkJWN3v1KjaMdWc8Vhwz8XPH0SaGKpVRQjwwycKfyXIR(6)EcZYT5hlw86y5GSOsSGDeeiln4WcYsbsS2kWcgYYT5hl3gfNfFO6yXIJpcKfaKx4JfvQbhILBJ6408W9WcBWhWugji85DvnH2Y7iLXock3Gto45VcOfHRxKYwfGqni0szcE(RGzihmEsIvi85DvnzcWcbeqkds44vqraIGkVot9O2UCZPKeWz9GMcMdGyonKMLyhtywInq0JLVXYxS4flOxq)ryIfVaz5MNWSCqw0FrS8hlRiwS83gla4Lg7dAzbzPajwBfyXlqwsbOhDpcILDl(0XP5H7Hf2GpGPmsARjEg2YKEveA)MYuq)ryY8v2R4k8OCyJcaQqD1AMO57Gd476SpbV(qoAPX(yq46fbuaAnPROhi8moOhDpckJT4txg07CuK5(aGFHkjXQaebvEDMIcdudhW(kq4Z7QAYGDeuUbNCWZFfu0tD1AMXrqfCHZTHQug3muN)fgOajayp0a8ZQOgCqrg8xTLoVfhF08EFfQRwZmocQGlCUnuLY4MvusIvQRwZmocQGlCUnuLY4MvuFonKMLyhtSaGUOBJL9ZNMR1SenWaMLVXY(5tZ1AwECHUJLveNMhUhwyd(aMYibF(0CTgTFtz1vRzGfDB4Cenbk6EyzwrkuxTMbF(0CT2muBi8MRQjonpCpSWg8bmLrsWRaPZQRwdTL3rkJpF0WbeTFtz1vRzWNpA4aAgQZ)cdu0OON6Q1muq)rykJHAFmd15FHtfnjjQRwZqb9hHPSEv(ygQZ)cNkA6RWX346Ce0cnPcKsNtdPzj2U6IWSKcmaMfvQbhIfKbleqajww4VqXYTrSGmyHaciXsawG)9WILdYsyJcaYY3ybzWcbeqILhZIhULR1XzXvHRJLdYIkXsWXhNMhUhwyd(aMYibF(GxdkcTFt5aebvEDM6rTD5Mtkq4Z7QAYeGfciGugKWXRGIaeQbHwktawiGas5BJY4OF(dBgQZ)cdu0OWkWz9GMcMdGyfuq)ryY8v2R4kC8nUohbTqtQwt6CAinlXoMyz)8P5Anlw(BJL9J0AFyj2oF7yXlqwkil7NpA4aIwwSSrflfKL9ZNMR1S8ywwrOLL4Wfl(qS8flO)Q8Hf0lO)imXsdoSaeagMcywGdlhKLObgybaV0yFyXYgvS4QqeelaP0zjfyamlWHfhmYVhbXc2IpDSS5ywacadtbmld15F9fkwGdlpMLVyPPFuBNHLybpILBZpwwfinSCBelyVJyjalW)EyHz5p0HzbmcZsrRBCnlhKL9ZNMR1SaUMVqXcachbvWfMLyZqvkJJwwSSrflXHl0bYc(ETMfQazzfXIL)2ybiLoWCCeln4WYTrSOD8Xcknu11ydNMhUhwyd(aMYibF(0CTgTFt5Z1uDg8rATpzW5BNHkxvtGkS6CnvNbF(OHdOHkxvtGkuxTMbF(0CT2muBi8MRQjf9uxTMHc6pctz9Q8XmuN)fovGGckO)imz(kRxLpkuxTMjA(o4a(Uo7tWRpKJwASpgeUErafGOj9Ke1vRzIMVdoGVRZ(e86d5OLg7JbHRxuQkdq0KUchFJRZrql0Kkqk9Keq4zCqp6EeugBXNUmO35OiZqD(x4ubcjjE4EyzCqp6EeugBXNUmO35OiZx5M(rTD9veGqni0szcE(RGzOo)lCQkLoNgsZsSJjw2pFWRbfXca6IUnwIgyaZIxGSaU6Iyjfyamlw2OIfKLcKyTvGf4WYTrSaGev3w8Hf1vRXYJzXvHRJLdYsZ1AwGTglWHL4Wf6azj4rSKcmaMtZd3dlSbFatzKGpFWRbfH2VPS6Q1mWIUnCoOjFYiE8dlZkkjrD1Aga)cCiWm1fbTqthvxMkAq9PKmROKe1vRzcE(RGzfPON6Q1mJJGk4cNBdvPmUzOo)lmqrfanDoYb(a96Eo(gxNJGwObPgZ07dSyc8NRP6mfzj3bHLHkxvtGkSAwf1GdkYG)QT05T44JM3vOUAnZ4iOcUW52qvkJBwrjjQRwZe88xbZqD(xyGIkaA6CKd8b619C8nUohbTqdsnMP3pjrD1AMXrqfCHZTHQugpJ)QT05T44JM3nROKeRuxTMzCeubx4CBOkLXnRifwfGqni0szghbvWfo3gQszCZqoy8KeRcqeu51zqq1TfF6NK44BCDocAHMubsPRGc6pctMVYEfNtdPzX6tCwoilDoGel3gXIkHpwGnw2pF0WbKf14SGppa4xOy5pwwrSaCxFaqDCw(IfVIZc6f0FeMyrDDSaGxASpS846yXvHRJLdYIkXs0adbcKtZd3dlSbFatzKGpFWRbfH2VP85AQod(8rdhqdvUQMavy1SkQbhuK5(oYcCQm4qEN6xG0OON6Q1m4ZhnCanROKehFJRZrql0Kkqk9(kuxTMbF(OHdObFEaqGgtf9uxTMHc6pctzmu7JzfLKOUAndf0FeMY6v5Jzf1xH6Q1mrZ3bhW31zFcE9HC0sJ9XGW1lcOaeiMUIEbiudcTuMGN)kygQZ)cNQsPNKyfcFExvtMaSqabKYGeoEfueGiOYRZupQTl3CQpNgsZc6HVVZpcZYg0clDRWglPadGzXhIfu(xeilr0WcMcWcKtZd3dlSbFatzKGWN3v1eAlVJu2XrayA2PaAr46fPmf0FeMmFL1RYhGhiGu9W9WYGpFA)qgc5uyDu((ocywrb9hHjZxz9Q8b47bCa25AQodgU0zylFBuUbhcFgQCvnbc8XSps1d3dlJLXVndHCkSokFFhbS0nwdAqQ4isRZBo(iGLUbna)5AQot53AiCw11EfidvUQMa50qAwITRUiw2pFWRbfXYxS4SaebgMcSSd1(Wc6f0FeMqllGWcDhlA6y5pwIgyGfa8sJ9HLE3MFS8yw28cutGSOgNf6VnAy52iw2pFAUwZI(lIf4WYTrSKcmaovGu6SO)IyPbhw2pFWRbf1hTSacl0DSarqJL5pIfVybaDr3glrdmWIxGSOPJLBJyXvHiiw0FrSS5fOMyz)8rdhqonpCpSWg8bmLrc(8bVgueA)MYwnRIAWbfzUVJSaNkdoK3P(fink6PUAnt08DWb8DD2NGxFihT0yFmiC9IakabIPNKOUAnt08DWb8DD2NGxFihT0yFmiC9Iakart6koxt1zWhP1(KbNVDgQCvnb2xrpkO)imz(kJHAFu44BCDocAHgGHWN3v1KXXrayA2PaWRUAndf0FeMYyO2hZqD(xyGbcptBnXZWwM0RIm3haeNhQZ)c4bObnPcespjHc6pctMVY6v5JchFJRZrql0ame(8UQMmoocatZofaE1vRzOG(JWuwVkFmd15FHbgi8mT1epdBzsVkYCFaqCEOo)lGhGg0Kkqk9(kSsD1Agyr3gohrtGIUhwMvKcRoxt1zWNpA4aAOYv1eOIEbiudcTuMGN)kygQZ)cNkqmjbdxA1Van328ADgteG0yOYv1eOc1vRzUT516mMiaPXGppaiqJzmbG9Mvrn4GIm4VAlDElo(O5DGhn9v0EuBxEOo)lCQkLE6kApQTlpuN)fgOam907ROxac1GqlLbWVahcmJJ(5pSzOo)lCQaXKeRcqeu51zam(8E1NtdPzj2XelaOGWcZYxSG(RYhwqVG(JWelEbYc2rqSGugx3awSzP1SaGcclwAWHfKLcKyTvGfVazbP0xGdbYc61fbTqthvhNMhUhwyd(aMYiPil5oiSq73uUN6Q1muq)rykRxLpMH68VWPsiNcRJY33rjj9cB(GIWkdqfdf28bfLVVJakA6NKe28bfHvoM9v4r5WgfaubcFExvtgSJGYn4KdE(RaNMhUhwyd(aMYizZ1TChewO9Bk3tD1AgkO)imL1RYhZqD(x4ujKtH1r577ifwfGiOYRZay859kjPN6Q1ma(f4qGzQlcAHMoQUmv0G6tjzwrkcqeu51zam(8E1pjPxyZhuewzaQyOWMpOO89Deqrt)KKWMpOiSYXmjrD1AMGN)kywr9v4r5WgfaubcFExvtgSJGYn4KdE(RGIEQRwZmocQGlCUnuLY4MH68VWaThAaGae4Nvrn4GIm4VAlDElo(O59(kuxTMzCeubx4CBOkLXnROKeRuxTMzCeubx4CBOkLXnRO(CAE4EyHn4dykJK2sRZDqyH2VPCp1vRzOG(JWuwVkFmd15FHtLqofwhLVVJuyvaIGkVodGXN3RKKEQRwZa4xGdbMPUiOfA6O6YurdQpLKzfPiarqLxNbW4Z7v)KKEHnFqryLbOIHcB(GIY33rafn9tscB(GIWkhZKe1vRzcE(RGzf1xHhLdBuaqfi85DvnzWock3Gto45Vck6PUAnZ4iOcUW52qvkJBgQZ)cdu0OqD1AMXrqfCHZTHQug3SIuy1SkQbhuKb)vBPZBXXhnVNKyL6Q1mJJGk4cNBdvPmUzf1NtdPzj2Xelifq0JfyXsaKtZd3dlSbFatzKyXN5Htg2YKEveNgsZsSJjw2pFA)qSCqwIgyGLDO2hwqVG(JWeAzbzPajwBfyzZXSOjmML77iwUnVyXzbPy8BJfc5uyDelAQDSahwGLoolO)Q8Hf0lO)imXYJzzfXP5H7Hf2GpGPmsWNpTFi0(nLPG(JWK5RSEv(KKqb9hHjdgQ9jxeYVKekO)imz8kEUiKFjj9uxTMXIpZdNmSLj9QiZkkjbhrADEZXhb00nwdAuyvaIGkVodcQUT4tscoI068MJpcOPBSgfbicQ86miO62Ip9vOUAndf0FeMY6v5JzfLK0tD1AMGN)kygQZ)cdupCpSmwg)2meYPW6O89DKc1vRzcE(RGzf1NtdPzj2XelifJFBSaVnAS8yIflBFyJLhZYxSSd1(Wc6f0FeMqllilfiXARalWHLdYs0adSG(RYhwqVG(JWeNMhUhwyd(aMYiXY43gNgsZsSX16BBwCAE4EyHn4dykJKzvzpCpSY6hFOT8os5MR132SS3XruWowkLoaTp7Z2ga]] )

end