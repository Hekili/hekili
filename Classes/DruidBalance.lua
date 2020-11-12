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
        removeBuff( "starsurge_empowerment" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire CA_Inc: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseLunar = setfenv( function()
        eclipse.state = "SOLAR_NEXT"
        eclipse.reset_stacks()
        removeBuff( "starsurge_empowerment" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
        removeBuff( "starsurge_empowerment" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Solar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    spec:RegisterStateTable( "eclipse", setmetatable( {
        -- ANY_NEXT, IN_SOLAR, IN_LUNAR, IN_BOTH, SOLAR_NEXT, LUNAR_NEXT
        state = "ANY_NEXT",
        wrath_counter = 2,
        starfire_counter = 2,

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

            removeBuff( "starsurge_empowerment" )
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

        -- Eclipses
        -- ANY_NEXT, IN_SOLAR, IN_LUNAR, IN_BOTH, SOLAR_NEXT, LUNAR_NEXT

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

                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment" ) end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment" ) end

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
                starsurge_empowerment = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = max( buff.eclipse_lunar.remains, buff.eclipse_solar.remains )
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
                    end
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


    spec:RegisterPack( "Balance", 20201111, [[dKerRdqiQkEebjCjicBcO(KkuPgfP4uKsRciQxjumlve3cIi7cv)sfPHbbhdcTmvqpdizAQq5AaHTjuIVbePXPcvDocsTocs6DeKOY8OQ09eQ2hb1bvHkyHqKEOqjnrvOsCrcsu1hvHkQtsqISsvGzceXnjirzNQqgQkurwQkuHEQqMkqQVQcvs7vL(lrdwPdtzXKQhJYKH0Lr2SGpdsJMaNwQxRIA2u52uLDR43qnCqDCiIA5sEojtxvxhW2bX3PQA8eeNhIA9cLA(eA)I(I4f03iu7P7rhIWHiGiIiIi)qepgi9qq6n6rgMUrWg7SbLUrJ5r3iKAoBy0nc2q2Hn0lOVrkmqXOBKG)Hvc1tpfA)ca05mS3PQ2dWzFJhwzH)uv7Xo9gPd0UxO0C1VrO2t3JoeHdrarerer(HiE4HG4gzaVaCDJIAVy9gjOrrP5QFJqjf7gjuKlsnNnmk3JlfqJMhiuK7ryiKNov5IiINK7HiCic5b5bcf5gRcSbkPeQ5bcf5IKY94akkHMBe2zvUiLmpEEGqrUiPCJvb2aLqZ9Tck9YoKlZuKk3hNldzMJKVvqPxXZdekYfjL7XrYddHqZfygIrkLviNleRAt3rQC10CIFsUWfbrQERuafukxKKW5cxeeU6TsbuqjT88aHICrs5kuwp4kxcT)CFCU0WWaLbLYn6TkyoxU9KBeOZ1F)cYn6jNZQCpUuD4ZvJqzXOvOC5QeGbCO5cxyDt3HCU6uUwUkyILlg(B8WVrUw9QlOVrWfXWE62Fb99ieVG(gzSVXZnYdJNZ9id4Y7grJP7i0lsV)9OdVG(grJP7i0lsVrg7B8CJ8x2l4g56HKm0BeIiC)7rG6c6BenMUJqVi9gXQ(PQTBeCrq4iY9x2lixW56tUWfbHFi3FzVGBKX(gp3i)L9cU)9OJDb9nYyFJNBK6Tk0fDJOX0De6fP3)EeiUG(grJP7i0lsVry4BKI(BKX(gp3iiw1MUJUrqmhaDJ0XkvUGZn4W4kxn5Qj3qdvWllYZ6rLlsk3drixT5EAUiEic5QnxHZn4W4kxn5Qj3qdvWllYZ6rLlsk3dbrUiPC1KlIiKliN7BoAEEpmRg7B8WPX0DeAUAZfjLRMCpwUGCUm8Gc0phUiwRiP5AOJhnpNgt3rO5QnxT5EAUiE8iKR2BeeRKJ5r3igEGGptsusH8WU)9Vr6y7VG(EeIxqFJOX0De6fP3iw1pvTDJ0bcboZK9W4aW3iJ9nEUrLbHgmGsgkAInY3)E0HxqFJOX0De6fP3im8nsr)nYyFJNBeeRAt3r3iiMdGUrbhgx5Qjxn52Ztfm2zpHkdnubVSipRhvUiPCpeHC1M7P5I4HiKR2Cfo3GdJRC1KRMC75Pcg7SNqLHgQGxwKN1JkxKuUhcICrs5Qjxerixqo33C088Eywn234HtJP7i0C1Mlskxn5ESCb5Cz4bfOFoCrSwrsZ1qhpAEonMUJqZvBUAZ90Cr84rixT3iiwjhZJUrm8abFMKOKc5HD)7rG6c6BenMUJqVi9gHHVrk6Vrg7B8CJGyvB6o6gbXCa0nYNC1bcbUU5SHrsCqAoN8f0duLCShOioaCUGZ1NC1bcbUU5SHrsCqAoN8f0duL0kMneha(gbXk5yE0nIv9p4ha((3Jo2f03iAmDhHEr6nYyFJNBKHAWFdHKk)w5DJyv)u12nshie46MZggjXbP5CYxqpqvYXEGI4Q3yNLqmhaLRV5EmeYfCU6aHax3C2WijoinNt(c6bQsAfZgIREJDwcXCauU(M7XqixW5QjxFYff)Cd1G)gcjv(TYtIAEguI)n7CpqZfCU(KRX(gpCd1G)gcjv(TYtIAEguI3Jm4AOc(CbNRMC9jxu8Znud(BiKu53kpPaYC8VzN7bAUII5IIFUHAWFdHKk)w5jfqMJxKN1JkxHZfu5QnxrXCrXp3qn4VHqsLFR8KOMNbL4Q3yNZ13CbvUGZff)Cd1G)gcjv(TYtIAEguIxKN1JkxFZfe5coxu8Znud(BiKu53kpjQ5zqj(3SZ9anxT3igYmhjFRGsV6EeI3)EeiUG(grJP7i0lsVrSQFQA7gPjxiw1MUJ4m8abFMKOKc5HLl4C75Pcg7SNqLHgQGxwKN1JkxHZfrqHqUGZ1NCzySdf7F4mt2dJxKHICUII5QdecCMj7HXbGZvBUGZvtU6aHax3C2WijoinNt(c6bQso2duex9g7SeI5aOCJNliqixrXC1bcbUU5SHrsCqAoN8f0duL0kMnex9g7SeI5aOCJNliqixT5kkMBOHk4Lf5z9OY13CreHBKX(gp3igEGGptYxajvWD1V6(3JILlOVr0y6oc9I0BeR6NQ2UrAYvhie46MZggjXbP5CYxqpqvYXEGI4f5z9OYv4Cpghe5kkMRoqiW1nNnmsIdsZ5KVGEGQKwXSH4f5z9OYv4Cpghe5QnxW5AQVmNeg7NQCfoEUcnc5coxn5YWyhk2)WzMShgVipRhvUcNlinxrXC1KldJDOy)dN8GX(PsQJhuErEwpQCfoxqAUGZ1NC1bcb(5EqlcvsEWy)u5rZlPHkODSjoaCUGZLHHqJnp)mYvBtUAZv7nYyFJNBeZgg5K6aHWnshieKJ5r3i1BLdxO3)Eei9c6BenMUJqVi9gXQ(PQTBKp5cXQ20DeNv9p4haoxW5Qjxggcn288PHk4LbJYvumxgg7qX(hoZK9W4f5z9OYv4CbP5kkMRMCzySdf7F4Khm2pvsD8GYlYZ6rLRW5csZfCU(KRoqiWp3dArOsYdg7NkpAEjnubTJnXbGZfCUmmeAS55NrUABYvBUAVrg7B8CJuVvkGckD)7rh)f03iAmDhHEr6nIv9tvB3in5YWyhk2)Wz4bc(mjFbKub3v)koaCUGZvtUqSQnDhXz4bc(mjrjfYdlxrXCzySdf7F4mt2dJxKN1JkxFZfe5QnxT5coxt9L5KWy)uLRW5cceYfCUmmeAS55tdvWldgDJm2345gPERuafu6(3Je6lOVr0y6oc9I0BKX(gp3ifWe6IUrSQFQA7gvuOiLat3r5co33kO0Z)2JKpwI2uUcNlIXsUGZvtUgSKjGyNZfCUAYfIvTP7ioR6FWpaCUII5Qjxt9L5KWy)uLRV5ckeYfCU(KRoqiWzMShghaoxT5kkMldJDOy)dNzYEy8ImuKZvBUAVrmKzos(wbLE19ieV)9ier4c6BenMUJqVi9gzSVXZnYdJNqx0nIv9tvB3OIcfPey6okxW5(wbLE(3EK8Xs0MYv4CreuCqKl4C1KRblzci25CbNRMCHyvB6oIZQ(h8daNROyUAY1uFzojm2pv56BUGcHCbNRp5QdecCMj7HXbGZvBUII5YWyhk2)WzMShgVidf5C1Ml4C9jxDGqGFUh0IqLKhm2pvE08sAOcAhBIdaNR2BedzMJKVvqPxDpcX7FpcreVG(grJP7i0lsVrg7B8CJup5CwjdoROBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5IySKBm5wKN1JkxW5QjxdwYeqSZ5coxn5cXQ20DeNv9p4haoxrXCn1xMtcJ9tvU(MlOqixrXCzySdf7F4mt2dJxKHICUAZv7nIHmZrY3kO0RUhH49VhH4HxqFJOX0De6fP3iw1pvTDJmyjtaXoFJm2345gfWfJK4GCShOO7FpcrqDb9nIgt3rOxKEJyv)u12nstUeZ1WkI3J0gKZvumxI5AyfXvyNvYEKiMROyUeZ1WkI7agRK9irmxT5coxn56tUmmeAS55tdvWldgLROyUAY1uFzojm2pv56BUcniYfCUAYfIvTP7ioR6FWpaCUII5AQVmNeg7NQC9nxqHqUII5cXQ20DeVvsdt5QnxW5Qjxiw1MUJ4m8abFMKOKc5HLl4C9jxgg7qX(hodpqWNj5lGKk4U6xXbGZvumxFYfIvTP7iodpqWNjjkPqEy5coxFYLHXouS)HZmzpmoaCUAZvBUAZfCUAYLHXouS)HZmzpmErEwpQCfoxqHqUII5AQVmNeg7NQCfoxHgHCbNldJDOy)dNzYEyCa4CbNRMCzySdf7F4Khm2pvsD8GYlYZ6rLRV5ASVXdx9wf6I4KqigWtYV9OCffZ1NCzyi0yZZpJC12KR2CffZTNNkySZEcvgAOcEzrEwpQC9nxerixT5coxn5IIFUHAWFdHKk)w5jrnpdkXlYZ6rLRW5ESCffZ1NCzyi0yZZhIvyhUqZv7nYyFJNBuaOqwIdsYbm09VhH4XUG(grJP7i0lsVrSQFQA7gPjxI5AyfXDaJvYHeYNROyUeZ1WkIRWoRKdjKpxrXCjMRHve3gKLdjKpxrXC1bcbUU5SHrsCqAoN8f0duLCShOiErEwpQCfo3JXbrUII5QdecCDZzdJK4G0Co5lOhOkPvmBiErEwpQCfo3JXbrUII5AQVmNeg7NQCfoxHgHCbNldJDOy)dNzYEy8ImuKZvBUGZvtUmm2HI9pCMj7HXlYZ6rLRW5ckeYvumxgg7qX(hoZK9W4fzOiNR2CffZTNNkySZEcvgAOcEzrEwpQC9nxer4gzSVXZn6CpOfHkvWD1V6(3JqeexqFJOX0De6fP3iw1pvTDJ0KRP(YCsySFQYv4CfAeYfCUAYvhie4N7bTiuj5bJ9tLhnVKgQG2XM4aW5kkMRp5YWqOXMNFg5QTjxT5kkMlddHgBE(0qf8YGr5kkMRoqiW1DymQdq9Ca4CbNRoqiW1DymQdq98I8SEu56BUhIqUXKRMCpwUGCUm8Gc0phUiwRiP5AOJhnpNgt3rO5QnxT5coxn56tUmmeAS55tdvWldgLROyUmm2HI9pCgEGGptYxajvWD1VIdaNROyU98ubJD2tOYqdvWllYZ6rLRV5YWyhk2)Wz4bc(mjFbKub3v)kErEwpQCJj3yjxrXC75Pcg7SNqLHgQGxwKN1JkxKixepEeY13CpeHCJjxn5ESCb5Cz4bfOFoCrSwrsZ1qhpAEonMUJqZvBUAVrg7B8CJyKJuFBoP5AOJhn)9VhHySCb9nIgt3rOxKEJyv)u12nstUM6lZjHX(PkxHZvOrixW5QjxDGqGFUh0IqLKhm2pvE08sAOcAhBIdaNROyU(KlddHgBE(zKR2MC1MROyUmmeAS55tdvWldgLROyU6aHax3HXOoa1ZbGZfCU6aHax3HXOoa1ZlYZ6rLRV5ckeYnMC1K7XYfKZLHhuG(5WfXAfjnxdD8O550y6ocnxT5QnxW5QjxFYLHHqJnpFAOcEzWOCffZLHXouS)HZWde8zs(ciPcUR(vCa4CffZfIvTP7iodpqWNjjkPqEy5co3EEQGXo7juzOHk4Lf5z9OYv4Cr84ri3yY9qeYnMC1K7XYfKZLHhuG(5WfXAfjnxdD8O550y6ocnxT5kkMBppvWyN9eQm0qf8YI8SEu56BUmm2HI9pCgEGGptYxajvWD1VIxKN1Jk3yYnwYvum3EEQGXo7juzOHk4Lf5z9OY13Cbfc5gtUAY9y5cY5YWdkq)C4IyTIKMRHoE08CAmDhHMR2C1EJm2345g1dZQX(gp3)EeIG0lOVr0y6oc9I0BeR6NQ2UrmmeAS55tdvWldgLl4C1KleRAt3rCgEGGptsusH8WYvumxgg7qX(hoZK9W4f5z9OY13CreHC1Ml4Cn1xMtcJ9tvUcNliqixW5YWyhk2)Wz4bc(mjFbKub3v)kErEwpQC9nxer4gzSVXZns9wPakO09VhH4XFb9nIgt3rOxKEJWW3if93iJ9nEUrqSQnDhDJGyoa6grmxdRiEpshWyvUGCUhFUNMRX(gpC1BvOlItcHyapj)2JYnMC9jxI5AyfX7r6agRYfKZnwY90Cn234H7VSxaNecXaEs(ThLBm5Ia)WCpnxfm5CsbM6PBeeRKJ5r3itbFCIQiID)7rik0xqFJOX0De6fP3iw1pvTDJ0KBppvWyN9eQm0qf8YI8SEu56BUhlxrXC1KRoqiWldcnyaLmu0eBK5f5z9OY13CHYq5EMqYfKZLrTlxn5AQVmNeg7NQCpnxqHqUAZfCU6aHaVmi0GbuYqrtSrMdaNR2C1MROyUAY1uFzojm2pv5gtUqSQnDhXnf8XjQIiwUGCU6aHaNyUgwrsf2zfVipRhvUXKlk(5bGczjoijhWq8VzNvYI8SEYfKZ9qoiYv4Cr8qeYvumxt9L5KWy)uLBm5cXQ20De3uWhNOkIy5cY5QdecCI5AyfjDaJv8I8SEu5gtUO4NhakKL4GKCadX)MDwjlYZ6jxqo3d5GixHZfXdrixT5coxI5AyfX7rAdY5coxn5QjxFYLHXouS)HZmzpmoaCUII5YWqOXMNFg5QTjxW56tUmm2HI9pCYdg7NkPoEq5aW5QnxrXCzyi0yZZNgQGxgmkxT5coxn56tUmmeAS55qO5fGCLROyU(KRoqiWzMShghaoxrXCn1xMtcJ9tvUcNRqJqUAZvumxDGqGZmzpmErEwpQCfo3JpxW56tU6aHaVmi0GbuYqrtSrMdaFJm2345gPERuafu6(3JoeHlOVr0y6oc9I0BeR6NQ2UrAYvhie4eZ1Wks6agR4aW5kkMRMCzcSckPYnEUhMl4ClIjWkOK8BpkxFZfe5QnxrXCzcSckPYnEUGkxT5coxdwYeqSZ3iJ9nEUrd5x6HXZ9VhDiIxqFJOX0De6fP3iw1pvTDJ0KRoqiWjMRHvK0bmwXbGZvumxn5YeyfusLB8CpmxW5wetGvqj53EuU(MliYvBUII5YeyfusLB8CbvUAZfCUgSKjGyNVrg7B8CJeyUG0dJN7Fp6WdVG(grJP7i0lsVrSQFQA7gPjxDGqGtmxdRiPdySIdaNROyUAYLjWkOKk345EyUGZTiMaRGsYV9OC9nxqKR2CffZLjWkOKk345cQC1Ml4CnyjtaXoFJm2345gfaCoPhgp3)E0HG6c6BKX(gp3i)wvnUK4GKCadDJOX0De6fP3)E0Hh7c6BenMUJqVi9gXQ(PQTBeXCnSI49iDaJv5kkMlXCnSI4kSZk5qc5ZvumxI5AyfXTbz5qc5ZvumxDGqG73QQXLehKKdyioaCUGZLyUgwr8EKoGXQCffZvtU6aHaNzYEy8I8SEu56BUg7B8W9x2lGtcHyapj)2JYfCU6aHaNzYEyCa4C1EJm2345gPERcDr3)E0HG4c6BKX(gp3i)L9cUr0y6oc9I07Fp6Wy5c6BenMUJqVi9gzSVXZnQagPX(gpsxR(BKRvVCmp6gfmN7fua3)(3iukyaU)c67riEb9nYyFJNBKc7SsQtM3nIgt3rOxKE)7rhEb9nIgt3rOxKEJWW3if93iJ9nEUrqSQnDhDJGyoa6gPGjNt(wbLEfx9wfmNlxHZfXCbNRMC9j33C08C1BLdxOCAmDhHMROyUV5O55QNCoRKOvhEonMUJqZvBUII5QGjNt(wbLEfx9wfmNlxHZ9WBeeRKJ5r3OwjnmD)7rG6c6BenMUJqVi9gHHVrk6Vrg7B8CJGyvB6o6gbXCa0nsbtoN8Tck9kU6Tk0fLRW5I4ncIvYX8OBuRKmhzqO7Fp6yxqFJOX0De6fP3iw1pvTDJ0KRp5YWqOXMNpnubVmyuUII56tUmm2HI9pCgEGGptYxajvWD1VIdaNR2CbNRoqiWzMShgha(gzSVXZnsNkfvN7b69VhbIlOVr0y6oc9I0BeR6NQ2Ur6aHaNzYEyCa4BKX(gp3iy8345(3JILlOVrg7B8CJauKSFYtDJOX0De6fP3)Eei9c6BenMUJqVi9gXQ(PQTBKJGqUC9nxqG4nYyFJNBKaYQxskfnm6(3Jo(lOVr0y6oc9I0BeR6NQ2UrqSQnDhXBL0W0ns9vZ(7riEJm2345gvaJ0yFJhPRv)nY1QxoMhDJmmD)7rc9f03iAmDhHEr6nIv9tvB3OcyOaUGs8V9i)4AKOfzE69GsfNqYanmmHEJuF1S)EeI3iJ9nEUrfWin234r6A1FJCT6LJ5r3i0Imp9EqP6(3JqeHlOVr0y6oc9I0BeR6NQ2UrfWqbCbL46MZggjXbP5CYxqpqvCcjd0WWe6ns9vZ(7riEJm2345gvaJ0yFJhPRv)nY1QxoMhDJ0X2F)7riI4f03iAmDhHEr6nIv9tvB3ihbHC5kCUGaHBKX(gp3OcyKg7B8iDT6VrUw9YX8OBK6V)9iep8c6BenMUJqVi9gzSVXZnQagPX(gpsxR(BKRvVCmp6gbxeS9mbs1F)7FJqlY807bLQlOVhH4f03iAmDhHEr6ncdFJu0FJm2345gbXQ20D0ncI5aOBKMC1bcb(3EKFCns0Imp9EqPIxKN1JkxHZfkdL7zcj3yYfboI5coxn5smxdRiEpsD8lixrXCjMRHveVhPc7SkxrXCjMRHve3bmwjhsiFUAZvumxDGqG)Th5hxJeTiZtVhuQ4f5z9OYv4Cn234HRERcDrCsied4j53EuUXKlcCeZfCUAYLyUgwr8EKoGXQCffZLyUgwrCf2zLCiH85kkMlXCnSI42GSCiH85QnxT5kkMRp5Qdec8V9i)4AKOfzE69Gsfha(gbXk5yE0nszbs(yjGIKkyY5U)9OdVG(grJP7i0lsVrSQFQA7gPjxFYfIvTP7iUYcK8XsafjvWKZLROyUAYvhie4LbHgmGsgkAInY8I8SEu56BUqzOCpti5cY5YO2LRMCn1xMtcJ9tvUNMlOqixT5coxDGqGxgeAWakzOOj2iZbGZvBUAZvumxt9L5KWy)uLRW5k0iCJm2345gPERuafu6(3Ja1f03iAmDhHEr6nIv9tvB3in5cXQ20DeNHhi4ZKeLuipSCbNBppvWyN9eQm0qf8YI8SEu5kCUickeYfCU(KldJDOy)dNzYEy8ImuKZvumxDGqGZmzpmoaCUAZfCUM6lZjHX(PkxFZ9yiKl4C1KRoqiWjMRHvK0bmwXlYZ6rLRW5Iic5kkMRoqiWjMRHvKuHDwXlYZ6rLRW5Iic5QnxrXCdnubVSipRhvU(MlIiCJm2345gXWde8zs(ciPcUR(v3)E0XUG(grJP7i0lsVrg7B8CJmud(BiKu53kVBeR6NQ2Ur(Klk(5gQb)nesQ8BLNe18mOe)B25EGMl4C9jxJ9nE4gQb)nesQ8BLNe18mOeVhzW1qf85coxn56tUO4NBOg83qiPYVvEsbK54FZo3d0CffZff)Cd1G)gcjv(TYtkGmhVipRhvUcNliYvBUII5IIFUHAWFdHKk)w5jrnpdkXvVXoNRV5cQCbNlk(5gQb)nesQ8BLNe18mOeVipRhvU(MlOYfCUO4NBOg83qiPYVvEsuZZGs8VzN7b6nIHmZrY3kO0RUhH49VhbIlOVr0y6oc9I0BKX(gp3ipmEcDr3iw1pvTDJkkuKsGP7OCbN7Bfu65F7rYhlrBkxHZfXdZfCUAYvtU6aHaNzYEy8I8SEu5kCUGixW5QjxDGqGxgeAWakzOOj2iZlYZ6rLRW5cICffZ1NC1bcbEzqObdOKHIMyJmhaoxT5kkMRp5QdecCMj7HXbGZvumxt9L5KWy)uLRV5ckeYvBUGZvtU(KRoqiWp3dArOsYdg7NkpAEjnubTJnXbGZvumxt9L5KWy)uLRV5ckeYvBUGZ1GLmbe7CUAVrmKzos(wbLE19ieV)9Oy5c6BenMUJqVi9gzSVXZnsbmHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4H5coxn5QjxDGqGZmzpmErEwpQCfoxqKl4C1KRoqiWldcnyaLmu0eBK5f5z9OYv4CbrUII56tU6aHaVmi0GbuYqrtSrMdaNR2CffZ1NC1bcboZK9W4aW5kkMRP(YCsySFQY13Cbfc5QnxW5QjxFYvhie4N7bTiuj5bJ9tLhnVKgQG2XM4aW5kkMRP(YCsySFQY13Cbfc5QnxW5AWsMaIDoxT3igYmhjFRGsV6EeI3)Eei9c6BenMUJqVi9gzSVXZns9KZzLm4SIUrSQFQA7gvuOiLat3r5co33kO0Z)2JKpwI2uUcNlIXsUGZvtUAYvhie4mt2dJxKN1JkxHZfe5coxn5Qdec8YGqdgqjdfnXgzErEwpQCfoxqKROyU(KRoqiWldcnyaLmu0eBK5aW5QnxrXC9jxDGqGZmzpmoaCUII5AQVmNeg7NQC9nxqHqUAZfCUAY1NC1bcb(5EqlcvsEWy)u5rZlPHkODSjoaCUII5AQVmNeg7NQC9nxqHqUAZfCUgSKjGyNZv7nIHmZrY3kO0RUhH49VhD8xqFJOX0De6fP3iw1pvTDJmyjtaXoFJm2345gfWfJK4GCShOO7FpsOVG(grJP7i0lsVrSQFQA7gPdecCMj7HXbGVrg7B8CJkdcnyaLmu0eBKV)9ier4c6BenMUJqVi9gXQ(PQTBKMC1KRoqiWjMRHvKuHDwXlYZ6rLRW5Iic5kkMRoqiWjMRHvK0bmwXlYZ6rLRW5Iic5QnxW5YWyhk2)WzMShgVipRhvUcNlOqixT5kkMldJDOy)dNzYEy8ImuKVrg7B8CJo3dArOsfCx9RU)9ier8c6BenMUJqVi9gXQ(PQTBKMC1KRoqiWp3dArOsYdg7NkpAEjnubTJnXbGZvumxFYLHHqJnp)mYvBtUAZvumxggcn288PHk4LbJYvumxiw1MUJ4TsAykxrXC1bcbUUdJrDaQNdaNl4C1bcbUUdJrDaQNxKN1JkxFZ9qeYnMC1K7XYfKZLHhuG(5WfXAfjnxdD8O550y6ocnxT5QnxW56tU6aHaNzYEyCa4CbNRMC9jxggcn288PHk4LbJYvumxgg7qX(hodpqWNj5lGKk4U6xXbGZvum3EEQGXo7juzOHk4Lf5z9OY13CzySdf7F4m8abFMKVasQG7QFfVipRhvUXKBSKROyU98ubJD2tOYqdvWllYZ6rLlsKlIhpc56BUhIqUXKRMCpwUGCUm8Gc0phUiwRiP5AOJhnpNgt3rO5QnxT3iJ9nEUrmYrQVnN0Cn0XJM)(3Jq8WlOVr0y6oc9I0BeR6NQ2UrAYvtU6aHa)CpOfHkjpySFQ8O5L0qf0o2ehaoxrXC9jxggcn288ZixTn5QnxrXCzyi0yZZNgQGxgmkxrXCHyvB6oI3kPHPCffZvhie46omg1bOEoaCUGZvhie46omg1bOEErEwpQC9nxqHqUXKRMCpwUGCUm8Gc0phUiwRiP5AOJhnpNgt3rO5QnxT5coxFYvhie4mt2dJdaNl4C1KRp5YWqOXMNpnubVmyuUII5YWyhk2)Wz4bc(mjFbKub3v)koaCUII52Ztfm2zpHkdnubVSipRhvU(MldJDOy)dNHhi4ZK8fqsfCx9R4f5z9OYnMCJLCffZTNNkySZEcvgAOcEzrEwpQCrICr84rixFZfuiKBm5Qj3JLliNldpOa9ZHlI1ksAUg64rZZPX0DeAUAZv7nYyFJNBupmRg7B8C)7ricQlOVr0y6oc9I0Beg(gPO)gzSVXZncIvTP7OBeeZbq3in56tUmm2HI9pCMj7HXlYqroxrXC9jxiw1MUJ4m8abFMKOKc5HLl4Czyi0yZZNgQGxgmkxT3iiwjhZJUrkdcjd4sYmzpS7FpcXJDb9nIgt3rOxKEJyv)u12nIyUgwr8EK2GCUGZ1GLmbe7CUGZvtUO4NBOg83qiPYVvEsuZZGs8VzN7bAUII56tUmmeAS55dXkSdxO5QnxW5cXQ20DexzqizaxsMj7HDJm2345gfakKL4GKCadD)7ricIlOVr0y6oc9I0BeR6NQ2UrmmeAS55tdvWldgLl4CHyvB6oIZWde8zsIskKhwUGZ1uFzojm2pv5kC8Cpgc5coxgg7qX(hodpqWNj5lGKk4U6xXlYZ6rLRV5cLHY9mHKliNlJAxUAY1uFzojm2pv5EAUGcHC1EJm2345gPERuafu6(3JqmwUG(grJP7i0lsVrSQFQA7gPjxDGqGtmxdRiPdySIdaNROyUAYLjWkOKk345EyUGZTiMaRGsYV9OC9nxqKR2CffZLjWkOKk345cQC1Ml4CnyjtaXoNl4CHyvB6oIRmiKmGljZK9WUrg7B8CJgYV0dJN7Fpcrq6f03iAmDhHEr6nIv9tvB3in5QdecCI5AyfjDaJvCa4CbNRp5YWqOXMNFg5QTjxrXC1KRoqiWp3dArOsYdg7NkpAEjnubTJnXbGZfCUmmeAS55NrUABYvBUII5QjxMaRGsQCJN7H5co3IycSckj)2JY13CbrUAZvumxMaRGsQCJNlOYvumxDGqGZmzpmoaCUAZfCUgSKjGyNZfCUqSQnDhXvgesgWLKzYEy3iJ9nEUrcmxq6HXZ9VhH4XFb9nIgt3rOxKEJyv)u12nstU6aHaNyUgwrshWyfhaoxW56tUmmeAS55NrUABYvumxn5Qdec8Z9GweQK8GX(PYJMxsdvq7ytCa4CbNlddHgBE(zKR2MC1MROyUAYLjWkOKk345EyUGZTiMaRGsYV9OC9nxqKR2CffZLjWkOKk345cQCffZvhie4mt2dJdaNR2CbNRblzci25CbNleRAt3rCLbHKbCjzMSh2nYyFJNBuaW5KEy8C)7rik0xqFJm2345g53QQXLehKKdyOBenMUJqVi9(3JoeHlOVr0y6oc9I0BeR6NQ2UreZ1WkI3J0bmwLROyUeZ1WkIRWoRKdjKpxrXCjMRHve3gKLdjKpxrXC1bcbUFRQgxsCqsoGH4aW5coxDGqGtmxdRiPdySIdaNROyUAYvhie4mt2dJxKN1JkxFZ1yFJhU)YEbCsied4j53EuUGZvhie4mt2dJdaNR2BKX(gp3i1BvOl6(3JoeXlOVrg7B8CJ8x2l4grJP7i0lsV)9Odp8c6BenMUJqVi9gzSVXZnQagPX(gpsxR(BKRvVCmp6gfmN7fua3)(3idtxqFpcXlOVr0y6oc9I0Beg(gPO)gzSVXZncIvTP7OBeeZbq3in5Qdec8V9i)4AKOfzE69GsfVipRhvU(Mlugk3ZesUXKlcCeZvumxDGqG)Th5hxJeTiZtVhuQ4f5z9OY13Cn234HRERcDrCsied4j53EuUXKlcCeZfCUAYLyUgwr8EKoGXQCffZLyUgwrCf2zLCiH85kkMlXCnSI42GSCiH85QnxT5coxDGqG)Th5hxJeTiZtVhuQ4aW5co3cyOaUGs8V9i)4AKOfzE69GsfNqYanmmHEJGyLCmp6gHwK5j93oNmyoNehc3)E0HxqFJOX0De6fP3iw1pvTDJ0bcbU6TkyohVOqrkbMUJYfCUAYvbtoN8Tck9kU6TkyoxU(MlOYvumxFYTagkGlOe)BpYpUgjArMNEpOuXjKmqddtO5QnxW5QjxFYTagkGlOe3HmZktjdoI(EGkH6ApyfXjKmqddtO5kkM73EuUirUhde5kCU6aHax9wfmNJxKN1Jk3yY9WC1EJm2345gPERcMZD)7rG6c6BenMUJqVi9gXQ(PQTBubmuaxqj(3EKFCns0Imp9EqPItizGggMqZfCUkyY5KVvqPxXvVvbZ5Yv445cQCbNRMC9jxDGqG)Th5hxJeTiZtVhuQ4aW5coxDGqGRERcMZXlkuKsGP7OCffZvtUqSQnDhXrlY8K(BNtgmNtIdHCbNRMC1bcbU6TkyohVipRhvU(MlOYvumxfm5CY3kO0R4Q3QG5C5kCUhMl4CFZrZZvp5CwjrRo8CAmDhHMl4C1bcbU6TkyohVipRhvU(MliYvBUAZv7nYyFJNBK6Tkyo39VhDSlOVr0y6oc9I0Beg(gPO)gzSVXZncIvTP7OBeeZbq3it9L5KWy)uLRW5E8iKlskxn5Iic5cY5Qdec8V9i)4AKOfzE69Gsfx9g7CUAZfjLRMC1bcbU6TkyohVipRhvUGCUGk3tZvbtoNuGPEkxT5IKYvtUO4NhakKL4GKCadXlYZ6rLliNliYvBUGZvhie4Q3QG5CCa4BeeRKJ5r3i1BvWCoPF88YG5CsCiC)7rG4c6BenMUJqVi9gXQ(PQTBeeRAt3rC0ImpP)25KbZ5K4qixW5cXQ20Dex9wfmNt6hpVmyoNehc3iJ9nEUrQ3kfqbLU)9Oy5c6BenMUJqVi9gzSVXZnsbmHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4XYfjLRcMCo5Bfu6v5gtUf5z9OYfCUgSKjGyNZfCUeZ1WkI3J0gKVrmKzos(wbLE19ieV)9iq6f03iAmDhHEr6nYyFJNBKHAWFdHKk)w5DJyv)u12nYNC)MDUhO5coxFY1yFJhUHAWFdHKk)w5jrnpdkX7rgCnubFUII5IIFUHAWFdHKk)w5jrnpdkXvVXoNRV5cQCbNlk(5gQb)nesQ8BLNe18mOeVipRhvU(MlOUrmKzos(wbLE19ieV)9OJ)c6BenMUJqVi9gzSVXZnYdJNqx0nIv9tvB3OIcfPey6okxW5(wbLE(3EK8Xs0MYv4C1KlIhl3yYvtUkyY5KVvqPxXvVvHUOCb5CrKdIC1MR2Cpnxfm5CY3kO0RYnMClYZ6rLl4C1KRMCzySdf7F4mt2dJxKHICUII5QGjNt(wbLEfx9wf6IY13CbvUII5QjxI5AyfX7rQWoRYvumxI5AyfX7rQJFb5kkMlXCnSI49iDaJv5coxFY9nhnpxHbCsCq(cizaxK650y6ocnxrXC1bcboC1E4cTnN0kMnntcd4uwXHyoakxHJN7HGaHC1Ml4C1KRcMCo5Bfu6vC1BvOlkxFZfreYfKZvtUiMBm5(MJMN)(7r6HXJItJP7i0C1MR2CbNRP(YCsySFQYv4Cbbc5IKYvhie4Q3QG5C8I8SEu5cY5gl5QnxW56tU6aHa)CpOfHkjpySFQ8O5L0qf0o2ehaoxW5AWsMaIDoxT3igYmhjFRGsV6EeI3)EKqFb9nIgt3rOxKEJyv)u12nstUqSQnDhXz4bc(mjrjfYdlxW52Ztfm2zpHkdnubVSipRhvUcNlIGcHCbNRp5YWyhk2)WzMShgVidf5CffZvhie4mt2dJdaNR2CbNRP(YCsySFQY13Cbbc5coxn5QdecCI5AyfjDaJv8I8SEu5kCUXsUII5QdecCI5AyfjvyNv8I8SEu5kCUhlxT5kkMBOHk4Lf5z9OY13CreHBKX(gp3igEGGptYxajvWD1V6(3JqeHlOVr0y6oc9I0BeR6NQ2UrgSKjGyNVrg7B8CJc4IrsCqo2du09VhHiIxqFJOX0De6fP3iw1pvTDJ0bcboZK9W4aW3iJ9nEUrLbHgmGsgkAInY3)EeIhEb9nIgt3rOxKEJyv)u12nstU6aHax9wfmNJdaNROyUM6lZjHX(PkxHZfeiKR2CbNRp5QdecCf2P(MrCa4CbNRp5QdecCMj7HXbGZfCUAY1NCzyi0yZZNgQGxgmkxrXCzySdf7F4m8abFMKVasQG7QFfhaoxrXC75Pcg7SNqLHgQGxwKN1JkxFZLHXouS)HZWde8zs(ciPcUR(v8I8SEu5gtUXsUII52Ztfm2zpHkdnubVSipRhvUirUiE8iKRV5Eic5gtUAY9y5cY5YWdkq)C4IyTIKMRHoE08CAmDhHMR2C1EJm2345gXihP(2CsZ1qhpA(7FpcrqDb9nIgt3rOxKEJyv)u12nstU6aHax9wfmNJdaNROyUM6lZjHX(PkxHZfeiKR2CbNRp5QdecCf2P(MrCa4CbNRp5QdecCMj7HXbGZfCUAY1NCzyi0yZZNgQGxgmkxrXCzySdf7F4m8abFMKVasQG7QFfhaoxrXC75Pcg7SNqLHgQGxwKN1JkxFZLHXouS)HZWde8zs(ciPcUR(v8I8SEu5gtUXsUII52Ztfm2zpHkdnubVSipRhvUirUiE8iKRV5ckeYnMC1K7XYfKZLHhuG(5WfXAfjnxdD8O550y6ocnxT5Q9gzSVXZnQhMvJ9nEU)9iep2f03iAmDhHEr6nIv9tvB3OEEQGXo7juzOHk4Lf5z9OY13Cree5kkMRMC1bcboC1E4cTnN0kMnntcd4uwXHyoakxFZ9qqGqUII5QdecC4Q9WfABoPvmBAMegWPSIdXCauUchp3dbbc5QnxW5QdecC1BvWCooaCUGZLHXouS)HZmzpmErEwpQCfoxqGWnYyFJNB05EqlcvQG7QF19VhHiiUG(grJP7i0lsVrg7B8CJup5CwjdoROBeR6NQ2UrffksjW0DuUGZ9Bps(yjAt5kCUicICbNRcMCo5Bfu6vC1BvOlkxFZ9y5coxdwYeqSZ5coxn5QdecCMj7HXlYZ6rLRW5Iic5kkMRp5QdecCMj7HXbGZv7nIHmZrY3kO0RUhH49VhHySCb9nIgt3rOxKEJyv)u12nIyUgwr8EK2GCUGZ1GLmbe7CUGZvhie4Wv7Hl02CsRy20mjmGtzfhI5aOC9n3dbbc5coxn5IIFUHAWFdHKk)w5jrnpdkX)MDUhO5kkMRp5YWqOXMNpeRWoCHMROyUkyY5KVvqPxLRW5EyUAVrg7B8CJcafYsCqsoGHU)9iebPxqFJOX0De6fP3iw1pvTDJ0bcboEOxGsctfJG)gpCa4CbNRMC1bcbU6TkyohVOqrkbMUJYvumxt9L5KWy)uLRW5k0iKR2BKX(gp3i1BvWCU7FpcXJ)c6BenMUJqVi9gXQ(PQTBeddHgBE(0qf8YGr5coxn5cXQ20DeNHhi4ZKeLuipSCffZLHXouS)HZmzpmoaCUII5QdecCMj7HXbGZvBUGZLHXouS)HZWde8zs(ciPcUR(v8I8SEu56BUqzOCpti5cY5YO2LRMCn1xMtcJ9tvUNMliqixT5coxDGqGRERcMZXlYZ6rLRV5ESBKX(gp3i1BvWCU7FpcrH(c6BenMUJqVi9gXQ(PQTBeddHgBE(0qf8YGr5coxn5cXQ20DeNHhi4ZKeLuipSCffZLHXouS)HZmzpmoaCUII5QdecCMj7HXbGZvBUGZLHXouS)HZWde8zs(ciPcUR(v8I8SEu56BUqzOCpti5cY5YO2LRMCn1xMtcJ9tvUNMlOqixT5coxDGqGRERcMZXbGZfCUeZ1WkI3J0gKVrg7B8CJuVvkGckD)7rhIWf03iAmDhHEr6nIv9tvB3iDGqGJh6fOKmhzLesRA8WbGZvumxn56tUQ3Qqxe3GLmbe7CUII5QjxDGqGZmzpmErEwpQC9nxqKl4C1bcboZK9W4aW5kkMRMC1bcbEzqObdOKHIMyJmVipRhvU(Mlugk3ZesUGCUmQD5Qjxt9L5KWy)uL7P5ckeYvBUGZvhie4LbHgmGsgkAInYCa4C1MR2CbNleRAt3rC1BvWCoPF88YG5CsCiKl4CvWKZjFRGsVIRERcMZLRV5cQC1Ml4C1KRp5wadfWfuI)Th5hxJeTiZtVhuQ4esgOHHj0CffZvbtoN8Tck9kU6TkyoxU(MlOYv7nYyFJNBK6TsbuqP7Fp6qeVG(grJP7i0lsVrSQFQA7gPjxI5AyfX7rAdY5coxgg7qX(hoZK9W4f5z9OYv4Cbbc5kkMRMCzcSckPYnEUhMl4ClIjWkOK8BpkxFZfe5QnxrXCzcSckPYnEUGkxT5coxdwYeqSZ3iJ9nEUrd5x6HXZ9VhD4HxqFJOX0De6fP3iw1pvTDJ0KlXCnSI49iTb5CbNldJDOy)dNzYEy8I8SEu5kCUGaHCffZvtUmbwbLu5gp3dZfCUfXeyfus(ThLRV5cIC1MROyUmbwbLu5gpxqLR2CbNRblzci25BKX(gp3ibMli9W45(3JoeuxqFJOX0De6fP3iw1pvTDJ0KlXCnSI49iTb5CbNldJDOy)dNzYEy8I8SEu5kCUGaHCffZvtUmbwbLu5gp3dZfCUfXeyfus(ThLRV5cIC1MROyUmbwbLu5gpxqLR2CbNRblzci25BKX(gp3OaGZj9W45(3Jo8yxqFJm2345g53QQXLehKKdyOBenMUJqVi9(3JoeexqFJOX0De6fP3im8nsr)nYyFJNBeeRAt3r3iiMdGUrkyY5KVvqPxXvVvHUOCfo3JLBm5gCyCLRMC9m1tfYsiMdGY90CpeHC1MBm5gCyCLRMC1bcbU6Tsbuqjj5bJ9tLhnpx9g7CUNM7XYv7ncIvYX8OBK6Tk0fj7rQWoRU)9OdJLlOVr0y6oc9I0BeR6NQ2UreZ1WkI7agRKdjKpxrXCjMRHve3gKLdjKpxW5cXQ20DeVvsMJmiuUII5QdecCI5AyfjvyNv8I8SEu56BUg7B8WvVvHUiojeIb8K8BpkxW5QdecCI5AyfjvyNvCa4CffZLyUgwr8EKkSZQCbNRp5cXQ20Dex9wf6IK9ivyNv5kkMRoqiWzMShgVipRhvU(MRX(gpC1BvOlItcHyapj)2JYfCU(KleRAt3r8wjzoYGq5coxDGqGZmzpmErEwpQC9nxsied4j53EuUGZvhie4mt2dJdaNROyU6aHaVmi0GbuYqrtSrMdaNl4CvWKZjfyQNYv4CrGhl5coxn5QGjNt(wbLEvU(gpxqLROyU(K7BoAEUcd4K4G8fqYaUi1ZPX0DeAUAZvumxFYfIvTP7iERKmhzqOCbNRoqiWzMShgVipRhvUcNljeIb8K8Bp6gzSVXZnYFzVG7Fp6qq6f03iJ9nEUrQ3Qqx0nIgt3rOxKE)7rhE8xqFJOX0De6fP3iJ9nEUrfWin234r6A1FJCT6LJ5r3OG5CVGc4(3)gfmN7fuaxqFpcXlOVr0y6oc9I0BeR6NQ2Ur(KBbmuaxqjUU5SHrsCqAoN8f0dufNqYanmmHEJm2345gPERuafu6(3Jo8c6BenMUJqVi9gzSVXZnsbmHUOBeR6NQ2UrO4N7HXtOlIxKN1JkxHZTipRh1nIHmZrY3kO0RUhH49VhbQlOVrg7B8CJ8W4j0fDJOX0De6fP3)(3i1Fb99ieVG(grJP7i0lsVrg7B8CJmud(BiKu53kVBeR6NQ2Ur(Klk(5gQb)nesQ8BLNe18mOe)B25EGMl4C9jxJ9nE4gQb)nesQ8BLNe18mOeVhzW1qf85coxn56tUO4NBOg83qiPYVvEsbK54FZo3d0CffZff)Cd1G)gcjv(TYtkGmhVipRhvUcNliYvBUII5IIFUHAWFdHKk)w5jrnpdkXvVXoNRV5cQCbNlk(5gQb)nesQ8BLNe18mOeVipRhvU(MlOYfCUO4NBOg83qiPYVvEsuZZGs8VzN7b6nIHmZrY3kO0RUhH49VhD4f03iAmDhHEr6nIv9tvB3in5cXQ20DeNHhi4ZKeLuipSCbNBppvWyN9eQm0qf8YI8SEu5kCUickeYfCU(KldJDOy)dNzYEy8ImuKZvumxDGqGZmzpmoaCUAZfCUM6lZjHX(PkxFZfeiKl4C1KRoqiWjMRHvK0bmwXlYZ6rLRW5Iic5kkMRoqiWjMRHvKuHDwXlYZ6rLRW5Iic5QnxrXCdnubVSipRhvU(MlIiCJm2345gXWde8zs(ciPcUR(v3)EeOUG(grJP7i0lsVry4BKI(BKX(gp3iiw1MUJUrqmhaDJ0KRoqiWzMShgVipRhvUcNliYfCUAYvhie4LbHgmGsgkAInY8I8SEu5kCUGixrXC9jxDGqGxgeAWakzOOj2iZbGZvBUII56tU6aHaNzYEyCa4CffZ1uFzojm2pv56BUGcHC1Ml4C1KRp5Qdec8Z9GweQK8GX(PYJMxsdvq7ytCa4CffZ1uFzojm2pv56BUGcHC1Ml4C1KRoqiWjMRHvKuHDwXlYZ6rLRW5cLHY9mHKROyU6aHaNyUgwrshWyfVipRhvUcNlugk3ZesUAVrqSsoMhDJqXVSiKmqxKhnV6(3Jo2f03iAmDhHEr6nYyFJNBKhgpHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4H5coxn5AWsMaIDoxW5cXQ20Dehf)YIqYaDrE08QC1EJyiZCK8Tck9Q7riE)7rG4c6BenMUJqVi9gzSVXZnsbmHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4H5coxn5AWsMaIDoxW5cXQ20Dehf)YIqYaDrE08QC1EJyiZCK8Tck9Q7riE)7rXYf03iAmDhHEr6nYyFJNBK6jNZkzWzfDJyv)u12nQOqrkbMUJYfCUVvqPN)ThjFSeTPCfoxeJLCbNRMCnyjtaXoNl4CHyvB6oIJIFzrizGUipAEvUAVrmKzos(wbLE19ieV)9iq6f03iAmDhHEr6nIv9tvB3idwYeqSZ3iJ9nEUrbCXijoih7bk6(3Jo(lOVr0y6oc9I0BeR6NQ2Ur6aHaNzYEyCa4BKX(gp3OYGqdgqjdfnXg57FpsOVG(grJP7i0lsVrSQFQA7gPjxn5QdecCI5AyfjvyNv8I8SEu5kCUiIqUII5QdecCI5AyfjDaJv8I8SEu5kCUiIqUAZfCUmm2HI9pCMj7HXlYZ6rLRW5ckeYfCUAYvhie4Wv7Hl02CsRy20mjmGtzfhI5aOC9n3dpgc5kkMRp5wadfWfuIdxThUqBZjTIztZKWaoLvCcjd0WWeAUAZvBUII5QdecC4Q9WfABoPvmBAMegWPSIdXCauUchp3dbPiKROyUmm2HI9pCMj7HXlYqroxW5Qjxt9L5KWy)uLRW5k0iKROyUqSQnDhXBL0WuUAVrg7B8CJo3dArOsfCx9RU)9ier4c6BenMUJqVi9gXQ(PQTBKMCn1xMtcJ9tvUcNRqJqUGZvtU6aHa)CpOfHkjpySFQ8O5L0qf0o2ehaoxrXC9jxggcn288ZixTn5QnxrXCzyi0yZZNgQGxgmkxrXCHyvB6oI3kPHPCffZvhie46omg1bOEoaCUGZvhie46omg1bOEErEwpQC9n3dri3yYvtUAYvOZfKZTagkGlOehUApCH2MtAfZMMjHbCkR4esgOHHj0C1MBm5Qj3JLliNldpOa9ZHlI1ksAUg64rZZPX0DeAUAZvBUAZfCU(KRoqiWzMShghaoxW5QjxFYLHHqJnpFAOcEzWOCffZLHXouS)HZWde8zs(ciPcUR(vCa4CffZTNNkySZEcvgAOcEzrEwpQC9nxgg7qX(hodpqWNj5lGKk4U6xXlYZ6rLBm5gl5kkMBppvWyN9eQm0qf8YI8SEu5Ie5I4XJqU(M7HiKBm5Qj3JLliNldpOa9ZHlI1ksAUg64rZZPX0DeAUAZv7nYyFJNBeJCK6BZjnxdD8O5V)9ier8c6BenMUJqVi9gXQ(PQTBKMCn1xMtcJ9tvUcNRqJqUGZvtU6aHa)CpOfHkjpySFQ8O5L0qf0o2ehaoxrXC9jxggcn288ZixTn5QnxrXCzyi0yZZNgQGxgmkxrXCHyvB6oI3kPHPCffZvhie46omg1bOEoaCUGZvhie46omg1bOEErEwpQC9nxqHqUXKRMC1KRqNliNBbmuaxqjoC1E4cTnN0kMnntcd4uwXjKmqddtO5Qn3yYvtUhlxqoxgEqb6NdxeRvK0Cn0XJMNtJP7i0C1MR2C1Ml4C9jxDGqGZmzpmoaCUGZvtU(KlddHgBE(0qf8YGr5kkMldJDOy)dNHhi4ZK8fqsfCx9R4aW5kkMBppvWyN9eQm0qf8YI8SEu56BUmm2HI9pCgEGGptYxajvWD1VIxKN1Jk3yYnwYvum3EEQGXo7juzOHk4Lf5z9OYfjYfXJhHC9nxqHqUXKRMCpwUGCUm8Gc0phUiwRiP5AOJhnpNgt3rO5QnxT3iJ9nEUr9WSASVXZ9VhH4HxqFJOX0De6fP3im8nsr)nYyFJNBeeRAt3r3iiMdGUrAY1NCzySdf7F4mt2dJxKHICUII56tUqSQnDhXz4bc(mjrjfYdlxW5YWqOXMNpnubVmyuUAVrqSsoMhDJugesgWLKzYEy3)EeIG6c6BenMUJqVi9gXQ(PQTBeXCnSI49iTb5CbNRblzci25CbNRoqiWHR2dxOT5KwXSPzsyaNYkoeZbq56BUhEmeYfCUAYff)Cd1G)gcjv(TYtIAEguI)n7CpqZvumxFYLHHqJnpFiwHD4cnxT5coxiw1MUJ4kdcjd4sYmzpSBKX(gp3OaqHSehKKdyO7FpcXJDb9nIgt3rOxKEJyv)u12nshie44HEbkjmvmc(B8WbGZfCU6aHax9wfmNJxuOiLat3r3iJ9nEUrQ3QG5C3)EeIG4c6BenMUJqVi9gXQ(PQTBKoqiWvVvoCHYlYZ6rLRV5cICbNRMC1bcboXCnSIKkSZkErEwpQCfoxqKROyU6aHaNyUgwrshWyfVipRhvUcNliYvBUGZ1uFzojm2pv5kCUcnc3iJ9nEUrmByKtQdec3iDGqqoMhDJuVvoCHE)7riglxqFJOX0De6fP3iw1pvTDJyyi0yZZNgQGxgmkxW5cXQ20DeNHhi4ZKeLuipSCbNldJDOy)dNHhi4ZK8fqsfCx9R4f5z9OY13CHYq5EMqYfKZLrTlxn5AQVmNeg7NQCpnxqHqUAVrg7B8CJuVvkGckD)7ricsVG(grJP7i0lsVrSQFQA7g9MJMNREY5SsIwD450y6ocnxW56tUV5O55Q3khUq50y6ocnxW5QdecC1BvWCoErHIucmDhLl4C1KRoqiWjMRHvK0bmwXlYZ6rLRW5gl5coxI5AyfX7r6agRYfCU6aHahUApCH2MtAfZMMjHbCkR4qmhaLRV5EiiqixrXC1bcboC1E4cTnN0kMnntcd4uwXHyoakxHJN7HGaHCbNRP(YCsySFQYv4CfAeYvumxu8Znud(BiKu53kpjQ5zqjErEwpQCfo3JpxrXCn234HBOg83qiPYVvEsuZZGs8EKbxdvWNR2CbNRp5YWyhk2)WzMShgVidf5BKX(gp3i1BvWCU7FpcXJ)c6BenMUJqVi9gXQ(PQTBKoqiWXd9cusMJSscPvnE4aW5kkMRoqiWp3dArOsYdg7NkpAEjnubTJnXbGZvumxDGqGZmzpmoaCUGZvtU6aHaVmi0GbuYqrtSrMxKN1JkxFZfkdL7zcjxqoxg1UC1KRP(YCsySFQY90Cbfc5QnxW5Qdec8YGqdgqjdfnXgzoaCUII56tU6aHaVmi0GbuYqrtSrMdaNl4C9jxgg7qX(hEzqObdOKHIMyJmVidf5CffZ1NCzyi0yZZHqZla5kxT5kkMRP(YCsySFQYv4CfAeYfCUeZ1WkI3J0gKVrg7B8CJuVvkGckD)7rik0xqFJOX0De6fP3iw1pvTDJEZrZZvVvoCHYPX0DeAUGZvtU6aHax9w5WfkhaoxrXCn1xMtcJ9tvUcNRqJqUAZfCU6aHax9w5Wfkx9g7CU(MlOYfCUAYvhie4eZ1WksQWoR4aW5kkMRoqiWjMRHvK0bmwXbGZvBUGZvhie4Wv7Hl02CsRy20mjmGtzfhI5aOC9n3dbPiKl4C1KldJDOy)dNzYEy8I8SEu5kCUiIqUII56tUqSQnDhXz4bc(mjrjfYdlxW5YWqOXMNpnubVmyuUAVrg7B8CJuVvkGckD)7rhIWf03iAmDhHEr6nIv9tvB3in5QdecC4Q9WfABoPvmBAMegWPSIdXCauU(M7HGueYvumxDGqGdxThUqBZjTIztZKWaoLvCiMdGY13CpeeiKl4CFZrZZvp5CwjrRo8CAmDhHMR2CbNRoqiWjMRHvKuHDwXlYZ6rLRW5csZfCUeZ1WkI3JuHDwLl4C9jxDGqGJh6fOKWuXi4VXdhaoxW56tUV5O55Q3khUq50y6ocnxW5YWyhk2)WzMShgVipRhvUcNlinxW5Qjxgg7qX(h(5EqlcvQG7QFfVipRhvUcNlinxrXC9jxggcn288ZixTn5Q9gzSVXZns9wPakO09VhDiIxqFJOX0De6fP3iw1pvTDJ0KRoqiWjMRHvK0bmwXbGZvumxn5YeyfusLB8CpmxW5wetGvqj53EuU(MliYvBUII5YeyfusLB8CbvUAZfCUgSKjGyNZfCUqSQnDhXvgesgWLKzYEy3iJ9nEUrd5x6HXZ9VhD4HxqFJOX0De6fP3iw1pvTDJ0KRoqiWjMRHvK0bmwXbGZfCU(KlddHgBE(zKR2MCffZvtU6aHa)CpOfHkjpySFQ8O5L0qf0o2ehaoxW5YWqOXMNFg5QTjxT5kkMRMCzcSckPYnEUhMl4ClIjWkOK8BpkxFZfe5QnxrXCzcSckPYnEUGkxrXC1bcboZK9W4aW5QnxW5AWsMaIDoxW5cXQ20DexzqizaxsMj7HDJm2345gjWCbPhgp3)E0HG6c6BenMUJqVi9gXQ(PQTBKMC1bcboXCnSIKoGXkoaCUGZ1NCzyi0yZZpJC12KROyUAYvhie4N7bTiuj5bJ9tLhnVKgQG2XM4aW5coxggcn288ZixTn5QnxrXC1KltGvqjvUXZ9WCbNBrmbwbLKF7r56BUGixT5kkMltGvqjvUXZfu5kkMRoqiWzMShghaoxT5coxdwYeqSZ5coxiw1MUJ4kdcjd4sYmzpSBKX(gp3OaGZj9W45(3Jo8yxqFJm2345g53QQXLehKKdyOBenMUJqVi9(3JoeexqFJOX0De6fP3iw1pvTDJiMRHveVhPdySkxrXCjMRHvexHDwjhsiFUII5smxdRiUnilhsiFUII5QdecC)wvnUK4GKCadXbGZfCU6aHaNyUgwrshWyfhaoxrXC1KRoqiWzMShgVipRhvU(MRX(gpC)L9c4KqigWtYV9OCbNRoqiWzMShghaoxT3iJ9nEUrQ3Qqx09VhDySCb9nYyFJNBK)YEb3iAmDhHEr69VhDii9c6BenMUJqVi9gzSVXZnQagPX(gpsxR(BKRvVCmp6gfmN7fua3)(3i4IGTNjqQ(lOVhH4f03iAmDhHEr6nYyFJNBKhgpHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4H5coxn5QjxDGqGZmzpmErEwpQCfoxqKROyU(KRoqiWzMShghaoxrXCn1xMtcJ9tvU(MlOqixT5coxdwYeqSZ5Q9gXqM5i5Bfu6v3Jq8(3Jo8c6BenMUJqVi9gzSVXZnsbmHUOBeR6NQ2UrffksjW0DuUGZ9Tck98V9i5JLOnLRW5I4H5coxn5QjxDGqGZmzpmErEwpQCfoxqKROyU(KRoqiWzMShghaoxrXCn1xMtcJ9tvU(MlOqixT5coxdwYeqSZ5Q9gXqM5i5Bfu6v3Jq8(3Ja1f03iAmDhHEr6nYyFJNBK6jNZkzWzfDJyv)u12nQOqrkbMUJYfCUVvqPN)ThjFSeTPCfoxeJLCbNRMC1KRoqiWzMShgVipRhvUcNliYvumxFYvhie4mt2dJdaNROyUM6lZjHX(PkxFZfuiKR2CbNRblzci25C1EJyiZCK8Tck9Q7riE)7rh7c6BenMUJqVi9gXQ(PQTBKblzci25BKX(gp3OaUyKehKJ9afD)7rG4c6BenMUJqVi9gXQ(PQTBKMCn1xMtcJ9tvUcNRqJqUII5QdecCDhgJ6auphaoxW5QdecCDhgJ6aupVipRhvU(M7HXsUAZfCU(KRoqiWzMShgha(gzSVXZnIros9T5KMRHoE083)EuSCb9nIgt3rOxKEJyv)u12nstUM6lZjHX(PkxHZvOrixrXC1bcbUUdJrDaQNdaNl4C1bcbUUdJrDaQNxKN1JkxFZfuXsUAZfCU(KRoqiWzMShgha(gzSVXZnQhMvJ9nEU)9iq6f03iAmDhHEr6ncdFJu0FJm2345gbXQ20D0ncI5aOBKp5YWyhk2)WzMShgVidf5BeeRKJ5r3iLbHKbCjzMSh29VhD8xqFJOX0De6fP3iw1pvTDJiMRHveVhPniNl4CnyjtaXoNl4CHyvB6oIRmiKmGljZK9WUrg7B8CJcafYsCqsoGHU)9iH(c6BenMUJqVi9gXQ(PQTBKoqiWvVvoCHYlYZ6rLRV5gl5coxn5QdecCI5AyfjvyNvCa4CffZvhie4eZ1Wks6agR4aW5QnxW5AQVmNeg7NQCfoxHgHBKX(gp3iMnmYj1bcHBKoqiihZJUrQ3khUqV)9ier4c6BenMUJqVi9gXQ(PQTBKMC9jxl2u1pXvFr25EGkvVvkEzZ5CffZvhie4mt2dJxKN1JkxFZLecXaEs(ThLROyU(KlCrq4Q3kfqbLYvBUGZvtU6aHaNzYEyCa4CffZ1uFzojm2pv5kCUcnc5coxI5AyfX7rAdY5Q9gzSVXZns9wPakO09VhHiIxqFJOX0De6fP3iw1pvTDJ0KRp5AXMQ(jU6lYo3duP6TsXlBoNROyU6aHaNzYEy8I8SEu56BUKqigWtYV9OCffZ1NCHlccx9wPakOuUAZfCUV5O55Q3khUq50y6ocnxW5QjxDGqGRERC4cLdaNROyUM6lZjHX(PkxHZvOrixT5coxDGqGRERC4cLREJDoxFZfu5coxn5QdecCI5AyfjvyNvCa4CffZvhie4eZ1Wks6agR4aW5QnxW5YWyhk2)WzMShgVipRhvUcNli9gzSVXZns9wPakO09VhH4HxqFJOX0De6fP3iw1pvTDJ0KRp5AXMQ(jU6lYo3duP6TsXlBoNROyU6aHaNzYEy8I8SEu56BUKqigWtYV9OCffZ1NCHlccx9wPakOuUAZfCU6aHaNyUgwrsf2zfVipRhvUcNlinxW5smxdRiEpsf2zvUGZ1NCFZrZZvVvoCHYPX0DeAUGZLHXouS)HZmzpmErEwpQCfoxq6nYyFJNBK6TsbuqP7FpcrqDb9nIgt3rOxKEJyv)u12nstU6aHaNyUgwrshWyfhaoxrXC1KltGvqjvUXZ9WCbNBrmbwbLKF7r56BUGixT5kkMltGvqjvUXZfu5QnxW5AWsMaIDoxW5cXQ20DexzqizaxsMj7HDJm2345gnKFPhgp3)EeIh7c6BenMUJqVi9gXQ(PQTBKMC1bcboXCnSIKoGXkoaCUII5QjxMaRGsQCJN7H5co3IycSckj)2JY13CbrUAZvumxMaRGsQCJNlOYvumxDGqGZmzpmoaCUAZfCUgSKjGyNZfCUqSQnDhXvgesgWLKzYEy3iJ9nEUrcmxq6HXZ9VhHiiUG(grJP7i0lsVrSQFQA7gPjxDGqGtmxdRiPdySIdaNROyUAYLjWkOKk345EyUGZTiMaRGsYV9OC9nxqKR2CffZLjWkOKk345cQCffZvhie4mt2dJdaNR2CbNRblzci25CbNleRAt3rCLbHKbCjzMSh2nYyFJNBuaW5KEy8C)7riglxqFJm2345g53QQXLehKKdyOBenMUJqVi9(3JqeKEb9nIgt3rOxKEJyv)u12nstUwSPQFIR(ISZ9avQERu8YMZ5coxDGqGZmzpmErEwpQCfoxsied4j53EuUGZfUiiC)L9cYvBUII5QjxFY1Inv9tC1xKDUhOs1BLIx2CoxrXC1bcboZK9W4f5z9OY13CjHqmGNKF7r5kkMRp5cxeeU6Tk0fLR2CbNRMCjMRHveVhPdySkxrXCjMRHvexHDwjhsiFUII5smxdRiUnilhsiFUII5QdecC)wvnUK4GKCadXbGZfCU6aHaNyUgwrshWyfhaoxrXC1KRoqiWzMShgVipRhvU(MRX(gpC)L9c4KqigWtYV9OCbNRoqiWzMShghaoxT5QnxrXC1KRfBQ6N4OM)PhOsfWWlBoNRW5EyUGZvhie4eZ1WksQWoR4f5z9OYv4CbrUGZ1NC1bcboQ5F6bQubm8I8SEu5kCUg7B8W9x2lGtcHyapj)2JYv7nYyFJNBK6Tk0fD)7riE8xqFJOX0De6fP3iw1pvTDJEZrZZvp5CwjrRo8CAmDhHMl4C1bcbU6TkyohVOqrkbMUJYfCUHgQGxwKN1JkxHZvhie4Q3QG5CCuGY(gp5coxn56tUeZ1WkI3J0gKZvumxDGqGRERuafussEWy)u5rZZbGZv7nYyFJNBK6Tkyo39VhHOqFb9nYyFJNBK)YEb3iAmDhHEr69VhDicxqFJOX0De6fP3iJ9nEUrfWin234r6A1FJCT6LJ5r3OG5CVGc4(3)(3iiuPA8Cp6qeoebereHy5g53QPhOQB0X1JdhhpsO0rhNfQ5MlOfq52EW46ZnGRCpUrlY807bLQJ7Clcjd0fHMRc7r5Aap2ZEcnxMaBGskEEaiPhk3dfQ5gR4bcvpHMBu7fR5QqEEti5Ie5(4CbjawUOnKw14jxmmv2JRC1CQ2C1GOq0YZdaj9q5IiIc1CJv8aHQNqZnQ9I1CvipVjKCrcKi3hNlibWY1dJc4au5IHPYECLRgKqBUAquiA55bGKEOCr8qHAUXkEGq1tO5g1EXAUkKN3esUibsK7JZfKay56HrbCaQCXWuzpUYvdsOnxnikeT88aqspuUiccHAUXkEGq1tO5g1EXAUkKN3esUirUpoxqcGLlAdPvnEYfdtL94kxnNQnxnikeT88G8GJRhhooEKqPJooluZnxqlGYT9GX1NBax5ECdxed7PB)XDUfHKb6IqZvH9OCnGh7zpHMltGnqjfppaK0dLlieQ5gR4bcvpHMBu7fR5QqEEti5Ie5(4CbjawUOnKw14jxmmv2JRC1CQ2C1COq0YZdYdoUEC444rcLo64Sqn3CbTak32dgxFUbCL7XTHPJ7Clcjd0fHMRc7r5Aap2ZEcnxMaBGskEEaiPhk3dfQ5gR4bcvpHMBu7fR5QqEEti5IeirUpoxqcGLRhgfWbOYfdtL94kxniH2C1GOq0YZdaj9q5EmHAUXkEGq1tO5g1EXAUkKN3esUirUpoxqcGLlAdPvnEYfdtL94kxnNQnxnikeT88aqspuUhVqn3yfpqO6j0CJAVynxfYZBcjxKi3hNlibWYfTH0Qgp5IHPYECLRMt1MRgefIwEEaiPhkxepuOMBSIhiu9eAUrTxSMRc55nHKlsGe5(4CbjawUEyuahGkxmmv2JRC1GeAZvdIcrlppaK0dLlIGsOMBSIhiu9eAUrTxSMRc55nHKlsGe5(4CbjawUEyuahGkxmmv2JRC1GeAZvdIcrlppaK0dLlIhVqn3yfpqO6j0CJAVynxfYZBcjxKi3hNlibWYfTH0Qgp5IHPYECLRMt1MRgefIwEEaiPhkxefAHAUXkEGq1tO5g1EXAUkKN3esUirUpoxqcGLlAdPvnEYfdtL94kxnNQnxnikeT88aqspuUhIGqn3yfpqO6j0CJAVynxfYZBcjxKi3hNlibWYfTH0Qgp5IHPYECLRMt1MRgefIwEEaiPhk3dbHqn3yfpqO6j0CJAVynxfYZBcjxKi3hNlibWYfTH0Qgp5IHPYECLRMt1MRMdfIwEEqEWX1JdhhpsO0rhNfQ5MlOfq52EW46ZnGRCpUv)XDUfHKb6IqZvH9OCnGh7zpHMltGnqjfppaK0dLlIiiuZnwXdeQEcn3O2lwZvH88MqYfjqICFCUGealxpmkGdqLlgMk7XvUAqcT5QbrHOLNhas6HYfrefQ5gR4bcvpHMBu7fR5QqEEti5IeirUpoxqcGLRhgfWbOYfdtL94kxniH2C1GOq0YZdaj9q5IySiuZnwXdeQEcn3O2lwZvH88MqYfjY9X5csaSCrBiTQXtUyyQShx5Q5uT5QbrHOLNhas6HYfXJxOMBSIhiu9eAUrTxSMRc55nHKlsK7JZfKay5I2qAvJNCXWuzpUYvZPAZvdIcrlppip446XHJJhju6OJZc1CZf0cOCBpyC95gWvUh36y7pUZTiKmqxeAUkShLRb8yp7j0CzcSbkP45bGKEOCpuOMBSIhiu9eAUrTxSMRc55nHKlsK7JZfKay5I2qAvJNCXWuzpUYvZPAZvZHcrlppaK0dLlIGqOMBSIhiu9eAUrTxSMRc55nHKlsGe5(4CbjawUEyuahGkxmmv2JRC1GeAZvdIcrlppaK0dLlIhVqn3yfpqO6j0CJAVynxfYZBcjxKi3hNlibWYfTH0Qgp5IHPYECLRMt1MRgqjeT88aqspuUik0c1CJv8aHQNqZnQ9I1CvipVjKCrICFCUGealx0gsRA8KlgMk7XvUAovBUAquiA55b5bcL8GX1tO5E85ASVXtUUw9kEEWnsbtS7riIWH3i4chAhDJekYfPMZggL7XLcOrZdekY9imeYtNQCreXtY9qeoeH8G8aHICJvb2aLuc18aHICrs5ECafLqZnc7SkxKsMhppqOixKuUXQaBGsO5(wbLEzhYLzksL7JZLHmZrY3kO0R45bcf5IKY94i5HHqO5cmdXiLYkKZfIvTP7ivUAAoXpjx4IGivVvkGckLlss4CHlccx9wPakOKwEEGqrUiPCfkRhCLlH2FUpoxAyyGYGs5g9wfmNl3EYnc056VFb5g9KZzvUhxQo85QrOSy0kuUCvcWao0CHlSUP7qoxDkxlxfmXYfd)nE45b5bg7B8O4WfXWE62h3dJNZ9id4YlpWyFJhfhUig2t3(yIFQ)YEbN46HKm04iIqEGX(gpkoCrmSNU9Xe)u)L9coPdXHlcchrU)YEbG9bUii8d5(l7fKhySVXJIdxed7PBFmXpv9wf6IYdm234rXHlIH90TpM4NcXQ20D0jJ5rXz4bc(mjrjfYd7eiMdGIRJvkWbhgxA0eAOcEzrEwpkK0HiOfjq8qe0kCWHXLgnHgQGxwKN1JcjDiiqsAqebq(nhnpVhMvJ9nE40y6ocvlssZXazgEqb6NdxeRvK0Cn0XJMNtJP7iuTArcepEe0MhKhiuKRq5fcXaEcnxccviN73EuUVakxJ94k3wLRbXANP7iEEGX(gpQ4kSZkPozE5bg7B8OIj(PqSQnDhDYyEu8wjnmDceZbqXvWKZjFRGsVIRERcMZjmIG14ZBoAEU6TYHluonMUJqffFZrZZvp5CwjrRo8CAmDhHQvuubtoN8Tck9kU6TkyoNWhMhySVXJkM4NcXQ20D0jJ5rXBLK5idcDceZbqXvWKZjFRGsVIRERcDrcJyEGX(gpQyIFQovkQo3d0t6qCn(WWqOXMNpnubVmyKOOpmm2HI9pCgEGGptYxajvWD1VIdaRfSoqiWzMShghaopWyFJhvmXpfg)nEoPdX1bcboZK9W4aW5bg7B8OIj(Paks2p5PYdm234rft8tfqw9ssPOHrN0H4occ58feiMhySVXJkM4NwaJ0yFJhPRv)jJ5rXnmDI6RM9Xr8KoehIvTP7iERKgMYdm234rft8tlGrASVXJ01Q)KX8O4OfzE69Gs1jQVA2hhXt6q8cyOaUGs8V9i)4AKOfzE69GsfNqYanmmHMhySVXJkM4NwaJ0yFJhPRv)jJ5rX1X2FI6RM9Xr8KoeVagkGlOex3C2WijoinNt(c6bQItizGggMqZdm234rft8tlGrASVXJ01Q)KX8O4Q)Koe3rqiNWGaH8aJ9nEuXe)0cyKg7B8iDT6pzmpkoCrW2ZeivFEqEGX(gpkUHP4qSQnDhDYyEuC0ImpP)25KbZ5K4q4eiMdGIRrhie4F7r(X1irlY807bLkErEwpkFHYq5EMqIbboIII6aHa)BpYpUgjArMNEpOuXlYZ6r5RX(gpC1BvOlItcHyapj)2JIbboIG1qmxdRiEpshWyLOiXCnSI4kSZk5qc5ffjMRHve3gKLdjKxRwW6aHa)BpYpUgjArMNEpOuXbGbxadfWfuI)Th5hxJeTiZtVhuQ4esgOHHj08aJ9nEuCdtXe)u1BvWCUt6qCDGqGRERcMZXlkuKsGP7iWAuWKZjFRGsVIRERcMZ5lOef9PagkGlOe)BpYpUgjArMNEpOuXjKmqddtOAbRXNcyOaUGsChYmRmLm4i67bQeQR9GveNqYanmmHkk(ThHeiXXaHW6aHax9wfmNJxKN1JkMd1MhySVXJIBykM4NQERcMZDshIxadfWfuI)Th5hxJeTiZtVhuQ4esgOHHjuWkyY5KVvqPxXvVvbZ5eooOaRXhDGqG)Th5hxJeTiZtVhuQ4aWG1bcbU6TkyohVOqrkbMUJef1aXQ20DehTiZt6VDozWCojoeaRrhie4Q3QG5C8I8SEu(ckrrfm5CY3kO0R4Q3QG5CcFi43C08C1toNvs0QdpNgt3rOG1bcbU6TkyohVipRhLVGqRwT5bg7B8O4gMIj(PqSQnDhDYyEuC1BvWCoPF88YG5CsCiCceZbqXn1xMtcJ9tLWhpcijniIaiRdec8V9i)4AKOfzE69Gsfx9g7SwKKgDGqGRERcMZXlYZ6rbYGcjuWKZjfyQN0IK0GIFEaOqwIdsYbmeVipRhfidcTG1bcbU6TkyohhaopWyFJhf3WumXpv9wPakO0jDioeRAt3rC0ImpP)25KbZ5K4qameRAt3rC1BvWCoPF88YG5CsCiKhySVXJIBykM4NQaMqx0jmKzos(wbLEvCepPdXlkuKsGP7iWVvqPN)ThjFSeTjHr8yijfm5CY3kO0RIPipRhfydwYeqSZGjMRHveVhPniNhySVXJIBykM4NAOg83qiPYVvENWqM5i5Bfu6vXr8Koe3NVzN7bkyFm234HBOg83qiPYVvEsuZZGs8EKbxdvWlkIIFUHAWFdHKk)w5jrnpdkXvVXo7lOaJIFUHAWFdHKk)w5jrnpdkXlYZ6r5lOYdm234rXnmft8t9W4j0fDcdzMJKVvqPxfhXt6q8IcfPey6oc8Bfu65F7rYhlrBsyniESy0OGjNt(wbLEfx9wf6Iaze5GqRwKqbtoN8Tck9QykYZ6rbwJggg7qX(hoZK9W4fzOilkQGjNt(wbLEfx9wf6I8fuIIAiMRHveVhPc7SsuKyUgwr8EK64xGOiXCnSI49iDaJvG95nhnpxHbCsCq(cizaxK650y6ocvuuhie4Wv7Hl02CsRy20mjmGtzfhI5aiHJFiiqqlynkyY5KVvqPxXvVvHUiFrebqwdIX8MJMN)(7r6HXJItJP7iuTAbBQVmNeg7NkHbbcijDGqGRERcMZXlYZ6rbYXIwW(Odec8Z9GweQK8GX(PYJMxsdvq7ytCayWgSKjGyN1MhySVXJIBykM4NYWde8zs(ciPcUR(vN0H4AGyvB6oIZWde8zsIskKhg4EEQGXo7juzOHk4Lf5z9OegrqHayFyySdf7F4mt2dJxKHISOOoqiWzMShghawlyt9L5KWy)u5liqaSgDGqGtmxdRiPdySIxKN1Js4yruuhie4eZ1WksQWoR4f5z9Oe(yAffdnubVSipRhLViIqEGX(gpkUHPyIFAaxmsIdYXEGIoPdXnyjtaXoNhySVXJIBykM4NwgeAWakzOOj2iFshIRdecCMj7HXbGZdm234rXnmft8tzKJuFBoP5AOJhn)jDiUgDGqGRERcMZXbGffn1xMtcJ9tLWGabTG9rhie4kSt9nJ4aWG9rhie4mt2dJdadwJpmmeAS55tdvWldgjkYWyhk2)Wz4bc(mjFbKub3v)koaSOyppvWyN9eQm0qf8YI8SEu(YWyhk2)Wz4bc(mjFbKub3v)kErEwpQyIfrXEEQGXo7juzOHk4Lf5z9OqcKaXJhbFpeHy0CmqMHhuG(5WfXAfjnxdD8O550y6ocvR28aJ9nEuCdtXe)0Eywn2345KoexJoqiWvVvbZ54aWIIM6lZjHX(PsyqGGwW(OdecCf2P(MrCayW(OdecCMj7HXbGbRXhggcn288PHk4LbJefzySdf7F4m8abFMKVasQG7QFfhawuSNNkySZEcvgAOcEzrEwpkFzySdf7F4m8abFMKVasQG7QFfVipRhvmXIOyppvWyN9eQm0qf8YI8SEuibsG4XJGVGcHy0CmqMHhuG(5WfXAfjnxdD8O550y6ocvR28aJ9nEuCdtXe)0Z9GweQub3v)Qt6q8EEQGXo7juzOHk4Lf5z9O8frqikQrhie4Wv7Hl02CsRy20mjmGtzfhI5aiFpeeiikQdecC4Q9WfABoPvmBAMegWPSIdXCaKWXpeeiOfSoqiWvVvbZ54aWGzySdf7F4mt2dJxKN1JsyqGqEGX(gpkUHPyIFQ6jNZkzWzfDcdzMJKVvqPxfhXt6q8IcfPey6oc83EK8Xs0MegrqawbtoN8Tck9kU6Tk0f57XaBWsMaIDgSgDGqGZmzpmErEwpkHrebrrF0bcboZK9W4aWAZdm234rXnmft8tdafYsCqsoGHoPdXjMRHveVhPnid2GLmbe7myDGqGdxThUqBZjTIztZKWaoLvCiMdG89qqGaynO4NBOg83qiPYVvEsuZZGs8VzN7bQOOpmmeAS55dXkSdxOIIkyY5KVvqPxj8HAZdm234rXnmft8tvVvbZ5oPdX1bcboEOxGsctfJG)gpCayWA0bcbU6TkyohVOqrkbMUJefn1xMtcJ9tLWcncAZdm234rXnmft8tvVvbZ5oPdXzyi0yZZNgQGxgmcSgiw1MUJ4m8abFMKOKc5HjkYWyhk2)WzMShghawuuhie4mt2dJdaRfmdJDOy)dNHhi4ZK8fqsfCx9R4f5z9O8fkdL7zcbKzu70yQVmNeg7NkKaeiOfSoqiWvVvbZ54f5z9O89y5bg7B8O4gMIj(PQ3kfqbLoPdXzyi0yZZNgQGxgmcSgiw1MUJ4m8abFMKOKc5HjkYWyhk2)WzMShghawuuhie4mt2dJdaRfmdJDOy)dNHhi4ZK8fqsfCx9R4f5z9O8fkdL7zcbKzu70yQVmNeg7NkKauiOfSoqiWvVvbZ54aWGjMRHveVhPniNhySVXJIBykM4NQERuafu6Koexhie44HEbkjZrwjH0QgpCayrrn(OERcDrCdwYeqSZIIA0bcboZK9W4f5z9O8feG1bcboZK9W4aWIIA0bcbEzqObdOKHIMyJmVipRhLVqzOCptiGmJANgt9L5KWy)uHeGcbTG1bcbEzqObdOKHIMyJmhawRwWqSQnDhXvVvbZ5K(XZldMZjXHayfm5CY3kO0R4Q3QG5C(ckTG14tbmuaxqj(3EKFCns0Imp9EqPItizGggMqffvWKZjFRGsVIRERcMZ5lO0MhySVXJIBykM4NoKFPhgpN0H4AiMRHveVhPnidMHXouS)HZmzpmErEwpkHbbcIIAycSckPIFi4IycSckj)2J8feAffzcSckPIdkTGnyjtaXoNhySVXJIBykM4NkWCbPhgpN0H4AiMRHveVhPnidMHXouS)HZmzpmErEwpkHbbcIIAycSckPIFi4IycSckj)2J8feAffzcSckPIdkTGnyjtaXoNhySVXJIBykM4NgaCoPhgpN0H4AiMRHveVhPnidMHXouS)HZmzpmErEwpkHbbcIIAycSckPIFi4IycSckj)2J8feAffzcSckPIdkTGnyjtaXoNhySVXJIBykM4N63QQXLehKKdyO8aJ9nEuCdtXe)uiw1MUJozmpkU6Tk0fj7rQWoRobI5aO4kyY5KVvqPxXvVvHUiHpwmbhgxA8m1tfYsiMdGqIdrqBmbhgxA0bcbU6Tsbuqjj5bJ9tLhnpx9g7msCmT5bg7B8O4gMIj(P(l7fCshItmxdRiUdySsoKqErrI5AyfXTbz5qc5bdXQ20DeVvsMJmiKOOoqiWjMRHvKuHDwXlYZ6r5RX(gpC1BvOlItcHyapj)2JaRdecCI5AyfjvyNvCayrrI5AyfX7rQWoRa7deRAt3rC1BvOls2JuHDwjkQdecCMj7HXlYZ6r5RX(gpC1BvOlItcHyapj)2Ja7deRAt3r8wjzoYGqG1bcboZK9W4f5z9O8LecXaEs(Thbwhie4mt2dJdalkQdec8YGqdgqjdfnXgzoamyfm5CsbM6jHrGhlG1OGjNt(wbLELVXbLOOpV5O55kmGtIdYxajd4IupNgt3rOAff9bIvTP7iERKmhzqiW6aHaNzYEy8I8SEuctcHyapj)2JYdm234rXnmft8tvVvHUO8aJ9nEuCdtXe)0cyKg7B8iDT6pzmpkEWCUxqbKhKhySVXJIRJTpEzqObdOKHIMyJ8jDiUoqiWzMShghaopWyFJhfxhBFmXpfIvTP7OtgZJIZWde8zsIskKh2jqmhafp4W4sJMEEQGXo7juzOHk4Lf5z9OqshIGwKaXdrqRWbhgxA00Ztfm2zpHkdnubVSipRhfs6qqGK0GicG8BoAEEpmRg7B8WPX0DeQwKKMJbYm8Gc0phUiwRiP5AOJhnpNgt3rOA1IeiE8iOnpWyFJhfxhBFmXpfIvTP7OtgZJIZQ(h8daFceZbqX9rhie46MZggjXbP5CYxqpqvYXEGI4aWG9rhie46MZggjXbP5CYxqpqvsRy2qCa48aJ9nEuCDS9Xe)ud1G)gcjv(TY7egYmhjFRGsVkoIN0H46aHax3C2WijoinNt(c6bQso2duex9g7SeI5aiFpgcG1bcbUU5SHrsCqAoN8f0duL0kMnex9g7SeI5aiFpgcG14dk(5gQb)nesQ8BLNe18mOe)B25EGc2hJ9nE4gQb)nesQ8BLNe18mOeVhzW1qf8G14dk(5gQb)nesQ8BLNuazo(3SZ9avuef)Cd1G)gcjv(TYtkGmhVipRhLWGsROik(5gQb)nesQ8BLNe18mOex9g7SVGcmk(5gQb)nesQ8BLNe18mOeVipRhLVGamk(5gQb)nesQ8BLNe18mOe)B25EGQnpWyFJhfxhBFmXpLHhi4ZK8fqsfCx9RoPdX1aXQ20DeNHhi4ZKeLuipmW98ubJD2tOYqdvWllYZ6rjmIGcbW(WWyhk2)WzMShgVidfzrrDGqGZmzpmoaSwWA0bcbUU5SHrsCqAoN8f0duLCShOiU6n2zjeZbqXbbcII6aHax3C2WijoinNt(c6bQsAfZgIREJDwcXCauCqGGwrXqdvWllYZ6r5lIiKhySVXJIRJTpM4NYSHroPoqiCYyEuC1BLdxON0H4A0bcbUU5SHrsCqAoN8f0duLCShOiErEwpkHpgheII6aHax3C2WijoinNt(c6bQsAfZgIxKN1Js4JXbHwWM6lZjHX(Ps44cncG1WWyhk2)WzMShgVipRhLWGurrnmm2HI9pCYdg7NkPoEq5f5z9OegKc2hDGqGFUh0IqLKhm2pvE08sAOcAhBIdadMHHqJnp)mYvBJwT5bg7B8O46y7Jj(PQ3kfqbLoPdX9bIvTP7ioR6FWpamynmmeAS55tdvWldgjkYWyhk2)WzMShgVipRhLWGurrnmm2HI9pCYdg7NkPoEq5f5z9OegKc2hDGqGFUh0IqLKhm2pvE08sAOcAhBIdadMHHqJnp)mYvBJwT5bg7B8O46y7Jj(PQ3kfqbLoPdX1WWyhk2)Wz4bc(mjFbKub3v)koamynqSQnDhXz4bc(mjrjfYdtuKHXouS)HZmzpmErEwpkFbHwTGn1xMtcJ9tLWGabWmmeAS55tdvWldgLhySVXJIRJTpM4NQaMqx0jmKzos(wbLEvCepPdXlkuKsGP7iWVvqPN)ThjFSeTjHrmwaRXGLmbe7mynqSQnDhXzv)d(bGff1yQVmNeg7NkFbfcG9rhie4mt2dJdaRvuKHXouS)HZmzpmErgkYA1MhySVXJIRJTpM4N6HXtOl6egYmhjFRGsVkoIN0H4ffksjW0De43kO0Z)2JKpwI2KWickoiaRXGLmbe7mynqSQnDhXzv)d(bGff1yQVmNeg7NkFbfcG9rhie4mt2dJdaRvuKHXouS)HZmzpmErgkYAb7JoqiWp3dArOsYdg7NkpAEjnubTJnXbG1MhySVXJIRJTpM4NQEY5SsgCwrNWqM5i5Bfu6vXr8KoeVOqrkbMUJa)wbLE(3EK8Xs0MegXyjMI8SEuG1yWsMaIDgSgiw1MUJ4SQ)b)aWIIM6lZjHX(PYxqHGOidJDOy)dNzYEy8ImuK1QnpWyFJhfxhBFmXpnGlgjXb5ypqrN0H4gSKjGyNZdm234rX1X2ht8tdafYsCqsoGHoPdX1qmxdRiEpsBqwuKyUgwrCf2zLShjIIIeZ1WkI7agRK9irulyn(WWqOXMNpnubVmyKOOgt9L5KWy)u5RqdcWAGyvB6oIZQ(h8dalkAQVmNeg7NkFbfcIIqSQnDhXBL0WKwWAGyvB6oIZWde8zsIskKhgyFyySdf7F4m8abFMKVasQG7QFfhawu0hiw1MUJ4m8abFMKOKc5Hb2hgg7qX(hoZK9W4aWA1QfSggg7qX(hoZK9W4f5z9OeguiikAQVmNeg7NkHfAeaZWyhk2)WzMShghagSggg7qX(ho5bJ9tLuhpO8I8SEu(ASVXdx9wf6I4KqigWtYV9irrFyyi0yZZpJC12OvuSNNkySZEcvgAOcEzrEwpkFrebTG1GIFUHAWFdHKk)w5jrnpdkXlYZ6rj8Xef9HHHqJnpFiwHD4cvBEGX(gpkUo2(yIF65EqlcvQG7QF1jDiUgI5AyfXDaJvYHeYlksmxdRiUc7SsoKqErrI5AyfXTbz5qc5ff1bcbUU5SHrsCqAoN8f0duLCShOiErEwpkHpgheII6aHax3C2WijoinNt(c6bQsAfZgIxKN1Js4JXbHOOP(YCsySFQewOramdJDOy)dNzYEy8ImuK1cwddJDOy)dNzYEy8I8SEucdkeefzySdf7F4mt2dJxKHISwrXEEQGXo7juzOHk4Lf5z9O8freYdm234rX1X2ht8tzKJuFBoP5AOJhn)jDiUgt9L5KWy)ujSqJayn6aHa)CpOfHkjpySFQ8O5L0qf0o2ehawu0hggcn288ZixTnAffzyi0yZZNgQGxgmsuuhie46omg1bOEoamyDGqGR7WyuhG65f5z9O89qeIrZXazgEqb6NdxeRvK0Cn0XJMNtJP7iuTAbRXhggcn288PHk4LbJefzySdf7F4m8abFMKVasQG7QFfhawuSNNkySZEcvgAOcEzrEwpkFzySdf7F4m8abFMKVasQG7QFfVipRhvmXIOyppvWyN9eQm0qf8YI8SEuibsG4XJGVhIqmAogiZWdkq)C4IyTIKMRHoE08CAmDhHQvBEGX(gpkUo2(yIFApmRg7B8CshIRXuFzojm2pvcl0iawJoqiWp3dArOsYdg7NkpAEjnubTJnXbGff9HHHqJnp)mYvBJwrrggcn288PHk4LbJef1bcbUUdJrDaQNdadwhie46omg1bOEErEwpkFbfcXO5yGmdpOa9ZHlI1ksAUg64rZZPX0DeQwTG14dddHgBE(0qf8YGrIImm2HI9pCgEGGptYxajvWD1VIdalkcXQ20DeNHhi4ZKeLuipmW98ubJD2tOYqdvWllYZ6rjmIhpcXCicXO5yGmdpOa9ZHlI1ksAUg64rZZPX0DeQwrXEEQGXo7juzOHk4Lf5z9O8LHXouS)HZWde8zs(ciPcUR(v8I8SEuXelII98ubJD2tOYqdvWllYZ6r5lOqignhdKz4bfOFoCrSwrsZ1qhpAEonMUJq1QnpWyFJhfxhBFmXpv9wPakO0jDioddHgBE(0qf8YGrG1aXQ20DeNHhi4ZKeLuipmrrgg7qX(hoZK9W4f5z9O8fre0c2uFzojm2pvcdceaZWyhk2)Wz4bc(mjFbKub3v)kErEwpkFreH8aJ9nEuCDS9Xe)uiw1MUJozmpkUPGporveXobI5aO4eZ1WkI3J0bmwbYhpsySVXdx9wf6I4KqigWtYV9Oy8HyUgwr8EKoGXkqowqcJ9nE4(l7fWjHqmGNKF7rXGa)qKqbtoNuGPEkpWyFJhfxhBFmXpv9wPakO0jDiUMEEQGXo7juzOHk4Lf5z9O89yIIA0bcbEzqObdOKHIMyJmVipRhLVqzOCptiGmJANgt9L5KWy)uHeGcbTG1bcbEzqObdOKHIMyJmhawRwrrnM6lZjHX(Pkgiw1MUJ4Mc(4evredK1bcboXCnSIKkSZkErEwpQyqXppauilXbj5agI)n7SswKN1diFihecJ4HiikAQVmNeg7NQyGyvB6oIBk4Jtufrmqwhie4eZ1Wks6agR4f5z9OIbf)8aqHSehKKdyi(3SZkzrEwpG8HCqimIhIGwWeZ1WkI3J0gKbRrJpmm2HI9pCMj7HXbGffzyi0yZZpJC12a2hgg7qX(ho5bJ9tLuhpOCayTIImmeAS55tdvWldgPfSgFyyi0yZZHqZla5su0hDGqGZmzpmoaSOOP(YCsySFQewOrqROOoqiWzMShgVipRhLWhpyF0bcbEzqObdOKHIMyJmhaopWyFJhfxhBFmXpDi)spmEoPdX1OdecCI5AyfjDaJvCayrrnmbwbLuXpeCrmbwbLKF7r(ccTIImbwbLuXbLwWgSKjGyNZdm234rX1X2ht8tfyUG0dJNt6qCn6aHaNyUgwrshWyfhawuudtGvqjv8dbxetGvqj53EKVGqROitGvqjvCqPfSblzci258aJ9nEuCDS9Xe)0aGZj9W45KoexJoqiWjMRHvK0bmwXbGff1Weyfusf)qWfXeyfus(Th5li0kkYeyfusfhuAbBWsMaIDopWyFJhfxhBFmXp1VvvJljoijhWq5bg7B8O46y7Jj(PQ3Qqx0jDioXCnSI49iDaJvIIeZ1WkIRWoRKdjKxuKyUgwrCBqwoKqErrDGqG73QQXLehKKdyioamyI5AyfX7r6agRef1OdecCMj7HXlYZ6r5RX(gpC)L9c4KqigWtYV9iW6aHaNzYEyCayT5bg7B8O46y7Jj(P(l7fKhySVXJIRJTpM4NwaJ0yFJhPRv)jJ5rXdMZ9ckG8G8aJ9nEuC0Imp9EqPkoeRAt3rNmMhfxzbs(yjGIKkyY5obI5aO4A0bcb(3EKFCns0Imp9EqPIxKN1JsyOmuUNjKyqGJiyneZ1WkI3Juh)cefjMRHveVhPc7SsuKyUgwrChWyLCiH8Aff1bcb(3EKFCns0Imp9EqPIxKN1JsyJ9nE4Q3QqxeNecXaEs(ThfdcCebRHyUgwr8EKoGXkrrI5AyfXvyNvYHeYlksmxdRiUnilhsiVwTII(Odec8V9i)4AKOfzE69GsfhaopWyFJhfhTiZtVhuQIj(PQ3kfqbLoPdX14deRAt3rCLfi5JLaksQGjNtuuJoqiWldcnyaLmu0eBK5f5z9O8fkdL7zcbKzu70yQVmNeg7NkKauiOfSoqiWldcnyaLmu0eBK5aWA1kkAQVmNeg7NkHfAeYdm234rXrlY807bLQyIFkdpqWNj5lGKk4U6xDshIRbIvTP7iodpqWNjjkPqEyG75Pcg7SNqLHgQGxwKN1JsyebfcG9HHXouS)HZmzpmErgkYII6aHaNzYEyCayTGn1xMtcJ9tLVhdbWA0bcboXCnSIKoGXkErEwpkHrebrrDGqGtmxdRiPc7SIxKN1JsyerqROyOHk4Lf5z9O8freYdm234rXrlY807bLQyIFQHAWFdHKk)w5DcdzMJKVvqPxfhXt6qCFqXp3qn4VHqsLFR8KOMNbL4FZo3duW(ySVXd3qn4VHqsLFR8KOMNbL49idUgQGhSgFqXp3qn4VHqsLFR8KciZX)MDUhOIIO4NBOg83qiPYVvEsbK54f5z9OegeAffrXp3qn4VHqsLFR8KOMNbL4Q3yN9fuGrXp3qn4VHqsLFR8KOMNbL4f5z9O8fuGrXp3qn4VHqsLFR8KOMNbL4FZo3d08aJ9nEuC0Imp9EqPkM4N6HXtOl6egYmhjFRGsVkoIN0H4ffksjW0De43kO0Z)2JKpwI2KWiEiynA0bcboZK9W4f5z9OegeG1Odec8YGqdgqjdfnXgzErEwpkHbHOOp6aHaVmi0GbuYqrtSrMdaRvu0hDGqGZmzpmoaSOOP(YCsySFQ8fuiOfSgF0bcb(5EqlcvsEWy)u5rZlPHkODSjoaSOOP(YCsySFQ8fuiOfSblzci2zT5bg7B8O4OfzE69GsvmXpvbmHUOtyiZCK8Tck9Q4iEshIxuOiLat3rGFRGsp)Bps(yjAtcJ4HG1Orhie4mt2dJxKN1JsyqawJoqiWldcnyaLmu0eBK5f5z9OegeII(Odec8YGqdgqjdfnXgzoaSwrrF0bcboZK9W4aWIIM6lZjHX(PYxqHGwWA8rhie4N7bTiuj5bJ9tLhnVKgQG2XM4aWIIM6lZjHX(PYxqHGwWgSKjGyN1MhySVXJIJwK5P3dkvXe)u1toNvYGZk6egYmhjFRGsVkoIN0H4ffksjW0De43kO0Z)2JKpwI2KWiglG1Orhie4mt2dJxKN1JsyqawJoqiWldcnyaLmu0eBK5f5z9OegeII(Odec8YGqdgqjdfnXgzoaSwrrF0bcboZK9W4aWIIM6lZjHX(PYxqHGwWA8rhie4N7bTiuj5bJ9tLhnVKgQG2XM4aWIIM6lZjHX(PYxqHGwWgSKjGyN1MhySVXJIJwK5P3dkvXe)0aUyKehKJ9afDshIBWsMaIDopWyFJhfhTiZtVhuQIj(PLbHgmGsgkAInYN0H46aHaNzYEyCa48aJ9nEuC0Imp9EqPkM4NEUh0IqLk4U6xDshIRrJoqiWjMRHvKuHDwXlYZ6rjmIiikQdecCI5AyfjDaJv8I8SEucJicAbZWyhk2)WzMShgVipRhLWGcbTIImm2HI9pCMj7HXlYqropWyFJhfhTiZtVhuQIj(PmYrQVnN0Cn0XJM)KoexJgDGqGFUh0IqLKhm2pvE08sAOcAhBIdalk6dddHgBE(zKR2gTIImmeAS55tdvWldgjkcXQ20DeVvsdtII6aHax3HXOoa1ZbGbRdecCDhgJ6aupVipRhLVhIqmAogiZWdkq)C4IyTIKMRHoE08CAmDhHQvlyF0bcboZK9W4aWG14dddHgBE(0qf8YGrIImm2HI9pCgEGGptYxajvWD1VIdalk2Ztfm2zpHkdnubVSipRhLVmm2HI9pCgEGGptYxajvWD1VIxKN1JkMyruSNNkySZEcvgAOcEzrEwpkKajq84rW3drignhdKz4bfOFoCrSwrsZ1qhpAEonMUJq1QnpWyFJhfhTiZtVhuQIj(P9WSASVXZjDiUgn6aHa)CpOfHkjpySFQ8O5L0qf0o2ehawu0hggcn288ZixTnAffzyi0yZZNgQGxgmsueIvTP7iERKgMef1bcbUUdJrDaQNdadwhie46omg1bOEErEwpkFbfcXO5yGmdpOa9ZHlI1ksAUg64rZZPX0DeQwTG9rhie4mt2dJdadwJpmmeAS55tdvWldgjkYWyhk2)Wz4bc(mjFbKub3v)koaSOyppvWyN9eQm0qf8YI8SEu(YWyhk2)Wz4bc(mjFbKub3v)kErEwpQyIfrXEEQGXo7juzOHk4Lf5z9OqcKaXJhbFbfcXO5yGmdpOa9ZHlI1ksAUg64rZZPX0DeQwT5bg7B8O4OfzE69GsvmXpfIvTP7OtgZJIRmiKmGljZK9WobI5aO4A8HHXouS)HZmzpmErgkYII(aXQ20DeNHhi4ZKeLuipmWmmeAS55tdvWldgPnpWyFJhfhTiZtVhuQIj(PbGczjoijhWqN0H4eZ1WkI3J0gKbBWsMaIDgSgu8Znud(BiKu53kpjQ5zqj(3SZ9avu0hggcn288Hyf2HluTGHyvB6oIRmiKmGljZK9WYdm234rXrlY807bLQyIFQ6TsbuqPt6qCggcn288PHk4LbJadXQ20DeNHhi4ZKeLuipmWM6lZjHX(Ps44hdbWmm2HI9pCgEGGptYxajvWD1VIxKN1JYxOmuUNjeqMrTtJP(YCsySFQqcqHG28aJ9nEuC0Imp9EqPkM4NoKFPhgpN0H4A0bcboXCnSIKoGXkoaSOOgMaRGsQ4hcUiMaRGsYV9iFbHwrrMaRGsQ4GslydwYeqSZGHyvB6oIRmiKmGljZK9WYdm234rXrlY807bLQyIFQaZfKEy8CshIRrhie4eZ1Wks6agR4aWG9HHHqJnp)mYvBJOOgDGqGFUh0IqLKhm2pvE08sAOcAhBIdadMHHqJnp)mYvBJwrrnmbwbLuXpeCrmbwbLKF7r(ccTIImbwbLuXbLOOoqiWzMShghawlydwYeqSZGHyvB6oIRmiKmGljZK9WYdm234rXrlY807bLQyIFAaW5KEy8CshIRrhie4eZ1Wks6agR4aWG9HHHqJnp)mYvBJOOgDGqGFUh0IqLKhm2pvE08sAOcAhBIdadMHHqJnp)mYvBJwrrnmbwbLuXpeCrmbwbLKF7r(ccTIImbwbLuXbLOOoqiWzMShghawlydwYeqSZGHyvB6oIRmiKmGljZK9WYdm234rXrlY807bLQyIFQFRQgxsCqsoGHYdm234rXrlY807bLQyIFQ6Tk0fDshItmxdRiEpshWyLOiXCnSI4kSZk5qc5ffjMRHve3gKLdjKxuuhie4(TQACjXbj5agIdadwhie4eZ1Wks6agR4aWIIA0bcboZK9W4f5z9O81yFJhU)YEbCsied4j53EeyDGqGZmzpmoaS28aJ9nEuC0Imp9EqPkM4N6VSxqEGX(gpkoArMNEpOuft8tlGrASVXJ01Q)KX8O4bZ5EbfqEqEGX(gpkEWCUxqbex9wPakO0jDiUpfWqbCbL46MZggjXbP5CYxqpqvCcjd0WWeAEGX(gpkEWCUxqbet8tvatOl6egYmhjFRGsVkoIN0H4O4N7HXtOlIxKN1Js4I8SEu5bg7B8O4bZ5EbfqmXp1dJNqxuEqEGX(gpkoCrW2ZeivFCpmEcDrNWqM5i5Bfu6vXr8KoeVOqrkbMUJa)wbLE(3EK8Xs0MegXdbRrJoqiWzMShgVipRhLWGqu0hDGqGZmzpmoaSOOP(YCsySFQ8fuiOfSblzci2zT5bg7B8O4WfbBptGu9Xe)ufWe6IoHHmZrY3kO0RIJ4jDiErHIucmDhb(Tck98V9i5JLOnjmIhcwJgDGqGZmzpmErEwpkHbHOOp6aHaNzYEyCayrrt9L5KWy)u5lOqqlydwYeqSZAZdm234rXHlc2EMaP6Jj(PQNCoRKbNv0jmKzos(wbLEvCepPdXlkuKsGP7iWVvqPN)ThjFSeTjHrmwaRrJoqiWzMShgVipRhLWGqu0hDGqGZmzpmoaSOOP(YCsySFQ8fuiOfSblzci2zT5bg7B8O4WfbBptGu9Xe)0aUyKehKJ9afDshIBWsMaIDopWyFJhfhUiy7zcKQpM4NYihP(2CsZ1qhpA(t6qCnM6lZjHX(PsyHgbrrDGqGR7WyuhG65aWG1bcbUUdJrDaQNxKN1JY3dJfTG9rhie4mt2dJdaNhySVXJIdxeS9mbs1ht8t7Hz1yFJNt6qCnM6lZjHX(PsyHgbrrDGqGR7WyuhG65aWG1bcbUUdJrDaQNxKN1JYxqflAb7JoqiWzMShghaopWyFJhfhUiy7zcKQpM4NcXQ20D0jJ5rXvgesgWLKzYEyNaXCauCFyySdf7F4mt2dJxKHICEGX(gpkoCrW2ZeivFmXpnauilXbj5ag6KoeNyUgwr8EK2GmydwYeqSZGHyvB6oIRmiKmGljZK9WYdm234rXHlc2EMaP6Jj(PmByKtQdecNmMhfx9w5Wf6jDiUoqiWvVvoCHYlYZ6r5BSawJoqiWjMRHvKuHDwXbGff1bcboXCnSIKoGXkoaSwWM6lZjHX(PsyHgH8aJ9nEuC4IGTNjqQ(yIFQ6TsbuqPt6qCn(yXMQ(jU6lYo3duP6TsXlBolkQdecCMj7HXlYZ6r5ljeIb8K8Bpsu0h4IGWvVvkGckPfSgDGqGZmzpmoaSOOP(YCsySFQewOramXCnSI49iTbzT5bg7B8O4WfbBptGu9Xe)u1BLcOGsN0H4A8XInv9tC1xKDUhOs1BLIx2Cwuuhie4mt2dJxKN1JYxsied4j53EKOOpWfbHRERuafusl43C08C1BLdxOCAmDhHcwJoqiWvVvoCHYbGffn1xMtcJ9tLWcncAbRdecC1BLdxOC1BSZ(ckWA0bcboXCnSIKkSZkoaSOOoqiWjMRHvK0bmwXbG1cMHXouS)HZmzpmErEwpkHbP5bg7B8O4WfbBptGu9Xe)u1BLcOGsN0H4A8XInv9tC1xKDUhOs1BLIx2Cwuuhie4mt2dJxKN1JYxsied4j53EKOOpWfbHRERuafuslyDGqGtmxdRiPc7SIxKN1JsyqkyI5AyfX7rQWoRa7ZBoAEU6TYHluonMUJqbZWyhk2)WzMShgVipRhLWG08aJ9nEuC4IGTNjqQ(yIF6q(LEy8CshIRrhie4eZ1Wks6agR4aWIIAycSckPIFi4IycSckj)2J8feAffzcSckPIdkTGnyjtaXodgIvTP7iUYGqYaUKmt2dlpWyFJhfhUiy7zcKQpM4NkWCbPhgpN0H4A0bcboXCnSIKoGXkoaSOOgMaRGsQ4hcUiMaRGsYV9iFbHwrrMaRGsQ4Gsuuhie4mt2dJdaRfSblzci2zWqSQnDhXvgesgWLKzYEy5bg7B8O4WfbBptGu9Xe)0aGZj9W45KoexJoqiWjMRHvK0bmwXbGff1Weyfusf)qWfXeyfus(Th5li0kkYeyfusfhuII6aHaNzYEyCayTGnyjtaXodgIvTP7iUYGqYaUKmt2dlpWyFJhfhUiy7zcKQpM4N63QQXLehKKdyO8aJ9nEuC4IGTNjqQ(yIFQ6Tk0fDshIRXInv9tC1xKDUhOs1BLIx2CgSoqiWzMShgVipRhLWKqigWtYV9iWWfbH7VSxGwrrn(yXMQ(jU6lYo3duP6TsXlBolkQdecCMj7HXlYZ6r5ljeIb8K8Bpsu0h4IGWvVvHUiTG1qmxdRiEpshWyLOiXCnSI4kSZk5qc5ffjMRHve3gKLdjKxuuhie4(TQACjXbj5agIdadwhie4eZ1Wks6agR4aWIIA0bcboZK9W4f5z9O81yFJhU)YEbCsied4j53EeyDGqGZmzpmoaSwTIIASytv)eh18p9avQagEzZzHpeSoqiWjMRHvKuHDwXlYZ6rjmia7JoqiWrn)tpqLkGHxKN1JsyJ9nE4(l7fWjHqmGNKF7rAZdekYvOuixKXa5(y85CJEY5Sk3Jlvh(tYfzmqUWfw30DiNRFB(Cvypk3O3QG5C5ca)ThX588aJ9nEuC4IGTNjqQ(yIFQ6Tkyo3jDi(BoAEU6jNZkjA1HNtJP7iuW6aHax9wfmNJxuOiLat3rGdnubVSipRhLW6aHax9wfmNJJcu234bSgFiMRHveVhPnilkQdecC1BLcOGssYdg7NkpAEoaS28aJ9nEuC4IGTNjqQ(yIFQ)YEb5bg7B8O4WfbBptGu9Xe)0cyKg7B8iDT6pzmpkEWCUxqbKhKhySVXJIR(4gQb)nesQ8BL3jmKzos(wbLEvCepPdX9bf)Cd1G)gcjv(TYtIAEguI)n7Cpqb7JX(gpCd1G)gcjv(TYtIAEguI3Jm4AOcEWA8bf)Cd1G)gcjv(TYtkGmh)B25EGkkIIFUHAWFdHKk)w5jfqMJxKN1JsyqOvuef)Cd1G)gcjv(TYtIAEguIREJD2xqbgf)Cd1G)gcjv(TYtIAEguIxKN1JYxqbgf)Cd1G)gcjv(TYtIAEguI)n7CpqZdm234rXvFmXpLHhi4ZK8fqsfCx9RoPdX1aXQ20DeNHhi4ZKeLuipmW98ubJD2tOYqdvWllYZ6rjmIGcbW(WWyhk2)WzMShgVidfzrrDGqGZmzpmoaSwWM6lZjHX(PYxqGayn6aHaNyUgwrshWyfVipRhLWiIGOOoqiWjMRHvKuHDwXlYZ6rjmIiOvum0qf8YI8SEu(Iic5bg7B8O4QpM4NcXQ20D0jJ5rXrXVSiKmqxKhnV6eiMdGIRrhie4mt2dJxKN1JsyqawJoqiWldcnyaLmu0eBK5f5z9OegeII(Odec8YGqdgqjdfnXgzoaSwrrF0bcboZK9W4aWIIM6lZjHX(PYxqHGwWA8rhie4N7bTiuj5bJ9tLhnVKgQG2XM4aWIIM6lZjHX(PYxqHGwWA0bcboXCnSIKkSZkErEwpkHHYq5EMqef1bcboXCnSIKoGXkErEwpkHHYq5EMq0MhySVXJIR(yIFQhgpHUOtyiZCK8Tck9Q4iEshIxuOiLat3rGFRGsp)Bps(yjAtcJ4HG1yWsMaIDgmeRAt3rCu8llcjd0f5rZR0MhySVXJIR(yIFQcycDrNWqM5i5Bfu6vXr8KoeVOqrkbMUJa)wbLE(3EK8Xs0MegXdbRXGLmbe7myiw1MUJ4O4xwesgOlYJMxPnpWyFJhfx9Xe)u1toNvYGZk6egYmhjFRGsVkoIN0H4ffksjW0De43kO0Z)2JKpwI2KWiglG1yWsMaIDgmeRAt3rCu8llcjd0f5rZR0MhySVXJIR(yIFAaxmsIdYXEGIoPdXnyjtaXoNhySVXJIR(yIFAzqObdOKHIMyJ8jDiUoqiWzMShghaopWyFJhfx9Xe)0Z9GweQub3v)Qt6qCnA0bcboXCnSIKkSZkErEwpkHrebrrDGqGtmxdRiPdySIxKN1Jsyerqlygg7qX(hoZK9W4f5z9OeguiawJoqiWHR2dxOT5KwXSPzsyaNYkoeZbq(E4Xqqu0NcyOaUGsC4Q9WfABoPvmBAMegWPSItizGggMq1Qvuuhie4Wv7Hl02CsRy20mjmGtzfhI5aiHJFiifbrrgg7qX(hoZK9W4fzOidwJP(YCsySFQewOrqueIvTP7iERKgM0MhySVXJIR(yIFkJCK6BZjnxdD8O5pPdX1yQVmNeg7NkHfAeaRrhie4N7bTiuj5bJ9tLhnVKgQG2XM4aWII(WWqOXMNFg5QTrROiddHgBE(0qf8YGrIIqSQnDhXBL0WKOOoqiW1DymQdq9CayW6aHax3HXOoa1ZlYZ6r57HieJgncnixadfWfuIdxThUqBZjTIztZKWaoLvCcjd0WWeQ2y0CmqMHhuG(5WfXAfjnxdD8O550y6ocvRwTG9rhie4mt2dJdadwJpmmeAS55tdvWldgjkYWyhk2)Wz4bc(mjFbKub3v)koaSOyppvWyN9eQm0qf8YI8SEu(YWyhk2)Wz4bc(mjFbKub3v)kErEwpQyIfrXEEQGXo7juzOHk4Lf5z9OqcKaXJhbFpeHy0CmqMHhuG(5WfXAfjnxdD8O550y6ocvR28aJ9nEuC1ht8t7Hz1yFJNt6qCnM6lZjHX(PsyHgbWA0bcb(5EqlcvsEWy)u5rZlPHkODSjoaSOOpmmeAS55NrUAB0kkYWqOXMNpnubVmyKOieRAt3r8wjnmjkQdecCDhgJ6auphagSoqiW1DymQdq98I8SEu(ckeIrJgHgKlGHc4ckXHR2dxOT5KwXSPzsyaNYkoHKbAyycvBmAogiZWdkq)C4IyTIKMRHoE08CAmDhHQvRwW(OdecCMj7HXbGbRXhggcn288PHk4LbJefzySdf7F4m8abFMKVasQG7QFfhawuSNNkySZEcvgAOcEzrEwpkFzySdf7F4m8abFMKVasQG7QFfVipRhvmXIOyppvWyN9eQm0qf8YI8SEuibsG4XJGVGcHy0CmqMHhuG(5WfXAfjnxdD8O550y6ocvR28aJ9nEuC1ht8tHyvB6o6KX8O4kdcjd4sYmzpStGyoakUgFyySdf7F4mt2dJxKHISOOpqSQnDhXz4bc(mjrjfYddmddHgBE(0qf8YGrAZdm234rXvFmXpnauilXbj5ag6KoeNyUgwr8EK2GmydwYeqSZG1bcboC1E4cTnN0kMnntcd4uwXHyoaY3dpgcG1GIFUHAWFdHKk)w5jrnpdkX)MDUhOII(WWqOXMNpeRWoCHQfmeRAt3rCLbHKbCjzMShwEGX(gpkU6Jj(PQ3QG5CN0H46aHahp0lqjHPIrWFJhoamyDGqGRERcMZXlkuKsGP7O8aJ9nEuC1ht8tz2WiNuhieozmpkU6TYHl0t6qCDGqGRERC4cLxKN1JYxqawJoqiWjMRHvKuHDwXlYZ6rjmief1bcboXCnSIKoGXkErEwpkHbHwWM6lZjHX(PsyHgH8aJ9nEuC1ht8tvVvkGckDshIZWqOXMNpnubVmyeyiw1MUJ4m8abFMKOKc5HbMHXouS)HZWde8zs(ciPcUR(v8I8SEu(cLHY9mHaYmQDAm1xMtcJ9tfsake0MhySVXJIR(yIFQ6Tkyo3jDi(BoAEU6jNZkjA1HNtJP7iuW(8MJMNRERC4cLtJP7iuW6aHax9wfmNJxuOiLat3rG1OdecCI5AyfjDaJv8I8SEuchlGjMRHveVhPdyScSoqiWHR2dxOT5KwXSPzsyaNYkoeZbq(Eiiqquuhie4Wv7Hl02CsRy20mjmGtzfhI5aiHJFiiqaSP(YCsySFQewOrquef)Cd1G)gcjv(TYtIAEguIxKN1Js4Jxu0yFJhUHAWFdHKk)w5jrnpdkX7rgCnubVwW(WWyhk2)WzMShgVidf58aJ9nEuC1ht8tvVvkGckDshIRdecC8qVaLK5iRKqAvJhoaSOOoqiWp3dArOsYdg7NkpAEjnubTJnXbGff1bcboZK9W4aWG1Odec8YGqdgqjdfnXgzErEwpkFHYq5EMqazg1onM6lZjHX(PcjafcAbRdec8YGqdgqjdfnXgzoaSOOp6aHaVmi0GbuYqrtSrMdad2hgg7qX(hEzqObdOKHIMyJmVidfzrrFyyi0yZZHqZla5sROOP(YCsySFQewOramXCnSI49iTb58aJ9nEuC1ht8tvVvkGckDshI)MJMNRERC4cLtJP7iuWA0bcbU6TYHluoaSOOP(YCsySFQewOrqlyDGqGRERC4cLREJD2xqbwJoqiWjMRHvKuHDwXbGff1bcboXCnSIKoGXkoaSwW6aHahUApCH2MtAfZMMjHbCkR4qmha57HGueaRHHXouS)HZmzpmErEwpkHrebrrFGyvB6oIZWde8zsIskKhgyggcn288PHk4LbJ0MhySVXJIR(yIFQ6TsbuqPt6qCn6aHahUApCH2MtAfZMMjHbCkR4qmha57HGueef1bcboC1E4cTnN0kMnntcd4uwXHyoaY3dbbcGFZrZZvp5CwjrRo8CAmDhHQfSoqiWjMRHvKuHDwXlYZ6rjmifmXCnSI49ivyNvG9rhie44HEbkjmvmc(B8WbGb7ZBoAEU6TYHluonMUJqbZWyhk2)WzMShgVipRhLWGuWAyySdf7F4N7bTiuPcUR(v8I8SEucdsff9HHHqJnp)mYvBJ28aJ9nEuC1ht8thYV0dJNt6qCn6aHaNyUgwrshWyfhawuudtGvqjv8dbxetGvqj53EKVGqROitGvqjvCqPfSblzci2zWqSQnDhXvgesgWLKzYEy5bg7B8O4QpM4NkWCbPhgpN0H4A0bcboXCnSIKoGXkoamyFyyi0yZZpJC12ikQrhie4N7bTiuj5bJ9tLhnVKgQG2XM4aWGzyi0yZZpJC12OvuudtGvqjv8dbxetGvqj53EKVGqROitGvqjvCqjkQdecCMj7HXbG1c2GLmbe7myiw1MUJ4kdcjd4sYmzpS8aJ9nEuC1ht8tdaoN0dJNt6qCn6aHaNyUgwrshWyfhagSpmmeAS55NrUABef1Odec8Z9GweQK8GX(PYJMxsdvq7ytCayWmmeAS55NrUAB0kkQHjWkOKk(HGlIjWkOK8BpYxqOvuKjWkOKkoOef1bcboZK9W4aWAbBWsMaIDgmeRAt3rCLbHKbCjzMShwEGX(gpkU6Jj(P(TQACjXbj5agkpWyFJhfx9Xe)u1BvOl6KoeNyUgwr8EKoGXkrrI5AyfXvyNvYHeYlksmxdRiUnilhsiVOOoqiW9Bv14sIdsYbmehagSoqiWjMRHvK0bmwXbGff1OdecCMj7HXlYZ6r5RX(gpC)L9c4KqigWtYV9iW6aHaNzYEyCayT5bg7B8O4QpM4N6VSxqEGX(gpkU6Jj(PfWin234r6A1FYyEu8G5CVGc4(3)Eb]] )


end