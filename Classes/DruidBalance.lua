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

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
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
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
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
            duration = 10,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
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
            duration = 10,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
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
        thrash_cat ={
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 1,
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
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
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
            id = 236696,
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
            duration = 5,
            max_stack = 1
        },

        balance_of_all_things_nature = {
            id = 339943,
            duration = 5,
            max_stack = 1,
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

    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end

        if buff.warrior_of_elune.up then
            setCooldown( "warrior_of_elune", 3600 )
        end

        -- Eclipses
        solar_eclipse = buff.eclipse_lunar.up and 2 or GetSpellCount( 197628 )
        lunar_eclipse = buff.eclipse_solar.up and 2 or GetSpellCount( 5176 )

        buff.eclipse_solar.empowerTime = 0
        buff.eclipse_lunar.empowerTime = 0

        if buff.eclipse_solar.up and action.starsurge.lastCast > buff.eclipse_solar.applied then buff.eclipse_solar.empowerTime = action.starsurge.lastCast end
        if buff.eclipse_lunar.up and action.starsurge.lastCast > buff.eclipse_lunar.applied then buff.eclipse_lunar.empowerTime = action.starsurge.lastCast end
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


    spec:RegisterStateTable( "eclipse", setmetatable( {}, {
        __index = function( t, k )
            -- any_next
            if k == "any_next" then
                return lunar_eclipse == 2 and solar_eclipse == 2
            -- in_any
            elseif k == "in_any" then
                return buff.eclipse_lunar.up or buff.eclipse_solar.up
            -- in_solar
            elseif k == "in_solar" then
                return buff.eclipse_solar.up
            -- in_lunar
            elseif k == "in_lunar" then
                return buff.eclipse_lunar.up
            -- in_both
            elseif k == "in_both" then
                return buff.eclipse_lunar.up and buff.eclipse_solar.up
            -- solar_next
            elseif k == "solar_next" then
                return solar_eclipse > 0
            -- solar_in
            elseif k == "solar_in" then
                return solar_eclipse
            -- solar_in_2
            elseif k == "solar_in_2" then
                return solar_eclipse == 2
            -- solar_in_1
            elseif k == "solar_in_1" then
                return solar_eclipse == 1
            -- lunar_next
            elseif k == "lunar_next" then
                return lunar_eclipse > 0
            -- lunar_in
            elseif k == "lunar_in" then
                return lunar_eclipse > 0
            -- lunar_in_2
            elseif k == "lunar_in_2" then
                return lunar_eclipse == 2
            -- lunar_in_1
            elseif k == "lunar_in_1" then
                return lunar_eclipse == 1
            end
        end
    } ) )



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
                stat.haste = stat.haste + 0.15

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },


        cyclone = {
            id = 33786,
            cast = 1.7,
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
            cast = 1.7,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 25,
            recharge = 25,
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
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                if talent.starlord.enabled then
                    if buff.starlord.stack < 3 then stat.haste = stat.haste + 0.04 end
                    addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
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
                if buff.warrior_of_elune.up or buff.elunes_wrath.up then return 0 end
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

                if buff.eclipse_lunar.down and solar_eclipse > 0 then
                    solar_eclipse = solar_eclipse - 1
                    if solar_eclipse == 0 then
                        applyBuff( "eclipse_solar" )
                        if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_nature" ) end
                        if talent.solstice.enabled then applyBuff( "solstice" ) end
                    end
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

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.1 ) ) end,
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

                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time end

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if azerite.arcanic_pulsar.enabled then
                    addStack( "arcanic_pulsar" )
                    if buff.arcanic_pulsar.stack == 9 then
                        removeBuff( "arcanic_pulsar" )
                        applyBuff( talent.incarnation.enabled and "incarnation" or "celestial_alignment" )
                    end
                end

                if legendary.timeworn_dreambinder.enabled then
                    addStack( "timeworn_dreambinder", nil, 1 )
                end

                -- TODO:  Needs Review.
                if eclipse.in_any then applyBuff( "starsurge_empowerment" ) end
            end,

            auras = {
                starsurge_empowerment = {
                    duration = 3600,
                    max_stack = 30,
                    generate = function( t )
                        local last = action.starsurge.lastCast

                        t.name = "Starsurge Empowerment"

                        if eclipse.in_any then
                            t.applied = last
                            t.duration = max( buff.eclipse_lunar.remains, buff.eclipse_solar.remains )
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
                    end
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
            id = 236696,
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
            texture = 538771,

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

            ap_check = function() return check_for_ap_overcap( "solar_wrath" ) end,

            handler = function ()
                if not buff.moonkin_form.up then unshift() end

                if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then
                        applyBuff( "eclipse_lunar" )
                        if legendary.balance_of_all_things.enabled then applyBuff( "balance_of_all_things_arcane" ) end
                        if talent.solstice.enabled then applyBuff( "solstice" ) end
                    end
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

        potion = "unbridled_fury",

        package = "Balance",
    } )


    spec:RegisterSetting( "starlord_cancel", false, {
        name = "Cancel |T462651:0|t Starlord",
        desc = "If checked, the addon will recommend canceling your Starlord buff before starting to build stacks with Starsurge again.\n\n" ..
            "You will likely want a |cFFFFD100/cancelaura Starlord|r macro to manage this during combat.",
        icon = 462651,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "toggle",
        width = 1.5
    } )


    -- Starlord Cancel Override
    class.specs[0].abilities.cancel_buff.funcs.usable = setfenv( function ()
        if not settings.starlord_cancel and args.buff_name == "starlord" then return false, "starlord cancel option disabled" end
        return args.buff_name ~= nil, "no buff name detected"
    end, state )


    spec:RegisterPack( "Balance", 20201101, [[dC0WRdqiQcpIQOuxsfkBceFckqAuuLofvLvrveVsimlvKULqsSlc)svfdtvvhdkAzcrptfY0Gc6AQQ02uHQ(gvr14Gc4CufP1rvumpuvDpvW(qv5GufL0crv4Hcj1eHcuYfHcuQpcfO4KqbQwPqQzQcv2PkIHcfiSuQIs8uHAQqH(kuGO9Qs)LObR0HjTyk5XOmzO6YiBwWNbPrdLoTuVwf1SPYTPu7wXVHmCqDCHK0YL8CkMoW1vLTRQ8DQQgpQIopQsRxiX8rL9l6lMxmEJXvaDpjY)r(htm)FKiYJ()hdp(BmGxy6gdRSZku6gpQnDJ5H60Hr3yyLxhsXVy8gBqVIr3ySaaSXZ8ZpqBa2NLGHS)X02pNcA0Wkna(X02SFUXwV2bWGpxRBmUcO7jr(pY)yI5)JerE0))yyK3y9bWIQBCCBh13ySnoonxRBmozy3yp7C5H60Hr5IbR614z0E25Ec6JSTOkxmpn3i)h5)m6mAp7CJAS6aLmEMmAp7CJk56zfhNWZng50kxEqQTiJ2Zo3OsUrnwDGs45c0ckbKDixMAitUauUmEzosc0ckbmImAp7CJk56zHSrFeEUVzigzmAXBUFA1QLJm56TfK40CHl6tAaAzEfuk3OcF5cx0NWa0Y8kOKpXn21gG5IXBmCrmKTLcUy8EcMxmEJvgOrZn2gHMZ9idOY(gtJA5i8lpUG7jrEX4nwzGgn3y)LcWEJPrTCe(LhxW9KJUy8gRmqJMBS)sbyVX0Owoc)YJl4EcgEX4nwzGgn3ydqRqx0nMg1Yr4xECb3t(9IXBmnQLJWV84gJGVXgcCJvgOrZn(tRwTC0n(tDp6gBHmMCHKBWHqvUEZ1BUHgkwGSiBThtUrLCJ8FU(Y9NCXmY)56lx(Yn4qOkxV56n3qdflqwKT2Jj3OsUr(BUrLC9MlM)Z1tYfOoAaIEyAnkOrJGg1Yr456l3OsUEZfdZ1tYLHg8xdeWfXAdjvxdDSPbiOrTCeEU(Y1xU)KlMyG)567g)PLCuB6gZqZh6mjXjdVd7cUGBSfsbxmEpbZlgVX0Owoc)YJBmRAavTEJTEHGGPYEyIh8nwzGgn34s)Ob9mYqrtu49cUNe5fJ3yAulhHF5XngbFJne4gRmqJMB8NwTA5OB8N6E0n2JCTEHGWsD6WijkivNtcW2duJCuWRiXdoxi56rUwVqqyPoDyKefKQZjby7bQrQfths8GVXFAjh1MUXSQbdc8GVG7jhDX4nMg1Yr4xECJvgOrZnwXvyq)rsJFTSVXSQbu16n26fccl1PdJKOGuDojaBpqnYrbVIegGYol)u3JYL)CXW)5cjxRxiiSuNomsIcs15KaS9a1i1IPdjmaLDw(PUhLl)5IH)ZfsUEZ1JCXraHIRWG(JKg)AzlXvBfkjan7CpqZfsUEKRYanAekUcd6psA8RLTexTvOKOhzW1qXcYfsUEZ1JCXraHIRWG(JKg)AzlXsQtaA25EGMlhxU4iGqXvyq)rsJFTSLyj1jkYw7XKlF5EuU(YLJlxCeqO4kmO)iPXVw2sC1wHscdqzNZL)Cpkxi5IJacfxHb9hjn(1YwIR2kusuKT2Jjx(Z93CHKlociuCfg0FK04xlBjUARqjbOzN7bAU(UXmEzosc0ckbm3tW8cUNGHxmEJPrTCe(Lh3yw1aQA9g7nxRxiiSuNomsIcs15KaS9a1ihf8ksuKT2Jjx(Yfdf)MlhxUwVqqyPoDyKefKQZjby7bQrQfthsuKT2Jjx(Yfdf)MRVCHKRAaL6KWi)uLlFhY1t)NlKC9MldHC4i)JGPYEyIIS1Em5YxUEEUCC56nxgc5Wr(hbzdJ8tL0cn4IIS1Em5YxUEEUqY1JCTEHG4Cp4fHljByKFQSPbiPHkODuiXdoxi5YqF0OdqCM3Q1jxF567gRmqJMBmthg5KwVq4gB9cb5O20n2a0YHk8l4EYVxmEJPrTCe(Lh3yw1aQA9g7rUFA1QLJeSQbdc8GZfsUEZ1BUEKldHC4i)JGHMp0zscWssdCxnWiEW5YXLRh5(PvRwosWqZh6mjzObVbnAYLJlxpYLH(OrhGyAOybYGs56lxi56nxg6JgDaIPHIfidkLlhxUEZLHqoCK)rWuzpmrr2ApMC5lxppxoUC9MldHC4i)JGSHr(PsAHgCrr2ApMC5lxppxi56rUwVqqCUh8IWLKnmYpv20aK0qf0okK4bNlKCzOpA0bioZB16KRVC9LRVC9LlhxUEZLHqoCK)rWqZh6mjbyjPbURgyep4CHKldHC4i)JGPYEyIIuCEZfsUm0hn6aetdflqgukxF3yLbA0CJnaTmVckDb3to(lgVX0Owoc)YJBSYanAUXM3e6IUXSQbu16nUOqrgSQLJYfsUaTGsabOTjjajXBkx(YfZJpxi5QWsgwIDoxi56n3pTA1Yrcw1GbbEW5YXLR3CvdOuNeg5NQC5p3J(NlKC9ixRxiiyQShM4bNRVC54YLHqoCK)rWuzpmrrkoV567gZ4L5ijqlOeWCpbZl4EINFX4nMg1Yr4xECJvgOrZn2gHMqx0nMvnGQwVXffkYGvTCuUqYfOfuciaTnjbijEt5YxUyEK43CHKRclzyj25CHKR3C)0Qvlhjyvdge4bNlhxUEZvnGsDsyKFQYL)Cp6FUqY1JCTEHGGPYEyIhCU(YLJlxgc5Wr(hbtL9WefP48MRVCHKRh5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIh8nMXlZrsGwqjG5EcMxW9emWfJ3yAulhHF5XnwzGgn3ydGCoTKbNw0nMvnGQwVXffkYGvTCuUqYfOfuciaTnjbijEt5YxUyE85grUfzR9yYfsUkSKHLyNZfsUEZ9tRwTCKGvnyqGhCUCC5QgqPojmYpv5YFUh9pxoUCziKdh5Femv2dtuKIZBU(UXmEzosc0ckbm3tW8cUN4PxmEJPrTCe(Lh3yw1aQA9gRWsgwID(gRmqJMBCavmsIcYrbVIUG7jy()IXBmnQLJWV84gZQgqvR3yV5smxdBirpsD4nxoUCjMRHnKWGCAj7rIzUCC5smxdBiH7nAj7rIzU(YfsUEZ1JCzOpA0biMgkwGmOuUCC56nx1ak1jHr(Pkx(Z1t)nxi56n3pTA1Yrcw1GbbEW5YXLRAaL6KWi)uLl)5E0)C54Y9tRwTCKOnsfr56lxi56n3pTA1YrcgA(qNjjoz4Dy5cjxpYLHqoCK)rWqZh6mjbyjPbURgyep4C54Y1JC)0QvlhjyO5dDMK4KH3HLlKC9ixgc5Wr(hbtL9Wep4C9LRVC9LlKC9MldHC4i)JGPYEyIIS1Em5YxUh9pxoUCvdOuNeg5NQC5lxp9FUqYLHqoCK)rWuzpmXdoxi56nxgc5Wr(hbzdJ8tL0cn4IIS1Em5YFUkd0OryaAf6Ieepj2dqsqBt5YXLRh5YqF0OdqCM3Q1jxF5YXLBOHIfilYw7XKl)5I5)C9LlKC9MlociuCfg0FK04xlBjUARqjrr2ApMC5lxmmxoUC9ixg6JgDaIHyfYHk8C9DJvgOrZno8kELOGKCVHUG7jyI5fJ3yAulhHF5XnMvnGQwVXEZLyUg2qc3B0soepb5YXLlXCnSHegKtl5q8eKlhxUeZ1WgsOdVYH4jixoUCTEHGWsD6WijkivNtcW2duJCuWRirr2ApMC5lxmu8BUCC5A9cbHL60HrsuqQoNeGThOgPwmDirr2ApMC5lxmu8BUCC5QgqPojmYpv5YxUE6)CHKldHC4i)JGPYEyIIuCEZ1xUqY1BUmeYHJ8pcMk7HjkYw7XKlF5E0)C54YLHqoCK)rWuzpmrrkoV56lxoUCdnuSazr2ApMC5pxm)FJvgOrZn(Cp4fHlnWD1aZfCpbZiVy8gtJA5i8lpUXSQbu16n2BUQbuQtcJ8tvU8LRN(pxi56nxRxiio3dEr4sYgg5NkBAasAOcAhfs8GZLJlxpYLH(OrhG4mVvRtU(YLJlxg6JgDaIPHIfidkLlhxUwVqqy5qiC3Zaep4CHKR1leewoec39marr2ApMC5p3i)NBe56nxmmxpjxgAWFnqaxeRnKuDn0XMgGGg1Yr456lxF5cjxV56rUm0hn6aetdflqgukxoUCziKdh5Fem08HotsawsAG7QbgXdoxoUCdnuSazr2ApMC5pxgc5Wr(hbdnFOZKeGLKg4UAGruKT2Jj3iY94ZLJl3qdflqwKT2Jj3JLlMyG)5YFUr(p3iY1BUyyUEsUm0G)AGaUiwBiP6AOJnnabnQLJWZ1xU(UXkd0O5gZihzaT6KQRHo20aUG7jyE0fJ3yAulhHF5XnMvnGQwVXEZvnGsDsyKFQYLVC90)5cjxV5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC56rUm0hn6aeN5TADY1xUCC5YqF0OdqmnuSazqPC54Y16fcclhcH7EgG4bNlKCTEHGWYHq4UNbikYw7XKl)5E0)CJixV5IH56j5Yqd(Rbc4IyTHKQRHo20ae0OwocpxF56lxi56nxpYLH(OrhGyAOybYGs5YXLldHC4i)JGHMp0zscWssdCxnWiEW5YXL7NwTA5ibdnFOZKeNm8oSCHKBOHIfilYw7XKlF5Ijg4FUrKBK)ZnIC9MlgMRNKldn4VgiGlI1gsQUg6ytdqqJA5i8C9LlhxUHgkwGSiBThtU8NldHC4i)JGHMp0zscWssdCxnWikYw7XKBe5E85YXLBOHIfilYw7XKl)5E0)CJixV5IH56j5Yqd(Rbc4IyTHKQRHo20ae0OwocpxF567gRmqJMBCpmTgf0O5cUNGjgEX4nMg1Yr4xECJzvdOQ1BS3C)0QvlhjyO5dDMK4KH3HLlKCdnuSazr2ApMC5lxmp6FUCC5A9cbbtL9Wep4C9LlKC9MR1leewQthgjrbP6Csa2EGAKJcEfjmaLDw(PUhLlF5E0)C54Y16fccl1PdJKOGuDojaBpqnsTy6qcdqzNLFQ7r5YxUh9pxF5YXLBOHIfilYw7XKl)5I5)BSYanAUXm08HotsawsAG7QbMl4EcM)EX4nMg1Yr4xECJzvdOQ1Bmd9rJoaX0qXcKbLYfsUEZ9tRwTCKGHMp0zsItgEhwUCC5YqihoY)iyQShMOiBThtU8NlM)Z1xUqYvnGsDsyKFQYLVC)9FUqYLHqoCK)rWqZh6mjbyjPbURgyefzR9yYL)CX8)nwzGgn3ydqlZRGsxW9emp(lgVX0Owoc)YJBmc(gBiWnwzGgn34pTA1Yr34p19OBmXCnSHe9iDVrRC9KCXa5(tUkd0OryaAf6Ieepj2dqsqBt5grUEKlXCnSHe9iDVrRC9KCp(C)jxLbA0i8xkaRG4jXEascABk3iY9ViYC)jxdm5CsSQbq34pTKJAt3y1aJbbvXe7cUNGPNFX4nMg1Yr4xECJzvdOQ1BS3C7bqfmYPacxgAOybYIS1Em5YFUyyUCC56nxRxiik9Jg0ZidfnrHxrr2ApMC5pxOmCHTYZC9KCzu7Y1BUQbuQtcJ8tvU)K7r)Z1xUqY16fcIs)Ob9mYqrtu4v8GZ1xU(YLJlxV5QgqPojmYpv5grUFA1QLJeQbgdcQIjwUEsUwVqqqmxdBiPb50suKT2Jj3iYfhbeHxXRefKK7nKa0SZgzr2Ap56j5gP43C5lxmJ8FUCC5QgqPojmYpv5grUFA1QLJeQbgdcQIjwUEsUwVqqqmxdBiP7nAjkYw7XKBe5IJaIWR4vIcsY9gsaA2zJSiBTNC9KCJu8BU8LlMr(pxF5cjxI5Aydj6rQdV5cjxV56nxpYLHqoCK)rWuzpmXdoxoUCzOpA0bioZB16KlKC9ixgc5Wr(hbzdJ8tL0cn4IhCU(YLJlxg6JgDaIPHIfidkLRVCHKR3C9ixg6JgDaIpAay5TYLJlxpY16fccMk7HjEW5YXLRAaL6KWi)uLlF56P)Z1xUCC5A9cbbtL9WefzR9yYLVCXa5cjxpY16fcIs)Ob9mYqrtu4v8GVXkd0O5gBaAzEfu6cUNGjg4IXBmnQLJWV84gZQgqvR3yV5A9cbbXCnSHKU3OL4bNlhxUEZLHvlOKj3d5gzUqYTigwTGssqBt5YFU)MRVC54YLHvlOKj3d5EuU(YfsUkSKHLyNVXkd0O5gpKFPncnxW9em90lgVX0Owoc)YJBmRAavTEJ9MR1leeeZ1Wgs6EJwIhCUCC56nxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BU(YLJlxgwTGsMCpK7r56lxi5QWsgwID(gRmqJMBmw1fK2i0Cb3tI8)fJ3yAulhHF5XnMvnGQwVXEZ16fccI5AydjDVrlXdoxoUC9MldRwqjtUhYnYCHKBrmSAbLKG2MYL)C)nxF5YXLldRwqjtUhY9OC9LlKCvyjdlXoFJvgOrZno8CoPncnxW9KiX8IXBSYanAUX(1QAujrbj5EdDJPrTCe(LhxW9KiJ8IXBmnQLJWV84gZQgqvR3yI5Aydj6r6EJw5YXLlXCnSHegKtl5q8eKlhxUeZ1WgsOdVYH4jixoUCTEHGWVwvJkjkij3BiXdoxi5smxdBirps3B0kxoUC9MR1leemv2dtuKT2Jjx(ZvzGgnc)LcWkiEsShGKG2MYfsUwVqqWuzpmXdoxF3yLbA0CJnaTcDrxW9Kip6IXBSYanAUX(lfG9gtJA5i8lpUG7jrIHxmEJPrTCe(Lh3yLbA0CJR3ivgOrJ01gWn21gGCuB6ghuNdGTExWfCJXPG(CGlgVNG5fJ3yLbA0CJniNwslsTVX0Owoc)YJl4EsKxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3ydm5CsGwqjGryaAfuNlx(YfZCHKR3C9ixG6ObimaTCOcxqJA5i8C54YfOoAacdGCoTK4vhacAulhHNRVC54Y1atoNeOfucyegGwb15YLVCJ8g)PLCuB6g3gPIOl4EYrxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3ydm5CsGwqjGryaAf6IYLVCX8g)PLCuB6g3gjZr6hDb3tWWlgVX0Owoc)YJBmRAavTEJ9MRh5YqF0OdqmnuSazqPC54Y1JCziKdh5Fem08HotsawsAG7QbgXdoxF5cjxRxiiyQShM4bFJvgOrZn2IkdvN7b6fCp53lgVX0Owoc)YJBmRAavTEJTEHGGPYEyIh8nwzGgn3yyeOrZfCp54Vy8gRmqJMB8ZqYgq2MBmnQLJWV84cUN45xmEJPrTCe(Lh3yw1aQA9g)PvRwos0gPIOBSbundCpbZBSYanAUX1BKkd0Or6Ad4g7AdqoQnDJveDb3tWaxmEJPrTCe(Lh3yw1aQA9gxVHcOckjaTn5hvJeVi12QhCQeuu91WWe(n2aQMbUNG5nwzGgn346nsLbA0iDTbCJDTbih1MUX4fP2w9Gt1fCpXtVy8gtJA5i8lpUXSQbu16nUEdfqfusyPoDyKefKQZjby7bQrqr1xddt43ydOAg4EcM3yLbA0CJR3ivgOrJ01gWn21gGCuB6gBHuWfCpbZ)xmEJPrTCe(Lh3yw1aQA9g7OpYLlF5(7)BSYanAUX1BKkd0Or6Ad4g7AdqoQnDJnGl4EcMyEX4nMg1Yr4xECJrW3ydbUXkd0O5g)PvRwo6g)PUhDJHl6t4Vua2B8NwYrTPBmCrFs)LcWEb3tWmYlgVX0Owoc)YJBmc(gBiWnwzGgn34pTA1Yr34p19OBmCrFcdqRqx0n(tl5O20ngUOpPbOvOl6cUNG5rxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3y4I(egGwMxbLUXFAjh1MUXWf9jnaTmVckDb3tWedVy8gtJA5i8lpUXkd0O5gxVrQmqJgPRnGBSRna5O20ngUiyfWWknGl4cUX4fP2w9Gt1fJ3tW8IXBmnQLJWV84gJGVXgcCJvgOrZn(tRwTC0n(tDp6g7nxRxiiaTn5hvJeVi12QhCQefzR9yYLVCHYWf2kpZnIC)lWmxi56nxI5Aydj6rAHayZLJlxI5Aydj6rAqoTYLJlxI5AydjCVrl5q8eKRVC54Y16fccqBt(r1iXlsTT6bNkrr2ApMC5lxLbA0imaTcDrcINe7bijOTPCJi3)cmZfsUEZLyUg2qIEKU3OvUCC5smxdBiHb50soepb5YXLlXCnSHe6WRCiEcY1xU(YLJlxpY16fccqBt(r1iXlsTT6bNkXd(g)PLCuB6gB0ajbi5Zqsdm5CxW9KiVy8gtJA5i8lpUXSQbu16n2BUEK7NwTA5iHrdKeGKpdjnWKZLlhxUEZ16fcIs)Ob9mYqrtu4vuKT2Jjx(ZfkdxyR8mxpjxg1UC9MRAaL6KWi)uL7p5E0)C9LlKCTEHGO0pAqpJmu0efEfp4C9LRVC54YvnGsDsyKFQYLVC90)3yLbA0CJnaTmVckDb3to6IXBmnQLJWV84gRmqJMBSIRWG(JKg)AzFJzvdOQ1BSh5IJacfxHb9hjn(1YwIR2kusaA25EGMlKC9ixLbA0iuCfg0FK04xlBjUARqjrpYGRHIfKlKC9MRh5IJacfxHb9hjn(1YwILuNa0SZ9anxoUCXraHIRWG(JKg)AzlXsQtuKT2Jjx(Y93C9LlhxU4iGqXvyq)rsJFTSL4QTcLegGYoNl)5EuUqYfhbekUcd6psA8RLTexTvOKOiBThtU8N7r5cjxCeqO4kmO)iPXVw2sC1wHscqZo3d0BmJxMJKaTGsaZ9emVG7jy4fJ3yAulhHF5XnwzGgn3yBeAcDr3yw1aQA9gxuOidw1Yr5cjxGwqjGa02KeGK4nLlF5IzK5cjxV56nxRxiiyQShMOiBThtU8L7V5cjxV5A9cbrPF0GEgzOOjk8kkYw7XKlF5(BUCC56rUwVqqu6hnONrgkAIcVIhCU(YLJlxpY16fccMk7HjEW5YXLRAaL6KWi)uLl)5E0)C9LlKC9MRh5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC5QgqPojmYpv5YFUh9pxF5cjxfwYWsSZ567gZ4L5ijqlOeWCpbZl4EYVxmEJPrTCe(Lh3yLbA0CJnVj0fDJzvdOQ1BCrHImyvlhLlKCbAbLacqBtsasI3uU8LlMrMlKC9MR3CTEHGGPYEyIIS1Em5YxU)MlKC9MR1leeL(rd6zKHIMOWROiBThtU8L7V5YXLRh5A9cbrPF0GEgzOOjk8kEW56lxoUC9ixRxiiyQShM4bNlhxUQbuQtcJ8tvU8N7r)Z1xUqY1BUEKR1leeN7bViCjzdJ8tLnnajnubTJcjEW5YXLRAaL6KWi)uLl)5E0)C9LlKCvyjdlXoNRVBmJxMJKaTGsaZ9emVG7jh)fJ3yAulhHF5XnwzGgn3ydGCoTKbNw0nMvnGQwVXffkYGvTCuUqYfOfuciaTnjbijEt5YxUyE85cjxV56nxRxiiyQShMOiBThtU8L7V5cjxV5A9cbrPF0GEgzOOjk8kkYw7XKlF5(BUCC56rUwVqqu6hnONrgkAIcVIhCU(YLJlxpY16fccMk7HjEW5YXLRAaL6KWi)uLl)5E0)C9LlKC9MRh5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC5QgqPojmYpv5YFUh9pxF5cjxfwYWsSZ567gZ4L5ijqlOeWCpbZl4EINFX4nMg1Yr4xECJzvdOQ1BSclzyj25BSYanAUXbuXijkihf8k6cUNGbUy8gtJA5i8lpUXSQbu16n26fccMk7HjEW3yLbA0CJl9Jg0ZidfnrH3l4EINEX4nMg1Yr4xECJzvdOQ1BS3C9MR1leeeZ1WgsAqoTefzR9yYLVCX8FUCC5A9cbbXCnSHKU3OLOiBThtU8LlM)Z1xUqYLHqoCK)rWuzpmrr2ApMC5l3J(NRVC54YLHqoCK)rWuzpmrrkoV3yLbA0CJp3dEr4sdCxnWCb3tW8)fJ3yAulhHF5XnMvnGQwVXEZ16fcIZ9GxeUKSHr(PYMgGKgQG2rHep4C54Y1JCzOpA0bioZB16KRVC54YLH(OrhGyAOybYGs5YXL7NwTA5irBKkIYLJlxRxiiSCieU7zaIhCUqY16fcclhcH7EgGOiBThtU8NBK)ZnIC9MlgMRNKldn4VgiGlI1gsQUg6ytdqqJA5i8C9LlKC9ixRxiiyQShM4bNlKC9MBpaQGrofq4YqdflqwKT2Jjx(ZLHqoCK)rWqZh6mjbyjPbURgyefzR9yYnIC98C54YThavWiNciCzOHIfilYw7XKl)5gzK5YXLBpaQGrofq4YqdflqwKT2Jj3JLlMyG)5YFUrgzUCC5YqihoY)iyO5dDMKaSK0a3vdmIhCUCC56rUm0hn6aetdflqgukxF3yLbA0CJzKJmGwDs11qhBAaxW9emX8IXBmnQLJWV84gZQgqvR3yV5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC56rUm0hn6aeN5TADY1xUCC5YqF0OdqmnuSazqPC54Y9tRwTCKOnsfr5YXLR1leewoec39maXdoxi5A9cbHLdHWDpdquKT2Jjx(Z9O)5grUEZfdZ1tYLHg8xdeWfXAdjvxdDSPbiOrTCeEU(YfsUEKR1leemv2dt8GZfsUEZThavWiNciCzOHIfilYw7XKl)5YqihoY)iyO5dDMKaSK0a3vdmIIS1Em5grUEEUCC52dGkyKtbeUm0qXcKfzR9yYL)CpkYC54YThavWiNciCzOHIfilYw7XK7XYftmW)C5p3JImxoUCziKdh5Fem08HotsawsAG7QbgXdoxoUC9ixg6JgDaIPHIfidkLRVBSYanAUX9W0AuqJMl4EcMrEX4nMg1Yr4xECJrW3ydbUXkd0O5g)PvRwo6g)PUhDJzOpA0biMgkwGmOuUqY1BUwVqqaxTnQWB1j1IPtZKWpNrlXN6EuU8NBKy4)CHKR3CziKdh5Femv2dtuKT2Jj3iYfZ)5YxU9aOcg5uaHldnuSazr2ApMC54YLHqoCK)rWuzpmrr2ApMCJi3J(Nl)52dGkyKtbeUm0qXcKfzR9yYfsU9aOcg5uaHldnuSazr2ApMC5lxmp6FUCC5A9cbbtL9WefzR9yYLVC98C9LlKCTEHGGyUg2qsdYPLOiBThtU8LlM)ZLJl3EaubJCkGWLHgkwGSiBThtUhlxmJ8FU8NlM)MRVB8NwYrTPBmdnFOZKKHg8g0O5cUNG5rxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3yV56rUmeYHJ8pcMk7HjksX5nxoUC9i3pTA1YrcgA(qNjjdn4nOrtUqYLH(OrhGyAOybYGs567g)PLCuB6gB0psgqLKPYEyxW9emXWlgVX0Owoc)YJBmRAavTEJ)0QvlhjyO5dDMKm0G3Ggn5cjx1ak1jHr(Pkx(Zfd)FJvgOrZnMHMp0zscWssdCxnWCb3tW83lgVX0Owoc)YJBmRAavTEJjMRHnKOhPo8MlKCvyjdlXoNlKC9MlociuCfg0FK04xlBjUARqjbOzN7bAUCC56rUm0hn6aedXkKdv456lxi5(PvRwosy0psgqLKPYEy3yLbA0CJdVIxjkij3BOl4EcMh)fJ3yAulhHF5XnMvnGQwVXm0hn6aetdflqgukxi5(PvRwosWqZh6mjzObVbnAYfsUQbuQtcJ8tvU8Dixm8FUqYLHqoCK)rWqZh6mjbyjPbURgyefzR9yYL)CHYWf2kpZ1tYLrTlxV5QgqPojmYpv5(tUh9pxF3yLbA0CJnaTmVckDb3tW0ZVy8gtJA5i8lpUXSQbu16n2BUwVqqqmxdBiP7nAjEW5YXLR3Czy1ckzY9qUrMlKClIHvlOKe02uU8N7V56lxoUCzy1ckzY9qUhLRVCHKRclzyj25CHK7NwTA5iHr)izavsMk7HDJvgOrZnEi)sBeAUG7jyIbUy8gtJA5i8lpUXSQbu16n2BUwVqqqmxdBiP7nAjEW5cjxpYLH(OrhG4mVvRtUCC56nxRxiio3dEr4sYgg5NkBAasAOcAhfs8GZfsUm0hn6aeN5TADY1xUCC56nxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BU(YLJlxgwTGsMCpK7r5YXLR1leemv2dt8GZ1xUqYvHLmSe7CUqY9tRwTCKWOFKmGkjtL9WUXkd0O5gJvDbPncnxW9em90lgVX0Owoc)YJBmRAavTEJ9MR1leeeZ1Wgs6EJwIhCUqY1JCzOpA0bioZB16KlhxUEZ16fcIZ9GxeUKSHr(PYMgGKgQG2rHep4CHKld9rJoaXzERwNC9LlhxUEZLHvlOKj3d5gzUqYTigwTGssqBt5YFU)MRVC54YLHvlOKj3d5EuUCC5A9cbbtL9Wep4C9LlKCvyjdlXoNlKC)0Qvlhjm6hjdOsYuzpSBSYanAUXHNZjTrO5cUNe5)lgVXkd0O5g7xRQrLefKK7n0nMg1Yr4xECb3tIeZlgVX0Owoc)YJBmRAavTEJjMRHnKOhP7nALlhxUeZ1WgsyqoTKdXtqUCC5smxdBiHo8khINGC54Y16fcc)AvnQKOGKCVHep4CHKR1leeeZ1Wgs6EJwIhCUCC56nxRxiiyQShMOiBThtU8NRYanAe(lfGvq8KypajbTnLlKCTEHGGPYEyIhCU(UXkd0O5gBaAf6IUG7jrg5fJ3yLbA0CJ9xka7nMg1Yr4xECb3tI8OlgVX0Owoc)YJBSYanAUX1BKkd0Or6Ad4g7AdqoQnDJdQZbWwVl4cUXkIUy8EcMxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3yV5A9cbbOTj)OAK4fP2w9GtLOiBThtU8NlugUWw5zUrK7FbM5YXLR1leeG2M8JQrIxKAB1dovIIS1Em5YFUkd0OryaAf6Ieepj2dqsqBt5grU)fyMlKC9MlXCnSHe9iDVrRC54YLyUg2qcdYPLCiEcYLJlxI5Aydj0Hx5q8eKRVC9LlKCTEHGa02KFuns8IuBREWPs8GZfsU1BOaQGscqBt(r1iXlsTT6bNkbfvFnmmHFJ)0soQnDJXlsTL(BNtguNtIcHl4EsKxmEJPrTCe(Lh3yw1aQA9gB9cbHbOvqDorrHImyvlhLlKC9MRbMCojqlOeWimaTcQZLl)5EuUCC56rU1BOaQGscqBt(r1iXlsTT6bNkbfvFnmmHNRVCHKR3C9i36nuavqjHJxMwQrgCeb6bQeQRTHnKGIQVggMWZLJlxqBt5ESCXWFZLVCTEHGWa0kOoNOiBThtUrKBK567gRmqJMBSbOvqDUl4EYrxmEJPrTCe(Lh3yw1aQA9gxVHcOckjaTn5hvJeVi12QhCQeuu91WWeEUqY1atoNeOfucyegGwb15YLVd5EuUqY1BUEKR1leeG2M8JQrIxKAB1dovIhCUqY16fccdqRG6CIIcfzWQwokxoUC9M7NwTA5ibErQT0F7CYG6CsuiKlKC9MR1leegGwb15efzR9yYL)CpkxoUCnWKZjbAbLagHbOvqDUC5l3iZfsUa1rdqyaKZPLeV6aqqJA5i8CHKR1leegGwb15efzR9yYL)C)nxF56lxF3yLbA0CJnaTcQZDb3tWWlgVX0Owoc)YJBmc(gBiWnwzGgn34pTA1Yr34p19OBSAaL6KWi)uLlF5Ib(NBujxV5I5)C9KCTEHGa02KFuns8IuBREWPsyak7CU(YnQKR3CTEHGWa0kOoNOiBThtUEsUhL7p5AGjNtIvnakxF5gvY1BU4iGi8kELOGKCVHefzR9yY1tY93C9LlKCTEHGWa0kOoN4bFJ)0soQnDJnaTcQZj9JgGmOoNefcxW9KFVy8gtJA5i8lpUXSQbu16n(tRwTCKaVi1w6VDozqDojkeYfsUFA1QLJegGwb15K(rdqguNtIcHBSYanAUXgGwMxbLUG7jh)fJ3yAulhHF5XnwzGgn3yZBcDr3yw1aQA9gxuOidw1Yr5cjxGwqjGa02KeGK4nLlF5IjgMBujxdm5CsGwqjGj3iYTiBThtUqYvHLmSe7CUqYLyUg2qIEK6W7nMXlZrsGwqjG5EcMxW9ep)IXBmnQLJWV84gRmqJMBSIRWG(JKg)AzFJzvdOQ1BSh5cA25EGMlKC9ixLbA0iuCfg0FK04xlBjUARqjrpYGRHIfKlhxU4iGqXvyq)rsJFTSL4QTcLegGYoNl)5EuUqYfhbekUcd6psA8RLTexTvOKOiBThtU8N7r3ygVmhjbAbLaM7jyEb3tWaxmEJPrTCe(Lh3yLbA0CJTrOj0fDJzvdOQ1BCrHImyvlhLlKCbAbLacqBtsasI3uU8LR3CXedZnIC9MRbMCojqlOeWimaTcDr56j5IP43C9LRVC)jxdm5CsGwqjGj3iYTiBThtUqY1BUEZLHqoCK)rWuzpmrrkoV5YXLRbMCojqlOeWimaTcDr5YFUhLlhxUEZLyUg2qIEKgKtRC54YLyUg2qIEKwia2C54YLyUg2qIEKU3OvUqY1JCbQJgGWGEojkibyjzavKbiOrTCeEUCC5A9cbbC12OcVvNulMontc)CgTeFQ7r5Y3HCJ83)56lxi56nxdm5CsGwqjGryaAf6IYL)CX8FUEsUEZfZCJixG6Obia(7rAJqJrqJA5i8C9LRVCHKRAaL6KWi)uLlF5(7)CJk5A9cbHbOvqDorr2ApMC9KCp(C9LlKC9ixRxiio3dEr4sYgg5NkBAasAOcAhfs8GZfsUkSKHLyNZ13nMXlZrsGwqjG5EcMxW9ep9IXBmnQLJWV84gZQgqvR3yfwYWsSZ3yLbA0CJdOIrsuqok4v0fCpbZ)xmEJPrTCe(Lh3yw1aQA9gB9cbbtL9Wep4BSYanAUXL(rd6zKHIMOW7fCpbtmVy8gtJA5i8lpUXSQbu16n2BUwVqqyaAfuNt8GZLJlx1ak1jHr(Pkx(Y93)56lxi56rUwVqqyqodOzK4bNlKC9ixRxiiyQShM4bNlKC9MBpaQGrofq4YqdflqwKT2Jjx(ZLHqoCK)rWqZh6mjbyjPbURgyefzR9yYnIC98C54YThavWiNciCzOHIfilYw7XK7XYftmW)C5p3iJmxoUCziKdh5Fem08HotsawsAG7QbgXdoxoUC9ixg6JgDaIPHIfidkLRVBSYanAUXmYrgqRoP6AOJnnGl4EcMrEX4nMg1Yr4xECJzvdOQ1BCOHIfilYw7XKl)5I5V5YXLR3CTEHGaUABuH3QtQftNMjHFoJwIp19OC5p3i)9FUCC5A9cbbC12OcVvNulMontc)CgTeFQ7r5Y3HCJ83)56lxi5A9cbHbOvqDoXdoxi5YqihoY)iyQShMOiBThtU8L7V)VXkd0O5g3dtRrbnAUG7jyE0fJ3yAulhHF5XnwzGgn3ydGCoTKbNw0nMvnGQwVXffkYGvTCuUqYf02KeGK4nLlF5I5V5cjxdm5CsGwqjGryaAf6IYL)CXWCHKRclzyj25CHKR3CTEHGGPYEyIIS1Em5YxUy(pxoUC9ixRxiiyQShM4bNRVBmJxMJKaTGsaZ9emVG7jyIHxmEJPrTCe(Lh3ye8n2qGBSYanAUXFA1QLJUXFQ7r3yRxiiGR2gv4T6KAX0Pzs4NZOL4tDpkx(ZnYF)NBujx1ak1jHr(Pkxi56nxgc5Wr(hbtL9WefzR9yYnICX8FU8LBOHIfilYw7XKlhxUmeYHJ8pcMk7HjkYw7XKBe5E0)C5p3qdflqwKT2Jjxi5gAOybYIS1Em5YxUyE0)C54Y16fccMk7HjkYw7XKlF56556lxi5smxdBirpsD4nxoUCdnuSazr2ApMCpwUyg5)C5pxm)9g)PLCuB6gZqZh6mjzObVbnAUG7jy(7fJ3yAulhHF5XnMvnGQwVXFA1QLJem08HotsgAWBqJMCHKRAaL6KWi)uLl)5(7)BSYanAUXm08HotsawsAG7QbMl4EcMh)fJ3yAulhHF5XnMvnGQwVXeZ1Wgs0JuhEZfsUkSKHLyNZfsUwVqqaxTnQWB1j1IPtZKWpNrlXN6EuU8NBK)(pxi56nxCeqO4kmO)iPXVw2sC1wHscqZo3d0C54Y1JCzOpA0bigIvihQWZLJlxdm5CsGwqjGjx(YnYC9DJvgOrZno8kELOGKCVHUG7jy65xmEJPrTCe(Lh3yw1aQA9gB9cbbAiawJeMkgbdA0iEW5cjxV5A9cbHbOvqDorrHImyvlhLlhxUQbuQtcJ8tvU8LRN(pxF3yLbA0CJnaTcQZDb3tWedCX4nMg1Yr4xECJzvdOQ1Bmd9rJoaX0qXcKbLYfsUFA1QLJem08HotsgAWBqJMCHKldHC4i)JGHMp0zscWssdCxnWikYw7XKl)5cLHlSvEMRNKlJAxUEZvnGsDsyKFQY9NC)9FU(YfsUwVqqyaAfuNtuuOidw1Yr3yLbA0CJnaTcQZDb3tW0tVy8gtJA5i8lpUXSQbu16nMH(OrhGyAOybYGs5cj3pTA1YrcgA(qNjjdn4nOrtUqYLHqoCK)rWqZh6mjbyjPbURgyefzR9yYL)CHYWf2kpZ1tYLrTlxV5QgqPojmYpv5(tUh9pxF5cjxRxiimaTcQZjEW3yLbA0CJnaTmVckDb3tI8)fJ3yAulhHF5XnMvnGQwVXwVqqGgcG1izosl5xBA0iEW5YXLRh5AaAf6IekSKHLyNZLJlxV5A9cbbtL9WefzR9yYL)C)nxi5A9cbbtL9Wep4C54Y1BUwVqqu6hnONrgkAIcVIIS1Em5YFUqz4cBLN56j5YO2LR3CvdOuNeg5NQC)j3J(NRVCHKR1leeL(rd6zKHIMOWR4bNRVC9LlKC)0QvlhjmaTcQZj9JgGmOoNefc5cjxdm5CsGwqjGryaAfuNlx(Z9OBSYanAUXgGwMxbLUG7jrI5fJ3yAulhHF5XnMvnGQwVXEZLyUg2qIEK6WBUqYLHqoCK)rWuzpmrr2ApMC5l3F)NlhxUEZLHvlOKj3d5gzUqYTigwTGssqBt5YFU)MRVC54YLHvlOKj3d5EuU(YfsUkSKHLyNVXkd0O5gpKFPncnxW9KiJ8IXBmnQLJWV84gZQgqvR3yV5smxdBirpsD4nxi5YqihoY)iyQShMOiBThtU8L7V)ZLJlxV5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1xUCC5YWQfuYK7HCpkxF5cjxfwYWsSZ3yLbA0CJXQUG0gHMl4EsKhDX4nMg1Yr4xECJzvdOQ1BS3CjMRHnKOhPo8MlKCziKdh5Femv2dtuKT2Jjx(Y93)5YXLR3Czy1ckzY9qUrMlKClIHvlOKe02uU8N7V56lxoUCzy1ckzY9qUhLRVCHKRclzyj25BSYanAUXHNZjTrO5cUNejgEX4nwzGgn3y)AvnQKOGKCVHUX0Owoc)YJl4EsK)EX4nMg1Yr4xECJrW3ydbUXkd0O5g)PvRwo6g)PUhDJnWKZjbAbLagHbOvOlkx(YfdZnICdoeQY1BU2QbqfVYp19OC)j3i)NRVCJi3GdHQC9MR1leegGwMxbLKKnmYpv20aegGYoN7p5IH567g)PLCuB6gBaAf6IK9iniNwxW9Kip(lgVX0Owoc)YJBmRAavTEJjMRHnKW9gTKdXtqUCC5smxdBiHo8khINGCHK7NwTA5irBKmhPFuUCC5A9cbbXCnSHKgKtlrr2ApMC5pxLbA0imaTcDrcINe7bijOTPCHKR1leeeZ1WgsAqoTep4C54YLyUg2qIEKgKtRCHKRh5(PvRwosyaAf6IK9iniNw5YXLR1leemv2dtuKT2Jjx(ZvzGgncdqRqxKG4jXEascABkxi56rUFA1QLJeTrYCK(r5cjxRxiiyQShMOiBThtU8NlXtI9aKe02uUqY16fccMk7HjEW5YXLR1leeL(rd6zKHIMOWR4bNlKCnWKZjXQgaLlF5(xC85cjxV5AGjNtc0ckbm5Y)HCpkxoUC9ixG6ObimONtIcsawsgqfzacAulhHNRVC54Y1JC)0QvlhjAJK5i9JYfsUwVqqWuzpmrr2ApMC5lxINe7bijOTPBSYanAUX(lfG9cUNePNFX4nwzGgn3ydqRqx0nMg1Yr4xECb3tIedCX4nMg1Yr4xECJvgOrZnUEJuzGgnsxBa3yxBaYrTPBCqDoa26DbxWnoOohaB9Uy8EcMxmEJPrTCe(Lh3yw1aQA9g7rU1BOaQGscl1PdJKOGuDojaBpqnckQ(Ayyc)gRmqJMBSbOL5vqPl4EsKxmEJPrTCe(Lh3yLbA0CJnVj0fDJzvdOQ1BmociSrOj0fjkYw7XKlF5wKT2J5gZ4L5ijqlOeWCpbZl4EYrxmEJvgOrZn2gHMqx0nMg1Yr4xECbxWn2aUy8EcMxmEJPrTCe(Lh3yLbA0CJvCfg0FK04xl7BmRAavTEJ9ixCeqO4kmO)iPXVw2sC1wHscqZo3d0CHKRh5QmqJgHIRWG(JKg)AzlXvBfkj6rgCnuSGCHKR3C9ixCeqO4kmO)iPXVw2sSK6eGMDUhO5YXLlociuCfg0FK04xlBjwsDIIS1Em5YxU)MRVC54YfhbekUcd6psA8RLTexTvOKWau25C5p3JYfsU4iGqXvyq)rsJFTSL4QTcLefzR9yYL)Cpkxi5IJacfxHb9hjn(1YwIR2kusaA25EGEJz8YCKeOfucyUNG5fCpjYlgVX0Owoc)YJBSYanAUX2i0e6IUXSQbu16nUOqrgSQLJYfsUaTGsabOTjjajXBkx(YfZiZfsUEZ16fccMk7HjkYw7XKlF5(BUqY1BUwVqqu6hnONrgkAIcVIIS1Em5YxU)MlhxUEKR1leeL(rd6zKHIMOWR4bNRVC54Y1JCTEHGGPYEyIhCUCC5QgqPojmYpv5YFUh9pxF5cjxV56rUwVqqCUh8IWLKnmYpv20aK0qf0okK4bNlhxUQbuQtcJ8tvU8N7r)Z1xUqYvHLmSe78nMXlZrsGwqjG5EcMxW9KJUy8gtJA5i8lpUXkd0O5gBEtOl6gZQgqvR34IcfzWQwokxi5c0ckbeG2MKaKeVPC5lxmJmxi56nxRxiiyQShMOiBThtU8L7V5cjxV5A9cbrPF0GEgzOOjk8kkYw7XKlF5(BUCC56rUwVqqu6hnONrgkAIcVIhCU(YLJlxpY16fccMk7HjEW5YXLRAaL6KWi)uLl)5E0)C9LlKC9MRh5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC5QgqPojmYpv5YFUh9pxF5cjxfwYWsSZ3ygVmhjbAbLaM7jyEb3tWWlgVX0Owoc)YJBSYanAUXga5CAjdoTOBmRAavTEJlkuKbRA5OCHKlqlOeqaABscqs8MYLVCX84ZfsUEZ16fccMk7HjkYw7XKlF5(BUqY1BUwVqqu6hnONrgkAIcVIIS1Em5YxU)MlhxUEKR1leeL(rd6zKHIMOWR4bNRVC54Y1JCTEHGGPYEyIhCUCC5QgqPojmYpv5YFUh9pxF5cjxV56rUwVqqCUh8IWLKnmYpv20aK0qf0okK4bNlhxUQbuQtcJ8tvU8N7r)Z1xUqYvHLmSe78nMXlZrsGwqjG5EcMxW9KFVy8gtJA5i8lpUXSQbu16nwHLmSe78nwzGgn34aQyKefKJcEfDb3to(lgVX0Owoc)YJBmRAavTEJTEHGGPYEyIh8nwzGgn34s)Ob9mYqrtu49cUN45xmEJPrTCe(Lh3yw1aQA9g7nxV5A9cbbXCnSHKgKtlrr2ApMC5lxm)NlhxUwVqqqmxdBiP7nAjkYw7XKlF5I5)C9LlKCziKdh5Femv2dtuKT2Jjx(Y9O)5cjxV5A9cbbC12OcVvNulMontc)CgTeFQ7r5YFUrIH)ZLJlxpYTEdfqfusaxTnQWB1j1IPtZKWpNrlbfvFnmmHNRVC9LlhxUwVqqaxTnQWB1j1IPtZKWpNrlXN6EuU8Di3i98)5YXLldHC4i)JGPYEyIIuCEZfsUEZvnGsDsyKFQYLVC90)5YXL7NwTA5irBKkIY13nwzGgn34Z9GxeU0a3vdmxW9emWfJ3yAulhHF5XnMvnGQwVXEZvnGsDsyKFQYLVC90)5cjxV5A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhCUCC56rUm0hn6aeN5TADY1xUCC5YqF0OdqmnuSazqPC54Y9tRwTCKOnsfr5YXLR1leewoec39maXdoxi5A9cbHLdHWDpdquKT2Jjx(ZnY)5grUEZ1BUEAUEsU1BOaQGsc4QTrfERoPwmDAMe(5mAjOO6RHHj8C9LBe56nxmmxpjxgAWFnqaxeRnKuDn0XMgGGg1Yr456lxF56lxi56rUwVqqWuzpmXdoxi56n3qdflqwKT2Jjx(ZLHqoCK)rWqZh6mjbyjPbURgyefzR9yYnIC98C54Yn0qXcKfzR9yYL)CJmYCJixV56P56j56nxRxiiGR2gv4T6KAX0Pzs4NZOL4tDpkx(YfZ))Z1xU(YLJl3qdflqwKT2Jj3JLlMyG)5YFUrgzUCC5YqihoY)iyO5dDMKaSK0a3vdmIhCUCC56rUm0hn6aetdflqgukxF3yLbA0CJzKJmGwDs11qhBAaxW9ep9IXBmnQLJWV84gZQgqvR3yV5QgqPojmYpv5YxUE6)CHKR3CTEHG4Cp4fHljByKFQSPbiPHkODuiXdoxoUC9ixg6JgDaIZ8wTo56lxoUCzOpA0biMgkwGmOuUCC5(PvRwos0gPIOC54Y16fcclhcH7EgG4bNlKCTEHGWYHq4UNbikYw7XKl)5E0)CJixV56nxpnxpj36nuavqjbC12OcVvNulMontc)CgTeuu91WWeEU(YnIC9MlgMRNKldn4VgiGlI1gsQUg6ytdqqJA5i8C9LRVC9LlKC9ixRxiiyQShM4bNlKC9MBOHIfilYw7XKl)5YqihoY)iyO5dDMKaSK0a3vdmIIS1Em5grUEEUCC5gAOybYIS1Em5YFUhfzUrKR3C90C9KC9MR1leeWvBJk8wDsTy60mj8Zz0s8PUhLlF5I5))56lxF5YXLBOHIfilYw7XK7XYftmW)C5p3JImxoUCziKdh5Fem08HotsawsAG7QbgXdoxoUC9ixg6JgDaIPHIfidkLRVBSYanAUX9W0AuqJMl4EcM)Vy8gtJA5i8lpUXi4BSHa3yLbA0CJ)0QvlhDJ)u3JUXm0hn6aetdflqgukxi56nxRxiiGR2gv4T6KAX0Pzs4NZOL4tDpkx(Znsm8FUqY1BUmeYHJ8pcMk7HjkYw7XKBe5I5)C5l3qdflqwKT2JjxoUCziKdh5Femv2dtuKT2Jj3iY9O)5YFUHgkwGSiBThtUqYn0qXcKfzR9yYLVCX8O)5YXLR1leemv2dtuKT2Jjx(Y1ZZ1xUqY16fccI5AydjniNwIIS1Em5YxUy(pxoUCdnuSazr2ApMCpwUyg5)C5pxm)nxF34pTKJAt3ygA(qNjjdn4nOrZfCpbtmVy8gtJA5i8lpUXi4BSHa3yLbA0CJ)0QvlhDJ)u3JUXEZ1JCziKdh5Femv2dtuKIZBUCC56rUFA1QLJem08HotsgAWBqJMCHKld9rJoaX0qXcKbLY13n(tl5O20n2OFKmGkjtL9WUG7jyg5fJ3yAulhHF5XnMvnGQwVXFA1QLJem08HotsgAWBqJMCHKRAaL6KWi)uLl)5E0)BSYanAUXm08HotsawsAG7QbMl4EcMhDX4nMg1Yr4xECJzvdOQ1BmXCnSHe9i1H3CHKRclzyj25CHKR1leeWvBJk8wDsTy60mj8Zz0s8PUhLl)5gjg(pxi56nxCeqO4kmO)iPXVw2sC1wHscqZo3d0C54Y1JCzOpA0bigIvihQWZ1xUqY9tRwTCKWOFKmGkjtL9WUXkd0O5ghEfVsuqsU3qxW9emXWlgVX0Owoc)YJBmRAavTEJTEHGaneaRrctfJGbnAep4CHKR1leegGwb15effkYGvTC0nwzGgn3ydqRG6CxW9em)9IXBmnQLJWV84gZQgqvR3yRxiimaTCOcxuKT2Jjx(Z93CHKR3CTEHGGyUg2qsdYPLOiBThtU8L7V5YXLR1leeeZ1Wgs6EJwIIS1Em5YxU)MRVCHKRAaL6KWi)uLlF56P)VXkd0O5gZ0HroP1leUXwVqqoQnDJnaTCOc)cUNG5XFX4nMg1Yr4xECJzvdOQ1Bmd9rJoaX0qXcKbLYfsUFA1QLJem08HotsgAWBqJMCHKldHC4i)JGHMp0zscWssdCxnWikYw7XKl)5cLHlSvEMRNKlJAxUEZvnGsDsyKFQY9NCp6FU(UXkd0O5gBaAzEfu6cUNGPNFX4nMg1Yr4xECJzvdOQ1BmqD0aega5CAjXRoae0Owocpxi56rUa1rdqyaA5qfUGg1Yr45cjxRxiimaTcQZjkkuKbRA5OCHKR3CTEHGGyUg2qs3B0suKT2Jjx(Y94ZfsUeZ1Wgs0J09gTYfsUEZ1JCR3qbubLeWvBJk8wDsTy60mj8Zz0sqJA5i8C54Y16fcc4QTrfERoPwmDAMe(5mAj(u3JYL)CJ83)56lxoUC9MRh5wVHcOckjGR2gv4T6KAX0Pzs4NZOLGg1Yr45YXLR1leeWvBJk8wDsTy60mj8Zz0s8PUhLlFhYnYF)NRVCHKRAaL6KWi)uLlF56P)ZLJlxCeqO4kmO)iPXVw2sC1wHsIIS1Em5YxUyGC54YvzGgncfxHb9hjn(1YwIR2kus0Jm4AOyb56lxi56rUmeYHJ8pcMk7HjksX59gRmqJMBSbOvqDUl4EcMyGlgVX0Owoc)YJBmRAavTEJTEHGaneaRrYCKwYV20Or8GZLJlxRxiio3dEr4sYgg5NkBAasAOcAhfs8GZLJlxRxiiyQShM4bNlKC9MR1leeL(rd6zKHIMOWROiBThtU8NlugUWw5zUEsUmQD56nx1ak1jHr(Pk3FY9O)56lxi5A9cbrPF0GEgzOOjk8kEW5YXLRh5A9cbrPF0GEgzOOjk8kEW5cjxpYLHqoCK)ru6hnONrgkAIcVIIuCEZLJlxpYLH(OrhG4JgawERC9LlhxUQbuQtcJ8tvU8LRN(pxi5smxdBirpsD49gRmqJMBSbOL5vqPl4EcME6fJ3yAulhHF5XnMvnGQwVXa1rdqyaA5qfUGg1Yr45cjxV5A9cbHbOLdv4IhCUCC5QgqPojmYpv5YxUE6)C9LlKCTEHGWa0YHkCHbOSZ5YFUhLlKC9MR1leeeZ1WgsAqoTep4C54Y16fccI5AydjDVrlXdoxF5cjxRxiiGR2gv4T6KAX0Pzs4NZOL4tDpkx(Znsp)FUqY1BUmeYHJ8pcMk7HjkYw7XKlF5I5)C54Y1JC)0QvlhjyO5dDMKm0G3Ggn5cjxg6JgDaIPHIfidkLRVBSYanAUXgGwMxbLUG7jr()IXBmnQLJWV84gZQgqvR3yV5A9cbbC12OcVvNulMontc)CgTeFQ7r5YFUr65)ZLJlxRxiiGR2gv4T6KAX0Pzs4NZOL4tDpkx(ZnYF)NlKCbQJgGWaiNtljE1bGGg1Yr456lxi5A9cbbXCnSHKgKtlrr2ApMC5lxppxi5smxdBirpsdYPvUqY1JCTEHGaneaRrctfJGbnAep4CHKRh5cuhnaHbOLdv4cAulhHNlKCziKdh5Femv2dtuKT2Jjx(Y1ZZfsUEZLHqoCK)rCUh8IWLg4UAGruKT2Jjx(Y1ZZLJlxpYLH(OrhG4mVvRtU(UXkd0O5gBaAzEfu6cUNejMxmEJPrTCe(Lh3yw1aQA9g7nxRxiiiMRHnK09gTep4C54Y1BUmSAbLm5Ei3iZfsUfXWQfuscABkx(Z93C9LlhxUmSAbLm5Ei3JY1xUqYvHLmSe7CUqY9tRwTCKWOFKmGkjtL9WUXkd0O5gpKFPncnxW9KiJ8IXBmnQLJWV84gZQgqvR3yV5A9cbbXCnSHKU3OL4bNlKC9ixg6JgDaIZ8wTo5YXLR3CTEHG4Cp4fHljByKFQSPbiPHkODuiXdoxi5YqF0OdqCM3Q1jxF5YXLR3Czy1ckzY9qUrMlKClIHvlOKe02uU8N7V56lxoUCzy1ckzY9qUhLlhxUwVqqWuzpmXdoxF5cjxfwYWsSZ5cj3pTA1YrcJ(rYaQKmv2d7gRmqJMBmw1fK2i0Cb3tI8OlgVX0Owoc)YJBmRAavTEJ9MR1leeeZ1Wgs6EJwIhCUqY1JCzOpA0bioZB16KlhxUEZ16fcIZ9GxeUKSHr(PYMgGKgQG2rHep4CHKld9rJoaXzERwNC9LlhxUEZLHvlOKj3d5gzUqYTigwTGssqBt5YFU)MRVC54YLHvlOKj3d5EuUCC5A9cbbtL9Wep4C9LlKCvyjdlXoNlKC)0Qvlhjm6hjdOsYuzpSBSYanAUXHNZjTrO5cUNejgEX4nwzGgn3y)AvnQKOGKCVHUX0Owoc)YJl4EsK)EX4nMg1Yr4xECJzvdOQ1BmXCnSHe9iDVrRC54YLyUg2qcdYPLCiEcYLJlxI5Aydj0Hx5q8eKlhxUwVqq4xRQrLefKK7nK4bNlKCTEHGGyUg2qs3B0s8GZLJlxV5A9cbbtL9WefzR9yYL)CvgOrJWFPaScINe7bijOTPCHKR1leemv2dt8GZ13nwzGgn3ydqRqx0fCpjYJ)IXBSYanAUX(lfG9gtJA5i8lpUG7jr65xmEJPrTCe(Lh3yLbA0CJR3ivgOrJ01gWn21gGCuB6ghuNdGTExWfCJHlcwbmSsd4IX7jyEX4nMg1Yr4xECJvgOrZn2gHMqx0nMvnGQwVXffkYGvTCuUqYfOfuciaTnjbijEt5YxUygzUqY1BUwVqqWuzpmrr2ApMC5l3FZLJlxpY16fccMk7HjEW5YXLRAaL6KWi)uLl)5E0)C9LlKCvyjdlXoFJz8YCKeOfucyUNG5fCpjYlgVX0Owoc)YJBSYanAUXM3e6IUXSQbu16nUOqrgSQLJYfsUaTGsabOTjjajXBkx(YfZiZfsUEZ16fccMk7HjkYw7XKlF5(BUCC56rUwVqqWuzpmXdoxoUCvdOuNeg5NQC5p3J(NRVCHKRclzyj25BmJxMJKaTGsaZ9emVG7jhDX4nMg1Yr4xECJvgOrZn2aiNtlzWPfDJzvdOQ1BCrHImyvlhLlKCbAbLacqBtsasI3uU8LlMrMlKC9MR1leemv2dtuKT2Jjx(Y93C54Y1JCTEHGGPYEyIhCUCC5QgqPojmYpv5YFUh9pxF5cjxfwYWsSZ3ygVmhjbAbLaM7jyEb3tWWlgVX0Owoc)YJBmRAavTEJvyjdlXoFJvgOrZnoGkgjrb5OGxrxW9KFVy8gtJA5i8lpUXSQbu16n2BUQbuQtcJ8tvU8LRN(pxoUCTEHGWYHq4UNbiEW5cjxRxiiSCieU7zaIIS1Em5YFUrE856lxi56rUwVqqWuzpmXd(gRmqJMBmJCKb0QtQUg6ytd4cUNC8xmEJPrTCe(Lh3yw1aQA9g7nx1ak1jHr(Pkx(Y1t)NlhxUwVqqy5qiC3Zaep4CHKR1leewoec39marr2ApMC5p3Jo(C9LlKC9ixRxiiyQShM4bFJvgOrZnUhMwJcA0Cb3t88lgVX0Owoc)YJBmc(gBiWnwzGgn34pTA1Yr34p19OBSh5YqihoY)iyQShMOifN3B8NwYrTPBSr)izavsMk7HDb3tWaxmEJPrTCe(Lh3yw1aQA9gtmxdBirpsD4nxi5QWsgwIDoxi5(PvRwosy0psgqLKPYEy3yLbA0CJdVIxjkij3BOl4EINEX4nMg1Yr4xECJzvdOQ1BS1leegGwouHlkYw7XKl)5E85cjxV5A9cbbXCnSHKgKtlXdoxoUCTEHGGyUg2qs3B0s8GZ1xUqYvnGsDsyKFQYLVC90)3yLbA0CJz6WiN06fc3yRxiih1MUXgGwouHFb3tW8)fJ3yAulhHF5XnMvnGQwVXEZ1JC1OqvdiHbuKEUhOsdqlJO05CUCC5A9cbbtL9WefzR9yYL)CjEsShGKG2MYLJlxpYfUOpHbOL5vqPC9LlKC9MR1leemv2dt8GZLJlx1ak1jHr(Pkx(Y1t)NlKCjMRHnKOhPo8MRVBSYanAUXgGwMxbLUG7jyI5fJ3yAulhHF5XnMvnGQwVXEZ1JC1OqvdiHbuKEUhOsdqlJO05CUCC5A9cbbtL9WefzR9yYL)CjEsShGKG2MYLJlxpY9tRwTCKaUOpPbOL5vqPC9LlKCbQJgGWa0YHkCbnQLJWZfsUEZ16fccdqlhQWfp4C54YvnGsDsyKFQYLVC90)56lxi5A9cbHbOLdv4cdqzNZL)Cpkxi56nxRxiiiMRHnK0GCAjEW5YXLR1leeeZ1Wgs6EJwIhCU(YfsUmeYHJ8pcMk7HjkYw7XKlF5653yLbA0CJnaTmVckDb3tWmYlgVX0Owoc)YJBmRAavTEJ9MRh5QrHQgqcdOi9CpqLgGwgrPZ5C54Y16fccMk7HjkYw7XKl)5s8KypajbTnLlhxUEKlCrFcdqlZRGs56lxi5A9cbbXCnSHKgKtlrr2ApMC5lxppxi5smxdBirpsdYPvUqY1JCbQJgGWa0YHkCbnQLJWZfsUmeYHJ8pcMk7HjkYw7XKlF5653yLbA0CJnaTmVckDb3tW8OlgVX0Owoc)YJBmRAavTEJ9MR1leeeZ1Wgs6EJwIhCUCC56nxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BU(YLJlxgwTGsMCpK7r56lxi5QWsgwIDoxi5(PvRwosy0psgqLKPYEy3yLbA0CJhYV0gHMl4EcMy4fJ3yAulhHF5XnMvnGQwVXEZ16fccI5AydjDVrlXdoxoUC9MldRwqjtUhYnYCHKBrmSAbLKG2MYL)C)nxF5YXLldRwqjtUhY9OC54Y16fccMk7HjEW56lxi5QWsgwIDoxi5(PvRwosy0psgqLKPYEy3yLbA0CJXQUG0gHMl4EcM)EX4nMg1Yr4xECJzvdOQ1BS3CTEHGGyUg2qs3B0s8GZLJlxV5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1xUCC5YWQfuYK7HCpkxoUCTEHGGPYEyIhCU(YfsUkSKHLyNZfsUFA1QLJeg9JKbujzQSh2nwzGgn34WZ5K2i0Cb3tW84Vy8gRmqJMBSFTQgvsuqsU3q3yAulhHF5XfCpbtp)IXBmnQLJWV84gZQgqvR3yV5QrHQgqcdOi9CpqLgGwgrPZ5CHKR1leemv2dtuKT2Jjx(YL4jXEascABkxi5cx0NWFPaS56lxoUC9MRh5QrHQgqcdOi9CpqLgGwgrPZ5C54Y16fccMk7HjkYw7XKl)5s8KypajbTnLlhxUEKlCrFcdqRqxuU(YfsUEZLyUg2qIEKU3OvUCC5smxdBiHb50soepb5YXLlXCnSHe6WRCiEcYLJlxRxii8Rv1OsIcsY9gs8GZfsUwVqqqmxdBiP7nAjEW5YXLR3CTEHGGPYEyIIS1Em5YFUkd0Or4VuawbXtI9aKe02uUqY16fccMk7HjEW56lxF5YXLR3C1OqvdibU6F6bQ08grPZ5C5l3iZfsUwVqqqmxdBiPb50suKT2Jjx(Y93CHKRh5A9cbbU6F6bQ08grr2ApMC5lxLbA0i8xkaRG4jXEascABkxF3yLbA0CJnaTcDrxW9emXaxmEJPrTCe(Lh3yw1aQA9gduhnaHbqoNws8QdabnQLJWZfsUwVqqyaAfuNtuuOidw1Yr5cj3qdflqwKT2Jjx(Y16fccdqRG6Cc8xPGgn5cjxV56rUeZ1Wgs0JuhEZLJlxRxiimaTmVckjjByKFQSPbiEW567gRmqJMBSbOvqDUl4EcME6fJ3yLbA0CJ9xka7nMg1Yr4xECb3tI8)fJ3yAulhHF5XnwzGgn346nsLbA0iDTbCJDTbih1MUXb15ayR3fCbxWn(JktJM7jr(pY)y(psp9g7xRPhOMBmgKEw9SCcg8tWGXZKBUyelLBBdJkqUbuLlgu8IuBREWPcdAUffvFDr45Aq2uU6dGSvaHNldRoqjJiJ(46HYnsptUrnA(Ocq45g32rDUgEhGYZCpwUauUh3tZfV)AtJMCrWuPauLR3F8LRxm5Pprg9X1dLlM)9m5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWFUNjxemvkav569y(Y1lM80NiJ(46HYftm9m5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWFUNjxemvkav569y(Y1lM80NiJ(46HYfZi9m5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWFUNjxemvkav569y(Y1lM80NiJ(46HYfZJ3ZKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav569hF56ftE6tKrNrJbPNvplNGb)emy8m5MlgXs522WOcKBav5IbfUigY2sbyqZTOO6RlcpxdYMYvFaKTci8Czy1bkzez0hxpuU)6zYnQrZhvacp342oQZ1W7auEM7XYfGY94EAU49xBA0KlcMkfGQC9(JVC9gjp9jYOZOXG0ZQNLtWGFcgmEMCZfJyPCBByubYnGQCXGQicdAUffvFDr45Aq2uU6dGSvaHNldRoqjJiJ(46HYnsptUrnA(Ocq45g32rDUgEhGYZCp2XYfGY94EAU2i8N7zYfbtLcqvUEpMVC9Ijp9jYOpUEOCXqptUrnA(Ocq45g32rDUgEhGYZCpwUauUh3tZfV)AtJMCrWuPauLR3F8LRxm5Pprg9X1dLlgWZKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav569hF56ftE6tKrFC9q5IjMEMCJA08rfGWZnUTJ6Cn8oaLN5ESJLlaL7X90CTr4p3ZKlcMkfGQC9EmF56ftE6tKrFC9q5IzKEMCJA08rfGWZnUTJ6Cn8oaLN5ESJLlaL7X90CTr4p3ZKlcMkfGQC9EmF56ftE6tKrFC9q5Ijg6zYnQrZhvacp342oQZ1W7auEM7XowUauUh3tZ1gH)CptUiyQuaQY17X8LRxm5Pprg9X1dLlMyaptUrnA(Ocq45g32rDUgEhGYZCpwUauUh3tZfV)AtJMCrWuPauLR3F8LRxm5Pprg9X1dLlMEQNj3OgnFubi8CJB7OoxdVdq5zUhlxak3J7P5I3FTPrtUiyQuaQY17p(Y1lM80NiJ(46HYnY)EMCJA08rfGWZnUTJ6Cn8oaLN5ESCbOCpUNMlE)1Mgn5IGPsbOkxV)4lxVyYtFIm6JRhk3i)1ZKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav569hF56nsE6tKrNrJbPNvplNGb)emy8m5MlgXs522WOcKBav5Ib1aWGMBrr1xxeEUgKnLR(aiBfq45YWQduYiYOpUEOCXaEMCJA08rfGWZnUTJ6Cn8oaLN5ESJLlaL7X90CTr4p3ZKlcMkfGQC9EmF56ftE6tKrFC9q56PEMCJA08rfGWZnUTJ6Cn8oaLN5ESJLlaL7X90CTr4p3ZKlcMkfGQC9EmF56ftE6tKrFC9q5I5FptUrnA(Ocq45g32rDUgEhGYZCp2XYfGY94EAU2i8N7zYfbtLcqvUEpMVC9Ijp9jYOpUEOCX849m5g1O5JkaHNBCBh15A4DakpZ9y5cq5ECpnx8(RnnAYfbtLcqvUE)XxUEXKN(ez0hxpuUyIb8m5g1O5JkaHNBCBh15A4DakpZ9y5cq5ECpnx8(RnnAYfbtLcqvUE)XxUEXKN(ez0z0yq6z1ZYjyWpbdgptU5IrSuUTnmQa5gqvUyqTqkadAUffvFDr45Aq2uU6dGSvaHNldRoqjJiJ(46HYfZi9m5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWFUNjxemvkav569y(Y1lM80NiJ(46HYfZJ3ZKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav569hF569iE6tKrFC9q5IPN7zYnQrZhvacp342oQZ1W7auEM7XYfGY94EAU49xBA0KlcMkfGQC9(JVC9Ijp9jYOZOXGBdJkaHNlgixLbA0KRRnaJiJ(gBGj29em)h5ngUqH2r3yp7C5H60Hr5IbR614z0E25Ec6JSTOkxmpn3i)h5)m6mAp7CJAS6aLmEMmAp7CJk56zfhNWZng50kxEqQTiJ2Zo3OsUrnwDGs45c0ckbKDixMAitUauUmEzosc0ckbmImAp7CJk56zHSrFeEUVzigzmAXBUFA1QLJm56TfK40CHl6tAaAzEfuk3OcF5cx0NWa0Y8kOKprgDgTYanAmc4IyiBlfCWgHMZ9idOYoJwzGgngbCrmKTLcI4Wp(lfGnJwzGgngbCrmKTLcI4Wp(lfGnJwzGgngbCrmKTLcI4WpgGwHUOmALbA0yeWfXq2wkiId)8PvRwo60rTPdm08HotsCYW7Wo9tDp6GfYyGeCiu51BOHIfilYw7XevI8VVJHzK)9XxWHqLxVHgkwGSiBThtujYFJkEX8VNauhnarpmTgf0OrqJA5iCFrfVyONWqd(Rbc4IyTHKQRHo20ae0Owoc3NVJHjg4VVm6mAp7CXGnpj2dq45sFuXBUG2MYfGLYvzauLBBYv)02PwosKrRmqJgZbdYPL0Iu7mALbA0yI4WpFA1QLJoDuB6qBKkIo9tDp6GbMCojqlOeWimaTcQZXhMq86bqD0aegGwouHlOrTCeohhqD0aega5CAjXRoae0Owoc3hhNbMCojqlOeWimaTcQZXxKz0kd0OXeXHF(0QvlhD6O20H2izos)Ot)u3JoyGjNtc0ckbmcdqRqxeFyMrRmqJgteh(XIkdvN7b6PD4GxpyOpA0biMgkwGmOehNhmeYHJ8pcgA(qNjjaljnWD1aJ4b7dI1leemv2dt8GZOvgOrJjId)aJanAoTdhSEHGGPYEyIhCgTYanAmrC4NNHKnGSnz0kd0OXeXHFQ3ivgOrJ01gWPJAthueDQbundCaZt7WHpTA1YrI2iveLrRmqJgteh(PEJuzGgnsxBaNoQnDaVi12QhCQo1aQMboG5PD4q9gkGkOKa02KFuns8IuBREWPsqr1xddt4z0kd0OXeXHFQ3ivgOrJ01gWPJAthSqk4udOAg4aMN2Hd1BOaQGscl1PdJKOGuDojaBpqnckQ(AyycpJwzGgnMio8t9gPYanAKU2aoDuB6GbCAho4OpYX3V)ZOvgOrJjId)8PvRwo60rTPdWf9j9xka7PFQ7rhGl6t4Vua2mALbA0yI4WpFA1QLJoDuB6aCrFsdqRqx0PFQ7rhGl6tyaAf6IYOvgOrJjId)8PvRwo60rTPdWf9jnaTmVckD6N6E0b4I(egGwMxbLYOvgOrJjId)uVrQmqJgPRnGth1MoaxeScyyLgqgDgTYanAmcfrh(0QvlhD6O20b8IuBP)25Kb15KOq40p19OdETEHGa02KFuns8IuBREWPsuKT2JHFOmCHTYZi(lWKJZ6fccqBt(r1iXlsTT6bNkrr2Apg(vgOrJWa0k0fjiEsShGKG2MI4VatiEjMRHnKOhP7nAXXrmxdBiHb50soepbCCeZ1WgsOdVYH4jWNpiwVqqaABYpQgjErQTvp4ujEWqQ3qbubLeG2M8JQrIxKAB1dovckQ(AyycpJwzGgngHIOio8JbOvqDUt7WbRxiimaTcQZjkkuKbRA5iiEnWKZjbAbLagHbOvqDo(pIJZJ6nuavqjbOTj)OAK4fP2w9GtLGIQVggMW9bXRh1BOaQGschVmTuJm4ic0dujuxBdBibfvFnmmHZXbAB6yhdd)LpRxiimaTcQZjkYw7XerK(YOvgOrJrOikId)yaAfuN70oCOEdfqfusaABYpQgjErQTvp4ujOO6RHHjCigyY5KaTGsaJWa0kOohFhocIxpSEHGa02KFuns8IuBREWPs8GHy9cbHbOvqDorrHImyvlhXX59tRwTCKaVi1w6VDozqDojkeG416fccdqRG6CIIS1Em8FehNbMCojqlOeWimaTcQZXxKqaQJgGWaiNtljE1bGGg1Yr4qSEHGWa0kOoNOiBThd))6ZNVmALbA0yekII4WpFA1QLJoDuB6GbOvqDoPF0aKb15KOq40p19OdQbuQtcJ8tfFyG)rfVy(3tSEHGa02KFuns8IuBREWPsyak7SVOIxRxiimaTcQZjkYw7X4jhDmdm5CsSQbq(IkEXrar4v8krbj5EdjkYw7X4j)6dI1leegGwb15ep4mALbA0yekII4WpgGwMxbLoTdh(0QvlhjWlsTL(BNtguNtIcbiFA1QLJegGwb15K(rdqguNtIcHmALbA0yekII4WpM3e6IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMyyuXatoNeOfucyIOiBThdefwYWsSZqiMRHnKOhPo8MrRmqJgJqrueh(rXvyq)rsJFTSpLXlZrsGwqjG5aMN2HdEaA25EGcXdLbA0iuCfg0FK04xlBjUARqjrpYGRHIfWXHJacfxHb9hjn(1YwIR2kusyak7m)hbbhbekUcd6psA8RLTexTvOKOiBThd)hLrRmqJgJqrueh(XgHMqx0PmEzosc0ckbmhW80oCOOqrgSQLJGa0ckbeG2MKaKeVj(8IjggHxdm5CsGwqjGryaAf6I8emf)6Z3XmWKZjbAbLaMikYw7XaXRxgc5Wr(hbtL9WefP48YXzGjNtc0ckbmcdqRqxe)hXX5LyUg2qIEKgKtlooI5Aydj6rAHay54iMRHnKOhP7nAbXdG6ObimONtIcsawsgqfzacAulhHZXz9cbbC12OcVvNulMontc)CgTeFQ7r8DiYF)7dIxdm5CsGwqjGryaAf6I4hZ)EIxmJaOoAacG)EK2i0ye0Owoc3NpiQbuQtcJ8tfF)(pQy9cbHbOvqDorr2Apgp549bXdRxiio3dEr4sYgg5NkBAasAOcAhfs8GHOWsgwID2xgTYanAmcfrrC4NaQyKefKJcEfDAhoOWsgwIDoJwzGgngHIOio8tPF0GEgzOOjk8EAhoy9cbbtL9Wep4mALbA0yekII4WpmYrgqRoP6AOJnnGt7WbVwVqqyaAfuNt8G54udOuNeg5Nk((9VpiEy9cbHb5mGMrIhmepSEHGGPYEyIhmeV9aOcg5uaHldnuSazr2Apg(ziKdh5Fem08HotsawsAG7Qbgrr2ApMi8CoUEaubJCkGWLHgkwGSiBThZXogMyG)8hzKCCmeYHJ8pcgA(qNjjaljnWD1aJ4bZX5bd9rJoaX0qXcKbL8LrRmqJgJqrueh(PhMwJcA0CAho416fccdqRG6CIhmhNAaL6KWi)uX3V)9bXdRxiimiNb0ms8GH4H1leemv2dt8GH4ThavWiNciCzOHIfilYw7XWpdHC4i)JGHMp0zscWssdCxnWikYw7XeHNZX1dGkyKtbeUm0qXcKfzR9yo2XWed8N)JIKJJHqoCK)rWqZh6mjbyjPbURgyepyoopyOpA0biMgkwGmOKpLbA0yekII4WpN7bViCPbURgyoTdhcnuSazr2Apg(X8xooVwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)r(7FooRxiiGR2gv4T6KAX0Pzs4NZOL4tDpIVdr(7FFqSEHGWa0kOoN4bdHHqoCK)rWuzpmrr2Apg((9FgTYanAmcfrrC4hdGCoTKbNw0PmEzosc0ckbmhW80oCOOqrgSQLJGaABscqs8M4dZFHyGjNtc0ckbmcdqRqxe)yiefwYWsSZq8A9cbbtL9WefzR9y4dZ)CCEy9cbbtL9WepyFz0kd0OXiuefXHF(0QvlhD6O20bgA(qNjjdn4nOrZPFQ7rhSEHGaUABuH3QtQftNMjHFoJwIp19i(J83)rf1ak1jHr(PcIxgc5Wr(hbtL9WefzR9yIaZ)8fAOybYIS1EmCCmeYHJ8pcMk7HjkYw7XeXr)5p0qXcKfzR9yGeAOybYIS1Em8H5r)54SEHGGPYEyIIS1Em855(GqmxdBirpsD4LJl0qXcKfzR9yo2XWmY)8J5Vz0kd0OXiuefXHFyO5dDMKaSK0a3vdmN2HdFA1QLJem08HotsgAWBqJgiQbuQtcJ8tf))(pJwzGgngHIOio8t4v8krbj5EdDAhoqmxdBirpsD4fIclzyj2ziwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)r(7FiEXraHIRWG(JKg)AzlXvBfkjan7Cpq548GH(OrhGyiwHCOcNJZatoNeOfucy4lsFz0kd0OXiuefXHFmaTcQZDAhoy9cbbAiawJeMkgbdA0iEWq8A9cbHbOvqDorrHImyvlhXXPgqPojmYpv85P)9LrRmqJgJqrueh(Xa0kOo3PD4ad9rJoaX0qXcKbLG8PvRwosWqZh6mjzObVbnAGWqihoY)iyO5dDMKaSK0a3vdmIIS1Em8dLHlSvE6jmQDEvdOuNeg5NQJ97FFqSEHGWa0kOoNOOqrgSQLJYOvgOrJrOikId)yaAzEfu60oCGH(OrhGyAOybYGsq(0QvlhjyO5dDMKm0G3GgnqyiKdh5Fem08HotsawsAG7Qbgrr2Apg(HYWf2kp9eg1oVQbuQtcJ8t1Xo6VpiwVqqyaAfuNt8GZOvgOrJrOikId)yaAzEfu60oCW6fcc0qaSgjZrAj)AtJgXdMJZddqRqxKqHLmSe7mhNxRxiiyQShMOiBThd))cX6fccMk7HjEWCCETEHGO0pAqpJmu0efEffzR9y4hkdxyR80tyu78QgqPojmYpvh7O)(Gy9cbrPF0GEgzOOjk8kEW(8b5tRwTCKWa0kOoN0pAaYG6CsuiaXatoNeOfucyegGwb154)OmALbA0yekII4Wpd5xAJqZPD4GxI5Aydj6rQdVqyiKdh5Femv2dtuKT2JHVF)ZX5LHvlOK5qKqkIHvlOKe02e))6JJJHvlOK5Wr(GOWsgwIDoJwzGgngHIOio8dw1fK2i0CAho4LyUg2qIEK6Wlegc5Wr(hbtL9WefzR9y473)CCEzy1ckzoejKIyy1ckjbTnX)V(44yy1ckzoCKpikSKHLyNZOvgOrJrOikId)eEoN0gHMt7WbVeZ1Wgs0JuhEHWqihoY)iyQShMOiBThdF)(NJZldRwqjZHiHuedRwqjjOTj()1hhhdRwqjZHJ8brHLmSe7CgTYanAmcfrrC4h)AvnQKOGKCVHYOvgOrJrOikId)8PvRwo60rTPdgGwHUizpsdYP1PFQ7rhmWKZjbAbLagHbOvOlIpmmIGdHkV2QbqfVYp19OJf5FFreCiu516fccdqlZRGssYgg5NkBAacdqzNpgg6lJwzGgngHIOio8J)sbypTdhiMRHnKW9gTKdXtahhXCnSHe6WRCiEcG8PvRwos0gjZr6hXXz9cbbXCnSHKgKtlrr2Apg(vgOrJWa0k0fjiEsShGKG2MGy9cbbXCnSHKgKtlXdMJJyUg2qIEKgKtliE8PvRwosyaAf6IK9iniNwCCwVqqWuzpmrr2Apg(vgOrJWa0k0fjiEsShGKG2MG4XNwTA5irBKmhPFeeRxiiyQShMOiBThd)epj2dqsqBtqSEHGGPYEyIhmhN1leeL(rd6zKHIMOWR4bdXatoNeRAaeF)fhpeVgyY5KaTGsad)hoIJZdG6ObimONtIcsawsgqfzacAulhH7JJZJpTA1YrI2izos)iiwVqqWuzpmrr2Apg(iEsShGKG2MYOvgOrJrOikId)yaAf6IYOvgOrJrOikId)uVrQmqJgPRnGth1MoeuNdGTEz0z0kd0OXiSqk4qPF0GEgzOOjk8EAhoy9cbbtL9Wep4mALbA0yewifeXHF(0QvlhD6O20bw1GbbEWN(PUhDWdRxiiSuNomsIcs15KaS9a1ihf8ks8GH4H1leewQthgjrbP6Csa2EGAKAX0Hep4mALbA0yewifeXHFuCfg0FK04xl7tz8YCKeOfucyoG5PD4G1leewQthgjrbP6Csa2EGAKJcEfjmaLDw(PUhXpg(hI1leewQthgjrbP6Csa2EGAKAX0HegGYol)u3J4hd)dXRh4iGqXvyq)rsJFTSL4QTcLeGMDUhOq8qzGgncfxHb9hjn(1YwIR2kus0Jm4AOybq86bociuCfg0FK04xlBjwsDcqZo3duooCeqO4kmO)iPXVw2sSK6efzR9y47iFCC4iGqXvyq)rsJFTSL4QTcLegGYoZ)rqWraHIRWG(JKg)AzlXvBfkjkYw7XW)VqWraHIRWG(JKg)AzlXvBfkjan7Cpq9LrRmqJgJWcPGio8dthg5KwVq40rTPdgGwouHFAho416fccl1PdJKOGuDojaBpqnYrbVIefzR9y4ddf)YXz9cbHL60HrsuqQoNeGThOgPwmDirr2Apg(WqXV(GOgqPojmYpv8DWt)dXldHC4i)JGPYEyIIS1Em855CCEziKdh5FeKnmYpvsl0GlkYw7XWNNdXdRxiio3dEr4sYgg5NkBAasAOcAhfs8GHWqF0OdqCM3Q1XNVmALbA0yewifeXHFmaTmVckDAho4XNwTA5ibRAWGapyiE96bdHC4i)JGHMp0zscWssdCxnWiEWCCE8PvRwosWqZh6mjzObVbnA448GH(OrhGyAOybYGs(G4LH(OrhGyAOybYGsCCEziKdh5Femv2dtuKT2JHppNJZldHC4i)JGSHr(PsAHgCrr2Apg(8CiEy9cbX5EWlcxs2Wi)uztdqsdvq7OqIhmeg6JgDaIZ8wTo(85ZhhNxgc5Wr(hbdnFOZKeGLKg4UAGr8GHWqihoY)iyQShMOifNxim0hn6aetdflqguYxgTYanAmclKcI4WpM3e6IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMhpefwYWsSZq8(PvRwosWQgmiWdMJZRAaL6KWi)uX)r)H4H1leemv2dt8G9XXXqihoY)iyQShMOifNxFz0kd0OXiSqkiId)yJqtOl6ugVmhjbAbLaMdyEAhouuOidw1YrqaAbLacqBtsasI3eFyEK4xikSKHLyNH49tRwTCKGvnyqGhmhNx1ak1jHr(PI)J(dXdRxiiyQShM4b7JJJHqoCK)rWuzpmrrkoV(G4H1leeN7bViCjzdJ8tLnnajnubTJcjEWz0kd0OXiSqkiId)yaKZPLm40IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMhFefzR9yGOWsgwIDgI3pTA1Yrcw1GbbEWCCQbuQtcJ8tf)h9NJJHqoCK)rWuzpmrrkoV(YOvgOrJryHuqeh(jGkgjrb5OGxrN2HdkSKHLyNZOvgOrJryHuqeh(j8kELOGKCVHoTdh8smxdBirpsD4LJJyUg2qcdYPLShjMCCeZ1Wgs4EJwYEKy6dIxpyOpA0biMgkwGmOehNx1ak1jHr(PIFp9xiE)0Qvlhjyvdge4bZXPgqPojmYpv8F0FoUpTA1YrI2ive5dI3pTA1YrcgA(qNjjoz4Dyq8GHqoCK)rWqZh6mjbyjPbURgyepyoop(0QvlhjyO5dDMK4KH3HbXdgc5Wr(hbtL9WepyF(8bXldHC4i)JGPYEyIIS1Em8D0Foo1ak1jHr(PIpp9pegc5Wr(hbtL9WepyiEziKdh5FeKnmYpvsl0GlkYw7XWVYanAegGwHUibXtI9aKe02ehNhm0hn6aeN5TAD8XXfAOybYIS1Em8J5FFq8IJacfxHb9hjn(1YwIR2kusuKT2JHpmKJZdg6JgDaIHyfYHkCFz0kd0OXiSqkiId)CUh8IWLg4UAG50oCWlXCnSHeU3OLCiEc44iMRHnKWGCAjhINaooI5Aydj0Hx5q8eWXz9cbHL60HrsuqQoNeGThOg5OGxrIIS1Em8HHIF54SEHGWsD6WijkivNtcW2duJulMoKOiBThdFyO4xoo1ak1jHr(PIpp9pegc5Wr(hbtL9WefP486dIxgc5Wr(hbtL9WefzR9y47O)CCmeYHJ8pcMk7HjksX51hhxOHIfilYw7XWpM)ZOvgOrJryHuqeh(HroYaA1jvxdDSPbCAho4vnGsDsyKFQ4Zt)dXR1leeN7bViCjzdJ8tLnnajnubTJcjEWCCEWqF0OdqCM3Q1Xhhhd9rJoaX0qXcKbL44SEHGWYHq4UNbiEWqSEHGWYHq4UNbikYw7XWFK)JWlg6jm0G)AGaUiwBiP6AOJnnabnQLJW95dIxpyOpA0biMgkwGmOehhdHC4i)JGHMp0zscWssdCxnWiEWCCHgkwGSiBThd)meYHJ8pcgA(qNjjaljnWD1aJOiBThtehphxOHIfilYw7XCSJHjg4p)r(pcVyONWqd(Rbc4IyTHKQRHo20ae0Owoc3NVmALbA0yewifeXHF6HP1OGgnN2HdEvdOuNeg5Nk(80)q8A9cbX5EWlcxs2Wi)uztdqsdvq7OqIhmhNhm0hn6aeN5TAD8XXXqF0OdqmnuSazqjooRxiiSCieU7zaIhmeRxiiSCieU7zaIIS1Em8F0)i8IHEcdn4VgiGlI1gsQUg6ytdqqJA5iCF(G41dg6JgDaIPHIfidkXXXqihoY)iyO5dDMKaSK0a3vdmIhmh3NwTA5ibdnFOZKeNm8omiHgkwGSiBThdFyIb(hrK)JWlg6jm0G)AGaUiwBiP6AOJnnabnQLJW9XXfAOybYIS1Em8ZqihoY)iyO5dDMKaSK0a3vdmIIS1EmrC8CCHgkwGSiBThd)h9pcVyONWqd(Rbc4IyTHKQRHo20ae0Owoc3NVmALbA0yewifeXHFyO5dDMKaSK0a3vdmN2HdE)0QvlhjyO5dDMK4KH3Hbj0qXcKfzR9y4dZJ(ZXz9cbbtL9WepyFq8A9cbHL60HrsuqQoNeGThOg5OGxrcdqzNLFQ7r8D0FooRxiiSuNomsIcs15KaS9a1i1IPdjmaLDw(PUhX3r)9XXfAOybYIS1Em8J5)mALbA0yewifeXHFmaTmVckDAhoWqF0OdqmnuSazqjiE)0QvlhjyO5dDMK4KH3HXXXqihoY)iyQShMOiBThd)y(3he1ak1jHr(PIVF)dHHqoCK)rWqZh6mjbyjPbURgyefzR9y4hZ)z0kd0OXiSqkiId)8PvRwo60rTPdQbgdcQIj2PFQ7rhiMRHnKOhP7nA5jyGJPmqJgHbOvOlsq8KypajbTnfHheZ1Wgs0J09gT8KJ)ykd0Or4VuawbXtI9aKe02ue)frEmdm5CsSQbqz0kd0OXiSqkiId)yaAzEfu60oCWBpaQGrofq4YqdflqwKT2JHFmKJZR1leeL(rd6zKHIMOWROiBThd)qz4cBLNEcJANx1ak1jHr(P6yh93heRxiik9Jg0ZidfnrHxXd2NpooVQbuQtcJ8tveFA1QLJeQbgdcQIjMNy9cbbXCnSHKgKtlrr2ApMiWrar4v8krbj5Edjan7SrwKT2JNeP4x(WmY)CCQbuQtcJ8tveFA1QLJeQbgdcQIjMNy9cbbXCnSHKU3OLOiBThte4iGi8kELOGKCVHeGMD2ilYw7XtIu8lFyg5FFqiMRHnKOhPo8cXRxpyiKdh5Femv2dt8G54yOpA0bioZB16aXdgc5Wr(hbzdJ8tL0cn4IhSpoog6JgDaIPHIfidk5dIxpyOpA0bi(ObGL3IJZdRxiiyQShM4bZXPgqPojmYpv85P)9XXz9cbbtL9WefzR9y4ddaXdRxiik9Jg0ZidfnrHxXdoJwzGgngHfsbrC4NH8lTrO50oCWR1leeeZ1Wgs6EJwIhmhNxgwTGsMdrcPigwTGssqBt8)RpoogwTGsMdh5dIclzyj25mALbA0yewifeXHFWQUG0gHMt7WbVwVqqqmxdBiP7nAjEWCCEzy1ckzoejKIyy1ckjbTnX)V(44yy1ckzoCKpikSKHLyNZOvgOrJryHuqeh(j8CoPncnN2HdETEHGGyUg2qs3B0s8G548YWQfuYCisifXWQfuscABI)F9XXXWQfuYC4iFquyjdlXoNrRmqJgJWcPGio8JFTQgvsuqsU3qz0kd0OXiSqkiId)yaAf6IoTdhiMRHnKOhP7nAXXrmxdBiHb50soepbCCeZ1WgsOdVYH4jGJZ6fcc)AvnQKOGKCVHepyieZ1Wgs0J09gT448A9cbbtL9WefzR9y4xzGgnc)LcWkiEsShGKG2MGy9cbbtL9WepyFz0kd0OXiSqkiId)4Vua2mALbA0yewifeXHFQ3ivgOrJ01gWPJAthcQZbWwVm6mALbA0ye4fP2w9Gt1HpTA1YrNoQnDWObscqYNHKgyY5o9tDp6GxRxiiaTn5hvJeVi12QhCQefzR9y4dkdxyR8mI)cmH4LyUg2qIEKwiawooI5Aydj6rAqoT44iMRHnKW9gTKdXtGpooRxiiaTn5hvJeVi12QhCQefzR9y4tzGgncdqRqxKG4jXEascABkI)cmH4LyUg2qIEKU3OfhhXCnSHegKtl5q8eWXrmxdBiHo8khINaF(448W6fccqBt(r1iXlsTT6bNkXdoJwzGgngbErQTvp4ufXHFmaTmVckDAho41JpTA1YrcJgijajFgsAGjNJJZR1leeL(rd6zKHIMOWROiBThd)qz4cBLNEcJANx1ak1jHr(P6yh93heRxiik9Jg0ZidfnrHxXd2Npoo1ak1jHr(PIpp9FgTYanAmc8IuBREWPkId)O4kmO)iPXVw2NY4L5ijqlOeWCaZt7WbpWraHIRWG(JKg)AzlXvBfkjan7CpqH4HYanAekUcd6psA8RLTexTvOKOhzW1qXcG41dCeqO4kmO)iPXVw2sSK6eGMDUhOCC4iGqXvyq)rsJFTSLyj1jkYw7XW3V(44WraHIRWG(JKg)AzlXvBfkjmaLDM)JGGJacfxHb9hjn(1YwIR2kusuKT2JH)JGGJacfxHb9hjn(1YwIR2kusaA25EGMrRmqJgJaVi12QhCQI4Wp2i0e6IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMrcXRxRxiiyQShMOiBThdF)cXR1leeL(rd6zKHIMOWROiBThdF)YX5H1leeL(rd6zKHIMOWR4b7JJZdRxiiyQShM4bZXPgqPojmYpv8F0FFq86H1leeN7bViCjzdJ8tLnnajnubTJcjEWCCQbuQtcJ8tf)h93hefwYWsSZ(YOvgOrJrGxKAB1dovrC4hZBcDrNY4L5ijqlOeWCaZt7WHIcfzWQwoccqlOeqaABscqs8M4dZiH41R1leemv2dtuKT2JHVFH416fcIs)Ob9mYqrtu4vuKT2JHVF548W6fcIs)Ob9mYqrtu4v8G9XX5H1leemv2dt8G54udOuNeg5Nk(p6VpiE9W6fcIZ9GxeUKSHr(PYMgGKgQG2rHepyoo1ak1jHr(PI)J(7dIclzyj2zFz0kd0OXiWlsTT6bNQio8JbqoNwYGtl6ugVmhjbAbLaMdyEAhouuOidw1YrqaAbLacqBtsasI3eFyE8q8616fccMk7HjkYw7XW3Vq8A9cbrPF0GEgzOOjk8kkYw7XW3VCCEy9cbrPF0GEgzOOjk8kEW(448W6fccMk7HjEWCCQbuQtcJ8tf)h93heVEy9cbX5EWlcxs2Wi)uztdqsdvq7OqIhmhNAaL6KWi)uX)r)9brHLmSe7SVmALbA0ye4fP2w9Gtveh(jGkgjrb5OGxrN2HdkSKHLyNZOvgOrJrGxKAB1dovrC4Ns)Ob9mYqrtu490oCW6fccMk7HjEWz0kd0OXiWlsTT6bNQio8Z5EWlcxAG7QbMt7WbVETEHGGyUg2qsdYPLOiBThdFy(NJZ6fccI5AydjDVrlrr2Apg(W8VpimeYHJ8pcMk7HjkYw7XW3r)9XXXqihoY)iyQShMOifN3mALbA0ye4fP2w9Gtveh(HroYaA1jvxdDSPbCAho416fcIZ9GxeUKSHr(PYMgGKgQG2rHepyoopyOpA0bioZB164JJJH(OrhGyAOybYGsCCFA1QLJeTrQiIJZ6fcclhcH7EgG4bdX6fcclhcH7EgGOiBThd)r(pcVyONWqd(Rbc4IyTHKQRHo20ae0Owoc3hepSEHGGPYEyIhmeV9aOcg5uaHldnuSazr2Apg(ziKdh5Fem08HotsawsAG7Qbgrr2ApMi8CoUEaubJCkGWLHgkwGSiBThd)rgjhxpaQGrofq4YqdflqwKT2J5yhdtmWF(Jmsoogc5Wr(hbdnFOZKeGLKg4UAGr8G548GH(OrhGyAOybYGs(YOvgOrJrGxKAB1dovrC4NEyAnkOrZPD4GxRxiio3dEr4sYgg5NkBAasAOcAhfs8G548GH(OrhG4mVvRJpoog6JgDaIPHIfidkXX9PvRwos0gPIiooRxiiSCieU7zaIhmeRxiiSCieU7zaIIS1Em8F0)i8IHEcdn4VgiGlI1gsQUg6ytdqqJA5iCFq8W6fccMk7HjEWq82dGkyKtbeUm0qXcKfzR9y4NHqoCK)rWqZh6mjbyjPbURgyefzR9yIWZ546bqfmYPacxgAOybYIS1Em8FuKCC9aOcg5uaHldnuSazr2ApMJDmmXa)5)Oi54yiKdh5Fem08HotsawsAG7QbgXdMJZdg6JgDaIPHIfidk5lJwzGgngbErQTvp4ufXHF(0QvlhD6O20bgA(qNjjdn4nOrZPFQ7rhyOpA0biMgkwGmOeeVwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)rIH)H4LHqoCK)rWuzpmrr2ApMiW8pF9aOcg5uaHldnuSazr2Apgoogc5Wr(hbtL9WefzR9yI4O)83dGkyKtbeUm0qXcKfzR9yG0dGkyKtbeUm0qXcKfzR9y4dZJ(ZXz9cbbtL9WefzR9y4ZZ9bX6fccI5AydjniNwIIS1Em8H5FoUEaubJCkGWLHgkwGSiBThZXogMr(NFm)1xgTYanAmc8IuBREWPkId)8PvRwo60rTPdg9JKbujzQSh2PFQ7rh86bdHC4i)JGPYEyIIuCE5484tRwTCKGHMp0zsYqdEdA0aHH(OrhGyAOybYGs(YOvgOrJrGxKAB1dovrC4hgA(qNjjaljnWD1aZPD4WNwTA5ibdnFOZKKHg8g0ObIAaL6KWi)uXpg(pJwzGgngbErQTvp4ufXHFcVIxjkij3BOt7WbI5Aydj6rQdVquyjdlXodXlociuCfg0FK04xlBjUARqjbOzN7bkhNhm0hn6aedXkKdv4(G8PvRwosy0psgqLKPYEyz0kd0OXiWlsTT6bNQio8JbOL5vqPt7Wbg6JgDaIPHIfidkb5tRwTCKGHMp0zsYqdEdA0arnGsDsyKFQ47ag(hcdHC4i)JGHMp0zscWssdCxnWikYw7XWpugUWw5PNWO25vnGsDsyKFQo2r)9LrRmqJgJaVi12QhCQI4Wpd5xAJqZPD4GxRxiiiMRHnK09gTepyooVmSAbLmhIesrmSAbLKG2M4)xFCCmSAbLmhoYhefwYWsSZq(0Qvlhjm6hjdOsYuzpSmALbA0ye4fP2w9Gtveh(bR6csBeAoTdh8A9cbbXCnSHKU3OL4bdXdg6JgDaIZ8wToCCETEHG4Cp4fHljByKFQSPbiPHkODuiXdgcd9rJoaXzERwhFCCEzy1ckzoejKIyy1ckjbTnX)V(44yy1ckzoCehN1leemv2dt8G9brHLmSe7mKpTA1YrcJ(rYaQKmv2dlJwzGgngbErQTvp4ufXHFcpNtAJqZPD4GxRxiiiMRHnK09gTepyiEWqF0OdqCM3Q1HJZR1leeN7bViCjzdJ8tLnnajnubTJcjEWqyOpA0bioZB164JJZldRwqjZHiHuedRwqjjOTj()1hhhdRwqjZHJ44SEHGGPYEyIhSpikSKHLyNH8PvRwosy0psgqLKPYEyz0kd0OXiWlsTT6bNQio8JFTQgvsuqsU3qz0kd0OXiWlsTT6bNQio8JbOvOl60oCGyUg2qIEKU3OfhhXCnSHegKtl5q8eWXrmxdBiHo8khINaooRxii8Rv1OsIcsY9gs8GHy9cbbXCnSHKU3OL4bZX516fccMk7HjkYw7XWVYanAe(lfGvq8KypajbTnbX6fccMk7HjEW(YOvgOrJrGxKAB1dovrC4h)LcWMrRmqJgJaVi12QhCQI4Wp1BKkd0Or6Ad40rTPdb15ayRxgDgTYanAmIG6CaS17GbOL5vqPt7WbpQ3qbubLewQthgjrbP6Csa2EGAeuu91WWeEgTYanAmIG6CaS1lId)yEtOl6ugVmhjbAbLaMdyEAhoGJacBeAcDrIIS1Em8vKT2JjJwzGgngrqDoa26fXHFSrOj0fLrNrRmqJgJaUiyfWWknGd2i0e6IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMrcXR1leemv2dtuKT2JHVF548W6fccMk7HjEWCCQbuQtcJ8tf)h93hefwYWsSZz0kd0OXiGlcwbmSsdiId)yEtOl6ugVmhjbAbLaMdyEAhouuOidw1YrqaAbLacqBtsasI3eFygjeVwVqqWuzpmrr2Apg((LJZdRxiiyQShM4bZXPgqPojmYpv8F0FFquyjdlXoNrRmqJgJaUiyfWWknGio8JbqoNwYGtl6ugVmhjbAbLaMdyEAhouuOidw1YrqaAbLacqBtsasI3eFygjeVwVqqWuzpmrr2Apg((LJZdRxiiyQShM4bZXPgqPojmYpv8F0FFquyjdlXoNrRmqJgJaUiyfWWknGio8tavmsIcYrbVIoTdhuyjdlXoNrRmqJgJaUiyfWWknGio8dJCKb0QtQUg6ytd40oCWRAaL6KWi)uXNN(NJZ6fcclhcH7EgG4bdX6fcclhcH7EgGOiBThd)rE8(G4H1leemv2dt8GZOvgOrJraxeScyyLgqeh(PhMwJcA0CAho4vnGsDsyKFQ4Zt)ZXz9cbHLdHWDpdq8GHy9cbHLdHWDpdquKT2JH)JoEFq8W6fccMk7HjEWz0kd0OXiGlcwbmSsdiId)8PvRwo60rTPdg9JKbujzQSh2PFQ7rh8GHqoCK)rWuzpmrrkoVz0kd0OXiGlcwbmSsdiId)eEfVsuqsU3qN2HdeZ1Wgs0JuhEHOWsgwIDgYNwTA5iHr)izavsMk7HLrRmqJgJaUiyfWWknGio8dthg5KwVq40rTPdgGwouHFAhoy9cbHbOLdv4IIS1Em8F8q8A9cbbXCnSHKgKtlXdMJZ6fccI5AydjDVrlXd2he1ak1jHr(PIpp9FgTYanAmc4IGvadR0aI4WpgGwMxbLoTdh86HgfQAajmGI0Z9avAaAzeLoN54SEHGGPYEyIIS1Em8t8KypajbTnXX5bCrFcdqlZRGs(G416fccMk7HjEWCCQbuQtcJ8tfFE6FieZ1Wgs0JuhE9LrRmqJgJaUiyfWWknGio8JbOL5vqPt7WbVEOrHQgqcdOi9CpqLgGwgrPZzooRxiiyQShMOiBThd)epj2dqsqBtCCE8PvRwosax0N0a0Y8kOKpia1rdqyaA5qfUGg1Yr4q8A9cbHbOLdv4IhmhNAaL6KWi)uXNN(3heRxiimaTCOcxyak7m)hbXR1leeeZ1WgsAqoTepyooRxiiiMRHnK09gTepyFqyiKdh5Femv2dtuKT2JHpppJwzGgngbCrWkGHvAarC4hdqlZRGsN2HdE9qJcvnGegqr65EGknaTmIsNZCCwVqqWuzpmrr2Apg(jEsShGKG2M448aUOpHbOL5vqjFqSEHGGyUg2qsdYPLOiBThdFEoeI5Aydj6rAqoTG4bqD0aegGwouHlOrTCeoegc5Wr(hbtL9WefzR9y4ZZZOvgOrJraxeScyyLgqeh(zi)sBeAoTdh8A9cbbXCnSHKU3OL4bZX5LHvlOK5qKqkIHvlOKe02e))6JJJHvlOK5Wr(GOWsgwIDgYNwTA5iHr)izavsMk7HLrRmqJgJaUiyfWWknGio8dw1fK2i0CAho416fccI5AydjDVrlXdMJZldRwqjZHiHuedRwqjjOTj()1hhhdRwqjZHJ44SEHGGPYEyIhSpikSKHLyNH8PvRwosy0psgqLKPYEyz0kd0OXiGlcwbmSsdiId)eEoN0gHMt7WbVwVqqqmxdBiP7nAjEWCCEzy1ckzoejKIyy1ckjbTnX)V(44yy1ckzoCehN1leemv2dt8G9brHLmSe7mKpTA1YrcJ(rYaQKmv2dlJwzGgngbCrWkGHvAarC4h)AvnQKOGKCVHYOvgOrJraxeScyyLgqeh(Xa0k0fDAho4vJcvnGegqr65EGknaTmIsNZqSEHGGPYEyIIS1Em8r8KypajbTnbbUOpH)sby9XX51dnku1asyafPN7bQ0a0YikDoZXz9cbbtL9WefzR9y4N4jXEascABIJZd4I(egGwHUiFq8smxdBirps3B0IJJyUg2qcdYPLCiEc44iMRHnKqhELdXtahN1lee(1QAujrbj5EdjEWqSEHGGyUg2qs3B0s8G548A9cbbtL9WefzR9y4xzGgnc)LcWkiEsShGKG2MGy9cbbtL9WepyF(448QrHQgqcC1)0duP5nIsNZ8fjeRxiiiMRHnK0GCAjkYw7XW3Vq8W6fccC1)0duP5nIIS1Em8PmqJgH)sbyfepj2dqsqBt(YO9SZfdEixErVCbi05CJbKZPvUyWQ6a40C5f9YfUqwQLJ3C9RdixdYMYngOvqDUCFWG2MecrgTYanAmc4IGvadR0aI4WpgGwb15oTdhaQJgGWaiNtljE1bGGg1Yr4qSEHGWa0kOoNOOqrgSQLJGeAOybYIS1Em8z9cbHbOvqDob(RuqJgiE9GyUg2qIEK6WlhN1leegGwMxbLKKnmYpv20aepyFz0kd0OXiGlcwbmSsdiId)4Vua2mALbA0yeWfbRagwPbeXHFQ3ivgOrJ01gWPJAthcQZbWwVm6mALbA0yegWbfxHb9hjn(1Y(ugVmhjbAbLaMdyEAho4bociuCfg0FK04xlBjUARqjbOzN7bkepugOrJqXvyq)rsJFTSL4QTcLe9idUgkwaeVEGJacfxHb9hjn(1YwILuNa0SZ9aLJdhbekUcd6psA8RLTelPorr2Apg((1hhhociuCfg0FK04xlBjUARqjHbOSZ8FeeCeqO4kmO)iPXVw2sC1wHsIIS1Em8FeeCeqO4kmO)iPXVw2sC1wHscqZo3d0mALbA0yegqeh(XgHMqx0PmEzosc0ckbmhW80oCOOqrgSQLJGa0ckbeG2MKaKeVj(WmsiETEHGGPYEyIIS1Em89leVwVqqu6hnONrgkAIcVIIS1Em89lhNhwVqqu6hnONrgkAIcVIhSpoopSEHGGPYEyIhmhNAaL6KWi)uX)r)9bXRhwVqqCUh8IWLKnmYpv20aK0qf0okK4bZXPgqPojmYpv8F0FFquyjdlXoNrRmqJgJWaI4WpM3e6IoLXlZrsGwqjG5aMN2HdffkYGvTCeeGwqjGa02KeGK4nXhMrcXR1leemv2dtuKT2JHVFH416fcIs)Ob9mYqrtu4vuKT2JHVF548W6fcIs)Ob9mYqrtu4v8G9XX5H1leemv2dt8G54udOuNeg5Nk(p6VpiE9W6fcIZ9GxeUKSHr(PYMgGKgQG2rHepyoo1ak1jHr(PI)J(7dIclzyj25mALbA0yegqeh(XaiNtlzWPfDkJxMJKaTGsaZbmpTdhkkuKbRA5iiaTGsabOTjjajXBIpmpEiETEHGGPYEyIIS1Em89leVwVqqu6hnONrgkAIcVIIS1Em89lhNhwVqqu6hnONrgkAIcVIhSpoopSEHGGPYEyIhmhNAaL6KWi)uX)r)9bXRhwVqqCUh8IWLKnmYpv20aK0qf0okK4bZXPgqPojmYpv8F0FFquyjdlXoNrRmqJgJWaI4WpbuXijkihf8k60oCqHLmSe7CgTYanAmcdiId)u6hnONrgkAIcVN2HdwVqqWuzpmXdoJwzGgngHbeXHFo3dEr4sdCxnWCAho41R1leeeZ1WgsAqoTefzR9y4dZ)CCwVqqqmxdBiP7nAjkYw7XWhM)9bHHqoCK)rWuzpmrr2Apg(o6peVwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)rIH)548OEdfqfusaxTnQWB1j1IPtZKWpNrlbfvFnmmH7ZhhN1leeWvBJk8wDsTy60mj8Zz0s8PUhX3Hi98)CCmeYHJ8pcMk7HjksX5fIx1ak1jHr(PIpp9ph3NwTA5irBKkI8LrRmqJgJWaI4WpmYrgqRoP6AOJnnGt7WbVQbuQtcJ8tfFE6FiETEHG4Cp4fHljByKFQSPbiPHkODuiXdMJZdg6JgDaIZ8wTo(44yOpA0biMgkwGmOeh3NwTA5irBKkI44SEHGWYHq4UNbiEWqSEHGWYHq4UNbikYw7XWFK)JWRxp1tQ3qbubLeWvBJk8wDsTy60mj8Zz0sqr1xddt4(IWlg6jm0G)AGaUiwBiP6AOJnnabnQLJW95ZhepSEHGGPYEyIhmeVHgkwGSiBThd)meYHJ8pcgA(qNjjaljnWD1aJOiBThteEohxOHIfilYw7XWFKrgHxp1t8A9cbbC12OcVvNulMontc)CgTeFQ7r8H5))(8XXfAOybYIS1Emh7yyIb(ZFKrYXXqihoY)iyO5dDMKaSK0a3vdmIhmhNhm0hn6aetdflqguYxgTYanAmcdiId)0dtRrbnAoTdh8QgqPojmYpv85P)H416fcIZ9GxeUKSHr(PYMgGKgQG2rHepyoopyOpA0bioZB164JJJH(OrhGyAOybYGsCCFA1QLJeTrQiIJZ6fcclhcH7EgG4bdX6fcclhcH7EgGOiBThd)h9pcVE9upPEdfqfusaxTnQWB1j1IPtZKWpNrlbfvFnmmH7lcVyONWqd(Rbc4IyTHKQRHo20ae0Owoc3NpFq8W6fccMk7HjEWq8gAOybYIS1Em8ZqihoY)iyO5dDMKaSK0a3vdmIIS1Emr45CCHgkwGSiBThd)hfzeE9upXR1leeWvBJk8wDsTy60mj8Zz0s8PUhXhM))7ZhhxOHIfilYw7XCSJHjg4p)hfjhhdHC4i)JGHMp0zscWssdCxnWiEWCCEWqF0OdqmnuSazqjFz0kd0OXimGio8ZNwTA5Oth1MoWqZh6mjzObVbnAo9tDp6ad9rJoaX0qXcKbLG416fcc4QTrfERoPwmDAMe(5mAj(u3J4psm8peVmeYHJ8pcMk7HjkYw7XebM)5l0qXcKfzR9y44yiKdh5Femv2dtuKT2JjIJ(ZFOHIfilYw7Xaj0qXcKfzR9y4dZJ(ZXz9cbbtL9WefzR9y4ZZ9bX6fccI5AydjniNwIIS1Em8H5FoUqdflqwKT2J5yhdZi)ZpM)6lJwzGgngHbeXHF(0QvlhD6O20bJ(rYaQKmv2d70p19OdE9GHqoCK)rWuzpmrrkoVCCE8PvRwosWqZh6mjzObVbnAGWqF0OdqmnuSazqjFz0kd0OXimGio8ddnFOZKeGLKg4UAG50oC4tRwTCKGHMp0zsYqdEdA0arnGsDsyKFQ4)O)z0kd0OXimGio8t4v8krbj5EdDAhoqmxdBirpsD4fIclzyj2ziwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)rIH)H4fhbekUcd6psA8RLTexTvOKa0SZ9aLJZdg6JgDaIHyfYHkCFq(0Qvlhjm6hjdOsYuzpSmALbA0yegqeh(Xa0kOo3PD4G1leeOHaynsyQyemOrJ4bdX6fccdqRG6CIIcfzWQwokJwzGgngHbeXHFy6WiN06fcNoQnDWa0YHk8t7WbRxiimaTCOcxuKT2JH)FH416fccI5AydjniNwIIS1Em89lhN1leeeZ1Wgs6EJwIIS1Em89RpiQbuQtcJ8tfFE6)mALbA0yegqeh(Xa0Y8kO0PD4ad9rJoaX0qXcKbLG8PvRwosWqZh6mjzObVbnAGWqihoY)iyO5dDMKaSK0a3vdmIIS1Em8dLHlSvE6jmQDEvdOuNeg5NQJD0FFz0kd0OXimGio8JbOvqDUt7WbG6ObimaY50sIxDaiOrTCeoepaQJgGWa0YHkCbnQLJWHy9cbHbOvqDorrHImyvlhbXR1leeeZ1Wgs6EJwIIS1Em8D8qiMRHnKOhP7nAbXRh1BOaQGsc4QTrfERoPwmDAMe(5mAjOrTCeohN1leeWvBJk8wDsTy60mj8Zz0s8PUhXFK)(3hhNxpQ3qbubLeWvBJk8wDsTy60mj8Zz0sqJA5iCooRxiiGR2gv4T6KAX0Pzs4NZOL4tDpIVdr(7FFqudOuNeg5Nk(80)CC4iGqXvyq)rsJFTSL4QTcLefzR9y4ddWXPmqJgHIRWG(JKg)AzlXvBfkj6rgCnuSaFq8GHqoCK)rWuzpmrrkoVz0kd0OXimGio8JbOL5vqPt7WbRxiiqdbWAKmhPL8RnnAepyooRxiio3dEr4sYgg5NkBAasAOcAhfs8G54SEHGGPYEyIhmeVwVqqu6hnONrgkAIcVIIS1Em8dLHlSvE6jmQDEvdOuNeg5NQJD0FFqSEHGO0pAqpJmu0efEfpyoopSEHGO0pAqpJmu0efEfpyiEWqihoY)ik9Jg0ZidfnrHxrrkoVCCEWqF0Odq8rdalVLpoo1ak1jHr(PIpp9peI5Aydj6rQdVz0kd0OXimGio8JbOL5vqPt7WbG6ObimaTCOcxqJA5iCiETEHGWa0YHkCXdMJtnGsDsyKFQ4Zt)7dI1leegGwouHlmaLDM)JG416fccI5AydjniNwIhmhN1leeeZ1Wgs6EJwIhSpiwVqqaxTnQWB1j1IPtZKWpNrlXN6Ee)r65)H4LHqoCK)rWuzpmrr2Apg(W8phNhFA1QLJem08HotsgAWBqJgim0hn6aetdflqguYxgTYanAmcdiId)yaAzEfu60oCWR1leeWvBJk8wDsTy60mj8Zz0s8PUhXFKE(FooRxiiGR2gv4T6KAX0Pzs4NZOL4tDpI)i)9peG6ObimaY50sIxDaiOrTCeUpiwVqqqmxdBiPb50suKT2JHpphcXCnSHe9iniNwq8W6fcc0qaSgjmvmcg0Or8GH4bqD0aegGwouHlOrTCeoegc5Wr(hbtL9WefzR9y4ZZH4LHqoCK)rCUh8IWLg4UAGruKT2JHppNJZdg6JgDaIZ8wTo(YOvgOrJryarC4NH8lTrO50oCWR1leeeZ1Wgs6EJwIhmhNxgwTGsMdrcPigwTGssqBt8)RpoogwTGsMdh5dIclzyj2ziFA1QLJeg9JKbujzQShwgTYanAmcdiId)GvDbPncnN2HdETEHGGyUg2qs3B0s8GH4bd9rJoaXzERwhooVwVqqCUh8IWLKnmYpv20aK0qf0okK4bdHH(OrhG4mVvRJpooVmSAbLmhIesrmSAbLKG2M4)xFCCmSAbLmhoIJZ6fccMk7HjEW(GOWsgwIDgYNwTA5iHr)izavsMk7HLrRmqJgJWaI4WpHNZjTrO50oCWR1leeeZ1Wgs6EJwIhmepyOpA0bioZB16WX516fcIZ9GxeUKSHr(PYMgGKgQG2rHepyim0hn6aeN5TAD8XX5LHvlOK5qKqkIHvlOKe02e))6JJJHvlOK5WrCCwVqqWuzpmXd2hefwYWsSZq(0Qvlhjm6hjdOsYuzpSmALbA0yegqeh(XVwvJkjkij3BOmALbA0yegqeh(Xa0k0fDAhoqmxdBirps3B0IJJyUg2qcdYPLCiEc44iMRHnKqhELdXtahN1lee(1QAujrbj5EdjEWqSEHGGyUg2qs3B0s8G548A9cbbtL9WefzR9y4xzGgnc)LcWkiEsShGKG2MGy9cbbtL9WepyFz0kd0OXimGio8J)sbyZOvgOrJryarC4N6nsLbA0iDTbC6O20HG6CaS17cUG7fa]] )


end