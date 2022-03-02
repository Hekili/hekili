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


    spec:RegisterPack( "Balance", 20220301, [[dm1r0fqikfpcsLUeevSjsPpPuQrPOCkfvRsiLxbbMfKQUfPqTlk(fKIHjs5yKIwgLsptiY0GG6AKc2gKk8niv04eIY5eskRtijZdc5EcH9Pu0)esQQgOqsv5GkL0cfPYdHOmrsH4IqkzJquPpcbPYiHGu1jfPQwPsHxkKuLzcrv3KuizNkL4NKcPgkeehviPIwkeKYtbyQcP6QIuLTkKuPVcbjJfsP2Rq9xrnyIdt1IjvpwWKb6YiBwHpdjJwP60QSAHKk8AiYSj52Iy3s(nOHtjhxiQwUuphQPRQRRKTdOVtPA8qOoViz9cjMVISFuhRzC0Jba6pfVfBtZwBtlsPzRjT0slsAQHyaFklkgGLhqYrrXakpHIbKox5vGIby5Puqhmo6XaWWvhOya7)BHJk0GgDx5vG0y8LemOUFFPBoiAsNR8kqAmGlbzOjb0S)jQO(hNIIq3vEfiZJ4pgG(6uF6xX6Xaa9NI3ITPzRTPfP0S1KwAPfjnr4ya(63HDmaaxcYIbSFGGufRhdaKWHyaPZvEfiw0i96a5n0O8oSZIMONfBtZwB5n4nq2UxOiCuXBOXSSvqqcKfaqL3SKoYtm8gAmliB3lueilV3OOpFdwcoMWS8qwcPckk)EJIESH3qJzbHgLabsGSSQIceg7Dkwa6956kcZYSZqg0ZIvtaZ43B8QrrSOXBYIvtan43B8QrrZn8gAmlBfi8azXQPGJ)RqXccv7)ol3GL73gZYVtSyVHfkwqRG6SWKH3qJzrJYrIybzWciejILFNybG113JzXzrD)RiwsGnXYqri(0velZUblPGlw2DWA7NL97z5EwWxYs9ErWfwLIf73VZs60O3A0zbbSGmsr4)CflBvDOQeQE0ZY9BdYcgPZAUH3qJzrJYrIyjbIFw2ECO2)Ctj(v4TzbhOY7dIzXTSuPy5HSOdXywghQ9hZcSuPm8gAmlrVj)zj6WeIf4GL0P8DwsNY3zjDkFNfhZIZc2IcNRy57RqIEdVHgZIgTfvuZYSZqg0Zccv7)o6zbHQ9Fh9Sa49ECnnNLehKyjb2elnHp1r1ZYdzH8wDuZsaMO7VgJFVFdVHgZcY9qmlr9UcSjqwqRelODQtO6zjStbKyzaBwqMgHLf2rrMyaQd)44OhdaArf1XrpElAgh9yau56kcmoDXa8WFWkgG92)9yaGeo0N1FWkgacPPGJFwSLfeQ2)Dw8cKfNfaV34vJIybwSai6Sy)(Dw2YHA)zb56elEbYs6GBn6SaBwa8EpUMyb(7uB)WumGqFp1NhdygluqDwyYOwL35Iq8ZY0eluqDwyYCvgdvEZY0eluqDwyYCvwh(7SmnXcfuNfMmELkxeIFwMZIwwSAcOrtJ92)Dw0YInSy1eqJTg7T)7XF8wSno6XaOY1veyC6Ib4H)Gvma8794AkgqOVN6ZJbydl9QObSrrgDx5vGYWr2vQ8VFfkSHkxxrGSmnXInSeGaPYR3uhQ9ppCILPjwSHfSfPu53Bu0Jn437HRuSeblAYY0el2WY7kQEt5)QjCw3vEfidvUUIazzAILzSqb1zHjdgQ8oxeIFwMMyHcQZctMRYQv5nlttSqb1zHjZvzD4VZY0eluqDwyY4vQCri(zzEma1vuoagdqdXF8wIuC0JbqLRRiW40fdWd)bRya437X1umGqFp1Nhdygl2WsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veilttSydlbiqQ86n1HA)ZdNyzAIfBybBrkv(9gf9yd(9E4kflrWIMSmnXInS8UIQ3u(VAcN1DLxbYqLRRiqwMZIwwSHfm9zDyTWM)O22ilBRvGLPjwMXcfuNfMmyOY7Cri(zzAIfkOolmzUkRwL3SmnXcfuNfMmxL1H)olttSqb1zHjJxPYfH4NL5Xauxr5aymane)XBbHJJEmaQCDfbgNUyaE4pyfda)EJxnkkgqOVN6ZJbmJLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqw0YsacKkVEtDO2)8Wjw0Yc2IuQ87nk6Xg879WvkwIGfnzzolAzXgwW0N1H1cB(JABJSSTwHyaQROCamgGgI)4pgain8L6JJE8w0mo6Xa8WFWkgagQ8oRtEsmaQCDfbgNU4pEl2gh9yau56kcmoDXac99uFEmG)siwqelZyXwwIglE4pyzS3(VBco(Z)LqSGaw8WFWYGFVhxtMGJ)8FjelZJbG)(cF8w0mgGh(dwXacUsL9WFWkRo8hdqD4pxEcfdaArf1XF8wIuC0JbqLRRiW40fdaAfdatFmap8hSIba07Z1vumaGUArXaWwKsLFVrrp2GFVhUsXYMSOjlAzzgl2WY7kQEd(9wbBqdvUUIazzAIL3vu9g8tkL3zW(gVHkxxrGSmNLPjwWwKsLFVrrp2GFVhUsXYMSyBmaqch6Z6pyfdaa9yw2keTybwSejeWI973HRNfW(gplEbYI973zbW7Tc2GS4fil2IawG)o12pmfdaO35YtOyaho7qk(J3cchh9yau56kcmoDXaGwXaW0hdWd)bRyaa9(CDffdaORwumaSfPu53Bu0Jn437X1elBYIMXaajCOpR)Gvmaa0JzjOihiXI9DQybW794AILGxSSFpl2IawEVrrpMf77xyNLdZstkcOxpldyZYVtSGwb1zHjwEil6elwnnOUjqw8cKf77xyNLXPuuZYdzj44pgaqVZLNqXaoCoOihif)XBrdXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdWQjGzubqJMMeiSgxtSmnXIvtaZOcGgnn4vnUMyzAIfRMaMrfanAAWV34vJIyzAIfRMaMrfanAAWV3dxPyzAIfRMaMrfanAAgRovgoYKAvelttSy1eqt7aPcUW5rtvusXY0el6RXWe88vbttj(vywIGf91yycE(QGbC1(FWILPjwa6956kYC4SdPyaGeo0N1FWkgquxVpxxrS87(ZsyNciHz5gSKcUyXBILRyXzbvaKLhYIdeEGS87el47x(FWIf77utS4S89virpl0hy5WSSWeilxXIo92jQyj44hhdaO35YtOyaxLrfaJ)4TGoIJEmaQCDfbgNUyaE4pyfdqNAm1iDfQyaGeo0N1FWkgq6Hjwsh1yQr6kuS4pl)oXcvGSahSGCBQIskwSVtfl7o(jwomlUoeiXc6inKd6zXhp1SGmybeIeXIxGSa)DQTFyIf73VZcY2kAs)kedi03t95XaMXYmwSHLaeivE9M6qT)5HtSmnXInSeGqfi0EzcWciejk)7ugBD99yZYILPjw6vrdyJImbsr4)CvgBD99ydvUUIazzolAzrFngMGNVkyAkXVcZYMSOPgyrll6RXW0oqQGlCE0ufLuMMs8RWSGiwqyw0YInSeGaPYR3aKQFpvZY0elbiqQ86naP63t1SOLf91yycE(QGzzXIww0xJHPDGubx48OPkkPmllw0YYmw0xJHPDGubx48OPkkPmnL4xHzbrrWIM2YIgZccZs0yPxfnGnkYGVASu59u4N6Znu56kcKLPjw0xJHj45RcMMs8RWSGiw0utwMMyrtwqdlylsPY7o(jwqelAAqhSmNL5SOLfGEFUUImxLrfaJ)4TGoJJEmaQCDfbgNUyaH(EQppgWmw0xJHj45RcMMs8RWSSjlAQbw0YYmwSHLEv0a2Oid(QXsL3tHFQp3qLRRiqwMMyrFngM2bsfCHZJMQOKY0uIFfMfeXIMrnw0YI(AmmTdKk4cNhnvrjLzzXYCwMMyrhIXSOLLXHA)ZnL4xHzbrSyRgyzolAzbO3NRRiZvzubWyaGeo0N1FWkgacb(Sy)(DwCwq2wrt6xbw(D)z5W12ploliKLc7nlwnmWcSzX(ovS87elJd1(ZYHzX1HRNLhYcvGXa8WFWkgGf8pyf)XBjYIJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgqGoflZyzglJd1(NBkXVcZIgZIMAGfnMLaeQaH2ltWZxfmnL4xHzzolOHfnJS0yzolrWsGoflZyzglJd1(NBkXVcZIgZIMAGfnMLaeQaH2ltawaHir5FNYyRRVhBaxT)hSyrJzjaHkqO9YeGfqisu(3Pm2667XMMs8RWSmNf0WIMrwASmNfTSydlTFGzcivVXbbXgcXh(XSOLLzSydlbiubcTxMGNVkyAYbtXY0el2WsacvGq7LjalGqKittoykwMZY0elbiubcTxMGNVkyAkXVcZYMSC1tTfu5pbMhhQ9p3uIFfMLPjw6vrdyJImbsr4)CvgBD99ydvUUIazrllbiubcTxMGNVkyAkXVcZYMSeP0yzAILaeQaH2ltawaHir5FNYyRRVhBAkXVcZYMSC1tTfu5pbMhhQ9p3uIFfMfnMfntJLPjwSHLaeivE9M6qT)5HtXaajCOpR)GvmaK5QWs5pHzX(o97uZYcFfkwqgSacrIyPG2zX(PuS4kf0olPGlwEil4)ukwco(z53jwWEcXINax1ZcCWcYGfqisecq2wrt6xbwco(XXaa6DU8ekgqawaHirzqcNQcXF8wIAXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdWgwWWLs)kqZV3NsLXeHe1gQCDfbYY0elJd1(NBkXVcZYMSyBAPXY0el6qmMfTSmou7FUPe)kmliIfB1aliGLzSGWPXIgZI(Amm)EFkvgtesuBWVhqILOXITSmNLPjw0xJH537tPYyIqIAd(9asSSjlrkYyrJzzgl9QObSrrg8vJLkVNc)uFUHkxxrGSenwSLL5XaajCOpR)GvmGOUEFUUIyzHjqwEilGKYtXIxPy57RqIEmlEbYsaeZI9DQyXUF)vOyzaBw8If0AzTd7ZzXQHHyaa9oxEcfd437tPYyIqI6SD)(4pElAMwC0JbqLRRiW40fdaKWH(S(dwXaspmXcALyLQjxXIgDdwEfiwSnnmfWSOtdytS4SGSTIM0VcSSWelWMfmKLF3FwUNf7NsXI6kILLfl2VFNLFNyHkqwGdwqUnvrjvmGYtOyauIvQMCvg2GLxbkgqOVN6ZJbeGqfi0EzcE(QGPPe)kmliIfBtJfTSeGqfi0EzcWciejk)7ugBD99yttj(vywqel2MglAzzgla9(CDfz(9(uQmMiKOoB3VNLPjw0xJH537tPYyIqIAd(9asSSjlrknwqalZyPxfnGnkYGVASu59u4N6Znu56kcKLOXsKyzolZzrlla9(CDfzUkJkaYY0el6qmMfTSmou7FUPe)kmliILiHoJb4H)GvmakXkvtUkdBWYRaf)XBrtnJJEmaQCDfbgNUyaGeo0N1FWkgq6Hjwaaxkf9xHIfeAl9uSGoWuaZIonGnXIZcY2kAs)kWYctSaBwWqw(D)z5EwSFkflQRiwwwSy)(Dw(DIfQazboyb52ufLuXakpHIbGHlLI()ku5EPNkgqOVN6ZJbmJLaeQaH2ltWZxfmnL4xHzbrSGoyrll2WsacKkVEdqQ(9unlAzXgwcqGu51BQd1(NhoXY0elbiqQ86n1HA)ZdNyrllbiubcTxMaSacrIY)oLXwxFp20uIFfMfeXc6GfTSmJfGEFUUImbybeIeLbjCQkWY0elbiubcTxMGNVkyAkXVcZcIybDWYCwMMyjabsLxVbiv)EQMfTSmJfByPxfnGnkYGVASu59u4N6Znu56kcKfTSeGqfi0EzcE(QGPPe)kmliIf0blttSOVgdt7aPcUW5rtvuszAkXVcZcIyrZ0ybbSmJfnWs0yHI81zzrGMRWFVcpSXzWd4vuwNukwMZIww0xJHPDGubx48OPkkPmllwMZY0el6qmMfTSmou7FUPe)kmliIfB1alttSqr(6SSiqdLyLQjxLHny5vGyrllbiubcTxgkXkvtUkdBWYRazAkXVcZYMSyBASmNfTSa07Z1vK5QmQailAzXgwOiFDwweO5kCOxVRROCKV86xjzqc4fiwMMyjaHkqO9YCfo0R31vuoYxE9RKmib8cKPPe)kmlBYITPXY0el6qmMfTSmou7FUPe)kmliIfBtlgGh(dwXaWWLsr)FfQCV0tf)XBrtBJJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgG(AmmbpFvW0uIFfMLnzrtnWIwwMXInS0RIgWgfzWxnwQ8Ek8t95gQCDfbYY0el6RXW0oqQGlCE0ufLuMMs8RWSGOiyrtny0aliGLzSejJgyjASOVgdJUccbvl8BwwSmNfeWYmwqyJgyrJzjsgnWs0yrFnggDfecQw43SSyzolrJfkYxNLfbAUc)9k8WgNbpGxrzDsPybbSGWgnWs0yzgluKVollc087uECn(Z4d1PyrllbiubcTxMFNYJRXFgFOoLPPe)kmlikcwSnnwMZIww0xJHPDGubx48OPkkPmllwMZY0elJd1(NBkXVcZcIyXwnWY0eluKVollc0qjwPAYvzydwEfiw0YsacvGq7LHsSs1KRYWgS8kqMMs8RWXaajCOpR)GvmGTQS7PWSSWelPFuNAewSF)oliBROj9RalWMf)z53jwOcKf4GfKBtvusfdaO35YtOyaxKdMdWc8(dwXF8w0msXrpgavUUIaJtxmap8hSIbCfo0R31vuoYxE9RKmib8cumGqFp1NhdaO3NRRiZf5G5aSaV)GflAzbO3NRRiZvzubWyaLNqXaUch6176kkh5lV(vsgKaEbk(J3IMiCC0JbqLRRiW40fdaKWH(S(dwXaspmXcGDheANazrJU1zrNgWMybzBfnPFfIbuEcfdaV7Gq7eyg26z4i)WoHQpgqOVN6ZJbmJLaeQaH2ltWZxfmn5GPyrll2WsacKkVEtDO2)8Wjw0YcqVpxxrMFVpLkJjcjQZ297zrllZyjaHkqO9YOtnMAKUcLPjhmflttSydlThiZ3qLIL5SmnXsacKkVEtDO2)8Wjw0YsacvGq7LjalGqKO8VtzS113Jnn5GPyrllZybO3NRRitawaHirzqcNQcSmnXsacvGq7Lj45RcMMCWuSmNL5SOLfq4BWRACnz(lG0vOyrllZybe(g8tkL35HYBY8xaPRqXY0el2WY7kQEd(jLY78q5nzOY1veilttSGTiLk)EJIESb)EpUMyztwIelZzrllGW3KaH14AY8xaPRqXIwwMXcqVpxxrMdNDiXY0el9QObSrrgDx5vGYWr2vQ8VFfkSHkxxrGSmnXIJ)2vzlODQzzZiyjQLglttSa07Z1vKjalGqKOmiHtvbwMMyrFnggDfecQw43SSyzolAzXgwOiFDwweO5kCOxVRROCKV86xjzqc4fiwMMyHI81zzrGMRWHE9UUIYr(YRFLKbjGxGyrllbiubcTxMRWHE9UUIYr(YRFLKbjGxGmnL4xHzztwIuASOLfByrFngMGNVkywwSmnXIoeJzrllJd1(NBkXVcZcIybHtlgGh(dwXaW7oi0obMHTEgoYpStO6J)4TOPgIJEmaQCDfbgNUyaGeo0N1FWkgq03pmlhMfNL2)DQzHuUoS9NyXUNILhYsIJeXIRuSalwwyIf87plFFfs0Jz5HSOtSOUIazzzXI973zbzBfnPFfyXlqwqgSacrIyXlqwwyILFNyX2cKfSc(SalwcGSCdw0H)olFFfs0JzXBIfyXYctSGF)z57RqIECmGqFp1Nhdygla9(CDfzGvEHP83xHe9SyteSOjlAzXgw((kKO382AAYbtLdqOceAVyzAILzSa07Z1vKbw5fMYFFfs0ZseSOjlttSa07Z1vKbw5fMYFFfs0ZseSejwMZIwwMXI(AmmbpFvWSSyrllZyXgwcqGu51Bas1VNQzzAIf91yyAhivWfopAQIskttj(vywqalZyjsgnWs0yPxfnGnkYGVASu59u4N6Znu56kcKL5SGOiy57RqIEZRPrFngzWv7)blw0YI(AmmTdKk4cNhnvrjLzzXY0el6RXW0oqQGlCE0ufLuz8vJLkVNc)uFUzzXYCwMMyjaHkqO9Ye88vbttj(vywqal2YYMS89virV510eGqfi0EzaxT)hSyrll2WI(AmmbpFvWSSyrllZyXgwcqGu51BQd1(NhoXY0el2WcqVpxxrMaSacrIYGeovfyzolAzXgwcqGu51BqkvFEXY0elbiqQ86n1HA)ZdNyrlla9(CDfzcWciejkds4uvGfTSeGqfi0EzcWciejk)7ugBD99yZYIfTSydlbiubcTxMGNVkywwSOLLzSmJf91yyOG6SWuwTkVnnL4xHzztw0mnwMMyrFnggkOolmLXqL3MMs8RWSSjlAMglZzrll2WsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veilttSmJf91yy0DLxbkdhzxPY)(vOW5Y)vtg87bKyjcw0alttSOVgdJUR8kqz4i7kv(3Vcfo7DWlYGFpGelrWsKXYCwMZY0el6RXWG0vGnbMPelODQtO6ZurnQlkKzzXYCwMMyrhIXSOLLXHA)ZnL4xHzbrSyBASmnXcqVpxxrgyLxyk)9virplrWsASmNfTSa07Z1vK5QmQaymaSc(4yaFFfs0Rzmap8hSIb89virVMXF8w0eDeh9yau56kcmoDXa8WFWkgW3xHe92gdi03t95XaMXcqVpxxrgyLxyk)9virpl2ebl2YIwwSHLVVcj6nVMMMCWu5aeQaH2lwMMybO3NRRidSYlmL)(kKONLiyXww0YYmw0xJHj45RcMLflAzzgl2WsacKkVEdqQ(9unlttSOVgdt7aPcUW5rtvuszAkXVcZccyzglrYObwIgl9QObSrrg8vJLkVNc)uFUHkxxrGSmNfefblFFfs0BEBn6RXidUA)pyXIww0xJHPDGubx48OPkkPmllwMMyrFngM2bsfCHZJMQOKkJVASu59u4N6ZnllwMZY0elbiubcTxMGNVkyAkXVcZccyXww2KLVVcj6nVTMaeQaH2ld4Q9)GflAzXgw0xJHj45RcMLflAzzgl2WsacKkVEtDO2)8WjwMMyXgwa6956kYeGfqisugKWPQalZzrll2WsacKkVEdsP6Zlw0YYmwSHf91yycE(QGzzXY0el2WsacKkVEdqQ(9unlZzzAILaeivE9M6qT)5HtSOLfGEFUUImbybeIeLbjCQkWIwwcqOceAVmbybeIeL)DkJTU(ESzzXIwwSHLaeQaH2ltWZxfmllw0YYmwMXI(AmmuqDwykRwL3MMs8RWSSjlAMglttSOVgddfuNfMYyOYBttj(vyw2KfntJL5SOLfByPxfnGnkYO7kVcugoYUsL)9RqHnu56kcKLPjwMXI(Amm6UYRaLHJSRu5F)ku4C5)Qjd(9asSeblAGLPjw0xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqILiyjYyzolZzzolttSOVgddsxb2eyMsSG2PoHQptf1OUOqMLflttSOdXyw0YY4qT)5Ms8RWSGiwSnnwMMybO3NRRidSYlmL)(kKONLiyjnwMZIwwa6956kYCvgvamgawbFCmGVVcj6Tn(J3IMOZ4OhdGkxxrGXPlgaiHd9z9hSIbKEycZIRuSa)DQzbwSSWel3tjywGflbWyaE4pyfdyHP89uco(J3IMrwC0JbqLRRiW40fdaKWH(S(dwXaqR73PMfuqwU6HS87el4NfyZIdjw8WFWIf1H)yaE4pyfdOxv2d)bRS6WFma83x4J3IMXac99uFEmaGEFUUImho7qkgG6WFU8ekgGdP4pElAg1IJEmaQCDfbgNUyaE4pyfdOxv2d)bRS6WFma1H)C5juma8h)XFmaRMcWeD)JJE8w0mo6Xa8WFWkgasxb2eygBD994yau56kcmoDXF8wSno6XaOY1veyC6IbaTIbGPpgGh(dwXaa6956kkgaqxTOyaPfdaKWH(S(dwXaI(oXcqVpxxrSCywW0ZYdzjnwSF)olfKf87plWILfMy57RqIEm6zrtwSVtfl)oXY4A8ZcSiwomlWILfMqpl2YYny53jwWuawGSCyw8cKLiXYnyrh(7S4nfdaO35YtOyaWkVWu(7RqI(4pElrko6XaOY1veyC6IbaTIb4GGXa8WFWkgaqVpxxrXaa6QffdqZyaH(EQppgW3xHe9MxtZUJZlmL1xJblAz57RqIEZRPjaHkqO9YaUA)pyXIwwSHLVVcj6nVMMdBEycLHJCcSWFdx4Caw4VxH)GfogaqVZLNqXaGvEHP83xHe9XF8wq44OhdGkxxrGXPlga0kgGdcgdWd)bRyaa9(CDffdaORwumaBJbe67P(8yaFFfs0BEBn7ooVWuwFngSOLLVVcj6nVTMaeQaH2ld4Q9)GflAzXgw((kKO382AoS5HjugoYjWc)nCHZbyH)Ef(dw4yaa9oxEcfdaw5fMYFFfs0h)XBrdXrpgavUUIaJtxmaOvmahemgGh(dwXaa6956kkgaqVZLNqXaGvEHP83xHe9Xac99uFEmakYxNLfbAUch6176kkh5lV(vsgKaEbILPjwOiFDwweOHsSs1KRYWgS8kqSmnXcf5RZYIany4sPO)VcvUx6PIbas4qFw)bRyarFNWelFFfs0JzXBILc(S4RhM4)fCLkflG0tHNazXXSalwwyIf87plFFfs0JnSWca6zbO3NRRiwEilimloMLFNsXIRWqwkIazbBrHZvSS7fO6kuMyaaD1IIbGWXF8wqhXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdisPXs0yzglAYIgZsAgBzjASGPpRdRf28h12gzze2kWY8yaGeo0N1FWkgaa6XS87elaEVXRgfXsaIFwgWMfL)uZsWvHLY)dwywMnGnleI9elfXI9DQy5HSGFVFwaxjwxHIfDAaBIfKBtvusXYWvkmlWXyEmaGENlpHIbGX5ae)XF8wqNXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdisPXccyrZ0yjAS0RIgWgfzcKIW)5Qm2667XgQCDfbgdaKWH(S(dwXaaqpMf)zX((f2zXtGR6zboyzRyeclidwaHirSG3Hlfil6ellmbgvSGWPXI973HRNfKrkc)NRybG113JzXlqwIuASy)(DtmaGENlpHIbeGfqisu2XwXF8wIS4OhdWd)bRyajqyH0v5bStIbqLRRiW40f)XBjQfh9yau56kcmoDXa8WFWkgG92)9yaH(EQppgWmwOG6SWKrTkVZfH4NLPjwOG6SWK5QmgQ8MLPjwOG6SWK5QSo83zzAIfkOolmz8kvUie)SmpgG6kkhaJbOzAXF8hdWHuC0J3IMXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdOxfnGnkY8xczh2vgSjpr)kqQnu56kcKfTSmJf91yy(lHSd7kd2KNOFfi1MMs8RWSGiwqfanjoIzbbSKMrtwMMyrFngM)si7WUYGn5j6xbsTPPe)kmliIfp8hSm437X1KHqmfwpL)lHybbSKMrtw0YYmwOG6SWK5QSAvEZY0eluqDwyYGHkVZfH4NLPjwOG6SWKXRu5Iq8ZYCwMZIww0xJH5VeYoSRmytEI(vGuBwwXaajCOpR)GvmaK5QWs5pHzX(o97uZYVtSOrAYtc(h2PMf91yWI9tPyz4kflWXGf73VFfl)oXsri(zj44pgaqVZLNqXaaBYtY2pLkpCLkdhJ4pEl2gh9yau56kcmoDXaGwXaW0hdWd)bRyaa9(CDffdaORwumaByHcQZctMRYyOYBw0Yc2IuQ87nk6Xg8794AILnzbDYIgZY7kQEdgUuz4i)7uEaBc)gQCDfbYs0yXwwqaluqDwyYCvwh(7SOLfByPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazrll2WsVkAaBuKbw0VJZbf5Dg4HpyzOY1veymaqch6Z6pyfdazUkSu(tywSVt)o1Sa49gVAuelhMf7W(3zj44)kuSabsnlaEVhxtSCfli)Q8Mf0kOolmfdaO35YtOyahQc2ug)EJxnkk(J3sKIJEmaQCDfbgNUyaE4pyfdialGqKO8VtzS113JJbas4qFw)bRyaPhMybzWciejIf77uXI)SOimMLF3lw0qASSvmcHfVazrDfXYYIf73VZcY2kAs)kedi03t95XaSHfWEDGMcMdGyw0YYmwMXcqVpxxrMaSacrIYGeovfyrll2WsacvGq7Lj45RcMMCWuSmnXI(AmmbpFvWSSyzolAzzgl6RXWqb1zHPSAvEBAkXVcZYMSObwMMyrFnggkOolmLXqL3MMs8RWSSjlAGL5SOLLzS44VDv2cANAwqelAinw0YYmwWwKsLFVrrp2GFVhxtSSjlrILPjw0xJHj45RcMLflZzzAIfByPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazzolAzzgl2WY7kQEd(jLY7myFJ3qLRRiqwMMyrFngg879Wvkttj(vywqelAA0alAmlPz0alrJLEv0a2OitGue(pxLXwxFp2qLRRiqwMMyrFngMGNVkyAkXVcZcIyrFngg879Wvkttj(vywqalAGfTSOVgdtWZxfmllwMZIwwMXInS0RIgWgfz0DLxbkdhzxPY)(vOWgQCDfbYY0el6RXWO7kVcugoYUsL)9RqHZL)RMm43diXYMSejwMMyrFnggDx5vGYWr2vQ8VFfkC27GxKb)Eajw2KLiXYCwMMyrhIXSOLLXHA)ZnL4xHzbrSOzASOLLaeQaH2ltWZxfmnL4xHzztw0alZJ)4TGWXrpgavUUIaJtxmap8hSIbGx14Akgqivqr53Bu0JJ3IMXac99uFEmGzS00Oj8URRiwMMyrFnggkOolmLXqL3MMs8RWSGiwIelAzHcQZctMRYyOYBw0Ystj(vywqelAIWSOLL3vu9gmCPYWr(3P8a2e(nu56kcKL5SOLL3Bu0B(lHYpmdEelBYIMimlAmlylsPYV3OOhZccyPPe)kmlAzzgluqDwyYCv2RuSmnXstj(vywqelOcGMehXSmpgaiHd9z9hSIbKEyIfaRACnXYvSy5fiLCbwGflEL63Vcfl)U)SOoGeMfnrymfWS4filkcJzX(97SKaBIL3Bu0JzXlqw8NLFNyHkqwGdwCwaavEZcAfuNfMyXFw0eHzbtbmlWMffHXS0uIF1vOyXXS8qwk4ZYUd8kuS8qwAA0eENfWvFfkwq(v5nlOvqDwyk(J3IgIJEmaQCDfbgNUyaE4pyfdaVQX1umaqch6Z6pyfdi9Welaw14AILhYYUdKyXzbLcQ7kwEillmXs6h1PgjgqOVN6ZJba07Z1vK5ICWCawG3FWIfTSeGqfi0EzUch6176kkh5lV(vsgKaEbY0KdMIfTSqr(6SSiqZv4qVExxr5iF51VsYGeWlqSOLf3kh2PasXF8wqhXrpgavUUIaJtxmap8hSIbGFVhUsfdaKWH(S(dwXaI6rKflllwa8EpCLIf)zXvkw(lHWSSkfHXSSWxHIfKpvWBhZIxGSCplhMfxhUEwEilwnmWcSzrrpl)oXc2IcNRyXd)blwuxrSOtkODw29curSOrAYt0VcKAwGfl2YY7nk6XXac99uFEmaBy5DfvVb)Ks5DgSVXBOY1veilAzzgl2WcM(SoSwyZFuBBKLryRalttSqb1zHjZvzVsXY0elylsPYV3OOhBWV3dxPyztwIelZzrllZyrFngg879WvkttJMW7UUIyrllZybBrkv(9gf9yd(9E4kfliILiXY0el2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilZzzAIL3vu9gmCPYWr(3P8a2e(nu56kcKfTSOVgddfuNfMYyOYBttj(vywqelrIfTSqb1zHjZvzmu5nlAzrFngg879Wvkttj(vywqelOtw0Yc2IuQ87nk6Xg879Wvkw2mcwqywMZIwwMXInS0RIgWgfzuPcE748qr0FfQmk1LyHjdvUUIazzAIL)siwqoSGWAGLnzrFngg879Wvkttj(vywqal2YYCw0YY7nk6n)Lq5hMbpILnzrdXF8wqNXrpgavUUIaJtxmap8hSIbGFVhUsfdaKWH(S(dwXaqOUFNfapPuEZIgPVXZYctSalwcGSyFNkwAA0eE31vel6RNf8Fkfl297zzaBwq(ubVDmlwnmWIxGSacRTFwwyIfDAaBIfKPrWgwa8NsXYctSOtdytSGmybeIeXc(QaXYV7pl2pLIfRggyXl4VtnlaEVhUsfdi03t95XaExr1BWpPuENb7B8gQCDfbYIww0xJHb)EpCLY00Oj8URRiw0YYmwSHfm9zDyTWM)O22ilJWwbwMMyHcQZctMRYELILPjwWwKsLFVrrp2GFVhUsXYMSGWSmNfTSmJfByPxfnGnkYOsf82X5HIO)kuzuQlXctgQCDfbYY0el)LqSGCybH1alBYccZYCw0YY7nk6n)Lq5hMbpILnzjsXF8wIS4OhdGkxxrGXPlgGh(dwXaWV3dxPIbas4qFw)bRyaiu3VZIgPjpr)kqQzzHjwa8EpCLILhYcsezXYYILFNyrFngSONIfxHHSSWxHIfaV3dxPybwSObwWuawGywGnlkcJzPPe)QRqfdi03t95Xa6vrdyJIm)Lq2HDLbBYt0VcKAdvUUIazrllylsPYV3OOhBWV3dxPyzZiyjsSOLLzSydl6RXW8xczh2vgSjpr)kqQnllw0YI(Amm437HRuMMgnH3DDfXY0elZybO3NRRidytEs2(Pu5HRuz4yWIwwMXI(Amm437HRuMMs8RWSGiwIelttSGTiLk)EJIESb)EpCLILnzXww0YY7kQEd(jLY7myFJ3qLRRiqw0YI(Amm437HRuMMs8RWSGiw0alZzzolZJ)4Te1IJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgGJ)2vzlODQzztwIS0yjASmJfnzrJzbtFwhwlS5pQTnYY2AfyjASKMXwwMZs0yzglAYIgZI(Amm)Lq2HDLbBYt0VcKAd(9asSenwsZOjlZzrJzzgl6RXWGFVhUszAkXVcZs0yjsSGgwWwKsL3D8tSenwSHL3vu9g8tkL3zW(gVHkxxrGSmNfnMLzSeGqfi0EzWV3dxPmnL4xHzjASejwqdlylsPY7o(jwIglVRO6n4NukVZG9nEdvUUIazzolAmlZyrFngMXQtLHJmPwfzAkXVcZs0yrdSmNfTSmJf91yyWV3dxPmllwMMyjaHkqO9YGFVhUszAkXVcZY8yaGeo0N1FWkgaYCvyP8NWSyFN(DQzXzbW7nE1OiwwyIf7NsXsWxyIfaV3dxPy5HSmCLIf4yGEw8cKLfMybW7nE1OiwEilirKflAKM8e9RaPMf87bKyzzzyjYsJLdZYVtS0uKVUMazzRyeclpKLGJFwa8EJxnkcbaEVhUsfdaO35YtOya437HRuz7W6ZdxPYWXi(J3IMPfh9yau56kcmoDXa8WFWkga(9gVAuumaqch6Z6pyfdi9WelaEVXRgfXI973zrJ0KNOFfi1S8qwqIilwwwS87el6RXGf73Vdxplki(kuSa49E4kfllR)siw8cKLfMybW7nE1OiwGflimcyjDWTgDwWVhqcZYQ(tXccZY7nk6XXac99uFEmaGEFUUImGn5jz7NsLhUsLHJblAzbO3NRRid(9E4kv2oS(8WvQmCmyrll2WcqVpxxrMdvbBkJFVXRgfXY0elZyrFnggDx5vGYWr2vQ8VFfkCU8F1Kb)Eajw2KLiXY0el6RXWO7kVcugoYUsL)9RqHZEh8Im43diXYMSejwMZIwwWwKsLFVrrp2GFVhUsXcIybHzrlla9(CDfzWV3dxPY2H1NhUsLHJr8hVfn1mo6XaOY1veyC6Ib4H)Gvmah0T(diLX29ojgqivqr53Bu0JJ3IMXac99uFEmaBy5VasxHIfTSydlE4pyzCq36pGugB37KmON4OiZv5H6qT)SmnXci8noOB9hqkJT7Dsg0tCuKb)EajwqelrIfTSacFJd6w)bKYy7ENKb9ehfzAkXVcZcIyjsXaajCOpR)GvmG0dtSGT7Dclyil)U)SKcUybf9SK4iMLL1Fjel6PyzHVcfl3ZIJzr5pXIJzXcIXNUIybwSOimMLF3lwIel43diHzb2Se1Xc)SyFNkwIecyb)EajmleITUMI)4TOPTXrpgavUUIaJtxmap8hSIbKaH14Akgqivqr53Bu0JJ3IMXac99uFEmGMgnH3DDfXIwwEVrrV5Vek)Wm4rSSjlZyzglAIWSGawMXc2IuQ87nk6Xg8794AILOXITSenw0xJHHcQZctz1Q82SSyzolZzbbS0uIFfML5SGgwMXIMSGawExr1BE7xLtGWcBOY1veilZzrllZyXTYHDkGelttSa07Z1vK5qvWMY43B8QrrSmnXInSqb1zHjZvzVsXYCw0YYmwcqOceAVmbpFvW0KdMIfTSqb1zHjZvzVsXIwwSHfWEDGMcMdGyw0YYmwa6956kYeGfqisugKWPQalttSeGqfi0EzcWciejk)7ugBD99yttoykwMMyXgwcqGu51BQd1(NhoXYCwMMybBrkv(9gf9yd(9ECnXcIyzglZybDWIgZYmw0xJHHcQZctz1Q82SSyjASyllZzzolrJLzSOjliGL3vu9M3(v5eiSWgQCDfbYYCwMZIwwSHfkOolmzWqL35Iq8ZIwwSHLaeQaH2ltWZxfmn5GPyzAILzSqb1zHjZvzmu5nlttSOVgddfuNfMYQv5TzzXIwwSHL3vu9gmCPYWr(3P8a2e(nu56kcKLPjw0xJHXQVeydEUk7DWRlKTwkS3gGUArSSzeSyRgsJL5SOLLzSGTiLk)EJIESb)EpUMybrSOzASenwMXIMSGawExr1BE7xLtGWcBOY1veilZzzolAzXXF7QSf0o1SSjlAinw0yw0xJHb)EpCLY0uIFfMLOXc6GL5SOLLzSydlbiqQ86niLQpVyzAIfByrFnggKUcSjWmLybTtDcvFMkQrDrHmllwMMyHcQZctMRYyOYBwMZIwwSHf91yyAhivWfopAQIsQm(QXsL3tHFQp3SSIbas4qFw)bRyai0Ort4Dw0OGWACnXYnybzBfnPFfy5WS0KdMc9S87utS4nXIIWyw(DVyrdS8EJIEmlxXcYVkVzbTcQZctSy)(DwaaFKl6zrryml)UxSOzASa)DQTFyILRyXRuSGwb1zHjwGnlllwEilAGL3Bu0JzrNgWMyXzb5xL3SGwb1zHjdlAeyT9ZstJMW7SaU6RqXsuVRaBcKf0kXcAN6eQEwwLIWywUIfaqL3SGwb1zHP4pElAgP4OhdGkxxrGXPlgGh(dwXagWoqz4ix(VAkgaiHd9z9hSIbKEyIfKlClSalwcGSy)(D46zj4wwxHkgqOVN6ZJb4w5WofqILPjwa6956kYCOkytz87nE1OO4pElAIWXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdWgwa71bAkyoaIzrllZybO3NRRitamhGf49hSyrllZyrFngg879WvkZYILPjwExr1BWpPuENb7B8gQCDfbYY0elbiqQ86n1HA)ZdNyzolAzbe(MeiSgxtM)ciDfkw0YYmwSHf91yyWqf(VazwwSOLfByrFngMGNVkywwSOLLzSydlVRO6nJvNkdhzsTkYqLRRiqwMMyrFngMGNVkyaxT)hSyztwcqOceAVmJvNkdhzsTkY0uIFfMfeWsKXYCw0YYmwSHfm9zDyTWM)O22ilBRvGLPjwOG6SWK5QSAvEZY0eluqDwyYGHkVZfH4NL5SOLfGEFUUIm)EFkvgtesuNT73ZIwwMXInSeGaPYR3uhQ9ppCILPjwcqOceAVmbybeIeL)DkJTU(ESPPe)kmliIf91yycE(QGbC1(FWILOXsAgnWYCw0YY7nk6n)Lq5hMbpILnzrFngMGNVkyaxT)hSyjASKMbDYYCwMMyrhIXSOLLXHA)ZnL4xHzbrSOVgdtWZxfmGR2)dwSGaw00wwIgl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilZJba07C5jumGayoalW7pyLDif)XBrtneh9yau56kcmoDXa8WFWkgq7aPcUW5rtvusfdaKWH(S(dwXaspmXcYTPkkPyX(97SGSTIM0VcXac99uFEma91yycE(QGPPe)kmlBYIMAGLPjw0xJHj45RcgWv7)blwqalAAllrJLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKfeXITOdw0YcqVpxxrMayoalW7pyLDif)XBrt0rC0JbqLRRiW40fdWd)bRyabsr4)Cv2vhQkHQpgaiHd9z9hSIbKEyIfKTv0K(vGfyXsaKLvPimMfVazrDfXY9SSSyX(97SGmybeIefdi03t95Xaa6956kYeaZbybE)bRSdjw0YYmw0xJHj45RcgWv7)blwqalAAllrJLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLnJGfBrhSmnXInSeGaPYR3aKQFpvZYCwMMyrFngM2bsfCHZJMQOKYSSyrll6RXW0oqQGlCE0ufLuMMs8RWSGiwIASGawcWcCDVXQPWHPSRouvcvV5Vekd0vlIfeWYmwSHf91yy0vqiOAHFZYIfTSydlVRO6n43BfSbnu56kcKL5XF8w0eDgh9yau56kcmoDXac99uFEmaGEFUUImbWCawG3FWk7qkgGh(dwXaUk4D5)bR4pElAgzXrpgavUUIaJtxmap8hSIbqjwq7uN1Hfymaqch6Z6pyfdi9WelOvIf0o1SKoybYcSyjaYI973zbW79WvkwwwS4filyhiXYa2SGqwkS3S4filiBROj9RqmGqFp1NhdyglbiubcTxMGNVkyAkXVcZccyrFngMGNVkyaxT)hSybbS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSenw00ww2KLaeQaH2ldLybTtDwhwGgWv7)blwqalAMglZzzAIf91yycE(QGPPe)kmlBYsKXY0elG96anfmhaXXF8w0mQfh9yau56kcmoDXa8WFWkga(jLY78q5nfdiKkOO87nk6XXBrZyaH(EQppgqtJMW7UUIyrll)Lq5hMbpILnzrtnWIwwWwKsLFVrrp2GFVhxtSGiwqyw0YIBLd7uajw0YYmw0xJHj45RcMMs8RWSSjlAMglttSydl6RXWe88vbZYIL5XaajCOpR)GvmaeA0Oj8oldL3elWILLflpKLiXY7nk6XSy)(D46zbzBfnPFfyrNUcflUoC9S8qwieBDnXIxGSuWNfiqQdUL1vOI)4TyBAXrpgavUUIaJtxmap8hSIbmwDQmCKj1QOyaGeo0N1FWkgq6HjwqUq0ILBWYv4dKyXlwqRG6SWelEbYI6kIL7zzzXI973zXzbHSuyVzXQHbw8cKLTc6w)bKybGDVtIbe67P(8yauqDwyYCv2RuSOLLzS4w5WofqILPjwSHLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKL5SOLLzSOVgdJvFjWg8Cv27GxxiBTuyVnaD1IybrSyRgsJLPjw0xJHj45RcMMs8RWSSjlrglZzrllZybe(gh0T(diLX29ojd6jokY8xaPRqXY0el2WsacKkVEtrHgQGnilttSGTiLk)EJIEmlBYITSmNfTSmJf91yyAhivWfopAQIskttj(vywqelrnw0ywMXccZs0yPxfnGnkYGVASu59u4N6Znu56kcKL5SOLf91yyAhivWfopAQIskZYILPjwSHf91yyAhivWfopAQIskZYIL5SOLLzSydlbiubcTxMGNVkywwSmnXI(Amm)EFkvgtesuBWVhqIfeXIMAGfTSmou7FUPe)kmliIfBtlnw0YY4qT)5Ms8RWSSjlAMwASmnXInSGHlL(vGMFVpLkJjcjQnu56kcKL5SOLLzSGHlL(vGMFVpLkJjcjQnu56kcKLPjwcqOceAVmbpFvW0uIFfMLnzjsPXYCw0YY7nk6n)Lq5hMbpILnzrdSmnXIoeJzrllJd1(NBkXVcZcIyrZ0I)4TyRMXrpgavUUIaJtxmap8hSIbGFVhUsfdaKWH(S(dwXaspmXIZcG37HRuSOrx0VZIvddSSkfHXSa49E4kflhMfx1KdMILLflWMLuWflEtS46W1ZYdzbcK6GBXYwXiKyaH(EQppgG(AmmWI(DC2I6az9hSmllw0YYmw0xJHb)EpCLY00Oj8URRiwMMyXXF7QSf0o1SSjlrT0yzE8hVfBTno6XaOY1veyC6Ib4H)Gvma879WvQyaGeo0N1FWkgGgzLyXYwXiew0PbSjwqgSacrIyX(97Sa49E4kflEbYYVtflaEVXRgffdi03t95XacqGu51BQd1(NhoXIwwSHL3vu9g8tkL3zW(gVHkxxrGSOLLzSa07Z1vKjalGqKOmiHtvbwMMyjaHkqO9Ye88vbZYILPjw0xJHj45RcMLflZzrllbiubcTxMaSacrIY)oLXwxFp20uIFfMfeXcQaOjXrmlrJLaDkwMXIJ)2vzlODQzbnSOH0yzolAzrFngg879Wvkttj(vywqelimlAzXgwa71bAkyoaIJ)4TyBKIJEmaQCDfbgNUyaH(EQppgqacKkVEtDO2)8Wjw0YYmwa6956kYeGfqisugKWPQalttSeGqfi0EzcE(QGzzXY0el6RXWe88vbZYIL5SOLLaeQaH2ltawaHir5FNYyRRVhBAkXVcZcIyrdSOLfGEFUUIm437HRuz7W6ZdxPYWXGfTSqb1zHjZvzVsXIwwSHfGEFUUImhQc2ug)EJxnkIfTSydlG96anfmhaXXa8WFWkga(9gVAuu8hVfBr44OhdGkxxrGXPlgGh(dwXaWV34vJIIbas4qFw)bRyaPhMybW7nE1OiwSF)olEXIgDr)olwnmWcSz5gSKcU2gKfiqQdUflBfJqyX(97SKcUAwkcXplbh)gw2QcdzbCLyXYwXiew8NLFNyHkqwGdw(DILOUu97PAw0xJbl3GfaV3dxPyXoCPaRTFwgUsXcCmyb2SKcUyXBIfyXITS8EJIECmGqFp1NhdqFnggyr)oohuK3zGh(GLzzXY0elZyXgwWV3JRjJBLd7uajw0YInSa07Z1vK5qvWMY43B8QrrSmnXYmw0xJHj45RcMMs8RWSGiw0alAzrFngMGNVkywwSmnXYmwMXI(AmmbpFvW0uIFfMfeXcQaOjXrmlrJLaDkwMXIJ)2vzlODQzbnSa07Z1vKbJZbi(zzolAzrFngMGNVkywwSmnXI(AmmTdKk4cNhnvrjvgF1yPY7PWp1NBAkXVcZcIybva0K4iMLOXsGoflZyXXF7QSf0o1SGgwa6956kYGX5ae)SmNfTSOVgdt7aPcUW5rtvusLXxnwQ8Ek8t95MLflZzrllbiqQ86naP63t1SmNL5SOLLzSGTiLk)EJIESb)EpCLIfeXsKyzAIfGEFUUIm437HRuz7W6ZdxPYWXGL5SmNfTSydla9(CDfzoufSPm(9gVAuelAzzgl2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilttSGTiLk)EJIESb)EpCLIfeXsKyzE8hVfB1qC0JbqLRRiW40fdWd)bRyafzpNaHvmaqch6Z6pyfdi9WelAuqyHz5kwaavEZcAfuNfMyXlqwWoqIfK7sPyrJcclwgWMfKTv0K(vigqOVN6ZJbmJf91yyOG6SWugdvEBAkXVcZYMSqiMcRNY)LqSmnXYmwc7EJIWSebl2YIwwAkS7nkk)xcXcIyrdSmNLPjwc7EJIWSeblrIL5SOLf3kh2PasXF8wSfDeh9yau56kcmoDXac99uFEmGzSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeILPjwMXsy3BueMLiyXww0YstHDVrr5)siwqelAGL5SmnXsy3BueMLiyjsSmNfTS4w5WofqIfTSmJf91yyAhivWfopAQIskttj(vywqelAGfTSOVgdt7aPcUW5rtvuszwwSOLfByPxfnGnkYGVASu59u4N6Znu56kcKLPjwSHf91yyAhivWfopAQIskZYIL5Xa8WFWkgWURg5eiSI)4Tyl6mo6XaOY1veyC6Ibe67P(8yaZyrFnggkOolmLXqL3MMs8RWSSjleIPW6P8FjelAzzglbiubcTxMGNVkyAkXVcZYMSOH0yzAILaeQaH2ltawaHir5FNYyRRVhBAkXVcZYMSOH0yzolttSmJLWU3OimlrWITSOLLMc7EJIY)LqSGiw0alZzzAILWU3OimlrWsKyzolAzXTYHDkGelAzzgl6RXW0oqQGlCE0ufLuMMs8RWSGiw0alAzrFngM2bsfCHZJMQOKYSSyrll2WsVkAaBuKbF1yPY7PWp1NBOY1veilttSydl6RXW0oqQGlCE0ufLuMLflZJb4H)GvmGXsPYjqyf)XBX2ilo6XaOY1veyC6Ibas4qFw)bRyaPhMybHcIwSalwqMgjgGh(dwXaS7DFWodhzsTkk(J3ITrT4OhdGkxxrGXPlga0kgaM(yaE4pyfdaO3NRROyaaD1IIbGTiLk)EJIESb)EpUMyztwqywqaldfe2SmJLeh)uNkd0vlILOXIMPLglOHfBtJL5SGawgkiSzzgl6RXWGFVXRgfLPelODQtO6ZyOYBd(9asSGgwqywMhdaKWH(S(dwXaqMRclL)eMf770VtnlpKLfMybW794AILRybau5nl23VWolhMf)zrdS8EJIEmc0KLbSzHasDkwSnnKdljo(PoflWMfeMfaV34vJIybTsSG2PoHQNf87bKWXaa6DU8ekga(9ECnLVkJHkVJ)4TeP0IJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgGMSGgwWwKsL3D8tSGiwSLfnMLzSKMXwwIglZybBrkv(9gf9yd(9ECnXIgZIMSmNLOXYmw0KfeWY7kQEdgUuz4i)7uEaBc)gQCDfbYs0yrtJgyzolZzbbSKMrtnWs0yrFngM2bsfCHZJMQOKY0uIFfogaiHd9z9hSIbGmxfwk)jml23PFNAwEiliuT)7SaU6RqXcYTPkkPIba07C5juma7T)75RYJMQOKk(J3sK0mo6XaOY1veyC6Ib4H)Gvma7T)7XaajCOpR)GvmG0dtSGq1(VZYvSaaQ8Mf0kOolmXcSz5gSuqwa8EpUMyX(PuSmUNLREiliBROj9RalELkb2umGqFp1NhdygluqDwyYOwL35Iq8ZY0eluqDwyY4vQCri(zrlla9(CDfzoCoOihiXYCw0YYmwEVrrV5Vek)Wm4rSSjlimlttSqb1zHjJAvENVkBllttSOdXyw0YY4qT)5Ms8RWSGiw0mnwMZY0el6RXWqb1zHPmgQ820uIFfMfeXIh(dwg8794AYqiMcRNY)LqSOLf91yyOG6SWugdvEBwwSmnXcfuNfMmxLXqL3SOLfBybO3NRRid(9ECnLVkJHkVzzAIf91yycE(QGPPe)kmliIfp8hSm437X1KHqmfwpL)lHyrll2WcqVpxxrMdNdkYbsSOLf91yycE(QGPPe)kmliIfcXuy9u(VeIfTSOVgdtWZxfmllwMMyrFngM2bsfCHZJMQOKYSSyrlla9(CDfzS3(VNVkpAQIskwMMyXgwa6956kYC4CqroqIfTSOVgdtWZxfmnL4xHzztwietH1t5)sO4pElrY24OhdGkxxrGXPlgaiHd9z9hSIbKEyIfaV3JRjwUblxXcYVkVzbTcQZctONLRybau5nlOvqDwyIfyXccJawEVrrpMfyZYdzXQHbwaavEZcAfuNfMIb4H)Gvma8794Ak(J3sKIuC0JbqLRRiW40fdaKWH(S(dwXaqUUs979kgGh(dwXa6vL9WFWkRo8hdqD4pxEcfdy4k1V3R4p(JbmCL637vC0J3IMXrpgavUUIaJtxmap8hSIbGFVXRgffdaKWH(S(dwXaa8EJxnkILbSzjbcKsO6zzvkcJzzHVcflPdU1Ohdi03t95XaSHLEv0a2OiJUR8kqz4i7kv(3Vcf2qr(6SSiW4pEl2gh9yau56kcmoDXa8WFWkgaEvJRPyaHubfLFVrrpoElAgdi03t95XaaHVjbcRX1KPPe)kmlBYstj(vywIgl2AllOHfnJSyaGeo0N1FWkgaYC8ZYVtSacFwSF)ol)oXsce)S8xcXYdzXbbzzv)Py53jwsCeZc4Q9)GflhML97nSayvJRjwAkXVcZsYs9NL6iqwEilj(h2zjbcRX1elGR2)dwXF8wIuC0Jb4H)GvmGeiSgxtXaOY1veyC6I)4pga(JJE8w0mo6XaOY1veyC6Ib4H)Gvmah0T(diLX29ojgqivqr53Bu0JJ3IMXac99uFEmaBybe(gh0T(diLX29ojd6jokY8xaPRqXIwwSHfp8hSmoOB9hqkJT7Dsg0tCuK5Q8qDO2Fw0YYmwSHfq4BCq36pGugB37K8o5kZFbKUcflttSacFJd6w)bKYy7ENK3jxzAkXVcZYMSObwMZY0elGW34GU1FaPm2U3jzqpXrrg87bKybrSejw0Yci8noOB9hqkJT7Dsg0tCuKPPe)kmliILiXIwwaHVXbDR)aszSDVtYGEIJIm)fq6kuXaajCOpR)GvmG0dtSSvq36pGelaS7Dcl23PILFNAILdZsbzXd)bKybB37e0ZIJzr5pXIJzXcIXNUIybwSGT7Dcl2VFNfBzb2Smi7uZc(9asywGnlWIfNLiHawW29oHfmKLF3Fw(DILISZc2U3jS4DFajmlrDSWpl(4PMLF3FwW29oHfcXwxt44pEl2gh9yau56kcmoDXa8WFWkgqawaHir5FNYyRRVhhdaKWH(S(dwXaspmHzbzWciejILBWcY2kAs)kWYHzzzXcSzjfCXI3elGeovfUcfliBROj9Ral2VFNfKblGqKiw8cKLuWflEtSOtkODwq40qtKsBgYifH)ZvSaW667XZzzRyeclxXIZIMPHawWuGf0kOolmzyzRkmKfqyT9ZIIEw0in5j6xbsnleITUMqplUYUNcZYctSCfliBROj9Ral2VFNfeYsH9MfVazXFw(DIf879ZcCWIZs6GBn6Sy)kqODtmGqFp1NhdWgwa71bAkyoaIzrllZyzgla9(CDfzcWciejkds4uvGfTSydlbiubcTxMGNVkyAYbtXIwwSHLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLPjw0xJHj45RcMLflZzrllZyzglo(BxLTG2PMfefbla9(CDfzcWciejk7ylw0YYmw0xJHHcQZctz1Q820uIFfMLnzrZ0yzAIf91yyOG6SWugdvEBAkXVcZYMSOzASmNLPjw0xJHj45RcMMs8RWSSjlAGfTSOVgdtWZxfmnL4xHzbrrWIM2YYCw0YYmwSHLEv0a2OiZFjKDyxzWM8e9RaP2qLRRiqwMMyXgw6vrdyJImbsr4)CvgBD99ydvUUIazzAIf91yy(lHSd7kd2KNOFfi1MMs8RWSSjleIPW6P8FjelZzzAILEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMZIwwMXInS0RIgWgfz0DLxbkdhzxPY)(vOWgQCDfbYY0elZyrFnggDx5vGYWr2vQ8VFfkCU8F1Kb)EajwIGLiJLPjw0xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqILiyjYyzolZzzAIfDigZIwwghQ9p3uIFfMfeXIMPXIwwSHLaeQaH2ltWZxfmn5GPyzE8hVLifh9yau56kcmoDXa8WFWkga(9gVAuumaqch6Z6pyfdi9WelaEVXRgfXYdzbjISyzzXYVtSOrAYt0VcKAw0xJbl3GL7zXoCPazHqS11el60a2elJRo8(vOy53jwkcXplbh)SaBwEilGRelw0PbSjwqgSacrIIbe67P(8ya9QObSrrM)si7WUYGn5j6xbsTHkxxrGSOLLzSydlZyzgl6RXW8xczh2vgSjpr)kqQnnL4xHzztw8WFWYyV9F3qiMcRNY)LqSGawsZOjlAzzgluqDwyYCvwh(7SmnXcfuNfMmxLXqL3SmnXcfuNfMmQv5DUie)SmNLPjw0xJH5VeYoSRmytEI(vGuBAkXVcZYMS4H)GLb)EpUMmeIPW6P8FjeliGL0mAYIwwMXcfuNfMmxLvRYBwMMyHcQZctgmu5DUie)SmnXcfuNfMmELkxeIFwMZYCwMMyXgw0xJH5VeYoSRmytEI(vGuBwwSmNLPjwMXI(AmmbpFvWSSyzAIfGEFUUImbybeIeLbjCQkWYCw0YsacvGq7LjalGqKO8VtzS113Jnn5GPyrllbiqQ86n1HA)ZdNyrllZyrFnggkOolmLvRYBttj(vyw2KfntJLPjw0xJHHcQZctzmu5TPPe)kmlBYIMPXYCwMZIwwMXInSeGaPYR3GuQ(8ILPjwcqOceAVmuIf0o1zDybAAkXVcZYMSezSmp(J3cchh9yau56kcmoDXa8WFWkga(9gVAuumaqch6Z6pyfdqJSsSybW7nE1Oiml2VFNL05kVcelWblBvPyj67xHcZcSz5HSy1KL3eldyZcYGfqisel2VFNL0b3A0Jbe67P(8ya9QObSrrgDx5vGYWr2vQ8VFfkSHkxxrGSOLLzSmJf91yy0DLxbkdhzxPY)(vOW5Y)vtg87bKyztwSLLPjw0xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqILnzXwwMZIwwcqOceAVmbpFvW0uIFfMLnzbDYIwwSHLaeQaH2ltawaHir5FNYyRRVhBwwSmnXYmwcqGu51BQd1(NhoXIwwcqOceAVmbybeIeL)DkJTU(ESPPe)kmliIfntJfTSqb1zHjZvzVsXIwwC83UkBbTtnlBYITPXccyjsPXs0yjaHkqO9Ye88vbttoykwMZY84pElAio6XaOY1veyC6IbaTIbGPpgGh(dwXaa6956kkgaqxTOyaZyrFngM2bsfCHZJMQOKY0uIFfMLnzrdSmnXInSOVgdt7aPcUW5rtvuszwwSmNfTSydl6RXW0oqQGlCE0ufLuz8vJLkVNc)uFUzzXIwwMXI(AmmiDfytGzkXcAN6eQ(mvuJ6IczAkXVcZcIybva0K4iML5SOLLzSOVgddfuNfMYyOYBttj(vyw2KfubqtIJywMMyrFnggkOolmLvRYBttj(vyw2KfubqtIJywMMyzgl2WI(AmmuqDwykRwL3MLflttSydl6RXWqb1zHPmgQ82SSyzolAzXgwExr1BWqf(VazOY1veilZJbas4qFw)bRyaidwG3FWILbSzXvkwaHpMLF3FwsCKiml4vtS87ukw8MQTFwAA0eENazX(ovSGqZbsfCHzb52ufLuSS7ywuegZYV7flAGfmfWS0uIF1vOyb2S87elOvIf0o1SKoybYI(Amy5WS46W1ZYdzz4kflWXGfyZIxPybTcQZctSCywCD46z5HSqi26AkgaqVZLNqXaaHFUPiFDnLq1JJ)4TGoIJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgWmwSHf91yyOG6SWugdvEBwwSOLfByrFnggkOolmLvRYBZYIL5SOLfBy5DfvVbdv4)cKHkxxrGSOLfByPxfnGnkY8xczh2vgSjpr)kqQnu56kcmgaiHd9z9hSIbGmybE)blw(D)zjStbKWSCdwsbxS4nXcC94dKyHcQZctS8qwGLkflGWNLFNAIfyZYHQGnXYVFywSF)olaGk8FbkgaqVZLNqXaaHFgUE8bszkOolmf)XBbDgh9yau56kcmoDXa8WFWkgqcewJRPyaHubfLFVrrpoElAgdi03t95XaMXI(AmmuqDwykJHkVnnL4xHzztwAkXVcZY0el6RXWqb1zHPSAvEBAkXVcZYMS0uIFfMLPjwa6956kYac)mC94dKYuqDwyIL5SOLLMgnH3DDfXIwwEVrrV5Vek)Wm4rSSjlAAllAzXTYHDkGelAzbO3NRRidi8Znf5RRPeQECmaqch6Z6pyfdqJaFwCLIL3Bu0JzX(97xXccXlqk5cSy)(D46zbcK6GBzDfke87elUoeiXsawG3FWch)XBjYIJEmaQCDfbgNUyaE4pyfdaVQX1umGqFp1Nhdygl6RXWqb1zHPmgQ820uIFfMLnzPPe)kmlttSOVgddfuNfMYQv5TPPe)kmlBYstj(vywMMybO3NRRidi8ZW1Jpqktb1zHjwMZIwwAA0eE31velAz59gf9M)sO8dZGhXYMSOPTSOLf3kh2PasSOLfGEFUUImGWp3uKVUMsO6XXacPckk)EJIEC8w0m(J3sulo6XaOY1veyC6Ib4H)Gvma8tkL35HYBkgqOVN6ZJbmJf91yyOG6SWugdvEBAkXVcZYMS0uIFfMLPjw0xJHHcQZctz1Q820uIFfMLnzPPe)kmlttSa07Z1vKbe(z46XhiLPG6SWelZzrllnnAcV76kIfTS8EJIEZFju(HzWJyztw0eDWIwwCRCyNciXIwwa6956kYac)Ctr(6AkHQhhdiKkOO87nk6XXBrZ4pElAMwC0JbqLRRiW40fdaAfdatFmap8hSIba07Z1vumaGUArXacqGu51Bas1VNQzrll2WsVkAaBuKbF1yPY7PWp1NBOY1veilAzXgw6vrdyJImHRdkkdhz1nOSxGzqY)DdvUUIazrllbiubcTxgDQXuJ0vOmn5GPyrllbiubcTxM2bsfCHZJMQOKY0KdMIfTSydl6RXWe88vbZYIfTSmJfh)TRYwq7uZYMSezOtwMMyrFnggDfecQw43SSyzEmaqch6Z6pyfdqJaFw6d1(ZIonGnXcYTPkkPy5gSCpl2HlfilUsbTZsk4ILhYstJMW7SOimMfWvFfkwqUnvrjflZ(9dZcSuPyz3TSOcZI973HRNfaxnwkwqOpf(P(85Xaa6DU8ekgqbZ7PWp1NNjVvPYGWp(J3IMAgh9yau56kcmoDXac99uFEmaGEFUUImfmVNc)uFEM8wLkdcFw0Ystj(vywqel2Mwmap8hSIbKaH14Ak(J3IM2gh9yau56kcmoDXac99uFEmaGEFUUImfmVNc)uFEM8wLkdcFw0Ystj(vywqelAg1Ib4H)Gvma8QgxtXF8w0msXrpgavUUIaJtxmap8hSIbmGDGYWrU8F1umaqch6Z6pyfdi9Welix4wybwSeazX(97W1ZsWTSUcvmGqFp1NhdWTYHDkGu8hVfnr44OhdGkxxrGXPlgGh(dwXaOelODQZ6WcmgaiHd9z9hSIbKEyIf0kXcANAwshSazX(97S4vkwuWcflubxO2zr54)kuSGwb1zHjw8cKLVtXYdzrDfXY9SSSyX(97SGqwkS3S4filiBROj9RqmGqFp1NhdyglbiubcTxMGNVkyAkXVcZccyrFngMGNVkyaxT)hSybbS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSenw00ww2KLaeQaH2ldLybTtDwhwGgWv7)blwqalAMglZzzAIf91yycE(QGPPe)kmlBYsKXY0elG96anfmhaXXF8w0udXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdWXF7QSf0o1SSjlrT0yrJzzgl2A0alrJf91yygRovgoYKAvKb)Eajw0ywSLLOXcfuNfMmxLvRYBwMhdaKWH(S(dwXaaqpMf77uXYwXiewW7WLcKfDIfWvIfbYYdzPGplqGuhClwMPrilQaXSalwqURoflWblOLAvelEbYYVtSGwb1zHP5Xaa6DU8ekgGJTYGReR4pElAIoIJEmaQCDfbgNUyaqRyay6Jb4H)GvmaGEFUUIIba0vlkgGnSa2Rd0uWCaeZIwwMXcqVpxxrMayoalW7pyXIwwSHf91yycE(QGzzXIwwMXInSGPpRdRf28h12gzzBTcSmnXcfuNfMmxLvRYBwMMyHcQZctgmu5DUie)SmNfTSmJLzSmJfGEFUUImo2kdUsSyzAILaeivE9M6qT)5HtSmnXYmwcqGu51BqkvFEXIwwcqOceAVmuIf0o1zDybAAYbtXYCwMMyPxfnGnkY8xczh2vgSjpr)kqQnu56kcKL5SOLfq4BWRACnzAkXVcZYMSezSOLfq4BsGWACnzAkXVcZYMSe1yrllZybe(g8tkL35HYBY0uIFfMLnzrZ0yzAIfBy5DfvVb)Ks5DEO8Mmu56kcKL5SOLfGEFUUIm)EFkvgtesuNT73ZIwwEVrrV5Vek)Wm4rSSjl6RXWe88vbd4Q9)GflrJL0mOtwMMyrFnggDfecQw43SSyrll6RXWORGqq1c)MMs8RWSGiw0xJHj45RcgWv7)blwqalZyrtBzjAS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSmNL5SmnXYmwOiFDwweOHsSs1KRYWgS8kqSOLLaeQaH2ldLyLQjxLHny5vGmnL4xHzbrSOj6aDYccyzglAGLOXsVkAaBuKbF1yPY7PWp1NBOY1veilZzzolZzrllZyXgwcqGu51BQd1(NhoXY0elZyjaHkqO9YeGfqisu(3Pm2667XMMs8RWSGiw0xJHj45RcgWv7)blwqdl2YIwwSHLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMMyjaHkqO9YeGfqisu(3Pm2667XMMCWuSOLfh)TRYwq7uZcIyrdPXYCwMMyrhIXSOLLXHA)ZnL4xHzbrSeGqfi0EzcWciejk)7ugBD99yttj(vywMZY0el6qmMfTSmou7FUPe)kmliIf91yycE(QGbC1(FWIfeWIM2Ys0yPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazzEmaqch6Z6pyfdi9WeliBROj9Ral2VFNfKblGqKi0e17kWMazbG113JzXlqwaH12plqGuBVVNybHSuyVzb2SyFNkwsNccbvl8ZID4sbYcHyRRjw0PbSjwq2wrt6xbwieBDnHnSOr5irSGxnXYdzHQNAwCwq(v5nlOvqDwyIf77uXYcFOkwIUTrgl2AfyXlqwCLIfKPrWSy)ukw0PamHyPjhmflyiSyHk4c1olGR(kuS87el6RXGfVazbe(yw2DGel6evSGxJXfoQEvkwAA0eENanXaa6DU8ekgqamhGf49hSY4p(J3IMOZ4OhdGkxxrGXPlgGh(dwXaAhivWfopAQIsQyaGeo0N1FWkgq6HjwqUnvrjfl2VFNfKTv0K(vGLvPimMfKBtvusXID4sbYIYXplkyHIAw(DVybzBfnPFfqpl)ovSSWel60a2umGqFp1NhdqFngMGNVkyAkXVcZYMSOPgyzAIf91yycE(QGbC1(FWIfeXITOtwqal9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilrJfnTLfTSa07Z1vKjaMdWc8(dwz8h)XBrZilo6XaOY1veyC6Ibe67P(8yaa9(CDfzcG5aSaV)Gvg)SOLLzSOVgdtWZxfmGR2)dwSSzeSyl6KfeWsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYs0yrtBzzAIfByjabsLxVbiv)EQML5SmnXI(AmmTdKk4cNhnvrjLzzXIww0xJHPDGubx48OPkkPmnL4xHzbrSe1ybbSeGf46EJvtHdtzxDOQeQEZFjugORweliGLzSydl6RXWORGqq1c)MLflAzXgwExr1BWV3kydAOY1veilZJb4H)GvmGaPi8FUk7QdvLq1h)XBrZOwC0JbqLRRiW40fdi03t95Xaa6956kYeaZbybE)bRm(Jb4H)GvmGRcEx(FWk(J3ITPfh9yau56kcmoDXaGwXaW0hdWd)bRyaa9(CDffdaORwumGaeQaH2ltWZxfmnL4xHzztw0mnwMMyXgwa6956kYeGfqisugKWPQalAzjabsLxVPou7FE4elttSa2Rd0uWCaehdaKWH(S(dwXaI66956kILfMazbwS46N6(JWS87(ZIDVEwEil6elyhibYYa2SGSTIM0VcSGHS87(ZYVtPyXBQEwS74NazjQJf(zrNgWMy53PKyaa9oxEcfda7aP8a25GNVke)XBXwnJJEmaQCDfbgNUyaE4pyfdyS6uz4itQvrXaajCOpR)GvmG0dtywqUq0ILBWYvS4flOvqDwyIfVaz57JWS8qwuxrSCplllwSF)oliKLc7n6zbzBfnPFfqplOvIf0o1SKoybYIxGSSvq36pGelaS7DsmGqFp1NhdGcQZctMRYELIfTSmJfh)TRYwq7uZcIyjQzllAml6RXWmwDQmCKj1Qid(9asSenw0alttSOVgdt7aPcUW5rtvuszwwSmNfTSmJf91yyS6lb2GNRYEh86czRLc7TbORweliIfBr40yzAIf91yycE(QGPPe)kmlBYsKXYCw0YcqVpxxrgSdKYdyNdE(QalAzzgl2WsacKkVEtrHgQGnilttSacFJd6w)bKYy7ENKb9ehfz(lG0vOyzolAzzgl2WsacKkVEdqQ(9unlttSOVgdt7aPcUW5rtvuszAkXVcZcIyjQXIgZYmwqywIgl9QObSrrg8vJLkVNc)uFUHkxxrGSmNfTSOVgdt7aPcUW5rtvuszwwSmnXInSOVgdt7aPcUW5rtvuszwwSmNfTSmJfByjabsLxVbPu95flttSeGqfi0EzOelODQZ6Wc00uIFfMLnzX20yzolAz59gf9M)sO8dZGhXYMSObwMMyrhIXSOLLXHA)ZnL4xHzbrSOzAXF8wS124OhdGkxxrGXPlgGh(dwXaWV3dxPIbas4qFw)bRyaPhMyrJUOFNfaV3dxPyXQHbml3GfaV3dxPy5W12pllRyaH(EQppgG(AmmWI(DC2I6az9hSmllw0YI(Amm437HRuMMgnH3DDff)XBX2ifh9yau56kcmoDXa8WFWkgqWRaPY6RXigqOVN6ZJbOVgdd(9wbBqttj(vywqelAGfTSmJf91yyOG6SWugdvEBAkXVcZYMSObwMMyrFnggkOolmLvRYBttj(vyw2KfnWYCw0YIJ)2vzlODQzztwIAPfdqFng5YtOya43BfSbJbas4qFw)bRyaiZRaPybW7Tc2GSCdwUNLDhZIIWyw(DVyrdywAkXV6kuONLuWflEtS4plrT0qalBfJqyXlqw(DILWQBQEwqRG6SWel7oMfnGamlnL4xDfQ4pEl2IWXrpgavUUIaJtxmap8hSIbe8kqQS(AmIbe67P(8yaVRO6nxf8U8)GLHkxxrGSOLfBy5DfvVPi75eiSmu56kcKfTSe1hlZyzglrkT0yrJzXXF7QSf0o1SGawq40yrJzbtFwhwlS5pQTnYY2AfyjASGWPXYCwqdlZybHzbnSGTiLkV74NyzolAmlbiubcTxMaSacrIY)oLXwxFp20uIFfML5SGiwI6JLzSmJLiLwASOXS44VDv2cANAw0yw0xJHXQVeydEUk7DWRlKTwkS3gGUArSGawq40yrJzbtFwhwlS5pQTnYY2AfyjASGWPXYCwqdlZybHzbnSGTiLkV74NyzolAmlbiubcTxMaSacrIY)oLXwxFp20uIFfML5SOLLaeQaH2ltWZxfmnL4xHzztwIuASOLf91yyS6lb2GNRYEh86czRLc7TbORweliIfB1mnw0YI(Ammw9LaBWZvzVdEDHS1sH92a0vlILnzjsPXIwwcqOceAVmbybeIeL)DkJTU(ESPPe)kmliIfeonw0YY4qT)5Ms8RWSSjlbiubcTxMaSacrIY)oLXwxFp20uIFfMfeWc6GfTSmJLEv0a2OitGue(pxLXwxFp2qLRRiqwMMybO3NRRitawaHirzqcNQcSmpgG(AmYLNqXaS6lb2GNRYEh86czRLc7Dmaqch6Z6pyfdazEfifl)oXcczPWEZI(Amy5gS87elwnmWID4sbwB)SOUIyzzXI973z53jwkcXpl)LqSGmybeIeXsaMqywGJblbqdlrF)WSSWlxPsXcSuPyz3TSOcZc4QVcfl)oXs6qEt8hVfB1qC0JbqLRRiW40fdaAfdatFmap8hSIba07Z1vumaGUArXacqGu51BQd1(NhoXIww6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqw0YI(Ammw9LaBWZvzVdEDHS1sH92a0vlIfeWIJ)2vzlODQzbbSejw2mcwIuAPXIwwa6956kYeGfqisugKWPQalAzjaHkqO9YeGfqisu(3Pm2667XMMs8RWSGiwC83UkBbTtnlOHLiLglrJfubqtIJyw0YInSa2Rd0uWCaeZIwwOG6SWK5QSxPyrllo(BxLTG2PMLnzbO3NRRitawaHirzhBXIwwcqOceAVmbpFvW0uIFfMLnzrdXaajCOpR)Gvmaa0JzX(ovSGqwkS3SG3Hlfil6elwnmeiqwiVvPy5HSOtS46kILhYYctSGmybeIeXcSyjaHkqO9ILzOfgt1FUsLIfDkatimlFViwUblGReRRqXYwXiewkODwSFkflUsbTZsk4ILhYIf1dk8QuSq1tnliKLc7nlEbYYVtfllmXcYGfqis08yaa9oxEcfdWQHHS1sH9otERsf)XBXw0rC0JbqLRRiW40fdWd)bRya437HRuXaajCOpR)GvmG0dtSa49E4kfl2VFNfapPuEZIgPVXZcSz5TnYybHTcS4filfKfaV3kydIEwSVtflfKfaV3dxPy5WSSSyb2S8qwSAyGfeYsH9Mf77uXIRdbsSe1sJLTIriZGnl)oXc5TkfliKLc7nlwnmWcqVpxxrSCyw(ErZzb2S4Gw(FajwW29oHLDhZsKHamfWS0uIF1vOyb2SCywUILH6qT)Xac99uFEmGzS8UIQ3GFsP8od234nu56kcKLPjwW0N1H1cB(JABJSmcBfyzolAzXgwExr1BWV3kydAOY1veilAzrFngg879WvkttJMW7UUIyrll2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilAzzgl6RXWy1xcSbpxL9o41fYwlf2BdqxTiw2mcwSvdPXIwwSHf91yycE(QGzzXIwwMXcqVpxxrghBLbxjwSmnXI(AmmiDfytGzkXcAN6eQ(mvuJ6IczwwSmnXcqVpxxrgRggYwlf27m5TkflZzzAILzSeGaPYR3uuOHkydYIwwExr1BWpPuENb7B8gQCDfbYIwwMXci8noOB9hqkJT7Dsg0tCuKPPe)kmlBYsKXY0elE4pyzCq36pGugB37KmON4OiZv5H6qT)SmNL5SmNfTSmJLaeQaH2ltWZxfmnL4xHzztw0mnwMMyjaHkqO9YeGfqisu(3Pm2667XMMs8RWSSjlAMglZJ)4Tyl6mo6XaOY1veyC6Ib4H)Gvma87nE1OOyaGeo0N1FWkgGgzLyHzzRyecl60a2elidwaHirSSWxHILFNybzWciejILaSaV)GflpKLWofqILBWcYGfqiselhMfp8lxPsXIRdxplpKfDILGJ)yaH(EQppgaqVpxxrgRggYwlf27m5Tkv8hVfBJS4OhdGkxxrGXPlgGh(dwXakYEobcRyaGeo0N1FWkgq6Hjw0OGWcZI9DQyjfCXI3elUoC9S8q04nXsWTSUcflHDVrryw8cKLehjIf8Qjw(DkflEtSCflEXcAfuNfMyb)NsXYa2SGqVgfAqUAuXac99uFEma3kh2PasSOLLzSe29gfHzjcwSLfTS0uy3Buu(VeIfeXIgyzAILWU3OimlrWsKyzE8hVfBJAXrpgavUUIaJtxmGqFp1NhdWTYHDkGelAzzglHDVrrywIGfBzrllnf29gfL)lHybrSObwMMyjS7nkcZseSejwMZIwwMXI(AmmuqDwykRwL3MMs8RWSSjleIPW6P8FjelttSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeIL5Xa8WFWkgWURg5eiSI)4TeP0IJEmaQCDfbgNUyaH(EQppgGBLd7uajw0YYmwc7EJIWSebl2YIwwAkS7nkk)xcXcIyrdSmnXsy3BueMLiyjsSmNfTSmJf91yyOG6SWuwTkVnnL4xHzztwietH1t5)siwMMyrFnggkOolmLXqL3MMs8RWSSjleIPW6P8FjelZJb4H)GvmGXsPYjqyf)XBjsAgh9yau56kcmoDXa8WFWkga(9gVAuumaqch6Z6pyfdi9WelaEVXRgfXIgDr)olwnmGzXlqwaxjwSSvmcHf77uXcY2kAs)kGEwqRelODQzjDWce9S87elrDP63t1SOVgdwomlUoC9S8qwgUsXcCmyb2SKcU2gKLGBXYwXiKyaH(EQppgafuNfMmxL9kflAzzgl6RXWal63X5GI8od8WhSmllwMMyrFnggKUcSjWmLybTtDcvFMkQrDrHmllwMMyrFngMGNVkywwSOLLzSydlbiqQ86niLQpVyzAILaeQaH2ldLybTtDwhwGMMs8RWSSjlAGLPjw0xJHj45RcMMs8RWSGiwqfanjoIzjASmuqyZYmwC83UkBbTtnlOHfGEFUUImyCoaXplZzzolAzzgl2WsacKkVEdqQ(9unlttSOVgdt7aPcUW5rtvuszAkXVcZcIybva0K4iMLOXsGoflZyzglo(BxLTG2PMfeWccNglrJL3vu9MXQtLHJmPwfzOY1veilZzbnSa07Z1vKbJZbi(zzoliGLiXs0y5DfvVPi75eiSmu56kcKfTSydl9QObSrrg8vJLkVNc)uFUHkxxrGSOLf91yyAhivWfopAQIskZYILPjw0xJHPDGubx48OPkkPY4RglvEpf(P(CZYILPjwMXI(AmmTdKk4cNhnvrjLPPe)kmliIfp8hSm437X1KHqmfwpL)lHyrllylsPY7o(jwqelPzqywMMyrFngM2bsfCHZJMQOKY0uIFfMfeXIh(dwg7T)7gcXuy9u(VeILPjwa6956kYCroyoalW7pyXIwwcqOceAVmxHd96DDfLJ8Lx)kjdsaVazAYbtXIwwOiFDwweO5kCOxVRROCKV86xjzqc4fiwMZIww0xJHPDGubx48OPkkPmllwMMyXgw0xJHPDGubx48OPkkPmllw0YInSeGqfi0EzAhivWfopAQIskttoykwMZY0ela9(CDfzCSvgCLyXY0el6qmMfTSmou7FUPe)kmliIfubqtIJywIglb6uSmJfh)TRYwq7uZcAybO3NRRidgNdq8ZYCwMh)XBjs2gh9yau56kcmoDXa8WFWkga(9gVAuumaqch6Z6pyfdi6DkwEiljosel)oXIoHFwGdwa8ERGnil6Pyb)EaPRqXY9SSSyjYxxajvkwUIfVsXcAfuNfMyrF9SGqwkS3SC4A7NfxhUEwEil6elwnmeiWyaH(EQppgW7kQEd(9wbBqdvUUIazrll2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilAzzgl6RXWGFVvWg0SSyzAIfh)TRYwq7uZYMSe1sJL5SOLf91yyWV3kydAWVhqIfeXsKyrllZyrFnggkOolmLXqL3MLflttSOVgddfuNfMYQv5TzzXYCw0YI(Ammw9LaBWZvzVdEDHS1sH92a0vlIfeXITOZ0yrllZyjaHkqO9Ye88vbttj(vyw2KfntJLPjwSHfGEFUUImbybeIeLbjCQkWIwwcqGu51BQd1(NhoXY84pElrksXrpgavUUIaJtxmaOvmam9Xa8WFWkgaqVpxxrXaa6QffdGcQZctMRYQv5nlrJLiJf0WIh(dwg8794AYqiMcRNY)LqSGawSHfkOolmzUkRwL3SenwMXc6GfeWY7kQEdgUuz4i)7uEaBc)gQCDfbYs0yjsSmNf0WIh(dwg7T)7gcXuy9u(VeIfeWsAgewdSGgwWwKsL3D8tSGawsZObwIglVRO6nL)RMWzDx5vGmu56kcmgaiHd9z9hSIbGw4)s8NWSSdTZsYkSZYwXiew8MybLFfbYIf1SGPaSanSOrxQuS8oseMfNfC5w4D4ZYa2S87elHv3u9SGVF5)blwWqwSdxkWA7NfDIfpewT)eldyZIYBuuZYFj0O9echdaO35YtOyao2cHqnake)XBjsiCC0JbqLRRiW40fdWd)bRya43B8QrrXaajCOpR)GvmanYkXIfaV34vJIy5kw8If0kOolmXIJzbdHfloMfligF6kIfhZIcwOyXXSKcUyX(PuSqfilllwSF)olrwAiGf77uXcvp1xHILFNyPie)SGwb1zHj0ZciS2(zrrpl3ZIvddSGqwkS3ONfqyT9Zcei1277jw8Ifn6I(DwSAyGfVazXccvSOtdytSGSTIM0VcS4filOvIf0o1SKoybgdi03t95XaSHLEv0a2OiZFjKDyxzWM8e9RaP2qLRRiqw0YYmw0xJHXQVeydEUk7DWRlKTwkS3gGUArSGiwSfDMglttSOVgdJvFjWg8Cv27GxxiBTuyVnaD1IybrSyRgsJfTS8UIQ3GFsP8od234nu56kcKL5SOLLzSqb1zHjZvzmu5nlAzXXF7QSf0o1SGawa6956kY4ylec1aOalrJf91yyOG6SWugdvEBAkXVcZccybe(MXQtLHJmPwfz(lGeo3uIFflrJfBnAGLnzjYsJLPjwOG6SWK5QSAvEZIwwC83UkBbTtnliGfGEFUUImo2cHqnakWs0yrFnggkOolmLvRYBttj(vywqalGW3mwDQmCKj1QiZFbKW5Ms8RyjASyRrdSSjlrT0yzolAzXgw0xJHbw0VJZwuhiR)GLzzXIwwSHL3vu9g87Tc2GgQCDfbYIwwMXsacvGq7Lj45RcMMs8RWSSjlOtwMMybdxk9Ran)EFkvgtesuBOY1veilAzrFngMFVpLkJjcjQn43diXcIyjsrIfnMLzS0RIgWgfzWxnwQ8Ek8t95gQCDfbYs0yXwwMZIwwghQ9p3uIFfMLnzrZ0sJfTSmou7FUPe)kmliIfBtlnwMMybSxhOPG5aiML5SOLLzSydlbiqQ86niLQpVyzAILaeQaH2ldLybTtDwhwGMMs8RWSSjl2YY84pElrsdXrpgavUUIaJtxmap8hSIbuK9CcewXaajCOpR)GvmG0dtSOrbHfMLRyXRuSGwb1zHjw8cKfSdKybHExnqaYDPuSOrbHfldyZcY2kAs)kWIxGSe17kWMazbTsSG2PoHQ3WYwvyillmXYw0OyXlqwqUAuS4pl)oXcvGSahSGCBQIskw8cKfqyT9ZIIEw0in5j6xbsnldxPybogXac99uFEma3kh2PasSOLfGEFUUImyhiLhWoh88vbw0YYmw0xJHHcQZctz1Q820uIFfMLnzHqmfwpL)lHyzAIf91yyOG6SWugdvEBAkXVcZYMSqiMcRNY)LqSmp(J3sKqhXrpgavUUIaJtxmGqFp1NhdWTYHDkGelAzbO3NRRid2bs5bSZbpFvGfTSmJf91yyOG6SWuwTkVnnL4xHzztwietH1t5)siwMMyrFnggkOolmLXqL3MMs8RWSSjleIPW6P8FjelZzrllZyrFngMGNVkywwSmnXI(Ammw9LaBWZvzVdEDHS1sH92a0vlIfefbl2QzASmNfTSmJfByjabsLxVbiv)EQMLPjw0xJHPDGubx48OPkkPmnL4xHzbrSmJfnWIgZITSenw6vrdyJIm4RglvEpf(P(CdvUUIazzolAzrFngM2bsfCHZJMQOKYSSyzAIfByrFngM2bsfCHZJMQOKYSSyzolAzzgl2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilttSqiMcRNY)LqSGiw0xJH5VeYoSRmytEI(vGuBAkXVcZY0el2WI(Amm)Lq2HDLbBYt0VcKAZYIL5Xa8WFWkgWURg5eiSI)4Tej0zC0JbqLRRiW40fdi03t95XaCRCyNciXIwwa6956kYGDGuEa7CWZxfyrllZyrFnggkOolmLvRYBttj(vyw2KfcXuy9u(VeILPjw0xJHHcQZctzmu5TPPe)kmlBYcHykSEk)xcXYCw0YYmw0xJHj45RcMLflttSOVgdJvFjWg8Cv27GxxiBTuyVnaD1IybrrWITAMglZzrllZyXgwcqGu51BqkvFEXY0el6RXWG0vGnbMPelODQtO6ZurnQlkKzzXYCw0YYmwSHLaeivE9gGu97PAwMMyrFngM2bsfCHZJMQOKY0uIFfMfeXIgyrll6RXW0oqQGlCE0ufLuMLflAzXgw6vrdyJIm4RglvEpf(P(CdvUUIazzAIfByrFngM2bsfCHZJMQOKYSSyzolAzzgl2WsVkAaBuK5VeYoSRmytEI(vGuBOY1veilttSqiMcRNY)LqSGiw0xJH5VeYoSRmytEI(vGuBAkXVcZY0el2WI(Amm)Lq2HDLbBYt0VcKAZYIL5Xa8WFWkgWyPu5eiSI)4TePilo6XaOY1veyC6Ibas4qFw)bRyaPhMybHcIwSalwcGXa8WFWkgGDV7d2z4itQvrXF8wIuulo6XaOY1veyC6Ib4H)Gvma8794AkgaiHd9z9hSIbKEyIfaV3JRjwEilwnmWcaOYBwqRG6SWe6zbzBfnPFfyz3XSOimML)siw(DVyXzbHQ9FNfcXuy9elkA8SaBwGLkfli)Q8Mf0kOolmXYHzzzzybH6(DwIUTrgl2AfyHQNAwCwaavEZcAfuNfMy5gSGqwkS3SG)tPyz3XSOimMLF3lwSvZ0yb)EajmlEbYcY2kAs)kWIxGSGmybeIeXYUdKyjb2el)UxSOj6eZcY0iS0uIF1vOmSKEyIfxhcKyXwnKgYHLDh)elGR(kuSGCBQIskw8cKfBT1wKdl7o(jwSF)oC9SGCBQIsQyaH(EQppgafuNfMmxLvRYBw0YInSOVgdt7aPcUW5rtvuszwwSmnXcfuNfMmyOY7Cri(zzAILzSqb1zHjJxPYfH4NLPjw0xJHj45RcMMs8RWSGiw8WFWYyV9F3qiMcRNY)LqSOLf91yycE(QGzzXYCw0YYmwSHfm9zDyTWM)O22ilBRvGLPjw6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqw0YI(Ammw9LaBWZvzVdEDHS1sH92a0vlIfeXITAMglAzjaHkqO9Ye88vbttj(vyw2KfnrNSOLLzSydlbiqQ86n1HA)ZdNyzAILaeQaH2ltawaHir5FNYyRRVhBAkXVcZYMSOj6KL5SOLLzSydlThiZ3qLILPjwcqOceAVm6uJPgPRqzAkXVcZYMSOj6KL5SmNLPjwOG6SWK5QSxPyrllZyrFngg7E3hSZWrMuRImllwMMybBrkvE3XpXcIyjndcRbw0YYmwSHLaeivE9gGu97PAwMMyXgw0xJHPDGubx48OPkkPmllwMZY0elbiqQ86naP63t1SOLfSfPu5Dh)eliIL0mimlZJ)4TGWPfh9yau56kcmoDXaajCOpR)GvmG0dtSGq1(VZc83P2(HjwSVFHDwomlxXcaOYBwqRG6SWe6zbzBfnPFfyb2S8qwSAyGfKFvEZcAfuNfMIb4H)Gvma7T)7XF8wqynJJEmaQCDfbgNUyaGeo0N1FWkgaY1vQFVxXa8WFWkgqVQSh(dwz1H)yaQd)5YtOyadxP(9Ef)XF8hdai14dwXBX20S120S1w0zma7ExxHchdaHARi02s6Vfe6Ikwyj67elxIfSFwgWMLTHwur92S0uKVUMazbdtiw81dt8NazjS7fkcB4nq(RiwSnQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kILifvSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbYFfXcchvSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbVbc1wrOTL0Fli0fvSWs03jwUely)SmGnlBdsdFP(TzPPiFDnbYcgMqS4RhM4pbYsy3lue2WBG8xrSGoIkwqgSas9tGSa4sqgl4u17iMfKdlpKfKF5SaEap8blwGwu7pSzzgAMZYmnr8CdVbYFfXc6iQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLz2I45gEdK)kIf0zuXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZ0eXZn8gi)velrwuXcYGfqQFcKfaxcYybNQEhXSGCy5HSG8lNfWd4HpyXc0IA)HnlZqZCwMzlINB4nq(RiwISOIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMPjINB4nq(RiwIArflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSOzArflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSOPMrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSOPTrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSOjchvSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbYFfXIMAiQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLz2I45gEdK)kIfn1quXcYGfqQFcKLT)(kKO3OPbT3MLhYY2FFfs0BEnnO92SmZwep3WBG8xrSOPgIkwqgSas9tGSS93xHe9gBnO92S8qw2(7RqIEZBRbT3MLzAI45gEdK)kIfnrhrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42SmZwep3WBG8xrSOj6iQybzWci1pbYY2FFfs0B00G2BZYdzz7VVcj6nVMg0EBwMPjINB4nq(Riw0eDevSGmybK6Nazz7VVcj6n2Aq7Tz5HSS93xHe9M3wdAVnlZSfXZn8g8giuBfH2ws)TGqxuXclrFNy5sSG9ZYa2SSTvtbyIU)BZstr(6AcKfmmHyXxpmXFcKLWUxOiSH3a5VIyjsrflidwaP(jqw2(7RqIEJMg0EBwEilB)9virV510G2BZYSiH45gEdK)kIfeoQybzWci1pbYY2FFfs0BS1G2BZYdzz7VVcj6nVTg0EBwMfjep3WBG8xrSGoJkwqgSas9tGSSDVkAaBuKbT3MLhYY29QObSrrg02qLRRiWTzXFwqlnAKNLzAI45gEdEdeQTIqBlP)wqOlQyHLOVtSCjwW(zzaBw22H02S0uKVUMazbdtiw81dt8NazjS7fkcB4nq(Riw0mQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIfBJkwqgSas9tGSSDVkAaBuKbT3MLhYY29QObSrrg02qLRRiWTzzMMiEUH3a5VIyX2OIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBw8Nf0sJg5zzMMiEUH3a5VIyjsrflidwaP(jqw2(DfvVbT3MLhYY2VRO6nOTHkxxrGBZYmnr8CdVbYFfXsKIkwqgSas9tGSSDVkAaBuKbT3MLhYY29QObSrrg02qLRRiWTzzwKq8CdVbYFfXc6iQybzWci1pbYcGlbzSGtvVJywqoihwEili)YzjbcUulmlqlQ9h2Smd5mNLzAI45gEdK)kIf0ruXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZSfXZn8gi)velOZOIfKblGu)eilaUeKXcov9oIzb5GCy5HSG8lNLei4sTWSaTO2FyZYmKZCwMPjINB4nq(RiwqNrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSezrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSe1IkwqgSas9tGSa4sqgl4u17iMfKdlpKfKF5SaEap8blwGwu7pSzzgAMZYmBr8CdVbYFfXIM2gvSGmybK6NazbWLGmwWPQ3rmlihwEili)Yzb8aE4dwSaTO2FyZYm0mNLzAI45gEdK)kIfnr4OIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMPjINB4nq(Riw0udrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42Smttep3WBG8xrSOj6iQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIfnJSOIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMPjINB4nq(RiwSnTOIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMzlINB4nq(RiwS12OIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5Smttep3WBG8xrSylchvSGmybK6NazbWLGmwWPQ3rmlihwEili)Yzb8aE4dwSaTO2FyZYm0mNLz2I45gEdK)kIfBr4OIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMPjINB4nq(RiwSfDevSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbYFfXITOZOIfKblGu)eilB3RIgWgfzq7Tz5HSSDVkAaBuKbTnu56kcCBwMPjINB4nq(RiwSnQfvSGmybK6NazbWLGmwWPQ3rmlihwEili)Yzb8aE4dwSaTO2FyZYm0mNLz2I45gEdK)kILiLwuXcYGfqQFcKfaxcYybNQEhXSGCy5HSG8lNfWd4HpyXc0IA)HnlZqZCwMPjINB4n4nqO2kcTTK(BbHUOIfwI(oXYLyb7NLbSzz7HRu)EV2MLMI811eilyycXIVEyI)eilHDVqrydVbYFfXITrflidwaP(jqwaCjiJfCQ6DeZcYHLhYcYVCwapGh(GflqlQ9h2SmdnZzzMMiEUH3G3aHARi02s6Vfe6Ikwyj67elxIfSFwgWMLTX)2S0uKVUMazbdtiw81dt8NazjS7fkcB4nq(RiwSnQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAaXZn8gi)velrkQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIfeoQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIf0ruXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnl(ZcAPrJ8Smttep3WBG8xrSOzArflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42SmZwep3WBG8xrSOjchvSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbYFfXIMOJOIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5Smttep3WBG8xrSOj6iQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAaXZn8gi)velAIoJkwqgSas9tGSSDVkAaBuKbT3MLhYY29QObSrrg02qLRRiWTzzMMiEUH3a5VIyrZilQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIfB1mQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kIfBr4OIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5SmdHr8CdVbYFfXITiCuXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZ0eXZn8gi)vel2QHOIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5Smttep3WBG8xrSyRgIkwqgSas9tGSSDVkAaBuKbT3MLhYY29QObSrrg02qLRRiWTzzMMiEUH3a5VIyXw0ruXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZ0eXZn8gi)velrsZOIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5SmlsiEUH3a5VIyjsAgvSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmnr8CdVbYFfXsKSnQybzWci1pbYY29QObSrrg0EBwEilB3RIgWgfzqBdvUUIa3MLzAI45gEdK)kILifPOIfKblGu)eilaUeKXcov9oIzb5WYdzb5xolGhWdFWIfOf1(dBwMHM5SmlsiEUH3a5VIyjsiCuXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZSfXZn8gi)velrcDevSGmybK6Nazz7Ev0a2OidAVnlpKLT7vrdyJImOTHkxxrGBZYmBr8CdVbYFfXsKqNrflidwaP(jqw2UxfnGnkYG2BZYdzz7Ev0a2OidABOY1ve42SmZwep3WBG8xrSePOwuXcYGfqQFcKLT7vrdyJImO92S8qw2UxfnGnkYG2gQCDfbUnlZ0eXZn8g8gPFIfSFcKf0blE4pyXI6Wp2WBedWQHJtrXaqx0LL05kVcelAKEDG8gOl6YIgL3HDw0e9SyBA2AlVbVb6IUSGSDVqr4OI3aDrxw0yw2kiibYcaOYBwsh5jgEd0fDzrJzbz7EHIaz59gf95BWsWXeMLhYsivqr53Bu0Jn8gOl6YIgZccnkbcKazzvffim27uSa07Z1veMLzNHmONfRMaMXV34vJIyrJ3KfRMaAWV34vJIMB4nqx0LfnMLTceEGSy1uWX)vOybHQ9FNLBWY9BJz53jwS3WcflOvqDwyYWBGUOllAmlAuoselidwaHirS87elaSU(EmlolQ7FfXscSjwgkcXNUIyz2nyjfCXYUdwB)SSFpl3Zc(swQ3lcUWQuSy)(DwsNg9wJoliGfKrkc)NRyzRQdvLq1JEwUFBqwWiDwZn8gOl6YIgZIgLJeXsce)SS94qT)5Ms8RWBZcoqL3heZIBzPsXYdzrhIXSmou7pMfyPsz4nqx0LfnMLO3K)SeDycXcCWs6u(olPt57SKoLVZIJzXzbBrHZvS89virVH3aDrxw0yw0OTOIAwMDgYGEwqOA)3rpliuT)7ONfaV3JRP5SK4GeljWMyPj8PoQEwEilK3QJAwcWeD)1y879B4nqx0LfnMfK7HywI6DfytGSGwjwq7uNq1ZsyNciXYa2SGmncllSJIm8g8gOl6YYwRc((tGSKox5vGyzRieKNLGxSOtSmGRcKf)zz)FlCuHg0O7kVcKgJVKGb197lDZbrt6CLxbsJbCjidnjGM9prf1)4uue6UYRazEe)8g8gE4pyHnwnfGj6(hbsxb2eygBD99yEd0LLOVtSa07Z1velhMfm9S8qwsJf73VZsbzb)(ZcSyzHjw((kKOhJEw0Kf77uXYVtSmUg)SalILdZcSyzHj0ZITSCdw(DIfmfGfilhMfVazjsSCdw0H)olEt8gE4pyHnwnfGj6(JGiqdqVpxxrOV8ekcyLxyk)9virp6b6QffrA8gE4pyHnwnfGj6(JGiqdqVpxxrOV8ekcyLxyk)9virp6Hwr4GGOhORwueAI(BeX3xHe9gnn7ooVWuwFngA)(kKO3OPjaHkqO9YaUA)pyP1MVVcj6nAAoS5HjugoYjWc)nCHZbyH)Ef(dwyEdp8hSWgRMcWeD)rqeObO3NRRi0xEcfbSYlmL)(kKOh9qRiCqq0d0vlkcBr)nI47RqIEJTMDhNxykRVgdTFFfs0BS1eGqfi0EzaxT)hS0AZ3xHe9gBnh28Wekdh5eyH)gUW5aSWFVc)blmVb6Ys03jmXY3xHe9yw8MyPGpl(6Hj(FbxPsXci9u4jqwCmlWILfMyb)(ZY3xHe9ydlSaGEwa6956kILhYccZIJz53PuS4kmKLIiqwWwu4Cfl7EbQUcLH3Wd)blSXQPamr3FeebAa6956kc9LNqraR8ct5VVcj6rp0kchee9aD1IIaHr)nIGI81zzrGMRWHE9UUIYr(YRFLKbjGxGMMOiFDwweOHsSs1KRYWgS8kqttuKVollc0GHlLI()ku5EPNI3aDzba9yw(DIfaV34vJIyjaXpldyZIYFQzj4QWs5)blmlZgWMfcXEILIyX(ovS8qwWV3plGReRRqXIonGnXcYTPkkPyz4kfMf4ymN3Wd)blSXQPamr3FeebAa6956kc9LNqrGX5ae)OhORwuerkTOnttnonJTrdtFwhwlS5pQTnYYiSvyoVb6Yca6XS4pl23VWolEcCvplWblBfJqybzWciejIf8oCPazrNyzHjWOIfeonwSF)oC9SGmsr4)CflaSU(EmlEbYsKsJf73VB4n8WFWcBSAkat09hbrGgGEFUUIqF5juebybeIeLDSf6b6QffrKsdbAMw06vrdyJImbsr4)CvgBD99yEdp8hSWgRMcWeD)rqeOjbclKUkpGDcVHh(dwyJvtbyIU)iic0yV9Fh9QROCamcntd93iIzuqDwyYOwL35Iq8pnrb1zHjZvzmu590efuNfMmxL1H)(0efuNfMmELkxeI)58g8gOlliKMco(zXwwqOA)3zXlqwCwa8EJxnkIfyXcGOZI973zzlhQ9NfKRtS4filPdU1OZcSzbW794AIf4VtT9dt8gE4pyHnqlQOgbrGg7T)7O)grmJcQZctg1Q8oxeI)PjkOolmzUkJHkVNMOG6SWK5QSo83NMOG6SWKXRu5Iq8pxRvtanAAS3(VR1gRMaAS1yV9FN3Wd)blSbArf1iic0GFVhxtOxDfLdGrOb0FJiSPxfnGnkYO7kVcugoYUsL)9RqHNMSjabsLxVPou7FE400KnylsPYV3OOhBWV3dxPIqZPjBExr1Bk)xnHZ6UYRazOY1ve400mkOolmzWqL35Iq8pnrb1zHjZvz1Q8EAIcQZctMRY6WFFAIcQZctgVsLlcX)CEdp8hSWgOfvuJGiqd(9ECnHE1vuoagHgq)nIyMn9QObSrrgDx5vGYWr2vQ8VFfk80KnbiqQ86n1HA)ZdNMMSbBrkv(9gf9yd(9E4kveAonzZ7kQEt5)QjCw3vEfidvUUIaNR1gm9zDyTWM)O22ilBRvyAAgfuNfMmyOY7Cri(NMOG6SWK5QSAvEpnrb1zHjZvzD4Vpnrb1zHjJxPYfH4FoVHh(dwyd0IkQrqeOb)EJxnkc9QROCamcnG(BeXSEv0a2OiJUR8kqz4i7kv(3VcfwBacKkVEtDO2)8WjTylsPYV3OOhBWV3dxPIqZ5ATbtFwhwlS5pQTnYY2Af4n4nqx0Lf0cXuy9eileqQtXYFjel)oXIhEyZYHzXb6NY1vKH3Wd)blCeyOY7So5j8gE4pyHrqeOj4kv2d)bRS6Wp6lpHIaArf1Oh)9f(i0e93iI)sienZ2O5H)GLXE7)Uj44p)xcHap8hSm437X1Kj44p)xcnN3aDzba9yw2keTybwSejeWI973HRNfW(gplEbYI973zbW7Tc2GS4fil2IawG)o12pmXB4H)GfgbrGgGEFUUIqF5jueho7qc9aD1IIaBrkv(9gf9yd(9E4k1MAQDMnVRO6n43BfSbnu56kcCA6DfvVb)Ks5DgSVXBOY1ve48PjSfPu53Bu0Jn437HRuBAlVb6Yca6XSeuKdKyX(ovSa49ECnXsWlw2VNfBralV3OOhZI99lSZYHzPjfb0RNLbSz53jwqRG6SWelpKfDIfRMgu3eilEbYI99lSZY4ukQz5HSeC8ZB4H)GfgbrGgGEFUUIqF5juehohuKdKqpqxTOiWwKsLFVrrp2GFVhxtBQjVb6YsuxVpxxrS87(ZsyNciHz5gSKcUyXBILRyXzbvaKLhYIdeEGS87el47x(FWIf77utS4S89virpl0hy5WSSWeilxXIo92jQyj44hZB4H)GfgbrGgGEFUUIqF5juexLrfarpqxTOiSAcygva0OPjbcRX100KvtaZOcGgnn4vnUMMMSAcygva0OPb)EJxnkAAYQjGzubqJMg879WvQPjRMaMrfanAAgRovgoYKAv00KvtanTdKk4cNhnvrj10K(AmmbpFvW0uIFfoc91yycE(QGbC1(FWAAcO3NRRiZHZoK4nqxwspmXs6OgtnsxHIf)z53jwOcKf4GfKBtvusXI9DQyz3XpXYHzX1HajwqhPHCqpl(4PMfKblGqKiw8cKf4VtT9dtSy)(Dwq2wrt6xbEdp8hSWiic0OtnMAKUcf6VreZMztacKkVEtDO2)8WPPjBcqOceAVmbybeIeL)DkJTU(ESzznn1RIgWgfzcKIW)5Qm2667XZ1QVgdtWZxfmnL4xH3utnOvFngM2bsfCHZJMQOKY0uIFfgriSwBcqGu51Bas1VNQNMcqGu51Bas1VNQ1QVgdtWZxfmllT6RXW0oqQGlCE0ufLuMLL2z6RXW0oqQGlCE0ufLuMMs8RWikcnTvJr4O1RIgWgfzWxnwQ8Ek8t95tt6RXWe88vbttj(vyePPMttAICWwKsL3D8tistd6y(CTa9(CDfzUkJkaYBGUSGqGpl2VFNfNfKTv0K(vGLF3FwoCT9ZIZcczPWEZIvddSaBwSVtfl)oXY4qT)SCywCD46z5HSqfiVHh(dwyeebASG)bl0FJiMPVgdtWZxfmnL4xH3utnODMn9QObSrrg8vJLkVNc)uF(0K(AmmTdKk4cNhnvrjLPPe)kmI0mQPvFngM2bsfCHZJMQOKYSSMpnPdXyTJd1(NBkXVcJiB1WCTa9(CDfzUkJkaYBGUSGmxfwk)jml23PFNAww4RqXcYGfqiself0ol2pLIfxPG2zjfCXYdzb)NsXsWXpl)oXc2tiw8e4QEwGdwqgSacrIqaY2kAs)kWsWXpM3Wd)blmcIana9(CDfH(YtOicWciejkds4uva9aD1IIiqNA2SXHA)ZnL4xH1yn1GghGqfi0EzcE(QGPPe)k8CKJMrwAZJiqNA2SXHA)ZnL4xH1yn1GghGqfi0EzcWciejk)7ugBD99yd4Q9)GLghGqfi0EzcWciejk)7ugBD99yttj(v45ihnJS0MR1M2pWmbKQ34GGydH4d)yTZSjaHkqO9Ye88vbttoyQPjBcqOceAVmbybeIezAYbtnFAkaHkqO9Ye88vbttj(v4nV6P2cQ8NaZJd1(NBkXVcpn1RIgWgfzcKIW)5Qm2667XAdqOceAVmbpFvW0uIFfEZiL20uacvGq7LjalGqKO8VtzS113JnnL4xH38QNAlOYFcmpou7FUPe)kSgRzAtt2eGaPYR3uhQ9ppCI3aDzj9WeilpKfqs5Py53jwwyhfXcCWcY2kAs)kWI9DQyzHVcflGWLUIybwSSWelEbYIvtaP6zzHDuel23PIfVyXbbzHas1ZYHzX1HRNLhYc4r8giGfp8hSWiic0a07Z1ve6lpHIiaMdWc8(dwOhORwueZEVrrV5Vek)Wm4rBQPgMMA)aZeqQEJdcInxTPgsBU2zZOiFDwweOHsSs1KRYWgS8kqANztacKkVEdqQ(9u90uacvGq7LHsSs1KRYWgS8kqMMs8RWist0b6ebZ0q06vrdyJIm4RglvEpf(P(85Z1AtacvGq7LHsSs1KRYWgS8kqMMCWuZNMOiFDwweObdxkf9)vOY9spL2z2eGaPYR3uhQ9ppCAAkaHkqO9YGHlLI()ku5EPNkhjewdrwAAAAkXVcJin1eHNpnnlaHkqO9YOtnMAKUcLPjhm10KnThiZ3qLAAkabsLxVPou7FE40CTZS5DfvVzS6uz4itQvrgQCDfbonfGaPYR3aKQFpvRnaHkqO9YmwDQmCKj1Qittj(vyePPMiqdrRxfnGnkYGVASu59u4N6ZNMSjabsLxVbiv)EQwBacvGq7LzS6uz4itQvrMMs8RWisFngMGNVkyaxT)hSqGM2gTEv0a2OiJvFjWg8Cv27GxxiBTuyV1ynTDU2zuKVollc0Cfo0R31vuoYxE9RKmib8cK2aeQaH2lZv4qVExxr5iF51VsYGeWlqMMs8RWisdZNMMnJI81zzrGg8UdcTtGzyRNHJ8d7eQETbiubcTxMh2ju9ey(k8HA)ZrsdAis2QPPPe)k88PPzZa6956kYaR8ct5VVcj6JqZPjGEFUUImWkVWu(7RqI(iI0CTZ((kKO3OPPjhmvoaHkqO9AA67RqIEJMMaeQaH2lttj(v4nV6P2cQ8NaZJd1(NBkXVcRXAM28PjGEFUUImWkVWu(7RqI(iSv7SVVcj6n2AAYbtLdqOceAVMM((kKO3yRjaHkqO9Y0uIFfEZREQTGk)jW84qT)5Ms8RWASMPnFAcO3NRRidSYlmL)(kKOpI0MpFoVb6YsuxVpxxrSSWeilpKfqs5PyXRuS89virpMfVazjaIzX(ovSy3V)kuSmGnlEXcATS2H95Sy1WaVHh(dwyeebAa6956kc9LNqr879PuzmrirD2UFp6b6QffHny4sPFfO537tPYyIqIAdvUUIaNMghQ9p3uIFfEtBtlTPjDigRDCO2)Ctj(vyezRgqWmeonnwFngMFVpLkJjcjQn43difnBNpnPVgdZV3NsLXeHe1g87bK2msrMgpRxfnGnkYGVASu59u4N6ZJMTZ5nqxwspmXcALyLQjxXIgDdwEfiwSnnmfWSOtdytS4SGSTIM0VcSSWelWMfmKLF3FwUNf7NsXI6kILLfl2VFNLFNyHkqwGdwqUnvrjfVHh(dwyeebAwykFpLG(YtOiOeRun5QmSblVce6VrebiubcTxMGNVkyAkXVcJiBttBacvGq7LjalGqKO8VtzS113JnnL4xHrKTPPDgqVpxxrMFVpLkJjcjQZ297NM0xJH537tPYyIqIAd(9asBgP0qWSEv0a2Oid(QXsL3tHFQppArA(CTa9(CDfzUkJkaonPdXyTJd1(NBkXVcJOiHo5nqxwspmXca4sPO)kuSGqBPNIf0bMcyw0PbSjwCwq2wrt6xbwwyIfyZcgYYV7pl3ZI9tPyrDfXYYIf73VZYVtSqfilWbli3MQOKI3Wd)blmcIanlmLVNsqF5juey4sPO)VcvUx6Pq)nIywacvGq7Lj45RcMMs8RWicDO1MaeivE9gGu97PAT2eGaPYR3uhQ9ppCAAkabsLxVPou7FE4K2aeQaH2ltawaHir5FNYyRRVhBAkXVcJi0H2za9(CDfzcWciejkds4uvyAkaHkqO9Ye88vbttj(vyeHoMpnfGaPYR3aKQFpvRDMn9QObSrrg8vJLkVNc)uFU2aeQaH2ltWZxfmnL4xHre6yAsFngM2bsfCHZJMQOKY0uIFfgrAMgcMPHOrr(6SSiqZv4VxHh24m4b8kkRtk1CT6RXW0oqQGlCE0ufLuML18PjDigRDCO2)Ctj(vyezRgMMOiFDwweOHsSs1KRYWgS8kqAdqOceAVmuIvQMCvg2GLxbY0uIFfEtBtBUwGEFUUImxLrfa1Adf5RZYIanxHd96DDfLJ8Lx)kjdsaVannfGqfi0EzUch6176kkh5lV(vsgKaEbY0uIFfEtBtBAshIXAhhQ9p3uIFfgr2MgVb6YYwv29uywwyIL0pQtncl2VFNfKTv0K(vGfyZI)S87elubYcCWcYTPkkP4n8WFWcJGiqdqVpxxrOV8ekIlYbZbybE)bl0d0vlkc91yycE(QGPPe)k8MAQbTZSPxfnGnkYGVASu59u4N6ZNM0xJHPDGubx48OPkkPmnL4xHrueAQbJgqWSiz0q00xJHrxbHGQf(nlR5iygcB0GghjJgIM(Amm6kieuTWVzznpAuKVollc0Cf(7v4HnodEaVIY6KsHae2OHOnJI81zzrGMFNYJRXFgFOoL2aeQaH2lZVt5X14pJpuNY0uIFfgrryBAZ1QVgdt7aPcUW5rtvuszwwZNMghQ9p3uIFfgr2QHPjkYxNLfbAOeRun5QmSblVcK2aeQaH2ldLyLQjxLHny5vGmnL4xH5n8WFWcJGiqZct57Pe0xEcfXv4qVExxr5iF51VsYGeWlqO)gra07Z1vK5ICWCawG3FWslqVpxxrMRYOcG8gOllPhMybWUdcTtGSOr36SOtdytSGSTIM0Vc8gE4pyHrqeOzHP89uc6lpHIaV7Gq7eyg26z4i)WoHQh93iIzbiubcTxMGNVkyAYbtP1MaeivE9M6qT)5HtAb6956kY879PuzmrirD2UFV2zbiubcTxgDQXuJ0vOmn5GPMMSP9az(gQuZNMcqGu51BQd1(NhoPnaHkqO9YeGfqisu(3Pm2667XMMCWuANb07Z1vKjalGqKOmiHtvHPPaeQaH2ltWZxfmn5GPMpxli8n4vnUMm)fq6kuANbcFd(jLY78q5nz(lG0vOMMS5DfvVb)Ks5DEO8Mmu56kcCAcBrkv(9gf9yd(9ECnTzKMRfe(MeiSgxtM)ciDfkTZa6956kYC4SdPPPEv0a2OiJUR8kqz4i7kv(3VcfEAYXF7QSf0o1BgrulTPjGEFUUImbybeIeLbjCQkmnPVgdJUccbvl8BwwZ1Adf5RZYIanxHd96DDfLJ8Lx)kjdsaVannrr(6SSiqZv4qVExxr5iF51VsYGeWlqAdqOceAVmxHd96DDfLJ8Lx)kjdsaVazAkXVcVzKstRn6RXWe88vbZYAAshIXAhhQ9p3uIFfgriCA8gOllrF)WSCywCwA)3PMfs56W2FIf7EkwEiljoselUsXcSyzHjwWV)S89virpMLhYIoXI6kcKLLfl2VFNfKTv0K(vGfVazbzWciejIfVazzHjw(DIfBlqwWk4ZcSyjaYYnyrh(7S89virpMfVjwGfllmXc(9NLVVcj6X8gE4pyHrqeOzHP89ucg9yf8Xr89virVMO)grmdO3NRRidSYlmL)(kKO3Mi0uRnFFfs0BS10KdMkhGqfi0EnnndO3NRRidSYlmL)(kKOpcnNMa6956kYaR8ct5VVcj6JisZ1otFngMGNVkywwANztacKkVEdqQ(9u90K(AmmTdKk4cNhnvrjLPPe)kmcMfjJgIwVkAaBuKbF1yPY7PWp1Nphrr89virVrtJ(AmYGR2)dwA1xJHPDGubx48OPkkPmlRPj91yyAhivWfopAQIsQm(QXsL3tHFQp3SSMpnfGqfi0EzcE(QGPPe)kmcSDZVVcj6nAAcqOceAVmGR2)dwATrFngMGNVkywwANztacKkVEtDO2)8WPPjBa6956kYeGfqisugKWPQWCT2eGaPYR3GuQ(8AAkabsLxVPou7FE4KwGEFUUImbybeIeLbjCQkOnaHkqO9YeGfqisu(3Pm2667XMLLwBcqOceAVmbpFvWSS0oBM(AmmuqDwykRwL3MMs8RWBQzAtt6RXWqb1zHPmgQ820uIFfEtntBUwB6vrdyJIm6UYRaLHJSRu5F)ku4PPz6RXWO7kVcugoYUsL)9RqHZL)RMm43difHgMM0xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqkIiB(8Pj91yyq6kWMaZuIf0o1ju9zQOg1ffYSSMpnPdXyTJd1(NBkXVcJiBtBAcO3NRRidSYlmL)(kKOpI0MRfO3NRRiZvzubqEdp8hSWiic0SWu(EkbJESc(4i((kKO3w0FJiMb07Z1vKbw5fMYFFfs0Bte2Q1MVVcj6nAAAYbtLdqOceAVMMa6956kYaR8ct5VVcj6JWwTZ0xJHj45RcMLL2z2eGaPYR3aKQFpvpnPVgdt7aPcUW5rtvuszAkXVcJGzrYOHO1RIgWgfzWxnwQ8Ek8t95ZrueFFfs0BS1OVgJm4Q9)GLw91yyAhivWfopAQIskZYAAsFngM2bsfCHZJMQOKkJVASu59u4N6ZnlR5ttbiubcTxMGNVkyAkXVcJaB387RqIEJTMaeQaH2ld4Q9)GLwB0xJHj45RcMLL2z2eGaPYR3uhQ9ppCAAYgGEFUUImbybeIeLbjCQkmxRnbiqQ86niLQpV0oZg91yycE(QGzznnztacKkVEdqQ(9u98PPaeivE9M6qT)5HtAb6956kYeGfqisugKWPQG2aeQaH2ltawaHir5FNYyRRVhBwwATjaHkqO9Ye88vbZYs7Sz6RXWqb1zHPSAvEBAkXVcVPMPnnPVgddfuNfMYyOYBttj(v4n1mT5ATPxfnGnkYO7kVcugoYUsL)9RqHNMMPVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGueAyAsFnggDx5vGYWr2vQ8VFfkC27GxKb)EaPiIS5ZNpnPVgddsxb2eyMsSG2PoHQptf1OUOqML10KoeJ1oou7FUPe)kmISnTPjGEFUUImWkVWu(7RqI(isBUwGEFUUImxLrfa5nqxwspmHzXvkwG)o1SalwwyIL7PemlWILaiVHh(dwyeebAwykFpLG5nqxwqR73PMfuqwU6HS87el4NfyZIdjw8WFWIf1HFEdp8hSWiic00Rk7H)GvwD4h9LNqr4qc94VVWhHMO)gra07Z1vK5Wzhs8gE4pyHrqeOPxv2d)bRS6Wp6lpHIa)8g8gOlliZvHLYFcZI9D63PMLFNyrJ0KNe8pStnl6RXGf7NsXYWvkwGJbl2VF)kw(DILIq8ZsWXpVHh(dwyJdPia6956kc9LNqra2KNKTFkvE4kvgogOhORwue9QObSrrM)si7WUYGn5j6xbsT2z6RXW8xczh2vgSjpr)kqQnnL4xHreQaOjXrmcsZO50K(Amm)Lq2HDLbBYt0VcKAttj(vye5H)GLb)EpUMmeIPW6P8FjecsZOP2zuqDwyYCvwTkVNMOG6SWKbdvENlcX)0efuNfMmELkxeI)5Z1QVgdZFjKDyxzWM8e9RaP2SS4nqxwqMRclL)eMf770VtnlaEVXRgfXYHzXoS)Dwco(VcflqGuZcG37X1elxXcYVkVzbTcQZct8gE4pyHnoKqqeObO3NRRi0xEcfXHQGnLXV34vJIqpqxTOiSHcQZctMRYyOYBTylsPYV3OOhBWV3JRPnrNA87kQEdgUuz4i)7uEaBc)gQCDfbgnBrafuNfMmxL1H)UwB6vrdyJImw9LaBWZvzVdEDHS1sH9wRn9QObSrrgyr)oohuK3zGh(GfVb6Ys6HjwqgSacrIyX(ovS4plkcJz539IfnKglBfJqyXlqwuxrSSSyX(97SGSTIM0Vc8gE4pyHnoKqqeOjalGqKO8VtzS113Jr)nIWgWEDGMcMdGyTZMb07Z1vKjalGqKOmiHtvbT2eGqfi0EzcE(QGPjhm10K(AmmbpFvWSSMRDM(AmmuqDwykRwL3MMs8RWBQHPj91yyOG6SWugdvEBAkXVcVPgMRDMJ)2vzlODQrKgst7mSfPu53Bu0Jn437X10MrAAsFngMGNVkywwZNMSPxfnGnkYy1xcSbpxL9o41fYwlf275ANzZ7kQEd(jLY7myFJFAsFngg879Wvkttj(vyePPrdACAgneTEv0a2OitGue(pxLXwxFpEAsFngMGNVkyAkXVcJi91yyWV3dxPmnL4xHrGg0QVgdtWZxfmlR5ANztVkAaBuKr3vEfOmCKDLk)7xHcpnPVgdJUR8kqz4i7kv(3Vcfox(VAYGFpG0MrAAsFnggDx5vGYWr2vQ8VFfkC27GxKb)EaPnJ08PjDigRDCO2)Ctj(vyePzAAdqOceAVmbpFvW0uIFfEtnmN3aDzj9Welaw14AILRyXYlqk5cSalw8k1VFfkw(D)zrDajmlAIWykGzXlqwuegZI973zjb2elV3OOhZIxGS4pl)oXcvGSahS4SaaQ8Mf0kOolmXI)SOjcZcMcywGnlkcJzPPe)QRqXIJz5HSuWNLDh4vOy5HS00Oj8olGR(kuSG8RYBwqRG6SWeVHh(dwyJdjeebAWRACnH(qQGIYV3OOhhHMO)grmRPrt4Dxxrtt6RXWqb1zHPmgQ820uIFfgrrslfuNfMmxLXqL3ABkXVcJinryTVRO6ny4sLHJ8Vt5bSj8BOY1ve4CTV3OO38xcLFyg8On1eH1ySfPu53Bu0Jrqtj(vyTZOG6SWK5QSxPMMAkXVcJiubqtIJ458gOllPhMybWQgxtS8qw2DGelolOuqDxXYdzzHjws)Oo1i8gE4pyHnoKqqeObVQX1e6Vrea9(CDfzUihmhGf49hS0gGqfi0EzUch6176kkh5lV(vsgKaEbY0KdMslf5RZYIanxHd96DDfLJ8Lx)kjdsaVaP1TYHDkGeVb6YsupISyzzXcG37HRuS4plUsXYFjeMLvPimMLf(kuSG8PcE7yw8cKL7z5WS46W1ZYdzXQHbwGnlk6z53jwWwu4CflE4pyXI6kIfDsbTZYUxGkIfnstEI(vGuZcSyXwwEVrrpM3Wd)blSXHecIan437HRuO)gryZ7kQEd(jLY7myFJ3qLRRiqTZSbtFwhwlS5pQTnYYiSvyAIcQZctMRYELAAcBrkv(9gf9yd(9E4k1MrAU2z6RXWGFVhUszAA0eE31vK2zylsPYV3OOhBWV3dxPquKMMSPxfnGnkY8xczh2vgSjpr)kqQNpn9UIQ3GHlvgoY)oLhWMWVHkxxrGA1xJHHcQZctzmu5TPPe)kmIIKwkOolmzUkJHkV1QVgdd(9E4kLPPe)kmIqNAXwKsLFVrrp2GFVhUsTzei8CTZSPxfnGnkYOsf82X5HIO)kuzuQlXcttt)LqihKdcRHn1xJHb)EpCLY0uIFfgb2ox77nk6n)Lq5hMbpAtnWBGUSGqD)olaEsP8MfnsFJNLfMybwSeazX(ovS00Oj8URRiw0xpl4)ukwS73ZYa2SG8PcE7ywSAyGfVazbewB)SSWel60a2elitJGnSa4pLILfMyrNgWMybzWciejIf8vbILF3FwSFkflwnmWIxWFNAwa8EpCLI3Wd)blSXHecIan437HRuO)gr8UIQ3GFsP8od234nu56kcuR(Amm437HRuMMgnH3DDfPDMny6Z6WAHn)rTTrwgHTcttuqDwyYCv2RuttylsPYV3OOhBWV3dxP2eHNRDMn9QObSrrgvQG3oopue9xHkJsDjwyAA6Vec5GCqynSjcpx77nk6n)Lq5hMbpAZiXBGUSGqD)olAKM8e9RaPMLfMybW79WvkwEilirKflllw(DIf91yWIEkwCfgYYcFfkwa8EpCLIfyXIgybtbybIzb2SOimMLMs8RUcfVHh(dwyJdjeebAWV3dxPq)nIOxfnGnkY8xczh2vgSjpr)kqQ1ITiLk)EJIESb)EpCLAZiIK2z2OVgdZFjKDyxzWM8e9RaP2SS0QVgdd(9E4kLPPrt4DxxrttZa6956kYa2KNKTFkvE4kvgogANPVgdd(9E4kLPPe)kmII00e2IuQ87nk6Xg879WvQnTv77kQEd(jLY7myFJ3qLRRiqT6RXWGFVhUszAkXVcJinmF(CEd0LfK5QWs5pHzX(o97uZIZcG3B8QrrSSWel2pLILGVWelaEVhUsXYdzz4kflWXa9S4fillmXcG3B8QrrS8qwqIilw0in5j6xbsnl43diXYYYWsKLglhMLFNyPPiFDnbYYwXiewEilbh)Sa49gVAueca8EpCLI3Wd)blSXHecIana9(CDfH(YtOiWV3dxPY2H1NhUsLHJb6b6QffHJ)2vzlODQ3mYslAZ0uJX0N1H1cB(JABJSSTwHOLMX25rBMMAS(Amm)Lq2HDLbBYt0VcKAd(9asrlnJMZ14z6RXWGFVhUszAkXVchTiHCWwKsL3D8trZM3vu9g8tkL3zW(gVHkxxrGZ14zbiubcTxg879Wvkttj(v4OfjKd2IuQ8UJFkAVRO6n4NukVZG9nEdvUUIaNRXZ0xJHzS6uz4itQvrMMs8RWrtdZ1otFngg879WvkZYAAkaHkqO9YGFVhUszAkXVcpN3aDzj9WelaEVXRgfXI973zrJ0KNOFfi1S8qwqIilwwwS87el6RXGf73Vdxplki(kuSa49E4kfllR)siw8cKLfMybW7nE1OiwGflimcyjDWTgDwWVhqcZYQ(tXccZY7nk6X8gE4pyHnoKqqeOb)EJxnkc93icGEFUUImGn5jz7NsLhUsLHJHwGEFUUIm437HRuz7W6ZdxPYWXqRna9(CDfzoufSPm(9gVAu000m91yy0DLxbkdhzxPY)(vOW5Y)vtg87bK2mstt6RXWO7kVcugoYUsL)9RqHZEh8Im43diTzKMRfBrkv(9gf9yd(9E4kfIqyTa9(CDfzWV3dxPY2H1NhUsLHJbVb6Ys6HjwW29oHfmKLF3FwsbxSGIEwsCeZYY6VeIf9uSSWxHIL7zXXSO8NyXXSybX4txrSalwuegZYV7flrIf87bKWSaBwI6yHFwSVtflrcbSGFpGeMfcXwxt8gE4pyHnoKqqeOXbDR)aszSDVtqFivqr53Bu0JJqt0FJiS5VasxHsRnE4pyzCq36pGugB37KmON4OiZv5H6qT)ttGW34GU1FaPm2U3jzqpXrrg87bKquK0ccFJd6w)bKYy7ENKb9ehfzAkXVcJOiXBGUSGqJgnH3zrJccRX1el3GfKTv0K(vGLdZstoyk0ZYVtnXI3elkcJz539IfnWY7nk6XSCfli)Q8Mf0kOolmXI973zba8rUONffHXS87EXIMPXc83P2(HjwUIfVsXcAfuNfMyb2SSSy5HSObwEVrrpMfDAaBIfNfKFvEZcAfuNfMmSOrG12plnnAcVZc4QVcflr9UcSjqwqRelODQtO6zzvkcJz5kwaavEZcAfuNfM4n8WFWcBCiHGiqtcewJRj0hsfuu(9gf94i0e93iIMgnH3DDfP99gf9M)sO8dZGhT5SzAIWiyg2IuQ87nk6Xg8794AkA2gn91yyOG6SWuwTkVnlR5Zrqtj(v45iNzAIG3vu9M3(v5eiSWgQCDfbox7m3kh2Pastta9(CDfzoufSPm(9gVAu00KnuqDwyYCv2RuZ1olaHkqO9Ye88vbttoykTuqDwyYCv2RuATbSxhOPG5aiw7mGEFUUImbybeIeLbjCQkmnfGqfi0EzcWciejk)7ugBD99yttoyQPjBcqGu51BQd1(NhonFAcBrkv(9gf9yd(9ECnHOzZqhA8m91yyOG6SWuwTkVnlROz785rBMMi4DfvV5TFvobclSHkxxrGZNR1gkOolmzWqL35Iq8R1MaeQaH2ltWZxfmn5GPMMMrb1zHjZvzmu590K(AmmuqDwykRwL3MLLwBExr1BWWLkdh5FNYdyt43qLRRiWPj91yyS6lb2GNRYEh86czRLc7TbORw0MryRgsBU2zylsPYV3OOhBWV3JRjePzArBMMi4DfvV5TFvobclSHkxxrGZNR1XF7QSf0o1BQH00y91yyWV3dxPmnL4xHJg6yU2z2eGaPYR3GuQ(8AAYg91yyq6kWMaZuIf0o1ju9zQOg1ffYSSMMOG6SWK5QmgQ8EUwB0xJHPDGubx48OPkkPY4RglvEpf(P(CZYI3aDzj9Welix4wybwSeazX(97W1ZsWTSUcfVHh(dwyJdjeebAgWoqz4ix(VAc93ic3kh2Pastta9(CDfzoufSPm(9gVAueVHh(dwyJdjeebAa6956kc9LNqreaZbybE)bRSdj0d0vlkcBa71bAkyoaI1odO3NRRitamhGf49hS0otFngg879WvkZYAA6DfvVb)Ks5DgSVXBOY1ve40uacKkVEtDO2)8WP5AbHVjbcRX1K5VasxHs7mB0xJHbdv4)cKzzP1g91yycE(QGzzPDMnVRO6nJvNkdhzsTkYqLRRiWPj91yycE(QGbC1(FWAZaeQaH2lZy1PYWrMuRImnL4xHrqKnx7mBW0N1H1cB(JABJSSTwHPjkOolmzUkRwL3ttuqDwyYGHkVZfH4FUwGEFUUIm)EFkvgtesuNT73RDMnbiqQ86n1HA)ZdNMMcqOceAVmbybeIeL)DkJTU(ESPPe)kmI0xJHj45RcgWv7)bROLMrdZ1(EJIEZFju(HzWJ2uFngMGNVkyaxT)hSIwAg058PjDigRDCO2)Ctj(vyePVgdtWZxfmGR2)dwiqtBJwVkAaBuKXQVeydEUk7DWRlKTwkS3Z5nqxwspmXcYTPkkPyX(97SGSTIM0Vc8gE4pyHnoKqqeOPDGubx48OPkkPq)nIqFngMGNVkyAkXVcVPMAyAsFngMGNVkyaxT)hSqGM2gTEv0a2OiJvFjWg8Cv27GxxiBTuyVrKTOdTa9(CDfzcG5aSaV)Gv2HeVb6Ys6Hjwq2wrt6xbwGflbqwwLIWyw8cKf1vel3ZYYIf73VZcYGfqiseVHh(dwyJdjeebAcKIW)5QSRouvcvp6Vrea9(CDfzcG5aSaV)Gv2HK2z6RXWe88vbd4Q9)Gfc002O1RIgWgfzS6lb2GNRYEh86czRLc79Mryl6yAYMaeivE9gGu97P65tt6RXW0oqQGlCE0ufLuMLLw91yyAhivWfopAQIskttj(vyef1qqawGR7nwnfomLD1HQsO6n)LqzGUAriyMn6RXWORGqq1c)MLLwBExr1BWV3kydAOY1ve4CEdp8hSWghsiic0CvW7Y)dwO)gra07Z1vKjaMdWc8(dwzhs8gOllPhMybTsSG2PML0blqwGflbqwSF)olaEVhUsXYYIfVazb7ajwgWMfeYsH9MfVazbzBfnPFf4n8WFWcBCiHGiqdLybTtDwhwGO)grmlaHkqO9Ye88vbttj(vyeOVgdtWZxfmGR2)dwiOxfnGnkYy1xcSbpxL9o41fYwlf27OPPTBgGqfi0EzOelODQZ6Wc0aUA)pyHantB(0K(AmmbpFvW0uIFfEZiBAcSxhOPG5aiM3aDzbHgnAcVZYq5nXcSyzzXYdzjsS8EJIEml2VFhUEwq2wrt6xbw0PRqXIRdxplpKfcXwxtS4filf8zbcK6GBzDfkEdp8hSWghsiic0GFsP8opuEtOpKkOO87nk6XrOj6VrennAcV76ks7Fju(HzWJ2utnOfBrkv(9gf9yd(9ECnHiewRBLd7uajTZ0xJHj45RcMMs8RWBQzAtt2OVgdtWZxfmlR58gOllPhMyb5crlwUblxHpqIfVybTcQZctS4filQRiwUNLLfl2VFNfNfeYsH9MfRggyXlqw2kOB9hqIfa29oH3Wd)blSXHecIanJvNkdhzsTkc93ickOolmzUk7vkTZCRCyNcinnztVkAaBuKXQVeydEUk7DWRlKTwkS3Z1otFnggR(sGn45QS3bVUq2APWEBa6QfHiB1qAtt6RXWe88vbttj(v4nJS5ANbcFJd6w)bKYy7ENKb9ehfz(lG0vOMMSjabsLxVPOqdvWgCAcBrkv(9gf94nTDU2z6RXW0oqQGlCE0ufLuMMs8RWikQPXZq4O1RIgWgfzWxnwQ8Ek8t95Z1QVgdt7aPcUW5rtvuszwwtt2OVgdt7aPcUW5rtvuszwwZ1oZMaeQaH2ltWZxfmlRPj91yy(9(uQmMiKO2GFpGeI0udAhhQ9p3uIFfgr2MwAAhhQ9p3uIFfEtntlTPjBWWLs)kqZV3NsLXeHe1gQCDfbox7mmCP0Vc0879PuzmrirTHkxxrGttbiubcTxMGNVkyAkXVcVzKsBU23Bu0B(lHYpmdE0MAyAshIXAhhQ9p3uIFfgrAMgVb6Ys6HjwCwa8EpCLIfn6I(DwSAyGLvPimMfaV3dxPy5WS4QMCWuSSSyb2SKcUyXBIfxhUEwEilqGuhClw2kgHWB4H)Gf24qcbrGg879Wvk0FJi0xJHbw0VJZwuhiR)GLzzPDM(Amm437HRuMMgnH3DDfnn54VDv2cAN6nJAPnN3aDzrJSsSyzRyecl60a2elidwaHirSy)(Dwa8EpCLIfVaz53PIfaV34vJI4n8WFWcBCiHGiqd(9E4kf6VrebiqQ86n1HA)ZdN0AZ7kQEd(jLY7myFJ3qLRRiqTZa6956kYeGfqisugKWPQW0uacvGq7Lj45RcML10K(AmmbpFvWSSMRnaHkqO9YeGfqisu(3Pm2667XMMs8RWicva0K4ioAb6uZC83UkBbTtnYrdPnxR(Amm437HRuMMs8RWicH1AdyVoqtbZbqmVHh(dwyJdjeebAWV34vJIq)nIiabsLxVPou7FE4K2za9(CDfzcWciejkds4uvyAkaHkqO9Ye88vbZYAAsFngMGNVkywwZ1gGqfi0EzcWciejk)7ugBD99yttj(vyePbTa9(CDfzWV3dxPY2H1NhUsLHJHwkOolmzUk7vkT2a07Z1vK5qvWMY43B8QrrATbSxhOPG5aiM3aDzj9WelaEVXRgfXI973zXlw0Ol63zXQHbwGnl3GLuW12GSabsDWTyzRyecl2VFNLuWvZsri(zj443WYwvyilGRelw2kgHWI)S87elubYcCWYVtSe1LQFpvZI(Amy5gSa49E4kfl2HlfyT9ZYWvkwGJblWMLuWflEtSalwSLL3Bu0J5n8WFWcBCiHGiqd(9gVAue6Vre6RXWal63X5GI8od8WhSmlRPPz2GFVhxtg3kh2PasATbO3NRRiZHQGnLXV34vJIMMMPVgdtWZxfmnL4xHrKg0QVgdtWZxfmlRPPzZ0xJHj45RcMMs8RWicva0K4ioAb6uZC83UkBbTtnYbO3NRRidgNdq8pxR(AmmbpFvWSSMM0xJHPDGubx48OPkkPY4RglvEpf(P(Cttj(vyeHkaAsCehTaDQzo(BxLTG2Pg5a07Z1vKbJZbi(NRvFngM2bsfCHZJMQOKkJVASu59u4N6ZnlR5AdqGu51Bas1VNQNpx7mSfPu53Bu0Jn437HRuikstta9(CDfzWV3dxPY2H1NhUsLHJX85ATbO3NRRiZHQGnLXV34vJI0oZMEv0a2OiZFjKDyxzWM8e9RaPEAcBrkv(9gf9yd(9E4kfII0CEd0LL0dtSOrbHfMLRybau5nlOvqDwyIfVazb7ajwqUlLIfnkiSyzaBwq2wrt6xbEdp8hSWghsiic0uK9CcewO)grmtFnggkOolmLXqL3MMs8RWBsiMcRNY)LqttZc7EJIWryR2Mc7EJIY)LqisdZNMc7EJIWreP5ADRCyNciXB4H)Gf24qcbrGMDxnYjqyH(BeXm91yyOG6SWugdvEBAkXVcVjHykSEk)xcnnnlS7nkchHTABkS7nkk)xcHinmFAkS7nkchrKMR1TYHDkGK2z6RXW0oqQGlCE0ufLuMMs8RWisdA1xJHPDGubx48OPkkPmllT20RIgWgfzWxnwQ8Ek8t95tt2OVgdt7aPcUW5rtvuszwwZ5n8WFWcBCiHGiqZyPu5eiSq)nIyM(AmmuqDwykJHkVnnL4xH3KqmfwpL)lH0olaHkqO9Ye88vbttj(v4n1qAttbiubcTxMaSacrIY)oLXwxFp20uIFfEtnK28PPzHDVrr4iSvBtHDVrr5)siePH5ttHDVrr4iI0CTUvoStbK0otFngM2bsfCHZJMQOKY0uIFfgrAqR(AmmTdKk4cNhnvrjLzzP1MEv0a2Oid(QXsL3tHFQpFAYg91yyAhivWfopAQIskZYAoVb6Ys6HjwqOGOflWIfKPr4n8WFWcBCiHGiqJDV7d2z4itQvr8gOlliZvHLYFcZI9D63PMLhYYctSa49ECnXYvSaaQ8Mf77xyNLdZI)SObwEVrrpgbAYYa2SqaPofl2MgYHLeh)uNIfyZccZcG3B8QrrSGwjwq7uNq1Zc(9asyEdp8hSWghsiic0a07Z1ve6lpHIa)EpUMYxLXqL3OhORwueylsPYV3OOhBWV3JRPnryemuqyplXXp1PYaD1IIMMPLgYX20MJGHcc7z6RXWGFVXRgfLPelODQtO6ZyOYBd(9asiheEoVb6YcYCvyP8NWSyFN(DQz5HSGq1(VZc4QVcfli3MQOKI3Wd)blSXHecIana9(CDfH(YtOiS3(VNVkpAQIsk0d0vlkcnroylsPY7o(jezRgplnJTrBg2IuQ87nk6Xg8794AsJ1CE0MPjcExr1BWWLkdh5FNYdyt43qLRRiWOPPrdZNJG0mAQHOPVgdt7aPcUW5rtvuszAkXVcZBGUSKEyIfeQ2)DwUIfaqL3SGwb1zHjwGnl3GLcYcG37X1el2pLILX9SC1dzbzBfnPFfyXRujWM4n8WFWcBCiHGiqJ92)D0FJiMrb1zHjJAvENlcX)0efuNfMmELkxeIFTa9(CDfzoCoOihinx7S3Bu0B(lHYpmdE0Mi80efuNfMmQv5D(QSTtt6qmw74qT)5Ms8RWisZ0MpnPVgddfuNfMYyOYBttj(vye5H)GLb)EpUMmeIPW6P8FjKw91yyOG6SWugdvEBwwttuqDwyYCvgdvER1gGEFUUIm437X1u(QmgQ8EAsFngMGNVkyAkXVcJip8hSm437X1KHqmfwpL)lH0AdqVpxxrMdNdkYbsA1xJHj45RcMMs8RWiIqmfwpL)lH0QVgdtWZxfmlRPj91yyAhivWfopAQIskZYslqVpxxrg7T)75RYJMQOKAAYgGEFUUImhohuKdK0QVgdtWZxfmnL4xH3KqmfwpL)lH4nqxwspmXcG37X1el3GLRyb5xL3SGwb1zHj0ZYvSaaQ8Mf0kOolmXcSybHralV3OOhZcSz5HSy1WalaGkVzbTcQZct8gE4pyHnoKqqeOb)EpUM4nqxwqUUs979I3Wd)blSXHecIan9QYE4pyLvh(rF5juedxP(9EXBWBGUSa49gVAueldyZsceiLq1ZYQuegZYcFfkwshCRrN3Wd)blSz4k1V3RiWV34vJIq)nIWMEv0a2OiJUR8kqz4i7kv(3Vcf2qr(6SSiqEd0LfK54NLFNybe(Sy)(Dw(DILei(z5VeILhYIdcYYQ(tXYVtSK4iMfWv7)blwoml73BybWQgxtS0uIFfMLKL6pl1rGS8qws8pSZscewJRjwaxT)hS4n8WFWcBgUs979cbrGg8QgxtOpKkOO87nk6XrOj6VreGW3KaH14AY0uIFfEZMs8RWrZwBroAgz8gE4pyHndxP(9EHGiqtcewJRjEdEd0LL0dtSSvq36pGelaS7Dcl23PILFNAILdZsbzXd)bKybB37e0ZIJzr5pXIJzXcIXNUIybwSGT7Dcl2VFNfBzb2Smi7uZc(9asywGnlWIfNLiHawW29oHfmKLF3Fw(DILISZc2U3jS4DFajmlrDSWpl(4PMLF3FwW29oHfcXwxtyEdp8hSWg8hHd6w)bKYy7ENG(qQGIYV3OOhhHMO)grydi8noOB9hqkJT7Dsg0tCuK5VasxHsRnE4pyzCq36pGugB37KmON4OiZv5H6qT)ANzdi8noOB9hqkJT7DsENCL5VasxHAAce(gh0T(diLX29ojVtUY0uIFfEtnmFAce(gh0T(diLX29ojd6jokYGFpGeIIKwq4BCq36pGugB37KmON4Oittj(vyefjTGW34GU1FaPm2U3jzqpXrrM)ciDfkEd0LL0dtywqgSacrIy5gSGSTIM0VcSCywwwSaBwsbxS4nXciHtvHRqXcY2kAs)kWI973zbzWciejIfVazjfCXI3el6KcANfeon0eP0MHmsr4)CflaSU(E8Cw2kgHWYvS4SOzAiGfmfybTcQZctgw2QcdzbewB)SOONfnstEI(vGuZcHyRRj0ZIRS7PWSSWelxXcY2kAs)kWI973zbHSuyVzXlqw8NLFNyb)E)SahS4SKo4wJol2VceA3WB4H)Gf2GFeebAcWciejk)7ugBD99y0FJiSbSxhOPG5aiw7Sza9(CDfzcWciejkds4uvqRnbiubcTxMGNVkyAYbtP1MEv0a2OiJvFjWg8Cv27GxxiBTuyVNM0xJHj45RcML1CTZM54VDv2cANAefbqVpxxrMaSacrIYo2s7m91yyOG6SWuwTkVnnL4xH3uZ0MM0xJHHcQZctzmu5TPPe)k8MAM28Pj91yycE(QGPPe)k8MAqR(AmmbpFvW0uIFfgrrOPTZ1oZMEv0a2OiZFjKDyxzWM8e9RaPEAYMEv0a2OitGue(pxLXwxFpEAsFngM)si7WUYGn5j6xbsTPPe)k8MeIPW6P8Fj08PPEv0a2OiJUR8kqz4i7kv(3VcfEU2z20RIgWgfz0DLxbkdhzxPY)(vOWttZ0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqkIiBAsFnggDx5vGYWr2vQ8VFfkC27GxKb)EaPiIS5ZNM0HyS2XHA)ZnL4xHrKMPP1MaeQaH2ltWZxfmn5GPMZBGUSKEyIfaV34vJIy5HSGerwSSSy53jw0in5j6xbsnl6RXGLBWY9SyhUuGSqi26AIfDAaBILXvhE)kuS87elfH4NLGJFwGnlpKfWvIfl60a2elidwaHir8gE4pyHn4hbrGg87nE1Oi0FJi6vrdyJIm)Lq2HDLbBYt0VcKATZSz2m91yy(lHSd7kd2KNOFfi1MMs8RWB6H)GLXE7)UHqmfwpL)lHqqAgn1oJcQZctMRY6WFFAIcQZctMRYyOY7PjkOolmzuRY7Cri(NpnPVgdZFjKDyxzWM8e9RaP20uIFfEtp8hSm437X1KHqmfwpL)lHqqAgn1oJcQZctMRYQv590efuNfMmyOY7Cri(NMOG6SWKXRu5Iq8pF(0Kn6RXW8xczh2vgSjpr)kqQnlR5ttZ0xJHj45RcML10eqVpxxrMaSacrIYGeovfMRnaHkqO9YeGfqisu(3Pm2667XMMCWuAdqGu51BQd1(NhoPDM(AmmuqDwykRwL3MMs8RWBQzAtt6RXWqb1zHPmgQ820uIFfEtntB(CTZSjabsLxVbPu9510uacvGq7LHsSG2PoRdlqttj(v4nJS58gOllAKvIflaEVXRgfHzX(97SKox5vGyboyzRkflrF)kuywGnlpKfRMS8MyzaBwqgSacrIyX(97SKo4wJoVHh(dwyd(rqeOb)EJxnkc93iIEv0a2OiJUR8kqz4i7kv(3Vcfw7Sz6RXWO7kVcugoYUsL)9RqHZL)RMm43diTPTtt6RXWO7kVcugoYUsL)9RqHZEh8Im43diTPTZ1gGqfi0EzcE(QGPPe)k8MOtT2eGqfi0EzcWciejk)7ugBD99yZYAAAwacKkVEtDO2)8WjTbiubcTxMaSacrIY)oLXwxFp20uIFfgrAMMwkOolmzUk7vkTo(BxLTG2PEtBtdbrkTOfGqfi0EzcE(QGPjhm1858gOllidwG3FWILbSzXvkwaHpMLF3FwsCKiml4vtS87ukw8MQTFwAA0eENazX(ovSGqZbsfCHzb52ufLuSS7ywuegZYV7flAGfmfWS0uIF1vOyb2S87elOvIf0o1SKoybYI(Amy5WS46W1ZYdzz4kflWXGfyZIxPybTcQZctSCywCD46z5HSqi26AI3Wd)blSb)iic0a07Z1ve6lpHIae(5MI811ucvpg9aD1IIyM(AmmTdKk4cNhnvrjLPPe)k8MAyAYg91yyAhivWfopAQIskZYAUwB0xJHPDGubx48OPkkPY4RglvEpf(P(CZYs7m91yyq6kWMaZuIf0o1ju9zQOg1ffY0uIFfgrOcGMehXZ1otFnggkOolmLXqL3MMs8RWBIkaAsCepnPVgddfuNfMYQv5TPPe)k8MOcGMehXttZSrFnggkOolmLvRYBZYAAYg91yyOG6SWugdvEBwwZ1AZ7kQEdgQW)fidvUUIaNZBGUSGmybE)blw(D)zjStbKWSCdwsbxS4nXcC94dKyHcQZctS8qwGLkflGWNLFNAIfyZYHQGnXYVFywSF)olaGk8FbI3Wd)blSb)iic0a07Z1ve6lpHIae(z46XhiLPG6SWe6b6QffXmB0xJHHcQZctzmu5TzzP1g91yyOG6SWuwTkVnlR5AT5DfvVbdv4)cKHkxxrGATPxfnGnkY8xczh2vgSjpr)kqQ5nqxw0iWNfxPy59gf9ywSF)(vSGq8cKsUal2VFhUEwGaPo4wwxHcb)oXIRdbsSeGf49hSW8gE4pyHn4hbrGMeiSgxtOpKkOO87nk6XrOj6VreZ0xJHHcQZctzmu5TPPe)k8MnL4xHNM0xJHHcQZctz1Q820uIFfEZMs8RWtta9(CDfzaHFgUE8bszkOolmnxBtJMW7UUI0(EJIEZFju(HzWJ2utB16w5WofqslqVpxxrgq4NBkYxxtju9yEdp8hSWg8JGiqdEvJRj0hsfuu(9gf94i0e93iIz6RXWqb1zHPmgQ820uIFfEZMs8RWtt6RXWqb1zHPSAvEBAkXVcVztj(v4PjGEFUUImGWpdxp(aPmfuNfMMRTPrt4DxxrAFVrrV5Vek)Wm4rBQPTADRCyNciPfO3NRRidi8Znf5RRPeQEmVHh(dwyd(rqeOb)Ks5DEO8MqFivqr53Bu0JJqt0FJiMPVgddfuNfMYyOYBttj(v4nBkXVcpnPVgddfuNfMYQv5TPPe)k8MnL4xHNMa6956kYac)mC94dKYuqDwyAU2MgnH3DDfP99gf9M)sO8dZGhTPMOdTUvoStbK0c07Z1vKbe(5MI811ucvpM3aDzrJaFw6d1(ZIonGnXcYTPkkPy5gSCpl2HlfilUsbTZsk4ILhYstJMW7SOimMfWvFfkwqUnvrjflZ(9dZcSuPyz3TSOcZI973HRNfaxnwkwqOpf(P(858gE4pyHn4hbrGgGEFUUIqF5juefmVNc)uFEM8wLkdcF0d0vlkIaeivE9gGu97PAT20RIgWgfzWxnwQ8Ek8t95ATPxfnGnkYeUoOOmCKv3GYEbMbj)31gGqfi0Ez0PgtnsxHY0KdMsBacvGq7LPDGubx48OPkkPmn5GP0AJ(AmmbpFvWSS0oZXF7QSf0o1BgzOZPj91yy0vqiOAHFZYAoVHh(dwyd(rqeOjbcRX1e6Vrea9(CDfzkyEpf(P(8m5Tkvge(ABkXVcJiBtJ3Wd)blSb)iic0Gx14Ac93icGEFUUImfmVNc)uFEM8wLkdcFTnL4xHrKMrnEd0LL0dtSGCHBHfyXsaKf73Vdxplb3Y6ku8gE4pyHn4hbrGMbSdugoYL)RMq)nIWTYHDkGeVb6Ys6HjwqRelODQzjDWcKf73VZIxPyrbluSqfCHANfLJ)RqXcAfuNfMyXlqw(oflpKf1vel3ZYYIf73VZcczPWEZIxGSGSTIM0Vc8gE4pyHn4hbrGgkXcAN6SoSar)nIywacvGq7Lj45RcMMs8RWiqFngMGNVkyaxT)hSqqVkAaBuKXQVeydEUk7DWRlKTwkS3rttB3maHkqO9Yqjwq7uN1HfObC1(FWcbAM28Pj91yycE(QGPPe)k8Mr20eyVoqtbZbqmVb6Yca6XSyFNkw2kgHWcEhUuGSOtSaUsSiqwEilf8zbcK6GBXYmnczrfiMfyXcYD1PyboybTuRIyXlqw(DIf0kOolmnN3Wd)blSb)iic0a07Z1ve6lpHIWXwzWvIf6b6QffHJ)2vzlODQ3mQLMgpZwJgIM(AmmJvNkdhzsTkYGFpGKgBB0OG6SWK5QSAvEpN3aDzj9WeliBROj9Ral2VFNfKblGqKi0e17kWMazbG113JzXlqwaH12plqGuBVVNybHSuyVzb2SyFNkwsNccbvl8ZID4sbYcHyRRjw0PbSjwq2wrt6xbwieBDnHnSOr5irSGxnXYdzHQNAwCwq(v5nlOvqDwyIf77uXYcFOkwIUTrgl2AfyXlqwCLIfKPrWSy)ukw0PamHyPjhmflyiSyHk4c1olGR(kuS87el6RXGfVazbe(yw2DGel6evSGxJXfoQEvkwAA0eENan8gE4pyHn4hbrGgGEFUUIqF5juebWCawG3FWkJF0d0vlkcBa71bAkyoaI1odO3NRRitamhGf49hS0AJ(AmmbpFvWSS0oZgm9zDyTWM)O22ilBRvyAIcQZctMRYQv590efuNfMmyOY7Cri(NRD2Sza9(CDfzCSvgCLynnfGaPYR3uhQ9ppCAAAwacKkVEdsP6ZlTbiubcTxgkXcAN6SoSann5GPMpn1RIgWgfz(lHSd7kd2KNOFfi1Z1ccFdEvJRjttj(v4nJmTGW3KaH14AY0uIFfEZOM2zGW3GFsP8opuEtMMs8RWBQzAtt28UIQ3GFsP8opuEtgQCDfboxlqVpxxrMFVpLkJjcjQZ2971(EJIEZFju(HzWJ2uFngMGNVkyaxT)hSIwAg050K(Amm6kieuTWVzzPvFnggDfecQw430uIFfgr6RXWe88vbd4Q9)GfcMPPTrRxfnGnkYy1xcSbpxL9o41fYwlf275ZNMMrr(6SSiqdLyLQjxLHny5vG0gGqfi0EzOeRun5QmSblVcKPPe)kmI0eDGorWmneTEv0a2Oid(QXsL3tHFQpF(85ANztacKkVEtDO2)8WPPPzbiubcTxMaSacrIY)oLXwxFp20uIFfgr6RXWe88vbd4Q9)GfYXwT20RIgWgfz0DLxbkdhzxPY)(vOWttbiubcTxMaSacrIY)oLXwxFp20KdMsRJ)2vzlODQrKgsB(0KoeJ1oou7FUPe)kmIcqOceAVmbybeIeL)DkJTU(ESPPe)k88PjDigRDCO2)Ctj(vyePVgdtWZxfmGR2)dwiqtBJwVkAaBuKXQVeydEUk7DWRlKTwkS3Z5nqxwspmXcYTPkkPyX(97SGSTIM0VcSSkfHXSGCBQIskwSdxkqwuo(zrbluuZYV7fliBROj9Ra6z53PILfMyrNgWM4n8WFWcBWpcIanTdKk4cNhnvrjf6Vre6RXWe88vbttj(v4n1udtt6RXWe88vbd4Q9)GfISfDIGEv0a2OiJvFjWg8Cv27GxxiBTuyVJMM2QfO3NRRitamhGf49hSY4N3Wd)blSb)iic0eifH)ZvzxDOQeQE0FJia6956kYeaZbybE)bRm(1otFngMGNVkyaxT)hS2mcBrNiOxfnGnkYy1xcSbpxL9o41fYwlf27OPPTtt2eGaPYR3aKQFpvpFAsFngM2bsfCHZJMQOKYSS0QVgdt7aPcUW5rtvuszAkXVcJOOgccWcCDVXQPWHPSRouvcvV5Vekd0vlcbZSrFnggDfecQw43SS0AZ7kQEd(9wbBqdvUUIaNZB4H)Gf2GFeebAUk4D5)bl0FJia6956kYeaZbybE)bRm(5nqxwI66956kILfMazbwS46N6(JWS87(ZIDVEwEil6elyhibYYa2SGSTIM0VcSGHS87(ZYVtPyXBQEwS74NazjQJf(zrNgWMy53PeEdp8hSWg8JGiqdqVpxxrOV8ekcSdKYdyNdE(Qa6b6QffracvGq7Lj45RcMMs8RWBQzAtt2a07Z1vKjalGqKOmiHtvbTbiqQ86n1HA)ZdNMMa71bAkyoaI5nqxwspmHzb5crlwUblxXIxSGwb1zHjw8cKLVpcZYdzrDfXY9SSSyX(97SGqwkS3ONfKTv0K(va9SGwjwq7uZs6GfilEbYYwbDR)asSaWU3j8gE4pyHn4hbrGMXQtLHJmPwfH(BebfuNfMmxL9kL2zo(BxLTG2PgrrnB1y91yygRovgoYKAvKb)EaPOPHPj91yyAhivWfopAQIskZYAU2z6RXWy1xcSbpxL9o41fYwlf2BdqxTiezlcN20K(AmmbpFvW0uIFfEZiBUwGEFUUImyhiLhWoh88vbTZSjabsLxVPOqdvWgCAce(gh0T(diLX29ojd6jokY8xaPRqnx7mBcqGu51Bas1VNQNM0xJHPDGubx48OPkkPmnL4xHruutJNHWrRxfnGnkYGVASu59u4N6ZNRvFngM2bsfCHZJMQOKYSSMMSrFngM2bsfCHZJMQOKYSSMRDMnbiqQ86niLQpVMMcqOceAVmuIf0o1zDybAAkXVcVPTPnx77nk6n)Lq5hMbpAtnmnPdXyTJd1(NBkXVcJintJ3aDzj9WelA0f97Sa49E4kflwnmGz5gSa49E4kflhU2(zzzXB4H)Gf2GFeebAWV3dxPq)nIqFnggyr)ooBrDGS(dwMLLw91yyWV3dxPmnnAcV76kI3aDzbzEfiflaEVvWgKLBWY9SS7ywuegZYV7flAaZstj(vxHc9SKcUyXBIf)zjQLgcyzRyeclEbYYVtSewDt1ZcAfuNfMyz3XSObeGzPPe)QRqXB4H)Gf2GFeebAcEfivwFngOV8ekc87Tc2GO)grOVgdd(9wbBqttj(vyePbTZ0xJHHcQZctzmu5TPPe)k8MAyAsFnggkOolmLvRYBttj(v4n1WCTo(BxLTG2PEZOwA8gOlliZRaPy53jwqilf2Bw0xJbl3GLFNyXQHbwSdxkWA7Nf1velllwSF)ol)oXsri(z5VeIfKblGqKiwcWecZcCmyjaAyj67hMLfE5kvkwGLkfl7ULfvywax9vOy53jwshYB4n8WFWcBWpcIanbVcKkRVgd0xEcfHvFjWg8Cv27GxxiBTuyVr)nI4DfvV5QG3L)hSmu56kcuRnVRO6nfzpNaHLHkxxrGAJ6B2SiLwAASJ)2vzlODQracNMgJPpRdRf28h12gzzBTcrdHtBoYzgcJCWwKsL3D8tZ14aeQaH2ltawaHir5FNYyRRVhBAkXVcphrr9nBwKslnn2XF7QSf0o1AS(Ammw9LaBWZvzVdEDHS1sH92a0vlcbiCAAmM(SoSwyZFuBBKLT1keneoT5iNzimYbBrkvE3XpnxJdqOceAVmbybeIeL)DkJTU(ESPPe)k8CTbiubcTxMGNVkyAkXVcVzKstR(Ammw9LaBWZvzVdEDHS1sH92a0vlcr2QzAA1xJHXQVeydEUk7DWRlKTwkS3gGUArBgP00gGqfi0EzcWciejk)7ugBD99yttj(vyeHWPPDCO2)Ctj(v4ndqOceAVmbybeIeL)DkJTU(ESPPe)kmcqhAN1RIgWgfzcKIW)5Qm2667Xtta9(CDfzcWciejkds4uvyoVb6Yca6XSyFNkwqilf2BwW7WLcKfDIfRggceilK3QuS8qw0jwCDfXYdzzHjwqgSacrIybwSeGqfi0EXYm0cJP6pxPsXIofGjeMLVxel3GfWvI1vOyzRyeclf0ol2pLIfxPG2zjfCXYdzXI6bfEvkwO6PMfeYsH9MfVaz53PILfMybzWciejAoVHh(dwyd(rqeObO3NRRi0xEcfHvddzRLc7DM8wLc9aD1IIiabsLxVPou7FE4K2Ev0a2OiJvFjWg8Cv27GxxiBTuyV1QVgdJvFjWg8Cv27GxxiBTuyVnaD1IqGJ)2vzlODQrqK2mIiLwAAb6956kYeGfqisugKWPQG2aeQaH2ltawaHir5FNYyRRVhBAkXVcJih)TRYwq7uJCIuArdva0K4iwRnG96anfmhaXAPG6SWK5QSxP064VDv2cAN6nb6956kYeGfqisu2XwAdqOceAVmbpFvW0uIFfEtnWBGUSKEyIfaV3dxPyX(97Sa4jLYBw0i9nEwGnlVTrgliSvGfVazPGSa49wbBq0ZI9DQyPGSa49E4kflhMLLflWMLhYIvddSGqwkS3SyFNkwCDiqILOwASSvmczgSz53jwiVvPybHSuyVzXQHbwa6956kILdZY3lAolWMfh0Y)diXc2U3jSS7ywImeGPaMLMs8RUcflWMLdZYvSmuhQ9N3Wd)blSb)iic0GFVhUsH(BeXS3vu9g8tkL3zW(gVHkxxrGtty6Z6WAHn)rTTrwgHTcZ1AZ7kQEd(9wbBqdvUUIa1QVgdd(9E4kLPPrt4DxxrATPxfnGnkY8xczh2vgSjpr)kqQ1otFnggR(sGn45QS3bVUq2APWEBa6QfTze2QH00AJ(AmmbpFvWSS0odO3NRRiJJTYGReRPj91yyq6kWMaZuIf0o1ju9zQOg1ffYSSMMa6956kYy1Wq2APWENjVvPMpnnlabsLxVPOqdvWgu77kQEd(jLY7myFJ3qLRRiqTZaHVXbDR)aszSDVtYGEIJImnL4xH3mYMM8WFWY4GU1FaPm2U3jzqpXrrMRYd1HA)NpFU2zbiubcTxMGNVkyAkXVcVPMPnnfGqfi0EzcWciejk)7ugBD99yttj(v4n1mT58gOllAKvIfMLTIriSOtdytSGmybeIeXYcFfkw(DIfKblGqKiwcWc8(dwS8qwc7uajwUblidwaHirSCyw8WVCLkflUoC9S8qw0jwco(5n8WFWcBWpcIan43B8QrrO)gra07Z1vKXQHHS1sH9otERsXBGUSKEyIfnkiSWSyFNkwsbxS4nXIRdxplpenEtSeClRRqXsy3BueMfVazjXrIybVAILFNsXI3elxXIxSGwb1zHjwW)PuSmGnli0RrHgKRgfVHh(dwyd(rqeOPi75eiSq)nIWTYHDkGK2zHDVrr4iSvBtHDVrr5)siePHPPWU3OiCerAoVHh(dwyd(rqeOz3vJCcewO)gr4w5Wofqs7SWU3OiCe2QTPWU3OO8FjeI0W0uy3BueoIinx7m91yyOG6SWuwTkVnnL4xH3KqmfwpL)lHMM0xJHHcQZctzmu5TPPe)k8MeIPW6P8Fj0CEdp8hSWg8JGiqZyPu5eiSq)nIWTYHDkGK2zHDVrr4iSvBtHDVrr5)siePHPPWU3OiCerAU2z6RXWqb1zHPSAvEBAkXVcVjHykSEk)xcnnPVgddfuNfMYyOYBttj(v4njetH1t5)sO58gOllPhMybW7nE1Oiw0Ol63zXQHbmlEbYc4kXILTIriSyFNkwq2wrt6xb0ZcALybTtnlPdwGONLFNyjQlv)EQMf91yWYHzX1HRNLhYYWvkwGJblWMLuW12GSeClw2kgHWB4H)Gf2GFeebAWV34vJIq)nIGcQZctMRYELs7m91yyGf974CqrENbE4dwML10K(AmmiDfytGzkXcAN6eQ(mvuJ6Iczwwtt6RXWe88vbZYs7mBcqGu51BqkvFEnnfGqfi0EzOelODQZ6Wc00uIFfEtnmnPVgdtWZxfmnL4xHreQaOjXrC0gkiSN54VDv2cANAKdqVpxxrgmohG4F(CTZSjabsLxVbiv)EQEAsFngM2bsfCHZJMQOKY0uIFfgrOcGMehXrlqNA2mh)TRYwq7uJaeoTO9UIQ3mwDQmCKj1QidvUUIaNJCa6956kYGX5ae)ZrqKI27kQEtr2ZjqyzOY1veOwB6vrdyJIm4RglvEpf(P(CT6RXW0oqQGlCE0ufLuML10K(AmmTdKk4cNhnvrjvgF1yPY7PWp1NBwwttZ0xJHPDGubx48OPkkPmnL4xHrKh(dwg8794AYqiMcRNY)LqAXwKsL3D8tikndcpnPVgdt7aPcUW5rtvuszAkXVcJip8hSm2B)3neIPW6P8Fj00eqVpxxrMlYbZbybE)blTbiubcTxMRWHE9UUIYr(YRFLKbjGxGmn5GP0sr(6SSiqZv4qVExxr5iF51VsYGeWlqZ1QVgdt7aPcUW5rtvuszwwtt2OVgdt7aPcUW5rtvuszwwATjaHkqO9Y0oqQGlCE0ufLuMMCWuZNMa6956kY4yRm4kXAAshIXAhhQ9p3uIFfgrOcGMehXrlqNAMJ)2vzlODQroa9(CDfzW4CaI)5Z5nqxwIENILhYsIJeXYVtSOt4Nf4GfaV3kydYIEkwWVhq6kuSCplllwI81fqsLILRyXRuSGwb1zHjw0xpliKLc7nlhU2(zX1HRNLhYIoXIvddbcK3Wd)blSb)iic0GFVXRgfH(BeX7kQEd(9wbBqdvUUIa1AtVkAaBuK5VeYoSRmytEI(vGuRDM(Amm43BfSbnlRPjh)TRYwq7uVzulT5A1xJHb)ERGnOb)EajefjTZ0xJHHcQZctzmu5TzznnPVgddfuNfMYQv5TzznxR(Ammw9LaBWZvzVdEDHS1sH92a0vlcr2Iott7SaeQaH2ltWZxfmnL4xH3uZ0MMSbO3NRRitawaHirzqcNQcAdqGu51BQd1(NhonN3aDzbTW)L4pHzzhANLKvyNLTIriS4nXck)kcKflQzbtbybAyrJUuPy5DKimlol4YTW7WNLbSz53jwcRUP6zbF)Y)dwSGHSyhUuG12pl6elEiSA)jwgWMfL3OOML)sOr7jeM3Wd)blSb)iic0a07Z1ve6lpHIWXwieQbqb0d0vlkckOolmzUkRwL3rlYqoE4pyzWV3JRjdHykSEk)xcHaBOG6SWK5QSAvEhTzOde8UIQ3GHlvgoY)oLhWMWVHkxxrGrlsZroE4pyzS3(VBietH1t5)sieKMbH1aYbBrkvE3XpHG0mAiAVRO6nL)RMWzDx5vGmu56kcK3aDzrJSsSybW7nE1OiwUIfVybTcQZctS4ywWqyXIJzXcIXNUIyXXSOGfkwCmlPGlwSFkflubYYYIf73VZsKLgcyX(ovSq1t9vOy53jwkcXplOvqDwyc9SacRTFwu0ZY9Sy1WaliKLc7n6zbewB)SabsT9(EIfVyrJUOFNfRggyXlqwSGqfl60a2eliBROj9RalEbYcALybTtnlPdwG8gE4pyHn4hbrGg87nE1Oi0FJiSPxfnGnkY8xczh2vgSjpr)kqQ1otFnggR(sGn45QS3bVUq2APWEBa6QfHiBrNPnnPVgdJvFjWg8Cv27GxxiBTuyVnaD1IqKTAinTVRO6n4NukVZG9nEdvUUIaNRDgfuNfMmxLXqL3AD83UkBbTtnca6956kY4ylec1aOq00xJHHcQZctzmu5TPPe)kmcaHVzS6uz4itQvrM)ciHZnL4xfnBnAyZilTPjkOolmzUkRwL3AD83UkBbTtnca6956kY4ylec1aOq00xJHHcQZctz1Q820uIFfgbGW3mwDQmCKj1QiZFbKW5Ms8RIMTgnSzulT5ATrFnggyr)ooBrDGS(dwMLLwBExr1BWV3kydAOY1veO2zbiubcTxMGNVkyAkXVcVj6CAcdxk9Ran)EFkvgtesuBOY1veOw91yy(9(uQmMiKO2GFpGeIIuK04z9QObSrrg8vJLkVNc)uFE0SDU2XHA)ZnL4xH3uZ0st74qT)5Ms8RWiY20sBAcSxhOPG5aiEU2z2eGaPYR3GuQ(8AAkaHkqO9Yqjwq7uN1HfOPPe)k8M2oN3aDzj9WelAuqyHz5kw8kflOvqDwyIfVazb7ajwqO3vdeGCxkflAuqyXYa2SGSTIM0VcS4filr9UcSjqwqRelODQtO6nSSvfgYYctSSfnkw8cKfKRgfl(ZYVtSqfilWbli3MQOKIfVazbewB)SOONfnstEI(vGuZYWvkwGJbVHh(dwyd(rqeOPi75eiSq)nIWTYHDkGKwGEFUUImyhiLhWoh88vbTZ0xJHHcQZctz1Q820uIFfEtcXuy9u(VeAAsFnggkOolmLXqL3MMs8RWBsiMcRNY)LqZ5n8WFWcBWpcIan7UAKtGWc93ic3kh2PasAb6956kYGDGuEa7CWZxf0otFnggkOolmLvRYBttj(v4njetH1t5)sOPj91yyOG6SWugdvEBAkXVcVjHykSEk)xcnx7m91yycE(QGzznnPVgdJvFjWg8Cv27GxxiBTuyVnaD1Ique2QzAZ1oZMaeivE9gGu97P6Pj91yyAhivWfopAQIskttj(vyentdASTrRxfnGnkYGVASu59u4N6ZNRvFngM2bsfCHZJMQOKYSSMMSrFngM2bsfCHZJMQOKYSSMRDMn9QObSrrM)si7WUYGn5j6xbs90eHykSEk)xcHi91yy(lHSd7kd2KNOFfi1MMs8RWtt2OVgdZFjKDyxzWM8e9RaP2SSMZB4H)Gf2GFeebAglLkNaHf6VreUvoStbK0c07Z1vKb7aP8a25GNVkODM(AmmuqDwykRwL3MMs8RWBsiMcRNY)Lqtt6RXWqb1zHPmgQ820uIFfEtcXuy9u(VeAU2z6RXWe88vbZYAAsFnggR(sGn45QS3bVUq2APWEBa6QfHOiSvZ0MRDMnbiqQ86niLQpVMM0xJHbPRaBcmtjwq7uNq1NPIAuxuiZYAU2z2eGaPYR3aKQFpvpnPVgdt7aPcUW5rtvuszAkXVcJinOvFngM2bsfCHZJMQOKYSS0AtVkAaBuKbF1yPY7PWp1NpnzJ(AmmTdKk4cNhnvrjLzznx7mB6vrdyJIm)Lq2HDLbBYt0VcK6PjcXuy9u(Vecr6RXW8xczh2vgSjpr)kqQnnL4xHNMSrFngM)si7WUYGn5j6xbsTzznN3aDzj9Weliuq0IfyXsaK3Wd)blSb)iic0y37(GDgoYKAveVb6Ys6Hjwa8EpUMy5HSy1WalaGkVzbTcQZctONfKTv0K(vGLDhZIIWyw(lHy539IfNfeQ2)DwietH1tSOOXZcSzbwQuSG8RYBwqRG6SWelhMLLLHfeQ73zj62gzSyRvGfQEQzXzbau5nlOvqDwyILBWcczPWEZc(pLILDhZIIWyw(DVyXwntJf87bKWS4filiBROj9RalEbYcYGfqisel7oqILeytS87EXIMOtmlitJWstj(vxHYWs6HjwCDiqIfB1qAihw2D8tSaU6RqXcYTPkkPyXlqwS1wBroSS74NyX(97W1ZcYTPkkP4n8WFWcBWpcIan437X1e6VreuqDwyYCvwTkV1AJ(AmmTdKk4cNhnvrjLzznnrb1zHjdgQ8oxeI)PPzuqDwyY4vQCri(NM0xJHj45RcMMs8RWiYd)blJ92)DdHykSEk)xcPvFngMGNVkywwZ1oZgm9zDyTWM)O22ilBRvyAQxfnGnkYy1xcSbpxL9o41fYwlf2BT6RXWy1xcSbpxL9o41fYwlf2BdqxTiezRMPPnaHkqO9Ye88vbttj(v4n1eDQDMnbiqQ86n1HA)ZdNMMcqOceAVmbybeIeL)DkJTU(ESPPe)k8MAIoNRDMnThiZ3qLAAkaHkqO9YOtnMAKUcLPPe)k8MAIoNpFAIcQZctMRYELs7m91yyS7DFWodhzsTkYSSMMWwKsL3D8tikndcRbTZSjabsLxVbiv)EQEAYg91yyAhivWfopAQIskZYA(0uacKkVEdqQ(9uTwSfPu5Dh)eIsZGWZ5nqxwspmXccv7)olWFNA7hMyX((f2z5WSCflaGkVzbTcQZctONfKTv0K(vGfyZYdzXQHbwq(v5nlOvqDwyI3Wd)blSb)iic0yV9FN3aDzb56k1V3lEdp8hSWg8JGiqtVQSh(dwz1HF0xEcfXWvQFVxXaWwuiElAMMTXF8hhd]] )
    

end