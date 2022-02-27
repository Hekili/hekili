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
            debuff = true,

            last = function ()
                local app = state.debuff.fury_of_elune_ap.applied
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
        high_winds = 5383, -- 200931
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        owlkin_adept = 5407, -- 354541
        protector_of_the_grove = 3728, -- 209730
        star_burst = 3058, -- 356517
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
            duration = 15,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 15,
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
        owlkin_frenzy = {
            id = 157228,
            duration = 10,
            max_stack = function () return pvptalent.owlkin_adept.enabled and 2 or 1 end,
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
            duration = 8,
            max_stack = 1,
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
        ca_inc = {},
        --[[
            alias = { "incarnation", "celestial_alignment" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            -- duration = function () return talent.incarnation.enabled and 30 or 20 end,
        }, ]]

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
            id = 33786,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        high_winds = {
            id = 200931,
            duration = 4,
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
            id = 305497,
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
            duration = 8,
            max_stack = 8
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 8,
            max_stack = 8,
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

    --[[ This is intended to cause an AP reset on entering an encounter, but it's not working. 
        spec:RegisterHook( "start_combat", function( action )
        if boss and astral_power.current > 50 then
            spend( astral_power.current - 50, "astral_power" )
        end
    end ) ]]

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
        eclipse.wrath_counter = 0
        removeBuff( "starsurge_empowerment_lunar" )
        if Hekili.ActiveDebug then Hekili:Debug( "Expire Lunar: %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
    end, state )

    local ExpireEclipseSolar = setfenv( function()
        eclipse.state = "LUNAR_NEXT"
        eclipse.reset_stacks()
        eclipse.starfire_counter = 0
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
                -- eclipse.reset_stacks()
            elseif buff.eclipse_solar.up then
                eclipse.state = "IN_SOLAR"
                -- eclipse.reset_stacks()
            elseif buff.eclipse_lunar.up then
                eclipse.state = "IN_LUNAR"
                -- eclipse.reset_stacks()
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
                applyBuff( "balance_of_all_things_arcane", nil, 8, 8 )
                applyBuff( "balance_of_all_things_nature", nil, 8, 8 )
            end

            if talent.solstice.enabled then applyBuff( "solstice" ) end

            removeBuff( "starsurge_empowerment_lunar" )
            removeBuff( "starsurge_empowerment_solar" )

            applyBuff( "eclipse_lunar", ( duration or class.auras.eclipse_lunar.duration ) + buff.eclipse_lunar.remains )
            if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
            applyBuff( "eclipse_solar", ( duration or class.auras.eclipse_solar.duration ) + buff.eclipse_solar.remains )

            state:QueueAuraExpiration( "ca_inc", ExpireCelestialAlignment, buff.ca_inc.expires )
            state:RemoveAuraExpiration( "eclipse_solar" )
            state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
            state:RemoveAuraExpiration( "eclipse_lunar" )
            state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
        end, state ),

        advance = setfenv( function()
            if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Pre): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end

            if not ( eclipse.state == "IN_SOLAR" or eclipse.state == "IN_LUNAR" or eclipse.state == "IN_BOTH" ) then           
                if eclipse.starfire_counter == 0 and ( eclipse.state == "SOLAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_solar", class.auras.eclipse_solar.duration + buff.eclipse_solar.remains )                
                    state:RemoveAuraExpiration( "eclipse_solar" )
                    state:QueueAuraExpiration( "eclipse_solar", ExpireEclipseSolar, buff.eclipse_solar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_SOLAR"
                    eclipse.starfire_counter = 0
                    eclipse.wrath_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end

                if eclipse.wrath_counter == 0 and ( eclipse.state == "LUNAR_NEXT" or eclipse.state == "ANY_NEXT" ) then
                    applyBuff( "eclipse_lunar", class.auras.eclipse_lunar.duration + buff.eclipse_lunar.remains )
                    if set_bonus.tier28_2pc > 0 then applyDebuff( "target", "fury_of_elune_ap" ) end
                    state:RemoveAuraExpiration( "eclipse_lunar" )
                    state:QueueAuraExpiration( "eclipse_lunar", ExpireEclipseLunar, buff.eclipse_lunar.expires )
                    if talent.solstice.enabled then applyBuff( "solstice" ) end
                    if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature", nil, 5, 8 ) end
                    eclipse.state = "IN_LUNAR"
                    eclipse.wrath_counter = 0
                    eclipse.starfire_counter = 2
                    if Hekili.ActiveDebug then Hekili:Debug( "Eclipse Advance (Post): %s - Starfire(%d), Wrath(%d), Solar(%.2f), Lunar(%.2f)", eclipse.state, eclipse.starfire_counter, eclipse.wrath_counter, buff.eclipse_solar.remains, buff.eclipse_lunar.remains ) end
                    return
                end
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
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif rawget( debuff, k ) ~= nil then return debuff[ k ] end
            return false
        end
    } ) )

    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandler( "wild_growth" ) end
    end, state )

    local SinfulHysteriaHandler = setfenv( function ()
        applyBuff( "ravenous_frenzy_sinful_hysteria" )
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
            rawset( buff, "ca_inc", buff.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
            rawset( buff, "ca_inc", buff.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 )
        end

        eclipse.reset()

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
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


    -- Tier 28
    spec:RegisterGear( "tier28", 188853, 188851, 188849, 188848, 188847 )
    spec:RegisterSetBonuses( "tier28_2pc", 364423, "tier28_4pc", 363497 )
    -- 2-Set - Celestial Pillar - Entering Lunar Eclipse creates a Fury of Elune at 25% effectiveness that follows your current target for 8 sec.
    -- 4-Set - Umbral Infusion - While in an Eclipse, the cost of Starsurge and Starfall is reduced by 20%.

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

                eclipse.trigger_both( 20 )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
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
            cast = function () return pvptalent.owlkin_adept.enabled and buff.owlkin_frenzy.up and 0.85 or 1.7 end,
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
            cooldown = 20,
            recharge = 20,
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
            cooldown = 20,
            recharge = 20,
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

                eclipse.trigger_both( 20 )

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
            cooldown = 20,
            recharge = 20,
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
            cooldown = function () return talent.stellar_drift.enabled and 12 or 0 end,
            gcd = "spell",

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                end

                applyBuff( "starfall" )
                if level > 53 then
                    if debuff.moonfire.up then debuff.moonfire.expires = debuff.moonfire.expires + 4 end
                    if debuff.sunfire.up then debuff.sunfire.expires = debuff.sunfire.expires + 4 end
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
                if buff.warrior_of_elune.up or buff.elunes_wrath.up or buff.owlkin_frenzy.up then return 0 end
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
                elseif buff.owlkin_frenzy.up then
                    removeStack( "owlkin_frenzy" )
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

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) * ( set_bonus.tier28_4pc > 0 and 0.8 or 1 ) end,
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
            id = 305497,
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
            -- texture = 538771,

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

            impact = function ()
                if not state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
                    eclipse.wrath_counter = eclipse.wrath_counter - 1
                    eclipse.advance()
                end
            end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if state.spec.balance and ( eclipse.state == "ANY_NEXT" or eclipse.state == "LUNAR_NEXT" ) then
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

        enhancedRecheck = true,

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


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20220226, [[dm1QHgqiPcpIcrxIciBse(eqvJcqofaTkaKxbvywuiDlkuzxu5xuGggq5yuqlte1ZOqzAqf11GQY2GksFJcOgNuP4CsLQSoPsL5bvY9KkAFav(NuPQQgOuPQkheqvleqLhcvQjsHQCrke2iuvPpcvvunsOQIYjbqzLakVuQuvzMqvv3KcvLDkI8tkuvnuOI4OsLQIwkuvrEkuMka0vbq1wLkvL(kuvHXsbyVk5VIAWKoSWIPupMQMmOUmYMvQpdsJgiNwvRwQuv41qvMnQUTiTBj)gYWPOJlvkTCfphLPRY1LY2bX3PeJxQKZtjTEaW8LQ2pXldxa4cdooALuYGLCYGLCY4uxYjNm(mg(wyNvtAHzgE8cO0cRIuAHbCbpkpTWmdRCuaVaWfgd1gpTWaDNjR7mObTdEuEY4yFQ3b9pqnB3JmiWf8O8KXH9P42GPWoqxkV7)9ZPoTdEuEYDDDlm72ZpawTSxyWXrRKsgSKtgSKtgN6so5KXz819wyr7aHMfg2NI7fgOhgMQL9cdMy(fgWf8O8KOgVP9WcWWVK90IXQOjJtnQOjdwYjlatagUbffuI1DcWmorbEyycwumepgrboksDcWmorXnOOGsWIEXaLU8Vf1hmIj6He1B1ZP8fdu6yobygNO4NOueecw0wvKNySySkkKy(WMtmrb6DKZOIAoeKm7IH1gOKOgh4e1Ciio2fdRnqjaDcWmorbEiOhwuZH8b7(cQO4htCGe93I(h4zIEGirTmOcQOgHN)MmYjaZ4e14lWJef3Occcps0dejkM5p)XeneL)3Xjrtrdj6MtD92CsuG(TOwrnrbfWf4prb9NO)jk7tB8lkc1yCRIA5pqIcCg)apakkoef3eNy3hCrbE(dTsP6mQO)bEyrz49Ma6eGzCIA8f4rIMIyNOGF)qbD5HsJVyGxuMNQyEet0W0KBv0djQnIXeD)qbDmrrf3QtaMXjkaouCIcGOusu0wuGJhGef44birboEas0GjAikZK8FWf9MVWJoNamJtuJFtQOruGEh5mQO4htCGmQO4htCGmQOyxm7FiafnnGjrtrdj6qSN)uDIEirPy4pnI6rP2XzCSlMZjaZ4ef)(DjA3VVGhcwuJi1ezHMuQor9GipEIUrJO424jAJfqj3cJ)SJTaWfgYKkAwa4kjdxa4cJQWMtWlGBH5N)O5JfgqIsE(BYihVvXKlQRt0(Erjp)nzK7RmdXJr0(Erjp)nzK7RSn6ajAFVOKN)MmYfL1CrDDIcOOje1CiiodDwM4ajAcr7quZHG4s2zzId0cl83JQfMLjoqlmyI5N38EuTWWjd5d2jAYIIFmXbs0OGfnef7IH1gOKOOsumauul)bs0KEOGorXVbjAuWIcCiGhaffnIIDXS)HefDGOXYZO1Tsk5faUWOkS5e8c4wy(5pA(yH1HOtROnAGso7GhLNYODo488b6lOmhvHnNGfTVx0oe1JGqvuNREOGU8oir77fTdrzMeNNVyGshZXUy2bNlANIAOO99I2HOxWP6CvCTHyz7GhLNCuf2Ccw0(ErbsuYZFtg5yiEm5I66eTVxuYZFtg5(kZBvmI23lk55VjJCFLTrhir77fL883KrUOSMlQRtuaxyH)EuTWyxm7FOfg)lk7Hxy4BDRKm2caxyuf2CcEbClm)8hnFSWas0oeDAfTrduYzh8O8ugTZbNNpqFbL5OkS5eSO99I2HOEeeQI6C1df0L3bjAFVODikZK488fdu6yo2fZo4Cr7uudfTVx0oe9covNRIRnelBh8O8KJQWMtWIcOOjeTdrz0LTrvJ5UNMK7MCYMEr77ffirjp)nzKJH4XKlQRt0(Erjp)nzK7RmVvXiAFVOKN)MmY9v2gDGeTVxuYZFtg5IYAUOUorbCHf(7r1cJDXS)Hwy8VOShEHHV1TscNxa4cJQWMtWlGBH5N)O5JfgqIoTI2Obk5SdEuEkJ25GZZhOVGYCuf2Ccw0eI6rqOkQZvpuqxEhKOjeLzsCE(IbkDmh7IzhCUODkQHIcOOjeTdrz0LTrvJ5UNMK7MCYM(fw4Vhvlm2fdRnqPfg)lk7Hxy4BDRBHbt7OXVfaUsYWfaUWAmkBb0ZPSpy3xqxjb2cdMy(5nVhvlSfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqIjxrkTWAvfPe8cdzUWy0TW8ZF08XcBH1yugT3zOE4vsGTWGe8gTWwymYVWmCH91rZ0mV8VxylSWFpQwymepMSnfPlmQcBobVaUfgvHnNYPiiFbDzVWGPD043cBHzIUhvlmyAhn(TW(6OzAM3kjWwyFD0mnZl)PPe8hhTscSfgKG3OmXz0cBHzj(BHbMdFlSnAYf11TscSfML4VmQYdfWwxjb2cJzT8lSfwA0vMkAGADLeylS0ORS3QNt5lgO0XwjzSfgfd3A2dk(k)7f2cJ66MihPOwDlmWwy(W8EuTWw3kPKxa4cRXOSfqpNY(GDFbDLeylSWFpQwy(GZZH)EuL5p7wyEREoLVyGshBLeylmibVrlSfMhvW)9OAHTW4p7YvKslmKjv0SWAmkJ27mup8kjWwyiZfgJUfMF(JMpwy3NsIIlrbs0KffGen83JkNLjoqoFWU89PKO4q0WFpQCSlM9pKZhSlFFkjkGlmg5xygUWGetUIuAH1Qksj4fg7M3FRKmCH91rZ0mV8Vxylmt09OAHbt7OXVfgvHnNGxa3cJQWMt5ueKVGUSxyW0oA8BHTWGjMFEZ7r1cBH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wyB0KlQRBLeylmlXFzuLhkGTUscSfgZA5xylS0ORmv0a16kjWwyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvsgBbGlSgJYwa9Ck7d29f0vsGTWc)9OAHbjMpS50cZB1ZP8fdu6yRKaBH5rf8FpQwylmiXKRiLwyplhiAHHmxym6wy(5pA(yHTWAmkJ27mup8kjWwyqcEJwymtIZZxmqPJ5yxm7GZffCIAOOjefir7q0l4uDo2fdhnWoQcBoblAFVOxWP6CSJ48yYWZVphvHnNGffqr77fLzsCE(IbkDmh7IzhCUOGt0KxymYVWmCH91rZ0mV8VxylmyI5N38EuTWWOJjkWJmcrrLOgdhIA5pqO2jk887t0OGf1YFGef7IHJgyrJcw0KXHOOdenwEgTWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRKW5faUWAmkBb0ZPSpy3xqxjb2cl83JQfgKy(WMtlmVvpNYxmqPJTscSfMhvW)9OAHTWGetUIuAH9SSNtbeAHHmxym6wy(5pA(yHTWAmkJ27mup8kjWwyqcEJwymtIZZxmqPJ5yxm7FirbNOgUWyKFHz4c7RJMPzE5FVWwyWeZpV59OAHHrhtupNciKOwarLOyxm7Fir9rjkO)enzCi6fdu6yIAb07bj6ZeDiobjQt0nAe9arIAeE(BYirpKO2KOMdTPziyrJcwulGEpir3pNtJOhsuFWUfgvHnNGxa3cJQWMt5ueKVGUSxyW0oA8BHTWmr3JQfgmTJg)wyFD0mnZBLeylSVoAMM5L)0uc(JJwjb2cdsWBuM4mAHTWSe)TWaZHVf2gn5I66wjb2cZs8xgv5HcyRRKaBHXSw(f2cln6ktfnqTUscSfwA0v2B1ZP8fdu6yRKm2cJIHBn7bfFL)9cBHrDDtKJuuRUfgylmFyEpQwyRBLe(wa4cRXOSfqpNY(GDFbDLeylSWFpQwyqI5dBoTW8w9CkFXaLo2kjWwyEub)3JQf2cdsm5ksPf2xzOE4fgYCHXOBH5N)O5Jf2cRXOmAVZq9WRKaBHbj4nAHzoeKmupSZqxkcv7Fir77f1CiizOEyNHowR2)qI23lQ5qqYq9WodDSlgwBGsI23lQ5qqYq9WodDSlMDW5I23lQ5qqYq9WodD72ynJ2zI3ks0(ErnhcIBciuHAS8EOcaSkAFVO2T925J8xE3qPXxmr7uu72E78r(lVdUnX9Os0(ErHeZh2CY9SCGOfgJ8lmdxyFD0mnZl)7f2cdMy(5nVhvlSUVX8HnNe9afNOEqKhpMO)wuROMOXqI(LOHOq9WIEirdiOhw0dejk7VwCpQe1ciAirdrV5l8Otu68I(mrBmcw0Ve1MolevI6d2Xwyuf2CcEbClmQcBoLtrq(c6YEHbt7OXVf2cZeDpQwyW0oA8BH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wyB0KlQRBLeylmlXFzuLhkGTUscSfgZA5xylS0ORmv0a16kjWwyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvs40faUWAmkBb0ZPSpy3xqxjb2cl83JQfMnnmAW7lOlmVvpNYxmqPJTscSfMhvW)9OAHTWGetUIuAH1Qksj4fgYCHXOBH5N)O5JfgqIcKODiQhbHQOox9qbD5DqI23lAhI6riomYs58OcccpkFGOmZ8N)yUMPO99IoTI2Obk58eNy3h8mZ8N)yoQcBoblkGIMqu72E78r(lVBO04lMOGtudXNOje1UT3UjGqfQXY7HkaWQBO04lMO4suCw0eI2HOEeeQI6CqO6azDeTVxupccvrDoiuDGSoIMqu72E78r(lVRzkAcrTB7TBciuHAS8EOcaS6AMIMquGe1UT3UjGqfQXY7HkaWQBO04lMO4QtrnmzrnorXzrbirNwrB0aLCSV2nEgKv2rZhoQcBoblAFVO2T925J8xE3qPXxmrXLOgAOO99IAOOguuMjX5zqb7irXLOg6WPIcOOakAcrHeZh2CY9vgQhEH1yugT3zOE4vsGTWGe8gTWwymYVWmCH91rZ0mV8VxylmyI5N38EuTWa4msuGJggn49furJt0dejkvWII2IIFhQaaRIAbevIckyhj6ZenSrqirXPGzGmQOX(OruCJkii8irJcwu0bIglpJe1YFGef3aVbbyLFHrvyZj4fWTWOkS5uofb5lOl7fgmTJg)wylmt09OAHbt7OXVf2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHTrtUOUUvsGTWSe)LrvEOa26kjWwymRLFHTWsJUYurduRRKaBHLgDL9w9CkFXaLo2kjJTWOy4wZEqXx5FVWwyux3e5if1QBHb2cZhM3JQf26wjzGxa4cRXOSfqpNY(GDFbDLeylSWFpQwyMO7r1cZB1ZP8fdu6yRKaBH5rf8FpQwylmiXKRiLwyTQIucEHHmxym6wy(5pA(yHbKO2T925J8xE3qPXxmrbNOgIprtikqI2HOtROnAGso2x7gpdYk7O5dhvHnNGfTVxu72E7MacvOglVhQaaRUHsJVyIIlrnS7jAcrTB7TBciuHAS8EOcaS6AMIcOO99IAJymrti6(Hc6YdLgFXefxIMm(efqrtikKy(WMtUVYq9WlSgJYO9od1dVscSfgKG3Of2cJr(fMHlSVoAMM5L)9cBHbtm)8M3JQfgobDIA5pqIgIIBG3GaSYl6bkorFwb(t0quCsJZIruZb5ffnIAbevIEGir3puqNOpt0Wg1orpKOubVWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRK6MfaUWAmkBb0ZPSpy3xqxjb2cl83JQfgKy(WMtlmVvpNYxmqPJTscSfMhvW)9OAHTWGetUIuAH5rfeeEugMywl)cdzUWy0TW8ZF08XcBH1yugT3zOE4vsGTWGe8gTW80Zffirbs09df0Lhkn(IjQXjQH4tuJtupcXHrwkNpYF5DdLgFXefqrnOOg2nGjkGI2POE65IcKOaj6(Hc6YdLgFXe14e1q8jQXjQhH4WilLZJkii8O8bIYmZF(J5GBtCpQe14e1JqCyKLY5rfeeEu(arzM5p)XCdLgFXefqrnOOg2nGjkGIMq0oeDIhotqO6CbmmZrD9SJjAcrbs0oe1JqCyKLY5J8xE3qbSvr77fTdr9iehgzPCEubbHh5gkGTkkGI23lQhH4WilLZh5V8UHsJVyIcor)6OXeXJJGZ7hkOlpuA8ft0(ErNwrB0aLCEItS7dEMz(ZFmhvHnNGfnHOEeIdJSuoFK)Y7gkn(Ijk4e1yGjAFVOEeIdJSuopQGGWJYhikZm)5pMBO04lMOGt0VoAmr84i48(Hc6YdLgFXe14e1qWeTVx0oe1JGqvuNREOGU8oOfgJ8lmdxyFD0mnZl)7f2cdMy(5nVhvlmChCFJhhXe1ci6arJOn2xqff3Occcps0czrulpNlAW5ilIAf1e9qIYUNZf1hSt0dejklsjrJuuRorrBrXnQGGWJWbUbEdcWkVO(GDSfgvHnNGxa3cJQWMt5ueKVGUSxyW0oA8BHTWmr3JQfgmTJg)wyFD0mnZBLeylSVoAMM5L)0uc(JJwjb2cdsWBuM4mAHTWSe)TWaZHVf2gn5I66wjb2cZs8xgv5HcyRRKaBHXSw(f2cln6ktfnqTUscSfwA0v2B1ZP8fdu6yRKm2cJIHBn7bfFL)9cBHrDDtKJuuRUfgylmFyEpQwyRBLu3BbGlSgJYwa9Ck7d29f0vsGTWc)9OAHbjMpS50cZB1ZP8fdu6yRKaBH5rf8FpQwylmiXKRiLwyE4ShvW)9OAHHmxym6wy(5pA(yHTWAmkJ27mup8kjWwyqcEJwyaj6fdu6C3Ns5dLHFsuWjQH4t0(ErN4HZeeQoxadZCFjk4efFGjkGIMquGefirPUT9MMeSJsnTouWZObUIYtIMquGeTdr9iiuf15Gq1bY6iAFVOEeIdJSuok106qbpJg4kkp5gkn(IjkUe1qCQbwuCikqIIprbirNwrB0aLCSV2nEgKv2rZhoQcBoblkGIcOOjeTdr9iehgzPCuQP1HcEgnWvuEYnuaBvuafTVxuQBBVPjb7yOgNt39f080STkAcrbs0oe1JGqvuNREOGU8oir77f1JqCyKLYXqnoNU7lO5PzBnBmCgFDdyg6gkn(IjkUe1qdXzrbu0(ErbsupcXHrwkNnnmAW7lOUHcyRI23lAhIoHNC3G4Cr77f1JGqvuNREOGU8oirbu0eIcKODi6fCQo3UnwZODM4TICuf2Ccw0(Er9iiuf15Gq1bY6iAcr9iehgzPC72ynJ2zI3kYnuA8ftuCjQHgkkoefFIcqIoTI2Obk5yFTB8miRSJMpCuf2Ccw0(Er7qupccvrDoiuDGSoIMqupcXHrwk3UnwZODM4TICdLgFXefxIA32BNpYF5DWTjUhvIIdrnmzrbirNwrB0aLCMZNIg4p45y8r9(SzJZIXrvyZjyrnornmzrbu0eIcKOajk1TT30KGDFX8t7cBoL72wuxlndtqEpjAcr9iehgzPCFX8t7cBoL72wuxlndtqEp5gkGTkkGI23lkqIsDB7nnjyhduaJSqWz0yNr78HMuQortiQhH4WilL7qtkvhbN)I9qbDzJHp8zSKn0nuA8ftuafTVxuGefirHeZh2CYHQCJr5B(cp6eTtrnu0(ErHeZh2CYHQCJr5B(cp6eTtrnMOakAcrbs0B(cp6CNHUHcyRzpcXHrwkr77f9MVWJo3zOZJqCyKLYnuA8ftuWj6xhnMiECeCE)qbD5HsJVyIACIAiyIcOO99IcjMpS5Kdv5gJY38fE0jANIMSOjefirV5l8OZDj7gkGTM9iehgzPeTVx0B(cp6CxYopcXHrwk3qPXxmrbNOFD0yI4XrW59df0Lhkn(IjQXjQHGjkGI23lkKy(WMtouLBmkFZx4rNODkkyIcOOakkGlmg5xygUW(6OzAMx(3lSfgmX8ZBEpQwyaCgbl6HefM4HvrpqKOnwaLefTff3aVbbyLxulGOs0g7lOIcJA2CsuujAJrIgfSOMdbHQt0glGsIAbevIgLObmSOeeQorFMOHnQDIEirHFAHrvyZj4fWTWOkS5uofb5lOl7fgmTJg)wylmt09OAHbt7OXVf2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHTrtUOUUvsGTWSe)LrvEOa26kjWwymRLFHTWsJUYurduRRKaBHLgDL9w9CkFXaLo2kjJTWOy4wZEqXx5FVWwyux3e5if1QBHb2cZhM3JQf26wjziylaCH1yu2cONtzFWUVGUscSfw4VhvlmiX8HnNwyEREoLVyGshBLeylmpQG)7r1cBHbjMCfP0c7anpNNzeHhnzlXFlmK5cJr3cZp)rZhlSfwJrz0ENH6Hxjb2cdsWB0cRdrzOg3(ly3bAEopZicpACuf2Ccw0(Er3puqxEO04lMOGt0Kbdmr77f1gXyIMq09df0Lhkn(IjkUenz8jkoefirXzWe14e1UT3Ud08CEMreE04yx4Xtuas0Kffqr77f1UT3Ud08CEMreE04yx4XtuWjQX6grnorbs0Pv0gnqjh7RDJNbzLD08HJQWMtWIcqIMSOaUWyKFHz4c7RJMPzE5FVWwyWeZpV59OAH19nMpS5KOngbl6HefM4HvrJYQO38fE0Xenkyr9WmrTaIkrTe)9fur3Or0Oe1iAMGqZhIAoi)cJQWMtWlGBHrvyZPCkcYxqx2lmyAhn(TWwyMO7r1cdM2rJFlSVoAMM5TscSf2xhntZ8YFAkb)XrRKaBHbj4nktCgTWwywI)wyG5W3cBJMCrDDRKaBHzj(lJQ8qbS1vsGTWywl)cBHLgDLPIgOwxjb2cln6k7T65u(IbkDSvsgBHrXWTM9GIVY)EHTWOUUjYrkQv3cdSfMpmVhvlS1TsYqdxa4cRXOSfqpNY(GDFbDLeylSnAYf11TscSfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqcEJwylSgJYO9od1dVscSfgYCHXOBH5N)O5JfMhH4WilLZh5V8UHsJVyIIlrtgmrtiQhH4WilLZJkii8O8bIYmZF(J5gkn(IjkUenzWenHOajkKy(WMtUd08CEMreE0KTe)jAFVO2T92DGMNZZmIWJgh7cpEIcorngyIIdrbs0Pv0gnqjh7RDJNbzLD08HJQWMtWIcqIAmrbuuafnHOqI5dBo5(kd1dlAFVO2igt0eIUFOGU8qPXxmrXLOgZaVWyKFHz4cdsm5ksPfwRQiLGxyFD0mnZl)7f2cZeDpQwyW0oA8BHvrkTWOutRdf8mAGRO80cJQWMtWlGBHrvyZPCkcYxqx2lmyI5N38EuTWa4msuJi106qbxuJ)bUIYtIMmymYZe1M2OHenef3aVbbyLx0gJefnIYqIEGIt0)e1YZ5IY)IeTzkQL)aj6bIeLkyrrBrXVdvaG1fgmTJg)wylSVoAMM5TscSf2xhntZ8YFAkb)XrRKaBHbj4nktCgTWwywI)wyG5W3cZs8xgv5HcyRRKaBHLgDLPIgOwxjb2cJzT8lSfw4Vhvlmk106qbpJg4kkpTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRKmm5faUWAmkBb0ZPSpy3xqxjb2cBJMCrDDRKaBH5T65u(IbkDSvsGTW8Oc(VhvlSfgKG3Of2cRXOmAVZq9WRKaBHHmxym6wy(5pA(yHbKOEeIdJSuoFK)Y7gkn(IjkUefNkAcr7qupccvrDoiuDGSoIMq0oe1JGqvuNREOGU8oir77f1JGqvuNREOGU8oirtiQhH4WilLZJkii8O8bIYmZF(J5gkn(IjkUefNkAcrbsuiX8HnNCEubbHhLHjM1YlAFVOEeIdJSuoFK)Y7gkn(IjkUefNkkGI23lQhbHQOoheQoqwhrtikqI2HOtROnAGso2x7gpdYk7O5dhvHnNGfnHOEeIdJSuoFK)Y7gkn(IjkUefNkAFVO2T92nbeQqnwEpubawDdLgFXefxIAiyIIdrbsu8jkajk1TT30KGDFXUP5p0WYWpKVOSnX5IcOOje1UT3UjGqfQXY7HkaWQRzkkGI23lQnIXenHO7hkOlpuA8ftuCjAY4t0(ErPUT9MMeSJsnTouWZObUIYtIMqupcXHrwkhLAADOGNrdCfLNCdLgFXefCIMmyIcOOjefsmFyZj3xzOEyrtiAhIsDB7nnjy3xm)0UWMt5UTf11sZWeK3tI23lQhH4WilL7lMFAxyZPC32I6APzycY7j3qPXxmrbNOjdMO99IAJymrti6(Hc6YdLgFXefxIMmylmg5xygUWGetUIuAH1Qksj4f2xhntZ8Y)EHTWmr3JQfgmTJg)wyvKslmgQX50DFbnpnBRlmQcBobVaUfgvHnNYPiiFbDzVWGjMFEZ7r1cdGZirXqnoNUVGkk(PMTvrXPmYZe1M2OHenef3aVbbyLx0gJefnIYqIEGIt0)e1YZ5IY)IeTzkQL)aj6bIeLkyrrBrXVdvaG1fgmTJg)wylSVoAMM5TscSf2xhntZ8YFAkb)XrRKaBHbj4nktCgTWwywI)wyG5W3cZs8xgv5HcyRRKaBHLgDLPIgOwxjb2cJzT8lSfw4VhvlmgQX50DFbnpnBRlS0ORS3QNt5lgO0XwjzSfgfd3A2dk(k)7f2cJ66MihPOwDlmWwy(W8EuTWw3kjdn2caxyngLTa65u2hS7lORKaBHf(7r1cdsmFyZPfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqIjxrkTW(Ufo7rf8FpQwyiZfgJUfMF(JMpwylSgJYO9od1dVscSfgKG3OfMDBVD(i)L3nuA8ftuWjQH4t0eIcKODi60kAJgOKJ91UXZGSYoA(WrvyZjyr77f1UT3UjGqfQXY7HkaWQBO04lMO4QtrneFo8jkoefirnMdFIcqIA32BNnhHG5n25AMIcOO4quGefND4tuJtuJ5WNOaKO2T92zZriyEJDUMPOakkajk1TT30KGDFXUP5p0WYWpKVOSnX5IMqu72E7MacvOglVhQaaRUMPOakAFVO2igt0eIUFOGU8qPXxmrXLOjJpr77fL622BAsWok106qbpJg4kkpjAcr9iehgzPCuQP1HcEgnWvuEYnuA8fBHXi)cZWf2xhntZ8Y)EHTWGjMFEZ7r1cd45wcRmrBmsuaw3NgprT8hirXnWBqaw5ffnIgNOhisuQGffTff)oubawxyuf2CcEbClmQcBoLtrq(c6YEHbt7OXVf2cZeDpQwyW0oA8BH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wyB0KlQRBLeylmlXFzuLhkGTUscSfgZA5xylS0ORmv0a16kjWwyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvsgIZlaCH1yu2cONtzFWUVGUscSf2gn5I66wjb2cZB1ZP8fdu6yRKaBH5rf8FpQwylmibVrlSfwJrz0ENH6Hxjb2cdzUWy0TW8ZF08XcdsmFyZj33TWzpQG)7rLOjefsmFyZj3xzOE4fgJ8lmdxyqIjxrkTWAvfPe8c7RJMPzE5FVWwyMO7r1cdM2rJFlSksPf2xm)0UWMt5UTf11sZWeK3tlmQcBobVaUfgvHnNYPiiFbDzVWc)9OAH9fZpTlS5uUBBrDT0mmb590cdM2rJFlSf2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHzj(lJQ8qbS1vsGTWsJUYurduRRKaBHXSw(f2cdMy(5nVhvlSfwA0v2B1ZP8fdu6yRKm2cJIHBn7bfFL)9cBHrDDtKJuuRUfgylmFyEpQwyRBLKH4BbGlSgJYwa9Ck7d29f0vsGTW2Ojxux3kjWwyEREoLVyGshBLeylmpQG)7r1cBHbj4nAHTWAmkJ27mup8kjWwyiZfgJUfMF(JMpwyajQhH4WilLZh5V8UHcyRIMq0oe1JGqvuNREOGU8oirtikKy(WMtUd08CEMreE0KTe)jAcrbsupcXHrwkNnnmAW7lOUHcyRI23lAhIoHNC3G4Crbu0(Er9iiuf15QhkOlVds0eI6riomYs58OcccpkFGOmZ8N)yUHcyRIMquGefsmFyZjNhvqq4rzyIzT8I23lQhH4WilLZh5V8UHcyRIcOOakAcrHrNJ1Q9pK7EpEFbv0eIcKOWOZXoIZJjV5XqU7949fur77fTdrVGt15yhX5XK38yihvHnNGfTVxuMjX55lgO0XCSlM9pKOGtuJjkGIMquy05srOA)d5U3J3xqfnHOajkKy(WMtUNLdejAFVOtROnAGso7GhLNYODo488b6lOmhvHnNGfTVx0GDtWZMil0ik46u0UhyI23lkKy(WMtopQGGWJYWeZA5fTVxu72E7S5iemVXoxZuuafnHODik1TT30KGDFX8t7cBoL72wuxlndtqEpjAFVOu32Ettc29fZpTlS5uUBBrDT0mmb59KOje1JqCyKLY9fZpTlS5uUBBrDT0mmb59KBO04lMOGtuJbMOjeTdrTB7TZh5V8UMPO99IAJymrti6(Hc6YdLgFXefxIIZGTWyKFHz4cdsm5ksPfwRQiLGxyFD0mnZl)7f2cZeDpQwyW0oA8BHvrkTWyGcyKfcoJg7mANp0Ks1TWOkS5e8c4wyuf2CkNIG8f0L9cdMy(5nVhvlmaoJefduaJSqWIA8p2IAtB0qIIBG3GaSYVWGPD043cBH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wywI)YOkpuaBDLeylS0ORmv0a16kjWwymRLFHTWc)9OAHXafWileCgn2z0oFOjLQBHLgDL9w9CkFXaLo2kjJTWOy4wZEqXx5FVWwyux3e5if1QBHb2cZhM3JQf26wjzioDbGlSgJYwa9Ck7d29f0vsGTW2Ojxux3kjWwyEREoLVyGshBLeylmpQG)7r1cBHbj4nAHTWAmkJ27mup8kjWwyiZfgJUfMF(JMpwyajkKy(WMtouLBmkFZx4rNOD0POgkAcr7q0B(cp6CxYUHcyRzpcXHrwkr77ffirHeZh2CYHQCJr5B(cp6eTtrnu0(ErHeZh2CYHQCJr5B(cp6eTtrnMOakAcrbsu72E78r(lVRzkAcrbs0oe1JGqvuNdcvhiRJO99IA32B3eqOc1y59qfay1nuA8ftuCikqIAmh(efGeDAfTrduYX(A34zqwzhnF4OkS5eSOakkU6u0B(cp6CNHo72ENHBtCpQenHO2T92nbeQqnwEpubawDntr77f1UT3UjGqfQXY7HkaWAM91UXZGSYoA(W1mffqr77f1JqCyKLY5J8xE3qPXxmrXHOjlk4e9MVWJo3zOZJqCyKLYb3M4EujAcr7qu72E78r(lVRzkAcrbs0oe1JGqvuNREOGU8oir77fTdrHeZh2CY5rfeeEugMywlVOakAcr7qupccvrDo8SoFuI23lQhbHQOox9qbD5DqIMquiX8HnNCEubbHhLHjM1YlAcr9iehgzPCEubbHhLpquMz(ZFmxZu0eI2HOEeIdJSuoFK)Y7AMIMquGefirTB7TJ883KrzERIXnuA8ftuWjQHGjAFVO2T92rE(BYOmdXJXnuA8ftuWjQHGjkGIMq0oeDAfTrduYzh8O8ugTZbNNpqFbL5OkS5eSO99IcKO2T92zh8O8ugTZbNNpqFbLLR4Ad5yx4Xt0offFI23lQDBVD2bpkpLr7CW55d0xqz5y8rro2fE8eTtr7grbuuafTVxu72E7W7l4HGZuQjYcnPuDzQOb6daKRzkkGI23lQnIXenHO7hkOlpuA8ftuCjAYGjAFVOqI5dBo5qvUXO8nFHhDI2POGjkGIMquiX8HnNCFLH6HxymYVWmCHbjMCfP0cRvvKsWlSVoAMM5L)9cBHzIUhvlmyAhn(TWGPD043cBHrvyZj4fWTWOkS5uofb5lOl7fgmX8ZBEpQwyaiONj6ZeneDIdenIs8WgnXrIAjSk6HennWJen4CrrLOngjk7It0B(cp6yIEirTjr5FrWI2mf1YFGef3aVbbyLx0OGff3Occcps0OGfTXirpqKOjxWIY4OtuujQhw0FlQn6aj6nFHhDmrJHefvI2yKOSlorV5l8OJTWyC0Xwy38fE0z4c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TWSe)LrvEOa26kjWwyPrxzQObQ1vsGTWywl)cBHf(7r1c7MVWJodxyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvsgAGxa4cRXOSfqpNY(GDFbDLeylSnAYf11TscSfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqcEJwylSgJYO9od1dVscSfgYCHXOBH5N)O5JfgqIcjMpS5Kdv5gJY38fE0jAhDkAYIMq0oe9MVWJo3zOBOa2A2JqCyKLs0(ErHeZh2CYHQCJr5B(cp6eTtrtw0eIcKO2T925J8xExZu0eIcKODiQhbHQOoheQoqwhr77f1UT3UjGqfQXY7HkaWQBO04lMO4quGe1yo8jkaj60kAJgOKJ91UXZGSYoA(WrvyZjyrbuuC1PO38fE05UKD2T9od3M4EujAcrTB7TBciuHAS8EOcaS6AMI23lQDBVDtaHkuJL3dvaG1m7RDJNbzLD08HRzkkGI23lQhH4WilLZh5V8UHsJVyIIdrtwuWj6nFHhDUlzNhH4WilLdUnX9Os0eI2HO2T925J8xExZu0eIcKODiQhbHQOox9qbD5DqI23lAhIcjMpS5KZJkii8OmmXSwErbu0eI2HOEeeQI6C4zD(OenHOajAhIA32BNpYF5Dntr77fTdr9iiuf15Gq1bY6ikGI23lQhbHQOox9qbD5DqIMquiX8HnNCEubbHhLHjM1YlAcr9iehgzPCEubbHhLpquMz(ZFmxZu0eI2HOEeIdJSuoFK)Y7AMIMquGefirTB7TJ883KrzERIXnuA8ftuWjQHGjAFVO2T92rE(BYOmdXJXnuA8ftuWjQHGjkGIMq0oeDAfTrduYzh8O8ugTZbNNpqFbL5OkS5eSO99IcKO2T92zh8O8ugTZbNNpqFbLLR4Ad5yx4Xt0offFI23lQDBVD2bpkpLr7CW55d0xqz5y8rro2fE8eTtr7grbuuaffqr77f1UT3o8(cEi4mLAISqtkvxMkAG(aa5AMI23lQnIXenHO7hkOlpuA8ftuCjAYGjAFVOqI5dBo5qvUXO8nFHhDI2POGjkGIMquiX8HnNCFLH6HxymYVWmCHbjMCfP0cRvvKsWlSVoAMM5L)9cBHzIUhvlmyAhn(TWGPD043cBHrvyZj4fWTWOkS5uofb5lOl7fw4VhvlSB(cp6sEHX4OJTWU5l8Ol5f2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHzj(lJQ8qbS1vsGTWsJUYurduRRKaBHXSw(f2cdMy(5nVhvlSfwA0v2B1ZP8fdu6yRKm2cJIHBn7bfFL)9cBHrDDtKJuuRUfgylmFyEpQwyRBLKHDZcaxyngLTa65u2hS7lORKaBHf(7r1cRXO8FukBH5T65u(IbkDSvsGTW8Oc(VhvlSfgKyYvKslSwvrkbVWqMlmgDlm)8hnFSWwyngLr7DgQhELeylmibVrlSfgJ8lmdxyFD0mnZl)7f2cdMy(5nVhvlmaoJyIgCUOOdenIIkrBms0)OuMOOsup8cJQWMtWlGBHrvyZPCkcYxqx2lmyAhn(TWwyMO7r1cdM2rJFlSVoAMM5TscSf2xhntZ8YFAkb)XrRKaBHbj4nktCgTWwywI)wyG5W3cBJMCrDDRKaBHzj(lJQ8qbS1vsGTWywl)cBHLgDLPIgOwxjb2cln6k7T65u(IbkDSvsgBHrXWTM9GIVY)EHTWOUUjYrkQv3cdSfMpmVhvlS1TsYWU3caxyngLTa65u2hS7lORKaBHf(7r1cBAvo83JQm)z3cZB1ZP8fdu6yRKaBHbj4nAHTW8Oc(VhvlSfg)zxUIuAHfiAH1yugT3zOE4vsGTWqMlmgDlm)8hnFSWGeZh2CY9SCGOfgJ8lmdxyqIjxrkTWAvfPe8cJDZ7VvsgUW(6OzAMx(3lSfMj6EuTWGPD043cJQWMtWlGBHrvyZPCkcYxqx2lmyAhn(TWwyWeZpV59OAHze)bIgrHIe9Rdj6bIeLDIIgrdejA4VhvIYF2TW(6OzAM3kjWwyFD0mnZl)PPe8hhTscSfgKG3OmXz0cBHzj(BHbMdFlSnAYf11TscSfML4VmQYdfWwxjb2cJzT8lSfwA0vMkAGADLeylS0ORS3QNt5lgO0XwjzSfgfd3A2dk(k)7f2cJ66MihPOwDlmWwy(W8EuTWw3kPKbBbGlSgJYwa9Ck7d29f0vsGTWc)9OAHnTkh(7rvM)SBH5T65u(IbkDSvsGTW8Oc(VhvlSfg)zxUIuAHXUfgKyYvKslSwvrkbVWqMlmgDlm)8hnFSWwyngLr7DgQhELeylmibVrlSfgJ8lmdxyFD0mnZl)7f2cdMy(5nVhvlSfgvHnNGxa3cJQWMt5ueKVGUSxyW0oA8BHTWmr3JQfgmTJg)wyFD0mnZBLeylSVoAMM5L)0uc(JJwjb2cdsWBuM4mAHTWSe)TWaZHVf2gn5I66wjb2cZs8xgv5HcyRRKaBHXSw(f2cln6ktfnqTUscSfwA0v2B1ZP8fdu6yRKm2cJIHBn7bfFL)9cBHrDDtKJuuRUfgylmFyEpQwyRBDlmZH8Ou74wa4kjdxa4cRXOSfqpNY(GDFbDLeylmyI5N38EuTWwyEREoLVyGshBLeylmpQG)7r1cBHbjMCfP0cRvvKsWlmK5cJr3cZp)rZhlSfwJrz0ENH6Hxjb2cdsWB0cBHXi)cZWf2xhntZ8Y)EHTWc)9OAHH3xWdbNzM)8hBHrvyZj4fWTWOkS5uofb5lOl7fgmTJg)wylmt09OAHbt7OXVf2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHTrtUOUUvsGTWSe)LrvEOa26kjWwymRLFHTWsJUYurduRRKaBHLgDL9w9CkFXaLo2kjJTWOy4wZEqXx5FVWwyux3e5if1QBHb2cZhM3JQf26wjL8caxyngLTa65u2hS7lORKaBHf(7r1cdsmFyZPfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqIjxrkTWqvUXO8nFHhDlmK5cJr3cZp)rZhlSfwJrz0ENH6Hxjb2cdsWB0cdSfgJ8lmdxyFD0mnZl)7f2cdMy(5nVhvlmaeejkKy(WMtI(mrz0j6HefmrT8hirlKOSlorrLOngj6nFHhDmJkQHIAbevIEGir3)Worrfj6ZefvI2yKrfnzr)TOhisug5rfSOpt0OGf1yI(BrTrhirJHwyuf2CcEbClmQcBoLtrq(c6YEHbt7OXVf2cZeDpQwyW0oA8BH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wyB0KlQRBLeylmlXFzuLhkGTUscSfgZA5xylS0ORmv0a16kjWwyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvsgBbGlSgJYwa9Ck7d29f0vsGTWc)9OAHbjMpS50cZB1ZP8fdu6yRKaBH5rf8FpQwylmiXKRiLwyOk3yu(MVWJUfgYCHfWWlm)8hnFSWU5l8OZDg6afSCJrz72ElAcrV5l8OZDg68iehgzPCWTjUhvIMq0oe9MVWJo3zO7zUdLsz0oNIk2nOgl7rf7MM)EuXwyngLr7DgQhELeylmibVrlmdxymYVWmCH91rZ0mV8VxylmyI5N38EuTWwyuf2CcEbClmQcBoLtrq(c6YEHbt7OXVf2cZeDpQwyW0oA8BH91rZ0mVvsGTW(6OzAMx(ttj4poALeylmibVrzIZOf2cZs83cdmh(wyB0KlQRBLeylmlXFzuLhkGTUscSfgZA5xylS0ORmv0a16kjWwyPrxzVvpNYxmqPJTsYylmkgU1Shu8v(3lSfg11nrosrT6wyGTW8H59OAHTUvs48caxyngLTa65u2hS7lORKaBHf(7r1cdsmFyZPfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqIjxrkTWqvUXO8nFHhDlmK5clGHxy(5pA(yHDZx4rN7s2bky5gJY2T9w0eIEZx4rN7s25riomYs5GBtCpQenHODi6nFHhDUlz3ZChkLYODofvSBqnw2Jk2nn)9OITWAmkJ27mup8kjWwyqcEJwyjVWyKFHz4c7RJMPzE5FVWwyWeZpV59OAHTWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRKW3caxyngLTa65u2hS7lORKaBHf(7r1cdsmFyZPfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqcEJwy48cdzUWcy4fMF(JMpwyu32Ettc29fZpTlS5uUBBrDT0mmb59KO99IsDB7nnjyhLAADOGNrdCfLNeTVxuQBBVPjb7yOgNt39f080STUWAmkJ27mup8kjWwyqIjxrkTWqvUXO8nFHhDlmg5xygUW(6OzAMx(3lSfgmX8ZBEpQwyaiiIrIEZx4rht0yirl0jA0ouACVp4CRIcth5pcw0GjkQeTXirzxCIEZx4rhZjQOy0jkKy(WMtIEirXzrdMOhiYQObNHeTicwuMj5)GlkOOG5Fb1TWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRKWPlaCH1yu2cONtzFWUVGUscSfw4VhvlmiX8HnNwyEREoLVyGshBLeylmpQG)7r1cBHbjMCfP0cJXYEe7wyiZfgJUfMF(JMpwylSgJYO9od1dVscSfgKG3OfMXatuasuGe1qrnorbZLSOaKOm6Y2OQXC3ttYDtgNn9Ic4cJr(fMHlSVoAMM5L)9cBHbtm)8M3JQfggDmrpqKOyxmS2aLe1JyNOB0ikpoAe1hCFJh3JkMOaTrJOuxrQjNe1ciQe9qIYUyorHBPMFbvuBAJgsu87qfayv0DW5mrr7nGlmQcBobVaUfgvHnNYPiiFbDzVWGPD043cBHzIUhvlmyAhn(TW(6OzAM3kjWwyFD0mnZl)PPe8hhTscSfgKG3OmXz0cBHzj(BHbMdFlSnAYf11TscSfML4VmQYdfWwxjb2cJzT8lSfwA0vMkAGADLeylS0ORS3QNt5lgO0XwjzSfgfd3A2dk(k)7f2cJ66MihPOwDlmWwy(W8EuTWw3kjd8caxyngLTa65u2hS7lORKaBHf(7r1cdsmFyZPfM3QNt5lgO0Xwjb2cZJk4)EuTWwyqIjxrkTW8OcccpkhmZfgYCHXOBH5N)O5Jf2cRXOmAVZq9WRKaBHbj4nAHzmWefhIAiyIcqIoTI2Obk58eNy3h8mZ8N)yoQcBobVWyKFHz4c7RJMPzE5FVWwyWeZpV59OAHHrht04e1cO3ds0if1Qtu0wuGNHtef3OcccpsugiuJdlQnjAJrWDNO4myIA5pqO2jkUjoXUp4IIz(ZFmrJcwuJbMOw(dKBHrvyZj4fWTWOkS5uofb5lOl7fgmTJg)wylmt09OAHbt7OXVf2xhntZ8wjb2c7RJMPzE5pnLG)4OvsGTWGe8gLjoJwylmlXFlmWC4BHTrtUOUUvsGTWSe)LrvEOa26kjWwymRLFHTWsJUYurduRRKaBHLgDL9w9CkFXaLo2kjJTWOy4wZEqXx5FVWwyux3e5if1QBHb2cZhM3JQf26wj1nlaCH1yu2cONtzFWUVGUscSfgmX8ZBEpQwylmVvpNYxmqPJTscSfMhvW)9OAHTWGetUIuAH1Qksj4fgYCHXOBH5N)O5Jf2cRXOmAVZq9WRKaBHbj4nAHTWyKFHz4c7RJMPzE5FVWwyH)EuTWsrOcVVYB0KUWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRK6ElaCH1yu2cONtzFWUVGUscSfgmX8ZBEpQwylmVvpNYxmqPJTscSfMhvW)9OAHTWGetUIuAH1Qksj4fwJrz0ENH6Hxjb2cdzUWy0TW8ZF08Xcdirjp)nzKJ3QyYf11jAFVOKN)MmY9vMH4XiAFVOKN)MmY9v2gDGeTVxuYZFtg5IYAUOUorbCHX)IYE4fMHGTWGe8gTWwymYVWmCH91rZ0mV8VxylSWFpQwywM4aTWOkS5e8c4wyuf2CkNIG8f0L9cdM2rJFlSfMj6EuTWGPD043c7RJMPzERKaBH91rZ0mV8NMsWFC0kjWwyqcEJYeNrlSfML4Vfgyo8TW2Ojxux3kjWwywI)YOkpuaBDLeylmM1YVWwyPrxzQObQ1vsGTWsJUYEREoLVyGshBLKXwyumCRzpO4R8VxylmQRBICKIA1TWaBH5dZ7r1cBDRBHfiAbGRKmCbGlmQcBobVaUfgYCHXOBHf(7r1cdsmFyZPfgKG3Of20kAJgOK7(uYcAQm8qrQ9xW04OkS5eSOjefirTB7T7(uYcAQm8qrQ9xW04gkn(IjkUefQh2LgDjkoefmNHI23lQDBVD3NswqtLHhksT)cMg3qPXxmrXLOH)Eu5yxm7Fih1f5BhLVpLefhIcMZqrtikqIsE(BYi3xzERIr0(Erjp)nzKJH4XKlQRt0(Erjp)nzKlkR5I66efqrbu0eIA32B39PKf0uz4HIu7VGPX1mxyqIjxrkTWGhksZwEopVdopJ27fgmX8ZBEpQwy4o4(gpoIjQfq0bIgrpqKOgVHIuFCEq0iQDBVf1YZ5IUdoxu0ElQL)a9LOhis0I66e1hSBDRKsEbGlmQcBobVaUfgYCHXOBHf(7r1cdsmFyZPfgKG3OfwhIsE(BYi3xzgIhJOjeLzsCE(IbkDmh7Iz)djk4e1alQXj6fCQohd14z0oFGO8gne7Cuf2Ccwuas0KffhIsE(BYi3xzB0bs0eI2HOtROnAGsoZ5trd8h8Cm(OEF2SXzX4OkS5eSOjeTdrNwrB0aLCOIoqSSNtXKH8ShvoQcBobVWGetUIuAH9ql0qz2fdRnqPfgmX8ZBEpQwy4o4(gpoIjQfq0bIgrXUyyTbkj6Ze1cAoqI6d29furrqOruSlM9pKOFjk(3Qye1i883KrRBLKXwa4cJQWMtWlGBH5N)O5JfwhIcpTh2vOShMjAcrbsuGefsmFyZjNhvqq4rzyIzT8IMq0oe1JqCyKLY5J8xE3qbSvr77f1UT3oFK)Y7AMIcOOjefirTB7TJ883KrzERIXnuA8ftuWjk(eTVxu72E7ip)nzuMH4X4gkn(Ijk4efFIcOOjefird2nbpBISqJO4su8bMOjefirzMeNNVyGshZXUy2)qIcornMO99IA32BNpYF5Dntrbu0(Er7q0Pv0gnqjN58POb(dEogFuVpB24SyCuf2CcwuafnHOajAhIEbNQZXoIZJjdp)(Cuf2Ccw0(ErTB7TJDXSdo3nuA8ftuCjQHo8jQXjkyo8jkaj60kAJgOKZtCIDFWZmZF(J5OkS5eSO99IA32BNpYF5DdLgFXefxIA32Bh7IzhCUBO04lMO4qu8jAcrTB7TZh5V8UMPOakAcrbs0oeDAfTrduYzh8O8ugTZbNNpqFbL5OkS5eSO99IA32BNDWJYtz0ohCE(a9fuwUIRnKJDHhprbNOgt0(ErTB7TZo4r5PmANdopFG(cklhJpkYXUWJNOGtuJjkGI23lQnIXenHO7hkOlpuA8ftuCjQHGjAcr9iehgzPC(i)L3nuA8ftuWjk(efWfw4VhvlmpQGGWJYhikZm)5p2cdMy(5nVhvlmaoJef3OcccpsulGOs04eLtmMOhOOefFGjkWZWjIgfSO8VirBMIA5pqIIBG3GaSYVUvs48caxyuf2CcEbClSWFpQwySwT)HwyEREoLVyGshBLKHlmyI5N38EuTWa4msuSwT)He9lrnJcMsFVOOs0OSEG(cQOhO4eL)qiMOgIZmYZenkyr5eJjQL)ajAkAirVyGsht0OGfnorpqKOublkAlAikgIhJOgHN)Mms04e1qCwug5zIIgr5eJj6qPXxFbv0Gj6HeTqNOGciFbv0dj6q7HyGefUnFbvu8VvXiQr45VjJwy(5pA(yHbKOdThIbkS5KO99IA32Bh55VjJYmepg3qPXxmrXLOgt0eIsE(BYi3xzgIhJOjeDO04lMO4sudXzrti6fCQohd14z0oFGO8gne7Cuf2CcwuafnHOxmqPZDFkLpug(jrbNOgIZIACIYmjopFXaLoMO4q0HsJVyIMquGeL883KrUVYrzv0(Erhkn(IjkUefQh2LgDjkGRBLe(wa4cJQWMtWlGBH5N)O5JfgKy(WMtUVBHZEub)3JkrtiQhH4WilL7lMFAxyZPC32I6APzycY7j3qbSvrtik1TT30KGDFX8t7cBoL72wuxlndtqEpjAcrdZShe5XBHf(7r1cJ1Q9p0cdMy(5nVhvlmaoJefRv7FirpKOGciKOHOq5i7Gl6HeTXirbyDFA8w3kjC6caxyuf2CcEbClm)8hnFSW6q0l4uDo2rCEmz453NJQWMtWIMquGeTdrz0LTrvJ5UNMK7MmoB6fTVxuYZFtg5(khLvr77fLzsCE(IbkDmh7IzhCUOGtuJjkGIMquGe1UT3o2fZo4C3q7HyGcBojAcrbsuMjX55lgO0XCSlMDW5IIlrnMO99I2HOtROnAGsU7tjlOPYWdfP2FbtJJQWMtWIcOO99IEbNQZXqnEgTZhikVrdXohvHnNGfnHO2T92rE(BYOmdXJXnuA8ftuCjQXenHOKN)MmY9vMH4XiAcrTB7TJDXSdo3nuA8ftuCjQbw0eIYmjopFXaLoMJDXSdoxuW1PO4SOakAcrbs0oeDAfTrduYXT6Jjy5nNO7lOzO8p1KroQcBoblAFVO3NsIAGefNXNOGtu72E7yxm7GZDdLgFXefhIMSOakAcrVyGsN7(ukFOm8tIcorX3cl83JQfg7IzhC(cdMy(5nVhvlSUFezkAZuuSlMDW5IgNObNl69Pet0wXjgt0g7lOII)w9XemrJcw0)e9zIg2O2j6He1CqErrJOC6e9arIYmj)hCrd)9Osu(xKO2ehzruqrbZjrnEdfP2FbtJOOs0Kf9IbkDS1TsYaVaWfgvHnNGxa3cZp)rZhlSl4uDo2rCEmz453NJQWMtWIMqu72E7yxm7GZDdThIbkS5KOjefir7qugDzBu1yU7Pj5UjJZMEr77fL883KrUVYrzv0(ErzMeNNVyGshZXUy2bNlk4efNffqrtikqI2HOtROnAGsoUvFmblV5eDFbndL)PMmYrvyZjyr77f9(usudKO4m(efCIIZIcOOje9IbkDU7tP8HYWpjk4e1ylSWFpQwySlMDW5lmyI5N38EuTWWp(dKOyhX5XiQXB(9jAJrIIkr9WIAbevIo0EigOWMtIA3orz3Z5IAj(t0nAef)T6JjyIAoiVOrblkmQa)jAJrIAtB0qIIBJhZjk29CUOngjQnTrdjkUrfeeEKOSV8KOhO4e1YZ5IAoiVOrHoq0ik2fZo481TsQBwa4cJQWMtWlGBH5N)O5Jf20kAJgOK7(uYcAQm8qrQ9xW04OkS5eSOjeLzsCE(IbkDmh7IzhCUOGRtrnMOjefir7qu72E7UpLSGMkdpuKA)fmnUMPOje1UT3o2fZo4C3q7HyGcBojAFVOajkKy(WMto4HI0SLNZZ7GZZO9w0eIcKO2T92XUy2bN7gkn(IjkUe1yI23lkZK488fdu6yo2fZo4CrbNOjlAcrVGt15yhX5XKHNFFoQcBoblAcrTB7TJDXSdo3nuA8ftuCjk(efqrbuuaxyH)EuTWyxm7GZxyWeZpV59OAHHF8hirnEdfP2FbtJOngjk2fZo4CrpKO4rKPOntrpqKO2T9wuBRIgCgs0g7lOIIDXSdoxuujk(eLrEubZefnIYjgt0HsJV(c66wj19wa4cJQWMtWlGBHHmxym6wyH)EuTWGeZh2CAHbj4nAHfSBcE2ezHgrbNODdyIcqIcKOgkQXjkJUSnQAm390KC3Kt20lkajkyUKffqrbirbsudf14e1UT3U7tjlOPYWdfP2FbtJJDHhprbirbZzOOakQXjkqIA32Bh7IzhCUBO04lMOaKOgtudkkZK48mOGDKOaKODi6fCQoh7iopMm887ZrvyZjyrbuuJtuGe1JqCyKLYXUy2bN7gkn(IjkajQXe1GIYmjopdkyhjkaj6fCQoh7iopMm887ZrvyZjyrbuuJtuGe1UT3UDBSMr7mXBf5gkn(Ijkajk(efqrtikqIA32Bh7IzhCURzkAFVOEeIdJSuo2fZo4C3qPXxmrbCHbjMCfP0cJDXSdopBbvxEhCEgT3lmyI5N38EuTWWDW9nECetulGOdenIgIIDXWAdus0gJe1YZ5I6JgJef7IzhCUOhs0DW5II2BJkAuWI2yKOyxmS2aLe9qIIhrMIA8gksT)cMgrzx4Xt0MPt0UbmrFMOhis0H622peSOapdNi6He1hStuSlgwBGs4a7IzhC(6wjziylaCHrvyZj4fWTW8ZF08XcdsmFyZjh8qrA2YZ55DW5z0ElAcrHeZh2CYXUy2bNNTGQlVdopJ2BrtiAhIcjMpS5K7HwOHYSlgwBGsI23lkqIA32BNDWJYtz0ohCE(a9fuwUIRnKJDHhprbNOgt0(ErTB7TZo4r5PmANdopFG(cklhJpkYXUWJNOGtuJjkGIMquMjX55lgO0XCSlMDW5IIlrXzrtikKy(WMto2fZo48SfuD5DW5z0EVWc)9OAHXUyyTbkTWGjMFEZ7r1cdGZirXUyyTbkjQL)ajQXBOi1(lyAe9qIIhrMI2mf9arIA32BrT8hiu7eLJyFbvuSlMDW5I2mVpLenkyrBmsuSlgwBGsIIkrXzCikWHaEauu2fE8yI2Q75IIZIEXaLo26wjzOHlaCHrvyZj4fWTWc)9OAHfWH59qOmZsmPlmVvpNYxmqPJTsYWfgmX8ZBEpQwyaCgjkZsmPIYqIEGItuROMOqPt00OlrBM3NsIABv0g7lOI(NObtuECKObtuteJ92CsuujkNymrpqrjQXeLDHhpMOOr0UpAStulGOsuJHdrzx4XJjk1L5p0cZp)rZhlSoe9EpEFbv0eI2HOH)Eu5c4W8EiuMzjM0mCKgqj3x5n)Hc6eTVxuy05c4W8EiuMzjM0mCKgqjh7cpEIIlrnMOjefgDUaomVhcLzwIjndhPbuYnuA8ftuCjQXw3kjdtEbGlmQcBobVaUfw4VhvlSueQ2)qlmVvpNYxmqPJTsYWfgmX8ZBEpQwy4NO9qmqIA8Hq1(hs0FlkUbEdcWkVOpt0HcyRgv0denKOXqIYjgt0duuIIprVyGsht0Vef)BvmIAeE(BYirT8hirXqh(1OIYjgt0duuIAiyIIoq0y5zKOFjAuwf1i883KrIIgrBMIEirXNOxmqPJjQnTrdjAik(3Qye1i883KrornEOc8NOdThIbsu428fur7(9f8qWIAePMil0Ks1jAR4eJj6xIIH4XiQr45VjJwy(5pA(yHbKOHz2dI84jAFVOqI5dBo5EOfAOm7IH1gOKO99I2HOKN)MmY9vokRIcOOjefir9iehgzPC(i)L3nuaBv0eIsE(BYi3x5OSkAcr7qu4P9WUcL9WmrtikqIcjMpS5KZJkii8OmmXSwEr77f1JqCyKLY5rfeeEu(arzM5p)XCdfWwfTVx0oe1JGqvuNREOGU8oirbu0(ErzMeNNVyGshZXUy2)qIIlrbsuGefNkQXjkqIA32Bh55VjJY8wfJRzkkajAYIcOOakkajkqIAOO4q0l4uDUZYx5ueQyoQcBoblkGIcOOjeTdrjp)nzKJH4XKlQRt0eI2HOEeIdJSuoFK)Y7gkGTkAFVOajk55VjJCFLziEmI23lQDBVDKN)MmkZBvmUMPOjeTdrVGt15yOgpJ25deL3OHyNJQWMtWI23lQDBVDMZNIg4p45y8r9(SzJZIXbj4nsuW1POjJpWefqrtikqIYmjopFXaLoMJDXS)HefxIAiyIcqIcKOgkkoe9covN7S8vofHkMJQWMtWIcOOakAcrd2nbpBISqJOGtu8bMOgNO2T92XUy2bN7gkn(IjkajkovuafnHOajAhI6rqOkQZHN15Js0(Er7qu72E7W7l4HGZuQjYcnPuDzQOb6daKRzkAFVOKN)MmY9vMH4XikGIMq0oe1UT3UjGqfQXY7HkaWAM91UXZGSYoA(W1mx3kjdn2caxyuf2CcEbClm)8hnFSWcZShe5Xt0(ErHeZh2CY9ql0qz2fdRnqPfw4VhvlSnA8ugTZvCTHwyWeZpV59OAHbWzKO4xusIIkr9WIA5pqO2jQpmn)c66wjzioVaWfgvHnNGxa3cdzUWy0TWc)9OAHbjMpS50cdsWB0cRdrHN2d7ku2dZenHOajkKy(WMtopC2Jk4)EujAcrbsu72E7yxm7GZDntr77f9covNJDeNhtgE(95OkS5eSO99I6rqOkQZvpuqxEhKOakAcrHrNlfHQ9pK7EpEFbv0eIcKODiQDBVDmeNDVNCntrtiAhIA32BNpYF5DntrtikqI2HOxWP6C72ynJ2zI3kYrvyZjyr77f1UT3oFK)Y7GBtCpQefCI6riomYs52TXAgTZeVvKBO04lMO4q0UruafnHOajAhIYOlBJQgZDpnj3n5Kn9I23lk55VjJCFL5Tkgr77fL883KrogIhtUOUorbu0eIcjMpS5K7anpNNzeHhnzlXFIMquGeTdr9iiuf15QhkOlVds0(Er9iehgzPCEubbHhLpquMz(ZFm3qPXxmrXLO2T925J8xEhCBI7rLOaKOG5WNOakAcrVyGsN7(ukFOm8tIcorTB7TZh5V8o42e3JkrbirbZzGffqr77f1gXyIMq09df0Lhkn(IjkUe1UT3oFK)Y7GBtCpQefhIAyYIcqIoTI2Obk5mNpfnWFWZX4J69zZgNfJJQWMtWIc4cdsm5ksPfMho7rf8FpQYbIw3kjdX3caxyuf2CcEbClm)8hnFSWSB7TZh5V8UHsJVyIcorneFI23lQDBVD(i)L3b3M4Eujkoe1WKffGeDAfTrduYzoFkAG)GNJXh17ZMnolghvHnNGffxIMmov0eIcjMpS5KZdN9Oc(Vhv5arlSWFpQwytaHkuJL3dvaG1fgmX8ZBEpQwyaCgjk(DOcaSkQL)ajkUbEdcWk)6wjzioDbGlmQcBobVaUfMF(JMpwyqI5dBo58WzpQG)7rvoqKOjefirTB7TZh5V8o42e3JkrXHOgMSOaKOtROnAGsoZ5trd8h8Cm(OEF2SXzX4OkS5eSOGRtrtgNkAFVODiQhbHQOoheQoqwhrbu0(ErTB7TBciuHAS8EOcaS6AMIMqu72E7MacvOglVhQaaRUHsJVyIIlr7EIIdr9OcU9NZCi)ZOCWFOvkvN7(ukdj4nsuCikqI2HO2T92zZriyEJDUMPOjeTdrVGt15yxmC0a7OkS5eSOaUWc)9OAH5joXUp45G)qRuQUfgmX8ZBEpQwyaCgjkUbEdcWkVOOsupSOTItmMOrblk)ls0)eTzkQL)ajkUrfeeE06wjzObEbGlmQcBobVaUfMF(JMpwyqI5dBo58WzpQG)7rvoq0cl83JQf2x(yQ4EuTUvsg2nlaCHrvyZj4fWTW8ZF08Xcdir9iehgzPC(i)L3nuA8ftuCiQDBVD(i)L3b3M4EujkoeDAfTrduYzoFkAG)GNJXh17ZMnolghvHnNGffGe1WKffCI6riomYs5OutKfAY2Oc2b3M4Eujkoe1qWefqr77f1UT3oFK)Y7gkn(Ijk4eTBeTVxu4P9WUcL9WSfw4Vhvlmk1ezHMSnQGxyWeZpV59OAHbWzKOgrQjYcnIcCOcwuujQhwul)bsuSlMDW5I2mfnkyrzbes0nAefN04SyenkyrXnWBqaw5x3kjd7ElaCHrvyZj4fWTWc)9OAHXoIZJjV5XqlmVvpNYxmqPJTsYWfgmX8ZBEpQwy4NO9qmqIU5XqIIkrBMIEirnMOxmqPJjQL)aHANO4g4niaR8IAtFbv0Wg1orpKOuxM)qIgfSOf6efbHgFyA(f0fMF(JMpwydThIbkS5KOje9(ukFOm8tIcorneFIMquMjX55lgO0XCSlM9pKO4suCw0eIgMzpiYJNOjefirTB7TZh5V8UHsJVyIcornemr77fTdrTB7TZh5V8UMPOaUUvsjd2caxyuf2CcEbClm)8hnFSWip)nzK7RCuwfnHOajAyM9GipEI23lAhIoTI2Obk5mNpfnWFWZX4J69zZgNfJJQWMtWIcOOjefirTB7TZC(u0a)bphJpQ3NnBCwmoibVrIIlrtgFGjAFVO2T925J8xE3qPXxmrbNODJOakAcrbsuy05c4W8EiuMzjM0mCKgqj39E8(cQO99I2HOEeeQI6Cf5hehnWI23lkZK488fdu6yIcortwuafnHOajQDBVDtaHkuJL3dvaGv3qPXxmrXLODprnorbsuCwuas0Pv0gnqjh7RDJNbzLD08HJQWMtWIcOOje1UT3UjGqfQXY7HkaWQRzkAFVODiQDBVDtaHkuJL3dvaGvxZuuafnHOajAhI6riomYs58r(lVRzkAFVO2T92DGMNZZmIWJgh7cpEIIlrneFIMq09df0Lhkn(IjkUenzWat0eIUFOGU8qPXxmrbNOgcgyI23lAhIYqnU9xWUd08CEMreE04OkS5eSOakAcrbsugQXT)c2DGMNZZmIWJghvHnNGfTVxupcXHrwkNpYF5DdLgFXefCIAmWefqrti6fdu6C3Ns5dLHFsuWjk(eTVxuBeJjAcr3puqxEO04lMO4sudbBHf(7r1cB3gRz0ot8wrlmyI5N38EuTWa4msu8lYie93I(f7HjrJsuJWZFtgjAuWIY)Ie9prBMIA5pqIgIItACwmIAoiVOrblkWdhM3dHefZsmPRBLuYgUaWfgvHnNGxa3cZp)rZhlm72E7qfDGyztA8K59OY1mfnHOajQDBVDSlMDW5UH2dXaf2Cs0(Erd2nbpBISqJOGt0UhyIc4cl83JQfg7IzhC(cdMy(5nVhvlmaoJenef7IzhCUOg)fDGe1CqErBfNymrXUy2bNl6Zen4dfWwfTzkkAe1kQjAmKOHnQDIEirrqOXhMIc8mCY6wjLCYlaCHrvyZj4fWTW8ZF08XcZJGqvuNREOGU8oirtiAhIEbNQZXoIZJjdp)(Cuf2Ccw0eIcKOqI5dBo58OcccpkdtmRLx0(Er9iehgzPC(i)L31mfTVxu72E78r(lVRzkkGIMqupcXHrwkNhvqq4r5deLzM)8hZnuA8ftuCjkupSln6suasup9Crbs0GDtWZMil0iQbffFGjkGIMqu72E7yxm7GZDdLgFXefxIIZIMq0oefEApSRqzpmBHf(7r1cJDXSdoFHbtm)8M3JQfMXRLAkkWZWjIAtB0qIIBubbHhjQL)ajk2fZo4CrJcw0devIIDXWAduADRKs2ylaCHrvyZj4fWTW8ZF08XcZJGqvuNREOGU8oirtikqIcjMpS5KZJkii8OmmXSwEr77f1JqCyKLY5J8xExZu0(ErTB7TZh5V8UMPOakAcr9iehgzPCEubbHhLpquMz(ZFm3qPXxmrXLO4t0eIcjMpS5KJDXSdopBbvxEhCEgT3IMquYZFtg5(khLvrtiAhIcjMpS5K7HwOHYSlgwBGsIMq0oefEApSRqzpmBHf(7r1cJDXWAduADRKsgNxa4cJQWMtWlGBH5N)O5JfMDBVDOIoqSSNtXKH8ShvUMPO99IcKODik7Iz)d5cZShe5Xt0eI2HOqI5dBo5EOfAOm7IH1gOKO99IcKO2T925J8xE3qPXxmrXLO4t0eIA32BNpYF5Dntr77ffirbsu72E78r(lVBO04lMO4suOEyxA0LOaKOE65IcKOb7MGNnrwOrudkkKy(WMtogl7rStuafnHO2T925J8xExZu0(ErTB7TBciuHAS8EOcaSMzFTB8miRSJMpCdLgFXefxIc1d7sJUefGe1tpxuGeny3e8SjYcnIAqrHeZh2CYXyzpIDIcOOje1UT3UjGqfQXY7HkaWAM91UXZGSYoA(W1mffqrtiQhbHQOoheQoqwhrbuuafnHOajkZK488fdu6yo2fZo4CrXLOgt0(ErHeZh2CYXUy2bNNTGQlVdopJ2BrbuuafnHODikKy(WMtUhAHgkZUyyTbkjAcrbs0oeDAfTrduYDFkzbnvgEOi1(lyACuf2Ccw0(ErzMeNNVyGshZXUy2bNlkUe1yIc4cl83JQfg7IH1gO0cdMy(5nVhvlmaoJef7IH1gOKOw(dKOrjQXFrhirnhKxu0i6Vf1kQbEyrrqOXhMIc8mCIOw(dKOwrTr0I66e1hSZjkWZzirHBPMIc8mCIOXj6bIeLkyrrBrpqKODFP6azDe1UT3I(BrXUy2bNlQfuJdxG)eDhCUOO9wu0iQvut0yirrLOjl6fdu6yRBLuY4BbGlmQcBobVaUfMF(JMpwyajQDBVDKN)MmkZq8yCdLgFXefCIsDr(2r57tjr77ffir9GIbkXeTtrtw0eIoKhumqP89PKO4su8jkGI23lQhumqjMODkQXefqrtiAyM9GipElSWFpQwyfzjNIq1cdMy(5nVhvlmaoJe14dHkMOFjkgIhJOgHN)Mms0OGfLfqirXVnoxuJpeQeDJgrXnWBqaw5x3kPKXPlaCHrvyZj4fWTW8ZF08XcdirTB7TJ883KrzgIhJBO04lMOGtuQlY3okFFkjAFVOajQhumqjMODkAYIMq0H8GIbkLVpLefxIIprbu0(Er9GIbkXeTtrnMOakAcrdZShe5Xt0eIcKO2T92nbeQqnwEpubawDdLgFXefxIIprtiQDBVDtaHkuJL3dvaGvxZu0eI2HOtROnAGso2x7gpdYk7O5dhvHnNGfTVx0oe1UT3UjGqfQXY7HkaWQRzkkGlSWFpQwyGc(oNIq16wjLSbEbGlmQcBobVaUfMF(JMpwyajQDBVDKN)MmkZq8yCdLgFXefCIsDr(2r57tjrtikqI6riomYs58r(lVBO04lMOGtu8bMO99I6riomYs58OcccpkFGOmZ8N)yUHsJVyIcorXhyIcOO99IcKOEqXaLyI2POjlAcrhYdkgOu((usuCjk(efqr77f1dkgOet0of1yIcOOjenmZEqKhprtikqIA32B3eqOc1y59qfay1nuA8ftuCjk(enHO2T92nbeQqnwEpubawDntrtiAhIoTI2Obk5yFTB8miRSJMpCuf2Ccw0(Er7qu72E7MacvOglVhQaaRUMPOaUWc)9OAHTBCEofHQ1Tsk5UzbGlmQcBobVaUfgmX8ZBEpQwyaCgjk(bYiefvIIBJ3cl83JQfMLyMhnz0ot8wrRBLuYDVfaUWOkS5e8c4wyiZfgJUfw4VhvlmiX8HnNwyqcEJwymtIZZxmqPJ5yxm7FirbNO4SO4q0nhHgrbs00GD0yndj4nsuasudbdmrnOOjdMOakkoeDZrOruGe1UT3o2fdRnqPmLAISqtkvxMH4X4yx4XtudkkolkGlmiXKRiLwySlM9pu(RmdXJzHbtm)8M3JQfgUdUVXJJyIAbeDGOr0djAJrIIDXS)He9lrXq8ye1cO3ds0NjACIIprVyGshdhgk6gnIsqOXQOjdMbs00GD0yvu0ikolk2fdRnqjrnIutKfAsP6eLDHhp26wjzmWwa4cJQWMtWlGBHHmxym6wyH)EuTWGeZh2CAHbj4nAHzOOguuMjX5zqb7irXLOjlQXjkqIcMlzrbirbsuMjX55lgO0XCSlM9pKOgNOgkkGIcqIcKOgkkoe9covNJHA8mANpquEJgIDoQcBoblkajQHo8jkGIcOO4quWCgIprbirTB7TBciuHAS8EOcaS6gkn(ITWGetUIuAHzzIdu(R8EOcaSUWGjMFEZ7r1cd3b334XrmrTaIoq0i6Hef)yIdKOWT5lOIIFhQaaRRBLKXmCbGlmQcBobVaUfMF(JMpwyajk55VjJC8wftUOUor77fL883KrUOSMlQRt0eIcjMpS5K7zzpNciKOakAcrbs0lgO05UpLYhkd)KOGtuCw0(Erjp)nzKJ3QyYFLtw0(ErTrmMOjeD)qbD5HsJVyIIlrnemrbu0(ErTB7TJ883KrzgIhJBO04lMO4s0WFpQCSlM9pKJ6I8TJY3NsIMqu72E7ip)nzuMH4X4AMI23lk55VjJCFLziEmIMq0oefsmFyZjh7Iz)dL)kZq8yeTVxu72E78r(lVBO04lMO4s0WFpQCSlM9pKJ6I8TJY3NsIMq0oefsmFyZj3ZYEofqirtiQDBVD(i)L3nuA8ftuCjk1f5BhLVpLenHO2T925J8xExZu0(ErTB7TBciuHAS8EOcaS6AMIMquiX8HnNCwM4aL)kVhQaaRI23lAhIcjMpS5K7zzpNciKOje1UT3oFK)Y7gkn(Ijk4eL6I8TJY3NslSWFpQwywM4aTWGjMFEZ7r1cdGZirXpM4aj6xIIH4XiQr45VjJefnI(BrlKOyxm7FirT8CUO7)e9RdjkUbEdcWkVOrznfn06wjzSKxa4cJQWMtWlGBHbtm)8M3JQfgaNrIIDXS)He93I(LO4FRIruJWZFtgzur)sumepgrncp)nzKOOsuCghIEXaLoMOOr0djQ5G8IIH4XiQr45VjJwyH)EuTWyxm7FO1TsYygBbGlmQcBobVaUfw4VhvlSPv5WFpQY8NDlmyI5N38EuTWWVbNFGM2cJ)SlxrkTW2bNFGM26w3cBhC(bAAlaCLKHlaCHrvyZj4fWTW8ZF08XcRdrNwrB0aLC2bpkpLr7CW55d0xqzoQBBVPjbVWc)9OAHXUyyTbkTWGjMFEZ7r1cd7IH1gOKOB0iAkccLs1jAR4eJjAJ9furboeWdGRBLuYlaCHrvyZj4fWTWc)9OAHXA1(hAH5T65u(IbkDSvsgUWGjMFEZ7r1cd3b7e9arIcJorT8hirpqKOPi2j69PKOhs0agw0wDpx0dejAA0LOWTjUhvI(mrb9NtuSwT)HeDO04lMOPn(9M8NGf9qIMgNhKOPiuT)HefUnX9OAH5N)O5Jfgm6CPiuT)HCdLgFXefCIouA8ftuas0KtwudkQHDZ6wjzSfaUWc)9OAHLIq1(hAHrvyZj4fWTU1TWy3caxjz4caxyuf2CcEbClSWFpQwybCyEpekZSet6cZB1ZP8fdu6yRKmCHbtm)8M3JQfgaNrIc8WH59qirXSetQOwarLOhiAirFMOfs0WFpesuMLysnQObtuECKObtuteJ92CsuujkZsmPIA5pqIMSOOr0nzHgrzx4XJjkAefvIgIAmCikZsmPIYqIEGIt0dejArweLzjMurJzEiet0UpASt0yF0i6bkorzwIjvuQlZFi2cZp)rZhlSoefgDUaomVhcLzwIjndhPbuYDVhVVGkAcr7q0WFpQCbCyEpekZSetAgosdOK7R8M)qbDIMquGeTdrHrNlGdZ7HqzMLysZGOG7U3J3xqfTVxuy05c4W8EiuMzjM0mik4UHsJVyIcorXNOakAFVOWOZfWH59qOmZsmPz4inGso2fE8efxIAmrtikm6CbCyEpekZSetAgosdOKBO04lMO4suJjAcrHrNlGdZ7HqzMLysZWrAaLC37X7lORBLuYlaCHrvyZj4fWTW8ZF08XcRdrHN2d7ku2dZenHOajkqIcjMpS5KZJkii8OmmXSwErtiAhI6riomYs58r(lVBOa2QOjeTdrNwrB0aLCMZNIg4p45y8r9(SzJZIXrvyZjyr77f1UT3oFK)Y7AMIcOOjefirbs0GDtWZMil0ikU6uuiX8HnNCEubbHhLdMPOjefirTB7TJ883KrzERIXnuA8ftuWjQHGjAFVO2T92rE(BYOmdXJXnuA8ftuWjQHGjkGI23lQDBVD(i)L3nuA8ftuWjk(enHO2T925J8xE3qPXxmrXvNIAyYIcOOjefir7q0Pv0gnqj39PKf0uz4HIu7VGPXrvyZjyr77fTdrNwrB0aLCEItS7dEMz(ZFmhvHnNGfTVxu72E7UpLSGMkdpuKA)fmnUHsJVyIcorPUiF7O89PKOakAFVOtROnAGso7GhLNYODo488b6lOmhvHnNGffqrtikqI2HOtROnAGso7GhLNYODo488b6lOmhvHnNGfTVxuGe1UT3o7GhLNYODo488b6lOSCfxBih7cpEI2PODJO99IA32BNDWJYtz0ohCE(a9fuwogFuKJDHhpr7u0Uruaffqr77f1gXyIMq09df0Lhkn(IjkUe1qWenHODiQhH4WilLZh5V8UHcyRIc4cl83JQfMhvqq4r5deLzM)8hBHbtm)8M3JQfgaNrmrXnQGGWJe93IIBG3GaSYl6ZeTzkkAe1kQjAmKOWeZA5)cQO4g4niaR8IA5pqIIBubbHhjAuWIAf1engsuBIJSikodMbngyaHBItS7dUOyM)8hdqrbEgor0Vene1qWWHOmYlQr45VjJCIc8Cgsuyub(tuoDIA8gksT)cMgrPUm)HmQOb3syLjAJrI(LO4g4niaR8IA5pqIItACwmIgfSOXj6bIeLDXCII2IgIcCiGhaf1YxWilU1TsYylaCHrvyZj4fWTW8ZF08XcBAfTrduYDFkzbnvgEOi1(lyACuf2Ccw0eIcKODikqIcKO2T92DFkzbnvgEOi1(lyACdLgFXefCIg(7rLZYehih1f5BhLVpLefhIcMZqrtikqIsE(BYi3xzB0bs0(Erjp)nzK7RmdXJr0(Erjp)nzKJ3QyYf11jkGI23lQDBVD3NswqtLHhksT)cMg3qPXxmrbNOH)Eu5yxm7Fih1f5BhLVpLefhIcMZqrtikqIsE(BYi3xzERIr0(Erjp)nzKJH4XKlQRt0(Erjp)nzKlkR5I66efqrbu0(Er7qu72E7UpLSGMkdpuKA)fmnUMPOakAFVOajQDBVD(i)L31mfTVxuiX8HnNCEubbHhLHjM1YlkGIMqupcXHrwkNhvqq4r5deLzM)8hZnuaBv0eI6rqOkQZvpuqxEhKOjefirTB7TJ883KrzERIXnuA8ftuWjQHGjAFVO2T92rE(BYOmdXJXnuA8ftuWjQHGjkGIcOOjefir7qupccvrDo8SoFuI23lQhH4WilLJsnrwOjBJky3qPXxmrbNODJOaUWc)9OAHXUyyTbkTWGjMFEZ7r1cdGZirXUyyTbkj6HefpImfTzk6bIe14nuKA)fmnIA32Br)TO)jQfuJdlk1L5pKO20gnKO7VEgOVGk6bIeTOUor9b7efnIEirHBPMIAtB0qIIBubbHhTUvs48caxyuf2CcEbClm)8hnFSWMwrB0aLC2bpkpLr7CW55d0xqzoQcBoblAcrbsuGe1UT3o7GhLNYODo488b6lOSCfxBih7cpEIcortw0(ErTB7TZo4r5PmANdopFG(cklhJpkYXUWJNOGt0KffqrtiQhH4WilLZh5V8UHsJVyIcornWIMq0oe1JqCyKLY5rfeeEu(arzM5p)XCntr77ffir9iiuf15QhkOlVds0eI6riomYs58OcccpkFGOmZ8N)yUHsJVyIIlrnemrtik55VjJCFLJYQOjeny3e8SjYcnIcortgmrXHOgdmrbir9iehgzPC(i)L3nuaBvuaffWfw4Vhvlm2fdRnqPfgmX8ZBEpQwygVwQPOyxmS2aLyIA5pqIcCbpkpjkAlkWZ5IcGG(cktu0i6He1CiZyir3OruCJkii8irT8hirboeWdGRBLe(wa4cJQWMtWlGBHHmxym6wyH)EuTWGeZh2CAHbj4nAHbKO2T92nbeQqnwEpubawDdLgFXefCIIpr77fTdrTB7TBciuHAS8EOcaS6AMIcOOjeTdrTB7TBciuHAS8EOcaSMzFTB8miRSJMpCntrtikqIA32BhEFbpeCMsnrwOjLQltfnqFaGCdLgFXefxIc1d7sJUefqrtikqIA32Bh55VjJYmepg3qPXxmrbNOq9WU0Olr77f1UT3oYZFtgL5Tkg3qPXxmrbNOq9WU0Olr77ffir7qu72E7ip)nzuM3QyCntr77fTdrTB7TJ883KrzgIhJRzkkGIMq0oe9covNJH4S79KJQWMtWIc4cdsm5ksPfgm6Yd1TTFOuQo2cdMy(5nVhvlmCJk4)Euj6gnIgCUOWOJj6bkortd8iMOS2qIEGiRIgdvG)eDO9qmqeSOwarLO4NciuHAmrXVdvaGvrbfmr5eJj6bkkrXNOmYZeDO04RVGkkAe9arIAePMil0ikWHkyrTB7TOpt0Wg1orpKO7GZffT3IIgrJYQOgHN)Mms0NjAyJANOhsuQlZFO1TscNUaWfgvHnNGxa3cdzUWy0TWc)9OAHbjMpS50cdsWB0cdir7qu72E7ip)nzuMH4X4AMIMq0oe1UT3oYZFtgL5TkgxZuuafnHODi6fCQohdXz37jhvHnNGfnHODi60kAJgOK7(uYcAQm8qrQ9xW04OkS5e8cdsm5ksPfgm6YO2XEyktE(BYOfgmX8ZBEpQwy4gvW)9Os0duCI6brE8yI(BrTIAIgdjkQDShMeL883KrIEirrf3QOWOt0denKOOr0hAHgs0d0Ze1YFGefdXz37P1TsYaVaWfgvHnNGxa3cl83JQfwkcv7FOfM3QNt5lgO0Xwjz4cdMy(5nVhvlmJh6en4CrVyGshtul)b6lrXjrbtPVxul)bc1orrqOXhMMFbfhhis0WgbHe1Jk4)EuXwy(5pA(yHbKO2T92rE(BYOmdXJXnuA8ftuWj6qPXxmr77f1UT3oYZFtgL5Tkg3qPXxmrbNOdLgFXeTVxuiX8HnNCWOlJAh7HPm55VjJefqrti6q7HyGcBojAcrVyGsN7(ukFOm8tIcornmzrtiAyM9GipEIMquiX8HnNCWOlpu32(HsP6yRBLu3SaWfgvHnNGxa3cZp)rZhlmGe1UT3oYZFtgLziEmUHsJVyIcorhkn(IjAFVO2T92rE(BYOmVvX4gkn(Ijk4eDO04lMO99IcjMpS5KdgDzu7ypmLjp)nzKOakAcrhApeduyZjrti6fdu6C3Ns5dLHFsuWjQHjlAcrdZShe5Xt0eIcjMpS5KdgD5H622pukvhBHf(7r1cJ1Q9p0cZB1ZP8fdu6yRKmCDRK6ElaCHrvyZj4fWTW8ZF08XcdirTB7TJ883KrzgIhJBO04lMOGt0HsJVyI23lQDBVDKN)MmkZBvmUHsJVyIcorhkn(IjAFVOqI5dBo5Grxg1o2dtzYZFtgjkGIMq0H2dXaf2Cs0eIEXaLo39Pu(qz4NefCIAiov0eIgMzpiYJNOjefsmFyZjhm6Yd1TTFOuQo2cl83JQfg7iopM8MhdTW8w9CkFXaLo2kjdx3kjdbBbGlmQcBobVaUfgYCHXOBHf(7r1cdsmFyZPfgKG3OfMhbHQOoheQoqwhrtiAhIoTI2Obk5yFTB8miRSJMpCuf2Ccw0eI2HOtROnAGso)pEoLr7m)3uok4mmfhihvHnNGfnHOEeIdJSuoBAy0G3xqDdfWwfnHOEeIdJSuUjGqfQXY7HkaWQBOa2QOjeTdrTB7TZh5V8UMPOjefird2nbpBISqJOGt0UXalAFVO2T92zZriyEJDUMPOaUWGetUIuAHvOmiRSJMpYumCRzy0TWGjMFEZ7r1cZ4HorNhkOtuBAJgsu87qfayv0Fl6FIAb14WIgCoYIOwrnrpKOdThIbsuoXyIc3MVGkk(DOcaSkkqhONjkQ4wffuyAsftul)bc1orX(A34IIFMv2rZhaUUvsgA4caxyuf2CcEbClm)8hnFSWGeZh2CYvOmiRSJMpYumCRzy0jAcrhkn(IjkUenzWwyH)EuTWsrOA)dTUvsgM8caxyuf2CcEbClm)8hnFSWGeZh2CYvOmiRSJMpYumCRzy0jAcrhkn(IjkUe1WU3cl83JQfgRv7FO1TsYqJTaWfgvHnNGxa3cZp)rZhlSWm7brE8wyH)EuTW2OXtz0oxX1gAHbtm)8M3JQfgaNrIIFrjjkQe1dlQL)aHANO(W08lORBLKH48caxyuf2CcEbClm)8hnFSWasupcXHrwkNpYF5DdLgFXefhIA32BNpYF5DWTjUhvIIdrNwrB0aLCMZNIg4p45y8r9(SzJZIXrvyZjyrbirnmzrbNOEeIdJSuok1ezHMSnQGDWTjUhvIIdrnemrbu0(ErTB7TZh5V8UHsJVyIcor7gr77ffEApSRqzpmBHf(7r1cJsnrwOjBJk4fgmX8ZBEpQwyaCgjQrKAISqJOahQGf1YFGenkRIYrfurPc1GcsuEWUVGkQr45VjJenkyrVXQOhsu(xKO)jAZuul)bsuCsJZIr0OGff3aVbbyLFDRKmeFlaCHrvyZj4fWTWqMlmgDlSWFpQwyqI5dBoTWGe8gTWc2nbpBISqJOGt0UhyIACIcKOj7WNOaKO2T92TBJ1mANjERih7cpEIACIMSOaKOKN)MmY9vM3QyefWfgKyYvKslSGzMHBPMlmyI5N38EuTWWOJjQfqujkWZWjIYaHACyrTjrHBPMeSOhs0cDIIGqJpmffiJhzsfmtuujk(TnwffTf1i4TIenkyrpqKOgHN)MmcW1TsYqC6caxyuf2CcEbClmK5cJr3cl83JQfgKy(WMtlmibVrlSoefEApSRqzpmt0eIcKOqI5dBo58WzpQG)7rLOjeTdrTB7TZh5V8UMPOjefir7qugDzBu1yU7Pj5UjNSPx0(Erjp)nzK7RmVvXiAFVOKN)MmYXq8yYf11jkGIMquGefirbsuiX8HnNCbZmd3snfTVxupccvrDU6Hc6Y7GeTVxuGe1JGqvuNdpRZhLOje1JqCyKLYrPMil0KTrfSBOa2QOakAFVOtROnAGsU7tjlOPYWdfP2FbtJJQWMtWIcOOjefgDowR2)qUHsJVyIcor7grtikm6CPiuT)HCdLgFXefCI29enHOajkm6CSJ48yYBEmKBO04lMOGtudbt0(Er7q0l4uDo2rCEm5npgYrvyZjyrbu0eIcjMpS5K7anpNNzeHhnzlXFIMq0lgO05UpLYhkd)KOGtu72E78r(lVdUnX9OsuasuWCgyr77f1UT3oBocbZBSZ1mfnHO2T92zZriyEJDUHsJVyIIlrTB7TZh5V8o42e3JkrXHOajQHjlkaj60kAJgOKZC(u0a)bphJpQ3NnBCwmoQcBoblkGIcOO99IcKOu32Ettc2rPMwhk4z0axr5jrtiQhH4WilLJsnTouWZObUIYtUHsJVyIIlrneNAGffhIcKO4tuas0Pv0gnqjh7RDJNbzLD08HJQWMtWIcOOakkGIMquGeTdr9iiuf15QhkOlVds0(ErbsupcXHrwkNhvqq4r5deLzM)8hZnuA8ftuCjQDBVD(i)L3b3M4EujQbfnzrtiAhIoTI2Obk5SdEuEkJ25GZZhOVGYCuf2Ccw0(Er9iehgzPCEubbHhLpquMz(ZFm3qbSvrtiAWUj4ztKfAefxIIpWefqr77f1gXyIMq09df0Lhkn(IjkUe1JqCyKLY5rfeeEu(arzM5p)XCdLgFXefqr77f1gXyIMq09df0Lhkn(IjkUe1UT3oFK)Y7GBtCpQefhIAyYIcqIoTI2Obk5mNpfnWFWZX4J69zZgNfJJQWMtWIc4cdsm5ksPfMho7rf8FpQYSBHbtm)8M3JQfgaNrIIBG3GaSYlQL)ajkUrfeeEKb7(9f8qWIIz(ZFmrJcwuyub(tueeASm)rIItACwmIIgrTaIkrboocbZBStulOghwuQlZFirTPnAirXnWBqaw5fL6Y8hI5e14lWJeL1gs0djkvhnIgII)Tkgrncp)nzKOwarLOn2dTefatUBenztVOrblAW5IIBJhtulpNlQn5rPKOdfWwfLHqLOuHAqbjkCB(cQOhisu72ElAuWIcJoMOGciKO2evIYA797FQoUvrhApedeb7w3kjdnWlaCHrvyZj4fWTW8ZF08XcZUT3oFK)Y7gkn(Ijk4e1q8jAFVO2T925J8xEhCBI7rLO4s0KnWIIdrNwrB0aLCMZNIg4p45y8r9(SzJZIXrvyZjyrbirnmzrtikKy(WMtopC2Jk4)EuLz3cl83JQf2eqOc1y59qfayDHbtm)8M3JQfgaNrIIFhQaaRIA5pqIIBG3GaSYlAR4eJjk(DOcaSkQfuJdlkpyNOCubLgrpqrjkUbEdcWkVrf9arLOngjQnTrdTUvsg2nlaCHrvyZj4fWTW8ZF08XcdsmFyZjNho7rf8FpQYSt0eIcKO2T925J8xEhCBI7rLOGRtrt2alkoeDAfTrduYzoFkAG)GNJXh17ZMnolghvHnNGffGe1WKfTVx0oe1JGqvuNdcvhiRJOakAFVO2T92nbeQqnwEpubawDntrtiQDBVDtaHkuJL3dvaGv3qPXxmrXLODprXHOEub3(ZzoK)zuo4p0kLQZDFkLHe8gjkoefir7qu72E7S5iemVXoxZu0eI2HOxWP6CSlgoAGDuf2CcwuaxyH)EuTW8eNy3h8CWFOvkv36wjzy3BbGlmQcBobVaUfMF(JMpwyqI5dBo58WzpQG)7rvMDlSWFpQwyF5JPI7r16wjLmylaCHrvyZj4fWTWqMlmgDlSWFpQwyqI5dBoTWGe8gTW8iehgzPC(i)L3nuA8ftuWjQHGjAFVODikKy(WMtopQGGWJYWeZA5fnHOEeeQI6C1df0L3bjAFVOWt7HDfk7HzlmiXKRiLwySacL3Oj7J8x(fgmX8ZBEpQwyDFJ5dBojAJrWIIkrd7N)3tmrpqXjQLOorpKO2KOSacbl6gnIIBG3GaSYlkdj6bkorpqKvrJHQtulb7iyr7(OXorTPnAirpqu66wjLSHlaCHrvyZj4fWTW8ZF08XcJ883KrUVYrzv0eIcKOb7MGNnrwOruCjA3lzrnorTB7TB3gRz0ot8wro2fE8efGefFI23lQDBVDtaHkuJL3dvaGvxZuuafnHOajQDBVDMZNIg4p45y8r9(SzJZIXbj4nsuCjAY4myI23lQDBVD(i)L3nuA8ftuWjA3ikGIMquiX8HnNCSacL3Oj7J8xErtikqI2HOEeeQI6Cf5hehnWI23lkm6CbCyEpekZSetAgosdOK7EpEFbvuafnHOajAhI6rqOkQZbHQdK1r0(ErTB7TBciuHAS8EOcaS6gkn(IjkUeT7jQXjkqIIZIcqIoTI2Obk5yFTB8miRSJMpCuf2CcwuafnHO2T92nbeQqnwEpubawDntr77fTdrTB7TBciuHAS8EOcaS6AMIcOOjefir7qupccvrDo8SoFuI23lQhH4WilLJsnrwOjBJky3qPXxmrbNOjdMOakAcrVyGsN7(ukFOm8tIcorXNO99IAJymrti6(Hc6YdLgFXefxIAiylSWFpQwy72ynJ2zI3kAHbtm)8M3JQfgaNrmrXViJq0Fl6xIgLOgHN)Mms0OGf9MNyIEir5FrI(NOntrT8hirXjnolgJkkUbEdcWkVrf1isnrwOruGdvWIgfSOapCyEpesumlXKUUvsjN8caxyuf2CcEbClm)8hnFSWSB7Tdv0bILnPXtM3JkxZu0eIA32Bh7IzhCUBO9qmqHnNwyH)EuTWyxm7GZxyWeZpV59OAHbWzKOg)fDGef7IzhCUOMdYZe93IIDXSdox0NvG)eTzUUvsjBSfaUWSB7DUIuAHXUy4ObEH5N)O5JfMDBVDSlgoAGDdLgFXefxIIprtikqIA32Bh55VjJYmepg3qPXxmrbNO4t0(ErTB7TJ883KrzERIXnuA8ftuWjk(efqrtiAWUj4ztKfAefCI29aBHrvyZj4fWTWGjMFEZ7r1cd3r5jUOyxmC0al6Vf9prbfmr5eJj6bkkrXht0HsJV(cQrf1kQjAmKOXjA3dmCikWZWjIgfSOhisuFBgQorncp)nzKOGcMO4dhmrhkn(6lOlSWFpQwy(O8epB3271TskzCEbGlm72ENRiLwyMZNIg4p45y8r9(SzJZIzH5N)O5Jf2fCQo3x(yQ4Eu5OkS5eSOjeTdrVGt15kYsofHkhvHnNGfnHOD)jkqIcKOgdmWe14eny3e8SjYcnIIdrXzWe14eLrx2gvnM7EAsUBYjB6ffGefNbtuaf1GIcKO4SOguuMjX5zqb7irbuuJtupcXHrwkNhvqq4r5deLzM)8hZnuA8ftuaffxI29NOajkqIAmWatuJt0GDtWZMil0iQXjQDBVDMZNIg4p45y8r9(SzJZIXbj4nsuCikodMOgNOm6Y2OQXC3ttYDtoztVOaKO4myIcOOguuGefNf1GIYmjopdkyhjkGIACI6riomYs58OcccpkFGOmZ8N)yUHsJVyIcOOje1JqCyKLY5J8xE3qPXxmrbNOgdmrtiQDBVDMZNIg4p45y8r9(SzJZIXbj4nsuCjAYgcMOje1UT3oZ5trd8h8Cm(OEF2SXzX4Ge8gjk4e1yGjAcr9iehgzPCEubbHhLpquMz(ZFm3qPXxmrXLO4myIMq09df0Lhkn(Ijk4e1JqCyKLY5rfeeEu(arzM5p)XCdLgFXefhIItfnHOaj60kAJgOKZtCIDFWZmZF(J5OkS5eSO99IcjMpS5KZJkii8OmmXSwErbCHrvyZj4fWTWGjMFEZ7r1cd3r5jUOhisuCsJZIru72El6Vf9arIAoiVOwqnoCb(tu(xKOntrT8hirpqKOf11j69PKO4gvqq4rI6rPetu0ElQh2jkac6zI2yTGZTkkQ4wffuyAsftu428furpqKOah(7wyH)EuTW8r5jE2UT3RBLuY4BbGlmQcBobVaUfgYCHXOBHf(7r1cdsmFyZPfgKG3OfMhbHQOox9qbD5DqIMq0Pv0gnqjN58POb(dEogFuVpB24SyCuf2Ccw0eIA32BN58POb(dEogFuVpB24SyCqcEJefhIgSBcE2ezHgrXHOgtuW1POgdmWenHOqI5dBo58OcccpkdtmRLx0eI6riomYs58OcccpkFGOmZ8N)yUHsJVyIIlrd2nbpBISqJOguuJbMOaKOq9WU0OlrtiAhIcpTh2vOShMjAcrjp)nzK7RCuwfnHOb7MGNnrwOruWjkKy(WMtopQGGWJYbZu0eI6riomYs58r(lVBO04lMOGtu8TWGetUIuAHzoiF2SXzXKPy4wxyWeZpV59OAHHrhtulGOsuCsJZIrugiuJdlQnjQ5G8EcwukgUvrpKO2KOHnNe9qI2yKO4gvqq4rIIkr9iehgzPefiJGXO6(GZTkQn5rPet0BAKO)wu4wQ5xqff4z4erlKfrT8CUObNJSiQvut0djQjnBYFCRIs1rJO4KgNfJOrbl6bIkrBmsuCJkii8iax3kPKXPlaCHrvyZj4fWTW8ZF08XcdirVGt15yhX5XKHNFFoQcBoblAFVOm6Y2OQXC3ttYDtgNn9IcOOjeTdrVGt15yxmC0a7OkS5eSOje1UT3o2fZo4C3q7HyGcBojAcr7q0Pv0gnqj39PKf0uz4HIu7VGPXrvyZjyrtikqIA32BN58POb(dEogFuVpB24SyCqcEJefCDkAY4dmrtiAhIA32BNpYF5DntrtikqIcjMpS5KlyMz4wQPO99IA32BhEFbpeCMsnrwOjLQltfnqFaGCntr77ffsmFyZjN5G8zZgNftMIHBvuafTVxuGe1JGqvuNRi)G4Obw0eIEbNQZXoIZJjdp)(Cuf2Ccw0eIcKOWOZfWH59qOmZsmPz4inGsUHsJVyIcor7gr77fn83JkxahM3dHYmlXKMHJ0ak5(kV5puqNOakkGIcOOje1JqCyKLY5J8xE3qPXxmrbNOgc2cl83JQfg7IzhC(cdMy(5nVhvlmaoJef7IzhCUOw(dKOyhX5XiQXB(9jkAe9sUBefNn9IgfSOfsuSlgoAGnQOwarLOfsuSlMDW5I(mrBMIIgrpKOMdYlkoPXzXiQfqujAyJGqI29atuGNHtacnIEGirPy4wffN04Sye1CqErHeZh2Cs0Nj6nncqrrJObSzCpesuMLysffuWeTBWbJ8mrhkn(6lOIIgrFMOFj6M)qbDRBLuYg4faUWOkS5e8c4wy(5pA(yHbjMpS5KZCq(SzJZIjtXWTUWc)9OAHXUyyTbkTWGjMFEZ7r1cZ41snzIc8mCIO20gnKO4gvqq4rI2yFbv0dejkUrfeeEKOEub)3JkrpKOEqKhpr)TO4gvqq4rI(mrd)1co3QOHnQDIEirTjr9b7w3kPK7MfaUWOkS5e8c4wy(5pA(yHfMzpiYJNOjefir9GIbkXeTtrtw0eIoKhumqP89PKO4su8jAFVOEqXaLyI2POgtuaxyH)EuTWkYsofHQfgmX8ZBEpQwyaCgjQXhcvmrTaIkrTIAIgdjAyJANOhYGXqI6dtZVGkQhumqjMOrblAAGhjkRnKOhiYQOXqI(LOrjQr45VjJeLDpNl6gnIIFMXNbXVgFRBLuYDVfaUWOkS5e8c4wy(5pA(yHfMzpiYJNOjefir9GIbkXeTtrtw0eIoKhumqP89PKO4su8jAFVOEqXaLyI2POgtuafnHOajQDBVDKN)MmkZBvmUHsJVyIcorPUiF7O89PKO99IA32Bh55VjJYmepg3qPXxmrbNOuxKVDu((usuaxyH)EuTWaf8DofHQ1TsYyGTaWfgvHnNGxa3cZp)rZhlSWm7brE8enHOajQhumqjMODkAYIMq0H8GIbkLVpLefxIIpr77f1dkgOet0of1yIcOOjefirTB7TJ883KrzERIXnuA8ftuWjk1f5BhLVpLeTVxu72E7ip)nzuMH4X4gkn(Ijk4eL6I8TJY3NsIc4cl83JQf2UX55ueQw3kjJz4caxyuf2CcEbClm)8hnFSWip)nzK7RCuwfnHOajQDBVDOIoqSSNtXKH8ShvUMPO99IA32BhEFbpeCMsnrwOjLQltfnqFaGCntr77f1UT3oFK)Y7AMIMquGeTdr9iiuf15WZ68rjAFVOEeIdJSuok1ezHMSnQGDdLgFXefCIIpr77f1UT3oFK)Y7gkn(IjkUefQh2LgDjkaj6MJqJOajAWUj4ztKfAe1GIcjMpS5KJXYEe7efqrbu0eIcKODiQhbHQOoheQoqwhr77f1UT3UjGqfQXY7HkaWQBO04lMO4suOEyxA0LOaKOE65IcKOajAWUj4ztKfAefhIIZGjkaj6fCQo3UnwZODM4TICuf2Ccwuaf1GIcjMpS5KJXYEe7efqrXHOgtuas0l4uDUISKtrOYrvyZjyrtiAhIoTI2Obk5yFTB8miRSJMpCuf2Ccw0eIA32B3eqOc1y59qfay11mfTVxu72E7MacvOglVhQaaRz2x7gpdYk7O5dxZu0(Erbsu72E7MacvOglVhQaaRUHsJVyIIlrd)9OYXUy2)qoQlY3okFFkjAcrzMeNNbfSJefxIcMdNfTVxu72E7MacvOglVhQaaRUHsJVyIIlrd)9OYzzIdKJ6I8TJY3NsI23lkKy(WMtUVBHZEub)3JkrtiQhH4WilL7lMFAxyZPC32I6APzycY7j3qbSvrtik1TT30KGDFX8t7cBoL72wuxlndtqEpjkGIMqu72E7MacvOglVhQaaRUMPO99I2HO2T92nbeQqnwEpubawDntrtiAhI6riomYs5MacvOglVhQaaRUHcyRIcOO99IcjMpS5KlyMz4wQPO99IAJymrti6(Hc6YdLgFXefxIc1d7sJUefGe1tpxuGeny3e8SjYcnIAqrHeZh2CYXyzpIDIcOOaUWc)9OAHXUyyTbkTWGjMFEZ7r1cdGZirXUyyTbkjQXFrhirnhKNjAuWIc3snff4z4erTaIkrXnWBqaw5nQOgrQjYcnIcCOc2OIEGir7(s1bY6iQDBVf9zIg2O2j6HeDhCUOO9wu0iQvud8WI6dtrbEgozDRKmwYlaCHrvyZj4fWTW8ZF08Xc7covNJDXWrdSJQWMtWIMq0oeDAfTrduYDFkzbnvgEOi1(lyACuf2Ccw0eIcKO2T92XUy4Ob21mfTVx0GDtWZMil0ik4eT7bMOakAcrTB7TJDXWrdSJDHhprXLOgt0eIcKO2T92rE(BYOmdXJX1mfTVxu72E7ip)nzuM3QyCntrbu0eIA32BN58POb(dEogFuVpB24SyCqcEJefxIMSbgmrtikqI6riomYs58r(lVBO04lMOGtudbt0(Er7quiX8HnNCEubbHhLHjM1YlAcr9iiuf15QhkOlVdsuaxyH)EuTWyxmS2aLwyWeZpV59OAHbGJvrpKOPbEKOhisuBIDII2IIDXWrdSO2wfLDHhVVGk6FI2mfTBBVhpUvr)s0OSkQr45VjJe1UDIItACwmI(Sc8NOHnQDIEirTjrnhK3tWRBLKXm2caxyuf2CcEbClmK5cJr3cl83JQfgKy(WMtlmibVrlmYZFtg5(kZBvmIcqI2nIAqrd)9OYXUy2)qoQlY3okFFkjkoeTdrjp)nzK7RmVvXikajkqIItffhIEbNQZXqnEgTZhikVrdXohvHnNGffGe1yIcOOgu0WFpQCwM4a5OUiF7O89PKO4quWC4m(e1GIYmjopdkyhjkoefmh(efGe9covNRIRnelBh8O8KJQWMtWlmiXKRiLwybZeNqdg5xyWeZpV59OAHzeS7tJJyIcczr00MhKOapdNiAmKOqJViyrnPrug5rfStuJ)IBv0lWJyIgIYQWKbcDIUrJOhisuFBgQorz)1I7rLOmKOwqnoCb(tuBs0W7BtCKOB0ikpgO0i69P0EIuITUvsgdNxa4cJQWMtWlGBH5N)O5JfwhIoTI2Obk5UpLSGMkdpuKA)fmnoQcBoblAcrbsu72E7mNpfnWFWZX4J69zZgNfJdsWBKO4s0KnWGjAFVO2T92zoFkAG)GNJXh17ZMnolghKG3irXLOjJpWenHOxWP6CSJ48yYWZVphvHnNGffqrtikqIsE(BYi3xzgIhJOjeny3e8SjYcnIIdrHeZh2CYfmtCcnyKxuasu72E7ip)nzuMH4X4gkn(IjkoefgDUDBSMr7mXBf5U3JhlpuA8LOaKOj7WNOGt0Ubmr77fL883KrUVY8wfJOjeny3e8SjYcnIIdrHeZh2CYfmtCcnyKxuasu72E7ip)nzuM3QyCdLgFXefhIcJo3UnwZODM4TIC37XJLhkn(suas0KD4tuWjA3dmrbu0eI2HO2T92Hk6aXYM04jZ7rLRzkAcr7q0l4uDo2fdhnWoQcBoblAcrbsupcXHrwkNpYF5DdLgFXefCIAGfTVxugQXT)c2DGMNZZmIWJghvHnNGfnHO2T92DGMNZZmIWJgh7cpEIIlrnMXe14efirNwrB0aLCSV2nEgKv2rZhoQcBoblkajAYIcOOjeD)qbD5HsJVyIcornemWenHO7hkOlpuA8ftuCjAYGbMO99IcpTh2vOShMjkGIMquGeTdr9iiuf15WZ68rjAFVOEeIdJSuok1ezHMSnQGDdLgFXefCIMSOaUWc)9OAHXUyyTbkTWGjMFEZ7r1cZ41snff7IH1gOKOFjAuIAeE(BYirdMOmeQenyIAIyS3MtIgmr5OcQObtuROMOwEoxuQGfTzkQL)ajA3agoe1ciQeLQJMVGk6bIeTOUorncp)nzKrffgvG)eLtNO)jQ5G8IItACwmgvuyub(tueeASm)rIgLOg)fDGe1CqErJcwuteIlQnTrdjkUbEdcWkVOrblQrKAISqJOahQGx3kjJHVfaUWOkS5e8c4wy(5pA(yHfMzpiYJNOjefsmFyZjhlGq5nAY(i)Lx0eIcKO2T92rE(BYOmVvX4gkn(Ijk4eL6I8TJY3NsI23lQDBVDKN)MmkZq8yCdLgFXefCIsDr(2r57tjrbCHf(7r1cRil5ueQwyWeZpV59OAHbWzKOgFiuXe9lrJYQOgHN)Mms0OGfLfqirXpl4BCGFBCUOgFiuj6gnIIBG3GaSYlAuWI297l4HGf1isnrwOjLQZjkWZzirBms0Km(enkyrXVgFIgNOhisuQGffTff)oubawfnkyrHrf4pr50jQXBOi1(lyAeDhCUOO9EDRKmgoDbGlmQcBobVaUfMF(JMpwyHz2dI84jAcrHeZh2CYXciuEJMSpYF5fnHOajQDBVDKN)MmkZBvmUHsJVyIcorPUiF7O89PKO99IA32Bh55VjJYmepg3qPXxmrbNOuxKVDu((usuafnHOajQDBVD(i)L31mfTVxu72E7mNpfnWFWZX4J69zZgNfJdsWBKO4Qtrt2qWefqrtikqI2HOEeeQI6CqO6azDeTVxu72E7MacvOglVhQaaRUHsJVyIIlrbsu8jQXjAYIcqIoTI2Obk5yFTB8miRSJMpCuf2CcwuafnHO2T92nbeQqnwEpubawDntr77fTdrTB7TBciuHAS8EOcaS6AMIcOOjefir7q0Pv0gnqj39PKf0uz4HIu7VGPXrvyZjyr77fL6I8TJY3NsIIlrTB7T7(uYcAQm8qrQ9xW04gkn(IjAFVODiQDBVD3NswqtLHhksT)cMgxZuuaxyH)EuTWaf8DofHQ1TsYyg4faUWOkS5e8c4wy(5pA(yHfMzpiYJNOjefsmFyZjhlGq5nAY(i)Lx0eIcKO2T92rE(BYOmVvX4gkn(Ijk4eL6I8TJY3NsI23lQDBVDKN)MmkZq8yCdLgFXefCIsDr(2r57tjrbu0eIcKO2T925J8xExZu0(ErTB7TZC(u0a)bphJpQ3NnBCwmoibVrIIRofnzdbtuafnHOajAhI6rqOkQZHN15Js0(ErTB7TdVVGhcotPMil0Ks1LPIgOpaqUMPOakAcrbs0oe1JGqvuNdcvhiRJO99IA32B3eqOc1y59qfay1nuA8ftuCjk(enHO2T92nbeQqnwEpubawDntrtiAhIoTI2Obk5yFTB8miRSJMpCuf2Ccw0(Er7qu72E7MacvOglVhQaaRUMPOakAcrbs0oeDAfTrduYDFkzbnvgEOi1(lyACuf2Ccw0(ErPUiF7O89PKO4su72E7UpLSGMkdpuKA)fmnUHsJVyI23lAhIA32B39PKf0uz4HIu7VGPX1mffWfw4VhvlSDJZZPiuTUvsgRBwa4cJQWMtWlGBHbtm)8M3JQfgaNrIIFGmcrrLOE4fw4VhvlmlXmpAYODM4TIw3kjJ19wa4cJQWMtWlGBH5N)O5Jfg55VjJCFL5TkgrtiAhIA32B3eqOc1y59qfay11mfTVxuYZFtg5yiEm5I66eTVxuGeL883KrUOSMlQRt0(ErTB7TZh5V8UHsJVyIIlrd)9OYzzIdKJ6I8TJY3NsIMqu72E78r(lVRzkkGIMquGeTdrz0LTrvJ5UNMK7MCYMEr77fDAfTrduYzoFkAG)GNJXh17ZMnolghvHnNGfnHO2T92zoFkAG)GNJXh17ZMnolghKG3irXLOjBiyIMqupcXHrwkNpYF5DdLgFXefCIAObw0eIcKODiQhbHQOox9qbD5DqI23lQhH4WilLZJkii8O8bIYmZF(J5gkn(Ijk4e1qdSOakAcrbs0oeDcp5UbX5I23lQhH4WilLZMggn49fu3qPXxmrbNOgAGffqrbu0(Erjp)nzK7RCuwfnHOajQDBVDwIzE0Kr7mXBf5AMI23lkZK48mOGDKO4suWC4m(enHOajAhI6rqOkQZbHQdK1r0(Er7qu72E7MacvOglVhQaaRUMPOakAFVOEeeQI6CqO6azDenHOmtIZZGc2rIIlrbZHZIc4cl83JQfg7Iz)dTWGjMFEZ7r1cdGZirXUy2)qIEirnhKxumepgrncp)nzKrff3aVbbyLxuqbtuoXyIEFkj6bkkrdrXpM4ajk1f5BhjkN2NOOruuXTkk(3Qye1i883KrI(mrBMorXp(dKOayYDJOjB6fLQJgrdrXq8ye1i883KrI(BrXjnolgrz3Z5IckyIYjgt0duuIMSHGjk7cpEmrJcwuCd8geGvErJcwuCJkii8irbfqirtrdj6bkkrn0aZef3gprhkn(6lOorb4ms0WgbHenz8bMbsuqb7irHBZxqff)oubawfnkyrto5KnqIckyhjQL)aHANO43HkaW66wjHZGTaWfgvHnNGxa3cdMy(5nVhvlmaoJef)yIdKOOdenwEgjQfqVhKOpt0VefdXJruJWZFtgzurXnWBqaw5ffnIEirnhKxu8VvXiQr45VjJwyH)EuTWSmXbADRKWzdxa4cJQWMtWlGBHf(7r1cBAvo83JQm)z3cdMy(5nVhvlm8BW5hOPTW4p7YvKslSDW5hOPTU1TUfgeAypQwjLmyjNmygcwYlmlXuFbLTWWpaE8tjbWsc)8UturbqqKOFQjAor3OruWJmPIgWl6qDB7hcwugkLenAhknocwupOOGsmNam8)ls0K7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))Ie1yDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGH)FrIIZDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGjad)a4XpLealj8Z7orffabrI(PMO5eDJgrbpmTJg)aVOd1TTFiyrzOus0ODO04iyr9GIckXCcWW)VirXPDNO4gvqO5iyrX(uClkZADrxIAGe9qII)Tqu4hYZEujkYKM4qJOazqaffid7cqNam8)lsuCA3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqj3fGoby4)xKOg4UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)Vir7MUtuCJki0CeSOyFkUfLzTUOlrnqIEirX)wik8d5zpQefzstCOruGmiGIcuYDbOtag()fjA30DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjA3R7ef3Occnhblk4NwrB0aLCga4f9qIc(Pv0gnqjNb4OkS5em4ffiJ1fGoby4)xKODVUtuCJki0CeSOG)MVWJoNHoda8IEirb)nFHhDUZqNbaErbk5Ua0jad))IeT71DIIBubHMJGff838fE05s2zaGx0djk4V5l8OZDj7maWlkqj3fGoby4)xKOgcw3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKOgAy3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKOgMC3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKOgASUtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirneFDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGH)FrIAioT7ef3Occnhblk4NwrB0aLCga4f9qIc(Pv0gnqjNb4OkS5em4ffOK7cqNam8)lsudXPDNO4gvqO5iyrb)nFHhDodDga4f9qIc(B(cp6CNHoda8IcuYDbOtag()fjQH40UtuCJki0CeSOG)MVWJoxYoda8IEirb)nFHhDUlzNbaErbYWUa0jad))Ie1qdC3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqj3fGoby4)xKOgAG7orXnQGqZrWIc(B(cp6Cg6maWl6Hef838fE05odDga4ffid7cqNam8)lsudnWDNO4gvqO5iyrb)nFHhDUKDga4f9qIc(B(cp6CxYoda8IcuYDbOtaMam8dGh)usaSKWpV7evuaeej6NAIMt0nAef8Md5rP2XbErhQBB)qWIYqPKOr7qPXrWI6bffuI5eGH)FrIASUtuCJki0CeSOG)MVWJoNHoda8IEirb)nFHhDUZqNbaErbYyDbOtag()fjko3DIIBubHMJGff838fE05s2zaGx0djk4V5l8OZDj7maWlkqgRlaDcWW)VirnWDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOXjQry8J)IcKHDbOtaMam8dGh)usaSKWpV7evuaeej6NAIMt0nAef8bIaVOd1TTFiyrzOus0ODO04iyr9GIckXCcWW)VirnS7ef3Occnhblk4NwrB0aLCga4f9qIc(Pv0gnqjNb4OkS5em4ffid7cqNam8)ls0K7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))Ien5UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGx04e1im(XFrbYWUa0jad))Ie1yDNO4gvqO5iyrb)fCQoNbaErpKOG)covNZaCuf2Ccg8IcKHDbOtag()fjQX6orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYyDbOtag()fjkoT7ef3Occnhblk2NIBrzwRl6sudKbs0djk(3crtrWnEJjkYKM4qJOazGauuGmSlaDcWW)VirXPDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOaLCxa6eGH)FrIAG7orXnQGqZrWII9P4wuM16IUe1azGe9qII)Tq0ueCJ3yIImPjo0ikqgiaffid7cqNam8)lsudC3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKODt3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKODVUtuCJki0CeSOyFkUfLzTUOlrnqIEirX)wik8d5zpQefzstCOruGmiGIcuYDbOtag()fjQHj3DIIBubHMJGff7tXTOmR1fDjQbs0djk(3crHFip7rLOitAIdnIcKbbuuGmSlaDcWW)VirneN7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))Ie1q81DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjQH40UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirnSB6orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))IenzW6orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbk5Ua0jad))Ien5K7orXnQGqZrWII9P4wuM16IUe1aj6Hef)BHOWpKN9OsuKjnXHgrbYGakkqg2fGoby4)xKOjJZDNO4gvqO5iyrX(uClkZADrxIAGe9qII)Tqu4hYZEujkYKM4qJOazqaffOK7cqNam8)ls0KX5UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirtgN2DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjAYg4UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirtU71DIIBubHMJGff7tXTOmR1fDjQbs0djk(3crHFip7rLOitAIdnIcKbbuuGsUlaDcWW)VirngyDNO4gvqO5iyrX(uClkZADrxIAGe9qII)Tqu4hYZEujkYKM4qJOazqaffid7cqNamby4hap(PKayjHFE3jQOaiis0p1enNOB0ik43bNFGMg4fDOUT9dblkdLsIgTdLghblQhuuqjMtag()fjAYDNO4gvqO5iyrX(uClkZADrxIAGe9qII)Tqu4hYZEujkYKM4qJOazqaffid7cqNamby4hap(PKayjHFE3jQOaiis0p1enNOB0ik4zh4fDOUT9dblkdLsIgTdLghblQhuuqjMtag()fjAYDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOaHVUa0jad))Ie1yDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGH)FrIIZDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGH)FrIIt7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErJtuJW4h)ffid7cqNam8)lsudbR7ef3Occnhblk4NwrB0aLCga4f9qIc(Pv0gnqjNb4OkS5em4ffOK7cqNam8)lsudX5UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirneN2DIIBubHMJGff7tXTOmR1fDjQbs0djk(3crHFip7rLOitAIdnIcKbbuuGmSlaDcWW)VirneN2DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8Ice(6cqNam8)lsudnWDNO4gvqO5iyrb)0kAJgOKZaaVOhsuWpTI2Obk5mahvHnNGbVOazyxa6eGH)FrIAy30DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjAYg2DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjAY4C3jkUrfeAocwuSpf3IYSwx0LOgirpKO4Flef(H8ShvIImPjo0ikqgeqrbcN7cqNam8)ls0KX5UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWW)VirtgFDNO4gvqO5iyrX(uClkZADrxIAGe9qII)Tqu4hYZEujkYKM4qJOazqaffid7cqNam8)ls0KXx3jkUrfeAocwuWpTI2Obk5maWl6Hef8tROnAGsodWrvyZjyWlkqg2fGoby4)xKOjJt7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))Ie1yg2DIIBubHMJGff7tXTOmR1fDjQbs0djk(3crHFip7rLOitAIdnIcKbbuuGmwxa6eGH)FrIAmd7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbYWUa0jad))Ie1yj3DIIBubHMJGff8tROnAGsoda8IEirb)0kAJgOKZaCuf2Ccg8IcKHDbOtag()fjQXmw3jkUrfeAocwuSpf3IYSwx0LOgirpKO4Flef(H8ShvIImPjo0ikqgeqrbYyDbOtag()fjQXW5UtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGsUlaDcWW)VirngoT7ef3Occnhblk4NwrB0aLCga4f9qIc(Pv0gnqjNb4OkS5em4ffOK7cqNam8)lsuJzG7orXnQGqZrWIc(Pv0gnqjNbaErpKOGFAfTrduYzaoQcBobdErbk5Ua0jad))Ie1yDVUtuCJki0CeSOGFAfTrduYzaGx0djk4NwrB0aLCgGJQWMtWGxuGmSlaDcWeGbWsnrZrWIItfn83Jkr5p7yobylmMj5xjziyjVWmh0(50cZinsrbUGhLNe14nThwaMrAKIIFj7PfJvrtgNAurtgSKtwaMamJ0iff3GIckX6obygPrkQXjkWddtWIIH4XikWrrQtaMrAKIACIIBqrbLGf9IbkD5FlQpyet0djQ3QNt5lgO0XCcWmsJuuJtu8tukccblARkYtmwmwffsmFyZjMOa9oYzurnhcsMDXWAdusuJdCIAoeeh7IH1gOeGobygPrkQXjkWdb9WIAoKpy3xqff)yIdKO)w0)apt0dejQLbvqf1i883KrobygPrkQXjQXxGhjkUrfeeEKOhisumZF(JjAik)VJtIMIgs0nN66T5KOa9BrTIAIckGlWFIc6pr)tu2N24xueQX4wf1YFGef4m(bEauuCikUjoXUp4Ic88hALs1zur)d8WIYW7nb0jaZinsrnorn(c8irtrStuWVFOGU8qPXxmWlkZtvmpIjAyAYTk6He1gXyIUFOGoMOOIB1jaZinsrnorbWHItuaeLsII2IcC8aKOahpajkWXdqIgmrdrzMK)dUO38fE05eGzKgPOgNOg)MurJOa9oYzurXpM4azurXpM4azurXUy2)qakAAatIMIgs0Hyp)P6e9qIsXWFAe1JsTJZ4yxmNtaMrAKIACIIF)UeT73xWdblQrKAISqtkvNOEqKhpr3OruCB8eTXcOKtaMamJ0iff4RcDXrWIcCbpkpjkWJtWFr9rjQnj6g1kyrJtuq3zY6odAq7GhLNmo2N6Dq)duZ29idcCbpkpzCyFkUnykSd0LY7(F)CQt7GhLNCxxNambyH)EuXCMd5rP2X1jEFbpeCMz(ZFmbygPOaiisuiX8HnNe9zIYOt0djkyIA5pqIwirzxCIIkrBms0B(cp6ygvudf1ciQe9arIU)HDIIks0NjkQeTXiJkAYI(BrpqKOmYJkyrFMOrblQXe93IAJoqIgdjal83JkMZCipk1ooC0PbHeZh2CYOvKsDIQCJr5B(cp6mkKG3Oobtaw4VhvmN5qEuQDC4OtdcjMpS5KrRiL6ev5gJY38fE0zuKzNbmSrHe8g1PHg93DEZx4rNZqhOGLBmkB327e38fE05m05riomYs5GBtCpQs0XnFHhDodDpZDOukJ25uuXUb1yzpQy3083JkMaSWFpQyoZH8Ou74WrNgesmFyZjJwrk1jQYngLV5l8OZOiZodyyJcj4nQZKn6V78MVWJoxYoqbl3yu2UT3jU5l8OZLSZJqCyKLYb3M4EuLOJB(cp6Cj7EM7qPugTZPOIDdQXYEuXUP5VhvmbygPOaiiIrIEZx4rht0yirl0jA0ouACVp4CRIcth5pcw0GjkQeTXirzxCIEZx4rhZjQOy0jkKy(WMtIEirXzrdMOhiYQObNHeTicwuMj5)GlkOOG5Fb1jal83JkMZCipk1ooC0PbHeZh2CYOvKsDIQCJr5B(cp6mkYSZag2OqcEJ6eNn6V7K622BAsWUVy(PDHnNYDBlQRLMHjiVN67PUT9MMeSJsnTouWZObUIYt99u32Ettc2XqnoNU7lO5PzBvaMrkkgDmrpqKOyxmS2aLe1JyNOB0ikpoAe1hCFJh3JkMOaTrJOuxrQjNe1ciQe9qIYUyorHBPMFbvuBAJgsu87qfayv0DW5mrr7nGcWc)9OI5mhYJsTJdhDAqiX8HnNmAfPuNmw2JyNrHe8g1PXadGaYqJdmxYaeJUSnQAm390KC3KXztpGcWmsrXOJjACIAb07bjAKIA1jkAlkWZWjIIBubbHhjkdeQXHf1MeTXi4UtuCgmrT8hiu7ef3eNy3hCrXm)5pMOrblQXatul)bYjal83JkMZCipk1ooC0PbHeZh2CYOvKsD6rfeeEuoyMgfsWBuNgdmCyiya00kAJgOKZtCIDFWZmZF(Jjal83JkMZCipk1ooC0PbtrOcVVYB0Kkal83JkMZCipk1ooC0PbTmXbYO8VOShUtdbZO)UtGip)nzKJ3QyYf1113tE(BYi3xzgIhtFp55VjJCFLTrhO(EYZFtg5IYAUOUoafGjaZiffNmKpyNOjlk(XehirJcw0quSlgwBGsIIkrXaqrT8hirt6Hc6ef)gKOrblkWHaEauu0ik2fZ(hsu0bIglpJeGf(7rfZHmPIgC0PbTmXbYO)UtGip)nzKJ3QyYf1113tE(BYi3xzgIhtFp55VjJCFLTrhO(EYZFtg5IYAUOUoatyoeeNHoltCGs0H5qqCj7SmXbsaw4VhvmhYKkAWrNgKDXS)Hmk)lk7H7eFg93D2X0kAJgOKZo4r5PmANdopFG(ckRVVdpccvrDU6Hc6Y7G677GzsCE(IbkDmh7IzhCENg233XfCQoxfxBiw2o4r5jhvHnNG77bI883KrogIhtUOUU(EYZFtg5(kZBvm99KN)MmY9v2gDG67jp)nzKlkR5I66auaw4VhvmhYKkAWrNgKDXS)Hmk)lk7H7eFg93DcuhtROnAGso7GhLNYODo488b6lOS((o8iiuf15QhkOlVdQVVdMjX55lgO0XCSlMDW5DAyFFhxWP6CvCTHyz7GhLNCuf2CcgWeDWOlBJQgZDpnj3n5Kn999arE(BYihdXJjxuxxFp55VjJCFL5TkM(EYZFtg5(kBJoq99KN)MmYfL1CrDDakal83JkMdzsfn4OtdYUyyTbkzu(xu2d3j(m6V7eOPv0gnqjNDWJYtz0ohCE(a9fuwcpccvrDU6Hc6Y7GsWmjopFXaLoMJDXSdoVtdbmrhm6Y2OQXC3ttYDtoztVambygPrkQr0f5BhblkbHgRIEFkj6bIen8hAe9zIgqINh2CYjal83JkwNmepMSnfPcWc)9OIHJonOp48C4Vhvz(ZoJwrk1jYKkAmk7M3FDAOr)DN3Ns4cOKbOWFpQCwM4a58b7Y3Ns4i83Jkh7Iz)d58b7Y3NsakaZiffJoMOapYiefvIAmCiQL)aHANOWZVprJcwul)bsuSlgoAGfnkyrtghIIoq0y5zKaSWFpQy4OtdcjMpS5KrRiL68z5argfsWBuNmtIZZxmqPJ5yxm7GZbNHjaQJl4uDo2fdhnWoQcBob33FbNQZXoIZJjdp)(Cuf2CcgW(EMjX55lgO0XCSlMDW5GlzbygPOy0Xe1ZPacjQfqujk2fZ(hsuFuIc6prtghIEXaLoMOwa9EqI(mrhItqI6eDJgrpqKOgHN)Mms0djQnjQ5qBAgcw0OGf1cO3ds09Z50i6He1hStaw4VhvmC0PbHeZh2CYOvKsD(SSNtbeYOqcEJ6KzsCE(IbkDmh7Iz)dbodfGzKI29nMpS5KOhO4e1dI84Xe93IAf1engs0VenefQhw0djAab9WIEGirz)1I7rLOwardjAi6nFHhDIsNx0NjAJrWI(LO20zHOsuFWoMaSWFpQy4OtdcjMpS5KrRiL68RmupSrHe8g1P5qqYq9WodDPiuT)H67nhcsgQh2zOJ1Q9puFV5qqYq9WodDSlgwBGs99Mdbjd1d7m0XUy2bN33BoeKmupSZq3UnwZODM4TI67nhcIBciuHAS8EOcaS23B32BNpYF5DdLgFX60UT3oFK)Y7GBtCpQ67HeZh2CY9SCGibygPOaCgjkWrdJg8(cQOXj6bIeLkyrrBrXVdvaGvrTaIkrbfSJe9zIg2iiKO4uWmqgv0yF0ikUrfeeEKOrblk6arJLNrIA5pqIIBG3GaSYlal83Jkgo60G20WObVVGA0F3jqa1HhbHQOox9qbD5Dq99D4riomYs58OcccpkFGOmZ8N)yUMzF)0kAJgOKZtCIDFWZmZF(Jbyc72E78r(lVBO04lg4meFjSB7TBciuHAS8EOcaS6gkn(IHlCorhEeeQI6CqO6azD679iiuf15Gq1bY6KWUT3oFK)Y7AMjSB7TBciuHAS8EOcaS6AMjaYUT3UjGqfQXY7HkaWQBO04lgU60WKnoCgGMwrB0aLCSV2nEgKv2rZh992T925J8xE3qPXxmCzOH99gAGyMeNNbfSJWLHoCkGaMasmFyZj3xzOEybygPO4e0jQL)ajAikUbEdcWkVOhO4e9zf4prdrXjnolgrnhKxu0iQfquj6bIeD)qbDI(mrdBu7e9qIsfSaSWFpQy4OtdAIUhvg93DcKDBVD(i)L3nuA8fdCgIVea1X0kAJgOKJ91UXZGSYoA(OV3UT3UjGqfQXY7HkaWQBO04lgUmS7LWUT3UjGqfQXY7HkaWQRzcyFVnIXsSFOGU8qPXxmCLm(ambKy(WMtUVYq9WcWmsrXDW9nECetulGOdenI2yFbvuCJkii8irlKfrT8CUObNJSiQvut0djk7EoxuFWorpqKOSiLensrT6efTff3Occcpch4g4niaR8I6d2XeGf(7rfdhDAqiX8HnNmAfPuNEubbHhLHjM1YBuibVrD6PNdeq7hkOlpuA8fZ4meFgNhH4WilLZh5V8UHsJVyaAGmSBadWo90ZbcO9df0Lhkn(IzCgIpJZJqCyKLY5rfeeEu(arzM5p)XCWTjUhvgNhH4WilLZJkii8O8bIYmZF(J5gkn(IbObYWUbmat0XepCMGq15cyyMJ66zhlbqD4riomYs58r(lVBOa2AFFhEeIdJSuopQGGWJCdfWwbSV3JqCyKLY5J8xE3qPXxmW91rJjIhhbN3puqxEO04lwF)0kAJgOKZtCIDFWZmZF(JLWJqCyKLY5J8xE3qPXxmWzmW679iehgzPCEubbHhLpquMz(ZFm3qPXxmW91rJjIhhbN3puqxEO04lMXziy99D4rqOkQZvpuqxEhKamJuuaoJGf9qIct8WQOhis0glGsII2IIBG3GaSYlQfqujAJ9furHrnBojkQeTXirJcwuZHGq1jAJfqjrTaIkrJs0agwuccvNOpt0Wg1orpKOWpjal83Jkgo60GqI5dBoz0ksPo9WzpQG)7rLrHe8g1jqxmqPZDFkLpug(jWzi(67N4HZeeQoxadZCFbo8bgGjaciQBBVPjb7OutRdf8mAGRO8ucG6WJGqvuNdcvhiRtFVhH4WilLJsnTouWZObUIYtUHsJVy4YqCQbghaHpaAAfTrduYX(A34zqwzhnFaiGj6WJqCyKLYrPMwhk4z0axr5j3qbSva77PUT9MMeSJHACoD3xqZtZ2AcG6WJGqvuNREOGU8oO(EpcXHrwkhd14C6UVGMNMT1SXWz81nGzOBO04lgUm0qCgW(EG8iehgzPC20WObVVG6gkGT233XeEYDdIZ779iiuf15QhkOlVdcWea1XfCQo3UnwZODM4TICuf2CcUV3JGqvuNdcvhiRtcpcXHrwk3UnwZODM4TICdLgFXWLHgId8bqtROnAGso2x7gpdYk7O5J((o8iiuf15Gq1bY6KWJqCyKLYTBJ1mANjERi3qPXxmCz32BNpYF5DWTjUhv4WWKbOPv0gnqjN58POb(dEogFuVpB24SymodtgWeabe1TT30KGDFX8t7cBoL72wuxlndtqEpLWJqCyKLY9fZpTlS5uUBBrDT0mmb59KBOa2kG99arDB7nnjyhduaJSqWz0yNr78HMuQUeEeIdJSuUdnPuDeC(l2df0Lng(WNXs2q3qPXxma77bciiX8HnNCOk3yu(MVWJUonSVhsmFyZjhQYngLV5l8ORtJbycGU5l8OZzOBOa2A2JqCyKLQV)MVWJoNHopcXHrwk3qPXxmW91rJjIhhbN3puqxEO04lMXziya23djMpS5Kdv5gJY38fE01zYja6MVWJoxYUHcyRzpcXHrwQ((B(cp6Cj78iehgzPCdLgFXa3xhnMiECeCE)qbD5HsJVygNHGbyFpKy(WMtouLBmkFZx4rxNGbiGakaZifT7BmFyZjrBmcw0djkmXdRIgLvrV5l8OJjAuWI6HzIAbevIAj(7lOIUrJOrjQr0mbHMpe1CqEbyH)EuXWrNgesmFyZjJwrk15bAEopZicpAYwI)mkKG3Oo7GHAC7VGDhO558mJi8OXrvyZj4((9df0Lhkn(IbUKbdS(EBeJLy)qbD5HsJVy4kz8HdGWzWmo72E7oqZZ5zgr4rJJDHhpakza77TB7T7anpNNzeHhno2fE8aNX6gJdOPv0gnqjh7RDJNbzLD08baLmGcWmsrb4msuJi106qbxuJ)bUIYtIMmymYZe1M2OHenef3aVbbyLx0gJefnIYqIEGIt0)e1YZ5IY)IeTzkQL)aj6bIeLkyrrBrXVdvaGvbyH)EuXWrNgSXO8FuQrRiL6KsnTouWZObUIYtg93D6riomYs58r(lVBO04lgUsgSeEeIdJSuopQGGWJYhikZm)5pMBO04lgUsgSeabjMpS5K7anpNNzeHhnzlXF992T92DGMNZZmIWJgh7cpEGZyGHdGMwrB0aLCSV2nEgKv2rZhaKXaeWeqI5dBo5(kd1d33BJySe7hkOlpuA8fdxgZalaZiffGZirXqnoNUVGkk(PMTvrXPmYZe1M2OHenef3aVbbyLx0gJefnIYqIEGIt0)e1YZ5IY)IeTzkQL)aj6bIeLkyrrBrXVdvaGvbyH)EuXWrNgSXO8FuQrRiL6KHACoD3xqZtZ2Qr)DNa5riomYs58r(lVBO04lgUWPj6WJGqvuNdcvhiRtIo8iiuf15QhkOlVdQV3JGqvuNREOGU8oOeEeIdJSuopQGGWJYhikZm)5pMBO04lgUWPjacsmFyZjNhvqq4rzyIzT899EeIdJSuoFK)Y7gkn(IHlCkG99EeeQI6CqO6azDsauhtROnAGso2x7gpdYk7O5JeEeIdJSuoFK)Y7gkn(IHlCAFVDBVDtaHkuJL3dvaGv3qPXxmCziy4ai8bqu32Ettc29f7MM)qdld)q(IY2eNdyc72E7MacvOglVhQaaRUMjG992iglX(Hc6YdLgFXWvY4RVN622BAsWok106qbpJg4kkpLWJqCyKLYrPMwhk4z0axr5j3qPXxmWLmyaMasmFyZj3xzOE4eDqDB7nnjy3xm)0UWMt5UTf11sZWeK3t99EeIdJSuUVy(PDHnNYDBlQRLMHjiVNCdLgFXaxYG13BJySe7hkOlpuA8fdxjdMamJuuGNBjSYeTXirbyDFA8e1YFGef3aVbbyLxu0iACIEGirPcwu0wu87qfayvaw4VhvmC0PbHeZh2CYOvKsD(DlC2Jk4)EuzuibVrDA32BNpYF5DdLgFXaNH4lbqDmTI2Obk5yFTB8miRSJMp67TB7TBciuHAS8EOcaS6gkn(IHRoneFo8HdGmMdFaKDBVD2CecM3yNRzcioacND4Z4mMdFaKDBVD2CecM3yNRzciarDB7nnjy3xSBA(dnSm8d5lkBtCEc72E7MacvOglVhQaaRUMjG992iglX(Hc6YdLgFXWvY4RVN622BAsWok106qbpJg4kkpLWJqCyKLYrPMwhk4z0axr5j3qPXxmbyH)EuXWrNgSXO8FuQrRiL68lMFAxyZPC32I6APzycY7jJ(7oHeZh2CY9DlC2Jk4)EuLasmFyZj3xzOEybygPOaCgjkgOagzHGf14FSf1M2OHef3aVbbyLxaw4VhvmC0PbBmk)hLA0ksPozGcyKfcoJg7mANp0Ks1z0F3jqEeIdJSuoFK)Y7gkGTMOdpccvrDU6Hc6Y7GsajMpS5K7anpNNzeHhnzlXFjaYJqCyKLYztdJg8(cQBOa2AFFht4j3niohW(EpccvrDU6Hc6Y7Gs4riomYs58OcccpkFGOmZ8N)yUHcyRjacsmFyZjNhvqq4rzyIzT899EeIdJSuoFK)Y7gkGTciGjGrNJ1Q9pK7EpEFbnbqWOZXoIZJjV5XqU7949f0((oUGt15yhX5XK38yihvHnNG77zMeNNVyGshZXUy2)qGZyaMagDUueQ2)qU7949f0eabjMpS5K7z5ar99tROnAGso7GhLNYODo488b6lOS((GDtWZMil0aUo7EG13djMpS5KZJkii8OmmXSw((E72E7S5iemVXoxZeWeDqDB7nnjy3xm)0UWMt5UTf11sZWeK3t99u32Ettc29fZpTlS5uUBBrDT0mmb59ucpcXHrwk3xm)0UWMt5UTf11sZWeK3tUHsJVyGZyGLOd72E78r(lVRz23BJySe7hkOlpuA8fdx4mycWmsrbqqpt0NjAi6ehiAeL4HnAIJe1syv0djAAGhjAW5IIkrBmsu2fNO38fE0Xe9qIAtIY)IGfTzkQL)ajkUbEdcWkVOrblkUrfeeEKOrblAJrIEGirtUGfLXrNOOsupSO)wuB0bs0B(cp6yIgdjkQeTXirzxCIEZx4rhtaw4VhvmC0PbBmk)hLYmkJJowN38fE0zOr)DNabjMpS5Kdv5gJY38fE01rNgMOJB(cp6Cj7gkGTM9iehgzP67bcsmFyZjhQYngLV5l8ORtd77HeZh2CYHQCJr5B(cp660yaMai72E78r(lVRzMaOo8iiuf15Gq1bY603B32B3eqOc1y59qfay1nuA8fdhazmh(aOPv0gnqjh7RDJNbzLD08bG4QZB(cp6Cg6SB7DgUnX9OkHDBVDtaHkuJL3dvaGvxZSV3UT3UjGqfQXY7HkaWAM91UXZGSYoA(W1mbSV3JqCyKLY5J8xE3qPXxmCKm4U5l8OZzOZJqCyKLYb3M4EuLOd72E78r(lVRzMaOo8iiuf15QhkOlVdQVVdiX8HnNCEubbHhLHjM1YdyIo8iiuf15WZ68r137rqOkQZvpuqxEhuciX8HnNCEubbHhLHjM1YNWJqCyKLY5rfeeEu(arzM5p)XCnZeD4riomYs58r(lVRzMaiGSB7TJ883KrzERIXnuA8fdCgcwFVDBVDKN)MmkZq8yCdLgFXaNHGbyIoMwrB0aLC2bpkpLr7CW55d0xqz99az32BNDWJYtz0ohCE(a9fuwUIRnKJDHhVoXxFVDBVD2bpkpLr7CW55d0xqz5y8rro2fE86SBaeW(E72E7W7l4HGZuQjYcnPuDzQOb6daKRzcyFVnIXsSFOGU8qPXxmCLmy99qI5dBo5qvUXO8nFHhDDcgGjGeZh2CY9vgQhwaw4VhvmC0PbBmk)hLYmkJJowN38fE0LSr)DNabjMpS5Kdv5gJY38fE01rNjNOJB(cp6Cg6gkGTM9iehgzP67HeZh2CYHQCJr5B(cp66m5eaz32BNpYF5DnZea1HhbHQOoheQoqwN(E72E7MacvOglVhQaaRUHsJVy4aiJ5WhanTI2Obk5yFTB8miRSJMpaexDEZx4rNlzNDBVZWTjUhvjSB7TBciuHAS8EOcaS6AM992T92nbeQqnwEpubawZSV2nEgKv2rZhUMjG99EeIdJSuoFK)Y7gkn(IHJKb3nFHhDUKDEeIdJSuo42e3JQeDy32BNpYF5DnZea1HhbHQOox9qbD5Dq99DajMpS5KZJkii8OmmXSwEat0HhbHQOohEwNpQea1HDBVD(i)L31m777WJGqvuNdcvhiRdG99EeeQI6C1df0L3bLasmFyZjNhvqq4rzyIzT8j8iehgzPCEubbHhLpquMz(ZFmxZmrhEeIdJSuoFK)Y7AMjaci72E7ip)nzuM3QyCdLgFXaNHG13B32Bh55VjJYmepg3qPXxmWziyaMOJPv0gnqjNDWJYtz0ohCE(a9fuwFpq2T92zh8O8ugTZbNNpqFbLLR4Ad5yx4XRt813B32BNDWJYtz0ohCE(a9fuwogFuKJDHhVo7gabeW(E72E7W7l4HGZuQjYcnPuDzQOb6daKRz23BJySe7hkOlpuA8fdxjdwFpKy(WMtouLBmkFZx4rxNGbyciX8HnNCFLH6HfGzKIcWzet0GZffDGOruujAJrI(hLYefvI6HfGf(7rfdhDAWgJY)rPmbygPOgXFGOruOir)6qIEGirzNOOr0arIg(7rLO8NDcWc)9OIHJon40QC4Vhvz(ZoJwrk1zGiJYU59xNgA0F3jKy(WMtUNLdejal83Jkgo60GtRYH)EuL5p7mAfPuNStaMamJuuChCFJhhXe1ci6arJOhisuJ3qrQpopiAe1UT3IA55Cr3bNlkAVf1YFG(s0dejArDDI6d2jal83JkMlquNqI5dBoz0ksPoHhksZwEopVdopJ2BJcj4nQZPv0gnqj39PKf0uz4HIu7VGPjbq2T92DFkzbnvgEOi1(lyACdLgFXWfupSln6chG5mSV3UT3U7tjlOPYWdfP2FbtJBO04lgUc)9OYXUy2)qoQlY3okFFkHdWCgMaiYZFtg5(kZBvm99KN)MmYXq8yYf1113tE(BYixuwZf11biGjSB7T7(uYcAQm8qrQ9xW04AMcWmsrXDW9nECetulGOdenIIDXWAdus0NjQf0CGe1hS7lOIIGqJOyxm7Fir)su8VvXiQr45VjJeGf(7rfZfichDAqiX8HnNmAfPuNp0cnuMDXWAduYOqcEJ6SdYZFtg5(kZq8ysWmjopFXaLoMJDXS)HaNb24UGt15yOgpJ25deL3OHyNJQWMtWauY4G883KrUVY2OduIoMwrB0aLCMZNIg4p45y8r9(SzJZIjrhtROnAGsourhiw2ZPyYqE2JkbygPOaCgjkUrfeeEKOwarLOXjkNymrpqrjk(atuGNHtenkyr5FrI2mf1YFGef3aVbbyLxaw4VhvmxGiC0Pb9OcccpkFGOmZ8N)yg93D2b80EyxHYEywcGacsmFyZjNhvqq4rzyIzT8j6WJqCyKLY5J8xE3qbS1(E72E78r(lVRzcycGSB7TJ883KrzERIXnuA8fdC4RV3UT3oYZFtgLziEmUHsJVyGdFaMaOGDtWZMil0Gl8bwcGyMeNNVyGshZXUy2)qGZy992T925J8xExZeW((oMwrB0aLCMZNIg4p45y8r9(SzJZIbWea1XfCQoh7iopMm887RV3UT3o2fZo4C3qPXxmCzOdFghyo8bqtROnAGsopXj29bpZm)5pwFVDBVD(i)L3nuA8fdx2T92XUy2bN7gkn(IHd8LWUT3oFK)Y7AMaMaOoMwrB0aLC2bpkpLr7CW55d0xqz992T92zh8O8ugTZbNNpqFbLLR4Ad5yx4XdCgRV3UT3o7GhLNYODo488b6lOSCm(Oih7cpEGZya23BJySe7hkOlpuA8fdxgcwcpcXHrwkNpYF5DdLgFXah(auaMrkkaNrII1Q9pKOFjQzuWu67ffvIgL1d0xqf9afNO8hcXe1qCMrEMOrblkNymrT8hirtrdj6fdu6yIgfSOXj6bIeLkyrrBrdrXq8ye1i883KrIgNOgIZIYiptu0ikNymrhkn(6lOIgmrpKOf6efua5lOIEirhApedKOWT5lOII)Tkgrncp)nzKaSWFpQyUar4OtdYA1(hYOEREoLVyGshRtdn6V7eOH2dXaf2CQV3UT3oYZFtgLziEmUHsJVy4Yyjip)nzK7RmdXJjXqPXxmCzioN4covNJHA8mANpquEJgIDoQcBobdyIlgO05UpLYhkd)e4meNnoMjX55lgO0XWXqPXxSearE(BYi3x5OS23puA8fdxq9WU0OlafGzKIcWzKOyTA)dj6HefuaHenefkhzhCrpKOngjkaR7tJNaSWFpQyUar4OtdYA1(hYO)UtiX8HnNCF3cN9Oc(Vhvj8iehgzPCFX8t7cBoL72wuxlndtqEp5gkGTMG622BAsWUVy(PDHnNYDBlQRLMHjiVNseMzpiYJNamJu0UFezkAZuuSlMDW5IgNObNl69Pet0wXjgt0g7lOII)w9XemrJcw0)e9zIg2O2j6He1CqErrJOC6e9arIYmj)hCrd)9Osu(xKO2ehzruqrbZjrnEdfP2FbtJOOs0Kf9IbkDmbyH)EuXCbIWrNgKDXSdo3O)UZoUGt15yhX5XKHNFFoQcBobNaOoy0LTrvJ5UNMK7MmoB677jp)nzK7RCuw77zMeNNVyGshZXUy2bNdoJbycGSB7TJDXSdo3n0EigOWMtjaIzsCE(IbkDmh7IzhCoUmwFFhtROnAGsU7tjlOPYWdfP2FbtdG99xWP6CmuJNr78bIYB0qSZrvyZj4e2T92rE(BYOmdXJXnuA8fdxglb55VjJCFLziEmjSB7TJDXSdo3nuA8fdxg4emtIZZxmqPJ5yxm7GZbxN4mGjaQJPv0gnqjh3QpMGL3CIUVGMHY)utg13FFkzGmq4m(aNDBVDSlMDW5UHsJVy4izatCXaLo39Pu(qz4Nah(eGzKIIF8hirXoIZJruJ387t0gJefvI6Hf1ciQeDO9qmqHnNe1UDIYUNZf1s8NOB0ik(B1htWe1CqErJcwuyub(t0gJe1M2OHef3gpMtuS75CrBmsuBAJgsuCJkii8irzF5jrpqXjQLNZf1CqErJcDGOruSlMDW5cWc)9OI5ceHJoni7IzhCUr)DNxWP6CSJ48yYWZVphvHnNGty32Bh7IzhCUBO9qmqHnNsauhm6Y2OQXC3ttYDtgNn999KN)MmY9vokR99mtIZZxmqPJ5yxm7GZbhodycG6yAfTrduYXT6Jjy5nNO7lOzO8p1Kr993NsgideoJpWHZaM4IbkDU7tP8HYWpboJjaZiff)4pqIA8gksT)cMgrBmsuSlMDW5IEirXJitrBMIEGirTB7TO2wfn4mKOn2xqff7IzhCUOOsu8jkJ8OcMjkAeLtmMOdLgF9fubyH)EuXCbIWrNgKDXSdo3O)UZPv0gnqj39PKf0uz4HIu7VGPjbZK488fdu6yo2fZo4CW1PXsauh2T92DFkzbnvgEOi1(lyACnZe2T92XUy2bN7gApeduyZP(EGGeZh2CYbpuKMT8CEEhCEgT3jaYUT3o2fZo4C3qPXxmCzS(EMjX55lgO0XCSlMDW5Gl5exWP6CSJ48yYWZVphvHnNGty32Bh7IzhCUBO04lgUWhGacOamJuuChCFJhhXe1ci6arJOHOyxmS2aLeTXirT8CUO(OXirXUy2bNl6HeDhCUOO92OIgfSOngjk2fdRnqjrpKO4rKPOgVHIu7VGPru2fE8eTz6eTBat0Nj6bIeDOUT9dblkWZWjIEir9b7ef7IH1gOeoWUy2bNlal83JkMlqeo60GqI5dBoz0ksPozxm7GZZwq1L3bNNr7TrHe8g1zWUj4ztKfAax3agabKHghJUSnQAm390KC3Kt20dqG5sgqacidno72E7UpLSGMkdpuKA)fmno2fE8aiWCgcOXbKDBVDSlMDW5UHsJVyaKXmqmtIZZGc2rauhxWP6CSJ48yYWZVphvHnNGb04aYJqCyKLYXUy2bN7gkn(IbqgZaXmjopdkyhbqxWP6CSJ48yYWZVphvHnNGb04aYUT3UDBSMr7mXBf5gkn(Ibq4dWeaz32Bh7IzhCURz237riomYs5yxm7GZDdLgFXauaMrkkaNrIIDXWAdusul)bsuJ3qrQ9xW0i6HefpImfTzk6bIe1UT3IA5pqO2jkhX(cQOyxm7GZfTzEFkjAuWI2yKOyxmS2aLefvIIZ4quGdb8aOOSl84XeTv3ZffNf9IbkDmbyH)EuXCbIWrNgKDXWAduYO)UtiX8HnNCWdfPzlpNN3bNNr7DciX8HnNCSlMDW5zlO6Y7GZZO9orhqI5dBo5EOfAOm7IH1gOuFpq2T92zh8O8ugTZbNNpqFbLLR4Ad5yx4XdCgRV3UT3o7GhLNYODo488b6lOSCm(Oih7cpEGZyaMGzsCE(IbkDmh7IzhCoUW5eqI5dBo5yxm7GZZwq1L3bNNr7TamJuuaoJeLzjMurzirpqXjQvutuO0jAA0LOnZ7tjrTTkAJ9fur)t0Gjkpos0GjQjIXEBojkQeLtmMOhOOe1yIYUWJhtu0iA3hn2jQfqujQXWHOSl84XeL6Y8hsaw4VhvmxGiC0Pbd4W8EiuMzjMuJ6T65u(IbkDSon0O)UZoU3J3xqt0r4VhvUaomVhcLzwIjndhPbuY9vEZFOGU(Ey05c4W8EiuMzjM0mCKgqjh7cpE4YyjGrNlGdZ7HqzMLysZWrAaLCdLgFXWLXeGzKIIFI2dXajQXhcv7Fir)TO4g4niaR8I(mrhkGTAurpq0qIgdjkNymrpqrjk(e9IbkDmr)su8VvXiQr45VjJe1YFGefdD4xJkkNymrpqrjQHGjk6arJLNrI(LOrzvuJWZFtgjkAeTzk6HefFIEXaLoMO20gnKOHO4FRIruJWZFtg5e14HkWFIo0EigirHBZxqfT73xWdblQrKAISqtkvNOTItmMOFjkgIhJOgHN)Mmsaw4VhvmxGiC0PbtrOA)dzuVvpNYxmqPJ1PHg93Do0EigOWMtjUyGsN7(ukFOm8tGdiGmeNXbqmtIZZxmqPJ5yxm7FiakzaYUT3oYZFtgL5TkgxZeqaXXqPXxmanqazioUGt15olFLtrOI5OkS5emGg93DcuyM9GipE99qI5dBo5EOfAOm7IH1gOuFFhKN)MmY9vokRaMaipcXHrwkNpYF5DdfWwtqE(BYi3x5OSMOd4P9WUcL9WSeabjMpS5KZJkii8OmmXSw((EpcXHrwkNhvqq4r5deLzM)8hZnuaBTVVdpccvrDU6Hc6Y7GaSVNzsCE(IbkDmh7Iz)dHlGacNACaz32Bh55VjJY8wfJRzcqjdiGaeqgIJl4uDUZYx5ueQyoQcBobdiGj6G883KrogIhtUOUUeD4riomYs58r(lVBOa2AFpqKN)MmY9vMH4X03B32Bh55VjJY8wfJRzMOJl4uDogQXZOD(ar5nAi25OkS5eCFVDBVDMZNIg4p45y8r9(SzJZIXbj4ncCDMm(adWeaXmjopFXaLoMJDXS)HWLHGbqazioUGt15olFLtrOI5OkS5emGaMiy3e8SjYcnGdFGzC2T92XUy2bN7gkn(Ibq4uatauhEeeQI6C4zD(O677WUT3o8(cEi4mLAISqtkvxMkAG(aa5AM99KN)MmY9vMH4XayIoSB7TBciuHAS8EOcaSMzFTB8miRSJMpCntbygPOaCgjk(fLKOOsupSOw(deQDI6dtZVGkal83JkMlqeo60GB04PmANR4Adz0F3zyM9GipE99qI5dBo5EOfAOm7IH1gOKaSWFpQyUar4OtdcjMpS5KrRiL60dN9Oc(Vhv5argfsWBuNDapTh2vOShMLaiiX8HnNCE4ShvW)9Okbq2T92XUy2bN7AM99xWP6CSJ48yYWZVphvHnNG779iiuf15QhkOlVdcWeWOZLIq1(hYDVhVVGMaOoSB7TJH4S79KRzMOd72E78r(lVRzMaOoUGt152TXAgTZeVvKJQWMtW992T925J8xEhCBI7rf48iehgzPC72ynJ2zI3kYnuA8fdhDdGjaQdgDzBu1yU7Pj5UjNSPVVN883KrUVY8wftFp55VjJCmepMCrDDaMasmFyZj3bAEopZicpAYwI)sauhEeeQI6C1df0L3b137riomYs58OcccpkFGOmZ8N)yUHsJVy4YUT3oFK)Y7GBtCpQaiWC4dWexmqPZDFkLpug(jWz32BNpYF5DWTjUhvaeyodmG992iglX(Hc6YdLgFXWLDBVD(i)L3b3M4EuHddtgGMwrB0aLCMZNIg4p45y8r9(SzJZIbqbygPOaCgjk(DOcaSkQL)ajkUbEdcWkVaSWFpQyUar4OtdobeQqnwEpubawn6V70UT3oFK)Y7gkn(IbodXxFVDBVD(i)L3b3M4EuHddtgGMwrB0aLCMZNIg4p45y8r9(SzJZIbxjJttajMpS5KZdN9Oc(Vhv5arcWmsrb4msuCd8geGvErrLOEyrBfNymrJcwu(xKO)jAZuul)bsuCJkii8ibyH)EuXCbIWrNg0tCIDFWZb)HwPuDg93DcjMpS5KZdN9Oc(Vhv5arjaYUT3oFK)Y7GBtCpQWHHjdqtROnAGsoZ5trd8h8Cm(OEF2SXzXaUotgN233HhbHQOoheQoqwha77TB7TBciuHAS8EOcaS6AMjSB7TBciuHAS8EOcaS6gkn(IHRUho8OcU9NZCi)ZOCWFOvkvN7(ukdj4ncha1HDBVD2CecM3yNRzMOJl4uDo2fdhnWoQcBobdOaSWFpQyUar4Otd(LpMkUhvg93DcjMpS5KZdN9Oc(Vhv5arcWmsrb4msuJi1ezHgrboublkQe1dlQL)ajk2fZo4CrBMIgfSOSacj6gnIItACwmIgfSO4g4niaR8cWc)9OI5ceHJoniLAISqt2gvWg93DcKhH4WilLZh5V8UHsJVy4WUT3oFK)Y7GBtCpQWX0kAJgOKZC(u0a)bphJpQ3NnBCwmaKHjdopcXHrwkhLAISqt2gvWo42e3JkCyiya23B32BNpYF5DdLgFXax303dpTh2vOShMjaZiff)eThIbs0npgsuujAZu0djQXe9IbkDmrT8hiu7ef3aVbbyLxuB6lOIg2O2j6HeL6Y8hs0OGfTqNOii04dtZVGkal83JkMlqeo60GSJ48yYBEmKr9w9CkFXaLowNgA0F35q7HyGcBoL4(ukFOm8tGZq8LGzsCE(IbkDmh7Iz)dHlCoryM9GipEjaYUT3oFK)Y7gkn(IbodbRVVd72E78r(lVRzcOamJuuaoJef)Imcr)TOFXEys0Oe1i883KrIgfSO8Vir)t0MPOw(dKOHO4KgNfJOMdYlAuWIc8WH59qirXSetQaSWFpQyUar4OtdUBJ1mANjERiJ(7ojp)nzK7RCuwtauyM9GipE99DmTI2Obk5mNpfnWFWZX4J69zZgNfdGjaYUT3oZ5trd8h8Cm(OEF2SXzX4Ge8gHRKXhy992T925J8xE3qPXxmW1naMaiy05c4W8EiuMzjM0mCKgqj39E8(cAFFhEeeQI6Cf5hehnW99mtIZZxmqPJbUKbmbq2T92nbeQqnwEpubawDdLgFXWv3Z4acNbOPv0gnqjh7RDJNbzLD08bGjSB7TBciuHAS8EOcaS6AM99Dy32B3eqOc1y59qfay11mbmbqD4riomYs58r(lVRz23B32B3bAEopZicpACSl84HldXxI9df0Lhkn(IHRKbdSe7hkOlpuA8fdCgcgy99DWqnU9xWUd08CEMreE04OkS5emGjaIHAC7VGDhO558mJi8OXrvyZj4(EpcXHrwkNpYF5DdLgFXaNXadWexmqPZDFkLpug(jWHV(EBeJLy)qbD5HsJVy4YqWeGzKIcWzKOHOyxm7GZf14VOdKOMdYlAR4eJjk2fZo4CrFMObFOa2QOntrrJOwrnrJHenSrTt0djkccn(WuuGNHteGf(7rfZfichDAq2fZo4CJ(7oTB7Tdv0bILnPXtM3JkxZmbq2T92XUy2bN7gApeduyZP((GDtWZMil0aUUhyakaZif141snff4z4erTPnAirXnQGGWJe1YFGef7IzhCUOrbl6bIkrXUyyTbkjal83JkMlqeo60GSlMDW5g93D6rqOkQZvpuqxEhuIoUGt15yhX5XKHNFFoQcBobNaiiX8HnNCEubbHhLHjM1Y337riomYs58r(lVRz23B32BNpYF5Dntat4riomYs58OcccpkFGOmZ8N)yUHsJVy4cQh2LgDbqE65afSBcE2ezHgde(adWe2T92XUy2bN7gkn(IHlCorhWt7HDfk7HzcWc)9OI5ceHJoni7IH1gOKr)DNEeeQI6C1df0L3bLaiiX8HnNCEubbHhLHjM1Y337riomYs58r(lVRz23B32BNpYF5Dntat4riomYs58OcccpkFGOmZ8N)yUHsJVy4cFjGeZh2CYXUy2bNNTGQlVdopJ27eKN)MmY9vokRj6asmFyZj3dTqdLzxmS2aLs0b80EyxHYEyMamJuuaoJef7IH1gOKOw(dKOrjQXFrhirnhKxu0i6Vf1kQbEyrrqOXhMIc8mCIOw(dKOwrTr0I66e1hSZjkWZzirHBPMIc8mCIOXj6bIeLkyrrBrpqKODFP6azDe1UT3I(BrXUy2bNlQfuJdxG)eDhCUOO9wu0iQvut0yirrLOjl6fdu6ycWc)9OI5ceHJoni7IH1gOKr)DN2T92Hk6aXYEoftgYZEu5AM99a1b7Iz)d5cZShe5XlrhqI5dBo5EOfAOm7IH1gOuFpq2T925J8xE3qPXxmCHVe2T925J8xExZSVhiGSB7TZh5V8UHsJVy4cQh2LgDbqE65afSBcE2ezHgdeKy(WMtogl7rSdWe2T925J8xExZSV3UT3UjGqfQXY7HkaWAM91UXZGSYoA(WnuA8fdxq9WU0OlaYtphOGDtWZMil0yGGeZh2CYXyzpIDaMWUT3UjGqfQXY7HkaWAM91UXZGSYoA(W1mbmHhbHQOoheQoqwhabmbqmtIZZxmqPJ5yxm7GZXLX67HeZh2CYXUy2bNNTGQlVdopJ2BabmrhqI5dBo5EOfAOm7IH1gOucG6yAfTrduYDFkzbnvgEOi1(lyA67zMeNNVyGshZXUy2bNJlJbOamJuuaoJe14dHkMOFjkgIhJOgHN)Mms0OGfLfqirXVnoxuJpeQeDJgrXnWBqaw5fGf(7rfZfichDAWISKtrOYO)UtGSB7TJ883KrzgIhJBO04lg4OUiF7O89PuFpqEqXaLyDMCIH8GIbkLVpLWf(aSV3dkgOeRtJbyIWm7brE8eGf(7rfZfichDAqqbFNtrOYO)UtGSB7TJ883KrzgIhJBO04lg4OUiF7O89PuFpqEqXaLyDMCIH8GIbkLVpLWf(aSV3dkgOeRtJbyIWm7brE8saKDBVDtaHkuJL3dvaGv3qPXxmCHVe2T92nbeQqnwEpubawDnZeDmTI2Obk5yFTB8miRSJMp677WUT3UjGqfQXY7HkaWQRzcOaSWFpQyUar4OtdUBCEofHkJ(7obYUT3oYZFtgLziEmUHsJVyGJ6I8TJY3NsjaYJqCyKLY5J8xE3qPXxmWHpW679iehgzPCEubbHhLpquMz(ZFm3qPXxmWHpWaSVhipOyGsSotoXqEqXaLY3Ns4cFa237bfduI1PXamryM9GipEjaYUT3UjGqfQXY7HkaWQBO04lgUWxc72E7MacvOglVhQaaRUMzIoMwrB0aLCSV2nEgKv2rZh99Dy32B3eqOc1y59qfay11mbuaMrkkaNrIIFGmcrrLO424jal83JkMlqeo60GwIzE0Kr7mXBfjaZiff3b334XrmrTaIoq0i6HeTXirXUy2)qI(LOyiEmIAb07bj6ZenorXNOxmqPJHddfDJgrji0yv0KbZajAAWoASkkAefNff7IH1gOKOgrQjYcnPuDIYUWJhtaw4VhvmxGiC0PbHeZh2CYOvKsDYUy2)q5VYmepgJcj4nQtMjX55lgO0XCSlM9pe4WzCS5i0auAWoASMHe8gbqgcgygOKbdqCS5i0aKDBVDSlgwBGszk1ezHMuQUmdXJXXUWJNbcNbuaMrkkUdUVXJJyIAbeDGOr0djk(XehirHBZxqff)oubawfGf(7rfZfichDAqiX8HnNmAfPuNwM4aL)kVhQaaRgfsWBuNgAGyMeNNbfSJWvYghqG5sgGaIzsCE(IbkDmh7Iz)dzCgciabKH44covNJHA8mANpquEJgIDoQcBobdqg6WhGaIdWCgIpaYUT3UjGqfQXY7HkaWQBO04lMamJuuaoJef)yIdKOFjkgIhJOgHN)Mmsu0i6VfTqIIDXS)He1YZ5IU)t0VoKO4g4niaR8IgL1u0qcWc)9OI5ceHJonOLjoqg93Dce55VjJC8wftUOUU(EYZFtg5IYAUOUUeqI5dBo5Ew2ZPacbycGUyGsN7(ukFOm8tGdN77jp)nzKJ3QyYFLtUV3gXyj2puqxEO04lgUmema77TB7TJ883KrzgIhJBO04lgUc)9OYXUy2)qoQlY3okFFkLWUT3oYZFtgLziEmUMzFp55VjJCFLziEmj6asmFyZjh7Iz)dL)kZq8y67TB7TZh5V8UHsJVy4k83Jkh7Iz)d5OUiF7O89PuIoGeZh2CY9SSNtbekHDBVD(i)L3nuA8fdxuxKVDu((ukHDBVD(i)L31m77TB7TBciuHAS8EOcaS6AMjGeZh2CYzzIdu(R8EOcaS233bKy(WMtUNL9CkGqjSB7TZh5V8UHsJVyGJ6I8TJY3NscWmsrb4msuSlM9pKO)w0Vef)BvmIAeE(BYiJk6xIIH4XiQr45VjJefvIIZ4q0lgO0XefnIEirnhKxumepgrncp)nzKaSWFpQyUar4OtdYUy2)qcWmsrXVbNFGMMaSWFpQyUar4OtdoTkh(7rvM)SZOvKsDUdo)annbycWmsrXUyyTbkj6gnIMIGqPuDI2koXyI2yFbvuGdb8aOaSWFpQyUDW5hOP1j7IH1gOKr)DNDmTI2Obk5SdEuEkJ25GZZhOVGYCu32EttcwaMrkkUd2j6bIefgDIA5pqIEGirtrSt07tjrpKObmSOT6EUOhis00OlrHBtCpQe9zIc6pNOyTA)dj6qPXxmrtB87n5pbl6HennopirtrOA)djkCBI7rLaSWFpQyUDW5hOPHJoniRv7FiJ6T65u(IbkDSon0O)Uty05srOA)d5gkn(IbUHsJVyauYjBGmSBeGf(7rfZTdo)annC0PbtrOA)djataMrkkaNrIc8WH59qirXSetQOwarLOhiAirFMOfs0WFpesuMLysnQObtuECKObtuteJ92CsuujkZsmPIA5pqIMSOOr0nzHgrzx4XJjkAefvIgIAmCikZsmPIYqIEGIt0dejArweLzjMurJzEiet0UpASt0yF0i6bkorzwIjvuQlZFiMaSWFpQyo21zahM3dHYmlXKAuVvpNYxmqPJ1PHg93D2bm6CbCyEpekZSetAgosdOK7EpEFbnrhH)Eu5c4W8EiuMzjM0mCKgqj3x5n)Hc6sauhWOZfWH59qOmZsmPzquWD37X7lO99WOZfWH59qOmZsmPzquWDdLgFXah(aSVhgDUaomVhcLzwIjndhPbuYXUWJhUmwcy05c4W8EiuMzjM0mCKgqj3qPXxmCzSeWOZfWH59qOmZsmPz4inGsU7949fubygPOaCgXef3Occcps0FlkUbEdcWkVOpt0MPOOruROMOXqIctmRL)lOIIBG3GaSYlQL)ajkUrfeeEKOrblQvut0yirTjoYIO4myg0yGbeUjoXUp4IIz(ZFmaff4z4er)s0qudbdhIYiVOgHN)MmYjkWZzirHrf4pr50jQXBOi1(lyAeL6Y8hYOIgClHvMOngj6xIIBG3GaSYlQL)ajkoPXzXiAuWIgNOhisu2fZjkAlAikWHaEauulFbJS4eGf(7rfZXoC0Pb9OcccpkFGOmZ8N)yg93D2b80EyxHYEywcGacsmFyZjNhvqq4rzyIzT8j6WJqCyKLY5J8xE3qbS1eDmTI2Obk5mNpfnWFWZX4J69zZgNftFVDBVD(i)L31mbmbqafSBcE2ezHgC1jKy(WMtopQGGWJYbZmbq2T92rE(BYOmVvX4gkn(IbodbRV3UT3oYZFtgLziEmUHsJVyGZqWaSV3UT3oFK)Y7gkn(Ibo8LWUT3oFK)Y7gkn(IHRonmzatauhtROnAGsU7tjlOPYWdfP2FbttFFhtROnAGsopXj29bpZm)5pwFVDBVD3NswqtLHhksT)cMg3qPXxmWrDr(2r57tja77NwrB0aLC2bpkpLr7CW55d0xqzaMaOoMwrB0aLC2bpkpLr7CW55d0xqz99az32BNDWJYtz0ohCE(a9fuwUIRnKJDHhVo7M(E72E7SdEuEkJ25GZZhOVGYYX4JICSl841z3aiG992iglX(Hc6YdLgFXWLHGLOdpcXHrwkNpYF5DdfWwbuaMrkkaNrIIDXWAdus0djkEezkAZu0dejQXBOi1(lyAe1UT3I(Br)tulOghwuQlZFirTPnAir3F9mqFbv0dejArDDI6d2jkAe9qIc3snf1M2OHef3Occcpsaw4Vhvmh7WrNgKDXWAduYO)UZPv0gnqj39PKf0uz4HIu7VGPjbqDaeq2T92DFkzbnvgEOi1(lyACdLgFXax4VhvoltCGCuxKVDu((uchG5mmbqKN)MmY9v2gDG67jp)nzK7RmdXJPVN883KroERIjxuxhG992T92DFkzbnvgEOi1(lyACdLgFXax4Vhvo2fZ(hYrDr(2r57tjCaMZWearE(BYi3xzERIPVN883KrogIhtUOUU(EYZFtg5IYAUOUoabSVVd72E7UpLSGMkdpuKA)fmnUMjG99az32BNpYF5DnZ(EiX8HnNCEubbHhLHjM1YdycpcXHrwkNhvqq4r5deLzM)8hZnuaBnHhbHQOox9qbD5DqjaYUT3oYZFtgL5Tkg3qPXxmWziy992T92rE(BYOmdXJXnuA8fdCgcgGaMaOo8iiuf15WZ68r137riomYs5OutKfAY2Oc2nuA8fdCDdGcWmsrnETutrXUyyTbkXe1YFGef4cEuEsu0wuGNZffab9fuMOOr0djQ5qMXqIUrJO4gvqq4rIA5pqIcCiGhafGf(7rfZXoC0PbzxmS2aLm6V7CAfTrduYzh8O8ugTZbNNpqFbLLaiGSB7TZo4r5PmANdopFG(cklxX1gYXUWJh4sUV3UT3o7GhLNYODo488b6lOSCm(Oih7cpEGlzat4riomYs58r(lVBO04lg4mWj6WJqCyKLY5rfeeEu(arzM5p)XCnZ(EG8iiuf15QhkOlVdkHhH4WilLZJkii8O8bIYmZF(J5gkn(IHldblb55VjJCFLJYAIGDtWZMil0aUKbdhgdmaYJqCyKLY5J8xE3qbSvabuaMrkkUrf8FpQeDJgrdoxuy0Xe9afNOPbEetuwBirpqKvrJHkWFIo0EigicwulGOsu8tbeQqnMO43HkaWQOGcMOCIXe9afLO4tug5zIouA81xqffnIEGirnIutKfAef4qfSO2T9w0NjAyJANOhs0DW5II2BrrJOrzvuJWZFtgj6ZenSrTt0djk1L5pKaSWFpQyo2HJoniKy(WMtgTIuQty0LhQBB)qPuDmJcj4nQtGSB7TBciuHAS8EOcaS6gkn(Ibo8133HDBVDtaHkuJL3dvaGvxZeWeDy32B3eqOc1y59qfaynZ(A34zqwzhnF4AMjaYUT3o8(cEi4mLAISqtkvxMkAG(aa5gkn(IHlOEyxA0fGjaYUT3oYZFtgLziEmUHsJVyGdQh2LgD13B32Bh55VjJY8wfJBO04lg4G6HDPrx99a1HDBVDKN)MmkZBvmUMzFFh2T92rE(BYOmdXJX1mbmrhxWP6CmeNDVNCuf2CcgqbygPO4gvW)9Os0duCI6brE8yI(BrTIAIgdjkQDShMeL883KrIEirrf3QOWOt0denKOOr0hAHgs0d0Ze1YFGefdXz37jbyH)EuXCSdhDAqiX8HnNmAfPuNWOlJAh7HPm55VjJmkKG3OobQd72E7ip)nzuMH4X4AMj6WUT3oYZFtgL5TkgxZeWeDCbNQZXqC29EYrvyZj4eDmTI2Obk5UpLSGMkdpuKA)fmncWmsrnEOt0GZf9IbkDmrT8hOVefNefmL(ErT8hiu7efbHgFyA(fuCCGirdBeesupQG)7rftaw4Vhvmh7WrNgmfHQ9pKr9w9CkFXaLowNgA0F3jq2T92rE(BYOmdXJXnuA8fdCdLgFX67TB7TJ883KrzERIXnuA8fdCdLgFX67HeZh2CYbJUmQDShMYKN)MmcWedThIbkS5uIlgO05UpLYhkd)e4mm5eHz2dI84LasmFyZjhm6Yd1TTFOuQoMaSWFpQyo2HJoniRv7FiJ6T65u(IbkDSon0O)UtGSB7TJ883KrzgIhJBO04lg4gkn(I13B32Bh55VjJY8wfJBO04lg4gkn(I13djMpS5KdgDzu7ypmLjp)nzeGjgApeduyZPexmqPZDFkLpug(jWzyYjcZShe5XlbKy(WMtoy0LhQBB)qPuDmbyH)EuXCSdhDAq2rCEm5npgYOEREoLVyGshRtdn6V7ei72E7ip)nzuMH4X4gkn(IbUHsJVy992T92rE(BYOmVvX4gkn(IbUHsJVy99qI5dBo5Grxg1o2dtzYZFtgbyIH2dXaf2CkXfdu6C3Ns5dLHFcCgItteMzpiYJxciX8HnNCWOlpu32(HsP6ycWmsrnEOt05Hc6e1M2OHef)oubawf93I(NOwqnoSObNJSiQvut0dj6q7HyGeLtmMOWT5lOIIFhQaaRIc0b6zIIkUvrbfMMuXe1YFGqTtuSV2nUO4NzLD08bGcWc)9OI5yho60GqI5dBoz0ksPolugKv2rZhzkgU1mm6mkKG3Oo9iiuf15Gq1bY6KOJPv0gnqjh7RDJNbzLD08rIoMwrB0aLC(F8CkJ2z(VPCuWzykoqj8iehgzPC20WObVVG6gkGTMWJqCyKLYnbeQqnwEpubawDdfWwt0HDBVD(i)L31mtauWUj4ztKfAax3yG77TB7TZMJqW8g7CntafGf(7rfZXoC0PbtrOA)dz0F3jKy(WMtUcLbzLD08rMIHBndJUedLgFXWvYGjal83JkMJD4OtdYA1(hYO)UtiX8HnNCfkdYk7O5Jmfd3AggDjgkn(IHld7EcWmsrb4msu8lkjrrLOEyrT8hiu7e1hMMFbvaw4Vhvmh7WrNgCJgpLr7CfxBiJ(7odZShe5XtaMrkkaNrIAePMil0ikWHkyrT8hirJYQOCubvuQqnOGeLhS7lOIAeE(BYirJcw0BSk6HeL)fj6FI2mf1YFGefN04SyenkyrXnWBqaw5fGf(7rfZXoC0PbPutKfAY2Oc2O)UtG8iehgzPC(i)L3nuA8fdh2T925J8xEhCBI7rfoMwrB0aLCMZNIg4p45y8r9(SzJZIbGmmzW5riomYs5OutKfAY2Oc2b3M4EuHddbdW(E72E78r(lVBO04lg46M(E4P9WUcL9WmbygPOy0Xe1ciQef4z4erzGqnoSO2KOWTutcw0djAHorrqOXhMIcKXJmPcMjkQef)2gRII2IAe8wrIgfSOhisuJWZFtgbOaSWFpQyo2HJoniKy(WMtgTIuQZGzMHBPMgfsWBuNb7MGNnrwObCDpWmoGs2HpaYUT3UDBSMr7mXBf5yx4XZ4sgGip)nzK7RmVvXaOamJuuaoJef3aVbbyLxul)bsuCJkii8id297l4HGffZ8N)yIgfSOWOc8NOii0yz(JefN04SyefnIAbevIcCCecM3yNOwqnoSOuxM)qIAtB0qIIBG3GaSYlk1L5peZjQXxGhjkRnKOhsuQoAenef)BvmIAeE(BYirTaIkrBShAjkaMC3iAYMErJcw0GZff3gpMOwEoxuBYJsjrhkGTkkdHkrPc1Gcsu428furpqKO2T9w0OGffgDmrbfqirTjQeL1273)uDCRIo0Eigic2jal83JkMJD4OtdcjMpS5KrRiL60dN9Oc(Vhvz2zuibVrD2b80EyxHYEywcGGeZh2CY5HZEub)3JQeDy32BNpYF5DnZea1bJUSnQAm390KC3Kt2033tE(BYi3xzERIPVN883KrogIhtUOUoataeqabjMpS5KlyMz4wQzFVhbHQOox9qbD5Dq99a5rqOkQZHN15JkHhH4WilLJsnrwOjBJky3qbSva77NwrB0aLC3NswqtLHhksT)cMgataJohRv7Fi3qPXxmW1njGrNlfHQ9pKBO04lg46EjacgDo2rCEm5npgYnuA8fdCgcwFFhxWP6CSJ48yYBEmKJQWMtWaMasmFyZj3bAEopZicpAYwI)sCXaLo39Pu(qz4NaNDBVD(i)L3b3M4EubqG5mW992T92zZriyEJDUMzc72E7S5iemVXo3qPXxmCz32BNpYF5DWTjUhv4aidtgGMwrB0aLCMZNIg4p45y8r9(SzJZIbqa77bI622BAsWok106qbpJg4kkpLWJqCyKLYrPMwhk4z0axr5j3qPXxmCzio1aJdGWhanTI2Obk5yFTB8miRSJMpaeqatauhEeeQI6C1df0L3b13dKhH4WilLZJkii8O8bIYmZF(J5gkn(IHl72E78r(lVdUnX9OYaLCIoMwrB0aLC2bpkpLr7CW55d0xqz99EeIdJSuopQGGWJYhikZm)5pMBOa2AIGDtWZMil0Gl8bgG992iglX(Hc6YdLgFXWLhH4WilLZJkii8O8bIYmZF(J5gkn(IbyFVnIXsSFOGU8qPXxmCz32BNpYF5DWTjUhv4WWKbOPv0gnqjN58POb(dEogFuVpB24SyauaMrkkaNrIIFhQaaRIA5pqIIBG3GaSYlAR4eJjk(DOcaSkQfuJdlkpyNOCubLgrpqrjkUbEdcWkVrf9arLOngjQnTrdjal83JkMJD4OtdobeQqnwEpubawn6V70UT3oFK)Y7gkn(IbodXxFVDBVD(i)L3b3M4EuHRKnW4yAfTrduYzoFkAG)GNJXh17ZMnolgaYWKtajMpS5KZdN9Oc(Vhvz2jal83JkMJD4Otd6joXUp45G)qRuQoJ(7oHeZh2CY5HZEub)3JQm7saKDBVD(i)L3b3M4EubUot2aJJPv0gnqjN58POb(dEogFuVpB24SyaidtUVVdpccvrDoiuDGSoa23B32B3eqOc1y59qfay11mty32B3eqOc1y59qfay1nuA8fdxDpC4rfC7pN5q(Nr5G)qRuQo39PugsWBeoaQd72E7S5iemVXoxZmrhxWP6CSlgoAGDuf2CcgqbyH)EuXCSdhDAWV8XuX9OYO)UtiX8HnNCE4ShvW)9OkZobygPODFJ5dBojAJrWIIkrd7N)3tmrpqXjQLOorpKO2KOSacbl6gnIIBG3GaSYlkdj6bkorpqKvrJHQtulb7iyr7(OXorTPnAirpquQaSWFpQyo2HJoniKy(WMtgTIuQtwaHYB0K9r(lVrHe8g1PhH4WilLZh5V8UHsJVyGZqW677asmFyZjNhvqq4rzyIzT8j8iiuf15QhkOlVdQVhEApSRqzpmtaMrkkaNrmrXViJq0Fl6xIgLOgHN)Mms0OGf9MNyIEir5FrI(NOntrT8hirXjnolgJkkUbEdcWkVrf1isnrwOruGdvWIgfSOapCyEpesumlXKkal83JkMJD4OtdUBJ1mANjERiJ(7ojp)nzK7RCuwtauWUj4ztKfAWv3lzJZUT3UDBSMr7mXBf5yx4XdGWxFVDBVDtaHkuJL3dvaGvxZeWeaz32BN58POb(dEogFuVpB24SyCqcEJWvY4my992T925J8xE3qPXxmW1naMasmFyZjhlGq5nAY(i)LpbqD4rqOkQZvKFqC0a33dJoxahM3dHYmlXKMHJ0ak5U3J3xqbmbqD4rqOkQZbHQdK1PV3UT3UjGqfQXY7HkaWQBO04lgU6Eghq4manTI2Obk5yFTB8miRSJMpamHDBVDtaHkuJL3dvaGvxZSVVd72E7MacvOglVhQaaRUMjGjaQdpccvrDo8SoFu99EeIdJSuok1ezHMSnQGDdLgFXaxYGbyIlgO05UpLYhkd)e4WxFVnIXsSFOGU8qPXxmCziycWmsrb4msuJ)IoqIIDXSdoxuZb5zI(BrXUy2bNl6ZkWFI2mfGf(7rfZXoC0Pbzxm7GZn6V70UT3ourhiw2KgpzEpQCnZe2T92XUy2bN7gApeduyZjbygPO4okpXff7IHJgyr)TO)jkOGjkNymrpqrjk(yIouA81xqnQOwrnrJHenor7EGHdrbEgor0OGf9arI6BZq1jQr45VjJefuWefF4Gj6qPXxFbvaw4Vhvmh7WrNg0hLN4z72EB0ksPozxmC0aB0F3PDBVDSlgoAGDdLgFXWf(saKDBVDKN)MmkZq8yCdLgFXah(67TB7TJ883KrzERIXnuA8fdC4dWeb7MGNnrwObCDpWeGzKII7O8ex0dejkoPXzXiQDBVf93IEGirnhKxulOghUa)jk)ls0MPOw(dKOhis0I66e9(usuCJkii8ir9OuIjkAVf1d7efab9mrBSwW5wffvCRIckmnPIjkCB(cQOhisuGd)DcWc)9OI5yho60G(O8epB32BJwrk1P58POb(dEogFuVpB24Sym6V78covN7lFmvCpQCuf2CcorhxWP6CfzjNIqLJQWMtWj6(diGmgyGzCb7MGNnrwObh4myghJUSnQAm390KC3Kt20dq4myaAGacNnqmtIZZGc2raACEeIdJSuopQGGWJYhikZm)5pMBO04lgG4Q7pGaYyGbMXfSBcE2ezHgJZUT3oZ5trd8h8Cm(OEF2SXzX4Ge8gHdCgmJJrx2gvnM7EAsUBYjB6biCgmanqaHZgiMjX5zqb7ianopcXHrwkNhvqq4r5deLzM)8hZnuA8fdWeEeIdJSuoFK)Y7gkn(IboJbwc72E7mNpfnWFWZX4J69zZgNfJdsWBeUs2qWsy32BN58POb(dEogFuVpB24SyCqcEJaNXalHhH4WilLZJkii8O8bIYmZF(J5gkn(IHlCgSe7hkOlpuA8fdCEeIdJSuopQGGWJYhikZm)5pMBO04lgoWPjaAAfTrduY5joXUp4zM5p)X67HeZh2CY5rfeeEugMywlpGcWmsrXOJjQfqujkoPXzXikdeQXHf1Me1CqEpblkfd3QOhsuBs0WMtIEirBmsuCJkii8irrLOEeIdJSuIcKrWyuDFW5wf1M8OuIj6nns0FlkCl18lOIc8mCIOfYIOwEox0GZrwe1kQj6He1KMn5pUvrP6OruCsJZIr0OGf9arLOngjkUrfeeEeGcWc)9OI5yho60GqI5dBoz0ksPonhKpB24SyYumCRgfsWBuNEeeQI6C1df0L3bLyAfTrduYzoFkAG)GNJXh17ZMnolMe2T92zoFkAG)GNJXh17ZMnolghKG3iCeSBcE2ezHgCymW1PXadSeqI5dBo58OcccpkdtmRLpHhH4WilLZJkii8O8bIYmZF(J5gkn(IHRGDtWZMil0yGmgyaeupSln6krhWt7HDfk7Hzjip)nzK7RCuwteSBcE2ezHgWbjMpS5KZJkii8OCWmt4riomYs58r(lVBO04lg4WNamJuuaoJef7IzhCUOw(dKOyhX5XiQXB(9jkAe9sUBefNn9IgfSOfsuSlgoAGnQOwarLOfsuSlMDW5I(mrBMIIgrpKOMdYlkoPXzXiQfqujAyJGqI29atuGNHtacnIEGirPy4wffN04Sye1CqErHeZh2Cs0Nj6nncqrrJObSzCpesuMLysffuWeTBWbJ8mrhkn(6lOIIgrFMOFj6M)qbDcWc)9OI5yho60GSlMDW5g93Dc0fCQoh7iopMm887ZrvyZj4(EgDzBu1yU7Pj5UjJZMEat0XfCQoh7IHJgyhvHnNGty32Bh7IzhCUBO9qmqHnNs0X0kAJgOK7(uYcAQm8qrQ9xW0Kai72E7mNpfnWFWZX4J69zZgNfJdsWBe46mz8bwIoSB7TZh5V8UMzcGGeZh2CYfmZmCl1SV3UT3o8(cEi4mLAISqtkvxMkAG(aa5AM99qI5dBo5mhKpB24SyYumCRa23dKhbHQOoxr(bXrdCIl4uDo2rCEmz453NJQWMtWjacgDUaomVhcLzwIjndhPbuYnuA8fdCDtFF4VhvUaomVhcLzwIjndhPbuY9vEZFOGoabeWeEeIdJSuoFK)Y7gkn(IbodbtaMrkQXRLAYef4z4erTPnAirXnQGGWJeTX(cQOhisuCJkii8ir9Oc(VhvIEir9GipEI(BrXnQGGWJe9zIg(RfCUvrdBu7e9qIAtI6d2jal83JkMJD4OtdYUyyTbkz0F3jKy(WMtoZb5ZMnolMmfd3QamJuuaoJe14dHkMOwarLOwrnrJHenSrTt0dzWyir9HP5xqf1dkgOet0OGfnnWJeL1gs0dezv0yir)s0Oe1i883KrIYUNZfDJgrXpZ4ZG4xJpbyH)EuXCSdhDAWISKtrOYO)UZWm7brE8saKhumqjwNjNyipOyGs57tjCHV(EpOyGsSongGcWc)9OI5yho60GGc(oNIqLr)DNHz2dI84LaipOyGsSotoXqEqXaLY3Ns4cF99EqXaLyDAmataKDBVDKN)MmkZBvmUHsJVyGJ6I8TJY3Ns992T92rE(BYOmdXJXnuA8fdCuxKVDu((ucqbyH)EuXCSdhDAWDJZZPiuz0F3zyM9GipEjaYdkgOeRZKtmKhumqP89PeUWxFVhumqjwNgdWeaz32Bh55VjJY8wfJBO04lg4OUiF7O89PuFVDBVDKN)MmkZq8yCdLgFXah1f5BhLVpLauaMrkkaNrIIDXWAdusuJ)IoqIAoipt0OGffULAkkWZWjIAbevIIBG3GaSYBurnIutKfAef4qfSrf9arI29LQdK1ru72El6ZenSrTt0dj6o4Crr7TOOruROg4Hf1hMIc8mCIaSWFpQyo2HJoni7IH1gOKr)DNKN)MmY9vokRjaYUT3ourhiw2ZPyYqE2JkxZSV3UT3o8(cEi4mLAISqtkvxMkAG(aa5AM992T925J8xExZmbqD4rqOkQZHN15JQV3JqCyKLYrPMil0KTrfSBO04lg4WxFVDBVD(i)L3nuA8fdxq9WU0OlaAZrObOGDtWZMil0yGGeZh2CYXyzpIDacycG6WJGqvuNdcvhiRtFVDBVDtaHkuJL3dvaGv3qPXxmCb1d7sJUaip9CGaky3e8SjYcn4aNbdGUGt152TXAgTZeVvKJQWMtWaAGGeZh2CYXyzpIDaIdJbqxWP6CfzjNIqLJQWMtWj6yAfTrduYX(A34zqwzhnFKWUT3UjGqfQXY7HkaWQRz23B32B3eqOc1y59qfaynZ(A34zqwzhnF4AM99az32B3eqOc1y59qfay1nuA8fdxH)Eu5yxm7Fih1f5BhLVpLsWmjopdkyhHlWC4CFVDBVDtaHkuJL3dvaGv3qPXxmCf(7rLZYehih1f5BhLVpL67HeZh2CY9DlC2Jk4)EuLWJqCyKLY9fZpTlS5uUBBrDT0mmb59KBOa2AcQBBVPjb7(I5N2f2Ck3TTOUwAgMG8EcWe2T92nbeQqnwEpubawDnZ((oSB7TBciuHAS8EOcaS6AMj6WJqCyKLYnbeQqnwEpubawDdfWwbSVhsmFyZjxWmZWTuZ(EBeJLy)qbD5HsJVy4cQh2LgDbqE65afSBcE2ezHgdeKy(WMtogl7rSdqafGzKIcGJvrpKOPbEKOhisuBIDII2IIDXWrdSO2wfLDHhVVGk6FI2mfTBBVhpUvr)s0OSkQr45VjJe1UDIItACwmI(Sc8NOHnQDIEirTjrnhK3tWcWc)9OI5yho60GSlgwBGsg93DEbNQZXUy4Ob2rvyZj4eDmTI2Obk5UpLSGMkdpuKA)fmnjaYUT3o2fdhnWUMzFFWUj4ztKfAax3dmaty32Bh7IHJgyh7cpE4YyjaYUT3oYZFtgLziEmUMzFVDBVDKN)MmkZBvmUMjGjSB7TZC(u0a)bphJpQ3NnBCwmoibVr4kzdmyjaYJqCyKLY5J8xE3qPXxmWziy99DajMpS5KZJkii8OmmXSw(eEeeQI6C1df0L3bbOamJuuJGDFACetuqilIM28Gef4z4erJHefA8fblQjnIYipQGDIA8xCRIEbEet0quwfMmqOt0nAe9arI6BZq1jk7VwCpQeLHe1cQXHlWFIAtIgEFBIJeDJgr5XaLgrVpL2tKsmbyH)EuXCSdhDAqiX8HnNmAfPuNbZeNqdg5nkKG3Oojp)nzK7RmVvXaqDJbk83Jkh7Iz)d5OUiF7O89Peo6G883KrUVY8wfdabeofhxWP6CmuJNr78bIYB0qSZrvyZjyaYyaAGc)9OYzzIdKJ6I8TJY3Ns4amhoJpdeZK48mOGDeoaZHpa6covNRIRnelBh8O8KJQWMtWcWmsrnETutrXUyyTbkj6xIgLOgHN)Mms0GjkdHkrdMOMig7T5KObtuoQGkAWe1kQjQLNZfLkyrBMIA5pqI2nGHdrTaIkrP6O5lOIEGirlQRtuJWZFtgzurHrf4pr50j6FIAoiVO4KgNfJrffgvG)efbHglZFKOrjQXFrhirnhKx0OGf1eH4IAtB0qIIBG3GaSYlAuWIAePMil0ikWHkybyH)EuXCSdhDAq2fdRnqjJ(7o7yAfTrduYDFkzbnvgEOi1(lyAsaKDBVDMZNIg4p45y8r9(SzJZIXbj4ncxjBGbRV3UT3oZ5trd8h8Cm(OEF2SXzX4Ge8gHRKXhyjUGt15yhX5XKHNFFoQcBobdycGip)nzK7RmdXJjrWUj4ztKfAWbKy(WMtUGzItObJ8aKDBVDKN)MmkZq8yCdLgFXWbm6C72ynJ2zI3kYDVhpwEO04lakzh(ax3awFp55VjJCFL5TkMeb7MGNnrwObhqI5dBo5cMjoHgmYdq2T92rE(BYOmVvX4gkn(IHdy052TXAgTZeVvK7EpES8qPXxauYo8bUUhyaMOd72E7qfDGyztA8K59OY1mt0XfCQoh7IHJgyhvHnNGtaKhH4WilLZh5V8UHsJVyGZa33ZqnU9xWUd08CEMreE04OkS5eCc72E7oqZZ5zgr4rJJDHhpCzmJzCanTI2Obk5yFTB8miRSJMpaOKbmX(Hc6YdLgFXaNHGbwI9df0Lhkn(IHRKbdS(E4P9WUcL9WmatauhEeeQI6C4zD(O679iehgzPCuQjYcnzBub7gkn(IbUKbuaMrkkaNrIA8Hqft0VenkRIAeE(BYirJcwuwaHef)SGVXb(TX5IA8HqLOB0ikUbEdcWkVOrblA3VVGhcwuJi1ezHMuQoNOapNHeTXirtY4t0OGff)A8jACIEGirPcwu0wu87qfayv0OGffgvG)eLtNOgVHIu7VGPr0DW5II2BbyH)EuXCSdhDAWISKtrOYO)UZWm7brE8sajMpS5KJfqO8gnzFK)YNai72E7ip)nzuM3QyCdLgFXah1f5BhLVpL67TB7TJ883KrzgIhJBO04lg4OUiF7O89PeGcWc)9OI5yho60GGc(oNIqLr)DNHz2dI84LasmFyZjhlGq5nAY(i)Lpbq2T92rE(BYOmVvX4gkn(IboQlY3okFFk13B32Bh55VjJYmepg3qPXxmWrDr(2r57tjataKDBVD(i)L31m77TB7TZC(u0a)bphJpQ3NnBCwmoibVr4QZKnematauhEeeQI6CqO6azD67TB7TBciuHAS8EOcaS6gkn(IHlGWNXLmanTI2Obk5yFTB8miRSJMpamHDBVDtaHkuJL3dvaGvxZSVVd72E7MacvOglVhQaaRUMjGjaQJPv0gnqj39PKf0uz4HIu7VGPPVN6I8TJY3Ns4YUT3U7tjlOPYWdfP2FbtJBO04lwFFh2T92DFkzbnvgEOi1(lyACntafGf(7rfZXoC0Pb3nopNIqLr)DNHz2dI84LasmFyZjhlGq5nAY(i)Lpbq2T92rE(BYOmVvX4gkn(IboQlY3okFFk13B32Bh55VjJYmepg3qPXxmWrDr(2r57tjataKDBVD(i)L31m77TB7TZC(u0a)bphJpQ3NnBCwmoibVr4QZKnematauhEeeQI6C4zD(O67TB7TdVVGhcotPMil0Ks1LPIgOpaqUMjGjaQdpccvrDoiuDGSo992T92nbeQqnwEpubawDdLgFXWf(sy32B3eqOc1y59qfay11mt0X0kAJgOKJ91UXZGSYoA(OVVd72E7MacvOglVhQaaRUMjGjaQJPv0gnqj39PKf0uz4HIu7VGPPVN6I8TJY3Ns4YUT3U7tjlOPYWdfP2FbtJBO04lwFFh2T92DFkzbnvgEOi1(lyACntafGzKIcWzKO4hiJquujQhwaw4Vhvmh7WrNg0smZJMmANjERibygPOaCgjk2fZ(hs0djQ5G8IIH4XiQr45VjJmQO4g4niaR8IckyIYjgt07tjrpqrjAik(XehirPUiF7ir50(efnIIkUvrX)wfJOgHN)Mms0NjAZ0jk(XFGefatUBenztVOuD0iAikgIhJOgHN)Mms0FlkoPXzXik7EoxuqbtuoXyIEGIs0Knemrzx4XJjAuWIIBG3GaSYlAuWIIBubbHhjkOacjAkAirpqrjQHgyMO424j6qPXxFb1jkaNrIg2iiKOjJpWmqIckyhjkCB(cQO43HkaWQOrblAYjNSbsuqb7irT8hiu7ef)oubawfGf(7rfZXoC0Pbzxm7FiJ(7ojp)nzK7RmVvXKOd72E7MacvOglVhQaaRUMzFp55VjJCmepMCrDD99arE(BYixuwZf1113B32BNpYF5DdLgFXWv4VhvoltCGCuxKVDu((ukHDBVD(i)L31mbmbqDWOlBJQgZDpnj3n5Kn999tROnAGsoZ5trd8h8Cm(OEF2SXzXKWUT3oZ5trd8h8Cm(OEF2SXzX4Ge8gHRKneSeEeIdJSuoFK)Y7gkn(IbodnWjaQdpccvrDU6Hc6Y7G679iehgzPCEubbHhLpquMz(ZFm3qPXxmWzObgWea1XeEYDdIZ779iehgzPC20WObVVG6gkn(IbodnWacyFp55VjJCFLJYAcGSB7TZsmZJMmANjERixZSVNzsCEguWocxG5Wz8LaOo8iiuf15Gq1bY6033HDBVDtaHkuJL3dvaGvxZeW(EpccvrDoiuDGSojyMeNNbfSJWfyoCgqbygPOaCgjk(XehirrhiAS8msulGEpirFMOFjkgIhJOgHN)MmYOIIBG3GaSYlkAe9qIAoiVO4FRIruJWZFtgjal83JkMJD4OtdAzIdKamJuu8BW5hOPjal83JkMJD4OtdoTkh(7rvM)SZOvKsDUdo)anT1TU1ca]] )
    

end