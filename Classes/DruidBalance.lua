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


    spec:RegisterPack( "Balance", 20201029, [[dG05QdqiQGhrfk1LuHYMaXNGcPmkQOtrLSkQq8kHWSurClHKyxe(LQkgMQQogu0YeIEMkKPbfQRPQsBdkeFJkunovOQZrfsRJkumpuvDpvW(qv5GuHsSqufEOqsnrOqcDrOqc6JqHK6KqHuTsHuZufQStvK(juibgkuirlLkuspvOMkuWxHcjzVQ0FjAWkDyslMsEmktgQUmYMf8zqA0qPtl1RvrnBQ62uQDR43qgoOoUqsA5sEofth46QY2vv(ovQXJQOZJQ06fsmFuz)I(I5fd3yCfq3tJ8FK)X8)r)f))hPJhPJFJb8ct3yyLDwHs34rTPBmpuVom6gdR86rk(fd3yd6vm6gJfaGnoMF(bAdW(SemK9pM2(5vqJgwPbWpM2M9Zn261Eag95ADJXvaDpnY)r(hZ)h9x8)FKoEKy8nwFaSO6gh32r9ngBJJtZ16gJtg2n2XoxEOEDyuUyuSEnEgTJDUyuadGSOk3iD0tYnY)r(pJoJ2Xo3OgRoqjJJjJ2Xo3OsUowWXj8CJrETYLhKAlYODSZnQKBuJvhOeEUaTGsazhYLPgYKlaLlJxMNKaTGsaJiJ2Xo3OsUowjB0hHN7BgIrgJw8M7NwTA5jtUoBbjojx4I(KgGwMxbLYnQWxUWf9jmaTmVck5sCJ9TbyUy4gdxedzBPGlgUNI5fd3yLbA0CJTrO5CpYaQSVX0OwEc)YJl4EAKxmCJvgOrZn2DPaS3yAulpHF5XfCp9OlgUXkd0O5g7Uua2BmnQLNWV84cUNIXxmCJvgOrZn2a0k0fDJPrT8e(LhxW90FVy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXwiJjxi5g8iuLRZCDMBOHIfilYw7XKBuj3i)NRRC)jxmJ8FUUYLVCdEeQY1zUoZn0qXcKfzR9yYnQKBK)MBujxN5I5)CDKCbQNgGOhMwJcA0iOrT8eEUUYnQKRZCX4CDKCzOb)1abCrS2qs13qhBAacAulpHNRRCDL7p5I5X)pxx34pTKJAt3ygA(qNjjoz4DyxWfCJTqk4IH7PyEXWnMg1Yt4xECJzvdOQ1BS1leemv2dt8GVXkd0O5gx6hnONrgkAIcVxW90iVy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXoKR1leewQxhgjrbP69sa2EGAKJcEfjEW5cjxhY16fccl1RdJKOGu9EjaBpqnsTy6qIh8n(tl5O20nMvnyqGh8fCp9OlgUX0OwEc)YJBmRAavTEJDMR1leewQxhgjrbP69sa2EGAKJcEfjkYw7XKlF5IXIFZLJlxRxiiSuVomsIcs17LaS9a1i1IPdjkYw7XKlF5IXIFZ1vUqYvnGs9syKBQYLVd56O)ZfsUoZLHqECK7rWuzpmrr2ApMC5lxhpxoUCDMldH84i3JGSHrUPsAHgCrr2ApMC5lxhpxi56qUwVqqCUh8IWLKnmYnv20aK0qf0okK4bNlKCzOpA0bioZB16KRRCDDJvgOrZnMPdJ8sRxiCJTEHGCuB6gBaA5rf(fCpfJVy4gtJA5j8lpUXSQbu16n2HC)0Qvlpjyvdge4bNlKCDMRZCDixgc5XrUhbdnFOZKeGLKg4UAGr8GZLJlxhY9tRwT8KGHMp0zsYqdEdA0KlhxUoKld9rJoaX0qXcKbLY1vUqY1zUm0hn6aetdflqgukxoUCDMldH84i3JGPYEyIIS1Em5YxUoEUCC56mxgc5XrUhbzdJCtL0cn4IIS1Em5YxUoEUqY1HCTEHG4Cp4fHljByKBQSPbiPHkODuiXdoxi5YqF0OdqCM3Q1jxx56kxx56kxoUCDMldH84i3JGHMp0zscWssdCxnWiEW5cjxgc5XrUhbtL9WefP48MlKCzOpA0biMgkwGmOuUUUXkd0O5gBaAzEfu6cUN(7fd3yAulpHF5XnwzGgn3yfxHb9hjnU1Y(gZQgqvR3yhYfhbekUcd6psACRLTexTvOKa0SZ9anxi56qUkd0OrO4kmO)iPXTw2sC1wHsIEKbFdflixi56mxhYfhbekUcd6psACRLTelPEbOzN7bAUCC5IJacfxHb9hjnU1YwILuVOiBThtU8L7V56kxoUCXraHIRWG(JKg3AzlXvBfkjmaLDox(Z9OCHKlociuCfg0FK04wlBjUARqjrr2ApMC5p3JYfsU4iGqXvyq)rsJBTSL4QTcLeGMDUhO3ygVmpjbAbLaM7PyEb3tXixmCJPrT8e(Lh3yLbA0CJnVj0fDJzvdOQ1BCrHImyvlpLlKCbAbLacqBtsasI3uU8LlMyKCHKRclzyj25CHKRZC)0Qvlpjyvdge4bNlhxUoZvnGs9syKBQYL)Cp6FUqY1HCTEHGGPYEyIhCUUYLJlxgc5XrUhbtL9WefP48MRRBmJxMNKaTGsaZ9umVG7Po(fd3yAulpHF5XnwzGgn3yBeAcDr3yw1aQA9gxuOidw1Yt5cjxGwqjGa02KeGK4nLlF5I5rIFZfsUkSKHLyNZfsUoZ9tRwT8KGvnyqGhCUCC56mx1ak1lHrUPkx(Z9O)5cjxhY16fccMk7HjEW56kxoUCziKhh5Eemv2dtuKIZBUUYfsUoKR1leeN7bViCjzdJCtLnnajnubTJcjEW3ygVmpjbAbLaM7PyEb3tp(lgUX0OwEc)YJBSYanAUXga59AjdETOBmRAavTEJlkuKbRA5PCHKlqlOeqaABscqs8MYLVCXeJKBe5wKT2Jjxi5QWsgwIDoxi56m3pTA1Ytcw1GbbEW5YXLRAaL6LWi3uLl)5E0)C54YLHqECK7rWuzpmrrkoV566gZ4L5jjqlOeWCpfZl4EQJEXWnMg1Yt4xECJzvdOQ1BSclzyj25BSYanAUXbuXijkihf8k6cUNI5)lgUX0OwEc)YJBmRAavTEJDMlX8nSHe9i1H3C54YLy(g2qcdYRLShjM5YXLlX8nSHe(3OLShjM56kxi56mxhYLH(OrhGyAOybYGs5YXLRZCvdOuVeg5MQC5pxh93CHKRZC)0Qvlpjyvdge4bNlhxUQbuQxcJCtvU8N7r)ZLJl3pTA1YtI2iveLRRCHKRZC)0QvlpjyO5dDMK4KH3HLlKCDixgc5XrUhbdnFOZKeGLKg4UAGr8GZLJlxhY9tRwT8KGHMp0zsItgEhwUqY1HCziKhh5Eemv2dt8GZ1vUUY1vUqY1zUmeYJJCpcMk7HjkYw7XKlF5E0)C54YvnGs9syKBQYLVCD0)5cjxgc5XrUhbtL9Wep4CHKRZCziKhh5EeKnmYnvsl0GlkYw7XKl)5QmqJgHbOvOlsq8KypajbTnLlhxUoKld9rJoaXzERwNCDLlhxUHgkwGSiBThtU8NlM)Z1vUqY1zU4iGqXvyq)rsJBTSL4QTcLefzR9yYLVCX4C54Y1HCzOpA0bigIvipQWZ11nwzGgn34WR4vIcsY)g6cUNIjMxmCJPrT8e(Lh3yw1aQA9g7mxI5Bydj8Vrl5q8eKlhxUeZ3WgsyqETKdXtqUCC5smFdBiHo8khINGC54Y16fccl1RdJKOGu9EjaBpqnYrbVIefzR9yYLVCXyXV5YXLR1leewQxhgjrbP69sa2EGAKAX0HefzR9yYLVCXyXV5YXLRAaL6LWi3uLlF56O)ZfsUmeYJJCpcMk7HjksX5nxx5cjxN5YqipoY9iyQShMOiBThtU8L7r)ZLJlxgc5XrUhbtL9WefP48MRRC54Yn0qXcKfzR9yYL)CX8)nwzGgn34Z9GxeU0a3vdmxW9umJ8IHBmnQLNWV84gZQgqvR3yN5QgqPEjmYnv5YxUo6)CHKRZCTEHG4Cp4fHljByKBQSPbiPHkODuiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmOuUCC5A9cbHLhHW9pdq8GZfsUwVqqy5riC)ZaefzR9yYL)CJ8FUrKRZCX4CDKCzOb)1abCrS2qs13qhBAacAulpHNRRCDLlKCDMRd5YqF0OdqmnuSazqPC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Yn0qXcKfzR9yYL)CziKhh5Eem08HotsawsAG7Qbgrr2ApMCJixmsUCC5gAOybYIS1Em5ESCX84)Nl)5g5)CJixN5IX56i5Yqd(Rbc4IyTHKQVHo20ae0OwEcpxx566gRmqJMBmJ8Kb0QxQ(g6ytd4cUNI5rxmCJPrT8e(Lh3yw1aQA9g7mx1ak1lHrUPkx(Y1r)NlKCDMR1leeN7bViCjzdJCtLnnajnubTJcjEW5YXLRd5YqF0OdqCM3Q1jxx5YXLld9rJoaX0qXcKbLYLJlxRxiiS8ieU)zaIhCUqY16fcclpcH7FgGOiBThtU8N7r)ZnICDMlgNRJKldn4VgiGlI1gsQ(g6ytdqqJA5j8CDLRRCHKRZCDixg6JgDaIPHIfidkLlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUFA1QLNem08HotsCYW7WYfsUHgkwGSiBThtU8LlMh))CJi3i)NBe56mxmoxhjxgAWFnqaxeRnKu9n0XMgGGg1Yt456kxoUCdnuSazr2ApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKT2Jj3iYfJKlhxUHgkwGSiBThtU8N7r)ZnICDMlgNRJKldn4VgiGlI1gsQ(g6ytdqqJA5j8CDLRRBSYanAUX9W0AuqJMl4EkMy8fd3yAulpHF5XnMvnGQwVXoZ9tRwT8KGHMp0zsItgEhwUqYn0qXcKfzR9yYLVCX8O)5YXLR1leemv2dt8GZ1vUqY1zUwVqqyPEDyKefKQ3lby7bQrok4vKWau2z5N6FuU8L7r)ZLJlxRxiiSuVomsIcs17LaS9a1i1IPdjmaLDw(P(hLlF5E0)CDLlhxUHgkwGSiBThtU8NlM)VXkd0O5gZqZh6mjbyjPbURgyUG7Py(7fd3yAulpHF5XnMvnGQwVXm0hn6aetdflqgukxi56m3pTA1YtcgA(qNjjoz4Dy5YXLldH84i3JGPYEyIIS1Em5YFUy(pxx5cjx1ak1lHrUPkx(Y93)5cjxgc5XrUhbdnFOZKeGLKg4UAGruKT2Jjx(ZfZ)3yLbA0CJnaTmVckDb3tXeJCXWnMg1Yt4xECJrW3ydbUXkd0O5g)PvRwE6g)P(hDJjMVHnKOhP)nALRJK7XN7p5QmqJgHbOvOlsq8KypajbTnLBe56qUeZ3Wgs0J0)gTY1rYfJK7p5QmqJgH7sbyfepj2dqsqBt5grU)frM7p5AGjVxIvna6g)PLCuB6gRgymkPkMyxW9umD8lgUX0OwEc)YJBmRAavTEJDMBpaQGrEfq4YqdflqwKT2Jjx(ZfJZLJlxN5A9cbrPF0GEgzOOjk8kkYw7XKl)5cLHlSvEMRJKlJAFUoZvnGs9syKBQY9NCp6FUUYfsUwVqqu6hnONrgkAIcVIhCUUY1vUCC56mx1ak1lHrUPk3iY9tRwT8KqnWyusvmXY1rY16fccI5BydjniVwIIS1Em5grU4iGi8kELOGK8VHeGMD2ilYw7jxhj3if)MlF5IzK)ZLJlx1ak1lHrUPk3iY9tRwT8KqnWyusvmXY1rY16fccI5Bydj9Vrlrr2ApMCJixCeqeEfVsuqs(3qcqZoBKfzR9KRJKBKIFZLVCXmY)56kxi5smFdBirpsD4nxi56mxN56qUmeYJJCpcMk7HjEW5YXLld9rJoaXzERwNCHKRd5YqipoY9iiByKBQKwObx8GZ1vUCC5YqF0OdqmnuSazqPCDLlKCDMRd5YqF0Odq8rdalVvUCC56qUwVqqWuzpmXdoxoUCvdOuVeg5MQC5lxh9FUUYLJlxRxiiyQShMOiBThtU8L7XNlKCDixRxiik9Jg0ZidfnrHxXd(gRmqJMBSbOL5vqPl4EkMh)fd3yAulpHF5XnMvnGQwVXoZ16fccI5Bydj9VrlXdoxoUCDMldRwqjtUhYnYCHKBrmSAbLKG2MYL)C)nxx5YXLldRwqjtUhY9OCDLlKCvyjdlXoFJvgOrZnEi3sBeAUG7Py6OxmCJPrT8e(Lh3yw1aQA9g7mxRxiiiMVHnK0)gTep4C54Y1zUmSAbLm5Ei3iZfsUfXWQfuscABkx(Z93CDLlhxUmSAbLm5Ei3JY1vUqYvHLmSe78nwzGgn3ySQpiTrO5cUNg5)lgUX0OwEc)YJBmRAavTEJDMR1leeeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BUUYLJlxgwTGsMCpK7r56kxi5QWsgwID(gRmqJMBC459sBeAUG7PrI5fd3yLbA0CJDRv1OsIcsY)g6gtJA5j8lpUG7Prg5fd3yAulpHF5XnMvnGQwVXeZ3Wgs0J0)gTYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUCC5A9cbHBTQgvsuqs(3qIhCUqYLy(g2qIEK(3OvUCC56mxRxiiyQShMOiBThtU8NRYanAeUlfGvq8KypajbTnLlKCTEHGGPYEyIhCUUUXkd0O5gBaAf6IUG7PrE0fd3yLbA0CJDxka7nMg1Yt4xECb3tJeJVy4gtJA5j8lpUXkd0O5gxVrQmqJgPVnGBSVna5O20noOEpaB9UGl4gJtb95bxmCpfZlgUXkd0O5gBqETKwKAFJPrT8e(LhxW90iVy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXgyY7LaTGsaJWa0kOEFU8LlM5cjxN56qUa1tdqyaA5rfUGg1Yt45YXLlq90aega59AjXRoae0OwEcpxx5YXLRbM8EjqlOeWimaTcQ3NlF5g5n(tl5O20nUnsfrxW90JUy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXgyY7LaTGsaJWa0k0fLlF5I5n(tl5O20nUnsMN0p6cUNIXxmCJPrT8e(Lh3yw1aQA9g7mxhYLH(OrhGyAOybYGs5YXLRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUUYfsUwVqqWuzpmXd(gRmqJMBSfvgQo3d0l4E6VxmCJPrT8e(Lh3yw1aQA9gB9cbbtL9Wep4BSYanAUXWiqJMl4Ekg5IHBSYanAUXpdjBazBUX0OwEc)YJl4EQJFXWnMg1Yt4xECJzvdOQ1B8NwTA5jrBKkIUXgq1mW9umVXkd0O5gxVrQmqJgPVnGBSVna5O20nwr0fCp94Vy4gtJA5j8lpUXSQbu16nUEdfqfusaABYnQgjErQTvp4ujOO6RHHj8BSbundCpfZBSYanAUX1BKkd0Or6Bd4g7BdqoQnDJXlsTT6bNQl4EQJEXWnMg1Yt4xECJzvdOQ1BC9gkGkOKWs96WijkivVxcW2duJGIQVggMWVXgq1mW9umVXkd0O5gxVrQmqJgPVnGBSVna5O20n2cPGl4EkM)Vy4gtJA5j8lpUXSQbu16n2tFKpx(Y93)3yLbA0CJR3ivgOrJ03gWn23gGCuB6gBaxW9umX8IHBmnQLNWV84gJGVXgcCJvgOrZn(tRwT80n(t9p6gdx0NWDPaS34pTKJAt3y4I(KUlfG9cUNIzKxmCJPrT8e(Lh3ye8n2qGBSYanAUXFA1QLNUXFQ)r3y4I(egGwHUOB8NwYrTPBmCrFsdqRqx0fCpfZJUy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXWf9jmaTmVckDJ)0soQnDJHl6tAaAzEfu6cUNIjgFXWnMg1Yt4xECJvgOrZnUEJuzGgnsFBa3yFBaYrTPBmCrWkGHvAaxWfCJXlsTT6bNQlgUNI5fd3yAulpHF5XngbFJne4gRmqJMB8NwTA5PB8N6F0n2zUwVqqaABYnQgjErQTvp4ujkYw7XKlF5cLHlSvEMBe5(xGzUqY1zUeZ3Wgs0J0cbWMlhxUeZ3Wgs0J0G8ALlhxUeZ3Wgs4FJwYH4jixx5YXLR1leeG2MCJQrIxKAB1dovIIS1Em5YxUkd0OryaAf6Ieepj2dqsqBt5grU)fyMlKCDMlX8nSHe9i9VrRC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKRRCDLlhxUoKR1leeG2MCJQrIxKAB1dovIh8n(tl5O20n2ObscqYNHKgyY7VG7PrEXWnMg1Yt4xECJzvdOQ1BSZCDi3pTA1YtcJgijajFgsAGjVpxoUCDMR1leeL(rd6zKHIMOWROiBThtU8NlugUWw5zUosUmQ956mx1ak1lHrUPk3FY9O)56kxi5A9cbrPF0GEgzOOjk8kEW56kxx5YXLRAaL6LWi3uLlF56O)VXkd0O5gBaAzEfu6cUNE0fd3yAulpHF5XnwzGgn3yfxHb9hjnU1Y(gZQgqvR3yhYfhbekUcd6psACRLTexTvOKa0SZ9anxi56qUkd0OrO4kmO)iPXTw2sC1wHsIEKbFdflixi56mxhYfhbekUcd6psACRLTelPEbOzN7bAUCC5IJacfxHb9hjnU1YwILuVOiBThtU8L7V56kxoUCXraHIRWG(JKg3AzlXvBfkjmaLDox(Z9OCHKlociuCfg0FK04wlBjUARqjrr2ApMC5p3JYfsU4iGqXvyq)rsJBTSL4QTcLeGMDUhO3ygVmpjbAbLaM7PyEb3tX4lgUX0OwEc)YJBSYanAUX2i0e6IUXSQbu16nUOqrgSQLNYfsUaTGsabOTjjajXBkx(YfZiZfsUoZ1zUwVqqWuzpmrr2ApMC5l3FZfsUoZ16fcIs)Ob9mYqrtu4vuKT2Jjx(Y93C54Y1HCTEHGO0pAqpJmu0efEfp4CDLlhxUoKR1leemv2dt8GZLJlx1ak1lHrUPkx(Z9O)56kxi56mxhY16fcIZ9GxeUKSHrUPYMgGKgQG2rHep4C54YvnGs9syKBQYL)Cp6FUUYfsUkSKHLyNZ11nMXlZtsGwqjG5EkMxW90FVy4gtJA5j8lpUXkd0O5gBEtOl6gZQgqvR34IcfzWQwEkxi5c0ckbeG2MKaKeVPC5lxmJmxi56mxN5A9cbbtL9WefzR9yYLVC)nxi56mxRxiik9Jg0ZidfnrHxrr2ApMC5l3FZLJlxhY16fcIs)Ob9mYqrtu4v8GZ1vUCC56qUwVqqWuzpmXdoxoUCvdOuVeg5MQC5p3J(NRRCHKRZCDixRxiio3dEr4sYgg5MkBAasAOcAhfs8GZLJlx1ak1lHrUPkx(Z9O)56kxi5QWsgwIDoxx3ygVmpjbAbLaM7PyEb3tXixmCJPrT8e(Lh3yLbA0CJnaY71sg8Ar3yw1aQA9gxuOidw1Yt5cjxGwqjGa02KeGK4nLlF5Ijgjxi56mxN5A9cbbtL9WefzR9yYLVC)nxi56mxRxiik9Jg0ZidfnrHxrr2ApMC5l3FZLJlxhY16fcIs)Ob9mYqrtu4v8GZ1vUCC56qUwVqqWuzpmXdoxoUCvdOuVeg5MQC5p3J(NRRCHKRZCDixRxiio3dEr4sYgg5MkBAasAOcAhfs8GZLJlx1ak1lHrUPkx(Z9O)56kxi5QWsgwIDoxx3ygVmpjbAbLaM7PyEb3tD8lgUX0OwEc)YJBmRAavTEJvyjdlXoFJvgOrZnoGkgjrb5OGxrxW90J)IHBmnQLNWV84gZQgqvR3yRxiiyQShM4bFJvgOrZnU0pAqpJmu0efEVG7Po6fd3yAulpHF5XnMvnGQwVXoZ1zUwVqqqmFdBiPb51suKT2Jjx(YfZ)5YXLR1leeeZ3Wgs6FJwIIS1Em5YxUy(pxx5cjxgc5XrUhbtL9WefzR9yYLVCp6FUUYLJlxgc5XrUhbtL9WefP48EJvgOrZn(Cp4fHlnWD1aZfCpfZ)xmCJPrT8e(Lh3yw1aQA9g7mxRxiio3dEr4sYgg5MkBAasAOcAhfs8GZLJlxhYLH(OrhG4mVvRtUUYLJlxg6JgDaIPHIfidkLlhxUFA1QLNeTrQikxoUCTEHGWYJq4(NbiEW5cjxRxiiS8ieU)zaIIS1Em5YFUr(p3iY1zUyCUosUm0G)AGaUiwBiP6BOJnnabnQLNWZ1vUqY1HCTEHGGPYEyIhCUqY1zU9aOcg5vaHldnuSazr2ApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKT2Jj3iY1XZLJl3EaubJ8kGWLHgkwGSiBThtU8NBKrMlhxU9aOcg5vaHldnuSazr2ApMCpwUyE8)ZL)CJmYC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y1HCzOpA0biMgkwGmOuUUUXkd0O5gZipzaT6LQVHo20aUG7PyI5fd3yAulpHF5XnMvnGQwVXoZ16fcIZ9GxeUKSHrUPYMgGKgQG2rHep4C54Y1HCzOpA0bioZB16KRRC54YLH(OrhGyAOybYGs5YXL7NwTA5jrBKkIYLJlxRxiiS8ieU)zaIhCUqY16fcclpcH7FgGOiBThtU8N7r)ZnICDMlgNRJKldn4VgiGlI1gsQ(g6ytdqqJA5j8CDLlKCDixRxiiyQShM4bNlKCDMBpaQGrEfq4YqdflqwKT2Jjx(ZLHqECK7rWqZh6mjbyjPbURgyefzR9yYnICD8C54YThavWiVciCzOHIfilYw7XKl)5EuK5YXLBpaQGrEfq4YqdflqwKT2Jj3JLlMh))C5p3JImxoUCziKhh5Eem08HotsawsAG7QbgXdoxoUCDixg6JgDaIPHIfidkLRRBSYanAUX9W0AuqJMl4EkMrEXWnMg1Yt4xECJrW3ydbUXkd0O5g)PvRwE6g)P(hDJzOpA0biMgkwGmOuUqY1zUwVqqaxTnQWB1l1IPtZKWpVrlXN6FuU8NBKy8)CHKRZCziKhh5Eemv2dtuKT2Jj3iYfZ)5YxU9aOcg5vaHldnuSazr2ApMC54YLHqECK7rWuzpmrr2ApMCJi3J(Nl)52dGkyKxbeUm0qXcKfzR9yYfsU9aOcg5vaHldnuSazr2ApMC5lxmp6FUCC5A9cbbtL9WefzR9yYLVCD8CDLlKCTEHGGy(g2qsdYRLOiBThtU8LlM)ZLJl3EaubJ8kGWLHgkwGSiBThtUhlxmJ8FU8NlM)MRRB8NwYrTPBmdnFOZKKHg8g0O5cUNI5rxmCJPrT8e(Lh3ye8n2qGBSYanAUXFA1QLNUXFQ)r3yN56qUmeYJJCpcMk7HjksX5nxoUCDi3pTA1YtcgA(qNjjdn4nOrtUqYLH(OrhGyAOybYGs566g)PLCuB6gB0psgqLKPYEyxW9umX4lgUX0OwEc)YJBmRAavTEJ)0QvlpjyO5dDMKm0G3Ggn5cjx1ak1lHrUPkx(ZfJ)FJvgOrZnMHMp0zscWssdCxnWCb3tX83lgUX0OwEc)YJBmRAavTEJjMVHnKOhPo8MlKCvyjdlXoNlKCDMlociuCfg0FK04wlBjUARqjbOzN7bAUCC56qUm0hn6aedXkKhv456kxi5(PvRwEsy0psgqLKPYEy3yLbA0CJdVIxjkij)BOl4EkMyKlgUX0OwEc)YJBmRAavTEJzOpA0biMgkwGmOuUqY9tRwT8KGHMp0zsYqdEdA0KlKCvdOuVeg5MQC57qUy8)CHKldH84i3JGHMp0zscWssdCxnWikYw7XKl)5cLHlSvEMRJKlJAFUoZvnGs9syKBQY9NCp6FUUUXkd0O5gBaAzEfu6cUNIPJFXWnMg1Yt4xECJzvdOQ1BSZCTEHGGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1vUCC5YWQfuYK7HCpkxx5cjxfwYWsSZ5cj3pTA1YtcJ(rYaQKmv2d7gRmqJMB8qUL2i0Cb3tX84Vy4gtJA5j8lpUXSQbu16n2zUwVqqqmFdBiP)nAjEW5cjxhYLH(OrhG4mVvRtUCC56mxRxiio3dEr4sYgg5MkBAasAOcAhfs8GZfsUm0hn6aeN5TADY1vUCC56mxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BUUYLJlxgwTGsMCpK7r5YXLR1leemv2dt8GZ1vUqYvHLmSe7CUqY9tRwT8KWOFKmGkjtL9WUXkd0O5gJv9bPncnxW9umD0lgUX0OwEc)YJBmRAavTEJDMR1leeeZ3Wgs6FJwIhCUqY1HCzOpA0bioZB16KlhxUoZ16fcIZ9GxeUKSHrUPYMgGKgQG2rHep4CHKld9rJoaXzERwNCDLlhxUoZLHvlOKj3d5gzUqYTigwTGssqBt5YFU)MRRC54YLHvlOKj3d5EuUCC5A9cbbtL9Wep4CDLlKCvyjdlXoNlKC)0Qvlpjm6hjdOsYuzpSBSYanAUXHN3lTrO5cUNg5)lgUXkd0O5g7wRQrLefKK)n0nMg1Yt4xECb3tJeZlgUX0OwEc)YJBmRAavTEJjMVHnKOhP)nALlhxUeZ3WgsyqETKdXtqUCC5smFdBiHo8khINGC54Y16fcc3AvnQKOGK8VHep4CHKR1leeeZ3Wgs6FJwIhCUCC56mxRxiiyQShMOiBThtU8NRYanAeUlfGvq8KypajbTnLlKCTEHGGPYEyIhCUUUXkd0O5gBaAf6IUG7Prg5fd3yLbA0CJDxka7nMg1Yt4xECb3tJ8OlgUX0OwEc)YJBSYanAUX1BKkd0Or6Bd4g7BdqoQnDJdQ3dWwVl4cUXkIUy4EkMxmCJPrT8e(Lh3ye8n2qGBSYanAUXFA1QLNUXFQ)r3yN5A9cbbOTj3OAK4fP2w9GtLOiBThtU8NlugUWw5zUrK7FbM5YXLR1leeG2MCJQrIxKAB1dovIIS1Em5YFUkd0OryaAf6Ieepj2dqsqBt5grU)fyMlKCDMlX8nSHe9i9VrRC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKRRCDLlKCTEHGa02KBuns8IuBREWPs8GZfsU1BOaQGscqBtUr1iXlsTT6bNkbfvFnmmHFJ)0soQnDJXlsTLUBVxguVxIcHl4EAKxmCJPrT8e(Lh3yw1aQA9gB9cbHbOvq9ErrHImyvlpLlKCDMRbM8EjqlOeWimaTcQ3Nl)5EuUCC56qU1BOaQGscqBtUr1iXlsTT6bNkbfvFnmmHNRRCHKRZCDi36nuavqjHNxMwQrg8eb6bQeQVTHnKGIQVggMWZLJlxqBt5ESCX4FZLVCTEHGWa0kOEVOiBThtUrKBK566gRmqJMBSbOvq9(l4E6rxmCJPrT8e(Lh3yw1aQA9gxVHcOckjaTn5gvJeVi12QhCQeuu91WWeEUqY1atEVeOfucyegGwb17ZLVd5EuUqY1zUoKR1leeG2MCJQrIxKAB1dovIhCUqY16fccdqRG69IIcfzWQwEkxoUCDM7NwTA5jbErQT0D79YG69suiKlKCDMR1leegGwb17ffzR9yYL)CpkxoUCnWK3lbAbLagHbOvq9(C5l3iZfsUa1tdqyaK3RLeV6aqqJA5j8CHKR1leegGwb17ffzR9yYL)C)nxx56kxx3yLbA0CJnaTcQ3Fb3tX4lgUX0OwEc)YJBmc(gBiWnwzGgn34pTA1Yt34p1)OBSAaL6LWi3uLlF5E8)ZnQKRZCX8FUosUwVqqaABYnQgjErQTvp4ujmaLDoxx5gvY1zUwVqqyaAfuVxuKT2Jjxhj3JY9NCnWK3lXQgaLRRCJk56mxCeqeEfVsuqs(3qIIS1Em56i5(BUUYfsUwVqqyaAfuVx8GVXFAjh1MUXgGwb17LUrdqguVxIcHl4E6VxmCJPrT8e(Lh3yw1aQA9g)PvRwEsGxKAlD3EVmOEVefc5cj3pTA1YtcdqRG69s3ObidQ3lrHWnwzGgn3ydqlZRGsxW9umYfd3yAulpHF5XnwzGgn3yZBcDr3yw1aQA9gxuOidw1Yt5cjxGwqjGa02KeGK4nLlF5IjgNBujxdm59sGwqjGj3iYTiBThtUqYvHLmSe7CUqYLy(g2qIEK6W7nMXlZtsGwqjG5EkMxW9uh)IHBmnQLNWV84gRmqJMBSIRWG(JKg3AzFJzvdOQ1BSd5cA25EGMlKCDixLbA0iuCfg0FK04wlBjUARqjrpYGVHIfKlhxU4iGqXvyq)rsJBTSL4QTcLegGYoNl)5EuUqYfhbekUcd6psACRLTexTvOKOiBThtU8N7r3ygVmpjbAbLaM7PyEb3tp(lgUX0OwEc)YJBSYanAUX2i0e6IUXSQbu16nUOqrgSQLNYfsUaTGsabOTjjajXBkx(Y1zUyIX5grUoZ1atEVeOfucyegGwHUOCDKCXu8BUUY1vU)KRbM8EjqlOeWKBe5wKT2Jjxi56mxN5YqipoY9iyQShMOifN3C54Y1atEVeOfucyegGwHUOC5p3JYLJlxN5smFdBirpsdYRvUCC5smFdBirpsleaBUCC5smFdBirps)B0kxi56qUa1tdqyqpVefKaSKmGkYae0OwEcpxoUCTEHGaUABuH3QxQftNMjHFEJwIp1)OC57qUr(7)CDLlKCDMRbM8EjqlOeWimaTcDr5YFUy(pxhjxN5IzUrKlq90aea39iTrOXiOrT8eEUUY1vUqYvnGs9syKBQYLVC)9FUrLCTEHGWa0kOEVOiBThtUosUyKCDLlKCDixRxiio3dEr4sYgg5MkBAasAOcAhfs8GZfsUkSKHLyNZ11nMXlZtsGwqjG5EkMxW9uh9IHBmnQLNWV84gZQgqvR3yfwYWsSZ3yLbA0CJdOIrsuqok4v0fCpfZ)xmCJPrT8e(Lh3yw1aQA9gB9cbbtL9Wep4BSYanAUXL(rd6zKHIMOW7fCpftmVy4gtJA5j8lpUXSQbu16n2zUwVqqyaAfuVx8GZLJlx1ak1lHrUPkx(Y93)56kxi56qUwVqqyqEdOzK4bNlKCDixRxiiyQShM4bNlKCDMBpaQGrEfq4YqdflqwKT2Jjx(ZLHqECK7rWqZh6mjbyjPbURgyefzR9yYnICD8C54YThavWiVciCzOHIfilYw7XK7XYfZJ)FU8NBKrMlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUoKld9rJoaX0qXcKbLY11nwzGgn3yg5jdOvVu9n0XMgWfCpfZiVy4gtJA5j8lpUXSQbu16no0qXcKfzR9yYL)CX83C54Y1zUwVqqaxTnQWB1l1IPtZKWpVrlXN6FuU8NBK)(pxoUCTEHGaUABuH3QxQftNMjHFEJwIp1)OC57qUr(7)CDLlKCTEHGWa0kOEV4bNlKCziKhh5Eemv2dtuKT2Jjx(Y93)3yLbA0CJ7HP1OGgnxW9ump6IHBmnQLNWV84gRmqJMBSbqEVwYGxl6gZQgqvR34IcfzWQwEkxi5cABscqs8MYLVCX83CHKRbM8EjqlOeWimaTcDr5YFUyCUqYvHLmSe7CUqY1zUwVqqWuzpmrr2ApMC5lxm)NlhxUoKR1leemv2dt8GZ11nMXlZtsGwqjG5EkMxW9umX4lgUX0OwEc)YJBmc(gBiWnwzGgn34pTA1Yt34p1)OBS1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5g5V)ZnQKRAaL6LWi3uLlKCDMldH84i3JGPYEyIIS1Em5grUy(px(Yn0qXcKfzR9yYLJlxgc5XrUhbtL9WefzR9yYnICp6FU8NBOHIfilYw7XKlKCdnuSazr2ApMC5lxmp6FUCC5A9cbbtL9WefzR9yYLVCD8CDLlKCjMVHnKOhPo8MlhxUHgkwGSiBThtUhlxmJ8FU8NlM)EJ)0soQnDJzO5dDMKm0G3GgnxW9um)9IHBmnQLNWV84gZQgqvR34pTA1YtcgA(qNjjdn4nOrtUqYvnGs9syKBQYL)C)9)nwzGgn3ygA(qNjjaljnWD1aZfCpftmYfd3yAulpHF5XnMvnGQwVXeZ3Wgs0JuhEZfsUkSKHLyNZfsUwVqqaxTnQWB1l1IPtZKWpVrlXN6FuU8NBK)(pxi56mxCeqO4kmO)iPXTw2sC1wHscqZo3d0C54Y1HCzOpA0bigIvipQWZLJlxdm59sGwqjGjx(YnYCDDJvgOrZno8kELOGK8VHUG7Py64xmCJPrT8e(Lh3yw1aQA9gB9cbbAiawJeMkgbdA0iEW5cjxN5A9cbHbOvq9ErrHImyvlpLlhxUQbuQxcJCtvU8LRJ(pxx3yLbA0CJnaTcQ3Fb3tX84Vy4gtJA5j8lpUXSQbu16nMH(OrhGyAOybYGs5cj3pTA1YtcgA(qNjjdn4nOrtUqYLHqECK7rWqZh6mjbyjPbURgyefzR9yYL)CHYWf2kpZ1rYLrTpxN5QgqPEjmYnv5(tU)(pxx5cjxRxiimaTcQ3lkkuKbRA5PBSYanAUXgGwb17VG7Py6OxmCJPrT8e(Lh3yw1aQA9gZqF0OdqmnuSazqPCHK7NwTA5jbdnFOZKKHg8g0Ojxi5YqipoY9iyO5dDMKaSK0a3vdmIIS1Em5YFUqz4cBLN56i5YO2NRZCvdOuVeg5MQC)j3J(NRRCHKR1leegGwb17fp4BSYanAUXgGwMxbLUG7Pr()IHBmnQLNWV84gZQgqvR3yRxiiqdbWAKmpPL8RnnAep4C54Y1HCnaTcDrcfwYWsSZ5YXLRZCTEHGGPYEyIIS1Em5YFU)MlKCTEHGGPYEyIhCUCC56mxRxiik9Jg0ZidfnrHxrr2ApMC5pxOmCHTYZCDKCzu7Z1zUQbuQxcJCtvU)K7r)Z1vUqY16fcIs)Ob9mYqrtu4v8GZ1vUUYfsUFA1QLNegGwb17LUrdqguVxIcHCHKRbM8EjqlOeWimaTcQ3Nl)5E0nwzGgn3ydqlZRGsxW90iX8IHBmnQLNWV84gZQgqvR3yN5smFdBirpsD4nxi5YqipoY9iyQShMOiBThtU8L7V)ZLJlxN5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1vUCC5YWQfuYK7HCpkxx5cjxfwYWsSZ3yLbA0CJhYT0gHMl4EAKrEXWnMg1Yt4xECJzvdOQ1BSZCjMVHnKOhPo8MlKCziKhh5Eemv2dtuKT2Jjx(Y93)5YXLRZCzy1ckzY9qUrMlKClIHvlOKe02uU8N7V56kxoUCzy1ckzY9qUhLRRCHKRclzyj25BSYanAUXyvFqAJqZfCpnYJUy4gtJA5j8lpUXSQbu16n2zUeZ3Wgs0JuhEZfsUmeYJJCpcMk7HjkYw7XKlF5(7)C54Y1zUmSAbLm5Ei3iZfsUfXWQfuscABkx(Z93CDLlhxUmSAbLm5Ei3JY1vUqYvHLmSe78nwzGgn34WZ7L2i0Cb3tJeJVy4gRmqJMBSBTQgvsuqs(3q3yAulpHF5XfCpnYFVy4gtJA5j8lpUXi4BSHa3yLbA0CJ)0QvlpDJ)u)JUXgyY7LaTGsaJWa0k0fLlF5IX5grUbpcv56mxB1aOIx5N6FuU)KBK)Z1vUrKBWJqvUoZ16fccdqlZRGssYgg5MkBAacdqzNZ9NCX4CDDJ)0soQnDJnaTcDrYEKgKxRl4EAKyKlgUX0OwEc)YJBmRAavTEJjMVHnKW)gTKdXtqUCC5smFdBiHo8khINGCHK7NwTA5jrBKmpPFuUCC5A9cbbX8nSHKgKxlrr2ApMC5pxLbA0imaTcDrcINe7bijOTPCHKR1leeeZ3WgsAqETep4C54YLy(g2qIEKgKxRCHKRd5(PvRwEsyaAf6IK9iniVw5YXLR1leemv2dtuKT2Jjx(ZvzGgncdqRqxKG4jXEascABkxi56qUFA1QLNeTrY8K(r5cjxRxiiyQShMOiBThtU8NlXtI9aKe02uUqY16fccMk7HjEW5YXLR1leeL(rd6zKHIMOWR4bNlKCnWK3lXQgaLlF5(xGrYfsUoZ1atEVeOfucyYL)d5EuUCC56qUa1tdqyqpVefKaSKmGkYae0OwEcpxx5YXLRd5(PvRwEs0gjZt6hLlKCTEHGGPYEyIIS1Em5YxUepj2dqsqBt3yLbA0CJDxka7fCpnsh)IHBSYanAUXgGwHUOBmnQLNWV84cUNg5XFXWnMg1Yt4xECJvgOrZnUEJuzGgnsFBa3yFBaYrTPBCq9Ea26DbxWnoOEpaB9Uy4EkMxmCJPrT8e(Lh3yw1aQA9g7qU1BOaQGscl1RdJKOGu9EjaBpqnckQ(Ayyc)gRmqJMBSbOL5vqPl4EAKxmCJPrT8e(Lh3yLbA0CJnVj0fDJzvdOQ1BmociSrOj0fjkYw7XKlF5wKT2J5gZ4L5jjqlOeWCpfZl4E6rxmCJvgOrZn2gHMqx0nMg1Yt4xECbxWn2aUy4EkMxmCJPrT8e(Lh3yLbA0CJvCfg0FK04wl7BmRAavTEJDixCeqO4kmO)iPXTw2sC1wHscqZo3d0CHKRd5QmqJgHIRWG(JKg3AzlXvBfkj6rg8nuSGCHKRZCDixCeqO4kmO)iPXTw2sSK6fGMDUhO5YXLlociuCfg0FK04wlBjws9IIS1Em5YxU)MRRC54YfhbekUcd6psACRLTexTvOKWau25C5p3JYfsU4iGqXvyq)rsJBTSL4QTcLefzR9yYL)Cpkxi5IJacfxHb9hjnU1YwIR2kusaA25EGEJz8Y8KeOfucyUNI5fCpnYlgUX0OwEc)YJBSYanAUX2i0e6IUXSQbu16nUOqrgSQLNYfsUaTGsabOTjjajXBkx(YfZiZfsUoZ16fccMk7HjkYw7XKlF5(BUqY1zUwVqqu6hnONrgkAIcVIIS1Em5YxU)MlhxUoKR1leeL(rd6zKHIMOWR4bNRRC54Y1HCTEHGGPYEyIhCUCC5QgqPEjmYnv5YFUh9pxx5cjxN56qUwVqqCUh8IWLKnmYnv20aK0qf0okK4bNlhxUQbuQxcJCtvU8N7r)Z1vUqYvHLmSe78nMXlZtsGwqjG5EkMxW90JUy4gtJA5j8lpUXkd0O5gBEtOl6gZQgqvR34IcfzWQwEkxi5c0ckbeG2MKaKeVPC5lxmJmxi56mxRxiiyQShMOiBThtU8L7V5cjxN5A9cbrPF0GEgzOOjk8kkYw7XKlF5(BUCC56qUwVqqu6hnONrgkAIcVIhCUUYLJlxhY16fccMk7HjEW5YXLRAaL6LWi3uLl)5E0)CDLlKCDMRd5A9cbX5EWlcxs2Wi3uztdqsdvq7OqIhCUCC5QgqPEjmYnv5YFUh9pxx5cjxfwYWsSZ3ygVmpjbAbLaM7PyEb3tX4lgUX0OwEc)YJBSYanAUXga59AjdETOBmRAavTEJlkuKbRA5PCHKlqlOeqaABscqs8MYLVCXeJKlKCDMR1leemv2dtuKT2Jjx(Y93CHKRZCTEHGO0pAqpJmu0efEffzR9yYLVC)nxoUCDixRxiik9Jg0ZidfnrHxXdoxx5YXLRd5A9cbbtL9Wep4C54YvnGs9syKBQYL)Cp6FUUYfsUoZ1HCTEHG4Cp4fHljByKBQSPbiPHkODuiXdoxoUCvdOuVeg5MQC5p3J(NRRCHKRclzyj25BmJxMNKaTGsaZ9umVG7P)EXWnMg1Yt4xECJzvdOQ1BSclzyj25BSYanAUXbuXijkihf8k6cUNIrUy4gtJA5j8lpUXSQbu16n26fccMk7HjEW3yLbA0CJl9Jg0ZidfnrH3l4EQJFXWnMg1Yt4xECJzvdOQ1BSZCDMR1leeeZ3WgsAqETefzR9yYLVCX8FUCC5A9cbbX8nSHK(3OLOiBThtU8LlM)Z1vUqYLHqECK7rWuzpmrr2ApMC5l3J(NlKCDMR1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5gjg)pxoUCDi36nuavqjbC12OcVvVulMontc)8gTeuu91WWeEUUY1vUCC5A9cbbC12OcVvVulMontc)8gTeFQ)r5Y3HCJ0X)NlhxUmeYJJCpcMk7HjksX5nxi56mx1ak1lHrUPkx(Y1r)NlhxUFA1QLNeTrQikxx3yLbA0CJp3dEr4sdCxnWCb3tp(lgUX0OwEc)YJBmRAavTEJDMRAaL6LWi3uLlF56O)ZfsUoZ16fcIZ9GxeUKSHrUPYMgGKgQG2rHep4C54Y1HCzOpA0bioZB16KRRC54YLH(OrhGyAOybYGs5YXL7NwTA5jrBKkIYLJlxRxiiS8ieU)zaIhCUqY16fcclpcH7FgGOiBThtU8NBK)ZnICDMRZCD0CDKCR3qbubLeWvBJk8w9sTy60mj8ZB0sqr1xddt456k3iY1zUyCUosUm0G)AGaUiwBiP6BOJnnabnQLNWZ1vUUY1vUqY1HCTEHGGPYEyIhCUqY1zUHgkwGSiBThtU8NldH84i3JGHMp0zscWssdCxnWikYw7XKBe5645YXLBOHIfilYw7XKl)5gzK5grUoZ1rZ1rY1zUwVqqaxTnQWB1l1IPtZKWpVrlXN6FuU8LlM))NRRCDLlhxUHgkwGSiBThtUhlxmp()5YFUrgzUCC5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUm0hn6aetdflqgukxx3yLbA0CJzKNmGw9s13qhBAaxW9uh9IHBmnQLNWV84gZQgqvR3yN5QgqPEjmYnv5YxUo6)CHKRZCTEHG4Cp4fHljByKBQSPbiPHkODuiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmOuUCC5(PvRwEs0gPIOC54Y16fcclpcH7FgG4bNlKCTEHGWYJq4(NbikYw7XKl)5E0)CJixN56mxhnxhj36nuavqjbC12OcVvVulMontc)8gTeuu91WWeEUUYnICDMlgNRJKldn4VgiGlI1gsQ(g6ytdqqJA5j8CDLRRCDLlKCDixRxiiyQShM4bNlKCDMBOHIfilYw7XKl)5YqipoY9iyO5dDMKaSK0a3vdmIIS1Em5grUoEUCC5gAOybYIS1Em5YFUhfzUrKRZCD0CDKCDMR1leeWvBJk8w9sTy60mj8ZB0s8P(hLlF5I5))56kxx5YXLBOHIfilYw7XK7XYfZJ)FU8N7rrMlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUoKld9rJoaX0qXcKbLY11nwzGgn34EyAnkOrZfCpfZ)xmCJPrT8e(Lh3ye8n2qGBSYanAUXFA1QLNUXFQ)r3yg6JgDaIPHIfidkLlKCDMR1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5gjg)pxi56mxgc5XrUhbtL9WefzR9yYnICX8FU8LBOHIfilYw7XKlhxUmeYJJCpcMk7HjkYw7XKBe5E0)C5p3qdflqwKT2Jjxi5gAOybYIS1Em5YxUyE0)C54Y16fccMk7HjkYw7XKlF56456kxi5A9cbbX8nSHKgKxlrr2ApMC5lxm)NlhxUHgkwGSiBThtUhlxmJ8FU8NlM)MRRB8NwYrTPBmdnFOZKKHg8g0O5cUNIjMxmCJPrT8e(Lh3ye8n2qGBSYanAUXFA1QLNUXFQ)r3yN56qUmeYJJCpcMk7HjksX5nxoUCDi3pTA1YtcgA(qNjjdn4nOrtUqYLH(OrhGyAOybYGs566g)PLCuB6gB0psgqLKPYEyxW9umJ8IHBmnQLNWV84gZQgqvR34pTA1YtcgA(qNjjdn4nOrtUqYvnGs9syKBQYL)Cp6)nwzGgn3ygA(qNjjaljnWD1aZfCpfZJUy4gtJA5j8lpUXSQbu16nMy(g2qIEK6WBUqYvHLmSe7CUqY16fcc4QTrfEREPwmDAMe(5nAj(u)JYL)CJeJ)NlKCDMlociuCfg0FK04wlBjUARqjbOzN7bAUCC56qUm0hn6aedXkKhv456kxi5(PvRwEsy0psgqLKPYEy3yLbA0CJdVIxjkij)BOl4EkMy8fd3yAulpHF5XnMvnGQwVXwVqqGgcG1iHPIrWGgnIhCUqY16fccdqRG69IIcfzWQwE6gRmqJMBSbOvq9(l4EkM)EXWnMg1Yt4xECJzvdOQ1BS1leegGwEuHlkYw7XKl)5(BUqY1zUwVqqqmFdBiPb51suKT2Jjx(Y93C54Y16fccI5Bydj9Vrlrr2ApMC5l3FZ1vUqYvnGs9syKBQYLVCD0)3yLbA0CJz6WiV06fc3yRxiih1MUXgGwEuHFb3tXeJCXWnMg1Yt4xECJzvdOQ1Bmd9rJoaX0qXcKbLYfsUFA1QLNem08HotsgAWBqJMCHKldH84i3JGHMp0zscWssdCxnWikYw7XKl)5cLHlSvEMRJKlJAFUoZvnGs9syKBQY9NCp6FUUUXkd0O5gBaAzEfu6cUNIPJFXWnMg1Yt4xECJzvdOQ1Bmq90aega59AjXRoae0OwEcpxi56qUa1tdqyaA5rfUGg1Yt45cjxRxiimaTcQ3lkkuKbRA5PCHKRZCTEHGGy(g2qs)B0suKT2Jjx(YfJKlKCjMVHnKOhP)nALlKCDMRd5wVHcOckjGR2gv4T6LAX0Pzs4N3OLGg1Yt45YXLR1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5g5V)Z1vUCC56mxhYTEdfqfusaxTnQWB1l1IPtZKWpVrlbnQLNWZLJlxRxiiGR2gv4T6LAX0Pzs4N3OL4t9pkx(oKBK)(pxx5cjx1ak1lHrUPkx(Y1r)NlhxU4iGqXvyq)rsJBTSL4QTcLefzR9yYLVCp(C54YvzGgncfxHb9hjnU1YwIR2kus0Jm4BOyb56kxi56qUmeYJJCpcMk7HjksX59gRmqJMBSbOvq9(l4EkMh)fd3yAulpHF5XnMvnGQwVXwVqqGgcG1izEsl5xBA0iEW5YXLR1leeN7bViCjzdJCtLnnajnubTJcjEW5YXLR1leemv2dt8GZfsUoZ16fcIs)Ob9mYqrtu4vuKT2Jjx(ZfkdxyR8mxhjxg1(CDMRAaL6LWi3uL7p5E0)CDLlKCTEHGO0pAqpJmu0efEfp4C54Y1HCTEHGO0pAqpJmu0efEfp4CHKRd5YqipoY9ik9Jg0ZidfnrHxrrkoV5YXLRd5YqF0Odq8rdalVvUUYLJlx1ak1lHrUPkx(Y1r)NlKCjMVHnKOhPo8EJvgOrZn2a0Y8kO0fCpfth9IHBmnQLNWV84gZQgqvR3yG6PbimaT8OcxqJA5j8CHKRZCTEHGWa0YJkCXdoxoUCvdOuVeg5MQC5lxh9FUUYfsUwVqqyaA5rfUWau25C5p3JYfsUoZ16fccI5BydjniVwIhCUCC5A9cbbX8nSHK(3OL4bNRRCHKR1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5gPJ)pxi56mxgc5XrUhbtL9WefzR9yYLVCX8FUCC56qUFA1QLNem08HotsgAWBqJMCHKld9rJoaX0qXcKbLY11nwzGgn3ydqlZRGsxW90i)FXWnMg1Yt4xECJzvdOQ1BSZCTEHGaUABuH3QxQftNMjHFEJwIp1)OC5p3iD8)5YXLR1leeWvBJk8w9sTy60mj8ZB0s8P(hLl)5g5V)ZfsUa1tdqyaK3RLeV6aqqJA5j8CDLlKCTEHGGy(g2qsdYRLOiBThtU8LRJNlKCjMVHnKOhPb51kxi56qUwVqqGgcG1iHPIrWGgnIhCUqY1HCbQNgGWa0YJkCbnQLNWZfsUmeYJJCpcMk7HjkYw7XKlF5645cjxN5YqipoY9io3dEr4sdCxnWikYw7XKlF5645YXLRd5YqF0OdqCM3Q1jxx3yLbA0CJnaTmVckDb3tJeZlgUX0OwEc)YJBmRAavTEJDMR1leeeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BUUYLJlxgwTGsMCpK7r56kxi5QWsgwIDoxi5(PvRwEsy0psgqLKPYEy3yLbA0CJhYT0gHMl4EAKrEXWnMg1Yt4xECJzvdOQ1BSZCTEHGGy(g2qs)B0s8GZfsUoKld9rJoaXzERwNC54Y1zUwVqqCUh8IWLKnmYnv20aK0qf0okK4bNlKCzOpA0bioZB16KRRC54Y1zUmSAbLm5Ei3iZfsUfXWQfuscABkx(Z93CDLlhxUmSAbLm5Ei3JYLJlxRxiiyQShM4bNRRCHKRclzyj25CHK7NwTA5jHr)izavsMk7HDJvgOrZngR6dsBeAUG7PrE0fd3yAulpHF5XnMvnGQwVXoZ16fccI5Bydj9VrlXdoxi56qUm0hn6aeN5TADYLJlxN5A9cbX5EWlcxs2Wi3uztdqsdvq7OqIhCUqYLH(OrhG4mVvRtUUYLJlxN5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1vUCC5YWQfuYK7HCpkxoUCTEHGGPYEyIhCUUYfsUkSKHLyNZfsUFA1QLNeg9JKbujzQSh2nwzGgn34WZ7L2i0Cb3tJeJVy4gRmqJMBSBTQgvsuqs(3q3yAulpHF5XfCpnYFVy4gtJA5j8lpUXSQbu16nMy(g2qIEK(3OvUCC5smFdBiHb51soepb5YXLlX8nSHe6WRCiEcYLJlxRxiiCRv1OsIcsY)gs8GZfsUwVqqqmFdBiP)nAjEW5YXLRZCTEHGGPYEyIIS1Em5YFUkd0Or4UuawbXtI9aKe02uUqY16fccMk7HjEW566gRmqJMBSbOvOl6cUNgjg5IHBSYanAUXUlfG9gtJA5j8lpUG7Pr64xmCJPrT8e(Lh3yLbA0CJR3ivgOrJ03gWn23gGCuB6ghuVhGTExWfCJHlcwbmSsd4IH7PyEXWnMg1Yt4xECJvgOrZn2gHMqx0nMvnGQwVXffkYGvT8uUqYfOfuciaTnjbijEt5YxUygzUqY1zUwVqqWuzpmrr2ApMC5l3FZLJlxhY16fccMk7HjEW5YXLRAaL6LWi3uLl)5E0)CDLlKCvyjdlXoFJz8Y8KeOfucyUNI5fCpnYlgUX0OwEc)YJBSYanAUXM3e6IUXSQbu16nUOqrgSQLNYfsUaTGsabOTjjajXBkx(YfZiZfsUoZ16fccMk7HjkYw7XKlF5(BUCC56qUwVqqWuzpmXdoxoUCvdOuVeg5MQC5p3J(NRRCHKRclzyj25BmJxMNKaTGsaZ9umVG7PhDXWnMg1Yt4xECJvgOrZn2aiVxlzWRfDJzvdOQ1BCrHImyvlpLlKCbAbLacqBtsasI3uU8LlMrMlKCDMR1leemv2dtuKT2Jjx(Y93C54Y1HCTEHGGPYEyIhCUCC5QgqPEjmYnv5YFUh9pxx5cjxfwYWsSZ3ygVmpjbAbLaM7PyEb3tX4lgUX0OwEc)YJBmRAavTEJvyjdlXoFJvgOrZnoGkgjrb5OGxrxW90FVy4gtJA5j8lpUXSQbu16n2zUQbuQxcJCtvU8LRJ(pxoUCTEHGWYJq4(NbiEW5cjxRxiiS8ieU)zaIIS1Em5YFUrIrY1vUqY1HCTEHGGPYEyIh8nwzGgn3yg5jdOvVu9n0XMgWfCpfJCXWnMg1Yt4xECJzvdOQ1BSZCvdOuVeg5MQC5lxh9FUCC5A9cbHLhHW9pdq8GZfsUwVqqy5riC)ZaefzR9yYL)CpcJKRRCHKRd5A9cbbtL9Wep4BSYanAUX9W0AuqJMl4EQJFXWnMg1Yt4xECJrW3ydbUXkd0O5g)PvRwE6g)P(hDJDixgc5XrUhbtL9WefP48EJ)0soQnDJn6hjdOsYuzpSl4E6XFXWnMg1Yt4xECJzvdOQ1BmX8nSHe9i1H3CHKRclzyj25CHK7NwTA5jHr)izavsMk7HDJvgOrZno8kELOGK8VHUG7Po6fd3yAulpHF5XnMvnGQwVXwVqqyaA5rfUOiBThtU8Nlgjxi56mxRxiiiMVHnK0G8AjEW5YXLR1leeeZ3Wgs6FJwIhCUUYfsUQbuQxcJCtvU8LRJ()gRmqJMBmthg5LwVq4gB9cb5O20n2a0YJk8l4EkM)Vy4gtJA5j8lpUXSQbu16n2zUoKRgfQAajmGI0Z9avAaAzeLoNZLJlxRxiiyQShMOiBThtU8NlXtI9aKe02uUCC56qUWf9jmaTmVckLRRCHKRZCTEHGGPYEyIhCUCC5QgqPEjmYnv5YxUo6)CHKlX8nSHe9i1H3CDDJvgOrZn2a0Y8kO0fCpftmVy4gtJA5j8lpUXSQbu16n2zUoKRgfQAajmGI0Z9avAaAzeLoNZLJlxRxiiyQShMOiBThtU8NlXtI9aKe02uUCC56qUFA1QLNeWf9jnaTmVckLRRCHKlq90aegGwEuHlOrT8eEUqY1zUwVqqyaA5rfU4bNlhxUQbuQxcJCtvU8LRJ(pxx5cjxRxiimaT8Ocxyak7CU8N7r5cjxN5A9cbbX8nSHKgKxlXdoxoUCTEHGGy(g2qs)B0s8GZ1vUqYLHqECK7rWuzpmrr2ApMC5lxh)gRmqJMBSbOL5vqPl4EkMrEXWnMg1Yt4xECJzvdOQ1BSZCDixnku1asyafPN7bQ0a0YikDoNlhxUwVqqWuzpmrr2ApMC5pxINe7bijOTPC54Y1HCHl6tyaAzEfukxx5cjxRxiiiMVHnK0G8AjkYw7XKlF5645cjxI5Bydj6rAqETYfsUoKlq90aegGwEuHlOrT8eEUqYLHqECK7rWuzpmrr2ApMC5lxh)gRmqJMBSbOL5vqPl4EkMhDXWnMg1Yt4xECJzvdOQ1BSZCTEHGGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCJmxi5wedRwqjjOTPC5p3FZ1vUCC5YWQfuYK7HCpkxx5cjxfwYWsSZ5cj3pTA1YtcJ(rYaQKmv2d7gRmqJMB8qUL2i0Cb3tXeJVy4gtJA5j8lpUXSQbu16n2zUwVqqqmFdBiP)nAjEW5YXLRZCzy1ckzY9qUrMlKClIHvlOKe02uU8N7V56kxoUCzy1ckzY9qUhLlhxUwVqqWuzpmXdoxx5cjxfwYWsSZ5cj3pTA1YtcJ(rYaQKmv2d7gRmqJMBmw1hK2i0Cb3tX83lgUX0OwEc)YJBmRAavTEJDMR1leeeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBK5cj3Iyy1ckjbTnLl)5(BUUYLJlxgwTGsMCpK7r5YXLR1leemv2dt8GZ1vUqYvHLmSe7CUqY9tRwT8KWOFKmGkjtL9WUXkd0O5ghEEV0gHMl4EkMyKlgUXkd0O5g7wRQrLefKK)n0nMg1Yt4xECb3tX0XVy4gtJA5j8lpUXSQbu16n2zUAuOQbKWaksp3duPbOLru6Coxi5A9cbbtL9WefzR9yYLVCjEsShGKG2MYfsUWf9jCxkaBUUYLJlxN56qUAuOQbKWaksp3duPbOLru6CoxoUCTEHGGPYEyIIS1Em5YFUepj2dqsqBt5YXLRd5cx0NWa0k0fLRRCHKRZCjMVHnKOhP)nALlhxUeZ3WgsyqETKdXtqUCC5smFdBiHo8khINGC54Y16fcc3AvnQKOGK8VHep4CHKR1leeeZ3Wgs6FJwIhCUCC56mxRxiiyQShMOiBThtU8NRYanAeUlfGvq8KypajbTnLlKCTEHGGPYEyIhCUUY1vUCC56mxnku1asGRUNEGknVru6Cox(YnYCHKR1leeeZ3WgsAqETefzR9yYLVC)nxi56qUwVqqGRUNEGknVruKT2Jjx(YvzGgnc3LcWkiEsShGKG2MY11nwzGgn3ydqRqx0fCpfZJ)IHBmnQLNWV84gZQgqvR3yG6PbimaY71sIxDaiOrT8eEUqY16fccdqRG69IIcfzWQwEkxi5gAOybYIS1Em5YxUwVqqyaAfuVxG)kf0Ojxi56mxhYLy(g2qIEK6WBUCC5A9cbHbOL5vqjjzdJCtLnnaXdoxx3yLbA0CJnaTcQ3Fb3tX0rVy4gRmqJMBS7sbyVX0OwEc)YJl4EAK)Vy4gtJA5j8lpUXkd0O5gxVrQmqJgPVnGBSVna5O20noOEpaB9UGl4cUXFuzA0CpnY)r(hZ)rIX3y3An9a1CJXOYXIJ1tXOFkg1oMCZfdyPCBByubYnGQCXOHxKAB1dovy0YTOO6RlcpxdYMYvFaKTci8Czy1bkzez0hxpuUr6yYnQrZhvacp342oQZ1W7auEM7XYfGY94EAU49xBA0KlcMkfGQCD(JRCDIjpDjYOpUEOCX8VJj3OgnFubi8CJB7OoxdVdq5zUh7y5cq5ECpnxBe(Z)m5IGPsbOkxNhZvUoXKNUez0hxpuUyIPJj3OgnFubi8CJB7OoxdVdq5zUh7y5cq5ECpnxBe(Z)m5IGPsbOkxNhZvUoXKNUez0hxpuUygPJj3OgnFubi8CJB7OoxdVdq5zUh7y5cq5ECpnxBe(Z)m5IGPsbOkxNhZvUoXKNUez0hxpuUyIrCm5g1O5JkaHNBCBh15A4DakpZ9y5cq5ECpnx8(RnnAYfbtLcqvUo)XvUoXKNUez0z0yu5yXX6Py0pfJAhtU5IbSuUTnmQa5gqvUy0GlIHSTuagTClkQ(6IWZ1GSPC1hazRacpxgwDGsgrg9X1dL7VoMCJA08rfGWZnUTJ6Cn8oaLN5ESCbOCpUNMlE)1Mgn5IGPsbOkxN)4kxNrYtxIm6mAmQCS4y9um6NIrTJj3CXawk32ggvGCdOkxmAkIWOLBrr1xxeEUgKnLR(aiBfq45YWQduYiYOpUEOCJ0XKBuJMpQaeEUXTDuNRH3bO8m3JDSCbOCpUNMRnc)5FMCrWuPauLRZJ5kxNyYtxIm6JRhkxm2XKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav568hx56etE6sKrFC9q5E8oMCJA08rfGWZnUTJ6Cn8oaLN5ESCbOCpUNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm6JRhkxmX0XKBuJMpQaeEUXTDuNRH3bO8m3JDSCbOCpUNMRnc)5FMCrWuPauLRZJ5kxNyYtxIm6JRhkxmJ0XKBuJMpQaeEUXTDuNRH3bO8m3JDSCbOCpUNMRnc)5FMCrWuPauLRZJ5kxNyYtxIm6JRhkxmXyhtUrnA(Ocq45g32rDUgEhGYZCp2XYfGY94EAU2i8N)zYfbtLcqvUopMRCDIjpDjYOpUEOCX84Dm5g1O5JkaHNBCBh15A4DakpZ9y5cq5ECpnx8(RnnAYfbtLcqvUo)XvUoXKNUez0hxpuUy6OoMCJA08rfGWZnUTJ6Cn8oaLN5ESCbOCpUNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm6JRhk3i)7yYnQrZhvacp342oQZ1W7auEM7XYfGY94EAU49xBA0KlcMkfGQCD(JRCDIjpDjYOpUEOCJ8xhtUrnA(Ocq45g32rDUgEhGYZCpwUauUh3tZfV)AtJMCrWuPauLRZFCLRZi5PlrgDgngvowCSEkg9tXO2XKBUyalLBBdJkqUbuLlgndaJwUffvFDr45Aq2uU6dGSvaHNldRoqjJiJ(46HY94Dm5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWF(Njxemvkav568yUY1jM80LiJ(46HY1rDm5g1O5JkaHNBCBh15A4DakpZ9yhlxak3J7P5AJWF(Njxemvkav568yUY1jM80LiJ(46HYfZ)oMCJA08rfGWZnUTJ6Cn8oaLN5ESJLlaL7X90CTr4p)ZKlcMkfGQCDEmx56etE6sKrFC9q5IjgXXKBuJMpQaeEUXTDuNRH3bO8m3JLlaL7X90CX7V20Ojxemvkav568hx56etE6sKrFC9q5I5X7yYnQrZhvacp342oQZ1W7auEM7XYfGY94EAU49xBA0KlcMkfGQCD(JRCDIjpDjYOZOXOYXIJ1tXOFkg1oMCZfdyPCBByubYnGQCXOzHuagTClkQ(6IWZ1GSPC1hazRacpxgwDGsgrg9X1dLlMr6yYnQrZhvacp342oQZ1W7auEM7XowUauUh3tZ1gH)8ptUiyQuaQY15XCLRtm5Plrg9X1dLlMyehtUrnA(Ocq45g32rDUgEhGYZCpwUauUh3tZfV)AtJMCrWuPauLRZFCLRZJ4Plrg9X1dLlMoUJj3OgnFubi8CJB7OoxdVdq5zUhlxak3J7P5I3FTPrtUiyQuaQY15pUY1jM80LiJoJgJUnmQaeEUhFUkd0OjxFBagrg9n2atS7Py(pYBmCHcTNUXo25Yd1RdJYfJI1RXZODSZfJcyaKfv5gPJEsUr(pY)z0z0o25g1y1bkzCmz0o25gvY1XcooHNBmYRvU8GuBrgTJDUrLCJAS6aLWZfOfuci7qUm1qMCbOCz8Y8KeOfucyez0o25gvY1XkzJ(i8CFZqmYy0I3C)0QvlpzY1zliXj5cx0N0a0Y8kOuUrf(YfUOpHbOL5vqjxIm6mALbA0yeWfXq2wk4GncnN7rgqLDgTYanAmc4IyiBlfeXHFCxkaBgTYanAmc4IyiBlfeXHFCxkaBgTYanAmc4IyiBlfeXHFmaTcDrz0kd0OXiGlIHSTuqeh(5tRwT80jJAthyO5dDMK4KH3HDYN6F0blKXaj4rOYPZqdflqwKT2JjQe5FxhdZi)7IVGhHkNodnuSazr2ApMOsK)gvCI5FhbOEAaIEyAnkOrJGg1Yt4UIkoXyhHHg8xdeWfXAdjvFdDSPbiOrT8eUlxhdZJ)VRm6mAh7CXOqEsShGWZL(OI3CbTnLlalLRYaOk32KR(PTxT8KiJwzGgnMdgKxlPfP2z0kd0OXeXHF(0QvlpDYO20H2iveDYN6F0bdm59sGwqjGryaAfuVNpmH40bG6PbimaT8OcxqJA5jCooG6PbimaY71sIxDaiOrT8eUloodm59sGwqjGryaAfuVNViZOvgOrJjId)8PvRwE6KrTPdTrY8K(rN8P(hDWatEVeOfucyegGwHUi(WmJwzGgnMio8JfvgQo3d0t6WbNoWqF0OdqmnuSazqjoohyiKhh5Eem08HotsawsAG7QbgXd2feRxiiyQShM4bNrRmqJgteh(bgbA0Cshoy9cbbtL9Wep4mALbA0yI4WppdjBazBYOvgOrJjId)uVrQmqJgPVnGtg1MoOi6edOAg4aMN0HdFA1QLNeTrQikJwzGgnMio8t9gPYanAK(2aozuB6aErQTvp4uDIbundCaZt6WH6nuavqjbOTj3OAK4fP2w9GtLGIQVggMWZOvgOrJjId)uVrQmqJgPVnGtg1MoyHuWjgq1mWbmpPdhQ3qbubLewQxhgjrbP69sa2EGAeuu91WWeEgTYanAmrC4N6nsLbA0i9TbCYO20bd4KoCWtFKNVF)NrRmqJgteh(5tRwT80jJAthGl6t6Uua2t(u)Joax0NWDPaSz0kd0OXeXHF(0QvlpDYO20b4I(KgGwHUOt(u)Joax0NWa0k0fLrRmqJgteh(5tRwT80jJAthGl6tAaAzEfu6Kp1)OdWf9jmaTmVckLrRmqJgteh(PEJuzGgnsFBaNmQnDaUiyfWWknGm6mALbA0yekIo8PvRwE6KrTPd4fP2s3T3ldQ3lrHWjFQ)rhCA9cbbOTj3OAK4fP2w9GtLOiBThd)qz4cBLNr8xGjhN1leeG2MCJQrIxKAB1dovIIS1Em8RmqJgHbOvOlsq8KypajbTnfXFbMqCsmFdBirps)B0IJJy(g2qcdYRLCiEc44iMVHnKqhELdXtGlxqSEHGa02KBuns8IuBREWPs8GHuVHcOckjaTn5gvJeVi12QhCQeuu91WWeEgTYanAmcfrrC4hdqRG69N0HdwVqqyaAfuVxuuOidw1YtqCAGjVxc0ckbmcdqRG698FehNd1BOaQGscqBtUr1iXlsTT6bNkbfvFnmmH7cIthQ3qbubLeEEzAPgzWteOhOsO(2g2qckQ(AyycNJd020Xogg)lFwVqqyaAfuVxuKT2JjIiDLrRmqJgJqrueh(Xa0kOE)jD4q9gkGkOKa02KBuns8IuBREWPsqr1xddt4qmWK3lbAbLagHbOvq9E(oCeeNoy9cbbOTj3OAK4fP2w9GtL4bdX6fccdqRG69IIcfzWQwEIJZ5NwTA5jbErQT0D79YG69suiaXP1leegGwb17ffzR9y4)ioodm59sGwqjGryaAfuVNViHaupnaHbqEVws8QdabnQLNWHy9cbHbOvq9Err2Apg()1Llxz0kd0OXiuefXHF(0QvlpDYO20bdqRG69s3ObidQ3lrHWjFQ)rhudOuVeg5Mk(o()rfNy(3rSEHGa02KBuns8IuBREWPsyak7SROItRxiimaTcQ3lkYw7X4ihDmdm59sSQbqUIkoXrar4v8krbj5FdjkYw7X4i)6cI1leegGwb17fp4mALbA0yekII4WpgGwMxbLoPdh(0QvlpjWlsTLUBVxguVxIcbiFA1QLNegGwb17LUrdqguVxIcHmALbA0yekII4WpM3e6IoHXlZtsGwqjG5aMN0HdffkYGvT8eeGwqjGa02KeGK4nXhMyCuXatEVeOfucyIOiBThdefwYWsSZqiMVHnKOhPo8MrRmqJgJqrueh(rXvyq)rsJBTSpHXlZtsGwqjG5aMN0HdoaA25EGcXbLbA0iuCfg0FK04wlBjUARqjrpYGVHIfWXHJacfxHb9hjnU1YwIR2kusyak7m)hbbhbekUcd6psACRLTexTvOKOiBThd)hLrRmqJgJqrueh(XgHMqx0jmEzEsc0ckbmhW8KoCOOqrgSQLNGa0ckbeG2MKaKeVj(CIjghHtdm59sGwqjGryaAf6ICemf)6Y1XmWK3lbAbLaMikYw7XaXPtgc5XrUhbtL9WefP48YXzGjVxc0ckbmcdqRqxe)hXX5Ky(g2qIEKgKxlooI5Bydj6rAHay54iMVHnKOhP)nAbXbG6PbimONxIcsawsgqfzacAulpHZXz9cbbC12OcVvVulMontc)8gTeFQ)r8DiYF)7cItdm59sGwqjGryaAf6I4hZ)oItmJaOEAacG7EK2i0ye0OwEc3LliQbuQxcJCtfF)(pQy9cbHbOvq9Err2ApghbJ4cIdwVqqCUh8IWLKnmYnv20aK0qf0okK4bdrHLmSe7SRmALbA0yekII4WpbuXijkihf8k6KoCqHLmSe7CgTYanAmcfrrC4Ns)Ob9mYqrtu49KoCW6fccMk7HjEWz0kd0OXiuefXHFyKNmGw9s13qhBAaN0HdoTEHGWa0kOEV4bZXPgqPEjmYnv897FxqCW6fccdYBanJepyioy9cbbtL9Wepyio7bqfmYRacxgAOybYIS1Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS1Emr44CC9aOcg5vaHldnuSazr2ApMJDmmp()8hzKCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKbLCLrRmqJgJqrueh(PhMwJcA0Csho406fccdqRG69IhmhNAaL6LWi3uX3V)DbXbRxiimiVb0ms8GH4G1leemv2dt8GH4ShavWiVciCzOHIfilYw7XWpdH84i3JGHMp0zscWssdCxnWikYw7XeHJZX1dGkyKxbeUm0qXcKfzR9yo2XW84)Z)rrYXXqipoY9iyO5dDMKaSK0a3vdmIhmhNdm0hn6aetdflqguYLYanAmcfrrC4NZ9GxeU0a3vdmN0HdHgkwGSiBThd)y(lhNtRxiiGR2gv4T6LAX0Pzs4N3OL4t9pI)i)9phN1leeWvBJk8w9sTy60mj8ZB0s8P(hX3Hi)9VliwVqqyaAfuVx8GHWqipoY9iyQShMOiBThdF)(pJwzGgngHIOio8JbqEVwYGxl6egVmpjbAbLaMdyEshouuOidw1YtqaTnjbijEt8H5VqmWK3lbAbLagHbOvOlIFmgIclzyj2zioTEHGGPYEyIIS1Em8H5FoohSEHGGPYEyIhSRmALbA0yekII4WpFA1QLNozuB6adnFOZKKHg8g0O5Kp1)OdwVqqaxTnQWB1l1IPtZKWpVrlXN6Fe)r(7)OIAaL6LWi3ubXjdH84i3JGPYEyIIS1EmrG5F(cnuSazr2Apgoogc5XrUhbtL9WefzR9yI4O)8hAOybYIS1EmqcnuSazr2Apg(W8O)CCwVqqWuzpmrr2Apg(CCxqiMVHnKOhPo8YXfAOybYIS1Emh7yyg5F(X83mALbA0yekII4Wpm08HotsawsAG7QbMt6WHpTA1YtcgA(qNjjdn4nOrde1ak1lHrUPI)F)NrRmqJgJqrueh(j8kELOGK8VHoPdhiMVHnKOhPo8crHLmSe7meRxiiGR2gv4T6LAX0Pzs4N3OL4t9pI)i)9peN4iGqXvyq)rsJBTSL4QTcLeGMDUhOCCoWqF0OdqmeRqEuHZXzGjVxc0ckbm8fPRmALbA0yekII4WpgGwb17pPdhSEHGaneaRrctfJGbnAepyioTEHGWa0kOEVOOqrgSQLN44udOuVeg5Mk(C0)UYOvgOrJrOikId)yaAfuV)KoCGH(OrhGyAOybYGsq(0QvlpjyO5dDMKm0G3GgnqyiKhh5Eem08HotsawsAG7Qbgrr2Apg(HYWf2kpDeg1ENQbuQxcJCt1X(9VliwVqqyaAfuVxuuOidw1Ytz0kd0OXiuefXHFmaTmVckDshoWqF0OdqmnuSazqjiFA1QLNem08HotsgAWBqJgimeYJJCpcgA(qNjjaljnWD1aJOiBThd)qz4cBLNocJAVt1ak1lHrUP6yh93feRxiimaTcQ3lEWz0kd0OXiuefXHFmaTmVckDshoy9cbbAiawJK5jTKFTPrJ4bZX5GbOvOlsOWsgwIDMJZP1leemv2dtuKT2JH)FHy9cbbtL9WepyooNwVqqu6hnONrgkAIcVIIS1Em8dLHlSvE6imQ9ovdOuVeg5MQJD0FxqSEHGO0pAqpJmu0efEfpyxUG8PvRwEsyaAfuVx6gnazq9EjkeGyGjVxc0ckbmcdqRG698FugTYanAmcfrrC4NHClTrO5KoCWjX8nSHe9i1HximeYJJCpcMk7HjkYw7XW3V)54CYWQfuYCisifXWQfuscABI)FDXXXWQfuYC4ixquyjdlXoNrRmqJgJqrueh(bR6dsBeAoPdhCsmFdBirpsD4fcdH84i3JGPYEyIIS1Em897FooNmSAbLmhIesrmSAbLKG2M4)xxCCmSAbLmhoYfefwYWsSZz0kd0OXiuefXHFcpVxAJqZjD4GtI5Bydj6rQdVqyiKhh5Eemv2dtuKT2JHVF)ZX5KHvlOK5qKqkIHvlOKe02e))6IJJHvlOK5WrUGOWsgwIDoJwzGgngHIOio8JBTQgvsuqs(3qz0kd0OXiuefXHF(0QvlpDYO20bdqRqxKShPb516Kp1)OdgyY7LaTGsaJWa0k0fXhghrWJqLtB1aOIx5N6F0XI8VRicEeQCA9cbHbOL5vqjjzdJCtLnnaHbOSZhdJDLrRmqJgJqrueh(XDPaSN0HdeZ3Wgs4FJwYH4jGJJy(g2qcD4voepbq(0QvlpjAJK5j9J44SEHGGy(g2qsdYRLOiBThd)kd0OryaAf6Ieepj2dqsqBtqSEHGGy(g2qsdYRL4bZXrmFdBirpsdYRfeh(0QvlpjmaTcDrYEKgKxlooRxiiyQShMOiBThd)kd0OryaAf6Ieepj2dqsqBtqC4tRwT8KOnsMN0pcI1leemv2dtuKT2JHFINe7bijOTjiwVqqWuzpmXdMJZ6fcIs)Ob9mYqrtu4v8GHyGjVxIvnaIV)cmceNgyY7LaTGsad)hoIJZbG6PbimONxIcsawsgqfzacAulpH7IJZHpTA1YtI2izEs)iiwVqqWuzpmrr2Apg(iEsShGKG2MYOvgOrJrOikId)yaAf6IYOvgOrJrOikId)uVrQmqJgPVnGtg1MoeuVhGTEz0z0kd0OXiSqk4qPF0GEgzOOjk8Eshoy9cbbtL9Wep4mALbA0yewifeXHF(0QvlpDYO20bw1GbbEWN8P(hDWbRxiiSuVomsIcs17LaS9a1ihf8ks8GH4G1leewQxhgjrbP69sa2EGAKAX0Hep4mALbA0yewifeXHFy6WiV06fcNmQnDWa0YJk8t6WbNwVqqyPEDyKefKQ3lby7bQrok4vKOiBThdFyS4xooRxiiSuVomsIcs17LaS9a1i1IPdjkYw7XWhgl(1fe1ak1lHrUPIVdo6FioziKhh5Eemv2dtuKT2JHphNJZjdH84i3JGSHrUPsAHgCrr2Apg(CCioy9cbX5EWlcxs2Wi3uztdqsdvq7OqIhmeg6JgDaIZ8wToUCLrRmqJgJWcPGio8JbOL5vqPt6Wbh(0Qvlpjyvdge4bdXPthyiKhh5Eem08HotsawsAG7QbgXdMJZHpTA1YtcgA(qNjjdn4nOrdhNdm0hn6aetdflqguYfeNm0hn6aetdflqguIJZjdH84i3JGPYEyIIS1Em854CCoziKhh5EeKnmYnvsl0GlkYw7XWNJdXbRxiio3dEr4sYgg5MkBAasAOcAhfs8GHWqF0OdqCM3Q1XLlxU44CYqipoY9iyO5dDMKaSK0a3vdmIhmegc5XrUhbtL9WefP48cHH(OrhGyAOybYGsUYOvgOrJryHuqeh(rXvyq)rsJBTSpHXlZtsGwqjG5aMN0HdoGJacfxHb9hjnU1YwIR2kusaA25EGcXbLbA0iuCfg0FK04wlBjUARqjrpYGVHIfaXPd4iGqXvyq)rsJBTSLyj1lan7Cpq54WraHIRWG(JKg3AzlXsQxuKT2JHVFDXXHJacfxHb9hjnU1YwIR2kusyak7m)hbbhbekUcd6psACRLTexTvOKOiBThd)hbbhbekUcd6psACRLTexTvOKa0SZ9anJwzGgngHfsbrC4hZBcDrNW4L5jjqlOeWCaZt6WHIcfzWQwEccqlOeqaABscqs8M4dtmcefwYWsSZqC(PvRwEsWQgmiWdMJZPAaL6LWi3uX)r)H4G1leemv2dt8GDXXXqipoY9iyQShMOifNxxz0kd0OXiSqkiId)yJqtOl6egVmpjbAbLaMdyEshouuOidw1YtqaAbLacqBtsasI3eFyEK4xikSKHLyNH48tRwT8KGvnyqGhmhNt1ak1lHrUPI)J(dXbRxiiyQShM4b7IJJHqECK7rWuzpmrrkoVUG4G1leeN7bViCjzdJCtLnnajnubTJcjEWz0kd0OXiSqkiId)yaK3RLm41IoHXlZtsGwqjG5aMN0HdffkYGvT8eeGwqjGa02KeGK4nXhMyKikYw7XarHLmSe7meNFA1QLNeSQbdc8G54udOuVeg5Mk(p6phhdH84i3JGPYEyIIuCEDLrRmqJgJWcPGio8tavmsIcYrbVIoPdhuyjdlXoNrRmqJgJWcPGio8t4v8krbj5FdDsho4Ky(g2qIEK6WlhhX8nSHegKxlzpsm54iMVHnKW)gTK9iX0feNoWqF0OdqmnuSazqjooNQbuQxcJCtf)o6VqC(PvRwEsWQgmiWdMJtnGs9syKBQ4)O)CCFA1QLNeTrQiYfeNFA1QLNem08HotsCYW7WG4adH84i3JGHMp0zscWssdCxnWiEWCCo8PvRwEsWqZh6mjXjdVddIdmeYJJCpcMk7HjEWUC5cItgc5XrUhbtL9WefzR9y47O)CCQbuQxcJCtfFo6FimeYJJCpcMk7HjEWqCYqipoY9iiByKBQKwObxuKT2JHFLbA0imaTcDrcINe7bijOTjoohyOpA0bioZB164IJl0qXcKfzR9y4hZ)UG4ehbekUcd6psACRLTexTvOKOiBThdFymhNdm0hn6aedXkKhv4UYOvgOrJryHuqeh(5Cp4fHlnWD1aZjD4GtI5Bydj8Vrl5q8eWXrmFdBiHb51soepbCCeZ3WgsOdVYH4jGJZ6fccl1RdJKOGu9EjaBpqnYrbVIefzR9y4dJf)YXz9cbHL61HrsuqQEVeGThOgPwmDirr2Apg(WyXVCCQbuQxcJCtfFo6FimeYJJCpcMk7HjksX51feNmeYJJCpcMk7HjkYw7XW3r)54yiKhh5Eemv2dtuKIZRloUqdflqwKT2JHFm)NrRmqJgJWcPGio8dJ8Kb0QxQ(g6ytd4KoCWPAaL6LWi3uXNJ(hItRxiio3dEr4sYgg5MkBAasAOcAhfs8G54CGH(OrhG4mVvRJloog6JgDaIPHIfidkXXz9cbHLhHW9pdq8GHy9cbHLhHW9pdquKT2JH)i)hHtm2ryOb)1abCrS2qs13qhBAacAulpH7YfeNoWqF0OdqmnuSazqjoogc5XrUhbdnFOZKeGLKg4UAGr8G54cnuSazr2Apg(ziKhh5Eem08HotsawsAG7Qbgrr2ApMiWiCCHgkwGSiBThZXogMh)F(J8FeoXyhHHg8xdeWfXAdjvFdDSPbiOrT8eUlxz0kd0OXiSqkiId)0dtRrbnAoPdhCQgqPEjmYnv85O)H406fcIZ9GxeUKSHrUPYMgGKgQG2rHepyoohyOpA0bioZB164IJJH(OrhGyAOybYGsCCwVqqy5riC)ZaepyiwVqqy5riC)ZaefzR9y4)O)r4eJDegAWFnqaxeRnKu9n0XMgGGg1Yt4UCbXPdm0hn6aetdflqguIJJHqECK7rWqZh6mjbyjPbURgyepyoUpTA1YtcgA(qNjjoz4DyqcnuSazr2Apg(W84)hrK)JWjg7im0G)AGaUiwBiP6BOJnnabnQLNWDXXfAOybYIS1Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS1EmrGr44cnuSazr2Apg(p6FeoXyhHHg8xdeWfXAdjvFdDSPbiOrT8eUlxz0kd0OXiSqkiId)WqZh6mjbyjPbURgyoPdhC(PvRwEsWqZh6mjXjdVddsOHIfilYw7XWhMh9NJZ6fccMk7HjEWUG406fccl1RdJKOGu9EjaBpqnYrbVIegGYol)u)J47O)CCwVqqyPEDyKefKQ3lby7bQrQfthsyak7S8t9pIVJ(7IJl0qXcKfzR9y4hZ)z0kd0OXiSqkiId)yaAzEfu6KoCGH(OrhGyAOybYGsqC(PvRwEsWqZh6mjXjdVdJJJHqECK7rWuzpmrr2Apg(X8VliQbuQxcJCtfF)(hcdH84i3JGHMp0zscWssdCxnWikYw7XWpM)ZOvgOrJryHuqeh(5tRwT80jJAthudmgLuftSt(u)JoqmFdBirps)B0Yro(JPmqJgHbOvOlsq8KypajbTnfHdeZ3Wgs0J0)gTCemYXugOrJWDPaScINe7bijOTPi(lI8ygyY7LyvdGYOvgOrJryHuqeh(Xa0Y8kO0jD4GZEaubJ8kGWLHgkwGSiBThd)ymhNtRxiik9Jg0ZidfnrHxrr2Apg(HYWf2kpDeg1ENQbuQxcJCt1Xo6VliwVqqu6hnONrgkAIcVIhSlxCCovdOuVeg5MQi(0QvlpjudmgLuftmhX6fccI5BydjniVwIIS1EmrGJaIWR4vIcsY)gsaA2zJSiBThhjsXV8HzK)54udOuVeg5MQi(0QvlpjudmgLuftmhX6fccI5Bydj9Vrlrr2ApMiWrar4v8krbj5Fdjan7SrwKT2JJeP4x(WmY)UGqmFdBirpsD4fItNoWqipoY9iyQShM4bZXXqF0OdqCM3Q1bIdmeYJJCpcYgg5MkPfAWfpyxCCm0hn6aetdflqguYfeNoWqF0Odq8rdalVfhNdwVqqWuzpmXdMJtnGs9syKBQ4Zr)7IJZ6fccMk7HjkYw7XW3XdXbRxiik9Jg0ZidfnrHxXdoJwzGgngHfsbrC4NHClTrO5KoCWP1leeeZ3Wgs6FJwIhmhNtgwTGsMdrcPigwTGssqBt8)RloogwTGsMdh5cIclzyj25mALbA0yewifeXHFWQ(G0gHMt6WbNwVqqqmFdBiP)nAjEWCCozy1ckzoejKIyy1ckjbTnX)VU44yy1ckzoCKlikSKHLyNZOvgOrJryHuqeh(j88EPncnN0HdoTEHGGy(g2qs)B0s8G54CYWQfuYCisifXWQfuscABI)FDXXXWQfuYC4ixquyjdlXoNrRmqJgJWcPGio8JBTQgvsuqs(3qz0kd0OXiSqkiId)yaAf6IoPdhiMVHnKOhP)nAXXrmFdBiHb51soepbCCeZ3WgsOdVYH4jGJZ6fcc3AvnQKOGK8VHepyieZ3Wgs0J0)gT44CA9cbbtL9WefzR9y4xzGgnc3LcWkiEsShGKG2MGy9cbbtL9Wepyxz0kd0OXiSqkiId)4Uua2mALbA0yewifeXHFQ3ivgOrJ03gWjJAthcQ3dWwVm6mALbA0ye4fP2w9Gt1HpTA1YtNmQnDWObscqYNHKgyY7p5t9p6GtRxiiaTn5gvJeVi12QhCQefzR9y4dkdxyR8mI)cmH4Ky(g2qIEKwiawooI5Bydj6rAqET44iMVHnKW)gTKdXtGlooRxiiaTn5gvJeVi12QhCQefzR9y4tzGgncdqRqxKG4jXEascABkI)cmH4Ky(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaxU44CW6fccqBtUr1iXlsTT6bNkXdoJwzGgngbErQTvp4ufXHFmaTmVckDsho40HpTA1YtcJgijajFgsAGjVNJZP1leeL(rd6zKHIMOWROiBThd)qz4cBLNocJAVt1ak1lHrUP6yh93feRxiik9Jg0ZidfnrHxXd2Lloo1ak1lHrUPIph9FgTYanAmc8IuBREWPkId)O4kmO)iPXTw2NW4L5jjqlOeWCaZt6WbhWraHIRWG(JKg3AzlXvBfkjan7CpqH4GYanAekUcd6psACRLTexTvOKOhzW3qXcG40bCeqO4kmO)iPXTw2sSK6fGMDUhOCC4iGqXvyq)rsJBTSLyj1lkYw7XW3VU44WraHIRWG(JKg3AzlXvBfkjmaLDM)JGGJacfxHb9hjnU1YwIR2kusuKT2JH)JGGJacfxHb9hjnU1YwIR2kusaA25EGMrRmqJgJaVi12QhCQI4Wp2i0e6IoHXlZtsGwqjG5aMN0HdffkYGvT8eeGwqjGa02KeGK4nXhMrcXPtRxiiyQShMOiBThdF)cXP1leeL(rd6zKHIMOWROiBThdF)YX5G1leeL(rd6zKHIMOWR4b7IJZbRxiiyQShM4bZXPgqPEjmYnv8F0FxqC6G1leeN7bViCjzdJCtLnnajnubTJcjEWCCQbuQxcJCtf)h93fefwYWsSZUYOvgOrJrGxKAB1dovrC4hZBcDrNW4L5jjqlOeWCaZt6WHIcfzWQwEccqlOeqaABscqs8M4dZiH40P1leemv2dtuKT2JHVFH406fcIs)Ob9mYqrtu4vuKT2JHVF54CW6fcIs)Ob9mYqrtu4v8GDXX5G1leemv2dt8G54udOuVeg5Mk(p6VlioDW6fcIZ9GxeUKSHrUPYMgGKgQG2rHepyoo1ak1lHrUPI)J(7cIclzyj2zxz0kd0OXiWlsTT6bNQio8JbqEVwYGxl6egVmpjbAbLaMdyEshouuOidw1YtqaAbLacqBtsasI3eFyIrG40P1leemv2dtuKT2JHVFH406fcIs)Ob9mYqrtu4vuKT2JHVF54CW6fcIs)Ob9mYqrtu4v8GDXX5G1leemv2dt8G54udOuVeg5Mk(p6VlioDW6fcIZ9GxeUKSHrUPYMgGKgQG2rHepyoo1ak1lHrUPI)J(7cIclzyj2zxz0kd0OXiWlsTT6bNQio8tavmsIcYrbVIoPdhuyjdlXoNrRmqJgJaVi12QhCQI4WpL(rd6zKHIMOW7jD4G1leemv2dt8GZOvgOrJrGxKAB1dovrC4NZ9GxeU0a3vdmN0HdoDA9cbbX8nSHKgKxlrr2Apg(W8phN1leeeZ3Wgs6FJwIIS1Em8H5FxqyiKhh5Eemv2dtuKT2JHVJ(7IJJHqECK7rWuzpmrrkoVz0kd0OXiWlsTT6bNQio8dJ8Kb0QxQ(g6ytd4KoCWP1leeN7bViCjzdJCtLnnajnubTJcjEWCCoWqF0OdqCM3Q1Xfhhd9rJoaX0qXcKbL44(0QvlpjAJurehN1leewEec3)maXdgI1leewEec3)marr2Apg(J8FeoXyhHHg8xdeWfXAdjvFdDSPbiOrT8eUlioy9cbbtL9Wepyio7bqfmYRacxgAOybYIS1Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS1Emr44CC9aOcg5vaHldnuSazr2Apg(JmsoUEaubJ8kGWLHgkwGSiBThZXogMh)F(Jmsoogc5XrUhbdnFOZKeGLKg4UAGr8G54CGH(OrhGyAOybYGsUYOvgOrJrGxKAB1dovrC4NEyAnkOrZjD4GtRxiio3dEr4sYgg5MkBAasAOcAhfs8G54CGH(OrhG4mVvRJloog6JgDaIPHIfidkXX9PvRwEs0gPIiooRxiiS8ieU)zaIhmeRxiiS8ieU)zaIIS1Em8F0)iCIXocdn4VgiGlI1gsQ(g6ytdqqJA5jCxqCW6fccMk7HjEWqC2dGkyKxbeUm0qXcKfzR9y4NHqECK7rWqZh6mjbyjPbURgyefzR9yIWX546bqfmYRacxgAOybYIS1Em8FuKCC9aOcg5vaHldnuSazr2ApMJDmmp()8FuKCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKbLCLrRmqJgJaVi12QhCQI4WpFA1QLNozuB6adnFOZKKHg8g0O5Kp1)Odm0hn6aetdflqgucItRxiiGR2gv4T6LAX0Pzs4N3OL4t9pI)iX4)qCYqipoY9iyQShMOiBThtey(NVEaubJ8kGWLHgkwGSiBThdhhdH84i3JGPYEyIIS1EmrC0F(7bqfmYRacxgAOybYIS1Emq6bqfmYRacxgAOybYIS1Em8H5r)54SEHGGPYEyIIS1Em854UGy9cbbX8nSHKgKxlrr2Apg(W8phxpaQGrEfq4YqdflqwKT2J5yhdZi)ZpM)6kJwzGgngbErQTvp4ufXHF(0QvlpDYO20bJ(rYaQKmv2d7Kp1)OdoDGHqECK7rWuzpmrrkoVCCo8PvRwEsWqZh6mjzObVbnAGWqF0OdqmnuSazqjxz0kd0OXiWlsTT6bNQio8ddnFOZKeGLKg4UAG5KoC4tRwT8KGHMp0zsYqdEdA0arnGs9syKBQ4hJ)NrRmqJgJaVi12QhCQI4WpHxXRefKK)n0jD4aX8nSHe9i1HxikSKHLyNH4ehbekUcd6psACRLTexTvOKa0SZ9aLJZbg6JgDaIHyfYJkCxq(0Qvlpjm6hjdOsYuzpSmALbA0ye4fP2w9Gtveh(Xa0Y8kO0jD4ad9rJoaX0qXcKbLG8PvRwEsWqZh6mjzObVbnAGOgqPEjmYnv8DaJ)dHHqECK7rWqZh6mjbyjPbURgyefzR9y4hkdxyR80ryu7DQgqPEjmYnvh7O)UYOvgOrJrGxKAB1dovrC4NHClTrO5KoCWP1leeeZ3Wgs6FJwIhmhNtgwTGsMdrcPigwTGssqBt8)RloogwTGsMdh5cIclzyj2ziFA1QLNeg9JKbujzQShwgTYanAmc8IuBREWPkId)Gv9bPncnN0HdoTEHGGy(g2qs)B0s8GH4ad9rJoaXzERwhooNwVqqCUh8IWLKnmYnv20aK0qf0okK4bdHH(OrhG4mVvRJlooNmSAbLmhIesrmSAbLKG2M4)xxCCmSAbLmhoIJZ6fccMk7HjEWUGOWsgwIDgYNwTA5jHr)izavsMk7HLrRmqJgJaVi12QhCQI4WpHN3lTrO5KoCWP1leeeZ3Wgs6FJwIhmehyOpA0bioZB16WX506fcIZ9GxeUKSHrUPYMgGKgQG2rHepyim0hn6aeN5TADCXX5KHvlOK5qKqkIHvlOKe02e))6IJJHvlOK5WrCCwVqqWuzpmXd2fefwYWsSZq(0Qvlpjm6hjdOsYuzpSmALbA0ye4fP2w9Gtveh(XTwvJkjkij)BOmALbA0ye4fP2w9Gtveh(Xa0k0fDshoqmFdBirps)B0IJJy(g2qcdYRLCiEc44iMVHnKqhELdXtahN1leeU1QAujrbj5FdjEWqSEHGGy(g2qs)B0s8G54CA9cbbtL9WefzR9y4xzGgnc3LcWkiEsShGKG2MGy9cbbtL9Wepyxz0kd0OXiWlsTT6bNQio8J7sbyZOvgOrJrGxKAB1dovrC4N6nsLbA0i9TbCYO20HG69aS1lJoJwzGgngrq9Ea26DWa0Y8kO0jD4Gd1BOaQGscl1RdJKOGu9EjaBpqnckQ(AyycpJwzGgngrq9Ea26fXHFmVj0fDcJxMNKaTGsaZbmpPdhWraHncnHUirr2Apg(kYw7XKrRmqJgJiOEpaB9I4Wp2i0e6IYOZOvgOrJraxeScyyLgWbBeAcDrNW4L5jjqlOeWCaZt6WHIcfzWQwEccqlOeqaABscqs8M4dZiH406fccMk7HjkYw7XW3VCCoy9cbbtL9Wepyoo1ak1lHrUPI)J(7cIclzyj25mALbA0yeWfbRagwPbeXHFmVj0fDcJxMNKaTGsaZbmpPdhkkuKbRA5jiaTGsabOTjjajXBIpmJeItRxiiyQShMOiBThdF)YX5G1leemv2dt8G54udOuVeg5Mk(p6VlikSKHLyNZOvgOrJraxeScyyLgqeh(XaiVxlzWRfDcJxMNKaTGsaZbmpPdhkkuKbRA5jiaTGsabOTjjajXBIpmJeItRxiiyQShMOiBThdF)YX5G1leemv2dt8G54udOuVeg5Mk(p6VlikSKHLyNZOvgOrJraxeScyyLgqeh(jGkgjrb5OGxrN0HdkSKHLyNZOvgOrJraxeScyyLgqeh(HrEYaA1lvFdDSPbCsho4unGs9syKBQ4Zr)ZXz9cbHLhHW9pdq8GHy9cbHLhHW9pdquKT2JH)iXiUG4G1leemv2dt8GZOvgOrJraxeScyyLgqeh(PhMwJcA0Csho4unGs9syKBQ4Zr)ZXz9cbHLhHW9pdq8GHy9cbHLhHW9pdquKT2JH)JWiUG4G1leemv2dt8GZOvgOrJraxeScyyLgqeh(5tRwT80jJAthm6hjdOsYuzpSt(u)Jo4adH84i3JGPYEyIIuCEZOvgOrJraxeScyyLgqeh(j8kELOGK8VHoPdhiMVHnKOhPo8crHLmSe7mKpTA1YtcJ(rYaQKmv2dlJwzGgngbCrWkGHvAarC4hMomYlTEHWjJAthmaT8Oc)KoCW6fccdqlpQWffzR9y4hJaXP1leeeZ3WgsAqETepyooRxiiiMVHnK0)gTepyxqudOuVeg5Mk(C0)z0kd0OXiGlcwbmSsdiId)yaAzEfu6KoCWPdAuOQbKWaksp3duPbOLru6CMJZ6fccMk7HjkYw7XWpXtI9aKe02ehNdWf9jmaTmVck5cItRxiiyQShM4bZXPgqPEjmYnv85O)HqmFdBirpsD41vgTYanAmc4IGvadR0aI4WpgGwMxbLoPdhC6GgfQAajmGI0Z9avAaAzeLoN54SEHGGPYEyIIS1Em8t8KypajbTnXX5WNwTA5jbCrFsdqlZRGsUGaupnaHbOLhv4cAulpHdXP1leegGwEuHlEWCCQbuQxcJCtfFo6FxqSEHGWa0YJkCHbOSZ8FeeNwVqqqmFdBiPb51s8G54SEHGGy(g2qs)B0s8GDbHHqECK7rWuzpmrr2Apg(C8mALbA0yeWfbRagwPbeXHFmaTmVckDsho40bnku1asyafPN7bQ0a0YikDoZXz9cbbtL9WefzR9y4N4jXEascABIJZb4I(egGwMxbLCbX6fccI5BydjniVwIIS1Em854qiMVHnKOhPb51cIda1tdqyaA5rfUGg1Yt4qyiKhh5Eemv2dtuKT2JHphpJwzGgngbCrWkGHvAarC4NHClTrO5KoCWP1leeeZ3Wgs6FJwIhmhNtgwTGsMdrcPigwTGssqBt8)RloogwTGsMdh5cIclzyj2ziFA1QLNeg9JKbujzQShwgTYanAmc4IGvadR0aI4WpyvFqAJqZjD4GtRxiiiMVHnK0)gTepyooNmSAbLmhIesrmSAbLKG2M4)xxCCmSAbLmhoIJZ6fccMk7HjEWUGOWsgwIDgYNwTA5jHr)izavsMk7HLrRmqJgJaUiyfWWknGio8t459sBeAoPdhCA9cbbX8nSHK(3OL4bZX5KHvlOK5qKqkIHvlOKe02e))6IJJHvlOK5WrCCwVqqWuzpmXd2fefwYWsSZq(0Qvlpjm6hjdOsYuzpSmALbA0yeWfbRagwPbeXHFCRv1OsIcsY)gkJwzGgngbCrWkGHvAarC4hdqRqx0jD4Gtnku1asyafPN7bQ0a0YikDodX6fccMk7HjkYw7XWhXtI9aKe02ee4I(eUlfG1fhNth0OqvdiHbuKEUhOsdqlJO05mhN1leemv2dtuKT2JHFINe7bijOTjoohGl6tyaAf6ICbXjX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbCCwVqq4wRQrLefKK)nK4bdX6fccI5Bydj9VrlXdMJZP1leemv2dtuKT2JHFLbA0iCxkaRG4jXEascABcI1leemv2dt8GD5IJZPgfQAajWv3tpqLM3ikDoZxKqSEHGGy(g2qsdYRLOiBThdF)cXbRxiiWv3tpqLM3ikYw7XWNYanAeUlfGvq8KypajbTn5kJ2Xoxm6HC5f9YfGqNZngqEVw5IrXQdGtYLx0lx4czPwEEZ1ToGCniBk3yGwb17Z9bdABsiez0kd0OXiGlcwbmSsdiId)yaAfuV)KoCaOEAacdG8ETK4vhacAulpHdX6fccdqRG69IIcfzWQwEcsOHIfilYw7XWN1leegGwb17f4VsbnAG40bI5Bydj6rQdVCCwVqqyaAzEfuss2Wi3uztdq8GDLrRmqJgJaUiyfWWknGio8J7sbyZOvgOrJraxeScyyLgqeh(PEJuzGgnsFBaNmQnDiOEpaB9YOZOvgOrJryahuCfg0FK04wl7ty8Y8KeOfucyoG5jD4Gd4iGqXvyq)rsJBTSL4QTcLeGMDUhOqCqzGgncfxHb9hjnU1YwIR2kus0Jm4BOybqC6aociuCfg0FK04wlBjws9cqZo3duooCeqO4kmO)iPXTw2sSK6ffzR9y47xxCC4iGqXvyq)rsJBTSL4QTcLegGYoZ)rqWraHIRWG(JKg3AzlXvBfkjkYw7XW)rqWraHIRWG(JKg3AzlXvBfkjan7CpqZOvgOrJryarC4hBeAcDrNW4L5jjqlOeWCaZt6WHIcfzWQwEccqlOeqaABscqs8M4dZiH406fccMk7HjkYw7XW3VqCA9cbrPF0GEgzOOjk8kkYw7XW3VCCoy9cbrPF0GEgzOOjk8kEWU44CW6fccMk7HjEWCCQbuQxcJCtf)h93feNoy9cbX5EWlcxs2Wi3uztdqsdvq7OqIhmhNAaL6LWi3uX)r)DbrHLmSe7CgTYanAmcdiId)yEtOl6egVmpjbAbLaMdyEshouuOidw1YtqaAbLacqBtsasI3eFygjeNwVqqWuzpmrr2Apg((fItRxiik9Jg0ZidfnrHxrr2Apg((LJZbRxiik9Jg0ZidfnrHxXd2fhNdwVqqWuzpmXdMJtnGs9syKBQ4)O)UG40bRxiio3dEr4sYgg5MkBAasAOcAhfs8G54udOuVeg5Mk(p6VlikSKHLyNZOvgOrJryarC4hdG8ETKbVw0jmEzEsc0ckbmhW8KoCOOqrgSQLNGa0ckbeG2MKaKeVj(WeJaXP1leemv2dtuKT2JHVFH406fcIs)Ob9mYqrtu4vuKT2JHVF54CW6fcIs)Ob9mYqrtu4v8GDXX5G1leemv2dt8G54udOuVeg5Mk(p6VlioDW6fcIZ9GxeUKSHrUPYMgGKgQG2rHepyoo1ak1lHrUPI)J(7cIclzyj25mALbA0yegqeh(jGkgjrb5OGxrN0HdkSKHLyNZOvgOrJryarC4Ns)Ob9mYqrtu49KoCW6fccMk7HjEWz0kd0OXimGio8Z5EWlcxAG7QbMt6WbNoTEHGGy(g2qsdYRLOiBThdFy(NJZ6fccI5Bydj9Vrlrr2Apg(W8VlimeYJJCpcMk7HjkYw7XW3r)H406fcc4QTrfEREPwmDAMe(5nAj(u)J4psm(phNd1BOaQGsc4QTrfEREPwmDAMe(5nAjOO6RHHjCxU44SEHGaUABuH3QxQftNMjHFEJwIp1)i(oePJ)NJJHqECK7rWuzpmrrkoVqCQgqPEjmYnv85O)54(0QvlpjAJurKRmALbA0yegqeh(HrEYaA1lvFdDSPbCsho4unGs9syKBQ4Zr)dXP1leeN7bViCjzdJCtLnnajnubTJcjEWCCoWqF0OdqCM3Q1Xfhhd9rJoaX0qXcKbL44(0QvlpjAJurehN1leewEec3)maXdgI1leewEec3)marr2Apg(J8FeoD6Oos9gkGkOKaUABuH3QxQftNMjHFEJwckQ(Ayyc3veoXyhHHg8xdeWfXAdjvFdDSPbiOrT8eUlxUG4G1leemv2dt8GH4m0qXcKfzR9y4NHqECK7rWqZh6mjbyjPbURgyefzR9yIWX54cnuSazr2Apg(JmYiC6OoItRxiiGR2gv4T6LAX0Pzs4N3OL4t9pIpm))3LloUqdflqwKT2J5yhdZJ)p)rgjhhdH84i3JGHMp0zscWssdCxnWiEWCCoWqF0OdqmnuSazqjxz0kd0OXimGio8tpmTgf0O5KoCWPAaL6LWi3uXNJ(hItRxiio3dEr4sYgg5MkBAasAOcAhfs8G54CGH(OrhG4mVvRJloog6JgDaIPHIfidkXX9PvRwEs0gPIiooRxiiS8ieU)zaIhmeRxiiS8ieU)zaIIS1Em8F0)iC60rDK6nuavqjbC12OcVvVulMontc)8gTeuu91WWeURiCIXocdn4VgiGlI1gsQ(g6ytdqqJA5jCxUCbXbRxiiyQShM4bdXzOHIfilYw7XWpdH84i3JGHMp0zscWssdCxnWikYw7XeHJZXfAOybYIS1Em8FuKr40rDeNwVqqaxTnQWB1l1IPtZKWpVrlXN6FeFy()VlxCCHgkwGSiBThZXogMh)F(pksoogc5XrUhbdnFOZKeGLKg4UAGr8G54CGH(OrhGyAOybYGsUYOvgOrJryarC4NpTA1YtNmQnDGHMp0zsYqdEdA0CYN6F0bg6JgDaIPHIfidkbXP1leeWvBJk8w9sTy60mj8ZB0s8P(hXFKy8FioziKhh5Eemv2dtuKT2Jjcm)ZxOHIfilYw7XWXXqipoY9iyQShMOiBThteh9N)qdflqwKT2JbsOHIfilYw7XWhMh9NJZ6fccMk7HjkYw7XWNJ7cI1leeeZ3WgsAqETefzR9y4dZ)CCHgkwGSiBThZXogMr(NFm)1vgTYanAmcdiId)8PvRwE6KrTPdg9JKbujzQSh2jFQ)rhC6adH84i3JGPYEyIIuCE54C4tRwT8KGHMp0zsYqdEdA0aHH(OrhGyAOybYGsUYOvgOrJryarC4hgA(qNjjaljnWD1aZjD4WNwTA5jbdnFOZKKHg8g0ObIAaL6LWi3uX)r)ZOvgOrJryarC4NWR4vIcsY)g6KoCGy(g2qIEK6WlefwYWsSZqSEHGaUABuH3QxQftNMjHFEJwIp1)i(JeJ)dXjociuCfg0FK04wlBjUARqjbOzN7bkhNdm0hn6aedXkKhv4UG8PvRwEsy0psgqLKPYEyz0kd0OXimGio8JbOvq9(t6WbRxiiqdbWAKWuXiyqJgXdgI1leegGwb17fffkYGvT8ugTYanAmcdiId)W0HrEP1leozuB6GbOLhv4N0HdwVqqyaA5rfUOiBThd))cXP1leeeZ3WgsAqETefzR9y47xooRxiiiMVHnK0)gTefzR9y47xxqudOuVeg5Mk(C0)z0kd0OXimGio8JbOL5vqPt6Wbg6JgDaIPHIfidkb5tRwT8KGHMp0zsYqdEdA0aHHqECK7rWqZh6mjbyjPbURgyefzR9y4hkdxyR80ryu7DQgqPEjmYnvh7O)UYOvgOrJryarC4hdqRG69N0Hda1tdqyaK3RLeV6aqqJA5jCioaupnaHbOLhv4cAulpHdX6fccdqRG69IIcfzWQwEcItRxiiiMVHnK0)gTefzR9y4dJaHy(g2qIEK(3OfeNouVHcOckjGR2gv4T6LAX0Pzs4N3OLGg1Yt4CCwVqqaxTnQWB1l1IPtZKWpVrlXN6Fe)r(7FxCCoDOEdfqfusaxTnQWB1l1IPtZKWpVrlbnQLNW54SEHGaUABuH3QxQftNMjHFEJwIp1)i(oe5V)DbrnGs9syKBQ4Zr)ZXHJacfxHb9hjnU1YwIR2kusuKT2JHVJNJtzGgncfxHb9hjnU1YwIR2kus0Jm4BOybUG4adH84i3JGPYEyIIuCEZOvgOrJryarC4hdqlZRGsN0HdwVqqGgcG1izEsl5xBA0iEWCCwVqqCUh8IWLKnmYnv20aK0qf0okK4bZXz9cbbtL9WepyioTEHGO0pAqpJmu0efEffzR9y4hkdxyR80ryu7DQgqPEjmYnvh7O)UGy9cbrPF0GEgzOOjk8kEWCCoy9cbrPF0GEgzOOjk8kEWqCGHqECK7ru6hnONrgkAIcVIIuCE54CGH(OrhG4JgawElxCCQbuQxcJCtfFo6FieZ3Wgs0JuhEZOvgOrJryarC4hdqlZRGsN0Hda1tdqyaA5rfUGg1Yt4qCA9cbHbOLhv4IhmhNAaL6LWi3uXNJ(3feRxiimaT8Ocxyak7m)hbXP1leeeZ3WgsAqETepyooRxiiiMVHnK0)gTepyxqSEHGaUABuH3QxQftNMjHFEJwIp1)i(J0X)dXjdH84i3JGPYEyIIS1Em8H5Fooh(0QvlpjyO5dDMKm0G3GgnqyOpA0biMgkwGmOKRmALbA0yegqeh(Xa0Y8kO0jD4GtRxiiGR2gv4T6LAX0Pzs4N3OL4t9pI)iD8)CCwVqqaxTnQWB1l1IPtZKWpVrlXN6Fe)r(7Fia1tdqyaK3RLeV6aqqJA5jCxqSEHGGy(g2qsdYRLOiBThdFooeI5Bydj6rAqETG4G1leeOHaynsyQyemOrJ4bdXbG6PbimaT8OcxqJA5jCimeYJJCpcMk7HjkYw7XWNJdXjdH84i3J4Cp4fHlnWD1aJOiBThdFoohNdm0hn6aeN5TADCLrRmqJgJWaI4Wpd5wAJqZjD4GtRxiiiMVHnK0)gTepyooNmSAbLmhIesrmSAbLKG2M4)xxCCmSAbLmhoYfefwYWsSZq(0Qvlpjm6hjdOsYuzpSmALbA0yegqeh(bR6dsBeAoPdhCA9cbbX8nSHK(3OL4bdXbg6JgDaIZ8wToCCoTEHG4Cp4fHljByKBQSPbiPHkODuiXdgcd9rJoaXzERwhxCCozy1ckzoejKIyy1ckjbTnX)VU44yy1ckzoCehN1leemv2dt8GDbrHLmSe7mKpTA1YtcJ(rYaQKmv2dlJwzGgngHbeXHFcpVxAJqZjD4GtRxiiiMVHnK0)gTepyioWqF0OdqCM3Q1HJZP1leeN7bViCjzdJCtLnnajnubTJcjEWqyOpA0bioZB164IJZjdRwqjZHiHuedRwqjjOTj()1fhhdRwqjZHJ44SEHGGPYEyIhSlikSKHLyNH8PvRwEsy0psgqLKPYEyz0kd0OXimGio8JBTQgvsuqs(3qz0kd0OXimGio8JbOvOl6KoCGy(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaooRxiiCRv1OsIcsY)gs8GHy9cbbX8nSHK(3OL4bZX506fccMk7HjkYw7XWVYanAeUlfGvq8KypajbTnbX6fccMk7HjEWUYOvgOrJryarC4h3LcWMrRmqJgJWaI4Wp1BKkd0Or6Bd4KrTPdb17byR3fCb3la]] )


end