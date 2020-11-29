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
        width = 1.5
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20201129, [[dCuSqdqiQkEefsQlPcQnbsFccfAuuWPiOvPcYReGzPIQBbHk7cv)sfPHbOogezzQapdczAcOUMkkBtaPVbHQgNafNJcPwhfsmpQkDpvO9rH6GqOOwievpuaXeHqrYfHqrQpcHc6KuijTsbYmfO0ovrmuiuGLsHK4PcAQqu(kekI9Qs)LObR0HjTyQYJrzYG6YiBwOpdIrtGtl1RbKztLBtr7wYVHA4q64qO0Yv8CknDvDDG2oaFNQQXtH48qW6fOA(eA)I(I0fz3qy9P7jha8baJeshy0CGdMZcmWi(B4JakDdrvgqke6gwQjDdrU60Ir3qufbhwHVi7gAXGdJUHc(h1Auo9ui9la0JZWMNABtqN(nUyJg)tTTj70BOhy7EJQ117gcRpDp5aGpayKq6aJMdCWCwGb(SBOc(cWZnmSndKBOGggMQR3neMSSBOrDUixDAXOCrm1a2Wzqg15Ecgaz6rtUhy0NN7baFaWzqzqg15gic0ccznkzqg15I4YfXmmmbNBi2PtUiNutEgKrDUiUCdebAbHGZ91bc9YoMltTKn3hNldbMJKVoqO3YZGmQZfXLRrfYedGGZfSkIrwRoiKlaDA1Zr2Cn0CIFEUOdbqAFDSGdekxeNX5IoeaU91XcoqiH8BORTV9ISBi8qQPxxW0Cr29eKUi7gsL65i4lYVHy0BOL(BOY(gx3qa60QNJUHauhiDdnKRhymY)2K8JNscpKA61fmn8Hm1US5ACUqyWCt1i5gqUaZrkxO5AixI5AulX7s6HFb5kkMlXCnQL4DjTyNo5kkMlXCnQL4oWshzrg5ZvyUII56bgJ8Vnj)4PKWdPMEDbtdFitTlBUgNRY(gxC7RtShItgHyGpj)2KYnGCbMJuUqZ1qUeZ1OwI3L0bw6KROyUeZ1OwIBXoDKfzKpxrXCjMRrTexleKfzKpxH5kmxrXC9jxpWyK)Tj5hpLeEi10RlyA4GO3qa6il1KUHwnsYhlbTK0Iso39VNCWfz3qQuphbFr(nKn9ttR3qd56tUa0PvphXTAKKpwcAjPfLCUCffZ1qUEGXiFuauHbTY4qvWrGpKP2LnxFZfcdMBQgj3dLlJAxUgYvT)Oojk2pn5EAUic4CfMl0C9aJr(OaOcdALXHQGJahenxH5kmxrXCv7pQtII9ttUgNRrd8nuzFJRBO91XcoqO7FpbrxKDdPs9Ce8f53q20pnTEdnKlaDA1ZrCgUaGbIKWKfHILl0C76Pbf70NGLXgIGxoKP2LnxJZfjebCUqZ1NCzySdg7V4mv2fJpKcJqUII56bgJCMk7IXbrZvyUqZvT)Oojk2pn56BUbg4CHMRHC9aJroXCnQLKoWsh(qMAx2CnoxKaoxrXC9aJroXCnQLKwSth(qMAx2CnoxKaoxH5kkMBSHi4LdzQDzZ13Crc4BOY(gx3qgUaGbIKVasAr7PF79VNe4lYUHuPEoc(I8BOY(gx3qfwr)gajT(1X8gYM(PP1BOp5cJFUcROFdGKw)6ykHvtfcX)MbuxqYfAU(KRY(gxCfwr)gajT(1XucRMkeI3Lm6Aic(CHMRHC9jxy8Zvyf9BaK06xhtPasD8Vza1fKCffZfg)Cfwr)gajT(1XukGuhFitTlBUgN7z5kmxrXCHXpxHv0VbqsRFDmLWQPcH42xzaLRV5IOCHMlm(5kSI(nasA9RJPewnvieFitTlBU(MlIYfAUW4NRWk63aiP1VoMsy1uHq8Vza1fKBidbMJKVoqO3EpbP7Fp5SlYUHuPEoc(I8BOY(gx3qtmUI9q3q20pnTEdhkoKvG65OCHM7Rde65FBsYhlHBkxJZfPdYfAUgY1qUEGXiNPYUy8Hm1US5ACUNLl0CnKRhymYhfavyqRmoufCe4dzQDzZ14CplxrXC9jxpWyKpkaQWGwzCOk4iWbrZvyUII56tUEGXiNPYUyCq0CffZvT)Oojk2pn56BUic4CfMl0CnKRp56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5kkMRA)rDsuSFAY13CreW5kmxO5QOsMaIbuUcVHmeyos(6aHE79eKU)9Ka9ISBivQNJGVi)gQSVX1n0cwXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLWnLRX5I0b5cnxd5AixpWyKZuzxm(qMAx2Cno3ZYfAUgY1dmg5JcGkmOvghQcoc8Hm1US5ACUNLROyU(KRhymYhfavyqRmoufCe4GO5kmxrXC9jxpWyKZuzxmoiAUII5Q2FuNef7NMC9nxebCUcZfAUgY1NC9aJroqDbpeSKmrX(PXKQxsfnq6GtCq0CffZvT)Oojk2pn56BUic4CfMl0CvujtaXakxH3qgcmhjFDGqV9Ecs3)EcI)ISBivQNJGVi)gQSVX1n0(KZPJm60HUHSPFAA9gouCiRa1Zr5cn3xhi0Z)2KKpwc3uUgNlsbAUqZ1qUgY1dmg5mv2fJpKP2LnxJZ9SCHMRHC9aJr(OaOcdALXHQGJaFitTlBUgN7z5kkMRp56bgJ8rbqfg0kJdvbhboiAUcZvumxFY1dmg5mv2fJdIMROyUQ9h1jrX(PjxFZfraNRWCHMRHC9jxpWyKduxWdbljtuSFAmP6LurdKo4ehenxrXCv7pQtII9ttU(MlIaoxH5cnxfvYeqmGYv4nKHaZrYxhi0BVNG09VNemxKDdPs9Ce8f53q20pnTEdvujtaXa6gQSVX1nmIhgjXrzPp4q3)EIrFr2nKk1ZrWxKFdzt)006n0dmg5mv2fJdIEdv2346gokaQWGwzCOk4iC)7jib8fz3qQuphbFr(nKn9ttR3qd5AixpWyKtmxJAjPf70HpKP2LnxJZfjGZvumxpWyKtmxJAjPdS0HpKP2LnxJZfjGZvyUqZLHXoyS)IZuzxm(qMAx2CnoxebCUcZvumxgg7GX(lotLDX4dPWiCdv2346gcuxWdblTO90V9(3tqcPlYUHuPEoc(I8BiB6NMwVHgY1qUEGXihOUGhcwsMOy)0ys1lPIgiDWjoiAUII56tUmmaQ065aHW0ALRWCffZLHbqLwpVAicEzuPCffZfGoT65iEBLkMYvumxpWyK75WyyhO95GO5cnxpWyK75WyyhO95dzQDzZ13Cpa4Cdixd5g4CpuUmCbd2phDiwBjP6AiLjvpNk1ZrW5kmxH5cnxFY1dmg5mv2fJdIMl0CnKRp5YWaOsRNxnebVmQuUII5YWyhm2FXz4cagis(ciPfTN(TCq0CffZTRNguStFcwgBicE5qMAx2C9nxgg7GX(lodxaWarYxajTO90VLpKP2Ln3aYnqZvum3UEAqXo9jyzSHi4LdzQDzZ9W5IuWaCU(M7baNBa5Ai3aN7HYLHlyW(5OdXAljvxdPmP65uPEocoxH5k8gQSVX1nKroY(T6KQRHuMu93)EcshCr2nKk1ZrWxKFdzt)006n0qUgY1dmg5a1f8qWsYef7NgtQEjv0aPdoXbrZvumxFYLHbqLwphieMwRCfMROyUmmaQ065vdrWlJkLROyUa0PvphXBRuXuUII56bgJCphgd7aTphenxO56bgJCphgd7aTpFitTlBU(MlIao3aY1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZvyUqZ1NC9aJrotLDX4GO5cnxd56tUmmaQ065vdrWlJkLROyUmm2bJ9xCgUaGbIKVasAr7PFlhenxrXC76Pbf70NGLXgIGxoKP2LnxFZLHXoyS)IZWfamqK8fqslAp9B5dzQDzZnGCd0CffZTRNguStFcwgBicE5qMAx2CpCUifmaNRV5IiGZnGCnKBGZ9q5YWfmy)C0HyTLKQRHuMu9CQuphbNRWCfEdv2346g2ftNs)gx3)Ecsi6ISBivQNJGVi)gIrVHw6VHk7BCDdbOtREo6gcqDG0n0qU(KldJDWy)fNPYUy8HuyeYvumxFYfGoT65iodxaWarsyYIqXYfAUmmaQ065vdrWlJkLRWBiaDKLAs3qRcGKr8izQSl29VNGuGVi7gsL65i4lYVHSPFAA9gsmxJAjExsTqixO5QOsMaIbuUqZ1qUW4NRWk63aiP1VoMsy1uHq8Vza1fKCffZ1NCzyauP1ZlInyhEGZvyUqZfGoT65iUvbqYiEKmv2f7gQSVX1nmcoiiXrj5al6(3tq6SlYUHuPEoc(I8BiB6NMwVHmmaQ065vdrWlJkLl0CbOtREoIZWfamqKeMSiuSCHMRA)rDsuSFAY14J5gyGZfAUmm2bJ9xCgUaGbIKVasAr7PFlFitTlBU(Mlegm3unsUhkxg1UCnKRA)rDsuSFAY90CreW5k8gQSVX1n0(6ybhi09VNGuGEr2nKk1ZrWxKFdzt)006n0qUEGXiNyUg1sshyPdhenxrXCnKltGoqiBUhZ9GCHM7qmb6aHKFBs56BUNLRWCffZLjqhiKn3J5IOCfMl0CvujtaXakxO5cqNw9Ce3QaizepsMk7IDdv2346gwKFPjgx3)Ecsi(lYUHuPEoc(I8BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5cnxFYLHbqLwphieMwRCffZ1qUEGXihOUGhcwsMOy)0ys1lPIgiDWjoiAUqZLHbqLwphieMwRCfMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCruUII56bgJCMk7IXbrZvyUqZvrLmbedOCHMlaDA1ZrCRcGKr8izQSl2nuzFJRBOa1fLMyCD)7jifmxKDdPs9Ce8f53q20pnTEdnKRhymYjMRrTK0bw6WbrZfAU(KlddGkTEoqimTw5kkMRHC9aJroqDbpeSKmrX(PXKQxsfnq6GtCq0CHMlddGkTEoqimTw5kmxrXCnKltGoqiBUhZ9GCHM7qmb6aHKFBs56BUNLRWCffZLjqhiKn3J5IOCffZ1dmg5mv2fJdIMRWCHMRIkzcigq5cnxa60QNJ4wfajJ4rYuzxSBOY(gx3WiOZjnX46(3tqYOVi7gQSVX1n0VotJhjokjhyr3qQuphbFr(9VNCaWxKDdPs9Ce8f53q20pnTEdjMRrTeVlPdS0jxrXCjMRrTe3ID6ilYiFUII5smxJAjUwiilYiFUII56bgJC)6mnEK4OKCGfXbrZfAUEGXiNyUg1sshyPdhenxrXCnKRhymYzQSlgFitTlBU(MRY(gxC)J(c4Krig4tYVnPCHMRhymYzQSlghenxH3qL9nUUH2xNyp09VNCasxKDdv2346g6F0xWnKk1ZrWxKF)7jhCWfz3qQuphbFr(nuzFJRB4awsL9nUKU2(3qxBFzPM0nmQo3lyaV)9VHWuubD)fz3tq6ISBOY(gx3ql2PJ0JuZBivQNJGVi)(3to4ISBivQNJGVi)gIrVHw6VHk7BCDdbOtREo6gcqDG0n0IsoN81bc9wU91jQoxUgNls5cnxd56tUV6O652xhhEG5uPEocoxrXCF1r1ZTp5C6iHNo(CQuphbNRWCffZ1IsoN81bc9wU91jQoxUgN7b3qa6il1KUHTvQy6(3tq0fz3qQuphbFr(neJEdT0Fdv2346gcqNw9C0neG6aPBOfLCo5Rde6TC7RtShkxJZfPBiaDKLAs3W2kzosbq3)EsGVi7gsL65i4lYVHSPFAA9gAixFYLHbqLwpVAicEzuPCffZ1NCzySdg7V4mCbadejFbK0I2t)woiAUcZfAUEGXiNPYUyCq0BOY(gx3qpAS0auxqU)9KZUi7gsL65i4lYVHSPFAA9g6bgJCMk7IXbrVHk7BCDdrXFJR7FpjqVi7gQSVX1ne0sY(jt7nKk1ZrWxKF)7ji(lYUHuPEoc(I8BiB6NMwVHoca5Y13CpdPBOY(gx3qbKoVKSwQy09VNemxKDdPs9Ce8f53q20pnTEdbOtREoI3wPIPBO9NM93tq6gQSVX1nCalPY(gxsxB)BORTVSut6gQy6(3tm6lYUHuPEoc(I8BiB6NMwVHdyrr8aH4FBs(XtjHhsn96cMgoHybBuuc(gA)Pz)9eKUHk7BCDdhWsQSVXL012)g6A7ll1KUHWdPMEDbtZ9VNGeWxKDdPs9Ce8f53q20pnTEdhWII4bcX9uNwmsIJs15KVGUGy5eIfSrrj4BO9NM93tq6gQSVX1nCalPY(gxsxB)BORTVSut6g6H1)(3tqcPlYUHuPEoc(I8BOY(gx3WbSKk7BCjDT9VHU2(YsnPBO9V)9VHEy9Vi7EcsxKDdPs9Ce8f53q20pnTEd9aJrotLDX4GO3qL9nUUHJcGkmOvghQcoc3)EYbxKDdPs9Ce8f53qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHrhgp5Aixd521tdk2PpblJnebVCitTlBUiUCpa4CfM7P5I0baNRWCno3OdJNCnKRHC76Pbf70NGLXgIGxoKP2LnxexUhCwUiUCnKlsaN7HY9vhvpVlMoL(nU4uPEocoxH5I4Y1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZvyUNMlsbdW5k8gcqhzPM0nKHlayGijmzrOy3)EcIUi7gsL65i4lYVHy0BOL(BOY(gx3qa60QNJUHauhiDd9jxpWyK7PoTyKehLQZjFbDbXkl9bhIdIMl0C9jxpWyK7PoTyKehLQZjFbDbXk1HPfXbrVHa0rwQjDdzt)f(brV)9KaFr2nKk1ZrWxKFdv2346gQWk63aiP1VoM3q20pnTEd9aJrUN60IrsCuQoN8f0feRS0hCiU9vgqsaQdKY13CdmW5cnxpWyK7PoTyKehLQZjFbDbXk1HPfXTVYascqDGuU(MBGboxO5AixFYfg)Cfwr)gajT(1XucRMkeI)ndOUGKl0C9jxL9nU4kSI(nasA9RJPewnvieVlz01qe85cnxd56tUW4NRWk63aiP1VoMsbK64FZaQli5kkMlm(5kSI(nasA9RJPuaPo(qMAx2CnoxeLRWCffZfg)Cfwr)gajT(1XucRMkeIBFLbuU(MlIYfAUW4NRWk63aiP1VoMsy1uHq8Hm1US56BUNLl0CHXpxHv0VbqsRFDmLWQPcH4FZaQli5k8gYqG5i5Rde6T3tq6(3to7ISBivQNJGVi)gYM(PP1BOHCbOtREoIZWfamqKeMSiuSCHMBxpnOyN(eSm2qe8YHm1US5ACUiHiGZfAU(KldJDWy)fNPYUy8HuyeYvumxpWyKZuzxmoiAUcZfAUgY1dmg5EQtlgjXrP6CYxqxqSYsFWH42xzajbOoqk3J5EgW5kkMRhymY9uNwmsIJs15KVGUGyL6W0I42xzajbOoqk3J5EgW5kmxrXCJnebVCitTlBU(MlsaFdv2346gYWfamqK8fqslAp9BV)9Ka9ISBivQNJGVi)gYM(PP1BOHC9aJrUN60IrsCuQoN8f0feRS0hCi(qMAx2Cno3aZplxrXC9aJrUN60IrsCuQoN8f0feRuhMweFitTlBUgNBG5NLRWCHMRA)rDsuSFAY14J5A0aNl0CnKldJDWy)fNPYUy8Hm1US5ACUi(CffZ1qUmm2bJ9xCYef7NgPhUG5dzQDzZ14Cr85cnxFY1dmg5a1f8qWsYef7NgtQEjv0aPdoXbrZfAUmmaQ065aHW0ALRWCfEdv2346gY0IroPhymEd9aJrzPM0n0(64Wd89VNG4Vi7gsL65i4lYVHSPFAA9g6tUa0PvphXzt)f(brZfAUgYLHbqLwpVAicEzuPCffZLHXoyS)IZuzxm(qMAx2CnoxeFUII5Aixgg7GX(lozII9tJ0dxW8Hm1US5ACUi(CHMRp56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5cnxggavA9CGqyATYvyUcVHk7BCDdTVowWbcD)7jbZfz3qQuphbFr(nKn9ttR3qd5YWyhm2FXz4cagis(ciPfTN(TCq0CHMRHCbOtREoIZWfamqKeMSiuSCffZLHXoyS)IZuzxm(qMAx2C9n3ZYvyUcZfAUQ9h1jrX(PjxJZ9mGZfAUmmaQ065vdrWlJkDdv2346gAFDSGde6(3tm6lYUHuPEoc(I8BOY(gx3qlyf7HUHSPFAA9gouCiRa1Zr5cn3xhi0Z)2KKpwc3uUgNlsbAUqZ1qUkQKjGyaLl0CnKlaDA1ZrC20FHFq0CffZ1qUQ9h1jrX(PjxFZfraNl0C9jxpWyKZuzxmoiAUcZvumxgg7GX(lotLDX4dPWiKRWCfEdziWCK81bc927jiD)7jib8fz3qQuphbFr(nuzFJRBOjgxXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLWnLRX5IeI4NLl0CnKRIkzcigq5cnxd5cqNw9CeNn9x4henxrXCnKRA)rDsuSFAY13CreW5cnxFY1dmg5mv2fJdIMRWCffZLHXoyS)IZuzxm(qkmc5kmxO56tUEGXihOUGhcwsMOy)0ys1lPIgiDWjoiAUcVHmeyos(6aHE79eKU)9eKq6ISBivQNJGVi)gQSVX1n0(KZPJm60HUHSPFAA9gouCiRa1Zr5cn3xhi0Z)2KKpwc3uUgNlsbAUbK7qMAx2CHMRHCvujtaXakxO5Aixa60QNJ4SP)c)GO5kkMRA)rDsuSFAY13CreW5kkMldJDWy)fNPYUy8HuyeYvyUcVHmeyos(6aHE79eKU)9eKo4ISBivQNJGVi)gYM(PP1BOIkzcigq3qL9nUUHr8Wijokl9bh6(3tqcrxKDdPs9Ce8f53q20pnTEdnKlXCnQL4Dj1cHCffZLyUg1sCl2PJSljs5kkMlXCnQL4oWshzxsKYvyUqZ1qU(KlddGkTEE1qe8YOs5kkMRHCv7pQtII9ttU(MRrFwUqZ1qUa0PvphXzt)f(brZvumx1(J6KOy)0KRV5IiGZvumxa60QNJ4TvQykxH5cnxd5cqNw9CeNHlayGijmzrOy5cnxFYLHXoyS)IZWfamqK8fqslAp9B5GO5kkMRp5cqNw9CeNHlayGijmzrOy5cnxFYLHXoyS)IZuzxmoiAUcZvyUcZfAUgYLHXoyS)IZuzxm(qMAx2CnoxebCUII5Q2FuNef7NMCnoxJg4CHMldJDWy)fNPYUyCq0CHMRHCzySdg7V4Kjk2pnspCbZhYu7YMRV5QSVXf3(6e7H4Krig4tYVnPCffZ1NCzyauP1ZbcHP1kxH5kkMBxpnOyN(eSm2qe8YHm1US56BUibCUcZfAUgYfg)Cfwr)gajT(1XucRMkeIpKP2LnxJZnW5kkMRp5YWaOsRNxeBWo8aNRWBOY(gx3Wi4GGehLKdSO7FpbPaFr2nKk1ZrWxKFdzt)006n0qUeZ1OwI7alDKfzKpxrXCjMRrTe3ID6ilYiFUII5smxJAjUwiilYiFUII56bgJCp1PfJK4OuDo5lOliwzPp4q8Hm1US5ACUbMFwUII56bgJCp1PfJK4OuDo5lOliwPomTi(qMAx2Cno3aZplxrXCv7pQtII9ttUgNRrdCUqZLHXoyS)IZuzxm(qkmc5kmxO5Aixgg7GX(lotLDX4dzQDzZ14CreW5kkMldJDWy)fNPYUy8HuyeYvyUII521tdk2PpblJnebVCitTlBU(MlsaFdv2346gcuxWdblTO90V9(3tq6SlYUHuPEoc(I8BiB6NMwVHgYvT)Oojk2pn5ACUgnW5cnxd56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5kkMRp5YWaOsRNdectRvUcZvumxggavA98QHi4LrLYvumxpWyK75WyyhO95GO5cnxpWyK75WyyhO95dzQDzZ13Cpa4Cdixd5g4CpuUmCbd2phDiwBjP6AiLjvpNk1ZrW5kmxH5cnxd56tUmmaQ065vdrWlJkLROyUmm2bJ9xCgUaGbIKVasAr7PFlhenxrXC76Pbf70NGLXgIGxoKP2LnxFZLHXoyS)IZWfamqK8fqslAp9B5dzQDzZnGCd0CffZTRNguStFcwgBicE5qMAx2CpCUifmaNRV5EaW5gqUgYnW5EOCz4cgSFo6qS2ss11qktQEovQNJGZvyUcVHk7BCDdzKJSFRoP6AiLjv)9VNGuGEr2nKk1ZrWxKFdzt)006n0qUQ9h1jrX(PjxJZ1OboxO5AixpWyKduxWdbljtuSFAmP6LurdKo4ehenxrXC9jxggavA9CGqyATYvyUII5YWaOsRNxnebVmQuUII56bgJCphgd7aTphenxO56bgJCphgd7aTpFitTlBU(MlIao3aY1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZvyUqZ1qU(KlddGkTEE1qe8YOs5kkMldJDWy)fNHlayGi5lGKw0E63YbrZvumxa60QNJ4mCbadejHjlcflxO521tdk2PpblJnebVCitTlBUgNlsbdW5gqUhaCUbKRHCdCUhkxgUGb7NJoeRTKuDnKYKQNtL65i4CfMROyUD90GID6tWYydrWlhYu7YMRV5YWyhm2FXz4cagis(ciPfTN(T8Hm1US5gqUbAUII521tdk2PpblJnebVCitTlBU(MlIao3aY1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZv4nuzFJRByxmDk9BCD)7jiH4Vi7gsL65i4lYVHSPFAA9gYWaOsRNxnebVmQuUqZ1qUa0PvphXz4cagisctwekwUII5YWyhm2FXzQSlgFitTlBU(MlsaNRWCHMRA)rDsuSFAY14Cpd4CHMldJDWy)fNHlayGi5lGKw0E63YhYu7YMRV5IeW3qL9nUUH2xhl4aHU)9eKcMlYUHuPEoc(I8Big9gAP)gQSVX1neGoT65OBia1bs3qI5AulX7s6alDY9q5gm5EAUk7BCXTVoXEiozeIb(K8Btk3aY1NCjMRrTeVlPdS0j3dLBGM7P5QSVXf3)OVaozeIb(K8Btk3aYfy(b5EAUwuY5Kcu7t3qa6il1KUHQffXaAcj29VNGKrFr2nKk1ZrWxKFdzt)006n0qUD90GID6tWYydrWlhYu7YMRV5g4CffZ1qUEGXiFuauHbTY4qvWrGpKP2LnxFZfcdMBQgj3dLlJAxUgYvT)Oojk2pn5EAUic4CfMl0C9aJr(OaOcdALXHQGJahenxH5kmxrXCnKRA)rDsuSFAYnGCbOtREoIRwuedOjKy5EOC9aJroXCnQLKwSth(qMAx2Cdixy8ZJGdcsCusoWI4FZaYkhYu7k3dL7b8ZY14Cr6aGZvumx1(J6KOy)0KBa5cqNw9CexTOigqtiXY9q56bgJCI5AuljDGLo8Hm1US5gqUW4NhbheK4OKCGfX)MbKvoKP2vUhk3d4NLRX5I0baNRWCHMlXCnQL4Dj1cHCHMRHCnKRp5YWyhm2FXzQSlghenxrXCzyauP1ZbcHP1kxO56tUmm2bJ9xCYef7NgPhUG5GO5kmxrXCzyauP1ZRgIGxgvkxH5cnxd56tUmmaQ065aO6fGWKROyU(KRhymYzQSlghenxrXCv7pQtII9ttUgNRrdCUcZvumxpWyKZuzxm(qMAx2Cno3GjxO56tUEGXiFuauHbTY4qvWrGdIEdv2346gAFDSGde6(3toa4lYUHuPEoc(I8BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5kkMRHCzc0bczZ9yUhKl0ChIjqhiK8BtkxFZ9SCfMROyUmb6aHS5EmxeLRWCHMRIkzcigq3qL9nUUHf5xAIX19VNCasxKDdPs9Ce8f53q20pnTEdnKRhymYjMRrTK0bw6WbrZvumxd5YeOdeYM7XCpixO5oetGoqi53MuU(M7z5kmxrXCzc0bczZ9yUikxH5cnxfvYeqmGUHk7BCDdfOUO0eJR7Fp5GdUi7gsL65i4lYVHSPFAA9gAixpWyKtmxJAjPdS0HdIMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCruUcZfAUkQKjGyaDdv2346ggbDoPjgx3)EYbi6ISBOY(gx3q)6mnEK4OKCGfDdPs9Ce8f53)EYbb(ISBivQNJGVi)gYM(PP1BiXCnQL4DjDGLo5kkMlXCnQL4wSthzrg5ZvumxI5AulX1cbzrg5ZvumxpWyK7xNPXJehLKdSioiAUqZLyUg1s8UKoWsNCffZ1qUEGXiNPYUy8Hm1US56BUk7BCX9p6lGtgHyGpj)2KYfAUEGXiNPYUyCq0CfEdv2346gAFDI9q3)EYbNDr2nuzFJRBO)rFb3qQuphbFr(9VNCqGEr2nKk1ZrWxKFdv2346goGLuzFJlPRT)n012xwQjDdJQZ9cgW7F)BOIPlYUNG0fz3qQuphbFr(neJEdT0Fdv2346gcqNw9C0neG6aPBOHC9aJr(3MKF8us4HutVUGPHpKP2LnxFZfcdMBQgj3aYfyos5kkMRhymY)2K8JNscpKA61fmn8Hm1US56BUk7BCXTVoXEiozeIb(K8Btk3aYfyos5cnxd5smxJAjExshyPtUII5smxJAjUf70rwKr(CffZLyUg1sCTqqwKr(CfMRWCHMRhymY)2K8JNscpKA61fmnCq0CHM7awuepqi(3MKF8us4HutVUGPHtiwWgfLGVHa0rwQjDdHhsnL(BNtgvNtIJX7Fp5GlYUHuPEoc(I8BiB6NMwVHEGXi3(6evNJpuCiRa1Zr5cnxd5ArjNt(6aHEl3(6evNlxFZfr5kkMRp5oGffXdeI)Tj5hpLeEi10RlyA4eIfSrrj4CfMl0CnKRp5oGffXdeI7qGPJALrhrFxqKqCTjQL4eIfSrrj4CffZ9Btk3dNBGplxJZ1dmg52xNO6C8Hm1US5gqUhKRWBOY(gx3q7RtuDU7FpbrxKDdPs9Ce8f53q20pnTEdhWII4bcX)2K8JNscpKA61fmnCcXc2OOeCUqZ1IsoN81bc9wU91jQoxUgFmxeLl0CnKRp56bgJ8Vnj)4PKWdPMEDbtdhenxO56bgJC7RtuDo(qXHScuphLROyUgYfGoT65io8qQP0F7CYO6CsCmMl0CnKRhymYTVor154dzQDzZ13CruUII5ArjNt(6aHEl3(6evNlxJZ9GCHM7RoQEU9jNthj80XNtL65i4CHMRhymYTVor154dzQDzZ13CplxH5kmxH3qL9nUUH2xNO6C3)EsGVi7gsL65i4lYVHy0BOL(BOY(gx3qa60QNJUHauhiDdv7pQtII9ttUgNBWaCUiUCnKlsaN7HY1dmg5FBs(XtjHhsn96cMgU9vgq5kmxexUgY1dmg52xNO6C8Hm1US5EOCruUNMRfLCoPa1(uUcZfXLRHCHXppcoiiXrj5alIpKP2Ln3dL7z5kmxO56bgJC7RtuDooi6neGoYsnPBO91jQoN0pUEzuDojogV)9KZUi7gsL65i4lYVHSPFAA9gcqNw9CehEi1u6VDozuDojogZfAUa0PvphXTVor15K(X1lJQZjXX4nuzFJRBO91XcoqO7FpjqVi7gsL65i4lYVHk7BCDdTGvSh6gYM(PP1B4qXHScuphLl0CFDGqp)Bts(yjCt5ACUif4CrC5ArjNt(6aHEBUbK7qMAx2CHMRIkzcigq5cnxI5AulX7sQfc3qgcmhjFDGqV9Ecs3)EcI)ISBivQNJGVi)gQSVX1nuHv0VbqsRFDmVHSPFAA9g6tUFZaQli5cnxFYvzFJlUcROFdGKw)6ykHvtfcX7sgDnebFUII5cJFUcROFdGKw)6ykHvtfcXTVYakxFZfr5cnxy8Zvyf9BaK06xhtjSAQqi(qMAx2C9nxeDdziWCK81bc927jiD)7jbZfz3qQuphbFr(nuzFJRBOjgxXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLWnLRX5AixKcCUbKRHCTOKZjFDGqVLBFDI9q5EOCrIFwUcZvyUNMRfLCo5Rde6T5gqUdzQDzZfAUgYLHXoyS)IZuzxm(qkmc5cnxd5cqNw9CeNHlayGijmzrOy5kkMldJDWy)fNHlayGi5lGKw0E63YhsHrixrXC9jxggavA98QHi4LrLYvyUII5ArjNt(6aHEl3(6e7HY13CnKBGZ9q5AixKYnGCF1r1ZF)DjnX4YYPs9CeCUcZvyUII5AixI5AulX7sAXoDYvumxd5smxJAjExsp8lixrXCjMRrTeVlPdS0jxH5cnxFY9vhvp3IbDsCu(cizepK95uPEocoxrXC9aJro60M4bUvNuhMwntIc6S6WbOoqkxJpM7bNbCUcZfAUgY1IsoN81bc9wU91j2dLRV5IeW5EOCnKls5gqUV6O65V)UKMyCz5uPEocoxH5kmxO5Q2FuNef7NMCno3ZaoxexUEGXi3(6evNJpKP2Ln3dLBGMRWCHMRHC9jxpWyKduxWdbljtuSFAmP6LurdKo4ehenxrXCjMRrTeVlPf70jxrXC9jxggavA9CGqyATYvyUqZvrLmbedOBidbMJKVoqO3EpbP7FpXOVi7gsL65i4lYVHSPFAA9gAixa60QNJ4mCbadejHjlcflxO521tdk2PpblJnebVCitTlBUgNlsic4CHMRp5YWyhm2FXzQSlgFifgHCffZ1dmg5mv2fJdIMRWCHMRA)rDsuSFAY13Cpd4CHMRHC9aJroXCnQLKoWsh(qMAx2Cno3anxrXC9aJroXCnQLKwSth(qMAx2Cno3aNRWCffZn2qe8YHm1US56BUib8nuzFJRBidxaWarYxajTO90V9(3tqc4lYUHuPEoc(I8BiB6NMwVHkQKjGyaDdv2346ggXdJK4OS0hCO7FpbjKUi7gsL65i4lYVHSPFAA9g6bgJCMk7IXbrVHk7BCDdhfavyqRmoufCeU)9eKo4ISBivQNJGVi)gYM(PP1BOHC9aJrU91jQohhenxrXCv7pQtII9ttUgN7zaNRWCHMRp56bgJCl2z)MrCq0CHMRp56bgJCMk7IXbrZfAUgY1NCzyauP1ZRgIGxgvkxrXCzySdg7V4mCbadejFbK0I2t)woiAUII521tdk2PpblJnebVCitTlBU(MldJDWy)fNHlayGi5lGKw0E63YhYu7YMBa5gO5kkMBxpnOyN(eSm2qe8YHm1US5E4CrkyaoxFZ9aGZnGCnKBGZ9q5YWfmy)C0HyTLKQRHuMu9CQuphbNRWCfEdv2346gYihz)wDs11qktQ(7FpbjeDr2nKk1ZrWxKFdzt)006n0qUEGXi3(6evNJdIMROyUQ9h1jrX(PjxJZ9mGZvyUqZ1NC9aJrUf7SFZioiAUqZ1NC9aJrotLDX4GO5cnxd56tUmmaQ065vdrWlJkLROyUmm2bJ9xCgUaGbIKVasAr7PFlhenxrXC76Pbf70NGLXgIGxoKP2LnxFZLHXoyS)IZWfamqK8fqslAp9B5dzQDzZnGCd0CffZTRNguStFcwgBicE5qMAx2CpCUifmaNRV5IiGZnGCnKBGZ9q5YWfmy)C0HyTLKQRHuMu9CQuphbNRWCfEdv2346g2ftNs)gx3)Ecsb(ISBivQNJGVi)gYM(PP1ByxpnOyN(eSm2qe8YHm1US56BUiDwUII5AixpWyKJoTjEGB1j1HPvZKOGoRoCaQdKY13Cp4mGZvumxpWyKJoTjEGB1j1HPvZKOGoRoCaQdKY14J5EWzaNRWCHMRhymYTVor154GO5cnxgg7GX(lotLDX4dzQDzZ14Cpd4BOY(gx3qYef7NgPhUGV)9eKo7ISBivQNJGVi)gQSVX1n0(KZPJm60HUHSPFAA9gouCiRa1Zr5cn3Vnj5JLWnLRX5I0z5cnxlk5CYxhi0B52xNypuU(MBGZfAUkQKjGyaLl0CnKRhymYzQSlgFitTlBUgNlsaNROyU(KRhymYzQSlghenxH3qgcmhjFDGqV9Ecs3)Ecsb6fz3qQuphbFr(nKn9ttR3qI5AulX7sQfc5cnxfvYeqmGYfAUEGXihDAt8a3QtQdtRMjrbDwD4auhiLRV5EWzaNl0CnKlm(5kSI(nasA9RJPewnvie)BgqDbjxrXC9jxggavA98Iyd2Hh4CffZ1IsoN81bc92Cno3dYv4nuzFJRByeCqqIJsYbw09VNGeI)ISBivQNJGVi)gYM(PP1BOhymYXf9cSsuAye634IdIMl0CnKRhymYTVor154dfhYkq9CuUII5Q2FuNef7NMCnoxJg4CfEdv2346gAFDIQZD)7jifmxKDdPs9Ce8f53q20pnTEdzyauP1ZRgIGxgvkxO5Aixa60QNJ4mCbadejHjlcflxrXCzySdg7V4mv2fJdIMROyUEGXiNPYUyCq0CfMl0CzySdg7V4mCbadejFbK0I2t)w(qMAx2C9nximyUPAKCpuUmQD5Aix1(J6KOy)0K7P5EgW5kmxO56bgJC7RtuDo(qMAx2C9n3aFdv2346gAFDIQZD)7jiz0xKDdPs9Ce8f53q20pnTEdzyauP1ZRgIGxgvkxO5Aixa60QNJ4mCbadejHjlcflxrXCzySdg7V4mv2fJdIMROyUEGXiNPYUyCq0CfMl0CzySdg7V4mCbadejFbK0I2t)w(qMAx2C9nximyUPAKCpuUmQD5Aix1(J6KOy)0K7P5IiGZvyUqZ1dmg52xNO6CCq0CHMlXCnQL4Dj1cHBOY(gx3q7RJfCGq3)EYbaFr2nKk1ZrWxKFdzt)006n0dmg54IEbwjZr6ib02gxCq0CffZ1qU(KR91j2dXvujtaXakxrXCnKRhymYzQSlgFitTlBU(M7z5cnxpWyKZuzxmoiAUII5AixpWyKpkaQWGwzCOk4iWhYu7YMRV5cHbZnvJK7HYLrTlxd5Q2FuNef7NMCpnxebCUcZfAUEGXiFuauHbTY4qvWrGdIMRWCfMl0CbOtREoIBFDIQZj9JRxgvNtIJXCHMRfLCo5Rde6TC7RtuDUC9nxeLRWCHMRHC9j3bSOiEGq8Vnj)4PKWdPMEDbtdNqSGnkkbNROyUwuY5KVoqO3YTVor15Y13CruUcVHk7BCDdTVowWbcD)7jhG0fz3qQuphbFr(nKn9ttR3qd5smxJAjExsTqixO5YWyhm2FXzQSlgFitTlBUgN7zaNROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCruUcZfAUkQKjGyaDdv2346gwKFPjgx3)EYbhCr2nKk1ZrWxKFdzt)006n0qUeZ1OwI3LuleYfAUmm2bJ9xCMk7IXhYu7YMRX5EgW5kkMRHCzc0bczZ9yUhKl0ChIjqhiK8BtkxFZ9SCfMROyUmb6aHS5EmxeLRWCHMRIkzcigq3qL9nUUHcuxuAIX19VNCaIUi7gsL65i4lYVHSPFAA9gAixI5AulX7sQfc5cnxgg7GX(lotLDX4dzQDzZ14Cpd4CffZ1qUmb6aHS5Em3dYfAUdXeOdes(TjLRV5EwUcZvumxMaDGq2CpMlIYvyUqZvrLmbedOBOY(gx3WiOZjnX46(3toiWxKDdv2346g6xNPXJehLKdSOBivQNJGVi)(3to4SlYUHuPEoc(I8Big9gAP)gQSVX1neGoT65OBia1bs3qlk5CYxhi0B52xNypuUgNBGZnGCJomEY1qUMQ9Pbbja1bs5EAUhaCUcZnGCJomEY1qUEGXi3(6ybhiKKmrX(PXKQxAXoD42xzaL7P5g4CfEdbOJSut6gAFDI9qYUKwStN7Fp5Ga9ISBivQNJGVi)gYM(PP1BiXCnQL4oWshzrg5ZvumxI5AulX1cbzrg5ZfAUa0PvphXBRK5ifaLROyUEGXiNyUg1ssl2PdFitTlBU(MRY(gxC7RtShItgHyGpj)2KYfAUEGXiNyUg1ssl2PdhenxrXCjMRrTeVlPf70jxO56tUa0PvphXTVoXEizxsl2PtUII56bgJCMk7IXhYu7YMRV5QSVXf3(6e7H4Krig4tYVnPCHMRp5cqNw9CeVTsMJuauUqZ1dmg5mv2fJpKP2LnxFZLmcXaFs(TjLl0C9aJrotLDX4GO5kkMRhymYhfavyqRmoufCe4GO5cnxlk5CsbQ9PCnoxG5bAUqZ1qUwuY5KVoqO3MRVhZfr5kkMRp5(QJQNBXGojokFbKmIhY(CQuphbNRWCffZ1NCbOtREoI3wjZrkakxO56bgJCMk7IXhYu7YMRX5sgHyGpj)2KUHk7BCDd9p6l4(3toaXFr2nuzFJRBO91j2dDdPs9Ce8f53)EYbbZfz3qQuphbFr(nuzFJRB4awsL9nUKU2(3qxBFzPM0nmQo3lyaV)9VHr15Ebd4fz3tq6ISBivQNJGVi)gYM(PP1BOp5oGffXdeI7PoTyKehLQZjFbDbXYjelyJIsW3qL9nUUH2xhl4aHU)9KdUi7gsL65i4lYVHk7BCDdTGvSh6gYM(PP1Bim(5MyCf7H4dzQDzZ14ChYu7YEdziWCK81bc927jiD)7ji6ISBOY(gx3qtmUI9q3qQuphbFr(9V)n0(xKDpbPlYUHuPEoc(I8BOY(gx3qfwr)gajT(1X8gYM(PP1BOp5cJFUcROFdGKw)6ykHvtfcX)MbuxqYfAU(KRY(gxCfwr)gajT(1XucRMkeI3Lm6Aic(CHMRHC9jxy8Zvyf9BaK06xhtPasD8Vza1fKCffZfg)Cfwr)gajT(1XukGuhFitTlBUgN7z5kmxrXCHXpxHv0VbqsRFDmLWQPcH42xzaLRV5IOCHMlm(5kSI(nasA9RJPewnvieFitTlBU(MlIYfAUW4NRWk63aiP1VoMsy1uHq8Vza1fKBidbMJKVoqO3EpbP7Fp5GlYUHuPEoc(I8BiB6NMwVHgYfGoT65iodxaWarsyYIqXYfAUD90GID6tWYydrWlhYu7YMRX5IeIaoxO56tUmm2bJ9xCMk7IXhsHrixrXC9aJrotLDX4GO5kmxO5Q2FuNef7NMC9n3ZaoxO5AixpWyKtmxJAjPdS0HpKP2LnxJZfjGZvumxpWyKtmxJAjPf70HpKP2LnxJZfjGZvyUII5gBicE5qMAx2C9nxKa(gQSVX1nKHlayGi5lGKw0E63E)7ji6ISBivQNJGVi)gIrVHw6VHk7BCDdbOtREo6gcqDG0n0qUEGXiNPYUy8Hm1US5ACUNLl0CnKRhymYhfavyqRmoufCe4dzQDzZ14CplxrXC9jxpWyKpkaQWGwzCOk4iWbrZvyUII56tUEGXiNPYUyCq0CffZvT)Oojk2pn56BUic4CfMl0CnKRp56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5kkMRA)rDsuSFAY13CreW5kmxO5AixpWyKtmxJAjPf70HpKP2LnxJZfcdMBQgjxrXC9aJroXCnQLKoWsh(qMAx2CnoximyUPAKCfEdbOJSut6gcJF5qiwWEitQE79VNe4lYUHuPEoc(I8BOY(gx3qtmUI9q3q20pnTEdhkoKvG65OCHM7Rde65FBsYhlHBkxJZfPdYfAUgYvrLmbedOCHMlaDA1ZrCy8lhcXc2dzs1BZv4nKHaZrYxhi0BVNG09VNC2fz3qQuphbFr(nuzFJRBOfSI9q3q20pnTEdhkoKvG65OCHM7Rde65FBsYhlHBkxJZfPdYfAUgYvrLmbedOCHMlaDA1ZrCy8lhcXc2dzs1BZv4nKHaZrYxhi0BVNG09VNeOxKDdPs9Ce8f53qL9nUUH2NCoDKrNo0nKn9ttR3WHIdzfOEokxO5(6aHE(3MK8Xs4MY14CrkqZfAUgYvrLmbedOCHMlaDA1ZrCy8lhcXc2dzs1BZv4nKHaZrYxhi0BVNG09VNG4Vi7gsL65i4lYVHSPFAA9gQOsMaIb0nuzFJRByepmsIJYsFWHU)9KG5ISBivQNJGVi)gYM(PP1BOhymYzQSlghe9gQSVX1nCuauHbTY4qvWr4(3tm6lYUHuPEoc(I8BiB6NMwVHgY1qUEGXiNyUg1ssl2PdFitTlBUgNlsaNROyUEGXiNyUg1sshyPdFitTlBUgNlsaNRWCHMldJDWy)fNPYUy8Hm1US5ACUic4CHMRHC9aJro60M4bUvNuhMwntIc6S6WbOoqkxFZ9GadCUII56tUdyrr8aH4OtBIh4wDsDyA1mjkOZQdNqSGnkkbNRWCfMROyUEGXihDAt8a3QtQdtRMjrbDwD4auhiLRXhZ9aepW5kkMldJDWy)fNPYUy8HuyeYfAUgYvT)Oojk2pn5ACUgnW5kkMlaDA1Zr82kvmLRWBOY(gx3qYef7NgPhUGV)9eKa(ISBivQNJGVi)gYM(PP1BOHCv7pQtII9ttUgNRrdCUqZ1qUEGXihOUGhcwsMOy)0ys1lPIgiDWjoiAUII56tUmmaQ065aHW0ALRWCffZLHbqLwpVAicEzuPCffZfGoT65iEBLkMYvumxpWyK75WyyhO95GO5cnxpWyK75WyyhO95dzQDzZ13Cpa4Cdixd5AixJo3dL7awuepqio60M4bUvNuhMwntIc6S6WjelyJIsW5km3aY1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZvyUcZfAU(KRhymYzQSlghenxO5AixFYLHbqLwpVAicEzuPCffZLHXoyS)IZWfamqK8fqslAp9B5GO5kkMBxpnOyN(eSm2qe8YHm1US56BUmm2bJ9xCgUaGbIKVasAr7PFlFitTlBUbKBGMROyUD90GID6tWYydrWlhYu7YM7HZfPGb4C9n3dao3aY1qUbo3dLldxWG9ZrhI1wsQUgszs1ZPs9CeCUcZv4nuzFJRBiJCK9B1jvxdPmP6V)9eKq6ISBivQNJGVi)gYM(PP1BOHCv7pQtII9ttUgNRrdCUqZ1qUEGXihOUGhcwsMOy)0ys1lPIgiDWjoiAUII56tUmmaQ065aHW0ALRWCffZLHbqLwpVAicEzuPCffZfGoT65iEBLkMYvumxpWyK75WyyhO95GO5cnxpWyK75WyyhO95dzQDzZ13CreW5gqUgY1qUgDUhk3bSOiEGqC0PnXdCRoPomTAMef0z1HtiwWgfLGZvyUbKRHCdCUhkxgUGb7NJoeRTKuDnKYKQNtL65i4CfMRWCfMl0C9jxpWyKZuzxmoiAUqZ1qU(KlddGkTEE1qe8YOs5kkMldJDWy)fNHlayGi5lGKw0E63YbrZvum3UEAqXo9jyzSHi4LdzQDzZ13CzySdg7V4mCbadejFbK0I2t)w(qMAx2Cdi3anxrXC76Pbf70NGLXgIGxoKP2Ln3dNlsbdW56BUic4Cdixd5g4CpuUmCbd2phDiwBjP6AiLjvpNk1ZrW5kmxH3qL9nUUHDX0P0VX19VNG0bxKDdPs9Ce8f53qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHgY1NCzySdg7V4mv2fJpKcJqUII56tUa0PvphXz4cagisctwekwUqZLHbqLwpVAicEzuPCfEdbOJSut6gAvaKmIhjtLDXU)9eKq0fz3qQuphbFr(nKn9ttR3qI5AulX7sQfc5cnxfvYeqmGYfAUEGXihDAt8a3QtQdtRMjrbDwD4auhiLRV5EqGboxO5Aixy8Zvyf9BaK06xhtjSAQqi(3mG6csUII56tUmmaQ065fXgSdpW5kmxO5cqNw9Ce3QaizepsMk7IDdv2346ggbheK4OKCGfD)7jif4lYUHuPEoc(I8BiB6NMwVHEGXihx0lWkrPHrOFJloiAUqZ1dmg52xNO6C8HIdzfOEo6gQSVX1n0(6evN7(3tq6SlYUHuPEoc(I8BiB6NMwVHEGXi3(64WdmFitTlBU(M7z5cnxd56bgJCI5AuljTyNo8Hm1US5ACUNLROyUEGXiNyUg1sshyPdFitTlBUgN7z5kmxO5Q2FuNef7NMCnoxJg4BOY(gx3qMwmYj9aJXBOhymkl1KUH2xhhEGV)9eKc0lYUHuPEoc(I8BiB6NMwVHmmaQ065vdrWlJkLl0CbOtREoIZWfamqKeMSiuSCHMldJDWy)fNHlayGi5lGKw0E63YhYu7YMRV5cHbZnvJK7HYLrTlxd5Q2FuNef7NMCpnxebCUcVHk7BCDdTVowWbcD)7jiH4Vi7gsL65i4lYVHSPFAA9g(QJQNBFY50rcpD85uPEocoxO56tUV6O652xhhEG5uPEocoxO56bgJC7RtuDo(qXHScuphLl0CnKRhymYjMRrTK0bw6WhYu7YMRX5gO5cnxI5AulX7s6alDYfAUEGXihDAt8a3QtQdtRMjrbDwD4auhiLRV5EWzaNROyUEGXihDAt8a3QtQdtRMjrbDwD4auhiLRXhZ9GZaoxO5Q2FuNef7NMCnoxJg4CffZfg)Cfwr)gajT(1XucRMkeIpKP2LnxJZnyYvumxL9nU4kSI(nasA9RJPewnvieVlz01qe85kmxO56tUmm2bJ9xCMk7IXhsHr4gQSVX1n0(6evN7(3tqkyUi7gsL65i4lYVHSPFAA9g6bgJCCrVaRK5iDKaABJloiAUII56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5kkMRhymYzQSlghenxO5AixpWyKpkaQWGwzCOk4iWhYu7YMRV5cHbZnvJK7HYLrTlxd5Q2FuNef7NMCpnxebCUcZfAUEGXiFuauHbTY4qvWrGdIMROyU(KRhymYhfavyqRmoufCe4GO5cnxFYLHXoyS)IpkaQWGwzCOk4iWhsHrixrXC9jxggavA9Cau9cqyYvyUII5Q2FuNef7NMCnoxJg4CHMlXCnQL4Dj1cHBOY(gx3q7RJfCGq3)Ecsg9fz3qQuphbFr(nKn9ttR3WxDu9C7RJdpWCQuphbNl0CnKRhymYTVoo8aZbrZvumx1(J6KOy)0KRX5A0aNRWCHMRhymYTVoo8aZTVYakxFZfr5cnxd56bgJCI5AuljTyNoCq0CffZ1dmg5eZ1Ows6alD4GO5kmxO56bgJC0PnXdCRoPomTAMef0z1HdqDGuU(M7biEGZfAUgYLHXoyS)IZuzxm(qMAx2CnoxKaoxrXC9jxa60QNJ4mCbadejHjlcflxO5YWaOsRNxnebVmQuUcVHk7BCDdTVowWbcD)7jha8fz3qQuphbFr(nKn9ttR3qd56bgJC0PnXdCRoPomTAMef0z1HdqDGuU(M7biEGZvumxpWyKJoTjEGB1j1HPvZKOGoRoCaQdKY13Cp4mGZfAUV6O652NCoDKWthFovQNJGZvyUqZ1dmg5eZ1OwsAXoD4dzQDzZ14Cr85cnxI5AulX7sAXoDYfAU(KRhymYXf9cSsuAye634IdIMl0C9j3xDu9C7RJdpWCQuphbNl0CzySdg7V4mv2fJpKP2LnxJZfXNl0CnKldJDWy)fhOUGhcwAr7PFlFitTlBUgNlIpxrXC9jxggavA9CGqyATYv4nuzFJRBO91XcoqO7Fp5aKUi7gsL65i4lYVHSPFAA9gAixpWyKtmxJAjPdS0HdIMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCruUcZfAUkQKjGyaLl0CbOtREoIBvaKmIhjtLDXUHk7BCDdlYV0eJR7Fp5GdUi7gsL65i4lYVHSPFAA9gAixpWyKtmxJAjPdS0HdIMl0C9jxggavA9CGqyATYvumxd56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5cnxggavA9CGqyATYvyUII5AixMaDGq2CpM7b5cn3Hyc0bcj)2KY13CplxH5kkMltGoqiBUhZfr5kkMRhymYzQSlghenxH5cnxfvYeqmGYfAUa0PvphXTkasgXJKPYUy3qL9nUUHcuxuAIX19VNCaIUi7gsL65i4lYVHSPFAA9gAixpWyKtmxJAjPdS0HdIMl0C9jxggavA9CGqyATYvumxd56bgJCG6cEiyjzII9tJjvVKkAG0bN4GO5cnxggavA9CGqyATYvyUII5AixMaDGq2CpM7b5cn3Hyc0bcj)2KY13CplxH5kkMltGoqiBUhZfr5kkMRhymYzQSlghenxH5cnxfvYeqmGYfAUa0PvphXTkasgXJKPYUy3qL9nUUHrqNtAIX19VNCqGVi7gQSVX1n0VotJhjokjhyr3qQuphbFr(9VNCWzxKDdPs9Ce8f53q20pnTEdjMRrTeVlPdS0jxrXCjMRrTe3ID6ilYiFUII5smxJAjUwiilYiFUII56bgJC)6mnEK4OKCGfXbrZfAUEGXiNyUg1sshyPdhenxrXCnKRhymYzQSlgFitTlBU(MRY(gxC)J(c4Krig4tYVnPCHMRhymYzQSlghenxH3qL9nUUH2xNyp09VNCqGEr2nuzFJRBO)rFb3qQuphbFr(9VNCaI)ISBivQNJGVi)gQSVX1nCalPY(gxsxB)BORTVSut6ggvN7fmG3)(3q0Hyytp9Vi7EcsxKDdv2346gAIXfqDjJ4X8gsL65i4lYV)9KdUi7gQSVX1neOUGhcwAr7PF7nKk1ZrWxKF)7ji6ISBivQNJGVi)gQSVX1n0)OVGBORlsYGVHib89VNe4lYUHuPEoc(I8BiB6NMwVHOdbGJe3)OVGCHMRp5Ioea(bC)J(cUHk7BCDd9p6l4(3to7ISBOY(gx3q7RtSh6gsL65i4lYV)9Ka9ISBivQNJGVi)gIrVHw6VHk7BCDdbOtREo6gcqDG0n0dBT5cn3OdJNCnKRHCJnebVCitTlBUiUCpa4CfM7P5I0baNRWCno3OdJNCnKRHCJnebVCitTlBUiUCp4SCrC5AixKao3dL7RoQEExmDk9BCXPs9CeCUcZfXLRHCdCUhkxgUGb7NJoeRTKuDnKYKQNtL65i4CfMRWCpnxKcgGZv4neGoYsnPBidxaWarsyYIqXU)9V)nean2gx3toa4dagjKo4SBOFDQUGyVHiMGy2OYjgvpbXqJsU5ImbuUTjkE(CJ4jxeJWdPMEDbtdIXChcXc2dbNRfBs5QGp2uFcoxMaTGqwEguW2fL7bgLCdeCbGMNGZnSndKCTiuVAKCpCUpo3GfuZfUb02gx5IrPrF8KRHtfMRbKmIqEguW2fLlsizuYnqWfaAEco3W2mqY1Iq9QrY9Who3hNBWcQ5AIHbDG2CXO0OpEY1WHfMRbKmIqEguW2fLlshyuYnqWfaAEco3W2mqY1Iq9QrY9Who3hNBWcQ5AIHbDG2CXO0OpEY1WHfMRbKmIqEguW2fLlsNzuYnqWfaAEco3W2mqY1Iq9QrY9W5(4Cdwqnx4gqBBCLlgLg9XtUgovyUgqYic5zqzqiMGy2OYjgvpbXqJsU5ImbuUTjkE(CJ4jxeJOdXWME6Jym3HqSG9qW5AXMuUk4Jn1NGZLjqliKLNbfSDr5gOgLCdeCbGMNGZnSndKCTiuVAKCpCUpo3GfuZfUb02gx5IrPrF8KRHtfMRHdmIqEgugeIjiMnQCIr1tqm0OKBUitaLBBIINp3iEYfXOIjeJ5oeIfShcoxl2KYvbFSP(eCUmbAbHS8mOGTlk3dmk5gi4canpbNByBgi5ArOE1i5E4dN7JZnyb1CnXWGoqBUyuA0hp5A4WcZ1asgripdky7IYnWgLCdeCbGMNGZnSndKCTiuVAKCpCUpo3GfuZfUb02gx5IrPrF8KRHtfMRbKmIqEguW2fLBWyuYnqWfaAEco3W2mqY1Iq9QrY9W5(4Cdwqnx4gqBBCLlgLg9XtUgovyUgqYic5zqbBxuUiDGrj3abxaO5j4CdBZajxlc1Rgj3dF4CFCUblOMRjgg0bAZfJsJ(4jxdhwyUgqYic5zqbBxuUiHiJsUbcUaqZtW5g2MbsUweQxnsUh(W5(4CdwqnxtmmOd0MlgLg9XtUgoSWCnGKreYZGc2UOCrkymk5gi4canpbNByBgi5ArOE1i5E4CFCUblOMlCdOTnUYfJsJ(4jxdNkmxdizeH8mOGTlkxKmAJsUbcUaqZtW5g2MbsUweQxnsUho3hNBWcQ5c3aABJRCXO0OpEY1WPcZ1asgripdky7IY9aGnk5gi4canpbNByBgi5ArOE1i5E4CFCUblOMlCdOTnUYfJsJ(4jxdNkmxdizeH8mOGTlk3doZOKBGGla08eCUHTzGKRfH6vJK7HZ9X5gSGAUWnG224kxmkn6JNCnCQWCnCGreYZGYGqmbXSrLtmQEcIHgLCZfzcOCBtu885gXtUigTpIXChcXc2dbNRfBs5QGp2uFcoxMaTGqwEguW2fLlsaBuYnqWfaAEco3W2mqY1Iq9QrY9Who3hNBWcQ5AIHbDG2CXO0OpEY1WHfMRbKmIqEguW2fLlsizuYnqWfaAEco3W2mqY1Iq9QrY9Who3hNBWcQ5AIHbDG2CXO0OpEY1WHfMRbKmIqEguW2fLlsbQrj3abxaO5j4CdBZajxlc1Rgj3dN7JZnyb1CHBaTTXvUyuA0hp5A4uH5AajJiKNbfSDr5IuWyuYnqWfaAEco3W2mqY1Iq9QrY9W5(4Cdwqnx4gqBBCLlgLg9XtUgovyUgqYic5zqzqiMGy2OYjgvpbXqJsU5ImbuUTjkE(CJ4jxeJEy9rmM7qiwWEi4CTytkxf8XM6tW5YeOfeYYZGc2UOCpWOKBGGla08eCUHTzGKRfH6vJK7HZ9X5gSGAUWnG224kxmkn6JNCnCQWCnCGreYZGc2UOCr6mJsUbcUaqZtW5g2MbsUweQxnsUh(W5(4CdwqnxtmmOd0MlgLg9XtUgoSWCnGKreYZGc2UOCrkymk5gi4canpbNByBgi5ArOE1i5E4CFCUblOMlCdOTnUYfJsJ(4jxdNkmxdiYic5zqbBxuUiz0gLCdeCbGMNGZnSndKCTiuVAKCpCUpo3GfuZfUb02gx5IrPrF8KRHtfMRbKmIqEgugKrvtu88eCUi(Cv234kxxBFlpd6gArj29eKa(GBi6GJTJUHg15IC1PfJYfXudydNbzuN7jyaKPhn5EGrFEUha8baNbLbzuNBGiqliK1OKbzuNlIlxeZWWeCUHyNo5ICsn5zqg15I4YnqeOfeco3xhi0l7yUm1s2CFCUmeyos(6aHElpdYOoxexUgvitmacoxWQigzT6GqUa0PvphzZ1qZj(55IoeaP91XcoqOCrCgNl6qa42xhl4aHeYZGYGu234YYrhIHn90)Ojgxa1LmIhZmiL9nUSC0Hyytp9d44Pa1f8qWslAp9BZGu234YYrhIHn90pGJN6F0xW5UUijd(isaNbPSVXLLJoedB6PFahp1)OVGZ74r0HaWrI7F0xauFqhca)aU)rFbzqk7BCz5OdXWME6hWXtTVoXEOmiL9nUSC0Hyytp9d44Pa0PvphDEPM0rgUaGbIKWKfHIDoa1bsh9Wwl0OdJhdgInebVCitTllI7aGfEyKoayHghDy8yWqSHi4LdzQDzrChCgIZasaFOxDu98Uy6u634ItL65iyHiodb(qmCbd2phDiwBjP6AiLjvpNk1ZrWcfEyKcgGfMbLbzuNlIPncXaFcoxcaniK73MuUVakxL94j32MRcqBN65iEgKY(gx2JwSthPhPMzqk7BCzd44Pa0PvphDEPM0X2kvmDoa1bshTOKZjFDGqVLBFDIQZzmsqn4ZRoQEU91XHhyovQNJGffF1r1ZTp5C6iHNo(CQuphbluu0IsoN81bc9wU91jQoNXhKbPSVXLnGJNcqNw9C05LAshBRK5ifaDoa1bshTOKZjFDGqVLBFDI9qgJugKY(gx2aoEQhnwAaQliN3XJg8HHbqLwpVAicEzujrrFyySdg7V4mCbadejFbK0I2t)woiQqOEGXiNPYUyCq0miL9nUSbC8uu83468oE0dmg5mv2fJdIMbPSVXLnGJNcAjz)KPndszFJlBahpvaPZljRLkgDEhp6iaKZ3ZqkdszFJlBahpDalPY(gxsxB)Zl1KoQy6C7pn7pI05D8iaDA1Zr82kvmLbPSVXLnGJNoGLuzFJlPRT)5LAshHhsn96cMMZT)0S)isN3XJdyrr8aH4FBs(XtjHhsn96cMgoHybBuucodszFJlBahpDalPY(gxsxB)Zl1Ko6H1)C7pn7pI05D84awuepqiUN60IrsCuQoN8f0felNqSGnkkbNbPSVXLnGJNoGLuzFJlPRT)5LAshTFgugKY(gxwUIPJa0PvphDEPM0r4HutP)25Kr15K4y8CaQdKoAWdmg5FBs(XtjHhsn96cMg(qMAxwFHWG5MQrcayosIIEGXi)BtYpEkj8qQPxxW0WhYu7Y6RY(gxC7RtShItgHyGpj)2KcayosqnqmxJAjExshyPJOiXCnQL4wSthzrg5ffjMRrTexleKfzKxOqOEGXi)BtYpEkj8qQPxxW0WbrHoGffXdeI)Tj5hpLeEi10RlyA4eIfSrrj4miL9nUSCftbC8u7RtuDUZ74rpWyKBFDIQZXhkoKvG65iOgSOKZjFDGqVLBFDIQZ5lIef9zalkIhie)BtYpEkj8qQPxxW0WjelyJIsWcHAWNbSOiEGqChcmDuRm6i67cIeIRnrTeNqSGnkkblk(TjD4dh4Zm2dmg52xNO6C8Hm1USbCGWmiL9nUSCftbC8u7RtuDUZ74XbSOiEGq8Vnj)4PKWdPMEDbtdNqSGnkkbd1IsoN81bc9wU91jQoNXhreud(4bgJ8Vnj)4PKWdPMEDbtdhefQhymYTVor154dfhYkq9CKOOba60QNJ4WdPMs)TZjJQZjXXiudEGXi3(6evNJpKP2L1xejkArjNt(6aHEl3(6evNZ4dG(QJQNBFY50rcpD85uPEocgQhymYTVor154dzQDz99mHcfMbPSVXLLRykGJNcqNw9C05LAshTVor15K(X1lJQZjXX45auhiDuT)Oojk2pnghmaJ4mGeWhYdmg5FBs(XtjHhsn96cMgU9vgqcrCg8aJrU91jQohFitTl7Hq0HTOKZjfO2NeI4maJFEeCqqIJsYbweFitTl7HotiupWyKBFDIQZXbrZGu234YYvmfWXtTVowWbcDEhpcqNw9CehEi1u6VDozuDojogHcqNw9Ce3(6evNt6hxVmQoNehJzqk7BCz5kMc44PwWk2dDodbMJKVoqO3EePZ74XHIdzfOEoc6Rde65FBsYhlHBYyKcmIZIsoN81bc92agYu7YcvrLmbediOeZ1OwI3LuleYGu234YYvmfWXtvyf9BaK06xhZZziWCK81bc92JiDEhp6Z3mG6ccuFu234IRWk63aiP1VoMsy1uHq8UKrxdrWlkcJFUcROFdGKw)6ykHvtfcXTVYaYxebfg)Cfwr)gajT(1XucRMkeIpKP2L1xeLbPSVXLLRykGJNAIXvSh6CgcmhjFDGqV9isN3XJdfhYkq9Ce0xhi0Z)2KKpwc3KXgqkWbyWIsoN81bc9wU91j2dDiK4Nju4HTOKZjFDGqVnGHm1USqnWWyhm2FXzQSlgFifgbOgaOtREoIZWfamqKeMSiumrrgg7GX(lodxaWarYxajTO90VLpKcJGOOpmmaQ065vdrWlJkjuu0IsoN81bc9wU91j2d5RHaFidifWRoQE(7VlPjgxwovQNJGfkuu0aXCnQL4DjTyNoIIgiMRrTeVlPh(fiksmxJAjExshyPJqO(8QJQNBXGojokFbKmIhY(CQuphblk6bgJC0PnXdCRoPomTAMef0z1HdqDGKXhp4mGfc1GfLCo5Rde6TC7RtShYxKa(qgqkGxDu983FxstmUSCQuphbluiu1(J6KOy)0y8zaJ48aJrU91jQohFitTl7HcuHqn4JhymYbQl4HGLKjk2pnMu9sQObshCIdIkksmxJAjExsl2PJOOpmmaQ065aHW0AjeQIkzcigqzqk7BCz5kMc44PmCbadejFbK0I2t)2Z74rda0PvphXz4cagisctwekg0UEAqXo9jyzSHi4LdzQDzngjebmuFyySdg7V4mv2fJpKcJGOOhymYzQSlgheviu1(J6KOy)047zad1GhymYjMRrTK0bw6WhYu7YACGkk6bgJCI5AuljTyNo8Hm1USghyHIIXgIGxoKP2L1xKaodszFJllxXuahpnIhgjXrzPp4qN3XJkQKjGyaLbPSVXLLRykGJNokaQWGwzCOk4iCEhp6bgJCMk7IXbrZGu234YYvmfWXtzKJSFRoP6AiLjv)5D8ObpWyKBFDIQZXbrffv7pQtII9tJXNbSqO(4bgJCl2z)MrCquO(4bgJCMk7IXbrHAWhggavA98QHi4LrLefzySdg7V4mCbadejFbK0I2t)woiQOyxpnOyN(eSm2qe8YHm1US(YWyhm2FXz4cagis(ciPfTN(T8Hm1USbeOIID90GID6tWYydrWlhYu7YE4dJuWaSVhaCagc8Hy4cgSFo6qS2ss11qktQEovQNJGfkmdszFJllxXuahpTlMoL(nUoVJhn4bgJC7RtuDooiQOOA)rDsuSFAm(mGfc1hpWyKBXo73mIdIc1hpWyKZuzxmoikud(WWaOsRNxnebVmQKOidJDWy)fNHlayGi5lGKw0E63Ybrff76Pbf70NGLXgIGxoKP2L1xgg7GX(lodxaWarYxajTO90VLpKP2LnGavuSRNguStFcwgBicE5qMAx2dFyKcgG9frahGHaFigUGb7NJoeRTKuDnKYKQNtL65iyHcZGu234YYvmfWXtjtuSFAKE4c(8oESRNguStFcwgBicE5qMAxwFr6mrrdEGXihDAt8a3QtQdtRMjrbDwD4auhi57bNbSOOhymYrN2epWT6K6W0QzsuqNvhoa1bsgF8GZawiupWyKBFDIQZXbrHYWyhm2FXzQSlgFitTlRXNbCgKY(gxwUIPaoEQ9jNthz0PdDodbMJKVoqO3EePZ74XHIdzfOEoc63MK8Xs4MmgPZGArjNt(6aHEl3(6e7H8nWqvujtaXacQbpWyKZuzxm(qMAxwJrcyrrF8aJrotLDX4GOcZGu234YYvmfWXtJGdcsCusoWIoVJhjMRrTeVlPwiavrLmbediOEGXihDAt8a3QtQdtRMjrbDwD4auhi57bNbmudW4NRWk63aiP1VoMsy1uHq8Vza1ferrFyyauP1ZlInyhEGffTOKZjFDGqV14deMbPSVXLLRykGJNAFDIQZDEhp6bgJCCrVaReLggH(nU4GOqn4bgJC7RtuDo(qXHScuphjkQ2FuNef7NgJnAGfMbPSVXLLRykGJNAFDIQZDEhpYWaOsRNxnebVmQeuda0PvphXz4cagisctwekMOidJDWy)fNPYUyCqurrpWyKZuzxmoiQqOmm2bJ9xCgUaGbIKVasAr7PFlFitTlRVqyWCt1ihIrTZGA)rDsuSFAo8zaleQhymYTVor154dzQDz9nWzqk7BCz5kMc44P2xhl4aHoVJhzyauP1ZRgIGxgvcQba60QNJ4mCbadejHjlcftuKHXoyS)IZuzxmoiQOOhymYzQSlgheviugg7GX(lodxaWarYxajTO90VLpKP2L1ximyUPAKdXO2zqT)Oojk2pnhgraleQhymYTVor154GOqjMRrTeVlPwiKbPSVXLLRykGJNAFDSGde68oE0dmg54IEbwjZr6ib02gxCqurrd(yFDI9qCfvYeqmGefn4bgJCMk7IXhYu7Y67zq9aJrotLDX4GOIIg8aJr(OaOcdALXHQGJaFitTlRVqyWCt1ihIrTZGA)rDsuSFAomIawiupWyKpkaQWGwzCOk4iWbrfkekaDA1ZrC7RtuDoPFC9YO6CsCmc1IsoN81bc9wU91jQoNVisiud(mGffXdeI)Tj5hpLeEi10RlyA4eIfSrrjyrrlk5CYxhi0B52xNO6C(IiHzqk7BCz5kMc44Pf5xAIX15D8ObI5AulX7sQfcqzySdg7V4mv2fJpKP2L14Zawu0atGoqi7XdGoetGoqi53MKVNjuuKjqhiK9iIecvrLmbedOmiL9nUSCftbC8ubQlknX468oE0aXCnQL4Dj1cbOmm2bJ9xCMk7IXhYu7YA8zalkAGjqhiK94bqhIjqhiK8BtY3ZekkYeOdeYEercHQOsMaIbugKY(gxwUIPaoEAe05KMyCDEhpAGyUg1s8UKAHaugg7GX(lotLDX4dzQDzn(mGffnWeOdeYE8aOdXeOdes(Tj57zcffzc0bczpIiHqvujtaXakdszFJllxXuahp1VotJhjokjhyrzqk7BCz5kMc44Pa0PvphDEPM0r7RtShs2L0ID6Coa1bshTOKZjFDGqVLBFDI9qgh4aIomEmyQ2NgeKauhiD4dawyarhgpg8aJrU91XcoqijzII9tJjvV0ID6WTVYa6WbwygKY(gxwUIPaoEQ)rFbN3XJeZ1OwI7alDKfzKxuKyUg1sCTqqwKrEOa0PvphXBRK5ifajk6bgJCI5AuljTyNo8Hm1US(QSVXf3(6e7H4Krig4tYVnjOEGXiNyUg1ssl2PdhevuKyUg1s8UKwSthO(aqNw9Ce3(6e7HKDjTyNoIIEGXiNPYUy8Hm1US(QSVXf3(6e7H4Krig4tYVnjO(aqNw9CeVTsMJuaeupWyKZuzxm(qMAxwFjJqmWNKFBsq9aJrotLDX4GOIIEGXiFuauHbTY4qvWrGdIc1IsoNuGAFYyG5bkudwuY5KVoqO367rejk6ZRoQEUfd6K4O8fqYiEi7ZPs9CeSqrrFaOtREoI3wjZrkacQhymYzQSlgFitTlRXKrig4tYVnPmiL9nUSCftbC8u7RtShkdszFJllxXuahpDalPY(gxsxB)Zl1KogvN7fmGzqzqk7BCz5Ey9pokaQWGwzCOk4iCEhp6bgJCMk7IXbrZGu234YY9W6hWXtbOtREo68snPJmCbadejHjlcf7CaQdKogDy8yWqxpnOyN(eSm2qe8YHm1USiUdaw4Hr6aGfAC0HXJbdD90GID6tWYydrWlhYu7YI4o4meNbKa(qV6O65DX0P0VXfNk1ZrWcrCgc8Hy4cgSFo6qS2ss11qktQEovQNJGfk8WifmalmdszFJll3dRFahpfGoT65OZl1KoYM(l8dIEoa1bsh9Xdmg5EQtlgjXrP6CYxqxqSYsFWH4GOq9Xdmg5EQtlgjXrP6CYxqxqSsDyArCq0miL9nUSCpS(bC8ufwr)gajT(1X8CgcmhjFDGqV9isN3XJEGXi3tDAXijokvNt(c6cIvw6doe3(kdija1bs(gyGH6bgJCp1PfJK4OuDo5lOliwPomTiU9vgqsaQdK8nWad1GpW4NRWk63aiP1VoMsy1uHq8Vza1feO(OSVXfxHv0VbqsRFDmLWQPcH4DjJUgIGhQbFGXpxHv0VbqsRFDmLci1X)MbuxqefHXpxHv0VbqsRFDmLci1XhYu7YAmIekkcJFUcROFdGKw)6ykHvtfcXTVYaYxebfg)Cfwr)gajT(1XucRMkeIpKP2L13ZGcJFUcROFdGKw)6ykHvtfcX)MbuxqeMbPSVXLL7H1pGJNYWfamqK8fqslAp9BpVJhnaqNw9CeNHlayGijmzrOyq76Pbf70NGLXgIGxoKP2L1yKqeWq9HHXoyS)IZuzxm(qkmcIIEGXiNPYUyCquHqn4bgJCp1PfJK4OuDo5lOliwzPp4qC7RmGKauhiD8mGff9aJrUN60IrsCuQoN8f0feRuhMwe3(kdija1bshpdyHIIXgIGxoKP2L1xKaodszFJll3dRFahpLPfJCspWy88snPJ2xhhEGpVJhn4bgJCp1PfJK4OuDo5lOliwzPp4q8Hm1USghy(zIIEGXi3tDAXijokvNt(c6cIvQdtlIpKP2L14aZptiu1(J6KOy)0y8rJgyOgyySdg7V4mv2fJpKP2L1yeVOObgg7GX(lozII9tJ0dxW8Hm1USgJ4H6JhymYbQl4HGLKjk2pnMu9sQObshCIdIcLHbqLwphieMwlHcZGu234YY9W6hWXtTVowWbcDEhp6daDA1ZrC20FHFquOgyyauP1ZRgIGxgvsuKHXoyS)IZuzxm(qMAxwJr8IIgyySdg7V4Kjk2pnspCbZhYu7YAmIhQpEGXihOUGhcwsMOy)0ys1lPIgiDWjoikuggavA9CGqyATekmdszFJll3dRFahp1(6ybhi05D8Obgg7GX(lodxaWarYxajTO90VLdIc1aaDA1ZrCgUaGbIKWKfHIjkYWyhm2FXzQSlgFitTlRVNjuiu1(J6KOy)0y8zadLHbqLwpVAicEzuPmiL9nUSCpS(bC8ulyf7HoNHaZrYxhi0BpI05D84qXHScuphb91bc98Vnj5JLWnzmsbkudkQKjGyab1aaDA1ZrC20FHFqurrdQ9h1jrX(PXxebmuF8aJrotLDX4GOcffzySdg7V4mv2fJpKcJGqHzqk7BCz5Ey9d44PMyCf7HoNHaZrYxhi0BpI05D84qXHScuphb91bc98Vnj5JLWnzmsiIFgudkQKjGyab1aaDA1ZrC20FHFqurrdQ9h1jrX(PXxebmuF8aJrotLDX4GOcffzySdg7V4mv2fJpKcJGqO(4bgJCG6cEiyjzII9tJjvVKkAG0bN4GOcZGu234YY9W6hWXtTp5C6iJoDOZziWCK81bc92JiDEhpouCiRa1ZrqFDGqp)Bts(yjCtgJuGgWqMAxwOguujtaXacQba60QNJ4SP)c)GOIIQ9h1jrX(PXxebSOidJDWy)fNPYUy8HuyeekmdszFJll3dRFahpnIhgjXrzPp4qN3XJkQKjGyaLbPSVXLL7H1pGJNgbheK4OKCGfDEhpAGyUg1s8UKAHGOiXCnQL4wSthzxsKefjMRrTe3bw6i7sIKqOg8HHbqLwpVAicEzujrrdQ9h1jrX(PXxJ(mOgaOtREoIZM(l8dIkkQ2FuNef7NgFreWIIa0PvphXBRuXKqOgaOtREoIZWfamqKeMSiumO(WWyhm2FXz4cagis(ciPfTN(TCqurrFaOtREoIZWfamqKeMSiumO(WWyhm2FXzQSlghevOqHqnWWyhm2FXzQSlgFitTlRXicyrr1(J6KOy)0ySrdmugg7GX(lotLDX4GOqnWWyhm2FXjtuSFAKE4cMpKP2L1xL9nU42xNypeNmcXaFs(Tjjk6dddGkTEoqimTwcff76Pbf70NGLXgIGxoKP2L1xKawiudW4NRWk63aiP1VoMsy1uHq8Hm1USghyrrFyyauP1ZlInyhEGfMbPSVXLL7H1pGJNcuxWdblTO90V98oE0aXCnQL4oWshzrg5ffjMRrTe3ID6ilYiVOiXCnQL4AHGSiJ8IIEGXi3tDAXijokvNt(c6cIvw6doeFitTlRXbMFMOOhymY9uNwmsIJs15KVGUGyL6W0I4dzQDznoW8Zefv7pQtII9tJXgnWqzySdg7V4mv2fJpKcJGqOgyySdg7V4mv2fJpKP2L1yebSOidJDWy)fNPYUy8Huyeekk21tdk2PpblJnebVCitTlRVibCgKY(gxwUhw)aoEkJCK9B1jvxdPmP6pVJhnO2FuNef7NgJnAGHAWdmg5a1f8qWsYef7NgtQEjv0aPdoXbrff9HHbqLwphieMwlHIImmaQ065vdrWlJkjk6bgJCphgd7aTphefQhymY9CymSd0(8Hm1US(EaWbyiWhIHlyW(5OdXAljvxdPmP65uPEocwOqOg8HHbqLwpVAicEzujrrgg7GX(lodxaWarYxajTO90VLdIkk21tdk2PpblJnebVCitTlRVmm2bJ9xCgUaGbIKVasAr7PFlFitTlBabQOyxpnOyN(eSm2qe8YHm1USh(Wifma77bahGHaFigUGb7NJoeRTKuDnKYKQNtL65iyHcZGu234YY9W6hWXt7IPtPFJRZ74rdQ9h1jrX(PXyJgyOg8aJroqDbpeSKmrX(PXKQxsfnq6GtCqurrFyyauP1ZbcHP1sOOiddGkTEE1qe8YOsIIEGXi3ZHXWoq7ZbrH6bgJCphgd7aTpFitTlRVic4ame4dXWfmy)C0HyTLKQRHuMu9CQuphbluiud(WWaOsRNxnebVmQKOidJDWy)fNHlayGi5lGKw0E63YbrffbOtREoIZWfamqKeMSiumOD90GID6tWYydrWlhYu7YAmsbdWbCaWbyiWhIHlyW(5OdXAljvxdPmP65uPEocwOOyxpnOyN(eSm2qe8YHm1US(YWyhm2FXz4cagis(ciPfTN(T8Hm1USbeOIID90GID6tWYydrWlhYu7Y6lIaoadb(qmCbd2phDiwBjP6AiLjvpNk1ZrWcfMbPSVXLL7H1pGJNAFDSGde68oEKHbqLwpVAicEzujOgaOtREoIZWfamqKeMSiumrrgg7GX(lotLDX4dzQDz9fjGfcvT)Oojk2pngFgWqzySdg7V4mCbadejFbK0I2t)w(qMAxwFrc4miL9nUSCpS(bC8ua60QNJoVut6OArrmGMqIDoa1bshjMRrTeVlPdS05qbZHv234IBFDI9qCYied8j53Mua(qmxJAjExshyPZHc0dRSVXf3)OVaozeIb(K8BtkaG5hCylk5CsbQ9PmiL9nUSCpS(bC8u7RJfCGqN3XJg66Pbf70NGLXgIGxoKP2L13alkAWdmg5JcGkmOvghQcoc8Hm1US(cHbZnvJCig1odQ9h1jrX(P5WicyHq9aJr(OaOcdALXHQGJahevOqrrdQ9h1jrX(Pjaa60QNJ4QffXaAcj2H8aJroXCnQLKwSth(qMAx2aGXppcoiiXrj5alI)ndiRCitTRdDa)mJr6aGffv7pQtII9ttaa0PvphXvlkIb0esSd5bgJCI5AuljDGLo8Hm1USbaJFEeCqqIJsYbwe)Bgqw5qMAxh6a(zgJ0balekXCnQL4Dj1cbOgm4ddJDWy)fNPYUyCqurrggavA9CGqyATG6ddJDWy)fNmrX(Pr6HlyoiQqrrggavA98QHi4LrLec1GpmmaQ065aO6fGWik6JhymYzQSlghevuuT)Oojk2pngB0aluu0dmg5mv2fJpKP2L14GbQpEGXiFuauHbTY4qvWrGdIMbPSVXLL7H1pGJNwKFPjgxN3XJg8aJroXCnQLKoWshoiQOObMaDGq2JhaDiMaDGqYVnjFptOOitGoqi7rejeQIkzcigqzqk7BCz5Ey9d44PcuxuAIX15D8ObpWyKtmxJAjPdS0HdIkkAGjqhiK94bqhIjqhiK8BtY3ZekkYeOdeYEercHQOsMaIbugKY(gxwUhw)aoEAe05KMyCDEhpAWdmg5eZ1Ows6alD4GOIIgyc0bczpEa0Hyc0bcj)2K89mHIImb6aHShrKqOkQKjGyaLbPSVXLL7H1pGJN6xNPXJehLKdSOmiL9nUSCpS(bC8u7RtSh68oEKyUg1s8UKoWshrrI5AulXTyNoYImYlksmxJAjUwiilYiVOOhymY9RZ04rIJsYbwehefkXCnQL4DjDGLoIIg8aJrotLDX4dzQDz9vzFJlU)rFbCYied8j53MeupWyKZuzxmoiQWmiL9nUSCpS(bC8u)J(cYGu234YY9W6hWXthWsQSVXL012)8snPJr15EbdygugKY(gxwo8qQPxxW0CeGoT65OZl1KoA1ijFSe0sslk5CNdqDG0rdEGXi)BtYpEkj8qQPxxW0WhYu7YAmegm3unsaaZrcQbI5AulX7s6HFbIIeZ1OwI3L0ID6iksmxJAjUdS0rwKrEHIIEGXi)BtYpEkj8qQPxxW0WhYu7YASY(gxC7RtShItgHyGpj)2KcayosqnqmxJAjExshyPJOiXCnQL4wSthzrg5ffjMRrTexleKfzKxOqrrF8aJr(3MKF8us4HutVUGPHdIMbPSVXLLdpKA61fmnbC8u7RJfCGqN3XJg8bGoT65iUvJK8XsqljTOKZjkAWdmg5JcGkmOvghQcoc8Hm1US(cHbZnvJCig1odQ9h1jrX(P5WicyHq9aJr(OaOcdALXHQGJahevOqrr1(J6KOy)0ySrdCgKY(gxwo8qQPxxW0eWXtz4cagis(ciPfTN(TN3XJgaOtREoIZWfamqKeMSiumOD90GID6tWYydrWlhYu7YAmsicyO(WWyhm2FXzQSlgFifgbrrpWyKZuzxmoiQqOQ9h1jrX(PX3admudEGXiNyUg1sshyPdFitTlRXibSOOhymYjMRrTK0ID6WhYu7YAmsaluum2qe8YHm1US(IeWzqk7BCz5WdPMEDbttahpvHv0VbqsRFDmpNHaZrYxhi0BpI05D8OpW4NRWk63aiP1VoMsy1uHq8Vza1feO(OSVXfxHv0VbqsRFDmLWQPcH4DjJUgIGhQbFGXpxHv0VbqsRFDmLci1X)MbuxqefHXpxHv0VbqsRFDmLci1XhYu7YA8zcffHXpxHv0VbqsRFDmLWQPcH42xza5lIGcJFUcROFdGKw)6ykHvtfcXhYu7Y6lIGcJFUcROFdGKw)6ykHvtfcX)MbuxqYGu234YYHhsn96cMMaoEQjgxXEOZziWCK81bc92JiDEhpouCiRa1ZrqFDGqp)Bts(yjCtgJ0bqnyWdmg5mv2fJpKP2L14ZGAWdmg5JcGkmOvghQcoc8Hm1USgFMOOpEGXiFuauHbTY4qvWrGdIkuu0hpWyKZuzxmoiQOOA)rDsuSFA8fraleQbF8aJroqDbpeSKmrX(PXKQxsfnq6GtCqurr1(J6KOy)04lIawiufvYeqmGeMbPSVXLLdpKA61fmnbC8ulyf7HoNHaZrYxhi0BpI05D84qXHScuphb91bc98Vnj5JLWnzmsha1GbpWyKZuzxm(qMAxwJpdQbpWyKpkaQWGwzCOk4iWhYu7YA8zII(4bgJ8rbqfg0kJdvbhboiQqrrF8aJrotLDX4GOIIQ9h1jrX(PXxebSqOg8Xdmg5a1f8qWsYef7NgtQEjv0aPdoXbrffv7pQtII9tJVicyHqvujtaXasygKY(gxwo8qQPxxW0eWXtTp5C6iJoDOZziWCK81bc92JiDEhpouCiRa1ZrqFDGqp)Bts(yjCtgJuGc1GbpWyKZuzxm(qMAxwJpdQbpWyKpkaQWGwzCOk4iWhYu7YA8zII(4bgJ8rbqfg0kJdvbhboiQqrrF8aJrotLDX4GOIIQ9h1jrX(PXxebSqOg8Xdmg5a1f8qWsYef7NgtQEjv0aPdoXbrffv7pQtII9tJVicyHqvujtaXasygKY(gxwo8qQPxxW0eWXtJ4HrsCuw6do05D8OIkzcigqzqk7BCz5WdPMEDbttahpDuauHbTY4qvWr48oE0dmg5mv2fJdIMbPSVXLLdpKA61fmnbC8uG6cEiyPfTN(TN3XJgm4bgJCI5AuljTyNo8Hm1USgJeWIIEGXiNyUg1sshyPdFitTlRXibSqOmm2bJ9xCMk7IXhYu7YAmIawOOidJDWy)fNPYUy8HuyeYGu234YYHhsn96cMMaoEkJCK9B1jvxdPmP6pVJhnyWdmg5a1f8qWsYef7NgtQEjv0aPdoXbrff9HHbqLwphieMwlHIImmaQ065vdrWlJkjkcqNw9CeVTsftIIEGXi3ZHXWoq7ZbrH6bgJCphgd7aTpFitTlRVhaCagc8Hy4cgSFo6qS2ss11qktQEovQNJGfkeQpEGXiNPYUyCquOg8HHbqLwpVAicEzujrrgg7GX(lodxaWarYxajTO90VLdIkk21tdk2PpblJnebVCitTlRVmm2bJ9xCgUaGbIKVasAr7PFlFitTlBabQOyxpnOyN(eSm2qe8YHm1USh(Wifma77bahGHaFigUGb7NJoeRTKuDnKYKQNtL65iyHcZGu234YYHhsn96cMMaoEAxmDk9BCDEhpAWGhymYbQl4HGLKjk2pnMu9sQObshCIdIkk6dddGkTEoqimTwcffzyauP1ZRgIGxgvsueGoT65iEBLkMef9aJrUNdJHDG2NdIc1dmg5Eomg2bAF(qMAxwFreWbyiWhIHlyW(5OdXAljvxdPmP65uPEocwOqO(4bgJCMk7IXbrHAWhggavA98QHi4LrLefzySdg7V4mCbadejFbK0I2t)woiQOyxpnOyN(eSm2qe8YHm1US(YWyhm2FXz4cagis(ciPfTN(T8Hm1USbeOIID90GID6tWYydrWlhYu7YE4dJuWaSVic4ame4dXWfmy)C0HyTLKQRHuMu9CQuphbluygKY(gxwo8qQPxxW0eWXtbOtREo68snPJwfajJ4rYuzxSZbOoq6ObFyySdg7V4mv2fJpKcJGOOpa0PvphXz4cagisctwekguggavA98QHi4LrLeMbPSVXLLdpKA61fmnbC80i4GGehLKdSOZ74rI5AulX7sQfcqvujtaXacQby8Zvyf9BaK06xhtjSAQqi(3mG6cIOOpmmaQ065fXgSdpWcHcqNw9Ce3QaizepsMk7ILbPSVXLLdpKA61fmnbC8u7RJfCGqN3XJmmaQ065vdrWlJkbfGoT65iodxaWarsyYIqXGQ2FuNef7NgJpgyGHYWyhm2FXz4cagis(ciPfTN(T8Hm1US(cHbZnvJCig1odQ9h1jrX(P5WicyHzqk7BCz5WdPMEDbttahpTi)stmUoVJhn4bgJCI5AuljDGLoCqurrdmb6aHShpa6qmb6aHKFBs(EMqrrMaDGq2JisiufvYeqmGGcqNw9Ce3QaizepsMk7ILbPSVXLLdpKA61fmnbC8ubQlknX468oE0GhymYjMRrTK0bw6WbrH6dddGkTEoqimTwIIg8aJroqDbpeSKmrX(PXKQxsfnq6GtCquOmmaQ065aHW0Ajuu0atGoqi7XdGoetGoqi53MKVNjuuKjqhiK9iIef9aJrotLDX4GOcHQOsMaIbeua60QNJ4wfajJ4rYuzxSmiL9nUSC4HutVUGPjGJNgbDoPjgxN3XJg8aJroXCnQLKoWshoikuFyyauP1ZbcHP1su0GhymYbQl4HGLKjk2pnMu9sQObshCIdIcLHbqLwphieMwlHIIgyc0bczpEa0Hyc0bcj)2K89mHIImb6aHShrKOOhymYzQSlgheviufvYeqmGGcqNw9Ce3QaizepsMk7ILbPSVXLLdpKA61fmnbC8u)6mnEK4OKCGfLbPSVXLLdpKA61fmnbC8u7RtSh68oEKyUg1s8UKoWshrrI5AulXTyNoYImYlksmxJAjUwiilYiVOOhymY9RZ04rIJsYbwehefQhymYjMRrTK0bw6Wbrffn4bgJCMk7IXhYu7Y6RY(gxC)J(c4Krig4tYVnjOEGXiNPYUyCquHzqk7BCz5WdPMEDbttahp1)OVGmiL9nUSC4HutVUGPjGJNoGLuzFJlPRT)5LAshJQZ9cgWmOmiL9nUS8O6CVGb8O91XcoqOZ74rFgWII4bcX9uNwmsIJs15KVGUGy5eIfSrrj4miL9nUS8O6CVGbmGJNAbRyp05meyos(6aHE7rKoVJhHXp3eJRypeFitTlRXdzQDzZGu234YYJQZ9cgWaoEQjgxXEOmOmiL9nUSC7FuHv0VbqsRFDmpNHaZrYxhi0BpI05D8OpW4NRWk63aiP1VoMsy1uHq8Vza1feO(OSVXfxHv0VbqsRFDmLWQPcH4DjJUgIGhQbFGXpxHv0VbqsRFDmLci1X)MbuxqefHXpxHv0VbqsRFDmLci1XhYu7YA8zcffHXpxHv0VbqsRFDmLWQPcH42xza5lIGcJFUcROFdGKw)6ykHvtfcXhYu7Y6lIGcJFUcROFdGKw)6ykHvtfcX)MbuxqYGu234YYTFahpLHlayGi5lGKw0E63EEhpAaGoT65iodxaWarsyYIqXG21tdk2PpblJnebVCitTlRXiHiGH6ddJDWy)fNPYUy8Huyeef9aJrotLDX4GOcHQ2FuNef7NgFpdyOg8aJroXCnQLKoWsh(qMAxwJrcyrrpWyKtmxJAjPf70HpKP2L1yKawOOySHi4LdzQDz9fjGZGu234YYTFahpfGoT65OZl1KocJF5qiwWEitQE75auhiD0GhymYzQSlgFitTlRXNb1GhymYhfavyqRmoufCe4dzQDzn(mrrF8aJr(OaOcdALXHQGJahevOOOpEGXiNPYUyCqurr1(J6KOy)04lIawiud(4bgJCG6cEiyjzII9tJjvVKkAG0bN4GOIIQ9h1jrX(PXxebSqOg8aJroXCnQLKwSth(qMAxwJHWG5MQref9aJroXCnQLKoWsh(qMAxwJHWG5MQreMbPSVXLLB)aoEQjgxXEOZziWCK81bc92JiDEhpouCiRa1ZrqFDGqp)Bts(yjCtgJ0bqnOOsMaIbeua60QNJ4W4xoeIfShYKQ3kmdszFJll3(bC8ulyf7HoNHaZrYxhi0BpI05D84qXHScuphb91bc98Vnj5JLWnzmsha1GIkzcigqqbOtREoIdJF5qiwWEitQERWmiL9nUSC7hWXtTp5C6iJoDOZziWCK81bc92JiDEhpouCiRa1ZrqFDGqp)Bts(yjCtgJuGc1GIkzcigqqbOtREoIdJF5qiwWEitQERWmiL9nUSC7hWXtJ4HrsCuw6do05D8OIkzcigqzqk7BCz52pGJNokaQWGwzCOk4iCEhp6bgJCMk7IXbrZGu234YYTFahpLmrX(Pr6Hl4Z74rdg8aJroXCnQLKwSth(qMAxwJrcyrrpWyKtmxJAjPdS0HpKP2L1yKawiugg7GX(lotLDX4dzQDzngrad1GhymYrN2epWT6K6W0QzsuqNvhoa1bs(EqGbwu0NbSOiEGqC0PnXdCRoPomTAMef0z1HtiwWgfLGfkuu0dmg5OtBIh4wDsDyA1mjkOZQdhG6ajJpEaIhyrrgg7GX(lotLDX4dPWia1GA)rDsuSFAm2ObwueGoT65iEBLkMeMbPSVXLLB)aoEkJCK9B1jvxdPmP6pVJhnO2FuNef7NgJnAGHAWdmg5a1f8qWsYef7NgtQEjv0aPdoXbrff9HHbqLwphieMwlHIImmaQ065vdrWlJkjkcqNw9CeVTsftIIEGXi3ZHXWoq7ZbrH6bgJCphgd7aTpFitTlRVhaCagmy0hAalkIhiehDAt8a3QtQdtRMjrbDwD4eIfSrrjyHbyiWhIHlyW(5OdXAljvxdPmP65uPEocwOqHq9Xdmg5mv2fJdIc1GpmmaQ065vdrWlJkjkYWyhm2FXz4cagis(ciPfTN(TCqurXUEAqXo9jyzSHi4LdzQDz9LHXoyS)IZWfamqK8fqslAp9B5dzQDzdiqff76Pbf70NGLXgIGxoKP2L9WhgPGbyFpa4ame4dXWfmy)C0HyTLKQRHuMu9CQuphbluygKY(gxwU9d44PDX0P0VX15D8Ob1(J6KOy)0ySrdmudEGXihOUGhcwsMOy)0ys1lPIgiDWjoiQOOpmmaQ065aHW0AjuuKHbqLwpVAicEzujrra60QNJ4TvQysu0dmg5Eomg2bAFoikupWyK75WyyhO95dzQDz9frahGbdg9HgWII4bcXrN2epWT6K6W0QzsuqNvhoHybBuucwyagc8Hy4cgSFo6qS2ss11qktQEovQNJGfkuiuF8aJrotLDX4GOqn4dddGkTEE1qe8YOsIImm2bJ9xCgUaGbIKVasAr7PFlhevuSRNguStFcwgBicE5qMAxwFzySdg7V4mCbadejFbK0I2t)w(qMAx2acurXUEAqXo9jyzSHi4LdzQDzp8Hrkya2xebCagc8Hy4cgSFo6qS2ss11qktQEovQNJGfkmdszFJll3(bC8ua60QNJoVut6OvbqYiEKmv2f7CaQdKoAWhgg7GX(lotLDX4dPWiik6daDA1ZrCgUaGbIKWKfHIbLHbqLwpVAicEzujHzqk7BCz52pGJNgbheK4OKCGfDEhpsmxJAjExsTqaQIkzcigqq9aJro60M4bUvNuhMwntIc6S6WbOoqY3dcmWqnaJFUcROFdGKw)6ykHvtfcX)Mbuxqef9HHbqLwpVi2GD4bwiua60QNJ4wfajJ4rYuzxSmiL9nUSC7hWXtTVor15oVJh9aJroUOxGvIsdJq)gxCquOEGXi3(6evNJpuCiRa1Zrzqk7BCz52pGJNY0IroPhymEEPM0r7RJdpWN3XJEGXi3(64WdmFitTlRVNb1GhymYjMRrTK0ID6WhYu7YA8zIIEGXiNyUg1sshyPdFitTlRXNjeQA)rDsuSFAm2ObodszFJll3(bC8u7RJfCGqN3XJmmaQ065vdrWlJkbfGoT65iodxaWarsyYIqXGYWyhm2FXz4cagis(ciPfTN(T8Hm1US(cHbZnvJCig1odQ9h1jrX(P5WicyHzqk7BCz52pGJNAFDIQZDEhp(QJQNBFY50rcpD85uPEocgQpV6O652xhhEG5uPEocgQhymYTVor154dfhYkq9CeudEGXiNyUg1sshyPdFitTlRXbkuI5AulX7s6alDG6bgJC0PnXdCRoPomTAMef0z1HdqDGKVhCgWIIEGXihDAt8a3QtQdtRMjrbDwD4auhiz8XdodyOQ9h1jrX(PXyJgyrry8Zvyf9BaK06xhtjSAQqi(qMAxwJdgrrL9nU4kSI(nasA9RJPewnvieVlz01qe8cH6ddJDWy)fNPYUy8HuyeYGu234YYTFahp1(6ybhi05D8OhymYXf9cSsMJ0rcOTnU4GOIIEGXihOUGhcwsMOy)0ys1lPIgiDWjoiQOOhymYzQSlghefQbpWyKpkaQWGwzCOk4iWhYu7Y6legm3unYHyu7mO2FuNef7NMdJiGfc1dmg5JcGkmOvghQcocCqurrF8aJr(OaOcdALXHQGJahefQpmm2bJ9x8rbqfg0kJdvbhb(qkmcII(WWaOsRNdGQxacJqrr1(J6KOy)0ySrdmuI5AulX7sQfczqk7BCz52pGJNAFDSGde68oE8vhvp3(64WdmNk1ZrWqn4bgJC7RJdpWCqurr1(J6KOy)0ySrdSqOEGXi3(64Wdm3(kdiFreudEGXiNyUg1ssl2Pdhevu0dmg5eZ1Ows6alD4GOcH6bgJC0PnXdCRoPomTAMef0z1HdqDGKVhG4bgQbgg7GX(lotLDX4dzQDzngjGff9bGoT65iodxaWarsyYIqXGYWaOsRNxnebVmQKWmiL9nUSC7hWXtTVowWbcDEhpAWdmg5OtBIh4wDsDyA1mjkOZQdhG6ajFpaXdSOOhymYrN2epWT6K6W0QzsuqNvhoa1bs(EWzad9vhvp3(KZPJeE64ZPs9CeSqOEGXiNyUg1ssl2PdFitTlRXiEOeZ1OwI3L0ID6a1hpWyKJl6fyLO0Wi0VXfhefQpV6O652xhhEG5uPEocgkdJDWy)fNPYUy8Hm1USgJ4HAGHXoyS)IduxWdblTO90VLpKP2L1yeVOOpmmaQ065aHW0AjmdszFJll3(bC80I8lnX468oE0GhymYjMRrTK0bw6WbrffnWeOdeYE8aOdXeOdes(Tj57zcffzc0bczpIiHqvujtaXackaDA1ZrCRcGKr8izQSlwgKY(gxwU9d44PcuxuAIX15D8ObpWyKtmxJAjPdS0HdIc1hggavA9CGqyATefn4bgJCG6cEiyjzII9tJjvVKkAG0bN4GOqzyauP1ZbcHP1sOOObMaDGq2JhaDiMaDGqYVnjFptOOitGoqi7rejk6bgJCMk7IXbrfcvrLmbediOa0PvphXTkasgXJKPYUyzqk7BCz52pGJNgbDoPjgxN3XJg8aJroXCnQLKoWshoikuFyyauP1ZbcHP1su0GhymYbQl4HGLKjk2pnMu9sQObshCIdIcLHbqLwphieMwlHIIgyc0bczpEa0Hyc0bcj)2K89mHIImb6aHShrKOOhymYzQSlgheviufvYeqmGGcqNw9Ce3QaizepsMk7ILbPSVXLLB)aoEQFDMgpsCusoWIYGu234YYTFahp1(6e7HoVJhjMRrTeVlPdS0ruKyUg1sCl2PJSiJ8IIeZ1OwIRfcYImYlk6bgJC)6mnEK4OKCGfXbrH6bgJCI5AuljDGLoCqurrdEGXiNPYUy8Hm1US(QSVXf3)OVaozeIb(K8BtcQhymYzQSlghevygKY(gxwU9d44P(h9fKbPSVXLLB)aoE6awsL9nUKU2(NxQjDmQo3lyaV)9Vxa]] )


end