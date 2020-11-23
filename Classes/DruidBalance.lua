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
            max_stack = 1
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 5,
            max_stack = 1,
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
                applyBuff( "balance_of_all_things_arcane" )
                applyBuff( "balance_of_all_things_nature" )
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
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature" ) end
                eclipse.state = "IN_SOLAR"
                eclipse.reset_stacks()
                if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                return
            end

            if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                applyBuff( "eclipse_lunar" )                
                state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                if talent.solstice.enabled then applyBuff( "solstice" ) end
                if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature" ) end
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

                --[[ if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then
                        applyBuff( "eclipse_lunar" )
                        if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_arcane" ) end
                        if talent.solstice.enabled then applyBuff( "solstice" ) end
                    end
                end ]]

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

        potion = "unbridled_fury",

        package = "Balance",
    } )


    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = 1.5
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20201123, [[dC0cpdqiQk9ikKuxsfQ2eO8jqsOrrqNIcwLkuELamlvuUfiPSlu9lvKggq1XaPwMa1ZajMMaQRPIQTjG4BGKQXPcrNtaP1rHeZJQI7Pc2hfQdsHK0cbv1dPqQjcsIKlcsIuFeKeXjPqsSsbYmvHWovrmuqsGLcsI6PcAQGQ8vqsq7vL(lrdwPdtAXuLhJYKH4YiBwOpdIrtGtl51aLztLBtr7wQFd1WH0XbjPLR45uA6Q66a2oq(ovvJNcX5bvwVkKMpH2VOVqFH3nerF6EsWGhm4qdDWqHd95qdouc(g(WHs3quLbMcHUHTAs3q4RoTz0nevHZHvKl8UHwmWWOBOG)rTgLtpfs9ca84mS5P2YeWPFHB2OX)uBzYo9g6buU3OsF9UHi6t3tcg8GbhAOdgkCOphAWdoqUHkWlap3WWY0OVHckeeQVE3qeYYUHg15cF1PnJYfQudqHKbzuN7jyqKPhn5gmuol3GbpyWZGYGmQZ1OfOneYAuYGmQZfQLRrveecj3qStNCHpPM8miJ6CHA5A0c0gcHK7Rde6LvmxMAjBUpoxgCmhjFDGqVLNbzuNlulxOYKjgeHKlq3eJSwDGlxq6uQNJS5kS4e)SCrhcK0(6ybgiuUqnJZfDiqC7RJfyGqg43qxzF7fE3qKHutVQrO5cV7jqFH3nKA1Zrix4FdXO3ql93qL9fUVHG0PuphDdbPoa6gkmxpGyK)Lj5hpTezi10RAeA4dzQvBZ14CHWq4MQrYnGCbNdDUWYvyUeZvOwIxT0d)cYvumxI5kulXRwAXoDYvumxI5kulXDaToYMmYNRHCffZ1dig5Fzs(Xtlrgsn9QgHg(qMA12CnoxL9fU52xNyneNmcXaEs(LjLBa5coh6CHLRWCjMRqTeVAPdO1jxrXCjMRqTe3ID6iBYiFUII5smxHAjU2WjBYiFUgY1qUII56BUEaXi)ltYpEAjYqQPx1i0WbqVHG0r2QjDdTAKKpwcyjPfLCU7Fpj4l8UHuREoc5c)BiBQNMsVHcZ13CbPtPEoIB1ijFSeWsslk5C5kkMRWC9aIr(OGOgdyLXH6JchFitTABU(Klegc3unsUhlxgvUCfMRA)rDsuSFAY90CHc45Aixy56beJ8rbrngWkJd1hfooaAUgY1qUII5Q2FuNef7NMCno3af8BOY(c33q7RJfyGq3)EcuUW7gsT65iKl8VHSPEAk9gkmxq6uQNJ4mCdcdgjrilCnlxy5w9tdk2PpHiJfebVCitTABUgNl0qb8CHLRV5YWyhc2FZzQSAgFifbUCffZ1dig5mvwnJdGMRHCHLRA)rDsuSFAY1NCdm45clxH56beJCI5kuljDaTo8Hm1QT5ACUqdEUII56beJCI5kuljTyNo8Hm1QT5ACUqdEUgYvum3ybrWlhYuR2MRp5cn43qL9fUVHmCdcdgjFbK0Iwt927FpjWx4DdPw9CeYf(3qL9fUVHkII(fisA9RJ5nKn1ttP3qFZfb)Cfrr)cejT(1XuIOMkeI)fdSQHKlSC9nxL9fU5kII(fisA9RJPernvieVAz0vqe85clxH56BUi4NRik6xGiP1VoMsbK64FXaRAi5kkMlc(5kII(fisA9RJPuaPo(qMA12Cno3ZZ1qUII5IGFUIOOFbIKw)6ykrutfcXTVYalxFYfk5clxe8Zvef9lqK06xhtjIAQqi(qMA12C9jxOKlSCrWpxru0VarsRFDmLiQPcH4FXaRAi3qgCmhjFDGqV9Ec03)EY5x4DdPw9CeYf(3qL9fUVHMyChRHUHSPEAk9gouCiRa1Zr5cl3xhi0Z)YKKpwIuuUgNl0bNlSCfMRWC9aIrotLvZ4dzQvBZ14Cppxy5kmxpGyKpkiQXawzCO(OWXhYuR2MRX5EEUII56BUEaXiFuquJbSY4q9rHJdGMRHCffZ13C9aIrotLvZ4aO5kkMRA)rDsuSFAY1NCHc45Aixy5kmxFZ1dig5GvnYqisYef7NgtQFj10aPokXbqZvumx1(J6KOy)0KRp5cfWZ1qUWYvrLmbedSCnCdzWXCK81bc927jqF)7jbYfE3qQvphHCH)nuzFH7BOfOJ1q3q2upnLEdhkoKvG65OCHL7Rde65FzsYhlrkkxJZf6GZfwUcZvyUEaXiNPYQz8Hm1QT5ACUNNlSCfMRhqmYhfe1yaRmouFu44dzQvBZ14CppxrXC9nxpGyKpkiQXawzCO(OWXbqZ1qUII56BUEaXiNPYQzCa0CffZvT)Oojk2pn56tUqb8CnKlSCfMRV56beJCWQgziejzII9tJj1VKAAGuhL4aO5kkMRA)rDsuSFAY1NCHc45Aixy5QOsMaIbwUgUHm4yos(6aHE79eOV)9eO(fE3qQvphHCH)nuzFH7BO9jNthz0PdDdzt90u6nCO4qwbQNJYfwUVoqON)LjjFSePOCnoxOdKCHLRWCfMRhqmYzQSAgFitTABUgN755clxH56beJ8rbrngWkJd1hfo(qMA12Cno3ZZvumxFZ1dig5JcIAmGvghQpkCCa0CnKROyU(MRhqmYzQSAghanxrXCv7pQtII9ttU(Kluapxd5clxH56BUEaXihSQrgcrsMOy)0ys9lPMgi1rjoaAUII5Q2FuNef7NMC9jxOaEUgYfwUkQKjGyGLRHBidoMJKVoqO3Epb67Fp5iVW7gsT65iKl8VHSPEAk9gQOsMaIb2nuzFH7ByepmsIJYwFGHU)9Ka9cVBi1QNJqUW)gYM6PP0BOhqmYzQSAgha9gQSVW9nCuquJbSY4q9rH7(3tGg8l8UHuREoc5c)BiBQNMsVHcZvyUEaXiNyUc1ssl2PdFitTABUgNl0GNROyUEaXiNyUc1sshqRdFitTABUgNl0GNRHCHLldJDiy)nNPYQz8Hm1QT5ACUqb8CnKROyUmm2HG93CMkRMXhsrG7gQSVW9neSQrgcrArRPE79VNan0x4DdPw9CeYf(3q2upnLEdfMRWC9aIroyvJmeIKmrX(PXK6xsnnqQJsCa0CffZ13CzyquR9ZbdUP0oxd5kkMlddIATFExqe8YOs5kkMliDk1Zr8YkvmLROyUEaXi3ZHXioa7ZbqZfwUEaXi3ZHXioa7ZhYuR2MRp5gm45gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgYfwU(MRhqmYzQSAghanxy5kmxFZLHbrT2pVlicEzuPCffZLHXoeS)MZWnimyK8fqslAn1B5aO5kkMB1pnOyN(eImwqe8YHm1QT56tUmm2HG93CgUbHbJKVasArRPElFitTABUbKBGKROyUv)0GID6tiYybrWlhYuR2M7XZf6Je8C9j3Gbp3aYvyUbo3JLld3ia1ZrhIvwsQUcsBs9ZPw9CesUgY1WnuzFH7BiJCK9l1jvxbPnP(V)9eOd(cVBi1QNJqUW)gYM6PP0BOWCfMRhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGMROyU(MlddIATFoyWnL25AixrXCzyquR9Z7cIGxgvkxrXCbPtPEoIxwPIPCffZ1dig5EomgXbyFoaAUWY1dig5EomgXbyF(qMA12C9jxOaEUbKRWCdCUhlxgUraQNJoeRSKuDfK2K6NtT65iKCnKRHCHLRV56beJCMkRMXbqZfwUcZ13CzyquR9Z7cIGxgvkxrXCzySdb7V5mCdcdgjFbK0Iwt9woaAUII5w9tdk2PpHiJfebVCitTABU(KldJDiy)nNHBqyWi5lGKw0AQ3YhYuR2MBa5gi5kkMB1pnOyN(eImwqe8YHm1QT5E8CH(ibpxFYfkGNBa5km3aN7XYLHBeG65OdXkljvxbPnP(5uREocjxd5A4gQSVW9nSAMoT(fUV)9eOHYfE3qQvphHCH)neJEdT0Fdv2x4(gcsNs9C0neK6aOBOWC9nxgg7qW(BotLvZ4dPiWLROyU(MliDk1ZrCgUbHbJKiKfUMLlSCzyquR9Z7cIGxgvkxd3qq6iB1KUHwfejJ4rYuz1S7Fpb6aFH3nKA1Zrix4Fdzt90u6nKyUc1s8QLAdxUWYvrLmbedSCHLRWCrWpxru0VarsRFDmLiQPcH4FXaRAi5kkMRV5YWGOw7N3eBWo8GKRHCHLliDk1ZrCRcIKr8izQSA2nuzFH7ByeyGtIJsYb009VNa95x4DdPw9CeYf(3q2upnLEdzyquR9Z7cIGxgvkxy5csNs9CeNHBqyWijczHRz5clx1(J6KOy)0KRXhYnWGNlSCzySdb7V5mCdcdgjFbK0Iwt9w(qMA12C9jximeUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1WnuzFH7BO91XcmqO7Fpb6a5cVBi1QNJqUW)gYM6PP0BOWC9aIroXCfQLKoGwhoaAUII5kmxMaDGq2CpKBW5cl3Hyc0bcj)YKY1NCppxd5kkMltGoqiBUhYfk5Aixy5QOsMaIbwUWYfKoL65iUvbrYiEKmvwn7gQSVW9nSj)stmUV)9eOH6x4DdPw9CeYf(3q2upnLEdfMRhqmYjMRqTK0b06WbqZfwU(MlddIATFoyWnL25kkMRWC9aIroyvJmeIKmrX(PXK6xsnnqQJsCa0CHLlddIATFoyWnL25AixrXCfMltGoqiBUhYn4CHL7qmb6aHKFzs56tUNNRHCffZLjqhiKn3d5cLCffZ1dig5mvwnJdGMRHCHLRIkzcigy5clxq6uQNJ4wfejJ4rYuz1SBOY(c33qbQlknX4((3tG(iVW7gsT65iKl8VHSPEAk9gkmxpGyKtmxHAjPdO1HdGMlSC9nxgge1A)CWGBkTZvumxH56beJCWQgziejzII9tJj1VKAAGuhL4aO5clxgge1A)CWGBkTZ1qUII5kmxMaDGq2CpKBW5cl3Hyc0bcj)YKY1NCppxd5kkMltGoqiBUhYfk5kkMRhqmYzQSAghanxd5clxfvYeqmWYfwUG0PuphXTkisgXJKPYQz3qL9fUVHraNtAIX99VNaDGEH3nuzFH7BOFDMcpsCusoGMUHuREoc5c)7FpjyWVW7gsT65iKl8VHSPEAk9gsmxHAjE1shqRtUII5smxHAjUf70r2Kr(CffZLyUc1sCTHt2Kr(CffZ1dig5(1zk8iXrj5aAIdGMlSC9aIroXCfQLKoGwhoaAUII5kmxpGyKZuz1m(qMA12C9jxL9fU5(h9fWjJqmGNKFzs5clxpGyKZuz1moaAUgUHk7lCFdTVoXAO7FpjyOVW7gQSVW9n0)OVGBi1QNJqUW)(3tco4l8UHuREoc5c)BOY(c33WbOLk7lClDL9VHUY(YwnPByuDUxWaC)7FdrOOc4(l8UNa9fE3qL9fUVHwSthPhPM3qQvphHCH)9VNe8fE3qQvphHCH)neJEdT0Fdv2x4(gcsNs9C0neK6aOBOfLCo5Rde6TC7RtuDUCnoxOZfwUcZ13CF1r9ZTVoo8GWPw9CesUII5(QJ6NBFY50rImv85uREocjxd5kkMRfLCo5Rde6TC7RtuDUCno3GVHG0r2QjDdlRuX09VNaLl8UHuREoc5c)Big9gAP)gQSVW9neKoL65OBii1bq3qlk5CYxhi0B52xNynuUgNl03qq6iB1KUHLvYCKcIU)9KaFH3nKA1Zrix4Fdzt90u6nuyU(MlddIATFExqe8YOs5kkMRV5YWyhc2FZz4gegms(ciPfTM6TCa0CnKlSC9aIrotLvZ4aO3qL9fUVHE0yPbSQHC)7jNFH3nKA1Zrix4Fdzt90u6n0dig5mvwnJdGEdv2x4(gII)c33)EsGCH3nuzFH7BiGLK1tM2Bi1QNJqUW)(3tG6x4DdPw9CeYf(3q2upnLEdDeiYLRp5Eo03qL9fUVHciDEjzTuZO7Fp5iVW7gsT65iKl8VHSPEAk9gcsNs9CeVSsft3q7pf7VNa9nuzFH7B4a0sL9fULUY(3qxzFzRM0nuX09VNeOx4DdPw9CeYf(3q2upnLEdhGMI4bcX)YK8JNwImKA6vncnCcQcuOOeYn0(tX(7jqFdv2x4(goaTuzFHBPRS)n0v2x2QjDdrgsn9QgHM7FpbAWVW7gsT65iKl8VHSPEAk9goanfXdeI7PoTzKehLQZjFbvdXYjOkqHIsi3q7pf7VNa9nuzFH7B4a0sL9fULUY(3qxzFzRM0n0dR)9VNan0x4DdPw9CeYf(3qL9fUVHdqlv2x4w6k7FdDL9LTAs3q7F)7Fd9W6FH39eOVW7gsT65iKl8VHSPEAk9g6beJCMkRMXbqVHk7lCFdhfe1yaRmouFu4U)9KGVW7gsT65iKl8VHy0BOL(BOY(c33qq6uQNJUHGuhaDdJomEYvyUcZT6NguStFcrglicE5qMA12CHA5gm45Ai3tZf6Gbpxd5ACUrhgp5kmxH5w9tdk2PpHiJfebVCitTABUqTCd(8CHA5kmxObp3JL7RoQFE1mDA9lCZPw9CesUgYfQLRWCdCUhlxgUraQNJoeRSKuDfK2K6NtT65iKCnKRHCpnxOpsWZ1WneKoYwnPBid3GWGrseYcxZU)9eOCH3nKA1Zrix4FdXO3ql93qL9fUVHG0PuphDdbPoa6g6BUEaXi3tDAZijokvNt(cQgIv26dmehanxy56BUEaXi3tDAZijokvNt(cQgIvQdtBIdGEdbPJSvt6gYM6B8dGE)7jb(cVBi1QNJqUW)gQSVW9nuru0VarsRFDmVHSPEAk9g6beJCp1PnJK4OuDo5lOAiwzRpWqC7RmWKGuhaLRp5gyWZfwUEaXi3tDAZijokvNt(cQgIvQdtBIBFLbMeK6aOC9j3adEUWYvyU(Mlc(5kII(fisA9RJPernvie)lgyvdjxy56BUk7lCZvef9lqK06xhtjIAQqiE1YORGi4ZfwUcZ13CrWpxru0VarsRFDmLci1X)Ibw1qYvumxe8Zvef9lqK06xhtPasD8Hm1QT5ACUqjxd5kkMlc(5kII(fisA9RJPernvie3(kdSC9jxOKlSCrWpxru0VarsRFDmLiQPcH4dzQvBZ1NCppxy5IGFUIOOFbIKw)6ykrutfcX)Ibw1qY1WnKbhZrYxhi0BVNa99VNC(fE3qQvphHCH)nKn1ttP3qH5csNs9CeNHBqyWijczHRz5cl3QFAqXo9jezSGi4LdzQvBZ14CHgkGNlSC9nxgg7qW(BotLvZ4dPiWLROyUEaXiNPYQzCa0CnKlSCfMRhqmY9uN2msIJs15KVGQHyLT(adXTVYatcsDauUhY9CWZvumxpGyK7PoTzKehLQZjFbvdXk1HPnXTVYatcsDauUhY9CWZ1qUII5glicE5qMA12C9jxOb)gQSVW9nKHBqyWi5lGKw0AQ3E)7jbYfE3qQvphHCH)nKn1ttP3qH56beJCp1PnJK4OuDo5lOAiwzRpWq8Hm1QT5ACUbMFEUII56beJCp1PnJK4OuDo5lOAiwPomTj(qMA12Cno3aZppxd5clx1(J6KOy)0KRXhYnqbpxy5kmxgg7qW(BotLvZ4dzQvBZ14CH65kkMRWCzySdb7V5Kjk2pnspCJWhYuR2MRX5c1ZfwU(MRhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGMlSCzyquR9ZbdUP0oxd5A4gQSVW9nKPnJCspGy8g6beJYwnPBO91XHhK7FpbQFH3nKA1Zrix4Fdzt90u6n03CbPtPEoIZM6B8dGMlSCfMlddIATFExqe8YOs5kkMldJDiy)nNPYQz8Hm1QT5ACUq9CffZvyUmm2HG93CYef7NgPhUr4dzQvBZ14CH65clxFZ1dig5GvnYqisYef7NgtQFj10aPokXbqZfwUmmiQ1(5Gb3uANRHCnCdv2x4(gAFDSade6(3toYl8UHuREoc5c)BiBQNMsVHcZLHXoeS)MZWnimyK8fqslAn1B5aO5clxH5csNs9CeNHBqyWijczHRz5kkMldJDiy)nNPYQz8Hm1QT56tUNNRHCnKlSCv7pQtII9ttUgN75GNlSCzyquR9Z7cIGxgv6gQSVW9n0(6ybgi09VNeOx4DdPw9CeYf(3qL9fUVHwGowdDdzt90u6nCO4qwbQNJYfwUVoqON)LjjFSePOCnoxOdKCHLRWCvujtaXalxy5kmxq6uQNJ4SP(g)aO5kkMRWCv7pQtII9ttU(Kluapxy56BUEaXiNPYQzCa0CnKROyUmm2HG93CMkRMXhsrGlxd5A4gYGJ5i5Rde6T3tG((3tGg8l8UHuREoc5c)BOY(c33qtmUJ1q3q2upnLEdhkoKvG65OCHL7Rde65FzsYhlrkkxJZfAOWppxy5kmxfvYeqmWYfwUcZfKoL65ioBQVXpaAUII5kmx1(J6KOy)0KRp5cfWZfwU(MRhqmYzQSAghanxd5kkMldJDiy)nNPYQz8Hue4Y1qUWY13C9aIroyvJmeIKmrX(PXK6xsnnqQJsCa0CnCdzWXCK81bc927jqF)7jqd9fE3qQvphHCH)nuzFH7BO9jNthz0PdDdzt90u6nCO4qwbQNJYfwUVoqON)LjjFSePOCnoxOdKCdi3Hm1QT5clxH5QOsMaIbwUWYvyUG0PuphXzt9n(bqZvumx1(J6KOy)0KRp5cfWZvumxgg7qW(BotLvZ4dPiWLRHCnCdzWXCK81bc927jqF)7jqh8fE3qQvphHCH)nKn1ttP3qfvYeqmWUHk7lCFdJ4HrsCu26dm09VNanuUW7gsT65iKl8VHSPEAk9gkmxI5kulXRwQnC5kkMlXCfQL4wSthz1sOZvumxI5kulXDaToYQLqNRHCHLRWC9nxgge1A)8UGi4LrLYvumxH5Q2FuNef7NMC9j3a98CHLRWCbPtPEoIZM6B8dGMROyUQ9h1jrX(PjxFYfkGNROyUG0PuphXlRuXuUgYfwUcZfKoL65iod3GWGrseYcxZYfwU(MldJDiy)nNHBqyWi5lGKw0AQ3YbqZvumxFZfKoL65iod3GWGrseYcxZYfwU(MldJDiy)nNPYQzCa0CnKRHCnKlSCfMldJDiy)nNPYQz8Hm1QT5ACUqb8CffZvT)Oojk2pn5ACUbk45clxgg7qW(BotLvZ4aO5clxH5YWyhc2FZjtuSFAKE4gHpKPwTnxFYvzFHBU91jwdXjJqmGNKFzs5kkMRV5YWGOw7NdgCtPDUgYvum3QFAqXo9jezSGi4LdzQvBZ1NCHg8CnKlSCfMlc(5kII(fisA9RJPernvieFitTABUgNBGZvumxFZLHbrT2pVj2GD4bjxd3qL9fUVHrGbojokjhqt3)Ec0b(cVBi1QNJqUW)gYM6PP0BOWCjMRqTe3b06iBYiFUII5smxHAjUf70r2Kr(CffZLyUc1sCTHt2Kr(CffZ1dig5EQtBgjXrP6CYxq1qSYwFGH4dzQvBZ14Cdm)8CffZ1dig5EQtBgjXrP6CYxq1qSsDyAt8Hm1QT5ACUbMFEUII5Q2FuNef7NMCno3af8CHLldJDiy)nNPYQz8Hue4Y1qUWYvyUmm2HG93CMkRMXhYuR2MRX5cfWZvumxgg7qW(BotLvZ4dPiWLRHCffZT6NguStFcrglicE5qMA12C9jxOb)gQSVW9neSQrgcrArRPE79VNa95x4DdPw9CeYf(3q2upnLEdfMRA)rDsuSFAY14CduWZfwUcZ1dig5GvnYqisYef7NgtQFj10aPokXbqZvumxFZLHbrT2phm4Ms7CnKROyUmmiQ1(5DbrWlJkLROyUEaXi3ZHXioa7ZbqZfwUEaXi3ZHXioa7ZhYuR2MRp5gm45gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgYfwUcZ13CzyquR9Z7cIGxgvkxrXCzySdb7V5mCdcdgjFbK0Iwt9woaAUII5w9tdk2PpHiJfebVCitTABU(KldJDiy)nNHBqyWi5lGKw0AQ3YhYuR2MBa5gi5kkMB1pnOyN(eImwqe8YHm1QT5E8CH(ibpxFYnyWZnGCfMBGZ9y5YWncq9C0HyLLKQRG0Mu)CQvphHKRHCnCdv2x4(gYihz)sDs1vqAtQ)7Fpb6a5cVBi1QNJqUW)gYM6PP0BOWCv7pQtII9ttUgNBGcEUWYvyUEaXihSQrgcrsMOy)0ys9lPMgi1rjoaAUII56BUmmiQ1(5Gb3uANRHCffZLHbrT2pVlicEzuPCffZ1dig5EomgXbyFoaAUWY1dig5EomgXbyF(qMA12C9jxOaEUbKRWCdCUhlxgUraQNJoeRSKuDfK2K6NtT65iKCnKRHCHLRWC9nxgge1A)8UGi4LrLYvumxgg7qW(Bod3GWGrYxajTO1uVLdGMROyUG0PuphXz4gegmsIqw4AwUWYT6NguStFcrglicE5qMA12CnoxOpsWZnGCdg8CdixH5g4CpwUmCJauphDiwzjP6kiTj1pNA1Zri5AixrXCR(Pbf70NqKXcIGxoKPwTnxFYLHXoeS)MZWnimyK8fqslAn1B5dzQvBZnGCdKCffZT6NguStFcrglicE5qMA12C9jxOaEUbKRWCdCUhlxgUraQNJoeRSKuDfK2K6NtT65iKCnKRHBOY(c33WQz606x4((3tGgQFH3nKA1Zrix4Fdzt90u6nKHbrT2pVlicEzuPCHLRWCbPtPEoIZWnimyKeHSW1SCffZLHXoeS)MZuz1m(qMA12C9jxObpxd5clx1(J6KOy)0KRX5Eo45clxgg7qW(Bod3GWGrYxajTO1uVLpKPwTnxFYfAWVHk7lCFdTVowGbcD)7jqFKx4DdPw9CeYf(3qm6n0s)nuzFH7BiiDk1Zr3qqQdGUHeZvOwIxT0b06K7XY9iZ90Cv2x4MBFDI1qCYied4j5xMuUbKRV5smxHAjE1shqRtUhl3aj3tZvzFHBU)rFbCYied4j5xMuUbKl48GZ90CTOKZjfO2NUHG0r2QjDdvlkub0esS7Fpb6a9cVBi1QNJqUW)gYM6PP0BOWCR(Pbf70NqKXcIGxoKPwTnxFYnW5kkMRWC9aIr(OGOgdyLXH6JchFitTABU(Klegc3unsUhlxgvUCfMRA)rDsuSFAY90CHc45Aixy56beJ8rbrngWkJd1hfooaAUgY1qUII5kmx1(J6KOy)0KBa5csNs9CexTOqfqtiXY9y56beJCI5kuljTyNo8Hm1QT5gqUi4Nhbg4K4OKCanX)IbMvoKPwDUhl3G5NNRX5cDWGNROyUQ9h1jrX(Pj3aYfKoL65iUArHkGMqIL7XY1dig5eZvOws6aAD4dzQvBZnGCrWppcmWjXrj5aAI)fdmRCitT6CpwUbZppxJZf6Gbpxd5clxI5kulXRwQnC5clxH5kmxFZLHXoeS)MZuz1moaAUII5YWGOw7NdgCtPDUWY13CzySdb7V5Kjk2pnspCJWbqZ1qUII5YWGOw7N3febVmQuUgYfwUcZ13CzyquR9Zbr9laUjxrXC9nxpGyKZuz1moaAUII5Q2FuNef7NMCno3af8CnKROyUEaXiNPYQz8Hm1QT5ACUhzUWY13C9aIr(OGOgdyLXH6Jchha9gQSVW9n0(6ybgi09VNem4x4DdPw9CeYf(3q2upnLEdfMRhqmYjMRqTK0b06WbqZvumxH5YeOdeYM7HCdoxy5oetGoqi5xMuU(K755AixrXCzc0bczZ9qUqjxd5clxfvYeqmWUHk7lCFdBYV0eJ77FpjyOVW7gsT65iKl8VHSPEAk9gkmxpGyKtmxHAjPdO1HdGMROyUcZLjqhiKn3d5gCUWYDiMaDGqYVmPC9j3ZZ1qUII5YeOdeYM7HCHsUgYfwUkQKjGyGDdv2x4(gkqDrPjg33)EsWbFH3nKA1Zrix4Fdzt90u6nuyUEaXiNyUc1sshqRdhanxrXCfMltGoqiBUhYn4CHL7qmb6aHKFzs56tUNNRHCffZLjqhiKn3d5cLCnKlSCvujtaXa7gQSVW9nmc4CstmUV)9KGHYfE3qL9fUVH(1zk8iXrj5aA6gsT65iKl8V)9KGd8fE3qQvphHCH)nKn1ttP3qI5kulXRw6aADYvumxI5kulXTyNoYMmYNROyUeZvOwIRnCYMmYNROyUEaXi3VotHhjokjhqtCa0CHLlXCfQL4vlDaTo5kkMRWC9aIrotLvZ4dzQvBZ1NCv2x4M7F0xaNmcXaEs(LjLlSC9aIrotLvZ4aO5A4gQSVW9n0(6eRHU)9KGp)cVBOY(c33q)J(cUHuREoc5c)7Fpj4a5cVBi1QNJqUW)gQSVW9nCaAPY(c3sxz)BORSVSvt6ggvN7fma3)(3qftx4Dpb6l8UHuREoc5c)Big9gAP)gQSVW9neKoL65OBii1bq3qH56beJ8Vmj)4PLidPMEvJqdFitTABU(Klegc3unsUbKl4COZvumxpGyK)Lj5hpTezi10RAeA4dzQvBZ1NCv2x4MBFDI1qCYied4j5xMuUbKl4COZfwUcZLyUc1s8QLoGwNCffZLyUc1sCl2PJSjJ85kkMlXCfQL4AdNSjJ85Aixd5clxpGyK)Lj5hpTezi10RAeA4aO5cl3bOPiEGq8Vmj)4PLidPMEvJqdNGQafkkHCdbPJSvt6gImKAk9xoNmQoNehJ3)EsWx4DdPw9CeYf(3q2upnLEd9aIrU91jQohFO4qwbQNJYfwUcZ1IsoN81bc9wU91jQoxU(KluYvumxFZDaAkIhie)ltYpEAjYqQPx1i0WjOkqHIsi5Aixy5kmxFZDaAkIhie3bhth1kJoI(QHiH4ktulXjOkqHIsi5kkM7xMuUhp3aFEUgNRhqmYTVor154dzQvBZnGCdoxd3qL9fUVH2xNO6C3)EcuUW7gsT65iKl8VHSPEAk9goanfXdeI)Lj5hpTezi10RAeA4eufOqrjKCHLRfLCo5Rde6TC7RtuDUCn(qUqjxy5kmxFZ1dig5Fzs(Xtlrgsn9QgHgoaAUWY1dig52xNO6C8HIdzfOEokxrXCfMliDk1ZrCKHutP)Y5Kr15K4ymxy5kmxpGyKBFDIQZXhYuR2MRp5cLCffZ1IsoN81bc9wU91jQoxUgNBW5cl3xDu)C7toNosKPIpNA1Zri5clxpGyKBFDIQZXhYuR2MRp5EEUgY1qUgUHk7lCFdTVor15U)9KaFH3nKA1Zrix4FdXO3ql93qL9fUVHG0PuphDdbPoa6gQ2FuNef7NMCno3Je8CHA5kmxObp3JLRhqmY)YK8JNwImKA6vncnC7RmWY1qUqTCfMRhqmYTVor154dzQvBZ9y5cLCpnxlk5CsbQ9PCnKlulxH5IGFEeyGtIJsYb0eFitTABUhl3ZZ1qUWY1dig52xNO6CCa0BiiDKTAs3q7RtuDoPFC)YO6CsCmE)7jNFH3nKA1Zrix4Fdzt90u6neKoL65ioYqQP0F5CYO6CsCmMlSCbPtPEoIBFDIQZj9J7xgvNtIJXBOY(c33q7RJfyGq3)EsGCH3nKA1Zrix4Fdv2x4(gAb6yn0nKn1ttP3WHIdzfOEokxy5(6aHE(xMK8XsKIY14CHoW5c1Y1IsoN81bc92Cdi3Hm1QT5clxfvYeqmWYfwUeZvOwIxTuB4UHm4yos(6aHE79eOV)9eO(fE3qQvphHCH)nuzFH7BOIOOFbIKw)6yEdzt90u6n03C)Ibw1qYfwU(MRY(c3Cfrr)cejT(1XuIOMkeIxTm6kic(CffZfb)Cfrr)cejT(1XuIOMkeIBFLbwU(KluYfwUi4NRik6xGiP1VoMse1uHq8Hm1QT56tUq5gYGJ5i5Rde6T3tG((3toYl8UHuREoc5c)BOY(c33qtmUJ1q3q2upnLEdhkoKvG65OCHL7Rde65FzsYhlrkkxJZvyUqh4CdixH5ArjNt(6aHEl3(6eRHY9y5cn)8CnKRHCpnxlk5CYxhi0BZnGChYuR2MlSCfMRWCzySdb7V5mvwnJpKIaxUII5ArjNt(6aHEl3(6eRHY1NCHsUII5kmxI5kulXRwAXoDYvumxI5kulXRw6HFb5kkMlXCfQL4vlDaTo5clxFZ9vh1p3IbCsCu(cizepK95uREocjxrXC9aIro6uM4bPuNuhM2ftIc4S6WbPoakxJpKBWNdEUgYfwUcZ1IsoN81bc9wU91jwdLRp5cn45ESCfMl05gqUV6O(5V)QLMyCB5uREocjxd5Aixy5Q2FuNef7NMCno3ZbpxOwUEaXi3(6evNJpKPwTn3JLBGKRHCHLRV56beJCWQgziejzII9tJj1VKAAGuhL4aO5clxfvYeqmWY1WnKbhZrYxhi0BVNa99VNeOx4DdPw9CeYf(3q2upnLEdfMliDk1ZrCgUbHbJKiKfUMLlSCR(Pbf70NqKXcIGxoKPwTnxJZfAOaEUWY13CzySdb7V5mvwnJpKIaxUII56beJCMkRMXbqZ1qUWYvT)Oojk2pn56tUNdEUWYvyUEaXiNyUc1sshqRdFitTABUgNBGKROyUEaXiNyUc1ssl2PdFitTABUgNBGZ1qUII5glicE5qMA12C9jxOb)gQSVW9nKHBqyWi5lGKw0AQ3E)7jqd(fE3qQvphHCH)nKn1ttP3qfvYeqmWUHk7lCFdJ4HrsCu26dm09VNan0x4DdPw9CeYf(3q2upnLEd9aIrotLvZ4aO3qL9fUVHJcIAmGvghQpkC3)Ec0bFH3nKA1Zrix4Fdzt90u6nuyUEaXi3(6evNJdGMROyUQ9h1jrX(PjxJZ9CWZ1qUWY13C9aIrUf7SFXioaAUWY13C9aIrotLvZ4aO5clxH56BUmmiQ1(5DbrWlJkLROyUmm2HG93CgUbHbJKVasArRPElhanxrXCR(Pbf70NqKXcIGxoKPwTnxFYLHXoeS)MZWnimyK8fqslAn1B5dzQvBZnGCdKCffZT6NguStFcrglicE5qMA12CpEUqFKGNRp5gm45gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgUHk7lCFdzKJSFPoP6kiTj1)9VNanuUW7gsT65iKl8VHSPEAk9gkmxpGyKBFDIQZXbqZvumx1(J6KOy)0KRX5Eo45Aixy56BUEaXi3ID2Vyehanxy56BUEaXiNPYQzCa0CHLRWC9nxgge1A)8UGi4LrLYvumxgg7qW(Bod3GWGrYxajTO1uVLdGMROyUv)0GID6tiYybrWlhYuR2MRp5YWyhc2FZz4gegms(ciPfTM6T8Hm1QT5gqUbsUII5w9tdk2PpHiJfebVCitTABUhpxOpsWZ1NCHc45gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgUHk7lCFdRMPtRFH77Fpb6aFH3nKA1Zrix4Fdzt90u6nS6NguStFcrglicE5qMA12C9jxOppxrXCfMRhqmYrNYepiL6K6W0UysuaNvhoi1bq56tUbFo45kkMRhqmYrNYepiL6K6W0UysuaNvhoi1bq5A8HCd(CWZ1qUWY1dig52xNO6CCa0CHLldJDiy)nNPYQz8Hm1QT5ACUNd(nuzFH7BiyvJmeI0Iwt927Fpb6ZVW7gsT65iKl8VHk7lCFdTp5C6iJoDOBiBQNMsVHdfhYkq9CuUWY9lts(yjsr5ACUqFEUWY1IsoN81bc9wU91jwdLRp5g4CHLRIkzcigy5clxH56beJCMkRMXhYuR2MRX5cn45kkMRV56beJCMkRMXbqZ1WnKbhZrYxhi0BVNa99VNaDGCH3nKA1Zrix4Fdzt90u6nKyUc1s8QLAdxUWYvrLmbedSCHLRhqmYrNYepiL6K6W0UysuaNvhoi1bq56tUbFo45clxH5IGFUIOOFbIKw)6ykrutfcX)Ibw1qYvumxFZLHbrT2pVj2GD4bjxrXCTOKZjFDGqVnxJZn4CnCdv2x4(ggbg4K4OKCanD)7jqd1VW7gsT65iKl8VHSPEAk9g6beJCCtVaReLggH(fU5aO5clxH56beJC7RtuDo(qXHScuphLROyUQ9h1jrX(PjxJZnqbpxd3qL9fUVH2xNO6C3)Ec0h5fE3qQvphHCH)nKn1ttP3qgge1A)8UGi4LrLYfwUcZfKoL65iod3GWGrseYcxZYvumxgg7qW(BotLvZ4aO5kkMRhqmYzQSAghanxd5clxgg7qW(Bod3GWGrYxajTO1uVLpKPwTnxFYfcdHBQgj3JLlJkxUcZvT)Oojk2pn5EAUNdEUgYfwUEaXi3(6evNJpKPwTnxFYnW3qL9fUVH2xNO6C3)Ec0b6fE3qQvphHCH)nKn1ttP3qgge1A)8UGi4LrLYfwUcZfKoL65iod3GWGrseYcxZYvumxgg7qW(BotLvZ4aO5kkMRhqmYzQSAghanxd5clxgg7qW(Bod3GWGrYxajTO1uVLpKPwTnxFYfcdHBQgj3JLlJkxUcZvT)Oojk2pn5EAUqb8CnKlSC9aIrU91jQohhanxy5smxHAjE1sTH7gQSVW9n0(6ybgi09VNem4x4DdPw9CeYf(3q2upnLEd9aIroUPxGvYCKosqLTWnhanxrXCfMRV5AFDI1qCfvYeqmWYvumxH56beJCMkRMXhYuR2MRp5EEUWY1dig5mvwnJdGMROyUcZ1dig5JcIAmGvghQpkC8Hm1QT56tUqyiCt1i5ESCzu5YvyUQ9h1jrX(Pj3tZfkGNRHCHLRhqmYhfe1yaRmouFu44aO5Aixd5clxq6uQNJ42xNO6Cs)4(Lr15K4ymxy5ArjNt(6aHEl3(6evNlxFYfk5Aixy5kmxFZDaAkIhie)ltYpEAjYqQPx1i0WjOkqHIsi5kkMRfLCo5Rde6TC7RtuDUC9jxOKRHBOY(c33q7RJfyGq3)EsWqFH3nKA1Zrix4Fdzt90u6nuyUeZvOwIxTuB4YfwUmm2HG93CMkRMXhYuR2MRX5Eo45kkMRWCzc0bczZ9qUbNlSChIjqhiK8ltkxFY98CnKROyUmb6aHS5EixOKRHCHLRIkzcigy3qL9fUVHn5xAIX99VNeCWx4DdPw9CeYf(3q2upnLEdfMlXCfQL4vl1gUCHLldJDiy)nNPYQz8Hm1QT5ACUNdEUII5kmxMaDGq2CpKBW5cl3Hyc0bcj)YKY1NCppxd5kkMltGoqiBUhYfk5Aixy5QOsMaIb2nuzFH7BOa1fLMyCF)7jbdLl8UHuREoc5c)BiBQNMsVHcZLyUc1s8QLAdxUWYLHXoeS)MZuz1m(qMA12Cno3ZbpxrXCfMltGoqiBUhYn4CHL7qmb6aHKFzs56tUNNRHCffZLjqhiKn3d5cLCnKlSCvujtaXa7gQSVW9nmc4CstmUV)9KGd8fE3qL9fUVH(1zk8iXrj5aA6gsT65iKl8V)9KGp)cVBi1QNJqUW)gIrVHw6VHk7lCFdbPtPEo6gcsDa0n0IsoN81bc9wU91jwdLRX5g4Cdi3OdJNCfMRPAFAGtcsDauUNMBWGNRHCdi3OdJNCfMRhqmYTVowGbcjjtuSFAmP(LwSthU9vgy5EAUboxd3qq6iB1KUH2xNynKSAPf705(3tcoqUW7gsT65iKl8VHSPEAk9gsmxHAjUdO1r2Kr(CffZLyUc1sCTHt2Kr(CHLliDk1Zr8Ykzosbr5kkMRhqmYjMRqTK0ID6WhYuR2MRp5QSVWn3(6eRH4KrigWtYVmPCHLRhqmYjMRqTK0ID6WbqZvumxI5kulXRwAXoDYfwU(MliDk1ZrC7RtSgswT0ID6KROyUEaXiNPYQz8Hm1QT56tUk7lCZTVoXAiozeIb8K8ltkxy56BUG0PuphXlRK5ifeLlSC9aIrotLvZ4dzQvBZ1NCjJqmGNKFzs5clxpGyKZuz1moaAUII56beJ8rbrngWkJd1hfooaAUWY1IsoNuGAFkxJZfCEGKlSCfMRfLCo5Rde6T56ZHCHsUII56BUV6O(5wmGtIJYxajJ4HSpNA1Zri5AixrXC9nxq6uQNJ4LvYCKcIYfwUEaXiNPYQz8Hm1QT5ACUKrigWtYVmPBOY(c33q)J(cU)9KGH6x4Ddv2x4(gAFDI1q3qQvphHCH)9VNe8rEH3nKA1Zrix4Fdv2x4(goaTuzFHBPRS)n0v2x2QjDdJQZ9cgG7F)ByuDUxWaCH39eOVW7gsT65iKl8VHSPEAk9g6BUdqtr8aH4EQtBgjXrP6CYxq1qSCcQcuOOeYnuzFH7BO91XcmqO7Fpj4l8UHuREoc5c)BOY(c33qlqhRHUHSPEAk9gIGFUjg3XAi(qMA12Cno3Hm1QT3qgCmhjFDGqV9Ec03)EcuUW7gQSVW9n0eJ7yn0nKA1Zrix4F)7FdT)fE3tG(cVBi1QNJqUW)gQSVW9nuru0VarsRFDmVHSPEAk9g6BUi4NRik6xGiP1VoMse1uHq8VyGvnKCHLRV5QSVWnxru0VarsRFDmLiQPcH4vlJUcIGpxy5kmxFZfb)Cfrr)cejT(1XukGuh)lgyvdjxrXCrWpxru0VarsRFDmLci1XhYuR2MRX5EEUgYvumxe8Zvef9lqK06xhtjIAQqiU9vgy56tUqjxy5IGFUIOOFbIKw)6ykrutfcXhYuR2MRp5cLCHLlc(5kII(fisA9RJPernvie)lgyvd5gYGJ5i5Rde6T3tG((3tc(cVBi1QNJqUW)gYM6PP0BOWCbPtPEoIZWnimyKeHSW1SCHLB1pnOyN(eImwqe8YHm1QT5ACUqdfWZfwU(MldJDiy)nNPYQz8Hue4YvumxpGyKZuz1moaAUgYfwUQ9h1jrX(PjxFY9CWZfwUcZ1dig5eZvOws6aAD4dzQvBZ14CHg8CffZ1dig5eZvOwsAXoD4dzQvBZ14CHg8CnKROyUXcIGxoKPwTnxFYfAWVHk7lCFdz4gegms(ciPfTM6T3)EcuUW7gsT65iKl8VHy0BOL(BOY(c33qq6uQNJUHGuhaDdfMRhqmYzQSAgFitTABUgN755clxH56beJ8rbrngWkJd1hfo(qMA12Cno3ZZvumxFZ1dig5JcIAmGvghQpkCCa0CnKROyU(MRhqmYzQSAghanxrXCv7pQtII9ttU(Kluapxd5clxH56BUEaXihSQrgcrsMOy)0ys9lPMgi1rjoaAUII5Q2FuNef7NMC9jxOaEUgYfwUcZ1dig5eZvOwsAXoD4dzQvBZ14CHWq4MQrYvumxpGyKtmxHAjPdO1HpKPwTnxJZfcdHBQgjxd3qq6iB1KUHi4xoeufOgYK63E)7jb(cVBi1QNJqUW)gQSVW9n0eJ7yn0nKn1ttP3WHIdzfOEokxy5(6aHE(xMK8XsKIY14CHo4CHLRWCvujtaXalxy5csNs9Cehb)YHGQa1qMu)2CnCdzWXCK81bc927jqF)7jNFH3nKA1Zrix4Fdv2x4(gAb6yn0nKn1ttP3WHIdzfOEokxy5(6aHE(xMK8XsKIY14CHo4CHLRWCvujtaXalxy5csNs9Cehb)YHGQa1qMu)2CnCdzWXCK81bc927jqF)7jbYfE3qQvphHCH)nuzFH7BO9jNthz0PdDdzt90u6nCO4qwbQNJYfwUVoqON)LjjFSePOCnoxOdKCHLRWCvujtaXalxy5csNs9Cehb)YHGQa1qMu)2CnCdzWXCK81bc927jqF)7jq9l8UHuREoc5c)BiBQNMsVHkQKjGyGDdv2x4(ggXdJK4OS1hyO7Fp5iVW7gsT65iKl8VHSPEAk9g6beJCMkRMXbqVHk7lCFdhfe1yaRmouFu4U)9Ka9cVBi1QNJqUW)gYM6PP0BOWCfMRhqmYjMRqTK0ID6WhYuR2MRX5cn45kkMRhqmYjMRqTK0b06WhYuR2MRX5cn45Aixy5YWyhc2FZzQSAgFitTABUgNluapxy5kmxpGyKJoLjEqk1j1HPDXKOaoRoCqQdGY1NCdoWGNROyU(M7a0uepqio6uM4bPuNuhM2ftIc4S6WjOkqHIsi5Aixd5kkMRhqmYrNYepiL6K6W0UysuaNvhoi1bq5A8HCdgQdEUII5YWyhc2FZzQSAgFifbUCHLRWCv7pQtII9ttUgNBGcEUII5csNs9CeVSsft5A4gQSVW9neSQrgcrArRPE79VNan4x4DdPw9CeYf(3q2upnLEdfMRA)rDsuSFAY14CduWZfwUcZ1dig5GvnYqisYef7NgtQFj10aPokXbqZvumxFZLHbrT2phm4Ms7CnKROyUmmiQ1(5DbrWlJkLROyUG0PuphXlRuXuUII56beJCphgJ4aSphanxy56beJCphgJ4aSpFitTABU(KBWGNBa5kmxH5gO5ESChGMI4bcXrNYepiL6K6W0UysuaNvhobvbkuucjxd5gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgY1qUWY13C9aIrotLvZ4aO5clxH56BUmmiQ1(5DbrWlJkLROyUmm2HG93CgUbHbJKVasArRPElhanxrXCR(Pbf70NqKXcIGxoKPwTnxFYLHXoeS)MZWnimyK8fqslAn1B5dzQvBZnGCdKCffZT6NguStFcrglicE5qMA12CpEUqFKGNRp5gm45gqUcZnW5ESCz4gbOEo6qSYss1vqAtQFo1QNJqY1qUgUHk7lCFdzKJSFPoP6kiTj1)9VNan0x4DdPw9CeYf(3q2upnLEdfMRA)rDsuSFAY14CduWZfwUcZ1dig5GvnYqisYef7NgtQFj10aPokXbqZvumxFZLHbrT2phm4Ms7CnKROyUmmiQ1(5DbrWlJkLROyUG0PuphXlRuXuUII56beJCphgJ4aSphanxy56beJCphgJ4aSpFitTABU(Kluap3aYvyUcZnqZ9y5oanfXdeIJoLjEqk1j1HPDXKOaoRoCcQcuOOesUgYnGCfMBGZ9y5YWncq9C0HyLLKQRG0Mu)CQvphHKRHCnKRHCHLRV56beJCMkRMXbqZfwUcZ13CzyquR9Z7cIGxgvkxrXCzySdb7V5mCdcdgjFbK0Iwt9woaAUII5w9tdk2PpHiJfebVCitTABU(KldJDiy)nNHBqyWi5lGKw0AQ3YhYuR2MBa5gi5kkMB1pnOyN(eImwqe8YHm1QT5E8CH(ibpxFYfkGNBa5km3aN7XYLHBeG65OdXkljvxbPnP(5uREocjxd5A4gQSVW9nSAMoT(fUV)9eOd(cVBi1QNJqUW)gIrVHw6VHk7lCFdbPtPEo6gcsDa0nuyU(MldJDiy)nNPYQz8Hue4YvumxFZfKoL65iod3GWGrseYcxZYfwUmmiQ1(5DbrWlJkLRHBiiDKTAs3qRcIKr8izQSA29VNanuUW7gsT65iKl8VHSPEAk9gsmxHAjE1sTHlxy5QOsMaIbwUWY1dig5OtzIhKsDsDyAxmjkGZQdhK6aOC9j3Gdm45clxH5IGFUIOOFbIKw)6ykrutfcX)Ibw1qYvumxFZLHbrT2pVj2GD4bjxd5clxq6uQNJ4wfejJ4rYuz1SBOY(c33WiWaNehLKdOP7Fpb6aFH3nKA1Zrix4Fdzt90u6n0dig54MEbwjknmc9lCZbqZfwUEaXi3(6evNJpuCiRa1Zr3qL9fUVH2xNO6C3)Ec0NFH3nKA1Zrix4Fdzt90u6n0dig52xhhEq4dzQvBZ1NCppxy5kmxpGyKtmxHAjPf70HpKPwTnxJZ98CffZ1dig5eZvOws6aAD4dzQvBZ14Cppxd5clx1(J6KOy)0KRX5gOGFdv2x4(gY0MroPhqmEd9aIrzRM0n0(64WdY9VNaDGCH3nKA1Zrix4Fdzt90u6nKHbrT2pVlicEzuPCHLliDk1ZrCgUbHbJKiKfUMLlSCzySdb7V5mCdcdgjFbK0Iwt9w(qMA12C9jximeUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1WnuzFH7BO91XcmqO7FpbAO(fE3qQvphHCH)nKn1ttP3WxDu)C7toNosKPIpNA1Zri5clxFZ9vh1p3(64WdcNA1Zri5clxpGyKBFDIQZXhkoKvG65OCHLRWC9aIroXCfQLKoGwh(qMA12Cno3ajxy5smxHAjE1shqRtUWY1dig5OtzIhKsDsDyAxmjkGZQdhK6aOC9j3Gph8CffZ1dig5OtzIhKsDsDyAxmjkGZQdhK6aOCn(qUbFo45clx1(J6KOy)0KRX5gOGNROyUi4NRik6xGiP1VoMse1uHq8Hm1QT5ACUhzUII5QSVWnxru0VarsRFDmLiQPcH4vlJUcIGpxd5clxFZLHXoeS)MZuz1m(qkcC3qL9fUVH2xNO6C3)Ec0h5fE3qQvphHCH)nKn1ttP3qpGyKJB6fyLmhPJeuzlCZbqZvumxpGyKdw1idHijtuSFAmP(LutdK6OehanxrXC9aIrotLvZ4aO5clxH56beJ8rbrngWkJd1hfo(qMA12C9jximeUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1qUWY1dig5JcIAmGvghQpkCCa0CffZ13C9aIr(OGOgdyLXH6Jchhanxy56BUmm2HG938rbrngWkJd1hfo(qkcC5kkMRV5YWGOw7NdI6xaCtUgYvumx1(J6KOy)0KRX5gOGNlSCjMRqTeVAP2WDdv2x4(gAFDSade6(3tGoqVW7gsT65iKl8VHSPEAk9g(QJ6NBFDC4bHtT65iKCHLRWC9aIrU91XHheoaAUII5Q2FuNef7NMCno3af8CnKlSC9aIrU91XHheU9vgy56tUqjxy5kmxpGyKtmxHAjPf70HdGMROyUEaXiNyUc1sshqRdhanxd5clxpGyKJoLjEqk1j1HPDXKOaoRoCqQdGY1NCdgQdEUWYvyUmm2HG93CMkRMXhYuR2MRX5cn45kkMRV5csNs9CeNHBqyWijczHRz5clxgge1A)8UGi4LrLY1WnuzFH7BO91XcmqO7FpjyWVW7gsT65iKl8VHSPEAk9gkmxpGyKJoLjEqk1j1HPDXKOaoRoCqQdGY1NCdgQdEUII56beJC0PmXdsPoPomTlMefWz1HdsDauU(KBWNdEUWY9vh1p3(KZPJezQ4ZPw9CesUgYfwUEaXiNyUc1ssl2PdFitTABUgNlupxy5smxHAjE1sl2PtUWY13C9aIroUPxGvIsdJq)c3Ca0CHLRV5(QJ6NBFDC4bHtT65iKCHLldJDiy)nNPYQz8Hm1QT5ACUq9CHLRWCzySdb7V5GvnYqislAn1B5dzQvBZ14CH65kkMRV5YWGOw7NdgCtPDUgUHk7lCFdTVowGbcD)7jbd9fE3qQvphHCH)nKn1ttP3qH56beJCI5kuljDaToCa0CffZvyUmb6aHS5Ei3GZfwUdXeOdes(LjLRp5EEUgYvumxMaDGq2CpKluY1qUWYvrLmbedSCHLliDk1ZrCRcIKr8izQSA2nuzFH7Byt(LMyCF)7jbh8fE3qQvphHCH)nKn1ttP3qH56beJCI5kuljDaToCa0CHLRV5YWGOw7NdgCtPDUII5kmxpGyKdw1idHijtuSFAmP(LutdK6Oehanxy5YWGOw7NdgCtPDUgYvumxH5YeOdeYM7HCdoxy5oetGoqi5xMuU(K755AixrXCzc0bczZ9qUqjxrXC9aIrotLvZ4aO5Aixy5QOsMaIbwUWYfKoL65iUvbrYiEKmvwn7gQSVW9nuG6IstmUV)9KGHYfE3qQvphHCH)nKn1ttP3qH56beJCI5kuljDaToCa0CHLRV5YWGOw7NdgCtPDUII5kmxpGyKdw1idHijtuSFAmP(LutdK6Oehanxy5YWGOw7NdgCtPDUgYvumxH5YeOdeYM7HCdoxy5oetGoqi5xMuU(K755AixrXCzc0bczZ9qUqjxrXC9aIrotLvZ4aO5Aixy5QOsMaIbwUWYfKoL65iUvbrYiEKmvwn7gQSVW9nmc4CstmUV)9KGd8fE3qL9fUVH(1zk8iXrj5aA6gsT65iKl8V)9KGp)cVBi1QNJqUW)gYM6PP0BiXCfQL4vlDaTo5kkMlXCfQL4wSthztg5ZvumxI5kulX1goztg5ZvumxpGyK7xNPWJehLKdOjoaAUWY1dig5eZvOws6aAD4aO5kkMRWC9aIrotLvZ4dzQvBZ1NCv2x4M7F0xaNmcXaEs(LjLlSC9aIrotLvZ4aO5A4gQSVW9n0(6eRHU)9KGdKl8UHk7lCFd9p6l4gsT65iKl8V)9KGH6x4DdPw9CeYf(3qL9fUVHdqlv2x4w6k7FdDL9LTAs3WO6CVGb4(3)gIoedB6P)fE3tG(cVBOY(c33qtmUbRAzepM3qQvphHCH)9VNe8fE3qQvphHCH)nuzFH7BO)rFb3qx1KKHCdHg87Fpbkx4DdPw9CeYf(3q2upnLEdrhcehAU)rFb5clxFZfDiq8G5(h9fCdv2x4(g6F0xW9VNe4l8UHk7lCFdTVoXAOBi1QNJqUW)(3to)cVBi1QNJqUW)gIrVHw6VHk7lCFdbPtPEo6gcsDa0n0dBT5cl3OdJNCfMRWCJfebVCitTABUqTCdg8CnK7P5cDWGNRHCno3OdJNCfMRWCJfebVCitTABUqTCd(8CHA5kmxObp3JL7RoQFE1mDA9lCZPw9CesUgYfQLRWCdCUhlxgUraQNJoeRSKuDfK2K6NtT65iKCnKRHCpnxOpsWZ1WneKoYwnPBid3GWGrseYcxZU)9V)neen2c33tcg8GbhAOHgk3q)60vdXEdHk0Oku5tmQCcujgLCZfEcOCltu885gXtUqfrgsn9QgHgOI5oeufOgcjxl2KYvbESP(esUmbAdHS8mOJOAk3Gnk5A04genpHKByzA05AHRF1i5E8CFCUhbGMlsbQSfUZfJsJ(4jxHNAixHqBed8mOJOAkxOH2OKRrJBq08esUHLPrNRfU(vJK7XpEUpo3JaqZ1eJa4aS5IrPrF8KRWJBixHqBed8mOJOAkxOd2OKRrJBq08esUHLPrNRfU(vJK7XpEUpo3JaqZ1eJa4aS5IrPrF8KRWJBixHqBed8mOJOAkxOp3OKRrJBq08esUHLPrNRfU(vJK7XZ9X5EeaAUifOYw4oxmkn6JNCfEQHCfcTrmWZGYGGk0Oku5tmQCcujgLCZfEcOCltu885gXtUqfrhIHn90hQyUdbvbQHqY1InPCvGhBQpHKltG2qilpd6iQMY9CJsUgnUbrZti5gwMgDUw46xnsUhp3hN7raO5IuGkBH7CXO0OpEYv4PgYvyWgXapdkdcQqJQqLpXOYjqLyuYnx4jGYTmrXZNBep5cvuXeuXChcQcudHKRfBs5Qap2uFcjxMaTHqwEg0runLBWgLCnACdIMNqYnSmn6CTW1VAKCp(XZ9X5EeaAUMyeahGnxmkn6JNCfECd5keAJyGNbDevt5gyJsUgnUbrZti5gwMgDUw46xnsUhp3hN7raO5IuGkBH7CXO0OpEYv4PgYvi0gXapd6iQMY9ink5A04genpHKByzA05AHRF1i5E8CFCUhbGMlsbQSfUZfJsJ(4jxHNAixHqBed8mOJOAkxOd2OKRrJBq08esUHLPrNRfU(vJK7XpEUpo3JaqZ1eJa4aS5IrPrF8KRWJBixHqBed8mOJOAkxOHIrjxJg3GO5jKCdltJoxlC9Rgj3JF8CFCUhbGMRjgbWbyZfJsJ(4jxHh3qUcH2ig4zqhr1uUqFKgLCnACdIMNqYnSmn6CTW1VAKCpEUpo3JaqZfPav2c35IrPrF8KRWtnKRqOnIbEg0runLl0bQrjxJg3GO5jKCdltJoxlC9Rgj3JN7JZ9ia0CrkqLTWDUyuA0hp5k8ud5keAJyGNbDevt5gm4gLCnACdIMNqYnSmn6CTW1VAKCpEUpo3JaqZfPav2c35IrPrF8KRWtnKRqOnIbEg0runLBWNBuY1OXniAEcj3WY0OZ1cx)QrY945(4CpcanxKcuzlCNlgLg9XtUcp1qUcd2ig4zqzqqfAufQ8jgvobQeJsU5cpbuULjkE(CJ4jxOI2hQyUdbvbQHqY1InPCvGhBQpHKltG2qilpd6iQMYfAWnk5A04genpHKByzA05AHRF1i5E8JN7JZ9ia0CnXiaoaBUyuA0hp5k84gYvi0gXapd6iQMYfAOnk5A04genpHKByzA05AHRF1i5E8JN7JZ9ia0CnXiaoaBUyuA0hp5k84gYvi0gXapd6iQMYf6aXOKRrJBq08esUHLPrNRfU(vJK7XZ9X5EeaAUifOYw4oxmkn6JNCfEQHCfcTrmWZGoIQPCH(ink5A04genpHKByzA05AHRF1i5E8CFCUhbGMlsbQSfUZfJsJ(4jxHNAixHqBed8mOmiOcnQcv(eJkNavIrj3CHNak3YefpFUr8KlurpS(qfZDiOkqnesUwSjLRc8yt9jKCzc0gcz5zqhr1uUbBuY1OXniAEcj3WY0OZ1cx)QrY945(4CpcanxKcuzlCNlgLg9XtUcp1qUcd2ig4zqhr1uUqFUrjxJg3GO5jKCdltJoxlC9Rgj3JF8CFCUhbGMRjgbWbyZfJsJ(4jxHh3qUcH2ig4zqhr1uUqFKgLCnACdIMNqYnSmn6CTW1VAKCpEUpo3JaqZfPav2c35IrPrF8KRWtnKRqOyed8mOJOAkxOduJsUgnUbrZti5gwMgDUw46xnsUhp3hN7raO5IuGkBH7CXO0OpEYv4PgYvi0gXapdkdYOIjkEEcjxOEUk7lCNRRSVLNbDdrhCSC0n0Oox4RoTzuUqLAakKmiJ6CpbdIm9Oj3GHYz5gm4bdEgugKrDUgTaTHqwJsgKrDUqTCnQIGqi5gID6Kl8j1KNbzuNlulxJwG2qiKCFDGqVSI5YulzZ9X5YGJ5i5Rde6T8miJ6CHA5cvMmXGiKCb6MyK1QdC5csNs9CKnxHfN4NLl6qGK2xhlWaHYfQzCUOdbIBFDSadeYapdkdszFHBlhDig20t)dMyCdw1YiEmZGu2x42YrhIHn90pGdN6F0xWzUQjjd5a0GNbPSVWTLJoedB6PFaho1)OVGZQ4b0HaXHM7F0xamFrhcepyU)rFbzqk7lCB5OdXWME6hWHtTVoXAOmiL9fUTC0Hyytp9d4WPG0PuphDwRM0bgUbHbJKiKfUMDgi1bqh8WwlSOdJhHcJfebVCitTAlulyWnCCOdgCdghDy8iuySGi4LdzQvBHAbFouti0GFSxDu)8Qz606x4MtT65iedqnHb(ymCJauphDiwzjP6kiTj1pNA1ZrigmCCOpsWnKbLbzuNluPncXaEcjxcenWL7xMuUVakxL94j3YMRcslN65iEgKY(c32dwSthPhPMzqk7lCBd4WPG0PuphDwRM0HYkvmDgi1bqhSOKZjFDGqVLBFDIQZzm0We67RoQFU91XHheo1QNJqefF1r9ZTp5C6irMk(CQvphHyqu0IsoN81bc9wU91jQoNXbNbPSVWTnGdNcsNs9C0zTAshkRK5ifeDgi1bqhSOKZjFDGqVLBFDI1qgdDgKY(c32aoCQhnwAaRAiNvXdc9LHbrT2pVlicEzujrrFzySdb7V5mCdcdgjFbK0Iwt9woaQbyEaXiNPYQzCa0miL9fUTbC4uu8x4(SkEWdig5mvwnJdGMbPSVWTnGdNcyjz9KPndszFHBBahovaPZljRLAgDwfp4iqKZNZHodszFHBBahoDaAPY(c3sxz)ZA1KoOy6m7pf7pa9zv8aiDk1Zr8YkvmLbPSVWTnGdNoaTuzFHBPRS)zTAshqgsn9QgHMZS)uS)a0NvXddqtr8aH4Fzs(Xtlrgsn9QgHgobvbkuucjdszFHBBahoDaAPY(c3sxz)ZA1Ko4H1)m7pf7pa9zv8Wa0uepqiUN60MrsCuQoN8funelNGQafkkHKbPSVWTnGdNoaTuzFHBPRS)zTAshSFgugKY(c3wUIPdG0PuphDwRM0bKHutP)Y5Kr15K4y8mqQdGoi0dig5Fzs(Xtlrgsn9QgHg(qMA1wFGWq4MQrcaCo0IIEaXi)ltYpEAjYqQPx1i0WhYuR26JY(c3C7RtSgItgHyapj)YKcaCo0WesmxHAjE1shqRJOiXCfQL4wSthztg5ffjMRqTexB4KnzK3GbyEaXi)ltYpEAjYqQPx1i0WbqHnanfXdeI)Lj5hpTezi10RAeA4eufOqrjKmiL9fUTCftbC4u7RtuDUZQ4bpGyKBFDIQZXhkoKvG65iycTOKZjFDGqVLBFDIQZ5duef9DaAkIhie)ltYpEAjYqQPx1i0WjOkqHIsigGj03bOPiEGqChCmDuRm6i6RgIeIRmrTeNGQafkkHik(LjD8Jh4Zn2dig52xNO6C8Hm1QTbeSHmiL9fUTCftbC4u7RtuDUZQ4HbOPiEGq8Vmj)4PLidPMEvJqdNGQafkkHaZIsoN81bc9wU91jQoNXhGcmH(6beJ8Vmj)4PLidPMEvJqdhafMhqmYTVor154dfhYkq9CKOOqq6uQNJ4idPMs)LZjJQZjXXimHEaXi3(6evNJpKPwT1hOikArjNt(6aHEl3(6evNZ4GH9QJ6NBFY50rImv85uREocbMhqmYTVor154dzQvB95CdgmKbPSVWTLRykGdNcsNs9C0zTAshSVor15K(X9lJQZjXX4zGuhaDqT)Oojk2pngFKGd1ecn4hZdig5Fzs(Xtlrgsn9QgHgU9vgygGAc9aIrU91jQohFitTA7XGYXTOKZjfO2Nma1eIGFEeyGtIJsYb0eFitTA7Xo3ampGyKBFDIQZXbqZGu2x42YvmfWHtTVowGbcDwfpasNs9Cehzi1u6VCozuDojogHbsNs9Ce3(6evNt6h3VmQoNehJzqk7lCB5kMc4WPwGowdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdmuZIsoN81bc92agYuR2ctrLmbedmyeZvOwIxTuB4YGu2x42YvmfWHtvef9lqK06xhZZyWXCK81bc92dqFwfp47xmWQgcmFv2x4MRik6xGiP1VoMse1uHq8QLrxbrWlkIGFUIOOFbIKw)6ykrutfcXTVYaZhOadb)Cfrr)cejT(1XuIOMkeIpKPwT1hOKbPSVWTLRykGdNAIXDSg6mgCmhjFDGqV9a0NvXddfhYkq9CeSxhi0Z)YKKpwIuKXcHoWbi0IsoN81bc9wU91jwdDmO5NBWWXTOKZjFDGqVnGHm1QTWekKHXoeS)MZuz1m(qkcCIIwuY5KVoqO3YTVoXAiFGIOOqI5kulXRwAXoDefjMRqTeVAPh(fiksmxHAjE1shqRdmFF1r9ZTyaNehLVasgXdzFo1QNJqef9aIro6uM4bPuNuhM2ftIc4S6WbPoaY4dbFo4gGj0IsoN81bc9wU91jwd5d0GFmHqhWRoQF(7VAPjg3wo1QNJqmyaMA)rDsuSFAm(CWHAEaXi3(6evNJpKPwT9ybIby(6beJCWQgziejzII9tJj1VKAAGuhL4aOWuujtaXaZqgKY(c3wUIPaoCkd3GWGrYxajTO1uV9SkEqiiDk1ZrCgUbHbJKiKfUMbR6NguStFcrglicE5qMA1wJHgkGdZxgg7qW(BotLvZ4dPiWjk6beJCMkRMXbqnatT)Oojk2pn(Co4We6beJCI5kuljDaTo8Hm1QTghiIIEaXiNyUc1ssl2PdFitTARXb2GOySGi4LdzQvB9bAWZGu2x42YvmfWHtJ4HrsCu26dm0zv8GIkzcigyzqk7lCB5kMc4WPJcIAmGvghQpkCNvXdEaXiNPYQzCa0miL9fUTCftbC4ug5i7xQtQUcsBs9Fwfpi0dig52xNO6CCaurr1(J6KOy)0y85GBaMVEaXi3ID2VyehafMVEaXiNPYQzCauyc9LHbrT2pVlicEzujrrgg7qW(Bod3GWGrYxajTO1uVLdGkkw9tdk2PpHiJfebVCitTARpmm2HG93CgUbHbJKVasArRPElFitTABabIOy1pnOyN(eImwqe8YHm1QTh)4qFKG7tWGhGWaFmgUraQNJoeRSKuDfK2K6NtT65iedgYGu2x42YvmfWHtRMPtRFH7ZQ4bHEaXi3(6evNJdGkkQ2FuNef7NgJphCdW81dig5wSZ(fJ4aOW81dig5mvwnJdGctOVmmiQ1(5DbrWlJkjkYWyhc2FZz4gegms(ciPfTM6TCaurXQFAqXo9jezSGi4LdzQvB9HHXoeS)MZWnimyK8fqslAn1B5dzQvBdiqefR(Pbf70NqKXcIGxoKPwT94hh6JeCFGc4bimWhJHBeG65OdXkljvxbPnP(5uREocXGHmiL9fUTCftbC4uWQgziePfTM6TNvXdv)0GID6tiYybrWlhYuR26d0Nlkk0dig5OtzIhKsDsDyAxmjkGZQdhK6aiFc(CWff9aIro6uM4bPuNuhM2ftIc4S6WbPoaY4dbFo4gG5beJC7RtuDooakmgg7qW(BotLvZ4dzQvBn(CWZGu2x42YvmfWHtTp5C6iJoDOZyWXCK81bc92dqFwfpmuCiRa1ZrW(YKKpwIuKXqFomlk5CYxhi0B52xNynKpbgMIkzcigyWe6beJCMkRMXhYuR2Am0Glk6RhqmYzQSAgha1qgKY(c3wUIPaoCAeyGtIJsYb00zv8aXCfQL4vl1goykQKjGyGbZdig5OtzIhKsDsDyAxmjkGZQdhK6aiFc(CWHjeb)Cfrr)cejT(1XuIOMkeI)fdSQHik6lddIATFEtSb7WdIOOfLCo5Rde6TghSHmiL9fUTCftbC4u7RtuDUZQ4bpGyKJB6fyLO0Wi0VWnhafMqpGyKBFDIQZXhkoKvG65irr1(J6KOy)0yCGcUHmiL9fUTCftbC4u7RtuDUZQ4bgge1A)8UGi4LrLGjeKoL65iod3GWGrseYcxZefzySdb7V5mvwnJdGkk6beJCMkRMXbqnaJHXoeS)MZWnimyK8fqslAn1B5dzQvB9bcdHBQg5ymQCcv7pQtII9tZXphCdW8aIrU91jQohFitTARpbodszFHBlxXuaho1(6ybgi0zv8addIATFExqe8YOsWecsNs9CeNHBqyWijczHRzIImm2HG93CMkRMXbqff9aIrotLvZ4aOgGXWyhc2FZz4gegms(ciPfTM6T8Hm1QT(aHHWnvJCmgvoHQ9h1jrX(P54qbCdW8aIrU91jQohhafgXCfQL4vl1gUmiL9fUTCftbC4u7RJfyGqNvXdEaXih30lWkzoshjOYw4MdGkkk0x7RtSgIROsMaIbMOOqpGyKZuz1m(qMA1wFohMhqmYzQSAghavuuOhqmYhfe1yaRmouFu44dzQvB9bcdHBQg5ymQCcv7pQtII9tZXHc4gG5beJ8rbrngWkJd1hfooaQbdWaPtPEoIBFDIQZj9J7xgvNtIJrywuY5KVoqO3YTVor158bkgGj03bOPiEGq8Vmj)4PLidPMEvJqdNGQafkkHikArjNt(6aHEl3(6evNZhOyidszFHBlxXuahoTj)stmUpRIhesmxHAjE1sTHdgdJDiy)nNPYQz8Hm1QTgFo4IIczc0bczpemSHyc0bcj)YK85CdIImb6aHShGIbykQKjGyGLbPSVWTLRykGdNkqDrPjg3NvXdcjMRqTeVAP2WbJHXoeS)MZuz1m(qMA1wJphCrrHmb6aHShcg2qmb6aHKFzs(CUbrrMaDGq2dqXamfvYeqmWYGu2x42YvmfWHtJaoN0eJ7ZQ4bHeZvOwIxTuB4GXWyhc2FZzQSAgFitTARXNdUOOqMaDGq2dbdBiMaDGqYVmjFo3GOitGoqi7bOyaMIkzcigyzqk7lCB5kMc4WP(1zk8iXrj5aAkdszFHBlxXuahofKoL65OZA1KoyFDI1qYQLwStNZaPoa6GfLCo5Rde6TC7RtSgY4ahq0HXJqt1(0aNeK6aOJhm4gci6W4rOhqmYTVowGbcjjtuSFAmP(LwSthU9vgyhpWgYGu2x42YvmfWHt9p6l4SkEGyUc1sChqRJSjJ8IIeZvOwIRnCYMmYddKoL65iEzLmhPGirrpGyKtmxHAjPf70HpKPwT1hL9fU52xNyneNmcXaEs(LjbZdig5eZvOwsAXoD4aOIIeZvOwIxT0ID6aZxq6uQNJ42xNynKSAPf70ru0dig5mvwnJpKPwT1hL9fU52xNyneNmcXaEs(LjbZxq6uQNJ4LvYCKcIG5beJCMkRMXhYuR26dzeIb8K8ltcMhqmYzQSAghavu0dig5JcIAmGvghQpkCCauywuY5Kcu7tgdopqGj0IsoN81bc9wFoafrrFF1r9ZTyaNehLVasgXdzFo1QNJqmik6liDk1Zr8YkzosbrW8aIrotLvZ4dzQvBnMmcXaEs(LjLbPSVWTLRykGdNAFDI1qzqk7lCB5kMc4WPdqlv2x4w6k7FwRM0HO6CVGbidkdszFHBl3dR)HrbrngWkJd1hfUZQ4bpGyKZuz1moaAgKY(c3wUhw)aoCkiDk1ZrN1QjDGHBqyWijczHRzNbsDa0HOdJhHcR(Pbf70NqKXcIGxoKPwTfQfm4goo0bdUbJJomEekS6NguStFcrglicE5qMA1wOwWNd1ecn4h7vh1pVAMoT(fU5uREocXautyGpgd3ia1ZrhIvwsQUcsBs9ZPw9CeIbdhh6JeCdzqk7lCB5Ey9d4WPG0PuphDwRM0b2uFJFa0ZaPoa6GVEaXi3tDAZijokvNt(cQgIv26dmehafMVEaXi3tDAZijokvNt(cQgIvQdtBIdGMbPSVWTL7H1pGdNQik6xGiP1VoMNXGJ5i5Rde6ThG(SkEWdig5EQtBgjXrP6CYxq1qSYwFGH42xzGjbPoaYNadompGyK7PoTzKehLQZjFbvdXk1HPnXTVYatcsDaKpbgCyc9fb)Cfrr)cejT(1XuIOMkeI)fdSQHaZxL9fU5kII(fisA9RJPernvieVAz0vqe8We6lc(5kII(fisA9RJPuaPo(xmWQgIOic(5kII(fisA9RJPuaPo(qMA1wJHIbrre8Zvef9lqK06xhtjIAQqiU9vgy(afyi4NRik6xGiP1VoMse1uHq8Hm1QT(Come8Zvef9lqK06xhtjIAQqi(xmWQgIHmiL9fUTCpS(bC4ugUbHbJKVasArRPE7zv8Gqq6uQNJ4mCdcdgjrilCndw1pnOyN(eImwqe8YHm1QTgdnuahMVmm2HG93CMkRMXhsrGtu0dig5mvwnJdGAaMqpGyK7PoTzKehLQZjFbvdXkB9bgIBFLbMeK6aOdNdUOOhqmY9uN2msIJs15KVGQHyL6W0M42xzGjbPoa6W5GBqumwqe8YHm1QT(an4zqk7lCB5Ey9d4WPmTzKt6beJN1QjDW(64WdYzv8GqpGyK7PoTzKehLQZjFbvdXkB9bgIpKPwT14aZpxu0dig5EQtBgjXrP6CYxq1qSsDyAt8Hm1QTghy(5gGP2FuNef7NgJpeOGdtidJDiy)nNPYQz8Hm1QTgd1fffYWyhc2FZjtuSFAKE4gHpKPwT1yOomF9aIroyvJmeIKmrX(PXK6xsnnqQJsCauymmiQ1(5Gb3uABWqgKY(c3wUhw)aoCQ91XcmqOZQ4bFbPtPEoIZM6B8dGctiddIATFExqe8YOsIImm2HG93CMkRMXhYuR2AmuxuuidJDiy)nNmrX(Pr6HBe(qMA1wJH6W81dig5GvnYqisYef7NgtQFj10aPokXbqHXWGOw7NdgCtPTbdzqk7lCB5Ey9d4WP2xhlWaHoRIheYWyhc2FZz4gegms(ciPfTM6TCauycbPtPEoIZWnimyKeHSW1mrrgg7qW(BotLvZ4dzQvB95CdgGP2FuNef7NgJphCymmiQ1(5DbrWlJkLbPSVWTL7H1pGdNAb6yn0zm4yos(6aHE7bOpRIhgkoKvG65iyVoqON)LjjFSePiJHoqGjurLmbedmycbPtPEoIZM6B8dGkkkuT)Oojk2pn(afWH5RhqmYzQSAgha1GOidJDiy)nNPYQz8Hue4myidszFHBl3dRFaho1eJ7yn0zm4yos(6aHE7bOpRIhgkoKvG65iyVoqON)LjjFSePiJHgk8ZHjurLmbedmycbPtPEoIZM6B8dGkkkuT)Oojk2pn(afWH5RhqmYzQSAgha1GOidJDiy)nNPYQz8Hue4maZxpGyKdw1idHijtuSFAmP(LutdK6Oeha1qgKY(c3wUhw)aoCQ9jNthz0PdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdKagYuR2ctOIkzcigyWecsNs9CeNn134havuuT)Oojk2pn(afWffzySdb7V5mvwnJpKIaNbdzqk7lCB5Ey9d4WPr8WijokB9bg6SkEqrLmbedSmiL9fUTCpS(bC40iWaNehLKdOPZQ4bHeZvOwIxTuB4efjMRqTe3ID6iRwcTOiXCfQL4oGwhz1sOnatOVmmiQ1(5DbrWlJkjkkuT)Oojk2pn(eONdtiiDk1ZrC2uFJFaurr1(J6KOy)04duaxueKoL65iEzLkMmatiiDk1ZrCgUbHbJKiKfUMbZxgg7qW(Bod3GWGrYxajTO1uVLdGkk6liDk1ZrCgUbHbJKiKfUMbZxgg7qW(BotLvZ4aOgmyaMqgg7qW(BotLvZ4dzQvBngkGlkQ2FuNef7NgJduWHXWyhc2FZzQSAghafMqgg7qW(BozII9tJ0d3i8Hm1QT(OSVWn3(6eRH4KrigWtYVmjrrFzyquR9ZbdUP02GOy1pnOyN(eImwqe8YHm1QT(an4gGjeb)Cfrr)cejT(1XuIOMkeIpKPwT14alk6lddIATFEtSb7WdIHmiL9fUTCpS(bC4uWQgziePfTM6TNvXdcjMRqTe3b06iBYiVOiXCfQL4wSthztg5ffjMRqTexB4KnzKxu0dig5EQtBgjXrP6CYxq1qSYwFGH4dzQvBnoW8Zff9aIrUN60MrsCuQoN8funeRuhM2eFitTARXbMFUOOA)rDsuSFAmoqbhgdJDiy)nNPYQz8Hue4matidJDiy)nNPYQz8Hm1QTgdfWffzySdb7V5mvwnJpKIaNbrXQFAqXo9jezSGi4LdzQvB9bAWZGu2x42Y9W6hWHtzKJSFPoP6kiTj1)zv8Gq1(J6KOy)0yCGcomHEaXihSQrgcrsMOy)0ys9lPMgi1rjoaQOOVmmiQ1(5Gb3uABquKHbrT2pVlicEzujrrpGyK75WyehG95aOW8aIrUNdJrCa2NpKPwT1NGbpaHb(ymCJauphDiwzjP6kiTj1pNA1ZrigmatOVmmiQ1(5DbrWlJkjkYWyhc2FZz4gegms(ciPfTM6TCaurXQFAqXo9jezSGi4LdzQvB9HHXoeS)MZWnimyK8fqslAn1B5dzQvBdiqefR(Pbf70NqKXcIGxoKPwT94hh6JeCFcg8aeg4JXWncq9C0HyLLKQRG0Mu)CQvphHyWqgKY(c3wUhw)aoCA1mDA9lCFwfpiuT)Oojk2pnghOGdtOhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGkk6lddIATFoyWnL2gefzyquR9Z7cIGxgvsu0dig5EomgXbyFoakmpGyK75WyehG95dzQvB9bkGhGWaFmgUraQNJoeRSKuDfK2K6NtT65iedgGj0xgge1A)8UGi4LrLefzySdb7V5mCdcdgjFbK0Iwt9woaQOiiDk1ZrCgUbHbJKiKfUMbR6NguStFcrglicE5qMA1wJH(ibpGGbpaHb(ymCJauphDiwzjP6kiTj1pNA1ZrigefR(Pbf70NqKXcIGxoKPwT1hgg7qW(Bod3GWGrYxajTO1uVLpKPwTnGaruS6NguStFcrglicE5qMA1wFGc4bimWhJHBeG65OdXkljvxbPnP(5uREocXGHmiL9fUTCpS(bC4u7RJfyGqNvXdmmiQ1(5DbrWlJkbtiiDk1ZrCgUbHbJKiKfUMjkYWyhc2FZzQSAgFitTARpqdUbyQ9h1jrX(PX4ZbhgdJDiy)nNHBqyWi5lGKw0AQ3YhYuR26d0GNbPSVWTL7H1pGdNcsNs9C0zTAshulkub0esSZaPoa6aXCfQL4vlDaToh7ipUY(c3C7RtSgItgHyapj)YKcWxI5kulXRw6aADowGCCL9fU5(h9fWjJqmGNKFzsbaop4JBrjNtkqTpLbPSVWTL7H1pGdNAFDSade6SkEqy1pnOyN(eImwqe8YHm1QT(eyrrHEaXiFuquJbSY4q9rHJpKPwT1himeUPAKJXOYjuT)Oojk2pnhhkGBaMhqmYhfe1yaRmouFu44aOgmikkuT)Oojk2pnbasNs9CexTOqfqtiXoMhqmYjMRqTK0ID6WhYuR2gac(5rGbojokjhqt8VyGzLdzQvFSG5NBm0bdUOOA)rDsuSFAcaKoL65iUArHkGMqIDmpGyKtmxHAjPdO1HpKPwTnae8ZJadCsCusoGM4FXaZkhYuR(ybZp3yOdgCdWiMRqTeVAP2WbtOqFzySdb7V5mvwnJdGkkYWGOw7NdgCtPnmFzySdb7V5Kjk2pnspCJWbqnikYWGOw7N3febVmQKbyc9LHbrT2phe1Va4grrF9aIrotLvZ4aOIIQ9h1jrX(PX4afCdIIEaXiNPYQz8Hm1QTgFKW81dig5JcIAmGvghQpkCCa0miL9fUTCpS(bC40M8lnX4(SkEqOhqmYjMRqTK0b06WbqfffYeOdeYEiyydXeOdes(Lj5Z5gefzc0bczpafdWuujtaXaldszFHBl3dRFahovG6IstmUpRIhe6beJCI5kuljDaToCaurrHmb6aHShcg2qmb6aHKFzs(CUbrrMaDGq2dqXamfvYeqmWYGu2x42Y9W6hWHtJaoN0eJ7ZQ4bHEaXiNyUc1sshqRdhavuuitGoqi7HGHnetGoqi5xMKpNBquKjqhiK9aumatrLmbedSmiL9fUTCpS(bC4u)6mfEK4OKCanLbPSVWTL7H1pGdNAFDI1qNvXdeZvOwIxT0b06iksmxHAjUf70r2KrErrI5kulX1goztg5ff9aIrUFDMcpsCusoGM4aOWiMRqTeVAPdO1ruuOhqmYzQSAgFitTARpk7lCZ9p6lGtgHyapj)YKG5beJCMkRMXbqnKbPSVWTL7H1pGdN6F0xqgKY(c3wUhw)aoC6a0sL9fULUY(N1QjDiQo3lyaYGYGu2x42Yrgsn9QgHMdG0PuphDwRM0bRgj5JLawsArjN7mqQdGoi0dig5Fzs(Xtlrgsn9QgHg(qMA1wJHWq4MQrcaCo0WesmxHAjE1sp8lquKyUc1s8QLwSthrrI5kulXDaToYMmYBqu0dig5Fzs(Xtlrgsn9QgHg(qMA1wJv2x4MBFDI1qCYied4j5xMuaGZHgMqI5kulXRw6aADefjMRqTe3ID6iBYiVOiXCfQL4AdNSjJ8gmik6RhqmY)YK8JNwImKA6vncnCa0miL9fUTCKHutVQrOjGdNAFDSade6SkEqOVG0PuphXTAKKpwcyjPfLCorrHEaXiFuquJbSY4q9rHJpKPwT1himeUPAKJXOYjuT)Oojk2pnhhkGBaMhqmYhfe1yaRmouFu44aOgmikQ2FuNef7NgJduWZGu2x42Yrgsn9QgHMaoCkd3GWGrYxajTO1uV9SkEqiiDk1ZrCgUbHbJKiKfUMbR6NguStFcrglicE5qMA1wJHgkGdZxgg7qW(BotLvZ4dPiWjk6beJCMkRMXbqnatT)Oojk2pn(eyWHj0dig5eZvOws6aAD4dzQvBngAWff9aIroXCfQLKwSth(qMA1wJHgCdIIXcIGxoKPwT1hObpdszFHBlhzi10RAeAc4WPkII(fisA9RJ5zm4yos(6aHE7bOpRIh8fb)Cfrr)cejT(1XuIOMkeI)fdSQHaZxL9fU5kII(fisA9RJPernvieVAz0vqe8We6lc(5kII(fisA9RJPuaPo(xmWQgIOic(5kII(fisA9RJPuaPo(qMA1wJp3GOic(5kII(fisA9RJPernvie3(kdmFGcme8Zvef9lqK06xhtjIAQqi(qMA1wFGcme8Zvef9lqK06xhtjIAQqi(xmWQgsgKY(c3woYqQPx1i0eWHtnX4owdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdgMqHEaXiNPYQz8Hm1QTgFomHEaXiFuquJbSY4q9rHJpKPwT14Zff91dig5JcIAmGvghQpkCCaudII(6beJCMkRMXbqffv7pQtII9tJpqbCdWe6RhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGkkQ2FuNef7NgFGc4gGPOsMaIbMHmiL9fUTCKHutVQrOjGdNAb6yn0zm4yos(6aHE7bOpRIhgkoKvG65iyVoqON)LjjFSePiJHoyycf6beJCMkRMXhYuR2A85We6beJ8rbrngWkJd1hfo(qMA1wJpxu0xpGyKpkiQXawzCO(OWXbqnik6RhqmYzQSAghavuuT)Oojk2pn(afWnatOVEaXihSQrgcrsMOy)0ys9lPMgi1rjoaQOOA)rDsuSFA8bkGBaMIkzcigygYGu2x42Yrgsn9QgHMaoCQ9jNthz0PdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdeycf6beJCMkRMXhYuR2A85We6beJ8rbrngWkJd1hfo(qMA1wJpxu0xpGyKpkiQXawzCO(OWXbqnik6RhqmYzQSAghavuuT)Oojk2pn(afWnatOVEaXihSQrgcrsMOy)0ys9lPMgi1rjoaQOOA)rDsuSFA8bkGBaMIkzcigygYGu2x42Yrgsn9QgHMaoCAepmsIJYwFGHoRIhuujtaXaldszFHBlhzi10RAeAc4WPJcIAmGvghQpkCNvXdEaXiNPYQzCa0miL9fUTCKHutVQrOjGdNcw1idHiTO1uV9SkEqOqpGyKtmxHAjPf70HpKPwT1yObxu0dig5eZvOws6aAD4dzQvBngAWnaJHXoeS)MZuz1m(qMA1wJHc4gefzySdb7V5mvwnJpKIaxgKY(c3woYqQPx1i0eWHtzKJSFPoP6kiTj1)zv8GqHEaXihSQrgcrsMOy)0ys9lPMgi1rjoaQOOVmmiQ1(5Gb3uABquKHbrT2pVlicEzujrrq6uQNJ4LvQysu0dig5EomgXbyFoakmpGyK75WyehG95dzQvB9jyWdqyGpgd3ia1ZrhIvwsQUcsBs9ZPw9CeIbdW81dig5mvwnJdGctOVmmiQ1(5DbrWlJkjkYWyhc2FZz4gegms(ciPfTM6TCaurXQFAqXo9jezSGi4LdzQvB9HHXoeS)MZWnimyK8fqslAn1B5dzQvBdiqefR(Pbf70NqKXcIGxoKPwT94hh6JeCFcg8aeg4JXWncq9C0HyLLKQRG0Mu)CQvphHyWqgKY(c3woYqQPx1i0eWHtRMPtRFH7ZQ4bHc9aIroyvJmeIKmrX(PXK6xsnnqQJsCaurrFzyquR9ZbdUP02GOiddIATFExqe8YOsIIG0PuphXlRuXKOOhqmY9CymIdW(CauyEaXi3ZHXioa7ZhYuR26duapaHb(ymCJauphDiwzjP6kiTj1pNA1ZrigmaZxpGyKZuz1moakmH(YWGOw7N3febVmQKOidJDiy)nNHBqyWi5lGKw0AQ3YbqffR(Pbf70NqKXcIGxoKPwT1hgg7qW(Bod3GWGrYxajTO1uVLpKPwTnGaruS6NguStFcrglicE5qMA12JFCOpsW9bkGhGWaFmgUraQNJoeRSKuDfK2K6NtT65iedgYGu2x42Yrgsn9QgHMaoCkiDk1ZrN1QjDWQGizepsMkRMDgi1bqhe6ldJDiy)nNPYQz8Hue4ef9fKoL65iod3GWGrseYcxZGXWGOw7N3febVmQKHmiL9fUTCKHutVQrOjGdNgbg4K4OKCanDwfpqmxHAjE1sTHdMIkzcigyWeIGFUIOOFbIKw)6ykrutfcX)Ibw1qef9LHbrT2pVj2GD4bXamq6uQNJ4wfejJ4rYuz1SmiL9fUTCKHutVQrOjGdNAFDSade6SkEGHbrT2pVlicEzujyG0PuphXz4gegmsIqw4Agm1(J6KOy)0y8Hadomgg7qW(Bod3GWGrYxajTO1uVLpKPwT1himeUPAKJXOYjuT)Oojk2pnhhkGBidszFHBlhzi10RAeAc4WPn5xAIX9zv8GqpGyKtmxHAjPdO1HdGkkkKjqhiK9qWWgIjqhiK8ltYNZnikYeOdeYEakgGPOsMaIbgmq6uQNJ4wfejJ4rYuz1SmiL9fUTCKHutVQrOjGdNkqDrPjg3NvXdc9aIroXCfQLKoGwhoakmFzyquR9ZbdUP0wuuOhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGcJHbrT2phm4MsBdIIczc0bczpemSHyc0bcj)YK85CdIImb6aHShGIOOhqmYzQSAgha1amfvYeqmWGbsNs9Ce3QGizepsMkRMLbPSVWTLJmKA6vncnbC40iGZjnX4(SkEqOhqmYjMRqTK0b06WbqH5lddIATFoyWnL2IIc9aIroyvJmeIKmrX(PXK6xsnnqQJsCauymmiQ1(5Gb3uABquuitGoqi7HGHnetGoqi5xMKpNBquKjqhiK9auef9aIrotLvZ4aOgGPOsMaIbgmq6uQNJ4wfejJ4rYuz1SmiL9fUTCKHutVQrOjGdN6xNPWJehLKdOPmiL9fUTCKHutVQrOjGdNAFDI1qNvXdeZvOwIxT0b06iksmxHAjUf70r2KrErrI5kulX1goztg5ff9aIrUFDMcpsCusoGM4aOW8aIroXCfQLKoGwhoaQOOqpGyKZuz1m(qMA1wFu2x4M7F0xaNmcXaEs(LjbZdig5mvwnJdGAidszFHBlhzi10RAeAc4WP(h9fKbPSVWTLJmKA6vncnbC40bOLk7lClDL9pRvt6quDUxWaKbLbPSVWTLhvN7fmahSVowGbcDwfp47a0uepqiUN60MrsCuQoN8funelNGQafkkHKbPSVWTLhvN7fmabC4ulqhRHoJbhZrYxhi0Bpa9zv8ac(5MyChRH4dzQvBnEitTABgKY(c3wEuDUxWaeWHtnX4owdLbLbPSVWTLB)dkII(fisA9RJ5zm4yos(6aHE7bOpRIh8fb)Cfrr)cejT(1XuIOMkeI)fdSQHaZxL9fU5kII(fisA9RJPernvieVAz0vqe8We6lc(5kII(fisA9RJPuaPo(xmWQgIOic(5kII(fisA9RJPuaPo(qMA1wJp3GOic(5kII(fisA9RJPernvie3(kdmFGcme8Zvef9lqK06xhtjIAQqi(qMA1wFGcme8Zvef9lqK06xhtjIAQqi(xmWQgsgKY(c3wU9d4WPmCdcdgjFbK0Iwt92ZQ4bHG0PuphXz4gegmsIqw4AgSQFAqXo9jezSGi4LdzQvBngAOaomFzySdb7V5mvwnJpKIaNOOhqmYzQSAgha1am1(J6KOy)04Z5GdtOhqmYjMRqTK0b06WhYuR2Am0Glk6beJCI5kuljTyNo8Hm1QTgdn4gefJfebVCitTARpqdEgKY(c3wU9d4WPG0PuphDwRM0be8lhcQcudzs9BpdK6aOdc9aIrotLvZ4dzQvBn(Cyc9aIr(OGOgdyLXH6JchFitTARXNlk6RhqmYhfe1yaRmouFu44aOgef91dig5mvwnJdGkkQ2FuNef7NgFGc4gGj0xpGyKdw1idHijtuSFAmP(LutdK6OehavuuT)Oojk2pn(afWnatOhqmYjMRqTK0ID6WhYuR2Amegc3unIOOhqmYjMRqTK0b06WhYuR2Amegc3unIHmiL9fUTC7hWHtnX4owdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdgMqfvYeqmWGbsNs9Cehb)YHGQa1qMu)wdzqk7lCB52pGdNAb6yn0zm4yos(6aHE7bOpRIhgkoKvG65iyVoqON)LjjFSePiJHoyycvujtaXadgiDk1ZrCe8lhcQcudzs9BnKbPSVWTLB)aoCQ9jNthz0PdDgdoMJKVoqO3Ea6ZQ4HHIdzfOEoc2Rde65FzsYhlrkYyOdeycvujtaXadgiDk1ZrCe8lhcQcudzs9BnKbPSVWTLB)aoCAepmsIJYwFGHoRIhuujtaXaldszFHBl3(bC40rbrngWkJd1hfUZQ4bpGyKZuz1moaAgKY(c3wU9d4WPGvnYqislAn1BpRIhek0dig5eZvOwsAXoD4dzQvBngAWff9aIroXCfQLKoGwh(qMA1wJHgCdWyySdb7V5mvwnJpKPwT1yOaomHEaXihDkt8GuQtQdt7IjrbCwD4Guha5tWbgCrrFhGMI4bcXrNYepiL6K6W0UysuaNvhobvbkuucXGbrrpGyKJoLjEqk1j1HPDXKOaoRoCqQdGm(qWqDWffzySdb7V5mvwnJpKIahmHQ9h1jrX(PX4afCrrq6uQNJ4LvQyYqgKY(c3wU9d4WPmYr2VuNuDfK2K6)SkEqOA)rDsuSFAmoqbhMqpGyKdw1idHijtuSFAmP(LutdK6Oehavu0xgge1A)CWGBkTnikYWGOw7N3febVmQKOiiDk1Zr8Ykvmjk6beJCphgJ4aSphafMhqmY9CymIdW(8Hm1QT(em4biuyGESbOPiEGqC0PmXdsPoPomTlMefWz1HtqvGcfLqmeGWaFmgUraQNJoeRSKuDfK2K6NtT65iedgmaZxpGyKZuz1moakmH(YWGOw7N3febVmQKOidJDiy)nNHBqyWi5lGKw0AQ3YbqffR(Pbf70NqKXcIGxoKPwT1hgg7qW(Bod3GWGrYxajTO1uVLpKPwTnGaruS6NguStFcrglicE5qMA12JFCOpsW9jyWdqyGpgd3ia1ZrhIvwsQUcsBs9ZPw9CeIbdzqk7lCB52pGdNwntNw)c3NvXdcv7pQtII9tJXbk4We6beJCWQgziejzII9tJj1VKAAGuhL4aOII(YWGOw7NdgCtPTbrrgge1A)8UGi4LrLefbPtPEoIxwPIjrrpGyK75WyehG95aOW8aIrUNdJrCa2NpKPwT1hOaEacfgOhBaAkIhiehDkt8GuQtQdt7IjrbCwD4eufOqrjedbimWhJHBeG65OdXkljvxbPnP(5uREocXGbdW81dig5mvwnJdGctOVmmiQ1(5DbrWlJkjkYWyhc2FZz4gegms(ciPfTM6TCaurXQFAqXo9jezSGi4LdzQvB9HHXoeS)MZWnimyK8fqslAn1B5dzQvBdiqefR(Pbf70NqKXcIGxoKPwT94hh6JeCFGc4bimWhJHBeG65OdXkljvxbPnP(5uREocXGHmiL9fUTC7hWHtbPtPEo6SwnPdwfejJ4rYuz1SZaPoa6GqFzySdb7V5mvwnJpKIaNOOVG0PuphXz4gegmsIqw4Agmgge1A)8UGi4LrLmKbPSVWTLB)aoCAeyGtIJsYb00zv8aXCfQL4vl1goykQKjGyGbZdig5OtzIhKsDsDyAxmjkGZQdhK6aiFcoWGdtic(5kII(fisA9RJPernvie)lgyvdru0xgge1A)8Myd2HhedWaPtPEoIBvqKmIhjtLvZYGu2x42YTFaho1(6evN7SkEWdig54MEbwjknmc9lCZbqH5beJC7RtuDo(qXHScuphLbPSVWTLB)aoCktBg5KEaX4zTAshSVoo8GCwfp4beJC7RJdpi8Hm1QT(ComHEaXiNyUc1ssl2PdFitTARXNlk6beJCI5kuljDaTo8Hm1QTgFUbyQ9h1jrX(PX4af8miL9fUTC7hWHtTVowGbcDwfpWWGOw7N3febVmQemq6uQNJ4mCdcdgjrilCndgdJDiy)nNHBqyWi5lGKw0AQ3YhYuR26degc3unYXyu5eQ2FuNef7NMJdfWnKbPSVWTLB)aoCQ91jQo3zv8WRoQFU9jNthjYuXNtT65iey((QJ6NBFDC4bHtT65ieyEaXi3(6evNJpuCiRa1ZrWe6beJCI5kuljDaTo8Hm1QTghiWiMRqTeVAPdO1bMhqmYrNYepiL6K6W0UysuaNvhoi1bq(e85Glk6beJC0PmXdsPoPomTlMefWz1HdsDaKXhc(CWHP2FuNef7NgJduWffrWpxru0VarsRFDmLiQPcH4dzQvBn(iffv2x4MRik6xGiP1VoMse1uHq8QLrxbrWBaMVmm2HG93CMkRMXhsrGldszFHBl3(bC4u7RJfyGqNvXdEaXih30lWkzoshjOYw4MdGkk6beJCWQgziejzII9tJj1VKAAGuhL4aOIIEaXiNPYQzCauyc9aIr(OGOgdyLXH6JchFitTARpqyiCt1ihJrLtOA)rDsuSFAooua3ampGyKpkiQXawzCO(OWXbqff91dig5JcIAmGvghQpkCCauy(YWyhc2FZhfe1yaRmouFu44dPiWjk6lddIATFoiQFbWngefv7pQtII9tJXbk4WiMRqTeVAP2WLbPSVWTLB)aoCQ91XcmqOZQ4HxDu)C7RJdpiCQvphHatOhqmYTVoo8GWbqffv7pQtII9tJXbk4gG5beJC7RJdpiC7RmW8bkWe6beJCI5kuljTyNoCaurrpGyKtmxHAjPdO1HdGAaMhqmYrNYepiL6K6W0UysuaNvhoi1bq(emuhCyczySdb7V5mvwnJpKPwT1yObxu0xq6uQNJ4mCdcdgjrilCndgddIATFExqe8YOsgYGu2x42YTFaho1(6ybgi0zv8GqpGyKJoLjEqk1j1HPDXKOaoRoCqQdG8jyOo4IIEaXihDkt8GuQtQdt7IjrbCwD4Guha5tWNdoSxDu)C7toNosKPIpNA1ZrigG5beJCI5kuljTyNo8Hm1QTgd1HrmxHAjE1sl2PdmF9aIroUPxGvIsdJq)c3Cauy((QJ6NBFDC4bHtT65ieymm2HG93CMkRMXhYuR2AmuhMqgg7qW(BoyvJmeI0Iwt9w(qMA1wJH6II(YWGOw7NdgCtPTHmiL9fUTC7hWHtBYV0eJ7ZQ4bHEaXiNyUc1sshqRdhavuuitGoqi7HGHnetGoqi5xMKpNBquKjqhiK9aumatrLmbedmyG0PuphXTkisgXJKPYQzzqk7lCB52pGdNkqDrPjg3NvXdc9aIroXCfQLKoGwhoakmFzyquR9ZbdUP0wuuOhqmYbRAKHqKKjk2pnMu)sQPbsDuIdGcJHbrT2phm4MsBdIIczc0bczpemSHyc0bcj)YK85CdIImb6aHShGIOOhqmYzQSAgha1amfvYeqmWGbsNs9Ce3QGizepsMkRMLbPSVWTLB)aoCAeW5KMyCFwfpi0dig5eZvOws6aAD4aOW8LHbrT2phm4MsBrrHEaXihSQrgcrsMOy)0ys9lPMgi1rjoakmgge1A)CWGBkTnikkKjqhiK9qWWgIjqhiK8ltYNZnikYeOdeYEakIIEaXiNPYQzCaudWuujtaXadgiDk1ZrCRcIKr8izQSAwgKY(c3wU9d4WP(1zk8iXrj5aAkdszFHBl3(bC4u7RtSg6SkEGyUc1s8QLoGwhrrI5kulXTyNoYMmYlksmxHAjU2WjBYiVOOhqmY9RZu4rIJsYb0ehafMhqmYjMRqTK0b06Wbqfff6beJCMkRMXhYuR26JY(c3C)J(c4KrigWtYVmjyEaXiNPYQzCaudzqk7lCB52pGdN6F0xqgKY(c3wU9d4WPdqlv2x4w6k7FwRM0HO6CVGb4gArj29eObp47F)7f]] )


end