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


    spec:RegisterPack( "Balance", 20201201, [[dC02qdqiQkEefsQlPcQnbsFcuezuuWPiOvPcYReGzPIQBbkk7cv)sfPHbOogOYYubEgOW0eqDnvu2gfs9nqr14eO05eqADuiX8OQ09uH2hfQdckIAHGQ6HciMiOiixeueuFeueYjPqsALcKzkqXovrmuqrGLsHK4PcAQGQ8vqrO2Rk9xIgSshM0IPkpgLjdXLr2SqFgeJMaNwQxdiZMk3MI2TKFd1WH0XbfPLR45uA6Q66aTDa(ovvJNcX5bLwVavZNq7x0x4UW7gIOpDp5aGpay4oay44WD2zWDqWEdFyrPBiQYasHq3WsnPBi8vNwm6gIQW6WkYfE3qlgCy0nuW)OwJYPNcPFbGECg28uBBc60VXfB04FQTnzNEd9aB3BuTUE3qe9P7jha8bad3badhhUZodo4m6BOc(cWZnmSndKBOGgbHQR3neHSSBOrDUWxDAXOCHj0a2izqg15ctiIrME0KlCNN7baFaWzqzqg15gic0ccznkzqg15cZYfMmccHKBi2PtUWNutEgKrDUWSCdebAbHqY91bc9YoMltTKn3hNldwMJKVoqO3YZGmQZfMLRrfYedGqYfSkIrwRoWMlaDA1Zr2Cn0CIFEUOdbqAFDSGdekxyMX5IoeaU91XcoqiH8BORTV9cVBOhw)l8UNa3fE3qQuphHCH)nKn9ttR3qpWyKZuzxmoi6nuzFJRB4OaOcdALXHQGd79VNCWfE3qQuphHCH)neJEdT0Fdv2346gcqNw9C0neG6aPBy0HXtUgY1qUD90GID6tiYydrWlhYu7YMlml3daoxH5EAUWDaW5kmxJZn6W4jxd5Ai3UEAqXo9jezSHi4LdzQDzZfML7bNLlmlxd5chW5EOCF1r1Z7IPtPFJlovQNJqYvyUWSCnKBGZ9q5YWfcy)C0HyTLKQRHuMu9CQuphHKRWCfM7P5cxWcCUcVHa0rwQjDdz4cagisIqwyl29VNaJl8UHuPEoc5c)Big9gAP)gQSVX1neGoT65OBia1bs3qFY1dmg5EQtlgjXrP6CYxqxqSYsFWH4GO5cnxFY1dmg5EQtlgjXrP6CYxqxqSsDyArCq0BiaDKLAs3q20FHFq07FpjWx4DdPs9CeYf(3qL9nUUHkII(nasA9RJ5nKn9ttR3qpWyK7PoTyKehLQZjFbDbXkl9bhIBFLbKeG6aPC9n3adCUqZ1dmg5EQtlgjXrP6CYxqxqSsDyArC7RmGKauhiLRV5gyGZfAUgY1NCrWpxru0VbqsRFDmLiQPcH4FZaQli5cnxFYvzFJlUIOOFdGKw)6ykrutfcX7sgDnebFUqZ1qU(Klc(5kII(nasA9RJPuaPo(3mG6csUII5IGFUIOOFdGKw)6ykfqQJpKP2LnxJZfg5kmxrXCrWpxru0VbqsRFDmLiQPcH42xzaLRV5cJCHMlc(5kII(nasA9RJPernvieFitTlBU(M7z5cnxe8Zvef9BaK06xhtjIAQqi(3mG6csUcVHmyzos(6aHE79e4U)9KZUW7gsL65iKl8VHSPFAA9gAixa60QNJ4mCbadejrilSflxO521tdk2PpHiJnebVCitTlBUgNlCWa4CHMRp5YWyhc2FXzQSlgFifb2CffZ1dmg5mv2fJdIMRWCHMRHC9aJrUN60IrsCuQoN8f0feRS0hCiU9vgqsaQdKY9yUNbCUII56bgJCp1PfJK4OuDo5lOliwPomTiU9vgqsaQdKY9yUNbCUcZvum3ydrWlhYu7YMRV5chW3qL9nUUHmCbadejFbK0I2t)27FpXOVW7gsL65iKl8VHSPFAA9gAixpWyK7PoTyKehLQZjFbDbXkl9bhIpKP2LnxJZnW8ZYvumxpWyK7PoTyKehLQZjFbDbXk1HPfXhYu7YMRX5gy(z5kmxO5Q2FuNef7NMCn(yUbkW5cnxd5YWyhc2FXzQSlgFitTlBUgNlmpxrXCnKldJDiy)fNmrX(Pr6Hle(qMAx2CnoxyEUqZ1NC9aJroqDHmeIKmrX(PXKQxsfnq6GtCq0CHMlddGkTEoqWoTw5kmxH3qL9nUUHmTyKt6bgJ3qpWyuwQjDdTVoo8GC)7jW8l8UHuPEoc5c)BiB6NMwVH(KlaDA1ZrC20FHFq0CHMRHCzyauP1ZRgIGxgvkxrXCzySdb7V4mv2fJpKP2LnxJZfMNROyUgYLHXoeS)ItMOy)0i9WfcFitTlBUgNlmpxO56tUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUqZLHbqLwphiyNwRCfMRWBOY(gx3q7RJfCGq3)EsWEH3nKk1Zrix4Fdzt)006n0qUmm2HG9xCgUaGbIKVasAr7PFlhenxO5Aixa60QNJ4mCbadejrilSflxrXCzySdb7V4mv2fJpKP2LnxFZ9SCfMRWCHMRA)rDsuSFAY14Cpd4CHMlddGkTEE1qe8YOs3qL9nUUH2xhl4aHU)9Ka9cVBivQNJqUW)gQSVX1n0cwXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLinLRX5cNrNl0CnKRIkzcigq5cnxd5cqNw9CeNn9x4henxrXCnKRA)rDsuSFAY13CHbW5cnxFY1dmg5mv2fJdIMRWCffZLHXoeS)IZuzxm(qkcS5kmxH3qgSmhjFDGqV9EcC3)EcCaFH3nKk1Zrix4Fdv2346gAIXvSh6gYM(PP1B4qXHScuphLl0CFDGqp)Bts(yjst5ACUWbd(z5cnxd5QOsMaIbuUqZ1qUa0PvphXzt)f(brZvumxd5Q2FuNef7NMC9nxyaCUqZ1NC9aJrotLDX4GO5kmxrXCzySdb7V4mv2fJpKIaBUcZfAU(KRhymYbQlKHqKKjk2pnMu9sQObshCIdIMRWBidwMJKVoqO3EpbU7Fpbo4UW7gsL65iKl8VHk7BCDdTp5C6iJoDOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLinLRX5cNrNBa5oKP2LnxO5AixfvYeqmGYfAUgYfGoT65ioB6VWpiAUII5Q2FuNef7NMC9nxyaCUII5YWyhc2FXzQSlgFifb2CfMRWBidwMJKVoqO3EpbU7FpbUdUW7gsL65iKl8VHSPFAA9gQOsMaIb0nuzFJRByepmsIJYsFWHU)9e4GXfE3qQuphHCH)nKn9ttR3qd5smxJAjExsTGnxrXCjMRrTe3ID6i7scxUII5smxJAjUdS0r2LeUCfMl0CnKRp5YWaOsRNxnebVmQuUII5Aix1(J6KOy)0KRV5gONLl0CnKlaDA1ZrC20FHFq0CffZvT)Oojk2pn56BUWa4CffZfGoT65iEBLkMYvyUqZ1qUa0PvphXz4cagisIqwylwUqZ1NCzySdb7V4mCbadejFbK0I2t)woiAUII56tUa0PvphXz4cagisIqwylwUqZ1NCzySdb7V4mv2fJdIMRWCfMRWCHMRHCzySdb7V4mv2fJpKP2LnxJZfgaNROyUQ9h1jrX(PjxJZnqboxO5YWyhc2FXzQSlghenxO5Aixgg7qW(lozII9tJ0dxi8Hm1US56BUk7BCXTVoXEiozeIb(K8BtkxrXC9jxggavA9CGGDATYvyUII521tdk2PpHiJnebVCitTlBU(MlCaNRWCHMRHCrWpxru0VbqsRFDmLiQPcH4dzQDzZ14CdCUII56tUmmaQ065fXgSdpi5k8gQSVX1nmcoWkXrj5al6(3tGlWx4DdPs9CeYf(3q20pnTEdnKlXCnQL4oWshzrg5ZvumxI5AulXTyNoYImYNROyUeZ1OwIRfSYImYNROyUEGXi3tDAXijokvNt(c6cIvw6doeFitTlBUgNBG5NLROyUEGXi3tDAXijokvNt(c6cIvQdtlIpKP2LnxJZnW8ZYvumx1(J6KOy)0KRX5gOaNl0CzySdb7V4mv2fJpKIaBUcZfAUgYLHXoeS)IZuzxm(qMAx2CnoxyaCUII5YWyhc2FXzQSlgFifb2CfMROyUD90GID6tiYydrWlhYu7YMRV5chW3qL9nUUHa1fYqislAp9BV)9e4o7cVBivQNJqUW)gYM(PP1BOHCv7pQtII9ttUgNBGcCUqZ1qUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUII56tUmmaQ065ab70ALRWCffZLHbqLwpVAicEzuPCffZ1dmg5EomgXbAFoiAUqZ1dmg5EomgXbAF(qMAx2C9n3dao3aY1qUbo3dLldxiG9ZrhI1wsQUgszs1ZPs9CesUcZvyUqZ1qU(KlddGkTEE1qe8YOs5kkMldJDiy)fNHlayGi5lGKw0E63YbrZvum3UEAqXo9jezSHi4LdzQDzZ13CzySdb7V4mCbadejFbK0I2t)w(qMAx2CdixJoxrXC76Pbf70NqKXgIGxoKP2Ln3dNlCblW56BUhaCUbKRHCdCUhkxgUqa7NJoeRTKuDnKYKQNtL65iKCfMRWBOY(gx3qg5i73QtQUgszs1F)7jWz0x4DdPs9CeYf(3q20pnTEdnKRA)rDsuSFAY14CduGZfAUgY1dmg5a1fYqisYef7NgtQEjv0aPdoXbrZvumxFYLHbqLwphiyNwRCfMROyUmmaQ065vdrWlJkLROyUEGXi3ZHXioq7ZbrZfAUEGXi3ZHXioq7ZhYu7YMRV5cdGZnGCnKBGZ9q5YWfcy)C0HyTLKQRHuMu9CQuphHKRWCfMl0CnKRp5YWaOsRNxnebVmQuUII5YWyhc2FXz4cagis(ciPfTN(TCq0CffZfGoT65iodxaWarseYcBXYfAUD90GID6tiYydrWlhYu7YMRX5cxWcCUbK7baNBa5Ai3aN7HYLHleW(5OdXAljvxdPmP65uPEocjxH5kkMBxpnOyN(eIm2qe8YHm1US56BUmm2HG9xCgUaGbIKVasAr7PFlFitTlBUbKRrNROyUD90GID6tiYydrWlhYu7YMRV5cdGZnGCnKBGZ9q5YWfcy)C0HyTLKQRHuMu9CQuphHKRWCfEdv2346g2ftNs)gx3)EcCW8l8UHuPEoc5c)BiB6NMwVHmmaQ065vdrWlJkLl0CnKlaDA1ZrCgUaGbIKiKf2ILROyUmm2HG9xCMk7IXhYu7YMRV5chW5kmxO5Q2FuNef7NMCno3ZaoxO5YWyhc2FXz4cagis(ciPfTN(T8Hm1US56BUWb8nuzFJRBO91XcoqO7FpbUG9cVBivQNJqUW)gIrVHw6VHk7BCDdbOtREo6gcqDG0nKyUg1s8UKoWsNCpuUbBUNMRY(gxC7RtShItgHyGpj)2KYnGC9jxI5AulX7s6alDY9q5A05EAUk7BCX9p6lGtgHyGpj)2KYnGCbMFqUNMRfLCoPa1(0neGoYsnPBOArHjGMqID)7jWfOx4DdPs9CeYf(3q20pnTEdnKBxpnOyN(eIm2qe8YHm1US56BUboxrXCnKRhymYhfavyqRmoufCy5dzQDzZ13CHWq4MQrY9q5YO2LRHCv7pQtII9ttUNMlmaoxH5cnxpWyKpkaQWGwzCOk4WYbrZvyUcZvumxd5Q2FuNef7NMCdixa60QNJ4QffMaAcjwUhkxpWyKtmxJAjPf70HpKP2Ln3aYfb)8i4aRehLKdSi(3mGSYHm1UY9q5Ea)SCnox4oa4CffZvT)Oojk2pn5gqUa0PvphXvlkmb0esSCpuUEGXiNyUg1sshyPdFitTlBUbKlc(5rWbwjokjhyr8VzazLdzQDL7HY9a(z5ACUWDaW5kmxO5smxJAjExsTGnxO5Aixd56tUmm2HG9xCMk7IXbrZvumxggavA9CGGDATYfAU(KldJDiy)fNmrX(Pr6HleoiAUcZvumxggavA98QHi4LrLYvyUqZ1qU(KlddGkTEoaQEbWo5kkMRp56bgJCMk7IXbrZvumx1(J6KOy)0KRX5gOaNRWCffZ1dmg5mv2fJpKP2LnxJZnyZfAU(KRhymYhfavyqRmoufCy5GO3qL9nUUH2xhl4aHU)9Kda(cVBivQNJqUW)gYM(PP1BOHC9aJroXCnQLKoWshoiAUII5AixMaDGq2CpM7b5cn3Hyc0bcj)2KY13CplxH5kkMltGoqiBUhZfg5kmxO5QOsMaIb0nuzFJRByr(LMyCD)7jha3fE3qQuphHCH)nKn9ttR3qd56bgJCI5AuljDGLoCq0CffZ1qUmb6aHS5Em3dYfAUdXeOdes(TjLRV5EwUcZvumxMaDGq2CpMlmYvyUqZvrLmbedOBOY(gx3qbQlknX46(3to4Gl8UHuPEoc5c)BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5kkMRHCzc0bczZ9yUhKl0ChIjqhiK8BtkxFZ9SCfMROyUmb6aHS5EmxyKRWCHMRIkzcigq3qL9nUUHrqNtAIX19VNCamUW7gQSVX1n0VotJhjokjhyr3qQuphHCH)9VNCqGVW7gsL65iKl8VHSPFAA9gsmxJAjExshyPtUII5smxJAjUf70rwKr(CffZLyUg1sCTGvwKr(CffZ1dmg5(1zA8iXrj5alIdIMl0CjMRrTeVlPdS0jxrXCnKRhymYzQSlgFitTlBU(MRY(gxC)J(c4Krig4tYVnPCHMRhymYzQSlghenxH3qL9nUUH2xNyp09VNCWzx4Ddv2346g6F0xWnKk1Zrix4F)7jhy0x4DdPs9CeYf(3qL9nUUHdyjv234s6A7FdDT9LLAs3WO6CVGb8(3)gIqrf09x4DpbUl8UHk7BCDdTyNospsnVHuPEoc5c)7Fp5Gl8UHuPEoc5c)Big9gAP)gQSVX1neGoT65OBia1bs3qlk5CYxhi0B52xNO6C5ACUWLl0CnKRp5(QJQNBFDC4bHtL65iKCffZ9vhvp3(KZPJez64ZPs9CesUcZvumxlk5CYxhi0B52xNO6C5ACUhCdbOJSut6g2wPIP7Fpbgx4DdPs9CeYf(3qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHwuY5KVoqO3YTVoXEOCnox4UHa0rwQjDdBRK5ifaD)7jb(cVBivQNJqUW)gYM(PP1BOHC9jxggavA98QHi4LrLYvumxFYLHXoeS)IZWfamqK8fqslAp9B5GO5kmxO56bgJCMk7IXbrVHk7BCDd9OXsdqDb5(3to7cVBivQNJqUW)gYM(PP1BOhymYzQSlghe9gQSVX1nef)nUU)9eJ(cVBOY(gx3qqlj7NmT3qQuphHCH)9VNaZVW7gsL65iKl8VHSPFAA9g6iaKlxFZ9m4UHk7BCDdfq68sYAPIr3)EsWEH3nKk1Zrix4Fdzt)006neGoT65iEBLkMUH2FA2FpbUBOY(gx3WbSKk7BCjDT9VHU2(YsnPBOIP7FpjqVW7gsL65iKl8VHSPFAA9goGffXdeI)Tj5hpLezi10RleA4emfSrrjKBO9NM93tG7gQSVX1nCalPY(gxsxB)BORTVSut6gImKA61fcn3)EcCaFH3nKk1Zrix4Fdzt)006nCalkIhie3tDAXijokvNt(c6cILtWuWgfLqUH2FA2FpbUBOY(gx3WbSKk7BCjDT9VHU2(YsnPBOhw)7Fpbo4UW7gsL65iKl8VHk7BCDdhWsQSVXL012)g6A7ll1KUH2)(3)gIoedB6P)fE3tG7cVBOY(gx3qtmUaQlzepM3qQuphHCH)9VNCWfE3qL9nUUHa1fYqislAp9BVHuPEoc5c)7Fpbgx4DdPs9CeYf(3qL9nUUH(h9fCdDDrsgYneoGV)9KaFH3nKk1Zrix4Fdzt)006neDiaC44(h9fKl0C9jx0HaWpG7F0xWnuzFJRBO)rFb3)EYzx4Ddv2346gAFDI9q3qQuphHCH)9VNy0x4DdPs9CeYf(3qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHEyRnxO5gDy8KRHCnKBSHi4LdzQDzZfML7baNRWCpnx4oa4CfMRX5gDy8KRHCnKBSHi4LdzQDzZfML7bNLlmlxd5chW5EOCF1r1Z7IPtPFJlovQNJqYvyUWSCnKBGZ9q5YWfcy)C0HyTLKQRHuMu9CQuphHKRWCfM7P5cxWcCUcVHa0rwQjDdz4cagisIqwyl29V)nuX0fE3tG7cVBivQNJqUW)gIrVHw6VHk7BCDdbOtREo6gcqDG0n0qUEGXi)BtYpEkjYqQPxxi0WhYu7YMRV5cHHWnvJKBa5cmhUCffZ1dmg5FBs(Xtjrgsn96cHg(qMAx2C9nxL9nU42xNypeNmcXaFs(TjLBa5cmhUCHMRHCjMRrTeVlPdS0jxrXCjMRrTe3ID6ilYiFUII5smxJAjUwWklYiFUcZvyUqZ1dmg5FBs(Xtjrgsn96cHgoiAUqZDalkIhie)BtYpEkjYqQPxxi0WjykyJIsi3qa6il1KUHidPMs)TZjJQZjXX49VNCWfE3qQuphHCH)nKn9ttR3qpWyKBFDIQZXhkoKvG65OCHMRHCTOKZjFDGqVLBFDIQZLRV5cJCffZ1NChWII4bcX)2K8JNsImKA61fcnCcMc2OOesUcZfAUgY1NChWII4bcXDWY0rTYOJOVlisiU2e1sCcMc2OOesUII5(TjL7HZnWNLRX56bgJC7RtuDo(qMAx2Cdi3dYv4nuzFJRBO91jQo39VNaJl8UHuPEoc5c)BiB6NMwVHdyrr8aH4FBs(Xtjrgsn96cHgobtbBuucjxO5ArjNt(6aHEl3(6evNlxJpMlmYfAUgY1NC9aJr(3MKF8usKHutVUqOHdIMl0C9aJrU91jQohFO4qwbQNJYvumxd5cqNw9Cehzi1u6VDozuDojogZfAUgY1dmg52xNO6C8Hm1US56BUWixrXCTOKZjFDGqVLBFDIQZLRX5EqUqZ9vhvp3(KZPJez64ZPs9CesUqZ1dmg52xNO6C8Hm1US56BUNLRWCfMRWBOY(gx3q7RtuDU7FpjWx4DdPs9CeYf(3qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHQ9h1jrX(PjxJZnyboxywUgYfoGZ9q56bgJ8Vnj)4PKidPMEDHqd3(kdOCfMlmlxd56bgJC7RtuDo(qMAx2CpuUWi3tZ1IsoNuGAFkxH5cZY1qUi4NhbhyL4OKCGfXhYu7YM7HY9SCfMl0C9aJrU91jQohhe9gcqhzPM0n0(6evNt6hxVmQoNehJ3)EYzx4DdPs9CeYf(3q20pnTEdbOtREoIJmKAk93oNmQoNehJ5cnxa60QNJ42xNO6Cs)46Lr15K4y8gQSVX1n0(6ybhi09VNy0x4DdPs9CeYf(3qL9nUUHwWk2dDdzt)006nCO4qwbQNJYfAUVoqON)TjjFSePPCnox4cCUWSCTOKZjFDGqVn3aYDitTlBUqZvrLmbedOCHMlXCnQL4Dj1c2BidwMJKVoqO3EpbU7FpbMFH3nKk1Zrix4Fdv2346gQik63aiP1VoM3q20pnTEd9j3Vza1fKCHMRp5QSVXfxru0VbqsRFDmLiQPcH4DjJUgIGpxrXCrWpxru0VbqsRFDmLiQPcH42xzaLRV5cJCHMlc(5kII(nasA9RJPernvieFitTlBU(MlmUHmyzos(6aHE79e4U)9KG9cVBivQNJqUW)gQSVX1n0eJRyp0nKn9ttR3WHIdzfOEokxO5(6aHE(3MK8XsKMY14CnKlCbo3aY1qUwuY5KVoqO3YTVoXEOCpuUWXplxH5km3tZ1IsoN81bc92Cdi3Hm1US5cnxd5YWyhc2FXzQSlgFifb2CHMRHCbOtREoIZWfamqKeHSWwSCffZLHXoeS)IZWfamqK8fqslAp9B5dPiWMROyU(KlddGkTEE1qe8YOs5kmxrXCTOKZjFDGqVLBFDI9q56BUgYnW5EOCnKlC5gqUV6O65V)UKMyCz5uPEocjxH5kmxrXCnKlXCnQL4DjTyNo5kkMRHCjMRrTeVlPh(fKROyUeZ1OwI3L0bw6KRWCHMRp5(QJQNBXGojokFbKmIhY(CQuphHKROyUEGXihDAt8G0QtQdtRMjrbDwD4auhiLRXhZ9GZaoxH5cnxd5ArjNt(6aHEl3(6e7HY13CHd4CpuUgYfUCdi3xDu983FxstmUSCQuphHKRWCfMl0Cv7pQtII9ttUgN7zaNlmlxpWyKBFDIQZXhYu7YM7HY1OZvyUqZ1qU(KRhymYbQlKHqKKjk2pnMu9sQObshCIdIMROyUeZ1OwI3L0ID6KROyU(KlddGkTEoqWoTw5kmxO5QOsMaIb0nKblZrYxhi0BVNa39VNeOx4DdPs9CeYf(3q20pnTEdnKlaDA1ZrCgUaGbIKiKf2ILl0C76Pbf70NqKXgIGxoKP2LnxJZfoyaCUqZ1NCzySdb7V4mv2fJpKIaBUII56bgJCMk7IXbrZvyUqZvT)Oojk2pn56BUNbCUqZ1qUEGXiNyUg1sshyPdFitTlBUgNRrNROyUEGXiNyUg1ssl2PdFitTlBUgNBGZvyUII5gBicE5qMAx2C9nx4a(gQSVX1nKHlayGi5lGKw0E63E)7jWb8fE3qQuphHCH)nKn9ttR3qfvYeqmGUHk7BCDdJ4HrsCuw6do09VNahCx4DdPs9CeYf(3q20pnTEd9aJrotLDX4GO3qL9nUUHJcGkmOvghQcoS3)EcChCH3nKk1Zrix4Fdzt)006n0qUEGXi3(6evNJdIMROyUQ9h1jrX(PjxJZ9mGZvyUqZ1NC9aJrUf7SFZioiAUqZ1NC9aJrotLDX4GO5cnxd56tUmmaQ065vdrWlJkLROyUmm2HG9xCgUaGbIKVasAr7PFlhenxrXC76Pbf70NqKXgIGxoKP2LnxFZLHXoeS)IZWfamqK8fqslAp9B5dzQDzZnGCn6CffZTRNguStFcrgBicE5qMAx2CpCUWfSaNRV5EaW5gqUgYnW5EOCz4cbSFo6qS2ss11qktQEovQNJqYvyUcVHk7BCDdzKJSFRoP6AiLjv)9VNahmUW7gsL65iKl8VHSPFAA9gAixpWyKBFDIQZXbrZvumx1(J6KOy)0KRX5EgW5kmxO56tUEGXi3ID2VzehenxO56tUEGXiNPYUyCq0CHMRHC9jxggavA98QHi4LrLYvumxgg7qW(lodxaWarYxajTO90VLdIMROyUD90GID6tiYydrWlhYu7YMRV5YWyhc2FXz4cagis(ciPfTN(T8Hm1US5gqUgDUII521tdk2PpHiJnebVCitTlBUhox4cwGZ13CHbW5gqUgYnW5EOCz4cbSFo6qS2ss11qktQEovQNJqYvyUcVHk7BCDd7IPtPFJR7FpbUaFH3nKk1Zrix4Fdzt)006nSRNguStFcrgBicE5qMAx2C9nx4olxrXCnKRhymYrN2epiT6K6W0QzsuqNvhoa1bs56BUhCgW5kkMRhymYrN2epiT6K6W0QzsuqNvhoa1bs5A8XCp4mGZvyUqZ1dmg52xNO6CCq0CHMldJDiy)fNPYUy8Hm1US5ACUNb8nuzFJRBizII9tJ0dxi3)EcCNDH3nKk1Zrix4Fdv2346gAFY50rgD6q3q20pnTEdhkoKvG65OCHM73MK8XsKMY14CH7SCHMRfLCo5Rde6TC7RtShkxFZnW5cnxfvYeqmGYfAUgY1dmg5mv2fJpKP2LnxJZfoGZvumxFY1dmg5mv2fJdIMRWBidwMJKVoqO3EpbU7FpboJ(cVBivQNJqUW)gYM(PP1BiXCnQL4Dj1c2CHMRIkzcigq5cnxpWyKJoTjEqA1j1HPvZKOGoRoCaQdKY13Cp4mGZfAUgYfb)Cfrr)gajT(1XuIOMkeI)ndOUGKROyU(KlddGkTEErSb7WdsUII5ArjNt(6aHEBUgN7b5k8gQSVX1nmcoWkXrj5al6(3tGdMFH3nKk1Zrix4Fdzt)006n0dmg54IEbwjknmc9BCXbrZfAUgY1dmg52xNO6C8HIdzfOEokxrXCv7pQtII9ttUgNBGcCUcVHk7BCDdTVor15U)9e4c2l8UHuPEoc5c)BiB6NMwVHmmaQ065vdrWlJkLl0CnKlaDA1ZrCgUaGbIKiKf2ILROyUmm2HG9xCMk7IXbrZvumxpWyKZuzxmoiAUcZfAUmm2HG9xCgUaGbIKVasAr7PFlFitTlBU(Mlegc3unsUhkxg1UCnKRA)rDsuSFAY90Cpd4CfMl0C9aJrU91jQohFitTlBU(MBGVHk7BCDdTVor15U)9e4c0l8UHuPEoc5c)BiB6NMwVHmmaQ065vdrWlJkLl0CnKlaDA1ZrCgUaGbIKiKf2ILROyUmm2HG9xCMk7IXbrZvumxpWyKZuzxmoiAUcZfAUmm2HG9xCgUaGbIKVasAr7PFlFitTlBU(Mlegc3unsUhkxg1UCnKRA)rDsuSFAY90CHbW5kmxO56bgJC7RtuDooiAUqZLyUg1s8UKAb7nuzFJRBO91XcoqO7Fp5aGVW7gsL65iKl8VHSPFAA9g6bgJCCrVaRK5iDKaABJloiAUII5AixFY1(6e7H4kQKjGyaLROyUgY1dmg5mv2fJpKP2LnxFZ9SCHMRhymYzQSlghenxrXCnKRhymYhfavyqRmoufCy5dzQDzZ13CHWq4MQrY9q5YO2LRHCv7pQtII9ttUNMlmaoxH5cnxpWyKpkaQWGwzCOk4WYbrZvyUcZfAUa0PvphXTVor15K(X1lJQZjXXyUqZ1IsoN81bc9wU91jQoxU(MlmYvyUqZ1qU(K7awuepqi(3MKF8usKHutVUqOHtWuWgfLqYvumxlk5CYxhi0B52xNO6C56BUWixH3qL9nUUH2xhl4aHU)9KdG7cVBivQNJqUW)gYM(PP1BOHCjMRrTeVlPwWMl0CzySdb7V4mv2fJpKP2LnxJZ9mGZvumxd5YeOdeYM7XCpixO5oetGoqi53MuU(M7z5kmxrXCzc0bczZ9yUWixH5cnxfvYeqmGUHk7BCDdlYV0eJR7Fp5GdUW7gsL65iKl8VHSPFAA9gAixI5AulX7sQfS5cnxgg7qW(lotLDX4dzQDzZ14Cpd4CffZ1qUmb6aHS5Em3dYfAUdXeOdes(TjLRV5EwUcZvumxMaDGq2CpMlmYvyUqZvrLmbedOBOY(gx3qbQlknX46(3toagx4DdPs9CeYf(3q20pnTEdnKlXCnQL4Dj1c2CHMldJDiy)fNPYUy8Hm1US5ACUNbCUII5AixMaDGq2CpM7b5cn3Hyc0bcj)2KY13CplxH5kkMltGoqiBUhZfg5kmxO5QOsMaIb0nuzFJRBye05KMyCD)7jhe4l8UHk7BCDd9RZ04rIJsYbw0nKk1Zrix4F)7jhC2fE3qQuphHCH)neJEdT0Fdv2346gcqNw9C0neG6aPBOfLCo5Rde6TC7RtShkxJZnW5gqUrhgp5Aixt1(0aReG6aPCpn3daoxH5gqUrhgp5AixpWyKBFDSGdessMOy)0ys1lTyNoC7RmGY90CdCUcVHa0rwQjDdTVoXEizxsl2PZ9VNCGrFH3nKk1Zrix4Fdzt)006nKyUg1sChyPJSiJ85kkMlXCnQL4AbRSiJ85cnxa60QNJ4TvYCKcGYvumxpWyKtmxJAjPf70HpKP2LnxFZvzFJlU91j2dXjJqmWNKFBs5cnxpWyKtmxJAjPf70HdIMROyUeZ1OwI3L0ID6Kl0C9jxa60QNJ42xNypKSlPf70jxrXC9aJrotLDX4dzQDzZ13Cv234IBFDI9qCYied8j53MuUqZ1NCbOtREoI3wjZrkakxO56bgJCMk7IXhYu7YMRV5sgHyGpj)2KYfAUEGXiNPYUyCq0CffZ1dmg5JcGkmOvghQcoSCq0CHMRfLCoPa1(uUgNlWCJoxO5Aixlk5CYxhi0BZ13J5cJCffZ1NCF1r1ZTyqNehLVasgXdzFovQNJqYvyUII56tUa0PvphXBRK5ifaLl0C9aJrotLDX4dzQDzZ14CjJqmWNKFBs3qL9nUUH(h9fC)7jhaZVW7gQSVX1n0(6e7HUHuPEoc5c)7Fp5GG9cVBivQNJqUW)gQSVX1nCalPY(gxsxB)BORTVSut6ggvN7fmG3)(3WO6CVGb8cV7jWDH3nKk1Zrix4Fdzt)006n0NChWII4bcX9uNwmsIJs15KVGUGy5emfSrrjKBOY(gx3q7RJfCGq3)EYbx4DdPs9CeYf(3qL9nUUHwWk2dDdzt)006neb)CtmUI9q8Hm1US5ACUdzQDzVHmyzos(6aHE79e4U)9eyCH3nuzFJRBOjgxXEOBivQNJqUW)(3)gA)l8UNa3fE3qQuphHCH)nuzFJRBOIOOFdGKw)6yEdzt)006n0NCrWpxru0VbqsRFDmLiQPcH4FZaQli5cnxFYvzFJlUIOOFdGKw)6ykrutfcX7sgDnebFUqZ1qU(Klc(5kII(nasA9RJPuaPo(3mG6csUII5IGFUIOOFdGKw)6ykfqQJpKP2LnxJZ9SCfMROyUi4NRik63aiP1VoMse1uHqC7RmGY13CHrUqZfb)Cfrr)gajT(1XuIOMkeIpKP2LnxFZfg5cnxe8Zvef9BaK06xhtjIAQqi(3mG6cYnKblZrYxhi0BVNa39VNCWfE3qQuphHCH)nKn9ttR3qd5cqNw9CeNHlayGijczHTy5cn3UEAqXo9jezSHi4LdzQDzZ14CHdgaNl0C9jxgg7qW(lotLDX4dPiWMROyUEGXiNPYUyCq0CfMl0Cv7pQtII9ttU(M7zaNl0CnKRhymYjMRrTK0bw6WhYu7YMRX5chW5kkMRhymYjMRrTK0ID6WhYu7YMRX5chW5kmxrXCJnebVCitTlBU(MlCaFdv2346gYWfamqK8fqslAp9BV)9eyCH3nKk1Zrix4FdXO3ql93qL9nUUHa0PvphDdbOoq6gAixpWyKZuzxm(qMAx2Cno3ZYfAUgY1dmg5JcGkmOvghQcoS8Hm1US5ACUNLROyU(KRhymYhfavyqRmoufCy5GO5kmxrXC9jxpWyKZuzxmoiAUII5Q2FuNef7NMC9nxyaCUcZfAUgY1NC9aJroqDHmeIKmrX(PXKQxsfnq6GtCq0CffZvT)Oojk2pn56BUWa4CfMl0CnKRhymYjMRrTK0ID6WhYu7YMRX5cHHWnvJKROyUEGXiNyUg1sshyPdFitTlBUgNlegc3unsUcVHa0rwQjDdrWVCiykypKjvV9(3tc8fE3qQuphHCH)nuzFJRBOjgxXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLinLRX5c3b5cnxd5QOsMaIbuUqZfGoT65ioc(Ldbtb7HmP6T5k8gYGL5i5Rde6T3tG7(3to7cVBivQNJqUW)gQSVX1n0cwXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLinLRX5c3b5cnxd5QOsMaIbuUqZfGoT65ioc(Ldbtb7HmP6T5k8gYGL5i5Rde6T3tG7(3tm6l8UHuPEoc5c)BOY(gx3q7toNoYOth6gYM(PP1B4qXHScuphLl0CFDGqp)Bts(yjst5ACUWz05cnxd5QOsMaIbuUqZfGoT65ioc(Ldbtb7HmP6T5k8gYGL5i5Rde6T3tG7(3tG5x4DdPs9CeYf(3q20pnTEdvujtaXa6gQSVX1nmIhgjXrzPp4q3)EsWEH3nKk1Zrix4Fdzt)006n0dmg5mv2fJdIEdv2346gokaQWGwzCOk4WE)7jb6fE3qQuphHCH)nKn9ttR3qd5AixpWyKtmxJAjPf70HpKP2LnxJZfoGZvumxpWyKtmxJAjPdS0HpKP2LnxJZfoGZvyUqZLHXoeS)IZuzxm(qMAx2CnoxyaCUqZ1qUEGXihDAt8G0QtQdtRMjrbDwD4auhiLRV5EqGboxrXC9j3bSOiEGqC0PnXdsRoPomTAMef0z1HtWuWgfLqYvyUcZvumxpWyKJoTjEqA1j1HPvZKOGoRoCaQdKY14J5Eamh4CffZLHXoeS)IZuzxm(qkcS5cnxd5Q2FuNef7NMCno3af4CffZfGoT65iEBLkMYv4nuzFJRBizII9tJ0dxi3)EcCaFH3nKk1Zrix4Fdzt)006n0qUQ9h1jrX(PjxJZnqboxO5AixpWyKduxidHijtuSFAmP6LurdKo4ehenxrXC9jxggavA9CGGDATYvyUII5YWaOsRNxnebVmQuUII5cqNw9CeVTsft5kkMRhymY9CymId0(Cq0CHMRhymY9CymId0(8Hm1US56BUhaCUbKRHCnKBGM7HYDalkIhiehDAt8G0QtQdtRMjrbDwD4emfSrrjKCfMBa5Ai3aN7HYLHleW(5OdXAljvxdPmP65uPEocjxH5kmxH5cnxFY1dmg5mv2fJdIMl0CnKRp5YWaOsRNxnebVmQuUII5YWyhc2FXz4cagis(ciPfTN(TCq0CffZTRNguStFcrgBicE5qMAx2C9nxgg7qW(lodxaWarYxajTO90VLpKP2Ln3aY1OZvum3UEAqXo9jezSHi4LdzQDzZ9W5cxWcCU(M7baNBa5Ai3aN7HYLHleW(5OdXAljvxdPmP65uPEocjxH5k8gQSVX1nKroY(T6KQRHuMu93)EcCWDH3nKk1Zrix4Fdzt)006n0qUQ9h1jrX(PjxJZnqboxO5AixpWyKduxidHijtuSFAmP6LurdKo4ehenxrXC9jxggavA9CGGDATYvyUII5YWaOsRNxnebVmQuUII5cqNw9CeVTsft5kkMRhymY9CymId0(Cq0CHMRhymY9CymId0(8Hm1US56BUWa4Cdixd5Ai3an3dL7awuepqio60M4bPvNuhMwntIc6S6WjykyJIsi5km3aY1qUbo3dLldxiG9ZrhI1wsQUgszs1ZPs9CesUcZvyUcZfAU(KRhymYzQSlghenxO5AixFYLHbqLwpVAicEzuPCffZLHXoeS)IZWfamqK8fqslAp9B5GO5kkMBxpnOyN(eIm2qe8YHm1US56BUmm2HG9xCgUaGbIKVasAr7PFlFitTlBUbKRrNROyUD90GID6tiYydrWlhYu7YM7HZfUGf4C9nxyaCUbKRHCdCUhkxgUqa7NJoeRTKuDnKYKQNtL65iKCfMRWBOY(gx3WUy6u6346(3tG7Gl8UHuPEoc5c)Big9gAP)gQSVX1neGoT65OBia1bs3qd56tUmm2HG9xCMk7IXhsrGnxrXC9jxa60QNJ4mCbadejrilSflxO5YWaOsRNxnebVmQuUcVHa0rwQjDdTkasgXJKPYUy3)EcCW4cVBivQNJqUW)gYM(PP1BiXCnQL4Dj1c2CHMRIkzcigq5cnxpWyKJoTjEqA1j1HPvZKOGoRoCaQdKY13CpiWaNl0CnKlc(5kII(nasA9RJPernvie)BgqDbjxrXC9jxggavA98Iyd2HhKCfMl0CbOtREoIBvaKmIhjtLDXUHk7BCDdJGdSsCusoWIU)9e4c8fE3qQuphHCH)nKn9ttR3qpWyKJl6fyLO0Wi0VXfhenxO56bgJC7RtuDo(qXHScuphDdv2346gAFDIQZD)7jWD2fE3qQuphHCH)nKn9ttR3qpWyKBFDC4bHpKP2LnxFZ9SCHMRHC9aJroXCnQLKwSth(qMAx2Cno3ZYvumxpWyKtmxJAjPdS0HpKP2LnxJZ9SCfMl0Cv7pQtII9ttUgNBGc8nuzFJRBitlg5KEGX4n0dmgLLAs3q7RJdpi3)EcCg9fE3qQuphHCH)nKn9ttR3qggavA98QHi4LrLYfAUa0PvphXz4cagisIqwylwUqZLHXoeS)IZWfamqK8fqslAp9B5dzQDzZ13CHWq4MQrY9q5YO2LRHCv7pQtII9ttUNMlmaoxH3qL9nUUH2xhl4aHU)9e4G5x4DdPs9CeYf(3q20pnTEdF1r1ZTp5C6irMo(CQuphHKl0CT0)DbXYTyhwImD8ZfAU(K7RoQEU91XHheovQNJqYfAUEGXi3(6evNJpuCiRa1Zr5cnxd56bgJCI5AuljDGLo8Hm1US5ACUgDUqZLyUg1s8UKoWsNCHMRhymYrN2epiT6K6W0QzsuqNvhoa1bs56BUhCgW5kkMRhymYrN2epiT6K6W0QzsuqNvhoa1bs5A8XCp4mGZfAUQ9h1jrX(PjxJZnqboxrXCrWpxru0VbqsRFDmLiQPcH4dzQDzZ14Cd2CffZvzFJlUIOOFdGKw)6ykrutfcX7sgDnebFUcZfAU(KldJDiy)fNPYUy8HueyVHk7BCDdTVor15U)9e4c2l8UHuPEoc5c)BiB6NMwVHEGXihx0lWkzoshjG224IdIMROyUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUII56bgJCMk7IXbrZfAUgY1dmg5JcGkmOvghQcoS8Hm1US56BUqyiCt1i5EOCzu7Y1qUQ9h1jrX(Pj3tZfgaNRWCHMRhymYhfavyqRmoufCy5GO5kkMRp56bgJ8rbqfg0kJdvbhwoiAUqZ1NCzySdb7V4JcGkmOvghQcoS8HueyZvumxFYLHbqLwphavVayNCfMROyUQ9h1jrX(PjxJZnqboxO5smxJAjExsTG9gQSVX1n0(6ybhi09VNaxGEH3nKk1Zrix4Fdzt)006n8vhvp3(64WdcNk1Zri5cnxd56bgJC7RJdpiCq0CffZvT)Oojk2pn5ACUbkW5kmxO56bgJC7RJdpiC7RmGY13CHrUqZ1qUEGXiNyUg1ssl2PdhenxrXC9aJroXCnQLKoWshoiAUcZfAUEGXihDAt8G0QtQdtRMjrbDwD4auhiLRV5Eamh4CHMRHCzySdb7V4mv2fJpKP2LnxJZfoGZvumxFYfGoT65iodxaWarseYcBXYfAUmmaQ065vdrWlJkLRWBOY(gx3q7RJfCGq3)EYbaFH3nKk1Zrix4Fdzt)006n0qUEGXihDAt8G0QtQdtRMjrbDwD4auhiLRV5Eamh4CffZ1dmg5OtBIhKwDsDyA1mjkOZQdhG6aPC9n3dod4CHM7RoQEU9jNthjY0XNtL65iKCfMl0C9aJroXCnQLKwSth(qMAx2CnoxyEUqZLyUg1s8UKwStNCHMRp56bgJCCrVaReLggH(nU4GO5cnxFY9vhvp3(64WdcNk1Zri5cnxgg7qW(lotLDX4dzQDzZ14CH55cnxd5YWyhc2FXbQlKHqKw0E63YhYu7YMRX5cZZvumxFYLHbqLwphiyNwRCfEdv2346gAFDSGde6(3toaUl8UHuPEoc5c)BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5kkMRHCzc0bczZ9yUhKl0ChIjqhiK8BtkxFZ9SCfMROyUmb6aHS5EmxyKRWCHMRIkzcigq5cnxa60QNJ4wfajJ4rYuzxSBOY(gx3WI8lnX46(3to4Gl8UHuPEoc5c)BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5cnxFYLHbqLwphiyNwRCffZ1qUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUqZLHbqLwphiyNwRCfMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCHrUII56bgJCMk7IXbrZvyUqZvrLmbedOCHMlaDA1ZrCRcGKr8izQSl2nuzFJRBOa1fLMyCD)7jhaJl8UHuPEoc5c)BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5cnxFYLHbqLwphiyNwRCffZ1qUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUqZLHbqLwphiyNwRCfMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCHrUII56bgJCMk7IXbrZvyUqZvrLmbedOCHMlaDA1ZrCRcGKr8izQSl2nuzFJRBye05KMyCD)7jhe4l8UHk7BCDd9RZ04rIJsYbw0nKk1Zrix4F)7jhC2fE3qQuphHCH)nKn9ttR3qI5AulX7s6alDYvumxI5AulXTyNoYImYNROyUeZ1OwIRfSYImYNROyUEGXi3VotJhjokjhyrCq0CHMRhymYjMRrTK0bw6WbrZvumxd56bgJCMk7IXhYu7YMRV5QSVXf3)OVaozeIb(K8BtkxO56bgJCMk7IXbrZv4nuzFJRBO91j2dD)7jhy0x4Ddv2346g6F0xWnKk1Zrix4F)7jhaZVW7gsL65iKl8VHk7BCDdhWsQSVXL012)g6A7ll1KUHr15Ebd49V)nezi10RleAUW7EcCx4DdPs9CeYf(3qm6n0s)nuzFJRBiaDA1Zr3qaQdKUHgY1dmg5FBs(Xtjrgsn96cHg(qMAx2CnoximeUPAKCdixG5WLl0CnKlXCnQL4Dj9WVGCffZLyUg1s8UKwStNCffZLyUg1sChyPJSiJ85kmxrXC9aJr(3MKF8usKHutVUqOHpKP2LnxJZvzFJlU91j2dXjJqmWNKFBs5gqUaZHlxO5AixI5AulX7s6alDYvumxI5AulXTyNoYImYNROyUeZ1OwIRfSYImYNRWCfMROyU(KRhymY)2K8JNsImKA61fcnCq0BiaDKLAs3qRgj5JLGwsArjN7(3to4cVBivQNJqUW)gYM(PP1BOHC9jxa60QNJ4wnsYhlbTK0IsoxUII5AixpWyKpkaQWGwzCOk4WYhYu7YMRV5cHHWnvJK7HYLrTlxd5Q2FuNef7NMCpnxyaCUcZfAUEGXiFuauHbTY4qvWHLdIMRWCfMROyUQ9h1jrX(PjxJZnqb(gQSVX1n0(6ybhi09VNaJl8UHuPEoc5c)BiB6NMwVHgYfGoT65iodxaWarseYcBXYfAUD90GID6tiYydrWlhYu7YMRX5chmaoxO56tUmm2HG9xCMk7IXhsrGnxrXC9aJrotLDX4GO5kmxO5Q2FuNef7NMC9n3adCUqZ1qUEGXiNyUg1sshyPdFitTlBUgNlCaNROyUEGXiNyUg1ssl2PdFitTlBUgNlCaNRWCffZn2qe8YHm1US56BUWb8nuzFJRBidxaWarYxajTO90V9(3tc8fE3qQuphHCH)nuzFJRBOIOOFdGKw)6yEdzt)006n0NCrWpxru0VbqsRFDmLiQPcH4FZaQli5cnxFYvzFJlUIOOFdGKw)6ykrutfcX7sgDnebFUqZ1qU(Klc(5kII(nasA9RJPuaPo(3mG6csUII5IGFUIOOFdGKw)6ykfqQJpKP2LnxJZ9SCfMROyUi4NRik63aiP1VoMse1uHqC7RmGY13CHrUqZfb)Cfrr)gajT(1XuIOMkeIpKP2LnxFZfg5cnxe8Zvef9BaK06xhtjIAQqi(3mG6cYnKblZrYxhi0BVNa39VNC2fE3qQuphHCH)nuzFJRBOjgxXEOBiB6NMwVHdfhYkq9CuUqZ91bc98Vnj5JLinLRX5c3b5cnxd5AixpWyKZuzxm(qMAx2Cno3ZYfAUgY1dmg5JcGkmOvghQcoS8Hm1US5ACUNLROyU(KRhymYhfavyqRmoufCy5GO5kmxrXC9jxpWyKZuzxmoiAUII5Q2FuNef7NMC9nxyaCUcZfAUgY1NC9aJroqDHmeIKmrX(PXKQxsfnq6GtCq0CffZvT)Oojk2pn56BUWa4CfMl0CvujtaXakxH3qgSmhjFDGqV9EcC3)EIrFH3nKk1Zrix4Fdv2346gAbRyp0nKn9ttR3WHIdzfOEokxO5(6aHE(3MK8XsKMY14CH7GCHMRHCnKRhymYzQSlgFitTlBUgN7z5cnxd56bgJ8rbqfg0kJdvbhw(qMAx2Cno3ZYvumxFY1dmg5JcGkmOvghQcoSCq0CfMROyU(KRhymYzQSlghenxrXCv7pQtII9ttU(MlmaoxH5cnxd56tUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUII5Q2FuNef7NMC9nxyaCUcZfAUkQKjGyaLRWBidwMJKVoqO3EpbU7FpbMFH3nKk1Zrix4Fdv2346gAFY50rgD6q3q20pnTEdhkoKvG65OCHM7Rde65FBsYhlrAkxJZfoJoxO5Aixd56bgJCMk7IXhYu7YMRX5EwUqZ1qUEGXiFuauHbTY4qvWHLpKP2LnxJZ9SCffZ1NC9aJr(OaOcdALXHQGdlhenxH5kkMRp56bgJCMk7IXbrZvumx1(J6KOy)0KRV5cdGZvyUqZ1qU(KRhymYbQlKHqKKjk2pnMu9sQObshCIdIMROyUQ9h1jrX(PjxFZfgaNRWCHMRIkzcigq5k8gYGL5i5Rde6T3tG7(3tc2l8UHuPEoc5c)BiB6NMwVHkQKjGyaDdv2346ggXdJK4OS0hCO7FpjqVW7gsL65iKl8VHSPFAA9g6bgJCMk7IXbrVHk7BCDdhfavyqRmoufCyV)9e4a(cVBivQNJqUW)gYM(PP1BOHCnKRhymYjMRrTK0ID6WhYu7YMRX5chW5kkMRhymYjMRrTK0bw6WhYu7YMRX5chW5kmxO5YWyhc2FXzQSlgFitTlBUgNlmaoxH5kkMldJDiy)fNPYUy8HueyVHk7BCDdbQlKHqKw0E63E)7jWb3fE3qQuphHCH)nKn9ttR3qd5AixpWyKduxidHijtuSFAmP6LurdKo4ehenxrXC9jxggavA9CGGDATYvyUII5YWaOsRNxnebVmQuUII5cqNw9CeVTsft5kkMRhymY9CymId0(Cq0CHMRhymY9CymId0(8Hm1US56BUhaCUbKRHCdCUhkxgUqa7NJoeRTKuDnKYKQNtL65iKCfMRWCHMRp56bgJCMk7IXbrZfAUgY1NCzyauP1ZRgIGxgvkxrXCzySdb7V4mCbadejFbK0I2t)woiAUII521tdk2PpHiJnebVCitTlBU(MldJDiy)fNHlayGi5lGKw0E63YhYu7YMBa5A05kkMBxpnOyN(eIm2qe8YHm1US5E4CHlyboxFZ9aGZnGCnKBGZ9q5YWfcy)C0HyTLKQRHuMu9CQuphHKRWCfEdv2346gYihz)wDs11qktQ(7FpbUdUW7gsL65iKl8VHSPFAA9gAixd56bgJCG6cziejzII9tJjvVKkAG0bN4GO5kkMRp5YWaOsRNdeStRvUcZvumxggavA98QHi4LrLYvumxa60QNJ4TvQykxrXC9aJrUNdJrCG2NdIMl0C9aJrUNdJrCG2NpKP2LnxFZfgaNBa5Ai3aN7HYLHleW(5OdXAljvxdPmP65uPEocjxH5kmxO56tUEGXiNPYUyCq0CHMRHC9jxggavA98QHi4LrLYvumxgg7qW(lodxaWarYxajTO90VLdIMROyUD90GID6tiYydrWlhYu7YMRV5YWyhc2FXz4cagis(ciPfTN(T8Hm1US5gqUgDUII521tdk2PpHiJnebVCitTlBUhox4cwGZ13CHbW5gqUgYnW5EOCz4cbSFo6qS2ss11qktQEovQNJqYvyUcVHk7BCDd7IPtPFJR7FpboyCH3nKk1Zrix4FdXO3ql93qL9nUUHa0PvphDdbOoq6gAixFYLHXoeS)IZuzxm(qkcS5kkMRp5cqNw9CeNHlayGijczHTy5cnxggavA98QHi4LrLYv4neGoYsnPBOvbqYiEKmv2f7(3tGlWx4DdPs9CeYf(3q20pnTEdjMRrTeVlPwWMl0CvujtaXakxO5Aixe8Zvef9BaK06xhtjIAQqi(3mG6csUII56tUmmaQ065fXgSdpi5kmxO5cqNw9Ce3QaizepsMk7IDdv2346ggbhyL4OKCGfD)7jWD2fE3qQuphHCH)nKn9ttR3qggavA98QHi4LrLYfAUa0PvphXz4cagisIqwylwUqZvT)Oojk2pn5A8XCdmW5cnxgg7qW(lodxaWarYxajTO90VLpKP2LnxFZfcdHBQgj3dLlJAxUgYvT)Oojk2pn5EAUWa4CfEdv2346gAFDSGde6(3tGZOVW7gsL65iKl8VHSPFAA9gAixpWyKtmxJAjPdS0HdIMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCHrUcZfAUkQKjGyaLl0CbOtREoIBvaKmIhjtLDXUHk7BCDdlYV0eJR7Fpboy(fE3qQuphHCH)nKn9ttR3qd56bgJCI5AuljDGLoCq0CHMRp5YWaOsRNdeStRvUII5AixpWyKduxidHijtuSFAmP6LurdKo4ehenxO5YWaOsRNdeStRvUcZvumxd5YeOdeYM7XCpixO5oetGoqi53MuU(M7z5kmxrXCzc0bczZ9yUWixrXC9aJrotLDX4GO5kmxO5QOsMaIbuUqZfGoT65iUvbqYiEKmv2f7gQSVX1nuG6IstmUU)9e4c2l8UHuPEoc5c)BiB6NMwVHgY1dmg5eZ1Ows6alD4GO5cnxFYLHbqLwphiyNwRCffZ1qUEGXihOUqgcrsMOy)0ys1lPIgiDWjoiAUqZLHbqLwphiyNwRCfMROyUgYLjqhiKn3J5EqUqZDiMaDGqYVnPC9n3ZYvyUII5YeOdeYM7XCHrUII56bgJCMk7IXbrZvyUqZvrLmbedOCHMlaDA1ZrCRcGKr8izQSl2nuzFJRBye05KMyCD)7jWfOx4Ddv2346g6xNPXJehLKdSOBivQNJqUW)(3toa4l8UHuPEoc5c)BiB6NMwVHeZ1OwI3L0bw6KROyUeZ1OwIBXoDKfzKpxrXCjMRrTexlyLfzKpxrXC9aJrUFDMgpsCusoWI4GO5cnxpWyKtmxJAjPdS0HdIMROyUgY1dmg5mv2fJpKP2LnxFZvzFJlU)rFbCYied8j53MuUqZ1dmg5mv2fJdIMRWBOY(gx3q7RtSh6(3toaUl8UHk7BCDd9p6l4gsL65iKl8V)9Kdo4cVBivQNJqUW)gQSVX1nCalPY(gxsxB)BORTVSut6ggvN7fmG3)(3)gcGgBJR7jha8badhCheO3q)6uDbXEdHjgMSrLtmQEcmrgLCZfEcOCBtu885gXtUWKqgsn96cHgys5oemfShcjxl2KYvbFSP(esUmbAbHS8mOGPlk3dmk5gi4canpHKByBgi5AHTE1i5E4CFCUbdOMlsdOTnUYfJsJ(4jxdNkmxdWzeH8mOGPlkx4GZOKBGGla08esUHTzGKRf26vJK7HpCUpo3GbuZ1eJa6aT5IrPrF8KRHdlmxdWzeH8mOGPlkx4oWOKBGGla08esUHTzGKRf26vJK7HpCUpo3GbuZ1eJa6aT5IrPrF8KRHdlmxdWzeH8mOGPlkx4oZOKBGGla08esUHTzGKRf26vJK7HZ9X5gmGAUinG224kxmkn6JNCnCQWCnaNreYZGYGGjgMSrLtmQEcmrgLCZfEcOCBtu885gXtUWKqhIHn90hMuUdbtb7HqY1InPCvWhBQpHKltGwqilpdky6IY1Onk5gi4canpHKByBgi5AHTE1i5E4CFCUbdOMlsdOTnUYfJsJ(4jxdNkmxdhyeH8mOmiyIHjBu5eJQNatKrj3CHNak32efpFUr8KlmjftWKYDiykypesUwSjLRc(yt9jKCzc0ccz5zqbtxuUhyuYnqWfaAEcj3W2mqY1cB9QrY9Who3hNBWaQ5AIraDG2CXO0OpEY1WHfMRb4mIqEguW0fLBGnk5gi4canpHKByBgi5AHTE1i5E4CFCUbdOMlsdOTnUYfJsJ(4jxdNkmxdWzeH8mOGPlk3G1OKBGGla08esUHTzGKRf26vJK7HZ9X5gmGAUinG224kxmkn6JNCnCQWCnaNreYZGcMUOCH7aJsUbcUaqZti5g2MbsUwyRxnsUh(W5(4CdgqnxtmcOd0MlgLg9XtUgoSWCnaNreYZGcMUOCHdggLCdeCbGMNqYnSndKCTWwVAKCp8HZ9X5gmGAUMyeqhOnxmkn6JNCnCyH5AaoJiKNbfmDr5cxWAuYnqWfaAEcj3W2mqY1cB9QrY9W5(4CdgqnxKgqBBCLlgLg9XtUgovyUgGZic5zqbtxuUWfOgLCdeCbGMNqYnSndKCTWwVAKCpCUpo3GbuZfPb02gx5IrPrF8KRHtfMRb4mIqEguW0fL7baBuYnqWfaAEcj3W2mqY1cB9QrY9W5(4CdgqnxKgqBBCLlgLg9XtUgovyUgGZic5zqbtxuUhCMrj3abxaO5jKCdBZajxlS1Rgj3dN7JZnya1CrAaTTXvUyuA0hp5A4uH5A4aJiKNbLbbtmmzJkNyu9eyImk5Ml8eq52MO45ZnINCHjzFys5oemfShcjxl2KYvbFSP(esUmbAbHS8mOGPlkx4a2OKBGGla08esUHTzGKRf26vJK7HpCUpo3GbuZ1eJa6aT5IrPrF8KRHdlmxdWzeH8mOGPlkx4GZOKBGGla08esUHTzGKRf26vJK7HpCUpo3GbuZ1eJa6aT5IrPrF8KRHdlmxdWzeH8mOGPlkx4mAJsUbcUaqZti5g2MbsUwyRxnsUho3hNBWaQ5I0aABJRCXO0OpEY1WPcZ1aCgripdky6IYfUG1OKBGGla08esUHTzGKRf26vJK7HZ9X5gmGAUinG224kxmkn6JNCnCQWCnaNreYZGYGGjgMSrLtmQEcmrgLCZfEcOCBtu885gXtUWK8W6dtk3HGPG9qi5AXMuUk4Jn1NqYLjqliKLNbfmDr5EGrj3abxaO5jKCdBZajxlS1Rgj3dN7JZnya1CrAaTTXvUyuA0hp5A4uH5A4aJiKNbfmDr5c3zgLCdeCbGMNqYnSndKCTWwVAKCp8HZ9X5gmGAUMyeqhOnxmkn6JNCnCyH5AaoJiKNbfmDr5cxWAuYnqWfaAEcj3W2mqY1cB9QrY9W5(4CdgqnxKgqBBCLlgLg9XtUgovyUgGHreYZGcMUOCHlqnk5gi4canpHKByBgi5AHTE1i5E4CFCUbdOMlsdOTnUYfJsJ(4jxdNkmxdWzeH8mOmiJQMO45jKCH55QSVXvUU2(wEg0n0IsS7jWb8b3q0bhBhDdnQZf(QtlgLlmHgWgjdYOoxycrmY0JMCH78Cpa4daodkdYOo3arGwqiRrjdYOoxywUWKrqiKCdXoDYf(KAYZGmQZfMLBGiqliesUVoqOx2XCzQLS5(4CzWYCK81bc9wEgKrDUWSCnQqMyaesUGvrmYA1b2CbOtREoYMRHMt8ZZfDias7RJfCGq5cZmox0HaWTVowWbcjKNbLbPSVXLLJoedB6P)rtmUaQlzepMzqk7BCz5OdXWME6hWXtbQlKHqKw0E63MbPSVXLLJoedB6PFahp1)OVGZDDrsgYr4aodszFJllhDig20t)aoEQ)rFbN3XJOdbGdh3)OVaO(Goea(bC)J(cYGu234YYrhIHn90pGJNAFDI9qzqk7BCz5OdXWME6hWXtbOtREo68snPJmCbadejrilSf7CaQdKo6HTwOrhgpgmeBicE5qMAxwy2bal8WWDaWcno6W4XGHydrWlhYu7YcZo4myMb4a(qV6O65DX0P0VXfNk1ZricHzgc8Hy4cbSFo6qS2ss11qktQEovQNJqek8WWfSalmdkdYOoxycBeIb(esUeaAGn3VnPCFbuUk7XtUTnxfG2o1Zr8miL9nUShTyNospsnZGu234YgWXtbOtREo68snPJTvQy6CaQdKoArjNt(6aHEl3(6evNZy4GAWNxDu9C7RJdpiCQuphHik(QJQNBFY50rImD85uPEocrOOOfLCo5Rde6TC7RtuDoJpidszFJlBahpfGoT65OZl1Ko2wjZrka6CaQdKoArjNt(6aHEl3(6e7HmgUmiL9nUSbC8upAS0auxqoVJhn4dddGkTEE1qe8YOsII(WWyhc2FXz4cagis(ciPfTN(TCquHq9aJrotLDX4GOzqk7BCzd44PO4VX15D8OhymYzQSlghendszFJlBahpf0sY(jtBgKY(gx2aoEQasNxswlvm68oE0raiNVNbxgKY(gx2aoE6awsL9nUKU2(NxQjDuX052FA2FeUZ74ra60QNJ4TvQykdszFJlBahpDalPY(gxsxB)Zl1KoImKA61fcnNB)Pz)r4oVJhhWII4bcX)2K8JNsImKA61fcnCcMc2OOesgKY(gx2aoE6awsL9nUKU2(NxQjD0dR)52FA2FeUZ74XbSOiEGqCp1PfJK4OuDo5lOliwobtbBuucjdszFJlBahpDalPY(gxsxB)Zl1KoA)mOmiL9nUSCfthbOtREo68snPJidPMs)TZjJQZjXX45auhiD0GhymY)2K8JNsImKA61fcn8Hm1US(cHHWnvJeaWC4ef9aJr(3MKF8usKHutVUqOHpKP2L1xL9nU42xNypeNmcXaFs(TjfaWC4GAGyUg1s8UKoWshrrI5AulXTyNoYImYlksmxJAjUwWklYiVqHq9aJr(3MKF8usKHutVUqOHdIcDalkIhie)BtYpEkjYqQPxxi0WjykyJIsizqk7BCz5kMc44P2xNO6CN3XJEGXi3(6evNJpuCiRa1ZrqnyrjNt(6aHEl3(6evNZxyik6Zawuepqi(3MKF8usKHutVUqOHtWuWgfLqec1Gpdyrr8aH4oyz6Owz0r03fejexBIAjobtbBuucru8Bt6WhoWNzShymYTVor154dzQDzd4aHzqk7BCz5kMc44P2xNO6CN3XJdyrr8aH4FBs(Xtjrgsn96cHgobtbBuucbQfLCo5Rde6TC7RtuDoJpcdOg8Xdmg5FBs(Xtjrgsn96cHgoikupWyKBFDIQZXhkoKvG65irrda0PvphXrgsnL(BNtgvNtIJrOg8aJrU91jQohFitTlRVWqu0IsoN81bc9wU91jQoNXha9vhvp3(KZPJez64ZPs9CecupWyKBFDIQZXhYu7Y67zcfkmdszFJllxXuahpfGoT65OZl1KoAFDIQZj9JRxgvNtIJXZbOoq6OA)rDsuSFAmoybgMzaoGpKhymY)2K8JNsImKA61fcnC7RmGecZm4bgJC7RtuDo(qMAx2dbJdBrjNtkqTpjeMzab)8i4aRehLKdSi(qMAx2dDMqOEGXi3(6evNJdIMbPSVXLLRykGJNAFDSGde68oEeGoT65ioYqQP0F7CYO6CsCmcfGoT65iU91jQoN0pUEzuDojogZGu234YYvmfWXtTGvSh6CgSmhjFDGqV9iCN3XJdfhYkq9Ce0xhi0Z)2KKpwI0KXWfyyMfLCo5Rde6TbmKP2LfQIkzcigqqjMRrTeVlPwWMbPSVXLLRykGJNQik63aiP1VoMNZGL5i5Rde6ThH78oE0NVza1feO(OSVXfxru0VbqsRFDmLiQPcH4DjJUgIGxueb)Cfrr)gajT(1XuIOMkeIBFLbKVWakc(5kII(nasA9RJPernvieFitTlRVWidszFJllxXuahp1eJRyp05myzos(6aHE7r4oVJhhkoKvG65iOVoqON)TjjFSePjJnaxGdWGfLCo5Rde6TC7RtSh6qWXptOWdBrjNt(6aHEBadzQDzHAGHXoeS)IZuzxm(qkcSqnaqNw9CeNHlayGijczHTyIImm2HG9xCgUaGbIKVasAr7PFlFifbwrrFyyauP1ZRgIGxgvsOOOfLCo5Rde6TC7RtShYxdb(qgGlGxDu983FxstmUSCQuphHiuOOObI5AulX7sAXoDefnqmxJAjExsp8lquKyUg1s8UKoWshHq95vhvp3IbDsCu(cizepK95uPEocru0dmg5OtBIhKwDsDyA1mjkOZQdhG6ajJpEWzaleQblk5CYxhi0B52xNypKVWb8HmaxaV6O65V)UKMyCz5uPEocrOqOQ9h1jrX(PX4ZagM5bgJC7RtuDo(qMAx2dz0cHAWhpWyKduxidHijtuSFAmP6LurdKo4ehevuKyUg1s8UKwSthrrFyyauP1Zbc2P1siufvYeqmGYGu234YYvmfWXtz4cagis(ciPfTN(TN3XJgaOtREoIZWfamqKeHSWwmOD90GID6tiYydrWlhYu7YAmCWayO(WWyhc2FXzQSlgFifbwrrpWyKZuzxmoiQqOQ9h1jrX(PX3ZagQbpWyKtmxJAjPdS0HpKP2L1yJwu0dmg5eZ1OwsAXoD4dzQDznoWcffJnebVCitTlRVWbCgKY(gxwUIPaoEAepmsIJYsFWHoVJhvujtaXakdszFJllxXuahpDuauHbTY4qvWH98oE0dmg5mv2fJdIMbPSVXLLRykGJNYihz)wDs11qktQ(Z74rdEGXi3(6evNJdIkkQ2FuNef7NgJpdyHq9Xdmg5wSZ(nJ4GOq9Xdmg5mv2fJdIc1GpmmaQ065vdrWlJkjkYWyhc2FXz4cagis(ciPfTN(TCqurXUEAqXo9jezSHi4LdzQDz9LHXoeS)IZWfamqK8fqslAp9B5dzQDzdWOff76Pbf70NqKXgIGxoKP2L9WhgUGfyFpa4ame4dXWfcy)C0HyTLKQRHuMu9CQuphHiuygKY(gxwUIPaoEAxmDk9BCDEhpAWdmg52xNO6CCqurr1(J6KOy)0y8zaleQpEGXi3ID2VzehefQpEGXiNPYUyCquOg8HHbqLwpVAicEzujrrgg7qW(lodxaWarYxajTO90VLdIkk21tdk2PpHiJnebVCitTlRVmm2HG9xCgUaGbIKVasAr7PFlFitTlBagTOyxpnOyN(eIm2qe8YHm1USh(WWfSa7lmaoadb(qmCHa2phDiwBjP6AiLjvpNk1ZricfMbPSVXLLRykGJNsMOy)0i9WfY5D8yxpnOyN(eIm2qe8YHm1US(c3zIIg8aJro60M4bPvNuhMwntIc6S6WbOoqY3dodyrrpWyKJoTjEqA1j1HPvZKOGoRoCaQdKm(4bNbSqOEGXi3(6evNJdIcLHXoeS)IZuzxm(qMAxwJpd4miL9nUSCftbC8u7toNoYOth6CgSmhjFDGqV9iCN3XJdfhYkq9Ce0Vnj5JLinzmCNb1IsoN81bc9wU91j2d5BGHQOsMaIbeudEGXiNPYUy8Hm1USgdhWII(4bgJCMk7IXbrfMbPSVXLLRykGJNgbhyL4OKCGfDEhpsmxJAjExsTGfQIkzcigqq9aJro60M4bPvNuhMwntIc6S6WbOoqY3dodyOgqWpxru0VbqsRFDmLiQPcH4FZaQliII(WWaOsRNxeBWo8GikArjNt(6aHERXhimdszFJllxXuahp1(6evN78oE0dmg54IEbwjknmc9BCXbrHAWdmg52xNO6C8HIdzfOEosuuT)Oojk2pnghOalmdszFJllxXuahp1(6evN78oEKHbqLwpVAicEzujOgaOtREoIZWfamqKeHSWwmrrgg7qW(lotLDX4GOIIEGXiNPYUyCquHqzySdb7V4mCbadejFbK0I2t)w(qMAxwFHWq4MQroeJANb1(J6KOy)0C4ZawiupWyKBFDIQZXhYu7Y6BGZGu234YYvmfWXtTVowWbcDEhpYWaOsRNxnebVmQeuda0PvphXz4cagisIqwylMOidJDiy)fNPYUyCqurrpWyKZuzxmoiQqOmm2HG9xCgUaGbIKVasAr7PFlFitTlRVqyiCt1ihIrTZGA)rDsuSFAommawiupWyKBFDIQZXbrHsmxJAjExsTGndszFJllxXuahp1(6ybhi05D8OhymYXf9cSsMJ0rcOTnU4GOIIg8X(6e7H4kQKjGyajkAWdmg5mv2fJpKP2L13ZG6bgJCMk7IXbrffn4bgJ8rbqfg0kJdvbhw(qMAxwFHWq4MQroeJANb1(J6KOy)0CyyaSqOEGXiFuauHbTY4qvWHLdIkuiua60QNJ42xNO6Cs)46Lr15K4yeQfLCo5Rde6TC7RtuDoFHHqOg8zalkIhie)BtYpEkjYqQPxxi0WjykyJIsiIIwuY5KVoqO3YTVor158fgcZGu234YYvmfWXtlYV0eJRZ74rdeZ1OwI3LulyHYWyhc2FXzQSlgFitTlRXNbSOObMaDGq2JhaDiMaDGqYVnjFptOOitGoqi7ryieQIkzcigqzqk7BCz5kMc44PcuxuAIX15D8ObI5AulX7sQfSqzySdb7V4mv2fJpKP2L14Zawu0atGoqi7XdGoetGoqi53MKVNjuuKjqhiK9imecvrLmbedOmiL9nUSCftbC80iOZjnX468oE0aXCnQL4Dj1cwOmm2HG9xCMk7IXhYu7YA8zalkAGjqhiK94bqhIjqhiK8BtY3ZekkYeOdeYEegcHQOsMaIbugKY(gxwUIPaoEQFDMgpsCusoWIYGu234YYvmfWXtbOtREo68snPJ2xNypKSlPf705CaQdKoArjNt(6aHEl3(6e7HmoWbeDy8yWuTpnWkbOoq6WhaSWaIomEm4bgJC7RJfCGqsYef7NgtQEPf70HBFLb0HdSWmiL9nUSCftbC8u)J(coVJhjMRrTe3bw6ilYiVOiXCnQL4AbRSiJ8qbOtREoI3wjZrkasu0dmg5eZ1OwsAXoD4dzQDz9vzFJlU91j2dXjJqmWNKFBsq9aJroXCnQLKwSthoiQOiXCnQL4DjTyNoq9bGoT65iU91j2dj7sAXoDef9aJrotLDX4dzQDz9vzFJlU91j2dXjJqmWNKFBsq9bGoT65iEBLmhPaiOEGXiNPYUy8Hm1US(sgHyGpj)2KG6bgJCMk7IXbrff9aJr(OaOcdALXHQGdlhefQfLCoPa1(KXaZnAOgSOKZjFDGqV13JWqu0NxDu9Clg0jXr5lGKr8q2NtL65ieHII(aqNw9CeVTsMJuaeupWyKZuzxm(qMAxwJjJqmWNKFBszqk7BCz5kMc44P2xNypugKY(gxwUIPaoE6awsL9nUKU2(NxQjDmQo3lyaZGYGu234YY9W6FCuauHbTY4qvWH98oE0dmg5mv2fJdIMbPSVXLL7H1pGJNcqNw9C05LAshz4cagisIqwyl25auhiDm6W4XGHUEAqXo9jezSHi4LdzQDzHzhaSWdd3bal04OdJhdg66Pbf70NqKXgIGxoKP2LfMDWzWmdWb8HE1r1Z7IPtPFJlovQNJqecZme4dXWfcy)C0HyTLKQRHuMu9CQuphHiu4HHlybwygKY(gxwUhw)aoEkaDA1ZrNxQjDKn9x4he9CaQdKo6JhymY9uNwmsIJs15KVGUGyLL(GdXbrH6JhymY9uNwmsIJs15KVGUGyL6W0I4GOzqk7BCz5Ey9d44PkII(nasA9RJ55myzos(6aHE7r4oVJh9aJrUN60IrsCuQoN8f0feRS0hCiU9vgqsaQdK8nWad1dmg5EQtlgjXrP6CYxqxqSsDyArC7RmGKauhi5BGbgQbFqWpxru0VbqsRFDmLiQPcH4FZaQliq9rzFJlUIOOFdGKw)6ykrutfcX7sgDnebpud(GGFUIOOFdGKw)6ykfqQJ)ndOUGikIGFUIOOFdGKw)6ykfqQJpKP2L1yyiuueb)Cfrr)gajT(1XuIOMkeIBFLbKVWakc(5kII(nasA9RJPernvieFitTlRVNbfb)Cfrr)gajT(1XuIOMkeI)ndOUGimdszFJll3dRFahpLHlayGi5lGKw0E63EEhpAaGoT65iodxaWarseYcBXG21tdk2PpHiJnebVCitTlRXWbdGH6ddJDiy)fNPYUy8Hueyff9aJrotLDX4GOcHAWdmg5EQtlgjXrP6CYxqxqSYsFWH42xzajbOoq64zalk6bgJCp1PfJK4OuDo5lOliwPomTiU9vgqsaQdKoEgWcffJnebVCitTlRVWbCgKY(gxwUhw)aoEktlg5KEGX45LAshTVoo8GCEhpAWdmg5EQtlgjXrP6CYxqxqSYsFWH4dzQDznoW8Zef9aJrUN60IrsCuQoN8f0feRuhMweFitTlRXbMFMqOQ9h1jrX(PX4JbkWqnWWyhc2FXzQSlgFitTlRXWCrrdmm2HG9xCYef7NgPhUq4dzQDzngMd1hpWyKduxidHijtuSFAmP6LurdKo4ehefkddGkTEoqWoTwcfMbPSVXLL7H1pGJNAFDSGde68oE0ha60QNJ4SP)c)GOqnWWaOsRNxnebVmQKOidJDiy)fNPYUy8Hm1USgdZffnWWyhc2FXjtuSFAKE4cHpKP2L1yyouF8aJroqDHmeIKmrX(PXKQxsfnq6GtCquOmmaQ065ab70AjuygKY(gxwUhw)aoEQ91XcoqOZ74rdmm2HG9xCgUaGbIKVasAr7PFlhefQba60QNJ4mCbadejrilSftuKHXoeS)IZuzxm(qMAxwFptOqOQ9h1jrX(PX4ZagkddGkTEE1qe8YOszqk7BCz5Ey9d44PwWk2dDodwMJKVoqO3EeUZ74XHIdzfOEoc6Rde65FBsYhlrAYy4mAOguujtaXacQba60QNJ4SP)c)GOIIgu7pQtII9tJVWayO(4bgJCMk7IXbrfkkYWyhc2FXzQSlgFifbwHcZGu234YY9W6hWXtnX4k2dDodwMJKVoqO3EeUZ74XHIdzfOEoc6Rde65FBsYhlrAYy4Gb)mOguujtaXacQba60QNJ4SP)c)GOIIgu7pQtII9tJVWayO(4bgJCMk7IXbrfkkYWyhc2FXzQSlgFifbwHq9Xdmg5a1fYqisYef7NgtQEjv0aPdoXbrfMbPSVXLL7H1pGJNAFY50rgD6qNZGL5i5Rde6ThH78oECO4qwbQNJG(6aHE(3MK8XsKMmgoJoGHm1USqnOOsMaIbeuda0PvphXzt)f(brffv7pQtII9tJVWayrrgg7qW(lotLDX4dPiWkuygKY(gxwUhw)aoEAepmsIJYsFWHoVJhvujtaXakdszFJll3dRFahpncoWkXrj5al68oE0aXCnQL4Dj1cwrrI5AulXTyNoYUKWjksmxJAjUdS0r2LeoHqn4dddGkTEE1qe8YOsIIgu7pQtII9tJVb6zqnaqNw9CeNn9x4hevuuT)Oojk2pn(cdGffbOtREoI3wPIjHqnaqNw9CeNHlayGijczHTyq9HHXoeS)IZWfamqK8fqslAp9B5GOII(aqNw9CeNHlayGijczHTyq9HHXoeS)IZuzxmoiQqHcHAGHXoeS)IZuzxm(qMAxwJHbWIIQ9h1jrX(PX4afyOmm2HG9xCMk7IXbrHAGHXoeS)ItMOy)0i9WfcFitTlRVk7BCXTVoXEiozeIb(K8Btsu0hggavA9CGGDATekk21tdk2PpHiJnebVCitTlRVWbSqOgqWpxru0VbqsRFDmLiQPcH4dzQDznoWII(WWaOsRNxeBWo8GimdszFJll3dRFahpfOUqgcrAr7PF75D8ObI5AulXDGLoYImYlksmxJAjUf70rwKrErrI5AulX1cwzrg5ff9aJrUN60IrsCuQoN8f0feRS0hCi(qMAxwJdm)mrrpWyK7PoTyKehLQZjFbDbXk1HPfXhYu7YACG5NjkQ2FuNef7NgJduGHYWyhc2FXzQSlgFifbwHqnWWyhc2FXzQSlgFitTlRXWayrrgg7qW(lotLDX4dPiWkuuSRNguStFcrgBicE5qMAxwFHd4miL9nUSCpS(bC8ug5i73QtQUgszs1FEhpAqT)Oojk2pnghOad1GhymYbQlKHqKKjk2pnMu9sQObshCIdIkk6dddGkTEoqWoTwcffzyauP1ZRgIGxgvsu0dmg5EomgXbAFoikupWyK75WyehO95dzQDz99aGdWqGpedxiG9ZrhI1wsQUgszs1ZPs9CeIqHqn4dddGkTEE1qe8YOsIImm2HG9xCgUaGbIKVasAr7PFlhevuSRNguStFcrgBicE5qMAxwFzySdb7V4mCbadejFbK0I2t)w(qMAx2amArXUEAqXo9jezSHi4LdzQDzp8HHlyb23daoadb(qmCHa2phDiwBjP6AiLjvpNk1ZricfMbPSVXLL7H1pGJN2ftNs)gxN3XJgu7pQtII9tJXbkWqn4bgJCG6cziejzII9tJjvVKkAG0bN4GOII(WWaOsRNdeStRLqrrggavA98QHi4LrLef9aJrUNdJrCG2NdIc1dmg5EomgXbAF(qMAxwFHbWbyiWhIHleW(5OdXAljvxdPmP65uPEocrOqOg8HHbqLwpVAicEzujrrgg7qW(lodxaWarYxajTO90VLdIkkcqNw9CeNHlayGijczHTyq76Pbf70NqKXgIGxoKP2L1y4cwGd4aGdWqGpedxiG9ZrhI1wsQUgszs1ZPs9CeIqrXUEAqXo9jezSHi4LdzQDz9LHXoeS)IZWfamqK8fqslAp9B5dzQDzdWOff76Pbf70NqKXgIGxoKP2L1xyaCagc8Hy4cbSFo6qS2ss11qktQEovQNJqekmdszFJll3dRFahp1(6ybhi05D8iddGkTEE1qe8YOsqnaqNw9CeNHlayGijczHTyIImm2HG9xCMk7IXhYu7Y6lCaleQA)rDsuSFAm(mGHYWyhc2FXz4cagis(ciPfTN(T8Hm1US(chWzqk7BCz5Ey9d44Pa0PvphDEPM0r1IctanHe7CaQdKosmxJAjExshyPZHc2dRSVXf3(6e7H4Krig4tYVnPa8HyUg1s8UKoWsNdz0hwzFJlU)rFbCYied8j53MuaaZp4WwuY5Kcu7tzqk7BCz5Ey9d44P2xhl4aHoVJhn01tdk2PpHiJnebVCitTlRVbwu0GhymYhfavyqRmoufCy5dzQDz9fcdHBQg5qmQDgu7pQtII9tZHHbWcH6bgJ8rbqfg0kJdvbhwoiQqHIIgu7pQtII9ttaa0PvphXvlkmb0esSd5bgJCI5AuljTyNo8Hm1USbGGFEeCGvIJsYbwe)Bgqw5qMAxh6a(zgd3balkQ2FuNef7NMaaOtREoIRwuycOjKyhYdmg5eZ1Ows6alD4dzQDzdab)8i4aRehLKdSi(3mGSYHm1Uo0b8ZmgUdawiuI5AulX7sQfSqnyWhgg7qW(lotLDX4GOIImmaQ065ab70Ab1hgg7qW(lozII9tJ0dxiCquHIImmaQ065vdrWlJkjeQbFyyauP1Zbq1la2ru0hpWyKZuzxmoiQOOA)rDsuSFAmoqbwOOOhymYzQSlgFitTlRXbluF8aJr(OaOcdALXHQGdlhendszFJll3dRFahpTi)stmUoVJhn4bgJCI5AuljDGLoCqurrdmb6aHShpa6qmb6aHKFBs(EMqrrMaDGq2JWqiufvYeqmGYGu234YY9W6hWXtfOUO0eJRZ74rdEGXiNyUg1sshyPdhevu0atGoqi7XdGoetGoqi53MKVNjuuKjqhiK9imecvrLmbedOmiL9nUSCpS(bC80iOZjnX468oE0GhymYjMRrTK0bw6WbrffnWeOdeYE8aOdXeOdes(Tj57zcffzc0bczpcdHqvujtaXakdszFJll3dRFahp1VotJhjokjhyrzqk7BCz5Ey9d44P2xNyp05D8iXCnQL4DjDGLoIIeZ1OwIBXoDKfzKxuKyUg1sCTGvwKrErrpWyK7xNPXJehLKdSioikuI5AulX7s6alDefn4bgJCMk7IXhYu7Y6RY(gxC)J(c4Krig4tYVnjOEGXiNPYUyCquHzqk7BCz5Ey9d44P(h9fKbPSVXLL7H1pGJNoGLuzFJlPRT)5LAshJQZ9cgWmOmiL9nUSCKHutVUqO5iaDA1ZrNxQjD0Qrs(yjOLKwuY5ohG6aPJg8aJr(3MKF8usKHutVUqOHpKP2L1yimeUPAKaaMdhudeZ1OwI3L0d)cefjMRrTeVlPf70ruKyUg1sChyPJSiJ8cff9aJr(3MKF8usKHutVUqOHpKP2L1yL9nU42xNypeNmcXaFs(TjfaWC4GAGyUg1s8UKoWshrrI5AulXTyNoYImYlksmxJAjUwWklYiVqHII(4bgJ8Vnj)4PKidPMEDHqdhendszFJllhzi10RleAc44P2xhl4aHoVJhn4daDA1ZrCRgj5JLGwsArjNtu0GhymYhfavyqRmoufCy5dzQDz9fcdHBQg5qmQDgu7pQtII9tZHHbWcH6bgJ8rbqfg0kJdvbhwoiQqHIIQ9h1jrX(PX4af4miL9nUSCKHutVUqOjGJNYWfamqK8fqslAp9BpVJhnaqNw9CeNHlayGijczHTyq76Pbf70NqKXgIGxoKP2L1y4GbWq9HHXoeS)IZuzxm(qkcSIIEGXiNPYUyCquHqv7pQtII9tJVbgyOg8aJroXCnQLKoWsh(qMAxwJHdyrrpWyKtmxJAjPf70HpKP2L1y4awOOySHi4LdzQDz9foGZGu234YYrgsn96cHMaoEQIOOFdGKw)6yEodwMJKVoqO3EeUZ74rFqWpxru0VbqsRFDmLiQPcH4FZaQliq9rzFJlUIOOFdGKw)6ykrutfcX7sgDnebpud(GGFUIOOFdGKw)6ykfqQJ)ndOUGikIGFUIOOFdGKw)6ykfqQJpKP2L14ZekkIGFUIOOFdGKw)6ykrutfcXTVYaYxyafb)Cfrr)gajT(1XuIOMkeIpKP2L1xyafb)Cfrr)gajT(1XuIOMkeI)ndOUGKbPSVXLLJmKA61fcnbC8utmUI9qNZGL5i5Rde6ThH78oECO4qwbQNJG(6aHE(3MK8XsKMmgUdGAWGhymYzQSlgFitTlRXNb1GhymYhfavyqRmoufCy5dzQDzn(mrrF8aJr(OaOcdALXHQGdlhevOOOpEGXiNPYUyCqurr1(J6KOy)04lmawiud(4bgJCG6cziejzII9tJjvVKkAG0bN4GOIIQ9h1jrX(PXxyaSqOkQKjGyajmdszFJllhzi10RleAc44PwWk2dDodwMJKVoqO3EeUZ74XHIdzfOEoc6Rde65FBsYhlrAYy4oaQbdEGXiNPYUy8Hm1USgFgudEGXiFuauHbTY4qvWHLpKP2L14Zef9Xdmg5JcGkmOvghQcoSCquHII(4bgJCMk7IXbrffv7pQtII9tJVWayHqn4JhymYbQlKHqKKjk2pnMu9sQObshCIdIkkQ2FuNef7NgFHbWcHQOsMaIbKWmiL9nUSCKHutVUqOjGJNAFY50rgD6qNZGL5i5Rde6ThH78oECO4qwbQNJG(6aHE(3MK8XsKMmgoJgQbdEGXiNPYUy8Hm1USgFgudEGXiFuauHbTY4qvWHLpKP2L14Zef9Xdmg5JcGkmOvghQcoSCquHII(4bgJCMk7IXbrffv7pQtII9tJVWayHqn4JhymYbQlKHqKKjk2pnMu9sQObshCIdIkkQ2FuNef7NgFHbWcHQOsMaIbKWmiL9nUSCKHutVUqOjGJNgXdJK4OS0hCOZ74rfvYeqmGYGu234YYrgsn96cHMaoE6OaOcdALXHQGd75D8OhymYzQSlghendszFJllhzi10RleAc44Pa1fYqislAp9BpVJhnyWdmg5eZ1OwsAXoD4dzQDzngoGff9aJroXCnQLKoWsh(qMAxwJHdyHqzySdb7V4mv2fJpKP2L1yyaSqrrgg7qW(lotLDX4dPiWMbPSVXLLJmKA61fcnbC8ug5i73QtQUgszs1FEhpAWGhymYbQlKHqKKjk2pnMu9sQObshCIdIkk6dddGkTEoqWoTwcffzyauP1ZRgIGxgvsueGoT65iEBLkMef9aJrUNdJrCG2NdIc1dmg5EomgXbAF(qMAxwFpa4ame4dXWfcy)C0HyTLKQRHuMu9CQuphHiuiuF8aJrotLDX4GOqn4dddGkTEE1qe8YOsIImm2HG9xCgUaGbIKVasAr7PFlhevuSRNguStFcrgBicE5qMAxwFzySdb7V4mCbadejFbK0I2t)w(qMAx2amArXUEAqXo9jezSHi4LdzQDzp8HHlyb23daoadb(qmCHa2phDiwBjP6AiLjvpNk1ZricfMbPSVXLLJmKA61fcnbC80Uy6u63468oE0GbpWyKduxidHijtuSFAmP6LurdKo4ehevu0hggavA9CGGDATekkYWaOsRNxnebVmQKOiaDA1Zr82kvmjk6bgJCphgJ4aTphefQhymY9CymId0(8Hm1US(cdGdWqGpedxiG9ZrhI1wsQUgszs1ZPs9CeIqHq9Xdmg5mv2fJdIc1GpmmaQ065vdrWlJkjkYWyhc2FXz4cagis(ciPfTN(TCqurXUEAqXo9jezSHi4LdzQDz9LHXoeS)IZWfamqK8fqslAp9B5dzQDzdWOff76Pbf70NqKXgIGxoKP2L9WhgUGfyFHbWbyiWhIHleW(5OdXAljvxdPmP65uPEocrOWmiL9nUSCKHutVUqOjGJNcqNw9C05LAshTkasgXJKPYUyNdqDG0rd(WWyhc2FXzQSlgFifbwrrFaOtREoIZWfamqKeHSWwmOmmaQ065vdrWlJkjmdszFJllhzi10RleAc44PrWbwjokjhyrN3XJeZ1OwI3LulyHQOsMaIbeudi4NRik63aiP1VoMse1uHq8Vza1ferrFyyauP1ZlInyhEqecfGoT65iUvbqYiEKmv2fldszFJllhzi10RleAc44P2xhl4aHoVJhzyauP1ZRgIGxgvckaDA1ZrCgUaGbIKiKf2IbvT)Oojk2pngFmWadLHXoeS)IZWfamqK8fqslAp9B5dzQDz9fcdHBQg5qmQDgu7pQtII9tZHHbWcZGu234YYrgsn96cHMaoEAr(LMyCDEhpAWdmg5eZ1Ows6alD4GOIIgyc0bczpEa0Hyc0bcj)2K89mHIImb6aHShHHqOkQKjGyabfGoT65iUvbqYiEKmv2fldszFJllhzi10RleAc44PcuxuAIX15D8ObpWyKtmxJAjPdS0HdIc1hggavA9CGGDATefn4bgJCG6cziejzII9tJjvVKkAG0bN4GOqzyauP1Zbc2P1sOOObMaDGq2JhaDiMaDGqYVnjFptOOitGoqi7ryik6bgJCMk7IXbrfcvrLmbediOa0PvphXTkasgXJKPYUyzqk7BCz5idPMEDHqtahpnc6CstmUoVJhn4bgJCI5AuljDGLoCquO(WWaOsRNdeStRLOObpWyKduxidHijtuSFAmP6LurdKo4ehefkddGkTEoqWoTwcffnWeOdeYE8aOdXeOdes(Tj57zcffzc0bczpcdrrpWyKZuzxmoiQqOkQKjGyabfGoT65iUvbqYiEKmv2fldszFJllhzi10RleAc44P(1zA8iXrj5alkdszFJllhzi10RleAc44P2xNyp05D8iXCnQL4DjDGLoIIeZ1OwIBXoDKfzKxuKyUg1sCTGvwKrErrpWyK7xNPXJehLKdSioikupWyKtmxJAjPdS0HdIkkAWdmg5mv2fJpKP2L1xL9nU4(h9fWjJqmWNKFBsq9aJrotLDX4GOcZGu234YYrgsn96cHMaoEQ)rFbzqk7BCz5idPMEDHqtahpDalPY(gxsxB)Zl1KogvN7fmGzqzqk7BCz5r15Ebd4r7RJfCGqN3XJ(mGffXdeI7PoTyKehLQZjFbDbXYjykyJIsizqk7BCz5r15Ebdyahp1cwXEOZzWYCK81bc92JWDEhpIGFUjgxXEi(qMAxwJhYu7YMbPSVXLLhvN7fmGbC8utmUI9qzqzqk7BCz52)OIOOFdGKw)6yEodwMJKVoqO3EeUZ74rFqWpxru0VbqsRFDmLiQPcH4FZaQliq9rzFJlUIOOFdGKw)6ykrutfcX7sgDnebpud(GGFUIOOFdGKw)6ykfqQJ)ndOUGikIGFUIOOFdGKw)6ykfqQJpKP2L14ZekkIGFUIOOFdGKw)6ykrutfcXTVYaYxyafb)Cfrr)gajT(1XuIOMkeIpKP2L1xyafb)Cfrr)gajT(1XuIOMkeI)ndOUGKbPSVXLLB)aoEkdxaWarYxajTO90V98oE0aaDA1ZrCgUaGbIKiKf2IbTRNguStFcrgBicE5qMAxwJHdgad1hgg7qW(lotLDX4dPiWkk6bgJCMk7IXbrfcvT)Oojk2pn(EgWqn4bgJCI5AuljDGLo8Hm1USgdhWIIEGXiNyUg1ssl2PdFitTlRXWbSqrXydrWlhYu7Y6lCaNbPSVXLLB)aoEkaDA1ZrNxQjDeb)YHGPG9qMu92ZbOoq6ObpWyKZuzxm(qMAxwJpdQbpWyKpkaQWGwzCOk4WYhYu7YA8zII(4bgJ8rbqfg0kJdvbhwoiQqrrF8aJrotLDX4GOIIQ9h1jrX(PXxyaSqOg8Xdmg5a1fYqisYef7NgtQEjv0aPdoXbrffv7pQtII9tJVWayHqn4bgJCI5AuljTyNo8Hm1USgdHHWnvJik6bgJCI5AuljDGLo8Hm1USgdHHWnvJimdszFJll3(bC8utmUI9qNZGL5i5Rde6ThH78oECO4qwbQNJG(6aHE(3MK8XsKMmgUdGAqrLmbediOa0PvphXrWVCiykypKjvVvygKY(gxwU9d44PwWk2dDodwMJKVoqO3EeUZ74XHIdzfOEoc6Rde65FBsYhlrAYy4oaQbfvYeqmGGcqNw9Cehb)YHGPG9qMu9wHzqk7BCz52pGJNAFY50rgD6qNZGL5i5Rde6ThH78oECO4qwbQNJG(6aHE(3MK8XsKMmgoJgQbfvYeqmGGcqNw9Cehb)YHGPG9qMu9wHzqk7BCz52pGJNgXdJK4OS0hCOZ74rfvYeqmGYGu234YYTFahpDuauHbTY4qvWH98oE0dmg5mv2fJdIMbPSVXLLB)aoEkzII9tJ0dxiN3XJgm4bgJCI5AuljTyNo8Hm1USgdhWIIEGXiNyUg1sshyPdFitTlRXWbSqOmm2HG9xCMk7IXhYu7YAmmagQbpWyKJoTjEqA1j1HPvZKOGoRoCaQdK89GadSOOpdyrr8aH4OtBIhKwDsDyA1mjkOZQdNGPGnkkHiuOOOhymYrN2epiT6K6W0QzsuqNvhoa1bsgF8ayoWIImm2HG9xCMk7IXhsrGfQb1(J6KOy)0yCGcSOiaDA1Zr82kvmjmdszFJll3(bC8ug5i73QtQUgszs1FEhpAqT)Oojk2pnghOad1GhymYbQlKHqKKjk2pnMu9sQObshCIdIkk6dddGkTEoqWoTwcffzyauP1ZRgIGxgvsueGoT65iEBLkMef9aJrUNdJrCG2NdIc1dmg5EomgXbAF(qMAxwFpa4amyiqp0awuepqio60M4bPvNuhMwntIc6S6WjykyJIsicdWqGpedxiG9ZrhI1wsQUgszs1ZPs9CeIqHcH6JhymYzQSlghefQbFyyauP1ZRgIGxgvsuKHXoeS)IZWfamqK8fqslAp9B5GOIID90GID6tiYydrWlhYu7Y6ldJDiy)fNHlayGi5lGKw0E63YhYu7YgGrlk21tdk2PpHiJnebVCitTl7HpmCblW(EaWbyiWhIHleW(5OdXAljvxdPmP65uPEocrOWmiL9nUSC7hWXt7IPtPFJRZ74rdQ9h1jrX(PX4afyOg8aJroqDHmeIKmrX(PXKQxsfnq6GtCqurrFyyauP1Zbc2P1sOOiddGkTEE1qe8YOsIIa0PvphXBRuXKOOhymY9CymId0(CquOEGXi3ZHXioq7ZhYu7Y6lmaoadgc0dnGffXdeIJoTjEqA1j1HPvZKOGoRoCcMc2OOeIWame4dXWfcy)C0HyTLKQRHuMu9CQuphHiuOqO(4bgJCMk7IXbrHAWhggavA98QHi4LrLefzySdb7V4mCbadejFbK0I2t)woiQOyxpnOyN(eIm2qe8YHm1US(YWyhc2FXz4cagis(ciPfTN(T8Hm1USby0IID90GID6tiYydrWlhYu7YE4ddxWcSVWa4ame4dXWfcy)C0HyTLKQRHuMu9CQuphHiuygKY(gxwU9d44Pa0PvphDEPM0rRcGKr8izQSl25auhiD0Gpmm2HG9xCMk7IXhsrGvu0ha60QNJ4mCbadejrilSfdkddGkTEE1qe8YOscZGu234YYTFahpncoWkXrj5al68oEKyUg1s8UKAblufvYeqmGG6bgJC0PnXdsRoPomTAMef0z1HdqDGKVheyGHAab)Cfrr)gajT(1XuIOMkeI)ndOUGik6dddGkTEErSb7WdIqOa0PvphXTkasgXJKPYUyzqk7BCz52pGJNAFDIQZDEhp6bgJCCrVaReLggH(nU4GOq9aJrU91jQohFO4qwbQNJYGu234YYTFahpLPfJCspWy88snPJ2xhhEqoVJh9aJrU91XHhe(qMAxwFpdQbpWyKtmxJAjPf70HpKP2L14Zef9aJroXCnQLKoWsh(qMAxwJptiu1(J6KOy)0yCGcCgKY(gxwU9d44P2xhl4aHoVJhzyauP1ZRgIGxgvckaDA1ZrCgUaGbIKiKf2IbLHXoeS)IZWfamqK8fqslAp9B5dzQDz9fcdHBQg5qmQDgu7pQtII9tZHHbWcZGu234YYTFahp1(6evN78oE8vhvp3(KZPJez64ZPs9Cecul9FxqSCl2HLithFO(8QJQNBFDC4bHtL65ieOEGXi3(6evNJpuCiRa1Zrqn4bgJCI5AuljDGLo8Hm1USgB0qjMRrTeVlPdS0bQhymYrN2epiT6K6W0QzsuqNvhoa1bs(EWzalk6bgJC0PnXdsRoPomTAMef0z1HdqDGKXhp4mGHQ2FuNef7NgJduGffrWpxru0VbqsRFDmLiQPcH4dzQDznoyffv234IRik63aiP1VoMse1uHq8UKrxdrWleQpmm2HG9xCMk7IXhsrGndszFJll3(bC8u7RJfCGqN3XJEGXihx0lWkzoshjG224IdIkk6bgJCG6cziejzII9tJjvVKkAG0bN4GOIIEGXiNPYUyCquOg8aJr(OaOcdALXHQGdlFitTlRVqyiCt1ihIrTZGA)rDsuSFAommawiupWyKpkaQWGwzCOk4WYbrff9Xdmg5JcGkmOvghQcoSCquO(WWyhc2FXhfavyqRmoufCy5dPiWkk6dddGkTEoaQEbWocffv7pQtII9tJXbkWqjMRrTeVlPwWMbPSVXLLB)aoEQ91XcoqOZ74XxDu9C7RJdpiCQuphHa1GhymYTVoo8GWbrffv7pQtII9tJXbkWcH6bgJC7RJdpiC7RmG8fgqn4bgJCI5AuljTyNoCqurrpWyKtmxJAjPdS0HdIkeQhymYrN2epiT6K6W0QzsuqNvhoa1bs(EamhyOgyySdb7V4mv2fJpKP2L1y4awu0ha60QNJ4mCbadejrilSfdkddGkTEE1qe8YOscZGu234YYTFahp1(6ybhi05D8ObpWyKJoTjEqA1j1HPvZKOGoRoCaQdK89ayoWIIEGXihDAt8G0QtQdtRMjrbDwD4auhi57bNbm0xDu9C7toNosKPJpNk1ZricH6bgJCI5AuljTyNo8Hm1USgdZHsmxJAjExsl2PduF8aJroUOxGvIsdJq)gxCquO(8QJQNBFDC4bHtL65ieOmm2HG9xCMk7IXhYu7YAmmhQbgg7qW(loqDHmeI0I2t)w(qMAxwJH5II(WWaOsRNdeStRLWmiL9nUSC7hWXtlYV0eJRZ74rdEGXiNyUg1sshyPdhevu0atGoqi7XdGoetGoqi53MKVNjuuKjqhiK9imecvrLmbediOa0PvphXTkasgXJKPYUyzqk7BCz52pGJNkqDrPjgxN3XJg8aJroXCnQLKoWshoikuFyyauP1Zbc2P1su0GhymYbQlKHqKKjk2pnMu9sQObshCIdIcLHbqLwphiyNwlHIIgyc0bczpEa0Hyc0bcj)2K89mHIImb6aHShHHOOhymYzQSlgheviufvYeqmGGcqNw9Ce3QaizepsMk7ILbPSVXLLB)aoEAe05KMyCDEhpAWdmg5eZ1Ows6alD4GOq9HHbqLwphiyNwlrrdEGXihOUqgcrsMOy)0ys1lPIgiDWjoikuggavA9CGGDATekkAGjqhiK94bqhIjqhiK8BtY3ZekkYeOdeYEegIIEGXiNPYUyCquHqvujtaXackaDA1ZrCRcGKr8izQSlwgKY(gxwU9d44P(1zA8iXrj5alkdszFJll3(bC8u7RtSh68oEKyUg1s8UKoWshrrI5AulXTyNoYImYlksmxJAjUwWklYiVOOhymY9RZ04rIJsYbwehefQhymYjMRrTK0bw6Wbrffn4bgJCMk7IXhYu7Y6RY(gxC)J(c4Krig4tYVnjOEGXiNPYUyCquHzqk7BCz52pGJN6F0xqgKY(gxwU9d44Pdyjv234s6A7FEPM0XO6CVGb8(3)Eb]] )


end