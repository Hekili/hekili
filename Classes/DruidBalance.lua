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


    spec:RegisterPack( "Balance", 20220102, [[divuZfqikPEeePUeejTji1NiHmkPkNsQQvbHQxbHmlsGBjvkTlk(feXWukCmsultPONju00OKW1ibTniu6BkLKXPucNdcfRtPKAEkL6EKi7tOQ)brIuhuOsluOupeIQjsjP6IKq1gLkv5JuskYiPKuuNKsswPujVeIe1mPKOBkvQk7uOIFkvQQgQsj6OqKizPusk9uaMQqHRkvk2kLKcFfIegRuPYEfYFf1GjomvlMKESGjd0Lr2Su(mKmALQtRYQHir8Aiy2K62I0UL8BqdNsDCsOSCfphQPRQRRKTdOVtjgpeLZlvSEHsMVi2pQJuokgraa9NIIZMBS5MBO8gBAuEluERIzmJa8DSPia2EabhffbO8ukcqSDTxbkcGT3rdDWOyebadxtGIaS)VnERrcsuDTxbQBXxAWG6(9LQ5Gij2U2Ra1TaUuKJKuqZ(NQrkD70KsQU2RazEK9rauxN(TQksncaO)uuC2CJn3CdL3ytJYBHYBLYiMia(63HteaaxkYJaSFGGufPgbaKWHiaX21EfiwS6Z6a5U6YRLpDyztfWYMBS5MCxCxiF3lueER5U6wwIliibYcaO2hwIn5PgURULfKV7fkcKL3hu0NVglbhtywEilHobnLFFqrp2WD1TSy1sPqGeilRQOaHX(0HfG(CUQMWS07mKrbSypeWm(9bVguelDB8Sypeqd(9bVguuFd3v3YsCbcpqwShk44)kuSGum(VZY1y5EfHz53jwSmWcflkEqF2yYWD1TS095iqSGCybeIaXYVtSaW(M7XS4SOV)1elPWHyPPjKDQAILExJLoWfl7oyPONL97z5EwWx6s)ErWfw3Hfl3VZsS7(JBmybrSGCst4)CnlXvFOQuQEfWY9kcKfmcNDFd3v3Ys3NJaXske)SOO2HA)ZdL6xHvel4av(CqmlUTTUdlpKfvigZs7qT)ywGLUJH7QBzjgd5plXaMsSaBSeBTVZsS1(olXw77S4ywCwW2u4Cnl)Cfc0B4U6ww6(TPIgw6DgYOawqkg)3valifJ)7kGfaVpTBO(SK6GelPWHyzi8PpQEwEilKp6JgwcWuv)7w87ZB4U6ww6EhYybP8vGdbYIINAdTqtkvplHDkGaln4WcYT6SSWokYWDXDf3QGV)eilX21EfiwI7wALSe8IfvILgCvGS4pl7)BJ3AKGevx7vG6w8LgmOUFFPAoisITR9kqDlGlf5ijf0S)PAKs3onPKQR9kqMhzFea9HFCumIaaTPIMOyefhLJIreaQCvnbgf7iaE4pyfbWY4)EeaqchMZ(pyfbylhk44NLnzbPy8FNfVazXzbW7dEnOiwGflaIblwUFNL4CO2Fw6EoXIxGSeByCJblWHfaVpTBiwG)onwomfbim3tZ5ra6Xcf0NnMm6v5tUiK9SKKWcf0NnMmxLXqTpSKKWcf0NnMmxLvH)oljjSqb9zJjJxDYfHSNL(SGMf7HaAu2yz8FNf0Synl2db0SPXY4)E0hfNnJIreaQCvnbgf7iaE4pyfba)(0UHIaeM7P58iawZYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjSynlbiqQ86n1HA)ZnNyjjHfRzbBtAD(9bf9yd(9P5AnlkXIYSKKWI1S8UMQ3u(VgcNvDTxbYqLRQjqwssyPhluqF2yYGHAFYfHSNLKewOG(SXK5QSEv(WsscluqF2yYCvwf(7SKKWcf0NnMmE1jxeYEw6hbqFfLdGrauy0hfNygfJiau5QAcmk2ra8WFWkca(9bVguueGWCpnNhbywf1GdkYO6AVcug2YUwN)9RqHnu5QAcKf0SeGaPYR3uhQ9p3CIf0SGTjTo)(GIESb)(0CTMfLyr5ia6ROCamcGcJ(Opcai18L(JIruCuokgra8WFWkcagQ9jRsEAeaQCvnbgf7OpkoBgfJiau5QAcmk2racZ90CEeG)sjw2MLESSjliolE4pyzSm(VBco(Z)LsSGiw8WFWYGFFA3qMGJ)8FPel9JaG)5cFuCuocGh(dwracUwN9WFWkRp8hbqF4pxEkfbaAtfnrFuCIzumIaqLRQjWOyhbaAhbatFeap8hSIaa0NZv1ueaGUErraW2KwNFFqrp2GFFAUwZs8SOmlOzPhlwZY7AQEd(9rdhqdvUQMazjjHL31u9g8tATpzW5AVHkxvtGS0NLKewW2KwNFFqrp2GFFAUwZs8SSzeaqchMZ(pyfbaa9ywIluXzbwSeteXIL73HRNfW5AplEbYIL73zbW7JgoGS4filBIiwG)onwomfbaOp5YtPiaho7qk6JIJvefJiau5QAcmk2raG2raW0hbWd)bRiaa95CvnfbaORxueaSnP153hu0Jn43N2nelXZIYraajCyo7)Gveaa0JzjOjhiXILDQybW7t7gILGxSSFplBIiwEFqrpMfl7xyNLdZYqAcOxpln4WYVtSO4b9zJjwEilQel2d1Oziqw8cKfl7xyNL2P10WYdzj44pcaqFYLNsraoCoOjhif9rXrHrXicavUQMaJIDeaODeam9ra8WFWkcaqFoxvtraa66ffbWEiGzubqJYMuiSA3qSKKWI9qaZOcGgLn4v1UHyjjHf7HaMrfankBWVp41GIyjjHf7HaMrfankBWVpnxRzjjHf7HaMrfankBARPtg2YKEveljjSypeqZ4aPcUW52qvS6WssclQRwZe88vbZqP(vywuIf1vRzcE(QGbCn(FWILKewa6Z5QAYC4SdPiaGeomN9FWkcGvdFoxvtS87(ZsyNciGz5AS0bUyXhILRyXzbvaKLhYIdeEGS87el47x(FWIfl70qS4S8Zviqpl0hy5WSSWeilxXIk9wiQyj44hhbaOp5YtPiaxLrfaJ(O4GyJIreaQCvnbgf7iaE4pyfbqLgmniCfQiaGeomN9FWkcq3GjwInnyAq4kuSy5(DwqECrIvvbwGdlE7PHfKdlGqeiwUIfKhxKyvvicqyUNMZJa0JLESynlbiqQ86n1HA)ZnNyjjHfRzjaHAqOLYeGfqicu(3Pm2(M7XMLnl9zbnlQRwZe88vbZqP(vywINfLvilOzXAwcqGu51Bas1V3zyjjHLaeivE9gGu97DgwqZI6Q1mbpFvWSSzbnlQRwZmoqQGlCUnufRoMLnlOzPhlQRwZmoqQGlCUnufRoMHs9RWSSnlkRmlDllkKfeNLzvudoOid(Q2sN37GFAo3qLRQjqwssyrD1AMGNVkygk1VcZY2SOSYSKKWIYSGewW2KwN3D8tSSnlkBuOczPpl9zbnla95CvnzUkJkag9rXzRIIreaQCvnbgf7iaH5EAopcqpwuxTMj45RcMHs9RWSeplkRqwqZspwSMLzvudoOid(Q2sN37GFAo3qLRQjqwssyrD1AMXbsfCHZTHQy1XmuQFfMLTzr5TILULLnzbXzrD1AgvnecQx43SSzbnlQRwZmoqQGlCUnufRoMLnl9zjjHfvigZcAwAhQ9ppuQFfMLTzztfYsFwqZcqFoxvtMRYOcGraajCyo7)GveGTe(Sy5(DwCwqECrIvvbw(D)z5WLIEwCw2YLg7dl2dmWcCyXYovS87elTd1(ZYHzXvHRNLhYcvGra8WFWkcGn8pyf9rXzlIIreaQCvnbgf7iaq7iay6Ja4H)GveaG(CUQMIaa01lkcqGonl9yPhlTd1(Nhk1VcZs3YIYkKLULLaeQbHwktWZxfmdL6xHzPpliHfL3InyPplkXsGonl9yPhlTd1(Nhk1VcZs3YIYkKLULLaeQbHwktawaHiq5FNYy7BUhBaxJ)hSyPBzjaHAqOLYeGfqicu(3Pm2(M7XMHs9RWS0NfKWIYBXgS0Nf0SynlJFGzcivVXbbXgczh(XSKKWsac1GqlLj45RcMHs9RWSeplx90yd1(tG52HA)ZdL6xHzjjHLzvudoOitG0e(pxNX23Cp2qLRQjqwqZsac1GqlLj45RcMHs9RWSeplXCdwssyjaHAqOLYeGfqicu(3Pm2(M7XMHs9RWSeplx90yd1(tG52HA)ZdL6xHzPBzr5nyjjHfRzjabsLxVPou7FU5ueaqchMZ(pyfba5UoS0(tywSSt)onSSWxHIfKdlGqeiwkOfwSCAnlUwdTWsh4ILhYc(pTMLGJFw(DIfSNsS4PWv9SaBSGCybeIaHiKhxKyvvGLGJFCeaG(KlpLIaeGfqicugKWDQq0hfhetumIaqLRQjWOyhbaAhbatFeap8hSIaa0NZv1ueaGUErra6Xs7qT)5Hs9RWSeplkRqwssyz8dmtaP6noii2CflXZIc3GL(SGMLES0JLESqk26STjqdLA3zixNHdy5vGybnl9yjaHAqOLYqP2DgY1z4awEfiZqP(vyw2MfLrSBWssclbiqQ86naP637mSGMLaeQbHwkdLA3zixNHdy5vGmdL6xHzzBwugXUvSGiw6XIYkZcIZYSkQbhuKbFvBPZ7DWpnNBOYv1eil9zPplOzXAwcqOgeAPmuQDNHCDgoGLxbYmKd2HL(SKKWcPyRZ2Many4sRP)VcvEwQDybnl9yXAwcqGu51BQd1(NBoXssclbiudcTugmCP10)xHkpl1o5yAfkCl2qzZqP(vyw2MfLv2kyPpljjS0JLaeQbHwkJknyAq4kuMHCWoSKKWI1SmEGm)a1Aw6ZcAw6XspwifBD22eO5kCywVRQPSIT86xPzqc4fiwqZspwcqOgeAPmxHdZ6DvnLvSLx)kndsaVazgYb7WssclE4pyzUchM17QAkRylV(vAgKaEbYaEyxvtGS0NL(SKKWspwifBD22eObV7GqleygoQzyl)WjLQNf0SeGqni0szE4Ks1tG5RWhQ9phtfQWyUPYMHs9RWS0NLKew6Xspwa6Z5QAYaR8ct5FUcb6zrjwuMLKewa6Z5QAYaR8ct5FUcb6zrjwIjl9zbnl9y5NRqGEZRSzihStoaHAqOLILKew(5keO38kBcqOgeAPmdL6xHzjEwU6PXgQ9NaZTd1(Nhk1VcZs3YIYBWsFwssybOpNRQjdSYlmL)5keONfLyztwqZspw(5keO38BAgYb7KdqOgeAPyjjHLFUcb6n)MMaeQbHwkZqP(vywINLREASHA)jWC7qT)5Hs9RWS0TSO8gS0NLKewa6Z5QAYaR8ct5FUcb6zrjw2GL(S0NL(SKKWsacKkVEdcDMZlw6ZssclQqmMf0S0ou7FEOu)kmlBZI6Q1mbpFvWaUg)pyfbaKWH5S)dwra6gmbYYdzbK0Ehw(DILf2rrSaBSG84IeRQcSyzNkww4RqXciCPQjwGfllmXIxGSypeqQEwwyhfXILDQyXlwCqqwiGu9SCywCv46z5HSaEueaG(KlpLIaeaZbybE)bROpkokVrumIaqLRQjWOyhbaAhbatFeap8hSIaa0NZv1ueaGUErraSMfmCPvVc087ZP1zmriqJHkxvtGSKKWs7qT)5Hs9RWSeplBUXgSKKWs7qT)5Hs9RWSSnlBQqwqel9yXk2GLULf1vRz(9506mMieOXGFpGaliolBYsFwssyrD1AMFFoToJjcbAm43diWs8SeZTGLULLESmRIAWbfzWx1w68Eh8tZ5gQCvnbYcIZIczPFeaqchMZ(pyfbWQHpNRQjwwycKLhYciP9oS4vhw(5keOhZIxGSeaXSyzNkwS43FfkwAWHfVyrXx27W5CwShyicaqFYLNsra(9506mMieOjBXVp6JIJYkhfJiau5QAcmk2raajCyo7)GveGUbtSO4P2DgY1S09pGLxbILn3atbmlQudoelolipUiXQQallmzIauEkfbGsT7mKRZWbS8kqracZ90CEeGaeQbHwktWZxfmdL6xHzzBw2CdwqZsac1GqlLjalGqeO8VtzS9n3JndL6xHzzBw2CdwqZspwa6Z5QAY87ZP1zmriqt2IFpljjSOUAnZVpNwNXeHang87beyjEwI5gSGiw6XYSkQbhuKbFvBPZ7DWpnNBOYv1eilioliww6ZsFwqZcqFoxvtMRYOcGSKKWIkeJzbnlTd1(Nhk1VcZY2SeZTkcGh(dwraOu7od56mCalVcu0hfhL3mkgraOYv1eyuSJaas4WC2)bRiaDdMybaCP10FfkwSAxQDybXIPaMfvQbhIfNfKhxKyvvGLfMmrakpLIaGHlTM()ku5zP2jcqyUNMZJa0JLaeQbHwktWZxfmdL6xHzzBwqSSGMfRzjabsLxVbiv)ENHf0SynlbiqQ86n1HA)ZnNyjjHLaeivE9M6qT)5MtSGMLaeQbHwktawaHiq5FNYy7BUhBgk1VcZY2SGyzbnl9ybOpNRQjtawaHiqzqc3PcSKKWsac1GqlLj45RcMHs9RWSSnliww6ZssclbiqQ86naP637mSGMLESynlZQOgCqrg8vTLoV3b)0CUHkxvtGSGMLaeQbHwktWZxfmdL6xHzzBwqSSKKWI6Q1mJdKk4cNBdvXQJzOu)kmlBZIYwbliILESOqwqCwifBD22eO5k8pRWdhCg8aEfLvjTML(SGMf1vRzghivWfo3gQIvhZYML(SKKWIkeJzbnlTd1(Nhk1VcZY2SSPczjjHfsXwNTnbAOu7od56mCalVcelOzjaHAqOLYqP2DgY1z4awEfiZqP(vywINLn3GL(SGMfG(CUQMmxLrfazbnlwZcPyRZ2ManxHdZ6DvnLvSLx)kndsaVaXssclbiudcTuMRWHz9UQMYk2YRFLMbjGxGmdL6xHzjEw2CdwssyrfIXSGML2HA)ZdL6xHzzBw2CJiaE4pyfbadxAn9)vOYZsTt0hfhLJzumIaqLRQjWOyhbaAhbatFeap8hSIaa0NZv1ueaGUErrauxTMj45RcMHs9RWSeplkRqwqZspwSMLzvudoOid(Q2sN37GFAo3qLRQjqwssyrD1AMXbsfCHZTHQy1XmuQFfMLTvIfL30SjliILESetwqCwuxTMrvdHG6f(nlBw6ZcIyPhlBblDllkKfeNf1vRzu1qiOEHFZYML(SG4Sqk26STjqZv4FwHho4m4b8kkRsAnlOzrD1AMXbsfCHZTHQy1XSSzPpljjSOcXywqZs7qT)5Hs9RWSSnlBQqwssyHuS1zBtGgk1UZqUodhWYRaXcAwcqOgeAPmuQDNHCDgoGLxbYmuQFfocaiHdZz)hSIaexTfVdMLfMyXQqkLvNfl3VZcYJlsSQkebaOp5YtPiaNIbMdWc8(dwrFuCu2kIIreaQCvnbgf7iaE4pyfb4kCywVRQPSIT86xPzqc4fOiaH5EAopcaqFoxvtMtXaZbybE)blwqZcqFoxvtMRYOcGrakpLIaCfomR3v1uwXwE9R0mib8cu0hfhLvyumIaqLRQjWOyhbaKWH5S)dwra6gmXYCO2FwuPgCiwcG4iaLNsraW7oi0cbMHJAg2YpCsP6JaeM7P58ia9yjaHAqOLYe88vbZqoyhwqZI1SeGaPYR3uhQ9p3CIf0Sa0NZv1K53NtRZyIqGMSf)EwqZspwcqOgeAPmQ0GPbHRqzgYb7WssclwZY4bY8duRzPpljjSeGaPYR3uhQ9p3CIf0SeGqni0szcWciebk)7ugBFZ9yZqoyhwqZspwa6Z5QAYeGfqicugKWDQaljjSeGqni0szcE(QGzihSdl9zPplOzbe(g8QA3qM)ciCfkwqZspwaHVb)Kw7tUP9Hm)fq4kuSKKWI1S8UMQ3GFsR9j30(qgQCvnbYssclyBsRZVpOOhBWVpTBiwINLyYsFwqZci8nPqy1UHm)fq4kuSGMLESa0NZv1K5WzhsSKKWYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjS44FCD2gAHgwIxjwqmBWsscla95CvnzcWciebkds4ovGLKewuxTMrvdHG6f(nlBw6ZcAwSMfsXwNTnbAUchM17QAkRylV(vAgKaEbILKewifBD22eO5kCywVRQPSIT86xPzqc4fiwqZsac1GqlL5kCywVRQPSIT86xPzqc4fiZqP(vywINLyUblOzXAwuxTMj45RcMLnljjSOcXywqZs7qT)5Hs9RWSSnlwXgra8WFWkcaE3bHwiWmCuZWw(HtkvF0hfhLrSrXicavUQMaJIDeaqchMZ(pyfbig7hMLdZIZY4)onSqAxfo(tSyX7WYdzj1rGyX1AwGfllmXc(9NLFUcb6XS8qwujw0xrGSSSzXY97SG84IeRQcS4filihwaHiqS4fillmXYVtSSzbYcwdFwGflbqwUglQWFNLFUcb6XS4dXcSyzHjwWV)S8ZviqpocqyUNMZJa0JfG(CUQMmWkVWu(NRqGEwSwjwuMf0Synl)Cfc0B(nnd5GDYbiudcTuSKKWspwa6Z5QAYaR8ct5FUcb6zrjwuMLKewa6Z5QAYaR8ct5FUcb6zrjwIjl9zbnl9yrD1AMGNVkyw2SGMLESynlbiqQ86naP637mSKKWI6Q1mJdKk4cNBdvXQJzOu)kmliILESOqwqCwMvrn4GIm4RAlDEVd(P5CdvUQMazPplBRel)Cfc0BELnQRwldUg)pyXcAwuxTMzCGubx4CBOkwDmlBwssyrD1AMXbsfCHZTHQy1jJVQT059o4NMZnlBw6ZssclbiudcTuMGNVkygk1VcZcIyztwINLFUcb6nVYMaeQbHwkd4A8)GflOzXAwuxTMj45RcMLnlOzPhlwZsacKkVEtDO2)CZjwssyXAwa6Z5QAYeGfqicugKWDQal9zbnlwZsacKkVEdcDMZlwssyjabsLxVPou7FU5elOzbOpNRQjtawaHiqzqc3PcSGMLaeQbHwktawaHiq5FNYy7BUhBw2SGMfRzjaHAqOLYe88vbZYMf0S0JLESOUAndf0NnMY6v5JzOu)kmlXZIYBWssclQRwZqb9zJPmgQ9XmuQFfML4zr5nyPplOzXAwMvrn4GImQU2RaLHTSR15F)kuydvUQMazjjHLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpGalkXIczjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87beyrjw2cw6ZsFwssyrD1AgeUcCiWmLAdTqtkvFMkAqDXImlBw6ZssclQqmMf0S0ou7FEOu)kmlBZYMBWsscla95CvnzGvEHP8pxHa9SOelBWsFwqZcqFoxvtMRYOcGraWA4JJa8ZviqVYra8WFWkcWpxHa9kh9rXr5TkkgraOYv1eyuSJa4H)GveGFUcb63mcqyUNMZJa0JfG(CUQMmWkVWu(NRqGEwSwjw2Kf0Synl)Cfc0BELnd5GDYbiudcTuSKKWcqFoxvtgyLxyk)ZviqplkXYMSGMLESOUAntWZxfmlBwqZspwSMLaeivE9gGu97DgwssyrD1AMXbsfCHZTHQy1XmuQFfMfeXspwuiliolZQOgCqrg8vTLoV3b)0CUHkxvtGS0NLTvILFUcb6n)Mg1vRLbxJ)hSybnlQRwZmoqQGlCUnufRoMLnljjSOUAnZ4aPcUW52qvS6KXx1w68Eh8tZ5MLnl9zjjHLaeQbHwktWZxfmdL6xHzbrSSjlXZYpxHa9MFttac1GqlLbCn(FWIf0SynlQRwZe88vbZYMf0S0JfRzjabsLxVPou7FU5eljjSynla95CvnzcWciebkds4ovGL(SGMfRzjabsLxVbHoZ5flOzPhlwZI6Q1mbpFvWSSzjjHfRzjabsLxVbiv)ENHL(SKKWsacKkVEtDO2)CZjwqZcqFoxvtMaSacrGYGeUtfybnlbiudcTuMaSacrGY)oLX23Cp2SSzbnlwZsac1GqlLj45RcMLnlOzPhl9yrD1AgkOpBmL1RYhZqP(vywINfL3GLKewuxTMHc6Zgtzmu7JzOu)kmlXZIYBWsFwqZI1SmRIAWbfzuDTxbkdBzxRZ)(vOWgQCvnbYsscl9yrD1Agvx7vGYWw2168VFfkCU8FnKb)EabwuIffYssclQRwZO6AVcug2YUwN)9RqHZ(e8Im43diWIsSSfS0NL(S0NLKewuxTMbHRahcmtP2ql0Ks1NPIguxSiZYMLKewuHymlOzPDO2)8qP(vyw2MLn3GLKewa6Z5QAYaR8ct5FUcb6zrjw2GL(SGMfG(CUQMmxLrfaJaG1Whhb4NRqG(nJ(O4O8wefJiau5QAcmk2raajCyo7)GveGUbtywCTMf4VtdlWILfMy5EkfZcSyjagbWd)bRialmLVNsXrFuCugXefJiau5QAcmk2raajCyo7)GveaRofoqIfp8hSyrF4NfvhtGSalwW3V8)Gfs0eQdhbWd)bRiaZQYE4pyL1h(JaG)5cFuCuocqyUNMZJaa0NZv1K5Wzhsra0h(ZLNsraCif9rXzZnIIreaQCvnbgf7iaH5EAopcWSkQbhuKr11EfOmSLDTo)7xHcBifBD22eyea8px4JIJYra8WFWkcWSQSh(dwz9H)ia6d)5YtPiaQq)J(O4SPYrXicavUQMaJIDeap8hSIamRk7H)GvwF4pcG(WFU8ukca(J(OpcGk0)OyefhLJIreaQCvnbgf7iaE4pyfbyCGubx4CBOkwDIaas4WC2)bRiaDVHQy1Hfl3VZcYJlsSQkebim3tZ5rauxTMj45RcMHs9RWSeplkRWOpkoBgfJiau5QAcmk2ra8WFWkcGd62)bKYyl(Kgbi0jOP87dk6XrXr5iaH5EAopcG6Q1mQU2RaLHTSR15F)ku4C5)Aid(9acSSnlBblOzrD1Agvx7vGYWw2168VFfkC2NGxKb)Eabw2MLTGf0S0JfRzbe(gh0T)diLXw8jnd6PokY8xaHRqXcAwSMfp8hSmoOB)hqkJT4tAg0tDuK5QCtFO2FwqZspwSMfq4BCq3(pGugBXN08o5AZFbeUcfljjSacFJd62)bKYyl(KM3jxBgk1VcZs8Setw6ZssclGW34GU9FaPm2IpPzqp1rrg87beyzBwIjlOzbe(gh0T)diLXw8jnd6PokYmuQFfMLTzrHSGMfq4BCq3(pGugBXN0mON6OiZFbeUcfl9Jaas4WC2)bRiaDdMyjUGU9FajwayXNuwSStfl(ZIMWyw(DVyXkyj2W4gdwWVhqaZIxGS8qwgQneENfNLTvAtwWVhqGfhZI2FIfhZIneJpvnXcCy5VuIL7zbdz5Ew8zoGeMfKsw4NfV90WIZsmrel43diWcHm7BiC0hfNygfJiau5QAcmk2ra8WFWkcqawaHiq5FNYy7BUhhbaKWH5S)dwra6gmXcYHfqicelwUFNfKhxKyvvGfl7uXIneJpvnXIxGSa)DASCyIfl3VZIZsSHXngSOUAnwSStflGeUtfUcveGWCpnNhbWAwaN1bAkyoaIzbnl9yPhla95CvnzcWciebkds4ovGf0SynlbiudcTuMGNVkygYb7WssclQRwZe88vbZYML(SGMLESOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpGalkXYwWssclQRwZO6AVcug2YUwN)9RqHZ(e8Im43diWIsSSfS0NLKewuHymlOzPDO2)8qP(vyw2MfL3Gf0SeGqni0szcE(QGzOu)kmlXZYwXs)OpkowrumIaqLRQjWOyhbWd)bRiaT10jdBzsVkkcaiHdZz)hSIa09GkoloMLFNyPDd(zbvaKLRy53jwCwInmUXGflxbcTWcCyXY97S87eliL7mNxSOUAnwGdlwUFNfNLTarykWsCbD7)asSaWIpPS4filw87zPbhwqECrIvvbwUgl3ZIfy9SOsSSSzXr5xXIk1GdXYVtSeaz5WS0U6W7eyeGWCpnNhbOhl9yPhlQRwZO6AVcug2YUwN)9RqHZL)RHm43diWs8SGyzjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87beyjEwqSS0Nf0S0JfRzjabsLxVbiv)ENHLKewSMf1vRzghivWfo3gQIvhZYML(S0Nf0S0JfWzDGMcMdGywssyjaHAqOLYe88vbZqP(vywINffUbljjS0JLaeivE9M6qT)5MtSGMLaeQbHwktawaHiq5FNYy7BUhBgk1VcZs8SOWnyPpl9zPpljjS0Jfq4BCq3(pGugBXN0mON6OiZqP(vywINLTGf0SeGqni0szcE(QGzOu)kmlXZIYBWcAwcqGu51BkkmqnCazPpljjSC1tJnu7pbMBhQ9ppuQFfMLTzzlybnlwZsac1GqlLj45RcMHCWoSKKWsacKkVEdcDMZlwqZI6Q1miCf4qGzk1gAHMuQEZYMLKewcqGu51Bas1V3zybnlQRwZmoqQGlCUnufRoMHs9RWSSnligwqZI6Q1mJdKk4cNBdvXQJzzh9rXrHrXicavUQMaJIDeap8hSIae8kq6S6Q1IaeM7P58ia9yrD1Agvx7vGYWw2168VFfkCU8FnKzOu)kmlXZYwzuiljjSOUAnJQR9kqzyl7AD(3Vcfo7tWlYmuQFfML4zzRmkKL(SGMLESeGqni0szcE(QGzOu)kmlXZYwXsscl9yjaHAqOLYqP2ql0KvHfOzOu)kmlXZYwXcAwSMf1vRzq4kWHaZuQn0cnPu9zQOb1flYSSzbnlbiqQ86ni0zoVyPpl9zbnlo(hxNTHwOHL4vILyUrea1vRLlpLIaGFF0WbmcaiHdZz)hSIaGCVcKMfaVpA4aYIL73zXzPilSeByCJblQRwJfVazb5Xfjwvfy5WLIEwCv46z5HSOsSSWey0hfheBumIaqLRQjWOyhbWd)bRia43h8AqrraajCyo7)GveaR(k1MfaVp41GIWSOsn4qSGCybeIafbim3tZ5ra6Xsac1GqlLjalGqeO8VtzS9n3JndL6xHzzBwuilOzXAwaN1bAkyoaIzbnl9ybOpNRQjtawaHiqzqc3PcSKKWsac1GqlLj45RcMHs9RWSSnlkKL(SGMfG(CUQMmbWCawG3FWIL(SGMfRzbe(M2A6KHTmPxfz(lGWvOybnlbiqQ86n1HA)ZnNybnlwZc4SoqtbZbqmlOzHc6ZgtMRYE1Hf0S44FCD2gAHgwINfRyJOpkoBvumIaqLRQjWOyhbaAhbatFeap8hSIaa0NZv1ueaGUErra6XI6Q1mJdKk4cNBdvXQJzOu)kmlXZIczjjHfRzrD1AMXbsfCHZTHQy1XSSzPplOzPhlQRwZGWvGdbMPuBOfAsP6ZurdQlwKzOu)kmlBZcQaOj1rgl9zbnl9yrD1AgkOpBmLXqTpMHs9RWSeplOcGMuhzSKKWI6Q1muqF2ykRxLpMHs9RWSeplOcGMuhzS0pcaiHdZz)hSIay1HLIEwaHplGR5kuS87elubYcSXIvRdKk4cZs3BOkwDualGR5kuSGWvGdbYcLAdTqtkvplWHLRy53jw0o(zbvaKfyJfVyrXd6Zgtraa6tU8ukcai8ZdPyRBOuQEC0hfNTikgraOYv1eyuSJa4H)Gvea8QA3qracZ90CEeGHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkJyzbnlUDoStbeybnla95CvnzaHFEifBDdLs1JJae6e0u(9bf94O4OC0hfhetumIaqLRQjWOyhbWd)bRiaPqy1UHIaeM7P58iad1gcV7QAIf0S8(GIEZFPu(HzWJyjEwuoMgfYcAwC7CyNciWcAwa6Z5QAYac)8qk26gkLQhhbi0jOP87dk6XrXr5OpkokVrumIaqLRQjWOyhbWd)bRia4N0AFYnTpueGWCpnNhbyO2q4DxvtSGML3hu0B(lLYpmdEelXZIYiwwqeldL6xHzbnlUDoStbeybnla95CvnzaHFEifBDdLs1JJae6e0u(9bf94O4OC0hfhLvokgraOYv1eyuSJa4H)GveGgCcug2YL)RHIaas4WC2)bRiaDpyCybwSeazXY97W1ZsWTTVcveGWCpnNhbWTZHDkGq0hfhL3mkgraOYv1eyuSJa4H)Gveak1gAHMSkSaJaas4WC2)bRiakEQn0cnSeBybYILDQyXvHRNLhYcvpnS4SuKfwInmUXGflxbcTWIxGSGDGeln4WcYJlsSQkebim3tZ5ra6Xcf0NnMm6v5tUiK9SKKWcf0NnMmyO2NCri7zjjHfkOpBmz8QtUiK9SKKWI6Q1mQU2RaLHTSR15F)ku4C5)AiZqP(vywINLTYOqwssyrD1Agvx7vGYWw2168VFfkC2NGxKzOu)kmlXZYwzuiljjS44FCD2gAHgwINfeZgSGMLaeQbHwktWZxfmd5GDybnlwZc4SoqtbZbqml9zbnl9yjaHAqOLYe88vbZqP(vywINLyUbljjSeGqni0szcE(QGzihSdl9zjjHfvigZcAwU6PXgQ9NaZTd1(Nhk1VcZY2SO8grFuCuoMrXicavUQMaJIDeap8hSIa0wtNmSLj9QOiaGeomN9FWkcq3dQ4SmhQ9NfvQbhILf(kuSG84gbim3tZ5racqOgeAPmbpFvWmKd2Hf0Sa0NZv1KjaMdWc8(dwSGMLES44FCD2gAHgwINfeZgSGMfRzjabsLxVPou7FU5eljjSeGaPYR3uhQ9p3CIf0S44FCD2gAHgw2MfRydw6ZcAwSMLaeivE9gGu97DgwqZspwSMLaeivE9M6qT)5MtSKKWsac1GqlLjalGqeO8VtzS9n3Jnd5GDyPplOzXAwaN1bAkyoaIJ(O4OSvefJiau5QAcmk2raG2raW0hbWd)bRiaa95CvnfbaORxueaRzbCwhOPG5aiMf0Sa0NZv1KjaMdWc8(dwSGMLES0Jfh)JRZ2ql0Ws8SGy2Gf0S0Jf1vRzq4kWHaZuQn0cnPu9zQOb1flYSSzjjHfRzjabsLxVbHoZ5fl9zjjHf1vRzu1qiOEHFZYMf0SOUAnJQgcb1l8Bgk1VcZY2SOUAntWZxfmGRX)dwS0NLKewuHymlOz5QNgBO2Fcm3ou7FEOu)kmlBZI6Q1mbpFvWaUg)pyXssclbiqQ86n1HA)ZnNyPplOzPhlwZsacKkVEtDO2)CZjwssyPhlo(hxNTHwOHLTzXk2GLKewaHVPTMozylt6vrM)ciCfkw6ZcAw6XcqFoxvtMaSacrGYGeUtfyjjHLaeQbHwktawaHiq5FNYy7BUhBgYb7WsFw6hbaKWH5S)dwraqECrIvvbwSStfl(ZcIzdeXsCXBjl9GJgAHgw(DVyXk2GL4I3swSC)olihwaHiq9zXY97W1ZIgIVcfl)LsSCflXwdHG6f(zXlqw0xrSSSzXY97SGCybeIaXY1y5EwS4ywajCNkqGraa6tU8ukcqamhGf49hSYQq)J(O4OScJIreaQCvnbgf7iaH5EAopcaqFoxvtMayoalW7pyLvH(hbWd)bRiabst4)CD21hQkLQp6JIJYi2OyebGkxvtGrXocqyUNMZJaa0NZv1KjaMdWc8(dwzvO)ra8WFWkcWvbFk)pyf9rXr5TkkgraOYv1eyuSJaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiauqF2yYCvwVkFybXzzlybjS4H)GLb)(0UHmeYOW6P8FPeliIfRzHc6ZgtMRY6v5dliol9ybXYcIy5DnvVbdx6mSL)Dk3GdHFdvUQMazbXzjMS0NfKWIh(dwglJ)7gczuy9u(VuIfeXYgMnzbjSGTjToV74NIaas4WC2)bRiako(Vu)jml7qlSKUc7Sex8wYIpelO8RiqwSPHfmfGfyeaG(KlpLIa4y7TKgaui6JIJYBrumIaqLRQjWOyhbWd)bRia43h8AqrraajCyo7)GveaR(k1MfaVp41GIWSyzNkw(DIL2HA)z5WS4QW1ZYdzHkqfWsBOkwDy5WS4QW1ZYdzHkqfWsh4IfFiw8NfeZgiIL4I3swUIfVyrXd6ZgtkGfKhxKyvvGfTJFmlEb)DAyzlqeMcywGdlDGlwSaxAqwGaPj42SKchILF3lw4eL3GL4I3swSStflDGlwSaxAWsrplaEFWRbfXsbTebim3tZ5ra6XIkeJzbnlx90yd1(tG52HA)ZdL6xHzzBwScwssyPhlQRwZmoqQGlCUnufRoMHs9RWSSnlOcGMuhzSG4SeOtZspwC8pUoBdTqdliHLyUbl9zbnlQRwZmoqQGlCUnufRoMLnl9zPpljjS0Jfh)JRZ2ql0WcIybOpNRQjJJT3sAaqbwqCwuxTMHc6Zgtzmu7JzOu)kmliIfq4BARPtg2YKEvK5Vac48qP(vSG4SSPrHSeplkR8gSKKWIJ)X1zBOfAybrSa0NZv1KXX2BjnaOaliolQRwZqb9zJPSEv(ygk1VcZcIybe(M2A6KHTmPxfz(lGaopuQFfliolBAuilXZIYkVbl9zbnluqF2yYCv2RoSGMLESynlQRwZe88vbZYMLKewSML31u9g87JgoGgQCvnbYsFwqZspw6XI1SeGqni0szcE(QGzzZssclbiqQ86ni0zoVybnlwZsac1GqlLHsTHwOjRclqZYML(SKKWsacKkVEtDO2)CZjw6ZcAw6XI1SeGaPYR3aKQFVZWssclwZI6Q1mbpFvWSSzjjHfh)JRZ2ql0Ws8SGy2GL(SKKWspwExt1BWVpA4aAOYv1eilOzrD1AMGNVkyw2SGMLESOUAnd(9rdhqd(9acSSnlXKLKewC8pUoBdTqdlXZcIzdw6ZsFwssyrD1AMGNVkyw2SGMfRzrD1AMXbsfCHZTHQy1XSSzbnlwZY7AQEd(9rdhqdvUQMaJ(O4OmIjkgraOYv1eyuSJa4H)GveGISKtHWkcaiHdZz)hSIa0nyILUpiSWSCflw5Q8HffpOpBmXIxGSGDGelwn76gI6ElTMLUpiSyPbhwqECrIvvHiaH5EAopcqpwuxTMHc6Zgtz9Q8XmuQFfML4zHqgfwpL)lLyjjHLESe29bfHzrjw2Kf0Smuy3huu(VuILTzrHS0NLKewc7(GIWSOelXKL(SGMf3oh2PacrFuC2CJOyebGkxvtGrXocqyUNMZJa0Jf1vRzOG(SXuwVkFmdL6xHzjEwiKrH1t5)sjwqZspwcqOgeAPmbpFvWmuQFfML4zrHBWssclbiudcTuMaSacrGY)oLX23Cp2muQFfML4zrHBWsFwssyPhlHDFqrywuILnzbnldf29bfL)lLyzBwuil9zjjHLWUpOimlkXsmzPplOzXTZHDkGqeap8hSIaS76wofcROpkoBQCumIaqLRQjWOyhbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPelOzPhlbiudcTuMGNVkygk1VcZs8SOWnyjjHLaeQbHwktawaHiq5FNYy7BUhBgk1VcZs8SOWnyPpljjS0JLWUpOimlkXYMSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyjMS0Nf0S425WofqicGh(dwraAlToNcHv0hfNn3mkgraOYv1eyuSJaas4WC2)bRiaifqfNfyXsamcGh(dwraS4ZCWjdBzsVkk6JIZMXmkgraOYv1eyuSJa4H)Gvea87t7gkcaiHdZz)hSIa0nyIfaVpTBiwEil2dmWcaO2hwu8G(SXelWHfl7uXYvSalDhwSYv5dlkEqF2yIfVazzHjwqkGkol2dmGz5ASCflw5Q8HffpOpBmfbim3tZ5raOG(SXK5QSEv(WsscluqF2yYGHAFYfHSNLKewOG(SXKXRo5Iq2ZssclQRwZyXN5Gtg2YKEvKzzZcAwuxTMHc6Zgtz9Q8XSSzjjHLESOUAntWZxfmdL6xHzzBw8WFWYyz8F3qiJcRNY)LsSGMf1vRzcE(QGzzZs)OpkoBAfrXicGh(dwraSm(VhbGkxvtGrXo6JIZMkmkgraOYv1eyuSJa4H)GveGzvzp8hSY6d)ra0h(ZLNsraAUw)7Zk6J(iaoKIIruCuokgraOYv1eyuSJaaTJaGPpcGh(dwraa6Z5QAkcaqxVOia9yrD1AM)sjlWPYGd5PQxbsJzOu)kmlBZcQaOj1rgliILnmkZssclQRwZ8xkzbovgCipv9kqAmdL6xHzzBw8WFWYGFFA3qgczuy9u(VuIfeXYggLzbnl9yHc6ZgtMRY6v5dljjSqb9zJjdgQ9jxeYEwssyHc6ZgtgV6Klczpl9zPplOzrD1AM)sjlWPYGd5PQxbsJzzZcAwMvrn4GIm)LswGtLbhYtvVcKgdvUQMaJaas4WC2)bRiai31HL2FcZILD63PHLFNyXQpKNg8pStdlQRwJflNwZsZ1AwGTglwUF)kw(DILIq2ZsWXFeaG(KlpLIaaoKNMTCADU5ADg2ArFuC2mkgraOYv1eyuSJaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiawZcf0NnMmxLXqTpSGMLESGTjTo)(GIESb)(0UHyjEwuilOz5DnvVbdx6mSL)Dk3GdHFdvUQMazjjHfSnP153hu0Jn43N2nelXZYwXs)iaGeomN9FWkcaYDDyP9NWSyzN(DAybW7dEnOiwomlwGZVZsWX)vOybcKgwa8(0UHy5kwSYv5dlkEqF2ykcaqFYLNsraoufCOm(9bVguu0hfNygfJiau5QAcmk2ra8WFWkcqawaHiq5FNYy7BUhhbaKWH5S)dwra6gmXcYHfqicelw2PIf)zrtyml)UxSOWnyjU4TKfVazrFfXYYMfl3VZcYJlsSQkebim3tZ5raSMfWzDGMcMdGywqZspw6XcqFoxvtMaSacrGYGeUtfybnlwZsac1GqlLj45RcMHCWoSKKWI6Q1mbpFvWSSzPplOzPhlQRwZqb9zJPSEv(ygk1VcZs8SGyzjjHf1vRzOG(SXugd1(ygk1VcZs8SGyzPplOzPhlwZYSkQbhuKr11EfOmSLDTo)7xHcBOYv1eiljjSOUAnJQR9kqzyl7AD(3Vcfox(VgYGFpGalXZsmzjjHf1vRzuDTxbkdBzxRZ)(vOWzFcErg87beyjEwIjl9zjjHfvigZcAwAhQ9ppuQFfMLTzr5nybnlwZsac1GqlLj45RcMHCWoS0p6JIJvefJiau5QAcmk2ra8WFWkcaEvTBOiaHobnLFFqrpokokhbim3tZ5ra6XYqTHW7UQMyjjHf1vRzOG(SXugd1(ygk1VcZY2SetwqZcf0NnMmxLXqTpSGMLHs9RWSSnlkBfSGML31u9gmCPZWw(3PCdoe(nu5QAcKL(SGML3hu0B(lLYpmdEelXZIYwblDllyBsRZVpOOhZcIyzOu)kmlOzPhluqF2yYCv2RoSKKWYqP(vyw2MfubqtQJmw6hbaKWH5S)dwra6gmXcGv1UHy5kwS9cKsValWIfV687xHILF3Fw0hqcZIYwbMcyw8cKfnHXSy5(DwsHdXY7dk6XS4fil(ZYVtSqfilWglolaGAFyrXd6ZgtS4plkBfSGPaMf4WIMWywgk1V6kuS4ywEilf8zz3bEfkwEild1gcVZc4AUcflw5Q8HffpOpBmf9rXrHrXicavUQMaJIDeap8hSIaGxv7gkcaiHdZz)hSIa0nyIfaRQDdXYdzz3bsS4SGsdvDnlpKLfMyXQqkLvpcqyUNMZJaa0NZv1K5umWCawG3FWIf0SeGqni0szUchM17QAkRylV(vAgKaEbYmKd2Hf0Sqk26STjqZv4WSExvtzfB51VsZGeWlqrFuCqSrXicavUQMaJIDeGWCpnNhbWAwExt1BWpP1(KbNR9gQCvnbYcAw6XI6Q1m43NMR1MHAdH3DvnXcAw6Xc2M0687dk6Xg87tZ1Aw2MLyYssclwZYSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eil9zjjHL31u9gmCPZWw(3PCdoe(nu5QAcKf0SOUAndf0NnMYyO2hZqP(vyw2MLyYcAwOG(SXK5QmgQ9Hf0SOUAnd(9P5ATzOu)kmlBZYwXcAwW2KwNFFqrp2GFFAUwZs8kXIvWsFwqZspwSMLzvudoOiJUtWhhNBAI(RqLrPVuBmzOYv1eiljjS8xkXcsLfRqHSeplQRwZGFFAUwBgk1VcZcIyztw6ZcAwEFqrV5Vuk)Wm4rSeplkmcGh(dwraWVpnxRJ(O4SvrXicavUQMaJIDeap8hSIaGFFAUwhbaKWH5S)dwraqkUFNfapP1(WIvFU2ZYctSalwcGSyzNkwgQneE3v1elQRNf8FAnlw87zPbhwSYobFCml2dmWIxGSaclf9SSWelQudoeli3QJnSa4pTMLfMyrLAWHyb5WciebIf8vbILF3FwSCAnl2dmWIxWFNgwa8(0CTocqyUNMZJa8UMQ3GFsR9jdox7nu5QAcKf0SOUAnd(9P5ATzO2q4DxvtSGMLESynlZQOgCqrgDNGpoo30e9xHkJsFP2yYqLRQjqwssy5VuIfKklwHczjEwScw6ZcAwEFqrV5Vuk)Wm4rSeplXm6JIZwefJiau5QAcmk2ra8WFWkca(9P5ADeaqchMZ(pyfbaP4(DwS6d5PQxbsdllmXcG3NMR1S8qwqGiBww2S87elQRwJf1oS4AmKLf(kuSa49P5AnlWIffYcMcWceZcCyrtymldL6xDfQiaH5EAopcWSkQbhuK5VuYcCQm4qEQ6vG0yOYv1eilOzbBtAD(9bf9yd(9P5AnlXRelXKf0S0JfRzrD1AM)sjlWPYGd5PQxbsJzzZcAwuxTMb)(0CT2muBi8URQjwssyPhla95CvnzahYtZwoTo3CTodBnwqZspwuxTMb)(0CT2muQFfMLTzjMSKKWc2M0687dk6Xg87tZ1AwINLnzbnlVRP6n4N0AFYGZ1EdvUQMazbnlQRwZGFFAUwBgk1VcZY2SOqw6ZsFw6h9rXbXefJiau5QAcmk2raG2raW0hbWd)bRiaa95CvnfbaORxueah)JRZ2ql0Ws8SSfBWs3YspwuEdwqCwuxTM5VuYcCQm4qEQ6vG0yWVhqGL(S0TS0Jf1vRzWVpnxRndL6xHzbXzjMSGewW2KwN3D8tSG4SynlVRP6n4N0AFYGZ1EdvUQMazPplDll9yjaHAqOLYGFFAUwBgk1VcZcIZsmzbjSGTjToV74NybXz5DnvVb)Kw7tgCU2BOYv1eil9zPBzPhlGW30wtNmSLj9QiZqP(vywqCwuil9zbnl9yrD1Ag87tZ1AZYMLKewcqOgeAPm43NMR1MHs9RWS0pcaiHdZz)hSIaGCxhwA)jmlw2PFNgwCwa8(GxdkILfMyXYP1Se8fMybW7tZ1AwEilnxRzb2AkGfVazzHjwa8(GxdkILhYccezZIvFipv9kqAyb)Eabww2raa6tU8ukca(9P5AD2cS(CZ16mS1I(O4O8grXicavUQMaJIDeap8hSIaGFFWRbffbaKWH5S)dwra6gmXcG3h8AqrSy5(DwS6d5PQxbsdlpKfeiYMLLnl)oXI6Q1yXY97W1ZIgIVcflaEFAUwZYY(VuIfVazzHjwa8(GxdkIfyXIvGiwInmUXGf87beWSSQ)0SyfS8(GIECeGWCpnNhbaOpNRQjd4qEA2YP15MR1zyRXcAwa6Z5QAYGFFAUwNTaRp3CTodBnwqZI1Sa0NZv1K5qvWHY43h8AqrSKKWspwuxTMr11EfOmSLDTo)7xHcNl)xdzWVhqGL4zjMSKKWI6Q1mQU2RaLHTSR15F)ku4SpbVid(9acSeplXKL(SGMfSnP153hu0Jn43NMR1SSnlwblOzbOpNRQjd(9P5AD2cS(CZ16mS1I(O4OSYrXicavUQMaJIDeap8hSIa4GU9FaPm2IpPracDcAk)(GIECuCuocqyUNMZJaynl)fq4kuSGMfRzXd)blJd62)bKYyl(KMb9uhfzUk30hQ9NLKewaHVXbD7)aszSfFsZGEQJIm43diWY2SetwqZci8noOB)hqkJT4tAg0tDuKzOu)kmlBZsmJaas4WC2)bRiaDdMybBXNuwWqw(D)zPdCXck6zj1rgll7)sjwu7WYcFfkwUNfhZI2FIfhZIneJpvnXcSyrtyml)UxSetwWVhqaZcCybPKf(zXYovSeteXc(9acywiKzFdf9rXr5nJIreaQCvnbgf7iaE4pyfbifcR2nueGqNGMYVpOOhhfhLJaeM7P58iad1gcV7QAIf0S8(GIEZFPu(HzWJyjEw6Xspwu2kybrS0JfSnP153hu0Jn43N2neliolBYcIZI6Q1muqF2ykRxLpMLnl9zPpliILHs9RWS0NfKWspwuMfeXY7AQEZB5QCkewydvUQMazPplOzPhlbiudcTuMGNVkygYb7WcAwSMfWzDGMcMdGywqZspwa6Z5QAYeGfqicugKWDQaljjSeGqni0szcWciebk)7ugBFZ9yZqoyhwssyXAwcqGu51BQd1(NBoXsFwssybBtAD(9bf9yd(9PDdXY2S0JLESGyzPBzPhlQRwZqb9zJPSEv(yw2SG4SSjl9zPpliol9yrzwqelVRP6nVLRYPqyHnu5QAcKL(S0Nf0SynluqF2yYGHAFYfHSNLKew6Xcf0NnMmxLXqTpSKKWspwOG(SXK5QSk83zjjHfkOpBmzUkRxLpS0Nf0SynlVRP6ny4sNHT8Vt5gCi8BOYv1eiljjSOUAnJ9CPWb8CD2NGxxiBV0yFmaD9IyjELyztfUbl9zbnl9ybBtAD(9bf9yd(9PDdXY2SO8gSG4S0JfLzbrS8UMQ38wUkNcHf2qLRQjqw6ZsFwqZIJ)X1zBOfAyjEwu4gS0TSOUAnd(9P5ATzOu)kmlioliww6ZcAw6XI1SOUAndcxboeyMsTHwOjLQptfnOUyrMLnljjSqb9zJjZvzmu7dljjSynlbiqQ86ni0zoVyPplOzXAwuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYocaiHdZz)hSIay1sTHW7S09bHv7gILRXcYJlsSQkWYHzzihSJcy53PHyXhIfnHXS87EXIcz59bf9ywUIfRCv(WIIh0NnMyXY97Saa(DpfWIMWyw(DVyr5nyb(70y5WelxXIxDyrXd6ZgtSahww2S8qwuilVpOOhZIk1GdXIZIvUkFyrXd6ZgtgwS6Wsrpld1gcVZc4AUcfliLVcCiqwu8uBOfAsP6zzvAcJz5kwaa1(WIIh0NnMI(O4OCmJIreaQCvnbgf7iaE4pyfbObNaLHTC5)AOiaGeomN9FWkcq3Gjw6EW4WcSyjaYIL73HRNLGBBFfQiaH5EAopcGBNd7uaHOpkokBfrXicavUQMaJIDeaODeam9ra8WFWkcaqFoxvtraa66ffbWAwaN1bAkyoaIzbnla95CvnzcG5aSaV)GflOzPhl9yrD1Ag87tZ1AZYMLKewExt1BWpP1(KbNR9gQCvnbYssclbiqQ86n1HA)ZnNyPplOzPhlwZI6Q1myOg)xGmlBwqZI1SOUAntWZxfmlBwqZspwSML31u9M2A6KHTmPxfzOYv1eiljjSOUAntWZxfmGRX)dwSeplbiudcTuM2A6KHTmPxfzgk1VcZcIyzlyPplOzbOpNRQjZVpNwNXeHanzl(9SGMLESynlbiqQ86n1HA)ZnNyjjHLaeQbHwktawaHiq5FNYy7BUhBw2SGMLESOUAnd(9P5ATzOu)kmlBZYMSKKWI1S8UMQ3GFsR9jdox7nu5QAcKL(S0Nf0S8(GIEZFPu(HzWJyjEwuxTMj45RcgW14)blwqCw2WSvS0NLKewuHymlOzPDO2)8qP(vyw2Mf1vRzcE(QGbCn(FWIL(raa6tU8ukcqamhGf49hSYoKI(O4OScJIreaQCvnbgf7iaE4pyfbyCGubx4CBOkwDIaas4WC2)bRiaDdMyP7nufRoSy5(DwqECrIvvHiaH5EAopcG6Q1mbpFvWmuQFfML4zrzfYssclQRwZe88vbd4A8)GflBZsm3Gf0Sa0NZv1KjaMdWc8(dwzhsrFuCugXgfJiau5QAcmk2ra8WFWkcqG0e(pxND9HQsP6Jaas4WC2)bRiaDdMyb5XfjwvfybwSeazzvAcJzXlqw0xrSCpllBwSC)olihwaHiqracZ90CEeaG(CUQMmbWCawG3FWk7qIf0S0Jf1vRzcE(QGbCn(FWIL4vILyUbljjSynlbiqQ86naP637mS0NLKewuxTMzCGubx4CBOkwDmlBwqZI6Q1mJdKk4cNBdvXQJzOu)kmlBZcIHfeXsawGR7n2dfomLD9HQsP6n)LszGUErSGiw6XI1SOUAnJQgcb1l8Bw2SGMfRz5DnvVb)(OHdOHkxvtGS0p6JIJYBvumIaqLRQjWOyhbim3tZ5raa6Z5QAYeaZbybE)bRSdPiaE4pyfb4QGpL)hSI(O4O8wefJiau5QAcmk2ra8WFWkcaLAdTqtwfwGraajCyo7)GveGUbtSO4P2ql0WsSHfilWILailwUFNfaVpnxRzzzZIxGSGDGeln4WYwU0yFyXlqwqECrIvvHiaH5EAopcGkeJzbnlx90yd1(tG52HA)ZdL6xHzzBwuwHSKKWspwuxTMXEUu4aEUo7tWRlKTxASpgGUErSSnlBQWnyjjHf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelXRelBQWnyPplOzrD1Ag87tZ1AZYMf0S0JLaeQbHwktWZxfmdL6xHzjEwSInyjjHfWzDGMcMdGyw6h9rXrzetumIaqLRQjWOyhbWd)bRia4N0AFYnTpueGqNGMYVpOOhhfhLJaeM7P58iad1gcV7QAIf0S8xkLFyg8iwINfLvilOzbBtAD(9bf9yd(9PDdXY2SyfSGMf3oh2PacSGMLESOUAntWZxfmdL6xHzjEwuEdwssyXAwuxTMj45RcMLnl9Jaas4WC2)bRiawTuBi8olnTpelWILLnlpKLyYY7dk6XSy5(D46zb5XfjwvfyrLUcflUkC9S8qwiKzFdXIxGSuWNfiqAcUT9vOI(O4S5grXicavUQMaJIDeap8hSIa0wtNmSLj9QOiaGeomN9FWkcq3Gjw6EqfNLRXYv4dKyXlwu8G(SXelEbYI(kIL7zzzZIL73zXzzlxASpSypWalEbYsCbD7)asSaWIpPracZ90CEeakOpBmzUk7vhwqZI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lILTzztfUblOzPhlGW34GU9FaPm2IpPzqp1rrM)ciCfkwssyXAwcqGu51BkkmqnCazjjHfSnP153hu0JzjEw2KL(SGMLESOUAnZ4aPcUW52qvS6ygk1VcZY2SGyyPBzPhlkKfeNLzvudoOid(Q2sN37GFAo3qLRQjqw6ZcAwuxTMzCGubx4CBOkwDmlBwssyXAwuxTMzCGubx4CBOkwDmlBw6ZcAw6XI1SeGqni0szcE(QGzzZssclQRwZ87ZP1zmriqJb)Eabw2MfLvilOzPDO2)8qP(vyw2MLn3ydwqZs7qT)5Hs9RWSeplkVXgSKKWI1SGHlT6vGMFFoToJjcbAmu5QAcKL(SGMLESGHlT6vGMFFoToJjcbAmu5QAcKLKewcqOgeAPmbpFvWmuQFfML4zjMBWs)OpkoBQCumIaqLRQjWOyhbWd)bRia43NMR1raajCyo7)GveGUbtS4Sa49P5AnlD)f97SypWalRstymlaEFAUwZYHzX1d5GDyzzZcCyPdCXIpelUkC9S8qwGaPj42Sex8wgbim3tZ5rauxTMbw0VJZ20ei7)GLzzZcAw6XI6Q1m43NMR1MHAdH3DvnXssclo(hxNTHwOHL4zbXSbl9J(O4S5MrXicavUQMaJIDeap8hSIaGFFAUwhbaKWH5S)dwraS6RuBwIlElzrLAWHyb5WciebIfl3VZcG3NMR1S4fil)ovSa49bVguueGWCpnNhbiabsLxVPou7FU5elOzXAwExt1BWpP1(KbNR9gQCvnbYcAw6XcqFoxvtMaSacrGYGeUtfyjjHLaeQbHwktWZxfmlBwssyrD1AMGNVkyw2S0Nf0SeGqni0szcWciebk)7ugBFZ9yZqP(vyw2MfubqtQJmwqCwc0PzPhlo(hxNTHwOHfKWIc3GL(SGMf1vRzWVpnxRndL6xHzzBwScwqZI1SaoRd0uWCaeh9rXzZygfJiau5QAcmk2racZ90CEeGaeivE9M6qT)5MtSGMLESa0NZv1KjalGqeOmiH7ubwssyjaHAqOLYe88vbZYMLKewuxTMj45RcMLnl9zbnlbiudcTuMaSacrGY)oLX23Cp2muQFfMLTzbXYcAwuxTMb)(0CT2SSzbnluqF2yYCv2RoSGMfRzbOpNRQjZHQGdLXVp41GIybnlwZc4SoqtbZbqCeap8hSIaGFFWRbff9rXztRikgraOYv1eyuSJa4H)Gvea87dEnOOiaGeomN9FWkcq3Gjwa8(GxdkIfl3VZIxS09x0VZI9adSahwUglDGlfbYceinb3ML4I3swSC)olDGRHLIq2ZsWXVHL4QXqwaxP2Sex8wYI)S87elubYcSXYVtSy1GQFVZWI6Q1y5ASa49P5AnlwGlnyPONLMR1SaBnwGdlDGlw8HybwSSjlVpOOhhbim3tZ5rauxTMbw0VJZbn5tg4Hpyzw2SKKWspwSMf87t7gY425WofqGf0Synla95CvnzoufCOm(9bVgueljjS0Jf1vRzcE(QGzOu)kmlBZIczbnlQRwZe88vbZYMLKew6XspwuxTMj45RcMHs9RWSSnlOcGMuhzSG4SeOtZspwC8pUoBdTqdliHLyUbl9zbnlQRwZe88vbZYMLKewuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZqP(vyw2MfubqtQJmwqCwc0PzPhlo(hxNTHwOHfKWsm3GL(SGMf1vRzghivWfo3gQIvNm(Q2sN37GFAo3SSzPplOzjabsLxVbiv)ENHL(S0Nf0S0JfSnP153hu0Jn43NMR1SSnlXKLKewa6Z5QAYGFFAUwNTaRp3CTodBnw6ZsFwqZI1Sa0NZv1K5qvWHY43h8AqrSGMLESynlZQOgCqrM)sjlWPYGd5PQxbsJHkxvtGSKKWc2M0687dk6Xg87tZ1Aw2MLyYs)OpkoBQWOyebGkxvtGrXocGh(dwrakYsofcRiaGeomN9FWkcq3Gjw6(GWcZYvSaaQ9HffpOpBmXIxGSGDGelDVLwZs3hewS0GdlipUiXQQqeGWCpnNhbOhlQRwZqb9zJPmgQ9XmuQFfML4zHqgfwpL)lLyjjHLESe29bfHzrjw2Kf0Smuy3huu(VuILTzrHS0NLKewc7(GIWSOelXKL(SGMf3oh2PacrFuC2eXgfJiau5QAcmk2racZ90CEeGESOUAndf0NnMYyO2hZqP(vywINfczuy9u(VuILKew6Xsy3hueMfLyztwqZYqHDFqr5)sjw2MffYsFwssyjS7dkcZIsSetw6ZcAwC7CyNciWcAw6XI6Q1mJdKk4cNBdvXQJzOu)kmlBZIczbnlQRwZmoqQGlCUnufRoMLnlOzXAwMvrn4GIm4RAlDEVd(P5CdvUQMazjjHfRzrD1AMXbsfCHZTHQy1XSSzPFeap8hSIaS76wofcROpkoBUvrXicavUQMaJIDeGWCpnNhbOhlQRwZqb9zJPmgQ9XmuQFfML4zHqgfwpL)lLybnl9yjaHAqOLYe88vbZqP(vywINffUbljjSeGqni0szcWciebk)7ugBFZ9yZqP(vywINffUbl9zjjHLESe29bfHzrjw2Kf0Smuy3huu(VuILTzrHS0NLKewc7(GIWSOelXKL(SGMf3oh2PacSGMLESOUAnZ4aPcUW52qvS6ygk1VcZY2SOqwqZI6Q1mJdKk4cNBdvXQJzzZcAwSMLzvudoOid(Q2sN37GFAo3qLRQjqwssyXAwuxTMzCGubx4CBOkwDmlBw6hbWd)bRiaTLwNtHWk6JIZMBrumIaqLRQjWOyhbaKWH5S)dwra6gmXcsbuXzbwSGCREeap8hSIayXN5Gtg2YKEvu0hfNnrmrXicavUQMaJIDeaODeam9ra8WFWkcaqFoxvtraa66ffbaBtAD(9bf9yd(9PDdXs8SyfSGiwAAiCyPhlPo(PPtgORxeliolkVXgSGew2Cdw6ZcIyPPHWHLESOUAnd(9bVguuMsTHwOjLQpJHAFm43diWcsyXkyPFeaqchMZ(pyfba5UoS0(tywSSt)onS8qwwyIfaVpTBiwUIfaqTpSyz)c7SCyw8NffYY7dk6XiszwAWHfcinDyzZnqQSK64NMoSahwScwa8(GxdkIffp1gAHMuQEwWVhqahbaOp5YtPia43N2nu(QmgQ9j6JItm3ikgraOYv1eyuSJaaTJaGPpcGh(dwraa6Z5QAkcaqxVOiakZcsybBtADE3XpXY2SSjlDll9yzdZMSG4S0JfSnP153hu0Jn43N2nelDllkZsFwqCw6XIYSGiwExt1BWWLodB5FNYn4q43qLRQjqwqCwu2Oqw6ZsFwqelByuwHSG4SOUAnZ4aPcUW52qvS6ygk1VchbaKWH5S)dwraqURdlT)eMfl70VtdlpKfKIX)DwaxZvOyP7nufRoraa6tU8ukcGLX)98v52qvS6e9rXjMkhfJiau5QAcmk2ra8WFWkcGLX)9iaGeomN9FWkcq3Gjwqkg)3z5kwaa1(WIIh0NnMyboSCnwkilaEFA3qSy50AwA3ZYvpKfKhxKyvvGfV6KchkcqyUNMZJa0JfkOpBmz0RYNCri7zjjHfkOpBmz8QtUiK9SGMfG(CUQMmhoh0KdKyPplOzPhlVpOO38xkLFyg8iwINfRGLKewOG(SXKrVkFYxL3KLKewAhQ9ppuQFfMLTzr5nyPpljjSOUAndf0NnMYyO2hZqP(vyw2Mfp8hSm43N2nKHqgfwpL)lLybnlQRwZqb9zJPmgQ9XSSzjjHfkOpBmzUkJHAFybnlwZcqFoxvtg87t7gkFvgd1(WssclQRwZe88vbZqP(vyw2Mfp8hSm43N2nKHqgfwpL)lLybnlwZcqFoxvtMdNdAYbsSGMf1vRzcE(QGzOu)kmlBZcHmkSEk)xkXcAwuxTMj45RcMLnljjSOUAnZ4aPcUW52qvS6yw2SGMfG(CUQMmwg)3ZxLBdvXQdljjSynla95CvnzoCoOjhiXcAwuxTMj45RcMHs9RWSepleYOW6P8FPu0hfNyUzumIaqLRQjWOyhbaKWH5S)dwra6gmXcG3N2nelxJLRyXkxLpSO4b9zJjfWYvSaaQ9HffpOpBmXcSyXkqelVpOOhZcCy5HSypWalaGAFyrXd6Zgtra8WFWkca(9PDdf9rXjMXmkgraOYv1eyuSJaas4WC2)bRiaDpxR)9zfbWd)bRiaZQYE4pyL1h(JaOp8NlpLIa0CT(3Nv0h9raAUw)7ZkkgrXr5OyebGkxvtGrXocGh(dwraWVp41GIIaas4WC2)bRiaaEFWRbfXsdoSKcbsPu9SSknHXSSWxHILydJBmIaeM7P58iawZYSkQbhuKr11EfOmSLDTo)7xHcBifBD22ey0hfNnJIreaQCvnbgf7iaE4pyfbaVQ2nueGqNGMYVpOOhhfhLJaeM7P58iaGW3KcHv7gYmuQFfML4zzOu)kmliolBUjliHfL3IiaGeomN9FWkcaYD8ZYVtSacFwSC)ol)oXske)S8xkXYdzXbbzzv)Pz53jwsDKXc4A8)GflhML97nSayvTBiwgk1VcZs6s)NT(iqwEilP(h2zjfcR2nelGRX)dwrFuCIzumIa4H)GveGuiSA3qraOYv1eyuSJ(Opca(JIruCuokgraOYv1eyuSJa4H)Gvea87dEnOOiaGeomN9FWkcq3Gjwa8(GxdkILhYccezZYYMLFNyXQpKNQEfinSOUAnwUgl3ZIf4sdYcHm7BiwuPgCiwAxD49RqXYVtSueYEwco(zboS8qwaxP2SOsn4qSGCybeIafbim3tZ5raMvrn4GIm)LswGtLbhYtvVcKgdvUQMazbnl9yHc6ZgtMRYE1Hf0Synl9yPhlQRwZ8xkzbovgCipv9kqAmdL6xHzjEw8WFWYyz8F3qiJcRNY)LsSGiw2WOmlOzPhluqF2yYCvwf(7SKKWcf0NnMmxLXqTpSKKWcf0NnMm6v5tUiK9S0NLKewuxTM5VuYcCQm4qEQ6vG0ygk1VcZs8S4H)GLb)(0UHmeYOW6P8FPeliILnmkZcAw6Xcf0NnMmxL1RYhwssyHc6Zgtgmu7tUiK9SKKWcf0NnMmE1jxeYEw6ZsFwssyXAwuxTM5VuYcCQm4qEQ6vG0yw2S0NLKew6XI6Q1mbpFvWSSzjjHfG(CUQMmbybeIaLbjCNkWsFwqZsac1GqlLjalGqeO8VtzS9n3Jnd5GDybnlbiqQ86n1HA)ZnNyPplOzPhlwZsacKkVEdcDMZlwssyjaHAqOLYqP2ql0KvHfOzOu)kmlXZYwWsFwqZspwuxTMj45RcMLnljjSynlbiudcTuMGNVkygYb7Ws)OpkoBgfJiau5QAcmk2ra8WFWkcGd62)bKYyl(Kgbi0jOP87dk6XrXr5iaH5EAopcG1SacFJd62)bKYyl(KMb9uhfz(lGWvOybnlwZIh(dwgh0T)diLXw8jnd6PokYCvUPpu7plOzPhlwZci8noOB)hqkJT4tAENCT5VacxHILKewaHVXbD7)aszSfFsZ7KRndL6xHzjEwuil9zjjHfq4BCq3(pGugBXN0mON6Oid(9acSSnlXKf0SacFJd62)bKYyl(KMb9uhfzgk1VcZY2SetwqZci8noOB)hqkJT4tAg0tDuK5VacxHkcaiHdZz)hSIa0nyIL4c62)bKybGfFszXYovS870qSCywkilE4pGelyl(KQawCmlA)jwCml2qm(u1elWIfSfFszXY97SSjlWHLgzHgwWVhqaZcCybwS4SeteXc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdiHzbPKf(zXBpnS87(Zc2IpPSqiZ(gch9rXjMrXicavUQMaJIDeap8hSIaeGfqicu(3Pm2(M7XraajCyo7)GveGUbtywqoSacrGy5ASG84IeRQcSCyww2Sahw6axS4dXciH7uHRqXcYJlsSQkWIL73zb5WciebIfVazPdCXIpelQKgAHfRydwIlElJaeM7P58iawZc4SoqtbZbqmlOzPhl9ybOpNRQjtawaHiqzqc3PcSGMfRzjaHAqOLYe88vbZqoyhwqZI1SmRIAWbfzSNlfoGNRZ(e86cz7Lg7JHkxvtGSKKWI6Q1mbpFvWSSzPplOzXX)46Sn0cnSSTsSyfBWcAw6XI6Q1muqF2ykRxLpMHs9RWSeplkVbljjSOUAndf0NnMYyO2hZqP(vywINfL3GL(SKKWIkeJzbnlTd1(Nhk1VcZY2SO8gSGMfRzjaHAqOLYe88vbZqoyhw6h9rXXkIIreaQCvnbgf7iaq7iay6Ja4H)GveaG(CUQMIaa01lkcqpwuxTMzCGubx4CBOkwDmdL6xHzjEwuiljjSynlQRwZmoqQGlCUnufRoMLnl9zbnlwZI6Q1mJdKk4cNBdvXQtgFvBPZ7DWpnNBw2SGMLESOUAndcxboeyMsTHwOjLQptfnOUyrMHs9RWSSnlOcGMuhzS0Nf0S0Jf1vRzOG(SXugd1(ygk1VcZs8SGkaAsDKXssclQRwZqb9zJPSEv(ygk1VcZs8SGkaAsDKXsscl9yXAwuxTMHc6Zgtz9Q8XSSzjjHfRzrD1AgkOpBmLXqTpMLnl9zbnlwZY7AQEdgQX)fidvUQMazPFeaqchMZ(pyfba5Wc8(dwS0GdlUwZci8XS87(ZsQJaHzbVgILFN6WIpuPONLHAdH3jqwSStflwToqQGlmlDVHQy1HLDhZIMWyw(DVyrHSGPaMLHs9RUcflWHLFNybHoZ5flQRwJLdZIRcxplpKLMR1SaBnwGdlE1HffpOpBmXYHzXvHRNLhYcHm7BOiaa9jxEkfbae(5HuS1nukvpo6JIJcJIreaQCvnbgf7iaq7iay6Ja4H)GveaG(CUQMIaa01lkcqpwSMf1vRzOG(SXugd1(yw2SGMfRzrD1AgkOpBmL1RYhZYML(SKKWY7AQEdgQX)fidvUQMaJaas4WC2)bRiaihwG3FWILF3Fwc7uabmlxJLoWfl(qSaxp(ajwOG(SXelpKfyP7Wci8z53PHyboSCOk4qS87hMfl3VZcaOg)xGIaa0NC5Pueaq4NHRhFGuMc6ZgtrFuCqSrXicavUQMaJIDeap8hSIaKcHv7gkcqyUNMZJamuBi8URQjwqZspwuxTMHc6Zgtzmu7JzOu)kmlXZYqP(vywssyrD1AgkOpBmL1RYhZqP(vywINLHs9RWSKKWcqFoxvtgq4NHRhFGuMc6ZgtS0Nf0SmuBi8URQjwqZY7dk6n)Ls5hMbpIL4zr5nzbnlUDoStbeybnla95CvnzaHFEifBDdLs1JJae6e0u(9bf94O4OC0hfNTkkgraOYv1eyuSJa4H)Gvea8QA3qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjEwgk1VcZssclQRwZqb9zJPSEv(ygk1VcZs8SmuQFfMLKewa6Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkVjlOzXTZHDkGalOzbOpNRQjdi8ZdPyRBOuQECeGqNGMYVpOOhhfhLJ(O4SfrXicavUQMaJIDeap8hSIaGFsR9j30(qracZ90CEeGHAdH3DvnXcAw6XI6Q1muqF2ykJHAFmdL6xHzjEwgk1VcZssclQRwZqb9zJPSEv(ygk1VcZs8SmuQFfMLKewa6Z5QAYac)mC94dKYuqF2yIL(SGMLHAdH3DvnXcAwEFqrV5Vuk)Wm4rSeplkJyzbnlUDoStbeybnla95CvnzaHFEifBDdLs1JJae6e0u(9bf94O4OC0hfhetumIaqLRQjWOyhbWd)bRian4eOmSLl)xdfbaKWH5S)dwra6gmXs3dghwGflbqwSC)oC9SeCB7Rqfbim3tZ5raC7CyNcie9rXr5nIIreaQCvnbgf7iaE4pyfbGsTHwOjRclWiaGeomN9FWkcq3GjwqkFf4qGSaW(M7XSy5(Dw8QdlAyHIfQGlu7SOD8Ffkwu8G(SXelEbYYpDy5HSOVIy5Eww2Sy5(Dw2YLg7dlEbYcYJlsSQkebim3tZ5ra6XspwuxTMHc6Zgtzmu7JzOu)kmlXZIYBWssclQRwZqb9zJPSEv(ygk1VcZs8SO8gS0Nf0SeGqni0szcE(QGzOu)kmlXZsm3Gf0S0Jf1vRzSNlfoGNRZ(e86cz7Lg7JbORxelBZYMwXgSKKWI1SmRIAWbfzSNlfoGNRZ(e86cz7Lg7JHuS1zBtGS0NL(SKKWI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lIL4vILn3QnyjjHf1vRzcE(QGzOu)kmlXZIYBe9rXrzLJIreaQCvnbgf7iaq7iay6Ja4H)GveaG(CUQMIaa01lkcG1SaoRd0uWCaeZcAwa6Z5QAYeaZbybE)blwqZspw6Xsac1GqlLHsT7mKRZWbS8kqMHs9RWSSnlkJy3kwqel9yrzLzbXzzwf1GdkYGVQT059o4NMZnu5QAcKL(SGMfsXwNTnbAOu7od56mCalVcel9zjjHfh)JRZ2ql0Ws8kXcIzdwqZspwSML31u9M2A6KHTmPxfzOYv1eiljjSOUAntWZxfmGRX)dwSeplbiudcTuM2A6KHTmPxfzgk1VcZcIyzlyPplOzbe(g8QA3qMHs9RWSeplBblOzbe(MuiSA3qMHs9RWSepligwqZspwaHVb)Kw7tUP9HmdL6xHzjEwuEdwssyXAwExt1BWpP1(KBAFidvUQMazPplOzbOpNRQjZVpNwNXeHanzl(9SGMLESeGqni0szOuBOfAYQWc0SSzjjHfRzjabsLxVbHoZ5fl9zbnlVpOO38xkLFyg8iwINf1vRzcE(QGbCn(FWIfeNLnmBfljjSOcXywqZs7qT)5Hs9RWSSnlQRwZe88vbd4A8)GfljjSeGaPYR3uhQ9p3CILKewuxTMrvdHG6f(nlBwqZI6Q1mQAieuVWVzOu)kmlBZI6Q1mbpFvWaUg)pyXcIyPhligwqCwMvrn4GIm2ZLchWZ1zFcEDHS9sJ9Xqk26STjqw6ZsFwqZI1SOUAntWZxfmlBwqZspwSMLaeivE9M6qT)5MtSKKWsac1GqlLjalGqeO8VtzS9n3JnlBwssyrfIXSGML2HA)ZdL6xHzzBwcqOgeAPmbybeIaL)DkJTV5ESzOu)kmliIfelljjSOcXywqZs7qT)5Hs9RWSGuzr5Tydw2Mf1vRzcE(QGbCn(FWIL(raajCyo7)GveGUbtSG84IeRQcSy5(DwqoSacrGqcs5RahcKfa23CpMfVazbewk6zbcKglZ9elB5sJ9Hf4WILDQyj2AieuVWplwGlnileYSVHyrLAWHyb5XfjwvfyHqM9neocaqFYLNsracG5aSaV)Gvg)rFuCuEZOyebGkxvtGrXocGh(dwraghivWfo3gQIvNiaGeomN9FWkcq3Gjw(DIfRgu97DgwSC)ololipUiXQQal)U)SC4srplTbMYYwU0yFIaeM7P58iaQRwZe88vbZqP(vywINfLviljjSOUAntWZxfmGRX)dwSSnlXCtwqZcqFoxvtMayoalW7pyLXF0hfhLJzumIaqLRQjWOyhbim3tZ5raa6Z5QAYeaZbybE)bRm(zbnl9yrD1AMGNVkyaxJ)hSyjELyjMBYssclwZsacKkVEdqQ(9odl9zjjHf1vRzghivWfo3gQIvhZYMf0SOUAnZ4aPcUW52qvS6ygk1VcZY2SGyybrSeGf46EJ9qHdtzxFOQuQEZFPugORxeliILESynlQRwZOQHqq9c)MLnlOzXAwExt1BWVpA4aAOYv1eil9Ja4H)GveGaPj8FUo76dvLs1h9rXrzRikgraOYv1eyuSJaeM7P58iaa95CvnzcG5aSaV)Gvg)ra8WFWkcWvbFk)pyf9rXrzfgfJiau5QAcmk2raG2raW0hbWd)bRiaa95CvnfbaORxueaRzjaHAqOLYe88vbZqoyhwssyXAwa6Z5QAYeGfqicugKWDQalOzjabsLxVPou7FU5eljjSaoRd0uWCaehbaKWH5S)dwraSA4Z5QAILfMazbwS4QN((JWS87(ZIfVEwEilQelyhibYsdoSG84IeRQcSGHS87(ZYVtDyXhQEwS44NazbPKf(zrLAWHy53P0iaa9jxEkfba7aPCdo5GNVke9rXrzeBumIaqLRQjWOyhbWd)bRiaT10jdBzsVkkcaiHdZz)hSIa0nycZs3dQ4SCnwUIfVyrXd6ZgtS4fil)CeMLhYI(kIL7zzzZIL73zzlxASpkGfKhxKyvvGfVazjUGU9FajwayXN0iaH5EAopcaf0NnMmxL9QdlOzXTZHDkGalOzrD1Ag75sHd456SpbVUq2EPX(ya66fXY2SSPvSblOzPhlGW34GU9FaPm2IpPzqp1rrM)ciCfkwssyXAwcqGu51BkkmqnCazPplOzbOpNRQjd2bs5gCYbpFvGf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MfedlDll9yrHSG4SmRIAWbfzWx1w68Eh8tZ5gQCvnbYcIyXAwifBD22eO5k8pRWdhCg8aEfLvjTML(SGMf1vRzghivWfo3gQIvhZYMLKewSMf1vRzghivWfo3gQIvhZYML(SGMLESynlbiqQ86ni0zoVyjjHLaeQbHwkdLAdTqtwfwGMHs9RWSeplBUbl9J(O4O8wffJiau5QAcmk2ra8WFWkca(9P5ADeaqchMZ(pyfbOBWelD)f97Sa49P5Anl2dmGz5ASa49P5AnlhUu0ZYYocqyUNMZJaOUAndSOFhNTPjq2)blZYMf0SOUAnd(9P5ATzO2q4DxvtrFuCuElIIreaQCvnbgf7iaH5EAopcG6Q1m43hnCandL6xHzzBwuilOzPhlQRwZqb9zJPmgQ9XmuQFfML4zrHSKKWI6Q1muqF2ykRxLpMHs9RWSeplkKL(SGMfh)JRZ2ql0Ws8SGy2icGh(dwracEfiDwD1ArauxTwU8ukca(9rdhWOpkokJyIIreaQCvnbgf7iaE4pyfba)(GxdkkcaiHdZz)hSIay1xP2ywIlElzrLAWHyb5WciebILf(kuS87elihwaHiqSeGf49hSy5HSe2PacSCnwqoSacrGy5WS4HF5ADhwCv46z5HSOsSeC8hbim3tZ5racqGu51BQd1(NBoXcAwa6Z5QAYeGfqicugKWDQalOzjaHAqOLYeGfqicu(3Pm2(M7XMHs9RWSSnlkKf0SynlGZ6anfmhaXSGMfkOpBmzUk7vhwqZIJ)X1zBOfAyjEwSInI(O4S5grXicavUQMaJIDeap8hSIaGFFAUwhbaKWH5S)dwra6gmXcG3NMR1Sy5(Dwa8Kw7dlw95AplEbYsbzbW7JgoGkGfl7uXsbzbW7tZ1AwomllBfWsh4IfFiwUIfRCv(WIIh0NnMyPbhw2ceHPaMf4WYdzXEGbw2YLg7dlw2PIfxfcKybXSblXfVLSahwCqB)pGelyl(KYYUJzzlqeMcywgk1V6kuSahwomlxXstFO2FdlXb(el)U)SSkqAy53jwWEkXsawG3FWcZY9kcZcOnMLIw)4AwEilaEFAUwZc4AUcflwToqQGlmlDVHQy1rbSyzNkw6axkcKf8FAnlubYYYMfl3VZcIzde5yBwAWHLFNyr74NfuAOQRXMiaH5EAopcW7AQEd(jT2Nm4CT3qLRQjqwqZI1S8UMQ3GFF0Wb0qLRQjqwqZI6Q1m43NMR1MHAdH3DvnXcAw6XI6Q1muqF2ykRxLpMHs9RWSeplBblOzHc6ZgtMRY6v5dlOzrD1Ag75sHd456SpbVUq2EPX(ya66fXY2SSPc3GLKewuxTMXEUu4aEUo7tWRlKTxASpgGUErSeVsSSPc3Gf0S44FCD2gAHgwINfeZgSKKWci8noOB)hqkJT4tAg0tDuKzOu)kmlXZYwWssclE4pyzCq3(pGugBXN0mON6OiZv5M(qT)S0Nf0SeGqni0szcE(QGzOu)kmlXZIYBe9rXztLJIreaQCvnbgf7iaE4pyfba)(GxdkkcaiHdZz)hSIa0nyIfaVp41GIyP7VOFNf7bgWS4filGRuBwIlElzXYovSG84IeRQcSahw(DIfRgu97DgwuxTglhMfxfUEwEilnxRzb2ASahw6axkcKLGBZsCXBzeGWCpnNhbqD1Agyr)ooh0KpzGh(GLzzZssclQRwZGWvGdbMPuBOfAsP6ZurdQlwKzzZssclQRwZe88vbZYMf0S0Jf1vRzghivWfo3gQIvhZqP(vyw2MfubqtQJmwqCwc0PzPhlo(hxNTHwOHfKWsm3GL(SGiwIjliolVRP6nfzjNcHLHkxvtGSGMfRzzwf1GdkYGVQT059o4NMZnu5QAcKf0SOUAnZ4aPcUW52qvS6yw2SKKWI6Q1mbpFvWmuQFfMLTzbva0K6iJfeNLaDAw6XIJ)X1zBOfAybjSeZnyPpljjSOUAnZ4aPcUW52qvS6KXx1w68Eh8tZ5MLnljjS0Jf1vRzghivWfo3gQIvhZqP(vyw2Mfp8hSm43N2nKHqgfwpL)lLybnlyBsRZ7o(jw2MLnmwbljjSOUAnZ4aPcUW52qvS6ygk1VcZY2S4H)GLXY4)UHqgfwpL)lLyjjHfG(CUQMmNIbMdWc8(dwSGMLaeQbHwkZv4WSExvtzfB51VsZGeWlqMHCWoSGMfsXwNTnbAUchM17QAkRylV(vAgKaEbIL(SGMf1vRzghivWfo3gQIvhZYMLKewSMf1vRzghivWfo3gQIvhZYMf0SynlbiudcTuMXbsfCHZTHQy1XmKd2HLKewSMLaeivE9gGu97Dgw6Zssclo(hxNTHwOHL4zbXSblOzHc6ZgtMRYE1j6JIZMBgfJiau5QAcmk2ra8WFWkca(9bVguueaqchMZ(pyfbigthwEilPocel)oXIkHFwGnwa8(OHdilQDyb)EaHRqXY9SSSzrXwxabDhwUIfV6WIIh0NnMyrD9SSLln2hwoC9S4QW1ZYdzrLyXEGHabgbim3tZ5raExt1BWVpA4aAOYv1eilOzXAwMvrn4GIm)LswGtLbhYtvVcKgdvUQMazbnl9yrD1Ag87JgoGMLnljjS44FCD2gAHgwINfeZgS0Nf0SOUAnd(9rdhqd(9acSSnlXKf0S0Jf1vRzOG(SXugd1(yw2SKKWI6Q1muqF2ykRxLpMLnl9zbnlQRwZypxkCapxN9j41fY2ln2hdqxViw2MLn3Qnybnl9yjaHAqOLYe88vbZqP(vywINfL3GLKewSMfG(CUQMmbybeIaLbjCNkWcAwcqGu51BQd1(NBoXs)OpkoBgZOyebGkxvtGrXoca0ocaM(iaE4pyfbaOpNRQPiaaD9IIaqb9zJjZvz9Q8HfeNLTGfKWIh(dwg87t7gYqiJcRNY)LsSGiwSMfkOpBmzUkRxLpSG4S0JfelliIL31u9gmCPZWw(3PCdoe(nu5QAcKfeNLyYsFwqclE4pyzSm(VBiKrH1t5)sjwqelByScfYcsybBtADE3XpXcIyzdJczbXz5DnvVP8FneoR6AVcKHkxvtGraajCyo7)Gveafh)xQ)eMLDOfwsxHDwIlElzXhIfu(veil20WcMcWcmcaqFYLNsraCS9wsdake9rXztRikgraOYv1eyuSJa4H)Gvea87dEnOOiaGeomN9FWkcGvFLAZcG3h8AqrSCflolBfIWuGfaqTpSO4b9zJjfWciSu0ZIMEwUNf7bgyzlxASpS0739NLdZYUxGAcKf1oSq3Vtdl)oXcG3NMR1SOVIyboS87elXfVLXJy2Gf9veln4WcG3h8Aqr9valGWsrplqG0yzUNyXlw6(l63zXEGbw8cKfn9S87elUkeiXI(kILDVa1elaEF0WbmcqyUNMZJaynlZQOgCqrM)sjlWPYGd5PQxbsJHkxvtGSGMLESOUAnJ9CPWb8CD2NGxxiBV0yFmaD9IyzBw2CR2GLKewuxTMXEUu4aEUo7tWRlKTxASpgGUErSSnlBQWnybnlVRP6n4N0AFYGZ1EdvUQMazPplOzPhluqF2yYCvgd1(WcAwC8pUoBdTqdliIfG(CUQMmo2ElPbafybXzrD1AgkOpBmLXqTpMHs9RWSGiwaHVPTMozylt6vrM)ciGZdL6xXcIZYMgfYs8SSfBWsscluqF2yYCvwVkFybnlo(hxNTHwOHfeXcqFoxvtghBVL0aGcSG4SOUAndf0NnMY6v5JzOu)kmliIfq4BARPtg2YKEvK5Vac48qP(vSG4SSPrHSepliMnyPplOzXAwuxTMbw0VJZ20ei7)GLzzZcAwSML31u9g87JgoGgQCvnbYcAw6Xsac1GqlLj45RcMHs9RWSeplBfljjSGHlT6vGMFFoToJjcbAmu5QAcKf0SOUAnZVpNwNXeHang87beyzBwIzmzPBzPhlZQOgCqrg8vTLoV3b)0CUHkxvtGSG4SOqw6ZcAwAhQ9ppuQFfML4zr5n2Gf0S0ou7FEOu)kmlBZYMBSbljjSaoRd0uWCaeZsFwqZspwcqOgeAPmiCf4qGzS9n3JndL6xHzjEw2kwssyXAwcqGu51BqOZCEXs)OpkoBQWOyebGkxvtGrXocGh(dwrakYsofcRiaGeomN9FWkcq3Gjw6(GWcZYvSyLRYhwu8G(SXelEbYc2bsSy1SRBiQ7T0Aw6(GWILgCyb5XfjwvfyXlqwqkFf4qGSO4P2ql0Ks1hbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPeljjS0JLWUpOimlkXYMSGMLHc7(GIY)LsSSnlkKL(SKKWsy3hueMfLyjMS0Nf0S425WofqGf0Sa0NZv1Kb7aPCdo5GNVke9rXzteBumIaqLRQjWOyhbim3tZ5ra6XI6Q1muqF2ykRxLpMHs9RWSepleYOW6P8FPelOzXAwcqGu51BqOZCEXsscl9yrD1AgeUcCiWmLAdTqtkvFMkAqDXImlBwqZsacKkVEdcDMZlw6Zsscl9yjS7dkcZIsSSjlOzzOWUpOO8FPelBZIczPpljjSe29bfHzrjwIjljjSOUAntWZxfmlBw6ZcAwC7CyNciWcAwa6Z5QAYGDGuUbNCWZxfybnl9yrD1AMXbsfCHZTHQy1XmuQFfMLTzPhlkKLULLnzbXzzwf1GdkYGVQT059o4NMZnu5QAcKL(SGMf1vRzghivWfo3gQIvhZYMLKewSMf1vRzghivWfo3gQIvhZYML(ra8WFWkcWURB5uiSI(O4S5wffJiau5QAcmk2racZ90CEeGESOUAndf0NnMY6v5JzOu)kmlXZcHmkSEk)xkXcAwSMLaeivE9ge6mNxSKKWspwuxTMbHRahcmtP2ql0Ks1NPIguxSiZYMf0SeGaPYR3GqN58IL(SKKWspwc7(GIWSOelBYcAwgkS7dkk)xkXY2SOqw6ZssclHDFqrywuILyYssclQRwZe88vbZYML(SGMf3oh2PacSGMfG(CUQMmyhiLBWjh88vbwqZspwuxTMzCGubx4CBOkwDmdL6xHzzBwuilOzrD1AMXbsfCHZTHQy1XSSzbnlwZYSkQbhuKbFvBPZ7DWpnNBOYv1eiljjSynlQRwZmoqQGlCUnufRoMLnl9Ja4H)GveG2sRZPqyf9rXzZTikgraOYv1eyuSJaas4WC2)bRiaDdMybPaQ4SalwcGra8WFWkcGfFMdozylt6vrrFuC2eXefJiau5QAcmk2ra8WFWkca(9PDdfbaKWH5S)dwra6gmXcG3N2nelpKf7bgybau7dlkEqF2ysbSG84IeRQcSS7yw0egZYFPel)UxS4SGum(VZcHmkSEIfn1EwGdlWs3HfRCv(WIIh0NnMy5WSSSJaeM7P58iauqF2yYCvwVkFybnlwZI6Q1mJdKk4cNBdvXQJzzZsscluqF2yYGHAFYfHSNLKewOG(SXKXRo5Iq2Zsscl9yrD1Agl(mhCYWwM0RImlBwssybBtADE3XpXY2SSHXkuilOzXAwcqGu51Bas1V3zyjjHfSnP15Dh)elBZYggRGf0SeGaPYR3aKQFVZWsFwqZI6Q1muqF2ykRxLpMLnljjS0Jf1vRzcE(QGzOu)kmlBZIh(dwglJ)7gczuy9u(VuIf0SOUAntWZxfmlBw6h9rXjMBefJiau5QAcmk2raajCyo7)GveGUbtSGum(VZc83PXYHjwSSFHDwomlxXcaO2hwu8G(SXKcyb5XfjwvfyboS8qwShyGfRCv(WIIh0NnMIa4H)GvealJ)7rFuCIPYrXicavUQMaJIDeaqchMZ(pyfbO75A9VpRiaE4pyfbywv2d)bRS(WFea9H)C5PueGMR1)(SI(OpcG9qbyQQ)rXikokhfJiaE4pyfbaHRahcmJTV5ECeaQCvnbgf7OpkoBgfJiau5QAcmk2raG2raW0hbWd)bRiaa95CvnfbaORxueGnIaas4WC2)bRiaXyNybOpNRQjwomly6z5HSSblwUFNLcYc(9NfyXYctS8ZviqpwbSOmlw2PILFNyPDd(zbwelhMfyXYctkGLnz5AS87elykalqwomlEbYsmz5ASOc)Dw8HIaa0NC5PueayLxyk)ZviqF0hfNygfJiau5QAcmk2raG2raCqWiaE4pyfbaOpNRQPiaaD9IIaOCeGWCpnNhb4NRqGEZRSz3X5fMYQRwJf0S8ZviqV5v2eGqni0szaxJ)hSybnlwZYpxHa9MxzZHnpmLYWwofw4FGlCoal8pRWFWchbaOp5YtPiaWkVWu(NRqG(OpkowrumIaqLRQjWOyhbaAhbWbbJa4H)GveaG(CUQMIaa01lkcWMracZ90CEeGFUcb6n)MMDhNxykRUAnwqZYpxHa9MFttac1GqlLbCn(FWIf0Synl)Cfc0B(nnh28WukdB5uyH)bUW5aSW)Sc)blCeaG(KlpLIaaR8ct5FUcb6J(O4OWOyebGkxvtGrXoca0ocGdcgbWd)bRiaa95CvnfbaOp5YtPiaWkVWu(NRqG(iaH5EAopcaPyRZ2ManxHdZ6DvnLvSLx)kndsaVaXssclKIToBBc0qP2DgY1z4awEfiwssyHuS1zBtGgmCP10)xHkpl1oraajCyo7)GveGyStyILFUcb6XS4dXsbFw81dt9)cUw3Hfq6PWtGS4ywGfllmXc(9NLFUcb6Xgwyba9Sa0NZv1elpKfRGfhZYVtDyX1yilfrGSGTPW5Aw29cuFfkteaGUErraSIOpkoi2OyebWd)bRiaPqyHWv5gCsJaqLRQjWOyh9rXzRIIreaQCvnbgf7iaE4pyfbWY4)EeGWCpnNhbOhluqF2yYOxLp5Iq2ZsscluqF2yYCvgd1(WsscluqF2yYCvwf(7SKKWcf0NnMmE1jxeYEw6hbqFfLdGrauEJOp6J(iaaPbFWkkoBUXMkRSYBgZiaw8PUcfocasrCTAJJvfhRM2Awyjg7elxQnCEwAWHffbTPIgfXYqk26gcKfmmLyXxpm1FcKLWUxOiSH7YkVIyzZTMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEkJS(gUlR8kILyU1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDXDHuexR24yvXXQPTMfwIXoXYLAdNNLgCyrrGuZx6xrSmKITUHazbdtjw81dt9NazjS7fkcB4USYRiwqSBnlihwaP5jqwaCPiNfCN6DKXcsLLhYIvUCwapGh(GflqBA8hoS0dj9zPNYiRVH7YkVIybXU1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSSvBnlihwaP5jqwu0SkQbhuKP7uelpKffnRIAWbfz6odvUQMavel9ugz9nCxw5velBXwZcYHfqAEcKfaxkYzb3PEhzSGuz5HSyLlNfWd4HpyXc0Mg)Hdl9qsFw6TjY6B4USYRiw2ITMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEkJS(gUlR8kIfeZwZcYHfqAEcKffnRIAWbfz6ofXYdzrrZQOgCqrMUZqLRQjqfXspLrwFd3LvEfXcIzRzb5WcinpbYII(5keO3OSP7uelpKff9ZviqV5v20DkILEBIS(gUlR8kIfeZwZcYHfqAEcKff9ZviqVztt3PiwEilk6NRqGEZVPP7uel92ez9nCxw5velkVXwZcYHfqAEcKffnRIAWbfz6ofXYdzrrZQOgCqrMUZqLRQjqfXspLrwFd3LvEfXIYkV1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSO8MBnlihwaP5jqwu0SkQbhuKP7uelpKffnRIAWbfz6odvUQMavel9ugz9nCxw5velkhZTMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEkJS(gUlR8kIfLv4wZcYHfqAEcKffnRIAWbfz6ofXYdzrrZQOgCqrMUZqLRQjqfXspLrwFd3LvEfXIYi2TMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEBIS(gUlR8kIfLrSBnlihwaP5jqwu0pxHa9gLnDNIy5HSOOFUcb6nVYMUtrS0BtK13WDzLxrSOmIDRzb5WcinpbYII(5keO3SPP7uelpKff9ZviqV5300DkILEkJS(gUlR8kIfL3QTMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEBIS(gUlR8kIfL3QTMfKdlG08eilk6NRqGEJYMUtrS8qwu0pxHa9Mxzt3Piw6PmY6B4USYRiwuER2AwqoSasZtGSOOFUcb6nBA6ofXYdzrr)Cfc0B(nnDNIyP3MiRVH7I7cPiUwTXXQIJvtBnlSeJDILl1gopln4WIIShkatv9xrSmKITUHazbdtjw81dt9NazjS7fkcB4USYRiwI5wZcYHfqAEcKff9ZviqVrzt3PiwEilk6NRqGEZRSP7uel9IjY6B4USYRiwSITMfKdlG08eilk6NRqGEZMMUtrS8qwu0pxHa9MFtt3Piw6ftK13WDXDHuexR24yvXXQPTMfwIXoXYLAdNNLgCyrroKueldPyRBiqwWWuIfF9Wu)jqwc7EHIWgUlR8kIfL3AwqoSasZtGSOOzvudoOit3PiwEilkAwf1GdkY0DgQCvnbQiw8NffV73kzPNYiRVH7YkVIyjMBnlihwaP5jqwu0SkQbhuKP7uelpKffnRIAWbfz6odvUQMavel9ugz9nCxw5veli2TMfKdlG08eilaUuKZcUt9oYybPIuz5HSyLlNLui4sVWSaTPXF4WspKAFw6PmY6B4USYRiwqSBnlihwaP5jqwu0SkQbhuKP7uelpKffnRIAWbfz6odvUQMavel92ez9nCxw5velB1wZcYHfqAEcKfaxkYzb3PEhzSGurQS8qwSYLZskeCPxywG204pCyPhsTpl9ugz9nCxw5velB1wZcYHfqAEcKffnRIAWbfz6ofXYdzrrZQOgCqrMUZqLRQjqfXspLrwFd3LvEfXYwS1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSGy2AwqoSasZtGSa4srol4o17iJfKklpKfRC5SaEap8blwG204pCyPhs6ZsVnrwFd3LvEfXIYBU1SGCybKMNazbWLICwWDQ3rglivwEilw5Yzb8aE4dwSaTPXF4WspK0NLEkJS(gUlR8kILn3yRzb5WcinpbYIIMvrn4GImDNIy5HSOOzvudoOit3zOYv1eOIyPNYiRVH7YkVIyzZn3AwqoSasZtGSa4srol4o17iJfKklpKfRC5SaEap8blwG204pCyPhs6ZspLrwFd3LvEfXYMwXwZcYHfqAEcKfaxkYzb3PEhzSGuz5HSyLlNfWd4HpyXc0Mg)Hdl9qsFw6TjY6B4USYRiw20k2AwqoSasZtGSOOzvudoOit3PiwEilkAwf1GdkY0DgQCvnbQiw6PmY6B4USYRiw2eXU1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSS5wT1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSSjIzRzb5WcinpbYcGlf5SG7uVJmwqQS8qwSYLZc4b8WhSybAtJ)WHLEiPpl92ez9nCxw5velXCJTMfKdlG08eilaUuKZcUt9oYybPYYdzXkxolGhWdFWIfOnn(dhw6HK(S0tzK13WDXDHuexR24yvXXQPTMfwIXoXYLAdNNLgCyrrnxR)9zPiwgsXw3qGSGHPel(6HP(tGSe29cfHnCxw5velBU1SGCybKMNazbWLICwWDQ3rglivwEilw5Yzb8aE4dwSaTPXF4WspK0NLEkJS(gUlUlKI4A1ghRkownT1SWsm2jwUuB48S0Gdlkc)kILHuS1neilyykXIVEyQ)eilHDVqryd3LvEfXIYBnlihwaP5jqwu0SkQbhuKP7uelpKffnRIAWbfz6odvUQMavel9ugz9nCxw5velXCRzb5WcinpbYIIMvrn4GImDNIy5HSOOzvudoOit3zOYv1eOIyPNYiRVH7YkVIyrzL3AwqoSasZtGSa4srol4o17iJfKksLLhYIvUCwsHGl9cZc0Mg)Hdl9qQ9zPNYiRVH7YkVIyrzL3AwqoSasZtGSOOzvudoOit3PiwEilkAwf1GdkY0DgQCvnbQiw6PmY6B4USYRiwugXU1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0tzK13WDzLxrSSPYBnlihwaP5jqwaCPiNfCN6DKXcsLLhYIvUCwapGh(GflqBA8hoS0dj9zP3MiRVH7YkVIyztL3AwqoSasZtGSOOzvudoOit3PiwEilkAwf1GdkY0DgQCvnbQiw6PmY6B4USYRiw2CZTMfKdlG08eilkAwf1GdkY0DkILhYIIMvrn4GImDNHkxvtGkILEkJS(gUlR8kILnJ5wZcYHfqAEcKfaxkYzb3PEhzSGuz5HSyLlNfWd4HpyXc0Mg)Hdl9qsFw6ftK13WDzLxrSSPvS1SGCybKMNazrrZQOgCqrMUtrS8qwu0SkQbhuKP7mu5QAcurS0BtK13WDzLxrSSjIDRzb5WcinpbYIIMvrn4GImDNIy5HSOOzvudoOit3zOYv1eOIyPNYiRVH7YkVIyzZTARzb5WcinpbYIIMvrn4GImDNIy5HSOOzvudoOit3zOYv1eOIyPNYiRVH7I7cPiUwTXXQIJvtBnlSeJDILl1gopln4WIIuH(RiwgsXw3qGSGHPel(6HP(tGSe29cfHnCxw5velkVvBnlihwaP5jqwaCPiNfCN6DKXcsLLhYIvUCwapGh(GflqBA8hoS0dj9zPxmrwFd3LvEfXIYBXwZcYHfqAEcKfaxkYzb3PEhzSGuz5HSyLlNfWd4HpyXc0Mg)Hdl9qsFw6PmY6B4U4USQuB48eilBflE4pyXI(Wp2WDfbWEGTttraqAKMLy7AVcelw9zDGCxinsZsxET8PdlBQaw2CJn3K7I7cPrAwq(UxOi8wZDH0inlDllXfeKazbau7dlXM8ud3fsJ0S0TSG8DVqrGS8(GI(81yj4ycZYdzj0jOP87dk6XgUlKgPzPBzXQLsHajqwwvrbcJ9Pdla95CvnHzP3ziJcyXEiGz87dEnOiw624zXEiGg87dEnOO(gUlKgPzPBzjUaHhil2dfC8Ffkwqkg)3z5ASCVIWS87elwgyHIffpOpBmz4UqAKMLULLUphbIfKdlGqeiw(DIfa23CpMfNf99VMyjfoelnnHStvtS07AS0bUyz3blf9SSFpl3Zc(sx63lcUW6oSy5(DwID3FCJbliIfKtAc)NRzjU6dvLs1RawUxrGSGr4S7B4UqAKMLULLUphbILui(zrrTd1(Nhk1VcRiwWbQ85GywCBBDhwEilQqmML2HA)XSalDhd3fsJ0S0TSeJH8NLyatjwGnwIT23zj2AFNLyR9DwCmlolyBkCUMLFUcb6nCxinsZs3Ys3Vnv0WsVZqgfWcsX4)UcybPy8FxbSa49PDd1NLuhKyjfoeldHp9r1ZYdzH8rF0WsaMQ6F3IFFEd3fsJ0S0TS09oKXcs5RahcKffp1gAHMuQEwc7uabwAWHfKB1zzHDuKH7I7cPrAwIBvW3FcKLy7AVcelXDlTswcEXIkXsdUkqw8NL9)TXBnsqIQR9kqDl(sdgu3VVunhejX21EfOUfWLICKKcA2)unsPBNMus11EfiZJSN7I7Yd)blSXEOamv1FLq4kWHaZy7BUhZDH0SeJDIfG(CUQMy5WSGPNLhYYgSy5(Dwkil43FwGfllmXYpxHa9yfWIYSyzNkw(DIL2n4NfyrSCywGfllmPaw2KLRXYVtSGPaSaz5WS4filXKLRXIk83zXhI7Yd)blSXEOamv1FePesa6Z5QAsbLNskbR8ct5FUcb6vaqxViL2G7Yd)blSXEOamv1FePesa6Z5QAsbLNskbR8ct5FUcb6va0wjheubaD9IuszfCnL(5keO3OSz3X5fMYQRwd9pxHa9gLnbiudcTugW14)bl0w)ZviqVrzZHnpmLYWwofw4FGlCoal8pRWFWcZD5H)Gf2ypuaMQ6pIucja95CvnPGYtjLGvEHP8pxHa9kaARKdcQaGUErkTPcUMs)Cfc0B20S748ctz1vRH(NRqGEZMMaeQbHwkd4A8)GfAR)5keO3SP5WMhMszylNcl8pWfohGf(Nv4pyH5UqAwIXoHjw(5keOhZIpelf8zXxpm1)l4ADhwaPNcpbYIJzbwSSWel43Fw(5keOhByHfa0ZcqFoxvtS8qwScwCml)o1HfxJHSuebYc2McNRzz3lq9vOmCxE4pyHn2dfGPQ(JiLqcqFoxvtkO8usjyLxyk)ZviqVcG2k5GGkaORxKswHcUMsKIToBBc0CfomR3v1uwXwE9R0mib8cuscPyRZ2ManuQDNHCDgoGLxbkjHuS1zBtGgmCP10)xHkpl1oCxE4pyHn2dfGPQ(JiLqskewiCvUbNuUlp8hSWg7HcWuv)rKsiXY4)Uc0xr5aOskVHcUMs9OG(SXKrVkFYfHSpjHc6ZgtMRYyO2NKekOpBmzUkRc)9KekOpBmz8QtUiK995U4UqAw2YHco(zztwqkg)3zXlqwCwa8(GxdkIfyXcGyWIL73zjohQ9NLUNtS4filXgg3yWcCybW7t7gIf4VtJLdtCxE4pyHnqBQObrkHelJ)7k4Ak1Jc6Zgtg9Q8jxeY(KekOpBmzUkJHAFssOG(SXK5QSk83tsOG(SXKXRo5Iq23hT9qankBSm(VJ2A7HaA20yz8FN7Yd)blSbAtfnisjKGFFA3qkqFfLdGkPqfCnLSEwf1GdkYO6AVcug2YUwN)9RqHtsSoabsLxVPou7FU5usI1yBsRZVpOOhBWVpnxRvs5KeRFxt1Bk)xdHZQU2RazOYv1eysspkOpBmzWqTp5Iq2NKqb9zJjZvz9Q8jjHc6ZgtMRYQWFpjHc6ZgtgV6KlczFFUlp8hSWgOnv0GiLqc(9bVguKc0xr5aOskubxtPzvudoOiJQR9kqzyl7AD(3VcfgDacKkVEtDO2)CZj0yBsRZVpOOhBWVpnxRvszUlUlKgPzrXrgfwpbYcbKMoS8xkXYVtS4HhoSCywCG(PDvnz4U8WFWcRegQ9jRsEk3Lh(dwyePescUwN9WFWkRp8RGYtjLG2urJcW)CHxjLvW1u6VuA7EBI4E4pyzSm(VBco(Z)LsiYd)bld(9PDdzco(Z)Ls95UqAwaqpML4cvCwGflXerSy5(D46zbCU2ZIxGSy5(Dwa8(OHdilEbYYMiIf4VtJLdtCxE4pyHrKsibOpNRQjfuEkP0HZoKuaqxViLW2KwNFFqrp2GFFAUwhVYO7z97AQEd(9rdhqdvUQMatsExt1BWpP1(KbNR9gQCvnb2pjbBtAD(9bf9yd(9P5AD8BYDH0SaGEmlbn5ajwSStflaEFA3qSe8IL97zzteXY7dk6XSyz)c7SCywgsta96zPbhw(DIffpOpBmXYdzrLyXEOgndbYIxGSyz)c7S0oTMgwEilbh)CxE4pyHrKsibOpNRQjfuEkP0HZbn5ajfa01lsjSnP153hu0Jn43N2nu8kZDH0Sy1WNZv1el)U)Se2PacywUglDGlw8Hy5kwCwqfaz5HS4aHhil)oXc((L)hSyXYonelol)Cfc0Zc9bwomllmbYYvSOsVfIkwco(XCxE4pyHrKsibOpNRQjfuEkP0vzubqfa01lsj7HaMrfankBsHWQDdLKypeWmQaOrzdEvTBOKe7HaMrfankBWVp41GIssShcygva0OSb)(0CTojXEiGzubqJYM2A6KHTmPxfLKypeqZ4aPcUW52qvS6KKOUAntWZxfmdL6xHvsD1AMGNVkyaxJ)hSssa6Z5QAYC4SdjUlKMLUbtSeBAW0GWvOyXY97SG84IeRQcSahw82tdlihwaHiqSCflipUiXQQa3Lh(dwyePesuPbtdcxHsbxtPE9SoabsLxVPou7FU5usI1biudcTuMaSacrGY)oLX23Cp2SS7JwD1AMGNVkygk1VchVYkeT1biqQ86naP637mjjbiqQ86naP637mOvxTMj45RcMLnA1vRzghivWfo3gQIvhZYgDp1vRzghivWfo3gQIvhZqP(v4Tvw5UvHi(SkQbhuKbFvBPZ7DWpnNNKOUAntWZxfmdL6xH3wzLtsugPITjToV74N2wzJcvy)(Ob6Z5QAYCvgvaK7cPzzlHplwUFNfNfKhxKyvvGLF3FwoCPONfNLTCPX(WI9adSahwSStfl)oXs7qT)SCywCv46z5HSqfi3Lh(dwyePesSH)blfCnL6PUAntWZxfmdL6xHJxzfIUN1ZQOgCqrg8vTLoV3b)0CEsI6Q1mJdKk4cNBdvXQJzOu)k82kVvD7MiU6Q1mQAieuVWVzzJwD1AMXbsfCHZTHQy1XSS7NKOcXy0Td1(Nhk1VcV9MkSpAG(CUQMmxLrfa5UqAwqURdlT)eMfl70Vtdll8vOyb5WciebILcAHflNwZIR1qlS0bUy5HSG)tRzj44NLFNyb7PelEkCvplWglihwaHiqic5Xfjwvfyj44hZD5H)GfgrkHeG(CUQMuq5PKsbybeIaLbjCNkOaGUErkfOt3Rx7qT)5Hs9RWDRYkSBdqOgeAPmbpFvWmuQFfUpsv5TyJ(kfOt3Rx7qT)5Hs9RWDRYkSBdqOgeAPmbybeIaL)DkJTV5ESbCn(FWQBdqOgeAPmbybeIaL)DkJTV5ESzOu)kCFKQYBXg9rB94hyMas1BCqqSHq2HFCssac1GqlLj45RcMHs9RWXF1tJnu7pbMBhQ9ppuQFfojzwf1GdkYeinH)Z1zS9n3JrhGqni0szcE(QGzOu)kC8XCJKKaeQbHwktawaHiq5FNYy7BUhBgk1Vch)vpn2qT)eyUDO2)8qP(v4Uv5nssSoabsLxVPou7FU5e3fsZs3GjqwEilGK27WYVtSSWokIfyJfKhxKyvvGfl7uXYcFfkwaHlvnXcSyzHjw8cKf7Has1ZYc7OiwSStflEXIdcYcbKQNLdZIRcxplpKfWJ4U8WFWcJiLqcqFoxvtkO8usPayoalW7pyPaGUErk1RDO2)8qP(v44vwHjjJFGzcivVXbbXMRIxHB0hDVE9ifBD22eOHsT7mKRZWbS8kqO7fGqni0szOu7od56mCalVcKzOu)k82kJy3ijjabsLxVbiv)ENbDac1GqlLHsT7mKRZWbS8kqMHs9RWBRmIDRqupLvgXNvrn4GIm4RAlDEVd(P58(9rBDac1GqlLHsT7mKRZWbS8kqMHCWo9tsifBD22eObdxAn9)vOYZsTd6EwhGaPYR3uhQ9p3CkjjaHAqOLYGHlTM()ku5zP2jhtRqHBXgkBgk1VcVTYkBf9ts6fGqni0szuPbtdcxHYmKd2jjX6XdK5hOw3hDVEKIToBBc0CfomR3v1uwXwE9R0mib8ce6EbiudcTuMRWHz9UQMYk2YRFLMbjGxGmd5GDss8WFWYCfomR3v1uwXwE9R0mib8cKb8WUQMa73pjPhPyRZ2Man4DheAHaZWrndB5hoPu9OdqOgeAPmpCsP6jW8v4d1(NJPcvym3uzZqP(v4(jj96b0NZv1Kbw5fMY)Cfc0RKYjja95CvnzGvEHP8pxHa9kfZ(O79ZviqVrzZqoyNCac1GqlvsYpxHa9gLnbiudcTuMHs9RWXF1tJnu7pbMBhQ9ppuQFfUBvEJ(jja95CvnzGvEHP8pxHa9kTj6E)Cfc0B20mKd2jhGqni0sLK8ZviqVzttac1GqlLzOu)kC8x90yd1(tG52HA)ZdL6xH7wL3OFscqFoxvtgyLxyk)ZviqVsB0VF)KKaeivE9ge6mNx9tsuHym62HA)ZdL6xH3wD1AMGNVkyaxJ)hS4UqAwSA4Z5QAILfMaz5HSasAVdlE1HLFUcb6XS4filbqmlw2PIfl(9xHILgCyXlwu8L9oCoNf7bg4U8WFWcJiLqcqFoxvtkO8usPFFoToJjcbAYw87vaqxViLSgdxA1Ran)(CADgtec0yOYv1eyss7qT)5Hs9RWXV5gBKK0ou7FEOu)k82BQqe1Zk2OBvxTM53NtRZyIqGgd(9aci(M9tsuxTM53NtRZyIqGgd(9acXhZTOB7nRIAWbfzWx1w68Eh8tZ5iUc7ZDH0S0nyIffp1UZqUMLU)bS8kqSS5gykGzrLAWHyXzb5XfjwvfyzHjd3Lh(dwyePeswykFpLQGYtjLOu7od56mCalVcKcUMsbiudcTuMGNVkygk1VcV9MBGoaHAqOLYeGfqicu(3Pm2(M7XMHs9RWBV5gO7b0NZv1K53NtRZyIqGMSf)(Ke1vRz(9506mMieOXGFpGq8XCde1Bwf1GdkYGVQT059o4NMZrCeB)(Ob6Z5QAYCvgvamjrfIXOBhQ9ppuQFfE7yUvCxinlDdMybaCP10FfkwSAxQDybXIPaMfvQbhIfNfKhxKyvvGLfMmCxE4pyHrKsizHP89uQckpLucdxAn9)vOYZsTJcUMs9cqOgeAPmbpFvWmuQFfEBelARdqGu51Bas1V3zqBDacKkVEtDO2)CZPKKaeivE9M6qT)5MtOdqOgeAPmbybeIaL)DkJTV5ESzOu)k82iw09a6Z5QAYeGfqicugKWDQqssac1GqlLj45RcMHs9RWBJy7NKeGaPYR3aKQFVZGUN1ZQOgCqrg8vTLoV3b)0Co6aeQbHwktWZxfmdL6xH3gXMKOUAnZ4aPcUW52qvS6ygk1VcVTYwbI6PqeNuS1zBtGMRW)ScpCWzWd4vuwL06(OvxTMzCGubx4CBOkwDml7(jjQqmgD7qT)5Hs9RWBVPctsifBD22eOHsT7mKRZWbS8kqOdqOgeAPmuQDNHCDgoGLxbYmuQFfo(n3OpAG(CUQMmxLrfarBnPyRZ2ManxHdZ6DvnLvSLx)kndsaVaLKeGqni0szUchM17QAkRylV(vAgKaEbYmuQFfo(n3ijrfIXOBhQ9ppuQFfE7n3G7cPzjUAlEhmllmXIvHukRolwUFNfKhxKyvvG7Yd)blmIucja95CvnPGYtjLofdmhGf49hSuaqxViLuxTMj45RcMHs9RWXRScr3Z6zvudoOid(Q2sN37GFAopjrD1AMXbsfCHZTHQy1XmuQFfEBLuEtZMiQxmrC1vRzu1qiOEHFZYUpI6TfDRcrC1vRzu1qiOEHFZYUpItk26STjqZv4FwHho4m4b8kkRsAnA1vRzghivWfo3gQIvhZYUFsIkeJr3ou7FEOu)k82BQWKesXwNTnbAOu7od56mCalVce6aeQbHwkdLA3zixNHdy5vGmdL6xH5U8WFWcJiLqYct57PufuEkP0v4WSExvtzfB51VsZGeWlqk4Akb0NZv1K5umWCawG3FWcnqFoxvtMRYOcGCxinlDdMyzou7plQudoelbqm3Lh(dwyePeswykFpLQGYtjLW7oi0cbMHJAg2YpCsP6vW1uQxac1GqlLj45RcMHCWoOToabsLxVPou7FU5eAG(CUQMm)(CADgtec0KT43JUxac1GqlLrLgmniCfkZqoyNKeRhpqMFGAD)KKaeivE9M6qT)5MtOdqOgeAPmbybeIaL)DkJTV5ESzihSd6Ea95CvnzcWciebkds4ovijjaHAqOLYe88vbZqoyN(9rdcFdEvTBiZFbeUcf6EGW3GFsR9j30(qM)ciCfQKeRFxt1BWpP1(KBAFidvUQMatsW2KwNFFqrp2GFFA3qXhZ(ObHVjfcR2nK5VacxHcDpG(CUQMmho7qkjzwf1GdkYO6AVcug2YUwN)9RqHtsC8pUoBdTqt8kHy2ijbOpNRQjtawaHiqzqc3PcjjQRwZOQHqq9c)MLDF0wtk26STjqZv4WSExvtzfB51VsZGeWlqjjKIToBBc0CfomR3v1uwXwE9R0mib8ce6aeQbHwkZv4WSExvtzfB51VsZGeWlqMHs9RWXhZnqBT6Q1mbpFvWSStsuHym62HA)ZdL6xH32k2G7cPzjg7hMLdZIZY4)onSqAxfo(tSyX7WYdzj1rGyX1AwGfllmXc(9NLFUcb6XS8qwujw0xrGSSSzXY97SG84IeRQcS4filihwaHiqS4fillmXYVtSSzbYcwdFwGflbqwUglQWFNLFUcb6XS4dXcSyzHjwWV)S8ZviqpM7Yd)blmIucjlmLVNsXkaRHpwPFUcb6vwbxtPEa95CvnzGvEHP8pxHa9wRKYOT(NRqGEZMMHCWo5aeQbHwQKKEa95CvnzGvEHP8pxHa9kPCscqFoxvtgyLxyk)ZviqVsXSp6EQRwZe88vbZYgDpRdqGu51Bas1V3zssuxTMzCGubx4CBOkwDmdL6xHrupfI4ZQOgCqrg8vTLoV3b)0CE)Tv6NRqGEJYg1vRLbxJ)hSqRUAnZ4aPcUW52qvS6yw2jjQRwZmoqQGlCUnufRoz8vTLoV3b)0CUzz3pjjaHAqOLYe88vbZqP(vyeTz8)Cfc0Bu2eGqni0szaxJ)hSqBT6Q1mbpFvWSSr3Z6aeivE9M6qT)5Mtjjwd0NZv1KjalGqeOmiH7uH(OToabsLxVbHoZ5vssacKkVEtDO2)CZj0a95CvnzcWciebkds4ovaDac1GqlLjalGqeO8VtzS9n3JnlB0whGqni0szcE(QGzzJUxp1vRzOG(SXuwVkFmdL6xHJx5nssuxTMHc6Zgtzmu7JzOu)kC8kVrF0wpRIAWbfzuDTxbkdBzxRZ)(vOWjj9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhqqjfMKOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpGGsBr)(jjQRwZGWvGdbMPuBOfAsP6ZurdQlwKzz3pjrfIXOBhQ9ppuQFfE7n3ijbOpNRQjdSYlmL)5keOxPn6JgOpNRQjZvzubqUlp8hSWisjKSWu(EkfRaSg(yL(5keOFtfCnL6b0NZv1Kbw5fMY)Cfc0BTsBI26FUcb6nkBgYb7KdqOgeAPssa6Z5QAYaR8ct5FUcb6vAt09uxTMj45RcMLn6EwhGaPYR3aKQFVZKKOUAnZ4aPcUW52qvS6ygk1VcJOEkeXNvrn4GIm4RAlDEVd(P58(BR0pxHa9MnnQRwldUg)pyHwD1AMXbsfCHZTHQy1XSStsuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYUFssac1GqlLj45RcMHs9RWiAZ4)5keO3SPjaHAqOLYaUg)pyH2A1vRzcE(QGzzJUN1biqQ86n1HA)ZnNssSgOpNRQjtawaHiqzqc3Pc9rBDacKkVEdcDMZl09SwD1AMGNVkyw2jjwhGaPYR3aKQFVZ0pjjabsLxVPou7FU5eAG(CUQMmbybeIaLbjCNkGoaHAqOLYeGfqicu(3Pm2(M7XMLnARdqOgeAPmbpFvWSSr3RN6Q1muqF2ykRxLpMHs9RWXR8gjjQRwZqb9zJPmgQ9XmuQFfoEL3OpARNvrn4GImQU2RaLHTSR15F)ku4KKEQRwZO6AVcug2YUwN)9RqHZL)RHm43diOKctsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhqqPTOF)(jjQRwZGWvGdbMPuBOfAsP6ZurdQlwKzzNKOcXy0Td1(Nhk1VcV9MBKKa0NZv1Kbw5fMY)Cfc0R0g9rd0NZv1K5QmQai3fsZs3GjmlUwZc83PHfyXYctSCpLIzbwSea5U8WFWcJiLqYct57Pum3fsZIvNchiXIh(dwSOp8ZIQJjqwGfl47x(FWcjAc1H5U8WFWcJiLqYSQSh(dwz9HFfuEkPKdjfG)5cVskRGRPeqFoxvtMdNDiXD5H)GfgrkHKzvzp8hSY6d)kO8usjvO)ka)ZfELuwbxtPzvudoOiJQR9kqzyl7AD(3Vcf2qk26STjqUlp8hSWisjKmRk7H)GvwF4xbLNskHFUlUlKMfK76Ws7pHzXYo970WYVtSy1hYtd(h2PHf1vRXILtRzP5AnlWwJfl3VFfl)oXsri7zj44N7Yd)blSXHKsa95CvnPGYtjLahYtZwoTo3CTodBnfa01lsPEQRwZ8xkzbovgCipv9kqAmdL6xH3gva0K6idrByuojrD1AM)sjlWPYGd5PQxbsJzOu)k82E4pyzWVpTBidHmkSEk)xkHOnmkJUhf0NnMmxL1RYNKekOpBmzWqTp5Iq2NKqb9zJjJxDYfHSVFF0QRwZ8xkzbovgCipv9kqAmlB0ZQOgCqrM)sjlWPYGd5PQxbsd3fsZcYDDyP9NWSyzN(DAybW7dEnOiwomlwGZVZsWX)vOybcKgwa8(0UHy5kwSYv5dlkEqF2yI7Yd)blSXHeIucja95CvnPGYtjLoufCOm(9bVguKca66fPK1uqF2yYCvgd1(GUh2M0687dk6Xg87t7gkEfI(DnvVbdx6mSL)Dk3GdHFdvUQMatsW2KwNFFqrp2GFFA3qXVv95UqAw6gmXcYHfqicelw2PIf)zrtyml)UxSOWnyjU4TKfVazrFfXYYMfl3VZcYJlsSQkWD5H)Gf24qcrkHKaSacrGY)oLX23CpwbxtjRbN1bAkyoaIr3RhqFoxvtMaSacrGYGeUtfqBDac1GqlLj45RcMHCWojjQRwZe88vbZYUp6EQRwZqb9zJPSEv(ygk1VchpInjrD1AgkOpBmLXqTpMHs9RWXJy7JUN1ZQOgCqrgvx7vGYWw2168VFfkCsI6Q1mQU2RaLHTSR15F)ku4C5)Aid(9acXhZKe1vRzuDTxbkdBzxRZ)(vOWzFcErg87beIpM9tsuHym62HA)ZdL6xH3w5nqBDac1GqlLj45RcMHCWo95UqAw6gmXcGv1UHy5kwS9cKsValWIfV687xHILF3Fw0hqcZIYwbMcyw8cKfnHXSy5(DwsHdXY7dk6XS4fil(ZYVtSqfilWglolaGAFyrXd6ZgtS4plkBfSGPaMf4WIMWywgk1V6kuS4ywEilf8zz3bEfkwEild1gcVZc4AUcflw5Q8HffpOpBmXD5H)Gf24qcrkHe8QA3qki0jOP87dk6XkPScUMs9gQneE3v1usI6Q1muqF2ykJHAFmdL6xH3oMOPG(SXK5QmgQ9b9qP(v4Tv2kq)UMQ3GHlDg2Y)oLBWHWVHkxvtG9r)(GIEZFPu(HzWJIxzROBX2KwNFFqrpgrdL6xHr3Jc6ZgtMRYE1jjzOu)k82OcGMuhz95UqAw6gmXcGv1UHy5HSS7ajwCwqPHQUMLhYYctSyviLYQZD5H)Gf24qcrkHe8QA3qk4Akb0NZv1K5umWCawG3FWcDac1GqlL5kCywVRQPSIT86xPzqc4fiZqoyh0KIToBBc0CfomR3v1uwXwE9R0mib8ce3Lh(dwyJdjePesWVpnxRvW1uY631u9g8tATpzW5AVHkxvtGO7PUAnd(9P5ATzO2q4DxvtO7HTjTo)(GIESb)(0CTE7yMKy9SkQbhuK5VuYcCQm4qEQ6vG00pj5DnvVbdx6mSL)Dk3GdHFdvUQMarRUAndf0NnMYyO2hZqP(v4TJjAkOpBmzUkJHAFqRUAnd(9P5ATzOu)k82BfASnP153hu0Jn43NMR1XRKv0hDpRNvrn4GIm6obFCCUPj6VcvgL(sTXusYFPesfPAfkmE1vRzWVpnxRndL6xHr0M9r)(GIEZFPu(HzWJIxHCxinlif3VZcGN0AFyXQpx7zzHjwGflbqwSStfld1gcV7QAIf11Zc(pTMfl(9S0GdlwzNGpoMf7bgyXlqwaHLIEwwyIfvQbhIfKB1Xgwa8NwZYctSOsn4qSGCybeIaXc(QaXYV7plwoTMf7bgyXl4VtdlaEFAUwZD5H)Gf24qcrkHe87tZ1AfCnLExt1BWpP1(KbNR9gQCvnbIwD1Ag87tZ1AZqTHW7UQMq3Z6zvudoOiJUtWhhNBAI(RqLrPVuBmLK8xkHurQwHcJ3k6J(9bf9M)sP8dZGhfFm5UqAwqkUFNfR(qEQ6vG0WYctSa49P5AnlpKfeiYMLLnl)oXI6Q1yrTdlUgdzzHVcflaEFAUwZcSyrHSGPaSaXSahw0egZYqP(vxHI7Yd)blSXHeIucj43NMR1k4AknRIAWbfz(lLSaNkdoKNQEfinOX2KwNFFqrp2GFFAUwhVsXeDpRvxTM5VuYcCQm4qEQ6vG0yw2OvxTMb)(0CT2muBi8URQPKKEa95CvnzahYtZwoTo3CTodBn09uxTMb)(0CT2muQFfE7yMKGTjTo)(GIESb)(0CTo(nr)UMQ3GFsR9jdox7nu5QAceT6Q1m43NMR1MHs9RWBRW(97ZDH0SGCxhwA)jmlw2PFNgwCwa8(GxdkILfMyXYP1Se8fMybW7tZ1AwEilnxRzb2AkGfVazzHjwa8(GxdkILhYccezZIvFipv9kqAyb)Eabww2CxE4pyHnoKqKsibOpNRQjfuEkPe(9P5AD2cS(CZ16mS1uaqxViLC8pUoBdTqt8BXgDBpL3aXvxTM5VuYcCQm4qEQ6vG0yWVhqOF32tD1Ag87tZ1AZqP(vyepMivSnP15Dh)eIB97AQEd(jT2Nm4CT3qLRQjW(DBVaeQbHwkd(9P5ATzOu)kmIhtKk2M068UJFcXFxt1BWpP1(KbNR9gQCvnb2VB7bcFtBnDYWwM0RImdL6xHrCf2hDp1vRzWVpnxRnl7KKaeQbHwkd(9P5ATzOu)kCFUlKMLUbtSa49bVguelwUFNfR(qEQ6vG0WYdzbbISzzzZYVtSOUAnwSC)oC9SOH4RqXcG3NMR1SSS)lLyXlqwwyIfaVp41GIybwSyfiILydJBmyb)EabmlR6pnlwblVpOOhZD5H)Gf24qcrkHe87dEnOifCnLa6Z5QAYaoKNMTCADU5ADg2AOb6Z5QAYGFFAUwNTaRp3CTodBn0wd0NZv1K5qvWHY43h8Aqrjj9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhqi(yMKOUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpGq8XSpASnP153hu0Jn43NMR1BBfOb6Z5QAYGFFAUwNTaRp3CTodBnUlKMLUbtSGT4tklyil)U)S0bUybf9SK6iJLL9FPelQDyzHVcfl3ZIJzr7pXIJzXgIXNQMybwSOjmMLF3lwIjl43diGzboSGuYc)SyzNkwIjIyb)EabmleYSVH4U8WFWcBCiHiLqId62)bKYyl(KQGqNGMYVpOOhRKYk4Akz9FbeUcfAR9WFWY4GU9FaPm2IpPzqp1rrMRYn9HA)tsaHVXbD7)aszSfFsZGEQJIm43diSDmrdcFJd62)bKYyl(KMb9uhfzgk1VcVDm5UqAwSAP2q4Dw6(GWQDdXY1yb5Xfjwvfy5WSmKd2rbS870qS4dXIMWyw(DVyrHS8(GIEmlxXIvUkFyrXd6ZgtSy5(Dwaa)UNcyrtyml)UxSO8gSa)DASCyILRyXRoSO4b9zJjwGdllBwEilkKL3hu0JzrLAWHyXzXkxLpSO4b9zJjdlwDyPONLHAdH3zbCnxHIfKYxboeilkEQn0cnPu9SSknHXSCflaGAFyrXd6ZgtCxE4pyHnoKqKsijfcR2nKccDcAk)(GIESskRGRP0qTHW7UQMq)(GIEZFPu(HzWJIVxpLTce1dBtAD(9bf9yd(9PDdH4BI4QRwZqb9zJPSEv(yw297JOHs9RW9rQ9ugrVRP6nVLRYPqyHnu5QAcSp6EbiudcTuMGNVkygYb7G2AWzDGMcMdGy09a6Z5QAYeGfqicugKWDQqssac1GqlLjalGqeO8VtzS9n3Jnd5GDssSoabsLxVPou7FU5u)KeSnP153hu0Jn43N2n0296Hy72EQRwZqb9zJPSEv(yw2i(M97J49ugrVRP6nVLRYPqyHnu5QAcSFF0wtb9zJjdgQ9jxeY(KKEuqF2yYCvgd1(KK0Jc6ZgtMRYQWFpjHc6ZgtMRY6v5tF0w)UMQ3GHlDg2Y)oLBWHWVHkxvtGjjQRwZypxkCapxN9j41fY2ln2hdqxVO4vAtfUrF09W2KwNFFqrp2GFFA3qBR8giEpLr07AQEZB5QCkewydvUQMa73hTJ)X1zBOfAIxHB0TQRwZGFFAUwBgk1VcJ4i2(O7zT6Q1miCf4qGzk1gAHMuQ(mv0G6Ifzw2jjuqF2yYCvgd1(KKyDacKkVEdcDMZR(OTwD1AMXbsfCHZTHQy1jJVQT059o4NMZnlBUlKMLUbtS09GXHfyXsaKfl3Vdxplb32(kuCxE4pyHnoKqKsiPbNaLHTC5)AifCnLC7CyNciWD5H)Gf24qcrkHeG(CUQMuq5PKsbWCawG3FWk7qsbaD9IuYAWzDGMcMdGy0a95CvnzcG5aSaV)Gf6E9uxTMb)(0CT2SStsExt1BWpP1(KbNR9gQCvnbMKeGaPYR3uhQ9p3CQp6EwRUAndgQX)fiZYgT1QRwZe88vbZYgDpRFxt1BARPtg2YKEvKHkxvtGjjQRwZe88vbd4A8)Gv8biudcTuM2A6KHTmPxfzgk1VcJOTOpAG(CUQMm)(CADgtec0KT43JUN1biqQ86n1HA)ZnNsscqOgeAPmbybeIaL)DkJTV5ESzzJUN6Q1m43NMR1MHs9RWBVzsI1VRP6n4N0AFYGZ1EdvUQMa73h97dk6n)Ls5hMbpkE1vRzcE(QGbCn(FWcX3WSv9tsuHym62HA)ZdL6xH3wD1AMGNVkyaxJ)hS6ZDH0S0nyILU3qvS6WIL73zb5Xfjwvf4U8WFWcBCiHiLqY4aPcUW52qvS6OGRPK6Q1mbpFvWmuQFfoELvysI6Q1mbpFvWaUg)pyTDm3anqFoxvtMayoalW7pyLDiXDH0S0nyIfKhxKyvvGfyXsaKLvPjmMfVazrFfXY9SSSzXY97SGCybeIaXD5H)Gf24qcrkHKaPj8FUo76dvLs1RGRPeqFoxvtMayoalW7pyLDiHUN6Q1mbpFvWaUg)pyfVsXCJKeRdqGu51Bas1V3z6NKOUAnZ4aPcUW52qvS6yw2OvxTMzCGubx4CBOkwDmdL6xH3gXGOaSax3BShkCyk76dvLs1B(lLYaD9IqupRvxTMrvdHG6f(nlB0w)UMQ3GFF0Wb0qLRQjW(CxE4pyHnoKqKsi5QGpL)hSuW1ucOpNRQjtamhGf49hSYoK4UqAw6gmXIINAdTqdlXgwGSalwcGSy5(Dwa8(0CTMLLnlEbYc2bsS0GdlB5sJ9HfVazb5Xfjwvf4U8WFWcBCiHiLqcLAdTqtwfwGk4AkPcXy0x90yd1(tG52HA)ZdL6xH3wzfMK0tD1Ag75sHd456SpbVUq2EPX(ya66fT9MkCJKe1vRzSNlfoGNRZ(e86cz7Lg7JbORxu8kTPc3OpA1vRzWVpnxRnlB09cqOgeAPmbpFvWmuQFfoERyJKeWzDGMcMdG4(CxinlwTuBi8olnTpelWILLnlpKLyYY7dk6XSy5(D46zb5XfjwvfyrLUcflUkC9S8qwiKzFdXIxGSuWNfiqAcUT9vO4U8WFWcBCiHiLqc(jT2NCt7dPGqNGMYVpOOhRKYk4AknuBi8URQj0)Ls5hMbpkELviASnP153hu0Jn43N2n02wbA3oh2PacO7PUAntWZxfmdL6xHJx5nssSwD1AMGNVkyw295UqAw6gmXs3dQ4SCnwUcFGelEXIIh0NnMyXlqw0xrSCpllBwSC)ololB5sJ9Hf7bgyXlqwIlOB)hqIfaw8jL7Yd)blSXHeIucjT10jdBzsVksbxtjkOpBmzUk7vh0QRwZypxkCapxN9j41fY2ln2hdqxVOT3uHBGUhi8noOB)hqkJT4tAg0tDuK5VacxHkjX6aeivE9MIcdudhWKeSnP153hu0JJFZ(O7PUAnZ4aPcUW52qvS6ygk1VcVnIPB7PqeFwf1GdkYGVQT059o4NMZ7JwD1AMXbsfCHZTHQy1XSStsSwD1AMXbsfCHZTHQy1XSS7JUN1biudcTuMGNVkyw2jjQRwZ87ZP1zmriqJb)EaHTvwHOBhQ9ppuQFfE7n3yd0Td1(Nhk1VchVYBSrsI1y4sREfO53NtRZyIqGgdvUQMa7JUhgU0QxbA(9506mMieOXqLRQjWKKaeQbHwktWZxfmdL6xHJpMB0N7cPzPBWelolaEFAUwZs3Fr)ol2dmWYQ0egZcG3NMR1SCywC9qoyhww2Sahw6axS4dXIRcxplpKfiqAcUnlXfVLCxE4pyHnoKqKsib)(0CTwbxtj1vRzGf974SnnbY(pyzw2O7PUAnd(9P5ATzO2q4Dxvtjjo(hxNTHwOjEeZg95UqAwS6RuBwIlElzrLAWHyb5WciebIfl3VZcG3NMR1S4fil)ovSa49bVgue3Lh(dwyJdjePesWVpnxRvW1ukabsLxVPou7FU5eARFxt1BWpP1(KbNR9gQCvnbIUhqFoxvtMaSacrGYGeUtfsscqOgeAPmbpFvWSStsuxTMj45RcMLDF0biudcTuMaSacrGY)oLX23Cp2muQFfEBubqtQJmepqNUNJ)X1zBOfAqQkCJ(OvxTMb)(0CT2muQFfEBRaT1GZ6anfmhaXCxE4pyHnoKqKsib)(GxdksbxtPaeivE9M6qT)5MtO7b0NZv1KjalGqeOmiH7uHKKaeQbHwktWZxfml7Ke1vRzcE(QGzz3hDac1GqlLjalGqeO8VtzS9n3JndL6xH3gXIwD1Ag87tZ1AZYgnf0NnMmxL9QdARb6Z5QAYCOk4qz87dEnOi0wdoRd0uWCaeZDH0S0nyIfaVp41GIyXY97S4flD)f97SypWalWHLRXsh4srGSabstWTzjU4TKfl3VZsh4AyPiK9SeC8ByjUAmKfWvQnlXfVLS4pl)oXcvGSaBS87elwnO637mSOUAnwUglaEFAUwZIf4sdwk6zP5AnlWwJf4Wsh4IfFiwGflBYY7dk6XCxE4pyHnoKqKsib)(Gxdksbxtj1vRzGf974Cqt(KbE4dwMLDsspRXVpTBiJBNd7uab0wd0NZv1K5qvWHY43h8Aqrjj9uxTMj45RcMHs9RWBRq0QRwZe88vbZYojPxp1vRzcE(QGzOu)k82OcGMuhziEGoDph)JRZ2ql0GuJ5g9rRUAntWZxfml7Ke1vRzghivWfo3gQIvNm(Q2sN37GFAo3muQFfEBubqtQJmepqNUNJ)X1zBOfAqQXCJ(OvxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYUp6aeivE9gGu97DM(9r3dBtAD(9bf9yd(9P5A92XmjbOpNRQjd(9P5AD2cS(CZ16mS163hT1a95CvnzoufCOm(9bVgue6EwpRIAWbfz(lLSaNkdoKNQEfinjjyBsRZVpOOhBWVpnxR3oM95UqAw6gmXs3hewywUIfaqTpSO4b9zJjw8cKfSdKyP7T0Aw6(GWILgCyb5Xfjwvf4U8WFWcBCiHiLqsrwYPqyPGRPup1vRzOG(SXugd1(ygk1VchpHmkSEk)xkLK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvkM9r725WofqG7Yd)blSXHeIucj7UULtHWsbxtPEQRwZqb9zJPmgQ9XmuQFfoEczuy9u(VukjPxy3huewPnrpuy3huu(VuABf2pjjS7dkcRum7J2TZHDkGa6EQRwZmoqQGlCUnufRoMHs9RWBRq0QRwZmoqQGlCUnufRoMLnARNvrn4GIm4RAlDEVd(P58KeRvxTMzCGubx4CBOkwDml7(CxE4pyHnoKqKsiPT06Ckewk4Ak1tD1AgkOpBmLXqTpMHs9RWXtiJcRNY)LsO7fGqni0szcE(QGzOu)kC8kCJKKaeQbHwktawaHiq5FNYy7BUhBgk1VchVc3OFssVWUpOiSsBIEOWUpOO8FP02kSFssy3huewPy2hTBNd7uab09uxTMzCGubx4CBOkwDmdL6xH3wHOvxTMzCGubx4CBOkwDmlB0wpRIAWbfzWx1w68Eh8tZ5jjwRUAnZ4aPcUW52qvS6yw295UqAw6gmXcsbuXzbwSGCRo3Lh(dwyJdjePesS4ZCWjdBzsVkI7cPzb5UoS0(tywSSt)onS8qwwyIfaVpTBiwUIfaqTpSyz)c7SCyw8NffYY7dk6XiszwAWHfcinDyzZnqQSK64NMoSahwScwa8(GxdkIffp1gAHMuQEwWVhqaZD5H)Gf24qcrkHeG(CUQMuq5PKs43N2nu(QmgQ9rbaD9IucBtAD(9bf9yd(9PDdfVvGOMgcNEPo(PPtgORxeIR8gBGu3CJ(iQPHWPN6Q1m43h8Aqrzk1gAHMuQ(mgQ9XGFpGas1k6ZDH0SGCxhwA)jmlw2PFNgwEilifJ)7SaUMRqXs3BOkwD4U8WFWcBCiHiLqcqFoxvtkO8usjlJ)75RYTHQy1rbaD9IuszKk2M068UJFA7n72EBy2eX7HTjTo)(GIESb)(0UH6wL7J49ugrVRP6ny4sNHT8Vt5gCi8BOYv1eiIRSrH97JOnmkRqexD1AMXbsfCHZTHQy1XmuQFfM7cPzPBWelifJ)7SCflaGAFyrXd6ZgtSahwUglfKfaVpTBiwSCAnlT7z5QhYcYJlsSQkWIxDsHdXD5H)Gf24qcrkHelJ)7k4Ak1Jc6Zgtg9Q8jxeY(KekOpBmz8QtUiK9Ob6Z5QAYC4CqtoqQp6EVpOO38xkLFyg8O4TIKekOpBmz0RYN8v5ntsAhQ9ppuQFfEBL3OFsI6Q1muqF2ykJHAFmdL6xH32d)bld(9PDdziKrH1t5)sj0QRwZqb9zJPmgQ9XSStsOG(SXK5QmgQ9bT1a95CvnzWVpTBO8vzmu7tsI6Q1mbpFvWmuQFfEBp8hSm43N2nKHqgfwpL)lLqBnqFoxvtMdNdAYbsOvxTMj45RcMHs9RWBtiJcRNY)LsOvxTMj45RcMLDsI6Q1mJdKk4cNBdvXQJzzJgOpNRQjJLX)98v52qvS6KKynqFoxvtMdNdAYbsOvxTMj45RcMHs9RWXtiJcRNY)LsCxinlDdMybW7t7gILRXYvSyLRYhwu8G(SXKcy5kwaa1(WIIh0NnMybwSyfiIL3hu0JzboS8qwShyGfaqTpSO4b9zJjUlp8hSWghsisjKGFFA3qCxinlDpxR)9zXD5H)Gf24qcrkHKzvzp8hSY6d)kO8usPMR1)(S4U4UqAw6EdvXQdlwUFNfKhxKyvvG7Yd)blSrf6VsJdKk4cNBdvXQJcUMsQRwZe88vbZqP(v44vwHCxinlDdMyjUGU9FajwayXNuwSStfl(ZIMWyw(DVyXkyj2W4gdwWVhqaZIxGS8qwgQneENfNLTvAtwWVhqGfhZI2FIfhZIneJpvnXcCy5VuIL7zbdz5Ew8zoGeMfKsw4NfV90WIZsmrel43diWcHm7Bim3Lh(dwyJk0FePesCq3(pGugBXNufe6e0u(9bf9yLuwbxtj1vRzuDTxbkdBzxRZ)(vOW5Y)1qg87be2ElqRUAnJQR9kqzyl7AD(3Vcfo7tWlYGFpGW2Bb6EwdcFJd62)bKYyl(KMb9uhfz(lGWvOqBTh(dwgh0T)diLXw8jnd6PokYCvUPpu7p6EwdcFJd62)bKYyl(KM3jxB(lGWvOssaHVXbD7)aszSfFsZ7KRndL6xHJpM9tsaHVXbD7)aszSfFsZGEQJIm43diSDmrdcFJd62)bKYyl(KMb9uhfzgk1VcVTcrdcFJd62)bKYyl(KMb9uhfz(lGWvO6ZDH0S0nyIfKdlGqeiwSC)olipUiXQQalw2PIfBigFQAIfVazb(70y5WelwUFNfNLydJBmyrD1ASyzNkwajCNkCfkUlp8hSWgvO)isjKeGfqicu(3Pm2(M7Xk4Akzn4SoqtbZbqm6E9a6Z5QAYeGfqicugKWDQaARdqOgeAPmbpFvWmKd2jjrD1AMGNVkyw29r3tD1Agvx7vGYWw2168VFfkCU8FnKb)EabL2IKe1vRzuDTxbkdBzxRZ)(vOWzFcErg87beuAl6NKOcXy0Td1(Nhk1VcVTYBGoaHAqOLYe88vbZqP(v443Q(CxinlDpOIZIJz53jwA3GFwqfaz5kw(DIfNLydJBmyXYvGqlSahwSC)ol)oXcs5oZ5flQRwJf4WIL73zXzzlqeMcSexq3(pGelaS4tklEbYIf)EwAWHfKhxKyvvGLRXY9SybwplQellBwCu(vSOsn4qS87elbqwomlTRo8obYD5H)Gf2Oc9hrkHK2A6KHTmPxfPGRPuVE9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhqiEeBsI6Q1mQU2RaLHTSR15F)ku4SpbVid(9acXJy7JUN1biqQ86naP637mjjwRUAnZ4aPcUW52qvS6yw297JUh4SoqtbZbqCssac1GqlLj45RcMHs9RWXRWnss6fGaPYR3uhQ9p3CcDac1GqlLjalGqeO8VtzS9n3JndL6xHJxHB0VF)KKEGW34GU9FaPm2IpPzqp1rrMHs9RWXVfOdqOgeAPmbpFvWmuQFfoEL3aDacKkVEtrHbQHdy)KKREASHA)jWC7qT)5Hs9RWBVfOToaHAqOLYe88vbZqoyNKKaeivE9ge6mNxOvxTMbHRahcmtP2ql0Ks1Bw2jjbiqQ86naP637mOvxTMzCGubx4CBOkwDmdL6xH3gXGwD1AMXbsfCHZTHQy1XSS5UqAwqUxbsZcG3hnCazXY97S4SuKfwInmUXGf1vRXIxGSG84IeRQcSC4srplUkC9S8qwujwwycK7Yd)blSrf6pIucjbVcKoRUAnfuEkPe(9rdhqfCnL6PUAnJQR9kqzyl7AD(3Vcfox(VgYmuQFfo(TYOWKe1vRzuDTxbkdBzxRZ)(vOWzFcErMHs9RWXVvgf2hDVaeQbHwktWZxfmdL6xHJFRss6fGqni0szOuBOfAYQWc0muQFfo(TcT1QRwZGWvGdbMPuBOfAsP6ZurdQlwKzzJoabsLxVbHoZ5v)(OD8pUoBdTqt8kfZn4UqAwS6RuBwa8(GxdkcZIL73zXzj2W4gdwuxTglQRNLc(SyzNkwSHq9vOyPbhwqECrIvvbwGdliLVcCiqwayFZ9yURWFWcBuH(JiLqc(9bVguKcUMs9uxTMr11EfOmSLDTo)7xHcNl)xdzWVhqi(ntsuxTMr11EfOmSLDTo)7xHcN9j4fzWVhqi(n7JUxpRdqGu51BQd1(NBoLK44FCD2gAHM4vYk2Op6aeQbHwktWZxfmdL6xHJFRssSgOpNRQjtamhGf49hSqBDacKkVEdcDMZRKKEbiudcTugk1gAHMSkSandL6xHJFRqBT6Q1miCf4qGzk1gAHMuQ(mv0G6Ifzw2OdqGu51BqOZCE1Vp6EwdcFtBnDYWwM0RIm)fq4kujjwhGqni0szcE(QGzihStsI1biudcTuMaSacrGY)oLX23Cp2mKd2Pp3fsZIvFLAZcG3h8AqrywuPgCiwqoSacrG4U8WFWcBuH(JiLqc(9bVguKcUMs9cqOgeAPmbybeIaL)DkJTV5ESzOu)k82keT1GZ6anfmhaXO7b0NZv1KjalGqeOmiH7uHKKaeQbHwktWZxfmdL6xH3wH9rd0NZv1KjaMdWc8(dw9rBni8nT10jdBzsVkY8xaHRqHoabsLxVPou7FU5eARbN1bAkyoaIrtb9zJjZvzV6G2X)46Sn0cnXBfBWDH0Sy1HLIEwaHplGR5kuS87elubYcSXIvRdKk4cZs3BOkwDualGR5kuSGWvGdbYcLAdTqtkvplWHLRy53jw0o(zbvaKfyJfVyrXd6ZgtCxE4pyHnQq)rKsibOpNRQjfuEkPei8ZdPyRBOuQESca66fPup1vRzghivWfo3gQIvhZqP(v44vysI1QRwZmoqQGlCUnufRoMLDF09uxTMbHRahcmtP2ql0Ks1NPIguxSiZqP(v4TrfanPoY6JUN6Q1muqF2ykJHAFmdL6xHJhva0K6iljrD1AgkOpBmL1RYhZqP(v44rfanPoY6ZD5H)Gf2Oc9hrkHe8QA3qki0jOP87dk6XkPScUMsd1gcV7QAc97dk6n)Ls5hMbpkELrSOD7CyNciGgOpNRQjdi8ZdPyRBOuQEm3Lh(dwyJk0FePessHWQDdPGqNGMYVpOOhRKYk4AknuBi8URQj0VpOO38xkLFyg8O4voMgfI2TZHDkGaAG(CUQMmGWppKITUHsP6XCxE4pyHnQq)rKsib)Kw7tUP9HuqOtqt53hu0JvszfCnLgQneE3v1e63hu0B(lLYpmdEu8kJyr0qP(vy0UDoStbeqd0NZv1Kbe(5HuS1nukvpM7cPzP7bJdlWILailwUFhUEwcUT9vO4U8WFWcBuH(JiLqsdobkdB5Y)1qk4Ak525WofqG7cPzrXtTHwOHLydlqwSStflUkC9S8qwO6PHfNLISWsSHXngSy5kqOfw8cKfSdKyPbhwqECrIvvbUlp8hSWgvO)isjKqP2ql0KvHfOcUMs9OG(SXKrVkFYfHSpjHc6Zgtgmu7tUiK9jjuqF2yY4vNCri7tsuxTMr11EfOmSLDTo)7xHcNl)xdzgk1Vch)wzuysI6Q1mQU2RaLHTSR15F)ku4SpbViZqP(v443kJctsC8pUoBdTqt8iMnqhGqni0szcE(QGzihSdARbN1bAkyoaI7JUxac1GqlLj45RcMHs9RWXhZnsscqOgeAPmbpFvWmKd2PFsIkeJrF1tJnu7pbMBhQ9ppuQFfEBL3G7cPzP7bvCwMd1(ZIk1GdXYcFfkwqEC5U8WFWcBuH(JiLqsBnDYWwM0RIuW1ukaHAqOLYe88vbZqoyh0a95CvnzcG5aSaV)Gf6Eo(hxNTHwOjEeZgOToabsLxVPou7FU5ussacKkVEtDO2)CZj0o(hxNTHwOzBRyJ(OToabsLxVbiv)ENbDpRdqGu51BQd1(NBoLKeGqni0szcWciebk)7ugBFZ9yZqoyN(OTgCwhOPG5aiM7cPzb5XfjwvfyXYovS4pliMnqelXfVLS0doAOfAy539IfRydwIlElzXY97SGCybeIa1Nfl3VdxplAi(kuS8xkXYvSeBnecQx4NfVazrFfXYYMfl3VZcYHfqicelxJL7zXIJzbKWDQabYD5H)Gf2Oc9hrkHeG(CUQMuq5PKsbWCawG3FWkRc9xbaD9IuYAWzDGMcMdGy0a95CvnzcG5aSaV)Gf6E9C8pUoBdTqt8iMnq3tD1AgeUcCiWmLAdTqtkvFMkAqDXIml7KeRdqGu51BqOZCE1pjrD1AgvnecQx43SSrRUAnJQgcb1l8Bgk1VcVT6Q1mbpFvWaUg)py1pjrfIXOV6PXgQ9NaZTd1(Nhk1VcVT6Q1mbpFvWaUg)pyLKeGaPYR3uhQ9p3CQp6EwhGaPYR3uhQ9p3CkjPNJ)X1zBOfA22k2ijbe(M2A6KHTmPxfz(lGWvO6JUhqFoxvtMaSacrGYGeUtfsscqOgeAPmbybeIaL)DkJTV5ESzihSt)(CxE4pyHnQq)rKsijqAc)NRZU(qvPu9k4Akb0NZv1KjaMdWc8(dwzvO)CxE4pyHnQq)rKsi5QGpL)hSuW1ucOpNRQjtamhGf49hSYQq)5UqAwuC8FP(tyw2HwyjDf2zjU4TKfFiwq5xrGSytdlykalqUlp8hSWgvO)isjKa0NZv1KckpLuYX2BjnaOGca66fPef0NnMmxL1RYheFlqQE4pyzWVpTBidHmkSEk)xkHiRPG(SXK5QSEv(G49qSi6DnvVbdx6mSL)Dk3GdHFdvUQMar8y2hP6H)GLXY4)UHqgfwpL)lLq0gMnrQyBsRZ7o(jUlKMfR(k1MfaVp41GIWSyzNkw(DIL2HA)z5WS4QW1ZYdzHkqfWsBOkwDy5WS4QW1ZYdzHkqfWsh4IfFiw8NfeZgiIL4I3swUIfVyrXd6ZgtkGfKhxKyvvGfTJFmlEb)DAyzlqeMcywGdlDGlwSaxAqwGaPj42SKchILF3lw4eL3GL4I3swSStflDGlwSaxAWsrplaEFWRbfXsbTWD5H)Gf2Oc9hrkHe87dEnOifCnL6PcXy0x90yd1(tG52HA)ZdL6xH32kss6PUAnZ4aPcUW52qvS6ygk1VcVnQaOj1rgIhOt3ZX)46Sn0cni1yUrF0QRwZmoqQGlCUnufRoMLD)(jj9C8pUoBdTqdIa6Z5QAY4y7TKgauaXvxTMHc6Zgtzmu7JzOu)kmIaHVPTMozylt6vrM)ciGZdL6xH4BAuy8kR8gjjo(hxNTHwObra95CvnzCS9wsdakG4QRwZqb9zJPSEv(ygk1VcJiq4BARPtg2YKEvK5Vac48qP(vi(MgfgVYkVrF0uqF2yYCv2RoO7zT6Q1mbpFvWSStsS(DnvVb)(OHdOHkxvtG9r3RN1biudcTuMGNVkyw2jjbiqQ86ni0zoVqBDac1GqlLHsTHwOjRclqZYUFssacKkVEtDO2)CZP(O7zDacKkVEdqQ(9otsI1QRwZe88vbZYojXX)46Sn0cnXJy2OFssV31u9g87JgoGgQCvnbIwD1AMGNVkyw2O7PUAnd(9rdhqd(9acBhZKeh)JRZ2ql0epIzJ(9tsuxTMj45RcMLnARvxTMzCGubx4CBOkwDmlB0w)UMQ3GFF0Wb0qLRQjqUlKMLUbtS09bHfMLRyXkxLpSO4b9zJjw8cKfSdKyXQzx3qu3BP1S09bHfln4WcYJlsSQkWD5H)Gf2Oc9hrkHKISKtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkLK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvkM9r725WofqG7Yd)blSrf6pIucj7UULtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkHUxac1GqlLj45RcMHs9RWXRWnsscqOgeAPmbybeIaL)DkJTV5ESzOu)kC8kCJ(jj9c7(GIWkTj6Hc7(GIY)LsBRW(jjHDFqryLIzF0UDoStbe4U8WFWcBuH(JiLqsBP15uiSuW1uQN6Q1muqF2ykRxLpMHs9RWXtiJcRNY)LsO7fGqni0szcE(QGzOu)kC8kCJKKaeQbHwktawaHiq5FNYy7BUhBgk1VchVc3OFssVWUpOiSsBIEOWUpOO8FP02kSFssy3huewPy2hTBNd7uabUlKMfKcOIZcSyjaYD5H)Gf2Oc9hrkHel(mhCYWwM0RI4UqAw6gmXcG3N2nelpKf7bgybau7dlkEqF2yIf4WILDQy5kwGLUdlw5Q8HffpOpBmXIxGSSWelifqfNf7bgWSCnwUIfRCv(WIIh0NnM4U8WFWcBuH(JiLqc(9PDdPGRPef0NnMmxL1RYNKekOpBmzWqTp5Iq2NKqb9zJjJxDYfHSpjrD1Agl(mhCYWwM0RImlB0QRwZqb9zJPSEv(yw2jj9uxTMj45RcMHs9RWB7H)GLXY4)UHqgfwpL)lLqRUAntWZxfml7(CxE4pyHnQq)rKsiXY4)o3Lh(dwyJk0FePesMvL9WFWkRp8RGYtjLAUw)7ZI7I7cPzbW7dEnOiwAWHLuiqkLQNLvPjmMLf(kuSeByCJb3Lh(dwytZ16FFwkHFFWRbfPGRPK1ZQOgCqrgvx7vGYWw2168VFfkSHuS1zBtGCxinli3Xpl)oXci8zXY97S87elPq8ZYFPelpKfheKLv9NMLFNyj1rglGRX)dwSCyw2V3WcGv1UHyzOu)kmlPl9F26Jaz5HSK6FyNLuiSA3qSaUg)pyXD5H)Gf20CT(3NfIucj4v1UHuqOtqt53hu0JvszfCnLaHVjfcR2nKzOu)kC8dL6xHr8n3ePQ8wWD5H)Gf20CT(3NfIucjPqy1UH4U4UqAw6gmXcG3h8AqrS8qwqGiBww2S87elw9H8u1RaPHf1vRXY1y5EwSaxAqwiKzFdXIk1GdXs7QdVFfkw(DILIq2ZsWXplWHLhYc4k1MfvQbhIfKdlGqeiUlp8hSWg8Re(9bVguKcUMsZQOgCqrM)sjlWPYGd5PQxbsd6EuqF2yYCv2RoOTUxp1vRz(lLSaNkdoKNQEfinMHs9RWX7H)GLXY4)UHqgfwpL)lLq0ggLr3Jc6ZgtMRYQWFpjHc6ZgtMRYyO2NKekOpBmz0RYNCri77NKOUAnZFPKf4uzWH8u1RaPXmuQFfoEp8hSm43N2nKHqgfwpL)lLq0ggLr3Jc6ZgtMRY6v5tscf0NnMmyO2NCri7tsOG(SXKXRo5Iq23VFsI1QRwZ8xkzbovgCipv9kqAml7(jj9uxTMj45RcMLDscqFoxvtMaSacrGYGeUtf6JoaHAqOLYeGfqicu(3Pm2(M7XMHCWoOdqGu51BQd1(NBo1hDpRdqGu51BqOZCELKeGqni0szOuBOfAYQWc0muQFfo(TOp6EQRwZe88vbZYojX6aeQbHwktWZxfmd5GD6ZDH0S0nyIL4c62)bKybGfFszXYovS870qSCywkilE4pGelyl(KQawCmlA)jwCml2qm(u1elWIfSfFszXY97SSjlWHLgzHgwWVhqaZcCybwS4SeteXc2IpPSGHS87(ZYVtSuKfwWw8jLfFMdiHzbPKf(zXBpnS87(Zc2IpPSqiZ(gcZD5H)Gf2GFePesCq3(pGugBXNufe6e0u(9bf9yLuwbxtjRbHVXbD7)aszSfFsZGEQJIm)fq4kuOT2d)blJd62)bKYyl(KMb9uhfzUk30hQ9hDpRbHVXbD7)aszSfFsZ7KRn)fq4kujjGW34GU9FaPm2IpP5DY1MHs9RWXRW(jjGW34GU9FaPm2IpPzqp1rrg87be2oMObHVXbD7)aszSfFsZGEQJImdL6xH3oMObHVXbD7)aszSfFsZGEQJIm)fq4kuCxinlDdMWSGCybeIaXY1yb5Xfjwvfy5WSSSzboS0bUyXhIfqc3PcxHIfKhxKyvvGfl3VZcYHfqicelEbYsh4IfFiwujn0clwXgSex8wYD5H)Gf2GFePescWciebk)7ugBFZ9yfCnLSgCwhOPG5aigDVEa95CvnzcWciebkds4ovaT1biudcTuMGNVkygYb7G26zvudoOiJ9CPWb8CD2NGxxiBV0yFssuxTMj45RcMLDF0o(hxNTHwOzBLSInq3tD1AgkOpBmL1RYhZqP(v44vEJKe1vRzOG(SXugd1(ygk1VchVYB0pjrfIXOBhQ9ppuQFfEBL3aT1biudcTuMGNVkygYb70N7cPzb5Wc8(dwS0GdlUwZci8XS87(ZsQJaHzbVgILFN6WIpuPONLHAdH3jqwSStflwToqQGlmlDVHQy1HLDhZIMWyw(DVyrHSGPaMLHs9RUcflWHLFNybHoZ5flQRwJLdZIRcxplpKLMR1SaBnwGdlE1HffpOpBmXYHzXvHRNLhYcHm7BiUlp8hSWg8JiLqcqFoxvtkO8usjq4NhsXw3qPu9yfa01lsPEQRwZmoqQGlCUnufRoMHs9RWXRWKeRvxTMzCGubx4CBOkwDml7(OTwD1AMXbsfCHZTHQy1jJVQT059o4NMZnlB09uxTMbHRahcmtP2ql0Ks1NPIguxSiZqP(v4TrfanPoY6JUN6Q1muqF2ykJHAFmdL6xHJhva0K6iljrD1AgkOpBmL1RYhZqP(v44rfanPoYss6zT6Q1muqF2ykRxLpMLDsI1QRwZqb9zJPmgQ9XSS7J2631u9gmuJ)lqgQCvnb2N7cPzb5Wc8(dwS87(ZsyNciGz5AS0bUyXhIf46XhiXcf0NnMy5HSalDhwaHpl)onelWHLdvbhILF)WSy5(Dwaa14)ce3Lh(dwyd(rKsibOpNRQjfuEkPei8ZW1Jpqktb9zJjfa01lsPEwRUAndf0NnMYyO2hZYgT1QRwZqb9zJPSEv(yw29tsExt1BWqn(VazOYv1ei3Lh(dwyd(rKsijfcR2nKccDcAk)(GIESskRGRP0qTHW7UQMq3tD1AgkOpBmLXqTpMHs9RWXpuQFfojrD1AgkOpBmL1RYhZqP(v44hk1VcNKa0NZv1Kbe(z46XhiLPG(SXuF0d1gcV7QAc97dk6n)Ls5hMbpkEL3eTBNd7uab0a95CvnzaHFEifBDdLs1J5U8WFWcBWpIucj4v1UHuqOtqt53hu0JvszfCnLgQneE3v1e6EQRwZqb9zJPmgQ9XmuQFfo(Hs9RWjjQRwZqb9zJPSEv(ygk1Vch)qP(v4KeG(CUQMmGWpdxp(aPmf0NnM6JEO2q4DxvtOFFqrV5Vuk)Wm4rXR8MOD7CyNciGgOpNRQjdi8ZdPyRBOuQEm3Lh(dwyd(rKsib)Kw7tUP9HuqOtqt53hu0JvszfCnLgQneE3v1e6EQRwZqb9zJPmgQ9XmuQFfo(Hs9RWjjQRwZqb9zJPSEv(ygk1Vch)qP(v4KeG(CUQMmGWpdxp(aPmf0NnM6JEO2q4DxvtOFFqrV5Vuk)Wm4rXRmIfTBNd7uab0a95CvnzaHFEifBDdLs1J5UqAw6gmXs3dghwGflbqwSC)oC9SeCB7RqXD5H)Gf2GFePesAWjqzylx(Vgsbxtj3oh2PacCxinlDdMybP8vGdbYca7BUhZIL73zXRoSOHfkwOcUqTZI2X)vOyrXd6ZgtS4fil)0HLhYI(kIL7zzzZIL73zzlxASpS4filipUiXQQa3Lh(dwyd(rKsiHsTHwOjRclqfCnL61tD1AgkOpBmLXqTpMHs9RWXR8gjjQRwZqb9zJPSEv(ygk1VchVYB0hDac1GqlLj45RcMHs9RWXhZnq3tD1Ag75sHd456SpbVUq2EPX(ya66fT9MwXgjjwpRIAWbfzSNlfoGNRZ(e86cz7Lg7JHuS1zBtG97NKOUAnJ9CPWb8CD2NGxxiBV0yFmaD9IIxPn3QnssuxTMj45RcMHs9RWXR8gCxinlDdMyb5XfjwvfyXY97SGCybeIaHeKYxboeilaSV5EmlEbYciSu0ZceinwM7jw2YLg7dlWHfl7uXsS1qiOEHFwSaxAqwiKzFdXIk1GdXcYJlsSQkWcHm7Bim3Lh(dwyd(rKsibOpNRQjfuEkPuamhGf49hSY4xbaD9IuYAWzDGMcMdGy0a95CvnzcG5aSaV)Gf6E9cqOgeAPmuQDNHCDgoGLxbYmuQFfEBLrSBfI6PSYi(SkQbhuKbFvBPZ7DWpnN3hnPyRZ2ManuQDNHCDgoGLxbQFsIJ)X1zBOfAIxjeZgO7z97AQEtBnDYWwM0RImu5QAcmjrD1AMGNVkyaxJ)hSIpaHAqOLY0wtNmSLj9QiZqP(vyeTf9rdcFdEvTBiZqP(v443c0GW3KcHv7gYmuQFfoEed6EGW3GFsR9j30(qMHs9RWXR8gjjw)UMQ3GFsR9j30(qgQCvnb2hnqFoxvtMFFoToJjcbAYw87r3laHAqOLYqP2ql0KvHfOzzNKyDacKkVEdcDMZR(OFFqrV5Vuk)Wm4rXRUAntWZxfmGRX)dwi(gMTkjrfIXOBhQ9ppuQFfEB1vRzcE(QGbCn(FWkjjabsLxVPou7FU5usI6Q1mQAieuVWVzzJwD1AgvnecQx43muQFfEB1vRzcE(QGbCn(FWcr9qmi(SkQbhuKXEUu4aEUo7tWRlKTxASpgsXwNTnb2VpARvxTMj45RcMLn6EwhGaPYR3uhQ9p3CkjjaHAqOLYeGfqicu(3Pm2(M7XMLDsIkeJr3ou7FEOu)k82biudcTuMaSacrGY)oLX23Cp2muQFfgri2KevigJUDO2)8qP(vyKksv5TyJTvxTMj45RcgW14)bR(CxinlDdMy53jwSAq1V3zyXY97S4SG84IeRQcS87(ZYHlf9S0gyklB5sJ9H7Yd)blSb)isjKmoqQGlCUnufRok4AkPUAntWZxfmdL6xHJxzfMKOUAntWZxfmGRX)dwBhZnrd0NZv1KjaMdWc8(dwz8ZD5H)Gf2GFePescKMW)56SRpuvkvVcUMsa95CvnzcG5aSaV)Gvg)O7PUAntWZxfmGRX)dwXRum3mjX6aeivE9gGu97DM(jjQRwZmoqQGlCUnufRoMLnA1vRzghivWfo3gQIvhZqP(v4TrmikalW19g7HchMYU(qvPu9M)sPmqxVie1ZA1vRzu1qiOEHFZYgT1VRP6n43hnCanu5QAcSp3Lh(dwyd(rKsi5QGpL)hSuW1ucOpNRQjtamhGf49hSY4N7cPzXQHpNRQjwwycKfyXIRE67pcZYV7plw86z5HSOsSGDGeiln4WcYJlsSQkWcgYYV7pl)o1HfFO6zXIJFcKfKsw4NfvQbhILFNs5U8WFWcBWpIucja95CvnPGYtjLWoqk3Gto45RckaORxKswhGqni0szcE(QGzihStsI1a95CvnzcWciebkds4ovaDacKkVEtDO2)CZPKeWzDGMcMdGyUlKMLUbtyw6EqfNLRXYvS4flkEqF2yIfVaz5NJWS8qw0xrSCpllBwSC)olB5sJ9rbSG84IeRQcS4filXf0T)diXcal(KYD5H)Gf2GFePesARPtg2YKEvKcUMsuqF2yYCv2RoOD7CyNciGwD1Ag75sHd456SpbVUq2EPX(ya66fT9MwXgO7bcFJd62)bKYyl(KMb9uhfz(lGWvOssSoabsLxVPOWa1WbSpAG(CUQMmyhiLBWjh88vb09uxTMzCGubx4CBOkwDmdL6xH3gX0T9uiIpRIAWbfzWx1w68Eh8tZ5iYAsXwNTnbAUc)Zk8WbNbpGxrzvsR7JwD1AMXbsfCHZTHQy1XSStsSwD1AMXbsfCHZTHQy1XSS7JUN1biqQ86ni0zoVsscqOgeAPmuQn0cnzvybAgk1Vch)MB0N7cPzPBWelD)f97Sa49P5Anl2dmGz5ASa49P5AnlhUu0ZYYM7Yd)blSb)isjKGFFAUwRGRPK6Q1mWI(DC2MMaz)hSmlB0QRwZGFFAUwBgQneE3v1e3Lh(dwyd(rKsij4vG0z1vRPGYtjLWVpA4aQGRPK6Q1m43hnCandL6xH3wHO7PUAndf0NnMYyO2hZqP(v44vysI6Q1muqF2ykRxLpMHs9RWXRW(OD8pUoBdTqt8iMn4UqAwS6RuBmlXfVLSOsn4qSGCybeIaXYcFfkw(DIfKdlGqeiwcWc8(dwS8qwc7uabwUglihwaHiqSCyw8WVCTUdlUkC9S8qwujwco(5U8WFWcBWpIucj43h8Aqrk4AkfGaPYR3uhQ9p3CcnqFoxvtMaSacrGYGeUtfqhGqni0szcWciebk)7ugBFZ9yZqP(v4TviARbN1bAkyoaIrtb9zJjZvzV6G2X)46Sn0cnXBfBWDH0S0nyIfaVpnxRzXY97Sa4jT2hwS6Z1Ew8cKLcYcG3hnCavalw2PILcYcG3NMR1SCyww2kGLoWfl(qSCflw5Q8HffpOpBmXsdoSSfictbmlWHLhYI9adSSLln2hwSStflUkeiXcIzdwIlElzboS4G2(FajwWw8jLLDhZYwGimfWSmuQF1vOyboSCywUILM(qT)gwId8jw(D)zzvG0WYVtSG9uILaSaV)GfML7veMfqBmlfT(X1S8qwa8(0CTMfW1CfkwSADGubxyw6EdvXQJcyXYovS0bUueil4)0AwOcKLLnlwUFNfeZgiYX2S0Gdl)oXI2XplO0qvxJnCxE4pyHn4hrkHe87tZ1AfCnLExt1BWpP1(KbNR9gQCvnbI2631u9g87JgoGgQCvnbIwD1Ag87tZ1AZqTHW7UQMq3tD1AgkOpBmL1RYhZqP(v443c0uqF2yYCvwVkFqRUAnJ9CPWb8CD2NGxxiBV0yFmaD9I2EtfUrsI6Q1m2ZLchWZ1zFcEDHS9sJ9Xa01lkEL2uHBG2X)46Sn0cnXJy2ijbe(gh0T)diLXw8jnd6PokYmuQFfo(TijXd)blJd62)bKYyl(KMb9uhfzUk30hQ9Vp6aeQbHwktWZxfmdL6xHJx5n4UqAw6gmXcG3h8AqrS09x0VZI9adyw8cKfWvQnlXfVLSyzNkwqECrIvvbwGdl)oXIvdQ(9odlQRwJLdZIRcxplpKLMR1SaBnwGdlDGlfbYsWTzjU4TK7Yd)blSb)isjKGFFWRbfPGRPK6Q1mWI(DCoOjFYap8blZYojrD1AgeUcCiWmLAdTqtkvFMkAqDXIml7Ke1vRzcE(QGzzJUN6Q1mJdKk4cNBdvXQJzOu)k82OcGMuhziEGoDph)JRZ2ql0GuJ5g9rumr831u9MISKtHWYqLRQjq0wpRIAWbfzWx1w68Eh8tZ5OvxTMzCGubx4CBOkwDml7Ke1vRzcE(QGzOu)k82OcGMuhziEGoDph)JRZ2ql0GuJ5g9tsuxTMzCGubx4CBOkwDY4RAlDEVd(P5CZYojPN6Q1mJdKk4cNBdvXQJzOu)k82E4pyzWVpTBidHmkSEk)xkHgBtADE3XpT9ggRijrD1AMXbsfCHZTHQy1XmuQFfEBp8hSmwg)3neYOW6P8FPuscqFoxvtMtXaZbybE)bl0biudcTuMRWHz9UQMYk2YRFLMbjGxGmd5GDqtk26STjqZv4WSExvtzfB51VsZGeWlq9rRUAnZ4aPcUW52qvS6yw2jjwRUAnZ4aPcUW52qvS6yw2OToaHAqOLYmoqQGlCUnufRoMHCWojjwhGaPYR3aKQFVZ0pjXX)46Sn0cnXJy2anf0NnMmxL9Qd3fsZsmMoS8qwsDeiw(DIfvc)SaBSa49rdhqwu7Wc(9acxHIL7zzzZIITUac6oSCflE1HffpOpBmXI66zzlxASpSC46zXvHRNLhYIkXI9adbcK7Yd)blSb)isjKGFFWRbfPGRP07AQEd(9rdhqdvUQMarB9SkQbhuK5VuYcCQm4qEQ6vG0GUN6Q1m43hnCanl7Keh)JRZ2ql0epIzJ(OvxTMb)(OHdOb)EaHTJj6EQRwZqb9zJPmgQ9XSStsuxTMHc6Zgtz9Q8XSS7JwD1Ag75sHd456SpbVUq2EPX(ya66fT9MB1gO7fGqni0szcE(QGzOu)kC8kVrsI1a95CvnzcWciebkds4ovaDacKkVEtDO2)CZP(Cxinlko(Vu)jml7qlSKUc7Sex8wYIpelO8RiqwSPHfmfGfi3Lh(dwyd(rKsibOpNRQjfuEkPKJT3sAaqbfa01lsjkOpBmzUkRxLpi(wGu9WFWYGFFA3qgczuy9u(Vucrwtb9zJjZvz9Q8bX7Hyr07AQEdgU0zyl)7uUbhc)gQCvnbI4XSps1d)blJLX)DdHmkSEk)xkHOnmwHcrQyBsRZ7o(jeTHrHi(7AQEt5)AiCw11EfidvUQMa5UqAwS6RuBwa8(GxdkILRyXzzRqeMcSaaQ9HffpOpBmPawaHLIEw00ZY9SypWalB5sJ9HLE)U)SCyw29cutGSO2Hf6(DAy53jwa8(0CTMf9velWHLFNyjU4TmEeZgSOVIyPbhwa8(GxdkQVcybewk6zbcKglZ9elEXs3Fr)ol2dmWIxGSOPNLFNyXvHajw0xrSS7fOMybW7JgoGCxE4pyHn4hrkHe87dEnOifCnLSEwf1GdkY8xkzbovgCipv9kqAq3tD1Ag75sHd456SpbVUq2EPX(ya66fT9MB1gjjQRwZypxkCapxN9j41fY2ln2hdqxVOT3uHBG(DnvVb)Kw7tgCU2BOYv1eyF09OG(SXK5QmgQ9bTJ)X1zBOfAqeqFoxvtghBVL0aGciU6Q1muqF2ykJHAFmdL6xHrei8nT10jdBzsVkY8xabCEOu)keFtJcJFl2ijHc6ZgtMRY6v5dAh)JRZ2ql0GiG(CUQMmo2ElPbafqC1vRzOG(SXuwVkFmdL6xHrei8nT10jdBzsVkY8xabCEOu)keFtJcJhXSrF0wRUAndSOFhNTPjq2)blZYgT1VRP6n43hnCanu5QAceDVaeQbHwktWZxfmdL6xHJFRssWWLw9kqZVpNwNXeHangQCvnbIwD1AMFFoToJjcbAm43diSDmJz32Bwf1GdkYGVQT059o4NMZrCf2hD7qT)5Hs9RWXR8gBGUDO2)8qP(v4T3CJnssaN1bAkyoaI7JUxac1GqlLbHRahcmJTV5ESzOu)kC8BvsI1biqQ86ni0zoV6ZDH0S0nyILUpiSWSCflw5Q8HffpOpBmXIxGSGDGelwn76gI6ElTMLUpiSyPbhwqECrIvvbw8cKfKYxboeilkEQn0cnPu9CxE4pyHn4hrkHKISKtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkLK0lS7dkcR0MOhkS7dkk)xkTTc7NKe29bfHvkM9r725WofqanqFoxvtgSdKYn4KdE(Qa3Lh(dwyd(rKsiz31TCkewk4Ak1tD1AgkOpBmL1RYhZqP(v44jKrH1t5)sj0whGaPYR3GqN58kjPN6Q1miCf4qGzk1gAHMuQ(mv0G6Ifzw2OdqGu51BqOZCE1pjPxy3huewPnrpuy3huu(VuABf2pjjS7dkcRumtsuxTMj45RcMLDF0UDoStbeqd0NZv1Kb7aPCdo5GNVkGUN6Q1mJdKk4cNBdvXQJzOu)k829uy3UjIpRIAWbfzWx1w68Eh8tZ59rRUAnZ4aPcUW52qvS6yw2jjwRUAnZ4aPcUW52qvS6yw295U8WFWcBWpIucjTLwNtHWsbxtPEQRwZqb9zJPSEv(ygk1VchpHmkSEk)xkH26aeivE9ge6mNxjj9uxTMbHRahcmtP2ql0Ks1NPIguxSiZYgDacKkVEdcDMZR(jj9c7(GIWkTj6Hc7(GIY)LsBRW(jjHDFqryLIzsI6Q1mbpFvWSS7J2TZHDkGaAG(CUQMmyhiLBWjh88vb09uxTMzCGubx4CBOkwDmdL6xH3wHOvxTMzCGubx4CBOkwDmlB0wpRIAWbfzWx1w68Eh8tZ5jjwRUAnZ4aPcUW52qvS6yw295UqAw6gmXcsbuXzbwSea5U8WFWcBWpIucjw8zo4KHTmPxfXDH0S0nyIfaVpTBiwEil2dmWcaO2hwu8G(SXKcyb5Xfjwvfyz3XSOjmML)sjw(DVyXzbPy8FNfczuy9elAQ9SahwGLUdlw5Q8HffpOpBmXYHzzzZD5H)Gf2GFePesWVpTBifCnLOG(SXK5QSEv(G2A1vRzghivWfo3gQIvhZYojHc6Zgtgmu7tUiK9jjuqF2yY4vNCri7ts6PUAnJfFMdozylt6vrMLDsc2M068UJFA7nmwHcrBDacKkVEdqQ(9otsc2M068UJFA7nmwb6aeivE9gGu97DM(OvxTMHc6Zgtz9Q8XSSts6PUAntWZxfmdL6xH32d)blJLX)DdHmkSEk)xkHwD1AMGNVkyw295UqAw6gmXcsX4)olWFNglhMyXY(f2z5WSCflaGAFyrXd6ZgtkGfKhxKyvvGf4WYdzXEGbwSYv5dlkEqF2yI7Yd)blSb)isjKyz8FN7cPzP75A9VplUlp8hSWg8JiLqYSQSh(dwz9HFfuEkPuZ16FFwraW2uikokVXMrF0hfb]] )
    

end