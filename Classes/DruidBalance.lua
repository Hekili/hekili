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


    spec:RegisterPack( "Balance", 20220302, [[dmLk7fqikLEeIkDjeQytKsFsPuJsI6ukKvjrYRqaZIuKBrkk7IIFHO0WuOCmsHLrP4zcrnneOUgIQ2gcv6BikQXjeX5KiK1jrW8qqUNqyFkf9pjcv1aLiuLdQusluHQEicLjskQCrevSref5JiqQmseivDsfQyLkfEPeHkZerHBskQYovkXpjfv1qrG4OsekAPiqkpfqtvIuxvHkTvjcL(kcKmweQAVc1FL0GjomvlMu9ybtgOldTzf9zez0kvNwLvlrOWRriZMKBlHDl63GgoLCCHiTCPEostxvxxjBhGVtPA8iOoVqA9senFfSFuhRrCPJbc6pgVfBgZgBglYJzJrJiHGTjYrog4h1cJbA5bICsymW0lWyGJ3vEgWyGwEuf0bJlDmqkC1bmg4()w0sGSKv3vEgqnJEfbdP73x6Mds2X7kpdOMb8kigzlan7FHQe)5PWi0DLNb08e(JbQVo1pozSEmqq)X4TyZy2yZyrEmBmAejeSnAqCJb6RFh2XabEfelg4(bcIzSEmqqKgIboEx5zazrZ1RdK3qZZ7Wol2OjwSzmBSH3G3Gy7EscPLaVHMXYwbbrqwacvEZY4rVWWBOzSqSDpjHGS8Etc)6nzj4uKYYdzjenOW67nj8PgEdnJfcAybeacYYktmGuQ3rzbG3NRRqklLpdA0elwncOsFVPRMeYIMTjlwncWqFVPRMeoYWBOzSSvaWdKfRgdo9VKeleuT)7SCtwUFBkl)oYI9gMKyHCcQZIIgEdnJfnpNiKfIbtaqIqw(DKfGwxFpLfNf19VczPa2iltfs4txHSu(MSefUyz3bZTFw2VNL7zHEfl17jcxuvuwSF)olJxZFRLMfcWcXqfs)ZvSSv1rklW81el3VniluIoRrgEdnJfnpNiKLci9zz75rA)Rnw4xs3MfAatVpiLf3YsfLLhYIoKszzEK2FklWuf1WBOzSu6g9NLsdlqwGtwgVY3zz8kFNLXR8DwCklolulmCUILVVKi8n8gAglA(wyInlLpdA0eleuT)7AIfcQ2)DnXcW37514iwkCqKLcyJS0i9uhMplpKf0B1HnlbyHU)Ag99(n8gAglKPJWSuI7sWgbzHCkSG2XUaZNLWogiILjSzHyAowwuNeAIbQo6tJlDmqOfMyhx64TOrCPJbIPRRqW4Xhd0d)bZyG2B)3JbcI0qFw)bZyGeKgdo9zXgwiOA)3zXtqwCwa(EtxnjKfyYcWsZI973zzlhP9NfYKJS4jilJhU1sZcSzb4798AKf4VJT9JIXad99yFEmWYSGb1zrrJALExtKWplddSGb1zrrZLvku5nlddSGb1zrrZLvD4VZYWalyqDwu04z0AIe(zzelAzXQragnm2B)3zrll2YIvJam2yS3(Vh)XBXM4shdetxxHGXJpgOh(dMXaPV3ZRXyGH(ESppgOTS0ReNWMeA0DLNbScNvxPQ)(LKOgmDDfcYYWal2YsacatpFtEK2)60rwggyXwwOwOsvFVjHp1qFVNUsXseSOblddSyllVRW8nP)RgPvDx5zany66keKLHbwkZcguNffnuOY7AIe(zzyGfmOolkAUSQwP3SmmWcguNffnxw1H)olddSGb1zrrJNrRjs4NLrXavxI1aymqYh)XBjYXLogiMUUcbJhFmqp8hmJbsFVNxJXad99yFEmWYSyll9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSmmWITSeGaW0Z3KhP9VoDKLHbwSLfQfQu13Bs4tn037PRuSeblAWYWal2YY7kmFt6)QrAv3vEgqdMUUcbzzelAzXwwO4x1H5IA(dBBIKQnwbwggyPmlyqDwu0qHkVRjs4NLHbwWG6SOO5YQALEZYWalyqDwu0Czvh(7SmmWcguNffnEgTMiHFwgfduDjwdGXajF8hVfcoU0XaX01viy84Jb6H)Gzmq67nD1KWyGH(ESppgyzw6vItytcn6UYZawHZQRu1F)ssudMUUcbzrllbiam98n5rA)RthzrlluluPQV3KWNAOV3txPyjcw0GLrSOLfBzHIFvhMlQ5pSTjsQ2yfIbQUeRbWyGKp(J)yGG40xQpU0XBrJ4shd0d)bZyGuOY7Qo6fXaX01viy84J)4TytCPJbIPRRqW4Xhdm03J95Xa)RazHqSuMfByPuS4H)GPXE7)Uj40V(xbYcbyXd)btd99EEnAco9R)vGSmkgi97l8XBrJyGE4pygdm4kv1d)bZQ6OFmq1r)A6fymqOfMyh)XBjYXLogiMUUcbJhFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdKAHkv99Me(ud99E6kflBYIgSOLLYSyllVRW8n03BfSbny66keKLHbwExH5BOpQuExb7B(gmDDfcYYiwggyHAHkv99Me(ud99E6kflBYInXabrAOpR)GzmqG4tzzRqYHfyYsKjal2VFhUEwa7B(S4jil2VFNfGV3kydYINGSydbyb(7yB)OymqaExtVaJbE0QdX4pEleCCPJbIPRRqW4XhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXaPwOsvFVjHp1qFVNxJSSjlAedeePH(S(dMXabIpLLGcDail23XKfGV3ZRrwcEYY(9Sydby59Me(uwSVFHDwoklnQqaE(SmHnl)oYc5euNffz5HSOJSy14e7gbzXtqwSVFHDwMNsHnlpKLGt)yGa8UMEbgd8O1GcDay8hVfYhx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqRgbujfanAykGWCEnYYWalwncOskaA0Wqx58AKLHbwSAeqLua0OHH(EtxnjKLHbwSAeqLua0OHH(EpDLILHbwSAeqLua0OHzU6Ov4SIQvISmmWIvJamTdat4IwNnMLmklddSOVMttWRxgmnw4xszjcw0xZPj41ldgWv7)btwggybG3NRRqZrRoeJbcI0qFw)bZyGLy9(CDfYYV7plHDmqeLLBYsu4IfVrwUKfNfsbqwEiloa4bYYVJSqVF5)btwSVJnYIZY3xse(SGFGLJYYIIGSCjl64BhXKLGtFAmqaExtVaJbEzLuam(J3cXnU0XaX01viy84Jb6H)GzmqDSPyt0LKIbcI0qFw)bZyGJlfzz8ytXMOljXI)S87ilycYcCYczQXSKrzX(oMSS70hz5OS46qaile3XioAIfF(yZcXGjairilEcYc83X2(rrwSF)oleBRKDCYqmWqFp2NhdSmlLzXwwcqay65BYJ0(xNoYYWal2YsacvGq7PjataqIW6VJvQ113tnllwggyPxjoHnj0eqfs)ZvvQ113tny66keKLrSOLf91CAcE9YGPXc)sklBYIgKNfTSOVMtt7aWeUO1zJzjJAASWVKYcHyHGzrll2YsacatpFdam)9OnlddSeGaW0Z3aaZFpAZIww0xZPj41ldMLflAzrFnNM2bGjCrRZgZsg1SSyrllLzrFnNM2bGjCrRZgZsg10yHFjLfcfblAydlAglemlLILEL4e2Kqd9Y5sv3JsFSp3GPRRqqwggyrFnNMGxVmyASWVKYcHyrdnyzyGfnyHSSqTqLQU70hzHqSOHH4YYiwgXIwwa4956k0CzLuam(J3czoU0XaX01viy84Jbg67X(8yGLzrFnNMGxVmyASWVKYYMSOb5zrllLzXww6vItytcn0lNlvDpk9X(CdMUUcbzzyGf91CAAhaMWfToBmlzutJf(LuwielAuIyrll6R500oamHlAD2ywYOMLflJyzyGfDiLYIwwMhP9V2yHFjLfcXInKNLrSOLfaEFUUcnxwjfaJbcI0qFw)bZyGee4ZI973zXzHyBLSJtgy539NLJMB)S4SqqwkQ3Sy1WalWMf77yYYVJSmps7plhLfxhUEwEilycgd0d)bZyGwW)Gz8hVLijU0XaX01viy84JbcTIbsXpgOh(dMXab4956kmgiaxTWyGb8uSuMLYSmps7FTXc)sklAglAqEw0mwcqOceApnbVEzW0yHFjLLrSqww0isgJLrSeblb8uSuMLYSmps7FTXc)sklAglAqEw0mwcqOceApnbycasew)DSsTU(EQbC1(FWKfnJLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYYiwillAejJXYiw0YITS0(bwray(gheKAqcF0NYIwwkZITSeGqfi0EAcE9YGPrhmklddSyllbiubcTNMambajcnn6GrzzelddSeGqfi0EAcE9YGPXc)sklBYYLp2wqL)iyDEK2)AJf(LuwggyPxjoHnj0eqfs)ZvvQ113tny66keKfTSeGqfi0EAcE9YGPXc)sklBYsKhJLHbwcqOceApnbycasew)DSsTU(EQPXc)sklBYYLp2wqL)iyDEK2)AJf(Luw0mw0ymwggyXwwcqay65BYJ0(xNogdeePH(S(dMXajMRclL)iLf774VJnll6LKyHyWeaKiKLeANf7NsXIRuq7SefUy5HSq)tPyj40NLFhzH6filEbCLplWjledMaGeHeGyBLSJtgyj40NgdeG310lWyGbycasewbrA0me)XBPefx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymWYS8EtcFZFfy9HvWdzztw0G8SmmWs7hyfbG5BCqqQ5sw2KfYpglJyrllLzPmlyKUolle0GfwrB0vvydMEgqw0YszwSLLaeaME(gay(7rBwggyjaHkqO90GfwrB0vvydMEgqtJf(LuwielAqCjZSqawkZc5zPuS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYiwgXIwwSLLaeQaH2tdwyfTrxvHny6zann6GrzzelddSGr66SSqqdfUuk8)ljv7LEuw0YszwSLLaeaME(M8iT)1PJSmmWsacvGq7PHcxkf()LKQ9spAnYem5JKX0W0yHFjLfcXIgAqWSmILHbwkZsacvGq7PrhBk2eDjjtJoyuwggyXwwApGMVHkflddSeGaW0Z3KhP9VoDKLrSOLLYSyllVRW8nZvhTcNvuTs0GPRRqqwggyjabGPNVbaM)E0MfTSeGqfi0EAMRoAfoROALOPXc)skleIfn0GfcWc5zPuS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYWal2YsacatpFdam)9OnlAzjaHkqO90mxD0kCwr1krtJf(Luwiel6R50e86Lbd4Q9)GjleGfnSHLsXsVsCcBsOXQVcydEUQ6DWZluTwkQ3gmDDfcYIMXIg2WYiw0YszwWiDDwwiO5sAOxVRRWAKU88xfvqeWfqw0YsacvGq7P5sAOxVRRWAKU88xfvqeWfqtJf(LuwielKNLrSmmWszwkZcgPRZYcbn0DheAhbRWwVcN1h2fy(SOLLaeQaH2tZd7cmFeSEj9iT)1itEYhzB0W0yHFjLLrSmmWszwkZcaVpxxHgywxuS(9LeHplrWIgSmmWcaVpxxHgywxuS(9LeHplrWsKzzelAzPmlFFjr4BEnmn6GrRbiubcTNSmmWY3xse(MxdtacvGq7PPXc)sklBYYLp2wqL)iyDEK2)AJf(Luw0mw0ymwgXYWala8(CDfAGzDrX63xse(Sebl2WIwwkZY3xse(M3gtJoy0AacvGq7jlddS89LeHV5TXeGqfi0EAASWVKYYMSC5JTfu5pcwNhP9V2yHFjLfnJfngJLrSmmWcaVpxxHgywxuS(9LeHplrWYySmILrSmkgiisd9z9hmJboUueKLhYciQ8OS87illQtczbozHyBLSJtgyX(oMSSOxsIfq4sxHSatwwuKfpbzXQray(SSOojKf77yYINS4GGSGaW8z5OS46W1ZYdzb8WyGa8UMEbgdmawdWe8(dMXF8w0yS4shdetxxHGXJpgi0kgif)yGE4pygdeG3NRRWyGaC1cJbAllu4sPFjO537tPQuejcBdMUUcbzzyGL5rA)Rnw4xszztwSzSXyzyGfDiLYIwwMhP9V2yHFjLfcXInKNfcWszwi4XyrZyrFnNMFVpLQsrKiSn03deXsPyXgwgXYWal6R50879PuvkIeHTH(EGiw2KLihjSOzSuMLEL4e2Kqd9Y5sv3JsFSp3GPRRqqwkfl2WYOyGGin0N1FWmgyjwVpxxHSSOiilpKfqu5rzXZOS89LeHpLfpbzjaszX(oMSy3V)ssSmHnlEYc5SS2H95Sy1WqmqaExtVaJb(79PuvkIeHD1UFF8hVfn0iU0XaX01viy84JbcI0qFw)bZyGJlfzHCkSI2ORyrZVbtpdil2mgfduw0XjSrwCwi2wj74KbwwuKfyZcfYYV7pl3ZI9tPyrDjYYYIf73VZYVJSGjilWjlKPgZsgngy6fymqSWkAJUQcBW0Zagdm03J95XadqOceApnbVEzW0yHFjLfcXInJXIwwcqOceApnbycasew)DSsTU(EQPXc)skleIfBgJfTSuMfaEFUUcn)EFkvLIiryxT73ZYWal6R50879PuvkIeHTH(EGiw2KLipgleGLYS0ReNWMeAOxoxQ6Eu6J95gmDDfcYsPyjYSmILrSOLfaEFUUcnxwjfazzyGfDiLYIwwMhP9V2yHFjLfcXsKjZXa9WFWmgiwyfTrxvHny6zaJ)4TOHnXLogiMUUcbJhFmqqKg6Z6pygdCCPilaHlLc)ljXcbTLEuwiUumqzrhNWgzXzHyBLSJtgyzrrwGnluil)U)SCpl2pLIf1LilllwSF)ol)oYcMGSaNSqMAmlz0yGPxGXaPWLsH)FjPAV0Jgdm03J95XalZsacvGq7Pj41ldMgl8lPSqiwiUSOLfBzjabGPNVbaM)E0MfTSyllbiam98n5rA)RthzzyGLaeaME(M8iT)1PJSOLLaeQaH2ttaMaGeH1FhRuRRVNAASWVKYcHyH4YIwwkZcaVpxxHMambajcRGinAgyzyGLaeQaH2ttWRxgmnw4xszHqSqCzzelddSeGaW0Z3aaZFpAZIwwkZITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYIwwcqOceApnbVEzW0yHFjLfcXcXLLHbw0xZPPDaycx06SXSKrnnw4xszHqSOXySqawkZc5zPuSGr66SSqqZL0VxHh20k4b4sSQJkflJyrll6R500oamHlAD2ywYOMLflJyzyGfDiLYIwwMhP9V2yHFjLfcXInKNLHbwWiDDwwiOblSI2ORQWgm9mGSOLLaeQaH2tdwyfTrxvHny6zannw4xszztwSzmwgXIwwa4956k0CzLuaKfTSyllyKUolle0Cjn0R31vynsxE(RIkic4cilddSeGqfi0EAUKg6176kSgPlp)vrfebCb00yHFjLLnzXMXyzyGfDiLYIwwMhP9V2yHFjLfcXInJfd0d)bZyGu4sPW)VKuTx6rJ)4TOrKJlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgO(AonbVEzW0yHFjLLnzrdYZIwwkZITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYWal6R500oamHlAD2ywYOMgl8lPSqOiyrdYBipleGLYSezd5zPuSOVMtJUccbvl6BwwSmIfcWszwiyd5zrZyjYgYZsPyrFnNgDfecQw03SSyzelLIfmsxNLfcAUK(9k8WMwbpaxIvDuPyHaSqWgYZsPyPmlyKUolle087yDEn9R0J0PyrllbiubcTNMFhRZRPFLEKoLPXc)sklekcwSzmwgXIww0xZPPDaycx06SXSKrnllwgXYWal6qkLfTSmps7FTXc)skleIfBiplddSGr66SSqqdwyfTrxvHny6zazrllbiubcTNgSWkAJUQcBW0ZaAASWVKgdeePH(S(dMXa3QYUhLYYIISmoLyQ5yX(97SqSTs2XjdSaBw8NLFhzbtqwGtwitnMLmAmqaExtVaJbErkynatW7pyg)XBrdcoU0XaX01viy84Jb6H)GzmWlPHE9UUcRr6YZFvubraxaJbg67X(8yGa8(CDfAUifSgGj49hmzrlla8(CDfAUSskagdm9cmg4L0qVExxH1iD55VkQGiGlGXF8w0G8XLogiMUUcbJhFmqqKg6Z6pygdCCPila3DqODeKfn)wNfDCcBKfITvYoozigy6fymq6UdcTJGvyRxHZ6d7cm)yGH(ESppgyzwcqOceApnbVEzW0OdgLfTSyllbiam98n5rA)Rthzrlla8(CDfA(9(uQkfrIWUA3VNfTSuMLaeQaH2tJo2uSj6ssMgDWOSmmWITS0EanFdvkwgXYWalbiam98n5rA)RthzrllbiubcTNMambajcR)owPwxFp10OdgLfTSuMfaEFUUcnbycasewbrA0mWYWalbiubcTNMGxVmyA0bJYYiwgXIwwaHVHUY51O5VarxsIfTSuMfq4BOpQuExNkVrZFbIUKelddSyllVRW8n0hvkVRtL3ObtxxHGSmmWc1cvQ67nj8Pg6798AKLnzjYSmIfTSacFtbeMZRrZFbIUKelAzPmla8(CDfAoA1HilddS0ReNWMeA0DLNbScNvxPQ)(LKOgmDDfcYYWalo9BxvTG2XMLnJGLs0ySmmWcaVpxxHMambajcRGinAgyzyGf91CA0vqiOArFZYILrSOLfBzbJ01zzHGMlPHE9UUcRr6YZFvubraxazzyGfmsxNLfcAUKg6176kSgPlp)vrfebCbKfTSeGqfi0EAUKg6176kSgPlp)vrfebCb00yHFjLLnzjYJXIwwSLf91CAcE9YGzzXYWal6qkLfTSmps7FTXc)skleIfcESyGE4pygdKU7Gq7iyf26v4S(WUaZp(J3Ige34shdetxxHGXJpgiisd9z9hmJbw69JYYrzXzP9FhBwqLRdB)rwS7rz5HSu4eHS4kflWKLffzH((ZY3xse(uwEil6ilQlrqwwwSy)(Dwi2wj74Kbw8eKfIbtaqIqw8eKLffz53rwSjbzHQGplWKLail3KfD4VZY3xse(uw8gzbMSSOil03Fw((sIWNgdm03J95XalZcaVpxxHgywxuS(9LeHpl2gblAWIwwSLLVVKi8nVnMgDWO1aeQaH2twggyPmla8(CDfAGzDrX63xse(SeblAWYWala8(CDfAGzDrX63xse(SeblrMLrSOLLYSOVMttWRxgmllw0YszwSLLaeaME(gay(7rBwggyrFnNM2bGjCrRZgZsg10yHFjLfcWszwISH8Sukw6vItytcn0lNlvDpk9X(CdMUUcbzzelekcw((sIW38Ay0xZzfC1(FWKfTSOVMtt7aWeUO1zJzjJAwwSmmWI(AonTdat4IwNnMLmALE5CPQ7rPp2NBwwSmILHbwcqOceApnbVEzW0yHFjLfcWInSSjlFFjr4BEnmbiubcTNgWv7)btw0YITSOVMttWRxgmllw0YszwSLLaeaME(M8iT)1PJSmmWITSaW7Z1vOjataqIWkisJMbwgXIwwSLLaeaME(gII2NNSmmWsacatpFtEK2)60rw0YcaVpxxHMambajcRGinAgyrllbiubcTNMambajcR)owPwxFp1SSyrll2YsacvGq7Pj41ldMLflAzPmlLzrFnNgmOolkwvR0BtJf(Luw2KfngJLHbw0xZPbdQZIIvku5TPXc)sklBYIgJXYiw0YITS0ReNWMeA0DLNbScNvxPQ)(LKOgmDDfcYYWalLzrFnNgDx5zaRWz1vQ6VFjjAn9F1OH(EGiwIGfYZYWal6R50O7kpdyfoRUsv)9ljrREh8en03deXseSejSmILrSmmWI(AoneDjyJGvSWcAh7cm)kMyt6kjAwwSmILHbw0HuklAzzEK2)AJf(Luwiel2mglddSaW7Z1vObM1ffRFFjr4ZseSmglJyrlla8(CDfAUSskagdKQGpng43xse(Aed0d)bZyGFFjr4Rr8hVfniZXLogiMUUcbJhFmqp8hmJb(9LeHVnXad99yFEmWYSaW7Z1vObM1ffRFFjr4ZITrWInSOLfBz57ljcFZRHPrhmAnaHkqO9KLHbwa4956k0aZ6II1VVKi8zjcwSHfTSuMf91CAcE9YGzzXIwwkZITSeGaW0Z3aaZFpAZYWal6R500oamHlAD2ywYOMgl8lPSqawkZsKnKNLsXsVsCcBsOHE5CPQ7rPp2NBW01viilJyHqrWY3xse(M3gJ(AoRGR2)dMSOLf91CAAhaMWfToBmlzuZYILHbw0xZPPDaycx06SXSKrR0lNlvDpk9X(CZYILrSmmWsacvGq7Pj41ldMgl8lPSqawSHLnz57ljcFZBJjaHkqO90aUA)pyYIwwSLf91CAcE9YGzzXIwwkZITSeGaW0Z3KhP9VoDKLHbwSLfaEFUUcnbycasewbrA0mWYiw0YITSeGaW0Z3qu0(8KfTSuMfBzrFnNMGxVmywwSmmWITSeGaW0Z3aaZFpAZYiwggyjabGPNVjps7FD6ilAzbG3NRRqtaMaGeHvqKgndSOLLaeQaH2ttaMaGeH1FhRuRRVNAwwSOLfBzjaHkqO90e86LbZYIfTSuMLYSOVMtdguNffRQv6TPXc)sklBYIgJXYWal6R50Gb1zrXkfQ820yHFjLLnzrJXyzelAzXww6vItytcn6UYZawHZQRu1F)ssudMUUcbzzyGLYSOVMtJUR8mGv4S6kv93VKeTM(VA0qFpqelrWc5zzyGf91CA0DLNbScNvxPQ)(LKOvVdEIg67bIyjcwIewgXYiwgXYWal6R50q0LGncwXclODSlW8RyInPRKOzzXYWal6qkLfTSmps7FTXc)skleIfBgJLHbwa4956k0aZ6II1VVKi8zjcwgJLrSOLfaEFUUcnxwjfaJbsvWNgd87ljcFBI)4TOrKex6yGy66kemE8XabrAOpR)GzmWXLIuwCLIf4VJnlWKLffz5ESGYcmzjagd0d)bZyGlkwVhlOXF8w0Oefx6yGy66kemE8XabrAOpR)GzmqY5(DSzHeKLlFil)oYc9zb2S4qKfp8hmzrD0pgOh(dMXa7vw9WFWSQo6hdK(9f(4TOrmWqFp2NhdeG3NRRqZrRoeJbQo6xtVaJb6qm(J3InJfx6yGy66kemE8Xa9WFWmgyVYQh(dMv1r)yGQJ(10lWyG0p(J)yGwngGf6(hx64TOrCPJb6H)GzmqIUeSrWk1667PXaX01viy84J)4TytCPJbIPRRqW4XhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXahlgiisd9z9hmJbw6DKfaEFUUcz5OSqXNLhYYySy)(Dwsil03FwGjllkYY3xse(unXIgSyFhtw(DKL510NfyISCuwGjllkQjwSHLBYYVJSqXambz5OS4jilrMLBYIo83zXBmgiaVRPxGXaHzDrX63xse(XF8wICCPJbIPRRqW4XhdeAfd0bbJb6H)GzmqaEFUUcJbcWvlmgOgXad99yFEmWVVKi8nVgMDNwxuSQVMtw0YY3xse(MxdtacvGq7PbC1(FWKfTSyllFFjr4BEnmh18WcScN1cys)gUO1amPFVc)btAmqaExtVaJbcZ6II1VVKi8J)4TqWXLogiMUUcbJhFmqOvmqhemgOh(dMXab4956kmgiaxTWyG2edm03J95Xa)(sIW382y2DADrXQ(AozrllFFjr4BEBmbiubcTNgWv7)btw0YITS89LeHV5TXCuZdlWkCwlGj9B4IwdWK(9k8hmPXab4Dn9cmgimRlkw)(sIWp(J3c5JlDmqmDDfcgp(yGqRyGoiymqp8hmJbcW7Z1vymqaExtVaJbcZ6II1VVKi8Jbg67X(8yGyKUolle0Cjn0R31vynsxE(RIkic4cilddSGr66SSqqdwyfTrxvHny6zazzyGfmsxNLfcAOWLsH)FjPAV0JgdeePH(S(dMXal9osrw((sIWNYI3ilj8zXxpSW)l4kvuwaXhdpcYItzbMSSOil03Fw((sIWNAyHfG4ZcaVpxxHS8qwiywCkl)ogLfxrHSKicYc1cdNRyz3tq1LKmXab4QfgdKGJ)4TqCJlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgyKhJLsXszw0GfnJLXm2WsPyHIFvhMlQ5pSTjsQeSvGLrXabrAOpR)GzmqG4tz53rwa(EtxnjKLaK(SmHnlk)XMLGRclL)hmPSuEcBwqc7fwkKf77yYYdzH(E)SaUkSUKel64e2ilKPgZsgLLPRuuwGZ5OyGa8UMEbgdKsRbi9J)4TqMJlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgyKhJfcWIgJXsPyPxjoHnj0eqfs)ZvvQ113tny66kemgiisd9z9hmJbceFkl(ZI99lSZIxax5ZcCYYwPeewigmbajczHUdxkqw0rwwueSeyHGhJf73Vdxpledvi9pxXcqRRVNYINGSe5XyX(97MyGa8UMEbgdmataqIWQtTI)4TejXLogOh(dMXalGWKOlRtyxedetxxHGXJp(J3sjkU0XaX01viy84Jb6H)Gzmq7T)7Xad99yFEmWYSGb1zrrJALExtKWplddSGb1zrrZLvku5nlddSGb1zrrZLvD4VZYWalyqDwu04z0AIe(zzumq1LynagduJXI)4pgOdX4shVfnIlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgyVsCcBsO5Vc0oSZkyJEH(LGyBW01viilAzPml6R508xbAh2zfSrVq)sqSnnw4xszHqSqkaAkCcZcbyzmJgSmmWI(Aon)vG2HDwbB0l0VeeBtJf(LuwielE4pyAOV3ZRrdsymSES(xbYcbyzmJgSOLLYSGb1zrrZLv1k9MLHbwWG6SOOHcvExtKWplddSGb1zrrJNrRjs4NLrSmIfTSOVMtZFfODyNvWg9c9lbX2SSIbcI0qFw)bZyGeZvHLYFKYI9D83XMLFhzrZ1Oxe8pSJnl6R5Kf7NsXY0vkwGZjl2VF)sw(DKLej8ZsWPFmqaExtVaJbc2OxuTFkvD6kvfoNXF8wSjU0XaX01viy84JbcTIbsXpgOh(dMXab4956kmgiaxTWyG2YcguNffnxwPqL3SOLfQfQu13Bs4tn03751ilBYczMfnJL3vy(gkCPQWz93X6e2i9ny66keKLsXInSqawWG6SOO5YQo83zrll2YsVsCcBsOXQVcydEUQ6DWZluTwkQ3gmDDfcYIwwSLLEL4e2KqdmXFNwdk07kGJEW0GPRRqWyGGin0N1FWmgiXCvyP8hPSyFh)DSzb47nD1Kqwokl2H9VZsWP)LKybcaBwa(EpVgz5swiJv6nlKtqDwumgiaVRPxGXapsjSXk99MUAsy8hVLihx6yGy66kemE8Xa9WFWmgyaMaGeH1FhRuRRVNgdeePH(S(dMXahxkYcXGjairil23XKf)zrHukl)UNSq(XyzRucclEcYI6sKLLfl2VFNfITvYoozigyOVh7ZJbAllG96anjSgaPSOLLYSuMfaEFUUcnbycasewbrA0mWIwwSLLaeQaH2ttWRxgmn6GrzzyGf91CAcE9YGzzXYiw0Yszw0xZPbdQZIIv1k920yHFjLLnzH8SmmWI(AonyqDwuSsHkVnnw4xszztwiplJyrllLzXPF7QQf0o2Sqiwi)ySOLLYSqTqLQ(EtcFQH(EpVgzztwImlddSOVMttWRxgmllwgXYWal2YsVsCcBsOXQVcydEUQ6DWZluTwkQ3gmDDfcYYiw0YszwSLL3vy(g6JkL3vW(MVbtxxHGSmmWI(Aon037PRuMgl8lPSqiw0WqEw0mwgZqEwkfl9kXjSjHMaQq6FUQsTU(EQbtxxHGSmmWI(AonbVEzW0yHFjLfcXI(Aon037PRuMgl8lPSqawiplAzrFnNMGxVmywwSmIfTSuMfBzPxjoHnj0O7kpdyfoRUsv)9ljrny66keKLHbw0xZPr3vEgWkCwDLQ(7xsIwt)xnAOVhiILnzjYSmmWI(Aon6UYZawHZQRu1F)ss0Q3bprd99arSSjlrMLrSmmWIoKszrllZJ0(xBSWVKYcHyrJXyrllbiubcTNMGxVmyASWVKYYMSqEwgf)XBHGJlDmqmDDfcgp(yGE4pygdKUY51ymWq0GcRV3KWNgVfnIbg67X(8yGLzPXzJ0DxxHSmmWI(AonyqDwuSsHkVnnw4xszHqSezw0YcguNffnxwPqL3SOLLgl8lPSqiw0GGzrllVRW8nu4svHZ6VJ1jSr6BW01viilJyrllV3KW38xbwFyf8qw2Kfniyw0mwOwOsvFVjHpLfcWsJf(Luw0YszwWG6SOO5YQNrzzyGLgl8lPSqiwifanfoHzzumqqKg6Z6pygdCCPilax58AKLlzXYtqS4cSatw8m6VFjjw(D)zrDaqklAqWumqzXtqwuiLYI973zPa2ilV3KWNYINGS4pl)oYcMGSaNS4SaeQ8MfYjOolkYI)SObbZcfduwGnlkKszPXc)YljXItz5HSKWNLDhWLKy5HS04Sr6olGR(ssSqgR0BwiNG6SOy8hVfYhx6yGy66kemE8Xa9WFWmgiDLZRXyGGin0N1FWmg44srwaUY51ilpKLDhaYIZcjfu3vS8qwwuKLXPetnxmWqFp2NhdeG3NRRqZfPG1ambV)GjlAzjaHkqO90Cjn0R31vynsxE(RIkic4cOPrhmklAzbJ01zzHGMlPHE9UUcRr6YZFvubraxazrllUvnSJbII)4TqCJlDmqmDDfcgp(yGE4pygdK(EpDLkgiisd9z9hmJbwIdrlwwwSa89E6kfl(ZIRuS8xbszzLkKszzrVKelKr0G3oLfpbz5EwoklUoC9S8qwSAyGfyZIcFw(DKfQfgoxXIh(dMSOUezrhvq7SS7jOczrZ1OxOFji2SatwSHL3Bs4tJbg67X(8yG2YY7kmFd9rLY7kyFZ3GPRRqqw0YszwSLfk(vDyUOM)W2MiPsWwbwggybdQZIIMlREgLLHbwOwOsvFVjHp1qFVNUsXYMSezwgXIwwkZI(Aon037PRuMgNns3DDfYIwwkZc1cvQ67nj8Pg6790vkwielrMLHbwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwgXYWalVRW8nu4svHZ6VJ1jSr6BW01viilAzrFnNgmOolkwPqL3Mgl8lPSqiwImlAzbdQZIIMlRuOYBw0YI(Aon037PRuMgl8lPSqiwiZSOLfQfQu13Bs4tn037PRuSSzeSqWSmIfTSuMfBzPxjoHnj0OIg82P1PcX)ssvsQRWIIgmDDfcYYWal)vGSqCyHGjplBYI(Aon037PRuMgl8lPSqawSHLrSOLL3Bs4B(RaRpScEilBYc5J)4TqMJlDmqmDDfcgp(yGE4pygdK(EpDLkgiisd9z9hmJbsqD)olaFuP8MfnxFZNLffzbMSeazX(oMS04Sr6URRqw0xpl0)ukwS73ZYe2SqgrdE7uwSAyGfpbzbeMB)SSOil64e2iletZrnSa8pLILffzrhNWgzHyWeaKiKf6LbKLF3FwSFkflwnmWINWFhBwa(EpDLkgyOVh7ZJb(UcZ3qFuP8Uc238ny66keKfTSOVMtd99E6kLPXzJ0DxxHSOLLYSyllu8R6WCrn)HTnrsLGTcSmmWcguNffnxw9mklddSqTqLQ(EtcFQH(EpDLILnzHGzzelAzPml2YsVsCcBsOrfn4TtRtfI)LKQKuxHffny66keKLHbw(RazH4WcbtEw2KfcMLrSOLL3Bs4B(RaRpScEilBYsKJ)4TejXLogiMUUcbJhFmqp8hmJbsFVNUsfdeePH(S(dMXajOUFNfnxJEH(LGyZYIISa89E6kflpKfIq0ILLfl)oYI(AozrpklUIczzrVKelaFVNUsXcmzH8SqXambPSaBwuiLYsJf(LxskgyOVh7ZJb2ReNWMeA(RaTd7Sc2OxOFji2gmDDfcYIwwOwOsvFVjHp1qFVNUsXYMrWsKzrllLzXww0xZP5Vc0oSZkyJEH(LGyBwwSOLf91CAOV3txPmnoBKU76kKLHbwkZcaVpxxHgWg9IQ9tPQtxPQW5KfTSuMf91CAOV3txPmnw4xszHqSezwggyHAHkv99Me(ud99E6kflBYInSOLL3vy(g6JkL3vW(MVbtxxHGSOLf91CAOV3txPmnw4xszHqSqEwgXYiwgf)XBPefx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqN(TRQwq7yZYMSejJXsPyPmlAWIMXcf)QomxuZFyBtKuTXkWsPyzmJnSmILsXszw0GfnJf91CA(RaTd7Sc2OxOFji2g67bIyPuSmMrdwgXIMXszw0xZPH(EpDLY0yHFjLLsXsKzHSSqTqLQU70hzPuSyllVRW8n0hvkVRG9nFdMUUcbzzelAglLzjaHkqO90qFVNUszASWVKYsPyjYSqwwOwOsv3D6JSukwExH5BOpQuExb7B(gmDDfcYYiw0mwkZI(AonZvhTcNvuTs00yHFjLLsXc5zzelAzPml6R50qFVNUszwwSmmWsacvGq7PH(EpDLY0yHFjLLrXabrAOpR)GzmqI5QWs5pszX(o(7yZIZcW3B6QjHSSOil2pLILGVOilaFVNUsXYdzz6kflW5utS4jillkYcW3B6QjHS8qwicrlw0Cn6f6xcInl03deXYYYWsKmglhLLFhzPXiDDncYYwPeewEilbN(Sa89MUAsiba(EpDLkgiaVRPxGXaPV3txPQ2H5xNUsvHZz8hVfnglU0XaX01viy84Jb6H)Gzmq67nD1KWyGGin0N1FWmg44srwa(EtxnjKf73VZIMRrVq)sqSz5HSqeIwSSSy53rw0xZjl2VFhUEwuq6LKyb4790vkwww)vGS4jillkYcW3B6QjHSatwiycWY4HBT0SqFpqeLLv(NIfcML3Bs4tJbg67X(8yGa8(CDfAaB0lQ2pLQoDLQcNtw0YcaVpxxHg6790vQQDy(1PRuv4CYIwwSLfaEFUUcnhPe2yL(EtxnjKLHbwkZI(Aon6UYZawHZQRu1F)ss0A6)Qrd99arSSjlrMLHbw0xZPr3vEgWkCwDLQ(7xsIw9o4jAOVhiILnzjYSmIfTSqTqLQ(EtcFQH(EpDLIfcXcbZIwwa4956k0qFVNUsvTdZVoDLQcNZ4pElAOrCPJbIPRRqW4Xhd0d)bZyGoOB9haSsT7DrmWq0GcRV3KWNgVfnIbg67X(8yG2YYFbIUKelAzXww8WFW04GU1FaWk1U3fvqVWjHMlRt1rA)zzyGfq4BCq36payLA37IkOx4Kqd99arSqiwImlAzbe(gh0T(dawP29UOc6foj00yHFjLfcXsKJbcI0qFw)bZyGJlfzHA37cwOqw(D)zjkCXcj8zPWjmllR)kqw0JYYIEjjwUNfNYIYFKfNYIfKspDfYcmzrHukl)UNSezwOVhiIYcSzPeJf9zX(oMSezcWc99aruwqcBDng)XBrdBIlDmqmDDfcgp(yGE4pygdSacZ51ymWq0GcRV3KWNgVfnIbg67X(8yGnoBKU76kKfTS8EtcFZFfy9HvWdzztwkZszw0GGzHaSuMfQfQu13Bs4tn03751ilLIfByPuSOVMtdguNffRQv6TzzXYiwgXcbyPXc)sklJyHSSuMfnyHaS8UcZ382VSwaHj1GPRRqqwgXIwwkZIBvd7yGiwggybG3NRRqZrkHnwPV30vtczzyGfBzbdQZIIMlREgLLrSOLLYSeGqfi0EAcE9YGPrhmklAzbdQZIIMlREgLfTSyllG96anjSgaPSOLLYSaW7Z1vOjataqIWkisJMbwggyjaHkqO90eGjairy93Xk1667PMgDWOSmmWITSeGaW0Z3KhP9VoDKLrSmmWc1cvQ67nj8Pg6798AKfcXszwkZcXLfnJLYSOVMtdguNffRQv6TzzXsPyXgwgXYiwkflLzrdwialVRW8nV9lRfqysny66keKLrSmIfTSyllyqDwu0qHkVRjs4NfTSyllbiubcTNMGxVmyA0bJYYWalLzbdQZIIMlRuOYBwggyrFnNgmOolkwvR0BZYIfTSyllVRW8nu4svHZ6VJ1jSr6BW01viilddSOVMtJvFfWg8Cv17GNxOATuuVnaC1czzZiyXgYpglJyrllLzHAHkv99Me(ud99EEnYcHyrJXyPuSuMfnyHaS8UcZ382VSwaHj1GPRRqqwgXYiw0YIt)2vvlODSzztwi)ySOzSOVMtd99E6kLPXc)sklLIfIllJyrllLzXwwcqay65BikAFEYYWal2YI(AoneDjyJGvSWcAh7cm)kMyt6kjAwwSmmWcguNffnxwPqL3SmIfTSyll6R500oamHlAD2ywYOv6LZLQUhL(yFUzzfdeePH(S(dMXajOHZgP7SO5bH58AKLBYcX2kzhNmWYrzPrhmQMy53XgzXBKffsPS87EYc5z59Me(uwUKfYyLEZc5euNffzX(97Sae(KjnXIcPuw(DpzrJXyb(7yB)OilxYINrzHCcQZIISaBwwwS8qwiplV3KWNYIooHnYIZczSsVzHCcQZIIgw0CWC7NLgNns3zbC1xsILsCxc2iilKtHf0o2fy(SSsfsPSCjlaHkVzHCcQZIIXF8w0iYXLogiMUUcbJhFmqp8hmJboHDaRWzn9F1ymqqKg6Z6pygdCCPilKj4wybMSeazX(97W1ZsWTSUKumWqFp2Nhd0TQHDmqelddSaW7Z1vO5iLWgR03B6QjHXF8w0GGJlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgOTSa2Rd0KWAaKYIwwkZcaVpxxHMaynatW7pyYIwwkZI(Aon037PRuMLflddS8UcZ3qFuP8Uc238ny66keKLHbwcqay65BYJ0(xNoYYiw0Yci8nfqyoVgn)fi6ssSOLLYSyll6R50qHk6Fb0SSyrll2YI(AonbVEzWSSyrllLzXwwExH5BMRoAfoROALObtxxHGSmmWI(AonbVEzWaUA)pyYYMSeGqfi0EAMRoAfoROALOPXc)skleGLiHLrSOLLYSyllu8R6WCrn)HTnrs1gRalddSGb1zrrZLv1k9MLHbwWG6SOOHcvExtKWplJyrlla8(CDfA(9(uQkfrIWUA3VNfTSuMfBzjabGPNVjps7FD6ilddSeGqfi0EAcWeaKiS(7yLAD99utJf(Luwiel6R50e86Lbd4Q9)GjlLILXmKNLrSOLL3Bs4B(RaRpScEilBYI(AonbVEzWaUA)pyYsPyzmdzMLrSmmWIoKszrllZJ0(xBSWVKYcHyrFnNMGxVmyaxT)hmzHaSOHnSukw6vItytcnw9vaBWZvvVdEEHQ1sr92GPRRqqwgfdeG310lWyGbWAaMG3FWS6qm(J3IgKpU0XaX01viy84Jb6H)GzmW2bGjCrRZgZsgngiisd9z9hmJboUuKfYuJzjJYI973zHyBLSJtgIbg67X(8yG6R50e86LbtJf(Luw2KfniplddSOVMttWRxgmGR2)dMSqaw0Wgwkfl9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viileIfBiUSOLfaEFUUcnbWAaMG3FWS6qm(J3Ige34shdetxxHGXJpgOh(dMXadOcP)5QQRoszbMFmqqKg6Z6pygdCCPileBRKDCYalWKLailRuHuklEcYI6sKL7zzzXI973zHyWeaKimgyOVh7ZJbcW7Z1vOjawdWe8(dMvhISOLLYSOVMttWRxgmGR2)dMSqaw0Wgwkfl9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viilBgbl2qCzzyGfBzjabGPNVbaM)E0MLrSmmWI(AonTdat4IwNnMLmQzzXIww0xZPPDaycx06SXSKrnnw4xszHqSuIyHaSeGj46EJvJHJIvxDKYcmFZFfyfGRwileGLYSyll6R50ORGqq1I(MLflAzXwwExH5BOV3kydAW01viilJI)4TObzoU0XaX01viy84Jbg67X(8yGa8(CDfAcG1ambV)Gz1Hymqp8hmJbEzW70)dMXF8w0isIlDmqmDDfcgp(yGE4pygdelSG2XUQdtWyGGin0N1FWmg44srwiNclODSzz8WeKfyYsaKf73VZcW37PRuSSSyXtqwOoaKLjSzHGSuuVzXtqwi2wj74KHyGH(ESppgyzwcqOceApnbVEzW0yHFjLfcWI(AonbVEzWaUA)pyYcbyPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzPuSOHnSSjlbiubcTNgSWcAh7QombnGR2)dMSqaw0ymwgXYWal6R50e86LbtJf(Luw2KLiHLHbwa71bAsynasJ)4TOrjkU0XaX01viy84Jb6H)Gzmq6JkL31PYBmgyiAqH13Bs4tJ3IgXad99yFEmWgNns3DDfYIww(RaRpScEilBYIgKNfTSqTqLQ(EtcFQH(EpVgzHqSqWSOLf3Qg2XarSOLLYSOVMttWRxgmnw4xszztw0ymwggyXww0xZPj41ldMLflJIbcI0qFw)bZyGe0WzJ0DwMkVrwGjlllwEilrML3Bs4tzX(97W1ZcX2kzhNmWIoEjjwCD46z5HSGe26AKfpbzjHplqayhClRljf)XBXMXIlDmqmDDfcgp(yGE4pygdCU6Ov4SIQvIXabrAOpR)GzmWXLISqMGKdl3KLlPhiYINSqob1zrrw8eKf1Lil3ZYYIf73VZIZcbzPOEZIvddS4jilBf0T(daYcq7Exedm03J95XaXG6SOO5YQNrzrllLzXTQHDmqelddSyll9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viilJyrllLzrFnNgR(kGn45QQ3bpVq1APOEBa4QfYcHyXgYpglddSOVMttWRxgmnw4xszztwIewgXIwwkZci8noOB9haSsT7Drf0lCsO5VarxsILHbwSLLaeaME(MednubBqwggyHAHkv99Me(uw2KfByzelAzPml6R500oamHlAD2ywYOMgl8lPSqiwkrSOzSuMfcMLsXsVsCcBsOHE5CPQ7rPp2NBW01viilJyrll6R500oamHlAD2ywYOMLflddSyll6R500oamHlAD2ywYOMLflJyrllLzXwwcqOceApnbVEzWSSyzyGf91CA(9(uQkfrIW2qFpqeleIfniplAzzEK2)AJf(Luwiel2m2ySOLL5rA)Rnw4xszztw0ySXyzyGfBzHcxk9lbn)EFkvLIiryBW01viilJyrllLzHcxk9lbn)EFkvLIiryBW01viilddSeGqfi0EAcE9YGPXc)sklBYsKhJLrSOLL3Bs4B(RaRpScEilBYc5zzyGfDiLYIwwMhP9V2yHFjLfcXIgJf)XBXgnIlDmqmDDfcgp(yGE4pygdK(EpDLkgiisd9z9hmJboUuKfNfGV3txPyrZpXFNfRggyzLkKszb4790vkwoklUQrhmklllwGnlrHlw8gzX1HRNLhYcea2b3ILTsjiXad99yFEmq91CAGj(70Qf2b06pyAwwSOLLYSOVMtd99E6kLPXzJ0DxxHSmmWIt)2vvlODSzztwkrJXYO4pEl2ytCPJbIPRRqW4Xhd0d)bZyG037PRuXabrAOpR)Gzmqn3QWILTsjiSOJtyJSqmycaseYI973zb4790vkw8eKLFhtwa(EtxnjmgyOVh7ZJbgGaW0Z3KhP9VoDKfTSyllVRW8n0hvkVRG9nFdMUUcbzrllLzbG3NRRqtaMaGeHvqKgndSmmWsacvGq7Pj41ldMLflddSOVMttWRxgmllwgXIwwcqOceApnbycasew)DSsTU(EQPXc)skleIfsbqtHtywkflb8uSuMfN(TRQwq7yZczzH8JXYiw0YI(Aon037PRuMgl8lPSqiwiyw0YITSa2Rd0KWAaKg)XBXMihx6yGy66kemE8Xad99yFEmWaeaME(M8iT)1PJSOLLYSaW7Z1vOjataqIWkisJMbwggyjaHkqO90e86LbZYILHbw0xZPj41ldMLflJyrllbiubcTNMambajcR)owPwxFp10yHFjLfcXc5zrlla8(CDfAOV3txPQ2H5xNUsvHZjlAzbdQZIIMlREgLfTSylla8(CDfAosjSXk99MUAsilAzXwwa71bAsynasJb6H)Gzmq67nD1KW4pEl2qWXLogiMUUcbJhFmqp8hmJbsFVPRMegdeePH(S(dMXahxkYcW3B6QjHSy)(Dw8Kfn)e)DwSAyGfyZYnzjkCTnilqayhClw2kLGWI973zjkC1SKiHFwco9nSSvffYc4QWILTsjiS4pl)oYcMGSaNS87ilLyX83J2SOVMtwUjlaFVNUsXID4sbMB)SmDLIf4CYcSzjkCXI3ilWKfBy59Me(0yGH(ESppgO(AonWe)DAnOqVRao6btZYILHbwkZITSqFVNxJg3Qg2XarSOLfBzbG3NRRqZrkHnwPV30vtczzyGLYSOVMttWRxgmnw4xszHqSqEw0YI(AonbVEzWSSyzyGLYSuMf91CAcE9YGPXc)skleIfsbqtHtywkflb8uSuMfN(TRQwq7yZczzbG3NRRqdLwdq6ZYiw0YI(AonbVEzWSSyzyGf91CAAhaMWfToBmlz0k9Y5sv3JsFSp30yHFjLfcXcPaOPWjmlLILaEkwkZIt)2vvlODSzHSSaW7Z1vOHsRbi9zzelAzrFnNM2bGjCrRZgZsgTsVCUu19O0h7ZnllwgXIwwcqay65BaG5VhTzzelJyrllLzHAHkv99Me(ud99E6kfleILiZYWala8(CDfAOV3txPQ2H5xNUsvHZjlJyzelAzXwwa4956k0CKsyJv67nD1Kqw0YszwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggyHAHkv99Me(ud99E6kfleILiZYO4pEl2q(4shdetxxHGXJpgOh(dMXat0ETacZyGGin0N1FWmg44srw08GWKYYLSaeQ8MfYjOolkYINGSqDailKPLsXIMheMSmHnleBRKDCYqmWqFp2NhdSml6R50Gb1zrXkfQ820yHFjLLnzbjmgwpw)RazzyGLYSe29MeszjcwSHfTS0yy3Bsy9VcKfcXc5zzelddSe29MeszjcwImlJyrllUvnSJbII)4TydXnU0XaX01viy84Jbg67X(8yGLzrFnNgmOolkwPqL3Mgl8lPSSjliHXW6X6FfilddSuMLWU3KqklrWInSOLLgd7EtcR)vGSqiwiplJyzyGLWU3KqklrWsKzzelAzXTQHDmqelAzPml6R500oamHlAD2ywYOMgl8lPSqiwiplAzrFnNM2bGjCrRZgZsg1SSyrll2YsVsCcBsOHE5CPQ7rPp2NBW01viilddSyll6R500oamHlAD2ywYOMLflJIb6H)GzmWDxnRfqyg)XBXgYCCPJbIPRRqW4Xhdm03J95XalZI(AonyqDwuSsHkVnnw4xszztwqcJH1J1)kqw0YszwcqOceApnbVEzW0yHFjLLnzH8JXYWalbiubcTNMambajcR)owPwxFp10yHFjLLnzH8JXYiwggyPmlHDVjHuwIGfByrllng29Mew)RazHqSqEwgXYWalHDVjHuwIGLiZYiw0YIBvd7yGiw0Yszw0xZPPDaycx06SXSKrnnw4xszHqSqEw0YI(AonTdat4IwNnMLmQzzXIwwSLLEL4e2Kqd9Y5sv3JsFSp3GPRRqqwggyXww0xZPPDaycx06SXSKrnllwgfd0d)bZyGZLsvlGWm(J3InrsCPJbIPRRqW4XhdeePH(S(dMXahxkYcbfKCybMSqmnxmqp8hmJbA37(GDfoROALy8hVfBkrXLogiMUUcbJhFmqOvmqk(Xa9WFWmgiaVpxxHXab4QfgdKAHkv99Me(ud99EEnYYMSqWSqawMkiSzPmlfo9XoAfGRwilLIfngBmwill2mglJyHaSmvqyZszw0xZPH(EtxnjSIfwq7yxG5xPqL3g67bIyHSSqWSmkgiisd9z9hmJbsmxfwk)rkl23XFhBwEillkYcW3751ilxYcqOYBwSVFHDwokl(Zc5z59Me(ucObltyZcca7OSyZyehwkC6JDuwGnlemlaFVPRMeYc5uybTJDbMpl03derJbcW7A6fymq6798ASEzLcvEh)XBjYJfx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqnyHSSqTqLQU70hzHqSydlAglLzzmJnSukwkZc1cvQ67nj8Pg6798AKfnJfnyzelLILYSObleGL3vy(gkCPQWz93X6e2i9ny66keKLsXIggYZYiwgXcbyzmJgKNLsXI(AonTdat4IwNnMLmQPXc)sAmqqKg6Z6pygdKyUkSu(JuwSVJ)o2S8qwiOA)3zbC1xsIfYuJzjJgdeG310lWyG2B)3RxwNnMLmA8hVLiRrCPJbIPRRqW4Xhd0d)bZyG2B)3JbcI0qFw)bZyGJlfzHGQ9FNLlzbiu5nlKtqDwuKfyZYnzjHSa89EEnYI9tPyzEplx(qwi2wj74Kbw8mAbSXyGH(ESppgyzwWG6SOOrTsVRjs4NLHbwWG6SOOXZO1ej8ZIwwa4956k0C0AqHoaKLrSOLLYS8EtcFZFfy9HvWdzztwiywggybdQZIIg1k9UEz1gwggyrhsPSOLL5rA)Rnw4xszHqSOXySmILHbw0xZPbdQZIIvku5TPXc)skleIfp8hmn03751Objmgwpw)Razrll6R50Gb1zrXkfQ82SSyzyGfmOolkAUSsHkVzrll2YcaVpxxHg6798ASEzLcvEZYWal6R50e86LbtJf(LuwielE4pyAOV3ZRrdsymSES(xbYIwwSLfaEFUUcnhTguOdazrll6R50e86LbtJf(LuwieliHXW6X6FfilAzrFnNMGxVmywwSmmWI(AonTdat4IwNnMLmQzzXIwwa4956k0yV9FVEzD2ywYOSmmWITSaW7Z1vO5O1GcDailAzrFnNMGxVmyASWVKYYMSGegdRhR)vGXF8wISnXLogiMUUcbJhFmqqKg6Z6pygdCCPilaFVNxJSCtwUKfYyLEZc5euNff1elxYcqOYBwiNG6SOilWKfcMaS8EtcFklWMLhYIvddSaeQ8MfYjOolkgd0d)bZyG03751y8hVLih54shdetxxHGXJpgiisd9z9hmJbsMCL637vmqp8hmJb2RS6H)GzvD0pgO6OFn9cmg40vQFVxXF8hdC6k1V3R4shVfnIlDmqmDDfcgp(yGE4pygdK(Etxnjmgiisd9z9hmJbc89MUAsiltyZsbeawG5ZYkviLYYIEjjwgpCRLogyOVh7ZJbAll9kXjSjHgDx5zaRWz1vQ6VFjjQbJ01zzHGXF8wSjU0XaX01viy84Jb6H)Gzmq6kNxJXadrdkS(EtcFA8w0igyOVh7ZJbccFtbeMZRrtJf(Luw2KLgl8lPSukwSXgwillAejXabrAOpR)GzmqI50NLFhzbe(Sy)(Dw(DKLci9z5VcKLhYIdcYYk)tXYVJSu4eMfWv7)btwokl73Byb4kNxJS0yHFjLLIL6pl1HGS8qwk8pSZsbeMZRrwaxT)hmJ)4Te54shd0d)bZyGfqyoVgJbIPRRqW4Xh)XFmq6hx64TOrCPJbIPRRqW4Xhd0d)bZyGoOB9haSsT7DrmWq0GcRV3KWNgVfnIbg67X(8yG2Yci8noOB9haSsT7Drf0lCsO5VarxsIfTSyllE4pyACq36payLA37IkOx4KqZL1P6iT)SOLLYSyllGW34GU1FaWk1U3f1D0vM)ceDjjwggybe(gh0T(dawP29UOUJUY0yHFjLLnzH8SmILHbwaHVXbDR)aGvQDVlQGEHtcn03deXcHyjYSOLfq4BCq36payLA37IkOx4KqtJf(LuwielrMfTSacFJd6w)baRu7Exub9cNeA(lq0LKIbcI0qFw)bZyGJlfzzRGU1FaqwaA37cwSVJjl)o2ilhLLeYIh(daYc1U3fAIfNYIYFKfNYIfKspDfYcmzHA37cwSF)ol2WcSzzI2XMf67bIOSaBwGjlolrMaSqT7Dbluil)U)S87iljANfQDVlyX7(aGuwkXyrFw85Jnl)U)SqT7DbliHTUgPXF8wSjU0XaX01viy84Jb6H)GzmWambajcR)owPwxFpngiisd9z9hmJboUuKYcXGjairil3KfITvYoozGLJYYYIfyZsu4IfVrwarA0mCjjwi2wj74KbwSF)oledMaGeHS4jilrHlw8gzrhvq7SqWJr2ipwzIHkK(NRybO113thXYwPeewUKfNfngJaSqXalKtqDwu0WYwvuilGWC7Nff(SO5A0l0VeeBwqcBDnQjwCLDpkLLffz5swi2wj74KbwSF)oleKLI6nlEcYI)S87il037Nf4KfNLXd3APzX(LGq7MyGH(ESppgOTSa2Rd0KWAaKYIwwkZszwa4956k0eGjairyfePrZalAzXwwcqOceApnbVEzW0OdgLfTSyll9kXjSjHgR(kGn45QQ3bpVq1APOEBW01viilddSOVMttWRxgmllwgXIwwkZszwC63UQAbTJnlekcwa4956k0eGjairy1PwSOLLYSOVMtdguNffRQv6TPXc)sklBYIgJXYWal6R50Gb1zrXkfQ820yHFjLLnzrJXyzelddSOVMttWRxgmnw4xszztwiplAzrFnNMGxVmyASWVKYcHIGfnSHLrSOLLYSyll9kXjSjHM)kq7WoRGn6f6xcITbtxxHGSmmWITS0ReNWMeAcOcP)5Qk1667PgmDDfcYYWal6R508xbAh2zfSrVq)sqSnnw4xszztwqcJH1J1)kqwgXYWal9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSmIfTSuMfBzPxjoHnj0O7kpdyfoRUsv)9ljrny66keKLHbwkZI(Aon6UYZawHZQRu1F)ss0A6)Qrd99arSeblrclddSOVMtJUR8mGv4S6kv93VKeT6DWt0qFpqelrWsKWYiwgXYWal6qkLfTSmps7FTXc)skleIfngJfTSyllbiubcTNMGxVmyA0bJYYO4pElroU0XaX01viy84Jb6H)Gzmq67nD1KWyGGin0N1FWmg44srwa(EtxnjKLhYcriAXYYILFhzrZ1OxOFji2SOVMtwUjl3ZID4sbYcsyRRrw0XjSrwMxE09ljXYVJSKiHFwco9zb2S8qwaxfwSOJtyJSqmycasegdm03J95Xa7vItytcn)vG2HDwbB0l0VeeBdMUUcbzrllLzXwwkZszw0xZP5Vc0oSZkyJEH(LGyBASWVKYYMS4H)GPXE7)Ubjmgwpw)RazHaSmMrdw0YszwWG6SOO5YQo83zzyGfmOolkAUSsHkVzzyGfmOolkAuR07AIe(zzelddSOVMtZFfODyNvWg9c9lbX20yHFjLLnzXd)btd99EEnAqcJH1J1)kqwialJz0GfTSuMfmOolkAUSQwP3SmmWcguNffnuOY7AIe(zzyGfmOolkA8mAnrc)SmILrSmmWITSOVMtZFfODyNvWg9c9lbX2SSyzelddSuMf91CAcE9YGzzXYWala8(CDfAcWeaKiScI0OzGLrSOLLaeQaH2ttaMaGeH1FhRuRRVNAA0bJYIwwcqay65BYJ0(xNoYIwwkZI(AonyqDwuSQwP3Mgl8lPSSjlAmglddSOVMtdguNffRuOYBtJf(Luw2KfngJLrSmIfTSuMfBzjabGPNVHOO95jlddSeGqfi0EAWclODSR6We00yHFjLLnzjsyzu8hVfcoU0XaX01viy84Jb6H)Gzmq67nD1KWyGGin0N1FWmgOMBvyXcW3B6QjHuwSF)olJ3vEgqwGtw2QsXsP3VKeLfyZYdzXQrlVrwMWMfIbtaqIqwSF)olJhU1shdm03J95Xa7vItytcn6UYZawHZQRu1F)ssudMUUcbzrllLzPml6R50O7kpdyfoRUsv)9ljrRP)Rgn03deXYMSydlddSOVMtJUR8mGv4S6kv93VKeT6DWt0qFpqelBYInSmIfTSeGqfi0EAcE9YGPXc)sklBYczMfTSyllbiubcTNMambajcR)owPwxFp1SSyzyGLYSeGaW0Z3KhP9VoDKfTSeGqfi0EAcWeaKiS(7yLAD99utJf(LuwielAmglAzbdQZIIMlREgLfTS40VDv1cAhBw2KfBgJfcWsKhJLsXsacvGq7Pj41ldMgDWOSmILrXF8wiFCPJbIPRRqW4XhdeAfdKIFmqp8hmJbcW7Z1vymqaUAHXalZI(AonTdat4IwNnMLmQPXc)sklBYc5zzyGfBzrFnNM2bGjCrRZgZsg1SSyzelAzXww0xZPPDaycx06SXSKrR0lNlvDpk9X(CZYIfTSuMf91CAi6sWgbRyHf0o2fy(vmXM0vs00yHFjLfcXcPaOPWjmlJyrllLzrFnNgmOolkwPqL3Mgl8lPSSjlKcGMcNWSmmWI(AonyqDwuSQwP3Mgl8lPSSjlKcGMcNWSmmWszwSLf91CAWG6SOyvTsVnllwggyXww0xZPbdQZIIvku5TzzXYiw0YITS8UcZ3qHk6Fb0GPRRqqwgfdeePH(S(dMXajgmbV)GjltyZIRuSacFkl)U)Su4eHuwORgz53XOS4nMB)S04Sr6ocYI9DmzHGMdat4IYczQXSKrzz3PSOqkLLF3twiplumqzPXc)YljXcSz53rwiNclODSzz8WeKf91CYYrzX1HRNLhYY0vkwGZjlWMfpJYc5euNffz5OS46W1ZYdzbjS11ymqaExtVaJbcc)AJr66ASaZNg)XBH4gx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymWYSyll6R50Gb1zrXkfQ82SSyrll2YI(AonyqDwuSQwP3MLflJyrll2YY7kmFdfQO)fqdMUUcbzrll2YsVsCcBsO5Vc0oSZkyJEH(LGyBW01viymqqKg6Z6pygdKyWe8(dMS87(Zsyhderz5MSefUyXBKf46PhiYcguNffz5HSatvuwaHpl)o2ilWMLJucBKLF)OSy)(Dwacv0)cymqaExtVaJbcc)kC90deRyqDwum(J3czoU0XaX01viy84Jb6H)GzmWcimNxJXadrdkS(EtcFA8w0igyOVh7ZJbwMf91CAWG6SOyLcvEBASWVKYYMS0yHFjLLHbw0xZPbdQZIIv1k920yHFjLLnzPXc)sklddSaW7Z1vObe(v46PhiwXG6SOilJyrllnoBKU76kKfTS8EtcFZFfy9HvWdzztw0Wgw0YIBvd7yGiw0YcaVpxxHgq4xBmsxxJfy(0yGGin0N1FWmgOMd(S4kflV3KWNYI973VKfcINGyXfyX(97W1Zcea2b3Y6sse43rwCDiaKLambV)Gjn(J3sKex6yGy66kemE8Xa9WFWmgiDLZRXyGH(ESppgyzw0xZPbdQZIIvku5TPXc)sklBYsJf(LuwggyrFnNgmOolkwvR0BtJf(Luw2KLgl8lPSmmWcaVpxxHgq4xHRNEGyfdQZIISmIfTS04Sr6URRqw0YY7nj8n)vG1hwbpKLnzrdByrllUvnSJbIyrlla8(CDfAaHFTXiDDnwG5tJbgIguy99Me(04TOr8hVLsuCPJbIPRRqW4Xhd0d)bZyG0hvkVRtL3ymWqFp2NhdSml6R50Gb1zrXkfQ820yHFjLLnzPXc)sklddSOVMtdguNffRQv6TPXc)sklBYsJf(LuwggybG3NRRqdi8RW1tpqSIb1zrrwgXIwwAC2iD31vilAz59Me(M)kW6dRGhYYMSObXLfTS4w1WogiIfTSaW7Z1vObe(1gJ011ybMpngyiAqH13Bs4tJ3IgXF8w0yS4shdetxxHGXJpgi0kgif)yGE4pygdeG3NRRWyGaC1cJbgGaW0Z3aaZFpAZIwwSLLEL4e2Kqd9Y5sv3JsFSp3GPRRqqw0YITS0ReNWMeAcxhuyfoRQBIvpbRGO)7gmDDfcYIwwcqOceApn6ytXMOljzA0bJYIwwcqOceApnTdat4IwNnMLmQPrhmklAzXww0xZPj41ldMLflAzPmlo9BxvTG2XMLnzjsiZSmmWI(Aon6kieuTOVzzXYOyGGin0N1FWmgOMd(S0hP9NfDCcBKfYuJzjJYYnz5EwSdxkqwCLcANLOWflpKLgNns3zrHuklGR(ssSqMAmlzuwk)7hLfyQIYYUBzHjLf73VdxplaVCUuSqqFu6J95JIbcW7A6fymWew3JsFSpVIERIwbHF8hVfn0iU0XaX01viy84Jbg67X(8yGa8(CDfAsyDpk9X(8k6TkAfe(SOLLgl8lPSqiwSzSyGE4pygdSacZ51y8hVfnSjU0XaX01viy84Jbg67X(8yGa8(CDfAsyDpk9X(8k6TkAfe(SOLLgl8lPSqiw0Oefd0d)bZyG0voVgJ)4TOrKJlDmqmDDfcgp(yGE4pygdCc7awHZA6)QXyGGin0N1FWmg44srwitWTWcmzjaYI973HRNLGBzDjPyGH(ESppgOBvd7yGO4pElAqWXLogiMUUcbJhFmqp8hmJbIfwq7yx1HjymqqKg6Z6pygdCCPilKtHf0o2SmEycYI973zXZOSOGjjwWeUiTZIYP)LKyHCcQZIIS4jilFhLLhYI6sKL7zzzXI973zHGSuuVzXtqwi2wj74KHyGH(ESppgyzwcqOceApnbVEzW0yHFjLfcWI(AonbVEzWaUA)pyYcbyPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzPuSOHnSSjlbiubcTNgSWcAh7QombnGR2)dMSqaw0ymwgXYWal6R50e86LbtJf(Luw2KLiHLHbwa71bAsynasJ)4TOb5JlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgOt)2vvlODSzztwkrJXIMXszwSXqEwkfl6R50mxD0kCwr1krd99arSOzSydlLIfmOolkAUSQwP3Smkgiisd9z9hmJbceFkl23XKLTsjiSq3Hlfil6ilGRcleKLhYscFwGaWo4wSuwZHwycszbMSqMwDuwGtwih1krw8eKLFhzHCcQZIIJIbcW7A6fymqNAvbxfwXF8w0G4gx6yGy66kemE8XaHwXaP4hd0d)bZyGa8(CDfgdeGRwymqBzbSxhOjH1aiLfTSuMfaEFUUcnbWAaMG3FWKfTSyll6R50e86LbZYIfTSuMfBzHIFvhMlQ5pSTjsQ2yfyzyGfmOolkAUSQwP3SmmWcguNffnuOY7AIe(zzelAzPmlLzPmla8(CDfACQvfCvyXYWalbiam98n5rA)RthzzyGLYSeGaW0Z3qu0(8KfTSeGqfi0EAWclODSR6We00OdgLLrSmmWsVsCcBsO5Vc0oSZkyJEH(LGyBW01viilJyrllGW3qx58A00yHFjLLnzjsyrllGW3uaH58A00yHFjLLnzPeXIwwkZci8n0hvkVRtL3OPXc)sklBYIgJXYWal2YY7kmFd9rLY76u5nAW01viilJyrlla8(CDfA(9(uQkfrIWUA3VNfTS8EtcFZFfy9HvWdzztw0xZPj41ldgWv7)btwkflJziZSmmWI(Aon6kieuTOVzzXIww0xZPrxbHGQf9nnw4xszHqSOVMttWRxgmGR2)dMSqawkZIg2WsPyPxjoHnj0y1xbSbpxv9o45fQwlf1BdMUUcbzzelJyzyGLYSGr66SSqqdwyfTrxvHny6zazrllbiubcTNgSWkAJUQcBW0ZaAASWVKYcHyrdIlzMfcWszwiplLILEL4e2Kqd9Y5sv3JsFSp3GPRRqqwgXYiwgXIwwkZITSeGaW0Z3KhP9VoDKLHbwkZsacvGq7PjataqIW6VJvQ113tnnw4xszHqSOVMttWRxgmGR2)dMSqwwSHfTSyll9kXjSjHgDx5zaRWz1vQ6VFjjQbtxxHGSmmWsacvGq7PjataqIW6VJvQ113tnn6Grzrllo9BxvTG2XMfcXc5hJLrSmmWIoKszrllZJ0(xBSWVKYcHyjaHkqO90eGjairy93Xk1667PMgl8lPSmILHbw0HuklAzzEK2)AJf(Luwiel6R50e86Lbd4Q9)GjleGfnSHLsXsVsCcBsOXQVcydEUQ6DWZluTwkQ3gmDDfcYYOyGGin0N1FWmg44srwi2wj74KbwSF)oledMaGeHKTe3LGncYcqRRVNYINGSacZTFwGaW2EFpYcbzPOEZcSzX(oMSmEfecQw0Nf7WLcKfKWwxJSOJtyJSqSTs2XjdSGe26AKAyrZZjczHUAKLhYcMp2S4SqgR0BwiNG6SOil23XKLf9iLSuABIewSXkWINGS4kfletZrzX(PuSOJbybYsJoyuwOqyYcMWfPDwax9LKy53rw0xZjlEcYci8PSS7aqw0rmzHUMZlCy(QOS04Sr6ocAIbcW7A6fymWaynatW7pywPF8hVfniZXLogiMUUcbJhFmqp8hmJb2oamHlAD2ywYOXabrAOpR)GzmWXLISqMAmlzuwSF)oleBRKDCYalRuHuklKPgZsgLf7WLcKfLtFwuWKe2S87EYcX2kzhNmOjw(Dmzzrrw0XjSXyGH(ESppgO(AonbVEzW0yHFjLLnzrdYZYWal6R50e86Lbd4Q9)GjleIfBiZSqaw6vItytcnw9vaBWZvvVdEEHQ1sr92GPRRqqwkflAydlAzbG3NRRqtaSgGj49hmR0p(J3IgrsCPJbIPRRqW4Xhdm03J95Xab4956k0eaRbycE)bZk9zrllLzrFnNMGxVmyaxT)hmzzZiyXgYmleGLEL4e2KqJvFfWg8Cv17GNxOATuuVny66keKLsXIg2WYWal2YsacatpFdam)9OnlJyzyGf91CAAhaMWfToBmlzuZYIfTSOVMtt7aWeUO1zJzjJAASWVKYcHyPeXcbyjatW19gRgdhfRU6iLfy(M)kWkaxTqwialLzXww0xZPrxbHGQf9nllw0YITS8UcZ3qFVvWg0GPRRqqwgfd0d)bZyGbuH0)Cv1vhPSaZp(J3IgLO4shdetxxHGXJpgyOVh7ZJbcW7Z1vOjawdWe8(dMv6hd0d)bZyGxg8o9)Gz8hVfBglU0XaX01viy84JbcTIbsXpgOh(dMXab4956kmgiaxTWyGbiubcTNMGxVmyASWVKYYMSOXySmmWITSaW7Z1vOjataqIWkisJMbw0YsacatpFtEK2)60rwggybSxhOjH1aingiisd9z9hmJbwI17Z1villkcYcmzX1p19hsz539Nf7E(S8qw0rwOoaeKLjSzHyBLSJtgyHcz539NLFhJYI3y(Sy3PpcYsjgl6ZIooHnYYVJfXab4Dn9cmgi1bG1jSRbVEzi(J3InAex6yGy66kemE8Xa9WFWmg4C1rRWzfvReJbcI0qFw)bZyGJlfPSqMGKdl3KLlzXtwiNG6SOilEcYY3hsz5HSOUez5EwwwSy)(Dwiilf1BnXcX2kzhNmOjwiNclODSzz8WeKfpbzzRGU1FaqwaA37IyGH(ESppgiguNffnxw9mklAzPmlo9BxvTG2XMfcXsjYgw0mw0xZPzU6Ov4SIQvIg67bIyPuSqEwggyrFnNM2bGjCrRZgZsg1SSyzelAzPml6R50y1xbSbpxv9o45fQwlf1BdaxTqwiel2qWJXYWal6R50e86LbtJf(Luw2KLiHLrSOLfaEFUUcnuhawNWUg86Lbw0YszwSLLaeaME(MednubBqwggybe(gh0T(dawP29UOc6foj08xGOljXYiw0YszwSLLaeaME(gay(7rBwggyrFnNM2bGjCrRZgZsg10yHFjLfcXsjIfnJLYSqWSukw6vItytcn0lNlvDpk9X(CdMUUcbzzelAzrFnNM2bGjCrRZgZsg1SSyzyGfBzrFnNM2bGjCrRZgZsg1SSyzelAzPml2YsacatpFdrr7ZtwggyjaHkqO90Gfwq7yx1HjOPXc)sklBYInJXYiw0YY7nj8n)vG1hwbpKLnzH8SmmWIoKszrllZJ0(xBSWVKYcHyrJXI)4TyJnXLogiMUUcbJhFmqp8hmJbsFVNUsfdeePH(S(dMXahxkYIMFI)olaFVNUsXIvdduwUjlaFVNUsXYrZTFwwwXad99yFEmq91CAGj(70Qf2b06pyAwwSOLf91CAOV3txPmnoBKU76km(J3InroU0XaX01viy84Jb6H)GzmWGNbuv1xZzmWqFp2NhduFnNg67Tc2GMgl8lPSqiwiplAzPml6R50Gb1zrXkfQ820yHFjLLnzH8SmmWI(AonyqDwuSQwP3Mgl8lPSSjlKNLrSOLfN(TRQwq7yZYMSuIglgO(AoRPxGXaPV3kydgdeePH(S(dMXajMNbuXcW3BfSbz5MSCpl7oLffsPS87EYc5PS0yHF5LK0elrHlw8gzXFwkrJraw2kLGWINGS87ilHv3y(Sqob1zrrw2DklKNauwASWV8ssXF8wSHGJlDmqmDDfcgp(yGE4pygdm4zavv91Cgdm03J95XaFxH5BUm4D6)btdMUUcbzrll2YY7kmFtI2RfqyAW01viilAzPepwkZszwI8yJXIMXIt)2vvlODSzHaSqWJXIMXcf)QomxuZFyBtKuTXkWsPyHGhJLrSqwwkZcbZczzHAHkvD3PpYYiw0mwcqOceApnbycasew)DSsTU(EQPXc)sklJyHqSuIhlLzPmlrESXyrZyXPF7QQf0o2SOzSOVMtJvFfWg8Cv17GNxOATuuVnaC1czHaSqWJXIMXcf)QomxuZFyBtKuTXkWsPyHGhJLrSqwwkZcbZczzHAHkvD3PpYYiw0mwcqOceApnbycasew)DSsTU(EQPXc)sklJyrllbiubcTNMGxVmyASWVKYYMSe5Xyrll6R50y1xbSbpxv9o45fQwlf1BdaxTqwiel2OXySOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwilBYsKhJfTSeGqfi0EAcWeaKiS(7yLAD99utJf(Luwiele8ySOLL5rA)Rnw4xszztwcqOceApnbycasew)DSsTU(EQPXc)skleGfIllAzPml9kXjSjHMaQq6FUQsTU(EQbtxxHGSmmWcaVpxxHMambajcRGinAgyzumq91CwtVaJbA1xbSbpxv9o45fQwlf17yGGin0N1FWmgiX8mGkw(DKfcYsr9Mf91CYYnz53rwSAyGf7WLcm3(zrDjYYYIf73VZYVJSKiHFw(RazHyWeaKiKLaSaPSaNtwcGgwk9(rzzrxUsfLfyQIYYUBzHjLfWvFjjw(DKLXtgM4pEl2q(4shdetxxHGXJpgi0kgif)yGE4pygdeG3NRRWyGaC1cJbgGaW0Z3KhP9VoDKfTS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileGfN(TRQwq7yZcbyjYSSzeSe5XgJfTSaW7Z1vOjataqIWkisJMbw0YsacvGq7PjataqIW6VJvQ113tnnw4xszHqS40VDv1cAhBwillrEmwkflKcGMcNWSOLfBzbSxhOjH1aiLfTSGb1zrrZLvpJYIwwC63UQAbTJnlBYcaVpxxHMambajcRo1IfTSeGqfi0EAcE9YGPXc)sklBYc5JbcI0qFw)bZyGaXNYI9DmzHGSuuVzHUdxkqw0rwSAyiGGSGERIYYdzrhzX1vilpKLffzHyWeaKiKfyYsacvGq7jlLjhkfZ)CLkkl6yawGuw(EHSCtwaxfwxsILTsjiSKq7Sy)ukwCLcANLOWflpKflSNy4vrzbZhBwiilf1Bw8eKLFhtwwuKfIbtaqIWrXab4Dn9cmgOvddvRLI6Df9wfn(J3Ine34shdetxxHGXJpgOh(dMXaPV3txPIbcI0qFw)bZyGJlfzb4790vkwSF)olaFuP8MfnxFZNfyZYBtKWcbBfyXtqwsilaFVvWgutSyFhtwsilaFVNUsXYrzzzXcSz5HSy1WaleKLI6nl23XKfxhcazPenglBLsqkdBw(DKf0Bvuwiilf1BwSAyGfaEFUUcz5OS89chXcSzXbT8)aGSqT7Dbl7oLLiHaumqzPXc)YljXcSz5OSCjlt1rA)Jbg67X(8yGLz5DfMVH(Os5DfSV5BW01viilddSqXVQdZf18h22ejvc2kWYiw0YITS8UcZ3qFVvWg0GPRRqqw0YI(Aon037PRuMgNns3DDfYIwwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqw0Yszw0xZPXQVcydEUQ6DWZluTwkQ3gaUAHSSzeSyd5hJfTSyll6R50e86LbZYIfTSuMfaEFUUcno1QcUkSyzyGf91CAi6sWgbRyHf0o2fy(vmXM0vs0SSyzyGfaEFUUcnwnmuTwkQ3v0BvuwgXYWalLzjabGPNVjXqdvWgKfTS8UcZ3qFuP8Uc238ny66keKfTSuMfq4BCq36payLA37IkOx4KqtJf(Luw2KLiHLHbw8WFW04GU1FaWk1U3fvqVWjHMlRt1rA)zzelJyzelAzPmlbiubcTNMGxVmyASWVKYYMSOXySmmWsacvGq7PjataqIW6VJvQ113tnnw4xszztw0ymwgf)XBXgYCCPJbIPRRqW4Xhd0d)bZyG03B6QjHXabrAOpR)Gzmqn3QWIYYwPeew0XjSrwigmbajczzrVKel)oYcXGjairilbycE)btwEilHDmqel3KfIbtaqIqwoklE4xUsfLfxhUEwEil6ilbN(Xad99yFEmqaEFUUcnwnmuTwkQ3v0Bv04pEl2ejXLogiMUUcbJhFmqp8hmJbMO9AbeMXabrAOpR)GzmWXLISO5bHjLf77yYsu4IfVrwCD46z5HK1BKLGBzDjjwc7EtcPS4jilforil0vJS87yuw8gz5sw8KfYjOolkYc9pLILjSzHGEnpYsM08Ibg67X(8yGUvnSJbIyrllLzjS7njKYseSydlAzPXWU3KW6FfileIfYZYWalHDVjHuwIGLiZYO4pEl2uIIlDmqmDDfcgp(yGH(ESppgOBvd7yGiw0Yszwc7EtcPSebl2WIwwAmS7njS(xbYcHyH8SmmWsy3BsiLLiyjYSmIfTSuMf91CAWG6SOyvTsVnnw4xszztwqcJH1J1)kqwggyrFnNgmOolkwPqL3Mgl8lPSSjliHXW6X6FfilJIb6H)GzmWDxnRfqyg)XBjYJfx6yGy66kemE8Xad99yFEmq3Qg2XarSOLLYSe29MeszjcwSHfTS0yy3Bsy9VcKfcXc5zzyGLWU3KqklrWsKzzelAzPml6R50Gb1zrXQALEBASWVKYYMSGegdRhR)vGSmmWI(AonyqDwuSsHkVnnw4xszztwqcJH1J1)kqwgfd0d)bZyGZLsvlGWm(J3sK1iU0XaX01viy84Jb6H)Gzmq67nD1KWyGGin0N1FWmg44srwa(EtxnjKfn)e)DwSAyGYINGSaUkSyzRuccl23XKfITvYoozqtSqofwq7yZY4HjOMy53rwkXI5VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsjiXad99yFEmqmOolkAUS6zuw0Yszw0xZPbM4VtRbf6DfWrpyAwwSmmWI(AoneDjyJGvSWcAh7cm)kMyt6kjAwwSmmWI(AonbVEzWSSyrllLzXwwcqay65BikAFEYYWalbiubcTNgSWcAh7Qombnnw4xszztwiplddSOVMttWRxgmnw4xszHqSqkaAkCcZsPyzQGWMLYS40VDv1cAhBwilla8(CDfAO0AasFwgXYiw0YszwSLLaeaME(gay(7rBwggyrFnNM2bGjCrRZgZsg10yHFjLfcXcPaOPWjmlLILaEkwkZszwC63UQAbTJnleGfcEmwkflVRW8nZvhTcNvuTs0GPRRqqwgXczzbG3NRRqdLwdq6ZYiwialrMLsXY7kmFtI2RfqyAW01viilAzXww6vItytcn0lNlvDpk9X(CdMUUcbzrll6R500oamHlAD2ywYOMLflddSOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95MLflddSuMf91CAAhaMWfToBmlzutJf(LuwielE4pyAOV3ZRrdsymSES(xbYIwwOwOsv3D6JSqiwgZqWSmmWI(AonTdat4IwNnMLmQPXc)skleIfp8hmn2B)3niHXW6X6FfilddSaW7Z1vO5IuWAaMG3FWKfTSeGqfi0EAUKg6176kSgPlp)vrfebCb00OdgLfTSGr66SSqqZL0qVExxH1iD55VkQGiGlGSmIfTSOVMtt7aWeUO1zJzjJAwwSmmWITSOVMtt7aWeUO1zJzjJAwwSOLfBzjaHkqO900oamHlAD2ywYOMgDWOSmILHbwa4956k04uRk4QWILHbw0HuklAzzEK2)AJf(LuwielKcGMcNWSukwc4PyPmlo9BxvTG2XMfYYcaVpxxHgkTgG0NLrSmk(J3sKTjU0XaX01viy84Jb6H)Gzmq67nD1KWyGGin0N1FWmgyP7OS8qwkCIqw(DKfDK(SaNSa89wbBqw0JYc99arxsIL7zzzXsKUUarQOSCjlEgLfYjOolkYI(6zHGSuuVz5O52plUoC9S8qw0rwSAyiGGXad99yFEmW3vy(g67Tc2GgmDDfcYIwwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqw0Yszw0xZPH(ERGnOzzXYWalo9BxvTG2XMLnzPenglJyrll6R50qFVvWg0qFpqeleILiZIwwkZI(AonyqDwuSsHkVnllwggyrFnNgmOolkwvR0BZYILrSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfBiZJXIwwkZsacvGq7Pj41ldMgl8lPSSjlAmglddSylla8(CDfAcWeaKiScI0OzGfTSeGaW0Z3KhP9VoDKLrXF8wICKJlDmqmDDfcgp(yGqRyGu8Jb6H)GzmqaEFUUcJbcWvlmgiguNffnxwvR0BwkflrclKLfp8hmn03751Objmgwpw)RazHaSyllyqDwu0CzvTsVzPuSuMfIlleGL3vy(gkCPQWz93X6e2i9ny66keKLsXsKzzelKLfp8hmn2B)3niHXW6X6FfileGLXmem5zHSSqTqLQU70hzHaSmMH8SukwExH5Bs)xnsR6UYZaAW01viymqqKg6Z6pygdKCO)v4pszzhANLIvyNLTsjiS4nYcj)seKflSzHIbycAyrZpvrz5DIqklol00TO7WNLjSz53rwcRUX8zHE)Y)dMSqHSyhUuG52pl6ilEiSA)rwMWMfL3KWML)kWz7fingiaVRPxGXaDQfbbBGyi(J3sKj44shdetxxHGXJpgOh(dMXaPV30vtcJbcI0qFw)bZyGAUvHflaFVPRMeYYLS4jlKtqDwuKfNYcfctwCklwqk90viloLffmjXItzjkCXI9tPybtqwwwSy)(DwIKXial23XKfmFSVKel)oYsIe(zHCcQZIIAIfqyU9ZIcFwUNfRggyHGSuuV1elGWC7NfiaST33JS4jlA(j(7Sy1WalEcYIfeQyrhNWgzHyBLSJtgyXtqwiNclODSzz8WemgyOVh7ZJbAll9kXjSjHM)kq7WoRGn6f6xcITbtxxHGSOLLYSOVMtJvFfWg8Cv17GNxOATuuVnaC1czHqSydzEmwggyrFnNgR(kGn45QQ3bpVq1APOEBa4QfYcHyXgYpglAz5DfMVH(Os5DfSV5BW01viilJyrllLzbdQZIIMlRuOYBw0YIt)2vvlODSzHaSaW7Z1vOXPweeSbIbwkfl6R50Gb1zrXkfQ820yHFjLfcWci8nZvhTcNvuTs08xGiATXc)swkfl2yiplBYsKmglddSGb1zrrZLv1k9MfTS40VDv1cAhBwiala8(CDfACQfbbBGyGLsXI(AonyqDwuSQwP3Mgl8lPSqawaHVzU6Ov4SIQvIM)cerRnw4xYsPyXgd5zztwkrJXYiw0YITSOVMtdmXFNwTWoGw)btZYIfTSyllVRW8n03BfSbny66keKfTSuMLaeQaH2ttWRxgmnw4xszztwiZSmmWcfUu6xcA(9(uQkfrIW2GPRRqqw0YI(Aon)EFkvLIiryBOVhiIfcXsKJmlAglLzPxjoHnj0qVCUu19O0h7Zny66keKLsXInSmIfTSmps7FTXc)sklBYIgJnglAzzEK2)AJf(Luwiel2m2ySmmWcyVoqtcRbqklJyrllLzXwwcqay65BikAFEYYWalbiubcTNgSWcAh7Qombnnw4xszztwSHLrXF8wIm5JlDmqmDDfcgp(yGE4pygdmr71cimJbcI0qFw)bZyGJlfzrZdctklxYINrzHCcQZIIS4jiluhaYcb9UAsaY0sPyrZdctwMWMfITvYoozGfpbzPe3LGncYc5uybTJDbMVHLTQOqwwuKLTO5XINGSqM08yXFw(DKfmbzbozHm1ywYOS4jilGWC7Nff(SO5A0l0VeeBwMUsXcCoJbg67X(8yGUvnSJbIyrlla8(CDfAOoaSoHDn41ldSOLLYSOVMtdguNffRQv6TPXc)sklBYcsymSES(xbYYWal6R50Gb1zrXkfQ820yHFjLLnzbjmgwpw)Razzu8hVLitCJlDmqmDDfcgp(yGH(ESppgOBvd7yGiw0YcaVpxxHgQdaRtyxdE9YalAzPml6R50Gb1zrXQALEBASWVKYYMSGegdRhR)vGSmmWI(AonyqDwuSsHkVnnw4xszztwqcJH1J1)kqwgXIwwkZI(AonbVEzWSSyzyGf91CAS6Ra2GNRQEh88cvRLI6TbGRwilekcwSrJXyzelAzPml2YsacatpFdam)9OnlddSOVMtt7aWeUO1zJzjJAASWVKYcHyPmlKNfnJfByPuS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYiw0YI(AonTdat4IwNnMLmQzzXYWal2YI(AonTdat4IwNnMLmQzzXYiw0YszwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggybjmgwpw)RazHqSOVMtZFfODyNvWg9c9lbX20yHFjLLHbwSLf91CA(RaTd7Sc2OxOFji2MLflJIb6H)GzmWDxnRfqyg)XBjYK54shdetxxHGXJpgyOVh7ZJb6w1WogiIfTSaW7Z1vOH6aW6e21GxVmWIwwkZI(AonyqDwuSQwP3Mgl8lPSSjliHXW6X6FfilddSOVMtdguNffRuOYBtJf(Luw2KfKWyy9y9VcKLrSOLLYSOVMttWRxgmllwggyrFnNgR(kGn45QQ3bpVq1APOEBa4QfYcHIGfB0ymwgXIwwkZITSeGaW0Z3qu0(8KLHbw0xZPHOlbBeSIfwq7yxG5xXeBsxjrZYILrSOLLYSyllbiam98naW83J2SmmWI(AonTdat4IwNnMLmQPXc)skleIfYZIww0xZPPDaycx06SXSKrnllw0YITS0ReNWMeAOxoxQ6Eu6J95gmDDfcYYWal2YI(AonTdat4IwNnMLmQzzXYiw0YszwSLLEL4e2KqZFfODyNvWg9c9lbX2GPRRqqwggybjmgwpw)RazHqSOVMtZFfODyNvWg9c9lbX20yHFjLLHbwSLf91CA(RaTd7Sc2OxOFji2MLflJIb6H)GzmW5sPQfqyg)XBjYrsCPJbIPRRqW4XhdeePH(S(dMXahxkYcbfKCybMSeaJb6H)Gzmq7E3hSRWzfvReJ)4Te5suCPJbIPRRqW4Xhd0d)bZyG03751ymqqKg6Z6pygdCCPilaFVNxJS8qwSAyGfGqL3Sqob1zrrnXcX2kzhNmWYUtzrHukl)vGS87EYIZcbv7)oliHXW6rwu48zb2SatvuwiJv6nlKtqDwuKLJYYYYWcb197SuABIewSXkWcMp2S4SaeQ8MfYjOolkYYnzHGSuuVzH(NsXYUtzrHukl)UNSyJgJXc99aruw8eKfITvYoozGfpbzHyWeaKiKLDhaYsbSrw(DpzrdYmLfIP5yPXc)YljzyzCPilUoeaYInKFmIdl7o9rwax9LKyHm1ywYOS4jil2yJnehw2D6JSy)(D46zHm1ywYOXad99yFEmqmOolkAUSQwP3SOLfBzrFnNM2bGjCrRZgZsg1SSyzyGfmOolkAOqL31ej8ZYWalLzbdQZIIgpJwtKWplddSOVMttWRxgmnw4xszHqS4H)GPXE7)Ubjmgwpw)Razrll6R50e86LbZYILrSOLLYSyllu8R6WCrn)HTnrs1gRalddS0ReNWMeAS6Ra2GNRQEh88cvRLI6TbtxxHGSOLf91CAS6Ra2GNRQEh88cvRLI6TbGRwileIfB0ymw0YsacvGq7Pj41ldMgl8lPSSjlAqMzrllLzXwwcqay65BYJ0(xNoYYWalbiubcTNMambajcR)owPwxFp10yHFjLLnzrdYmlJyrllLzXwwApGMVHkflddSeGqfi0EA0XMInrxsY0yHFjLLnzrdYmlJyzelddSGb1zrrZLvpJYIwwkZI(Aon29UpyxHZkQwjAwwSmmWc1cvQ6UtFKfcXYygcM8SOLLYSyllbiam98naW83J2SmmWITSOVMtt7aWeUO1zJzjJAwwSmILHbwcqay65BaG5VhTzrlluluPQ7o9rwielJziywgf)XBHGhlU0XaX01viy84JbcI0qFw)bZyGJlfzHGQ9FNf4VJT9JISyF)c7SCuwUKfGqL3Sqob1zrrnXcX2kzhNmWcSz5HSy1WalKXk9MfYjOolkgd0d)bZyG2B)3J)4TqWAex6yGy66kemE8XabrAOpR)GzmqYKRu)EVIb6H)GzmWELvp8hmRQJ(Xavh9RPxGXaNUs979k(J)4pgiaSPhmJ3InJzJnJf5X0igODVZljrJbsqTvcABzC2cbDLalSu6DKLRWc2pltyZY2qlmXEBwAmsxxJGSqHfil(6Hf(JGSe29Kesn8gKXLil2ucSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszni8idVbzCjYsKlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3GmUezHGlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3G3GGARe02Y4Sfc6kbwyP07ilxHfSFwMWMLTbXPVu)2S0yKUUgbzHclqw81dl8hbzjS7jjKA4niJlrwiULaledMaW(rqwaEfeJfA08DcZcXHLhYczSCwapah9GjlqlS9h2SuMSJyPSgeEKH3GmUezH4wcSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszBi8idVbzCjYczUeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKLiPeyHyWea2pcYcWRGySqJMVtywioS8qwiJLZc4b4OhmzbAHT)WMLYKDelLTHWJm8gKXLilrsjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlL1GWJm8gKXLilLOsGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkhzcpYWBqgxISuIkbwigmbG9JGSS93xse(gnme)2S8qw2(7ljcFZRHH43MLY2q4rgEdY4sKLsujWcXGjaSFeKLT)(sIW3yJH43MLhYY2FFjr4BEBme)2Su2gcpYWBqgxISOXyLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISOHgLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISOHnLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISOrKlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3GmUezrdYxcSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszni8idVbzCjYIge3sGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkBdHhz4niJlrw0G4wcSqmyca7hbzz7VVKi8nAyi(Tz5HSS93xse(MxddXVnlLTHWJm8gKXLilAqClbwigmbG9JGSS93xse(gBme)2S8qw2(7ljcFZBJH43MLYAq4rgEdY4sKfniZLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42Su2gcpYWBqgxISObzUeyHyWea2pcYY2FFjr4B0Wq8BZYdzz7VVKi8nVggIFBwkRbHhz4niJlrw0GmxcSqmyca7hbzz7VVKi8n2yi(Tz5HSS93xse(M3gdXVnlLTHWJm8g8geuBLG2wgNTqqxjWclLEhz5kSG9ZYe2SSTvJbyHU)BZsJr66AeKfkSazXxpSWFeKLWUNKqQH3GmUezjYLaledMaW(rqw2(7ljcFJggIFBwEilB)9LeHV51Wq8BZs5it4rgEdY4sKfcUeyHyWea2pcYY2FFjr4BSXq8BZYdzz7VVKi8nVngIFBwkhzcpYWBqgxISqMlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzXFwihnFYGLYAq4rgEdEdcQTsqBlJZwiOReyHLsVJSCfwW(zzcBw22H42S0yKUUgbzHclqw81dl8hbzjS7jjKA4niJlrw0OeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfBkbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3GmUezXMsGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBw8NfYrZNmyPSgeEKH3GmUezjYLaledMaW(rqw2(DfMVH43MLhYY2VRW8neVbtxxHGBZszni8idVbzCjYsKlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPCKj8idVbzCjYcXTeyHyWea2pcYcWRGySqJMVtywioehwEilKXYzPacUulklqlS9h2SuM4mILYAq4rgEdY4sKfIBjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlLTHWJm8gKXLilK5sGfIbtay)iilaVcIXcnA(oHzH4qCy5HSqglNLci4sTOSaTW2FyZszIZiwkRbHhz4niJlrwiZLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISejLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISuIkbwigmbG9JGSa8kigl0O57eMfIdlpKfYy5SaEao6btwGwy7pSzPmzhXszBi8idVbzCjYIg2ucSqmyca7hbzb4vqmwOrZ3jmlehwEilKXYzb8aC0dMSaTW2FyZszYoILYAq4rgEdY4sKfni4sGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkRbHhz4niJlrw0G8LaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42SuwdcpYWBqgxISObXTeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfnIKsGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkRbHhz4niJlrwSzSsGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkBdHhz4niJlrwSXMsGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuwdcpYWBqgxISydbxcSqmyca7hbzb4vqmwOrZ3jmlehwEilKXYzb8aC0dMSaTW2FyZszYoILY2q4rgEdY4sKfBi4sGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkRbHhz4niJlrwSH4wcSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszni8idVbzCjYInK5sGfIbtay)iilB3ReNWMeAi(Tz5HSSDVsCcBsOH4ny66keCBwkRbHhz4niJlrwSPevcSqmyca7hbzb4vqmwOrZ3jmlehwEilKXYzb8aC0dMSaTW2FyZszYoILY2q4rgEdY4sKLipwjWcXGjaSFeKfGxbXyHgnFNWSqCy5HSqglNfWdWrpyYc0cB)HnlLj7iwkRbHhz4n4niO2kbTTmoBHGUsGfwk9oYYvyb7NLjSzz7PRu)EV2MLgJ011iiluybYIVEyH)iilHDpjHudVbzCjYInLaledMaW(rqwaEfeJfA08DcZcXHLhYczSCwapah9GjlqlS9h2SuMSJyPSgeEKH3G3GGARe02Y4Sfc6kbwyP07ilxHfSFwMWMLTP)2S0yKUUgbzHclqw81dl8hbzjS7jjKA4niJlrwSPeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYKNWJm8gKXLilrUeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfcUeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfIBjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnl(Zc5O5tgSuwdcpYWBqgxISOXyLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42Su2gcpYWBqgxISObbxcSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszni8idVbzCjYIge3sGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuwdcpYWBqgxISObXTeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYKNWJm8gKXLilAqMlbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3GmUezrJiPeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfB0OeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKfBi4sGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuMGj8idVbzCjYIneCjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlL1GWJm8gKXLil2q(sGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuwdcpYWBqgxISyd5lbwigmbG9JGSSDVsCcBsOH43MLhYY29kXjSjHgI3GPRRqWTzPSgeEKH3GmUezXgIBjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlL1GWJm8gKXLilrwJsGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuoYeEKH3GmUezjYAucSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszni8idVbzCjYsKTPeyHyWea2pcYY29kXjSjHgIFBwEilB3ReNWMeAiEdMUUcb3MLYAq4rgEdY4sKLih5sGfIbtay)iilaVcIXcnA(oHzH4WYdzHmwolGhGJEWKfOf2(dBwkt2rSuoYeEKH3GmUezjYeCjWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlLTHWJm8gKXLilrM4wcSqmyca7hbzz7EL4e2KqdXVnlpKLT7vItytcneVbtxxHGBZszBi8idVbzCjYsKjZLaledMaW(rqw2UxjoHnj0q8BZYdzz7EL4e2KqdXBW01vi42Su2gcpYWBqgxISe5sujWcXGjaSFeKLT7vItytcne)2S8qw2UxjoHnj0q8gmDDfcUnlL1GWJm8g8gJtHfSFeKfIllE4pyYI6Op1WBedKAHH4TOXy2ed0QHZtHXajxYLLX7kpdilAUEDG8gKl5YIMN3HDwSrtSyZy2ydVbVb5sUSqSDpjH0sG3GCjxw0mw2kiicYcqOYBwgp6fgEdYLCzrZyHy7Escbz59Me(1BYsWPiLLhYsiAqH13Bs4tn8gKl5YIMXcbnSacabzzLjgqk17OSaW7Z1viLLYNbnAIfRgbuPV30vtczrZ2KfRgbyOV30vtchz4nixYLfnJLTcaEGSy1yWP)LKyHGQ9FNLBYY9Btz53rwS3WKelKtqDwu0WBqUKllAglAEoriledMaGeHS87ilaTU(EklolQ7FfYsbSrwMkKWNUczP8nzjkCXYUdMB)SSFpl3Zc9kwQ3teUOQOSy)(DwgVM)wlnleGfIHkK(NRyzRQJuwG5RjwUFBqwOeDwJm8gKl5YIMXIMNteYsbK(SS98iT)1gl8lPBZcnGP3hKYIBzPIYYdzrhsPSmps7pLfyQIA4nixYLfnJLs3O)SuAybYcCYY4v(olJx57SmELVZItzXzHAHHZvS89LeHVH3GCjxw0mw08TWeBwkFg0OjwiOA)31eleuT)7AIfGV3ZRXrSu4GilfWgzPr6PomFwEilO3QdBwcWcD)1m679B4nixYLfnJfY0rywkXDjyJGSqofwq7yxG5ZsyhdeXYe2SqmnhllQtcn8g8gKl5YYwZe((JGSmEx5zazzReeYGLGNSOJSmHReKf)zz)FlAjqwYQ7kpdOMrVIGH097lDZbj74DLNbuZaEfeJSfGM9VqvI)8uye6UYZaAEc)8g8gE4pysnwngGf6(hbrxc2iyLAD99uEdYLLsVJSaW7Z1vilhLfk(S8qwgJf73VZsczH((Zcmzzrrw((sIWNQjw0Gf77yYYVJSmVM(SatKLJYcmzzrrnXInSCtw(DKfkgGjilhLfpbzjYSCtw0H)olEJ8gE4pysnwngGf6(tGiilaVpxxHAk9cmcywxuS(9LeHVMa4QfgXy8gE4pysnwngGf6(tGiilaVpxxHAk9cmcywxuS(9LeHVMGwr4GGAcGRwyeAOPBgX3xse(gnm7oTUOyvFnNA)(sIW3OHjaHkqO90aUA)pyQ12VVKi8nAyoQ5HfyfoRfWK(nCrRbys)Ef(dMuEdp8hmPgRgdWcD)jqeKfG3NRRqnLEbgbmRlkw)(sIWxtqRiCqqnbWvlmcB00nJ47ljcFJnMDNwxuSQVMtTFFjr4BSXeGqfi0EAaxT)hm1A73xse(gBmh18WcScN1cys)gUO1amPFVc)btkVb5YsP3rkYY3xse(uw8gzjHpl(6Hf(FbxPIYci(y4rqwCklWKLffzH((ZY3xse(udlSaeFwa4956kKLhYcbZItz53XOS4kkKLerqwOwy4Cfl7EcQUKKH3Wd)btQXQXaSq3Fcebzb4956kutPxGraZ6II1VVKi81e0kcheutaC1cJGG10nJaJ01zzHGMlPHE9UUcRr6YZFvubraxahgWiDDwwiOblSI2ORQWgm9mGddyKUolle0qHlLc))ss1EPhL3GCzbi(uw(DKfGV30vtczjaPpltyZIYFSzj4QWs5)btklLNWMfKWEHLczX(oMS8qwOV3plGRcRljXIooHnYczQXSKrzz6kfLf4CoI3Wd)btQXQXaSq3Fcebzb4956kutPxGrqP1aK(AcGRwyerESsvwdnBmJnLIIFvhMlQ5pSTjsQeSvyeVb5Ycq8PS4pl23VWolEbCLplWjlBLsqyHyWeaKiKf6oCPazrhzzrrWsGfcEmwSF)oC9SqmuH0)CflaTU(EklEcYsKhJf73VB4n8WFWKASAmal09NarqwaEFUUc1u6fyebycasewDQLMa4QfgrKhJaAmwP6vItytcnbuH0)CvLAD99uEdp8hmPgRgdWcD)jqeKTactIUSoHDbVHh(dMuJvJbyHU)eicYAV9FxtQlXAamcngtt3mIYyqDwu0OwP31ej8pmGb1zrrZLvku59WaguNffnxw1H)(WaguNffnEgTMiH)r8g8gKlleKgdo9zXgwiOA)3zXtqwCwa(EtxnjKfyYcWsZI973zzlhP9NfYKJS4jilJhU1sZcSzb4798AKf4VJT9JI8gE4pysnqlmXMarqw7T)7A6MrugdQZIIg1k9UMiH)HbmOolkAUSsHkVhgWG6SOO5YQo83hgWG6SOOXZO1ej8psRvJamAyS3(VR1wRgbySXyV9FN3Wd)btQbAHj2eicYsFVNxJAsDjwdGrqEnDZiSTxjoHnj0O7kpdyfoRUsv)9ljrhgSnabGPNVjps7FD64WGTuluPQV3KWNAOV3txPIqJHbBFxH5Bs)xnsR6UYZaAW01vi4WqzmOolkAOqL31ej8pmGb1zrrZLv1k9EyadQZIIMlR6WFFyadQZIIgpJwtKW)iEdp8hmPgOfMytGiil99EEnQj1Lynagb510nJOST9kXjSjHgDx5zaRWz1vQ6VFjj6WGTbiam98n5rA)RthhgSLAHkv99Me(ud99E6kveAmmy77kmFt6)QrAv3vEgqdMUUcbhP1wk(vDyUOM)W2MiPAJvyyOmguNffnuOY7AIe(hgWG6SOO5YQALEpmGb1zrrZLvD4VpmGb1zrrJNrRjs4FeVHh(dMud0ctSjqeKL(EtxnjutQlXAamcYRPBgr5EL4e2KqJUR8mGv4S6kv93VKevBacatpFtEK2)60rTuluPQV3KWNAOV3txPIqJrATLIFvhMlQ5pSTjsQ2yf4n4nixYLfYHWyy9iiliaSJYYFfil)oYIhEyZYrzXb4NY1vOH3Wd)btAeuOY7Qo6f8gE4pysjqeKn4kv1d)bZQ6OVMsVaJaAHj2AI(9f(i0qt3mI)kqcv2Ms5H)GPXE7)Uj40V(xbsap8hmn03751Oj40V(xboI3GCzbi(uw2kKCybMSezcWI973HRNfW(MplEcYI973zb47Tc2GS4jil2qawG)o22pkYB4H)GjLarqwaEFUUc1u6fyehT6qutaC1cJGAHkv99Me(ud99E6k1MAOTSTVRW8n03BfSbny66keCy4DfMVH(Os5DfSV5BW01vi4OHbQfQu13Bs4tn037PRuBAdVb5Ycq8PSeuOdazX(oMSa89EEnYsWtw2VNfBialV3KWNYI99lSZYrzPrfcWZNLjSz53rwiNG6SOilpKfDKfRgNy3iilEcYI99lSZY8ukSz5HSeC6ZB4H)GjLarqwaEFUUc1u6fyehTguOda1eaxTWiOwOsvFVjHp1qFVNxJBQbVb5YsjwVpxxHS87(Zsyhderz5MSefUyXBKLlzXzHuaKLhYIdaEGS87il07x(FWKf77yJS4S89LeHpl4hy5OSSOiilxYIo(2rmzj40NYB4H)GjLarqwaEFUUc1u6fyexwjfa1eaxTWiSAeqLua0OHPacZ514WGvJaQKcGgnm0voVghgSAeqLua0OHH(EtxnjCyWQravsbqJgg6790vQHbRgbujfanAyMRoAfoROAL4WGvJamTdat4IwNnMLm6WG(AonbVEzW0yHFjnc91CAcE9YGbC1(FWCyaG3NRRqZrRoe5nixwgxkYY4XMInrxsIf)z53rwWeKf4KfYuJzjJYI9Dmzz3PpYYrzX1HaqwiUJrC0el(8XMfIbtaqIqw8eKf4VJT9JISy)(Dwi2wj74KbEdp8hmPeicYQJnfBIUKKMUzeLlBBacatpFtEK2)60XHbBdqOceApnbycasew)DSsTU(EQzznm0ReNWMeAcOcP)5Qk1667PJ0QVMttWRxgmnw4xs3udYRvFnNM2bGjCrRZgZsg10yHFjLqeSwBdqay65BaG5VhThgcqay65BaG5VhT1QVMttWRxgmllT6R500oamHlAD2ywYOMLL2Y6R500oamHlAD2ywYOMgl8lPekcnSrZi4s1ReNWMeAOxoxQ6Eu6J95dd6R50e86LbtJf(LucPHgddAqCOwOsv3D6JesddXD0iTa8(CDfAUSskaYBqUSqqGpl2VFNfNfITvYoozGLF3FwoAU9ZIZcbzPOEZIvddSaBwSVJjl)oYY8iT)SCuwCD46z5HSGjiVHh(dMucebzTG)btnDZikRVMttWRxgmnw4xs3udYRTST9kXjSjHg6LZLQUhL(yF(WG(AonTdat4IwNnMLmQPXc)skH0OePvFnNM2bGjCrRZgZsg1SSgnmOdPuTZJ0(xBSWVKsiBi)iTa8(CDfAUSskaYBqUSqmxfwk)rkl23XFhBww0ljXcXGjairilj0ol2pLIfxPG2zjkCXYdzH(NsXsWPpl)oYc1lqw8c4kFwGtwigmbajcjaX2kzhNmWsWPpL3Wd)btkbIGSa8(CDfQP0lWicWeaKiScI0OzqtaC1cJiGNQC55rA)Rnw4xs1mniVMfGqfi0EAcE9YGPXc)s6iIJgrYyJIiGNQC55rA)Rnw4xs1mniVMfGqfi0EAcWeaKiS(7yLAD99ud4Q9)GPMfGqfi0EAcWeaKiS(7yLAD99utJf(L0rehnIKXgP122pWkcaZ34GGuds4J(uTLTnaHkqO90e86LbtJoy0HbBdqOceApnbycaseAA0bJoAyiaHkqO90e86LbtJf(L0nV8X2cQ8hbRZJ0(xBSWVKom0ReNWMeAcOcP)5Qk1667PAdqOceApnbVEzW0yHFjDZip2WqacvGq7PjataqIW6VJvQ113tnnw4xs38YhBlOYFeSops7FTXc)sQMPXydd2gGaW0Z3KhP9VoDK3GCzzCPiilpKfqu5rz53rwwuNeYcCYcX2kzhNmWI9DmzzrVKelGWLUczbMSSOilEcYIvJaW8zzrDsil23XKfpzXbbzbbG5ZYrzX1HRNLhYc4H8gE4pysjqeKfG3NRRqnLEbgraSgGj49hm1eaxTWik)EtcFZFfy9HvWd3udYpm0(bwray(gheKAUCtYp2iTLlJr66SSqqdwyfTrxvHny6za1w22aeaME(gay(7r7HHaeQaH2tdwyfTrxvHny6zannw4xsjKgexYmbkt(s1ReNWMeAOxoxQ6Eu6J95JgP12aeQaH2tdwyfTrxvHny6zann6GrhnmGr66SSqqdfUuk8)ljv7LEuTLTnabGPNVjps7FD64WqacvGq7PHcxkf()LKQ9spAnYem5JKX0W0yHFjLqAObbpAyOCacvGq7PrhBk2eDjjtJoy0HbBBpGMVHk1WqacatpFtEK2)60XrAlB77kmFZC1rRWzfvReny66keCyiabGPNVbaM)E0wBacvGq7PzU6Ov4SIQvIMgl8lPesdnia5lvVsCcBsOHE5CPQ7rPp2NpmyBacatpFdam)9OT2aeQaH2tZC1rRWzfvRennw4xsjK(AonbVEzWaUA)pysanSPu9kXjSjHgR(kGn45QQ3bpVq1APOERzAyZiTLXiDDwwiO5sAOxVRRWAKU88xfvqeWfqTbiubcTNMlPHE9UUcRr6YZFvubraxannw4xsje5hnmuUmgPRZYcbn0DheAhbRWwVcN1h2fy(AdqOceApnpSlW8rW6L0J0(xJm5jFKTrdtJf(L0rddLldW7Z1vObM1ffRFFjr4hHgdda8(CDfAGzDrX63xse(re5rAl)9LeHVrdtJoy0AacvGq75WW3xse(gnmbiubcTNMgl8lPBE5JTfu5pcwNhP9V2yHFjvZ0ySrdda8(CDfAGzDrX63xse(ryJ2YFFjr4BSX0OdgTgGqfi0Eom89LeHVXgtacvGq7PPXc)s6Mx(yBbv(JG15rA)Rnw4xs1mngB0WaaVpxxHgywxuS(9LeHFeJnA0iEdYLLsSEFUUczzrrqwEilGOYJYINrz57ljcFklEcYsaKYI9DmzXUF)LKyzcBw8KfYzzTd7ZzXQHbEdp8hmPeicYcW7Z1vOMsVaJ437tPQuejc7QD)EnbWvlmcBPWLs)sqZV3NsvPise2gmDDfcommps7FTXc)s6M2m2ydd6qkv78iT)1gl8lPeYgYtGYe8yAM(Aon)EFkvLIiryBOVhiQu2mAyqFnNMFVpLQsrKiSn03deTzKJenRCVsCcBsOHE5CPQ7rPp2NxkBgXBqUSmUuKfYPWkAJUIfn)gm9mGSyZyumqzrhNWgzXzHyBLSJtgyzrrwGnluil)U)SCpl2pLIf1LilllwSF)ol)oYcMGSaNSqMAmlzuEdp8hmPeicYUOy9ESqtPxGrGfwrB0vvydMEgqnDZicqOceApnbVEzW0yHFjLq2mM2aeQaH2ttaMaGeH1FhRuRRVNAASWVKsiBgtBzaEFUUcn)EFkvLIiryxT73pmOVMtZV3NsvPise2g67bI2mYJrGY9kXjSjHg6LZLQUhL(yFEPI8OrAb4956k0CzLuaCyqhsPANhP9V2yHFjLqrMmZBqUSmUuKfGWLsH)LKyHG2spklexkgOSOJtyJS4SqSTs2XjdSSOilWMfkKLF3FwUNf7NsXI6sKLLfl2VFNLFhzbtqwGtwitnMLmkVHh(dMucebzxuSEpwOP0lWiOWLsH)FjPAV0JQPBgr5aeQaH2ttWRxgmnw4xsjeXvRTbiam98naW83J2ATnabGPNVjps7FD64WqacatpFtEK2)60rTbiubcTNMambajcR)owPwxFp10yHFjLqexTLb4956k0eGjairyfePrZWWqacvGq7Pj41ldMgl8lPeI4oAyiabGPNVbaM)E0wBzB7vItytcn0lNlvDpk9X(CTbiubcTNMGxVmyASWVKsiI7WG(AonTdat4IwNnMLmQPXc)skH0ymcuM8LcJ01zzHGMlPFVcpSPvWdWLyvhvQrA1xZPPDaycx06SXSKrnlRrdd6qkv78iT)1gl8lPeYgYpmGr66SSqqdwyfTrxvHny6za1gGqfi0EAWcROn6QkSbtpdOPXc)s6M2m2iTa8(CDfAUSskaQ1wmsxNLfcAUKg6176kSgPlp)vrfebCbCyiaHkqO90Cjn0R31vynsxE(RIkic4cOPXc)s6M2m2WGoKs1ops7FTXc)skHSzmEdYLLTQS7rPSSOilJtjMAowSF)oleBRKDCYalWMf)z53rwWeKf4KfYuJzjJYB4H)GjLarqwaEFUUc1u6fyexKcwdWe8(dMAcGRwye6R50e86LbtJf(L0n1G8AlBBVsCcBsOHE5CPQ7rPp2NpmOVMtt7aWeUO1zJzjJAASWVKsOi0G8gYtGYr2q(sPVMtJUccbvl6BwwJiqzc2qEnlYgYxk91CA0vqiOArFZYAuPWiDDwwiO5s63RWdBAf8aCjw1rLIaeSH8LQmgPRZYcbn)owNxt)k9iDkTbiubcTNMFhRZRPFLEKoLPXc)skHIWMXgPvFnNM2bGjCrRZgZsg1SSgnmOdPuTZJ0(xBSWVKsiBi)WagPRZYcbnyHv0gDvf2GPNbuBacvGq7PblSI2ORQWgm9mGMgl8lP8gE4pysjqeKDrX69yHMsVaJ4sAOxVRRWAKU88xfvqeWfqnDZia4956k0CrkynatW7pyQfG3NRRqZLvsbqEdYLLXLISaC3bH2rqw08BDw0XjSrwi2wj74KbEdp8hmPeicYUOy9ESqtPxGrq3DqODeScB9kCwFyxG5RPBgr5aeQaH2ttWRxgmn6Gr1ABacatpFtEK2)60rTa8(CDfA(9(uQkfrIWUA3VxB5aeQaH2tJo2uSj6ssMgDWOdd22EanFdvQrddbiam98n5rA)Rth1gGqfi0EAcWeaKiS(7yLAD99utJoyuTLb4956k0eGjairyfePrZWWqacvGq7Pj41ldMgDWOJgPfe(g6kNxJM)ceDjjTLbHVH(Os5DDQ8gn)fi6ssdd2(UcZ3qFuP8UovEJgmDDfcomqTqLQ(EtcFQH(EpVg3mYJ0ccFtbeMZRrZFbIUKK2Ya8(CDfAoA1H4WqVsCcBsOr3vEgWkCwDLQ(7xsIom40VDv1cAh7nJOen2WaaVpxxHMambajcRGinAggg0xZPrxbHGQf9nlRrATfJ01zzHGMlPHE9UUcRr6YZFvubraxahgWiDDwwiO5sAOxVRRWAKU88xfvqeWfqTbiubcTNMlPHE9UUcRr6YZFvubraxannw4xs3mYJP1w91CAcE9YGzznmOdPuTZJ0(xBSWVKsicEmEdYLLsVFuwoklolT)7yZcQCDy7pYIDpklpKLcNiKfxPybMSSOil03Fw((sIWNYYdzrhzrDjcYYYIf73VZcX2kzhNmWINGSqmycaseYINGSSOil)oYInjiluf8zbMSeaz5MSOd)Dw((sIWNYI3ilWKLffzH((ZY3xse(uEdp8hmPeicYUOy9ESGQjQc(0i((sIWxdnDZikdW7Z1vObM1ffRFFjr4BBeAO12VVKi8n2yA0bJwdqOceAphgkdW7Z1vObM1ffRFFjr4hHgdda8(CDfAGzDrX63xse(re5rAlRVMttWRxgmllTLTnabGPNVbaM)E0EyqFnNM2bGjCrRZgZsg10yHFjLaLJSH8LQxjoHnj0qVCUu19O0h7ZhrOi((sIW3OHrFnNvWv7)btT6R500oamHlAD2ywYOML1WG(AonTdat4IwNnMLmALE5CPQ7rPp2NBwwJggcqOceApnbVEzW0yHFjLa2S53xse(gnmbiubcTNgWv7)btT2QVMttWRxgmllTLTnabGPNVjps7FD64WGTa8(CDfAcWeaKiScI0OzyKwBdqay65BikAFEomeGaW0Z3KhP9VoDulaVpxxHMambajcRGinAg0gGqfi0EAcWeaKiS(7yLAD99uZYsRTbiubcTNMGxVmywwAlxwFnNgmOolkwvR0BtJf(L0n1ySHb91CAWG6SOyLcvEBASWVKUPgJnsRT9kXjSjHgDx5zaRWz1vQ6VFjj6Wqz91CA0DLNbScNvxPQ)(LKO10)vJg67bIIG8dd6R50O7kpdyfoRUsv)9ljrREh8en03defrKmA0WG(AoneDjyJGvSWcAh7cm)kMyt6kjAwwJgg0HuQ25rA)Rnw4xsjKnJnmaW7Z1vObM1ffRFFjr4hXyJ0cW7Z1vO5YkPaiVHh(dMucebzxuSEpwq1evbFAeFFjr4BJMUzeLb4956k0aZ6II1VVKi8TncB0A73xse(gnmn6GrRbiubcTNdda8(CDfAGzDrX63xse(ryJ2Y6R50e86LbZYsBzBdqay65BaG5VhThg0xZPPDaycx06SXSKrnnw4xsjq5iBiFP6vItytcn0lNlvDpk9X(8rekIVVKi8n2y0xZzfC1(FWuR(AonTdat4IwNnMLmQzznmOVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95ML1OHHaeQaH2ttWRxgmnw4xsjGnB(9LeHVXgtacvGq7PbC1(FWuRT6R50e86LbZYsBzBdqay65BYJ0(xNoomylaVpxxHMambajcRGinAggP12aeaME(gII2NNAlBR(AonbVEzWSSggSnabGPNVbaM)E0E0WqacatpFtEK2)60rTa8(CDfAcWeaKiScI0OzqBacvGq7PjataqIW6VJvQ113tnllT2gGqfi0EAcE9YGzzPTCz91CAWG6SOyvTsVnnw4xs3uJXgg0xZPbdQZIIvku5TPXc)s6MAm2iT22ReNWMeA0DLNbScNvxPQ)(LKOddL1xZPr3vEgWkCwDLQ(7xsIwt)xnAOVhikcYpmOVMtJUR8mGv4S6kv93VKeT6DWt0qFpquerYOrJgg0xZPHOlbBeSIfwq7yxG5xXeBsxjrZYAyqhsPANhP9V2yHFjLq2m2WaaVpxxHgywxuS(9LeHFeJnslaVpxxHMlRKcG8gKllJlfPS4kflWFhBwGjllkYY9ybLfyYsaK3Wd)btkbIGSlkwVhlO8gKllKZ97yZcjilx(qw(DKf6ZcSzXHilE4pyYI6OpVHh(dMucebz7vw9WFWSQo6RP0lWiCiQj63x4JqdnDZia4956k0C0QdrEdp8hmPeicY2RS6H)GzvD0xtPxGrqFEdEdYLfI5QWs5pszX(o(7yZYVJSO5A0lc(h2XMf91CYI9tPyz6kflW5Kf73VFjl)oYsIe(zj40N3Wd)btQXHyea8(CDfQP0lWiaB0lQ2pLQoDLQcNtnbWvlmIEL4e2KqZFfODyNvWg9c9lbXwBz91CA(RaTd7Sc2OxOFji2Mgl8lPeIua0u4eMaJz0yyqFnNM)kq7WoRGn6f6xcITPXc)skH8WFW0qFVNxJgKWyy9y9VcKaJz0qBzmOolkAUSQwP3ddyqDwu0qHkVRjs4FyadQZIIgpJwtKW)OrA1xZP5Vc0oSZkyJEH(LGyBww8gKlleZvHLYFKYI9D83XMfGV30vtcz5OSyh2)olbN(xsIfiaSzb4798AKLlzHmwP3Sqob1zrrEdp8hmPghIeicYcW7Z1vOMsVaJ4iLWgR03B6QjHAcGRwye2Ib1zrrZLvku5TwQfQu13Bs4tn037514MKzn7DfMVHcxQkCw)DSoHnsFdMUUcblLneadQZIIMlR6WFxRT9kXjSjHgR(kGn45QQ3bpVq1APOER12EL4e2KqdmXFNwdk07kGJEWK3GCzzCPiledMaGeHSyFhtw8NffsPS87EYc5hJLTsjiS4jilQlrwwwSy)(Dwi2wj74KbEdp8hmPghIeicYgGjairy93Xk1667PA6MrylyVoqtcRbqQ2YLb4956k0eGjairyfePrZGwBdqOceApnbVEzW0OdgDyqFnNMGxVmywwJ0wwFnNgmOolkwvR0BtJf(L0nj)WG(AonyqDwuSsHkVnnw4xs3K8J0w2PF7QQf0o2eI8JPTm1cvQ67nj8Pg6798ACZipmOVMttWRxgmlRrdd22ReNWMeAS6Ra2GNRQEh88cvRLI69iTLT9DfMVH(Os5DfSV5pmOVMtd99E6kLPXc)skH0WqEnBmd5lvVsCcBsOjGkK(NRQuRRVNomOVMttWRxgmnw4xsjK(Aon037PRuMgl8lPeG8A1xZPj41ldML1iTLTTxjoHnj0O7kpdyfoRUsv)9ljrhg0xZPr3vEgWkCwDLQ(7xsIwt)xnAOVhiAZipmOVMtJUR8mGv4S6kv93VKeT6DWt0qFpq0MrE0WGoKs1ops7FTXc)skH0ymTbiubcTNMGxVmyASWVKUj5hXBqUSmUuKfGRCEnYYLSy5jiwCbwGjlEg93VKel)U)SOoaiLfniykgOS4jilkKszX(97SuaBKL3Bs4tzXtqw8NLFhzbtqwGtwCwacvEZc5euNffzXFw0GGzHIbklWMffsPS0yHF5LKyXPS8qws4ZYUd4ssS8qwAC2iDNfWvFjjwiJv6nlKtqDwuK3Wd)btQXHibIGS0voVg1uiAqH13Bs4tJqdnDZik34Sr6URRWHb91CAWG6SOyLcvEBASWVKsOiRfdQZIIMlRuOYBTnw4xsjKgeS23vy(gkCPQWz93X6e2i9ny66keCK23Bs4B(RaRpScE4MAqWAg1cvQ67nj8PeOXc)sQ2YyqDwu0Cz1ZOddnw4xsjePaOPWj8iEdYLLXLISaCLZRrwEil7oaKfNfskOURy5HSSOilJtjMAoEdp8hmPghIeicYsx58Aut3mcaEFUUcnxKcwdWe8(dMAdqOceApnxsd96DDfwJ0LN)QOcIaUaAA0bJQfJ01zzHGMlPHE9UUcRr6YZFvubraxa16w1WogiI3GCzPehIwSSSyb4790vkw8NfxPy5VcKYYkviLYYIEjjwiJObVDklEcYY9SCuwCD46z5HSy1WalWMff(S87ilulmCUIfp8hmzrDjYIoQG2zz3tqfYIMRrVq)sqSzbMSydlV3KWNYB4H)Gj14qKarqw6790vknDZiS9DfMVH(Os5DfSV5BW01viO2Y2sXVQdZf18h22ejvc2kmmGb1zrrZLvpJomqTqLQ(EtcFQH(EpDLAZipsBz91CAOV3txPmnoBKU76kuBzQfQu13Bs4tn037PRuekYdd22ReNWMeA(RaTd7Sc2OxOFji2JggExH5BOWLQcN1FhRtyJ03GPRRqqT6R50Gb1zrXkfQ820yHFjLqrwlguNffnxwPqL3A1xZPH(EpDLY0yHFjLqKzTuluPQV3KWNAOV3txP2mccEK2Y22ReNWMeAurdE706uH4FjPkj1vyrXHH)kqIdXHGj)M6R50qFVNUszASWVKsaBgP99Me(M)kW6dRGhUj55nixwiOUFNfGpQuEZIMRV5ZYIISatwcGSyFhtwAC2iD31vil6RNf6Fkfl297zzcBwiJObVDklwnmWINGSacZTFwwuKfDCcBKfIP5Ogwa(NsXYIISOJtyJSqmycaseYc9YaYYV7pl2pLIfRggyXt4VJnlaFVNUsXB4H)Gj14qKarqw6790vknDZiExH5BOpQuExb7B(gmDDfcQvFnNg6790vktJZgP7UUc1w2wk(vDyUOM)W2MiPsWwHHbmOolkAUS6z0HbQfQu13Bs4tn037PRuBsWJ0w22EL4e2KqJkAWBNwNke)ljvjPUclkom8xbsCioem53KGhP99Me(M)kW6dRGhUzK5nixwiOUFNfnxJEH(LGyZYIISa89E6kflpKfIq0ILLfl)oYI(AozrpklUIczzrVKelaFVNUsXcmzH8SqXambPSaBwuiLYsJf(LxsI3Wd)btQXHibIGS037PRuA6Mr0ReNWMeA(RaTd7Sc2OxOFji2APwOsvFVjHp1qFVNUsTzerwBzB1xZP5Vc0oSZkyJEH(LGyBwwA1xZPH(EpDLY04Sr6URRWHHYa8(CDfAaB0lQ2pLQoDLQcNtTL1xZPH(EpDLY0yHFjLqrEyGAHkv99Me(ud99E6k1M2O9DfMVH(Os5DfSV5BW01viOw91CAOV3txPmnw4xsje5hnAeVb5YcXCvyP8hPSyFh)DSzXzb47nD1KqwwuKf7NsXsWxuKfGV3txPy5HSmDLIf4CQjw8eKLffzb47nD1KqwEileHOflAUg9c9lbXMf67bIyzzzyjsgJLJYYVJS0yKUUgbzzRucclpKLGtFwa(EtxnjKaaFVNUsXB4H)Gj14qKarqwaEFUUc1u6fye037PRuv7W8RtxPQW5utaC1cJWPF7QQf0o2BgjJvQYAOzu8R6WCrn)HTnrs1gRqPgZyZOsvwdntFnNM)kq7WoRGn6f6xcITH(EGOsnMrJrAwz91CAOV3txPmnw4xslvKjouluPQ7o9Xsz77kmFd9rLY7kyFZ3GPRRqWrAw5aeQaH2td99E6kLPXc)sAPImXHAHkvD3PpwQ3vy(g6JkL3vW(MVbtxxHGJ0SY6R50mxD0kCwr1krtJf(L0sr(rAlRVMtd99E6kLzznmeGqfi0EAOV3txPmnw4xshXBqUSmUuKfGV30vtczX(97SO5A0l0VeeBwEileHOflllw(DKf91CYI973HRNffKEjjwa(EpDLILL1FfilEcYYIISa89MUAsilWKfcMaSmE4wlnl03derzzL)PyHGz59Me(uEdp8hmPghIeicYsFVPRMeQPBgbaVpxxHgWg9IQ9tPQtxPQW5ulaVpxxHg6790vQQDy(1PRuv4CQ1waEFUUcnhPe2yL(EtxnjCyOS(Aon6UYZawHZQRu1F)ss0A6)Qrd99arBg5Hb91CA0DLNbScNvxPQ)(LKOvVdEIg67bI2mYJ0sTqLQ(EtcFQH(EpDLIqeSwaEFUUcn037PRuv7W8RtxPQW5K3GCzzCPilu7ExWcfYYV7plrHlwiHplfoHzzz9xbYIEuww0ljXY9S4uwu(JS4uwSGu6PRqwGjlkKsz539KLiZc99aruwGnlLySOpl23XKLitawOVhiIYcsyRRrEdp8hmPghIeicY6GU1FaWk1U3fAkenOW67nj8PrOHMUze2(xGOljP1wp8hmnoOB9haSsT7Drf0lCsO5Y6uDK2)Hbq4BCq36payLA37IkOx4Kqd99arekYAbHVXbDR)aGvQDVlQGEHtcnnw4xsjuK5nixwiOHZgP7SO5bH58AKLBYcX2kzhNmWYrzPrhmQMy53XgzXBKffsPS87EYc5z59Me(uwUKfYyLEZc5euNffzX(97Sae(KjnXIcPuw(DpzrJXyb(7yB)OilxYINrzHCcQZIISaBwwwS8qwiplV3KWNYIooHnYIZczSsVzHCcQZIIgw0CWC7NLgNns3zbC1xsILsCxc2iilKtHf0o2fy(SSsfsPSCjlaHkVzHCcQZII8gE4pysnoejqeKTacZ51OMcrdkS(EtcFAeAOPBgrJZgP7UUc1(EtcFZFfy9HvWd3SCzniycuMAHkv99Me(ud99EEnwkBkL(AonyqDwuSQwP3ML1OreOXc)s6iItzniW7kmFZB)YAbeMudMUUcbhPTSBvd7yGOHbaEFUUcnhPe2yL(EtxnjCyWwmOolkAUS6z0rAlhGqfi0EAcE9YGPrhmQwmOolkAUS6zuT2c2Rd0KWAaKQTmaVpxxHMambajcRGinAgggcqOceApnbycasew)DSsTU(EQPrhm6WGTbiam98n5rA)RthhnmqTqLQ(EtcFQH(EpVgju5YexnRS(AonyqDwuSQwP3MLvPSz0Osvwdc8UcZ382VSwaHj1GPRRqWrJ0AlguNffnuOY7AIe(1ABacvGq7Pj41ldMgDWOddLXG6SOO5YkfQ8EyqFnNgmOolkwvR0BZYsRTVRW8nu4svHZ6VJ1jSr6BW01vi4WG(Aonw9vaBWZvvVdEEHQ1sr92aWvlCZiSH8JnsBzQfQu13Bs4tn03751iH0ySsvwdc8UcZ382VSwaHj1GPRRqWrJ060VDv1cAh7nj)yAM(Aon037PRuMgl8lPLI4osBzBdqay65BikAFEomyR(AoneDjyJGvSWcAh7cm)kMyt6kjAwwddyqDwu0CzLcvEpsRT6R500oamHlAD2ywYOv6LZLQUhL(yFUzzXBqUSmUuKfYeClSatwcGSy)(D46zj4wwxsI3Wd)btQXHibIGStyhWkCwt)xnQPBgHBvd7yGOHbaEFUUcnhPe2yL(EtxnjK3Wd)btQXHibIGSa8(CDfQP0lWicG1ambV)Gz1HOMa4QfgHTG96anjSgaPAldW7Z1vOjawdWe8(dMAlRVMtd99E6kLzznm8UcZ3qFuP8Uc238ny66keCyiabGPNVjps7FD64iTGW3uaH58A08xGOljPTST6R50qHk6Fb0SS0AR(AonbVEzWSS0w223vy(M5QJwHZkQwjAW01vi4WG(AonbVEzWaUA)pyUzacvGq7PzU6Ov4SIQvIMgl8lPeisgPTSTu8R6WCrn)HTnrs1gRWWaguNffnxwvR07HbmOolkAOqL31ej8pslaVpxxHMFVpLQsrKiSR2971w22aeaME(M8iT)1PJddbiubcTNMambajcR)owPwxFp10yHFjLq6R50e86Lbd4Q9)GzPgZq(rAFVjHV5VcS(Wk4HBQVMttWRxgmGR2)dMLAmdzE0WGoKs1ops7FTXc)skH0xZPj41ldgWv7)btcOHnLQxjoHnj0y1xbSbpxv9o45fQwlf17r8gKllJlfzHm1ywYOSy)(Dwi2wj74KbEdp8hmPghIeicY2oamHlAD2ywYOA6MrOVMttWRxgmnw4xs3udYpmOVMttWRxgmGR2)dMeqdBkvVsCcBsOXQVcydEUQ6DWZluTwkQ3eYgIRwaEFUUcnbWAaMG3FWS6qK3GCzzCPileBRKDCYalWKLailRuHuklEcYI6sKL7zzzXI973zHyWeaKiK3Wd)btQXHibIGSbuH0)Cv1vhPSaZxt3mcaEFUUcnbWAaMG3FWS6quBz91CAcE9YGbC1(FWKaAytP6vItytcnw9vaBWZvvVdEEHQ1sr9EZiSH4omyBacatpFdam)9O9OHb91CAAhaMWfToBmlzuZYsR(AonTdat4IwNnMLmQPXc)skHkreiatW19gRgdhfRU6iLfy(M)kWkaxTqcu2w91CA0vqiOArFZYsRTVRW8n03BfSbny66keCeVHh(dMuJdrcebzVm4D6)btnDZia4956k0eaRbycE)bZQdrEdYLLXLISqofwq7yZY4HjilWKLail2VFNfGV3txPyzzXINGSqDailtyZcbzPOEZINGSqSTs2Xjd8gE4pysnoejqeKflSG2XUQdtqnDZikhGqfi0EAcE9YGPXc)skb0xZPj41ldgWv7)btc0ReNWMeAS6Ra2GNRQEh88cvRLI6DP0WMndqOceApnyHf0o2vDycAaxT)hmjGgJnAyqFnNMGxVmyASWVKUzKmma2Rd0KWAaKYBqUSqqdNns3zzQ8gzbMSSSy5HSezwEVjHpLf73VdxpleBRKDCYal64LKyX1HRNLhYcsyRRrw8eKLe(SabGDWTSUKeVHh(dMuJdrcebzPpQuExNkVrnfIguy99Me(0i0qt3mIgNns3DDfQ9VcS(Wk4HBQb51sTqLQ(EtcFQH(EpVgjebR1TQHDmqK2Y6R50e86LbtJf(L0n1ySHbB1xZPj41ldML1iEdYLLXLISqMGKdl3KLlPhiYINSqob1zrrw8eKf1Lil3ZYYIf73VZIZcbzPOEZIvddS4jilBf0T(daYcq7ExWB4H)Gj14qKarq25QJwHZkQwjQPBgbguNffnxw9mQ2YUvnSJbIggSTxjoHnj0y1xbSbpxv9o45fQwlf17rAlRVMtJvFfWg8Cv17GNxOATuuVnaC1cjKnKFSHb91CAcE9YGPXc)s6MrYiTLbHVXbDR)aGvQDVlQGEHtcn)fi6ssdd2gGaW0Z3KyOHkydomqTqLQ(EtcF6M2msBz91CAAhaMWfToBmlzutJf(LucvI0SYeCP6vItytcn0lNlvDpk9X(8rA1xZPPDaycx06SXSKrnlRHbB1xZPPDaycx06SXSKrnlRrAlBBacvGq7Pj41ldML1WG(Aon)EFkvLIiryBOVhiIqAqETZJ0(xBSWVKsiBgBmTZJ0(xBSWVKUPgJn2WGTu4sPFjO537tPQuejcBdMUUcbhPTmfUu6xcA(9(uQkfrIW2GPRRqWHHaeQaH2ttWRxgmnw4xs3mYJns77nj8n)vG1hwbpCtYpmOdPuTZJ0(xBSWVKsingJ3GCzzCPilolaFVNUsXIMFI)olwnmWYkviLYcW37PRuSCuwCvJoyuwwwSaBwIcxS4nYIRdxplpKfiaSdUflBLsq4n8WFWKACisGiil99E6kLMUze6R50at83PvlSdO1FW0SS0wwFnNg6790vktJZgP7UUchgC63UQAbTJ9MLOXgXBqUSO5wfwSSvkbHfDCcBKfIbtaqIqwSF)olaFVNUsXINGS87yYcW3B6QjH8gE4pysnoejqeKL(EpDLst3mIaeaME(M8iT)1PJAT9DfMVH(Os5DfSV5BW01viO2Ya8(CDfAcWeaKiScI0OzyyiaHkqO90e86LbZYAyqFnNMGxVmywwJ0gGqfi0EAcWeaKiS(7yLAD99utJf(LucrkaAkCcxQaEQYo9BxvTG2XM4q(XgPvFnNg6790vktJf(LucrWATfSxhOjH1aiL3Wd)btQXHibIGS03B6QjHA6MreGaW0Z3KhP9VoDuBzaEFUUcnbycasewbrA0mmmeGqfi0EAcE9YGzznmOVMttWRxgmlRrAdqOceApnbycasew)DSsTU(EQPXc)skHiVwaEFUUcn037PRuv7W8RtxPQW5ulguNffnxw9mQwBb4956k0CKsyJv67nD1KqT2c2Rd0KWAaKYBqUSmUuKfGV30vtczX(97S4jlA(j(7Sy1WalWMLBYsu4ABqwGaWo4wSSvkbHf73VZsu4Qzjrc)SeC6ByzRkkKfWvHflBLsqyXFw(DKfmbzboz53rwkXI5VhTzrFnNSCtwa(EpDLIf7WLcm3(zz6kflW5KfyZsu4IfVrwGjl2WY7nj8P8gE4pysnoejqeKL(Etxnjut3mc91CAGj(70AqHExbC0dMML1WqzBPV3ZRrJBvd7yGiT2cW7Z1vO5iLWgR03B6QjHddL1xZPj41ldMgl8lPeI8A1xZPj41ldML1Wq5Y6R50e86LbtJf(LucrkaAkCcxQaEQYo9BxvTG2XM4aW7Z1vOHsRbi9hPvFnNMGxVmywwdd6R500oamHlAD2ywYOv6LZLQUhL(yFUPXc)skHifanfoHlvapvzN(TRQwq7ytCa4956k0qP1aK(J0QVMtt7aWeUO1zJzjJwPxoxQ6Eu6J95ML1iTbiam98naW83J2JgPTm1cvQ67nj8Pg6790vkcf5HbaEFUUcn037PRuv7W8RtxPQW5C0iT2cW7Z1vO5iLWgR03B6QjHAlBBVsCcBsO5Vc0oSZkyJEH(LGypmqTqLQ(EtcFQH(EpDLIqrEeVb5YY4srw08GWKYYLSaeQ8MfYjOolkYINGSqDailKPLsXIMheMSmHnleBRKDCYaVHh(dMuJdrcebzt0ETactnDZikRVMtdguNffRuOYBtJf(L0nrcJH1J1)kWHHYHDVjH0iSrBJHDVjH1)kqcr(rddHDVjH0iI8iTUvnSJbI4n8WFWKACisGii7URM1cim10nJOS(AonyqDwuSsHkVnnw4xs3ejmgwpw)Rahgkh29MesJWgTng29Mew)Raje5hnme29MesJiYJ06w1WogisBz91CAAhaMWfToBmlzutJf(LucrET6R500oamHlAD2ywYOMLLwB7vItytcn0lNlvDpk9X(8HbB1xZPPDaycx06SXSKrnlRr8gE4pysnoejqeKDUuQAbeMA6MruwFnNgmOolkwPqL3Mgl8lPBIegdRhR)vGAlhGqfi0EAcE9YGPXc)s6MKFSHHaeQaH2ttaMaGeH1FhRuRRVNAASWVKUj5hB0Wq5WU3KqAe2OTXWU3KW6FfiHi)OHHWU3KqAerEKw3Qg2XarAlRVMtt7aWeUO1zJzjJAASWVKsiYRvFnNM2bGjCrRZgZsg1SS0ABVsCcBsOHE5CPQ7rPp2NpmyR(AonTdat4IwNnMLmQzznI3GCzzCPileuqYHfyYcX0C8gE4pysnoejqeK1U39b7kCwr1krEdYLfI5QWs5pszX(o(7yZYdzzrrwa(EpVgz5swacvEZI99lSZYrzXFwiplV3KWNsanyzcBwqayhLfBgJ4WsHtFSJYcSzHGzb47nD1KqwiNclODSlW8zH(EGikVHh(dMuJdrcebzb4956kutPxGrqFVNxJ1lRuOYBnbWvlmcQfQu13Bs4tn037514MembMkiSlx40h7OvaUAHLsJXgJ4yZyJiWubHDz91CAOV30vtcRyHf0o2fy(vku5TH(EGiIdbpI3GCzHyUkSu(JuwSVJ)o2S8qwiOA)3zbC1xsIfYuJzjJYB4H)Gj14qKarqwaEFUUc1u6fye2B)3RxwNnMLmQMa4QfgHgehQfQu1DN(iHSrZkpMXMsvMAHkv99Me(ud99EEnQzAmQuL1GaVRW8nu4svHZ6VJ1jSr6BW01viyP0Wq(rJiWygniFP0xZPPDaycx06SXSKrnnw4xs5nixwgxkYcbv7)olxYcqOYBwiNG6SOilWMLBYsczb4798AKf7NsXY8EwU8HSqSTs2XjdS4z0cyJ8gE4pysnoejqeK1E7)UMUzeLXG6SOOrTsVRjs4FyadQZIIgpJwtKWVwaEFUUcnhTguOdahPT87nj8n)vG1hwbpCtcEyadQZIIg1k9UEz1MHbDiLQDEK2)AJf(LucPXyJgg0xZPbdQZIIvku5TPXc)skH8WFW0qFVNxJgKWyy9y9VcuR(AonyqDwuSsHkVnlRHbmOolkAUSsHkV1AlaVpxxHg6798ASEzLcvEpmOVMttWRxgmnw4xsjKh(dMg6798A0GegdRhR)vGATfG3NRRqZrRbf6aqT6R50e86LbtJf(LucHegdRhR)vGA1xZPj41ldML1WG(AonTdat4IwNnMLmQzzPfG3NRRqJ92)96L1zJzjJomylaVpxxHMJwdk0bGA1xZPj41ldMgl8lPBIegdRhR)vG8gKllJlfzb4798AKLBYYLSqgR0BwiNG6SOOMy5swacvEZc5euNffzbMSqWeGL3Bs4tzb2S8qwSAyGfGqL3Sqob1zrrEdp8hmPghIeicYsFVNxJ8gKllKjxP(9EXB4H)Gj14qKarq2ELvp8hmRQJ(Ak9cmIPRu)EV4n4nixwa(EtxnjKLjSzPacalW8zzLkKszzrVKelJhU1sZB4H)Gj1mDL637ve03B6QjHA6MryBVsCcBsOr3vEgWkCwDLQ(7xsIAWiDDwwiiVb5YcXC6ZYVJSacFwSF)ol)oYsbK(S8xbYYdzXbbzzL)Py53rwkCcZc4Q9)GjlhLL97nSaCLZRrwASWVKYsXs9NL6qqwEilf(h2zPacZ51ilGR2)dM8gE4pysntxP(9ErGiilDLZRrnfIguy99Me(0i0qt3mcq4BkGWCEnAASWVKUzJf(L0szJnehnIeEdp8hmPMPRu)EViqeKTacZ51iVbVb5YY4srw2kOB9haKfG29UGf77yYYVJnYYrzjHS4H)aGSqT7DHMyXPSO8hzXPSybP0txHSatwO29UGf73VZInSaBwMODSzH(EGiklWMfyYIZsKjalu7ExWcfYYV7pl)oYsI2zHA37cw8UpaiLLsmw0NfF(yZYV7plu7ExWcsyRRrkVHh(dMud9JWbDR)aGvQDVl0uiAqH13Bs4tJqdnDZiSfe(gh0T(dawP29UOc6foj08xGOljP1wp8hmnoOB9haSsT7Drf0lCsO5Y6uDK2FTLTfe(gh0T(dawP29UOUJUY8xGOljnmacFJd6w)baRu7Exu3rxzASWVKUj5hnmacFJd6w)baRu7Exub9cNeAOVhiIqrwli8noOB9haSsT7Drf0lCsOPXc)skHISwq4BCq36payLA37IkOx4KqZFbIUKeVb5YY4srkledMaGeHSCtwi2wj74KbwoklllwGnlrHlw8gzbePrZWLKyHyBLSJtgyX(97SqmycaseYINGSefUyXBKfDubTZcbpgzJ8yLjgQq6FUIfGwxFpDelBLsqy5swCw0ymcWcfdSqob1zrrdlBvrHSacZTFwu4ZIMRrVq)sqSzbjS11OMyXv29OuwwuKLlzHyBLSJtgyX(97SqqwkQ3S4jil(ZYVJSqFVFwGtwCwgpCRLMf7xccTB4n8WFWKAOpbIGSbycasew)DSsTU(EQMUze2c2Rd0KWAaKQTCzaEFUUcnbycasewbrA0mO12aeQaH2ttWRxgmn6Gr1ABVsCcBsOXQVcydEUQ6DWZluTwkQ3dd6R50e86LbZYAK2YLD63UQAbTJnHIaG3NRRqtaMaGeHvNAPTS(AonyqDwuSQwP3Mgl8lPBQXydd6R50Gb1zrXkfQ820yHFjDtngB0WG(AonbVEzW0yHFjDtYRvFnNMGxVmyASWVKsOi0WMrAlBBVsCcBsO5Vc0oSZkyJEH(LGypmyBVsCcBsOjGkK(NRQuRRVNomOVMtZFfODyNvWg9c9lbX20yHFjDtKWyy9y9VcC0WqVsCcBsOr3vEgWkCwDLQ(7xsIosBzB7vItytcn6UYZawHZQRu1F)ss0HHY6R50O7kpdyfoRUsv)9ljrRP)Rgn03defrKmmOVMtJUR8mGv4S6kv93VKeT6DWt0qFpquerYOrdd6qkv78iT)1gl8lPesJX0ABacvGq7Pj41ldMgDWOJ4nixwgxkYcW3B6QjHS8qwicrlwwwS87ilAUg9c9lbXMf91CYYnz5EwSdxkqwqcBDnYIooHnYY8YJUFjjw(DKLej8ZsWPplWMLhYc4QWIfDCcBKfIbtaqIqEdp8hmPg6tGiil99MUAsOMUze9kXjSjHM)kq7WoRGn6f6xcIT2Y2wUS(Aon)vG2HDwbB0l0VeeBtJf(L0n9WFW0yV9F3GegdRhR)vGeymJgAlJb1zrrZLvD4VpmGb1zrrZLvku59WaguNffnQv6Dnrc)Jgg0xZP5Vc0oSZkyJEH(LGyBASWVKUPh(dMg6798A0GegdRhR)vGeymJgAlJb1zrrZLv1k9EyadQZIIgku5Dnrc)ddyqDwu04z0AIe(hnAyWw91CA(RaTd7Sc2OxOFji2ML1OHHY6R50e86LbZYAyaG3NRRqtaMaGeHvqKgndJ0gGqfi0EAcWeaKiS(7yLAD99utJoyuTbiam98n5rA)Rth1wwFnNgmOolkwvR0BtJf(L0n1ySHb91CAWG6SOyLcvEBASWVKUPgJnAK2Y2gGaW0Z3qu0(8CyiaHkqO90Gfwq7yx1HjOPXc)s6MrYiEdYLfn3QWIfGV30vtcPSy)(DwgVR8mGSaNSSvLILsVFjjklWMLhYIvJwEJSmHnledMaGeHSy)(DwgpCRLM3Wd)btQH(eicYsFVPRMeQPBgrVsCcBsOr3vEgWkCwDLQ(7xsIQTCz91CA0DLNbScNvxPQ)(LKO10)vJg67bI20MHb91CA0DLNbScNvxPQ)(LKOvVdEIg67bI20MrAdqOceApnbVEzW0yHFjDtYSwBdqOceApnbycasew)DSsTU(EQzznmuoabGPNVjps7FD6O2aeQaH2ttaMaGeH1FhRuRRVNAASWVKsingtlguNffnxw9mQwN(TRQwq7yVPnJrGipwPcqOceApnbVEzW0OdgD0iEdYLfIbtW7pyYYe2S4kflGWNYYV7plforiLf6Qrw(DmklEJ52plnoBKUJGSyFhtwiO5aWeUOSqMAmlzuw2DklkKsz539KfYZcfduwASWV8ssSaBw(DKfYPWcAhBwgpmbzrFnNSCuwCD46z5HSmDLIf4CYcSzXZOSqob1zrrwoklUoC9S8qwqcBDnYB4H)Gj1qFcebzb4956kutPxGrac)AJr66ASaZNQjaUAHruwFnNM2bGjCrRZgZsg10yHFjDtYpmyR(AonTdat4IwNnMLmQzznsRT6R500oamHlAD2ywYOv6LZLQUhL(yFUzzPTS(AoneDjyJGvSWcAh7cm)kMyt6kjAASWVKsisbqtHt4rAlRVMtdguNffRuOYBtJf(L0njfanfoHhg0xZPbdQZIIv1k920yHFjDtsbqtHt4HHY2QVMtdguNffRQv6TzznmyR(AonyqDwuSsHkVnlRrAT9DfMVHcv0)cObtxxHGJ4nixwigmbV)Gjl)U)Se2XaruwUjlrHlw8gzbUE6bISGb1zrrwEilWufLfq4ZYVJnYcSz5iLWgz53pkl2VFNfGqf9VaYB4H)Gj1qFcebzb4956kutPxGrac)kC90deRyqDwuutaC1cJOST6R50Gb1zrXkfQ82SS0AR(AonyqDwuSQwP3ML1iT2(UcZ3qHk6Fb0GPRRqqT22ReNWMeA(RaTd7Sc2OxOFji28gKllAo4ZIRuS8EtcFkl2VF)swiiEcIfxGf73VdxplqayhClRljrGFhzX1HaqwcWe8(dMuEdp8hmPg6tGiiBbeMZRrnfIguy99Me(0i0qt3mIY6R50Gb1zrXkfQ820yHFjDZgl8lPdd6R50Gb1zrXQALEBASWVKUzJf(L0HbaEFUUcnGWVcxp9aXkguNffhPTXzJ0DxxHAFVjHV5VcS(Wk4HBQHnADRAyhdePfG3NRRqdi8RngPRRXcmFkVHh(dMud9jqeKLUY51OMcrdkS(EtcFAeAOPBgrz91CAWG6SOyLcvEBASWVKUzJf(L0Hb91CAWG6SOyvTsVnnw4xs3SXc)s6WaaVpxxHgq4xHRNEGyfdQZIIJ024Sr6URRqTV3KW38xbwFyf8Wn1WgTUvnSJbI0cW7Z1vObe(1gJ011ybMpL3Wd)btQH(eicYsFuP8UovEJAkenOW67nj8PrOHMUzeL1xZPbdQZIIvku5TPXc)s6Mnw4xshg0xZPbdQZIIv1k920yHFjDZgl8lPdda8(CDfAaHFfUE6bIvmOolkosBJZgP7UUc1(EtcFZFfy9HvWd3udIRw3Qg2XarAb4956k0ac)AJr66ASaZNYBqUSO5Gpl9rA)zrhNWgzHm1ywYOSCtwUNf7WLcKfxPG2zjkCXYdzPXzJ0DwuiLYc4QVKelKPgZsgLLY)(rzbMQOSS7wwyszX(97W1ZcWlNlfle0hL(yF(iEdp8hmPg6tGiilaVpxxHAk9cmIew3JsFSpVIERIwbHVMa4QfgracatpFdam)9OTwB7vItytcn0lNlvDpk9X(CT22ReNWMeAcxhuyfoRQBIvpbRGO)7AdqOceApn6ytXMOljzA0bJQnaHkqO900oamHlAD2ywYOMgDWOATvFnNMGxVmywwAl70VDv1cAh7nJeY8WG(Aon6kieuTOVzznI3Wd)btQH(eicYwaH58Aut3mcaEFUUcnjSUhL(yFEf9wfTccFTnw4xsjKnJXB4H)Gj1qFcebzPRCEnQPBgbaVpxxHMew3JsFSpVIERIwbHV2gl8lPesJseVb5YY4srwitWTWcmzjaYI973HRNLGBzDjjEdp8hmPg6tGii7e2bScN10)vJA6Mr4w1WogiI3GCzzCPilKtHf0o2SmEycYI973zXZOSOGjjwWeUiTZIYP)LKyHCcQZIIS4jilFhLLhYI6sKL7zzzXI973zHGSuuVzXtqwi2wj74KbEdp8hmPg6tGiilwybTJDvhMGA6MruoaHkqO90e86LbtJf(LucOVMttWRxgmGR2)dMeOxjoHnj0y1xbSbpxv9o45fQwlf17sPHnBgGqfi0EAWclODSR6We0aUA)pysangB0WG(AonbVEzW0yHFjDZizyaSxhOjH1aiL3GCzbi(uwSVJjlBLsqyHUdxkqw0rwaxfwiilpKLe(SabGDWTyPSMdTWeKYcmzHmT6OSaNSqoQvIS4jil)oYc5euNffhXB4H)Gj1qFcebzb4956kutPxGr4uRk4QWstaC1cJWPF7QQf0o2BwIgtZkBJH8LsFnNM5QJwHZkQwjAOVhisZSPuyqDwu0CzvTsVhXBqUSmUuKfITvYoozGf73VZcXGjairizlXDjyJGSa0667PS4jilGWC7NfiaST33JSqqwkQ3SaBwSVJjlJxbHGQf9zXoCPazbjS11il64e2ileBRKDCYaliHTUgPgw08CIqwORgz5HSG5JnlolKXk9MfYjOolkYI9DmzzrpsjlL2MiHfBScS4jilUsXcX0CuwSFkfl6yawGS0OdgLfkeMSGjCrANfWvFjjw(DKf91CYINGSacFkl7oaKfDetwOR58chMVkklnoBKUJGgEdp8hmPg6tGiilaVpxxHAk9cmIaynatW7pywPVMa4QfgHTG96anjSgaPAldW7Z1vOjawdWe8(dMATvFnNMGxVmywwAlBlf)QomxuZFyBtKuTXkmmGb1zrrZLv1k9EyadQZIIgku5Dnrc)J0wUCzaEFUUcno1QcUkSggcqay65BYJ0(xNoomuoabGPNVHOO95P2aeQaH2tdwybTJDvhMGMgDWOJgg6vItytcn)vG2HDwbB0l0Vee7rAbHVHUY51OPXc)s6MrIwq4BkGWCEnAASWVKUzjsBzq4BOpQuExNkVrtJf(L0n1ySHbBFxH5BOpQuExNkVrdMUUcbhPfG3NRRqZV3NsvPise2v7(9AFVjHV5VcS(Wk4HBQVMttWRxgmGR2)dMLAmdzEyqFnNgDfecQw03SS0QVMtJUccbvl6BASWVKsi91CAcE9YGbC1(FWKaL1WMs1ReNWMeAS6Ra2GNRQEh88cvRLI69OrddLXiDDwwiOblSI2ORQWgm9mGAdqOceApnyHv0gDvf2GPNb00yHFjLqAqCjZeOm5lvVsCcBsOHE5CPQ7rPp2NpA0iTLTnabGPNVjps7FD64Wq5aeQaH2ttaMaGeH1FhRuRRVNAASWVKsi91CAcE9YGbC1(FWK4yJwB7vItytcn6UYZawHZQRu1F)ss0HHaeQaH2ttaMaGeH1FhRuRRVNAA0bJQ1PF7QQf0o2eI8JnAyqhsPANhP9V2yHFjLqbiubcTNMambajcR)owPwxFp10yHFjD0WGoKs1ops7FTXc)skH0xZPj41ldgWv7)btcOHnLQxjoHnj0y1xbSbpxv9o45fQwlf17r8gKllJlfzHm1ywYOSy)(Dwi2wj74KbwwPcPuwitnMLmkl2HlfilkN(SOGjjSz539KfITvYoozqtS87yYYIISOJtyJ8gE4pysn0Narq22bGjCrRZgZsgvt3mc91CAcE9YGPXc)s6MAq(Hb91CAcE9YGbC1(FWKq2qMjqVsCcBsOXQVcydEUQ6DWZluTwkQ3LsdB0cW7Z1vOjawdWe8(dMv6ZB4H)Gj1qFcebzdOcP)5QQRoszbMVMUzea8(CDfAcG1ambV)GzL(AlRVMttWRxgmGR2)dMBgHnKzc0ReNWMeAS6Ra2GNRQEh88cvRLI6DP0WMHbBdqay65BaG5VhThnmOVMtt7aWeUO1zJzjJAwwA1xZPPDaycx06SXSKrnnw4xsjujIabycUU3y1y4Oy1vhPSaZ38xbwb4QfsGY2QVMtJUccbvl6BwwAT9DfMVH(ERGnObtxxHGJ4n8WFWKAOpbIGSxg8o9)GPMUzea8(CDfAcG1ambV)GzL(8gKllLy9(CDfYYIIGSatwC9tD)Huw(D)zXUNplpKfDKfQdabzzcBwi2wj74KbwOqw(D)z53XOS4nMpl2D6JGSuIXI(SOJtyJS87ybVHh(dMud9jqeKfG3NRRqnLEbgb1bG1jSRbVEzqtaC1cJiaHkqO90e86LbtJf(L0n1ySHbBb4956k0eGjairyfePrZG2aeaME(M8iT)1PJddG96anjSgaP8gKllJlfPSqMGKdl3KLlzXtwiNG6SOilEcYY3hsz5HSOUez5EwwwSy)(Dwiilf1BnXcX2kzhNmOjwiNclODSzz8WeKfpbzzRGU1FaqwaA37cEdp8hmPg6tGii7C1rRWzfvRe10nJadQZIIMlREgvBzN(TRQwq7ytOsKnAM(AonZvhTcNvuTs0qFpquPi)WG(AonTdat4IwNnMLmQzznsBz91CAS6Ra2GNRQEh88cvRLI6TbGRwiHSHGhByqFnNMGxVmyASWVKUzKmslaVpxxHgQdaRtyxdE9YG2Y2gGaW0Z3KyOHkydomacFJd6w)baRu7Exub9cNeA(lq0LKgPTSTbiam98naW83J2dd6R500oamHlAD2ywYOMgl8lPeQePzLj4s1ReNWMeAOxoxQ6Eu6J95J0QVMtt7aWeUO1zJzjJAwwdd2QVMtt7aWeUO1zJzjJAwwJ0w22aeaME(gII2NNddbiubcTNgSWcAh7Qombnnw4xs30MXgP99Me(M)kW6dRGhUj5hg0HuQ25rA)Rnw4xsjKgJXBqUSmUuKfn)e)Dwa(EpDLIfRggOSCtwa(EpDLILJMB)SSS4n8WFWKAOpbIGS037PRuA6MrOVMtdmXFNwTWoGw)btZYsR(Aon037PRuMgNns3DDfYBqUSqmpdOIfGV3kydYYnz5Ew2DklkKsz539KfYtzPXc)YljPjwIcxS4nYI)SuIgJaSSvkbHfpbz53rwcRUX8zHCcQZIISS7uwipbOS0yHF5LK4n8WFWKAOpbIGSbpdOQQVMtnLEbgb99wbBqnDZi0xZPH(ERGnOPXc)skHiV2Y6R50Gb1zrXkfQ820yHFjDtYpmOVMtdguNffRQv6TPXc)s6MKFKwN(TRQwq7yVzjAmEdYLfI5zavS87ileKLI6nl6R5KLBYYVJSy1Wal2HlfyU9ZI6sKLLfl2VFNLFhzjrc)S8xbYcXGjairilbybszboNSeanSu69JYYIUCLkklWufLLD3YctklGR(ssS87ilJNmm8gE4pysn0Narq2GNbuv1xZPMsVaJWQVcydEUQ6DWZluTwkQ3A6Mr8UcZ3CzW70)dMgmDDfcQ123vy(MeTxlGW0GPRRqqTL4vUCKhBmnZPF7QQf0o2eGGhtZO4x1H5IA(dBBIKQnwHsrWJnI4uMGjouluPQ7o9XrAwacvGq7PjataqIW6VJvQ113tnnw4xshrOs8kxoYJnMM50VDv1cAhBntFnNgR(kGn45QQ3bpVq1APOEBa4QfsacEmnJIFvhMlQ5pSTjsQ2yfkfbp2iItzcM4qTqLQU70hhPzbiubcTNMambajcR)owPwxFp10yHFjDK2aeQaH2ttWRxgmnw4xs3mYJPvFnNgR(kGn45QQ3bpVq1APOEBa4QfsiB0ymT6R50y1xbSbpxv9o45fQwlf1BdaxTWnJ8yAdqOceApnbycasew)DSsTU(EQPXc)skHi4X0ops7FTXc)s6MbiubcTNMambajcR)owPwxFp10yHFjLaexTL7vItytcnbuH0)CvLAD990HbaEFUUcnbycasewbrA0mmI3GCzbi(uwSVJjleKLI6nl0D4sbYIoYIvddbeKf0BvuwEil6ilUUcz5HSSOiledMaGeHSatwcqOceApzPm5qPy(NRurzrhdWcKYY3lKLBYc4QW6ssSSvkbHLeANf7NsXIRuq7SefUy5HSyH9edVkkly(yZcbzPOEZINGS87yYYIISqmycaseoI3Wd)btQH(eicYcW7Z1vOMsVaJWQHHQ1sr9UIERIQjaUAHreGaW0Z3KhP9VoDuBVsCcBsOXQVcydEUQ6DWZluTwkQ3A1xZPXQVcydEUQ6DWZluTwkQ3gaUAHeWPF7QQf0o2eiYBgrKhBmTa8(CDfAcWeaKiScI0OzqBacvGq7PjataqIW6VJvQ113tnnw4xsjKt)2vvlODSjorESsrkaAkCcR1wWEDGMewdGuTyqDwu0Cz1ZOAD63UQAbTJ9Ma8(CDfAcWeaKiS6ulTbiubcTNMGxVmyASWVKUj55nixwgxkYcW37PRuSy)(Dwa(Os5nlAU(MplWML3MiHfc2kWINGSKqwa(ERGnOMyX(oMSKqwa(EpDLILJYYYIfyZYdzXQHbwiilf1BwSVJjlUoeaYsjAmw2kLGug2S87ilO3QOSqqwkQ3Sy1Wala8(CDfYYrz57foIfyZIdA5)bazHA37cw2DklrcbOyGYsJf(LxsIfyZYrz5swMQJ0(ZB4H)Gj1qFcebzPV3txP00nJO87kmFd9rLY7kyFZ3GPRRqWHbk(vDyUOM)W2MiPsWwHrAT9DfMVH(ERGnObtxxHGA1xZPH(EpDLY04Sr6URRqT22ReNWMeA(RaTd7Sc2OxOFji2AlRVMtJvFfWg8Cv17GNxOATuuVnaC1c3mcBi)yATvFnNMGxVmywwAldW7Z1vOXPwvWvH1WG(AoneDjyJGvSWcAh7cm)kMyt6kjAwwdda8(CDfASAyOATuuVRO3QOJggkhGaW0Z3KyOHkydQ9DfMVH(Os5DfSV5BW01viO2YGW34GU1FaWk1U3fvqVWjHMgl8lPBgjddE4pyACq36payLA37IkOx4KqZL1P6iT)JgnsB5aeQaH2ttWRxgmnw4xs3uJXggcqOceApnbycasew)DSsTU(EQPXc)s6MAm2iEdYLfn3QWIYYwPeew0XjSrwigmbajczzrVKel)oYcXGjairilbycE)btwEilHDmqel3KfIbtaqIqwoklE4xUsfLfxhUEwEil6ilbN(8gE4pysn0Narqw67nD1KqnDZia4956k0y1Wq1APOExrVvr5nixwgxkYIMheMuwSVJjlrHlw8gzX1HRNLhswVrwcUL1LKyjS7njKYINGSu4eHSqxnYYVJrzXBKLlzXtwiNG6SOil0)ukwMWMfc618ilzsZJ3Wd)btQH(eicYMO9AbeMA6Mr4w1WogisB5WU3KqAe2OTXWU3KW6FfiHi)Wqy3BsinIipI3Wd)btQH(eicYU7QzTactnDZiCRAyhdePTCy3BsincB02yy3Bsy9VcKqKFyiS7njKgrKhPTS(AonyqDwuSQwP3Mgl8lPBIegdRhR)vGdd6R50Gb1zrXkfQ820yHFjDtKWyy9y9VcCeVHh(dMud9jqeKDUuQAbeMA6Mr4w1WogisB5WU3KqAe2OTXWU3KW6FfiHi)Wqy3BsinIipsBz91CAWG6SOyvTsVnnw4xs3ejmgwpw)Rahg0xZPbdQZIIvku5TPXc)s6MiHXW6X6Ff4iEdYLLXLISa89MUAsilA(j(7Sy1WaLfpbzbCvyXYwPeewSVJjleBRKDCYGMyHCkSG2XMLXdtqnXYVJSuIfZFpAZI(Aoz5OS46W1ZYdzz6kflW5KfyZsu4ABqwcUflBLsq4n8WFWKAOpbIGS03B6QjHA6MrGb1zrrZLvpJQTS(AonWe)DAnOqVRao6btZYAyqFnNgIUeSrWkwybTJDbMFftSjDLenlRHb91CAcE9YGzzPTSTbiam98nefTpphgcqOceApnyHf0o2vDycAASWVKUj5hg0xZPj41ldMgl8lPeIua0u4eUutfe2LD63UQAbTJnXbG3NRRqdLwdq6pAK2Y2gGaW0Z3aaZFpApmOVMtt7aWeUO1zJzjJAASWVKsisbqtHt4sfWtvUSt)2vvlODSjabpwPExH5BMRoAfoROALObtxxHGJioa8(CDfAO0Aas)reiYL6DfMVjr71cimny66keuRT9kXjSjHg6LZLQUhL(yFUw91CAAhaMWfToBmlzuZYAyqFnNM2bGjCrRZgZsgTsVCUu19O0h7ZnlRHHY6R500oamHlAD2ywYOMgl8lPeYd)btd99EEnAqcJH1J1)kqTuluPQ7o9rcnMHGhg0xZPPDaycx06SXSKrnnw4xsjKh(dMg7T)7gKWyy9y9VcCyaG3NRRqZfPG1ambV)GP2aeQaH2tZL0qVExxH1iD55VkQGiGlGMgDWOAXiDDwwiO5sAOxVRRWAKU88xfvqeWfWrA1xZPPDaycx06SXSKrnlRHbB1xZPPDaycx06SXSKrnllT2gGqfi0EAAhaMWfToBmlzutJoy0rdda8(CDfACQvfCvynmOdPuTZJ0(xBSWVKsisbqtHt4sfWtv2PF7QQf0o2ehaEFUUcnuAnaP)Or8gKllLUJYYdzPWjcz53rw0r6ZcCYcW3BfSbzrpkl03deDjjwUNLLflr66cePIYYLS4zuwiNG6SOil6RNfcYsr9MLJMB)S46W1ZYdzrhzXQHHacYB4H)Gj1qFcebzPV30vtc10nJ4DfMVH(ERGnObtxxHGATTxjoHnj08xbAh2zfSrVq)sqS1wwFnNg67Tc2GML1WGt)2vvlODS3Sen2iT6R50qFVvWg0qFpqeHIS2Y6R50Gb1zrXkfQ82SSgg0xZPbdQZIIv1k92SSgPvFnNgR(kGn45QQ3bpVq1APOEBa4QfsiBiZJPTCacvGq7Pj41ldMgl8lPBQXydd2cW7Z1vOjataqIWkisJMbTbiam98n5rA)RthhXBqUSqo0)k8hPSSdTZsXkSZYwPeew8gzHKFjcYIf2SqXambnSO5NQOS8oriLfNfA6w0D4ZYe2S87ilHv3y(SqVF5)btwOqwSdxkWC7NfDKfpewT)iltyZIYBsyZYFf4S9cKYB4H)Gj1qFcebzb4956kutPxGr4ulcc2aXGMa4QfgbguNffnxwvR07sfjehp8hmn03751Objmgwpw)RajGTyqDwu0CzvTsVlvzIlbExH5BOWLQcN1FhRtyJ03GPRRqWsf5rehp8hmn2B)3niHXW6X6FfibgZqWKN4qTqLQU70hjWygYxQ3vy(M0)vJ0QUR8mGgmDDfcYBqUSO5wfwSa89MUAsilxYINSqob1zrrwCkluimzXPSybP0txHS4uwuWKeloLLOWfl2pLIfmbzzzXI973zjsgJaSyFhtwW8X(ssS87iljs4NfYjOolkQjwaH52plk8z5EwSAyGfcYsr9wtSacZTFwGaW2EFpYINSO5N4VZIvddS4jilwqOIfDCcBKfITvYoozGfpbzHCkSG2XMLXdtqEdp8hmPg6tGiil99MUAsOMUze22ReNWMeA(RaTd7Sc2OxOFji2AlRVMtJvFfWg8Cv17GNxOATuuVnaC1cjKnK5Xgg0xZPXQVcydEUQ6DWZluTwkQ3gaUAHeYgYpM23vy(g6JkL3vW(MVbtxxHGJ0wgdQZIIMlRuOYBTo9BxvTG2XMaa8(CDfACQfbbBGyOu6R50Gb1zrXkfQ820yHFjLaGW3mxD0kCwr1krZFbIO1gl8llLngYVzKm2WaguNffnxwvR0BTo9BxvTG2XMaa8(CDfACQfbbBGyOu6R50Gb1zrXQALEBASWVKsaq4BMRoAfoROALO5Var0AJf(LLYgd53Sen2iT2QVMtdmXFNwTWoGw)btZYsRTVRW8n03BfSbny66keuB5aeQaH2ttWRxgmnw4xs3KmpmqHlL(LGMFVpLQsrKiSny66keuR(Aon)EFkvLIiryBOVhiIqroYAw5EL4e2Kqd9Y5sv3JsFSpVu2ms78iT)1gl8lPBQXyJPDEK2)AJf(LuczZyJnma2Rd0KWAaKosBzBdqay65BikAFEomeGqfi0EAWclODSR6We00yHFjDtBgXBqUSmUuKfnpimPSCjlEgLfYjOolkYINGSqDaile07QjbitlLIfnpimzzcBwi2wj74Kbw8eKLsCxc2iilKtHf0o2fy(gw2QIczzrrw2IMhlEcYczsZJf)z53rwWeKf4KfYuJzjJYINGSacZTFwu4ZIMRrVq)sqSzz6kflW5K3Wd)btQH(eicYMO9AbeMA6Mr4w1WogislaVpxxHgQdaRtyxdE9YG2Y6R50Gb1zrXQALEBASWVKUjsymSES(xbomOVMtdguNffRuOYBtJf(L0nrcJH1J1)kWr8gE4pysn0Narq2DxnRfqyQPBgHBvd7yGiTa8(CDfAOoaSoHDn41ldAlRVMtdguNffRQv6TPXc)s6MiHXW6X6Ff4WG(AonyqDwuSsHkVnnw4xs3ejmgwpw)RahPTS(AonbVEzWSSgg0xZPXQVcydEUQ6DWZluTwkQ3gaUAHekcB0ySrAlBBacatpFdam)9O9WG(AonTdat4IwNnMLmQPXc)skHktEnZMs1ReNWMeAOxoxQ6Eu6J95J0QVMtt7aWeUO1zJzjJAwwdd2QVMtt7aWeUO1zJzjJAwwJ0w22EL4e2KqZFfODyNvWg9c9lbXEyajmgwpw)RajK(Aon)vG2HDwbB0l0VeeBtJf(L0HbB1xZP5Vc0oSZkyJEH(LGyBwwJ4n8WFWKAOpbIGSZLsvlGWut3mc3Qg2XarAb4956k0qDayDc7AWRxg0wwFnNgmOolkwvR0BtJf(L0nrcJH1J1)kWHb91CAWG6SOyLcvEBASWVKUjsymSES(xbosBz91CAcE9YGzznmOVMtJvFfWg8Cv17GNxOATuuVnaC1cjue2OXyJ0w22aeaME(gII2NNdd6R50q0LGncwXclODSlW8RyInPRKOzznsBzBdqay65BaG5VhThg0xZPPDaycx06SXSKrnnw4xsje51QVMtt7aWeUO1zJzjJAwwATTxjoHnj0qVCUu19O0h7ZhgSvFnNM2bGjCrRZgZsg1SSgPTST9kXjSjHM)kq7WoRGn6f6xcI9WasymSES(xbsi91CA(RaTd7Sc2OxOFji2Mgl8lPdd2QVMtZFfODyNvWg9c9lbX2SSgXBqUSmUuKfcki5WcmzjaYB4H)Gj1qFcebzT7DFWUcNvuTsK3GCzzCPilaFVNxJS8qwSAyGfGqL3Sqob1zrrnXcX2kzhNmWYUtzrHukl)vGS87EYIZcbv7)oliHXW6rwu48zb2SatvuwiJv6nlKtqDwuKLJYYYYWcb197SuABIewSXkWcMp2S4SaeQ8MfYjOolkYYnzHGSuuVzH(NsXYUtzrHukl)UNSyJgJXc99aruw8eKfITvYoozGfpbzHyWeaKiKLDhaYsbSrw(DpzrdYmLfIP5yPXc)YljzyzCPilUoeaYInKFmIdl7o9rwax9LKyHm1ywYOS4jil2yJnehw2D6JSy)(D46zHm1ywYO8gE4pysn0Narqw6798Aut3mcmOolkAUSQwP3ATvFnNM2bGjCrRZgZsg1SSggWG6SOOHcvExtKW)WqzmOolkA8mAnrc)dd6R50e86LbtJf(Luc5H)GPXE7)Ubjmgwpw)Ra1QVMttWRxgmlRrAlBlf)QomxuZFyBtKuTXkmm0ReNWMeAS6Ra2GNRQEh88cvRLI6Tw91CAS6Ra2GNRQEh88cvRLI6TbGRwiHSrJX0gGqfi0EAcE9YGPXc)s6MAqM1w22aeaME(M8iT)1PJddbiubcTNMambajcR)owPwxFp10yHFjDtniZJ0w222dO5BOsnmeGqfi0EA0XMInrxsY0yHFjDtniZJgnmGb1zrrZLvpJQTS(Aon29UpyxHZkQwjAwwdduluPQ7o9rcnMHGjV2Y2gGaW0Z3aaZFpApmyR(AonTdat4IwNnMLmQzznAyiabGPNVbaM)E0wl1cvQ6UtFKqJzi4r8gKllJlfzHGQ9FNf4VJT9JISyF)c7SCuwUKfGqL3Sqob1zrrnXcX2kzhNmWcSz5HSy1WalKXk9MfYjOolkYB4H)Gj1qFcebzT3(VZBqUSqMCL637fVHh(dMud9jqeKTxz1d)bZQ6OVMsVaJy6k1V3R4p(JJb]] )
    

end