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


    spec:RegisterPack( "Balance", 20220307, [[dmvb5fqikv9iiv6squPnrk9jLsnkfXPuKwLqkVccmlsrDlsrSlk(fKsdtKYXifwgLkptiyAqqDnivTniQY3GG04ec5CcjyDcjAEqi3tiAFkf9pHeQAGcju5GkL0cfPYdHOmrsrYfHuXgHOQ(ievugjevuDsrQYkvk8sHekZesHBskszNkL4NKIunuiioQqcrlfIkYtb0ufs1vfPQ2QqcPVcrfglKI2Rq9xrnyIdt1IjvpwWKb6YiBwHpdjJwP60QSAHecVgImBsUTi2TKFdA4uYXfc1YL65qnDvDDLSDa(oLY4HqDErY6fsA(kQ9J6ynIJEmqq)P4TyxA2zxArineQrJikcOhHJOyGFklkgOLhqYrrXalpHIbMox5vGIbA5Puqhmo6XaXWvhOyG7)BHJs0IwDx5vG0e8LemOUFFPBoiAtNR8kqAcWlbzOnb0S)jQO4hNIIu3vEfiZJ4pgO(6uF6vX6Xab9NI3IDPzNDPfH0qOgnIOiGE7IcXa91Vd7yGaVeKfdC)abPkwpgiiHdXatNR8kqSOP61bYBOP5DyNfeQMzXU0SZoEdEdKT7fkchL8gAclBfeKazbiu5nlPJ8edVHMWcY29cfbYY7nk6Z3GLGJjmlpKLqQGIYV3OOhB4n0ewqorjqaeilRQOaHXENIfaEFUUIWSm5mKrZSy1eGm(9gVAuelAYMSy1ead(9gVAu0udVHMWYwbapqwSAk44)kuSGC0(VZYny5(TXS87el2AyHIf0jOolmz4n0ew00CKiwqgSaarIy53jwaAD99ywCwu3)kILeytSmueIpDfXYKBWsk4ILDhS2(zz)EwUNf8LSuVxeCHvPyX297SKon9TgDwqaliJue(pxXYwvhQkHQxZSC)2GSGr6SMA4n0ew00CKiwsG4NLThhQ9p3uIFfEBwWbQ8(GywCllvkwEil6qmMLXHA)XSalvkdVHMWs0BYFwIomHyboyjDkFNL0P8DwsNY3zXXS4SGTOW5kw((kKO3WBOjSOPBrf1Sm5mKrZSGC0(VRzwqoA)31mlaFVhxttzjXbjwsGnXst4tDu9S8qwiVvh1SeGj6(Rj4373WBOjSG8peZsuSRaBcKf0jXcAJ6eQEwc7uajwgWMfKPPyzHDuKjgO6Wpoo6XaHwurDC0J3IgXrpgivUUIaJtxmqp8hSIbAR9FpgiiHd9z9hSIbIqAk44Nf7yb5O9FNfVazXzb47nE1OiwGflaJol2UFNLTCO2Fwq(oXIxGSKo4wJolWMfGV3JRjwG)o12omfdm03t95XaNWcfuNfMmQv5DUie)SmpZcfuNfMmxLXqL3SmpZcfuNfMmxL1H)olZZSqb1zHjJxPYfH4NLPSOLfRMay0WyR9FNfTSyplwnbWyNXw7)E8hVf7IJEmqQCDfbgNUyGE4pyfde)EpUMIbg67P(8yGtyXEw6vrdyJIm6UYRaLHJSRu5F)kuydvUUIazzEMf7zjabqLxVPou7FE4elZZSyplylsPYV3OOhBWV3dxPyjsw0GL5zwSNL3vu9MY)vt4SUR8kqgQCDfbYYuw0YI9SGPpRdRf28h12frz7ScSmpZYewOG6SWKbdvENlcXplZZSqb1zHjZvz1Q8ML5zwOG6SWK5QSo83zzEMfkOolmz8kvUie)SmngO6kkhaJbI(4pElrio6XaPY1veyC6Ib6H)Gvmq87nE1OOyGH(EQppg4ew6vrdyJIm6UYRaLHJSRu5F)kuydvUUIazrllbiaQ86n1HA)ZdNyrllylsPYV3OOhBWV3dxPyjsw0GLPSOLf7zbtFwhwlS5pQTlIY2zfIbQUIYbWyGOp(J)yGG0WxQpo6XBrJ4Ohd0d)bRyGyOY7So5jXaPY1veyC6I)4TyxC0JbsLRRiW40fdm03t95Xa)lHybrSmHf7yjAS4H)GLXw7)Uj44p)xcXccyXd)bld(9ECnzco(Z)LqSmngi(7l8XBrJyGE4pyfdm4kv2d)bRS6WFmq1H)C5jumqOfvuh)XBjcXrpgivUUIaJtxmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdeBrkv(9gf9yd(9E4kflBYIgSOLLjSyplVRO6n43BfSbnu56kcKL5zwExr1BWpPuENb7B8gQCDfbYYuwMNzbBrkv(9gf9yd(9E4kflBYIDXabjCOpR)GvmqG0JzzRq0HfyXseqal2UFhUEwa7B8S4fil2UFNfGV3kydYIxGSyhcyb(7uB7WumqaENlpHIbE4SdP4pEliCC0JbsLRRiW40fdeAfdetFmqp8hSIbcW7Z1vumqaUArXaXwKsLFVrrp2GFVhxtSSjlAedeKWH(S(dwXabspMLGICael22PIfGV3JRjwcEXY(9Syhcy59gf9ywSTFHDwomlnPiaE9SmGnl)oXc6euNfMy5HSOtSy10G6MazXlqwSTFHDwgNsrnlpKLGJ)yGa8oxEcfd8W5GICau8hVf0hh9yGu56kcmoDXaHwXaX0hd0d)bRyGa8(CDffdeGRwumqRMaKrfanAysGWACnXY8mlwnbiJkaA0WGx14AIL5zwSAcqgva0OHb)EJxnkIL5zwSAcqgva0OHb)EpCLIL5zwSAcqgva0OHzS6uz4itQvrSmpZIvtamTdGk4cNhnvrnflZZSOVgdtWZxfmnL4xHzjsw0xJHj45RcgWv7)blwMNzbG3NRRiZHZoKIbcs4qFw)bRyGrr9(CDfXYV7plHDkGeMLBWsk4IfVjwUIfNfubqwEiloa4bYYVtSGVF5)blwSTtnXIZY3xHe9SqFGLdZYctGSCfl60BJOILGJFCmqaENlpHIbEvgvam(J3cYlo6XaPY1veyC6Ib6H)GvmqDQXuJ0vOIbcs4qFw)bRyGPpMyjDuJPgPRqXI)S87elubYcCWcYVPkQPyX2ovSS74Ny5WS46qaeliV0qUAMfF8uZcYGfaisel2UFNL0b9OZIxGSa)DQTDyIfB3VZcY2kAtVkedm03t95XaNWYewSNLaeavE9M6qT)5HtSmpZI9SeGqfi0wzcWcaejk)7ugBD99yZYIL5zwSNLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMYIww0xJHj45RcMMs8RWSSjlAGEw0YI(AmmTdGk4cNhnvrnLPPe)kmliIfeMfTSyplbiaQ86naO63t1SmpZsacGkVEdaQ(9unlAzrFngMGNVkywwSOLf91yyAhavWfopAQIAkZYIfTSmHf91yyAhavWfopAQIAkttj(vywquKSOHDSOjSGWSenw6vrdyJIm4RglvEpf(P(CdvUUIazzEMf91yycE(QGPPe)kmliIfn0GL5zw0Gf0Yc2IuQ8UJFIfeXIggKhltzzklAzbG3NRRiZvzubW4pEli04OhdKkxxrGXPlgyOVN6ZJboHf91yycE(QGPPe)kmlBYIgONfTSmHf7zPxfnGnkYGVASu59u4N6Znu56kcKL5zw0xJHPDaubx48OPkQPmnL4xHzbrSOruGfTSOVgdt7aOcUW5rtvutzwwSmLL5zw0HymlAzzCO2)Ctj(vywqel2HEwMYIwwa4956kYCvgvamgiiHd9z9hSIbIqGpl2UFNfNfKTv0MEvGLF3FwoCT9ZIZcczPWEZIvddSaBwSTtfl)oXY4qT)SCywCD46z5HSqfymqp8hSIbAb)dwXF8wIO4OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbgOtXYewMWY4qT)5Ms8RWSOjSOb6zrtyjaHkqOTYe88vbttj(vywMYcAzrJiknwMYsKSeOtXYewMWY4qT)5Ms8RWSOjSOb6zrtyjaHkqOTYeGfaisu(3Pm2667XgWv7)blw0ewcqOceARmbybaIeL)DkJTU(ESPPe)kmltzbTSOreLgltzrll2Zs7hyMaq1BCqqSHq8HFmlAzzcl2ZsacvGqBLj45RcMMCWuSmpZI9SeGqfi0wzcWcaejY0KdMILPSmpZsacvGqBLj45RcMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzzEMLEv0a2OitGue(pxLXwxFp2qLRRiqw0YsacvGqBLj45RcMMs8RWSSjlrinwMNzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzrtyrJ0yzEMf7zjabqLxVPou7FE4umqqch6Z6pyfdezUkSu(tywSTt)o1SSWxHIfKblaqKiwkOnwSDkflUsbTXsk4ILhYc(pLILGJFw(DIfSNqS4jWv9SahSGmybaIeHaKTv0MEvGLGJFCmqaENlpHIbgGfaisugKWPQq8hVLOqC0JbsLRRiW40fdeAfdetFmqp8hSIbcW7Z1vumqaUArXaNWY7nk6n)Lq5hMbpILnzrd0ZY8mlTFGzcavVXbbXMRyztwqFASmLfTSmHLjSqr86SSiqdLyLQjxLHny5vGyrlltyXEwcqau51Baq1VNQzzEMLaeQaH2kdLyLQjxLHny5vGmnL4xHzbrSObYdHYccyzclONLOXsVkAaBuKbF1yPY7PWp1NBOY1veiltzzklAzXEwcqOceARmuIvQMCvg2GLxbY0KdMILPSmpZcfXRZYIany4sPO)VcvUx6PyrlltyXEwcqau51BQd1(NhoXY8mlbiubcTvgmCPu0)xHk3l9u5iGWOpIstdttj(vywqelAObcZYuwMNzzclbiubcTvgDQXuJ0vOmn5GPyzEMf7zP9az(gQuSmpZsacGkVEtDO2)8WjwMYIwwMWI9S8UIQ3mwDQmCKj1QidvUUIazzEMLaeavE9gau97PAw0YsacvGqBLzS6uz4itQvrMMs8RWSGiw0qdwqalONLOXsVkAaBuKbF1yPY7PWp1NBOY1veilZZSyplbiaQ86naO63t1SOLLaeQaH2kZy1PYWrMuRImnL4xHzbrSOVgdtWZxfmGR2)dwSGaw0WowIgl9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilAclAyhltzrlltyHI41zzrGMRWHE9UUIYr8YRFLKbjaxGyrllbiubcTvMRWHE9UUIYr8YRFLKbjaxGmnL4xHzbrSGEwMYY8mltyzclueVollc0G3DqOncmdB9mCKFyNq1ZIwwcqOceARmpStO6jW8v4d1(NJa6rFeStdttj(vywMYY8mltyzcla8(CDfzGvEHP83xHe9SejlAWY8mla8(CDfzGvEHP83xHe9SejlrGLPSOLLjS89virV51W0KdMkhGqfi0wXY8mlFFfs0BEnmbiubcTvMMs8RWSSjlx9uBbv(tG5XHA)ZnL4xHzrtyrJ0yzklZZSaW7Z1vKbw5fMYFFfs0ZsKSyhlAzzclFFfs0BE7mn5GPYbiubcTvSmpZY3xHe9M3otacvGqBLPPe)kmlBYYvp1wqL)eyECO2)Ctj(vyw0ew0inwMYY8mla8(CDfzGvEHP83xHe9SejlPXYuwMYY0yGGeo0N1FWkgy6JjqwEilGKYtXYVtSSWokIf4GfKTv0MEvGfB7uXYcFfkwaHlDfXcSyzHjw8cKfRMaq1ZYc7OiwSTtflEXIdcYcbGQNLdZIRdxplpKfWJIbcW7C5jumWayoalW7pyf)XBrJ0IJEmqQCDfbgNUyGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgO9SGHlL(vGMFVpLkJjcjQnu56kcKL5zwghQ9p3uIFfMLnzXU0sJL5zw0HymlAzzCO2)Ctj(vywqel2HEwqaltybHtJfnHf91yy(9(uQmMiKO2GFpGelrJf7yzklZZSOVgdZV3NsLXeHe1g87bKyztwIqeXIMWYew6vrdyJIm4RglvEpf(P(CdvUUIazjASyhltJbcs4qFw)bRyGrr9(CDfXYctGS8qwajLNIfVsXY3xHe9yw8cKLaiMfB7uXIn)(RqXYa2S4flOZYAh2NZIvddXab4DU8ekg4V3NsLXeHe1zB(9XF8w0qJ4OhdKkxxrGXPlgiiHd9z9hSIbM(yIf0jXkvtUIfn9gS8kqSyxAykGzrNgWMyXzbzBfTPxfyzHjwGnlyil)U)SCpl2oLIf1velllwSD)ol)oXcvGSahSG8BQIAQyGLNqXaPeRun5QmSblVcumWqFp1NhdmaHkqOTYe88vbttj(vywqel2LglAzjaHkqOTYeGfaisu(3Pm2667XMMs8RWSGiwSlnw0YYewa4956kY879PuzmrirD2MFplZZSOVgdZV3NsLXeHe1g87bKyztwIqASGawMWsVkAaBuKbF1yPY7PWp1NBOY1veilrJLiWYuwMYIwwa4956kYCvgvaKL5zw0HymlAzzCO2)Ctj(vywqelraHgd0d)bRyGuIvQMCvg2GLxbk(J3Ig2fh9yGu56kcmoDXabjCOpR)GvmW0htSaeUuk6VcfliNw6Pyb5HPaMfDAaBIfNfKTv0MEvGLfMyb2SGHS87(ZY9Sy7ukwuxrSSSyX297S87elubYcCWcYVPkQPIbwEcfdedxkf9)vOY9spvmWqFp1NhdCclbiubcTvMGNVkyAkXVcZcIyb5XIwwSNLaeavE9gau97PAw0YI9SeGaOYR3uhQ9ppCIL5zwcqau51BQd1(NhoXIwwcqOceARmbybaIeL)DkJTU(ESPPe)kmliIfKhlAzzcla8(CDfzcWcaejkds4uvGL5zwcqOceARmbpFvW0uIFfMfeXcYJLPSmpZsacGkVEdaQ(9unlAzzcl2ZsVkAaBuKbF1yPY7PWp1NBOY1veilAzjaHkqOTYe88vbttj(vywqelipwMNzrFngM2bqfCHZJMQOMY0uIFfMfeXIgPXccyzclONLOXcfXRZYIanxH)EfEyJZGhGROSoPuSmLfTSOVgdt7aOcUW5rtvutzwwSmLL5zw0HymlAzzCO2)Ctj(vywqel2HEwMNzHI41zzrGgkXkvtUkdBWYRaXIwwcqOceARmuIvQMCvg2GLxbY0uIFfMLnzXU0yzklAzbG3NRRiZvzubqw0YI9Sqr86SSiqZv4qVExxr5iE51VsYGeGlqSmpZsacvGqBL5kCOxVRROCeV86xjzqcWfittj(vyw2Kf7sJL5zw0HymlAzzCO2)Ctj(vywqel2Lwmqp8hSIbIHlLI()ku5EPNk(J3Igrio6XaPY1veyC6IbcTIbIPpgOh(dwXab4956kkgiaxTOyG6RXWe88vbttj(vyw2KfnqplAzzcl2ZsVkAaBuKbF1yPY7PWp1NBOY1veilZZSOVgdt7aOcUW5rtvutzAkXVcZcIIKfnqVb9SGawMWsemONLOXI(Amm6kieuTWVzzXYuwqaltybHnONfnHLiyqplrJf91yy0vqiOAHFZYILPSenwOiEDwweO5k83RWdBCg8aCfL1jLIfeWccBqplrJLjSqr86SSiqZVt5X14pJpuNIfTSeGqfi0wz(DkpUg)z8H6u5iG8qO2HWAyAkXVcZcIIKf7sJLPSOLf91yyAhavWfopAQIAkZYILPSmpZIoeJzrllJd1(NBkXVcZcIyXo0ZY8mlueVollc0qjwPAYvzydwEfiw0YsacvGqBLHsSs1KRYWgS8kqMMs8RWXabjCOpR)GvmWTQS5PWSSWelPxuKAkwSD)oliBROn9QalWMf)z53jwOcKf4GfKFtvutfdeG35YtOyGxedMdWc8(dwXF8w0aHJJEmqQCDfbgNUyGE4pyfd8kCOxVRROCeV86xjzqcWfOyGH(EQppgiaVpxxrMlIbZbybE)blw0YcaVpxxrMRYOcGXalpHIbEfo0R31vuoIxE9RKmib4cu8hVfnqFC0JbsLRRiW40fdeKWH(S(dwXatFmXcWDheAJazrtV1zrNgWMybzBfTPxfIbwEcfdeV7GqBeyg26z4i)WoHQpgyOVN6ZJboHLaeQaH2ktWZxfmn5GPyrll2ZsacGkVEtDO2)8Wjw0YcaVpxxrMFVpLkJjcjQZ287zrlltyjaHkqOTYOtnMAKUcLPjhmflZZSyplThiZ3qLILPSmpZsacGkVEtDO2)8Wjw0YsacvGqBLjalaqKO8VtzS113Jnn5GPyrlltybG3NRRitawaGirzqcNQcSmpZsacvGqBLj45RcMMCWuSmLLPSOLfq4BWRACnz(lG0vOyrlltybe(g8tkL35HYBY8xaPRqXY8ml2ZY7kQEd(jLY78q5nzOY1veilZZSGTiLk)EJIESb)EpUMyztwIaltzrllGW3KaH14AY8xaPRqXIwwMWcaVpxxrMdNDiXY8ml9QObSrrgDx5vGYWr2vQ8VFfkSHkxxrGSmpZIJ)2vzlOnQzzZizjkKglZZSaW7Z1vKjalaqKOmiHtvbwMNzrFnggDfecQw43SSyzklAzXEwOiEDwweO5kCOxVRROCeV86xjzqcWfiwMNzHI41zzrGMRWHE9UUIYr8YRFLKbjaxGyrllbiubcTvMRWHE9UUIYr8YRFLKbjaxGmnL4xHzztwIqASOLf7zrFngMGNVkywwSmpZIoeJzrllJd1(NBkXVcZcIybHtlgOh(dwXaX7oi0gbMHTEgoYpStO6J)4TObYlo6XaPY1veyC6Ibcs4qFw)bRyGrF)WSCywCwA)3PMfs56W2FIfBEkwEiljoselUsXcSyzHjwWV)S89virpMLhYIoXI6kcKLLfl2UFNfKTv0MEvGfVazbzWcaejIfVazzHjw(DIf7kqwWk4ZcSyjaYYnyrh(7S89virpMfVjwGfllmXc(9NLVVcj6XXad99uFEmWjSaW7Z1vKbw5fMYFFfs0ZI9rYIgSOLf7z57RqIEZBNPjhmvoaHkqOTIL5zwMWcaVpxxrgyLxyk)9virplrYIgSmpZcaVpxxrgyLxyk)9virplrYseyzklAzzcl6RXWe88vbZYIfTSmHf7zjabqLxVbav)EQML5zw0xJHPDaubx48OPkQPmnL4xHzbbSmHLiyqplrJLEv0a2Oid(QXsL3tHFQp3qLRRiqwMYcIIKLVVcj6nVgg91yKbxT)hSyrll6RXW0oaQGlCE0uf1uMLflZZSOVgdt7aOcUW5rtvutLXxnwQ8Ek8t95MLfltzzEMLaeQaH2ktWZxfmnL4xHzbbSyhlBYY3xHe9MxdtacvGqBLbC1(FWIfTSypl6RXWe88vbZYIfTSmHf7zjabqLxVPou7FE4elZZSypla8(CDfzcWcaejkds4uvGLPSOLf7zjabqLxVbPu95flZZSeGaOYR3uhQ9ppCIfTSaW7Z1vKjalaqKOmiHtvbw0YsacvGqBLjalaqKO8VtzS113Jnllw0YI9SeGqfi0wzcE(QGzzXIwwMWYew0xJHHcQZctz1Q820uIFfMLnzrJ0yzEMf91yyOG6SWugdvEBAkXVcZYMSOrASmLfTSypl9QObSrrgDx5vGYWr2vQ8VFfkSHkxxrGSmpZYew0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqILizb9SmpZI(Amm6UYRaLHJSRu5F)ku4S3bVid(9asSejlreltzzklZZSOVgddsxb2eyMsSG2OoHQptf1OUOsMLfltzzEMfDigZIwwghQ9p3uIFfMfeXIDPXY8mla8(CDfzGvEHP83xHe9SejlPXYuw0YcaVpxxrMRYOcGXaXk4JJb(9virVgXa9WFWkg43xHe9Ae)XBrdeAC0JbsLRRiW40fd0d)bRyGFFfs0BxmWqFp1NhdCcla8(CDfzGvEHP83xHe9SyFKSyhlAzXEw((kKO38AyAYbtLdqOceARyzEMfaEFUUImWkVWu(7RqIEwIKf7yrlltyrFngMGNVkywwSOLLjSyplbiaQ86naO63t1SmpZI(AmmTdGk4cNhnvrnLPPe)kmliGLjSebd6zjAS0RIgWgfzWxnwQ8Ek8t95gQCDfbYYuwquKS89virV5TZOVgJm4Q9)GflAzrFngM2bqfCHZJMQOMYSSyzEMf91yyAhavWfopAQIAQm(QXsL3tHFQp3SSyzklZZSeGqfi0wzcE(QGPPe)kmliGf7yztw((kKO382zcqOceARmGR2)dwSOLf7zrFngMGNVkywwSOLLjSyplbiaQ86n1HA)ZdNyzEMf7zbG3NRRitawaGirzqcNQcSmLfTSyplbiaQ86niLQpVyrlltyXEw0xJHj45RcMLflZZSyplbiaQ86naO63t1SmLL5zwcqau51BQd1(NhoXIwwa4956kYeGfaisugKWPQalAzjaHkqOTYeGfaisu(3Pm2667XMLflAzXEwcqOceARmbpFvWSSyrlltyzcl6RXWqb1zHPSAvEBAkXVcZYMSOrASmpZI(AmmuqDwykJHkVnnL4xHzztw0inwMYIwwSNLEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqwMNzzcl6RXWO7kVcugoYUsL)9RqHZL)RMm43diXsKSGEwMNzrFnggDx5vGYWr2vQ8VFfkC27GxKb)EajwIKLiILPSmLLPSmpZI(AmmiDfytGzkXcAJ6eQ(mvuJ6IkzwwSmpZIoeJzrllJd1(NBkXVcZcIyXU0yzEMfaEFUUImWkVWu(7RqIEwIKL0yzklAzbG3NRRiZvzubWyGyf8XXa)(kKO3U4pElAerXrpgivUUIaJtxmqqch6Z6pyfdm9XeMfxPyb(7uZcSyzHjwUNsWSalwcGXa9WFWkg4ct57PeC8hVfnIcXrpgivUUIaJtxmqqch6Z6pyfdeDUFNAwqbz5QhYYVtSGFwGnloKyXd)blwuh(Jb6H)GvmWEvzp8hSYQd)XaXFFHpElAedm03t95Xab4956kYC4SdPyGQd)5YtOyGoKI)4TyxAXrpgivUUIaJtxmqp8hSIb2Rk7H)GvwD4pgO6WFU8ekgi(J)4pgOvtbyIU)XrpElAeh9yGE4pyfdePRaBcmJTU(ECmqQCDfbgNU4pEl2fh9yGu56kcmoDXaHwXaX0hd0d)bRyGa8(CDffdeGRwumW0Ibcs4qFw)bRyGrFNybG3NRRiwomly6z5HSKgl2UFNLcYc(9NfyXYctS89virpwZSObl22PILFNyzCn(zbwelhMfyXYctAMf7y5gS87elykalqwomlEbYsey5gSOd)Dw8MIbcW7C5jumqyLxyk)9virF8hVLieh9yGu56kcmoDXaHwXaDqWyGE4pyfdeG3NRROyGaC1IIbQrmWqFp1Nhd87RqIEZRHz3X5fMY6RXGfTS89virV51WeGqfi0wzaxT)hSyrll2ZY3xHe9MxdZHnpmHYWrobw4VHlCoal83RWFWchdeG35YtOyGWkVWu(7RqI(4pEliCC0JbsLRRiW40fdeAfd0bbJb6H)GvmqaEFUUIIbcWvlkgODXad99uFEmWVVcj6nVDMDhNxykRVgdw0YY3xHe9M3otacvGqBLbC1(FWIfTSyplFFfs0BE7mh28Wekdh5eyH)gUW5aSWFVc)blCmqaENlpHIbcR8ct5VVcj6J)4TG(4OhdKkxxrGXPlgi0kgOdcgd0d)bRyGa8(CDffdeG35YtOyGWkVWu(7RqI(yGH(EQppgifXRZYIanxHd96DDfLJ4Lx)kjdsaUaXY8mlueVollc0qjwPAYvzydwEfiwMNzHI41zzrGgmCPu0)xHk3l9uXabjCOpR)GvmWOVtyILVVcj6XS4nXsbFw81dt8)cUsLIfq6PWtGS4ywGfllmXc(9NLVVcj6Xgwybi9SaW7Z1velpKfeMfhZYVtPyXvyilfrGSGTOW5kw29cuDfktmqaUArXar44pEliV4OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbgH0yjASmHfnyrtyjnJDSenwW0N1H1cB(JA7IOmcBfyzAmqqch6Z6pyfdei9yw(DIfGV34vJIyjaXpldyZIYFQzj4QWs5)blmltgWMfcXEILIyX2ovS8qwWV3plGReRRqXIonGnXcYVPkQPyz4kfMf4ymngiaVZLNqXaX4CaI)4pEli04OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbgH0ybbSOrASenw6vrdyJImbsr4)CvgBD99ydvUUIaJbcs4qFw)bRyGaPhZI)SyB)c7S4jWv9SahSSvmcHfKblaqKiwW7WLcKfDILfMaJswq40yX297W1ZcYifH)ZvSa0667XS4filrinwSD)UjgiaVZLNqXadWcaejk7yR4pElruC0Jb6H)GvmWeiSq6Q8a2jXaPY1veyC6I)4TefIJEmqQCDfbgNUyGE4pyfd0w7)EmWqFp1NhdCcluqDwyYOwL35Iq8ZY8mluqDwyYCvgdvEZY8mluqDwyYCvwh(7SmpZcfuNfMmELkxeIFwMgduDfLdGXa1iT4p(Jb6qko6XBrJ4OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIb2RIgWgfz(lHSb7kd2KNOFfi1gQCDfbYIwwMWI(Amm)Lq2GDLbBYt0VcKAttj(vywqelOcGMehXSGawsZOblZZSOVgdZFjKnyxzWM8e9RaP20uIFfMfeXIh(dwg8794AYqiMcRNY)LqSGawsZOblAzzcluqDwyYCvwTkVzzEMfkOolmzWqL35Iq8ZY8mluqDwyY4vQCri(zzkltzrll6RXW8xczd2vgSjpr)kqQnlRyGGeo0N1FWkgiYCvyP8NWSyBN(DQz53jw0un5jb)d7uZI(AmyX2PuSmCLIf4yWIT73VILFNyPie)SeC8hdeG35YtOyGGn5jzBNsLhUsLHJr8hVf7IJEmqQCDfbgNUyGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgO9Sqb1zHjZvzmu5nlAzbBrkv(9gf9yd(9ECnXYMSGqzrty5DfvVbdxQmCK)DkpGnHFdvUUIazjASyhliGfkOolmzUkRd)Dw0YI9S0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSOLf7zPxfnGnkYal63X5GI8od4WhSmu56kcmgiiHd9z9hSIbImxfwk)jml22PFNAwa(EJxnkILdZIny)7SeC8FfkwGaOMfGV3JRjwUIf0yvEZc6euNfMIbcW7C5jumWdvbBkJFVXRgff)XBjcXrpgivUUIaJtxmqp8hSIbgGfaisu(3Pm2667XXabjCOpR)GvmW0htSGmybaIeXITDQyXFwuegZYV7flOpnw2kgHWIxGSOUIyzzXIT73zbzBfTPxfIbg67P(8yG2ZcyVoqtbZbqmlAzzcltybG3NRRitawaGirzqcNQcSOLf7zjaHkqOTYe88vbttoykwMNzrFngMGNVkywwSmLfTSmHf91yyOG6SWuwTkVnnL4xHzztwqplZZSOVgddfuNfMYyOYBttj(vyw2Kf0ZYuw0YYewC83UkBbTrnliIf0NglAzzclylsPYV3OOhBWV3JRjw2KLiWY8ml6RXWe88vbZYILPSmpZI9S0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSmLfTSmHf7z5DfvVb)Ks5DgSVXBOY1veilZZSOVgdd(9E4kLPPe)kmliIfnmONfnHL0mONLOXsVkAaBuKjqkc)NRYyRRVhBOY1veilZZSOVgdtWZxfmnL4xHzbrSOVgdd(9E4kLPPe)kmliGf0ZIww0xJHj45RcMLfltzrlltyXEw6vrdyJIm6UYRaLHJSRu5F)kuydvUUIazzEMf91yy0DLxbkdhzxPY)(vOW5Y)vtg87bKyztwIalZZSOVgdJUR8kqz4i7kv(3Vcfo7DWlYGFpGelBYseyzklZZSOdXyw0YY4qT)5Ms8RWSGiw0inw0YsacvGqBLj45RcMMs8RWSSjlONLPXF8wq44OhdKkxxrGXPlgOh(dwXaXRACnfdmKkOO87nk6XXBrJyGH(EQppg4ewAA0eE31velZZSOVgddfuNfMYyOYBttj(vywqelrGfTSqb1zHjZvzmu5nlAzPPe)kmliIfnqyw0YY7kQEdgUuz4i)7uEaBc)gQCDfbYYuw0YY7nk6n)Lq5hMbpILnzrdeMfnHfSfPu53Bu0JzbbS0uIFfMfTSmHfkOolmzUk7vkwMNzPPe)kmliIfubqtIJywMgdeKWH(S(dwXatFmXcWvnUMy5kwS8cKsUalWIfVs97xHILF3FwuhacZIgimMcyw8cKffHXSy7(DwsGnXY7nk6XS4fil(ZYVtSqfilWblolaHkVzbDcQZctS4plAGWSGPaMfyZIIWywAkXV6kuS4ywEilf8zz3bCfkwEilnnAcVZc4QVcflOXQ8Mf0jOolmf)XBb9XrpgivUUIaJtxmqp8hSIbIx14AkgiiHd9z9hSIbM(yIfGRACnXYdzz3bqS4SGsb1DflpKLfMyj9IIutfdm03t95Xab4956kYCrmyoalW7pyXIwwcqOceARmxHd96DDfLJ4Lx)kjdsaUazAYbtXIwwOiEDwweO5kCOxVRROCeV86xjzqcWfiw0YIBLd7uaP4pEliV4OhdKkxxrGXPlgOh(dwXaXV3dxPIbcs4qFw)bRyGrXiYILLflaFVhUsXI)S4kfl)LqywwLIWyww4RqXcAKk4TJzXlqwUNLdZIRdxplpKfRggyb2SOONLFNybBrHZvS4H)GflQRiw0jf0gl7EbQiw0un5j6xbsnlWIf7y59gf94yGH(EQppgO9S8UIQ3GFsP8od234nu56kcKfTSmHf7zbtFwhwlS5pQTlIYiSvGL5zwOG6SWK5QSxPyzEMfSfPu53Bu0Jn437HRuSSjlrGLPSOLLjSOVgdd(9E4kLPPrt4DxxrSOLLjSGTiLk)EJIESb)EpCLIfeXseyzEMf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKLPSmpZY7kQEdgUuz4i)7uEaBc)gQCDfbYIww0xJHHcQZctzmu5TPPe)kmliILiWIwwOG6SWK5QmgQ8MfTSOVgdd(9E4kLPPe)kmliIfeklAzbBrkv(9gf9yd(9E4kflBgjlimltzrlltyXEw6vrdyJImQubVDCEOi6VcvgL6sSWKHkxxrGSmpZYFjelixwqy0ZYMSOVgdd(9E4kLPPe)kmliGf7yzklAz59gf9M)sO8dZGhXYMSG(4pEli04OhdKkxxrGXPlgOh(dwXaXV3dxPIbcs4qFw)bRyGih3VZcWNukVzrt134zzHjwGflbqwSTtflnnAcV76kIf91Zc(pLIfB(9SmGnlOrQG3oMfRggyXlqwaH12pllmXIonGnXcY0uydla)tPyzHjw0PbSjwqgSaarIybFvGy539NfBNsXIvddS4f83PMfGV3dxPIbg67P(8yGVRO6n4NukVZG9nEdvUUIazrll6RXWGFVhUszAA0eE31velAzzcl2ZcM(SoSwyZFuBxeLryRalZZSqb1zHjZvzVsXY8mlylsPYV3OOhBWV3dxPyztwqywMYIwwMWI9S0RIgWgfzuPcE748qr0FfQmk1LyHjdvUUIazzEML)siwqUSGWONLnzbHzzklAz59gf9M)sO8dZGhXYMSeH4pElruC0JbsLRRiW40fd0d)bRyG437HRuXabjCOpR)GvmqKJ73zrt1KNOFfi1SSWelaFVhUsXYdzbjISyzzXYVtSOVgdw0tXIRWqww4RqXcW37HRuSalwqplykalqmlWMffHXS0uIF1vOIbg67P(8yG9QObSrrM)siBWUYGn5j6xbsTHkxxrGSOLfSfPu53Bu0Jn437HRuSSzKSebw0YYewSNf91yy(lHSb7kd2KNOFfi1MLflAzrFngg879WvkttJMW7UUIyzEMLjSaW7Z1vKbSjpjB7uQ8WvQmCmyrlltyrFngg879Wvkttj(vywqelrGL5zwWwKsLFVrrp2GFVhUsXYMSyhlAz5DfvVb)Ks5DgSVXBOY1veilAzrFngg879Wvkttj(vywqelONLPSmLLPXF8wIcXrpgivUUIaJtxmqOvmqm9Xa9WFWkgiaVpxxrXab4Qffd0XF7QSf0g1SSjlruASenwMWIgSOjSGPpRdRf28h12frz7ScSenwsZyhltzjASmHfnyrtyrFngM)siBWUYGn5j6xbsTb)EajwIglPz0GLPSOjSmHf91yyWV3dxPmnL4xHzjASebwqllylsPY7o(jwIgl2ZY7kQEd(jLY7myFJ3qLRRiqwMYIMWYewcqOceARm437HRuMMs8RWSenwIalOLfSfPu5Dh)elrJL3vu9g8tkL3zW(gVHkxxrGSmLfnHLjSOVgdZy1PYWrMuRImnL4xHzjASGEwMYIwwMWI(Amm437HRuMLflZZSeGqfi0wzWV3dxPmnL4xHzzAmqqch6Z6pyfdezUkSu(tywSTt)o1S4Sa89gVAuellmXITtPyj4lmXcW37HRuS8qwgUsXcCm0mlEbYYctSa89gVAuelpKfKiYIfnvtEI(vGuZc(9asSSSmSerPXYHz53jwAkIxxtGSSvmcHLhYsWXplaFVXRgfHaGV3dxPIbcW7C5jumq879WvQSny95HRuz4ye)XBrJ0IJEmqQCDfbgNUyGE4pyfde)EJxnkkgiiHd9z9hSIbM(yIfGV34vJIyX297SOPAYt0VcKAwEilirKflllw(DIf91yWIT73HRNffeFfkwa(EpCLILL1FjelEbYYctSa89gVAuelWIfegbSKo4wJol43diHzzv)PybHz59gf94yGH(EQppgiaVpxxrgWM8KSTtPYdxPYWXGfTSaW7Z1vKb)EpCLkBdwFE4kvgogSOLf7zbG3NRRiZHQGnLXV34vJIyzEMLjSOVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGelBYseyzEMf91yy0DLxbkdhzxPY)(vOWzVdErg87bKyztwIaltzrllylsPYV3OOhBWV3dxPybrSGWSOLfaEFUUIm437HRuzBW6ZdxPYWXi(J3IgAeh9yGu56kcmoDXa9WFWkgOd6w)bGYyBENedmKkOO87nk6XXBrJyGH(EQppgO9S8xaPRqXIwwSNfp8hSmoOB9hakJT5Dsg0tCuK5Q8qDO2FwMNzbe(gh0T(daLX28ojd6jokYGFpGeliILiWIwwaHVXbDR)aqzSnVtYGEIJImnL4xHzbrSeHyGGeo0N1FWkgy6JjwW28oHfmKLF3FwsbxSGIEwsCeZYY6VeIf9uSSWxHIL7zXXSO8NyXXSybX4txrSalwuegZYV7flrGf87bKWSaBwIIyHFwSTtflrabSGFpGeMfcXwxtXF8w0WU4OhdKkxxrGXPlgOh(dwXatGWACnfdmKkOO87nk6XXBrJyGH(EQppgytJMW7UUIyrllV3OO38xcLFyg8iw2KLjSmHfnqywqaltybBrkv(9gf9yd(9ECnXs0yXowIgl6RXWqb1zHPSAvEBwwSmLLPSGawAkXVcZYuwqlltyrdwqalVRO6nVTRYjqyHnu56kcKLPSOLLjS4w5WofqIL5zwa4956kYCOkytz87nE1OiwMNzXEwOG6SWK5QSxPyzklAzzclbiubcTvMGNVkyAYbtXIwwOG6SWK5QSxPyrll2ZcyVoqtbZbqmlAzzcla8(CDfzcWcaejkds4uvGL5zwcqOceARmbybaIeL)DkJTU(ESPjhmflZZSyplbiaQ86n1HA)ZdNyzklZZSGTiLk)EJIESb)EpUMybrSmHLjSG8yrtyzcl6RXWqb1zHPSAvEBwwSenwSJLPSmLLOXYew0GfeWY7kQEZB7QCcewydvUUIazzkltzrll2ZcfuNfMmyOY7Cri(zrll2ZsacvGqBLj45RcMMCWuSmpZYewOG6SWK5QmgQ8ML5zw0xJHHcQZctz1Q82SSyrll2ZY7kQEdgUuz4i)7uEaBc)gQCDfbYY8ml6RXWy1xcSbpxL9o41fYwlf2BdaxTiw2mswSd9PXYuw0YYewWwKsLFVrrp2GFVhxtSGiw0inwIgltyrdwqalVRO6nVTRYjqyHnu56kcKLPSmLfTS44VDv2cAJAw2Kf0NglAcl6RXWGFVhUszAkXVcZs0yb5XYuw0YYewSNLaeavE9gKs1NxSmpZI9SOVgddsxb2eyMsSG2OoHQptf1OUOsMLflZZSqb1zHjZvzmu5nltzrll2ZI(AmmTdGk4cNhnvrnvgF1yPY7PWp1NBwwXabjCOpR)GvmqKt0Oj8olAAqynUMy5gSGSTI20RcSCywAYbtPzw(DQjw8Myrryml)UxSGEwEVrrpMLRybnwL3SGob1zHjwSD)olaHpYxZSOimMLF3lw0inwG)o12omXYvS4vkwqNG6SWelWMLLflpKf0ZY7nk6XSOtdytS4SGgRYBwqNG6SWKHfnfS2(zPPrt4Dwax9vOyjk2vGnbYc6KybTrDcvplRsrymlxXcqOYBwqNG6SWu8hVfnIqC0JbsLRRiW40fd0d)bRyGdyhOmCKl)xnfdeKWH(S(dwXatFmXcYhUfwGflbqwSD)oC9SeClRRqfdm03t95XaDRCyNciXY8mla8(CDfzoufSPm(9gVAuu8hVfnq44OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbAplG96anfmhaXSOLLjSaW7Z1vKjaMdWc8(dwSOLLjSOVgdd(9E4kLzzXY8mlVRO6n4NukVZG9nEdvUUIazzEMLaeavE9M6qT)5HtSmLfTSacFtcewJRjZFbKUcflAzzcl2ZI(AmmyOc)xGmllw0YI9SOVgdtWZxfmllw0YYewSNL3vu9MXQtLHJmPwfzOY1veilZZSOVgdtWZxfmGR2)dwSSjlbiubcTvMXQtLHJmPwfzAkXVcZccyjIyzklAzzcl2ZcM(SoSwyZFuBxeLTZkWY8mluqDwyYCvwTkVzzEMfkOolmzWqL35Iq8ZYuw0YcaVpxxrMFVpLkJjcjQZ287zrlltyXEwcqau51BQd1(NhoXY8mlbiubcTvMaSaarIY)oLXwxFp20uIFfMfeXI(AmmbpFvWaUA)pyXs0yjnd6zzklAz59gf9M)sO8dZGhXYMSOVgdtWZxfmGR2)dwSenwsZGqzzklZZSOdXyw0YY4qT)5Ms8RWSGiw0xJHj45RcgWv7)blwqalAyhlrJLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLPXab4DU8ekgyamhGf49hSYoKI)4TOb6JJEmqQCDfbgNUyGE4pyfdSDaubx48OPkQPIbcs4qFw)bRyGPpMyb53uf1uSy7(Dwq2wrB6vHyGH(EQppgO(AmmbpFvW0uIFfMLnzrd0ZY8ml6RXWe88vbd4Q9)GfliGfnSJLOXsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYcIyXoKhlAzbG3NRRitamhGf49hSYoKI)4TObYlo6XaPY1veyC6Ib6H)GvmWaPi8FUk7QdvLq1hdeKWH(S(dwXatFmXcY2kAtVkWcSyjaYYQuegZIxGSOUIy5EwwwSy7(DwqgSaarIIbg67P(8yGa8(CDfzcG5aSaV)Gv2HelAzzcl6RXWe88vbd4Q9)GfliGfnSJLOXsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYYMrYIDipwMNzXEwcqau51Baq1VNQzzklZZSOVgdt7aOcUW5rtvutzwwSOLf91yyAhavWfopAQIAkttj(vywqelrbwqalbybUU3y1u4Wu2vhQkHQ38xcLb4QfXccyzcl2ZI(Amm6kieuTWVzzXIwwSNL3vu9g87Tc2GgQCDfbYY04pElAGqJJEmqQCDfbgNUyGH(EQppgiaVpxxrMayoalW7pyLDifd0d)bRyGxf8U8)Gv8hVfnIO4OhdKkxxrGXPlgOh(dwXaPelOnQZ6WcmgiiHd9z9hSIbM(yIf0jXcAJAwshSazbwSeazX297Sa89E4kflllw8cKfSdGyzaBwqilf2Bw8cKfKTv0MEvigyOVN6ZJboHLaeQaH2ktWZxfmnL4xHzbbSOVgdtWZxfmGR2)dwSGaw6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqwIglAyhlBYsacvGqBLHsSG2OoRdlqd4Q9)GfliGfnsJLPSmpZI(AmmbpFvW0uIFfMLnzjIyzEMfWEDGMcMdG44pElAefIJEmqQCDfbgNUyGE4pyfde)Ks5DEO8MIbgsfuu(9gf944TOrmWqFp1NhdSPrt4DxxrSOLL)sO8dZGhXYMSOb6zrllylsPYV3OOhBWV3JRjwqelimlAzXTYHDkGelAzzcl6RXWe88vbttj(vyw2KfnsJL5zwSNf91yycE(QGzzXY0yGGeo0N1FWkgiYjA0eENLHYBIfyXYYILhYsey59gf9ywSD)oC9SGSTI20RcSOtxHIfxhUEwEileITUMyXlqwk4Zcea1b3Y6kuXF8wSlT4OhdKkxxrGXPlgOh(dwXahRovgoYKAvumqqch6Z6pyfdm9XeliFi6WYny5k8bsS4flOtqDwyIfVazrDfXY9SSSyX297S4SGqwkS3Sy1WalEbYYwbDR)aqSa0M3jXad99uFEmqkOolmzUk7vkw0YYewCRCyNciXY8ml2ZsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYYuw0YYew0xJHXQVeydEUk7DWRlKTwkS3gaUArSGiwSd9PXY8ml6RXWe88vbttj(vyw2KLiILPSOLLjSacFJd6w)bGYyBENKb9ehfz(lG0vOyzEMf7zjabqLxVPOqdvWgKL5zwWwKsLFVrrpMLnzXowMYIwwMWI(AmmTdGk4cNhnvrnLPPe)kmliILOalAcltybHzjAS0RIgWgfzWxnwQ8Ek8t95gQCDfbYYuw0YI(AmmTdGk4cNhnvrnLzzXY8ml2ZI(AmmTdGk4cNhnvrnLzzXYuw0YYewSNLaeQaH2ktWZxfmllwMNzrFngMFVpLkJjcjQn43diXcIyrd0ZIwwghQ9p3uIFfMfeXIDPLglAzzCO2)Ctj(vyw2KfnslnwMNzXEwWWLs)kqZV3NsLXeHe1gQCDfbYYuw0YYewWWLs)kqZV3NsLXeHe1gQCDfbYY8mlbiubcTvMGNVkyAkXVcZYMSeH0yzklAz59gf9M)sO8dZGhXYMSGEwMNzrhIXSOLLXHA)ZnL4xHzbrSOrAXF8wStJ4OhdKkxxrGXPlgOh(dwXaXV3dxPIbcs4qFw)bRyGPpMyXzb479Wvkw00l63zXQHbwwLIWywa(EpCLILdZIRAYbtXYYIfyZsk4IfVjwCD46z5HSabqDWTyzRyesmWqFp1NhduFnggyr)ooBrDGS(dwMLflAzzcl6RXWGFVhUszAA0eE31velZZS44VDv2cAJAw2KLOqASmn(J3ID2fh9yGu56kcmoDXa9WFWkgi(9E4kvmqqch6Z6pyfdutTsSyzRyecl60a2elidwaGirSy7(Dwa(EpCLIfVaz53PIfGV34vJIIbg67P(8yGbiaQ86n1HA)ZdNyrll2ZY7kQEd(jLY7myFJ3qLRRiqw0YYewa4956kYeGfaisugKWPQalZZSeGqfi0wzcE(QGzzXY8ml6RXWe88vbZYILPSOLLaeQaH2ktawaGir5FNYyRRVhBAkXVcZcIybva0K4iMLOXsGofltyXXF7QSf0g1SGwwqFASmLfTSOVgdd(9E4kLPPe)kmliIfeMfTSyplG96anfmhaXXF8wSlcXrpgivUUIaJtxmWqFp1NhdmabqLxVPou7FE4elAzzcla8(CDfzcWcaejkds4uvGL5zwcqOceARmbpFvWSSyzEMf91yycE(QGzzXYuw0YsacvGqBLjalaqKO8VtzS113JnnL4xHzbrSGEw0YcaVpxxrg879WvQSny95HRuz4yWIwwOG6SWK5QSxPyrll2ZcaVpxxrMdvbBkJFVXRgfXIwwSNfWEDGMcMdG4yGE4pyfde)EJxnkk(J3IDiCC0JbsLRRiW40fd0d)bRyG43B8QrrXabjCOpR)GvmW0htSa89gVAuel2UFNfVyrtVOFNfRggyb2SCdwsbxBdYcea1b3ILTIriSy7(DwsbxnlfH4NLGJFdlBvHHSaUsSyzRyecl(ZYVtSqfilWbl)oXsuuQ(9unl6RXGLBWcW37HRuSydUuG12pldxPybogSaBwsbxS4nXcSyXowEVrrpogyOVN6ZJbQVgddSOFhNdkY7mGdFWYSSyzEMLjSypl437X1KXTYHDkGelAzXEwa4956kYCOkytz87nE1OiwMNzzcl6RXWe88vbttj(vywqelONfTSOVgdtWZxfmllwMNzzcltyrFngMGNVkyAkXVcZcIybva0K4iMLOXsGofltyXXF7QSf0g1SGwwa4956kYGX5ae)SmLfTSOVgdtWZxfmllwMNzrFngM2bqfCHZJMQOMkJVASu59u4N6ZnnL4xHzbrSGkaAsCeZs0yjqNILjS44VDv2cAJAwqlla8(CDfzW4CaIFwMYIww0xJHPDaubx48OPkQPY4RglvEpf(P(CZYILPSOLLaeavE9gau97PAwMYYuw0YYewWwKsLFVrrp2GFVhUsXcIyjcSmpZcaVpxxrg879WvQSny95HRuz4yWYuwMYIwwSNfaEFUUImhQc2ug)EJxnkIfTSmHf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKL5zwWwKsLFVrrp2GFVhUsXcIyjcSmn(J3IDOpo6XaPY1veyC6Ib6H)GvmWISLtGWkgiiHd9z9hSIbM(yIfnniSWSCflaHkVzbDcQZctS4filyhaXcYFPuSOPbHfldyZcY2kAtVkedm03t95XaNWI(AmmuqDwykJHkVnnL4xHzztwietH1t5)siwMNzzclHDVrrywIKf7yrllnf29gfL)lHybrSGEwMYY8mlHDVrrywIKLiWYuw0YIBLd7uaP4pEl2H8IJEmqQCDfbgNUyGH(EQppg4ew0xJHHcQZctzmu5TPPe)kmlBYcHykSEk)xcXY8mltyjS7nkcZsKSyhlAzPPWU3OO8FjeliIf0ZYuwMNzjS7nkcZsKSebwMYIwwCRCyNciXIwwMWI(AmmTdGk4cNhnvrnLPPe)kmliIf0ZIww0xJHPDaubx48OPkQPmllw0YI9S0RIgWgfzWxnwQ8Ek8t95gQCDfbYY8ml2ZI(AmmTdGk4cNhnvrnLzzXY0yGE4pyfdC3vJCcewXF8wSdHgh9yGu56kcmoDXad99uFEmWjSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeIfTSmHLaeQaH2ktWZxfmnL4xHzztwqFASmpZsacvGqBLjalaqKO8VtzS113JnnL4xHzztwqFASmLL5zwMWsy3BueMLizXow0YstHDVrr5)siwqelONLPSmpZsy3BueMLizjcSmLfTS4w5WofqIfTSmHf91yyAhavWfopAQIAkttj(vywqelONfTSOVgdt7aOcUW5rtvutzwwSOLf7zPxfnGnkYGVASu59u4N6Znu56kcKL5zwSNf91yyAhavWfopAQIAkZYILPXa9WFWkg4yPu5eiSI)4Tyxefh9yGu56kcmoDXabjCOpR)GvmW0htSGCarhwGflittfd0d)bRyG28UpyNHJmPwff)XBXUOqC0JbsLRRiW40fdeAfdetFmqp8hSIbcW7Z1vumqaUArXaXwKsLFVrrp2GFVhxtSSjlimliGLHccBwMWsIJFQtLb4QfXs0yrJ0sJf0YIDPXYuwqaldfe2SmHf91yyWV34vJIYuIf0g1ju9zmu5Tb)EajwqllimltJbcs4qFw)bRyGiZvHLYFcZITD63PMLhYYctSa89ECnXYvSaeQ8MfB7xyNLdZI)SGEwEVrrpgbAWYa2SqaOofl2LgYLLeh)uNIfyZccZcW3B8QrrSGojwqBuNq1Zc(9as4yGa8oxEcfde)EpUMYxLXqL3XF8wIqAXrpgivUUIaJtxmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdudwqllylsPY7o(jwqel2XIMWYewsZyhlrJLjSGTiLk)EJIESb)EpUMyrtyrdwMYs0yzclAWccy5DfvVbdxQmCK)DkpGnHFdvUUIazjASOHb9SmLLPSGawsZOb6zjASOVgdt7aOcUW5rtvutzAkXVchdeKWH(S(dwXarMRclL)eMfB70VtnlpKfKJ2)Dwax9vOyb53uf1uXab4DU8ekgOT2)98v5rtvutf)XBjcAeh9yGu56kcmoDXa9WFWkgOT2)9yGGeo0N1FWkgy6JjwqoA)3z5kwacvEZc6euNfMyb2SCdwkilaFVhxtSy7ukwg3ZYvpKfKTv0MEvGfVsLaBkgyOVN6ZJboHfkOolmzuRY7Cri(zzEMfkOolmz8kvUie)SOLfaEFUUImhohuKdGyzklAzzclV3OO38xcLFyg8iw2KfeML5zwOG6SWKrTkVZxLTJL5zw0HymlAzzCO2)Ctj(vywqelAKgltzzEMf91yyOG6SWugdvEBAkXVcZcIyXd)bld(9ECnzietH1t5)siw0YI(AmmuqDwykJHkVnllwMNzHcQZctMRYyOYBw0YI9SaW7Z1vKb)EpUMYxLXqL3SmpZI(AmmbpFvW0uIFfMfeXIh(dwg8794AYqiMcRNY)LqSOLf7zbG3NRRiZHZbf5aiw0YI(AmmbpFvW0uIFfMfeXcHykSEk)xcXIww0xJHj45RcMLflZZSOVgdt7aOcUW5rtvutzwwSOLfaEFUUIm2A)3ZxLhnvrnflZZSypla8(CDfzoCoOihaXIww0xJHj45RcMMs8RWSSjleIPW6P8Fju8hVLiyxC0JbsLRRiW40fdeKWH(S(dwXatFmXcW37X1el3GLRybnwL3SGob1zHjnZYvSaeQ8Mf0jOolmXcSybHralV3OOhZcSz5HSy1WalaHkVzbDcQZctXa9WFWkgi(9ECnf)XBjcrio6XaPY1veyC6Ibcs4qFw)bRyGiFxP(9Efd0d)bRyG9QYE4pyLvh(JbQo8NlpHIboCL637v8h)XahUs979ko6XBrJ4OhdKkxxrGXPlgOh(dwXaXV34vJIIbcs4qFw)bRyGaFVXRgfXYa2SKabqju9SSkfHXSSWxHIL0b3A0Jbg67P(8yG2ZsVkAaBuKr3vEfOmCKDLk)7xHcBOiEDwwey8hVf7IJEmqQCDfbgNUyGE4pyfdeVQX1umWqQGIYV3OOhhVfnIbg67P(8yGGW3KaH14AY0uIFfMLnzPPe)kmlrJf7SJf0YIgrumqqch6Z6pyfdezo(z53jwaHpl2UFNLFNyjbIFw(lHy5HS4GGSSQ)uS87eljoIzbC1(FWILdZY(9gwaUQX1elnL4xHzjzP(ZsDeilpKLe)d7SKaH14AIfWv7)bR4pElrio6Xa9WFWkgycewJRPyGu56kcmoDXF8hde)XrpElAeh9yGu56kcmoDXa9WFWkgOd6w)bGYyBENedmKkOO87nk6XXBrJyGH(EQppgO9SacFJd6w)bGYyBENKb9ehfz(lG0vOyrll2ZIh(dwgh0T(daLX28ojd6jokYCvEOou7plAzzcl2Zci8noOB9hakJT5DsENCL5VasxHIL5zwaHVXbDR)aqzSnVtY7KRmnL4xHzztwqpltzzEMfq4BCq36paugBZ7KmON4Oid(9asSGiwIalAzbe(gh0T(daLX28ojd6jokY0uIFfMfeXseyrllGW34GU1FaOm2M3jzqpXrrM)ciDfQyGGeo0N1FWkgy6Jjw2kOB9haIfG28oHfB7uXYVtnXYHzPGS4H)aqSGT5DIMzXXSO8NyXXSybX4txrSalwW28oHfB3VZIDSaBwgKnQzb)EajmlWMfyXIZseqalyBENWcgYYV7pl)oXsr2ybBZ7ew8UpaeMLOiw4NfF8uZYV7plyBENWcHyRRjC8hVf7IJEmqQCDfbgNUyGE4pyfdmalaqKO8VtzS113JJbcs4qFw)bRyGPpMWSGmybaIeXYnybzBfTPxfy5WSSSyb2SKcUyXBIfqcNQcxHIfKTv0MEvGfB3VZcYGfaiselEbYsk4IfVjw0jf0gliCAOncPnbzKIW)5kwaAD994PSSvmcHLRyXzrJ0qalykWc6euNfMmSSvfgYciS2(zrrplAQM8e9RaPMfcXwxtAMfxzZtHzzHjwUIfKTv0MEvGfB3VZcczPWEZIxGS4pl)oXc(9(zboyXzjDWTgDwSDfi0MjgyOVN6ZJbAplG96anfmhaXSOLLjSmHfaEFUUImbybaIeLbjCQkWIwwSNLaeQaH2ktWZxfmn5GPyrll2ZsVkAaBuKXQVeydEUk7DWRlKTwkS3gQCDfbYY8ml6RXWe88vbZYILPSOLLjSmHfh)TRYwqBuZcIIKfaEFUUImbybaIeLDSflAzzcl6RXWqb1zHPSAvEBAkXVcZYMSOrASmpZI(AmmuqDwykJHkVnnL4xHzztw0inwMYY8ml6RXWe88vbttj(vyw2Kf0ZIww0xJHj45RcMMs8RWSGOizrd7yzklAzzcl2ZsVkAaBuK5VeYgSRmytEI(vGuBOY1veilZZSypl9QObSrrMaPi8FUkJTU(ESHkxxrGSmpZI(Amm)Lq2GDLbBYt0VcKAttj(vyw2KfcXuy9u(VeILPSmpZsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veiltzrlltyXEw6vrdyJIm6UYRaLHJSRu5F)kuydvUUIazzEMLjSOVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGelrYseXY8ml6RXWO7kVcugoYUsL)9RqHZEh8Im43diXsKSerSmLLPSmpZIoeJzrllJd1(NBkXVcZcIyrJ0yrll2ZsacvGqBLj45RcMMCWuSmn(J3seIJEmqQCDfbgNUyGE4pyfde)EJxnkkgiiHd9z9hSIbM(yIfGV34vJIy5HSGerwSSSy53jw0un5j6xbsnl6RXGLBWY9SydUuGSqi26AIfDAaBILXvhE)kuS87elfH4NLGJFwGnlpKfWvIfl60a2elidwaGirXad99uFEmWEv0a2OiZFjKnyxzWM8e9RaP2qLRRiqw0YYewSNLjSmHf91yy(lHSb7kd2KNOFfi1MMs8RWSSjlE4pyzS1(VBietH1t5)siwqalPz0GfTSmHfkOolmzUkRd)DwMNzHcQZctMRYyOYBwMNzHcQZctg1Q8oxeIFwMYY8ml6RXW8xczd2vgSjpr)kqQnnL4xHzztw8WFWYGFVhxtgcXuy9u(VeIfeWsAgnyrlltyHcQZctMRYQv5nlZZSqb1zHjdgQ8oxeIFwMNzHcQZctgVsLlcXpltzzklZZSypl6RXW8xczd2vgSjpr)kqQnllwMYY8mltyrFngMGNVkywwSmpZcaVpxxrMaSaarIYGeovfyzklAzjaHkqOTYeGfaisu(3Pm2667XMMCWuSOLLaeavE9M6qT)5HtSOLLjSOVgddfuNfMYQv5TPPe)kmlBYIgPXY8ml6RXWqb1zHPmgQ820uIFfMLnzrJ0yzkltzrlltyXEwcqau51BqkvFEXY8mlbiubcTvgkXcAJ6SoSannL4xHzztwIiwMg)XBbHJJEmqQCDfbgNUyGE4pyfde)EJxnkkgiiHd9z9hSIbQPwjwSa89gVAueMfB3VZs6CLxbIf4GLTQuSe99RqHzb2S8qwSAYYBILbSzbzWcaejIfB3VZs6GBn6Xad99uFEmWEv0a2OiJUR8kqz4i7kv(3Vcf2qLRRiqw0YYewMWI(Amm6UYRaLHJSRu5F)ku4C5)Qjd(9asSSjl2XY8ml6RXWO7kVcugoYUsL)9RqHZEh8Im43diXYMSyhltzrllbiubcTvMGNVkyAkXVcZYMSGqzrll2ZsacvGqBLjalaqKO8VtzS113JnllwMNzzclbiaQ86n1HA)ZdNyrllbiubcTvMaSaarIY)oLXwxFp20uIFfMfeXIgPXIwwOG6SWK5QSxPyrllo(BxLTG2OMLnzXU0ybbSeH0yjASeGqfi0wzcE(QGPjhmfltzzA8hVf0hh9yGu56kcmoDXaHwXaX0hd0d)bRyGa8(CDffdeGRwumWjSOVgdt7aOcUW5rtvutzAkXVcZYMSGEwMNzXEw0xJHPDaubx48OPkQPmllwMYIwwSNf91yyAhavWfopAQIAQm(QXsL3tHFQp3SSyrlltyrFnggKUcSjWmLybTrDcvFMkQrDrLmnL4xHzbrSGkaAsCeZYuw0YYew0xJHHcQZctzmu5TPPe)kmlBYcQaOjXrmlZZSOVgddfuNfMYQv5TPPe)kmlBYcQaOjXrmlZZSmHf7zrFnggkOolmLvRYBZYIL5zwSNf91yyOG6SWugdvEBwwSmLfTSyplVRO6nyOc)xGmu56kcKLPXabjCOpR)GvmqKblW7pyXYa2S4kflGWhZYV7pljoseMf8Qjw(DkflEt12plnnAcVtGSyBNkwqo5aOcUWSG8BQIAkw2DmlkcJz539If0ZcMcywAkXV6kuSaBw(DIf0jXcAJAwshSazrFngSCywCD46z5HSmCLIf4yWcSzXRuSGob1zHjwomlUoC9S8qwieBDnfdeG35YtOyGGWp3ueVUMsO6XXF8wqEXrpgivUUIaJtxmqOvmqm9Xa9WFWkgiaVpxxrXab4QffdCcl2ZI(AmmuqDwykJHkVnllw0YI9SOVgddfuNfMYQv5TzzXYuw0YI9S8UIQ3GHk8FbYqLRRiqw0YI9S0RIgWgfz(lHSb7kd2KNOFfi1gQCDfbgdeKWH(S(dwXargSaV)Gfl)U)Se2PasywUblPGlw8MybUE8bsSqb1zHjwEilWsLIfq4ZYVtnXcSz5qvWMy53pml2UFNfGqf(VafdeG35YtOyGGWpdxp(aPmfuNfMI)4TGqJJEmqQCDfbgNUyGE4pyfdmbcRX1umWqQGIYV3OOhhVfnIbg67P(8yGtyrFnggkOolmLXqL3MMs8RWSSjlnL4xHzzEMf91yyOG6SWuwTkVnnL4xHzztwAkXVcZY8mla8(CDfzaHFgUE8bszkOolmXYuw0YstJMW7UUIyrllV3OO38xcLFyg8iw2KfnSJfTS4w5WofqIfTSaW7Z1vKbe(5MI411ucvpogiiHd9z9hSIbQPGplUsXY7nk6XSy7(9RybH4fiLCbwSD)oC9SabqDWTSUcfc(DIfxhcGyjalW7pyHJ)4TerXrpgivUUIaJtxmqp8hSIbIx14AkgyOVN6ZJboHf91yyOG6SWugdvEBAkXVcZYMS0uIFfML5zw0xJHHcQZctz1Q820uIFfMLnzPPe)kmlZZSaW7Z1vKbe(z46XhiLPG6SWeltzrllnnAcV76kIfTS8EJIEZFju(HzWJyztw0Wow0YIBLd7uajw0YcaVpxxrgq4NBkIxxtju94yGHubfLFVrrpoElAe)XBjkeh9yGu56kcmoDXa9WFWkgi(jLY78q5nfdm03t95XaNWI(AmmuqDwykJHkVnnL4xHzztwAkXVcZY8ml6RXWqb1zHPSAvEBAkXVcZYMS0uIFfML5zwa4956kYac)mC94dKYuqDwyILPSOLLMgnH3DDfXIwwEVrrV5Vek)Wm4rSSjlAG8yrllUvoStbKyrlla8(CDfzaHFUPiEDnLq1JJbgsfuu(9gf944TOr8hVfnslo6XaPY1veyC6IbcTIbIPpgOh(dwXab4956kkgiaxTOyGbiaQ86naO63t1SOLf7zPxfnGnkYGVASu59u4N6Znu56kcKfTSypl9QObSrrMW1bfLHJS6gu2lWmi5)UHkxxrGSOLLaeQaH2kJo1yQr6kuMMCWuSOLLaeQaH2kt7aOcUW5rtvutzAYbtXIwwSNf91yycE(QGzzXIwwMWIJ)2vzlOnQzztwIieklZZSOVgdJUccbvl8BwwSmngiiHd9z9hSIbQPGpl9HA)zrNgWMyb53uf1uSCdwUNfBWLcKfxPG2yjfCXYdzPPrt4DwuegZc4QVcfli)MQOMILj)(HzbwQuSS7wwuHzX297W1ZcWRglfliNNc)uF(0yGa8oxEcfdSG59u4N6ZZK3Quzq4h)XBrdnIJEmqQCDfbgNUyGH(EQppgiaVpxxrMcM3tHFQpptERsLbHplAzPPe)kmliIf7slgOh(dwXatGWACnf)XBrd7IJEmqQCDfbgNUyGH(EQppgiaVpxxrMcM3tHFQpptERsLbHplAzPPe)kmliIfnIcXa9WFWkgiEvJRP4pElAeH4OhdKkxxrGXPlgOh(dwXahWoqz4ix(VAkgiiHd9z9hSIbM(yIfKpClSalwcGSy7(D46zj4wwxHkgyOVN6ZJb6w5Wofqk(J3IgiCC0JbsLRRiW40fd0d)bRyGuIf0g1zDybgdeKWH(S(dwXatFmXc6KybTrnlPdwGSy7(Dw8kflkyHIfQGlu7SOC8FfkwqNG6SWelEbYY3Py5HSOUIy5EwwwSy7(Dwqilf2Bw8cKfKTv0MEvigyOVN6ZJboHLaeQaH2ktWZxfmnL4xHzbbSOVgdtWZxfmGR2)dwSGaw6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqwIglAyhlBYsacvGqBLHsSG2OoRdlqd4Q9)GfliGfnsJLPSmpZI(AmmbpFvW0uIFfMLnzjIyzEMfWEDGMcMdG44pElAG(4OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIb64VDv2cAJAw2KLOqASOjSmHf7mONLOXI(AmmJvNkdhzsTkYGFpGelAcl2Xs0yHcQZctMRYQv5nltJbcs4qFw)bRyGaPhZITDQyzRyecl4D4sbYIoXc4kXIaz5HSuWNfiaQdUflt0uKfvGywGfli)vNIf4Gf0rTkIfVaz53jwqNG6SW00yGa8oxEcfd0XwzWvIv8hVfnqEXrpgivUUIaJtxmqOvmqm9Xa9WFWkgiaVpxxrXab4Qffd0Ewa71bAkyoaIzrlltybG3NRRitamhGf49hSyrll2ZI(AmmbpFvWSSyrlltyXEwW0N1H1cB(JA7IOSDwbwMNzHcQZctMRYQv5nlZZSqb1zHjdgQ8oxeIFwMYIwwMWYewMWcaVpxxrghBLbxjwSmpZsacGkVEtDO2)8WjwMNzzclbiaQ86niLQpVyrllbiubcTvgkXcAJ6SoSann5GPyzklZZS0RIgWgfz(lHSb7kd2KNOFfi1gQCDfbYYuw0Yci8n4vnUMmnL4xHzztwIiw0Yci8njqynUMmnL4xHzztwIcSOLLjSacFd(jLY78q5nzAkXVcZYMSOrASmpZI9S8UIQ3GFsP8opuEtgQCDfbYYuw0YcaVpxxrMFVpLkJjcjQZ287zrllV3OO38xcLFyg8iw2Kf91yycE(QGbC1(FWILOXsAgeklZZSOVgdJUccbvl8BwwSOLf91yy0vqiOAHFttj(vywqel6RXWe88vbd4Q9)GfliGLjSOHDSenw6vrdyJImw9LaBWZvzVdEDHS1sH92qLRRiqwMYYuwMNzzclueVollc0qjwPAYvzydwEfiw0YsacvGqBLHsSs1KRYWgS8kqMMs8RWSGiw0a5HqzbbSmHf0Zs0yPxfnGnkYGVASu59u4N6Znu56kcKLPSmLLPSOLLjSyplbiaQ86n1HA)ZdNyzEMLjSeGqfi0wzcWcaejk)7ugBD99yttj(vywqel6RXWe88vbd4Q9)GflOLf7yrll2ZsVkAaBuKr3vEfOmCKDLk)7xHcBOY1veilZZSeGqfi0wzcWcaejk)7ugBD99yttoykw0YIJ)2vzlOnQzbrSG(0yzklZZSOdXyw0YY4qT)5Ms8RWSGiwcqOceARmbybaIeL)DkJTU(ESPPe)kmltzzEMfDigZIwwghQ9p3uIFfMfeXI(AmmbpFvWaUA)pyXccyrd7yjAS0RIgWgfzS6lb2GNRYEh86czRLc7THkxxrGSmngiiHd9z9hSIbM(yIfKTv0MEvGfB3VZcYGfaiseAJIDfytGSa0667XS4filGWA7NfiaQT13tSGqwkS3SaBwSTtflPtbHGQf(zXgCPazHqS11el60a2eliBROn9QaleITUMWgw00CKiwWRMy5HSq1tnlolOXQ8Mf0jOolmXITDQyzHpuflr3UiIf7ScS4filUsXcY0uywSDkfl6uaMqS0KdMIfmewSqfCHANfWvFfkw(DIf91yWIxGSacFml7oaIfDIkwWRX4chvVkflnnAcVtGMyGa8oxEcfdmaMdWc8(dwz8h)XBrdeAC0JbsLRRiW40fd0d)bRyGTdGk4cNhnvrnvmqqch6Z6pyfdm9Xeli)MQOMIfB3VZcY2kAtVkWYQuegZcYVPkQPyXgCPazr54NffSqrnl)UxSGSTI20RcAMLFNkwwyIfDAaBkgyOVN6ZJbQVgdtWZxfmnL4xHzztw0a9SmpZI(AmmbpFvWaUA)pyXcIyXoekliGLEv0a2OiJvFjWg8Cv27GxxiBTuyVnu56kcKLOXIg2XIwwa4956kYeaZbybE)bRm(J)4TOrefh9yGu56kcmoDXad99uFEmqaEFUUImbWCawG3FWkJFw0YYew0xJHj45RcgWv7)blw2mswSdHYccyPxfnGnkYy1xcSbpxL9o41fYwlf2BdvUUIazjASOHDSmpZI9SeGaOYR3aGQFpvZYuwMNzrFngM2bqfCHZJMQOMYSSyrll6RXW0oaQGlCE0uf1uMMs8RWSGiwIcSGawcWcCDVXQPWHPSRouvcvV5VekdWvlIfeWYewSNf91yy0vqiOAHFZYIfTSyplVRO6n43BfSbnu56kcKLPXa9WFWkgyGue(pxLD1HQsO6J)4TOruio6XaPY1veyC6Ibg67P(8yGa8(CDfzcG5aSaV)Gvg)Xa9WFWkg4vbVl)pyf)XBXU0IJEmqQCDfbgNUyGqRyGy6Jb6H)GvmqaEFUUIIbcWvlkgyacvGqBLj45RcMMs8RWSSjlAKglZZSypla8(CDfzcWcaejkds4uvGfTSeGaOYR3uhQ9ppCIL5zwa71bAkyoaIJbcs4qFw)bRyGrr9(CDfXYctGSalwC9tD)ryw(D)zXMxplpKfDIfSdGazzaBwq2wrB6vbwWqw(D)z53PuS4nvpl2C8tGSefXc)SOtdytS87usmqaENlpHIbIDauEa7CWZxfI)4TyNgXrpgivUUIaJtxmqp8hSIbowDQmCKj1QOyGGeo0N1FWkgy6JjmliFi6WYny5kw8If0jOolmXIxGS89rywEilQRiwUNLLfl2UFNfeYsH9wZSGSTI20RcAMf0jXcAJAwshSazXlqw2kOB9haIfG28ojgyOVN6ZJbsb1zHjZvzVsXIwwMWIJ)2vzlOnQzbrSefSJfnHf91yygRovgoYKAvKb)EajwIglONL5zw0xJHPDaubx48OPkQPmllwMYIwwMWI(Ammw9LaBWZvzVdEDHS1sH92aWvlIfeXIDiCASmpZI(AmmbpFvW0uIFfMLnzjIyzklAzbG3NRRid2bq5bSZbpFvGfTSmHf7zjabqLxVPOqdvWgKL5zwaHVXbDR)aqzSnVtYGEIJIm)fq6kuSmLfTSmHf7zjabqLxVbav)EQML5zw0xJHPDaubx48OPkQPmnL4xHzbrSefyrtyzclimlrJLEv0a2Oid(QXsL3tHFQp3qLRRiqwMYIww0xJHPDaubx48OPkQPmllwMNzXEw0xJHPDaubx48OPkQPmllwMYIwwMWI9SeGaOYR3GuQ(8IL5zwcqOceARmuIf0g1zDybAAkXVcZYMSyxASmLfTS8EJIEZFju(HzWJyztwqplZZSOdXyw0YY4qT)5Ms8RWSGiw0iT4pEl2zxC0JbsLRRiW40fd0d)bRyG437HRuXabjCOpR)GvmW0htSOPx0VZcW37HRuSy1WaMLBWcW37HRuSC4A7NLLvmWqFp1NhduFnggyr)ooBrDGS(dwMLflAzrFngg879WvkttJMW7UUII)4TyxeIJEmqQCDfbgNUyGE4pyfdm4vGuz91yedm03t95Xa1xJHb)ERGnOPPe)kmliIf0ZIwwMWI(AmmuqDwykJHkVnnL4xHzztwqplZZSOVgddfuNfMYQv5TPPe)kmlBYc6zzklAzXXF7QSf0g1SSjlrH0IbQVgJC5jumq87Tc2GXabjCOpR)GvmqK5vGuSa89wbBqwUbl3ZYUJzrryml)UxSGEmlnL4xDfknZsk4IfVjw8NLOqAiGLTIriS4fil)oXsy1nvplOtqDwyILDhZc6raMLMs8RUcv8hVf7q44OhdKkxxrGXPlgOh(dwXadEfivwFngXad99uFEmW3vu9MRcEx(FWYqLRRiqw0YI9S8UIQ3uKTCcewgQCDfbYIwwIIJLjSmHLiKwASOjS44VDv2cAJAwqaliCASOjSGPpRdRf28h12frz7ScSenwq40yzklOLLjSGWSGwwWwKsL3D8tSmLfnHLaeQaH2ktawaGir5FNYyRRVhBAkXVcZYuwqelrXXYewMWseslnw0ewC83UkBbTrnlAcl6RXWy1xcSbpxL9o41fYwlf2BdaxTiwqaliCASOjSGPpRdRf28h12frz7ScSenwq40yzklOLLjSGWSGwwWwKsL3D8tSmLfnHLaeQaH2ktawaGir5FNYyRRVhBAkXVcZYuw0YsacvGqBLj45RcMMs8RWSSjlrinw0YI(Ammw9LaBWZvzVdEDHS1sH92aWvlIfeXIDAKglAzrFnggR(sGn45QS3bVUq2APWEBa4QfXYMSeH0yrllbiubcTvMaSaarIY)oLXwxFp20uIFfMfeXccNglAzzCO2)Ctj(vyw2KLaeQaH2ktawaGir5FNYyRRVhBAkXVcZccyb5XIwwMWsVkAaBuKjqkc)NRYyRRVhBOY1veilZZSaW7Z1vKjalaqKOmiHtvbwMgduFng5YtOyGw9LaBWZvzVdEDHS1sH9ogiiHd9z9hSIbImVcKILFNybHSuyVzrFngSCdw(DIfRggyXgCPaRTFwuxrSSSyX297S87elfH4NL)siwqgSaarIyjatimlWXGLaOHLOVFyww4LRuPybwQuSS7wwuHzbC1xHILFNyjDOHj(J3IDOpo6XaPY1veyC6IbcTIbIPpgOh(dwXab4956kkgiaxTOyGbiaQ86n1HA)ZdNyrll9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilAzrFnggR(sGn45QS3bVUq2APWEBa4QfXccyXXF7QSf0g1SGawIalBgjlriT0yrlla8(CDfzcWcaejkds4uvGfTSeGqfi0wzcWcaejk)7ugBD99yttj(vywqelo(BxLTG2OMf0YsesJLOXcQaOjXrmlAzXEwa71bAkyoaIzrlluqDwyYCv2RuSOLfh)TRYwqBuZYMSaW7Z1vKjalaqKOSJTyrllbiubcTvMGNVkyAkXVcZYMSG(yGGeo0N1FWkgiq6XSyBNkwqilf2BwW7WLcKfDIfRggceilK3QuS8qw0jwCDfXYdzzHjwqgSaarIybwSeGqfi0wXYe0bJP6pxPsXIofGjeMLVxel3GfWvI1vOyzRyeclf0gl2oLIfxPG2yjfCXYdzXI6bfEvkwO6PMfeYsH9MfVaz53PILfMybzWcaejAAmqaENlpHIbA1Wq2APWENjVvPI)4TyhYlo6XaPY1veyC6Ib6H)Gvmq879WvQyGGeo0N1FWkgy6Jjwa(EpCLIfB3VZcWNukVzrt134zb2S82frSGWwbw8cKLcYcW3BfSb1ml22PILcYcW37HRuSCywwwSaBwEilwnmWcczPWEZITDQyX1HaiwIcPXYwXiKjWMLFNyH8wLIfeYsH9MfRggybG3NRRiwomlFVOPSaBwCql)paelyBENWYUJzjIqaMcywAkXV6kuSaBwomlxXYqDO2)yGH(EQppg4ewExr1BWpPuENb7B8gQCDfbYY8mly6Z6WAHn)rTDrugHTcSmLfTSyplVRO6n43BfSbnu56kcKfTSOVgdd(9E4kLPPrt4DxxrSOLf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKfTSmHf91yyS6lb2GNRYEh86czRLc7TbGRwelBgjl2H(0yrll2ZI(AmmbpFvWSSyrlltybG3NRRiJJTYGRelwMNzrFnggKUcSjWmLybTrDcvFMkQrDrLmllwMNzbG3NRRiJvddzRLc7DM8wLILPSmpZYewcqau51Bkk0qfSbzrllVRO6n4NukVZG9nEdvUUIazrlltybe(gh0T(daLX28ojd6jokY0uIFfMLnzjIyzEMfp8hSmoOB9hakJT5Dsg0tCuK5Q8qDO2FwMYYuwMYIwwMWsacvGqBLj45RcMMs8RWSSjlAKglZZSeGqfi0wzcWcaejk)7ugBD99yttj(vyw2KfnsJLPXF8wSdHgh9yGu56kcmoDXa9WFWkgi(9gVAuumqqch6Z6pyfdutTsSWSSvmcHfDAaBIfKblaqKiww4RqXYVtSGmybaIeXsawG3FWILhYsyNciXYnybzWcaejILdZIh(LRuPyX1HRNLhYIoXsWXFmWqFp1NhdeG3NRRiJvddzRLc7DM8wLk(J3IDruC0JbsLRRiW40fd0d)bRyGfzlNaHvmqqch6Z6pyfdm9XelAAqyHzX2ovSKcUyXBIfxhUEwEiA9Myj4wwxHILWU3OimlEbYsIJeXcE1el)oLIfVjwUIfVybDcQZctSG)tPyzaBwqoxtdTiFnTyGH(EQppgOBLd7uajw0YYewc7EJIWSejl2XIwwAkS7nkk)xcXcIyb9SmpZsy3BueMLizjcSmn(J3IDrH4OhdKkxxrGXPlgyOVN6ZJb6w5WofqIfTSmHLWU3OimlrYIDSOLLMc7EJIY)LqSGiwqplZZSe29gfHzjswIaltzrlltyrFnggkOolmLvRYBttj(vyw2KfcXuy9u(VeIL5zw0xJHHcQZctzmu5TPPe)kmlBYcHykSEk)xcXY0yGE4pyfdC3vJCcewXF8wIqAXrpgivUUIaJtxmWqFp1Nhd0TYHDkGelAzzclHDVrrywIKf7yrllnf29gfL)lHybrSGEwMNzjS7nkcZsKSebwMYIwwMWI(AmmuqDwykRwL3MMs8RWSSjleIPW6P8FjelZZSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeILPXa9WFWkg4yPu5eiSI)4TebnIJEmqQCDfbgNUyGE4pyfde)EJxnkkgiiHd9z9hSIbM(yIfGV34vJIyrtVOFNfRggWS4filGRelw2kgHWITDQybzBfTPxf0mlOtIf0g1SKoybQzw(DILOOu97PAw0xJblhMfxhUEwEildxPybogSaBwsbxBdYsWTyzRyesmWqFp1NhdKcQZctMRYELIfTSmHf91yyGf974CqrENbC4dwMLflZZSOVgddsxb2eyMsSG2OoHQptf1OUOsMLflZZSOVgdtWZxfmllw0YYewSNLaeavE9gKs1NxSmpZsacvGqBLHsSG2OoRdlqttj(vyw2Kf0ZY8ml6RXWe88vbttj(vywqelOcGMehXSenwgkiSzzclo(BxLTG2OMf0YcaVpxxrgmohG4NLPSmLfTSmHf7zjabqLxVbav)EQML5zw0xJHPDaubx48OPkQPmnL4xHzbrSGkaAsCeZs0yjqNILjSmHfh)TRYwqBuZccybHtJLOXY7kQEZy1PYWrMuRImu56kcKLPSGwwa4956kYGX5ae)SmLfeWseyjAS8UIQ3uKTCcewgQCDfbYIwwSNLEv0a2Oid(QXsL3tHFQp3qLRRiqw0YI(AmmTdGk4cNhnvrnLzzXY8ml6RXW0oaQGlCE0uf1uz8vJLkVNc)uFUzzXY8mltyrFngM2bqfCHZJMQOMY0uIFfMfeXIh(dwg8794AYqiMcRNY)LqSOLfSfPu5Dh)eliIL0mimlZZSOVgdt7aOcUW5rtvutzAkXVcZcIyXd)blJT2)DdHykSEk)xcXY8mla8(CDfzUigmhGf49hSyrllbiubcTvMRWHE9UUIYr8YRFLKbjaxGmn5GPyrllueVollc0Cfo0R31vuoIxE9RKmib4celtzrll6RXW0oaQGlCE0uf1uMLflZZSypl6RXW0oaQGlCE0uf1uMLflAzXEwcqOceARmTdGk4cNhnvrnLPjhmfltzzEMfaEFUUImo2kdUsSyzEMfDigZIwwghQ9p3uIFfMfeXcQaOjXrmlrJLaDkwMWIJ)2vzlOnQzbTSaW7Z1vKbJZbi(zzkltJ)4Teb7IJEmqQCDfbgNUyGE4pyfde)EJxnkkgiiHd9z9hSIbg9oflpKLehjILFNyrNWplWblaFVvWgKf9uSGFpG0vOy5EwwwSeXRlGKkflxXIxPybDcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceymWqFp1Nhd8DfvVb)ERGnOHkxxrGSOLf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKfTSmHf91yyWV3kydAwwSmpZIJ)2vzlOnQzztwIcPXYuw0YI(Amm43BfSbn43diXcIyjcSOLLjSOVgddfuNfMYyOYBZYIL5zw0xJHHcQZctz1Q82SSyzklAzrFnggR(sGn45QS3bVUq2APWEBa4QfXcIyXoeAASOLLjSeGqfi0wzcE(QGPPe)kmlBYIgPXY8ml2ZcaVpxxrMaSaarIYGeovfyrllbiaQ86n1HA)ZdNyzA8hVLieH4OhdKkxxrGXPlgi0kgiM(yGE4pyfdeG3NRROyGaC1IIbsb1zHjZvz1Q8MLOXseXcAzXd)bld(9ECnzietH1t5)siwqal2ZcfuNfMmxLvRYBwIgltyb5Xccy5DfvVbdxQmCK)DkpGnHFdvUUIazjASebwMYcAzXd)blJT2)DdHykSEk)xcXccyjndcJEwqllylsPY7o(jwqalPzqplrJL3vu9MY)vt4SUR8kqgQCDfbgdeKWH(S(dwXarh8Fj(tyw2H2yjzf2zzRyeclEtSGYVIazXIAwWuawGgw00lvkwEhjcZIZcUCl8o8zzaBw(DILWQBQEwW3V8)Gflyil2GlfyT9ZIoXIhcR2FILbSzr5nkQz5VeA0EcHJbcW7C5jumqhBHqOgifI)4Tebeoo6XaPY1veyC6Ib6H)Gvmq87nE1OOyGGeo0N1FWkgOMALyXcW3B8QrrSCflEXc6euNfMyXXSGHWIfhZIfeJpDfXIJzrbluS4ywsbxSy7ukwOcKLLfl2UFNLikneWITDQyHQN6RqXYVtSueIFwqNG6SWKMzbewB)SOONL7zXQHbwqilf2BnZciS2(zbcGAB99elEXIMEr)olwnmWIxGSybHkw0PbSjwq2wrB6vbw8cKf0jXcAJAwshSaJbg67P(8yG2ZsVkAaBuK5VeYgSRmytEI(vGuBOY1veilAzzcl6RXWy1xcSbpxL9o41fYwlf2BdaxTiwqel2HqtJL5zw0xJHXQVeydEUk7DWRlKTwkS3gaUArSGiwSd9PXIwwExr1BWpPuENb7B8gQCDfbYYuw0YYewOG6SWK5QmgQ8MfTS44VDv2cAJAwqala8(CDfzCSfcHAGuGLOXI(AmmuqDwykJHkVnnL4xHzbbSacFZy1PYWrMuRIm)fqcNBkXVILOXIDg0ZYMSerPXY8mluqDwyYCvwTkVzrllo(BxLTG2OMfeWcaVpxxrghBHqOgifyjASOVgddfuNfMYQv5TPPe)kmliGfq4BgRovgoYKAvK5Vas4Ctj(vSenwSZGEw2KLOqASmLfTSypl6RXWal63XzlQdK1FWYSSyrll2ZY7kQEd(9wbBqdvUUIazrlltyjaHkqOTYe88vbttj(vyw2KfeklZZSGHlL(vGMFVpLkJjcjQnu56kcKfTSOVgdZV3NsLXeHe1g87bKybrSeHiWIMWYew6vrdyJIm4RglvEpf(P(CdvUUIazjASyhltzrllJd1(NBkXVcZYMSOrAPXIwwghQ9p3uIFfMfeXIDPLglZZSa2Rd0uWCaeZYuw0YYewSNLaeavE9gKs1NxSmpZsacvGqBLHsSG2OoRdlqttj(vyw2Kf7yzA8hVLiG(4OhdKkxxrGXPlgOh(dwXalYwobcRyGGeo0N1FWkgy6Jjw00GWcZYvS4vkwqNG6SWelEbYc2bqSGCURgia5Vukw00GWILbSzbzBfTPxfyXlqwIIDfytGSGojwqBuNq1ByzRkmKLfMyzlAAS4filiFnnw8NLFNyHkqwGdwq(nvrnflEbYciS2(zrrplAQM8e9RaPMLHRuSahJyGH(EQppgOBLd7uajw0YcaVpxxrgSdGYdyNdE(QalAzzcl6RXWqb1zHPSAvEBAkXVcZYMSqiMcRNY)LqSmpZI(AmmuqDwykJHkVnnL4xHzztwietH1t5)siwMg)XBjciV4OhdKkxxrGXPlgyOVN6ZJb6w5WofqIfTSaW7Z1vKb7aO8a25GNVkWIwwMWI(AmmuqDwykRwL3MMs8RWSSjleIPW6P8FjelZZSOVgddfuNfMYyOYBttj(vyw2KfcXuy9u(VeILPSOLLjSOVgdtWZxfmllwMNzrFnggR(sGn45QS3bVUq2APWEBa4QfXcIIKf70inwMYIwwMWI9SeGaOYR3aGQFpvZY8ml6RXW0oaQGlCE0uf1uMMs8RWSGiwMWc6zrtyXowIgl9QObSrrg8vJLkVNc)uFUHkxxrGSmLfTSOVgdt7aOcUW5rtvutzwwSmpZI9SOVgdt7aOcUW5rtvutzwwSmLfTSmHf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKL5zwietH1t5)siwqel6RXW8xczd2vgSjpr)kqQnnL4xHzzEMf7zrFngM)siBWUYGn5j6xbsTzzXY0yGE4pyfdC3vJCcewXF8wIacno6XaPY1veyC6Ibg67P(8yGUvoStbKyrlla8(CDfzWoakpGDo45RcSOLLjSOVgddfuNfMYQv5TPPe)kmlBYcHykSEk)xcXY8ml6RXWqb1zHPmgQ820uIFfMLnzHqmfwpL)lHyzklAzzcl6RXWe88vbZYIL5zw0xJHXQVeydEUk7DWRlKTwkS3gaUArSGOizXonsJLPSOLLjSyplbiaQ86niLQpVyzEMf91yyq6kWMaZuIf0g1ju9zQOg1fvYSSyzklAzzcl2ZsacGkVEdaQ(9unlZZSOVgdt7aOcUW5rtvutzAkXVcZcIyb9SOLf91yyAhavWfopAQIAkZYIfTSypl9QObSrrg8vJLkVNc)uFUHkxxrGSmpZI9SOVgdt7aOcUW5rtvutzwwSmLfTSmHf7zPxfnGnkY8xczd2vgSjpr)kqQnu56kcKL5zwietH1t5)siwqel6RXW8xczd2vgSjpr)kqQnnL4xHzzEMf7zrFngM)siBWUYGn5j6xbsTzzXY0yGE4pyfdCSuQCcewXF8wIqefh9yGu56kcmoDXabjCOpR)GvmW0htSGCarhwGflbWyGE4pyfd0M39b7mCKj1QO4pElrikeh9yGu56kcmoDXa9WFWkgi(9ECnfdeKWH(S(dwXatFmXcW37X1elpKfRggybiu5nlOtqDwysZSGSTI20RcSS7ywuegZYFjel)UxS4SGC0(VZcHykSEIffnEwGnlWsLIf0yvEZc6euNfMy5WSSSmSGCC)olr3UiIf7ScSq1tnlolaHkVzbDcQZctSCdwqilf2BwW)PuSS7ywuegZYV7fl2PrASGFpGeMfVazbzBfTPxfyXlqwqgSaarIyz3bqSKaBILF3lw0aHIzbzAkwAkXV6kugwsFmXIRdbqSyh6td5YYUJFIfWvFfkwq(nvrnflEbYID2zhYLLDh)el2UFhUEwq(nvrnvmWqFp1NhdKcQZctMRYQv5nlAzXEw0xJHPDaubx48OPkQPmllwMNzHcQZctgmu5DUie)SmpZYewOG6SWKXRu5Iq8ZY8ml6RXWe88vbttj(vywqelE4pyzS1(VBietH1t5)siw0YI(AmmbpFvWSSyzklAzzcl2ZcM(SoSwyZFuBxeLTZkWY8ml9QObSrrgR(sGn45QS3bVUq2APWEBOY1veilAzrFnggR(sGn45QS3bVUq2APWEBa4QfXcIyXonsJfTSeGqfi0wzcE(QGPPe)kmlBYIgiuw0YYewSNLaeavE9M6qT)5HtSmpZsacvGqBLjalaqKO8VtzS113JnnL4xHzztw0aHYYuw0YYewSNL2dK5BOsXY8mlbiubcTvgDQXuJ0vOmnL4xHzztw0aHYYuwMYY8mluqDwyYCv2RuSOLLjSOVgdJnV7d2z4itQvrMLflZZSGTiLkV74NybrSKMbHrplAzzcl2ZsacGkVEdaQ(9unlZZSypl6RXW0oaQGlCE0uf1uMLfltzzEMLaeavE9gau97PAw0Yc2IuQ8UJFIfeXsAgeMLPXF8wq40IJEmqQCDfbgNUyGGeo0N1FWkgy6JjwqoA)3zb(7uB7Wel22VWolhMLRybiu5nlOtqDwysZSGSTI20RcSaBwEilwnmWcASkVzbDcQZctXa9WFWkgOT2)94pEliSgXrpgivUUIaJtxmqqch6Z6pyfde57k1V3RyGE4pyfdSxv2d)bRS6WFmq1H)C5jumWHRu)EVI)4p(JbcGA8bR4TyxA2zxArin0hd0M31vOWXaro2kYPTKEBb5SOKfwI(oXYLyb7NLbSzzBOfvuVnlnfXRRjqwWWeIfF9We)jqwc7EHIWgEd04kIf7IswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3anUIyjcrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBWBGCSvKtBj92cYzrjlSe9DILlXc2pldyZY2G0WxQFBwAkIxxtGSGHjel(6Hj(tGSe29cfHn8gOXveliVOKfKblau)eilaVeKXcov9oIzb5YYdzbnwolGhGdFWIfOf1(dBwMG2PSmrdep1WBGgxrSG8IswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIDiEQH3anUIybHgLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXsefLSGmybG6Nazb4LGmwWPQ3rmlixwEilOXYzb8aC4dwSaTO2FyZYe0oLLj2H4PgEd04kILikkzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEd04kILOquYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnltIaINA4nqJRiwIcrjlidwaO(jqw2(7RqIEJgg0CBwEilB)9virV51WGMBZYe7q8udVbACfXsuikzbzWca1pbYY2FFfs0BSZGMBZYdzz7VVcj6nVDg0CBwMyhINA4nqJRiw0iTOKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiw0qJOKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiw0WUOKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiw0icrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBGgxrSOb6JswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3anUIyrdKxuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnltSdXtn8gOXvelAG8IswqgSaq9tGSS93xHe9gnmO52S8qw2(7RqIEZRHbn3MLj2H4PgEd04kIfnqErjlidwaO(jqw2(7RqIEJDg0CBwEilB)9virV5TZGMBZYenq8udVbACfXIgi0OKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMyhINA4nqJRiw0aHgLSGmybG6Nazz7VVcj6nAyqZTz5HSS93xHe9MxddAUnlt0aXtn8gOXvelAGqJswqgSaq9tGSS93xHe9g7mO52S8qw2(7RqIEZBNbn3MLj2H4PgEdEdKJTICAlP3wqolkzHLOVtSCjwW(zzaBw22QPamr3)TzPPiEDnbYcgMqS4RhM4pbYsy3lue2WBGgxrSeHOKfKblau)eilB)9virVrddAUnlpKLT)(kKO38AyqZTzzseq8udVbACfXcchLSGmybG6Nazz7VVcj6n2zqZTz5HSS93xHe9M3odAUnltIaINA4nqJRiwqOrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42S4plOJMoAWYenq8udVbVbYXwroTL0BliNfLSWs03jwUely)SmGnlB7qABwAkIxxtGSGHjel(6Hj(tGSe29cfHn8gOXvelAeLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXIDrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBGgxrSyxuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnl(Zc6OPJgSmrdep1WBGgxrSeHOKfKblau)eilB)UIQ3GMBZYdzz73vu9g00qLRRiWTzzIgiEQH3anUIyjcrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42SmjciEQH3anUIyb5fLSGmybG6Nazb4LGmwWPQ3rmlixKllpKf0y5SKabxQfMfOf1(dBwMGCNYYenq8udVbACfXcYlkzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLj2H4PgEd04kIfeAuYcYGfaQFcKfGxcYybNQEhXSGCrUS8qwqJLZsceCPwywGwu7pSzzcYDklt0aXtn8gOXveli0OKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiwIOOKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiwIcrjlidwaO(jqwaEjiJfCQ6DeZcYLLhYcASCwapah(GflqlQ9h2SmbTtzzIDiEQH3anUIyrd7IswqgSaq9tGSa8sqgl4u17iMfKllpKf0y5SaEao8blwGwu7pSzzcANYYenq8udVbACfXIgiCuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gOXvelAG(OKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMObINA4nqJRiw0a5fLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXIgruuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gOXvel2LwuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnltSdXtn8gOXvel2zxuYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMObINA4nqJRiwSdHJswqgSaq9tGSa8sqgl4u17iMfKllpKf0y5SaEao8blwGwu7pSzzcANYYe7q8udVbACfXIDiCuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gOXvel2H8IswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3anUIyXoeAuYcYGfaQFcKLT7vrdyJImO52S8qw2UxfnGnkYGMgQCDfbUnlt0aXtn8gOXvel2ffIswqgSaq9tGSa8sqgl4u17iMfKllpKf0y5SaEao8blwGwu7pSzzcANYYe7q8udVbACfXseslkzbzWca1pbYcWlbzSGtvVJywqUS8qwqJLZc4b4WhSybArT)WMLjODklt0aXtn8g8gihBf50wsVTGCwuYclrFNy5sSG9ZYa2SS9WvQFVxBZstr86AcKfmmHyXxpmXFcKLWUxOiSH3anUIyXUOKfKblau)eilaVeKXcov9oIzb5YYdzbnwolGhGdFWIfOf1(dBwMG2PSmrdep1WBWBGCSvKtBj92cYzrjlSe9DILlXc2pldyZY24FBwAkIxxtGSGHjel(6Hj(tGSe29cfHn8gOXvel2fLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYe0J4PgEd04kILieLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXcchLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXcYlkzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3Mf)zbD00rdwMObINA4nqJRiw0iTOKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMyhINA4nqJRiw0aHJswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3anUIyrdKxuYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMObINA4nqJRiw0a5fLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYe0J4PgEd04kIfnqOrjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBGgxrSOrefLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXIDAeLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXIDiCuYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMGWiEQH3anUIyXoeokzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEd04kIf7qFuYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMObINA4nqJRiwSd9rjlidwaO(jqw2UxfnGnkYGMBZYdzz7Ev0a2OidAAOY1ve42Smrdep1WBGgxrSyhYlkzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEd04kILiOruYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMebep1WBGgxrSebnIswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIgiEQH3anUIyjc2fLSGmybG6Nazz7Ev0a2OidAUnlpKLT7vrdyJImOPHkxxrGBZYenq8udVbACfXseIquYcYGfaQFcKfGxcYybNQEhXSGCz5HSGglNfWdWHpyXc0IA)Hnltq7uwMebep1WBGgxrSebeokzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLj2H4PgEd04kILiG8IswqgSaq9tGSSDVkAaBuKbn3MLhYY29QObSrrg00qLRRiWTzzIDiEQH3anUIyjci0OKfKblau)eilB3RIgWgfzqZTz5HSSDVkAaBuKbnnu56kcCBwMyhINA4nqJRiwIquikzbzWca1pbYY29QObSrrg0CBwEilB3RIgWgfzqtdvUUIa3MLjAG4PgEdEJ0lXc2pbYcYJfp8hSyrD4hB4nIbITOq8w0in7IbA1WXPOyGOl6Ys6CLxbIfnvVoqEd0fDzrtZ7WoliunZIDPzND8g8gOl6YcY29cfHJsEd0fDzrtyzRGGeilaHkVzjDKNy4nqx0LfnHfKT7fkcKL3Bu0NVblbhtywEilHubfLFVrrp2WBGUOllAcliNOeiacKLvvuGWyVtXcaVpxxrywMCgYOzwSAcqg)EJxnkIfnztwSAcGb)EJxnkAQH3aDrxw0ew2ka4bYIvtbh)xHIfKJ2)DwUbl3VnMLFNyXwdluSGob1zHjdVb6IUSOjSOP5irSGmybaIeXYVtSa0667XS4SOU)veljWMyzOieF6kILj3GLuWfl7oyT9ZY(9SCpl4lzPEVi4cRsXIT73zjDA6Bn6SGawqgPi8FUILTQouvcvVMz5(TbzbJ0zn1WBGUOllAclAAoseljq8ZY2Jd1(NBkXVcVnl4avEFqmlULLkflpKfDigZY4qT)ywGLkLH3aDrxw0ewIEt(Zs0HjelWblPt57SKoLVZs6u(oloMfNfSffoxXY3xHe9gEd0fDzrtyrt3IkQzzYziJMzb5O9FxZSGC0(VRzwa(EpUMMYsIdsSKaBILMWN6O6z5HSqERoQzjat09xtWV3VH3aDrxw0ewq(hIzjk2vGnbYc6KybTrDcvplHDkGeldyZcY0uSSWokYWBWBGUOllBTk47pbYs6CLxbILTIqqdwcEXIoXYaUkqw8NL9)TWrjArRUR8kqAc(scgu3VV0nheTPZvEfinb4LGm0MaA2)evu8JtrrQ7kVcK5r8ZBWB4H)Gf2y1uaMO7FKiDfytGzS113J5nqxwI(oXcaVpxxrSCywW0ZYdzjnwSD)olfKf87plWILfMy57RqIESMzrdwSTtfl)oXY4A8ZcSiwomlWILfM0ml2XYny53jwWuawGSCyw8cKLiWYnyrh(7S4nXB4H)Gf2y1uaMO7pcIeTa8(CDfP5YtOiHvEHP83xHe9AgGRwuKPXB4H)Gf2y1uaMO7pcIeTa8(CDfP5YtOiHvEHP83xHe9AgAfPdcQzaUArrQHMVrKFFfs0B0WS748ctz91yO97RqIEJgMaeQaH2kd4Q9)GLw7)(kKO3OH5WMhMqz4iNal83WfohGf(7v4pyH5n8WFWcBSAkat09hbrIwaEFUUI0C5juKWkVWu(7RqIEndTI0bb1maxTOiTtZ3iYVVcj6n2z2DCEHPS(Am0(9virVXotacvGqBLbC1(FWsR9FFfs0BSZCyZdtOmCKtGf(B4cNdWc)9k8hSW8gOllrFNWelFFfs0JzXBILc(S4RhM4)fCLkflG0tHNazXXSalwwyIf87plFFfs0JnSWcq6zbG3NRRiwEilimloMLFNsXIRWqwkIazbBrHZvSS7fO6kugEdp8hSWgRMcWeD)rqKOfG3NRRinxEcfjSYlmL)(kKOxZqRiDqqndWvlksewZ3iskIxNLfbAUch6176kkhXlV(vsgKaCbAEMI41zzrGgkXkvtUkdBWYRanptr86SSiqdgUuk6)RqL7LEkEd0LfG0Jz53jwa(EJxnkILae)SmGnlk)PMLGRclL)hSWSmzaBwie7jwkIfB7uXYdzb)E)SaUsSUcfl60a2eli)MQOMILHRuywGJXuEdp8hSWgRMcWeD)rqKOfG3NRRinxEcfjgNdq8RzaUArrgH0I2en0K0m2fnm9zDyTWM)O2UikJWwHP8gOllaPhZI)SyB)c7S4jWv9SahSSvmcHfKblaqKiwW7WLcKfDILfMaJswq40yX297W1ZcYifH)ZvSa0667XS4filrinwSD)UH3Wd)blSXQPamr3FeejAb4956ksZLNqrgGfaisu2XwAgGRwuKrineOrArRxfnGnkYeifH)ZvzS113J5n8WFWcBSAkat09hbrI2eiSq6Q8a2j8gE4pyHnwnfGj6(JGirRT2)DnRUIYbWi1innFJiNqb1zHjJAvENlcX)8mfuNfMmxLXqL3ZZuqDwyYCvwh(7ZZuqDwyY4vQCri(NYBWBGUSGqAk44Nf7yb5O9FNfVazXzb47nE1OiwGflaJol2UFNLTCO2Fwq(oXIxGSKo4wJolWMfGV3JRjwG)o12omXB4H)Gf2aTOIAeejAT1(VR5Be5ekOolmzuRY7Cri(NNPG6SWK5QmgQ8EEMcQZctMRY6WFFEMcQZctgVsLlcX)uTwnbWOHXw7)Uw7TAcGXoJT2)DEdp8hSWgOfvuJGirl(9ECnPz1vuoagj618nICI99QObSrrgDx5vGYWr2vQ8VFfk88S9biaQ86n1HA)ZdNMNThBrkv(9gf9yd(9E4kvKAmpB)7kQEt5)QjCw3vEfidvUUIaNQ1Em9zDyTWM)O2UikBNvyEEcfuNfMmyOY7Cri(NNPG6SWK5QSAvEpptb1zHjZvzD4Vpptb1zHjJxPYfH4FkVHh(dwyd0IkQrqKOf)EJxnksZQROCams0R5Be5KEv0a2OiJUR8kqz4i7kv(3VcfwBacGkVEtDO2)8WjTylsPYV3OOhBWV3dxPIuJPAThtFwhwlS5pQTlIY2zf4n4nqx0Lf0bXuy9eileaQtXYFjel)oXIhEyZYHzXb4NY1vKH3Wd)blCKyOY7So5j8gE4pyHrqKOn4kv2d)bRS6WVMlpHIeArf1Ag)9f(i1qZ3iY)sienXUO5H)GLXw7)Uj44p)xcHap8hSm437X1Kj44p)xcnL3aDzbi9yw2keDybwSebeWIT73HRNfW(gplEbYIT73zb47Tc2GS4fil2HawG)o12omXB4H)GfgbrIwaEFUUI0C5juKho7qsZaC1IIeBrkv(9gf9yd(9E4k1MAODI9VRO6n43BfSbnu56kcCE(DfvVb)Ks5DgSVXBOY1ve405zSfPu53Bu0Jn437HRuBAhVb6Ycq6XSeuKdGyX2ovSa89ECnXsWlw2VNf7qalV3OOhZIT9lSZYHzPjfbWRNLbSz53jwqNG6SWelpKfDIfRMgu3eilEbYIT9lSZY4ukQz5HSeC8ZB4H)GfgbrIwaEFUUI0C5juKhohuKdG0maxTOiXwKsLFVrrp2GFVhxtBQbVb6YsuuVpxxrS87(ZsyNciHz5gSKcUyXBILRyXzbvaKLhYIdaEGS87el47x(FWIfB7utS4S89virpl0hy5WSSWeilxXIo92iQyj44hZB4H)GfgbrIwaEFUUI0C5juKxLrfa1maxTOiTAcqgva0OHjbcRX108SvtaYOcGgnm4vnUMMNTAcqgva0OHb)EJxnkAE2QjazubqJgg879WvQ5zRMaKrfanAygRovgoYKAv08SvtamTdGk4cNhnvrn18S(AmmbpFvW0uIFfos91yycE(QGbC1(FWAEgG3NRRiZHZoK4nqxwsFmXs6OgtnsxHIf)z53jwOcKf4GfKFtvutXITDQyz3XpXYHzX1HaiwqEPHC1ml(4PMfKblaqKiwSD)olPd6rNfVazb(7uB7Wel2UFNfKTv0MEvG3Wd)blmcIeT6uJPgPRqP5Be5Kj2hGaOYR3uhQ9ppCAE2(aeQaH2ktawaGir5FNYyRRVhBwwZZ23RIgWgfz0DLxbkdhzxPY)(vOWt1QVgdtWZxfmnL4xH3ud0RvFngM2bqfCHZJMQOMY0uIFfgriSw7dqau51Baq1VNQNNdqau51Baq1VNQ1QVgdtWZxfmllT6RXW0oaQGlCE0uf1uMLL2j6RXW0oaQGlCE0uf1uMMs8RWiksnSttq4O1RIgWgfzWxnwQ8Ek8t95ZZ6RXWe88vbttj(vyePHgZZAGCXwKsL3D8tisddYB6uTa8(CDfzUkJkaYBGUSGqGpl2UFNfNfKTv0MEvGLF3FwoCT9ZIZcczPWEZIvddSaBwSTtfl)oXY4qT)SCywCD46z5HSqfiVHh(dwyeejATG)blnFJiNOVgdtWZxfmnL4xH3ud0RDI99QObSrrg8vJLkVNc)uF(8S(AmmTdGk4cNhnvrnLPPe)kmI0ikOvFngM2bqfCHZJMQOMYSSMopRdXyTJd1(NBkXVcJi7q)uTa8(CDfzUkJkaYBGUSGmxfwk)jml22PFNAww4RqXcYGfaiself0gl2oLIfxPG2yjfCXYdzb)NsXsWXpl)oXc2tiw8e4QEwGdwqgSaarIqaY2kAtVkWsWXpM3Wd)blmcIeTa8(CDfP5YtOidWcaejkds4uvqZaC1IImqNAYKXHA)ZnL4xH1enqVMeGqfi0wzcE(QGPPe)k8uKRgruAtJmqNAYKXHA)ZnL4xH1enqVMeGqfi0wzcWcaejk)7ugBD99yd4Q9)GLMeGqfi0wzcWcaejk)7ugBD99yttj(v4PixnIO0MQ1(2pWmbGQ34GGydH4d)yTtSpaHkqOTYe88vbttoyQ5z7dqOceARmbybaIezAYbtnDEoaHkqOTYe88vbttj(v4nV6P2cQ8NaZJd1(NBkXVcpp3RIgWgfzcKIW)5Qm2667XAdqOceARmbpFvW0uIFfEZiK28CacvGqBLjalaqKO8VtzS113JnnL4xH38QNAlOYFcmpou7FUPe)kSMOrAZZ2hGaOYR3uhQ9ppCI3aDzj9XeilpKfqs5Py53jwwyhfXcCWcY2kAtVkWITDQyzHVcflGWLUIybwSSWelEbYIvtaO6zzHDuel22PIfVyXbbzHaq1ZYHzX1HRNLhYc4r8gE4pyHrqKOfG3NRRinxEcfzamhGf49hS0maxTOiN8EJIEZFju(HzWJ2ud0pp3(bMjau9gheeBUAt0N2uTtMqr86SSiqdLyLQjxLHny5vG0oX(aeavE9gau97P655aeQaH2kdLyLQjxLHny5vGmnL4xHrKgipekcMG(O1RIgWgfzWxnwQ8Ek8t95tNQ1(aeQaH2kdLyLQjxLHny5vGmn5GPMoptr86SSiqdgUuk6)RqL7LEkTtSpabqLxVPou7FE408CacvGqBLbdxkf9)vOY9spvocim6JO00W0uIFfgrAObcpDEEsacvGqBLrNAm1iDfkttoyQ5z7BpqMVHk18CacGkVEtDO2)8WPPANy)7kQEZy1PYWrMuRImu56kcCEoabqLxVbav)EQwBacvGqBLzS6uz4itQvrMMs8RWisdnqa6JwVkAaBuKbF1yPY7PWp1NppBFacGkVEdaQ(9uT2aeQaH2kZy1PYWrMuRImnL4xHrK(AmmbpFvWaUA)pyHanSlA9QObSrrgR(sGn45QS3bVUq2APWERjAy3uTtOiEDwweO5kCOxVRROCeV86xjzqcWfiTbiubcTvMRWHE9UUIYr8YRFLKbjaxGmnL4xHre6NoppzcfXRZYIan4DheAJaZWwpdh5h2ju9AdqOceARmpStO6jW8v4d1(NJa6rFeStdttj(v4PZZtMaW7Z1vKbw5fMYFFfs0hPgZZa8(CDfzGvEHP83xHe9rgHPAN89virVrdttoyQCacvGqB1883xHe9gnmbiubcTvMMs8RWBE1tTfu5pbMhhQ9p3uIFfwt0iTPZZa8(CDfzGvEHP83xHe9rAN2jFFfs0BSZ0KdMkhGqfi0wnp)9virVXotacvGqBLPPe)k8Mx9uBbv(tG5XHA)ZnL4xH1ensB68maVpxxrgyLxyk)9virFKPnD6uEd0LLOOEFUUIyzHjqwEilGKYtXIxPy57RqIEmlEbYsaeZITDQyXMF)vOyzaBw8If0zzTd7ZzXQHbEdp8hSWiis0cW7Z1vKMlpHI837tPYyIqI6Sn)EndWvlks7XWLs)kqZV3NsLXeHe1gQCDfboppou7FUPe)k8M2LwAZZ6qmw74qT)5Ms8RWiYo0JGjiCAAI(Amm)EFkvgtesuBWVhqkA2nDEwFngMFVpLkJjcjQn43diTzeIinzsVkAaBuKbF1yPY7PWp1Nhn7MYBGUSK(yIf0jXkvtUIfn9gS8kqSyxAykGzrNgWMyXzbzBfTPxfyzHjwGnlyil)U)SCpl2oLIf1velllwSD)ol)oXcvGSahSG8BQIAkEdp8hSWiis0UWu(EkrZLNqrsjwPAYvzydwEfinFJidqOceARmbpFvW0uIFfgr2LM2aeQaH2ktawaGir5FNYyRRVhBAkXVcJi7st7eaEFUUIm)EFkvgtesuNT53ppRVgdZV3NsLXeHe1g87bK2mcPHGj9QObSrrg8vJLkVNc)uFE0IW0PAb4956kYCvgvaCEwhIXAhhQ9p3uIFfgrraHYBGUSK(yIfGWLsr)vOyb50spflipmfWSOtdytS4SGSTI20RcSSWelWMfmKLF3FwUNfBNsXI6kILLfl2UFNLFNyHkqwGdwq(nvrnfVHh(dwyeejAxykFpLO5YtOiXWLsr)FfQCV0tP5Be5KaeQaH2ktWZxfmnL4xHreYtR9biaQ86naO63t1ATpabqLxVPou7FE408CacGkVEtDO2)8WjTbiubcTvMaSaarIY)oLXwxFp20uIFfgripTta4956kYeGfaisugKWPQW8CacvGqBLj45RcMMs8RWic5nDEoabqLxVbav)EQw7e77vrdyJIm4RglvEpf(P(CTbiubcTvMGNVkyAkXVcJiK38S(AmmTdGk4cNhnvrnLPPe)kmI0inemb9rJI41zzrGMRWFVcpSXzWdWvuwNuQPA1xJHPDaubx48OPkQPmlRPZZ6qmw74qT)5Ms8RWiYo0pptr86SSiqdLyLQjxLHny5vG0gGqfi0wzOeRun5QmSblVcKPPe)k8M2L2uTa8(CDfzUkJkaQ1EkIxNLfbAUch6176kkhXlV(vsgKaCbAEoaHkqOTYCfo0R31vuoIxE9RKmib4cKPPe)k8M2L28SoeJ1oou7FUPe)kmISlnEd0LLTQS5PWSSWelPxuKAkwSD)oliBROn9QalWMf)z53jwOcKf4GfKFtvutXB4H)GfgbrIwaEFUUI0C5juKxedMdWc8(dwAgGRwuK6RXWe88vbttj(v4n1a9ANyFVkAaBuKbF1yPY7PWp1NppRVgdt7aOcUW5rtvutzAkXVcJOi1a9g0JGjrWG(OPVgdJUccbvl8BwwtrWee2GEnjcg0hn91yy0vqiOAHFZYAA0OiEDwweO5k83RWdBCg8aCfL1jLcbiSb9rBcfXRZYIan)oLhxJ)m(qDkTbiubcTvMFNYJRXFgFOovocipeQDiSgMMs8RWiks7sBQw91yyAhavWfopAQIAkZYA68SoeJ1oou7FUPe)kmISd9ZZueVollc0qjwPAYvzydwEfiTbiubcTvgkXkvtUkdBWYRazAkXVcZB4H)GfgbrI2fMY3tjAU8ekYRWHE9UUIYr8YRFLKbjaxG08nIeG3NRRiZfXG5aSaV)GLwaEFUUImxLrfa5nqxwsFmXcWDheAJazrtV1zrNgWMybzBfTPxf4n8WFWcJGir7ct57PenxEcfjE3bH2iWmS1ZWr(HDcvVMVrKtcqOceARmbpFvW0KdMsR9biaQ86n1HA)ZdN0cW7Z1vK537tPYyIqI6Sn)ETtcqOceARm6uJPgPRqzAYbtnpBF7bY8nuPMophGaOYR3uhQ9ppCsBacvGqBLjalaqKO8VtzS113Jnn5GP0obG3NRRitawaGirzqcNQcZZbiubcTvMGNVkyAYbtnDQwq4BWRACnz(lG0vO0obe(g8tkL35HYBY8xaPRqnpB)7kQEd(jLY78q5nzOY1ve48m2IuQ87nk6Xg8794AAZimvli8njqynUMm)fq6kuANaW7Z1vK5WzhsZZ9QObSrrgDx5vGYWr2vQ8VFfk88SJ)2vzlOnQ3mYOqAZZa8(CDfzcWcaejkds4uvyEwFnggDfecQw43SSMQ1EkIxNLfbAUch6176kkhXlV(vsgKaCbAEMI41zzrGMRWHE9UUIYr8YRFLKbjaxG0gGqfi0wzUch6176kkhXlV(vsgKaCbY0uIFfEZiKMw71xJHj45RcML18SoeJ1oou7FUPe)kmIq404nqxwI((Hz5WS4S0(VtnlKY1HT)el28uS8qwsCKiwCLIfyXYctSGF)z57RqIEmlpKfDIf1veilllwSD)oliBROn9QalEbYcYGfaiselEbYYctS87el2vGSGvWNfyXsaKLBWIo83z57RqIEmlEtSalwwyIf87plFFfs0J5n8WFWcJGir7ct57PeSMXk4JJ87RqIEn08nICcaVpxxrgyLxyk)9virV9rQHw7)(kKO3yNPjhmvoaHkqOTAEEcaVpxxrgyLxyk)9virFKAmpdW7Z1vKbw5fMYFFfs0hzeMQDI(AmmbpFvWSS0oX(aeavE9gau97P65z91yyAhavWfopAQIAkttj(vyemjcg0hTEv0a2Oid(QXsL3tHFQpFkII87RqIEJgg91yKbxT)hS0QVgdt7aOcUW5rtvutzwwZZ6RXW0oaQGlCE0uf1uz8vJLkVNc)uFUzznDEoaHkqOTYe88vbttj(vyey3MFFfs0B0WeGqfi0wzaxT)hS0AV(AmmbpFvWSS0oX(aeavE9M6qT)5HtZZ2dW7Z1vKjalaqKOmiHtvHPATpabqLxVbPu9518CacGkVEtDO2)8WjTa8(CDfzcWcaejkds4uvqBacvGqBLjalaqKO8VtzS113JnllT2hGqfi0wzcE(QGzzPDYe91yyOG6SWuwTkVnnL4xH3uJ0MN1xJHHcQZctzmu5TPPe)k8MAK2uT23RIgWgfz0DLxbkdhzxPY)(vOWZZt0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqks0ppRVgdJUR8kqz4i7kv(3Vcfo7DWlYGFpGuKr00PZZ6RXWG0vGnbMPelOnQtO6ZurnQlQKzznDEwhIXAhhQ9p3uIFfgr2L28maVpxxrgyLxyk)9virFKPnvlaVpxxrMRYOcG8gE4pyHrqKODHP89ucwZyf8Xr(9virVDA(grobG3NRRidSYlmL)(kKO3(iTtR9FFfs0B0W0KdMkhGqfi0wnpdW7Z1vKbw5fMYFFfs0hPDANOVgdtWZxfmllTtSpabqLxVbav)EQEEwFngM2bqfCHZJMQOMY0uIFfgbtIGb9rRxfnGnkYGVASu59u4N6ZNIOi)(kKO3yNrFngzWv7)blT6RXW0oaQGlCE0uf1uML18S(AmmTdGk4cNhnvrnvgF1yPY7PWp1NBwwtNNdqOceARmbpFvW0uIFfgb2T53xHe9g7mbiubcTvgWv7)blT2RVgdtWZxfmllTtSpabqLxVPou7FE408S9a8(CDfzcWcaejkds4uvyQw7dqau51BqkvFEPDI96RXWe88vbZYAE2(aeavE9gau97P6PZZbiaQ86n1HA)ZdN0cW7Z1vKjalaqKOmiHtvbTbiubcTvMaSaarIY)oLXwxFp2SS0AFacvGqBLj45RcMLL2jt0xJHHcQZctz1Q820uIFfEtnsBEwFnggkOolmLXqL3MMs8RWBQrAt1AFVkAaBuKr3vEfOmCKDLk)7xHcppprFnggDx5vGYWr2vQ8VFfkCU8F1Kb)EaPir)8S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asrgrtNoDEwFnggKUcSjWmLybTrDcvFMkQrDrLmlR5zDigRDCO2)Ctj(vyezxAZZa8(CDfzGvEHP83xHe9rM2uTa8(CDfzUkJkaYBGUSK(ycZIRuSa)DQzbwSSWel3tjywGflbqEdp8hSWiis0UWu(EkbZBGUSGo3VtnlOGSC1dz53jwWplWMfhsS4H)GflQd)8gE4pyHrqKOTxv2d)bRS6WVMlpHI0HKMXFFHpsn08nIeG3NRRiZHZoK4n8WFWcJGirBVQSh(dwz1HFnxEcfj(5n4nqxwqMRclL)eMfB70Vtnl)oXIMQjpj4FyNAw0xJbl2oLILHRuSahdwSD)(vS87elfH4NLGJFEdp8hSWghsrcW7Z1vKMlpHIeSjpjB7uQ8WvQmCm0maxTOi7vrdyJIm)Lq2GDLbBYt0VcKATt0xJH5VeYgSRmytEI(vGuBAkXVcJiubqtIJyeKMrJ5z91yy(lHSb7kd2KNOFfi1MMs8RWiYd)bld(9ECnzietH1t5)sieKMrdTtOG6SWK5QSAvEpptb1zHjdgQ8oxeI)5zkOolmz8kvUie)tNQvFngM)siBWUYGn5j6xbsTzzXBGUSGmxfwk)jml22PFNAwa(EJxnkILdZIny)7SeC8FfkwGaOMfGV3JRjwUIf0yvEZc6euNfM4n8WFWcBCiHGirlaVpxxrAU8ekYdvbBkJFVXRgfPzaUArrApfuNfMmxLXqL3AXwKsLFVrrp2GFVhxtBIq1K3vu9gmCPYWr(3P8a2e(nu56kcmA2HakOolmzUkRd)DT23RIgWgfzS6lb2GNRYEh86czRLc7Tw77vrdyJImWI(DCoOiVZao8blEd0LL0htSGmybaIeXITDQyXFwuegZYV7flOpnw2kgHWIxGSOUIyzzXIT73zbzBfTPxf4n8WFWcBCiHGirBawaGir5FNYyRRVhR5BeP9G96anfmhaXANmbG3NRRitawaGirzqcNQcATpaHkqOTYe88vbttoyQ5z91yycE(QGzznv7e91yyOG6SWuwTkVnnL4xH3e9ZZ6RXWqb1zHPmgQ820uIFfEt0pv7eh)TRYwqBuJi0NM2jylsPYV3OOhBWV3JRPnJW8S(AmmbpFvWSSMopBFVkAaBuKXQVeydEUk7DWRlKTwkS3t1oX(3vu9g8tkL3zW(g)8S(Amm437HRuMMs8RWisdd61K0mOpA9QObSrrMaPi8FUkJTU(E88S(AmmbpFvW0uIFfgr6RXWGFVhUszAkXVcJa0RvFngMGNVkywwt1oX(Ev0a2OiJUR8kqz4i7kv(3VcfEEwFnggDx5vGYWr2vQ8VFfkCU8F1Kb)EaPnJW8S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asBgHPZZ6qmw74qT)5Ms8RWisJ00gGqfi0wzcE(QGPPe)k8MOFkVb6Ys6JjwaUQX1elxXILxGuYfybwS4vQF)kuS87(ZI6aqyw0aHXuaZIxGSOimMfB3VZscSjwEVrrpMfVazXFw(DIfQazboyXzbiu5nlOtqDwyIf)zrdeMfmfWSaBwuegZstj(vxHIfhZYdzPGpl7oGRqXYdzPPrt4Dwax9vOybnwL3SGob1zHjEdp8hSWghsiis0Ix14AsZHubfLFVrrposn08nICstJMW7UUIMN1xJHHcQZctzmu5TPPe)kmIIGwkOolmzUkJHkV12uIFfgrAGWAFxr1BWWLkdh5FNYdyt43qLRRiWPAFVrrV5Vek)Wm4rBQbcRjylsPYV3OOhJGMs8RWANqb1zHjZvzVsnp3uIFfgrOcGMehXt5nqxwsFmXcWvnUMy5HSS7aiwCwqPG6UILhYYctSKErrQP4n8WFWcBCiHGirlEvJRjnFJib4956kYCrmyoalW7pyPnaHkqOTYCfo0R31vuoIxE9RKmib4cKPjhmLwkIxNLfbAUch6176kkhXlV(vsgKaCbsRBLd7uajEd0LLOyezXYYIfGV3dxPyXFwCLIL)simlRsrymll8vOybnsf82XS4fil3ZYHzX1HRNLhYIvddSaBwu0ZYVtSGTOW5kw8WFWIf1vel6KcAJLDVavelAQM8e9RaPMfyXIDS8EJIEmVHh(dwyJdjeejAXV3dxP08nI0(3vu9g8tkL3zW(gVHkxxrGANypM(SoSwyZFuBxeLryRW8mfuNfMmxL9k18m2IuQ87nk6Xg879WvQnJWuTt0xJHb)EpCLY00Oj8URRiTtWwKsLFVrrp2GFVhUsHOimpBFVkAaBuK5VeYgSRmytEI(vGupDE(DfvVbdxQmCK)DkpGnHFdvUUIa1QVgddfuNfMYyOYBttj(vyefbTuqDwyYCvgdvERvFngg879Wvkttj(vyeHq1ITiLk)EJIESb)EpCLAZir4PANyFVkAaBuKrLk4TJZdfr)vOYOuxIfMMN)lHqUixeg9BQVgdd(9E4kLPPe)kmcSBQ23Bu0B(lHYpmdE0MON3aDzb54(Dwa(Ks5nlAQ(gpllmXcSyjaYITDQyPPrt4DxxrSOVEwW)PuSyZVNLbSzbnsf82XSy1WalEbYciS2(zzHjw0PbSjwqMMcByb4FkfllmXIonGnXcYGfaisel4Rcel)U)Sy7ukwSAyGfVG)o1Sa89E4kfVHh(dwyJdjeejAXV3dxP08nI8DfvVb)Ks5DgSVXBOY1veOw91yyWV3dxPmnnAcV76ks7e7X0N1H1cB(JA7IOmcBfMNPG6SWK5QSxPMNXwKsLFVrrp2GFVhUsTjcpv7e77vrdyJImQubVDCEOi6VcvgL6sSW088FjeYf5IWOFteEQ23Bu0B(lHYpmdE0MrG3aDzb54(Dw0un5j6xbsnllmXcW37HRuS8qwqIilwwwS87el6RXGf9uS4kmKLf(kuSa89E4kflWIf0ZcMcWceZcSzrrymlnL4xDfkEdp8hSWghsiis0IFVhUsP5BezVkAaBuK5VeYgSRmytEI(vGuRfBrkv(9gf9yd(9E4k1MrgbTtSxFngM)siBWUYGn5j6xbsTzzPvFngg879WvkttJMW7UUIMNNaW7Z1vKbSjpjB7uQ8WvQmCm0orFngg879Wvkttj(vyefH5zSfPu53Bu0Jn437HRuBAN23vu9g8tkL3zW(gVHkxxrGA1xJHb)EpCLY0uIFfgrOF60P8gOlliZvHLYFcZITD63PMfNfGV34vJIyzHjwSDkflbFHjwa(EpCLILhYYWvkwGJHMzXlqwwyIfGV34vJIy5HSGerwSOPAYt0VcKAwWVhqILLLHLiknwoml)oXstr86AcKLTIriS8qwco(zb47nE1Oiea89E4kfVHh(dwyJdjeejAb4956ksZLNqrIFVhUsLTbRppCLkdhdndWvlksh)TRYwqBuVzeLw0MOHMGPpRdRf28h12frz7ScrlnJDtJ2en0e91yy(lHSb7kd2KNOFfi1g87bKIwAgnMQjt0xJHb)EpCLY0uIFfoAra5ITiLkV74NIM9VRO6n4NukVZG9nEdvUUIaNQjtcqOceARm437HRuMMs8RWrlcixSfPu5Dh)u0Exr1BWpPuENb7B8gQCDfbovtMOVgdZy1PYWrMuRImnL4xHJg6NQDI(Amm437HRuML18CacvGqBLb)EpCLY0uIFfEkVb6Ys6Jjwa(EJxnkIfB3VZIMQjpr)kqQz5HSGerwSSSy53jw0xJbl2UFhUEwuq8vOyb479Wvkwww)LqS4fillmXcW3B8QrrSalwqyeWs6GBn6SGFpGeMLv9NIfeML3Bu0J5n8WFWcBCiHGirl(9gVAuKMVrKa8(CDfzaBYtY2oLkpCLkdhdTa8(CDfzWV3dxPY2G1NhUsLHJHw7b4956kYCOkytz87nE1OO55j6RXWO7kVcugoYUsL)9RqHZL)RMm43diTzeMN1xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqAZimvl2IuQ87nk6Xg879WvkeHWAb4956kYGFVhUsLTbRppCLkdhdEd0LL0htSGT5Dclyil)U)SKcUybf9SK4iMLL1Fjel6PyzHVcfl3ZIJzr5pXIJzXcIXNUIybwSOimMLF3lwIal43diHzb2SefXc)SyBNkwIacyb)EajmleITUM4n8WFWcBCiHGirRd6w)bGYyBENO5qQGIYV3OOhhPgA(grA)FbKUcLw79WFWY4GU1FaOm2M3jzqpXrrMRYd1HA)NNbHVXbDR)aqzSnVtYGEIJIm43diHOiOfe(gh0T(daLX28ojd6jokY0uIFfgrrG3aDzb5enAcVZIMgewJRjwUbliBROn9QalhMLMCWuAMLFNAIfVjwuegZYV7flONL3Bu0Jz5kwqJv5nlOtqDwyIfB3VZcq4J81mlkcJz539IfnsJf4VtTTdtSCflELIf0jOolmXcSzzzXYdzb9S8EJIEml60a2elolOXQ8Mf0jOolmzyrtbRTFwAA0eENfWvFfkwIIDfytGSGojwqBuNq1ZYQuegZYvSaeQ8Mf0jOolmXB4H)Gf24qcbrI2eiSgxtAoKkOO87nk6XrQHMVrKnnAcV76ks77nk6n)Lq5hMbpAZjt0aHrWeSfPu53Bu0Jn437X1u0SlA6RXWqb1zHPSAvEBwwtNIGMs8RWtrUt0abVRO6nVTRYjqyHnu56kcCQ2jUvoStbKMNb4956kYCOkytz87nE1OO5z7PG6SWK5QSxPMQDsacvGqBLj45RcMMCWuAPG6SWK5QSxP0ApyVoqtbZbqS2ja8(CDfzcWcaejkds4uvyEoaHkqOTYeGfaisu(3Pm2667XMMCWuZZ2hGaOYR3uhQ9ppCA68m2IuQ87nk6Xg8794AcrtMG80Kj6RXWqb1zHPSAvEBwwrZUPtJ2enqW7kQEZB7QCcewydvUUIaNovR9uqDwyYGHkVZfH4xR9biubcTvMGNVkyAYbtnppHcQZctMRYyOY75z91yyOG6SWuwTkVnllT2)UIQ3GHlvgoY)oLhWMWVHkxxrGZZ6RXWy1xcSbpxL9o41fYwlf2BdaxTOnJ0o0N2uTtWwKsLFVrrp2GFVhxtisJ0I2enqW7kQEZB7QCcewydvUUIaNovRJ)2vzlOnQ3e9PPj6RXWGFVhUszAkXVchnK3uTtSpabqLxVbPu9518S96RXWG0vGnbMPelOnQtO6ZurnQlQKzznptb1zHjZvzmu59uT2RVgdt7aOcUW5rtvutLXxnwQ8Ek8t95MLfVb6Ys6Jjwq(WTWcSyjaYIT73HRNLGBzDfkEdp8hSWghsiis0oGDGYWrU8F1KMVrKUvoStbKMNb4956kYCOkytz87nE1OiEdp8hSWghsiis0cW7Z1vKMlpHImaMdWc8(dwzhsAgGRwuK2d2Rd0uWCaeRDcaVpxxrMayoalW7pyPDI(Amm437HRuML1887kQEd(jLY7myFJ3qLRRiW55aeavE9M6qT)5Htt1ccFtcewJRjZFbKUcL2j2RVgddgQW)fiZYsR96RXWe88vbZYs7e7Fxr1BgRovgoYKAvKHkxxrGZZ6RXWe88vbd4Q9)G1MbiubcTvMXQtLHJmPwfzAkXVcJGiAQ2j2JPpRdRf28h12frz7ScZZuqDwyYCvwTkVNNPG6SWKbdvENlcX)uTa8(CDfz(9(uQmMiKOoBZVx7e7dqau51BQd1(NhonphGqfi0wzcWcaejk)7ugBD99yttj(vyePVgdtWZxfmGR2)dwrlnd6NQ99gf9M)sO8dZGhTP(AmmbpFvWaUA)pyfT0mi0PZZ6qmw74qT)5Ms8RWisFngMGNVkyaxT)hSqGg2fTEv0a2OiJvFjWg8Cv27GxxiBTuyVNYBGUSK(yIfKFtvutXIT73zbzBfTPxf4n8WFWcBCiHGirB7aOcUW5rtvutP5BeP(AmmbpFvW0uIFfEtnq)8S(AmmbpFvWaUA)pyHanSlA9QObSrrgR(sGn45QS3bVUq2APWEJi7qEAb4956kYeaZbybE)bRSdjEd0LL0htSGSTI20RcSalwcGSSkfHXS4filQRiwUNLLfl2UFNfKblaqKiEdp8hSWghsiis0gifH)ZvzxDOQeQEnFJib4956kYeaZbybE)bRSdjTt0xJHj45RcgWv7)bleOHDrRxfnGnkYy1xcSbpxL9o41fYwlf27nJ0oK38S9biaQ86naO63t1tNN1xJHPDaubx48OPkQPmllT6RXW0oaQGlCE0uf1uMMs8RWikkGGaSax3BSAkCyk7QdvLq1B(lHYaC1IqWe71xJHrxbHGQf(nllT2)UIQ3GFVvWg0qLRRiWP8gE4pyHnoKqqKO9QG3L)hS08nIeG3NRRitamhGf49hSYoK4nqxwsFmXc6KybTrnlPdwGSalwcGSy7(Dwa(EpCLILLflEbYc2bqSmGnliKLc7nlEbYcY2kAtVkWB4H)Gf24qcbrIwkXcAJ6SoSa18nICsacvGqBLj45RcMMs8RWiqFngMGNVkyaxT)hSqqVkAaBuKXQVeydEUk7DWRlKTwkS3rtd72maHkqOTYqjwqBuN1HfObC1(FWcbAK205z91yycE(QGPPe)k8Mr08myVoqtbZbqmVb6YcYjA0eENLHYBIfyXYYILhYsey59gf9ywSD)oC9SGSTI20RcSOtxHIfxhUEwEileITUMyXlqwk4Zcea1b3Y6ku8gE4pyHnoKqqKOf)Ks5DEO8M0Civqr53Bu0JJudnFJiBA0eE31vK2)sO8dZGhTPgOxl2IuQ87nk6Xg8794AcriSw3kh2PasANOVgdtWZxfmnL4xH3uJ0MNTxFngMGNVkywwt5nqxwsFmXcYhIoSCdwUcFGelEXc6euNfMyXlqwuxrSCplllwSD)ololiKLc7nlwnmWIxGSSvq36paelaT5DcVHh(dwyJdjeejAhRovgoYKAvKMVrKuqDwyYCv2RuAN4w5WofqAE2(Ev0a2OiJvFjWg8Cv27GxxiBTuyVNQDI(Ammw9LaBWZvzVdEDHS1sH92aWvlcr2H(0MN1xJHj45RcMMs8RWBgrt1obe(gh0T(daLX28ojd6jokY8xaPRqnpBFacGkVEtrHgQGn48m2IuQ87nk6XBA3uTt0xJHPDaubx48OPkQPmnL4xHruuqtMGWrRxfnGnkYGVASu59u4N6ZNQvFngM2bqfCHZJMQOMYSSMNTxFngM2bqfCHZJMQOMYSSMQDI9biubcTvMGNVkywwZZ6RXW879PuzmrirTb)EajePb61oou7FUPe)kmISlT00oou7FUPe)k8MAKwAZZ2JHlL(vGMFVpLkJjcjQnu56kcCQ2jy4sPFfO537tPYyIqIAdvUUIaNNdqOceARmbpFvW0uIFfEZiK2uTV3OO38xcLFyg8Onr)8SoeJ1oou7FUPe)kmI0inEd0LL0htS4Sa89E4kflA6f97Sy1WalRsrymlaFVhUsXYHzXvn5GPyzzXcSzjfCXI3elUoC9S8qwGaOo4wSSvmcH3Wd)blSXHecIeT437HRuA(grQVgddSOFhNTOoqw)blZYs7e91yyWV3dxPmnnAcV76kAE2XF7QSf0g1BgfsBkVb6YIMALyXYwXiew0PbSjwqgSaarIyX297Sa89E4kflEbYYVtflaFVXRgfXB4H)Gf24qcbrIw879WvknFJidqau51BQd1(NhoP1(3vu9g8tkL3zW(gVHkxxrGANaW7Z1vKjalaqKOmiHtvH55aeQaH2ktWZxfmlR5z91yycE(QGzznvBacvGqBLjalaqKO8VtzS113JnnL4xHreQaOjXrC0c0PM44VDv2cAJAKl6tBQw91yyWV3dxPmnL4xHrecR1EWEDGMcMdGyEdp8hSWghsiis0IFVXRgfP5BezacGkVEtDO2)8WjTta4956kYeGfaisugKWPQW8CacvGqBLj45RcML18S(AmmbpFvWSSMQnaHkqOTYeGfaisu(3Pm2667XMMs8RWic9Ab4956kYGFVhUsLTbRppCLkdhdTuqDwyYCv2RuAThG3NRRiZHQGnLXV34vJI0ApyVoqtbZbqmVb6Ys6Jjwa(EJxnkIfB3VZIxSOPx0VZIvddSaBwUblPGRTbzbcG6GBXYwXiewSD)olPGRMLIq8ZsWXVHLTQWqwaxjwSSvmcHf)z53jwOcKf4GLFNyjkkv)EQMf91yWYnyb479WvkwSbxkWA7NLHRuSahdwGnlPGlw8MybwSyhlV3OOhZB4H)Gf24qcbrIw87nE1OinFJi1xJHbw0VJZbf5DgWHpyzwwZZtSh)EpUMmUvoStbK0ApaVpxxrMdvbBkJFVXRgfnpprFngMGNVkyAkXVcJi0RvFngMGNVkywwZZtMOVgdtWZxfmnL4xHreQaOjXrC0c0PM44VDv2cAJAKlaVpxxrgmohG4FQw91yycE(QGzznpRVgdt7aOcUW5rtvutLXxnwQ8Ek8t95MMs8RWicva0K4ioAb6utC83UkBbTrnYfG3NRRidgNdq8pvR(AmmTdGk4cNhnvrnvgF1yPY7PWp1NBwwt1gGaOYR3aGQFpvpDQ2jylsPYV3OOhBWV3dxPqueMNb4956kYGFVhUsLTbRppCLkdhJPt1ApaVpxxrMdvbBkJFVXRgfPDI99QObSrrM)siBWUYGn5j6xbs98m2IuQ87nk6Xg879WvkefHP8gOllPpMyrtdclmlxXcqOYBwqNG6SWelEbYc2bqSG8xkflAAqyXYa2SGSTI20Rc8gE4pyHnoKqqKOTiB5eiS08nICI(AmmuqDwykJHkVnnL4xH3KqmfwpL)lHMNNe29gfHJ0oTnf29gfL)lHqe6Noph29gfHJmct16w5WofqI3Wd)blSXHecIeT7UAKtGWsZ3iYj6RXWqb1zHPmgQ820uIFfEtcXuy9u(VeAEEsy3Bueos702uy3Buu(VecrOF68Cy3BueoYimvRBLd7uajTt0xJHPDaubx48OPkQPmnL4xHre61QVgdt7aOcUW5rtvutzwwATVxfnGnkYGVASu59u4N6ZNNTxFngM2bqfCHZJMQOMYSSMYB4H)Gf24qcbrI2XsPYjqyP5Be5e91yyOG6SWugdvEBAkXVcVjHykSEk)xcPDsacvGqBLj45RcMMs8RWBI(0MNdqOceARmbybaIeL)DkJTU(ESPPe)k8MOpTPZZtc7EJIWrAN2Mc7EJIY)Lqic9tNNd7EJIWrgHPADRCyNciPDI(AmmTdGk4cNhnvrnLPPe)kmIqVw91yyAhavWfopAQIAkZYsR99QObSrrg8vJLkVNc)uF(8S96RXW0oaQGlCE0uf1uML1uEd0LL0htSGCarhwGflittXB4H)Gf24qcbrIwBE3hSZWrMuRI4nqxwqMRclL)eMfB70VtnlpKLfMyb4794AILRybiu5nl22VWolhMf)zb9S8EJIEmc0GLbSzHaqDkwSlnKlljo(PoflWMfeMfGV34vJIybDsSG2OoHQNf87bKW8gE4pyHnoKqqKOfG3NRRinxEcfj(9ECnLVkJHkV1maxTOiXwKsLFVrrp2GFVhxtBIWiyOGWEsIJFQtLb4QffnnslnKRDPnfbdfe2t0xJHb)EJxnkktjwqBuNq1NXqL3g87bKqUi8uEd0LfK5QWs5pHzX2o97uZYdzb5O9FNfWvFfkwq(nvrnfVHh(dwyJdjeejAb4956ksZLNqrAR9FpFvE0uf1uAgGRwuKAGCXwKsL3D8tiYonzsAg7I2eSfPu53Bu0Jn437X1KMOX0Onrde8UIQ3GHlvgoY)oLhWMWVHkxxrGrtdd6NofbPz0a9rtFngM2bqfCHZJMQOMY0uIFfM3aDzj9XelihT)7SCflaHkVzbDcQZctSaBwUblfKfGV3JRjwSDkflJ7z5QhYcY2kAtVkWIxPsGnXB4H)Gf24qcbrIwBT)7A(groHcQZctg1Q8oxeI)5zkOolmz8kvUie)Ab4956kYC4CqroaAQ2jV3OO38xcLFyg8Onr45zkOolmzuRY78vz7MN1HyS2XHA)ZnL4xHrKgPnDEwFnggkOolmLXqL3MMs8RWiYd)bld(9ECnzietH1t5)siT6RXWqb1zHPmgQ82SSMNPG6SWK5QmgQ8wR9a8(CDfzWV3JRP8vzmu598S(AmmbpFvW0uIFfgrE4pyzWV3JRjdHykSEk)xcP1EaEFUUImhohuKdG0QVgdtWZxfmnL4xHreHykSEk)xcPvFngMGNVkywwZZ6RXW0oaQGlCE0uf1uMLLwaEFUUIm2A)3ZxLhnvrn18S9a8(CDfzoCoOihaPvFngMGNVkyAkXVcVjHykSEk)xcXBGUSK(yIfGV3JRjwUblxXcASkVzbDcQZctAMLRybiu5nlOtqDwyIfyXccJawEVrrpMfyZYdzXQHbwacvEZc6euNfM4n8WFWcBCiHGirl(9ECnXBGUSG8DL637fVHh(dwyJdjeejA7vL9WFWkRo8R5YtOihUs979I3G3aDzb47nE1OiwgWMLeiakHQNLvPimMLf(kuSKo4wJoVHh(dwyZWvQFVxrIFVXRgfP5BeP99QObSrrgDx5vGYWr2vQ8VFfkSHI41zzrG8gOlliZXpl)oXci8zX297S87eljq8ZYFjelpKfheKLv9NILFNyjXrmlGR2)dwSCyw2V3WcWvnUMyPPe)kmljl1FwQJaz5HSK4FyNLeiSgxtSaUA)pyXB4H)Gf2mCL637fcIeT4vnUM0Civqr53Bu0JJudnFJibHVjbcRX1KPPe)k8MnL4xHJMD2HC1iI4n8WFWcBgUs979cbrI2eiSgxt8g8gOllPpMyzRGU1FaiwaAZ7ewSTtfl)o1elhMLcYIh(daXc2M3jAMfhZIYFIfhZIfeJpDfXcSybBZ7ewSD)ol2XcSzzq2OMf87bKWSaBwGflolrabSGT5Dclyil)U)S87elfzJfSnVtyX7(aqywIIyHFw8Xtnl)U)SGT5DcleITUMW8gE4pyHn4psh0T(daLX28orZHubfLFVrrposn08nI0Eq4BCq36paugBZ7KmON4OiZFbKUcLw79WFWY4GU1FaOm2M3jzqpXrrMRYd1HA)1oXEq4BCq36paugBZ7K8o5kZFbKUc18mi8noOB9hakJT5DsENCLPPe)k8MOF68mi8noOB9hakJT5Dsg0tCuKb)EajefbTGW34GU1FaOm2M3jzqpXrrMMs8RWikcAbHVXbDR)aqzSnVtYGEIJIm)fq6ku8gOllPpMWSGmybaIeXYnybzBfTPxfy5WSSSyb2SKcUyXBIfqcNQcxHIfKTv0MEvGfB3VZcYGfaiselEbYsk4IfVjw0jf0gliCAOncPnbzKIW)5kwaAD994PSSvmcHLRyXzrJ0qalykWc6euNfMmSSvfgYciS2(zrrplAQM8e9RaPMfcXwxtAMfxzZtHzzHjwUIfKTv0MEvGfB3VZcczPWEZIxGS4pl)oXc(9(zboyXzjDWTgDwSDfi0MH3Wd)blSb)iis0gGfaisu(3Pm2667XA(grApyVoqtbZbqS2jta4956kYeGfaisugKWPQGw7dqOceARmbpFvW0KdMsR99QObSrrgR(sGn45QS3bVUq2APWEppRVgdtWZxfmlRPANmXXF7QSf0g1iksaEFUUImbybaIeLDSL2j6RXWqb1zHPSAvEBAkXVcVPgPnpRVgddfuNfMYyOYBttj(v4n1iTPZZ6RXWe88vbttj(v4nrVw91yycE(QGPPe)kmIIud7MQDI99QObSrrM)siBWUYGn5j6xbs98S99QObSrrMaPi8FUkJTU(E88S(Amm)Lq2GDLbBYt0VcKAttj(v4njetH1t5)sOPZZ9QObSrrgDx5vGYWr2vQ8VFfk8uTtSVxfnGnkYO7kVcugoYUsL)9RqHNNNOVgdJUR8kqz4i7kv(3Vcfox(VAYGFpGuKr08S(Amm6UYRaLHJSRu5F)ku4S3bVid(9asrgrtNopRdXyTJd1(NBkXVcJinstR9biubcTvMGNVkyAYbtnL3aDzj9XelaFVXRgfXYdzbjISyzzXYVtSOPAYt0VcKAw0xJbl3GL7zXgCPazHqS11el60a2elJRo8(vOy53jwkcXplbh)SaBwEilGRelw0PbSjwqgSaarI4n8WFWcBWpcIeT43B8QrrA(gr2RIgWgfz(lHSb7kd2KNOFfi1ANy)Kj6RXW8xczd2vgSjpr)kqQnnL4xH30d)blJT2)DdHykSEk)xcHG0mAODcfuNfMmxL1H)(8mfuNfMmxLXqL3ZZuqDwyYOwL35Iq8pDEwFngM)siBWUYGn5j6xbsTPPe)k8ME4pyzWV3JRjdHykSEk)xcHG0mAODcfuNfMmxLvRY75zkOolmzWqL35Iq8pptb1zHjJxPYfH4F605z71xJH5VeYgSRmytEI(vGuBwwtNNNOVgdtWZxfmlR5zaEFUUImbybaIeLbjCQkmvBacvGqBLjalaqKO8VtzS113Jnn5GP0gGaOYR3uhQ9ppCs7e91yyOG6SWuwTkVnnL4xH3uJ0MN1xJHHcQZctzmu5TPPe)k8MAK20PANyFacGkVEdsP6ZR55aeQaH2kdLybTrDwhwGMMs8RWBgrt5nqxw0uRelwa(EJxnkcZIT73zjDUYRaXcCWYwvkwI((vOWSaBwEilwnz5nXYa2SGmybaIeXIT73zjDWTgDEdp8hSWg8JGirl(9gVAuKMVrK9QObSrrgDx5vGYWr2vQ8VFfkS2jt0xJHr3vEfOmCKDLk)7xHcNl)xnzWVhqAt7MN1xJHr3vEfOmCKDLk)7xHcN9o4fzWVhqAt7MQnaHkqOTYe88vbttj(v4nrOATpaHkqOTYeGfaisu(3Pm2667XML188KaeavE9M6qT)5HtAdqOceARmbybaIeL)DkJTU(ESPPe)kmI0inTuqDwyYCv2RuAD83UkBbTr9M2LgcIqArlaHkqOTYe88vbttoyQPt5nqxwqgSaV)GfldyZIRuSacFml)U)SK4irywWRMy53PuS4nvB)S00Oj8obYITDQyb5KdGk4cZcYVPkQPyz3XSOimMLF3lwqplykGzPPe)QRqXcSz53jwqNelOnQzjDWcKf91yWYHzX1HRNLhYYWvkwGJblWMfVsXc6euNfMy5WS46W1ZYdzHqS11eVHh(dwyd(rqKOfG3NRRinxEcfji8ZnfXRRPeQESMb4Qff5e91yyAhavWfopAQIAkttj(v4nr)8S96RXW0oaQGlCE0uf1uML1uT2RVgdt7aOcUW5rtvutLXxnwQ8Ek8t95MLL2j6RXWG0vGnbMPelOnQtO6ZurnQlQKPPe)kmIqfanjoINQDI(AmmuqDwykJHkVnnL4xH3eva0K4iEEwFnggkOolmLvRYBttj(v4nrfanjoINNNyV(AmmuqDwykRwL3ML18S96RXWqb1zHPmgQ82SSMQ1(3vu9gmuH)lqgQCDfboL3aDzbzWc8(dwS87(ZsyNciHz5gSKcUyXBIf46XhiXcfuNfMy5HSalvkwaHpl)o1elWMLdvbBILF)WSy7(Dwacv4)ceVHh(dwyd(rqKOfG3NRRinxEcfji8ZW1Jpqktb1zHjndWvlkYj2RVgddfuNfMYyOYBZYsR96RXWqb1zHPSAvEBwwt1A)7kQEdgQW)fidvUUIa1AFVkAaBuK5VeYgSRmytEI(vGuZBGUSOPGplUsXY7nk6XSy7(9RybH4fiLCbwSD)oC9SabqDWTSUcfc(DIfxhcGyjalW7pyH5n8WFWcBWpcIeTjqynUM0Civqr53Bu0JJudnFJiNOVgddfuNfMYyOYBttj(v4nBkXVcppRVgddfuNfMYQv5TPPe)k8MnL4xHNNb4956kYac)mC94dKYuqDwyAQ2MgnH3DDfP99gf9M)sO8dZGhTPg2P1TYHDkGKwaEFUUImGWp3ueVUMsO6X8gE4pyHn4hbrIw8QgxtAoKkOO87nk6XrQHMVrKt0xJHHcQZctzmu5TPPe)k8MnL4xHNN1xJHHcQZctz1Q820uIFfEZMs8RWZZa8(CDfzaHFgUE8bszkOolmnvBtJMW7UUI0(EJIEZFju(HzWJ2ud706w5WofqslaVpxxrgq4NBkIxxtju9yEdp8hSWg8JGirl(jLY78q5nP5qQGIYV3OOhhPgA(grorFnggkOolmLXqL3MMs8RWB2uIFfEEwFnggkOolmLvRYBttj(v4nBkXVcppdW7Z1vKbe(z46XhiLPG6SW0uTnnAcV76ks77nk6n)Lq5hMbpAtnqEADRCyNciPfG3NRRidi8ZnfXRRPeQEmVb6YIMc(S0hQ9NfDAaBIfKFtvutXYny5EwSbxkqwCLcAJLuWflpKLMgnH3zrrymlGR(kuSG8BQIAkwM87hMfyPsXYUBzrfMfB3VdxplaVASuSGCEk8t95t5n8WFWcBWpcIeTa8(CDfP5YtOilyEpf(P(8m5Tkvge(AgGRwuKbiaQ86naO63t1ATVxfnGnkYGVASu59u4N6Z1AFVkAaBuKjCDqrz4iRUbL9cmds(VRnaHkqOTYOtnMAKUcLPjhmL2aeQaH2kt7aOcUW5rtvutzAYbtP1E91yycE(QGzzPDIJ)2vzlOnQ3mIqOZZ6RXWORGqq1c)ML1uEdp8hSWg8JGirBcewJRjnFJib4956kYuW8Ek8t95zYBvQmi812uIFfgr2LgVHh(dwyd(rqKOfVQX1KMVrKa8(CDfzkyEpf(P(8m5Tkvge(ABkXVcJinIc8gOllPpMyb5d3clWILail2UFhUEwcUL1vO4n8WFWcBWpcIeTdyhOmCKl)xnP5BePBLd7uajEd0LL0htSGojwqBuZs6Gfil2UFNfVsXIcwOyHk4c1olkh)xHIf0jOolmXIxGS8DkwEilQRiwUNLLfl2UFNfeYsH9MfVazbzBfTPxf4n8WFWcBWpcIeTuIf0g1zDybQ5Be5KaeQaH2ktWZxfmnL4xHrG(AmmbpFvWaUA)pyHGEv0a2OiJvFjWg8Cv27GxxiBTuyVJMg2TzacvGqBLHsSG2OoRdlqd4Q9)Gfc0iTPZZ6RXWe88vbttj(v4nJO5zWEDGMcMdGyEd0LfG0JzX2ovSSvmcHf8oCPazrNybCLyrGS8qwk4Zcea1b3ILjAkYIkqmlWIfK)QtXcCWc6OwfXIxGS87elOtqDwyAkVHh(dwyd(rqKOfG3NRRinxEcfPJTYGRelndWvlksh)TRYwqBuVzuinnzIDg0hn91yygRovgoYKAvKb)EajnXUOrb1zHjZvz1Q8EkVb6Ys6Jjwq2wrB6vbwSD)olidwaGirOnk2vGnbYcqRRVhZIxGSacRTFwGaO2wFpXcczPWEZcSzX2ovSKofecQw4NfBWLcKfcXwxtSOtdytSGSTI20RcSqi26AcByrtZrIybVAILhYcvp1S4SGgRYBwqNG6SWel22PILf(qvSeD7IiwSZkWIxGS4kflittHzX2PuSOtbycXstoykwWqyXcvWfQDwax9vOy53jw0xJblEbYci8XSS7aiw0jQybVgJlCu9QuS00Oj8obA4n8WFWcBWpcIeTa8(CDfP5YtOidG5aSaV)Gvg)AgGRwuK2d2Rd0uWCaeRDcaVpxxrMayoalW7pyP1E91yycE(QGzzPDI9y6Z6WAHn)rTDru2oRW8mfuNfMmxLvRY75zkOolmzWqL35Iq8pv7Kjta4956kY4yRm4kXAEoabqLxVPou7FE4088KaeavE9gKs1NxAdqOceARmuIf0g1zDybAAYbtnDEUxfnGnkY8xczd2vgSjpr)kqQNQfe(g8QgxtMMs8RWBgrAbHVjbcRX1KPPe)k8MrbTtaHVb)Ks5DEO8MmnL4xH3uJ0MNT)DfvVb)Ks5DEO8Mmu56kcCQwaEFUUIm)EFkvgtesuNT53R99gf9M)sO8dZGhTP(AmmbpFvWaUA)pyfT0mi05z91yy0vqiOAHFZYsR(Amm6kieuTWVPPe)kmI0xJHj45RcgWv7)blemrd7IwVkAaBuKXQVeydEUk7DWRlKTwkS3tNoppHI41zzrGgkXkvtUkdBWYRaPnaHkqOTYqjwPAYvzydwEfittj(vyePbYdHIGjOpA9QObSrrg8vJLkVNc)uF(0Pt1oX(aeavE9M6qT)5HtZZtcqOceARmbybaIeL)DkJTU(ESPPe)kmI0xJHj45RcgWv7)blKRDATVxfnGnkYO7kVcugoYUsL)9RqHNNdqOceARmbybaIeL)DkJTU(ESPjhmLwh)TRYwqBuJi0N205zDigRDCO2)Ctj(vyefGqfi0wzcWcaejk)7ugBD99yttj(v4PZZ6qmw74qT)5Ms8RWisFngMGNVkyaxT)hSqGg2fTEv0a2OiJvFjWg8Cv27GxxiBTuyVNYBGUSK(yIfKFtvutXIT73zbzBfTPxfyzvkcJzb53uf1uSydUuGSOC8ZIcwOOMLF3lwq2wrB6vbnZYVtfllmXIonGnXB4H)Gf2GFeejABhavWfopAQIAknFJi1xJHj45RcMMs8RWBQb6NN1xJHj45RcgWv7)blezhcfb9QObSrrgR(sGn45QS3bVUq2APWEhnnStlaVpxxrMayoalW7pyLXpVHh(dwyd(rqKOnqkc)NRYU6qvju9A(grcW7Z1vKjaMdWc8(dwz8RDI(AmmbpFvWaUA)pyTzK2HqrqVkAaBuKXQVeydEUk7DWRlKTwkS3rtd7MNTpabqLxVbav)EQE68S(AmmTdGk4cNhnvrnLzzPvFngM2bqfCHZJMQOMY0uIFfgrrbeeGf46EJvtHdtzxDOQeQEZFjugGRwecMyV(Amm6kieuTWVzzP1(3vu9g87Tc2GgQCDfboL3Wd)blSb)iis0EvW7Y)dwA(grcW7Z1vKjaMdWc8(dwz8ZBGUSef17Z1vellmbYcSyX1p19hHz539NfBE9S8qw0jwWoacKLbSzbzBfTPxfybdz539NLFNsXI3u9SyZXpbYsuel8ZIonGnXYVtj8gE4pyHn4hbrIwaEFUUI0C5juKyhaLhWoh88vbndWvlkYaeQaH2ktWZxfmnL4xH3uJ0MNThG3NRRitawaGirzqcNQcAdqau51BQd1(Nhonpd2Rd0uWCaeZBGUSK(ycZcYhIoSCdwUIfVybDcQZctS4filFFeMLhYI6kIL7zzzXIT73zbHSuyV1mliBROn9QGMzbDsSG2OML0blqw8cKLTc6w)bGybOnVt4n8WFWcBWpcIeTJvNkdhzsTksZ3iskOolmzUk7vkTtC83UkBbTrnIIc2Pj6RXWmwDQmCKj1Qid(9asrd9ZZ6RXW0oaQGlCE0uf1uML1uTt0xJHXQVeydEUk7DWRlKTwkS3gaUAriYoeoT5z91yycE(QGPPe)k8Mr0uTa8(CDfzWoakpGDo45RcANyFacGkVEtrHgQGn48mi8noOB9hakJT5Dsg0tCuK5VasxHAQ2j2hGaOYR3aGQFpvppRVgdt7aOcUW5rtvutzAkXVcJOOGMmbHJwVkAaBuKbF1yPY7PWp1NpvR(AmmTdGk4cNhnvrnLzznpBV(AmmTdGk4cNhnvrnLzznv7e7dqau51BqkvFEnphGqfi0wzOelOnQZ6Wc00uIFfEt7sBQ23Bu0B(lHYpmdE0MOFEwhIXAhhQ9p3uIFfgrAKgVb6Ys6Jjw00l63zb479WvkwSAyaZYnyb479WvkwoCT9ZYYI3Wd)blSb)iis0IFVhUsP5BeP(AmmWI(DC2I6az9hSmllT6RXWGFVhUszAA0eE31veVb6YcY8kqkwa(ERGnil3GL7zz3XSOimMLF3lwqpMLMs8RUcLMzjfCXI3el(ZsuineWYwXiew8cKLFNyjS6MQNf0jOolmXYUJzb9iaZstj(vxHI3Wd)blSb)iis0g8kqQS(Am0C5juK43BfSb18nIuFngg87Tc2GMMs8RWic9ANOVgddfuNfMYyOYBttj(v4nr)8S(AmmuqDwykRwL3MMs8RWBI(PAD83UkBbTr9MrH04nqxwqMxbsXYVtSGqwkS3SOVgdwUbl)oXIvddSydUuG12plQRiwwwSy7(Dw(DILIq8ZYFjelidwaGirSeGjeMf4yWsa0Ws03pmll8YvQuSalvkw2DllQWSaU6RqXYVtSKo0WWB4H)Gf2GFeejAdEfivwFngAU8eksR(sGn45QS3bVUq2APWER5Be57kQEZvbVl)pyzOY1veOw7Fxr1BkYwobcldvUUIa1gf3KjriT00eh)TRYwqBuJaeonnbtFwhwlS5pQTlIY2zfIgcN2uK7eeg5ITiLkV74NMQjbiubcTvMaSaarIY)oLXwxFp20uIFfEkIIIBYKiKwAAIJ)2vzlOnQ1e91yyS6lb2GNRYEh86czRLc7TbGRwecq400em9zDyTWM)O2UikBNviAiCAtrUtqyKl2IuQ8UJFAQMeGqfi0wzcWcaejk)7ugBD99yttj(v4PAdqOceARmbpFvW0uIFfEZiKMw91yyS6lb2GNRYEh86czRLc7TbGRweIStJ00QVgdJvFjWg8Cv27GxxiBTuyVnaC1I2mcPPnaHkqOTYeGfaisu(3Pm2667XMMs8RWicHtt74qT)5Ms8RWBgGqfi0wzcWcaejk)7ugBD99yttj(vyeG80oPxfnGnkYeifH)ZvzS113JNNb4956kYeGfaisugKWPQWuEd0LfG0JzX2ovSGqwkS3SG3Hlfil6elwnmeiqwiVvPy5HSOtS46kILhYYctSGmybaIeXcSyjaHkqOTILjOdgt1FUsLIfDkatimlFViwUblGReRRqXYwXiewkOnwSDkflUsbTXsk4ILhYIf1dk8QuSq1tnliKLc7nlEbYYVtfllmXcYGfais0uEdp8hSWg8JGirlaVpxxrAU8eksRggYwlf27m5TkLMb4QffzacGkVEtDO2)8WjT9QObSrrgR(sGn45QS3bVUq2APWERvFnggR(sGn45QS3bVUq2APWEBa4QfHah)TRYwqBuJGiSzKriT00cW7Z1vKjalaqKOmiHtvbTbiubcTvMaSaarIY)oLXwxFp20uIFfgro(BxLTG2Og5gH0IgQaOjXrSw7b71bAkyoaI1sb1zHjZvzVsP1XF7QSf0g1BcW7Z1vKjalaqKOSJT0gGqfi0wzcE(QGPPe)k8MON3aDzj9XelaFVhUsXIT73zb4tkL3SOP6B8SaBwE7IiwqyRalEbYsbzb47Tc2GAMfB7uXsbzb479WvkwomlllwGnlpKfRggybHSuyVzX2ovS46qaelrH0yzRyeYeyZYVtSqERsXcczPWEZIvddSaW7Z1velhMLVx0uwGnloOL)haIfSnVtyz3XSeriatbmlnL4xDfkwGnlhMLRyzOou7pVHh(dwyd(rqKOf)EpCLsZ3iYjVRO6n4NukVZG9nEdvUUIaNNX0N1H1cB(JA7IOmcBfMQ1(3vu9g87Tc2GgQCDfbQvFngg879WvkttJMW7UUI0AFVkAaBuK5VeYgSRmytEI(vGuRDI(Ammw9LaBWZvzVdEDHS1sH92aWvlAZiTd9PP1E91yycE(QGzzPDcaVpxxrghBLbxjwZZ6RXWG0vGnbMPelOnQtO6ZurnQlQKzznpdW7Z1vKXQHHS1sH9otERsnDEEsacGkVEtrHgQGnO23vu9g8tkL3zW(gVHkxxrGANacFJd6w)bGYyBENKb9ehfzAkXVcVzenp7H)GLXbDR)aqzSnVtYGEIJImxLhQd1(pD6uTtcqOceARmbpFvW0uIFfEtnsBEoaHkqOTYeGfaisu(3Pm2667XMMs8RWBQrAt5nqxw0uRelmlBfJqyrNgWMybzWcaejILf(kuS87elidwaGirSeGf49hSy5HSe2PasSCdwqgSaarIy5WS4HF5kvkwCD46z5HSOtSeC8ZB4H)Gf2GFeejAXV34vJI08nIeG3NRRiJvddzRLc7DM8wLI3aDzj9XelAAqyHzX2ovSKcUyXBIfxhUEwEiA9Myj4wwxHILWU3OimlEbYsIJeXcE1el)oLIfVjwUIfVybDcQZctSG)tPyzaBwqoxtdTiFnnEdp8hSWg8JGirBr2YjqyP5BePBLd7uajTtc7EJIWrAN2Mc7EJIY)Lqic9ZZHDVrr4iJWuEdp8hSWg8JGir7URg5eiS08nI0TYHDkGK2jHDVrr4iTtBtHDVrr5)sieH(55WU3OiCKryQ2j6RXWqb1zHPSAvEBAkXVcVjHykSEk)xcnpRVgddfuNfMYyOYBttj(v4njetH1t5)sOP8gE4pyHn4hbrI2XsPYjqyP5BePBLd7uajTtc7EJIWrAN2Mc7EJIY)Lqic9ZZHDVrr4iJWuTt0xJHHcQZctz1Q820uIFfEtcXuy9u(VeAEwFnggkOolmLXqL3MMs8RWBsiMcRNY)Lqt5nqxwsFmXcW3B8QrrSOPx0VZIvddyw8cKfWvIflBfJqyX2ovSGSTI20RcAMf0jXcAJAwshSa1ml)oXsuuQ(9unl6RXGLdZIRdxplpKLHRuSahdwGnlPGRTbzj4wSSvmcH3Wd)blSb)iis0IFVXRgfP5BejfuNfMmxL9kL2j6RXWal63X5GI8od4WhSmlR5z91yyq6kWMaZuIf0g1ju9zQOg1fvYSSMN1xJHj45RcMLL2j2hGaOYR3GuQ(8AEoaHkqOTYqjwqBuN1HfOPPe)k8MOFEwFngMGNVkyAkXVcJiubqtIJ4OnuqypXXF7QSf0g1ixaEFUUImyCoaX)0PANyFacGkVEdaQ(9u98S(AmmTdGk4cNhnvrnLPPe)kmIqfanjoIJwGo1Kjo(BxLTG2OgbiCAr7DfvVzS6uz4itQvrgQCDfbof5cW7Z1vKbJZbi(NIGieT3vu9MISLtGWYqLRRiqT23RIgWgfzWxnwQ8Ek8t95A1xJHPDaubx48OPkQPmlR5z91yyAhavWfopAQIAQm(QXsL3tHFQp3SSMNNOVgdt7aOcUW5rtvutzAkXVcJip8hSm437X1KHqmfwpL)lH0ITiLkV74NquAgeEEwFngM2bqfCHZJMQOMY0uIFfgrE4pyzS1(VBietH1t5)sO5zaEFUUImxedMdWc8(dwAdqOceARmxHd96DDfLJ4Lx)kjdsaUazAYbtPLI41zzrGMRWHE9UUIYr8YRFLKbjaxGMQvFngM2bqfCHZJMQOMYSSMNTxFngM2bqfCHZJMQOMYSS0AFacvGqBLPDaubx48OPkQPmn5GPMopdW7Z1vKXXwzWvI18SoeJ1oou7FUPe)kmIqfanjoIJwGo1eh)TRYwqBuJCb4956kYGX5ae)tNYBGUSe9oflpKLehjILFNyrNWplWblaFVvWgKf9uSGFpG0vOy5EwwwSeXRlGKkflxXIxPybDcQZctSOVEwqilf2BwoCT9ZIRdxplpKfDIfRggceiVHh(dwyd(rqKOf)EJxnksZ3iY3vu9g87Tc2GgQCDfbQ1(Ev0a2OiZFjKnyxzWM8e9RaPw7e91yyWV3kydAwwZZo(BxLTG2OEZOqAt1QVgdd(9wbBqd(9asikcANOVgddfuNfMYyOYBZYAEwFnggkOolmLvRYBZYAQw91yyS6lb2GNRYEh86czRLc7TbGRweISdHMM2jbiubcTvMGNVkyAkXVcVPgPnpBpaVpxxrMaSaarIYGeovf0gGaOYR3uhQ9ppCAkVb6Yc6G)lXFcZYo0gljRWolBfJqyXBIfu(veilwuZcMcWc0WIMEPsXY7irywCwWLBH3HpldyZYVtSewDt1Zc((L)hSybdzXgCPaRTFw0jw8qy1(tSmGnlkVrrnl)LqJ2timVHh(dwyd(rqKOfG3NRRinxEcfPJTqiudKcAgGRwuKuqDwyYCvwTkVJweHC9WFWYGFVhxtgcXuy9u(Vecb2tb1zHjZvz1Q8oAtqEi4DfvVbdxQmCK)DkpGnHFdvUUIaJweMIC9WFWYyR9F3qiMcRNY)LqiindcJEKl2IuQ8UJFcbPzqF0Exr1Bk)xnHZ6UYRazOY1veiVb6YIMALyXcW3B8QrrSCflEXc6euNfMyXXSGHWIfhZIfeJpDfXIJzrbluS4ywsbxSy7ukwOcKLLfl2UFNLikneWITDQyHQN6RqXYVtSueIFwqNG6SWKMzbewB)SOONL7zXQHbwqilf2BnZciS2(zbcGAB99elEXIMEr)olwnmWIxGSybHkw0PbSjwq2wrB6vbw8cKf0jXcAJAwshSa5n8WFWcBWpcIeT43B8QrrA(grAFVkAaBuK5VeYgSRmytEI(vGuRDI(Ammw9LaBWZvzVdEDHS1sH92aWvlcr2HqtBEwFnggR(sGn45QS3bVUq2APWEBa4QfHi7qFAAFxr1BWpPuENb7B8gQCDfbov7ekOolmzUkJHkV164VDv2cAJAeaW7Z1vKXXwieQbsHOPVgddfuNfMYyOYBttj(vyeacFZy1PYWrMuRIm)fqcNBkXVkA2zq)MruAZZuqDwyYCvwTkV164VDv2cAJAeaW7Z1vKXXwieQbsHOPVgddfuNfMYQv5TPPe)kmcaHVzS6uz4itQvrM)ciHZnL4xfn7mOFZOqAt1AV(AmmWI(DC2I6az9hSmllT2)UIQ3GFVvWg0qLRRiqTtcqOceARmbpFvW0uIFfEte68mgUu6xbA(9(uQmMiKO2qLRRiqT6RXW879PuzmrirTb)EajefHiOjt6vrdyJIm4RglvEpf(P(8Oz3uTJd1(NBkXVcVPgPLM2XHA)ZnL4xHrKDPL28myVoqtbZbq8uTtSpabqLxVbPu9518CacvGqBLHsSG2OoRdlqttj(v4nTBkVb6Ys6Jjw00GWcZYvS4vkwqNG6SWelEbYc2bqSGCURgia5Vukw00GWILbSzbzBfTPxfyXlqwIIDfytGSGojwqBuNq1ByzRkmKLfMyzlAAS4filiFnnw8NLFNyHkqwGdwq(nvrnflEbYciS2(zrrplAQM8e9RaPMLHRuSahdEdp8hSWg8JGirBr2YjqyP5BePBLd7uajTa8(CDfzWoakpGDo45RcANOVgddfuNfMYQv5TPPe)k8MeIPW6P8Fj08S(AmmuqDwykJHkVnnL4xH3KqmfwpL)lHMYB4H)Gf2GFeejA3D1iNaHLMVrKUvoStbK0cW7Z1vKb7aO8a25GNVkODI(AmmuqDwykRwL3MMs8RWBsiMcRNY)LqZZ6RXWqb1zHPmgQ820uIFfEtcXuy9u(VeAQ2j6RXWe88vbZYAEwFnggR(sGn45QS3bVUq2APWEBa4QfHOiTtJ0MQDI9biaQ86naO63t1ZZ6RXW0oaQGlCE0uf1uMMs8RWiAc61e7IwVkAaBuKbF1yPY7PWp1NpvR(AmmTdGk4cNhnvrnLzznpBV(AmmTdGk4cNhnvrnLzznv7e77vrdyJIm)Lq2GDLbBYt0VcK65zcXuy9u(Vecr6RXW8xczd2vgSjpr)kqQnnL4xHNNTxFngM)siBWUYGn5j6xbsTzznL3Wd)blSb)iis0owkvobclnFJiDRCyNciPfG3NRRid2bq5bSZbpFvq7e91yyOG6SWuwTkVnnL4xH3KqmfwpL)lHMN1xJHHcQZctzmu5TPPe)k8MeIPW6P8Fj0uTt0xJHj45RcML18S(Ammw9LaBWZvzVdEDHS1sH92aWvlcrrANgPnv7e7dqau51BqkvFEnpRVgddsxb2eyMsSG2OoHQptf1OUOsML1uTtSpabqLxVbav)EQEEwFngM2bqfCHZJMQOMY0uIFfgrOxR(AmmTdGk4cNhnvrnLzzP1(Ev0a2Oid(QXsL3tHFQpFE2E91yyAhavWfopAQIAkZYAQ2j23RIgWgfz(lHSb7kd2KNOFfi1ZZeIPW6P8FjeI0xJH5VeYgSRmytEI(vGuBAkXVcppBV(Amm)Lq2GDLbBYt0VcKAZYAkVb6Ys6JjwqoGOdlWILaiVHh(dwyd(rqKO1M39b7mCKj1QiEd0LL0htSa89ECnXYdzXQHbwacvEZc6euNfM0mliBROn9Qal7oMffHXS8xcXYV7flolihT)7SqiMcRNyrrJNfyZcSuPybnwL3SGob1zHjwomllldlih3VZs0TlIyXoRalu9uZIZcqOYBwqNG6SWel3GfeYsH9Mf8Fkfl7oMffHXS87EXIDAKgl43diHzXlqwq2wrB6vbw8cKfKblaqKiw2DaeljWMy539IfnqOywqMMILMs8RUcLHL0htS46qael2H(0qUSS74NybC1xHIfKFtvutXIxGSyND2HCzz3XpXIT73HRNfKFtvutXB4H)Gf2GFeejAXV3JRjnFJiPG6SWK5QSAvER1E91yyAhavWfopAQIAkZYAEMcQZctgmu5DUie)ZZtOG6SWKXRu5Iq8ppRVgdtWZxfmnL4xHrKh(dwgBT)7gcXuy9u(VesR(AmmbpFvWSSMQDI9y6Z6WAHn)rTDru2oRW8CVkAaBuKXQVeydEUk7DWRlKTwkS3A1xJHXQVeydEUk7DWRlKTwkS3gaUAriYonstBacvGqBLj45RcMMs8RWBQbcv7e7dqau51BQd1(NhonphGqfi0wzcWcaejk)7ugBD99yttj(v4n1aHov7e7BpqMVHk18CacvGqBLrNAm1iDfkttj(v4n1aHoD68mfuNfMmxL9kL2j6RXWyZ7(GDgoYKAvKzznpJTiLkV74NquAgeg9ANyFacGkVEdaQ(9u98S96RXW0oaQGlCE0uf1uML1055aeavE9gau97PATylsPY7o(jeLMbHNYBGUSK(yIfKJ2)DwG)o12omXIT9lSZYHz5kwacvEZc6euNfM0mliBROn9QalWMLhYIvddSGgRYBwqNG6SWeVHh(dwyd(rqKO1w7)oVb6YcY3vQFVx8gE4pyHn4hbrI2Evzp8hSYQd)AU8ekYHRu)EVI)4pog]] )
    

end