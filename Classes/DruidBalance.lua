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


    spec:RegisterPack( "Balance", 20220316, [[dmLe4fqiHWJif0LqKkBIu6tkLAuIuNsHSkrsEfcywKIClsrzxu8leLgMcLJHOAzukEgLsnneKUgPqBdrQ6BisPXrkQoNirSorIAEiq3tiAFkf9prIu1afjsLdQusluHkperYePuIUiPaBerk(icIkJebrvNuHQALkfEPirkZerr3KsjyNkL4NukHgkcchvKirlfbr5PaAQIK6QkuLTksK0xrqKXIOWEfXFf1GjomvlMu9ybtgOldTzf9zeA0kvNwLvlsKWRreZMKBlu7wYVbnCk54ukPLl1ZrA6Q66kz7a8DkvJhb15fsRxKW8vW(rDc5jPobiO)yYwSzmBSzmBtoP3mMMB7XiN8eGFulmbOLhiXjIjalpgtaoox5vataA5rvqhmj1jaPWvhWeG7)BrtzYswDx5va1m6fhmeVFFPBoizhNR8kGAgWlMuKng0S)XQu6NNcJu3vEfqZt4pbO(6u)4xj6jab9ht2InJzJnJzBYj9MX0CBsjAuJja91Vd7eGaVysLaC)abXkrpbiisdjahNR8kGSyl71bYByl4DyNfYj9AIfBgZgB4n4ni1UxerAkZBOzSSvqqeKfGqL3Smo0Jn8gAglKA3lIiilV3eXpFtwcofPS8qwcrdkm)EteFQH3qZyHqggdbGGSSQcdiL6Duwa4956kKYs6ZGgnXIvJaY03B6QjISOzBYIvJam03B6QjIJm8gAglBfa8azXQXGt)RiYcHu7)ol3KL73MYYVJSyVHfrw0GG6SOOH3qZyXwWjbzHuWcaKeKLFhzbO113tzXzrD)RqwIHnYYuHe(0vilPVjlrHlw2DWA7NL97z5EwOx8s9EHWfvfLf73VZY4Sf3AQzHaSqkuH0)CflBvDeRySEnXY9BdYcLKZAKH3qZyXwWjbzjgsFw2EEe3)CJX(v0TzHgWY7dszXTSurz5HSOdPuwMhX9NYcSurn8gAglPUr)zj1WyKf4KLXP8DwgNY3zzCkFNfNYIZc1cdNRy57RibFdVHMXITOfwyZs6ZGgnXcHu7)UMyHqQ9FxtSa89EEnoILyhezjg2ilnsp1H1ZYdzb9wDyZsagR7VMrFVFdVHMXcP5imlP0UcSrqw0GylODSJX6zjSJbsyzcBwiLTKLf1jIMeGQJ(0KuNaeAHf2jPozlKNK6eGy56kemzCja9WFWkbO92)9eGGin0N1FWkbiHOXGtFwSHfcP2)Dw8cKfNfGV30vtezbwSam1Sy)(Dw2YrC)zH04ilEbYY4GBn1SaBwa(EpVgzb(7yB)OycWqFp2NNamnlyqDwu0OwL35cj8ZYWalyqDwu0CvMcvEZYWalyqDwu0Cvwh(7SmmWcguNffnEfnxiHFwgXIwwSAeGHCJ92)Dw0YseSy1iaJng7T)7jFYwSjj1jaXY1viyY4sa6H)Gvcq6798AmbyOVh7ZtaMMLiyPxfoHnr0O7kVcygoZUsL)9Risny56keKLHbwIGLaeawE9M6iU)5PJSmmWseSqTqLk)EteFQH(EpDLILizHCwggyjcwExH1Bk)xnsZ6UYRaAWY1viilJyrllrWcf)SoSwuZFyBJMNTXkWYWalPzbdQZIIgku5DUqc)SmmWcguNffnxLvRYBwggybdQZIIMRY6WFNLHbwWG6SOOXRO5cj8ZYOeGQRWCambOgt(KTy7KuNaelxxHGjJlbOh(dwjaPV30vtetag67X(8eGPzPxfoHnr0O7kVcygoZUsL)9Risny56keKfTSeGaWYR3uhX9ppDKfTSqTqLk)EteFQH(EpDLILizHCwgXIwwIGfk(zDyTOM)W2gnpBJvibO6kmhataQXKp5tacItFP(KuNSfYtsDcqp8hSsasHkVZ6OhNaelxxHGjJl5t2InjPobiwUUcbtgxcWqFp2NNa8VyKfcYsAwSHLuXIh(dwg7T)7MGt)8FXileGfp8hSm03751Oj40p)xmYYOeG0VVWNSfYta6H)GvcWGRuzp8hSYQJ(javh9ZLhJjaHwyHDYNSfBNK6eGy56kemzCjaHwjaP4Na0d)bReGa8(CDfMaeGRwycqQfQu53BI4tn037PRuSSjlKZIwwsZseS8UcR3qFVvWg0GLRRqqwggy5DfwVH(Os5DgSV5BWY1viilJyzyGfQfQu53BI4tn037PRuSSjl2KaeePH(S(dwjabIpLLTc1awGfl2MaSy)(D46zbSV5ZIxGSy)(Dwa(ERGnilEbYIneGf4VJT9JIjab4DU8ymb4rZoet(KTqOjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMaKAHkv(9Mi(ud99EEnYYMSqEcqqKg6Z6pyLaei(uwck0bGSyFhlwa(EpVgzj4fl73ZIneGL3BI4tzX((f2z5OS0Ocb41ZYe2S87ilAqqDwuKLhYIoYIvJtSBeKfVazX((f2zzEkf2S8qwco9tacW7C5XycWJMdk0bGjFYw0ysQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaTAeqMya0qUjgcR51ilddSy1iGmXaOHCdDvZRrwggyXQrazIbqd5g67nD1erwggyXQrazIbqd5g6790vkwggyXQrazIbqd5M5QJMHZmQwfYYWalwncW0oaSGlAE2yLIOSmmWI(AonbpFvW0ySFfLLizrFnNMGNVkyaxT)hSyzyGfaEFUUcnhn7qmbiisd9z9hSsaMs17Z1vil)U)Se2XajuwUjlrHlw8gz5kwCwigaz5HS4aGhil)oYc9(L)hSyX(o2ilolFFfj4Zc(bwokllkcYYvSOJVDelwco9Pjab4DU8ymb4vzIbWKpzlK(KuNaelxxHGjJlbOh(dwja1XMInjxrmbiisd9z9hSsaoEuKLXHnfBsUIil(ZYVJSGfilWjlKMgRueLf77yXYUtFKLJYIRdbGSq6hJ0Pjw85JnlKcwaGKGSy)(Dwgh0tnlEbYc83X2(rrwSF)olKARKD8RqcWqFp2NNamnlPzjcwcqay51BQJ4(NNoYYWalrWsacvGq7LjalaqsW8VJzQ113tnllwggyjcw6vHtyten6UYRaMHZSRu5F)kIudwUUcbzzelAzrFnNMGNVkyAm2VIYYMSqUgzrll6R500oaSGlAE2yLIOMgJ9ROSqqwiuw0YseSeGaWYR3aaRFpAZYWalbiaS86naW63J2SOLf91CAcE(QGzzXIww0xZPPDaybx08SXkfrnllw0YsAw0xZPPDaybx08SXkfrnng7xrzHGrYc52WIMXcHYsQyPxfoHnr0qVAUu59O0h7Zny56keKLHbw0xZPj45RcMgJ9ROSqqwiNCwggyHCwilluluPY7o9rwiilKBi9SmILrSOLfaEFUUcnxLjgat(KTqAtsDcqSCDfcMmUeGH(ESppbyAw0xZPj45RcMgJ9ROSSjlKRrw0YsAwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyrFnNM2bGfCrZZgRue10ySFfLfcYc5Pew0YI(AonTdal4IMNnwPiQzzXYiwggyrhsPSOLL5rC)Zng7xrzHGSyJgzzelAzbG3NRRqZvzIbWeGGin0N1FWkbiHa(Sy)(DwCwi1wj74xbw(D)z5O12ploleILI6nlwnmWcSzX(owS87ilZJ4(ZYrzX1HRNLhYcwGja9WFWkbOf8pyL8jBrZtsDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbyapflPzjnlZJ4(NBm2VIYIMXc5AKfnJLaeQaH2ltWZxfmng7xrzzelKLfY18XyzelBYsapflPzjnlZJ4(NBm2VIYIMXc5AKfnJLaeQaH2ltawaGKG5FhZuRRVNAAm2VIYYiwillKR5JXYiw0YseS0(bMray9gheKAqcF0NYIwwsZseSeGqfi0EzcE(QGPrhmklddSeblbiubcTxMaSaajbZ)oMPwxFp10OdgLLrSmmWsacvGq7Lj45RcMgJ9ROSSjlx9yBbv(JG55rC)Zng7xrzzyGLEv4e2ertavi9pxLPwxFp1GLRRqqw0YsacvGq7Lj45RcMgJ9ROSSjl2EmwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSSjlx9yBbv(JG55rC)Zng7xrzrZyH8XyzyGLiyjabGLxVPoI7FE6ycqqKg6Z6pyLaKuUkSu(JuwSVJ)o2SSOxrKfsblaqsqwkODwSFkflUsbTZsu4ILhYc9pLILGtFw(DKfQhJS4XWv9SaNSqkybascsasTvYo(vGLGtFAcqaENlpgtagGfaijygePrRqYNSLussQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjatZY7nr8n)fJ5hMbpKLnzHCnYYWalTFGzeawVXbbPMRyztw04ySmIfTSKML0SG266SSqqdgBfTrxLHny5vazrllPzjcwcqay51BaG1VhTzzyGLaeQaH2ldgBfTrxLHny5vanng7xrzHGSqoPN0YcbyjnlAKLuXsVkCcBIOHE1CPY7rPp2NBWY1viilJyzelAzjcwcqOceAVmySv0gDvg2GLxb00OdgLLrSmmWcARRZYcbnu4sPW)VIyUx6rzrllPzjcwcqay51BQJ4(NNoYYWalbiubcTxgkCPu4)xrm3l9OzBtOAuZhJCtJX(vuwiilKtoHYYiwggyjnlbiubcTxgDSPytYvenn6GrzzyGLiyP9aA(gQuSmmWsacalVEtDe3)80rwgXIwwsZseS8UcR3mxD0mCMr1QqdwUUcbzzyGLaeawE9gay97rBw0YsacvGq7LzU6Oz4mJQvHMgJ9ROSqqwiNCwialAKLuXsVkCcBIOHE1CPY7rPp2NBWY1viilddSeblbiaS86naW63J2SOLLaeQaH2lZC1rZWzgvRcnng7xrzHGSOVMttWZxfmGR2)dwSqawi3gwsfl9QWjSjIgR(IHn45QS3bVUq2APOEBWY1viilAglKBdlJyrllPzbT11zzHGMROHE9UUcZ26YRFfNbraxazrllbiubcTxMROHE9UUcZ26YRFfNbraxanng7xrzHGSOrwgXYWalPzjnlOTUolle0q3DqODemdB9mCMFyhJ1ZIwwcqOceAVmpSJX6rW8v0J4(NTTg1OTTHCtJX(vuwgXYWalPzjnla8(CDfAGvErX83xrc(SejlKZYWala8(CDfAGvErX83xrc(Sejl2MLrSOLL0S89vKGV5j30OdgnhGqfi0EXYWalFFfj4BEYnbiubcTxMgJ9ROSSjlx9yBbv(JG55rC)Zng7xrzrZyH8XyzelddSaW7Z1vObw5ffZFFfj4ZsKSydlAzjnlFFfj4BEBmn6GrZbiubcTxSmmWY3xrc(M3gtacvGq7LPXy)kklBYYvp2wqL)iyEEe3)CJX(vuw0mwiFmwgXYWala8(CDfAGvErX83xrc(SejlJXYiwgXYOeGGin0N1FWkb44rrqwEilGOYJYYVJSSOorKf4KfsTvYo(vGf77yXYIEfrwaHlDfYcSyzrrw8cKfRgbG1ZYI6erwSVJflEXIdcYccaRNLJYIRdxplpKfWdtacW7C5XycWayoalW7pyL8jBH8XssDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbyeSqHlL(vGMFVpLktrKeSny56keKLHbwMhX9p3ySFfLLnzXMXgJLHbw0HuklAzzEe3)CJX(vuwiil2OrwialPzHqhJfnJf91CA(9(uQmfrsW2qFpqclPIfByzelddSOVMtZV3NsLPisc2g67bsyztwSTMZIMXsAw6vHtyten0RMlvEpk9X(CdwUUcbzjvSydlJsacI0qFw)bReGPu9(CDfYYIIGS8qwarLhLfVIYY3xrc(uw8cKLaiLf77yXID)(RiYYe2S4flAWYAh2NZIvddjab4DU8ymb4V3NsLPisc2z7(9jFYwiN8KuNaelxxHGjJlbiisd9z9hSsaoEuKfni2kAJUIfBXgS8kGSyZyumqzrhNWgzXzHuBLSJFfyzrrwGnluil)U)SCpl2pLIf1villlwSF)ol)oYcwGSaNSqAASsr0eGLhJjaXyROn6QmSblVcycWqFp2NNamaHkqO9Ye88vbtJX(vuwiil2mglAzjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSqqwSzmw0YsAwa4956k0879PuzkIKGD2UFplddSOVMtZV3NsLPisc2g67bsyztwS9ySqawsZsVkCcBIOHE1CPY7rPp2NBWY1viilPIfBZYiwgXIwwa4956k0CvMyaKLHbw0HuklAzzEe3)CJX(vuwiil2M0Ma0d)bReGySv0gDvg2GLxbm5t2c52KK6eGy56kemzCjabrAOpR)GvcWXJISaeUuk8VIileYw6rzH0tXaLfDCcBKfNfsTvYo(vGLffzb2SqHS87(ZY9Sy)ukwuxHSSSyX(97S87ilybYcCYcPPXkfrtawEmMaKcxkf()veZ9spAcWqFp2NNamnlbiubcTxMGNVkyAm2VIYcbzH0ZIwwIGLaeawE9gay97rBw0YseSeGaWYR3uhX9ppDKLHbwcqay51BQJ4(NNoYIwwcqOceAVmbybascM)DmtTU(EQPXy)kkleKfsplAzjnla8(CDfAcWcaKemdI0OvGLHbwcqOceAVmbpFvW0ySFfLfcYcPNLrSmmWsacalVEdaS(9OnlAzjnlrWsVkCcBIOHE1CPY7rPp2NBWY1viilAzjaHkqO9Ye88vbtJX(vuwiilKEwggyrFnNM2bGfCrZZgRue10ySFfLfcYc5JXcbyjnlAKLuXcARRZYcbnxr)EfEytZGhGRWSoQuSmIfTSOVMtt7aWcUO5zJvkIAwwSmILHbw0HuklAzzEe3)CJX(vuwiil2OrwggybT11zzHGgm2kAJUkdBWYRaYIwwcqOceAVmySv0gDvg2GLxb00ySFfLLnzXMXyzelAzbG3NRRqZvzIbqw0YseSG266SSqqZv0qVExxHzBD51VIZGiGlGSmmWsacvGq7L5kAOxVRRWSTU86xXzqeWfqtJX(vuw2KfBgJLHbw0HuklAzzEe3)CJX(vuwiil2mwcqp8hSsasHlLc))kI5EPhn5t2c52oj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeG6R50e88vbtJX(vuw2KfY1ilAzjnlrWsVkCcBIOHE1CPY7rPp2NBWY1viilddSOVMtt7aWcUO5zJvkIAAm2VIYcbJKfY1OrJSqawsZITnAKLuXI(Aon6kieuTOVzzXYiwialPzHqnAKfnJfBB0ilPIf91CA0vqiOArFZYILrSKkwqBDDwwiO5k63RWdBAg8aCfM1rLIfcWcHA0ilPIL0SG266SSqqZVJ5510ptpINIfTSeGqfi0Ez(DmpVM(z6r8uMgJ9ROSqWizXMXyzelAzrFnNM2bGfCrZZgRue1SSyzelddSOdPuw0YY8iU)5gJ9ROSqqwSrJSmmWcARRZYcbnySv0gDvg2GLxbKfTSeGqfi0EzWyROn6QmSblVcOPXy)kAcqqKg6Z6pyLaCRk7EukllkYY4NsPTKf73VZcP2kzh)kWcSzXFw(DKfSazbozH00yLIOjab4DU8ymb4zRG5aSaV)GvYNSfYj0KuNaelxxHGjJlbOh(dwjaVIg6176kmBRlV(vCgebCbmbyOVh7ZtacW7Z1vO5SvWCawG3FWIfTSaW7Z1vO5QmXaycWYJXeGxrd96DDfMT1Lx)kodIaUaM8jBHCnMK6eGy56kemzCjabrAOpR)GvcWXJISaC3bH2rqwSfBDw0XjSrwi1wj74xHeGLhJjaP7oi0ocMHTEgoZpSJX6tag67X(8eGPzjaHkqO9Ye88vbtJoyuw0YseSeGaWYR3uhX9ppDKfTSaW7Z1vO537tPYuejb7SD)Ew0YsAwcqOceAVm6ytXMKRiAA0bJYYWalrWs7b08nuPyzelddSeGaWYR3uhX9ppDKfTSeGqfi0EzcWcaKem)7yMAD99utJoyuw0YsAwa4956k0eGfaijygePrRalddSeGqfi0EzcE(QGPrhmklJyzelAzbe(g6QMxJM)cKCfrw0YsAwaHVH(Os5DEQ8gn)fi5kISmmWseS8UcR3qFuP8opvEJgSCDfcYYWaluluPYV3eXNAOV3ZRrw2KfBZYiw0Yci8nXqynVgn)fi5kISOLL0SaW7Z1vO5OzhISmmWsVkCcBIOr3vEfWmCMDLk)7xrKAWY1viilddS40VDv2cAhBw2mswsjJXYWala8(CDfAcWcaKemdI0OvGLHbw0xZPrxbHGQf9nllwgXIwwIGf0wxNLfcAUIg6176kmBRlV(vCgebCbKLHbwqBDDwwiO5kAOxVRRWSTU86xXzqeWfqw0YsacvGq7L5kAOxVRRWSTU86xXzqeWfqtJX(vuw2KfBpglAzjcw0xZPj45RcMLflddSOdPuw0YY8iU)5gJ9ROSqqwi0Xsa6H)Gvcq6UdcTJGzyRNHZ8d7yS(KpzlKt6tsDcqSCDfcMmUeGGin0N1FWkbyQ3pklhLfNL2)DSzbvUoS9hzXUhLLhYsStcYIRuSalwwuKf67plFFfj4tz5HSOJSOUcbzzzXI973zHuBLSJFfyXlqwifSaajbzXlqwwuKLFhzXMcKfQc(SalwcGSCtw0H)olFFfj4tzXBKfyXYIISqF)z57RibFAcWqFp2NNamnla8(CDfAGvErX83xrc(SerKSqolAzjcw((ksW382yA0bJMdqOceAVyzyGL0SaW7Z1vObw5ffZFFfj4ZsKSqolddSaW7Z1vObw5ffZFFfj4ZsKSyBwgXIwwsZI(AonbpFvWSSyrllPzjcwcqay51BaG1VhTzzyGf91CAAhawWfnpBSsrutJX(vuwialPzX2gnYsQyPxfoHnr0qVAUu59O0h7Zny56keKLrSqWiz57RibFZtUrFnNzWv7)blw0YI(AonTdal4IMNnwPiQzzXYWal6R500oaSGlAE2yLIOz6vZLkVhL(yFUzzXYiwggyjaHkqO9Ye88vbtJX(vuwial2WYMS89vKGV5j3eGqfi0EzaxT)hSyrllrWI(AonbpFvWSSyrllPzjcwcqay51BQJ4(NNoYYWalrWcaVpxxHMaSaajbZGinAfyzelAzjcwcqay51BijAFEXYWalbiaS86n1rC)Zthzrlla8(CDfAcWcaKemdI0OvGfTSeGqfi0EzcWcaKem)7yMAD99uZYIfTSeblbiubcTxMGNVkywwSOLL0SKMf91CAWG6SOywTkVnng7xrzztwiFmwggyrFnNgmOolkMPqL3MgJ9ROSSjlKpglJyrllrWsVkCcBIOr3vEfWmCMDLk)7xrKAWY1viilddSKMf91CA0DLxbmdNzxPY)(veP5Y)vJg67bsyjsw0ilddSOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqclrYIMZYiwgXYWal6R50qYvGncMXylODSJX6ZyHnXlfOzzXYiwggyrhsPSOLL5rC)Zng7xrzHGSyZySmmWcaVpxxHgyLxum)9vKGplrYYySmIfTSaW7Z1vO5QmXaycqQc(0eGFFfj4tEcqp8hSsa(9vKGp5jFYwiN0MK6eGy56kemzCja9WFWkb43xrc(2Kam03J95jatZcaVpxxHgyLxum)9vKGplrejl2WIwwIGLVVIe8np5MgDWO5aeQaH2lwggybG3NRRqdSYlkM)(ksWNLizXgw0YsAw0xZPj45RcMLflAzjnlrWsacalVEdaS(9OnlddSOVMtt7aWcUO5zJvkIAAm2VIYcbyjnl22Orwsfl9QWjSjIg6vZLkVhL(yFUblxxHGSmIfcgjlFFfj4BEBm6R5mdUA)pyXIww0xZPPDaybx08SXkfrnllwggyrFnNM2bGfCrZZgRuentVAUu59O0h7ZnllwgXYWalbiubcTxMGNVkyAm2VIYcbyXgw2KLVVIe8nVnMaeQaH2ld4Q9)GflAzjcw0xZPj45RcMLflAzjnlrWsacalVEtDe3)80rwggyjcwa4956k0eGfaijygePrRalJyrllrWsacalVEdjr7Zlw0YsAwIGf91CAcE(QGzzXYWalrWsacalVEdaS(9OnlJyzyGLaeawE9M6iU)5PJSOLfaEFUUcnbybascMbrA0kWIwwcqOceAVmbybascM)DmtTU(EQzzXIwwIGLaeQaH2ltWZxfmllw0YsAwsZI(AonyqDwumRwL3MgJ9ROSSjlKpglddSOVMtdguNffZuOYBtJX(vuw2KfYhJLrSOLLiyPxfoHnr0O7kVcygoZUsL)9Risny56keKLHbwsZI(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajSejlAKLHbw0xZPr3vEfWmCMDLk)7xrKM9o4fAOVhiHLizrZzzelJyzelddSOVMtdjxb2iygJTG2XogRpJf2eVuGMLflddSOdPuw0YY8iU)5gJ9ROSqqwSzmwggybG3NRRqdSYlkM)(ksWNLizzmwgXIwwa4956k0CvMyambivbFAcWVVIe8Tj5t2c5AEsQtaILRRqWKXLaeePH(S(dwjahpkszXvkwG)o2SalwwuKL7XyklWILaycqp8hSsaUOy(EmMM8jBH8ussQtaILRRqWKXLaeePH(S(dwja1G73XMfIqwU6HS87il0NfyZIdrw8WFWIf1r)eGE4pyLaSxv2d)bRS6OFcq63x4t2c5jad99yFEcqaEFUUcnhn7qmbO6OFU8ymbOdXKpzl2mwsQtaILRRqWKXLa0d)bReG9QYE4pyLvh9taQo6Nlpgtas)Kp5taA1yagR7FsQt2c5jPobOh(dwjaj5kWgbZuRRVNMaelxxHGjJl5t2InjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMaCSeGGin0N1FWkbyQ3rwa4956kKLJYcfFwEilJXI973zPGSqF)zbwSSOilFFfj4t1elKZI9DSy53rwMxtFwGfYYrzbwSSOOMyXgwUjl)oYcfdWcKLJYIxGSyBwUjl6WFNfVXeGa8oxEmMaew5ffZFFfj4N8jBX2jPobiwUUcbtgxcqOvcqhembOh(dwjab4956kmbiaxTWeGKNam03J95ja)(ksW38KB2DAErXS(AozrllFFfj4BEYnbiubcTxgWv7)blw0YseS89vKGV5j3CuZdJXmCMJHf9B4IMdWI(9k8hSOjab4DU8ymbiSYlkM)(ksWp5t2cHMK6eGy56kemzCjaHwjaDqWeGE4pyLaeG3NRRWeGaC1ctaAtcWqFp2NNa87RibFZBJz3P5ffZ6R5KfTS89vKGV5TXeGqfi0EzaxT)hSyrllrWY3xrc(M3gZrnpmgZWzogw0VHlAoal63RWFWIMaeG35YJXeGWkVOy(7Rib)KpzlAmj1jaXY1viyY4sacTsa6GGja9WFWkbiaVpxxHjab4DU8ymbiSYlkM)(ksWpbyOVh7ZtaI266SSqqZv0qVExxHzBD51VIZGiGlGSmmWcARRZYcbnySv0gDvg2GLxbKLHbwqBDDwwiOHcxkf()veZ9spAcqqKg6Z6pyLam17ifz57RibFklEJSuWNfF9Wy)VGRurzbeFm8iiloLfyXYIISqF)z57RibFQHfwaIpla8(CDfYYdzHqzXPS87yuwCffYsHiilulmCUILDVavxr0KaeGRwycqcn5t2cPpj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeG2EmwsflPzHCw0mwgZqUgzjvSqXpRdRf18h22O5zc1kWYOeGGin0N1FWkbiq8PS87ilaFVPRMiYsasFwMWMfL)yZsWvHLY)dwuwspHnliH9ylfYI9DSy5HSqFVFwaxXwxrKfDCcBKfstJvkIYY0vkklW5CucqaENlpgtasP5aK(jFYwiTjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMauJJXsQyjnlKZIMXYygY1ilPIfk(zDyTOM)W2gnptOwbwgLaeG35YJXeG0zoaPFYNSfnpj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeG2EmwialKpglPILEv4e2ertavi9pxLPwxFp1GLRRqWeGGin0N1FWkbiq8PS4pl23VWolEmCvplWjlBLsiyHuWcaKeKf6oCPazrhzzrrWuMfcDmwSF)oC9SqkuH0)CflaTU(EklEbYIThJf73VBsacW7C5XycWaSaajbZo1k5t2skjj1ja9WFWkbymewKCvEc74eGy56kemzCjFYwiFSKuNaelxxHGjJlbOh(dwjaT3(VNam03J95jatZcguNffnQv5DUqc)SmmWcguNffnxLPqL3SmmWcguNffnxL1H)olddSGb1zrrJxrZfs4NLrjavxH5aycqYhl5t(eGoetsDYwipj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeG9QWjSjIM)Ir7WUYGn6X6xbITblxxHGSOLL0SOVMtZFXODyxzWg9y9RaX20ySFfLfcYcXaOj2jmleGLXmKZYWal6R508xmAh2vgSrpw)kqSnng7xrzHGS4H)GLH(EpVgniHXW6X8FXileGLXmKZIwwsZcguNffnxLvRYBwggybdQZIIgku5DUqc)SmmWcguNffnEfnxiHFwgXYiw0YI(Aon)fJ2HDLbB0J1VceBZYkbiisd9z9hSsaskxfwk)rkl23XFhBw(DKfBzJECW)Wo2SOVMtwSFkfltxPyboNSy)(9Ry53rwkKWplbN(jab4DU8ymbiyJEC2(Pu5PRuz4CM8jBXMKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctagblyqDwu0CvMcvEZIwwOwOsLFVjIp1qFVNxJSSjlKww0mwExH1BOWLkdN5FhZtyJ03GLRRqqwsfl2WcbybdQZIIMRY6WFNfTSebl9QWjSjIgR(IHn45QS3bVUq2APOEBWY1viilAzjcw6vHtytenWc)DAoOqVZao6bldwUUcbtacI0qFw)bReGKYvHLYFKYI9D83XMfGV30vtez5OSyh2)olbN(xrKfiaSzb4798AKLRyHmxL3SObb1zrXeGa8oxEmMa8iwWgZ03B6QjIjFYwSDsQtaILRRqWKXLa0d)bReGbybascM)DmtTU(EAcqqKg6Z6pyLaC8OilKcwaGKGSyFhlw8NffsPS87EXIghJLTsjeS4filQRqwwwSy)(Dwi1wj74xHeGH(ESppbyeSa2Rd0uWCaKYIwwsZsAwa4956k0eGfaijygePrRalAzjcwcqOceAVmbpFvW0OdgLfTSebl9QWjSjIgR(IHn45QS3bVUq2APOEBWY1viilddSOVMttWZxfmllw0YsAwIGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLHbw6vHtytenbuH0)CvMAD99udwUUcbzzyGL5rC)Zng7xrzztwi3gsllddSOdPuw0YY8iU)5gJ9ROSqqwcqOceAVmbpFvW0ySFfLfcWc5JXYWal6R50e88vbtJX(vuw2KfYTHLrSmIfTSKML0SKMfN(TRYwq7yZcbJKfaEFUUcnbybascMDQflddSqTqLk)EteFQH(EpVgzztwSnlJyrllPzrFnNgmOolkMvRYBtJX(vuw2KfYhJLHbw0xZPbdQZIIzku5TPXy)kklBYc5JXYiwggyrFnNMGNVkyAm2VIYYMSOrw0YI(AonbpFvW0ySFfLfcgjlKBdlJyrllPzjcwExH1BOpQuENb7B(gSCDfcYYWal6R50qFVNUszAm2VIYcbzHCJgzrZyzmJgzjvS0RcNWMiAcOcP)5Qm1667PgSCDfcYYWal6R50e88vbtJX(vuwiil6R50qFVNUszAm2VIYcbyrJSOLf91CAcE(QGzzXYiw0YsAwIGLEv4e2erZFXODyxzWg9y9RaX2GLRRqqwggyjcw6vHtytenbuH0)CvMAD99udwUUcbzzyGf91CA(lgTd7kd2OhRFfi2MgJ9ROSSjliHXW6X8FXilJyzyGLEv4e2erJUR8kGz4m7kv(3VIi1GLRRqqwgXIwwsZseS0RcNWMiA0DLxbmdNzxPY)(vePgSCDfcYYWalPzrFnNgDx5vaZWz2vQ8VFfrAU8F1OH(EGewIKfnNLHbw0xZPr3vEfWmCMDLk)7xrKM9o4fAOVhiHLizrZzzelJyzyGfDiLYIwwMhX9p3ySFfLfcYc5JXIwwIGLaeQaH2ltWZxfmn6GrzzuYNSfcnj1jaXY1viyY4sa6H)Gvcq6QMxJjadrdkm)EteFAYwipbyOVh7ZtaMMLgNns3DDfYYWal6R50Gb1zrXmfQ820ySFfLfcYITzrllyqDwu0CvMcvEZIwwAm2VIYcbzHCcLfTS8UcR3qHlvgoZ)oMNWgPVblxxHGSmIfTS8EteFZFXy(HzWdzztwiNqzrZyHAHkv(9Mi(uwialng7xrzrllPzbdQZIIMRYEfLLHbwAm2VIYcbzHya0e7eMLrjabrAOpR)GvcWXJISaCvZRrwUIflVaX4lWcSyXRO)(vez539Nf1baPSqoHsXaLfVazrHukl2VFNLyyJS8EteFklEbYI)S87ilybYcCYIZcqOYBw0GG6SOil(Zc5eklumqzb2SOqkLLgJ9RUIiloLLhYsbFw2DaxrKLhYsJZgP7SaU6RiYczUkVzrdcQZIIjFYw0ysQtaILRRqWKXLa0d)bReG0vnVgtacI0qFw)bReGJhfzb4QMxJS8qw2DailolevqDxXYdzzrrwg)ukTLjad99yFEcqaEFUUcnNTcMdWc8(dwSOLLaeQaH2lZv0qVExxHzBD51VIZGiGlGMgDWOSOLf0wxNLfcAUIg6176kmBRlV(vCgebCbKfTS4w5Wogij5t2cPpj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkbykneTyzzXcW37PRuS4plUsXYFXiLLvPqkLLf9kISqMrdE7uw8cKL7z5OS46W1ZYdzXQHbwGnlk8z53rwOwy4CflE4pyXI6kKfDubTZYUxGkKfBzJES(vGyZcSyXgwEVjIpnbyOVh7ZtagblVRW6n0hvkVZG9nFdwUUcbzrllPzjcwO4N1H1IA(dBB08mHAfyzyGfmOolkAUk7vuwggyHAHkv(9Mi(ud99E6kflBYITzzelAzjnl6R50qFVNUszAC2iD31vilAzjnluluPYV3eXNAOV3txPyHGSyBwggyjcw6vHtyten)fJ2HDLbB0J1VceBdwUUcbzzelddS8UcR3qHlvgoZ)oMNWgPVblxxHGSOLf91CAWG6SOyMcvEBAm2VIYcbzX2SOLfmOolkAUktHkVzrll6R50qFVNUszAm2VIYcbzH0YIwwOwOsLFVjIp1qFVNUsXYMrYcHYYiw0YsAwIGLEv4e2erJkAWBNMNke)RiMjQUylkAWY1viilddS8xmYcPJfcvJSSjl6R50qFVNUszAm2VIYcbyXgwgXIwwEVjIV5Vym)Wm4HSSjlAm5t2cPnj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkbiH097Sa8rLYBwSL9nFwwuKfyXsaKf77yXsJZgP7UUczrF9Sq)tPyXUFpltyZczgn4TtzXQHbw8cKfqyT9ZYIISOJtyJSqkBj1WcW)ukwwuKfDCcBKfsblaqsqwOxfqw(D)zX(PuSy1WalEb)DSzb4790vQeGH(ESppb47kSEd9rLY7myFZ3GLRRqqw0YI(Aon037PRuMgNns3DDfYIwwsZseSqXpRdRf18h22O5zc1kWYWalyqDwu0Cv2ROSmmWc1cvQ87nr8Pg6790vkw2KfcLLrSOLL0Sebl9QWjSjIgv0G3onpvi(xrmtuDXwu0GLRRqqwggy5VyKfshleQgzztwiuwgXIwwEVjIV5Vym)Wm4HSSjl2o5t2IMNK6eGy56kemzCja9WFWkbi99E6kvcqqKg6Z6pyLaKq6(DwSLn6X6xbInllkYcW37PRuS8qwibrlwwwS87il6R5Kf9OS4kkKLf9kISa89E6kflWIfnYcfdWcKYcSzrHuklng7xDfXeGH(ESppbyVkCcBIO5Vy0oSRmyJES(vGyBWY1viilAzHAHkv(9Mi(ud99E6kflBgjl2MfTSKMLiyrFnNM)Ir7WUYGn6X6xbITzzXIww0xZPH(EpDLY04Sr6URRqwggyjnla8(CDfAaB0JZ2pLkpDLkdNtw0YsAw0xZPH(EpDLY0ySFfLfcYITzzyGfQfQu53BI4tn037PRuSSjl2WIwwExH1BOpQuENb7B(gSCDfcYIww0xZPH(EpDLY0ySFfLfcYIgzzelJyzuYNSLussQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaD63UkBbTJnlBYIMpglPIL0SqolAglu8Z6WArn)HTnAE2gRalPILXm2WYiwsflPzHCw0mw0xZP5Vy0oSRmyJES(vGyBOVhiHLuXYygYzzelAglPzrFnNg6790vktJX(vuwsfl2MfYYc1cvQ8UtFKLuXseS8UcR3qFuP8od238ny56keKLrSOzSKMLaeQaH2ld99E6kLPXy)kklPIfBZczzHAHkvE3PpYsQy5DfwVH(Os5DgSV5BWY1viilJyrZyjnl6R50mxD0mCMr1QqtJX(vuwsflAKLrSOLL0SOVMtd99E6kLzzXYWalbiubcTxg6790vktJX(vuwgLaeePH(S(dwjajLRclL)iLf774VJnlolaFVPRMiYYIISy)ukwc(IISa89E6kflpKLPRuSaNtnXIxGSSOilaFVPRMiYYdzHeeTyXw2OhRFfi2SqFpqcllldlA(ySCuw(DKLgT111iilBLsiy5HSeC6ZcW3B6QjIea4790vQeGa8oxEmMaK(EpDLkBhwFE6kvgoNjFYwiFSKuNaelxxHGjJlbOh(dwjaPV30vtetacI0qFw)bReGJhfzb47nD1erwSF)ol2Yg9y9RaXMLhYcjiAXYYILFhzrFnNSy)(D46zrbPxrKfGV3txPyzz9xmYIxGSSOilaFVPRMiYcSyHqjalJdU1uZc99ajuww1FkwiuwEVjIpnbyOVh7ZtacW7Z1vObSrpoB)uQ80vQmCozrlla8(CDfAOV3txPY2H1NNUsLHZjlAzjcwa4956k0CelyJz67nD1erwggyjnl6R50O7kVcygoZUsL)9RisZL)Rgn03dKWYMSyBwggyrFnNgDx5vaZWz2vQ8VFfrA27GxOH(EGew2KfBZYiw0Yc1cvQ87nr8Pg6790vkwiileklAzbG3NRRqd99E6kv2oS(80vQmCot(KTqo5jPobiwUUcbtgxcqp8hSsa6GU1FaWm1U3Xjadrdkm)EteFAYwipbyOVh7Ztagbl)fi5kISOLLiyXd)blJd6w)baZu7EhNb9yNiAUkpvhX9NLHbwaHVXbDR)aGzQDVJZGESten03dKWcbzX2SOLfq4BCq36payMA374mOh7ertJX(vuwiil2obiisd9z9hSsaoEuKfQDVJzHcz539NLOWfleXNLyNWSSS(lgzrpkll6vez5EwCklk)rwCklwqk90vilWIffsPS87EXITzH(EGeklWMLukw0Nf77yXITjal03dKqzbjS11yYNSfYTjj1jaXY1viyY4sa6H)GvcWyiSMxJjadrdkm)EteFAYwipbyOVh7Zta24Sr6URRqw0YY7nr8n)fJ5hMbpKLnzjnlPzHCcLfcWsAwOwOsLFVjIp1qFVNxJSKkwSHLuXI(AonyqDwumRwL3MLflJyzeleGLgJ9ROSmIfYYsAwiNfcWY7kSEZB)QCmewudwUUcbzzelAzXPF7QSf0o2SSjla8(CDfAOZCasFw0mw0xZPH(EpDLY0ySFfLLuXcPNfTSKMf3kh2XajSmmWcaVpxxHMJybBmtFVPRMiYYWalrWcguNffnxL9kklJyrllPzjaHkqO9Ye88vbtJoyuw0YcguNffnxL9kklAzjcwa71bAkyoaszrllPzbG3NRRqtawaGKGzqKgTcSmmWsacvGq7LjalaqsW8VJzQ113tnn6GrzzyGLiyjabGLxVPoI7FE6ilJyzyGfQfQu53BI4tn03751ileKL0SKMfnNfnJL0SOVMtdguNffZQv5TzzXsQyX2SmILrSKkwsZc5SqawExH1BE7xLJHWIAWY1viilJyzelAzjcwWG6SOOHcvENlKWplAzjnlrWsacvGq7Lj45RcMgDWOSmmWcyVoqtbZbqklJyzyGL0SGb1zrrZvzku5nlddSOVMtdguNffZQv5TzzXIwwIGL3vy9gkCPYWz(3X8e2i9ny56keKLrSOLL0SqTqLk)EteFQH(EpVgzHGSq(ySKkwsZc5SqawExH1BE7xLJHWIAWY1viilJyzelJyrllPzjcwcqay51BijAFEXYWalrWI(AonKCfyJGzm2cAh7yS(mwyt8sbAwwSmmWcguNffnxLPqL3SmIfTSebl6R500oaSGlAE2yLIOz6vZLkVhL(yFUzzLaeePH(S(dwjajKHZgP7SylaH18AKLBYcP2kzh)kWYrzPrhmQMy53XgzXBKffsPS87EXIgz59Mi(uwUIfYCvEZIgeuNffzX(97Sae(KgnXIcPuw(DVyH8Xyb(7yB)OilxXIxrzrdcQZIISaBwwwS8qw0ilV3eXNYIooHnYIZczUkVzrdcQZIIgwSLWA7NLgNns3zbC1xrKLuAxb2iilAqSf0o2Xy9SSkfsPSCflaHkVzrdcQZIIjFYwi32jPobiwUUcbtgxcqp8hSsaoHDaZWzU8F1ycqqKg6Z6pyLaC8OilKg4wybwSeazX(97W1ZsWTSUIycWqFp2NNa0TYHDmqclddSaW7Z1vO5iwWgZ03B6QjIjFYwiNqtsDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbyeSa2Rd0uWCaKYIwwsZcaVpxxHMayoalW7pyXIwwsZI(Aon037PRuMLflddS8UcR3qFuP8od238ny56keKLHbwcqay51BQJ4(NNoYYiw0Yci8nXqynVgn)fi5kISOLL0Sebl6R50qHk6Fb0SSyrllrWI(AonbpFvWSSyrllPzjcwExH1BMRoAgoZOAvOblxxHGSmmWI(AonbpFvWaUA)pyXYMSeGqfi0EzMRoAgoZOAvOPXy)kkleGfnNLrSOLL0Seblu8Z6WArn)HTnAE2gRalddSGb1zrrZvz1Q8MLHbwWG6SOOHcvENlKWplJyrlla8(CDfA(9(uQmfrsWoB3VNfTSKMLiyjabGLxVPoI7FE6ilddSaW7Z1vOjalaqsWmisJwbwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSqqwixJSmIfTS8EteFZFXy(HzWdzztw0xZPj45RcgWv7)blwsflJziTSmILHbw0HuklAzzEe3)CJX(vuwiil6R50e88vbd4Q9)GfleGfYTHLuXsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYYOeGa8oxEmMamaMdWc8(dwzhIjFYwixJjPobiwUUcbtgxcqp8hSsa2oaSGlAE2yLIOjabrAOpR)GvcWXJISqAASsruwSF)olKARKD8RqcWqFp2NNauFnNMGNVkyAm2VIYYMSqUgzzyGf91CAcE(QGbC1(FWIfcWc52WsQyPxfoHnr0y1xmSbpxL9o41fYwlf1BdwUUcbzHGSydPNfTSaW7Z1vOjaMdWc8(dwzhIjFYwiN0NK6eGy56kemzCja9WFWkbyavi9pxLD1rSIX6tacI0qFw)bReGJhfzHuBLSJFfybwSeazzvkKszXlqwuxHSCplllwSF)olKcwaGKGjad99yFEcqaEFUUcnbWCawG3FWk7qKfTSKMLiyjabGLxVbaw)E0MLHbwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyPxfoHnr0y1xmSbpxL9o41fYwlf1BdwUUcbzzyGf91CAcE(QGbC1(FWILnJKfBi9SmILHbw0xZPPDaybx08SXkfrnllw0YI(AonTdal4IMNnwPiQPXy)kkleKfY1OrJjFYwiN0MK6eGy56kemzCjad99yFEcqaEFUUcnbWCawG3FWk7qmbOh(dwjaVk4D5)bRKpzlKR5jPobiwUUcbtgxcqp8hSsaIXwq7yN1HfycqqKg6Z6pyLaC8OilAqSf0o2SmoybYcSyjaYI973zb4790vkwwwS4filuhaYYe2SqiwkQ3S4filKARKD8RqcWqFp2NNamnlbiubcTxMGNVkyAm2VIYcbyrFnNMGNVkyaxT)hSyHaS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSKkwi3gw2KLaeQaH2ldgBbTJDwhwGgWv7)blwialKpglJyzyGf91CAcE(QGPXy)kklBYIMZYWalG96anfmhaPjFYwipLKK6eGy56kemzCja9WFWkbi9rLY78u5nMamenOW87nr8PjBH8eGH(ESppbyJZgP7UUczrll)fJ5hMbpKLnzHCnYIwwOwOsLFVjIp1qFVNxJSqqwiuw0YIBLd7yGew0YsAw0xZPj45RcMgJ9ROSSjlKpglddSebl6R50e88vbZYILrjabrAOpR)Gvcqcz4Sr6oltL3ilWILLflpKfBZY7nr8PSy)(D46zHuBLSJFfyrhVIilUoC9S8qwqcBDnYIxGSuWNfiaSdUL1vet(KTyZyjPobiwUUcbtgxcqp8hSsaoxD0mCMr1QWeGGin0N1FWkb44rrwinqnGLBYYv0dezXlw0GG6SOilEbYI6kKL7zzzXI973zXzHqSuuVzXQHbw8cKLTc6w)bazbODVJtag67X(8eGyqDwu0Cv2ROSOLL0S4w5WogiHLHbwIGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLrSOLL0SOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGSyJghJLHbw0xZPj45RcMgJ9ROSSjlAolJyrllPzbe(gh0T(daMP29ood6Xor08xGKRiYYWalrWsacalVEtHHgQGnilddSqTqLk)EteFklBYInSmIfTSKMf91CAAhawWfnpBSsrutJX(vuwiilPew0mwsZcHYsQyPxfoHnr0qVAUu59O0h7Zny56keKLrSOLf91CAAhawWfnpBSsruZYILHbwIGf91CAAhawWfnpBSsruZYILrSOLL0SeblbiubcTxMGNVkywwSmmWI(Aon)EFkvMIijyBOVhiHfcYc5AKfTSmpI7FUXy)kkleKfBgBmw0YY8iU)5gJ9ROSSjlKp2ySmmWseSqHlL(vGMFVpLktrKeSny56keKLrSOLL0SqHlL(vGMFVpLktrKeSny56keKLHbwcqOceAVmbpFvW0ySFfLLnzX2JXYiw0YY7nr8n)fJ5hMbpKLnzrJSmmWIoKszrllZJ4(NBm2VIYcbzH8Xs(KTyd5jPobiwUUcbtgxcqp8hSsasFVNUsLaeePH(S(dwjahpkYIZcW37PRuSylw4VZIvddSSkfsPSa89E6kflhLfx1OdgLLLflWMLOWflEJS46W1ZYdzbca7GBXYwPeIeGH(ESppbO(AonWc)DA2c7aA9hSmllw0YsAw0xZPH(EpDLY04Sr6URRqwggyXPF7QSf0o2SSjlPKXyzuYNSfBSjj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkbOTCfBXYwPecw0XjSrwifSaajbzX(97Sa89E6kflEbYYVJflaFVPRMiMam03J95jadqay51BQJ4(NNoYIwwIGL3vy9g6JkL3zW(MVblxxHGSOLL0SaW7Z1vOjalaqsWmisJwbwggyjaHkqO9Ye88vbZYILHbw0xZPj45RcMLflJyrllbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcYcXaOj2jmlPILaEkwsZIt)2vzlODSzHSSaW7Z1vOHoZbi9zzelAzrFnNg6790vktJX(vuwiileklAzjcwa71bAkyoast(KTyJTtsDcqSCDfcMmUeGH(ESppbyacalVEtDe3)80rw0YsAwa4956k0eGfaijygePrRalddSeGqfi0EzcE(QGzzXYWal6R50e88vbZYILrSOLLaeQaH2ltawaGKG5FhZuRRVNAAm2VIYcbzrJSOLfaEFUUcn037PRuz7W6ZtxPYW5KfTSGb1zrrZvzVIYIwwIGfaEFUUcnhXc2yM(EtxnrKfTSeblG96anfmhaPja9WFWkbi99MUAIyYNSfBi0KuNaelxxHGjJlbOh(dwjaPV30vtetacI0qFw)bReGJhfzb47nD1erwSF)olEXITyH)olwnmWcSz5MSefU2gKfiaSdUflBLsiyX(97SefUAwkKWplbN(gw2QIczbCfBXYwPecw8NLFhzblqwGtw(DKLuQy97rBw0xZjl3KfGV3txPyXoCPaRTFwMUsXcCozb2SefUyXBKfyXInS8EteFAcWqFp2NNauFnNgyH)onhuO3zah9GLzzXYWalPzjcwOV3ZRrJBLd7yGew0YseSaW7Z1vO5iwWgZ03B6QjISmmWsAw0xZPj45RcMgJ9ROSqqw0ilAzrFnNMGNVkywwSmmWsAwsZI(AonbpFvW0ySFfLfcYcXaOj2jmlPILaEkwsZIt)2vzlODSzHSSaW7Z1vOHsZbi9zzelAzrFnNMGNVkywwSmmWI(AonTdal4IMNnwPiAME1CPY7rPp2NBAm2VIYcbzHya0e7eMLuXsapflPzXPF7QSf0o2Sqwwa4956k0qP5aK(SmIfTSOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MLflJyrllbiaS86naW63J2SmILrSOLL0SqTqLk)EteFQH(EpDLIfcYITzzyGfaEFUUcn037PRuz7W6ZtxPYW5KLrSmIfTSebla8(CDfAoIfSXm99MUAIilAzjnlrWsVkCcBIO5Vy0oSRmyJES(vGyBWY1viilddSqTqLk)EteFQH(EpDLIfcYITzzuYNSfB0ysQtaILRRqWKXLa0d)bReGfAphdHvcqqKg6Z6pyLaC8Oil2cqyrz5kwacvEZIgeuNffzXlqwOoaKfsZsPyXwaclwMWMfsTvYo(vibyOVh7ZtaMMf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmmWsAwc7EtePSejl2WIwwAmS7nrm)xmYcbzrJSmILHbwc7EtePSejl2MLrSOLf3kh2XajjFYwSH0NK6eGy56kemzCjad99yFEcW0SOVMtdguNffZuOYBtJX(vuw2KfKWyy9y(VyKLHbwsZsy3BIiLLizXgw0YsJHDVjI5)IrwiilAKLrSmmWsy3BIiLLizX2SmIfTS4w5WogiHfTSKMf91CAAhawWfnpBSsrutJX(vuwiilAKfTSOVMtt7aWcUO5zJvkIAwwSOLLiyPxfoHnr0qVAUu59O0h7Zny56keKLHbwIGf91CAAhawWfnpBSsruZYILrja9WFWkb4URM5yiSs(KTydPnj1jaXY1viyY4sag67X(8eGPzrFnNgmOolkMPqL3MgJ9ROSSjliHXW6X8FXilAzjnlbiubcTxMGNVkyAm2VIYYMSOXXyzyGLaeQaH2ltawaGKG5FhZuRRVNAAm2VIYYMSOXXyzelddSKMLWU3erklrYInSOLLgd7EteZ)fJSqqw0ilJyzyGLWU3erklrYITzzelAzXTYHDmqclAzjnl6R500oaSGlAE2yLIOMgJ9ROSqqw0ilAzrFnNM2bGfCrZZgRue1SSyrllrWsVkCcBIOHE1CPY7rPp2NBWY1viilddSebl6R500oaSGlAE2yLIOMLflJsa6H)GvcW5sPYXqyL8jBXgnpj1jaXY1viyY4sacI0qFw)bReGJhfzHqcQbSalwiLTmbOh(dwjaT7DFWodNzuTkm5t2InPKKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctasTqLk)EteFQH(EpVgzztwiuwialtfe2SKMLyN(yhndWvlKLuXc5JnglKLfBgJLrSqawMkiSzjnl6R50qFVPRMiMXylODSJX6ZuOYBd99ajSqwwiuwgLaeePH(S(dwjajLRclL)iLf774VJnlpKLffzb4798AKLRybiu5nl23VWolhLf)zrJS8EteFkbiNLjSzbbGDuwSzmshlXo9XoklWMfcLfGV30vtezrdITG2XogRNf67bsOjab4DU8ymbi99EEnMVktHkVt(KTy7XssDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbi5SqwwOwOsL3D6JSqqwSHfnJL0SmMXgwsflPzHAHkv(9Mi(ud99EEnYIMXc5SmILuXsAwiNfcWY7kSEdfUuz4m)7yEcBK(gSCDfcYsQyHCJgzzelJyHaSmMHCnYsQyrFnNM2bGfCrZZgRue10ySFfnbiisd9z9hSsaskxfwk)rkl23XFhBwEilesT)7SaU6RiYcPPXkfrtacW7C5Xycq7T)75RYZgRuen5t2ITjpj1jaXY1viyY4sa6H)Gvcq7T)7jabrAOpR)GvcWXJISqi1(VZYvSaeQ8MfniOolkYcSz5MSuqwa(EpVgzX(PuSmVNLREilKARKD8RalEfng2ycWqFp2NNamnlyqDwu0OwL35cj8ZYWalyqDwu04v0CHe(zrlla8(CDfAoAoOqhaYYiw0YsAwEVjIV5Vym)Wm4HSSjleklddSGb1zrrJAvENVkBdlddSOdPuw0YY8iU)5gJ9ROSqqwiFmwgXYWal6R50Gb1zrXmfQ820ySFfLfcYIh(dwg6798A0GegdRhZ)fJSOLf91CAWG6SOyMcvEBwwSmmWcguNffnxLPqL3SOLLiybG3NRRqd99EEnMVktHkVzzyGf91CAcE(QGPXy)kkleKfp8hSm03751ObjmgwpM)lgzrllrWcaVpxxHMJMdk0bGSOLf91CAcE(QGPXy)kkleKfKWyy9y(VyKfTSOVMttWZxfmllwggyrFnNM2bGfCrZZgRue1SSyrlla8(CDfAS3(VNVkpBSsruwggyjcwa4956k0C0CqHoaKfTSOVMttWZxfmng7xrzztwqcJH1J5)IXKpzl22MKuNaelxxHGjJlbiisd9z9hSsaoEuKfGV3ZRrwUjlxXczUkVzrdcQZIIAILRybiu5nlAqqDwuKfyXcHsawEVjIpLfyZYdzXQHbwacvEZIgeuNffta6H)Gvcq6798Am5t2ITTDsQtaILRRqWKXLaeePH(S(dwjajnUs979kbOh(dwja7vL9WFWkRo6NauD0pxEmMaC6k1V3RKp5taoDL637vsQt2c5jPobiwUUcbtgxcqp8hSsasFVPRMiMaeePH(S(dwjab(EtxnrKLjSzjgcaJX6zzvkKszzrVIilJdU1uNam03J95jaJGLEv4e2erJUR8kGz4m7kv(3VIi1G266SSqWKpzl2KK6eGy56kemzCja9WFWkbiDvZRXeGHObfMFVjIpnzlKNam03J95jabHVjgcR51OPXy)kklBYsJX(vuwsfl2ydlKLfY18eGGin0N1FWkbiPC6ZYVJSacFwSF)ol)oYsmK(S8xmYYdzXbbzzv)Py53rwIDcZc4Q9)GflhLL97nSaCvZRrwAm2VIYs8s9NL6qqwEilX(h2zjgcR51ilGR2)dwjFYwSDsQta6H)GvcWyiSMxJjaXY1viyY4s(Kpbi9tsDYwipj1jaXY1viyY4sa6H)Gvcqh0T(daMP29oobyiAqH53BI4tt2c5jad99yFEcWiybe(gh0T(daMP29ood6Xor08xGKRiYIwwIGfp8hSmoOB9hamtT7DCg0JDIO5Q8uDe3Fw0YsAwIGfq4BCq36payMA3748o6kZFbsUIilddSacFJd6w)baZu7EhN3rxzAm2VIYYMSOrwgXYWalGW34GU1FaWm1U3Xzqp2jIg67bsyHGSyBw0Yci8noOB9hamtT7DCg0JDIOPXy)kkleKfBZIwwaHVXbDR)aGzQDVJZGESten)fi5kIjabrAOpR)GvcWXJISSvq36pailaT7Dml23XILFhBKLJYsbzXd)bazHA37ynXItzr5pYItzXcsPNUczbwSqT7Dml2VFNfByb2Smr7yZc99ajuwGnlWIfNfBtawO29oMfkKLF3Fw(DKLcTZc1U3XS4DFaqklPuSOpl(8XMLF3FwO29oMfKWwxJ0Kpzl2KK6eGy56kemzCja9WFWkbi99MUAIycqqKg6Z6pyLaC8OilaFVPRMiYYdzHeeTyzzXYVJSylB0J1VceBw0xZjl3KL7zXoCPazbjS11il64e2ilZRo6(vez53rwkKWplbN(SaBwEilGRylw0XjSrwifSaajbtag67X(8eG9QWjSjIM)Ir7WUYGn6X6xbITblxxHGSOLL0SeblPzjnl6R508xmAh2vgSrpw)kqSnng7xrzztw8WFWYyV9F3GegdRhZ)fJSqawgZqolAzjnlyqDwu0Cvwh(7SmmWcguNffnxLPqL3SmmWcguNffnQv5DUqc)SmILHbw0xZP5Vy0oSRmyJES(vGyBAm2VIYYMS4H)GLH(EpVgniHXW6X8FXileGLXmKZIwwsZcguNffnxLvRYBwggybdQZIIgku5DUqc)SmmWcguNffnEfnxiHFwgXYiwggyjcw0xZP5Vy0oSRmyJES(vGyBwwSmILHbwsZI(AonbpFvWSSyzyGfaEFUUcnbybascMbrA0kWYiw0YsacvGq7LjalaqsW8VJzQ113tnn6GrzrllbiaS86n1rC)ZthzrllPzrFnNgmOolkMvRYBtJX(vuw2KfYhJLHbw0xZPbdQZIIzku5TPXy)kklBYc5JXYiwgXIwwsZseSeGaWYR3qs0(8ILHbwcqOceAVmySf0o2zDybAAm2VIYYMSO5Smk5t2ITtsDcqSCDfcMmUeGE4pyLaK(Etxnrmbiisd9z9hSsaAlxXwSa89MUAIiLf73VZY4CLxbKf4KLTQuSK69Riszb2S8qwSA0YBKLjSzHuWcaKeKf73VZY4GBn1jad99yFEcWEv4e2erJUR8kGz4m7kv(3VIi1GLRRqqw0YsAwsZI(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajSSjl2WYWal6R50O7kVcygoZUsL)9RisZEh8cn03dKWYMSydlJyrllbiubcTxMGNVkyAm2VIYYMSqAzrllrWsacvGq7LjalaqsW8VJzQ113tnllwggyjnlbiaS86n1rC)ZthzrllbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcYc5JXIwwWG6SOO5QSxrzrllo9BxLTG2XMLnzXMXyHaSy7XyjvSeGqfi0EzcE(QGPrhmklJyzuYNSfcnj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGPzrFnNM2bGfCrZZgRue10ySFfLLnzrJSmmWseSOVMtt7aWcUO5zJvkIAwwSmIfTSebl6R500oaSGlAE2yLIOz6vZLkVhL(yFUzzXIwwsZI(AonKCfyJGzm2cAh7yS(mwyt8sbAAm2VIYcbzHya0e7eMLrSOLL0SOVMtdguNffZuOYBtJX(vuw2KfIbqtStywggyrFnNgmOolkMvRYBtJX(vuw2KfIbqtStywggyjnlrWI(AonyqDwumRwL3MLflddSebl6R50Gb1zrXmfQ82SSyzelAzjcwExH1BOqf9VaAWY1viilJsacI0qFw)bReGKcwG3FWILjSzXvkwaHpLLF3FwIDsqkl0vJS87yuw8gRTFwAC2iDhbzX(owSqiZbGfCrzH00yLIOSS7uwuiLYYV7flAKfkgOS0ySF1vezb2S87ilAqSf0o2SmoybYI(Aoz5OS46W1ZYdzz6kflW5KfyZIxrzrdcQZIISCuwCD46z5HSGe26AmbiaVZLhJjabHFUrBDDngJ1tt(KTOXKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctaMMLiyrFnNgmOolkMPqL3MLflAzjcw0xZPbdQZIIz1Q82SSyzelAzjcwExH1BOqf9VaAWY1viilAzjcw6vHtyten)fJ2HDLbB0J1VceBdwUUcbtacI0qFw)bReGKcwG3FWILF3Fwc7yGekl3KLOWflEJSaxp9arwWG6SOilpKfyPIYci8z53Xgzb2SCelyJS87hLf73VZcqOI(xatacW7C5Xycqq4NHRNEGygdQZIIjFYwi9jPobiwUUcbtgxcqp8hSsagdH18AmbyiAqH53BI4tt2c5jad99yFEcW0SOVMtdguNffZuOYBtJX(vuw2KLgJ9ROSmmWI(AonyqDwumRwL3MgJ9ROSSjlng7xrzzyGfaEFUUcnGWpdxp9aXmguNffzzelAzPXzJ0DxxHSOLL3BI4B(lgZpmdEilBYc52WIwwCRCyhdKWIwwa4956k0ac)CJ266AmgRNMaeePH(S(dwjaTLWNfxPy59Mi(uwSF)(vSqi8ceJVal2VFhUEwGaWo4wwxrKa)oYIRdbGSeGf49hSOjFYwiTjPobiwUUcbtgxcqp8hSsasx18AmbyOVh7ZtaMMf91CAWG6SOyMcvEBAm2VIYYMS0ySFfLLHbw0xZPbdQZIIz1Q820ySFfLLnzPXy)kklddSaW7Z1vObe(z46PhiMXG6SOilJyrllnoBKU76kKfTS8EteFZFXy(HzWdzztwi3gw0YIBLd7yGew0YcaVpxxHgq4NB0wxxJXy90eGHObfMFVjIpnzlKN8jBrZtsDcqSCDfcMmUeGE4pyLaK(Os5DEQ8gtag67X(8eGPzrFnNgmOolkMPqL3MgJ9ROSSjlng7xrzzyGf91CAWG6SOywTkVnng7xrzztwAm2VIYYWala8(CDfAaHFgUE6bIzmOolkYYiw0YsJZgP7UUczrllV3eX38xmMFyg8qw2KfYj9SOLf3kh2XajSOLfaEFUUcnGWp3OTUUgJX6Pjadrdkm)EteFAYwip5t2skjj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGbiaS86naW63J2SOLLiyPxfoHnr0qVAUu59O0h7Zny56keKfTSebl9QWjSjIMW1bfMHZS6My2lWmi6)UblxxHGSOLLaeQaH2lJo2uSj5kIMgDWOSOLLaeQaH2lt7aWcUO5zJvkIAA0bJYIwwIGf91CAcE(QGzzXIwwsZIt)2vzlODSzztw0CsllddSOVMtJUccbvl6BwwSmkbiisd9z9hSsaAlHpl9rC)zrhNWgzH00yLIOSCtwUNf7WLcKfxPG2zjkCXYdzPXzJ0DwuiLYc4QVIilKMgRueLL0)(rzbwQOSS7wwyrzX(97W1ZcWRMlfleYhL(yF(OeGa8oxEmMaSG59O0h7ZZO3QOzq4N8jBH8XssDcqSCDfcMmUeGH(ESppbiaVpxxHMcM3JsFSppJERIMbHplAzPXy)kkleKfBglbOh(dwjaJHWAEnM8jBHCYtsDcqSCDfcMmUeGH(ESppbiaVpxxHMcM3JsFSppJERIMbHplAzPXy)kkleKfYtjja9WFWkbiDvZRXKpzlKBtsQtaILRRqWKXLa0d)bReGtyhWmCMl)xnMaeePH(S(dwjahpkYcPbUfwGflbqwSF)oC9SeClRRiMam03J95jaDRCyhdKK8jBHCBNK6eGy56kemzCja9WFWkbigBbTJDwhwGjabrAOpR)GvcWXJISObXwq7yZY4Gfil2VFNfVIYIcwezbl4I4olkN(xrKfniOolkYIxGS8DuwEilQRqwUNLLfl2VFNfcXsr9MfVazHuBLSJFfsag67X(8eGPzjaHkqO9Ye88vbtJX(vuwial6R50e88vbd4Q9)GfleGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLuXc52WYMSeGqfi0EzWylODSZ6Wc0aUA)pyXcbyH8XyzelddSOVMttWZxfmng7xrzztw0CwggybSxhOPG5ain5t2c5eAsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaD63UkBbTJnlBYskzmw0mwsZIngnYsQyrFnNM5QJMHZmQwfAOVhiHfnJfByjvSGb1zrrZvz1Q8MLrjabrAOpR)GvcqG4tzX(owSSvkHGf6oCPazrhzbCfBHGS8qwk4Zcea2b3IL02s0clqklWIfsZQJYcCYIgOwfYIxGS87ilAqqDwuCucqaENlpgta6uRm4k2k5t2c5Amj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGrWcyVoqtbZbqklAzjnla8(CDfAcG5aSaV)GflAzjcw0xZPj45RcMLflAzjnlrWcf)SoSwuZFyBJMNTXkWYWalyqDwu0CvwTkVzzyGfmOolkAOqL35cj8ZYiw0YsAwsZsAwa4956k04uRm4k2ILHbwcqay51BQJ4(NNoYYWalPzjabGLxVHKO95flAzjaHkqO9YGXwq7yN1HfOPrhmklJyzyGLEv4e2erZFXODyxzWg9y9RaX2GLRRqqwgXIwwaHVHUQ51OPXy)kklBYIMZIwwaHVjgcR51OPXy)kklBYskHfTSKMfq4BOpQuENNkVrtJX(vuw2KfYhJLHbwIGL3vy9g6JkL35PYB0GLRRqqwgXIwwa4956k0879PuzkIKGD2UFplAz59Mi(M)IX8dZGhYYMSOVMttWZxfmGR2)dwSKkwgZqAzzyGf91CA0vqiOArFZYIfTSOVMtJUccbvl6BAm2VIYcbzrFnNMGNVkyaxT)hSyHaSKMfYTHLuXsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYYiwgXYWalPzbT11zzHGgm2kAJUkdBWYRaYIwwcqOceAVmySv0gDvg2GLxb00ySFfLfcYc5KEslleGL0SOrwsfl9QWjSjIg6vZLkVhL(yFUblxxHGSmILrSmIfTSKML0SeblbiaS86n1rC)ZthzzyGL0SaW7Z1vOjalaqsWmisJwbwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSqqwixJSmIfTSKMLiyPxfoHnr0O7kVcygoZUsL)9Risny56keKLHbwC63UkBbTJnleKfnoglAzjaHkqO9YeGfaijy(3Xm1667PMgDWOSmILrSmmWY8iU)5gJ9ROSqqwcqOceAVmbybascM)DmtTU(EQPXy)kklJyzyGfDiLYIwwMhX9p3ySFfLfcYI(AonbpFvWaUA)pyXcbyHCByjvS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSmkbiisd9z9hSsaoEuKfsTvYo(vGf73VZcPGfaijiztPDfyJGSa0667PS4filGWA7NfiaST33JSqiwkQ3SaBwSVJflJtbHGQf9zXoCPazbjS11il64e2ilKARKD8RaliHTUgPgwSfCsqwORgz5HSG1JnlolK5Q8MfniOolkYI9DSyzrpIflP2gnNfBScS4filUsXcPSLuwSFkfl6yagJS0OdgLfkewSGfCrCNfWvFfrw(DKf91CYIxGSacFkl7oaKfDelwOR58chwVkklnoBKUJGMeGa8oxEmMamaMdWc8(dwz6N8jBHCsFsQtaILRRqWKXLa0d)bReGTdal4IMNnwPiAcqqKg6Z6pyLaC8OilKMgRueLf73VZcP2kzh)kWYQuiLYcPPXkfrzXoCPazr50NffSiInl)UxSqQTs2XVcAILFhlwwuKfDCcBmbyOVh7ZtaQVMttWZxfmng7xrzztwixJSmmWI(AonbpFvWaUA)pyXcbzXgslleGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLuXc52WIwwa4956k0eaZbybE)bRm9t(KTqoPnj1jaXY1viyY4sag67X(8eGa8(CDfAcG5aSaV)GvM(SOLL0SOVMttWZxfmGR2)dwSSzKSydPLfcWsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYsQyHCByzyGLiyjabGLxVbaw)E0MLrSmmWI(AonTdal4IMNnwPiQzzXIww0xZPPDaybx08SXkfrnng7xrzHGSKsyHaSeGf46EJvJHJIzxDeRySEZFXygGRwileGL0Sebl6R50ORGqq1I(MLflAzjcwExH1BOV3kydAWY1viilJsa6H)GvcWaQq6FUk7QJyfJ1N8jBHCnpj1jaXY1viyY4sag67X(8eGa8(CDfAcG5aSaV)GvM(ja9WFWkb4vbVl)pyL8jBH8ussQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjadqOceAVmbpFvW0ySFfLLnzH8XyzyGLiybG3NRRqtawaGKGzqKgTcSOLLaeawE9M6iU)5PJSmmWcyVoqtbZbqAcqqKg6Z6pyLamLQ3NRRqwwueKfyXIRFQ7pKYYV7pl296z5HSOJSqDaiiltyZcP2kzh)kWcfYYV7pl)ogLfVX6zXUtFeKLukw0NfDCcBKLFhJtacW7C5XycqQdaZtyNdE(QqYNSfBglj1jaXY1viyY4sa6H)GvcW5QJMHZmQwfMaeePH(S(dwjahpkszH0a1awUjlxXIxSObb1zrrw8cKLVpKYYdzrDfYY9SSSyX(97SqiwkQ3AIfsTvYo(vqtSObXwq7yZY4GfilEbYYwbDR)aGSa0U3Xjad99yFEcqmOolkAUk7vuw0YsAwC63UkBbTJnleKLuInSOzSOVMtZC1rZWzgvRcn03dKWsQyrJSmmWI(AonTdal4IMNnwPiQzzXYiw0YsAw0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqqwSHqhJLHbw0xZPj45RcMgJ9ROSSjlAolJyrlla8(CDfAOoampHDo45RcSOLL0SeblbiaS86nfgAOc2GSmmWci8noOB9hamtT7DCg0JDIO5VajxrKLrSOLL0SeblbiaS86naW63J2SmmWI(AonTdal4IMNnwPiQPXy)kkleKLuclAglPzHqzjvS0RcNWMiAOxnxQ8Eu6J95gSCDfcYYiw0YI(AonTdal4IMNnwPiQzzXYWalrWI(AonTdal4IMNnwPiQzzXYiw0YsAwIGLaeawE9gsI2NxSmmWsacvGq7LbJTG2XoRdlqtJX(vuw2KfBgJLrSOLL3BI4B(lgZpmdEilBYIgzzyGfDiLYIwwMhX9p3ySFfLfcYc5JL8jBXgYtsDcqSCDfcMmUeGE4pyLaK(EpDLkbiisd9z9hSsaoEuKfBXc)Dwa(EpDLIfRggOSCtwa(EpDLILJwB)SSSsag67X(8eG6R50al83PzlSdO1FWYSSyrll6R50qFVNUszAC2iD31vyYNSfBSjj1jaXY1viyY4sa6H)GvcWGxbuL1xZzcWqFp2NNauFnNg67Tc2GMgJ9ROSqqw0ilAzjnl6R50Gb1zrXmfQ820ySFfLLnzrJSmmWI(AonyqDwumRwL3MgJ9ROSSjlAKLrSOLfN(TRYwq7yZYMSKsglbO(AoZLhJjaPV3kydMaeePH(S(dwjajLxbuXcW3BfSbz5MSCpl7oLffsPS87EXIgPS0ySF1ve1elrHlw8gzXFwsjJraw2kLqWIxGS87ilHv3y9SObb1zrrw2DklAKauwAm2V6kIjFYwSX2jPobiwUUcbtgxcqp8hSsag8kGQS(Aotag67X(8eGVRW6nxf8U8)GLblxxHGSOLLiy5DfwVPq75yiSmy56keKfTSKshlPzjnl2ESXyrZyXPF7QSf0o2Sqawi0XyrZyHIFwhwlQ5pSTrZZ2yfyjvSqOJXYiwillPzHqzHSSqTqLkV70hzzelAglbiubcTxMaSaajbZ)oMPwxFp10ySFfLLrSqqwsPJL0SKMfBp2ySOzS40VDv2cAhBw0mw0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqawi0XyrZyHIFwhwlQ5pSTrZZ2yfyjvSqOJXYiwillPzHqzHSSqTqLkV70hzzelAglbiubcTxMaSaajbZ)oMPwxFp10ySFfLLrSOLLaeQaH2ltWZxfmng7xrzztwS9ySOLf91CAS6lg2GNRYEh86czRLI6TbGRwileKfBiFmw0YI(Aonw9fdBWZvzVdEDHS1sr92aWvlKLnzX2JXIwwcqOceAVmbybascM)DmtTU(EQPXy)kkleKfcDmw0YY8iU)5gJ9ROSSjlbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcWcPNfTSKMLEv4e2ertavi9pxLPwxFp1GLRRqqwggybG3NRRqtawaGKGzqKgTcSmkbO(AoZLhJjaT6lg2GNRYEh86czRLI6DcqqKg6Z6pyLaKuEfqfl)oYcHyPOEZI(Aoz5MS87ilwnmWID4sbwB)SOUczzzXI973z53rwkKWpl)fJSqkybascYsagJuwGZjlbqdlPE)OSSOlxPIYcSurzz3TSWIYc4QVIil)oYY4ittYNSfBi0KuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctagGaWYR3uhX9ppDKfTS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSOLf91CAS6lg2GNRYEh86czRLI6TbGRwileGfN(TRYwq7yZcbyX2SSzKSy7XgJfTSaW7Z1vOjalaqsWmisJwbw0YsacvGq7LjalaqsW8VJzQ113tnng7xrzHGS40VDv2cAhBwill2EmwsfledGMyNWSOLLiybSxhOPG5aiLfTSGb1zrrZvzVIYIwwC63UkBbTJnlBYcaVpxxHMaSaajbZo1IfTSeGqfi0EzcE(QGPXy)kklBYIgtacI0qFw)bReGaXNYI9DSyHqSuuVzHUdxkqw0rwSAyiGGSGERIYYdzrhzX1vilpKLffzHuWcaKeKfyXsacvGq7flP1akfR)CLkkl6yagJuw(EHSCtwaxXwxrKLTsjeSuq7Sy)ukwCLcANLOWflpKflSNy4vrzbRhBwielf1Bw8cKLFhlwwuKfsblaqsWrjab4DU8ymbOvddzRLI6Dg9wfn5t2InAmj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkb44rrwa(EpDLIf73VZcWhvkVzXw238zb2S82O5SqOwbw8cKLcYcW3BfSb1el23XILcYcW37PRuSCuwwwSaBwEilwnmWcHyPOEZI9DSyX1HaqwsjJXYwPeI0WMLFhzb9wfLfcXsr9MfRggybG3NRRqwoklFVWrSaBwCql)pailu7EhZYUtzrZjafduwAm2V6kISaBwoklxXYuDe3)eGH(ESppbyAwExH1BOpQuENb7B(gSCDfcYYWalu8Z6WArn)HTnAEMqTcSmIfTSeblVRW6n03BfSbny56keKfTSOVMtd99E6kLPXzJ0DxxHSOLLiyPxfoHnr08xmAh2vgSrpw)kqSny56keKfTSKMf91CAS6lg2GNRYEh86czRLI6TbGRwilBgjl2OXXyrllrWI(AonbpFvWSSyrllPzbG3NRRqJtTYGRylwggyrFnNgsUcSrWmgBbTJDmwFglSjEPanllwggybG3NRRqJvddzRLI6Dg9wfLLrSmmWsAwcqay51Bkm0qfSbzrllVRW6n0hvkVZG9nFdwUUcbzrllPzbe(gh0T(daMP29ood6Xor00ySFfLLnzrZzzyGfp8hSmoOB9hamtT7DCg0JDIO5Q8uDe3FwgXYiwgXIwwsZsacvGq7Lj45RcMgJ9ROSSjlKpglddSeGqfi0EzcWcaKem)7yMAD99utJX(vuw2KfYhJLrjFYwSH0NK6eGy56kemzCja9WFWkbi99MUAIycqqKg6Z6pyLa0wUITOSSvkHGfDCcBKfsblaqsqww0RiYYVJSqkybascYsawG3FWILhYsyhdKWYnzHuWcaKeKLJYIh(LRurzX1HRNLhYIoYsWPFcWqFp2NNaeG3NRRqJvddzRLI6Dg9wfn5t2InK2KuNaelxxHGjJlbOh(dwjal0EogcReGGin0N1FWkb44rrwSfGWIYI9DSyjkCXI3ilUoC9S8qY6nYsWTSUIilHDVjIuw8cKLyNeKf6Qrw(DmklEJSCflEXIgeuNffzH(NsXYe2SqiVTazjn2cjad99yFEcq3kh2XajSOLL0Se29MiszjswSHfTS0yy3BIy(VyKfcYIgzzyGLWU3erklrYITzzuYNSfB08KuNaelxxHGjJlbyOVh7Zta6w5WogiHfTSKMLWU3erklrYInSOLLgd7EteZ)fJSqqw0ilddSe29MiszjswSnlJyrllPzrFnNgmOolkMvRYBtJX(vuw2KfKWyy9y(VyKLHbw0xZPbdQZIIzku5TPXy)kklBYcsymSEm)xmYYOeGE4pyLaC3vZCmewjFYwSjLKK6eGy56kemzCjad99yFEcq3kh2XajSOLL0Se29MiszjswSHfTS0yy3BIy(VyKfcYIgzzyGLWU3erklrYITzzelAzjnl6R50Gb1zrXSAvEBAm2VIYYMSGegdRhZ)fJSmmWI(AonyqDwumtHkVnng7xrzztwqcJH1J5)IrwgLa0d)bReGZLsLJHWk5t2IThlj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkb44rrwa(EtxnrKfBXc)DwSAyGYIxGSaUITyzRucbl23XIfsTvYo(vqtSObXwq7yZY4GfOMy53rwsPI1VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsjejad99yFEcqmOolkAUk7vuw0YsAw0xZPbw4VtZbf6DgWrpyzwwSmmWI(AonKCfyJGzm2cAh7yS(mwyt8sbAwwSmmWI(AonbpFvWSSyrllPzjcwcqay51BijAFEXYWalbiubcTxgm2cAh7SoSanng7xrzztw0ilddSOVMttWZxfmng7xrzHGSqmaAIDcZsQyzQGWML0S40VDv2cAhBwilla8(CDfAO0CasFwgXYiw0YsAwIGLaeawE9gay97rBwggyrFnNM2bGfCrZZgRue10ySFfLfcYcXaOj2jmlPILaEkwsZsAwC63UkBbTJnleGfcDmwsflVRW6nZvhndNzuTk0GLRRqqwgXczzbG3NRRqdLMdq6ZYiwial2MLuXY7kSEtH2ZXqyzWY1viilAzjcw6vHtyten0RMlvEpk9X(CdwUUcbzrll6R500oaSGlAE2yLIOMLflddSOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MLflddSKMf91CAAhawWfnpBSsrutJX(vuwiilE4pyzOV3ZRrdsymSEm)xmYIwwOwOsL3D6JSqqwgZqOSmmWI(AonTdal4IMNnwPiQPXy)kkleKfp8hSm2B)3niHXW6X8FXilddSaW7Z1vO5SvWCawG3FWIfTSeGqfi0EzUIg6176kmBRlV(vCgebCb00OdgLfTSG266SSqqZv0qVExxHzBD51VIZGiGlGSmIfTSOVMtt7aWcUO5zJvkIAwwSmmWseSOVMtt7aWcUO5zJvkIAwwSOLLiyjaHkqO9Y0oaSGlAE2yLIOMgDWOSmILHbwa4956k04uRm4k2ILHbw0HuklAzzEe3)CJX(vuwiiledGMyNWSKkwc4Pyjnlo9BxLTG2XMfYYcaVpxxHgknhG0NLrSmk5t2ITjpj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkbyQ7OS8qwIDsqw(DKfDK(SaNSa89wbBqw0JYc99ajxrKL7zzzXITUUajQOSCflEfLfniOolkYI(6zHqSuuVz5O12plUoC9S8qw0rwSAyiGGjad99yFEcW3vy9g67Tc2GgSCDfcYIwwIGLEv4e2erZFXODyxzWg9y9RaX2GLRRqqw0YsAw0xZPH(ERGnOzzXYWalo9BxLTG2XMLnzjLmglJyrll6R50qFVvWg0qFpqcleKfBZIwwsZI(AonyqDwumtHkVnllwggyrFnNgmOolkMvRYBZYILrSOLf91CAS6lg2GNRYEh86czRLI6TbGRwileKfBiTJXIwwsZsacvGq7Lj45RcMgJ9ROSSjlKpglddSebla8(CDfAcWcaKemdI0OvGfTSeGaWYR3uhX9ppDKLrjFYwSTnjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMaedQZIIMRYQv5nlPIfnNfYYIh(dwg6798A0GegdRhZ)fJSqawIGfmOolkAUkRwL3SKkwsZcPNfcWY7kSEdfUuz4m)7yEcBK(gSCDfcYsQyX2SmIfYYIh(dwg7T)7gKWyy9y(VyKfcWYygcvJSqwwOwOsL3D6JSqawgZOrwsflVRW6nL)RgPzDx5vany56kembiisd9z9hSsaQb0)I9hPSSdTZs8kSZYwPecw8gzHOFfcYIf2SqXaSanSylwQOS8ojiLfNfA5w0D4ZYe2S87ilHv3y9SqVF5)blwOqwSdxkWA7NfDKfpewT)iltyZIYBIyZYFX4S9yKMaeG35YJXeGo1IqGnqmK8jBX22oj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkbOTCfBXcW3B6QjISCflEXIgeuNffzXPSqHWIfNYIfKspDfYItzrblIS4uwIcxSy)ukwWcKLLfl2VFNfnFmcWI9DSybRh7RiYYVJSuiHFw0GG6SOOMybewB)SOWNL7zXQHbwielf1BnXciS2(zbcaB799ilEXITyH)olwnmWIxGSybHkw0XjSrwi1wj74xbw8cKfni2cAhBwghSatag67X(8eGrWsVkCcBIO5Vy0oSRmyJES(vGyBWY1viilAzjnl6R50y1xmSbpxL9o41fYwlf1BdaxTqwiil2qAhJLHbw0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqqwSrJJXIwwExH1BOpQuENb7B(gSCDfcYYiw0YsAwWG6SOO5QmfQ8MfTS40VDv2cAhBwiala8(CDfACQfHaBGyGLuXI(AonyqDwumtHkVnng7xrzHaSacFZC1rZWzgvRcn)fiHMBm2VILuXIngnYYMSO5JXYWalyqDwu0CvwTkVzrllo9BxLTG2XMfcWcaVpxxHgNAriWgigyjvSOVMtdguNffZQv5TPXy)kkleGfq4BMRoAgoZOAvO5Vaj0CJX(vSKkwSXOrw2KLuYySmIfTSebl6R50al83PzlSdO1FWYSSyrllrWY7kSEd99wbBqdwUUcbzrllPzjaHkqO9Ye88vbtJX(vuw2KfsllddSqHlL(vGMFVpLktrKeSny56keKfTSOVMtZV3NsLPisc2g67bsyHGSyBBZIMXsAw6vHtyten0RMlvEpk9X(CdwUUcbzjvSydlJyrllZJ4(NBm2VIYYMSq(yJXIwwMhX9p3ySFfLfcYInJnglddSa2Rd0uWCaKYYiw0YsAwIGLaeawE9gsI2NxSmmWsacvGq7LbJTG2XoRdlqtJX(vuw2KfByzuYNSfBtOjPobiwUUcbtgxcqp8hSsawO9CmewjabrAOpR)GvcWXJISylaHfLLRyXROSObb1zrrw8cKfQdazHqExnjaPzPuSylaHfltyZcP2kzh)kWIxGSKs7kWgbzrdITG2XogR3WYwvuillkYYwSfyXlqwin2cS4pl)oYcwGSaNSqAASsruw8cKfqyT9ZIcFwSLn6X6xbInltxPyboNjad99yFEcq3kh2XajSOLfaEFUUcnuhaMNWoh88vbw0YsAw0xZPbdQZIIz1Q820ySFfLLnzbjmgwpM)lgzzyGf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmk5t2IT1ysQtaILRRqWKXLam03J95jaDRCyhdKWIwwa4956k0qDayEc7CWZxfyrllPzrFnNgmOolkMvRYBtJX(vuw2KfKWyy9y(VyKLHbw0xZPbdQZIIzku5TPXy)kklBYcsymSEm)xmYYiw0YsAw0xZPj45RcMLflddSOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGrYInKpglJyrllPzjcwcqay51BaG1VhTzzyGf91CAAhawWfnpBSsrutJX(vuwiilPzrJSOzSydlPILEv4e2erd9Q5sL3JsFSp3GLRRqqwgXIww0xZPPDaybx08SXkfrnllwggyjcw0xZPPDaybx08SXkfrnllwgXIwwsZseS0RcNWMiA(lgTd7kd2OhRFfi2gSCDfcYYWaliHXW6X8FXileKf91CA(lgTd7kd2OhRFfi2MgJ9ROSmmWseSOVMtZFXODyxzWg9y9RaX2SSyzucqp8hSsaU7QzogcRKpzl2M0NK6eGy56kemzCjad99yFEcq3kh2XajSOLfaEFUUcnuhaMNWoh88vbw0YsAw0xZPbdQZIIz1Q820ySFfLLnzbjmgwpM)lgzzyGf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmIfTSKMf91CAcE(QGzzXYWal6R50y1xmSbpxL9o41fYwlf1BdaxTqwiyKSyd5JXYiw0YsAwIGLaeawE9gsI2NxSmmWI(AonKCfyJGzm2cAh7yS(mwyt8sbAwwSmIfTSKMLiyjabGLxVbaw)E0MLHbw0xZPPDaybx08SXkfrnng7xrzHGSOrw0YI(AonTdal4IMNnwPiQzzXIwwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyjcw0xZPPDaybx08SXkfrnllwgXIwwsZseS0RcNWMiA(lgTd7kd2OhRFfi2gSCDfcYYWaliHXW6X8FXileKf91CA(lgTd7kd2OhRFfi2MgJ9ROSmmWseSOVMtZFXODyxzWg9y9RaX2SSyzucqp8hSsaoxkvogcRKpzl2M0MK6eGy56kemzCjabrAOpR)GvcWXJISqib1awGflbWeGE4pyLa0U39b7mCMr1QWKpzl2wZtsDcqSCDfcMmUeGE4pyLaK(EpVgtacI0qFw)bReGJhfzb4798AKLhYIvddSaeQ8MfniOolkQjwi1wj74xbw2DklkKsz5VyKLF3lwCwiKA)3zbjmgwpYIcNplWMfyPIYczUkVzrdcQZIISCuwwwgwiKUFNLuBJMZInwbwW6XMfNfGqL3SObb1zrrwUjleILI6nl0)ukw2DklkKsz539IfBiFmwOVhiHYIxGSqQTs2XVcS4filKcwaGKGSS7aqwIHnYYV7flKtAPSqkBjlng7xDfrdlJhfzX1HaqwSrJJr6yz3PpYc4QVIilKMgRueLfVazXgBSH0XYUtFKf73VdxplKMgRuenbyOVh7ZtaIb1zrrZvz1Q8MfTSebl6R500oaSGlAE2yLIOMLflddSGb1zrrdfQ8oxiHFwggyjnlyqDwu04v0CHe(zzyGf91CAcE(QGPXy)kkleKfp8hSm2B)3niHXW6X8FXilAzrFnNMGNVkywwSmIfTSKMLiyHIFwhwlQ5pSTrZZ2yfyzyGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKfTSOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGSyd5JXIwwcqOceAVmbpFvW0ySFfLLnzHCsllAzjnlrWsacalVEtDe3)80rwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSSjlKtAzzelAzjnlrWs7b08nuPyzyGLaeQaH2lJo2uSj5kIMgJ9ROSSjlKtAzzelJyzyGfmOolkAUk7vuw0YsAw0xZPXU39b7mCMr1QqZYILHbwOwOsL3D6JSqqwgZqOAKfTSKMLiyjabGLxVbaw)E0MLHbwIGf91CAAhawWfnpBSsruZYILrSmmWsacalVEdaS(9OnlAzHAHkvE3PpYcbzzmdHYYOKpzl2oLKK6eGy56kemzCjabrAOpR)GvcWXJISqi1(VZc83X2(rrwSVFHDwoklxXcqOYBw0GG6SOOMyHuBLSJFfyb2S8qwSAyGfYCvEZIgeuNffta6H)Gvcq7T)7jFYwi0XssDcqSCDfcMmUeGGin0N1FWkbiPXvQFVxja9WFWkbyVQSh(dwz1r)eGQJ(5YJXeGtxP(9EL8jFYNaea20dwjBXMXSXMXSn5AmbODVRRistasiTvczBz83cHCPmlSK6DKLl2c2pltyZY2qlSWEBwA0wxxJGSqHXil(6HX(JGSe29Iisn8gK5vil2KYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsAYj8idVbzEfYITtzwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzjn5eEKH3G3GqAReY2Y4Vfc5szwyj17ilxSfSFwMWMLTbXPVu)2S0OTUUgbzHcJrw81dJ9hbzjS7frKA4niZRqwi9PmlKcwaW(rqwaEXKIfA06DcZcPJLhYczUCwapah9GflqlS9h2SKMSJyjn5eEKH3GmVczH0NYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsABi8idVbzEfYcPnLzHuWca2pcYY29QWjSjIgYyBwEilB3RcNWMiAiddwUUcb3ML0Kt4rgEdY8kKfnpLzHuWca2pcYcWlMuSqJwVtywiDS8qwiZLZc4b4OhSybAHT)WML0KDelPTHWJm8gK5vilAEkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPjNWJm8gK5vilPKuMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwsBBcpYWBqMxHSKsszwifSaG9JGSS93xrc(gYnKX2S8qw2(7RibFZtUHm2ML02q4rgEdY8kKLuskZcPGfaSFeKLT)(ksW3yJHm2MLhYY2FFfj4BEBmKX2SK2gcpYWBqMxHSq(yPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSqo5PmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSqUnPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSqUTtzwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzjn5eEKH3GmVczHCnMYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsAYj8idVbzEfYc5K(uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwsBdHhz4niZRqwiN0NYSqkyba7hbzz7VVIe8nKBiJTz5HSS93xrc(MNCdzSnlPTHWJm8gK5vilKt6tzwifSaG9JGSS93xrc(gBmKX2S8qw2(7RibFZBJHm2ML0Kt4rgEdY8kKfYjTPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SK2gcpYWBqMxHSqoPnLzHuWca2pcYY2FFfj4Bi3qgBZYdzz7VVIe8np5gYyBwstoHhz4niZRqwiN0MYSqkyba7hbzz7VVIe8n2yiJTz5HSS93xrc(M3gdzSnlPTHWJm8g8gesBLq2wg)TqixkZclPEhz5ITG9ZYe2SSTvJbySU)BZsJ266AeKfkmgzXxpm2FeKLWUxerQH3GmVczX2PmlKcwaW(rqw2(7RibFd5gYyBwEilB)9vKGV5j3qgBZsABt4rgEdY8kKfcnLzHuWca2pcYY2FFfj4BSXqgBZYdzz7VVIe8nVngYyBwsBBcpYWBqMxHSO5PmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42S4plAGTizYsAYj8idVbVbH0wjKTLXFleYLYSWsQ3rwUyly)SmHnlB7qCBwA0wxxJGSqHXil(6HX(JGSe29Iisn8gK5vilKNYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsAYj8idVbzEfYInPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSytkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnl(ZIgylsMSKMCcpYWBqMxHSy7uMfsblay)iilB)UcR3qgBZYdzz73vy9gYWGLRRqWTzjn5eEKH3GmVczX2PmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKwZj8idVbzEfYcPpLzHuWca2pcYcWlMuSqJwVtywiDKowEilK5YzjgcUulklqlS9h2SKM0nIL0Kt4rgEdY8kKfsFkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPTHWJm8gK5vilK2uMfsblay)iilaVysXcnA9oHzH0r6y5HSqMlNLyi4sTOSaTW2FyZsAs3iwstoHhz4niZRqwiTPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSO5PmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSKsszwifSaG9JGSa8Ijfl0O17eMfshlpKfYC5SaEao6blwGwy7pSzjnzhXsABi8idVbzEfYc52KYSqkyba7hbzb4ftkwOrR3jmlKowEilK5Yzb8aC0dwSaTW2FyZsAYoIL0Kt4rgEdY8kKfYj0uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwixJPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSqoPpLzHuWca2pcYY29QWjSjIgYyBwEilB3RcNWMiAiddwUUcb3ML02q4rgEdY8kKfY18uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwSzSuMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwsBdHhz4niZRqwSXMuMfsblay)iilaVysXcnA9oHzH0XYdzHmxolGhGJEWIfOf2(dBwst2rSKMCcpYWBqMxHSydHMYSqkyba7hbzb4ftkwOrR3jmlKowEilK5Yzb8aC0dwSaTW2FyZsAYoIL02q4rgEdY8kKfBi0uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwSH0NYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsAYj8idVbzEfYInK2uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwSjLKYSqkyba7hbzb4ftkwOrR3jmlKowEilK5Yzb8aC0dwSaTW2FyZsAYoIL02q4rgEdY8kKfBpwkZcPGfaSFeKfGxmPyHgTENWSq6y5HSqMlNfWdWrpyXc0cB)HnlPj7iwstoHhz4n4niK2kHSTm(BHqUuMfws9oYYfBb7NLjSzz7PRu)EV2MLgT111iiluymYIVEyS)iilHDViIudVbzEfYInPmlKcwaW(rqwaEXKIfA06DcZcPJLhYczUCwapah9GflqlS9h2SKMSJyjn5eEKH3G3GqAReY2Y4Vfc5szwyj17ilxSfSFwMWMLTP)2S0OTUUgbzHcJrw81dJ9hbzjS7frKA4niZRqwSjLzHuWca2pcYY29QWjSjIgYyBwEilB3RcNWMiAiddwUUcb3ML0Kt4rgEdY8kKfBNYSqkyba7hbzz7Ev4e2erdzSnlpKLT7vHtytenKHblxxHGBZsAYj8idVbzEfYIgtzwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzXFw0aBrYKL0Kt4rgEdY8kKLuskZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPTHWJm8gK5vilKB7uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwixJPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKwJeEKH3GmVczHCsFkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPjNWJm8gK5vilKtAtzwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzjn5eEKH3GmVczXMXszwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzjn5eEKH3GmVczXgBNYSqkyba7hbzb4ftkwOrR3jmlKowEilK5Yzb8aC0dwSaTW2FyZsAYoIL0ekHhz4niZRqwSX2PmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSydHMYSqkyba7hbzb4ftkwOrR3jmlKowEilK5Yzb8aC0dwSaTW2FyZsAYoIL0Kt4rgEdY8kKfBi0uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwSrJPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SKMCcpYWBqMxHSy7XszwifSaG9JGSa8Ijfl0O17eMfshlpKfYC5SaEao6blwGwy7pSzjnzhXsABt4rgEdY8kKfBpwkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPjNWJm8gK5vil2M8uMfsblay)iilB3RcNWMiAiJTz5HSSDVkCcBIOHmmy56keCBwstoHhz4niZRqwSTnPmlKcwaW(rqwaEXKIfA06DcZcPJLhYczUCwapah9GflqlS9h2SKMSJyjTTj8idVbzEfYITTDkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPTHWJm8gK5vil2wJPmlKcwaW(rqw2UxfoHnr0qgBZYdzz7Ev4e2erdzyWY1vi42SK2gcpYWBqMxHSyBsFkZcPGfaSFeKLT7vHtytenKX2S8qw2UxfoHnr0qggSCDfcUnlPTHWJm8gK5vil2wZtzwifSaG9JGSSDVkCcBIOHm2MLhYY29QWjSjIgYWGLRRqWTzjn5eEKH3G3y8JTG9JGSq6zXd)blwuh9PgEJeGulmKSfYhZMeGwnCEkmbOgQHSmox5vazXw2RdK3qd1qwSf8oSZc5KEnXInJzJn8g8gAOgYcP29IistzEdnudzrZyzRGGiilaHkVzzCOhB4n0qnKfnJfsT7freKL3BI4NVjlbNIuwEilHObfMFVjIp1WBOHAilAgleYWyiaeKLvvyaPuVJYcaVpxxHuwsFg0OjwSAeqM(EtxnrKfnBtwSAeGH(EtxnrCKH3qd1qw0mw2ka4bYIvJbN(xrKfcP2)DwUjl3VnLLFhzXEdlISObb1zrrdVHgQHSOzSyl4KGSqkybascYYVJSa0667PS4SOU)vilXWgzzQqcF6kKL03KLOWfl7oyT9ZY(9SCpl0lEPEVq4IQIYI973zzC2IBn1SqawifQq6FUILTQoIvmwVMy5(TbzHsYznYWBOHAilAgl2cojilXq6ZY2ZJ4(NBm2VIUnl0awEFqklULLkklpKfDiLYY8iU)uwGLkQH3qd1qw0mwsDJ(ZsQHXilWjlJt57SmoLVZY4u(oloLfNfQfgoxXY3xrc(gEdnudzrZyXw0clSzj9zqJMyHqQ9FxtSqi1(VRjwa(EpVghXsSdISedBKLgPN6W6z5HSGERoSzjaJ19xZOV3VH3qd1qw0mwinhHzjL2vGncYIgeBbTJDmwplHDmqcltyZcPSLSSOor0WBWBOHAilBTk47pcYY4CLxbKLTsiitwcEXIoYYeUkqw8NL9)TOPmzjRUR8kGAg9IdgI3VV0nhKSJZvEfqnd4ftkYgdA2)yvk9ZtHrQ7kVcO5j8ZBWB4H)Gf1y1yagR7FKKCfyJGzQ113t5n0qws9oYcaVpxxHSCuwO4ZYdzzmwSF)olfKf67plWILffz57RibFQMyHCwSVJfl)oYY8A6ZcSqwoklWILff1el2WYnz53rwOyawGSCuw8cKfBZYnzrh(7S4nYB4H)Gf1y1yagR7pbIKSa8(CDfQPYJXiHvErX83xrc(AcGRwyKJXB4H)Gf1y1yagR7pbIKSa8(CDfQPYJXiHvErX83xrc(AcAfPdcQjaUAHrsUMUzKFFfj4Bi3S708IIz91CQ97RibFd5MaeQaH2ld4Q9)GL2i((ksW3qU5OMhgJz4mhdl63WfnhGf97v4pyr5n8WFWIASAmaJ19NarswaEFUUc1u5XyKWkVOy(7RibFnbTI0bb1eaxTWiTrt3mYVVIe8n2y2DAErXS(Ao1(9vKGVXgtacvGq7LbC1(FWsBeFFfj4BSXCuZdJXmCMJHf9B4IMdWI(9k8hSO8gAilPEhPilFFfj4tzXBKLc(S4Rhg7)fCLkklG4JHhbzXPSalwwuKf67plFFfj4tnSWcq8zbG3NRRqwEilekloLLFhJYIROqwkebzHAHHZvSS7fO6kIgEdp8hSOgRgdWyD)jqKKfG3NRRqnvEmgjSYlkM)(ksWxtqRiDqqnbWvlmscvt3ms0wxNLfcAUIg6176kmBRlV(vCgebCbCyaT11zzHGgm2kAJUkdBWYRaomG266SSqqdfUuk8)RiM7LEuEdnKfG4tz53rwa(EtxnrKLaK(SmHnlk)XMLGRclL)hSOSKEcBwqc7XwkKf77yXYdzH(E)SaUITUIil64e2ilKMgRueLLPRuuwGZ5iEdp8hSOgRgdWyD)jqKKfG3NRRqnvEmgjLMdq6RjaUAHrA7XsvAY1SXmKRXurXpRdRf18h22O5zc1kmI3Wd)blQXQXamw3Fcejzb4956kutLhJrsN5aK(AcGRwyKACSuLMCnBmd5Amvu8Z6WArn)HTnAEMqTcJ4n0qwaIpLf)zX((f2zXJHR6zbozzRucblKcwaGKGSq3Hlfil6illkcMYSqOJXI973HRNfsHkK(NRybO113tzXlqwS9ySy)(DdVHh(dwuJvJbySU)eisYcW7Z1vOMkpgJmalaqsWStT0eaxTWiT9yeG8XsvVkCcBIOjGkK(NRYuRRVNYB4H)Gf1y1yagR7pbIKSXqyrYv5jSJ5n8WFWIASAmaJ19Narsw7T)7AsDfMdGrs(yA6MrMgdQZIIg1Q8oxiH)HbmOolkAUktHkVhgWG6SOO5QSo83hgWG6SOOXRO5cj8pI3G3qdzHq0yWPpl2WcHu7)olEbYIZcW3B6QjISalwaMAwSF)olB5iU)SqACKfVazzCWTMAwGnlaFVNxJSa)DSTFuK3Wd)blQbAHf2eisYAV9Fxt3mY0yqDwu0OwL35cj8pmGb1zrrZvzku59WaguNffnxL1H)(WaguNffnEfnxiH)rATAeGHCJ92)DTry1iaJng7T)78gE4pyrnqlSWMarsw6798AutQRWCamsnQPBgz6i6vHtyten6UYRaMHZSRu5F)kI0HHicqay51BQJ4(NNoomeb1cvQ87nr8Pg6790vQijFyiI3vy9MY)vJ0SUR8kGgSCDfcosBeu8Z6WArn)HTnAE2gRWWqAmOolkAOqL35cj8pmGb1zrrZvz1Q8EyadQZIIMRY6WFFyadQZIIgVIMlKW)iEdp8hSOgOfwytGijl99MUAIOMuxH5ayKAut3mY09QWjSjIgDx5vaZWz2vQ8VFfrQ2aeawE9M6iU)5PJAPwOsLFVjIp1qFVNUsfj5J0gbf)SoSwuZFyBJMNTXkWBWBOHAilAaHXW6rqwqayhLL)Irw(DKfp8WMLJYIdWpLRRqdVHh(dw0iPqL3zD0J5n8WFWIsGijBWvQSh(dwz1rFnvEmgj0clS1e97l8rsUMUzK)fJemTnPYd)blJ92)DtWPF(VyKaE4pyzOV3ZRrtWPF(VyCeVHgYcq8PSSvOgWcSyX2eGf73VdxplG9nFw8cKf73VZcW3BfSbzXlqwSHaSa)DSTFuK3Wd)blkbIKSa8(CDfQPYJXipA2HOMa4Qfgj1cvQ87nr8Pg6790vQnjxB6iExH1BOV3kydAWY1vi4WW7kSEd9rLY7myFZ3GLRRqWrdduluPYV3eXNAOV3txP20gEdnKfG4tzjOqhaYI9DSyb4798AKLGxSSFpl2qawEVjIpLf77xyNLJYsJkeGxpltyZYVJSObb1zrrwEil6ilwnoXUrqw8cKf77xyNL5PuyZYdzj40N3Wd)blkbIKSa8(CDfQPYJXipAoOqhaQjaUAHrsTqLk)EteFQH(EpVg3KCEdnKLuQEFUUcz539NLWogiHYYnzjkCXI3ilxXIZcXailpKfha8az53rwO3V8)Gfl23XgzXz57RibFwWpWYrzzrrqwUIfD8TJyXsWPpL3Wd)blkbIKSa8(CDfQPYJXiVktmaQjaUAHrA1iGmXaOHCtmewZRXHbRgbKjganKBORAEnomy1iGmXaOHCd99MUAI4WGvJaYedGgYn037PRuddwncitmaAi3mxD0mCMr1QWHbRgbyAhawWfnpBSsr0Hb91CAcE(QGPXy)kAK6R50e88vbd4Q9)G1WaaVpxxHMJMDiYBOHSmEuKLXHnfBsUIil(ZYVJSGfilWjlKMgRueLf77yXYUtFKLJYIRdbGSq6hJ0Pjw85JnlKcwaGKGSy)(Dwgh0tnlEbYc83X2(rrwSF)olKARKD8RaVHh(dwucejz1XMInjxrut3mY0PJiabGLxVPoI7FE64WqebiubcTxMaSaajbZ)oMPwxFp1SSggIOxfoHnr0O7kVcygoZUsL)9RishPvFnNMGNVkyAm2VIUj5AuR(AonTdal4IMNnwPiQPXy)kkbjuTreGaWYR3aaRFpApmeGaWYR3aaRFpARvFnNMGNVkywwA1xZPPDaybx08SXkfrnllTP1xZPPDaybx08SXkfrnng7xrjyKKBJMrOPQxfoHnr0qVAUu59O0h7Zhg0xZPj45RcMgJ9ROeKCYhgiN0rTqLkV70hji5gs)OrAb4956k0CvMyaK3qdzHqaFwSF)ololKARKD8Ral)U)SC0A7NfNfcXsr9MfRggyb2SyFhlw(DKL5rC)z5OS46W1ZYdzblqEdp8hSOeisYAb)dwA6MrMwFnNMGNVkyAm2VIUj5AuB6i6vHtyten0RMlvEpk9X(8Hb91CAAhawWfnpBSsrutJX(vucsEkrR(AonTdal4IMNnwPiQzznAyqhsPANhX9p3ySFfLG2OXrAb4956k0CvMyaK3qdzHuUkSu(JuwSVJ)o2SSOxrKfsblaqsqwkODwSFkflUsbTZsu4ILhYc9pLILGtFw(DKfQhJS4XWv9SaNSqkybascsasTvYo(vGLGtFkVHh(dwucejzb4956kutLhJrgGfaijygePrRGMa4Qfgzapv60ZJ4(NBm2VIQzKRrnlaHkqO9Ye88vbtJX(v0rKoY18XgTzapv60ZJ4(NBm2VIQzKRrnlaHkqO9YeGfaijy(3Xm1667PMgJ9ROJiDKR5JnsBeTFGzeawVXbbPgKWh9PAthracvGq7Lj45RcMgDWOddreGqfi0EzcWcaKem)7yMAD99utJoy0rddbiubcTxMGNVkyAm2VIU5vp2wqL)iyEEe3)CJX(v0HHEv4e2ertavi9pxLPwxFpvBacvGq7Lj45RcMgJ9ROBA7XggcqOceAVmbybascM)DmtTU(EQPXy)k6Mx9yBbv(JG55rC)Zng7xr1mYhByiIaeawE9M6iU)5PJ8gAilJhfbz5HSaIkpkl)oYYI6erwGtwi1wj74xbwSVJfll6vezbeU0vilWILffzXlqwSAeawpllQtezX(owS4floiiliaSEwoklUoC9S8qwapK3Wd)blkbIKSa8(CDfQPYJXidG5aSaV)GLMa4Qfgz63BI4B(lgZpmdE4MKRXHH2pWmcaR34GGuZvBQXXgPnDA0wxNLfcAWyROn6QmSblVcO20reGaWYR3aaRFpApmeGqfi0EzWyROn6QmSblVcOPXy)kkbjN0tAjqAnMQEv4e2erd9Q5sL3JsFSpF0iTreGqfi0EzWyROn6QmSblVcOPrhm6OHb0wxNLfcAOWLsH)FfXCV0JQnDebiaS86n1rC)ZthhgcqOceAVmu4sPW)VIyUx6rZ2Mq1OMpg5MgJ9ROeKCYj0rddPdqOceAVm6ytXMKRiAA0bJomer7b08nuPggcqay51BQJ4(NNoosB6iExH1BMRoAgoZOAvOblxxHGddbiaS86naW63J2AdqOceAVmZvhndNzuTk00ySFfLGKtob0yQ6vHtyten0RMlvEpk9X(8HHicqay51BaG1VhT1gGqfi0EzMRoAgoZOAvOPXy)kkb1xZPj45RcgWv7)blcqUnPQxfoHnr0y1xmSbpxL9o41fYwlf1BnJCBgPnnARRZYcbnxrd96DDfMT1Lx)kodIaUaQnaHkqO9YCfn0R31vy2wxE9R4mic4cOPXy)kkb14OHH0PrBDDwwiOHU7Gq7iyg26z4m)WogRxBacvGq7L5HDmwpcMVIEe3)ST1OgTTnKBAm2VIoAyiDAaEFUUcnWkVOy(7Rib)ijFyaG3NRRqdSYlkM)(ksWpsBpsB6VVIe8nKBA0bJMdqOceAVgg((ksW3qUjaHkqO9Y0ySFfDZRESTGk)rW88iU)5gJ9ROAg5JnAyaG3NRRqdSYlkM)(ksWpsB0M(7RibFJnMgDWO5aeQaH2RHHVVIe8n2ycqOceAVmng7xr38QhBlOYFemppI7FUXy)kQMr(yJgga4956k0aR8II5VVIe8JCSrJgXBOHSKs17Z1villkcYYdzbevEuw8kklFFfj4tzXlqwcGuwSVJfl297VIiltyZIxSOblRDyFolwnmWB4H)GfLarswaEFUUc1u5XyK)EFkvMIijyNT73RjaUAHrgbfUu6xbA(9(uQmfrsW2GLRRqWHH5rC)Zng7xr30MXgByqhsPANhX9p3ySFfLG2OrcKMqhtZ0xZP537tPYuejbBd99ajPYMrdd6R50879PuzkIKGTH(EGKnTTMRzP7vHtyten0RMlvEpk9X(8uzZiEdnKLXJISObXwrB0vSyl2GLxbKfBgJIbkl64e2ilolKARKD8RallkYcSzHcz539NL7zX(PuSOUczzzXI973z53rwWcKf4KfstJvkIYB4H)GfLars2ffZ3JXAQ8ymsm2kAJUkdBWYRaQPBgzacvGq7Lj45RcMgJ9ROe0MX0gGqfi0EzcWcaKem)7yMAD99utJX(vucAZyAtdW7Z1vO537tPYuejb7SD)(Hb91CA(9(uQmfrsW2qFpqYM2EmcKUxfoHnr0qVAUu59O0h7ZtLThnslaVpxxHMRYedGdd6qkv78iU)5gJ9ROe02KwEdnKLXJISaeUuk8VIileYw6rzH0tXaLfDCcBKfNfsTvYo(vGLffzb2SqHS87(ZY9Sy)ukwuxHSSSyX(97S87ilybYcCYcPPXkfr5n8WFWIsGij7II57XynvEmgjfUuk8)RiM7LEunDZithGqfi0EzcE(QGPXy)kkbj9AJiabGLxVbaw)E0wBebiaS86n1rC)Zthhgcqay51BQJ4(NNoQnaHkqO9YeGfaijy(3Xm1667PMgJ9ROeK0RnnaVpxxHMaSaajbZGinAfggcqOceAVmbpFvW0ySFfLGK(rddbiaS86naW63J2AthrVkCcBIOHE1CPY7rPp2NRnaHkqO9Ye88vbtJX(vucs6hg0xZPPDaybx08SXkfrnng7xrji5JrG0AmvOTUolle0Cf97v4HnndEaUcZ6OsnsR(AonTdal4IMNnwPiQzznAyqhsPANhX9p3ySFfLG2OXHb0wxNLfcAWyROn6QmSblVcO2aeQaH2ldgBfTrxLHny5vanng7xr30MXgPfG3NRRqZvzIbqTrG266SSqqZv0qVExxHzBD51VIZGiGlGddbiubcTxMROHE9UUcZ26YRFfNbraxanng7xr30MXgg0HuQ25rC)Zng7xrjOnJXBOHSSvLDpkLLffzz8tP0wYI973zHuBLSJFfyb2S4pl)oYcwGSaNSqAASsruEdp8hSOeisYcW7Z1vOMkpgJ8SvWCawG3FWstaC1cJuFnNMGNVkyAm2VIUj5AuB6i6vHtyten0RMlvEpk9X(8Hb91CAAhawWfnpBSsrutJX(vucgj5A0OrcK22gnMk91CA0vqiOArFZYAebstOgnQz22OXuPVMtJUccbvl6BwwJsfARRZYcbnxr)EfEytZGhGRWSoQueGqnAmvPrBDDwwiO53X88A6NPhXtPnaHkqO9Y87yEEn9Z0J4Pmng7xrjyK2m2iT6R500oaSGlAE2yLIOML1OHbDiLQDEe3)CJX(vucAJghgqBDDwwiObJTI2ORYWgS8kGAdqOceAVmySv0gDvg2GLxb00ySFfL3Wd)blkbIKSlkMVhJ1u5XyKxrd96DDfMT1Lx)kodIaUaQPBgjaVpxxHMZwbZbybE)blTa8(CDfAUktmaYBOHSmEuKfG7oi0ocYITyRZIooHnYcP2kzh)kWB4H)GfLars2ffZ3JXAQ8yms6UdcTJGzyRNHZ8d7ySEnDZithGqfi0EzcE(QGPrhmQ2icqay51BQJ4(NNoQfG3NRRqZV3NsLPisc2z7(9AthGqfi0Ez0XMInjxr00OdgDyiI2dO5BOsnAyiabGLxVPoI7FE6O2aeQaH2ltawaGKG5FhZuRRVNAA0bJQnnaVpxxHMaSaajbZGinAfggcqOceAVmbpFvW0OdgD0iTGW3qx18A08xGKRiQnni8n0hvkVZtL3O5VajxrCyiI3vy9g6JkL35PYB0GLRRqWHbQfQu53BI4tn037514M2EKwq4BIHWAEnA(lqYve1MgG3NRRqZrZoehg6vHtyten6UYRaMHZSRu5F)kI0HbN(TRYwq7yVzKPKXgga4956k0eGfaijygePrRWWG(Aon6kieuTOVzznsBeOTUolle0Cfn0R31vy2wxE9R4mic4c4WaARRZYcbnxrd96DDfMT1Lx)kodIaUaQnaHkqO9YCfn0R31vy2wxE9R4mic4cOPXy)k6M2EmTrOVMttWZxfmlRHbDiLQDEe3)CJX(vucsOJXBOHSK69JYYrzXzP9FhBwqLRdB)rwS7rz5HSe7KGS4kflWILffzH((ZY3xrc(uwEil6ilQRqqwwwSy)(Dwi1wj74xbw8cKfsblaqsqw8cKLffz53rwSPazHQGplWILail3KfD4VZY3xrc(uw8gzbwSSOil03Fw((ksWNYB4H)GfLars2ffZ3JXunrvWNg53xrc(KRPBgzAaEFUUcnWkVOy(7Rib)iIKCTr89vKGVXgtJoy0CacvGq71WqAaEFUUcnWkVOy(7Rib)ijFyaG3NRRqdSYlkM)(ksWpsBpsBA91CAcE(QGzzPnDebiaS86naW63J2dd6R500oaSGlAE2yLIOMgJ9ROeiTTnAmv9QWjSjIg6vZLkVhL(yF(icg53xrc(gYn6R5mdUA)pyPvFnNM2bGfCrZZgRue1SSgg0xZPPDaybx08SXkfrZ0RMlvEpk9X(CZYA0WqacvGq7Lj45RcMgJ9ROeWMn)(ksW3qUjaHkqO9YaUA)pyPnc91CAcE(QGzzPnDebiaS86n1rC)ZthhgIaG3NRRqtawaGKGzqKgTcJ0gracalVEdjr7ZRHHaeawE9M6iU)5PJAb4956k0eGfaijygePrRG2aeQaH2ltawaGKG5FhZuRRVNAwwAJiaHkqO9Ye88vbZYsB606R50Gb1zrXSAvEBAm2VIUj5JnmOVMtdguNffZuOYBtJX(v0njFSrAJOxfoHnr0O7kVcygoZUsL)9RishgsRVMtJUR8kGz4m7kv(3VIinx(VA0qFpqsKACyqFnNgDx5vaZWz2vQ8VFfrA27GxOH(EGKi18rJgg0xZPHKRaBemJXwq7yhJ1NXcBIxkqZYA0WGoKs1opI7FUXy)kkbTzSHbaEFUUcnWkVOy(7Rib)ihBKwaEFUUcnxLjga5n8WFWIsGij7II57XyQMOk4tJ87RibFB00nJmnaVpxxHgyLxum)9vKGFerAJ2i((ksW3qUPrhmAoaHkqO9AyaG3NRRqdSYlkM)(ksWpsB0MwFnNMGNVkywwAthracalVEdaS(9O9WG(AonTdal4IMNnwPiQPXy)kkbsBBJgtvVkCcBIOHE1CPY7rPp2NpIGr(9vKGVXgJ(AoZGR2)dwA1xZPPDaybx08SXkfrnlRHb91CAAhawWfnpBSsr0m9Q5sL3JsFSp3SSgnmeGqfi0EzcE(QGPXy)kkbSzZVVIe8n2ycqOceAVmGR2)dwAJqFnNMGNVkywwAthracalVEtDe3)80XHHia4956k0eGfaijygePrRWiTreGaWYR3qs0(8sB6i0xZPj45RcML1WqebiaS86naW63J2Jggcqay51BQJ4(NNoQfG3NRRqtawaGKGzqKgTcAdqOceAVmbybascM)DmtTU(EQzzPnIaeQaH2ltWZxfmllTPtRVMtdguNffZQv5TPXy)k6MKp2WG(AonyqDwumtHkVnng7xr3K8XgPnIEv4e2erJUR8kGz4m7kv(3VIiDyiT(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajrQXHb91CA0DLxbmdNzxPY)(vePzVdEHg67bsIuZhnA0WG(AonKCfyJGzm2cAh7yS(mwyt8sbAwwdd6qkv78iU)5gJ9ROe0MXgga4956k0aR8II5VVIe8JCSrAb4956k0CvMyaK3qdzz8OiLfxPyb(7yZcSyzrrwUhJPSalwcG8gE4pyrjqKKDrX89ymL3qdzrdUFhBwicz5QhYYVJSqFwGnloezXd)blwuh95n8WFWIsGijBVQSh(dwz1rFnvEmgPdrnr)(cFKKRPBgjaVpxxHMJMDiYB4H)GfLars2Evzp8hSYQJ(AQ8yms6ZBWBOHSqkxfwk)rkl23XFhBw(DKfBzJECW)Wo2SOVMtwSFkfltxPyboNSy)(9Ry53rwkKWplbN(8gE4pyrnoeJeG3NRRqnvEmgjyJEC2(Pu5PRuz4CQjaUAHr2RcNWMiA(lgTd7kd2OhRFfi2AtRVMtZFXODyxzWg9y9RaX20ySFfLGedGMyNWeymd5dd6R508xmAh2vgSrpw)kqSnng7xrjOh(dwg6798A0GegdRhZ)fJeymd5AtJb1zrrZvz1Q8EyadQZIIgku5DUqc)ddyqDwu04v0CHe(hnsR(Aon)fJ2HDLbB0J1VceBZYI3qdzHuUkSu(JuwSVJ)o2Sa89MUAIilhLf7W(3zj40)kISabGnlaFVNxJSCflK5Q8MfniOolkYB4H)Gf14qKarswaEFUUc1u5XyKhXc2yM(EtxnrutaC1cJmcmOolkAUktHkV1sTqLk)EteFQH(EpVg3K0QzVRW6nu4sLHZ8VJ5jSr6BWY1viyQSHayqDwu0Cvwh(7AJOxfoHnr0y1xmSbpxL9o41fYwlf1BTr0RcNWMiAGf(70CqHENbC0dw8gAilJhfzHuWcaKeKf77yXI)SOqkLLF3lw04ySSvkHGfVazrDfYYYIf73VZcP2kzh)kWB4H)Gf14qKars2aSaajbZ)oMPwxFpvt3mYia71bAkyoas1MonaVpxxHMaSaajbZGinAf0gracvGq7Lj45RcMgDWOAJOxfoHnr0y1xmSbpxL9o41fYwlf17Hb91CAcE(QGzzPnDe9QWjSjIgR(IHn45QS3bVUq2APOEpm0RcNWMiAcOcP)5Qm1667PddZJ4(NBm2VIUj52qAhg0HuQ25rC)Zng7xrjyacvGq7Lj45RcMgJ9ROeG8Xgg0xZPj45RcMgJ9ROBsUnJgPnD60o9BxLTG2XMGrcW7Z1vOjalaqsWStTggOwOsLFVjIp1qFVNxJBA7rAtRVMtdguNffZQv5TPXy)k6MKp2WG(AonyqDwumtHkVnng7xr3K8XgnmOVMttWZxfmng7xr3uJA1xZPj45RcMgJ9ROemsYTzK20r8UcR3qFuP8od238hg0xZPH(EpDLY0ySFfLGKB0OMnMrJPQxfoHnr0eqfs)ZvzQ113thg0xZPj45RcMgJ9ROeuFnNg6790vktJX(vucOrT6R50e88vbZYAK20r0RcNWMiA(lgTd7kd2OhRFfi2ddr0RcNWMiAcOcP)5Qm1667Pdd6R508xmAh2vgSrpw)kqSnng7xr3ejmgwpM)lghnm0RcNWMiA0DLxbmdNzxPY)(vePJ0MoIEv4e2erJUR8kGz4m7kv(3VIiDyiT(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajrQ5dd6R50O7kVcygoZUsL)9RisZEh8cn03dKePMpA0WGoKs1opI7FUXy)kkbjFmTreGqfi0EzcE(QGPrhm6iEdnKLXJISaCvZRrwUIflVaX4lWcSyXRO)(vez539Nf1baPSqoHsXaLfVazrHukl2VFNLyyJS8EteFklEbYI)S87ilybYcCYIZcqOYBw0GG6SOil(Zc5eklumqzb2SOqkLLgJ9RUIiloLLhYsbFw2DaxrKLhYsJZgP7SaU6RiYczUkVzrdcQZII8gE4pyrnoejqKKLUQ51OMcrdkm)EteFAKKRPBgz6gNns3DDfomOVMtdguNffZuOYBtJX(vucABTyqDwu0CvMcvERTXy)kkbjNq1(UcR3qHlvgoZ)oMNWgPVblxxHGJ0(EteFZFXy(HzWd3KCcvZOwOsLFVjIpLang7xr1MgdQZIIMRYEfDyOXy)kkbjganXoHhXBOHSmEuKfGRAEnYYdzz3bGS4Squb1DflpKLffzz8tP0wYB4H)Gf14qKarsw6QMxJA6MrcW7Z1vO5SvWCawG3FWsBacvGq7L5kAOxVRRWSTU86xXzqeWfqtJoyuTOTUolle0Cfn0R31vy2wxE9R4mic4cOw3kh2Xaj8gAilP0q0ILLflaFVNUsXI)S4kfl)fJuwwLcPuww0RiYczgn4TtzXlqwUNLJYIRdxplpKfRggyb2SOWNLFhzHAHHZvS4H)GflQRqw0rf0ol7EbQqwSLn6X6xbInlWIfBy59Mi(uEdp8hSOghIeisYsFVNUsPPBgzeVRW6n0hvkVZG9nFdwUUcb1Mock(zDyTOM)W2gnptOwHHbmOolkAUk7v0HbQfQu53BI4tn037PRuBA7rAtRVMtd99E6kLPXzJ0DxxHAttTqLk)EteFQH(EpDLIG2EyiIEv4e2erZFXODyxzWg9y9RaXE0WW7kSEdfUuz4m)7yEcBK(gSCDfcQvFnNgmOolkMPqL3MgJ9ROe02AXG6SOO5QmfQ8wR(Aon037PRuMgJ9ROeK0QLAHkv(9Mi(ud99E6k1MrsOJ0MoIEv4e2erJkAWBNMNke)RiMjQUylkom8xms6iDeQg3uFnNg6790vktJX(vucyZiTV3eX38xmMFyg8Wn1iVHgYcH097Sa8rLYBwSL9nFwwuKfyXsaKf77yXsJZgP7UUczrF9Sq)tPyXUFpltyZczgn4TtzXQHbw8cKfqyT9ZYIISOJtyJSqkBj1WcW)ukwwuKfDCcBKfsblaqsqwOxfqw(D)zX(PuSy1WalEb)DSzb4790vkEdp8hSOghIeisYsFVNUsPPBg57kSEd9rLY7myFZ3GLRRqqT6R50qFVNUszAC2iD31vO20rqXpRdRf18h22O5zc1kmmGb1zrrZvzVIomqTqLk)EteFQH(EpDLAtcDK20r0RcNWMiAurdE708uH4FfXmr1fBrXHH)IrshPJq14Me6iTV3eX38xmMFyg8WnTnVHgYcH097SylB0J1VceBwwuKfGV3txPy5HSqcIwSSSy53rw0xZjl6rzXvuill6vezb4790vkwGflAKfkgGfiLfyZIcPuwAm2V6kI8gE4pyrnoejqKKL(EpDLst3mYEv4e2erZFXODyxzWg9y9RaXwl1cvQ87nr8Pg6790vQnJ02AthH(Aon)fJ2HDLbB0J1VceBZYsR(Aon037PRuMgNns3DDfomKgG3NRRqdyJEC2(Pu5PRuz4CQnT(Aon037PRuMgJ9ROe02dduluPYV3eXNAOV3txP20gTVRW6n0hvkVZG9nFdwUUcb1QVMtd99E6kLPXy)kkb14OrJ4n0qwiLRclL)iLf774VJnlolaFVPRMiYYIISy)ukwc(IISa89E6kflpKLPRuSaNtnXIxGSSOilaFVPRMiYYdzHeeTyXw2OhRFfi2SqFpqcllldlA(ySCuw(DKLgT111iilBLsiy5HSeC6ZcW3B6QjIea4790vkEdp8hSOghIeisYcW7Z1vOMkpgJK(EpDLkBhwFE6kvgoNAcGRwyKo9BxLTG2XEtnFSuLMCnJIFwhwlQ5pSTrZZ2yfs1ygBgLQ0KRz6R508xmAh2vgSrpw)kqSn03dKKQXmKpsZsRVMtd99E6kLPXy)kAQSnPJAHkvE3PpMQiExH1BOpQuENb7B(gSCDfcosZshGqfi0EzOV3txPmng7xrtLTjDuluPY7o9Xu9UcR3qFuP8od238ny56keCKMLwFnNM5QJMHZmQwfAAm2VIMknosBA91CAOV3txPmlRHHaeQaH2ld99E6kLPXy)k6iEdnKLXJISa89MUAIil2VFNfBzJES(vGyZYdzHeeTyzzXYVJSOVMtwSF)oC9SOG0RiYcW37PRuSSS(lgzXlqwwuKfGV30vtezbwSqOeGLXb3AQzH(EGeklR6pfleklV3eXNYB4H)Gf14qKarsw67nD1ernDZib4956k0a2OhNTFkvE6kvgoNAb4956k0qFVNUsLTdRppDLkdNtTraW7Z1vO5iwWgZ03B6QjIddP1xZPr3vEfWmCMDLk)7xrKMl)xnAOVhiztBpmOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqYM2EKwQfQu53BI4tn037PRueKq1cW7Z1vOH(EpDLkBhwFE6kvgoN8gAilJhfzHA37ywOqw(D)zjkCXcr8zj2jmllR)Irw0JYYIEfrwUNfNYIYFKfNYIfKspDfYcSyrHukl)UxSyBwOVhiHYcSzjLIf9zX(owSyBcWc99ajuwqcBDnYB4H)Gf14qKarswh0T(daMP29owtHObfMFVjIpnsY10nJmI)cKCfrTr4H)GLXbDR)aGzQDVJZGEStenxLNQJ4(pmacFJd6w)baZu7EhNb9yNiAOVhiHG2wli8noOB9hamtT7DCg0JDIOPXy)kkbTnVHgYcHmC2iDNfBbiSMxJSCtwi1wj74xbwokln6Gr1el)o2ilEJSOqkLLF3lw0ilV3eXNYYvSqMRYBw0GG6SOil2VFNfGWN0OjwuiLYYV7flKpglWFhB7hfz5kw8kklAqqDwuKfyZYYILhYIgz59Mi(uw0XjSrwCwiZv5nlAqqDwu0WITewB)S04Sr6olGR(kISKs7kWgbzrdITG2XogRNLvPqkLLRybiu5nlAqqDwuK3Wd)blQXHibIKSXqynVg1uiAqH53BI4tJKCnDZiBC2iD31vO23BI4B(lgZpmdE4MPttoHsG0uluPYV3eXNAOV3ZRXuztQ0xZPbdQZIIz1Q82SSgnIang7xrhr6stobExH1BE7xLJHWIAWY1vi4iTo9BxLTG2XEtaEFUUcn0zoaPVMPVMtd99E6kLPXy)kAQi9At7w5WogizyaG3NRRqZrSGnMPV30vtehgIadQZIIMRYEfDK20biubcTxMGNVkyA0bJQfdQZIIMRYEfvBeG96anfmhaPAtdW7Z1vOjalaqsWmisJwHHHaeQaH2ltawaGKG5FhZuRRVNAA0bJomeracalVEtDe3)80XrdduluPYV3eXNAOV3ZRrcMoTMRzP1xZPbdQZIIz1Q82SSsLThnkvPjNaVRW6nV9RYXqyrny56keC0iTrGb1zrrdfQ8oxiHFTPJiaHkqO9Ye88vbtJoy0HbWEDGMcMdG0rddPXG6SOO5QmfQ8EyqFnNgmOolkMvRYBZYsBeVRW6nu4sLHZ8VJ5jSr6BWY1vi4iTPPwOsLFVjIp1qFVNxJeK8XsvAYjW7kSEZB)QCmewudwUUcbhnAK20reGaWYR3qs0(8Ayic91CAi5kWgbZySf0o2Xy9zSWM4Lc0SSggWG6SOO5QmfQ8EK2i0xZPPDaybx08SXkfrZ0RMlvEpk9X(CZYI3qdzz8OilKg4wybwSeazX(97W1ZsWTSUIiVHh(dwuJdrcejzNWoGz4mx(VAut3ms3kh2Xajdda8(CDfAoIfSXm99MUAIiVHh(dwuJdrcejzb4956kutLhJrgaZbybE)bRSdrnbWvlmYia71bAkyoas1MgG3NRRqtamhGf49hS0MwFnNg6790vkZYAy4DfwVH(Os5DgSV5BWY1vi4WqacalVEtDe3)80XrAbHVjgcR51O5VajxruB6i0xZPHcv0)cOzzPnc91CAcE(QGzzPnDeVRW6nZvhndNzuTk0GLRRqWHb91CAcE(QGbC1(FWAZaeQaH2lZC1rZWzgvRcnng7xrjGMpsB6iO4N1H1IA(dBB08SnwHHbmOolkAUkRwL3ddyqDwu0qHkVZfs4FKwaEFUUcn)EFkvMIijyNT73RnDebiaS86n1rC)Zthhga4956k0eGfaijygePrRWWqacvGq7LjalaqsW8VJzQ113tnng7xrji5ACK23BI4B(lgZpmdE4M6R50e88vbd4Q9)GvQgZqAhnmOdPuTZJ4(NBm2VIsq91CAcE(QGbC1(FWIaKBtQ6vHtytenw9fdBWZvzVdEDHS1sr9EeVHgYY4rrwinnwPikl2VFNfsTvYo(vG3Wd)blQXHibIKSTdal4IMNnwPiQMUzK6R50e88vbtJX(v0njxJdd6R50e88vbd4Q9)Gfbi3Mu1RcNWMiAS6lg2GNRYEh86czRLI6nbTH0RfG3NRRqtamhGf49hSYoe5n0qwgpkYcP2kzh)kWcSyjaYYQuiLYIxGSOUcz5EwwwSy)(DwifSaajb5n8WFWIACisGijBavi9pxLD1rSIX610nJeG3NRRqtamhGf49hSYoe1MoIaeawE9gay97r7HHi6vHtyten0RMlvEpk9X(8HHEv4e2erJvFXWg8Cv27GxxiBTuuVhg0xZPj45RcgWv7)bRnJ0gs)OHb91CAAhawWfnpBSsruZYsR(AonTdal4IMNnwPiQPXy)kkbjxJgnYB4H)Gf14qKars2RcEx(FWst3msaEFUUcnbWCawG3FWk7qK3qdzz8OilAqSf0o2SmoybYcSyjaYI973zb4790vkwwwS4filuhaYYe2SqiwkQ3S4filKARKD8RaVHh(dwuJdrcejzXylODSZ6Wcut3mY0biubcTxMGNVkyAm2VIsa91CAcE(QGbC1(FWIa9QWjSjIgR(IHn45QS3bVUq2APOENkYTzZaeQaH2ldgBbTJDwhwGgWv7)blcq(yJgg0xZPj45RcMgJ9ROBQ5ddG96anfmhaP8gAileYWzJ0DwMkVrwGflllwEil2ML3BI4tzX(97W1ZcP2kzh)kWIoEfrwCD46z5HSGe26AKfVazPGplqayhClRRiYB4H)Gf14qKarsw6JkL35PYButHObfMFVjIpnsY10nJSXzJ0DxxHA)lgZpmdE4MKRrTuluPYV3eXNAOV3ZRrcsOADRCyhdKOnT(AonbpFvW0ySFfDtYhByic91CAcE(QGzznI3qdzz8OilKgOgWYnz5k6bIS4flAqqDwuKfVazrDfYY9SSSyX(97S4SqiwkQ3Sy1WalEbYYwbDR)aGSa0U3X8gE4pyrnoejqKKDU6Oz4mJQvHA6MrIb1zrrZvzVIQnTBLd7yGKHHi6vHtytenw9fdBWZvzVdEDHS1sr9EK206R50y1xmSbpxL9o41fYwlf1BdaxTqcAJghByqFnNMGNVkyAm2VIUPMpsBAq4BCq36payMA374mOh7erZFbsUI4WqebiaS86nfgAOc2GdduluPYV3eXNUPnJ0MwFnNM2bGfCrZZgRue10ySFfLGPenlnHMQEv4e2erd9Q5sL3JsFSpFKw91CAAhawWfnpBSsruZYAyic91CAAhawWfnpBSsruZYAK20reGqfi0EzcE(QGzznmOVMtZV3NsLPisc2g67bsii5Au78iU)5gJ9ROe0MXgt78iU)5gJ9ROBs(yJnmebfUu6xbA(9(uQmfrsW2GLRRqWrAttHlL(vGMFVpLktrKeSny56keCyiaHkqO9Ye88vbtJX(v0nT9yJ0(EteFZFXy(HzWd3uJdd6qkv78iU)5gJ9ROeK8X4n0qwgpkYIZcW37PRuSylw4VZIvddSSkfsPSa89E6kflhLfx1OdgLLLflWMLOWflEJS46W1ZYdzbca7GBXYwPecEdp8hSOghIeisYsFVNUsPPBgP(AonWc)DA2c7aA9hSmllTP1xZPH(EpDLY04Sr6URRWHbN(TRYwq7yVzkzSr8gAil2YvSflBLsiyrhNWgzHuWcaKeKf73VZcW37PRuS4fil)owSa89MUAIiVHh(dwuJdrcejzPV3txP00nJmabGLxVPoI7FE6O2iExH1BOpQuENb7B(gSCDfcQnnaVpxxHMaSaajbZGinAfggcqOceAVmbpFvWSSgg0xZPj45RcML1iTbiubcTxMaSaajbZ)oMPwxFp10ySFfLGedGMyNWPkGNkTt)2vzlODSjDa8(CDfAOZCas)rA1xZPH(EpDLY0ySFfLGeQ2ia71bAkyoas5n8WFWIACisGijl99MUAIOMUzKbiaS86n1rC)Zth1MgG3NRRqtawaGKGzqKgTcddbiubcTxMGNVkywwdd6R50e88vbZYAK2aeQaH2ltawaGKG5FhZuRRVNAAm2VIsqnQfG3NRRqd99E6kv2oS(80vQmCo1Ib1zrrZvzVIQncaEFUUcnhXc2yM(EtxnruBeG96anfmhaP8gAilJhfzb47nD1erwSF)olEXITyH)olwnmWcSz5MSefU2gKfiaSdUflBLsiyX(97SefUAwkKWplbN(gw2QIczbCfBXYwPecw8NLFhzblqwGtw(DKLuQy97rBw0xZjl3KfGV3txPyXoCPaRTFwMUsXcCozb2SefUyXBKfyXInS8EteFkVHh(dwuJdrcejzPV30vte10nJuFnNgyH)onhuO3zah9GLzznmKoc6798A04w5WogirBea8(CDfAoIfSXm99MUAI4WqA91CAcE(QGPXy)kkb1Ow91CAcE(QGzznmKoT(AonbpFvW0ySFfLGedGMyNWPkGNkTt)2vzlODSjDa8(CDfAO0Cas)rA1xZPj45RcML1WG(AonTdal4IMNnwPiAME1CPY7rPp2NBAm2VIsqIbqtSt4ufWtL2PF7QSf0o2KoaEFUUcnuAoaP)iT6R500oaSGlAE2yLIOz6vZLkVhL(yFUzznsBacalVEdaS(9O9OrAttTqLk)EteFQH(EpDLIG2EyaG3NRRqd99E6kv2oS(80vQmCohnsBea8(CDfAoIfSXm99MUAIO20r0RcNWMiA(lgTd7kd2OhRFfi2dduluPYV3eXNAOV3txPiOThXBOHSmEuKfBbiSOSCflaHkVzrdcQZIIS4filuhaYcPzPuSylaHfltyZcP2kzh)kWB4H)Gf14qKars2cTNJHWst3mY06R50Gb1zrXmfQ820ySFfDtKWyy9y(VyCyiDy3BIinsB02yy3BIy(VyKGAC0Wqy3BIinsBpsRBLd7yGeEdp8hSOghIeisYU7QzogclnDZitRVMtdguNffZuOYBtJX(v0nrcJH1J5)IXHH0HDVjI0iTrBJHDVjI5)IrcQXrddHDVjI0iT9iTUvoSJbs0MwFnNM2bGfCrZZgRue10ySFfLGAuR(AonTdal4IMNnwPiQzzPnIEv4e2erd9Q5sL3JsFSpFyic91CAAhawWfnpBSsruZYAeVHh(dwuJdrcejzNlLkhdHLMUzKP1xZPbdQZIIzku5TPXy)k6MiHXW6X8FXO20biubcTxMGNVkyAm2VIUPghByiaHkqO9YeGfaijy(3Xm1667PMgJ9ROBQXXgnmKoS7nrKgPnABmS7nrm)xmsqnoAyiS7nrKgPThP1TYHDmqI206R500oaSGlAE2yLIOMgJ9ROeuJA1xZPPDaybx08SXkfrnllTr0RcNWMiAOxnxQ8Eu6J95ddrOVMtt7aWcUO5zJvkIAwwJ4n0qwgpkYcHeudybwSqkBjVHh(dwuJdrcejzT7DFWodNzuTkK3qdzHuUkSu(JuwSVJ)o2S8qwwuKfGV3ZRrwUIfGqL3SyF)c7SCuw8NfnYY7nr8PeGCwMWMfea2rzXMXiDSe70h7OSaBwiuwa(EtxnrKfni2cAh7ySEwOVhiHYB4H)Gf14qKarswaEFUUc1u5XyK03751y(QmfQ8wtaC1cJKAHkv(9Mi(ud99EEnUjHsGPcc70Xo9XoAgGRwyQiFSXiD2m2icmvqyNwFnNg67nD1eXmgBbTJDmwFMcvEBOVhiH0rOJ4n0qwiLRclL)iLf774VJnlpKfcP2)Dwax9vezH00yLIO8gE4pyrnoejqKKfG3NRRqnvEmgP92)98v5zJvkIQjaUAHrsoPJAHkvE3PpsqB0S0JzSjvPPwOsLFVjIp1qFVNxJAg5JsvAYjW7kSEdfUuz4m)7yEcBK(gSCDfcMkYnAC0icmMHCnMk91CAAhawWfnpBSsrutJX(vuEdnKLXJISqi1(VZYvSaeQ8MfniOolkYcSz5MSuqwa(EpVgzX(PuSmVNLREilKARKD8RalEfng2iVHh(dwuJdrcejzT3(VRPBgzAmOolkAuRY7CHe(hgWG6SOOXRO5cj8RfG3NRRqZrZbf6aWrAt)EteFZFXy(HzWd3KqhgWG6SOOrTkVZxLTzyqhsPANhX9p3ySFfLGKp2OHb91CAWG6SOyMcvEBAm2VIsqp8hSm03751ObjmgwpM)lg1QVMtdguNffZuOYBZYAyadQZIIMRYuOYBTraW7Z1vOH(EpVgZxLPqL3dd6R50e88vbtJX(vuc6H)GLH(EpVgniHXW6X8FXO2ia4956k0C0CqHoauR(AonbpFvW0ySFfLGiHXW6X8FXOw91CAcE(QGzznmOVMtt7aWcUO5zJvkIAwwAb4956k0yV9FpFvE2yLIOddraW7Z1vO5O5GcDaOw91CAcE(QGPXy)k6MiHXW6X8FXiVHgYY4rrwa(EpVgz5MSCflK5Q8MfniOolkQjwUIfGqL3SObb1zrrwGflekby59Mi(uwGnlpKfRggybiu5nlAqqDwuK3Wd)blQXHibIKS03751iVHgYcPXvQFVx8gE4pyrnoejqKKTxv2d)bRS6OVMkpgJC6k1V3lEdEdnKfGV30vtezzcBwIHaWySEwwLcPuww0RiYY4GBn18gE4pyrntxP(9Efj99MUAIOMUzKr0RcNWMiA0DLxbmdNzxPY)(vePg0wxNLfcYBOHSqkN(S87ilGWNf73VZYVJSedPpl)fJS8qwCqqww1Fkw(DKLyNWSaUA)pyXYrzz)Edlax18AKLgJ9ROSeVu)zPoeKLhYsS)HDwIHWAEnYc4Q9)GfVHh(dwuZ0vQFVxeisYsx18AutHObfMFVjIpnsY10nJee(MyiSMxJMgJ9ROB2ySFfnv2ydPJCnN3Wd)blQz6k1V3lcejzJHWAEnYBWBOHSmEuKLTc6w)bazbODVJzX(owS87yJSCuwkilE4pailu7EhRjwCklk)rwCklwqk90vilWIfQDVJzX(97SydlWMLjAhBwOVhiHYcSzbwS4SyBcWc1U3XSqHS87(ZYVJSuODwO29oMfV7daszjLIf9zXNp2S87(Zc1U3XSGe26AKYB4H)Gf1q)iDq36payMA37ynfIguy(9Mi(0ijxt3mYiaHVXbDR)aGzQDVJZGESten)fi5kIAJWd)blJd6w)baZu7EhNb9yNiAUkpvhX9xB6iaHVXbDR)aGzQDVJZ7ORm)fi5kIddGW34GU1FaWm1U3X5D0vMgJ9ROBQXrddGW34GU1FaWm1U3Xzqp2jIg67bsiOT1ccFJd6w)baZu7EhNb9yNiAAm2VIsqBRfe(gh0T(daMP29ood6Xor08xGKRiYBOHSmEuKYcPGfaijil3KfsTvYo(vGLJYYYIfyZsu4IfVrwarA0kCfrwi1wj74xbwSF)olKcwaGKGS4filrHlw8gzrhvq7SqOJrwBpwAsHkK(NRybO113thXYwPecwUIfNfYhJaSqXalAqqDwu0WYwvuilGWA7Nff(SylB0J1VceBwqcBDnQjwCLDpkLLffz5kwi1wj74xbwSF)oleILI6nlEbYI)S87il037Nf4KfNLXb3AQzX(vGq7gEdcWIh(dwud9jqKKnalaqsW8VJzQ113t10nJmcWEDGMcMdGuTPtdW7Z1vOjalaqsWmisJwbTreGqfi0EzcE(QGPrhmQ2i6vHtytenw9fdBWZvzVdEDHS1sr9EyqFnNMGNVkywwAthrVkCcBIOXQVyydEUk7DWRlKTwkQ3dd9QWjSjIMaQq6FUktTU(E6WW8iU)5gJ9ROBsUnK2HbDiLQDEe3)CJX(vucgGqfi0EzcE(QGPXy)kkbiFSHb91CAcE(QGPXy)k6MKBZOrAtN2PF7QSf0o2emsaEFUUcnbybascMDQL206R50Gb1zrXSAvEBAm2VIUj5JnmOVMtdguNffZuOYBtJX(v0njFSrdd6R50e88vbtJX(v0n1Ow91CAcE(QGPXy)kkbJKCBgPnDe9QWjSjIM)Ir7WUYGn6X6xbI9Wqe9QWjSjIMaQq6FUktTU(E6WG(Aon)fJ2HDLbB0J1VceBtJX(v0nrcJH1J5)IXrdd9QWjSjIgDx5vaZWz2vQ8VFfr6iTPJOxfoHnr0O7kVcygoZUsL)9RishgsRVMtJUR8kGz4m7kv(3VIinx(VA0qFpqsKA(WG(Aon6UYRaMHZSRu5F)kI0S3bVqd99ajrQ5JgnmOdPuTZJ4(NBm2VIsqYhtBebiubcTxMGNVkyA0bJoI3qdzz8OilaFVPRMiYYdzHeeTyzzXYVJSylB0J1VceBw0xZjl3KL7zXoCPazbjS11il64e2ilZRo6(vez53rwkKWplbN(SaBwEilGRylw0XjSrwifSaajb5n8WFWIAOpbIKS03B6QjIA6Mr2RcNWMiA(lgTd7kd2OhRFfi2Athr606R508xmAh2vgSrpw)kqSnng7xr30d)blJ92)DdsymSEm)xmsGXmKRnnguNffnxL1H)(WaguNffnxLPqL3ddyqDwu0OwL35cj8pAyqFnNM)Ir7WUYGn6X6xbITPXy)k6ME4pyzOV3ZRrdsymSEm)xmsGXmKRnnguNffnxLvRY7HbmOolkAOqL35cj8pmGb1zrrJxrZfs4F0OHHi0xZP5Vy0oSRmyJES(vGyBwwJggsRVMttWZxfmlRHbaEFUUcnbybascMbrA0kmsBacvGq7LjalaqsW8VJzQ113tnn6Gr1gGaWYR3uhX9ppDuBA91CAWG6SOywTkVnng7xr3K8Xgg0xZPbdQZIIzku5TPXy)k6MKp2OrAthracalVEdjr7ZRHHaeQaH2ldgBbTJDwhwGMgJ9ROBQ5J4n0qwSLRylwa(EtxnrKYI973zzCUYRaYcCYYwvkws9(vePSaBwEilwnA5nYYe2SqkybascYI973zzCWTMAEdp8hSOg6tGijl99MUAIOMUzK9QWjSjIgDx5vaZWz2vQ8VFfrQ20P1xZPr3vEfWmCMDLk)7xrKMl)xnAOVhiztBgg0xZPr3vEfWmCMDLk)7xrKM9o4fAOVhiztBgPnaHkqO9Ye88vbtJX(v0njTAJiaHkqO9YeGfaijy(3Xm1667PML1Wq6aeawE9M6iU)5PJAdqOceAVmbybascM)DmtTU(EQPXy)kkbjFmTyqDwu0Cv2ROAD63UkBbTJ9M2mgbS9yPkaHkqO9Ye88vbtJoy0rJ4n0qwifSaV)GfltyZIRuSacFkl)U)Se7KGuwORgz53XOS4nwB)S04Sr6ocYI9DSyHqMdal4IYcPPXkfrzz3PSOqkLLF3lw0ilumqzPXy)QRiYcSz53rw0GylODSzzCWcKf91CYYrzX1HRNLhYY0vkwGZjlWMfVIYIgeuNffz5OS46W1ZYdzbjS11iVHh(dwud9jqKKfG3NRRqnvEmgji8ZnARRRXySEQMa4QfgzA91CAAhawWfnpBSsrutJX(v0n14Wqe6R500oaSGlAE2yLIOML1iTrOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MLL206R50qYvGncMXylODSJX6ZyHnXlfOPXy)kkbjganXoHhPnT(AonyqDwumtHkVnng7xr3Kya0e7eEyqFnNgmOolkMvRYBtJX(v0njganXoHhgshH(AonyqDwumRwL3ML1Wqe6R50Gb1zrXmfQ82SSgPnI3vy9gkur)lGgSCDfcoI3qdzHuWc8(dwS87(ZsyhdKqz5MSefUyXBKf46PhiYcguNffz5HSalvuwaHpl)o2ilWMLJybBKLF)OSy)(Dwacv0)ciVHh(dwud9jqKKfG3NRRqnvEmgji8ZW1tpqmJb1zrrnbWvlmY0rOVMtdguNffZuOYBZYsBe6R50Gb1zrXSAvEBwwJ0gX7kSEdfQO)fqdwUUcb1grVkCcBIO5Vy0oSRmyJES(vGyZBOHSylHplUsXY7nr8PSy)(9RyHq4figFbwSF)oC9SabGDWTSUIib(DKfxhcazjalW7pyr5n8WFWIAOpbIKSXqynVg1uiAqH53BI4tJKCnDZitRVMtdguNffZuOYBtJX(v0nBm2VIomOVMtdguNffZQv5TPXy)k6Mng7xrhga4956k0ac)mC90deZyqDwuCK2gNns3DDfQ99Mi(M)IX8dZGhUj52O1TYHDmqIwaEFUUcnGWp3OTUUgJX6P8gE4pyrn0Narsw6QMxJAkenOW87nr8PrsUMUzKP1xZPbdQZIIzku5TPXy)k6Mng7xrhg0xZPbdQZIIz1Q820ySFfDZgJ9ROdda8(CDfAaHFgUE6bIzmOolkosBJZgP7UUc1(EteFZFXy(HzWd3KCB06w5WogirlaVpxxHgq4NB0wxxJXy9uEdp8hSOg6tGijl9rLY78u5nQPq0GcZV3eXNgj5A6MrMwFnNgmOolkMPqL3MgJ9ROB2ySFfDyqFnNgmOolkMvRYBtJX(v0nBm2VIomaW7Z1vObe(z46PhiMXG6SO4iTnoBKU76ku77nr8n)fJ5hMbpCtYj9ADRCyhdKOfG3NRRqdi8ZnARRRXySEkVHgYITe(S0hX9NfDCcBKfstJvkIYYnz5EwSdxkqwCLcANLOWflpKLgNns3zrHuklGR(kISqAASsruws)7hLfyPIYYUBzHfLf73VdxplaVAUuSqiFu6J95J4n8WFWIAOpbIKSa8(CDfQPYJXilyEpk9X(8m6TkAge(AcGRwyKbiaS86naW63J2AJOxfoHnr0qVAUu59O0h7Z1grVkCcBIOjCDqHz4mRUjM9cmdI(VRnaHkqO9YOJnfBsUIOPrhmQ2aeQaH2lt7aWcUO5zJvkIAA0bJQnc91CAcE(QGzzPnTt)2vzlODS3uZjTdd6R50ORGqq1I(ML1iEdp8hSOg6tGijBmewZRrnDZib4956k0uW8Eu6J95z0Bv0mi812ySFfLG2mgVHh(dwud9jqKKLUQ51OMUzKa8(CDfAkyEpk9X(8m6TkAge(ABm2VIsqYtj8gAilJhfzH0a3clWILail2VFhUEwcUL1ve5n8WFWIAOpbIKStyhWmCMl)xnQPBgPBLd7yGeEdnKLXJISObXwq7yZY4Gfil2VFNfVIYIcwezbl4I4olkN(xrKfniOolkYIxGS8DuwEilQRqwUNLLfl2VFNfcXsr9MfVazHuBLSJFf4n8WFWIAOpbIKSySf0o2zDybQPBgz6aeQaH2ltWZxfmng7xrjG(AonbpFvWaUA)pyrGEv4e2erJvFXWg8Cv27GxxiBTuuVtf52SzacvGq7LbJTG2XoRdlqd4Q9)GfbiFSrdd6R50e88vbtJX(v0n18HbWEDGMcMdGuEdnKfG4tzX(owSSvkHGf6oCPazrhzbCfBHGS8qwk4Zcea2b3IL02s0clqklWIfsZQJYcCYIgOwfYIxGS87ilAqqDwuCeVHh(dwud9jqKKfG3NRRqnvEmgPtTYGRylnbWvlmsN(TRYwq7yVzkzmnlTngnMk91CAMRoAgoZOAvOH(EGenZMuHb1zrrZvz1Q8EeVHgYY4rrwi1wj74xbwSF)olKcwaGKGKnL2vGncYcqRRVNYIxGSacRTFwGaW2EFpYcHyPOEZcSzX(owSmofecQw0Nf7WLcKfKWwxJSOJtyJSqQTs2XVcSGe26AKAyXwWjbzHUAKLhYcwp2S4SqMRYBw0GG6SOil23XILf9iwSKAB0CwSXkWIxGS4kflKYwszX(PuSOJbymYsJoyuwOqyXcwWfXDwax9vez53rw0xZjlEbYci8PSS7aqw0rSyHUMZlCy9QOS04Sr6ocA4n8WFWIAOpbIKSa8(CDfQPYJXidG5aSaV)GvM(AcGRwyKra2Rd0uWCaKQnnaVpxxHMayoalW7pyPnc91CAcE(QGzzPnDeu8Z6WArn)HTnAE2gRWWaguNffnxLvRY7HbmOolkAOqL35cj8psB60Pb4956k04uRm4k2AyiabGLxVPoI7FE64Wq6aeawE9gsI2NxAdqOceAVmySf0o2zDybAA0bJoAyOxfoHnr08xmAh2vgSrpw)kqShPfe(g6QMxJMgJ9ROBQ5AbHVjgcR51OPXy)k6MPeTPbHVH(Os5DEQ8gnng7xr3K8XggI4DfwVH(Os5DEQ8gny56keCKwaEFUUcn)EFkvMIijyNT73R99Mi(M)IX8dZGhUP(AonbpFvWaUA)pyLQXmK2Hb91CA0vqiOArFZYsR(Aon6kieuTOVPXy)kkb1xZPj45RcgWv7)blcKMCBsvVkCcBIOXQVyydEUk7DWRlKTwkQ3JgnmKgT11zzHGgm2kAJUkdBWYRaQnaHkqO9YGXwrB0vzydwEfqtJX(vucsoPN0sG0Amv9QWjSjIg6vZLkVhL(yF(OrJ0MoDebiaS86n1rC)ZthhgsdW7Z1vOjalaqsWmisJwHHHaeQaH2ltawaGKG5FhZuRRVNAAm2VIsqY14iTPJOxfoHnr0O7kVcygoZUsL)9RishgC63UkBbTJnb14yAdqOceAVmbybascM)DmtTU(EQPrhm6OrddZJ4(NBm2VIsWaeQaH2ltawaGKG5FhZuRRVNAAm2VIoAyqhsPANhX9p3ySFfLG6R50e88vbd4Q9)Gfbi3Mu1RcNWMiAS6lg2GNRYEh86czRLI69iEdnKLXJISqAASsruwSF)olKARKD8RalRsHuklKMgRueLf7WLcKfLtFwuWIi2S87EXcP2kzh)kOjw(DSyzrrw0XjSrEdp8hSOg6tGijB7aWcUO5zJvkIQPBgP(AonbpFvW0ySFfDtY14WG(AonbpFvWaUA)pyrqBiTeOxfoHnr0y1xmSbpxL9o41fYwlf17urUnAb4956k0eaZbybE)bRm95n8WFWIAOpbIKSbuH0)Cv2vhXkgRxt3msaEFUUcnbWCawG3FWktFTP1xZPj45RcgWv7)bRnJ0gslb6vHtytenw9fdBWZvzVdEDHS1sr9ovKBZWqebiaS86naW63J2Jgg0xZPPDaybx08SXkfrnllT6R500oaSGlAE2yLIOMgJ9ROemLqGaSax3BSAmCum7QJyfJ1B(lgZaC1cjq6i0xZPrxbHGQf9nllTr8UcR3qFVvWg0GLRRqWr8gE4pyrn0Nars2RcEx(FWst3msaEFUUcnbWCawG3FWktFEdnKLuQEFUUczzrrqwGflU(PU)qkl)U)Sy3RNLhYIoYc1bGGSmHnlKARKD8Raluil)U)S87yuw8gRNf7o9rqwsPyrFw0XjSrw(DmM3Wd)blQH(eisYcW7Z1vOMkpgJK6aW8e25GNVkOjaUAHrgGqfi0EzcE(QGPXy)k6MKp2Wqea8(CDfAcWcaKemdI0OvqBacalVEtDe3)80XHbWEDGMcMdGuEdnKLXJIuwinqnGLBYYvS4flAqqDwuKfVaz57dPS8qwuxHSCplllwSF)oleILI6TMyHuBLSJFf0elAqSf0o2SmoybYIxGSSvq36pailaT7DmVHh(dwud9jqKKDU6Oz4mJQvHA6MrIb1zrrZvzVIQnTt)2vzlODSjykXgntFnNM5QJMHZmQwfAOVhijvACyqFnNM2bGfCrZZgRue1SSgPnT(Aonw9fdBWZvzVdEDHS1sr92aWvlKG2qOJnmOVMttWZxfmng7xr3uZhPfG3NRRqd1bG5jSZbpFvqB6icqay51Bkm0qfSbhgaHVXbDR)aGzQDVJZGESten)fi5kIJ0MoIaeawE9gay97r7Hb91CAAhawWfnpBSsrutJX(vucMs0S0eAQ6vHtyten0RMlvEpk9X(8rA1xZPPDaybx08SXkfrnlRHHi0xZPPDaybx08SXkfrnlRrAthracalVEdjr7ZRHHaeQaH2ldgBbTJDwhwGMgJ9ROBAZyJ0(EteFZFXy(HzWd3uJdd6qkv78iU)5gJ9ROeK8X4n0qwgpkYITyH)olaFVNUsXIvdduwUjlaFVNUsXYrRTFwww8gE4pyrn0Narsw6790vknDZi1xZPbw4VtZwyhqR)GLzzPvFnNg6790vktJZgP7UUc5n0qwiLxbuXcW3BfSbz5MSCpl7oLffsPS87EXIgPS0ySF1ve1elrHlw8gzXFwsjJraw2kLqWIxGS87ilHv3y9SObb1zrrw2DklAKauwAm2V6kI8gE4pyrn0Nars2GxbuL1xZPMkpgJK(ERGnOMUzK6R50qFVvWg00ySFfLGAuBA91CAWG6SOyMcvEBAm2VIUPghg0xZPbdQZIIz1Q820ySFfDtnosRt)2vzlODS3mLmgVHgYcP8kGkw(DKfcXsr9Mf91CYYnz53rwSAyGf7WLcS2(zrDfYYYIf73VZYVJSuiHFw(lgzHuWcaKeKLamgPSaNtwcGgws9(rzzrxUsfLfyPIYYUBzHfLfWvFfrw(DKLXrMgEdp8hSOg6tGijBWRaQY6R5utLhJrA1xmSbpxL9o41fYwlf1BnDZiFxH1BUk4D5)bldwUUcb1gX7kSEtH2ZXqyzWY1viO2u6sN22JnMM50VDv2cAhBcqOJPzu8Z6WArn)HTnAE2gRqQi0Xgr6stOKoQfQu5DN(4inlaHkqO9YeGfaijy(3Xm1667PMgJ9ROJiykDPtB7XgtZC63UkBbTJTMPVMtJvFXWg8Cv27GxxiBTuuVnaC1cjaHoMMrXpRdRf18h22O5zBScPIqhBePlnHs6OwOsL3D6JJ0SaeQaH2ltawaGKG5FhZuRRVNAAm2VIosBacvGq7Lj45RcMgJ9ROBA7X0QVMtJvFXWg8Cv27GxxiBTuuVnaC1cjOnKpMw91CAS6lg2GNRYEh86czRLI6TbGRw4M2EmTbiubcTxMaSaajbZ)oMPwxFp10ySFfLGe6yANhX9p3ySFfDZaeQaH2ltawaGKG5FhZuRRVNAAm2VIsasV209QWjSjIMaQq6FUktTU(E6WaaVpxxHMaSaajbZGinAfgXBOHSaeFkl23XIfcXsr9Mf6oCPazrhzXQHHacYc6TkklpKfDKfxxHS8qwwuKfsblaqsqwGflbiubcTxSKwdOuS(ZvQOSOJbymsz57fYYnzbCfBDfrw2kLqWsbTZI9tPyXvkODwIcxS8qwSWEIHxfLfSESzHqSuuVzXlqw(DSyzrrwifSaajbhXB4H)Gf1qFcejzb4956kutLhJrA1Wq2APOENrVvr1eaxTWidqay51BQJ4(NNoQTxfoHnr0y1xmSbpxL9o41fYwlf1BT6R50y1xmSbpxL9o41fYwlf1BdaxTqc40VDv2cAhBcy7nJ02JnMwaEFUUcnbybascMbrA0kOnaHkqO9YeGfaijy(3Xm1667PMgJ9ROe0PF7QSf0o2KoBpwQiganXoH1gbyVoqtbZbqQwmOolkAUk7vuTo9BxLTG2XEtaEFUUcnbybascMDQL2aeQaH2ltWZxfmng7xr3uJ8gAilJhfzb4790vkwSF)olaFuP8MfBzFZNfyZYBJMZcHAfyXlqwkilaFVvWgutSyFhlwkilaFVNUsXYrzzzXcSz5HSy1WaleILI6nl23XIfxhcazjLmglBLsisdBw(DKf0Bvuwielf1BwSAyGfaEFUUcz5OS89chXcSzXbT8)aGSqT7Dml7oLfnNaumqzPXy)QRiYcSz5OSCflt1rC)5n8WFWIAOpbIKS037PRuA6MrM(DfwVH(Os5DgSV5BWY1vi4Waf)SoSwuZFyBJMNjuRWiTr8UcR3qFVvWg0GLRRqqT6R50qFVNUszAC2iD31vO2i6vHtyten)fJ2HDLbB0J1VceBTP1xZPXQVyydEUk7DWRlKTwkQ3gaUAHBgPnACmTrOVMttWZxfmllTPb4956k04uRm4k2AyqFnNgsUcSrWmgBbTJDmwFglSjEPanlRHbaEFUUcnwnmKTwkQ3z0Bv0rddPdqay51Bkm0qfSb1(UcR3qFuP8od238ny56keuBAq4BCq36payMA374mOh7ertJX(v0n18Hbp8hSmoOB9hamtT7DCg0JDIO5Q8uDe3)rJgPnDacvGq7Lj45RcMgJ9ROBs(yddbiubcTxMaSaajbZ)oMPwxFp10ySFfDtYhBeVHgYITCfBrzzRucbl64e2ilKcwaGKGSSOxrKLFhzHuWcaKeKLaSaV)GflpKLWogiHLBYcPGfaijilhLfp8lxPIYIRdxplpKfDKLGtFEdp8hSOg6tGijl99MUAIOMUzKa8(CDfASAyiBTuuVZO3QO8gAilJhfzXwaclkl23XILOWflEJS46W1ZYdjR3ilb3Y6kISe29MiszXlqwIDsqwORgz53XOS4nYYvS4flAqqDwuKf6FkfltyZcH82cKL0ylWB4H)Gf1qFcejzl0EogclnDZiDRCyhdKOnDy3BIinsB02yy3BIy(VyKGACyiS7nrKgPThXB4H)Gf1qFcejz3D1mhdHLMUzKUvoSJbs0MoS7nrKgPnABmS7nrm)xmsqnome29MisJ02J0MwFnNgmOolkMvRYBtJX(v0nrcJH1J5)IXHb91CAWG6SOyMcvEBAm2VIUjsymSEm)xmoI3Wd)blQH(eisYoxkvogclnDZiDRCyhdKOnDy3BIinsB02yy3BIy(VyKGACyiS7nrKgPThPnT(AonyqDwumRwL3MgJ9ROBIegdRhZ)fJdd6R50Gb1zrXmfQ820ySFfDtKWyy9y(VyCeVHgYY4rrwa(EtxnrKfBXc)DwSAyGYIxGSaUITyzRucbl23XIfsTvYo(vqtSObXwq7yZY4GfOMy53rwsPI1VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsje8gE4pyrn0Narsw67nD1ernDZiXG6SOO5QSxr1MwFnNgyH)onhuO3zah9GLzznmOVMtdjxb2iygJTG2XogRpJf2eVuGML1WG(AonbpFvWSS0MoIaeawE9gsI2NxddbiubcTxgm2cAh7SoSanng7xr3uJdd6R50e88vbtJX(vucsmaAIDcNQPcc70o9BxLTG2XM0bW7Z1vOHsZbi9hnsB6icqay51BaG1VhThg0xZPPDaybx08SXkfrnng7xrjiXaOj2jCQc4PsN2PF7QSf0o2eGqhlvVRW6nZvhndNzuTk0GLRRqWrKoaEFUUcnuAoaP)icy7u9UcR3uO9CmewgSCDfcQnIEv4e2erd9Q5sL3JsFSpxR(AonTdal4IMNnwPiQzznmOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95ML1WqA91CAAhawWfnpBSsrutJX(vuc6H)GLH(EpVgniHXW6X8FXOwQfQu5DN(ibhZqOdd6R500oaSGlAE2yLIOMgJ9ROe0d)blJ92)DdsymSEm)xmomaW7Z1vO5SvWCawG3FWsBacvGq7L5kAOxVRRWSTU86xXzqeWfqtJoyuTOTUolle0Cfn0R31vy2wxE9R4mic4c4iT6R500oaSGlAE2yLIOML1Wqe6R500oaSGlAE2yLIOMLL2icqOceAVmTdal4IMNnwPiQPrhm6OHbaEFUUcno1kdUITgg0HuQ25rC)Zng7xrjiXaOj2jCQc4Ps70VDv2cAhBshaVpxxHgknhG0F0iEdnKLu3rz5HSe7KGS87il6i9zbozb47Tc2GSOhLf67bsUIil3ZYYIfBDDbsurz5kw8kklAqqDwuKf91ZcHyPOEZYrRTFwCD46z5HSOJSy1Wqab5n8WFWIAOpbIKS03B6QjIA6Mr(UcR3qFVvWg0GLRRqqTr0RcNWMiA(lgTd7kd2OhRFfi2AtRVMtd99wbBqZYAyWPF7QSf0o2BMsgBKw91CAOV3kydAOVhiHG2wBA91CAWG6SOyMcvEBwwdd6R50Gb1zrXSAvEBwwJ0QVMtJvFXWg8Cv27GxxiBTuuVnaC1cjOnK2X0MoaHkqO9Ye88vbtJX(v0njFSHHia4956k0eGfaijygePrRG2aeawE9M6iU)5PJJ4n0qw0a6FX(Juw2H2zjEf2zzRucblEJSq0VcbzXcBwOyawGgwSflvuwENeKYIZcTCl6o8zzcBw(DKLWQBSEwO3V8)Gfluil2HlfyT9ZIoYIhcR2FKLjSzr5nrSz5VyC2Ems5n8WFWIAOpbIKSa8(CDfQPYJXiDQfHaBGyqtaC1cJedQZIIMRYQv5DQ0CsNh(dwg6798A0GegdRhZ)fJeicmOolkAUkRwL3PknPNaVRW6nu4sLHZ8VJ5jSr6BWY1viyQS9isNh(dwg7T)7gKWyy9y(VyKaJziuns6OwOsL3D6JeymJgt17kSEt5)QrAw3vEfqdwUUcb5n0qwSLRylwa(EtxnrKLRyXlw0GG6SOiloLfkewS4uwSGu6PRqwCklkyrKfNYsu4If7NsXcwGSSSyX(97SO5JrawSVJfly9yFfrw(DKLcj8ZIgeuNff1elGWA7Nff(SCplwnmWcHyPOERjwaH12plqayBVVhzXlwSfl83zXQHbw8cKfliuXIooHnYcP2kzh)kWIxGSObXwq7yZY4GfiVHh(dwud9jqKKL(Etxnrut3mYi6vHtyten)fJ2HDLbB0J1VceBTP1xZPXQVyydEUk7DWRlKTwkQ3gaUAHe0gs7ydd6R50y1xmSbpxL9o41fYwlf1BdaxTqcAJght77kSEd9rLY7myFZ3GLRRqWrAtJb1zrrZvzku5TwN(TRYwq7ytaaEFUUcno1IqGnqmKk91CAWG6SOyMcvEBAm2VIsaq4BMRoAgoZOAvO5Vaj0CJX(vPYgJg3uZhByadQZIIMRYQv5TwN(TRYwq7ytaaEFUUcno1IqGnqmKk91CAWG6SOywTkVnng7xrjai8nZvhndNzuTk08xGeAUXy)QuzJrJBMsgBK2i0xZPbw4VtZwyhqR)GLzzPnI3vy9g67Tc2GgSCDfcQnDacvGq7Lj45RcMgJ9ROBsAhgOWLs)kqZV3NsLPisc2gSCDfcQvFnNMFVpLktrKeSn03dKqqBBBnlDVkCcBIOHE1CPY7rPp2NNkBgPDEe3)CJX(v0njFSX0opI7FUXy)kkbTzSXgga71bAkyoashPnDebiaS86nKeTpVggcqOceAVmySf0o2zDybAAm2VIUPnJ4n0qwgpkYITaewuwUIfVIYIgeuNffzXlqwOoaKfc5D1KaKMLsXITaewSmHnlKARKD8RalEbYskTRaBeKfni2cAh7ySEdlBvrHSSOilBXwGfVazH0ylWI)S87ilybYcCYcPPXkfrzXlqwaH12plk8zXw2OhRFfi2SmDLIf4CYB4H)Gf1qFcejzl0EogclnDZiDRCyhdKOfG3NRRqd1bG5jSZbpFvqBA91CAWG6SOywTkVnng7xr3ejmgwpM)lghg0xZPbdQZIIzku5TPXy)k6MiHXW6X8FX4iEdp8hSOg6tGij7URM5yiS00nJ0TYHDmqIwaEFUUcnuhaMNWoh88vbTP1xZPbdQZIIz1Q820ySFfDtKWyy9y(VyCyqFnNgmOolkMPqL3MgJ9ROBIegdRhZ)fJJ0MwFnNMGNVkywwdd6R50y1xmSbpxL9o41fYwlf1BdaxTqcgPnKp2iTPJiabGLxVbaw)E0EyqFnNM2bGfCrZZgRue10ySFfLGP1OMztQ6vHtyten0RMlvEpk9X(8rA1xZPPDaybx08SXkfrnlRHHi0xZPPDaybx08SXkfrnlRrAthrVkCcBIO5Vy0oSRmyJES(vGypmGegdRhZ)fJeuFnNM)Ir7WUYGn6X6xbITPXy)k6Wqe6R508xmAh2vgSrpw)kqSnlRr8gE4pyrn0Nars25sPYXqyPPBgPBLd7yGeTa8(CDfAOoampHDo45RcAtRVMtdguNffZQv5TPXy)k6MiHXW6X8FX4WG(AonyqDwumtHkVnng7xr3ejmgwpM)lghPnT(AonbpFvWSSgg0xZPXQVyydEUk7DWRlKTwkQ3gaUAHemsBiFSrAthracalVEdjr7ZRHb91CAi5kWgbZySf0o2Xy9zSWM4Lc0SSgPnDebiaS86naW63J2dd6R500oaSGlAE2yLIOMgJ9ROeuJA1xZPPDaybx08SXkfrnllTr0RcNWMiAOxnxQ8Eu6J95ddrOVMtt7aWcUO5zJvkIAwwJ0MoIEv4e2erZFXODyxzWg9y9RaXEyajmgwpM)lgjO(Aon)fJ2HDLbB0J1VceBtJX(v0HHi0xZP5Vy0oSRmyJES(vGyBwwJ4n0qwgpkYcHeudybwSea5n8WFWIAOpbIKS29UpyNHZmQwfYBOHSmEuKfGV3ZRrwEilwnmWcqOYBw0GG6SOOMyHuBLSJFfyz3PSOqkLL)Irw(DVyXzHqQ9FNfKWyy9ilkC(SaBwGLkklK5Q8MfniOolkYYrzzzzyHq6(DwsTnAol2yfybRhBwCwacvEZIgeuNffz5MSqiwkQ3Sq)tPyz3PSOqkLLF3lwSH8XyH(EGeklEbYcP2kzh)kWIxGSqkybascYYUdazjg2il)UxSqoPLYcPSLS0ySF1venSmEuKfxhcazXgnogPJLDN(ilGR(kISqAASsruw8cKfBSXgshl7o9rwSF)oC9SqAASsruEdp8hSOg6tGijl99EEnQPBgjguNffnxLvRYBTrOVMtt7aWcUO5zJvkIAwwddyqDwu0qHkVZfs4FyinguNffnEfnxiH)Hb91CAcE(QGPXy)kkb9WFWYyV9F3GegdRhZ)fJA1xZPj45RcML1iTPJGIFwhwlQ5pSTrZZ2yfgg6vHtytenw9fdBWZvzVdEDHS1sr9wR(Aonw9fdBWZvzVdEDHS1sr92aWvlKG2q(yAdqOceAVmbpFvW0ySFfDtYjTAthracalVEtDe3)80XHHaeQaH2ltawaGKG5FhZuRRVNAAm2VIUj5K2rAthr7b08nuPggcqOceAVm6ytXMKRiAAm2VIUj5K2rJggWG6SOO5QSxr1MwFnNg7E3hSZWzgvRcnlRHbQfQu5DN(ibhZqOAuB6icqay51BaG1VhThgIqFnNM2bGfCrZZgRue1SSgnmeGaWYR3aaRFpARLAHkvE3PpsWXme6iEdnKLXJISqi1(VZc83X2(rrwSVFHDwoklxXcqOYBw0GG6SOOMyHuBLSJFfyb2S8qwSAyGfYCvEZIgeuNff5n8WFWIAOpbIKS2B)35n0qwinUs979I3Wd)blQH(eisY2Rk7H)GvwD0xtLhJroDL637vYN8jja]] )
    

end