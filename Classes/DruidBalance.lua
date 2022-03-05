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


    spec:RegisterPack( "Balance", 20220305, [[dm104fqikv9iiv6squXMiL(KsPgLI4uksRsKKxbbMfPOUfPi2ff)csPHjs5yKclJsLNjeAAqqDnivTniQ03GuOXje4CIeY6ejyEqi3tiAFkf9prcv1afjuLdQusluKQEieLjsksUiKk2iKc(ieKkJecsvNuKkwPsHxksOYmHOQBskszNkL4NKIunuiioQiHIwkeKYtb0ufj1vfPsBvKqPVcbjJfsr7vO(ROgmXHPAXKQhlyYaDzKnRWNHKrRuDAvwTiHcVgImBsUTi2TKFdA4uYXfcA5s9COMUQUUs2oaFNsz8qOoVqA9IenFf1(rDSgXPogiO)u8wSln7SlTiMg6nAKgchbiCeed8JArXaT8asokkgy5jumW07kVcumqlpQc6GXPogigU6afdC)FlCkGw0Q7kVcKMGVKGb197lDZbrB6DLxbstaEjidTjGM9prLI)4uuK6UYRazEe)Xa1xN6tNkwpgiO)u8wSln7SlTiMg6nAKgchbimYngOV(Dyhde4LGSyG7hiivX6XabjCigy6DLxbIfnvVoqEdnnVd7SGWAMf7sZo74n4nq2UxOiCkWBOjSSvqqcKfGqL3SKEYtm8gAcliB3lueilV3OOpFdwcoMWS8qwcrdkk)EJIESH3qtybHgLabqGSSQIceg7Duwa4956kcZYKZqgnZIvtaY43B8QrrSOjBYIvtam43B8Qrrtn8gAclBfa8azXQPGJ)RqXccv7)ol3GL73gZYVtSyRHfkwqNG6SWKH3qtyrtZrIybzWcaejILFNybO113JzXzrD)RiwsGnXYqri(0veltUblrHlw2DWA7NL97z5EwWxYs9ErWfwfLfB3VZs6103AQzbbSGmsr4)CflBvDOQeQEnZY9BdYcgPZAQH3qtyrtZrIyjbIFw2ECO2)Ctj(v4TzbhOY7dIzXTSurz5HSOdXywghQ9hZcSurn8gAclPUj)zj1WeIf4GL0R8DwsVY3zj9kFNfhZIZc2IcNRy57RqIEdVHMWIMUfvuZYKZqgnZccv7)UMzbHQ9FxZSa89ECnnLLehKyjb2elnHp1r1ZYdzH8wDuZsaMO7VMGFVFdVHMWcA4qmlP4UcSjqwqNelOnQtO6zjStbKyzaBwqMMILf2rrMyGQd)44uhdeArf1XPoElAeN6yGu56kcmo9Xa9WFWkgOT2)9yGGeo0N1FWkgicPPGJFwSJfeQ2)Dw8cKfNfGV34vJIybwSam1Sy7(Dw2YHA)zbn4elEbYs6HBn1SaBwa(EpUMyb(7uB7WumWqFp1NhdCcluqDwyYOwL35Iq8ZY8mluqDwyYCvgdvEZY8mluqDwyYCvwh(7SmpZcfuNfMmEfnxeIFwMYIwwSAcGrdJT2)Dw0YI9Sy1eaJDgBT)7XF8wSlo1XaPY1veyC6Jb6H)Gvmq8794AkgyOVN6ZJboHf7zPxfnGnkYO7kVcugoYUsL)9RqHnu56kcKL5zwSNLaeavE9M6qT)5HtSmpZI9SGTiLk)EJIESb)EpCLILizrdwMNzXEwExr1Bk)xnHZ6UYRazOY1veiltzrll2ZcM(SoSwyZFuBxeKTZkWY8mltyHcQZctgmu5DUie)SmpZcfuNfMmxLvRYBwMNzHcQZctMRY6WFNL5zwOG6SWKXRO5Iq8ZY0yGQROCamgi6J)4TeX4uhdKkxxrGXPpgOh(dwXaXV34vJIIbg67P(8yGtyPxfnGnkYO7kVcugoYUsL)9RqHnu56kcKfTSeGaOYR3uhQ9ppCIfTSGTiLk)EJIESb)EpCLILizrdwMYIwwSNfm9zDyTWM)O2UiiBNvigO6kkhaJbI(4p(JbcsdFP(4uhVfnItDmqp8hSIbIHkVZ6KNedKkxxrGXPp(J3IDXPogivUUIaJtFmWqFp1Nhd8VeIfeXYewSJLuXIh(dwgBT)7MGJ)8FjeliGfp8hSm437X1Kj44p)xcXY0yG4VVWhVfnIb6H)GvmWGRuzp8hSYQd)Xavh(ZLNqXaHwurD8hVLigN6yGu56kcmo9XaHwXaX0hd0d)bRyGa8(CDffdeGRwumqSfPu53Bu0Jn437HRuSSjlAWIwwMWI9S8UIQ3GFVvWg0qLRRiqwMNz5DfvVb)Ks5DgSVXBOY1veiltzzEMfSfPu53Bu0Jn437HRuSSjl2fdeKWH(S(dwXabspMLTcrhwGflrebSy7(D46zbSVXZIxGSy7(Dwa(ERGnilEbYIDiGf4VtTTdtXab4DU8ekg4HZoKI)4TGWXPogivUUIaJtFmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdeBrkv(9gf9yd(9ECnXYMSOrmqqch6Z6pyfdei9ywckYbqSyBNkwa(EpUMyj4fl73ZIDiGL3Bu0JzX2(f2z5WS0KIa41ZYa2S87elOtqDwyILhYIoXIvtdQBcKfVazX2(f2zzCkf1S8qwco(JbcW7C5jumWdNdkYbqXF8wqFCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXaTAcqgva0OHjbcRX1elZZSy1eGmQaOrddEvJRjwMNzXQjazubqJgg87nE1OiwMNzXQjazubqJgg879WvkwMNzXQjazubqJgMXQJMHJmPwfXY8mlwnbW0oaQGlCE0uLYOSmpZI(AmmbpFvW0uIFfMLizrFngMGNVkyaxT)hSyzEMfaEFUUImho7qkgiiHd9z9hSIbMI17Z1vel)U)Se2PasywUblrHlw8My5kwCwqfaz5HS4aGhil)oXc((L)hSyX2o1elolFFfs0Zc9bwomllmbYYvSOtVnIkwco(XXab4DU8ekg4vzubW4pEli34uhdKkxxrGXPpgOh(dwXa1PgtnsxHkgiiHd9z9hSIbMUyIL0tnMAKUcfl(ZYVtSqfilWblOHMQugLfB7uXYUJFILdZIRdbqSGCtd5Ozw8XtnlidwaGirS4filWFNABhMyX297SGSTI20PcXad99uFEmWjSmHf7zjabqLxVPou7FE4elZZSyplbiubcTvMaSaarIY)oLXwxFp2SSyzEMLEv0a2OitGue(pxLXwxFp2qLRRiqwMYIww0xJHj45RcMMs8RWSSjlAGEw0YI(AmmTdGk4cNhnvPmQPPe)kmliIfeMfTSyplbiaQ86naO63J2SmpZsacGkVEdaQ(9OnlAzrFngMGNVkywwSOLf91yyAhavWfopAQszuZYIfTSmHf91yyAhavWfopAQszuttj(vywquKSOHDSOjSGWSKkw6vrdyJIm4RglvEpk(P(CdvUUIazzEMf91yycE(QGPPe)kmliIfn0GL5zw0Gf0Yc2IuQ8UJFIfeXIggKlltzzklAzbG3NRRiZvzubW4pElOX4uhdKkxxrGXPpgyOVN6ZJboHf91yycE(QGPPe)kmlBYIgONfTSmHf7zPxfnGnkYGVASu59O4N6Znu56kcKL5zw0xJHPDaubx48OPkLrnnL4xHzbrSOrkIfTSOVgdt7aOcUW5rtvkJAwwSmLL5zw0HymlAzzCO2)Ctj(vywqel2HEwMYIwwa4956kYCvgvamgiiHd9z9hSIbIqGpl2UFNfNfKTv0MovGLF3FwoCT9ZIZcczPWEZIvddSaBwSTtfl)oXY4qT)SCywCD46z5HSqfymqp8hSIbAb)dwXF8wIG4uhdKkxxrGXPpgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbgOtXYewMWY4qT)5Ms8RWSOjSOb6zrtyjaHkqOTYe88vbttj(vywMYcAzrJiinwMYsKSeOtXYewMWY4qT)5Ms8RWSOjSOb6zrtyjaHkqOTYeGfaisu(3Pm2667XgWv7)blw0ewcqOceARmbybaIeL)DkJTU(ESPPe)kmltzbTSOreKgltzrll2Zs7hyMaq1BCqqSHq8HFmlAzzcl2ZsacvGqBLj45RcMMCWOSmpZI9SeGqfi0wzcWcaejY0KdgLLPSmpZsacvGqBLj45RcMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzzEMLEv0a2OitGue(pxLXwxFp2qLRRiqw0YsacvGqBLj45RcMMs8RWSSjlrmnwMNzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzrtyrJ0yzEMf7zjabqLxVPou7FE4umqqch6Z6pyfdezUkSu(tywSTt)o1SSWxHIfKblaqKiwkOnwSDkflUsbTXsu4ILhYc(pLILGJFw(DIfSNqS4jWv9SahSGmybaIeHaKTv0MovGLGJFCmqaENlpHIbgGfaisugKWrRq8hVLuuCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXaNWY7nk6n)Lq5hMbpILnzrd0ZY8mlTFGzcavVXbbXMRyztwqFASmLfTSmHLjSqr46SSiqdLyfTjxLHny5vGyrlltyXEwcqau51Baq1VhTzzEMLaeQaH2kdLyfTjxLHny5vGmnL4xHzbrSObYfnYccyzclONLuXsVkAaBuKbF1yPY7rXp1NBOY1veiltzzklAzXEwcqOceARmuIv0MCvg2GLxbY0KdgLLPSmpZcfHRZYIany4sPO)VcvUx6rzrlltyXEwcqau51BQd1(NhoXY8mlbiubcTvgmCPu0)xHk3l9O5iIWOpcstdttj(vywqelAObcZYuwMNzzclbiubcTvgDQXuJ0vOmn5GrzzEMf7zP9az(gQuSmpZsacGkVEtDO2)8WjwMYIwwMWI9S8UIQ3mwD0mCKj1QidvUUIazzEMLaeavE9gau97rBw0YsacvGqBLzS6Oz4itQvrMMs8RWSGiw0qdwqalONLuXsVkAaBuKbF1yPY7rXp1NBOY1veilZZSyplbiaQ86naO63J2SOLLaeQaH2kZy1rZWrMuRImnL4xHzbrSOVgdtWZxfmGR2)dwSGaw0Wowsfl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilAclAyhltzrlltyHIW1zzrGMRWHE9UUIYr4YRFLKbjaxGyrllbiubcTvMRWHE9UUIYr4YRFLKbjaxGmnL4xHzbrSGEwMYY8mltyzclueUollc0G3DqOncmdB9mCKFyNq1ZIwwcqOceARmpStO6jW8v4d1(NJi6rFeTtdttj(vywMYY8mltyzcla8(CDfzGvEHP83xHe9SejlAWY8mla8(CDfzGvEHP83xHe9SejlrKLPSOLLjS89virV51W0KdgnhGqfi0wXY8mlFFfs0BEnmbiubcTvMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzrtyrJ0yzklZZSaW7Z1vKbw5fMYFFfs0ZsKSyhlAzzclFFfs0BE7mn5GrZbiubcTvSmpZY3xHe9M3otacvGqBLPPe)kmlBYYvp1wqL)eyECO2)Ctj(vyw0ew0inwMYY8mla8(CDfzGvEHP83xHe9SejlPXYuwMYY0yGGeo0N1FWkgy6IjqwEilGKYJYYVtSSWokIf4GfKTv0MovGfB7uXYcFfkwaHlDfXcSyzHjw8cKfRMaq1ZYc7OiwSTtflEXIdcYcbGQNLdZIRdxplpKfWJIbcW7C5jumWayoalW7pyf)XBrJ0ItDmqQCDfbgN(yGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgO9SGHlL(vGMFVpLkJjcjQnu56kcKL5zwghQ9p3uIFfMLnzXU0sJL5zw0HymlAzzCO2)Ctj(vywqel2HEwqaltybHtJfnHf91yy(9(uQmMiKO2GFpGelPIf7yzklZZSOVgdZV3NsLXeHe1g87bKyztwIyeWIMWYew6vrdyJIm4RglvEpk(P(CdvUUIazjvSyhltJbcs4qFw)bRyGPy9(CDfXYctGS8qwajLhLfVIYY3xHe9yw8cKLaiMfB7uXIn)(RqXYa2S4flOZYAh2NZIvddXab4DU8ekg4V3NsLXeHe1zB(9XF8w0qJ4uhdKkxxrGXPpgiiHd9z9hSIbMUyIf0jXkAtUIfn9gS8kqSyxAykGzrNgWMyXzbzBfTPtfyzHjwGnlyil)U)SCpl2oLIf1velllwSD)ol)oXcvGSahSGgAQsz0yGLNqXaPeROn5QmSblVcumWqFp1NhdmaHkqOTYe88vbttj(vywqel2LglAzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSGiwSlnw0YYewa4956kY879PuzmrirD2MFplZZSOVgdZV3NsLXeHe1g87bKyztwIyASGawMWsVkAaBuKbF1yPY7rXp1NBOY1veilPILiYYuwMYIwwa4956kYCvgvaKL5zw0HymlAzzCO2)Ctj(vywqelrengd0d)bRyGuIv0MCvg2GLxbk(J3Ig2fN6yGu56kcmo9XabjCOpR)GvmW0ftSaeUuk6Vcfli0w6rzb5IPaMfDAaBIfNfKTv0MovGLfMyb2SGHS87(ZY9Sy7ukwuxrSSSyX297S87elubYcCWcAOPkLrJbwEcfdedxkf9)vOY9spAmWqFp1NhdCclbiubcTvMGNVkyAkXVcZcIyb5YIwwSNLaeavE9gau97rBw0YI9SeGaOYR3uhQ9ppCIL5zwcqau51BQd1(NhoXIwwcqOceARmbybaIeL)DkJTU(ESPPe)kmliIfKllAzzcla8(CDfzcWcaejkds4OvGL5zwcqOceARmbpFvW0uIFfMfeXcYLLPSmpZsacGkVEdaQ(9OnlAzzcl2ZsVkAaBuKbF1yPY7rXp1NBOY1veilAzjaHkqOTYe88vbttj(vywqelixwMNzrFngM2bqfCHZJMQug10uIFfMfeXIgPXccyzclONLuXcfHRZYIanxH)EfEyJZGhGROSoPuSmLfTSOVgdt7aOcUW5rtvkJAwwSmLL5zw0HymlAzzCO2)Ctj(vywqel2HEwMNzHIW1zzrGgkXkAtUkdBWYRaXIwwcqOceARmuIv0MCvg2GLxbY0uIFfMLnzXU0yzklAzbG3NRRiZvzubqw0YI9Sqr46SSiqZv4qVExxr5iC51VsYGeGlqSmpZsacvGqBL5kCOxVRROCeU86xjzqcWfittj(vyw2Kf7sJL5zw0HymlAzzCO2)Ctj(vywqel2Lwmqp8hSIbIHlLI()ku5EPhn(J3Igrmo1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyG6RXWe88vbttj(vyw2KfnqplAzzcl2ZsVkAaBuKbF1yPY7rXp1NBOY1veilZZSOVgdt7aOcUW5rtvkJAAkXVcZcIIKfnqVb9SGawMWsenONLuXI(Amm6kieuTWVzzXYuwqaltybHnONfnHLiAqplPIf91yy0vqiOAHFZYILPSKkwOiCDwweO5k83RWdBCg8aCfL1jLIfeWccBqplPILjSqr46SSiqZVt5X14pJpuNIfTSeGqfi0wz(DkpUg)z8H6uMMs8RWSGOizXU0yzklAzrFngM2bqfCHZJMQug1SSyzklZZSOdXyw0YY4qT)5Ms8RWSGiwSd9SmpZcfHRZYIanuIv0MCvg2GLxbIfTSeGqfi0wzOeROn5QmSblVcKPPe)kCmqqch6Z6pyfdCRkBEumllmXs6KIPMIfB3VZcY2kAtNkWcSzXFw(DIfQazboybn0uLYOXab4DU8ekg4fHG5aSaV)Gv8hVfnq44uhdKkxxrGXPpgOh(dwXaVch6176kkhHlV(vsgKaCbkgyOVN6ZJbcW7Z1vK5IqWCawG3FWIfTSaW7Z1vK5QmQaymWYtOyGxHd96DDfLJWLx)kjdsaUaf)XBrd0hN6yGu56kcmo9XabjCOpR)GvmW0ftSaC3bH2iqw00BDw0PbSjwq2wrB6uHyGLNqXaX7oi0gbMHTEgoYpStO6Jbg67P(8yGtyjaHkqOTYe88vbttoyuw0YI9SeGaOYR3uhQ9ppCIfTSaW7Z1vK537tPYyIqI6Sn)Ew0YYewcqOceARm6uJPgPRqzAYbJYY8ml2Zs7bY8nuPyzklZZSeGaOYR3uhQ9ppCIfTSeGqfi0wzcWcaejk)7ugBD99yttoyuw0YYewa4956kYeGfaisugKWrRalZZSeGqfi0wzcE(QGPjhmkltzzklAzbe(g8QgxtM)ciDfkw0YYewaHVb)Ks5DEO8Mm)fq6kuSmpZI9S8UIQ3GFsP8opuEtgQCDfbYY8mlylsPYV3OOhBWV3JRjw2KLiYYuw0Yci8njqynUMm)fq6kuSOLLjSaW7Z1vK5WzhsSmpZsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veilZZS44VDv2cAJAw2mswsrPXY8mla8(CDfzcWcaejkds4OvGL5zw0xJHrxbHGQf(nllwMYIwwSNfkcxNLfbAUch6176kkhHlV(vsgKaCbIL5zwOiCDwweO5kCOxVRROCeU86xjzqcWfiw0YsacvGqBL5kCOxVRROCeU86xjzqcWfittj(vyw2KLiMglAzXEw0xJHj45RcMLflZZSOdXyw0YY4qT)5Ms8RWSGiwq40Ib6H)Gvmq8UdcTrGzyRNHJ8d7eQ(4pElAGCJtDmqQCDfbgN(yGGeo0N1FWkgyQ3pmlhMfNL2)DQzHuUoS9NyXMhLLhYsIJeXIRuSalwwyIf87plFFfs0Jz5HSOtSOUIazzzXIT73zbzBfTPtfyXlqwqgSaarIyXlqwwyILFNyXUcKfSc(SalwcGSCdw0H)olFFfs0JzXBIfyXYctSGF)z57RqIECmWqFp1NhdCcla8(CDfzGvEHP83xHe9SyFKSOblAzXEw((kKO382zAYbJMdqOceARyzEMLjSaW7Z1vKbw5fMYFFfs0ZsKSOblZZSaW7Z1vKbw5fMYFFfs0ZsKSerwMYIwwMWI(AmmbpFvWSSyrlltyXEwcqau51Baq1VhTzzEMf91yyAhavWfopAQszuttj(vywqaltyjIg0ZsQyPxfnGnkYGVASu59O4N6Znu56kcKLPSGOiz57RqIEZRHrFngzWv7)blw0YI(AmmTdGk4cNhnvPmQzzXY8ml6RXW0oaQGlCE0uLYOz8vJLkVhf)uFUzzXYuwMNzjaHkqOTYe88vbttj(vywqal2XYMS89virV51WeGqfi0wzaxT)hSyrll2ZI(AmmbpFvWSSyrlltyXEwcqau51BQd1(NhoXY8ml2ZcaVpxxrMaSaarIYGeoAfyzklAzXEwcqau51BqkAFEXY8mlbiaQ86n1HA)ZdNyrlla8(CDfzcWcaejkds4OvGfTSeGqfi0wzcWcaejk)7ugBD99yZYIfTSyplbiubcTvMGNVkywwSOLLjSmHf91yyOG6SWuwTkVnnL4xHzztw0inwMNzrFnggkOolmLXqL3MMs8RWSSjlAKgltzrll2ZsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veilZZSmHf91yy0DLxbkdhzxPY)(vOW5Y)vtg87bKyjswqplZZSOVgdJUR8kqz4i7kv(3Vcfo7DWlYGFpGelrYseWYuwMYY8ml6RXWG0vGnbMPelOnQtO6ZurnQlLKzzXYuwMNzrhIXSOLLXHA)ZnL4xHzbrSyxASmpZcaVpxxrgyLxyk)9virplrYsASmLfTSaW7Z1vK5QmQaymqSc(4yGFFfs0Rrmqp8hSIb(9virVgXF8w0angN6yGu56kcmo9Xa9WFWkg43xHe92fdm03t95XaNWcaVpxxrgyLxyk)9virpl2hjl2XIwwSNLVVcj6nVgMMCWO5aeQaH2kwMNzbG3NRRidSYlmL)(kKONLizXow0YYew0xJHj45RcMLflAzzcl2ZsacGkVEdaQ(9OnlZZSOVgdt7aOcUW5rtvkJAAkXVcZccyzclr0GEwsfl9QObSrrg8vJLkVhf)uFUHkxxrGSmLfefjlFFfs0BE7m6RXidUA)pyXIww0xJHPDaubx48OPkLrnllwMNzrFngM2bqfCHZJMQugnJVASu59O4N6ZnllwMYY8mlbiubcTvMGNVkyAkXVcZccyXow2KLVVcj6nVDMaeQaH2kd4Q9)GflAzXEw0xJHj45RcMLflAzzcl2ZsacGkVEtDO2)8WjwMNzXEwa4956kYeGfaisugKWrRaltzrll2ZsacGkVEdsr7Zlw0YYewSNf91yycE(QGzzXY8ml2ZsacGkVEdaQ(9OnltzzEMLaeavE9M6qT)5HtSOLfaEFUUImbybaIeLbjC0kWIwwcqOceARmbybaIeL)DkJTU(ESzzXIwwSNLaeQaH2ktWZxfmllw0YYewMWI(AmmuqDwykRwL3MMs8RWSSjlAKglZZSOVgddfuNfMYyOYBttj(vyw2KfnsJLPSOLf7zPxfnGnkYO7kVcugoYUsL)9RqHnu56kcKL5zwMWI(Amm6UYRaLHJSRu5F)ku4C5)Qjd(9asSejlONL5zw0xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqILizjcyzkltzzklZZSOVgddsxb2eyMsSG2OoHQptf1OUusMLflZZSOdXyw0YY4qT)5Ms8RWSGiwSlnwMNzbG3NRRidSYlmL)(kKONLizjnwMYIwwa4956kYCvgvamgiwbFCmWVVcj6Tl(J3IgrqCQJbsLRRiW40hdeKWH(S(dwXatxmHzXvkwG)o1SalwwyIL7PemlWILaymqp8hSIbUWu(Ekbh)XBrJuuCQJbsLRRiW40hdeKWH(S(dwXarN73PMfuqwU6HS87el4NfyZIdjw8WFWIf1H)yGE4pyfdSxv2d)bRS6WFmq83x4J3IgXad99uFEmqaEFUUImho7qkgO6WFU8ekgOdP4pEl2LwCQJbsLRRiW40hd0d)bRyG9QYE4pyLvh(JbQo8NlpHIbI)4p(JbA1uaMO7FCQJ3IgXPogOh(dwXar6kWMaZyRRVhhdKkxxrGXPp(J3IDXPogivUUIaJtFmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdmTyGGeo0N1FWkgyQ3jwa4956kILdZcMEwEilPXIT73zPGSGF)zbwSSWelFFfs0J1mlAWITDQy53jwgxJFwGfXYHzbwSSWKMzXowUbl)oXcMcWcKLdZIxGSerwUbl6WFNfVPyGa8oxEcfdew5fMYFFfs0h)XBjIXPogivUUIaJtFmqOvmqhemgOh(dwXab4956kkgiaxTOyGAedm03t95Xa)(kKO38Ay2DCEHPS(AmyrllFFfs0BEnmbiubcTvgWv7)blw0YI9S89virV51WCyZdtOmCKtGf(B4cNdWc)9k8hSWXab4DU8ekgiSYlmL)(kKOp(J3cchN6yGu56kcmo9XaHwXaDqWyGE4pyfdeG3NRROyGaC1IIbAxmWqFp1Nhd87RqIEZBNz3X5fMY6RXGfTS89virV5TZeGqfi0wzaxT)hSyrll2ZY3xHe9M3oZHnpmHYWrobw4VHlCoal83RWFWchdeG35YtOyGWkVWu(7RqI(4pElOpo1XaPY1veyC6JbcTIb6GGXa9WFWkgiaVpxxrXab4DU8ekgiSYlmL)(kKOpgyOVN6ZJbsr46SSiqZv4qVExxr5iC51VsYGeGlqSmpZcfHRZYIanuIv0MCvg2GLxbIL5zwOiCDwweObdxkf9)vOY9spAmqqch6Z6pyfdm17eMy57RqIEmlEtSuWNfF9We)VGRurzbKEk8eiloMfyXYctSGF)z57RqIESHfwaspla8(CDfXYdzbHzXXS87uuwCfgYsreilylkCUILDVavxHYedeGRwumqeo(J3cYno1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyGrmnwsfltyrdw0ewsZyhlPIfm9zDyTWM)O2UiiJWwbwMgdeKWH(S(dwXabspMLFNyb47nE1Oiwcq8ZYa2SO8NAwcUkSu(FWcZYKbSzHqSNyPiwSTtflpKf879Zc4kX6kuSOtdytSGgAQszuwgUsHzbogtJbcW7C5jumqmohG4p(J3cAmo1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyGrmnwqalAKglPILEv0a2OitGue(pxLXwxFp2qLRRiWyGGeo0N1FWkgiq6XS4pl22VWolEcCvplWblBfJqybzWcaejIf8oCPazrNyzHjWuGfeonwSD)oC9SGmsr4)CflaTU(EmlEbYsetJfB3VBIbcW7C5jumWaSaarIYo2k(J3seeN6yGE4pyfdmbclKUkpGDsmqQCDfbgN(4pElPO4uhdKkxxrGXPpgOh(dwXaT1(Vhdm03t95XaNWcfuNfMmQv5DUie)SmpZcfuNfMmxLXqL3SmpZcfuNfMmxL1H)olZZSqb1zHjJxrZfH4NLPXavxr5aymqnsl(J)yGoKItD8w0io1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyG9QObSrrM)siBWUYGn5j6xbsTHkxxrGSOLLjSOVgdZFjKnyxzWM8e9RaP20uIFfMfeXcQaOjXrmliGL0mAWY8ml6RXW8xczd2vgSjpr)kqQnnL4xHzbrS4H)GLb)EpUMmeIPW6P8FjeliGL0mAWIwwMWcfuNfMmxLvRYBwMNzHcQZctgmu5DUie)SmpZcfuNfMmEfnxeIFwMYYuw0YI(Amm)Lq2GDLbBYt0VcKAZYkgiiHd9z9hSIbImxfwk)jml22PFNAw(DIfnvtEsW)Wo1SOVgdwSDkfldxPybogSy7(9Ry53jwkcXplbh)Xab4DU8ekgiytEs22Pu5HRuz4ye)XBXU4uhdKkxxrGXPpgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbApluqDwyYCvgdvEZIwwWwKsLFVrrp2GFVhxtSSjlOrw0ewExr1BWWLkdh5FNYdyt43qLRRiqwsfl2XccyHcQZctMRY6WFNfTSypl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilAzXEw6vrdyJImWI(DCoOiVZao8bldvUUIaJbcs4qFw)bRyGiZvHLYFcZITD63PMfGV34vJIy5WSyd2)olbh)xHIfiaQzb4794AILRyb5xL3SGob1zHPyGa8oxEcfd8qvWMY43B8QrrXF8wIyCQJbsLRRiW40hd0d)bRyGbybaIeL)DkJTU(ECmqqch6Z6pyfdmDXelidwaGirSyBNkw8NffHXS87EXc6tJLTIriS4filQRiwwwSy7(Dwq2wrB6uHyGH(EQppgO9Sa2Rd0uWCaeZIwwMWYewa4956kYeGfaisugKWrRalAzXEwcqOceARmbpFvW0KdgLL5zw0xJHj45RcMLfltzrlltyrFnggkOolmLvRYBttj(vyw2Kf0ZY8ml6RXWqb1zHPmgQ820uIFfMLnzb9SmLfTSmHfh)TRYwqBuZcIyb9PXIwwMWc2IuQ87nk6Xg8794AILnzjISmpZI(AmmbpFvWSSyzklZZSypl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veiltzrlltyXEwExr1BWpPuENb7B8gQCDfbYY8ml6RXWGFVhUszAkXVcZcIyrdd6zrtyjnd6zjvS0RIgWgfzcKIW)5Qm2667XgQCDfbYY8ml6RXWe88vbttj(vywqel6RXWGFVhUszAkXVcZccyb9SOLf91yycE(QGzzXYuw0YYewSNLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMNzrFnggDx5vGYWr2vQ8VFfkCU8F1Kb)Eajw2KLiYY8ml6RXWO7kVcugoYUsL)9RqHZEh8Im43diXYMSerwMYY8ml6qmMfTSmou7FUPe)kmliIfnsJfTSeGqfi0wzcE(QGPPe)kmlBYc6zzA8hVfeoo1XaPY1veyC6Jb6H)Gvmq8QgxtXadrdkk)EJIEC8w0igyOVN6ZJboHLMgnH3DDfXY8ml6RXWqb1zHPmgQ820uIFfMfeXsezrlluqDwyYCvgdvEZIwwAkXVcZcIyrdeMfTS8UIQ3GHlvgoY)oLhWMWVHkxxrGSmLfTS8EJIEZFju(HzWJyztw0aHzrtybBrkv(9gf9ywqalnL4xHzrlltyHcQZctMRYEfLL5zwAkXVcZcIybva0K4iMLPXabjCOpR)GvmW0ftSaCvJRjwUIflVaPKlWcSyXRO)(vOy539Nf1bGWSObcJPaMfVazrryml2UFNLeytS8EJIEmlEbYI)S87elubYcCWIZcqOYBwqNG6SWel(ZIgimlykGzb2SOimMLMs8RUcfloMLhYsbFw2DaxHILhYstJMW7SaU6RqXcYVkVzbDcQZctXF8wqFCQJbsLRRiW40hd0d)bRyG4vnUMIbcs4qFw)bRyGPlMyb4QgxtS8qw2DaelolOuqDxXYdzzHjwsNum1uXad99uFEmqaEFUUImxecMdWc8(dwSOLLaeQaH2kZv4qVExxr5iC51VsYGeGlqMMCWOSOLfkcxNLfbAUch6176kkhHlV(vsgKaCbIfTS4w5Wofqk(J3cYno1XaPY1veyC6Jb6H)Gvmq879WvQyGGeo0N1FWkgykoISyzzXcW37HRuS4plUsXYFjeMLvPimMLf(kuSG8rdE7yw8cKL7z5WS46W1ZYdzXQHbwGnlk6z53jwWwu4CflE4pyXI6kIfDsbTXYUxGkIfnvtEI(vGuZcSyXowEVrrpogyOVN6ZJbAplVRO6n4NukVZG9nEdvUUIazrlltyXEwW0N1H1cB(JA7IGmcBfyzEMfkOolmzUk7vuwMNzbBrkv(9gf9yd(9E4kflBYsezzklAzzcl6RXWGFVhUszAA0eE31velAzzclylsPYV3OOhBWV3dxPybrSerwMNzXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazzklZZS8UIQ3GHlvgoY)oLhWMWVHkxxrGSOLf91yyOG6SWugdvEBAkXVcZcIyjISOLfkOolmzUkJHkVzrll6RXWGFVhUszAkXVcZcIybnYIwwWwKsLFVrrp2GFVhUsXYMrYccZYuw0YYewSNLEv0a2OiJkAWBhNhkI(RqLrPUelmzOY1veilZZS8xcXcYHfeg9SSjl6RXWGFVhUszAkXVcZccyXowMYIwwEVrrV5Vek)Wm4rSSjlOp(J3cAmo1XaPY1veyC6Jb6H)Gvmq879WvQyGGeo0N1FWkgic197Sa8jLYBw0u9nEwwyIfyXsaKfB7uXstJMW7UUIyrF9SG)tPyXMFpldyZcYhn4TJzXQHbw8cKfqyT9ZYctSOtdytSGmnf2WcW)ukwwyIfDAaBIfKblaqKiwWxfiw(D)zX2PuSy1WalEb)DQzb479WvQyGH(EQppg47kQEd(jLY7myFJ3qLRRiqw0YI(Amm437HRuMMgnH3DDfXIwwMWI9SGPpRdRf28h12fbze2kWY8mluqDwyYCv2ROSmpZc2IuQ87nk6Xg879Wvkw2KfeMLPSOLLjSypl9QObSrrgv0G3oopue9xHkJsDjwyYqLRRiqwMNz5VeIfKdlim6zztwqywMYIwwEVrrV5Vek)Wm4rSSjlrm(J3seeN6yGu56kcmo9Xa9WFWkgi(9E4kvmqqch6Z6pyfdeH6(Dw0un5j6xbsnllmXcW37HRuS8qwqIilwwwS87el6RXGf9OS4kmKLf(kuSa89E4kflWIf0ZcMcWceZcSzrrymlnL4xDfQyGH(EQppgyVkAaBuK5VeYgSRmytEI(vGuBOY1veilAzbBrkv(9gf9yd(9E4kflBgjlrKfTSmHf7zrFngM)siBWUYGn5j6xbsTzzXIww0xJHb)EpCLY00Oj8URRiwMNzzcla8(CDfzaBYtY2oLkpCLkdhdw0YYew0xJHb)EpCLY0uIFfMfeXsezzEMfSfPu53Bu0Jn437HRuSSjl2XIwwExr1BWpPuENb7B8gQCDfbYIww0xJHb)EpCLY0uIFfMfeXc6zzkltzzA8hVLuuCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXaD83UkBbTrnlBYseKglPILjSOblAcly6Z6WAHn)rTDrq2oRalPIL0m2XYuwsfltyrdw0ew0xJH5VeYgSRmytEI(vGuBWVhqILuXsAgnyzklAcltyrFngg879Wvkttj(vywsflrKf0Yc2IuQ8UJFILuXI9S8UIQ3GFsP8od234nu56kcKLPSOjSmHLaeQaH2kd(9E4kLPPe)kmlPILiYcAzbBrkvE3XpXsQy5DfvVb)Ks5DgSVXBOY1veiltzrtyzcl6RXWmwD0mCKj1Qittj(vywsflONLPSOLLjSOVgdd(9E4kLzzXY8mlbiubcTvg879Wvkttj(vywMgdeKWH(S(dwXarMRclL)eMfB70VtnlolaFVXRgfXYctSy7ukwc(ctSa89E4kflpKLHRuSahdnZIxGSSWelaFVXRgfXYdzbjISyrt1KNOFfi1SGFpGellldlrqASCyw(DILMIW11eilBfJqy5HSeC8ZcW3B8Qrria479WvQyGa8oxEcfde)EpCLkBdwFE4kvgogXF8w0iT4uhdKkxxrGXPpgOh(dwXaXV34vJIIbcs4qFw)bRyGPlMyb47nE1OiwSD)olAQM8e9RaPMLhYcsezXYYILFNyrFngSy7(D46zrbXxHIfGV3dxPyzz9xcXIxGSSWelaFVXRgfXcSybHralPhU1uZc(9asyww1FkwqywEVrrpogyOVN6ZJbcW7Z1vKbSjpjB7uQ8WvQmCmyrlla8(CDfzWV3dxPY2G1NhUsLHJblAzXEwa4956kYCOkytz87nE1OiwMNzzcl6RXWO7kVcugoYUsL)9RqHZL)RMm43diXYMSerwMNzrFnggDx5vGYWr2vQ8VFfkC27GxKb)Eajw2KLiYYuw0Yc2IuQ87nk6Xg879WvkwqelimlAzbG3NRRid(9E4kv2gS(8WvQmCmI)4TOHgXPogivUUIaJtFmqp8hSIb6GU1FaOm2M3jXadrdkk)EJIEC8w0igyOVN6ZJbApl)fq6kuSOLf7zXd)blJd6w)bGYyBENKb9ehfzUkpuhQ9NL5zwaHVXbDR)aqzSnVtYGEIJIm43diXcIyjISOLfq4BCq36paugBZ7KmON4Oittj(vywqelrmgiiHd9z9hSIbMUyIfSnVtybdz539NLOWflOONLehXSSS(lHyrpkll8vOy5EwCmlk)jwCmlwqm(0velWIffHXS87EXsezb)EajmlWMLumw4NfB7uXseral43diHzHqS11u8hVfnSlo1XaPY1veyC6Jb6H)GvmWeiSgxtXadrdkk)EJIEC8w0igyOVN6ZJb20Oj8URRiw0YY7nk6n)Lq5hMbpILnzzcltyrdeMfeWYewWwKsLFVrrp2GFVhxtSKkwSJLuXI(AmmuqDwykRwL3MLfltzzkliGLMs8RWSmLf0YYew0GfeWY7kQEZB7QCcewydvUUIazzklAzzclUvoStbKyzEMfaEFUUImhQc2ug)EJxnkIL5zwSNfkOolmzUk7vuwMYIwwMWsacvGqBLj45RcMMCWOSOLfkOolmzUk7vuw0YI9Sa2Rd0uWCaeZIwwMWcaVpxxrMaSaarIYGeoAfyzEMLaeQaH2ktawaGir5FNYyRRVhBAYbJYY8ml2ZsacGkVEtDO2)8WjwMYY8mlylsPYV3OOhBWV3JRjwqeltyzclixw0ewMWI(AmmuqDwykRwL3MLflPIf7yzkltzjvSmHfnybbS8UIQ382UkNaHf2qLRRiqwMYYuw0YI9Sqb1zHjdgQ8oxeIFw0YI9SeGqfi0wzcE(QGPjhmklZZSmHfkOolmzUkJHkVzzEMf91yyOG6SWuwTkVnllw0YI9S8UIQ3GHlvgoY)oLhWMWVHkxxrGSmpZI(Ammw9LaBWZvzVdEDHS1sH92aWvlILnJKf7qFASmLfTSmHfSfPu53Bu0Jn437X1eliIfnsJLuXYew0GfeWY7kQEZB7QCcewydvUUIazzkltzrllo(BxLTG2OMLnzb9PXIMWI(Amm437HRuMMs8RWSKkwqUSmLfTSmHf7zjabqLxVbPO95flZZSypl6RXWG0vGnbMPelOnQtO6ZurnQlLKzzXY8mluqDwyYCvgdvEZYuw0YI9SOVgdt7aOcUW5rtvkJMXxnwQ8Eu8t95MLvmqqch6Z6pyfdeHgnAcVZIMgewJRjwUbliBROnDQalhMLMCWOAMLFNAIfVjwuegZYV7flONL3Bu0Jz5kwq(v5nlOtqDwyIfB3VZcq4Jg0mlkcJz539IfnsJf4VtTTdtSCflEfLf0jOolmXcSzzzXYdzb9S8EJIEml60a2eloli)Q8Mf0jOolmzyrtbRTFwAA0eENfWvFfkwsXDfytGSGojwqBuNq1ZYQuegZYvSaeQ8Mf0jOolmf)XBrJigN6yGu56kcmo9Xa9WFWkg4a2bkdh5Y)vtXabjCOpR)GvmW0ftSGgGBHfyXsaKfB3Vdxplb3Y6kuXad99uFEmq3kh2PasSmpZcaVpxxrMdvbBkJFVXRgff)XBrdeoo1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyG2ZcyVoqtbZbqmlAzzcla8(CDfzcG5aSaV)GflAzzcl6RXWGFVhUszwwSmpZY7kQEd(jLY7myFJ3qLRRiqwMNzjabqLxVPou7FE4eltzrllGW3KaH14AY8xaPRqXIwwMWI9SOVgddgQW)fiZYIfTSypl6RXWe88vbZYIfTSmHf7z5DfvVzS6Oz4itQvrgQCDfbYY8ml6RXWe88vbd4Q9)GflBYsacvGqBLzS6Oz4itQvrMMs8RWSGawIawMYIwwMWI9SGPpRdRf28h12fbz7ScSmpZcfuNfMmxLvRYBwMNzHcQZctgmu5DUie)SmLfTSaW7Z1vK537tPYyIqI6Sn)Ew0YYewSNLaeavE9M6qT)5HtSmpZsacvGqBLjalaqKO8VtzS113JnnL4xHzbrSOVgdtWZxfmGR2)dwSKkwsZGEwMYIwwEVrrV5Vek)Wm4rSSjl6RXWe88vbd4Q9)GflPIL0mOrwMYY8ml6qmMfTSmou7FUPe)kmliIf91yycE(QGbC1(FWIfeWIg2XsQyPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazzAmqaENlpHIbgaZbybE)bRSdP4pElAG(4uhdKkxxrGXPpgOh(dwXaBhavWfopAQsz0yGGeo0N1FWkgy6IjwqdnvPmkl2UFNfKTv0MovigyOVN6ZJbQVgdtWZxfmnL4xHzztw0a9SmpZI(AmmbpFvWaUA)pyXccyrd7yjvS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSGiwSd5YIwwa4956kYeaZbybE)bRSdP4pElAGCJtDmqQCDfbgN(yGE4pyfdmqkc)NRYU6qvju9XabjCOpR)GvmW0ftSGSTI20PcSalwcGSSkfHXS4filQRiwUNLLfl2UFNfKblaqKOyGH(EQppgiaVpxxrMayoalW7pyLDiXIwwMWI(AmmbpFvWaUA)pyXccyrd7yjvS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSSzKSyhYLL5zwSNLaeavE9gau97rBwMYY8ml6RXW0oaQGlCE0uLYOMLflAzrFngM2bqfCHZJMQug10uIFfMfeXskIfeWsawGR7nwnfomLD1HQsO6n)LqzaUArSGawMWI9SOVgdJUccbvl8BwwSOLf7z5DfvVb)ERGnOHkxxrGSmn(J3IgOX4uhdKkxxrGXPpgyOVN6ZJbcW7Z1vKjaMdWc8(dwzhsXa9WFWkg4vbVl)pyf)XBrJiio1XaPY1veyC6Jb6H)GvmqkXcAJ6SoSaJbcs4qFw)bRyGPlMybDsSG2OML0dlqwGflbqwSD)olaFVhUsXYYIfVazb7aiwgWMfeYsH9MfVazbzBfTPtfIbg67P(8yGtyjaHkqOTYe88vbttj(vywqal6RXWe88vbd4Q9)GfliGLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLuXIg2XYMSeGqfi0wzOelOnQZ6Wc0aUA)pyXccyrJ0yzklZZSOVgdtWZxfmnL4xHzztwIawMNzbSxhOPG5aio(J3IgPO4uhdKkxxrGXPpgOh(dwXaXpPuENhkVPyGHObfLFVrrpoElAedm03t95XaBA0eE31velAz5Vek)Wm4rSSjlAGEw0Yc2IuQ87nk6Xg8794AIfeXccZIwwCRCyNciXIwwMWI(AmmbpFvW0uIFfMLnzrJ0yzEMf7zrFngMGNVkywwSmngiiHd9z9hSIbIqJgnH3zzO8MybwSSSy5HSerwEVrrpMfB3VdxpliBROnDQal60vOyX1HRNLhYcHyRRjw8cKLc(SabqDWTSUcv8hVf7slo1XaPY1veyC6Jb6H)GvmWXQJMHJmPwffdeKWH(S(dwXatxmXcAaIoSCdwUcFGelEXc6euNfMyXlqwuxrSCplllwSD)ololiKLc7nlwnmWIxGSSvq36paelaT5DsmWqFp1NhdKcQZctMRYEfLfTSmHf3kh2PasSmpZI9S0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSmLfTSmHf91yyS6lb2GNRYEh86czRLc7TbGRweliIf7qFASmpZI(AmmbpFvW0uIFfMLnzjcyzklAzzclGW34GU1FaOm2M3jzqpXrrM)ciDfkwMNzXEwcqau51Bkk0qfSbzzEMfSfPu53Bu0JzztwSJLPSOLLjSOVgdt7aOcUW5rtvkJAAkXVcZcIyjfXIMWYewqywsfl9QObSrrg8vJLkVhf)uFUHkxxrGSmLfTSOVgdt7aOcUW5rtvkJAwwSmpZI9SOVgdt7aOcUW5rtvkJAwwSmLfTSmHf7zjaHkqOTYe88vbZYIL5zw0xJH537tPYyIqIAd(9asSGiw0a9SOLLXHA)ZnL4xHzbrSyxAPXIwwghQ9p3uIFfMLnzrJ0sJL5zwSNfmCP0Vc0879PuzmrirTHkxxrGSmLfTSmHfmCP0Vc0879PuzmrirTHkxxrGSmpZsacvGqBLj45RcMMs8RWSSjlrmnwMYIwwEVrrV5Vek)Wm4rSSjlONL5zw0HymlAzzCO2)Ctj(vywqelAKw8hVf70io1XaPY1veyC6Jb6H)Gvmq879WvQyGGeo0N1FWkgy6IjwCwa(EpCLIfn9I(DwSAyGLvPimMfGV3dxPy5WS4QMCWOSSSyb2SefUyXBIfxhUEwEilqauhClw2kgHedm03t95Xa1xJHbw0VJZwuhiR)GLzzXIwwMWI(Amm437HRuMMgnH3DDfXY8mlo(BxLTG2OMLnzjfLgltJ)4TyNDXPogivUUIaJtFmqp8hSIbIFVhUsfdeKWH(S(dwXa1uRelw2kgHWIonGnXcYGfaisel2UFNfGV3dxPyXlqw(DQyb47nE1OOyGH(EQppgyacGkVEtDO2)8Wjw0YI9S8UIQ3GFsP8od234nu56kcKfTSmHfaEFUUImbybaIeLbjC0kWY8mlbiubcTvMGNVkywwSmpZI(AmmbpFvWSSyzklAzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSGiwqfanjoIzjvSeOtXYewC83UkBbTrnlOLf0Ngltzrll6RXWGFVhUszAkXVcZcIybHzrll2ZcyVoqtbZbqC8hVf7IyCQJbsLRRiW40hdm03t95Xadqau51BQd1(NhoXIwwMWcaVpxxrMaSaarIYGeoAfyzEMLaeQaH2ktWZxfmllwMNzrFngMGNVkywwSmLfTSeGqfi0wzcWcaejk)7ugBD99yttj(vywqelONfTSaW7Z1vKb)EpCLkBdwFE4kvgogSOLfkOolmzUk7vuw0YI9SaW7Z1vK5qvWMY43B8QrrSOLf7zbSxhOPG5aiogOh(dwXaXV34vJII)4TyhchN6yGu56kcmo9Xa9WFWkgi(9gVAuumqqch6Z6pyfdmDXelaFVXRgfXIT73zXlw00l63zXQHbwGnl3GLOW12GSabqDWTyzRyecl2UFNLOWvZsri(zj443WYwvyilGRelw2kgHWI)S87elubYcCWYVtSKILQFpAZI(Amy5gSa89E4kfl2GlfyT9ZYWvkwGJblWMLOWflEtSalwSJL3Bu0JJbg67P(8yG6RXWal63X5GI8od4WhSmllwMNzzcl2Zc(9ECnzCRCyNciXIwwSNfaEFUUImhQc2ug)EJxnkIL5zwMWI(AmmbpFvW0uIFfMfeXc6zrll6RXWe88vbZYIL5zwMWYew0xJHj45RcMMs8RWSGiwqfanjoIzjvSeOtXYewC83UkBbTrnlOLfaEFUUImyCoaXpltzrll6RXWe88vbZYIL5zw0xJHPDaubx48OPkLrZ4RglvEpk(P(Cttj(vywqelOcGMehXSKkwc0Pyzclo(BxLTG2OMf0YcaVpxxrgmohG4NLPSOLf91yyAhavWfopAQsz0m(QXsL3JIFQp3SSyzklAzjabqLxVbav)E0MLPSmLfTSmHfSfPu53Bu0Jn437HRuSGiwIilZZSaW7Z1vKb)EpCLkBdwFE4kvgogSmLLPSOLf7zbG3NRRiZHQGnLXV34vJIyrlltyXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazzEMfSfPu53Bu0Jn437HRuSGiwIiltJ)4Tyh6JtDmqQCDfbgN(yGE4pyfdSiB5eiSIbcs4qFw)bRyGPlMyrtdclmlxXcqOYBwqNG6SWelEbYc2bqSGgwkflAAqyXYa2SGSTI20PcXad99uFEmWjSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeIL5zwMWsy3BueMLizXow0YstHDVrr5)siwqelONLPSmpZsy3BueMLizjISmLfTS4w5Wofqk(J3IDi34uhdKkxxrGXPpgyOVN6ZJboHf91yyOG6SWugdvEBAkXVcZYMSqiMcRNY)LqSmpZYewc7EJIWSejl2XIwwAkS7nkk)xcXcIyb9SmLL5zwc7EJIWSejlrKLPSOLf3kh2PasSOLLjSOVgdt7aOcUW5rtvkJAAkXVcZcIyb9SOLf91yyAhavWfopAQszuZYIfTSypl9QObSrrg8vJLkVhf)uFUHkxxrGSmpZI9SOVgdt7aOcUW5rtvkJAwwSmngOh(dwXa3D1iNaHv8hVf7qJXPogivUUIaJtFmWqFp1NhdCcl6RXWqb1zHPmgQ820uIFfMLnzHqmfwpL)lHyrlltyjaHkqOTYe88vbttj(vyw2Kf0NglZZSeGqfi0wzcWcaejk)7ugBD99yttj(vyw2Kf0NgltzzEMLjSe29gfHzjswSJfTS0uy3Buu(VeIfeXc6zzklZZSe29gfHzjswIiltzrllUvoStbKyrlltyrFngM2bqfCHZJMQug10uIFfMfeXc6zrll6RXW0oaQGlCE0uLYOMLflAzXEw6vrdyJIm4RglvEpk(P(CdvUUIazzEMf7zrFngM2bqfCHZJMQug1SSyzAmqp8hSIbowkvobcR4pEl2fbXPogivUUIaJtFmqqch6Z6pyfdmDXeliuq0HfyXcY0uXa9WFWkgOnV7d2z4itQvrXF8wSlffN6yGu56kcmo9XaHwXaX0hd0d)bRyGa8(CDffdeGRwumqSfPu53Bu0Jn437X1elBYccZccyzOGWMLjSK44N6OzaUArSKkw0iT0ybTSyxASmLfeWYqbHnltyrFngg87nE1OOmLybTrDcvFgdvEBWVhqIf0YccZY0yGGeo0N1FWkgiYCvyP8NWSyBN(DQz5HSSWelaFVhxtSCflaHkVzX2(f2z5WS4plONL3Bu0JrGgSmGnleaQJYIDPHCyjXXp1rzb2SGWSa89gVAuelOtIf0g1ju9SGFpGeogiaVZLNqXaXV3JRP8vzmu5D8hVLiMwCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXa1Gf0Yc2IuQ8UJFIfeXIDSOjSmHL0m2XsQyzclylsPYV3OOhBWV3JRjw0ew0GLPSKkwMWIgSGawExr1BWWLkdh5FNYdyt43qLRRiqwsflAyqpltzzkliGL0mAGEwsfl6RXW0oaQGlCE0uLYOMMs8RWXabjCOpR)GvmqK5QWs5pHzX2o97uZYdzbHQ9FNfWvFfkwqdnvPmAmqaENlpHIbAR9FpFvE0uLYOXF8wIOgXPogivUUIaJtFmqp8hSIbAR9FpgiiHd9z9hSIbMUyIfeQ2)DwUIfGqL3SGob1zHjwGnl3GLcYcW37X1el2oLILX9SC1dzbzBfTPtfyXROjWMIbg67P(8yGtyHcQZctg1Q8oxeIFwMNzHcQZctgVIMlcXplAzbG3NRRiZHZbf5aiwMYIwwMWY7nk6n)Lq5hMbpILnzbHzzEMfkOolmzuRY78vz7yzEMfDigZIwwghQ9p3uIFfMfeXIgPXYuwMNzrFnggkOolmLXqL3MMs8RWSGiw8WFWYGFVhxtgcXuy9u(VeIfTSOVgddfuNfMYyOYBZYIL5zwOG6SWK5QmgQ8MfTSypla8(CDfzWV3JRP8vzmu5nlZZSOVgdtWZxfmnL4xHzbrS4H)GLb)EpUMmeIPW6P8FjelAzXEwa4956kYC4CqroaIfTSOVgdtWZxfmnL4xHzbrSqiMcRNY)LqSOLf91yycE(QGzzXY8ml6RXW0oaQGlCE0uLYOMLflAzbG3NRRiJT2)98v5rtvkJYY8ml2ZcaVpxxrMdNdkYbqSOLf91yycE(QGPPe)kmlBYcHykSEk)xcf)XBjI2fN6yGu56kcmo9XabjCOpR)GvmW0ftSa89ECnXYny5kwq(v5nlOtqDwysZSCflaHkVzbDcQZctSalwqyeWY7nk6XSaBwEilwnmWcqOYBwqNG6SWumqp8hSIbIFVhxtXF8wIyeJtDmqQCDfbgN(yGGeo0N1FWkgiAWvQFVxXa9WFWkgyVQSh(dwz1H)yGQd)5YtOyGdxP(9Ef)XFmWHRu)EVItD8w0io1XaPY1veyC6Jb6H)Gvmq87nE1OOyGGeo0N1FWkgiW3B8QrrSmGnljqaucvplRsrymll8vOyj9WTM6yGH(EQppgO9S0RIgWgfz0DLxbkdhzxPY)(vOWgkcxNLfbg)XBXU4uhdKkxxrGXPpgOh(dwXaXRACnfdmenOO87nk6XXBrJyGH(EQppgii8njqynUMmnL4xHzztwAkXVcZsQyXo7ybTSOreedeKWH(S(dwXarMJFw(DIfq4ZIT73z53jwsG4NL)siwEiloiilR6pfl)oXsIJywaxT)hSy5WSSFVHfGRACnXstj(vywswQ)SuhbYYdzjX)WoljqynUMybC1(FWk(J3seJtDmqp8hSIbMaH14AkgivUUIaJtF8h)XaXFCQJ3IgXPogivUUIaJtFmqp8hSIb6GU1FaOm2M3jXadrdkk)EJIEC8w0igyOVN6ZJbAplGW34GU1FaOm2M3jzqpXrrM)ciDfkw0YI9S4H)GLXbDR)aqzSnVtYGEIJImxLhQd1(ZIwwMWI9SacFJd6w)bGYyBENK3jxz(lG0vOyzEMfq4BCq36paugBZ7K8o5kttj(vyw2Kf0ZYuwMNzbe(gh0T(daLX28ojd6jokYGFpGeliILiYIwwaHVXbDR)aqzSnVtYGEIJImnL4xHzbrSerw0Yci8noOB9hakJT5Dsg0tCuK5VasxHkgiiHd9z9hSIbMUyILTc6w)bGybOnVtyX2ovS87utSCywkilE4paelyBENOzwCmlk)jwCmlwqm(0velWIfSnVtyX297SyhlWMLbzJAwWVhqcZcSzbwS4SereWc2M3jSGHS87(ZYVtSuKnwW28oHfV7daHzjfJf(zXhp1S87(Zc2M3jSqi26Ach)XBXU4uhdKkxxrGXPpgOh(dwXadWcaejk)7ugBD994yGGeo0N1FWkgy6IjmlidwaGirSCdwq2wrB6ubwomlllwGnlrHlw8MybKWrRWvOybzBfTPtfyX297SGmybaIeXIxGSefUyXBIfDsbTXccNgAJyAtqgPi8FUIfGwxFpEklBfJqy5kwCw0ineWcMcSGob1zHjdlBvHHSacRTFwu0ZIMQjpr)kqQzHqS11KMzXv28OywwyILRybzBfTPtfyX297SGqwkS3S4fil(ZYVtSGFVFwGdwCwspCRPMfBxbcTzIbg67P(8yG2ZcyVoqtbZbqmlAzzcltybG3NRRitawaGirzqchTcSOLf7zjaHkqOTYe88vbttoyuw0YI9S0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSmpZI(AmmbpFvWSSyzklAzzcltyXXF7QSf0g1SGOizbG3NRRitawaGirzhBXIwwMWI(AmmuqDwykRwL3MMs8RWSSjlAKglZZSOVgddfuNfMYyOYBttj(vyw2KfnsJLPSmpZI(AmmbpFvW0uIFfMLnzb9SOLf91yycE(QGPPe)kmliksw0WowMYIwwMWI9S0RIgWgfz(lHSb7kd2KNOFfi1gQCDfbYY8ml2ZsVkAaBuKjqkc)NRYyRRVhBOY1veilZZSOVgdZFjKnyxzWM8e9RaP20uIFfMLnzHqmfwpL)lHyzklZZS0RIgWgfz0DLxbkdhzxPY)(vOWgQCDfbYYuw0YYewSNLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMNzzcl6RXWO7kVcugoYUsL)9RqHZL)RMm43diXsKSebSmpZI(Amm6UYRaLHJSRu5F)ku4S3bVid(9asSejlraltzzklZZSOdXyw0YY4qT)5Ms8RWSGiw0inw0YI9SeGqfi0wzcE(QGPjhmkltJ)4TeX4uhdKkxxrGXPpgOh(dwXaXV34vJIIbcs4qFw)bRyGPlMyb47nE1OiwEilirKflllw(DIfnvtEI(vGuZI(Amy5gSCpl2GlfileITUMyrNgWMyzC1H3Vcfl)oXsri(zj44NfyZYdzbCLyXIonGnXcYGfaisumWqFp1NhdSxfnGnkY8xczd2vgSjpr)kqQnu56kcKfTSmHf7zzcltyrFngM)siBWUYGn5j6xbsTPPe)kmlBYIh(dwgBT)7gcXuy9u(VeIfeWsAgnyrlltyHcQZctMRY6WFNL5zwOG6SWK5QmgQ8ML5zwOG6SWKrTkVZfH4NLPSmpZI(Amm)Lq2GDLbBYt0VcKAttj(vyw2Kfp8hSm437X1KHqmfwpL)lHybbSKMrdw0YYewOG6SWK5QSAvEZY8mluqDwyYGHkVZfH4NL5zwOG6SWKXRO5Iq8ZYuwMYY8ml2ZI(Amm)Lq2GDLbBYt0VcKAZYILPSmpZYew0xJHj45RcMLflZZSaW7Z1vKjalaqKOmiHJwbwMYIwwcqOceARmbybaIeL)DkJTU(ESPjhmklAzjabqLxVPou7FE4elAzzcl6RXWqb1zHPSAvEBAkXVcZYMSOrASmpZI(AmmuqDwykJHkVnnL4xHzztw0inwMYYuw0YYewSNLaeavE9gKI2NxSmpZsacvGqBLHsSG2OoRdlqttj(vyw2KLiGLPXF8wq44uhdKkxxrGXPpgOh(dwXaXV34vJIIbcs4qFw)bRyGAQvIflaFVXRgfHzX297SKEx5vGyboyzRkflPE)kuywGnlpKfRMS8MyzaBwqgSaarIyX297SKE4wtDmWqFp1NhdSxfnGnkYO7kVcugoYUsL)9RqHnu56kcKfTSmHLjSOVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGelBYIDSmpZI(Amm6UYRaLHJSRu5F)ku4S3bVid(9asSSjl2XYuw0YsacvGqBLj45RcMMs8RWSSjlOrw0YI9SeGqfi0wzcWcaejk)7ugBD99yZYIL5zwMWsacGkVEtDO2)8Wjw0YsacvGqBLjalaqKO8VtzS113JnnL4xHzbrSOrASOLfkOolmzUk7vuw0YIJ)2vzlOnQzztwSlnwqalrmnwsflbiubcTvMGNVkyAYbJYYuwMg)XBb9XPogivUUIaJtFmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdCcl6RXW0oaQGlCE0uLYOMMs8RWSSjlONL5zwSNf91yyAhavWfopAQszuZYILPSOLf7zrFngM2bqfCHZJMQugnJVASu59O4N6Znllw0YYew0xJHbPRaBcmtjwqBuNq1NPIAuxkjttj(vywqelOcGMehXSmLfTSmHf91yyOG6SWugdvEBAkXVcZYMSGkaAsCeZY8ml6RXWqb1zHPSAvEBAkXVcZYMSGkaAsCeZY8mltyXEw0xJHHcQZctz1Q82SSyzEMf7zrFnggkOolmLXqL3MLfltzrll2ZY7kQEdgQW)fidvUUIazzAmqqch6Z6pyfdezWc8(dwSmGnlUsXci8XS87(ZsIJeHzbVAILFNIYI3uT9ZstJMW7eil22PIfeAoaQGlmlOHMQugLLDhZIIWyw(DVyb9SGPaMLMs8RUcflWMLFNybDsSG2OML0dlqw0xJblhMfxhUEwEildxPybogSaBw8kklOtqDwyILdZIRdxplpKfcXwxtXab4DU8ekgii8ZnfHRRPeQEC8hVfKBCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXaNWI9SOVgddfuNfMYyOYBZYIfTSypl6RXWqb1zHPSAvEBwwSmLfTSyplVRO6nyOc)xGmu56kcKfTSypl9QObSrrM)siBWUYGn5j6xbsTHkxxrGXabjCOpR)GvmqKblW7pyXYV7plHDkGeMLBWsu4IfVjwGRhFGeluqDwyILhYcSurzbe(S87utSaBwoufSjw(9dZIT73zbiuH)lqXab4DU8ekgii8ZW1Jpqktb1zHP4pElOX4uhdKkxxrGXPpgOh(dwXatGWACnfdmenOO87nk6XXBrJyGH(EQppg4ew0xJHHcQZctzmu5TPPe)kmlBYstj(vywMNzrFnggkOolmLvRYBttj(vyw2KLMs8RWSmpZcaVpxxrgq4NHRhFGuMcQZctSmLfTS00Oj8URRiw0YY7nk6n)Lq5hMbpILnzrd7yrllUvoStbKyrlla8(CDfzaHFUPiCDnLq1JJbcs4qFw)bRyGAk4ZIRuS8EJIEml2UF)kwqiEbsjxGfB3VdxplqauhClRRqHGFNyX1HaiwcWc8(dw44pElrqCQJbsLRRiW40hd0d)bRyG4vnUMIbg67P(8yGtyrFnggkOolmLXqL3MMs8RWSSjlnL4xHzzEMf91yyOG6SWuwTkVnnL4xHzztwAkXVcZY8mla8(CDfzaHFgUE8bszkOolmXYuw0YstJMW7UUIyrllV3OO38xcLFyg8iw2KfnSJfTS4w5WofqIfTSaW7Z1vKbe(5MIW11ucvpogyiAqr53Bu0JJ3IgXF8wsrXPogivUUIaJtFmqp8hSIbIFsP8opuEtXad99uFEmWjSOVgddfuNfMYyOYBttj(vyw2KLMs8RWSmpZI(AmmuqDwykRwL3MMs8RWSSjlnL4xHzzEMfaEFUUImGWpdxp(aPmfuNfMyzklAzPPrt4DxxrSOLL3Bu0B(lHYpmdEelBYIgixw0YIBLd7uajw0YcaVpxxrgq4NBkcxxtju94yGHObfLFVrrpoElAe)XBrJ0ItDmqQCDfbgN(yGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgyacGkVEdaQ(9OnlAzXEw6vrdyJIm4RglvEpk(P(CdvUUIazrll2ZsVkAaBuKjCDqrz4iRUbL9cmds(VBOY1veilAzjaHkqOTYOtnMAKUcLPjhmklAzjaHkqOTY0oaQGlCE0uLYOMMCWOSOLf7zrFngMGNVkywwSOLLjS44VDv2cAJAw2KLianYY8ml6RXWORGqq1c)MLfltJbcs4qFw)bRyGAk4ZsFO2Fw0PbSjwqdnvPmkl3GL7zXgCPazXvkOnwIcxS8qwAA0eENffHXSaU6RqXcAOPkLrzzYVFywGLkkl7ULfvywSD)oC9Sa8QXsXcc9rXp1NpngiaVZLNqXalyEpk(P(8m5TkAge(XF8w0qJ4uhdKkxxrGXPpgyOVN6ZJbcW7Z1vKPG59O4N6ZZK3QOzq4ZIwwAkXVcZcIyXU0Ib6H)GvmWeiSgxtXF8w0WU4uhdKkxxrGXPpgyOVN6ZJbcW7Z1vKPG59O4N6ZZK3QOzq4ZIwwAkXVcZcIyrJuumqp8hSIbIx14Ak(J3Igrmo1XaPY1veyC6Jb6H)GvmWbSdugoYL)RMIbcs4qFw)bRyGPlMybna3clWILail2UFhUEwcUL1vOIbg67P(8yGUvoStbKI)4TObchN6yGu56kcmo9Xa9WFWkgiLybTrDwhwGXabjCOpR)GvmW0ftSGojwqBuZs6Hfil2UFNfVIYIcwOyHk4c1olkh)xHIf0jOolmXIxGS8DuwEilQRiwUNLLfl2UFNfeYsH9MfVazbzBfTPtfIbg67P(8yGtyjaHkqOTYe88vbttj(vywqal6RXWe88vbd4Q9)GfliGLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLuXIg2XYMSeGqfi0wzOelOnQZ6Wc0aUA)pyXccyrJ0yzklZZSOVgdtWZxfmnL4xHzztwIawMNzbSxhOPG5aio(J3IgOpo1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyGo(BxLTG2OMLnzjfLglAcltyXod6zjvSOVgdZy1rZWrMuRIm43diXIMWIDSKkwOG6SWK5QSAvEZY0yGGeo0N1FWkgiq6XSyBNkw2kgHWcEhUuGSOtSaUsSiqwEilf8zbcG6GBXYenfzrfiMfyXcAy1rzboybDuRIyXlqw(DIf0jOolmnngiaVZLNqXaDSvgCLyf)XBrdKBCQJbsLRRiW40hdeAfdetFmqp8hSIbcW7Z1vumqaUArXaTNfWEDGMcMdGyw0YYewa4956kYeaZbybE)blw0YI9SOVgdtWZxfmllw0YYewSNfm9zDyTWM)O2UiiBNvGL5zwOG6SWK5QSAvEZY8mluqDwyYGHkVZfH4NLPSOLLjSmHLjSaW7Z1vKXXwzWvIflZZSeGaOYR3uhQ9ppCIL5zwMWsacGkVEdsr7Zlw0YsacvGqBLHsSG2OoRdlqttoyuwMYY8ml9QObSrrM)siBWUYGn5j6xbsTHkxxrGSmLfTSacFdEvJRjttj(vyw2KLiGfTSacFtcewJRjttj(vyw2KLuelAzzclGW3GFsP8opuEtMMs8RWSSjlAKglZZSyplVRO6n4NukVZdL3KHkxxrGSmLfTSaW7Z1vK537tPYyIqI6Sn)Ew0YY7nk6n)Lq5hMbpILnzrFngMGNVkyaxT)hSyjvSKMbnYY8ml6RXWORGqq1c)MLflAzrFnggDfecQw430uIFfMfeXI(AmmbpFvWaUA)pyXccyzclAyhlPILEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLPSmLL5zwMWcfHRZYIanuIv0MCvg2GLxbIfTSeGqfi0wzOeROn5QmSblVcKPPe)kmliIfnqUOrwqaltyb9SKkw6vrdyJIm4RglvEpk(P(CdvUUIazzkltzzklAzzcl2ZsacGkVEtDO2)8WjwMNzzclbiubcTvMaSaarIY)oLXwxFp20uIFfMfeXI(AmmbpFvWaUA)pyXcAzXow0YI9S0RIgWgfz0DLxbkdhzxPY)(vOWgQCDfbYY8mlbiubcTvMaSaarIY)oLXwxFp20KdgLfTS44VDv2cAJAwqelOpnwMYY8ml6qmMfTSmou7FUPe)kmliILaeQaH2ktawaGir5FNYyRRVhBAkXVcZYuwMNzrhIXSOLLXHA)ZnL4xHzbrSOVgdtWZxfmGR2)dwSGaw0Wowsfl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veiltJbcs4qFw)bRyGPlMybzBfTPtfyX297SGmybaIeH2uCxb2eilaTU(EmlEbYciS2(zbcGAB99eliKLc7nlWMfB7uXs6vqiOAHFwSbxkqwieBDnXIonGnXcY2kAtNkWcHyRRjSHfnnhjIf8QjwEilu9uZIZcYVkVzbDcQZctSyBNkww4dvXsQTlcyXoRalEbYIRuSGmnfMfBNsXIofGjeln5GrzbdHflubxO2zbC1xHILFNyrFngS4filGWhZYUdGyrNOIf8AmUWr1RIYstJMW7eOjgiaVZLNqXadG5aSaV)Gvg)XF8w0angN6yGu56kcmo9Xa9WFWkgy7aOcUW5rtvkJgdeKWH(S(dwXatxmXcAOPkLrzX297SGSTI20PcSSkfHXSGgAQszuwSbxkqwuo(zrbluuZYV7fliBROnDQGMz53PILfMyrNgWMIbg67P(8yG6RXWe88vbttj(vyw2KfnqplZZSOVgdtWZxfmGR2)dwSGiwSdnYccyPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazjvSOHDSOLfaEFUUImbWCawG3FWkJ)4pElAebXPogivUUIaJtFmWqFp1NhdeG3NRRitamhGf49hSY4NfTSmHf91yycE(QGbC1(FWILnJKf7qJSGaw6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqwsflAyhlZZSyplbiaQ86naO63J2SmLL5zw0xJHPDaubx48OPkLrnllw0YI(AmmTdGk4cNhnvPmQPPe)kmliILueliGLaSax3BSAkCyk7QdvLq1B(lHYaC1IybbSmHf7zrFnggDfecQw43SSyrll2ZY7kQEd(9wbBqdvUUIazzAmqp8hSIbgifH)ZvzxDOQeQ(4pElAKIItDmqQCDfbgN(yGH(EQppgiaVpxxrMayoalW7pyLXFmqp8hSIbEvW7Y)dwXF8wSlT4uhdKkxxrGXPpgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbgGqfi0wzcE(QGPPe)kmlBYIgPXY8ml2ZcaVpxxrMaSaarIYGeoAfyrllbiaQ86n1HA)ZdNyzEMfWEDGMcMdG4yGGeo0N1FWkgykwVpxxrSSWeilWIfx)u3FeMLF3FwS51ZYdzrNyb7aiqwgWMfKTv0MovGfmKLF3Fw(DkklEt1ZInh)eilPySWpl60a2el)oLedeG35YtOyGyhaLhWoh88vH4pEl2PrCQJbsLRRiW40hd0d)bRyGJvhndhzsTkkgiiHd9z9hSIbMUycZcAaIoSCdwUIfVybDcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1mliBROnDQGMzbDsSG2OML0dlqw8cKLTc6w)bGybOnVtIbg67P(8yGuqDwyYCv2ROSOLLjS44VDv2cAJAwqelPi7yrtyrFngMXQJMHJmPwfzWVhqILuXc6zzEMf91yyAhavWfopAQszuZYILPSOLLjSOVgdJvFjWg8Cv27GxxiBTuyVnaC1IybrSyhcNglZZSOVgdtWZxfmnL4xHzztwIawMYIwwa4956kYGDauEa7CWZxfyrlltyXEwcqau51Bkk0qfSbzzEMfq4BCq36paugBZ7KmON4OiZFbKUcfltzrlltyXEwcqau51Baq1VhTzzEMf91yyAhavWfopAQszuttj(vywqelPiw0ewMWccZsQyPxfnGnkYGVASu59O4N6Znu56kcKLPSOLf91yyAhavWfopAQszuZYIL5zwSNf91yyAhavWfopAQszuZYILPSOLLjSyplbiaQ86nifTpVyzEMLaeQaH2kdLybTrDwhwGMMs8RWSSjl2LgltzrllV3OO38xcLFyg8iw2Kf0ZY8ml6qmMfTSmou7FUPe)kmliIfnsl(J3ID2fN6yGu56kcmo9Xa9WFWkgi(9E4kvmqqch6Z6pyfdmDXelA6f97Sa89E4kflwnmGz5gSa89E4kflhU2(zzzfdm03t95Xa1xJHbw0VJZwuhiR)GLzzXIww0xJHb)EpCLY00Oj8URRO4pEl2fX4uhdKkxxrGXPpgOh(dwXadEfivwFngXad99uFEmq91yyWV3kydAAkXVcZcIyb9SOLLjSOVgddfuNfMYyOYBttj(vyw2Kf0ZY8ml6RXWqb1zHPSAvEBAkXVcZYMSGEwMYIwwC83UkBbTrnlBYskkTyG6RXixEcfde)ERGnymqqch6Z6pyfdezEfiflaFVvWgKLBWY9SS7ywuegZYV7flOhZstj(vxHsZSefUyXBIf)zjfLgcyzRyeclEbYYVtSewDt1Zc6euNfMyz3XSGEeGzPPe)QRqf)XBXoeoo1XaPY1veyC6Jb6H)GvmWGxbsL1xJrmWqFp1Nhd8DfvV5QG3L)hSmu56kcKfTSyplVRO6nfzlNaHLHkxxrGSOLLu8yzcltyjIPLglAclo(BxLTG2OMfeWccNglAcly6Z6WAHn)rTDrq2oRalPIfeonwMYcAzzclimlOLfSfPu5Dh)eltzrtyjaHkqOTYeGfaisu(3Pm2667XMMs8RWSmLfeXskESmHLjSeX0sJfnHfh)TRYwqBuZIMWI(Ammw9LaBWZvzVdEDHS1sH92aWvlIfeWccNglAcly6Z6WAHn)rTDrq2oRalPIfeonwMYcAzzclimlOLfSfPu5Dh)eltzrtyjaHkqOTYeGfaisu(3Pm2667XMMs8RWSmLfTSeGqfi0wzcE(QGPPe)kmlBYsetJfTSOVgdJvFjWg8Cv27GxxiBTuyVnaC1IybrSyNgPXIww0xJHXQVeydEUk7DWRlKTwkS3gaUArSSjlrmnw0YsacvGqBLjalaqKO8VtzS113JnnL4xHzbrSGWPXIwwghQ9p3uIFfMLnzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSGawqUSOLLjS0RIgWgfzcKIW)5Qm2667XgQCDfbYY8mla8(CDfzcWcaejkds4OvGLPXa1xJrU8ekgOvFjWg8Cv27GxxiBTuyVJbcs4qFw)bRyGiZRaPy53jwqilf2Bw0xJbl3GLFNyXQHbwSbxkWA7Nf1velllwSD)ol)oXsri(z5VeIfKblaqKiwcWecZcCmyjaAyj17hMLfE5kvuwGLkkl7ULfvywax9vOy53jwspYBI)4Tyh6JtDmqQCDfbgN(yGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgyacGkVEtDO2)8Wjw0YsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYIww0xJHXQVeydEUk7DWRlKTwkS3gaUArSGawC83UkBbTrnliGLiYYMrYsetlnw0YcaVpxxrMaSaarIYGeoAfyrllbiubcTvMaSaarIY)oLXwxFp20uIFfMfeXIJ)2vzlOnQzbTSeX0yjvSGkaAsCeZIwwSNfWEDGMcMdGyw0YcfuNfMmxL9kklAzXXF7QSf0g1SSjla8(CDfzcWcaejk7ylw0YsacvGqBLj45RcMMs8RWSSjlOpgiiHd9z9hSIbcKEml22PIfeYsH9Mf8oCPazrNyXQHHabYc5TkklpKfDIfxxrS8qwwyIfKblaqKiwGflbiubcTvSmbDWyQ(ZvQOSOtbycHz57fXYnybCLyDfkw2kgHWsbTXITtPyXvkOnwIcxS8qwSOEqHxfLfQEQzbHSuyVzXlqw(DQyzHjwqgSaarIMgdeG35YtOyGwnmKTwkS3zYBv04pEl2HCJtDmqQCDfbgN(yGE4pyfde)EpCLkgiiHd9z9hSIbMUyIfGV3dxPyX297Sa8jLYBw0u9nEwGnlVDraliSvGfVazPGSa89wbBqnZITDQyPGSa89E4kflhMLLflWMLhYIvddSGqwkS3SyBNkwCDiaILuuASSvmczcSz53jwiVvrzbHSuyVzXQHbwa4956kILdZY3lAklWMfh0Y)daXc2M3jSS7ywIaeGPaMLMs8RUcflWMLdZYvSmuhQ9pgyOVN6ZJboHL3vu9g8tkL3zW(gVHkxxrGSmpZcM(SoSwyZFuBxeKryRaltzrll2ZY7kQEd(9wbBqdvUUIazrll6RXWGFVhUszAA0eE31velAzXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazrlltyrFnggR(sGn45QS3bVUq2APWEBa4QfXYMrYIDOpnw0YI9SOVgdtWZxfmllw0YYewa4956kY4yRm4kXIL5zw0xJHbPRaBcmtjwqBuNq1NPIAuxkjZYIL5zwa4956kYy1Wq2APWENjVvrzzklZZSmHLaeavE9MIcnubBqw0YY7kQEd(jLY7myFJ3qLRRiqw0YYewaHVXbDR)aqzSnVtYGEIJImnL4xHzztwIawMNzXd)blJd6w)bGYyBENKb9ehfzUkpuhQ9NLPSmLLPSOLLjSeGqfi0wzcE(QGPPe)kmlBYIgPXY8mlbiubcTvMaSaarIY)oLXwxFp20uIFfMLnzrJ0yzA8hVf7qJXPogivUUIaJtFmqp8hSIbIFVXRgffdeKWH(S(dwXa1uRelmlBfJqyrNgWMybzWcaejILf(kuS87elidwaGirSeGf49hSy5HSe2PasSCdwqgSaarIy5WS4HF5kvuwCD46z5HSOtSeC8hdm03t95Xab4956kYy1Wq2APWENjVvrJ)4TyxeeN6yGu56kcmo9Xa9WFWkgyr2YjqyfdeKWH(S(dwXatxmXIMgewywSTtflrHlw8MyX1HRNLhIwVjwcUL1vOyjS7nkcZIxGSK4irSGxnXYVtrzXBILRyXlwqNG6SWel4)ukwgWMfe610qlAqtlgyOVN6ZJb6w5WofqIfTSmHLWU3OimlrYIDSOLLMc7EJIY)LqSGiwqplZZSe29gfHzjswIiltJ)4Tyxkko1XaPY1veyC6Jbg67P(8yGUvoStbKyrlltyjS7nkcZsKSyhlAzPPWU3OO8FjeliIf0ZY8mlHDVrrywIKLiYYuw0YYew0xJHHcQZctz1Q820uIFfMLnzHqmfwpL)lHyzEMf91yyOG6SWugdvEBAkXVcZYMSqiMcRNY)LqSmngOh(dwXa3D1iNaHv8hVLiMwCQJbsLRRiW40hdm03t95XaDRCyNciXIwwMWsy3BueMLizXow0YstHDVrr5)siwqelONL5zwc7EJIWSejlrKLPSOLLjSOVgddfuNfMYQv5TPPe)kmlBYcHykSEk)xcXY8ml6RXWqb1zHPmgQ820uIFfMLnzHqmfwpL)lHyzAmqp8hSIbowkvobcR4pElruJ4uhdKkxxrGXPpgOh(dwXaXV34vJIIbcs4qFw)bRyGPlMyb47nE1Oiw00l63zXQHbmlEbYc4kXILTIriSyBNkwq2wrB6ubnZc6KybTrnlPhwGAMLFNyjflv)E0Mf91yWYHzX1HRNLhYYWvkwGJblWMLOW12GSeClw2kgHedm03t95XaPG6SWK5QSxrzrlltyrFnggyr)oohuK3zah(GLzzXY8ml6RXWG0vGnbMPelOnQtO6ZurnQlLKzzXY8ml6RXWe88vbZYIfTSmHf7zjabqLxVbPO95flZZSeGqfi0wzOelOnQZ6Wc00uIFfMLnzb9SmpZI(AmmbpFvW0uIFfMfeXcQaOjXrmlPILHccBwMWIJ)2vzlOnQzbTSaW7Z1vKbJZbi(zzkltzrlltyXEwcqau51Baq1VhTzzEMf91yyAhavWfopAQszuttj(vywqelOcGMehXSKkwc0PyzcltyXXF7QSf0g1SGawq40yjvS8UIQ3mwD0mCKj1QidvUUIazzklOLfaEFUUImyCoaXpltzbbSerwsflVRO6nfzlNaHLHkxxrGSOLf7zPxfnGnkYGVASu59O4N6Znu56kcKfTSOVgdt7aOcUW5rtvkJAwwSmpZI(AmmTdGk4cNhnvPmAgF1yPY7rXp1NBwwSmpZYew0xJHPDaubx48OPkLrnnL4xHzbrS4H)GLb)EpUMmeIPW6P8FjelAzbBrkvE3XpXcIyjndcZY8ml6RXW0oaQGlCE0uLYOMMs8RWSGiw8WFWYyR9F3qiMcRNY)LqSmpZcaVpxxrMlcbZbybE)blw0YsacvGqBL5kCOxVRROCeU86xjzqcWfittoyuw0YcfHRZYIanxHd96DDfLJWLx)kjdsaUaXYuw0YI(AmmTdGk4cNhnvPmQzzXY8ml2ZI(AmmTdGk4cNhnvPmQzzXIwwSNLaeQaH2kt7aOcUW5rtvkJAAYbJYYuwMNzbG3NRRiJJTYGRelwMNzrhIXSOLLXHA)ZnL4xHzbrSGkaAsCeZsQyjqNILjS44VDv2cAJAwqlla8(CDfzW4CaIFwMYY04pElr0U4uhdKkxxrGXPpgOh(dwXaXV34vJIIbcs4qFw)bRyGPUJYYdzjXrIy53jw0j8ZcCWcW3BfSbzrpkl43diDfkwUNLLflr46ciPIYYvS4vuwqNG6SWel6RNfeYsH9MLdxB)S46W1ZYdzrNyXQHHabgdm03t95XaFxr1BWV3kydAOY1veilAzXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazrlltyrFngg87Tc2GMLflZZS44VDv2cAJAw2KLuuASmLfTSOVgdd(9wbBqd(9asSGiwIilAzzcl6RXWqb1zHPmgQ82SSyzEMf91yyOG6SWuwTkVnllwMYIww0xJHXQVeydEUk7DWRlKTwkS3gaUArSGiwSdnMglAzzclbiubcTvMGNVkyAkXVcZYMSOrASmpZI9SaW7Z1vKjalaqKOmiHJwbw0YsacGkVEtDO2)8WjwMg)XBjIrmo1XaPY1veyC6JbcTIbIPpgOh(dwXab4956kkgiaxTOyGuqDwyYCvwTkVzjvSebSGww8WFWYGFVhxtgcXuy9u(VeIfeWI9Sqb1zHjZvz1Q8MLuXYewqUSGawExr1BWWLkdh5FNYdyt43qLRRiqwsflrKLPSGww8WFWYyR9F3qiMcRNY)LqSGawsZGWONf0Yc2IuQ8UJFIfeWsAg0ZsQy5DfvVP8F1eoR7kVcKHkxxrGXabjCOpR)Gvmq0b)xI)eMLDOnwswHDw2kgHWI3elO8RiqwSOMfmfGfOHfn9sfLL3rIWS4SGl3cVdFwgWMLFNyjS6MQNf89l)pyXcgYIn4sbwB)SOtS4HWQ9NyzaBwuEJIAw(lHgTNq4yGa8oxEcfd0XwieQbsH4pElreHJtDmqQCDfbgN(yGE4pyfde)EJxnkkgiiHd9z9hSIbQPwjwSa89gVAuelxXIxSGob1zHjwCmlyiSyXXSybX4txrS4ywuWcfloMLOWfl2oLIfQazzzXIT73zjcsdbSyBNkwO6P(kuS87elfH4Nf0jOolmPzwaH12plk6z5EwSAyGfeYsH9wZSacRTFwGaO2wFpXIxSOPx0VZIvddS4filwqOIfDAaBIfKTv0MovGfVazbDsSG2OML0dlWyGH(EQppgO9S0RIgWgfz(lHSb7kd2KNOFfi1gQCDfbYIwwMWI(Ammw9LaBWZvzVdEDHS1sH92aWvlIfeXIDOX0yzEMf91yyS6lb2GNRYEh86czRLc7TbGRweliIf7qFASOLL3vu9g8tkL3zW(gVHkxxrGSmLfTSmHfkOolmzUkJHkVzrllo(BxLTG2OMfeWcaVpxxrghBHqOgifyjvSOVgddfuNfMYyOYBttj(vywqalGW3mwD0mCKj1QiZFbKW5Ms8RyjvSyNb9SSjlrqASmpZcfuNfMmxLvRYBw0YIJ)2vzlOnQzbbSaW7Z1vKXXwieQbsbwsfl6RXWqb1zHPSAvEBAkXVcZccybe(MXQJMHJmPwfz(lGeo3uIFflPIf7mONLnzjfLgltzrll2ZI(AmmWI(DC2I6az9hSmllw0YI9S8UIQ3GFVvWg0qLRRiqw0YYewcqOceARmbpFvW0uIFfMLnzbnYY8mly4sPFfO537tPYyIqIAdvUUIazrll6RXW879PuzmrirTb)EajwqelrmISOjSmHLEv0a2Oid(QXsL3JIFQp3qLRRiqwsfl2XYuw0YY4qT)5Ms8RWSSjlAKwASOLLXHA)ZnL4xHzbrSyxAPXY8mlG96anfmhaXSmLfTSmHf7zjabqLxVbPO95flZZSeGqfi0wzOelOnQZ6Wc00uIFfMLnzXowMg)XBjIOpo1XaPY1veyC6Jb6H)GvmWISLtGWkgiiHd9z9hSIbMUyIfnniSWSCflEfLf0jOolmXIxGSGDaeli07QbcqdlLIfnniSyzaBwq2wrB6ubw8cKLuCxb2eilOtIf0g1ju9gw2QcdzzHjw2IMglEbYcAqtJf)z53jwOcKf4Gf0qtvkJYIxGSacRTFwu0ZIMQjpr)kqQzz4kflWXigyOVN6ZJb6w5WofqIfTSaW7Z1vKb7aO8a25GNVkWIwwMWI(AmmuqDwykRwL3MMs8RWSSjleIPW6P8FjelZZSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeILPXF8wIiYno1XaPY1veyC6Jbg67P(8yGUvoStbKyrlla8(CDfzWoakpGDo45RcSOLLjSOVgddfuNfMYQv5TPPe)kmlBYcHykSEk)xcXY8ml6RXWqb1zHPmgQ820uIFfMLnzHqmfwpL)lHyzklAzzcl6RXWe88vbZYIL5zw0xJHXQVeydEUk7DWRlKTwkS3gaUArSGOizXonsJLPSOLLjSyplbiaQ86naO63J2SmpZI(AmmTdGk4cNhnvPmQPPe)kmliILjSGEw0ewSJLuXsVkAaBuKbF1yPY7rXp1NBOY1veiltzrll6RXW0oaQGlCE0uLYOMLflZZSypl6RXW0oaQGlCE0uLYOMLfltzrlltyXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazzEMfcXuy9u(VeIfeXI(Amm)Lq2GDLbBYt0VcKAttj(vywMNzXEw0xJH5VeYgSRmytEI(vGuBwwSmngOh(dwXa3D1iNaHv8hVLiIgJtDmqQCDfbgN(yGH(EQppgOBLd7uajw0YcaVpxxrgSdGYdyNdE(QalAzzcl6RXWqb1zHPSAvEBAkXVcZYMSqiMcRNY)LqSmpZI(AmmuqDwykJHkVnnL4xHzztwietH1t5)siwMYIwwMWI(AmmbpFvWSSyzEMf91yyS6lb2GNRYEh86czRLc7TbGRwelikswStJ0yzklAzzcl2ZsacGkVEdsr7ZlwMNzrFnggKUcSjWmLybTrDcvFMkQrDPKmllwMYIwwMWI9SeGaOYR3aGQFpAZY8ml6RXW0oaQGlCE0uLYOMMs8RWSGiwqplAzrFngM2bqfCHZJMQug1SSyrll2ZsVkAaBuKbF1yPY7rXp1NBOY1veilZZSypl6RXW0oaQGlCE0uLYOMLfltzrlltyXEw6vrdyJIm)Lq2GDLbBYt0VcKAdvUUIazzEMfcXuy9u(VeIfeXI(Amm)Lq2GDLbBYt0VcKAttj(vywMNzXEw0xJH5VeYgSRmytEI(vGuBwwSmngOh(dwXahlLkNaHv8hVLigbXPogivUUIaJtFmqqch6Z6pyfdmDXeliuq0HfyXsamgOh(dwXaT5DFWodhzsTkk(J3setrXPogivUUIaJtFmqp8hSIbIFVhxtXabjCOpR)GvmW0ftSa89ECnXYdzXQHbwacvEZc6euNfM0mliBROnDQal7oMffHXS8xcXYV7floliuT)7SqiMcRNyrrJNfyZcSurzb5xL3SGob1zHjwomllldliu3VZsQTlcyXoRalu9uZIZcqOYBwqNG6SWel3GfeYsH9Mf8Fkfl7oMffHXS87EXIDAKgl43diHzXlqwq2wrB6ubw8cKfKblaqKiw2DaeljWMy539IfnqJywqMMILMs8RUcLHL0ftS46qael2H(0qoSS74NybC1xHIf0qtvkJYIxGSyND2HCyz3XpXIT73HRNf0qtvkJgdm03t95XaPG6SWK5QSAvEZIwwSNf91yyAhavWfopAQszuZYIL5zwOG6SWKbdvENlcXplZZSmHfkOolmz8kAUie)SmpZI(AmmbpFvW0uIFfMfeXIh(dwgBT)7gcXuy9u(VeIfTSOVgdtWZxfmllwMYIwwMWI9SGPpRdRf28h12fbz7ScSmpZsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYIww0xJHXQVeydEUk7DWRlKTwkS3gaUArSGiwStJ0yrllbiubcTvMGNVkyAkXVcZYMSObAKfTSmHf7zjabqLxVPou7FE4elZZSeGqfi0wzcWcaejk)7ugBD99yttj(vyw2KfnqJSmLfTSmHf7zP9az(gQuSmpZsacvGqBLrNAm1iDfkttj(vyw2KfnqJSmLLPSmpZcfuNfMmxL9kklAzzcl6RXWyZ7(GDgoYKAvKzzXY8mlylsPY7o(jwqelPzqy0ZIwwMWI9SeGaOYR3aGQFpAZY8ml2ZI(AmmTdGk4cNhnvPmQzzXYuwMNzjabqLxVbav)E0MfTSGTiLkV74NybrSKMbHzzA8hVfeoT4uhdKkxxrGXPpgiiHd9z9hSIbMUyIfeQ2)DwG)o12omXIT9lSZYHz5kwacvEZc6euNfM0mliBROnDQalWMLhYIvddSG8RYBwqNG6SWumqp8hSIbAR9Fp(J3ccRrCQJbsLRRiW40hdeKWH(S(dwXardUs979kgOh(dwXa7vL9WFWkRo8hduD4pxEcfdC4k1V3R4p(J)yGaOgFWkEl2LMD2LwetZUyG28UUcfogic1wrOTL0zli0LcSWsQ3jwUely)SmGnlBdTOI6TzPPiCDnbYcgMqS4RhM4pbYsy3lue2WBG8xrSyxkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gi)velrmfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdEdeQTIqBlPZwqOlfyHLuVtSCjwW(zzaBw2gKg(s9BZstr46AcKfmmHyXxpmXFcKLWUxOiSH3a5VIyb5McSGmybG6Nazb4LGmwWrR3rmlihwEili)Yzb8aC4dwSaTO2FyZYe0oLLjAG4PgEdK)kIfKBkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnltSdXtn8gi)velOXuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwIGuGfKblau)eilaVeKXcoA9oIzb5WYdzb5xolGhGdFWIfOf1(dBwMG2PSmXoep1WBG8xrSebPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBG8xrSKIsbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzser8udVbYFfXskkfybzWca1pbYY2FFfs0B0WGMBZYdzz7VVcj6nVgg0CBwMyhINA4nq(RiwsrPalidwaO(jqw2(7RqIEJDg0CBwEilB)9virV5TZGMBZYe7q8udVbYFfXIgPLcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXIgAKcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXIg2LcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXIgrmfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdK)kIfnqFkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gi)velAGCtbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIDiEQH3a5VIyrdKBkWcYGfaQFcKLT)(kKO3OHbn3MLhYY2FFfs0BEnmO52SmXoep1WBG8xrSObYnfybzWca1pbYY2FFfs0BSZGMBZYdzz7VVcj6nVDg0CBwMObINA4nq(Riw0anMcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYe7q8udVbYFfXIgOXuGfKblau)eilB)9virVrddAUnlpKLT)(kKO38AyqZTzzIgiEQH3a5VIyrd0ykWcYGfaQFcKLT)(kKO3yNbn3MLhYY2FFfs0BE7mO52SmXoep1WBWBGqTveABjD2ccDPalSK6DILlXc2pldyZY2wnfGj6(VnlnfHRRjqwWWeIfF9We)jqwc7EHIWgEdK)kILiMcSGmybG6Nazz7VVcj6nAyqZTz5HSS93xHe9MxddAUnltIiINA4nq(Riwq4uGfKblau)eilB)9virVXodAUnlpKLT)(kKO382zqZTzzser8udVbYFfXcAmfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3Mf)zbD00rEwMObINA4n4nqO2kcTTKoBbHUuGfws9oXYLyb7NLbSzzBhsBZstr46AcKfmmHyXxpmXFcKLWUxOiSH3a5VIyrJuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwSlfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdK)kIf7sbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzXFwqhnDKNLjAG4PgEdK)kILiMcSGmybG6Nazz73vu9g0CBwEilB)UIQ3GMgQCDfbUnlt0aXtn8gi)velrmfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjreXtn8gi)veli3uGfKblau)eilaVeKXcoA9oIzb5GCy5HSG8lNLei4sTWSaTO2FyZYeKZuwMObINA4nq(RiwqUPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42SmXoep1WBG8xrSGgtbwqgSaq9tGSa8sqgl4O17iMfKdYHLhYcYVCwsGGl1cZc0IA)HnltqotzzIgiEQH3a5VIybnMcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXseKcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXskkfybzWca1pbYcWlbzSGJwVJywqoS8qwq(LZc4b4WhSybArT)WMLjODkltSdXtn8gi)velAyxkWcYGfaQFcKfGxcYybhTEhXSGCy5HSG8lNfWdWHpyXc0IA)Hnltq7uwMObINA4nq(Riw0aHtbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3a5VIyrd0NcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbYFfXIgi3uGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(Riw0icsbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3a5VIyXU0sbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIDiEQH3a5VIyXo7sbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYenq8udVbYFfXIDiCkWcYGfaQFcKfGxcYybhTEhXSGCy5HSG8lNfWdWHpyXc0IA)Hnltq7uwMyhINA4nq(RiwSdHtbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3a5VIyXoKBkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gi)vel2HgtbwqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3a5VIyXUuukWcYGfaQFcKfGxcYybhTEhXSGCy5HSG8lNfWdWHpyXc0IA)Hnltq7uwMyhINA4nq(RiwIyAPalidwaO(jqwaEjiJfC06DeZcYHLhYcYVCwapah(GflqlQ9h2SmbTtzzIgiEQH3G3aHARi02s6Sfe6sbwyj17elxIfSFwgWMLThUs979ABwAkcxxtGSGHjel(6Hj(tGSe29cfHn8gi)vel2LcSGmybG6Nazb4LGmwWrR3rmlihwEili)Yzb8aC4dwSaTO2FyZYe0oLLjAG4PgEdEdeQTIqBlPZwqOlfyHLuVtSCjwW(zzaBw2g)BZstr46AcKfmmHyXxpmXFcKLWUxOiSH3a5VIyXUuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMGEep1WBG8xrSeXuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(Riwq4uGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwqUPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42S4plOJMoYZYenq8udVbYFfXIgPLcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYe7q8udVbYFfXIgiCkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gi)velAGCtbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYenq8udVbYFfXIgi3uGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMGEep1WBG8xrSObAmfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdK)kIfnIGuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwStJuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwSdHtbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYeegXtn8gi)vel2HWPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBG8xrSyh6tbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYenq8udVbYFfXIDOpfybzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdK)kIf7qUPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBG8xrSernsbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYKiI4PgEdK)kILiQrkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gi)velr0UuGfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nq(RiwIyetbwqgSaq9tGSa8sqgl4O17iMfKdlpKfKF5SaEao8blwGwu7pSzzcANYYKiI4PgEdK)kILiIWPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42SmXoep1WBG8xrSerKBkWcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnltSdXtn8gi)velrenMcSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYe7q8udVbYFfXsetrPalidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBWBKojwW(jqwqUS4H)GflQd)ydVrmqSffI3IgPzxmqRgooffdeDrxwsVR8kqSOP61bYBGUOllAAEh2zbH1ml2LMD2XBWBGUOlliB3lueof4nqx0LfnHLTccsGSaeQ8ML0tEIH3aDrxw0ewq2UxOiqwEVrrF(gSeCmHz5HSeIguu(9gf9ydVb6IUSOjSGqJsGaiqwwvrbcJ9okla8(CDfHzzYziJMzXQjaz87nE1Oiw0KnzXQjag87nE1OOPgEd0fDzrtyzRaGhilwnfC8FfkwqOA)3z5gSC)2yw(DIfBnSqXc6euNfMm8gOl6YIMWIMMJeXcYGfaisel)oXcqRRVhZIZI6(xrSKaBILHIq8PRiwMCdwIcxSS7G12pl73ZY9SGVKL69IGlSkkl2UFNL0RPV1uZccybzKIW)5kw2Q6qvju9AML73gKfmsN1udVb6IUSOjSOP5irSKaXplBpou7FUPe)k82SGdu59bXS4wwQOS8qw0HymlJd1(JzbwQOgEd0fDzrtyj1n5plPgMqSahSKELVZs6v(olPx57S4ywCwWwu4CflFFfs0B4nqx0LfnHfnDlQOMLjNHmAMfeQ2)DnZccv7)UMzb4794AAkljoiXscSjwAcFQJQNLhYc5T6OMLamr3Fnb)E)gEd0fDzrtybnCiMLuCxb2eilOtIf0g1ju9Se2PasSmGnlittXYc7OidVbVb6IUSS1QGV)eilP3vEfiw2kcb5zj4fl6eld4QazXFw2)3cNcOfT6UYRaPj4ljyqD)(s3Cq0MEx5vG0eGxcYqBcOz)tuP4poffPUR8kqMhXpVbVHh(dwyJvtbyIU)rI0vGnbMXwxFpM3aDzj17ela8(CDfXYHzbtplpKL0yX297SuqwWV)SalwwyILVVcj6XAMfnyX2ovS87elJRXplWIy5WSalwwysZSyhl3GLFNybtbybYYHzXlqwIil3GfD4VZI3eVHh(dwyJvtbyIU)iis0cW7Z1vKMlpHIew5fMYFFfs0RzaUArrMgVHh(dwyJvtbyIU)iis0cW7Z1vKMlpHIew5fMYFFfs0RzOvKoiOMb4QffPgA(gr(9virVrdZUJZlmL1xJH2VVcj6nAycqOceARmGR2)dwAT)7RqIEJgMdBEycLHJCcSWFdx4Caw4VxH)GfM3Wd)blSXQPamr3FeejAb4956ksZLNqrcR8ct5VVcj61m0ksheuZaC1II0onFJi)(kKO3yNz3X5fMY6RXq73xHe9g7mbiubcTvgWv7)blT2)9virVXoZHnpmHYWrobw4VHlCoal83RWFWcZBGUSK6DctS89virpMfVjwk4ZIVEyI)xWvQOSaspfEcKfhZcSyzHjwWV)S89virp2WclaPNfaEFUUIy5HSGWS4yw(DkklUcdzPicKfSffoxXYUxGQRqz4n8WFWcBSAkat09hbrIwaEFUUI0C5juKWkVWu(7RqIEndTI0bb1maxTOirynFJiPiCDwweO5kCOxVRROCeU86xjzqcWfO5zkcxNLfbAOeROn5QmSblVc08mfHRZYIany4sPO)VcvUx6r5nqxwaspMLFNyb47nE1Oiwcq8ZYa2SO8NAwcUkSu(FWcZYKbSzHqSNyPiwSTtflpKf879Zc4kX6kuSOtdytSGgAQszuwgUsHzbogt5n8WFWcBSAkat09hbrIwaEFUUI0C5juKyCoaXVMb4Qffzetlvt0qtsZyxQW0N1H1cB(JA7IGmcBfMYBGUSaKEml(ZIT9lSZINax1ZcCWYwXiewqgSaarIybVdxkqw0jwwycmfybHtJfB3VdxpliJue(pxXcqRRVhZIxGSeX0yX297gEdp8hSWgRMcWeD)rqKOfG3NRRinxEcfzawaGirzhBPzaUArrgX0qGgPLQEv0a2OitGue(pxLXwxFpM3Wd)blSXQPamr3FeejAtGWcPRYdyNWB4H)Gf2y1uaMO7pcIeT2A)31S6kkhaJuJ008nICcfuNfMmQv5DUie)ZZuqDwyYCvgdvEpptb1zHjZvzD4Vpptb1zHjJxrZfH4FkVbVb6YccPPGJFwSJfeQ2)Dw8cKfNfGV34vJIybwSam1Sy7(Dw2YHA)zbn4elEbYs6HBn1SaBwa(EpUMyb(7uB7WeVHh(dwyd0IkQrqKO1w7)UMVrKtOG6SWKrTkVZfH4FEMcQZctMRYyOY75zkOolmzUkRd)95zkOolmz8kAUie)t1A1eaJggBT)7AT3Qjag7m2A)35n8WFWcBGwurncIeT437X1KMvxr5ayKOxZ3iYj23RIgWgfz0DLxbkdhzxPY)(vOWZZ2hGaOYR3uhQ9ppCAE2ESfPu53Bu0Jn437HRurQX8S9VRO6nL)RMWzDx5vGmu56kcCQw7X0N1H1cB(JA7IGSDwH55juqDwyYGHkVZfH4FEMcQZctMRYQv598mfuNfMmxL1H)(8mfuNfMmEfnxeI)P8gE4pyHnqlQOgbrIw87nE1OinRUIYbWirVMVrKt6vrdyJIm6UYRaLHJSRu5F)kuyTbiaQ86n1HA)ZdN0ITiLk)EJIESb)EpCLksnMQ1Em9zDyTWM)O2UiiBNvG3G3aDrxwqhetH1tGSqaOokl)LqS87elE4HnlhMfhGFkxxrgEdp8hSWrIHkVZ6KNWB4H)GfgbrI2GRuzp8hSYQd)AU8eksOfvuRz83x4JudnFJi)lHq0e7sLh(dwgBT)7MGJ)8Fjec8WFWYGFVhxtMGJ)8Fj0uEd0LfG0JzzRq0HfyXseral2UFhUEwa7B8S4fil2UFNfGV3kydYIxGSyhcyb(7uB7WeVHh(dwyeejAb4956ksZLNqrE4SdjndWvlksSfPu53Bu0Jn437HRuBQH2j2)UIQ3GFVvWg0qLRRiW553vu9g8tkL3zW(gVHkxxrGtNNXwKsLFVrrp2GFVhUsTPD8gOllaPhZsqroaIfB7uXcW37X1elbVyz)EwSdbS8EJIEml22VWolhMLMueaVEwgWMLFNybDcQZctS8qw0jwSAAqDtGS4fil22VWolJtPOMLhYsWXpVHh(dwyeejAb4956ksZLNqrE4CqroasZaC1IIeBrkv(9gf9yd(9ECnTPg8gOllPy9(CDfXYV7plHDkGeMLBWsu4IfVjwUIfNfubqwEiloa4bYYVtSGVF5)blwSTtnXIZY3xHe9SqFGLdZYctGSCfl60BJOILGJFmVHh(dwyeejAb4956ksZLNqrEvgvauZaC1II0QjazubqJgMeiSgxtZZwnbiJkaA0WGx14AAE2QjazubqJgg87nE1OO5zRMaKrfanAyWV3dxPMNTAcqgva0OHzS6Oz4itQvrZZwnbW0oaQGlCE0uLYOZZ6RXWe88vbttj(v4i1xJHj45RcgWv7)bR5zaEFUUImho7qI3aDzjDXelPNAm1iDfkw8NLFNyHkqwGdwqdnvPmkl22PILDh)elhMfxhcGyb5MgYrZS4JNAwqgSaarIyXlqwG)o12omXIT73zbzBfTPtf4n8WFWcJGirRo1yQr6kuA(grozI9biaQ86n1HA)ZdNMNTpaHkqOTYeGfaisu(3Pm2667XML18CVkAaBuKjqkc)NRYyRRVhpvR(AmmbpFvW0uIFfEtnqVw91yyAhavWfopAQszuttj(vyeHWATpabqLxVbav)E0EEoabqLxVbav)E0wR(AmmbpFvWSS0QVgdt7aOcUW5rtvkJAwwANOVgdt7aOcUW5rtvkJAAkXVcJOi1WonbHtvVkAaBuKbF1yPY7rXp1NppRVgdtWZxfmnL4xHrKgAmpRbYbBrkvE3XpHinmi3Pt1cW7Z1vK5QmQaiVb6Yccb(Sy7(DwCwq2wrB6ubw(D)z5W12ploliKLc7nlwnmWcSzX2ovS87elJd1(ZYHzX1HRNLhYcvG8gE4pyHrqKO1c(hS08nICI(AmmbpFvW0uIFfEtnqV2j23RIgWgfzWxnwQ8Eu8t95ZZ6RXW0oaQGlCE0uLYOMMs8RWisJuKw91yyAhavWfopAQszuZYA68SoeJ1oou7FUPe)kmISd9t1cW7Z1vK5QmQaiVb6YcYCvyP8NWSyBN(DQzzHVcflidwaGirSuqBSy7ukwCLcAJLOWflpKf8Fkflbh)S87elypHyXtGR6zboybzWcaejcbiBROnDQalbh)yEdp8hSWiis0cW7Z1vKMlpHImalaqKOmiHJwbndWvlkYaDQjtghQ9p3uIFfwt0a9AsacvGqBLj45RcMMs8RWtroAebPnnYaDQjtghQ9p3uIFfwt0a9AsacvGqBLjalaqKO8VtzS113JnGR2)dwAsacvGqBLjalaqKO8VtzS113JnnL4xHNIC0icsBQw7B)aZeaQEJdcIneIp8J1oX(aeQaH2ktWZxfmn5GrNNTpaHkqOTYeGfaisKPjhm6055aeQaH2ktWZxfmnL4xH38QNAlOYFcmpou7FUPe)k88CVkAaBuKjqkc)NRYyRRVhRnaHkqOTYe88vbttj(v4nJyAZZbiubcTvMaSaarIY)oLXwxFp20uIFfEZREQTGk)jW84qT)5Ms8RWAIgPnpBFacGkVEtDO2)8WjEd0LL0ftGS8qwajLhLLFNyzHDuelWbliBROnDQal22PILf(kuSacx6kIfyXYctS4filwnbGQNLf2rrSyBNkw8IfheKfcavplhMfxhUEwEilGhXB4H)GfgbrIwaEFUUI0C5juKbWCawG3FWsZaC1IICY7nk6n)Lq5hMbpAtnq)8C7hyMaq1BCqqS5QnrFAt1ozcfHRZYIanuIv0MCvg2GLxbs7e7dqau51Baq1VhTNNdqOceARmuIv0MCvg2GLxbY0uIFfgrAGCrJiyc6tvVkAaBuKbF1yPY7rXp1NpDQw7dqOceARmuIv0MCvg2GLxbY0KdgD68mfHRZYIany4sPO)VcvUx6r1oX(aeavE9M6qT)5HtZZbiubcTvgmCPu0)xHk3l9O5iIWOpcstdttj(vyePHgi8055jbiubcTvgDQXuJ0vOmn5GrNNTV9az(gQuZZbiaQ86n1HA)ZdNMQDI9VRO6nJvhndhzsTkYqLRRiW55aeavE9gau97rBTbiubcTvMXQJMHJmPwfzAkXVcJin0abOpv9QObSrrg8vJLkVhf)uF(8S9biaQ86naO63J2AdqOceARmJvhndhzsTkY0uIFfgr6RXWe88vbd4Q9)Gfc0WUu1RIgWgfzS6lb2GNRYEh86czRLc7TMOHDt1oHIW1zzrGMRWHE9UUIYr4YRFLKbjaxG0gGqfi0wzUch6176kkhHlV(vsgKaCbY0uIFfgrOF688KjueUollc0G3DqOncmdB9mCKFyNq1RnaHkqOTY8WoHQNaZxHpu7FoIOh9r0onmnL4xHNoppzcaVpxxrgyLxyk)9virFKAmpdW7Z1vKbw5fMYFFfs0hzeNQDY3xHe9gnmn5GrZbiubcTvZZFFfs0B0WeGqfi0wzAkXVcV5vp1wqL)eyECO2)Ctj(vynrJ0MopdW7Z1vKbw5fMYFFfs0hPDAN89virVXottoy0CacvGqB1883xHe9g7mbiubcTvMMs8RWBE1tTfu5pbMhhQ9p3uIFfwt0iTPZZa8(CDfzGvEHP83xHe9rM20Pt5nqxwsX6956kILfMaz5HSaskpklEfLLVVcj6XS4filbqml22PIfB(9xHILbSzXlwqNL1oSpNfRgg4n8WFWcJGirlaVpxxrAU8ekYFVpLkJjcjQZ2871maxTOiThdxk9Ran)EFkvgtesuBOY1ve4884qT)5Ms8RWBAxAPnpRdXyTJd1(NBkXVcJi7qpcMGWPPj6RXW879PuzmrirTb)EaPuz305z91yy(9(uQmMiKO2GFpG0Mrmc0Kj9QObSrrg8vJLkVhf)uFEQSBkVb6Ys6IjwqNeROn5kw00BWYRaXIDPHPaMfDAaBIfNfKTv0MovGLfMyb2SGHS87(ZY9Sy7ukwuxrSSSyX297S87elubYcCWcAOPkLr5n8WFWcJGir7ct57PenxEcfjLyfTjxLHny5vG08nImaHkqOTYe88vbttj(vyezxAAdqOceARmbybaIeL)DkJTU(ESPPe)kmISlnTta4956kY879PuzmrirD2MF)8S(Amm)EFkvgtesuBWVhqAZiMgcM0RIgWgfzWxnwQ8Eu8t95PkItNQfG3NRRiZvzubW5zDigRDCO2)Ctj(vyefr0iVb6Ys6Ijwacxkf9xHIfeAl9OSGCXuaZIonGnXIZcY2kAtNkWYctSaBwWqw(D)z5EwSDkflQRiwwwSy7(Dw(DIfQazboybn0uLYO8gE4pyHrqKODHP89uIMlpHIedxkf9)vOY9spQMVrKtcqOceARmbpFvW0uIFfgrixT2hGaOYR3aGQFpAR1(aeavE9M6qT)5HtZZbiaQ86n1HA)ZdN0gGqfi0wzcWcaejk)7ugBD99yttj(vyeHC1obG3NRRitawaGirzqchTcZZbiubcTvMGNVkyAkXVcJiK7055aeavE9gau97rBTtSVxfnGnkYGVASu59O4N6Z1gGqfi0wzcE(QGPPe)kmIqUZZ6RXW0oaQGlCE0uLYOMMs8RWisJ0qWe0NkkcxNLfbAUc)9k8WgNbpaxrzDsPMQvFngM2bqfCHZJMQug1SSMopRdXyTJd1(NBkXVcJi7q)8mfHRZYIanuIv0MCvg2GLxbsBacvGqBLHsSI2KRYWgS8kqMMs8RWBAxAt1cW7Z1vK5QmQaOw7PiCDwweO5kCOxVRROCeU86xjzqcWfO55aeQaH2kZv4qVExxr5iC51VsYGeGlqMMs8RWBAxAZZ6qmw74qT)5Ms8RWiYU04nqxw2QYMhfZYctSKoPyQPyX297SGSTI20PcSaBw8NLFNyHkqwGdwqdnvPmkVHh(dwyeejAb4956ksZLNqrEriyoalW7pyPzaUArrQVgdtWZxfmnL4xH3ud0RDI99QObSrrg8vJLkVhf)uF(8S(AmmTdGk4cNhnvPmQPPe)kmIIud0BqpcMerd6tL(Amm6kieuTWVzznfbtqyd61KiAqFQ0xJHrxbHGQf(nlRPPIIW1zzrGMRWFVcpSXzWdWvuwNukeGWg0NQjueUollc087uECn(Z4d1P0gGqfi0wz(DkpUg)z8H6uMMs8RWiks7sBQw91yyAhavWfopAQszuZYA68SoeJ1oou7FUPe)kmISd9ZZueUollc0qjwrBYvzydwEfiTbiubcTvgkXkAtUkdBWYRazAkXVcZB4H)GfgbrI2fMY3tjAU8ekYRWHE9UUIYr4YRFLKbjaxG08nIeG3NRRiZfHG5aSaV)GLwaEFUUImxLrfa5nqxwsxmXcWDheAJazrtV1zrNgWMybzBfTPtf4n8WFWcJGir7ct57PenxEcfjE3bH2iWmS1ZWr(HDcvVMVrKtcqOceARmbpFvW0KdgvR9biaQ86n1HA)ZdN0cW7Z1vK537tPYyIqI6Sn)ETtcqOceARm6uJPgPRqzAYbJopBF7bY8nuPMophGaOYR3uhQ9ppCsBacvGqBLjalaqKO8VtzS113Jnn5Gr1obG3NRRitawaGirzqchTcZZbiubcTvMGNVkyAYbJoDQwq4BWRACnz(lG0vO0obe(g8tkL35HYBY8xaPRqnpB)7kQEd(jLY78q5nzOY1ve48m2IuQ87nk6Xg8794AAZiovli8njqynUMm)fq6kuANaW7Z1vK5WzhsZZ9QObSrrgDx5vGYWr2vQ8VFfk88SJ)2vzlOnQ3mYuuAZZa8(CDfzcWcaejkds4OvyEwFnggDfecQw43SSMQ1EkcxNLfbAUch6176kkhHlV(vsgKaCbAEMIW1zzrGMRWHE9UUIYr4YRFLKbjaxG0gGqfi0wzUch6176kkhHlV(vsgKaCbY0uIFfEZiMMw71xJHj45RcML18SoeJ1oou7FUPe)kmIq404nqxws9(Hz5WS4S0(VtnlKY1HT)el28OS8qwsCKiwCLIfyXYctSGF)z57RqIEmlpKfDIf1veilllwSD)oliBROnDQalEbYcYGfaiselEbYYctS87el2vGSGvWNfyXsaKLBWIo83z57RqIEmlEtSalwwyIf87plFFfs0J5n8WFWcJGir7ct57PeSMXk4JJ87RqIEn08nICcaVpxxrgyLxyk)9virV9rQHw7)(kKO3yNPjhmAoaHkqOTAEEcaVpxxrgyLxyk)9virFKAmpdW7Z1vKbw5fMYFFfs0hzeNQDI(AmmbpFvWSS0oX(aeavE9gau97r75z91yyAhavWfopAQszuttj(vyemjIg0NQEv0a2Oid(QXsL3JIFQpFkII87RqIEJgg91yKbxT)hS0QVgdt7aOcUW5rtvkJAwwZZ6RXW0oaQGlCE0uLYOz8vJLkVhf)uFUzznDEoaHkqOTYe88vbttj(vyey3MFFfs0B0WeGqfi0wzaxT)hS0AV(AmmbpFvWSS0oX(aeavE9M6qT)5HtZZ2dW7Z1vKjalaqKOmiHJwHPATpabqLxVbPO9518CacGkVEtDO2)8WjTa8(CDfzcWcaejkds4OvqBacvGqBLjalaqKO8VtzS113JnllT2hGqfi0wzcE(QGzzPDYe91yyOG6SWuwTkVnnL4xH3uJ0MN1xJHHcQZctzmu5TPPe)k8MAK2uT23RIgWgfz0DLxbkdhzxPY)(vOWZZt0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqks0ppRVgdJUR8kqz4i7kv(3Vcfo7DWlYGFpGuKrW0PZZ6RXWG0vGnbMPelOnQtO6ZurnQlLKzznDEwhIXAhhQ9p3uIFfgr2L28maVpxxrgyLxyk)9virFKPnvlaVpxxrMRYOcG8gE4pyHrqKODHP89ucwZyf8Xr(9virVDA(grobG3NRRidSYlmL)(kKO3(iTtR9FFfs0B0W0KdgnhGqfi0wnpdW7Z1vKbw5fMYFFfs0hPDANOVgdtWZxfmllTtSpabqLxVbav)E0EEwFngM2bqfCHZJMQug10uIFfgbtIOb9PQxfnGnkYGVASu59O4N6ZNIOi)(kKO3yNrFngzWv7)blT6RXW0oaQGlCE0uLYOML18S(AmmTdGk4cNhnvPmAgF1yPY7rXp1NBwwtNNdqOceARmbpFvW0uIFfgb2T53xHe9g7mbiubcTvgWv7)blT2RVgdtWZxfmllTtSpabqLxVPou7FE408S9a8(CDfzcWcaejkds4OvyQw7dqau51BqkAFEPDI96RXWe88vbZYAE2(aeavE9gau97r7PZZbiaQ86n1HA)ZdN0cW7Z1vKjalaqKOmiHJwbTbiubcTvMaSaarIY)oLXwxFp2SS0AFacvGqBLj45RcMLL2jt0xJHHcQZctz1Q820uIFfEtnsBEwFnggkOolmLXqL3MMs8RWBQrAt1AFVkAaBuKr3vEfOmCKDLk)7xHcppprFnggDx5vGYWr2vQ8VFfkCU8F1Kb)EaPir)8S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asrgbtNoDEwFnggKUcSjWmLybTrDcvFMkQrDPKmlR5zDigRDCO2)Ctj(vyezxAZZa8(CDfzGvEHP83xHe9rM2uTa8(CDfzUkJkaYBGUSKUycZIRuSa)DQzbwSSWel3tjywGflbqEdp8hSWiis0UWu(EkbZBGUSGo3VtnlOGSC1dz53jwWplWMfhsS4H)GflQd)8gE4pyHrqKOTxv2d)bRS6WVMlpHI0HKMXFFHpsn08nIeG3NRRiZHZoK4n8WFWcJGirBVQSh(dwz1HFnxEcfj(5n4nqxwqMRclL)eMfB70Vtnl)oXIMQjpj4FyNAw0xJbl2oLILHRuSahdwSD)(vS87elfH4NLGJFEdp8hSWghsrcW7Z1vKMlpHIeSjpjB7uQ8WvQmCm0maxTOi7vrdyJIm)Lq2GDLbBYt0VcKATt0xJH5VeYgSRmytEI(vGuBAkXVcJiubqtIJyeKMrJ5z91yy(lHSb7kd2KNOFfi1MMs8RWiYd)bld(9ECnzietH1t5)sieKMrdTtOG6SWK5QSAvEpptb1zHjdgQ8oxeI)5zkOolmz8kAUie)tNQvFngM)siBWUYGn5j6xbsTzzXBGUSGmxfwk)jml22PFNAwa(EJxnkILdZIny)7SeC8FfkwGaOMfGV3JRjwUIfKFvEZc6euNfM4n8WFWcBCiHGirlaVpxxrAU8ekYdvbBkJFVXRgfPzaUArrApfuNfMmxLXqL3AXwKsLFVrrp2GFVhxtBIg1K3vu9gmCPYWr(3P8a2e(nu56kcmv2HakOolmzUkRd)DT23RIgWgfzS6lb2GNRYEh86czRLc7Tw77vrdyJImWI(DCoOiVZao8blEd0LL0ftSGmybaIeXITDQyXFwuegZYV7flOpnw2kgHWIxGSOUIyzzXIT73zbzBfTPtf4n8WFWcBCiHGirBawaGir5FNYyRRVhR5BeP9G96anfmhaXANmbG3NRRitawaGirzqchTcATpaHkqOTYe88vbttoy05z91yycE(QGzznv7e91yyOG6SWuwTkVnnL4xH3e9ZZ6RXWqb1zHPmgQ820uIFfEt0pv7eh)TRYwqBuJi0NM2jylsPYV3OOhBWV3JRPnJ48S(AmmbpFvWSSMopBFVkAaBuKXQVeydEUk7DWRlKTwkS3t1oX(3vu9g8tkL3zW(g)8S(Amm437HRuMMs8RWisdd61K0mOpv9QObSrrMaPi8FUkJTU(E88S(AmmbpFvW0uIFfgr6RXWGFVhUszAkXVcJa0RvFngMGNVkywwt1oX(Ev0a2OiJUR8kqz4i7kv(3VcfEEwFnggDx5vGYWr2vQ8VFfkCU8F1Kb)EaPnJ48S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asBgXPZZ6qmw74qT)5Ms8RWisJ00gGqfi0wzcE(QGPPe)k8MOFkVb6Ys6IjwaUQX1elxXILxGuYfybwS4v0F)kuS87(ZI6aqyw0aHXuaZIxGSOimMfB3VZscSjwEVrrpMfVazXFw(DIfQazboyXzbiu5nlOtqDwyIf)zrdeMfmfWSaBwuegZstj(vxHIfhZYdzPGpl7oGRqXYdzPPrt4Dwax9vOyb5xL3SGob1zHjEdp8hSWghsiis0Ix14AsZHObfLFVrrposn08nICstJMW7UUIMN1xJHHcQZctzmu5TPPe)kmIIOwkOolmzUkJHkV12uIFfgrAGWAFxr1BWWLkdh5FNYdyt43qLRRiWPAFVrrV5Vek)Wm4rBQbcRjylsPYV3OOhJGMs8RWANqb1zHjZvzVIop3uIFfgrOcGMehXt5nqxwsxmXcWvnUMy5HSS7aiwCwqPG6UILhYYctSKoPyQP4n8WFWcBCiHGirlEvJRjnFJib4956kYCriyoalW7pyPnaHkqOTYCfo0R31vuocxE9RKmib4cKPjhmQwkcxNLfbAUch6176kkhHlV(vsgKaCbsRBLd7uajEd0LLuCezXYYIfGV3dxPyXFwCLIL)simlRsrymll8vOyb5Jg82XS4fil3ZYHzX1HRNLhYIvddSaBwu0ZYVtSGTOW5kw8WFWIf1vel6KcAJLDVavelAQM8e9RaPMfyXIDS8EJIEmVHh(dwyJdjeejAXV3dxP08nI0(3vu9g8tkL3zW(gVHkxxrGANypM(SoSwyZFuBxeKryRW8mfuNfMmxL9k68m2IuQ87nk6Xg879WvQnJ4uTt0xJHb)EpCLY00Oj8URRiTtWwKsLFVrrp2GFVhUsHOiopBFVkAaBuK5VeYgSRmytEI(vGupDE(DfvVbdxQmCK)DkpGnHFdvUUIa1QVgddfuNfMYyOYBttj(vyefrTuqDwyYCvgdvERvFngg879Wvkttj(vyeHg1ITiLk)EJIESb)EpCLAZir4PANyFVkAaBuKrfn4TJZdfr)vOYOuxIfMMN)lHqoiheg9BQVgdd(9E4kLPPe)kmcSBQ23Bu0B(lHYpmdE0MON3aDzbH6(Dwa(Ks5nlAQ(gpllmXcSyjaYITDQyPPrt4DxxrSOVEwW)PuSyZVNLbSzb5Jg82XSy1WalEbYciS2(zzHjw0PbSjwqMMcByb4FkfllmXIonGnXcYGfaisel4Rcel)U)Sy7ukwSAyGfVG)o1Sa89E4kfVHh(dwyJdjeejAXV3dxP08nI8DfvVb)Ks5DgSVXBOY1veOw91yyWV3dxPmnnAcV76ks7e7X0N1H1cB(JA7IGmcBfMNPG6SWK5QSxrNNXwKsLFVrrp2GFVhUsTjcpv7e77vrdyJImQObVDCEOi6VcvgL6sSW088FjeYb5GWOFteEQ23Bu0B(lHYpmdE0MrK3aDzbH6(Dw0un5j6xbsnllmXcW37HRuS8qwqIilwwwS87el6RXGf9OS4kmKLf(kuSa89E4kflWIf0ZcMcWceZcSzrrymlnL4xDfkEdp8hSWghsiis0IFVhUsP5BezVkAaBuK5VeYgSRmytEI(vGuRfBrkv(9gf9yd(9E4k1MrgrTtSxFngM)siBWUYGn5j6xbsTzzPvFngg879WvkttJMW7UUIMNNaW7Z1vKbSjpjB7uQ8WvQmCm0orFngg879Wvkttj(vyefX5zSfPu53Bu0Jn437HRuBAN23vu9g8tkL3zW(gVHkxxrGA1xJHb)EpCLY0uIFfgrOF60P8gOlliZvHLYFcZITD63PMfNfGV34vJIyzHjwSDkflbFHjwa(EpCLILhYYWvkwGJHMzXlqwwyIfGV34vJIy5HSGerwSOPAYt0VcKAwWVhqILLLHLiinwoml)oXstr46AcKLTIriS8qwco(zb47nE1Oiea89E4kfVHh(dwyJdjeejAb4956ksZLNqrIFVhUsLTbRppCLkdhdndWvlksh)TRYwqBuVzeKwQMOHMGPpRdRf28h12fbz7ScPknJDtt1en0e91yy(lHSb7kd2KNOFfi1g87bKsvAgnMQjt0xJHb)EpCLY0uIFfovre5GTiLkV74NsL9VRO6n4NukVZG9nEdvUUIaNQjtcqOceARm437HRuMMs8RWPkIihSfPu5Dh)uQExr1BWpPuENb7B8gQCDfbovtMOVgdZy1rZWrMuRImnL4xHtf6NQDI(Amm437HRuML18CacvGqBLb)EpCLY0uIFfEkVb6Ys6Ijwa(EJxnkIfB3VZIMQjpr)kqQz5HSGerwSSSy53jw0xJbl2UFhUEwuq8vOyb479Wvkwww)LqS4fillmXcW3B8QrrSalwqyeWs6HBn1SGFpGeMLv9NIfeML3Bu0J5n8WFWcBCiHGirl(9gVAuKMVrKa8(CDfzaBYtY2oLkpCLkdhdTa8(CDfzWV3dxPY2G1NhUsLHJHw7b4956kYCOkytz87nE1OO55j6RXWO7kVcugoYUsL)9RqHZL)RMm43diTzeNN1xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqAZiovl2IuQ87nk6Xg879WvkeHWAb4956kYGFVhUsLTbRppCLkdhdEd0LL0ftSGT5Dclyil)U)SefUybf9SK4iMLL1Fjel6rzzHVcfl3ZIJzr5pXIJzXcIXNUIybwSOimMLF3lwIil43diHzb2SKIXc)SyBNkwIicyb)EajmleITUM4n8WFWcBCiHGirRd6w)bGYyBENO5q0GIYV3OOhhPgA(grA)FbKUcLw79WFWY4GU1FaOm2M3jzqpXrrMRYd1HA)NNbHVXbDR)aqzSnVtYGEIJIm43diHOiQfe(gh0T(daLX28ojd6jokY0uIFfgrrK3aDzbHgnAcVZIMgewJRjwUbliBROnDQalhMLMCWOAMLFNAIfVjwuegZYV7flONL3Bu0Jz5kwq(v5nlOtqDwyIfB3VZcq4Jg0mlkcJz539IfnsJf4VtTTdtSCflEfLf0jOolmXcSzzzXYdzb9S8EJIEml60a2eloli)Q8Mf0jOolmzyrtbRTFwAA0eENfWvFfkwsXDfytGSGojwqBuNq1ZYQuegZYvSaeQ8Mf0jOolmXB4H)Gf24qcbrI2eiSgxtAoenOO87nk6XrQHMVrKnnAcV76ks77nk6n)Lq5hMbpAZjt0aHrWeSfPu53Bu0Jn437X1uQSlv6RXWqb1zHPSAvEBwwtNIGMs8RWtrot0abVRO6nVTRYjqyHnu56kcCQ2jUvoStbKMNb4956kYCOkytz87nE1OO5z7PG6SWK5QSxrNQDsacvGqBLj45RcMMCWOAPG6SWK5QSxr1ApyVoqtbZbqS2ja8(CDfzcWcaejkds4OvyEoaHkqOTYeGfaisu(3Pm2667XMMCWOZZ2hGaOYR3uhQ9ppCA68m2IuQ87nk6Xg8794AcrtMGC1Kj6RXWqb1zHPSAvEBwwPYUPtt1enqW7kQEZB7QCcewydvUUIaNovR9uqDwyYGHkVZfH4xR9biubcTvMGNVkyAYbJoppHcQZctMRYyOY75z91yyOG6SWuwTkVnllT2)UIQ3GHlvgoY)oLhWMWVHkxxrGZZ6RXWy1xcSbpxL9o41fYwlf2BdaxTOnJ0o0N2uTtWwKsLFVrrp2GFVhxtisJ0s1enqW7kQEZB7QCcewydvUUIaNovRJ)2vzlOnQ3e9PPj6RXWGFVhUszAkXVcNkK7uTtSpabqLxVbPO9518S96RXWG0vGnbMPelOnQtO6ZurnQlLKzznptb1zHjZvzmu59uT2RVgdt7aOcUW5rtvkJMXxnwQ8Eu8t95MLfVb6Ys6IjwqdWTWcSyjaYIT73HRNLGBzDfkEdp8hSWghsiis0oGDGYWrU8F1KMVrKUvoStbKMNb4956kYCOkytz87nE1OiEdp8hSWghsiis0cW7Z1vKMlpHImaMdWc8(dwzhsAgGRwuK2d2Rd0uWCaeRDcaVpxxrMayoalW7pyPDI(Amm437HRuML1887kQEd(jLY7myFJ3qLRRiW55aeavE9M6qT)5Htt1ccFtcewJRjZFbKUcL2j2RVgddgQW)fiZYsR96RXWe88vbZYs7e7Fxr1BgRoAgoYKAvKHkxxrGZZ6RXWe88vbd4Q9)G1MbiubcTvMXQJMHJmPwfzAkXVcJGiyQ2j2JPpRdRf28h12fbz7ScZZuqDwyYCvwTkVNNPG6SWKbdvENlcX)uTa8(CDfz(9(uQmMiKOoBZVx7e7dqau51BQd1(NhonphGqfi0wzcWcaejk)7ugBD99yttj(vyePVgdtWZxfmGR2)dwPknd6NQ99gf9M)sO8dZGhTP(AmmbpFvWaUA)pyLQ0mOXPZZ6qmw74qT)5Ms8RWisFngMGNVkyaxT)hSqGg2LQEv0a2OiJvFjWg8Cv27GxxiBTuyVNYBGUSKUyIf0qtvkJYIT73zbzBfTPtf4n8WFWcBCiHGirB7aOcUW5rtvkJQ5BeP(AmmbpFvW0uIFfEtnq)8S(AmmbpFvWaUA)pyHanSlv9QObSrrgR(sGn45QS3bVUq2APWEJi7qUAb4956kYeaZbybE)bRSdjEd0LL0ftSGSTI20PcSalwcGSSkfHXS4filQRiwUNLLfl2UFNfKblaqKiEdp8hSWghsiis0gifH)ZvzxDOQeQEnFJib4956kYeaZbybE)bRSdjTt0xJHj45RcgWv7)bleOHDPQxfnGnkYy1xcSbpxL9o41fYwlf27nJ0oK78S9biaQ86naO63J2tNN1xJHPDaubx48OPkLrnllT6RXW0oaQGlCE0uLYOMMs8RWikfHGaSax3BSAkCyk7QdvLq1B(lHYaC1IqWe71xJHrxbHGQf(nllT2)UIQ3GFVvWg0qLRRiWP8gE4pyHnoKqqKO9QG3L)hS08nIeG3NRRitamhGf49hSYoK4nqxwsxmXc6KybTrnlPhwGSalwcGSy7(Dwa(EpCLILLflEbYc2bqSmGnliKLc7nlEbYcY2kAtNkWB4H)Gf24qcbrIwkXcAJ6SoSa18nICsacvGqBLj45RcMMs8RWiqFngMGNVkyaxT)hSqqVkAaBuKXQVeydEUk7DWRlKTwkS3Psd72maHkqOTYqjwqBuN1HfObC1(FWcbAK205z91yycE(QGPPe)k8MrW8myVoqtbZbqmVb6YccnA0eENLHYBIfyXYYILhYsez59gf9ywSD)oC9SGSTI20PcSOtxHIfxhUEwEileITUMyXlqwk4Zcea1b3Y6ku8gE4pyHnoKqqKOf)Ks5DEO8M0CiAqr53Bu0JJudnFJiBA0eE31vK2)sO8dZGhTPgOxl2IuQ87nk6Xg8794AcriSw3kh2PasANOVgdtWZxfmnL4xH3uJ0MNTxFngMGNVkywwt5nqxwsxmXcAaIoSCdwUcFGelEXc6euNfMyXlqwuxrSCplllwSD)ololiKLc7nlwnmWIxGSSvq36paelaT5DcVHh(dwyJdjeejAhRoAgoYKAvKMVrKuqDwyYCv2ROAN4w5WofqAE2(Ev0a2OiJvFjWg8Cv27GxxiBTuyVNQDI(Ammw9LaBWZvzVdEDHS1sH92aWvlcr2H(0MN1xJHj45RcMMs8RWBgbt1obe(gh0T(daLX28ojd6jokY8xaPRqnpBFacGkVEtrHgQGn48m2IuQ87nk6XBA3uTt0xJHPDaubx48OPkLrnnL4xHrukstMGWPQxfnGnkYGVASu59O4N6ZNQvFngM2bqfCHZJMQug1SSMNTxFngM2bqfCHZJMQug1SSMQDI9biubcTvMGNVkywwZZ6RXW879PuzmrirTb)EajePb61oou7FUPe)kmISlT00oou7FUPe)k8MAKwAZZ2JHlL(vGMFVpLkJjcjQnu56kcCQ2jy4sPFfO537tPYyIqIAdvUUIaNNdqOceARmbpFvW0uIFfEZiM2uTV3OO38xcLFyg8Onr)8SoeJ1oou7FUPe)kmI0inEd0LL0ftS4Sa89E4kflA6f97Sy1WalRsrymlaFVhUsXYHzXvn5GrzzzXcSzjkCXI3elUoC9S8qwGaOo4wSSvmcH3Wd)blSXHecIeT437HRuA(grQVgddSOFhNTOoqw)blZYs7e91yyWV3dxPmnnAcV76kAE2XF7QSf0g1BMIsBkVb6YIMALyXYwXiew0PbSjwqgSaarIyX297Sa89E4kflEbYYVtflaFVXRgfXB4H)Gf24qcbrIw879WvknFJidqau51BQd1(NhoP1(3vu9g8tkL3zW(gVHkxxrGANaW7Z1vKjalaqKOmiHJwH55aeQaH2ktWZxfmlR5z91yycE(QGzznvBacvGqBLjalaqKO8VtzS113JnnL4xHreQaOjXrCQc0PM44VDv2cAJAKd6tBQw91yyWV3dxPmnL4xHrecR1EWEDGMcMdGyEdp8hSWghsiis0IFVXRgfP5BezacGkVEtDO2)8WjTta4956kYeGfaisugKWrRW8CacvGqBLj45RcML18S(AmmbpFvWSSMQnaHkqOTYeGfaisu(3Pm2667XMMs8RWic9Ab4956kYGFVhUsLTbRppCLkdhdTuqDwyYCv2ROAThG3NRRiZHQGnLXV34vJI0ApyVoqtbZbqmVb6Ys6Ijwa(EJxnkIfB3VZIxSOPx0VZIvddSaBwUblrHRTbzbcG6GBXYwXiewSD)olrHRMLIq8ZsWXVHLTQWqwaxjwSSvmcHf)z53jwOcKf4GLFNyjflv)E0Mf91yWYnyb479WvkwSbxkWA7NLHRuSahdwGnlrHlw8MybwSyhlV3OOhZB4H)Gf24qcbrIw87nE1OinFJi1xJHbw0VJZbf5DgWHpyzwwZZtSh)EpUMmUvoStbK0ApaVpxxrMdvbBkJFVXRgfnpprFngMGNVkyAkXVcJi0RvFngMGNVkywwZZtMOVgdtWZxfmnL4xHreQaOjXrCQc0PM44VDv2cAJAKdaVpxxrgmohG4FQw91yycE(QGzznpRVgdt7aOcUW5rtvkJMXxnwQ8Eu8t95MMs8RWicva0K4iovb6utC83UkBbTrnYbG3NRRidgNdq8pvR(AmmTdGk4cNhnvPmAgF1yPY7rXp1NBwwt1gGaOYR3aGQFpApDQ2jylsPYV3OOhBWV3dxPqueNNb4956kYGFVhUsLTbRppCLkdhJPt1ApaVpxxrMdvbBkJFVXRgfPDI99QObSrrM)siBWUYGn5j6xbs98m2IuQ87nk6Xg879WvkefXP8gOllPlMyrtdclmlxXcqOYBwqNG6SWelEbYc2bqSGgwkflAAqyXYa2SGSTI20Pc8gE4pyHnoKqqKOTiB5eiS08nICI(AmmuqDwykJHkVnnL4xH3KqmfwpL)lHMNNe29gfHJ0oTnf29gfL)lHqe6Noph29gfHJmIt16w5WofqI3Wd)blSXHecIeT7UAKtGWsZ3iYj6RXWqb1zHPmgQ820uIFfEtcXuy9u(VeAEEsy3Bueos702uy3Buu(VecrOF68Cy3BueoYiovRBLd7uajTt0xJHPDaubx48OPkLrnnL4xHre61QVgdt7aOcUW5rtvkJAwwATVxfnGnkYGVASu59O4N6ZNNTxFngM2bqfCHZJMQug1SSMYB4H)Gf24qcbrI2XsPYjqyP5Be5e91yyOG6SWugdvEBAkXVcVjHykSEk)xcPDsacvGqBLj45RcMMs8RWBI(0MNdqOceARmbybaIeL)DkJTU(ESPPe)k8MOpTPZZtc7EJIWrAN2Mc7EJIY)Lqic9tNNd7EJIWrgXPADRCyNciPDI(AmmTdGk4cNhnvPmQPPe)kmIqVw91yyAhavWfopAQszuZYsR99QObSrrg8vJLkVhf)uF(8S96RXW0oaQGlCE0uLYOML1uEd0LL0ftSGqbrhwGflittXB4H)Gf24qcbrIwBE3hSZWrMuRI4nqxwqMRclL)eMfB70VtnlpKLfMyb4794AILRybiu5nl22VWolhMf)zb9S8EJIEmc0GLbSzHaqDuwSlnKdljo(PoklWMfeMfGV34vJIybDsSG2OoHQNf87bKW8gE4pyHnoKqqKOfG3NRRinxEcfj(9ECnLVkJHkV1maxTOiXwKsLFVrrp2GFVhxtBIWiyOGWEsIJFQJMb4QfLknslnKJDPnfbdfe2t0xJHb)EJxnkktjwqBuNq1NXqL3g87bKqoi8uEd0LfK5QWs5pHzX2o97uZYdzbHQ9FNfWvFfkwqdnvPmkVHh(dwyJdjeejAb4956ksZLNqrAR9FpFvE0uLYOAgGRwuKAGCWwKsL3D8tiYonzsAg7s1eSfPu53Bu0Jn437X1KMOX0unrde8UIQ3GHlvgoY)oLhWMWVHkxxrGPsdd6NofbPz0a9PsFngM2bqfCHZJMQug10uIFfM3aDzjDXeliuT)7SCflaHkVzbDcQZctSaBwUblfKfGV3JRjwSDkflJ7z5QhYcY2kAtNkWIxrtGnXB4H)Gf24qcbrIwBT)7A(groHcQZctg1Q8oxeI)5zkOolmz8kAUie)Ab4956kYC4CqroaAQ2jV3OO38xcLFyg8Onr45zkOolmzuRY78vz7MN1HyS2XHA)ZnL4xHrKgPnDEwFnggkOolmLXqL3MMs8RWiYd)bld(9ECnzietH1t5)siT6RXWqb1zHPmgQ82SSMNPG6SWK5QmgQ8wR9a8(CDfzWV3JRP8vzmu598S(AmmbpFvW0uIFfgrE4pyzWV3JRjdHykSEk)xcP1EaEFUUImhohuKdG0QVgdtWZxfmnL4xHreHykSEk)xcPvFngMGNVkywwZZ6RXW0oaQGlCE0uLYOMLLwaEFUUIm2A)3ZxLhnvPm68S9a8(CDfzoCoOihaPvFngMGNVkyAkXVcVjHykSEk)xcXBGUSKUyIfGV3JRjwUblxXcYVkVzbDcQZctAMLRybiu5nlOtqDwyIfyXccJawEVrrpMfyZYdzXQHbwacvEZc6euNfM4n8WFWcBCiHGirl(9ECnXBGUSGgCL637fVHh(dwyJdjeejA7vL9WFWkRo8R5YtOihUs979I3G3aDzb47nE1OiwgWMLeiakHQNLvPimMLf(kuSKE4wtnVHh(dwyZWvQFVxrIFVXRgfP5BeP99QObSrrgDx5vGYWr2vQ8VFfkSHIW1zzrG8gOlliZXpl)oXci8zX297S87eljq8ZYFjelpKfheKLv9NILFNyjXrmlGR2)dwSCyw2V3WcWvnUMyPPe)kmljl1FwQJaz5HSK4FyNLeiSgxtSaUA)pyXB4H)Gf2mCL637fcIeT4vnUM0CiAqr53Bu0JJudnFJibHVjbcRX1KPPe)k8MnL4xHtLD2HC0ic4n8WFWcBgUs979cbrI2eiSgxt8g8gOllPlMyzRGU1FaiwaAZ7ewSTtfl)o1elhMLcYIh(daXc2M3jAMfhZIYFIfhZIfeJpDfXcSybBZ7ewSD)ol2XcSzzq2OMf87bKWSaBwGflolrebSGT5Dclyil)U)S87elfzJfSnVtyX7(aqywsXyHFw8Xtnl)U)SGT5DcleITUMW8gE4pyHn4psh0T(daLX28orZHObfLFVrrposn08nI0Eq4BCq36paugBZ7KmON4OiZFbKUcLw79WFWY4GU1FaOm2M3jzqpXrrMRYd1HA)1oXEq4BCq36paugBZ7K8o5kZFbKUc18mi8noOB9hakJT5DsENCLPPe)k8MOF68mi8noOB9hakJT5Dsg0tCuKb)EajefrTGW34GU1FaOm2M3jzqpXrrMMs8RWikIAbHVXbDR)aqzSnVtYGEIJIm)fq6ku8gOllPlMWSGmybaIeXYnybzBfTPtfy5WSSSyb2SefUyXBIfqchTcxHIfKTv0MovGfB3VZcYGfaiselEbYsu4IfVjw0jf0gliCAOnIPnbzKIW)5kwaAD994PSSvmcHLRyXzrJ0qalykWc6euNfMmSSvfgYciS2(zrrplAQM8e9RaPMfcXwxtAMfxzZJIzzHjwUIfKTv0MovGfB3VZcczPWEZIxGS4pl)oXc(9(zboyXzj9WTMAwSDfi0MH3Wd)blSb)iis0gGfaisu(3Pm2667XA(grApyVoqtbZbqS2jta4956kYeGfaisugKWrRGw7dqOceARmbpFvW0KdgvR99QObSrrgR(sGn45QS3bVUq2APWEppRVgdtWZxfmlRPANmXXF7QSf0g1iksaEFUUImbybaIeLDSL2j6RXWqb1zHPSAvEBAkXVcVPgPnpRVgddfuNfMYyOYBttj(v4n1iTPZZ6RXWe88vbttj(v4nrVw91yycE(QGPPe)kmIIud7MQDI99QObSrrM)siBWUYGn5j6xbs98S99QObSrrMaPi8FUkJTU(E88S(Amm)Lq2GDLbBYt0VcKAttj(v4njetH1t5)sOPZZ9QObSrrgDx5vGYWr2vQ8VFfk8uTtSVxfnGnkYO7kVcugoYUsL)9RqHNNNOVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGuKrW8S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asrgbtNopRdXyTJd1(NBkXVcJinstR9biubcTvMGNVkyAYbJoL3aDzjDXelaFVXRgfXYdzbjISyzzXYVtSOPAYt0VcKAw0xJbl3GL7zXgCPazHqS11el60a2elJRo8(vOy53jwkcXplbh)SaBwEilGRelw0PbSjwqgSaarI4n8WFWcBWpcIeT43B8QrrA(gr2RIgWgfz(lHSb7kd2KNOFfi1ANy)Kj6RXW8xczd2vgSjpr)kqQnnL4xH30d)blJT2)DdHykSEk)xcHG0mAODcfuNfMmxL1H)(8mfuNfMmxLXqL3ZZuqDwyYOwL35Iq8pDEwFngM)siBWUYGn5j6xbsTPPe)k8ME4pyzWV3JRjdHykSEk)xcHG0mAODcfuNfMmxLvRY75zkOolmzWqL35Iq8pptb1zHjJxrZfH4F605z71xJH5VeYgSRmytEI(vGuBwwtNNNOVgdtWZxfmlR5zaEFUUImbybaIeLbjC0kmvBacvGqBLjalaqKO8VtzS113Jnn5Gr1gGaOYR3uhQ9ppCs7e91yyOG6SWuwTkVnnL4xH3uJ0MN1xJHHcQZctzmu5TPPe)k8MAK20PANyFacGkVEdsr7ZR55aeQaH2kdLybTrDwhwGMMs8RWBgbt5nqxw0uRelwa(EJxnkcZIT73zj9UYRaXcCWYwvkws9(vOWSaBwEilwnz5nXYa2SGmybaIeXIT73zj9WTMAEdp8hSWg8JGirl(9gVAuKMVrK9QObSrrgDx5vGYWr2vQ8VFfkS2jt0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqAt7MN1xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqAt7MQnaHkqOTYe88vbttj(v4nrJATpaHkqOTYeGfaisu(3Pm2667XML188KaeavE9M6qT)5HtAdqOceARmbybaIeL)DkJTU(ESPPe)kmI0inTuqDwyYCv2ROAD83UkBbTr9M2LgcIyAPkaHkqOTYe88vbttoy0Pt5nqxwqgSaV)GfldyZIRuSacFml)U)SK4irywWRMy53POS4nvB)S00Oj8obYITDQybHMdGk4cZcAOPkLrzz3XSOimMLF3lwqplykGzPPe)QRqXcSz53jwqNelOnQzj9WcKf91yWYHzX1HRNLhYYWvkwGJblWMfVIYc6euNfMy5WS46W1ZYdzHqS11eVHh(dwyd(rqKOfG3NRRinxEcfji8ZnfHRRPeQESMb4Qff5e91yyAhavWfopAQszuttj(v4nr)8S96RXW0oaQGlCE0uLYOML1uT2RVgdt7aOcUW5rtvkJMXxnwQ8Eu8t95MLL2j6RXWG0vGnbMPelOnQtO6ZurnQlLKPPe)kmIqfanjoINQDI(AmmuqDwykJHkVnnL4xH3eva0K4iEEwFnggkOolmLvRYBttj(v4nrfanjoINNNyV(AmmuqDwykRwL3ML18S96RXWqb1zHPmgQ82SSMQ1(3vu9gmuH)lqgQCDfboL3aDzbzWc8(dwS87(ZsyNciHz5gSefUyXBIf46XhiXcfuNfMy5HSalvuwaHpl)o1elWMLdvbBILF)WSy7(Dwacv4)ceVHh(dwyd(rqKOfG3NRRinxEcfji8ZW1Jpqktb1zHjndWvlkYj2RVgddfuNfMYyOYBZYsR96RXWqb1zHPSAvEBwwt1A)7kQEdgQW)fidvUUIa1AFVkAaBuK5VeYgSRmytEI(vGuZBGUSOPGplUsXY7nk6XSy7(9RybH4fiLCbwSD)oC9SabqDWTSUcfc(DIfxhcGyjalW7pyH5n8WFWcBWpcIeTjqynUM0CiAqr53Bu0JJudnFJiNOVgddfuNfMYyOYBttj(v4nBkXVcppRVgddfuNfMYQv5TPPe)k8MnL4xHNNb4956kYac)mC94dKYuqDwyAQ2MgnH3DDfP99gf9M)sO8dZGhTPg2P1TYHDkGKwaEFUUImGWp3ueUUMsO6X8gE4pyHn4hbrIw8QgxtAoenOO87nk6XrQHMVrKt0xJHHcQZctzmu5TPPe)k8MnL4xHNN1xJHHcQZctz1Q820uIFfEZMs8RWZZa8(CDfzaHFgUE8bszkOolmnvBtJMW7UUI0(EJIEZFju(HzWJ2ud706w5WofqslaVpxxrgq4NBkcxxtju9yEdp8hSWg8JGirl(jLY78q5nP5q0GIYV3OOhhPgA(grorFnggkOolmLXqL3MMs8RWB2uIFfEEwFnggkOolmLvRYBttj(v4nBkXVcppdW7Z1vKbe(z46XhiLPG6SW0uTnnAcV76ks77nk6n)Lq5hMbpAtnqUADRCyNciPfG3NRRidi8ZnfHRRPeQEmVb6YIMc(S0hQ9NfDAaBIf0qtvkJYYny5EwSbxkqwCLcAJLOWflpKLMgnH3zrrymlGR(kuSGgAQszuwM87hMfyPIYYUBzrfMfB3VdxplaVASuSGqFu8t95t5n8WFWcBWpcIeTa8(CDfP5YtOilyEpk(P(8m5TkAge(AgGRwuKbiaQ86naO63J2ATVxfnGnkYGVASu59O4N6Z1AFVkAaBuKjCDqrz4iRUbL9cmds(VRnaHkqOTYOtnMAKUcLPjhmQ2aeQaH2kt7aOcUW5rtvkJAAYbJQ1E91yycE(QGzzPDIJ)2vzlOnQ3mcqJZZ6RXWORGqq1c)ML1uEdp8hSWg8JGirBcewJRjnFJib4956kYuW8Eu8t95zYBv0mi812uIFfgr2LgVHh(dwyd(rqKOfVQX1KMVrKa8(CDfzkyEpk(P(8m5TkAge(ABkXVcJinsr8gOllPlMybna3clWILail2UFhUEwcUL1vO4n8WFWcBWpcIeTdyhOmCKl)xnP5BePBLd7uajEd0LL0ftSGojwqBuZs6Hfil2UFNfVIYIcwOyHk4c1olkh)xHIf0jOolmXIxGS8DuwEilQRiwUNLLfl2UFNfeYsH9MfVazbzBfTPtf4n8WFWcBWpcIeTuIf0g1zDybQ5Be5KaeQaH2ktWZxfmnL4xHrG(AmmbpFvWaUA)pyHGEv0a2OiJvFjWg8Cv27GxxiBTuyVtLg2TzacvGqBLHsSG2OoRdlqd4Q9)Gfc0iTPZZ6RXWe88vbttj(v4nJG5zWEDGMcMdGyEd0LfG0JzX2ovSSvmcHf8oCPazrNybCLyrGS8qwk4Zcea1b3ILjAkYIkqmlWIf0WQJYcCWc6OwfXIxGS87elOtqDwyAkVHh(dwyd(rqKOfG3NRRinxEcfPJTYGRelndWvlksh)TRYwqBuVzkknnzIDg0Nk91yygRoAgoYKAvKb)EajnXUurb1zHjZvz1Q8EkVb6Ys6Ijwq2wrB6ubwSD)olidwaGirOnf3vGnbYcqRRVhZIxGSacRTFwGaO2wFpXcczPWEZcSzX2ovSKEfecQw4NfBWLcKfcXwxtSOtdytSGSTI20PcSqi26AcByrtZrIybVAILhYcvp1S4SG8RYBwqNG6SWel22PILf(qvSKA7IawSZkWIxGS4kflittHzX2PuSOtbycXstoyuwWqyXcvWfQDwax9vOy53jw0xJblEbYci8XSS7aiw0jQybVgJlCu9QOS00Oj8obA4n8WFWcBWpcIeTa8(CDfP5YtOidG5aSaV)Gvg)AgGRwuK2d2Rd0uWCaeRDcaVpxxrMayoalW7pyP1E91yycE(QGzzPDI9y6Z6WAHn)rTDrq2oRW8mfuNfMmxLvRY75zkOolmzWqL35Iq8pv7Kjta4956kY4yRm4kXAEoabqLxVPou7FE4088KaeavE9gKI2NxAdqOceARmuIf0g1zDybAAYbJoDEUxfnGnkY8xczd2vgSjpr)kqQNQfe(g8QgxtMMs8RWBgbAbHVjbcRX1KPPe)k8MPiTtaHVb)Ks5DEO8MmnL4xH3uJ0MNT)DfvVb)Ks5DEO8Mmu56kcCQwaEFUUIm)EFkvgtesuNT53R99gf9M)sO8dZGhTP(AmmbpFvWaUA)pyLQ0mOX5z91yy0vqiOAHFZYsR(Amm6kieuTWVPPe)kmI0xJHj45RcgWv7)blemrd7svVkAaBuKXQVeydEUk7DWRlKTwkS3tNoppHIW1zzrGgkXkAtUkdBWYRaPnaHkqOTYqjwrBYvzydwEfittj(vyePbYfnIGjOpv9QObSrrg8vJLkVhf)uF(0Pt1oX(aeavE9M6qT)5HtZZtcqOceARmbybaIeL)DkJTU(ESPPe)kmI0xJHj45RcgWv7)blKJDATVxfnGnkYO7kVcugoYUsL)9RqHNNdqOceARmbybaIeL)DkJTU(ESPjhmQwh)TRYwqBuJi0N205zDigRDCO2)Ctj(vyefGqfi0wzcWcaejk)7ugBD99yttj(v4PZZ6qmw74qT)5Ms8RWisFngMGNVkyaxT)hSqGg2LQEv0a2OiJvFjWg8Cv27GxxiBTuyVNYBGUSKUyIf0qtvkJYIT73zbzBfTPtfyzvkcJzbn0uLYOSydUuGSOC8ZIcwOOMLF3lwq2wrB6ubnZYVtfllmXIonGnXB4H)Gf2GFeejABhavWfopAQszunFJi1xJHj45RcMMs8RWBQb6NN1xJHj45RcgWv7)blezhAeb9QObSrrgR(sGn45QS3bVUq2APWENknStlaVpxxrMayoalW7pyLXpVHh(dwyd(rqKOnqkc)NRYU6qvju9A(grcW7Z1vKjaMdWc8(dwz8RDI(AmmbpFvWaUA)pyTzK2HgrqVkAaBuKXQVeydEUk7DWRlKTwkS3Psd7MNTpabqLxVbav)E0E68S(AmmTdGk4cNhnvPmQzzPvFngM2bqfCHZJMQug10uIFfgrPieeGf46EJvtHdtzxDOQeQEZFjugGRwecMyV(Amm6kieuTWVzzP1(3vu9g87Tc2GgQCDfboL3Wd)blSb)iis0EvW7Y)dwA(grcW7Z1vKjaMdWc8(dwz8ZBGUSKI17Z1vellmbYcSyX1p19hHz539NfBE9S8qw0jwWoacKLbSzbzBfTPtfybdz539NLFNIYI3u9SyZXpbYskgl8ZIonGnXYVtj8gE4pyHn4hbrIwaEFUUI0C5juKyhaLhWoh88vbndWvlkYaeQaH2ktWZxfmnL4xH3uJ0MNThG3NRRitawaGirzqchTcAdqau51BQd1(Nhonpd2Rd0uWCaeZBGUSKUycZcAaIoSCdwUIfVybDcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1mliBROnDQGMzbDsSG2OML0dlqw8cKLTc6w)bGybOnVt4n8WFWcBWpcIeTJvhndhzsTksZ3iskOolmzUk7vuTtC83UkBbTrnIsr2Pj6RXWmwD0mCKj1Qid(9asPc9ZZ6RXW0oaQGlCE0uLYOML1uTt0xJHXQVeydEUk7DWRlKTwkS3gaUAriYoeoT5z91yycE(QGPPe)k8MrWuTa8(CDfzWoakpGDo45RcANyFacGkVEtrHgQGn48mi8noOB9hakJT5Dsg0tCuK5VasxHAQ2j2hGaOYR3aGQFpAppRVgdt7aOcUW5rtvkJAAkXVcJOuKMmbHtvVkAaBuKbF1yPY7rXp1NpvR(AmmTdGk4cNhnvPmQzznpBV(AmmTdGk4cNhnvPmQzznv7e7dqau51BqkAFEnphGqfi0wzOelOnQZ6Wc00uIFfEt7sBQ23Bu0B(lHYpmdE0MOFEwhIXAhhQ9p3uIFfgrAKgVb6Ys6Ijw00l63zb479WvkwSAyaZYnyb479WvkwoCT9ZYYI3Wd)blSb)iis0IFVhUsP5BeP(AmmWI(DC2I6az9hSmllT6RXWGFVhUszAA0eE31veVb6YcY8kqkwa(ERGnil3GL7zz3XSOimMLF3lwqpMLMs8RUcLMzjkCXI3el(ZskkneWYwXiew8cKLFNyjS6MQNf0jOolmXYUJzb9iaZstj(vxHI3Wd)blSb)iis0g8kqQS(Am0C5juK43BfSb18nIuFngg87Tc2GMMs8RWic9ANOVgddfuNfMYyOYBttj(v4nr)8S(AmmuqDwykRwL3MMs8RWBI(PAD83UkBbTr9MPO04nqxwqMxbsXYVtSGqwkS3SOVgdwUbl)oXIvddSydUuG12plQRiwwwSy7(Dw(DILIq8ZYFjelidwaGirSeGjeMf4yWsa0WsQ3pmll8YvQOSalvuw2DllQWSaU6RqXYVtSKEK3WB4H)Gf2GFeejAdEfivwFngAU8eksR(sGn45QS3bVUq2APWER5Be57kQEZvbVl)pyzOY1veOw7Fxr1BkYwobcldvUUIa1MI3KjrmT00eh)TRYwqBuJaeonnbtFwhwlS5pQTlcY2zfsfcN2uKZeeg5GTiLkV74NMQjbiubcTvMaSaarIY)oLXwxFp20uIFfEkIsXBYKiMwAAIJ)2vzlOnQ1e91yyS6lb2GNRYEh86czRLc7TbGRwecq400em9zDyTWM)O2UiiBNviviCAtrotqyKd2IuQ8UJFAQMeGqfi0wzcWcaejk)7ugBD99yttj(v4PAdqOceARmbpFvW0uIFfEZiMMw91yyS6lb2GNRYEh86czRLc7TbGRweIStJ00QVgdJvFjWg8Cv27GxxiBTuyVnaC1I2mIPPnaHkqOTYeGfaisu(3Pm2667XMMs8RWicHtt74qT)5Ms8RWBgGqfi0wzcWcaejk)7ugBD99yttj(vyeGC1oPxfnGnkYeifH)ZvzS113JNNb4956kYeGfaisugKWrRWuEd0LfG0JzX2ovSGqwkS3SG3Hlfil6elwnmeiqwiVvrz5HSOtS46kILhYYctSGmybaIeXcSyjaHkqOTILjOdgt1FUsfLfDkatimlFViwUblGReRRqXYwXiewkOnwSDkflUsbTXsu4ILhYIf1dk8QOSq1tnliKLc7nlEbYYVtfllmXcYGfais0uEdp8hSWg8JGirlaVpxxrAU8eksRggYwlf27m5TkQMb4QffzacGkVEtDO2)8WjT9QObSrrgR(sGn45QS3bVUq2APWERvFnggR(sGn45QS3bVUq2APWEBa4QfHah)TRYwqBuJGiUzKrmT00cW7Z1vKjalaqKOmiHJwbTbiubcTvMaSaarIY)oLXwxFp20uIFfgro(BxLTG2Og5eX0sfQaOjXrSw7b71bAkyoaI1sb1zHjZvzVIQ1XF7QSf0g1BcW7Z1vKjalaqKOSJT0gGqfi0wzcE(QGPPe)k8MON3aDzjDXelaFVhUsXIT73zb4tkL3SOP6B8SaBwE7IawqyRalEbYsbzb47Tc2GAMfB7uXsbzb479WvkwomlllwGnlpKfRggybHSuyVzX2ovS46qaelPO0yzRyeYeyZYVtSqERIYcczPWEZIvddSaW7Z1velhMLVx0uwGnloOL)haIfSnVtyz3XSebiatbmlnL4xDfkwGnlhMLRyzOou7pVHh(dwyd(rqKOf)EpCLsZ3iYjVRO6n4NukVZG9nEdvUUIaNNX0N1H1cB(JA7IGmcBfMQ1(3vu9g87Tc2GgQCDfbQvFngg879WvkttJMW7UUI0AFVkAaBuK5VeYgSRmytEI(vGuRDI(Ammw9LaBWZvzVdEDHS1sH92aWvlAZiTd9PP1E91yycE(QGzzPDcaVpxxrghBLbxjwZZ6RXWG0vGnbMPelOnQtO6ZurnQlLKzznpdW7Z1vKXQHHS1sH9otERIoDEEsacGkVEtrHgQGnO23vu9g8tkL3zW(gVHkxxrGANacFJd6w)bGYyBENKb9ehfzAkXVcVzemp7H)GLXbDR)aqzSnVtYGEIJImxLhQd1(pD6uTtcqOceARmbpFvW0uIFfEtnsBEoaHkqOTYeGfaisu(3Pm2667XMMs8RWBQrAt5nqxw0uRelmlBfJqyrNgWMybzWcaejILf(kuS87elidwaGirSeGf49hSy5HSe2PasSCdwqgSaarIy5WS4HF5kvuwCD46z5HSOtSeC8ZB4H)Gf2GFeejAXV34vJI08nIeG3NRRiJvddzRLc7DM8wfL3aDzjDXelAAqyHzX2ovSefUyXBIfxhUEwEiA9Myj4wwxHILWU3OimlEbYsIJeXcE1el)ofLfVjwUIfVybDcQZctSG)tPyzaBwqOxtdTObnnEdp8hSWg8JGirBr2YjqyP5BePBLd7uajTtc7EJIWrAN2Mc7EJIY)Lqic9ZZHDVrr4iJ4uEdp8hSWg8JGir7URg5eiS08nI0TYHDkGK2jHDVrr4iTtBtHDVrr5)sieH(55WU3OiCKrCQ2j6RXWqb1zHPSAvEBAkXVcVjHykSEk)xcnpRVgddfuNfMYyOYBttj(v4njetH1t5)sOP8gE4pyHn4hbrI2XsPYjqyP5BePBLd7uajTtc7EJIWrAN2Mc7EJIY)Lqic9ZZHDVrr4iJ4uTt0xJHHcQZctz1Q820uIFfEtcXuy9u(VeAEwFnggkOolmLXqL3MMs8RWBsiMcRNY)Lqt5nqxwsxmXcW3B8QrrSOPx0VZIvddyw8cKfWvIflBfJqyX2ovSGSTI20PcAMf0jXcAJAwspSa1ml)oXskwQ(9Onl6RXGLdZIRdxplpKLHRuSahdwGnlrHRTbzj4wSSvmcH3Wd)blSb)iis0IFVXRgfP5BejfuNfMmxL9kQ2j6RXWal63X5GI8od4WhSmlR5z91yyq6kWMaZuIf0g1ju9zQOg1LsYSSMN1xJHj45RcMLL2j2hGaOYR3Gu0(8AEoaHkqOTYqjwqBuN1HfOPPe)k8MOFEwFngMGNVkyAkXVcJiubqtIJ4unuqypXXF7QSf0g1ihaEFUUImyCoaX)0PANyFacGkVEdaQ(9O98S(AmmTdGk4cNhnvPmQPPe)kmIqfanjoItvGo1Kjo(BxLTG2OgbiCAP6DfvVzS6Oz4itQvrgQCDfbof5aW7Z1vKbJZbi(NIGiMQ3vu9MISLtGWYqLRRiqT23RIgWgfzWxnwQ8Eu8t95A1xJHPDaubx48OPkLrnlR5z91yyAhavWfopAQsz0m(QXsL3JIFQp3SSMNNOVgdt7aOcUW5rtvkJAAkXVcJip8hSm437X1KHqmfwpL)lH0ITiLkV74NquAgeEEwFngM2bqfCHZJMQug10uIFfgrE4pyzS1(VBietH1t5)sO5zaEFUUImxecMdWc8(dwAdqOceARmxHd96DDfLJWLx)kjdsaUazAYbJQLIW1zzrGMRWHE9UUIYr4YRFLKbjaxGMQvFngM2bqfCHZJMQug1SSMNTxFngM2bqfCHZJMQug1SS0AFacvGqBLPDaubx48OPkLrnn5GrNopdW7Z1vKXXwzWvI18SoeJ1oou7FUPe)kmIqfanjoItvGo1eh)TRYwqBuJCa4956kYGX5ae)tNYBGUSK6oklpKLehjILFNyrNWplWblaFVvWgKf9OSGFpG0vOy5EwwwSeHRlGKkklxXIxrzbDcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceiVHh(dwyd(rqKOf)EJxnksZ3iY3vu9g87Tc2GgQCDfbQ1(Ev0a2OiZFjKnyxzWM8e9RaPw7e91yyWV3kydAwwZZo(BxLTG2OEZuuAt1QVgdd(9wbBqd(9asikIANOVgddfuNfMYyOYBZYAEwFnggkOolmLvRYBZYAQw91yyS6lb2GNRYEh86czRLc7TbGRweISdnMM2jbiubcTvMGNVkyAkXVcVPgPnpBpaVpxxrMaSaarIYGeoAf0gGaOYR3uhQ9ppCAkVb6Yc6G)lXFcZYo0gljRWolBfJqyXBIfu(veilwuZcMcWc0WIMEPIYY7irywCwWLBH3HpldyZYVtSewDt1Zc((L)hSybdzXgCPaRTFw0jw8qy1(tSmGnlkVrrnl)LqJ2timVHh(dwyd(rqKOfG3NRRinxEcfPJTqiudKcAgGRwuKuqDwyYCvwTkVtveGC8WFWYGFVhxtgcXuy9u(Vecb2tb1zHjZvz1Q8ovtqUi4DfvVbdxQmCK)DkpGnHFdvUUIatveNIC8WFWYyR9F3qiMcRNY)LqiindcJEKd2IuQ8UJFcbPzqFQExr1Bk)xnHZ6UYRazOY1veiVb6YIMALyXcW3B8QrrSCflEXc6euNfMyXXSGHWIfhZIfeJpDfXIJzrbluS4ywIcxSy7ukwOcKLLfl2UFNLiineWITDQyHQN6RqXYVtSueIFwqNG6SWKMzbewB)SOONL7zXQHbwqilf2BnZciS2(zbcGAB99elEXIMEr)olwnmWIxGSybHkw0PbSjwq2wrB6ubw8cKf0jXcAJAwspSa5n8WFWcBWpcIeT43B8QrrA(grAFVkAaBuK5VeYgSRmytEI(vGuRDI(Ammw9LaBWZvzVdEDHS1sH92aWvlcr2HgtBEwFnggR(sGn45QS3bVUq2APWEBa4QfHi7qFAAFxr1BWpPuENb7B8gQCDfbov7ekOolmzUkJHkV164VDv2cAJAeaW7Z1vKXXwieQbsHuPVgddfuNfMYyOYBttj(vyeacFZy1rZWrMuRIm)fqcNBkXVkv2zq)MrqAZZuqDwyYCvwTkV164VDv2cAJAeaW7Z1vKXXwieQbsHuPVgddfuNfMYQv5TPPe)kmcaHVzS6Oz4itQvrM)ciHZnL4xLk7mOFZuuAt1AV(AmmWI(DC2I6az9hSmllT2)UIQ3GFVvWg0qLRRiqTtcqOceARmbpFvW0uIFfEt048mgUu6xbA(9(uQmMiKO2qLRRiqT6RXW879PuzmrirTb)EajefXiQjt6vrdyJIm4RglvEpk(P(8uz3uTJd1(NBkXVcVPgPLM2XHA)ZnL4xHrKDPL28myVoqtbZbq8uTtSpabqLxVbPO9518CacvGqBLHsSG2OoRdlqttj(v4nTBkVb6Ys6Ijw00GWcZYvS4vuwqNG6SWelEbYc2bqSGqVRgianSukw00GWILbSzbzBfTPtfyXlqwsXDfytGSGojwqBuNq1ByzRkmKLfMyzlAAS4filObnnw8NLFNyHkqwGdwqdnvPmklEbYciS2(zrrplAQM8e9RaPMLHRuSahdEdp8hSWg8JGirBr2YjqyP5BePBLd7uajTa8(CDfzWoakpGDo45RcANOVgddfuNfMYQv5TPPe)k8MeIPW6P8Fj08S(AmmuqDwykJHkVnnL4xH3KqmfwpL)lHMYB4H)Gf2GFeejA3D1iNaHLMVrKUvoStbK0cW7Z1vKb7aO8a25GNVkODI(AmmuqDwykRwL3MMs8RWBsiMcRNY)LqZZ6RXWqb1zHPmgQ820uIFfEtcXuy9u(VeAQ2j6RXWe88vbZYAEwFnggR(sGn45QS3bVUq2APWEBa4QfHOiTtJ0MQDI9biaQ86naO63J2ZZ6RXW0oaQGlCE0uLYOMMs8RWiAc61e7svVkAaBuKbF1yPY7rXp1NpvR(AmmTdGk4cNhnvPmQzznpBV(AmmTdGk4cNhnvPmQzznv7e77vrdyJIm)Lq2GDLbBYt0VcK65zcXuy9u(Vecr6RXW8xczd2vgSjpr)kqQnnL4xHNNTxFngM)siBWUYGn5j6xbsTzznL3Wd)blSb)iis0owkvobclnFJiDRCyNciPfG3NRRid2bq5bSZbpFvq7e91yyOG6SWuwTkVnnL4xH3KqmfwpL)lHMN1xJHHcQZctzmu5TPPe)k8MeIPW6P8Fj0uTt0xJHj45RcML18S(Ammw9LaBWZvzVdEDHS1sH92aWvlcrrANgPnv7e7dqau51BqkAFEnpRVgddsxb2eyMsSG2OoHQptf1OUusML1uTtSpabqLxVbav)E0EEwFngM2bqfCHZJMQug10uIFfgrOxR(AmmTdGk4cNhnvPmQzzP1(Ev0a2Oid(QXsL3JIFQpFE2E91yyAhavWfopAQszuZYAQ2j23RIgWgfz(lHSb7kd2KNOFfi1ZZeIPW6P8FjeI0xJH5VeYgSRmytEI(vGuBAkXVcppBV(Amm)Lq2GDLbBYt0VcKAZYAkVb6Ys6IjwqOGOdlWILaiVHh(dwyd(rqKO1M39b7mCKj1QiEd0LL0ftSa89ECnXYdzXQHbwacvEZc6euNfM0mliBROnDQal7oMffHXS8xcXYV7floliuT)7SqiMcRNyrrJNfyZcSurzb5xL3SGob1zHjwomllldliu3VZsQTlcyXoRalu9uZIZcqOYBwqNG6SWel3GfeYsH9Mf8Fkfl7oMffHXS87EXIDAKgl43diHzXlqwq2wrB6ubw8cKfKblaqKiw2DaeljWMy539IfnqJywqMMILMs8RUcLHL0ftS46qael2H(0qoSS74NybC1xHIf0qtvkJYIxGSyND2HCyz3XpXIT73HRNf0qtvkJYB4H)Gf2GFeejAXV3JRjnFJiPG6SWK5QSAvER1E91yyAhavWfopAQszuZYAEMcQZctgmu5DUie)ZZtOG6SWKXRO5Iq8ppRVgdtWZxfmnL4xHrKh(dwgBT)7gcXuy9u(VesR(AmmbpFvWSSMQDI9y6Z6WAHn)rTDrq2oRW8CVkAaBuKXQVeydEUk7DWRlKTwkS3A1xJHXQVeydEUk7DWRlKTwkS3gaUAriYonstBacvGqBLj45RcMMs8RWBQbAu7e7dqau51BQd1(NhonphGqfi0wzcWcaejk)7ugBD99yttj(v4n1anov7e7BpqMVHk18CacvGqBLrNAm1iDfkttj(v4n1anoD68mfuNfMmxL9kQ2j6RXWyZ7(GDgoYKAvKzznpJTiLkV74NquAgeg9ANyFacGkVEdaQ(9O98S96RXW0oaQGlCE0uLYOML1055aeavE9gau97rBTylsPY7o(jeLMbHNYBGUSKUyIfeQ2)DwG)o12omXIT9lSZYHz5kwacvEZc6euNfM0mliBROnDQalWMLhYIvddSG8RYBwqNG6SWeVHh(dwyd(rqKO1w7)oVb6YcAWvQFVx8gE4pyHn4hbrI2Evzp8hSYQd)AU8ekYHRu)EVI)4pog]] )
    

end