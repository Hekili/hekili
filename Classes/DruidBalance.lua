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


    spec:RegisterPack( "Balance", 20201113, [[dKulSdqiQkEebj6sqe2eq9jHskJIuCksPvbK0RekMLkIBbrKDHQFPI0WGGJbHwMkONbeMMkKUgq02ekX3as04uHOZrqQ1rqsVtOKOmpQkDpHQ9rqDqcsOfcr6HQqyIcLu1ffkjQ(OqjjNKGeSsvGzcKWnfkjYovHAOcLuzPcLeEQqMkqQVkusQ9Qs)LKbR4WuwmP6XOmziDzKnl4ZGy0e40s9AvuZMk3MQSBL(nudhuhhIOwUKNt00v11bSDq67uvnEcIZdrTEHsnFcTFrFr8c6BeQ9094dr4qeqerebb)qep6rbHqFJEKHPBeSXoBqOB0AE0ncPMZwgDJGnKDyd9c6BKedum6gj4FyPq90tH0VaaDod7DQS9aC234Lvw4pv2EStVr6aT7fkSx9BeQ9094dr4qeqerebb)qepkIiE0BKb8cW1nkQ9oIBKGgfL2R(ncLKSBKqzoi1C2YOCI1xanAEGqzohJHsE6uLdIG4KCoeHdripipqOmNJqGTqiPqnpqOmhKuocfrrj0CIWoRYbPK5XZdekZbjLZriWwieAoVvqOx1HCyMKK584CyiZCK6Tcc9sEEGqzoiPCIvqEyOeAoa7smskTc5CGAvB6osMJMMt8tYbUiOk5BLeOGq5GKeoh4IGYLVvsGccPLNhiuMdskNyL6fx5qO9NZJZHwggOmiuorVvbZ5YP3CIaDo(7xqorp5CwLtS(QdFoAIvkgTXklhPamGdnh4cRB6oKZrNYXYrctSCWWFJx(nY1YxEb9ncTiZtVxuQUG(EmIxqFJO10De6fP3im8nss)nYyFJ3BeuRAt3r3iOMdGUrAYrhie4F7r(X1QqlY807fLkErEwVYCeohimuUNjKCIjhe4iMd4C0KdXCnSK49Q0XVGCefZHyUgws8EvsSZQCefZHyUgwsChWALAjH85OnhrXC0bcb(3EKFCTk0Imp9ErPIxKN1RmhHZXyFJxU8Tk0fXjHqmGNuF7r5etoiWrmhW5OjhI5AyjX7v5awRYrumhI5AyjXLyNvQLeYNJOyoeZ1WsIBlYQLeYNJ2C0MJOyo(KJoqiW)2J8JRvHwK5P3lkvCa4BeuRuR5r3iPfi1JvassjHjN7(3Jp8c6BeTMUJqVi9gXQ(PQTBKMC8jhOw1MUJ4slqQhRaKKsctoxoII5OjhDGqGxguAXasvOOn2iZlYZ6vMJV5aHHY9mHKdOMdJAxoAYXKFzofm2pv5CAoGaHC0Md4C0bcbEzqPfdivHI2yJmhaohT5OnhrXCm5xMtbJ9tvocNJqJWnYyFJ3BK8TscuqO7FpgexqFJO10De6fP3iw1pvTDJ0KduRAt3rCgEHIptkusI8YYbCo9(ubJD2tOQqdrWRkYZ6vMJW5GiiqihW54tomm2HI9VCMP6LXlYqrohrXC0bcboZu9Y4aW5OnhW5yYVmNcg7NQC8nNJIqoGZrto6aHaNyUgwskhWAfVipRxzocNdIiKJOyo6aHaNyUgwskj2zfVipRxzocNdIiKJ2CefZj0qe8QI8SEL54BoiIWnYyFJ3BedVqXNj1lGus4U6xE)7Xh9c6BeTMUJqVi9gXQ(PQTBKp5GIFUHAWFdLus)w5PqnpdcX)MDUxi5aohFYXyFJxUHAWFdLus)w5PqnpdcX7vfCnebFoGZrto(Kdk(5gQb)nusj9BLNsazo(3SZ9cjhrXCqXp3qn4VHskPFR8uciZXlYZ6vMJW5aYC0MJOyoO4NBOg83qjL0VvEkuZZGqC5BSZ54BoGihW5GIFUHAWFdLus)w5PqnpdcXlYZ6vMJV5aICaNdk(5gQb)nusj9BLNc18mie)B25EHCJm2349gzOg83qjL0VvE3igYmhPERGqV8EmI3)EmiVG(grRP7i0lsVrSQFQA7gvuOiPat3r5aoN3ki0Z)2JupwH2uocNdIhMd4C0KJMC0bcboZu9Y4f5z9kZr4CazoGZrto6aHaVmO0IbKQqrBSrMxKN1RmhHZbK5ikMJp5Odec8YGslgqQcfTXgzoaCoAZrumhFYrhie4mt1lJdaNJOyoM8lZPGX(PkhFZbeiKJ2CaNJMC8jhDGqGFUx0IqvKhm2pvE0(kAPcshBIdaNJOyoM8lZPGX(PkhFZbeiKJ2CaNJbRyci25C0EJm2349g5HXBOl6gXqM5i1Bfe6L3Jr8(3JJLlOVr0A6oc9I0BeR6NQ2UrffkskW0DuoGZ5Tcc98V9i1JvOnLJW5G4H5aohn5OjhDGqGZmvVmErEwVYCeohqMd4C0KJoqiWldkTyaPku0gBK5f5z9kZr4CazoII54to6aHaVmO0IbKQqrBSrMdaNJ2CefZXNC0bcboZu9Y4aW5ikMJj)YCkySFQYX3Cabc5OnhW5OjhFYrhie4N7fTiuf5bJ9tLhTVIwQG0XM4aW5ikMJj)YCkySFQYX3Cabc5OnhW5yWkMaIDohT3iJ9nEVrsGn0fDJyiZCK6Tcc9Y7XiE)7XGYlOVr0A6oc9I0BeR6NQ2UrffkskW0DuoGZ5Tcc98V9i1JvOnLJW5GySKd4C0KJMC0bcboZu9Y4f5z9kZr4CazoGZrto6aHaVmO0IbKQqrBSrMxKN1RmhHZbK5ikMJp5Odec8YGslgqQcfTXgzoaCoAZrumhFYrhie4mt1lJdaNJOyoM8lZPGX(PkhFZbeiKJ2CaNJMC8jhDGqGFUx0IqvKhm2pvE0(kAPcshBIdaNJOyoM8lZPGX(PkhFZbeiKJ2CaNJbRyci25C0EJm2349gjFY5SsfCwr3igYmhPERGqV8EmI3)E8rEb9nIwt3rOxKEJyv)u12nYGvmbe78nYyFJ3BuaxmsHdQ1EGIU)9yH(c6BeTMUJqVi9gXQ(PQTBKoqiWzMQxgha(gzSVX7nQmO0IbKQqrBSr((3JreHlOVr0A6oc9I0BeR6NQ2UrAYrto6aHaNyUgwskj2zfVipRxzocNdIiKJOyo6aHaNyUgwskhWAfVipRxzocNdIiKJ2CaNddJDOy)lNzQEz8I8SEL5iCoGaHC0MJOyomm2HI9VCMP6LXlYqr(gzSVX7n6CVOfHQKWD1V8(3JreXlOVr0A6oc9I0BeR6NQ2UrAYrto6aHa)CVOfHQipySFQ8O9v0sfKo2ehaohrXC8jhggkT2(8ZixTT5OnhrXCyyO0A7Z3gIGxfmkhrXCGAvB6oI3sLHPCefZrhie46omg1biFoaCoGZrhie46omg1biFErEwVYC8nNdriNyYrtohnhqnhgErb6NdxeRLKYCnK1J2NtRP7i0C0MJ2CaNJp5OdecCMP6LXbGZbCoAYXNCyyO0A7Z3gIGxfmkhrXCyySdf7F5m8cfFMuVasjH7QFjhaohrXC69Pcg7SNqvHgIGxvKN1RmhFZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL5etoXsoII507tfm2zpHQcnebVQipRxzoiroiEKiKJV5Cic5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0EJm2349gXihj)2CkZ1qwpA)7FpgXdVG(grRP7i0lsVrSQFQA7gPjhn5Odec8Z9IweQI8GX(PYJ2xrlvq6ytCa4CefZXNCyyO0A7ZpJC12MJ2CefZHHHsRTpFBicEvWOCefZbQvTP7iElvgMYrumhDGqGR7WyuhG85aW5aohDGqGR7WyuhG85f5z9kZX3Cabc5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0Md4C8jhDGqGZmvVmoaCoGZrto(KdddLwBF(2qe8QGr5ikMddJDOy)lNHxO4ZK6fqkjCx9l5aW5ikMtVpvWyN9eQk0qe8QI8SEL54Bomm2HI9VCgEHIptQxaPKWD1VKxKN1RmNyYjwYrumNEFQGXo7juvOHi4vf5z9kZbjYbXJeHC8nhqGqoXKJMCoAoGAom8Ic0phUiwljL5AiRhTpNwt3rO5OnhT3iJ9nEVr9YSATVX79VhJiiUG(grRP7i0lsVry4BKK(BKX(gV3iOw1MUJUrqnhaDJ0KJp5WWyhk2)YzMQxgVidf5CefZXNCGAvB6oIZWlu8zsHssKxwoGZHHHsRTpFBicEvWOC0EJGALAnp6gjnOKkGlfZu9YU)9yep6f03iAnDhHEr6nIv9tvB3iI5AyjX7vzlY5aohdwXeqSZ5aohn5GIFUHAWFdLus)w5PqnpdcX)MDUxi5ikMJp5WWqP12NVeRWoCHMJ2CaNduRAt3rCPbLubCPyMQx2nYyFJ3BuaOqwHdkYbS09VhJiiVG(grRP7i0lsVrSQFQA7gXWqP12NVnebVkyuoGZbQvTP7iodVqXNjfkjrEz5aoht(L5uWy)uLJWXZ5OiKd4CyySdf7F5m8cfFMuVasjH7QFjVipRxzo(Mdegk3ZesoGAomQD5Ojht(L5uWy)uLZP5aceYr7nYyFJ3BK8TscuqO7FpgXy5c6BeTMUJqVi9gXQ(PQTBKMC0bcboXCnSKuoG1koaCoII5OjhMaRGqYCINZH5aoNIycSccP(2JYX3CazoAZrumhMaRGqYCINdiYrBoGZXGvmbe7CoGZbQvTP7iU0GsQaUumt1l7gzSVX7nAj)kpmEV)9yebLxqFJO10De6fP3iw1pvTDJ0KJoqiWjMRHLKYbSwXbGZbCo(KdddLwBF(zKR22CefZrto6aHa)CVOfHQipySFQ8O9v0sfKo2ehaohW5WWqP12NFg5QTnhT5ikMJMCycSccjZjEohMd4CkIjWkiK6BpkhFZbK5OnhrXCycSccjZjEoGihrXC0bcboZu9Y4aW5OnhW5yWkMaIDohW5a1Q20DexAqjvaxkMP6LDJm2349gjWCbLhgV3)EmIh5f03iAnDhHEr6nIv9tvB3in5OdecCI5AyjPCaRvCa4CaNJp5WWqP12NFg5QTnhrXC0KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZbCommuAT95NrUABZrBoII5OjhMaRGqYCINZH5aoNIycSccP(2JYX3CazoAZrumhMaRGqYCINdiYrumhDGqGZmvVmoaCoAZbCogSIjGyNZbCoqTQnDhXLgusfWLIzQEz3iJ9nEVrbaNt5HX79VhJOqFb9nYyFJ3BKFRQgxkCqroGLUr0A6oc9I07Fp(qeUG(grRP7i0lsVrSQFQA7grmxdljEVkhWAvoII5qmxdljUe7SsTKq(CefZHyUgwsCBrwTKq(CefZrhie4(TQACPWbf5awIdaNd4C0bcboXCnSKuoG1koaCoII5OjhDGqGZmvVmErEwVYC8nhJ9nE5(l7fWjHqmGNuF7r5aohDGqGZmvVmoaCoAVrg7B8EJKVvHUO7Fp(qeVG(gzSVX7nYFzVGBeTMUJqVi9(3Jp8WlOVr0A6oc9I0BKX(gV3Ocyvg7B8QCT8VrUw(Q18OBuWCUxqbC)7FJGlc2EMaL8VG(EmIxqFJO10De6fP3iw1pvTDJkkuKuGP7OCaNZBfe65F7rQhRqBkhHZbXdZbCoAYrto6aHaNzQEz8I8SEL5iCoGmhrXC8jhDGqGZmvVmoaCoII5yYVmNcg7NQC8nhqGqoAZbCogSIjGyNZr7nYyFJ3BKhgVHUOBedzMJuVvqOxEpgX7Fp(WlOVr0A6oc9I0BeR6NQ2UrffkskW0DuoGZ5Tcc98V9i1JvOnLJW5G4H5aohn5OjhDGqGZmvVmErEwVYCeohqMJOyo(KJoqiWzMQxghaohrXCm5xMtbJ9tvo(MdiqihT5aohdwXeqSZ5O9gzSVX7nscSHUOBedzMJuVvqOxEpgX7FpgexqFJO10De6fP3iw1pvTDJkkuKuGP7OCaNZBfe65F7rQhRqBkhHZbXyjhW5Ojhn5OdecCMP6LXlYZ6vMJW5aYCefZXNC0bcboZu9Y4aW5ikMJj)YCkySFQYX3Cabc5OnhW5yWkMaIDohT3iJ9nEVrYNCoRubNv0nIHmZrQ3ki0lVhJ49VhF0lOVr0A6oc9I0BeR6NQ2UrgSIjGyNVrg7B8EJc4IrkCqT2du09VhdYlOVr0A6oc9I0BeR6NQ2UrAYXKFzofm2pv5iCocnc5ikMJoqiW1DymQdq(Ca4CaNJoqiW1DymQdq(8I8SEL54Bohgl5OnhW54to6aHaNzQEzCa4BKX(gV3ig5i53MtzUgY6r7F)7XXYf03iAnDhHEr6nIv9tvB3in5yYVmNcg7NQCeohHgHCefZrhie46omg1biFoaCoGZrhie46omg1biFErEwVYC8nhqel5OnhW54to6aHaNzQEzCa4BKX(gV3OEzwT2349(3JbLxqFJO10De6fP3im8nss)nYyFJ3BeuRAt3r3iOMdGUr(KddJDOy)lNzQEz8ImuKVrqTsTMhDJKgusfWLIzQEz3)E8rEb9nIwt3rOxKEJyv)u12nIyUgws8Ev2ICoGZXGvmbe7CoGZbQvTP7iU0GsQaUumt1l7gzSVX7nkauiRWbf5aw6(3Jf6lOVr6aHGAnp6gjFRC4c9grRP7i0lsVrSQFQA7gPdecC5BLdxO8I8SEL54BoXsoGZrto6aHaNyUgwskj2zfhaohrXC0bcboXCnSKuoG1koaCoAZbCoM8lZPGX(PkhHZrOr4gzSVX7nIzlJCkDGq4(3JreHlOVr0A6oc9I0BeR6NQ2UrAYXNCSytv)ex(fzN7fIs(wj5LTNZrumhDGqGZmvVmErEwVYC8nhsied4j13EuoII54toWfbLlFRKafekhT5aohn5OdecCMP6LXbGZrumht(L5uWy)uLJW5i0iKd4CiMRHLeVxLTiNJ2BKX(gV3i5BLeOGq3)EmIiEb9nIwt3rOxKEJyv)u12nsto(KJfBQ6N4YVi7CVquY3kjVS9CoII5OdecCMP6LXlYZ6vMJV5qcHyapP(2JYrumhFYbUiOC5BLeOGq5OnhW58MJ2NlFRC4cLtRP7i0CaNJMC0bcbU8TYHluoaCoII5yYVmNcg7NQCeohHgHC0Md4C0bcbU8TYHluU8n25C8nhqKd4C0KJoqiWjMRHLKsIDwXbGZrumhDGqGtmxdljLdyTIdaNJ2CaNddJDOy)lNzQEz8I8SEL5iCoGYBKX(gV3i5BLeOGq3)EmIhEb9nIwt3rOxKEJyv)u12nsto(KJfBQ6N4YVi7CVquY3kjVS9CoII5OdecCMP6LXlYZ6vMJV5qcHyapP(2JYrumhFYbUiOC5BLeOGq5OnhW5OdecCI5AyjPKyNv8I8SEL5iCoGYCaNdXCnSK49QKyNv5aohFY5nhTpx(w5WfkNwt3rO5aohgg7qX(xoZu9Y4f5z9kZr4CaL3iJ9nEVrY3kjqbHU)9yebXf03iAnDhHEr6nIv9tvB3in5OdecCI5AyjPCaRvCa4CefZrtombwbHK5epNdZbCofXeyfes9ThLJV5aYC0MJOyombwbHK5ephqKJ2CaNJbRyci25CaNduRAt3rCPbLubCPyMQx2nYyFJ3B0s(vEy8E)7XiE0lOVr0A6oc9I0BeR6NQ2UrAYrhie4eZ1Wss5awR4aW5ikMJMCycSccjZjEohMd4CkIjWkiK6BpkhFZbK5OnhrXCycSccjZjEoGihrXC0bcboZu9Y4aW5OnhW5yWkMaIDohW5a1Q20DexAqjvaxkMP6LDJm2349gjWCbLhgV3)EmIG8c6BeTMUJqVi9gXQ(PQTBKMC0bcboXCnSKuoG1koaCoII5OjhMaRGqYCINZH5aoNIycSccP(2JYX3CazoAZrumhMaRGqYCINdiYrumhDGqGZmvVmoaCoAZbCogSIjGyNZbCoqTQnDhXLgusfWLIzQEz3iJ9nEVrbaNt5HX79VhJySCb9nYyFJ3BKFRQgxkCqroGLUr0A6oc9I07Fpgrq5f03iAnDhHEr6nIv9tvB3in5yXMQ(jU8lYo3leL8TsYlBpNd4C0bcboZu9Y4f5z9kZr4CiHqmGNuF7r5aoh4IGY9x2lihT5ikMJMC8jhl2u1pXLFr25EHOKVvsEz75CefZrhie4mt1lJxKN1RmhFZHecXaEs9ThLJOyo(KdCrq5Y3QqxuoAZbCoAYHyUgws8EvoG1QCefZHyUgwsCj2zLAjH85ikMdXCnSK42ISAjH85ikMJoqiW9Bv14sHdkYbSehaohW5OdecCI5AyjPCaRvCa4CefZrto6aHaNzQEz8I8SEL54Bog7B8Y9x2lGtcHyapP(2JYbCo6aHaNzQEzCa4C0MJ2CefZrtowSPQFIJA(3EHOKalVS9CocNZH5aohDGqGtmxdljLe7SIxKN1RmhHZbK5aohFYrhie4OM)TxikjWYlYZ6vMJW5ySVXl3FzVaojeIb8K6BpkhT3iJ9nEVrY3Qqx09VhJ4rEb9nIwt3rOxKEJyv)u12n6nhTpx(KZzLcT6WZP10DeAoGZrhie4Y3QG5C8Icfjfy6okhW5eAicEvrEwVYCeohDGqGlFRcMZXrbk7B8Md4C0KJp5qmxdljEVkBrohrXC0bcbU8Tscuqif5bJ9tLhTphaohT3iJ9nEVrY3QG5C3)EmIc9f03iJ9nEVr(l7fCJO10De6fP3)E8HiCb9nIwt3rOxKEJm2349gvaRYyFJxLRL)nY1YxTMhDJcMZ9ckG7F)Bekfma3Fb99yeVG(gzSVX7nsIDwP0jZ7grRP7i0lsV)94dVG(grRP7i0lsVry4BKK(BKX(gV3iOw1MUJUrqnhaDJKWKZPERGqVKlFRcMZLJW5GyoGZrto(KZBoAFU8TYHluoTMUJqZrumN3C0(C5toNvk0QdpNwt3rO5OnhrXCKWKZPERGqVKlFRcMZLJW5C4ncQvQ18OBulvgMU)9yqCb9nIwt3rOxKEJWW3ij93iJ9nEVrqTQnDhDJGAoa6gjHjNt9wbHEjx(wf6IYr4Cq8gb1k1AE0nQLkMJmO09VhF0lOVr0A6oc9I0BeR6NQ2UrAYXNCyyO0A7Z3gIGxfmkhrXC8jhgg7qX(xodVqXNj1lGus4U6xYbGZrBoGZrhie4mt1lJdaFJm2349gPtLKQZ9c5(3Jb5f03iAnDhHEr6nIv9tvB3iDGqGZmvVmoa8nYyFJ3Bem(B8E)7XXYf03iJ9nEVrass1p5jVr0A6oc9I07FpguEb9nIwt3rOxKEJyv)u12nYrqjxo(Mdir8gzSVX7nsaz1RiPKwgD)7Xh5f03iAnDhHEr6nIv9tvB3iOw1MUJ4Tuzy6gj)Qz)9yeVrg7B8EJkGvzSVXRY1Y)g5A5RwZJUrgMU)9yH(c6BeTMUJqVi9gXQ(PQTBubSuaxqi(3EKFCTk0Imp9ErPItizGggMqVrYVA2FpgXBKX(gV3Ocyvg7B8QCT8VrUw(Q18OBeArMNEVOuD)7XiIWf03iAnDhHEr6nIv9tvB3OcyPaUGqCDZzlJu4GYCo1lOxisoHKbAyyc9gj)Qz)9yeVrg7B8EJkGvzSVXRY1Y)g5A5RwZJUr6y7V)9yer8c6BeTMUJqVi9gzSVX7nQawLX(gVkxl)BeR6NQ2Urock5Yr4Cajc3ixlF1AE0ns(3)EmIhEb9nIwt3rOxKEJm2349gvaRYyFJxLRL)nY1YxTMhDJGlc2EMaL8V)9Vr6y7VG(EmIxqFJO10De6fP3iw1pvTDJ0bcboZu9Y4aW3iJ9nEVrLbLwmGufkAJnY3)E8HxqFJO10De6fP3im8nss)nYyFJ3BeuRAt3r3iOMdGUrbhgx5Ojhn507tfm2zpHQcnebVQipRxzoiPCoeHC0MZP5G4HiKJ2CeoNGdJRC0KJMC69Pcg7SNqvHgIGxvKN1RmhKuohcYCqs5OjherihqnN3C0(8EzwT234LtRP7i0C0Mdskhn5C0Ca1Cy4ffOFoCrSwskZ1qwpAFoTMUJqZrBoAZ50Cq8irihT3iOwPwZJUrm8cfFMuOKe5LD)7XG4c6BeTMUJqVi9gHHVrs6Vrg7B8EJGAvB6o6gb1Ca0nYNC0bcbUU5SLrkCqzoN6f0lePAThOioaCoGZXNC0bcbUU5SLrkCqzoN6f0lePYkMTeha(gb1k1AE0nIv9V4ha((3Jp6f03iAnDhHEr6nIv9tvB3iDGqGRBoBzKchuMZPEb9crQw7bkIlFJDwb1Cauo(MZrrihW5OdecCDZzlJu4GYCo1lOxisLvmBjU8n2zfuZbq54BohfHCaNJMC8jhu8Znud(BOKs63kpfQ5zqi(3SZ9cjhW54tog7B8Ynud(BOKs63kpfQ5zqiEVQGRHi4ZbCoAYXNCqXp3qn4VHskPFR8uciZX)MDUxi5ikMdk(5gQb)nusj9BLNsazoErEwVYCeohqKJ2CefZbf)Cd1G)gkPK(TYtHAEgeIlFJDohFZbe5aohu8Znud(BOKs63kpfQ5zqiErEwVYC8nhqMd4CqXp3qn4VHskPFR8uOMNbH4FZo3lKC0EJm2349gzOg83qjL0VvE3igYmhPERGqV8EmI3)EmiVG(grRP7i0lsVrSQFQA7gPjhOw1MUJ4m8cfFMuOKe5LLd4C69Pcg7SNqvHgIGxvKN1RmhHZbrqGqoGZXNCyySdf7F5mt1lJxKHICoII5OdecCMP6LXbGZrBoGZrto6aHax3C2YifoOmNt9c6fIuT2duex(g7ScQ5aOCINdirihrXC0bcbUU5SLrkCqzoN6f0lePYkMTex(g7ScQ5aOCINdirihT5ikMtOHi4vf5z9kZX3CqeHBKX(gV3igEHIptQxaPKWD1V8(3JJLlOVr6aHGAnp6gjFRC4c9grRP7i0lsVrSQFQA7gPjhDGqGRBoBzKchuMZPEb9crQw7bkIxKN1RmhHZ5OCqMJOyo6aHax3C2YifoOmNt9c6fIuzfZwIxKN1RmhHZ5OCqMJ2CaNJj)YCkySFQYr445i0iKd4C0KddJDOy)lNzQEz8I8SEL5iCoGYCefZrtomm2HI9VCYdg7NkLoEr5f5z9kZr4CaL5aohFYrhie4N7fTiuf5bJ9tLhTVIwQG0XM4aW5aohggkT2(8ZixTT5OnhT3iJ9nEVrmBzKtPdec3)EmO8c6BeTMUJqVi9gXQ(PQTBKp5a1Q20DeNv9V4haohW5OjhggkT2(8THi4vbJYrumhgg7qX(xoZu9Y4f5z9kZr4CaL5ikMJMCyySdf7F5Khm2pvkD8IYlYZ6vMJW5akZbCo(KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZbCommuAT95NrUABZrBoAVrg7B8EJKVvsGccD)7Xh5f03iAnDhHEr6nIv9tvB3in5WWyhk2)Yz4fk(mPEbKsc3v)soaCoGZrtoqTQnDhXz4fk(mPqjjYllhrXCyySdf7F5mt1lJxKN1RmhFZbK5OnhT5aoht(L5uWy)uLJW5aseYbCommuAT95BdrWRcgDJm2349gjFRKafe6(3Jf6lOVr0A6oc9I0BeR6NQ2UrffkskW0DuoGZ5Tcc98V9i1JvOnLJW5GySKd4C0KJbRyci25CaNJMCGAvB6oIZQ(x8daNJOyoAYXKFzofm2pv54BoGaHCaNJp5OdecCMP6LXbGZrBoII5WWyhk2)YzMQxgVidf5C0MJ2BKX(gV3ijWg6IUrmKzos9wbHE59yeV)9yer4c6BeTMUJqVi9gXQ(PQTBurHIKcmDhLd4CERGqp)Bps9yfAt5iCoiccoiZbCoAYXGvmbe7CoGZrtoqTQnDhXzv)l(bGZrumhn5yYVmNcg7NQC8nhqGqoGZXNC0bcboZu9Y4aW5OnhrXCyySdf7F5mt1lJxKHICoAZbCo(KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZr7nYyFJ3BKhgVHUOBedzMJuVvqOxEpgX7FpgreVG(grRP7i0lsVrSQFQA7gvuOiPat3r5aoN3ki0Z)2JupwH2uocNdIXsoXKtrEwVYCaNJMCmyftaXoNd4C0KduRAt3rCw1)IFa4CefZXKFzofm2pv54BoGaHCefZHHXouS)LZmvVmErgkY5OnhT3iJ9nEVrYNCoRubNv0nIHmZrQ3ki0lVhJ49VhJ4HxqFJO10De6fP3iw1pvTDJmyftaXoFJm2349gfWfJu4GAThOO7FpgrqCb9nIwt3rOxKEJyv)u12nstoeZ1WsI3RYwKZrumhI5AyjXLyNvQEviMJOyoeZ1WsI7awRu9QqmhT5aohn54tommuAT95BdrWRcgLJOyoAYXKFzofm2pv54BocniZbCoAYbQvTP7ioR6FXpaCoII5yYVmNcg7NQC8nhqGqoII5a1Q20DeVLkdt5OnhW5OjhOw1MUJ4m8cfFMuOKe5LLd4C8jhgg7qX(xodVqXNj1lGus4U6xYbGZrumhFYbQvTP7iodVqXNjfkjrEz5aohFYHHXouS)LZmvVmoaCoAZrBoAZbCoAYHHXouS)LZmvVmErEwVYCeohqGqoII5yYVmNcg7NQCeohHgHCaNddJDOy)lNzQEzCa4CaNJMCyySdf7F5Khm2pvkD8IYlYZ6vMJV5ySVXlx(wf6I4KqigWtQV9OCefZXNCyyO0A7ZpJC12MJ2CefZP3NkySZEcvfAicEvrEwVYC8nherihT5aohn5GIFUHAWFdLus)w5PqnpdcXlYZ6vMJW5C0CefZXNCyyO0A7ZxIvyhUqZr7nYyFJ3BuaOqwHdkYbS09VhJ4rVG(grRP7i0lsVrSQFQA7gPjhI5AyjXDaRvQLeYNJOyoeZ1WsIlXoRuljKphrXCiMRHLe3wKvljKphrXC0bcbUU5SLrkCqzoN6f0lePAThOiErEwVYCeoNJYbzoII5OdecCDZzlJu4GYCo1lOxisLvmBjErEwVYCeoNJYbzoII5yYVmNcg7NQCeohHgHCaNddJDOy)lNzQEz8ImuKZrBoGZrtomm2HI9VCMP6LXlYZ6vMJW5aceYrumhgg7qX(xoZu9Y4fzOiNJ2CefZP3NkySZEcvfAicEvrEwVYC8nher4gzSVX7n6CVOfHQKWD1V8(3JreKxqFJO10De6fP3iw1pvTDJ0KJj)YCkySFQYr4CeAeYbCoAYrhie4N7fTiuf5bJ9tLhTVIwQG0XM4aW5ikMJp5WWqP12NFg5QTnhT5ikMdddLwBF(2qe8QGr5ikMJoqiW1DymQdq(Ca4CaNJoqiW1DymQdq(8I8SEL54BohIqoXKJMCoAoGAom8Ic0phUiwljL5AiRhTpNwt3rO5OnhT5aohn54tommuAT95BdrWRcgLJOyomm2HI9VCgEHIptQxaPKWD1VKdaNJOyo9(ubJD2tOQqdrWRkYZ6vMJV5WWyhk2)Yz4fk(mPEbKsc3v)sErEwVYCIjNyjhrXC69Pcg7SNqvHgIGxvKN1RmhKihepseYX3CoeHCIjhn5C0Ca1Cy4ffOFoCrSwskZ1qwpAFoTMUJqZrBoAVrg7B8EJyKJKFBoL5AiRhT)9VhJySCb9nIwt3rOxKEJyv)u12nstoM8lZPGX(PkhHZrOrihW5OjhDGqGFUx0IqvKhm2pvE0(kAPcshBIdaNJOyo(KdddLwBF(zKR22C0MJOyommuAT95BdrWRcgLJOyo6aHax3HXOoa5ZbGZbCo6aHax3HXOoa5ZlYZ6vMJV5aceYjMC0KZrZbuZHHxuG(5WfXAjPmxdz9O950A6ocnhT5OnhW5OjhFYHHHsRTpFBicEvWOCefZHHXouS)LZWlu8zs9ciLeUR(LCa4CefZbQvTP7iodVqXNjfkjrEz5aoNEFQGXo7juvOHi4vf5z9kZr4Cq8iriNyY5qeYjMC0KZrZbuZHHxuG(5WfXAjPmxdz9O950A6ocnhT5ikMtVpvWyN9eQk0qe8QI8SEL54Bomm2HI9VCgEHIptQxaPKWD1VKxKN1RmNyYjwYrumNEFQGXo7juvOHi4vf5z9kZX3Cabc5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0EJm2349g1lZQ1(gV3)EmIGYlOVr0A6oc9I0BeR6NQ2UrmmuAT95BdrWRcgLd4C0KduRAt3rCgEHIptkusI8YYrumhgg7qX(xoZu9Y4f5z9kZX3CqeHC0Md4Cm5xMtbJ9tvocNdirihW5WWyhk2)Yz4fk(mPEbKsc3v)sErEwVYC8nher4gzSVX7ns(wjbki09VhJ4rEb9nIwt3rOxKEJWW3ij93iJ9nEVrqTQnDhDJGAoa6grmxdljEVkhWAvoGAohzoNMJX(gVC5BvOlItcHyapP(2JYjMC8jhI5AyjX7v5awRYbuZjwY50Cm234L7VSxaNecXaEs9ThLtm5Ga)WConhjm5CkbM8PBeuRuR5r3itchRJQiID)7Xik0xqFJO10De6fP3iw1pvTDJ0KtVpvWyN9eQk0qe8QI8SEL54BohnhrXC0KJoqiWldkTyaPku0gBK5f5z9kZX3CGWq5EMqYbuZHrTlhn5yYVmNcg7NQConhqGqoAZbCo6aHaVmO0IbKQqrBSrMdaNJ2C0MJOyoAYXKFzofm2pv5etoqTQnDhXnjCSoQIiwoGAo6aHaNyUgwskj2zfVipRxzoXKdk(5bGczfoOihWs8VzNLQI8SEZbuZ5qoiZr4Cq8qeYrumht(L5uWy)uLtm5a1Q20De3KWX6OkIy5aQ5OdecCI5AyjPCaRv8I8SEL5etoO4NhakKv4GICalX)MDwQkYZ6nhqnNd5GmhHZbXdrihT5aohI5AyjX7vzlY5aohn5OjhFYHHXouS)LZmvVmoaCoII5WWqP12NFg5QTnhW54tomm2HI9VCYdg7NkLoEr5aW5OnhrXCyyO0A7Z3gIGxfmkhT5aohn54tommuAT95qP9fGCLJOyo(KJoqiWzMQxghaohrXCm5xMtbJ9tvocNJqJqoAZrumhDGqGZmvVmErEwVYCeoNJmhW54to6aHaVmO0IbKQqrBSrMdaFJm2349gjFRKafe6(3JpeHlOVr0A6oc9I0BeR6NQ2UrAYrhie4eZ1Wss5awR4aW5ikMJMCycSccjZjEohMd4CkIjWkiK6BpkhFZbK5OnhrXCycSccjZjEoGihT5aohdwXeqSZ3iJ9nEVrl5x5HX79VhFiIxqFJO10De6fP3iw1pvTDJ0KJoqiWjMRHLKYbSwXbGZrumhn5WeyfesMt8ComhW5uetGvqi13Euo(MdiZrBoII5WeyfesMt8CaroAZbCogSIjGyNVrg7B8EJeyUGYdJ37Fp(WdVG(grRP7i0lsVrSQFQA7gPjhDGqGtmxdljLdyTIdaNJOyoAYHjWkiKmN45CyoGZPiMaRGqQV9OC8nhqMJ2CefZHjWkiKmN45aIC0Md4CmyftaXoFJm2349gfaCoLhgV3)E8HG4c6BKX(gV3i)wvnUu4GICalDJO10De6fP3)E8Hh9c6BeTMUJqVi9gXQ(PQTBeXCnSK49QCaRv5ikMdXCnSK4sSZk1sc5ZrumhI5AyjXTfz1sc5ZrumhDGqG73QQXLchuKdyjoaCoGZHyUgws8EvoG1QCefZrto6aHaNzQEz8I8SEL54Bog7B8Y9x2lGtcHyapP(2JYbCo6aHaNzQEzCa4C0EJm2349gjFRcDr3)E8HG8c6BKX(gV3i)L9cUr0A6oc9I07Fp(Wy5c6BeTMUJqVi9gzSVX7nQawLX(gVkxl)BKRLVAnp6gfmN7fua3)(3idtxqFpgXlOVr0A6oc9I0Beg(gjP)gzSVX7ncQvTP7OBeuZbq3in5Odec8V9i)4AvOfzE69IsfVipRxzo(Mdegk3ZesoXKdcCeZrumhDGqG)Th5hxRcTiZtVxuQ4f5z9kZX3Cm234LlFRcDrCsied4j13EuoXKdcCeZbCoAYHyUgws8EvoG1QCefZHyUgwsCj2zLAjH85ikMdXCnSK42ISAjH85OnhT5aohDGqG)Th5hxRcTiZtVxuQ4aW5aoNcyPaUGq8V9i)4AvOfzE69IsfNqYanmmHEJGALAnp6gHwK5P83oNkyoNchc3)E8HxqFJO10De6fP3iw1pvTDJ0bcbU8TkyohVOqrsbMUJYbCoAYrctoN6Tcc9sU8Tkyoxo(MdiYrumhFYPawkGlie)BpYpUwfArMNEVOuXjKmqddtO5OnhW5OjhFYPawkGlie3HmZktQcoI(EHOG4ApyjXjKmqddtO5ikMZ3EuoirohfK5iCo6aHax(wfmNJxKN1RmNyY5WC0EJm2349gjFRcMZD)7XG4c6BeTMUJqVi9gXQ(PQTBubSuaxqi(3EKFCTk0Imp9ErPItizGggMqZbCosyY5uVvqOxYLVvbZ5Yr445aICaNJMC8jhDGqG)Th5hxRcTiZtVxuQ4aW5aohDGqGlFRcMZXlkuKuGP7OCefZrtoqTQnDhXrlY8u(BNtfmNtHdHCaNJMC0bcbU8TkyohVipRxzo(MdiYrumhjm5CQ3ki0l5Y3QG5C5iCohMd4CEZr7ZLp5CwPqRo8CAnDhHMd4C0bcbU8TkyohVipRxzo(MdiZrBoAZr7nYyFJ3BK8Tkyo39VhF0lOVr0A6oc9I0Beg(gjP)gzSVX7ncQvTP7OBeuZbq3it(L5uWy)uLJW5CKiKdskhn5Gic5aQ5Odec8V9i)4AvOfzE69Isfx(g7CoAZbjLJMC0bcbU8TkyohVipRxzoGAoGiNtZrctoNsGjFkhT5GKYrtoO4NhakKv4GICalXlYZ6vMdOMdiZrBoGZrhie4Y3QG5CCa4BeuRuR5r3i5BvWCoLF8(QG5CkCiC)7XG8c6BeTMUJqVi9gXQ(PQTBeuRAt3rC0ImpL)25ubZ5u4qihW5a1Q20Dex(wfmNt5hVVkyoNchc3iJ9nEVrY3kjqbHU)94y5c6BeTMUJqVi9gXQ(PQTBurHIKcmDhLd4CERGqp)Bps9yfAt5iCoiE0Cqs5iHjNt9wbHEzoXKtrEwVYCaNJbRyci25CaNdXCnSK49QSf5BKX(gV3ijWg6IUrmKzos9wbHE59yeV)9yq5f03iAnDhHEr6nIv9tvB3iFY5B25EHKd4C8jhJ9nE5gQb)nusj9BLNc18mieVxvW1qe85ikMdk(5gQb)nusj9BLNc18miex(g7Co(MdiYbCoO4NBOg83qjL0VvEkuZZGq8I8SEL54BoG4gzSVX7nYqn4VHskPFR8UrmKzos9wbHE59yeV)94J8c6BeTMUJqVi9gXQ(PQTBurHIKcmDhLd4CERGqp)Bps9yfAt5iCoAYbXJMtm5Ojhjm5CQ3ki0l5Y3QqxuoGAoiYbzoAZrBoNMJeMCo1Bfe6L5etof5z9kZbCoAYrtomm2HI9VCMP6LXlYqrohrXCKWKZPERGqVKlFRcDr54BoGihrXC0KdXCnSK49QKyNv5ikMdXCnSK49Q0XVGCefZHyUgws8EvoG1QCaNJp58MJ2NlXaofoOEbKkGls(CAnDhHMJOyo6aHahUApCH2MtzfZ2MPGbCsR4qnhaLJWXZ5qqIqoAZbCoAYrctoN6Tcc9sU8Tk0fLJV5Gic5aQ5OjheZjMCEZr7ZF)9Q8W4vYP10DeAoAZrBoGZXKFzofm2pv5iCoGeHCqs5OdecC5BvWCoErEwVYCa1CILC0Md4C8jhDGqGFUx0IqvKhm2pvE0(kAPcshBIdaNd4CmyftaXoNJ2BKX(gV3ipmEdDr3igYmhPERGqV8EmI3)ESqFb9nIwt3rOxKEJyv)u12nstoqTQnDhXz4fk(mPqjjYllhW507tfm2zpHQcnebVQipRxzocNdIGaHCaNJp5WWyhk2)YzMQxgVidf5CefZrhie4mt1lJdaNJ2CaNJj)YCkySFQYX3Cajc5aohn5OdecCI5AyjPCaRv8I8SEL5iCoXsoII5OdecCI5AyjPKyNv8I8SEL5iCohnhT5ikMtOHi4vf5z9kZX3CqeHBKX(gV3igEHIptQxaPKWD1V8(3JreHlOVr0A6oc9I0BeR6NQ2UrgSIjGyNVrg7B8EJc4IrkCqT2du09VhJiIxqFJO10De6fP3iw1pvTDJ0bcboZu9Y4aW3iJ9nEVrLbLwmGufkAJnY3)EmIhEb9nIwt3rOxKEJyv)u12nsto6aHax(wfmNJdaNJOyoM8lZPGX(PkhHZbKiKJ2CaNJp5OdecCj2j)MrCa4CaNJp5OdecCMP6LXbGZbCoAYXNCyyO0A7Z3gIGxfmkhrXCyySdf7F5m8cfFMuVasjH7QFjhaohrXC69Pcg7SNqvHgIGxvKN1RmhFZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL5etoXsoII507tfm2zpHQcnebVQipRxzoiroiEKiKJV5Cic5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0EJm2349gXihj)2CkZ1qwpA)7FpgrqCb9nIwt3rOxKEJyv)u12nsto6aHax(wfmNJdaNJOyoM8lZPGX(PkhHZbKiKJ2CaNJp5OdecCj2j)MrCa4CaNJp5OdecCMP6LXbGZbCoAYXNCyyO0A7Z3gIGxfmkhrXCyySdf7F5m8cfFMuVasjH7QFjhaohrXC69Pcg7SNqvHgIGxvKN1RmhFZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL5etoXsoII507tfm2zpHQcnebVQipRxzoiroiEKiKJV5aceYjMC0KZrZbuZHHxuG(5WfXAjPmxdz9O950A6ocnhT5O9gzSVX7nQxMvR9nEV)9yep6f03iAnDhHEr6nIv9tvB3OEFQGXo7juvOHi4vf5z9kZX3CqeK5ikMJMC0bcboC1E4cTnNYkMTntbd4KwXHAoakhFZ5qqIqoII5OdecC4Q9WfABoLvmBBMcgWjTId1CauochpNdbjc5OnhW5OdecC5BvWCooaCoGZHHXouS)LZmvVmErEwVYCeohqIWnYyFJ3B05ErlcvjH7QF59VhJiiVG(grRP7i0lsVrSQFQA7gvuOiPat3r5aoNV9i1JvOnLJW5GiiZbCosyY5uVvqOxYLVvHUOC8nNJMd4CmyftaXoNd4C0KJoqiWzMQxgVipRxzocNdIiKJOyo(KJoqiWzMQxghaohT3iJ9nEVrYNCoRubNv0nIHmZrQ3ki0lVhJ49VhJySCb9nIwt3rOxKEJyv)u12nIyUgws8Ev2ICoGZXGvmbe7CoGZrhie4Wv7Hl02CkRy22mfmGtAfhQ5aOC8nNdbjc5aohn5GIFUHAWFdLus)w5PqnpdcX)MDUxi5ikMJp5WWqP12NVeRWoCHMJOyosyY5uVvqOxMJW5CyoAVrg7B8EJcafYkCqroGLU)9yebLxqFJO10De6fP3iw1pvTDJ0bcboEPxGubtfJG)gVCa4CaNJMC0bcbU8TkyohVOqrsbMUJYrumht(L5uWy)uLJW5i0iKJ2BKX(gV3i5BvWCU7FpgXJ8c6BeTMUJqVi9gXQ(PQTBeddLwBF(2qe8QGr5aohn5a1Q20DeNHxO4ZKcLKiVSCefZHHXouS)LZmvVmoaCoII5OdecCMP6LXbGZrBoGZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL54BoqyOCpti5aQ5WO2LJMCm5xMtbJ9tvoNMdirihT5aohDGqGlFRcMZXlYZ6vMJV5C0BKX(gV3i5BvWCU7FpgrH(c6BeTMUJqVi9gXQ(PQTBeddLwBF(2qe8QGr5aohn5a1Q20DeNHxO4ZKcLKiVSCefZHHXouS)LZmvVmoaCoII5OdecCMP6LXbGZrBoGZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL54BoqyOCpti5aQ5WO2LJMCm5xMtbJ9tvoNMdiqihT5aohDGqGlFRcMZXbGZbCoeZ1WsI3RYwKVrg7B8EJKVvsGccD)7XhIWf03iAnDhHEr6nIv9tvB3iDGqGJx6fivmhzLcAlB8YbGZrumhn54toY3Qqxe3Gvmbe7CoII5OjhDGqGZmvVmErEwVYC8nhqMd4C0bcboZu9Y4aW5ikMJMC0bcbEzqPfdivHI2yJmVipRxzo(Mdegk3ZesoGAomQD5Ojht(L5uWy)uLZP5aceYrBoGZrhie4LbLwmGufkAJnYCa4C0MJ2CaNduRAt3rC5BvWCoLF8(QG5CkCiKd4CKWKZPERGqVKlFRcMZLJV5aIC0Md4C0KJp5ualfWfeI)Th5hxRcTiZtVxuQ4esgOHHj0CefZrctoN6Tcc9sU8Tkyoxo(MdiYr7nYyFJ3BK8TscuqO7Fp(qeVG(grRP7i0lsVrSQFQA7gPjhI5AyjX7vzlY5aohgg7qX(xoZu9Y4f5z9kZr4Cajc5ikMJMCycSccjZjEohMd4CkIjWkiK6BpkhFZbK5OnhrXCycSccjZjEoGihT5aohdwXeqSZ3iJ9nEVrl5x5HX79VhF4HxqFJO10De6fP3iw1pvTDJ0KdXCnSK49QSf5CaNddJDOy)lNzQEz8I8SEL5iCoGeHCefZrtombwbHK5epNdZbCofXeyfes9ThLJV5aYC0MJOyombwbHK5ephqKJ2CaNJbRyci25BKX(gV3ibMlO8W49(3JpeexqFJO10De6fP3iw1pvTDJ0KdXCnSK49QSf5CaNddJDOy)lNzQEz8I8SEL5iCoGeHCefZrtombwbHK5epNdZbCofXeyfes9ThLJV5aYC0MJOyombwbHK5ephqKJ2CaNJbRyci25BKX(gV3OaGZP8W49(3Jp8OxqFJm2349g53QQXLchuKdyPBeTMUJqVi9(3JpeKxqFJO10De6fP3im8nss)nYyFJ3BeuRAt3r3iOMdGUrsyY5uVvqOxYLVvHUOCeoNJMtm5eCyCLJMC8m5tfYkOMdGY50CoeHC0Mtm5eCyCLJMC0bcbU8Tscuqif5bJ9tLhTVsIDwXLVXoNZP5C0C0EJGALAnp6gjFRcDrQEvsSZQ7Fp(Wy5c6BeTMUJqVi9gXQ(PQTBeXCnSK4oG1k1sc5ZrumhI5AyjXTfz1sc5ZbCoqTQnDhXBPI5idkLJOyo6aHaNyUgwskj2zfVipRxzo(MJX(gVC5BvOlItcHyapP(2JYbCo6aHaNyUgwskj2zfhaohrXCiMRHLeVxLe7SkhW54toqTQnDhXLVvHUivVkj2zvoII5OdecCMP6LXlYZ6vMJV5ySVXlx(wf6I4KqigWtQV9OCaNJp5a1Q20DeVLkMJmOuoGZrhie4mt1lJxKN1RmhFZHecXaEs9ThLd4C0bcboZu9Y4aW5ikMJoqiWldkTyaPku0gBK5aW5aohjm5CkbM8PCeohe4XsoGZrtosyY5uVvqOxMJVXZbe5ikMJp58MJ2NlXaofoOEbKkGls(CAnDhHMJ2CefZXNCGAvB6oI3sfZrgukhW5OdecCMP6LXlYZ6vMJW5qcHyapP(2JUrg7B8EJ8x2l4(3JpeuEb9nYyFJ3BK8Tk0fDJO10De6fP3)E8Hh5f03iAnDhHEr6nYyFJ3BubSkJ9nEvUw(3ixlF1AE0nkyo3lOaU)9VrbZ5EbfWf03Jr8c6BeTMUJqVi9gXQ(PQTBKp5ualfWfeIRBoBzKchuMZPEb9crYjKmqddtO3iJ9nEVrY3kjqbHU)94dVG(grRP7i0lsVrSQFQA7gHIFUhgVHUiErEwVYCeoNI8SEL3iJ9nEVrsGn0fDJyiZCK6Tcc9Y7XiE)7XG4c6BKX(gV3ipmEdDr3iAnDhHEr69V)ns(xqFpgXlOVr0A6oc9I0BeR6NQ2Ur(Kdk(5gQb)nusj9BLNc18mie)B25EHKd4C8jhJ9nE5gQb)nusj9BLNc18mieVxvW1qe85aohn54toO4NBOg83qjL0VvEkbK54FZo3lKCefZbf)Cd1G)gkPK(TYtjGmhVipRxzocNdiZrBoII5GIFUHAWFdLus)w5PqnpdcXLVXoNJV5aICaNdk(5gQb)nusj9BLNc18mieVipRxzo(MdiYbCoO4NBOg83qjL0VvEkuZZGq8VzN7fYnYyFJ3BKHAWFdLus)w5DJyiZCK6Tcc9Y7XiE)7XhEb9nIwt3rOxKEJyv)u12nstoqTQnDhXz4fk(mPqjjYllhW507tfm2zpHQcnebVQipRxzocNdIGaHCaNJp5WWyhk2)YzMQxgVidf5CefZrhie4mt1lJdaNJ2CaNJj)YCkySFQYX3Cajc5aohn5OdecCI5AyjPCaRv8I8SEL5iCoiIqoII5OdecCI5AyjPKyNv8I8SEL5iCoiIqoAZrumNqdrWRkYZ6vMJV5Gic3iJ9nEVrm8cfFMuVasjH7QF59VhdIlOVr0A6oc9I0Beg(gjP)gzSVX7ncQvTP7OBeuZbq3in5OdecCMP6LXlYZ6vMJW5aYCaNJMC0bcbEzqPfdivHI2yJmVipRxzocNdiZrumhFYrhie4LbLwmGufkAJnYCa4C0MJOyo(KJoqiWzMQxghaohrXCm5xMtbJ9tvo(MdiqihT5aohn54to6aHa)CVOfHQipySFQ8O9v0sfKo2ehaohrXCm5xMtbJ9tvo(MdiqihT5aohn5OdecCI5AyjPKyNv8I8SEL5iCoqyOCpti5ikMJoqiWjMRHLKYbSwXlYZ6vMJW5aHHY9mHKJ2BeuRuR5r3iu8Rkcjd0f5r7lV)94JEb9nIwt3rOxKEJyv)u12nQOqrsbMUJYbCoVvqON)ThPEScTPCeohepmhW5OjhdwXeqSZ5aohOw1MUJ4O4xvesgOlYJ2xMJ2BKX(gV3ipmEdDr3igYmhPERGqV8EmI3)EmiVG(grRP7i0lsVrSQFQA7gvuOiPat3r5aoN3ki0Z)2JupwH2uocNdIhMd4C0KJbRyci25CaNduRAt3rCu8Rkcjd0f5r7lZr7nYyFJ3BKeydDr3igYmhPERGqV8EmI3)ECSCb9nIwt3rOxKEJyv)u12nQOqrsbMUJYbCoVvqON)ThPEScTPCeoheJLCaNJMCmyftaXoNd4CGAvB6oIJIFvrizGUipAFzoAVrg7B8EJKp5CwPcoROBedzMJuVvqOxEpgX7FpguEb9nIwt3rOxKEJyv)u12nYGvmbe78nYyFJ3BuaxmsHdQ1EGIU)94J8c6BeTMUJqVi9gXQ(PQTBKoqiWzMQxgha(gzSVX7nQmO0IbKQqrBSr((3Jf6lOVr0A6oc9I0BeR6NQ2UrAYrto6aHaNyUgwskj2zfVipRxzocNdIiKJOyo6aHaNyUgwskhWAfVipRxzocNdIiKJ2CaNddJDOy)lNzQEz8I8SEL5iCoGaHCaNJMC0bcboC1E4cTnNYkMTntbd4KwXHAoakhFZ5WJIqoII54tofWsbCbH4Wv7Hl02CkRy22mfmGtAfNqYanmmHMJ2C0MJOyo6aHahUApCH2MtzfZ2MPGbCsR4qnhaLJWXZ5qqjc5ikMddJDOy)lNzQEz8ImuKZbCoAYXKFzofm2pv5iCocnc5ikMduRAt3r8wQmmLJ2BKX(gV3OZ9IweQsc3v)Y7FpgreUG(grRP7i0lsVrSQFQA7gPjht(L5uWy)uLJW5i0iKd4C0KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZrumhFYHHHsRTp)mYvBBoAZrumhggkT2(8THi4vbJYrumhOw1MUJ4TuzykhrXC0bcbUUdJrDaYNdaNd4C0bcbUUdJrDaYNxKN1RmhFZ5qeYjMC0KJMCe6Ca1CkGLc4ccXHR2dxOT5uwXSTzkyaN0koHKbAyycnhT5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0MJ2CaNJp5OdecCMP6LXbGZbCoAYXNCyyO0A7Z3gIGxfmkhrXCyySdf7F5m8cfFMuVasjH7QFjhaohrXC69Pcg7SNqvHgIGxvKN1RmhFZHHXouS)LZWlu8zs9ciLeUR(L8I8SEL5etoXsoII507tfm2zpHQcnebVQipRxzoiroiEKiKJV5Cic5etoAY5O5aQ5WWlkq)C4IyTKuMRHSE0(CAnDhHMJ2C0EJm2349gXihj)2CkZ1qwpA)7FpgreVG(grRP7i0lsVrSQFQA7gPjht(L5uWy)uLJW5i0iKd4C0KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZrumhFYHHHsRTp)mYvBBoAZrumhggkT2(8THi4vbJYrumhOw1MUJ4TuzykhrXC0bcbUUdJrDaYNdaNd4C0bcbUUdJrDaYNxKN1RmhFZbeiKtm5Ojhn5i05aQ5ualfWfeIdxThUqBZPSIzBZuWaoPvCcjd0WWeAoAZjMC0KZrZbuZHHxuG(5WfXAjPmxdz9O950A6ocnhT5OnhT5aohFYrhie4mt1lJdaNd4C0KJp5WWqP12NVnebVkyuoII5WWyhk2)Yz4fk(mPEbKsc3v)soaCoII507tfm2zpHQcnebVQipRxzo(MddJDOy)lNHxO4ZK6fqkjCx9l5f5z9kZjMCILCefZP3NkySZEcvfAicEvrEwVYCqICq8irihFZbeiKtm5OjNJMdOMddVOa9ZHlI1sszUgY6r7ZP10DeAoAZr7nYyFJ3BuVmRw7B8E)7XiE4f03iAnDhHEr6ncdFJK0FJm2349gb1Q20D0ncQ5aOBKMC8jhgg7qX(xoZu9Y4fzOiNJOyo(KduRAt3rCgEHIptkusI8YYbCommuAT95BdrWRcgLJ2BeuRuR5r3iPbLubCPyMQx29VhJiiUG(grRP7i0lsVrSQFQA7grmxdljEVkBrohW5yWkMaIDohW5OdecC4Q9WfABoLvmBBMcgWjTId1Cauo(MZHhfHCaNJMCqXp3qn4VHskPFR8uOMNbH4FZo3lKCefZXNCyyO0A7ZxIvyhUqZrBoGZbQvTP7iU0GsQaUumt1l7gzSVX7nkauiRWbf5aw6(3Jr8OxqFJO10De6fP3iw1pvTDJ0bcboEPxGubtfJG)gVCa4CaNJoqiWLVvbZ54ffkskW0D0nYyFJ3BK8Tkyo39VhJiiVG(gPdecQ18OBK8TYHl0BeTMUJqVi9gXQ(PQTBKoqiWLVvoCHYlYZ6vMJV5aYCaNJMC0bcboXCnSKusSZkErEwVYCeohqMJOyo6aHaNyUgwskhWAfVipRxzocNdiZrBoGZXKFzofm2pv5iCocnc3iJ9nEVrmBzKtPdec3)EmIXYf03iAnDhHEr6nIv9tvB3iggkT2(8THi4vbJYbCoqTQnDhXz4fk(mPqjjYllhW5WWyhk2)Yz4fk(mPEbKsc3v)sErEwVYC8nhimuUNjKCa1Cyu7YrtoM8lZPGX(PkNtZbeiKJ2BKX(gV3i5BLeOGq3)EmIGYlOVr0A6oc9I0BeR6NQ2UrV5O95YNCoRuOvhEoTMUJqZbCo(KZBoAFU8TYHluoTMUJqZbCo6aHax(wfmNJxuOiPat3r5aohn5OdecCI5AyjPCaRv8I8SEL5iCoXsoGZHyUgws8EvoG1QCaNJoqiWHR2dxOT5uwXSTzkyaN0kouZbq54BohcseYrumhDGqGdxThUqBZPSIzBZuWaoPvCOMdGYr445CiirihW5yYVmNcg7NQCeohHgHCefZbf)Cd1G)gkPK(TYtHAEgeIxKN1RmhHZ5iZrumhJ9nE5gQb)nusj9BLNc18mieVxvW1qe85OnhW54tomm2HI9VCMP6LXlYqr(gzSVX7ns(wfmN7(3Jr8iVG(grRP7i0lsVrSQFQA7gPdecC8sVaPI5iRuqBzJxoaCoII5Odec8Z9IweQI8GX(PYJ2xrlvq6ytCa4CefZrhie4mt1lJdaNd4C0KJoqiWldkTyaPku0gBK5f5z9kZX3CGWq5EMqYbuZHrTlhn5yYVmNcg7NQConhqGqoAZbCo6aHaVmO0IbKQqrBSrMdaNJOyo(KJoqiWldkTyaPku0gBK5aW5aohFYHHXouS)LxguAXasvOOn2iZlYqrohrXC8jhggkT2(CO0(cqUYrBoII5yYVmNcg7NQCeohHgHCaNdXCnSK49QSf5BKX(gV3i5BLeOGq3)EmIc9f03iAnDhHEr6nIv9tvB3O3C0(C5BLdxOCAnDhHMd4C0KJoqiWLVvoCHYbGZrumht(L5uWy)uLJW5i0iKJ2CaNJoqiWLVvoCHYLVXoNJV5aICaNJMC0bcboXCnSKusSZkoaCoII5OdecCI5AyjPCaRvCa4C0Md4C0bcboC1E4cTnNYkMTntbd4KwXHAoakhFZ5qqjc5aohn5WWyhk2)YzMQxgVipRxzocNdIiKJOyo(KduRAt3rCgEHIptkusI8YYbCommuAT95BdrWRcgLJ2BKX(gV3i5BLeOGq3)E8HiCb9nIwt3rOxKEJyv)u12nsto6aHahUApCH2MtzfZ2MPGbCsR4qnhaLJV5CiOeHCefZrhie4Wv7Hl02CkRy22mfmGtAfhQ5aOC8nNdbjc5aoN3C0(C5toNvk0QdpNwt3rO5OnhW5OdecCI5AyjPKyNv8I8SEL5iCoGYCaNdXCnSK49QKyNv5aohFYrhie44LEbsfmvmc(B8YbGZbCo(KZBoAFU8TYHluoTMUJqZbComm2HI9VCMP6LXlYZ6vMJW5akZbCoAYHHXouS)LFUx0Iqvs4U6xYlYZ6vMJW5akZrumhFYHHHsRTp)mYvBBoAVrg7B8EJKVvsGccD)7XhI4f03iAnDhHEr6nIv9tvB3in5OdecCI5AyjPCaRvCa4CefZrtombwbHK5epNdZbCofXeyfes9ThLJV5aYC0MJOyombwbHK5ephqKJ2CaNJbRyci25CaNduRAt3rCPbLubCPyMQx2nYyFJ3B0s(vEy8E)7XhE4f03iAnDhHEr6nIv9tvB3in5OdecCI5AyjPCaRvCa4CaNJp5WWqP12NFg5QTnhrXC0KJoqiWp3lArOkYdg7NkpAFfTubPJnXbGZbCommuAT95NrUABZrBoII5OjhMaRGqYCINZH5aoNIycSccP(2JYX3CazoAZrumhMaRGqYCINdiYrumhDGqGZmvVmoaCoAZbCogSIjGyNZbCoqTQnDhXLgusfWLIzQEz3iJ9nEVrcmxq5HX79VhFiiUG(grRP7i0lsVrSQFQA7gPjhDGqGtmxdljLdyTIdaNd4C8jhggkT2(8ZixTT5ikMJMC0bcb(5ErlcvrEWy)u5r7ROLkiDSjoaCoGZHHHsRTp)mYvBBoAZrumhn5WeyfesMt8ComhW5uetGvqi13Euo(MdiZrBoII5WeyfesMt8CaroII5OdecCMP6LXbGZrBoGZXGvmbe7CoGZbQvTP7iU0GsQaUumt1l7gzSVX7nka4CkpmEV)94dp6f03iJ9nEVr(TQACPWbf5aw6grRP7i0lsV)94db5f03iAnDhHEr6nIv9tvB3iI5AyjX7v5awRYrumhI5AyjXLyNvQLeYNJOyoeZ1WsIBlYQLeYNJOyo6aHa3VvvJlfoOihWsCa4CaNJoqiWjMRHLKYbSwXbGZrumhn5OdecCMP6LXlYZ6vMJV5ySVXl3FzVaojeIb8K6BpkhW5OdecCMP6LXbGZr7nYyFJ3BK8Tk0fD)7XhglxqFJm2349g5VSxWnIwt3rOxKE)7XhckVG(grRP7i0lsVrg7B8EJkGvzSVXRY1Y)g5A5RwZJUrbZ5EbfW9V)ncUig2t3(lOVhJ4f03iJ9nEVrEy8EUxvaxE3iAnDhHEr69VhF4f03iAnDhHEr6nYyFJ3BK)YEb3ixVKIHEJqeH7FpgexqFJO10De6fP3iw1pvTDJGlckhrU)YEb5aohFYbUiO8d5(l7fCJm2349g5VSxW9VhF0lOVrg7B8EJKVvHUOBeTMUJqVi9(3Jb5f03iAnDhHEr6ncdFJK0FJm2349gb1Q20D0ncQ5aOBKowkZbCobhgx5Ojhn5eAicEvrEwVYCqs5Cic5OnNtZbXdrihT5iCobhgx5Ojhn5eAicEvrEwVYCqs5CiiZbjLJMCqeHCa1CEZr7Z7Lz1AFJxoTMUJqZrBoiPC0KZrZbuZHHxuG(5WfXAjPmxdz9O950A6ocnhT5OnNtZbXJeHC0EJGALAnp6gXWlu8zsHssKx29V)9VrqPs249E8HiCiciIiIiEJ8B12le5nkwTqXyfhlu44yvc1CYb0cOCApyC95eWvoXAOfzE69IsvSwofHKb6IqZrI9OCmGh7zpHMdtGTqijppau0lLZHc1Coc8cLQNqZjQ9oICKiVVjKCqICECoGcalh0gAlB8MdgMk7XvoAovBoAquiA55bGIEPCqerHAohbEHs1tO5e1EhrosK33esoibsKZJZbuay54HrbCaYCWWuzpUYrdsOnhnikeT88aqrVuoiEOqnNJaVqP6j0CIAVJihjY7BcjhKajY5X5akaSC8WOaoazoyyQShx5Obj0MJgefIwEEaOOxkhebPqnNJaVqP6j0CIAVJihjY7BcjhKiNhNdOaWYbTH2YgV5GHPYECLJMt1MJgefIwEEqEqSAHIXkowOWXXQeQ5KdOfq50EW46ZjGRCI1Glc2EMaL8J1YPiKmqxeAosShLJb8yp7j0CycSfcj55bGwaLta7Cy)9cjhdOmzo(PIYbqsO50BoVakhJ9nEZX1YphDGph)ur5S4pNagyrZP3CEbuogkkEZb1Et3KKqnpihKuoY3kjqbHuKhm2pvE0(5b5bXQfkgR4yHchhRsOMtoGwaLt7bJRpNaUYjwdUig2t3(yTCkcjd0fHMJe7r5yap2ZEcnhMaBHqsEEaOOxkhqkuZ5iWluQEcnNO27iYrI8(MqYbjY5X5akaSCqBOTSXBoyyQShx5O5uT5O5qHOLNhKheRwOySIJfkCCSkHAo5aAbuoThmU(Cc4kNyndtXA5uesgOlcnhj2JYXaESN9eAomb2cHK88aqrVuohkuZ5iWluQEcnNO27iYrI8(MqYbjqICECoGcalhpmkGdqMdgMk7XvoAqcT5ObrHOLNhak6LY5Oc1Coc8cLQNqZjQ9oICKiVVjKCqICECoGcalh0gAlB8MdgMk7XvoAovBoAquiA55bGIEPCosHAohbEHs1tO5e1EhrosK33esoiropohqbGLdAdTLnEZbdtL94khnNQnhnikeT88aqrVuoiEOqnNJaVqP6j0CIAVJihjY7BcjhKajY5X5akaSC8WOaoazoyyQShx5Obj0MJgefIwEEaOOxkhebHqnNJaVqP6j0CIAVJihjY7BcjhKajY5X5akaSC8WOaoazoyyQShx5Obj0MJgefIwEEaOOxkhepsHAohbEHs1tO5e1EhrosK33esoiropohqbGLdAdTLnEZbdtL94khnNQnhnikeT88aqrVuoik0c1Coc8cLQNqZjQ9oICKiVVjKCqICECoGcalh0gAlB8MdgMk7XvoAovBoAquiA55bGIEPCoebHAohbEHs1tO5e1EhrosK33esoiropohqbGLdAdTLnEZbdtL94khnNQnhnikeT88aqrVuohcsHAohbEHs1tO5e1EhrosK33esoiropohqbGLdAdTLnEZbdtL94khnNQnhnhkeT88G8Gy1cfJvCSqHJJvjuZjhqlGYP9GX1Ntax5eRj)yTCkcjd0fHMJe7r5yap2ZEcnhMaBHqsEEaOOxkherqOMZrGxOu9eAorT3rKJe59nHKdsGe584CafawoEyuahGmhmmv2JRC0GeAZrdIcrlppau0lLdIikuZ5iWluQEcnNO27iYrI8(MqYbjqICECoGcalhpmkGdqMdgMk7XvoAqcT5ObrHOLNhak6LYbXyrOMZrGxOu9eAorT3rKJe59nHKdsKZJZbuay5G2qBzJ3CWWuzpUYrZPAZrdIcrlppau0lLdIhPqnNJaVqP6j0CIAVJihjY7BcjhKiNhNdOaWYbTH2YgV5GHPYECLJMt1MJgefIwEEqEqSAHIXkowOWXXQeQ5KdOfq50EW46ZjGRCI10X2hRLtrizGUi0CKypkhd4XE2tO5WeylesYZdaf9s5COqnNJaVqP6j0CIAVJihjY7BcjhKiNhNdOaWYbTH2YgV5GHPYECLJMt1MJMdfIwEEaOOxkhebPqnNJaVqP6j0CIAVJihjY7BcjhKajY5X5akaSC8WOaoazoyyQShx5Obj0MJgefIwEEaOOxkhepsHAohbEHs1tO5e1EhrosK33esoiropohqbGLdAdTLnEZbdtL94khnNQnhnGqiA55bGIEPCquOfQ5Ce4fkvpHMtu7De5irEFti5Ge584CafawoOn0w24nhmmv2JRC0CQ2C0GOq0YZdYdek4bJRNqZ5iZXyFJ3CCT8L88GBeCHdTJUrcL5GuZzlJYjwFb0O5bcL5Cmgk5PtvoicItY5qeoeH8G8aHYCocb2cHKc18aHYCqs5iuefLqZjc7SkhKsMhppqOmhKuohHaBHqO58wbHEvhYHzssMZJZHHmZrQ3ki0l55bcL5GKYjwb5HHsO5aSlXiP0kKZbQvTP7izoAAoXpjh4IGQKVvsGccLdss4CGlckx(wjbkiKwEEGqzoiPCIvQxCLdH2FopohAzyGYGq5e9wfmNlNEZjc054VFb5e9KZzvoX6Ro85OjwPy0gRSCKcWao0CGlSUP7qohDkhlhjmXYbd)nE55b5bg7B8k5WfXWE62h3dJ3Z9Qc4YlpWyFJxjhUig2t3(yIFQ)YEbN46Lum04iIqEGX(gVsoCrmSNU9Xe)u)L9coPdXHlckhrU)YEbG9bUiO8d5(l7fKhySVXRKdxed7PBFmXpv(wf6IYdm234vYHlIH90TpM4Nc1Q20D0jR5rXz4fk(mPqjjYl7eOMdGIRJLsWbhgxA0eAicEvrEwVsK0HiOfjq8qe0kCWHXLgnHgIGxvKN1RejDiirsAqebq9nhTpVxMvR9nE50A6ocvlssZrbvgErb6NdxeRLKYCnK1J2NtRP7iuTArcepse0MhKhiuMtSYfcXaEcnhckviNZ3EuoVakhJ94kNwMJb1ANP7iEEGX(gVY4sSZkLozE5bg7B8kJj(PqTQnDhDYAEu8wQmmDcuZbqXLWKZPERGqVKlFRcMZjmIG14ZBoAFU8TYHluoTMUJqffFZr7ZLp5CwPqRo8CAnDhHQvuuctoN6Tcc9sU8TkyoNWhMhySVXRmM4Nc1Q20D0jR5rXBPI5idkDcuZbqXLWKZPERGqVKlFRcDrcJyEGX(gVYyIFQovsQo3lKt6qCn(WWqP12NVnebVkyKOOpmm2HI9VCgEHIptQxaPKWD1VKdaRfSoqiWzMQxghaopWyFJxzmXpfg)nEpPdX1bcboZu9Y4aW5bg7B8kJj(Pass1p5jZdm234vgt8tfqw9kskPLrN0H4ock58fKiMhySVXRmM4NwaRYyFJxLRL)jR5rXnmDI8RM9Xr8KoehQvTP7iElvgMYdm234vgt8tlGvzSVXRY1Y)K18O4OfzE69Is1jYVA2hhXt6q8cyPaUGq8V9i)4AvOfzE69IsfNqYanmmHMhySVXRmM4NwaRYyFJxLRL)jR5rX1X2FI8RM9Xr8KoeVawkGliex3C2YifoOmNt9c6fIKtizGggMqZdm234vgt8tlGvzSVXRY1Y)K18O4Y)Koe3rqjNWGeH8aJ9nELXe)0cyvg7B8QCT8pznpkoCrW2ZeOKFEqEGX(gVsUHP4qTQnDhDYAEuC0ImpL)25ubZ5u4q4eOMdGIRrhie4F7r(X1QqlY807fLkErEwVsFHWq5EMqIbboIII6aHa)BpYpUwfArMNEVOuXlYZ6v6RX(gVC5BvOlItcHyapP(2JIbboIG1qmxdljEVkhWALOiXCnSK4sSZk1sc5ffjMRHLe3wKvljKxRwW6aHa)BpYpUwfArMNEVOuXbGbxalfWfeI)Th5hxRcTiZtVxuQ4esgOHHj08aJ9nELCdtXe)u5BvWCUt6qCDGqGlFRcMZXlkuKuGP7iWAKWKZPERGqVKlFRcMZ5lief9PawkGlie)BpYpUwfArMNEVOuXjKmqddtOAbRXNcyPaUGqChYmRmPk4i67fIcIR9GLeNqYanmmHkk(ThHeiXrbPW6aHax(wfmNJxKN1RmMd1MhySVXRKBykM4NkFRcMZDshIxalfWfeI)Th5hxRcTiZtVxuQ4esgOHHjuWsyY5uVvqOxYLVvbZ5eooiaRXhDGqG)Th5hxRcTiZtVxuQ4aWG1bcbU8TkyohVOqrsbMUJef1a1Q20DehTiZt5VDovWCofoeaRrhie4Y3QG5C8I8SEL(ccrrjm5CQ3ki0l5Y3QG5CcFi43C0(C5toNvk0QdpNwt3rOG1bcbU8TkyohVipRxPVGuRwT5bg7B8k5gMIj(PqTQnDhDYAEuC5BvWCoLF8(QG5CkCiCcuZbqXn5xMtbJ9tLWhjcijniIaOQdec8V9i)4AvOfzE69Isfx(g7SwKKgDGqGlFRcMZXlYZ6vcQGajKWKZPeyYN0IK0GIFEaOqwHdkYbSeVipRxjOcsTG1bcbU8TkyohhaopWyFJxj3WumXpv(wjbki0jDiouRAt3rC0ImpL)25ubZ5u4qamuRAt3rC5BvWCoLF8(QG5CkCiKhySVXRKBykM4Nkb2qx0jmKzos9wbHEzCepPdXlkuKuGP7iWVvqON)ThPEScTjHr8Oijjm5CQ3ki0lJPipRxjydwXeqSZGjMRHLeVxLTiNhySVXRKBykM4NAOg83qjL0VvENWqM5i1Bfe6LXr8Koe3NVzN7fcyFm234LBOg83qjL0VvEkuZZGq8EvbxdrWlkIIFUHAWFdLus)w5PqnpdcXLVXo7liaJIFUHAWFdLus)w5PqnpdcXlYZ6v6liYdm234vYnmft8t9W4n0fDcdzMJuVvqOxghXt6q8Icfjfy6oc8Bfe65F7rQhRqBsyniE0y0iHjNt9wbHEjx(wf6Iave5GuRwKqctoN6Tcc9YykYZ6vcwJggg7qX(xoZu9Y4fzOilkkHjNt9wbHEjx(wf6I8feIIAiMRHLeVxLe7SsuKyUgws8Ev64xGOiXCnSK49QCaRvG95nhTpxIbCkCq9civaxK850A6ocvuuhie4Wv7Hl02CkRy22mfmGtAfhQ5aiHJFiirqlynsyY5uVvqOxYLVvHUiFrebqvdIX8MJ2N)(7v5HXRKtRP7iuTAbBYVmNcg7NkHbjcijDGqGlFRcMZXlYZ6vcQXIwW(Odec8Z9IweQI8GX(PYJ2xrlvq6ytCayWgSIjGyN1MhySVXRKBykM4NYWlu8zs9ciLeUR(LN0H4AGAvB6oIZWlu8zsHssKxg4EFQGXo7juvOHi4vf5z9kfgrqGayFyySdf7F5mt1lJxKHISOOoqiWzMQxghawlyt(L5uWy)u5liraSgDGqGtmxdljLdyTIxKN1Ru4yruuhie4eZ1WssjXoR4f5z9kf(OAffdnebVQipRxPViIqEGX(gVsUHPyIFAaxmsHdQ1EGIoPdXnyftaXoNhySVXRKBykM4NwguAXasvOOn2iFshIRdecCMP6LXbGZdm234vYnmft8tzKJKFBoL5AiRhT)jDiUgDGqGlFRcMZXbGffn5xMtbJ9tLWGebTG9rhie4sSt(nJ4aWG9rhie4mt1lJdadwJpmmuAT95BdrWRcgjkYWyhk2)Yz4fk(mPEbKsc3v)soaSOyVpvWyN9eQk0qe8QI8SEL(YWyhk2)Yz4fk(mPEbKsc3v)sErEwVYyIfrXEFQGXo7juvOHi4vf5z9krcKaXJebFpeHy0CuqLHxuG(5WfXAjPmxdz9O950A6ocvR28aJ9nELCdtXe)0EzwT2349KoexJoqiWLVvbZ54aWIIM8lZPGX(PsyqIGwW(OdecCj2j)MrCayW(OdecCMP6LXbGbRXhggkT2(8THi4vbJefzySdf7F5m8cfFMuVasjH7QFjhawuS3NkySZEcvfAicEvrEwVsFzySdf7F5m8cfFMuVasjH7QFjVipRxzmXIOyVpvWyN9eQk0qe8QI8SELibsG4rIGVGaHy0CuqLHxuG(5WfXAjPmxdz9O950A6ocvR28aJ9nELCdtXe)0Z9IweQsc3v)Yt6q8EFQGXo7juvOHi4vf5z9k9frqkkQrhie4Wv7Hl02CkRy22mfmGtAfhQ5aiFpeKiikQdecC4Q9WfABoLvmBBMcgWjTId1CaKWXpeKiOfSoqiWLVvbZ54aWGzySdf7F5mt1lJxKN1RuyqIqEGX(gVsUHPyIFQ8jNZkvWzfDcdzMJuVvqOxghXt6q8Icfjfy6oc83EK6Xk0MegrqcwctoN6Tcc9sU8Tk0f57rbBWkMaIDgSgDGqGZmvVmErEwVsHrebrrF0bcboZu9Y4aWAZdm234vYnmft8tdafYkCqroGLoPdXjMRHLeVxLTid2Gvmbe7myDGqGdxThUqBZPSIzBZuWaoPvCOMdG89qqIaynO4NBOg83qjL0VvEkuZZGq8VzN7fIOOpmmuAT95lXkSdxOIIsyY5uVvqOxk8HAZdm234vYnmft8tLVvbZ5oPdX1bcboEPxGubtfJG)gVCayWA0bcbU8TkyohVOqrsbMUJefn5xMtbJ9tLWcncAZdm234vYnmft8tLVvbZ5oPdXzyO0A7Z3gIGxfmcSgOw1MUJ4m8cfFMuOKe5LjkYWyhk2)YzMQxghawuuhie4mt1lJdaRfmdJDOy)lNHxO4ZK6fqkjCx9l5f5z9k9fcdL7zcbuzu70yYVmNcg7NkKaKiOfSoqiWLVvbZ54f5z9k99O5bg7B8k5gMIj(PY3kjqbHoPdXzyO0A7Z3gIGxfmcSgOw1MUJ4m8cfFMuOKe5LjkYWyhk2)YzMQxghawuuhie4mt1lJdaRfmdJDOy)lNHxO4ZK6fqkjCx9l5f5z9k9fcdL7zcbuzu70yYVmNcg7NkKaeiOfSoqiWLVvbZ54aWGjMRHLeVxLTiNhySVXRKBykM4NkFRKafe6Koexhie44LEbsfZrwPG2YgVCayrrn(iFRcDrCdwXeqSZIIA0bcboZu9Y4f5z9k9fKG1bcboZu9Y4aWIIA0bcbEzqPfdivHI2yJmVipRxPVqyOCptiGkJANgt(L5uWy)uHeGabTG1bcbEzqPfdivHI2yJmhawRwWqTQnDhXLVvbZ5u(X7RcMZPWHayjm5CQ3ki0l5Y3QG5C(ccTG14tbSuaxqi(3EKFCTk0Imp9ErPItizGggMqffLWKZPERGqVKlFRcMZ5li0MhySVXRKBykM4NUKFLhgVN0H4AiMRHLeVxLTidMHXouS)LZmvVmErEwVsHbjcIIAycSccjJFi4IycSccP(2J8fKAffzcSccjJdcTGnyftaXoNhySVXRKBykM4NkWCbLhgVN0H4AiMRHLeVxLTidMHXouS)LZmvVmErEwVsHbjcIIAycSccjJFi4IycSccP(2J8fKAffzcSccjJdcTGnyftaXoNhySVXRKBykM4NgaCoLhgVN0H4AiMRHLeVxLTidMHXouS)LZmvVmErEwVsHbjcIIAycSccjJFi4IycSccP(2J8fKAffzcSccjJdcTGnyftaXoNhySVXRKBykM4N63QQXLchuKdyP8aJ9nELCdtXe)uOw1MUJoznpkU8Tk0fP6vjXoRobQ5aO4syY5uVvqOxYLVvHUiHpAmbhgxA8m5tfYkOMdGqIdrqBmbhgxA0bcbU8Tscuqif5bJ9tLhTVsIDwXLVXoJehvBEGX(gVsUHPyIFQ)YEbN0H4eZ1WsI7awRuljKxuKyUgwsCBrwTKqEWqTQnDhXBPI5idkjkQdecCI5AyjPKyNv8I8SEL(ASVXlx(wf6I4KqigWtQV9iW6aHaNyUgwskj2zfhawuKyUgws8EvsSZkW(a1Q20Dex(wf6Iu9QKyNvII6aHaNzQEz8I8SEL(ASVXlx(wf6I4KqigWtQV9iW(a1Q20DeVLkMJmOeyDGqGZmvVmErEwVsFjHqmGNuF7rG1bcboZu9Y4aWII6aHaVmO0IbKQqrBSrMdadwctoNsGjFsye4XcynsyY5uVvqOx6BCqik6ZBoAFUed4u4G6fqQaUi5ZP10DeQwrrFGAvB6oI3sfZrgucSoqiWzMQxgVipRxPWKqigWtQV9O8aJ9nELCdtXe)u5BvOlkpWyFJxj3WumXpTawLX(gVkxl)twZJIhmN7fua5b5bg7B8k56y7JxguAXasvOOn2iFshIRdecCMP6LXbGZdm234vY1X2ht8tHAvB6o6K18O4m8cfFMuOKe5LDcuZbqXdomU0OP3NkySZEcvfAicEvrEwVsK0HiOfjq8qe0kCWHXLgn9(ubJD2tOQqdrWRkYZ6vIKoeKijniIaO(MJ2N3lZQ1(gVCAnDhHQfjP5OGkdVOa9ZHlI1sszUgY6r7ZP10DeQwTibIhjcAZdm234vY1X2ht8tHAvB6o6K18O4SQ)f)aWNa1CauCF0bcbUU5SLrkCqzoN6f0lePAThOioamyF0bcbUU5SLrkCqzoN6f0lePYkMTehaopWyFJxjxhBFmXp1qn4VHskPFR8oHHmZrQ3ki0lJJ4jDiUoqiW1nNTmsHdkZ5uVGEHivR9afXLVXoRGAoaY3JIayDGqGRBoBzKchuMZPEb9crQSIzlXLVXoRGAoaY3JIayn(GIFUHAWFdLus)w5PqnpdcX)MDUxiG9XyFJxUHAWFdLus)w5PqnpdcX7vfCnebpyn(GIFUHAWFdLus)w5PeqMJ)n7CVqefrXp3qn4VHskPFR8uciZXlYZ6vkmi0kkIIFUHAWFdLus)w5PqnpdcXLVXo7liaJIFUHAWFdLus)w5PqnpdcXlYZ6v6libJIFUHAWFdLus)w5PqnpdcX)MDUxiAZdm234vY1X2ht8tz4fk(mPEbKsc3v)Yt6qCnqTQnDhXz4fk(mPqjjYldCVpvWyN9eQk0qe8QI8SELcJiiqaSpmm2HI9VCMP6LXlYqrwuuhie4mt1lJdaRfSgDGqGRBoBzKchuMZPEb9crQw7bkIlFJDwb1CauCqIGOOoqiW1nNTmsHdkZ5uVGEHivwXSL4Y3yNvqnhafhKiOvum0qe8QI8SEL(Iic5bg7B8k56y7Jj(PmBzKtPdecNSMhfx(w5Wf6jDiUgDGqGRBoBzKchuMZPEb9crQw7bkIxKN1Ru4JYbPOOoqiW1nNTmsHdkZ5uVGEHivwXSL4f5z9kf(OCqQfSj)YCkySFQeoUqJaynmm2HI9VCMP6LXlYZ6vkmOuuuddJDOy)lN8GX(PsPJxuErEwVsHbLG9rhie4N7fTiuf5bJ9tLhTVIwQG0XM4aWGzyO0A7ZpJC12QvBEGX(gVsUo2(yIFQ8TscuqOt6qCFGAvB6oIZQ(x8dadwdddLwBF(2qe8QGrIImm2HI9VCMP6LXlYZ6vkmOuuuddJDOy)lN8GX(PsPJxuErEwVsHbLG9rhie4N7fTiuf5bJ9tLhTVIwQG0XM4aWGzyO0A7ZpJC12QvBEGX(gVsUo2(yIFQ8TscuqOt6qCnmm2HI9VCgEHIptQxaPKWD1VKdadwduRAt3rCgEHIptkusI8YefzySdf7F5mt1lJxKN1R0xqQvlyt(L5uWy)ujmiramddLwBF(2qe8QGr5bg7B8k56y7Jj(PsGn0fDcdzMJuVvqOxghXt6q8Icfjfy6oc8Bfe65F7rQhRqBsyeJfWAmyftaXodwduRAt3rCw1)IFayrrnM8lZPGX(PYxqGayF0bcboZu9Y4aWAffzySdf7F5mt1lJxKHISwT5bg7B8k56y7Jj(PEy8g6IoHHmZrQ3ki0lJJ4jDiErHIKcmDhb(Tcc98V9i1JvOnjmIGGdsWAmyftaXodwduRAt3rCw1)IFayrrnM8lZPGX(PYxqGayF0bcboZu9Y4aWAffzySdf7F5mt1lJxKHISwW(Odec8Z9IweQI8GX(PYJ2xrlvq6ytCayT5bg7B8k56y7Jj(PYNCoRubNv0jmKzos9wbHEzCepPdXlkuKuGP7iWVvqON)ThPEScTjHrmwIPipRxjyngSIjGyNbRbQvTP7ioR6FXpaSOOj)YCkySFQ8feiikYWyhk2)YzMQxgVidfzTAZdm234vY1X2ht8td4IrkCqT2du0jDiUbRyci258aJ9nELCDS9Xe)0aqHSchuKdyPt6qCneZ1WsI3RYwKffjMRHLexIDwP6vHOOiXCnSK4oG1kvVke1cwJpmmuAT95BdrWRcgjkQXKFzofm2pv(k0GeSgOw1MUJ4SQ)f)aWIIM8lZPGX(PYxqGGOiuRAt3r8wQmmPfSgOw1MUJ4m8cfFMuOKe5Lb2hgg7qX(xodVqXNj1lGus4U6xYbGff9bQvTP7iodVqXNjfkjrEzG9HHXouS)LZmvVmoaSwTAbRHHXouS)LZmvVmErEwVsHbbcIIM8lZPGX(PsyHgbWmm2HI9VCMP6LXbGbRHHXouS)LtEWy)uP0XlkVipRxPVg7B8YLVvHUiojeIb8K6Bpsu0hggkT2(8ZixTTAff79Pcg7SNqvHgIGxvKN1R0xerqlynO4NBOg83qjL0VvEkuZZGq8I8SELcFurrFyyO0A7ZxIvyhUq1MhySVXRKRJTpM4NEUx0Iqvs4U6xEshIRHyUgwsChWALAjH8IIeZ1WsIlXoRuljKxuKyUgwsCBrwTKqErrDGqGRBoBzKchuMZPEb9crQw7bkIxKN1Ru4JYbPOOoqiW1nNTmsHdkZ5uVGEHivwXSL4f5z9kf(OCqkkAYVmNcg7NkHfAeaZWyhk2)YzMQxgVidfzTG1WWyhk2)YzMQxgVipRxPWGabrrgg7qX(xoZu9Y4fzOiRvuS3NkySZEcvfAicEvrEwVsFreH8aJ9nELCDS9Xe)ug5i53MtzUgY6r7FshIRXKFzofm2pvcl0iawJoqiWp3lArOkYdg7NkpAFfTubPJnXbGff9HHHsRTp)mYvBRwrrggkT2(8THi4vbJef1bcbUUdJrDaYNdadwhie46omg1biFErEwVsFpeHy0CuqLHxuG(5WfXAjPmxdz9O950A6ocvRwWA8HHHsRTpFBicEvWirrgg7qX(xodVqXNj1lGus4U6xYbGff79Pcg7SNqvHgIGxvKN1R0xgg7qX(xodVqXNj1lGus4U6xYlYZ6vgtSik27tfm2zpHQcnebVQipRxjsGeiEKi47HieJMJcQm8Ic0phUiwljL5AiRhTpNwt3rOA1MhySVXRKRJTpM4N2lZQ1(gVN0H4Am5xMtbJ9tLWcncG1Odec8Z9IweQI8GX(PYJ2xrlvq6ytCayrrFyyO0A7ZpJC12QvuKHHsRTpFBicEvWirrDGqGR7WyuhG85aWG1bcbUUdJrDaYNxKN1R0xqGqmAokOYWlkq)C4IyTKuMRHSE0(CAnDhHQvlyn(WWqP12NVnebVkyKOidJDOy)lNHxO4ZK6fqkjCx9l5aWIIqTQnDhXz4fk(mPqjjYldCVpvWyN9eQk0qe8QI8SELcJ4rIqmhIqmAokOYWlkq)C4IyTKuMRHSE0(CAnDhHQvuS3NkySZEcvfAicEvrEwVsFzySdf7F5m8cfFMuVasjH7QFjVipRxzmXIOyVpvWyN9eQk0qe8QI8SEL(cceIrZrbvgErb6NdxeRLKYCnK1J2NtRP7iuTAZdm234vY1X2ht8tLVvsGccDshIZWqP12NVnebVkyeynqTQnDhXz4fk(mPqjjYltuKHXouS)LZmvVmErEwVsFrebTGn5xMtbJ9tLWGebWmm2HI9VCgEHIptQxaPKWD1VKxKN1R0xeripWyFJxjxhBFmXpfQvTP7OtwZJIBs4yDufrStGAoakoXCnSK49QCaRvG6rIeg7B8YLVvHUiojeIb8K6BpkgFiMRHLeVxLdyTcuJfKWyFJxU)YEbCsied4j13EumiWpejKWKZPeyYNYdm234vY1X2ht8tLVvsGccDshIRP3NkySZEcvfAicEvrEwVsFpQOOgDGqGxguAXasvOOn2iZlYZ6v6legk3ZecOYO2PXKFzofm2pvibiqqlyDGqGxguAXasvOOn2iZbG1QvuuJj)YCkySFQIbQvTP7iUjHJ1rveXavDGqGtmxdljLe7SIxKN1Rmgu8ZdafYkCqroGL4FZolvf5z9cQhYbPWiEicIIM8lZPGX(PkgOw1MUJ4Meowhvredu1bcboXCnSKuoG1kErEwVYyqXppauiRWbf5awI)n7SuvKN1lOEihKcJ4HiOfmXCnSK49QSfzWA04ddJDOy)lNzQEzCayrrggkT2(8ZixTTG9HHXouS)LtEWy)uP0XlkhawROiddLwBF(2qe8QGrAbRXhggkT2(CO0(cqUef9rhie4mt1lJdalkAYVmNcg7NkHfAe0kkQdecCMP6LXlYZ6vk8rc2hDGqGxguAXasvOOn2iZbGZdm234vY1X2ht8txYVYdJ3t6qCn6aHaNyUgwskhWAfhawuudtGvqiz8dbxetGvqi13EKVGuROitGvqizCqOfSbRyci258aJ9nELCDS9Xe)ubMlO8W49KoexJoqiWjMRHLKYbSwXbGff1Weyfesg)qWfXeyfes9Th5li1kkYeyfesgheAbBWkMaIDopWyFJxjxhBFmXpna4CkpmEpPdX1OdecCI5AyjPCaRvCayrrnmbwbHKXpeCrmbwbHuF7r(csTIImbwbHKXbHwWgSIjGyNZdm234vY1X2ht8t9Bv14sHdkYbSuEGX(gVsUo2(yIFQ8Tk0fDshItmxdljEVkhWALOiXCnSK4sSZk1sc5ffjMRHLe3wKvljKxuuhie4(TQACPWbf5awIdadMyUgws8EvoG1krrn6aHaNzQEz8I8SEL(ASVXl3FzVaojeIb8K6BpcSoqiWzMQxghawBEGX(gVsUo2(yIFQ)YEb5bg7B8k56y7Jj(PfWQm234v5A5FYAEu8G5CVGcipipWyFJxjhTiZtVxuQId1Q20D0jR5rXLwGupwbijLeMCUtGAoakUgDGqG)Th5hxRcTiZtVxuQ4f5z9kfgcdL7zcjge4icwdXCnSK49Q0XVarrI5AyjX7vjXoRefjMRHLe3bSwPwsiVwrrDGqG)Th5hxRcTiZtVxuQ4f5z9kf2yFJxU8Tk0fXjHqmGNuF7rXGahrWAiMRHLeVxLdyTsuKyUgwsCj2zLAjH8IIeZ1WsIBlYQLeYRvROOp6aHa)BpYpUwfArMNEVOuXbGZdm234vYrlY807fLQyIFQ8TscuqOt6qCn(a1Q20DexAbs9yfGKusyY5ef1Odec8YGslgqQcfTXgzErEwVsFHWq5EMqavg1onM8lZPGX(PcjabcAbRdec8YGslgqQcfTXgzoaSwTIIM8lZPGX(PsyHgH8aJ9nELC0Imp9ErPkM4NYWlu8zs9ciLeUR(LN0H4AGAvB6oIZWlu8zsHssKxg4EFQGXo7juvOHi4vf5z9kfgrqGayFyySdf7F5mt1lJxKHISOOoqiWzMQxghawlyt(L5uWy)u57rraSgDGqGtmxdljLdyTIxKN1Ruyerquuhie4eZ1WssjXoR4f5z9kfgre0kkgAicEvrEwVsFreH8aJ9nELC0Imp9ErPkM4NAOg83qjL0VvENWqM5i1Bfe6LXr8Koe3hu8Znud(BOKs63kpfQ5zqi(3SZ9cbSpg7B8Ynud(BOKs63kpfQ5zqiEVQGRHi4bRXhu8Znud(BOKs63kpLaYC8VzN7fIOik(5gQb)nusj9BLNsazoErEwVsHbPwrru8Znud(BOKs63kpfQ5zqiU8n2zFbbyu8Znud(BOKs63kpfQ5zqiErEwVsFbbyu8Znud(BOKs63kpfQ5zqi(3SZ9cjpWyFJxjhTiZtVxuQIj(PEy8g6IoHHmZrQ3ki0lJJ4jDiErHIKcmDhb(Tcc98V9i1JvOnjmIhcwJgDGqGZmvVmErEwVsHbjyn6aHaVmO0IbKQqrBSrMxKN1Ruyqkk6JoqiWldkTyaPku0gBK5aWAff9rhie4mt1lJdalkAYVmNcg7NkFbbcAbRXhDGqGFUx0IqvKhm2pvE0(kAPcshBIdalkAYVmNcg7NkFbbcAbBWkMaIDwBEGX(gVsoArMNEVOuft8tLaBOl6egYmhPERGqVmoIN0H4ffkskW0De43ki0Z)2JupwH2KWiEiynA0bcboZu9Y4f5z9kfgKG1Odec8YGslgqQcfTXgzErEwVsHbPOOp6aHaVmO0IbKQqrBSrMdaRvu0hDGqGZmvVmoaSOOj)YCkySFQ8feiOfSgF0bcb(5ErlcvrEWy)u5r7ROLkiDSjoaSOOj)YCkySFQ8feiOfSbRyci2zT5bg7B8k5OfzE69IsvmXpv(KZzLk4SIoHHmZrQ3ki0lJJ4jDiErHIKcmDhb(Tcc98V9i1JvOnjmIXcynA0bcboZu9Y4f5z9kfgKG1Odec8YGslgqQcfTXgzErEwVsHbPOOp6aHaVmO0IbKQqrBSrMdaRvu0hDGqGZmvVmoaSOOj)YCkySFQ8feiOfSgF0bcb(5ErlcvrEWy)u5r7ROLkiDSjoaSOOj)YCkySFQ8feiOfSbRyci2zT5bg7B8k5OfzE69IsvmXpnGlgPWb1ApqrN0H4gSIjGyNZdm234vYrlY807fLQyIFAzqPfdivHI2yJ8jDiUoqiWzMQxghaopWyFJxjhTiZtVxuQIj(PN7fTiuLeUR(LN0H4A0OdecCI5AyjPKyNv8I8SELcJicII6aHaNyUgwskhWAfVipRxPWiIGwWmm2HI9VCMP6LXlYZ6vkmiqqROidJDOy)lNzQEz8ImuKZdm234vYrlY807fLQyIFkJCK8BZPmxdz9O9pPdX1Orhie4N7fTiuf5bJ9tLhTVIwQG0XM4aWII(WWqP12NFg5QTvROiddLwBF(2qe8QGrIIqTQnDhXBPYWKOOoqiW1DymQdq(CayW6aHax3HXOoa5ZlYZ6v67HieJMJcQm8Ic0phUiwljL5AiRhTpNwt3rOA1c2hDGqGZmvVmoamyn(WWqP12NVnebVkyKOidJDOy)lNHxO4ZK6fqkjCx9l5aWII9(ubJD2tOQqdrWRkYZ6v6ldJDOy)lNHxO4ZK6fqkjCx9l5f5z9kJjwef79Pcg7SNqvHgIGxvKN1Rejqcepse89qeIrZrbvgErb6NdxeRLKYCnK1J2NtRP7iuTAZdm234vYrlY807fLQyIFAVmRw7B8EshIRrJoqiWp3lArOkYdg7NkpAFfTubPJnXbGff9HHHsRTp)mYvBRwrrggkT2(8THi4vbJefHAvB6oI3sLHjrrDGqGR7WyuhG85aWG1bcbUUdJrDaYNxKN1R0xqGqmAokOYWlkq)C4IyTKuMRHSE0(CAnDhHQvlyF0bcboZu9Y4aWG14dddLwBF(2qe8QGrIImm2HI9VCgEHIptQxaPKWD1VKdalk27tfm2zpHQcnebVQipRxPVmm2HI9VCgEHIptQxaPKWD1VKxKN1RmMyruS3NkySZEcvfAicEvrEwVsKajq8irWxqGqmAokOYWlkq)C4IyTKuMRHSE0(CAnDhHQvBEGX(gVsoArMNEVOuft8tHAvB6o6K18O4sdkPc4sXmvVStGAoakUgFyySdf7F5mt1lJxKHISOOpqTQnDhXz4fk(mPqjjYldmddLwBF(2qe8QGrAZdm234vYrlY807fLQyIFAaOqwHdkYbS0jDioXCnSK49QSfzWgSIjGyNbRbf)Cd1G)gkPK(TYtHAEgeI)n7CVqef9HHHsRTpFjwHD4cvlyOw1MUJ4sdkPc4sXmvVS8aJ9nELC0Imp9ErPkM4NkFRKafe6KoeNHHsRTpFBicEvWiWqTQnDhXz4fk(mPqjjYldSj)YCkySFQeo(rramdJDOy)lNHxO4ZK6fqkjCx9l5f5z9k9fcdL7zcbuzu70yYVmNcg7NkKaeiOnpWyFJxjhTiZtVxuQIj(Pl5x5HX7jDiUgDGqGtmxdljLdyTIdalkQHjWkiKm(HGlIjWkiK6BpYxqQvuKjWkiKmoi0c2Gvmbe7myOw1MUJ4sdkPc4sXmvVS8aJ9nELC0Imp9ErPkM4NkWCbLhgVN0H4A0bcboXCnSKuoG1koamyFyyO0A7ZpJC12kkQrhie4N7fTiuf5bJ9tLhTVIwQG0XM4aWGzyO0A7ZpJC12QvuudtGvqiz8dbxetGvqi13EKVGuROitGvqizCqikQdecCMP6LXbG1c2Gvmbe7myOw1MUJ4sdkPc4sXmvVS8aJ9nELC0Imp9ErPkM4NgaCoLhgVN0H4A0bcboXCnSKuoG1koamyFyyO0A7ZpJC12kkQrhie4N7fTiuf5bJ9tLhTVIwQG0XM4aWGzyO0A7ZpJC12QvuudtGvqiz8dbxetGvqi13EKVGuROitGvqizCqikQdecCMP6LXbG1c2Gvmbe7myOw1MUJ4sdkPc4sXmvVS8aJ9nELC0Imp9ErPkM4N63QQXLchuKdyP8aJ9nELC0Imp9ErPkM4NkFRcDrN0H4eZ1WsI3RYbSwjksmxdljUe7SsTKqErrI5AyjXTfz1sc5ff1bcbUFRQgxkCqroGL4aWG1bcboXCnSKuoG1koaSOOgDGqGZmvVmErEwVsFn234L7VSxaNecXaEs9Thbwhie4mt1lJdaRnpWyFJxjhTiZtVxuQIj(P(l7fKhySVXRKJwK5P3lkvXe)0cyvg7B8QCT8pznpkEWCUxqbKhKhySVXRKhmN7fuaXLVvsGccDshI7tbSuaxqiUU5SLrkCqzoN6f0lejNqYanmmHMhySVXRKhmN7fuaXe)ujWg6IoHHmZrQ3ki0lJJ4jDiok(5Ey8g6I4f5z9kfUipRxzEGX(gVsEWCUxqbet8t9W4n0fLhKhySVXRKdxeS9mbk5h3dJ3qx0jmKzos9wbHEzCepPdXlkuKuGP7iWVvqON)ThPEScTjHr8qWA0OdecCMP6LXlYZ6vkmiff9rhie4mt1lJdalkAYVmNcg7NkFbbcAbBWkMaIDwBEGX(gVsoCrW2ZeOKFmXpvcSHUOtyiZCK6Tcc9Y4iEshIxuOiPat3rGFRGqp)Bps9yfAtcJ4HG1Orhie4mt1lJxKN1Ruyqkk6JoqiWzMQxghawu0KFzofm2pv(cce0c2Gvmbe7S28aJ9nELC4IGTNjqj)yIFQ8jNZkvWzfDcdzMJuVvqOxghXt6q8Icfjfy6oc8Bfe65F7rQhRqBsyeJfWA0OdecCMP6LXlYZ6vkmiff9rhie4mt1lJdalkAYVmNcg7NkFbbcAbBWkMaIDwBEGX(gVsoCrW2ZeOKFmXpnGlgPWb1ApqrN0H4gSIjGyNZdm234vYHlc2EMaL8Jj(PmYrYVnNYCnK1J2)KoexJj)YCkySFQewOrquuhie46omg1biFoamyDGqGR7WyuhG85f5z9k99WyrlyF0bcboZu9Y4aW5bg7B8k5WfbBptGs(Xe)0EzwT2349KoexJj)YCkySFQewOrquuhie46omg1biFoamyDGqGR7WyuhG85f5z9k9feXIwW(OdecCMP6LXbGZdm234vYHlc2EMaL8Jj(PqTQnDhDYAEuCPbLubCPyMQx2jqnhaf3hgg7qX(xoZu9Y4fzOiNhySVXRKdxeS9mbk5ht8tdafYkCqroGLoPdXjMRHLeVxLTid2Gvmbe7myOw1MUJ4sdkPc4sXmvVS8aJ9nELC4IGTNjqj)yIFkZwg5u6aHWjR5rXLVvoCHEshIRdecC5BLdxO8I8SEL(glG1OdecCI5AyjPKyNvCayrrDGqGtmxdljLdyTIdaRfSj)YCkySFQewOripWyFJxjhUiy7zcuYpM4NkFRKafe6KoexJpwSPQFIl)ISZ9crjFRK8Y2ZII6aHaNzQEz8I8SEL(scHyapP(2Jef9bUiOC5BLeOGqAbRrhie4mt1lJdalkAYVmNcg7NkHfAeatmxdljEVkBrwBEGX(gVsoCrW2ZeOKFmXpv(wjbki0jDiUgFSytv)ex(fzN7fIs(wj5LTNff1bcboZu9Y4f5z9k9LecXaEs9Thjk6dCrq5Y3kjqbH0c(nhTpx(w5WfkNwt3rOG1OdecC5BLdxOCayrrt(L5uWy)ujSqJGwW6aHax(w5Wfkx(g7SVGaSgDGqGtmxdljLe7SIdalkQdecCI5AyjPCaRvCayTGzySdf7F5mt1lJxKN1RuyqzEGX(gVsoCrW2ZeOKFmXpv(wjbki0jDiUgFSytv)ex(fzN7fIs(wj5LTNff1bcboZu9Y4f5z9k9LecXaEs9Thjk6dCrq5Y3kjqbH0cwhie4eZ1WssjXoR4f5z9kfgucMyUgws8EvsSZkW(8MJ2NlFRC4cLtRP7iuWmm2HI9VCMP6LXlYZ6vkmOmpWyFJxjhUiy7zcuYpM4NUKFLhgVN0H4A0bcboXCnSKuoG1koaSOOgMaRGqY4hcUiMaRGqQV9iFbPwrrMaRGqY4GqlydwXeqSZGHAvB6oIlnOKkGlfZu9YYdm234vYHlc2EMaL8Jj(Pcmxq5HX7jDiUgDGqGtmxdljLdyTIdalkQHjWkiKm(HGlIjWkiK6BpYxqQvuKjWkiKmoief1bcboZu9Y4aWAbBWkMaIDgmuRAt3rCPbLubCPyMQxwEGX(gVsoCrW2ZeOKFmXpna4CkpmEpPdX1OdecCI5AyjPCaRvCayrrnmbwbHKXpeCrmbwbHuF7r(csTIImbwbHKXbHOOoqiWzMQxghawlydwXeqSZGHAvB6oIlnOKkGlfZu9YYdm234vYHlc2EMaL8Jj(P(TQACPWbf5awkpWyFJxjhUiy7zcuYpM4NkFRcDrN0H4ASytv)ex(fzN7fIs(wj5LTNbRdecCMP6LXlYZ6vkmjeIb8K6BpcmCrq5(l7fOvuuJpwSPQFIl)ISZ9crjFRK8Y2ZII6aHaNzQEz8I8SEL(scHyapP(2Jef9bUiOC5BvOlslyneZ1WsI3RYbSwjksmxdljUe7SsTKqErrI5AyjXTfz1sc5ff1bcbUFRQgxkCqroGL4aWG1bcboXCnSKuoG1koaSOOgDGqGZmvVmErEwVsFn234L7VSxaNecXaEs9Thbwhie4mt1lJdaRvROOgl2u1pXrn)BVqusGLx2Ew4dbRdecCI5AyjPKyNv8I8SELcdsW(OdecCuZ)2leLey5f5z9kf2yFJxU)YEbCsied4j13EK28aHYCekeYbzmqopgFoNONCoRYjwF1H)KCqgdKdCH1nDhY5432phj2JYj6TkyoxoaWF7rCoppWyFJxjhUiy7zcuYpM4NkFRcMZDshI)MJ2NlFY5SsHwD450A6ocfSoqiWLVvbZ54ffkskW0De4qdrWRkYZ6vkSoqiWLVvbZ54OaL9nEbRXhI5AyjX7vzlYII6aHax(wjbkiKI8GX(PYJ2NdaRnpWyFJxjhUiy7zcuYpM4N6VSxqEGX(gVsoCrW2ZeOKFmXpTawLX(gVkxl)twZJIhmN7fua5b5bg7B8k5YpUHAWFdLus)w5DcdzMJuVvqOxghXt6qCFqXp3qn4VHskPFR8uOMNbH4FZo3leW(ySVXl3qn4VHskPFR8uOMNbH49QcUgIGhSgFqXp3qn4VHskPFR8uciZX)MDUxiIIO4NBOg83qjL0VvEkbK54f5z9kfgKAffrXp3qn4VHskPFR8uOMNbH4Y3yN9feGrXp3qn4VHskPFR8uOMNbH4f5z9k9feGrXp3qn4VHskPFR8uOMNbH4FZo3lK8aJ9nELC5ht8tz4fk(mPEbKsc3v)Yt6qCnqTQnDhXz4fk(mPqjjYldCVpvWyN9eQk0qe8QI8SELcJiiqaSpmm2HI9VCMP6LXlYqrwuuhie4mt1lJdaRfSj)YCkySFQ8fKiawJoqiWjMRHLKYbSwXlYZ6vkmIiikQdecCI5AyjPKyNv8I8SELcJicAffdnebVQipRxPViIqEGX(gVsU8Jj(PqTQnDhDYAEuCu8Rkcjd0f5r7lpbQ5aO4A0bcboZu9Y4f5z9kfgKG1Odec8YGslgqQcfTXgzErEwVsHbPOOp6aHaVmO0IbKQqrBSrMdaRvu0hDGqGZmvVmoaSOOj)YCkySFQ8feiOfSgF0bcb(5ErlcvrEWy)u5r7ROLkiDSjoaSOOj)YCkySFQ8feiOfSgDGqGtmxdljLe7SIxKN1RuyimuUNjerrDGqGtmxdljLdyTIxKN1RuyimuUNjeT5bg7B8k5YpM4N6HXBOl6egYmhPERGqVmoIN0H4ffkskW0De43ki0Z)2JupwH2KWiEiyngSIjGyNbd1Q20Dehf)QIqYaDrE0(sT5bg7B8k5YpM4Nkb2qx0jmKzos9wbHEzCepPdXlkuKuGP7iWVvqON)ThPEScTjHr8qWAmyftaXodgQvTP7iok(vfHKb6I8O9LAZdm234vYLFmXpv(KZzLk4SIoHHmZrQ3ki0lJJ4jDiErHIKcmDhb(Tcc98V9i1JvOnjmIXcyngSIjGyNbd1Q20Dehf)QIqYaDrE0(sT5bg7B8k5YpM4NgWfJu4GAThOOt6qCdwXeqSZ5bg7B8k5YpM4NwguAXasvOOn2iFshIRdecCMP6LXbGZdm234vYLFmXp9CVOfHQKWD1V8KoexJgDGqGtmxdljLe7SIxKN1Ruyerquuhie4eZ1Wss5awR4f5z9kfgre0cMHXouS)LZmvVmErEwVsHbbcG1OdecC4Q9WfABoLvmBBMcgWjTId1CaKVhEueef9PawkGliehUApCH2MtzfZ2MPGbCsR4esgOHHjuTAff1bcboC1E4cTnNYkMTntbd4KwXHAoas44hckrquKHXouS)LZmvVmErgkYG1yYVmNcg7NkHfAeefHAvB6oI3sLHjT5bg7B8k5YpM4NYihj)2CkZ1qwpA)t6qCnM8lZPGX(PsyHgbWA0bcb(5ErlcvrEWy)u5r7ROLkiDSjoaSOOpmmuAT95NrUAB1kkYWqP12NVnebVkyKOiuRAt3r8wQmmjkQdecCDhgJ6aKphagSoqiW1DymQdq(8I8SEL(EicXOrJqdQfWsbCbH4Wv7Hl02CkRy22mfmGtAfNqYanmmHQngnhfuz4ffOFoCrSwskZ1qwpAFoTMUJq1QvlyF0bcboZu9Y4aWG14dddLwBF(2qe8QGrIImm2HI9VCgEHIptQxaPKWD1VKdalk27tfm2zpHQcnebVQipRxPVmm2HI9VCgEHIptQxaPKWD1VKxKN1RmMyruS3NkySZEcvfAicEvrEwVsKajq8irW3drignhfuz4ffOFoCrSwskZ1qwpAFoTMUJq1QnpWyFJxjx(Xe)0EzwT2349KoexJj)YCkySFQewOraSgDGqGFUx0IqvKhm2pvE0(kAPcshBIdalk6dddLwBF(zKR2wTIImmuAT95BdrWRcgjkc1Q20DeVLkdtII6aHax3HXOoa5ZbGbRdecCDhgJ6aKpVipRxPVGaHy0OrOb1cyPaUGqC4Q9WfABoLvmBBMcgWjTItizGggMq1gJMJcQm8Ic0phUiwljL5AiRhTpNwt3rOA1QfSp6aHaNzQEzCayWA8HHHsRTpFBicEvWirrgg7qX(xodVqXNj1lGus4U6xYbGff79Pcg7SNqvHgIGxvKN1R0xgg7qX(xodVqXNj1lGus4U6xYlYZ6vgtSik27tfm2zpHQcnebVQipRxjsGeiEKi4liqignhfuz4ffOFoCrSwskZ1qwpAFoTMUJq1QnpWyFJxjx(Xe)uOw1MUJoznpkU0GsQaUumt1l7eOMdGIRXhgg7qX(xoZu9Y4fzOilk6duRAt3rCgEHIptkusI8YaZWqP12NVnebVkyK28aJ9nELC5ht8tdafYkCqroGLoPdXjMRHLeVxLTid2Gvmbe7myDGqGdxThUqBZPSIzBZuWaoPvCOMdG89WJIaynO4NBOg83qjL0VvEkuZZGq8VzN7fIOOpmmuAT95lXkSdxOAbd1Q20DexAqjvaxkMP6LLhySVXRKl)yIFQ8Tkyo3jDiUoqiWXl9cKkyQye834Ldadwhie4Y3QG5C8Icfjfy6okpWyFJxjx(Xe)uMTmYP0bcHtwZJIlFRC4c9Koexhie4Y3khUq5f5z9k9fKG1OdecCI5AyjPKyNv8I8SELcdsrrDGqGtmxdljLdyTIxKN1RuyqQfSj)YCkySFQewOripWyFJxjx(Xe)u5BLeOGqN0H4mmuAT95BdrWRcgbgQvTP7iodVqXNjfkjrEzGzySdf7F5m8cfFMuVasjH7QFjVipRxPVqyOCptiGkJANgt(L5uWy)uHeGabT5bg7B8k5YpM4NkFRcMZDshI)MJ2NlFY5SsHwD450A6ocfSpV5O95Y3khUq50A6ocfSoqiWLVvbZ54ffkskW0Deyn6aHaNyUgwskhWAfVipRxPWXcyI5AyjX7v5awRaRdecC4Q9WfABoLvmBBMcgWjTId1CaKVhcseef1bcboC1E4cTnNYkMTntbd4KwXHAoas44hcseaBYVmNcg7NkHfAeefrXp3qn4VHskPFR8uOMNbH4f5z9kf(iffn234LBOg83qjL0VvEkuZZGq8EvbxdrWRfSpmm2HI9VCMP6LXlYqropWyFJxjx(Xe)u5BLeOGqN0H46aHahV0lqQyoYkf0w24LdalkQdec8Z9IweQI8GX(PYJ2xrlvq6ytCayrrDGqGZmvVmoamyn6aHaVmO0IbKQqrBSrMxKN1R0ximuUNjeqLrTtJj)YCkySFQqcqGGwW6aHaVmO0IbKQqrBSrMdalk6JoqiWldkTyaPku0gBK5aWG9HHXouS)LxguAXasvOOn2iZlYqrwu0hggkT2(CO0(cqU0kkAYVmNcg7NkHfAeatmxdljEVkBropWyFJxjx(Xe)u5BLeOGqN0H4V5O95Y3khUq50A6ocfSgDGqGlFRC4cLdalkAYVmNcg7NkHfAe0cwhie4Y3khUq5Y3yN9feG1OdecCI5AyjPKyNvCayrrDGqGtmxdljLdyTIdaRfSoqiWHR2dxOT5uwXSTzkyaN0kouZbq(EiOebWAyySdf7F5mt1lJxKN1Ruyerqu0hOw1MUJ4m8cfFMuOKe5LbMHHsRTpFBicEvWiT5bg7B8k5YpM4NkFRKafe6KoexJoqiWHR2dxOT5uwXSTzkyaN0kouZbq(EiOebrrDGqGdxThUqBZPSIzBZuWaoPvCOMdG89qqIa43C0(C5toNvk0QdpNwt3rOAbRdecCI5AyjPKyNv8I8SELcdkbtmxdljEVkj2zfyF0bcboEPxGubtfJG)gVCayW(8MJ2NlFRC4cLtRP7iuWmm2HI9VCMP6LXlYZ6vkmOeSggg7qX(x(5ErlcvjH7QFjVipRxPWGsrrFyyO0A7ZpJC12QnpWyFJxjx(Xe)0L8R8W49KoexJoqiWjMRHLKYbSwXbGff1Weyfesg)qWfXeyfes9Th5li1kkYeyfesgheAbBWkMaIDgmuRAt3rCPbLubCPyMQxwEGX(gVsU8Jj(Pcmxq5HX7jDiUgDGqGtmxdljLdyTIdad2hggkT2(8ZixTTIIA0bcb(5ErlcvrEWy)u5r7ROLkiDSjoamyggkT2(8ZixTTAff1Weyfesg)qWfXeyfes9Th5li1kkYeyfesgheII6aHaNzQEzCayTGnyftaXodgQvTP7iU0GsQaUumt1llpWyFJxjx(Xe)0aGZP8W49KoexJoqiWjMRHLKYbSwXbGb7dddLwBF(zKR2wrrn6aHa)CVOfHQipySFQ8O9v0sfKo2ehagmddLwBF(zKR2wTIIAycSccjJFi4IycSccP(2J8fKAffzcSccjJdcrrDGqGZmvVmoaSwWgSIjGyNbd1Q20DexAqjvaxkMP6LLhySVXRKl)yIFQFRQgxkCqroGLYdm234vYLFmXpv(wf6IoPdXjMRHLeVxLdyTsuKyUgwsCj2zLAjH8IIeZ1WsIBlYQLeYlkQdecC)wvnUu4GICalXbGbRdecCI5AyjPCaRvCayrrn6aHaNzQEz8I8SEL(ASVXl3FzVaojeIb8K6BpcSoqiWzMQxghawBEGX(gVsU8Jj(P(l7fKhySVXRKl)yIFAbSkJ9nEvUw(NSMhfpyo3lOaUrsyIDpgreo8(3)Eb]] )


end