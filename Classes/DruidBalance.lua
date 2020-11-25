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


    spec:RegisterPack( "Balance", 20201125, [[dCu(pdqiQk9ikKKlPcvBccFcKezue0POGvPcLxjaZsfv3cKK2fQ(LksddO6yqKLPc5zGetta11urzBui13ajvJtGIZjG06OqI5rvX9ub7Jc1bbjrTqiQEOaIjcscYfbjb1hbjH6KuiPALcKzkqPDQIyOGKalLcjLNkOPcr5RGKq2Rk9xIgSshM0IPkpgLjdQlJSzH(mignboTKxduMnvUnfTBP(nudhshhKuwUINtPPRQRdy7a57uvnEkeNhKA9cunFcTFrFr6ISBiS(09KJa)iWrcPJoJdEWeyOCwWCdFOrPBiQYatHq3WwnPBiYvN2m6gIQq7Wk8fz3qlgyy0nuW)OwJYPNcPEbaECg28uBzc40VWnB04FQTmzNEd9ak3BuVVE3qy9P7jhb(rGJeshDgh8GjWq5mO(nubEb45ggwMbYnuqbdt917gctw2n0OkxKRoTzuUqfAak4miJQCpbdIm9Oj3Jc855Ee4hbEgugKrvUbIaTHqwJsgKrvUq1CHkddtW5gID6KlYj1KNbzuLlun3arG2qi4CFDGqVSI5YulzZ9X5YGM5i5Rde6T8miJQCHQ5AuJmXGi4Cb6MyK1Qd05csNs9CKnxHfN4NNl6qGK2xhlWaHYfQACUOdbIBFDSadeYapdYOkxOAUqfQIrAO(l9PCbRA4HGLw0AQ3MBCWM5sMOy)0i9WnCUc9xoxUnrW5(4Chcuzjd8BORSV9ISBOhw)lYUNG0fz3qQvphbFr(nKn1ttP3qpGyKZuz1moa6nuzFH7B4OGOgdyLXH6Gd99VNC0fz3qQvphbFr(neJEdT0Fdv2x4(gcsNs9C0neK6aOBy0HXtUcZvyUv)0GID6tWYybrWlhYuR2Mlun3Japxd5EAUiDe45AixJZn6W4jxH5km3QFAqXo9jyzSGi4LdzQvBZfQM7rNLlunxH5Ie45ESCF1r9ZRMPtRFHBo1QNJGZ1qUq1CfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnK7P5IuWaEUgUHG0r2QjDdz4gegmsctwOB29VNaLlYUHuREoc(I8Big9gAP)gQSVW9neKoL65OBii1bq3qFZ1dig5EQtBgjXrP6CYxq1qSYwFGH4aO5IixFZ1dig5EQtBgjXrP6CYxq1qSsDyAtCa0BiiDKTAs3q2uFJFa07FpjWxKDdPw9Ce8f53qL9fUVHkSI(fisA9RJ5nKn1ttP3qpGyK7PoTzKehLQZjFbvdXkB9bgIBFLbMeK6aOC9j3adEUiY1dig5EQtBgjXrP6CYxq1qSsDyAtC7RmWKGuhaLRp5gyWZfrUcZ13CHXpxHv0VarsRFDmLWQPcH4FXaRAi5IixFZvzFHBUcROFbIKw)6ykHvtfcXRwgDfebFUiYvyU(Mlm(5kSI(fisA9RJPuaPo(xmWQgsUII5cJFUcROFbIKw)6ykfqQJpKPwTnxJZfk5AixrXCHXpxHv0VarsRFDmLWQPcH42xzGLRp5cLCrKlm(5kSI(fisA9RJPewnvieFitTABU(K7z5Iixy8Zvyf9lqK06xhtjSAQqi(xmWQgsUgUHmOzos(6aHE79eKU)9KZUi7gsT65i4lYVHSPEAk9gkmxq6uQNJ4mCdcdgjHjl0nlxe5w9tdk2PpblJfebVCitTABUgNlsqb8CrKRV5YWyhm2FZzQSAgFifg6CffZ1dig5mvwnJdGMRHCrKRWC9aIrUN60MrsCuQoN8funeRS1hyiU9vgysqQdGY9qUNbEUII56beJCp1PnJK4OuDo5lOAiwPomTjU9vgysqQdGY9qUNbEUgYvum3ybrWlhYuR2MRp5Ie43qL9fUVHmCdcdgjFbK0Iwt927FpXOVi7gsT65i4lYVHSPEAk9gkmxpGyK7PoTzKehLQZjFbvdXkB9bgIpKPwTnxJZnW8ZYvumxpGyK7PoTzKehLQZjFbvdXk1HPnXhYuR2MRX5gy(z5Aixe5Q2FuNef7NMCn(qUbk45IixH5YWyhm2FZzQSAgFitTABUgNlupxrXCfMldJDWy)nNmrX(Pr6HBy(qMA12CnoxOEUiY13C9aIroyvdpeSKmrX(PXK6xsnnqQGtCa0CrKlddIATFoyqpL25Aixd3qL9fUVHmTzKt6beJ3qpGyu2QjDdTVoo8aF)7jq9lYUHuREoc(I8BiBQNMsVH(MliDk1ZrC2uFJFa0CrKRWCzyquR9Z7cIGxgvkxrXCzySdg7V5mvwnJpKPwTnxJZfQNROyUcZLHXoyS)MtMOy)0i9WnmFitTABUgNlupxe56BUEaXihSQHhcwsMOy)0ys9lPMgivWjoaAUiYLHbrT2phmONs7CnKRHBOY(c33q7RJfyGq3)EsWCr2nKA1ZrWxKFdzt90u6nuyUmm2bJ93CgUbHbJKVasArRPElhanxe5kmxq6uQNJ4mCdcdgjHjl0nlxrXCzySdg7V5mvwnJpKPwTnxFY9SCnKRHCrKRA)rDsuSFAY14Cpd8CrKlddIATFExqe8YOs3qL9fUVH2xhlWaHU)9Ka9ISBi1QNJGVi)gQSVW9n0c0XAOBiBQNMsVHdfhYkq9CuUiY91bc98Vmj5JLWfLRX5IKrNlICfMRIkzcigy5IixH5csNs9CeNn134hanxrXCfMRA)rDsuSFAY1NCHc45IixFZ1dig5mvwnJdGMRHCffZLHXoyS)MZuz1m(qkm05Aixd3qg0mhjFDGqV9Ecs3)EcsGFr2nKA1ZrWxKFdv2x4(gAIXDSg6gYM6PP0B4qXHScuphLlICFDGqp)lts(yjCr5ACUibf(z5IixH5QOsMaIbwUiYvyUG0PuphXzt9n(bqZvumxH5Q2FuNef7NMC9jxOaEUiY13C9aIrotLvZ4aO5AixrXCzySdg7V5mvwnJpKcdDUgYfrU(MRhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGMRHBidAMJKVoqO3EpbP7FpbjKUi7gsT65i4lYVHk7lCFdTp5C6iJoDOBiBQNMsVHdfhYkq9CuUiY91bc98Vmj5JLWfLRX5IKrNBa5oKPwTnxe5kmxfvYeqmWYfrUcZfKoL65ioBQVXpaAUII5Q2FuNef7NMC9jxOaEUII5YWyhm2FZzQSAgFifg6CnKRHBidAMJKVoqO3EpbP7FpbPJUi7gsT65i4lYVHSPEAk9gQOsMaIb2nuzFH7ByepmsIJYwFGHU)9eKGYfz3qQvphbFr(nKn1ttP3qH5smxHAjE1sTHoxrXCjMRqTe3ID6iRwIuUII5smxHAjUdO1rwTePCnKlICfMRV5YWGOw7N3febVmQuUII5kmx1(J6KOy)0KRp5gONLlICfMliDk1ZrC2uFJFa0CffZvT)Oojk2pn56tUqb8CffZfKoL65iEzLkMY1qUiYvyUG0PuphXz4gegmsctwOBwUiY13CzySdg7V5mCdcdgjFbK0Iwt9woaAUII56BUG0PuphXz4gegmsctwOBwUiY13CzySdg7V5mvwnJdGMRHCnKRHCrKRWCzySdg7V5mvwnJpKPwTnxJZfkGNROyUQ9h1jrX(PjxJZnqbpxe5YWyhm2FZzQSAghanxe5kmxgg7GX(BozII9tJ0d3W8Hm1QT56tUk7lCZTVoXAiozeIb8K8ltkxrXC9nxgge1A)CWGEkTZ1qUII5w9tdk2PpblJfebVCitTABU(KlsGNRHCrKRWCHXpxHv0VarsRFDmLWQPcH4dzQvBZ14CdCUII56BUmmiQ1(5nXgSdpW5A4gQSVW9nmcmqlXrj5aA6(3tqkWxKDdPw9Ce8f53q2upnLEdfMlXCfQL4oGwhztg5ZvumxI5kulXTyNoYMmYNROyUeZvOwIRn0YMmYNROyUEaXi3tDAZijokvNt(cQgIv26dmeFitTABUgNBG5NLROyUEaXi3tDAZijokvNt(cQgIvQdtBIpKPwTnxJZnW8ZYvumx1(J6KOy)0KRX5gOGNlICzySdg7V5mvwnJpKcdDUgYfrUcZLHXoyS)MZuz1m(qMA12CnoxOaEUII5YWyhm2FZzQSAgFifg6CnKROyUv)0GID6tWYybrWlhYuR2MRp5Ie43qL9fUVHGvn8qWslAn1BV)9eKo7ISBi1QNJGVi)gYM6PP0BOWCv7pQtII9ttUgNBGcEUiYvyUEaXihSQHhcwsMOy)0ys9lPMgivWjoaAUII56BUmmiQ1(5Gb9uANRHCffZLHbrT2pVlicEzuPCffZ1dig5Eomg2byFoaAUiY1dig5Eomg2byF(qMA12C9j3Jap3aYvyUbo3JLld3Wa1ZrhIvwsQUcsBs9ZPw9CeCUgY1qUiYvyU(MlddIATFExqe8YOs5kkMldJDWy)nNHBqyWi5lGKw0AQ3YbqZvum3QFAqXo9jyzSGi4LdzQvBZ1NCzySdg7V5mCdcdgjFbK0Iwt9w(qMA12CdixJoxrXCR(Pbf70NGLXcIGxoKPwTn3JNlsbd456tUhbEUbKRWCdCUhlxgUHbQNJoeRSKuDfK2K6NtT65i4CnKRHBOY(c33qg5i7xQtQUcsBs9F)7jiz0xKDdPw9Ce8f53q2upnLEdfMRA)rDsuSFAY14CduWZfrUcZ1dig5Gvn8qWsYef7NgtQFj10aPcoXbqZvumxFZLHbrT2phmONs7CnKROyUmmiQ1(5DbrWlJkLROyUEaXi3ZHXWoa7ZbqZfrUEaXi3ZHXWoa7ZhYuR2MRp5cfWZnGCfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnKlICfMRV5YWGOw7N3febVmQuUII5YWyhm2FZz4gegms(ciPfTM6TCa0CffZfKoL65iod3GWGrsyYcDZYfrUv)0GID6tWYybrWlhYuR2MRX5IuWaEUbK7rGNBa5km3aN7XYLHByG65OdXkljvxbPnP(5uREocoxd5kkMB1pnOyN(eSmwqe8YHm1QT56tUmm2bJ93CgUbHbJKVasArRPElFitTABUbKRrNROyUv)0GID6tWYybrWlhYuR2MRp5cfWZnGCfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnCdv2x4(gwntNw)c33)Ecsq9lYUHuREoc(I8BiBQNMsVHmmiQ1(5DbrWlJkLlICfMliDk1ZrCgUbHbJKWKf6MLROyUmm2bJ93CMkRMXhYuR2MRp5Ie45Aixe5Q2FuNef7NMCno3Zapxe5YWyhm2FZz4gegms(ciPfTM6T8Hm1QT56tUib(nuzFH7BO91XcmqO7FpbPG5ISBi1QNJGVi)gIrVHw6VHk7lCFdbPtPEo6gcsDa0nKyUc1s8QLoGwNCpwUbtUNMRY(c3C7RtSgItgHyapj)YKYnGC9nxI5kulXRw6aADY9y5A05EAUk7lCZ9p6lGtgHyapj)YKYnGCbNFuUNMRfLCoPa1(0neKoYwnPBOArHkGMqID)7jifOxKDdPw9Ce8f53q2upnLEdfMB1pnOyN(eSmwqe8YHm1QT56tUboxrXCfMRhqmYhfe1yaRmouhCO5dzQvBZ1NCHWG5MQrY9y5YOYLRWCv7pQtII9ttUNMluapxd5IixpGyKpkiQXawzCOo4qZbqZ1qUgYvumxH5Q2FuNef7NMCdixq6uQNJ4QffQaAcjwUhlxpGyKtmxHAjPf70HpKPwTn3aYfg)8iWaTehLKdOj(xmWSYHm1QZ9y5Ee)SCnoxKoc8CffZvT)Oojk2pn5gqUG0PuphXvlkub0esSCpwUEaXiNyUc1sshqRdFitTABUbKlm(5rGbAjokjhqt8VyGzLdzQvN7XY9i(z5ACUiDe45Aixe5smxHAjE1sTHoxe5kmxH56BUmm2bJ93CMkRMXbqZvumxgge1A)CWGEkTZfrU(MldJDWy)nNmrX(Pr6HByoaAUgYvumxgge1A)8UGi4LrLY1qUiYvyU(MlddIATFoiQFbqp5kkMRV56beJCMkRMXbqZvumx1(J6KOy)0KRX5gOGNRHCffZ1dig5mvwnJpKPwTnxJZnyYfrU(MRhqmYhfe1yaRmouhCO5aO3qL9fUVH2xhlWaHU)9KJa)ISBi1QNJGVi)gYM6PP0BOWC9aIroXCfQLKoGwhoaAUII5kmxMaDGq2CpK7r5Ii3Hyc0bcj)YKY1NCplxd5kkMltGoqiBUhYfk5Aixe5QOsMaIb2nuzFH7Byt(LMyCF)7jhH0fz3qQvphbFr(nKn1ttP3qH56beJCI5kuljDaToCa0CffZvyUmb6aHS5Ei3JYfrUdXeOdes(LjLRp5EwUgYvumxMaDGq2CpKluY1qUiYvrLmbedSBOY(c33qbQlknX4((3to6OlYUHuREoc(I8BiBQNMsVHcZ1dig5eZvOws6aAD4aO5kkMRWCzc0bczZ9qUhLlIChIjqhiK8ltkxFY9SCnKROyUmb6aHS5EixOKRHCrKRIkzcigy3qL9fUVHraNtAIX99VNCeuUi7gQSVW9n0VotHhjokjhqt3qQvphbFr(9VNCuGVi7gsT65i4lYVHSPEAk9gsmxHAjE1shqRtUII5smxHAjUf70r2Kr(CffZLyUc1sCTHw2Kr(CffZ1dig5(1zk8iXrj5aAIdGMlICjMRqTeVAPdO1jxrXCfMRhqmYzQSAgFitTABU(KRY(c3C)J(c4KrigWtYVmPCrKRhqmYzQSAghanxd3qL9fUVH2xNyn09VNC0zxKDdv2x4(g6F0xWnKA1ZrWxKF)7jhz0xKDdPw9Ce8f53qL9fUVHdqlv2x4w6k7FdDL9LTAs3WO6CVGb4(3)gctrfW9xKDpbPlYUHk7lCFdTyNospsnVHuREoc(I87Fp5OlYUHuREoc(I8Big9gAP)gQSVW9neKoL65OBii1bq3qlk5CYxhi0B52xNO6C5ACUiLlICfMRV5(QJ6NBFDC4bMtT65i4CffZ9vh1p3(KZPJeEQ4ZPw9CeCUgYvumxlk5CYxhi0B52xNO6C5ACUhDdbPJSvt6gwwPIP7FpbkxKDdPw9Ce8f53qm6n0s)nuzFH7BiiDk1Zr3qqQdGUHwuY5KVoqO3YTVoXAOCnoxKUHG0r2QjDdlRK5ifeD)7jb(ISBi1QNJGVi)gYM6PP0BOWC9nxgge1A)8UGi4LrLYvumxFZLHXoyS)MZWnimyK8fqslAn1B5aO5Aixe56beJCMkRMXbqVHk7lCFd9OXsdyvd5(3to7ISBi1QNJGVi)gYM6PP0BOhqmYzQSAgha9gQSVW9nef)fUV)9eJ(ISBOY(c33qaljRNmT3qQvphbFr(9VNa1Vi7gsT65i4lYVHSPEAk9g6iqKlxFY9mKUHk7lCFdfq68sYAPMr3)EsWCr2nKA1ZrWxKFdzt90u6neKoL65iEzLkMUH2Fk2FpbPBOY(c33WbOLk7lClDL9VHUY(YwnPBOIP7FpjqVi7gsT65i4lYVHSPEAk9goanfXdeI)Lj5hpTeEi10RAyA4eudOqrj4BO9NI93tq6gQSVW9nCaAPY(c3sxz)BORSVSvt6gcpKA6vnmn3)EcsGFr2nKA1ZrWxKFdzt90u6nCaAkIhie3tDAZijokvNt(cQgILtqnGcfLGVH2Fk2FpbPBOY(c33WbOLk7lClDL9VHUY(YwnPBOhw)7FpbjKUi7gsT65i4lYVHk7lCFdhGwQSVWT0v2)g6k7lB1KUH2)(3)gIoedB6P)fz3tq6ISBOY(c33qtmUbRAzepM3qQvphbFr(9VNC0fz3qL9fUVHGvn8qWslAn1BVHuREoc(I87FpbkxKDdPw9Ce8f53qL9fUVH(h9fCdDvtsg8nejWV)9KaFr2nKA1ZrWxKFdzt90u6neDiqCK4(h9fKlIC9nx0HaXpI7F0xWnuzFH7BO)rFb3)EYzxKDdv2x4(gAFDI1q3qQvphbFr(9VNy0xKDdPw9Ce8f53qm6n0s)nuzFH7BiiDk1Zr3qqQdGUHEyRnxe5gDy8KRWCfMBSGi4LdzQvBZfQM7rGNRHCpnxKoc8CnKRX5gDy8KRWCfMBSGi4LdzQvBZfQM7rNLlunxH5Ie45ESCF1r9ZRMPtRFHBo1QNJGZ1qUq1CfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnK7P5IuWaEUgUHG0r2QjDdz4gegmsctwOB29V)nuX0fz3tq6ISBi1QNJGVi)gIrVHw6VHk7lCFdbPtPEo6gcsDa0nuyUEaXi)ltYpEAj8qQPx1W0WhYuR2MRp5cHbZnvJKBa5cohPCffZ1dig5Fzs(XtlHhsn9QgMg(qMA12C9jxL9fU52xNyneNmcXaEs(LjLBa5cohPCrKRWCjMRqTeVAPdO1jxrXCjMRqTe3ID6iBYiFUII5smxHAjU2qlBYiFUgY1qUiY1dig5Fzs(XtlHhsn9QgMgoaAUiYDaAkIhie)ltYpEAj8qQPx1W0WjOgqHIsW3qq6iB1KUHWdPMs)LZjJQZjXX49VNC0fz3qQvphbFr(nKn1ttP3qpGyKBFDIQZXhkoKvG65OCrKRWCTOKZjFDGqVLBFDIQZLRp5cLCffZ13ChGMI4bcX)YK8JNwcpKA6vnmnCcQbuOOeCUgYfrUcZ13ChGMI4bcXDqZ0rTYOJOVAisiUYe1sCcQbuOOeCUII5(LjL7XZnWNLRX56beJC7RtuDo(qMA12Cdi3JY1WnuzFH7BO91jQo39VNaLlYUHuREoc(I8BiBQNMsVHdqtr8aH4Fzs(XtlHhsn9QgMgob1akuucoxe5ArjNt(6aHEl3(6evNlxJpKluYfrUcZ13C9aIr(xMKF80s4HutVQHPHdGMlIC9aIrU91jQohFO4qwbQNJYvumxH5csNs9CehEi1u6VCozuDojogZfrUcZ1dig52xNO6C8Hm1QT56tUqjxrXCTOKZjFDGqVLBFDIQZLRX5EuUiY9vh1p3(KZPJeEQ4ZPw9CeCUiY1dig52xNO6C8Hm1QT56tUNLRHCnKRHBOY(c33q7RtuDU7FpjWxKDdPw9Ce8f53qm6n0s)nuzFH7BiiDk1Zr3qqQdGUHQ9h1jrX(PjxJZnyapxOAUcZfjWZ9y56beJ8Vmj)4PLWdPMEvdtd3(kdSCnKlunxH56beJC7RtuDo(qMA12CpwUqj3tZ1IsoNuGAFkxd5cvZvyUW4NhbgOL4OKCanXhYuR2M7XY9SCnKlIC9aIrU91jQohha9gcshzRM0n0(6evNt6h3VmQoNehJ3)EYzxKDdPw9Ce8f53q2upnLEdbPtPEoIdpKAk9xoNmQoNehJ5Iixq6uQNJ42xNO6Cs)4(Lr15K4y8gQSVW9n0(6ybgi09VNy0xKDdPw9Ce8f53qL9fUVHwGowdDdzt90u6nCO4qwbQNJYfrUVoqON)LjjFSeUOCnoxKcCUq1CTOKZjFDGqVn3aYDitTABUiYvrLmbedSCrKlXCfQL4vl1g6BidAMJKVoqO3EpbP7FpbQFr2nKA1ZrWxKFdv2x4(gQWk6xGiP1VoM3q2upnLEd9n3VyGvnKCrKRV5QSVWnxHv0VarsRFDmLWQPcH4vlJUcIGpxrXCHXpxHv0VarsRFDmLWQPcH42xzGLRp5cLCrKlm(5kSI(fisA9RJPewnvieFitTABU(KluUHmOzos(6aHE79eKU)9KG5ISBi1QNJGVi)gQSVW9n0eJ7yn0nKn1ttP3WHIdzfOEokxe5(6aHE(xMK8Xs4IY14CfMlsbo3aYvyUwuY5KVoqO3YTVoXAOCpwUiXplxd5Ai3tZ1IsoN81bc92Cdi3Hm1QT5IixH5kmxgg7GX(BotLvZ4dPWqNROyUwuY5KVoqO3YTVoXAOC9jxOKROyUcZLyUc1s8QLwStNCffZLyUc1s8QLE4xqUII5smxHAjE1shqRtUiY13CF1r9ZTyaNehLVasgXdzFo1QNJGZvumxpGyKJoLjEGl1j1HPDXKOaoRoCqQdGY14d5E0zGNRHCrKRWCTOKZjFDGqVLBFDI1q56tUibEUhlxH5IuUbK7RoQF(7VAPjg3wo1QNJGZ1qUgYfrUQ9h1jrX(PjxJZ9mWZfQMRhqmYTVor154dzQvBZ9y5A05Aixe56BUEaXihSQHhcwsMOy)0ys9lPMgivWjoaAUiYvrLmbedSCnCdzqZCK81bc927jiD)7jb6fz3qQvphbFr(nKn1ttP3qH5csNs9CeNHBqyWijmzHUz5Ii3QFAqXo9jyzSGi4LdzQvBZ14CrckGNlIC9nxgg7GX(BotLvZ4dPWqNROyUEaXiNPYQzCa0CnKlICv7pQtII9ttU(K7zGNlICfMRhqmYjMRqTK0b06WhYuR2MRX5A05kkMRhqmYjMRqTK0ID6WhYuR2MRX5g4CnKROyUXcIGxoKPwTnxFYfjWVHk7lCFdz4gegms(ciPfTM6T3)EcsGFr2nKA1ZrWxKFdzt90u6nurLmbedSBOY(c33WiEyKehLT(adD)7jiH0fz3qQvphbFr(nKn1ttP3qpGyKZuz1moa6nuzFH7B4OGOgdyLXH6Gd99VNG0rxKDdPw9Ce8f53q2upnLEdfMRhqmYTVor154aO5kkMRA)rDsuSFAY14Cpd8CnKlIC9nxpGyKBXo7xmIdGMlIC9nxpGyKZuz1moaAUiYvyU(MlddIATFExqe8YOs5kkMldJDWy)nNHBqyWi5lGKw0AQ3YbqZvum3QFAqXo9jyzSGi4LdzQvBZ1NCzySdg7V5mCdcdgjFbK0Iwt9w(qMA12CdixJoxrXCR(Pbf70NGLXcIGxoKPwTn3JNlsbd456tUhbEUbKRWCdCUhlxgUHbQNJoeRSKuDfK2K6NtT65i4CnKRHBOY(c33qg5i7xQtQUcsBs9F)7jibLlYUHuREoc(I8BiBQNMsVHcZ1dig52xNO6CCa0CffZvT)Oojk2pn5ACUNbEUgYfrU(MRhqmYTyN9lgXbqZfrU(MRhqmYzQSAghanxe5kmxFZLHbrT2pVlicEzuPCffZLHXoyS)MZWnimyK8fqslAn1B5aO5kkMB1pnOyN(eSmwqe8YHm1QT56tUmm2bJ93CgUbHbJKVasArRPElFitTABUbKRrNROyUv)0GID6tWYybrWlhYuR2M7XZfPGb8C9jxOaEUbKRWCdCUhlxgUHbQNJoeRSKuDfK2K6NtT65i4CnKRHBOY(c33WQz606x4((3tqkWxKDdPw9Ce8f53q2upnLEdR(Pbf70NGLXcIGxoKPwTnxFYfPZYvumxH56beJC0PmXdCPoPomTlMefWz1HdsDauU(K7rNbEUII56beJC0PmXdCPoPomTlMefWz1HdsDauUgFi3Jod8CnKlIC9aIrU91jQohhanxe5YWyhm2FZzQSAgFitTABUgN7zGFdv2x4(gsMOy)0i9Wn89VNG0zxKDdPw9Ce8f53qL9fUVH2NCoDKrNo0nKn1ttP3WHIdzfOEokxe5(LjjFSeUOCnoxKolxe5ArjNt(6aHEl3(6eRHY1NCdCUiYvrLmbedSCrKRWC9aIrotLvZ4dzQvBZ14Crc8CffZ13C9aIrotLvZ4aO5A4gYGM5i5Rde6T3tq6(3tqYOVi7gsT65i4lYVHSPEAk9gsmxHAjE1sTHoxe5QOsMaIbwUiY1dig5OtzIh4sDsDyAxmjkGZQdhK6aOC9j3Jod8CrKRWCHXpxHv0VarsRFDmLWQPcH4FXaRAi5kkMRV5YWGOw7N3eBWo8aNROyUwuY5KVoqO3MRX5EuUgUHk7lCFdJad0sCusoGMU)9eKG6xKDdPw9Ce8f53q2upnLEd9aIroUPxGvIsdJq)c3Ca0CrKRWC9aIrU91jQohFO4qwbQNJYvumx1(J6KOy)0KRX5gOGNRHBOY(c33q7RtuDU7FpbPG5ISBi1QNJGVi)gYM6PP0BiddIATFExqe8YOs5IixH5csNs9CeNHBqyWijmzHUz5kkMldJDWy)nNPYQzCa0CffZ1dig5mvwnJdGMRHCrKldJDWy)nNHBqyWi5lGKw0AQ3YhYuR2MRp5cHbZnvJK7XYLrLlxH5Q2FuNef7NMCpn3Zapxd5IixpGyKBFDIQZXhYuR2MRp5g4BOY(c33q7RtuDU7FpbPa9ISBi1QNJGVi)gYM6PP0BiddIATFExqe8YOs5IixH5csNs9CeNHBqyWijmzHUz5kkMldJDWy)nNPYQzCa0CffZ1dig5mvwnJdGMRHCrKldJDWy)nNHBqyWi5lGKw0AQ3YhYuR2MRp5cHbZnvJK7XYLrLlxH5Q2FuNef7NMCpnxOaEUgYfrUEaXi3(6evNJdGMlICjMRqTeVAP2qFdv2x4(gAFDSade6(3toc8lYUHuREoc(I8BiBQNMsVHEaXih30lWkzoshjOYw4MdGMROyUcZ13CTVoXAiUIkzcigy5kkMRWC9aIrotLvZ4dzQvBZ1NCplxe56beJCMkRMXbqZvumxH56beJ8rbrngWkJd1bhA(qMA12C9jximyUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1qUiY1dig5JcIAmGvghQdo0Ca0CnKRHCrKliDk1ZrC7RtuDoPFC)YO6CsCmMlICTOKZjFDGqVLBFDIQZLRp5cLCnKlICfMRV5oanfXdeI)Lj5hpTeEi10RAyA4eudOqrj4CffZ1IsoN81bc9wU91jQoxU(KluY1WnuzFH7BO91XcmqO7Fp5iKUi7gsT65i4lYVHSPEAk9gkmxI5kulXRwQn05Iixgg7GX(BotLvZ4dzQvBZ14Cpd8CffZvyUmb6aHS5Ei3JYfrUdXeOdes(LjLRp5EwUgYvumxMaDGq2CpKluY1qUiYvrLmbedSBOY(c33WM8lnX4((3to6OlYUHuREoc(I8BiBQNMsVHcZLyUc1s8QLAdDUiYLHXoyS)MZuz1m(qMA12Cno3ZapxrXCfMltGoqiBUhY9OCrK7qmb6aHKFzs56tUNLRHCffZLjqhiKn3d5cLCnKlICvujtaXa7gQSVW9nuG6IstmUV)9KJGYfz3qQvphbFr(nKn1ttP3qH5smxHAjE1sTHoxe5YWyhm2FZzQSAgFitTABUgN7zGNROyUcZLjqhiKn3d5EuUiYDiMaDGqYVmPC9j3ZY1qUII5YeOdeYM7HCHsUgYfrUkQKjGyGDdv2x4(ggbCoPjg33)EYrb(ISBOY(c33q)6mfEK4OKCanDdPw9Ce8f53)EYrNDr2nKA1ZrWxKFdXO3ql93qL9fUVHG0PuphDdbPoa6gArjNt(6aHEl3(6eRHY14CdCUbKB0HXtUcZ1uTpnqlbPoak3tZ9iWZ1qUbKB0HXtUcZ1dig52xhlWaHKKjk2pnMu)sl2Pd3(kdSCpn3aNRHBiiDKTAs3q7RtSgswT0ID6C)7jhz0xKDdPw9Ce8f53q2upnLEdjMRqTe3b06iBYiFUII5smxHAjU2qlBYiFUiYfKoL65iEzLmhPGOCffZ1dig5eZvOwsAXoD4dzQvBZ1NCv2x4MBFDI1qCYied4j5xMuUiY1dig5eZvOwsAXoD4aO5kkMlXCfQL4vlTyNo5IixFZfKoL65iU91jwdjRwAXoDYvumxpGyKZuz1m(qMA12C9jxL9fU52xNyneNmcXaEs(LjLlIC9nxq6uQNJ4LvYCKcIYfrUEaXiNPYQz8Hm1QT56tUKrigWtYVmPCrKRhqmYzQSAghanxrXC9aIr(OGOgdyLXH6Gdnhanxe5ArjNtkqTpLRX5co3OZfrUcZ1IsoN81bc92C95qUqjxrXC9n3xDu)ClgWjXr5lGKr8q2NtT65i4CnKROyU(MliDk1Zr8Ykzosbr5IixpGyKZuz1m(qMA12CnoxYied4j5xM0nuzFH7BO)rFb3)EYrq9lYUHk7lCFdTVoXAOBi1QNJGVi)(3tokyUi7gsT65i4lYVHk7lCFdhGwQSVWT0v2)g6k7lB1KUHr15EbdW9V)nmQo3lyaUi7EcsxKDdPw9Ce8f53q2upnLEd9n3bOPiEGqCp1PnJK4OuDo5lOAiwob1akuuc(gQSVW9n0(6ybgi09VNC0fz3qQvphbFr(nuzFH7BOfOJ1q3q2upnLEdHXp3eJ7yneFitTABUgN7qMA12BidAMJKVoqO3EpbP7FpbkxKDdv2x4(gAIXDSg6gsT65i4lYV)9VH2)IS7jiDr2nKA1ZrWxKFdv2x4(gQWk6xGiP1VoM3q2upnLEd9nxy8Zvyf9lqK06xhtjSAQqi(xmWQgsUiY13Cv2x4MRWk6xGiP1VoMsy1uHq8QLrxbrWNlICfMRV5cJFUcROFbIKw)6ykfqQJ)fdSQHKROyUW4NRWk6xGiP1VoMsbK64dzQvBZ14Cplxd5kkMlm(5kSI(fisA9RJPewnvie3(kdSC9jxOKlICHXpxHv0VarsRFDmLWQPcH4dzQvBZ1NCHsUiYfg)Cfwr)cejT(1XucRMkeI)fdSQHCdzqZCK81bc927jiD)7jhDr2nKA1ZrWxKFdzt90u6nuyUG0PuphXz4gegmsctwOBwUiYT6NguStFcwglicE5qMA12CnoxKGc45IixFZLHXoyS)MZuz1m(qkm05kkMRhqmYzQSAghanxd5Iix1(J6KOy)0KRp5Eg45IixH56beJCI5kuljDaTo8Hm1QT5ACUibEUII56beJCI5kuljTyNo8Hm1QT5ACUibEUgYvum3ybrWlhYuR2MRp5Ie43qL9fUVHmCdcdgjFbK0Iwt927FpbkxKDdPw9Ce8f53qm6n0s)nuzFH7BiiDk1Zr3qqQdGUHcZ1dig5mvwnJpKPwTnxJZ9SCrKRWC9aIr(OGOgdyLXH6GdnFitTABUgN7z5kkMRV56beJ8rbrngWkJd1bhAoaAUgYvumxFZ1dig5mvwnJdGMROyUQ9h1jrX(PjxFYfkGNRHCrKRWC9nxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxrXCv7pQtII9ttU(Kluapxd5IixH56beJCI5kuljTyNo8Hm1QT5ACUqyWCt1i5kkMRhqmYjMRqTK0b06WhYuR2MRX5cHbZnvJKRHBiiDKTAs3qy8lhcQbudzs9BV)9KaFr2nKA1ZrWxKFdv2x4(gAIXDSg6gYM6PP0B4qXHScuphLlICFDGqp)lts(yjCr5ACUiDuUiYvyUkQKjGyGLlICbPtPEoIdJF5qqnGAitQFBUgUHmOzos(6aHE79eKU)9KZUi7gsT65i4lYVHk7lCFdTaDSg6gYM6PP0B4qXHScuphLlICFDGqp)lts(yjCr5ACUiDuUiYvyUkQKjGyGLlICbPtPEoIdJF5qqnGAitQFBUgUHmOzos(6aHE79eKU)9eJ(ISBi1QNJGVi)gQSVW9n0(KZPJm60HUHSPEAk9gouCiRa1Zr5Ii3xhi0Z)YKKpwcxuUgNlsgDUiYvyUkQKjGyGLlICbPtPEoIdJF5qqnGAitQFBUgUHmOzos(6aHE79eKU)9eO(fz3qQvphbFr(nKn1ttP3qfvYeqmWUHk7lCFdJ4HrsCu26dm09VNemxKDdPw9Ce8f53q2upnLEd9aIrotLvZ4aO3qL9fUVHJcIAmGvghQdo03)EsGEr2nKA1ZrWxKFdzt90u6nuyUcZ1dig5eZvOwsAXoD4dzQvBZ14Crc8CffZ1dig5eZvOws6aAD4dzQvBZ14Crc8CnKlICzySdg7V5mvwnJpKPwTnxJZfkGNlICfMRhqmYrNYepWL6K6W0UysuaNvhoi1bq56tUhfyWZvumxFZDaAkIhiehDkt8axQtQdt7IjrbCwD4eudOqrj4CnKRHCffZ1dig5OtzIh4sDsDyAxmjkGZQdhK6aOCn(qUhb1bpxrXCzySdg7V5mvwnJpKcdDUiYvyUQ9h1jrX(PjxJZnqbpxrXCbPtPEoIxwPIPCnCdv2x4(gsMOy)0i9Wn89VNGe4xKDdPw9Ce8f53q2upnLEdfMRA)rDsuSFAY14CduWZfrUcZ1dig5Gvn8qWsYef7NgtQFj10aPcoXbqZvumxFZLHbrT2phmONs7CnKROyUmmiQ1(5DbrWlJkLROyUG0PuphXlRuXuUII56beJCphgd7aSphanxe56beJCphgd7aSpFitTABU(K7rGNBa5kmxH5gO5ESChGMI4bcXrNYepWL6K6W0UysuaNvhob1akuucoxd5gqUcZnW5ESCz4ggOEo6qSYss1vqAtQFo1QNJGZ1qUgY1qUiY13C9aIrotLvZ4aO5IixH56BUmmiQ1(5DbrWlJkLROyUmm2bJ93CgUbHbJKVasArRPElhanxrXCR(Pbf70NGLXcIGxoKPwTnxFYLHXoyS)MZWnimyK8fqslAn1B5dzQvBZnGCn6CffZT6NguStFcwglicE5qMA12CpEUifmGNRp5Ee45gqUcZnW5ESCz4ggOEo6qSYss1vqAtQFo1QNJGZ1qUgUHk7lCFdzKJSFPoP6kiTj1)9VNGesxKDdPw9Ce8f53q2upnLEdfMRA)rDsuSFAY14CduWZfrUcZ1dig5Gvn8qWsYef7NgtQFj10aPcoXbqZvumxFZLHbrT2phmONs7CnKROyUmmiQ1(5DbrWlJkLROyUG0PuphXlRuXuUII56beJCphgd7aSphanxe56beJCphgd7aSpFitTABU(Kluap3aYvyUcZnqZ9y5oanfXdeIJoLjEGl1j1HPDXKOaoRoCcQbuOOeCUgYnGCfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnKRHCrKRV56beJCMkRMXbqZfrUcZ13CzyquR9Z7cIGxgvkxrXCzySdg7V5mCdcdgjFbK0Iwt9woaAUII5w9tdk2PpblJfebVCitTABU(KldJDWy)nNHBqyWi5lGKw0AQ3YhYuR2MBa5A05kkMB1pnOyN(eSmwqe8YHm1QT5E8CrkyapxFYfkGNBa5km3aN7XYLHByG65OdXkljvxbPnP(5uREocoxd5A4gQSVW9nSAMoT(fUV)9eKo6ISBi1QNJGVi)gIrVHw6VHk7lCFdbPtPEo6gcsDa0nuyU(MldJDWy)nNPYQz8HuyOZvumxFZfKoL65iod3GWGrsyYcDZYfrUmmiQ1(5DbrWlJkLRHBiiDKTAs3qRcIKr8izQSA29VNGeuUi7gsT65i4lYVHSPEAk9gsmxHAjE1sTHoxe5QOsMaIbwUiY1dig5OtzIh4sDsDyAxmjkGZQdhK6aOC9j3Jcm45IixH5cJFUcROFbIKw)6ykHvtfcX)Ibw1qYvumxFZLHbrT2pVj2GD4boxd5Iixq6uQNJ4wfejJ4rYuz1SBOY(c33WiWaTehLKdOP7FpbPaFr2nKA1ZrWxKFdzt90u6n0dig54MEbwjknmc9lCZbqZfrUEaXi3(6evNJpuCiRa1Zr3qL9fUVH2xNO6C3)EcsNDr2nKA1ZrWxKFdzt90u6n0dig52xhhEG5dzQvBZ1NCplxe5kmxpGyKtmxHAjPf70HpKPwTnxJZ9SCffZ1dig5eZvOws6aAD4dzQvBZ14Cplxd5Iix1(J6KOy)0KRX5gOGFdv2x4(gY0MroPhqmEd9aIrzRM0n0(64Wd89VNGKrFr2nKA1ZrWxKFdzt90u6nKHbrT2pVlicEzuPCrKliDk1ZrCgUbHbJKWKf6MLlICzySdg7V5mCdcdgjFbK0Iwt9w(qMA12C9jximyUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1WnuzFH7BO91XcmqO7FpbjO(fz3qQvphbFr(nKn1ttP3WxDu)C7toNos4PIpNA1ZrW5IixFZ9vh1p3(64WdmNA1ZrW5IixpGyKBFDIQZXhkoKvG65OCrKRWC9aIroXCfQLKoGwh(qMA12CnoxJoxe5smxHAjE1shqRtUiY1dig5OtzIh4sDsDyAxmjkGZQdhK6aOC9j3Jod8CffZ1dig5OtzIh4sDsDyAxmjkGZQdhK6aOCn(qUhDg45Iix1(J6KOy)0KRX5gOGNROyUW4NRWk6xGiP1VoMsy1uHq8Hm1QT5ACUbtUII5QSVWnxHv0VarsRFDmLWQPcH4vlJUcIGpxd5IixFZLHXoyS)MZuz1m(qkm03qL9fUVH2xNO6C3)EcsbZfz3qQvphbFr(nKn1ttP3qpGyKJB6fyLmhPJeuzlCZbqZvumxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxrXC9aIrotLvZ4aO5IixH56beJ8rbrngWkJd1bhA(qMA12C9jximyUPAKCpwUmQC5kmx1(J6KOy)0K7P5cfWZ1qUiY1dig5JcIAmGvghQdo0Ca0CffZ13C9aIr(OGOgdyLXH6Gdnhanxe56BUmm2bJ938rbrngWkJd1bhA(qkm05kkMRV5YWGOw7NdI6xa0tUgYvumx1(J6KOy)0KRX5gOGNlICjMRqTeVAP2qFdv2x4(gAFDSade6(3tqkqVi7gsT65i4lYVHSPEAk9g(QJ6NBFDC4bMtT65i4CrKRWC9aIrU91XHhyoaAUII5Q2FuNef7NMCno3af8CnKlIC9aIrU91XHhyU9vgy56tUqjxe5kmxpGyKtmxHAjPf70HdGMROyUEaXiNyUc1sshqRdhanxd5IixpGyKJoLjEGl1j1HPDXKOaoRoCqQdGY1NCpcQdEUiYvyUmm2bJ93CMkRMXhYuR2MRX5Ie45kkMRV5csNs9CeNHBqyWijmzHUz5Iixgge1A)8UGi4LrLY1WnuzFH7BO91XcmqO7Fp5iWVi7gsT65i4lYVHSPEAk9gkmxpGyKJoLjEGl1j1HPDXKOaoRoCqQdGY1NCpcQdEUII56beJC0PmXdCPoPomTlMefWz1HdsDauU(K7rNbEUiY9vh1p3(KZPJeEQ4ZPw9CeCUgYfrUEaXiNyUc1ssl2PdFitTABUgNlupxe5smxHAjE1sl2PtUiY13C9aIroUPxGvIsdJq)c3Ca0CrKRV5(QJ6NBFDC4bMtT65i4CrKldJDWy)nNPYQz8Hm1QT5ACUq9CrKRWCzySdg7V5Gvn8qWslAn1B5dzQvBZ14CH65kkMRV5YWGOw7Ndg0tPDUgUHk7lCFdTVowGbcD)7jhH0fz3qQvphbFr(nKn1ttP3qH56beJCI5kuljDaToCa0CffZvyUmb6aHS5Ei3JYfrUdXeOdes(LjLRp5EwUgYvumxMaDGq2CpKluY1qUiYvrLmbedSCrKliDk1ZrCRcIKr8izQSA2nuzFH7Byt(LMyCF)7jhD0fz3qQvphbFr(nKn1ttP3qH56beJCI5kuljDaToCa0CrKRV5YWGOw7Ndg0tPDUII5kmxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxe5YWGOw7Ndg0tPDUgYvumxH5YeOdeYM7HCpkxe5oetGoqi5xMuU(K7z5AixrXCzc0bczZ9qUqjxrXC9aIrotLvZ4aO5Aixe5QOsMaIbwUiYfKoL65iUvbrYiEKmvwn7gQSVW9nuG6IstmUV)9KJGYfz3qQvphbFr(nKn1ttP3qH56beJCI5kuljDaToCa0CrKRV5YWGOw7Ndg0tPDUII5kmxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxe5YWGOw7Ndg0tPDUgYvumxH5YeOdeYM7HCpkxe5oetGoqi5xMuU(K7z5AixrXCzc0bczZ9qUqjxrXC9aIrotLvZ4aO5Aixe5QOsMaIbwUiYfKoL65iUvbrYiEKmvwn7gQSVW9nmc4CstmUV)9KJc8fz3qL9fUVH(1zk8iXrj5aA6gsT65i4lYV)9KJo7ISBi1QNJGVi)gYM6PP0BiXCfQL4vlDaTo5kkMlXCfQL4wSthztg5ZvumxI5kulX1gAztg5ZvumxpGyK7xNPWJehLKdOjoaAUiY1dig5eZvOws6aAD4aO5kkMRWC9aIrotLvZ4dzQvBZ1NCv2x4M7F0xaNmcXaEs(LjLlIC9aIrotLvZ4aO5A4gQSVW9n0(6eRHU)9KJm6lYUHk7lCFd9p6l4gsT65i4lYV)9KJG6xKDdPw9Ce8f53qL9fUVHdqlv2x4w6k7FdDL9LTAs3WO6CVGb4(3)gcpKA6vnmnxKDpbPlYUHuREoc(I8Big9gAP)gQSVW9neKoL65OBii1bq3qH56beJ8Vmj)4PLWdPMEvdtdFitTABUgNlegm3unsUbKl4CKYfrUcZLyUc1s8QLE4xqUII5smxHAjE1sl2PtUII5smxHAjUdO1r2Kr(CnKROyUEaXi)ltYpEAj8qQPx1W0WhYuR2MRX5QSVWn3(6eRH4KrigWtYVmPCdixW5iLlICfMlXCfQL4vlDaTo5kkMlXCfQL4wSthztg5ZvumxI5kulX1gAztg5Z1qUgYvumxFZ1dig5Fzs(XtlHhsn9QgMgoa6neKoYwnPBOvJK8XsaljTOKZD)7jhDr2nKA1ZrWxKFdzt90u6nuyU(MliDk1ZrCRgj5JLawsArjNlxrXCfMRhqmYhfe1yaRmouhCO5dzQvBZ1NCHWG5MQrY9y5YOYLRWCv7pQtII9ttUNMluapxd5IixpGyKpkiQXawzCOo4qZbqZ1qUgYvumx1(J6KOy)0KRX5gOGFdv2x4(gAFDSade6(3tGYfz3qQvphbFr(nKn1ttP3qH5csNs9CeNHBqyWijmzHUz5Ii3QFAqXo9jyzSGi4LdzQvBZ14CrckGNlIC9nxgg7GX(BotLvZ4dPWqNROyUEaXiNPYQzCa0CnKlICv7pQtII9ttU(KBGbpxe5kmxpGyKtmxHAjPdO1HpKPwTnxJZfjWZvumxpGyKtmxHAjPf70HpKPwTnxJZfjWZ1qUII5glicE5qMA12C9jxKa)gQSVW9nKHBqyWi5lGKw0AQ3E)7jb(ISBi1QNJGVi)gQSVW9nuHv0VarsRFDmVHSPEAk9g6BUW4NRWk6xGiP1VoMsy1uHq8VyGvnKCrKRV5QSVWnxHv0VarsRFDmLWQPcH4vlJUcIGpxe5kmxFZfg)Cfwr)cejT(1XukGuh)lgyvdjxrXCHXpxHv0VarsRFDmLci1XhYuR2MRX5EwUgYvumxy8Zvyf9lqK06xhtjSAQqiU9vgy56tUqjxe5cJFUcROFbIKw)6ykHvtfcXhYuR2MRp5cLCrKlm(5kSI(fisA9RJPewnvie)lgyvd5gYGM5i5Rde6T3tq6(3to7ISBi1QNJGVi)gQSVW9n0eJ7yn0nKn1ttP3WHIdzfOEokxe5(6aHE(xMK8Xs4IY14Cr6OCrKRWCfMRhqmYzQSAgFitTABUgN7z5IixH56beJ8rbrngWkJd1bhA(qMA12Cno3ZYvumxFZ1dig5JcIAmGvghQdo0Ca0CnKROyU(MRhqmYzQSAghanxrXCv7pQtII9ttU(Kluapxd5IixH56BUEaXihSQHhcwsMOy)0ys9lPMgivWjoaAUII5Q2FuNef7NMC9jxOaEUgYfrUkQKjGyGLRHBidAMJKVoqO3EpbP7FpXOVi7gsT65i4lYVHk7lCFdTaDSg6gYM6PP0B4qXHScuphLlICFDGqp)lts(yjCr5ACUiDuUiYvyUcZ1dig5mvwnJpKPwTnxJZ9SCrKRWC9aIr(OGOgdyLXH6GdnFitTABUgN7z5kkMRV56beJ8rbrngWkJd1bhAoaAUgYvumxFZ1dig5mvwnJdGMROyUQ9h1jrX(PjxFYfkGNRHCrKRWC9nxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxrXCv7pQtII9ttU(Kluapxd5IixfvYeqmWY1WnKbnZrYxhi0BVNG09VNa1Vi7gsT65i4lYVHk7lCFdTp5C6iJoDOBiBQNMsVHdfhYkq9CuUiY91bc98Vmj5JLWfLRX5IKrNlICfMRWC9aIrotLvZ4dzQvBZ14Cplxe5kmxpGyKpkiQXawzCOo4qZhYuR2MRX5EwUII56BUEaXiFuquJbSY4qDWHMdGMRHCffZ13C9aIrotLvZ4aO5kkMRA)rDsuSFAY1NCHc45Aixe5kmxFZ1dig5Gvn8qWsYef7NgtQFj10aPcoXbqZvumx1(J6KOy)0KRp5cfWZ1qUiYvrLmbedSCnCdzqZCK81bc927jiD)7jbZfz3qQvphbFr(nKn1ttP3qfvYeqmWUHk7lCFdJ4HrsCu26dm09VNeOxKDdPw9Ce8f53q2upnLEd9aIrotLvZ4aO3qL9fUVHJcIAmGvghQdo03)EcsGFr2nKA1ZrWxKFdzt90u6nuyUcZ1dig5eZvOwsAXoD4dzQvBZ14Crc8CffZ1dig5eZvOws6aAD4dzQvBZ14Crc8CnKlICzySdg7V5mvwnJpKPwTnxJZfkGNRHCffZLHXoyS)MZuz1m(qkm03qL9fUVHGvn8qWslAn1BV)9eKq6ISBi1QNJGVi)gYM6PP0BOWCfMRhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGMROyU(MlddIATFoyqpL25AixrXCzyquR9Z7cIGxgvkxrXCbPtPEoIxwPIPCffZ1dig5Eomg2byFoaAUiY1dig5Eomg2byF(qMA12C9j3Jap3aYvyUbo3JLld3Wa1ZrhIvwsQUcsBs9ZPw9CeCUgY1qUiY13C9aIrotLvZ4aO5IixH56BUmmiQ1(5DbrWlJkLROyUmm2bJ93CgUbHbJKVasArRPElhanxrXCR(Pbf70NGLXcIGxoKPwTnxFYLHXoyS)MZWnimyK8fqslAn1B5dzQvBZnGCn6CffZT6NguStFcwglicE5qMA12CpEUifmGNRp5Ee45gqUcZnW5ESCz4ggOEo6qSYss1vqAtQFo1QNJGZ1qUgUHk7lCFdzKJSFPoP6kiTj1)9VNG0rxKDdPw9Ce8f53q2upnLEdfMRWC9aIroyvdpeSKmrX(PXK6xsnnqQGtCa0CffZ13CzyquR9Zbd6P0oxd5kkMlddIATFExqe8YOs5kkMliDk1Zr8YkvmLROyUEaXi3ZHXWoa7ZbqZfrUEaXi3ZHXWoa7ZhYuR2MRp5cfWZnGCfMBGZ9y5YWnmq9C0HyLLKQRG0Mu)CQvphbNRHCnKlIC9nxpGyKZuz1moaAUiYvyU(MlddIATFExqe8YOs5kkMldJDWy)nNHBqyWi5lGKw0AQ3YbqZvum3QFAqXo9jyzSGi4LdzQvBZ1NCzySdg7V5mCdcdgjFbK0Iwt9w(qMA12CdixJoxrXCR(Pbf70NGLXcIGxoKPwTn3JNlsbd456tUqb8CdixH5g4CpwUmCdduphDiwzjP6kiTj1pNA1ZrW5Aixd3qL9fUVHvZ0P1VW99VNGeuUi7gsT65i4lYVHy0BOL(BOY(c33qq6uQNJUHGuhaDdfMRV5YWyhm2FZzQSAgFifg6CffZ13CbPtPEoIZWnimyKeMSq3SCrKlddIATFExqe8YOs5A4gcshzRM0n0QGizepsMkRMD)7jif4lYUHuREoc(I8BiBQNMsVHeZvOwIxTuBOZfrUkQKjGyGLlICfMlm(5kSI(fisA9RJPewnvie)lgyvdjxrXC9nxgge1A)8Myd2Hh4CnKlICbPtPEoIBvqKmIhjtLvZUHk7lCFdJad0sCusoGMU)9eKo7ISBi1QNJGVi)gYM6PP0BiddIATFExqe8YOs5Iixq6uQNJ4mCdcdgjHjl0nlxe5Q2FuNef7NMCn(qUbg8CrKldJDWy)nNHBqyWi5lGKw0AQ3YhYuR2MRp5cHbZnvJK7XYLrLlxH5Q2FuNef7NMCpnxOaEUgUHk7lCFdTVowGbcD)7jiz0xKDdPw9Ce8f53q2upnLEdfMRhqmYjMRqTK0b06WbqZvumxH5YeOdeYM7HCpkxe5oetGoqi5xMuU(K7z5AixrXCzc0bczZ9qUqjxd5IixfvYeqmWYfrUG0PuphXTkisgXJKPYQz3qL9fUVHn5xAIX99VNGeu)ISBi1QNJGVi)gYM6PP0BOWC9aIroXCfQLKoGwhoaAUiY13CzyquR9Zbd6P0oxrXCfMRhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGMlICzyquR9Zbd6P0oxd5kkMRWCzc0bczZ9qUhLlIChIjqhiK8ltkxFY9SCnKROyUmb6aHS5EixOKROyUEaXiNPYQzCa0CnKlICvujtaXalxe5csNs9Ce3QGizepsMkRMDdv2x4(gkqDrPjg33)EcsbZfz3qQvphbFr(nKn1ttP3qH56beJCI5kuljDaToCa0CrKRV5YWGOw7Ndg0tPDUII5kmxpGyKdw1WdbljtuSFAmP(LutdKk4ehanxe5YWGOw7Ndg0tPDUgYvumxH5YeOdeYM7HCpkxe5oetGoqi5xMuU(K7z5AixrXCzc0bczZ9qUqjxrXC9aIrotLvZ4aO5Aixe5QOsMaIbwUiYfKoL65iUvbrYiEKmvwn7gQSVW9nmc4CstmUV)9eKc0lYUHk7lCFd9RZu4rIJsYb00nKA1ZrWxKF)7jhb(fz3qQvphbFr(nKn1ttP3qI5kulXRw6aADYvumxI5kulXTyNoYMmYNROyUeZvOwIRn0YMmYNROyUEaXi3VotHhjokjhqtCa0CrKRhqmYjMRqTK0b06WbqZvumxH56beJCMkRMXhYuR2MRp5QSVWn3)OVaozeIb8K8ltkxe56beJCMkRMXbqZ1WnuzFH7BO91jwdD)7jhH0fz3qL9fUVH(h9fCdPw9Ce8f53)EYrhDr2nKA1ZrWxKFdv2x4(goaTuzFHBPRS)n0v2x2QjDdJQZ9cgG7F)7FdbrJTW99KJa)iWrcPJGYn0VoD1qS3qOIGkBu7eJ6NavSrj3CrMak3YefpFUr8Kluj4HutVQHPbQuUdb1aQHGZ1InPCvGhBQpbNltG2qilpdkyRMY9iJsUbcUbrZtW5gwMbsUwO7xnsUhp3hNBWcO5cxGkBH7CXO0OpEYv4PgYvisgXapdkyRMYfjKmk5gi4genpbNByzgi5AHUF1i5E8JN7JZnyb0CnXWaoaBUyuA0hp5k84gYvisgXapdkyRMYfPJmk5gi4genpbNByzgi5AHUF1i5E8JN7JZnyb0CnXWaoaBUyuA0hp5k84gYvisgXapdkyRMYfPZmk5gi4genpbNByzgi5AHUF1i5E8CFCUblGMlCbQSfUZfJsJ(4jxHNAixHized8mOmiOIGkBu7eJ6NavSrj3CrMak3YefpFUr8Kluj0Hyytp9HkL7qqnGAi4CTytkxf4XM6tW5YeOneYYZGc2QPCnAJsUbcUbrZtW5gwMbsUwO7xnsUhp3hNBWcO5cxGkBH7CXO0OpEYv4PgYv4rgXapdkdcQiOYg1oXO(jqfBuYnxKjGYTmrXZNBep5cvsXeuPChcQbudbNRfBs5Qap2uFcoxMaTHqwEguWwnL7rgLCdeCdIMNGZnSmdKCTq3VAKCp(XZ9X5gSaAUMyyahGnxmkn6JNCfECd5kejJyGNbfSvt5gyJsUbcUbrZtW5gwMbsUwO7xnsUhp3hNBWcO5cxGkBH7CXO0OpEYv4PgYvisgXapdkyRMYnymk5gi4genpbNByzgi5AHUF1i5E8CFCUblGMlCbQSfUZfJsJ(4jxHNAixHized8mOGTAkxKoYOKBGGBq08eCUHLzGKRf6(vJK7XpEUpo3GfqZ1edd4aS5IrPrF8KRWJBixHized8mOGTAkxKGIrj3ab3GO5j4CdlZajxl09Rgj3JF8CFCUblGMRjggWbyZfJsJ(4jxHh3qUcrYig4zqbB1uUifmgLCdeCdIMNGZnSmdKCTq3VAKCpEUpo3GfqZfUav2c35IrPrF8KRWtnKRqKmIbEguWwnLlsbQrj3ab3GO5j4CdlZajxl09Rgj3JN7JZnyb0CHlqLTWDUyuA0hp5k8ud5kejJyGNbfSvt5Ee4gLCdeCdIMNGZnSmdKCTq3VAKCpEUpo3GfqZfUav2c35IrPrF8KRWtnKRqKmIbEguWwnL7rNzuYnqWniAEco3WYmqY1cD)QrY945(4Cdwanx4cuzlCNlgLg9XtUcp1qUcpYig4zqzqqfbv2O2jg1pbQyJsU5ImbuULjkE(CJ4jxOs2hQuUdb1aQHGZ1InPCvGhBQpbNltG2qilpdkyRMYfjWnk5gi4genpbNByzgi5AHUF1i5E8JN7JZnyb0CnXWaoaBUyuA0hp5k84gYvisgXapdkyRMYfjKmk5gi4genpbNByzgi5AHUF1i5E8JN7JZnyb0CnXWaoaBUyuA0hp5k84gYvisgXapdkyRMYfjJ2OKBGGBq08eCUHLzGKRf6(vJK7XZ9X5gSaAUWfOYw4oxmkn6JNCfEQHCfIKrmWZGc2QPCrkymk5gi4genpbNByzgi5AHUF1i5E8CFCUblGMlCbQSfUZfJsJ(4jxHNAixHized8mOmiOIGkBu7eJ6NavSrj3CrMak3YefpFUr8KlujpS(qLYDiOgqneCUwSjLRc8yt9j4Czc0gcz5zqbB1uUhzuYnqWniAEco3WYmqY1cD)QrY945(4Cdwanx4cuzlCNlgLg9XtUcp1qUcpYig4zqbB1uUiDMrj3ab3GO5j4CdlZajxl09Rgj3JF8CFCUblGMRjggWbyZfJsJ(4jxHh3qUcrYig4zqbB1uUifmgLCdeCdIMNGZnSmdKCTq3VAKCpEUpo3GfqZfUav2c35IrPrF8KRWtnKRqOyed8mOGTAkxKcuJsUbcUbrZtW5gwMbsUwO7xnsUhp3hNBWcO5cxGkBH7CXO0OpEYv4PgYvisgXapdkdYOUjkEEcoxOEUk7lCNRRSVLNbDdTOe7EcsGF0neDWXYr3qJQCrU60Mr5cvObOGZGmQY9emiY0JMCpkWNN7rGFe4zqzqgv5gic0gcznkzqgv5cvZfQmmmbNBi2PtUiNutEgKrvUq1CdebAdHGZ91bc9YkMltTKn3hNldAMJKVoqO3YZGmQYfQMRrnYedIGZfOBIrwRoqNliDk1Zr2CfwCIFEUOdbsAFDSadekxOQX5IoeiU91Xcmqid8miJQCHQ5cvOkgPH6V0NYfSQHhcwArRPEBUXbBMlzII9tJ0d3W5k0F5C52ebN7JZDiqLLmWZGYGu2x42YrhIHn90)Gjg3GvTmIhZmiL9fUTC0Hyytp9d4WPGvn8qWslAn1BZGu2x42YrhIHn90pGdN6F0xW5UQjjd(asGNbPSVWTLJoedB6PFaho1)OVGZR4b0HaXrI7F0xacFrhce)iU)rFbzqk7lCB5OdXWME6hWHtTVoXAOmiL9fUTC0Hyytp9d4WPG0PuphDERM0bgUbHbJKWKf6MDoi1bqh8WwlIOdJhHcJfebVCitTAlu9iWnCCKocCdghDy8iuySGi4LdzQvBHQhDguvisGFSxDu)8Qz606x4MtT65iydqvHb(ymCdduphDiwzjP6kiTj1pNA1ZrWgmCCKcgWnKbLbzuLluHncXaEcoxcenqN7xMuUVakxL94j3YMRcslN65iEgKY(c32dwSthPhPMzqk7lCBd4WPG0PuphDERM0HYkvmDoi1bqhSOKZjFDGqVLBFDIQZzmsie67RoQFU91XHhyo1QNJGffF1r9ZTp5C6iHNk(CQvphbBqu0IsoN81bc9wU91jQoNXhLbPSVWTnGdNcsNs9C05TAshkRK5ifeDoi1bqhSOKZjFDGqVLBFDI1qgJugKY(c32aoCQhnwAaRAiNxXdc9LHbrT2pVlicEzujrrFzySdg7V5mCdcdgjFbK0Iwt9woaQbeEaXiNPYQzCa0miL9fUTbC4uu8x4(8kEWdig5mvwnJdGMbPSVWTnGdNcyjz9KPndszFHBBahovaPZljRLAgDEfp4iqKZNZqkdszFHBBahoDaAPY(c3sxz)ZB1KoOy6C7pf7pG05v8aiDk1Zr8YkvmLbPSVWTnGdNoaTuzFHBPRS)5TAshGhsn9QgMMZT)uS)asNxXddqtr8aH4Fzs(XtlHhsn9QgMgob1akuucodszFHBBahoDaAPY(c3sxz)ZB1Ko4H1)C7pf7pG05v8Wa0uepqiUN60MrsCuQoN8funelNGAafkkbNbPSVWTnGdNoaTuzFHBPRS)5TAshSFgugKY(c3wUIPdG0PuphDERM0b4HutP)Y5Kr15K4y8CqQdGoi0dig5Fzs(XtlHhsn9QgMg(qMA1wFGWG5MQrcaCosIIEaXi)ltYpEAj8qQPx1W0WhYuR26JY(c3C7RtSgItgHyapj)YKcaCosiesmxHAjE1shqRJOiXCfQL4wSthztg5ffjMRqTexBOLnzK3GbeEaXi)ltYpEAj8qQPx1W0WbqrmanfXdeI)Lj5hpTeEi10RAyA4eudOqrj4miL9fUTCftbC4u7RtuDUZR4bpGyKBFDIQZXhkoKvG65iecTOKZjFDGqVLBFDIQZ5duef9DaAkIhie)ltYpEAj8qQPx1W0WjOgqHIsWgqi03bOPiEGqCh0mDuRm6i6RgIeIRmrTeNGAafkkblk(LjD8Jh4Zm2dig52xNO6C8Hm1QTbCKHmiL9fUTCftbC4u7RtuDUZR4HbOPiEGq8Vmj)4PLWdPMEvdtdNGAafkkbJWIsoN81bc9wU91jQoNXhGccH(6beJ8Vmj)4PLWdPMEvdtdhafHhqmYTVor154dfhYkq9CKOOqq6uQNJ4WdPMs)LZjJQZjXXicHEaXi3(6evNJpKPwT1hOikArjNt(6aHEl3(6evNZ4Jq8QJ6NBFY50rcpv85uREocgHhqmYTVor154dzQvB95mdgmKbPSVWTLRykGdNcsNs9C05TAshSVor15K(X9lJQZjXX45GuhaDqT)Oojk2pnghmGdvfIe4hZdig5Fzs(XtlHhsn9QgMgU9vgygGQc9aIrU91jQohFitTA7XGYXTOKZjfO2NmavfcJFEeyGwIJsYb0eFitTA7XoZacpGyKBFDIQZXbqZGu2x42YvmfWHtTVowGbcDEfpasNs9CehEi1u6VCozuDojograsNs9Ce3(6evNt6h3VmQoNehJzqk7lCB5kMc4WPwGowdDodAMJKVoqO3EaPZR4HHIdzfOEocXRde65FzsYhlHlYyKcmu1IsoN81bc92agYuR2IqrLmbedmeeZvOwIxTuBOZGu2x42YvmfWHtvyf9lqK06xhZZzqZCK81bc92diDEfp47xmWQgccFv2x4MRWk6xGiP1VoMsy1uHq8QLrxbrWlkcJFUcROFbIKw)6ykHvtfcXTVYaZhOGag)Cfwr)cejT(1XucRMkeIpKPwT1hOKbPSVWTLRykGdNAIXDSg6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXcrkWbi0IsoN81bc9wU91jwdDmK4NzWWXTOKZjFDGqVnGHm1QTiekKHXoyS)MZuz1m(qkm0IIwuY5KVoqO3YTVoXAiFGIOOqI5kulXRwAXoDefjMRqTeVAPh(fiksmxHAjE1shqRdcFF1r9ZTyaNehLVasgXdzFo1QNJGff9aIro6uM4bUuNuhM2ftIc4S6WbPoaY4dhDg4gqi0IsoN81bc9wU91jwd5dsGFmHifWRoQF(7VAPjg3wo1QNJGnyaHA)rDsuSFAm(mWHQEaXi3(6evNJpKPwT9ygTbe(6beJCWQgEiyjzII9tJj1VKAAGubN4aOiuujtaXaZqgKY(c3wUIPaoCkd3GWGrYxajTO1uV98kEqiiDk1ZrCgUbHbJKWKf6MHO6NguStFcwglicE5qMA1wJrckGJWxgg7GX(BotLvZ4dPWqlk6beJCMkRMXbqnGqT)Oojk2pn(Cg4ie6beJCI5kuljDaTo8Hm1QTgB0IIEaXiNyUc1ssl2PdFitTARXb2GOySGi4LdzQvB9bjWZGu2x42YvmfWHtJ4HrsCu26dm05v8GIkzcigyzqk7lCB5kMc4WPJcIAmGvghQdo0NxXdEaXiNPYQzCa0miL9fUTCftbC4ug5i7xQtQUcsBs9FEfpi0dig52xNO6CCaurr1(J6KOy)0y8zGBaHVEaXi3ID2VyehafHVEaXiNPYQzCauec9LHbrT2pVlicEzujrrgg7GX(Bod3GWGrYxajTO1uVLdGkkw9tdk2PpblJfebVCitTARpmm2bJ93CgUbHbJKVasArRPElFitTABagTOy1pnOyN(eSmwqe8YHm1QTh)4ifmG7ZrGhGWaFmgUHbQNJoeRSKuDfK2K6NtT65iydgYGu2x42YvmfWHtRMPtRFH7ZR4bHEaXi3(6evNJdGkkQ2FuNef7NgJpdCdi81dig5wSZ(fJ4aOi81dig5mvwnJdGIqOVmmiQ1(5DbrWlJkjkYWyhm2FZz4gegms(ciPfTM6TCaurXQFAqXo9jyzSGi4LdzQvB9HHXoyS)MZWnimyK8fqslAn1B5dzQvBdWOffR(Pbf70NGLXcIGxoKPwT94hhPGbCFGc4bimWhJHByG65OdXkljvxbPnP(5uREoc2GHmiL9fUTCftbC4uYef7NgPhUHpVIhQ(Pbf70NGLXcIGxoKPwT1hKotuuOhqmYrNYepWL6K6W0UysuaNvhoi1bq(C0zGlk6beJC0PmXdCPoPomTlMefWz1HdsDaKXho6mWnGWdig52xNO6CCauemm2bJ93CMkRMXhYuR2A8zGNbPSVWTLRykGdNAFY50rgD6qNZGM5i5Rde6Thq68kEyO4qwbQNJq8LjjFSeUiJr6mewuY5KVoqO3YTVoXAiFcmcfvYeqmWqi0dig5mvwnJpKPwT1yKaxu0xpGyKZuz1moaQHmiL9fUTCftbC40iWaTehLKdOPZR4bI5kulXRwQn0iuujtaXadHhqmYrNYepWL6K6W0UysuaNvhoi1bq(C0zGJqim(5kSI(fisA9RJPewnvie)lgyvdru0xgge1A)8Myd2Hhyrrlk5CYxhi0Bn(idzqk7lCB5kMc4WP2xNO6CNxXdEaXih30lWkrPHrOFHBoakcHEaXi3(6evNJpuCiRa1ZrIIQ9h1jrX(PX4afCdzqk7lCB5kMc4WP2xNO6CNxXdmmiQ1(5DbrWlJkHqiiDk1ZrCgUbHbJKWKf6MjkYWyhm2FZzQSAghavu0dig5mvwnJdGAabdJDWy)nNHBqyWi5lGKw0AQ3YhYuR26degm3unYXyu5eQ2FuNef7NMJFg4gq4beJC7RtuDo(qMA1wFcCgKY(c3wUIPaoCQ91XcmqOZR4bgge1A)8UGi4LrLqieKoL65iod3GWGrsyYcDZefzySdg7V5mvwnJdGkk6beJCMkRMXbqnGGHXoyS)MZWnimyK8fqslAn1B5dzQvB9bcdMBQg5ymQCcv7pQtII9tZXHc4gq4beJC7RtuDooakcI5kulXRwQn0zqk7lCB5kMc4WP2xhlWaHoVIh8aIroUPxGvYCKosqLTWnhavuuOV2xNynexrLmbedmrrHEaXiNPYQz8Hm1QT(CgcpGyKZuz1moaQOOqpGyKpkiQXawzCOo4qZhYuR26degm3unYXyu5eQ2FuNef7NMJdfWnGWdig5JcIAmGvghQdo0CaudgqasNs9Ce3(6evNt6h3VmQoNehJiSOKZjFDGqVLBFDIQZ5dumGqOVdqtr8aH4Fzs(XtlHhsn9QgMgob1akuucwu0IsoN81bc9wU91jQoNpqXqgKY(c3wUIPaoCAt(LMyCFEfpiKyUc1s8QLAdncgg7GX(BotLvZ4dzQvBn(mWfffYeOdeYE4iedXeOdes(Lj5Zzgefzc0bczpafdiuujtaXaldszFHBlxXuahovG6IstmUpVIhesmxHAjE1sTHgbdJDWy)nNPYQz8Hm1QTgFg4IIczc0bczpCeIHyc0bcj)YK85mdIImb6aHShGIbekQKjGyGLbPSVWTLRykGdNgbCoPjg3NxXdcjMRqTeVAP2qJGHXoyS)MZuz1m(qMA1wJpdCrrHmb6aHShocXqmb6aHKFzs(CMbrrMaDGq2dqXacfvYeqmWYGu2x42YvmfWHt9RZu4rIJsYb0ugKY(c3wUIPaoCkiDk1ZrN3QjDW(6eRHKvlTyNoNdsDa0blk5CYxhi0B52xNynKXboGOdJhHMQ9PbAji1bqh)iWneq0HXJqpGyKBFDSadessMOy)0ys9lTyNoC7RmWoEGnKbPSVWTLRykGdN6F0xW5v8aXCfQL4oGwhztg5ffjMRqTexBOLnzKhbiDk1Zr8YkzosbrIIEaXiNyUc1ssl2PdFitTARpk7lCZTVoXAiozeIb8K8ltcHhqmYjMRqTK0ID6WbqffjMRqTeVAPf70bHVG0PuphXTVoXAiz1sl2PJOOhqmYzQSAgFitTARpk7lCZTVoXAiozeIb8K8ltcHVG0PuphXlRK5ifeHWdig5mvwnJpKPwT1hYied4j5xMecpGyKZuz1moaQOOhqmYhfe1yaRmouhCO5aOiSOKZjfO2NmgCUrJqOfLCo5Rde6T(CakII((QJ6NBXaojokFbKmIhY(CQvphbBqu0xq6uQNJ4LvYCKcIq4beJCMkRMXhYuR2AmzeIb8K8ltkdszFHBlxXuaho1(6eRHYGu2x42YvmfWHthGwQSVWT0v2)8wnPdr15EbdqgugKY(c3wUhw)dJcIAmGvghQdo0NxXdEaXiNPYQzCa0miL9fUTCpS(bC4uq6uQNJoVvt6ad3GWGrsyYcDZohK6aOdrhgpcfw9tdk2PpblJfebVCitTAlu9iWnCCKocCdghDy8iuy1pnOyN(eSmwqe8YHm1QTq1JodQkejWp2RoQFE1mDA9lCZPw9CeSbOQWaFmgUHbQNJoeRSKuDfK2K6NtT65iydgoosbd4gYGu2x42Y9W6hWHtbPtPEo68wnPdSP(g)aONdsDa0bF9aIrUN60MrsCuQoN8funeRS1hyioakcF9aIrUN60MrsCuQoN8funeRuhM2ehandszFHBl3dRFahovHv0VarsRFDmpNbnZrYxhi0BpG05v8GhqmY9uN2msIJs15KVGQHyLT(adXTVYatcsDaKpbgCeEaXi3tDAZijokvNt(cQgIvQdtBIBFLbMeK6aiFcm4ie6lm(5kSI(fisA9RJPewnvie)lgyvdbHVk7lCZvyf9lqK06xhtjSAQqiE1YORGi4ri0xy8Zvyf9lqK06xhtPasD8VyGvnerry8Zvyf9lqK06xhtPasD8Hm1QTgdfdIIW4NRWk6xGiP1VoMsy1uHqC7RmW8bkiGXpxHv0VarsRFDmLWQPcH4dzQvB95meW4NRWk6xGiP1VoMsy1uHq8VyGvnedzqk7lCB5Ey9d4WPmCdcdgjFbK0Iwt92ZR4bHG0PuphXz4gegmsctwOBgIQFAqXo9jyzSGi4LdzQvBngjOaocFzySdg7V5mvwnJpKcdTOOhqmYzQSAgha1acHEaXi3tDAZijokvNt(cQgIv26dme3(kdmji1bqhodCrrpGyK7PoTzKehLQZjFbvdXk1HPnXTVYatcsDa0HZa3GOySGi4LdzQvB9bjWZGu2x42Y9W6hWHtzAZiN0digpVvt6G91XHh4ZR4bHEaXi3tDAZijokvNt(cQgIv26dmeFitTARXbMFMOOhqmY9uN2msIJs15KVGQHyL6W0M4dzQvBnoW8ZmGqT)Oojk2pngFiqbhHqgg7GX(BotLvZ4dzQvBngQlkkKHXoyS)MtMOy)0i9WnmFitTARXqDe(6beJCWQgEiyjzII9tJj1VKAAGubN4aOiyyquR9Zbd6P02GHmiL9fUTCpS(bC4u7RJfyGqNxXd(csNs9CeNn134hafHqgge1A)8UGi4LrLefzySdg7V5mvwnJpKPwT1yOUOOqgg7GX(BozII9tJ0d3W8Hm1QTgd1r4RhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGIGHbrT2phmONsBdgYGu2x42Y9W6hWHtTVowGbcDEfpiKHXoyS)MZWnimyK8fqslAn1B5aOiecsNs9CeNHBqyWijmzHUzIImm2bJ93CMkRMXhYuR26ZzgmGqT)Oojk2pngFg4iyyquR9Z7cIGxgvkdszFHBl3dRFaho1c0XAOZzqZCK81bc92diDEfpmuCiRa1ZriEDGqp)lts(yjCrgJKrJqOIkzcigyiecsNs9CeNn134havuuOA)rDsuSFA8bkGJWxpGyKZuz1moaQbrrgg7GX(BotLvZ4dPWqBWqgKY(c3wUhw)aoCQjg3XAOZzqZCK81bc92diDEfpmuCiRa1ZriEDGqp)lts(yjCrgJeu4NHqOIkzcigyiecsNs9CeNn134havuuOA)rDsuSFA8bkGJWxpGyKZuz1moaQbrrgg7GX(BotLvZ4dPWqBaHVEaXihSQHhcwsMOy)0ys9lPMgivWjoaQHmiL9fUTCpS(bC4u7toNoYOth6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXiz0bmKPwTfHqfvYeqmWqieKoL65ioBQVXpaQOOA)rDsuSFA8bkGlkYWyhm2FZzQSAgFifgAdgYGu2x42Y9W6hWHtJ4HrsCu26dm05v8GIkzcigyzqk7lCB5Ey9d4WPrGbAjokjhqtNxXdcjMRqTeVAP2qlksmxHAjUf70rwTejrrI5kulXDaToYQLizaHqFzyquR9Z7cIGxgvsuuOA)rDsuSFA8jqpdHqq6uQNJ4SP(g)aOIIQ9h1jrX(PXhOaUOiiDk1Zr8YkvmzaHqq6uQNJ4mCdcdgjHjl0ndHVmm2bJ93CgUbHbJKVasArRPElhavu0xq6uQNJ4mCdcdgjHjl0ndHVmm2bJ93CMkRMXbqnyWacHmm2bJ93CMkRMXhYuR2AmuaxuuT)Oojk2pnghOGJGHXoyS)MZuz1moakcHmm2bJ93CYef7NgPhUH5dzQvB9rzFHBU91jwdXjJqmGNKFzsII(YWGOw7Ndg0tPTbrXQFAqXo9jyzSGi4LdzQvB9bjWnGqim(5kSI(fisA9RJPewnvieFitTARXbwu0xgge1A)8Myd2Hhydzqk7lCB5Ey9d4WPGvn8qWslAn1BpVIhesmxHAjUdO1r2KrErrI5kulXTyNoYMmYlksmxHAjU2qlBYiVOOhqmY9uN2msIJs15KVGQHyLT(adXhYuR2ACG5Njk6beJCp1PnJK4OuDo5lOAiwPomTj(qMA1wJdm)mrr1(J6KOy)0yCGcocgg7GX(BotLvZ4dPWqBaHqgg7GX(BotLvZ4dzQvBngkGlkYWyhm2FZzQSAgFifgAdIIv)0GID6tWYybrWlhYuR26dsGNbPSVWTL7H1pGdNYihz)sDs1vqAtQ)ZR4bHQ9h1jrX(PX4afCec9aIroyvdpeSKmrX(PXK6xsnnqQGtCaurrFzyquR9Zbd6P02GOiddIATFExqe8YOsIIEaXi3ZHXWoa7Zbqr4beJCphgd7aSpFitTARphbEacd8Xy4ggOEo6qSYss1vqAtQFo1QNJGnyaHqFzyquR9Z7cIGxgvsuKHXoyS)MZWnimyK8fqslAn1B5aOIIv)0GID6tWYybrWlhYuR26ddJDWy)nNHBqyWi5lGKw0AQ3YhYuR2gGrlkw9tdk2PpblJfebVCitTA7Xposbd4(Ce4bimWhJHByG65OdXkljvxbPnP(5uREoc2GHmiL9fUTCpS(bC40Qz606x4(8kEqOA)rDsuSFAmoqbhHqpGyKdw1WdbljtuSFAmP(LutdKk4ehavu0xgge1A)CWGEkTnikYWGOw7N3febVmQKOOhqmY9CymSdW(CaueEaXi3ZHXWoa7ZhYuR26duapaHb(ymCdduphDiwzjP6kiTj1pNA1ZrWgmGqOVmmiQ1(5DbrWlJkjkYWyhm2FZz4gegms(ciPfTM6TCaurrq6uQNJ4mCdcdgjHjl0ndr1pnOyN(eSmwqe8YHm1QTgJuWaEahbEacd8Xy4ggOEo6qSYss1vqAtQFo1QNJGnikw9tdk2PpblJfebVCitTARpmm2bJ93CgUbHbJKVasArRPElFitTABagTOy1pnOyN(eSmwqe8YHm1QT(afWdqyGpgd3Wa1ZrhIvwsQUcsBs9ZPw9CeSbdzqk7lCB5Ey9d4WP2xhlWaHoVIhyyquR9Z7cIGxgvcHqq6uQNJ4mCdcdgjHjl0ntuKHXoyS)MZuz1m(qMA1wFqcCdiu7pQtII9tJXNbocgg7GX(Bod3GWGrYxajTO1uVLpKPwT1hKapdszFHBl3dRFahofKoL65OZB1KoOwuOcOjKyNdsDa0bI5kulXRw6aADowWCCL9fU52xNyneNmcXaEs(LjfGVeZvOwIxT0b06CmJ(4k7lCZ9p6lGtgHyapj)YKcaC(rh3IsoNuGAFkdszFHBl3dRFaho1(6ybgi05v8GWQFAqXo9jyzSGi4LdzQvB9jWIIc9aIr(OGOgdyLXH6GdnFitTARpqyWCt1ihJrLtOA)rDsuSFAooua3acpGyKpkiQXawzCOo4qZbqnyquuOA)rDsuSFAcaKoL65iUArHkGMqIDmpGyKtmxHAjPf70HpKPwTnay8ZJad0sCusoGM4FXaZkhYuR(yhXpZyKocCrr1(J6KOy)0eaiDk1ZrC1IcvanHe7yEaXiNyUc1sshqRdFitTABaW4NhbgOL4OKCanX)IbMvoKPw9XoIFMXiDe4gqqmxHAjE1sTHgHqH(YWyhm2FZzQSAghavuKHbrT2phmONsBe(YWyhm2FZjtuSFAKE4gMdGAquKHbrT2pVlicEzujdie6lddIATFoiQFbqpII(6beJCMkRMXbqffv7pQtII9tJXbk4gef9aIrotLvZ4dzQvBnoyq4RhqmYhfe1yaRmouhCO5aOzqk7lCB5Ey9d4WPn5xAIX95v8GqpGyKtmxHAjPdO1HdGkkkKjqhiK9WrigIjqhiK8ltYNZmikYeOdeYEakgqOOsMaIbwgKY(c3wUhw)aoCQa1fLMyCFEfpi0dig5eZvOws6aAD4aOIIczc0bczpCeIHyc0bcj)YK85mdIImb6aHShGIbekQKjGyGLbPSVWTL7H1pGdNgbCoPjg3NxXdc9aIroXCfQLKoGwhoaQOOqMaDGq2dhHyiMaDGqYVmjFoZGOitGoqi7bOyaHIkzcigyzqk7lCB5Ey9d4WP(1zk8iXrj5aAkdszFHBl3dRFaho1(6eRHoVIhiMRqTeVAPdO1ruKyUc1sCl2PJSjJ8IIeZvOwIRn0YMmYlk6beJC)6mfEK4OKCanXbqrqmxHAjE1shqRJOOqpGyKZuz1m(qMA1wFu2x4M7F0xaNmcXaEs(LjHWdig5mvwnJdGAidszFHBl3dRFaho1)OVGmiL9fUTCpS(bC40bOLk7lClDL9pVvt6quDUxWaKbLbPSVWTLdpKA6vnmnhaPtPEo68wnPdwnsYhlbSK0Iso35GuhaDqOhqmY)YK8JNwcpKA6vnmn8Hm1QTgdHbZnvJea4CKqiKyUc1s8QLE4xGOiXCfQL4vlTyNoIIeZvOwI7aADKnzK3GOOhqmY)YK8JNwcpKA6vnmn8Hm1QTgRSVWn3(6eRH4KrigWtYVmPaaNJecHeZvOwIxT0b06iksmxHAjUf70r2KrErrI5kulX1gAztg5nyqu0xpGyK)Lj5hpTeEi10RAyA4aOzqk7lCB5WdPMEvdttaho1(6ybgi05v8GqFbPtPEoIB1ijFSeWsslk5CIIc9aIr(OGOgdyLXH6GdnFitTARpqyWCt1ihJrLtOA)rDsuSFAooua3acpGyKpkiQXawzCOo4qZbqnyquuT)Oojk2pnghOGNbPSVWTLdpKA6vnmnbC4ugUbHbJKVasArRPE75v8Gqq6uQNJ4mCdcdgjHjl0ndr1pnOyN(eSmwqe8YHm1QTgJeuahHVmm2bJ93CMkRMXhsHHwu0dig5mvwnJdGAaHA)rDsuSFA8jWGJqOhqmYjMRqTK0b06WhYuR2AmsGlk6beJCI5kuljTyNo8Hm1QTgJe4gefJfebVCitTARpibEgKY(c3wo8qQPx1W0eWHtvyf9lqK06xhZZzqZCK81bc92diDEfp4lm(5kSI(fisA9RJPewnvie)lgyvdbHVk7lCZvyf9lqK06xhtjSAQqiE1YORGi4ri0xy8Zvyf9lqK06xhtPasD8VyGvnerry8Zvyf9lqK06xhtPasD8Hm1QTgFMbrry8Zvyf9lqK06xhtjSAQqiU9vgy(afeW4NRWk6xGiP1VoMsy1uHq8Hm1QT(afeW4NRWk6xGiP1VoMsy1uHq8VyGvnKmiL9fUTC4HutVQHPjGdNAIXDSg6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXiDecHc9aIrotLvZ4dzQvBn(mec9aIr(OGOgdyLXH6GdnFitTARXNjk6RhqmYhfe1yaRmouhCO5aOgef91dig5mvwnJdGkkQ2FuNef7NgFGc4gqi0xpGyKdw1WdbljtuSFAmP(LutdKk4ehavuuT)Oojk2pn(afWnGqrLmbedmdzqk7lCB5WdPMEvdttaho1c0XAOZzqZCK81bc92diDEfpmuCiRa1ZriEDGqp)lts(yjCrgJ0riek0dig5mvwnJpKPwT14Zqi0dig5JcIAmGvghQdo08Hm1QTgFMOOVEaXiFuquJbSY4qDWHMdGAqu0xpGyKZuz1moaQOOA)rDsuSFA8bkGBaHqF9aIroyvdpeSKmrX(PXK6xsnnqQGtCaurr1(J6KOy)04dua3acfvYeqmWmKbPSVWTLdpKA6vnmnbC4u7toNoYOth6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXiz0iek0dig5mvwnJpKPwT14Zqi0dig5JcIAmGvghQdo08Hm1QTgFMOOVEaXiFuquJbSY4qDWHMdGAqu0xpGyKZuz1moaQOOA)rDsuSFA8bkGBaHqF9aIroyvdpeSKmrX(PXK6xsnnqQGtCaurr1(J6KOy)04dua3acfvYeqmWmKbPSVWTLdpKA6vnmnbC40iEyKehLT(adDEfpOOsMaIbwgKY(c3wo8qQPx1W0eWHthfe1yaRmouhCOpVIh8aIrotLvZ4aOzqk7lCB5WdPMEvdttahofSQHhcwArRPE75v8GqHEaXiNyUc1ssl2PdFitTARXibUOOhqmYjMRqTK0b06WhYuR2AmsGBabdJDWy)nNPYQz8Hm1QTgdfWnikYWyhm2FZzQSAgFifg6miL9fUTC4HutVQHPjGdNYihz)sDs1vqAtQ)ZR4bHc9aIroyvdpeSKmrX(PXK6xsnnqQGtCaurrFzyquR9Zbd6P02GOiddIATFExqe8YOsIIG0PuphXlRuXKOOhqmY9CymSdW(CaueEaXi3ZHXWoa7ZhYuR26ZrGhGWaFmgUHbQNJoeRSKuDfK2K6NtT65iydgq4RhqmYzQSAghafHqFzyquR9Z7cIGxgvsuKHXoyS)MZWnimyK8fqslAn1B5aOIIv)0GID6tWYybrWlhYuR26ddJDWy)nNHBqyWi5lGKw0AQ3YhYuR2gGrlkw9tdk2PpblJfebVCitTA7Xposbd4(Ce4bimWhJHByG65OdXkljvxbPnP(5uREoc2GHmiL9fUTC4HutVQHPjGdNwntNw)c3NxXdcf6beJCWQgEiyjzII9tJj1VKAAGubN4aOII(YWGOw7Ndg0tPTbrrgge1A)8UGi4LrLefbPtPEoIxwPIjrrpGyK75WyyhG95aOi8aIrUNdJHDa2NpKPwT1hOaEacd8Xy4ggOEo6qSYss1vqAtQFo1QNJGnyaHVEaXiNPYQzCauec9LHbrT2pVlicEzujrrgg7GX(Bod3GWGrYxajTO1uVLdGkkw9tdk2PpblJfebVCitTARpmm2bJ93CgUbHbJKVasArRPElFitTABagTOy1pnOyN(eSmwqe8YHm1QTh)4ifmG7duapaHb(ymCdduphDiwzjP6kiTj1pNA1ZrWgmKbPSVWTLdpKA6vnmnbC4uq6uQNJoVvt6GvbrYiEKmvwn7CqQdGoi0xgg7GX(BotLvZ4dPWqlk6liDk1ZrCgUbHbJKWKf6MHGHbrT2pVlicEzujdzqk7lCB5WdPMEvdttahoncmqlXrj5aA68kEGyUc1s8QLAdncfvYeqmWqieg)Cfwr)cejT(1XucRMkeI)fdSQHik6lddIATFEtSb7WdSbeG0PuphXTkisgXJKPYQzzqk7lCB5WdPMEvdttaho1(6ybgi05v8addIATFExqe8YOsiaPtPEoIZWnimyKeMSq3meQ9h1jrX(PX4dbgCemm2bJ93CgUbHbJKVasArRPElFitTARpqyWCt1ihJrLtOA)rDsuSFAooua3qgKY(c3wo8qQPx1W0eWHtBYV0eJ7ZR4bHEaXiNyUc1sshqRdhavuuitGoqi7HJqmetGoqi5xMKpNzquKjqhiK9aumGqrLmbedmeG0PuphXTkisgXJKPYQzzqk7lCB5WdPMEvdttahovG6IstmUpVIhe6beJCI5kuljDaToCaue(YWGOw7Ndg0tPTOOqpGyKdw1WdbljtuSFAmP(LutdKk4ehafbddIATFoyqpL2geffYeOdeYE4iedXeOdes(Lj5Zzgefzc0bczpafrrpGyKZuz1moaQbekQKjGyGHaKoL65iUvbrYiEKmvwnldszFHBlhEi10RAyAc4WPraNtAIX95v8GqpGyKtmxHAjPdO1HdGIWxgge1A)CWGEkTfff6beJCWQgEiyjzII9tJj1VKAAGubN4aOiyyquR9Zbd6P02GOOqMaDGq2dhHyiMaDGqYVmjFoZGOitGoqi7bOik6beJCMkRMXbqnGqrLmbedmeG0PuphXTkisgXJKPYQzzqk7lCB5WdPMEvdttaho1VotHhjokjhqtzqk7lCB5WdPMEvdttaho1(6eRHoVIhiMRqTeVAPdO1ruKyUc1sCl2PJSjJ8IIeZvOwIRn0YMmYlk6beJC)6mfEK4OKCanXbqr4beJCI5kuljDaToCaurrHEaXiNPYQz8Hm1QT(OSVWn3)OVaozeIb8K8ltcHhqmYzQSAgha1qgKY(c3wo8qQPx1W0eWHt9p6lidszFHBlhEi10RAyAc4WPdqlv2x4w6k7FERM0HO6CVGbidkdszFHBlpQo3lyaoyFDSade68kEW3bOPiEGqCp1PnJK4OuDo5lOAiwob1akuucodszFHBlpQo3lyac4WPwGowdDodAMJKVoqO3EaPZR4by8ZnX4owdXhYuR2A8qMA12miL9fUT8O6CVGbiGdNAIXDSgkdkdszFHBl3(huyf9lqK06xhZZzqZCK81bc92diDEfp4lm(5kSI(fisA9RJPewnvie)lgyvdbHVk7lCZvyf9lqK06xhtjSAQqiE1YORGi4ri0xy8Zvyf9lqK06xhtPasD8VyGvnerry8Zvyf9lqK06xhtPasD8Hm1QTgFMbrry8Zvyf9lqK06xhtjSAQqiU9vgy(afeW4NRWk6xGiP1VoMsy1uHq8Hm1QT(afeW4NRWk6xGiP1VoMsy1uHq8VyGvnKmiL9fUTC7hWHtz4gegms(ciPfTM6TNxXdcbPtPEoIZWnimyKeMSq3mev)0GID6tWYybrWlhYuR2AmsqbCe(YWyhm2FZzQSAgFifgArrpGyKZuz1moaQbeQ9h1jrX(PXNZahHqpGyKtmxHAjPdO1HpKPwT1yKaxu0dig5eZvOwsAXoD4dzQvBngjWnikglicE5qMA1wFqc8miL9fUTC7hWHtbPtPEo68wnPdW4xoeudOgYK63Eoi1bqhe6beJCMkRMXhYuR2A8zie6beJ8rbrngWkJd1bhA(qMA1wJptu0xpGyKpkiQXawzCOo4qZbqnik6RhqmYzQSAghavuuT)Oojk2pn(afWnGqOVEaXihSQHhcwsMOy)0ys9lPMgivWjoaQOOA)rDsuSFA8bkGBaHqpGyKtmxHAjPf70HpKPwT1yimyUPAerrpGyKtmxHAjPdO1HpKPwT1yimyUPAedzqk7lCB52pGdNAIXDSg6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXiDecHkQKjGyGHaKoL65iom(Ldb1aQHmP(TgYGu2x42YTFaho1c0XAOZzqZCK81bc92diDEfpmuCiRa1ZriEDGqp)lts(yjCrgJ0rieQOsMaIbgcq6uQNJ4W4xoeudOgYK63AidszFHBl3(bC4u7toNoYOth6Cg0mhjFDGqV9asNxXddfhYkq9CeIxhi0Z)YKKpwcxKXiz0ieQOsMaIbgcq6uQNJ4W4xoeudOgYK63AidszFHBl3(bC40iEyKehLT(adDEfpOOsMaIbwgKY(c3wU9d4WPJcIAmGvghQdo0NxXdEaXiNPYQzCa0miL9fUTC7hWHtjtuSFAKE4g(8kEqOqpGyKtmxHAjPf70HpKPwT1yKaxu0dig5eZvOws6aAD4dzQvBngjWnGGHXoyS)MZuz1m(qMA1wJHc4ie6beJC0PmXdCPoPomTlMefWz1HdsDaKphfyWff9DaAkIhiehDkt8axQtQdt7IjrbCwD4eudOqrjydgef9aIro6uM4bUuNuhM2ftIc4S6WbPoaY4dhb1bxuKHXoyS)MZuz1m(qkm0ieQ2FuNef7NgJduWffbPtPEoIxwPIjdzqk7lCB52pGdNYihz)sDs1vqAtQ)ZR4bHQ9h1jrX(PX4afCec9aIroyvdpeSKmrX(PXK6xsnnqQGtCaurrFzyquR9Zbd6P02GOiddIATFExqe8YOsIIG0PuphXlRuXKOOhqmY9CymSdW(CaueEaXi3ZHXWoa7ZhYuR26ZrGhGqHb6XgGMI4bcXrNYepWL6K6W0UysuaNvhob1akuuc2qacd8Xy4ggOEo6qSYss1vqAtQFo1QNJGnyWacF9aIrotLvZ4aOie6lddIATFExqe8YOsIImm2bJ93CgUbHbJKVasArRPElhavuS6NguStFcwglicE5qMA1wFyySdg7V5mCdcdgjFbK0Iwt9w(qMA12amArXQFAqXo9jyzSGi4LdzQvBp(Xrkya3NJapaHb(ymCdduphDiwzjP6kiTj1pNA1ZrWgmKbPSVWTLB)aoCA1mDA9lCFEfpiuT)Oojk2pnghOGJqOhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGkk6lddIATFoyqpL2gefzyquR9Z7cIGxgvsueKoL65iEzLkMef9aIrUNdJHDa2NdGIWdig5Eomg2byF(qMA1wFGc4biuyGESbOPiEGqC0PmXdCPoPomTlMefWz1HtqnGcfLGneGWaFmgUHbQNJoeRSKuDfK2K6NtT65iydgmGWxpGyKZuz1moakcH(YWGOw7N3febVmQKOidJDWy)nNHBqyWi5lGKw0AQ3YbqffR(Pbf70NGLXcIGxoKPwT1hgg7GX(Bod3GWGrYxajTO1uVLpKPwTnaJwuS6NguStFcwglicE5qMA12JFCKcgW9bkGhGWaFmgUHbQNJoeRSKuDfK2K6NtT65iydgYGu2x42YTFahofKoL65OZB1KoyvqKmIhjtLvZohK6aOdc9LHXoyS)MZuz1m(qkm0II(csNs9CeNHBqyWijmzHUziyyquR9Z7cIGxgvYqgKY(c3wU9d4WPrGbAjokjhqtNxXdeZvOwIxTuBOrOOsMaIbgcpGyKJoLjEGl1j1HPDXKOaoRoCqQdG85OadocHW4NRWk6xGiP1VoMsy1uHq8VyGvnerrFzyquR9ZBInyhEGnGaKoL65iUvbrYiEKmvwnldszFHBl3(bC4u7RtuDUZR4bpGyKJB6fyLO0Wi0VWnhafHhqmYTVor154dfhYkq9CugKY(c3wU9d4WPmTzKt6beJN3QjDW(64Wd85v8GhqmYTVoo8aZhYuR26Zzie6beJCI5kuljTyNo8Hm1QTgFMOOhqmYjMRqTK0b06WhYuR2A8zgqO2FuNef7NgJduWZGu2x42YTFaho1(6ybgi05v8addIATFExqe8YOsiaPtPEoIZWnimyKeMSq3memm2bJ93CgUbHbJKVasArRPElFitTARpqyWCt1ihJrLtOA)rDsuSFAooua3qgKY(c3wU9d4WP2xNO6CNxXdV6O(52NCoDKWtfFo1QNJGr47RoQFU91XHhyo1QNJGr4beJC7RtuDo(qXHScuphHqOhqmYjMRqTK0b06WhYuR2ASrJGyUc1s8QLoGwheEaXihDkt8axQtQdt7IjrbCwD4Guha5ZrNbUOOhqmYrNYepWL6K6W0UysuaNvhoi1bqgF4OZahHA)rDsuSFAmoqbxueg)Cfwr)cejT(1XucRMkeIpKPwT14GruuzFHBUcROFbIKw)6ykHvtfcXRwgDfebVbe(YWyhm2FZzQSAgFifg6miL9fUTC7hWHtTVowGbcDEfp4beJCCtVaRK5iDKGkBHBoaQOOhqmYbRA4HGLKjk2pnMu)sQPbsfCIdGkk6beJCMkRMXbqri0dig5JcIAmGvghQdo08Hm1QT(aHbZnvJCmgvoHQ9h1jrX(P54qbCdi8aIr(OGOgdyLXH6Gdnhavu0xpGyKpkiQXawzCOo4qZbqr4ldJDWy)nFuquJbSY4qDWHMpKcdTOOVmmiQ1(5GO(fa9yquuT)Oojk2pnghOGJGyUc1s8QLAdDgKY(c3wU9d4WP2xhlWaHoVIhE1r9ZTVoo8aZPw9CemcHEaXi3(64WdmhavuuT)Oojk2pnghOGBaHhqmYTVoo8aZTVYaZhOGqOhqmYjMRqTK0ID6Wbqff9aIroXCfQLKoGwhoaQbeEaXihDkt8axQtQdt7IjrbCwD4Guha5ZrqDWriKHXoyS)MZuz1m(qMA1wJrcCrrFbPtPEoIZWnimyKeMSq3memmiQ1(5DbrWlJkzidszFHBl3(bC4u7RJfyGqNxXdc9aIro6uM4bUuNuhM2ftIc4S6WbPoaYNJG6Glk6beJC0PmXdCPoPomTlMefWz1HdsDaKphDg4iE1r9ZTp5C6iHNk(CQvphbBaHhqmYjMRqTK0ID6WhYuR2AmuhbXCfQL4vlTyNoi81dig54MEbwjknmc9lCZbqr47RoQFU91XHhyo1QNJGrWWyhm2FZzQSAgFitTARXqDeczySdg7V5Gvn8qWslAn1B5dzQvBngQlk6lddIATFoyqpL2gYGu2x42YTFahoTj)stmUpVIhe6beJCI5kuljDaToCaurrHmb6aHShocXqmb6aHKFzs(CMbrrMaDGq2dqXacfvYeqmWqasNs9Ce3QGizepsMkRMLbPSVWTLB)aoCQa1fLMyCFEfpi0dig5eZvOws6aAD4aOi8LHbrT2phmONsBrrHEaXihSQHhcwsMOy)0ys9lPMgivWjoakcgge1A)CWGEkTnikkKjqhiK9WrigIjqhiK8ltYNZmikYeOdeYEakIIEaXiNPYQzCaudiuujtaXadbiDk1ZrCRcIKr8izQSAwgKY(c3wU9d4WPraNtAIX95v8GqpGyKtmxHAjPdO1HdGIWxgge1A)CWGEkTfff6beJCWQgEiyjzII9tJj1VKAAGubN4aOiyyquR9Zbd6P02GOOqMaDGq2dhHyiMaDGqYVmjFoZGOitGoqi7bOik6beJCMkRMXbqnGqrLmbedmeG0PuphXTkisgXJKPYQzzqk7lCB52pGdN6xNPWJehLKdOPmiL9fUTC7hWHtTVoXAOZR4bI5kulXRw6aADefjMRqTe3ID6iBYiVOiXCfQL4AdTSjJ8IIEaXi3VotHhjokjhqtCaueEaXiNyUc1sshqRdhavuuOhqmYzQSAgFitTARpk7lCZ9p6lGtgHyapj)YKq4beJCMkRMXbqnKbPSVWTLB)aoCQ)rFbzqk7lCB52pGdNoaTuzFHBPRS)5TAshIQZ9cgG7F)7f]] )


end