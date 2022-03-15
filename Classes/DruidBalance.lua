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


    spec:RegisterPack( "Balance", 20220315, [[dmLa4fqiHWJif0LquKnrk9jLsnkrQtPqwLijVcbmlsrDlsrSlk(fIsdtHYXquTmkfpJsPMgcsxJuOTHOO(gIuACKI05ejkRtKiZdb6Ecr7tPO)jsuvnqrIQYbvkPfQqLhIizIukrxKuGnIifFebrLrIGOQtQqvTsLcVuKOkZerHBsPeStLs8tkLqdfbHJksurlfbr5PaAQIK6QkuLTksuPVIGiJfrQ2Ri(ROgmXHPAXKQhlyYaDzOnROpJqJwP60QSArIk8AeXSj52c1UL8BqdNsooLsA5s9CKMUQUUs2oaFNs14rqDEH06fjmFfSFuNqEsQtac6pMSfBgZgBgZ2KRrd5A6yJzBYta(rTWeGwEGeNiMaS8ymb44CLxbmbOLhvbDWKuNaKcxDataU)VfnLilz1DLxbutOxCWq8(9LU5GKDCUYRaQjaVysr2yqZ(hRs5FEkmsDx5vanpH)eG6Rt9JFLONae0Fmzl2mMn2mMTjxJgY10XgZgnnbOV(DyNae4ftQeG7hiiwj6jabrAib44CLxbKfBzVoqEdBbVd7SqUg1ml2mMn2WBWBqQDViI0uI3qtyzRGGiilaHkVzzCOhB4n0ewi1UxerqwEVjIF(MSeCksz5HSeIguy(9Mi(udVHMWcHmmgcabzzvfgqk17OSaW7Z1viLL0NbnAMfRgbKPV30vtezrt2KfRgbyOV30vtehz4n0ew2ka4bYIvJbN(xrKfcP2)DwUjl3VnLLFhzXEdlISObb1zrrdVHMWITGtcYcPGfaijil)oYcqRRVNYIZI6(xHSedBKLPcj8PRqwsFtwIcxSS7G12pl73ZY9SqV4L69cHlQkkl2VFNLXzlU1uZcbyHuOcP)5kw2Q6iwXy9AML73gKfkjN1idVHMWITGtcYsmK(SS98iU)5gJ9ROBZcnGL3hKYIBzPIYYdzrhsPSmpI7pLfyPIA4n0ewsDJ(ZsQHXilWjlJt57SmoLVZY4u(oloLfNfQfgoxXY3xrc(gEdnHfBrlSWML0NbnAMfcP2)DnZcHu7)UMzb4798ACelXoiYsmSrwAKEQdRNLhYc6T6WMLamw3FnH(E)gEdnHfsZryws5DfyJGSObXwq7yhJ1ZsyhdKWYe2SqkBjllQtenjavh9PjPobi0clStsDYwipj1jaXY1viyY4sa6H)Gvcq7T)7jabrAOpR)GvcqcrJbN(SydlesT)7S4filolaFVPRMiYcSybyQzX(97SSLJ4(ZcPXrw8cKLXb3AQzb2Sa89EEnYc83X2(rXeGH(ESppbyAwWG6SOOrTkVZfs4NLHbwWG6SOO5QmfQ8MLHbwWG6SOO5QSo83zzyGfmOolkA8kAUqc)SmIfTSy1iad5g7T)7SOLLiyXQragBm2B)3t(KTytsQtaILRRqWKXLa0d)bReG03751ycWqFp2NNamnlrWsVkCcBIOr3vEfWmCMDLk)7xrKAWY1viilddSeblbiaS86n1rC)ZthzzyGLiyHAHkv(9Mi(ud99E6kflrYc5SmmWseS8UcR3u(VAKM1DLxb0GLRRqqwgXIwwIGfk(zDyTOM)W2gnnBJvGLHbwsZcguNffnuOY7CHe(zzyGfmOolkAUkRwL3SmmWcguNffnxL1H)olddSGb1zrrJxrZfs4NLrjavxH5aycqnM8jBX2jPobiwUUcbtgxcqp8hSsasFVPRMiMam03J95jatZsVkCcBIOr3vEfWmCMDLk)7xrKAWY1viilAzjabGLxVPoI7FE6ilAzHAHkv(9Mi(ud99E6kflrYc5SmIfTSeblu8Z6WArn)HTnAA2gRqcq1vyoaMauJjFYNaeeN(s9jPozlKNK6eGE4pyLaKcvEN1rpobiwUUcbtgxYNSfBssDcqSCDfcMmUeGH(ESppb4FXileKL0SydlPIfp8hSm2B)3nbN(5)IrwialE4pyzOV3ZRrtWPF(VyKLrjaPFFHpzlKNa0d)bReGbxPYE4pyLvh9taQo6NlpgtacTWc7Kpzl2oj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGuluPYV3eXNAOV3txPyztwiNfTSKMLiy5DfwVH(ERGnOblxxHGSmmWY7kSEd9rLY7myFZ3GLRRqqwgXYWaluluPYV3eXNAOV3txPyztwSjbiisd9z9hSsaceFklBfQbSalwSnbyX(97W1ZcyFZNfVazX(97Sa89wbBqw8cKfBialWFhB7hftacW7C5XycWJMDiM8jBHqtsDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbi1cvQ87nr8Pg6798AKLnzH8eGGin0N1FWkbiq8PSeuOdazX(owSa89EEnYsWlw2VNfBialV3eXNYI99lSZYrzPrfcWRNLjSz53rw0GG6SOilpKfDKfRgNy3iilEbYI99lSZY8ukSz5HSeC6NaeG35YJXeGhnhuOdat(KTOXKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctaA1iGmXaOHCtmewZRrwggyXQrazIbqd5g6QMxJSmmWIvJaYedGgYn03B6QjISmmWIvJaYedGgYn037PRuSmmWIvJaYedGgYnZvhndNzuTkKLHbwSAeGPDaybx08SXkfrzzyGf91CAcE(QGPXy)kklrYI(AonbpFvWaUA)pyXYWala8(CDfAoA2HycqqKg6Z6pyLamLR3NRRqw(D)zjSJbsOSCtwIcxS4nYYvS4SqmaYYdzXbapqw(DKf69l)pyXI9DSrwCw((ksWNf8dSCuwwueKLRyrhF7iwSeC6ttacW7C5XycWRYedGjFYwiZjPobiwUUcbtgxcqp8hSsaQJnfBsUIycqqKg6Z6pyLaC8OilJdBk2KCfrw8NLFhzblqwGtwinnwPikl23XILDN(ilhLfxhcazHmpgzsZS4ZhBwifSaajbzX(97SmoONAw8cKf4VJT9JISy)(Dwi1wj74xHeGH(ESppbyAwsZseSeGaWYR3uhX9ppDKLHbwIGLaeQaH2ltawaGKG5FhZuRRVNAwwSmmWseS0RcNWMiA0DLxbmdNzxPY)(vePgSCDfcYYiw0YI(AonbpFvW0ySFfLLnzHCnYIww0xZPPDaybx08SXkfrnng7xrzHGSqOSOLLiyjabGLxVbaw)E0MLHbwcqay51BaG1VhTzrll6R50e88vbZYIfTSOVMtt7aWcUO5zJvkIAwwSOLL0SOVMtt7aWcUO5zJvkIAAm2VIYcbJKfYTHfnHfcLLuXsVkCcBIOHE1CPY7rPp2NBWY1viilddSOVMttWZxfmng7xrzHGSqo5SmmWc5SqwwOwOsL3D6JSqqwi3qMzzelJyrlla8(CDfAUktmaM8jBH0MK6eGy56kemzCjad99yFEcW0SOVMttWZxfmng7xrzztwixJSOLL0Sebl9QWjSjIg6vZLkVhL(yFUblxxHGSmmWI(AonTdal4IMNnwPiQPXy)kkleKfYtzSOLf91CAAhawWfnpBSsruZYILrSmmWIoKszrllZJ4(NBm2VIYcbzXgnYYiw0YcaVpxxHMRYedGjabrAOpR)Gvcqcb8zX(97S4SqQTs2XVcS87(ZYrRTFwCwielf1BwSAyGfyZI9DSy53rwMhX9NLJYIRdxplpKfSata6H)Gvcql4FWk5t2IMMK6eGy56kemzCjaHwjaP4Na0d)bReGa8(CDfMaeGRwycWaEkwsZsAwMhX9p3ySFfLfnHfY1ilAclbiubcTxMGNVkyAm2VIYYiwillKRPJXYiw2KLaEkwsZsAwMhX9p3ySFfLfnHfY1ilAclbiubcTxMaSaajbZ)oMPwxFp10ySFfLLrSqwwixthJLrSOLLiyP9dmJaW6noii1Ge(OpLfTSKMLiyjaHkqO9Ye88vbtJoyuwggyjcwcqOceAVmbybascM)DmtTU(EQPrhmklJyzyGLaeQaH2ltWZxfmng7xrzztwU6X2cQ8hbZZJ4(NBm2VIYYWal9QWjSjIMaQq6FUktTU(EQblxxHGSOLLaeQaH2ltWZxfmng7xrzztwS9ySmmWsacvGq7LjalaqsW8VJzQ113tnng7xrzztwU6X2cQ8hbZZJ4(NBm2VIYIMWc5JXYWalrWsacalVEtDe3)80XeGGin0N1FWkbiPCvyP8hPSyFh)DSzzrVIilKcwaGKGSuq7Sy)ukwCLcANLOWflpKf6FkflbN(S87ilupgzXJHR6zbozHuWcaKeKaKARKD8RalbN(0eGa8oxEmMamalaqsWmisJwHKpzlPSKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctaMML3BI4B(lgZpmdEilBYc5AKLHbwA)aZiaSEJdcsnxXYMSOXXyzelAzjnlPzbT11zzHGgm2kAJUkdBWYRaYIwwsZseSeGaWYR3aaRFpAZYWalbiubcTxgm2kAJUkdBWYRaAAm2VIYcbzHCYmPLfcWsAw0ilPILEv4e2erd9Q5sL3JsFSp3GLRRqqwgXYiw0YseSeGqfi0EzWyROn6QmSblVcOPrhmklJyzyGf0wxNLfcAOWLsH)FfXCV0JYIwwsZseSeGaWYR3uhX9ppDKLHbwcqOceAVmu4sPW)VIyUx6rZ2Mq1OMog5MgJ9ROSqqwiNCcLLrSmmWsAwcqOceAVm6ytXMKRiAA0bJYYWalrWs7b08nuPyzyGLaeawE9M6iU)5PJSmIfTSKMLiy5DfwVzU6Oz4mJQvHgSCDfcYYWalbiaS86naW63J2SOLLaeQaH2lZC1rZWzgvRcnng7xrzHGSqo5Sqaw0ilPILEv4e2erd9Q5sL3JsFSp3GLRRqqwggyjcwcqay51BaG1VhTzrllbiubcTxM5QJMHZmQwfAAm2VIYcbzrFnNMGNVkyaxT)hSyHaSqUnSKkw6vHtytenw9fdBWZvzVdEDHS1sr92GLRRqqw0ewi3gwgXIwwsZcARRZYcbnxrd96DDfMT1Lx)kodIaUaYIwwcqOceAVmxrd96DDfMT1Lx)kodIaUaAAm2VIYcbzrJSmILHbwsZsAwqBDDwwiOHU7Gq7iyg26z4m)WogRNfTSeGqfi0EzEyhJ1JG5ROhX9pBBnQrBBd5MgJ9ROSmILHbwsZsAwa4956k0aR8II5VVIe8zjswiNLHbwa4956k0aR8II5VVIe8zjswSnlJyrllPz57RibFZtUPrhmAoaHkqO9ILHbw((ksW38KBcqOceAVmng7xrzztwU6X2cQ8hbZZJ4(NBm2VIYIMWc5JXYiwggybG3NRRqdSYlkM)(ksWNLizXgw0YsAw((ksW382yA0bJMdqOceAVyzyGLVVIe8nVnMaeQaH2ltJX(vuw2KLRESTGk)rW88iU)5gJ9ROSOjSq(ySmILHbwa4956k0aR8II5VVIe8zjswgJLrSmILrjabrAOpR)GvcWXJIGS8qwarLhLLFhzzrDIilWjlKARKD8Ral23XILf9kISacx6kKfyXYIIS4filwncaRNLf1jISyFhlw8IfheKfeawplhLfxhUEwEilGhMaeG35YJXeGbWCawG3FWk5t2c5JLK6eGy56kemzCjaHwjaP4Na0d)bReGa8(CDfMaeGRwycWiyHcxk9Ran)EFkvMIijyBWY1viilddSmpI7FUXy)kklBYInJnglddSOdPuw0YY8iU)5gJ9ROSqqwSrJSqawsZcHoglAcl6R50879PuzkIKGTH(EGewsfl2WYiwggyrFnNMFVpLktrKeSn03dKWYMSyBnLfnHL0S0RcNWMiAOxnxQ8Eu6J95gSCDfcYsQyXgwgLaeePH(S(dwjat56956kKLffbz5HSaIkpklEfLLVVIe8PS4filbqkl23XIf7(9xrKLjSzXlw0GL1oSpNfRggsacW7C5XycWFVpLktrKeSZ297t(KTqo5jPobiwUUcbtgxcqqKg6Z6pyLaC8OilAqSv0gDfl2Iny5vazXMXOyGYIooHnYIZcP2kzh)kWYIISaBwOqw(D)z5EwSFkflQRqwwwSy)(Dw(DKfSazbozH00yLIOjalpgtaIXwrB0vzydwEfWeGH(ESppbyacvGq7Lj45RcMgJ9ROSqqwSzmw0YsacvGq7LjalaqsW8VJzQ113tnng7xrzHGSyZySOLL0SaW7Z1vO537tPYuejb7SD)EwggyrFnNMFVpLktrKeSn03dKWYMSy7XyHaSKMLEv4e2erd9Q5sL3JsFSp3GLRRqqwsfl2MLrSmIfTSaW7Z1vO5QmXailddSOdPuw0YY8iU)5gJ9ROSqqwSnPnbOh(dwjaXyROn6QmSblVcyYNSfYTjj1jaXY1viyY4sacI0qFw)bReGJhfzbiCPu4FfrwiKT0JYczMIbkl64e2ilolKARKD8RallkYcSzHcz539NL7zX(PuSOUczzzXI973z53rwWcKf4KfstJvkIMaS8ymbifUuk8)RiM7LE0eGH(ESppbyAwcqOceAVmbpFvW0ySFfLfcYczMfTSeblbiaS86naW63J2SOLLiyjabGLxVPoI7FE6ilddSeGaWYR3uhX9ppDKfTSeGqfi0EzcWcaKem)7yMAD99utJX(vuwiilKzw0YsAwa4956k0eGfaijygePrRalddSeGqfi0EzcE(QGPXy)kkleKfYmlJyzyGLaeawE9gay97rBw0YsAwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqw0YsacvGq7Lj45RcMgJ9ROSqqwiZSmmWI(AonTdal4IMNnwPiQPXy)kkleKfYhJfcWsAw0ilPIf0wxNLfcAUI(9k8WMMbpaxHzDuPyzelAzrFnNM2bGfCrZZgRue1SSyzelddSOdPuw0YY8iU)5gJ9ROSqqwSrJSmmWcARRZYcbnySv0gDvg2GLxbKfTSeGqfi0EzWyROn6QmSblVcOPXy)kklBYInJXYiw0YcaVpxxHMRYedGSOLLiybT11zzHGMROHE9UUcZ26YRFfNbraxazzyGLaeQaH2lZv0qVExxHzBD51VIZGiGlGMgJ9ROSSjl2mglddSOdPuw0YY8iU)5gJ9ROSqqwSzSeGE4pyLaKcxkf()veZ9spAYNSfYTDsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHja1xZPj45RcMgJ9ROSSjlKRrw0YsAwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyrFnNM2bGfCrZZgRue10ySFfLfcgjlKRrJgzHaSKMfBB0ilPIf91CA0vqiOArFZYILrSqawsZcHA0ilAcl22Orwsfl6R50ORGqq1I(MLflJyjvSG266SSqqZv0VxHh20m4b4kmRJkfleGfc1OrwsflPzbT11zzHGMFhZZRPFMEepflAzjaHkqO9Y87yEEn9Z0J4Pmng7xrzHGrYInJXYiw0YI(AonTdal4IMNnwPiQzzXYiwggyrhsPSOLL5rC)Zng7xrzHGSyJgzzyGf0wxNLfcAWyROn6QmSblVcilAzjaHkqO9YGXwrB0vzydwEfqtJX(v0eGGin0N1FWkb4wv29OuwwuKLXpLtBjl2VFNfsTvYo(vGfyZI)S87ilybYcCYcPPXkfrtacW7C5XycWZwbZbybE)bRKpzlKtOjPobiwUUcbtgxcqp8hSsaEfn0R31vy2wxE9R4mic4cycWqFp2NNaeG3NRRqZzRG5aSaV)GflAzbG3NRRqZvzIbWeGLhJjaVIg6176kmBRlV(vCgebCbm5t2c5Amj1jaXY1viyY4sacI0qFw)bReGJhfzb4UdcTJGSyl26SOJtyJSqQTs2XVcjalpgtas3DqODemdB9mCMFyhJ1Nam03J95jatZsacvGq7Lj45RcMgDWOSOLLiyjabGLxVPoI7FE6ilAzbG3NRRqZV3NsLPisc2z7(9SOLL0SeGqfi0Ez0XMInjxr00OdgLLHbwIGL2dO5BOsXYiwggyjabGLxVPoI7FE6ilAzjaHkqO9YeGfaijy(3Xm1667PMgDWOSOLL0SaW7Z1vOjalaqsWmisJwbwggyjaHkqO9Ye88vbtJoyuwgXYiw0Yci8n0vnVgn)fi5kISOLL0SacFd9rLY78u5nA(lqYvezzyGLiy5DfwVH(Os5DEQ8gny56keKLHbwOwOsLFVjIp1qFVNxJSSjl2MLrSOLfq4BIHWAEnA(lqYvezrllPzbG3NRRqZrZoezzyGLEv4e2erJUR8kGz4m7kv(3VIi1GLRRqqwggyXPF7QSf0o2SSzKSKYgJLHbwa4956k0eGfaijygePrRalddSOVMtJUccbvl6BwwSmIfTSeblOTUolle0Cfn0R31vy2wxE9R4mic4cilddSG266SSqqZv0qVExxHzBD51VIZGiGlGSOLLaeQaH2lZv0qVExxHzBD51VIZGiGlGMgJ9ROSSjl2Emw0YseSOVMttWZxfmllwggyrhsPSOLL5rC)Zng7xrzHGSqOJLa0d)bReG0DheAhbZWwpdN5h2Xy9jFYwiNmNK6eGy56kemzCjabrAOpR)GvcWuVFuwoklolT)7yZcQCDy7pYIDpklpKLyNeKfxPybwSSOil03Fw((ksWNYYdzrhzrDfcYYYIf73VZcP2kzh)kWIxGSqkybascYIxGSSOil)oYInfiluf8zbwSeaz5MSOd)Dw((ksWNYI3ilWILffzH((ZY3xrc(0eGH(ESppbyAwa4956k0aR8II5VVIe8zjIizHCw0YseS89vKGV5TX0OdgnhGqfi0EXYWalPzbG3NRRqdSYlkM)(ksWNLizHCwggybG3NRRqdSYlkM)(ksWNLizX2SmIfTSKMf91CAcE(QGzzXIwwsZseSeGaWYR3aaRFpAZYWal6R500oaSGlAE2yLIOMgJ9ROSqawsZITnAKLuXsVkCcBIOHE1CPY7rPp2NBWY1viilJyHGrYY3xrc(MNCJ(AoZGR2)dwSOLf91CAAhawWfnpBSsruZYILHbw0xZPPDaybx08SXkfrZ0RMlvEpk9X(CZYILrSmmWsacvGq7Lj45RcMgJ9ROSqawSHLnz57RibFZtUjaHkqO9YaUA)pyXIwwIGf91CAcE(QGzzXIwwsZseSeGaWYR3uhX9ppDKLHbwIGfaEFUUcnbybascMbrA0kWYiw0YseSeGaWYR3qs0(8ILHbwcqay51BQJ4(NNoYIwwa4956k0eGfaijygePrRalAzjaHkqO9YeGfaijy(3Xm1667PMLflAzjcwcqOceAVmbpFvWSSyrllPzjnl6R50Gb1zrXSAvEBAm2VIYYMSq(ySmmWI(AonyqDwumtHkVnng7xrzztwiFmwgXIwwIGLEv4e2erJUR8kGz4m7kv(3VIi1GLRRqqwggyjnl6R50O7kVcygoZUsL)9RisZL)Rgn03dKWsKSOrwggyrFnNgDx5vaZWz2vQ8VFfrA27GxOH(EGewIKfnLLrSmILHbw0xZPHKRaBemJXwq7yhJ1NXcBIxkqZYILrSmmWIoKszrllZJ4(NBm2VIYcbzXMXyzyGfaEFUUcnWkVOy(7RibFwIKLXyzelAzbG3NRRqZvzIbWeGuf8Pja)(ksWN8eGE4pyLa87RibFYt(KTqoPnj1jaXY1viyY4sa6H)GvcWVVIe8TjbyOVh7ZtaMMfaEFUUcnWkVOy(7RibFwIiswSHfTSeblFFfj4BEYnn6GrZbiubcTxSmmWcaVpxxHgyLxum)9vKGplrYInSOLL0SOVMttWZxfmllw0YsAwIGLaeawE9gay97rBwggyrFnNM2bGfCrZZgRue10ySFfLfcWsAwSTrJSKkw6vHtyten0RMlvEpk9X(CdwUUcbzzelemsw((ksW382y0xZzgC1(FWIfTSOVMtt7aWcUO5zJvkIAwwSmmWI(AonTdal4IMNnwPiAME1CPY7rPp2NBwwSmILHbwcqOceAVmbpFvW0ySFfLfcWInSSjlFFfj4BEBmbiubcTxgWv7)blw0YseSOVMttWZxfmllw0YsAwIGLaeawE9M6iU)5PJSmmWseSaW7Z1vOjalaqsWmisJwbwgXIwwIGLaeawE9gsI2NxSOLL0Sebl6R50e88vbZYILHbwIGLaeawE9gay97rBwgXYWalbiaS86n1rC)Zthzrlla8(CDfAcWcaKemdI0OvGfTSeGqfi0EzcWcaKem)7yMAD99uZYIfTSeblbiubcTxMGNVkywwSOLL0SKMf91CAWG6SOywTkVnng7xrzztwiFmwggyrFnNgmOolkMPqL3MgJ9ROSSjlKpglJyrllrWsVkCcBIOr3vEfWmCMDLk)7xrKAWY1viilddSKMf91CA0DLxbmdNzxPY)(veP5Y)vJg67bsyjsw0ilddSOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqclrYIMYYiwgXYiwggyrFnNgsUcSrWmgBbTJDmwFglSjEPanllwggyrhsPSOLL5rC)Zng7xrzHGSyZySmmWcaVpxxHgyLxum)9vKGplrYYySmIfTSaW7Z1vO5QmXaycqQc(0eGFFfj4BtYNSfY10KuNaelxxHGjJlbiisd9z9hSsaoEuKYIRuSa)DSzbwSSOil3JXuwGflbWeGE4pyLaCrX89ymn5t2c5PSKuNaelxxHGjJlbiisd9z9hSsaQb3VJnleHSC1dz53rwOplWMfhIS4H)GflQJ(ja9WFWkbyVQSh(dwz1r)eG0VVWNSfYtag67X(8eGa8(CDfAoA2Hycq1r)C5XycqhIjFYwSzSKuNaelxxHGjJlbOh(dwja7vL9WFWkRo6NauD0pxEmMaK(jFYNa0QXamw3)KuNSfYtsDcqp8hSsasYvGncMPwxFpnbiwUUcbtgxYNSfBssDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmb4yjabrAOpR)GvcWuVJSaW7Z1vilhLfk(S8qwgJf73VZsbzH((ZcSyzrrw((ksWNQzwiNf77yXYVJSmVM(SalKLJYcSyzrrnZInSCtw(DKfkgGfilhLfVazX2SCtw0H)olEJjab4DU8ymbiSYlkM)(ksWp5t2ITtsDcqSCDfcMmUeGqReGoiycqp8hSsacW7Z1vycqaUAHjajpbyOVh7Zta(9vKGV5j3S708IIz91CYIww((ksW38KBcqOceAVmGR2)dwSOLLiy57RibFZtU5OMhgJz4mhdl63WfnhGf97v4pyrtacW7C5XycqyLxum)9vKGFYNSfcnj1jaXY1viyY4sacTsa6GGja9WFWkbiaVpxxHjab4QfMa0MeGH(ESppb43xrc(M3gZUtZlkM1xZjlAz57RibFZBJjaHkqO9YaUA)pyXIwwIGLVVIe8nVnMJAEymMHZCmSOFdx0Caw0VxH)GfnbiaVZLhJjaHvErX83xrc(jFYw0ysQtaILRRqWKXLaeALa0bbta6H)GvcqaEFUUctacW7C5XycqyLxum)9vKGFcWqFp2NNaeT11zzHGMROHE9UUcZ26YRFfNbraxazzyGf0wxNLfcAWyROn6QmSblVcilddSG266SSqqdfUuk8)RiM7LE0eGGin0N1FWkbyQ3rkYY3xrc(uw8gzPGpl(6HX(FbxPIYci(y4rqwCklWILffzH((ZY3xrc(udlSaeFwa4956kKLhYcHYItz53XOS4kkKLcrqwOwy4Cfl7EbQUIOjbiaxTWeGeAYNSfYCsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaT9ySKkwsZc5SOjSmMHCnYsQyHIFwhwlQ5pSTrtZeQvGLrjabrAOpR)GvcqG4tz53rwa(EtxnrKLaK(SmHnlk)XMLGRclL)hSOSKEcBwqc7XwkKf77yXYdzH(E)SaUITUIil64e2ilKMgRueLLPRuuwGZ5OeGa8oxEmMaKsZbi9t(KTqAtsDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbOghJLuXsAwiNfnHLXmKRrwsflu8Z6WArn)HTnAAMqTcSmkbiaVZLhJjaPZCas)KpzlAAsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaT9ySqawiFmwsfl9QWjSjIMaQq6FUktTU(EQblxxHGjabrAOpR)GvcqG4tzXFwSVFHDw8y4QEwGtw2kLqWcPGfaijil0D4sbYIoYYIIGPele6ySy)(D46zHuOcP)5kwaAD99uw8cKfBpgl2VF3KaeG35YJXeGbybascMDQvYNSLuwsQta6H)GvcWyiSi5Q8e2XjaXY1viyY4s(KTq(yjPobiwUUcbtgxcqp8hSsaAV9FpbyOVh7ZtaMMfmOolkAuRY7CHe(zzyGfmOolkAUktHkVzzyGfmOolkAUkRd)DwggybdQZIIgVIMlKWplJsaQUcZbWeGKpwYN8jaDiMK6KTqEsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHja7vHtyten)fJ2HDLbB0J1VceBdwUUcbzrllPzrFnNM)Ir7WUYGn6X6xbITPXy)kkleKfIbqtStywialJziNLHbw0xZP5Vy0oSRmyJES(vGyBAm2VIYcbzXd)bld99EEnAqcJH1J5)IrwialJziNfTSKMfmOolkAUkRwL3SmmWcguNffnuOY7CHe(zzyGfmOolkA8kAUqc)SmILrSOLf91CA(lgTd7kd2OhRFfi2MLvcqqKg6Z6pyLaKuUkSu(JuwSVJ)o2S87il2Yg94G)HDSzrFnNSy)ukwMUsXcCozX(97xXYVJSuiHFwco9tacW7C5XycqWg94S9tPYtxPYW5m5t2InjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMamcwWG6SOO5QmfQ8MfTSqTqLk)EteFQH(EpVgzztwiTSOjS8UcR3qHlvgoZ)oMNWgPVblxxHGSKkwSHfcWcguNffnxL1H)olAzjcw6vHtytenw9fdBWZvzVdEDHS1sr92GLRRqqw0YseS0RcNWMiAGf(70CqHENbC0dwgSCDfcMaeePH(S(dwjajLRclL)iLf774VJnlaFVPRMiYYrzXoS)Dwco9VIilqayZcW3751ilxXczSkVzrdcQZIIjab4DU8ymb4rSGnMPV30vtet(KTy7KuNaelxxHGjJlbOh(dwjadWcaKem)7yMAD990eGGin0N1FWkb44rrwifSaajbzX(owS4plkKsz539IfnoglBLsiyXlqwuxHSSSyX(97SqQTs2XVcjad99yFEcWiybSxhOPG5aiLfTSKML0SaW7Z1vOjalaqsWmisJwbw0YseSeGqfi0EzcE(QGPrhmklAzjcw6vHtytenw9fdBWZvzVdEDHS1sr92GLRRqqwggyrFnNMGNVkywwSOLL0Sebl9QWjSjIgR(IHn45QS3bVUq2APOEBWY1viilddS0RcNWMiAcOcP)5Qm1667PgSCDfcYYWalZJ4(NBm2VIYYMSqUnKwwggyrhsPSOLL5rC)Zng7xrzHGSeGqfi0EzcE(QGPXy)kkleGfYhJLHbw0xZPj45RcMgJ9ROSSjlKBdlJyzelAzjnlPzjnlo9BxLTG2XMfcgjla8(CDfAcWcaKem7ulwggyHAHkv(9Mi(ud99EEnYYMSyBwgXIwwsZI(AonyqDwumRwL3MgJ9ROSSjlKpglddSOVMtdguNffZuOYBtJX(vuw2KfYhJLrSmmWI(AonbpFvW0ySFfLLnzrJSOLf91CAcE(QGPXy)kklemswi3gwgXIwwsZseS8UcR3qFuP8od238ny56keKLHbw0xZPH(EpDLY0ySFfLfcYc5gnYIMWYygnYsQyPxfoHnr0eqfs)ZvzQ113tny56keKLHbw0xZPj45RcMgJ9ROSqqw0xZPH(EpDLY0ySFfLfcWIgzrll6R50e88vbZYILrSOLL0Sebl9QWjSjIM)Ir7WUYGn6X6xbITblxxHGSmmWseS0RcNWMiAcOcP)5Qm1667PgSCDfcYYWal6R508xmAh2vgSrpw)kqSnng7xrzztwqcJH1J5)IrwgXYWal9QWjSjIgDx5vaZWz2vQ8VFfrQblxxHGSmIfTSKMLiyPxfoHnr0O7kVcygoZUsL)9Risny56keKLHbwsZI(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajSejlAklddSOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqclrYIMYYiwgXYWal6qkLfTSmpI7FUXy)kkleKfYhJfTSeblbiubcTxMGNVkyA0bJYYOKpzleAsQtaILRRqWKXLa0d)bReG0vnVgtagIguy(9Mi(0KTqEcWqFp2NNamnlnoBKU76kKLHbw0xZPbdQZIIzku5TPXy)kkleKfBZIwwWG6SOO5QmfQ8MfTS0ySFfLfcYc5eklAz5DfwVHcxQmCM)DmpHnsFdwUUcbzzelAz59Mi(M)IX8dZGhYYMSqoHYIMWc1cvQ87nr8PSqawAm2VIYIwwsZcguNffnxL9kklddS0ySFfLfcYcXaOj2jmlJsacI0qFw)bReGJhfzb4QMxJSCflwEbIXxGfyXIxr)9RiYYV7plQdaszHCcLIbklEbYIcPuwSF)olXWgz59Mi(uw8cKf)z53rwWcKf4KfNfGqL3SObb1zrrw8NfYjuwOyGYcSzrHuklng7xDfrwCklpKLc(SS7aUIilpKLgNns3zbC1xrKfYyvEZIgeuNfft(KTOXKuNaelxxHGjJlbOh(dwjaPRAEnMaeePH(S(dwjahpkYcWvnVgz5HSS7aqwCwiQG6UILhYYIISm(PCAltag67X(8eGa8(CDfAoBfmhGf49hSyrllbiubcTxMROHE9UUcZ26YRFfNbraxann6GrzrllOTUolle0Cfn0R31vy2wxE9R4mic4cilAzXTYHDmqsYNSfYCsQtaILRRqWKXLa0d)bReG037PRujabrAOpR)GvcWuEiAXYYIfGV3txPyXFwCLIL)IrklRsHukll6vezHmIg82PS4fil3ZYrzX1HRNLhYIvddSaBwu4ZYVJSqTWW5kw8WFWIf1vil6OcANLDVavil2Yg9y9RaXMfyXInS8EteFAcWqFp2NNamcwExH1BOpQuENb7B(gSCDfcYIwwsZseSqXpRdRf18h22OPzc1kWYWalyqDwu0Cv2ROSmmWc1cvQ87nr8Pg6790vkw2KfBZYiw0YsAw0xZPH(EpDLY04Sr6URRqw0YsAwOwOsLFVjIp1qFVNUsXcbzX2SmmWseS0RcNWMiA(lgTd7kd2OhRFfi2gSCDfcYYiwggy5DfwVHcxQmCM)DmpHnsFdwUUcbzrll6R50Gb1zrXmfQ820ySFfLfcYITzrllyqDwu0CvMcvEZIww0xZPH(EpDLY0ySFfLfcYcPLfTSqTqLk)EteFQH(EpDLILnJKfcLLrSOLL0Sebl9QWjSjIgv0G3onpvi(xrmtuDXwu0GLRRqqwggy5VyKfYeleQgzztw0xZPH(EpDLY0ySFfLfcWInSmIfTS8EteFZFXy(HzWdzztw0yYNSfsBsQtaILRRqWKXLa0d)bReG037PRujabrAOpR)GvcqcP73zb4JkL3Syl7B(SSOilWILail23XILgNns3DDfYI(6zH(NsXID)EwMWMfYiAWBNYIvddS4filGWA7NLffzrhNWgzHu2sQHfG)PuSSOil64e2ilKcwaGKGSqVkGS87(ZI9tPyXQHbw8c(7yZcW37PRujad99yFEcW3vy9g6JkL3zW(MVblxxHGSOLf91CAOV3txPmnoBKU76kKfTSKMLiyHIFwhwlQ5pSTrtZeQvGLHbwWG6SOO5QSxrzzyGfQfQu53BI4tn037PRuSSjleklJyrllPzjcw6vHtytenQObVDAEQq8VIyMO6ITOOblxxHGSmmWYFXilKjwiunYYMSqOSmIfTS8EteFZFXy(HzWdzztwSDYNSfnnj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkbiH097SylB0J1VceBwwuKfGV3txPy5HSqcIwSSSy53rw0xZjl6rzXvuill6vezb4790vkwGflAKfkgGfiLfyZIcPuwAm2V6kIjad99yFEcWEv4e2erZFXODyxzWg9y9RaX2GLRRqqw0Yc1cvQ87nr8Pg6790vkw2mswSnlAzjnlrWI(Aon)fJ2HDLbB0J1VceBZYIfTSOVMtd99E6kLPXzJ0DxxHSmmWsAwa4956k0a2OhNTFkvE6kvgoNSOLL0SOVMtd99E6kLPXy)kkleKfBZYWaluluPYV3eXNAOV3txPyztwSHfTS8UcR3qFuP8od238ny56keKfTSOVMtd99E6kLPXy)kkleKfnYYiwgXYOKpzlPSKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1cta60VDv2cAhBw2KfnDmwsflPzHCw0ewO4N1H1IA(dBB00SnwbwsflJzSHLrSKkwsZc5SOjSOVMtZFXODyxzWg9y9RaX2qFpqclPILXmKZYiw0ewsZI(Aon037PRuMgJ9ROSKkwSnlKLfQfQu5DN(ilPILiy5DfwVH(Os5DgSV5BWY1viilJyrtyjnlbiubcTxg6790vktJX(vuwsfl2MfYYc1cvQ8UtFKLuXY7kSEd9rLY7myFZ3GLRRqqwgXIMWsAw0xZPzU6Oz4mJQvHMgJ9ROSKkw0ilJyrllPzrFnNg6790vkZYILHbwcqOceAVm037PRuMgJ9ROSmkbiisd9z9hSsaskxfwk)rkl23XFhBwCwa(EtxnrKLffzX(PuSe8ffzb4790vkwEiltxPyboNAMfVazzrrwa(EtxnrKLhYcjiAXITSrpw)kqSzH(EGewwwgw00Xy5OS87ilnARRRrqw2kLqWYdzj40NfGV30vtejaW37PRujab4DU8ymbi99E6kv2oS(80vQmCot(KTq(yjPobiwUUcbtgxcqp8hSsasFVPRMiMaeePH(S(dwjahpkYcW3B6QjISy)(DwSLn6X6xbInlpKfsq0ILLfl)oYI(AozX(97W1ZIcsVIilaFVNUsXYY6VyKfVazzrrwa(EtxnrKfyXcHsawghCRPMf67bsOSSQ)uSqOS8EteFAcWqFp2NNaeG3NRRqdyJEC2(Pu5PRuz4CYIwwa4956k0qFVNUsLTdRppDLkdNtw0YseSaW7Z1vO5iwWgZ03B6QjISmmWsAw0xZPr3vEfWmCMDLk)7xrKMl)xnAOVhiHLnzX2SmmWI(Aon6UYRaMHZSRu5F)kI0S3bVqd99ajSSjl2MLrSOLfQfQu53BI4tn037PRuSqqwiuw0YcaVpxxHg6790vQSDy95PRuz4CM8jBHCYtsDcqSCDfcMmUeGE4pyLa0bDR)aGzQDVJtagIguy(9Mi(0KTqEcWqFp2NNamcw(lqYvezrllrWIh(dwgh0T(daMP29ood6Xor0CvEQoI7plddSacFJd6w)baZu7EhNb9yNiAOVhiHfcYITzrllGW34GU1FaWm1U3Xzqp2jIMgJ9ROSqqwSDcqqKg6Z6pyLaC8Oilu7EhZcfYYV7plrHlwiIplXoHzzz9xmYIEuww0RiYY9S4uwu(JS4uwSGu6PRqwGflkKsz539IfBZc99ajuwGnlPCSOpl23XIfBtawOVhiHYcsyRRXKpzlKBtsQtaILRRqWKXLaeePH(S(dwjajKHZgP7SylaH18AKLBYcP2kzh)kWYrzPrhmQMz53XgzXBKffsPS87EXIgz59Mi(uwUIfYyvEZIgeuNffzX(97Sae(KgnZIcPuw(DVyH8Xyb(7yB)OilxXIxrzrdcQZIISaBwwwS8qw0ilV3eXNYIooHnYIZczSkVzrdcQZIIgwSLWA7NLgNns3zbC1xrKLuExb2iilAqSf0o2Xy9SSkfsPSCflaHkVzrdcQZIIja9WFWkbymewZRXeGH(ESppbOt)2vzlODSzztwa4956k0qN5aK(SOjSOVMtd99E6kLPXy)kklPIfYmlAzjnlUvoSJbsyzyGfaEFUUcnhXc2yM(EtxnrKLHbwIGfmOolkAUk7vuwgXIwwsZsacvGq7Lj45RcMgDWOSOLfmOolkAUk7vuw0YseSa2Rd0uWCaKYIwwsZcaVpxxHMaSaajbZGinAfyzyGLaeQaH2ltawaGKG5FhZuRRVNAA0bJYYWalrWsacalVEtDe3)80rwgXYWaluluPYV3eXNAOV3ZRrwiilPzjnlAklAclPzrFnNgmOolkMvRYBZYILuXITzzelJyjvSKMfYzHaS8UcR382VkhdHf1GLRRqqwgXYiw0YseSGb1zrrdfQ8oxiHFw0YsAwIGLaeQaH2ltWZxfmn6GrzzyGfWEDGMcMdGuwgXYWalPzbdQZIIMRYuOYBwggyrFnNgmOolkMvRYBZYIfTSeblVRW6nu4sLHZ8VJ5jSr6BWY1viilJyrllPzHAHkv(9Mi(ud99EEnYcbzH8XyjvSKMfYzHaS8UcR382VkhdHf1GLRRqqwgXYiwgXIwwsZseSeGaWYR3qs0(8ILHbwIGf91CAi5kWgbZySf0o2Xy9zSWM4Lc0SSyzyGfmOolkAUktHkVzzelAzjcw0xZPPDaybx08SXkfrZ0RMlvEpk9X(CZYkb47nr8Z3mbyJZgP7UUczrllV3eX38xmMFyg8qw2KL0SKMfYjuwialPzHAHkv(9Mi(ud99EEnYsQyXgwsfl6R50Gb1zrXSAvEBwwSmILrSqawAm2VIYYiwillPzHCwialVRW6nV9RYXqyrny56keKLrjFYwi32jPobiwUUcbtgxcqp8hSsaoHDaZWzU8F1ycqqKg6Z6pyLaC8OilKg4wybwSeazX(97W1ZsWTSUIycWqFp2NNa0TYHDmqclddSaW7Z1vO5iwWgZ03B6QjIjFYwiNqtsDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbyeSa2Rd0uWCaKYIwwsZcaVpxxHMayoalW7pyXIwwsZI(Aon037PRuMLflddS8UcR3qFuP8od238ny56keKLHbwcqay51BQJ4(NNoYYiw0Yci8nXqynVgn)fi5kISOLL0Sebl6R50qHk6Fb0SSyrllrWI(AonbpFvWSSyrllPzjcwExH1BMRoAgoZOAvOblxxHGSmmWI(AonbpFvWaUA)pyXYMSeGqfi0EzMRoAgoZOAvOPXy)kkleGfnLLrSOLL0Seblu8Z6WArn)HTnAA2gRalddSGb1zrrZvz1Q8MLHbwWG6SOOHcvENlKWplJyrlla8(CDfA(9(uQmfrsWoB3VNfTSKMLiyjabGLxVPoI7FE6ilddSaW7Z1vOjalaqsWmisJwbwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSqqwixJSmIfTS8EteFZFXy(HzWdzztw0xZPj45RcgWv7)blwsflJziTSmILHbw0HuklAzzEe3)CJX(vuwiil6R50e88vbd4Q9)GfleGfYTHLuXsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYYOeGa8oxEmMamaMdWc8(dwzhIjFYwixJjPobiwUUcbtgxcqp8hSsa2oaSGlAE2yLIOjabrAOpR)GvcWXJISqAASsruwSF)olKARKD8RqcWqFp2NNauFnNMGNVkyAm2VIYYMSqUgzzyGf91CAcE(QGbC1(FWIfcWc52WsQyPxfoHnr0y1xmSbpxL9o41fYwlf1BdwUUcbzHGSydzMfTSaW7Z1vOjaMdWc8(dwzhIjFYwiNmNK6eGy56kemzCja9WFWkbyavi9pxLD1rSIX6tacI0qFw)bReGJhfzHuBLSJFfybwSeazzvkKszXlqwuxHSCplllwSF)olKcwaGKGjad99yFEcqaEFUUcnbWCawG3FWk7qKfTSKMLiyjabGLxVbaw)E0MLHbwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyPxfoHnr0y1xmSbpxL9o41fYwlf1BdwUUcbzzyGf91CAcE(QGbC1(FWILnJKfBiZSmILHbw0xZPPDaybx08SXkfrnllw0YI(AonTdal4IMNnwPiQPXy)kkleKfY1OrJjFYwiN0MK6eGy56kemzCjad99yFEcqaEFUUcnbWCawG3FWk7qmbOh(dwjaVk4D5)bRKpzlKRPjPobiwUUcbtgxcqp8hSsaIXwq7yN1HfycqqKg6Z6pyLaC8OilAqSf0o2SmoybYcSyjaYI973zb4790vkwwwS4filuhaYYe2SqiwkQ3S4filKARKD8RqcWqFp2NNamnlbiubcTxMGNVkyAm2VIYcbyrFnNMGNVkyaxT)hSyHaS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSKkwi3gw2KLaeQaH2ldgBbTJDwhwGgWv7)blwialKpglJyzyGf91CAcE(QGPXy)kklBYIMYYWalG96anfmhaPjFYwipLLK6eGy56kemzCja9WFWkbi9rLY78u5nMamenOW87nr8PjBH8eGH(ESppbyJZgP7UUczrll)fJ5hMbpKLnzHCnYIwwOwOsLFVjIp1qFVNxJSqqwiuw0YIBLd7yGew0YsAw0xZPj45RcMgJ9ROSSjlKpglddSebl6R50e88vbZYILrjabrAOpR)Gvcqcz4Sr6oltL3ilWILLflpKfBZY7nr8PSy)(D46zHuBLSJFfyrhVIilUoC9S8qwqcBDnYIxGSuWNfiaSdUL1vet(KTyZyjPobiwUUcbtgxcqp8hSsaoxD0mCMr1QWeGGin0N1FWkb44rrwinqnGLBYYv0dezXlw0GG6SOilEbYI6kKL7zzzXI973zXzHqSuuVzXQHbw8cKLTc6w)bazbODVJtag67X(8eGyqDwu0Cv2ROSOLL0S4w5WogiHLHbwIGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLrSOLL0SOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGSyJghJLHbw0xZPj45RcMgJ9ROSSjlAklJyrllPzbe(gh0T(daMP29ood6Xor08xGKRiYYWalrWsacalVEtHHgQGnilddSqTqLk)EteFklBYInSmIfTSKMf91CAAhawWfnpBSsrutJX(vuwiilPmw0ewsZcHYsQyPxfoHnr0qVAUu59O0h7Zny56keKLrSOLf91CAAhawWfnpBSsruZYILHbwIGf91CAAhawWfnpBSsruZYILrSOLL0SeblbiubcTxMGNVkywwSmmWI(Aon)EFkvMIijyBOVhiHfcYc5AKfTSmpI7FUXy)kkleKfBgBmw0YY8iU)5gJ9ROSSjlKp2ySmmWseSqHlL(vGMFVpLktrKeSny56keKLrSOLL0SqHlL(vGMFVpLktrKeSny56keKLHbwcqOceAVmbpFvW0ySFfLLnzX2JXYiw0YY7nr8n)fJ5hMbpKLnzrJSmmWIoKszrllZJ4(NBm2VIYcbzH8Xs(KTyd5jPobiwUUcbtgxcqp8hSsasFVNUsLaeePH(S(dwjahpkYIZcW37PRuSylw4VZIvddSSkfsPSa89E6kflhLfx1OdgLLLflWMLOWflEJS46W1ZYdzbca7GBXYwPeIeGH(ESppbO(AonWc)DA2c7aA9hSmllw0YsAw0xZPH(EpDLY04Sr6URRqwggyXPF7QSf0o2SSjlPSXyzuYNSfBSjj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkbOTCfBXYwPecw0XjSrwifSaajbzX(97Sa89E6kflEbYYVJflaFVPRMiMam03J95jadqay51BQJ4(NNoYIwwIGL3vy9g6JkL3zW(MVblxxHGSOLL0SaW7Z1vOjalaqsWmisJwbwggyjaHkqO9Ye88vbZYILHbw0xZPj45RcMLflJyrllbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcYcXaOj2jmlPILaEkwsZIt)2vzlODSzHSSaW7Z1vOHoZbi9zzelAzrFnNg6790vktJX(vuwiileklAzjcwa71bAkyoast(KTyJTtsDcqSCDfcMmUeGH(ESppbyacalVEtDe3)80rw0YsAwa4956k0eGfaijygePrRalddSeGqfi0EzcE(QGzzXYWal6R50e88vbZYILrSOLLaeQaH2ltawaGKG5FhZuRRVNAAm2VIYcbzrJSOLfaEFUUcn037PRuz7W6ZtxPYW5KfTSGb1zrrZvzVIYIwwIGfaEFUUcnhXc2yM(EtxnrKfTSeblG96anfmhaPja9WFWkbi99MUAIyYNSfBi0KuNaelxxHGjJlbOh(dwjaPV30vtetacI0qFw)bReGJhfzb47nD1erwSF)olEXITyH)olwnmWcSz5MSefU2gKfiaSdUflBLsiyX(97SefUAwkKWplbN(gw2QIczbCfBXYwPecw8NLFhzblqwGtw(DKLuUy97rBw0xZjl3KfGV3txPyXoCPaRTFwMUsXcCozb2SefUyXBKfyXInS8EteFAcWqFp2NNauFnNgyH)onhuO3zah9GLzzXYWalPzjcwOV3ZRrJBLd7yGew0YseSaW7Z1vO5iwWgZ03B6QjISmmWsAw0xZPj45RcMgJ9ROSqqw0ilAzrFnNMGNVkywwSmmWsAwsZI(AonbpFvW0ySFfLfcYcXaOj2jmlPILaEkwsZIt)2vzlODSzHSSaW7Z1vOHsZbi9zzelAzrFnNMGNVkywwSmmWI(AonTdal4IMNnwPiAME1CPY7rPp2NBAm2VIYcbzHya0e7eMLuXsapflPzXPF7QSf0o2Sqwwa4956k0qP5aK(SmIfTSOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MLflJyrllbiaS86naW63J2SmILrSOLL0SqTqLk)EteFQH(EpDLIfcYITzzyGfaEFUUcn037PRuz7W6ZtxPYW5KLrSmIfTSebla8(CDfAoIfSXm99MUAIilAzjnlrWsVkCcBIO5Vy0oSRmyJES(vGyBWY1viilddSqTqLk)EteFQH(EpDLIfcYITzzuYNSfB0ysQtaILRRqWKXLa0d)bReGfAphdHvcqqKg6Z6pyLaC8Oil2cqyrz5kwacvEZIgeuNffzXlqwOoaKfsZsPyXwaclwMWMfsTvYo(vibyOVh7ZtaMMf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmmWsAwc7EtePSejl2WIwwAmS7nrm)xmYcbzrJSmILHbwc7EtePSejl2MLrSOLf3kh2XajjFYwSHmNK6eGy56kemzCjad99yFEcW0SOVMtdguNffZuOYBtJX(vuw2KfKWyy9y(VyKLHbwsZsy3BIiLLizXgw0YsJHDVjI5)IrwiilAKLrSmmWsy3BIiLLizX2SmIfTS4w5WogiHfTSKMf91CAAhawWfnpBSsrutJX(vuwiilAKfTSOVMtt7aWcUO5zJvkIAwwSOLLiyPxfoHnr0qVAUu59O0h7Zny56keKLHbwIGf91CAAhawWfnpBSsruZYILrja9WFWkb4URM5yiSs(KTydPnj1jaXY1viyY4sag67X(8eGPzrFnNgmOolkMPqL3MgJ9ROSSjliHXW6X8FXilAzjnlbiubcTxMGNVkyAm2VIYYMSOXXyzyGLaeQaH2ltawaGKG5FhZuRRVNAAm2VIYYMSOXXyzelddSKMLWU3erklrYInSOLLgd7EteZ)fJSqqw0ilJyzyGLWU3erklrYITzzelAzXTYHDmqclAzjnl6R500oaSGlAE2yLIOMgJ9ROSqqw0ilAzrFnNM2bGfCrZZgRue1SSyrllrWsVkCcBIOHE1CPY7rPp2NBWY1viilddSebl6R500oaSGlAE2yLIOMLflJsa6H)GvcW5sPYXqyL8jBXgnnj1jaXY1viyY4sacI0qFw)bReGJhfzHqcQbSalwiLTmbOh(dwjaT7DFWodNzuTkm5t2InPSKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctasTqLk)EteFQH(EpVgzztwiuwialtfe2SKMLyN(yhndWvlKLuXc5JnglKLfBgJLrSqawMkiSzjnl6R50qFVPRMiMXylODSJX6ZuOYBd99ajSqwwiuwgLaeePH(S(dwjajLRclL)iLf774VJnlpKLffzb4798AKLRybiu5nl23VWolhLf)zrJS8EteFkbiNLjSzbbGDuwSzmYelXo9XoklWMfcLfGV30vtezrdITG2XogRNf67bsOjab4DU8ymbi99EEnMVktHkVt(KTy7XssDcqSCDfcMmUeGqReGu8ta6H)GvcqaEFUUctacWvlmbi5SqwwOwOsL3D6JSqqwSHfnHL0SmMXgwsflPzHAHkv(9Mi(ud99EEnYIMWc5SmILuXsAwiNfcWY7kSEdfUuz4m)7yEcBK(gSCDfcYsQyHCJgzzelJyHaSmMHCnYsQyrFnNM2bGfCrZZgRue10ySFfnbiisd9z9hSsaskxfwk)rkl23XFhBwEilesT)7SaU6RiYcPPXkfrtacW7C5Xycq7T)75RYZgRuen5t2ITjpj1jaXY1viyY4sa6H)Gvcq7T)7jabrAOpR)GvcWXJISqi1(VZYvSaeQ8MfniOolkYcSz5MSuqwa(EpVgzX(PuSmVNLREilKARKD8RalEfng2ycWqFp2NNamnlyqDwu0OwL35cj8ZYWalyqDwu04v0CHe(zrlla8(CDfAoAoOqhaYYiw0YsAwEVjIV5Vym)Wm4HSSjleklddSGb1zrrJAvENVkBdlddSOdPuw0YY8iU)5gJ9ROSqqwiFmwgXYWal6R50Gb1zrXmfQ820ySFfLfcYIh(dwg6798A0GegdRhZ)fJSOLf91CAWG6SOyMcvEBwwSmmWcguNffnxLPqL3SOLLiybG3NRRqd99EEnMVktHkVzzyGf91CAcE(QGPXy)kkleKfp8hSm03751ObjmgwpM)lgzrllrWcaVpxxHMJMdk0bGSOLf91CAcE(QGPXy)kkleKfKWyy9y(VyKfTSOVMttWZxfmllwggyrFnNM2bGfCrZZgRue1SSyrlla8(CDfAS3(VNVkpBSsruwggyjcwa4956k0C0CqHoaKfTSOVMttWZxfmng7xrzztwqcJH1J5)IXKpzl22MKuNaelxxHGjJlbiisd9z9hSsaoEuKfGV3ZRrwUjlxXczSkVzrdcQZIIAMLRybiu5nlAqqDwuKfyXcHsawEVjIpLfyZYdzXQHbwacvEZIgeuNffta6H)Gvcq6798Am5t2ITTDsQtaILRRqWKXLaeePH(S(dwjajnUs979kbOh(dwja7vL9WFWkRo6NauD0pxEmMaC6k1V3RKp5taoDL637vsQt2c5jPobiwUUcbtgxcqp8hSsasFVPRMiMaeePH(S(dwjab(EtxnrKLjSzjgcaJX6zzvkKszzrVIilJdU1uNam03J95jaJGLEv4e2erJUR8kGz4m7kv(3VIi1G266SSqWKpzl2KK6eGy56kemzCja9WFWkbiDvZRXeGHObfMFVjIpnzlKNam03J95jabHVjgcR51OPXy)kklBYsJX(vuwsfl2ydlKLfY10eGGin0N1FWkbiPC6ZYVJSacFwSF)ol)oYsmK(S8xmYYdzXbbzzv)Py53rwIDcZc4Q9)GflhLL97nSaCvZRrwAm2VIYs8s9NL6qqwEilX(h2zjgcR51ilGR2)dwjFYwSDsQta6H)GvcWyiSMxJjaXY1viyY4s(Kpbi9tsDYwipj1jaXY1viyY4sa6H)Gvcqh0T(daMP29oobyiAqH53BI4tt2c5jad99yFEcWiybe(gh0T(daMP29ood6Xor08xGKRiYIwwIGfp8hSmoOB9hamtT7DCg0JDIO5Q8uDe3Fw0YsAwIGfq4BCq36payMA3748o6kZFbsUIilddSacFJd6w)baZu7EhN3rxzAm2VIYYMSOrwgXYWalGW34GU1FaWm1U3Xzqp2jIg67bsyHGSyBw0Yci8noOB9hamtT7DCg0JDIOPXy)kkleKfBZIwwaHVXbDR)aGzQDVJZGESten)fi5kIjabrAOpR)GvcWXJISSvq36pailaT7Dml23XILFhBKLJYsbzXd)bazHA37ynZItzr5pYItzXcsPNUczbwSqT7Dml2VFNfByb2Smr7yZc99ajuwGnlWIfNfBtawO29oMfkKLF3Fw(DKLcTZc1U3XS4DFaqklPCSOpl(8XMLF3FwO29oMfKWwxJ0Kpzl2KK6eGy56kemzCja9WFWkbi99MUAIycqqKg6Z6pyLaC8OilaFVPRMiYYdzHeeTyzzXYVJSylB0J1VceBw0xZjl3KL7zXoCPazbjS11il64e2ilZRo6(vez53rwkKWplbN(SaBwEilGRylw0XjSrwifSaajbtag67X(8eG9QWjSjIM)Ir7WUYGn6X6xbITblxxHGSOLL0SeblPzjnl6R508xmAh2vgSrpw)kqSnng7xrzztw8WFWYyV9F3GegdRhZ)fJSqawgZqolAzjnlyqDwu0Cvwh(7SmmWcguNffnxLPqL3SmmWcguNffnQv5DUqc)SmILHbw0xZP5Vy0oSRmyJES(vGyBAm2VIYYMS4H)GLH(EpVgniHXW6X8FXileGLXmKZIwwsZcguNffnxLvRYBwggybdQZIIgku5DUqc)SmmWcguNffnEfnxiHFwgXYiwggyjcw0xZP5Vy0oSRmyJES(vGyBwwSmILHbwsZI(AonbpFvWSSyzyGfaEFUUcnbybascMbrA0kWYiw0YsacvGq7LjalaqsW8VJzQ113tnn6GrzrllbiaS86n1rC)ZthzrllPzrFnNgmOolkMvRYBtJX(vuw2KfYhJLHbw0xZPbdQZIIzku5TPXy)kklBYc5JXYiwgXIwwsZseSeGaWYR3qs0(8ILHbwcqOceAVmySf0o2zDybAAm2VIYYMSOPSmk5t2ITtsDcqSCDfcMmUeGE4pyLaK(Etxnrmbiisd9z9hSsaAlxXwSa89MUAIiLf73VZY4CLxbKf4KLTQuSK69Riszb2S8qwSA0YBKLjSzHuWcaKeKf73VZY4GBn1jad99yFEcWEv4e2erJUR8kGz4m7kv(3VIi1GLRRqqw0YsAwsZI(Aon6UYRaMHZSRu5F)kI0C5)Qrd99ajSSjl2WYWal6R50O7kVcygoZUsL)9RisZEh8cn03dKWYMSydlJyrllbiubcTxMGNVkyAm2VIYYMSqAzrllrWsacvGq7LjalaqsW8VJzQ113tnllwggyjnlbiaS86n1rC)ZthzrllbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcYc5JXIwwWG6SOO5QSxrzrllo9BxLTG2XMLnzXMXyHaSy7XyjvSeGqfi0EzcE(QGPrhmklJyzuYNSfcnj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGPzrFnNM2bGfCrZZgRue10ySFfLLnzrJSmmWseSOVMtt7aWcUO5zJvkIAwwSmIfTSebl6R500oaSGlAE2yLIOz6vZLkVhL(yFUzzXIwwsZI(AonKCfyJGzm2cAh7yS(mwyt8sbAAm2VIYcbzHya0e7eMLrSOLL0SOVMtdguNffZuOYBtJX(vuw2KfIbqtStywggyrFnNgmOolkMvRYBtJX(vuw2KfIbqtStywggyjnlrWI(AonyqDwumRwL3MLflddSebl6R50Gb1zrXmfQ82SSyzelAzjcwExH1BOqf9VaAWY1viilJsacI0qFw)bReGKcwG3FWILjSzXvkwaHpLLF3FwIDsqkl0vJS87yuw8gRTFwAC2iDhbzX(owSqiZbGfCrzH00yLIOSS7uwuiLYYV7flAKfkgOS0ySF1vezb2S87ilAqSf0o2SmoybYI(Aoz5OS46W1ZYdzz6kflW5KfyZIxrzrdcQZIISCuwCD46z5HSGe26AmbiaVZLhJjabHFUrBDDngJ1tt(KTOXKuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctaMMLiyrFnNgmOolkMPqL3MLflAzjcw0xZPbdQZIIz1Q82SSyzelAzjcwExH1BOqf9VaAWY1viilAzjcw6vHtyten)fJ2HDLbB0J1VceBdwUUcbtacI0qFw)bReGKcwG3FWILF3Fwc7yGekl3KLOWflEJSaxp9arwWG6SOilpKfyPIYci8z53Xgzb2SCelyJS87hLf73VZcqOI(xatacW7C5Xycqq4NHRNEGygdQZIIjFYwiZjPobiwUUcbtgxcqp8hSsagdH18AmbyiAqH53BI4tt2c5jad99yFEcW0SOVMtdguNffZuOYBtJX(vuw2KLgJ9ROSmmWI(AonyqDwumRwL3MgJ9ROSSjlng7xrzzyGfaEFUUcnGWpdxp9aXmguNffzzelAzPXzJ0DxxHSOLL3BI4B(lgZpmdEilBYc52WIwwCRCyhdKWIwwa4956k0ac)CJ266AmgRNMaeePH(S(dwjaTLWNfxPy59Mi(uwSF)(vSqi8ceJVal2VFhUEwGaWo4wwxrKa)oYIRdbGSeGf49hSOjFYwiTjPobiwUUcbtgxcqp8hSsasx18AmbyOVh7ZtaMMf91CAWG6SOyMcvEBAm2VIYYMS0ySFfLLHbw0xZPbdQZIIz1Q820ySFfLLnzPXy)kklddSaW7Z1vObe(z46PhiMXG6SOilJyrllnoBKU76kKfTS8EteFZFXy(HzWdzztwi3gw0YIBLd7yGew0YcaVpxxHgq4NB0wxxJXy90eGHObfMFVjIpnzlKN8jBrttsDcqSCDfcMmUeGE4pyLaK(Os5DEQ8gtag67X(8eGPzrFnNgmOolkMPqL3MgJ9ROSSjlng7xrzzyGf91CAWG6SOywTkVnng7xrzztwAm2VIYYWala8(CDfAaHFgUE6bIzmOolkYYiw0YsJZgP7UUczrllV3eX38xmMFyg8qw2KfYjZSOLf3kh2XajSOLfaEFUUcnGWp3OTUUgJX6Pjadrdkm)EteFAYwip5t2sklj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGbiaS86naW63J2SOLLiyPxfoHnr0qVAUu59O0h7Zny56keKfTSebl9QWjSjIMW1bfMHZS6My2lWmi6)UblxxHGSOLLaeQaH2lJo2uSj5kIMgDWOSOLLaeQaH2lt7aWcUO5zJvkIAA0bJYIwwIGf91CAcE(QGzzXIwwsZIt)2vzlODSzztw0usllddSOVMtJUccbvl6BwwSmkbiisd9z9hSsaAlHpl9rC)zrhNWgzH00yLIOSCtwUNf7WLcKfxPG2zjkCXYdzPXzJ0DwuiLYc4QVIilKMgRueLL0)(rzbwQOSS7wwyrzX(97W1ZcWRMlfleYhL(yF(OeGa8oxEmMaSG59O0h7ZZO3QOzq4N8jBH8XssDcqSCDfcMmUeGH(ESppbiaVpxxHMcM3JsFSppJERIMbHplAzPXy)kkleKfBglbOh(dwjaJHWAEnM8jBHCYtsDcqSCDfcMmUeGH(ESppbiaVpxxHMcM3JsFSppJERIMbHplAzPXy)kkleKfYtzja9WFWkbiDvZRXKpzlKBtsQtaILRRqWKXLa0d)bReGtyhWmCMl)xnMaeePH(S(dwjahpkYcPbUfwGflbqwSF)oC9SeClRRiMam03J95jaDRCyhdKK8jBHCBNK6eGy56kemzCja9WFWkbigBbTJDwhwGjabrAOpR)GvcWXJISObXwq7yZY4Gfil2VFNfVIYIcwezbl4I4olkN(xrKfniOolkYIxGS8DuwEilQRqwUNLLfl2VFNfcXsr9MfVazHuBLSJFfsag67X(8eGPzjaHkqO9Ye88vbtJX(vuwial6R50e88vbd4Q9)GfleGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLuXc52WYMSeGqfi0EzWylODSZ6Wc0aUA)pyXcbyH8XyzelddSOVMttWZxfmng7xrzztw0uwggybSxhOPG5ain5t2c5eAsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjaD63UkBbTJnlBYskBmw0ewsZIngnYsQyrFnNM5QJMHZmQwfAOVhiHfnHfByjvSGb1zrrZvz1Q8MLrjabrAOpR)GvcqG4tzX(owSSvkHGf6oCPazrhzbCfBHGS8qwk4Zcea2b3IL02s0clqklWIfsZQJYcCYIgOwfYIxGS87ilAqqDwuCucqaENlpgta6uRm4k2k5t2c5Amj1jaXY1viyY4sacTsasXpbOh(dwjab4956kmbiaxTWeGrWcyVoqtbZbqklAzjnla8(CDfAcG5aSaV)GflAzjcw0xZPj45RcMLflAzjnlrWcf)SoSwuZFyBJMMTXkWYWalyqDwu0CvwTkVzzyGfmOolkAOqL35cj8ZYiw0YsAwsZsAwa4956k04uRm4k2ILHbwcqay51BQJ4(NNoYYWalPzjabGLxVHKO95flAzjaHkqO9YGXwq7yN1HfOPrhmklJyzyGLEv4e2erZFXODyxzWg9y9RaX2GLRRqqwgXIwwaHVHUQ51OPXy)kklBYIMYIwwaHVjgcR51OPXy)kklBYskJfTSKMfq4BOpQuENNkVrtJX(vuw2KfYhJLHbwIGL3vy9g6JkL35PYB0GLRRqqwgXIwwa4956k0879PuzkIKGD2UFplAz59Mi(M)IX8dZGhYYMSOVMttWZxfmGR2)dwSKkwgZqAzzyGf91CA0vqiOArFZYIfTSOVMtJUccbvl6BAm2VIYcbzrFnNMGNVkyaxT)hSyHaSKMfYTHLuXsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYYiwgXYWalPzbT11zzHGgm2kAJUkdBWYRaYIwwcqOceAVmySv0gDvg2GLxb00ySFfLfcYc5KzslleGL0SOrwsfl9QWjSjIg6vZLkVhL(yFUblxxHGSmILrSmIfTSKML0SeblbiaS86n1rC)ZthzzyGL0SaW7Z1vOjalaqsWmisJwbwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSqqwixJSmIfTSKMLiyPxfoHnr0O7kVcygoZUsL)9Risny56keKLHbwC63UkBbTJnleKfnoglAzjaHkqO9YeGfaijy(3Xm1667PMgDWOSmILrSmmWY8iU)5gJ9ROSqqwcqOceAVmbybascM)DmtTU(EQPXy)kklJyzyGfDiLYIwwMhX9p3ySFfLfcYI(AonbpFvWaUA)pyXcbyHCByjvS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSmkbiisd9z9hSsaoEuKfsTvYo(vGf73VZcPGfaijizt5DfyJGSa0667PS4filGWA7NfiaST33JSqiwkQ3SaBwSVJflJtbHGQf9zXoCPazbjS11il64e2ilKARKD8RaliHTUgPgwSfCsqwORgz5HSG1JnlolKXQ8MfniOolkYI9DSyzrpIflP2gnLfBScS4filUsXcPSLuwSFkfl6yagJS0OdgLfkewSGfCrCNfWvFfrw(DKf91CYIxGSacFkl7oaKfDelwOR58chwVkklnoBKUJGMeGa8oxEmMamaMdWc8(dwz6N8jBHCYCsQtaILRRqWKXLa0d)bReGTdal4IMNnwPiAcqqKg6Z6pyLaC8OilKMgRueLf73VZcP2kzh)kWYQuiLYcPPXkfrzXoCPazr50NffSiInl)UxSqQTs2XVcAMLFhlwwuKfDCcBmbyOVh7ZtaQVMttWZxfmng7xrzztwixJSmmWI(AonbpFvWaUA)pyXcbzXgslleGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKLuXc52WIwwa4956k0eaZbybE)bRm9t(KTqoPnj1jaXY1viyY4sag67X(8eGa8(CDfAcG5aSaV)GvM(SOLL0SOVMttWZxfmGR2)dwSSzKSydPLfcWsVkCcBIOXQVyydEUk7DWRlKTwkQ3gSCDfcYsQyHCByzyGLiyjabGLxVbaw)E0MLrSmmWI(AonTdal4IMNnwPiQzzXIww0xZPPDaybx08SXkfrnng7xrzHGSKYyHaSeGf46EJvJHJIzxDeRySEZFXygGRwileGL0Sebl6R50ORGqq1I(MLflAzjcwExH1BOV3kydAWY1viilJsa6H)GvcWaQq6FUk7QJyfJ1N8jBHCnnj1jaXY1viyY4sag67X(8eGa8(CDfAcG5aSaV)GvM(ja9WFWkb4vbVl)pyL8jBH8uwsQtaILRRqWKXLaeALaKIFcqp8hSsacW7Z1vycqaUAHjadqOceAVmbpFvW0ySFfLLnzH8XyzyGLiybG3NRRqtawaGKGzqKgTcSOLLaeawE9M6iU)5PJSmmWcyVoqtbZbqAcqqKg6Z6pyLamLR3NRRqwwueKfyXIRFQ7pKYYV7pl296z5HSOJSqDaiiltyZcP2kzh)kWcfYYV7pl)ogLfVX6zXUtFeKLuow0NfDCcBKLFhJtacW7C5XycqQdaZtyNdE(QqYNSfBglj1jaXY1viyY4sa6H)GvcW5QJMHZmQwfMaeePH(S(dwjahpkszH0a1awUjlxXIxSObb1zrrw8cKLVpKYYdzrDfYY9SSSyX(97SqiwkQ3AMfsTvYo(vqZSObXwq7yZY4GfilEbYYwbDR)aGSa0U3Xjad99yFEcqmOolkAUk7vuw0YsAwC63UkBbTJnleKLuMnSOjSOVMtZC1rZWzgvRcn03dKWsQyrJSmmWI(AonTdal4IMNnwPiQzzXYiw0YsAw0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqqwSHqhJLHbw0xZPj45RcMgJ9ROSSjlAklJyrlla8(CDfAOoampHDo45RcSOLL0SeblbiaS86nfgAOc2GSmmWci8noOB9hamtT7DCg0JDIO5VajxrKLrSOLL0SeblbiaS86naW63J2SmmWI(AonTdal4IMNnwPiQPXy)kkleKLuglAclPzHqzjvS0RcNWMiAOxnxQ8Eu6J95gSCDfcYYiw0YI(AonTdal4IMNnwPiQzzXYWalrWI(AonTdal4IMNnwPiQzzXYiw0YsAwIGLaeawE9gsI2NxSmmWsacvGq7LbJTG2XoRdlqtJX(vuw2KfBgJLrSOLL3BI4B(lgZpmdEilBYIgzzyGfDiLYIwwMhX9p3ySFfLfcYc5JL8jBXgYtsDcqSCDfcMmUeGE4pyLaK(EpDLkbiisd9z9hSsaoEuKfBXc)Dwa(EpDLIfRggOSCtwa(EpDLILJwB)SSSsag67X(8eG6R50al83PzlSdO1FWYSSyrll6R50qFVNUszAC2iD31vyYNSfBSjj1jaXY1viyY4sa6H)GvcWGxbuL1xZzcWqFp2NNauFnNg67Tc2GMgJ9ROSqqw0ilAzjnl6R50Gb1zrXmfQ820ySFfLLnzrJSmmWI(AonyqDwumRwL3MgJ9ROSSjlAKLrSOLfN(TRYwq7yZYMSKYglbO(AoZLhJjaPV3kydMaeePH(S(dwjajLxbuXcW3BfSbz5MSCpl7oLffsPS87EXIgPS0ySF1ve1mlrHlw8gzXFwszJraw2kLqWIxGS87ilHv3y9SObb1zrrw2DklAKauwAm2V6kIjFYwSX2jPobiwUUcbtgxcqp8hSsag8kGQS(Aotag67X(8eGVRW6nxf8U8)GLblxxHGSOLLiy5DfwVPq75yiSmy56keKfTSKYhlPzjnl2ESXyrtyXPF7QSf0o2Sqawi0XyrtyHIFwhwlQ5pSTrtZ2yfyjvSqOJXYiwillPzHqzHSSqTqLkV70hzzelAclbiubcTxMaSaajbZ)oMPwxFp10ySFfLLrSqqws5JL0SKMfBp2ySOjS40VDv2cAhBw0ew0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqawi0XyrtyHIFwhwlQ5pSTrtZ2yfyjvSqOJXYiwillPzHqzHSSqTqLkV70hzzelAclbiubcTxMaSaajbZ)oMPwxFp10ySFfLLrSOLLaeQaH2ltWZxfmng7xrzztwS9ySOLf91CAS6lg2GNRYEh86czRLI6TbGRwileKfBiFmw0YI(Aonw9fdBWZvzVdEDHS1sr92aWvlKLnzX2JXIwwcqOceAVmbybascM)DmtTU(EQPXy)kkleKfcDmw0YY8iU)5gJ9ROSSjlbiubcTxMaSaajbZ)oMPwxFp10ySFfLfcWczMfTSKMLEv4e2ertavi9pxLPwxFp1GLRRqqwggybG3NRRqtawaGKGzqKgTcSmkbO(AoZLhJjaT6lg2GNRYEh86czRLI6DcqqKg6Z6pyLaKuEfqfl)oYcHyPOEZI(Aoz5MS87ilwnmWID4sbwB)SOUczzzXI973z53rwkKWpl)fJSqkybascYsagJuwGZjlbqdlPE)OSSOlxPIYcSurzz3TSWIYc4QVIil)oYY4idtYNSfBi0KuNaelxxHGjJlbi0kbif)eGE4pyLaeG3NRRWeGaC1ctagGaWYR3uhX9ppDKfTS0RcNWMiAS6lg2GNRYEh86czRLI6TblxxHGSOLf91CAS6lg2GNRYEh86czRLI6TbGRwileGfN(TRYwq7yZcbyX2SSzKSy7XgJfTSaW7Z1vOjalaqsWmisJwbw0YsacvGq7LjalaqsW8VJzQ113tnng7xrzHGS40VDv2cAhBwill2EmwsfledGMyNWSOLLiybSxhOPG5aiLfTSGb1zrrZvzVIYIwwC63UkBbTJnlBYcaVpxxHMaSaajbZo1IfTSeGqfi0EzcE(QGPXy)kklBYIgtacI0qFw)bReGaXNYI9DSyHqSuuVzHUdxkqw0rwSAyiGGSGERIYYdzrhzX1vilpKLffzHuWcaKeKfyXsacvGq7flP1akfR)CLkkl6yagJuw(EHSCtwaxXwxrKLTsjeSuq7Sy)ukwCLcANLOWflpKflSNy4vrzbRhBwielf1Bw8cKLFhlwwuKfsblaqsWrjab4DU8ymbOvddzRLI6Dg9wfn5t2InAmj1jaXY1viyY4sa6H)Gvcq6790vQeGGin0N1FWkb44rrwa(EpDLIf73VZcWhvkVzXw238zb2S82OPSqOwbw8cKLcYcW3BfSb1ml23XILcYcW37PRuSCuwwwSaBwEilwnmWcHyPOEZI9DSyX1HaqwszJXYwPeI0WMLFhzb9wfLfcXsr9MfRggybG3NRRqwoklFVWrSaBwCql)pailu7EhZYUtzrtjafduwAm2V6kISaBwoklxXYuDe3)eGH(ESppbyAwExH1BOpQuENb7B(gSCDfcYYWalu8Z6WArn)HTnAAMqTcSmIfTSeblVRW6n03BfSbny56keKfTSOVMtd99E6kLPXzJ0DxxHSOLLiyPxfoHnr08xmAh2vgSrpw)kqSny56keKfTSKMf91CAS6lg2GNRYEh86czRLI6TbGRwilBgjl2OXXyrllrWI(AonbpFvWSSyrllPzbG3NRRqJtTYGRylwggyrFnNgsUcSrWmgBbTJDmwFglSjEPanllwggybG3NRRqJvddzRLI6Dg9wfLLrSmmWsAwcqay51Bkm0qfSbzrllVRW6n0hvkVZG9nFdwUUcbzrllPzbe(gh0T(daMP29ood6Xor00ySFfLLnzrtzzyGfp8hSmoOB9hamtT7DCg0JDIO5Q8uDe3FwgXYiwgXIwwsZsacvGq7Lj45RcMgJ9ROSSjlKpglddSeGqfi0EzcWcaKem)7yMAD99utJX(vuw2KfYhJLrjFYwSHmNK6eGy56kemzCja9WFWkbi99MUAIycqqKg6Z6pyLa0wUITOSSvkHGfDCcBKfsblaqsqww0RiYYVJSqkybascYsawG3FWILhYsyhdKWYnzHuWcaKeKLJYIh(LRurzX1HRNLhYIoYsWPFcWqFp2NNaeG3NRRqJvddzRLI6Dg9wfn5t2InK2KuNaelxxHGjJlbOh(dwjal0EogcReGGin0N1FWkb44rrwSfGWIYI9DSyjkCXI3ilUoC9S8qY6nYsWTSUIilHDVjIuw8cKLyNeKf6Qrw(DmklEJSCflEXIgeuNffzH(NsXYe2SqiVTazjn2cjad99yFEcq3kh2XajSOLL0Se29MiszjswSHfTS0yy3BIy(VyKfcYIgzzyGLWU3erklrYITzzuYNSfB00KuNaelxxHGjJlbyOVh7Zta6w5WogiHfTSKMLWU3erklrYInSOLLgd7EteZ)fJSqqw0ilddSe29MiszjswSnlJyrllPzrFnNgmOolkMvRYBtJX(vuw2KfKWyy9y(VyKLHbw0xZPbdQZIIzku5TPXy)kklBYcsymSEm)xmYYOeGE4pyLaC3vZCmewjFYwSjLLK6eGy56kemzCjad99yFEcq3kh2XajSOLL0Se29MiszjswSHfTS0yy3BIy(VyKfcYIgzzyGLWU3erklrYITzzelAzjnl6R50Gb1zrXSAvEBAm2VIYYMSGegdRhZ)fJSmmWI(AonyqDwumtHkVnng7xrzztwqcJH1J5)IrwgLa0d)bReGZLsLJHWk5t2IThlj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkb44rrwa(EtxnrKfBXc)DwSAyGYIxGSaUITyzRucbl23XIfsTvYo(vqZSObXwq7yZY4GfOMz53rws5I1VhTzrFnNSCuwCD46z5HSmDLIf4CYcSzjkCTnilb3ILTsjejad99yFEcqmOolkAUk7vuw0YsAw0xZPbw4VtZbf6DgWrpyzwwSmmWI(AonKCfyJGzm2cAh7yS(mwyt8sbAwwSmmWI(AonbpFvWSSyrllPzjcwcqay51BijAFEXYWalbiubcTxgm2cAh7SoSanng7xrzztw0ilddSOVMttWZxfmng7xrzHGSqmaAIDcZsQyzQGWML0S40VDv2cAhBwilla8(CDfAO0CasFwgXYiw0YsAwIGLaeawE9gay97rBwggyrFnNM2bGfCrZZgRue10ySFfLfcYcXaOj2jmlPILaEkwsZsAwC63UkBbTJnleGfcDmwsflVRW6nZvhndNzuTk0GLRRqqwgXczzbG3NRRqdLMdq6ZYiwial2MLuXY7kSEtH2ZXqyzWY1viilAzjcw6vHtyten0RMlvEpk9X(CdwUUcbzrll6R500oaSGlAE2yLIOMLflddSOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MLflddSKMf91CAAhawWfnpBSsrutJX(vuwiilE4pyzOV3ZRrdsymSEm)xmYIwwOwOsL3D6JSqqwgZqOSmmWI(AonTdal4IMNnwPiQPXy)kkleKfp8hSm2B)3niHXW6X8FXilddSaW7Z1vO5SvWCawG3FWIfTSeGqfi0EzUIg6176kmBRlV(vCgebCb00OdgLfTSG266SSqqZv0qVExxHzBD51VIZGiGlGSmIfTSOVMtt7aWcUO5zJvkIAwwSmmWseSOVMtt7aWcUO5zJvkIAwwSOLLiyjaHkqO9Y0oaSGlAE2yLIOMgDWOSmILHbwa4956k04uRm4k2ILHbw0HuklAzzEe3)CJX(vuwiiledGMyNWSKkwc4Pyjnlo9BxLTG2XMfYYcaVpxxHgknhG0NLrSmk5t2ITjpj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkbyQ7OS8qwIDsqw(DKfDK(SaNSa89wbBqw0JYc99ajxrKL7zzzXITUUajQOSCflEfLfniOolkYI(6zHqSuuVz5O12plUoC9S8qw0rwSAyiGGjad99yFEcW3vy9g67Tc2GgSCDfcYIwwIGLEv4e2erZFXODyxzWg9y9RaX2GLRRqqw0YsAw0xZPH(ERGnOzzXYWalo9BxLTG2XMLnzjLnglJyrll6R50qFVvWg0qFpqcleKfBZIwwsZI(AonyqDwumtHkVnllwggyrFnNgmOolkMvRYBZYILrSOLf91CAS6lg2GNRYEh86czRLI6TbGRwileKfBiTJXIwwsZsacvGq7Lj45RcMgJ9ROSSjlKpglddSebla8(CDfAcWcaKemdI0OvGfTSeGaWYR3uhX9ppDKLrjFYwSTnjPobiwUUcbtgxcqOvcqk(ja9WFWkbiaVpxxHjab4QfMaedQZIIMRYQv5nlPIfnLfYYIh(dwg6798A0GegdRhZ)fJSqawIGfmOolkAUkRwL3SKkwsZczMfcWY7kSEdfUuz4m)7yEcBK(gSCDfcYsQyX2SmIfYYIh(dwg7T)7gKWyy9y(VyKfcWYygcvJSqwwOwOsL3D6JSqawgZOrwsflVRW6nL)RgPzDx5vany56kembiisd9z9hSsaQb0)I9hPSSdTZs8kSZYwPecw8gzHOFfcYIf2SqXaSanSylwQOS8ojiLfNfA5w0D4ZYe2S87ilHv3y9SqVF5)blwOqwSdxkWA7NfDKfpewT)iltyZIYBIyZYFX4S9yKMaeG35YJXeGo1IqGnqmK8jBX22oj1jaXY1viyY4sa6H)Gvcq67nD1eXeGGin0N1FWkbOTCfBXcW3B6QjISCflEXIgeuNffzXPSqHWIfNYIfKspDfYItzrblIS4uwIcxSy)ukwWcKLLfl2VFNfnDmcWI9DSybRh7RiYYVJSuiHFw0GG6SOOMzbewB)SOWNL7zXQHbwielf1BnZciS2(zbcaB799ilEXITyH)olwnmWIxGSybHkw0XjSrwi1wj74xbw8cKfni2cAhBwghSatag67X(8eGrWsVkCcBIO5Vy0oSRmyJES(vGyBWY1viilAzjnl6R50y1xmSbpxL9o41fYwlf1BdaxTqwiil2qAhJLHbw0xZPXQVyydEUk7DWRlKTwkQ3gaUAHSqqwSrJJXIwwExH1BOpQuENb7B(gSCDfcYYiw0YsAwWG6SOO5QmfQ8MfTS40VDv2cAhBwiala8(CDfACQfHaBGyGLuXI(AonyqDwumtHkVnng7xrzHaSacFZC1rZWzgvRcn)fiHMBm2VILuXIngnYYMSOPJXYWalyqDwu0CvwTkVzrllo9BxLTG2XMfcWcaVpxxHgNAriWgigyjvSOVMtdguNffZQv5TPXy)kkleGfq4BMRoAgoZOAvO5Vaj0CJX(vSKkwSXOrw2KLu2ySmIfTSebl6R50al83PzlSdO1FWYSSyrllrWY7kSEd99wbBqdwUUcbzrllPzjaHkqO9Ye88vbtJX(vuw2KfsllddSqHlL(vGMFVpLktrKeSny56keKfTSOVMtZV3NsLPisc2g67bsyHGSyBBZIMWsAw6vHtyten0RMlvEpk9X(CdwUUcbzjvSydlJyrllZJ4(NBm2VIYYMSq(yJXIwwMhX9p3ySFfLfcYInJnglddSa2Rd0uWCaKYYiw0YsAwIGLaeawE9gsI2NxSmmWsacvGq7LbJTG2XoRdlqtJX(vuw2KfByzuYNSfBtOjPobiwUUcbtgxcqp8hSsawO9CmewjabrAOpR)GvcWXJISylaHfLLRyXROSObb1zrrw8cKfQdazHqExnjaPzPuSylaHfltyZcP2kzh)kWIxGSKY7kWgbzrdITG2XogR3WYwvuillkYYwSfyXlqwin2cS4pl)oYcwGSaNSqAASsruw8cKfqyT9ZIcFwSLn6X6xbInltxPyboNjad99yFEcq3kh2XajSOLfaEFUUcnuhaMNWoh88vbw0YsAw0xZPbdQZIIz1Q820ySFfLLnzbjmgwpM)lgzzyGf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmk5t2IT1ysQtaILRRqWKXLam03J95jaDRCyhdKWIwwa4956k0qDayEc7CWZxfyrllPzrFnNgmOolkMvRYBtJX(vuw2KfKWyy9y(VyKLHbw0xZPbdQZIIzku5TPXy)kklBYcsymSEm)xmYYiw0YsAw0xZPj45RcMLflddSOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGrYInKpglJyrllPzjcwcqay51BaG1VhTzzyGf91CAAhawWfnpBSsrutJX(vuwiilPzrJSOjSydlPILEv4e2erd9Q5sL3JsFSp3GLRRqqwgXIww0xZPPDaybx08SXkfrnllwggyjcw0xZPPDaybx08SXkfrnllwgXIwwsZseS0RcNWMiA(lgTd7kd2OhRFfi2gSCDfcYYWaliHXW6X8FXileKf91CA(lgTd7kd2OhRFfi2MgJ9ROSmmWseSOVMtZFXODyxzWg9y9RaX2SSyzucqp8hSsaU7QzogcRKpzl2MmNK6eGy56kemzCjad99yFEcq3kh2XajSOLfaEFUUcnuhaMNWoh88vbw0YsAw0xZPbdQZIIz1Q820ySFfLLnzbjmgwpM)lgzzyGf91CAWG6SOyMcvEBAm2VIYYMSGegdRhZ)fJSmIfTSKMf91CAcE(QGzzXYWal6R50y1xmSbpxL9o41fYwlf1BdaxTqwiyKSyd5JXYiw0YsAwIGLaeawE9gsI2NxSmmWI(AonKCfyJGzm2cAh7yS(mwyt8sbAwwSmIfTSKMLiyjabGLxVbaw)E0MLHbw0xZPPDaybx08SXkfrnng7xrzHGSOrw0YI(AonTdal4IMNnwPiQzzXIwwIGLEv4e2erd9Q5sL3JsFSp3GLRRqqwggyjcw0xZPPDaybx08SXkfrnllwgXIwwsZseS0RcNWMiA(lgTd7kd2OhRFfi2gSCDfcYYWaliHXW6X8FXileKf91CA(lgTd7kd2OhRFfi2MgJ9ROSmmWseSOVMtZFXODyxzWg9y9RaX2SSyzucqp8hSsaoxkvogcRKpzl2M0MK6eGy56kemzCjabrAOpR)GvcWXJISqib1awGflbWeGE4pyLa0U39b7mCMr1QWKpzl2wttsDcqSCDfcMmUeGE4pyLaK(EpVgtacI0qFw)bReGJhfzb4798AKLhYIvddSaeQ8MfniOolkQzwi1wj74xbw2DklkKsz5VyKLF3lwCwiKA)3zbjmgwpYIcNplWMfyPIYczSkVzrdcQZIISCuwwwgwiKUFNLuBJMYInwbwW6XMfNfGqL3SObb1zrrwUjleILI6nl0)ukw2DklkKsz539IfBiFmwOVhiHYIxGSqQTs2XVcS4filKcwaGKGSS7aqwIHnYYV7flKtAPSqkBjlng7xDfrdlJhfzX1HaqwSrJJrMyz3PpYc4QVIilKMgRueLfVazXgBSHmXYUtFKf73VdxplKMgRuenbyOVh7ZtaIb1zrrZvz1Q8MfTSebl6R500oaSGlAE2yLIOMLflddSGb1zrrdfQ8oxiHFwggyjnlyqDwu04v0CHe(zzyGf91CAcE(QGPXy)kkleKfp8hSm2B)3niHXW6X8FXilAzrFnNMGNVkywwSmIfTSKMLiyHIFwhwlQ5pSTrtZ2yfyzyGLEv4e2erJvFXWg8Cv27GxxiBTuuVny56keKfTSOVMtJvFXWg8Cv27GxxiBTuuVnaC1czHGSyd5JXIwwcqOceAVmbpFvW0ySFfLLnzHCsllAzjnlrWsacalVEtDe3)80rwggyjaHkqO9YeGfaijy(3Xm1667PMgJ9ROSSjlKtAzzelAzjnlrWs7b08nuPyzyGLaeQaH2lJo2uSj5kIMgJ9ROSSjlKtAzzelJyzyGfmOolkAUk7vuw0YsAw0xZPXU39b7mCMr1QqZYILHbwOwOsL3D6JSqqwgZqOAKfTSKMLiyjabGLxVbaw)E0MLHbwIGf91CAAhawWfnpBSsruZYILrSmmWsacalVEdaS(9OnlAzHAHkvE3PpYcbzzmdHYYOKpzl2oLLK6eGy56kemzCjabrAOpR)GvcWXJISqi1(VZc83X2(rrwSVFHDwoklxXcqOYBw0GG6SOOMzHuBLSJFfyb2S8qwSAyGfYyvEZIgeuNffta6H)Gvcq7T)7jFYwi0XssDcqSCDfcMmUeGGin0N1FWkbiPXvQFVxja9WFWkbyVQSh(dwz1r)eGQJ(5YJXeGtxP(9EL8jFYNaea20dwjBXMXSXMXS9yAAcq7ExxrKMaKqAReY2Y4Vfc5sjwyj17ilxSfSFwMWMLTHwyH92S0OTUUgbzHcJrw81dJ9hbzjS7frKA4niJRqwSjLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML0Kt4rgEdY4kKfBNsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZsAYj8idVbVbH0wjKTLXFleYLsSWsQ3rwUyly)SmHnlBdItFP(TzPrBDDncYcfgJS4Rhg7pcYsy3lIi1WBqgxHSqMtjwifSaG9JGSa8Ijfl0O17eMfYelpKfYy5SaEao6blwGwy7pSzjnzhXsAYj8idVbzCfYczoLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML02q4rgEdY4kKfsBkXcPGfaSFeKLT7vHtytenK(2S8qw2UxfoHnr0q6gSCDfcUnlPjNWJm8gKXvilAAkXcPGfaSFeKfGxmPyHgTENWSqMy5HSqglNfWdWrpyXc0cB)HnlPj7iwsBdHhz4niJRqw00uIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwstoHhz4niJRqwszPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SK22eEKH3GmUczjLLsSqkyba7hbzz7VVIe8nKBi9Tz5HSS93xrc(MNCdPVnlPTHWJm8gKXvilPSuIfsblay)iilB)9vKGVXgdPVnlpKLT)(ksW382yi9TzjTneEKH3GmUczH8XsjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczHCYtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczHCBsjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczHCBNsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZsAYj8idVbzCfYc5AmLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML0Kt4rgEdY4kKfYjZPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SK2gcpYWBqgxHSqozoLyHuWca2pcYY2FFfj4Bi3q6BZYdzz7VVIe8np5gsFBwsBdHhz4niJRqwiNmNsSqkyba7hbzz7VVIe8n2yi9Tz5HSS93xrc(M3gdPVnlPjNWJm8gKXvilKtAtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjTneEKH3GmUczHCsBkXcPGfaSFeKLT)(ksW3qUH03MLhYY2FFfj4BEYnK(2SKMCcpYWBqgxHSqoPnLyHuWca2pcYY2FFfj4BSXq6BZYdzz7VVIe8nVngsFBwsBdHhz4n4niK2kHSTm(BHqUuIfws9oYYfBb7NLjSzzBRgdWyD)3MLgT111iiluymYIVEyS)iilHDViIudVbzCfYITtjwifSaG9JGSS93xrc(gYnK(2S8qw2(7RibFZtUH03ML02MWJm8gKXvileAkXcPGfaSFeKLT)(ksW3yJH03MLhYY2FFfj4BEBmK(2SK22eEKH3GmUczrttjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzXFw0aBrYGL0Kt4rgEdEdcPTsiBlJ)wiKlLyHLuVJSCXwW(zzcBw22H42S0OTUUgbzHcJrw81dJ9hbzjS7frKA4niJRqwipLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML0Kt4rgEdY4kKfBsjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczXMuIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBw8NfnWwKmyjn5eEKH3GmUczX2PelKcwaW(rqw2(DfwVH03MLhYY2VRW6nKUblxxHGBZsAYj8idVbzCfYITtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjTMs4rgEdY4kKfYCkXcPGfaSFeKfGxmPyHgTENWSqMitS8qwiJLZsmeCPwuwGwy7pSzjnzAelPjNWJm8gKXvilK5uIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwsBdHhz4niJRqwiTPelKcwaW(rqwaEXKIfA06DcZczImXYdzHmwolXqWLArzbAHT)WML0KPrSKMCcpYWBqgxHSqAtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczrttjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczjLLsSqkyba7hbzb4ftkwOrR3jmlKjwEilKXYzb8aC0dwSaTW2FyZsAYoIL02q4rgEdY4kKfYTjLyHuWca2pcYcWlMuSqJwVtywitS8qwiJLZc4b4OhSybAHT)WML0KDelPjNWJm8gKXvilKtOPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSqUgtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczHCYCkXcPGfaSFeKLT7vHtytenK(2S8qw2UxfoHnr0q6gSCDfcUnlPTHWJm8gKXvilKRPPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSyZyPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SK2gcpYWBqgxHSyJnPelKcwaW(rqwaEXKIfA06DcZczILhYczSCwapah9GflqlS9h2SKMSJyjn5eEKH3GmUczXgcnLyHuWca2pcYcWlMuSqJwVtywitS8qwiJLZc4b4OhSybAHT)WML0KDelPTHWJm8gKXvil2qOPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSydzoLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML0Kt4rgEdY4kKfBiTPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSytklLyHuWca2pcYcWlMuSqJwVtywitS8qwiJLZc4b4OhSybAHT)WML0KDelPTHWJm8gKXvil2ESuIfsblay)iilaVysXcnA9oHzHmXYdzHmwolGhGJEWIfOf2(dBwst2rSKMCcpYWBWBqiTvczBz83cHCPelSK6DKLl2c2pltyZY2txP(9ETnlnARRRrqwOWyKfF9Wy)rqwc7ErePgEdY4kKfBsjwifSaG9JGSa8Ijfl0O17eMfYelpKfYy5SaEao6blwGwy7pSzjnzhXsAYj8idVbVbH0wjKTLXFleYLsSWsQ3rwUyly)SmHnlBt)TzPrBDDncYcfgJS4Rhg7pcYsy3lIi1WBqgxHSytkXcPGfaSFeKLT7vHtytenK(2S8qw2UxfoHnr0q6gSCDfcUnlPjNWJm8gKXvil2oLyHuWca2pcYY29QWjSjIgsFBwEilB3RcNWMiAiDdwUUcb3ML0Kt4rgEdY4kKfnMsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZI)SOb2IKblPjNWJm8gKXvilPSuIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwsBdHhz4niJRqwi32PelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSqUgtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjTgj8idVbzCfYc5K5uIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwstoHhz4niJRqwiN0MsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZsAYj8idVbzCfYInJLsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZsAYj8idVbzCfYIn2oLyHuWca2pcYcWlMuSqJwVtywitS8qwiJLZc4b4OhSybAHT)WML0KDelPjucpYWBqgxHSyJTtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczXgcnLyHuWca2pcYcWlMuSqJwVtywitS8qwiJLZc4b4OhSybAHT)WML0KDelPjNWJm8gKXvil2qOPelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSyJgtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjn5eEKH3GmUczX2JLsSqkyba7hbzb4ftkwOrR3jmlKjwEilKXYzb8aC0dwSaTW2FyZsAYoIL02MWJm8gKXvil2ESuIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwstoHhz4niJRqwSn5PelKcwaW(rqw2UxfoHnr0q6BZYdzz7Ev4e2erdPBWY1vi42SKMCcpYWBqgxHSyBBsjwifSaG9JGSa8Ijfl0O17eMfYelpKfYy5SaEao6blwGwy7pSzjnzhXsABt4rgEdY4kKfBB7uIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwsBdHhz4niJRqwSTgtjwifSaG9JGSSDVkCcBIOH03MLhYY29QWjSjIgs3GLRRqWTzjTneEKH3GmUczX2K5uIfsblay)iilB3RcNWMiAi9Tz5HSSDVkCcBIOH0ny56keCBwsBdHhz4niJRqwSTMMsSqkyba7hbzz7Ev4e2erdPVnlpKLT7vHtytenKUblxxHGBZsAYj8idVbVX4hBb7hbzHmZIh(dwSOo6tn8gjaPwyizlKpMnjaTA48uycqnudzzCUYRaYITSxhiVHgQHSyl4DyNfY1OMzXMXSXgEdEdnudzHu7ErePPeVHgQHSOjSSvqqeKfGqL3Smo0Jn8gAOgYIMWcP29IicYY7nr8Z3KLGtrklpKLq0GcZV3eXNA4n0qnKfnHfczymeacYYQkmGuQ3rzbG3NRRqklPpdA0mlwncitFVPRMiYIMSjlwncWqFVPRMioYWBOHAilAclBfa8azXQXGt)RiYcHu7)ol3KL73MYYVJSyVHfrw0GG6SOOH3qd1qw0ewSfCsqwifSaajbz53rwaAD99uwCwu3)kKLyyJSmviHpDfYs6BYsu4ILDhS2(zz)EwUNf6fVuVxiCrvrzX(97SmoBXTMAwialKcvi9pxXYwvhXkgRxZSC)2GSqj5Sgz4n0qnKfnHfBbNeKLyi9zz75rC)Zng7xr3MfAalVpiLf3YsfLLhYIoKszzEe3FklWsf1WBOHAilAclPUr)zj1WyKf4KLXP8DwgNY3zzCkFNfNYIZc1cdNRy57RibFdVHgQHSOjSylAHf2SK(mOrZSqi1(VRzwiKA)31mlaFVNxJJyj2brwIHnYsJ0tDy9S8qwqVvh2SeGX6(Rj0373WBOHAilAclKMJWSKY7kWgbzrdITG2XogRNLWogiHLjSzHu2swwuNiA4n4n0qnKLTwf89hbzzCUYRaYYwjeKblbVyrhzzcxfil(ZY()w0uISKv3vEfqnHEXbdX73x6Mds2X5kVcOMa8IjfzJbn7FSkL)5PWi1DLxb08e(5n4n8WFWIASAmaJ19pssUcSrWm1667P8gAilPEhzbG3NRRqwoklu8z5HSmgl2VFNLcYc99NfyXYIIS89vKGpvZSqol23XILFhzzEn9zbwilhLfyXYIIAMfBy5MS87ilumalqwoklEbYITz5MSOd)Dw8g5n8WFWIASAmaJ19NarswaEFUUc1C5XyKWkVOy(7RibFndWvlmYX4n8WFWIASAmaJ19NarswaEFUUc1C5XyKWkVOy(7RibFndTI0bb1maxTWijxZ3mYVVIe8nKB2DAErXS(Ao1(9vKGVHCtacvGq7LbC1(FWsBeFFfj4Bi3CuZdJXmCMJHf9B4IMdWI(9k8hSO8gE4pyrnwngGX6(tGijlaVpxxHAU8ymsyLxum)9vKGVMHwr6GGAgGRwyK2O5Bg53xrc(gBm7onVOywFnNA)(ksW3yJjaHkqO9YaUA)pyPnIVVIe8n2yoQ5HXygoZXWI(nCrZbyr)Ef(dwuEdnKLuVJuKLVVIe8PS4nYsbFw81dJ9)cUsfLfq8XWJGS4uwGfllkYc99NLVVIe8Pgwybi(SaW7Z1vilpKfcLfNYYVJrzXvuilfIGSqTWW5kw29cuDfrdVHh(dwuJvJbySU)eisYcW7Z1vOMlpgJew5ffZFFfj4RzOvKoiOMb4QfgjHQ5BgjARRZYcbnxrd96DDfMT1Lx)kodIaUaomG266SSqqdgBfTrxLHny5vahgqBDDwwiOHcxkf()veZ9spkVHgYcq8PS87ilaFVPRMiYsasFwMWMfL)yZsWvHLY)dwuwspHnliH9ylfYI9DSy5HSqFVFwaxXwxrKfDCcBKfstJvkIYY0vkklW5CeVHh(dwuJvJbySU)eisYcW7Z1vOMlpgJKsZbi91maxTWiT9yPkn5AYygY1yQO4N1H1IA(dBB00mHAfgXB4H)Gf1y1yagR7pbIKSa8(CDfQ5YJXiPZCasFndWvlmsnowQstUMmMHCnMkk(zDyTOM)W2gnntOwHr8gAilaXNYI)SyF)c7S4XWv9SaNSSvkHGfsblaqsqwO7WLcKfDKLffbtjwi0XyX(97W1ZcPqfs)ZvSa0667PS4fil2EmwSF)UH3Wd)blQXQXamw3Fcejzb4956kuZLhJrgGfaijy2PwAgGRwyK2Emcq(yPQxfoHnr0eqfs)ZvzQ113t5n8WFWIASAmaJ19Nars2yiSi5Q8e2X8gE4pyrnwngGX6(tGijR92)DnRUcZbWijFmnFZitJb1zrrJAvENlKW)WaguNffnxLPqL3ddyqDwu0Cvwh(7ddyqDwu04v0CHe(hXBWBOHSqiAm40NfByHqQ9FNfVazXzb47nD1erwGflatnl2VFNLTCe3FwinoYIxGSmo4wtnlWMfGV3ZRrwG)o22pkYB4H)Gf1aTWcBcejzT3(VR5BgzAmOolkAuRY7CHe(hgWG6SOO5QmfQ8EyadQZIIMRY6WFFyadQZIIgVIMlKW)iTwncWqUXE7)U2iSAeGXgJ92)DEdp8hSOgOfwytGijl99EEnQz1vyoagPg18nJmDe9QWjSjIgDx5vaZWz2vQ8VFfr6WqebiaS86n1rC)ZthhgIGAHkv(9Mi(ud99E6kvKKpmeX7kSEt5)QrAw3vEfqdwUUcbhPnck(zDyTOM)W2gnnBJvyyinguNffnuOY7CHe(hgWG6SOO5QSAvEpmGb1zrrZvzD4VpmGb1zrrJxrZfs4FeVHh(dwud0clSjqKKL(EtxnruZQRWCamsnQ5Bgz6Ev4e2erJUR8kGz4m7kv(3VIivBacalVEtDe3)80rTuluPYV3eXNAOV3txPIK8rAJGIFwhwlQ5pSTrtZ2yf4n4n0qnKfnGWyy9iiliaSJYYFXil)oYIhEyZYrzXb4NY1vOH3Wd)blAKuOY7So6X8gE4pyrjqKKn4kv2d)bRS6OVMlpgJeAHf2AM(9f(ijxZ3mY)IrcM2Mu5H)GLXE7)Uj40p)xmsap8hSm03751Oj40p)xmoI3qdzbi(uw2kudybwSyBcWI973HRNfW(MplEbYI973zb47Tc2GS4fil2qawG)o22pkYB4H)GfLarswaEFUUc1C5XyKhn7quZaC1cJKAHkv(9Mi(ud99E6k1MKRnDeVRW6n03BfSbny56keCy4DfwVH(Os5DgSV5BWY1vi4OHbQfQu53BI4tn037PRuBAdVHgYcq8PSeuOdazX(owSa89EEnYsWlw2VNfBialV3eXNYI99lSZYrzPrfcWRNLjSz53rw0GG6SOilpKfDKfRgNy3iilEbYI99lSZY8ukSz5HSeC6ZB4H)GfLarswaEFUUc1C5XyKhnhuOda1maxTWiPwOsLFVjIp1qFVNxJBsoVHgYskxVpxxHS87(ZsyhdKqz5MSefUyXBKLRyXzHyaKLhYIdaEGS87il07x(FWIf77yJS4S89vKGpl4hy5OSSOiilxXIo(2rSyj40NYB4H)GfLarswaEFUUc1C5XyKxLjga1maxTWiTAeqMya0qUjgcR514WGvJaYedGgYn0vnVghgSAeqMya0qUH(EtxnrCyWQrazIbqd5g6790vQHbRgbKjganKBMRoAgoZOAv4WGvJamTdal4IMNnwPi6WG(AonbpFvW0ySFfns91CAcE(QGbC1(FWAyaG3NRRqZrZoe5n0qwgpkYY4WMInjxrKf)z53rwWcKf4KfstJvkIYI9DSyz3PpYYrzX1HaqwiZJrM0ml(8XMfsblaqsqwSF)olJd6PMfVazb(7yB)Oil2VFNfsTvYo(vG3Wd)blkbIKS6ytXMKRiQ5Bgz60reGaWYR3uhX9ppDCyiIaeQaH2ltawaGKG5FhZuRRVNAwwddr0RcNWMiA0DLxbmdNzxPY)(vePJ0QVMttWZxfmng7xr3KCnQvFnNM2bGfCrZZgRue10ySFfLGeQ2icqay51BaG1VhThgcqay51BaG1VhT1QVMttWZxfmllT6R500oaSGlAE2yLIOMLL206R500oaSGlAE2yLIOMgJ9ROemsYTrti0u1RcNWMiAOxnxQ8Eu6J95dd6R50e88vbtJX(vucso5ddKtMOwOsL3D6JeKCdzE0iTa8(CDfAUktmaYBOHSqiGpl2VFNfNfsTvYo(vGLF3FwoAT9ZIZcHyPOEZIvddSaBwSVJfl)oYY8iU)SCuwCD46z5HSGfiVHh(dwucejzTG)blnFZitRVMttWZxfmng7xr3KCnQnDe9QWjSjIg6vZLkVhL(yF(WG(AonTdal4IMNnwPiQPXy)kkbjpLPvFnNM2bGfCrZZgRue1SSgnmOdPuTZJ4(NBm2VIsqB04iTa8(CDfAUktmaYBOHSqkxfwk)rkl23XFhBww0RiYcPGfaijilf0ol2pLIfxPG2zjkCXYdzH(NsXsWPpl)oYc1Jrw8y4QEwGtwifSaajbjaP2kzh)kWsWPpL3Wd)blkbIKSa8(CDfQ5YJXidWcaKemdI0OvqZaC1cJmGNkD65rC)Zng7xr1eY1OMeGqfi0EzcE(QGPXy)k6iYe5A6yJ2mGNkD65rC)Zng7xr1eY1OMeGqfi0EzcWcaKem)7yMAD99utJX(v0rKjY10XgPnI2pWmcaR34GGuds4J(uTPJiaHkqO9Ye88vbtJoy0HHicqOceAVmbybascM)DmtTU(EQPrhm6OHHaeQaH2ltWZxfmng7xr38QhBlOYFemppI7FUXy)k6WqVkCcBIOjGkK(NRYuRRVNQnaHkqO9Ye88vbtJX(v0nT9yddbiubcTxMaSaajbZ)oMPwxFp10ySFfDZRESTGk)rW88iU)5gJ9ROAc5JnmeracalVEtDe3)80rEdnKLXJIGS8qwarLhLLFhzzrDIilWjlKARKD8Ral23XILf9kISacx6kKfyXYIIS4filwncaRNLf1jISyFhlw8IfheKfeawplhLfxhUEwEilGhYB4H)GfLarswaEFUUc1C5XyKbWCawG3FWsZaC1cJm97nr8n)fJ5hMbpCtY14Wq7hygbG1BCqqQ5Qn14yJ0MonARRZYcbnySv0gDvg2GLxbuB6icqay51BaG1VhThgcqOceAVmySv0gDvg2GLxb00ySFfLGKtMjTeiTgtvVkCcBIOHE1CPY7rPp2NpAK2icqOceAVmySv0gDvg2GLxb00OdgD0WaARRZYcbnu4sPW)VIyUx6r1MoIaeawE9M6iU)5PJddbiubcTxgkCPu4)xrm3l9OzBtOAuthJCtJX(vucso5e6OHH0biubcTxgDSPytYvenn6GrhgIO9aA(gQuddbiaS86n1rC)ZthhPnDeVRW6nZvhndNzuTk0GLRRqWHHaeawE9gay97rBTbiubcTxM5QJMHZmQwfAAm2VIsqYjNaAmv9QWjSjIg6vZLkVhL(yF(WqebiaS86naW63J2AdqOceAVmZvhndNzuTk00ySFfLG6R50e88vbd4Q9)Gfbi3Mu1RcNWMiAS6lg2GNRYEh86czRLI6TMqUnJ0MgT11zzHGMROHE9UUcZ26YRFfNbraxa1gGqfi0EzUIg6176kmBRlV(vCgebCb00ySFfLGAC0Wq60OTUolle0q3DqODemdB9mCMFyhJ1RnaHkqO9Y8WogRhbZxrpI7F22AuJ22gYnng7xrhnmKonaVpxxHgyLxum)9vKGFKKpmaW7Z1vObw5ffZFFfj4hPThPn93xrc(gYnn6GrZbiubcTxddFFfj4Bi3eGqfi0EzAm2VIU5vp2wqL)iyEEe3)CJX(vunH8XgnmaW7Z1vObw5ffZFFfj4hPnAt)9vKGVXgtJoy0CacvGq71WW3xrc(gBmbiubcTxMgJ9ROBE1JTfu5pcMNhX9p3ySFfvtiFSrdda8(CDfAGvErX83xrc(ro2OrJ4n0qws56956kKLffbz5HSaIkpklEfLLVVIe8PS4filbqkl23XIf7(9xrKLjSzXlw0GL1oSpNfRgg4n8WFWIsGijlaVpxxHAU8ymYFVpLktrKeSZ2971maxTWiJGcxk9Ran)EFkvMIijyBWY1vi4WW8iU)5gJ9ROBAZyJnmOdPuTZJ4(NBm2VIsqB0ibstOJPj6R50879PuzkIKGTH(EGKuzZOHb91CA(9(uQmfrsW2qFpqYM2wt1K09QWjSjIg6vZLkVhL(yFEQSzeVHgYY4rrw0GyROn6kwSfBWYRaYInJrXaLfDCcBKfNfsTvYo(vGLffzb2SqHS87(ZY9Sy)ukwuxHSSSyX(97S87ilybYcCYcPPXkfr5n8WFWIsGij7II57XynxEmgjgBfTrxLHny5va18nJmaHkqO9Ye88vbtJX(vucAZyAdqOceAVmbybascM)DmtTU(EQPXy)kkbTzmTPb4956k0879PuzkIKGD2UF)WG(Aon)EFkvMIijyBOVhiztBpgbs3RcNWMiAOxnxQ8Eu6J95PY2JgPfG3NRRqZvzIbWHbDiLQDEe3)CJX(vucABslVHgYY4rrwacxkf(xrKfczl9OSqMPyGYIooHnYIZcP2kzh)kWYIISaBwOqw(D)z5EwSFkflQRqwwwSy)(Dw(DKfSazbozH00yLIO8gE4pyrjqKKDrX89ySMlpgJKcxkf()veZ9spQMVzKPdqOceAVmbpFvW0ySFfLGKzTreGaWYR3aaRFpARnIaeawE9M6iU)5PJddbiaS86n1rC)Zth1gGqfi0EzcWcaKem)7yMAD99utJX(vucsM1MgG3NRRqtawaGKGzqKgTcddbiubcTxMGNVkyAm2VIsqY8OHHaeawE9gay97rBTPJOxfoHnr0qVAUu59O0h7Z1gGqfi0EzcE(QGPXy)kkbjZdd6R500oaSGlAE2yLIOMgJ9ROeK8XiqAnMk0wxNLfcAUI(9k8WMMbpaxHzDuPgPvFnNM2bGfCrZZgRue1SSgnmOdPuTZJ4(NBm2VIsqB04WaARRZYcbnySv0gDvg2GLxbuBacvGq7LbJTI2ORYWgS8kGMgJ9ROBAZyJ0cW7Z1vO5QmXaO2iqBDDwwiO5kAOxVRRWSTU86xXzqeWfWHHaeQaH2lZv0qVExxHzBD51VIZGiGlGMgJ9ROBAZydd6qkv78iU)5gJ9ROe0MX4n0qw2QYUhLYYIISm(PCAlzX(97SqQTs2XVcSaBw8NLFhzblqwGtwinnwPikVHh(dwucejzb4956kuZLhJrE2kyoalW7pyPzaUAHrQVMttWZxfmng7xr3KCnQnDe9QWjSjIg6vZLkVhL(yF(WG(AonTdal4IMNnwPiQPXy)kkbJKCnA0ibsBBJgtL(Aon6kieuTOVzznIaPjuJg1eBB0yQ0xZPrxbHGQf9nlRrPcT11zzHGMROFVcpSPzWdWvywhvkcqOgnMQ0OTUolle087yEEn9Z0J4P0gGqfi0Ez(DmpVM(z6r8uMgJ9ROemsBgBKw91CAAhawWfnpBSsruZYA0WGoKs1opI7FUXy)kkbTrJddOTUolle0GXwrB0vzydwEfqTbiubcTxgm2kAJUkdBWYRaAAm2VIYB4H)GfLars2ffZ3JXAU8ymYROHE9UUcZ26YRFfNbraxa18nJeG3NRRqZzRG5aSaV)GLwaEFUUcnxLjga5n0qwgpkYcWDheAhbzXwS1zrhNWgzHuBLSJFf4n8WFWIsGij7II57XynxEmgjD3bH2rWmS1ZWz(HDmwVMVzKPdqOceAVmbpFvW0OdgvBebiaS86n1rC)Zth1cW7Z1vO537tPYuejb7SD)ETPdqOceAVm6ytXMKRiAA0bJomer7b08nuPgnmeGaWYR3uhX9ppDuBacvGq7LjalaqsW8VJzQ113tnn6Gr1MgG3NRRqtawaGKGzqKgTcddbiubcTxMGNVkyA0bJoAKwq4BORAEnA(lqYve1Mge(g6JkL35PYB08xGKRiomeX7kSEd9rLY78u5nAWY1vi4Wa1cvQ87nr8Pg6798ACtBpsli8nXqynVgn)fi5kIAtdW7Z1vO5OzhIdd9QWjSjIgDx5vaZWz2vQ8VFfr6WGt)2vzlODS3mYu2ydda8(CDfAcWcaKemdI0OvyyqFnNgDfecQw03SSgPnc0wxNLfcAUIg6176kmBRlV(vCgebCbCyaT11zzHGMROHE9UUcZ26YRFfNbraxa1gGqfi0EzUIg6176kmBRlV(vCgebCb00ySFfDtBpM2i0xZPj45RcML1WGoKs1opI7FUXy)kkbj0X4n0qws9(rz5OS4S0(VJnlOY1HT)il29OS8qwIDsqwCLIfyXYIISqF)z57RibFklpKfDKf1viilllwSF)olKARKD8RalEbYcPGfaijilEbYYIIS87il2uGSqvWNfyXsaKLBYIo83z57RibFklEJSalwwuKf67plFFfj4t5n8WFWIsGij7II57XyQMPk4tJ87RibFY18nJmnaVpxxHgyLxum)9vKGFersU2i((ksW3yJPrhmAoaHkqO9AyinaVpxxHgyLxum)9vKGFKKpmaW7Z1vObw5ffZFFfj4hPThPnT(AonbpFvWSS0MoIaeawE9gay97r7Hb91CAAhawWfnpBSsrutJX(vucK22gnMQEv4e2erd9Q5sL3JsFSpFebJ87RibFd5g91CMbxT)hS0QVMtt7aWcUO5zJvkIAwwdd6R500oaSGlAE2yLIOz6vZLkVhL(yFUzznAyiaHkqO9Ye88vbtJX(vucyZMFFfj4Bi3eGqfi0EzaxT)hS0gH(AonbpFvWSS0MoIaeawE9M6iU)5PJddraW7Z1vOjalaqsWmisJwHrAJiabGLxVHKO951WqacalVEtDe3)80rTa8(CDfAcWcaKemdI0OvqBacvGq7LjalaqsW8VJzQ113tnllTreGqfi0EzcE(QGzzPnDA91CAWG6SOywTkVnng7xr3K8Xgg0xZPbdQZIIzku5TPXy)k6MKp2iTr0RcNWMiA0DLxbmdNzxPY)(vePddP1xZPr3vEfWmCMDLk)7xrKMl)xnAOVhijsnomOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqsKA6Ordd6R50qYvGncMXylODSJX6ZyHnXlfOzznAyqhsPANhX9p3ySFfLG2m2WaaVpxxHgyLxum)9vKGFKJnslaVpxxHMRYedG8gE4pyrjqKKDrX89ymvZuf8Pr(9vKGVnA(MrMgG3NRRqdSYlkM)(ksWpIiTrBeFFfj4Bi30OdgnhGqfi0EnmaW7Z1vObw5ffZFFfj4hPnAtRVMttWZxfmllTPJiabGLxVbaw)E0EyqFnNM2bGfCrZZgRue10ySFfLaPTTrJPQxfoHnr0qVAUu59O0h7ZhrWi)(ksW3yJrFnNzWv7)blT6R500oaSGlAE2yLIOML1WG(AonTdal4IMNnwPiAME1CPY7rPp2NBwwJggcqOceAVmbpFvW0ySFfLa2S53xrc(gBmbiubcTxgWv7)blTrOVMttWZxfmllTPJiabGLxVPoI7FE64Wqea8(CDfAcWcaKemdI0OvyK2icqay51BijAFEPnDe6R50e88vbZYAyiIaeawE9gay97r7rddbiaS86n1rC)Zth1cW7Z1vOjalaqsWmisJwbTbiubcTxMaSaajbZ)oMPwxFp1SS0gracvGq7Lj45RcMLL20P1xZPbdQZIIz1Q820ySFfDtYhByqFnNgmOolkMPqL3MgJ9ROBs(yJ0grVkCcBIOr3vEfWmCMDLk)7xrKomKwFnNgDx5vaZWz2vQ8VFfrAU8F1OH(EGKi14WG(Aon6UYRaMHZSRu5F)kI0S3bVqd99ajrQPJgnAyqFnNgsUcSrWmgBbTJDmwFglSjEPanlRHbDiLQDEe3)CJX(vucAZydda8(CDfAGvErX83xrc(ro2iTa8(CDfAUktmaYBOHSmEuKYIRuSa)DSzbwSSOil3JXuwGflbqEdp8hSOeisYUOy(EmMYBOHSOb3VJnleHSC1dz53rwOplWMfhIS4H)GflQJ(8gE4pyrjqKKTxv2d)bRS6OVMlpgJ0HOMPFFHpsY18nJeG3NRRqZrZoe5n8WFWIsGijBVQSh(dwz1rFnxEmgj95n4n0qwiLRclL)iLf774VJnl)oYITSrpo4FyhBw0xZjl2pLILPRuSaNtwSF)(vS87ilfs4NLGtFEdp8hSOghIrcW7Z1vOMlpgJeSrpoB)uQ80vQmCo1maxTWi7vHtyten)fJ2HDLbB0J1VceBTP1xZP5Vy0oSRmyJES(vGyBAm2VIsqIbqtStycmMH8Hb91CA(lgTd7kd2OhRFfi2MgJ9ROe0d)bld99EEnAqcJH1J5)IrcmMHCTPXG6SOO5QSAvEpmGb1zrrdfQ8oxiH)HbmOolkA8kAUqc)JgPvFnNM)Ir7WUYGn6X6xbITzzXBOHSqkxfwk)rkl23XFhBwa(EtxnrKLJYIDy)7SeC6FfrwGaWMfGV3ZRrwUIfYyvEZIgeuNff5n8WFWIACisGijlaVpxxHAU8ymYJybBmtFVPRMiQzaUAHrgbguNffnxLPqL3APwOsLFVjIp1qFVNxJBsA1K3vy9gkCPYWz(3X8e2i9ny56kemv2qamOolkAUkRd)DTr0RcNWMiAS6lg2GNRYEh86czRLI6T2i6vHtytenWc)DAoOqVZao6blEdnKLXJISqkybascYI9DSyXFwuiLYYV7flACmw2kLqWIxGSOUczzzXI973zHuBLSJFf4n8WFWIACisGijBawaGKG5FhZuRRVNQ5BgzeG96anfmhaPAtNgG3NRRqtawaGKGzqKgTcAJiaHkqO9Ye88vbtJoyuTr0RcNWMiAS6lg2GNRYEh86czRLI69WG(AonbpFvWSS0MoIEv4e2erJvFXWg8Cv27GxxiBTuuVhg6vHtytenbuH0)CvMAD990HH5rC)Zng7xr3KCBiTdd6qkv78iU)5gJ9ROemaHkqO9Ye88vbtJX(vucq(ydd6R50e88vbtJX(v0nj3MrJ0MoDAN(TRYwq7ytWib4956k0eGfaijy2PwdduluPYV3eXNAOV3ZRXnT9iTP1xZPbdQZIIz1Q820ySFfDtYhByqFnNgmOolkMPqL3MgJ9ROBs(yJgg0xZPj45RcMgJ9ROBQrT6R50e88vbtJX(vucgj52msB6iExH1BOpQuENb7B(dd6R50qFVNUszAm2VIsqYnAutgZOXu1RcNWMiAcOcP)5Qm1667Pdd6R50e88vbtJX(vucQVMtd99E6kLPXy)kkb0Ow91CAcE(QGzznsB6i6vHtyten)fJ2HDLbB0J1Vce7HHi6vHtytenbuH0)CvMAD990Hb91CA(lgTd7kd2OhRFfi2MgJ9ROBIegdRhZ)fJJgg6vHtyten6UYRaMHZSRu5F)kI0rAthrVkCcBIOr3vEfWmCMDLk)7xrKomKwFnNgDx5vaZWz2vQ8VFfrAU8F1OH(EGKi10Hb91CA0DLxbmdNzxPY)(vePzVdEHg67bsIuthnAyqhsPANhX9p3ySFfLGKpM2icqOceAVmbpFvW0OdgDeVHgYY4rrwaUQ51ilxXILxGy8fybwS4v0F)kIS87(ZI6aGuwiNqPyGYIxGSOqkLf73VZsmSrwEVjIpLfVazXFw(DKfSazbozXzbiu5nlAqqDwuKf)zHCcLfkgOSaBwuiLYsJX(vxrKfNYYdzPGpl7oGRiYYdzPXzJ0Dwax9vezHmwL3SObb1zrrEdp8hSOghIeisYsx18AuZHObfMFVjIpnsY18nJmDJZgP7UUchg0xZPbdQZIIzku5TPXy)kkbTTwmOolkAUktHkV12ySFfLGKtOAFxH1BOWLkdN5FhZtyJ03GLRRqWrAFVjIV5Vym)Wm4HBsoHQjuluPYV3eXNsGgJ9ROAtJb1zrrZvzVIom0ySFfLGedGMyNWJ4n0qwgpkYcWvnVgz5HSS7aqwCwiQG6UILhYYIISm(PCAl5n8WFWIACisGijlDvZRrnFZib4956k0C2kyoalW7pyPnaHkqO9YCfn0R31vy2wxE9R4mic4cOPrhmQw0wxNLfcAUIg6176kmBRlV(vCgebCbuRBLd7yGeEdnKLuEiAXYYIfGV3txPyXFwCLIL)IrklRsHukll6vezHmIg82PS4fil3ZYrzX1HRNLhYIvddSaBwu4ZYVJSqTWW5kw8WFWIf1vil6OcANLDVavil2Yg9y9RaXMfyXInS8EteFkVHh(dwuJdrcejzPV3txP08nJmI3vy9g6JkL3zW(MVblxxHGAthbf)SoSwuZFyBJMMjuRWWaguNffnxL9k6Wa1cvQ87nr8Pg6790vQnT9iTP1xZPH(EpDLY04Sr6URRqTPPwOsLFVjIp1qFVNUsrqBpmerVkCcBIO5Vy0oSRmyJES(vGypAy4DfwVHcxQmCM)DmpHnsFdwUUcb1QVMtdguNffZuOYBtJX(vucABTyqDwu0CvMcvERvFnNg6790vktJX(vucsA1sTqLk)EteFQH(EpDLAZij0rAthrVkCcBIOrfn4TtZtfI)veZevxSffhg(lgjtKjcvJBQVMtd99E6kLPXy)kkbSzK23BI4B(lgZpmdE4MAK3qdzHq6(Dwa(Os5nl2Y(MpllkYcSyjaYI9DSyPXzJ0DxxHSOVEwO)PuSy3VNLjSzHmIg82PSy1WalEbYciS2(zzrrw0XjSrwiLTKAyb4FkfllkYIooHnYcPGfaijil0Rcil)U)Sy)ukwSAyGfVG)o2Sa89E6kfVHh(dwuJdrcejzPV3txP08nJ8DfwVH(Os5DgSV5BWY1viOw91CAOV3txPmnoBKU76kuB6iO4N1H1IA(dBB00mHAfggWG6SOO5QSxrhgOwOsLFVjIp1qFVNUsTjHosB6i6vHtytenQObVDAEQq8VIyMO6ITO4WWFXizImrOACtcDK23BI4B(lgZpmdE4M2M3qdzHq6(DwSLn6X6xbInllkYcW37PRuS8qwibrlwwwS87il6R5Kf9OS4kkKLf9kISa89E6kflWIfnYcfdWcKYcSzrHuklng7xDfrEdp8hSOghIeisYsFVNUsP5BgzVkCcBIO5Vy0oSRmyJES(vGyRLAHkv(9Mi(ud99E6k1MrABTPJqFnNM)Ir7WUYGn6X6xbITzzPvFnNg6790vktJZgP7UUchgsdW7Z1vObSrpoB)uQ80vQmCo1MwFnNg6790vktJX(vucA7HbQfQu53BI4tn037PRuBAJ23vy9g6JkL3zW(MVblxxHGA1xZPH(EpDLY0ySFfLGAC0Or8gAilKYvHLYFKYI9D83XMfNfGV30vtezzrrwSFkflbFrrwa(EpDLILhYY0vkwGZPMzXlqwwuKfGV30vtez5HSqcIwSylB0J1VceBwOVhiHLLLHfnDmwokl)oYsJ266AeKLTsjeS8qwco9zb47nD1erca89E6kfVHh(dwuJdrcejzb4956kuZLhJrsFVNUsLTdRppDLkdNtndWvlmsN(TRYwq7yVPMowQstUMqXpRdRf18h22OPzBScPAmJnJsvAY1e91CA(lgTd7kd2OhRFfi2g67bss1ygYhPjP1xZPH(EpDLY0ySFfnv2MmrTqLkV70htveVRW6n0hvkVZG9nFdwUUcbhPjPdqOceAVm037PRuMgJ9ROPY2KjQfQu5DN(yQExH1BOpQuENb7B(gSCDfcostsRVMtZC1rZWzgvRcnng7xrtLghPnT(Aon037PRuML1WqacvGq7LH(EpDLY0ySFfDeVHgYY4rrwa(EtxnrKf73VZITSrpw)kqSz5HSqcIwSSSy53rw0xZjl2VFhUEwuq6vezb4790vkwww)fJS4fillkYcW3B6QjISalwiucWY4GBn1SqFpqcLLv9NIfcLL3BI4t5n8WFWIACisGijl99MUAIOMVzKa8(CDfAaB0JZ2pLkpDLkdNtTa8(CDfAOV3txPY2H1NNUsLHZP2ia4956k0CelyJz67nD1eXHH06R50O7kVcygoZUsL)9RisZL)Rgn03dKSPThg0xZPr3vEfWmCMDLk)7xrKM9o4fAOVhiztBpsl1cvQ87nr8Pg6790vkcsOAb4956k0qFVNUsLTdRppDLkdNtEdnKLXJISqT7Dmluil)U)SefUyHi(Se7eMLL1FXil6rzzrVIil3ZItzr5pYItzXcsPNUczbwSOqkLLF3lwSnl03dKqzb2SKYXI(SyFhlwSnbyH(EGekliHTUg5n8WFWIACisGijRd6w)baZu7EhR5q0GcZV3eXNgj5A(MrgXFbsUIO2i8WFWY4GU1FaWm1U3Xzqp2jIMRYt1rC)hgaHVXbDR)aGzQDVJZGESten03dKqqBRfe(gh0T(daMP29ood6Xor00ySFfLG2M3qdzHqgoBKUZITaewZRrwUjlKARKD8RalhLLgDWOAMLFhBKfVrwuiLYYV7flAKL3BI4tz5kwiJv5nlAqqDwuKf73VZcq4tA0mlkKsz539IfYhJf4VJT9JISCflEfLfniOolkYcSzzzXYdzrJS8EteFkl64e2ilolKXQ8MfniOolkAyXwcRTFwAC2iDNfWvFfrws5DfyJGSObXwq7yhJ1ZYQuiLYYvSaeQ8MfniOolkYB4H)Gf14qKars2yiSMxJA(9Mi(5BgzJZgP7UUc1(EteFZFXy(HzWd3mDAYjucKMAHkv(9Mi(ud99EEnMkBsL(AonyqDwumRwL3ML1OreOXy)k6iYuAYjW7kSEZB)QCmewudwUUcbhP5BgPt)2vzlODS3eG3NRRqdDMdq6Rj6R50qFVNUszAm2VIMkYS20UvoSJbsgga4956k0CelyJz67nD1eXHHiWG6SOO5QSxrhPnDacvGq7Lj45RcMgDWOAXG6SOO5QSxr1gbyVoqtbZbqQ20a8(CDfAcWcaKemdI0OvyyiaHkqO9YeGfaijy(3Xm1667PMgDWOddreGaWYR3uhX9ppDC0Wa1cvQ87nr8Pg6798AKGPtRPAsA91CAWG6SOywTkVnlRuz7rJsvAYjW7kSEZB)QCmewudwUUcbhnsBeyqDwu0qHkVZfs4xB6icqOceAVmbpFvW0OdgDyaSxhOPG5aiD0WqAmOolkAUktHkVhg0xZPbdQZIIz1Q82SS0gX7kSEdfUuz4m)7yEcBK(gSCDfcosBAQfQu53BI4tn03751ibjFSuLMCc8UcR382VkhdHf1GLRRqWrJgPnDebiaS86nKeTpVggIqFnNgsUcSrWmgBbTJDmwFglSjEPanlRHbmOolkAUktHkVhPnc91CAAhawWfnpBSsr0m9Q5sL3JsFSp3SS4n0qwgpkYcPbUfwGflbqwSF)oC9SeClRRiYB4H)Gf14qKars2jSdygoZL)Rg18nJ0TYHDmqYWaaVpxxHMJybBmtFVPRMiYB4H)Gf14qKarswaEFUUc1C5XyKbWCawG3FWk7quZaC1cJmcWEDGMcMdGuTPb4956k0eaZbybE)blTP1xZPH(EpDLYSSggExH1BOpQuENb7B(gSCDfcomeGaWYR3uhX9ppDCKwq4BIHWAEnA(lqYve1Moc91CAOqf9VaAwwAJqFnNMGNVkywwAthX7kSEZC1rZWzgvRcny56keCyqFnNMGNVkyaxT)hS2maHkqO9YmxD0mCMr1QqtJX(vucOPJ0Mock(zDyTOM)W2gnnBJvyyadQZIIMRYQv59WaguNffnuOY7CHe(hPfG3NRRqZV3NsLPisc2z7(9AthracalVEtDe3)80XHbaEFUUcnbybascMbrA0kmmeGqfi0EzcWcaKem)7yMAD99utJX(vucsUghP99Mi(M)IX8dZGhUP(AonbpFvWaUA)pyLQXmK2rdd6qkv78iU)5gJ9ROeuFnNMGNVkyaxT)hSia52KQEv4e2erJvFXWg8Cv27GxxiBTuuVhXBOHSmEuKfstJvkIYI973zHuBLSJFf4n8WFWIACisGijB7aWcUO5zJvkIQ5BgP(AonbpFvW0ySFfDtY14WG(AonbpFvWaUA)pyraYTjv9QWjSjIgR(IHn45QS3bVUq2APOEtqBiZAb4956k0eaZbybE)bRSdrEdnKLXJISqQTs2XVcSalwcGSSkfsPS4filQRqwUNLLfl2VFNfsblaqsqEdp8hSOghIeisYgqfs)ZvzxDeRySEnFZib4956k0eaZbybE)bRSdrTPJiabGLxVbaw)E0EyiIEv4e2erd9Q5sL3JsFSpFyOxfoHnr0y1xmSbpxL9o41fYwlf17Hb91CAcE(QGbC1(FWAZiTHmpAyqFnNM2bGfCrZZgRue1SS0QVMtt7aWcUO5zJvkIAAm2VIsqY1OrJ8gE4pyrnoejqKK9QG3L)hS08nJeG3NRRqtamhGf49hSYoe5n0qwgpkYIgeBbTJnlJdwGSalwcGSy)(Dwa(EpDLILLflEbYc1bGSmHnleILI6nlEbYcP2kzh)kWB4H)Gf14qKarswm2cAh7SoSa18nJmDacvGq7Lj45RcMgJ9ROeqFnNMGNVkyaxT)hSiqVkCcBIOXQVyydEUk7DWRlKTwkQ3PICB2maHkqO9YGXwq7yN1HfObC1(FWIaKp2OHb91CAcE(QGPXy)k6MA6WayVoqtbZbqkVHgYcHmC2iDNLPYBKfyXYYILhYITz59Mi(uwSF)oC9SqQTs2XVcSOJxrKfxhUEwEiliHTUgzXlqwk4Zcea2b3Y6kI8gE4pyrnoejqKKL(Os5DEQ8g1CiAqH53BI4tJKCnFZiBC2iD31vO2)IX8dZGhUj5Aul1cvQ87nr8Pg6798AKGeQw3kh2XajAtRVMttWZxfmng7xr3K8XggIqFnNMGNVkywwJ4n0qwgpkYcPbQbSCtwUIEGilEXIgeuNffzXlqwuxHSCplllwSF)ololeILI6nlwnmWIxGSSvq36pailaT7DmVHh(dwuJdrcejzNRoAgoZOAvOMVzKyqDwu0Cv2ROAt7w5WogizyiIEv4e2erJvFXWg8Cv27GxxiBTuuVhPnT(Aonw9fdBWZvzVdEDHS1sr92aWvlKG2OXXgg0xZPj45RcMgJ9ROBQPJ0Mge(gh0T(daMP29ood6Xor08xGKRiomeracalVEtHHgQGn4Wa1cvQ87nr8PBAZiTP1xZPPDaybx08SXkfrnng7xrjykttstOPQxfoHnr0qVAUu59O0h7ZhPvFnNM2bGfCrZZgRue1SSggIqFnNM2bGfCrZZgRue1SSgPnDebiubcTxMGNVkywwdd6R50879PuzkIKGTH(EGecsUg1opI7FUXy)kkbTzSX0opI7FUXy)k6MKp2yddrqHlL(vGMFVpLktrKeSny56keCK20u4sPFfO537tPYuejbBdwUUcbhgcqOceAVmbpFvW0ySFfDtBp2iTV3eX38xmMFyg8Wn14WGoKs1opI7FUXy)kkbjFmEdnKLXJIS4Sa89E6kfl2If(7Sy1WalRsHuklaFVNUsXYrzXvn6GrzzzXcSzjkCXI3ilUoC9S8qwGaWo4wSSvkHG3Wd)blQXHibIKS037PRuA(MrQVMtdSWFNMTWoGw)blZYsBA91CAOV3txPmnoBKU76kCyWPF7QSf0o2BMYgBeVHgYITCfBXYwPecw0XjSrwifSaajbzX(97Sa89E6kflEbYYVJflaFVPRMiYB4H)Gf14qKarsw6790vknFZidqay51BQJ4(NNoQnI3vy9g6JkL3zW(MVblxxHGAtdW7Z1vOjalaqsWmisJwHHHaeQaH2ltWZxfmlRHb91CAcE(QGzznsBacvGq7LjalaqsW8VJzQ113tnng7xrjiXaOj2jCQc4Ps70VDv2cAhBYeaVpxxHg6mhG0FKw91CAOV3txPmng7xrjiHQncWEDGMcMdGuEdp8hSOghIeisYsFVPRMiQ5BgzacalVEtDe3)80rTPb4956k0eGfaijygePrRWWqacvGq7Lj45RcML1WG(AonbpFvWSSgPnaHkqO9YeGfaijy(3Xm1667PMgJ9ROeuJAb4956k0qFVNUsLTdRppDLkdNtTyqDwu0Cv2ROAJaG3NRRqZrSGnMPV30vte1gbyVoqtbZbqkVHgYY4rrwa(EtxnrKf73VZIxSylw4VZIvddSaBwUjlrHRTbzbca7GBXYwPecwSF)olrHRMLcj8ZsWPVHLTQOqwaxXwSSvkHGf)z53rwWcKf4KLFhzjLlw)E0Mf91CYYnzb4790vkwSdxkWA7NLPRuSaNtwGnlrHlw8gzbwSydlV3eXNYB4H)Gf14qKarsw67nD1ernFZi1xZPbw4VtZbf6DgWrpyzwwddPJG(EpVgnUvoSJbs0gbaVpxxHMJybBmtFVPRMiomKwFnNMGNVkyAm2VIsqnQvFnNMGNVkywwddPtRVMttWZxfmng7xrjiXaOj2jCQc4Ps70VDv2cAhBYeaVpxxHgknhG0FKw91CAcE(QGzznmOVMtt7aWcUO5zJvkIMPxnxQ8Eu6J95MgJ9ROeKya0e7eovb8uPD63UkBbTJnzcG3NRRqdLMdq6psR(AonTdal4IMNnwPiAME1CPY7rPp2NBwwJ0gGaWYR3aaRFpApAK20uluPYV3eXNAOV3txPiOThga4956k0qFVNUsLTdRppDLkdNZrJ0gbaVpxxHMJybBmtFVPRMiQnDe9QWjSjIM)Ir7WUYGn6X6xbI9Wa1cvQ87nr8Pg6790vkcA7r8gAilJhfzXwaclklxXcqOYBw0GG6SOilEbYc1bGSqAwkfl2cqyXYe2SqQTs2XVc8gE4pyrnoejqKKTq75yiS08nJmT(AonyqDwumtHkVnng7xr3ejmgwpM)lghgsh29MisJ0gTng29MiM)lgjOghnme29MisJ02J06w5WogiH3Wd)blQXHibIKS7UAMJHWsZ3mY06R50Gb1zrXmfQ820ySFfDtKWyy9y(VyCyiDy3BIinsB02yy3BIy(VyKGAC0Wqy3BIinsBpsRBLd7yGeTP1xZPPDaybx08SXkfrnng7xrjOg1QVMtt7aWcUO5zJvkIAwwAJOxfoHnr0qVAUu59O0h7ZhgIqFnNM2bGfCrZZgRue1SSgXB4H)Gf14qKars25sPYXqyP5BgzA91CAWG6SOyMcvEBAm2VIUjsymSEm)xmQnDacvGq7Lj45RcMgJ9ROBQXXggcqOceAVmbybascM)DmtTU(EQPXy)k6MACSrddPd7EtePrAJ2gd7EteZ)fJeuJJggc7EtePrA7rADRCyhdKOnT(AonTdal4IMNnwPiQPXy)kkb1Ow91CAAhawWfnpBSsruZYsBe9QWjSjIg6vZLkVhL(yF(Wqe6R500oaSGlAE2yLIOML1iEdnKLXJISqib1awGflKYwYB4H)Gf14qKarsw7E3hSZWzgvRc5n0qwiLRclL)iLf774VJnlpKLffzb4798AKLRybiu5nl23VWolhLf)zrJS8EteFkbiNLjSzbbGDuwSzmYelXo9XoklWMfcLfGV30vtezrdITG2XogRNf67bsO8gE4pyrnoejqKKfG3NRRqnxEmgj99EEnMVktHkV1maxTWiPwOsLFVjIp1qFVNxJBsOeyQGWoDStFSJMb4QfMkYhBmYKnJnIatfe2P1xZPH(EtxnrmJXwq7yhJ1NPqL3g67bsite6iEdnKfs5QWs5pszX(o(7yZYdzHqQ9FNfWvFfrwinnwPikVHh(dwuJdrcejzb4956kuZLhJrAV9FpFvE2yLIOAgGRwyKKtMOwOsL3D6Je0gnj9ygBsvAQfQu53BI4tn03751OMq(OuLMCc8UcR3qHlvgoZ)oMNWgPVblxxHGPICJghnIaJzixJPsFnNM2bGfCrZZgRue10ySFfL3qdzz8OilesT)7SCflaHkVzrdcQZIISaBwUjlfKfGV3ZRrwSFkflZ7z5QhYcP2kzh)kWIxrJHnYB4H)Gf14qKarsw7T)7A(MrMgdQZIIg1Q8oxiH)HbmOolkA8kAUqc)Ab4956k0C0CqHoaCK20V3eX38xmMFyg8Wnj0HbmOolkAuRY78vzBgg0HuQ25rC)Zng7xrji5JnAyqFnNgmOolkMPqL3MgJ9ROe0d)bld99EEnAqcJH1J5)IrT6R50Gb1zrXmfQ82SSggWG6SOO5QmfQ8wBea8(CDfAOV3ZRX8vzku59WG(AonbpFvW0ySFfLGE4pyzOV3ZRrdsymSEm)xmQncaEFUUcnhnhuOda1QVMttWZxfmng7xrjisymSEm)xmQvFnNMGNVkywwdd6R500oaSGlAE2yLIOMLLwaEFUUcn2B)3ZxLNnwPi6Wqea8(CDfAoAoOqhaQvFnNMGNVkyAm2VIUjsymSEm)xmYBOHSmEuKfGV3ZRrwUjlxXczSkVzrdcQZIIAMLRybiu5nlAqqDwuKfyXcHsawEVjIpLfyZYdzXQHbwacvEZIgeuNff5n8WFWIACisGijl99EEnYBOHSqACL637fVHh(dwuJdrcejz7vL9WFWkRo6R5YJXiNUs979I3G3qdzb47nD1erwMWMLyiamgRNLvPqkLLf9kISmo4wtnVHh(dwuZ0vQFVxrsFVPRMiQ5Bgze9QWjSjIgDx5vaZWz2vQ8VFfrQbT11zzHG8gAilKYPpl)oYci8zX(97S87ilXq6ZYFXilpKfheKLv9NILFhzj2jmlGR2)dwSCuw2V3WcWvnVgzPXy)kklXl1FwQdbz5HSe7FyNLyiSMxJSaUA)pyXB4H)Gf1mDL637fbIKS0vnVg1CiAqH53BI4tJKCnFZibHVjgcR51OPXy)k6Mng7xrtLn2qMixt5n8WFWIAMUs979Iars2yiSMxJ8g8gAilJhfzzRGU1FaqwaA37ywSVJfl)o2ilhLLcYIh(daYc1U3XAMfNYIYFKfNYIfKspDfYcSyHA37ywSF)ol2WcSzzI2XMf67bsOSaBwGflol2MaSqT7Dmluil)U)S87ilfANfQDVJzX7(aGuws5yrFw85Jnl)U)SqT7DmliHTUgP8gE4pyrn0psh0T(daMP29owZHObfMFVjIpnsY18nJmcq4BCq36payMA374mOh7erZFbsUIO2i8WFWY4GU1FaWm1U3Xzqp2jIMRYt1rC)1Mocq4BCq36payMA3748o6kZFbsUI4Wai8noOB9hamtT7DCEhDLPXy)k6MAC0Wai8noOB9hamtT7DCg0JDIOH(EGecABTGW34GU1FaWm1U3Xzqp2jIMgJ9ROe02AbHVXbDR)aGzQDVJZGESten)fi5kI8gAilJhfPSqkybascYYnzHuBLSJFfy5OSSSyb2SefUyXBKfqKgTcxrKfsTvYo(vGf73VZcPGfaijilEbYsu4IfVrw0rf0ole6yK12JLMuOcP)5kwaAD990rSSvkHGLRyXzH8XialumWIgeuNffnSSvffYciS2(zrHpl2Yg9y9RaXMfKWwxJAMfxz3JszzrrwUIfsTvYo(vGf73VZcHyPOEZIxGS4pl)oYc99(zbozXzzCWTMAwSFfi0UH3GaS4H)Gf1qFcejzdWcaKem)7yMAD99unFZiJaSxhOPG5aivB60a8(CDfAcWcaKemdI0OvqBebiubcTxMGNVkyA0bJQnIEv4e2erJvFXWg8Cv27GxxiBTuuVhg0xZPj45RcMLL20r0RcNWMiAS6lg2GNRYEh86czRLI69WqVkCcBIOjGkK(NRYuRRVNommpI7FUXy)k6MKBdPDyqhsPANhX9p3ySFfLGbiubcTxMGNVkyAm2VIsaYhByqFnNMGNVkyAm2VIUj52mAK20PD63UkBbTJnbJeG3NRRqtawaGKGzNAPnT(AonyqDwumRwL3MgJ9ROBs(ydd6R50Gb1zrXmfQ820ySFfDtYhB0WG(AonbpFvW0ySFfDtnQvFnNMGNVkyAm2VIsWij3MrAthrVkCcBIO5Vy0oSRmyJES(vGypmerVkCcBIOjGkK(NRYuRRVNomOVMtZFXODyxzWg9y9RaX20ySFfDtKWyy9y(VyC0WqVkCcBIOr3vEfWmCMDLk)7xrKosB6i6vHtyten6UYRaMHZSRu5F)kI0HH06R50O7kVcygoZUsL)9RisZL)Rgn03dKePMomOVMtJUR8kGz4m7kv(3VIin7DWl0qFpqsKA6Ordd6qkv78iU)5gJ9ROeK8X0gracvGq7Lj45RcMgDWOJ4n0qwgpkYcW3B6QjIS8qwibrlwwwS87il2Yg9y9RaXMf91CYYnz5EwSdxkqwqcBDnYIooHnYY8QJUFfrw(DKLcj8ZsWPplWMLhYc4k2IfDCcBKfsblaqsqEdp8hSOg6tGijl99MUAIOMVzK9QWjSjIM)Ir7WUYGn6X6xbIT20rKoT(Aon)fJ2HDLbB0J1VceBtJX(v0n9WFWYyV9F3GegdRhZ)fJeymd5AtJb1zrrZvzD4VpmGb1zrrZvzku59WaguNffnQv5DUqc)Jgg0xZP5Vy0oSRmyJES(vGyBAm2VIUPh(dwg6798A0GegdRhZ)fJeymd5AtJb1zrrZvz1Q8EyadQZIIgku5DUqc)ddyqDwu04v0CHe(hnAyic91CA(lgTd7kd2OhRFfi2ML1OHH06R50e88vbZYAyaG3NRRqtawaGKGzqKgTcJ0gGqfi0EzcWcaKem)7yMAD99utJoyuTbiaS86n1rC)Zth1MwFnNgmOolkMvRYBtJX(v0njFSHb91CAWG6SOyMcvEBAm2VIUj5JnAK20reGaWYR3qs0(8AyiaHkqO9YGXwq7yN1HfOPXy)k6MA6iEdnKfB5k2IfGV30vtePSy)(DwgNR8kGSaNSSvLILuVFfrklWMLhYIvJwEJSmHnlKcwaGKGSy)(DwghCRPM3Wd)blQH(eisYsFVPRMiQ5BgzVkCcBIOr3vEfWmCMDLk)7xrKQnDA91CA0DLxbmdNzxPY)(veP5Y)vJg67bs20MHb91CA0DLxbmdNzxPY)(vePzVdEHg67bs20MrAdqOceAVmbpFvW0ySFfDtsR2icqOceAVmbybascM)DmtTU(EQzznmKoabGLxVPoI7FE6O2aeQaH2ltawaGKG5FhZuRRVNAAm2VIsqYhtlguNffnxL9kQwN(TRYwq7yVPnJraBpwQcqOceAVmbpFvW0OdgD0iEdnKfsblW7pyXYe2S4kflGWNYYV7plXojiLf6Qrw(DmklEJ12plnoBKUJGSyFhlwiK5aWcUOSqAASsruw2DklkKsz539IfnYcfduwAm2V6kISaBw(DKfni2cAhBwghSazrFnNSCuwCD46z5HSmDLIf4CYcSzXROSObb1zrrwoklUoC9S8qwqcBDnYB4H)Gf1qFcejzb4956kuZLhJrcc)CJ266AmgRNQzaUAHrMwFnNM2bGfCrZZgRue10ySFfDtnomeH(AonTdal4IMNnwPiQzznsBe6R500oaSGlAE2yLIOz6vZLkVhL(yFUzzPnT(AonKCfyJGzm2cAh7yS(mwyt8sbAAm2VIsqIbqtSt4rAtRVMtdguNffZuOYBtJX(v0njganXoHhg0xZPbdQZIIz1Q820ySFfDtIbqtSt4HH0rOVMtdguNffZQv5TzznmeH(AonyqDwumtHkVnlRrAJ4DfwVHcv0)cOblxxHGJ4n0qwifSaV)Gfl)U)Se2XajuwUjlrHlw8gzbUE6bISGb1zrrwEilWsfLfq4ZYVJnYcSz5iwWgz53pkl2VFNfGqf9VaYB4H)Gf1qFcejzb4956kuZLhJrcc)mC90deZyqDwuuZaC1cJmDe6R50Gb1zrXmfQ82SS0gH(AonyqDwumRwL3ML1iTr8UcR3qHk6Fb0GLRRqqTr0RcNWMiA(lgTd7kd2OhRFfi28gAil2s4ZIRuS8EteFkl2VF)kwieEbIXxGf73VdxplqayhClRRisGFhzX1HaqwcWc8(dwuEdp8hSOg6tGijBmewZRrnhIguy(9Mi(0ijxZ3mY06R50Gb1zrXmfQ820ySFfDZgJ9ROdd6R50Gb1zrXSAvEBAm2VIUzJX(v0HbaEFUUcnGWpdxp9aXmguNffhPTXzJ0DxxHAFVjIV5Vym)Wm4HBsUnADRCyhdKOfG3NRRqdi8ZnARRRXySEkVHh(dwud9jqKKLUQ51OMdrdkm)EteFAKKR5BgzA91CAWG6SOyMcvEBAm2VIUzJX(v0Hb91CAWG6SOywTkVnng7xr3SXy)k6WaaVpxxHgq4NHRNEGygdQZIIJ024Sr6URRqTV3eX38xmMFyg8Wnj3gTUvoSJbs0cW7Z1vObe(5gT111ymwpL3Wd)blQH(eisYsFuP8opvEJAoenOW87nr8PrsUMVzKP1xZPbdQZIIzku5TPXy)k6Mng7xrhg0xZPbdQZIIz1Q820ySFfDZgJ9ROdda8(CDfAaHFgUE6bIzmOolkosBJZgP7UUc1(EteFZFXy(HzWd3KCYSw3kh2XajAb4956k0ac)CJ266AmgRNYBOHSylHpl9rC)zrhNWgzH00yLIOSCtwUNf7WLcKfxPG2zjkCXYdzPXzJ0DwuiLYc4QVIilKMgRueLL0)(rzbwQOSS7wwyrzX(97W1ZcWRMlfleYhL(yF(iEdp8hSOg6tGijlaVpxxHAU8ymYcM3JsFSppJERIMbHVMb4QfgzacalVEdaS(9OT2i6vHtyten0RMlvEpk9X(CTr0RcNWMiAcxhuygoZQBIzVaZGO)7AdqOceAVm6ytXMKRiAA0bJQnaHkqO9Y0oaSGlAE2yLIOMgDWOAJqFnNMGNVkywwAt70VDv2cAh7n1us7WG(Aon6kieuTOVzznI3Wd)blQH(eisYgdH18AuZ3msaEFUUcnfmVhL(yFEg9wfndcFTng7xrjOnJXB4H)Gf1qFcejzPRAEnQ5BgjaVpxxHMcM3JsFSppJERIMbHV2gJ9ROeK8ugVHgYY4rrwinWTWcSyjaYI973HRNLGBzDfrEdp8hSOg6tGij7e2bmdN5Y)vJA(Mr6w5WogiH3qdzz8OilAqSf0o2SmoybYI973zXROSOGfrwWcUiUZIYP)vezrdcQZIIS4filFhLLhYI6kKL7zzzXI973zHqSuuVzXlqwi1wj74xbEdp8hSOg6tGijlgBbTJDwhwGA(MrMoaHkqO9Ye88vbtJX(vucOVMttWZxfmGR2)dweOxfoHnr0y1xmSbpxL9o41fYwlf17urUnBgGqfi0EzWylODSZ6Wc0aUA)pyraYhB0WG(AonbpFvW0ySFfDtnDyaSxhOPG5aiL3qdzbi(uwSVJflBLsiyHUdxkqw0rwaxXwiilpKLc(SabGDWTyjTTeTWcKYcSyH0S6OSaNSObQvHS4fil)oYIgeuNffhXB4H)Gf1qFcejzb4956kuZLhJr6uRm4k2sZaC1cJ0PF7QSf0o2BMYgttsBJrJPsFnNM5QJMHZmQwfAOVhirtSjvyqDwu0CvwTkVhXBOHSmEuKfsTvYo(vGf73VZcPGfaijizt5DfyJGSa0667PS4filGWA7NfiaST33JSqiwkQ3SaBwSVJflJtbHGQf9zXoCPazbjS11il64e2ilKARKD8RaliHTUgPgwSfCsqwORgz5HSG1JnlolKXQ8MfniOolkYI9DSyzrpIflP2gnLfBScS4filUsXcPSLuwSFkfl6yagJS0OdgLfkewSGfCrCNfWvFfrw(DKf91CYIxGSacFkl7oaKfDelwOR58chwVkklnoBKUJGgEdp8hSOg6tGijlaVpxxHAU8ymYayoalW7pyLPVMb4QfgzeG96anfmhaPAtdW7Z1vOjaMdWc8(dwAJqFnNMGNVkywwAthbf)SoSwuZFyBJMMTXkmmGb1zrrZvz1Q8EyadQZIIgku5DUqc)J0MoDAaEFUUcno1kdUITggcqay51BQJ4(NNoomKoabGLxVHKO95L2aeQaH2ldgBbTJDwhwGMgDWOJgg6vHtyten)fJ2HDLbB0J1Vce7rAbHVHUQ51OPXy)k6MAQwq4BIHWAEnAAm2VIUzktBAq4BOpQuENNkVrtJX(v0njFSHHiExH1BOpQuENNkVrdwUUcbhPfG3NRRqZV3NsLPisc2z7(9AFVjIV5Vym)Wm4HBQVMttWZxfmGR2)dwPAmdPDyqFnNgDfecQw03SS0QVMtJUccbvl6BAm2VIsq91CAcE(QGbC1(FWIaPj3Mu1RcNWMiAS6lg2GNRYEh86czRLI69OrddPrBDDwwiObJTI2ORYWgS8kGAdqOceAVmySv0gDvg2GLxb00ySFfLGKtMjTeiTgtvVkCcBIOHE1CPY7rPp2NpA0iTPthracalVEtDe3)80XHH0a8(CDfAcWcaKemdI0OvyyiaHkqO9YeGfaijy(3Xm1667PMgJ9ROeKCnosB6i6vHtyten6UYRaMHZSRu5F)kI0HbN(TRYwq7ytqnoM2aeQaH2ltawaGKG5FhZuRRVNAA0bJoA0WW8iU)5gJ9ROemaHkqO9YeGfaijy(3Xm1667PMgJ9ROJgg0HuQ25rC)Zng7xrjO(AonbpFvWaUA)pyraYTjv9QWjSjIgR(IHn45QS3bVUq2APOEpI3qdzz8OilKMgRueLf73VZcP2kzh)kWYQuiLYcPPXkfrzXoCPazr50NffSiInl)UxSqQTs2XVcAMLFhlwwuKfDCcBK3Wd)blQH(eisY2oaSGlAE2yLIOA(MrQVMttWZxfmng7xr3KCnomOVMttWZxfmGR2)dwe0gslb6vHtytenw9fdBWZvzVdEDHS1sr9ovKBJwaEFUUcnbWCawG3FWktFEdp8hSOg6tGijBavi9pxLD1rSIX618nJeG3NRRqtamhGf49hSY0xBA91CAcE(QGbC1(FWAZiTH0sGEv4e2erJvFXWg8Cv27GxxiBTuuVtf52mmeracalVEdaS(9O9OHb91CAAhawWfnpBSsruZYsR(AonTdal4IMNnwPiQPXy)kkbtzeialW19gRgdhfZU6iwXy9M)IXmaxTqcKoc91CA0vqiOArFZYsBeVRW6n03BfSbny56keCeVHh(dwud9jqKK9QG3L)hS08nJeG3NRRqtamhGf49hSY0N3qdzjLR3NRRqwwueKfyXIRFQ7pKYYV7pl296z5HSOJSqDaiiltyZcP2kzh)kWcfYYV7pl)ogLfVX6zXUtFeKLuow0NfDCcBKLFhJ5n8WFWIAOpbIKSa8(CDfQ5YJXiPoampHDo45RcAgGRwyKbiubcTxMGNVkyAm2VIUj5JnmebaVpxxHMaSaajbZGinAf0gGaWYR3uhX9ppDCyaSxhOPG5aiL3qdzz8OiLfsdudy5MSCflEXIgeuNffzXlqw((qklpKf1vil3ZYYIf73VZcHyPOERzwi1wj74xbnZIgeBbTJnlJdwGS4filBf0T(daYcq7EhZB4H)Gf1qFcejzNRoAgoZOAvOMVzKyqDwu0Cv2ROAt70VDv2cAhBcMYSrt0xZPzU6Oz4mJQvHg67bssLghg0xZPPDaybx08SXkfrnlRrAtRVMtJvFXWg8Cv27GxxiBTuuVnaC1cjOne6ydd6R50e88vbtJX(v0n10rAb4956k0qDayEc7CWZxf0MoIaeawE9McdnubBWHbq4BCq36payMA374mOh7erZFbsUI4iTPJiabGLxVbaw)E0EyqFnNM2bGfCrZZgRue10ySFfLGPmnjnHMQEv4e2erd9Q5sL3JsFSpFKw91CAAhawWfnpBSsruZYAyic91CAAhawWfnpBSsruZYAK20reGaWYR3qs0(8AyiaHkqO9YGXwq7yN1HfOPXy)k6M2m2iTV3eX38xmMFyg8Wn14WGoKs1opI7FUXy)kkbjFmEdnKLXJISylw4VZcW37PRuSy1WaLLBYcW37PRuSC0A7NLLfVHh(dwud9jqKKL(EpDLsZ3ms91CAGf(70Sf2b06pyzwwA1xZPH(EpDLY04Sr6URRqEdnKfs5vavSa89wbBqwUjl3ZYUtzrHukl)UxSOrklng7xDfrnZsu4IfVrw8NLu2yeGLTsjeS4fil)oYsy1nwplAqqDwuKLDNYIgjaLLgJ9RUIiVHh(dwud9jqKKn4vavz91CQ5YJXiPV3kydQ5BgP(Aon03BfSbnng7xrjOg1MwFnNgmOolkMPqL3MgJ9ROBQXHb91CAWG6SOywTkVnng7xr3uJJ060VDv2cAh7ntzJXBOHSqkVcOILFhzHqSuuVzrFnNSCtw(DKfRggyXoCPaRTFwuxHSSSyX(97S87ilfs4NL)IrwifSaajbzjaJrklW5KLaOHLuVFuww0LRurzbwQOSS7wwyrzbC1xrKLFhzzCKHH3Wd)blQH(eisYg8kGQS(Ao1C5XyKw9fdBWZvzVdEDHS1sr9wZ3mY3vy9MRcEx(FWYGLRRqqTr8UcR3uO9CmewgSCDfcQnLV0PT9yJPjo9BxLTG2XMae6yAcf)SoSwuZFyBJMMTXkKkcDSrKP0ekzIAHkvE3PpostcqOceAVmbybascM)DmtTU(EQPXy)k6icMYx602ESX0eN(TRYwq7yRj6R50y1xmSbpxL9o41fYwlf1BdaxTqcqOJPju8Z6WArn)HTnAA2gRqQi0XgrMstOKjQfQu5DN(4injaHkqO9YeGfaijy(3Xm1667PMgJ9ROJ0gGqfi0EzcE(QGPXy)k6M2EmT6R50y1xmSbpxL9o41fYwlf1BdaxTqcAd5JPvFnNgR(IHn45QS3bVUq2APOEBa4QfUPThtBacvGq7LjalaqsW8VJzQ113tnng7xrjiHoM25rC)Zng7xr3maHkqO9YeGfaijy(3Xm1667PMgJ9ROeGmRnDVkCcBIOjGkK(NRYuRRVNomaW7Z1vOjalaqsWmisJwHr8gAilaXNYI9DSyHqSuuVzHUdxkqw0rwSAyiGGSGERIYYdzrhzX1vilpKLffzHuWcaKeKfyXsacvGq7flP1akfR)CLkkl6yagJuw(EHSCtwaxXwxrKLTsjeSuq7Sy)ukwCLcANLOWflpKflSNy4vrzbRhBwielf1Bw8cKLFhlwwuKfsblaqsWr8gE4pyrn0NarswaEFUUc1C5XyKwnmKTwkQ3z0BvundWvlmYaeawE9M6iU)5PJA7vHtytenw9fdBWZvzVdEDHS1sr9wR(Aonw9fdBWZvzVdEDHS1sr92aWvlKao9BxLTG2XMa2EZiT9yJPfG3NRRqtawaGKGzqKgTcAdqOceAVmbybascM)DmtTU(EQPXy)kkbD63UkBbTJnzY2JLkIbqtStyTra2Rd0uWCaKQfdQZIIMRYEfvRt)2vzlODS3eG3NRRqtawaGKGzNAPnaHkqO9Ye88vbtJX(v0n1iVHgYY4rrwa(EpDLIf73VZcWhvkVzXw238zb2S82OPSqOwbw8cKLcYcW3BfSb1ml23XILcYcW37PRuSCuwwwSaBwEilwnmWcHyPOEZI9DSyX1HaqwszJXYwPeI0WMLFhzb9wfLfcXsr9MfRggybG3NRRqwoklFVWrSaBwCql)pailu7EhZYUtzrtjafduwAm2V6kISaBwoklxXYuDe3FEdp8hSOg6tGijl99E6kLMVzKPFxH1BOpQuENb7B(gSCDfcomqXpRdRf18h22OPzc1kmsBeVRW6n03BfSbny56keuR(Aon037PRuMgNns3DDfQnIEv4e2erZFXODyxzWg9y9RaXwBA91CAS6lg2GNRYEh86czRLI6TbGRw4MrAJghtBe6R50e88vbZYsBAaEFUUcno1kdUITgg0xZPHKRaBemJXwq7yhJ1NXcBIxkqZYAyaG3NRRqJvddzRLI6Dg9wfD0Wq6aeawE9McdnubBqTVRW6n0hvkVZG9nFdwUUcb1Mge(gh0T(daMP29ood6Xor00ySFfDtnDyWd)blJd6w)baZu7EhNb9yNiAUkpvhX9F0OrAthGqfi0EzcE(QGPXy)k6MKp2WqacvGq7LjalaqsW8VJzQ113tnng7xr3K8XgXBOHSylxXwuw2kLqWIooHnYcPGfaijill6vez53rwifSaajbzjalW7pyXYdzjSJbsy5MSqkybascYYrzXd)YvQOS46W1ZYdzrhzj40N3Wd)blQH(eisYsFVPRMiQ5BgjaVpxxHgRggYwlf17m6TkkVHgYY4rrwSfGWIYI9DSyjkCXI3ilUoC9S8qY6nYsWTSUIilHDVjIuw8cKLyNeKf6Qrw(DmklEJSCflEXIgeuNffzH(NsXYe2SqiVTazjn2c8gE4pyrn0Nars2cTNJHWsZ3ms3kh2XajAth29MisJ0gTng29MiM)lgjOghgc7EtePrA7r8gE4pyrn0Nars2DxnZXqyP5BgPBLd7yGeTPd7EtePrAJ2gd7EteZ)fJeuJddHDVjI0iT9iTP1xZPbdQZIIz1Q820ySFfDtKWyy9y(VyCyqFnNgmOolkMPqL3MgJ9ROBIegdRhZ)fJJ4n8WFWIAOpbIKSZLsLJHWsZ3ms3kh2XajAth29MisJ0gTng29MiM)lgjOghgc7EtePrA7rAtRVMtdguNffZQv5TPXy)k6MiHXW6X8FX4WG(AonyqDwumtHkVnng7xr3ejmgwpM)lghXBOHSmEuKfGV30vtezXwSWFNfRggOS4filGRylw2kLqWI9DSyHuBLSJFf0mlAqSf0o2SmoybQzw(DKLuUy97rBw0xZjlhLfxhUEwEiltxPyboNSaBwIcxBdYsWTyzRucbVHh(dwud9jqKKL(EtxnruZ3msmOolkAUk7vuTP1xZPbw4VtZbf6DgWrpyzwwdd6R50qYvGncMXylODSJX6ZyHnXlfOzznmOVMttWZxfmllTPJiabGLxVHKO951WqacvGq7LbJTG2XoRdlqtJX(v0n14WG(AonbpFvW0ySFfLGedGMyNWPAQGWoTt)2vzlODSjta8(CDfAO0Cas)rJ0MoIaeawE9gay97r7Hb91CAAhawWfnpBSsrutJX(vucsmaAIDcNQaEQ0PD63UkBbTJnbi0Xs17kSEZC1rZWzgvRcny56keCezcG3NRRqdLMdq6pIa2ovVRW6nfAphdHLblxxHGAJOxfoHnr0qVAUu59O0h7Z1QVMtt7aWcUO5zJvkIAwwdd6R500oaSGlAE2yLIOz6vZLkVhL(yFUzznmKwFnNM2bGfCrZZgRue10ySFfLGE4pyzOV3ZRrdsymSEm)xmQLAHkvE3PpsWXme6WG(AonTdal4IMNnwPiQPXy)kkb9WFWYyV9F3GegdRhZ)fJdda8(CDfAoBfmhGf49hS0gGqfi0EzUIg6176kmBRlV(vCgebCb00OdgvlARRZYcbnxrd96DDfMT1Lx)kodIaUaosR(AonTdal4IMNnwPiQzznmeH(AonTdal4IMNnwPiQzzPnIaeQaH2lt7aWcUO5zJvkIAA0bJoAyaG3NRRqJtTYGRyRHbDiLQDEe3)CJX(vucsmaAIDcNQaEQ0o9BxLTG2XMmbW7Z1vOHsZbi9hnI3qdzj1DuwEilXojil)oYIosFwGtwa(ERGnil6rzH(EGKRiYY9SSSyXwxxGevuwUIfVIYIgeuNffzrF9SqiwkQ3SC0A7NfxhUEwEil6ilwnmeqqEdp8hSOg6tGijl99MUAIOMVzKVRW6n03BfSbny56keuBe9QWjSjIM)Ir7WUYGn6X6xbIT206R50qFVvWg0SSggC63UkBbTJ9MPSXgPvFnNg67Tc2Gg67bsiOT1MwFnNgmOolkMPqL3ML1WG(AonyqDwumRwL3ML1iT6R50y1xmSbpxL9o41fYwlf1BdaxTqcAdPDmTPdqOceAVmbpFvW0ySFfDtYhByicaEFUUcnbybascMbrA0kOnabGLxVPoI7FE64iEdnKfnG(xS)iLLDODwIxHDw2kLqWI3ile9RqqwSWMfkgGfOHfBXsfLL3jbPS4Sql3IUdFwMWMLFhzjS6gRNf69l)pyXcfYID4sbwB)SOJS4HWQ9hzzcBwuEteBw(lgNThJuEdp8hSOg6tGijlaVpxxHAU8ymsNAriWgig0maxTWiXG6SOO5QSAvENknLm5H)GLH(EpVgniHXW6X8FXibIadQZIIMRYQv5DQstMjW7kSEdfUuz4m)7yEcBK(gSCDfcMkBpIm5H)GLXE7)UbjmgwpM)lgjWygcvJKjQfQu5DN(ibgZOXu9UcR3u(VAKM1DLxb0GLRRqqEdnKfB5k2IfGV30vtez5kw8IfniOolkYItzHcHfloLfliLE6kKfNYIcwezXPSefUyX(PuSGfilllwSF)olA6yeGf77yXcwp2xrKLFhzPqc)SObb1zrrnZciS2(zrHpl3ZIvddSqiwkQ3AMfqyT9Zcea2277rw8IfBXc)DwSAyGfVazXccvSOJtyJSqQTs2XVcS4filAqSf0o2SmoybYB4H)Gf1qFcejzPV30vte18nJmIEv4e2erZFXODyxzWg9y9RaXwBA91CAS6lg2GNRYEh86czRLI6TbGRwibTH0o2WG(Aonw9fdBWZvzVdEDHS1sr92aWvlKG2OXX0(UcR3qFuP8od238ny56keCK20yqDwu0CvMcvER1PF7QSf0o2eaG3NRRqJtTieydedPsFnNgmOolkMPqL3MgJ9ROeae(M5QJMHZmQwfA(lqcn3ySFvQSXOXn10XggWG6SOO5QSAvER1PF7QSf0o2eaG3NRRqJtTieydedPsFnNgmOolkMvRYBtJX(vucacFZC1rZWzgvRcn)fiHMBm2Vkv2y04MPSXgPnc91CAGf(70Sf2b06pyzwwAJ4DfwVH(ERGnOblxxHGAthGqfi0EzcE(QGPXy)k6MK2HbkCP0Vc0879PuzkIKGTblxxHGA1xZP537tPYuejbBd99aje022wts3RcNWMiAOxnxQ8Eu6J95PYMrANhX9p3ySFfDtYhBmTZJ4(NBm2VIsqBgBSHbWEDGMcMdG0rAthracalVEdjr7ZRHHaeQaH2ldgBbTJDwhwGMgJ9ROBAZiEdnKLXJISylaHfLLRyXROSObb1zrrw8cKfQdazHqExnjaPzPuSylaHfltyZcP2kzh)kWIxGSKY7kWgbzrdITG2XogR3WYwvuillkYYwSfyXlqwin2cS4pl)oYcwGSaNSqAASsruw8cKfqyT9ZIcFwSLn6X6xbInltxPyboN8gE4pyrn0Nars2cTNJHWsZ3ms3kh2XajAb4956k0qDayEc7CWZxf0MwFnNgmOolkMvRYBtJX(v0nrcJH1J5)IXHb91CAWG6SOyMcvEBAm2VIUjsymSEm)xmoI3Wd)blQH(eisYU7QzogclnFZiDRCyhdKOfG3NRRqd1bG5jSZbpFvqBA91CAWG6SOywTkVnng7xr3ejmgwpM)lghg0xZPbdQZIIzku5TPXy)k6MiHXW6X8FX4iTP1xZPj45RcML1WG(Aonw9fdBWZvzVdEDHS1sr92aWvlKGrAd5JnsB6icqay51BaG1VhThg0xZPPDaybx08SXkfrnng7xrjyAnQj2KQEv4e2erd9Q5sL3JsFSpFKw91CAAhawWfnpBSsruZYAyic91CAAhawWfnpBSsruZYAK20r0RcNWMiA(lgTd7kd2OhRFfi2ddiHXW6X8FXib1xZP5Vy0oSRmyJES(vGyBAm2VIomeH(Aon)fJ2HDLbB0J1VceBZYAeVHh(dwud9jqKKDUuQCmewA(Mr6w5WogirlaVpxxHgQdaZtyNdE(QG206R50Gb1zrXSAvEBAm2VIUjsymSEm)xmomOVMtdguNffZuOYBtJX(v0nrcJH1J5)IXrAtRVMttWZxfmlRHb91CAS6lg2GNRYEh86czRLI6TbGRwibJ0gYhBK20reGaWYR3qs0(8AyqFnNgsUcSrWmgBbTJDmwFglSjEPanlRrAthracalVEdaS(9O9WG(AonTdal4IMNnwPiQPXy)kkb1Ow91CAAhawWfnpBSsruZYsBe9QWjSjIg6vZLkVhL(yF(Wqe6R500oaSGlAE2yLIOML1iTPJOxfoHnr08xmAh2vgSrpw)kqShgqcJH1J5)IrcQVMtZFXODyxzWg9y9RaX20ySFfDyic91CA(lgTd7kd2OhRFfi2ML1iEdnKLXJISqib1awGflbqEdp8hSOg6tGijRDV7d2z4mJQvH8gAilJhfzb4798AKLhYIvddSaeQ8MfniOolkQzwi1wj74xbw2DklkKsz5VyKLF3lwCwiKA)3zbjmgwpYIcNplWMfyPIYczSkVzrdcQZIISCuwwwgwiKUFNLuBJMYInwbwW6XMfNfGqL3SObb1zrrwUjleILI6nl0)ukw2DklkKsz539IfBiFmwOVhiHYIxGSqQTs2XVcS4filKcwaGKGSS7aqwIHnYYV7flKtAPSqkBjlng7xDfrdlJhfzX1HaqwSrJJrMyz3PpYc4QVIilKMgRueLfVazXgBSHmXYUtFKf73VdxplKMgRueL3Wd)blQH(eisYsFVNxJA(MrIb1zrrZvz1Q8wBe6R500oaSGlAE2yLIOML1WaguNffnuOY7CHe(hgsJb1zrrJxrZfs4FyqFnNMGNVkyAm2VIsqp8hSm2B)3niHXW6X8FXOw91CAcE(QGzznsB6iO4N1H1IA(dBB00SnwHHHEv4e2erJvFXWg8Cv27GxxiBTuuV1QVMtJvFXWg8Cv27GxxiBTuuVnaC1cjOnKpM2aeQaH2ltWZxfmng7xr3KCsR20reGaWYR3uhX9ppDCyiaHkqO9YeGfaijy(3Xm1667PMgJ9ROBsoPDK20r0EanFdvQHHaeQaH2lJo2uSj5kIMgJ9ROBsoPD0OHbmOolkAUk7vuTP1xZPXU39b7mCMr1QqZYAyGAHkvE3PpsWXmeQg1MoIaeawE9gay97r7HHi0xZPPDaybx08SXkfrnlRrddbiaS86naW63J2APwOsL3D6JeCmdHoI3qdzz8OilesT)7Sa)DSTFuKf77xyNLJYYvSaeQ8MfniOolkQzwi1wj74xbwGnlpKfRggyHmwL3SObb1zrrEdp8hSOg6tGijR92)DEdnKfsJRu)EV4n8WFWIAOpbIKS9QYE4pyLvh91C5XyKtxP(9EL8jFsc]] )
    

end