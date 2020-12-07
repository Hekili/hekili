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


    spec:RegisterPack( "Balance", 20201207, [[dG0oudqicLhbvOCjOQYMaPprOknkQuNIkzvcj6vcHzbKClOcAxO6xaPgguPJbvzzcPEgiY0GQQUgiQTrOQ(gqOghuHCoHewhHQyEuv19ub7JQkheiqwiuvEiqqteiaCrGaOpceqojuHkRuiAMqfyNardfiaTuOcv9uHAQqf9vGa1ybcO2lG)s0Gv6WKwmv5XOmzOCzKnl4Za1OjKtl51QqZMs3Mk2TOFdz4G64aHSCfpNIPRQRRsBxf9DQkJNqLZdcRxiP5tW(LAa8aWjqmM(eaiJg3OXfVOXfeZXd3OXrqc)bIFiGjGyyLDubtaXP6qaX4tTAYiGyyfclsXaWjqSbDhgbel6FyJ4b0GgC9IUECgYb0MY5A1VqjB0WdAt5WanqS3TSpoUeWdigtFcaKrJB04Ix04cI54HB04iiHhqSEFrObioUCaHaXIkmmkb8aIXiddighRx8PwnzuVGayUfwhjowVGaGyKJhn9cIbvVrJB042r2rIJ1liuKMGjJ4PJehRxCyVGGWWiSEJrwD6fFK6W7iXX6fh2liuKMGjSEFDatVSc9Yudz69r9YGGzj5Rdy6n8osCSEXH9IJNCqNewV3mjgzm6arVN6uQNLm96U4ehu9cp0P086yUdyQxCOF9cp0j386yUdyYfVJehRxCyVGGorfwVWdXuZxj4Ebbp6lQ3k0B9IxtVViQxFdkb3liaz2c2qCGyBzEdaobIHhIHC80haNaGepaCceRSVqjqSdcLhRugqJdqmLQNLWaWhWdaYObWjqSY(cLaXhReBimPbUM6naXuQEwcdaFapaiHeaobIPu9Sega(aIv2xOei23OViGy2upnLce7UxIzlydXT3uhzsI77vqOxIzlydXRuAVPo9ki0lXSfSH4vk9qVOEfe6Ly2c2qCnHqMK4(EDbeBRKKmmGy8Wf4baj(dGtGykvplHbGpGy2upnLce7UxIzlydXT3uhzsI77vqOxIzlydXRuAVPo9ki0lXSfSH4vk9qVOEfe6Ly2c2qCnHqMK4(ED1l0EHh6KJh33OVOEH2Ry9cp0jpAUVrFraXk7luce7B0xeWdasidGtGykvplHbGpGy2upnLcelwVZnPaAatCp1QjJKOGuTw5lQsWgoLQNLW6vqOxX6LHoPuZNNfyrVmOuVcc9kwVgyYALVoGP3WnVob1A79qV4beRSVqjqS51judb8aGu8bWjqmLQNLWaWhqmBQNMsbINBsb0aM4EQvtgjrbPATYxuLGnCkvplH1l0EzOtk185zbw0ldk1l0EnWK1kFDatVHBEDcQ127HEXdiwzFHsGyZRJ5oGjGh4bIXOGETpaobajEa4eiwzFHsGydYQJ0JuhGykvplHbGpGhaKrdGtGykvplHbGpGyemqSHEGyL9fkbIp1PuplbeFQ2lbeBGjRv(6aMEd386euRTx)6fVEH2R7EfR3xTu(CZRJfnyCkvplH1RGqVVAP85MNSwDKytfEoLQNLW61vVcc9AGjRv(6aMEd386euRTx)6nAG4tDKP6qaXLrQic4bajKaWjqmLQNLWaWhqmcgi2qpqSY(cLaXN6uQNLaIpv7LaInWK1kFDatVHBEDc1q96xV4beFQJmvhciUmsML0tc4baj(dGtGykvplHbGpGy2upnLce7UxX6LHoPuZNNfyrVmOuVcc9kwVmeYIH8LCgkprhj5lIKg4AQ3WVW96QxO96DdbotLvY4xyGyL9fkbI9OXqZXkbd8aGeYa4eiMs1Zsya4diMn1ttPaXE3qGZuzLm(fgiwzFHsGyy0xOe4baP4dGtGykvplHbGpGyemqSHEGyL9fkbIp1PuplbeFQ2lbehSi00R7ED3BLpnWiR(eMmuGf9YHC0kn9Id7nAC7fh2ldHSyiFjNHYt0rs(IiPbUM6n8HC0kn96Qxq3lErJBVU61VEdweA61DVU7TYNgyKvFctgkWIE5qoALMEXH9gnK7fh2R7EXd3EJYEF1s5ZRKPtQFHsoLQNLW61vV4WED3ldLy365WdXkdjvBboDO85F5qYt1EPED1loSxgczXq(sotLvY4d5OvA61vVGUx8Wr42RREfe6LHqwmKVKZuzLm(qoALME9R3kFAGrw9jmzOal6Ld5OvA6vqOxgczXq(sodLNOJK8frsdCn1B4d5OvA61VER8Pbgz1NWKHcSOxoKJwPPxbHEfRxg6KsnFEwGf9YGsaXN6it1HaIzO8eDKKyKbIKb8aGeedGtGykvplHbGpGyL9fkbIR0WM7REwscIUA(xhjgDwmciMn1ttPaXE3qGZuzLm(fgiovhciUsdBUV6zjji6Q5FDKy0zXiGhaK4iaCceRSVqjq81qY6jhdqmLQNLWaWhWdaYOaaNaXuQEwcdaFaXSPEAkfi(uNs9SeVmsfraXMFk2das8aIv2xOeiEUPuzFHsPTmpqSTmVmvhciwreWdas8WfaNaXuQEwcdaFaXSPEAkfiEUjfqdyI)Ld5dnPeBi1XRsmA4ei6wWWegqS5NI9aGepGyL9fkbINBkv2xOuAlZdeBlZlt1HaIXgsD8QeJgGhaK4HhaobIPu9Sega(aIzt90ukq8CtkGgWe3tTAYijkivRv(IQeSHtGOBbdtyaXMFk2das8aIv2xOeiEUPuzFHsPTmpqSTmVmvhci2dPpWdas8IgaNaXuQEwcdaFaXk7lucep3uQSVqP0wMhi2wMxMQdbeBEGh4bIXgsD8QeJgaCcas8aWjqmLQNLWaWhqmcgi2qpqSY(cLaXN6uQNLaIpv7LaID3R3ne4F5q(qtkXgsD8QeJg(qoALME9RxWmmUJkUEJOxC541l0ED3lXSfSH4vk9qVOEfe6Ly2c2q8kLgKvNEfe6Ly2c2qC7n1rMK4(ED1RGqVE3qG)Ld5dnPeBi1XRsmA4d5OvA61VEv2xOKBEDc1qCsCe7(K8lhQ3i6fxoE9cTx39smBbBiELs7n1PxbHEjMTGne3GS6itsCFVcc9smBbBiUMqitsCFVU61vVcc9kwVE3qG)Ld5dnPeBi1XRsmA4xyG4tDKP6qaXgnqYhjVgsAGjRf4baz0a4eiMs1Zsya4diMn1ttPaXU7vSEp1PuplXnAGKpsEnK0atwBVcc96UxVBiWh9Ks01iddLrfc(qoALME9VxWmmUJkUEJYEzuz71DVQ5h1kHr(OPxq3lKWTxx9cTxVBiWh9Ks01iddLrfc(fUxx96QxbHEvZpQvcJ8rtV(1BuGlqSY(cLaXMxhZDatapaiHeaobIPu9Sega(aIzt90ukqS7Ep1PuplXzO8eDKKyKbIK1l0ER8Pbgz1NWKHcSOxoKJwPPx)6fpiHBVq7vSEziKfd5l5mvwjJpKIbrVcc96DdbotLvY4x4ED1l0EvZpQvcJ8rtV(3l(JBVq71DVE3qGtmBbBiP9M6WhYrR00RF9IhU9ki0R3ne4eZwWgsAqwD4d5OvA61VEXd3ED1RGqVHcSOxoKJwPPx)7fpCbIv2xOeiMHYt0rs(IiPbUM6napaiXFaCcetP6zjma8beRSVqjqSIPWFDssJpDCaIzt90ukqSy9IHEUIPWFDssJpDCKyQJcM4FXowj4EH2Ry9QSVqjxXu4VojPXNoosm1rbt8kLbBbw03l0ED3Ry9IHEUIPWFDssJpDCKIi1Y)IDSsW9ki0lg65kMc)1jjn(0XrkIulFihTstV(1lK71vVcc9IHEUIPWFDssJpDCKyQJcM4Mxzh71)EHuVq7fd9CftH)6KKgF64iXuhfmXhYrR00R)9cPEH2lg65kMc)1jjn(0XrIPokyI)f7yLGbIzqWSK81bm9gaqIhWdasidGtGykvplHbGpGyL9fkbIDqOmudbeZM6PPuG4HcdzePEwQxO9(6aME(xoK8rsSI61VEXl6EH2R7ED3R3ne4mvwjJpKJwPPx)6fY9cTx396Ddb(ONuIUgzyOmQqWhYrR00RF9c5Efe6vSE9UHaF0tkrxJmmugvi4x4ED1RGqVI1R3ne4mvwjJFH7vqOx18JALWiF00R)9cjC71vVq71DVI1R3ne4hReBimj5aJ8rJdLVKsAaxrL4x4Efe6vn)OwjmYhn96FVqc3ED1l0EvyjteXo2RlGygemljFDatVbaK4b8aGu8bWjqmLQNLWaWhqSY(cLaXMBgQHaIzt90ukq8qHHmIupl1l0EFDatp)lhs(ijwr96xV4fDVq71DVU717gcCMkRKXhYrR00RF9c5EH2R7E9UHaF0tkrxJmmugvi4d5OvA61VEHCVcc9kwVE3qGp6jLORrggkJke8lCVU6vqOxX617gcCMkRKXVW9ki0RA(rTsyKpA61)EHeU96QxO96UxX617gc8JvIneMKCGr(OXHYxsjnGROs8lCVcc9QMFuReg5JME9VxiHBVU6fAVkSKjIyh71fqmdcMLKVoGP3aas8aEaqcIbWjqmLQNLWaWhqSY(cLaXMNSwDKbRoeqmBQNMsbIhkmKrK6zPEH27Rdy65F5qYhjXkQx)6fpXVxO96Ux396DdbotLvY4d5OvA61VEHCVq71DVE3qGp6jLORrggkJke8HC0kn96xVqUxbHEfRxVBiWh9Ks01iddLrfc(fUxx9ki0Ry96DdbotLvY4x4Efe6vn)OwjmYhn96FVqc3ED1l0ED3Ry96Ddb(XkXgctsoWiF04q5lPKgWvuj(fUxbHEvZpQvcJ8rtV(3lKWTxx9cTxfwYerSJ96ciMbbZsYxhW0BaajEapaiXra4eiMs1Zsya4diMn1ttPaXkSKjIyhbIv2xOeioGggjrbzQ)DiGhaKrbaobIPu9Sega(aIzt90ukqS3ne4mvwjJFHbIv2xOeiE0tkrxJmmugviaEaqIhUa4eiMs1Zsya4diMn1ttPaXU71DVE3qGtmBbBiPbz1HpKJwPPx)6fpC7vqOxVBiWjMTGnK0EtD4d5OvA61VEXd3ED1l0EziKfd5l5mvwjJpKJwPPx)6fs42RREfe6LHqwmKVKZuzLm(qkgeaXk7luceFSsSHWKg4AQ3a8aGep8aWjqmLQNLWaWhqmBQNMsbID3R7E9UHa)yLydHjjhyKpACO8Lusd4kQe)c3RGqVI1ldDsPMp)ietPzVU6vqOxg6KsnFEwGf9YGs9ki07PoL6zjEzKkI6vqOxVBiW9SieM9AE(fUxO96DdbUNfHWSxZZhYrR00R)9gnU9grVU7LHsSB9C4HyLHKQTaNou(8VCi5PAVuVU61vVq7vSE9UHaNPYkz8lCVq71DVI1ldDsPMpplWIEzqPEfe6LHqwmKVKZq5j6ijFrK0axt9g(fUxbHER8Pbgz1NWKHcSOxoKJwPPx)7LHqwmKVKZq5j6ijFrK0axt9g(qoALMEJOxXVxbHER8Pbgz1NWKHcSOxoKJwPPx8Rx8Wr42R)9gnU9grVU7LHsSB9C4HyLHKQTaNou(8VCi5PAVuVU61fqSY(cLaXmYsMVuRuTf40HYh4bajErdGtGykvplHbGpGy2upnLce7Ux396Ddb(XkXgctsoWiF04q5lPKgWvuj(fUxbHEfRxg6KsnF(riMsZED1RGqVm0jLA(8Sal6LbL6vqO3tDk1Zs8Yive1RGqVE3qG7zrim7188lCVq717gcCplcHzVMNpKJwPPx)7fs42Be96UxgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9s96Qxx9cTxX617gcCMkRKXVW9cTx39kwVm0jLA(8Sal6LbL6vqOxgczXq(sodLNOJK8frsdCn1B4x4Efe6TYNgyKvFctgkWIE5qoALME9VxgczXq(sodLNOJK8frsdCn1B4d5OvA6nIEf)Efe6TYNgyKvFctgkWIE5qoALMEXVEXdhHBV(3lKWT3i61DVmuIDRNdpeRmKuTf40HYN)Ldjpv7L61vVUaIv2xOeiUsMoP(fkbEaqIhKaWjqmLQNLWaWhqmcgi2qpqSY(cLaXN6uQNLaIpv7LaID3Ry9YqilgYxYzQSsgFifdIEfe6vSEp1PuplXzO8eDKKyKbIK1l0EzOtk185zbw0ldk1RlG4tDKP6qaXg9KKb0izQSsgWdas8WFaCcetP6zjma8beZM6PPuGyIzlydXRuQje9cTxfwYerSJ9cTx39IHEUIPWFDssJpDCKyQJcM4FXowj4Efe6vSEzOtk185jXgKfny96QxO9EQtPEwIB0tsgqJKPYkzaXk7lucehUdesuqs2BsapaiXdYa4eiMs1Zsya4diMn1ttPaXm0jLA(8Sal6LbL6fAVN6uQNL4muEIossmYarY6fAVQ5h1kHr(OPx)o0l(JBVq7LHqwmKVKZq5j6ijFrK0axt9g(qoALME9VxWmmUJkUEJYEzuz71DVQ5h1kHr(OPxq3lKWTxxaXk7luceBEDm3bmb8aGepXhaNaXuQEwcdaFaXSPEAkfi2DVE3qGtmBbBiP9M6WVW9ki0R7EzI0bmz69qVr3l0EhIjshWK8lhQx)7fY96QxbHEzI0bmz69qVqQxx9cTxfwYerSJ9cT3tDk1ZsCJEsYaAKmvwjdiwzFHsG4K8jDqOe4bajEGyaCcetP6zjma8beZM6PPuGy396DdboXSfSHK2BQd)c3l0EfRxg6KsnF(riMsZEfe61DVE3qGFSsSHWKKdmYhnou(skPbCfvIFH7fAVm0jLA(8JqmLM96QxbHED3ltKoGjtVh6n6EH27qmr6aMKF5q96FVqUxx9ki0ltKoGjtVh6fs9ki0R3ne4mvwjJFH71vVq7vHLmre7yVq79uNs9Se3ONKmGgjtLvYaIv2xOeiwKAdshekbEaqIhocaNaXuQEwcdaFaXSPEAkfi2DVE3qGtmBbBiP9M6WVW9cTxX6LHoPuZNFeIP0SxbHED3R3ne4hReBimj5aJ8rJdLVKsAaxrL4x4EH2ldDsPMp)ietPzVU6vqOx39YePdyY07HEJUxO9oetKoGj5xouV(3lK71vVcc9YePdyY07HEHuVcc96DdbotLvY4x4ED1l0EvyjteXo2l0Ep1PuplXn6jjdOrYuzLmGyL9fkbIdxRv6GqjWdas8IcaCceRSVqjqSpDMcnsuqs2BsaXuQEwcdaFapaiJgxaCcetP6zjma8beZM6PPuGyIzlydXRuAVPo9ki0lXSfSH4gKvhzsI77vqOxIzlydX1eczsI77vqOxVBiW9PZuOrIcsYEtIFH7fAVE3qGtmBbBiP9M6WVW9ki0R7E9UHaNPYkz8HC0kn96FVk7luY9n6lItIJy3NKF5q9cTxVBiWzQSsg)c3RlGyL9fkbInVoHAiGhaKrJhaobIv2xOei23OViGykvplHbGpGhaKrhnaobIPu9Sega(aIv2xOeiEUPuzFHsPTmpqSTmVmvhcioOw7lAUapWdeRicaNaGepaCcetP6zjma8beJGbIn0deRSVqjq8PoL6zjG4t1EjGy396Ddb(xoKp0KsSHuhVkXOHpKJwPPx)7fmdJ7OIR3i6fxoE9ki0R3ne4F5q(qtkXgsD8QeJg(qoALME9VxL9fk5MxNqneNehXUpj)YH6nIEXLJxVq71DVeZwWgIxP0EtD6vqOxIzlydXniRoYKe33RGqVeZwWgIRjeYKe33RRED1l0E9UHa)lhYhAsj2qQJxLy0WVW9cT35MuanGj(xoKp0KsSHuhVkXOHtGOBbdtyaXN6it1HaIXgsDK(kRvguRvIcbGhaKrdGtGykvplHbGpGy2upnLce7U3tDk1ZsCgkprhjjgzGiz9cTxX6LHqwmKVKZuzLm(qkge9ki0R3ne4mvwjJFH71vVq7vn)OwjmYhn96FVqg3EH2R7E9UHaNy2c2qs7n1HpKJwPPx)6v87vqOxVBiWjMTGnK0GS6WhYrR00RF9k(96QxO96UxX6DUjfqdyI7PwnzKefKQ1kFrvc2WPu9SewVcc96DdbUNA1KrsuqQwR8fvjyJm1)oe38k7O8uTxQx)6fs42RGqVE3qG7PwnzKefKQ1kFrvc2i1HPjXnVYokpv7L61VEHeU96QxbHEdfyrVCihTstV(3lE4ceRSVqjqmdLNOJK8frsdCn1BaEaqcjaCcetP6zjma8beZM6PPuGyVBiWnVob1A5dfgYis9SuVq71DVgyYALVoGP3WnVob1A71)EHuVcc9kwVZnPaAat8VCiFOjLydPoEvIrdNar3cgMW61vVq71DVI17CtkGgWe3cbth1idwI(kblbBlhydXjq0TGHjSEfe69lhQx8Rx8hY96xVE3qGBEDcQ1YhYrR00Be9gDVUaIv2xOei286euRf4baj(dGtGykvplHbGpGy2upnLcep3KcObmX)YH8HMuInK64vjgnCceDlyycRxO9AGjRv(6aMEd386euRTx)o0lK6fAVU7vSE9UHa)lhYhAsj2qQJxLy0WVW9cTxVBiWnVob1A5dfgYis9SuVcc96U3tDk1ZsCSHuhPVYALb1ALOqOxO96UxVBiWnVob1A5d5OvA61)EHuVcc9AGjRv(6aMEd386euRTx)6n6EH27RwkFU5jRvhj2uHNtP6zjSEH2R3ne4MxNGAT8HC0kn96FVqUxx96QxxaXk7luceBEDcQ1c8aGeYa4eiMs1Zsya4digbdeBOhiwzFHsG4tDk1ZsaXNQ9saXQ5h1kHr(OPx)6fhHBV4WED3lE42Bu2R3ne4F5q(qtkXgsD8QeJgU5v2XED1loSx396DdbU51jOwlFihTstVrzVqQxq3RbMSwPi18uVU6fh2R7EXqppChiKOGKS3K4d5OvA6nk7fY96QxO96DdbU51jOwl)cdeFQJmvhci286euRv6dLVmOwRefcapaifFaCcetP6zjma8beZM6PPuG4tDk1ZsCSHuhPVYALb1ALOqOxO9EQtPEwIBEDcQ1k9HYxguRvIcHEfe61DVE3qG7PwnzKefKQ1kFrvc2it9VdXnVYokpv7L61VEHeU9ki0R3ne4EQvtgjrbPATYxuLGnsDyAsCZRSJYt1EPE9RxiHBVU6fAVgyYALVoGP3WnVob1A71)EXFGyL9fkbInVoM7aMaEaqcIbWjqmLQNLWaWhqSY(cLaXMBgQHaIzt90ukq8qHHmIupl1l0EFDatp)lhs(ijwr96xV4H)9Id71atwR81bm9MEJO3HC0kn9cTxfwYerSJ9cTxIzlydXRuQjeaXmiyws(6aMEdaiXd4bajocaNaXuQEwcdaFaXk7luceRyk8xNK04thhGy2upnLcelwVFXowj4EH2Ry9QSVqjxXu4VojPXNoosm1rbt8kLbBbw03RGqVyONRyk8xNK04thhjM6OGjU5v2XE9Vxi1l0EXqpxXu4VojPXNoosm1rbt8HC0kn96FVqciMbbZsYxhW0BaajEapaiJcaCcetP6zjma8beRSVqjqSdcLHAiGy2upnLcepuyiJi1Zs9cT3xhW0Z)YHKpsIvuV(1R7EXd)7nIED3RbMSw5Rdy6nCZRtOgQ3OSx84qUxx96Qxq3RbMSw5Rdy6n9grVd5OvA6fAVU7LHqwmKVKZuzLm(qkge9cTx39EQtPEwIZq5j6ijXidejRxbHEziKfd5l5muEIosYxejnW1uVHpKIbrVcc9kwVm0jLA(8Sal6LbL61vVcc9AGjRv(6aMEd386eQH61)ED3l(3Bu2R7EXR3i69vlLp)9vP0bHsdNs1Zsy96Qxx9ki0R7EjMTGneVsPbz1PxbHED3lXSfSH4vk9qVOEfe6Ly2c2q8kL2BQtVU6fAVI17RwkFUbDTsuq(IizanK55uQEwcRxbHE9UHahEkh0GvQvQdtZIjHVwJo8t1EPE97qVrdzC71vVq71DVgyYALVoGP3WnVoHAOE9Vx8WT3OSx39IxVr07RwkF(7RsPdcLgoLQNLW61vVU6fAVQ5h1kHr(OPx)6fY42loSxVBiWnVob1A5d5OvA6nk7v871vVq71DVI1R3ne4hReBimj5aJ8rJdLVKsAaxrL4x4Efe6Ly2c2q8kLgKvNEfe6vSEzOtk185hHykn71vVq7vHLmre7iqmdcMLKVoGP3aas8aEaqIhUa4eiMs1Zsya4diMn1ttPaXkSKjIyhbIv2xOeioGggjrbzQ)DiGhaK4HhaobIPu9Sega(aIzt90ukqS3ne4mvwjJFHbIv2xOeiE0tkrxJmmugviaEaqIx0a4eiMs1Zsya4diMn1ttPaXU717gcCZRtqTw(fUxbHEvZpQvcJ8rtV(1lKXTxx9cTxX617gcCdYA(Ir8lCVq7vSE9UHaNPYkz8lCVq71DVI1ldDsPMpplWIEzqPEfe69uNs9SeNHYt0rsIrgiswVcc9YqilgYxYzO8eDKKVisAGRPEd)c3RGqVv(0aJS6tyYqbw0lhYrR00R)9gnU9grVU7LHsSB9C4HyLHKQTaNou(8VCi5PAVuVU61fqSY(cLaXmYsMVuRuTf40HYh4bajEqcaNaXuQEwcdaFaXSPEAkfi2DVE3qGBEDcQ1YVW9ki0RA(rTsyKpA61VEHmU96QxO9kwVE3qGBqwZxmIFH7fAVI1R3ne4mvwjJFH7fAVU7vSEzOtk185zbw0ldk1RGqVN6uQNL4muEIossmYarY6vqOxgczXq(sodLNOJK8frsdCn1B4x4Efe6TYNgyKvFctgkWIE5qoALME9VxgczXq(sodLNOJK8frsdCn1B4d5OvA6nIEf)Efe6TYNgyKvFctgkWIE5qoALMEXVEXdhHBV(3lKWT3i61DVmuIDRNdpeRmKuTf40HYN)Ldjpv7L61vVUaIv2xOeiUsMoP(fkbEaqIh(dGtGykvplHbGpGy2upnLcex5tdmYQpHjdfyrVCihTstV(3lEqUxbHED3R3ne4Wt5GgSsTsDyAwmj81A0HFQ2l1R)9gnKXTxbHE9UHahEkh0GvQvQdtZIjHVwJo8t1EPE97qVrdzC71vVq717gcCZRtqTw(fUxO9YqilgYxYzQSsgFihTstV(1lKXfiwzFHsGyYbg5JgPhkXaEaqIhKbWjqmLQNLWaWhqSY(cLaXMNSwDKbRoeqmBQNMsbIhkmKrK6zPEH27xoK8rsSI61VEXdY9cTxdmzTYxhW0B4MxNqnuV(3l(3l0EvyjteXo2l0ED3R3ne4mvwjJpKJwPPx)6fpC7vqOxX617gcCMkRKXVW96ciMbbZsYxhW0BaajEapaiXt8bWjqmLQNLWaWhqmBQNMsbIjMTGneVsPMq0l0EvyjteXo2l0E9UHahEkh0GvQvQdtZIjHVwJo8t1EPE9V3OHmU9cTx39IHEUIPWFDssJpDCKyQJcM4FXowj4Efe6vSEzOtk185jXgKfny9ki0RbMSw5Rdy6n96xVr3RlGyL9fkbId3bcjkij7njGhaK4bIbWjqmLQNLWaWhqmBQNMsbI9UHahL0lYiHPHrWFHs(fUxO96UxVBiWnVob1A5dfgYis9SuVcc9QMFuReg5JME9R3Oa3EDbeRSVqjqS51jOwlWdas8Wra4eiMs1Zsya4diMn1ttPaXm0jLA(8Sal6LbL6fAVU79uNs9SeNHYt0rsIrgiswVcc9YqilgYxYzQSsg)c3RGqVE3qGZuzLm(fUxx9cTxgczXq(sodLNOJK8frsdCn1B4d5OvA61)EbZW4oQ46nk7LrLTx39QMFuReg5JMEbDVqg3ED1l0E9UHa386euRLpKJwPPx)7f)bIv2xOei286euRf4bajErbaobIPu9Sega(aIzt90ukqmdDsPMpplWIEzqPEH2R7Ep1PuplXzO8eDKKyKbIK1RGqVmeYIH8LCMkRKXVW9ki0R3ne4mvwjJFH71vVq7LHqwmKVKZq5j6ijFrK0axt9g(qoALME9VxXVxO96DdbU51jOwl)c3l0EjMTGneVsPMqaeRSVqjqS51XChWeWdaYOXfaNaXuQEwcdaFaXSPEAkfi27gcCusViJKzjDKNLPqj)c3RGqVU7vSEnVoHAiUclzIi2XEfe61DVE3qGZuzLm(qoALME9Vxi3l0E9UHaNPYkz8lCVcc96UxVBiWh9Ks01iddLrfc(qoALME9VxWmmUJkUEJYEzuz71DVQ5h1kHr(OPxq3lKWTxx9cTxVBiWh9Ks01iddLrfc(fUxx96QxO9EQtPEwIBEDcQ1k9HYxguRvIcHEH2RbMSw5Rdy6nCZRtqT2E9Vxi1RREH2R7EfR35MuanGj(xoKp0KsSHuhVkXOHtGOBbdty9ki0RbMSw5Rdy6nCZRtqT2E9Vxi1RlGyL9fkbInVoM7aMaEaqgnEa4eiMs1Zsya4diMn1ttPaXU7Ly2c2q8kLAcrVq7LHqwmKVKZuzLm(qoALME9RxiJBVcc96UxMiDatMEp0B09cT3HyI0bmj)YH61)EHCVU6vqOxMiDatMEp0lK61vVq7vHLmre7iqSY(cLaXj5t6GqjWdaYOJgaNaXuQEwcdaFaXSPEAkfi2DVeZwWgIxPuti6fAVmeYIH8LCMkRKXhYrR00RF9czC7vqOx39YePdyY07HEJUxO9oetKoGj5xouV(3lK71vVcc9YePdyY07HEHuVU6fAVkSKjIyhbIv2xOeiwKAdshekbEaqgnKaWjqmLQNLWaWhqmBQNMsbID3lXSfSH4vk1eIEH2ldHSyiFjNPYkz8HC0kn96xVqg3Efe61DVmr6aMm9EO3O7fAVdXePdys(Ld1R)9c5ED1RGqVmr6aMm9EOxi1RREH2RclzIi2rGyL9fkbIdxRv6GqjWdaYOXFaCceRSVqjqSpDMcnsuqs2BsaXuQEwcdaFapaiJgYa4eiMs1Zsya4digbdeBOhiwzFHsG4tDk1ZsaXNQ9saXgyYALVoGP3WnVoHAOE9Rx8V3i6nyrOPx396OMNgiKNQ9s9c6EJg3ED1Be9gSi00R7E9UHa386yUdyssoWiF04q5lniRoCZRSJ9c6EX)EDbeFQJmvhci286eQHKvkniRoapaiJw8bWjqmLQNLWaWhqmBQNMsbIjMTGne3EtDKjjUVxbHEjMTGnextiKjjUVxO9EQtPEwIxgjZs6j1RGqVE3qGtmBbBiPbz1HpKJwPPx)7vzFHsU51judXjXrS7tYVCOEH2R3ne4eZwWgsAqwD4x4Efe6Ly2c2q8kLgKvNEH2Ry9EQtPEwIBEDc1qYkLgKvNEfe617gcCMkRKXhYrR00R)9QSVqj386eQH4K4i29j5xouVq7vSEp1PuplXlJKzj9K6fAVE3qGZuzLm(qoALME9VxsCe7(K8lhQxO96DdbotLvY4x4Efe617gc8rpPeDnYWqzuHGFH7fAVgyYALIuZt96xV4Yf)EH2R7EnWK1kFDatVPx)p0lK6vqOxX69vlLp3GUwjkiFrKmGgY8CkvplH1RREfe6vSEp1PuplXlJKzj9K6fAVE3qGZuzLm(qoALME9RxsCe7(K8lhciwzFHsGyFJ(IaEaqgnigaNaXk7luceBEDc1qaXuQEwcdaFapaiJghbGtGykvplHbGpGyL9fkbINBkv2xOuAlZdeBlZlt1HaIdQ1(IMlWd8aXb1AFrZfaNaGepaCcetP6zjma8beZM6PPuGyX6DUjfqdyI7PwnzKefKQ1kFrvc2Wjq0TGHjmGyL9fkbInVoM7aMaEaqgnaobIPu9Sega(aIv2xOei2CZqneqmBQNMsbIXqp3bHYqneFihTstV(17qoALgGygemljFDatVbaK4b8aGesa4eiwzFHsGyhekd1qaXuQEwcdaFapWdeBEaCcas8aWjqmLQNLWaWhqSY(cLaXkMc)1jjn(0XbiMn1ttPaXI1lg65kMc)1jjn(0XrIPokyI)f7yLG7fAVI1RY(cLCftH)6KKgF64iXuhfmXRugSfyrFVq71DVI1lg65kMc)1jjn(0XrkIul)l2Xkb3RGqVyONRyk8xNK04thhPisT8HC0kn96xVqUxx9ki0lg65kMc)1jjn(0XrIPokyIBELDSx)7fs9cTxm0Zvmf(RtsA8PJJetDuWeFihTstV(3lK6fAVyONRyk8xNK04thhjM6OGj(xSJvcgiMbbZsYxhW0BaajEapaiJgaNaXuQEwcdaFaXSPEAkfi2DVN6uQNL4muEIossmYarY6fAVI1ldHSyiFjNPYkz8Humi6vqOxVBiWzQSsg)c3RREH2RA(rTsyKpA61)EXFC7fAVU717gcCIzlydjT3uh(qoALME9Rx8WTxbHE9UHaNy2c2qsdYQdFihTstV(1lE42RREfe6nuGf9YHC0kn96FV4HlqSY(cLaXmuEIosYxejnW1uVb4bajKaWjqmLQNLWaWhqmcgi2qpqSY(cLaXN6uQNLaIpv7LaID3R3ne4mvwjJpKJwPPx)6fY9cTx396Ddb(ONuIUgzyOmQqWhYrR00RF9c5Efe6vSE9UHaF0tkrxJmmugvi4x4ED1RGqVI1R3ne4mvwjJFH7vqOx18JALWiF00R)9cjC71vVq71DVI1R3ne4hReBimj5aJ8rJdLVKsAaxrL4x4Efe6vn)OwjmYhn96FVqc3ED1l0ED3R3ne4eZwWgsAqwD4d5OvA61VEbZW4oQ46vqOxVBiWjMTGnK0EtD4d5OvA61VEbZW4oQ461fq8PoYuDiGym0lhceDRHCO8napaiXFaCcetP6zjma8beRSVqjqSdcLHAiGy2upnLcepuyiJi1Zs9cT3xhW0Z)YHKpsIvuV(1lEr3l0ED3RclzIi2XEH27PoL6zjog6LdbIU1qou(MEDbeZGGzj5Rdy6naGepGhaKqgaNaXuQEwcdaFaXk7luceBUzOgciMn1ttPaXdfgYis9SuVq791bm98VCi5JKyf1RF9Ix09cTx39QWsMiIDSxO9EQtPEwIJHE5qGOBnKdLVPxxaXmiyws(6aMEdaiXd4baP4dGtGykvplHbGpGyL9fkbInpzT6idwDiGy2upnLcepuyiJi1Zs9cT3xhW0Z)YHKpsIvuV(1lEIFVq71DVkSKjIyh7fAVN6uQNL4yOxoei6wd5q5B61fqmdcMLKVoGP3aas8aEaqcIbWjqmLQNLWaWhqmBQNMsbIvyjteXoceRSVqjqCanmsIcYu)7qapaiXra4eiMs1Zsya4diMn1ttPaXE3qGZuzLm(fgiwzFHsG4rpPeDnYWqzuHa4bazuaGtGykvplHbGpGy2upnLce7Ux396DdboXSfSHKgKvh(qoALME9Rx8WTxbHE9UHaNy2c2qs7n1HpKJwPPx)6fpC71vVq7LHqwmKVKZuzLm(qoALME9RxiHBVq71DVE3qGdpLdAWk1k1HPzXKWxRrh(PAVuV(3B04pU9ki0Ry9o3KcObmXHNYbnyLAL6W0Sys4R1OdNar3cgMW61vVU6vqOxVBiWHNYbnyLAL6W0Sys4R1Od)uTxQx)o0B0GyC7vqOxgczXq(sotLvY4dPyq0l0ED3RA(rTsyKpA61VEJcC7vqO3tDk1Zs8Yive1RlGyL9fkbIjhyKpAKEOed4bajE4cGtGykvplHbGpGy2upnLce7Ux18JALWiF00RF9gf42l0ED3R3ne4hReBimj5aJ8rJdLVKsAaxrL4x4Efe6vSEzOtk185hHykn71vVcc9YqNuQ5ZZcSOxguQxbHEp1PuplXlJuruVcc96DdbUNfHWSxZZVW9cTxVBiW9SieM9AE(qoALME9V3OXT3i61DVU7nk6nk7DUjfqdyIdpLdAWk1k1HPzXKWxRrhobIUfmmH1RREJOx39Yqj2TEo8qSYqs1wGthkF(xoK8uTxQxx96Qxx9cTxX617gcCMkRKXVW9cTx39kwVm0jLA(8Sal6LbL6vqOxgczXq(sodLNOJK8frsdCn1B4x4Efe6TYNgyKvFctgkWIE5qoALME9VxgczXq(sodLNOJK8frsdCn1B4d5OvA6nIEf)Efe6TYNgyKvFctgkWIE5qoALMEXVEXdhHBV(3B042Be96UxgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9s96QxxaXk7luceZilz(sTs1wGthkFGhaK4HhaobIPu9Sega(aIzt90ukqS7EvZpQvcJ8rtV(1BuGBVq71DVE3qGFSsSHWKKdmYhnou(skPbCfvIFH7vqOxX6LHoPuZNFeIP0Sxx9ki0ldDsPMpplWIEzqPEfe69uNs9SeVmsfr9ki0R3ne4EwecZEnp)c3l0E9UHa3ZIqy2R55d5OvA61)EHeU9grVU71DVrrVrzVZnPaAatC4PCqdwPwPomnlMe(An6Wjq0TGHjSED1Be96UxgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9s96Qxx96QxO9kwVE3qGZuzLm(fUxO96UxX6LHoPuZNNfyrVmOuVcc9YqilgYxYzO8eDKKVisAGRPEd)c3RGqVv(0aJS6tyYqbw0lhYrR00R)9YqilgYxYzO8eDKKVisAGRPEdFihTstVr0R43RGqVv(0aJS6tyYqbw0lhYrR00l(1lE4iC71)EHeU9grVU7LHsSB9C4HyLHKQTaNou(8VCi5PAVuVU61fqSY(cLaXvY0j1VqjWdas8IgaNaXuQEwcdaFaXiyGyd9aXk7luceFQtPEwci(uTxci2DVI1ldHSyiFjNPYkz8Humi6vqOxX69uNs9SeNHYt0rsIrgiswVq7LHoPuZNNfyrVmOuVUaIp1rMQdbeB0tsgqJKPYkzapaiXdsa4eiMs1Zsya4diMn1ttPaXeZwWgIxPuti6fAVkSKjIyh7fAVE3qGdpLdAWk1k1HPzXKWxRrh(PAVuV(3B04pU9cTx39IHEUIPWFDssJpDCKyQJcM4FXowj4Efe6vSEzOtk185jXgKfny96QxO9EQtPEwIB0tsgqJKPYkzaXk7lucehUdesuqs2BsapaiXd)bWjqmLQNLWaWhqmBQNMsbI9UHahL0lYiHPHrWFHs(fUxO96DdbU51jOwlFOWqgrQNLaIv2xOei286euRf4bajEqgaNaXuQEwcdaFaXSPEAkfi27gcCZRJfny8HC0kn96FVqUxO96UxVBiWjMTGnK0GS6WhYrR00RF9c5Efe617gcCIzlydjT3uh(qoALME9Rxi3RREH2RA(rTsyKpA61VEJcCbIv2xOeiMPjJSsVBiae7DdbzQoeqS51XIgmGhaK4j(a4eiMs1Zsya4diMn1ttPaXm0jLA(8Sal6LbL6fAVN6uQNL4muEIossmYarY6fAVmeYIH8LCgkprhj5lIKg4AQ3WhYrR00R)9czGyL9fkbInVoM7aMaEaqIhigaNaXuQEwcdaFaXSPEAkfi(vlLp38K1QJeBQWZPu9SewVq7vSEF1s5ZnVow0GXPu9SewVq717gcCZRtqTw(qHHmIupl1l0ED3R3ne4eZwWgsAVPo8HC0kn96xVIFVq7Ly2c2q8kL2BQtVq717gcC4PCqdwPwPomnlMe(An6Wpv7L61)EJgY42RGqVE3qGdpLdAWk1k1HPzXKWxRrh(PAVuV(DO3OHmU9cTx18JALWiF00RF9gf42RGqVyONRyk8xNK04thhjM6OGj(qoALME9RxCuVcc9QSVqjxXu4VojPXNoosm1rbt8kLbBbw03RREH2Ry9YqilgYxYzQSsgFifdcGyL9fkbInVob1AbEaqIhocaNaXuQEwcdaFaXSPEAkfi27gcCusViJKzjDKNLPqj)c3RGqVE3qGFSsSHWKKdmYhnou(skPbCfvIFH7vqOxVBiWzQSsg)c3l0ED3R3ne4JEsj6AKHHYOcbFihTstV(3lygg3rfxVrzVmQS96Ux18JALWiF00lO7fs42RREH2R3ne4JEsj6AKHHYOcb)c3RGqVI1R3ne4JEsj6AKHHYOcb)c3l0EfRxgczXq(s(ONuIUgzyOmQqWhsXGOxbHEfRxg6KsnF(jLViiMED1RGqVQ5h1kHr(OPx)6nkWTxO9smBbBiELsnHaiwzFHsGyZRJ5oGjGhaK4ffa4eiMs1Zsya4diMn1ttPaXVAP85MxhlAW4uQEwcRxO96UxVBiWnVow0GXVW9ki0RA(rTsyKpA61VEJcC71vVq717gcCZRJfnyCZRSJ96FVqQxO96UxVBiWjMTGnK0GS6WVW9ki0R3ne4eZwWgsAVPo8lCVU6fAVE3qGdpLdAWk1k1HPzXKWxRrh(PAVuV(3B0GyC7fAVU7LHqwmKVKZuzLm(qoALME9Rx8WTxbHEfR3tDk1ZsCgkprhjjgzGiz9cTxg6KsnFEwGf9YGs96ciwzFHsGyZRJ5oGjGhaKrJlaobIPu9Sega(aIzt90ukqS7E9UHahEkh0GvQvQdtZIjHVwJo8t1EPE9V3ObX42RGqVE3qGdpLdAWk1k1HPzXKWxRrh(PAVuV(3B0qg3EH27RwkFU5jRvhj2uHNtP6zjSED1l0E9UHaNy2c2qsdYQdFihTstV(1liUxO9smBbBiELsdYQtVq7vSE9UHahL0lYiHPHrWFHs(fUxO9kwVVAP85MxhlAW4uQEwcRxO9YqilgYxYzQSsgFihTstV(1liUxO96UxgczXq(s(XkXgctAGRPEdFihTstV(1liUxbHEfRxg6KsnF(riMsZEDbeRSVqjqS51XChWeWdaYOXdaNaXuQEwcdaFaXSPEAkfi2DVE3qGtmBbBiP9M6WVW9ki0R7EzI0bmz69qVr3l0EhIjshWK8lhQx)7fY96QxbHEzI0bmz69qVqQxx9cTxfwYerSJ9cT3tDk1ZsCJEsYaAKmvwjdiwzFHsG4K8jDqOe4baz0rdGtGykvplHbGpGy2upnLce7UxVBiWjMTGnK0EtD4x4EH2Ry9YqNuQ5ZpcXuA2RGqVU717gc8JvIneMKCGr(OXHYxsjnGROs8lCVq7LHoPuZNFeIP0Sxx9ki0R7EzI0bmz69qVr3l0EhIjshWK8lhQx)7fY96QxbHEzI0bmz69qVqQxbHE9UHaNPYkz8lCVU6fAVkSKjIyh7fAVN6uQNL4g9KKb0izQSsgqSY(cLaXIuBq6GqjWdaYOHeaobIPu9Sega(aIzt90ukqS7E9UHaNy2c2qs7n1HFH7fAVI1ldDsPMp)ietPzVcc96UxVBiWpwj2qysYbg5JghkFjL0aUIkXVW9cTxg6KsnF(riMsZED1RGqVU7LjshWKP3d9gDVq7DiMiDatYVCOE9Vxi3RREfe6LjshWKP3d9cPEfe617gcCMkRKXVW96QxO9QWsMiIDSxO9EQtPEwIB0tsgqJKPYkzaXk7lucehUwR0bHsGhaKrJ)a4eiwzFHsGyF6mfAKOGKS3KaIPu9Sega(aEaqgnKbWjqmLQNLWaWhqmBQNMsbIjMTGneVsP9M60RGqVeZwWgIBqwDKjjUVxbHEjMTGnextiKjjUVxbHE9UHa3NotHgjkij7nj(fUxO96DdboXSfSHK2BQd)c3RGqVU717gcCMkRKXhYrR00R)9QSVqj33OViojoIDFs(Ld1l0E9UHaNPYkz8lCVUaIv2xOei286eQHaEaqgT4dGtGyL9fkbI9n6lciMs1Zsya4d4baz0GyaCcetP6zjma8beRSVqjq8CtPY(cLsBzEGyBzEzQoeqCqT2x0CbEGhi2dPpaobajEa4eiMs1Zsya4diMn1ttPaXE3qGZuzLm(fgiwzFHsG4rpPeDnYWqzuHa4baz0a4eiMs1Zsya4digbdeBOhiwzFHsG4tDk1ZsaXNQ9saXI1R3ne4EQvtgjrbPATYxuLGnYu)7q8lCVq7vSE9UHa3tTAYijkivRv(IQeSrQdttIFHbIp1rMQdbeZM6t0FHbEaqcjaCcetP6zjma8beRSVqjqSIPWFDssJpDCaIzt90ukqS3ne4EQvtgjrbPATYxuLGnYu)7qCZRSJYt1EPE9Vx8h3EH2R3ne4EQvtgjrbPATYxuLGnsDyAsCZRSJYt1EPE9Vx8h3EH2R7EfRxm0Zvmf(RtsA8PJJetDuWe)l2Xkb3l0EfRxL9fk5kMc)1jjn(0XrIPokyIxPmylWI(EH2R7EfRxm0Zvmf(RtsA8PJJuePw(xSJvcUxbHEXqpxXu4VojPXNoosrKA5d5OvA61VEHuVU6vqOxm0Zvmf(RtsA8PJJetDuWe38k7yV(3lK6fAVyONRyk8xNK04thhjM6OGj(qoALME9Vxi3l0EXqpxXu4VojPXNoosm1rbt8VyhReCVUaIzqWSK81bm9gaqIhWdas8haNaXuQEwcdaFaXSPEAkfi2DVN6uQNL4muEIossmYarY6fAVI1ldHSyiFjNPYkz8Humi6vqOxVBiWzQSsg)c3RREH2R7E9UHa3tTAYijkivRv(IQeSrM6FhIBELDuEQ2l17HEHmU9ki0R3ne4EQvtgjrbPATYxuLGnsDyAsCZRSJYt1EPEp0lKXTxx9ki0BOal6Ld5OvA61)EXdxGyL9fkbIzO8eDKKVisAGRPEdWdasidGtGykvplHbGpGy2upnLce7UxVBiW9uRMmsIcs1ALVOkbBKP(3H4d5OvA61VEXFoK7vqOxVBiW9uRMmsIcs1ALVOkbBK6W0K4d5OvA61VEXFoK71vVq7vn)OwjmYhn963HEJcC7fAVU7LHqwmKVKZuzLm(qoALME9RxqCVcc96UxgczXq(so5aJ8rJ0dLy8HC0kn96xVG4EH2Ry96Ddb(XkXgctsoWiF04q5lPKgWvuj(fUxO9YqNuQ5ZpcXuA2RREDbeRSVqjqmttgzLE3qai27gcYuDiGyZRJfnyapaifFaCcetP6zjma8beZM6PPuGyX69uNs9SeNn1NO)c3l0ED3ldDsPMpplWIEzqPEfe6LHqwmKVKZuzLm(qoALME9RxqCVcc96UxgczXq(so5aJ8rJ0dLy8HC0kn96xVG4EH2Ry96Ddb(XkXgctsoWiF04q5lPKgWvuj(fUxO9YqNuQ5ZpcXuA2RREDbeRSVqjqS51XChWeWdasqmaobIPu9Sega(aIzt90ukqS7EziKfd5l5muEIosYxejnW1uVHpKJwPPx)7fY9cTx39EQtPEwIZq5j6ijXidejRxbHEziKfd5l5mvwjJpKJwPPx)7fY96Qxx9cTx18JALWiF00RF9I)42l0EzOtk185zbw0ldkbeRSVqjqS51XChWeWdasCeaobIPu9Sega(aIv2xOei2CZqneqmBQNMsbIhkmKrK6zPEH27Rdy65F5qYhjXkQx)6fpXVxO96UxfwYerSJ9cTx39EQtPEwIZM6t0FH7vqOx39QMFuReg5JME9VxiHBVq7vSE9UHaNPYkz8lCVU6vqOxgczXq(sotLvY4dPyq0RREDbeZGGzj5Rdy6naGepGhaKrbaobIPu9Sega(aIv2xOei2bHYqneqmBQNMsbIhkmKrK6zPEH27Rdy65F5qYhjXkQx)6fpiXHCVq71DVkSKjIyh7fAVU79uNs9SeNn1NO)c3RGqVU7vn)OwjmYhn96FVqc3EH2Ry96DdbotLvY4x4ED1RGqVmeYIH8LCMkRKXhsXGOxx9cTxX617gc8JvIneMKCGr(OXHYxsjnGROs8lCVUaIzqWSK81bm9gaqIhWdas8WfaNaXuQEwcdaFaXk7luceBEYA1rgS6qaXSPEAkfiEOWqgrQNL6fAVVoGPN)LdjFKeROE9Rx8e)EJO3HC0kn9cTx39QWsMiIDSxO96U3tDk1ZsC2uFI(lCVcc9QMFuReg5JME9VxiHBVcc9YqilgYxYzQSsgFifdIED1RlGygemljFDatVbaK4b8aGep8aWjqmLQNLWaWhqmBQNMsbIvyjteXoceRSVqjqCanmsIcYu)7qapaiXlAaCcetP6zjma8beZM6PPuGy39smBbBiELsnHOxbHEjMTGne3GS6iRuIxVcc9smBbBiU9M6iRuIxVU6fAVU7vSEzOtk185zbw0ldk1RGqVU7vn)OwjmYhn96FVrbK7fAVU79uNs9SeNn1NO)c3RGqVQ5h1kHr(OPx)7fs42RGqVN6uQNL4LrQiQxx9cTx39EQtPEwIZq5j6ijXidejRxO9kwVmeYIH8LCgkprhj5lIKg4AQ3WVW9ki0Ry9EQtPEwIZq5j6ijXidejRxO9kwVmeYIH8LCMkRKXVW96Qxx96QxO96UxgczXq(sotLvY4d5OvA61VEHeU9ki0RA(rTsyKpA61VEJcC7fAVmeYIH8LCMkRKXVW9cTx39YqilgYxYjhyKpAKEOeJpKJwPPx)7vzFHsU51judXjXrS7tYVCOEfe6vSEzOtk185hHykn71vVcc9w5tdmYQpHjdfyrVCihTstV(3lE42RREH2R7EXqpxXu4VojPXNoosm1rbt8HC0kn96xV4FVcc9kwVm0jLA(8KydYIgSEDbeRSVqjqC4oqirbjzVjb8aGepibGtGykvplHbGpGy2upnLce7UxIzlydXT3uhzsI77vqOxIzlydXniRoYKe33RGqVeZwWgIRjeYKe33RGqVE3qG7PwnzKefKQ1kFrvc2it9VdXhYrR00RF9I)Ci3RGqVE3qG7PwnzKefKQ1kFrvc2i1HPjXhYrR00RF9I)Ci3RGqVQ5h1kHr(OPx)6nkWTxO9YqilgYxYzQSsgFifdIED1l0ED3ldHSyiFjNPYkz8HC0kn96xVqc3Efe6LHqwmKVKZuzLm(qkge96QxbHER8Pbgz1NWKHcSOxoKJwPPx)7fpCbIv2xOei(yLydHjnW1uVb4bajE4paobIPu9Sega(aIzt90ukqS7EvZpQvcJ8rtV(1BuGBVq71DVE3qGFSsSHWKKdmYhnou(skPbCfvIFH7vqOxX6LHoPuZNFeIP0Sxx9ki0ldDsPMpplWIEzqPEfe617gcCplcHzVMNFH7fAVE3qG7zrim7188HC0kn96FVrJBVr0R7EzOe7wphEiwziPAlWPdLp)lhsEQ2l1RRED1l0ED37PoL6zjodLNOJKeJmqKSEfe6LHqwmKVKZq5j6ijFrK0axt9g(qkge96QxbHER8Pbgz1NWKHcSOxoKJwPPx)7nAC7nIED3ldLy365WdXkdjvBboDO85F5qYt1EPEDbeRSVqjqmJSK5l1kvBboDO8bEaqIhKbWjqmLQNLWaWhqmBQNMsbID3RA(rTsyKpA61VEJcC7fAVU717gc8JvIneMKCGr(OXHYxsjnGROs8lCVcc9kwVm0jLA(8JqmLM96QxbHEzOtk185zbw0ldk1RGqVE3qG7zrim7188lCVq717gcCplcHzVMNpKJwPPx)7fs42Be96UxgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9s96Qxx9cTx39EQtPEwIZq5j6ijXidejRxbHEziKfd5l5muEIosYxejnW1uVHpKIbrVU6vqO3kFAGrw9jmzOal6Ld5OvA61)EHeU9grVU7LHsSB9C4HyLHKQTaNou(8VCi5PAVuVUaIv2xOeiUsMoP(fkbEaqIN4dGtGykvplHbGpGyemqSHEGyL9fkbIp1PuplbeFQ2lbetmBbBiELs7n1P3OSxCuVGUxL9fk5MxNqneNehXUpj)YH6nIEfRxIzlydXRuAVPo9gL9k(9c6Ev2xOK7B0xeNehXUpj)YH6nIEXLhDVGUxdmzTsrQ5jG4tDKP6qaXQbgeqAIjgWdas8aXa4eiMs1Zsya4diMn1ttPaXU7TYNgyKvFctgkWIE5qoALME9Vx8VxbHED3R3ne4JEsj6AKHHYOcbFihTstV(3lygg3rfxVrzVmQS96Ux18JALWiF00lO7fs42RREH2R3ne4JEsj6AKHHYOcb)c3RRED1RGqVU7vn)OwjmYhn9grVN6uQNL4QbgeqAIjwVrzVE3qGtmBbBiPbz1HpKJwPP3i6fd98WDGqIcsYEtI)f7OroKJwzVrzVrZHCV(1lErJBVcc9QMFuReg5JMEJO3tDk1ZsC1adcinXeR3OSxVBiWjMTGnK0EtD4d5OvA6nIEXqppChiKOGKS3K4FXoAKd5Ov2Bu2B0Ci3RF9Ix042RREH2lXSfSH4vk1eIEH2R7ED3Ry9YqilgYxYzQSsg)c3RGqVm0jLA(8JqmLM9cTxX6LHqwmKVKtoWiF0i9qjg)c3RREfe6LHoPuZNNfyrVmOuVU6fAVU7vSEzOtk185Nu(IGy6vqOxX617gcCMkRKXVW9ki0RA(rTsyKpA61VEJcC71vVcc96DdbotLvY4d5OvA61VEXr9cTxX617gc8rpPeDnYWqzuHGFHbIv2xOei286yUdyc4bajE4iaCcetP6zjma8beZM6PPuGy396DdboXSfSHK2BQd)c3RGqVU7LjshWKP3d9gDVq7DiMiDatYVCOE9Vxi3RREfe6LjshWKP3d9cPED1l0EvyjteXoceRSVqjqCs(Koiuc8aGeVOaaNaXuQEwcdaFaXSPEAkfi2DVE3qGtmBbBiP9M6WVW9ki0R7EzI0bmz69qVr3l0EhIjshWK8lhQx)7fY96QxbHEzI0bmz69qVqQxx9cTxfwYerSJaXk7lucelsTbPdcLapaiJgxaCcetP6zjma8beZM6PPuGy396DdboXSfSHK2BQd)c3RGqVU7LjshWKP3d9gDVq7DiMiDatYVCOE9Vxi3RREfe6LjshWKP3d9cPED1l0EvyjteXoceRSVqjqC4ATshekbEaqgnEa4eiwzFHsGyF6mfAKOGKS3KaIPu9Sega(aEaqgD0a4eiMs1Zsya4diMn1ttPaXeZwWgIxP0EtD6vqOxIzlydXniRoYKe33RGqVeZwWgIRjeYKe33RGqVE3qG7tNPqJefKK9Me)c3l0EjMTGneVsP9M60RGqVU717gcCMkRKXhYrR00R)9QSVqj33OViojoIDFs(Ld1l0E9UHaNPYkz8lCVUaIv2xOei286eQHaEaqgnKaWjqSY(cLaX(g9fbetP6zjma8b8aGmA8haNaXuQEwcdaFaXk7lucep3uQSVqP0wMhi2wMxMQdbehuR9fnxGh4bEG4tAmfkbaz04gnU4fnUIpqSpDYkbBaIbbdcchpiXXbsqGep92lofr9woWO57nGMEfVydPoEvIrJ4T3Har3AiSEnihQx9(ih9jSEzI0emz4DK4GkPEJw80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61nEIZfVJehuj1lE4jE6feIYtAEcR34Ybe2RbI8vX1l(HF9(OEXbxTxhe21En9IGPrF00RB8ZvVUXtCU4DK4GkPEXlAXtVGquEsZty9gxoGWEnqKVkUEXp8R3h1lo4Q96GWU2RPxemn6JMEDJFU61nEIZfVJehuj1lEqw80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61nEIZfVJSJeemiiC8Gehhibbs80BV4ue1B5aJMV3aA6v8Irb9AFXBVdbIU1qy9AqouV69ro6ty9YePjyYW7iXbvs9k(INEbHO8KMNW6nUCaH9AGiFvC9IF9(OEXbxTxS6Smfk7fbtJ(OPx3G2vVUJwCU4DKDKGGbbHJhK44ajiqINE7fNIOElhy089gqtVIx4Hyihp9fV9oei6wdH1Rb5q9Q3h5OpH1ltKMGjdVJehuj1lKfp9ccr5jnpH1R4DUjfqdyIdcS4T3h1R4DUjfqdyIdcmNs1ZsyI3EDJN4CX7iXbvs9k(INEbHO8KMNW6v8o3KcObmXbbw827J6v8o3KcObmXbbMtP6zjmXBVUXtCU4DKDKGGbbHJhK44ajiqINE7fNIOElhy089gqtVIxfrI3EhceDRHW61GCOE17JC0NW6LjstWKH3rIdQK6nAXtVGquEsZty9kENBsb0aM4GalE79r9kENBsb0aM4GaZPu9SeM4Tx34jox8osCqLuVqs80lieLN08ewVXLdiSxde5RIRx8d)69r9IdUAVoiSR9A6fbtJ(OPx34NREDJN4CX7iXbvs9czXtVGquEsZty9gxoGWEnqKVkUEXVEFuV4GR2lwDwMcL9IGPrF00RBq7Qx34jox8osCqLuVrH4PxqikpP5jSEJlhqyVgiYxfxV4xVpQxCWv7fRoltHYErW0OpA61nOD1RB8eNlEhjoOsQx8GK4PxqikpP5jSEJlhqyVgiYxfxV4h(17J6fhC1EDqyx710lcMg9rtVUXpx96gpX5I3rIdQK6fpCK4PxqikpP5jSEJlhqyVgiYxfxV4xVpQxCWv7fRoltHYErW0OpA61nOD1RB8eNlEhjoOsQ3OXv80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61nEIZfVJehuj1B0qw80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61D0IZfVJSJeemiiC8Gehhibbs80BV4ue1B5aJMV3aA6v8AEXBVdbIU1qy9AqouV69ro6ty9YePjyYW7iXbvs9IhUINEbHO8KMNW6nUCaH9AGiFvC9IF4xVpQxCWv71bHDTxtViyA0hn96g)C1RB8eNlEhjoOsQx8Wt80lieLN08ewVXLdiSxde5RIRx8d)69r9IdUAVoiSR9A6fbtJ(OPx34NREDJN4CX7iXbvs9Ihos80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61nEIZfVJSJeemiiC8Gehhibbs80BV4ue1B5aJMV3aA6v86H0x827qGOBnewVgKd1REFKJ(ewVmrAcMm8osCqLuV4j(INEbHO8KMNW6nUCaH9AGiFvC9IF9(OEXbxTxS6Smfk7fbtJ(OPx3G2vVUHK4CX7iXbvs9Ihiw80lieLN08ewVXLdiSxde5RIRx8R3h1lo4Q9IvNLPqzViyA0hn96g0U61nEIZfVJSJehNdmAEcRxqCVk7lu2RTmVH3rcedpOqzjGyCSEXNA1Kr9ccG5wyDK4y9ccaIroE00ligu9gnUrJBhzhjowVGqrAcMmINosCSEXH9cccdJW6ngz1Px8rQdVJehRxCyVGqrAcMW691bm9Yk0ltnKP3h1ldcMLKVoGP3W7iXX6fh2loEYbDsy9EZKyKXOde9EQtPEwY0R7ItCq1l8qNsZRJ5oGPEXH(1l8qNCZRJ5oGjx8osCSEXH9cc6evy9cpetnFLG7fe8OVOERqV1lEn9(IOE9nOeCVGaKzlydX7i7iv2xO0WHhIHC80)GdcLhRugqJthPY(cLgo8qmKJN(rCa0hReBimPbUM6nDKk7luA4WdXqoE6hXbq7B0xeOSvssg2b8Wfuv4GBIzlydXT3uhzsI7feiMTGneVsP9M6iiqmBbBiELsp0lsqGy2c2qCnHqMK4ExDKk7luA4WdXqoE6hXbq7B0xeOQWb3eZwWgIBVPoYKe3liqmBbBiELs7n1rqGy2c2q8kLEOxKGaXSfSH4AcHmjX9UGcp0jhpUVrFrqfdEOtE0CFJ(I6iv2xO0WHhIHC80pIdG286eQHavfoi2CtkGgWe3tTAYijkivRv(IQeSrqqmg6KsnFEwGf9YGsccIzGjRv(6aMEd386euR9aEDKk7luA4WdXqoE6hXbqBEDm3bmbQkCyUjfqdyI7PwnzKefKQ1kFrvc2aLHoPuZNNfyrVmOeudmzTYxhW0B4MxNGAThWRJSJehRxqakoIDFcRx6Kgi69lhQ3xe1RYE00Bz6vp1YQEwI3rQSVqP5Gbz1r6rQthPY(cLMdN6uQNLavQo0HYivebQt1EPdgyYALVoGP3WnVob1A9dpOUf7vlLp386yrdgNs1ZsyccVAP85MNSwDKytfEoLQNLWCjiyGjRv(6aMEd386euR1VO7iv2xO0eXbqFQtPEwcuP6qhkJKzj9Ka1PAV0bdmzTYxhW0B4MxNqnKF41rQSVqPjIdG2JgdnhRemOQWb3IXqNuQ5ZZcSOxgusqqmgczXq(sodLNOJK8frsdCn1B4xyxq9UHaNPYkz8lChPY(cLMioaAy0xOeuv4G3ne4mvwjJFH7iv2xO0eXbqFQtPEwcuP6qhyO8eDKKyKbIKbQt1EPdblcnUDx5tdmYQpHjdfyrVCihTsdomACXHmeYIH8LCgkprhj5lIKg4AQ3WhYrR04c)WlACD5xWIqJB3v(0aJS6tyYqbw0lhYrR0GdJgY4q34HBu(QLYNxjtNu)cLCkvplH5ch6MHsSB9C4HyLHKQTaNou(8VCi5PAVKlCidHSyiFjNPYkz8HC0knUWp8Wr46sqGHqwmKVKZuzLm(qoALg)Q8Pbgz1NWKHcSOxoKJwPrqGHqwmKVKZq5j6ijFrK0axt9g(qoALg)Q8Pbgz1NWKHcSOxoKJwPrqqmg6KsnFEwGf9YGsDKk7luAI4aOVgswp5aQuDOdvAyZ9vpljbrxn)RJeJolgbQkCW7gcCMkRKXVWDK4y9QSVqPjIdG(Aiz9KJbugl6nh(PYJ0JhOQWbX(PYJ0ZXJlsns4bX4Acbu3I9tLhPNhnxKAKWdIX1ecbbX(PYJ0ZJMpKIbHKHqwmKV0LGG3ne4mvwjJFHfeyiKfd5l5mvwjJpKJwPbhIhU(9tLhPNJhNHqwmKVKJDh9lucvmg6KsnF(riMstbbg6KsnFEwGf9YGsqp1PuplXzO8eDKKyKbIKbLHqwmKVKZq5j6ijFrK0axt9g(fwqW7gc8JvIneMKCGr(OXHYxsjnGROs8lSGqOal6Ld5OvA8pAC7iXX6vzFHsteha91qY6jhdOmw0Bo8tLhPpAqvHdI9tLhPNhnxKAKWdIX1ecOUf7NkpsphpUi1iHheJRjeccI9tLhPNJhFifdcjdHSyiFPlbHFQ8i9C84IuJeEqmUMqa9NkpsppAUi1iHheJRjeqf7Nkpsphp(qkgesgczXq(sbbVBiWzQSsg)cliWqilgYxYzQSsgFihTsdoepC97NkpsppAodHSyiFjh7o6xOeQym0jLA(8JqmLMccm0jLA(8Sal6LbLGEQtPEwIZq5j6ijXidejdkdHSyiFjNHYt0rs(IiPbUM6n8lSGG3ne4hReBimj5aJ8rJdLVKsAaxrL4xybHqbw0lhYrR04F042r2rQSVqPjIdG(Aiz9KJPJuzFHsteha9CtPY(cLsBzEqLQdDqreOm)uS)aEGQcho1PuplXlJuruhPY(cLMioa65MsL9fkL2Y8Gkvh6a2qQJxLy0akZpf7pGhOQWH5MuanGj(xoKp0KsSHuhVkXOHtGOBbdtyDKk7luAI4aONBkv2xOuAlZdQuDOdEi9bL5NI9hWduv4WCtkGgWe3tTAYijkivRv(IQeSHtGOBbdtyDKk7luAI4aONBkv2xOuAlZdQuDOdMVJSJuzFHsdxr0HtDk1ZsGkvh6a2qQJ0xzTYGATsuiaQt1EPdU9UHa)lhYhAsj2qQJxLy0WhYrR04pygg3rfxe4YXtqW7gc8VCiFOjLydPoEvIrdFihTsJ)k7luYnVoHAiojoIDFs(LdfbUC8G6My2c2q8kL2BQJGaXSfSH4gKvhzsI7feiMTGnextiKjjU3LlOE3qG)Ld5dnPeBi1XRsmA4xyOZnPaAat8VCiFOjLydPoEvIrdNar3cgMW6iv2xO0WvefXbqZq5j6ijFrK0axt9gqvHdUp1PuplXzO8eDKKyKbIKbvmgczXq(sotLvY4dPyqii4DdbotLvY4xyxqvZpQvcJ8rJ)qgxOU9UHaNy2c2qs7n1HpKJwPXpXxqW7gcCIzlydjniRo8HC0kn(j(UG6wS5MuanGjUNA1KrsuqQwR8fvjyJGG3ne4EQvtgjrbPATYxuLGnYu)7qCZRSJYt1Ej)GeUccE3qG7PwnzKefKQ1kFrvc2i1HPjXnVYokpv7L8ds46sqiuGf9YHC0kn(JhUDKk7luA4kII4aOnVob1Abvfo4DdbU51jOwlFOWqgrQNLG62atwR81bm9gU51jOwR)qsqqS5MuanGj(xoKp0KsSHuhVkXOHtGOBbdtyUG6wS5MuanGjUfcMoQrgSe9vcwc2woWgItGOBbdtyccF5q4h(H)q2pVBiWnVob1A5d5OvAIiAxDKk7luA4kII4aOnVob1Abvfom3KcObmX)YH8HMuInK64vjgnCceDlyycdQbMSw5Rdy6nCZRtqTw)oajOUfZ7gc8VCiFOjLydPoEvIrd)cd17gcCZRtqTw(qHHmIuplji4(uNs9SehBi1r6RSwzqTwjkeG627gcCZRtqTw(qoALg)HKGGbMSw5Rdy6nCZRtqTw)Ig6RwkFU5jRvhj2uHNtP6zjmOE3qGBEDcQ1YhYrR04pKD5YvhPY(cLgUIOioa6tDk1ZsGkvh6G51jOwR0hkFzqTwjkea1PAV0b18JALWiF04hocxCOB8Wnk9UHa)lhYhAsj2qQJxLy0WnVYo6ch627gcCZRtqTw(qoALMOes4NbMSwPi18KlCOBm0Zd3bcjkij7nj(qoALMOeYUG6DdbU51jOwl)c3rQSVqPHRikIdG286yUdycuv4WPoL6zjo2qQJ0xzTYGATsuia9uNs9Se386euRv6dLVmOwRefcccU9UHa3tTAYijkivRv(IQeSrM6FhIBELDuEQ2l5hKWvqW7gcCp1QjJKOGuTw5lQsWgPomnjU5v2r5PAVKFqcxxqnWK1kFDatVHBEDcQ16p(3rQSVqPHRikIdG2CZqneOyqWSK81bm9Md4bQkCyOWqgrQNLG(6aME(xoK8rsSI8dp8hhAGjRv(6aMEted5OvAGQWsMiIDekXSfSH4vk1eIosL9fknCfrrCa0kMc)1jjn(0Xbumiyws(6aMEZb8avfoi2xSJvcgQyk7luYvmf(RtsA8PJJetDuWeVszWwGf9ccyONRyk8xNK04thhjM6OGjU5v2r)Heum0Zvmf(RtsA8PJJetDuWeFihTsJ)qQJuzFHsdxruehaTdcLHAiqXGGzj5Rdy6nhWduv4WqHHmIuplb91bm98VCi5JKyf5NB8W)iCBGjRv(6aMEd386eQHIs84q2Ll8ZatwR81bm9MigYrR0a1ndHSyiFjNPYkz8HumiG6(uNs9SeNHYt0rsIrgisMGadHSyiFjNHYt0rs(IiPbUM6n8HumieeeJHoPuZNNfyrVmOKlbbdmzTYxhW0B4MxNqnK)UX)O0nEr8QLYN)(Qu6GqPHtP6zjmxUeeCtmBbBiELsdYQJGGBIzlydXRu6HErcceZwWgIxP0EtDCbvSxTu(Cd6ALOG8frYaAiZZPu9SeMGG3ne4Wt5GgSsTsDyAwmj81A0HFQ2l53HOHmUUG62atwR81bm9gU51jud5pE4gLUXlIxTu(83xLsheknCkvplH5Yfu18JALWiF04hKXfh6DdbU51jOwlFihTstuk(UG6wmVBiWpwj2qysYbg5JghkFjL0aUIkXVWcceZwWgIxP0GS6iiigdDsPMp)ietPPlOkSKjIyh7iv2xO0WvefXbqhqdJKOGm1)oeOQWbfwYerSJDKk7luA4kII4aOh9Ks01iddLrfcqvHdE3qGZuzLm(fUJuzFHsdxruehanJSK5l1kvBboDO8bvfo427gcCZRtqTw(fwqqn)OwjmYhn(bzCDbvmVBiWniR5lgXVWqfZ7gcCMkRKXVWqDlgdDsPMpplWIEzqjbHtDk1ZsCgkprhjjgzGizccmeYIH8LCgkprhj5lIKg4AQ3WVWccv(0aJS6tyYqbw0lhYrR04F04gHBgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9sUC1rQSVqPHRikIdGUsMoP(fkbvfo427gcCZRtqTw(fwqqn)OwjmYhn(bzCDbvmVBiWniR5lgXVWqfZ7gcCMkRKXVWqDlgdDsPMpplWIEzqjbHtDk1ZsCgkprhjjgzGizccmeYIH8LCgkprhj5lIKg4AQ3WVWccv(0aJS6tyYqbw0lhYrR04pdHSyiFjNHYt0rs(IiPbUM6n8HC0knri(ccv(0aJS6tyYqbw0lhYrR0GF4hE4iC9hs4gHBgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9sUC1rQSVqPHRikIdGMCGr(Or6HsmqvHdv(0aJS6tyYqbw0lhYrR04pEqwqWT3ne4Wt5GgSsTsDyAwmj81A0HFQ2l5F0qgxbbVBiWHNYbnyLAL6W0Sys4R1Od)uTxYVdrdzCDb17gcCZRtqTw(fgkdHSyiFjNPYkz8HC0kn(bzC7iv2xO0WvefXbqBEYA1rgS6qGIbbZsYxhW0BoGhOQWHHcdzePEwc6xoK8rsSI8dpid1atwR81bm9gU51jud5p(dvHLmre7iu3E3qGZuzLm(qoALg)WdxbbX8UHaNPYkz8lSRosL9fknCfrrCa0H7aHefKK9MeOQWbIzlydXRuQjeqvyjteXoc17gcC4PCqdwPwPomnlMe(An6Wpv7L8pAiJlu3yONRyk8xNK04thhjM6OGj(xSJvcwqqmg6KsnFEsSbzrdMGGbMSw5Rdy6n(fTRosL9fknCfrrCa0MxNGATGQch8UHahL0lYiHPHrWFHs(fgQBVBiWnVob1A5dfgYis9SKGGA(rTsyKpA8lkW1vhPY(cLgUIOioaAZRtqTwqvHdm0jLA(8Sal6LbLG6(uNs9SeNHYt0rsIrgisMGadHSyiFjNPYkz8lSGG3ne4mvwjJFHDbLHqwmKVKZq5j6ijFrK0axt9g(qoALg)bZW4oQ4Isgvw3Q5h1kHr(Ob)GmUUG6DdbU51jOwlFihTsJ)4FhPY(cLgUIOioaAZRJ5oGjqvHdm0jLA(8Sal6LbLG6(uNs9SeNHYt0rsIrgisMGadHSyiFjNPYkz8lSGG3ne4mvwjJFHDbLHqwmKVKZq5j6ijFrK0axt9g(qoALg)fFOE3qGBEDcQ1YVWqjMTGneVsPMq0rQSVqPHRikIdG286yUdycuv4G3ne4OKErgjZs6ipltHs(fwqWTyMxNqnexHLmre7OGGBVBiWzQSsgFihTsJ)qgQ3ne4mvwjJFHfeC7Ddb(ONuIUgzyOmQqWhYrR04pygg3rfxuYOY6wn)OwjmYhn4hKW1fuVBiWh9Ks01iddLrfc(f2LlON6uQNL4MxNGATsFO8Lb1ALOqaQbMSw5Rdy6nCZRtqTw)HKlOUfBUjfqdyI)Ld5dnPeBi1XRsmA4ei6wWWeMGGbMSw5Rdy6nCZRtqTw)HKRosL9fknCfrrCa0j5t6GqjOQWb3eZwWgIxPutiGYqilgYxYzQSsgFihTsJFqgxbb3mr6aMmhIg6qmr6aMKF5q(dzxccmr6aMmhGKlOkSKjIyh7iv2xO0WvefXbqlsTbPdcLGQchCtmBbBiELsnHakdHSyiFjNPYkz8HC0kn(bzCfeCZePdyYCiAOdXePdys(Ld5pKDjiWePdyYCasUGQWsMiIDSJuzFHsdxruehaD4ATshekbvfo4My2c2q8kLAcbugczXq(sotLvY4d5OvA8dY4ki4MjshWK5q0qhIjshWK8lhYFi7sqGjshWK5aKCbvHLmre7yhPY(cLgUIOioaAF6mfAKOGKS3K6iv2xO0WvefXbqFQtPEwcuP6qhmVoHAizLsdYQdOov7LoyGjRv(6aMEd386eQH8d)JiyrOXTJAEAGqEQ2lHFrJRRicweAC7DdbU51XChWKKCGr(OXHYxAqwD4MxzhXp83vhPY(cLgUIOioaAFJ(IavfoqmBbBiU9M6itsCVGaXSfSH4AcHmjX9qp1PuplXlJKzj9Kee8UHaNy2c2qsdYQdFihTsJ)k7luYnVoHAiojoIDFs(Ldb17gcCIzlydjniRo8lSGaXSfSH4vkniRoqf7uNs9Se386eQHKvkniRoccE3qGZuzLm(qoALg)v2xOKBEDc1qCsCe7(K8lhcQyN6uQNL4LrYSKEsq9UHaNPYkz8HC0kn(tIJy3NKF5qq9UHaNPYkz8lSGG3ne4JEsj6AKHHYOcb)cd1atwRuKAEYpC5Ipu3gyYALVoGP34)bijii2RwkFUbDTsuq(IizanK55uQEwcZLGGyN6uQNL4LrYSKEsq9UHaNPYkz8HC0kn(rIJy3NKF5qDKk7luA4kII4aOnVoHAOosL9fknCfrrCa0ZnLk7lukTL5bvQo0HGATVO52r2rQSVqPH7H0)WONuIUgzyOmQqaQkCW7gcCMkRKXVWDKk7luA4Ei9J4aOp1PuplbQuDOdSP(e9xyqDQ2lDqmVBiW9uRMmsIcs1ALVOkbBKP(3H4xyOI5DdbUNA1KrsuqQwR8fvjyJuhMMe)c3rQSVqPH7H0pIdGwXu4VojPXNooGIbbZsYxhW0BoGhOQWbVBiW9uRMmsIcs1ALVOkbBKP(3H4MxzhLNQ9s(J)4c17gcCp1QjJKOGuTw5lQsWgPomnjU5v2r5PAVK)4pUqDlgg65kMc)1jjn(0XrIPokyI)f7yLGHkMY(cLCftH)6KKgF64iXuhfmXRugSfyrpu3IHHEUIPWFDssJpDCKIi1Y)IDSsWccyONRyk8xNK04thhPisT8HC0kn(bjxccyONRyk8xNK04thhjM6OGjU5v2r)Heum0Zvmf(RtsA8PJJetDuWeFihTsJ)qgkg65kMc)1jjn(0XrIPokyI)f7yLGD1rQSVqPH7H0pIdGMHYt0rs(IiPbUM6nGQchCFQtPEwIZq5j6ijXidejdQymeYIH8LCMkRKXhsXGqqW7gcCMkRKXVWUG627gcCp1QjJKOGuTw5lQsWgzQ)DiU5v2r5PAV0biJRGG3ne4EQvtgjrbPATYxuLGnsDyAsCZRSJYt1EPdqgxxccHcSOxoKJwPXF8WTJuzFHsd3dPFehanttgzLE3qauP6qhmVow0GbQkCWT3ne4EQvtgjrbPATYxuLGnYu)7q8HC0kn(H)Cili4DdbUNA1KrsuqQwR8fvjyJuhMMeFihTsJF4phYUGQMFuReg5Jg)oef4c1ndHSyiFjNPYkz8HC0kn(bIfeCZqilgYxYjhyKpAKEOeJpKJwPXpqmuX8UHa)yLydHjjhyKpACO8Lusd4kQe)cdLHoPuZNFeIP00LRosL9fknCpK(rCa0MxhZDatGQche7uNs9SeNn1NO)cd1ndDsPMpplWIEzqjbbgczXq(sotLvY4d5OvA8deli4MHqwmKVKtoWiF0i9qjgFihTsJFGyOI5Ddb(XkXgctsoWiF04q5lPKgWvuj(fgkdDsPMp)ietPPlxDKk7luA4Ei9J4aOnVoM7aMavfo4MHqwmKVKZq5j6ijFrK0axt9g(qoALg)Hmu3N6uQNL4muEIossmYarYeeyiKfd5l5mvwjJpKJwPXFi7Yfu18JALWiF04h(Jlug6KsnFEwGf9YGsDKk7luA4Ei9J4aOn3mudbkgemljFDatV5aEGQchgkmKrK6zjOVoGPN)LdjFKeRi)Wt8H6wHLmre7iu3N6uQNL4SP(e9xybb3Q5h1kHr(OXFiHluX8UHaNPYkz8lSlbbgczXq(sotLvY4dPyq4YvhPY(cLgUhs)ioaAhekd1qGIbbZsYxhW0BoGhOQWHHcdzePEwc6Rdy65F5qYhjXkYp8GehYqDRWsMiIDeQ7tDk1ZsC2uFI(lSGGB18JALWiF04pKWfQyE3qGZuzLm(f2LGadHSyiFjNPYkz8HumiCbvmVBiWpwj2qysYbg5JghkFjL0aUIkXVWU6iv2xO0W9q6hXbqBEYA1rgS6qGIbbZsYxhW0BoGhOQWHHcdzePEwc6Rdy65F5qYhjXkYp8e)igYrR0a1TclzIi2rOUp1PuplXzt9j6VWccQ5h1kHr(OXFiHRGadHSyiFjNPYkz8HumiC5QJuzFHsd3dPFehaDanmsIcYu)7qGQchuyjteXo2rQSVqPH7H0pIdGoChiKOGKS3Kavfo4My2c2q8kLAcHGaXSfSH4gKvhzLs8eeiMTGne3EtDKvkXZfu3IXqNuQ5ZZcSOxgusqWTA(rTsyKpA8pkGmu3N6uQNL4SP(e9xybb18JALWiF04pKWvq4uNs9SeVmsfrUG6(uNs9SeNHYt0rsIrgisguXyiKfd5l5muEIosYxejnW1uVHFHfee7uNs9SeNHYt0rsIrgisguXyiKfd5l5mvwjJFHD5Yfu3meYIH8LCMkRKXhYrR04hKWvqqn)OwjmYhn(ff4cLHqwmKVKZuzLm(fgQBgczXq(so5aJ8rJ0dLy8HC0kn(RSVqj386eQH4K4i29j5xoKGGym0jLA(8JqmLMUeeQ8Pbgz1NWKHcSOxoKJwPXF8W1fu3yONRyk8xNK04thhjM6OGj(qoALg)WFbbXyOtk185jXgKfnyU6iv2xO0W9q6hXbqFSsSHWKg4AQ3aQkCWnXSfSH42BQJmjX9cceZwWgIBqwDKjjUxqGy2c2qCnHqMK4EbbVBiW9uRMmsIcs1ALVOkbBKP(3H4d5OvA8d)5qwqW7gcCp1QjJKOGuTw5lQsWgPomnj(qoALg)WFoKfeuZpQvcJ8rJFrbUqziKfd5l5mvwjJpKIbHlOUziKfd5l5mvwjJpKJwPXpiHRGadHSyiFjNPYkz8HumiCjiu5tdmYQpHjdfyrVCihTsJ)4HBhPY(cLgUhs)ioaAgzjZxQvQ2cC6q5dQkCWTA(rTsyKpA8lkWfQBVBiWpwj2qysYbg5JghkFjL0aUIkXVWccIXqNuQ5ZpcXuA6sqGHoPuZNNfyrVmOKGG3ne4EwecZEnp)cd17gcCplcHzVMNpKJwPX)OXnc3muIDRNdpeRmKuTf40HYN)Ldjpv7LC5cQ7tDk1ZsCgkprhjjgzGizccmeYIH8LCgkprhj5lIKg4AQ3WhsXGWLGqLpnWiR(eMmuGf9YHC0kn(hnUr4MHsSB9C4HyLHKQTaNou(8VCi5PAVKRosL9fknCpK(rCa0vY0j1VqjOQWb3Q5h1kHr(OXVOaxOU9UHa)yLydHjjhyKpACO8Lusd4kQe)cliigdDsPMp)ietPPlbbg6KsnFEwGf9YGsccE3qG7zrim7188lmuVBiW9SieM9AE(qoALg)HeUr4MHsSB9C4HyLHKQTaNou(8VCi5PAVKlxqDFQtPEwIZq5j6ijXidejtqGHqwmKVKZq5j6ijFrK0axt9g(qkgeUeeQ8Pbgz1NWKHcSOxoKJwPXFiHBeUzOe7wphEiwziPAlWPdLp)lhsEQ2l5QJuzFHsd3dPFeha9PoL6zjqLQdDqnWGastmXa1PAV0bIzlydXRuAVPorjoc)u2xOKBEDc1qCsCe7(K8lhkcXiMTGneVsP9M6eLIp(PSVqj33OViojoIDFs(LdfbU8OXpdmzTsrQ5PosL9fknCpK(rCa0MxhZDatGQchCx5tdmYQpHjdfyrVCihTsJ)4VGGBVBiWh9Ks01iddLrfc(qoALg)bZW4oQ4Isgvw3Q5h1kHr(Ob)GeUUG6Ddb(ONuIUgzyOmQqWVWUCji4wn)OwjmYhnrCQtPEwIRgyqaPjMyrP3ne4eZwWgsAqwD4d5OvAIad98WDGqIcsYEtI)f7OroKJwzugnhY(Hx04kiOMFuReg5JMio1PuplXvdmiG0etSO07gcCIzlydjT3uh(qoALMiWqppChiKOGKS3K4FXoAKd5OvgLrZHSF4fnUUGsmBbBiELsnHaQB3IXqilgYxYzQSsg)cliWqNuQ5ZpcXuAcvmgczXq(so5aJ8rJ0dLy8lSlbbg6KsnFEwGf9YGsUG6wmg6KsnF(jLViigbbX8UHaNPYkz8lSGGA(rTsyKpA8lkW1LGG3ne4mvwjJpKJwPXpCeuX8UHaF0tkrxJmmugvi4x4osL9fknCpK(rCa0j5t6GqjOQWb3E3qGtmBbBiP9M6WVWccUzI0bmzoen0HyI0bmj)YH8hYUeeyI0bmzoajxqvyjteXo2rQSVqPH7H0pIdGwKAdshekbvfo427gcCIzlydjT3uh(fwqWntKoGjZHOHoetKoGj5xoK)q2LGatKoGjZbi5cQclzIi2XosL9fknCpK(rCa0HR1kDqOeuv4GBVBiWjMTGnK0EtD4xybb3mr6aMmhIg6qmr6aMKF5q(dzxccmr6aMmhGKlOkSKjIyh7iv2xO0W9q6hXbq7tNPqJefKK9MuhPY(cLgUhs)ioaAZRtOgcuv4aXSfSH4vkT3uhbbIzlydXniRoYKe3liqmBbBiUMqitsCVGG3ne4(0zk0irbjzVjXVWqjMTGneVsP9M6ii427gcCMkRKXhYrR04VY(cLCFJ(I4K4i29j5xoeuVBiWzQSsg)c7QJuzFHsd3dPFehaTVrFrDKk7luA4Ei9J4aONBkv2xOuAlZdQuDOdb1AFrZTJSJuzFHsdhBi1XRsmAoCQtPEwcuP6qhmAGKpsEnK0atwlOov7Lo427gc8VCiFOjLydPoEvIrdFihTsJFGzyChvCrGlhpOUjMTGneVsPh6fjiqmBbBiELsdYQJGaXSfSH42BQJmjX9Uee8UHa)lhYhAsj2qQJxLy0WhYrR04NY(cLCZRtOgItIJy3NKF5qrGlhpOUjMTGneVsP9M6iiqmBbBiUbz1rMK4EbbIzlydX1eczsI7D5sqqmVBiW)YH8HMuInK64vjgn8lChPY(cLgo2qQJxLy0eXbqBEDm3bmbQkCWTyN6uQNL4gnqYhjVgsAGjRvqWT3ne4JEsj6AKHHYOcbFihTsJ)GzyChvCrjJkRB18JALWiF0GFqcxxq9UHaF0tkrxJmmugvi4xyxUeeuZpQvcJ8rJFrbUDKk7luA4ydPoEvIrtehandLNOJK8frsdCn1Bavfo4(uNs9SeNHYt0rsIrgisg0kFAGrw9jmzOal6Ld5OvA8dpiHluXyiKfd5l5mvwjJpKIbHGG3ne4mvwjJFHDbvn)OwjmYhn(J)4c1T3ne4eZwWgsAVPo8HC0kn(HhUccE3qGtmBbBiPbz1HpKJwPXp8W1LGqOal6Ld5OvA8hpC7iv2xO0WXgsD8QeJMioaAftH)6KKgF64akgemljFDatV5aEGQchedd9CftH)6KKgF64iXuhfmX)IDSsWqftzFHsUIPWFDssJpDCKyQJcM4vkd2cSOhQBXWqpxXu4VojPXNoosrKA5FXowjybbm0Zvmf(RtsA8PJJuePw(qoALg)GSlbbm0Zvmf(RtsA8PJJetDuWe38k7O)qckg65kMc)1jjn(0XrIPokyIpKJwPXFibfd9CftH)6KKgF64iXuhfmX)IDSsWDKk7luA4ydPoEvIrtehaTdcLHAiqXGGzj5Rdy6nhWduv4WqHHmIuplb91bm98VCi5JKyf5hErd1TBVBiWzQSsgFihTsJFqgQBVBiWh9Ks01iddLrfc(qoALg)GSGGyE3qGp6jLORrggkJke8lSlbbX8UHaNPYkz8lSGGA(rTsyKpA8hs46cQBX8UHa)yLydHjjhyKpACO8Lusd4kQe)cliOMFuReg5Jg)HeUUGQWsMiID0vhPY(cLgo2qQJxLy0eXbqBUzOgcumiyws(6aMEZb8avfomuyiJi1ZsqFDatp)lhs(ijwr(Hx0qD727gcCMkRKXhYrR04hKH627gc8rpPeDnYWqzuHGpKJwPXpiliiM3ne4JEsj6AKHHYOcb)c7sqqmVBiWzQSsg)cliOMFuReg5Jg)HeUUG6wmVBiWpwj2qysYbg5JghkFjL0aUIkXVWccQ5h1kHr(OXFiHRlOkSKjIyhD1rQSVqPHJnK64vjgnrCa0MNSwDKbRoeOyqWSK81bm9Md4bQkCyOWqgrQNLG(6aME(xoK8rsSI8dpXhQB3E3qGZuzLm(qoALg)Gmu3E3qGp6jLORrggkJke8HC0kn(bzbbX8UHaF0tkrxJmmugvi4xyxccI5DdbotLvY4xybb18JALWiF04pKW1fu3I5Ddb(XkXgctsoWiF04q5lPKgWvuj(fwqqn)OwjmYhn(djCDbvHLmre7ORosL9fknCSHuhVkXOjIdGoGggjrbzQ)DiqvHdkSKjIyh7iv2xO0WXgsD8QeJMioa6rpPeDnYWqzuHauv4G3ne4mvwjJFH7iv2xO0WXgsD8QeJMioa6JvIneM0axt9gqvHdUD7DdboXSfSHKgKvh(qoALg)WdxbbVBiWjMTGnK0EtD4d5OvA8dpCDbLHqwmKVKZuzLm(qoALg)GeUUeeyiKfd5l5mvwjJpKIbrhPY(cLgo2qQJxLy0eXbqZilz(sTs1wGthkFqvHdUD7Ddb(XkXgctsoWiF04q5lPKgWvuj(fwqqmg6KsnF(riMstxccm0jLA(8Sal6LbLeeo1PuplXlJurKGG3ne4EwecZEnp)cd17gcCplcHzVMNpKJwPX)OXnc3muIDRNdpeRmKuTf40HYN)Ldjpv7LC5cQyE3qGZuzLm(fgQBXyOtk185zbw0ldkjiWqilgYxYzO8eDKKVisAGRPEd)cliu5tdmYQpHjdfyrVCihTsJ)meYIH8LCgkprhj5lIKg4AQ3WhYrR0eH4liu5tdmYQpHjdfyrVCihTsd(HF4HJW1)OXnc3muIDRNdpeRmKuTf40HYN)Ldjpv7LC5QJuzFHsdhBi1XRsmAI4aORKPtQFHsqvHdUD7Ddb(XkXgctsoWiF04q5lPKgWvuj(fwqqmg6KsnF(riMstxccm0jLA(8Sal6LbLeeo1PuplXlJurKGG3ne4EwecZEnp)cd17gcCplcHzVMNpKJwPXFiHBeUzOe7wphEiwziPAlWPdLp)lhsEQ2l5YfuX8UHaNPYkz8lmu3IXqNuQ5ZZcSOxgusqGHqwmKVKZq5j6ijFrK0axt9g(fwqOYNgyKvFctgkWIE5qoALg)ziKfd5l5muEIosYxejnW1uVHpKJwPjcXxqOYNgyKvFctgkWIE5qoALg8d)WdhHR)qc3iCZqj2TEo8qSYqs1wGthkF(xoK8uTxYLRosL9fknCSHuhVkXOjIdG(uNs9SeOs1Hoy0tsgqJKPYkzG6uTx6GBXyiKfd5l5mvwjJpKIbHGGyN6uQNL4muEIossmYarYGYqNuQ5ZZcSOxguYvhPY(cLgo2qQJxLy0eXbqhUdesuqs2BsGQchiMTGneVsPMqavHLmre7iu3yONRyk8xNK04thhjM6OGj(xSJvcwqqmg6KsnFEsSbzrdMlON6uQNL4g9KKb0izQSswhPY(cLgo2qQJxLy0eXbqBEDm3bmbQkCGHoPuZNNfyrVmOe0tDk1ZsCgkprhjjgzGizqvZpQvcJ8rJFhWFCHYqilgYxYzO8eDKKVisAGRPEdFihTsJ)GzyChvCrjJkRB18JALWiF0GFqcxxDKk7luA4ydPoEvIrtehaDs(KoiucQkCWT3ne4eZwWgsAVPo8lSGGBMiDatMdrdDiMiDatYVCi)HSlbbMiDatMdqYfufwYerSJqp1PuplXn6jjdOrYuzLSosL9fknCSHuhVkXOjIdGwKAdshekbvfo427gcCIzlydjT3uh(fgQym0jLA(8JqmLMccU9UHa)yLydHjjhyKpACO8Lusd4kQe)cdLHoPuZNFeIP00LGGBMiDatMdrdDiMiDatYVCi)HSlbbMiDatMdqsqW7gcCMkRKXVWUGQWsMiIDe6PoL6zjUrpjzansMkRK1rQSVqPHJnK64vjgnrCa0HR1kDqOeuv4GBVBiWjMTGnK0EtD4xyOIXqNuQ5ZpcXuAki427gc8JvIneMKCGr(OXHYxsjnGROs8lmug6KsnF(riMstxccUzI0bmzoen0HyI0bmj)YH8hYUeeyI0bmzoajbbVBiWzQSsg)c7cQclzIi2rON6uQNL4g9KKb0izQSswhPY(cLgo2qQJxLy0eXbq7tNPqJefKK9MuhPY(cLgo2qQJxLy0eXbqBEDc1qGQchiMTGneVsP9M6iiqmBbBiUbz1rMK4EbbIzlydX1eczsI7fe8UHa3NotHgjkij7nj(fgQ3ne4eZwWgsAVPo8lSGGBVBiWzQSsgFihTsJ)k7luY9n6lItIJy3NKF5qq9UHaNPYkz8lSRosL9fknCSHuhVkXOjIdG23OVOosL9fknCSHuhVkXOjIdGEUPuzFHsPTmpOs1HoeuR9fn3oYosL9fkn8GATVO5EW86yUdycuv4GyZnPaAatCp1QjJKOGuTw5lQsWgobIUfmmH1rQSVqPHhuR9fn3ioaAZnd1qGIbbZsYxhW0BoGhOQWbm0ZDqOmudXhYrR043qoALMosL9fkn8GATVO5gXbq7GqzOgQJSJuzFHsd38humf(RtsA8PJdOyqWSK81bm9Md4bQkCqmm0Zvmf(RtsA8PJJetDuWe)l2XkbdvmL9fk5kMc)1jjn(0XrIPokyIxPmylWIEOUfdd9CftH)6KKgF64ifrQL)f7yLGfeWqpxXu4VojPXNoosrKA5d5OvA8dYUeeWqpxXu4VojPXNoosm1rbtCZRSJ(djOyONRyk8xNK04thhjM6OGj(qoALg)Heum0Zvmf(RtsA8PJJetDuWe)l2Xkb3rQSVqPHB(ioaAgkprhj5lIKg4AQ3aQkCW9PoL6zjodLNOJKeJmqKmOIXqilgYxYzQSsgFifdcbbVBiWzQSsg)c7cQA(rTsyKpA8h)XfQBVBiWjMTGnK0EtD4d5OvA8dpCfe8UHaNy2c2qsdYQdFihTsJF4HRlbHqbw0lhYrR04pE42rQSVqPHB(ioa6tDk1ZsGkvh6ag6LdbIU1qou(gqDQ2lDWT3ne4mvwjJpKJwPXpid1T3ne4JEsj6AKHHYOcbFihTsJFqwqqmVBiWh9Ks01iddLrfc(f2LGGyE3qGZuzLm(fwqqn)OwjmYhn(djCDb1TyE3qGFSsSHWKKdmYhnou(skPbCfvIFHfeuZpQvcJ8rJ)qcxxqD7DdboXSfSHKgKvh(qoALg)aZW4oQ4ee8UHaNy2c2qs7n1HpKJwPXpWmmUJkoxDKk7luA4MpIdG2bHYqneOyqWSK81bm9Md4bQkCyOWqgrQNLG(6aME(xoK8rsSI8dVOH6wHLmre7i0tDk1ZsCm0lhceDRHCO8nU6iv2xO0WnFehaT5MHAiqXGGzj5Rdy6nhWduv4WqHHmIuplb91bm98VCi5JKyf5hErd1TclzIi2rON6uQNL4yOxoei6wd5q5BC1rQSVqPHB(ioaAZtwRoYGvhcumiyws(6aMEZb8avfomuyiJi1ZsqFDatp)lhs(ijwr(HN4d1TclzIi2rON6uQNL4yOxoei6wd5q5BC1rQSVqPHB(ioa6aAyKefKP(3HavfoOWsMiIDSJuzFHsd38rCa0JEsj6AKHHYOcbOQWbVBiWzQSsg)c3rQSVqPHB(ioaAYbg5JgPhkXavfo42T3ne4eZwWgsAqwD4d5OvA8dpCfe8UHaNy2c2qs7n1HpKJwPXp8W1fugczXq(sotLvY4d5OvA8ds4c1T3ne4Wt5GgSsTsDyAwmj81A0HFQ2l5F04pUccIn3KcObmXHNYbnyLAL6W0Sys4R1OdNar3cgMWC5sqW7gcC4PCqdwPwPomnlMe(An6Wpv7L87q0GyCfeyiKfd5l5mvwjJpKIbbu3Q5h1kHr(OXVOaxbHtDk1Zs8Yive5QJuzFHsd38rCa0mYsMVuRuTf40HYhuv4GB18JALWiF04xuGlu3E3qGFSsSHWKKdmYhnou(skPbCfvIFHfeeJHoPuZNFeIP00LGadDsPMpplWIEzqjbHtDk1Zs8Yiveji4DdbUNfHWSxZZVWq9UHa3ZIqy2R55d5OvA8pACJWT7OikNBsb0aM4Wt5GgSsTsDyAwmj81A0HtGOBbdtyUIWndLy365WdXkdjvBboDO85F5qYt1EjxUCbvmVBiWzQSsg)cd1Tym0jLA(8Sal6LbLeeyiKfd5l5muEIosYxejnW1uVHFHfeQ8Pbgz1NWKHcSOxoKJwPXFgczXq(sodLNOJK8frsdCn1B4d5OvAIq8feQ8Pbgz1NWKHcSOxoKJwPb)Wp8Wr46F04gHBgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9sUC1rQSVqPHB(ioa6kz6K6xOeuv4GB18JALWiF04xuGlu3E3qGFSsSHWKKdmYhnou(skPbCfvIFHfeeJHoPuZNFeIP00LGadDsPMpplWIEzqjbHtDk1Zs8Yiveji4DdbUNfHWSxZZVWq9UHa3ZIqy2R55d5OvA8hs4gHB3rruo3KcObmXHNYbnyLAL6W0Sys4R1OdNar3cgMWCfHBgkXU1ZHhIvgsQ2cC6q5Z)YHKNQ9sUC5cQyE3qGZuzLm(fgQBXyOtk185zbw0ldkjiWqilgYxYzO8eDKKVisAGRPEd)cliu5tdmYQpHjdfyrVCihTsJ)meYIH8LCgkprhj5lIKg4AQ3WhYrR0eH4liu5tdmYQpHjdfyrVCihTsd(HF4HJW1FiHBeUzOe7wphEiwziPAlWPdLp)lhsEQ2l5YvhPY(cLgU5J4aOp1PuplbQuDOdg9KKb0izQSsgOov7Lo4wmgczXq(sotLvY4dPyqiii2PoL6zjodLNOJKeJmqKmOm0jLA(8Sal6LbLC1rQSVqPHB(ioa6WDGqIcsYEtcuv4aXSfSH4vk1ecOkSKjIyhH6Ddbo8uoObRuRuhMMftcFTgD4NQ9s(hn(Jlu3yONRyk8xNK04thhjM6OGj(xSJvcwqqmg6KsnFEsSbzrdMlON6uQNL4g9KKb0izQSswhPY(cLgU5J4aOnVob1Abvfo4DdbokPxKrctdJG)cL8lmuVBiWnVob1A5dfgYis9SuhPY(cLgU5J4aOzAYiR07gcGkvh6G51XIgmqvHdE3qGBEDSObJpKJwPXFid1T3ne4eZwWgsAqwD4d5OvA8dYccE3qGtmBbBiP9M6WhYrR04hKDbvn)OwjmYhn(ff42rQSVqPHB(ioaAZRJ5oGjqvHdm0jLA(8Sal6LbLGEQtPEwIZq5j6ijXidejdkdHSyiFjNHYt0rs(IiPbUM6n8HC0kn(d5osL9fknCZhXbqBEDcQ1cQkC4vlLp38K1QJeBQWZPu9SeguXE1s5ZnVow0GXPu9SeguVBiWnVob1A5dfgYis9Seu3E3qGtmBbBiP9M6WhYrR04N4dLy2c2q8kL2BQduVBiWHNYbnyLAL6W0Sys4R1Od)uTxY)OHmUccE3qGdpLdAWk1k1HPzXKWxRrh(PAVKFhIgY4cvn)OwjmYhn(ff4kiGHEUIPWFDssJpDCKyQJcM4d5OvA8dhjiOSVqjxXu4VojPXNoosm1rbt8kLbBbw07cQymeYIH8LCMkRKXhsXGOJuzFHsd38rCa0MxhZDatGQch8UHahL0lYizwsh5zzkuYVWccE3qGFSsSHWKKdmYhnou(skPbCfvIFHfe8UHaNPYkz8lmu3E3qGp6jLORrggkJke8HC0kn(dMHXDuXfLmQSUvZpQvcJ8rd(bjCDb17gc8rpPeDnYWqzuHGFHfeeZ7gc8rpPeDnYWqzuHGFHHkgdHSyiFjF0tkrxJmmugvi4dPyqiiigdDsPMp)KYxeeJlbb18JALWiF04xuGluIzlydXRuQjeDKk7luA4MpIdG286yUdycuv4WRwkFU51XIgmoLQNLWG627gcCZRJfny8lSGGA(rTsyKpA8lkW1fuVBiWnVow0GXnVYo6pKG627gcCIzlydjniRo8lSGG3ne4eZwWgsAVPo8lSlOE3qGdpLdAWk1k1HPzXKWxRrh(PAVK)rdIXfQBgczXq(sotLvY4d5OvA8dpCfee7uNs9SeNHYt0rsIrgisgug6KsnFEwGf9YGsU6iv2xO0WnFehaT51XChWeOQWb3E3qGdpLdAWk1k1HPzXKWxRrh(PAVK)rdIXvqW7gcC4PCqdwPwPomnlMe(An6Wpv7L8pAiJl0xTu(CZtwRosSPcpNs1ZsyUG6DdboXSfSHKgKvh(qoALg)aXqjMTGneVsPbz1bQyE3qGJs6fzKW0Wi4Vqj)cdvSxTu(CZRJfnyCkvplHbLHqwmKVKZuzLm(qoALg)aXqDZqilgYxYpwj2qysdCn1B4d5OvA8deliigdDsPMp)ietPPRosL9fknCZhXbqNKpPdcLGQchC7DdboXSfSHK2BQd)cli4MjshWK5q0qhIjshWK8lhYFi7sqGjshWK5aKCbvHLmre7i0tDk1ZsCJEsYaAKmvwjRJuzFHsd38rCa0IuBq6GqjOQWb3E3qGtmBbBiP9M6WVWqfJHoPuZNFeIP0uqWT3ne4hReBimj5aJ8rJdLVKsAaxrL4xyOm0jLA(8JqmLMUeeCZePdyYCiAOdXePdys(Ld5pKDjiWePdyYCasccE3qGZuzLm(f2fufwYerSJqp1PuplXn6jjdOrYuzLSosL9fknCZhXbqhUwR0bHsqvHdU9UHaNy2c2qs7n1HFHHkgdDsPMp)ietPPGGBVBiWpwj2qysYbg5JghkFjL0aUIkXVWqzOtk185hHyknDji4MjshWK5q0qhIjshWK8lhYFi7sqGjshWK5aKee8UHaNPYkz8lSlOkSKjIyhHEQtPEwIB0tsgqJKPYkzDKk7luA4MpIdG2NotHgjkij7nPosL9fknCZhXbqBEDc1qGQchiMTGneVsP9M6iiqmBbBiUbz1rMK4EbbIzlydX1eczsI7fe8UHa3NotHgjkij7nj(fgQ3ne4eZwWgsAVPo8lSGGBVBiWzQSsgFihTsJ)k7luY9n6lItIJy3NKF5qq9UHaNPYkz8lSRosL9fknCZhXbq7B0xuhPY(cLgU5J4aONBkv2xOuAlZdQuDOdb1AFrZfi2atmaqIhUrd8apaa]] )


end