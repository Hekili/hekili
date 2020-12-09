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


    spec:RegisterPack( "Balance", 20201208, [[dGuJudqicLhbvu5sqvLnbsFIqvAuuLofvXQuc0RecZci5wqfPDHYVasnmOshdQYYuc9mqutdQQ6AGiBtjGVbvughurCocv16iufZJQQUNqAFuv5GabYcHQYdbcAIabGlcea9rGaYjHkQYkfIMjqO2jq0qbcqlfQOQEQqnvOcFfiqnwGaQ9c4VenyvomPftLEmQMmuUmYMf8zGA0eYPL8ALOztXTPIDl63qgoOooqilxXZP00v11vQTRK(ovLXtOY5bH1Re08jy)snaEa4aigtFcaKlI7I4I3I4Ity4j(qcYqcpG4hcycigw5lvWeqCQoeqm(uJMCcigwHWGumaCaeBr7HtaXI(h2kEanObxVOTlJJCaTTC2g9luYhn8G2woCqde7UlZJZlbCbIX0Naa5I4UiU4TiU4egEIpKGm(l(aX6(fHgG44YbecelQWWOeWfigJSCGyCU(WNA0Kt9bcGzxyDK4C9bcaItoU00hobu9TiUlIBhzhjoxFGqrAcMSINosCU(WP9bccdJW6lgz0Pp8rQdRJeNRpCAFGqrAcMW671bm9Yk0hxTKTVh1hhcUHKVoGP3Y6iX56dN2hoFYbTsy9TZK4K1Qde9TQtPUgY2N3Irmq1h8qRs7RJDpGP(WP(1h8qRm7RJDpGjpSosCU(WP9bcAfvy9bpexTFLG7de8OVO(QqF1lET99IO(8nOeCFGaKBkylXaInL9Ta4aigBi1XTsmAaWbaiXdahaXuQUgcdaFaXiyGyl9aXk)luceVQtPUgciEvnBci2BFU7qG9Ld5dnPeBi1XTsmAyd5OvA7ZV(aZXyoQ46lI(WLHxFq7ZBFe3uWwIvP0f9I6tqOpIBkylXQuArgD6tqOpIBkylXm7uhzsI77ZtFcc95Udb2xoKp0KsSHuh3kXOHnKJwPTp)6t5FHsM91judXiXr89tYVCO(IOpCz41h0(82hXnfSLyvkn7uN(ee6J4Mc2smlYOJmjX99ji0hXnfSLyAcHmjX995Ppp9ji0Ny95Udb2xoKp0KsSHuh3kXOHTHbIx1rMQdbeB1ajFKCBjPfMmgGhaKlcGdGykvxdHbGpGy(upnLce7TpX6BvNsDneZQbs(i52sslmzm9ji0N3(C3HaB0vkrBRmmuUqiyd5OvA7Z)(aZXyoQ46Bb7JtLPpV9P2FuJeg5JM(aDFqg3(80h0(C3HaB0vkrBRmmuUqiyB4(80NN(ee6tT)OgjmYhn95xFIpUaXk)luceBFDS7bmb8aGeYa4aiMs11qya4diMp1ttPaXE7BvNsDneJJYv0ssIrwisEFq7RYNgyKrFctgkWIE5qoAL2(8Rp8GmU9bTpX6JJqgmKVKXvzLC2qkge9ji0N7oeyCvwjNTH7ZtFq7tT)OgjmYhn95FF4pU9bTpV95UdbgXnfSLKMDQdBihTsBF(1hE42NGqFU7qGrCtbBjPfz0HnKJwPTp)6dpC7ZtFcc9fkWIE5qoAL2(8Vp8Wfiw5FHsGyokxrlj5lIKw4AQ3c8aGe)bWbqmLQRHWaWhqSY)cLaXkMc)1kjT(0XbiMp1ttPaXI1hg6zkMc)1kjT(0XrIPokyI9fFzLG7dAFI1NY)cLmftH)ALKwF64iXuhfmXQugmfyrFFq7ZBFI1hg6zkMc)1kjT(0XrkIud7l(Ykb3NGqFyONPyk8xRK06thhPisnSHC0kT95xFqQpp9ji0hg6zkMc)1kjT(0XrIPokyIzFLVSp)7dY9bTpm0Zumf(RvsA9PJJetDuWeBihTsBF(3hK7dAFyONPyk8xRK06thhjM6OGj2x8LvcgiMdb3qYxhW0BbajEapaiHeaoaIPuDnega(aIv(xOei2bHYqneqmFQNMsbIhkmKvK6AO(G23Rdy6zF5qYhjXkQp)6dVf7dAFE7ZBFU7qGXvzLC2qoAL2(8Rpi1h0(82N7oeyJUsjABLHHYfcbBihTsBF(1hK6tqOpX6ZDhcSrxPeTTYWq5cHGTH7ZtFcc9jwFU7qGXvzLC2gUpbH(u7pQrcJ8rtF(3hKXTpp9bTpV9jwFU7qGTSsSHWKKdmYhnou(skPbCTqITH7tqOp1(JAKWiF00N)9bzC7ZtFq7tHLCreFzFEaI5qWnK81bm9waqIhWdaYfaahaXuQUgcdaFaXk)luceB3zOgciMp1ttPaXdfgYksDnuFq771bm9SVCi5JKyf1NF9H3I9bTpV95Tp3DiW4QSsoBihTsBF(1hK6dAFE7ZDhcSrxPeTTYWq5cHGnKJwPTp)6ds9ji0Ny95Udb2ORuI2wzyOCHqW2W95PpbH(eRp3DiW4QSsoBd3NGqFQ9h1iHr(OPp)7dY42NN(G2N3(eRp3DiWwwj2qysYbg5JghkFjL0aUwiX2W9ji0NA)rnsyKpA6Z)(GmU95PpO9PWsUiIVSppaXCi4gs(6aMElaiXd4bajodahaXuQUgcdaFaXk)luceBFYy0rgm6qaX8PEAkfiEOWqwrQRH6dAFVoGPN9LdjFKeRO(8Rp8wG(G2N3(82N7oeyCvwjNnKJwPTp)6ds9bTpV95Udb2ORuI2wzyOCHqWgYrR02NF9bP(ee6tS(C3HaB0vkrBRmmuUqiyB4(80NGqFI1N7oeyCvwjNTH7tqOp1(JAKWiF00N)9bzC7ZtFq7ZBFI1N7oeylReBimj5aJ8rJdLVKsAaxlKyB4(ee6tT)OgjmYhn95FFqg3(80h0(uyjxeXx2NhGyoeCdjFDatVfaK4b8aGeNaGdGykvxdHbGpGy(upnLceRWsUiIVeiw5FHsG4aA4KefKP(7HaEaqk(a4aiMs11qya4diMp1ttPaXU7qGXvzLC2ggiw5FHsG4rxPeTTYWq5cHa4bajE4cGdGykvxdHbGpGy(upnLce7TpV95UdbgXnfSLKwKrh2qoAL2(8Rp8WTpbH(C3HaJ4Mc2ssZo1HnKJwPTp)6dpC7ZtFq7JJqgmKVKXvzLC2qoAL2(8RpiJBFE6tqOpoczWq(sgxLvYzdPyqaeR8Vqjq8YkXgctAHRPElWdas8WdahaXuQUgcdaFaX8PEAkfi2BFE7ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFcc9jwFC0kLA(SLqmLM95PpbH(4Ovk18zzbw0ldk1NGqFR6uQRHyLvQiQpbH(C3HaZ1GqyMT9zB4(G2N7oeyUgecZSTpBihTsBF(33I42xe95TpokX21ZGhIxwsQMcC6q5Z(YHKRQzt95Ppp9bTpX6ZDhcmUkRKZ2W9bTpV9jwFC0kLA(SSal6LbL6tqOpoczWq(sghLROLK8frslCn1BzB4(ee6RYNgyKrFctgkWIE5qoAL2(8VpoczWq(sghLROLK8frslCn1Bzd5OvA7lI(wG(ee6RYNgyKrFctgkWIE5qoAL2(WV(WdNGBF(33I42xe95TpokX21ZGhIxwsQMcC6q5Z(YHKRQzt95PppaXk)luceZjdz)sns1uGthkFGhaK4TiaoaIPuDnega(aI5t90ukqS3(82N7oeylReBimj5aJ8rJdLVKsAaxlKyB4(ee6tS(4Ovk18zlHykn7ZtFcc9XrRuQ5ZYcSOxguQpbH(w1PuxdXkRuruFcc95UdbMRbHWmB7Z2W9bTp3DiWCnieMzBF2qoAL2(8VpiJBFr0N3(4OeBxpdEiEzjPAkWPdLp7lhsUQMn1NN(80h0(eRp3DiW4QSsoBd3h0(82Ny9XrRuQ5ZYcSOxguQpbH(4iKbd5lzCuUIwsYxejTW1uVLTH7tqOVkFAGrg9jmzOal6Ld5OvA7Z)(4iKbd5lzCuUIwsYxejTW1uVLnKJwPTVi6Bb6tqOVkFAGrg9jmzOal6Ld5OvA7d)6dpCcU95FFqg3(IOpV9Xrj2UEg8q8Yss1uGthkF2xoKCvnBQpp95biw5FHsG4k56K6xOe4bajEqgahaXuQUgcdaFaXiyGyl9aXk)luceVQtPUgciEvnBci2BFI1hhHmyiFjJRYk5SHumi6tqOpX6BvNsDneJJYv0ssIrwisEFq7JJwPuZNLfyrVmOuFEaIx1rMQdbeB1vsgqJKRYk5apaiXd)bWbqmLQRHWaWhqmFQNMsbIjUPGTeRsPMq0h0(uyjxeXx2h0(82hg6zkMc)1kjT(0XrIPokyI9fFzLG7tqOpX6JJwPuZNLeFqg0G1NN(G23QoL6AiMvxjzansUkRKdeR8VqjqCypqirbjz2jb8aGepibGdGykvxdHbGpGy(upnLceZrRuQ5ZYcSOxguQpO9TQtPUgIXr5kAjjXilejVpO9P2FuJeg5JM(8lAF4pU9bTpoczWq(sghLROLK8frslCn1Bzd5OvA7Z)(aZXyoQ46Bb7JtLPpV9P2FuJeg5JM(aDFqg3(8aeR8VqjqS91XUhWeWdas8waaCaetP6Aima8beZN6PPuGyV95UdbgXnfSLKMDQdBd3NGqFE7JlshWKTVO9TyFq7BiUiDatYVCO(8Vpi1NN(ee6JlshWKTVO9b5(80h0(uyjxeXx2h0(w1PuxdXS6kjdOrYvzLCGyL)fkbItYN0bHsGhaK4HZaWbqmLQRHWaWhqmFQNMsbI92N7oeye3uWwsA2PoSnCFq7tS(4Ovk18zlHykn7tqOpV95Udb2YkXgctsoWiF04q5lPKgW1cj2gUpO9XrRuQ5ZwcXuA2NN(ee6ZBFCr6aMS9fTVf7dAFdXfPdys(Ld1N)9bP(80NGqFCr6aMS9fTpi3NGqFU7qGXvzLC2gUpp9bTpfwYfr8L9bTVvDk11qmRUsYaAKCvwjhiw5FHsGyrQjiDqOe4bajE4eaCaetP6Aima8beZN6PPuGyV95UdbgXnfSLKMDQdBd3h0(eRpoALsnF2siMsZ(ee6ZBFU7qGTSsSHWKKdmYhnou(skPbCTqITH7dAFC0kLA(SLqmLM95PpbH(82hxKoGjBFr7BX(G23qCr6aMKF5q95FFqQpp9ji0hxKoGjBFr7dY9ji0N7oeyCvwjNTH7ZtFq7tHLCreFzFq7BvNsDneZQRKmGgjxLvYbIv(xOeioSngPdcLapaiXt8bWbqSY)cLaX(0zk0irbjz2jbetP6Aima8b8aGCrCbWbqmLQRHWaWhqmFQNMsbIjUPGTeRsPzN60NGqFe3uWwIzrgDKjjUVpbH(iUPGTettiKjjUVpbH(C3HaZNotHgjkijZoj2gUpO95UdbgXnfSLKMDQdBd3NGqFE7ZDhcmUkRKZgYrR02N)9P8VqjZ3OVigjoIVFs(Ld1h0(C3HaJRYk5SnCFEaIv(xOei2(6eQHaEaqUiEa4aiw5FHsGyFJ(IaIPuDnega(aEaqU4Ia4aiMs11qya4diw5FHsG4zNsL)fkLMY(aXMY(YuDiG4GAmVOzd8apqmgf0T5bWbaiXdahaXk)luceBrgDKUK6aetP6Aima8b8aGCraCaetP6Aima8beJGbIT0deR8Vqjq8QoL6AiG4v1SjGylmzmYxhW0Bz2xNGAm95xF41h0(82Ny99QHYNzFDmObJrP6AiS(ee67vdLpZ(KXOJeBQWZOuDnewFE6tqOplmzmYxhW0Bz2xNGAm95xFlceVQJmvhciUSsfrapaiHmaoaIPuDnega(aIrWaXw6bIv(xOeiEvNsDneq8QA2eqSfMmg5Rdy6Tm7RtOgQp)6dpG4vDKP6qaXLvYnKUsapaiXFaCaetP6Aima8beZN6PPuGyV9jwFC0kLA(SSal6LbL6tqOpX6JJqgmKVKXr5kAjjFrK0cxt9w2gUpp9bTp3DiW4QSsoBddeR8VqjqSlnwAwwjyGhaKqcahaXuQUgcdaFaX8PEAkfi2DhcmUkRKZ2WaXk)lucedJ(cLapaixaaCaetP6Aima8beJGbIT0deR8Vqjq8QoL6AiG4v1SjG4GbHM(82N3(Q8Pbgz0NWKHcSOxoKJwPTpCAFlIBF40(4iKbd5lzCuUIwsYxejTW1uVLnKJwPTpp9b6(WBrC7ZtF(1xWGqtFE7ZBFv(0aJm6tyYqbw0lhYrR02hoTVfHuF40(82hE423c23RgkFwLCDs9luYOuDnewFE6dN2N3(4OeBxpdEiEzjPAkWPdLp7lhsUQMn1NN(WP9XridgYxY4QSsoBihTsBFE6d09Hhob3(80NGqFCeYGH8LmUkRKZgYrR02NF9v5tdmYOpHjdfyrVCihTsBFcc9XridgYxY4OCfTKKVisAHRPElBihTsBF(1xLpnWiJ(eMmuGf9YHC0kT9ji0Ny9XrRuQ5ZYcSOxguciEvhzQoeqmhLROLKeJSqKCGhaK4maCaetP6Aima8beR8VqjqCLw(SF11qsq0wZF7iXO1ItaX8PEAkfi2DhcmUkRKZ2WaXP6qaXvA5Z(vxdjbrBn)TJeJwlob8aGeNaGdGyL)fkbI3wswp5ybIPuDnega(aEaqk(a4aiMs11qya4diMp1ttPaXR6uQRHyLvQici2(tXFaqIhqSY)cLaXZoLk)luknL9bInL9LP6qaXkIaEaqIhUa4aiMs11qya4diMp1ttPaXZoPaAatSVCiFOjLydPoUvIrdJar7cgMWaIT)u8haK4beR8Vqjq8StPY)cLstzFGytzFzQoeqm2qQJBLy0a8aGep8aWbqmLQRHWaWhqmFQNMsbINDsb0aMyUQrtojrbPAmYxuLGTmceTlyycdi2(tXFaqIhqSY)cLaXZoLk)luknL9bInL9LP6qaXUi9bEaqI3Ia4aiMs11qya4diw5FHsG4zNsL)fkLMY(aXMY(YuDiGy7d8apqSlsFaCaas8aWbqmLQRHWaWhqmFQNMsbID3HaJRYk5SnmqSY)cLaXJUsjABLHHYfcbWdaYfbWbqmLQRHWaWhqmcgi2spqSY)cLaXR6uQRHaIxvZMaIfRp3DiWCvJMCsIcs1yKVOkbBLP(7HyB4(G2Ny95UdbMRA0KtsuqQgJ8fvjyRuhUMeBddeVQJmvhciMp1NOFdd8aGeYa4aiMs11qya4diw5FHsGyftH)ALKwF64aeZN6PPuGy3DiWCvJMCsIcs1yKVOkbBLP(7Hy2x5lLRQzt95FF4pU9bTp3DiWCvJMCsIcs1yKVOkbBL6W1Ky2x5lLRQzt95FF4pU9bTpV9jwFyONPyk8xRK06thhjM6OGj2x8LvcUpO9jwFk)luYumf(RvsA9PJJetDuWeRszWuGf99bTpV9jwFyONPyk8xRK06thhPisnSV4lReCFcc9HHEMIPWFTssRpDCKIi1WgYrR02NF9b5(80NGqFyONPyk8xRK06thhjM6OGjM9v(Y(8Vpi3h0(WqptXu4VwjP1Noosm1rbtSHC0kT95FFqQpO9HHEMIPWFTssRpDCKyQJcMyFXxwj4(8aeZHGBi5Rdy6TaGepGhaK4paoaIPuDnega(aI5t90ukqS3(w1PuxdX4OCfTKKyKfIK3h0(eRpoczWq(sgxLvYzdPyq0NGqFU7qGXvzLC2gUpp9bTpV95UdbMRA0KtsuqQgJ8fvjyRm1FpeZ(kFPCvnBQVO9bjC7tqOp3DiWCvJMCsIcs1yKVOkbBL6W1Ky2x5lLRQzt9fTpiHBFE6tqOVqbw0lhYrR02N)9HhUaXk)luceZr5kAjjFrK0cxt9wGhaKqcahaXuQUgcdaFaX8PEAkfi2BFU7qG5Qgn5KefKQXiFrvc2kt93dXgYrR02NF9H)mi1NGqFU7qG5Qgn5KefKQXiFrvc2k1HRjXgYrR02NF9H)mi1NN(G2NA)rnsyKpA6ZVO9j(42h0(82hhHmyiFjJRYk5SHC0kT95xF4S(ee6ZBFCeYGH8LmYbg5JgPlkXyd5OvA7ZV(Wz9bTpX6ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFq7JJwPuZNTeIP0Spp95biw5FHsGyUMCYiD3HaqS7oeKP6qaX2xhdAWaEaqUaa4aiMs11qya4diMp1ttPaXI13QoL6AigFQpr)gUpO95TpoALsnFwwGf9YGs9ji0hhHmyiFjJRYk5SHC0kT95xF4S(ee6ZBFCeYGH8LmYbg5JgPlkXyd5OvA7ZV(Wz9bTpX6ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFq7JJwPuZNTeIP0Spp95biw5FHsGy7RJDpGjGhaK4maCaetP6Aima8beZN6PPuGyV9XridgYxY4OCfTKKVisAHRPElBihTsBF(3hK6dAFE7BvNsDneJJYv0ssIrwisEFcc9XridgYxY4QSsoBihTsBF(3hK6ZtFE6dAFQ9h1iHr(OPp)6d)XTpO9XrRuQ5ZYcSOxguciw5FHsGy7RJDpGjGhaK4eaCaetP6Aima8beR8VqjqSDNHAiGy(upnLcepuyiRi11q9bTVxhW0Z(YHKpsIvuF(1hElqFq7ZBFkSKlI4l7dAFE7BvNsDneJp1NOFd3NGqFE7tT)OgjmYhn95FFqg3(G2Ny95UdbgxLvYzB4(80NGqFCeYGH8LmUkRKZgsXGOpp95biMdb3qYxhW0BbajEapaifFaCaetP6Aima8beR8VqjqSdcLHAiGy(upnLcepuyiRi11q9bTVxhW0Z(YHKpsIvuF(1hEqMbP(G2N3(uyjxeXx2h0(823QoL6AigFQpr)gUpbH(82NA)rnsyKpA6Z)(GmU9bTpX6ZDhcmUkRKZ2W95PpbH(4iKbd5lzCvwjNnKIbrFE6dAFI1N7oeylReBimj5aJ8rJdLVKsAaxlKyB4(8aeZHGBi5Rdy6TaGepGhaK4HlaoaIPuDnega(aIv(xOei2(KXOJmy0HaI5t90ukq8qHHSIuxd1h0(EDatp7lhs(ijwr95xF4Ta9frFd5OvA7dAFE7tHLCreFzFq7ZBFR6uQRHy8P(e9B4(ee6tT)OgjmYhn95FFqg3(ee6JJqgmKVKXvzLC2qkge95PppaXCi4gs(6aMElaiXd4bajE4bGdGykvxdHbGpGy(upnLceRWsUiIVeiw5FHsG4aA4KefKP(7HaEaqI3Ia4aiMs11qya4diMp1ttPaXE7J4Mc2sSkLAcrFcc9rCtbBjMfz0rwPeV(ee6J4Mc2smZo1rwPeV(80h0(82Ny9XrRuQ5ZYcSOxguQpbH(82NA)rnsyKpA6Z)(eFi1h0(823QoL6AigFQpr)gUpbH(u7pQrcJ8rtF(3hKXTpbH(w1PuxdXkRuruFE6dAFE7BvNsDneJJYv0ssIrwisEFq7tS(4iKbd5lzCuUIwsYxejTW1uVLTH7tqOpX6BvNsDneJJYv0ssIrwisEFq7tS(4iKbd5lzCvwjNTH7ZtFE6ZtFq7ZBFCeYGH8LmUkRKZgYrR02NF9bzC7tqOp1(JAKWiF00NF9j(42h0(4iKbd5lzCvwjNTH7dAFE7JJqgmKVKroWiF0iDrjgBihTsBF(3NY)cLm7RtOgIrIJ47NKF5q9ji0Ny9XrRuQ5ZwcXuA2NN(ee6RYNgyKrFctgkWIE5qoAL2(8Vp8WTpp9bTpV9HHEMIPWFTssRpDCKyQJcMyd5OvA7ZV(W)(ee6tS(4Ovk18zjXhKbny95biw5FHsG4WEGqIcsYStc4bajEqgahaXuQUgcdaFaX8PEAkfi2BFe3uWwIz2PoYKe33NGqFe3uWwIzrgDKjjUVpbH(iUPGTettiKjjUVpbH(C3HaZvnAYjjkivJr(IQeSvM6VhInKJwPTp)6d)zqQpbH(C3HaZvnAYjjkivJr(IQeSvQdxtInKJwPTp)6d)zqQpbH(u7pQrcJ8rtF(1N4JBFq7JJqgmKVKXvzLC2qkge95PpO95TpoczWq(sgxLvYzd5OvA7ZV(GmU9ji0hhHmyiFjJRYk5SHumi6ZtFcc9v5tdmYOpHjdfyrVCihTsBF(3hE4ceR8Vqjq8YkXgctAHRPElWdas8WFaCaetP6Aima8beZN6PPuGyV9P2FuJeg5JM(8RpXh3(G2N3(C3HaBzLydHjjhyKpACO8Lusd4AHeBd3NGqFI1hhTsPMpBjetPzFE6tqOpoALsnFwwGf9YGs9ji0N7oeyUgecZSTpBd3h0(C3HaZ1GqyMT9zd5OvA7Z)(we3(IOpV9Xrj2UEg8q8Yss1uGthkF2xoKCvnBQpp95PpO95TVvDk11qmokxrljjgzHi59ji0hhHmyiFjJJYv0ss(IiPfUM6TSHumi6ZtFcc9v5tdmYOpHjdfyrVCihTsBF(33I42xe95TpokX21ZGhIxwsQMcC6q5Z(YHKRQzt95biw5FHsGyozi7xQrQMcC6q5d8aGepibGdGykvxdHbGpGy(upnLce7Tp1(JAKWiF00NF9j(42h0(82N7oeylReBimj5aJ8rJdLVKsAaxlKyB4(ee6tS(4Ovk18zlHykn7ZtFcc9XrRuQ5ZYcSOxguQpbH(C3HaZ1GqyMT9zB4(G2N7oeyUgecZSTpBihTsBF(3hKXTVi6ZBFCuITRNbpeVSKunf40HYN9LdjxvZM6ZtFE6dAFE7BvNsDneJJYv0ssIrwisEFcc9XridgYxY4OCfTKKVisAHRPElBifdI(80NGqFv(0aJm6tyYqbw0lhYrR02N)9bzC7lI(82hhLy76zWdXlljvtboDO8zF5qYv1SP(8aeR8VqjqCLCDs9luc8aGeVfaahaXuQUgcdaFaXiyGyl9aXk)luceVQtPUgciEvnBciM4Mc2sSkLMDQtFlyF4K(aDFk)luYSVoHAigjoIVFs(Ld1xe9jwFe3uWwIvP0StD6Bb7Bb6d09P8VqjZ3OVigjoIVFs(Ld1xe9HlBX(aDFwyYyKIu7taXR6it1HaIvlmiG0etCGhaK4HZaWbqmLQRHWaWhqmFQNMsbI92xLpnWiJ(eMmuGf9YHC0kT95FF4FFcc95Tp3DiWgDLs02kddLlec2qoAL2(8VpWCmMJkU(wW(4uz6ZBFQ9h1iHr(OPpq3hKXTpp9bTp3DiWgDLs02kddLlec2gUpp95PpbH(82NA)rnsyKpA6lI(w1PuxdXulmiG0et8(wW(C3HaJ4Mc2sslYOdBihTsBFr0hg6zH9aHefKKzNe7l(sRCihTY(wW(wKbP(8Rp8we3(ee6tT)OgjmYhn9frFR6uQRHyQfgeqAIjEFlyFU7qGrCtbBjPzN6WgYrR02xe9HHEwypqirbjz2jX(IV0khYrRSVfSVfzqQp)6dVfXTpp9bTpIBkylXQuQje9bTpV95TpX6JJqgmKVKXvzLC2gUpbH(4Ovk18zlHykn7dAFI1hhHmyiFjJCGr(Or6Ism2gUpp9ji0hhTsPMpllWIEzqP(80h0(82Ny9XrRuQ5ZwP8fbX0NGqFI1N7oeyCvwjNTH7tqOp1(JAKWiF00NF9j(42NN(ee6ZDhcmUkRKZgYrR02NF9Ht6dAFI1N7oeyJUsjABLHHYfcbBddeR8VqjqS91XUhWeWdas8Wja4aiMs11qya4diMp1ttPaXE7ZDhcmIBkyljn7uh2gUpbH(82hxKoGjBFr7BX(G23qCr6aMKF5q95FFqQpp9ji0hxKoGjBFr7dY95PpO9PWsUiIVeiw5FHsG4K8jDqOe4bajEIpaoaIPuDnega(aI5t90ukqS3(C3HaJ4Mc2ssZo1HTH7tqOpV9XfPdyY2x0(wSpO9nexKoGj5xouF(3hK6ZtFcc9XfPdyY2x0(GCFE6dAFkSKlI4lbIv(xOeiwKAcshekbEaqUiUa4aiMs11qya4diMp1ttPaXE7ZDhcmIBkyljn7uh2gUpbH(82hxKoGjBFr7BX(G23qCr6aMKF5q95FFqQpp9ji0hxKoGjBFr7dY95PpO9PWsUiIVeiw5FHsG4W2yKoiuc8aGCr8aWbqSY)cLaX(0zk0irbjz2jbetP6Aima8b8aGCXfbWbqmLQRHWaWhqmFQNMsbIjUPGTeRsPzN60NGqFe3uWwIzrgDKjjUVpbH(iUPGTettiKjjUVpbH(C3HaZNotHgjkijZoj2gUpO95UdbgXnfSLKMDQdBd3NGqFE7ZDhcmUkRKZgYrR02N)9P8VqjZ3OVigjoIVFs(Ld1h0(C3HaJRYk5SnCFEaIv(xOei2(6eQHaEaqUiKbWbqSY)cLaX(g9fbetP6Aima8b8aGCr8hahaXuQUgcdaFaXk)lucep7uQ8VqP0u2hi2u2xMQdbehuJ5fnBGh4bIvebGdaqIhaoaIPuDnega(aIrWaXw6bIv(xOeiEvNsDneq8QA2eqS3(C3Ha7lhYhAsj2qQJBLy0WgYrR02N)9bMJXCuX1xe9HldV(ee6ZDhcSVCiFOjLydPoUvIrdBihTsBF(3NY)cLm7RtOgIrIJ47NKF5q9frF4YWRpO95TpIBkylXQuA2Po9ji0hXnfSLywKrhzsI77tqOpIBkylX0eczsI77ZtFE6dAFU7qG9Ld5dnPeBi1XTsmAyB4(G23StkGgWe7lhYhAsj2qQJBLy0Wiq0UGHjmG4vDKP6qaXydPosFLXidQXirHaWdaYfbWbqmLQRHWaWhqmFQNMsbI923QoL6AighLROLKeJSqK8(G2Ny9XridgYxY4QSsoBifdI(ee6ZDhcmUkRKZ2W95PpO9P2FuJeg5JM(8VpiHBFq7ZBFU7qGrCtbBjPzN6WgYrR02NF9Ta9ji0N7oeye3uWwsArgDyd5OvA7ZV(wG(80h0(82Ny9n7KcObmXCvJMCsIcs1yKVOkbBzuQUgcRpbH(C3HaZvnAYjjkivJr(IQeSvM6VhIzFLVuUQMn1NF9bzC7tqOp3DiWCvJMCsIcs1yKVOkbBL6W1Ky2x5lLRQzt95xFqg3(80NGqFHcSOxoKJwPTp)7dpCbIv(xOeiMJYv0ss(IiPfUM6TapaiHmaoaIPuDnega(aI5t90ukqS7oey2xNGAmSHcdzfPUgQpO95TplmzmYxhW0Bz2xNGAm95FFqUpbH(eRVzNuanGj2xoKp0KsSHuh3kXOHrGODbdty95PpO95TpX6B2jfqdyIzGGRJALbdrFLGLGnLdSLyeiAxWWewFcc99Ld1h(1h(dP(8Rp3DiWSVob1yyd5OvA7lI(wSppaXk)luceBFDcQXa8aGe)bWbqmLQRHWaWhqmFQNMsbINDsb0aMyF5q(qtkXgsDCReJggbI2fmmH1h0(SWKXiFDatVLzFDcQX0NFr7dY9bTpV9jwFU7qG9Ld5dnPeBi1XTsmAyB4(G2N7oey2xNGAmSHcdzfPUgQpbH(823QoL6Aig2qQJ0xzmYGAmsui0h0(82N7oey2xNGAmSHC0kT95FFqUpbH(SWKXiFDatVLzFDcQX0NF9TyFq77vdLpZ(KXOJeBQWZOuDnewFq7ZDhcm7Rtqng2qoAL2(8Vpi1NN(80NhGyL)fkbITVob1yaEaqcjaCaetP6Aima8beJGbIT0deR8Vqjq8QoL6AiG4v1SjGy1(JAKWiF00NF9HtWTpCAFE7dpC7Bb7ZDhcSVCiFOjLydPoUvIrdZ(kFzFE6dN2N3(C3HaZ(6euJHnKJwPTVfSpi3hO7ZctgJuKAFQpp9Ht7ZBFyONf2desuqsMDsSHC0kT9TG9bP(80h0(C3HaZ(6euJHTHbIx1rMQdbeBFDcQXi9HYxguJrIcbGhaKlaaoaIPuDnega(aI5t90ukq8QoL6Aig2qQJ0xzmYGAmsui0h0(w1PuxdXSVob1yK(q5ldQXirHqFcc95Tp3DiWCvJMCsIcs1yKVOkbBLP(7Hy2x5lLRQzt95xFqg3(ee6ZDhcmx1OjNKOGung5lQsWwPoCnjM9v(s5QA2uF(1hKXTpp9bTplmzmYxhW0Bz2xNGAm95FF4pqSY)cLaX2xh7EatapaiXza4aiMs11qya4diw5FHsGy7od1qaX8PEAkfiEOWqwrQRH6dAFVoGPN9LdjFKeRO(8Rp8W)(WP9zHjJr(6aMEBFr03qoAL2(G2Ncl5Ii(Y(G2hXnfSLyvk1ecGyoeCdjFDatVfaK4b8aGeNaGdGykvxdHbGpGyL)fkbIvmf(RvsA9PJdqmFQNMsbIfRVV4lReCFq7tS(u(xOKPyk8xRK06thhjM6OGjwLYGPal67tqOpm0Zumf(RvsA9PJJetDuWeZ(kFzF(3hK7dAFyONPyk8xRK06thhjM6OGj2qoAL2(8VpideZHGBi5Rdy6TaGepGhaKIpaoaIPuDnega(aIv(xOei2bHYqneqmFQNMsbIhkmKvK6AO(G23Rdy6zF5qYhjXkQp)6ZBF4H)9frFE7ZctgJ81bm9wM91jud13c2hEmi1NN(80hO7ZctgJ81bm92(IOVHC0kT9bTpV9XridgYxY4QSsoBifdI(G2N3(w1PuxdX4OCfTKKyKfIK3NGqFCeYGH8Lmokxrlj5lIKw4AQ3YgsXGOpbH(eRpoALsnFwwGf9YGs95PpbH(SWKXiFDatVLzFDc1q95FFE7d)7Bb7ZBF41xe99QHYN9(Qu6GqPLrP6AiS(80NN(ee6ZBFe3uWwIvP0Im60NGqFE7J4Mc2sSkLUOxuFcc9rCtbBjwLsZo1Ppp9bTpX67vdLpZI2gjkiFrKmGgY(mkvxdH1NGqFU7qGbpLdAWk1i1HRzXLWBJvh2QA2uF(fTVfHeU95PpO95TplmzmYxhW0Bz2xNqnuF(3hE423c2N3(WRVi67vdLp79vP0bHslJs11qy95Ppp9bTp1(JAKWiF00NF9bjC7dN2N7oey2xNGAmSHC0kT9TG9Ta95PpO95TpX6ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFcc9rCtbBjwLslYOtFcc9jwFC0kLA(SLqmLM95PpO9PWsUiIVeiMdb3qYxhW0BbajEapaiXdxaCaetP6Aima8beZN6PPuGyfwYfr8LaXk)lucehqdNKOGm1FpeWdas8WdahaXuQUgcdaFaX8PEAkfi2DhcmUkRKZ2WaXk)lucep6kLOTvggkxieapaiXBraCaetP6Aima8beZN6PPuGyV95UdbM91jOgdBd3NGqFQ9h1iHr(OPp)6ds42NN(G2Ny95UdbMfzSFXj2gUpO9jwFU7qGXvzLC2gUpO95TpX6JJwPuZNLfyrVmOuFcc9TQtPUgIXr5kAjjXilejVpbH(4iKbd5lzCuUIwsYxejTW1uVLTH7tqOVkFAGrg9jmzOal6Ld5OvA7Z)(we3(IOpV9Xrj2UEg8q8Yss1uGthkF2xoKCvnBQpp95biw5FHsGyozi7xQrQMcC6q5d8aGepidGdGykvxdHbGpGy(upnLce7Tp3DiWSVob1yyB4(ee6tT)OgjmYhn95xFqc3(80h0(eRp3DiWSiJ9loX2W9bTpX6ZDhcmUkRKZ2W9bTpV9jwFC0kLA(SSal6LbL6tqOVvDk11qmokxrljjgzHi59ji0hhHmyiFjJJYv0ss(IiPfUM6TSnCFcc9v5tdmYOpHjdfyrVCihTsBF(3hhHmyiFjJJYv0ss(IiPfUM6TSHC0kT9frFlqFcc9v5tdmYOpHjdfyrVCihTsBF4xF4HtWTp)7dY42xe95TpokX21ZGhIxwsQMcC6q5Z(YHKRQzt95PppaXk)lucexjxNu)cLapaiXd)bWbqmLQRHWaWhqmFQNMsbIR8Pbgz0NWKHcSOxoKJwPTp)7dpi1NGqFE7ZDhcm4PCqdwPgPoCnlUeEBS6WwvZM6Z)(wes42NGqFU7qGbpLdAWk1i1HRzXLWBJvh2QA2uF(fTVfHeU95PpO95UdbM91jOgdBd3h0(4iKbd5lzCvwjNnKJwPTp)6ds4ceR8Vqjqm5aJ8rJ0fLyapaiXdsa4aiMs11qya4diw5FHsGy7tgJoYGrhciMp1ttPaXdfgYksDnuFq77lhs(ijwr95xF4bP(G2NfMmg5Rdy6Tm7RtOgQp)7d)7dAFkSKlI4l7dAFE7ZDhcmUkRKZgYrR02NF9HhU9ji0Ny95UdbgxLvYzB4(8aeZHGBi5Rdy6TaGepGhaK4Taa4aiMs11qya4diMp1ttPaXe3uWwIvPuti6dAFkSKlI4l7dAFU7qGbpLdAWk1i1HRzXLWBJvh2QA2uF(33Iqc3(G2N3(WqptXu4VwjP1Noosm1rbtSV4lReCFcc9jwFC0kLA(SK4dYGgS(ee6ZctgJ81bm92(8RVf7ZdqSY)cLaXH9aHefKKzNeWdas8Wza4aiMs11qya4diMp1ttPaXU7qGHs6fzLW0Wj4VqjBd3h0(82N7oey2xNGAmSHcdzfPUgQpbH(u7pQrcJ8rtF(1N4JBFEaIv(xOei2(6euJb4bajE4eaCaetP6Aima8beZN6PPuGyoALsnFwwGf9YGs9bTpV9TQtPUgIXr5kAjjXilejVpbH(4iKbd5lzCvwjNTH7tqOp3DiW4QSsoBd3NN(G2hhHmyiFjJJYv0ss(IiPfUM6TSHC0kT95FFG5ymhvC9TG9XPY0N3(u7pQrcJ8rtFGUpiHBFE6dAFU7qGzFDcQXWgYrR02N)9H)aXk)luceBFDcQXa8aGepXhahaXuQUgcdaFaX8PEAkfiMJwPuZNLfyrVmOuFq7ZBFR6uQRHyCuUIwssmYcrY7tqOpoczWq(sgxLvYzB4(ee6ZDhcmUkRKZ2W95PpO9XridgYxY4OCfTKKVisAHRPElBihTsBF(33c0h0(C3HaZ(6euJHTH7dAFe3uWwIvPutiaIv(xOei2(6y3dyc4ba5I4cGdGykvxdHbGpGy(upnLce7UdbgkPxKvYnKoY1YwOKTH7tqOpV9jwF2xNqnetHLCreFzFcc95Tp3DiW4QSsoBihTsBF(3hK6dAFU7qGXvzLC2gUpbH(82N7oeyJUsjABLHHYfcbBihTsBF(3hyogZrfxFlyFCQm95Tp1(JAKWiF00hO7dY42NN(G2N7oeyJUsjABLHHYfcbBd3NN(80h0(w1PuxdXSVob1yK(q5ldQXirHqFq7ZctgJ81bm9wM91jOgtF(3hK7ZtFq7ZBFI13StkGgWe7lhYhAsj2qQJBLy0Wiq0UGHjS(ee6ZctgJ81bm9wM91jOgtF(3hK7ZdqSY)cLaX2xh7EatapaixepaCaetP6Aima8beZN6PPuGyV9rCtbBjwLsnHOpO9XridgYxY4QSsoBihTsBF(1hKWTpbH(82hxKoGjBFr7BX(G23qCr6aMKF5q95FFqQpp9ji0hxKoGjBFr7dY95PpO9PWsUiIVeiw5FHsG4K8jDqOe4ba5IlcGdGykvxdHbGpGy(upnLce7TpIBkylXQuQje9bTpoczWq(sgxLvYzd5OvA7ZV(GeU9ji0N3(4I0bmz7lAFl2h0(gIlshWK8lhQp)7ds95PpbH(4I0bmz7lAFqUpp9bTpfwYfr8LaXk)lucelsnbPdcLapaixeYa4aiMs11qya4diMp1ttPaXE7J4Mc2sSkLAcrFq7JJqgmKVKXvzLC2qoAL2(8RpiHBFcc95TpUiDat2(I23I9bTVH4I0bmj)YH6Z)(GuFE6tqOpUiDat2(I2hK7ZtFq7tHLCreFjqSY)cLaXHTXiDqOe4ba5I4paoaIv(xOei2NotHgjkijZojGykvxdHbGpGhaKlcjaCaetP6Aima8beJGbIT0deR8Vqjq8QoL6AiG4v1SjGylmzmYxhW0Bz2xNqnuF(1h(3xe9fmi00N3(Cu7tdeYv1SP(aDFlIBFE6lI(cgeA6ZBFU7qGzFDS7bmjjhyKpACO8LwKrhM9v(Y(aDF4FFEaIx1rMQdbeBFDc1qYkLwKrhGhaKlUaa4aiMs11qya4diMp1ttPaXe3uWwIz2PoYKe33NGqFe3uWwIPjeYKe33h0(w1PuxdXkRKBiDL6tqOp3DiWiUPGTK0Im6WgYrR02N)9P8VqjZ(6eQHyK4i((j5xouFq7ZDhcmIBkyljTiJoSnCFcc9rCtbBjwLslYOtFq7tS(w1PuxdXSVoHAizLslYOtFcc95UdbgxLvYzd5OvA7Z)(u(xOKzFDc1qmsCeF)K8lhQpO9jwFR6uQRHyLvYnKUs9bTp3DiW4QSsoBihTsBF(3hjoIVFs(Ld1h0(C3HaJRYk5SnCFcc95Udb2ORuI2wzyOCHqW2W9bTplmzmsrQ9P(8RpCzlqFq7ZBFwyYyKVoGP32N)r7dY9ji0Ny99QHYNzrBJefKVisgqdzFgLQRHW6ZtFcc9jwFR6uQRHyLvYnKUs9bTp3DiW4QSsoBihTsBF(1hjoIVFs(LdbeR8VqjqSVrFrapaixeNbGdGyL)fkbITVoHAiGykvxdHbGpGhaKlItaWbqmLQRHWaWhqSY)cLaXZoLk)luknL9bInL9LP6qaXb1yErZg4bEG4GAmVOzdGdaqIhaoaIPuDnega(aI5t90ukqSy9n7KcObmXCvJMCsIcs1yKVOkbBzeiAxWWegqSY)cLaX2xh7EatapaixeahaXuQUgcdaFaXk)luceB3zOgciMp1ttPaXyON5GqzOgInKJwPTp)6BihTslqmhcUHKVoGP3cas8aEaqczaCaeR8VqjqSdcLHAiGykvxdHbGpGh4bITpaoaajEa4aiMs11qya4diw5FHsGyftH)ALKwF64aeZN6PPuGyX6dd9mftH)ALKwF64iXuhfmX(IVSsW9bTpX6t5FHsMIPWFTssRpDCKyQJcMyvkdMcSOVpO95TpX6dd9mftH)ALKwF64ifrQH9fFzLG7tqOpm0Zumf(RvsA9PJJuePg2qoAL2(8Rpi1NN(ee6dd9mftH)ALKwF64iXuhfmXSVYx2N)9b5(G2hg6zkMc)1kjT(0XrIPokyInKJwPTp)7dY9bTpm0Zumf(RvsA9PJJetDuWe7l(YkbdeZHGBi5Rdy6TaGepGhaKlcGdGykvxdHbGpGy(upnLce7TVvDk11qmokxrljjgzHi59bTpX6JJqgmKVKXvzLC2qkge9ji0N7oeyCvwjNTH7ZtFq7tT)OgjmYhn95FF4pU9bTpV95UdbgXnfSLKMDQdBihTsBF(1hE42NGqFU7qGrCtbBjPfz0HnKJwPTp)6dpC7ZtFcc9fkWIE5qoAL2(8Vp8Wfiw5FHsGyokxrlj5lIKw4AQ3c8aGeYa4aiMs11qya4digbdeBPhiw5FHsG4vDk11qaXRQztaXE7ZDhcmUkRKZgYrR02NF9bP(G2N3(C3HaB0vkrBRmmuUqiyd5OvA7ZV(GuFcc9jwFU7qGn6kLOTvggkxieSnCFE6tqOpX6ZDhcmUkRKZ2W9ji0NA)rnsyKpA6Z)(GmU95PpO95TpX6ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFcc9P2FuJeg5JM(8VpiJBFE6dAFE7ZDhcmIBkyljTiJoSHC0kT95xFG5ymhvC9ji0N7oeye3uWwsA2PoSHC0kT95xFG5ymhvC95biEvhzQoeqmg6LdbI21qou(wGhaK4paoaIPuDnega(aIv(xOei2bHYqneqmFQNMsbIhkmKvK6AO(G23Rdy6zF5qYhjXkQp)6dVf7dAFE7tHLCreFzFq7BvNsDnedd9YHar7AihkFBFEaI5qWnK81bm9waqIhWdasibGdGykvxdHbGpGyL)fkbIT7mudbeZN6PPuG4HcdzfPUgQpO996aME2xoK8rsSI6ZV(WBX(G2N3(uyjxeXx2h0(w1PuxdXWqVCiq0UgYHY32NhGyoeCdjFDatVfaK4b8aGCbaWbqmLQRHWaWhqSY)cLaX2NmgDKbJoeqmFQNMsbIhkmKvK6AO(G23Rdy6zF5qYhjXkQp)6dVfOpO95TpfwYfr8L9bTVvDk11qmm0lhceTRHCO8T95biMdb3qYxhW0BbajEapaiXza4aiMs11qya4diMp1ttPaXkSKlI4lbIv(xOeioGgojrbzQ)EiGhaK4eaCaetP6Aima8beZN6PPuGy3DiW4QSsoBddeR8Vqjq8ORuI2wzyOCHqa8aGu8bWbqmLQRHWaWhqmFQNMsbI92N3(C3HaJ4Mc2sslYOdBihTsBF(1hE42NGqFU7qGrCtbBjPzN6WgYrR02NF9HhU95PpO9XridgYxY4QSsoBihTsBF(1hKXTpO95Tp3DiWGNYbnyLAK6W1S4s4TXQdBvnBQp)7Br8h3(ee6tS(MDsb0aMyWt5GgSsnsD4AwCj82y1HrGODbdty95Ppp9ji0N7oeyWt5GgSsnsD4AwCj82y1HTQMn1NFr7BrCgU9ji0hhHmyiFjJRYk5SHumi6dAFE7tT)OgjmYhn95xFIpU9ji03QoL6AiwzLkI6ZdqSY)cLaXKdmYhnsxuIb8aGepCbWbqmLQRHWaWhqmFQNMsbI92NA)rnsyKpA6ZV(eFC7dAFE7ZDhcSLvIneMKCGr(OXHYxsjnGRfsSnCFcc9jwFC0kLA(SLqmLM95PpbH(4Ovk18zzbw0ldk1NGqFR6uQRHyLvQiQpbH(C3HaZ1GqyMT9zB4(G2N7oeyUgecZSTpBihTsBF(33I42xe95TpV9j(9TG9n7KcObmXGNYbnyLAK6W1S4s4TXQdJar7cgMW6ZtFr0N3(4OeBxpdEiEzjPAkWPdLp7lhsUQMn1NN(80NN(G2Ny95UdbgxLvYzB4(G2N3(eRpoALsnFwwGf9YGs9ji0hhHmyiFjJJYv0ss(IiPfUM6TSnCFcc9v5tdmYOpHjdfyrVCihTsBF(3hhHmyiFjJJYv0ss(IiPfUM6TSHC0kT9frFlqFcc9v5tdmYOpHjdfyrVCihTsBF4xF4HtWTp)7BrC7lI(82hhLy76zWdXlljvtboDO8zF5qYv1SP(80NhGyL)fkbI5KHSFPgPAkWPdLpWdas8WdahaXuQUgcdaFaX8PEAkfi2BFQ9h1iHr(OPp)6t8XTpO95Tp3DiWwwj2qysYbg5JghkFjL0aUwiX2W9ji0Ny9XrRuQ5ZwcXuA2NN(ee6JJwPuZNLfyrVmOuFcc9TQtPUgIvwPIO(ee6ZDhcmxdcHz22NTH7dAFU7qG5AqimZ2(SHC0kT95FFqg3(IOpV95TpXVVfSVzNuanGjg8uoObRuJuhUMfxcVnwDyeiAxWWewFE6lI(82hhLy76zWdXlljvtboDO8zF5qYv1SP(80NN(80h0(eRp3DiW4QSsoBd3h0(82Ny9XrRuQ5ZYcSOxguQpbH(4iKbd5lzCuUIwsYxejTW1uVLTH7tqOVkFAGrg9jmzOal6Ld5OvA7Z)(4iKbd5lzCuUIwsYxejTW1uVLnKJwPTVi6Bb6tqOVkFAGrg9jmzOal6Ld5OvA7d)6dpCcU95FFqg3(IOpV9Xrj2UEg8q8Yss1uGthkF2xoKCvnBQpp95biw5FHsG4k56K6xOe4bajElcGdGykvxdHbGpGyemqSLEGyL)fkbIx1PuxdbeVQMnbe7TpX6JJqgmKVKXvzLC2qkge9ji0Ny9TQtPUgIXr5kAjjXilejVpO9XrRuQ5ZYcSOxguQppaXR6it1HaIT6kjdOrYvzLCGhaK4bzaCaetP6Aima8beZN6PPuGyIBkylXQuQje9bTpfwYfr8L9bTp3DiWGNYbnyLAK6W1S4s4TXQdBvnBQp)7Br8h3(G2N3(WqptXu4VwjP1Noosm1rbtSV4lReCFcc9jwFC0kLA(SK4dYGgS(80h0(w1PuxdXS6kjdOrYvzLCGyL)fkbId7bcjkijZojGhaK4H)a4aiMs11qya4diMp1ttPaXU7qGHs6fzLW0Wj4VqjBd3h0(C3HaZ(6euJHnuyiRi11qaXk)luceBFDcQXa8aGepibGdGykvxdHbGpGy(upnLce7UdbM91XGgm2qoAL2(8Vpi1h0(82N7oeye3uWwsArgDyd5OvA7ZV(GuFcc95UdbgXnfSLKMDQdBihTsBF(1hK6ZtFq7tT)OgjmYhn95xFIpUaXk)luceZ1KtgP7oeaID3HGmvhci2(6yqdgWdas8waaCaetP6Aima8beZN6PPuGyoALsnFwwGf9YGs9bTVvDk11qmokxrljjgzHi59bTpoczWq(sghLROLK8frslCn1Bzd5OvA7Z)(GeqSY)cLaX2xh7EatapaiXdNbGdGykvxdHbGpGy(upnLce)QHYNzFYy0rInv4zuQUgcRpO9jwFVAO8z2xhdAWyuQUgcRpO95UdbM91jOgdBOWqwrQRH6dAFE7ZDhcmIBkyljn7uh2qoAL2(8RVfOpO9rCtbBjwLsZo1PpO95Udbg8uoObRuJuhUMfxcVnwDyRQzt95FFlcjC7tqOp3DiWGNYbnyLAK6W1S4s4TXQdBvnBQp)I23Iqc3(G2NA)rnsyKpA6ZV(eFC7tqOpm0Zumf(RvsA9PJJetDuWeBihTsBF(1hoPpbH(u(xOKPyk8xRK06thhjM6OGjwLYGPal67ZtFq7tS(4iKbd5lzCvwjNnKIbbqSY)cLaX2xNGAmapaiXdNaGdGykvxdHbGpGy(upnLce7UdbgkPxKvYnKoY1YwOKTH7tqOp3DiWwwj2qysYbg5JghkFjL0aUwiX2W9ji0N7oeyCvwjNTH7dAFE7ZDhcSrxPeTTYWq5cHGnKJwPTp)7dmhJ5OIRVfSpovM(82NA)rnsyKpA6d09bzC7ZtFq7ZDhcSrxPeTTYWq5cHGTH7tqOpX6ZDhcSrxPeTTYWq5cHGTH7dAFI1hhHmyiFjB0vkrBRmmuUqiydPyq0NGqFI1hhTsPMpBLYxeetFE6tqOp1(JAKWiF00NF9j(42h0(iUPGTeRsPMqaeR8VqjqS91XUhWeWdas8eFaCaetP6Aima8beZN6PPuG4xnu(m7RJbnymkvxdH1h0(82N7oey2xhdAWyB4(ee6tT)OgjmYhn95xFIpU95PpO95UdbM91XGgmM9v(Y(8Vpi3h0(82N7oeye3uWwsArgDyB4(ee6ZDhcmIBkyljn7uh2gUpp9bTp3DiWGNYbnyLAK6W1S4s4TXQdBvnBQp)7BrCgU9bTpV9XridgYxY4QSsoBihTsBF(1hE42NGqFI13QoL6AighLROLKeJSqK8(G2hhTsPMpllWIEzqP(8aeR8VqjqS91XUhWeWdaYfXfahaXuQUgcdaFaX8PEAkfi2BFU7qGbpLdAWk1i1HRzXLWBJvh2QA2uF(33I4mC7tqOp3DiWGNYbnyLAK6W1S4s4TXQdBvnBQp)7BriHBFq77vdLpZ(KXOJeBQWZOuDnewFE6dAFU7qGrCtbBjPfz0HnKJwPTp)6dN1h0(iUPGTeRsPfz0PpO9jwFU7qGHs6fzLW0Wj4VqjBd3h0(eRVxnu(m7RJbnymkvxdH1h0(4iKbd5lzCvwjNnKJwPTp)6dN1h0(82hhHmyiFjBzLydHjTW1uVLnKJwPTp)6dN1NGqFI1hhTsPMpBjetPzFEaIv(xOei2(6y3dyc4ba5I4bGdGykvxdHbGpGy(upnLce7Tp3DiWiUPGTK0StDyB4(ee6ZBFCr6aMS9fTVf7dAFdXfPdys(Ld1N)9bP(80NGqFCr6aMS9fTpi3NN(G2Ncl5Ii(Y(G23QoL6AiMvxjzansUkRKdeR8VqjqCs(Koiuc8aGCXfbWbqmLQRHWaWhqmFQNMsbI92N7oeye3uWwsA2PoSnCFq7tS(4Ovk18zlHykn7tqOpV95Udb2YkXgctsoWiF04q5lPKgW1cj2gUpO9XrRuQ5ZwcXuA2NN(ee6ZBFCr6aMS9fTVf7dAFdXfPdys(Ld1N)9bP(80NGqFCr6aMS9fTpi3NGqFU7qGXvzLC2gUpp9bTpfwYfr8L9bTVvDk11qmRUsYaAKCvwjhiw5FHsGyrQjiDqOe4ba5IqgahaXuQUgcdaFaX8PEAkfi2BFU7qGrCtbBjPzN6W2W9bTpX6JJwPuZNTeIP0SpbH(82N7oeylReBimj5aJ8rJdLVKsAaxlKyB4(G2hhTsPMpBjetPzFE6tqOpV9XfPdyY2x0(wSpO9nexKoGj5xouF(3hK6ZtFcc9XfPdyY2x0(GCFcc95UdbgxLvYzB4(80h0(uyjxeXx2h0(w1PuxdXS6kjdOrYvzLCGyL)fkbIdBJr6GqjWdaYfXFaCaeR8VqjqSpDMcnsuqsMDsaXuQUgcdaFapaixesa4aiMs11qya4diMp1ttPaXe3uWwIvP0StD6tqOpIBkylXSiJoYKe33NGqFe3uWwIPjeYKe33NGqFU7qG5tNPqJefKKzNeBd3h0(C3HaJ4Mc2ssZo1HTH7tqOpV95UdbgxLvYzd5OvA7Z)(u(xOK5B0xeJehX3pj)YH6dAFU7qGXvzLC2gUppaXk)luceBFDc1qapaixCbaWbqSY)cLaX(g9fbetP6Aima8b8aGCrCgaoaIPuDnega(aIv(xOeiE2Pu5FHsPPSpqSPSVmvhcioOgZlA2apWdedpeh54QpaoaajEa4aiw5FHsGyhekxwPmGghGykvxdHbGpGhaKlcGdGyL)fkbIxwj2qyslCn1BbIPuDnega(aEaqczaCaetP6Aima8beR8VqjqSVrFraX8PEAkfi2BFe3uWwIz2PoYKe33NGqFe3uWwIvP0StD6tqOpIBkylXQu6IEr9ji0hXnfSLyAcHmjX995bi2ujj5yaX4HlWdas8hahaXuQUgcdaFaX8PEAkfi2BFe3uWwIz2PoYKe33NGqFe3uWwIvP0StD6tqOpIBkylXQu6IEr9ji0hXnfSLyAcHmjX995PpO9bp0kdpMVrFr9bTpX6dEOv2ImFJ(IaIv(xOei23OViGhaKqcahaXuQUgcdaFaX8PEAkfiwS(MDsb0aMyUQrtojrbPAmYxuLGTmkvxdH1NGqFI1hhTsPMpllWIEzqP(ee6tS(SWKXiFDatVLzFDcQX0x0(WRpbH(eRVxnu(Su)9qwPRA0KtmkvxdHbeR8VqjqS91judb8aGCbaWbqmLQRHWaWhqmFQNMsbINDsb0aMyUQrtojrbPAmYxuLGTmkvxdH1h0(4Ovk18zzbw0ldk1h0(SWKXiFDatVLzFDcQX0x0(Wdiw5FHsGy7RJDpGjGh4bEG4vASfkba5I4UiU4TiU4mGyF6Kvc2cedcgeeoFqIZdKGajE6RpCiI6RCGrZ3xan9jEXgsDCReJgXBFdbI21qy9zrouF6(ro6ty9XfPjyYY6ibXvs9TO4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90Nx8eNhwhjiUsQp8Wt80hieLR08ewFXLdiSple5RIRp8d)67r9bI3AFoiSTzB7dbtJ(OPpV4NN(8IN48W6ibXvs9H3IIN(aHOCLMNW6lUCaH9zHiFvC9HF4xFpQpq8w7ZbHTnBBFiyA0hn95f)80Nx8eNhwhjiUsQp8GK4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90Nx8eNhwhzhjiyqq48bjopqccK4PV(WHiQVYbgnFFb00N4fJc628I3(gceTRHW6ZICO(09JC0NW6JlstWKL1rcIRK6Bbep9bcr5knpH1xC5ac7Zcr(Q46d)67r9bI3AFy1Azlu2hcMg9rtFEbTN(8UO48W6i7ibbdccNpiX5bsqGep91hoer9voWO57lGM(eVWdXroU6lE7Biq0UgcRplYH6t3pYrFcRpUinbtwwhjiUsQpijE6deIYvAEcRpX7StkGgWedeyXBFpQpX7StkGgWedeygLQRHWeV95fpX5H1rcIRK6Bbep9bcr5knpH1N4D2jfqdyIbcS4TVh1N4D2jfqdyIbcmJs11qyI3(8IN48W6i7ibbdccNpiX5bsqGep91hoer9voWO57lGM(eVkIeV9neiAxdH1Nf5q9P7h5OpH1hxKMGjlRJeexj13IIN(aHOCLMNW6t8o7KcObmXabw823J6t8o7KcObmXabMrP6AimXBFEXtCEyDKG4kP(GS4PpqikxP5jS(IlhqyFwiYxfxF4h(13J6deV1(CqyBZ22hcMg9rtFEXpp95fpX5H1rcIRK6dsIN(aHOCLMNW6lUCaH9zHiFvC9HF99O(aXBTpSATSfk7dbtJ(OPpVG2tFEXtCEyDKG4kP(eFXtFGquUsZty9fxoGW(SqKVkU(WV(EuFG4T2hwTw2cL9HGPrF00Nxq7PpV4jopSosqCLuF4bzXtFGquUsZty9fxoGW(SqKVkU(Wp8RVh1hiER95GW2MTTpemn6JM(8IFE6ZlEIZdRJeexj1hE4eXtFGquUsZty9fxoGW(SqKVkU(WV(EuFG4T2hwTw2cL9HGPrF00Nxq7PpV4jopSosqCLuFlIR4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90Nx8eNhwhjiUsQVfHK4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90N3ffNhwhzhjiyqq48bjopqccK4PV(WHiQVYbgnFFb00N41(I3(gceTRHW6ZICO(09JC0NW6JlstWKL1rcIRK6dpCfp9bcr5knpH1xC5ac7Zcr(Q46d)WV(EuFG4T2NdcBB22(qW0OpA6Zl(5PpV4jopSosqCLuF4HN4PpqikxP5jS(IlhqyFwiYxfxF4h(13J6deV1(CqyBZ22hcMg9rtFEXpp95fpX5H1rcIRK6dpCI4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90Nx8eNhwhzhjiyqq48bjopqccK4PV(WHiQVYbgnFFb00N41fPV4TVHar7AiS(SihQpD)ih9jS(4I0emzzDKG4kP(WBbep9bcr5knpH1xC5ac7Zcr(Q46d)67r9bI3AFy1Azlu2hcMg9rtFEbTN(8czX5H1rcIRK6dpCM4PpqikxP5jS(IlhqyFwiYxfxF4xFpQpq8w7dRwlBHY(qW0OpA6ZlO90Nx8eNhwhzhjophy08ewF4S(u(xOSptzFlRJei2ctCaqIhUlcedpOqziGyCU(WNA0Kt9bcGzxyDK4C9bcaItoU00hobu9TiUlIBhzhjoxFGqrAcMSINosCU(WP9bccdJW6lgz0Pp8rQdRJeNRpCAFGqrAcMW671bm9Yk0hxTKTVh1hhcUHKVoGP3Y6iX56dN2hoFYbTsy9TZK4K1Qde9TQtPUgY2N3Irmq1h8qRs7RJDpGP(WP(1h8qRm7RJDpGjpSosCU(WP9bcAfvy9bpexTFLG7de8OVO(QqF1lET99IO(8nOeCFGaKBkylX6i7iv(xO0YGhIJCC1pQdcLlRugqJthPY)cLwg8qCKJR(ref0lReBimPfUM6TDKk)luAzWdXroU6hruq7B0xeOmvssowu8WfuviQxIBkylXm7uhzsI7feiUPGTeRsPzN6iiqCtbBjwLsx0lsqG4Mc2smnHqMK4EpDKk)luAzWdXroU6hruq7B0xeOQquVe3uWwIz2PoYKe3liqCtbBjwLsZo1rqG4Mc2sSkLUOxKGaXnfSLyAcHmjX9EGcp0kdpMVrFrqfdEOv2ImFJ(I6iv(xO0YGhIJCC1pIOG2(6eQHavfIk2StkGgWeZvnAYjjkivJr(IQeSvqqmoALsnFwwGf9YGsccIzHjJr(6aMElZ(6euJjkEccI9QHYNL6VhYkDvJMCIrP6AiSosL)fkTm4H4ihx9JikOTVo29aMavfIo7KcObmXCvJMCsIcs1yKVOkbBHYrRuQ5ZYcSOxgucQfMmg5Rdy6Tm7RtqnMO41r2rIZ1hiafhX3pH1hTsde99Ld13lI6t5pA6RS9PRAzuxdX6iv(xO0g1Im6iDj1PJu5FHsB0vDk11qGkvhkAzLkIa1QA2uulmzmYxhW0Bz2xNGAm(HhuVI9QHYNzFDmObJrP6AimbHxnu(m7tgJosSPcpJs11qyEeeSWKXiFDatVLzFDcQX43IDKk)luAJikOx1PuxdbQuDOOLvYnKUsGAvnBkQfMmg5Rdy6Tm7RtOgYp86iv(xO0gruq7sJLMLvcguviQxX4Ovk18zzbw0ldkjiighHmyiFjJJYv0ss(IiPfUM6TSnShOU7qGXvzLC2gUJu5FHsBerbnm6lucQke1DhcmUkRKZ2WDKk)luAJikOx1PuxdbQuDOOCuUIwssmYcrYb1QA2u0GbHgVER8Pbgz0NWKHcSOxoKJwPfNUiU4uoczWq(sghLROLK8frslCn1Bzd5OvA9GF4TiUE8lyqOXR3kFAGrg9jmzOal6Ld5OvAXPlcjCQx8WDbF1q5ZQKRtQFHsgLQRHW8Gt9Yrj2UEg8q8Yss1uGthkF2xoKCvnBYdoLJqgmKVKXvzLC2qoALwp4hE4eC9iiWridgYxY4QSsoBihTsRFv(0aJm6tyYqbw0lhYrR0kiWridgYxY4OCfTKKVisAHRPElBihTsRFv(0aJm6tyYqbw0lhYrR0kiighTsPMpllWIEzqPosL)fkTref0BljRNCavQou0kT8z)QRHKGOTM)2rIrRfNavfI6UdbgxLvYzB4osCU(u(xO0gruqVTKSEYXckRb92O)u5s6XduviQy)u5s6z4XePwj8G4mnHaQxX(PYL0ZwKjsTs4bXzAcHGGy)u5s6zlYgsXGqYridgYx6rqWDhcmUkRKZ2WccCeYGH8LmUkRKZgYrR0ItXdx)(PYL0ZWJXridgYxYW2J(fkHkghTsPMpBjetPPGahTsPMpllWIEzqjOR6uQRHyCuUIwssmYcrYHYridgYxY4OCfTKKVisAHRPElBdli4Udb2YkXgctsoWiF04q5lPKgW1cj2gwqiuGf9YHC0kT(ViUDK4C9P8VqPnIOGEBjz9KJfuwd6Tr)PYL0ViOQquX(PYL0ZwKjsTs4bXzAcbuVI9tLlPNHhtKALWdIZ0ecbbX(PYL0ZWJnKIbHKJqgmKV0JGWpvUKEgEmrQvcpiottiG(tLlPNTitKALWdIZ0ecOI9tLlPNHhBifdcjhHmyiFPGG7oeyCvwjNTHfe4iKbd5lzCvwjNnKJwPfNIhU(9tLlPNTiJJqgmKVKHTh9lucvmoALsnF2siMstbboALsnFwwGf9YGsqx1PuxdX4OCfTKKyKfIKdLJqgmKVKXr5kAjjFrK0cxt9w2gwqWDhcSLvIneMKCGr(OXHYxsjnGRfsSnSGqOal6Ld5OvA9FrC7i7iv(xO0gruqVTKSEYX2rQ8VqPnIOGE2Pu5FHsPPSpOs1HIQicu2Fk(hfpqvHOR6uQRHyLvQiQJu5FHsBerb9StPY)cLstzFqLQdffBi1XTsmAaL9NI)rXduvi6StkGgWe7lhYhAsj2qQJBLy0Wiq0UGHjSosL)fkTref0ZoLk)luknL9bvQouuxK(GY(tX)O4bQkeD2jfqdyI5Qgn5KefKQXiFrvc2Yiq0UGHjSosL)fkTref0ZoLk)luknL9bvQouu73r2rQ8VqPLPik6QoL6AiqLQdffBi1r6Rmgzqngjkea1QA2uuVU7qG9Ld5dnPeBi1XTsmAyd5OvA9hmhJ5OIlcCz4ji4Udb2xoKp0KsSHuh3kXOHnKJwP1FL)fkz2xNqneJehX3pj)YHIaxgEq9sCtbBjwLsZo1rqG4Mc2smlYOJmjX9cce3uWwIPjeYKe37Xdu3DiW(YH8HMuInK64wjgnSnm0zNuanGj2xoKp0KsSHuh3kXOHrGODbdtyDKk)luAzkIIikO5OCfTKKVisAHRPElOQquVR6uQRHyCuUIwssmYcrYHkghHmyiFjJRYk5SHumieeC3HaJRYk5SnShOQ9h1iHr(OXFiHluVU7qGrCtbBjPzN6WgYrR063cii4UdbgXnfSLKwKrh2qoALw)wapq9k2StkGgWeZvnAYjjkivJr(IQeSvqWDhcmx1OjNKOGung5lQsWwzQ)EiM9v(s5QA2KFqgxbb3DiWCvJMCsIcs1yKVOkbBL6W1Ky2x5lLRQzt(bzC9iiekWIE5qoALw)Xd3osL)fkTmfrref02xNGAmGQcrD3HaZ(6euJHnuyiRi11qq9AHjJr(6aMElZ(6euJXFilii2StkGgWe7lhYhAsj2qQJBLy0Wiq0UGHjmpq9k2StkGgWeZabxh1kdgI(kblbBkhylXiq0UGHjmbHVCi8d)WFi5N7oey2xNGAmSHC0kTrSONosL)fkTmfrref02xNGAmGQcrNDsb0aMyF5q(qtkXgsDCReJggbI2fmmHb1ctgJ81bm9wM91jOgJFrHmuVI5Udb2xoKp0KsSHuh3kXOHTHH6UdbM91jOgdBOWqwrQRHee8UQtPUgIHnK6i9vgJmOgJefcq96UdbM91jOgdBihTsR)qwqWctgJ81bm9wM91jOgJFlc9vdLpZ(KXOJeBQWZOuDnegu3DiWSVob1yyd5OvA9hsE84PJu5FHsltruerb9QoL6AiqLQdf1(6euJr6dLVmOgJefcGAvnBkQA)rnsyKpA8dNGlo1lE4UGU7qG9Ld5dnPeBi1XTsmAy2x5l9Gt96UdbM91jOgdBihTs7ccz8ZctgJuKAFYdo1lg6zH9aHefKKzNeBihTs7ccjpqD3HaZ(6euJHTH7iv(xO0YuefruqBFDS7bmbQkeDvNsDnedBi1r6RmgzqngjkeGUQtPUgIzFDcQXi9HYxguJrIcbbbVU7qG5Qgn5KefKQXiFrvc2kt93dXSVYxkxvZM8dY4ki4UdbMRA0KtsuqQgJ8fvjyRuhUMeZ(kFPCvnBYpiJRhOwyYyKVoGP3YSVob1y8h)7iv(xO0YuefruqB3zOgcuCi4gs(6aMEBu8avfIouyiRi11qqFDatp7lhs(ijwr(Hh(JtTWKXiFDatVnIHC0kTqvyjxeXxcL4Mc2sSkLAcrhPY)cLwMIOiIcAftH)ALKwF64akoeCdjFDatVnkEGQcrf7l(YkbdvmL)fkzkMc)1kjT(0XrIPokyIvPmykWIEbbm0Zumf(RvsA9PJJetDuWeZ(kFP)qgkg6zkMc)1kjT(0XrIPokyInKJwP1Fi3rQ8VqPLPikIOG2bHYqneO4qWnK81bm92O4bQkeDOWqwrQRHG(6aME2xoK8rsSI8ZlE4FeETWKXiFDatVLzFDc1qliEmi5Xd(zHjJr(6aMEBed5OvAH6LJqgmKVKXvzLC2qkgeq9UQtPUgIXr5kAjjXilejxqGJqgmKVKXr5kAjjFrK0cxt9w2qkgeccIXrRuQ5ZYcSOxguYJGGfMmg5Rdy6Tm7RtOgYFV4)c6fViE1q5ZEFvkDqO0YOuDneMhpccEjUPGTeRsPfz0rqWlXnfSLyvkDrVibbIBkylXQuA2PoEGk2RgkFMfTnsuq(IizanK9zuQUgctqWDhcm4PCqdwPgPoCnlUeEBS6WwvZM8l6Iqcxpq9AHjJr(6aMElZ(6eQH8hpCxqV4fXRgkF27RsPdcLwgLQRHW84bQA)rnsyKpA8ds4ItD3HaZ(6euJHnKJwPDbxapq9kM7oeylReBimj5aJ8rJdLVKsAaxlKyBybbIBkylXQuArgDeeeJJwPuZNTeIP00dufwYfr8LDKk)luAzkIIikOdOHtsuqM6VhcuviQcl5Ii(YosL)fkTmfrref0JUsjABLHHYfcbOQqu3DiW4QSsoBd3rQ8VqPLPikIOGMtgY(LAKQPaNou(GQcr96UdbM91jOgdBdliO2FuJeg5Jg)GeUEGkM7oeywKX(fNyByOI5UdbgxLvYzByOEfJJwPuZNLfyrVmOKGWQoL6AighLROLKeJSqKCbboczWq(sghLROLK8frslCn1BzBybHkFAGrg9jmzOal6Ld5OvA9FrCJWlhLy76zWdXlljvtboDO8zF5qYv1SjpE6iv(xO0YuefruqxjxNu)cLGQcr96UdbM91jOgdBdliO2FuJeg5Jg)GeUEGkM7oeywKX(fNyByOI5UdbgxLvYzByOEfJJwPuZNLfyrVmOKGWQoL6AighLROLKeJSqKCbboczWq(sghLROLK8frslCn1BzBybHkFAGrg9jmzOal6Ld5OvA9NJqgmKVKXr5kAjjFrK0cxt9w2qoAL2iwabHkFAGrg9jmzOal6Ld5OvAXp8dpCcU(dzCJWlhLy76zWdXlljvtboDO8zF5qYv1SjpE6iv(xO0YuefruqtoWiF0iDrjgOQq0kFAGrg9jmzOal6Ld5OvA9hpiji41Dhcm4PCqdwPgPoCnlUeEBS6WwvZM8FriHRGG7oeyWt5GgSsnsD4AwCj82y1HTQMn5x0fHeUEG6UdbM91jOgdBddLJqgmKVKXvzLC2qoALw)GeUDKk)luAzkIIikOTpzm6idgDiqXHGBi5Rdy6TrXduvi6qHHSIuxdb9lhs(ijwr(HhKGAHjJr(6aMElZ(6eQH8h)HQWsUiIVeQx3DiW4QSsoBihTsRF4HRGGyU7qGXvzLC2g2thPY)cLwMIOiIc6WEGqIcsYStcuvikXnfSLyvk1ecOkSKlI4lH6Udbg8uoObRuJuhUMfxcVnwDyRQzt(ViKWfQxm0Zumf(RvsA9PJJetDuWe7l(YkbliighTsPMplj(GmObtqWctgJ81bm9w)w0thPY)cLwMIOiIcA7RtqngqvHOU7qGHs6fzLW0Wj4VqjBdd1R7oey2xNGAmSHcdzfPUgsqqT)OgjmYhn(j(46PJu5FHsltruerbT91jOgdOQquoALsnFwwGf9YGsq9UQtPUgIXr5kAjjXilejxqGJqgmKVKXvzLC2gwqWDhcmUkRKZ2WEGYridgYxY4OCfTKKVisAHRPElBihTsR)G5ymhvCliNkJx1(JAKWiF0GFqcxpqD3HaZ(6euJHnKJwP1F8VJu5FHsltruerbT91XUhWeOQquoALsnFwwGf9YGsq9UQtPUgIXr5kAjjXilejxqGJqgmKVKXvzLC2gwqWDhcmUkRKZ2WEGYridgYxY4OCfTKKVisAHRPElBihTsR)lau3DiWSVob1yyByOe3uWwIvPuti6iv(xO0YuefruqBFDS7bmbQke1DhcmusViRKBiDKRLTqjBdli4vm7RtOgIPWsUiIVuqWR7oeyCvwjNnKJwP1Fib1DhcmUkRKZ2WccED3HaB0vkrBRmmuUqiyd5OvA9hmhJ5OIBb5uz8Q2FuJeg5Jg8dY46bQ7oeyJUsjABLHHYfcbBd7Xd0vDk11qm7RtqngPpu(YGAmsuia1ctgJ81bm9wM91jOgJ)q2duVIn7KcObmX(YH8HMuInK64wjgnmceTlyyctqWctgJ81bm9wM91jOgJ)q2thPY)cLwMIOiIc6K8jDqOeuviQxIBkylXQuQjeq5iKbd5lzCvwjNnKJwP1piHRGGxUiDat2OlcDiUiDatYVCi)HKhbbUiDat2Oq2dufwYfr8LDKk)luAzkIIikOfPMG0bHsqvHOEjUPGTeRsPMqaLJqgmKVKXvzLC2qoALw)GeUccE5I0bmzJUi0H4I0bmj)YH8hsEee4I0bmzJczpqvyjxeXx2rQ8VqPLPikIOGoSngPdcLGQcr9sCtbBjwLsnHakhHmyiFjJRYk5SHC0kT(bjCfe8YfPdyYgDrOdXfPdys(Ld5pK8iiWfPdyYgfYEGQWsUiIVSJu5FHsltruerbTpDMcnsuqsMDsDKk)luAzkIIikOx1PuxdbQuDOO2xNqnKSsPfz0buRQztrTWKXiFDatVLzFDc1q(H)remi041rTpnqixvZMWVfX1tebdcnED3HaZ(6y3dyssoWiF04q5lTiJom7R8L4h(7PJu5FHsltruerbTVrFrGQcrjUPGTeZStDKjjUxqG4Mc2smnHqMK4EOR6uQRHyLvYnKUsccU7qGrCtbBjPfz0HnKJwP1FL)fkz2xNqneJehX3pj)YHG6UdbgXnfSLKwKrh2gwqG4Mc2sSkLwKrhOITQtPUgIzFDc1qYkLwKrhbb3DiW4QSsoBihTsR)k)luYSVoHAigjoIVFs(LdbvSvDk11qSYk5gsxjOU7qGXvzLC2qoALw)jXr89tYVCiOU7qGXvzLC2gwqWDhcSrxPeTTYWq5cHGTHHAHjJrksTp5hUSfaQxlmzmYxhW0B9pkKfee7vdLpZI2gjkiFrKmGgY(mkvxdH5rqqSvDk11qSYk5gsxjOU7qGXvzLC2qoALw)iXr89tYVCOosL)fkTmfrref02xNqnuhPY)cLwMIOiIc6zNsL)fkLMY(GkvhkAqnMx0S7i7iv(xO0YCr6hD0vkrBRmmuUqiavfI6UdbgxLvYzB4osL)fkTmxK(ref0R6uQRHavQouu(uFI(nmOwvZMIkM7oeyUQrtojrbPAmYxuLGTYu)9qSnmuXC3HaZvnAYjjkivJr(IQeSvQdxtITH7iv(xO0YCr6hruqRyk8xRK06thhqXHGBi5Rdy6TrXduviQ7oeyUQrtojrbPAmYxuLGTYu)9qm7R8LYv1Sj)XFCH6UdbMRA0KtsuqQgJ8fvjyRuhUMeZ(kFPCvnBYF8hxOEfdd9mftH)ALKwF64iXuhfmX(IVSsWqft5FHsMIPWFTssRpDCKyQJcMyvkdMcSOhQxXWqptXu4VwjP1NoosrKAyFXxwjybbm0Zumf(RvsA9PJJuePg2qoALw)GShbbm0Zumf(RvsA9PJJetDuWeZ(kFP)qgkg6zkMc)1kjT(0XrIPokyInKJwP1Fibfd9mftH)ALKwF64iXuhfmX(IVSsWE6iv(xO0YCr6hruqZr5kAjjFrK0cxt9wqvHOEx1PuxdX4OCfTKKyKfIKdvmoczWq(sgxLvYzdPyqii4UdbgxLvYzBypq96UdbMRA0KtsuqQgJ8fvjyRm1FpeZ(kFPCvnBkkKWvqWDhcmx1OjNKOGung5lQsWwPoCnjM9v(s5QA2uuiHRhbHqbw0lhYrR06pE42rQ8VqPL5I0pIOGMRjNms3DiaQuDOO2xhdAWavfI61Dhcmx1OjNKOGung5lQsWwzQ)Ei2qoALw)WFgKeeC3HaZvnAYjjkivJr(IQeSvQdxtInKJwP1p8Nbjpqv7pQrcJ8rJFrfFCH6LJqgmKVKXvzLC2qoALw)WzccE5iKbd5lzKdmYhnsxuIXgYrR06hodQyU7qGTSsSHWKKdmYhnou(skPbCTqITHHYrRuQ5ZwcXuA6XthPY)cLwMls)iIcA7RJDpGjqvHOITQtPUgIXN6t0VHH6LJwPuZNLfyrVmOKGahHmyiFjJRYk5SHC0kT(HZee8YridgYxYihyKpAKUOeJnKJwP1pCguXC3HaBzLydHjjhyKpACO8Lusd4AHeBddLJwPuZNTeIP00JNosL)fkTmxK(ref02xh7EatGQcr9YridgYxY4OCfTKKVisAHRPElBihTsR)qcQ3vDk11qmokxrljjgzHi5ccCeYGH8LmUkRKZgYrR06pK84bQA)rnsyKpA8d)XfkhTsPMpllWIEzqPosL)fkTmxK(ref02DgQHafhcUHKVoGP3gfpqvHOdfgYksDne0xhW0Z(YHKpsIvKF4Taq9QWsUiIVeQ3vDk11qm(uFI(nSGGx1(JAKWiF04pKXfQyU7qGXvzLC2g2JGahHmyiFjJRYk5SHumi84PJu5FHslZfPFerbTdcLHAiqXHGBi5Rdy6TrXduvi6qHHSIuxdb91bm9SVCi5JKyf5hEqMbjOEvyjxeXxc17QoL6AigFQpr)gwqWRA)rnsyKpA8hY4cvm3DiW4QSsoBd7rqGJqgmKVKXvzLC2qkgeEGkM7oeylReBimj5aJ8rJdLVKsAaxlKyBypDKk)luAzUi9JikOTpzm6idgDiqXHGBi5Rdy6TrXduvi6qHHSIuxdb91bm9SVCi5JKyf5hElqed5OvAH6vHLCreFjuVR6uQRHy8P(e9Bybb1(JAKWiF04pKXvqGJqgmKVKXvzLC2qkgeE80rQ8VqPL5I0pIOGoGgojrbzQ)EiqvHOkSKlI4l7iv(xO0YCr6hruqh2desuqsMDsGQcr9sCtbBjwLsnHqqG4Mc2smlYOJSsjEcce3uWwIz2PoYkL45bQxX4Ovk18zzbw0ldkji4vT)OgjmYhn(l(qcQ3vDk11qm(uFI(nSGGA)rnsyKpA8hY4kiSQtPUgIvwPIipq9UQtPUgIXr5kAjjXilejhQyCeYGH8Lmokxrlj5lIKw4AQ3Y2WccITQtPUgIXr5kAjjXilejhQyCeYGH8LmUkRKZ2WE84bQxoczWq(sgxLvYzd5OvA9dY4kiO2FuJeg5Jg)eFCHYridgYxY4QSsoBdd1lhHmyiFjJCGr(Or6Ism2qoALw)v(xOKzFDc1qmsCeF)K8lhsqqmoALsnF2siMstpccv(0aJm6tyYqbw0lhYrR06pE46bQxm0Zumf(RvsA9PJJetDuWeBihTsRF4VGGyC0kLA(SK4dYGgmpDKk)luAzUi9JikOxwj2qyslCn1BbvfI6L4Mc2smZo1rMK4EbbIBkylXSiJoYKe3liqCtbBjMMqitsCVGG7oeyUQrtojrbPAmYxuLGTYu)9qSHC0kT(H)miji4UdbMRA0KtsuqQgJ8fvjyRuhUMeBihTsRF4pdsccQ9h1iHr(OXpXhxOCeYGH8LmUkRKZgsXGWduVCeYGH8LmUkRKZgYrR06hKXvqGJqgmKVKXvzLC2qkgeEeeQ8Pbgz0NWKHcSOxoKJwP1F8WTJu5FHslZfPFerbnNmK9l1ivtboDO8bvfI6vT)OgjmYhn(j(4c1R7oeylReBimj5aJ8rJdLVKsAaxlKyBybbX4Ovk18zlHykn9iiWrRuQ5ZYcSOxgusqWDhcmxdcHz22NTHH6UdbMRbHWmB7ZgYrR06)I4gHxokX21ZGhIxwsQMcC6q5Z(YHKRQztE8a17QoL6AighLROLKeJSqKCbboczWq(sghLROLK8frslCn1BzdPyq4rqOYNgyKrFctgkWIE5qoALw)xe3i8Yrj2UEg8q8Yss1uGthkF2xoKCvnBYthPY)cLwMls)iIc6k56K6xOeuviQx1(JAKWiF04N4JluVU7qGTSsSHWKKdmYhnou(skPbCTqITHfeeJJwPuZNTeIP00JGahTsPMpllWIEzqjbb3DiWCnieMzBF2ggQ7oeyUgecZSTpBihTsR)qg3i8Yrj2UEg8q8Yss1uGthkF2xoKCvnBYJhOEx1PuxdX4OCfTKKyKfIKliWridgYxY4OCfTKKVisAHRPElBifdcpccv(0aJm6tyYqbw0lhYrR06pKXncVCuITRNbpeVSKunf40HYN9LdjxvZM80rQ8VqPL5I0pIOGEvNsDneOs1HIQwyqaPjM4GAvnBkkXnfSLyvkn7uNfeNGFk)luYSVoHAigjoIVFs(LdfHye3uWwIvP0StDwWfa)u(xOK5B0xeJehX3pj)YHIax2I4NfMmgPi1(uhPY)cLwMls)iIcA7RJDpGjqvHOER8Pbgz0NWKHcSOxoKJwP1F8xqWR7oeyJUsjABLHHYfcbBihTsR)G5ymhvCliNkJx1(JAKWiF0GFqgxpqD3HaB0vkrBRmmuUqiyBypEee8Q2FuJeg5JMiw1PuxdXulmiG0et8f0DhcmIBkyljTiJoSHC0kTrGHEwypqirbjz2jX(IV0khYrRCbxKbj)WBrCfeu7pQrcJ8rteR6uQRHyQfgeqAIj(c6UdbgXnfSLKMDQdBihTsBeyONf2desuqsMDsSV4lTYHC0kxWfzqYp8wexpqjUPGTeRsPMqa1RxX4iKbd5lzCvwjNTHfe4Ovk18zlHyknHkghHmyiFjJCGr(Or6Ism2g2JGahTsPMpllWIEzqjpq9kghTsPMpBLYxeeJGGyU7qGXvzLC2gwqqT)OgjmYhn(j(46rqWDhcmUkRKZgYrR06hobQyU7qGn6kLOTvggkxieSnChPY)cLwMls)iIc6K8jDqOeuviQx3DiWiUPGTK0StDyBybbVCr6aMSrxe6qCr6aMKF5q(djpccCr6aMSrHShOkSKlI4l7iv(xO0YCr6hruqlsnbPdcLGQcr96UdbgXnfSLKMDQdBdli4LlshWKn6IqhIlshWK8lhYFi5rqGlshWKnkK9avHLCreFzhPY)cLwMls)iIc6W2yKoiucQke1R7oeye3uWwsA2PoSnSGGxUiDat2OlcDiUiDatYVCi)HKhbbUiDat2Oq2dufwYfr8LDKk)luAzUi9JikO9PZuOrIcsYStQJu5FHslZfPFerbT91judbQkeL4Mc2sSkLMDQJGaXnfSLywKrhzsI7feiUPGTettiKjjUxqWDhcmF6mfAKOGKm7KyByOU7qGrCtbBjPzN6W2WccED3HaJRYk5SHC0kT(R8VqjZ3OVigjoIVFs(Ldb1DhcmUkRKZ2WE6iv(xO0YCr6hruq7B0xuhPY)cLwMls)iIc6zNsL)fkLMY(GkvhkAqnMx0S7i7iv(xO0YWgsDCReJMOR6uQRHavQouuRgi5JKBljTWKXaQv1SPOED3Ha7lhYhAsj2qQJBLy0WgYrR06hyogZrfxe4YWdQxIBkylXQu6IErcce3uWwIvP0Im6iiqCtbBjMzN6itsCVhbb3DiW(YH8HMuInK64wjgnSHC0kT(P8VqjZ(6eQHyK4i((j5xoue4YWdQxIBkylXQuA2Pocce3uWwIzrgDKjjUxqG4Mc2smnHqMK4EpEeeeZDhcSVCiFOjLydPoUvIrdBd3rQ8VqPLHnK64wjgnref02xh7EatGQcr9k2QoL6AiMvdK8rYTLKwyYyee86Udb2ORuI2wzyOCHqWgYrR06pyogZrf3cYPY4vT)OgjmYhn4hKX1du3DiWgDLs02kddLlec2g2Jhbb1(JAKWiF04N4JBhPY)cLwg2qQJBLy0eruqZr5kAjjFrK0cxt9wqvHOEx1PuxdX4OCfTKKyKfIKdTYNgyKrFctgkWIE5qoALw)WdY4cvmoczWq(sgxLvYzdPyqii4UdbgxLvYzBypqv7pQrcJ8rJ)4pUq96UdbgXnfSLKMDQdBihTsRF4HRGG7oeye3uWwsArgDyd5OvA9dpC9iiekWIE5qoALw)Xd3osL)fkTmSHuh3kXOjIOGwXu4VwjP1NooGIdb3qYxhW0BJIhOQquXWqptXu4VwjP1Noosm1rbtSV4lRemuXu(xOKPyk8xRK06thhjM6OGjwLYGPal6H6vmm0Zumf(RvsA9PJJuePg2x8Lvcwqad9mftH)ALKwF64ifrQHnKJwP1pi5rqad9mftH)ALKwF64iXuhfmXSVYx6pKHIHEMIPWFTssRpDCKyQJcMyd5OvA9hYqXqptXu4VwjP1Noosm1rbtSV4lReChPY)cLwg2qQJBLy0eruq7GqzOgcuCi4gs(6aMEBu8avfIouyiRi11qqFDatp7lhs(ijwr(H3Iq961DhcmUkRKZgYrR06hKG61DhcSrxPeTTYWq5cHGnKJwP1pijiiM7oeyJUsjABLHHYfcbBd7rqqm3DiW4QSsoBdliO2FuJeg5Jg)HmUEG6vm3DiWwwj2qysYbg5JghkFjL0aUwiX2WccQ9h1iHr(OXFiJRhOkSKlI4l90rQ8VqPLHnK64wjgnref02DgQHafhcUHKVoGP3gfpqvHOdfgYksDne0xhW0Z(YHKpsIvKF4TiuVED3HaJRYk5SHC0kT(bjOED3HaB0vkrBRmmuUqiyd5OvA9dsccI5Udb2ORuI2wzyOCHqW2WEeeeZDhcmUkRKZ2WccQ9h1iHr(OXFiJRhOEfZDhcSLvIneMKCGr(OXHYxsjnGRfsSnSGGA)rnsyKpA8hY46bQcl5Ii(spDKk)luAzydPoUvIrterbT9jJrhzWOdbkoeCdjFDatVnkEGQcrhkmKvK6AiOVoGPN9LdjFKeRi)WBbG61R7oeyCvwjNnKJwP1pib1R7oeyJUsjABLHHYfcbBihTsRFqsqqm3DiWgDLs02kddLlec2g2JGGyU7qGXvzLC2gwqqT)OgjmYhn(dzC9a1RyU7qGTSsSHWKKdmYhnou(skPbCTqITHfeu7pQrcJ8rJ)qgxpqvyjxeXx6PJu5FHsldBi1XTsmAIikOdOHtsuqM6VhcuviQcl5Ii(YosL)fkTmSHuh3kXOjIOGE0vkrBRmmuUqiavfI6UdbgxLvYzB4osL)fkTmSHuh3kXOjIOGEzLydHjTW1uVfuviQxVU7qGrCtbBjPfz0HnKJwP1p8WvqWDhcmIBkyljn7uh2qoALw)Wdxpq5iKbd5lzCvwjNnKJwP1piJRhbboczWq(sgxLvYzdPyq0rQ8VqPLHnK64wjgnref0CYq2VuJunf40HYhuviQxVU7qGTSsSHWKKdmYhnou(skPbCTqITHfeeJJwPuZNTeIP00JGahTsPMpllWIEzqjbHvDk11qSYkveji4UdbMRbHWmB7Z2WqD3HaZ1GqyMT9zd5OvA9FrCJWlhLy76zWdXlljvtboDO8zF5qYv1SjpEGkM7oeyCvwjNTHH6vmoALsnFwwGf9YGsccCeYGH8Lmokxrlj5lIKw4AQ3Y2Wccv(0aJm6tyYqbw0lhYrR06phHmyiFjJJYv0ss(IiPfUM6TSHC0kTrSaccv(0aJm6tyYqbw0lhYrR0IF4hE4eC9FrCJWlhLy76zWdXlljvtboDO8zF5qYv1SjpE6iv(xO0YWgsDCReJMiIc6k56K6xOeuviQxVU7qGTSsSHWKKdmYhnou(skPbCTqITHfeeJJwPuZNTeIP00JGahTsPMpllWIEzqjbHvDk11qSYkveji4UdbMRbHWmB7Z2WqD3HaZ1GqyMT9zd5OvA9hY4gHxokX21ZGhIxwsQMcC6q5Z(YHKRQztE8avm3DiW4QSsoBdd1RyC0kLA(SSal6LbLee4iKbd5lzCuUIwsYxejTW1uVLTHfeQ8Pbgz0NWKHcSOxoKJwP1FoczWq(sghLROLK8frslCn1Bzd5OvAJybeeQ8Pbgz0NWKHcSOxoKJwPf)Wp8Wj46pKXncVCuITRNbpeVSKunf40HYN9LdjxvZM84PJu5FHsldBi1XTsmAIikOx1PuxdbQuDOOwDLKb0i5QSsoOwvZMI6vmoczWq(sgxLvYzdPyqiii2QoL6AighLROLKeJSqKCOC0kLA(SSal6LbL80rQ8VqPLHnK64wjgnref0H9aHefKKzNeOQquIBkylXQuQjeqvyjxeXxc1lg6zkMc)1kjT(0XrIPokyI9fFzLGfeeJJwPuZNLeFqg0G5b6QoL6AiMvxjzansUkRK3rQ8VqPLHnK64wjgnref02xh7EatGQcr5Ovk18zzbw0ldkbDvNsDneJJYv0ssIrwisou1(JAKWiF04xu8hxOCeYGH8Lmokxrlj5lIKw4AQ3YgYrR06pyogZrf3cYPY4vT)OgjmYhn4hKX1thPY)cLwg2qQJBLy0eruqNKpPdcLGQcr96UdbgXnfSLKMDQdBdli4LlshWKn6IqhIlshWK8lhYFi5rqGlshWKnkK9avHLCreFj0vDk11qmRUsYaAKCvwjVJu5FHsldBi1XTsmAIikOfPMG0bHsqvHOED3HaJ4Mc2ssZo1HTHHkghTsPMpBjetPPGGx3DiWwwj2qysYbg5JghkFjL0aUwiX2Wq5Ovk18zlHykn9ii4LlshWKn6IqhIlshWK8lhYFi5rqGlshWKnkKfeC3HaJRYk5SnShOkSKlI4lHUQtPUgIz1vsgqJKRYk5DKk)luAzydPoUvIrterbDyBmshekbvfI61DhcmIBkyljn7uh2ggQyC0kLA(SLqmLMccED3HaBzLydHjjhyKpACO8Lusd4AHeBddLJwPuZNTeIP00JGGxUiDat2OlcDiUiDatYVCi)HKhbbUiDat2OqwqWDhcmUkRKZ2WEGQWsUiIVe6QoL6AiMvxjzansUkRK3rQ8VqPLHnK64wjgnref0(0zk0irbjz2j1rQ8VqPLHnK64wjgnref02xNqneOQquIBkylXQuA2Pocce3uWwIzrgDKjjUxqG4Mc2smnHqMK4Ebb3DiW8PZuOrIcsYStITHH6UdbgXnfSLKMDQdBdli41DhcmUkRKZgYrR06VY)cLmFJ(IyK4i((j5xoeu3DiW4QSsoBd7PJu5FHsldBi1XTsmAIikO9n6lQJu5FHsldBi1XTsmAIikONDkv(xOuAk7dQuDOOb1yErZUJSJu5FHsllOgZlA2rTVo29aMavfIk2StkGgWeZvnAYjjkivJr(IQeSLrGODbdtyDKk)luAzb1yErZoIOG2UZqneO4qWnK81bm92O4bQkefd9mhekd1qSHC0kT(nKJwPTJu5FHsllOgZlA2ref0oiugQH6i7iv(xO0YSFuftH)ALKwF64akoeCdjFDatVnkEGQcrfdd9mftH)ALKwF64iXuhfmX(IVSsWqft5FHsMIPWFTssRpDCKyQJcMyvkdMcSOhQxXWqptXu4VwjP1NoosrKAyFXxwjybbm0Zumf(RvsA9PJJuePg2qoALw)GKhbbm0Zumf(RvsA9PJJetDuWeZ(kFP)qgkg6zkMc)1kjT(0XrIPokyInKJwP1Fidfd9mftH)ALKwF64iXuhfmX(IVSsWDKk)luAz2pIOGMJYv0ss(IiPfUM6TGQcr9UQtPUgIXr5kAjjXilejhQyCeYGH8LmUkRKZgsXGqqWDhcmUkRKZ2WEGQ2FuJeg5Jg)XFCH61DhcmIBkyljn7uh2qoALw)Wdxbb3DiWiUPGTK0Im6WgYrR06hE46rqiuGf9YHC0kT(JhUDKk)luAz2pIOGEvNsDneOs1HIIHE5qGODnKdLVfuRQztr96UdbgxLvYzd5OvA9dsq96Udb2ORuI2wzyOCHqWgYrR06hKeeeZDhcSrxPeTTYWq5cHGTH9iiiM7oeyCvwjNTHfeu7pQrcJ8rJ)qgxpq9kM7oeylReBimj5aJ8rJdLVKsAaxlKyBybb1(JAKWiF04pKX1duVU7qGrCtbBjPfz0HnKJwP1pWCmMJkobb3DiWiUPGTK0StDyd5OvA9dmhJ5OIZthPY)cLwM9JikODqOmudbkoeCdjFDatVnkEGQcrhkmKvK6AiOVoGPN9LdjFKeRi)WBrOEvyjxeXxcDvNsDnedd9YHar7AihkFRNosL)fkTm7hruqB3zOgcuCi4gs(6aMEBu8avfIouyiRi11qqFDatp7lhs(ijwr(H3Iq9QWsUiIVe6QoL6Aigg6LdbI21qou(wpDKk)luAz2pIOG2(KXOJmy0HafhcUHKVoGP3gfpqvHOdfgYksDne0xhW0Z(YHKpsIvKF4Taq9QWsUiIVe6QoL6Aigg6LdbI21qou(wpDKk)luAz2pIOGoGgojrbzQ)EiqvHOkSKlI4l7iv(xO0YSFerb9ORuI2wzyOCHqaQke1DhcmUkRKZ2WDKk)luAz2pIOGMCGr(Or6IsmqvHOE96UdbgXnfSLKwKrh2qoALw)Wdxbb3DiWiUPGTK0StDyd5OvA9dpC9aLJqgmKVKXvzLC2qoALw)GmUq96Udbg8uoObRuJuhUMfxcVnwDyRQzt(Vi(JRGGyZoPaAatm4PCqdwPgPoCnlUeEBS6Wiq0UGHjmpEeeC3HadEkh0GvQrQdxZIlH3gRoSv1Sj)IUiodxbboczWq(sgxLvYzdPyqa1RA)rnsyKpA8t8XvqyvNsDneRSsfrE6iv(xO0YSFerbnNmK9l1ivtboDO8bvfI6vT)OgjmYhn(j(4c1R7oeylReBimj5aJ8rJdLVKsAaxlKyBybbX4Ovk18zlHykn9iiWrRuQ5ZYcSOxgusqyvNsDneRSsfrccU7qG5AqimZ2(Snmu3DiWCnieMzBF2qoALw)xe3i86v8xWzNuanGjg8uoObRuJuhUMfxcVnwDyeiAxWWeMNi8Yrj2UEg8q8Yss1uGthkF2xoKCvnBYJhpqfZDhcmUkRKZ2Wq9kghTsPMpllWIEzqjbboczWq(sghLROLK8frslCn1BzBybHkFAGrg9jmzOal6Ld5OvA9NJqgmKVKXr5kAjjFrK0cxt9w2qoAL2iwabHkFAGrg9jmzOal6Ld5OvAXp8dpCcU(ViUr4LJsSD9m4H4LLKQPaNou(SVCi5QA2KhpDKk)luAz2pIOGUsUoP(fkbvfI6vT)OgjmYhn(j(4c1R7oeylReBimj5aJ8rJdLVKsAaxlKyBybbX4Ovk18zlHykn9iiWrRuQ5ZYcSOxgusqyvNsDneRSsfrccU7qG5AqimZ2(Snmu3DiWCnieMzBF2qoALw)HmUr41R4VGZoPaAatm4PCqdwPgPoCnlUeEBS6Wiq0UGHjmpr4LJsSD9m4H4LLKQPaNou(SVCi5QA2KhpEGkM7oeyCvwjNTHH6vmoALsnFwwGf9YGsccCeYGH8Lmokxrlj5lIKw4AQ3Y2Wccv(0aJm6tyYqbw0lhYrR06phHmyiFjJJYv0ss(IiPfUM6TSHC0kTrSaccv(0aJm6tyYqbw0lhYrR0IF4hE4eC9hY4gHxokX21ZGhIxwsQMcC6q5Z(YHKRQztE80rQ8VqPLz)iIc6vDk11qGkvhkQvxjzansUkRKdQv1SPOEfJJqgmKVKXvzLC2qkgeccITQtPUgIXr5kAjjXilejhkhTsPMpllWIEzqjpDKk)luAz2pIOGoShiKOGKm7KavfIsCtbBjwLsnHaQcl5Ii(sOU7qGbpLdAWk1i1HRzXLWBJvh2QA2K)lI)4c1lg6zkMc)1kjT(0XrIPokyI9fFzLGfeeJJwPuZNLeFqg0G5b6QoL6AiMvxjzansUkRK3rQ8VqPLz)iIcA7RtqngqvHOU7qGHs6fzLW0Wj4VqjBdd1Dhcm7Rtqng2qHHSIuxd1rQ8VqPLz)iIcAUMCYiD3HaOs1HIAFDmObduviQ7oey2xhdAWyd5OvA9hsq96UdbgXnfSLKwKrh2qoALw)GKGG7oeye3uWwsA2PoSHC0kT(bjpqv7pQrcJ8rJFIpUDKk)luAz2pIOG2(6y3dycuvikhTsPMpllWIEzqjOR6uQRHyCuUIwssmYcrYHYridgYxY4OCfTKKVisAHRPElBihTsR)qQJu5FHslZ(ref02xNGAmGQcrF1q5ZSpzm6iXMk8mkvxdHbvSxnu(m7RJbnymkvxdHb1Dhcm7Rtqng2qHHSIuxdb1R7oeye3uWwsA2PoSHC0kT(TaqjUPGTeRsPzN6a1Dhcm4PCqdwPgPoCnlUeEBS6WwvZM8FriHRGG7oeyWt5GgSsnsD4AwCj82y1HTQMn5x0fHeUqv7pQrcJ8rJFIpUccyONPyk8xRK06thhjM6OGj2qoALw)Wjcck)luYumf(RvsA9PJJetDuWeRszWuGf9EGkghHmyiFjJRYk5SHumi6iv(xO0YSFerbT91XUhWeOQqu3DiWqj9ISsUH0rUw2cLSnSGG7oeylReBimj5aJ8rJdLVKsAaxlKyBybb3DiW4QSsoBdd1R7oeyJUsjABLHHYfcbBihTsR)G5ymhvCliNkJx1(JAKWiF0GFqgxpqD3HaB0vkrBRmmuUqiyBybbXC3HaB0vkrBRmmuUqiyByOIXridgYxYgDLs02kddLlec2qkgeccIXrRuQ5ZwP8fbX4rqqT)OgjmYhn(j(4cL4Mc2sSkLAcrhPY)cLwM9JikOTVo29aMavfI(QHYNzFDmObJrP6AimOED3HaZ(6yqdgBdliO2FuJeg5Jg)eFC9a1Dhcm7RJbnym7R8L(dzOED3HaJ4Mc2sslYOdBdli4UdbgXnfSLKMDQdBd7bQ7oeyWt5GgSsnsD4AwCj82y1HTQMn5)I4mCH6LJqgmKVKXvzLC2qoALw)WdxbbXw1PuxdX4OCfTKKyKfIKdLJwPuZNLfyrVmOKNosL)fkTm7hruqBFDS7bmbQke1R7oeyWt5GgSsnsD4AwCj82y1HTQMn5)I4mCfeC3HadEkh0GvQrQdxZIlH3gRoSv1Sj)xes4c9vdLpZ(KXOJeBQWZOuDneMhOU7qGrCtbBjPfz0HnKJwP1pCguIBkylXQuArgDGkM7oeyOKErwjmnCc(luY2Wqf7vdLpZ(6yqdgJs11qyq5iKbd5lzCvwjNnKJwP1pCguVCeYGH8LSLvIneM0cxt9w2qoALw)WzccIXrRuQ5ZwcXuA6PJu5FHslZ(ref0j5t6GqjOQquVU7qGrCtbBjPzN6W2WccE5I0bmzJUi0H4I0bmj)YH8hsEee4I0bmzJczpqvyjxeXxcDvNsDneZQRKmGgjxLvY7iv(xO0YSFerbTi1eKoiucQke1R7oeye3uWwsA2PoSnmuX4Ovk18zlHyknfe86Udb2YkXgctsoWiF04q5lPKgW1cj2ggkhTsPMpBjetPPhbbVCr6aMSrxe6qCr6aMKF5q(djpccCr6aMSrHSGG7oeyCvwjNTH9avHLCreFj0vDk11qmRUsYaAKCvwjVJu5FHslZ(ref0HTXiDqOeuviQx3DiWiUPGTK0StDyByOIXrRuQ5ZwcXuAki41DhcSLvIneMKCGr(OXHYxsjnGRfsSnmuoALsnF2siMstpccE5I0bmzJUi0H4I0bmj)YH8hsEee4I0bmzJczbb3DiW4QSsoBd7bQcl5Ii(sOR6uQRHywDLKb0i5QSsEhPY)cLwM9JikO9PZuOrIcsYStQJu5FHslZ(ref02xNqneOQquIBkylXQuA2Pocce3uWwIzrgDKjjUxqG4Mc2smnHqMK4Ebb3DiW8PZuOrIcsYStITHH6UdbgXnfSLKMDQdBdli41DhcmUkRKZgYrR06VY)cLmFJ(IyK4i((j5xoeu3DiW4QSsoBd7PJu5FHslZ(ref0(g9f1rQ8VqPLz)iIc6zNsL)fkLMY(GkvhkAqnMx0SbEGhaaa]] )


end