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

                return app + floor( ( t - app ) * 2 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        },

        natures_balance = {
            talent = "natures_balance",

            last = function ()
                local app = state.combat
                local t = state.query_time

                return app + floor( ( t - app ) / 2 ) * 2
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


    spec:RegisterPack( "Balance", 20220317, [[dm1O9fqikvEePGUeKkztKsFsPuJsbDkfYQuG8kiWSif6wKIyxu8livnmfkhdszzuQ6zcHMgeuxJuuBdsL6BqqACKI05uayDkanpiK7jeTpLI(NcGQgOcGkhuPKwOcvEiKKjkeWfjfyJqsPpQaimsiPOCsfQQvQu4LkakZesf3uiq2Psj(PqGAOqqCufarlfskYtb0uvG6QkuLTQai9viPWyHKQ9kI)kQbtCyQwmP6XcMmqxgzZk6Zq0OvQoTkRgskQEnKy2KCBHA3s(nOHtjhxiOLl1ZHA6Q66kz7a8DkLXdH68cP1RaA(I0(rDcAjdobiO)uYwSFm7TFSiIgc1m2aaHry00CcWpQfLa0YdO4iPeGLhtjahNR8kqjaT8OkOdMm4eGy4QducW9)TWdi6rVUR8kqAc(IdgK3VV0nhe9JZvEfinb4fJk0hdA2)y1a8ZtrrQ7kVcK5r8NauFDQF8Re9eGG(tjBX(XS3(XIiAiuZydaeoIrutta6RFh2jabEXOkb4(bcsvIEcqqchsaoox5vGyjc0RdK3icY7WolOHq1il2pM92ZBWBGQDVqs4bK3qtyzRGGeilaHkVzzCKhB4n0ewq1UxijqwEVrsF(MSeCmHz5HSeIguu(9gj9ydVHMWcQjkgcGazzvffim27OSaW7Z1veMLHNHmAKfRMaKXV34vJKyrt2KfRMayWV34vJKgz4n0ew2ka4bYIvtbh)xHKfuJ2)DwUjl3VnMLFNyXwdlKSObb1zHjdVHMWseKJcXcQGfaikel)oXcqRRVhZIZI6(xrSedBILPIq8PRiwgEtwIcxSS7G12pl73ZY9SGV4L69IGlSkkl2UFNLXfbV1bZccybvKIW)5kw2Q6qwXu9AKL73gKfmkN1idVHMWseKJcXsme)SS98qU)5MI9RWBZcoqL3heZIBzPIYYdzrhIXSmpK7pMfyPIA4n0ewgCt(ZYGHXelWjlJt57SmoLVZY4u(oloMfNfSffoxXY3xHc9gEdnHLiylQOMLHNHmAKfuJ2)DnYcQr7)Ugzb4798AAelXoiXsmSjwAcFQJQNLhYc5T6OMLamw3Fnb)E)gEdnHfu7HywgGDfytGSObXwqBuht1ZsyNcOWYe2SGQiallSJKmjavh(Xjdobi0IkQtgCYwqlzWjaPY1veyY4sa6H)GvcqBT)7jabjCOpR)Gvcqestbh)SyplOgT)7S4filolaFVXRgjXcSyb4GzX297SSLd5(ZcQ1jw8cKLXb36Gzb2Sa89EEnXc83P22HPeGH(EQppb4qwOG6SWKrTkVZfH4NL0uwOG6SWK5QmgQ8ML0uwOG6SWK5QSo83zjnLfkOolmz8kAUie)SmIfTSy1eadAgBT)7SOLf7yXQjag7n2A)3t(KTyFYGtasLRRiWKXLa0d)bReG43751ucWqFp1NNaCil2XsVkAcBKKr3vEfOmCMDLk)7xHeBOY1veilPPSyhlbiaQ86n1HC)ZtNyjnLf7ybBrkv(9gj9yd(9E6kflrYcASKMYIDS8UIQ3u(VAcN1DLxbYqLRRiqwgXIwwSJfm9zDyTWM)O2EnnBVvGL0uwgYcfuNfMmyOY7Cri(zjnLfkOolmzUkRwL3SKMYcfuNfMmxL1H)olPPSqb1zHjJxrZfH4NLrjavxr5aycqnN8jBjIjdobivUUIatgxcqp8hSsaIFVXRgjLam03t95jahYsVkAcBKKr3vEfOmCMDLk)7xHeBOY1veilAzjabqLxVPoK7FE6elAzbBrkv(9gj9yd(9E6kflrYcASmIfTSyhly6Z6WAHn)rT9AA2ERqcq1vuoaMauZjFYNaeKM(s9jdozlOLm4eGE4pyLaedvEN1jpobivUUIatgxYNSf7tgCcqQCDfbMmUeGH(EQppb4FXeliILHSypldIfp8hSm2A)3nbh)5)IjwqalE4pyzWV3ZRjtWXF(VyILrjaXFFHpzlOLa0d)bReGbxPYE4pyLvh(taQo8NlpMsacTOI6KpzlrmzWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGylsPYV3iPhBWV3txPyztwqJfTSmKf7y5DfvVb)ERGnOHkxxrGSKMYY7kQEd(jLY7myFZ3qLRRiqwgXsAklylsPYV3iPhBWV3txPyztwSpbiiHd9z9hSsacKEmlBfQbSalwIicyX297W1ZcyFZNfVazX297Sa89wbBqw8cKf7ralWFNABhMsacW7C5XucWdNDiL8jBbHtgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbi2IuQ87ns6Xg8798AILnzbTeGGeo0N1FWkbiq6XSeuKdGyX2ovSa89EEnXsWlw2VNf7ralV3iPhZIT9lSZYHzPjfbWRNLjSz53jw0GG6SWelpKfDIfRMMu3eilEbYIT9lSZY8ukQz5HSeC8NaeG35YJPeGhohuKdGs(KTO5KbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsaA1eGmYaObntmewZRjwstzXQjazKbqdAg8QMxtSKMYIvtaYidGg0m43B8QrsSKMYIvtaYidGg0m437PRuSKMYIvtaYidGg0mZvhndNzsTkIL0uwSAcGPDaubx48SPAGrzjnLf91CAcE(QGPPy)kmlrYI(AonbpFvWaUA)pyXsAkla8(CDfzoC2Hucqqch6Z6pyLaCaQ3NRRiw(D)zjStbuWSCtwIcxS4nXYvS4SGmaYYdzXbapqw(DIf89l)pyXITDQjwCw((kuONf6dSCywwycKLRyrNEBevSeC8JtacW7C5XucWRYidGjFYwq3jdobivUUIatgxcqp8hSsaQtnMAuUczcqqch6Z6pyLaC8WelJJAm1OCfsw8NLFNyHkqwGtwqTnvdmkl22PILDh)elhMfxhcGybDpg6sJS4ZNAwqfSaarHyX297SmoOpyw8cKf4VtTTdtSy7(Dwq1wr)4xHeGH(EQppb4qwgYIDSeGaOYR3uhY9ppDIL0uwSJLaeQaH2ktawaGOq5FNYyRRVhBwwSKMYIDS0RIMWgjz0DLxbkdNzxPY)(viXgQCDfbYYiw0YI(AonbpFvW0uSFfMLnzbnnZIww0xZPPDaubx48SPAGrnnf7xHzbrSGWSOLf7yjabqLxVbav)E0ML0uwcqau51Baq1VhTzrll6R50e88vbZYIfTSOVMtt7aOcUW5zt1aJAwwSOLLHSOVMtt7aOcUW5zt1aJAAk2VcZcIIKf0SNfnHfeMLbXsVkAcBKKbF1CPY7rXp1NBOY1veilPPSOVMttWZxfmnf7xHzbrSGgASKMYcASGEwWwKsL3D8tSGiwqZGUzzelJyrlla8(CDfzUkJmaM8jBbHMm4eGu56kcmzCjad99uFEcWHSOVMttWZxfmnf7xHzztwqtZSOLLHSyhl9QOjSrsg8vZLkVhf)uFUHkxxrGSKMYI(AonTdGk4cNNnvdmQPPy)kmliIf0gaSOLf91CAAhavWfopBQgyuZYILrSKMYIoeJzrllZd5(NBk2VcZcIyXEnZYiw0YcaVpxxrMRYidGjabjCOpR)Gvcqec8zX297S4SGQTI(XVcS87(ZYHRTFwCwqilf2BwSAyGfyZITDQy53jwMhY9NLdZIRdxplpKfQata6H)Gvcql4FWk5t2IMMm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucWaDkwgYYqwMhY9p3uSFfMfnHf00mlAclbiubcTvMGNVkyAk2VcZYiwqplOPPJXYiw2KLaDkwgYYqwMhY9p3uSFfMfnHf00mlAclbiubcTvMaSaarHY)oLXwxFp20uSFfMLrSGEwqtthJLrSOLf7yP9dmtaO6noii2qi(WpMfTSmKf7yjaHkqOTYe88vbttoyuwstzXowcqOceARmbybaIcL)DkJTU(ESPjhmklJyjnLLaeQaH2ktWZxfmnf7xHzztwU6P2cQ8NaZZd5(NBk2VcZsAkl9QOjSrsMaPi8FUkJTU(ESHkxxrGSOLLaeQaH2ktWZxfmnf7xHzztwI4ySKMYsacvGqBLjalaquO8VtzS113Jnnf7xHzztwU6P2cQ8NaZZd5(NBk2VcZIMWcAJXsAkl2XsacGkVEtDi3)80PeGGeo0N1FWkbiQCvyP8NWSyBN(DQzzHVcjlOcwaGOqSuqBSy7ukwCLcAJLOWflpKf8Fkflbh)S87elypMyXJHR6zbozbvWcaefcbOAROF8Ralbh)4eGa8oxEmLamalaquOmiHJwHKpzldGKbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsaoKL3BK0B(lMYpmdEelBYcAAML0uwA)aZeaQEJdcInxXYMSO5XyzelAzzildzHIW1zzrGgk2kAtUkdBWYRaXIwwgYIDSeGaOYR3aGQFpAZsAklbiubcTvgk2kAtUkdBWYRazAk2VcZcIybn0ncLfeWYqw0mldILEv0e2ijd(Q5sL3JIFQp3qLRRiqwgXYiw0YIDSeGqfi0wzOyROn5QmSblVcKPjhmklJyjnLfkcxNLfbAWWLsr)FfYCV0JYIwwgYIDSeGaOYR3uhY9ppDIL0uwcqOceARmy4sPO)VczUx6rZreH1SMogAMMI9RWSGiwqdneMLrSKMYYqwcqOceARm6uJPgLRqAAYbJYsAkl2Xs7bY8nuPyjnLLaeavE9M6qU)5PtSmIfTSmKf7y5DfvVzU6Oz4mtQvrgQCDfbYsAklbiaQ86naO63J2SOLLaeQaH2kZC1rZWzMuRImnf7xHzbrSGgASGaw0mldILEv0e2ijd(Q5sL3JIFQp3qLRRiqwstzXowcqau51Baq1VhTzrllbiubcTvM5QJMHZmPwfzAk2VcZcIyrFnNMGNVkyaxT)hSybbSGM9Smiw6vrtyJKmw9fdBWZvzVdEDHS1sH92qLRRiqw0ewqZEwgXIwwgYcfHRZYIanxHd96DDfLJWLx)kodsaUaXIwwcqOceARmxHd96DDfLJWLx)kodsaUazAk2VcZcIyrZSmIL0uwgYYqwOiCDwweObV7GqBeyg26z4m)WoMQNfTSeGqfi0wzEyht1tG5RWhY9phrnR5iApAMMI9RWSmIL0uwgYYqwa4956kYaR8ct5VVcf6zjswqJL0uwa4956kYaR8ct5VVcf6zjswIilJyrlldz57RqHEZJMPjhmAoaHkqOTIL0uw((kuO38OzcqOceARmnf7xHzztwU6P2cQ8NaZZd5(NBk2VcZIMWcAJXYiwstzbG3NRRidSYlmL)(kuONLizXEw0YYqw((kuO382BAYbJMdqOceARyjnLLVVcf6nV9MaeQaH2kttX(vyw2KLREQTGk)jW88qU)5MI9RWSOjSG2ySmIL0uwa4956kYaR8ct5VVcf6zjswgJLrSmILrjabjCOpR)GvcWXdtGS8qwajLhLLFNyzHDKelWjlOAROF8Ral22PILf(kKSacx6kIfyXYctS4filwnbGQNLf2rsSyBNkw8IfheKfcavplhMfxhUEwEilGhLaeG35YJPeGbWCawG3FWk5t2cAJLm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucq7ybdxk9Ran)EFkvgtekuBOY1veilPPSmpK7FUPy)kmlBYI9JnglPPSOdXyw0YY8qU)5MI9RWSGiwSxZSGawgYccpglAcl6R50879PuzmrOqTb)Eafwgel2ZYiwstzrFnNMFVpLkJjcfQn43dOWYMSernLfnHLHS0RIMWgjzWxnxQ8Eu8t95gQCDfbYYGyXEwgLaeKWH(S(dwjahG6956kILfMaz5HSaskpklEfLLVVcf6XS4filbqml22PIfB(9xHKLjSzXlw0GL1oSpNfRggsacW7C5XucWFVpLkJjcfQZ287t(KTGgAjdobivUUIatgxcqqch6Z6pyLaC8WelAqSv0MCflrWny5vGyX(XWuaZIonHnXIZcQ2k6h)kWYctSaBwWqw(D)z5EwSDkflQRiwwwSy7(Dw(DIfQazbozb12unWOjalpMsasXwrBYvzydwEfOeGH(EQppbyacvGqBLj45RcMMI9RWSGiwSFmw0YsacvGqBLjalaquO8VtzS113Jnnf7xHzbrSy)ySOLLHSaW7Z1vK537tPYyIqH6Sn)EwstzrFnNMFVpLkJjcfQn43dOWYMSeXXybbSmKLEv0e2ijd(Q5sL3JIFQp3qLRRiqwgelrKLrSmIfTSaW7Z1vK5QmYailPPSOdXyw0YY8qU)5MI9RWSGiwIicnbOh(dwjaPyROn5QmSblVcuYNSf0SpzWjaPY1veyY4sacs4qFw)bReGJhMybiCPu0FfswqnT0JYc6gtbml60e2elolOAROF8RallmXcSzbdz539NL7zX2PuSOUIyzzXIT73z53jwOcKf4KfuBt1aJMaS8ykbigUuk6)RqM7LE0eGH(EQppb4qwcqOceARmbpFvW0uSFfMfeXc6MfTSyhlbiaQ86naO63J2SOLf7yjabqLxVPoK7FE6elPPSeGaOYR3uhY9ppDIfTSeGqfi0wzcWcaefk)7ugBD99yttX(vywqelOBw0YYqwa4956kYeGfaikugKWrRalPPSeGqfi0wzcE(QGPPy)kmliIf0nlJyjnLLaeavE9gau97rBw0YYqwSJLEv0e2ijd(Q5sL3JIFQp3qLRRiqw0YsacvGqBLj45RcMMI9RWSGiwq3SKMYI(AonTdGk4cNNnvdmQPPy)kmliIf0gJfeWYqw0mldIfkcxNLfbAUc)9k8WgNbpaxrzDsPyzelAzrFnNM2bqfCHZZMQbg1SSyzelPPSOdXyw0YY8qU)5MI9RWSGiwSxZSKMYcfHRZYIanuSv0MCvg2GLxbIfTSeGqfi0wzOyROn5QmSblVcKPPy)kmlBYI9JXYiw0YcaVpxxrMRYidGSOLf7yHIW1zzrGMRWHE9UUIYr4YRFfNbjaxGyjnLLaeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWSSjl2pglPPSOdXyw0YY8qU)5MI9RWSGiwSFSeGE4pyLaedxkf9)viZ9spAYNSf0IyYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArja1xZPj45RcMMI9RWSSjlOPzw0YYqwSJLEv0e2ijd(Q5sL3JIFQp3qLRRiqwstzrFnNM2bqfCHZZMQbg10uSFfMfefjlOPzJMzbbSmKLiA0mldIf91CA0vqiOAHFZYILrSGawgYccB0mlAclr0Ozwgel6R50ORGqq1c)MLflJyzqSqr46SSiqZv4VxHh24m4b4kkRtkfliGfe2OzwgeldzHIW1zzrGMFNYZRXFgFipflAzjaHkqOTY87uEEn(Z4d5Pmnf7xHzbrrYI9JXYiw0YI(AonTdGk4cNNnvdmQzzXYiwstzrhIXSOLL5HC)Znf7xHzbrSyVMzjnLfkcxNLfbAOyROn5QmSblVcelAzjaHkqOTYqXwrBYvzydwEfittX(v4eGGeo0N1FWkb4wv28OywwyILXFaYial2UFNfuTv0p(vGfyZI)S87elubYcCYcQTPAGrtacW7C5XucWlcbZbybE)bRKpzlOHWjdobivUUIatgxcqp8hSsaEfo0R31vuocxE9R4mib4cucWqFp1NNaeG3NRRiZfHG5aSaV)GflAzbG3NRRiZvzKbWeGLhtjaVch6176kkhHlV(vCgKaCbk5t2cAAozWjaPY1veyY4sacs4qFw)bReGJhMyb4UdcTrGSeb36SOttytSGQTI(XVcjalpMsaI3DqOncmdB9mCMFyht1Nam03t95jahYsacvGqBLj45RcMMCWOSOLf7yjabqLxVPoK7FE6elAzbG3NRRiZV3NsLXeHc1zB(9SOLLHSeGqfi0wz0PgtnkxH00KdgLL0uwSJL2dK5BOsXYiwstzjabqLxVPoK7FE6elAzjaHkqOTYeGfaiku(3Pm2667XMMCWOSOLLHSaW7Z1vKjalaquOmiHJwbwstzjaHkqOTYe88vbttoyuwgXYiw0Yci8n4vnVMm)fq5kKSOLLHSacFd(jLY78u5nz(lGYvizjnLf7y5DfvVb)Ks5DEQ8Mmu56kcKL0uwWwKsLFVrsp2GFVNxtSSjlrKLrSOLfq4BIHWAEnz(lGYvizrlldzbG3NRRiZHZoKyjnLLEv0e2ijJUR8kqz4m7kv(3Vcj2qLRRiqwstzXXF7QSf0g1SSzKSmagJL0uwa4956kYeGfaikugKWrRalPPSOVMtJUccbvl8BwwSmIfTSyhlueUollc0Cfo0R31vuocxE9R4mib4celPPSqr46SSiqZv4qVExxr5iC51VIZGeGlqSOLLaeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWSSjlrCmw0YIDSOVMttWZxfmllwstzrhIXSOLL5HC)Znf7xHzbrSGWJLa0d)bReG4DheAJaZWwpdN5h2Xu9jFYwqdDNm4eGu56kcmzCjabjCOpR)GvcWbVFywomlolT)7uZcPCDy7pXInpklpKLyhfIfxPybwSSWel43Fw((kuOhZYdzrNyrDfbYYYIfB3VZcQ2k6h)kWIxGSGkybaIcXIxGSSWel)oXI9filyf8zbwSeaz5MSOd)Dw((kuOhZI3elWILfMyb)(ZY3xHc94eGH(EQppb4qwa4956kYaR8ct5VVcf6zXUizbnw0YIDS89vOqV5T30KdgnhGqfi0wXsAkldzbG3NRRidSYlmL)(kuONLizbnwstzbG3NRRidSYlmL)(kuONLizjISmIfTSmKf91CAcE(QGzzXIwwgYIDSeGaOYR3aGQFpAZsAkl6R500oaQGlCE2unWOMMI9RWSGawgYsenAMLbXsVkAcBKKbF1CPY7rXp1NBOY1veilJybrrYY3xHc9MhnJ(AoZGR2)dwSOLf91CAAhavWfopBQgyuZYIL0uw0xZPPDaubx48SPAGrZ4RMlvEpk(P(CZYILrSKMYsacvGqBLj45RcMMI9RWSGawSNLnz57RqHEZJMjaHkqOTYaUA)pyXIwwSJf91CAcE(QGzzXIwwgYIDSeGaOYR3uhY9ppDIL0uwSJfaEFUUImbybaIcLbjC0kWYiw0YIDSeGaOYR3Gs0(8IL0uwcqau51BQd5(NNoXIwwa4956kYeGfaikugKWrRalAzjaHkqOTYeGfaiku(3Pm2667XMLflAzXowcqOceARmbpFvWSSyrlldzzil6R50qb1zHPSAvEBAk2VcZYMSG2ySKMYI(AonuqDwykJHkVnnf7xHzztwqBmwgXIwwSJLEv0e2ijJUR8kqz4m7kv(3Vcj2qLRRiqwstzzil6R50O7kVcugoZUsL)9RqIZL)RMm43dOWsKSOzwstzrFnNgDx5vGYWz2vQ8VFfsC27GxKb)EafwIKfnLLrSmIL0uw0xZPbLRaBcmtXwqBuht1NPIAK3ajZYILrSKMYIoeJzrllZd5(NBk2VcZcIyX(XyjnLfaEFUUImWkVWu(7RqHEwIKLXyzelAzbG3NRRiZvzKbWeGyf8Xja)(kuOhTeGE4pyLa87RqHE0s(KTGgcnzWjaPY1veyY4sa6H)GvcWVVcf6TpbyOVN6ZtaoKfaEFUUImWkVWu(7RqHEwSlswSNfTSyhlFFfk0BE0mn5GrZbiubcTvSKMYcaVpxxrgyLxyk)9vOqplrYI9SOLLHSOVMttWZxfmllw0YYqwSJLaeavE9gau97rBwstzrFnNM2bqfCHZZMQbg10uSFfMfeWYqwIOrZSmiw6vrtyJKm4RMlvEpk(P(CdvUUIazzeliksw((kuO382B0xZzgC1(FWIfTSOVMtt7aOcUW5zt1aJAwwSKMYI(AonTdGk4cNNnvdmAgF1CPY7rXp1NBwwSmIL0uwcqOceARmbpFvW0uSFfMfeWI9SSjlFFfk0BE7nbiubcTvgWv7)blw0YIDSOVMttWZxfmllw0YYqwSJLaeavE9M6qU)5PtSKMYIDSaW7Z1vKjalaquOmiHJwbwgXIwwSJLaeavE9guI2NxSOLLHSyhl6R50e88vbZYIL0uwSJLaeavE9gau97rBwgXsAklbiaQ86n1HC)ZtNyrlla8(CDfzcWcaefkds4OvGfTSeGqfi0wzcWcaefk)7ugBD99yZYIfTSyhlbiubcTvMGNVkywwSOLLHSmKf91CAOG6SWuwTkVnnf7xHzztwqBmwstzrFnNgkOolmLXqL3MMI9RWSSjlOnglJyrll2XsVkAcBKKr3vEfOmCMDLk)7xHeBOY1veilPPSmKf91CA0DLxbkdNzxPY)(viX5Y)vtg87buyjsw0mlPPSOVMtJUR8kqz4m7kv(3Vcjo7DWlYGFpGclrYIMYYiwgXYiwstzrFnNguUcSjWmfBbTrDmvFMkQrEdKmllwstzrhIXSOLL5HC)Znf7xHzbrSy)ySKMYcaVpxxrgyLxyk)9vOqplrYYySmIfTSaW7Z1vK5QmYaycqSc(4eGFFfk0BFYNSf000KbNaKkxxrGjJlbiiHd9z9hSsaoEycZIRuSa)DQzbwSSWel3tXywGflbWeGE4pyLaCHP89umo5t2cAdGKbNaKkxxrGjJlbiiHd9z9hSsaQb3VtnliHSC1dz53jwWplWMfhsS4H)GflQd)ja9WFWkbyVQSh(dwz1H)eG4VVWNSf0sag67P(8eGa8(CDfzoC2Hucq1H)C5XucqhsjFYwSFSKbNaKkxxrGjJlbOh(dwja7vL9WFWkRo8NauD4pxEmLae)jFYNa0QPamw3)KbNSf0sgCcqp8hSsaIYvGnbMXwxFpobivUUIatgxYNSf7tgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkb4yjabjCOpR)GvcWbVtSaW7Z1velhMfm9S8qwgJfB3VZsbzb)(ZcSyzHjw((kuOhRrwqJfB7uXYVtSmVg)SalILdZcSyzHjnYI9SCtw(DIfmfGfilhMfVazjISCtw0H)olEtjab4DU8ykbiSYlmL)(kuOp5t2setgCcqQCDfbMmUeGqReGoiycqp8hSsacW7Z1vucqaUArjarlbyOVN6Zta(9vOqV5rZS748ctz91CYIww((kuO38OzcqOceARmGR2)dwSOLf7y57RqHEZJM5WMhgtz4mhdl83WfohGf(7v4pyHtacW7C5XucqyLxyk)9vOqFYNSfeozWjaPY1veyY4sacTsa6GGja9WFWkbiaVpxxrjab4QfLa0(eGH(EQppb43xHc9M3EZUJZlmL1xZjlAz57RqHEZBVjaHkqOTYaUA)pyXIwwSJLVVcf6nV9MdBEymLHZCmSWFdx4Caw4VxH)GfobiaVZLhtjaHvEHP83xHc9jFYw0CYGtasLRRiWKXLaeALa0bbta6H)GvcqaEFUUIsacW7C5XucqyLxyk)9vOqFcWqFp1NNaKIW1zzrGMRWHE9UUIYr4YRFfNbjaxGyjnLfkcxNLfbAOyROn5QmSblVcelPPSqr46SSiqdgUuk6)RqM7LE0eGGeo0N1FWkb4G3jmXY3xHc9yw8MyPGpl(6HX(FbxPIYci9u4jqwCmlWILfMyb)(ZY3xHc9ydlSaKEwa4956kILhYccZIJz53POS4kmKLIiqwWwu4Cfl7EbQUcPjbiaxTOeGiCYNSf0DYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArjaJ4ySmiwgYcASOjSmMbnnZYGybtFwhwlS5pQTxtZiSvGLrjabjCOpR)GvcqG0Jz53jwa(EJxnsILae)SmHnlk)PMLGRclL)hSWSmCcBwie7XwkIfB7uXYdzb)E)SaUITUcjl60e2elO2MQbgLLPRuywGZ5OeGa8oxEmLaeJZbi(t(KTGqtgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbOMhJLbXYqwqJfnHLXmOPzwgely6Z6WAHn)rT9AAgHTcSmkbiaVZLhtjaXZCaI)KpzlAAYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArjaJ4ySGawqBmwgel9QOjSrsMaPi8FUkJTU(ESHkxxrGjabjCOpR)GvcqG0JzXFwSTFHDw8y4QEwGtw2kgHWcQGfaikel4D4sbYIoXYctGdili8ySy7(D46zbvKIW)5kwaAD99yw8cKLiogl2UF3KaeG35YJPeGbybaIcLDSvYNSLbqYGta6H)GvcWyiSq5Q8e2XjaPY1veyY4s(KTG2yjdobivUUIatgxcqp8hSsaAR9FpbyOVN6ZtaoKfkOolmzuRY7Cri(zjnLfkOolmzUkJHkVzjnLfkOolmzUkRd)DwstzHcQZctgVIMlcXplJsaQUIYbWeGOnwYN8jaDiLm4KTGwYGtasLRRiWKXLaeALaetFcqp8hSsacW7Z1vucqaUArja7vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazrlldzrFnNM)IjBWUYGn5X6xbsTPPy)kmliIfKbqtSJywqalJzqJL0uw0xZP5VyYgSRmytES(vGuBAk2VcZcIyXd)bld(9EEnzietH1t5)IjwqalJzqJfTSmKfkOolmzUkRwL3SKMYcfuNfMmyOY7Cri(zjnLfkOolmz8kAUie)SmILrSOLf91CA(lMSb7kd2KhRFfi1MLvcqqch6Z6pyLaevUkSu(tywSTt)o1S87elrGM84G)HDQzrFnNSy7ukwMUsXcCozX297xXYVtSueIFwco(tacW7C5XucqWM84STtPYtxPYW5m5t2I9jdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLa0owOG6SWK5QmgQ8MfTSGTiLk)EJKESb)EpVMyztwqOSOjS8UIQ3GHlvgoZ)oLNWMWVHkxxrGSmiwSNfeWcfuNfMmxL1H)olAzXow6vrtyJKmw9fdBWZvzVdEDHS1sH92qLRRiqw0YIDS0RIMWgjzGf974CqrENbC4dwgQCDfbMaeKWH(S(dwjarLRclL)eMfB70VtnlaFVXRgjXYHzXgS)Dwco(VcjlqauZcW3751elxXc6SkVzrdcQZctjab4DU8ykb4HSGnLXV34vJKs(KTeXKbNaKkxxrGjJlbOh(dwjadWcaefk)7ugBD994eGGeo0N1FWkb44HjwqfSaarHyX2ovS4plkcJz539IfnpglBfJqyXlqwuxrSSSyX297SGQTI(XVcjad99uFEcq7ybSxhOPG5aiMfTSmKLHSaW7Z1vKjalaquOmiHJwbw0YIDSeGqfi0wzcE(QGPjhmklAzXow6vrtyJKmw9fdBWZvzVdEDHS1sH92qLRRiqwstzrFnNMGNVkywwSOLLHSyhl9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilPPS0RIMWgjzcKIW)5Qm2667XgQCDfbYsAklZd5(NBk2VcZYMSGM9iuwstzrhIXSOLL5HC)Znf7xHzbrSeGqfi0wzcE(QGPPy)kmliGf0gJL0uw0xZPj45RcMMI9RWSSjlOzplJyzelAzzildzzilo(BxLTG2OMfefjla8(CDfzcWcaefk7ylwstzbBrkv(9gj9yd(9EEnXYMSerwgXIwwgYI(AonuqDwykRwL3MMI9RWSSjlOnglPPSOVMtdfuNfMYyOYBttX(vyw2Kf0gJLrSKMYI(AonbpFvW0uSFfMLnzrZSOLf91CAcE(QGPPy)kmlikswqZEwgXIwwgYIDS8UIQ3GFsP8od238nu56kcKL0uw0xZPb)EpDLY0uSFfMfeXcAgnZIMWYygnZYGyPxfnHnsYeifH)ZvzS113Jnu56kcKL0uw0xZPj45RcMMI9RWSGiw0xZPb)EpDLY0uSFfMfeWIMzrll6R50e88vbZYILrSOLLHSyhl9QOjSrsM)IjBWUYGn5X6xbsTHkxxrGSKMYIDS0RIMWgjzcKIW)5Qm2667XgQCDfbYsAkl6R508xmzd2vgSjpw)kqQnnf7xHzztwietH1t5)IjwgXsAkl9QOjSrsgDx5vGYWz2vQ8VFfsSHkxxrGSmIfTSmKf7yPxfnHnsYO7kVcugoZUsL)9RqInu56kcKL0uwgYI(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akSejlAklPPSOVMtJUR8kqz4m7kv(3Vcjo7DWlYGFpGclrYIMYYiwgXsAkl6qmMfTSmpK7FUPy)kmliIf0gJfTSyhlbiubcTvMGNVkyAYbJYYOKpzliCYGtasLRRiWKXLa0d)bReG4vnVMsagIguu(9gj94KTGwcWqFp1NNaCilnnBcV76kIL0uw0xZPHcQZctzmu5TPPy)kmliILiYIwwOG6SWK5QmgQ8MfTS0uSFfMfeXcAimlAz5DfvVbdxQmCM)DkpHnHFdvUUIazzelAz59gj9M)IP8dZGhXYMSGgcZIMWc2IuQ87ns6XSGawAk2VcZIwwgYcfuNfMmxL9kklPPS0uSFfMfeXcYaOj2rmlJsacs4qFw)bReGJhMyb4QMxtSCflwEbsXxGfyXIxr)9RqYYV7plQdaHzbnegtbmlEbYIIWywSD)olXWMy59gj9yw8cKf)z53jwOcKf4KfNfGqL3SObb1zHjw8Nf0qywWuaZcSzrrymlnf7xDfswCmlpKLc(SS7aUcjlpKLMMnH3zbC1xHKf0zvEZIgeuNfMs(KTO5KbNaKkxxrGjJlbOh(dwjaXRAEnLaeKWH(S(dwjahpmXcWvnVMy5HSS7aiwCwqQG6UILhYYctSm(dqgbsag67P(8eGa8(CDfzUiemhGf49hSyrllbiubcTvMRWHE9UUIYr4YRFfNbjaxGmn5GrzrllueUollc0Cfo0R31vuocxE9R4mib4celAzXTYHDkGsYNSf0DYGtasLRRiWKXLa0d)bReG437PRujabjCOpR)GvcWbyezXYYIfGV3txPyXFwCLIL)IjmlRsrymll8vizbDIg82XS4fil3ZYHzX1HRNLhYIvddSaBwu0ZYVtSGTOW5kw8WFWIf1vel6KcAJLDVavelrGM8y9RaPMfyXI9S8EJKECcWqFp1NNa0owExr1BWpPuENb7B(gQCDfbYIwwgYIDSGPpRdRf28h12RPze2kWsAkluqDwyYCv2ROSKMYc2IuQ87ns6Xg8790vkw2KLiYYiw0YYqw0xZPb)EpDLY00Sj8URRiw0YYqwWwKsLFVrsp2GFVNUsXcIyjISKMYIDS0RIMWgjz(lMSb7kd2KhRFfi1gQCDfbYYiwstz5DfvVbdxQmCM)DkpHnHFdvUUIazrll6R50qb1zHPmgQ820uSFfMfeXsezrlluqDwyYCvgdvEZIww0xZPb)EpDLY0uSFfMfeXccLfTSGTiLk)EJKESb)EpDLILnJKfeMLrSOLLHSyhl9QOjSrsgv0G3oopve9xHmJuDXwyYqLRRiqwstz5VyIf0fliSMzztw0xZPb)EpDLY0uSFfMfeWI9SmIfTS8EJKEZFXu(HzWJyztw0CYNSfeAYGtasLRRiWKXLa0d)bReG437PRujabjCOpR)GvcquJ73zb4tkL3Seb6B(SSWelWILail22PILMMnH3DDfXI(6zb)NsXIn)EwMWMf0jAWBhZIvddS4filGWA7NLfMyrNMWMybvraSHfG)PuSSWel60e2elOcwaGOqSGVkqS87(ZITtPyXQHbw8c(7uZcW37PRujad99uFEcW3vu9g8tkL3zW(MVHkxxrGSOLf91CAWV3txPmnnBcV76kIfTSmKf7ybtFwhwlS5pQTxtZiSvGL0uwOG6SWK5QSxrzjnLfSfPu53BK0Jn437PRuSSjlimlJyrlldzXow6vrtyJKmQObVDCEQi6VczgP6ITWKHkxxrGSKMYYFXelOlwqynZYMSGWSmIfTS8EJKEZFXu(HzWJyztwIyYNSfnnzWjaPY1veyY4sa6H)Gvcq8790vQeGGeo0N1FWkbiQX97SebAYJ1VcKAwwyIfGV3txPy5HSGcrwSSSy53jw0xZjl6rzXvyill8vizb4790vkwGflAMfmfGfiMfyZIIWywAk2V6kKjad99uFEcWEv0e2ijZFXKnyxzWM8y9RaP2qLRRiqw0Yc2IuQ87ns6Xg8790vkw2mswIilAzzil2XI(Aon)ft2GDLbBYJ1VcKAZYIfTSOVMtd(9E6kLPPzt4DxxrSKMYYqwa4956kYa2KhNTDkvE6kvgoNSOLLHSOVMtd(9E6kLPPy)kmliILiYsAklylsPYV3iPhBWV3txPyztwSNfTS8UIQ3GFsP8od238nu56kcKfTSOVMtd(9E6kLPPy)kmliIfnZYiwgXYOKpzldGKbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1Isa64VDv2cAJAw2KfnDmwgeldzbnw0ewW0N1H1cB(JA710S9wbwgelJzSNLrSmiwgYcASOjSOVMtZFXKnyxzWM8y9RaP2GFpGcldILXmOXYiw0ewgYI(Aon437PRuMMI9RWSmiwIilONfSfPu5Dh)eldIf7y5DfvVb)Ks5DgSV5BOY1veilJyrtyzilbiubcTvg8790vkttX(vywgelrKf0Zc2IuQ8UJFILbXY7kQEd(jLY7myFZ3qLRRiqwgXIMWYqw0xZPzU6Oz4mtQvrMMI9RWSmiw0mlJyrlldzrFnNg8790vkZYIL0uwcqOceARm437PRuMMI9RWSmkbiiHd9z9hSsaIkxfwk)jml22PFNAwCwa(EJxnsILfMyX2PuSe8fMyb4790vkwEiltxPyboNAKfVazzHjwa(EJxnsILhYckezXseOjpw)kqQzb)Eafwwwgw00Xy5WS87elnfHRRjqw2kgHWYdzj44NfGV34vJKqaW37PRujab4DU8ykbi(9E6kv2gS(80vQmCot(KTG2yjdobivUUIatgxcqp8hSsaIFVXRgjLaeKWH(S(dwjahpmXcW3B8QrsSy7(DwIan5X6xbsnlpKfuiYILLfl)oXI(AozX297W1ZIcIVcjlaFVNUsXYY6VyIfVazzHjwa(EJxnsIfyXccJawghCRdMf87buWSSQ)uSGWS8EJKECcWqFp1NNaeG3NRRidytEC22Pu5PRuz4CYIwwa4956kYGFVNUsLTbRppDLkdNtw0YIDSaW7Z1vK5qwWMY43B8QrsSKMYYqw0xZPr3vEfOmCMDLk)7xHeNl)xnzWVhqHLnzjISKMYI(Aon6UYRaLHZSRu5F)kK4S3bVid(9akSSjlrKLrSOLfSfPu53BK0Jn437PRuSGiwqyw0YcaVpxxrg8790vQSny95PRuz4CM8jBbn0sgCcqQCDfbMmUeGE4pyLa0bDR)aqzSnVJtagIguu(9gj94KTGwcWqFp1NNa0ow(lGYvizrll2XIh(dwgh0T(daLX28ood6XosYCvEQoK7plPPSacFJd6w)bGYyBEhNb9yhjzWVhqHfeXsezrllGW34GU1FaOm2M3Xzqp2rsMMI9RWSGiwIycqqch6Z6pyLaC8WelyBEhZcgYYV7plrHlwqsplXoIzzz9xmXIEuww4RqYY9S4ywu(tS4ywSGy8PRiwGflkcJz539ILiYc(9akywGnlOMVWpl22PILiIawWVhqbZcHyRRPKpzlOzFYGtasLRRiWKXLa0d)bReGXqynVMsagIguu(9gj94KTGwcWqFp1NNaSPzt4DxxrSOLL3BK0B(lMYpmdEelBYYqwgYcAimliGLHSGTiLk)EJKESb)EpVMyzqSypldIf91CAOG6SWuwTkVnllwgXYiwqalnf7xHzzelONLHSGgliGL3vu9M32v5yiSWgQCDfbYYiw0YIJ)2vzlOnQzztwa4956kYGN5ae)SOjSOVMtd(9E6kLPPy)kmldIf0nlAzzilUvoStbuyjnLfaEFUUImhYc2ug)EJxnsIL0uwSJfkOolmzUk7vuwgXIwwgYsacvGqBLj45RcMMCWOSOLfkOolmzUk7vuw0YIDSa2Rd0uWCaeZIwwgYcaVpxxrMaSaarHYGeoAfyjnLLaeQaH2ktawaGOq5FNYyRRVhBAYbJYsAkl2XsacGkVEtDi3)80jwgXsAklylsPYV3iPhBWV3ZRjwqeldzzilAklAcldzrFnNgkOolmLvRYBZYILbXsezzelJyzqSmKf0ybbS8UIQ382UkhdHf2qLRRiqwgXYiw0YIDSqb1zHjdgQ8oxeIFw0YYqwSJLaeQaH2ktWZxfmn5GrzjnLfWEDGMcMdGywgXsAkldzHcQZctMRYyOYBwstzrFnNgkOolmLvRYBZYIfTSyhlVRO6ny4sLHZ8Vt5jSj8BOY1veilJyrlldzbBrkv(9gj9yd(9EEnXcIybTXyzqSmKf0ybbS8UIQ382UkhdHf2qLRRiqwgXYiwgXIwwgYIDSeGaOYR3Gs0(8IL0uwSJf91CAq5kWMaZuSf0g1Xu9zQOg5nqYSSyjnLfkOolmzUkJHkVzzelAzXow0xZPPDaubx48SPAGrZ4RMlvEpk(P(CZYkbiiHd9z9hSsaIAIMnH3zjcccR51el3KfuTv0p(vGLdZstoyunYYVtnXI3elkcJz539IfnZY7ns6XSCflOZQ8MfniOolmXIT73zbi8rTAKffHXS87EXcAJXc83P22HjwUIfVIYIgeuNfMyb2SSSy5HSOzwEVrspMfDAcBIfNf0zvEZIgeuNfMmSebG12plnnBcVZc4QVcjldWUcSjqw0GylOnQJP6zzvkcJz5kwacvEZIgeuNfMs(KTGwetgCcqQCDfbMmUeGE4pyLaCc7aLHZC5)QPeGGeo0N1FWkb44HjwqTWTWcSyjaYIT73HRNLGBzDfYeGH(EQppbOBLd7uafwstzbG3NRRiZHSGnLXV34vJKs(KTGgcNm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucq7ybSxhOPG5aiMfTSmKfaEFUUImbWCawG3FWIfTSmKf91CAWV3txPmllwstz5DfvVb)Ks5DgSV5BOY1veilPPSeGaOYR3uhY9ppDILrSOLfq4BIHWAEnz(lGYvizrlldzXow0xZPbdv4)cKzzXIwwSJf91CAcE(QGzzXIwwgYIDS8UIQ3mxD0mCMj1QidvUUIazjnLf91CAcE(QGbC1(FWILnzjaHkqOTYmxD0mCMj1QittX(vywqalAklJyrlldzXowW0N1H1cB(JA710S9wbwstzHcQZctMRYQv5nlPPSqb1zHjdgQ8oxeIFwgXIwwa4956kY879PuzmrOqD2MFplAzzil2XsacGkVEtDi3)80jwstzbG3NRRitawaGOqzqchTcSKMYsacvGqBLjalaquO8VtzS113Jnnf7xHzbrSGMMzzelAz59gj9M)IP8dZGhXYMSOVMttWZxfmGR2)dwSmiwgZGqzzelPPSOdXyw0YY8qU)5MI9RWSGiw0xZPj45RcgWv7)blwqalOzpldILEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKLrjab4DU8ykbyamhGf49hSYoKs(KTGMMtgCcqQCDfbMmUeGE4pyLaSDaubx48SPAGrtacs4qFw)bReGJhMyb12unWOSy7(Dwq1wr)4xHeGH(EQppbO(AonbpFvW0uSFfMLnzbnnZsAkl6R50e88vbd4Q9)GfliGf0SNLbXsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYcIyXE0nlAzbG3NRRitamhGf49hSYoKs(KTGg6ozWjaPY1veyY4sa6H)GvcWaPi8FUk7Qdzft1NaeKWH(S(dwjahpmXcQ2k6h)kWcSyjaYYQuegZIxGSOUIy5EwwwSy7(DwqfSaarHsag67P(8eGa8(CDfzcG5aSaV)Gv2HelAzzil2XsacGkVEdaQ(9OnlPPSyhl9QOjSrsg8vZLkVhf)uFUHkxxrGSKMYsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYsAkl6R50e88vbd4Q9)GflBgjl2JUzzelPPSOVMtt7aOcUW5zt1aJAwwSOLf91CAAhavWfopBQgyuttX(vywqelOPzJMt(KTGgcnzWjaPY1veyY4sag67P(8eGa8(CDfzcG5aSaV)Gv2Hucqp8hSsaEvW7Y)dwjFYwqtttgCcqQCDfbMmUeGE4pyLaKITG2OoRdlWeGGeo0N1FWkb44Hjw0GylOnQzzCWcKfyXsaKfB3VZcW37PRuSSSyXlqwWoaILjSzbHSuyVzXlqwq1wr)4xHeGH(EQppb4qwcqOceARmbpFvW0uSFfMfeWI(AonbpFvWaUA)pyXccyPxfnHnsYy1xmSbpxL9o41fYwlf2BdvUUIazzqSGM9SSjlbiubcTvgk2cAJ6SoSanGR2)dwSGawqBmwgXsAkl6R50e88vbttX(vyw2KfnLL0uwa71bAkyoaIt(KTG2aizWjaPY1veyY4sa6H)Gvcq8tkL35PYBkbyiAqr53BK0Jt2cAjad99uFEcWMMnH3DDfXIww(lMYpmdEelBYcAAMfTSGTiLk)EJKESb)EpVMybrSGWSOLf3kh2PakSOLLHSOVMttWZxfmnf7xHzztwqBmwstzXow0xZPj45RcMLflJsacs4qFw)bReGOMOzt4DwMkVjwGflllwEilrKL3BK0JzX297W1ZcQ2k6h)kWIoDfswCD46z5HSqi26AIfVazPGplqauhClRRqM8jBX(XsgCcqQCDfbMmUeGE4pyLaCU6Oz4mtQvrjabjCOpR)GvcWXdtSGAHAal3KLRWhiXIxSObb1zHjw8cKf1vel3ZYYIfB3VZIZcczPWEZIvddS4filBf0T(daXcqBEhNam03t95jaPG6SWK5QSxrzrlldzXTYHDkGclPPSyhl9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilJyrlldzrFnNgR(IHn45QS3bVUq2APWEBa4QfXcIyXEnpglPPSOVMttWZxfmnf7xHzztw0uwgXIwwgYci8noOB9hakJT5DCg0JDKK5VakxHKL0uwSJLaeavE9MIcnubBqwstzbBrkv(9gj9yw2Kf7zzelAzzil6R500oaQGlCE2unWOMMI9RWSGiwgaSOjSmKfeMLbXsVkAcBKKbF1CPY7rXp1NBOY1veilJyrll6R500oaQGlCE2unWOMLflPPSyhl6R500oaQGlCE2unWOMLflJyrlldzXowcqOceARmbpFvWSSyjnLf91CA(9(uQmMiuO2GFpGcliIf00mlAzzEi3)CtX(vywqel2p2ySOLL5HC)Znf7xHzztwqBSXyjnLf7ybdxk9Ran)EFkvgtekuBOY1veilJyrlldzbdxk9Ran)EFkvgtekuBOY1veilPPSeGqfi0wzcE(QGPPy)kmlBYsehJLrSOLL3BK0B(lMYpmdEelBYIMzjnLfDigZIwwMhY9p3uSFfMfeXcAJL8jBXE0sgCcqQCDfbMmUeGE4pyLae)EpDLkbiiHd9z9hSsaoEyIfNfGV3txPyjcUOFNfRggyzvkcJzb4790vkwomlUQjhmklllwGnlrHlw8MyX1HRNLhYcea1b3ILTIrijad99uFEcq91CAGf974Sf1bY6pyzwwSOLLHSOVMtd(9E6kLPPzt4DxxrSKMYIJ)2vzlOnQzztwgaJXYOKpzl2BFYGtasLRRiWKXLa0d)bReG437PRujabjCOpR)GvcWiWk2ILTIriSOttytSGkybaIcXIT73zb4790vkw8cKLFNkwa(EJxnskbyOVN6ZtagGaOYR3uhY9ppDIfTSyhlVRO6n4NukVZG9nFdvUUIazrlldzbG3NRRitawaGOqzqchTcSKMYsacvGqBLj45RcMLflPPSOVMttWZxfmllwgXIwwcqOceARmbybaIcL)DkJTU(ESPPy)kmliIfKbqtSJywgelb6uSmKfh)TRYwqBuZc6zbG3NRRidEMdq8ZYiw0YI(Aon437PRuMMI9RWSGiwqyw0YIDSa2Rd0uWCaeN8jBX(iMm4eGu56kcmzCjad99uFEcWaeavE9M6qU)5PtSOLLHSaW7Z1vKjalaquOmiHJwbwstzjaHkqOTYe88vbZYIL0uw0xZPj45RcMLflJyrllbiubcTvMaSaarHY)oLXwxFp20uSFfMfeXIMzrlla8(CDfzWV3txPY2G1NNUsLHZjlAzHcQZctMRYEfLfTSyhla8(CDfzoKfSPm(9gVAKelAzXowa71bAkyoaIta6H)Gvcq87nE1iPKpzl2JWjdobivUUIatgxcqp8hSsaIFVXRgjLaeKWH(S(dwjahpmXcW3B8QrsSy7(Dw8ILi4I(DwSAyGfyZYnzjkCTnilqauhClw2kgHWIT73zjkC1SueIFwco(nSSvfgYc4k2ILTIriS4pl)oXcvGSaNS87eldqP63J2SOVMtwUjlaFVNUsXIn4sbwB)SmDLIf4CYcSzjkCXI3elWIf7z59gj94eGH(EQppbO(AonWI(DCoOiVZao8blZYIL0uwgYIDSGFVNxtg3kh2PakSOLf7ybG3NRRiZHSGnLXV34vJKyjnLLHSOVMttWZxfmnf7xHzbrSOzw0YI(AonbpFvWSSyjnLLHSmKf91CAcE(QGPPy)kmliIfKbqtSJywgelb6uSmKfh)TRYwqBuZc6zbG3NRRidgNdq8ZYiw0YI(AonbpFvWSSyjnLf91CAAhavWfopBQgy0m(Q5sL3JIFQp30uSFfMfeXcYaOj2rmldILaDkwgYIJ)2vzlOnQzb9SaW7Z1vKbJZbi(zzelAzrFnNM2bqfCHZZMQbgnJVAUu59O4N6ZnllwgXIwwcqau51Baq1VhTzzelJyrlldzbBrkv(9gj9yd(9E6kfliILiYsAkla8(CDfzWV3txPY2G1NNUsLHZjlJyzelAzXowa4956kYCilytz87nE1ijw0YYqwSJLEv0e2ijZFXKnyxzWM8y9RaP2qLRRiqwstzbBrkv(9gj9yd(9E6kfliILiYYOKpzl2R5KbNaKkxxrGjJlbOh(dwjalYwogcReGGeo0N1FWkb44HjwIGGWcZYvSaeQ8MfniOolmXIxGSGDaelO2LsXseeewSmHnlOAROF8RqcWqFp1NNaCil6R50qb1zHPmgQ820uSFfMLnzHqmfwpL)lMyjnLLHSe29gjHzjswSNfTS0uy3BKu(VyIfeXIMzzelPPSe29gjHzjswIilJyrllUvoStbus(KTyp6ozWjaPY1veyY4sag67P(8eGdzrFnNgkOolmLXqL3MMI9RWSSjleIPW6P8FXelPPSmKLWU3ijmlrYI9SOLLMc7EJKY)ftSGiw0mlJyjnLLWU3ijmlrYsezzelAzXTYHDkGclAzzil6R500oaQGlCE2unWOMMI9RWSGiw0mlAzrFnNM2bqfCHZZMQbg1SSyrll2XsVkAcBKKbF1CPY7rXp1NBOY1veilPPSyhl6R500oaQGlCE2unWOMLflJsa6H)GvcWDxnZXqyL8jBXEeAYGtasLRRiWKXLam03t95jahYI(AonuqDwykJHkVnnf7xHzztwietH1t5)Ijw0YYqwcqOceARmbpFvW0uSFfMLnzrZJXsAklbiubcTvMaSaarHY)oLXwxFp20uSFfMLnzrZJXYiwstzzilHDVrsywIKf7zrllnf29gjL)lMybrSOzwgXsAklHDVrsywIKLiYYiw0YIBLd7uafw0YYqw0xZPPDaubx48SPAGrnnf7xHzbrSOzw0YI(AonTdGk4cNNnvdmQzzXIwwSJLEv0e2ijd(Q5sL3JIFQp3qLRRiqwstzXow0xZPPDaubx48SPAGrnllwgLa0d)bReGZLsLJHWk5t2I9AAYGtasLRRiWKXLaeKWH(S(dwjahpmXcQbudybwSGQiqcqp8hSsaAZ7(GDgoZKAvuYNSf7hajdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLaeBrkv(9gj9yd(9EEnXYMSGWSGawMkiSzzilXo(PoAgGRweldIf0gBmwqpl2pglJybbSmvqyZYqw0xZPb)EJxnsktXwqBuht1NXqL3g87buyb9SGWSmkbiiHd9z9hSsaIkxfwk)jml22PFNAwEillmXcW3751elxXcqOYBwSTFHDwoml(ZIMz59gj9yeGgltyZcbG6OSy)yOlwID8tDuwGnlimlaFVXRgjXIgeBbTrDmvpl43dOGtacW7C5Xucq8798AkFvgdvEN8jBjIJLm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucq0yb9SGTiLkV74NybrSyplAcldzzmJ9SmiwgYc2IuQ87ns6Xg8798AIfnHf0yzeldILHSGgliGL3vu9gmCPYWz(3P8e2e(nu56kcKLbXcAgnZYiwgXccyzmdAAMLbXI(AonTdGk4cNNnvdmQPPy)kCcqqch6Z6pyLaevUkSu(tywSTt)o1S8qwqnA)3zbC1xHKfuBt1aJMaeG35YJPeG2A)3ZxLNnvdmAYNSLiIwYGtasLRRiWKXLa0d)bReG2A)3tacs4qFw)bReGJhMyb1O9FNLRybiu5nlAqqDwyIfyZYnzPGSa89EEnXITtPyzEplx9qwq1wr)4xbw8kAmSPeGH(EQppb4qwOG6SWKrTkVZfH4NL0uwOG6SWKXRO5Iq8ZIwwa4956kYC4CqroaILrSOLLHS8EJKEZFXu(HzWJyztwqywstzHcQZctg1Q8oFv2EwstzrhIXSOLL5HC)Znf7xHzbrSG2ySmIL0uw0xZPHcQZctzmu5TPPy)kmliIfp8hSm43751KHqmfwpL)lMyrll6R50qb1zHPmgQ82SSyjnLfkOolmzUkJHkVzrll2XcaVpxxrg8798AkFvgdvEZsAkl6R50e88vbttX(vywqelE4pyzWV3ZRjdHykSEk)xmXIwwSJfaEFUUImhohuKdGyrll6R50e88vbttX(vywqeleIPW6P8FXelAzrFnNMGNVkywwSKMYI(AonTdGk4cNNnvdmQzzXIwwa4956kYyR9FpFvE2unWOSKMYIDSaW7Z1vK5W5GICaelAzrFnNMGNVkyAk2VcZYMSqiMcRNY)ftjFYwIO9jdobivUUIatgxcqqch6Z6pyLaC8WelaFVNxtSCtwUIf0zvEZIgeuNfM0ilxXcqOYBw0GG6SWelWIfegbS8EJKEmlWMLhYIvddSaeQ8MfniOolmLa0d)bReG43751uYNSLigXKbNaKkxxrGjJlbiiHd9z9hSsaIADL637vcqp8hSsa2Rk7H)GvwD4pbO6WFU8ykb40vQFVxjFYNaC6k1V3RKbNSf0sgCcqQCDfbMmUeGE4pyLae)EJxnskbiiHd9z9hSsac89gVAKeltyZsmeaft1ZYQuegZYcFfswghCRdobyOVN6ZtaAhl9QOjSrsgDx5vGYWz2vQ8VFfsSHIW1zzrGjFYwSpzWjaPY1veyY4sa6H)Gvcq8QMxtjadrdkk)EJKECYwqlbyOVN6ZtaccFtmewZRjttX(vyw2KLMI9RWSmiwS3EwqplOPPjabjCOpR)Gvcqu54NLFNybe(Sy7(Dw(DILyi(z5VyILhYIdcYYQ(tXYVtSe7iMfWv7)blwoml73Byb4QMxtS0uSFfML4L6pl1rGS8qwI9pSZsmewZRjwaxT)hSs(KTeXKbNa0d)bReGXqynVMsasLRRiWKXL8jFcq8Nm4KTGwYGtasLRRiWKXLa0d)bReGoOB9hakJT5DCcWq0GIYV3iPhNSf0sag67P(8eG2Xci8noOB9hakJT5DCg0JDKK5VakxHKfTSyhlE4pyzCq36paugBZ74mOh7ijZv5P6qU)SOLLHSyhlGW34GU1FaOm2M3X5DYvM)cOCfswstzbe(gh0T(daLX28ooVtUY0uSFfMLnzrZSmIL0uwaHVXbDR)aqzSnVJZGESJKm43dOWcIyjISOLfq4BCq36paugBZ74mOh7ijttX(vywqelrKfTSacFJd6w)bGYyBEhNb9yhjz(lGYvitacs4qFw)bReGJhMyzRGU1FaiwaAZ7ywSTtfl)o1elhMLcYIh(daXc2M3XAKfhZIYFIfhZIfeJpDfXcSybBZ7ywSD)ol2ZcSzzs2OMf87buWSaBwGflolrebSGT5Dmlyil)U)S87elfzJfSnVJzX7(aqywqnFHFw85tnl)U)SGT5DmleITUMWjFYwSpzWjaPY1veyY4sa6H)GvcWaSaarHY)oLXwxFpobiiHd9z9hSsaoEycZcQGfaikel3KfuTv0p(vGLdZYYIfyZsu4IfVjwajC0kCfswq1wr)4xbwSD)olOcwaGOqS4filrHlw8MyrNuqBSGWJH(io2qurkc)NRybO113JhXYwXiewUIfNf0gdbSGPalAqqDwyYWYwvyilGWA7Nff9SebAYJ1VcKAwieBDnPrwCLnpkMLfMy5kwq1wr)4xbwSD)oliKLc7nlEbYI)S87el437Nf4KfNLXb36GzX2vGqBMeGH(EQppbODSa2Rd0uWCaeZIwwgYYqwa4956kYeGfaikugKWrRalAzXowcqOceARmbpFvW0KdgLfTSyhl9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilPPSOVMttWZxfmllw0YYqwSJLEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKL0uw6vrtyJKmbsr4)CvgBD99ydvUUIazjnLL5HC)Znf7xHzztwqZEeklPPSOdXyw0YY8qU)5MI9RWSGiwcqOceARmbpFvW0uSFfMfeWcAJXsAkl6R50e88vbttX(vyw2Kf0SNLrSmIfTSmKLHS44VDv2cAJAwquKSaW7Z1vKjalaquOSJTyrlldzrFnNgkOolmLvRYBttX(vyw2Kf0gJL0uw0xZPHcQZctzmu5TPPy)kmlBYcAJXYiwstzrFnNMGNVkyAk2VcZYMSOzw0YI(AonbpFvW0uSFfMfefjlOzplJyrlldzXow6vrtyJKm)ft2GDLbBYJ1VcKAdvUUIazjnLf7yPxfnHnsYeifH)ZvzS113Jnu56kcKL0uw0xZP5VyYgSRmytES(vGuBAk2VcZYMSqiMcRNY)ftSmIL0uw6vrtyJKm6UYRaLHZSRu5F)kKydvUUIazzelAzzil2XsVkAcBKKr3vEfOmCMDLk)7xHeBOY1veilPPSmKf91CA0DLxbkdNzxPY)(viX5Y)vtg87buyjsw0uwstzrFnNgDx5vGYWz2vQ8VFfsC27GxKb)EafwIKfnLLrSmIL0uw0HymlAzzEi3)CtX(vywqelOnglAzXowcqOceARmbpFvW0KdgLLrjFYwIyYGtasLRRiWKXLa0d)bReG43B8QrsjabjCOpR)GvcWXdtSa89gVAKelpKfuiYILLfl)oXseOjpw)kqQzrFnNSCtwUNfBWLcKfcXwxtSOttytSmV6W7xHKLFNyPie)SeC8ZcSz5HSaUITyrNMWMybvWcaefkbyOVN6Zta2RIMWgjz(lMSb7kd2KhRFfi1gQCDfbYIwwgYIDSmKLHSOVMtZFXKnyxzWM8y9RaP20uSFfMLnzXd)blJT2)DdHykSEk)xmXccyzmdASOLLHSqb1zHjZvzD4VZsAkluqDwyYCvgdvEZsAkluqDwyYOwL35Iq8ZYiwstzrFnNM)IjBWUYGn5X6xbsTPPy)kmlBYIh(dwg8798AYqiMcRNY)ftSGawgZGglAzziluqDwyYCvwTkVzjnLfkOolmzWqL35Iq8ZsAkluqDwyY4v0Cri(zzelJyjnLf7yrFnNM)IjBWUYGn5X6xbsTzzXYiwstzzil6R50e88vbZYIL0uwa4956kYeGfaikugKWrRalJyrllbiubcTvMaSaarHY)oLXwxFp20KdgLfTSeGaOYR3uhY9ppDIfTSmKf91CAOG6SWuwTkVnnf7xHzztwqBmwstzrFnNgkOolmLXqL3MMI9RWSSjlOnglJyzelAzzil2XsacGkVEdkr7ZlwstzjaHkqOTYqXwqBuN1HfOPPy)kmlBYIMYYOKpzliCYGtasLRRiWKXLa0d)bReG43B8QrsjabjCOpR)GvcWiWk2IfGV34vJKWSy7(DwgNR8kqSaNSSvLILbVFfsmlWMLhYIvtwEtSmHnlOcwaGOqSy7(DwghCRdobyOVN6Zta2RIMWgjz0DLxbkdNzxPY)(viXgQCDfbYIwwgYYqw0xZPr3vEfOmCMDLk)7xHeNl)xnzWVhqHLnzXEwstzrFnNgDx5vGYWz2vQ8VFfsC27GxKb)Eafw2Kf7zzelAzjaHkqOTYe88vbttX(vyw2KfeklAzXowcqOceARmbybaIcL)DkJTU(ESzzXsAkldzjabqLxVPoK7FE6elAzjaHkqOTYeGfaiku(3Pm2667XMMI9RWSGiwqBmw0YcfuNfMmxL9kklAzXXF7QSf0g1SSjl2pgliGLiogldILaeQaH2ktWZxfmn5GrzzelJs(KTO5KbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1IsaoKf91CAAhavWfopBQgyuttX(vyw2KfnZsAkl2XI(AonTdGk4cNNnvdmQzzXYiw0YIDSOVMtt7aOcUW5zt1aJMXxnxQ8Eu8t95MLflAzzil6R50GYvGnbMPylOnQJP6ZurnYBGKPPy)kmliIfKbqtSJywgXIwwgYI(AonuqDwykJHkVnnf7xHzztwqganXoIzjnLf91CAOG6SWuwTkVnnf7xHzztwqganXoIzjnLLHSyhl6R50qb1zHPSAvEBwwSKMYIDSOVMtdfuNfMYyOYBZYILrSOLf7y5DfvVbdv4)cKHkxxrGSmkbiiHd9z9hSsaIkybE)blwMWMfxPybe(yw(D)zj2rHWSGxnXYVtrzXBQ2(zPPzt4DcKfB7uXcQjhavWfMfuBt1aJYYUJzrryml)UxSOzwWuaZstX(vxHKfyZYVtSObXwqBuZY4Gfil6R5KLdZIRdxplpKLPRuSaNtwGnlEfLfniOolmXYHzX1HRNLhYcHyRRPeGa8oxEmLaee(5MIW11umvpo5t2c6ozWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGdzXow0xZPHcQZctzmu5TzzXIwwSJf91CAOG6SWuwTkVnllwgXIwwSJL3vu9gmuH)lqgQCDfbYIwwSJLEv0e2ijZFXKnyxzWM8y9RaP2qLRRiWeGGeo0N1FWkbiQGf49hSy539NLWofqbZYnzjkCXI3elW1JpqIfkOolmXYdzbwQOSacFw(DQjwGnlhYc2el)(HzX297SaeQW)fOeGa8oxEmLaee(z46XhiLPG6SWuYNSfeAYGtasLRRiWKXLa0d)bReGXqynVMsagIguu(9gj94KTGwcWqFp1NNaCil6R50qb1zHPmgQ820uSFfMLnzPPy)kmlPPSOVMtdfuNfMYQv5TPPy)kmlBYstX(vywstzbG3NRRidi8ZW1Jpqktb1zHjwgXIwwAA2eE31velAz59gj9M)IP8dZGhXYMSGM9SOLf3kh2PakSOLfaEFUUImGWp3ueUUMIP6XjabjCOpR)GvcWia8zXvkwEVrspMfB3VFflieVaP4lWIT73HRNfiaQdUL1virWVtS46qaelbybE)blCYNSfnnzWjaPY1veyY4sa6H)Gvcq8QMxtjad99uFEcWHSOVMtdfuNfMYyOYBttX(vyw2KLMI9RWSKMYI(AonuqDwykRwL3MMI9RWSSjlnf7xHzjnLfaEFUUImGWpdxp(aPmfuNfMyzelAzPPzt4DxxrSOLL3BK0B(lMYpmdEelBYcA2ZIwwCRCyNcOWIwwa4956kYac)Ctr46AkMQhNamenOO87ns6XjBbTKpzldGKbNaKkxxrGjJlbOh(dwjaXpPuENNkVPeGH(EQppb4qw0xZPHcQZctzmu5TPPy)kmlBYstX(vywstzrFnNgkOolmLvRYBttX(vyw2KLMI9RWSKMYcaVpxxrgq4NHRhFGuMcQZctSmIfTS00Sj8URRiw0YY7ns6n)ft5hMbpILnzbn0nlAzXTYHDkGclAzbG3NRRidi8ZnfHRRPyQECcWq0GIYV3iPhNSf0s(KTG2yjdobivUUIatgxcqOvcqm9ja9WFWkbiaVpxxrjab4QfLamabqLxVbav)E0MfTSyhl9QOjSrsg8vZLkVhf)uFUHkxxrGSOLf7yPxfnHnsYeUoOOmCMv3KYEbMbj)3nu56kcKfTSeGqfi0wz0PgtnkxH00KdgLfTSeGqfi0wzAhavWfopBQgyuttoyuw0YIDSOVMttWZxfmllw0YYqwC83UkBbTrnlBYIMIqzjnLf91CA0vqiOAHFZYILrjabjCOpR)GvcWia8zPpK7pl60e2elO2MQbgLLBYY9SydUuGS4kf0glrHlwEilnnBcVZIIWywax9vizb12unWOSm83pmlWsfLLD3YIkml2UFhUEwaE1CPyb1SO4N6ZhLaeG35YJPeGfmVhf)uFEM8wfndc)KpzlOHwYGtasLRRiWKXLam03t95jab4956kYuW8Eu8t95zYBv0mi8zrllnf7xHzbrSy)yja9WFWkbymewZRPKpzlOzFYGtasLRRiWKXLam03t95jab4956kYuW8Eu8t95zYBv0mi8zrllnf7xHzbrSG2aibOh(dwjaXRAEnL8jBbTiMm4eGu56kcmzCja9WFWkb4e2bkdN5Y)vtjabjCOpR)GvcWXdtSGAHBHfyXsaKfB3Vdxplb3Y6kKjad99uFEcq3kh2PakjFYwqdHtgCcqQCDfbMmUeGE4pyLaKITG2OoRdlWeGGeo0N1FWkb44Hjw0GylOnQzzCWcKfB3VZIxrzrblKSqfCHCNfLJ)RqYIgeuNfMyXlqw(oklpKf1vel3ZYYIfB3VZcczPWEZIxGSGQTI(XVcjad99uFEcWHSeGqfi0wzcE(QGPPy)kmliGf91CAcE(QGbC1(FWIfeWsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYYGybn7zztwcqOceARmuSf0g1zDybAaxT)hSybbSG2ySmIL0uw0xZPj45RcMMI9RWSSjlAklPPSa2Rd0uWCaeN8jBbnnNm4eGu56kcmzCjaHwjaX0Na0d)bReGa8(CDfLaeGRwucqh)TRYwqBuZYMSmagJfnHLHSyVrZSmiw0xZPzU6Oz4mtQvrg87buyrtyXEwgeluqDwyYCvwTkVzzucqqch6Z6pyLaei9ywSTtflBfJqybVdxkqw0jwaxXweilpKLc(SabqDWTyzyeGSOceZcSyb1U6OSaNSObQvrS4fil)oXIgeuNfMgLaeG35YJPeGo2kdUITs(KTGg6ozWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeG2XcyVoqtbZbqmlAzzila8(CDfzcG5aSaV)GflAzXow0xZPj45RcMLflAzzil2XcM(SoSwyZFuBVMMT3kWsAkluqDwyYCvwTkVzjnLfkOolmzWqL35Iq8ZYiw0YYqwgYYqwa4956kY4yRm4k2IL0uwcqau51BQd5(NNoXsAkldzjabqLxVbLO95flAzjaHkqOTYqXwqBuN1HfOPjhmklJyjnLLEv0e2ijZFXKnyxzWM8y9RaP2qLRRiqwgXIwwaHVbVQ51KPPy)kmlBYIMYIwwaHVjgcR51KPPy)kmlBYYaGfTSmKfq4BWpPuENNkVjttX(vyw2Kf0gJL0uwSJL3vu9g8tkL35PYBYqLRRiqwgXIwwa4956kY879PuzmrOqD2MFplAz59gj9M)IP8dZGhXYMSOVMttWZxfmGR2)dwSmiwgZGqzjnLf91CA0vqiOAHFZYIfTSOVMtJUccbvl8BAk2VcZcIyrFnNMGNVkyaxT)hSybbSmKf0SNLbXsVkAcBKKXQVyydEUk7DWRlKTwkS3gQCDfbYYiwgXsAkldzHIW1zzrGgk2kAtUkdBWYRaXIwwcqOceARmuSv0MCvg2GLxbY0uSFfMfeXcAOBekliGLHSOzwgel9QOjSrsg8vZLkVhf)uFUHkxxrGSmILrSmIfTSmKLHSyhlbiaQ86n1HC)ZtNyjnLLHSaW7Z1vKjalaquOmiHJwbwstzjaHkqOTYeGfaiku(3Pm2667XMMI9RWSGiwqtZSmIfTSmKf7yPxfnHnsYO7kVcugoZUsL)9RqInu56kcKL0uwC83UkBbTrnliIfnpglAzjaHkqOTYeGfaiku(3Pm2667XMMCWOSmILrSKMYY8qU)5MI9RWSGiwcqOceARmbybaIcL)DkJTU(ESPPy)kmlJyjnLfDigZIwwMhY9p3uSFfMfeXI(AonbpFvWaUA)pyXccybn7zzqS0RIMWgjzS6lg2GNRYEh86czRLc7THkxxrGSmkbiiHd9z9hSsaoEyIfuTv0p(vGfB3VZcQGfaike6hGDfytGSa0667XS4filGWA7NfiaQT13tSGqwkS3SaBwSTtflJtbHGQf(zXgCPazHqS11el60e2elOAROF8RaleITUMWgwIGCuiwWRMy5HSq1tnlolOZQ8MfniOolmXITDQyzHpKfld2EnLf7TcS4filUsXcQIaywSDkfl6uagtS0KdgLfmewSqfCHCNfWvFfsw(DIf91CYIxGSacFml7oaIfDIkwWR58chvVkklnnBcVtGMeGa8oxEmLamaMdWc8(dwz8N8jBbneAYGtasLRRiWKXLa0d)bReGTdGk4cNNnvdmAcqqch6Z6pyLaC8WelO2MQbgLfB3VZcQ2k6h)kWYQuegZcQTPAGrzXgCPazr54NffSqsnl)UxSGQTI(XVcAKLFNkwwyIfDAcBkbyOVN6ZtaQVMttWZxfmnf7xHzztwqtZSKMYI(AonbpFvWaUA)pyXcIyXEekliGLEv0e2ijJvFXWg8Cv27GxxiBTuyVnu56kcKLbXcA2ZIwwa4956kYeaZbybE)bRm(t(KTGMMMm4eGu56kcmzCjad99uFEcqaEFUUImbWCawG3FWkJFw0YYqw0xZPj45RcgWv7)blw2mswShHYccyPxfnHnsYy1xmSbpxL9o41fYwlf2BdvUUIazzqSGM9SKMYIDSeGaOYR3aGQFpAZYiwstzrFnNM2bqfCHZZMQbg1SSyrll6R500oaQGlCE2unWOMMI9RWSGiwgaSGawcWcCDVXQPWHPSRoKvmvV5VykdWvlIfeWYqwSJf91CA0vqiOAHFZYIfTSyhlVRO6n43BfSbnu56kcKLrja9WFWkbyGue(pxLD1HSIP6t(KTG2aizWjaPY1veyY4sag67P(8eGa8(CDfzcG5aSaV)Gvg)ja9WFWkb4vbVl)pyL8jBX(XsgCcqQCDfbMmUeGqReGy6ta6H)GvcqaEFUUIsacWvlkbyacvGqBLj45RcMMI9RWSSjlOnglPPSyhla8(CDfzcWcaefkds4OvGfTSeGaOYR3uhY9ppDIL0uwa71bAkyoaItacs4qFw)bReGdq9(CDfXYctGSalwC9tD)ryw(D)zXMxplpKfDIfSdGazzcBwq1wr)4xbwWqw(D)z53POS4nvpl2C8tGSGA(c)SOttytS87uCcqaENlpMsaIDauEc7CWZxfs(KTypAjdobivUUIatgxcqp8hSsaoxD0mCMj1QOeGGeo0N1FWkb44HjmlOwOgWYnz5kw8IfniOolmXIxGS89rywEilQRiwUNLLfl2UFNfeYsH9wJSGQTI(XVcAKfni2cAJAwghSazXlqw2kOB9haIfG28oobyOVN6Ztasb1zHjZvzVIYIwwgYIJ)2vzlOnQzbrSmaSNfnHf91CAMRoAgoZKAvKb)EafwgelAML0uw0xZPPDaubx48SPAGrnllwgXIwwgYI(Aonw9fdBWZvzVdEDHS1sH92aWvlIfeXI9i8ySKMYI(AonbpFvW0uSFfMLnzrtzzelAzbG3NRRid2bq5jSZbpFvGfTSmKf7yjabqLxVPOqdvWgKL0uwaHVXbDR)aqzSnVJZGESJKm)fq5kKSmIfTSmKf7yjabqLxVbav)E0ML0uw0xZPPDaubx48SPAGrnnf7xHzbrSmayrtyzilimldILEv0e2ijd(Q5sL3JIFQp3qLRRiqwgXIww0xZPPDaubx48SPAGrnllwstzXow0xZPPDaubx48SPAGrnllwgXIwwgYIDSeGaOYR3Gs0(8IL0uwcqOceARmuSf0g1zDybAAk2VcZYMSy)ySmIfTS8EJKEZFXu(HzWJyztw0mlPPSOdXyw0YY8qU)5MI9RWSGiwqBSKpzl2BFYGtasLRRiWKXLa0d)bReG437PRujabjCOpR)GvcWXdtSebx0VZcW37PRuSy1WaMLBYcW37PRuSC4A7NLLvcWqFp1NNauFnNgyr)ooBrDGS(dwMLflAzrFnNg8790vkttZMW7UUIs(KTyFetgCcqQCDfbMmUeGE4pyLam4vGuz91CMam03t95ja1xZPb)ERGnOPPy)kmliIfnZIwwgYI(AonuqDwykJHkVnnf7xHzztw0mlPPSOVMtdfuNfMYQv5TPPy)kmlBYIMzzelAzXXF7QSf0g1SSjldGXsaQVMZC5Xucq87Tc2GjabjCOpR)Gvcqu5vGuSa89wbBqwUjl3ZYUJzrryml)UxSOzmlnf7xDfsnYsu4IfVjw8NLbWyiGLTIriS4fil)oXsy1nvplAqqDwyILDhZIMraMLMI9RUczYNSf7r4KbNaKkxxrGjJlbOh(dwjadEfivwFnNjad99uFEcW3vu9MRcEx(FWYqLRRiqw0YIDS8UIQ3uKTCmewgQCDfbYIwwgGJLHSmKLio2ySOjS44VDv2cAJAwqali8ySOjSGPpRdRf28h12RPz7TcSmiwq4XyzelONLHSGWSGEwWwKsL3D8tSmIfnHLaeQaH2ktawaGOq5FNYyRRVhBAk2VcZYiwqeldWXYqwgYsehBmw0ewC83UkBbTrnlAcl6R50y1xmSbpxL9o41fYwlf2BdaxTiwqali8ySOjSGPpRdRf28h12RPz7TcSmiwq4XyzelONLHSGWSGEwWwKsL3D8tSmIfnHLaeQaH2ktawaGOq5FNYyRRVhBAk2VcZYiw0YsacvGqBLj45RcMMI9RWSSjlrCmw0YI(Aonw9fdBWZvzVdEDHS1sH92aWvlIfeXI9OnglAzrFnNgR(IHn45QS3bVUq2APWEBa4QfXYMSeXXyrllbiubcTvMaSaarHY)oLXwxFp20uSFfMfeXccpglAzzEi3)CtX(vyw2KLaeQaH2ktawaGOq5FNYyRRVhBAk2VcZccybDZIwwgYsVkAcBKKjqkc)NRYyRRVhBOY1veilPPSaW7Z1vKjalaquOmiHJwbwgLauFnN5YJPeGw9fdBWZvzVdEDHS1sH9obiiHd9z9hSsaIkVcKILFNybHSuyVzrFnNSCtw(DIfRggyXgCPaRTFwuxrSSSyX297S87elfH4NL)IjwqfSaarHyjaJjmlW5KLaOHLbVFyww4LRurzbwQOSS7wwuHzbC1xHKLFNyzCOJj5t2I9AozWjaPY1veyY4sacTsaIPpbOh(dwjab4956kkbiaxTOeGbiaQ86n1HC)ZtNyrll9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilAzrFnNgR(IHn45QS3bVUq2APWEBa4QfXccyXXF7QSf0g1SGawIilBgjlrCSXyrlla8(CDfzcWcaefkds4OvGfTSeGqfi0wzcWcaefk)7ugBD99yttX(vywqelo(BxLTG2OMf0ZsehJLbXcYaOj2rmlAzXowa71bAkyoaIzrlluqDwyYCv2ROSOLfh)TRYwqBuZYMSaW7Z1vKjalaquOSJTyrllbiubcTvMGNVkyAk2VcZYMSO5eGGeo0N1FWkbiq6XSyBNkwqilf2BwW7WLcKfDIfRggceilK3QOS8qw0jwCDfXYdzzHjwqfSaarHybwSeGqfi0wXYqnaJP6pxPIYIofGXeMLVxel3KfWvS1vizzRyeclf0gl2oLIfxPG2yjkCXYdzXI6jfEvuwO6PMfeYsH9MfVaz53PILfMybvWcaefAucqaENlpMsaA1Wq2APWENjVvrt(KTyp6ozWjaPY1veyY4sa6H)Gvcq8790vQeGGeo0N1FWkb44Hjwa(EpDLIfB3VZcWNukVzjc038zb2S82RPSGWwbw8cKLcYcW3BfSb1il22PILcYcW37PRuSCywwwSaBwEilwnmWcczPWEZITDQyX1HaiwgaJXYwXiKHWMLFNyH8wfLfeYsH9MfRggybG3NRRiwomlFVOrSaBwCql)paelyBEhZYUJzrtraMcywAk2V6kKSaBwomlxXYuDi3)eGH(EQppb4qwExr1BWpPuENb7B(gQCDfbYsAkly6Z6WAHn)rT9AAgHTcSmIfTSyhlVRO6n43BfSbnu56kcKfTSOVMtd(9E6kLPPzt4DxxrSOLf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKfTSmKf91CAS6lg2GNRYEh86czRLc7TbGRwelBgjl2R5Xyrll2XI(AonbpFvWSSyrlldzbG3NRRiJJTYGRylwstzrFnNguUcSjWmfBbTrDmvFMkQrEdKmllwstzbG3NRRiJvddzRLc7DM8wfLLrSKMYYqwcqau51Bkk0qfSbzrllVRO6n4NukVZG9nFdvUUIazrlldzbe(gh0T(daLX28ood6XosY0uSFfMLnzrtzjnLfp8hSmoOB9hakJT5DCg0JDKK5Q8uDi3FwgXYiwgXIwwgYsacvGqBLj45RcMMI9RWSSjlOnglPPSeGqfi0wzcWcaefk)7ugBD99yttX(vyw2Kf0gJLrjFYwShHMm4eGu56kcmzCja9WFWkbi(9gVAKucqqch6Z6pyLamcSITWSSvmcHfDAcBIfublaquiww4RqYYVtSGkybaIcXsawG3FWILhYsyNcOWYnzbvWcaefILdZIh(LRurzX1HRNLhYIoXsWXFcWqFp1NNaeG3NRRiJvddzRLc7DM8wfn5t2I9AAYGtasLRRiWKXLa0d)bReGfzlhdHvcqqch6Z6pyLaC8WelrqqyHzX2ovSefUyXBIfxhUEwEi69Myj4wwxHKLWU3ijmlEbYsSJcXcE1el)ofLfVjwUIfVyrdcQZctSG)tPyzcBwqnlcc9O2iOeGH(EQppbOBLd7uafw0YYqwc7EJKWSejl2ZIwwAkS7nsk)xmXcIyrZSKMYsy3BKeMLizjISmk5t2I9dGKbNaKkxxrGjJlbyOVN6Zta6w5WofqHfTSmKLWU3ijmlrYI9SOLLMc7EJKY)ftSGiw0mlPPSe29gjHzjswIilJyrlldzrFnNgkOolmLvRYBttX(vyw2KfcXuy9u(VyIL0uw0xZPHcQZctzmu5TPPy)kmlBYcHykSEk)xmXYOeGE4pyLaC3vZCmewjFYwI4yjdobivUUIatgxcWqFp1NNa0TYHDkGclAzzilHDVrsywIKf7zrllnf29gjL)lMybrSOzwstzjS7nscZsKSerwgXIwwgYI(AonuqDwykRwL3MMI9RWSSjleIPW6P8FXelPPSOVMtdfuNfMYyOYBttX(vyw2KfcXuy9u(VyILrja9WFWkb4CPu5yiSs(KTer0sgCcqQCDfbMmUeGE4pyLae)EJxnskbiiHd9z9hSsaoEyIfGV34vJKyjcUOFNfRggWS4filGRylw2kgHWITDQybvBf9JFf0ilAqSf0g1SmoybQrw(DILbOu97rBw0xZjlhMfxhUEwEiltxPyboNSaBwIcxBdYsWTyzRyescWqFp1NNaKcQZctMRYEfLfTSmKf91CAGf974CqrENbC4dwMLflPPSOVMtdkxb2eyMITG2OoMQptf1iVbsMLflPPSOVMttWZxfmllw0YYqwSJLaeavE9guI2NxSKMYsacvGqBLHITG2OoRdlqttX(vyw2KfnZsAkl6R50e88vbttX(vywqelidGMyhXSmiwMkiSzzilo(BxLTG2OMf0ZcaVpxxrgmohG4NLrSmIfTSmKf7yjabqLxVbav)E0ML0uw0xZPPDaubx48SPAGrnnf7xHzbrSGmaAIDeZYGyjqNILHSmKfh)TRYwqBuZccybHhJLbXY7kQEZC1rZWzMuRImu56kcKLrSGEwa4956kYGX5ae)SmIfeWsezzqS8UIQ3uKTCmewgQCDfbYIwwSJLEv0e2ijd(Q5sL3JIFQp3qLRRiqw0YI(AonTdGk4cNNnvdmQzzXsAkl6R500oaQGlCE2unWOz8vZLkVhf)uFUzzXsAkldzrFnNM2bqfCHZZMQbg10uSFfMfeXIh(dwg8798AYqiMcRNY)ftSOLfSfPu5Dh)eliILXmimlPPSOVMtt7aOcUW5zt1aJAAk2VcZcIyXd)blJT2)DdHykSEk)xmXsAkla8(CDfzUiemhGf49hSyrllbiubcTvMRWHE9UUIYr4YRFfNbjaxGmn5GrzrllueUollc0Cfo0R31vuocxE9R4mib4celJyrll6R500oaQGlCE2unWOMLflPPSyhl6R500oaQGlCE2unWOMLflAzXowcqOceARmTdGk4cNNnvdmQPjhmklJyjnLfaEFUUImo2kdUITyjnLfDigZIwwMhY9p3uSFfMfeXcYaOj2rmldILaDkwgYIJ)2vzlOnQzb9SaW7Z1vKbJZbi(zzelJs(KTer7tgCcqQCDfbMmUeGE4pyLae)EJxnskbiiHd9z9hSsao4oklpKLyhfILFNyrNWplWjlaFVvWgKf9OSGFpGYviz5EwwwSeHRlGIkklxXIxrzrdcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceycWqFp1NNa8DfvVb)ERGnOHkxxrGSOLf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKfTSmKf91CAWV3kydAwwSKMYIJ)2vzlOnQzztwgaJXYiw0YI(Aon43BfSbn43dOWcIyjISOLLHSOVMtdfuNfMYyOYBZYIL0uw0xZPHcQZctz1Q82SSyzelAzrFnNgR(IHn45QS3bVUq2APWEBa4QfXcIyXEe6ySOLLHSeGqfi0wzcE(QGPPy)kmlBYcAJXsAkl2XcaVpxxrMaSaarHYGeoAfyrllbiaQ86n1HC)ZtNyzuYNSLigXKbNaKkxxrGjJlbi0kbiM(eGE4pyLaeG3NRROeGaC1Isasb1zHjZvz1Q8MLbXIMYc6zXd)bld(9EEnzietH1t5)Ijwqal2XcfuNfMmxLvRYBwgeldzbDZccy5DfvVbdxQmCM)DkpHnHFdvUUIazzqSerwgXc6zXd)blJT2)DdHykSEk)xmXccyzmdcRzwqplylsPY7o(jwqalJz0mldIL3vu9MY)vt4SUR8kqgQCDfbMaeKWH(S(dwja1a8FX(tyw2H2yjEf2zzRyeclEtSG0VIazXIAwWuawGgwIGlvuwEhfcZIZcUCl8o8zzcBw(DILWQBQEwW3V8)Gflyil2GlfyT9ZIoXIhcR2FILjSzr5nsQz5VyA2EmHtacW7C5XucqhBHqOgifs(KTereozWjaPY1veyY4sa6H)Gvcq87nE1iPeGGeo0N1FWkbyeyfBXcW3B8QrsSCflEXIgeuNfMyXXSGHWIfhZIfeJpDfXIJzrblKS4ywIcxSy7ukwOcKLLfl2UFNfnDmeWITDQyHQN6RqYYVtSueIFw0GG6SWKgzbewB)SOONL7zXQHbwqilf2BnYciS2(zbcGAB99elEXseCr)olwnmWIxGSybHkw0PjSjwq1wr)4xbw8cKfni2cAJAwghSatag67P(8eG2XsVkAcBKK5VyYgSRmytES(vGuBOY1veilAzzil6R50y1xmSbpxL9o41fYwlf2BdaxTiwqel2JqhJL0uw0xZPXQVyydEUk7DWRlKTwkS3gaUArSGiwSxZJXIwwExr1BWpPuENb7B(gQCDfbYYiw0YYqwOG6SWK5QmgQ8MfTS44VDv2cAJAwqala8(CDfzCSfcHAGuGLbXI(AonuqDwykJHkVnnf7xHzbbSacFZC1rZWzMuRIm)fqbNBk2VILbXI9gnZYMSOPJXsAkluqDwyYCvwTkVzrllo(BxLTG2OMfeWcaVpxxrghBHqOgifyzqSOVMtdfuNfMYQv5TPPy)kmliGfq4BMRoAgoZKAvK5Vak4CtX(vSmiwS3Ozw2KLbWySmIfTSyhl6R50al63XzlQdK1FWYSSyrll2XY7kQEd(9wbBqdvUUIazrlldzjaHkqOTYe88vbttX(vyw2KfeklPPSGHlL(vGMFVpLkJjcfQnu56kcKfTSOVMtZV3NsLXeHc1g87buybrSeXiYIMWYqw6vrtyJKm4RMlvEpk(P(CdvUUIazzqSyplJyrllZd5(NBk2VcZYMSG2yJXIwwMhY9p3uSFfMfeXI9JnglPPSa2Rd0uWCaeZYiw0YYqwSJLaeavE9guI2NxSKMYsacvGqBLHITG2OoRdlqttX(vyw2Kf7zzuYNSLiQ5KbNaKkxxrGjJlbOh(dwjalYwogcReGGeo0N1FWkb44HjwIGGWcZYvS4vuw0GG6SWelEbYc2bqSGAMRMia1UukwIGGWILjSzbvBf9JFfyXlqwgGDfytGSObXwqBuht1ByzRkmKLfMyzlrqS4filO2iiw8NLFNyHkqwGtwqTnvdmklEbYciS2(zrrplrGM8y9RaPMLPRuSaNZeGH(EQppbOBLd7uafw0YcaVpxxrgSdGYtyNdE(QalAzzil6R50qb1zHPSAvEBAk2VcZYMSqiMcRNY)ftSKMYI(AonuqDwykJHkVnnf7xHzztwietH1t5)IjwgL8jBjIO7KbNaKkxxrGjJlbyOVN6Zta6w5WofqHfTSaW7Z1vKb7aO8e25GNVkWIwwgYI(AonuqDwykRwL3MMI9RWSSjleIPW6P8FXelPPSOVMtdfuNfMYyOYBttX(vyw2KfcXuy9u(VyILrSOLLHSOVMttWZxfmllwstzrFnNgR(IHn45QS3bVUq2APWEBa4QfXcIIKf7rBmwgXIwwgYIDSeGaOYR3aGQFpAZsAkl6R500oaQGlCE2unWOMMI9RWSGiwgYIMzrtyXEwgel9QOjSrsg8vZLkVhf)uFUHkxxrGSmIfTSOVMtt7aOcUW5zt1aJAwwSKMYIDSOVMtt7aOcUW5zt1aJAwwSmIfTSmKf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKL0uwietH1t5)Ijwqel6R508xmzd2vgSjpw)kqQnnf7xHzjnLf7yrFnNM)IjBWUYGn5X6xbsTzzXYOeGE4pyLaC3vZCmewjFYwIicnzWjaPY1veyY4sag67P(8eGUvoStbuyrlla8(CDfzWoakpHDo45RcSOLLHSOVMtdfuNfMYQv5TPPy)kmlBYcHykSEk)xmXsAkl6R50qb1zHPmgQ820uSFfMLnzHqmfwpL)lMyzelAzzil6R50e88vbZYIL0uw0xZPXQVyydEUk7DWRlKTwkS3gaUArSGOizXE0gJLrSOLLHSyhlbiaQ86nOeTpVyjnLf91CAq5kWMaZuSf0g1Xu9zQOg5nqYSSyzelAzzil2XsacGkVEdaQ(9OnlPPSOVMtt7aOcUW5zt1aJAAk2VcZcIyrZSOLf91CAAhavWfopBQgyuZYIfTSyhl9QOjSrsg8vZLkVhf)uFUHkxxrGSKMYIDSOVMtt7aOcUW5zt1aJAwwSmIfTSmKf7yPxfnHnsY8xmzd2vgSjpw)kqQnu56kcKL0uwietH1t5)Ijwqel6R508xmzd2vgSjpw)kqQnnf7xHzjnLf7yrFnNM)IjBWUYGn5X6xbsTzzXYOeGE4pyLaCUuQCmewjFYwIOMMm4eGu56kcmzCjabjCOpR)GvcWXdtSGAa1awGflbWeGE4pyLa0M39b7mCMj1QOKpzlrCaKm4eGu56kcmzCja9WFWkbi(9EEnLaeKWH(S(dwjahpmXcW3751elpKfRggybiu5nlAqqDwysJSGQTI(XVcSS7ywuegZYFXel)UxS4SGA0(VZcHykSEIffnFwGnlWsfLf0zvEZIgeuNfMy5WSSSmSGAC)old2EnLf7TcSq1tnlolaHkVzrdcQZctSCtwqilf2BwW)PuSS7ywuegZYV7fl2J2ySGFpGcMfVazbvBf9JFfyXlqwqfSaarHyz3bqSedBILF3lwqdHIzbvrawAk2V6kKgwgpmXIRdbqSyVMhdDXYUJFIfWvFfswqTnvdmklEbYI92Bp6ILDh)el2UFhUEwqTnvdmAcWqFp1NNaKcQZctMRYQv5nlAzXow0xZPPDaubx48SPAGrnllwstzHcQZctgmu5DUie)SKMYYqwOG6SWKXRO5Iq8ZsAkl6R50e88vbttX(vywqelE4pyzS1(VBietH1t5)Ijw0YI(AonbpFvWSSyzelAzzil2XcM(SoSwyZFuBVMMT3kWsAkl9QOjSrsgR(IHn45QS3bVUq2APWEBOY1veilAzrFnNgR(IHn45QS3bVUq2APWEBa4QfXcIyXE0gJfTSeGqfi0wzcE(QGPPy)kmlBYcAiuw0YYqwSJLaeavE9M6qU)5PtSKMYsacvGqBLjalaquO8VtzS113Jnnf7xHzztwqdHYYiw0YYqwSJL2dK5BOsXsAklbiubcTvgDQXuJYvinnf7xHzztwqdHYYiwgXsAkluqDwyYCv2ROSOLLHSOVMtJnV7d2z4mtQvrMLflPPSGTiLkV74NybrSmMbH1mlAzzil2XsacGkVEdaQ(9OnlPPSyhl6R500oaQGlCE2unWOMLflJyjnLLaeavE9gau97rBw0Yc2IuQ8UJFIfeXYygeMLrjFYwq4XsgCcqQCDfbMmUeGGeo0N1FWkb44HjwqnA)3zb(7uB7Wel22VWolhMLRybiu5nlAqqDwysJSGQTI(XVcSaBwEilwnmWc6SkVzrdcQZctja9WFWkbOT2)9KpzlimAjdobivUUIatgxcqqch6Z6pyLae16k1V3ReGE4pyLaSxv2d)bRS6WFcq1H)C5XucWPRu)EVs(Kp5tacGA8bRKTy)y2B)yren0DcqBExxHeNae1yROM2Y4VLbigqwyzW7elxSfSFwMWMLTHwur92S0ueUUMazbdJjw81dJ9NazjS7fscB4nqNRiwSFazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kILioGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVbVbQXwrnTLXFldqmGSWYG3jwUyly)SmHnlBdstFP(TzPPiCDnbYcggtS4Rhg7pbYsy3lKe2WBGoxrSGUhqwqfSaq9tGSa8Irfl4O17iMf0flpKf0z5SaEao8blwGwu7pSzzi6hXYq0q8idVb6CfXc6EazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLH2J4rgEd05kIfe6aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrdXJm8gOZvelA6aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwgApIhz4nqNRiw00bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwgadilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmmIiEKH3aDUIyzamGSGkybG6Nazz7VVcf6nOzq9Tz5HSS93xHc9MhndQVnldThXJm8gOZveldGbKfublau)eilB)9vOqVXEdQVnlpKLT)(kuO382Bq9TzzO9iEKH3aDUIybTXgqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIybn0gqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIybn7hqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIybTioGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVb6CfXcAAEazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kIf0q3dilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42Sm0EepYWBGoxrSGg6EazbvWca1pbYY2FFfk0BqZG6BZYdzz7VVcf6npAguFBwgApIhz4nqNRiwqdDpGSGkybG6Nazz7VVcf6n2Bq9Tz5HSS93xHc9M3EdQVnldrdXJm8gOZvelOHqhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzO9iEKH3aDUIybne6aYcQGfaQFcKLT)(kuO3GMb13MLhYY2FFfk0BE0mO(2SmenepYWBGoxrSGgcDazbvWca1pbYY2FFfk0BS3G6BZYdzz7VVcf6nV9guFBwgApIhz4n4nqn2kQPTm(BzaIbKfwg8oXYfBb7NLjSzzBRMcWyD)3MLMIW11eilyymXIVEyS)eilHDVqsydVb6CfXsehqwqfSaq9tGSS93xHc9g0mO(2S8qw2(7RqHEZJMb13MLHreXJm8gOZveli8aYcQGfaQFcKLT)(kuO3yVb13MLhYY2FFfk0BE7nO(2SmmIiEKH3aDUIyrthqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzXFw0Giy0HLHOH4rgEdEduJTIAAlJ)wgGyazHLbVtSCXwW(zzcBw22H02S0ueUUMazbdJjw81dJ9NazjS7fscB4nqNRiwqBazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kIf7hqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyX(bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBw8NfnicgDyziAiEKH3aDUIyjIdilOcwaO(jqw2(DfvVb13MLhYY2VRO6nOUHkxxrGBZYq0q8idVb6CfXsehqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzOMI4rgEd05kIf09aYcQGfaQFcKfGxmQybhTEhXSGUqxS8qwqNLZsmeCPwywGwu7pSzzi6AeldrdXJm8gOZvelO7bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgApIhz4nqNRiwqOdilOcwaO(jqwaEXOIfC06DeZc6cDXYdzbDwolXqWLAHzbArT)WMLHORrSmenepYWBGoxrSGqhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyrthqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyzamGSGkybG6Nazb4fJkwWrR3rmlOlwEilOZYzb8aC4dwSaTO2FyZYq0pILH2J4rgEd05kIf0SFazbvWca1pbYcWlgvSGJwVJywqxS8qwqNLZc4b4WhSybArT)WMLHOFeldrdXJm8gOZvelOHWdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSGMMhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIybn09aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldThXJm8gOZvelOPPdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSy)ydilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42Sm0EepYWBGoxrSyV9dilOcwaO(jqwaEXOIfC06DeZc6ILhYc6SCwapah(GflqlQ9h2Sme9JyziAiEKH3aDUIyXEeEazbvWca1pbYcWlgvSGJwVJywqxS8qwqNLZc4b4WhSybArT)WMLHOFeldThXJm8gOZvel2JWdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSyp6EazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kIf7rOdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSy)ayazbvWca1pbYcWlgvSGJwVJywqxS8qwqNLZc4b4WhSybArT)WMLHOFeldThXJm8gOZvelrCSbKfublau)eilaVyuXcoA9oIzbDXYdzbDwolGhGdFWIfOf1(dBwgI(rSmenepYWBWBGASvutBz83YaedilSm4DILl2c2pltyZY2txP(9ETnlnfHRRjqwWWyIfF9Wy)jqwc7EHKWgEd05kIf7hqwqfSaq9tGSa8Irfl4O17iMf0flpKf0z5SaEao8blwGwu7pSzzi6hXYq0q8idVbVbQXwrnTLXFldqmGSWYG3jwUyly)SmHnlBJ)TzPPiCDnbYcggtS4Rhg7pbYsy3lKe2WBGoxrSy)aYcQGfaQFcKLT7vrtyJKmO(2S8qw2UxfnHnsYG6gQCDfbUnldrOiEKH3aDUIyjIdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSGWdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSGUhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzXFw0Giy0HLHOH4rgEd05kIf0gBazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLH2J4rgEd05kIf0q4bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgIgIhz4nqNRiwqdDpGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYqnJ4rgEd05kIf0qOdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSGMMoGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVb6CfXI9OnGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVb6CfXI9i8aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwgIWiEKH3aDUIyXEeEazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kIf718aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwgIgIhz4nqNRiwSxZdilOcwaO(jqw2UxfnHnsYG6BZYdzz7Ev0e2ijdQBOY1ve42SmenepYWBGoxrSyp6EazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEd05kILiI2aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwggrepYWBGoxrSer0gqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzziAiEKH3aDUIyjI2pGSGkybG6Nazz7Ev0e2ijdQVnlpKLT7vrtyJKmOUHkxxrGBZYq0q8idVb6CfXseJ4aYcQGfaQFcKfGxmQybhTEhXSGUy5HSGolNfWdWHpyXc0IA)Hnldr)iwggrepYWBGoxrSereEazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLH2J4rgEd05kILiIUhqwqfSaq9tGSSDVkAcBKKb13MLhYY29QOjSrsgu3qLRRiWTzzO9iEKH3aDUIyjIi0bKfublau)eilB3RIMWgjzq9Tz5HSSDVkAcBKKb1nu56kcCBwgApIhz4nqNRiwI4ayazbvWca1pbYY29QOjSrsguFBwEilB3RIMWgjzqDdvUUIa3MLHOH4rgEdEJXp2c2pbYc6Mfp8hSyrD4hB4nsaA1W5POeGAOgYY4CLxbILiqVoqEdnudzjcY7WolOHq1il2pM92ZBWBOHAilOA3lKeEa5n0qnKfnHLTccsGSaeQ8MLXrESH3qd1qw0ewq1UxijqwEVrsF(MSeCmHz5HSeIguu(9gj9ydVHgQHSOjSGAIIHaiqwwvrbcJ9okla8(CDfHzz4ziJgzXQjaz87nE1ijw0KnzXQjag87nE1iPrgEdnudzrtyzRaGhilwnfC8FfswqnA)3z5MSC)2yw(DIfBnSqYIgeuNfMm8gAOgYIMWseKJcXcQGfaikel)oXcqRRVhZIZI6(xrSedBILPIq8PRiwgEtwIcxSS7G12pl73ZY9SGV4L69IGlSkkl2UFNLXfbV1bZccybvKIW)5kw2Q6qwXu9AKL73gKfmkN1idVHgQHSOjSeb5OqSedXplBppK7FUPy)k82SGdu59bXS4wwQOS8qw0HymlZd5(JzbwQOgEdnudzrtyzWn5pldggtSaNSmoLVZY4u(olJt57S4ywCwWwu4CflFFfk0B4n0qnKfnHLiylQOMLHNHmAKfuJ2)DnYcQr7)Ugzb4798AAelXoiXsmSjwAcFQJQNLhYc5T6OMLamw3Fnb)E)gEdnudzrtyb1EiMLbyxb2eilAqSf0g1Xu9Se2PakSmHnlOkcWYc7ijdVbVHgQHSS1QGV)eilJZvEfiw2kcbDyj4fl6elt4QazXFw2)3cpGOh96UYRaPj4loyqE)(s3Cq0pox5vG0eGxmQqFmOz)JvdWppffPUR8kqMhXpVbVHh(dwyJvtbySU)rIYvGnbMXwxFpM3qdzzW7ela8(CDfXYHzbtplpKLXyX297SuqwWV)SalwwyILVVcf6XAKf0yX2ovS87elZRXplWIy5WSalwwysJSypl3KLFNybtbybYYHzXlqwIil3KfD4VZI3eVHh(dwyJvtbySU)iis0dW7Z1vKglpMIew5fMYFFfk0RraUArrogVHh(dwyJvtbySU)iis0dW7Z1vKglpMIew5fMYFFfk0RrOvKoiOgb4QffjAA8Mr(9vOqVbnZUJZlmL1xZP2VVcf6nOzcqOceARmGR2)dwAT77RqHEdAMdBEymLHZCmSWFdx4Caw4VxH)GfM3Wd)blSXQPamw3Feej6b4956ksJLhtrcR8ct5VVcf61i0ksheuJaC1II0EnEZi)(kuO3yVz3X5fMY6R5u73xHc9g7nbiubcTvgWv7)blT299vOqVXEZHnpmMYWzogw4VHlCoal83RWFWcZBOHSm4DctS89vOqpMfVjwk4ZIVEyS)xWvQOSaspfEcKfhZcSyzHjwWV)S89vOqp2WclaPNfaEFUUIy5HSGWS4yw(DkklUcdzPicKfSffoxXYUxGQRqA4n8WFWcBSAkaJ19hbrIEaEFUUI0y5XuKWkVWu(7RqHEncTI0bb1iaxTOirynEZiPiCDwweO5kCOxVRROCeU86xXzqcWfO0ukcxNLfbAOyROn5QmSblVcuAkfHRZYIany4sPO)VczUx6r5n0qwaspMLFNyb47nE1ijwcq8ZYe2SO8NAwcUkSu(FWcZYWjSzHqShBPiwSTtflpKf879Zc4k26kKSOttytSGABQgyuwMUsHzboNJ4n8WFWcBSAkaJ19hbrIEaEFUUI0y5XuKyCoaXVgb4QffzehBqdrttgZGMMheM(SoSwyZFuBVMMryRWiEdp8hSWgRMcWyD)rqKOhG3NRRinwEmfjEMdq8RraUArrQ5Xg0q00KXmOP5bHPpRdRf28h12RPze2kmI3qdzbi9yw8NfB7xyNfpgUQNf4KLTIriSGkybaIcXcEhUuGSOtSSWe4aYccpgl2UFhUEwqfPi8FUIfGwxFpMfVazjIJXIT73n8gE4pyHnwnfGX6(JGirpaVpxxrAS8ykYaSaarHYo2sJaC1IImIJHa0gBq9QOjSrsMaPi8FUkJTU(EmVHh(dwyJvtbySU)iis0hdHfkxLNWoM3Wd)blSXQPamw3Feej6T1(VRr1vuoagjAJPXBg5qkOolmzuRY7Cri(ttPG6SWK5QmgQ8onLcQZctMRY6WFpnLcQZctgVIMlcX)iEdEdnKfestbh)SyplOgT)7S4filolaFVXRgjXcSyb4GzX297SSLd5(ZcQ1jw8cKLXb36Gzb2Sa89EEnXc83P22HjEdp8hSWgOfvuJGirVT2)DnEZihsb1zHjJAvENlcXFAkfuNfMmxLXqL3PPuqDwyYCvwh(7PPuqDwyY4v0Cri(hP1Qjag0m2A)31ANvtam2BS1(VZB4H)Gf2aTOIAeej6XV3ZRjnQUIYbWi1SgVzKdTRxfnHnsYO7kVcugoZUsL)9RqIttTlabqLxVPoK7FE6uAQDylsPYV3iPhBWV3txPIeT0u7Exr1Bk)xnHZ6UYRazOY1ve4iT2HPpRdRf28h12RPz7TcPPdPG6SWKbdvENlcXFAkfuNfMmxLvRY70ukOolmzUkRd)90ukOolmz8kAUie)J4n8WFWcBGwurncIe943B8QrsAuDfLdGrQznEZih2RIMWgjz0DLxbkdNzxPY)(viXAdqau51BQd5(NNoPfBrkv(9gj9yd(9E6kvKOnsRDy6Z6WAHn)rT9AA2ERaVbVHgQHSObiMcRNazHaqDuw(lMy53jw8WdBwomloa)uUUIm8gE4pyHJedvEN1jpM3Wd)blmcIe9bxPYE4pyLvh(1y5XuKqlQOwJ4VVWhjAA8Mr(xmHOH2pip8hSm2A)3nbh)5)Ije4H)GLb)EpVMmbh)5)IPr8gAilaPhZYwHAalWILiIawSD)oC9Sa238zXlqwSD)olaFVvWgKfVazXEeWc83P22HjEdp8hSWiis0dW7Z1vKglpMI8WzhsAeGRwuKylsPYV3iPhBWV3txP2enTdT7DfvVb)ERGnOHkxxrGPPVRO6n4NukVZG9nFdvUUIahLMITiLk)EJKESb)EpDLAt75n0qwaspMLGICael22PIfGV3ZRjwcEXY(9Sypcy59gj9ywSTFHDwomlnPiaE9SmHnl)oXIgeuNfMy5HSOtSy10K6MazXlqwSTFHDwMNsrnlpKLGJFEdp8hSWiis0dW7Z1vKglpMI8W5GICaKgb4Qffj2IuQ87ns6Xg8798AAt04n0qwgG6956kILF3Fwc7uafml3KLOWflEtSCflolidGS8qwCaWdKLFNybF)Y)dwSyBNAIfNLVVcf6zH(alhMLfMaz5kw0P3grflbh)yEdp8hSWiis0dW7Z1vKglpMI8QmYaOgb4QffPvtaYidGg0mXqynVMstTAcqgza0GMbVQ51uAQvtaYidGg0m43B8QrsPPwnbiJmaAqZGFVNUsLMA1eGmYaObnZC1rZWzMuRIstTAcGPDaubx48SPAGrtt1xZPj45RcMMI9RWrQVMttWZxfmGR2)dwPPa8(CDfzoC2HeVHgYY4Hjwgh1yQr5kKS4pl)oXcvGSaNSGABQgyuwSTtfl7o(jwomlUoeaXc6Em0LgzXNp1SGkybaIcXIT73zzCqFWS4filWFNABhMyX297SGQTI(XVc8gE4pyHrqKOxNAm1OCfsnEZiho0UaeavE9M6qU)5PtPP2fGqfi0wzcWcaefk)7ugBD99yZYkn1UEv0e2ijJUR8kqz4m7kv(3VcjEKw91CAcE(QGPPy)k8MOPzT6R500oaQGlCE2unWOMMI9RWicH1AxacGkVEdaQ(9ODAAacGkVEdaQ(9OTw91CAcE(QGzzPvFnNM2bqfCHZZMQbg1SS0ouFnNM2bqfCHZZMQbg10uSFfgrrIM9AccpOEv0e2ijd(Q5sL3JIFQppnvFnNMGNVkyAk2VcJi0qlnfn0f2IuQ8UJFcrOzq3JgPfG3NRRiZvzKbqEdnKfec8zX297S4SGQTI(XVcS87(ZYHRTFwCwqilf2BwSAyGfyZITDQy53jwMhY9NLdZIRdxplpKfQa5n8WFWcJGirVf8pyPXBg5q91CAcE(QGPPy)k8MOPzTdTRxfnHnsYGVAUu59O4N6Ztt1xZPPDaubx48SPAGrnnf7xHreAdaT6R500oaQGlCE2unWOML1O0uDigRDEi3)CtX(vyezVMhPfG3NRRiZvzKbqEdnKfu5QWs5pHzX2o97uZYcFfswqfSaarHyPG2yX2PuS4kf0glrHlwEil4)ukwco(z53jwWEmXIhdx1ZcCYcQGfaikecq1wr)4xbwco(X8gE4pyHrqKOhG3NRRinwEmfzawaGOqzqchTcAeGRwuKb6udhopK7FUPy)kSMGMM1KaeQaH2ktWZxfmnf7xHhHUqtthB0Mb6udhopK7FUPy)kSMGMM1KaeQaH2ktawaGOq5FNYyRRVhBAk2VcpcDHMMo2iT21(bMjau9gheeBieF4hRDODbiubcTvMGNVkyAYbJMMAxacvGqBLjalaquO8VtzS113Jnn5GrhLMgGqfi0wzcE(QGPPy)k8Mx9uBbv(tG55HC)Znf7xHtt7vrtyJKmbsr4)CvgBD99yTbiubcTvMGNVkyAk2VcVzehlnnaHkqOTYeGfaiku(3Pm2667XMMI9RWBE1tTfu5pbMNhY9p3uSFfwtqBS0u7cqau51BQd5(NNoXBOHSmEycKLhYciP8OS87ellSJKybozbvBf9JFfyX2ovSSWxHKfq4sxrSalwwyIfVazXQjau9SSWosIfB7uXIxS4GGSqaO6z5WS46W1ZYdzb8iEdp8hSWiis0dW7Z1vKglpMImaMdWc8(dwAeGRwuKdFVrsV5Vyk)Wm4rBIMMttB)aZeaQEJdcInxTPMhBK2HdPiCDwweOHITI2KRYWgS8kqAhAxacGkVEdaQ(9ODAAacvGqBLHITI2KRYWgS8kqMMI9RWicn0ncfbd18G6vrtyJKm4RMlvEpk(P(8rJ0AxacvGqBLHITI2KRYWgS8kqMMCWOJstPiCDwweObdxkf9)viZ9spQ2H2fGaOYR3uhY9ppDknnaHkqOTYGHlLI()kK5EPhnhrewZA6yOzAk2VcJi0qdHhLMomaHkqOTYOtnMAuUcPPjhmAAQDThiZ3qLknnabqLxVPoK7FE60iTdT7DfvVzU6Oz4mtQvrgQCDfbMMgGaOYR3aGQFpARnaHkqOTYmxD0mCMj1QittX(vyeHgAiqZdQxfnHnsYGVAUu59O4N6ZttTlabqLxVbav)E0wBacvGqBLzU6Oz4mtQvrMMI9RWisFnNMGNVkyaxT)hSqaA2pOEv0e2ijJvFXWg8Cv27GxxiBTuyV1e0SFK2HueUollc0Cfo0R31vuocxE9R4mib4cK2aeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWisZJsthoKIW1zzrGg8UdcTrGzyRNHZ8d7yQETbiubcTvMh2Xu9ey(k8HC)ZruZAoI2JMPPy)k8O00Hdb4956kYaR8ct5VVcf6JeT0uaEFUUImWkVWu(7RqH(iJ4iTd)(kuO3GMPjhmAoaHkqOTkn97RqHEdAMaeQaH2kttX(v4nV6P2cQ8NaZZd5(NBk2VcRjOn2O0uaEFUUImWkVWu(7RqH(iTx7WVVcf6n2BAYbJMdqOceARst)(kuO3yVjaHkqOTY0uSFfEZREQTGk)jW88qU)5MI9RWAcAJnknfG3NRRidSYlmL)(kuOpYXgnAeVHgYYauVpxxrSSWeilpKfqs5rzXROS89vOqpMfVazjaIzX2ovSyZV)kKSmHnlEXIgSS2H95Sy1WaVHh(dwyeej6b4956ksJLhtr(79PuzmrOqD2MFVgb4QffPDy4sPFfO537tPYyIqHAdvUUIattNhY9p3uSFfEt7hBS0uDigRDEi3)CtX(vyezVMrWqeEmnrFnNMFVpLkJjcfQn43dOmi7hLMQVMtZV3NsLXeHc1g87bu2mIAQMmSxfnHnsYGVAUu59O4N6ZhK9J4n0qwgpmXIgeBfTjxXseCdwEfiwSFmmfWSOttytS4SGQTI(XVcSSWelWMfmKLF3FwUNfBNsXI6kILLfl2UFNLFNyHkqwGtwqTnvdmkVHh(dwyeej6xykFpfRXYJPiPyROn5QmSblVcKgVzKbiubcTvMGNVkyAk2VcJi7htBacvGqBLjalaquO8VtzS113Jnnf7xHrK9JPDiaVpxxrMFVpLkJjcfQZ287tt1xZP537tPYyIqHAd(9akBgXXqWWEv0e2ijd(Q5sL3JIFQpFqrC0iTa8(CDfzUkJmaMMQdXyTZd5(NBk2VcJOiIq5n0qwgpmXcq4sPO)kKSGAAPhLf0nMcyw0PjSjwCwq1wr)4xbwwyIfyZcgYYV7pl3ZITtPyrDfXYYIfB3VZYVtSqfilWjlO2MQbgL3Wd)blmcIe9lmLVNI1y5XuKy4sPO)VczUx6r14nJCyacvGqBLj45RcMMI9RWicDR1UaeavE9gau97rBT2fGaOYR3uhY9ppDknnabqLxVPoK7FE6K2aeQaH2ktawaGOq5FNYyRRVhBAk2VcJi0T2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbttX(vyeHUhLMgGaOYR3aGQFpARDOD9QOjSrsg8vZLkVhf)uFU2aeQaH2ktWZxfmnf7xHre6onvFnNM2bqfCHZZMQbg10uSFfgrOngcgQ5brr46SSiqZv4VxHh24m4b4kkRtk1iT6R500oaQGlCE2unWOML1O0uDigRDEi3)CtX(vyezVMttPiCDwweOHITI2KRYWgS8kqAdqOceARmuSv0MCvg2GLxbY0uSFfEt7hBKwaEFUUImxLrga1AhfHRZYIanxHd96DDfLJWLx)kodsaUaLMgGqfi0wzUch6176kkhHlV(vCgKaCbY0uSFfEt7hlnvhIXANhY9p3uSFfgr2pgVHgYYwv28OywwyILXFaYial2UFNfuTv0p(vGfyZI)S87elubYcCYcQTPAGr5n8WFWcJGirpaVpxxrAS8ykYlcbZbybE)blncWvlks91CAcE(QGPPy)k8MOPzTdTRxfnHnsYGVAUu59O4N6Ztt1xZPPDaubx48SPAGrnnf7xHruKOPzJMrWWiA08G0xZPrxbHGQf(nlRriyicB0SMerJMhK(Aon6kieuTWVzznAqueUollc0Cf(7v4HnodEaUIY6KsHae2O5bnKIW1zzrGMFNYZRXFgFipL2aeQaH2kZVt5514pJpKNY0uSFfgrrA)yJ0QVMtt7aOcUW5zt1aJAwwJst1HyS25HC)Znf7xHrK9AonLIW1zzrGgk2kAtUkdBWYRaPnaHkqOTYqXwrBYvzydwEfittX(vyEdp8hSWiis0VWu(EkwJLhtrEfo0R31vuocxE9R4mib4cKgVzKa8(CDfzUiemhGf49hS0cW7Z1vK5QmYaiVHgYY4HjwaU7GqBeilrWTol60e2elOAROF8RaVHh(dwyeej6xykFpfRXYJPiX7oi0gbMHTEgoZpSJP614nJCyacvGqBLj45RcMMCWOATlabqLxVPoK7FE6KwaEFUUIm)EFkvgtekuNT53RDyacvGqBLrNAm1OCfsttoy00u7ApqMVHk1O00aeavE9M6qU)5PtAdqOceARmbybaIcL)DkJTU(ESPjhmQ2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbttoy0rJ0ccFdEvZRjZFbuUcP2HGW3GFsP8opvEtM)cOCfY0u7Exr1BWpPuENNkVjdvUUIattXwKsLFVrsp2GFVNxtBgXrAbHVjgcR51K5VakxHu7qaEFUUImho7qknTxfnHnsYO7kVcugoZUsL)9RqIttD83UkBbTr9MroaglnfG3NRRitawaGOqzqchTcPP6R50ORGqq1c)ML1iT2rr46SSiqZv4qVExxr5iC51VIZGeGlqPPueUollc0Cfo0R31vuocxE9R4mib4cK2aeQaH2kZv4qVExxr5iC51VIZGeGlqMMI9RWBgXX0AN(AonbpFvWSSst1HyS25HC)Znf7xHrecpgVHgYYG3pmlhMfNL2)DQzHuUoS9NyXMhLLhYsSJcXIRuSalwwyIf87plFFfk0Jz5HSOtSOUIazzzXIT73zbvBf9JFfyXlqwqfSaarHyXlqwwyILFNyX(cKfSc(SalwcGSCtw0H)olFFfk0JzXBIfyXYctSGF)z57RqHEmVHh(dwyeej6xykFpfJ1iwbFCKFFfk0JMgVzKdb4956kYaR8ct5VVcf6Tls00A33xHc9g7nn5GrZbiubcTvPPdb4956kYaR8ct5VVcf6JeT0uaEFUUImWkVWu(7RqH(iJ4iTd1xZPj45RcMLL2H2fGaOYR3aGQFpANMQVMtt7aOcUW5zt1aJAAk2VcJGHr0O5b1RIMWgjzWxnxQ8Eu8t95JquKFFfk0BqZOVMZm4Q9)GLw91CAAhavWfopBQgyuZYknvFnNM2bqfCHZZMQbgnJVAUu59O4N6ZnlRrPPbiubcTvMGNVkyAk2VcJa7387RqHEdAMaeQaH2kd4Q9)GLw70xZPj45RcMLL2H2fGaOYR3uhY9ppDkn1oaEFUUImbybaIcLbjC0kmsRDbiaQ86nOeTpVstdqau51BQd5(NNoPfG3NRRitawaGOqzqchTcAdqOceARmbybaIcL)DkJTU(ESzzP1UaeQaH2ktWZxfmllTdhQVMtdfuNfMYQv5TPPy)k8MOnwAQ(AonuqDwykJHkVnnf7xH3eTXgP1UEv0e2ijJUR8kqz4m7kv(3VcjonDO(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akrQ50u91CA0DLxbkdNzxPY)(viXzVdErg87buIuthnknvFnNguUcSjWmfBbTrDmvFMkQrEdKmlRrPP6qmw78qU)5MI9RWiY(Xstb4956kYaR8ct5VVcf6JCSrAb4956kYCvgzaK3Wd)blmcIe9lmLVNIXAeRGpoYVVcf6TxJ3mYHa8(CDfzGvEHP83xHc92fP9AT77RqHEdAMMCWO5aeQaH2Q0uaEFUUImWkVWu(7RqH(iTx7q91CAcE(QGzzPDODbiaQ86naO63J2PP6R500oaQGlCE2unWOMMI9RWiyyenAEq9QOjSrsg8vZLkVhf)uF(ief53xHc9g7n6R5mdUA)pyPvFnNM2bqfCHZZMQbg1SSst1xZPPDaubx48SPAGrZ4RMlvEpk(P(CZYAuAAacvGqBLj45RcMMI9RWiW(n)(kuO3yVjaHkqOTYaUA)pyP1o91CAcE(QGzzPDODbiaQ86n1HC)ZtNstTdG3NRRitawaGOqzqchTcJ0AxacGkVEdkr7ZlTdTtFnNMGNVkywwPP2fGaOYR3aGQFpApknnabqLxVPoK7FE6KwaEFUUImbybaIcLbjC0kOnaHkqOTYeGfaiku(3Pm2667XMLLw7cqOceARmbpFvWSS0oCO(AonuqDwykRwL3MMI9RWBI2yPP6R50qb1zHPmgQ820uSFfEt0gBKw76vrtyJKm6UYRaLHZSRu5F)kK400H6R50O7kVcugoZUsL)9RqIZL)RMm43dOePMtt1xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqjsnD0OrPP6R50GYvGnbMPylOnQJP6ZurnYBGKzzLMQdXyTZd5(NBk2VcJi7hlnfG3NRRidSYlmL)(kuOpYXgPfG3NRRiZvzKbqEdnKLXdtywCLIf4VtnlWILfMy5EkgZcSyjaYB4H)GfgbrI(fMY3tXyEdnKfn4(DQzbjKLREil)oXc(zb2S4qIfp8hSyrD4N3Wd)blmcIe99QYE4pyLvh(1y5XuKoK0i(7l8rIMgVzKa8(CDfzoC2HeVHh(dwyeej67vL9WFWkRo8RXYJPiXpVbVHgYcQCvyP8NWSyBN(DQz53jwIan5Xb)d7uZI(AozX2PuSmDLIf4CYIT73VILFNyPie)SeC8ZB4H)Gf24qksaEFUUI0y5XuKGn5XzBNsLNUsLHZPgb4QffzVkAcBKK5VyYgSRmytES(vGuRDO(Aon)ft2GDLbBYJ1VcKAttX(vyeHmaAIDeJGXmOLMQVMtZFXKnyxzWM8y9RaP20uSFfgrE4pyzWV3ZRjdHykSEk)xmHGXmOPDifuNfMmxLvRY70ukOolmzWqL35Iq8NMsb1zHjJxrZfH4F0iT6R508xmzd2vgSjpw)kqQnllEdnKfu5QWs5pHzX2o97uZcW3B8QrsSCywSb7FNLGJ)RqYcea1Sa89EEnXYvSGoRYBw0GG6SWeVHh(dwyJdjeej6b4956ksJLhtrEilytz87nE1ijncWvlks7OG6SWK5QmgQ8wl2IuQ87ns6Xg8798AAteQM8UIQ3GHlvgoZ)oLNWMWVHkxxrGdYEeqb1zHjZvzD4VR1UEv0e2ijJvFXWg8Cv27GxxiBTuyV1AxVkAcBKKbw0VJZbf5DgWHpyXBOHSmEyIfublaquiwSTtfl(ZIIWyw(DVyrZJXYwXiew8cKf1velllwSD)olOAROF8RaVHh(dwyJdjeej6dWcaefk)7ugBD99ynEZiTdSxhOPG5aiw7WHa8(CDfzcWcaefkds4OvqRDbiubcTvMGNVkyAYbJQ1UEv0e2ijJvFXWg8Cv27GxxiBTuyVtt1xZPj45RcMLL2H21RIMWgjzS6lg2GNRYEh86czRLc7DAAVkAcBKKjqkc)NRYyRRVhNMopK7FUPy)k8MOzpcnnvhIXANhY9p3uSFfgrbiubcTvMGNVkyAk2VcJa0glnvFnNMGNVkyAk2VcVjA2pAK2Hdh64VDv2cAJAefjaVpxxrMaSaarHYo2knfBrkv(9gj9yd(9EEnTzehPDO(AonuqDwykRwL3MMI9RWBI2yPP6R50qb1zHPmgQ820uSFfEt0gBuAQ(AonbpFvW0uSFfEtnRvFnNMGNVkyAk2VcJOirZ(rAhA37kQEd(jLY7myFZpnvFnNg8790vkttX(vyeHMrZAYygnpOEv0e2ijtGue(pxLXwxFponvFnNMGNVkyAk2VcJi91CAWV3txPmnf7xHrGM1QVMttWZxfmlRrAhAxVkAcBKK5VyYgSRmytES(vGuNMAxVkAcBKKjqkc)NRYyRRVhNMQVMtZFXKnyxzWM8y9RaP20uSFfEtcXuy9u(VyAuAAVkAcBKKr3vEfOmCMDLk)7xHeps7q76vrtyJKm6UYRaLHZSRu5F)kK400H6R50O7kVcugoZUsL)9RqIZL)RMm43dOePMMMQVMtJUR8kqz4m7kv(3Vcjo7DWlYGFpGsKA6OrPP6qmw78qU)5MI9RWicTX0AxacvGqBLj45RcMMCWOJ4n0qwgpmXcWvnVMy5kwS8cKIValWIfVI(7xHKLF3FwuhacZcAimMcyw8cKffHXSy7(DwIHnXY7ns6XS4fil(ZYVtSqfilWjlolaHkVzrdcQZctS4plOHWSGPaMfyZIIWywAk2V6kKS4ywEilf8zz3bCfswEilnnBcVZc4QVcjlOZQ8MfniOolmXB4H)Gf24qcbrIE8QMxtAmenOO87ns6XrIMgVzKdBA2eE31vuAQ(AonuqDwykJHkVnnf7xHrue1sb1zHjZvzmu5T2MI9RWicnew77kQEdgUuz4m)7uEcBc)gQCDfbos77ns6n)ft5hMbpAt0qynbBrkv(9gj9ye0uSFfw7qkOolmzUk7v000MI9RWicza0e7iEeVHgYY4HjwaUQ51elpKLDhaXIZcsfu3vS8qwwyILXFaYiaVHh(dwyJdjeej6XRAEnPXBgjaVpxxrMlcbZbybE)blTbiubcTvMRWHE9UUIYr4YRFfNbjaxGmn5Gr1sr46SSiqZv4qVExxr5iC51VIZGeGlqADRCyNcOWBOHSmaJilwwwSa89E6kfl(ZIRuS8xmHzzvkcJzzHVcjlOt0G3oMfVaz5EwomlUoC9S8qwSAyGfyZIIEw(DIfSffoxXIh(dwSOUIyrNuqBSS7fOIyjc0KhRFfi1SalwSNL3BK0J5n8WFWcBCiHGirp(9E6kLgVzK29UIQ3GFsP8od238nu56kcu7q7W0N1H1cB(JA710mcBfstPG6SWK5QSxrttXwKsLFVrsp2GFVNUsTzehPDO(Aon437PRuMMMnH3DDfPDi2IuQ87ns6Xg8790vkefX0u76vrtyJKm)ft2GDLbBYJ1VcK6rPPVRO6ny4sLHZ8Vt5jSj8BOY1veOw91CAOG6SWugdvEBAk2VcJOiQLcQZctMRYyOYBT6R50GFVNUszAk2VcJieQwSfPu53BK0Jn437PRuBgjcps7q76vrtyJKmQObVDCEQi6VczgP6ITWuA6FXe6cDHWAEt91CAWV3txPmnf7xHrG9J0(EJKEZFXu(HzWJ2uZ8gAilOg3VZcWNukVzjc038zzHjwGflbqwSTtflnnBcV76kIf91Zc(pLIfB(9SmHnlOt0G3oMfRggyXlqwaH12pllmXIonHnXcQIaydla)tPyzHjw0PjSjwqfSaarHybFvGy539NfBNsXIvddS4f83PMfGV3txP4n8WFWcBCiHGirp(9E6kLgVzKVRO6n4NukVZG9nFdvUUIa1QVMtd(9E6kLPPzt4DxxrAhAhM(SoSwyZFuBVMMryRqAkfuNfMmxL9kAAk2IuQ87ns6Xg8790vQnr4rAhAxVkAcBKKrfn4TJZtfr)viZivxSfMst)lMqxOlewZBIWJ0(EJKEZFXu(HzWJ2mI8gAilOg3VZseOjpw)kqQzzHjwa(EpDLILhYckezXYYILFNyrFnNSOhLfxHHSSWxHKfGV3txPybwSOzwWuawGywGnlkcJzPPy)QRqYB4H)Gf24qcbrIE8790vknEZi7vrtyJKm)ft2GDLbBYJ1VcKATylsPYV3iPhBWV3txP2mYiQDOD6R508xmzd2vgSjpw)kqQnllT6R50GFVNUszAA2eE31vuA6qaEFUUImGn5XzBNsLNUsLHZP2H6R50GFVNUszAk2VcJOiMMITiLk)EJKESb)EpDLAt71(UIQ3GFsP8od238nu56kcuR(Aon437PRuMMI9RWisZJgnI3qdzbvUkSu(tywSTt)o1S4Sa89gVAKellmXITtPyj4lmXcW37PRuS8qwMUsXcCo1ilEbYYctSa89gVAKelpKfuiYILiqtES(vGuZc(9akSSSmSOPJXYHz53jwAkcxxtGSSvmcHLhYsWXplaFVXRgjHaGV3txP4n8WFWcBCiHGirpaVpxxrAS8yks8790vQSny95PRuz4CQraUArr64VDv2cAJ6n10Xg0q00em9zDyTWM)O2EnnBVvyqJzSF0GgIMMOVMtZFXKnyxzWM8y9RaP2GFpGYGgZG2inzO(Aon437PRuMMI9RWdkIOlSfPu5Dh)0GS7DfvVb)Ks5DgSV5BOY1ve4inzyacvGqBLb)EpDLY0uSFfEqreDHTiLkV74Ng07kQEd(jLY7myFZ3qLRRiWrAYq91CAMRoAgoZKAvKPPy)k8G08iTd1xZPb)EpDLYSSstdqOceARm437PRuMMI9RWJ4n0qwgpmXcW3B8QrsSy7(DwIan5X6xbsnlpKfuiYILLfl)oXI(AozX297W1ZIcIVcjlaFVNUsXYY6VyIfVazzHjwa(EJxnsIfyXccJawghCRdMf87buWSSQ)uSGWS8EJKEmVHh(dwyJdjeej6XV34vJK04nJeG3NRRidytEC22Pu5PRuz4CQfG3NRRid(9E6kv2gS(80vQmCo1AhaVpxxrMdzbBkJFVXRgjLMouFnNgDx5vGYWz2vQ8VFfsCU8F1Kb)EaLnJyAQ(Aon6UYRaLHZSRu5F)kK4S3bVid(9akBgXrAXwKsLFVrsp2GFVNUsHiewlaVpxxrg8790vQSny95PRuz4CYBOHSmEyIfSnVJzbdz539NLOWfliPNLyhXSSS(lMyrpkll8viz5EwCmlk)jwCmlwqm(0velWIffHXS87EXsezb)EafmlWMfuZx4NfB7uXseral43dOGzHqS11eVHh(dwyJdjeej6Dq36paugBZ7yngIguu(9gj94irtJ3ms7(lGYvi1ANh(dwgh0T(daLX28ood6XosYCvEQoK7FAki8noOB9hakJT5DCg0JDKKb)EafefrTGW34GU1FaOm2M3Xzqp2rsMMI9RWikI8gAilOMOzt4DwIGGWAEnXYnzbvBf9JFfy5WS0KdgvJS87utS4nXIIWyw(DVyrZS8EJKEmlxXc6SkVzrdcQZctSy7(DwacFuRgzrryml)UxSG2ySa)DQTDyILRyXROSObb1zHjwGnlllwEilAML3BK0JzrNMWMyXzbDwL3SObb1zHjdlrayT9ZstZMW7SaU6RqYYaSRaBcKfni2cAJ6yQEwwLIWywUIfGqL3SObb1zHjEdp8hSWghsiis0hdH18AsJHObfLFVrspos004nJSPzt4DxxrAFVrsV5Vyk)Wm4rBoCiAimcgITiLk)EJKESb)EpVMgK9dsFnNgkOolmLvRYBZYA0ie0uSFfEe6AiAi4DfvV5TDvogclSHkxxrGJ064VDv2cAJ6nb4956kYGN5ae)AI(Aon437PRuMMI9RWdcDRDOBLd7uaL0uaEFUUImhYc2ug)EJxnskn1okOolmzUk7v0rAhgGqfi0wzcE(QGPjhmQwkOolmzUk7vuT2b2Rd0uWCaeRDiaVpxxrMaSaarHYGeoAfstdqOceARmbybaIcL)DkJTU(ESPjhmAAQDbiaQ86n1HC)ZtNgLMITiLk)EJKESb)EpVMq0WHAQMmuFnNgkOolmLvRYBZYAqrC0Obnene8UIQ382UkhdHf2qLRRiWrJ0AhfuNfMmyOY7Cri(1o0UaeQaH2ktWZxfmn5Grttb71bAkyoaIhLMoKcQZctMRYyOY70u91CAOG6SWuwTkVnllT29UIQ3GHlvgoZ)oLNWMWVHkxxrGJ0oeBrkv(9gj9yd(9EEnHi0gBqdrdbVRO6nVTRYXqyHnu56kcC0OrAhAxacGkVEdkr7ZR0u70xZPbLRaBcmtXwqBuht1NPIAK3ajZYknLcQZctMRYyOY7rATtFnNM2bqfCHZZMQbgnJVAUu59O4N6ZnllEdnKLXdtSGAHBHfyXsaKfB3Vdxplb3Y6kK8gE4pyHnoKqqKOFc7aLHZC5)QjnEZiDRCyNcOKMcW7Z1vK5qwWMY43B8Qrs8gE4pyHnoKqqKOhG3NRRinwEmfzamhGf49hSYoK0iaxTOiTdSxhOPG5aiw7qaEFUUImbWCawG3FWs7q91CAWV3txPmlR003vu9g8tkL3zW(MVHkxxrGPPbiaQ86n1HC)ZtNgPfe(MyiSMxtM)cOCfsTdTtFnNgmuH)lqMLLw70xZPj45RcMLL2H29UIQ3mxD0mCMj1QidvUUIatt1xZPj45RcgWv7)bRndqOceARmZvhndNzsTkY0uSFfgbA6iTdTdtFwhwlS5pQTxtZ2BfstPG6SWK5QSAvENMsb1zHjdgQ8oxeI)rAb4956kY879PuzmrOqD2MFV2H2fGaOYR3uhY9ppDknfG3NRRitawaGOqzqchTcPPbiubcTvMaSaarHY)oLXwxFp20uSFfgrOP5rAFVrsV5Vyk)Wm4rBQVMttWZxfmGR2)dwdAmdcDuAQoeJ1opK7FUPy)kmI0xZPj45RcgWv7)bleGM9dQxfnHnsYy1xmSbpxL9o41fYwlf27r8gAilJhMyb12unWOSy7(Dwq1wr)4xbEdp8hSWghsiis03oaQGlCE2unWOA8MrQVMttWZxfmnf7xH3ennNMQVMttWZxfmGR2)dwian7huVkAcBKKXQVyydEUk7DWRlKTwkS3iYE0TwaEFUUImbWCawG3FWk7qI3qdzz8WelOAROF8RalWILailRsrymlEbYI6kIL7zzzXIT73zbvWcaefI3Wd)blSXHecIe9bsr4)Cv2vhYkMQxJ3msaEFUUImbWCawG3FWk7qs7q7cqau51Baq1VhTttTRxfnHnsYGVAUu59O4N6Ztt7vrtyJKmw9fdBWZvzVdEDHS1sH9onvFnNMGNVkyaxT)hS2ms7r3Jst1xZPPDaubx48SPAGrnllT6R500oaQGlCE2unWOMMI9RWicnnB0mVHh(dwyJdjeej6Vk4D5)blnEZib4956kYeaZbybE)bRSdjEdnKLXdtSObXwqBuZY4GfilWILail2UFNfGV3txPyzzXIxGSGDaeltyZcczPWEZIxGSGQTI(XVc8gE4pyHnoKqqKONITG2OoRdlqnEZihgGqfi0wzcE(QGPPy)kmc0xZPj45RcgWv7)ble0RIMWgjzS6lg2GNRYEh86czRLc79GqZ(ndqOceARmuSf0g1zDybAaxT)hSqaAJnknvFnNMGNVkyAk2VcVPMMMc2Rd0uWCaeZBOHSGAIMnH3zzQ8MybwSSSy5HSerwEVrspMfB3VdxplOAROF8Ral60vizX1HRNLhYcHyRRjw8cKLc(SabqDWTSUcjVHh(dwyJdjeej6XpPuENNkVjngIguu(9gj94irtJ3mYMMnH3DDfP9Vyk)Wm4rBIMM1ITiLk)EJKESb)EpVMqecR1TYHDkGI2H6R50e88vbttX(v4nrBS0u70xZPj45RcML1iEdnKLXdtSGAHAal3KLRWhiXIxSObb1zHjw8cKf1vel3ZYYIfB3VZIZcczPWEZIvddS4filBf0T(daXcqBEhZB4H)Gf24qcbrI(5QJMHZmPwfPXBgjfuNfMmxL9kQ2HUvoStbustTRxfnHnsYy1xmSbpxL9o41fYwlf27rAhQVMtJvFXWg8Cv27GxxiBTuyVnaC1IqK9AES0u91CAcE(QGPPy)k8MA6iTdbHVXbDR)aqzSnVJZGESJKm)fq5kKPP2fGaOYR3uuOHkydMMITiLk)EJKE8M2ps7q91CAAhavWfopBQgyuttX(vyena0KHi8G6vrtyJKm4RMlvEpk(P(8rA1xZPPDaubx48SPAGrnlR0u70xZPPDaubx48SPAGrnlRrAhAxacvGqBLj45RcMLvAQ(Aon)EFkvgtekuBWVhqbrOPzTZd5(NBk2VcJi7hBmTZd5(NBk2VcVjAJnwAQDy4sPFfO537tPYyIqHAdvUUIahPDigUu6xbA(9(uQmMiuO2qLRRiW00aeQaH2ktWZxfmnf7xH3mIJns77ns6n)ft5hMbpAtnNMQdXyTZd5(NBk2VcJi0gJ3qdzz8WelolaFVNUsXseCr)olwnmWYQuegZcW37PRuSCywCvtoyuwwwSaBwIcxS4nXIRdxplpKfiaQdUflBfJq4n8WFWcBCiHGirp(9E6kLgVzK6R50al63XzlQdK1FWYSS0ouFnNg8790vkttZMW7UUIstD83UkBbTr9MdGXgXBOHSebwXwSSvmcHfDAcBIfublaquiwSD)olaFVNUsXIxGS87uXcW3B8Qrs8gE4pyHnoKqqKOh)EpDLsJ3mYaeavE9M6qU)5PtAT7DfvVb)Ks5DgSV5BOY1veO2Ha8(CDfzcWcaefkds4OvinnaHkqOTYe88vbZYknvFnNMGNVkywwJ0gGqfi0wzcWcaefk)7ugBD99yttX(vyeHmaAIDepOaDQHo(BxLTG2OgDbW7Z1vKbpZbi(hPvFnNg8790vkttX(vyeHWATdSxhOPG5aiM3Wd)blSXHecIe943B8QrsA8MrgGaOYR3uhY9ppDs7qaEFUUImbybaIcLbjC0kKMgGqfi0wzcE(QGzzLMQVMttWZxfmlRrAdqOceARmbybaIcL)DkJTU(ESPPy)kmI0SwaEFUUIm437PRuzBW6ZtxPYW5ulfuNfMmxL9kQw7a4956kYCilytz87nE1ijT2b2Rd0uWCaeZBOHSmEyIfGV34vJKyX297S4flrWf97Sy1WalWMLBYsu4ABqwGaOo4wSSvmcHfB3VZsu4QzPie)SeC8ByzRkmKfWvSflBfJqyXFw(DIfQazboz53jwgGs1VhTzrFnNSCtwa(EpDLIfBWLcS2(zz6kflW5KfyZsu4IfVjwGfl2ZY7ns6X8gE4pyHnoKqqKOh)EJxnssJ3ms91CAGf974CqrENbC4dwMLvA6q7WV3ZRjJBLd7uafT2bW7Z1vK5qwWMY43B8QrsPPd1xZPj45RcMMI9RWisZA1xZPj45RcMLvA6WH6R50e88vbttX(vyeHmaAIDepOaDQHo(BxLTG2OgDbW7Z1vKbJZbi(hPvFnNMGNVkywwPP6R500oaQGlCE2unWOz8vZLkVhf)uFUPPy)kmIqganXoIhuGo1qh)TRYwqBuJUa4956kYGX5ae)J0QVMtt7aOcUW5zt1aJMXxnxQ8Eu8t95ML1iTbiaQ86naO63J2JgPDi2IuQ87ns6Xg8790vkefX0uaEFUUIm437PRuzBW6ZtxPYW5C0iT2bW7Z1vK5qwWMY43B8QrsAhAxVkAcBKK5VyYgSRmytES(vGuNMITiLk)EJKESb)EpDLcrrCeVHgYY4HjwIGGWcZYvSaeQ8MfniOolmXIxGSGDaelO2LsXseeewSmHnlOAROF8RaVHh(dwyJdjeej6lYwogclnEZihQVMtdfuNfMYyOYBttX(v4njetH1t5)IP00HHDVrs4iTxBtHDVrs5)IjeP5rPPHDVrs4iJ4iTUvoStbu4n8WFWcBCiHGir)URM5yiS04nJCO(AonuqDwykJHkVnnf7xH3KqmfwpL)lMsthg29gjHJ0ETnf29gjL)lMqKMhLMg29gjHJmIJ06w5Wofqr7q91CAAhavWfopBQgyuttX(vyePzT6R500oaQGlCE2unWOMLLw76vrtyJKm4RMlvEpk(P(80u70xZPPDaubx48SPAGrnlRr8gE4pyHnoKqqKOFUuQCmewA8MrouFnNgkOolmLXqL3MMI9RWBsiMcRNY)ftAhgGqfi0wzcE(QGPPy)k8MAES00aeQaH2ktawaGOq5FNYyRRVhBAk2VcVPMhBuA6WWU3ijCK2RTPWU3iP8FXeI08O00WU3ijCKrCKw3kh2PakAhQVMtt7aOcUW5zt1aJAAk2VcJinRvFnNM2bqfCHZZMQbg1SS0AxVkAcBKKbF1CPY7rXp1NNMAN(AonTdGk4cNNnvdmQzznI3qdzz8WelOgqnGfyXcQIa8gE4pyHnoKqqKO3M39b7mCMj1QiEdnKfu5QWs5pHzX2o97uZYdzzHjwa(EpVMy5kwacvEZIT9lSZYHzXFw0mlV3iPhJa0yzcBwiauhLf7hdDXsSJFQJYcSzbHzb47nE1ijw0GylOnQJP6zb)EafmVHh(dwyJdjeej6b4956ksJLhtrIFVNxt5RYyOYBncWvlksSfPu53BK0Jn437510MimcMkiShg74N6OzaUArdcTXgdDz)yJqWubH9q91CAWV34vJKYuSf0g1Xu9zmu5Tb)Eaf0fcpI3qdzbvUkSu(tywSTt)o1S8qwqnA)3zbC1xHKfuBt1aJYB4H)Gf24qcbrIEaEFUUI0y5XuK2A)3ZxLNnvdmQgb4QffjAOlSfPu5Dh)eISxtgoMX(bneBrkv(9gj9yd(9EEnPjOnAqdrdbVRO6ny4sLHZ8Vt5jSj8BOY1ve4GqZO5rJqWyg008G0xZPPDaubx48SPAGrnnf7xH5n0qwgpmXcQr7)olxXcqOYBw0GG6SWelWMLBYsbzb4798AIfBNsXY8EwU6HSGQTI(XVcS4v0yyt8gE4pyHnoKqqKO3w7)UgVzKdPG6SWKrTkVZfH4pnLcQZctgVIMlcXVwaEFUUImhohuKdGgPD47ns6n)ft5hMbpAteonLcQZctg1Q8oFv2(0uDigRDEi3)CtX(vyeH2yJst1xZPHcQZctzmu5TPPy)kmI8WFWYGFVNxtgcXuy9u(VysR(AonuqDwykJHkVnlR0ukOolmzUkJHkV1AhaVpxxrg8798AkFvgdvENMQVMttWZxfmnf7xHrKh(dwg8798AYqiMcRNY)ftATdG3NRRiZHZbf5aiT6R50e88vbttX(vyeriMcRNY)ftA1xZPj45RcMLvAQ(AonTdGk4cNNnvdmQzzPfG3NRRiJT2)98v5zt1aJMMAhaVpxxrMdNdkYbqA1xZPj45RcMMI9RWBsiMcRNY)ft8gAilJhMyb4798AILBYYvSGoRYBw0GG6SWKgz5kwacvEZIgeuNfMybwSGWiGL3BK0Jzb2S8qwSAyGfGqL3SObb1zHjEdp8hSWghsiis0JFVNxt8gAilOwxP(9EXB4H)Gf24qcbrI(Evzp8hSYQd)AS8ykYPRu)EV4n4n0qwa(EJxnsILjSzjgcGIP6zzvkcJzzHVcjlJdU1bZB4H)Gf2mDL637vK43B8QrsA8MrAxVkAcBKKr3vEfOmCMDLk)7xHeBOiCDwweiVHgYcQC8ZYVtSacFwSD)ol)oXsme)S8xmXYdzXbbzzv)Py53jwIDeZc4Q9)GflhML97nSaCvZRjwAk2VcZs8s9NL6iqwEilX(h2zjgcR51elGR2)dw8gE4pyHntxP(9EHGirpEvZRjngIguu(9gj94irtJ3msq4BIHWAEnzAk2VcVztX(v4bzV9Ol00uEdp8hSWMPRu)EVqqKOpgcR51eVbVHgYY4Hjw2kOB9haIfG28oMfB7uXYVtnXYHzPGS4H)aqSGT5DSgzXXSO8NyXXSybX4txrSalwW28oMfB3VZI9SaBwMKnQzb)EafmlWMfyXIZseralyBEhZcgYYV7pl)oXsr2ybBZ7yw8UpaeMfuZx4NfF(uZYV7plyBEhZcHyRRjmVHh(dwyd(J0bDR)aqzSnVJ1yiAqr53BK0JJennEZiTde(gh0T(daLX28ood6XosY8xaLRqQ1op8hSmoOB9hakJT5DCg0JDKK5Q8uDi3FTdTde(gh0T(daLX28ooVtUY8xaLRqMMccFJd6w)bGYyBEhN3jxzAk2VcVPMhLMccFJd6w)bGYyBEhNb9yhjzWVhqbrruli8noOB9hakJT5DCg0JDKKPPy)kmIIOwq4BCq36paugBZ74mOh7ijZFbuUcjVHgYY4HjmlOcwaGOqSCtwq1wr)4xbwomlllwGnlrHlw8MybKWrRWvizbvBf9JFfyX297SGkybaIcXIxGSefUyXBIfDsbTXccpg6J4ydrfPi8FUIfGwxFpEelBfJqy5kwCwqBmeWcMcSObb1zHjdlBvHHSacRTFwu0ZseOjpw)kqQzHqS11KgzXv28OywwyILRybvBf9JFfyX297SGqwkS3S4fil(ZYVtSGFVFwGtwCwghCRdMfBxbcTz4n8WFWcBWpcIe9bybaIcL)DkJTU(ESgVzK2b2Rd0uWCaeRD4qaEFUUImbybaIcLbjC0kO1UaeQaH2ktWZxfmn5Gr1AxVkAcBKKXQVyydEUk7DWRlKTwkS3PP6R50e88vbZYs7q76vrtyJKmw9fdBWZvzVdEDHS1sH9onTxfnHnsYeifH)ZvzS113JttNhY9p3uSFfEt0ShHMMQdXyTZd5(NBk2VcJOaeQaH2ktWZxfmnf7xHraAJLMQVMttWZxfmnf7xH3en7hns7WHo(BxLTG2OgrrcW7Z1vKjalaquOSJT0ouFnNgkOolmLvRYBttX(v4nrBS0u91CAOG6SWugdvEBAk2VcVjAJnknvFnNMGNVkyAk2VcVPM1QVMttWZxfmnf7xHruKOz)iTdTRxfnHnsY8xmzd2vgSjpw)kqQttTRxfnHnsYeifH)ZvzS113Jtt1xZP5VyYgSRmytES(vGuBAk2VcVjHykSEk)xmnknTxfnHnsYO7kVcugoZUsL)9RqIhPDOD9QOjSrsgDx5vGYWz2vQ8VFfsCA6q91CA0DLxbkdNzxPY)(viX5Y)vtg87buIuttt1xZPr3vEfOmCMDLk)7xHeN9o4fzWVhqjsnD0O0uDigRDEi3)CtX(vyeH2yATlaHkqOTYe88vbttoy0r8gAilJhMyb47nE1ijwEilOqKflllw(DILiqtES(vGuZI(Aoz5MSCpl2GlfileITUMyrNMWMyzE1H3Vcjl)oXsri(zj44NfyZYdzbCfBXIonHnXcQGfaikeVHh(dwyd(rqKOh)EJxnssJ3mYEv0e2ijZFXKnyxzWM8y9RaPw7q7gouFnNM)IjBWUYGn5X6xbsTPPy)k8ME4pyzS1(VBietH1t5)IjemMbnTdPG6SWK5QSo83ttPG6SWK5QmgQ8onLcQZctg1Q8oxeI)rPP6R508xmzd2vgSjpw)kqQnnf7xH30d)bld(9EEnzietH1t5)IjemMbnTdPG6SWK5QSAvENMsb1zHjdgQ8oxeI)0ukOolmz8kAUie)JgLMAN(Aon)ft2GDLbBYJ1VcKAZYAuA6q91CAcE(QGzzLMcW7Z1vKjalaquOmiHJwHrAdqOceARmbybaIcL)DkJTU(ESPjhmQ2aeavE9M6qU)5PtAhQVMtdfuNfMYQv5TPPy)k8MOnwAQ(AonuqDwykJHkVnnf7xH3eTXgns7q7cqau51BqjAFELMgGqfi0wzOylOnQZ6Wc00uSFfEtnDeVHgYseyfBXcW3B8QrsywSD)olJZvEfiwGtw2QsXYG3VcjMfyZYdzXQjlVjwMWMfublaquiwSD)olJdU1bZB4H)Gf2GFeej6XV34vJK04nJSxfnHnsYO7kVcugoZUsL)9RqI1oCO(Aon6UYRaLHZSRu5F)kK4C5)Qjd(9akBAFAQ(Aon6UYRaLHZSRu5F)kK4S3bVid(9akBA)iTbiubcTvMGNVkyAk2VcVjcvRDbiubcTvMaSaarHY)oLXwxFp2SSsthgGaOYR3uhY9ppDsBacvGqBLjalaquO8VtzS113Jnnf7xHreAJPLcQZctMRYEfvRJ)2vzlOnQ30(XqqehBqbiubcTvMGNVkyAYbJoAeVHgYcQGf49hSyzcBwCLIfq4Jz539NLyhfcZcE1el)ofLfVPA7NLMMnH3jqwSTtflOMCaubxywqTnvdmkl7oMffHXS87EXIMzbtbmlnf7xDfswGnl)oXIgeBbTrnlJdwGSOVMtwomlUoC9S8qwMUsXcCozb2S4vuw0GG6SWelhMfxhUEwEileITUM4n8WFWcBWpcIe9a8(CDfPXYJPibHFUPiCDnft1J1iaxTOihQVMtt7aOcUW5zt1aJAAk2VcVPMttTtFnNM2bqfCHZZMQbg1SSgP1o91CAAhavWfopBQgy0m(Q5sL3JIFQp3SS0ouFnNguUcSjWmfBbTrDmvFMkQrEdKmnf7xHreYaOj2r8iTd1xZPHcQZctzmu5TPPy)k8MidGMyhXPP6R50qb1zHPSAvEBAk2VcVjYaOj2rCA6q70xZPHcQZctz1Q82SSstTtFnNgkOolmLXqL3ML1iT29UIQ3GHk8FbYqLRRiWr8gAilOcwG3FWILF3Fwc7uafml3KLOWflEtSaxp(ajwOG6SWelpKfyPIYci8z53PMyb2SCilytS87hMfB3VZcqOc)xG4n8WFWcBWpcIe9a8(CDfPXYJPibHFgUE8bszkOolmPraUArro0o91CAOG6SWugdvEBwwATtFnNgkOolmLvRYBZYAKw7Exr1BWqf(VazOY1veOw76vrtyJKm)ft2GDLbBYJ1VcKAEdnKLia8zXvkwEVrspMfB3VFflieVaP4lWIT73HRNfiaQdUL1virWVtS46qaelbybE)blmVHh(dwyd(rqKOpgcR51Kgdrdkk)EJKECKOPXBg5q91CAOG6SWugdvEBAk2VcVztX(v40u91CAOG6SWuwTkVnnf7xH3SPy)kCAkaVpxxrgq4NHRhFGuMcQZctJ020Sj8URRiTV3iP38xmLFyg8OnrZETUvoStbu0cW7Z1vKbe(5MIW11umvpM3Wd)blSb)iis0Jx18AsJHObfLFVrspos004nJCO(AonuqDwykJHkVnnf7xH3SPy)kCAQ(AonuqDwykRwL3MMI9RWB2uSFfonfG3NRRidi8ZW1Jpqktb1zHPrABA2eE31vK23BK0B(lMYpmdE0MOzVw3kh2PakAb4956kYac)Ctr46AkMQhZB4H)Gf2GFeej6XpPuENNkVjngIguu(9gj94irtJ3mYH6R50qb1zHPmgQ820uSFfEZMI9RWPP6R50qb1zHPSAvEBAk2VcVztX(v40uaEFUUImGWpdxp(aPmfuNfMgPTPzt4DxxrAFVrsV5Vyk)Wm4rBIg6wRBLd7uafTa8(CDfzaHFUPiCDnft1J5n0qwIaWNL(qU)SOttytSGABQgyuwUjl3ZIn4sbYIRuqBSefUy5HS00Sj8olkcJzbC1xHKfuBt1aJYYWF)WSalvuw2DllQWSy7(D46zb4vZLIfuZIIFQpFeVHh(dwyd(rqKOhG3NRRinwEmfzbZ7rXp1NNjVvrZGWxJaC1IImabqLxVbav)E0wRD9QOjSrsg8vZLkVhf)uFUw76vrtyJKmHRdkkdNz1nPSxGzqY)DTbiubcTvgDQXuJYvinn5Gr1gGqfi0wzAhavWfopBQgyuttoyuT2PVMttWZxfmllTdD83UkBbTr9MAkcnnvFnNgDfecQw43SSgXB4H)Gf2GFeej6JHWAEnPXBgjaVpxxrMcM3JIFQpptERIMbHV2MI9RWiY(X4n8WFWcBWpcIe94vnVM04nJeG3NRRitbZ7rXp1NNjVvrZGWxBtX(vyeH2aG3qdzz8WelOw4wybwSeazX297W1ZsWTSUcjVHh(dwyd(rqKOFc7aLHZC5)QjnEZiDRCyNcOWBOHSmEyIfni2cAJAwghSazX297S4vuwuWcjlubxi3zr54)kKSObb1zHjw8cKLVJYYdzrDfXY9SSSyX297SGqwkS3S4filOAROF8RaVHh(dwyd(rqKONITG2OoRdlqnEZihgGqfi0wzcE(QGPPy)kmc0xZPj45RcgWv7)ble0RIMWgjzS6lg2GNRYEh86czRLc79GqZ(ndqOceARmuSf0g1zDybAaxT)hSqaAJnknvFnNMGNVkyAk2VcVPMMMc2Rd0uWCaeZBOHSaKEml22PILTIriSG3Hlfil6elGRylcKLhYsbFwGaOo4wSmmcqwubIzbwSGAxDuwGtw0a1Qiw8cKLFNyrdcQZctJ4n8WFWcBWpcIe9a8(CDfPXYJPiDSvgCfBPraUArr64VDv2cAJ6nhaJPjdT3O5bPVMtZC1rZWzMuRIm43dOOj2pikOolmzUkRwL3J4n0qwgpmXcQ2k6h)kWIT73zbvWcaefc9dWUcSjqwaAD99yw8cKfqyT9Zcea1267jwqilf2BwGnl22PILXPGqq1c)SydUuGSqi26AIfDAcBIfuTv0p(vGfcXwxtydlrqokel4vtS8qwO6PMfNf0zvEZIgeuNfMyX2ovSSWhYILbBVMYI9wbw8cKfxPybvraml2oLIfDkaJjwAYbJYcgclwOcUqUZc4QVcjl)oXI(AozXlqwaHpMLDhaXIorfl41CEHJQxfLLMMnH3jqdVHh(dwyd(rqKOhG3NRRinwEmfzamhGf49hSY4xJaC1II0oWEDGMcMdGyTdb4956kYeaZbybE)blT2PVMttWZxfmllTdTdtFwhwlS5pQTxtZ2BfstPG6SWK5QSAvENMsb1zHjdgQ8oxeI)rAhoCiaVpxxrghBLbxXwPPbiaQ86n1HC)ZtNsthgGaOYR3Gs0(8sBacvGqBLHITG2OoRdlqttoy0rPP9QOjSrsM)IjBWUYGn5X6xbs9iTGW3Gx18AY0uSFfEtnvli8nXqynVMmnf7xH3CaODii8n4NukVZtL3KPPy)k8MOnwAQDVRO6n4NukVZtL3KHkxxrGJ0cW7Z1vK537tPYyIqH6Sn)ETV3iP38xmLFyg8On1xZPj45RcgWv7)bRbnMbHMMQVMtJUccbvl8BwwA1xZPrxbHGQf(nnf7xHrK(AonbpFvWaUA)pyHGHOz)G6vrtyJKmw9fdBWZvzVdEDHS1sH9E0O00HueUollc0qXwrBYvzydwEfiTbiubcTvgk2kAtUkdBWYRazAk2VcJi0q3iuemuZdQxfnHnsYGVAUu59O4N6ZhnAK2HdTlabqLxVPoK7FE6uA6qaEFUUImbybaIcLbjC0kKMgGqfi0wzcWcaefk)7ugBD99yttX(vyeHMMhPDOD9QOjSrsgDx5vGYWz2vQ8VFfsCAQJ)2vzlOnQrKMhtBacvGqBLjalaquO8VtzS113Jnn5GrhnknDEi3)CtX(vyefGqfi0wzcWcaefk)7ugBD99yttX(v4rPP6qmw78qU)5MI9RWisFnNMGNVkyaxT)hSqaA2pOEv0e2ijJvFXWg8Cv27GxxiBTuyVhXBOHSmEyIfuBt1aJYIT73zbvBf9JFfyzvkcJzb12unWOSydUuGSOC8ZIcwiPMLF3lwq1wr)4xbnYYVtfllmXIonHnXB4H)Gf2GFeej6BhavWfopBQgyunEZi1xZPj45RcMMI9RWBIMMtt1xZPj45RcgWv7)blezpcfb9QOjSrsgR(IHn45QS3bVUq2APWEpi0SxlaVpxxrMayoalW7pyLXpVHh(dwyd(rqKOpqkc)NRYU6qwXu9A8MrcW7Z1vKjaMdWc8(dwz8RDO(AonbpFvWaUA)pyTzK2JqrqVkAcBKKXQVyydEUk7DWRlKTwkS3dcn7ttTlabqLxVbav)E0EuAQ(AonTdGk4cNNnvdmQzzPvFnNM2bqfCHZZMQbg10uSFfgrdaeeGf46EJvtHdtzxDiRyQEZFXugGRwecgAN(Aon6kieuTWVzzP1U3vu9g87Tc2GgQCDfboI3Wd)blSb)iis0FvW7Y)dwA8MrcW7Z1vKjaMdWc8(dwz8ZBOHSma17Z1vellmbYcSyX1p19hHz539NfBE9S8qw0jwWoacKLjSzbvBf9JFfybdz539NLFNIYI3u9SyZXpbYcQ5l8ZIonHnXYVtX8gE4pyHn4hbrIEaEFUUI0y5XuKyhaLNWoh88vbncWvlkYaeQaH2ktWZxfmnf7xH3eTXstTdG3NRRitawaGOqzqchTcAdqau51BQd5(NNoLMc2Rd0uWCaeZBOHSmEycZcQfQbSCtwUIfVyrdcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1ilOAROF8RGgzrdITG2OMLXblqw8cKLTc6w)bGybOnVJ5n8WFWcBWpcIe9ZvhndNzsTksJ3mskOolmzUk7vuTdD83UkBbTrnIga2Rj6R50mxD0mCMj1Qid(9akdsZPP6R500oaQGlCE2unWOML1iTd1xZPXQVyydEUk7DWRlKTwkS3gaUAriYEeES0u91CAcE(QGPPy)k8MA6iTa8(CDfzWoakpHDo45RcAhAxacGkVEtrHgQGnyAki8noOB9hakJT5DCg0JDKK5VakxHCK2H2fGaOYR3aGQFpANMQVMtt7aOcUW5zt1aJAAk2VcJObGMmeHhuVkAcBKKbF1CPY7rXp1NpsR(AonTdGk4cNNnvdmQzzLMAN(AonTdGk4cNNnvdmQzzns7q7cqau51BqjAFELMgGqfi0wzOylOnQZ6Wc00uSFfEt7hBK23BK0B(lMYpmdE0MAonvhIXANhY9p3uSFfgrOngVHgYY4HjwIGl63zb4790vkwSAyaZYnzb4790vkwoCT9ZYYI3Wd)blSb)iis0JFVNUsPXBgP(AonWI(DC2I6az9hSmllT6R50GFVNUszAA2eE31veVHgYcQ8kqkwa(ERGnil3KL7zz3XSOimMLF3lw0mMLMI9RUcPgzjkCXI3el(ZYaymeWYwXiew8cKLFNyjS6MQNfniOolmXYUJzrZiaZstX(vxHK3Wd)blSb)iis0h8kqQS(Ao1y5XuK43BfSb14nJuFnNg87Tc2GMMI9RWisZAhQVMtdfuNfMYyOYBttX(v4n1CAQ(AonuqDwykRwL3MMI9RWBQ5rAD83UkBbTr9MdGX4n0qwqLxbsXYVtSGqwkS3SOVMtwUjl)oXIvddSydUuG12plQRiwwwSy7(Dw(DILIq8ZYFXelOcwaGOqSeGXeMf4CYsa0WYG3pmll8YvQOSalvuw2DllQWSaU6RqYYVtSmo0XWB4H)Gf2GFeej6dEfivwFnNAS8yksR(IHn45QS3bVUq2APWERXBg57kQEZvbVl)pyzOY1veOw7Exr1BkYwogcldvUUIa1oa3WHrCSX0eh)TRYwqBuJaeEmnbtFwhwlS5pQTxtZ2Bfgecp2i01qegDHTiLkV74NgPjbiubcTvMaSaarHY)oLXwxFp20uSFfEeIgGB4Wio2yAIJ)2vzlOnQ1e91CAS6lg2GNRYEh86czRLc7TbGRwecq4X0em9zDyTWM)O2EnnBVvyqi8yJqxdry0f2IuQ8UJFAKMeGqfi0wzcWcaefk)7ugBD99yttX(v4rAdqOceARmbpFvW0uSFfEZioMw91CAS6lg2GNRYEh86czRLc7TbGRweIShTX0QVMtJvFXWg8Cv27GxxiBTuyVnaC1I2mIJPnaHkqOTYeGfaiku(3Pm2667XMMI9RWicHht78qU)5MI9RWBgGqfi0wzcWcaefk)7ugBD99yttX(vyeGU1oSxfnHnsYeifH)ZvzS113Jttb4956kYeGfaikugKWrRWiEdnKfG0JzX2ovSGqwkS3SG3Hlfil6elwnmeiqwiVvrz5HSOtS46kILhYYctSGkybaIcXcSyjaHkqOTILHAagt1FUsfLfDkaJjmlFViwUjlGRyRRqYYwXiewkOnwSDkflUsbTXsu4ILhYIf1tk8QOSq1tnliKLc7nlEbYYVtfllmXcQGfaik0iEdp8hSWg8JGirpaVpxxrAS8yksRggYwlf27m5TkQgb4QffzacGkVEtDi3)80jT9QOjSrsgR(IHn45QS3bVUq2APWERvFnNgR(IHn45QS3bVUq2APWEBa4QfHah)TRYwqBuJGiUzKrCSX0cW7Z1vKjalaquOmiHJwbTbiubcTvMaSaarHY)oLXwxFp20uSFfgro(BxLTG2OgDfXXgeYaOj2rSw7a71bAkyoaI1sb1zHjZvzVIQ1XF7QSf0g1BcW7Z1vKjalaquOSJT0gGqfi0wzcE(QGPPy)k8MAM3qdzz8WelaFVNUsXIT73zb4tkL3Seb6B(SaBwE71uwqyRalEbYsbzb47Tc2GAKfB7uXsbzb4790vkwomlllwGnlpKfRggybHSuyVzX2ovS46qaeldGXyzRyeYqyZYVtSqERIYcczPWEZIvddSaW7Z1velhMLVx0iwGnloOL)haIfSnVJzz3XSOPiatbmlnf7xDfswGnlhMLRyzQoK7pVHh(dwyd(rqKOh)EpDLsJ3mYHVRO6n4NukVZG9nFdvUUIattX0N1H1cB(JA710mcBfgP1U3vu9g87Tc2GgQCDfbQvFnNg8790vkttZMW7UUI0AxVkAcBKK5VyYgSRmytES(vGuRDO(Aonw9fdBWZvzVdEDHS1sH92aWvlAZiTxZJP1o91CAcE(QGzzPDiaVpxxrghBLbxXwPP6R50GYvGnbMPylOnQJP6ZurnYBGKzzLMcW7Z1vKXQHHS1sH9otERIoknDyacGkVEtrHgQGnO23vu9g8tkL3zW(MVHkxxrGAhccFJd6w)bGYyBEhNb9yhjzAk2VcVPMMM6H)GLXbDR)aqzSnVJZGESJKmxLNQd5(pA0iTddqOceARmbpFvW0uSFfEt0glnnaHkqOTYeGfaiku(3Pm2667XMMI9RWBI2yJ4n0qwIaRylmlBfJqyrNMWMybvWcaefILf(kKS87elOcwaGOqSeGf49hSy5HSe2PakSCtwqfSaarHy5WS4HF5kvuwCD46z5HSOtSeC8ZB4H)Gf2GFeej6XV34vJK04nJeG3NRRiJvddzRLc7DM8wfL3qdzz8WelrqqyHzX2ovSefUyXBIfxhUEwEi69Myj4wwxHKLWU3ijmlEbYsSJcXcE1el)ofLfVjwUIfVyrdcQZctSG)tPyzcBwqnlcc9O2iiEdp8hSWg8JGirFr2YXqyPXBgPBLd7uafTdd7EJKWrAV2Mc7EJKY)ftisZPPHDVrs4iJ4iEdp8hSWg8JGir)URM5yiS04nJ0TYHDkGI2HHDVrs4iTxBtHDVrs5)IjeP500WU3ijCKrCK2H6R50qb1zHPSAvEBAk2VcVjHykSEk)xmLMQVMtdfuNfMYyOYBttX(v4njetH1t5)IPr8gE4pyHn4hbrI(5sPYXqyPXBgPBLd7uafTdd7EJKWrAV2Mc7EJKY)ftisZPPHDVrs4iJ4iTd1xZPHcQZctz1Q820uSFfEtcXuy9u(VyknvFnNgkOolmLXqL3MMI9RWBsiMcRNY)ftJ4n0qwgpmXcW3B8QrsSebx0VZIvddyw8cKfWvSflBfJqyX2ovSGQTI(XVcAKfni2cAJAwghSa1il)oXYauQ(9Onl6R5KLdZIRdxplpKLPRuSaNtwGnlrHRTbzj4wSSvmcH3Wd)blSb)iis0JFVXRgjPXBgjfuNfMmxL9kQ2H6R50al63X5GI8od4WhSmlR0u91CAq5kWMaZuSf0g1Xu9zQOg5nqYSSst1xZPj45RcMLL2H2fGaOYR3Gs0(8knnaHkqOTYqXwqBuN1HfOPPy)k8MAonvFnNMGNVkyAk2VcJiKbqtSJ4bnvqyp0XF7QSf0g1OlaEFUUImyCoaX)OrAhAxacGkVEdaQ(9ODAQ(AonTdGk4cNNnvdmQPPy)kmIqganXoIhuGo1WHo(BxLTG2Ogbi8yd6DfvVzU6Oz4mtQvrgQCDfbocDbW7Z1vKbJZbi(hHGioO3vu9MISLJHWYqLRRiqT21RIMWgjzWxnxQ8Eu8t95A1xZPPDaubx48SPAGrnlR0u91CAAhavWfopBQgy0m(Q5sL3JIFQp3SSsthQVMtt7aOcUW5zt1aJAAk2VcJip8hSm43751KHqmfwpL)lM0ITiLkV74Nq0ygeonvFnNM2bqfCHZZMQbg10uSFfgrE4pyzS1(VBietH1t5)IP0uaEFUUImxecMdWc8(dwAdqOceARmxHd96DDfLJWLx)kodsaUazAYbJQLIW1zzrGMRWHE9UUIYr4YRFfNbjaxGgPvFnNM2bqfCHZZMQbg1SSstTtFnNM2bqfCHZZMQbg1SS0AxacvGqBLPDaubx48SPAGrnn5GrhLMcW7Z1vKXXwzWvSvAQoeJ1opK7FUPy)kmIqganXoIhuGo1qh)TRYwqBuJUa4956kYGX5ae)JgXBOHSm4oklpKLyhfILFNyrNWplWjlaFVvWgKf9OSGFpGYviz5EwwwSeHRlGIkklxXIxrzrdcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceiVHh(dwyd(rqKOh)EJxnssJ3mY3vu9g87Tc2GgQCDfbQ1UEv0e2ijZFXKnyxzWM8y9RaPw7q91CAWV3kydAwwPPo(BxLTG2OEZbWyJ0QVMtd(9wbBqd(9akikIAhQVMtdfuNfMYyOYBZYknvFnNgkOolmLvRYBZYAKw91CAS6lg2GNRYEh86czRLc7TbGRweIShHoM2HbiubcTvMGNVkyAk2VcVjAJLMAhaVpxxrMaSaarHYGeoAf0gGaOYR3uhY9ppDAeVHgYIgG)l2FcZYo0glXRWolBfJqyXBIfK(veilwuZcMcWc0WseCPIYY7OqywCwWLBH3HpltyZYVtSewDt1Zc((L)hSybdzXgCPaRTFw0jw8qy1(tSmHnlkVrsnl)ftZ2JjmVHh(dwyd(rqKOhG3NRRinwEmfPJTqiudKcAeGRwuKuqDwyYCvwTkVhKMIU8WFWYGFVNxtgcXuy9u(Vycb2rb1zHjZvz1Q8Eqdr3i4DfvVbdxQmCM)DkpHnHFdvUUIahuehHU8WFWYyR9F3qiMcRNY)ftiymdcRz0f2IuQ8UJFcbJz08GExr1Bk)xnHZ6UYRazOY1veiVHgYseyfBXcW3B8QrsSCflEXIgeuNfMyXXSGHWIfhZIfeJpDfXIJzrblKS4ywIcxSy7ukwOcKLLfl2UFNfnDmeWITDQyHQN6RqYYVtSueIFw0GG6SWKgzbewB)SOONL7zXQHbwqilf2BnYciS2(zbcGAB99elEXseCr)olwnmWIxGSybHkw0PjSjwq1wr)4xbw8cKfni2cAJAwghSa5n8WFWcBWpcIe943B8QrsA8MrAxVkAcBKK5VyYgSRmytES(vGuRDO(Aonw9fdBWZvzVdEDHS1sH92aWvlcr2JqhlnvFnNgR(IHn45QS3bVUq2APWEBa4QfHi718yAFxr1BWpPuENb7B(gQCDfbos7qkOolmzUkJHkV164VDv2cAJAeaW7Z1vKXXwieQbsHbPVMtdfuNfMYyOYBttX(vyeacFZC1rZWzMuRIm)fqbNBk2VAq2B08MA6yPPuqDwyYCvwTkV164VDv2cAJAeaW7Z1vKXXwieQbsHbPVMtdfuNfMYQv5TPPy)kmcaHVzU6Oz4mtQvrM)cOGZnf7xni7nAEZbWyJ0AN(AonWI(DC2I6az9hSmllT29UIQ3GFVvWg0qLRRiqTddqOceARmbpFvW0uSFfEteAAkgUu6xbA(9(uQmMiuO2qLRRiqT6R50879PuzmrOqTb)EafefXiQjd7vrtyJKm4RMlvEpk(P(8bz)iTZd5(NBk2VcVjAJnM25HC)Znf7xHrK9JnwAkyVoqtbZbq8iTdTlabqLxVbLO95vAAacvGqBLHITG2OoRdlqttX(v4nTFeVHgYY4HjwIGGWcZYvS4vuw0GG6SWelEbYc2bqSGAMRMia1UukwIGGWILjSzbvBf9JFfyXlqwgGDfytGSObXwqBuht1ByzRkmKLfMyzlrqS4filO2iiw8NLFNyHkqwGtwqTnvdmklEbYciS2(zrrplrGM8y9RaPMLPRuSaNtEdp8hSWg8JGirFr2YXqyPXBgPBLd7uafTa8(CDfzWoakpHDo45RcAhQVMtdfuNfMYQv5TPPy)k8MeIPW6P8FXuAQ(AonuqDwykJHkVnnf7xH3KqmfwpL)lMgXB4H)Gf2GFeej63D1mhdHLgVzKUvoStbu0cW7Z1vKb7aO8e25GNVkODO(AonuqDwykRwL3MMI9RWBsiMcRNY)ftPP6R50qb1zHPmgQ820uSFfEtcXuy9u(VyAK2H6R50e88vbZYknvFnNgR(IHn45QS3bVUq2APWEBa4QfHOiThTXgPDODbiaQ86naO63J2PP6R500oaQGlCE2unWOMMI9RWiAOM1e7huVkAcBKKbF1CPY7rXp1NpsR(AonTdGk4cNNnvdmQzzLMAN(AonTdGk4cNNnvdmQzzns7q76vrtyJKm)ft2GDLbBYJ1VcK60ucXuy9u(Vycr6R508xmzd2vgSjpw)kqQnnf7xHttTtFnNM)IjBWUYGn5X6xbsTzznI3Wd)blSb)iis0pxkvogclnEZiDRCyNcOOfG3NRRid2bq5jSZbpFvq7q91CAOG6SWuwTkVnnf7xH3KqmfwpL)lMst1xZPHcQZctzmu5TPPy)k8MeIPW6P8FX0iTd1xZPj45RcMLvAQ(Aonw9fdBWZvzVdEDHS1sH92aWvlcrrApAJns7q7cqau51BqjAFELMQVMtdkxb2eyMITG2OoMQptf1iVbsML1iTdTlabqLxVbav)E0onvFnNM2bqfCHZZMQbg10uSFfgrAwR(AonTdGk4cNNnvdmQzzP1UEv0e2ijd(Q5sL3JIFQppn1o91CAAhavWfopBQgyuZYAK2H21RIMWgjz(lMSb7kd2KhRFfi1PPeIPW6P8FXeI0xZP5VyYgSRmytES(vGuBAk2VcNMAN(Aon)ft2GDLbBYJ1VcKAZYAeVHgYY4HjwqnGAalWILaiVHh(dwyd(rqKO3M39b7mCMj1QiEdnKLXdtSa89EEnXYdzXQHbwacvEZIgeuNfM0ilOAROF8Ral7oMffHXS8xmXYV7flolOgT)7SqiMcRNyrrZNfyZcSurzbDwL3SObb1zHjwomllldlOg3VZYGTxtzXERalu9uZIZcqOYBw0GG6SWel3KfeYsH9Mf8Fkfl7oMffHXS87EXI9Ongl43dOGzXlqwq1wr)4xbw8cKfublaquiw2DaelXWMy539If0qOywqveGLMI9RUcPHLXdtS46qael2R5XqxSS74NybC1xHKfuBt1aJYIxGSyV92JUyz3XpXIT73HRNfuBt1aJYB4H)Gf2GFeej6XV3ZRjnEZiPG6SWK5QSAvER1o91CAAhavWfopBQgyuZYknLcQZctgmu5DUie)PPdPG6SWKXRO5Iq8NMQVMttWZxfmnf7xHrKh(dwgBT)7gcXuy9u(VysR(AonbpFvWSSgPDODy6Z6WAHn)rT9AA2ERqAAVkAcBKKXQVyydEUk7DWRlKTwkS3A1xZPXQVyydEUk7DWRlKTwkS3gaUAriYE0gtBacvGqBLj45RcMMI9RWBIgcv7q7cqau51BQd5(NNoLMgGqfi0wzcWcaefk)7ugBD99yttX(v4nrdHos7q7ApqMVHkvAAacvGqBLrNAm1OCfsttX(v4nrdHoAuAkfuNfMmxL9kQ2H6R50yZ7(GDgoZKAvKzzLMITiLkV74Nq0ygewZAhAxacGkVEdaQ(9ODAQD6R500oaQGlCE2unWOML1O00aeavE9gau97rBTylsPY7o(jenMbHhXBOHSmEyIfuJ2)DwG)o12omXIT9lSZYHz5kwacvEZIgeuNfM0ilOAROF8RalWMLhYIvddSGoRYBw0GG6SWeVHh(dwyd(rqKO3w7)oVHgYcQ1vQFVx8gE4pyHn4hbrI(Evzp8hSYQd)AS8ykYPRu)EVsaITOqYwqBm7t(Kpjb]] )
    

end