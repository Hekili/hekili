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


    spec:RegisterPack( "Balance", 20201206, [[dCuTsdqiQkEePKKlPcQnbkFsGcnksXPiuRsfKxjaZcO4wGeAxO6xQinmGQJbQSmvGNbsAAcOUgqPTrkP(girnoqcoNasRJusmpQkDpvO9rk1bfOOwiPepuaXejLKIlskjL(OafPtskjvRuGmtbkTtvedvGIyPcuqpvqtfuLVkqb2Rk9xIgSshMYIPkpgLjdXLr2SqFgeJMqoTuVwf1SPYTjv7wYVHA4q64Gez5kEojtxvxhW2bY3PQA8GQ68GuRxGQ5tW(f9fUl8UHi2t3toa8dahUdaxR5hahupa8aFdFOrPBiQXoBqOByz60nulMZkgDdrnODyd5cVBOcdmm6gk6FuLw50tH0ViapodRFQQ1bC234Inw8pv16StVHEaT71QxxVBiI909Kda)aWH7aW1A(bWDqGgy4UHgWlcp3WWwpqUHIAeeQUE3qesXUHAv5QfZzfJYvRMbOrYG0QYvRgIr6E0KRwdMCpa8dapdkdsRk3arKvqiLwjdsRkxOyUbZiiesUHyNn5QfY05zqAv5cfZnqezfecj33gi0l7yUmtrQCFCUmOzos(2aHEfpdsRkxOyUbdjDmicjxGQigPu2aDUGSPnphPYvtZjoyYfDiqs1BJcyGq5cf1ox0HaXvVnkGbcjMNbPvLlum3Gzq4gjx0HyM67csUbdg7fLBhZT)GrvUVikx)dUGKRwTmxJQi(n01QxDH3n0dB)fE3tG7cVBivMNJqUA5gYM(PPTBOhqmYzMSlgha9gASVX1nCmquHbuY4qvWH((3to4cVBivMNJqUA5gIrVHk6VHg7BCDdbztBEo6gcYCa0nm6W4jxn5Qj3UEAqXo7jezSHi6LdPBDPYfkM7bGNR4Cpnx4oa8CfNR25gDy8KRMC1KBxpnOyN9eIm2qe9YH0TUu5cfZ9aWMlumxn5ch45EOCFZr1Z7IztzFJlovMNJqYvCUqXC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfN7P5chua8CfFdbzJSmD6gYWfi8zsIqkOl29VNa1l8UHuzEoc5QLBig9gQO)gASVX1neKnT55OBiiZbq3qFY1dig5EMZkgjXrP5CYxuxquYYEGH4aO5clxFY1dig5EMZkgjXrP5CYxuxqusBywrCa0BiiBKLPt3q20FHFa07FpjWx4DdPY8CeYvl3qJ9nUUHgIH(nisQ8BJ(nKn9ttB3qpGyK7zoRyKehLMZjFrDbrjl7bgIREJDwcYCauU(MBGbpxy56beJCpZzfJK4O0Co5lQlikPnmRiU6n2zjiZbq56BUbg8CHLRMC9jxe8Zned9BqKu53gDjIPBqi(3SZDbjxy56tUg7BCXned9BqKu53gDjIPBqiExYORHi6ZfwUAY1NCrWp3qm0VbrsLFB0LIiZX)MDUli5kiKlc(5gIH(nisQ8BJUuezo(q6wxQC1oxOMR4CfeYfb)CdXq)gejv(TrxIy6geIREJDoxFZfQ5clxe8Zned9BqKu53gDjIPBqi(q6wxQC9nxWMlSCrWp3qm0VbrsLFB0LiMUbH4FZo3fKCfFdzqZCK8Tbc9Q7jWD)7jG9cVBivMNJqUA5gYM(PPTBOMCbztBEoIZWfi8zsIqkOlwUWYTRNguSZEcrgBiIE5q6wxQC1ox4Gk45clxFYLHXoeS)IZmzxm(qgc05kiKRhqmYzMSlghanxX5clxn56beJCpZzfJK4O0Co5lQlikzzpWqC1BSZsqMdGY9yUGf8CfeY1dig5EMZkgjXrP5CYxuxqusBywrC1BSZsqMdGY9yUGf8CfNRGqUXgIOxoKU1LkxFZfoWVHg7BCDdz4ce(mjFrKuH2t)Q7FprRVW7gsL55iKRwUHSPFAA7gQjxpGyK7zoRyKehLMZjFrDbrjl7bgIpKU1LkxTZnWCWMRGqUEaXi3ZCwXijoknNt(I6cIsAdZkIpKU1LkxTZnWCWMR4CHLRP(XCsuSFAYv7J5gOGNlSC1KldJDiy)fNzYUy8H0TUu5QDUq5CfeYvtUmm2HG9xCshf7NgPhUq4dPBDPYv7CHY5clxFY1dig5N7cziejPJI9tJovVKkAG0bN4aO5clxggevw98ZqpTv5koxX3qJ9nUUHmRyKt6beJ3qpGyuwMoDdvVno8GC)7jq5l8UHuzEoc5QLBiB6NM2UH(KliBAZZrC20FHFa0CHLRMCzyquz1ZRgIOxgnkxbHCzySdb7V4mt2fJpKU1LkxTZfkNRGqUAYLHXoeS)It6Oy)0i9WfcFiDRlvUANluoxy56tUEaXi)CxidHijDuSFA0P6LurdKo4ehanxy5YWGOYQNFg6PTkxX5k(gASVX1nu92Oagi09VNafUW7gsL55iKRwUHSPFAA7gQjxgg7qW(lodxGWNj5lIKk0E6xXbqZfwUAYfKnT55iodxGWNjjcPGUy5kiKldJDiy)fNzYUy8H0TUu56BUGnxX5koxy5AQFmNef7NMC1oxWcEUWYLHbrLvpVAiIEz0OBOX(gx3q1BJcyGq3)EsGEH3nKkZZrixTCdn2346gQaQyp0nKn9ttB3WHIdPezEokxy5(2aHE(36K8XsKMYv7CHtRZfwUAY1qLmre7CUWYvtUGSPnphXzt)f(bqZvqixn5AQFmNef7NMC9nxOcEUWY1NC9aIroZKDX4aO5koxbHCzySdb7V4mt2fJpKHaDUIZv8nKbnZrY3gi0RUNa39VNah4x4DdPY8CeYvl3qJ9nUUH6yCf7HUHSPFAA7gouCiLiZZr5cl33gi0Z)wNKpwI0uUANlCqLd2CHLRMCnujteXoNlSC1KliBAZZrC20FHFa0CfeYvtUM6hZjrX(PjxFZfQGNlSC9jxpGyKZmzxmoaAUIZvqixgg7qW(loZKDX4dziqNR4CHLRp56beJ8ZDHmeIK0rX(PrNQxsfnq6GtCa0CfFdzqZCK8Tbc9Q7jWD)7jWb3fE3qQmphHC1Yn0yFJRBO6jNZgz0zdDdzt)002nCO4qkrMNJYfwUVnqON)TojFSePPC1ox406Cdi3H0TUu5clxn5AOsMiIDoxy5Qjxq20MNJ4SP)c)aO5kiKRP(XCsuSFAY13CHk45kiKldJDiy)fNzYUy8HmeOZvCUIVHmOzos(2aHE19e4U)9e4o4cVBivMNJqUA5gYM(PPTBOHkzIi25BOX(gx3WiEyKehLL9adD)7jWb1l8UHuzEoc5QLBiB6NM2UHAYLyUgvr8UKwbDUcc5smxJQiUc7Sr2LeUCfeYLyUgvrChqzJSljC5koxy5QjxFYLHbrLvpVAiIEz0OCfeYvtUM6hZjrX(PjxFZnqbBUWYvtUGSPnphXzt)f(bqZvqixt9J5KOy)0KRV5cvWZvqixq20MNJ4TsAykxX5clxn5cYM28CeNHlq4ZKeHuqxSCHLRp5YWyhc2FXz4ce(mjFrKuH2t)koaAUcc56tUGSPnphXz4ce(mjrif0flxy56tUmm2HG9xCMj7IXbqZvCUIZvCUWYvtUmm2HG9xCMj7IXhs36sLR25cvWZvqixt9J5KOy)0KR25gOGNlSCzySdb7V4mt2fJdGMlSC1KldJDiy)fN0rX(Pr6Hle(q6wxQC9nxJ9nU4Q3MypeNGpXaEs(ToLRGqU(KlddIkRE(zON2QCfNRGqUD90GID2tiYydr0lhs36sLRV5ch45koxy5Qjxe8Zned9BqKu53gDjIPBqi(q6wxQC1o3aNRGqU(KlddIkREErSb7WdsUIVHg7BCDdJad0sCusoGIU)9e4c8fE3qQmphHC1YnKn9ttB3qn5smxJQiUdOSrwe8)CfeYLyUgvrCf2zJSi4)5kiKlXCnQI4wbTSi4)5kiKRhqmY9mNvmsIJsZ5KVOUGOKL9adXhs36sLR25gyoyZvqixpGyK7zoRyKehLMZjFrDbrjTHzfXhs36sLR25gyoyZvqixt9J5KOy)0KR25gOGNlSCzySdb7V4mt2fJpKHaDUIZfwUAYLHXoeS)IZmzxm(q6wxQC1oxOcEUcc5YWyhc2FXzMSlgFidb6CfNRGqUD90GID2tiYydr0lhs36sLRV5ch43qJ9nUUHN7cziePcTN(v3)EcCG9cVBivMNJqUA5gYM(PPTBOMCn1pMtII9ttUANBGcEUWYvtUEaXi)CxidHijDuSFA0P6LurdKo4ehanxbHC9jxggevw98ZqpTv5koxbHCzyquz1ZRgIOxgnkxbHC9aIrUNdJrCaQNdGMlSC9aIrUNdJrCaQNpKU1LkxFZ9aWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfNlSC1KRp5YWGOYQNxnerVmAuUcc5YWyhc2FXz4ce(mjFrKuH2t)koaAUcc521tdk2zpHiJnerVCiDRlvU(MldJDiy)fNHlq4ZK8frsfAp9R4dPBDPYnGC16CfeYTRNguSZEcrgBiIE5q6wxQCpCUWbfapxFZ9aWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfFdn2346gYihP(2CsZ1qkDQ(7FpboT(cVBivMNJqUA5gYM(PPTBOMCn1pMtII9ttUANBGcEUWYvtUEaXi)CxidHijDuSFA0P6LurdKo4ehanxbHC9jxggevw98ZqpTv5koxbHCzyquz1ZRgIOxgnkxbHC9aIrUNdJrCaQNdGMlSC9aIrUNdJrCaQNpKU1LkxFZfQGNBa5Qj3aN7HYLHleG(5OdXAfjnxdP0P65uzEocjxX5koxy5QjxFYLHbrLvpVAiIEz0OCfeYLHXoeS)IZWfi8zs(IiPcTN(vCa0CfeYfKnT55iodxGWNjjcPGUy5cl3UEAqXo7jezSHi6LdPBDPYv7CHdkaEUbK7bGNBa5Qj3aN7HYLHleG(5OdXAfjnxdP0P65uzEocjxX5kiKBxpnOyN9eIm2qe9YH0TUu56BUmm2HG9xCgUaHptYxejvO90VIpKU1Lk3aYvRZvqi3UEAqXo7jezSHi6LdPBDPY13CHk45gqUAYnW5EOCz4cbOFo6qSwrsZ1qkDQEovMNJqYvCUIVHg7BCDd7IztzFJR7FpboO8fE3qQmphHC1YnKn9ttB3qggevw98QHi6LrJYfwUAYfKnT55iodxGWNjjcPGUy5kiKldJDiy)fNzYUy8H0TUu56BUWbEUIZfwUM6hZjrX(PjxTZfSGNlSCzySdb7V4mCbcFMKVisQq7PFfFiDRlvU(MlCGFdn2346gQEBuade6(3tGdkCH3nKkZZrixTCdXO3qf93qJ9nUUHGSPnphDdbzoa6gsmxJQiExshqztUhkxOqUNMRX(gxC1BtShItWNyapj)wNYnGC9jxI5AufX7s6akBY9q5Q15EAUg7BCX9p2lItWNyapj)wNYnGCbNFqUNMRcLCoPit90neKnYY0PBOPqdMqtiXU)9e4c0l8UHuzEoc5QLBiB6NM2UHAYTRNguSZEcrgBiIE5q6wxQC9n3aNRGqUAY1dig5JbIkmGsghQco08H0TUu56BUqyiCDd(5EOCzu7YvtUM6hZjrX(Pj3tZfQGNR4CHLRhqmYhdevyaLmoufCO5aO5koxX5kiKRMCn1pMtII9ttUbKliBAZZrCtHgmHMqIL7HY1dig5eZ1OksQWoB4dPBDPYnGCrWppcmqlXrj5akI)n7SsoKU1vUhk3d4GnxTZfUdapxbHCn1pMtII9ttUbKliBAZZrCtHgmHMqIL7HY1dig5eZ1Oks6akB4dPBDPYnGCrWppcmqlXrj5akI)n7SsoKU1vUhk3d4GnxTZfUdapxX5clxI5AufX7sAf05clxn5QjxFYLHXoeS)IZmzxmoaAUcc5YWGOYQNFg6PTkxy56tUmm2HG9xCshf7NgPhUq4aO5koxbHCzyquz1ZRgIOxgnkxX5clxn56tUmmiQS65GO6fb9KRGqU(KRhqmYzMSlghanxbHCn1pMtII9ttUANBGcEUIZvqixpGyKZmzxm(q6wxQC1oxOqUWY1NC9aIr(yGOcdOKXHQGdnha9gASVX1nu92Oagi09VNCa4x4DdPY8CeYvl3q20pnTDd1KRhqmYjMRrvK0bu2WbqZvqixn5YezdesL7XCpixy5oetKnqi536uU(MlyZvCUcc5YezdesL7XCHAUIZfwUgQKjIyNVHg7BCDdlYVuhJR7Fp5a4UW7gsL55iKRwUHSPFAA7gQjxpGyKtmxJQiPdOSHdGMRGqUAYLjYgiKk3J5EqUWYDiMiBGqYV1PC9nxWMR4CfeYLjYgiKk3J5c1CfNlSCnujteXoFdn2346gkYCrPogx3)EYbhCH3nKkZZrixTCdzt)002nutUEaXiNyUgvrshqzdhanxbHC1KltKnqivUhZ9GCHL7qmr2aHKFRt56BUGnxX5kiKltKnqivUhZfQ5koxy5AOsMiID(gASVX1nmc4CsDmUU)9KdG6fE3qJ9nUUH(TzA8iXrj5ak6gsL55iKRwU)9Kdc8fE3qQmphHC1YnKn9ttB3qI5AufX7s6akBYvqixI5AufXvyNnYIG)NRGqUeZ1OkIBf0YIG)NRGqUEaXi3VntJhjokjhqrCa0CHLlXCnQI4DjDaLn5kiKRMC9aIroZKDX4dPBDPY13Cn234I7FSxeNGpXaEs(ToLlSC9aIroZKDX4aO5k(gASVX1nu92e7HU)9Kda7fE3qJ9nUUH(h7fDdPY8CeYvl3)EYbA9fE3qQmphHC1Yn0yFJRB4ausJ9nUKUw93qxREzz60nmAo3lAaU)9VHiu0aC)fE3tG7cVBOX(gx3qf2zJ0Jm9BivMNJqUA5(3to4cVBivMNJqUA5gIrVHk6VHg7BCDdbztBEo6gcYCa0nuHsoN8Tbc9kU6TjAoxUANlC5clxn56tUV5O65Q3ghEq4uzEocjxbHCFZr1Zvp5C2irMo(CQmphHKR4CfeYvHsoN8Tbc9kU6TjAoxUAN7b3qq2iltNUHTsAy6(3tG6fE3qQmphHC1YneJEdv0Fdn2346gcYM28C0neK5aOBOcLCo5Bde6vC1BtShkxTZfUBiiBKLPt3WwjzoYar3)EsGVW7gsL55iKRwUHSPFAA7gQjxFYLHbrLvpVAiIEz0OCfeY1NCzySdb7V4mCbcFMKVisQq7PFfhanxX5clxpGyKZmzxmoa6n0yFJRBOhnkAo3fK7FpbSx4DdPY8CeYvl3q20pnTDd9aIroZKDX4aO3qJ9nUUHO4VX19VNO1x4Ddn2346gcOiz)KU6gsL55iKRwU)9eO8fE3qQmphHC1YnKn9ttB3qhbIC56BUGfUBOX(gx3qrKnVKukQy09VNafUW7gsL55iKRwUHSPFAA7gcYM28CeVvsdt3q1pn7VNa3n0yFJRB4ausJ9nUKUw93qxREzz60n0W09VNeOx4DdPY8CeYvl3q20pnTDdhGII4bcX)wN8JNsImKP71fcnCckb0OOeYnu9tZ(7jWDdn2346goaL0yFJlPRv)n01QxwMoDdrgY096cHM7FpboWVW7gsL55iKRwUHSPFAA7goaffXdeI7zoRyKehLMZjFrDbrXjOeqJIsi3q1pn7VNa3n0yFJRB4ausJ9nUKUw93qxREzz60n0dB)9VNahCx4DdPY8CeYvl3qJ9nUUHdqjn234s6A1FdDT6LLPt3q1F)7FdrhIH19S)cV7jWDH3n0yFJRBOogxN7sgXJ(nKkZZrixTC)7jhCH3n0yFJRB45UqgcrQq7PF1nKkZZrixTC)7jq9cVBivMNJqUA5gASVX1n0)yVOBiB6NM2UHAYLyUgvrChqzJSi4)5kiKlXCnQI4DjDaLn5kiKlXCnQI4Dj9WVOCfeYLyUgvrCRGwwe8)CfFdDDrsgYneoWV)9KaFH3nKkZZrixTCdzt)002nutUeZ1OkI7akBKfb)pxbHCjMRrveVlPdOSjxbHCjMRrveVlPh(fLRGqUeZ1OkIBf0YIG)NR4CHLl6qG4WX9p2lkxy56tUOdbIFa3)yVOBOX(gx3q)J9IU)9eWEH3n0yFJRBO6Tj2dDdPY8CeYvl3)EIwFH3nKkZZrixTCdXO3qf93qJ9nUUHGSPnphDdbzoa6g6HvQCHLB0HXtUAYvtUXgIOxoKU1LkxOyUhaEUIZ90CH7aWZvCUANB0HXtUAYvtUXgIOxoKU1LkxOyUha2CHI5Qjx4ap3dL7BoQEExmBk7BCXPY8CesUIZfkMRMCdCUhkxgUqa6NJoeRvK0CnKsNQNtL55iKCfNR4Cpnx4GcGNR4BiiBKLPt3qgUaHptsesbDXU)9VHgMUW7EcCx4DdPY8CeYvl3qm6nur)n0yFJRBiiBAZZr3qqMdGUHAY1dig5FRt(XtjrgY096cHg(q6wxQC9nximeUUb)CdixW5WLRGqUEaXi)BDYpEkjYqMUxxi0Whs36sLRV5ASVXfx92e7H4e8jgWtYV1PCdixW5WLlSC1KlXCnQI4DjDaLn5kiKlXCnQI4kSZgzrW)ZvqixI5AufXTcAzrW)ZvCUIZfwUEaXi)BDYpEkjYqMUxxi0WbqZfwUdqrr8aH4FRt(XtjrgY096cHgobLaAuuc5gcYgzz60nezitx6VDoz0CojogV)9KdUW7gsL55iKRwUHSPFAA7g6beJC1Bt0Co(qXHuImphLlSC1KRcLCo5Bde6vC1Bt0CUC9nxOMRGqU(K7auuepqi(36KF8usKHmDVUqOHtqjGgfLqYvCUWYvtU(K7auuepqiUdAMnMsgDe9DbrcX16OkItqjGgfLqYvqi3V1PCpCUbgS5QDUEaXix92enNJpKU1Lk3aY9GCfFdn2346gQEBIMZD)7jq9cVBivMNJqUA5gYM(PPTB4auuepqi(36KF8usKHmDVUqOHtqjGgfLqYfwUkuY5KVnqOxXvVnrZ5Yv7J5c1CHLRMC9jxpGyK)To5hpLezit3RleA4aO5clxpGyKREBIMZXhkoKsK55OCfeYvtUGSPnphXrgY0L(BNtgnNtIJXCHLRMC9aIrU6TjAohFiDRlvU(MluZvqixfk5CY3gi0R4Q3MO5C5QDUhKlSCFZr1Zvp5C2irMo(CQmphHKlSC9aIrU6TjAohFiDRlvU(MlyZvCUIZv8n0yFJRBO6TjAo39VNe4l8UHuzEoc5QLBig9gQO)gASVX1neKnT55OBiiZbq3qt9J5KOy)0KR25cfapxOyUAYfoWZ9q56beJ8V1j)4PKidz6EDHqdx9g7CUIZfkMRMC9aIrU6TjAohFiDRlvUhkxOM7P5QqjNtkYupLR4CHI5Qjxe8ZJad0sCusoGI4dPBDPY9q5c2CfNlSC9aIrU6TjAohha9gcYgzz60nu92enNt6hxVmAoNehJ3)EcyVW7gsL55iKRwUHSPFAA7gcYM28Cehzitx6VDoz0CojogZfwUGSPnphXvVnrZ5K(X1lJMZjXX4n0yFJRBO6TrbmqO7FprRVW7gsL55iKRwUHg7BCDdvavSh6gYM(PPTB4qXHuImphLlSCFBGqp)BDs(yjst5QDUWf4CHI5QqjNt(2aHEvUbK7q6wxQCHLRHkzIi25CHLlXCnQI4DjTc6BidAMJKVnqOxDpbU7FpbkFH3nKkZZrixTCdn2346gAig63GiPYVn63q20pnTDd9j3VzN7csUWY1NCn234IBig63GiPYVn6set3Gq8UKrxdr0NRGqUi4NBig63GiPYVn6set3GqC1BSZ56BUqnxy5IGFUHyOFdIKk)2OlrmDdcXhs36sLRV5c1BidAMJKVnqOxDpbU7FpbkCH3nKkZZrixTCdn2346gQJXvSh6gYM(PPTB4qXHuImphLlSCFBGqp)BDs(yjst5QDUAYfUaNBa5Qjxfk5CY3gi0R4Q3MypuUhkx44GnxX5ko3tZvHsoN8Tbc9QCdi3H0TUu5clxn5YWyhc2FXzMSlgFidb6CHLRMCbztBEoIZWfi8zsIqkOlwUcc5YWyhc2FXz4ce(mjFrKuH2t)k(qgc05kiKRp5YWGOYQNxnerVmAuUIZvqixfk5CY3gi0R4Q3MypuU(MRMCdCUhkxn5cxUbK7BoQE(7VlPogxkovMNJqYvCUIZvqixn5smxJQiExsf2ztUcc5QjxI5AufX7s6HFr5kiKlXCnQI4DjDaLn5koxy56tUV5O65kmGtIJYxejJ4HupNkZZri5kiKRhqmYrNwhpiT5K2WSQzsuaNYgoiZbq5Q9XCpaSGNR4CHLRMCvOKZjFBGqVIREBI9q56BUWbEUhkxn5cxUbK7BoQE(7VlPogxkovMNJqYvCUIZfwUM6hZjrX(PjxTZfSGNlumxpGyKREBIMZXhs36sL7HYvRZvCUWYvtU(KRhqmYp3fYqisshf7NgDQEjv0aPdoXbqZvqixI5AufX7sQWoBYvqixFYLHbrLvp)m0tBvUIZfwUgQKjIyNVHmOzos(2aHE19e4U)9Ka9cVBivMNJqUA5gYM(PPTBOMCbztBEoIZWfi8zsIqkOlwUWYTRNguSZEcrgBiIE5q6wxQC1ox4Gk45clxFYLHXoeS)IZmzxm(qgc05kiKRhqmYzMSlghanxX5clxt9J5KOy)0KRV5cwWZfwUAY1dig5eZ1Oks6akB4dPBDPYv7C16CfeY1dig5eZ1OksQWoB4dPBDPYv7CdCUIZvqi3ydr0lhs36sLRV5ch43qJ9nUUHmCbcFMKVisQq7PF19VNah4x4DdPY8CeYvl3q20pnTDdnujteXoFdn2346ggXdJK4OSShyO7Fpbo4UW7gsL55iKRwUHSPFAA7g6beJCMj7IXbqVHg7BCDdhdevyaLmoufCOV)9e4o4cVBivMNJqUA5gYM(PPTBOMC9aIrU6TjAohhanxbHCn1pMtII9ttUANlybpxX5clxFY1dig5kSt9nJ4aO5clxFY1dig5mt2fJdGMlSC1KRp5YWGOYQNxnerVmAuUcc5YWyhc2FXz4ce(mjFrKuH2t)koaAUcc521tdk2zpHiJnerVCiDRlvU(MldJDiy)fNHlq4ZK8frsfAp9R4dPBDPYnGC16CfeYTRNguSZEcrgBiIE5q6wxQCpCUWbfapxFZ9aWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfFdn2346gYihP(2CsZ1qkDQ(7FpboOEH3nKkZZrixTCdzt)002nutUEaXix92enNJdGMRGqUM6hZjrX(PjxTZfSGNR4CHLRp56beJCf2P(MrCa0CHLRp56beJCMj7IXbqZfwUAY1NCzyquz1ZRgIOxgnkxbHCzySdb7V4mCbcFMKVisQq7PFfhanxbHC76Pbf7SNqKXgIOxoKU1LkxFZLHXoeS)IZWfi8zs(IiPcTN(v8H0TUu5gqUADUcc521tdk2zpHiJnerVCiDRlvUhox4GcGNRV5cvWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfFdn2346g2fZMY(gx3)EcCb(cVBivMNJqUA5gYM(PPTByxpnOyN9eIm2qe9YH0TUu56BUWb2CfeYvtUEaXihDAD8G0MtAdZQMjrbCkB4GmhaLRV5EaybpxbHC9aIro6064bPnN0gMvntIc4u2WbzoakxTpM7bGf8CfNlSC9aIrU6TjAohhanxy5YWyhc2FXzMSlgFiDRlvUANlyb)gASVX1nK0rX(Pr6HlK7FpboWEH3nKkZZrixTCdn2346gQEY5SrgD2q3q20pnTDdhkoKsK55OCHL736K8XsKMYv7CHdS5clxfk5CY3gi0R4Q3MypuU(MBGZfwUgQKjIyNZfwUAY1dig5mt2fJpKU1LkxTZfoWZvqixFY1dig5mt2fJdGMR4BidAMJKVnqOxDpbU7FpboT(cVBivMNJqUA5gYM(PPTBiXCnQI4DjTc6CHLRHkzIi25CHLRhqmYrNwhpiT5K2WSQzsuaNYgoiZbq56BUhawWZfwUAYfb)CdXq)gejv(TrxIy6geI)n7CxqYvqixFYLHbrLvpVi2GD4bjxbHCvOKZjFBGqVkxTZ9GCfFdn2346ggbgOL4OKCafD)7jWbLVW7gsL55iKRwUHSPFAA7g6beJCCrViLeLggH(nU4aO5clxn56beJC1Bt0Co(qXHuImphLRGqUM6hZjrX(PjxTZnqbpxX3qJ9nUUHQ3MO5C3)EcCqHl8UHuzEoc5QLBiB6NM2UHmmiQS65vdr0lJgLlSC1KliBAZZrCgUaHptsesbDXYvqixgg7qW(loZKDX4aO5kiKRhqmYzMSlghanxX5clxgg7qW(lodxGWNj5lIKk0E6xXhs36sLRV5cHHW1n4N7HYLrTlxn5AQFmNef7NMCpnxWcEUIZfwUEaXix92enNJpKU1LkxFZnW3qJ9nUUHQ3MO5C3)EcCb6fE3qQmphHC1YnKn9ttB3qggevw98QHi6LrJYfwUAYfKnT55iodxGWNjjcPGUy5kiKldJDiy)fNzYUyCa0CfeY1dig5mt2fJdGMR4CHLldJDiy)fNHlq4ZK8frsfAp9R4dPBDPY13CHWq46g8Z9q5YO2LRMCn1pMtII9ttUNMlubpxX5clxpGyKREBIMZXbqZfwUeZ1OkI3L0kOVHg7BCDdvVnkGbcD)7jha(fE3qQmphHC1YnKn9ttB3qpGyKJl6fPKmhzJeuRACXbqZvqixn56tUQ3Mype3qLmre7CUcc5QjxpGyKZmzxm(q6wxQC9nxWMlSC9aIroZKDX4aO5kiKRMC9aIr(yGOcdOKXHQGdnFiDRlvU(Mlegcx3GFUhkxg1UC1KRP(XCsuSFAY90CHk45koxy56beJ8XarfgqjJdvbhAoaAUIZvCUWYfKnT55iU6TjAoN0pUEz0CojogZfwUkuY5KVnqOxXvVnrZ5Y13CHAUIZfwUAY1NChGII4bcX)wN8JNsImKP71fcnCckb0OOesUcc5QqjNt(2aHEfx92enNlxFZfQ5k(gASVX1nu92Oagi09VNCaCx4DdPY8CeYvl3q20pnTDd1KlXCnQI4DjTc6CHLldJDiy)fNzYUy8H0TUu5QDUGf8CfeYvtUmr2aHu5Em3dYfwUdXezdes(ToLRV5c2CfNRGqUmr2aHu5EmxOMR4CHLRHkzIi25BOX(gx3WI8l1X46(3to4Gl8UHuzEoc5QLBiB6NM2UHAYLyUgvr8UKwbDUWYLHXoeS)IZmzxm(q6wxQC1oxWcEUcc5QjxMiBGqQCpM7b5cl3HyISbcj)wNY13CbBUIZvqixMiBGqQCpMluZvCUWY1qLmre78n0yFJRBOiZfL6yCD)7jha1l8UHuzEoc5QLBiB6NM2UHAYLyUgvr8UKwbDUWYLHXoeS)IZmzxm(q6wxQC1oxWcEUcc5QjxMiBGqQCpM7b5cl3HyISbcj)wNY13CbBUIZvqixMiBGqQCpMluZvCUWY1qLmre78n0yFJRByeW5K6yCD)7jhe4l8UHg7BCDd9BZ04rIJsYbu0nKkZZrixTC)7jha2l8UHuzEoc5QLBig9gQO)gASVX1neKnT55OBiiZbq3qfk5CY3gi0R4Q3MypuUANBGZnGCJomEYvtU6M6PbAjiZbq5EAUhaEUIZnGCJomEYvtUEaXix92OagiKK0rX(PrNQxQWoB4Q3yNZ90CdCUIVHGSrwMoDdvVnXEizxsf2zZ9VNCGwFH3nKkZZrixTCdzt)002nKyUgvrChqzJSi4)5kiKlXCnQI4wbTSi4)5clxq20MNJ4TsYCKbIYvqixpGyKtmxJQiPc7SHpKU1LkxFZ1yFJlU6Tj2dXj4tmGNKFRt5clxpGyKtmxJQiPc7SHdGMRGqUeZ1OkI3LuHD2KlSC9jxq20MNJ4Q3MypKSlPc7SjxbHC9aIroZKDX4dPBDPY13Cn234IREBI9qCc(ed4j536uUWY1NCbztBEoI3kjZrgikxy56beJCMj7IXhs36sLRV5sWNyapj)wNYfwUEaXiNzYUyCa0CfeY1dig5JbIkmGsghQco0Ca0CHLRcLCoPit9uUANl4CToxy5Qjxfk5CY3gi0RY13J5c1CfeY1NCFZr1ZvyaNehLVisgXdPEovMNJqYvCUcc56tUGSPnphXBLK5ideLlSC9aIroZKDX4dPBDPYv7Cj4tmGNKFRt3qJ9nUUH(h7fD)7jhaLVW7gASVX1nu92e7HUHuzEoc5QL7Fp5aOWfE3qQmphHC1Yn0yFJRB4ausJ9nUKUw93qxREzz60nmAo3lAaU)9VHrZ5ErdWfE3tG7cVBivMNJqUA5gYM(PPTBOp5oaffXdeI7zoRyKehLMZjFrDbrXjOeqJIsi3qJ9nUUHQ3gfWaHU)9KdUW7gsL55iKRwUHg7BCDdvavSh6gYM(PPTBic(56yCf7H4dPBDPYv7Chs36sDdzqZCK8Tbc9Q7jWD)7jq9cVBOX(gx3qDmUI9q3qQmphHC1Y9V)nu9x4DpbUl8UHuzEoc5QLBOX(gx3qdXq)gejv(Tr)gYM(PPTBOp5IGFUHyOFdIKk)2OlrmDdcX)MDUli5clxFY1yFJlUHyOFdIKk)2OlrmDdcX7sgDnerFUWYvtU(Klc(5gIH(nisQ8BJUuezo(3SZDbjxbHCrWp3qm0VbrsLFB0LIiZXhs36sLR25c2CfNRGqUi4NBig63GiPYVn6set3GqC1BSZ56BUqnxy5IGFUHyOFdIKk)2OlrmDdcXhs36sLRV5c1CHLlc(5gIH(nisQ8BJUeX0nie)B25UGCdzqZCK8Tbc9Q7jWD)7jhCH3nKkZZrixTCdzt)002nutUGSPnphXz4ce(mjrif0flxy521tdk2zpHiJnerVCiDRlvUANlCqf8CHLRp5YWyhc2FXzMSlgFidb6CfeY1dig5mt2fJdGMR4CHLRP(XCsuSFAY13Cbl45clxn56beJCI5AufjDaLn8H0TUu5QDUWbEUcc56beJCI5AufjvyNn8H0TUu5QDUWbEUIZvqi3ydr0lhs36sLRV5ch43qJ9nUUHmCbcFMKVisQq7PF19VNa1l8UHuzEoc5QLBig9gQO)gASVX1neKnT55OBiiZbq3qn56beJCMj7IXhs36sLR25c2CHLRMC9aIr(yGOcdOKXHQGdnFiDRlvUANlyZvqixFY1dig5JbIkmGsghQco0Ca0CfNRGqU(KRhqmYzMSlghanxbHCn1pMtII9ttU(MlubpxX5clxn56tUEaXi)CxidHijDuSFA0P6LurdKo4ehanxbHCn1pMtII9ttU(MlubpxX5clxn56beJCI5AufjvyNn8H0TUu5QDUqyiCDd(5kiKRhqmYjMRrvK0bu2Whs36sLR25cHHW1n4NR4BiiBKLPt3qe8lhckb0dPt1RU)9KaFH3nKkZZrixTCdn2346gQJXvSh6gYM(PPTB4qXHuImphLlSCFBGqp)BDs(yjst5QDUWDqUWYvtUgQKjIyNZfwUGSPnphXrWVCiOeqpKovVkxX3qg0mhjFBGqV6EcC3)EcyVW7gsL55iKRwUHg7BCDdvavSh6gYM(PPTB4qXHuImphLlSCFBGqp)BDs(yjst5QDUWDqUWYvtUgQKjIyNZfwUGSPnphXrWVCiOeqpKovVkxX3qg0mhjFBGqV6EcC3)EIwFH3nKkZZrixTCdn2346gQEY5SrgD2q3q20pnTDdhkoKsK55OCHL7Bde65FRtYhlrAkxTZfoToxy5QjxdvYerSZ5clxq20MNJ4i4xoeucOhsNQxLR4BidAMJKVnqOxDpbU7FpbkFH3nKkZZrixTCdzt)002n0qLmre78n0yFJRByepmsIJYYEGHU)9eOWfE3qQmphHC1YnKn9ttB3qpGyKZmzxmoa6n0yFJRB4yGOcdOKXHQGd99VNeOx4DdPY8CeYvl3q20pnTDd1KRMC9aIroXCnQIKkSZg(q6wxQC1ox4apxbHC9aIroXCnQIKoGYg(q6wxQC1ox4apxX5clxgg7qW(loZKDX4dPBDPYv7CHk45clxn56beJC0P1XdsBoPnmRAMefWPSHdYCauU(M7bbg8CfeY1NChGII4bcXrNwhpiT5K2WSQzsuaNYgobLaAuucjxX5koxbHC9aIro6064bPnN0gMvntIc4u2WbzoakxTpM7bqzWZvqixgg7qW(loZKDX4dziqNlSC1KRP(XCsuSFAYv7CduWZvqixq20MNJ4TsAykxX3qJ9nUUHKok2pnspCHC)7jWb(fE3qQmphHC1YnKn9ttB3qn5AQFmNef7NMC1o3af8CHLRMC9aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoaAUcc56tUmmiQS65NHEARYvCUcc5YWGOYQNxnerVmAuUcc5cYM28CeVvsdt5kiKRhqmY9CymIdq9Ca0CHLRhqmY9CymIdq98H0TUu56BUhaEUbKRMC1KBGM7HYDakkIhiehDAD8G0MtAdZQMjrbCkB4eucOrrjKCfNBa5Qj3aN7HYLHleG(5OdXAfjnxdP0P65uzEocjxX5koxX5clxFY1dig5mt2fJdGMlSC1KRp5YWGOYQNxnerVmAuUcc5YWyhc2FXz4ce(mjFrKuH2t)koaAUcc521tdk2zpHiJnerVCiDRlvU(MldJDiy)fNHlq4ZK8frsfAp9R4dPBDPYnGC16CfeYTRNguSZEcrgBiIE5q6wxQCpCUWbfapxFZ9aWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfFdn2346gYihP(2CsZ1qkDQ(7Fpbo4UW7gsL55iKRwUHSPFAA7gQjxt9J5KOy)0KR25gOGNlSC1KRhqmYp3fYqisshf7NgDQEjv0aPdoXbqZvqixFYLHbrLvp)m0tBvUIZvqixggevw98QHi6LrJYvqixq20MNJ4TsAykxbHC9aIrUNdJrCaQNdGMlSC9aIrUNdJrCaQNpKU1LkxFZfQGNBa5Qjxn5gO5EOChGII4bcXrNwhpiT5K2WSQzsuaNYgobLaAuucjxX5gqUAYnW5EOCz4cbOFo6qSwrsZ1qkDQEovMNJqYvCUIZvCUWY1NC9aIroZKDX4aO5clxn56tUmmiQS65vdr0lJgLRGqUmm2HG9xCgUaHptYxejvO90VIdGMRGqUD90GID2tiYydr0lhs36sLRV5YWyhc2FXz4ce(mjFrKuH2t)k(q6wxQCdixToxbHC76Pbf7SNqKXgIOxoKU1Lk3dNlCqbWZ13CHk45gqUAYnW5EOCz4cbOFo6qSwrsZ1qkDQEovMNJqYvCUIVHg7BCDd7IztzFJR7FpbUdUW7gsL55iKRwUHy0BOI(BOX(gx3qq20MNJUHGmhaDd1KRp5YWyhc2FXzMSlgFidb6CfeY1NCbztBEoIZWfi8zsIqkOlwUWYLHbrLvpVAiIEz0OCfFdbzJSmD6gQmqKmIhjZKDXU)9e4G6fE3qQmphHC1YnKn9ttB3qI5AufX7sAf05clxdvYerSZ5clxpGyKJoToEqAZjTHzvZKOaoLnCqMdGY13CpiWGNlSC1Klc(5gIH(nisQ8BJUeX0nie)B25UGKRGqU(KlddIkREErSb7WdsUIZfwUGSPnphXvgisgXJKzYUy3qJ9nUUHrGbAjokjhqr3)EcCb(cVBivMNJqUA5gYM(PPTBOhqmYXf9IusuAye634IdGMlSC9aIrU6TjAohFO4qkrMNJUHg7BCDdvVnrZ5U)9e4a7fE3qQmphHC1YnKn9ttB3qpGyKREBC4bHpKU1LkxFZfS5clxn56beJCI5AufjvyNn8H0TUu5QDUGnxbHC9aIroXCnQIKoGYg(q6wxQC1oxWMR4CHLRP(XCsuSFAYv7CduWVHg7BCDdzwXiN0digVHEaXOSmD6gQEBC4b5(3tGtRVW7gsL55iKRwUHSPFAA7gYWGOYQNxnerVmAuUWYfKnT55iodxGWNjjcPGUy5clxgg7qW(lodxGWNj5lIKk0E6xXhs36sLRV5cHHW1n4N7HYLrTlxn5AQFmNef7NMCpnxOcEUIVHg7BCDdvVnkGbcD)7jWbLVW7gsL55iKRwUHSPFAA7g(MJQNREY5SrImD85uzEocjxy5QO)7cIIRWoSez64NlSC9j33Cu9C1BJdpiCQmphHKlSC9aIrU6TjAohFO4qkrMNJYfwUAY1dig5eZ1Oks6akB4dPBDPYv7C16CHLlXCnQI4DjDaLn5clxpGyKJoToEqAZjTHzvZKOaoLnCqMdGY13CpaSGNRGqUEaXihDAD8G0MtAdZQMjrbCkB4GmhaLR2hZ9aWcEUWY1u)yojk2pn5QDUbk45kiKlc(5gIH(nisQ8BJUeX0nieFiDRlvUANluixbHCn234IBig63GiPYVn6set3Gq8UKrxdr0NR4CHLRp5YWyhc2FXzMSlgFidb6BOX(gx3q1Bt0CU7FpboOWfE3qQmphHC1YnKn9ttB3qpGyKJl6fPKmhzJeuRACXbqZvqixpGyKFUlKHqKKok2pn6u9sQObshCIdGMRGqUEaXiNzYUyCa0CHLRMC9aIr(yGOcdOKXHQGdnFiDRlvU(Mlegcx3GFUhkxg1UC1KRP(XCsuSFAY90CHk45koxy56beJ8XarfgqjJdvbhAoaAUcc56tUEaXiFmquHbuY4qvWHMdGMlSC9jxgg7qW(l(yGOcdOKXHQGdnFidb6CfeY1NCzyquz1Zbr1lc6jxX5kiKRP(XCsuSFAYv7CduWZfwUeZ1OkI3L0kOVHg7BCDdvVnkGbcD)7jWfOx4DdPY8CeYvl3q20pnTDdFZr1ZvVno8GWPY8CesUWYvtUEaXix924WdchanxbHCn1pMtII9ttUANBGcEUIZfwUEaXix924Wdcx9g7CU(MluZfwUAY1dig5eZ1OksQWoB4aO5kiKRhqmYjMRrvK0bu2WbqZvCUWY1dig5OtRJhK2CsByw1mjkGtzdhK5aOC9n3dGYGNlSC1KldJDiy)fNzYUy8H0TUu5QDUWbEUcc56tUGSPnphXz4ce(mjrif0flxy5YWGOYQNxnerVmAuUIVHg7BCDdvVnkGbcD)7jha(fE3qQmphHC1YnKn9ttB3qn56beJC0P1XdsBoPnmRAMefWPSHdYCauU(M7bqzWZvqixpGyKJoToEqAZjTHzvZKOaoLnCqMdGY13CpaSGNlSCFZr1Zvp5C2irMo(CQmphHKR4CHLRhqmYjMRrvKuHD2Whs36sLR25cLZfwUeZ1OkI3LuHD2KlSC9jxpGyKJl6fPKO0Wi0VXfhanxy56tUV5O65Q3ghEq4uzEocjxy5YWyhc2FXzMSlgFiDRlvUANluoxy5Qjxgg7qW(l(5UqgcrQq7PFfFiDRlvUANluoxbHC9jxggevw98ZqpTv5k(gASVX1nu92Oagi09VNCaCx4DdPY8CeYvl3q20pnTDd1KRhqmYjMRrvK0bu2WbqZvqixn5YezdesL7XCpixy5oetKnqi536uU(MlyZvCUcc5YezdesL7XCHAUIZfwUgQKjIyNZfwUGSPnphXvgisgXJKzYUy3qJ9nUUHf5xQJX19VNCWbx4DdPY8CeYvl3q20pnTDd1KRhqmYjMRrvK0bu2WbqZfwU(KlddIkRE(zON2QCfeYvtUEaXi)CxidHijDuSFA0P6LurdKo4ehanxy5YWGOYQNFg6PTkxX5kiKRMCzISbcPY9yUhKlSChIjYgiK8BDkxFZfS5koxbHCzISbcPY9yUqnxbHC9aIroZKDX4aO5koxy5AOsMiIDoxy5cYM28CexzGizepsMj7IDdn2346gkYCrPogx3)EYbq9cVBivMNJqUA5gYM(PPTBOMC9aIroXCnQIKoGYgoaAUWY1NCzyquz1Zpd90wLRGqUAY1dig5N7cziejPJI9tJovVKkAG0bN4aO5clxggevw98ZqpTv5koxbHC1KltKnqivUhZ9GCHL7qmr2aHKFRt56BUGnxX5kiKltKnqivUhZfQ5kiKRhqmYzMSlghanxX5clxdvYerSZ5clxq20MNJ4kdejJ4rYmzxSBOX(gx3WiGZj1X46(3toiWx4Ddn2346g63MPXJehLKdOOBivMNJqUA5(3toaSx4DdPY8CeYvl3q20pnTDdjMRrveVlPdOSjxbHCjMRrvexHD2ilc(FUcc5smxJQiUvqllc(FUcc56beJC)2mnEK4OKCafXbqZfwUEaXiNyUgvrshqzdhanxbHC1KRhqmYzMSlgFiDRlvU(MRX(gxC)J9I4e8jgWtYV1PCHLRhqmYzMSlghanxX3qJ9nUUHQ3Myp09VNCGwFH3n0yFJRBO)XEr3qQmphHC1Y9VNCau(cVBivMNJqUA5gASVX1nCakPX(gxsxR(BORvVSmD6ggnN7fna3)(3qKHmDVUqO5cV7jWDH3nKkZZrixTCdXO3qf93qJ9nUUHGSPnphDdbzoa6gQjxpGyK)To5hpLezit3RleA4dPBDPYv7CHWq46g8ZnGCbNdxUWYvtUeZ1OkI3L0d)IYvqixI5AufX7sQWoBYvqixI5AufXDaLnYIG)NR4CfeY1dig5FRt(XtjrgY096cHg(q6wxQC1oxJ9nU4Q3MypeNGpXaEs(ToLBa5cohUCHLRMCjMRrveVlPdOSjxbHCjMRrvexHD2ilc(FUcc5smxJQiUvqllc(FUIZvCUcc56tUEaXi)BDYpEkjYqMUxxi0WbqVHGSrwMoDdvwKKpwcOiPcLCU7Fp5Gl8UHuzEoc5QLBiB6NM2UHAY1NCbztBEoIRSijFSeqrsfk5C5kiKRMC9aIr(yGOcdOKXHQGdnFiDRlvU(Mlegcx3GFUhkxg1UC1KRP(XCsuSFAY90CHk45koxy56beJ8XarfgqjJdvbhAoaAUIZvCUcc5AQFmNef7NMC1o3af8BOX(gx3q1BJcyGq3)EcuVW7gsL55iKRwUHSPFAA7gQjxq20MNJ4mCbcFMKiKc6ILlSC76Pbf7SNqKXgIOxoKU1LkxTZfoOcEUWY1NCzySdb7V4mt2fJpKHaDUcc56beJCMj7IXbqZvCUWY1u)yojk2pn56BUbg8CHLRMC9aIroXCnQIKoGYg(q6wxQC1ox4apxbHC9aIroXCnQIKkSZg(q6wxQC1ox4apxX5kiKBSHi6LdPBDPY13CHd8BOX(gx3qgUaHptYxejvO90V6(3tc8fE3qQmphHC1Yn0yFJRBOHyOFdIKk)2OFdzt)002n0NCrWp3qm0VbrsLFB0LiMUbH4FZo3fKCHLRp5ASVXf3qm0VbrsLFB0LiMUbH4DjJUgIOpxy5QjxFYfb)CdXq)gejv(TrxkImh)B25UGKRGqUi4NBig63GiPYVn6srK54dPBDPYv7CbBUIZvqixe8Zned9BqKu53gDjIPBqiU6n25C9nxOMlSCrWp3qm0VbrsLFB0LiMUbH4dPBDPY13CHAUWYfb)CdXq)gejv(TrxIy6geI)n7CxqUHmOzos(2aHE19e4U)9eWEH3nKkZZrixTCdn2346gQJXvSh6gYM(PPTB4qXHuImphLlSCFBGqp)BDs(yjst5QDUWDqUWYvtUAY1dig5mt2fJpKU1LkxTZfS5clxn56beJ8XarfgqjJdvbhA(q6wxQC1oxWMRGqU(KRhqmYhdevyaLmoufCO5aO5koxbHC9jxpGyKZmzxmoaAUcc5AQFmNef7NMC9nxOcEUIZfwUAY1NC9aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoaAUcc5AQFmNef7NMC9nxOcEUIZfwUgQKjIyNZv8nKbnZrY3gi0RUNa39VNO1x4DdPY8CeYvl3qJ9nUUHkGk2dDdzt)002nCO4qkrMNJYfwUVnqON)TojFSePPC1ox4oixy5Qjxn56beJCMj7IXhs36sLR25c2CHLRMC9aIr(yGOcdOKXHQGdnFiDRlvUANlyZvqixFY1dig5JbIkmGsghQco0Ca0CfNRGqU(KRhqmYzMSlghanxbHCn1pMtII9ttU(MlubpxX5clxn56tUEaXi)CxidHijDuSFA0P6LurdKo4ehanxbHCn1pMtII9ttU(MlubpxX5clxdvYerSZ5k(gYGM5i5Bde6v3tG7(3tGYx4DdPY8CeYvl3qJ9nUUHQNCoBKrNn0nKn9ttB3WHIdPezEokxy5(2aHE(36K8XsKMYv7CHtRZfwUAYvtUEaXiNzYUy8H0TUu5QDUGnxy5QjxpGyKpgiQWakzCOk4qZhs36sLR25c2CfeY1NC9aIr(yGOcdOKXHQGdnhanxX5kiKRp56beJCMj7IXbqZvqixt9J5KOy)0KRV5cvWZvCUWYvtU(KRhqmYp3fYqisshf7NgDQEjv0aPdoXbqZvqixt9J5KOy)0KRV5cvWZvCUWY1qLmre7CUIVHmOzos(2aHE19e4U)9eOWfE3qQmphHC1YnKn9ttB3qdvYerSZ3qJ9nUUHr8Wijokl7bg6(3tc0l8UHuzEoc5QLBiB6NM2UHEaXiNzYUyCa0BOX(gx3WXarfgqjJdvbh67FpboWVW7gsL55iKRwUHSPFAA7gQjxn56beJCI5AufjvyNn8H0TUu5QDUWbEUcc56beJCI5AufjDaLn8H0TUu5QDUWbEUIZfwUmm2HG9xCMj7IXhs36sLR25cvWZvCUcc5YWyhc2FXzMSlgFidb6BOX(gx3WZDHmeIuH2t)Q7Fpbo4UW7gsL55iKRwUHSPFAA7gQjxn56beJ8ZDHmeIK0rX(PrNQxsfnq6GtCa0CfeY1NCzyquz1Zpd90wLR4CfeYLHbrLvpVAiIEz0OCfeYfKnT55iERKgMYvqixpGyK75WyehG65aO5clxpGyK75WyehG65dPBDPY13Cpa8Cdixn5g4CpuUmCHa0phDiwRiP5AiLovpNkZZri5koxX5clxFY1dig5mt2fJdGMlSC1KRp5YWGOYQNxnerVmAuUcc5YWyhc2FXz4ce(mjFrKuH2t)koaAUcc521tdk2zpHiJnerVCiDRlvU(MldJDiy)fNHlq4ZK8frsfAp9R4dPBDPYnGC16CfeYTRNguSZEcrgBiIE5q6wxQCpCUWbfapxFZ9aWZnGC1KBGZ9q5YWfcq)C0HyTIKMRHu6u9CQmphHKR4CfFdn2346gYihP(2CsZ1qkDQ(7FpbUdUW7gsL55iKRwUHSPFAA7gQjxn56beJ8ZDHmeIK0rX(PrNQxsfnq6GtCa0CfeY1NCzyquz1Zpd90wLR4CfeYLHbrLvpVAiIEz0OCfeYfKnT55iERKgMYvqixpGyK75WyehG65aO5clxpGyK75WyehG65dPBDPY13CHk45gqUAYnW5EOCz4cbOFo6qSwrsZ1qkDQEovMNJqYvCUIZfwU(KRhqmYzMSlghanxy5QjxFYLHbrLvpVAiIEz0OCfeYLHXoeS)IZWfi8zs(IiPcTN(vCa0CfeYTRNguSZEcrgBiIE5q6wxQC9nxgg7qW(lodxGWNj5lIKk0E6xXhs36sLBa5Q15kiKBxpnOyN9eIm2qe9YH0TUu5E4CHdkaEU(Mlubp3aYvtUbo3dLldxia9ZrhI1ksAUgsPt1ZPY8CesUIZv8n0yFJRByxmBk7BCD)7jWb1l8UHuzEoc5QLBig9gQO)gASVX1neKnT55OBiiZbq3qn56tUmm2HG9xCMj7IXhYqGoxbHC9jxq20MNJ4mCbcFMKiKc6ILlSCzyquz1ZRgIOxgnkxX3qq2iltNUHkdejJ4rYmzxS7FpbUaFH3nKkZZrixTCdzt)002nKyUgvr8UKwbDUWY1qLmre7CUWYvtUi4NBig63GiPYVn6set3Gq8VzN7csUcc56tUmmiQS65fXgSdpi5koxy5cYM28CexzGizepsMj7IDdn2346ggbgOL4OKCafD)7jWb2l8UHuzEoc5QLBiB6NM2UHmmiQS65vdr0lJgLlSCbztBEoIZWfi8zsIqkOlwUWY1u)yojk2pn5Q9XCdm45clxgg7qW(lodxGWNj5lIKk0E6xXhs36sLRV5cHHW1n4N7HYLrTlxn5AQFmNef7NMCpnxOcEUIVHg7BCDdvVnkGbcD)7jWP1x4DdPY8CeYvl3q20pnTDd1KRhqmYjMRrvK0bu2WbqZvqixn5YezdesL7XCpixy5oetKnqi536uU(MlyZvCUcc5YezdesL7XCHAUIZfwUgQKjIyNZfwUGSPnphXvgisgXJKzYUy3qJ9nUUHf5xQJX19VNahu(cVBivMNJqUA5gYM(PPTBOMC9aIroXCnQIKoGYgoaAUWY1NCzyquz1Zpd90wLRGqUAY1dig5N7cziejPJI9tJovVKkAG0bN4aO5clxggevw98ZqpTv5koxbHC1KltKnqivUhZ9GCHL7qmr2aHKFRt56BUGnxX5kiKltKnqivUhZfQ5kiKRhqmYzMSlghanxX5clxdvYerSZ5clxq20MNJ4kdejJ4rYmzxSBOX(gx3qrMlk1X46(3tGdkCH3nKkZZrixTCdzt)002nutUEaXiNyUgvrshqzdhanxy56tUmmiQS65NHEARYvqixn56beJ8ZDHmeIK0rX(PrNQxsfnq6GtCa0CHLlddIkRE(zON2QCfNRGqUAYLjYgiKk3J5EqUWYDiMiBGqYV1PC9nxWMR4CfeYLjYgiKk3J5c1CfeY1dig5mt2fJdGMR4CHLRHkzIi25CHLliBAZZrCLbIKr8izMSl2n0yFJRByeW5K6yCD)7jWfOx4Ddn2346g63MPXJehLKdOOBivMNJqUA5(3toa8l8UHuzEoc5QLBiB6NM2UHeZ1OkI3L0bu2KRGqUeZ1OkIRWoBKfb)pxbHCjMRrve3kOLfb)pxbHC9aIrUFBMgpsCusoGI4aO5clxpGyKtmxJQiPdOSHdGMRGqUAY1dig5mt2fJpKU1LkxFZ1yFJlU)XErCc(ed4j536uUWY1dig5mt2fJdGMR4BOX(gx3q1BtSh6(3toaUl8UHg7BCDd9p2l6gsL55iKRwU)9Kdo4cVBivMNJqUA5gASVX1nCakPX(gxsxR(BORvVSmD6ggnN7fna3)(3)gcIgvJR7jha(bGd3bGd3n0Vnvxqu3WGbbZbdprR(jbt1k5Ml8er526O45ZnINCdgrgY096cHMGXChckb0dHKRcRt5Aapw3EcjxMiRGqkEguW2fL7bALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRg4GVyEguW2fLlCWPvYnqWfiAEcj3WwpqYvbD9g8Z9Who3hNBWcy5QJraCaQCXO0ypEYvZHfNRg4GVyEguW2fLlChOvYnqWfiAEcj3WwpqYvbD9g8Z9Who3hNBWcy5QJraCaQCXO0ypEYvZHfNRg4GVyEguW2fLlCGvRKBGGlq08esUHTEGKRc66n4N7HZ9X5gSawUinOw14kxmkn2JNC1CQ4C1ah8fZZGYGcgemhm8eT6NemvRKBUWteLBRJINp3iEYnyeDigw3Z(GXChckb0dHKRcRt5Aapw3EcjxMiRGqkEguW2fLRwRvYnqWfiAEcj3WwpqYvbD9g8Z9W5(4CdwalxKguRACLlgLg7XtUAovCUAoa(I5zqzqbdcMdgEIw9tcMQvYnx4jIYT1rXZNBep5gmAykym3HGsa9qi5QW6uUgWJ1TNqYLjYkiKINbfSDr5EGwj3abxGO5jKCdB9ajxf01BWp3dF4CFCUblGLRogbWbOYfJsJ94jxnhwCUAGd(I5zqbBxuUbwRKBGGlq08esUHTEGKRc66n4N7HZ9X5gSawUinOw14kxmkn2JNC1CQ4C1ah8fZZGc2UOCHcALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRg4GVyEguW2fLlChOvYnqWfiAEcj3WwpqYvbD9g8Z9Who3hNBWcy5QJraCaQCXO0ypEYvZHfNRg4GVyEguW2fLlCqvRKBGGlq08esUHTEGKRc66n4N7HpCUpo3GfWYvhJa4au5IrPXE8KRMdloxnWbFX8mOGTlkx4GcALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRg4GVyEguW2fLlCbQwj3abxGO5jKCdB9ajxf01BWp3dN7JZnybSCrAqTQXvUyuAShp5Q5uX5Qbo4lMNbfSDr5Ea4ALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRg4GVyEguW2fL7bGvRKBGGlq08esUHTEGKRc66n4N7HZ9X5gSawUinOw14kxmkn2JNC1CQ4C1Ca8fZZGYGcgemhm8eT6NemvRKBUWteLBRJINp3iEYnyu9bJ5oeucOhcjxfwNY1aESU9esUmrwbHu8mOGTlkx4axRKBGGlq08esUHTEGKRc66n4N7HpCUpo3GfWYvhJa4au5IrPXE8KRMdloxnWbFX8mOGTlkx4GtRKBGGlq08esUHTEGKRc66n4N7HpCUpo3GfWYvhJa4au5IrPXE8KRMdloxnWbFX8mOGTlkx40ATsUbcUarZti5g26bsUkOR3GFUho3hNBWcy5I0GAvJRCXO0ypEYvZPIZvdCWxmpdky7IYfoOGwj3abxGO5jKCdB9ajxf01BWp3dN7JZnybSCrAqTQXvUyuAShp5Q5uX5Qbo4lMNbLbfmiyoy4jA1pjyQwj3CHNik3whfpFUr8KBWOh2(GXChckb0dHKRcRt5Aapw3EcjxMiRGqkEguW2fL7bALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRMdGVyEguW2fLlCGvRKBGGlq08esUHTEGKRc66n4N7HpCUpo3GfWYvhJa4au5IrPXE8KRMdloxnWbFX8mOGTlkx4GcALCdeCbIMNqYnS1dKCvqxVb)CpCUpo3GfWYfPb1Qgx5IrPXE8KRMtfNRgOcFX8mOGTlkx4cuTsUbcUarZti5g26bsUkOR3GFUho3hNBWcy5I0GAvJRCXO0ypEYvZPIZvdCWxmpdkdsRUokEEcjxOCUg7BCLRRvVINbDdrhCSD0nuRkxTyoRyuUA1mansgKwvUA1qms3JMC1AWK7bGFa4zqzqAv5giISccP0kzqAv5cfZnygbHqYne7SjxTqMopdsRkxOyUbIiRGqi5(2aHEzhZLzksL7JZLbnZrY3gi0R4zqAv5cfZnyiPJbri5cufXiLYgOZfKnT55ivUAAoXbtUOdbsQEBuadekxOO25IoeiU6TrbmqiX8miTQCHI5gmdc3i5IoeZuFxqYnyWyVOC7yU9hmQY9fr56FWfKC1QL5AufXZGYGm234sXrhIH19S)OogxN7sgXJEgKX(gxko6qmSUN9bC80ZDHmeIuH2t)QmiJ9nUuC0HyyDp7d44P(h7fbgxxKKHCeoWbthpQHyUgvrChqzJSi4)cceZ1OkI3L0bu2iiqmxJQiExsp8lsqGyUgvrCRGwwe8FXzqg7BCP4OdXW6E2hWXt9p2lcmD8OgI5AufXDaLnYIG)liqmxJQiExshqzJGaXCnQI4Dj9WVibbI5AufXTcAzrW)fddDiqC44(h7fbZh0HaXpG7FSxugKX(gxko6qmSUN9bC8u1BtShkdYyFJlfhDigw3Z(aoEkiBAZZrGPmD6idxGWNjjcPGUyGbK5aOJEyLcw0HXJgnXgIOxoKU1LckEa4IpmChaUyTJomE0Oj2qe9YH0TUuqXdaluudCGFO3Cu98Uy2u234ItL55ieXqrnb(qmCHa0phDiwRiP5AiLovpNkZZriIfFy4GcGlodkdsRkxTAHpXaEcjxcenqN736uUVikxJ94j3wLRbYAN55iEgKX(gxQJkSZgPhz6zqg7BCPc44PGSPnphbMY0PJTsAycmGmhaDuHsoN8Tbc9kU6TjAoN2WbtJpV5O65Q3ghEq4uzEocrq4nhvpx9KZzJez64ZPY8CeIybbfk5CY3gi0R4Q3MO5CAFqgKX(gxQaoEkiBAZZrGPmD6yRKmhzGiWaYCa0rfk5CY3gi0R4Q3MypK2WLbzSVXLkGJN6rJIMZDbbmD8OgFyyquz1ZRgIOxgnsqWhgg7qW(lodxGWNj5lIKk0E6xXbqfdZdig5mt2fJdGMbzSVXLkGJNII)gxGPJh9aIroZKDX4aOzqg7BCPc44Paks2pPRYGm234sfWXtfr28ssPOIrGPJhDeiY5lyHldYyFJlvahpDakPX(gxsxREWuMoD0Weyu)0S)iCGPJhbztBEoI3kPHPmiJ9nUubC80bOKg7BCjDT6btz60rKHmDVUqObmQFA2FeoW0XJdqrr8aH4FRt(XtjrgY096cHgobLaAuucjdYyFJlvahpDakPX(gxsxREWuMoD0dBpyu)0S)iCGPJhhGII4bcX9mNvmsIJsZ5KVOUGO4eucOrrjKmiJ9nUubC80bOKg7BCjDT6btz60r1NbLbzSVXLIBy6iiBAZZrGPmD6iYqMU0F7CYO5CsCmcgqMdGoQXdig5FRt(XtjrgY096cHg(q6wxkFHWq46g8daCoCccEaXi)BDYpEkjYqMUxxi0Whs36s5RX(gxC1BtShItWNyapj)wNcaCoCW0qmxJQiExshqzJGaXCnQI4kSZgzrW)feiMRrve3kOLfb)xSyyEaXi)BDYpEkjYqMUxxi0WbqHnaffXdeI)To5hpLezit3RleA4eucOrrjKmiJ9nUuCdtbC8u1Bt0CoW0XJEaXix92enNJpuCiLiZZrW0OqjNt(2aHEfx92enNZxOki4Zauuepqi(36KF8usKHmDVUqOHtqjGgfLqedtJpdqrr8aH4oOz2ykz0r03fejexRJQiobLaAuucrq4BD6WhoWGvBpGyKREBIMZXhs36sfWbIZGm234sXnmfWXtvVnrZ5athpoaffXdeI)To5hpLezit3RleA4eucOrrjeykuY5KVnqOxXvVnrZ50(iuHPXhpGyK)To5hpLezit3RleA4aOW8aIrU6TjAohFO4qkrMNJee0aYM28Cehzitx6VDoz0CojogHPXdig5Q3MO5C8H0TUu(cvbbfk5CY3gi0R4Q3MO5CAFaS3Cu9C1toNnsKPJpNkZZriW8aIrU6TjAohFiDRlLVGvSyXzqg7BCP4gMc44PGSPnphbMY0PJQ3MO5Cs)46LrZ5K4yemGmhaD0u)yojk2pnAdfahkQboWpKhqmY)wN8JNsImKP71fcnC1BSZIHIA8aIrU6TjAohFiDRl1HG6HvOKZjfzQNedf1GGFEeyGwIJsYbueFiDRl1HaRyyEaXix92enNJdGMbzSVXLIBykGJNQEBuadecmD8iiBAZZrCKHmDP)25KrZ5K4yegiBAZZrC1Bt0CoPFC9YO5CsCmMbzSVXLIBykGJNQaQypeyyqZCK8Tbc9QJWbMoECO4qkrMNJG92aHE(36K8XsKM0gUadfvOKZjFBGqVkGH0TUuWmujteXodJyUgvr8UKwbDgKX(gxkUHPaoEQHyOFdIKk)2Odgg0mhjFBGqV6iCGPJh95B25UGaZhJ9nU4gIH(nisQ8BJUeX0nieVlz01qe9cci4NBig63GiPYVn6set3GqC1BSZ(cvyi4NBig63GiPYVn6set3Gq8H0TUu(c1miJ9nUuCdtbC8uDmUI9qGHbnZrY3gi0Rochy64XHIdPezEoc2Bde65FRtYhlrAsBnWf4a0OqjNt(2aHEfx92e7HoeCCWkw8HvOKZjFBGqVkGH0TUuW0WWyhc2FXzMSlgFidbAyAaztBEoIZWfi8zsIqkOlMGadJDiy)fNHlq4ZK8frsfAp9R4dziqli4dddIkREE1qe9YOrIfeuOKZjFBGqVIREBI9q(QjWhsdCb8MJQN)(7sQJXLItL55ieXIfe0qmxJQiExsf2zJGGgI5AufX7s6HFrcceZ1OkI3L0bu2igMpV5O65kmGtIJYxejJ4HupNkZZriccEaXihDAD8G0MtAdZQMjrbCkB4GmhaP9Xdal4IHPrHsoN8Tbc9kU6Tj2d5lCGFinWfWBoQE(7VlPogxkovMNJqelgMP(XCsuSFA0gSGdf9aIrU6TjAohFiDRl1H0AXW04JhqmYp3fYqisshf7NgDQEjv0aPdoXbqfeiMRrveVlPc7SrqWhggevw98ZqpTvIHzOsMiIDodYyFJlf3WuahpLHlq4ZK8frsfAp9RathpQbKnT55iodxGWNjjcPGUyW66Pbf7SNqKXgIOxoKU1LsB4Gk4W8HHXoeS)IZmzxm(qgc0ccEaXiNzYUyCauXWm1pMtII9tJVGfCyA8aIroXCnQIKoGYg(q6wxkT1AbbpGyKtmxJQiPc7SHpKU1Ls7alwqi2qe9YH0TUu(ch4zqg7BCP4gMc44Pr8Wijokl7bgcmD8OHkzIi25miJ9nUuCdtbC80XarfgqjJdvbhAW0XJEaXiNzYUyCa0miJ9nUuCdtbC8ug5i13MtAUgsPt1dMoEuJhqmYvVnrZ54aOccM6hZjrX(PrBWcUyy(4beJCf2P(MrCauy(4beJCMj7IXbqHPXhggevw98QHi6LrJeeyySdb7V4mCbcFMKVisQq7PFfhavqORNguSZEcrgBiIE5q6wxkFzySdb7V4mCbcFMKVisQq7PFfFiDRlvaATGqxpnOyN9eIm2qe9YH0TUuh(WWbfa33dapanb(qmCHa0phDiwRiP5AiLovpNkZZriIfNbzSVXLIBykGJN2fZMY(gxGPJh14beJC1Bt0CooaQGGP(XCsuSFA0gSGlgMpEaXixHDQVzehafMpEaXiNzYUyCauyA8HHbrLvpVAiIEz0ibbgg7qW(lodxGWNj5lIKk0E6xXbqfe66Pbf7SNqKXgIOxoKU1LYxgg7qW(lodxGWNj5lIKk0E6xXhs36sfGwli01tdk2zpHiJnerVCiDRl1HpmCqbW9fQGhGMaFigUqa6NJoeRvK0CnKsNQNtL55ieXIZGm234sXnmfWXtjDuSFAKE4cbmD8yxpnOyN9eIm2qe9YH0TUu(chyfe04beJC0P1XdsBoPnmRAMefWPSHdYCaKVhawWfe8aIro6064bPnN0gMvntIc4u2Wbzoas7JhawWfdZdig5Q3MO5CCauymm2HG9xCMj7IXhs36sPnybpdYyFJlf3Wuahpv9KZzJm6SHaddAMJKVnqOxDeoW0XJdfhsjY8CeSV1j5JLinPnCGfMcLCo5Bde6vC1BtShY3adZqLmre7mmnEaXiNzYUy8H0TUuAdh4cc(4beJCMj7IXbqfNbzSVXLIBykGJNgbgOL4OKCafbMoEKyUgvr8UKwbnmdvYerSZW8aIro6064bPnN0gMvntIc4u2WbzoaY3dal4W0GGFUHyOFdIKk)2OlrmDdcX)MDUlicc(WWGOYQNxeBWo8GiiOqjNt(2aHEL2hiodYyFJlf3Wuahpv92enNdmD8OhqmYXf9IusuAye634IdGctJhqmYvVnrZ54dfhsjY8CKGGP(XCsuSFA0oqbxCgKX(gxkUHPaoEQ6TjAohy64rggevw98QHi6LrJGPbKnT55iodxGWNjjcPGUyccmm2HG9xCMj7IXbqfe8aIroZKDX4aOIHXWyhc2FXz4ce(mjFrKuH2t)k(q6wxkFHWq46g8peJANgt9J5KOy)0CyWcUyyEaXix92enNJpKU1LY3aNbzSVXLIBykGJNQEBuadecmD8iddIkREE1qe9YOrW0aYM28CeNHlq4ZKeHuqxmbbgg7qW(loZKDX4aOccEaXiNzYUyCauXWyySdb7V4mCbcFMKVisQq7PFfFiDRlLVqyiCDd(hIrTtJP(XCsuSFAomubxmmpGyKREBIMZXbqHrmxJQiExsRGodYyFJlf3Wuahpv92Oagiey64rpGyKJl6fPKmhzJeuRACXbqfe04J6Tj2dXnujteXoliOXdig5mt2fJpKU1LYxWcZdig5mt2fJdGkiOXdig5JbIkmGsghQco08H0TUu(cHHW1n4Fig1onM6hZjrX(P5WqfCXW8aIr(yGOcdOKXHQGdnhavSyyGSPnphXvVnrZ5K(X1lJMZjXXimfk5CY3gi0R4Q3MO5C(cvXW04Zauuepqi(36KF8usKHmDVUqOHtqjGgfLqeeuOKZjFBGqVIREBIMZ5lufNbzSVXLIBykGJNwKFPogxGPJh1qmxJQiExsRGggdJDiy)fNzYUy8H0TUuAdwWfe0WezdesD8aydXezdes(To5lyfliWezdesDeQIHzOsMiIDodYyFJlf3WuahpvK5IsDmUathpQHyUgvr8UKwbnmgg7qW(loZKDX4dPBDP0gSGliOHjYgiK64bWgIjYgiK8BDYxWkwqGjYgiK6iufdZqLmre7CgKX(gxkUHPaoEAeW5K6yCbMoEudXCnQI4DjTcAymm2HG9xCMj7IXhs36sPnybxqqdtKnqi1XdGnetKnqi536KVGvSGatKnqi1rOkgMHkzIi25miJ9nUuCdtbC8u)2mnEK4OKCafLbzSVXLIBykGJNcYM28CeyktNoQEBI9qYUKkSZgWaYCa0rfk5CY3gi0R4Q3MypK2boGOdJhn6M6PbAjiZbqh(aWfhq0HXJgpGyKREBuadess6Oy)0Ot1lvyNnC1BSZhoWIZGm234sXnmfWXt9p2lcmD8iXCnQI4oGYgzrW)feiMRrve3kOLfb)hgiBAZZr8wjzoYarccEaXiNyUgvrsf2zdFiDRlLVg7BCXvVnXEiobFIb8K8BDcMhqmYjMRrvKuHD2WbqfeiMRrveVlPc7SbMpGSPnphXvVnXEizxsf2zJGGhqmYzMSlgFiDRlLVg7BCXvVnXEiobFIb8K8BDcMpGSPnphXBLK5idebZdig5mt2fJpKU1LYxc(ed4j536empGyKZmzxmoaQGGhqmYhdevyaLmoufCO5aOWuOKZjfzQN0gCUwdtJcLCo5Bde6v(EeQcc(8MJQNRWaojokFrKmIhs9CQmphHiwqWhq20MNJ4TsYCKbIG5beJCMj7IXhs36sPnbFIb8K8BDkdYyFJlf3Wuahpv92e7HYGm234sXnmfWXthGsASVXL01QhmLPthJMZ9IgGmOmiJ9nUuCpS9hhdevyaLmoufCObthp6beJCMj7IXbqZGm234sX9W2hWXtbztBEocmLPthz4ce(mjrif0fdmGmhaDm6W4rJMUEAqXo7jezSHi6LdPBDPGIhaU4dd3bGlw7OdJhnA66Pbf7SNqKXgIOxoKU1LckEayHIAGd8d9MJQN3fZMY(gxCQmphHigkQjWhIHleG(5OdXAfjnxdP0P65uzEocrS4ddhuaCXzqg7BCP4Ey7d44PGSPnphbMY0PJSP)c)aOGbK5aOJ(4beJCpZzfJK4O0Co5lQlikzzpWqCauy(4beJCpZzfJK4O0Co5lQlikPnmRioaAgKX(gxkUh2(aoEQHyOFdIKk)2Odgg0mhjFBGqV6iCGPJh9aIrUN5SIrsCuAoN8f1feLSShyiU6n2zjiZbq(gyWH5beJCpZzfJK4O0Co5lQlikPnmRiU6n2zjiZbq(gyWHPXhe8Zned9BqKu53gDjIPBqi(3SZDbbMpg7BCXned9BqKu53gDjIPBqiExYORHi6HPXhe8Zned9BqKu53gDPiYC8VzN7cIGac(5gIH(nisQ8BJUuezo(q6wxkTHQybbe8Zned9BqKu53gDjIPBqiU6n2zFHkme8Zned9BqKu53gDjIPBqi(q6wxkFblme8Zned9BqKu53gDjIPBqi(3SZDbrCgKX(gxkUh2(aoEkdxGWNj5lIKk0E6xbMoEudiBAZZrCgUaHptsesbDXG11tdk2zpHiJnerVCiDRlL2WbvWH5ddJDiy)fNzYUy8HmeOfe8aIroZKDX4aOIHPXdig5EMZkgjXrP5CYxuxquYYEGH4Q3yNLGmhaDeSGli4beJCpZzfJK4O0Co5lQlikPnmRiU6n2zjiZbqhbl4IfeInerVCiDRlLVWbEgKX(gxkUh2(aoEkZkg5KEaXiyktNoQEBC4bbmD8OgpGyK7zoRyKehLMZjFrDbrjl7bgIpKU1Ls7aZbRGGhqmY9mNvmsIJsZ5KVOUGOK2WSI4dPBDP0oWCWkgMP(XCsuSFA0(yGcomnmm2HG9xCMj7IXhs36sPnuwqqddJDiy)fN0rX(Pr6Hle(q6wxkTHYW8Xdig5N7cziejPJI9tJovVKkAG0bN4aOWyyquz1Zpd90wjwCgKX(gxkUh2(aoEQ6TrbmqiW0XJ(aYM28CeNn9x4hafMgggevw98QHi6LrJeeyySdb7V4mt2fJpKU1LsBOSGGggg7qW(loPJI9tJ0dxi8H0TUuAdLH5JhqmYp3fYqisshf7NgDQEjv0aPdoXbqHXWGOYQNFg6PTsS4miJ9nUuCpS9bC8u1BJcyGqGPJh1WWyhc2FXz4ce(mjFrKuH2t)koakmnGSPnphXz4ce(mjrif0ftqGHXoeS)IZmzxm(q6wxkFbRyXWm1pMtII9tJ2GfCymmiQS65vdr0lJgLbzSVXLI7HTpGJNQaQypeyyqZCK8Tbc9QJWbMoECO4qkrMNJG92aHE(36K8XsKM0goTgMgdvYerSZW0aYM28CeNn9x4havqqJP(XCsuSFA8fQGdZhpGyKZmzxmoaQybbgg7qW(loZKDX4dziqlwCgKX(gxkUh2(aoEQogxXEiWWGM5i5Bde6vhHdmD84qXHuImphb7Tbc98V1j5JLinPnCqLdwyAmujteXodtdiBAZZrC20FHFaubbnM6hZjrX(PXxOcomF8aIroZKDX4aOIfeyySdb7V4mt2fJpKHaTyy(4beJ8ZDHmeIK0rX(PrNQxsfnq6GtCauXzqg7BCP4Ey7d44PQNCoBKrNneyyqZCK8Tbc9QJWbMoECO4qkrMNJG92aHE(36K8XsKM0goToGH0TUuW0yOsMiIDgMgq20MNJ4SP)c)aOccM6hZjrX(PXxOcUGadJDiy)fNzYUy8HmeOflodYyFJlf3dBFahpnIhgjXrzzpWqGPJhnujteXoNbzSVXLI7HTpGJNgbgOL4OKCafbMoEudXCnQI4DjTcAbbI5AufXvyNnYUKWjiqmxJQiUdOSr2LeoXW04dddIkREE1qe9YOrccAm1pMtII9tJVbkyHPbKnT55ioB6VWpaQGGP(XCsuSFA8fQGliaYM28CeVvsdtIHPbKnT55iodxGWNjjcPGUyW8HHXoeS)IZWfi8zs(IiPcTN(vCaubbFaztBEoIZWfi8zsIqkOlgmFyySdb7V4mt2fJdGkwSyyAyySdb7V4mt2fJpKU1LsBOcUGGP(XCsuSFA0oqbhgdJDiy)fNzYUyCauyAyySdb7V4Kok2pnspCHWhs36s5RX(gxC1BtShItWNyapj)wNee8HHbrLvp)m0tBLybHUEAqXo7jezSHi6LdPBDP8foWfdtdc(5gIH(nisQ8BJUeX0nieFiDRlL2bwqWhggevw98Iyd2HheXzqg7BCP4Ey7d44PN7cziePcTN(vGPJh1qmxJQiUdOSrwe8FbbI5AufXvyNnYIG)liqmxJQiUvqllc(VGGhqmY9mNvmsIJsZ5KVOUGOKL9adXhs36sPDG5GvqWdig5EMZkgjXrP5CYxuxqusBywr8H0TUuAhyoyfem1pMtII9tJ2bk4WyySdb7V4mt2fJpKHaTyyAyySdb7V4mt2fJpKU1LsBOcUGadJDiy)fNzYUy8HmeOfli01tdk2zpHiJnerVCiDRlLVWbEgKX(gxkUh2(aoEkJCK6BZjnxdP0P6bthpQXu)yojk2pnAhOGdtJhqmYp3fYqisshf7NgDQEjv0aPdoXbqfe8HHbrLvp)m0tBLybbggevw98QHi6LrJee8aIrUNdJrCaQNdGcZdig5EomgXbOE(q6wxkFpa8a0e4dXWfcq)C0HyTIKMRHu6u9CQmphHiwmmn(WWGOYQNxnerVmAKGadJDiy)fNHlq4ZK8frsfAp9R4aOccD90GID2tiYydr0lhs36s5ldJDiy)fNHlq4ZK8frsfAp9R4dPBDPcqRfe66Pbf7SNqKXgIOxoKU1L6WhgoOa4(Ea4bOjWhIHleG(5OdXAfjnxdP0P65uzEocrS4miJ9nUuCpS9bC80Uy2u234cmD8Ogt9J5KOy)0ODGcomnEaXi)CxidHijDuSFA0P6LurdKo4ehavqWhggevw98ZqpTvIfeyyquz1ZRgIOxgnsqWdig5EomgXbOEoakmpGyK75WyehG65dPBDP8fQGhGMaFigUqa6NJoeRvK0CnKsNQNtL55ieXIHPXhggevw98QHi6LrJeeyySdb7V4mCbcFMKVisQq7PFfhavqaKnT55iodxGWNjjcPGUyW66Pbf7SNqKXgIOxoKU1LsB4GcGhWbGhGMaFigUqa6NJoeRvK0CnKsNQNtL55ieXccD90GID2tiYydr0lhs36s5ldJDiy)fNHlq4ZK8frsfAp9R4dPBDPcqRfe66Pbf7SNqKXgIOxoKU1LYxOcEaAc8Hy4cbOFo6qSwrsZ1qkDQEovMNJqelodYyFJlf3dBFahpv92Oagiey64rggevw98QHi6LrJGPbKnT55iodxGWNjjcPGUyccmm2HG9xCMj7IXhs36s5lCGlgMP(XCsuSFA0gSGdJHXoeS)IZWfi8zs(IiPcTN(v8H0TUu(ch4zqg7BCP4Ey7d44PGSPnphbMY0PJMcnycnHedmGmhaDKyUgvr8UKoGYMdbfoSX(gxC1BtShItWNyapj)wNcWhI5AufX7s6akBoKwFyJ9nU4(h7fXj4tmGNKFRtbao)GdRqjNtkYupLbzSVXLI7HTpGJNQEBuadecmD8OMUEAqXo7jezSHi6LdPBDP8nWccA8aIr(yGOcdOKXHQGdnFiDRlLVqyiCDd(hIrTtJP(XCsuSFAomubxmmpGyKpgiQWakzCOk4qZbqflwqqJP(XCsuSFAcaKnT55iUPqdMqtiXoKhqmYjMRrvKuHD2Whs36sfac(5rGbAjokjhqr8VzNvYH0TUo0bCWQnChaUGGP(XCsuSFAcaKnT55iUPqdMqtiXoKhqmYjMRrvK0bu2Whs36sfac(5rGbAjokjhqr8VzNvYH0TUo0bCWQnChaUyyeZ1OkI3L0kOHPrJpmm2HG9xCMj7IXbqfeyyquz1Zpd90wbZhgg7qW(loPJI9tJ0dxiCauXccmmiQS65vdr0lJgjgMgFyyquz1Zbr1lc6rqWhpGyKZmzxmoaQGGP(XCsuSFA0oqbxSGGhqmYzMSlgFiDRlL2qby(4beJ8XarfgqjJdvbhAoaAgKX(gxkUh2(aoEAr(L6yCbMoEuJhqmYjMRrvK0bu2Wbqfe0WezdesD8aydXezdes(To5lyfliWezdesDeQIHzOsMiIDodYyFJlf3dBFahpvK5IsDmUathpQXdig5eZ1Oks6akB4aOccAyISbcPoEaSHyISbcj)wN8fSIfeyISbcPocvXWmujteXoNbzSVXLI7HTpGJNgbCoPogxGPJh14beJCI5AufjDaLnCaubbnmr2aHuhpa2qmr2aHKFRt(cwXccmr2aHuhHQyygQKjIyNZGm234sX9W2hWXt9BZ04rIJsYbuugKX(gxkUh2(aoEQ6Tj2dbMoEKyUgvr8UKoGYgbbI5AufXvyNnYIG)liqmxJQiUvqllc(VGGhqmY9BZ04rIJsYbuehafgXCnQI4DjDaLnccA8aIroZKDX4dPBDP81yFJlU)XErCc(ed4j536empGyKZmzxmoaQ4miJ9nUuCpS9bC8u)J9IYGm234sX9W2hWXthGsASVXL01QhmLPthJMZ9IgGmOmiJ9nUuCKHmDVUqO5iiBAZZrGPmD6OYIK8XsafjvOKZbgqMdGoQXdig5FRt(XtjrgY096cHg(q6wxkTHWq46g8daCoCW0qmxJQiExsp8lsqGyUgvr8UKkSZgbbI5AufXDaLnYIG)lwqWdig5FRt(XtjrgY096cHg(q6wxkTn234IREBI9qCc(ed4j536uaGZHdMgI5AufX7s6akBeeiMRrvexHD2ilc(VGaXCnQI4wbTSi4)Ifli4JhqmY)wN8JNsImKP71fcnCa0miJ9nUuCKHmDVUqOjGJNQEBuadecmD8OgFaztBEoIRSijFSeqrsfk5CccA8aIr(yGOcdOKXHQGdnFiDRlLVqyiCDd(hIrTtJP(XCsuSFAomubxmmpGyKpgiQWakzCOk4qZbqflwqWu)yojk2pnAhOGNbzSVXLIJmKP71fcnbC8ugUaHptYxejvO90VcmD8Ogq20MNJ4mCbcFMKiKc6IbRRNguSZEcrgBiIE5q6wxkTHdQGdZhgg7qW(loZKDX4dziqli4beJCMj7IXbqfdZu)yojk2pn(gyWHPXdig5eZ1Oks6akB4dPBDP0goWfe8aIroXCnQIKkSZg(q6wxkTHdCXccXgIOxoKU1LYx4apdYyFJlfhzit3RleAc44PgIH(nisQ8BJoyyqZCK8Tbc9QJWbMoE0he8Zned9BqKu53gDjIPBqi(3SZDbbMpg7BCXned9BqKu53gDjIPBqiExYORHi6HPXhe8Zned9BqKu53gDPiYC8VzN7cIGac(5gIH(nisQ8BJUuezo(q6wxkTbRybbe8Zned9BqKu53gDjIPBqiU6n2zFHkme8Zned9BqKu53gDjIPBqi(q6wxkFHkme8Zned9BqKu53gDjIPBqi(3SZDbjdYyFJlfhzit3RleAc44P6yCf7HaddAMJKVnqOxDeoW0XJdfhsjY8CeS3gi0Z)wNKpwI0K2WDamnA8aIroZKDX4dPBDP0gSW04beJ8XarfgqjJdvbhA(q6wxkTbRGGpEaXiFmquHbuY4qvWHMdGkwqWhpGyKZmzxmoaQGGP(XCsuSFA8fQGlgMgF8aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoaQGGP(XCsuSFA8fQGlgMHkzIi2zXzqg7BCP4idz6EDHqtahpvbuXEiWWGM5i5Bde6vhHdmD84qXHuImphb7Tbc98V1j5JLinPnChatJgpGyKZmzxm(q6wxkTblmnEaXiFmquHbuY4qvWHMpKU1LsBWki4JhqmYhdevyaLmoufCO5aOIfe8Xdig5mt2fJdGkiyQFmNef7NgFHk4IHPXhpGyKFUlKHqKKok2pn6u9sQObshCIdGkiyQFmNef7NgFHk4IHzOsMiIDwCgKX(gxkoYqMUxxi0eWXtvp5C2iJoBiWWGM5i5Bde6vhHdmD84qXHuImphb7Tbc98V1j5JLinPnCAnmnA8aIroZKDX4dPBDP0gSW04beJ8XarfgqjJdvbhA(q6wxkTbRGGpEaXiFmquHbuY4qvWHMdGkwqWhpGyKZmzxmoaQGGP(XCsuSFA8fQGlgMgF8aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoaQGGP(XCsuSFA8fQGlgMHkzIi2zXzqg7BCP4idz6EDHqtahpnIhgjXrzzpWqGPJhnujteXoNbzSVXLIJmKP71fcnbC80XarfgqjJdvbhAW0XJEaXiNzYUyCa0miJ9nUuCKHmDVUqOjGJNEUlKHqKk0E6xbMoEuJgpGyKtmxJQiPc7SHpKU1LsB4axqWdig5eZ1Oks6akB4dPBDP0goWfdJHXoeS)IZmzxm(q6wxkTHk4IfeyySdb7V4mt2fJpKHaDgKX(gxkoYqMUxxi0eWXtzKJuFBoP5AiLovpy64rnA8aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoaQGGpmmiQS65NHEAReliWWGOYQNxnerVmAKGaiBAZZr8wjnmji4beJCphgJ4auphafMhqmY9CymIdq98H0TUu(Ea4bOjWhIHleG(5OdXAfjnxdP0P65uzEocrSyy(4beJCMj7IXbqHPXhggevw98QHi6LrJeeyySdb7V4mCbcFMKVisQq7PFfhavqORNguSZEcrgBiIE5q6wxkFzySdb7V4mCbcFMKVisQq7PFfFiDRlvaATGqxpnOyN9eIm2qe9YH0TUuh(WWbfa33dapanb(qmCHa0phDiwRiP5AiLovpNkZZriIfNbzSVXLIJmKP71fcnbC80Uy2u234cmD8OgnEaXi)CxidHijDuSFA0P6LurdKo4ehavqWhggevw98ZqpTvIfeyyquz1ZRgIOxgnsqaKnT55iERKgMee8aIrUNdJrCaQNdGcZdig5EomgXbOE(q6wxkFHk4bOjWhIHleG(5OdXAfjnxdP0P65uzEocrSyy(4beJCMj7IXbqHPXhggevw98QHi6LrJeeyySdb7V4mCbcFMKVisQq7PFfhavqORNguSZEcrgBiIE5q6wxkFzySdb7V4mCbcFMKVisQq7PFfFiDRlvaATGqxpnOyN9eIm2qe9YH0TUuh(WWbfa3xOcEaAc8Hy4cbOFo6qSwrsZ1qkDQEovMNJqelodYyFJlfhzit3RleAc44PGSPnphbMY0PJkdejJ4rYmzxmWaYCa0rn(WWyhc2FXzMSlgFidbAbbFaztBEoIZWfi8zsIqkOlgmggevw98QHi6LrJeNbzSVXLIJmKP71fcnbC80iWaTehLKdOiW0XJeZ1OkI3L0kOHzOsMiIDgMge8Zned9BqKu53gDjIPBqi(3SZDbrqWhggevw98Iyd2HheXWaztBEoIRmqKmIhjZKDXYGm234sXrgY096cHMaoEQ6TrbmqiW0XJmmiQS65vdr0lJgbdKnT55iodxGWNjjcPGUyWm1pMtII9tJ2hdm4WyySdb7V4mCbcFMKVisQq7PFfFiDRlLVqyiCDd(hIrTtJP(XCsuSFAomubxCgKX(gxkoYqMUxxi0eWXtlYVuhJlW0XJA8aIroXCnQIKoGYgoaQGGgMiBGqQJhaBiMiBGqYV1jFbRybbMiBGqQJqvmmdvYerSZWaztBEoIRmqKmIhjZKDXYGm234sXrgY096cHMaoEQiZfL6yCbMoEuJhqmYjMRrvK0bu2WbqH5dddIkRE(zON2kbbnEaXi)CxidHijDuSFA0P6LurdKo4ehafgddIkRE(zON2kXccAyISbcPoEaSHyISbcj)wN8fSIfeyISbcPocvbbpGyKZmzxmoaQyygQKjIyNHbYM28CexzGizepsMj7ILbzSVXLIJmKP71fcnbC80iGZj1X4cmD8OgpGyKtmxJQiPdOSHdGcZhggevw98ZqpTvccA8aIr(5Uqgcrs6Oy)0Ot1lPIgiDWjoakmggevw98ZqpTvIfe0WezdesD8aydXezdes(To5lyfliWezdesDeQccEaXiNzYUyCauXWmujteXoddKnT55iUYarYiEKmt2fldYyFJlfhzit3RleAc44P(TzA8iXrj5akkdYyFJlfhzit3RleAc44PQ3Mypey64rI5AufX7s6akBeeiMRrvexHD2ilc(VGaXCnQI4wbTSi4)ccEaXi3VntJhjokjhqrCauyEaXiNyUgvrshqzdhavqqJhqmYzMSlgFiDRlLVg7BCX9p2lItWNyapj)wNG5beJCMj7IXbqfNbzSVXLIJmKP71fcnbC8u)J9IYGm234sXrgY096cHMaoE6ausJ9nUKUw9GPmD6y0CUx0aKbLbzSVXLIhnN7fnahvVnkGbcbMoE0NbOOiEGqCpZzfJK4O0Co5lQlikobLaAuucjdYyFJlfpAo3lAac44PkGk2dbgg0mhjFBGqV6iCGPJhrWpxhJRypeFiDRlL2dPBDPYGm234sXJMZ9IgGaoEQogxXEOmOmiJ9nUuC1F0qm0VbrsLFB0bddAMJKVnqOxDeoW0XJ(GGFUHyOFdIKk)2OlrmDdcX)MDUliW8XyFJlUHyOFdIKk)2OlrmDdcX7sgDnerpmn(GGFUHyOFdIKk)2OlfrMJ)n7CxqeeqWp3qm0VbrsLFB0LIiZXhs36sPnyfliGGFUHyOFdIKk)2OlrmDdcXvVXo7luHHGFUHyOFdIKk)2OlrmDdcXhs36s5luHHGFUHyOFdIKk)2OlrmDdcX)MDUlizqg7BCP4QpGJNYWfi8zs(IiPcTN(vGPJh1aYM28CeNHlq4ZKeHuqxmyD90GID2tiYydr0lhs36sPnCqfCy(WWyhc2FXzMSlgFidbAbbpGyKZmzxmoaQyyM6hZjrX(PXxWcomnEaXiNyUgvrshqzdFiDRlL2WbUGGhqmYjMRrvKuHD2Whs36sPnCGlwqi2qe9YH0TUu(ch4zqg7BCP4QpGJNcYM28CeyktNoIGF5qqjGEiDQEfyazoa6OgpGyKZmzxm(q6wxkTblmnEaXiFmquHbuY4qvWHMpKU1LsBWki4JhqmYhdevyaLmoufCO5aOIfe8Xdig5mt2fJdGkiyQFmNef7NgFHk4IHPXhpGyKFUlKHqKKok2pn6u9sQObshCIdGkiyQFmNef7NgFHk4IHPXdig5eZ1OksQWoB4dPBDP0gcdHRBWxqWdig5eZ1Oks6akB4dPBDP0gcdHRBWxCgKX(gxkU6d44P6yCf7HaddAMJKVnqOxDeoW0XJdfhsjY8CeS3gi0Z)wNKpwI0K2WDamngQKjIyNHbYM28Cehb)YHGsa9q6u9kXzqg7BCP4QpGJNQaQypeyyqZCK8Tbc9QJWbMoECO4qkrMNJG92aHE(36K8XsKM0gUdGPXqLmre7mmq20MNJ4i4xoeucOhsNQxjodYyFJlfx9bC8u1toNnYOZgcmmOzos(2aHE1r4athpouCiLiZZrWEBGqp)BDs(yjstAdNwdtJHkzIi2zyGSPnphXrWVCiOeqpKovVsCgKX(gxkU6d44Pr8Wijokl7bgcmD8OHkzIi25miJ9nUuC1hWXthdevyaLmoufCObthp6beJCMj7IXbqZGm234sXvFahpL0rX(Pr6HleW0XJA04beJCI5AufjvyNn8H0TUuAdh4ccEaXiNyUgvrshqzdFiDRlL2WbUyymm2HG9xCMj7IXhs36sPnubhMgpGyKJoToEqAZjTHzvZKOaoLnCqMdG89GadUGGpdqrr8aH4OtRJhK2CsByw1mjkGtzdNGsankkHiwSGGhqmYrNwhpiT5K2WSQzsuaNYgoiZbqAF8aOm4ccmm2HG9xCMj7IXhYqGgMgt9J5KOy)0ODGcUGaiBAZZr8wjnmjodYyFJlfx9bC8ug5i13MtAUgsPt1dMoEuJP(XCsuSFA0oqbhMgpGyKFUlKHqKKok2pn6u9sQObshCIdGki4dddIkRE(zON2kXccmmiQS65vdr0lJgjiaYM28CeVvsdtccEaXi3ZHXioa1ZbqH5beJCphgJ4aupFiDRlLVhaEaA0eOhAakkIhiehDAD8G0MtAdZQMjrbCkB4eucOrrjeXbOjWhIHleG(5OdXAfjnxdP0P65uzEocrSyXW8Xdig5mt2fJdGctJpmmiQS65vdr0lJgjiWWyhc2FXz4ce(mjFrKuH2t)koaQGqxpnOyN9eIm2qe9YH0TUu(YWyhc2FXz4ce(mjFrKuH2t)k(q6wxQa0AbHUEAqXo7jezSHi6LdPBDPo8HHdkaUVhaEaAc8Hy4cbOFo6qSwrsZ1qkDQEovMNJqelodYyFJlfx9bC80Uy2u234cmD8Ogt9J5KOy)0ODGcomnEaXi)CxidHijDuSFA0P6LurdKo4ehavqWhggevw98ZqpTvIfeyyquz1ZRgIOxgnsqaKnT55iERKgMee8aIrUNdJrCaQNdGcZdig5EomgXbOE(q6wxkFHk4bOrtGEObOOiEGqC0P1XdsBoPnmRAMefWPSHtqjGgfLqehGMaFigUqa6NJoeRvK0CnKsNQNtL55ieXIfdZhpGyKZmzxmoakmn(WWGOYQNxnerVmAKGadJDiy)fNHlq4ZK8frsfAp9R4aOccD90GID2tiYydr0lhs36s5ldJDiy)fNHlq4ZK8frsfAp9R4dPBDPcqRfe66Pbf7SNqKXgIOxoKU1L6WhgoOa4(cvWdqtGpedxia9ZrhI1ksAUgsPt1ZPY8CeIyXzqg7BCP4QpGJNcYM28CeyktNoQmqKmIhjZKDXadiZbqh14ddJDiy)fNzYUy8HmeOfe8bKnT55iodxGWNjjcPGUyWyyquz1ZRgIOxgnsCgKX(gxkU6d44PrGbAjokjhqrGPJhjMRrveVlPvqdZqLmre7mmpGyKJoToEqAZjTHzvZKOaoLnCqMdG89Gadomni4NBig63GiPYVn6set3Gq8VzN7cIGGpmmiQS65fXgSdpiIHbYM28CexzGizepsMj7ILbzSVXLIR(aoEQ6TjAohy64rpGyKJl6fPKO0Wi0VXfhafMhqmYvVnrZ54dfhsjY8CugKX(gxkU6d44PmRyKt6beJGPmD6O6TXHheW0XJEaXix924WdcFiDRlLVGfMgpGyKtmxJQiPc7SHpKU1LsBWki4beJCI5AufjDaLn8H0TUuAdwXWm1pMtII9tJ2bk4zqg7BCP4QpGJNQEBuadecmD8iddIkREE1qe9YOrWaztBEoIZWfi8zsIqkOlgmgg7qW(lodxGWNj5lIKk0E6xXhs36s5legcx3G)Hyu70yQFmNef7NMddvWfNbzSVXLIR(aoEQ6TjAohy64X3Cu9C1toNnsKPJpNkZZriWu0)DbrXvyhwImD8H5ZBoQEU6TXHheovMNJqG5beJC1Bt0Co(qXHuImphbtJhqmYjMRrvK0bu2Whs36sPTwdJyUgvr8UKoGYgyEaXihDAD8G0MtAdZQMjrbCkB4Gmha57bGfCbbpGyKJoToEqAZjTHzvZKOaoLnCqMdG0(4bGfCyM6hZjrX(Pr7afCbbe8Zned9BqKu53gDjIPBqi(q6wxkTHcccg7BCXned9BqKu53gDjIPBqiExYORHi6fdZhgg7qW(loZKDX4dziqNbzSVXLIR(aoEQ6TrbmqiW0XJEaXihx0lsjzoYgjOw14IdGki4beJ8ZDHmeIK0rX(PrNQxsfnq6GtCaubbpGyKZmzxmoakmnEaXiFmquHbuY4qvWHMpKU1LYximeUUb)dXO2PXu)yojk2pnhgQGlgMhqmYhdevyaLmoufCO5aOcc(4beJ8XarfgqjJdvbhAoakmFyySdb7V4JbIkmGsghQco08HmeOfe8HHbrLvphevViOhXccM6hZjrX(Pr7afCyeZ1OkI3L0kOZGm234sXvFahpv92Oagiey64X3Cu9C1BJdpiCQmphHatJhqmYvVno8GWbqfem1pMtII9tJ2bk4IH5beJC1BJdpiC1BSZ(cvyA8aIroXCnQIKkSZgoaQGGhqmYjMRrvK0bu2WbqfdZdig5OtRJhK2CsByw1mjkGtzdhK5aiFpakdomnmm2HG9xCMj7IXhs36sPnCGli4diBAZZrCgUaHptsesbDXGXWGOYQNxnerVmAK4miJ9nUuC1hWXtvVnkGbcbMoEuJhqmYrNwhpiT5K2WSQzsuaNYgoiZbq(EaugCbbpGyKJoToEqAZjTHzvZKOaoLnCqMdG89aWcoS3Cu9C1toNnsKPJpNkZZriIH5beJCI5AufjvyNn8H0TUuAdLHrmxJQiExsf2zdmF8aIroUOxKsIsdJq)gxCauy(8MJQNREBC4bHtL55ieymm2HG9xCMj7IXhs36sPnugMggg7qW(l(5UqgcrQq7PFfFiDRlL2qzbbFyyquz1Zpd90wjodYyFJlfx9bC80I8l1X4cmD8OgpGyKtmxJQiPdOSHdGkiOHjYgiK64bWgIjYgiK8BDYxWkwqGjYgiK6iufdZqLmre7mmq20MNJ4kdejJ4rYmzxSmiJ9nUuC1hWXtfzUOuhJlW0XJA8aIroXCnQIKoGYgoakmFyyquz1Zpd90wjiOXdig5N7cziejPJI9tJovVKkAG0bN4aOWyyquz1Zpd90wjwqqdtKnqi1XdGnetKnqi536KVGvSGatKnqi1rOki4beJCMj7IXbqfdZqLmre7mmq20MNJ4kdejJ4rYmzxSmiJ9nUuC1hWXtJaoNuhJlW0XJA8aIroXCnQIKoGYgoakmFyyquz1Zpd90wjiOXdig5N7cziejPJI9tJovVKkAG0bN4aOWyyquz1Zpd90wjwqqdtKnqi1XdGnetKnqi536KVGvSGatKnqi1rOki4beJCMj7IXbqfdZqLmre7mmq20MNJ4kdejJ4rYmzxSmiJ9nUuC1hWXt9BZ04rIJsYbuugKX(gxkU6d44PQ3Mypey64rI5AufX7s6akBeeiMRrvexHD2ilc(VGaXCnQI4wbTSi4)ccEaXi3VntJhjokjhqrCauyEaXiNyUgvrshqzdhavqqJhqmYzMSlgFiDRlLVg7BCX9p2lItWNyapj)wNG5beJCMj7IXbqfNbzSVXLIR(aoEQ)XErzqg7BCP4QpGJNoaL0yFJlPRvpyktNognN7fna3qfkXUNah4hC)7FVa]] )


end