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
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
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
            duration = 10,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
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
            duration = 10,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
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
        thrash_cat ={
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 1,
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
            duration = 5,
            max_stack = 5
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 5,
            max_stack = 5,
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
                applyBuff( "balance_of_all_things_arcane", nil, 5, 10 )
                applyBuff( "balance_of_all_things_nature", nil, 5, 10 )
            end

            if talent.solstice.enabled then applyBuff( "solstice" ) end

            removeBuff( "starsurge_empowerment_lunar" )
            removeBuff( "starsurge_empowerment_solar" )
            applyBuff( "eclipse_lunar", duration )
            applyBuff( "eclipse_solar", duration )

            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            state:RemoveAuraExpiration( "eclipse_solar" )
            state:RemoveAuraExpiration( "eclipse_lunar" )
        end, state ),

        advance = setfenv( function()
            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Pre): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
            
            if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_solar" )
                state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 10 ) end
                eclipse.state = "IN_SOLAR"
                eclipse.reset_stacks()
                if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                return
            end

            if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_lunar" )                
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 10 ) end
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
            elseif debuff[ k ] ~= nil then return debuff[ k ]
            end
        end
    } ) )

    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandle( "wild_growth" ) end
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

                if buff.eclipse_solar.up and buff.eclipse_lunar.up then
                    buff.eclipse_solar.expires = buff.eclipse_solar.expires + 20
                    buff.eclipse_lunar.expires = buff.eclipse_lunar.expires + 20
                else
                    eclipse.trigger_both()
                end

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = 1.7,
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
            cast = 1.7,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 25,
            recharge = 25,
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

                if buff.eclipse_solar.up and buff.eclipse_lunar.up then
                    buff.eclipse_solar.expires = buff.eclipse_solar.expires + 20
                    buff.eclipse_lunar.expires = buff.eclipse_lunar.expires + 20
                else
                    eclipse.trigger_both()
                end

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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 0,
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
                if buff.warrior_of_elune.up or buff.elunes_wrath.up then return 0 end
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
            texture = 538771,

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

    spec:RegisterSetting( "solo_drift", false, {
        name = "Use |T236168:0|t Starfall in Single-Target with Stellar Drift",
        desc = "If checked, the addon will include a recommendation for |T236168:0|t Starfall in single-target.  This allows you to cast while moving during Starfall.\n\n" ..
            "This is a DPS loss but may be useful during M+.",
        icon = 236168,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = "full"        
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20201209, [[dGuEudqicLhbvQ4seQytG0NiuLgfvPtrvSkHi9kHWSasUfuP0Uq5xaPgguXXGQSmHupde10iuPRbISnHi(guPQXbvkohHQADeQI5rvv3tfSpQQCqGazHqv5HabnrGaWfbcG(iqa5KqLkzLcjZeiu7eiAOabOLcvQupvOMkujFfiqnwGaQ9c4VenyLomPftLEmQMmuUmYMf8zGA0eYPL61QqZMIBtf7w0VHmCqDCGqwUINtPPRQRRsBxf9DQkJhQQopiSEHOMpb7xYa4bGlGym9jaqgnorJdErJJ4ZWr8Xb3enEaXpeWeqmSYpQGjG4uDiGy8Pgn5eqmScHbPya4ci2IUdNaIf9pSv8aAqdUFrxxgh5aAB7Cn63OKpA4bTTD4Ggi292Mh3vc4ceJPpbaYOXjACWlACeFgoIpo4g8IgiwVVi0aeh3oGqGyrnggLaUaXyKLdeJ7ul(uJMCQwqam3gRIc3PwqaqCYXLMAfFqvB04enovuvu4o1ccfPjyYkEQOWDQf3wliimmcR2yKrNAXhPoSkkCNAXT1ccfPjycR2xhW0l7qTC1s2AFuTCi4gs(6aMElRIc3PwCBT4Ujh0jHv7ntItwRoqu7PoT6AiBTEBgXavTWdDkTVo27aMQf36xTWdDYSVo27aM8WQOWDQf3wliOtuJvl8qC1(DcUwqWJ(IQTd12V41w7lIQ13GsW1ccqUPHTedi2023cGlGy4H4ihx9bWfaiXdaxaXk)Buce7Gq5XoLb04aetP6Aima8b8aGmAaCbeR8Vrjq8XoXgctAH7PFlqmLQRHWaWhWdasidGlGykvxdHbGpGyL)nkbI9n6lciMp9ttRaXERL4Mg2smZn1rMe()AfeQL4Mg2sSoLMBQtTcc1sCtdBjwNsx0lQwbHAjUPHTettiKjH)VwpaXMojjhdigpCaEaqkUa4ciMs11qya4diMp9ttRaXERL4Mg2smZn1rMe()AfeQL4Mg2sSoLMBQtTcc1sCtdBjwNsx0lQwbHAjUPHTettiKjH)Vwp1cTw4Hoz4X8n6lQwO1kwTWdDYIM5B0xeqSY)gLaX(g9fb8aGesa4ciMs11qya4diMp9ttRaXIv7CtkGgWeZvnAYjjkivJr(I6eSLrP6AiSAfeQvSA5Otk18zzdw0ldkvRGqTIvRfMmg5Rdy6Tm7RtqnMApulE1kiuRy1(QHYNL6FhYkDvJMCIrP6AimGyL)nkbITVoHEiGhaKrcaUaIPuDnega(aI5t)00kq8CtkGgWeZvnAYjjkivJr(I6eSLrP6AiSAHwlhDsPMplBWIEzqPAHwRfMmg5Rdy6Tm7RtqnMApulEaXk)BuceBFDS3bmb8apqmgf0R5bWfaiXdaxaXk)BuceBrgDKUK6aetP6Aima8b8aGmAaCbetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGylmzmYxhW0Bz2xNGAm16xT4vl0A9wRy1(QHYNzFDmObJrP6AiSAfeQ9vdLpZ(KXOJeB6WZOuDnewTEQvqOwlmzmYxhW0Bz2xNGAm16xTrdeFQJmvhciUTsfrapaiHmaUaIPuDnega(aIrWaXw6bIv(3Oei(uNwDneq8PAUeqSfMmg5Rdy6Tm7RtOhQw)QfpG4tDKP6qaXTvYnKEsapaifxaCbetP6Aima8beZN(PPvGyV1kwTC0jLA(SSbl6LbLQvqOwXQLJqgmKVKXr5j6ijFrK0c3t)w2fUwp1cTw3BiW4QSto7cdeR8VrjqSlnwAo2jyGhaKqcaxaXuQUgcdaFaX8PFAAfi29gcmUk7KZUWaXk)BucedJ(gLapaiJeaCbetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjG4GbHMA9wR3A78Pbgz0NWKHgSOxoKJ2PTwCBTrJtT42A5iKbd5lzCuEIosYxejTW90VLnKJ2PTwp1c6AXlACQ1tT(vBWGqtTER1BTD(0aJm6tyYqdw0lhYr70wlUT2OHuT42A9wlE4uBKw7RgkFwNCDs9BuYOuDnewTEQf3wR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRNAXT1YridgYxY4QStoBihTtBTEQf01IhUbNA9uRGqTCeYGH8LmUk7KZgYr70wRF125tdmYOpHjdnyrVCihTtBTcc1YridgYxY4O8eDKKVisAH7PFlBihTtBT(vBNpnWiJ(eMm0Gf9YHC0oT1kiuRy1YrNuQ5ZYgSOxguci(uhzQoeqmhLNOJKeJSqKCGhaK4EaCbetP6Aima8beR8VrjqCNw(CF11qsq0vZ)6iXOZMtaX8PFAAfi29gcmUk7KZUWaXP6qaXDA5Z9vxdjbrxn)RJeJoBob8aGe3aGlGyL)nkbIVws2p5ybIPuDnega(aEaqk(a4ciMs11qya4diMp9ttRaXN60QRHyTvQici2(tZFaqIhqSY)gLaXZnLk)BuknT9bInT9LP6qaXkIaEaqIhoa4ciMs11qya4diMp9ttRaXZnPaAatSVDiFOjLydPoUDIrdJar3ggMWaIT)08haK4beR8Vrjq8CtPY)gLstBFGytBFzQoeqm2qQJBNy0a8aGep8aWfqmLQRHWaWhqmF6NMwbINBsb0aMyUQrtojrbPAmYxuNGTmceDByycdi2(tZFaqIhqSY)gLaXZnLk)BuknT9bInT9LP6qaXUi9bEaqIx0a4ciMs11qya4diw5FJsG45MsL)nkLM2(aXM2(YuDiGy7d8apqm2qQJBNy0aGlaqIhaUaIPuDnega(aIrWaXw6bIv(3Oei(uNwDneq8PAUeqS3ADVHa7BhYhAsj2qQJBNy0WgYr70wRF1cMJXCu8xBe1IddVAHwR3AjUPHTeRtPl6fvRGqTe30WwI1P0Im6uRGqTe30WwIzUPoYKW)xRNAfeQ19gcSVDiFOjLydPoUDIrdBihTtBT(vRY)gLm7RtOhIr4N43NKF7q1grT4WWRwO16TwIBAylX6uAUPo1kiulXnnSLywKrhzs4)RvqOwIBAylX0eczs4)R1tTEQvqOwXQ19gcSVDiFOjLydPoUDIrd7cdeFQJmvhci2Qbs(i51sslmzmapaiJgaxaXuQUgcdaFaX8PFAAfi2BTIv7PoT6AiMvdK8rYRLKwyYyQvqOwV16Edb2ONuIUwzyOmYqWgYr70wR)1cMJXCu8xBKwlNAtTERvT)OgjmYhn1c6AHmo16PwO16Edb2ONuIUwzyOmYqWUW16Pwp1kiuRA)rnsyKpAQ1VAfFCaIv(3Oei2(6yVdyc4bajKbWfqmLQRHWaWhqmF6NMwbI9w7PoT6AighLNOJKeJSqK8AHwBNpnWiJ(eMm0Gf9YHC0oT16xT4bzCQfATIvlhHmyiFjJRYo5SHumiQvqOw3BiW4QSto7cxRNAHwRA)rnsyKpAQ1)AfxCQfATER19gcmIBAyljn3uh2qoAN2A9Rw8WPwbHADVHaJ4Mg2sslYOdBihTtBT(vlE4uRNAfeQn0Gf9YHC0oT16FT4HdqSY)gLaXCuEIosYxejTW90Vf4baP4cGlGykvxdHbGpGyL)nkbIvmf(7tsA9PJdqmF6NMwbIfRwm0Zumf(7tsA9PJJetDuWe7B(Xobxl0AfRwL)nkzkMc)9jjT(0XrIPokyI1PmyAWI(AHwR3AfRwm0Zumf(7tsA9PJJuePg238JDcUwbHAXqptXu4VpjP1NoosrKAyd5ODAR1VAHuTEQvqOwm0Zumf(7tsA9PJJetDuWeZ(k)yT(xlKRfATyONPyk83NK06thhjM6OGj2qoAN2A9Vwixl0AXqptXu4VpjP1Noosm1rbtSV5h7emqmhcUHKVoGP3cas8aEaqcjaCbetP6Aima8beR8VrjqSdcLHEiGy(0pnTcepuyiRi11q1cT2xhW0Z(2HKpsI1uT(vlErxl0A9wR3ADVHaJRYo5SHC0oT16xTqQwO16Tw3BiWg9Ks01kddLrgc2qoAN2A9RwivRGqTIvR7neyJEsj6ALHHYidb7cxRNAfeQvSADVHaJRYo5SlCTcc1Q2FuJeg5JMA9VwiJtTEQfATERvSADVHa7yNydHjjhyKpACO8Lusd4oYe7cxRGqTQ9h1iHr(OPw)RfY4uRNAHwRcl5Ii(XA9aeZHGBi5Rdy6TaGepGhaKrcaUaIPuDnega(aIv(3Oei2EZqpeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)QfVORfATER1BTU3qGXvzNC2qoAN2A9Rwivl0A9wR7neyJEsj6ALHHYidbBihTtBT(vlKQvqOwXQ19gcSrpPeDTYWqzKHGDHR1tTcc1kwTU3qGXvzNC2fUwbHAv7pQrcJ8rtT(xlKXPwp1cTwV1kwTU3qGDStSHWKKdmYhnou(skPbChzIDHRvqOw1(JAKWiF0uR)1czCQ1tTqRvHLCre)yTEaI5qWnK81bm9waqIhWdasCpaUaIPuDnega(aIv(3Oei2(KXOJmy0HaI5t)00kq8qHHSIuxdvl0AFDatp7Bhs(ijwt16xT4fj1cTwV16Tw3BiW4QStoBihTtBT(vlKQfATER19gcSrpPeDTYWqzKHGnKJ2PTw)Qfs1kiuRy16Edb2ONuIUwzyOmYqWUW16PwbHAfRw3BiW4QSto7cxRGqTQ9h1iHr(OPw)RfY4uRNAHwR3AfRw3BiWo2j2qysYbg5JghkFjL0aUJmXUW1kiuRA)rnsyKpAQ1)AHmo16PwO1QWsUiIFSwpaXCi4gs(6aMElaiXd4bajUbaxaXuQUgcdaFaX8PFAAfiwHLCre)iqSY)gLaXb0Wjjkit9Vdb8aGu8bWfqmLQRHWaWhqmF6NMwbIDVHaJRYo5SlmqSY)gLaXJEsj6ALHHYidbWdas8WbaxaXuQUgcdaFaX8PFAAfi2BTER19gcmIBAyljTiJoSHC0oT16xT4HtTcc16EdbgXnnSLKMBQdBihTtBT(vlE4uRNAHwlhHmyiFjJRYo5SHC0oT16xTqgNA9uRGqTCeYGH8LmUk7KZgsXGaiw5FJsGyYbg5JgPlkXaEaqIhEa4ciMs11qya4diMp9ttRaXER1BTU3qGDStSHWKKdmYhnou(skPbChzIDHRvqOwXQLJoPuZNDeIP1Swp1kiulhDsPMplBWIEzqPAfeQ9uNwDneRTsfr1kiuR7neyUgecZCTp7cxl0ADVHaZ1GqyMR9zd5ODAR1)AJgNAJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16PwO1kwTU3qGXvzNC2fUwO16TwXQLJoPuZNLnyrVmOuTcc1YridgYxY4O8eDKKVisAH7PFl7cxRGqTD(0aJm6tyYqdw0lhYr70wR)1YridgYxY4O8eDKKVisAH7PFlBihTtBTruBKuRGqTD(0aJm6tyYqdw0lhYr70wR4ulE4gCQ1)AJgNAJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16biw5FJsGyozi73QrQMgC6q5d8aGeVObWfqmLQRHWaWhqmF6NMwbI9wR3ADVHa7yNydHjjhyKpACO8Lusd4oYe7cxRGqTIvlhDsPMp7ietRzTEQvqOwo6KsnFw2Gf9YGs1kiu7PoT6AiwBLkIQvqOw3BiWCnieM5AF2fUwO16EdbMRbHWmx7ZgYr70wR)1czCQnIA9wlhLy3(zWdXBljvtdoDO8zF7qYt1CPA9uRNAHwRy16EdbgxLDYzx4AHwR3AfRwo6KsnFw2Gf9YGs1kiulhHmyiFjJJYt0rs(IiPfUN(TSlCTcc125tdmYOpHjdnyrVCihTtBT(xlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnyrVCihTtBTItT4HBWPw)RfY4uBe16TwokXU9ZGhI3wsQMgC6q5Z(2HKNQ5s16PwpaXk)Buce3jxNu)gLapaiXdYa4ciMs11qya4digbdeBPhiw5FJsG4tDA11qaXNQ5saXERvSA5iKbd5lzCv2jNnKIbrTcc1kwTN60QRHyCuEIossmYcrYRfATC0jLA(SSbl6LbLQ1dq8PoYuDiGyREsYaAKCv2jh4bajEIlaUaIPuDnega(aI5t)00kqmXnnSLyDk1eIAHwRcl5Ii(XAHwR3AXqptXu4VpjP1Noosm1rbtSV5h7eCTcc1kwTC0jLA(SK4dYGgSA9ul0Ap1PvxdXS6jjdOrYvzNCGyL)nkbId3bcjkijZnjGhaK4bjaCbetP6Aima8beZN(PPvGyo6KsnFw2Gf9YGs1cT2tDA11qmokprhjjgzHi51cTw1(JAKWiF0uRFhQvCXPwO1YridgYxY4O8eDKKVisAH7PFlBihTtBT(xlyogZrXFTrATCQn16Tw1(JAKWiF0ulORfY4uRhGyL)nkbITVo27aMaEaqIxKaGlGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1cPA9uRGqTCr6aMS1EOwixRNAHwRcl5Ii(XAHw7PoT6AiMvpjzansUk7KdeR8VrjqCs(Koiuc8aGepCpaUaIPuDnega(aI5t)00kqS3ADVHaJ4Mg2ssZn1HDHRfATIvlhDsPMp7ietRzTcc16Tw3BiWo2j2qysYbg5JghkFjL0aUJmXUW1cTwo6KsnF2riMwZA9uRGqTERLlshWKT2d1gDTqRDiUiDatYVDOA9VwivRNAfeQLlshWKT2d1c5AfeQ19gcmUk7KZUW16PwO1QWsUiIFSwO1EQtRUgIz1tsgqJKRYo5aXk)BucelsnbPdcLapaiXd3aGlGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AHwRy1YrNuQ5ZocX0AwRGqTER19gcSJDIneMKCGr(OXHYxsjnG7itSlCTqRLJoPuZNDeIP1Swp1kiuR3A5I0bmzR9qTrxl0AhIlshWK8BhQw)Rfs16PwbHA5I0bmzR9qTqUwbHADVHaJRYo5SlCTEQfATkSKlI4hRfATN60QRHyw9KKb0i5QStoqSY)gLaXHRXiDqOe4bajEIpaUaIv(3Oei2NotJgjkijZnjGykvxdHbGpGhaKrJdaUaIPuDnega(aI5t)00kqmXnnSLyDkn3uNAfeQL4Mg2smlYOJmj8)1kiulXnnSLyAcHmj8)1kiuR7ney(0zA0irbjzUjXUW1cTw3BiWiUPHTK0CtDyx4AfeQ1BTU3qGXvzNC2qoAN2A9VwL)nkz(g9fXi8t87tYVDOAHwR7neyCv2jNDHR1dqSY)gLaX2xNqpeWdaYOXdaxaXk)Buce7B0xeqmLQRHWaWhWdaYOJgaxaXuQUgcdaFaXk)Bucep3uQ8VrP002hi202xMQdbehuJ5fnxGh4bIvebGlaqIhaUaIPuDnega(aIrWaXw6bIv(3Oei(uNwDneq8PAUeqS3ADVHa7BhYhAsj2qQJBNy0WgYr70wR)1cMJXCu8xBe1IddVAfeQ19gcSVDiFOjLydPoUDIrdBihTtBT(xRY)gLm7RtOhIr4N43NKF7q1grT4WWRwO16TwIBAylX6uAUPo1kiulXnnSLywKrhzs4)RvqOwIBAylX0eczs4)R1tTEQfATU3qG9Td5dnPeBi1XTtmAyx4AHw7CtkGgWe7BhYhAsj2qQJBNy0Wiq0THHjmG4tDKP6qaXydPosFTXidQXirHaWdaYObWfqmLQRHWaWhqmF6NMwbI9w7PoT6AighLNOJKeJSqK8AHwRy1YridgYxY4QStoBifdIAfeQ19gcmUk7KZUW16PwO1Q2FuJeg5JMA9VwiHtTqR1BTU3qGrCtdBjP5M6WgYr70wRF1gj1kiuR7neye30WwsArgDyd5ODAR1VAJKA9ul0A9wRy1o3KcObmXCvJMCsIcs1yKVOobBzuQUgcRwbHADVHaZvnAYjjkivJr(I6eSvM6FhIzFLFuEQMlvRF1czCQvqOw3BiWCvJMCsIcs1yKVOobBL6W1Ky2x5hLNQ5s16xTqgNA9uRGqTHgSOxoKJ2PTw)RfpCaIv(3OeiMJYt0rs(IiPfUN(TapaiHmaUaIPuDnega(aI5t)00kqS7ney2xNGAmSHcdzfPUgQwO16TwlmzmYxhW0Bz2xNGAm16FTqUwbHAfR25MuanGj23oKp0KsSHuh3oXOHrGOBddty16PwO16TwXQDUjfqdyIzGGRJALbdrFNGLGnTdSLyei62WWewTcc1(TdvR4uR4cPA9Rw3BiWSVob1yyd5ODARnIAJUwpaXk)BuceBFDcQXa8aGuCbWfqmLQRHWaWhqmF6NMwbINBsb0aMyF7q(qtkXgsDC7eJggbIUnmmHvl0ATWKXiFDatVLzFDcQXuRFhQfY1cTwV1kwTU3qG9Td5dnPeBi1XTtmAyx4AHwR7ney2xNGAmSHcdzfPUgQwbHA9w7PoT6Aig2qQJ0xBmYGAmsuiul0A9wR7ney2xNGAmSHC0oT16FTqUwbHATWKXiFDatVLzFDcQXuRF1gDTqR9vdLpZ(KXOJeB6WZOuDnewTqR19gcm7Rtqng2qoAN2A9VwivRNA9uRhGyL)nkbITVob1yaEaqcjaCbetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGy1(JAKWiF0uRF1IBWPwCBTERfpCQnsR19gcSVDiFOjLydPoUDIrdZ(k)yTEQf3wR3ADVHaZ(6euJHnKJ2PT2iTwixlOR1ctgJuKAFQwp1IBR1BTyONfUdesuqsMBsSHC0oT1gP1cPA9ul0ADVHaZ(6euJHDHbIp1rMQdbeBFDcQXi9HYxguJrIcbGhaKrcaUaIPuDnega(aI5t)00kq8PoT6Aig2qQJ0xBmYGAmsuiul0Ap1PvxdXSVob1yK(q5ldQXirHqTcc16Tw3BiWCvJMCsIcs1yKVOobBLP(3Hy2x5hLNQ5s16xTqgNAfeQ19gcmx1OjNKOGung5lQtWwPoCnjM9v(r5PAUuT(vlKXPwp1cTwlmzmYxhW0Bz2xNGAm16FTIlqSY)gLaX2xh7DatapaiX9a4ciMs11qya4diw5FJsGy7nd9qaX8PFAAfiEOWqwrQRHQfATVoGPN9TdjFKeRPA9Rw8e3AXT1AHjJr(6aMEBTru7qoAN2AHwRcl5Ii(XAHwlXnnSLyDk1ecGyoeCdjFDatVfaK4b8aGe3aGlGykvxdHbGpGyL)nkbIvmf(7tsA9PJdqmF6NMwbIfR2V5h7eCTqRvSAv(3OKPyk83NK06thhjM6OGjwNYGPbl6RvqOwm0Zumf(7tsA9PJJetDuWeZ(k)yT(xlKRfATyONPyk83NK06thhjM6OGj2qoAN2A9VwideZHGBi5Rdy6TaGepGhaKIpaUaIPuDnega(aIv(3Oei2bHYqpeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)Q1BT4jU1grTER1ctgJ81bm9wM91j0dvBKwlEmivRNA9ulOR1ctgJ81bm92AJO2HC0oT1cTwV1YridgYxY4QStoBifdIAHwR3Ap1PvxdX4O8eDKKyKfIKxRGqTCeYGH8Lmokprhj5lIKw4E63YgsXGOwbHAfRwo6KsnFw2Gf9YGs16PwbHATWKXiFDatVLzFDc9q16FTERvCRnsR1BT4vBe1(QHYN9(6u6GqPLrP6AiSA9uRNAfeQ1BTe30WwI1P0Im6uRGqTERL4Mg2sSoLUOxuTcc1sCtdBjwNsZn1Pwp1cTwXQ9vdLpZIUgjkiFrKmGgY(mkvxdHvRGqTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(DO2OHeo16PwO16TwlmzmYxhW0Bz2xNqpuT(xlE4uBKwR3AXR2iQ9vdLp791P0bHslJs11qy16Pwp1cTw1(JAKWiF0uRF1cjCQf3wR7ney2xNGAmSHC0oT1gP1gj16PwO16TwXQ19gcSJDIneMKCGr(OXHYxsjnG7itSlCTcc1sCtdBjwNslYOtTcc1kwTC0jLA(SJqmTM16PwO1QWsUiIFeiMdb3qYxhW0BbajEapaiXdhaCbetP6Aima8beZN(PPvGyfwYfr8JaXk)BucehqdNKOGm1)oeWdas8WdaxaXuQUgcdaFaX8PFAAfi29gcmUk7KZUWaXk)Bucep6jLORvggkJmeapaiXlAaCbetP6Aima8beZN(PPvGyV16EdbM91jOgd7cxRGqTQ9h1iHr(OPw)Qfs4uRNAHwRy16EdbMfzSFZj2fUwO1kwTU3qGXvzNC2fUwO16TwXQLJoPuZNLnyrVmOuTcc1EQtRUgIXr5j6ijXilejVwbHA5iKbd5lzCuEIosYxejTW90VLDHRvqO2oFAGrg9jmzObl6Ld5ODAR1)AJgNAJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16biw5FJsGyozi73QrQMgC6q5d8aGepidGlGykvxdHbGpGy(0pnTce7Tw3BiWSVob1yyx4AfeQvT)OgjmYhn16xTqcNA9ul0AfRw3BiWSiJ9BoXUW1cTwXQ19gcmUk7KZUW1cTwV1kwTC0jLA(SSbl6LbLQvqO2tDA11qmokprhjjgzHi51kiulhHmyiFjJJYt0rs(IiPfUN(TSlCTcc125tdmYOpHjdnyrVCihTtBT(xlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnyrVCihTtBTItT4HBWPw)RfY4uBe16TwokXU9ZGhI3wsQMgC6q5Z(2HKNQ5s16PwpaXk)Buce3jxNu)gLapaiXtCbWfqmLQRHWaWhqmF6NMwbI78Pbgz0NWKHgSOxoKJ2PTw)RfpivRGqTER19gcm4PDqdwRgPoCnBUe(AS6WovZLQ1)AJgs4uRGqTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(DO2OHeo16PwO16EdbM91jOgd7cxl0A5iKbd5lzCv2jNnKJ2PTw)Qfs4aeR8Vrjqm5aJ8rJ0fLyapaiXdsa4ciMs11qya4diw5FJsGy7tgJoYGrhciMp9ttRaXdfgYksDnuTqR9Bhs(ijwt16xT4bPAHwRfMmg5Rdy6Tm7RtOhQw)RvCRfATkSKlI4hRfATER19gcmUk7KZgYr70wRF1Iho1kiuRy16EdbgxLDYzx4A9aeZHGBi5Rdy6TaGepGhaK4fja4ciMs11qya4diMp9ttRaXe30WwI1PutiQfATkSKlI4hRfATU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB0qcNAHwR3AXqptXu4VpjP1Noosm1rbtSV5h7eCTcc1kwTC0jLA(SK4dYGgSAfeQ1ctgJ81bm92A9R2OR1dqSY)gLaXH7aHefKK5MeWdas8W9a4ciMs11qya4diMp9ttRaXU3qGHs6fzLW0Wj4Vrj7cxl0A9wR7ney2xNGAmSHcdzfPUgQwbHAv7pQrcJ8rtT(vR4JtTEaIv(3Oei2(6euJb4bajE4gaCbetP6Aima8beZN(PPvGyo6KsnFw2Gf9YGs1cTwV1EQtRUgIXr5j6ijXilejVwbHA5iKbd5lzCv2jNDHRvqOw3BiW4QSto7cxRNAHwlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT16FTG5ymhf)1gP1YP2uR3Av7pQrcJ8rtTGUwiHtTEQfATU3qGzFDcQXWgYr70wR)1kUaXk)BuceBFDcQXa8aGepXhaxaXuQUgcdaFaX8PFAAfiMJoPuZNLnyrVmOuTqR1BTN60QRHyCuEIossmYcrYRvqOwoczWq(sgxLDYzx4AfeQ19gcmUk7KZUW16PwO1YridgYxY4O8eDKKVisAH7PFlBihTtBT(xBKul0ADVHaZ(6euJHDHRfATe30WwI1PutiaIv(3Oei2(6yVdyc4baz04aGlGykvxdHbGpGy(0pnTce7EdbgkPxKvYnKoYZ22OKDHRvqOwV1kwT2xNqpetHLCre)yTcc16Tw3BiW4QStoBihTtBT(xlKQfATU3qGXvzNC2fUwbHA9wR7neyJEsj6ALHHYidbBihTtBT(xlyogZrXFTrATCQn16Tw1(JAKWiF0ulORfY4uRNAHwR7neyJEsj6ALHHYidb7cxRNA9ul0Ap1PvxdXSVob1yK(q5ldQXirHqTqR1ctgJ81bm9wM91jOgtT(xlKR1tTqR1BTIv7CtkGgWe7BhYhAsj2qQJBNy0Wiq0THHjSAfeQ1ctgJ81bm9wM91jOgtT(xlKR1dqSY)gLaX2xh7DatapaiJgpaCbetP6Aima8beZN(PPvGyV1sCtdBjwNsnHOwO1YridgYxY4QStoBihTtBT(vlKWPwbHA9wlxKoGjBThQn6AHw7qCr6aMKF7q16FTqQwp1kiulxKoGjBThQfY16PwO1QWsUiIFeiw5FJsG4K8jDqOe4baz0rdGlGykvxdHbGpGy(0pnTce7TwIBAylX6uQje1cTwoczWq(sgxLDYzd5ODAR1VAHeo1kiuR3A5I0bmzR9qTrxl0AhIlshWK8BhQw)Rfs16PwbHA5I0bmzR9qTqUwp1cTwfwYfr8JaXk)BucelsnbPdcLapaiJgYa4ciMs11qya4diMp9ttRaXERL4Mg2sSoLAcrTqRLJqgmKVKXvzNC2qoAN2A9RwiHtTcc16TwUiDat2ApuB01cT2H4I0bmj)2HQ1)AHuTEQvqOwUiDat2ApulKR1tTqRvHLCre)iqSY)gLaXHRXiDqOe4baz0IlaUaIv(3Oei2NotJgjkijZnjGykvxdHbGpGhaKrdjaCbetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGylmzmYxhW0Bz2xNqpuT(vR4wBe1gmi0uR3ADu7tdeYt1CPAbDTrJtTEQnIAdgeAQ1BTU3qGzFDS3bmjjhyKpACO8LwKrhM9v(XAbDTIBTEaIp1rMQdbeBFDc9qYoLwKrhGhaKrhja4ciMs11qya4diMp9ttRaXe30WwIzUPoYKW)xRGqTe30WwIPjeYKW)xl0Ap1PvxdXARKBi9KQvqOw3BiWiUPHTK0Im6WgYr70wR)1Q8VrjZ(6e6Hye(j(9j53ouTqR19gcmIBAyljTiJoSlCTcc1sCtdBjwNslYOtTqRvSAp1PvxdXSVoHEizNslYOtTcc16EdbgxLDYzd5ODAR1)Av(3OKzFDc9qmc)e)(K8BhQwO1kwTN60QRHyTvYnKEs1cTw3BiW4QStoBihTtBT(xlHFIFFs(Tdvl0ADVHaJRYo5SlCTcc16Edb2ONuIUwzyOmYqWUW1cTwlmzmsrQ9PA9RwCyrsTqR1BTwyYyKVoGP3wR)hQfY1kiuRy1(QHYNzrxJefKVisgqdzFgLQRHWQ1tTcc1kwTN60QRHyTvYnKEs1cTw3BiW4QStoBihTtBT(vlHFIFFs(TdbeR8VrjqSVrFrapaiJg3dGlGyL)nkbITVoHEiGykvxdHbGpGhaKrJBaWfqmLQRHWaWhqSY)gLaXZnLk)BuknT9bInT9LP6qaXb1yErZf4bEG4GAmVO5cGlaqIhaUaIPuDnega(aI5t)00kqSy1o3KcObmXCvJMCsIcs1yKVOobBzei62WWegqSY)gLaX2xh7DatapaiJgaxaXuQUgcdaFaXk)BuceBVzOhciMp9ttRaXyON5GqzOhInKJ2PTw)QDihTtlqmhcUHKVoGP3cas8aEaqczaCbeR8VrjqSdcLHEiGykvxdHbGpGh4bITpaUaajEa4ciMs11qya4diw5FJsGyftH)(KKwF64aeZN(PPvGyXQfd9mftH)(KKwF64iXuhfmX(MFStW1cTwXQv5FJsMIPWFFssRpDCKyQJcMyDkdMgSOVwO16TwXQfd9mftH)(KKwF64ifrQH9n)yNGRvqOwm0Zumf(7tsA9PJJuePg2qoAN2A9RwivRNAfeQfd9mftH)(KKwF64iXuhfmXSVYpwR)1c5AHwlg6zkMc)9jjT(0XrIPokyInKJ2PTw)RfY1cTwm0Zumf(7tsA9PJJetDuWe7B(XobdeZHGBi5Rdy6TaGepGhaKrdGlGykvxdHbGpGy(0pnTce7T2tDA11qmokprhjjgzHi51cTwXQLJqgmKVKXvzNC2qkge1kiuR7neyCv2jNDHR1tTqRvT)OgjmYhn16FTIlo1cTwV16EdbgXnnSLKMBQdBihTtBT(vlE4uRGqTU3qGrCtdBjPfz0HnKJ2PTw)QfpCQ1tTcc1gAWIE5qoAN2A9Vw8Wbiw5FJsGyokprhj5lIKw4E63c8aGeYa4ciMs11qya4digbdeBPhiw5FJsG4tDA11qaXNQ5saXER19gcmUk7KZgYr70wRF1cPAHwR3ADVHaB0tkrxRmmugziyd5ODAR1VAHuTcc1kwTU3qGn6jLORvggkJmeSlCTEQvqOwXQ19gcmUk7KZUW1kiuRA)rnsyKpAQ1)AHmo16PwO16TwXQ19gcSJDIneMKCGr(OXHYxsjnG7itSlCTcc1Q2FuJeg5JMA9VwiJtTEQfATER19gcmIBAyljTiJoSHC0oT16xTG5ymhf)1kiuR7neye30WwsAUPoSHC0oT16xTG5ymhf)16bi(uhzQoeqmg6LdbIU9qou(wGhaKIlaUaIPuDnega(aIv(3Oei2bHYqpeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)QfVORfATERvHLCre)yTqR9uNwDnedd9YHar3EihkFBTEaI5qWnK81bm9waqIhWdasibGlGykvxdHbGpGyL)nkbIT3m0dbeZN(PPvG4HcdzfPUgQwO1(6aME23oK8rsSMQ1VAXl6AHwR3AvyjxeXpwl0Ap1PvxdXWqVCiq0ThYHY3wRhGyoeCdjFDatVfaK4b8aGmsaWfqmLQRHWaWhqSY)gLaX2NmgDKbJoeqmF6NMwbIhkmKvK6AOAHw7Rdy6zF7qYhjXAQw)QfViPwO16TwfwYfr8J1cT2tDA11qmm0lhceD7HCO8T16biMdb3qYxhW0BbajEapaiX9a4ciMs11qya4diMp9ttRaXkSKlI4hbIv(3OeioGgojrbzQ)DiGhaK4gaCbetP6Aima8beZN(PPvGy3BiW4QSto7cdeR8Vrjq8ONuIUwzyOmYqa8aGu8bWfqmLQRHWaWhqmF6NMwbI9wR3ADVHaJ4Mg2sslYOdBihTtBT(vlE4uRGqTU3qGrCtdBjP5M6WgYr70wRF1Iho16PwO1YridgYxY4QStoBihTtBT(vlKXPwO16Tw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnAXfNAfeQvSANBsb0aMyWt7GgSwnsD4A2Cj81y1HrGOBddty16Pwp1kiuR7neyWt7GgSwnsD4A2Cj81y1HDQMlvRFhQnACpo1kiulhHmyiFjJRYo5SHumiQfATERvT)OgjmYhn16xTIpo1kiu7PoT6AiwBLkIQ1dqSY)gLaXKdmYhnsxuIb8aGepCaWfqmLQRHWaWhqmF6NMwbI9wRA)rnsyKpAQ1VAfFCQfATER19gcSJDIneMKCGr(OXHYxsjnG7itSlCTcc1kwTC0jLA(SJqmTM16PwbHA5Otk18zzdw0ldkvRGqTN60QRHyTvQiQwbHADVHaZ1GqyMR9zx4AHwR7neyUgecZCTpBihTtBT(xB04uBe16TwV1k(1gP1o3KcObmXGN2bnyTAK6W1S5s4RXQdJar3ggMWQ1tTruR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRNA9uRNAHwRy16EdbgxLDYzx4AHwR3AfRwo6KsnFw2Gf9YGs1kiulhHmyiFjJJYt0rs(IiPfUN(TSlCTcc125tdmYOpHjdnyrVCihTtBT(xlhHmyiFjJJYt0rs(IiPfUN(TSHC0oT1grTrsTcc125tdmYOpHjdnyrVCihTtBTItT4HBWPw)RnACQnIA9wlhLy3(zWdXBljvtdoDO8zF7qYt1CPA9uRhGyL)nkbI5KHSFRgPAAWPdLpWdas8WdaxaXuQUgcdaFaX8PFAAfi2BTQ9h1iHr(OPw)Qv8XPwO16Tw3BiWo2j2qysYbg5JghkFjL0aUJmXUW1kiuRy1YrNuQ5ZocX0AwRNAfeQLJoPuZNLnyrVmOuTcc1EQtRUgI1wPIOAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTqgNAJOwV16TwXV2iT25MuanGjg80oObRvJuhUMnxcFnwDyei62WWewTEQnIA9wlhLy3(zWdXBljvtdoDO8zF7qYt1CPA9uRNA9ul0AfRw3BiW4QSto7cxl0A9wRy1YrNuQ5ZYgSOxguQwbHA5iKbd5lzCuEIosYxejTW90VLDHRvqO2oFAGrg9jmzObl6Ld5ODAR1)A5iKbd5lzCuEIosYxejTW90VLnKJ2PT2iQnsQvqO2oFAGrg9jmzObl6Ld5ODARvCQfpCdo16FTqgNAJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16biw5FJsG4o56K63Oe4bajErdGlGykvxdHbGpGyemqSLEGyL)nkbIp1PvxdbeFQMlbe7TwXQLJqgmKVKXvzNC2qkge1kiuRy1EQtRUgIXr5j6ijXilejVwO1YrNuQ5ZYgSOxguQwpaXN6it1HaIT6jjdOrYvzNCGhaK4bzaCbetP6Aima8beZN(PPvGyIBAylX6uQje1cTwfwYfr8J1cTw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnAXfNAHwR3AXqptXu4VpjP1Noosm1rbtSV5h7eCTcc1kwTC0jLA(SK4dYGgSA9ul0Ap1PvxdXS6jjdOrYvzNCGyL)nkbId3bcjkijZnjGhaK4jUa4ciMs11qya4diMp9ttRaXU3qGHs6fzLW0Wj4Vrj7cxl0ADVHaZ(6euJHnuyiRi11qaXk)BuceBFDcQXa8aGepibGlGykvxdHbGpGy(0pnTce7EdbM91XGgm2qoAN2A9Vwivl0A9wR7neye30WwsArgDyd5ODAR1VAHuTcc16EdbgXnnSLKMBQdBihTtBT(vlKQ1tTqRvT)OgjmYhn16xTIpoaXk)BuceZ1KtgP7neaIDVHGmvhci2(6yqdgWdas8IeaCbetP6Aima8beZN(PPvGyo6KsnFw2Gf9YGs1cT2tDA11qmokprhjjgzHi51cTwoczWq(sghLNOJK8frslCp9Bzd5ODAR1)AHeqSY)gLaX2xh7DatapaiXd3dGlGykvxdHbGpGy(0pnTce)QHYNzFYy0rInD4zuQUgcRwO1kwTVAO8z2xhdAWyuQUgcRwO16EdbM91jOgdBOWqwrQRHQfATER19gcmIBAyljn3uh2qoAN2A9R2iPwO1sCtdBjwNsZn1PwO16Edbg80oObRvJuhUMnxcFnwDyNQ5s16FTrdjCQvqOw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)ouB0qcNAHwRA)rnsyKpAQ1VAfFCQvqOwm0Zumf(7tsA9PJJetDuWeBihTtBT(vlUPwbHAv(3OKPyk83NK06thhjM6OGjwNYGPbl6R1tTqRvSA5iKbd5lzCv2jNnKIbbqSY)gLaX2xNGAmapaiXd3aGlGykvxdHbGpGy(0pnTce7EdbgkPxKvYnKoYZ22OKDHRvqOw3BiWo2j2qysYbg5JghkFjL0aUJmXUW1kiuR7neyCv2jNDHRfATER19gcSrpPeDTYWqzKHGnKJ2PTw)RfmhJ5O4V2iTwo1MA9wRA)rnsyKpAQf01czCQ1tTqR19gcSrpPeDTYWqzKHGDHRvqOwXQ19gcSrpPeDTYWqzKHGDHRfATIvlhHmyiFjB0tkrxRmmugziydPyquRGqTIvlhDsPMp7KYxeetTEQvqOw1(JAKWiF0uRF1k(4ul0AjUPHTeRtPMqaeR8VrjqS91XEhWeWdas8eFaCbetP6Aima8beZN(PPvG4xnu(m7RJbnymkvxdHvl0A9wR7ney2xhdAWyx4AfeQvT)OgjmYhn16xTIpo16PwO16EdbM91XGgmM9v(XA9Vwixl0A9wR7neye30WwsArgDyx4AfeQ19gcmIBAyljn3uh2fUwp1cTw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnACpo1cTwV1YridgYxY4QStoBihTtBT(vlE4uRGqTIv7PoT6AighLNOJKeJSqK8AHwlhDsPMplBWIEzqPA9aeR8VrjqS91XEhWeWdaYOXbaxaXuQUgcdaFaX8PFAAfi2BTU3qGbpTdAWA1i1HRzZLWxJvh2PAUuT(xB04ECQvqOw3BiWGN2bnyTAK6W1S5s4RXQd7unxQw)RnAiHtTqR9vdLpZ(KXOJeB6WZOuDnewTEQfATU3qGrCtdBjPfz0HnKJ2PTw)Qf3xl0AjUPHTeRtPfz0PwO1kwTU3qGHs6fzLW0Wj4Vrj7cxl0AfR2xnu(m7RJbnymkvxdHvl0A5iKbd5lzCv2jNnKJ2PTw)Qf3xl0A9wlhHmyiFjJCGr(Or6Ism2qoAN2A9RwCFTcc1kwTC0jLA(SJqmTM16biw5FJsGy7RJ9oGjGhaKrJhaUaIPuDnega(aI5t)00kqS3ADVHaJ4Mg2ssZn1HDHRvqOwV1YfPdyYw7HAJUwO1oexKoGj53ouT(xlKQ1tTcc1YfPdyYw7HAHCTEQfATkSKlI4hRfATN60QRHyw9KKb0i5QStoqSY)gLaXj5t6GqjWdaYOJgaxaXuQUgcdaFaX8PFAAfi2BTU3qGrCtdBjP5M6WUW1cTwXQLJoPuZNDeIP1SwbHA9wR7neyh7eBimj5aJ8rJdLVKsAa3rMyx4AHwlhDsPMp7ietRzTEQvqOwV1YfPdyYw7HAJUwO1oexKoGj53ouT(xlKQ1tTcc1YfPdyYw7HAHCTcc16EdbgxLDYzx4A9ul0AvyjxeXpwl0Ap1PvxdXS6jjdOrYvzNCGyL)nkbIfPMG0bHsGhaKrdzaCbetP6Aima8beZN(PPvGyV16EdbgXnnSLKMBQd7cxl0AfRwo6KsnF2riMwZAfeQ1BTU3qGDStSHWKKdmYhnou(skPbChzIDHRfATC0jLA(SJqmTM16PwbHA9wlxKoGjBThQn6AHw7qCr6aMKF7q16FTqQwp1kiulxKoGjBThQfY1kiuR7neyCv2jNDHR1tTqRvHLCre)yTqR9uNwDneZQNKmGgjxLDYbIv(3OeioCngPdcLapaiJwCbWfqSY)gLaX(0zA0irbjzUjbetP6Aima8b8aGmAibGlGykvxdHbGpGy(0pnTcetCtdBjwNsZn1PwbHAjUPHTeZIm6itc)FTcc1sCtdBjMMqitc)FTcc16EdbMpDMgnsuqsMBsSlCTqR19gcmIBAyljn3uh2fUwbHA9wR7neyCv2jNnKJ2PTw)Rv5FJsMVrFrmc)e)(K8BhQwO16EdbgxLDYzx4A9aeR8VrjqS91j0db8aGm6ibaxaXk)Buce7B0xeqmLQRHWaWhWdaYOX9a4ciMs11qya4diw5FJsG45MsL)nkLM2(aXM2(YuDiG4GAmVO5c8apqSlsFaCbas8aWfqmLQRHWaWhqmF6NMwbIDVHaJRYo5SlmqSY)gLaXJEsj6ALHHYidbWdaYObWfqmLQRHWaWhqmcgi2spqSY)gLaXN60QRHaIpvZLaIfRw3BiWCvJMCsIcs1yKVOobBLP(3Hyx4AHwRy16EdbMRA0KtsuqQgJ8f1jyRuhUMe7cdeFQJmvhciMp9NO)cd8aGeYa4ciMs11qya4diw5FJsGyftH)(KKwF64aeZN(PPvGy3BiWCvJMCsIcs1yKVOobBLP(3Hy2x5hLNQ5s16FTIlo1cTw3BiWCvJMCsIcs1yKVOobBL6W1Ky2x5hLNQ5s16FTIlo1cTwV1kwTyONPyk83NK06thhjM6OGj238JDcUwO1kwTk)BuYumf(7tsA9PJJetDuWeRtzW0Gf91cTwV1kwTyONPyk83NK06thhPisnSV5h7eCTcc1IHEMIPWFFssRpDCKIi1WgYr70wRF1c5A9uRGqTyONPyk83NK06thhjM6OGjM9v(XA9Vwixl0AXqptXu4VpjP1Noosm1rbtSHC0oT16FTqQwO1IHEMIPWFFssRpDCKyQJcMyFZp2j4A9aeZHGBi5Rdy6TaGepGhaKIlaUaIPuDnega(aI5t)00kqS3Ap1PvxdX4O8eDKKyKfIKxl0AfRwoczWq(sgxLDYzdPyquRGqTU3qGXvzNC2fUwp1cTwV16EdbMRA0KtsuqQgJ8f1jyRm1)oeZ(k)O8unxQ2d1cjCQvqOw3BiWCvJMCsIcs1yKVOobBL6W1Ky2x5hLNQ5s1EOwiHtTEQvqO2qdw0lhYr70wR)1IhoaXk)BuceZr5j6ijFrK0c3t)wGhaKqcaxaXuQUgcdaFaX8PFAAfi2BTU3qG5Qgn5KefKQXiFrDc2kt9VdXgYr70wRF1kUmivRGqTU3qG5Qgn5KefKQXiFrDc2k1HRjXgYr70wRF1kUmivRNAHwRA)rnsyKpAQ1Vd1k(4ul0A9wlhHmyiFjJRYo5SHC0oT16xT4(AfeQ1BTCeYGH8LmYbg5JgPlkXyd5ODAR1VAX91cTwXQ19gcSJDIneMKCGr(OXHYxsjnG7itSlCTqRLJoPuZNDeIP1Swp16biw5FJsGyUMCYiDVHaqS7neKP6qaX2xhdAWaEaqgja4ciMs11qya4diMp9ttRaXIv7PoT6AigF6pr)fUwO16Two6KsnFw2Gf9YGs1kiulhHmyiFjJRYo5SHC0oT16xT4(AfeQ1BTCeYGH8LmYbg5JgPlkXyd5ODAR1VAX91cTwXQ19gcSJDIneMKCGr(OXHYxsjnG7itSlCTqRLJoPuZNDeIP1Swp16biw5FJsGy7RJ9oGjGhaK4EaCbetP6Aima8beZN(PPvGyV1YridgYxY4O8eDKKVisAH7PFlBihTtBT(xlKQfATER9uNwDneJJYt0rsIrwisETcc1YridgYxY4QStoBihTtBT(xlKQ1tTEQfATQ9h1iHr(OPw)QvCXPwO1YrNuQ5ZYgSOxguciw5FJsGy7RJ9oGjGhaK4gaCbetP6Aima8beR8VrjqS9MHEiGy(0pnTcepuyiRi11q1cT2xhW0Z(2HKpsI1uT(vlErsTqR1BTkSKlI4hRfATER9uNwDneJp9NO)cxRGqTERvT)OgjmYhn16FTqgNAHwRy16EdbgxLDYzx4A9uRGqTCeYGH8LmUk7KZgsXGOwp16biMdb3qYxhW0BbajEapaifFaCbetP6Aima8beR8VrjqSdcLHEiGy(0pnTcepuyiRi11q1cT2xhW0Z(2HKpsI1uT(vlEqMbPAHwR3AvyjxeXpwl0A9w7PoT6AigF6pr)fUwbHA9wRA)rnsyKpAQ1)AHmo1cTwXQ19gcmUk7KZUW16PwbHA5iKbd5lzCv2jNnKIbrTEQfATIvR7neyh7eBimj5aJ8rJdLVKsAa3rMyx4A9aeZHGBi5Rdy6TaGepGhaK4HdaUaIPuDnega(aIv(3Oei2(KXOJmy0HaI5t)00kq8qHHSIuxdvl0AFDatp7Bhs(ijwt16xT4fj1grTd5ODARfATERvHLCre)yTqR1BTN60QRHy8P)e9x4AfeQvT)OgjmYhn16FTqgNAfeQLJqgmKVKXvzNC2qkge16PwpaXCi4gs(6aMElaiXd4bajE4bGlGykvxdHbGpGy(0pnTceRWsUiIFeiw5FJsG4aA4KefKP(3HaEaqIx0a4ciMs11qya4diMp9ttRaXERL4Mg2sSoLAcrTcc1sCtdBjMfz0r2PeVAfeQL4Mg2smZn1r2PeVA9ul0A9wRy1YrNuQ5ZYgSOxguQwbHA9wRA)rnsyKpAQ1)AfFivl0A9w7PoT6AigF6pr)fUwbHAv7pQrcJ8rtT(xlKXPwbHAp1PvxdXARuruTEQfATER9uNwDneJJYt0rsIrwisETqRvSA5iKbd5lzCuEIosYxejTW90VLDHRvqOwXQ9uNwDneJJYt0rsIrwisETqRvSA5iKbd5lzCv2jNDHR1tTEQ1tTqR1BTCeYGH8LmUk7KZgYr70wRF1czCQvqOw1(JAKWiF0uRF1k(4ul0A5iKbd5lzCv2jNDHRfATERLJqgmKVKroWiF0iDrjgBihTtBT(xRY)gLm7RtOhIr4N43NKF7q1kiuRy1YrNuQ5ZocX0AwRNAfeQTZNgyKrFctgAWIE5qoAN2A9Vw8WPwp1cTwV1IHEMIPWFFssRpDCKyQJcMyd5ODAR1VAf3AfeQvSA5Otk18zjXhKbny16biw5FJsG4WDGqIcsYCtc4bajEqgaxaXuQUgcdaFaX8PFAAfi2BTe30WwIzUPoYKW)xRGqTe30WwIzrgDKjH)VwbHAjUPHTettiKjH)VwbHADVHaZvnAYjjkivJr(I6eSvM6FhInKJ2PTw)QvCzqQwbHADVHaZvnAYjjkivJr(I6eSvQdxtInKJ2PTw)QvCzqQwbHAv7pQrcJ8rtT(vR4JtTqRLJqgmKVKXvzNC2qkge16PwO16TwoczWq(sgxLDYzd5ODAR1VAHmo1kiulhHmyiFjJRYo5SHumiQ1tTcc125tdmYOpHjdnyrVCihTtBT(xlE4aeR8Vrjqm5aJ8rJ0fLyapaiXtCbWfqmLQRHWaWhqmF6NMwbI9wRA)rnsyKpAQ1VAfFCQfATER19gcSJDIneMKCGr(OXHYxsjnG7itSlCTcc1kwTC0jLA(SJqmTM16PwbHA5Otk18zzdw0ldkvRGqTU3qG5AqimZ1(SlCTqR19gcmxdcHzU2NnKJ2PTw)RnACQnIA9wlhLy3(zWdXBljvtdoDO8zF7qYt1CPA9uRNAHwR3Ap1PvxdX4O8eDKKyKfIKxRGqTCeYGH8Lmokprhj5lIKw4E63YgsXGOwp1kiuBNpnWiJ(eMm0Gf9YHC0oT16FTrJtTruR3A5Oe72pdEiEBjPAAWPdLp7BhsEQMlvRhGyL)nkbI5KHSFRgPAAWPdLpWdas8GeaUaIPuDnega(aI5t)00kqS3Av7pQrcJ8rtT(vR4JtTqR1BTU3qGDStSHWKKdmYhnou(skPbChzIDHRvqOwXQLJoPuZNDeIP1Swp1kiulhDsPMplBWIEzqPAfeQ19gcmxdcHzU2NDHRfATU3qG5AqimZ1(SHC0oT16FTqgNAJOwV1Yrj2TFg8q82ss10GthkF23oK8unxQwp16PwO16T2tDA11qmokprhjjgzHi51kiulhHmyiFjJJYt0rs(IiPfUN(TSHumiQ1tTcc125tdmYOpHjdnyrVCihTtBT(xlKXP2iQ1BTCuID7NbpeVTKunn40HYN9TdjpvZLQ1dqSY)gLaXDY1j1VrjWdas8IeaCbetP6Aima8beJGbIT0deR8Vrjq8PoT6AiG4t1CjGyIBAylX6uAUPo1gP1IBQf01Q8VrjZ(6e6Hye(j(9j53ouTruRy1sCtdBjwNsZn1P2iT2iPwqxRY)gLmFJ(Iye(j(9j53ouTruloSORf01AHjJrksTpbeFQJmvhciwTWGastmXbEaqIhUhaxaXuQUgcdaFaX8PFAAfi2BTD(0aJm6tyYqdw0lhYr70wR)1kU1kiuR3ADVHaB0tkrxRmmugziyd5ODAR1)AbZXyok(RnsRLtTPwV1Q2FuJeg5JMAbDTqgNA9ul0ADVHaB0tkrxRmmugziyx4A9uRNAfeQ1BTQ9h1iHr(OP2iQ9uNwDnetTWGastmXRnsR19gcmIBAyljTiJoSHC0oT1grTyONfUdesuqsMBsSV5hTYHC0oRnsRnAgKQ1VAXlACQvqOw1(JAKWiF0uBe1EQtRUgIPwyqaPjM41gP16EdbgXnnSLKMBQdBihTtBTrulg6zH7aHefKK5Me7B(rRCihTZAJ0AJMbPA9Rw8IgNA9ul0AjUPHTeRtPMqul0A9wR3AfRwoczWq(sgxLDYzx4AfeQLJoPuZNDeIP1SwO1kwTCeYGH8LmYbg5JgPlkXyx4A9uRGqTC0jLA(SSbl6LbLQ1tTqR1BTIvlhDsPMp7KYxeetTcc1kwTU3qGXvzNC2fUwbHAv7pQrcJ8rtT(vR4JtTEQvqOw3BiW4QStoBihTtBT(vlUPwO1kwTU3qGn6jLORvggkJmeSlmqSY)gLaX2xh7DatapaiXd3aGlGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1cPA9uRGqTCr6aMS1EOwixRNAHwRcl5Ii(rGyL)nkbItYN0bHsGhaK4j(a4ciMs11qya4diMp9ttRaXER19gcmIBAyljn3uh2fUwbHA9wlxKoGjBThQn6AHw7qCr6aMKF7q16FTqQwp1kiulxKoGjBThQfY16PwO1QWsUiIFeiw5FJsGyrQjiDqOe4baz04aGlGykvxdHbGpGy(0pnTce7Tw3BiWiUPHTK0CtDyx4AfeQ1BTCr6aMS1EO2ORfATdXfPdys(TdvR)1cPA9uRGqTCr6aMS1EOwixRNAHwRcl5Ii(rGyL)nkbIdxJr6GqjWdaYOXdaxaXk)Buce7tNPrJefKK5MeqmLQRHWaWhWdaYOJgaxaXuQUgcdaFaX8PFAAfiM4Mg2sSoLMBQtTcc1sCtdBjMfz0rMe()AfeQL4Mg2smnHqMe()AfeQ19gcmF6mnAKOGKm3Kyx4AHwR7neye30WwsAUPoSlCTcc16Tw3BiW4QStoBihTtBT(xRY)gLmFJ(Iye(j(9j53ouTqR19gcmUk7KZUW16biw5FJsGy7RtOhc4baz0qgaxaXk)Buce7B0xeqmLQRHWaWhWdaYOfxaCbetP6Aima8beR8Vrjq8CtPY)gLstBFGytBFzQoeqCqnMx0CbEGh4bIpPX2OeaKrJt04Gx04GBaI9Pt2jylqmiyqq4UbjUlqccK4P2AXLiQ22bgnFTb0uR4fBi1XTtmAeV1oei62dHvRf5q1Q3h5OpHvlxKMGjlRIce3jvB0INAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXd)EyvuG4oPAXdpXtTGquEsZty1g3oGWATqKVI)AfhXP2hvli(Q16GWUMRTwemn6JMA9koEQ1lE43dRIce3jvlErlEQfeIYtAEcR242bewRfI8v8xR4io1(OAbXxTwhe21CT1IGPrF0uRxXXtTEXd)EyvuG4oPAXdsINAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXd)EyvuvuGGbbH7gK4UajiqINARfxIOABhy081gqtTIxmkOxZlERDiq0ThcRwlYHQvVpYrFcRwUinbtwwffiUtQ2ir8ulieLN08ewTXTdiSwle5R4VwXP2hvli(Q1I1NTTrzTiyA0hn16f0EQ1B043dRIQIcemiiC3Ge3fibbs8uBT4sevB7aJMV2aAQv8cpeh54QV4T2Har3EiSATihQw9(ih9jSA5I0emzzvuG4oPAHK4PwqikpP5jSAfVZnPaAatmqGfV1(OAfVZnPaAatmqGzuQUgct8wRx8WVhwffiUtQ2ir8ulieLN08ewTI35MuanGjgiWI3AFuTI35MuanGjgiWmkvxdHjER1lE43dRIQIcemiiC3Ge3fibbs8uBT4sevB7aJMV2aAQv8Qis8w7qGOBpewTwKdvREFKJ(ewTCrAcMSSkkqCNuTrlEQfeIYtAEcRwX7CtkGgWedeyXBTpQwX7CtkGgWedeygLQRHWeV16fp87HvrbI7KQfYINAbHO8KMNWQnUDaH1AHiFf)1koItTpQwq8vR1bHDnxBTiyA0hn16vC8uRx8WVhwffiUtQwijEQfeIYtAEcR242bewRfI8v8xR4u7JQfeF1AX6Z22OSwemn6JMA9cAp16fp87HvrbI7KQv8fp1ccr5jnpHvBC7acR1cr(k(RvCQ9r1cIVATy9zBBuwlcMg9rtTEbTNA9Ih(9WQOaXDs1IhKfp1ccr5jnpHvBC7acR1cr(k(RvCeNAFuTG4RwRdc7AU2ArW0OpAQ1R44PwV4HFpSkkqCNuT4HBep1ccr5jnpHvBC7acR1cr(k(RvCQ9r1cIVATy9zBBuwlcMg9rtTEbTNA9Ih(9WQOaXDs1gnoINAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXd)EyvuG4oPAJgsINAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEJg)EyvuvuGGbbH7gK4UajiqINARfxIOABhy081gqtTIx7lERDiq0ThcRwlYHQvVpYrFcRwUinbtwwffiUtQw8Wr8ulieLN08ewTXTdiSwle5R4VwXrCQ9r1cIVAToiSR5ARfbtJ(OPwVIJNA9Ih(9WQOaXDs1IhEINAbHO8KMNWQnUDaH1AHiFf)1koItTpQwq8vR1bHDnxBTiyA0hn16vC8uRx8WVhwffiUtQw8WnINAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXd)EyvuvuGGbbH7gK4UajiqINARfxIOABhy081gqtTIxxK(I3AhceD7HWQ1ICOA17JC0NWQLlstWKLvrbI7KQfVir8ulieLN08ewTXTdiSwle5R4VwXP2hvli(Q1I1NTTrzTiyA0hn16f0EQ1lKXVhwffiUtQw8W9INAbHO8KMNWQnUDaH1AHiFf)1ko1(OAbXxTwS(STnkRfbtJ(OPwVG2tTEXd)Eyvuvu4UCGrZty1I7Rv5FJYAnT9TSkkGylmXbajE4enqm8GcTHaIXDQfFQrtovliaMBJvrH7uliaio54stTIpOQnACIgNkQkkCNAbHI0emzfpvu4o1IBRfeeggHvBmYOtT4JuhwffUtT42AbHI0emHv7Rdy6LDOwUAjBTpQwoeCdjFDatVLvrH7ulUTwC3Kd6KWQ9MjXjRvhiQ9uNwDnKTwVnJyGQw4HoL2xh7Dat1IB9Rw4Hoz2xh7DatEyvu4o1IBRfe0jQXQfEiUA)obxli4rFr12HA7x8AR9fr16Bqj4Abbi30WwIvrvrP8VrPLbpeh54Q)bhekp2PmGgNkkL)nkTm4H4ihx9J4aOp2j2qyslCp9BROu(3O0YGhIJCC1pIdG23OViqz6KKCSd4HdO6WbVe30WwIzUPoYKW)liqCtdBjwNsZn1rqG4Mg2sSoLUOxKGaXnnSLyAcHmj8)EQOu(3O0YGhIJCC1pIdG23OViq1HdEjUPHTeZCtDKjH)xqG4Mg2sSoLMBQJGaXnnSLyDkDrVibbIBAylX0eczs4)9afEOtgEmFJ(IGkg8qNSOz(g9fvrP8VrPLbpeh54QFehaT91j0dbQoCqS5MuanGjMRA0KtsuqQgJ8f1jyRGGyC0jLA(SSbl6LbLeeeZctgJ81bm9wM91jOgZb8eee7vdLpl1)oKv6Qgn5eJs11qyvuk)BuAzWdXroU6hXbqBFDS3bmbQoCyUjfqdyI5Qgn5KefKQXiFrDc2cLJoPuZNLnyrVmOeulmzmYxhW0Bz2xNGAmhWRIQIc3PwqaIFIFFcRw6KgiQ9BhQ2xevRYF0uBBRvp12OUgIvrP8VrP9Gfz0r6sQtfLY)gL2dN60QRHavQo0H2kvebQt1CPdwyYyKVoGP3YSVob1y8dpOEf7vdLpZ(6yqdgJs11qyccVAO8z2NmgDKythEgLQRHW8iiyHjJr(6aMElZ(6euJXVOROu(3O0gXbqFQtRUgcuP6qhARKBi9Ka1PAU0blmzmYxhW0Bz2xNqpKF4vrP8VrPnIdG2Lglnh7emO6WbVIXrNuQ5ZYgSOxgusqqmoczWq(sghLNOJK8frslCp9BzxypqDVHaJRYo5SlCfLY)gL2ioaAy03OeuD4G7neyCv2jNDHROu(3O0gXbqFQtRUgcuP6qh4O8eDKKyKfIKdQt1CPdbdcnE925tdmYOpHjdnyrVCihTtlUnACWTCeYGH8Lmokprhj5lIKw4E63YgYr706rCWlAC84xWGqJxVD(0aJm6tyYqdw0lhYr70IBJgs4wV4HtK(QHYN1jxNu)gLmkvxdH5b36LJsSB)m4H4TLKQPbNou(SVDi5PAUKhClhHmyiFjJRYo5SHC0oTEeh8Wn44rqGJqgmKVKXvzNC2qoANw)68Pbgz0NWKHgSOxoKJ2PvqGJqgmKVKXr5j6ijFrK0c3t)w2qoANw)68Pbgz0NWKHgSOxoKJ2Pvqqmo6KsnFw2Gf9YGsvuk)BuAJ4aOVws2p5aQuDOdDA5Z9vxdjbrxn)RJeJoBobQoCW9gcmUk7KZUWvu4o1Q8VrPnIdG(Ajz)KJfuwd6Th(PZJ0JhO6WbX(PZJ0ZWJjsTs4bXzAcbuVI9tNhPNfntKALWdIZ0ecbbX(PZJ0ZIMnKIbHKJqgmKV0JGG7neyCv2jNDHfe4iKbd5lzCv2jNnKJ2Pf3Iho(9tNhPNHhJJqgmKVKHDh9Bucvmo6KsnF2riMwtbbo6KsnFw2Gf9YGsqp1PvxdX4O8eDKKyKfIKdLJqgmKVKXr5j6ijFrK0c3t)w2fwqW9gcSJDIneMKCGr(OXHYxsjnG7itSlSGqObl6Ld5ODA9pACQOWDQv5FJsBeha91sY(jhlOSg0Bp8tNhPpAq1HdI9tNhPNfntKALWdIZ0ecOEf7NopspdpMi1kHheNPjeccI9tNhPNHhBifdcjhHmyiFPhbHF68i9m8yIuReEqCMMqa9NopsplAMi1kHheNPjeqf7Nopspdp2qkgesoczWq(sbb3BiW4QSto7cliWridgYxY4QStoBihTtlUfpC87NopsplAghHmyiFjd7o63OeQyC0jLA(SJqmTMccC0jLA(SSbl6LbLGEQtRUgIXr5j6ijXilejhkhHmyiFjJJYt0rs(IiPfUN(TSlSGG7neyh7eBimj5aJ8rJdLVKsAa3rMyxybHqdw0lhYr706F04urP8VrPnIdG(Ajz)KJTIs5FJsBeha9CtPY)gLstBFqLQdDqreOS)08)aEGQdho1PvxdXARurufLY)gL2ioa65MsL)nkLM2(Gkvh6a2qQJBNy0ak7pn)pGhO6WH5MuanGj23oKp0KsSHuh3oXOHrGOBddtyvuk)BuAJ4aONBkv(3OuAA7dQuDOdUi9bL9NM)hWduD4WCtkGgWeZvnAYjjkivJr(I6eSLrGOBddtyvuk)BuAJ4aONBkv(3OuAA7dQuDOd2VIQIs5FJsltr0HtDA11qGkvh6a2qQJ0xBmYGAmsuiaQt1CPdEDVHa7BhYhAsj2qQJBNy0WgYr706pyogZrXFe4WWtqW9gcSVDiFOjLydPoUDIrdBihTtR)k)BuYSVoHEigHFIFFs(Tdfbom8G6L4Mg2sSoLMBQJGaXnnSLywKrhzs4)feiUPHTettiKjH)3JhOU3qG9Td5dnPeBi1XTtmAyxyOZnPaAatSVDiFOjLydPoUDIrdJar3ggMWQOu(3O0YuefXbqZr5j6ijFrK0c3t)wq1HdEp1PvxdX4O8eDKKyKfIKdvmoczWq(sgxLDYzdPyqii4EdbgxLDYzxypqv7pQrcJ8rJ)qchOEDVHaJ4Mg2ssZn1HnKJ2P1VirqW9gcmIBAyljTiJoSHC0oT(fjEG6vS5MuanGjMRA0KtsuqQgJ8f1jyRGG7neyUQrtojrbPAmYxuNGTYu)7qm7R8JYt1Cj)GmoccU3qG5Qgn5KefKQXiFrDc2k1HRjXSVYpkpvZL8dY44rqi0Gf9YHC0oT(Jhovuk)BuAzkII4aOTVob1yavho4EdbM91jOgdBOWqwrQRHG61ctgJ81bm9wM91jOgJ)qwqqS5MuanGj23oKp0KsSHuh3oXOHrGOBddtyEG6vS5MuanGjMbcUoQvgme9Dcwc20oWwIrGOBddtyccF7qIJ4iUqYp3BiWSVob1yyd5ODAJiApvuk)BuAzkII4aOTVob1yavhom3KcObmX(2H8HMuInK642jgnmceDByycdQfMmg5Rdy6Tm7Rtqng)oazOEfZ9gcSVDiFOjLydPoUDIrd7cd19gcm7Rtqng2qHHSIuxdji49uNwDnedBi1r6RngzqngjkeG619gcm7Rtqng2qoANw)HSGGfMmg5Rdy6Tm7Rtqng)Ig6RgkFM9jJrhj20HNrP6AimOU3qGzFDcQXWgYr706pK84XtfLY)gLwMIOioa6tDA11qGkvh6G91jOgJ0hkFzqngjkea1PAU0b1(JAKWiF04hUbhCRx8WjsDVHa7BhYhAsj2qQJBNy0WSVYp6b3619gcm7Rtqng2qoAN2ifYIJfMmgPi1(KhCRxm0Zc3bcjkijZnj2qoAN2ifsEG6EdbM91jOgd7cxrP8VrPLPikIdG2(6yVdycuD4WPoT6Aig2qQJ0xBmYGAmsuia9uNwDneZ(6euJr6dLVmOgJefcccEDVHaZvnAYjjkivJr(I6eSvM6FhIzFLFuEQMl5hKXrqW9gcmx1OjNKOGung5lQtWwPoCnjM9v(r5PAUKFqghpqTWKXiFDatVLzFDcQX4V4wrP8VrPLPikIdG2EZqpeO4qWnK81bm92d4bQoCyOWqwrQRHG(6aME23oK8rsSM8dpXf3AHjJr(6aMEBed5ODAHQWsUiIFekXnnSLyDk1eIkkL)nkTmfrrCa0kMc)9jjT(0XbuCi4gs(6aME7b8avhoi238JDcgQyk)BuYumf(7tsA9PJJetDuWeRtzW0Gf9ccyONPyk83NK06thhjM6OGjM9v(r)Hmum0Zumf(7tsA9PJJetDuWeBihTtR)qUIs5FJsltruehaTdcLHEiqXHGBi5Rdy6ThWduD4WqHHSIuxdb91bm9SVDi5JKyn5Nx8e3i8AHjJr(6aMElZ(6e6HIu8yqYJhXXctgJ81bm92igYr70c1lhHmyiFjJRYo5SHumiG69uNwDneJJYt0rsIrwisUGahHmyiFjJJYt0rs(IiPfUN(TSHumieeeJJoPuZNLnyrVmOKhbblmzmYxhW0Bz2xNqpK)Ef3i1lEr8QHYN9(6u6GqPLrP6AimpEee8sCtdBjwNslYOJGGxIBAylX6u6IErcce30WwI1P0CtD8avSxnu(ml6AKOG8frYaAi7ZOuDneMGG7neyWt7GgSwnsD4A2Cj81y1HDQMl53HOHeoEG61ctgJ81bm9wM91j0d5pE4ePEXlIxnu(S3xNshekTmkvxdH5Xdu1(JAKWiF04hKWb36EdbM91jOgdBihTtBKgjEG6vm3BiWo2j2qysYbg5JghkFjL0aUJmXUWcce30WwI1P0Im6iiighDsPMp7ietRPhOkSKlI4hROu(3O0YuefXbqhqdNKOGm1)oeO6WbfwYfr8Jvuk)BuAzkII4aOh9Ks01kddLrgcq1HdU3qGXvzNC2fUIs5FJsltruehanNmK9B1ivtdoDO8bvho419gcm7Rtqng2fwqqT)OgjmYhn(bjC8avm3BiWSiJ9BoXUWqfZ9gcmUk7KZUWq9kghDsPMplBWIEzqjbHtDA11qmokprhjjgzHi5ccCeYGH8Lmokprhj5lIKw4E63YUWccD(0aJm6tyYqdw0lhYr706F04eHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8urP8VrPLPikIdGUtUoP(nkbvho419gcm7Rtqng2fwqqT)OgjmYhn(bjC8avm3BiWSiJ9BoXUWqfZ9gcmUk7KZUWq9kghDsPMplBWIEzqjbHtDA11qmokprhjjgzHi5ccCeYGH8Lmokprhj5lIKw4E63YUWccD(0aJm6tyYqdw0lhYr706phHmyiFjJJYt0rs(IiPfUN(TSHC0oTrejccD(0aJm6tyYqdw0lhYr70koIdE4gC8hY4eHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8urP8VrPLPikIdGMCGr(Or6Ismq1HdD(0aJm6tyYqdw0lhYr706pEqsqWR7neyWt7GgSwnsD4A2Cj81y1HDQMl5F0qchbb3BiWGN2bnyTAK6W1S5s4RXQd7unxYVdrdjC8a19gcm7Rtqng2fgkhHmyiFjJRYo5SHC0oT(bjCQOu(3O0YuefXbqBFYy0rgm6qGIdb3qYxhW0BpGhO6WHHcdzfPUgc63oK8rsSM8dpib1ctgJ81bm9wM91j0d5V4cvHLCre)iuVU3qGXvzNC2qoANw)WdhbbXCVHaJRYo5SlSNkkL)nkTmfrrCa0H7aHefKK5MeO6WbIBAylX6uQjeqvyjxeXpc19gcm4PDqdwRgPoCnBUe(AS6WovZL8pAiHduVyONPyk83NK06thhjM6OGj238JDcwqqmo6KsnFws8bzqdMGGfMmg5Rdy6T(fTNkkL)nkTmfrrCa02xNGAmGQdhCVHadL0lYkHPHtWFJs2fgQx3BiWSVob1yydfgYksDnKGGA)rnsyKpA8t8XXtfLY)gLwMIOioaA7Rtqngq1HdC0jLA(SSbl6LbLG69uNwDneJJYt0rsIrwisUGahHmyiFjJRYo5SlSGG7neyCv2jNDH9aLJqgmKVKXr5j6ijFrK0c3t)w2qoANw)bZXyok(Juo1gVQ9h1iHr(OrCGeoEG6EdbM91jOgdBihTtR)IBfLY)gLwMIOioaA7RJ9oGjq1HdC0jLA(SSbl6LbLG69uNwDneJJYt0rsIrwisUGahHmyiFjJRYo5SlSGG7neyCv2jNDH9aLJqgmKVKXr5j6ijFrK0c3t)w2qoANw)JeOU3qGzFDcQXWUWqjUPHTeRtPMqurP8VrPLPikIdG2(6yVdycuD4G7neyOKErwj3q6ipBBJs2fwqWRy2xNqpetHLCre)OGGx3BiW4QStoBihTtR)qcQ7neyCv2jNDHfe86Edb2ONuIUwzyOmYqWgYr706pyogZrXFKYP24vT)OgjmYhnIdKXXdu3BiWg9Ks01kddLrgc2f2JhON60QRHy2xNGAmsFO8Lb1yKOqaQfMmg5Rdy6Tm7Rtqng)HShOEfBUjfqdyI9Td5dnPeBi1XTtmAyei62WWeMGGfMmg5Rdy6Tm7Rtqng)HSNkkL)nkTmfrrCa0j5t6GqjO6WbVe30WwI1PutiGYridgYxY4QStoBihTtRFqchbbVCr6aMShIg6qCr6aMKF7q(djpccCr6aMShGShOkSKlI4hROu(3O0YuefXbqlsnbPdcLGQdh8sCtdBjwNsnHakhHmyiFjJRYo5SHC0oT(bjCee8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYEGQWsUiIFSIs5FJsltruehaD4Amshekbvho4L4Mg2sSoLAcbuoczWq(sgxLDYzd5ODA9ds4ii4LlshWK9q0qhIlshWK8BhYFi5rqGlshWK9aK9avHLCre)yfLY)gLwMIOioaAF6mnAKOGKm3KQOu(3O0YuefXbqFQtRUgcuP6qhSVoHEizNslYOdOovZLoyHjJr(6aMElZ(6e6H8tCJiyqOXRJAFAGqEQMljorJJNicgeA86EdbM91XEhWKKCGr(OXHYxArgDy2x5hfhX1tfLY)gLwMIOioaAFJ(IavhoqCtdBjM5M6itc)VGaXnnSLyAcHmj8)qp1PvxdXARKBi9KeeCVHaJ4Mg2sslYOdBihTtR)k)BuYSVoHEigHFIFFs(Tdb19gcmIBAyljTiJoSlSGaXnnSLyDkTiJoqf7uNwDneZ(6e6HKDkTiJoccU3qGXvzNC2qoANw)v(3OKzFDc9qmc)e)(K8BhcQyN60QRHyTvYnKEsqDVHaJRYo5SHC0oT(t4N43NKF7qqDVHaJRYo5SlSGG7neyJEsj6ALHHYidb7cd1ctgJuKAFYpCyrcuVwyYyKVoGP36)bilii2RgkFMfDnsuq(IizanK9zuQUgcZJGGyN60QRHyTvYnKEsqDVHaJRYo5SHC0oT(r4N43NKF7qvuk)BuAzkII4aOTVoHEOkkL)nkTmfrrCa0ZnLk)BuknT9bvQo0HGAmVO5wrvrP8VrPL5I0)WONuIUwzyOmYqaQoCW9gcmUk7KZUWvuk)BuAzUi9J4aOp1PvxdbQuDOd8P)e9xyqDQMlDqm3BiWCvJMCsIcs1yKVOobBLP(3HyxyOI5EdbMRA0KtsuqQgJ8f1jyRuhUMe7cxrP8VrPL5I0pIdGwXu4VpjP1NooGIdb3qYxhW0BpGhO6Wb3BiWCvJMCsIcs1yKVOobBLP(3Hy2x5hLNQ5s(lU4a19gcmx1OjNKOGung5lQtWwPoCnjM9v(r5PAUK)Iloq9kgg6zkMc)9jjT(0XrIPokyI9n)yNGHkMY)gLmftH)(KKwF64iXuhfmX6ugmnyrpuVIHHEMIPWFFssRpDCKIi1W(MFStWccyONPyk83NK06thhPisnSHC0oT(bzpccyONPyk83NK06thhjM6OGjM9v(r)Hmum0Zumf(7tsA9PJJetDuWeBihTtR)qckg6zkMc)9jjT(0XrIPokyI9n)yNG9urP8VrPL5I0pIdGMJYt0rs(IiPfUN(TGQdh8EQtRUgIXr5j6ijXilejhQyCeYGH8LmUk7KZgsXGqqW9gcmUk7KZUWEG619gcmx1OjNKOGung5lQtWwzQ)DiM9v(r5PAU0biHJGG7neyUQrtojrbPAmYxuNGTsD4Asm7R8JYt1CPdqchpccHgSOxoKJ2P1F8WPIs5FJslZfPFehanxtozKU3qauP6qhSVog0GbQoCWR7neyUQrtojrbPAmYxuNGTYu)7qSHC0oT(jUmiji4EdbMRA0KtsuqQgJ8f1jyRuhUMeBihTtRFIldsEGQ2FuJeg5Jg)oi(4a1lhHmyiFjJRYo5SHC0oT(H7fe8YridgYxYihyKpAKUOeJnKJ2P1pCpuXCVHa7yNydHjjhyKpACO8Lusd4oYe7cdLJoPuZNDeIP10JNkkL)nkTmxK(rCa02xh7DatGQdhe7uNwDneJp9NO)cd1lhDsPMplBWIEzqjbboczWq(sgxLDYzd5ODA9d3li4LJqgmKVKroWiF0iDrjgBihTtRF4EOI5Edb2XoXgctsoWiF04q5lPKgWDKj2fgkhDsPMp7ietRPhpvuk)BuAzUi9J4aOTVo27aMavho4LJqgmKVKXr5j6ijFrK0c3t)w2qoANw)HeuVN60QRHyCuEIossmYcrYfe4iKbd5lzCv2jNnKJ2P1Fi5Xdu1(JAKWiF04N4Iduo6KsnFw2Gf9YGsvuk)BuAzUi9J4aOT3m0dbkoeCdjFDatV9aEGQdhgkmKvK6AiOVoGPN9TdjFKeRj)WlsG6vHLCre)iuVN60QRHy8P)e9xybbVQ9h1iHr(OXFiJduXCVHaJRYo5SlShbboczWq(sgxLDYzdPyq4XtfLY)gLwMls)ioaAhekd9qGIdb3qYxhW0BpGhO6WHHcdzfPUgc6Rdy6zF7qYhjXAYp8Gmdsq9QWsUiIFeQ3tDA11qm(0FI(lSGGx1(JAKWiF04pKXbQyU3qGXvzNC2f2JGahHmyiFjJRYo5SHumi8avm3BiWo2j2qysYbg5JghkFjL0aUJmXUWEQOu(3O0YCr6hXbqBFYy0rgm6qGIdb3qYxhW0BpGhO6WHHcdzfPUgc6Rdy6zF7qYhjXAYp8IKigYr70c1Rcl5Ii(rOEp1PvxdX4t)j6VWccQ9h1iHr(OXFiJJGahHmyiFjJRYo5SHumi84PIs5FJslZfPFehaDanCsIcYu)7qGQdhuyjxeXpwrP8VrPL5I0pIdGoChiKOGKm3Kavho4L4Mg2sSoLAcHGaXnnSLywKrhzNs8eeiUPHTeZCtDKDkXZduVIXrNuQ5ZYgSOxgusqWRA)rnsyKpA8x8HeuVN60QRHy8P)e9xybb1(JAKWiF04pKXrq4uNwDneRTsfrEG69uNwDneJJYt0rsIrwisouX4iKbd5lzCuEIosYxejTW90VLDHfee7uNwDneJJYt0rsIrwisouX4iKbd5lzCv2jNDH94XduVCeYGH8LmUk7KZgYr706hKXrqqT)OgjmYhn(j(4aLJqgmKVKXvzNC2fgQxoczWq(sg5aJ8rJ0fLySHC0oT(R8VrjZ(6e6Hye(j(9j53oKGGyC0jLA(SJqmTMEee68Pbgz0NWKHgSOxoKJ2P1F8WXduVyONPyk83NK06thhjM6OGj2qoANw)exbbX4Otk18zjXhKbnyEQOu(3O0YCr6hXbqtoWiF0iDrjgO6WbVe30WwIzUPoYKW)liqCtdBjMfz0rMe(FbbIBAylX0eczs4)feCVHaZvnAYjjkivJr(I6eSvM6FhInKJ2P1pXLbjbb3BiWCvJMCsIcs1yKVOobBL6W1Kyd5ODA9tCzqsqqT)OgjmYhn(j(4aLJqgmKVKXvzNC2qkgeEG6LJqgmKVKXvzNC2qoANw)GmoccCeYGH8LmUk7KZgsXGWJGqNpnWiJ(eMm0Gf9YHC0oT(Jhovuk)BuAzUi9J4aO5KHSFRgPAAWPdLpO6WbVQ9h1iHr(OXpXhhOEDVHa7yNydHjjhyKpACO8Lusd4oYe7cliighDsPMp7ietRPhbbo6KsnFw2Gf9YGsccU3qG5AqimZ1(Slmu3BiWCnieM5AF2qoANw)JgNi8Yrj2TFg8q82ss10GthkF23oK8unxYJhOEp1PvxdX4O8eDKKyKfIKliWridgYxY4O8eDKKVisAH7PFlBifdcpccD(0aJm6tyYqdw0lhYr706F04eHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sEQOu(3O0YCr6hXbq3jxNu)gLGQdh8Q2FuJeg5Jg)eFCG619gcSJDIneMKCGr(OXHYxsjnG7itSlSGGyC0jLA(SJqmTMEee4Otk18zzdw0ldkji4EdbMRbHWmx7ZUWqDVHaZ1GqyMR9zd5ODA9hY4eHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8a17PoT6AighLNOJKeJSqKCbboczWq(sghLNOJK8frslCp9BzdPyq4rqOZNgyKrFctgAWIE5qoANw)Hmor4LJsSB)m4H4TLKQPbNou(SVDi5PAUKNkkL)nkTmxK(rCa0N60QRHavQo0b1cdcinXehuNQ5shiUPHTeRtP5M6eP4gXr5FJsM91j0dXi8t87tYVDOieJ4Mg2sSoLMBQtKgjIJY)gLmFJ(Iye(j(9j53oue4WIwCSWKXifP2NQOu(3O0YCr6hXbqBFDS3bmbQoCWBNpnWiJ(eMm0Gf9YHC0oT(lUccEDVHaB0tkrxRmmugziyd5ODA9hmhJ5O4ps5uB8Q2FuJeg5JgXbY44bQ7neyJEsj6ALHHYidb7c7XJGGx1(JAKWiF0eXPoT6AiMAHbbKMyIhPU3qGrCtdBjPfz0HnKJ2Pncm0Zc3bcjkijZnj238Jw5qoANrA0mi5hErJJGGA)rnsyKpAI4uNwDnetTWGastmXJu3BiWiUPHTK0CtDyd5ODAJad9SWDGqIcsYCtI9n)OvoKJ2zKgnds(Hx044bkXnnSLyDk1ecOE9kghHmyiFjJRYo5SlSGahDsPMp7ietRjuX4iKbd5lzKdmYhnsxuIXUWEee4Otk18zzdw0ldk5bQxX4Otk18zNu(IGyeeeZ9gcmUk7KZUWccQ9h1iHr(OXpXhhpccU3qGXvzNC2qoANw)WnqfZ9gcSrpPeDTYWqzKHGDHROu(3O0YCr6hXbqNKpPdcLGQdh86EdbgXnnSLKMBQd7cli4LlshWK9q0qhIlshWK8BhYFi5rqGlshWK9aK9avHLCre)yfLY)gLwMls)ioaArQjiDqOeuD4Gx3BiWiUPHTK0CtDyxybbVCr6aMShIg6qCr6aMKF7q(djpccCr6aMShGShOkSKlI4hROu(3O0YCr6hXbqhUgJ0bHsq1HdEDVHaJ4Mg2ssZn1HDHfe8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYEGQWsUiIFSIs5FJslZfPFehaTpDMgnsuqsMBsvuk)BuAzUi9J4aOTVoHEiq1Hde30WwI1P0CtDeeiUPHTeZIm6itc)VGaXnnSLyAcHmj8)ccU3qG5tNPrJefKK5Me7cd19gcmIBAyljn3uh2fwqWR7neyCv2jNnKJ2P1FL)nkz(g9fXi8t87tYVDiOU3qGXvzNC2f2tfLY)gLwMls)ioaAFJ(IQOu(3O0YCr6hXbqp3uQ8VrP002huP6qhcQX8IMBfvfLY)gLwg2qQJBNy0C4uNwDneOs1Hoy1ajFK8AjPfMmgqDQMlDWR7neyF7q(qtkXgsDC7eJg2qoANw)aZXyok(JahgEq9sCtdBjwNsx0lsqG4Mg2sSoLwKrhbbIBAylXm3uhzs4)9ii4Edb23oKp0KsSHuh3oXOHnKJ2P1pL)nkz2xNqpeJWpXVpj)2HIahgEq9sCtdBjwNsZn1rqG4Mg2smlYOJmj8)cce30WwIPjeYKW)7XJGGyU3qG9Td5dnPeBi1XTtmAyx4kkL)nkTmSHuh3oXOjIdG2(6yVdycuD4GxXo1PvxdXSAGKpsETK0ctgJGGx3BiWg9Ks01kddLrgc2qoANw)bZXyok(Juo1gVQ9h1iHr(OrCGmoEG6Edb2ONuIUwzyOmYqWUWE8iiO2FuJeg5Jg)eFCQOu(3O0YWgsDC7eJMioaAokprhj5lIKw4E63cQoCW7PoT6AighLNOJKeJSqKCOD(0aJm6tyYqdw0lhYr706hEqghOIXridgYxY4QStoBifdcbb3BiW4QSto7c7bQA)rnsyKpA8xCXbQx3BiWiUPHTK0CtDyd5ODA9dpCeeCVHaJ4Mg2sslYOdBihTtRF4HJhbHqdw0lhYr706pE4urP8VrPLHnK642jgnrCa0kMc)9jjT(0XbuCi4gs(6aME7b8avhoigg6zkMc)9jjT(0XrIPokyI9n)yNGHkMY)gLmftH)(KKwF64iXuhfmX6ugmnyrpuVIHHEMIPWFFssRpDCKIi1W(MFStWccyONPyk83NK06thhPisnSHC0oT(bjpccyONPyk83NK06thhjM6OGjM9v(r)Hmum0Zumf(7tsA9PJJetDuWeBihTtR)qgkg6zkMc)9jjT(0XrIPokyI9n)yNGROu(3O0YWgsDC7eJMioaAhekd9qGIdb3qYxhW0BpGhO6WHHcdzfPUgc6Rdy6zF7qYhjXAYp8IgQxVU3qGXvzNC2qoANw)GeuVU3qGn6jLORvggkJmeSHC0oT(bjbbXCVHaB0tkrxRmmugziyxypccI5EdbgxLDYzxybb1(JAKWiF04pKXXduVI5Edb2XoXgctsoWiF04q5lPKgWDKj2fwqqT)OgjmYhn(dzC8avHLCre)ONkkL)nkTmSHuh3oXOjIdG2EZqpeO4qWnK81bm92d4bQoCyOWqwrQRHG(6aME23oK8rsSM8dVOH61R7neyCv2jNnKJ2P1pib1R7neyJEsj6ALHHYidbBihTtRFqsqqm3BiWg9Ks01kddLrgc2f2JGGyU3qGXvzNC2fwqqT)OgjmYhn(dzC8a1RyU3qGDStSHWKKdmYhnou(skPbChzIDHfeu7pQrcJ8rJ)qghpqvyjxeXp6PIs5FJsldBi1XTtmAI4aOTpzm6idgDiqXHGBi5Rdy6ThWduD4WqHHSIuxdb91bm9SVDi5JKyn5hErcuVEDVHaJRYo5SHC0oT(bjOEDVHaB0tkrxRmmugziyd5ODA9dsccI5Edb2ONuIUwzyOmYqWUWEeeeZ9gcmUk7KZUWccQ9h1iHr(OXFiJJhOEfZ9gcSJDIneMKCGr(OXHYxsjnG7itSlSGGA)rnsyKpA8hY44bQcl5Ii(rpvuk)BuAzydPoUDIrtehaDanCsIcYu)7qGQdhuyjxeXpwrP8VrPLHnK642jgnrCa0JEsj6ALHHYidbO6Wb3BiW4QSto7cxrP8VrPLHnK642jgnrCa0KdmYhnsxuIbQoCWRx3BiWiUPHTK0Im6WgYr706hE4ii4EdbgXnnSLKMBQdBihTtRF4HJhOCeYGH8LmUk7KZgYr706hKXXJGahHmyiFjJRYo5SHumiQOu(3O0YWgsDC7eJMioaAozi73QrQMgC6q5dQoCWRx3BiWo2j2qysYbg5JghkFjL0aUJmXUWccIXrNuQ5ZocX0A6rqGJoPuZNLnyrVmOKGWPoT6AiwBLkIeeCVHaZ1GqyMR9zxyOU3qG5AqimZ1(SHC0oT(hnor4LJsSB)m4H4TLKQPbNou(SVDi5PAUKhpqfZ9gcmUk7KZUWq9kghDsPMplBWIEzqjbboczWq(sghLNOJK8frslCp9BzxybHoFAGrg9jmzObl6Ld5ODA9NJqgmKVKXr5j6ijFrK0c3t)w2qoAN2iIebHoFAGrg9jmzObl6Ld5ODAfhXbpCdo(hnor4LJsSB)m4H4TLKQPbNou(SVDi5PAUKhpvuk)BuAzydPoUDIrtehaDNCDs9BucQoCWRx3BiWo2j2qysYbg5JghkFjL0aUJmXUWccIXrNuQ5ZocX0A6rqGJoPuZNLnyrVmOKGWPoT6AiwBLkIeeCVHaZ1GqyMR9zxyOU3qG5AqimZ1(SHC0oT(dzCIWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEGkM7neyCv2jNDHH6vmo6KsnFw2Gf9YGsccCeYGH8Lmokprhj5lIKw4E63YUWccD(0aJm6tyYqdw0lhYr706phHmyiFjJJYt0rs(IiPfUN(TSHC0oTrejccD(0aJm6tyYqdw0lhYr70koIdE4gC8hY4eHxokXU9ZGhI3wsQMgC6q5Z(2HKNQ5sE8urP8VrPLHnK642jgnrCa0N60QRHavQo0bREsYaAKCv2jhuNQ5sh8kghHmyiFjJRYo5SHumieee7uNwDneJJYt0rsIrwisouo6KsnFw2Gf9YGsEQOu(3O0YWgsDC7eJMioa6WDGqIcsYCtcuD4aXnnSLyDk1ecOkSKlI4hH6fd9mftH)(KKwF64iXuhfmX(MFStWccIXrNuQ5ZsIpidAW8a9uNwDneZQNKmGgjxLDYROu(3O0YWgsDC7eJMioaA7RJ9oGjq1HdC0jLA(SSbl6LbLGEQtRUgIXr5j6ijXilejhQA)rnsyKpA87G4IduoczWq(sghLNOJK8frslCp9Bzd5ODA9hmhJ5O4ps5uB8Q2FuJeg5JgXbY44PIs5FJsldBi1XTtmAI4aOtYN0bHsq1HdEDVHaJ4Mg2ssZn1HDHfe8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYEGQWsUiIFe6PoT6AiMvpjzansUk7KxrP8VrPLHnK642jgnrCa0Iutq6GqjO6WbVU3qGrCtdBjP5M6WUWqfJJoPuZNDeIP1uqWR7neyh7eBimj5aJ8rJdLVKsAa3rMyxyOC0jLA(SJqmTMEee8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYccU3qGXvzNC2f2dufwYfr8Jqp1PvxdXS6jjdOrYvzN8kkL)nkTmSHuh3oXOjIdGoCngPdcLGQdh86EdbgXnnSLKMBQd7cdvmo6KsnF2riMwtbbVU3qGDStSHWKKdmYhnou(skPbChzIDHHYrNuQ5ZocX0A6rqWlxKoGj7HOHoexKoGj53oK)qYJGaxKoGj7bili4EdbgxLDYzxypqvyjxeXpc9uNwDneZQNKmGgjxLDYROu(3O0YWgsDC7eJMioaAF6mnAKOGKm3KQOu(3O0YWgsDC7eJMioaA7RtOhcuD4aXnnSLyDkn3uhbbIBAylXSiJoYKW)liqCtdBjMMqitc)VGG7ney(0zA0irbjzUjXUWqDVHaJ4Mg2ssZn1HDHfe86EdbgxLDYzd5ODA9x5FJsMVrFrmc)e)(K8BhcQ7neyCv2jNDH9urP8VrPLHnK642jgnrCa0(g9fvrP8VrPLHnK642jgnrCa0ZnLk)BuknT9bvQo0HGAmVO5wrvrP8VrPLfuJ5fn3d2xh7DatGQdheBUjfqdyI5Qgn5KefKQXiFrDc2Yiq0THHjSkkL)nkTSGAmVO5gXbqBVzOhcuCi4gs(6aME7b8avhoGHEMdcLHEi2qoANw)gYr70wrP8VrPLfuJ5fn3ioaAhekd9qvuvuk)BuAz2)GIPWFFssRpDCafhcUHKVoGP3Eapq1HdIHHEMIPWFFssRpDCKyQJcMyFZp2jyOIP8VrjtXu4VpjP1Noosm1rbtSoLbtdw0d1RyyONPyk83NK06thhPisnSV5h7eSGag6zkMc)9jjT(0XrkIudBihTtRFqYJGag6zkMc)9jjT(0XrIPokyIzFLF0Fidfd9mftH)(KKwF64iXuhfmXgYr706pKHIHEMIPWFFssRpDCKyQJcMyFZp2j4kkL)nkTm7hXbqZr5j6ijFrK0c3t)wq1HdEp1PvxdX4O8eDKKyKfIKdvmoczWq(sgxLDYzdPyqii4EdbgxLDYzxypqv7pQrcJ8rJ)Iloq96EdbgXnnSLKMBQdBihTtRF4HJGG7neye30WwsArgDyd5ODA9dpC8iieAWIE5qoANw)XdNkkL)nkTm7hXbqFQtRUgcuP6qhWqVCiq0ThYHY3cQt1CPdEDVHaJRYo5SHC0oT(bjOEDVHaB0tkrxRmmugziyd5ODA9dsccI5Edb2ONuIUwzyOmYqWUWEeeeZ9gcmUk7KZUWccQ9h1iHr(OXFiJJhOEfZ9gcSJDIneMKCGr(OXHYxsjnG7itSlSGGA)rnsyKpA8hY44bQx3BiWiUPHTK0Im6WgYr706hyogZrXVGG7neye30WwsAUPoSHC0oT(bMJXCu87PIs5FJslZ(rCa0oiug6HafhcUHKVoGP3Eapq1HddfgYksDne0xhW0Z(2HKpsI1KF4fnuVkSKlI4hHEQtRUgIHHE5qGOBpKdLV1tfLY)gLwM9J4aOT3m0dbkoeCdjFDatV9aEGQdhgkmKvK6AiOVoGPN9TdjFKeRj)WlAOEvyjxeXpc9uNwDnedd9YHar3EihkFRNkkL)nkTm7hXbqBFYy0rgm6qGIdb3qYxhW0BpGhO6WHHcdzfPUgc6Rdy6zF7qYhjXAYp8IeOEvyjxeXpc9uNwDnedd9YHar3EihkFRNkkL)nkTm7hXbqhqdNKOGm1)oeO6WbfwYfr8Jvuk)BuAz2pIdGE0tkrxRmmugziavho4EdbgxLDYzx4kkL)nkTm7hXbqtoWiF0iDrjgO6WbVEDVHaJ4Mg2sslYOdBihTtRF4HJGG7neye30WwsAUPoSHC0oT(HhoEGYridgYxY4QStoBihTtRFqghOEDVHadEAh0G1QrQdxZMlHVgRoSt1Cj)JwCXrqqS5MuanGjg80oObRvJuhUMnxcFnwDyei62WWeMhpccU3qGbpTdAWA1i1HRzZLWxJvh2PAUKFhIg3JJGahHmyiFjJRYo5SHumiG6vT)OgjmYhn(j(4iiCQtRUgI1wPIipvuk)BuAz2pIdGMtgY(TAKQPbNou(GQdh8Q2FuJeg5Jg)eFCG619gcSJDIneMKCGr(OXHYxsjnG7itSlSGGyC0jLA(SJqmTMEee4Otk18zzdw0ldkjiCQtRUgI1wPIibb3BiWCnieM5AF2fgQ7neyUgecZCTpBihTtR)rJteE9k(r6CtkGgWedEAh0G1QrQdxZMlHVgRomceDByycZteE5Oe72pdEiEBjPAAWPdLp7BhsEQMl5XJhOI5EdbgxLDYzxyOEfJJoPuZNLnyrVmOKGahHmyiFjJJYt0rs(IiPfUN(TSlSGqNpnWiJ(eMm0Gf9YHC0oT(ZridgYxY4O8eDKKVisAH7PFlBihTtBerIGqNpnWiJ(eMm0Gf9YHC0oTIJ4GhUbh)JgNi8Yrj2TFg8q82ss10GthkF23oK8unxYJNkkL)nkTm7hXbq3jxNu)gLGQdh8Q2FuJeg5Jg)eFCG619gcSJDIneMKCGr(OXHYxsjnG7itSlSGGyC0jLA(SJqmTMEee4Otk18zzdw0ldkjiCQtRUgI1wPIibb3BiWCnieM5AF2fgQ7neyUgecZCTpBihTtR)qgNi86v8J05MuanGjg80oObRvJuhUMnxcFnwDyei62WWeMNi8Yrj2TFg8q82ss10GthkF23oK8unxYJhpqfZ9gcmUk7KZUWq9kghDsPMplBWIEzqjbboczWq(sghLNOJK8frslCp9BzxybHoFAGrg9jmzObl6Ld5ODA9NJqgmKVKXr5j6ijFrK0c3t)w2qoAN2iIebHoFAGrg9jmzObl6Ld5ODAfhXbpCdo(dzCIWlhLy3(zWdXBljvtdoDO8zF7qYt1CjpEQOu(3O0YSFeha9PoT6AiqLQdDWQNKmGgjxLDYb1PAU0bVIXridgYxY4QStoBifdcbbXo1PvxdX4O8eDKKyKfIKdLJoPuZNLnyrVmOKNkkL)nkTm7hXbqhUdesuqsMBsGQdhiUPHTeRtPMqavHLCre)iu3BiWGN2bnyTAK6W1S5s4RXQd7unxY)OfxCG6fd9mftH)(KKwF64iXuhfmX(MFStWccIXrNuQ5ZsIpidAW8a9uNwDneZQNKmGgjxLDYROu(3O0YSFehaT91jOgdO6Wb3BiWqj9ISsyA4e83OKDHH6EdbM91jOgdBOWqwrQRHQOu(3O0YSFehanxtozKU3qauP6qhSVog0GbQoCW9gcm7RJbnySHC0oT(djOEDVHaJ4Mg2sslYOdBihTtRFqsqW9gcmIBAyljn3uh2qoANw)GKhOQ9h1iHr(OXpXhNkkL)nkTm7hXbqBFDS3bmbQoCGJoPuZNLnyrVmOe0tDA11qmokprhjjgzHi5q5iKbd5lzCuEIosYxejTW90VLnKJ2P1FivrP8VrPLz)ioaA7Rtqngq1HdVAO8z2NmgDKythEgLQRHWGk2RgkFM91XGgmgLQRHWG6EdbM91jOgdBOWqwrQRHG619gcmIBAyljn3uh2qoANw)IeOe30WwI1P0CtDG6Edbg80oObRvJuhUMnxcFnwDyNQ5s(hnKWrqW9gcm4PDqdwRgPoCnBUe(AS6WovZL87q0qchOQ9h1iHr(OXpXhhbbm0Zumf(7tsA9PJJetDuWeBihTtRF4gbbL)nkzkMc)9jjT(0XrIPokyI1PmyAWIEpqfJJqgmKVKXvzNC2qkgevuk)BuAz2pIdG2(6yVdycuD4G7neyOKErwj3q6ipBBJs2fwqW9gcSJDIneMKCGr(OXHYxsjnG7itSlSGG7neyCv2jNDHH619gcSrpPeDTYWqzKHGnKJ2P1FWCmMJI)iLtTXRA)rnsyKpAehiJJhOU3qGn6jLORvggkJmeSlSGGyU3qGn6jLORvggkJmeSlmuX4iKbd5lzJEsj6ALHHYidbBifdcbbX4Otk18zNu(IGy8iiO2FuJeg5Jg)eFCGsCtdBjwNsnHOIs5FJslZ(rCa02xh7DatGQdhE1q5ZSVog0GXOuDneguVU3qGzFDmObJDHfeu7pQrcJ8rJFIpoEG6EdbM91XGgmM9v(r)HmuVU3qGrCtdBjPfz0HDHfeCVHaJ4Mg2ssZn1HDH9a19gcm4PDqdwRgPoCnBUe(AS6WovZL8pACpoq9YridgYxY4QStoBihTtRF4HJGGyN60QRHyCuEIossmYcrYHYrNuQ5ZYgSOxguYtfLY)gLwM9J4aOTVo27aMavho419gcm4PDqdwRgPoCnBUe(AS6WovZL8pACpoccU3qGbpTdAWA1i1HRzZLWxJvh2PAUK)rdjCG(QHYNzFYy0rInD4zuQUgcZdu3BiWiUPHTK0Im6WgYr706hUhkXnnSLyDkTiJoqfZ9gcmusViReMgob)nkzxyOI9QHYNzFDmObJrP6AimOCeYGH8LmUk7KZgYr706hUhQxoczWq(sg5aJ8rJ0fLySHC0oT(H7feeJJoPuZNDeIP10tfLY)gLwM9J4aOtYN0bHsq1HdEDVHaJ4Mg2ssZn1HDHfe8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYEGQWsUiIFe6PoT6AiMvpjzansUk7KxrP8VrPLz)ioaArQjiDqOeuD4Gx3BiWiUPHTK0CtDyxyOIXrNuQ5ZocX0Aki419gcSJDIneMKCGr(OXHYxsjnG7itSlmuo6KsnF2riMwtpccE5I0bmzpen0H4I0bmj)2H8hsEee4I0bmzpazbb3BiW4QSto7c7bQcl5Ii(rON60QRHyw9KKb0i5QStEfLY)gLwM9J4aOdxJr6GqjO6WbVU3qGrCtdBjP5M6WUWqfJJoPuZNDeIP1uqWR7neyh7eBimj5aJ8rJdLVKsAa3rMyxyOC0jLA(SJqmTMEee8YfPdyYEiAOdXfPdys(Td5pK8iiWfPdyYEaYccU3qGXvzNC2f2dufwYfr8Jqp1PvxdXS6jjdOrYvzN8kkL)nkTm7hXbq7tNPrJefKK5MufLY)gLwM9J4aOTVoHEiq1Hde30WwI1P0CtDeeiUPHTeZIm6itc)VGaXnnSLyAcHmj8)ccU3qG5tNPrJefKK5Me7cd19gcmIBAyljn3uh2fwqWR7neyCv2jNnKJ2P1FL)nkz(g9fXi8t87tYVDiOU3qGXvzNC2f2tfLY)gLwM9J4aO9n6lQIs5FJslZ(rCa0ZnLk)BuknT9bvQo0HGAmVO5c8apaaa]] )


end