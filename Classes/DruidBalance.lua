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


    spec:RegisterPack( "Balance", 20220308, [[dm194fqikv9iev6siuXMiL(KsPgLI4uksRsiLxHaMfPOUfPi2ff)crPHjs5yKclJsLNjeAAiqDnevTneQQVHqLgNqGZrksToHenpeK7jeTpLI(NqcvnqHeQCqLsAHIu5HiuMiPi5IiQyJiuLpIaPYirGu1jfPkRuPWlfsOmtefUPqcStLs8tHe0qrG4OcjeTueiLNcOPkKQRksvTvHesFfbsglII2Rq9xrnyIdt1IjvpwWKb6YqBwHpJiJwP60QSAHecVgHmBsUTi2TKFdA4uYXfcA5s9CKMUQUUs2oaFNsz8iOoViz9cjnFf1(rDSgXrpgiO)y8wSln7SlTiMMM2KMMMGjVge3yGFklmgOLhiYjHXalpbJbMox5vaJbA5Puqhmo6XaPWvhWyG7)BrJsYswDx5va1e6LemKUFFPBoiztNR8kGAcWlHyKnb0S)jQO4hNcJu3vEfqZt4pgO(6uF6vX6Xab9hJ3IDPzNDPfX000M000em51G8Xa91Vd7yGaVeIfdC)abXkwpgiisdXatNR8kGSOP61bYBef4DyNLiqZSyxA2zhVbVbX29IesJsEdnHLTccIGSaeQ8ML0HEIH3qtyHy7Ercbz59Me(5BWsWPiLLhYsivqH53Bs4tn8gAcle0WeiaeKLvvyaPuVtXcaVpxxHuwMCg0OzwSAeqM(EtxnjKfnztwSAeGH(EtxnjCQH3qtyzRaGhilwngC6FfjwiOA)3z5gSC)2uw(DKfBnSiXc5euNffn8gAclrboriledwaGeHS87ilaTU(EklolQ7FfYscSrwgkKWNUczzYnyjfCXYUdwB)SSFpl3Zc9swQ3leUOQuSy7(Dwsxu4wJoleGfIHkK(NRyzRQJuLG1RzwUFBqwOeDwtn8gAclrboriljq6ZY2JJ0(NBmXVIUnl0awEFqklULLkflpKfDiLYY4iT)uwGLkLH3qtyj6n6plrhMGSahSKoLVZs6u(olPt57S4uwCwOwy4CflFFfr4B4n0ewIcTWcBwMCg0OzwiOA)31mleuT)7AMfGV3JRXPSK4GiljWgzPr6PoSEwEilO3QdBwcWeD)1e679B4n0ewiEhHzjk2vGncYc5KybTHDcwplHDmqeldyZcX0uSSOoj0eduD0Ngh9yGqlSWoo6XBrJ4OhdelxxHGXPlgOh(dwXaT1(VhdeePH(S(dwXajingC6ZIDSqq1(VZIxGS4Sa89MUAsilWIfGrNfB3VZYwos7plephzXlqwshCRrNfyZcW37X1ilWFhBBhfJbg67X(8yGtybdQZIIg1Q8oxiHFwMNzbdQZIIMRYuOYBwMNzbdQZIIMRY6WFNL5zwWG6SOOXRu5cj8ZYuw0YIvJamAyS1(VZIwwSNfRgbySZyR9Fp(J3IDXrpgiwUUcbJtxmqp8hSIbsFVhxJXad99yFEmWjSypl9QWbSjHgDx5vaZWr2vQ8VFfjQblxxHGSmpZI9SeGaWYR3uhP9ppCKL5zwSNfQfQu53Bs4tn037HRuSejlAWY8ml2ZY7kSEt5)QrAw3vEfqdwUUcbzzklAzXEwO4N1H1IA(dB7IGSDwbwMNzzclyqDwu0qHkVZfs4NL5zwWG6SOO5QSAvEZY8mlyqDwu0Cvwh(7SmpZcguNffnELkxiHFwMgduDfMdGXajF8hVLigh9yGy56kemoDXa9WFWkgi99MUAsymWqFp2NhdCcl9QWbSjHgDx5vaZWr2vQ8VFfjQblxxHGSOLLaeawE9M6iT)5HJSOLfQfQu53Bs4tn037HRuSejlAWYuw0YI9SqXpRdRf18h22fbz7ScXavxH5aymqYh)XFmqqC4l1hh94TOrC0Jb6H)Gvmqku5Dwh9KyGy56kemoDXF8wSlo6XaXY1viyC6Ibg67X(8yG)LGSqiwMWIDSenw8WFWYyR9F3eC6N)lbzHaS4H)GLH(EpUgnbN(5)sqwMgdK(9f(4TOrmqp8hSIbgCLk7H)GvwD0pgO6OFU8emgi0clSJ)4TeX4OhdelxxHGXPlgi0kgif)yGE4pyfdeG3NRRWyGaC1cJbsTqLk)EtcFQH(EpCLILnzrdw0YYewSNL3vy9g67Tc2GgSCDfcYY8mlVRW6n0hvkVZG9nEdwUUcbzzklZZSqTqLk)EtcFQH(EpCLILnzXUyGGin0N1FWkgiq8PSSvi5WcSyjIeGfB3VdxplG9nEw8cKfB3VZcW3BfSbzXlqwSJaSa)DSTDumgiaVZLNGXapA2Hy8hVfcoo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyGuluPYV3KWNAOV3JRrw2KfnIbcI0qFw)bRyGaXNYsqHoaKfB7yXcW37X1ilbVyz)EwSJaS8EtcFkl22VWolhLLgviaVEwgWMLFhzHCcQZIIS8qw0rwSACGDJGS4fil22VWolJtPWMLhYsWPFmqaENlpbJbE0CqHoam(J3c5JJEmqSCDfcgNUyGqRyGu8Jb6H)GvmqaEFUUcJbcWvlmgOvJaYKcGgnmjqynUgzzEMfRgbKjfanAyORACnYY8mlwncitkaA0WqFVPRMeYY8mlwncitkaA0WqFVhUsXY8mlwncitkaA0WmwDQmCKr1QqwMNzXQraM2bGfCrZJgROMIL5zw0xJHj45RcMgt8ROSejl6RXWe88vbd4Q9)GflZZSaW7Z1vO5OzhIXabrAOpR)GvmWOOEFUUcz539NLWogiIYYnyjfCXI3ilxXIZcPailpKfha8az53rwO3V8)Gfl22XgzXz57RicFwWpWYrzzrrqwUIfD8THyXsWPpngiaVZLNGXaVktkag)XBH4hh9yGy56kemoDXa9WFWkgOo2uSj6ksXabrAOpR)GvmW0NISKoSPyt0vKyXFw(DKfSazboyH41yf1uSyBhlw2D6JSCuwCDiaKfIFAehnZIpESzHyWcaKiKfB3VZs6GE0zXlqwG)o22okYIT73zHyBLSPxfIbg67X(8yGtyzcl2ZsacalVEtDK2)8WrwMNzXEwcqOceARmbybaseM)DmtTU(EQzzXY8ml2ZsVkCaBsOr3vEfWmCKDLk)7xrIAWY1viiltzrll6RXWe88vbtJj(vuw2KfniplAzrFngM2bGfCrZJgROMY0yIFfLfcXcbZIwwSNLaeawE9gay97PAwMNzjabGLxVbaw)EQMfTSOVgdtWZxfmllw0YI(AmmTdal4IMhnwrnLzzXIwwMWI(AmmTdal4IMhnwrnLPXe)kkleksw0Wow0ewiywIgl9QWbSjHg6vJLkVNI(yFUblxxHGSmpZI(AmmbpFvW0yIFfLfcXIgAWY8mlAWczzHAHkvE3PpYcHyrddXNLPSmLfTSaW7Z1vO5QmPay8hVfIBC0JbILRRqW40fdm03J95XaNWI(AmmbpFvW0yIFfLLnzrdYZIwwMWI9S0RchWMeAOxnwQ8Ek6J95gSCDfcYY8ml6RXW0oaSGlAE0yf1uMgt8ROSqiw0qtZIww0xJHPDaybx08OXkQPmllwMYY8ml6qkLfTSmos7FUXe)kkleIf7ipltzrlla8(CDfAUktkagdeePH(S(dwXajiWNfB3VZIZcX2kztVkWYV7plhT2(zXzHGSuuVzXQHbwGnl22XILFhzzCK2FwoklUoC9S8qwWcmgOh(dwXaTG)bR4pElrqC0JbILRRqW40fdeAfdKIFmqp8hSIbcW7Z1vymqaUAHXad4PyzcltyzCK2)CJj(vuw0ew0G8SOjSeGqfi0wzcE(QGPXe)kkltzHSSOreKgltzjswc4PyzcltyzCK2)CJj(vuw0ew0G8SOjSeGqfi0wzcWcaKim)7yMAD99ud4Q9)GflAclbiubcTvMaSaajcZ)oMPwxFp10yIFfLLPSqww0icsJLPSOLf7zP9dmJaW6noii1Ge(OpLfTSmHf7zjaHkqOTYe88vbtJoykwMNzXEwcqOceARmbybaseAA0btXYuwMNzjaHkqOTYe88vbtJj(vuw2KLRESTGk)rW84iT)5gt8ROSmpZsVkCaBsOjGkK(NRYuRRVNAWY1viilAzjaHkqOTYe88vbtJj(vuw2KLiMglZZSeGqfi0wzcWcaKim)7yMAD99utJj(vuw2KLRESTGk)rW84iT)5gt8ROSOjSOrASmpZI9SeGaWYR3uhP9ppCmgiisd9z9hSIbsmxfwk)rkl22XFhBww0RiXcXGfairilf0gl2oLIfxPG2yjfCXYdzH(NsXsWPpl)oYc1tqw8e4QEwGdwigSaajcjaX2kztVkWsWPpngiaVZLNGXadWcaKimdI0uvi(J3IMoo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyGty59Me(M)sW8dZGhYYMSOb5zzEML2pWmcaR34GGuZvSSjlKpnwMYIwwMWYewWiCDwwiObtSs1ORYWgS8kGSOLLjSyplbiaS86naW63t1SmpZsacvGqBLbtSs1ORYWgS8kGMgt8ROSqiw0G4tCzHaSmHfYZs0yPxfoGnj0qVASu59u0h7Zny56keKLPSmLfTSyplbiubcTvgmXkvJUkdBWYRaAA0btXYuwMNzbJW1zzHGgkCPu4)xrk3l9uSOLLjSyplbiaS86n1rA)ZdhzzEMLaeQaH2kdfUuk8)RiL7LEQCejyYhbPPHPXe)kkleIfn0GGzzklZZSmHLaeQaH2kJo2uSj6ksMgDWuSmpZI9S0EanFdvkwMNzjabGLxVPos7FE4iltzrlltyXEwExH1BgRovgoYOAvOblxxHGSmpZsacalVEdaS(9unlAzjaHkqOTYmwDQmCKr1QqtJj(vuwielAObleGfYZs0yPxfoGnj0qVASu59u0h7Zny56keKL5zwSNLaeawE9gay97PAw0YsacvGqBLzS6uz4iJQvHMgt8ROSqiw0xJHj45RcgWv7)blwialAyhlrJLEv4a2KqJvFjWg8Cv27GxxiBTuuVny56keKfnHfnSJLPSOLLjSGr46SSqqZv0qVExxH5iC51VsYGiGlGSOLLaeQaH2kZv0qVExxH5iC51VsYGiGlGMgt8ROSqiwipltzzEMLjSmHfmcxNLfcAO7oi0gcMHTEgoYpStW6zrllbiubcTvMh2jy9iy(k6rA)ZrK8KpI2PHPXe)kkltzzEMLjSmHfaEFUUcnWkVOy(7RicFwIKfnyzEMfaEFUUcnWkVOy(7RicFwIKLiYYuw0YYew((kIW38AyA0btLdqOceARyzEMLVVIi8nVgMaeQaH2ktJj(vuw2KLRESTGk)rW84iT)5gt8ROSOjSOrASmLL5zwa4956k0aR8II5VVIi8zjswSJfTSmHLVVIi8nVDMgDWu5aeQaH2kwMNz57RicFZBNjaHkqOTY0yIFfLLnz5QhBlOYFempos7FUXe)kklAclAKgltzzEMfaEFUUcnWkVOy(7RicFwIKL0yzkltzzAmqqKg6Z6pyfdm9PiilpKfqu5Py53rwwuNeYcCWcX2kztVkWITDSyzrVIelGWLUczbwSSOilEbYIvJaW6zzrDsil22XIfVyXbbzbbG1ZYrzX1HRNLhYc4HXab4DU8emgyamhGf49hSI)4TOrAXrpgiwUUcbJtxmqOvmqk(Xa9WFWkgiaVpxxHXab4Qfgd0EwOWLs)kqZV3NsLPise2gSCDfcYY8mlJJ0(NBmXVIYYMSyxAPXY8ml6qkLfTSmos7FUXe)kkleIf7ipleGLjSqWPXIMWI(Amm)EFkvMIiryBOVhiILOXIDSmLL5zw0xJH537tPYuejcBd99arSSjlrmcyrtyzcl9QWbSjHg6vJLkVNI(yFUblxxHGSenwSJLPXabrAOpR)GvmWOOEFUUczzrrqwEilGOYtXIxPy57RicFklEbYsaKYITDSyXMF)vKyzaBw8IfYzzTd7ZzXQHHyGa8oxEcgd837tPYuejc7Sn)(4pElAOrC0JbILRRqW40fdeePH(S(dwXatFkYc5KyLQrxXsuydwEfqwSlnkgOSOJdyJS4SqSTs20RcSSOilWMfkKLF3FwUNfBNsXI6kKLLfl2UFNLFhzblqwGdwiEnwrnvmWYtWyGyIvQgDvg2GLxbmgyOVh7ZJbgGqfi0wzcE(QGPXe)kkleIf7sJfTSeGqfi0wzcWcaKim)7yMAD99utJj(vuwiel2LglAzzcla8(CDfA(9(uQmfrIWoBZVNL5zw0xJH537tPYuejcBd99arSSjlrmnwialtyPxfoGnj0qVASu59u0h7Zny56keKLOXsezzkltzrlla8(CDfAUktkaYY8ml6qkLfTSmos7FUXe)kkleILisCJb6H)GvmqmXkvJUkdBWYRag)XBrd7IJEmqSCDfcgNUyGGin0N1FWkgy6trwacxkf(xrIfcAl9uSq8PyGYIooGnYIZcX2kztVkWYIISaBwOqw(D)z5EwSDkflQRqwwwSy7(Dw(DKfSazboyH41yf1uXalpbJbsHlLc))ks5EPNkgyOVh7ZJboHLaeQaH2ktWZxfmnM4xrzHqSq8zrll2ZsacalVEdaS(9unlAzXEwcqay51BQJ0(NhoYY8mlbiaS86n1rA)ZdhzrllbiubcTvMaSaajcZ)oMPwxFp10yIFfLfcXcXNfTSmHfaEFUUcnbybaseMbrAQkWY8mlbiubcTvMGNVkyAmXVIYcHyH4ZYuwMNzjabGLxVbaw)EQMfTSmHf7zPxfoGnj0qVASu59u0h7Zny56keKfTSeGqfi0wzcE(QGPXe)kkleIfIplZZSOVgdt7aWcUO5rJvutzAmXVIYcHyrJ0yHaSmHfYZs0ybJW1zzHGMROFVcpSPzWdWvywhvkwMYIww0xJHPDaybx08OXkQPmllwMYY8ml6qkLfTSmos7FUXe)kkleIf7iplZZSGr46SSqqdMyLQrxLHny5vazrllbiubcTvgmXkvJUkdBWYRaAAmXVIYYMSyxASmLfTSaW7Z1vO5QmPailAzXEwWiCDwwiO5kAOxVRRWCeU86xjzqeWfqwMNzjaHkqOTYCfn0R31vyocxE9RKmic4cOPXe)kklBYIDPXY8ml6qkLfTSmos7FUXe)kkleIf7slgOh(dwXaPWLsH)FfPCV0tf)XBrJigh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymq91yycE(QGPXe)kklBYIgKNfTSmHf7zPxfoGnj0qVASu59u0h7Zny56keKL5zw0xJHPDaybx08OXkQPmnM4xrzHqrYIgK3qEwialtyjIgYZs0yrFnggDfecQw03SSyzkleGLjSqWgYZIMWsenKNLOXI(Amm6kieuTOVzzXYuwIglyeUolle0Cf97v4HnndEaUcZ6OsXcbyHGnKNLOXYewWiCDwwiO53X84A6NPhPtXIwwcqOceARm)oMhxt)m9iDktJj(vuwiuKSyxASmLfTSOVgdt7aWcUO5rJvutzwwSmLL5zw0HuklAzzCK2)CJj(vuwiel2rEwMNzbJW1zzHGgmXkvJUkdBWYRaYIwwcqOceARmyIvQgDvg2GLxb00yIFfngiisd9z9hSIbUvLnpfLLffzj9IIutXIT73zHyBLSPxfyb2S4pl)oYcwGSahSq8ASIAQyGa8oxEcgd8IqWCawG3FWk(J3IgeCC0JbILRRqW40fd0d)bRyGxrd96DDfMJWLx)kjdIaUagdm03J95Xab4956k0CriyoalW7pyXIwwa4956k0CvMuamgy5jymWROHE9UUcZr4YRFLKbraxaJ)4TOb5JJEmqSCDfcgNUyGGin0N1FWkgy6trwaU7GqBiilrHTol64a2ileBRKn9QqmWYtWyG0DheAdbZWwpdh5h2jy9Xad99yFEmWjSeGqfi0wzcE(QGPrhmflAzXEwcqay51BQJ0(NhoYIwwa4956k0879PuzkIeHD2MFplAzzclbiubcTvgDSPyt0vKmn6GPyzEMf7zP9aA(gQuSmLL5zwcqay51BQJ0(NhoYIwwcqOceARmbybaseM)DmtTU(EQPrhmflAzzcla8(CDfAcWcaKimdI0uvGL5zwcqOceARmbpFvW0OdMILPSmLfTSacFdDvJRrZFbIUIelAzzclGW3qFuP8opuEJM)ceDfjwMNzXEwExH1BOpQuENhkVrdwUUcbzzEMfQfQu53Bs4tn037X1ilBYsezzklAzbe(MeiSgxJM)ceDfjw0YYewa4956k0C0SdrwMNzPxfoGnj0O7kVcygoYUsL)9Rirny56keKL5zwC63UkBbTHnlBgjlA60yzEMfaEFUUcnbybaseMbrAQkWY8ml6RXWORGqq1I(MLfltzrll2ZcgHRZYcbnxrd96DDfMJWLx)kjdIaUaYY8mlyeUolle0Cfn0R31vyocxE9RKmic4cilAzjaHkqOTYCfn0R31vyocxE9RKmic4cOPXe)kklBYsetJfTSypl6RXWe88vbZYIL5zw0HuklAzzCK2)CJj(vuwieleCAXa9WFWkgiD3bH2qWmS1ZWr(HDcwF8hVfni(XrpgiwUUcbJtxmqqKg6Z6pyfdm67hLLJYIZs7)o2SGkxh2(JSyZtXYdzjXjczXvkwGfllkYc99NLVVIi8PS8qw0rwuxHGSSSyX297SqSTs20RcS4filedwaGeHS4fillkYYVJSyxbYcvbFwGflbqwUbl6WFNLVVIi8PS4nYcSyzrrwOV)S89veHpngyOVh7ZJboHfaEFUUcnWkVOy(7RicFwSpsw0GfTSyplFFfr4BE7mn6GPYbiubcTvSmpZYewa4956k0aR8II5VVIi8zjsw0GL5zwa4956k0aR8II5VVIi8zjswIiltzrlltyrFngMGNVkywwSOLLjSyplbiaS86naW63t1SmpZI(AmmTdal4IMhnwrnLPXe)kkleGLjSerd5zjAS0RchWMeAOxnwQ8Ek6J95gSCDfcYYuwiuKS89veHV51WOVgJm4Q9)GflAzrFngM2bGfCrZJgROMYSSyzEMf91yyAhawWfnpASIAQm9QXsL3trFSp3SSyzklZZSeGqfi0wzcE(QGPXe)kkleGf7yztw((kIW38AycqOceARmGR2)dwSOLf7zrFngMGNVkywwSOLLjSyplbiaS86n1rA)ZdhzzEMf7zbG3NRRqtawaGeHzqKMQcSmLfTSyplbiaS86neLQpVyzEMLaeawE9M6iT)5HJSOLfaEFUUcnbybaseMbrAQkWIwwcqOceARmbybaseM)DmtTU(EQzzXIwwSNLaeQaH2ktWZxfmllw0YYewMWI(AmmyqDwumRwL3Mgt8ROSSjlAKglZZSOVgddguNffZuOYBtJj(vuw2KfnsJLPSOLf7zPxfoGnj0O7kVcygoYUsL)9Rirny56keKL5zwMWI(Amm6UYRaMHJSRu5F)ks0C5)Qrd99arSejlKNL5zw0xJHr3vEfWmCKDLk)7xrIM9o4fAOVhiILizjcyzkltzzEMf91yyi6kWgbZyIf0g2jy9zSWM0fv0SSyzklZZSOdPuw0YY4iT)5gt8ROSqiwSlnwMNzbG3NRRqdSYlkM)(kIWNLizjnwMYIwwa4956k0CvMuamgivbFAmWVVIi81igOh(dwXa)(kIWxJ4pElAqCJJEmqSCDfcgNUyGE4pyfd87RicF7Ibg67X(8yGtybG3NRRqdSYlkM)(kIWNf7JKf7yrll2ZY3xre(MxdtJoyQCacvGqBflZZSaW7Z1vObw5ffZFFfr4ZsKSyhlAzzcl6RXWe88vbZYIfTSmHf7zjabGLxVbaw)EQML5zw0xJHPDaybx08OXkQPmnM4xrzHaSmHLiAiplrJLEv4a2Kqd9QXsL3trFSp3GLRRqqwMYcHIKLVVIi8nVDg91yKbxT)hSyrll6RXW0oaSGlAE0yf1uMLflZZSOVgdt7aWcUO5rJvutLPxnwQ8Ek6J95MLfltzzEMLaeQaH2ktWZxfmnM4xrzHaSyhlBYY3xre(M3otacvGqBLbC1(FWIfTSypl6RXWe88vbZYIfTSmHf7zjabGLxVPos7FE4ilZZSypla8(CDfAcWcaKimdI0uvGLPSOLf7zjabGLxVHOu95flAzzcl2ZI(AmmbpFvWSSyzEMf7zjabGLxVbaw)EQMLPSmpZsacalVEtDK2)8Wrw0YcaVpxxHMaSaajcZGinvfyrllbiubcTvMaSaajcZ)oMPwxFp1SSyrll2ZsacvGqBLj45RcMLflAzzcltyrFnggmOolkMvRYBtJj(vuw2KfnsJL5zw0xJHbdQZIIzku5TPXe)kklBYIgPXYuw0YI9S0RchWMeA0DLxbmdhzxPY)(vKOgSCDfcYY8mltyrFnggDx5vaZWr2vQ8VFfjAU8F1OH(EGiwIKfYZY8ml6RXWO7kVcygoYUsL)9RirZEh8cn03deXsKSebSmLLPSmLL5zw0xJHHORaBemJjwqByNG1NXcBsxurZYIL5zw0HuklAzzCK2)CJj(vuwiel2LglZZSaW7Z1vObw5ffZFFfr4ZsKSKgltzrlla8(CDfAUktkagdKQGpng43xre(2f)XBrJiio6XaXY1viyC6IbcI0qFw)bRyGPpfPS4kflWFhBwGfllkYY9ycLfyXsamgOh(dwXaxumFpMqJ)4TOHMoo6XaXY1viyC6IbcI0qFw)bRyGKZ97yZcjilx9qw(DKf6ZcSzXHilE4pyXI6OFmqp8hSIb2Rk7H)GvwD0pgi97l8XBrJyGH(ESppgiaVpxxHMJMDigduD0pxEcgd0Hy8hVf7slo6XaXY1viyC6Ib6H)GvmWEvzp8hSYQJ(Xavh9ZLNGXaPF8h)XaTAmat09po6XBrJ4Ohd0d)bRyGeDfyJGzQ113tJbILRRqW40f)XBXU4OhdelxxHGXPlgi0kgif)yGE4pyfdeG3NRRWyGaC1cJbMwmqqKg6Z6pyfdm67ila8(CDfYYrzHIplpKL0yX297SuqwOV)SalwwuKLVVIi8PAMfnyX2owS87ilJRPplWcz5OSalwwuuZSyhl3GLFhzHIbybYYrzXlqwIil3GfD4VZI3ymqaENlpbJbcR8II5VVIi8J)4TeX4OhdelxxHGXPlgi0kgOdcgd0d)bRyGa8(CDfgdeGRwymqnIbg67X(8yGFFfr4BEnm7onVOywFngSOLLVVIi8nVgMaeQaH2kd4Q9)GflAzXEw((kIW38AyoQ5HjygoYjWI(nCrZbyr)Ef(dw0yGa8oxEcgdew5ffZFFfr4h)XBHGJJEmqSCDfcgNUyGqRyGoiymqp8hSIbcW7Z1vymqaUAHXaTlgyOVh7ZJb(9veHV5TZS708IIz91yWIww((kIW382zcqOceARmGR2)dwSOLf7z57RicFZBN5OMhMGz4iNal63WfnhGf97v4pyrJbcW7C5jymqyLxum)9veHF8hVfYhh9yGy56kemoDXaHwXaDqWyGE4pyfdeG3NRRWyGa8oxEcgdew5ffZFFfr4hdm03J95XaXiCDwwiO5kAOxVRRWCeU86xjzqeWfqwMNzbJW1zzHGgmXkvJUkdBWYRaYY8mlyeUolle0qHlLc))ks5EPNkgiisd9z9hSIbg9DKIS89veHpLfVrwk4ZIVEyI)xWvQuSaIpgEeKfNYcSyzrrwOV)S89veHp1WclaXNfaEFUUcz5HSqWS4uw(DmflUIczPqeKfQfgoxXYUxGQRizIbcWvlmgibh)XBH4hh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymWiMglrJLjSOblAclPzSJLOXcf)SoSwuZFyBxeKjyRaltJbcI0qFw)bRyGaXNYYVJSa89MUAsilbi9zzaBwu(Jnlbxfwk)pyrzzYa2SGe2tSuil22XILhYc99(zbCLyDfjw0XbSrwiEnwrnfldxPOSahJPXab4DU8emgiLMdq6h)XBH4gh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymWiMgleGfnsJLOXsVkCaBsOjGkK(NRYuRRVNAWY1viymqqKg6Z6pyfdei(uw8NfB7xyNfpbUQNf4GLTsjiSqmybaseYcDhUuGSOJSSOiyuYcbNgl2UFhUEwigQq6FUIfGwxFpLfVazjIPXIT73nXab4DU8emgyawaGeHzNAf)XBjcIJEmqp8hSIbMaHfrxLhWojgiwUUcbJtx8hVfnDC0JbILRRqW40fd0d)bRyG2A)3Jbg67X(8yGtybdQZIIg1Q8oxiHFwMNzbdQZIIMRYuOYBwMNzbdQZIIMRY6WFNL5zwWG6SOOXRu5cj8ZY0yGQRWCamgOgPf)XFmqhIXrpElAeh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymWEv4a2KqZFjOnyxzWg9e9RaX2GLRRqqw0YYew0xJH5Ve0gSRmyJEI(vGyBAmXVIYcHyHua0K4eMfcWsAgnyzEMf91yy(lbTb7kd2ONOFfi2Mgt8ROSqiw8WFWYqFVhxJgKWyy9y(VeKfcWsAgnyrlltybdQZIIMRYQv5nlZZSGb1zrrdfQ8oxiHFwMNzbdQZIIgVsLlKWpltzzklAzrFngM)sqBWUYGn6j6xbITzzfdeePH(S(dwXajMRclL)iLfB74VJnl)oYIMQrpj4FyhBw0xJbl2oLILHRuSahdwSD)(vS87ilfs4NLGt)yGa8oxEcgdeSrpjB7uQ8WvQmCmI)4TyxC0JbILRRqW40fdeAfdKIFmqp8hSIbcW7Z1vymqaUAHXaTNfmOolkAUktHkVzrlluluPYV3KWNAOV3JRrw2KfIllAclVRW6nu4sLHJ8VJ5bSr6BWY1viilrJf7yHaSGb1zrrZvzD4VZIwwSNLEv4a2KqJvFjWg8Cv27GxxiBTuuVny56keKfTSypl9QWbSjHgyH)onhuO3zah9GLblxxHGXabrAOpR)GvmqI5QWs5pszX2o(7yZcW3B6QjHSCuwSb7FNLGt)RiXcea2Sa89ECnYYvSqgRYBwiNG6SOymqaENlpbJbEKkyJz67nD1KW4pElrmo6XaXY1viyC6Ib6H)GvmWaSaajcZ)oMPwxFpngiisd9z9hSIbM(uKfIblaqIqwSTJfl(ZIcPuw(DVyH8PXYwPeew8cKf1villlwSD)oleBRKn9QqmWqFp2Nhd0Ewa71bAkyoaszrlltyzcla8(CDfAcWcaKimdI0uvGfTSyplbiubcTvMGNVkyA0btXY8ml6RXWe88vbZYILPSOLLjSOVgddguNffZQv5TPXe)kklBYc5zzEMf91yyWG6SOyMcvEBAmXVIYYMSqEwMYIwwMWIt)2vzlOnSzHqSq(0yrlltyHAHkv(9Me(ud99ECnYYMSerwMNzrFngMGNVkywwSmLL5zwSNLEv4a2KqJvFjWg8Cv27GxxiBTuuVny56keKLPSOLLjSyplVRW6n0hvkVZG9nEdwUUcbzzEMf91yyOV3dxPmnM4xrzHqSOHH8SOjSKMH8Senw6vHdytcnbuH0)CvMAD99udwUUcbzzEMf91yycE(QGPXe)kkleIf91yyOV3dxPmnM4xrzHaSqEw0YI(AmmbpFvWSSyzklAzzcl2ZsVkCaBsOr3vEfWmCKDLk)7xrIAWY1viilZZSOVgdJUR8kGz4i7kv(3VIenx(VA0qFpqelBYsezzEMf91yy0DLxbmdhzxPY)(vKOzVdEHg67bIyztwIiltzzEMfDiLYIwwghP9p3yIFfLfcXIgPXIwwcqOceARmbpFvW0yIFfLLnzH8Smn(J3cbhh9yGy56kemoDXa9WFWkgiDvJRXyGHubfMFVjHpnElAedm03J95XaNWsJJgP7UUczzEMf91yyWG6SOyMcvEBAmXVIYcHyjISOLfmOolkAUktHkVzrllnM4xrzHqSObbZIwwExH1BOWLkdh5FhZdyJ03GLRRqqwMYIwwEVjHV5Vem)Wm4HSSjlAqWSOjSqTqLk)EtcFkleGLgt8ROSOLLjSGb1zrrZvzVsXY8mlnM4xrzHqSqkaAsCcZY0yGGin0N1FWkgy6trwaUQX1ilxXILxGyYfybwS4vQF)ksS87(ZI6aGuw0GGPyGYIxGSOqkLfB3VZscSrwEVjHpLfVazXFw(DKfSazboyXzbiu5nlKtqDwuKf)zrdcMfkgOSaBwuiLYsJj(vxrIfNYYdzPGpl7oGRiXYdzPXrJ0Dwax9vKyHmwL3Sqob1zrX4pElKpo6XaXY1viyC6Ib6H)Gvmq6QgxJXabrAOpR)GvmW0NISaCvJRrwEil7oaKfNfskOURy5HSSOilPxuKAQyGH(ESppgiaVpxxHMlcbZbybE)blw0YsacvGqBL5kAOxVRRWCeU86xjzqeWfqtJoykw0YcgHRZYcbnxrd96DDfMJWLx)kjdIaUaYIwwCRCyhdef)XBH4hh9yGy56kemoDXa9WFWkgi99E4kvmqqKg6Z6pyfdmkgIwSSSyb479Wvkw8NfxPy5VeKYYQuiLYYIEfjwiJubVDklEbYY9SCuwCD46z5HSy1WalWMff(S87ilulmCUIfp8hSyrDfYIoQG2yz3lqfYIMQrpr)kqSzbwSyhlV3KWNgdm03J95XaTNL3vy9g6JkL3zW(gVblxxHGSOLLjSyplu8Z6WArn)HTDrqMGTcSmpZcguNffnxL9kflZZSqTqLk)EtcFQH(EpCLILnzjISmLfTSmHf91yyOV3dxPmnoAKU76kKfTSmHfQfQu53Bs4tn037HRuSqiwIilZZSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSmLL5zwExH1BOWLkdh5FhZdyJ03GLRRqqw0YI(AmmyqDwumtHkVnnM4xrzHqSerw0YcguNffnxLPqL3SOLf91yyOV3dxPmnM4xrzHqSqCzrlluluPYV3KWNAOV3dxPyzZizHGzzklAzzcl2ZsVkCaBsOrLk4TtZdfI)vKYKuxIffny56keKL5zw(lbzH4WcbtEw2Kf91yyOV3dxPmnM4xrzHaSyhltzrllV3KW38xcMFyg8qw2KfYh)XBH4gh9yGy56kemoDXa9WFWkgi99E4kvmqqKg6Z6pyfdKG6(Dwa(Os5nlAQ(gpllkYcSyjaYITDSyPXrJ0DxxHSOVEwO)PuSyZVNLbSzHmsf82PSy1WalEbYciS2(zzrrw0XbSrwiMMIAyb4FkfllkYIooGnYcXGfairil0Rcil)U)Sy7ukwSAyGfVG)o2Sa89E4kvmWqFp2Nhd8DfwVH(Os5DgSVXBWY1viilAzrFngg679WvktJJgP7UUczrlltyXEwO4N1H1IA(dB7IGmbBfyzEMfmOolkAUk7vkwMNzHAHkv(9Me(ud99E4kflBYcbZYuw0YYewSNLEv4a2KqJkvWBNMhke)RiLjPUelkAWY1viilZZS8xcYcXHfcM8SSjlemltzrllV3KW38xcMFyg8qw2KLig)XBjcIJEmqSCDfcgNUyGE4pyfdK(EpCLkgiisd9z9hSIbsqD)olAQg9e9RaXMLffzb479WvkwEileHOflllw(DKf91yWIEkwCffYYIEfjwa(EpCLIfyXc5zHIbybszb2SOqkLLgt8RUIumWqFp2NhdSxfoGnj08xcAd2vgSrpr)kqSny56keKfTSqTqLk)EtcFQH(EpCLILnJKLiYIwwMWI9SOVgdZFjOnyxzWg9e9RaX2SSyrll6RXWqFVhUszAC0iD31vilZZSmHfaEFUUcnGn6jzBNsLhUsLHJblAzzcl6RXWqFVhUszAmXVIYcHyjISmpZc1cvQ87nj8Pg679Wvkw2Kf7yrllVRW6n0hvkVZG9nEdwUUcbzrll6RXWqFVhUszAmXVIYcHyH8SmLLPSmn(J3IMoo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyGo9BxLTG2WMLnzjcsJLOXYew0GfnHfk(zDyTOM)W2UiiBNvGLOXsAg7yzklrJLjSOblAcl6RXW8xcAd2vgSrpr)kqSn03deXs0yjnJgSmLfnHLjSOVgdd99E4kLPXe)kklrJLiYczzHAHkvE3PpYs0yXEwExH1BOpQuENb7B8gSCDfcYYuw0ewMWsacvGqBLH(EpCLY0yIFfLLOXsezHSSqTqLkV70hzjAS8UcR3qFuP8od234ny56keKLPSOjSmHf91yygRovgoYOAvOPXe)kklrJfYZYuw0YYew0xJHH(EpCLYSSyzEMLaeQaH2kd99E4kLPXe)kkltJbcI0qFw)bRyGeZvHLYFKYITD83XMfNfGV30vtczzrrwSDkflbFrrwa(EpCLILhYYWvkwGJHMzXlqwwuKfGV30vtcz5HSqeIwSOPA0t0VceBwOVhiILLLHLiinwokl)oYsJr46AeKLTsjiS8qwco9zb47nD1Kqca89E4kvmqaENlpbJbsFVhUsLTbRppCLkdhJ4pElAKwC0JbILRRqW40fd0d)bRyG03B6QjHXabrAOpR)GvmW0NISa89MUAsil2UFNfnvJEI(vGyZYdzHieTyzzXYVJSOVgdwSD)oC9SOG0RiXcW37HRuSSS(lbzXlqwwuKfGV30vtczbwSqWeGL0b3A0zH(EGiklR6pflemlV3KWNgdm03J95Xab4956k0a2ONKTDkvE4kvgogSOLfaEFUUcn037HRuzBW6ZdxPYWXGfTSypla8(CDfAosfSXm99MUAsilZZSmHf91yy0DLxbmdhzxPY)(vKO5Y)vJg67bIyztwIilZZSOVgdJUR8kGz4i7kv(3VIen7DWl0qFpqelBYsezzklAzHAHkv(9Me(ud99E4kfleIfcMfTSaW7Z1vOH(EpCLkBdwFE4kvgogXF8w0qJ4OhdelxxHGXPlgOh(dwXaDq36payMAZ7KyGHubfMFVjHpnElAedm03J95XaTNL)ceDfjw0YI9S4H)GLXbDR)aGzQnVtYGEItcnxLhQJ0(ZY8mlGW34GU1FaWm1M3jzqpXjHg67bIyHqSerw0Yci8noOB9hamtT5Dsg0tCsOPXe)kkleILigdeePH(S(dwXatFkYc1M3jSqHS87(Zsk4Ifs4ZsItywww)LGSONILf9ksSCploLfL)iloLfliLE6kKfyXIcPuw(DVyjISqFpqeLfyZsuel6ZITDSyjIeGf67bIOSGe26Am(J3Ig2fh9yGy56kemoDXa9WFWkgycewJRXyGHubfMFVjHpnElAedm03J95XaBC0iD31vilAz59Me(M)sW8dZGhYYMSmHLjSObbZcbyzcluluPYV3KWNAOV3JRrwIgl2Xs0yrFnggmOolkMvRYBZYILPSmLfcWsJj(vuwMYczzzclAWcby5DfwV5TDvobclQblxxHGSmLfTSmHf3kh2XarSmpZcaVpxxHMJubBmtFVPRMeYY8ml2ZcguNffnxL9kfltzrlltyjaHkqOTYe88vbtJoykw0YcguNffnxL9kflAzXEwa71bAkyoaszrlltybG3NRRqtawaGeHzqKMQcSmpZsacvGqBLjalaqIW8VJzQ113tnn6GPyzEMf7zjabGLxVPos7FE4iltzzEMfQfQu53Bs4tn037X1ileILjSmHfIplAcltyrFnggmOolkMvRYBZYILOXIDSmLLPSenwMWIgSqawExH1BEBxLtGWIAWY1viiltzzklAzXEwWG6SOOHcvENlKWplAzXEwcqOceARmbpFvW0OdMIL5zwMWcguNffnxLPqL3SmpZI(AmmyqDwumRwL3MLflAzXEwExH1BOWLkdh5FhZdyJ03GLRRqqwMNzrFnggR(sGn45QS3bVUq2APOEBa4QfYYMrYIDKpnwMYIwwMWc1cvQ87nj8Pg6794AKfcXIgPXs0yzclAWcby5DfwV5TDvobclQblxxHGSmLLPSOLfN(TRYwqByZYMSq(0yrtyrFngg679WvktJj(vuwIgleFwMYIwwMWI9SeGaWYR3quQ(8IL5zwSNf91yyi6kWgbZyIf0g2jy9zSWM0fv0SSyzEMfmOolkAUktHkVzzklAzXEw0xJHPDaybx08OXkQPY0RglvEpf9X(CZYkgiisd9z9hSIbsqdhns3zjkacRX1il3GfITvYMEvGLJYsJoyknZYVJnYI3ilkKsz539IfYZY7nj8PSCflKXQ8MfYjOolkYIT73zbi8jEAMffsPS87EXIgPXc83X22rrwUIfVsXc5euNffzb2SSSy5HSqEwEVjHpLfDCaBKfNfYyvEZc5euNffnSOPG12plnoAKUZc4QVIelrXUcSrqwiNelOnStW6zzvkKsz5kwacvEZc5euNffJ)4TOreJJEmqSCDfcgNUyGE4pyfdCa7aMHJC5)QXyGGin0N1FWkgy6trwiEWTWcSyjaYIT73HRNLGBzDfPyGH(ESppgOBLd7yGiwMNzbG3NRRqZrQGnMPV30vtcJ)4TObbhh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymq7zbSxhOPG5aiLfTSmHfaEFUUcnbWCawG3FWIfTSmHf91yyOV3dxPmllwMNz5DfwVH(Os5DgSVXBWY1viilZZSeGaWYR3uhP9ppCKLPSOLfq4BsGWACnA(lq0vKyrlltyXEw0xJHHcv0)cOzzXIwwSNf91yycE(QGzzXIwwMWI9S8UcR3mwDQmCKr1QqdwUUcbzzEMf91yycE(QGbC1(FWILnzjaHkqOTYmwDQmCKr1QqtJj(vuwialraltzrlltyXEwO4N1H1IA(dB7IGSDwbwMNzbdQZIIMRYQv5nlZZSGb1zrrdfQ8oxiHFwMYIwwa4956k0879PuzkIeHD2MFplAzzcl2ZsacalVEtDK2)8WrwMNzjaHkqOTYeGfairy(3Xm1667PMgt8ROSqiw0xJHj45RcgWv7)blwIglPzipltzrllV3KW38xcMFyg8qw2Kf91yycE(QGbC1(FWILOXsAgIlltzzEMfDiLYIwwghP9p3yIFfLfcXI(AmmbpFvWaUA)pyXcbyrd7yjAS0RchWMeAS6lb2GNRYEh86czRLI6TblxxHGSmngiaVZLNGXadG5aSaV)Gv2Hy8hVfniFC0JbILRRqW40fd0d)bRyGTdal4IMhnwrnvmqqKg6Z6pyfdm9PileVgROMIfB3VZcX2kztVkedm03J95Xa1xJHj45RcMgt8ROSSjlAqEwMNzrFngMGNVkyaxT)hSyHaSOHDSenw6vHdytcnw9LaBWZvzVdEDHS1sr92GLRRqqwiel2r8zrlla8(CDfAcG5aSaV)Gv2Hy8hVfni(XrpgiwUUcbJtxmqp8hSIbgqfs)ZvzxDKQeS(yGGin0N1FWkgy6trwi2wjB6vbwGflbqwwLcPuw8cKf1vil3ZYYIfB3VZcXGfairymWqFp2NhdeG3NRRqtamhGf49hSYoezrlltyrFngMGNVkyaxT)hSyHaSOHDSenw6vHdytcnw9LaBWZvzVdEDHS1sr92GLRRqqw2mswSJ4ZY8ml2ZsacalVEdaS(9unltzzEMf91yyAhawWfnpASIAkZYIfTSOVgdt7aWcUO5rJvutzAmXVIYcHyrtZcbyjalW19gRgdhfZU6ivjy9M)sWmaxTqwialtyXEw0xJHrxbHGQf9nllw0YI9S8UcR3qFVvWg0GLRRqqwMg)XBrdIBC0JbILRRqW40fdm03J95Xab4956k0eaZbybE)bRSdXyGE4pyfd8QG3L)hSI)4TOreeh9yGy56kemoDXa9WFWkgiMybTHDwhwGXabrAOpR)GvmW0NISqojwqByZs6GfilWILail2UFNfGV3dxPyzzXIxGSqDaildyZcbzPOEZIxGSqSTs20RcXad99yFEmWjSeGqfi0wzcE(QGPXe)kkleGf91yycE(QGbC1(FWIfcWsVkCaBsOXQVeydEUk7DWRlKTwkQ3gSCDfcYs0yrd7yztwcqOceARmyIf0g2zDybAaxT)hSyHaSOrASmLL5zw0xJHj45RcMgt8ROSSjlralZZSa2Rd0uWCaKg)XBrdnDC0JbILRRqW40fd0d)bRyG0hvkVZdL3ymWqQGcZV3KWNgVfnIbg67X(8yGnoAKU76kKfTS8xcMFyg8qw2KfniplAzHAHkv(9Me(ud99ECnYcHyHGzrllUvoSJbIyrlltyrFngMGNVkyAmXVIYYMSOrASmpZI9SOVgdtWZxfmllwMgdeePH(S(dwXajOHJgP7SmuEJSalwwwS8qwIilV3KWNYIT73HRNfITvYMEvGfD8ksS46W1ZYdzbjS11ilEbYsbFwGaWo4wwxrk(J3IDPfh9yGy56kemoDXa9WFWkg4y1PYWrgvRcJbcI0qFw)bRyGPpfzH4bjhwUblxrpqKfVyHCcQZIIS4filQRqwUNLLfl2UFNfNfcYsr9MfRggyXlqw2kOB9haKfG28ojgyOVh7ZJbIb1zrrZvzVsXIwwMWIBLd7yGiwMNzXEw6vHdytcnw9LaBWZvzVdEDHS1sr92GLRRqqwMYIwwMWI(Ammw9LaBWZvzVdEDHS1sr92aWvlKfcXIDKpnwMNzrFngMGNVkyAmXVIYYMSebSmLfTSmHfq4BCq36payMAZ7KmON4KqZFbIUIelZZSyplbiaS86nfgAOc2GSmpZc1cvQ87nj8PSSjl2XYuw0YYew0xJHPDaybx08OXkQPmnM4xrzHqSOPzrtyzclemlrJLEv4a2Kqd9QXsL3trFSp3GLRRqqwMYIww0xJHPDaybx08OXkQPmllwMNzXEw0xJHPDaybx08OXkQPmllwMYIwwMWI9SeGqfi0wzcE(QGzzXY8ml6RXW879PuzkIeHTH(EGiwielAqEw0YY4iT)5gt8ROSqiwSlT0yrllJJ0(NBmXVIYYMSOrAPXY8ml2ZcfUu6xbA(9(uQmfrIW2GLRRqqwMYIwwMWcfUu6xbA(9(uQmfrIW2GLRRqqwMNzjaHkqOTYe88vbtJj(vuw2KLiMgltzrllV3KW38xcMFyg8qw2KfYZY8ml6qkLfTSmos7FUXe)kkleIfnsl(J3IDAeh9yGy56kemoDXa9WFWkgi99E4kvmqqKg6Z6pyfdm9PilolaFVhUsXsuyH)olwnmWYQuiLYcW37HRuSCuwCvJoykwwwSaBwsbxS4nYIRdxplpKfiaSdUflBLsqIbg67X(8yG6RXWal83PzlSdO1FWYSSyrlltyrFngg679WvktJJgP7UUczzEMfN(TRYwqByZYMSOPtJLPXF8wSZU4OhdelxxHGXPlgOh(dwXaPV3dxPIbcI0qFw)bRyGAQvIflBLsqyrhhWgzHyWcaKiKfB3VZcW37HRuS4fil)owSa89MUAsymWqFp2NhdmabGLxVPos7FE4ilAzXEwExH1BOpQuENb7B8gSCDfcYIwwMWcaVpxxHMaSaajcZGinvfyzEMLaeQaH2ktWZxfmllwMNzrFngMGNVkywwSmLfTSeGqfi0wzcWcaKim)7yMAD99utJj(vuwielKcGMeNWSenwc4Pyzclo9BxLTG2WMfYYc5tJLPSOLf91yyOV3dxPmnM4xrzHqSqWSOLf7zbSxhOPG5ain(J3IDrmo6XaXY1viyC6Ibg67X(8yGbiaS86n1rA)ZdhzrlltybG3NRRqtawaGeHzqKMQcSmpZsacvGqBLj45RcMLflZZSOVgdtWZxfmllwMYIwwcqOceARmbybaseM)DmtTU(EQPXe)kkleIfYZIwwa4956k0qFVhUsLTbRppCLkdhdw0YcguNffnxL9kflAzXEwa4956k0CKkyJz67nD1Kqw0YI9Sa2Rd0uWCaKgd0d)bRyG03B6QjHXF8wSJGJJEmqSCDfcgNUyGE4pyfdK(Etxnjmgiisd9z9hSIbM(uKfGV30vtczX297S4flrHf(7Sy1WalWMLBWsk4ABqwGaWo4wSSvkbHfB3VZsk4QzPqc)SeC6ByzRkkKfWvIflBLsqyXFw(DKfSazboy53rwIII1VNQzrFngSCdwa(EpCLIfBWLcS2(zz4kflWXGfyZsk4IfVrwGfl2XY7nj8PXad99yFEmq91yyGf(70CqHENbC0dwMLflZZSmHf7zH(EpUgnUvoSJbIyrll2ZcaVpxxHMJubBmtFVPRMeYY8mltyrFngMGNVkyAmXVIYcHyH8SOLf91yycE(QGzzXY8mltyzcl6RXWe88vbtJj(vuwielKcGMeNWSenwc4Pyzclo9BxLTG2WMfYYcaVpxxHgknhG0NLPSOLf91yycE(QGzzXY8ml6RXW0oaSGlAE0yf1uz6vJLkVNI(yFUPXe)kkleIfsbqtItywIglb8uSmHfN(TRYwqByZczzbG3NRRqdLMdq6ZYuw0YI(AmmTdal4IMhnwrnvME1yPY7POp2NBwwSmLfTSeGaWYR3aaRFpvZYuwMYIwwMWc1cvQ87nj8Pg679WvkwielrKL5zwa4956k0qFVhUsLTbRppCLkdhdwMYYuw0YI9SaW7Z1vO5ivWgZ03B6QjHSOLLjSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSmpZc1cvQ87nj8Pg679WvkwielrKLPXF8wSJ8XrpgiwUUcbJtxmqp8hSIbwOTCcewXabrAOpR)GvmW0NISefaHfLLRybiu5nlKtqDwuKfVazH6aqwiElLILOaiSyzaBwi2wjB6vHyGH(ESppg4ew0xJHbdQZIIzku5TPXe)kklBYcsymSEm)xcYY8mltyjS7njKYsKSyhlAzPXWU3KW8FjileIfYZYuwMNzjS7njKYsKSerwMYIwwCRCyhdef)XBXoIFC0JbILRRqW40fdm03J95XaNWI(AmmyqDwumtHkVnnM4xrzztwqcJH1J5)sqwMNzzclHDVjHuwIKf7yrllng29MeM)lbzHqSqEwMYY8mlHDVjHuwIKLiYYuw0YIBLd7yGiw0YYew0xJHPDaybx08OXkQPmnM4xrzHqSqEw0YI(AmmTdal4IMhnwrnLzzXIwwSNLEv4a2Kqd9QXsL3trFSp3GLRRqqwMNzXEw0xJHPDaybx08OXkQPmllwMgd0d)bRyG7UAKtGWk(J3IDe34OhdelxxHGXPlgyOVh7ZJboHf91yyWG6SOyMcvEBAmXVIYYMSGegdRhZ)LGSOLLjSeGqfi0wzcE(QGPXe)kklBYc5tJL5zwcqOceARmbybaseM)DmtTU(EQPXe)kklBYc5tJLPSmpZYewc7EtcPSejl2XIwwAmS7njm)xcYcHyH8SmLL5zwc7EtcPSejlrKLPSOLf3kh2XarSOLLjSOVgdt7aWcUO5rJvutzAmXVIYcHyH8SOLf91yyAhawWfnpASIAkZYIfTSypl9QWbSjHg6vJLkVNI(yFUblxxHGSmpZI9SOVgdt7aWcUO5rJvutzwwSmngOh(dwXahlLkNaHv8hVf7IG4OhdelxxHGXPlgiisd9z9hSIbM(uKfcki5WcSyHyAQyGE4pyfd0M39b7mCKr1QW4pEl2PPJJEmqSCDfcgNUyGqRyGu8Jb6H)GvmqaEFUUcJbcWvlmgi1cvQ87nj8Pg6794AKLnzHGzHaSmuqyZYewsC6JDQmaxTqwIglAKwASqwwSlnwMYcbyzOGWMLjSOVgdd99MUAsygtSG2WobRptHkVn03deXczzHGzzAmqqKg6Z6pyfdKyUkSu(JuwSTJ)o2S8qwwuKfGV3JRrwUIfGqL3SyB)c7SCuw8NfYZY7nj8PeqdwgWMfea2PyXU0ioSK40h7uSaBwiywa(EtxnjKfYjXcAd7eSEwOVhiIgdeG35YtWyG037X1y(QmfQ8o(J3setlo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyGAWczzHAHkvE3PpYcHyXow0ewMWsAg7yjASmHfQfQu53Bs4tn037X1ilAclAWYuwIgltyrdwialVRW6nu4sLHJ8VJ5bSr6BWY1viilrJfnmKNLPSmLfcWsAgniplrJf91yyAhawWfnpASIAktJj(v0yGGin0N1FWkgiXCvyP8hPSyBh)DSz5HSqq1(VZc4QVIeleVgROMkgiaVZLNGXaT1(VNVkpASIAQ4pElruJ4OhdelxxHGXPlgOh(dwXaT1(VhdeePH(S(dwXatFkYcbv7)olxXcqOYBwiNG6SOilWMLBWsbzb4794AKfBNsXY4EwU6HSqSTs20RcS4vQeyJXad99yFEmWjSGb1zrrJAvENlKWplZZSGb1zrrJxPYfs4NfTSaW7Z1vO5O5GcDailtzrllty59Me(M)sW8dZGhYYMSqWSmpZcguNffnQv5D(QSDSmpZIoKszrllJJ0(NBmXVIYcHyrJ0yzklZZSOVgddguNffZuOYBtJj(vuwielE4pyzOV3JRrdsymSEm)xcYIww0xJHbdQZIIzku5TzzXY8mlyqDwu0CvMcvEZIwwSNfaEFUUcn037X1y(QmfQ8ML5zw0xJHj45RcMgt8ROSqiw8WFWYqFVhxJgKWyy9y(VeKfTSypla8(CDfAoAoOqhaYIww0xJHj45RcMgt8ROSqiwqcJH1J5)sqw0YI(AmmbpFvWSSyzEMf91yyAhawWfnpASIAkZYIfTSaW7Z1vOXw7)E(Q8OXkQPyzEMf7zbG3NRRqZrZbf6aqw0YI(AmmbpFvW0yIFfLLnzbjmgwpM)lbJ)4Ter7IJEmqSCDfcgNUyGGin0N1FWkgy6trwa(EpUgz5gSCflKXQ8MfYjOolkQzwUIfGqL3Sqob1zrrwGflemby59Me(uwGnlpKfRggybiu5nlKtqDwumgOh(dwXaPV3JRX4pElrmIXrpgiwUUcbJtxmqqKg6Z6pyfdK45k1V3RyGE4pyfdSxv2d)bRS6OFmq1r)C5jymWHRu)EVI)4pg4WvQFVxXrpElAeh9yGy56kemoDXa9WFWkgi99MUAsymqqKg6Z6pyfde47nD1KqwgWMLeiambRNLvPqkLLf9ksSKo4wJEmWqFp2Nhd0Ew6vHdytcn6UYRaMHJSRu5F)ksudgHRZYcbJ)4TyxC0JbILRRqW40fd0d)bRyG0vnUgJbgsfuy(9Me(04TOrmWqFp2Nhdee(MeiSgxJMgt8ROSSjlnM4xrzjASyNDSqww0icIbcI0qFw)bRyGeZPpl)oYci8zX297S87iljq6ZYFjilpKfheKLv9NILFhzjXjmlGR2)dwSCuw2V3WcWvnUgzPXe)kkljl1FwQdbz5HSK4FyNLeiSgxJSaUA)pyf)XBjIXrpgOh(dwXatGWACngdelxxHGXPl(J)yG0po6XBrJ4OhdelxxHGXPlgOh(dwXaDq36payMAZ7KyGHubfMFVjHpnElAedm03J95XaTNfq4BCq36payMAZ7KmON4KqZFbIUIelAzXEw8WFWY4GU1FaWm1M3jzqpXjHMRYd1rA)zrlltyXEwaHVXbDR)aGzQnVtY7ORm)fi6ksSmpZci8noOB9hamtT5DsEhDLPXe)kklBYc5zzklZZSacFJd6w)baZuBENKb9eNeAOVhiIfcXsezrllGW34GU1FaWm1M3jzqpXjHMgt8ROSqiwIilAzbe(gh0T(daMP28ojd6joj08xGORifdeePH(S(dwXatFkYYwbDR)aGSa0M3jSyBhlw(DSrwoklfKfp8haKfQnVt0mloLfL)iloLfliLE6kKfyXc1M3jSy7(DwSJfyZYaTHnl03derzb2SalwCwIibyHAZ7ewOqw(D)z53rwk0gluBENWI39baPSefXI(S4JhBw(D)zHAZ7ewqcBDnsJ)4TyxC0JbILRRqW40fd0d)bRyGbybaseM)DmtTU(EAmqqKg6Z6pyfdm9PiLfIblaqIqwUbleBRKn9QalhLLLflWMLuWflEJSaI0uv4ksSqSTs20RcSy7(DwigSaajczXlqwsbxS4nYIoQG2yHGtJSrmTjedvi9pxXcqRRVNoLLTsjiSCflolAKgbyHIbwiNG6SOOHLTQOqwaH12plk8zrt1ONOFfi2SGe26AuZS4kBEkkllkYYvSqSTs20RcSy7(Dwiilf1Bw8cKf)z53rwOV3plWblolPdU1OZITRaH2mXad99yFEmq7zbSxhOPG5aiLfTSmHLjSaW7Z1vOjalaqIWmistvbw0YI9SeGqfi0wzcE(QGPrhmflAzXEw6vHdytcnw9LaBWZvzVdEDHS1sr92GLRRqqwMNzrFngMGNVkywwSmLfTSmHLjS40VDv2cAdBwiuKSaW7Z1vOjalaqIWStTyrlltyrFnggmOolkMvRYBtJj(vuw2KfnsJL5zw0xJHbdQZIIzku5TPXe)kklBYIgPXYuwMNzrFngMGNVkyAmXVIYYMSqEw0YI(AmmbpFvW0yIFfLfcfjlAyhltzrlltyXEw6vHdytcn)LG2GDLbB0t0VceBdwUUcbzzEMf7zPxfoGnj0eqfs)ZvzQ113tny56keKL5zw0xJH5Ve0gSRmyJEI(vGyBAmXVIYYMSGegdRhZ)LGSmLL5zw6vHdytcn6UYRaMHJSRu5F)ksudwUUcbzzklAzzcl2ZsVkCaBsOr3vEfWmCKDLk)7xrIAWY1viilZZSmHf91yy0DLxbmdhzxPY)(vKO5Y)vJg67bIyjswIawMNzrFnggDx5vaZWr2vQ8VFfjA27GxOH(EGiwIKLiGLPSmLL5zw0HuklAzzCK2)CJj(vuwielAKglAzXEwcqOceARmbpFvW0OdMILPXF8wIyC0JbILRRqW40fd0d)bRyG03B6QjHXabrAOpR)GvmW0NISa89MUAsilpKfIq0ILLfl)oYIMQrpr)kqSzrFngSCdwUNfBWLcKfKWwxJSOJdyJSmU6O7xrILFhzPqc)SeC6ZcSz5HSaUsSyrhhWgzHyWcaKimgyOVh7ZJb2RchWMeA(lbTb7kd2ONOFfi2gSCDfcYIwwMWI9SmHLjSOVgdZFjOnyxzWg9e9RaX20yIFfLLnzXd)blJT2)DdsymSEm)xcYcbyjnJgSOLLjSGb1zrrZvzD4VZY8mlyqDwu0CvMcvEZY8mlyqDwu0OwL35cj8ZYuwMNzrFngM)sqBWUYGn6j6xbITPXe)kklBYIh(dwg6794A0GegdRhZ)LGSqawsZOblAzzclyqDwu0CvwTkVzzEMfmOolkAOqL35cj8ZY8mlyqDwu04vQCHe(zzkltzzEMf7zrFngM)sqBWUYGn6j6xbITzzXYuwMNzzcl6RXWe88vbZYIL5zwa4956k0eGfairygePPQaltzrllbiubcTvMaSaajcZ)oMPwxFp10OdMIfTSeGaWYR3uhP9ppCKfTSmHf91yyWG6SOywTkVnnM4xrzztw0inwMNzrFnggmOolkMPqL3Mgt8ROSSjlAKgltzzklAzzcl2ZsacalVEdrP6ZlwMNzjaHkqOTYGjwqByN1HfOPXe)kklBYseWY04pEleCC0JbILRRqW40fd0d)bRyG03B6QjHXabrAOpR)Gvmqn1kXIfGV30vtcPSy7(DwsNR8kGSahSSvLILOVFfjklWMLhYIvJwEJSmGnledwaGeHSy7(DwshCRrpgyOVh7ZJb2RchWMeA0DLxbmdhzxPY)(vKOgSCDfcYIwwMWYew0xJHr3vEfWmCKDLk)7xrIMl)xnAOVhiILnzXowMNzrFnggDx5vaZWr2vQ8VFfjA27GxOH(EGiw2Kf7yzklAzjaHkqOTYe88vbtJj(vuw2KfIllAzXEwcqOceARmbybaseM)DmtTU(EQzzXY8mltyjabGLxVPos7FE4ilAzjaHkqOTYeGfairy(3Xm1667PMgt8ROSqiw0inw0YcguNffnxL9kflAzXPF7QSf0g2SSjl2LgleGLiMglrJLaeQaH2ktWZxfmn6GPyzkltJ)4Tq(4OhdelxxHGXPlgi0kgif)yGE4pyfdeG3NRRWyGaC1cJboHf91yyAhawWfnpASIAktJj(vuw2KfYZY8ml2ZI(AmmTdal4IMhnwrnLzzXYuw0YI9SOVgdt7aWcUO5rJvutLPxnwQ8Ek6J95MLflAzzcl6RXWq0vGncMXelOnStW6ZyHnPlQOPXe)kkleIfsbqtItywMYIwwMWI(AmmyqDwumtHkVnnM4xrzztwifanjoHzzEMf91yyWG6SOywTkVnnM4xrzztwifanjoHzzEMLjSypl6RXWGb1zrXSAvEBwwSmpZI9SOVgddguNffZuOYBZYILPSOLf7z5DfwVHcv0)cOblxxHGSmngiisd9z9hSIbsmybE)blwgWMfxPybe(uw(D)zjXjcPSqxnYYVJPyXBS2(zPXrJ0DeKfB7yXcbnhawWfLfIxJvutXYUtzrHukl)UxSqEwOyGYsJj(vxrIfyZYVJSqojwqByZs6Gfil6RXGLJYIRdxplpKLHRuSahdwGnlELIfYjOolkYYrzX1HRNLhYcsyRRXyGa8oxEcgdee(5gJW11ycwpn(J3cXpo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyGtyXEw0xJHbdQZIIzku5TzzXIwwSNf91yyWG6SOywTkVnllwMYIwwSNL3vy9gkur)lGgSCDfcYIwwSNLEv4a2KqZFjOnyxzWg9e9RaX2GLRRqWyGGin0N1FWkgiXGf49hSy539NLWogiIYYnyjfCXI3ilW1tpqKfmOolkYYdzbwQuSacFw(DSrwGnlhPc2il)(rzX297SaeQO)fWyGa8oxEcgdee(z46PhiMXG6SOy8hVfIBC0JbILRRqW40fd0d)bRyGjqynUgJbgsfuy(9Me(04TOrmWqFp2NhdCcl6RXWGb1zrXmfQ820yIFfLLnzPXe)kklZZSOVgddguNffZQv5TPXe)kklBYsJj(vuwMNzbG3NRRqdi8ZW1tpqmJb1zrrwMYIwwAC0iD31vilAz59Me(M)sW8dZGhYYMSOHDSOLf3kh2XarSOLfaEFUUcnGWp3yeUUgtW6PXabrAOpR)Gvmqnf8zXvkwEVjHpLfB3VFfleeVaXKlWIT73HRNfiaSdUL1vKiWVJS46qailbybE)blA8hVLiio6XaXY1viyC6Ib6H)Gvmq6QgxJXad99yFEmWjSOVgddguNffZuOYBtJj(vuw2KLgt8ROSmpZI(AmmyqDwumRwL3Mgt8ROSSjlnM4xrzzEMfaEFUUcnGWpdxp9aXmguNffzzklAzPXrJ0DxxHSOLL3Bs4B(lbZpmdEilBYIg2XIwwCRCyhdeXIwwa4956k0ac)CJr46AmbRNgdmKkOW87nj8PXBrJ4pElA64OhdelxxHGXPlgOh(dwXaPpQuENhkVXyGH(ESppg4ew0xJHbdQZIIzku5TPXe)kklBYsJj(vuwMNzrFnggmOolkMvRYBtJj(vuw2KLgt8ROSmpZcaVpxxHgq4NHRNEGygdQZIISmLfTS04Or6URRqw0YY7nj8n)LG5hMbpKLnzrdIplAzXTYHDmqelAzbG3NRRqdi8ZngHRRXeSEAmWqQGcZV3KWNgVfnI)4TOrAXrpgiwUUcbJtxmqOvmqk(Xa9WFWkgiaVpxxHXab4QfgdmabGLxVbaw)EQMfTSypl9QWbSjHg6vJLkVNI(yFUblxxHGSOLf7zPxfoGnj0eUoOWmCKv3aZEbMbr)3ny56keKfTSeGqfi0wz0XMInrxrY0OdMIfTSeGqfi0wzAhawWfnpASIAktJoykw0YI9SOVgdtWZxfmllw0YYewC63UkBbTHnlBYseqCzzEMf91yy0vqiOArFZYILPXabrAOpR)Gvmqnf8zPps7pl64a2ileVgROMILBWY9SydUuGS4kf0glPGlwEilnoAKUZIcPuwax9vKyH41yf1uSm53pklWsLILD3Yclkl2UFhUEwaE1yPyHG(u0h7ZNgdeG35YtWyGfmVNI(yFEg9wLkdc)4pElAOrC0JbILRRqW40fdm03J95Xab4956k0uW8Ek6J95z0BvQmi8zrllnM4xrzHqSyxAXa9WFWkgycewJRX4pElAyxC0JbILRRqW40fdm03J95Xab4956k0uW8Ek6J95z0BvQmi8zrllnM4xrzHqSOHMogOh(dwXaPRACng)XBrJigh9yGy56kemoDXa9WFWkg4a2bmdh5Y)vJXabrAOpR)GvmW0NISq8GBHfyXsaKfB3Vdxplb3Y6ksXad99yFEmq3kh2XarXF8w0GGJJEmqSCDfcgNUyGE4pyfdetSG2WoRdlWyGGin0N1FWkgy6trwiNelOnSzjDWcKfB3VZIxPyrblsSGfCrANfLt)RiXc5euNffzXlqw(oflpKf1vil3ZYYIfB3VZcbzPOEZIxGSqSTs20RcXad99yFEmWjSeGqfi0wzcE(QGPXe)kkleGf91yycE(QGbC1(FWIfcWsVkCaBsOXQVeydEUk7DWRlKTwkQ3gSCDfcYs0yrd7yztwcqOceARmyIf0g2zDybAaxT)hSyHaSOrASmLL5zw0xJHj45RcMgt8ROSSjlralZZSa2Rd0uWCaKg)XBrdYhh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymqN(TRYwqByZYMSOPtJfnHLjSyNH8Senw0xJHzS6uz4iJQvHg67bIyrtyXowIglyqDwu0CvwTkVzzAmqqKg6Z6pyfdei(uwSTJflBLsqyHUdxkqw0rwaxjwiilpKLc(SabGDWTyzIMcTWcKYcSyH4T6uSahSqoQvHS4fil)oYc5euNffNgdeG35YtWyGo1kdUsSI)4TObXpo6XaXY1viyC6IbcTIbsXpgOh(dwXab4956kmgiaxTWyG2ZcyVoqtbZbqklAzzcla8(CDfAcG5aSaV)GflAzXEw0xJHj45RcMLflAzzcl2Zcf)SoSwuZFyBxeKTZkWY8mlyqDwu0CvwTkVzzEMfmOolkAOqL35cj8ZYuw0YYewMWYewa4956k04uRm4kXIL5zwcqay51BQJ0(NhoYY8mltyjabGLxVHOu95flAzjaHkqOTYGjwqByN1HfOPrhmfltzzEMLEv4a2KqZFjOnyxzWg9e9RaX2GLRRqqwMYIwwaHVHUQX1OPXe)kklBYseWIwwaHVjbcRX1OPXe)kklBYIMMfTSmHfq4BOpQuENhkVrtJj(vuw2KfnsJL5zwSNL3vy9g6JkL35HYB0GLRRqqwMYIwwa4956k0879PuzkIeHD2MFplAz59Me(M)sW8dZGhYYMSOVgdtWZxfmGR2)dwSenwsZqCzzEMf91yy0vqiOArFZYIfTSOVgdJUccbvl6BAmXVIYcHyrFngMGNVkyaxT)hSyHaSmHfnSJLOXsVkCaBsOXQVeydEUk7DWRlKTwkQ3gSCDfcYYuwMYY8mltybJW1zzHGgmXkvJUkdBWYRaYIwwcqOceARmyIvQgDvg2GLxb00yIFfLfcXIgeFIlleGLjSqEwIgl9QWbSjHg6vJLkVNI(yFUblxxHGSmLLPSmLfTSmHf7zjabGLxVPos7FE4ilZZSmHLaeQaH2ktawaGeH5FhZuRRVNAAmXVIYcHyrFngMGNVkyaxT)hSyHSSyhlAzXEw6vHdytcn6UYRaMHJSRu5F)ksudwUUcbzzEMLaeQaH2ktawaGeH5FhZuRRVNAA0btXIwwC63UkBbTHnleIfYNgltzzEMfDiLYIwwghP9p3yIFfLfcXsacvGqBLjalaqIW8VJzQ113tnnM4xrzzklZZSOdPuw0YY4iT)5gt8ROSqiw0xJHj45RcgWv7)blwialAyhlrJLEv4a2KqJvFjWg8Cv27GxxiBTuuVny56keKLPXabrAOpR)GvmW0NISqSTs20RcSy7(DwigSaajcjBuSRaBeKfGwxFpLfVazbewB)SabGTT(EKfcYsr9MfyZITDSyjDkieuTOpl2GlfiliHTUgzrhhWgzHyBLSPxfybjS11i1WsuGteYcD1ilpKfSESzXzHmwL3Sqob1zrrwSTJfll6rQyj62fbSyNvGfVazXvkwiMMIYITtPyrhdWeKLgDWuSqHWIfSGls7SaU6RiXYVJSOVgdw8cKfq4tzz3bGSOJyXcDngx4W6vPyPXrJ0De0edeG35YtWyGbWCawG3FWkt)4pElAqCJJEmqSCDfcgNUyGE4pyfdSDaybx08OXkQPIbcI0qFw)bRyGPpfzH41yf1uSy7(Dwi2wjB6vbwwLcPuwiEnwrnfl2GlfilkN(SOGfjSz539IfITvYMEvqZS87yXYIISOJdyJXad99yFEmq91yycE(QGPXe)kklBYIgKNL5zw0xJHj45RcgWv7)blwiel2rCzHaS0RchWMeAS6lb2GNRYEh86czRLI6TblxxHGSenw0Wow0YcaVpxxHMayoalW7pyLPF8hVfnIG4OhdelxxHGXPlgyOVh7ZJbcW7Z1vOjaMdWc8(dwz6ZIwwMWI(AmmbpFvWaUA)pyXYMrYIDexwial9QWbSjHgR(sGn45QS3bVUq2APOEBWY1viilrJfnSJL5zwSNLaeawE9gay97PAwMYY8ml6RXW0oaSGlAE0yf1uMLflAzrFngM2bGfCrZJgROMY0yIFfLfcXIMMfcWsawGR7nwngokMD1rQsW6n)LGzaUAHSqawMWI9SOVgdJUccbvl6BwwSOLf7z5DfwVH(ERGnOblxxHGSmngOh(dwXadOcP)5QSRosvcwF8hVfn00XrpgiwUUcbJtxmWqFp2NhdeG3NRRqtamhGf49hSY0pgOh(dwXaVk4D5)bR4pEl2LwC0JbILRRqW40fdeAfdKIFmqp8hSIbcW7Z1vymqaUAHXadqOceARmbpFvW0yIFfLLnzrJ0yzEMf7zbG3NRRqtawaGeHzqKMQcSOLLaeawE9M6iT)5HJSmpZcyVoqtbZbqAmqqKg6Z6pyfdmkQ3NRRqwwueKfyXIRFQ7pKYYV7pl286z5HSOJSqDaiildyZcX2kztVkWcfYYV7pl)oMIfVX6zXMtFeKLOiw0NfDCaBKLFhtIbcW7C5jymqQdaZdyNdE(Qq8hVf70io6XaXY1viyC6Ib6H)GvmWXQtLHJmQwfgdeePH(S(dwXatFkszH4bjhwUblxXIxSqob1zrrw8cKLVpKYYdzrDfYY9SSSyX297SqqwkQ3AMfITvYMEvqZSqojwqByZs6GfilEbYYwbDR)aGSa0M3jXad99yFEmqmOolkAUk7vkw0YYewC63UkBbTHnleIfnTDSOjSOVgdZy1PYWrgvRcn03deXs0yH8SmpZI(AmmTdal4IMhnwrnLzzXYuw0YYew0xJHXQVeydEUk7DWRlKTwkQ3gaUAHSqiwSJGtJL5zw0xJHj45RcMgt8ROSSjlraltzrlla8(CDfAOoampGDo45RcSOLLjSyplbiaS86nfgAOc2GSmpZci8noOB9hamtT5Dsg0tCsO5VarxrILPSOLLjSyplbiaS86naW63t1SmpZI(AmmTdal4IMhnwrnLPXe)kkleIfnnlAcltyHGzjAS0RchWMeAOxnwQ8Ek6J95gSCDfcYYuw0YI(AmmTdal4IMhnwrnLzzXY8ml2ZI(AmmTdal4IMhnwrnLzzXYuw0YYewSNLaeawE9gIs1NxSmpZsacvGqBLbtSG2WoRdlqtJj(vuw2Kf7sJLPSOLL3Bs4B(lbZpmdEilBYc5zzEMfDiLYIwwghP9p3yIFfLfcXIgPf)XBXo7IJEmqSCDfcgNUyGE4pyfdK(EpCLkgiisd9z9hSIbM(uKLOWc)Dwa(EpCLIfRggOSCdwa(EpCLILJwB)SSSIbg67X(8yG6RXWal83PzlSdO1FWYSSyrll6RXWqFVhUszAC0iD31vy8hVf7IyC0JbILRRqW40fd0d)bRyGbVcOkRVgJyGH(ESppgO(Amm03BfSbnnM4xrzHqSqEw0YYew0xJHbdQZIIzku5TPXe)kklBYc5zzEMf91yyWG6SOywTkVnnM4xrzztwipltzrllo9BxLTG2WMLnzrtNwmq91yKlpbJbsFVvWgmgiisd9z9hSIbsmVcOIfGV3kydYYny5Ew2DklkKsz539IfYtzPXe)QRiPzwsbxS4nYI)SOPtJaSSvkbHfVaz53rwcRUX6zHCcQZIISS7uwipbOS0yIF1vKI)4Tyhbhh9yGy56kemoDXa9WFWkgyWRaQY6RXigyOVh7ZJb(UcR3CvW7Y)dwgSCDfcYIwwSNL3vy9McTLtGWYGLRRqqw0YsuCSmHLjSeX0sJfnHfN(TRYwqByZcbyHGtJfnHfk(zDyTOM)W2UiiBNvGLOXcbNgltzHSSmHfcMfYYc1cvQ8UtFKLPSOjSeGqfi0wzcWcaKim)7yMAD99utJj(vuwMYcHyjkowMWYewIyAPXIMWIt)2vzlOnSzrtyrFnggR(sGn45QS3bVUq2APOEBa4QfYcbyHGtJfnHfk(zDyTOM)W2UiiBNvGLOXcbNgltzHSSmHfcMfYYc1cvQ8UtFKLPSOjSeGqfi0wzcWcaKim)7yMAD99utJj(vuwMYIwwcqOceARmbpFvW0yIFfLLnzjIPXIww0xJHXQVeydEUk7DWRlKTwkQ3gaUAHSqiwStJ0yrll6RXWy1xcSbpxL9o41fYwlf1BdaxTqw2KLiMglAzjaHkqOTYeGfairy(3Xm1667PMgt8ROSqiwi40yrllJJ0(NBmXVIYYMSeGqfi0wzcWcaKim)7yMAD99utJj(vuwialeFw0YYew6vHdytcnbuH0)CvMAD99udwUUcbzzEMfaEFUUcnbybaseMbrAQkWY0yG6RXixEcgd0QVeydEUk7DWRlKTwkQ3XabrAOpR)GvmqI5vavS87ileKLI6nl6RXGLBWYVJSy1Wal2GlfyT9ZI6kKLLfl2UFNLFhzPqc)S8xcYcXGfairilbycszbogSeanSe99JYYIUCLkflWsLILD3YclklGR(ksS87ilPJmmXF8wSJ8XrpgiwUUcbJtxmqOvmqk(Xa9WFWkgiaVpxxHXab4QfgdmabGLxVPos7FE4ilAzPxfoGnj0y1xcSbpxL9o41fYwlf1BdwUUcbzrll6RXWy1xcSbpxL9o41fYwlf1BdaxTqwialo9BxLTG2WMfcWsezzZizjIPLglAzbG3NRRqtawaGeHzqKMQcSOLLaeQaH2ktawaGeH5FhZuRRVNAAmXVIYcHyXPF7QSf0g2SqwwIyASenwifanjoHzrll2ZcyVoqtbZbqklAzbdQZIIMRYELIfTS40VDv2cAdBw2KfaEFUUcnbybaseMDQflAzjaHkqOTYe88vbtJj(vuw2KfYhdeePH(S(dwXabIpLfB7yXcbzPOEZcDhUuGSOJSy1Wqabzb9wLILhYIoYIRRqwEillkYcXGfairilWILaeQaH2kwMqoukw)5kvkw0XambPS89cz5gSaUsSUIelBLsqyPG2yX2PuS4kf0glPGlwEilwypWWRsXcwp2SqqwkQ3S4fil)owSSOiledwaGeHtJbcW7C5jymqRggYwlf17m6Tkv8hVf7i(XrpgiwUUcbJtxmqp8hSIbsFVhUsfdeePH(S(dwXatFkYcW37HRuSy7(Dwa(Os5nlAQ(gplWML3UiGfc2kWIxGSuqwa(ERGnOMzX2owSuqwa(EpCLILJYYYIfyZYdzXQHbwiilf1BwSTJflUoeaYIMonw2kLGmb2S87ilO3QuSqqwkQ3Sy1Wala8(CDfYYrz57foLfyZIdA5)bazHAZ7ew2DklrabOyGYsJj(vxrIfyZYrz5kwgQJ0(hdm03J95XaNWY7kSEd9rLY7myFJ3GLRRqqwMNzHIFwhwlQ5pSTlcYeSvGLPSOLf7z5DfwVH(ERGnOblxxHGSOLf91yyOV3dxPmnoAKU76kKfTSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSOLLjSOVgdJvFjWg8Cv27GxxiBTuuVnaC1czzZizXoYNglAzXEw0xJHj45RcMLflAzzcla8(CDfACQvgCLyXY8ml6RXWq0vGncMXelOnStW6ZyHnPlQOzzXY8mla8(CDfASAyiBTuuVZO3QuSmLL5zwMWsacalVEtHHgQGnilAz5DfwVH(Os5DgSVXBWY1viilAzzclGW34GU1FaWm1M3jzqpXjHMgt8ROSSjlralZZS4H)GLXbDR)aGzQnVtYGEItcnxLhQJ0(ZYuwMYYuw0YYewcqOceARmbpFvW0yIFfLLnzrJ0yzEMLaeQaH2ktawaGeH5FhZuRRVNAAmXVIYYMSOrASmn(J3IDe34OhdelxxHGXPlgOh(dwXaPV30vtcJbcI0qFw)bRyGAQvIfLLTsjiSOJdyJSqmybaseYYIEfjw(DKfIblaqIqwcWc8(dwS8qwc7yGiwUbledwaGeHSCuw8WVCLkflUoC9S8qw0rwco9Jbg67X(8yGa8(CDfASAyiBTuuVZO3QuXF8wSlcIJEmqSCDfcgNUyGE4pyfdSqB5eiSIbcI0qFw)bRyGPpfzjkaclkl22XILuWflEJS46W1ZYdjR3ilb3Y6ksSe29MeszXlqwsCIqwORgz53XuS4nYYvS4flKtqDwuKf6FkfldyZcb9rbKL4ffedm03J95XaDRCyhdeXIwwMWsy3BsiLLizXow0YsJHDVjH5)sqwielKNL5zwc7EtcPSejlrKLPXF8wStthh9yGy56kemoDXad99yFEmq3kh2XarSOLLjSe29MeszjswSJfTS0yy3Bsy(VeKfcXc5zzEMLWU3KqklrYsezzklAzzcl6RXWGb1zrXSAvEBAmXVIYYMSGegdRhZ)LGSmpZI(AmmyqDwumtHkVnnM4xrzztwqcJH1J5)sqwMgd0d)bRyG7UAKtGWk(J3setlo6XaXY1viyC6Ibg67X(8yGUvoSJbIyrlltyjS7njKYsKSyhlAzPXWU3KW8FjileIfYZY8mlHDVjHuwIKLiYYuw0YYew0xJHbdQZIIz1Q820yIFfLLnzbjmgwpM)lbzzEMf91yyWG6SOyMcvEBAmXVIYYMSGegdRhZ)LGSmngOh(dwXahlLkNaHv8hVLiQrC0JbILRRqW40fd0d)bRyG03B6QjHXabrAOpR)GvmW0NISa89MUAsilrHf(7Sy1WaLfVazbCLyXYwPeewSTJfleBRKn9QGMzHCsSG2WML0blqnZYVJSeffRFpvZI(Amy5OS46W1ZYdzz4kflWXGfyZsk4ABqwcUflBLsqIbg67X(8yGyqDwu0Cv2RuSOLLjSOVgddSWFNMdk07mGJEWYSSyzEMf91yyi6kWgbZyIf0g2jy9zSWM0fv0SSyzEMf91yycE(QGzzXIwwMWI9SeGaWYR3quQ(8IL5zwcqOceARmyIf0g2zDybAAmXVIYYMSqEwMNzrFngMGNVkyAmXVIYcHyHua0K4eMLOXYqbHnltyXPF7QSf0g2Sqwwa4956k0qP5aK(SmLLPSOLLjSyplbiaS86naW63t1SmpZI(AmmTdal4IMhnwrnLPXe)kkleIfsbqtItywIglb8uSmHLjS40VDv2cAdBwialeCASenwExH1BgRovgoYOAvOblxxHGSmLfYYcaVpxxHgknhG0NLPSqawIilrJL3vy9McTLtGWYGLRRqqw0YI9S0RchWMeAOxnwQ8Ek6J95gSCDfcYIww0xJHPDaybx08OXkQPmllwMNzrFngM2bGfCrZJgROMktVASu59u0h7ZnllwMNzzcl6RXW0oaSGlAE0yf1uMgt8ROSqiw8WFWYqFVhxJgKWyy9y(VeKfTSqTqLkV70hzHqSKMHGzzEMf91yyAhawWfnpASIAktJj(vuwielE4pyzS1(VBqcJH1J5)sqwMNzbG3NRRqZfHG5aSaV)GflAzjaHkqOTYCfn0R31vyocxE9RKmic4cOPrhmflAzbJW1zzHGMROHE9UUcZr4YRFLKbraxazzklAzrFngM2bGfCrZJgROMYSSyzEMf7zrFngM2bGfCrZJgROMYSSyrll2ZsacvGqBLPDaybx08OXkQPmn6GPyzklZZSaW7Z1vOXPwzWvIflZZSOdPuw0YY4iT)5gt8ROSqiwifanjoHzjASeWtXYewC63UkBbTHnlKLfaEFUUcnuAoaPpltzzA8hVLiAxC0JbILRRqW40fd0d)bRyG03B6QjHXabrAOpR)GvmWO3Py5HSK4eHS87il6i9zboyb47Tc2GSONIf67bIUIel3ZYYILiCDbIuPy5kw8kflKtqDwuKf91ZcbzPOEZYrRTFwCD46z5HSOJSy1WqabJbg67X(8yGVRW6n03BfSbny56keKfTSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSOLLjSOVgdd99wbBqZYIL5zwC63UkBbTHnlBYIMonwMYIww0xJHH(ERGnOH(EGiwielrKfTSmHf91yyWG6SOyMcvEBwwSmpZI(AmmyqDwumRwL3MLfltzrll6RXWy1xcSbpxL9o41fYwlf1BdaxTqwiel2rCtJfTSmHLaeQaH2ktWZxfmnM4xrzztw0inwMNzXEwa4956k0eGfairygePPQalAzjabGLxVPos7FE4iltJ)4TeXigh9yGy56kemoDXaHwXaP4hd0d)bRyGa8(CDfgdeGRwymqmOolkAUkRwL3SenwIawillE4pyzOV3JRrdsymSEm)xcYcbyXEwWG6SOO5QSAvEZs0yzcleFwialVRW6nu4sLHJ8VJ5bSr6BWY1viilrJLiYYuwillE4pyzS1(VBqcJH1J5)sqwialPziyYZczzHAHkvE3PpYcbyjnd5zjAS8UcR3u(VAKM1DLxb0GLRRqWyGGin0N1FWkgi5q)lXFKYYo0gljRWolBLsqyXBKfs(viilwyZcfdWc0WsuyPsXY7eHuwCwOLBr3HpldyZYVJSewDJ1Zc9(L)hSyHczXgCPaRTFw0rw8qy1(JSmGnlkVjHnl)LGJ2tqAmqaENlpbJb6ulcc2aXq8hVLisWXrpgiwUUcbJtxmqp8hSIbsFVPRMegdeePH(S(dwXa1uRelwa(EtxnjKLRyXlwiNG6SOiloLfkewS4uwSGu6PRqwCklkyrIfNYsk4IfBNsXcwGSSSyX297SebPrawSTJfly9yFfjw(DKLcj8Zc5euNff1mlGWA7Nff(SCplwnmWcbzPOERzwaH12plqayBRVhzXlwIcl83zXQHbw8cKfliuXIooGnYcX2kztVkWIxGSqojwqByZs6GfymWqFp2Nhd0Ew6vHdytcn)LG2GDLbB0t0VceBdwUUcbzrlltyrFnggR(sGn45QS3bVUq2APOEBa4QfYcHyXoIBASmpZI(Ammw9LaBWZvzVdEDHS1sr92aWvlKfcXIDKpnw0YY7kSEd9rLY7myFJ3GLRRqqwMYIwwMWcguNffnxLPqL3SOLfN(TRYwqByZcbybG3NRRqJtTiiydedSenw0xJHbdQZIIzku5TPXe)kkleGfq4BgRovgoYOAvO5Var0CJj(vSenwSZqEw2KLiinwMNzbdQZIIMRYQv5nlAzXPF7QSf0g2Sqawa4956k04ulcc2aXalrJf91yyWG6SOywTkVnnM4xrzHaSacFZy1PYWrgvRcn)fiIMBmXVILOXIDgYZYMSOPtJLPSOLf7zrFnggyH)onBHDaT(dwMLflAzXEwExH1BOV3kydAWY1viilAzzclbiubcTvMGNVkyAmXVIYYMSqCzzEMfkCP0Vc0879PuzkIeHTblxxHGSOLf91yy(9(uQmfrIW2qFpqeleILigrw0ewMWsVkCaBsOHE1yPY7POp2NBWY1viilrJf7yzklAzzCK2)CJj(vuw2Kfnslnw0YY4iT)5gt8ROSqiwSlT0yzEMfWEDGMcMdGuwMYIwwMWI9SeGaWYR3quQ(8IL5zwcqOceARmyIf0g2zDybAAmXVIYYMSyhltJ)4TerYhh9yGy56kemoDXa9WFWkgyH2YjqyfdeePH(S(dwXatFkYsuaewuwUIfVsXc5euNffzXlqwOoaKfc6D1GaeVLsXsuaewSmGnleBRKn9QalEbYsuSRaBeKfYjXcAd7eSEdlBvrHSSOilBjkGfVazH4ffWI)S87ilybYcCWcXRXkQPyXlqwaH12plk8zrt1ONOFfi2SmCLIf4yedm03J95XaDRCyhdeXIwwa4956k0qDayEa7CWZxfyrlltyrFnggmOolkMvRYBtJj(vuw2KfKWyy9y(VeKL5zw0xJHbdQZIIzku5TPXe)kklBYcsymSEm)xcYY04pElrK4hh9yGy56kemoDXad99yFEmq3kh2XarSOLfaEFUUcnuhaMhWoh88vbw0YYew0xJHbdQZIIz1Q820yIFfLLnzbjmgwpM)lbzzEMf91yyWG6SOyMcvEBAmXVIYYMSGegdRhZ)LGSmLfTSmHf91yycE(QGzzXY8ml6RXWy1xcSbpxL9o41fYwlf1BdaxTqwiuKSyNgPXYuw0YYewSNLaeawE9gay97PAwMNzrFngM2bGfCrZJgROMY0yIFfLfcXYewiplAcl2Xs0yPxfoGnj0qVASu59u0h7Zny56keKLPSOLf91yyAhawWfnpASIAkZYIL5zwSNf91yyAhawWfnpASIAkZYILPSOLLjSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSmpZcsymSEm)xcYcHyrFngM)sqBWUYGn6j6xbITPXe)kklZZSypl6RXW8xcAd2vgSrpr)kqSnllwMgd0d)bRyG7UAKtGWk(J3sejUXrpgiwUUcbJtxmWqFp2Nhd0TYHDmqelAzbG3NRRqd1bG5bSZbpFvGfTSmHf91yyWG6SOywTkVnnM4xrzztwqcJH1J5)sqwMNzrFnggmOolkMPqL3Mgt8ROSSjliHXW6X8FjiltzrlltyrFngMGNVkywwSmpZI(Ammw9LaBWZvzVdEDHS1sr92aWvlKfcfjl2PrASmLfTSmHf7zjabGLxVHOu95flZZSOVgddrxb2iygtSG2WobRpJf2KUOIMLfltzrlltyXEwcqay51BaG1VNQzzEMf91yyAhawWfnpASIAktJj(vuwielKNfTSOVgdt7aWcUO5rJvutzwwSOLf7zPxfoGnj0qVASu59u0h7Zny56keKL5zwSNf91yyAhawWfnpASIAkZYILPSOLLjSypl9QWbSjHM)sqBWUYGn6j6xbITblxxHGSmpZcsymSEm)xcYcHyrFngM)sqBWUYGn6j6xbITPXe)kklZZSypl6RXW8xcAd2vgSrpr)kqSnllwMgd0d)bRyGJLsLtGWk(J3seJG4OhdelxxHGXPlgiisd9z9hSIbM(uKfcki5WcSyjagd0d)bRyG28UpyNHJmQwfg)XBjIA64OhdelxxHGXPlgOh(dwXaPV3JRXyGGin0N1FWkgy6trwa(EpUgz5HSy1WalaHkVzHCcQZIIAMfITvYMEvGLDNYIcPuw(lbz539IfNfcQ2)DwqcJH1JSOWXZcSzbwQuSqgRYBwiNG6SOilhLLLLHfcQ73zj62fbSyNvGfSESzXzbiu5nlKtqDwuKLBWcbzPOEZc9pLILDNYIcPuw(DVyXonsJf67bIOS4fileBRKn9QalEbYcXGfairil7oaKLeyJS87EXIgexklettXsJj(vxrYWs6trwCDiaKf7iFAehw2D6JSaU6RiXcXRXkQPyXlqwSZo7ioSS70hzX297W1ZcXRXkQPIbg67X(8yGyqDwu0CvwTkVzrll2ZI(AmmTdal4IMhnwrnLzzXY8mlyqDwu0qHkVZfs4NL5zwMWcguNffnELkxiHFwMNzrFngMGNVkyAmXVIYcHyXd)blJT2)DdsymSEm)xcYIww0xJHj45RcMLfltzrlltyXEwO4N1H1IA(dB7IGSDwbwMNzPxfoGnj0y1xcSbpxL9o41fYwlf1BdwUUcbzrll6RXWy1xcSbpxL9o41fYwlf1BdaxTqwiel2PrASOLLaeQaH2ktWZxfmnM4xrzztw0G4YIwwMWI9SeGaWYR3uhP9ppCKL5zwcqOceARmbybaseM)DmtTU(EQPXe)kklBYIgexwMYIwwMWI9S0EanFdvkwMNzjaHkqOTYOJnfBIUIKPXe)kklBYIgexwMYYuwMNzbdQZIIMRYELIfTSmHf91yyS5DFWodhzuTk0SSyzEMfQfQu5DN(ileIL0mem5zrlltyXEwcqay51BaG1VNQzzEMf7zrFngM2bGfCrZJgROMYSSyzklZZSeGaWYR3aaRFpvZIwwOwOsL3D6JSqiwsZqWSmn(J3cbNwC0JbILRRqW40fdeePH(S(dwXatFkYcbv7)olWFhBBhfzX2(f2z5OSCflaHkVzHCcQZIIAMfITvYMEvGfyZYdzXQHbwiJv5nlKtqDwumgOh(dwXaT1(Vh)XBHG1io6XaXY1viyC6IbcI0qFw)bRyGepxP(9Efd0d)bRyG9QYE4pyLvh9JbQo6NlpbJboCL637v8h)XFmqaytpyfVf7sZo7slIPrCJbAZ76ks0yGeuBLG2wsVTqqxuYclrFhz5sSG9ZYa2SSn0clS3MLgJW11iiluycYIVEyI)iilHDViHudVbzCfYIDrjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42Smrdcp1WBqgxHSeXOKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMObHNA4n4niO2kbTTKEBHGUOKfwI(oYYLyb7NLbSzzBqC4l1VnlngHRRrqwOWeKfF9We)rqwc7ErcPgEdY4kKfIFuYcXGfaSFeKfGxcXyHMQENWSqCy5HSqglNfWdWrpyXc0cB)Hnlti7uwMObHNA4niJRqwi(rjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42SmXocp1WBqgxHSqCJswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczjcIswigSaG9JGSa8sigl0u17eMfIdlpKfYy5SaEao6blwGwy7pSzzczNYYe7i8udVbzCfYseeLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYeni8udVbzCfYIMokzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLjrKWtn8gKXvilA6OKfIblay)iilB)9veHVrddzUnlpKLT)(kIW38AyiZTzzIDeEQH3GmUczrthLSqmyba7hbzz7VVIi8n2ziZTz5HSS93xre(M3odzUnltSJWtn8gKXvilAKwuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilAOruYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilAyxuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilAeXOKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMObHNA4niJRqw0G8rjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42Smrdcp1WBqgxHSObXpkzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLj2r4PgEdY4kKfni(rjledwaW(rqw2(7RicFJggYCBwEilB)9veHV51WqMBZYe7i8udVbzCfYIge)OKfIblay)iilB)9veHVXodzUnlpKLT)(kIW382ziZTzzIgeEQH3GmUczrdIBuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnltSJWtn8gKXvilAqCJswigSaG9JGSS93xre(gnmK52S8qw2(7RicFZRHHm3MLjAq4PgEdY4kKfniUrjledwaW(rqw2(7RicFJDgYCBwEilB)9veHV5TZqMBZYe7i8udVbVbb1wjOTL0Ble0fLSWs03rwUely)SmGnlBB1yaMO7)2S0yeUUgbzHctqw81dt8hbzjS7fjKA4niJRqwIyuYcXGfaSFeKLT)(kIW3OHHm3MLhYY2FFfr4BEnmK52SmjIeEQH3GmUczHGJswigSaG9JGSS93xre(g7mK52S8qw2(7RicFZBNHm3MLjrKWtn8gKXvile3OKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBw8NfYjkKmyzIgeEQH3G3GGARe02s6Tfc6Iswyj67ilxIfSFwgWMLTDiUnlngHRRrqwOWeKfF9We)rqwc7ErcPgEdY4kKfnIswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczXUOKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMObHNA4niJRqwSlkzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3Mf)zHCIcjdwMObHNA4niJRqwIyuYcXGfaSFeKLTFxH1BiZTz5HSS97kSEdzAWY1vi42Smrdcp1WBqgxHSeXOKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMercp1WBqgxHSq8JswigSaG9JGSa8sigl0u17eMfIdXHLhYczSCwsGGl1IYc0cB)HnltiotzzIgeEQH3GmUczH4hLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYe7i8udVbzCfYcXnkzHyWca2pcYcWlHySqtvVtywioehwEilKXYzjbcUulklqlS9h2SmH4mLLjAq4PgEdY4kKfIBuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilrquYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilA6OKfIblay)iilaVeIXcnv9oHzH4WYdzHmwolGhGJEWIfOf2(dBwMq2PSmXocp1WBqgxHSOHDrjledwaW(rqwaEjeJfAQ6DcZcXHLhYczSCwapah9GflqlS9h2SmHStzzIgeEQH3GmUczrdcokzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLjAq4PgEdY4kKfniFuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnlt0GWtn8gKXvilAq8JswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczrJiikzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLjAq4PgEdY4kKf7slkzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLj2r4PgEdY4kKf7SlkzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDklt0GWtn8gKXvil2rWrjledwaW(rqwaEjeJfAQ6DcZcXHLhYczSCwapah9GflqlS9h2SmHStzzIDeEQH3GmUczXocokzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLjAq4PgEdY4kKf7i(rjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42Smrdcp1WBqgxHSyhXnkzHyWca2pcYY29QWbSjHgYCBwEilB3RchWMeAitdwUUcb3MLjAq4PgEdY4kKf700rjledwaW(rqwaEjeJfAQ6DcZcXHLhYczSCwapah9GflqlS9h2SmHStzzIDeEQH3GmUczjIPfLSqmyba7hbzb4LqmwOPQ3jmlehwEilKXYzb8aC0dwSaTW2FyZYeYoLLjAq4PgEdEdcQTsqBlP3wiOlkzHLOVJSCjwW(zzaBw2E4k1V3RTzPXiCDncYcfMGS4RhM4pcYsy3lsi1WBqgxHSyxuYcXGfaSFeKfGxcXyHMQENWSqCy5HSqglNfWdWrpyXc0cB)Hnlti7uwMObHNA4n4niO2kbTTKEBHGUOKfwI(oYYLyb7NLbSzzB6VnlngHRRrqwOWeKfF9We)rqwc7ErcPgEdY4kKf7IswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzc5j8udVbzCfYseJswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczHGJswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczH4hLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZI)SqorHKblt0GWtn8gKXvilAKwuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnltSJWtn8gKXvilAqWrjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42Smrdcp1WBqgxHSObXpkzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDklt0GWtn8gKXvilAq8JswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzc5j8udVbzCfYIge3OKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMObHNA4niJRqw0icIswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczXonIswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczXocokzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDkltiycp1WBqgxHSyhbhLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYeni8udVbzCfYIDKpkzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDklt0GWtn8gKXvil2r(OKfIblay)iilB3RchWMeAiZTz5HSSDVkCaBsOHmny56keCBwMObHNA4niJRqwSJ4hLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYeni8udVbzCfYse1ikzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDkltIiHNA4niJRqwIOgrjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42Smrdcp1WBqgxHSer7IswigSaG9JGSSDVkCaBsOHm3MLhYY29QWbSjHgY0GLRRqWTzzIgeEQH3GmUczjIrmkzHyWca2pcYcWlHySqtvVtywioS8qwiJLZc4b4OhSybAHT)WMLjKDkltIiHNA4niJRqwIibhLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYe7i8udVbzCfYsej(rjledwaW(rqw2UxfoGnj0qMBZYdzz7Ev4a2KqdzAWY1vi42SmXocp1WBqgxHSerIBuYcXGfaSFeKLT7vHdytcnK52S8qw2UxfoGnj0qMgSCDfcUnltSJWtn8gKXvilruthLSqmyba7hbzz7Ev4a2KqdzUnlpKLT7vHdytcnKPblxxHGBZYeni8udVbVr6Lyb7hbzH4ZIh(dwSOo6tn8gXaPwyiElAKMDXaTA44uymqYLCzjDUYRaYIMQxhiVb5sUSef4DyNLiqZSyxA2zhVbVb5sUSqSDViH0OK3GCjxw0ew2kiicYcqOYBwsh6jgEdYLCzrtyHy7Ercbz59Me(5BWsWPiLLhYsivqH53Bs4tn8gKl5YIMWcbnmbcabzzvfgqk17uSaW7Z1viLLjNbnAMfRgbKPV30vtczrt2KfRgbyOV30vtcNA4nixYLfnHLTcaEGSy1yWP)vKyHGQ9FNLBWY9Btz53rwS1WIelKtqDwu0WBqUKllAclrboriledwaGeHS87ilaTU(EklolQ7FfYscSrwgkKWNUczzYnyjfCXYUdwB)SSFpl3Zc9swQ3leUOQuSy7(Dwsxu4wJoleGfIHkK(NRyzRQJuLG1RzwUFBqwOeDwtn8gKl5YIMWsuGteYscK(SS94iT)5gt8ROBZcnGL3hKYIBzPsXYdzrhsPSmos7pLfyPsz4nixYLfnHLO3O)SeDycYcCWs6u(olPt57SKoLVZItzXzHAHHZvS89veHVH3GCjxw0ewIcTWcBwMCg0OzwiOA)31mleuT)7AMfGV3JRXPSK4GiljWgzPr6PoSEwEilO3QdBwcWeD)1e679B4nixYLfnHfI3rywIIDfyJGSqojwqByNG1ZsyhdeXYa2SqmnfllQtcn8g8gKl5YYwRc((JGSKox5vazzReeYGLGxSOJSmGRcKf)zz)FlAuswYQ7kVcOMqVKGH097lDZbjB6CLxbutaEjeJSjGM9prff)4uyK6UYRaAEc)8g8gE4pyrnwngGj6(hjrxb2iyMAD99uEdYLLOVJSaW7Z1vilhLfk(S8qwsJfB3VZsbzH((ZcSyzrrw((kIWNQzw0GfB7yXYVJSmUM(SalKLJYcSyzrrnZIDSCdw(DKfkgGfilhLfVazjISCdw0H)olEJ8gE4pyrnwngGj6(tGijlaVpxxHAU8emsyLxum)9veHVMb4QfgzA8gE4pyrnwngGj6(tGijlaVpxxHAU8emsyLxum)9veHVMHwr6GGAgGRwyKAO5Be53xre(gnm7onVOywFngA)(kIW3OHjaHkqOTYaUA)pyP1(VVIi8nAyoQ5HjygoYjWI(nCrZbyr)Ef(dwuEdp8hSOgRgdWeD)jqKKfG3NRRqnxEcgjSYlkM)(kIWxZqRiDqqndWvlms708nI87RicFJDMDNMxumRVgdTFFfr4BSZeGqfi0wzaxT)hS0A)3xre(g7mh18Wemdh5eyr)gUO5aSOFVc)blkVb5Ys03rkYY3xre(uw8gzPGpl(6Hj(FbxPsXci(y4rqwCklWILffzH((ZY3xre(udlSaeFwa4956kKLhYcbZItz53XuS4kkKLcrqwOwy4Cfl7EbQUIKH3Wd)blQXQXamr3Fcejzb4956kuZLNGrcR8II5VVIi81m0ksheuZaC1cJKG18nIeJW1zzHGMROHE9UUcZr4YRFLKbraxaNNXiCDwwiObtSs1ORYWgS8kGZZyeUolle0qHlLc))ks5EPNI3GCzbi(uw(DKfGV30vtczjaPpldyZIYFSzj4QWs5)blkltgWMfKWEILczX2owS8qwOV3plGReRRiXIooGnYcXRXkQPyz4kfLf4ymL3Wd)blQXQXamr3Fcejzb4956kuZLNGrsP5aK(AgGRwyKrmTOnrdnjnJDrJIFwhwlQ5pSTlcYeSvykVb5Ycq8PS4pl22VWolEcCvplWblBLsqyHyWcaKiKf6oCPazrhzzrrWOKfconwSD)oC9SqmuH0)CflaTU(EklEbYsetJfB3VB4n8WFWIASAmat09NarswaEFUUc1C5jyKbybaseMDQLMb4QfgzetJaAKw06vHdytcnbuH0)CvMAD99uEdp8hSOgRgdWeD)jqKKnbclIUkpGDcVHh(dwuJvJbyIU)eisYAR9FxZQRWCamsnstZ3iYjyqDwu0OwL35cj8ppJb1zrrZvzku598mguNffnxL1H)(8mguNffnELkxiH)P8g8gKlleKgdo9zXowiOA)3zXlqwCwa(EtxnjKfyXcWOZIT73zzlhP9NfINJS4filPdU1OZcSzb4794AKf4VJTTJI8gE4pyrnqlSWMarswBT)7A(grobdQZIIg1Q8oxiH)5zmOolkAUktHkVNNXG6SOO5QSo83NNXG6SOOXRu5cj8pvRvJamAyS1(VR1ERgbySZyR9FN3Wd)blQbAHf2eisYsFVhxJAwDfMdGrsEnFJiNyFVkCaBsOr3vEfWmCKDLk)7xrIopBFacalVEtDK2)8WX5z7PwOsLFVjHp1qFVhUsfPgZZ2)UcR3u(VAKM1DLxb0GLRRqWPATNIFwhwlQ5pSTlcY2zfMNNGb1zrrdfQ8oxiH)5zmOolkAUkRwL3ZZyqDwu0Cvwh(7ZZyqDwu04vQCHe(NYB4H)Gf1aTWcBcejzPV30vtc1S6kmhaJK8A(groPxfoGnj0O7kVcygoYUsL)9Rir1gGaWYR3uhP9ppCul1cvQ87nj8Pg679WvQi1yQw7P4N1H1IA(dB7IGSDwbEdEdYLCzHCimgwpcYcca7uS8xcYYVJS4Hh2SCuwCa(PCDfA4n8WFWIgjfQ8oRJEcVHh(dwucejzdUsL9WFWkRo6R5YtWiHwyHTMPFFHpsn08nI8VeKqtSlAE4pyzS1(VBco9Z)LGeWd)bld99ECnAco9Z)LGt5nixwaIpLLTcjhwGflrKaSy7(D46zbSVXZIxGSy7(Dwa(ERGnilEbYIDeGf4VJTTJI8gE4pyrjqKKfG3NRRqnxEcg5rZoe1maxTWiPwOsLFVjHp1qFVhUsTPgANy)7kSEd99wbBqdwUUcbNNFxH1BOpQuENb7B8gSCDfcoDEMAHkv(9Me(ud99E4k1M2XBqUSaeFklbf6aqwSTJflaFVhxJSe8IL97zXocWY7nj8PSyB)c7SCuwAuHa86zzaBw(DKfYjOolkYYdzrhzXQXb2ncYIxGSyB)c7SmoLcBwEilbN(8gE4pyrjqKKfG3NRRqnxEcg5rZbf6aqndWvlmsQfQu53Bs4tn037X14MAWBqUSef17Z1vil)U)Se2XaruwUblPGlw8gz5kwCwifaz5HS4aGhil)oYc9(L)hSyX2o2ilolFFfr4Zc(bwokllkcYYvSOJVnelwco9P8gE4pyrjqKKfG3NRRqnxEcg5vzsbqndWvlmsRgbKjfanAysGWACnopB1iGmPaOrddDvJRX5zRgbKjfanAyOV30vtcNNTAeqMua0OHH(EpCLAE2QrazsbqJgMXQtLHJmQwfopB1iat7aWcUO5rJvutnpRVgdtWZxfmnM4xrJuFngMGNVkyaxT)hSMNb4956k0C0SdrEdYLL0NISKoSPyt0vKyXFw(DKfSazboyH41yf1uSyBhlw2D6JSCuwCDiaKfIFAehnZIpESzHyWcaKiKfB3VZs6GE0zXlqwG)o22okYIT73zHyBLSPxf4n8WFWIsGijRo2uSj6ksA(grozI9biaS86n1rA)ZdhNNTpaHkqOTYeGfairy(3Xm1667PML18S99QWbSjHgDx5vaZWr2vQ8VFfj6uT6RXWe88vbtJj(v0n1G8A1xJHPDaybx08OXkQPmnM4xrjebR1(aeawE9gay97P655aeawE9gay97PAT6RXWe88vbZYsR(AmmTdal4IMhnwrnLzzPDI(AmmTdal4IMhnwrnLPXe)kkHIud70ecoA9QWbSjHg6vJLkVNI(yF(8S(AmmbpFvW0yIFfLqAOX8SgehQfQu5DN(iH0Wq8NovlaVpxxHMRYKcG8gKllee4ZIT73zXzHyBLSPxfy539NLJwB)S4SqqwkQ3Sy1WalWMfB7yXYVJSmos7plhLfxhUEwEilybYB4H)GfLarswl4FWsZ3iYj6RXWe88vbtJj(v0n1G8ANyFVkCaBsOHE1yPY7POp2NppRVgdt7aWcUO5rJvutzAmXVIsin00A1xJHPDaybx08OXkQPmlRPZZ6qkv74iT)5gt8ROeYoYpvlaVpxxHMRYKcG8gKlleZvHLYFKYITD83XMLf9ksSqmybaseYsbTXITtPyXvkOnwsbxS8qwO)PuSeC6ZYVJSq9eKfpbUQNf4GfIblaqIqcqSTs20RcSeC6t5n8WFWIsGijlaVpxxHAU8emYaSaajcZGinvf0maxTWid4PMmzCK2)CJj(vunrdYRjbiubcTvMGNVkyAmXVIoL4OreK20id4PMmzCK2)CJj(vunrdYRjbiubcTvMaSaajcZ)oMPwxFp1aUA)pyPjbiubcTvMaSaajcZ)oMPwxFp10yIFfDkXrJiiTPATV9dmJaW6noii1Ge(Opv7e7dqOceARmbpFvW0OdMAE2(aeQaH2ktawaGeHMgDWutNNdqOceARmbpFvW0yIFfDZRESTGk)rW84iT)5gt8ROZZ9QWbSjHMaQq6FUktTU(EQ2aeQaH2ktWZxfmnM4xr3mIPnphGqfi0wzcWcaKim)7yMAD99utJj(v0nV6X2cQ8hbZJJ0(NBmXVIQjAK28S9biaS86n1rA)Zdh5nixwsFkcYYdzbevEkw(DKLf1jHSahSqSTs20RcSyBhlww0RiXciCPRqwGfllkYIxGSy1iaSEwwuNeYITDSyXlwCqqwqay9SCuwCD46z5HSaEiVHh(dwucejzb4956kuZLNGrgaZbybE)blndWvlmYjV3KW38xcMFyg8Wn1G8ZZTFGzeawVXbbPMR2K8Pnv7KjyeUolle0GjwPA0vzydwEfqTtSpabGLxVbaw)EQEEoaHkqOTYGjwPA0vzydwEfqtJj(vucPbXN4sGjKpA9QWbSjHg6vJLkVNI(yF(0PATpaHkqOTYGjwPA0vzydwEfqtJoyQPZZyeUolle0qHlLc))ks5EPNs7e7dqay51BQJ0(NhoophGqfi0wzOWLsH)FfPCV0tLJibt(iinnmnM4xrjKgAqWtNNNeGqfi0wz0XMInrxrY0OdMAE2(2dO5BOsnphGaWYR3uhP9ppCCQ2j2)UcR3mwDQmCKr1QqdwUUcbNNdqay51BaG1VNQ1gGqfi0wzgRovgoYOAvOPXe)kkH0qdcq(O1RchWMeAOxnwQ8Ek6J95ZZ2hGaWYR3aaRFpvRnaHkqOTYmwDQmCKr1QqtJj(vucPVgdtWZxfmGR2)dweqd7IwVkCaBsOXQVeydEUk7DWRlKTwkQ3AIg2nv7emcxNLfcAUIg6176kmhHlV(vsgebCbuBacvGqBL5kAOxVRRWCeU86xjzqeWfqtJj(vucr(PZZtMGr46SSqqdD3bH2qWmS1ZWr(HDcwV2aeQaH2kZd7eSEemFf9iT)5isEYhr70W0yIFfD688Kja8(CDfAGvErX83xre(rQX8maVpxxHgyLxum)9veHFKrCQ2jFFfr4B0W0OdMkhGqfi0wnp)9veHVrdtacvGqBLPXe)k6Mx9yBbv(JG5XrA)ZnM4xr1ensB68maVpxxHgyLxum)9veHFK2PDY3xre(g7mn6GPYbiubcTvZZFFfr4BSZeGqfi0wzAmXVIU5vp2wqL)iyECK2)CJj(vunrJ0MopdW7Z1vObw5ffZFFfr4hzAtNoL3GCzjkQ3NRRqwwueKLhYciQ8uS4vkw((kIWNYIxGSeaPSyBhlwS53FfjwgWMfVyHCww7W(CwSAyG3Wd)blkbIKSa8(CDfQ5YtWi)9(uQmfrIWoBZVxZaC1cJ0EkCP0Vc0879PuzkIeHTblxxHGZZJJ0(NBmXVIUPDPL28SoKs1oos7FUXe)kkHSJ8eycbNMMOVgdZV3NsLPise2g67bIIMDtNN1xJH537tPYuejcBd99arBgXiqtM0RchWMeAOxnwQ8Ek6J95rZUP8gKllPpfzHCsSs1ORyjkSblVcil2Lgfduw0XbSrwCwi2wjB6vbwwuKfyZcfYYV7pl3ZITtPyrDfYYYIfB3VZYVJSGfilWbleVgROMI3Wd)blkbIKSlkMVht0C5jyKyIvQgDvg2GLxbuZ3iYaeQaH2ktWZxfmnM4xrjKDPPnaHkqOTYeGfairy(3Xm1667PMgt8ROeYU00obG3NRRqZV3NsLPise2zB(9ZZ6RXW879PuzkIeHTH(EGOnJyAeysVkCaBsOHE1yPY7POp2NhTioDQwaEFUUcnxLjfaNN1HuQ2XrA)ZnM4xrjuejU8gKllPpfzbiCPu4FfjwiOT0tXcXNIbkl64a2iloleBRKn9QallkYcSzHcz539NL7zX2PuSOUczzzXIT73z53rwWcKf4GfIxJvutXB4H)GfLars2ffZ3JjAU8emskCPu4)xrk3l9uA(grojaHkqOTYe88vbtJj(vucr81AFacalVEdaS(9uTw7dqay51BQJ0(NhoophGaWYR3uhP9ppCuBacvGqBLjalaqIW8VJzQ113tnnM4xrjeXx7eaEFUUcnbybaseMbrAQkmphGqfi0wzcE(QGPXe)kkHi(tNNdqay51BaG1VNQ1oX(Ev4a2Kqd9QXsL3trFSpxBacvGqBLj45RcMgt8ROeI4ppRVgdt7aWcUO5rJvutzAmXVIsinsJatiF0WiCDwwiO5k63RWdBAg8aCfM1rLAQw91yyAhawWfnpASIAkZYA68SoKs1oos7FUXe)kkHSJ8ZZyeUolle0GjwPA0vzydwEfqTbiubcTvgmXkvJUkdBWYRaAAmXVIUPDPnvlaVpxxHMRYKcGAThJW1zzHGMROHE9UUcZr4YRFLKbraxaNNdqOceARmxrd96DDfMJWLx)kjdIaUaAAmXVIUPDPnpRdPuTJJ0(NBmXVIsi7sJ3GCzzRkBEkkllkYs6ffPMIfB3VZcX2kztVkWcSzXFw(DKfSazboyH41yf1u8gE4pyrjqKKfG3NRRqnxEcg5fHG5aSaV)GLMb4QfgP(AmmbpFvW0yIFfDtniV2j23RchWMeAOxnwQ8Ek6J95ZZ6RXW0oaSGlAE0yf1uMgt8ROeksniVH8eysenKpA6RXWORGqq1I(ML1ucmHGnKxtIOH8rtFnggDfecQw03SSMgnmcxNLfcAUI(9k8WMMbpaxHzDuPiabBiF0MGr46SSqqZVJ5X10ptpsNsBacvGqBL53X84A6NPhPtzAmXVIsOiTlTPA1xJHPDaybx08OXkQPmlRPZZ6qkv74iT)5gt8ROeYoYppJr46SSqqdMyLQrxLHny5va1gGqfi0wzWeRun6QmSblVcOPXe)kkVHh(dwucejzxumFpMO5YtWiVIg6176kmhHlV(vsgebCbuZ3isaEFUUcnxecMdWc8(dwAb4956k0CvMuaK3GCzj9Pila3DqOneKLOWwNfDCaBKfITvYMEvG3Wd)blkbIKSlkMVht0C5jyK0DheAdbZWwpdh5h2jy9A(grojaHkqOTYe88vbtJoykT2hGaWYR3uhP9ppCulaVpxxHMFVpLktrKiSZ2871ojaHkqOTYOJnfBIUIKPrhm18S9ThqZ3qLA68CacalVEtDK2)8WrTbiubcTvMaSaajcZ)oMPwxFp10OdMs7eaEFUUcnbybaseMbrAQkmphGqfi0wzcE(QGPrhm10PAbHVHUQX1O5Varxrs7eq4BOpQuENhkVrZFbIUI08S9VRW6n0hvkVZdL3OblxxHGZZuluPYV3KWNAOV3JRXnJ4uTGW3KaH14A08xGORiPDcaVpxxHMJMDiop3RchWMeA0DLxbmdhzxPY)(vKOZZo9BxLTG2WEZi10PnpdW7Z1vOjalaqIWmistvH5z91yy0vqiOArFZYAQw7XiCDwwiO5kAOxVRRWCeU86xjzqeWfW5zmcxNLfcAUIg6176kmhHlV(vsgebCbuBacvGqBL5kAOxVRRWCeU86xjzqeWfqtJj(v0nJyAATxFngMGNVkywwZZ6qkv74iT)5gt8ROeIGtJ3GCzj67hLLJYIZs7)o2SGkxh2(JSyZtXYdzjXjczXvkwGfllkYc99NLVVIi8PS8qw0rwuxHGSSSyX297SqSTs20RcS4filedwaGeHS4fillkYYVJSyxbYcvbFwGflbqwUbl6WFNLVVIi8PS4nYcSyzrrwOV)S89veHpL3Wd)blkbIKSlkMVhtOAMQGpnYVVIi81qZ3iYja8(CDfAGvErX83xre(2hPgAT)7RicFJDMgDWu5aeQaH2Q55ja8(CDfAGvErX83xre(rQX8maVpxxHgyLxum)9veHFKrCQ2j6RXWe88vbZYs7e7dqay51BaG1VNQNN1xJHPDaybx08OXkQPmnM4xrjWKiAiF06vHdytcn0RglvEpf9X(8PekYVVIi8nAy0xJrgC1(FWsR(AmmTdal4IMhnwrnLzznpRVgdt7aWcUO5rJvutLPxnwQ8Ek6J95ML1055aeQaH2ktWZxfmnM4xrjGDB(9veHVrdtacvGqBLbC1(FWsR96RXWe88vbZYs7e7dqay51BQJ0(NhoopBpaVpxxHMaSaajcZGinvfMQ1(aeawE9gIs1NxZZbiaS86n1rA)Zdh1cW7Z1vOjalaqIWmistvbTbiubcTvMaSaajcZ)oMPwxFp1SS0AFacvGqBLj45RcMLL2jt0xJHbdQZIIz1Q820yIFfDtnsBEwFnggmOolkMPqL3Mgt8ROBQrAt1AFVkCaBsOr3vEfWmCKDLk)7xrIopprFnggDx5vaZWr2vQ8VFfjAU8F1OH(EGOij)8S(Amm6UYRaMHJSRu5F)ks0S3bVqd99arrgbtNopRVgddrxb2iygtSG2WobRpJf2KUOIML105zDiLQDCK2)CJj(vuczxAZZa8(CDfAGvErX83xre(rM2uTa8(CDfAUktkaYB4H)GfLars2ffZ3JjuntvWNg53xre(2P5Be5eaEFUUcnWkVOy(7RicF7J0oT2)9veHVrdtJoyQCacvGqB18maVpxxHgyLxum)9veHFK2PDI(AmmbpFvWSS0oX(aeawE9gay97P65z91yyAhawWfnpASIAktJj(vucmjIgYhTEv4a2Kqd9QXsL3trFSpFkHI87RicFJDg91yKbxT)hS0QVgdt7aWcUO5rJvutzwwZZ6RXW0oaSGlAE0yf1uz6vJLkVNI(yFUzznDEoaHkqOTYe88vbtJj(vucy3MFFfr4BSZeGqfi0wzaxT)hS0AV(AmmbpFvWSS0oX(aeawE9M6iT)5HJZZ2dW7Z1vOjalaqIWmistvHPATpabGLxVHOu95L2j2RVgdtWZxfmlR5z7dqay51BaG1VNQNophGaWYR3uhP9ppCulaVpxxHMaSaajcZGinvf0gGqfi0wzcWcaKim)7yMAD99uZYsR9biubcTvMGNVkywwANmrFnggmOolkMvRYBtJj(v0n1iT5z91yyWG6SOyMcvEBAmXVIUPgPnvR99QWbSjHgDx5vaZWr2vQ8VFfj688e91yy0DLxbmdhzxPY)(vKO5Y)vJg67bIIK8ZZ6RXWO7kVcygoYUsL)9RirZEh8cn03defzemD605z91yyi6kWgbZyIf0g2jy9zSWM0fv0SSMN1HuQ2XrA)ZnM4xrjKDPnpdW7Z1vObw5ffZFFfr4hzAt1cW7Z1vO5QmPaiVb5Ys6trklUsXc83XMfyXYIISCpMqzbwSea5n8WFWIsGij7II57XekVb5Yc5C)o2SqcYYvpKLFhzH(SaBwCiYIh(dwSOo6ZB4H)GfLars2Evzp8hSYQJ(AU8emshIAM(9f(i1qZ3isaEFUUcnhn7qK3Wd)blkbIKS9QYE4pyLvh91C5jyK0N3G3GCzHyUkSu(JuwSTJ)o2S87ilAQg9KG)HDSzrFngSy7ukwgUsXcCmyX297xXYVJSuiHFwco95n8WFWIACigjaVpxxHAU8emsWg9KSTtPYdxPYWXqZaC1cJSxfoGnj08xcAd2vgSrpr)kqS1orFngM)sqBWUYGn6j6xbITPXe)kkHifanjoHjqAgnMN1xJH5Ve0gSRmyJEI(vGyBAmXVIsip8hSm037X1ObjmgwpM)lbjqAgn0obdQZIIMRYQv598mguNffnuOY7CHe(NNXG6SOOXRu5cj8pDQw91yy(lbTb7kd2ONOFfi2MLfVb5YcXCvyP8hPSyBh)DSzb47nD1Kqwokl2G9VZsWP)vKybcaBwa(EpUgz5kwiJv5nlKtqDwuK3Wd)blQXHibIKSa8(CDfQ5YtWipsfSXm99MUAsOMb4QfgP9yqDwu0CvMcvERLAHkv(9Me(ud99ECnUjXvtExH1BOWLkdh5FhZdyJ03GLRRqWOzhbWG6SOO5QSo831AFVkCaBsOXQVeydEUk7DWRlKTwkQ3ATVxfoGnj0al83P5Gc9od4OhS4nixwsFkYcXGfairil22XIf)zrHukl)UxSq(0yzRucclEbYI6kKLLfl2UFNfITvYMEvG3Wd)blQXHibIKSbybaseM)DmtTU(EQMVrK2d2Rd0uWCaKQDYeaEFUUcnbybaseMbrAQkO1(aeQaH2ktWZxfmn6GPMN1xJHj45RcML1uTt0xJHbdQZIIz1Q820yIFfDtYppRVgddguNffZuOYBtJj(v0nj)uTtC63UkBbTHnHiFAANqTqLk)EtcFQH(EpUg3mIZZ6RXWe88vbZYA68S99QWbSjHgR(sGn45QS3bVUq2APOEpv7e7FxH1BOpQuENb7B8ZZ6RXWqFVhUszAmXVIsinmKxtsZq(O1RchWMeAcOcP)5Qm1667PZZ6RXWe88vbtJj(vucPVgdd99E4kLPXe)kkbiVw91yycE(QGzznv7e77vHdytcn6UYRaMHJSRu5F)ks05z91yy0DLxbmdhzxPY)(vKO5Y)vJg67bI2mIZZ6RXWO7kVcygoYUsL)9RirZEh8cn03deTzeNopRdPuTJJ0(NBmXVIsinstBacvGqBLj45RcMgt8ROBs(P8gKllPpfzb4QgxJSCflwEbIjxGfyXIxP(9RiXYV7plQdaszrdcMIbklEbYIcPuwSD)oljWgz59Me(uw8cKf)z53rwWcKf4GfNfGqL3Sqob1zrrw8NfniywOyGYcSzrHuklnM4xDfjwCklpKLc(SS7aUIelpKLghns3zbC1xrIfYyvEZc5euNff5n8WFWIACisGijlDvJRrnhsfuy(9Me(0i1qZ3iYjnoAKU76kCEwFnggmOolkMPqL3Mgt8ROekIAXG6SOO5QmfQ8wBJj(vucPbbR9DfwVHcxQmCK)DmpGnsFdwUUcbNQ99Me(M)sW8dZGhUPgeSMqTqLk)EtcFkbAmXVIQDcguNffnxL9k18CJj(vucrkaAsCcpL3GCzj9Pilax14AKLhYYUdazXzHKcQ7kwEillkYs6ffPMI3Wd)blQXHibIKS0vnUg18nIeG3NRRqZfHG5aSaV)GL2aeQaH2kZv0qVExxH5iC51VsYGiGlGMgDWuAXiCDwwiO5kAOxVRRWCeU86xjzqeWfqTUvoSJbI4nixwIIHOflllwa(EpCLIf)zXvkw(lbPSSkfsPSSOxrIfYivWBNYIxGSCplhLfxhUEwEilwnmWcSzrHpl)oYc1cdNRyXd)blwuxHSOJkOnw29cuHSOPA0t0VceBwGfl2XY7nj8P8gE4pyrnoejqKKL(EpCLsZ3is7FxH1BOpQuENb7B8gSCDfcQDI9u8Z6WArn)HTDrqMGTcZZyqDwu0Cv2RuZZuluPYV3KWNAOV3dxP2mIt1orFngg679WvktJJgP7UUc1oHAHkv(9Me(ud99E4kfHI48S99QWbSjHM)sqBWUYGn6j6xbI90553vy9gkCPYWr(3X8a2i9ny56keuR(AmmyqDwumtHkVnnM4xrjue1Ib1zrrZvzku5Tw91yyOV3dxPmnM4xrjeXvl1cvQ87nj8Pg679WvQnJKGNQDI99QWbSjHgvQG3onpui(xrktsDjwuCE(VeK4qCiyYVP(Amm037HRuMgt8ROeWUPAFVjHV5Vem)Wm4HBsEEdYLfcQ73zb4JkL3SOP6B8SSOilWILail22XILghns3DDfYI(6zH(NsXIn)EwgWMfYivWBNYIvddS4filGWA7NLffzrhhWgzHyAkQHfG)PuSSOil64a2iledwaGeHSqVkGS87(ZITtPyXQHbw8c(7yZcW37HRu8gE4pyrnoejqKKL(EpCLsZ3iY3vy9g6JkL3zW(gVblxxHGA1xJHH(EpCLY04Or6URRqTtSNIFwhwlQ5pSTlcYeSvyEgdQZIIMRYELAEMAHkv(9Me(ud99E4k1Me8uTtSVxfoGnj0Osf82P5HcX)kszsQlXIIZZ)LGehIdbt(nj4PAFVjHV5Vem)Wm4HBgrEdYLfcQ73zrt1ONOFfi2SSOilaFVhUsXYdzHieTyzzXYVJSOVgdw0tXIROqww0RiXcW37HRuSalwiplumalqklWMffsPS0yIF1vK4n8WFWIACisGijl99E4kLMVrK9QWbSjHM)sqBWUYGn6j6xbITwQfQu53Bs4tn037HRuBgze1oXE91yy(lbTb7kd2ONOFfi2MLLw91yyOV3dxPmnoAKU76kCEEcaVpxxHgWg9KSTtPYdxPYWXq7e91yyOV3dxPmnM4xrjueNNPwOsLFVjHp1qFVhUsTPDAFxH1BOpQuENb7B8gSCDfcQvFngg679WvktJj(vucr(PtNYBqUSqmxfwk)rkl22XFhBwCwa(EtxnjKLffzX2PuSe8ffzb479WvkwEildxPybogAMfVazzrrwa(EtxnjKLhYcriAXIMQrpr)kqSzH(EGiwwwgwIG0y5OS87ilngHRRrqw2kLGWYdzj40NfGV30vtcjaW37HRu8gE4pyrnoejqKKfG3NRRqnxEcgj99E4kv2gS(8WvQmCm0maxTWiD63UkBbTH9MrqArBIgAcf)SoSwuZFyBxeKTZkeT0m2nnAt0qt0xJH5Ve0gSRmyJEI(vGyBOVhikAPz0yQMmrFngg679WvktJj(v0OfrId1cvQ8UtFmA2)UcR3qFuP8od234ny56keCQMmjaHkqOTYqFVhUszAmXVIgTisCOwOsL3D6Jr7DfwVH(Os5DgSVXBWY1vi4unzI(AmmJvNkdhzuTk00yIFfnAKFQ2j6RXWqFVhUszwwZZbiubcTvg679WvktJj(v0P8gKllPpfzb47nD1KqwSD)olAQg9e9RaXMLhYcriAXYYILFhzrFngSy7(D46zrbPxrIfGV3dxPyzz9xcYIxGSSOilaFVPRMeYcSyHGjalPdU1OZc99aruww1FkwiywEVjHpL3Wd)blQXHibIKS03B6QjHA(grcW7Z1vObSrpjB7uQ8WvQmCm0cW7Z1vOH(EpCLkBdwFE4kvgogAThG3NRRqZrQGnMPV30vtcNNNOVgdJUR8kGz4i7kv(3VIenx(VA0qFpq0MrCEwFnggDx5vaZWr2vQ8VFfjA27GxOH(EGOnJ4uTuluPYV3KWNAOV3dxPiebRfG3NRRqd99E4kv2gS(8WvQmCm4nixwsFkYc1M3jSqHS87(Zsk4Ifs4ZsItywww)LGSONILf9ksSCploLfL)iloLfliLE6kKfyXIcPuw(DVyjISqFpqeLfyZsuel6ZITDSyjIeGf67bIOSGe26AK3Wd)blQXHibIKSoOB9hamtT5DIMdPckm)EtcFAKAO5BeP9)fi6ksAT3d)blJd6w)baZuBENKb9eNeAUkpuhP9FEge(gh0T(daMP28ojd6joj0qFpqeHIOwq4BCq36payMAZ7KmON4KqtJj(vucfrEdYLfcA4Or6olrbqynUgz5gSqSTs20RcSCuwA0btPzw(DSrw8gzrHukl)UxSqEwEVjHpLLRyHmwL3Sqob1zrrwSD)olaHpXtZSOqkLLF3lw0inwG)o22okYYvS4vkwiNG6SOilWMLLflpKfYZY7nj8PSOJdyJS4SqgRYBwiNG6SOOHfnfS2(zPXrJ0Dwax9vKyjk2vGncYc5KybTHDcwplRsHuklxXcqOYBwiNG6SOiVHh(dwuJdrcejztGWACnQ5qQGcZV3KWNgPgA(gr24Or6URRqTV3KW38xcMFyg8WnNmrdcMatOwOsLFVjHp1qFVhxJrZUOPVgddguNffZQv5TzznDkbAmXVIoL4mrdc8UcR382UkNaHf1GLRRqWPAN4w5WogiAEgG3NRRqZrQGnMPV30vtcNNThdQZIIMRYELAQ2jbiubcTvMGNVkyA0btPfdQZIIMRYELsR9G96anfmhaPANaW7Z1vOjalaqIWmistvH55aeQaH2ktawaGeH5FhZuRRVNAA0btnpBFacalVEtDK2)8WXPZZuluPYV3KWNAOV3JRrcnzcXxtMOVgddguNffZQv5Tzzfn7MonAt0GaVRW6nVTRYjqyrny56keC6uT2Jb1zrrdfQ8oxiHFT2hGqfi0wzcE(QGPrhm188emOolkAUktHkVNN1xJHbdQZIIz1Q82SS0A)7kSEdfUuz4i)7yEaBK(gSCDfcopRVgdJvFjWg8Cv27GxxiBTuuVnaC1c3ms7iFAt1oHAHkv(9Me(ud99ECnsinslAt0GaVRW6nVTRYjqyrny56keC6uTo9BxLTG2WEtYNMMOVgdd99E4kLPXe)kA0i(t1oX(aeawE9gIs1NxZZ2RVgddrxb2iygtSG2WobRpJf2KUOIML18mguNffnxLPqL3t1AV(AmmTdal4IMhnwrnvME1yPY7POp2NBww8gKllPpfzH4b3clWILail2UFhUEwcUL1vK4n8WFWIACisGij7a2bmdh5Y)vJA(gr6w5WogiAEgG3NRRqZrQGnMPV30vtc5n8WFWIACisGijlaVpxxHAU8emYayoalW7pyLDiQzaUAHrApyVoqtbZbqQ2ja8(CDfAcG5aSaV)GL2j6RXWqFVhUszwwZZVRW6n0hvkVZG9nEdwUUcbNNdqay51BQJ0(Nhoovli8njqynUgn)fi6ksANyV(AmmuOI(xanllT2RVgdtWZxfmllTtS)DfwVzS6uz4iJQvHgSCDfcopRVgdtWZxfmGR2)dwBgGqfi0wzgRovgoYOAvOPXe)kkbIGPANypf)SoSwuZFyBxeKTZkmpJb1zrrZvz1Q8EEgdQZIIgku5DUqc)t1cW7Z1vO537tPYuejc7Sn)ETtSpabGLxVPos7FE448CacvGqBLjalaqIW8VJzQ113tnnM4xrjK(AmmbpFvWaUA)pyfT0mKFQ23Bs4B(lbZpmdE4M6RXWe88vbd4Q9)Gv0sZqCNopRdPuTJJ0(NBmXVIsi91yycE(QGbC1(FWIaAyx06vHdytcnw9LaBWZvzVdEDHS1sr9EkVb5Ys6trwiEnwrnfl2UFNfITvYMEvG3Wd)blQXHibIKSTdal4IMhnwrnLMVrK6RXWe88vbtJj(v0n1G8ZZ6RXWe88vbd4Q9)Gfb0WUO1RchWMeAS6lb2GNRYEh86czRLI6nHSJ4RfG3NRRqtamhGf49hSYoe5nixwsFkYcX2kztVkWcSyjaYYQuiLYIxGSOUcz5EwwwSy7(DwigSaajc5n8WFWIACisGijBavi9pxLD1rQsW618nIeG3NRRqtamhGf49hSYoe1orFngMGNVkyaxT)hSiGg2fTEv4a2KqJvFjWg8Cv27GxxiBTuuV3ms7i(ZZ2hGaWYR3aaRFpvpDEwFngM2bGfCrZJgROMYSS0QVgdt7aWcUO5rJvutzAmXVIsinnbcWcCDVXQXWrXSRosvcwV5VemdWvlKatSxFnggDfecQw03SS0A)7kSEd99wbBqdwUUcbNYB4H)Gf14qKars2RcEx(FWsZ3isaEFUUcnbWCawG3FWk7qK3GCzj9PilKtIf0g2SKoybYcSyjaYIT73zb479WvkwwwS4filuhaYYa2SqqwkQ3S4fileBRKn9QaVHh(dwuJdrcejzXelOnSZ6WcuZ3iYjbiubcTvMGNVkyAmXVIsa91yycE(QGbC1(FWIa9QWbSjHgR(sGn45QS3bVUq2APOEhnnSBZaeQaH2kdMybTHDwhwGgWv7)blcOrAtNN1xJHj45RcMgt8ROBgbZZG96anfmhaP8gKlle0WrJ0DwgkVrwGflllwEilrKL3Bs4tzX297W1ZcX2kztVkWIoEfjwCD46z5HSGe26AKfVazPGplqayhClRRiXB4H)Gf14qKarsw6JkL35HYBuZHubfMFVjHpnsn08nISXrJ0DxxHA)lbZpmdE4MAqETuluPYV3KWNAOV3JRrcrWADRCyhdePDI(AmmbpFvW0yIFfDtnsBE2E91yycE(QGzznL3GCzj9Pilepi5WYny5k6bIS4flKtqDwuKfVazrDfYY9SSSyX297S4SqqwkQ3Sy1WalEbYYwbDR)aGSa0M3j8gE4pyrnoejqKKDS6uz4iJQvHA(grIb1zrrZvzVsPDIBLd7yGO5z77vHdytcnw9LaBWZvzVdEDHS1sr9EQ2j6RXWy1xcSbpxL9o41fYwlf1BdaxTqczh5tBEwFngMGNVkyAmXVIUzemv7eq4BCq36payMAZ7KmON4KqZFbIUI08S9biaS86nfgAOc2GZZuluPYV3KWNUPDt1orFngM2bGfCrZJgROMY0yIFfLqAAnzcbhTEv4a2Kqd9QXsL3trFSpFQw91yyAhawWfnpASIAkZYAE2E91yyAhawWfnpASIAkZYAQ2j2hGqfi0wzcE(QGzznpRVgdZV3NsLPise2g67bIiKgKx74iT)5gt8ROeYU0st74iT)5gt8ROBQrAPnpBpfUu6xbA(9(uQmfrIW2GLRRqWPANqHlL(vGMFVpLktrKiSny56keCEoaHkqOTYe88vbtJj(v0nJyAt1(EtcFZFjy(HzWd3K8ZZ6qkv74iT)5gt8ROesJ04nixwsFkYIZcW37HRuSefw4VZIvddSSkfsPSa89E4kflhLfx1OdMILLflWMLuWflEJS46W1ZYdzbca7GBXYwPeeEdp8hSOghIeisYsFVhUsP5BeP(AmmWc)DA2c7aA9hSmllTt0xJHH(EpCLY04Or6URRW5zN(TRYwqByVPMoTP8gKllAQvIflBLsqyrhhWgzHyWcaKiKfB3VZcW37HRuS4fil)owSa89MUAsiVHh(dwuJdrcejzPV3dxP08nImabGLxVPos7FE4Ow7FxH1BOpQuENb7B8gSCDfcQDcaVpxxHMaSaajcZGinvfMNdqOceARmbpFvWSSMN1xJHj45RcML1uTbiubcTvMaSaajcZ)oMPwxFp10yIFfLqKcGMeNWrlGNAIt)2vzlOnSjoKpTPA1xJHH(EpCLY0yIFfLqeSw7b71bAkyoas5n8WFWIACisGijl99MUAsOMVrKbiaS86n1rA)Zdh1obG3NRRqtawaGeHzqKMQcZZbiubcTvMGNVkywwZZ6RXWe88vbZYAQ2aeQaH2ktawaGeH5FhZuRRVNAAmXVIsiYRfG3NRRqd99E4kv2gS(8WvQmCm0Ib1zrrZvzVsP1EaEFUUcnhPc2yM(EtxnjuR9G96anfmhaP8gKllPpfzb47nD1KqwSD)olEXsuyH)olwnmWcSz5gSKcU2gKfiaSdUflBLsqyX297SKcUAwkKWplbN(gw2QIczbCLyXYwPeew8NLFhzblqwGdw(DKLOOy97PAw0xJbl3GfGV3dxPyXgCPaRTFwgUsXcCmyb2SKcUyXBKfyXIDS8EtcFkVHh(dwuJdrcejzPV30vtc18nIuFnggyH)onhuO3zah9GLzznppXE6794A04w5WogisR9a8(CDfAosfSXm99MUAs488e91yycE(QGPXe)kkHiVw91yycE(QGzznppzI(AmmbpFvW0yIFfLqKcGMeNWrlGNAIt)2vzlOnSjoa8(CDfAO0Cas)PA1xJHj45RcML18S(AmmTdal4IMhnwrnvME1yPY7POp2NBAmXVIsisbqtIt4OfWtnXPF7QSf0g2ehaEFUUcnuAoaP)uT6RXW0oaSGlAE0yf1uz6vJLkVNI(yFUzznvBacalVEdaS(9u90PANqTqLk)EtcFQH(EpCLIqrCEgG3NRRqd99E4kv2gS(8WvQmCmMovR9a8(CDfAosfSXm99MUAsO2j23RchWMeA(lbTb7kd2ONOFfi2ZZuluPYV3KWNAOV3dxPiueNYBqUSK(uKLOaiSOSCflaHkVzHCcQZIIS4filuhaYcXBPuSefaHfldyZcX2kztVkWB4H)Gf14qKars2cTLtGWsZ3iYj6RXWGb1zrXmfQ820yIFfDtKWyy9y(VeCEEsy3Bsins702yy3Bsy(VeKqKF68Cy3BsinYiovRBLd7yGiEdp8hSOghIeisYU7QrobclnFJiNOVgddguNffZuOYBtJj(v0nrcJH1J5)sW55jHDVjH0iTtBJHDVjH5)sqcr(PZZHDVjH0iJ4uTUvoSJbI0orFngM2bGfCrZJgROMY0yIFfLqKxR(AmmTdal4IMhnwrnLzzP1(Ev4a2Kqd9QXsL3trFSpFE2E91yyAhawWfnpASIAkZYAkVHh(dwuJdrcejzhlLkNaHLMVrKt0xJHbdQZIIzku5TPXe)k6MiHXW6X8FjO2jbiubcTvMGNVkyAmXVIUj5tBEoaHkqOTYeGfairy(3Xm1667PMgt8ROBs(0MoppjS7njKgPDABmS7njm)xcsiYpDEoS7njKgzeNQ1TYHDmqK2j6RXW0oaSGlAE0yf1uMgt8ROeI8A1xJHPDaybx08OXkQPmllT23RchWMeAOxnwQ8Ek6J95ZZ2RVgdt7aWcUO5rJvutzwwt5nixwsFkYcbfKCybwSqmnfVHh(dwuJdrcejzT5DFWodhzuTkK3GCzHyUkSu(JuwSTJ)o2S8qwwuKfGV3JRrwUIfGqL3SyB)c7SCuw8NfYZY7nj8PeqdwgWMfea2PyXU0ioSK40h7uSaBwiywa(EtxnjKfYjXcAd7eSEwOVhiIYB4H)Gf14qKarswaEFUUc1C5jyK037X1y(QmfQ8wZaC1cJKAHkv(9Me(ud99ECnUjbtGHcc7jjo9XovgGRwy00iT0io2L2ucmuqyprFngg67nD1KWmMybTHDcwFMcvEBOVhiI4qWt5nixwiMRclL)iLfB74VJnlpKfcQ2)Dwax9vKyH41yf1u8gE4pyrnoejqKKfG3NRRqnxEcgPT2)98v5rJvutPzaUAHrQbXHAHkvE3Ppsi70KjPzSlAtOwOsLFVjHp1qFVhxJAIgtJ2eniW7kSEdfUuz4i)7yEaBK(gSCDfcgnnmKF6ucKMrdYhn91yyAhawWfnpASIAktJj(vuEdYLL0NISqq1(VZYvSaeQ8MfYjOolkYcSz5gSuqwa(EpUgzX2PuSmUNLREileBRKn9QalELkb2iVHh(dwuJdrcejzT1(VR5Be5emOolkAuRY7CHe(NNXG6SOOXRu5cj8RfG3NRRqZrZbf6aWPAN8EtcFZFjy(HzWd3KGNNXG6SOOrTkVZxLTBEwhsPAhhP9p3yIFfLqAK205z91yyWG6SOyMcvEBAmXVIsip8hSm037X1ObjmgwpM)lb1QVgddguNffZuOYBZYAEgdQZIIMRYuOYBT2dW7Z1vOH(EpUgZxLPqL3ZZ6RXWe88vbtJj(vuc5H)GLH(EpUgniHXW6X8FjOw7b4956k0C0CqHoauR(AmmbpFvW0yIFfLqiHXW6X8FjOw91yycE(QGzznpRVgdt7aWcUO5rJvutzwwAb4956k0yR9FpFvE0yf1uZZ2dW7Z1vO5O5GcDaOw91yycE(QGPXe)k6MiHXW6X8FjiVb5Ys6trwa(EpUgz5gSCflKXQ8MfYjOolkQzwUIfGqL3Sqob1zrrwGflemby59Me(uwGnlpKfRggybiu5nlKtqDwuK3Wd)blQXHibIKS037X1iVb5YcXZvQFVx8gE4pyrnoejqKKTxv2d)bRS6OVMlpbJC4k1V3lEdEdYLfGV30vtczzaBwsGaWeSEwwLcPuww0RiXs6GBn68gE4pyrndxP(9Efj99MUAsOMVrK23RchWMeA0DLxbmdhzxPY)(vKOgmcxNLfcYBqUSqmN(S87ilGWNfB3VZYVJSKaPpl)LGS8qwCqqww1Fkw(DKLeNWSaUA)pyXYrzz)Edlax14AKLgt8ROSKSu)zPoeKLhYsI)HDwsGWACnYc4Q9)GfVHh(dwuZWvQFVxeisYsx14AuZHubfMFVjHpnsn08nIee(MeiSgxJMgt8ROB2yIFfnA2zhXrJiG3Wd)blQz4k1V3lcejztGWACnYBWBqUSK(uKLTc6w)bazbOnVtyX2owS87yJSCuwkilE4pailuBENOzwCklk)rwCklwqk90vilWIfQnVtyX297SyhlWMLbAdBwOVhiIYcSzbwS4SercWc1M3jSqHS87(ZYVJSuOnwO28oHfV7daszjkIf9zXhp2S87(Zc1M3jSGe26AKYB4H)Gf1q)iDq36payMAZ7enhsfuy(9Me(0i1qZ3is7bHVXbDR)aGzQnVtYGEItcn)fi6ksAT3d)blJd6w)baZuBENKb9eNeAUkpuhP9x7e7bHVXbDR)aGzQnVtY7ORm)fi6ksZZGW34GU1FaWm1M3j5D0vMgt8ROBs(PZZGW34GU1FaWm1M3jzqpXjHg67bIiue1ccFJd6w)baZuBENKb9eNeAAmXVIsOiQfe(gh0T(daMP28ojd6joj08xGORiXBqUSK(uKYcXGfairil3GfITvYMEvGLJYYYIfyZsk4IfVrwarAQkCfjwi2wjB6vbwSD)oledwaGeHS4filPGlw8gzrhvqBSqWPr2iM2eIHkK(NRybO113tNYYwPeewUIfNfnsJaSqXalKtqDwu0WYwvuilGWA7Nff(SOPA0t0VceBwqcBDnQzwCLnpfLLffz5kwi2wjB6vbwSD)oleKLI6nlEbYI)S87il037Nf4GfNL0b3A0zX2vGqBgEdp8hSOg6tGijBawaGeH5FhZuRRVNQ5BeP9G96anfmhaPANmbG3NRRqtawaGeHzqKMQcATpaHkqOTYe88vbtJoykT23RchWMeAS6lb2GNRYEh86czRLI698S(AmmbpFvWSSMQDYeN(TRYwqBytOib4956k0eGfairy2PwANOVgddguNffZQv5TPXe)k6MAK28S(AmmyqDwumtHkVnnM4xr3uJ0MopRVgdtWZxfmnM4xr3K8A1xJHj45RcMgt8ROeksnSBQ2j23RchWMeA(lbTb7kd2ONOFfi2ZZ23RchWMeAcOcP)5Qm1667PZZ6RXW8xcAd2vgSrpr)kqSnnM4xr3ejmgwpM)lbNop3RchWMeA0DLxbmdhzxPY)(vKOt1oX(Ev4a2KqJUR8kGz4i7kv(3VIeDEEI(Amm6UYRaMHJSRu5F)ks0C5)Qrd99arrgbZZ6RXWO7kVcygoYUsL)9RirZEh8cn03defzemD68SoKs1oos7FUXe)kkH0inT2hGqfi0wzcE(QGPrhm1uEdYLL0NISa89MUAsilpKfIq0ILLfl)oYIMQrpr)kqSzrFngSCdwUNfBWLcKfKWwxJSOJdyJSmU6O7xrILFhzPqc)SeC6ZcSz5HSaUsSyrhhWgzHyWcaKiK3Wd)blQH(eisYsFVPRMeQ5BezVkCaBsO5Ve0gSRmyJEI(vGyRDI9tMOVgdZFjOnyxzWg9e9RaX20yIFfDtp8hSm2A)3niHXW6X8FjibsZOH2jyqDwu0Cvwh(7ZZyqDwu0CvMcvEppJb1zrrJAvENlKW)05z91yy(lbTb7kd2ONOFfi2Mgt8ROB6H)GLH(EpUgniHXW6X8FjibsZOH2jyqDwu0CvwTkVNNXG6SOOHcvENlKW)8mguNffnELkxiH)PtNNTxFngM)sqBWUYGn6j6xbITzznDEEI(AmmbpFvWSSMNb4956k0eGfairygePPQWuTbiubcTvMaSaajcZ)oMPwxFp10OdMsBacalVEtDK2)8WrTt0xJHbdQZIIz1Q820yIFfDtnsBEwFnggmOolkMPqL3Mgt8ROBQrAtNQDI9biaS86neLQpVMNdqOceARmyIf0g2zDybAAmXVIUzemL3GCzrtTsSyb47nD1Kqkl2UFNL05kVcilWblBvPyj67xrIYcSz5HSy1OL3ildyZcXGfairil2UFNL0b3A05n8WFWIAOpbIKS03B6QjHA(gr2RchWMeA0DLxbmdhzxPY)(vKOANmrFnggDx5vaZWr2vQ8VFfjAU8F1OH(EGOnTBEwFnggDx5vaZWr2vQ8VFfjA27GxOH(EGOnTBQ2aeQaH2ktWZxfmnM4xr3K4Q1(aeQaH2ktawaGeH5FhZuRRVNAwwZZtcqay51BQJ0(NhoQnaHkqOTYeGfairy(3Xm1667PMgt8ROesJ00Ib1zrrZvzVsP1PF7QSf0g2BAxAeiIPfTaeQaH2ktWZxfmn6GPMoL3GCzHyWc8(dwSmGnlUsXci8PS87(ZsIteszHUAKLFhtXI3yT9ZsJJgP7iil22XIfcAoaSGlkleVgROMILDNYIcPuw(DVyH8SqXaLLgt8RUIelWMLFhzHCsSG2WML0blqw0xJblhLfxhUEwEildxPybogSaBw8kflKtqDwuKLJYIRdxplpKfKWwxJ8gE4pyrn0NarswaEFUUc1C5jyKGWp3yeUUgtW6PAgGRwyKt0xJHPDaybx08OXkQPmnM4xr3K8ZZ2RVgdt7aWcUO5rJvutzwwt1AV(AmmTdal4IMhnwrnvME1yPY7POp2NBwwANOVgddrxb2iygtSG2WobRpJf2KUOIMgt8ROeIua0K4eEQ2j6RXWGb1zrXmfQ820yIFfDtsbqtIt45z91yyWG6SOywTkVnnM4xr3Kua0K4eEEEI96RXWGb1zrXSAvEBwwZZ2RVgddguNffZuOYBZYAQw7FxH1BOqf9VaAWY1vi4uEdYLfIblW7pyXYV7plHDmqeLLBWsk4IfVrwGRNEGilyqDwuKLhYcSuPybe(S87yJSaBwosfSrw(9JYIT73zbiur)lG8gE4pyrn0NarswaEFUUc1C5jyKGWpdxp9aXmguNff1maxTWiNyV(AmmyqDwumtHkVnllT2RVgddguNffZQv5TzznvR9VRW6nuOI(xany56keuR99QWbSjHM)sqBWUYGn6j6xbInVb5YIMc(S4kflV3KWNYIT73VIfcIxGyYfyX297W1Zcea2b3Y6kse43rwCDiaKLaSaV)GfL3Wd)blQH(eisYMaH14AuZHubfMFVjHpnsn08nICI(AmmyqDwumtHkVnnM4xr3SXe)k68S(AmmyqDwumRwL3Mgt8ROB2yIFfDEgG3NRRqdi8ZW1tpqmJb1zrXPABC0iD31vO23Bs4B(lbZpmdE4MAyNw3kh2XarAb4956k0ac)CJr46AmbRNYB4H)Gf1qFcejzPRACnQ5qQGcZV3KWNgPgA(grorFnggmOolkMPqL3Mgt8ROB2yIFfDEwFnggmOolkMvRYBtJj(v0nBmXVIopdW7Z1vObe(z46PhiMXG6SO4uTnoAKU76ku77nj8n)LG5hMbpCtnStRBLd7yGiTa8(CDfAaHFUXiCDnMG1t5n8WFWIAOpbIKS0hvkVZdL3OMdPckm)EtcFAKAO5Be5e91yyWG6SOyMcvEBAmXVIUzJj(v05z91yyWG6SOywTkVnnM4xr3SXe)k68maVpxxHgq4NHRNEGygdQZIIt124Or6URRqTV3KW38xcMFyg8Wn1G4R1TYHDmqKwaEFUUcnGWp3yeUUgtW6P8gKllAk4ZsFK2Fw0XbSrwiEnwrnfl3GL7zXgCPazXvkOnwsbxS8qwAC0iDNffsPSaU6RiXcXRXkQPyzYVFuwGLkfl7ULfwuwSD)oC9Sa8QXsXcb9POp2NpL3Wd)blQH(eisYcW7Z1vOMlpbJSG59u0h7ZZO3Quzq4RzaUAHrgGaWYR3aaRFpvR1(Ev4a2Kqd9QXsL3trFSpxR99QWbSjHMW1bfMHJS6gy2lWmi6)U2aeQaH2kJo2uSj6ksMgDWuAdqOceARmTdal4IMhnwrnLPrhmLw71xJHj45RcMLL2jo9BxLTG2WEZiG4opRVgdJUccbvl6Bwwt5n8WFWIAOpbIKSjqynUg18nIeG3NRRqtbZ7POp2NNrVvPYGWxBJj(vuczxA8gE4pyrn0Narsw6QgxJA(grcW7Z1vOPG59u0h7ZZO3Quzq4RTXe)kkH0qtZBqUSK(uKfIhClSalwcGSy7(D46zj4wwxrI3Wd)blQH(eisYoGDaZWrU8F1OMVrKUvoSJbI4nixwsFkYc5KybTHnlPdwGSy7(Dw8kflkyrIfSGls7SOC6FfjwiNG6SOilEbYY3Py5HSOUcz5EwwwSy7(Dwiilf1Bw8cKfITvYMEvG3Wd)blQH(eisYIjwqByN1HfOMVrKtcqOceARmbpFvW0yIFfLa6RXWe88vbd4Q9)Gfb6vHdytcnw9LaBWZvzVdEDHS1sr9oAAy3MbiubcTvgmXcAd7SoSanGR2)dweqJ0MopRVgdtWZxfmnM4xr3mcMNb71bAkyoas5nixwaIpLfB7yXYwPeewO7WLcKfDKfWvIfcYYdzPGplqayhClwMOPqlSaPSalwiERoflWblKJAvilEbYYVJSqob1zrXP8gE4pyrn0NarswaEFUUc1C5jyKo1kdUsS0maxTWiD63UkBbTH9MA600Kj2ziF00xJHzS6uz4iJQvHg67bI0e7IgguNffnxLvRY7P8gKllPpfzHyBLSPxfyX297Sqmybases2Oyxb2iilaTU(EklEbYciS2(zbcaBB99ileKLI6nlWMfB7yXs6uqiOArFwSbxkqwqcBDnYIooGnYcX2kztVkWcsyRRrQHLOaNiKf6QrwEily9yZIZczSkVzHCcQZIISyBhlww0JuXs0TlcyXoRalEbYIRuSqmnfLfBNsXIogGjiln6GPyHcHflybxK2zbC1xrILFhzrFngS4filGWNYYUdazrhXIf6AmUWH1RsXsJJgP7iOH3Wd)blQH(eisYcW7Z1vOMlpbJmaMdWc8(dwz6RzaUAHrApyVoqtbZbqQ2ja8(CDfAcG5aSaV)GLw71xJHj45RcMLL2j2tXpRdRf18h22fbz7ScZZyqDwu0CvwTkVNNXG6SOOHcvENlKW)uTtMmbG3NRRqJtTYGReR55aeawE9M6iT)5HJZZtcqay51BikvFEPnaHkqOTYGjwqByN1HfOPrhm1055Ev4a2KqZFjOnyxzWg9e9RaXEQwq4BORACnAAmXVIUzeOfe(MeiSgxJMgt8ROBQP1obe(g6JkL35HYB00yIFfDtnsBE2(3vy9g6JkL35HYB0GLRRqWPAb4956k0879PuzkIeHD2MFV23Bs4B(lbZpmdE4M6RXWe88vbd4Q9)Gv0sZqCNN1xJHrxbHGQf9nllT6RXWORGqq1I(Mgt8ROesFngMGNVkyaxT)hSiWenSlA9QWbSjHgR(sGn45QS3bVUq2APOEpD688emcxNLfcAWeRun6QmSblVcO2aeQaH2kdMyLQrxLHny5vannM4xrjKgeFIlbMq(O1RchWMeAOxnwQ8Ek6J95tNov7e7dqay51BQJ0(NhooppjaHkqOTYeGfairy(3Xm1667PMgt8ROesFngMGNVkyaxT)hSio2P1(Ev4a2KqJUR8kGz4i7kv(3VIeDEoaHkqOTYeGfairy(3Xm1667PMgDWuAD63UkBbTHnHiFAtNN1HuQ2XrA)ZnM4xrjuacvGqBLjalaqIW8VJzQ113tnnM4xrNopRdPuTJJ0(NBmXVIsi91yycE(QGbC1(FWIaAyx06vHdytcnw9LaBWZvzVdEDHS1sr9EkVb5Ys6trwiEnwrnfl2UFNfITvYMEvGLvPqkLfIxJvutXIn4sbYIYPplkyrcBw(DVyHyBLSPxf0ml)owSSOil64a2iVHh(dwud9jqKKTDaybx08OXkQP08nIuFngMGNVkyAmXVIUPgKFEwFngMGNVkyaxT)hSiKDexc0RchWMeAS6lb2GNRYEh86czRLI6D00WoTa8(CDfAcG5aSaV)GvM(8gE4pyrn0Nars2aQq6FUk7QJuLG1R5BejaVpxxHMayoalW7pyLPV2j6RXWe88vbd4Q9)G1MrAhXLa9QWbSjHgR(sGn45QS3bVUq2APOEhnnSBE2(aeawE9gay97P6PZZ6RXW0oaSGlAE0yf1uMLLw91yyAhawWfnpASIAktJj(vucPPjqawGR7nwngokMD1rQsW6n)LGzaUAHeyI96RXWORGqq1I(MLLw7FxH1BOV3kydAWY1vi4uEdp8hSOg6tGij7vbVl)pyP5BejaVpxxHMayoalW7pyLPpVb5YsuuVpxxHSSOiilWIfx)u3FiLLF3FwS51ZYdzrhzH6aqqwgWMfITvYMEvGfkKLF3Fw(DmflEJ1ZInN(iilrrSOpl64a2il)oMWB4H)Gf1qFcejzb4956kuZLNGrsDayEa7CWZxf0maxTWidqOceARmbpFvW0yIFfDtnsBE2EaEFUUcnbybaseMbrAQkOnabGLxVPos7FE448myVoqtbZbqkVb5Ys6trklepi5WYny5kw8IfYjOolkYIxGS89HuwEilQRqwUNLLfl2UFNfcYsr9wZSqSTs20RcAMfYjXcAdBwshSazXlqw2kOB9haKfG28oH3Wd)blQH(eisYowDQmCKr1QqnFJiXG6SOO5QSxP0oXPF7QSf0g2estBNMOVgdZy1PYWrgvRcn03defnYppRVgdt7aWcUO5rJvutzwwt1orFnggR(sGn45QS3bVUq2APOEBa4Qfsi7i40MN1xJHj45RcMgt8ROBgbt1cW7Z1vOH6aW8a25GNVkODI9biaS86nfgAOc2GZZGW34GU1FaWm1M3jzqpXjHM)ceDfPPANyFacalVEdaS(9u98S(AmmTdal4IMhnwrnLPXe)kkH00AYecoA9QWbSjHg6vJLkVNI(yF(uT6RXW0oaSGlAE0yf1uML18S96RXW0oaSGlAE0yf1uML1uTtSpabGLxVHOu9518CacvGqBLbtSG2WoRdlqtJj(v0nTlTPAFVjHV5Vem)Wm4HBs(5zDiLQDCK2)CJj(vucPrA8gKllPpfzjkSWFNfGV3dxPyXQHbkl3GfGV3dxPy5O12plllEdp8hSOg6tGijl99E4kLMVrK6RXWal83PzlSdO1FWYSS0QVgdd99E4kLPXrJ0DxxH8gKlleZRaQyb47Tc2GSCdwUNLDNYIcPuw(DVyH8uwAmXV6ksAMLuWflEJS4plA60ialBLsqyXlqw(DKLWQBSEwiNG6SOil7oLfYtaklnM4xDfjEdp8hSOg6tGijBWRaQY6RXqZLNGrsFVvWguZ3is91yyOV3kydAAmXVIsiYRDI(AmmyqDwumtHkVnnM4xr3K8ZZ6RXWGb1zrXSAvEBAmXVIUj5NQ1PF7QSf0g2BQPtJ3GCzHyEfqfl)oYcbzPOEZI(Amy5gS87ilwnmWIn4sbwB)SOUczzzXIT73z53rwkKWpl)LGSqmybaseYsaMGuwGJblbqdlrF)OSSOlxPsXcSuPyz3TSWIYc4QVIel)oYs6iddVHh(dwud9jqKKn4vavz91yO5YtWiT6lb2GNRYEh86czRLI6TMVrKVRW6nxf8U8)GLblxxHGAT)DfwVPqB5eiSmy56keuBuCtMeX0sttC63UkBbTHnbi400ek(zDyTOM)W2UiiBNviAeCAtjotiyId1cvQ8UtFCQMeGqfi0wzcWcaKim)7yMAD99utJj(v0PekkUjtIyAPPjo9BxLTG2Wwt0xJHXQVeydEUk7DWRlKTwkQ3gaUAHeGGtttO4N1H1IA(dB7IGSDwHOrWPnL4mHGjouluPY7o9XPAsacvGqBLjalaqIW8VJzQ113tnnM4xrNQnaHkqOTYe88vbtJj(v0nJyAA1xJHXQVeydEUk7DWRlKTwkQ3gaUAHeYonstR(Ammw9LaBWZvzVdEDHS1sr92aWvlCZiMM2aeQaH2ktawaGeH5FhZuRRVNAAmXVIsiconTJJ0(NBmXVIUzacvGqBLjalaqIW8VJzQ113tnnM4xrjaXx7KEv4a2Kqtavi9pxLPwxFpDEgG3NRRqtawaGeHzqKMQct5nixwaIpLfB7yXcbzPOEZcDhUuGSOJSy1Wqabzb9wLILhYIoYIRRqwEillkYcXGfairilWILaeQaH2kwMqoukw)5kvkw0XambPS89cz5gSaUsSUIelBLsqyPG2yX2PuS4kf0glPGlwEilwypWWRsXcwp2SqqwkQ3S4fil)owSSOiledwaGeHt5n8WFWIAOpbIKSa8(CDfQ5YtWiTAyiBTuuVZO3QuAgGRwyKbiaS86n1rA)Zdh12RchWMeAS6lb2GNRYEh86czRLI6Tw91yyS6lb2GNRYEh86czRLI6TbGRwibC63UkBbTHnbI4MrgX0stlaVpxxHMaSaajcZGinvf0gGqfi0wzcWcaKim)7yMAD99utJj(vuc50VDv2cAdBItetlAKcGMeNWAThSxhOPG5aivlguNffnxL9kLwN(TRYwqByVjaVpxxHMaSaajcZo1sBacvGqBLj45RcMgt8ROBsEEdYLL0NISa89E4kfl2UFNfGpQuEZIMQVXZcSz5TlcyHGTcS4filfKfGV3kydQzwSTJflfKfGV3dxPy5OSSSyb2S8qwSAyGfcYsr9MfB7yXIRdbGSOPtJLTsjitGnl)oYc6TkfleKLI6nlwnmWcaVpxxHSCuw(EHtzb2S4Gw(FaqwO28oHLDNYseqakgOS0yIF1vKyb2SCuwUILH6iT)8gE4pyrn0Narsw679WvknFJiN8UcR3qFuP8od234ny56keCEMIFwhwlQ5pSTlcYeSvyQw7FxH1BOV3kydAWY1viOw91yyOV3dxPmnoAKU76kuR99QWbSjHM)sqBWUYGn6j6xbIT2j6RXWy1xcSbpxL9o41fYwlf1BdaxTWnJ0oYNMw71xJHj45RcMLL2ja8(CDfACQvgCLynpRVgddrxb2iygtSG2WobRpJf2KUOIML18maVpxxHgRggYwlf17m6Tk1055jbiaS86nfgAOc2GAFxH1BOpQuENb7B8gSCDfcQDci8noOB9hamtT5Dsg0tCsOPXe)k6MrW8Sh(dwgh0T(daMP28ojd6joj0CvEOos7)0Pt1ojaHkqOTYe88vbtJj(v0n1iT55aeQaH2ktawaGeH5FhZuRRVNAAmXVIUPgPnL3GCzrtTsSOSSvkbHfDCaBKfIblaqIqww0RiXYVJSqmybaseYsawG3FWILhYsyhdeXYnyHyWcaKiKLJYIh(LRuPyX1HRNLhYIoYsWPpVHh(dwud9jqKKL(EtxnjuZ3isaEFUUcnwnmKTwkQ3z0BvkEdYLL0NISefaHfLfB7yXsk4IfVrwCD46z5HK1BKLGBzDfjwc7EtcPS4filjoril0vJS87ykw8gz5kw8IfYjOolkYc9pLILbSzHG(OaYs8Ic4n8WFWIAOpbIKSfAlNaHLMVrKUvoSJbI0ojS7njKgPDABmS7njm)xcsiYpph29MesJmIt5n8WFWIAOpbIKS7UAKtGWsZ3is3kh2XarANe29MesJ0oTng29MeM)lbje5NNd7EtcPrgXPANOVgddguNffZQv5TPXe)k6MiHXW6X8Fj48S(AmmyqDwumtHkVnnM4xr3ejmgwpM)lbNYB4H)Gf1qFcejzhlLkNaHLMVrKUvoSJbI0ojS7njKgPDABmS7njm)xcsiYpph29MesJmIt1orFnggmOolkMvRYBtJj(v0nrcJH1J5)sW5z91yyWG6SOyMcvEBAmXVIUjsymSEm)xcoL3GCzj9PilaFVPRMeYsuyH)olwnmqzXlqwaxjwSSvkbHfB7yXcX2kztVkOzwiNelOnSzjDWcuZS87ilrrX63t1SOVgdwoklUoC9S8qwgUsXcCmyb2SKcU2gKLGBXYwPeeEdp8hSOg6tGijl99MUAsOMVrKyqDwu0Cv2RuANOVgddSWFNMdk07mGJEWYSSMN1xJHHORaBemJjwqByNG1NXcBsxurZYAEwFngMGNVkywwANyFacalVEdrP6ZR55aeQaH2kdMybTHDwhwGMgt8ROBs(5z91yycE(QGPXe)kkHifanjoHJ2qbH9eN(TRYwqBytCa4956k0qP5aK(tNQDI9biaS86naW63t1ZZ6RXW0oaSGlAE0yf1uMgt8ROeIua0K4eoAb8utM40VDv2cAdBcqWPfT3vy9MXQtLHJmQwfAWY1vi4uIdaVpxxHgknhG0FkbIy0ExH1Bk0wobcldwUUcb1AFVkCaBsOHE1yPY7POp2NRvFngM2bGfCrZJgROMYSSMN1xJHPDaybx08OXkQPY0RglvEpf9X(CZYAEEI(AmmTdal4IMhnwrnLPXe)kkH8WFWYqFVhxJgKWyy9y(Veul1cvQ8UtFKqPzi45z91yyAhawWfnpASIAktJj(vuc5H)GLXw7)UbjmgwpM)lbNNb4956k0CriyoalW7pyPnaHkqOTYCfn0R31vyocxE9RKmic4cOPrhmLwmcxNLfcAUIg6176kmhHlV(vsgebCbCQw91yyAhawWfnpASIAkZYAE2E91yyAhawWfnpASIAkZYsR9biubcTvM2bGfCrZJgROMY0OdMA68maVpxxHgNALbxjwZZ6qkv74iT)5gt8ROeIua0K4eoAb8utC63UkBbTHnXbG3NRRqdLMdq6pDkVb5Ys07uS8qwsCIqw(DKfDK(SahSa89wbBqw0tXc99arxrIL7zzzXseUUarQuSCflELIfYjOolkYI(6zHGSuuVz5O12plUoC9S8qw0rwSAyiGG8gE4pyrn0Narsw67nD1KqnFJiFxH1BOV3kydAWY1viOw77vHdytcn)LG2GDLbB0t0VceBTt0xJHH(ERGnOzznp70VDv2cAd7n10PnvR(Amm03BfSbn03derOiQDI(AmmyqDwumtHkVnlR5z91yyWG6SOywTkVnlRPA1xJHXQVeydEUk7DWRlKTwkQ3gaUAHeYoIBAANeGqfi0wzcE(QGPXe)k6MAK28S9a8(CDfAcWcaKimdI0uvqBacalVEtDK2)8WXP8gKllKd9Ve)rkl7qBSKSc7SSvkbHfVrwi5xHGSyHnlumalqdlrHLkflVteszXzHwUfDh(SmGnl)oYsy1nwpl07x(FWIfkKfBWLcS2(zrhzXdHv7pYYa2SO8Me2S8xcoApbP8gE4pyrn0NarswaEFUUc1C5jyKo1IGGnqmOzaUAHrIb1zrrZvz1Q8oAraXXd)bld99ECnAqcJH1J5)sqcypguNffnxLvRY7OnH4tG3vy9gkCPYWr(3X8a2i9ny56kemArCkXXd)blJT2)DdsymSEm)xcsG0mem5jouluPY7o9rcKMH8r7DfwVP8F1inR7kVcOblxxHG8gKllAQvIflaFVPRMeYYvS4flKtqDwuKfNYcfclwCklwqk90viloLffSiXItzjfCXITtPyblqwwwSy7(DwIG0ial22XIfSESVIel)oYsHe(zHCcQZIIAMfqyT9ZIcFwUNfRggyHGSuuV1mlGWA7NfiaST13JS4flrHf(7Sy1WalEbYIfeQyrhhWgzHyBLSPxfyXlqwiNelOnSzjDWcK3Wd)blQH(eisYsFVPRMeQ5BeP99QWbSjHM)sqBWUYGn6j6xbIT2j6RXWy1xcSbpxL9o41fYwlf1BdaxTqczhXnT5z91yyS6lb2GNRYEh86czRLI6TbGRwiHSJ8PP9DfwVH(Os5DgSVXBWY1vi4uTtWG6SOO5QmfQ8wRt)2vzlOnSjaaVpxxHgNArqWgigIM(AmmyqDwumtHkVnnM4xrjai8nJvNkdhzuTk08xGiAUXe)QOzNH8BgbPnpJb1zrrZvz1Q8wRt)2vzlOnSjaaVpxxHgNArqWgigIM(AmmyqDwumRwL3Mgt8ROeae(MXQtLHJmQwfA(lqen3yIFv0SZq(n10PnvR96RXWal83PzlSdO1FWYSS0A)7kSEd99wbBqdwUUcb1ojaHkqOTYe88vbtJj(v0njUZZu4sPFfO537tPYuejcBdwUUcb1QVgdZV3NsLPise2g67bIiueJOMmPxfoGnj0qVASu59u0h7ZJMDt1oos7FUXe)k6MAKwAAhhP9p3yIFfLq2LwAZZG96anfmhaPt1oX(aeawE9gIs1NxZZbiubcTvgmXcAd7SoSannM4xr30UP8gKllPpfzjkaclklxXIxPyHCcQZIIS4filuhaYcb9UAqaI3sPyjkaclwgWMfITvYMEvGfVazjk2vGncYc5KybTHDcwVHLTQOqwwuKLTefWIxGSq8IcyXFw(DKfSazboyH41yf1uS4filGWA7Nff(SOPA0t0VceBwgUsXcCm4n8WFWIAOpbIKSfAlNaHLMVrKUvoSJbI0cW7Z1vOH6aW8a25GNVkODI(AmmyqDwumRwL3Mgt8ROBIegdRhZ)LGZZ6RXWGb1zrXmfQ820yIFfDtKWyy9y(VeCkVHh(dwud9jqKKD3vJCcewA(gr6w5WogislaVpxxHgQdaZdyNdE(QG2j6RXWGb1zrXSAvEBAmXVIUjsymSEm)xcopRVgddguNffZuOYBtJj(v0nrcJH1J5)sWPANOVgdtWZxfmlR5z91yyS6lb2GNRYEh86czRLI6TbGRwiHI0onsBQ2j2hGaWYR3aaRFpvppRVgdt7aWcUO5rJvutzAmXVIsOjKxtSlA9QWbSjHg6vJLkVNI(yF(uT6RXW0oaSGlAE0yf1uML18S96RXW0oaSGlAE0yf1uML1uTtSVxfoGnj08xcAd2vgSrpr)kqSNNrcJH1J5)sqcPVgdZFjOnyxzWg9e9RaX20yIFfDE2E91yy(lbTb7kd2ONOFfi2ML1uEdp8hSOg6tGij7yPu5eiS08nI0TYHDmqKwaEFUUcnuhaMhWoh88vbTt0xJHbdQZIIz1Q820yIFfDtKWyy9y(VeCEwFnggmOolkMPqL3Mgt8ROBIegdRhZ)LGt1orFngMGNVkywwZZ6RXWy1xcSbpxL9o41fYwlf1BdaxTqcfPDAK2uTtSpabGLxVHOu9518S(AmmeDfyJGzmXcAd7eS(mwyt6IkAwwt1oX(aeawE9gay97P65z91yyAhawWfnpASIAktJj(vucrET6RXW0oaSGlAE0yf1uMLLw77vHdytcn0RglvEpf9X(85z71xJHPDaybx08OXkQPmlRPANyFVkCaBsO5Ve0gSRmyJEI(vGyppJegdRhZ)LGesFngM)sqBWUYGn6j6xbITPXe)k68S96RXW8xcAd2vgSrpr)kqSnlRP8gKllPpfzHGcsoSalwcG8gE4pyrn0NarswBE3hSZWrgvRc5nixwsFkYcW37X1ilpKfRggybiu5nlKtqDwuuZSqSTs20RcSS7uwuiLYYFjil)UxS4Sqq1(VZcsymSEKffoEwGnlWsLIfYyvEZc5euNffz5OSSSmSqqD)olr3UiGf7ScSG1JnlolaHkVzHCcQZIISCdwiilf1BwO)PuSS7uwuiLYYV7fl2PrASqFpqeLfVazHyBLSPxfyXlqwigSaajczz3bGSKaBKLF3lw0G4szHyAkwAmXV6ksgwsFkYIRdbGSyh5tJ4WYUtFKfWvFfjwiEnwrnflEbYID2zhXHLDN(il2UFhUEwiEnwrnfVHh(dwud9jqKKL(EpUg18nIedQZIIMRYQv5Tw71xJHPDaybx08OXkQPmlR5zmOolkAOqL35cj8pppbdQZIIgVsLlKW)8S(AmmbpFvW0yIFfLqE4pyzS1(VBqcJH1J5)sqT6RXWe88vbZYAQ2j2tXpRdRf18h22fbz7ScZZ9QWbSjHgR(sGn45QS3bVUq2APOERvFnggR(sGn45QS3bVUq2APOEBa4Qfsi70inTbiubcTvMGNVkyAmXVIUPgexTtSpabGLxVPos7FE448CacvGqBLjalaqIW8VJzQ113tnnM4xr3udI7uTtSV9aA(gQuZZbiubcTvgDSPyt0vKmnM4xr3udI70PZZyqDwu0Cv2RuANOVgdJnV7d2z4iJQvHML18m1cvQ8UtFKqPziyYRDI9biaS86naW63t1ZZ2RVgdt7aWcUO5rJvutzwwtNNdqay51BaG1VNQ1sTqLkV70hjuAgcEkVb5Ys6trwiOA)3zb(7yB7Oil22VWolhLLRybiu5nlKtqDwuuZSqSTs20RcSaBwEilwnmWczSkVzHCcQZII8gE4pyrn0NarswBT)78gKllepxP(9EXB4H)Gf1qFcejz7vL9WFWkRo6R5YtWihUs979k(J)4ya]] )
    

end