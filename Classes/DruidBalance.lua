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


    spec:RegisterPack( "Balance", 20201021, [[dGeeNdqiQGhjqkDjviTjq8jOqkJIk6uujRIkeVsaMLks3IkuAxe(LQkgMQQogu0YeqptfQPbfQRPQsBdkeFJkunovi6CuH06OcfZdvv3tfSpuvoiuivlevHhkqYeHcjIlcfsK(iuijNuGu0kfOMPke2PkIFcfsudfkKWsfifEQGMkuWxHcj1EvP)s0Gv6WKwmL6XOmzO6YiBwOpdsJgkDAPETkQztv3Ms2TIFdz4G64cKQLl55umDGRRkBxv57uPgpQIopQsRxGy(OY(f9fZlgUH4kGUNe4)a)J5)aXuG5r(pWFVHaEHPBiSYoRqPB4Ow0nKhQxhgDdHvE9if)IHBOb9kgDdXcaWghZp)aTbyF2cgY6htB98kOrdR0i4htBX(5gA)ApiO5CTVH4kGUNe4)a)J5)aXuG5r(pqm(iVH6dGfv3WW2kOUHyBCCAU23qCYWUHbT5Yd1RdJYfJsQxJNbh0MlgLzaKnv5g4)tZnW)b(pdodoOn3GcRoqjJJjdoOnxhBUy0XXj8CdrETYLhKAjYGdAZ1XMBqHvhOeEUaTGsazhZLPgYKlaLlJxMNKaTGsaJidoOnxhBUbnil0hHN7BgIrgJw8M7NwTA7jtUoBbjonx4I(KgGwMxbLY1XYxUWf9jmaTmVck5sCd9TbyUy4gIxKAz3dovxmCpbZlgUH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBOZCTFXOa0wKBuns8Iul7EWPsuKL2Jjx(YfkdxyP8m3aY9VaZCHKRZCjMVHnKOhPncGnxoUCjMVHnKOhPb51kxoUCjMVHnKW)gTKdXtqUUYLJlx7xmkaTf5gvJeVi1YUhCQefzP9yYLVCvgOrJWa0k2fjiEsShGKG2IYnGC)lWmxi56mxI5Bydj6r6FJw5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixx56kxoUCDix7xmkaTf5gvJeVi1YUhCQep4B4NwYrTOBOrJKeGKpdjnWK3Fb3tc8IHBinQTNWV84gYQgqvR3qN56qUFA1QTNegnssas(mK0atEFUCC56mx7xmkk9Jg0ZiJfnbHxrrwApMC5pxOmCHLYZCDKCzu7Z1zUQbuQxcJCtvU)K7X)Z1vUqY1(fJIs)Ob9mYyrtq4v8GZ1vUUYLJlx1ak1lHrUPkx(Y1r)FdvgOrZn0a0Y8kO0fCp54lgUH0O2Ec)YJBOYanAUHkUcd6psACRL1nKvnGQwVHoKlociuCfg0FK04wlljUAPqjbOzN7bAUqY1HCvgOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwqUqY1zUoKlociuCfg0FK04wlljws9cqZo3d0C54YfhbekUcd6psACRLLelPErrwApMC5l3FZ1vUCC5IJacfxHb9hjnU1YsIRwkusyak7CU8N7X5cjxCeqO4kmO)iPXTwwsC1sHsIIS0Em5YFUhNlKCXraHIRWG(JKg3AzjXvlfkjan7CpqVHmEzEsc0ckbm3tW8cUNGXxmCdPrT9e(Lh3qLbA0CdTqOj2fDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMbMlKCDMRZCTFXOGPYEyIIS0Em5YxU)MlKCDMR9lgfL(rd6zKXIMGWROilThtU8L7V5YXLRd5A)IrrPF0GEgzSOji8kEW56kxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8N7X)Z1vUqY1zUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRAaL6LWi3uLl)5E8)CDLlKCvyjdlXoNRRBiJxMNKaTGsaZ9emVG7j)EXWnKg12t4xECdvgOrZn08Myx0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zUoZ1(fJcMk7HjkYs7XKlF5(BUqY1zU2Vyuu6hnONrglAccVIIS0Em5YxU)MlhxUoKR9lgfL(rd6zKXIMGWR4bNRRC54Y1HCTFXOGPYEyIhCUCC5QgqPEjmYnv5YFUh)pxx5cjxN56qU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUQbuQxcJCtvU8N7X)Z1vUqYvHLmSe7CUUUHmEzEsc0ckbm3tW8cUNGrUy4gsJA7j8lpUHkd0O5gAaK3RLm61IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YftmsUqY1zUoZ1(fJcMk7HjkYs7XKlF5(BUqY1zU2Vyuu6hnONrglAccVIIS0Em5YxU)MlhxUoKR9lgfL(rd6zKXIMGWR4bNRRC54Y1HCTFXOGPYEyIhCUCC5QgqPEjmYnv5YFUh)pxx5cjxN56qU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUQbuQxcJCtvU8N7X)Z1vUqYvHLmSe7CUUUHmEzEsc0ckbm3tW8cUN44xmCdPrT9e(Lh3qw1aQA9gQWsgwID(gQmqJMByevmsIIYrbVIUG7jh5fd3qAuBpHF5XnKvnGQwVH2VyuWuzpmXd(gQmqJMByPF0GEgzSOji8Eb3tC0lgUH0O2Ec)YJBiRAavTEdDMRZCTFXOGy(g2qsdYRLOilThtU8LlM)ZLJlx7xmkiMVHnK0)gTefzP9yYLVCX8FUUYfsUmeYJJCpcMk7HjkYs7XKlF5E8)CDLlhxUmeYJJCpcMk7HjksX59gQmqJMB45EWlcxAG7QbMl4EcM)Vy4gsJA7j8lpUHSQbu16n0zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUoKld9rJoaXzERwNCDLlhxUm0hn6aetdflqgvkxoUC)0QvBpjAJuruUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaefzP9yYL)Cd8FUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCHKRd5A)IrbtL9Wep4CHKRZC7bqfmYRacxgBOybYIS0Em5YFUmeYJJCpcgA(qNjjaljnWD1aJOilThtUbKRJNlhxU9aOcg5vaHlJnuSazrwApMC5p3admxoUC7bqfmYRacxgBOybYIS0Em5E0CX8i)Nl)5gyG5YXLldH84i3JGHMp0zscWssdCxnWiEW5YXLRd5YqF0OdqmnuSazuPCDDdvgOrZnKrEYaA1lvFdDSObCb3tWeZlgUH0O2Ec)YJBiRAavTEdDMR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRd5YqF0OdqCM3Q1jxx5YXLld9rJoaX0qXcKrLYLJl3pTA12tI2iveLlhxU2Vyuy7riC)Zaep4CHKR9lgf2Eec3)marrwApMC5p3J)NBa56mxmoxhjxgAWFnqaxeRnKu9n0XIgGGg12t456kxi56qU2VyuWuzpmXdoxi56m3EaubJ8kGWLXgkwGSilThtU8NldH84i3JGHMp0zscWssdCxnWikYs7XKBa5645YXLBpaQGrEfq4YydflqwKL2Jjx(Z94aZLJl3EaubJ8kGWLXgkwGSilThtUhnxmpY)5YFUhhyUCC5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUm0hn6aetdflqgvkxx3qLbA0Cd7HP1OGgnxW9emd8IHBinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gYqF0OdqmnuSazuPCHKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3aX4)5cjxN5YqipoY9iyQShMOilThtUbKlM)ZLVC7bqfmYRacxgBOybYIS0Em5YXLldH84i3JGPYEyIIS0Em5gqUh)px(ZThavWiVciCzSHIfilYs7XKlKC7bqfmYRacxgBOybYIS0Em5YxUyE8)C54Y1(fJcMk7HjkYs7XKlF56456kxi5A)IrbX8nSHKgKxlrrwApMC5lxm)NlhxU9aOcg5vaHlJnuSazrwApMCpAUyg4)C5pxm)nxx3WpTKJAr3qgA(qNjjdn4nOrZfCpbZJVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHoZ1HCziKhh5Eemv2dtuKIZBUCC56qUFA1QTNem08HotsgAWBqJMCHKld9rJoaX0qXcKrLY11n8tl5Ow0n0OFKmIkjtL9WUG7jyIXxmCdPrT9e(Lh3qw1aQA9g(PvR2EsWqZh6mjzObVbnAYfsUQbuQxcJCtvU8Nlg))gQmqJMBidnFOZKeGLKg4UAG5cUNG5VxmCdPrT9e(Lh3qw1aQA9gsmFdBirpsD4nxi5QWsgwIDoxi56mxCeqO4kmO)iPXTwwsC1sHscqZo3d0C54Y1HCzOpA0bigIvipQWZ1vUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFfVsuus(3qxW9emXixmCdPrT9e(Lh3qw1aQA9gYqF0OdqmnuSazuPCHK7NwTA7jbdnFOZKKHg8g0Ojxi5QgqPEjmYnv5Y3HCX4)5cjxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jjx(ZfkdxyP8mxhjxg1(CDMRAaL6LWi3uL7p5E8)CDDdvgOrZn0a0Y8kO0fCpbth)IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3WHClTqO5cUNG5rEXWnKg12t4xECdzvdOQ1BOZCTFXOGy(g2qs)B0s8GZfsUoKld9rJoaXzERwNC54Y1zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlKCzOpA0bioZB16KRRC54Y1zUmSAbLm5Ei3aZfsUfXWQfuscAlkx(Z93CDLlhxUmSAbLm5Ei3JZLJlx7xmkyQShM4bNRRCHKRclzyj25CHK7NwTA7jHr)izevsMk7HDdvgOrZneR6JsleAUG7jy6OxmCdPrT9e(Lh3qw1aQA9g6mx7xmkiMVHnK0)gTep4CHKRd5YqF0OdqCM3Q1jxoUCDMR9lgfN7bViCjzbJCtLfnajnubTdcjEW5cjxg6JgDaIZ8wTo56kxoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94C54Y1(fJcMk7HjEW56kxi5QWsgwIDoxi5(PvR2Esy0psgrLKPYEy3qLbA0CdJpVxAHqZfCpjW)xmCdvgOrZn0TwvJkjkkj)BOBinQTNWV84cUNeiMxmCdPrT9e(Lh3qw1aQA9gsmFdBirps)B0kxoUCjMVHnKWG8AjhINGC54YLy(g2qcD4voepb5YXLR9lgfU1QAujrrj5FdjEW5cjx7xmkiMVHnK0)gTep4C54Y1zU2VyuWuzpmrrwApMC5pxLbA0iCxkaRG4jXEascAlkxi5A)IrbtL9Wep4CDDdvgOrZn0a0k2fDb3tcmWlgUHkd0O5g6Uua2BinQTNWV84cUNe4XxmCdPrT9e(Lh3qLbA0CdR3ivgOrJ03gWn03gGCul6ggvVhGTExWfCdHlcwbmSsd4IH7jyEXWnKg12t4xECdvgOrZn0cHMyx0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zU2VyuWuzpmrrwApMC5l3FZLJlxhY1(fJcMk7HjEW5YXLRAaL6LWi3uLl)5E8)CDLlKCvyjdlXoFdz8Y8KeOfucyUNG5fCpjWlgUH0O2Ec)YJBOYanAUHM3e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZaZfsUoZ1(fJcMk7HjkYs7XKlF5(BUCC56qU2VyuWuzpmXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRclzyj25BiJxMNKaTGsaZ9emVG7jhFXWnKg12t4xECdvgOrZn0aiVxlz0RfDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMbMlKCDMR9lgfmv2dtuKL2Jjx(Y93C54Y1HCTFXOGPYEyIhCUCC5QgqPEjmYnv5YFUh)pxx5cjxfwYWsSZ3qgVmpjbAbLaM7jyEb3tW4lgUH0O2Ec)YJBiRAavTEdvyjdlXoFdvgOrZnmIkgjrr5OGxrxW9KFVy4gsJA7j8lpUHSQbu16n0zUQbuQxcJCtvU8LRJ(pxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIIS0Em5YFUbIrY1vUqY1HCTFXOGPYEyIh8nuzGgn3qg5jdOvVu9n0XIgWfCpbJCXWnKg12t4xECdzvdOQ1BOZCvdOuVeg5MQC5lxh9FUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaefzP9yYL)CpgJKRRCHKRd5A)IrbtL9Wep4BOYanAUH9W0AuqJMl4EIJFXWnKg12t4xECdrW3qdbUHkd0O5g(PvR2E6g(P(hDdDixgc5XrUhbtL9WefP48Ed)0soQfDdn6hjJOsYuzpSl4EYrEXWnKg12t4xECdzvdOQ1BiX8nSHe9i1H3CHKRclzyj25CHK7NwTA7jHr)izevsMk7HDdvgOrZnm(kELOOK8VHUG7jo6fd3qAuBpHF5XnKvnGQwVH2VyuyaA5rfUOilThtU8Nlgjxi56mx7xmkiMVHnK0G8AjEW5YXLR9lgfeZ3Wgs6FJwIhCUUYfsUQbuQxcJCtvU8LRJ()gQmqJMBithg5L2Vy8gA)Ir5Ow0n0a0YJk8l4EcM)Vy4gsJA7j8lpUHSQbu16n0zUoKRgeQAajmGI0Z9avAaAzeLoNZLJlx7xmkyQShMOilThtU8NlXtI9aKe0wuUCC56qUWf9jmaTmVckLRRCHKRZCTFXOGPYEyIhCUCC5QgqPEjmYnv5YxUo6)CHKlX8nSHe9i1H3CDDdvgOrZn0a0Y8kO0fCpbtmVy4gsJA7j8lpUHSQbu16n0zUoKRgeQAajmGI0Z9avAaAzeLoNZLJlx7xmkyQShMOilThtU8NlXtI9aKe0wuUCC56qUFA1QTNeWf9jnaTmVckLRRCHKlq90aegGwEuHlOrT9eEUqY1zU2VyuyaA5rfU4bNlhxUQbuQxcJCtvU8LRJ(pxx5cjx7xmkmaT8Ocxyak7CU8N7X5cjxN5A)IrbX8nSHKgKxlXdoxoUCTFXOGy(g2qs)B0s8GZ1vUqYLHqECK7rWuzpmrrwApMC5lxh)gQmqJMBObOL5vqPl4EcMbEXWnKg12t4xECdzvdOQ1BOZCDixniu1asyafPN7bQ0a0YikDoNlhxU2VyuWuzpmrrwApMC5pxINe7bijOTOC54Y1HCHl6tyaAzEfukxx5cjx7xmkiMVHnK0G8AjkYs7XKlF5645cjxI5Bydj6rAqETYfsUoKlq90aegGwEuHlOrT9eEUqYLHqECK7rWuzpmrrwApMC5lxh)gQmqJMBObOL5vqPl4EcMhFXWnKg12t4xECdzvdOQ1BOZCTFXOGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMB4qULwi0Cb3tWeJVy4gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNlhxU2VyuWuzpmXdoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBiw1hLwi0Cb3tW83lgUH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X5YXLR9lgfmv2dt8GZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFEV0cHMl4EcMyKlgUHkd0O5g6wRQrLefLK)n0nKg12t4xECb3tW0XVy4gsJA7j8lpUHSQbu16n0zUAqOQbKWaksp3duPbOLru6Coxi5A)IrbtL9WefzP9yYLVCjEsShGKG2IYfsUWf9jCxkaBUUYLJlxN56qUAqOQbKWaksp3duPbOLru6CoxoUCTFXOGPYEyIIS0Em5YFUepj2dqsqBr5YXLRd5cx0NWa0k2fLRRCHKRZCjMVHnKOhP)nALlhxUeZ3WgsyqETKdXtqUCC5smFdBiHo8khINGC54Y1(fJc3AvnQKOOK8VHep4CHKR9lgfeZ3Wgs6FJwIhCUCC56mx7xmkyQShMOilThtU8NRYanAeUlfGvq8KypajbTfLlKCTFXOGPYEyIhCUUY1vUCC56mxniu1asGRUNEGknVru6Cox(YnWCHKR9lgfeZ3WgsAqETefzP9yYLVC)nxi56qU2VyuGRUNEGknVruKL2Jjx(YvzGgnc3LcWkiEsShGKG2IY11nuzGgn3qdqRyx0fCpbZJ8IHBOYanAUHUlfG9gsJA7j8lpUG7jy6OxmCdPrT9e(Lh3qLbA0CdR3ivgOrJ03gWn03gGCul6ggvVhGTExWfCdXPO(8GlgUNG5fd3qLbA0CdniVwsBsTUH0O2Ec)YJl4EsGxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qdm59sGwqjGryaAfvVpx(YfZCHKRZCDixG6PbimaT8OcxqJA7j8C54YfOEAacdG8ETK4vhbcAuBpHNRRC54Y1atEVeOfucyegGwr17ZLVCd8g(PLCul6g2gPIOl4EYXxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qdm59sGwqjGryaAf7IYLVCX8g(PLCul6g2gjZt6hDb3tW4lgUH0O2Ec)YJBiRAavTEdDMRd5YqF0OdqmnuSazuPC54Y1HCziKhh5Eem08HotsawsAG7QbgXdoxx5cjx7xmkyQShM4bFdvgOrZn0MkdvN7b6fCp53lgUH0O2Ec)YJBiRAavTEdTFXOGPYEyIh8nuzGgn3qyeOrZfCpbJCXWnuzGgn3WNHKnGSm3qAuBpHF5XfCpXXVy4gsJA7j8lpUHSQbu16n8tRwT9KOnsfr3qdOAg4EcM3qLbA0CdR3ivgOrJ03gWn03gGCul6gQi6cUNCKxmCdPrT9e(Lh3qw1aQA9gwVHIOckjaTf5gvJeVi1YUhCQeuq)1WWe(n0aQMbUNG5nuzGgn3W6nsLbA0i9TbCd9Tbih1IUH4fPw29Gt1fCpXrVy4gsJA7j8lpUHSQbu16nSEdfrfusyREDyKefLQ3lby7bQrqb9xddt43qdOAg4EcM3qLbA0CdR3ivgOrJ03gWn03gGCul6gAJuWfCpbZ)xmCdPrT9e(Lh3qw1aQA9g6PpYNlF5(7)BOYanAUH1BKkd0Or6Bd4g6BdqoQfDdnGl4EcMyEXWnKg12t4xECdrW3qdbUHkd0O5g(PvR2E6g(P(hDdHl6t4Uua2B4NwYrTOBiCrFs3LcWEb3tWmWlgUH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBiCrFcdqRyx0n8tl5Ow0neUOpPbOvSl6cUNG5XxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3q4I(egGwMxbLUHFAjh1IUHWf9jnaTmVckDb3tWeJVy4gsJA7j8lpUHkd0O5gwVrQmqJgPVnGBOVna5Ow0neUiyfWWknGl4cUH2ifCXW9emVy4gsJA7j8lpUHSQbu16n0(fJcMk7HjEW3qLbA0Cdl9Jg0ZiJfnbH3l4EsGxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qhY1(fJcB1RdJKOOu9EjaBpqnYrbVIep4CHKRd5A)IrHT61HrsuuQEVeGThOgPwmDiXd(g(PLCul6gYQgmiWd(cUNC8fd3qAuBpHF5XnKvnGQwVHoZ1(fJcB1RdJKOOu9EjaBpqnYrbVIefzP9yYLVCXyXV5YXLR9lgf2QxhgjrrP69sa2EGAKAX0HefzP9yYLVCXyXV56kxi5QgqPEjmYnv5Y3HCD0)5cjxN5YqipoY9iyQShMOilThtU8LRJNlhxUoZLHqECK7rqwWi3ujTrdUOilThtU8LRJNlKCDix7xmko3dEr4sYcg5MklAasAOcAhes8GZfsUm0hn6aeN5TADY1vUUUHkd0O5gY0HrEP9lgVH2VyuoQfDdnaT8Oc)cUNGXxmCdPrT9e(Lh3qw1aQA9g6qUFA1QTNeSQbdc8GZfsUoZ1zUoKldH84i3JGHMp0zscWssdCxnWiEW5YXLRd5(PvR2EsWqZh6mjzObVbnAYLJlxhYLH(OrhGyAOybYOs56kxi56mxg6JgDaIPHIfiJkLlhxUoZLHqECK7rWuzpmrrwApMC5lxhpxoUCDMldH84i3JGSGrUPsAJgCrrwApMC5lxhpxi56qU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlKCzOpA0bioZB16KRRCDLRRCDLlhxUoZLHqECK7rWqZh6mjbyjPbURgyep4CHKldH84i3JGPYEyIIuCEZfsUm0hn6aetdflqgvkxx3qLbA0CdnaTmVckDb3t(9IHBinQTNWV84gQmqJMBOIRWG(JKg3AzDdzvdOQ1BOd5IJacfxHb9hjnU1YsIRwkusaA25EGMlKCDixLbA0iuCfg0FK04wlljUAPqjrpYOVHIfKlKCDMRd5IJacfxHb9hjnU1YsILuVa0SZ9anxoUCXraHIRWG(JKg3AzjXsQxuKL2Jjx(Y93CDLlhxU4iGqXvyq)rsJBTSK4QLcLegGYoNl)5ECUqYfhbekUcd6psACRLLexTuOKOilThtU8N7X5cjxCeqO4kmO)iPXTwwsC1sHscqZo3d0BiJxMNKaTGsaZ9emVG7jyKlgUH0O2Ec)YJBOYanAUHM3e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YftmsUqYvHLmSe7CUqY1zUFA1QTNeSQbdc8GZLJlxN5QgqPEjmYnv5YFUh)pxi56qU2VyuWuzpmXdoxx5YXLldH84i3JGPYEyIIuCEZ11nKXlZtsGwqjG5EcMxW9eh)IHBinQTNWV84gQmqJMBOfcnXUOBiRAavTEdlkwKbRA7PCHKlqlOeqaAlscqs8MYLVCX8yXV5cjxfwYWsSZ5cjxN5(PvR2EsWQgmiWdoxoUCDMRAaL6LWi3uLl)5E8)CHKRd5A)IrbtL9Wep4CDLlhxUmeYJJCpcMk7HjksX5nxx5cjxhY1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4BiJxMNKaTGsaZ9emVG7jh5fd3qAuBpHF5XnuzGgn3qdG8ETKrVw0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUyIrYnGClYs7XKlKCvyjdlXoNlKCDM7NwTA7jbRAWGap4C54YvnGs9syKBQYL)Cp(FUCC5YqipoY9iyQShMOifN3CDDdz8Y8KeOfucyUNG5fCpXrVy4gsJA7j8lpUHSQbu16nuHLmSe78nuzGgn3WiQyKefLJcEfDb3tW8)fd3qAuBpHF5XnKvnGQwVHoZLy(g2qIEK6WBUCC5smFdBiHb51s2JeZC54YLy(g2qc)B0s2JeZCDLlKCDMRd5YqF0OdqmnuSazuPC54Y1zUQbuQxcJCtvU8NRJ(BUqY1zUFA1QTNeSQbdc8GZLJlx1ak1lHrUPkx(Z94)5YXL7NwTA7jrBKkIY1vUqY1zUFA1QTNem08HotsCYW7WYfsUoKldH84i3JGHMp0zscWssdCxnWiEW5YXLRd5(PvR2EsWqZh6mjXjdVdlxi56qUmeYJJCpcMk7HjEW56kxx56kxi56mxgc5XrUhbtL9WefzP9yYLVCp(FUCC5QgqPEjmYnv5YxUo6)CHKldH84i3JGPYEyIhCUqY1zUmeYJJCpcYcg5MkPnAWffzP9yYL)CvgOrJWa0k2fjiEsShGKG2IYLJlxhYLH(OrhG4mVvRtUUYLJl3ydflqwKL2Jjx(ZfZ)56kxi56mxCeqO4kmO)iPXTwwsC1sHsIIS0Em5YxUyCUCC56qUm0hn6aedXkKhv4566gQmqJMBy8v8krrj5FdDb3tWeZlgUH0O2Ec)YJBiRAavTEdDMlX8nSHe(3OLCiEcYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUCC5A)IrHT61HrsuuQEVeGThOg5OGxrIIS0Em5YxUyS43C54Y1(fJcB1RdJKOOu9EjaBpqnsTy6qIIS0Em5YxUyS43C54YvnGs9syKBQYLVCD0)5cjxgc5XrUhbtL9WefP48MRRCHKRZCziKhh5Eemv2dtuKL2Jjx(Y94)5YXLldH84i3JGPYEyIIuCEZ1vUCC5gBOybYIS0Em5YFUy()gQmqJMB45EWlcxAG7QbMl4EcMbEXWnKg12t4xECdzvdOQ1BOZCvdOuVeg5MQC5lxh9FUqY1zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUoKld9rJoaXzERwNCDLlhxUm0hn6aetdflqgvkxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIIS0Em5YFUb(p3aY1zUyCUosUm0G)AGaUiwBiP6BOJfnabnQTNWZ1vUUYfsUoZ1HCzOpA0biMgkwGmQuUCC5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC5gBOybYIS0Em5YFUmeYJJCpcgA(qNjjaljnWD1aJOilThtUbKlgjxoUCJnuSazrwApMCpAUyEK)ZL)Cd8FUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDDdvgOrZnKrEYaA1lvFdDSObCb3tW84lgUH0O2Ec)YJBiRAavTEdDMRAaL6LWi3uLlF56O)ZfsUoZ1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4C54Y1HCzOpA0bioZB16KRRC54YLH(OrhGyAOybYOs5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdquKL2Jjx(Z94)5gqUoZfJZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY1vUqY1zUoKld9rJoaX0qXcKrLYLJlxgc5XrUhbdnFOZKeGLKg4UAGr8GZLJl3pTA12tcgA(qNjjoz4Dy5cj3ydflqwKL2Jjx(YfZJ8FUbKBG)ZnGCDMlgNRJKldn4VgiGlI1gsQ(g6yrdqqJA7j8CDLlhxUXgkwGSilThtU8NldH84i3JGHMp0zscWssdCxnWikYs7XKBa5IrYLJl3ydflqwKL2Jjx(Z94)5gqUoZfJZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY11nuzGgn3WEyAnkOrZfCpbtm(IHBinQTNWV84gYQgqvR3qN5(PvR2EsWqZh6mjXjdVdlxi5gBOybYIS0Em5YxUyE8)C54Y1(fJcMk7HjEW56kxi56mx7xmkSvVomsIIs17LaS9a1ihf8ksyak7S8t9pkx(Y94)5YXLR9lgf2QxhgjrrP69sa2EGAKAX0HegGYol)u)JYLVCp(FUUYLJl3ydflqwKL2Jjx(ZfZ)3qLbA0CdzO5dDMKaSK0a3vdmxW9em)9IHBinQTNWV84gYQgqvR3qg6JgDaIPHIfiJkLlKCDM7NwTA7jbdnFOZKeNm8oSC54YLHqECK7rWuzpmrrwApMC5pxm)NRRCHKRAaL6LWi3uLlF5(7)CHKldH84i3JGHMp0zscWssdCxnWikYs7XKl)5I5)BOYanAUHgGwMxbLUG7jyIrUy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHeZ3Wgs0J0)gTY1rY9iZ9NCvgOrJWa0k2fjiEsShGKG2IYnGCDixI5Bydj6r6FJw56i5IrY9NCvgOrJWDPaScINe7bijOTOCdi3)IaZ9NCnWK3lXQgaDd)0soQfDdvdmgfufsSl4EcMo(fd3qAuBpHF5XnKvnGQwVHoZThavWiVciCzSHIfilYs7XKl)5IX5YXLRZCTFXOO0pAqpJmw0eeEffzP9yYL)CHYWfwkpZ1rYLrTpxN5QgqPEjmYnv5(tUh)pxx5cjx7xmkk9Jg0ZiJfnbHxXdoxx56kxoUCDMRAaL6LWi3uLBa5(PvR2EsOgymkOkKy56i5A)IrbX8nSHKgKxlrrwApMCdixCeqeFfVsuus(3qcqZoBKfzP9KRJKBGIFZLVCXmW)5YXLRAaL6LWi3uLBa5(PvR2EsOgymkOkKy56i5A)IrbX8nSHK(3OLOilThtUbKlociIVIxjkkj)BibOzNnYIS0EY1rYnqXV5YxUyg4)CDLlKCjMVHnKOhPo8MlKCDMRZCDixgc5XrUhbtL9Wep4C54YLH(OrhG4mVvRtUqY1HCziKhh5EeKfmYnvsB0GlEW56kxoUCzOpA0biMgkwGmQuUUYfsUoZ1HCzOpA0bi(ObGL3kxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8LRJ(pxx5YXLR9lgfmv2dtuKL2Jjx(Y9iZfsUoKR9lgfL(rd6zKXIMGWR4bFdvgOrZn0a0Y8kO0fCpbZJ8IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5goKBPfcnxW9emD0lgUH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X56kxi5QWsgwID(gQmqJMBiw1hLwi0Cb3tc8)fd3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94CDLlKCvyjdlXoFdvgOrZnm(8EPfcnxW9KaX8IHBOYanAUHU1QAujrrj5FdDdPrT9e(LhxW9Kad8IHBinQTNWV84gYQgqvR3qI5Bydj6r6FJw5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixoUCTFXOWTwvJkjkkj)BiXdoxi5smFdBirps)B0kxoUCDMR9lgfmv2dtuKL2Jjx(ZvzGgnc3LcWkiEsShGKG2IYfsU2VyuWuzpmXdoxx3qLbA0CdnaTIDrxW9Kap(IHBOYanAUHUlfG9gsJA7j8lpUG7jbIXxmCdPrT9e(Lh3qLbA0CdR3ivgOrJ03gWn03gGCul6ggvVhGTExWfCdveDXW9emVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHoZ1(fJcqBrUr1iXlsTS7bNkrrwApMC5pxOmCHLYZCdi3)cmZLJlx7xmkaTf5gvJeVi1YUhCQefzP9yYL)CvgOrJWa0k2fjiEsShGKG2IYnGC)lWmxi56mxI5Bydj6r6FJw5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixx56kxi5A)IrbOTi3OAK4fPw29GtL4bNlKCR3qrubLeG2ICJQrIxKAz3dovckO)Ayyc)g(PLCul6gIxKAjD3EVmQEVefJxW9KaVy4gsJA7j8lpUHSQbu16n0(fJcdqRO69IIIfzWQ2Ekxi56mxdm59sGwqjGryaAfvVpx(Z94C54Y1HCR3qrubLeG2ICJQrIxKAz3dovckO)Ayycpxx5cjxN56qU1BOiQGscpVmTuJm6jc0dujuFBbBibf0FnmmHNlhxUG2IY9O5IX)MlF5A)IrHbOvu9ErrwApMCdi3aZ11nuzGgn3qdqRO69xW9KJVy4gsJA7j8lpUHSQbu16nSEdfrfusaAlYnQgjErQLDp4ujOG(RHHj8CHKRbM8EjqlOeWimaTIQ3NlFhY94CHKRZCDix7xmkaTf5gvJeVi1YUhCQep4CHKR9lgfgGwr17ffflYGvT9uUCC56m3pTA12tc8IulP727Lr17LOymxi56mx7xmkmaTIQ3lkYs7XKl)5ECUCC5AGjVxc0ckbmcdqRO695YxUbMlKCbQNgGWaiVxljE1rGGg12t45cjx7xmkmaTIQ3lkYs7XKl)5(BUUY1vUUUHkd0O5gAaAfvV)cUNGXxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3q1ak1lHrUPkx(Y9i)NRJnxN5I5)CDKCTFXOa0wKBuns8Iul7EWPsyak7CUUY1XMRZCTFXOWa0kQEVOilThtUosUhN7p5AGjVxIvnakxx56yZ1zU4iGi(kELOOK8VHefzP9yY1rY93CDLlKCTFXOWa0kQEV4bFd)0soQfDdnaTIQ3lDJgGmQEVefJxW9KFVy4gsJA7j8lpUHSQbu16n8tRwT9KaVi1s6U9Ezu9EjkgZfsUFA1QTNegGwr17LUrdqgvVxIIXBOYanAUHgGwMxbLUG7jyKlgUH0O2Ec)YJBOYanAUHM3e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YftmoxhBUgyY7LaTGsatUbKBrwApMCHKRclzyj25CHKlX8nSHe9i1H3BiJxMNKaTGsaZ9emVG7jo(fd3qAuBpHF5XnuzGgn3qfxHb9hjnU1Y6gYQgqvR3qhYf0SZ9anxi56qUkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflixoUCXraHIRWG(JKg3AzjXvlfkjmaLDox(Z94CHKlociuCfg0FK04wlljUAPqjrrwApMC5p3JVHmEzEsc0ckbm3tW8cUNCKxmCdPrT9e(Lh3qLbA0CdTqOj2fDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LRZCXeJZnGCDMRbM8EjqlOeWimaTIDr56i5IP43CDLRRC)jxdm59sGwqjGj3aYTilThtUqY1zUoZLHqECK7rWuzpmrrkoV5YXLRbM8EjqlOeWimaTIDr5YFUhNlhxUoZLy(g2qIEKgKxRC54YLy(g2qIEK2ia2C54YLy(g2qIEK(3OvUqY1HCbQNgGWGEEjkkbyjzevKbiOrT9eEUCC5A)IrbC1wOcVvVulMontc)8gTeFQ)r5Y3HCd83)56kxi56mxdm59sGwqjGryaAf7IYL)CX8FUosUoZfZCdixG6PbiaU7rAHqJrqJA7j8CDLRRCHKRAaL6LWi3uLlF5(7)CDS5A)IrHbOvu9ErrwApMCDKCXi56kxi56qU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlKCvyjdlXoNRRBiJxMNKaTGsaZ9emVG7jo6fd3qAuBpHF5XnKvnGQwVHkSKHLyNVHkd0O5ggrfJKOOCuWROl4EcM)Vy4gsJA7j8lpUHSQbu16n0(fJcMk7HjEW3qLbA0Cdl9Jg0ZiJfnbH3l4EcMyEXWnKg12t4xECdzvdOQ1BOZCTFXOWa0kQEV4bNlhxUQbuQxcJCtvU8L7V)Z1vUqY1HCTFXOWG8gqZiXdoxi56qU2VyuWuzpmXdoxi56m3EaubJ8kGWLXgkwGSilThtU8NldH84i3JGHMp0zscWssdCxnWikYs7XKBa5645YXLBpaQGrEfq4YydflqwKL2Jj3JMlMh5)C5p3admxoUCziKhh5Eem08HotsawsAG7QbgXdoxoUCDixg6JgDaIPHIfiJkLRRBOYanAUHmYtgqREP6BOJfnGl4EcMbEXWnKg12t4xECdzvdOQ1BySHIfilYs7XKl)5I5V5YXLRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3a)9FUCC5A)IrbC1wOcVvVulMontc)8gTeFQ)r5Y3HCd83)56kxi5A)IrHbOvu9EXdoxi5YqipoY9iyQShMOilThtU8L7V)VHkd0O5g2dtRrbnAUG7jyE8fd3qAuBpHF5XnuzGgn3qdG8ETKrVw0nKvnGQwVHfflYGvT9uUqYf0wKeGK4nLlF5I5V5cjxdm59sGwqjGryaAf7IYL)CX4CHKRclzyj25CHKRZCTFXOGPYEyIIS0Em5YxUy(pxoUCDix7xmkyQShM4bNRRBiJxMNKaTGsaZ9emVG7jyIXxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3q7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(ZnWF)NRJnx1ak1lHrUPkxi56mxgc5XrUhbtL9WefzP9yYnGCX8FU8LBSHIfilYs7XKlhxUmeYJJCpcMk7HjkYs7XKBa5E8)C5p3ydflqwKL2Jjxi5gBOybYIS0Em5YxUyE8)C54Y1(fJcMk7HjkYs7XKlF56456kxi5smFdBirpsD4nxoUCJnuSazrwApMCpAUyg4)C5pxm)9g(PLCul6gYqZh6mjzObVbnAUG7jy(7fd3qAuBpHF5XnKvnGQwVHFA1QTNem08HotsgAWBqJMCHKRAaL6LWi3uLl)5(7)BOYanAUHm08HotsawsAG7QbMl4EcMyKlgUH0O2Ec)YJBiRAavTEdjMVHnKOhPo8MlKCvyjdlXoNlKCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3a)9FUqY1zU4iGqXvyq)rsJBTSK4QLcLeGMDUhO5YXLRd5YqF0OdqmeRqEuHNlhxUgyY7LaTGsatU8LBG566gQmqJMBy8v8krrj5FdDb3tW0XVy4gsJA7j8lpUHSQbu16n0(fJc0qaSgjmvmcg0Or8GZfsUoZ1(fJcdqRO69IIIfzWQ2EkxoUCvdOuVeg5MQC5lxh9FUUUHkd0O5gAaAfvV)cUNG5rEXWnKg12t4xECdzvdOQ1Bid9rJoaX0qXcKrLYfsUFA1QTNem08HotsgAWBqJMCHKldH84i3JGHMp0zscWssdCxnWikYs7XKl)5cLHlSuEMRJKlJAFUoZvnGs9syKBQY9NC)9FUUYfsU2VyuyaAfvVxuuSidw12t3qLbA0CdnaTIQ3Fb3tW0rVy4gsJA7j8lpUHSQbu16nKH(OrhGyAOybYOs5cj3pTA12tcgA(qNjjdn4nOrtUqYLHqECK7rWqZh6mjbyjPbURgyefzP9yYL)CHYWfwkpZ1rYLrTpxN5QgqPEjmYnv5(tUh)pxx5cjx7xmkmaTIQ3lEW3qLbA0CdnaTmVckDb3tc8)fd3qAuBpHF5XnKvnGQwVH2VyuGgcG1izEsl5xBA0iEW5YXLRd5AaAf7IekSKHLyNZLJlxN5A)IrbtL9WefzP9yYL)C)nxi5A)IrbtL9Wep4C54Y1zU2Vyuu6hnONrglAccVIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3J)NRRCHKR9lgfL(rd6zKXIMGWR4bNRRCDLlKC)0QvBpjmaTIQ3lDJgGmQEVefJ5cjxdm59sGwqjGryaAfvVpx(Z94BOYanAUHgGwMxbLUG7jbI5fd3qAuBpHF5XnKvnGQwVHoZLy(g2qIEK6WBUqYLHqECK7rWuzpmrrwApMC5l3F)NlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5goKBPfcnxW9Kad8IHBinQTNWV84gYQgqvR3qN5smFdBirpsD4nxi5YqipoY9iyQShMOilThtU8L7V)ZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxx5cjxfwYWsSZ3qLbA0CdXQ(O0cHMl4EsGhFXWnKg12t4xECdzvdOQ1BOZCjMVHnKOhPo8MlKCziKhh5Eemv2dtuKL2Jjx(Y93)5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNRRCHKRclzyj25BOYanAUHXN3lTqO5cUNeigFXWnuzGgn3q3AvnQKOOK8VHUH0O2Ec)YJl4EsG)EXWnKg12t4xECdrW3qdbUHkd0O5g(PvR2E6g(P(hDdnWK3lbAbLagHbOvSlkx(Y9iZnGCJEeQY1zUwQbqfVYp1)OC)j3a)NRRCdi3OhHQCDMR9lgfgGwMxbLKKfmYnvw0aegGYoN7p5IX566g(PLCul6gAaAf7IK9iniVwxW9KaXixmCdPrT9e(Lh3qw1aQA9gsmFdBiH)nAjhINGC54YLy(g2qcD4voepb5cj3pTA12tI2izEs)OC54YLy(g2qIEKgKxRCHKRd5(PvR2EsyaAf7IK9iniVw5YXLR9lgfmv2dtuKL2Jjx(ZvzGgncdqRyxKG4jXEascAlkxi56qUFA1QTNeTrY8K(r5cjx7xmkyQShMOilThtU8NlXtI9aKe0wuUqY1(fJcMk7HjEW5YXLR9lgfL(rd6zKXIMGWR4bNlKCnWK3lXQgaLlF5(xGrYLJlxhY9tRwT9KOnsMN0pkxi5A)IrbtL9WefzP9yYLVCjEsShGKG2IUHkd0O5g6Uua2l4EsGo(fd3qLbA0CdnaTIDr3qAuBpHF5XfCpjWJ8IHBinQTNWV84gQmqJMBy9gPYanAK(2aUH(2aKJAr3WO69aS17cUGByu9Ea26DXW9emVy4gsJA7j8lpUHSQbu16n0HCR3qrubLe2QxhgjrrP69sa2EGAeuq)1WWe(nuzGgn3qdqlZRGsxW9KaVy4gsJA7j8lpUHkd0O5gAEtSl6gYQgqvR3qCeqyHqtSlsuKL2Jjx(YTilThZnKXlZtsGwqjG5EcMxW9KJVy4gQmqJMBOfcnXUOBinQTNWV84cUGBObCXW9emVy4gsJA7j8lpUHkd0O5gQ4kmO)iPXTww3qw1aQA9g6qU4iGqXvyq)rsJBTSK4QLcLeGMDUhO5cjxhYvzGgncfxHb9hjnU1YsIRwkus0Jm6BOyb5cjxN56qU4iGqXvyq)rsJBTSKyj1lan7CpqZLJlxCeqO4kmO)iPXTwwsSK6ffzP9yYLVC)nxx5YXLlociuCfg0FK04wlljUAPqjHbOSZ5YFUhNlKCXraHIRWG(JKg3AzjXvlfkjkYs7XKl)5ECUqYfhbekUcd6psACRLLexTuOKa0SZ9a9gY4L5jjqlOeWCpbZl4EsGxmCdPrT9e(Lh3qLbA0CdTqOj2fDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMbMlKCDMR9lgfmv2dtuKL2Jjx(Y93CHKRZCTFXOO0pAqpJmw0eeEffzP9yYLVC)nxoUCDix7xmkk9Jg0ZiJfnbHxXdoxx5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)Cp(FUUYfsUoZ1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRclzyj25BiJxMNKaTGsaZ9emVG7jhFXWnKg12t4xECdvgOrZn08Myx0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zU2VyuWuzpmrrwApMC5l3FZfsUoZ1(fJIs)Ob9mYyrtq4vuKL2Jjx(Y93C54Y1HCTFXOO0pAqpJmw0eeEfp4CDLlhxUoKR9lgfmv2dt8GZLJlx1ak1lHrUPkx(Z94)56kxi56mxhY1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4C54YvnGs9syKBQYL)Cp(FUUYfsUkSKHLyNVHmEzEsc0ckbm3tW8cUNGXxmCdPrT9e(Lh3qLbA0CdnaY71sg9Ar3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5Ijgjxi56mx7xmkyQShMOilThtU8L7V5cjxN5A)IrrPF0GEgzSOji8kkYs7XKlF5(BUCC56qU2Vyuu6hnONrglAccVIhCUUYLJlxhY1(fJcMk7HjEW5YXLRAaL6LWi3uLl)5E8)CDLlKCDMRd5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUCC5QgqPEjmYnv5YFUh)pxx5cjxfwYWsSZ3qgVmpjbAbLaM7jyEb3t(9IHBinQTNWV84gYQgqvR3qfwYWsSZ3qLbA0CdJOIrsuuok4v0fCpbJCXWnKg12t4xECdzvdOQ1BO9lgfmv2dt8GVHkd0O5gw6hnONrglAccVxW9eh)IHBinQTNWV84gYQgqvR3qN56mx7xmkiMVHnK0G8AjkYs7XKlF5I5)C54Y1(fJcI5Bydj9VrlrrwApMC5lxm)NRRCHKldH84i3JGPYEyIIS0Em5YxUh)pxi56mx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(Znqm(FUCC56qU1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHj8CDLRRC54Y1(fJc4QTqfEREPwmDAMe(5nAj(u)JYLVd5gOJ)pxoUCziKhh5Eemv2dtuKIZBUqY1zUQbuQxcJCtvU8LRJ(pxoUC)0QvBpjAJuruUUUHkd0O5gEUh8IWLg4UAG5cUNCKxmCdPrT9e(Lh3qw1aQA9g6mx1ak1lHrUPkx(Y1r)NlKCDMR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRd5YqF0OdqCM3Q1jxx5YXLld9rJoaX0qXcKrLYLJl3pTA12tI2iveLlhxU2Vyuy7riC)Zaep4CHKR9lgf2Eec3)marrwApMC5p3a)NBa56mxN56O56i5wVHIOckjGR2cv4T6LAX0Pzs4N3OLGc6VggMWZ1vUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDLRRCHKRd5A)IrbtL9Wep4CHKRZCJnuSazrwApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jj3aY1XZLJl3ydflqwKL2Jjx(ZnWaZnGCDMRJMRJKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5lxm))pxx56kxoUCJnuSazrwApMCpAUyEK)ZL)CdmWC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y1HCzOpA0biMgkwGmQuUUUHkd0O5gYipzaT6LQVHow0aUG7jo6fd3qAuBpHF5XnKvnGQwVHoZvnGs9syKBQYLVCD0)5cjxN5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUCC56qUm0hn6aeN5TADY1vUCC5YqF0OdqmnuSazuPC54Y9tRwT9KOnsfr5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdquKL2Jjx(Z94)5gqUoZ1zUoAUosU1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHj8CDLBa56mxmoxhjxgAWFnqaxeRnKu9n0XIgGGg12t456kxx56kxi56qU2VyuWuzpmXdoxi56m3ydflqwKL2Jjx(ZLHqECK7rWqZh6mjbyjPbURgyefzP9yYnGCD8C54Yn2qXcKfzP9yYL)CpoWCdixN56O56i56mx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(YfZ))Z1vUUYLJl3ydflqwKL2Jj3JMlMh5)C5p3JdmxoUCziKhh5Eem08HotsawsAG7QbgXdoxoUCDixg6JgDaIPHIfiJkLRRBOYanAUH9W0AuqJMl4EcM)Vy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHm0hn6aetdflqgvkxi56mx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(Znqm(FUqY1zUmeYJJCpcMk7HjkYs7XKBa5I5)C5l3ydflqwKL2JjxoUCziKhh5Eemv2dtuKL2Jj3aY94)5YFUXgkwGSilThtUqYn2qXcKfzP9yYLVCX84)5YXLR9lgfmv2dtuKL2Jjx(Y1XZ1vUqY1(fJcI5BydjniVwIIS0Em5YxUy(pxoUCJnuSazrwApMCpAUyg4)C5pxm)nxx3WpTKJAr3qgA(qNjjdn4nOrZfCpbtmVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHoZ1HCziKhh5Eemv2dtuKIZBUCC56qUFA1QTNem08HotsgAWBqJMCHKld9rJoaX0qXcKrLY11n8tl5Ow0n0OFKmIkjtL9WUG7jyg4fd3qAuBpHF5XnKvnGQwVHFA1QTNem08HotsgAWBqJMCHKRAaL6LWi3uLl)5E8)BOYanAUHm08HotsawsAG7QbMl4EcMhFXWnKg12t4xECdzvdOQ1BiX8nSHe9i1H3CHKRclzyj25CHKR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLl)5gig)pxi56mxCeqO4kmO)iPXTwwsC1sHscqZo3d0C54Y1HCzOpA0bigIvipQWZ1vUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFfVsuus(3qxW9emX4lgUH0O2Ec)YJBiRAavTEdTFXOaneaRrctfJGbnAep4CHKR9lgfgGwr17ffflYGvT90nuzGgn3qdqRO69xW9em)9IHBinQTNWV84gYQgqvR3q7xmkmaT8OcxuKL2Jjx(Z93CHKRZCTFXOGy(g2qsdYRLOilThtU8L7V5YXLR9lgfeZ3Wgs6FJwIIS0Em5YxU)MRRCHKRAaL6LWi3uLlF56O)VHkd0O5gY0HrEP9lgVH2VyuoQfDdnaT8Oc)cUNGjg5IHBinQTNWV84gYQgqvR3qg6JgDaIPHIfiJkLlKC)0QvBpjyO5dDMKm0G3Ggn5cjxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jjx(ZfkdxyP8mxhjxg1(CDMRAaL6LWi3uL7p5E8)CDDdvgOrZn0a0Y8kO0fCpbth)IHBinQTNWV84gYQgqvR3qG6PbimaY71sIxDeiOrT9eEUqY1HCbQNgGWa0YJkCbnQTNWZfsU2VyuyaAfvVxuuSidw12t5cjxN5A)IrbX8nSHK(3OLOilThtU8Llgjxi5smFdBirps)B0kxi5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb(7)C54Y1(fJc4QTqfEREPwmDAMe(5nAj(u)JYLVd5g4V)ZfsUQbuQxcJCtvU8LRJ(pxoUCXraHIRWG(JKg3AzjXvlfkjkYs7XKlF5EK5YXLRYanAekUcd6psACRLLexTuOKOhz03qXcY1vUqY1HCziKhh5Eemv2dtuKIZ7nuzGgn3qdqRO69xW9empYlgUH0O2Ec)YJBiRAavTEdTFXOaneaRrY8KwYV20Or8GZLJlx7xmko3dEr4sYcg5MklAasAOcAhes8GZLJlx7xmkyQShM4bNlKCDMR9lgfL(rd6zKXIMGWROilThtU8NlugUWs5zUosUmQ956mx1ak1lHrUPk3FY94)56kxi5A)IrrPF0GEgzSOji8kEW5YXLRd5A)IrrPF0GEgzSOji8kEW5cjxhYLHqECK7ru6hnONrglAccVIIuCEZLJlxhYLH(OrhG4JgawERCDLlhxUQbuQxcJCtvU8LRJ(pxi5smFdBirpsD49gQmqJMBObOL5vqPl4EcMo6fd3qAuBpHF5XnKvnGQwVHa1tdqyaA5rfUGg12t45cjxN5A)IrHbOLhv4IhCUCC5QgqPEjmYnv5YxUo6)CDLlKCTFXOWa0YJkCHbOSZ5YFUhNlKCDMR9lgfeZ3WgsAqETep4C54Y1(fJcI5Bydj9VrlXdoxx5cjx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(Znqh)FUqY1zUmeYJJCpcMk7HjkYs7XKlF5I5)C54Y1HC)0QvBpjyO5dDMKm0G3Ggn5cjxg6JgDaIPHIfiJkLRRBOYanAUHgGwMxbLUG7jb()IHBinQTNWV84gYQgqvR3qN5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb64)ZLJlx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(ZnWF)NlKCbQNgGWaiVxljE1rGGg12t456kxi5A)IrbX8nSHKgKxlrrwApMC5lxhpxi5smFdBirpsdYRvUqY1HCTFXOaneaRrctfJGbnAep4CHKRd5cupnaHbOLhv4cAuBpHNlKCziKhh5Eemv2dtuKL2Jjx(Y1XZfsUoZLHqECK7rCUh8IWLg4UAGruKL2Jjx(Y1XZLJlxhYLH(OrhG4mVvRtUUUHkd0O5gAaAzEfu6cUNeiMxmCdPrT9e(Lh3qw1aQA9g6mx7xmkiMVHnK0)gTep4C54Y1zUmSAbLm5Ei3aZfsUfXWQfuscAlkx(Z93CDLlhxUmSAbLm5Ei3JZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5goKBPfcnxW9Kad8IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlKCDixg6JgDaIZ8wTo5YXLRZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxi5YqF0OdqCM3Q1jxx5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNlhxU2VyuWuzpmXdoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBiw1hLwi0Cb3tc84lgUH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUqY1HCzOpA0bioZB16KlhxUoZ1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4CHKld9rJoaXzERwNCDLlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUCC5A)IrbtL9Wep4CDLlKCvyjdlXoNlKC)0QvBpjm6hjJOsYuzpSBOYanAUHXN3lTqO5cUNeigFXWnuzGgn3q3AvnQKOOK8VHUH0O2Ec)YJl4EsG)EXWnKg12t4xECdzvdOQ1BiX8nSHe9i9VrRC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKlhxU2Vyu4wRQrLefLK)nK4bNlKCTFXOGy(g2qs)B0s8GZLJlxN5A)IrbtL9WefzP9yYL)CvgOrJWDPaScINe7bijOTOCHKR9lgfmv2dt8GZ11nuzGgn3qdqRyx0fCpjqmYfd3qLbA0CdDxka7nKg12t4xECb3tc0XVy4gsJA7j8lpUHkd0O5gwVrQmqJgPVnGBOVna5Ow0nmQEpaB9UGl4gcxedzzRGlgUNG5fd3qLbA0CdTqO5CpYiQSUH0O2Ec)YJl4EsGxmCdvgOrZn0DPaS3qAuBpHF5XfCp54lgUHkd0O5g6Uua2BinQTNWV84cUNGXxmCdvgOrZn0a0k2fDdPrT9e(LhxW9KFVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUH2iJjxi5g9iuLRZCDMBSHIfilYs7XKRJn3a)NRRC)jxmd8FUUYLVCJEeQY1zUoZn2qXcKfzP9yY1XMBG)MRJnxN5I5)CDKCbQNgGOhMwJcA0iOrT9eEUUY1XMRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDL7p5I5r(pxx3WpTKJAr3qgA(qNjjoz4DyxWfCb3WpQmnAUNe4)a)J5)a)lW8g6wRPhOMBig1y0dACsqZtWOYXKBUyalLBBbJkqUruLlgn8Iul7EWPcJwUff0FDr45AqwuU6dGSuaHNldRoqjJid(i6HYnqhtUbfA(Ocq45g2wbvUgEhGYZCpAUauUhXtZfV)AtJMCrWuPauLRZFCLRtm5Plrg8r0dLlM)Dm5guO5JkaHNByBfu5A4DakpZ9Ohnxak3J4P5AHWF(Njxemvkav568OUY1jM80Lid(i6HYftmDm5guO5JkaHNByBfu5A4DakpZ9Ohnxak3J4P5AHWF(Njxemvkav568OUY1jM80Lid(i6HYfZaDm5guO5JkaHNByBfu5A4DakpZ9Ohnxak3J4P5AHWF(Njxemvkav568OUY1jM80Lid(i6HYftmIJj3GcnFubi8CdBRGkxdVdq5zUhnxak3J4P5I3FTPrtUiyQuaQY15pUY1jM80LidodgJAm6bnojO5jyu5yYnxmGLYTTGrfi3iQYfJgCrmKLTcWOLBrb9xxeEUgKfLR(ailfq45YWQduYiYGpIEOC)1XKBqHMpQaeEUHTvqLRH3bO8m3JMlaL7r80CX7V20Ojxemvkav568hx56mqE6sKbNbJrng9GgNe08emQCm5MlgWs52wWOcKBev5IrtregTClkO)6IWZ1GSOC1hazPacpxgwDGsgrg8r0dLBGoMCdk08rfGWZnSTcQCn8oaLN5E0JMlaL7r80CTq4p)ZKlcMkfGQCDEux56etE6sKbFe9q5IXoMCdk08rfGWZnSTcQCn8oaLN5E0CbOCpINMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JOhk3J0XKBqHMpQaeEUHTvqLRH3bO8m3JMlaL7r80CX7V20Ojxemvkav568hx56etE6sKbFe9q5IjMoMCdk08rfGWZnSTcQCn8oaLN5E0JMlaL7r80CTq4p)ZKlcMkfGQCDEux56etE6sKbFe9q5IzGoMCdk08rfGWZnSTcQCn8oaLN5E0JMlaL7r80CTq4p)ZKlcMkfGQCDEux56etE6sKbFe9q5Ijg7yYnOqZhvacp3W2kOY1W7auEM7rpAUauUhXtZ1cH)8ptUiyQuaQY15rDLRtm5Plrg8r0dLlMhPJj3GcnFubi8CdBRGkxdVdq5zUhnxak3J4P5I3FTPrtUiyQuaQY15pUY1jM80Lid(i6HYfth1XKBqHMpQaeEUHTvqLRH3bO8m3JMlaL7r80CX7V20Ojxemvkav568hx56etE6sKbFe9q5g4FhtUbfA(Ocq45g2wbvUgEhGYZCpAUauUhXtZfV)AtJMCrWuPauLRZFCLRtm5Plrg8r0dLBG)6yYnOqZhvacp3W2kOY1W7auEM7rZfGY9iEAU49xBA0KlcMkfGQCD(JRCDgipDjYGZGXOgJEqJtcAEcgvoMCZfdyPCBlyubYnIQCXOzay0YTOG(RlcpxdYIYvFaKLci8Czy1bkzezWhrpuUhPJj3GcnFubi8CdBRGkxdVdq5zUh9O5cq5Eepnxle(Z)m5IGPsbOkxNh1vUoXKNUezWhrpuUoQJj3GcnFubi8CdBRGkxdVdq5zUh9O5cq5Eepnxle(Z)m5IGPsbOkxNh1vUoXKNUezWhrpuUy(3XKBqHMpQaeEUHTvqLRH3bO8m3JE0CbOCpINMRfc)5FMCrWuPauLRZJ6kxNyYtxIm4JOhkxmXioMCdk08rfGWZnSTcQCn8oaLN5E0CbOCpINMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JOhkxmpshtUbfA(Ocq45g2wbvUgEhGYZCpAUauUhXtZfV)AtJMCrWuPauLRZFCLRtm5PlrgCgmg1y0dACsqZtWOYXKBUyalLBBbJkqUruLlgnBKcWOLBrb9xxeEUgKfLR(ailfq45YWQduYiYGpIEOCXmqhtUbfA(Ocq45g2wbvUgEhGYZCp6rZfGY9iEAUwi8N)zYfbtLcqvUopQRCDIjpDjYGpIEOCXeJ4yYnOqZhvacp3W2kOY1W7auEM7rZfGY9iEAU49xBA0KlcMkfGQCD(JRCDEmpDjYGpIEOCX0XDm5guO5JkaHNByBfu5A4DakpZ9O5cq5Eepnx8(RnnAYfbtLcqvUo)XvUoXKNUezWzWbnTGrfGWZ9iZvzGgn56BdWiYGVHWfk2E6gg0MlpuVomkxmkPEnEgCqBUyuMbq2uLBGyEAUb(pW)zWzWbT5guy1bkzCmzWbT56yZfJoooHNBiYRvU8GulrgCqBUo2CdkS6aLWZfOfuci7yUm1qMCbOCz8Y8KeOfucyezWbT56yZnObzH(i8CFZqmYy0I3C)0QvBpzY1zliXP5cx0N0a0Y8kOuUow(YfUOpHbOL5vqjxIm4myLbA0yeWfXqw2k4GfcnN7rgrLvgSYanAmc4IyilBfeWHFCxkaBgSYanAmc4IyilBfeWHFCxkaBgSYanAmc4IyilBfeWHFmaTIDrzWkd0OXiGlIHSSvqah(5tRwT90PJArhyO5dDMK4KH3HD6N6F0bBKXaj6rOYPZydflqwKL2JXXg4FxhfZa)7IVOhHkNoJnuSazrwApghBG)6yDI5FhbOEAaIEyAnkOrJGg12t4UCSoXyhHHg8xdeWfXAdjvFdDSObiOrT9eUlxhfZJ8VRm4m4G2CXOuEsShGWZL(OI3CbTfLlalLRYaOk32KR(PTxT9KidwzGgnMdgKxlPnPwzWkd0OXeWHF(0QvBpD6Ow0H2iveD6N6F0bdm59sGwqjGryaAfvVNpmH40bG6PbimaT8OcxqJA7jCooG6PbimaY71sIxDeiOrT9eUloodm59sGwqjGryaAfvVNVaZGvgOrJjGd)8PvR2E60rTOdTrY8K(rN(P(hDWatEVeOfucyegGwXUi(WmdwzGgnMao8JnvgQo3d0t74bNoWqF0OdqmnuSazujoohyiKhh5Eem08HotsawsAG7QbgXd2fe7xmkyQShM4bNbRmqJgtah(bgbA0CAhpy)IrbtL9Wep4myLbA0yc4WppdjBazzYGvgOrJjGd)uVrQmqJgPVnGth1IoOi6udOAg4aMN2XdFA1QTNeTrQikdwzGgnMao8t9gPYanAK(2aoDul6aErQLDp4uDQbundCaZt74H6nuevqjbOTi3OAK4fPw29GtLGc6VggMWZGvgOrJjGd)uVrQmqJgPVnGth1IoyJuWPgq1mWbmpTJhQ3qrubLe2QxhgjrrP69sa2EGAeuq)1WWeEgSYanAmbC4N6nsLbA0i9TbC6Ow0bd40oEWtFKNVF)NbRmqJgtah(5tRwT90PJArhGl6t6Uua2t)u)Joax0NWDPaSzWkd0OXeWHF(0QvBpD6Ow0b4I(KgGwXUOt)u)Joax0NWa0k2fLbRmqJgtah(5tRwT90PJArhGl6tAaAzEfu60p1)OdWf9jmaTmVckLbRmqJgtah(PEJuzGgnsFBaNoQfDaUiyfWWknGm4myLbA0yekIo8PvR2E60rTOd4fPws3T3lJQ3lrX4PFQ)rhCA)IrbOTi3OAK4fPw29GtLOilThd)qz4clLNb8xGjhN9lgfG2ICJQrIxKAz3dovIIS0Em8RmqJgHbOvSlsq8KypajbTffWFbMqCsmFdBirps)B0IJJy(g2qcdYRLCiEc44iMVHnKqhELdXtGlxqSFXOa0wKBuns8Iul7EWPs8GHuVHIOckjaTf5gvJeVi1YUhCQeuq)1WWeEgSYanAmcfrbC4hdqRO69N2Xd2VyuyaAfvVxuuSidw12tqCAGjVxc0ckbmcdqRO698FmhNd1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmH7cIthQ3qrubLeEEzAPgz0teOhOsO(2c2qckO)AyycNJd0w0rpkg)lF2VyuyaAfvVxuKL2JjGaDLbRmqJgJqruah(Xa0kQE)PD8q9gkIkOKa0wKBuns8Iul7EWPsqb9xddt4qmWK3lbAbLagHbOvu9E(oCmeNoy)IrbOTi3OAK4fPw29GtL4bdX(fJcdqRO69IIIfzWQ2EIJZ5NwTA7jbErQL0D79YO69sumcXP9lgfgGwr17ffzP9y4)yoodm59sGwqjGryaAfvVNVaHaupnaHbqEVws8QJabnQTNWHy)IrHbOvu9ErrwApg()1LlxzWkd0OXiuefWHF(0QvBpD6Ow0bdqRO69s3ObiJQ3lrX4PFQ)rhudOuVeg5Mk(oY)owNy(3rSFXOa0wKBuns8Iul7EWPsyak7SlhRt7xmkmaTIQ3lkYs7X4ihFudm59sSQbqUCSoXrar8v8krrj5FdjkYs7X4i)6cI9lgfgGwr17fp4myLbA0yekIc4WpgGwMxbLoTJh(0QvBpjWlsTKUBVxgvVxIIriFA1QTNegGwr17LUrdqgvVxIIXmyLbA0yekIc4WpM3e7IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMySJ1atEVeOfucycOilThdefwYWsSZqiMVHnKOhPo8MbRmqJgJqruah(rXvyq)rsJBTSoLXlZtsGwqjG5aMN2XdoaA25EGcXbLbA0iuCfg0FK04wlljUAPqjrpYOVHIfWXHJacfxHb9hjnU1YsIRwkusyak7m)hdbhbekUcd6psACRLLexTuOKOilThd)hNbRmqJgJqruah(XcHMyx0PmEzEsc0ckbmhW80oEOOyrgSQTNGa0ckbeG2IKaKeVj(CIjghGtdm59sGwqjGryaAf7ICemf)6Y1rnWK3lbAbLaMakYs7XaXPtgc5XrUhbtL9WefP48YXzGjVxc0ckbmcdqRyxe)hZX5Ky(g2qIEKgKxlooI5Bydj6rAJay54iMVHnKOhP)nAbXbG6PbimONxIIsawsgrfzacAuBpHZXz)IrbC1wOcVvVulMontc)8gTeFQ)r8DiWF)7cItdm59sGwqjGryaAf7I4hZ)oItmdaOEAacG7EKwi0ye0O2Ec3LliQbuQxcJCtfF)(3XA)IrHbOvu9ErrwApghbJ4cId2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bdrHLmSe7SRmyLbA0yekIc4WpruXijkkhf8k60oEqHLmSe7CgSYanAmcfrbC4Ns)Ob9mYyrtq490oEW(fJcMk7HjEWzWkd0OXiuefWHFyKNmGw9s13qhlAaN2XdoTFXOWa0kQEV4bZXPgqPEjmYnv897FxqCW(fJcdYBanJepyioy)IrbtL9Wepyio7bqfmYRacxgBOybYIS0Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS0Emb44CC9aOcg5vaHlJnuSazrwApMJEumpY)8hyGCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKrLCLbRmqJgJqruah(PhMwJcA0CAhp40(fJcdqRO69IhmhNAaL6LWi3uX3V)DbXb7xmkmiVb0ms8GH4G9lgfmv2dt8GH4ShavWiVciCzSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeGJZX1dGkyKxbeUm2qXcKfzP9yo6rX8i)Z)XbYXXqipoY9iyO5dDMKaSK0a3vdmIhmhNdm0hn6aetdflqgvYLYanAmcfrbC4NZ9GxeU0a3vdmN2XdXgkwGSilThd)y(lhNt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)a)9phN9lgfWvBHk8w9sTy60mj8ZB0s8P(hX3Ha)9Vli2VyuyaAfvVx8GHWqipoY9iyQShMOilThdF)(pdwzGgngHIOao8JbqEVwYOxl6ugVmpjbAbLaMdyEAhpuuSidw12tqaTfjbijEt8H5VqmWK3lbAbLagHbOvSlIFmgIclzyj2zioTFXOGPYEyIIS0Em8H5FoohSFXOGPYEyIhSRmyLbA0yekIc4WpFA1QTNoDul6adnFOZKKHg8g0O50p1)Od2VyuaxTfQWB1l1IPtZKWpVrlXN6Fe)b(7FhRAaL6LWi3ubXjdH84i3JGPYEyIIS0EmbG5F(InuSazrwApgoogc5XrUhbtL9WefzP9yc44)8hBOybYIS0EmqInuSazrwApg(W84)CC2VyuWuzpmrrwApg(CCxqiMVHnKOhPo8YXfBOybYIS0Emh9Oyg4F(X83myLbA0yekIc4Wpm08HotsawsAG7QbMt74HpTA12tcgA(qNjjdn4nOrde1ak1lHrUPI)F)NbRmqJgJqruah(j(kELOOK8VHoTJhiMVHnKOhPo8crHLmSe7me7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)a)9peN4iGqXvyq)rsJBTSK4QLcLeGMDUhOCCoWqF0OdqmeRqEuHZXzGjVxc0ckbm8fORmyLbA0yekIc4WpgGwr17pTJhSFXOaneaRrctfJGbnAepyioTFXOWa0kQEVOOyrgSQTN44udOuVeg5Mk(C0)UYGvgOrJrOikGd)yaAfvV)0oEGH(OrhGyAOybYOsq(0QvBpjyO5dDMKm0G3GgnqyiKhh5Eem08HotsawsAG7QbgrrwApg(HYWfwkpDeg1ENQbuQxcJCt1r)9Vli2VyuyaAfvVxuuSidw12tzWkd0OXiuefWHFmaTmVckDAhpWqF0OdqmnuSazujiFA1QTNem08HotsgAWBqJgimeYJJCpcgA(qNjjaljnWD1aJOilThd)qz4clLNocJAVt1ak1lHrUP6Oh)3fe7xmkmaTIQ3lEWzWkd0OXiuefWHFmaTmVckDAhpy)IrbAiawJK5jTKFTPrJ4bZX5GbOvSlsOWsgwIDMJZP9lgfmv2dtuKL2JH)FHy)IrbtL9WepyooN2Vyuu6hnONrglAccVIIS0Em8dLHlSuE6imQ9ovdOuVeg5MQJE8FxqSFXOO0pAqpJmw0eeEfpyxUG8PvR2EsyaAfvVx6gnazu9EjkgHyGjVxc0ckbmcdqRO698FCgSYanAmcfrbC4NHClTqO50oEWjX8nSHe9i1HximeYJJCpcMk7HjkYs7XW3V)54CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yxquyjdlXoNbRmqJgJqruah(bR6JsleAoTJhCsmFdBirpsD4fcdH84i3JGPYEyIIS0Em897FooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmho2fefwYWsSZzWkd0OXiuefWHFIpVxAHqZPD8GtI5Bydj6rQdVqyiKhh5Eemv2dtuKL2JHVF)ZX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXUGOWsgwIDodwzGgngHIOao8JBTQgvsuus(3qzWkd0OXiuefWHF(0QvBpD6Ow0bdqRyxKShPb5160p1)OdgyY7LaTGsaJWa0k2fX3rgq0JqLtl1aOIx5N6F0rd8VRaIEeQCA)IrHbOL5vqjjzbJCtLfnaHbOSZhfJDLbRmqJgJqruah(XDPaSN2XdeZ3Wgs4FJwYH4jGJJy(g2qcD4voepbq(0QvBpjAJK5j9J44iMVHnKOhPb51cIdFA1QTNegGwXUizpsdYRfhN9lgfmv2dtuKL2JHFLbA0imaTIDrcINe7bijOTiio8PvR2Es0gjZt6hbX(fJcMk7HjkYs7XWpXtI9aKe0wee7xmkyQShM4bZXz)IrrPF0GEgzSOji8kEWqmWK3lXQgaX3FbgHJZHpTA12tI2izEs)ii2VyuWuzpmrrwApg(iEsShGKG2IYGvgOrJrOikGd)yaAf7IYGvgOrJrOikGd)uVrQmqJgPVnGth1IoevVhGTEzWzWkd0OXiSrk4qPF0GEgzSOji8EAhpy)IrbtL9Wep4myLbA0ye2ifeWHF(0QvBpD6Ow0bw1GbbEWN(P(hDWb7xmkSvVomsIIs17LaS9a1ihf8ks8GH4G9lgf2QxhgjrrP69sa2EGAKAX0Hep4myLbA0ye2ifeWHFy6WiV0(fJNoQfDWa0YJk8t74bN2VyuyREDyKefLQ3lby7bQrok4vKOilThdFyS4xoo7xmkSvVomsIIs17LaS9a1i1IPdjkYs7XWhgl(1fe1ak1lHrUPIVdo6FioziKhh5Eemv2dtuKL2JHphNJZjdH84i3JGSGrUPsAJgCrrwApg(CCioy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmeg6JgDaIZ8wToUCLbRmqJgJWgPGao8JbOL5vqPt74bh(0QvBpjyvdge4bdXPthyiKhh5Eem08HotsawsAG7QbgXdMJZHpTA12tcgA(qNjjdn4nOrdhNdm0hn6aetdflqgvYfeNm0hn6aetdflqgvIJZjdH84i3JGPYEyIIS0Em854CCoziKhh5EeKfmYnvsB0GlkYs7XWNJdXb7xmko3dEr4sYcg5MklAasAOcAhes8GHWqF0OdqCM3Q1XLlxU44CYqipoY9iyO5dDMKaSK0a3vdmIhmegc5XrUhbtL9WefP48cHH(OrhGyAOybYOsUYGvgOrJryJuqah(rXvyq)rsJBTSoLXlZtsGwqjG5aMN2XdoGJacfxHb9hjnU1YsIRwkusaA25EGcXbLbA0iuCfg0FK04wlljUAPqjrpYOVHIfaXPd4iGqXvyq)rsJBTSKyj1lan7Cpq54WraHIRWG(JKg3AzjXsQxuKL2JHVFDXXHJacfxHb9hjnU1YsIRwkusyak7m)hdbhbekUcd6psACRLLexTuOKOilThd)hdbhbekUcd6psACRLLexTuOKa0SZ9andwzGgngHnsbbC4hZBIDrNY4L5jjqlOeWCaZt74HIIfzWQ2EccqlOeqaAlscqs8M4dtmcefwYWsSZqC(PvR2EsWQgmiWdMJZPAaL6LWi3uX)X)H4G9lgfmv2dt8GDXXXqipoY9iyQShMOifNxxzWkd0OXiSrkiGd)yHqtSl6ugVmpjbAbLaMdyEAhpuuSidw12tqaAbLacqBrsasI3eFyES4xikSKHLyNH48tRwT9KGvnyqGhmhNt1ak1lHrUPI)J)dXb7xmkyQShM4b7IJJHqECK7rWuzpmrrkoVUG4G9lgfN7bViCjzbJCtLfnajnubTdcjEWzWkd0OXiSrkiGd)yaK3RLm61IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMyKakYs7XarHLmSe7meNFA1QTNeSQbdc8G54udOuVeg5Mk(p(phhdH84i3JGPYEyIIuCEDLbRmqJgJWgPGao8tevmsIIYrbVIoTJhuyjdlXoNbRmqJgJWgPGao8t8v8krrj5FdDAhp4Ky(g2qIEK6WlhhX8nSHegKxlzpsm54iMVHnKW)gTK9iX0feNoWqF0OdqmnuSazujooNQbuQxcJCtf)o6VqC(PvR2EsWQgmiWdMJtnGs9syKBQ4)4)CCFA1QTNeTrQiYfeNFA1QTNem08HotsCYW7WG4adH84i3JGHMp0zscWssdCxnWiEWCCo8PvR2EsWqZh6mjXjdVddIdmeYJJCpcMk7HjEWUC5cItgc5XrUhbtL9WefzP9y474)CCQbuQxcJCtfFo6FimeYJJCpcMk7HjEWqCYqipoY9iilyKBQK2ObxuKL2JHFLbA0imaTIDrcINe7bijOTioohyOpA0bioZB164IJl2qXcKfzP9y4hZ)UG4ehbekUcd6psACRLLexTuOKOilThdFymhNdm0hn6aedXkKhv4UYGvgOrJryJuqah(5Cp4fHlnWD1aZPD8GtI5Bydj8Vrl5q8eWXrmFdBiHb51soepbCCeZ3WgsOdVYH4jGJZ(fJcB1RdJKOOu9EjaBpqnYrbVIefzP9y4dJf)YXz)IrHT61HrsuuQEVeGThOgPwmDirrwApg(WyXVCCQbuQxcJCtfFo6FimeYJJCpcMk7HjksX51feNmeYJJCpcMk7HjkYs7XW3X)54yiKhh5Eemv2dtuKIZRloUydflqwKL2JHFm)NbRmqJgJWgPGao8dJ8Kb0QxQ(g6yrd40oEWPAaL6LWi3uXNJ(hIt7xmko3dEr4sYcg5MklAasAOcAhes8G54CGH(OrhG4mVvRJloog6JgDaIPHIfiJkXXz)IrHThHW9pdq8GHy)IrHThHW9pdquKL2JH)a)hGtm2ryOb)1abCrS2qs13qhlAacAuBpH7YfeNoWqF0OdqmnuSazujoogc5XrUhbdnFOZKeGLKg4UAGr8G54InuSazrwApg(ziKhh5Eem08HotsawsAG7QbgrrwApMaWiCCXgkwGSilThZrpkMh5F(d8FaoXyhHHg8xdeWfXAdjvFdDSObiOrT9eUlxzWkd0OXiSrkiGd)0dtRrbnAoTJhCQgqPEjmYnv85O)H40(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoohyOpA0bioZB164IJJH(OrhGyAOybYOsCC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaefzP9y4)4)b4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UCbXPdm0hn6aetdflqgvIJJHqECK7rWqZh6mjbyjPbURgyepyoUpTA12tcgA(qNjjoz4DyqInuSazrwApg(W8i)hqG)dWjg7im0G)AGaUiwBiP6BOJfnabnQTNWDXXfBOybYIS0Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS0EmbGr44InuSazrwApg(p(FaoXyhHHg8xdeWfXAdjvFdDSObiOrT9eUlxzWkd0OXiSrkiGd)WqZh6mjbyjPbURgyoTJhC(PvR2EsWqZh6mjXjdVddsSHIfilYs7XWhMh)NJZ(fJcMk7HjEWUG40(fJcB1RdJKOOu9EjaBpqnYrbVIegGYol)u)J474)CC2VyuyREDyKefLQ3lby7bQrQfthsyak7S8t9pIVJ)7IJl2qXcKfzP9y4hZ)zWkd0OXiSrkiGd)yaAzEfu60oEGH(OrhGyAOybYOsqC(PvR2EsWqZh6mjXjdVdJJJHqECK7rWuzpmrrwApg(X8VliQbuQxcJCtfF)(hcdH84i3JGHMp0zscWssdCxnWikYs7XWpM)ZGvgOrJryJuqah(5tRwT90PJArhudmgfufsSt)u)JoqmFdBirps)B0YroYJQmqJgHbOvSlsq8KypajbTffGdeZ3Wgs0J0)gTCemYrvgOrJWDPaScINe7bijOTOa(lc8OgyY7LyvdGYGvgOrJryJuqah(Xa0Y8kO0PD8GZEaubJ8kGWLXgkwGSilThd)ymhNt7xmkk9Jg0ZiJfnbHxrrwApg(HYWfwkpDeg1ENQbuQxcJCt1rp(Vli2Vyuu6hnONrglAccVIhSlxCCovdOuVeg5MQa(0QvBpjudmgfufsmhX(fJcI5BydjniVwIIS0EmbGJaI4R4vIIsY)gsaA2zJSilThhjqXV8HzG)54udOuVeg5MQa(0QvBpjudmgfufsmhX(fJcI5Bydj9VrlrrwApMaWrar8v8krrj5Fdjan7SrwKL2JJeO4x(WmW)UGqmFdBirpsD4fItNoWqipoY9iyQShM4bZXXqF0OdqCM3Q1bIdmeYJJCpcYcg5MkPnAWfpyxCCm0hn6aetdflqgvYfeNoWqF0Odq8rdalVfhNd2VyuWuzpmXdMJtnGs9syKBQ4Zr)7IJZ(fJcMk7HjkYs7XW3rcXb7xmkk9Jg0ZiJfnbHxXdodwzGgngHnsbbC4NHClTqO50oEWP9lgfeZ3Wgs6FJwIhmhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj25myLbA0ye2ifeWHFWQ(O0cHMt74bN2VyuqmFdBiP)nAjEWCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCSlikSKHLyNZGvgOrJryJuqah(j(8EPfcnN2XdoTFXOGy(g2qs)B0s8G54CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yxquyjdlXoNbRmqJgJWgPGao8JBTQgvsuus(3qzWkd0OXiSrkiGd)yaAf7IoTJhiMVHnKOhP)nAXXrmFdBiHb51soepbCCeZ3WgsOdVYH4jGJZ(fJc3AvnQKOOK8VHepyieZ3Wgs0J0)gT44CA)IrbtL9WefzP9y4xzGgnc3LcWkiEsShGKG2IGy)IrbtL9WepyxzWkd0OXiSrkiGd)4Uua2myLbA0ye2ifeWHFQ3ivgOrJ03gWPJArhIQ3dWwVm4myLbA0ye4fPw29Gt1HpTA12tNoQfDWOrscqYNHKgyY7p9t9p6Gt7xmkaTf5gvJeVi1YUhCQefzP9y4dkdxyP8mG)cmH4Ky(g2qIEK2iawooI5Bydj6rAqET44iMVHnKW)gTKdXtGloo7xmkaTf5gvJeVi1YUhCQefzP9y4tzGgncdqRyxKG4jXEascAlkG)cmH4Ky(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaxU44CW(fJcqBrUr1iXlsTS7bNkXdodwzGgngbErQLDp4ufWHFmaTmVckDAhp40HpTA12tcJgjjajFgsAGjVNJZP9lgfL(rd6zKXIMGWROilThd)qz4clLNocJAVt1ak1lHrUP6Oh)3fe7xmkk9Jg0ZiJfnbHxXd2Lloo1ak1lHrUPIph9FgSYanAmc8Iul7EWPkGd)O4kmO)iPXTwwNY4L5jjqlOeWCaZt74bhWraHIRWG(JKg3AzjXvlfkjan7CpqH4GYanAekUcd6psACRLLexTuOKOhz03qXcG40bCeqO4kmO)iPXTwwsSK6fGMDUhOCC4iGqXvyq)rsJBTSKyj1lkYs7XW3VU44WraHIRWG(JKg3AzjXvlfkjmaLDM)JHGJacfxHb9hjnU1YsIRwkusuKL2JH)JHGJacfxHb9hjnU1YsIRwkusaA25EGMbRmqJgJaVi1YUhCQc4Wpwi0e7IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMbcXPt7xmkyQShMOilThdF)cXP9lgfL(rd6zKXIMGWROilThdF)YX5G9lgfL(rd6zKXIMGWR4b7IJZb7xmkyQShM4bZXPgqPEjmYnv8F8FxqC6G9lgfN7bViCjzbJCtLfnajnubTdcjEWCCQbuQxcJCtf)h)3fefwYWsSZUYGvgOrJrGxKAz3dovbC4hZBIDrNY4L5jjqlOeWCaZt74HIIfzWQ2EccqlOeqaAlscqs8M4dZaH40P9lgfmv2dtuKL2JHVFH40(fJIs)Ob9mYyrtq4vuKL2JHVF54CW(fJIs)Ob9mYyrtq4v8GDXX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlioDW(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo1ak1lHrUPI)J)7cIclzyj2zxzWkd0OXiWlsTS7bNQao8JbqEVwYOxl6ugVmpjbAbLaMdyEAhpuuSidw12tqaAbLacqBrsasI3eFyIrG40P9lgfmv2dtuKL2JHVFH40(fJIs)Ob9mYyrtq4vuKL2JHVF54CW(fJIs)Ob9mYyrtq4v8GDXX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlioDW(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo1ak1lHrUPI)J)7cIclzyj2zxzWkd0OXiWlsTS7bNQao8tevmsIIYrbVIoTJhuyjdlXoNbRmqJgJaVi1YUhCQc4WpL(rd6zKXIMGW7PD8G9lgfmv2dt8GZGvgOrJrGxKAz3dovbC4NZ9GxeU0a3vdmN2XdoDA)IrbX8nSHKgKxlrrwApg(W8phN9lgfeZ3Wgs6FJwIIS0Em8H5FxqyiKhh5Eemv2dtuKL2JHVJ)7IJJHqECK7rWuzpmrrkoVzWkd0OXiWlsTS7bNQao8dJ8Kb0QxQ(g6yrd40oEWP9lgfN7bViCjzbJCtLfnajnubTdcjEWCCoWqF0OdqCM3Q1Xfhhd9rJoaX0qXcKrL44(0QvBpjAJurehN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(d8FaoXyhHHg8xdeWfXAdjvFdDSObiOrT9eUlioy)IrbtL9Wepyio7bqfmYRacxgBOybYIS0Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS0Emb44CC9aOcg5vaHlJnuSazrwApg(dmqoUEaubJ8kGWLXgkwGSilThZrpkMh5F(dmqoogc5XrUhbdnFOZKeGLKg4UAGr8G54CGH(OrhGyAOybYOsUYGvgOrJrGxKAz3dovbC4NEyAnkOrZPD8Gt7xmko3dEr4sYcg5MklAasAOcAhes8G54CGH(OrhG4mVvRJloog6JgDaIPHIfiJkXX9PvR2Es0gPIioo7xmkS9ieU)zaIhme7xmkS9ieU)zaIIS0Em8F8)aCIXocdn4VgiGlI1gsQ(g6yrdqqJA7jCxqCW(fJcMk7HjEWqC2dGkyKxbeUm2qXcKfzP9y4NHqECK7rWqZh6mjbyjPbURgyefzP9ycWX546bqfmYRacxgBOybYIS0Em8FCGCC9aOcg5vaHlJnuSazrwApMJEumpY)8FCGCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKrLCLbRmqJgJaVi1YUhCQc4WpFA1QTNoDul6adnFOZKKHg8g0O50p1)Odm0hn6aetdflqgvcIt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aX4)qCYqipoY9iyQShMOilThtay(NVEaubJ8kGWLXgkwGSilThdhhdH84i3JGPYEyIIS0EmbC8F(7bqfmYRacxgBOybYIS0Emq6bqfmYRacxgBOybYIS0Em8H5X)54SFXOGPYEyIIS0Em854UGy)IrbX8nSHKgKxlrrwApg(W8phxpaQGrEfq4YydflqwKL2J5OhfZa)ZpM)6kdwzGgngbErQLDp4ufWHF(0QvBpD6Ow0bJ(rYiQKmv2d70p1)OdoDGHqECK7rWuzpmrrkoVCCo8PvR2EsWqZh6mjzObVbnAGWqF0OdqmnuSazujxzWkd0OXiWlsTS7bNQao8ddnFOZKeGLKg4UAG50oE4tRwT9KGHMp0zsYqdEdA0arnGs9syKBQ4hJ)NbRmqJgJaVi1YUhCQc4WpXxXRefLK)n0PD8aX8nSHe9i1HxikSKHLyNH4ehbekUcd6psACRLLexTuOKa0SZ9aLJZbg6JgDaIHyfYJkCxq(0QvBpjm6hjJOsYuzpSmyLbA0ye4fPw29Gtvah(Xa0Y8kO0PD8ad9rJoaX0qXcKrLG8PvR2EsWqZh6mjzObVbnAGOgqPEjmYnv8DaJ)dHHqECK7rWqZh6mjbyjPbURgyefzP9y4hkdxyP80ryu7DQgqPEjmYnvh94)UYGvgOrJrGxKAz3dovbC4NHClTqO50oEWP9lgfeZ3Wgs6FJwIhmhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmc8Iul7EWPkGd)Gv9rPfcnN2XdoTFXOGy(g2qs)B0s8GH4ad9rJoaXzERwhooN2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bdHH(OrhG4mVvRJlooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmhoMJZ(fJcMk7HjEWUGOWsgwIDgYNwTA7jHr)izevsMk7HLbRmqJgJaVi1YUhCQc4WpXN3lTqO50oEWP9lgfeZ3Wgs6FJwIhmehyOpA0bioZB16WX50(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyim0hn6aeN5TADCXX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXCC2VyuWuzpmXd2fefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0ye4fPw29Gtvah(XTwvJkjkkj)BOmyLbA0ye4fPw29Gtvah(Xa0k2fDAhpqmFdBirps)B0IJJy(g2qcdYRLCiEc44iMVHnKqhELdXtahN9lgfU1QAujrrj5FdjEWqSFXOGy(g2qs)B0s8G54CA)IrbtL9WefzP9y4xzGgnc3LcWkiEsShGKG2IGy)IrbtL9WepyxzWkd0OXiWlsTS7bNQao8J7sbyZGvgOrJrGxKAz3dovbC4N6nsLbA0i9TbC6Ow0HO69aS1ldodwzGgngru9Ea26DWa0Y8kO0PD8Gd1BOiQGscB1RdJKOOu9EjaBpqnckO)AyycpdwzGgngru9Ea26fWHFmVj2fDkJxMNKaTGsaZbmpTJhWraHfcnXUirrwApg(kYs7XKbRmqJgJiQEpaB9c4Wpwi0e7IYGZGvgOrJraxeScyyLgWbleAIDrNY4L5jjqlOeWCaZt74HIIfzWQ2EccqlOeqaAlscqs8M4dZaH40(fJcMk7HjkYs7XW3VCCoy)IrbtL9Wepyoo1ak1lHrUPI)J)7cIclzyj25myLbA0yeWfbRagwPbeWHFmVj2fDkJxMNKaTGsaZbmpTJhkkwKbRA7jiaTGsabOTijajXBIpmdeIt7xmkyQShMOilThdF)YX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlikSKHLyNZGvgOrJraxeScyyLgqah(XaiVxlz0RfDkJxMNKaTGsaZbmpTJhkkwKbRA7jiaTGsabOTijajXBIpmdeIt7xmkyQShMOilThdF)YX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlikSKHLyNZGvgOrJraxeScyyLgqah(jIkgjrr5OGxrN2XdkSKHLyNZGvgOrJraxeScyyLgqah(HrEYaA1lvFdDSObCAhp4unGs9syKBQ4Zr)ZXz)IrHThHW9pdq8GHy)IrHThHW9pdquKL2JH)aXiUG4G9lgfmv2dt8GZGvgOrJraxeScyyLgqah(PhMwJcA0CAhp4unGs9syKBQ4Zr)ZXz)IrHThHW9pdq8GHy)IrHThHW9pdquKL2JH)JXiUG4G9lgfmv2dt8GZGvgOrJraxeScyyLgqah(5tRwT90PJArhm6hjJOsYuzpSt)u)Jo4adH84i3JGPYEyIIuCEZGvgOrJraxeScyyLgqah(j(kELOOK8VHoTJhiMVHnKOhPo8crHLmSe7mKpTA12tcJ(rYiQKmv2dldwzGgngbCrWkGHvAabC4hMomYlTFX4PJArhmaT8Oc)0oEW(fJcdqlpQWffzP9y4hJaXP9lgfeZ3WgsAqETepyoo7xmkiMVHnK0)gTepyxqudOuVeg5Mk(C0)zWkd0OXiGlcwbmSsdiGd)yaAzEfu60oEWPdAqOQbKWaksp3duPbOLru6CMJZ(fJcMk7HjkYs7XWpXtI9aKe0wehNdWf9jmaTmVck5cIt7xmkyQShM4bZXPgqPEjmYnv85O)HqmFdBirpsD41vgSYanAmc4IGvadR0ac4WpgGwMxbLoTJhC6GgeQAajmGI0Z9avAaAzeLoN54SFXOGPYEyIIS0Em8t8KypajbTfXX5WNwTA7jbCrFsdqlZRGsUGaupnaHbOLhv4cAuBpHdXP9lgfgGwEuHlEWCCQbuQxcJCtfFo6FxqSFXOWa0YJkCHbOSZ8FmeN2VyuqmFdBiPb51s8G54SFXOGy(g2qs)B0s8GDbHHqECK7rWuzpmrrwApg(C8myLbA0yeWfbRagwPbeWHFmaTmVckDAhp40bniu1asyafPN7bQ0a0YikDoZXz)IrbtL9WefzP9y4N4jXEascAlIJZb4I(egGwMxbLCbX(fJcI5BydjniVwIIS0Em854qiMVHnKOhPb51cIda1tdqyaA5rfUGg12t4qyiKhh5Eemv2dtuKL2JHphpdwzGgngbCrWkGHvAabC4NHClTqO50oEWP9lgfeZ3Wgs6FJwIhmhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmc4IGvadR0ac4WpyvFuAHqZPD8Gt7xmkiMVHnK0)gTepyooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmhoMJZ(fJcMk7HjEWUGOWsgwIDgYNwTA7jHr)izevsMk7HLbRmqJgJaUiyfWWknGao8t859sleAoTJhCA)IrbX8nSHK(3OL4bZX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXCC2VyuWuzpmXd2fefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0yeWfbRagwPbeWHFCRv1OsIIsY)gkdwzGgngbCrWkGHvAabC4hdqRyx0PD8Gtniu1asyafPN7bQ0a0YikDodX(fJcMk7HjkYs7XWhXtI9aKe0wee4I(eUlfG1fhNth0GqvdiHbuKEUhOsdqlJO05mhN9lgfmv2dtuKL2JHFINe7bijOTioohGl6tyaAf7ICbXjX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbCC2Vyu4wRQrLefLK)nK4bdX(fJcI5Bydj9VrlXdMJZP9lgfmv2dtuKL2JHFLbA0iCxkaRG4jXEascAlcI9lgfmv2dt8GD5IJZPgeQAajWv3tpqLM3ikDoZxGqSFXOGy(g2qsdYRLOilThdF)cXb7xmkWv3tpqLM3ikYs7XWNYanAeUlfGvq8KypajbTf5kdwzGgngbCrWkGHvAabC4h3LcWMbRmqJgJaUiyfWWknGao8t9gPYanAK(2aoDul6qu9Ea26LbNbRmqJgJWaoO4kmO)iPXTwwNY4L5jjqlOeWCaZt74bhWraHIRWG(JKg3AzjXvlfkjan7CpqH4GYanAekUcd6psACRLLexTuOKOhz03qXcG40bCeqO4kmO)iPXTwwsSK6fGMDUhOCC4iGqXvyq)rsJBTSKyj1lkYs7XW3VU44WraHIRWG(JKg3AzjXvlfkjmaLDM)JHGJacfxHb9hjnU1YsIRwkusuKL2JH)JHGJacfxHb9hjnU1YsIRwkusaA25EGMbRmqJgJWac4Wpwi0e7IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMbcXP9lgfmv2dtuKL2JHVFH40(fJIs)Ob9mYyrtq4vuKL2JHVF54CW(fJIs)Ob9mYyrtq4v8GDXX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlioDW(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo1ak1lHrUPI)J)7cIclzyj25myLbA0yegqah(X8Myx0PmEzEsc0ckbmhW80oEOOyrgSQTNGa0ckbeG2IKaKeVj(WmqioTFXOGPYEyIIS0Em89leN2Vyuu6hnONrglAccVIIS0Em89lhNd2Vyuu6hnONrglAccVIhSloohSFXOGPYEyIhmhNAaL6LWi3uX)X)DbXPd2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bZXPgqPEjmYnv8F8FxquyjdlXoNbRmqJgJWac4Wpga59AjJETOtz8Y8KeOfucyoG5PD8qrXImyvBpbbOfuciaTfjbijEt8HjgbIt7xmkyQShMOilThdF)cXP9lgfL(rd6zKXIMGWROilThdF)YX5G9lgfL(rd6zKXIMGWR4b7IJZb7xmkyQShM4bZXPgqPEjmYnv8F8FxqC6G9lgfN7bViCjzbJCtLfnajnubTdcjEWCCQbuQxcJCtf)h)3fefwYWsSZzWkd0OXimGao8tevmsIIYrbVIoTJhuyjdlXoNbRmqJgJWac4WpL(rd6zKXIMGW7PD8G9lgfmv2dt8GZGvgOrJryabC4NZ9GxeU0a3vdmN2XdoDA)IrbX8nSHKgKxlrrwApg(W8phN9lgfeZ3Wgs6FJwIIS0Em8H5FxqyiKhh5Eemv2dtuKL2JHVJ)dXP9lgfWvBHk8w9sTy60mj8ZB0s8P(hXFGy8FoohQ3qrubLeWvBHk8w9sTy60mj8ZB0sqb9xddt4UCXXz)IrbC1wOcVvVulMontc)8gTeFQ)r8Diqh)phhdH84i3JGPYEyIIuCEH4unGs9syKBQ4Zr)ZX9PvR2Es0gPIixzWkd0OXimGao8dJ8Kb0QxQ(g6yrd40oEWPAaL6LWi3uXNJ(hIt7xmko3dEr4sYcg5MklAasAOcAhes8G54CGH(OrhG4mVvRJloog6JgDaIPHIfiJkXX9PvR2Es0gPIioo7xmkS9ieU)zaIhme7xmkS9ieU)zaIIS0Em8h4)aC60rDK6nuevqjbC1wOcVvVulMontc)8gTeuq)1WWeURaCIXocdn4VgiGlI1gsQ(g6yrdqqJA7jCxUCbXb7xmkyQShM4bdXzSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeGJZXfBOybYIS0Em8hyGb40rDeN2VyuaxTfQWB1l1IPtZKWpVrlXN6FeFy()VlxCCXgkwGSilThZrpkMh5F(dmqoogc5XrUhbdnFOZKeGLKg4UAGr8G54CGH(OrhGyAOybYOsUYGvgOrJryabC4NEyAnkOrZPD8Gt1ak1lHrUPIph9peN2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bZX5ad9rJoaXzERwhxCCm0hn6aetdflqgvIJ7tRwT9KOnsfrCC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaefzP9y4)4)b40PJ6i1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHjCxb4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UC5cId2VyuWuzpmXdgIZydflqwKL2JHFgc5XrUhbdnFOZKeGLKg4UAGruKL2JjahNJl2qXcKfzP9y4)4adWPJ6ioTFXOaUAluH3QxQftNMjHFEJwIp1)i(W8)FxU44InuSazrwApMJEumpY)8FCGCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKrLCLbRmqJgJWac4WpFA1QTNoDul6adnFOZKKHg8g0O50p1)Odm0hn6aetdflqgvcIt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aX4)qCYqipoY9iyQShMOilThtay(NVydflqwKL2JHJJHqECK7rWuzpmrrwApMao(p)XgkwGSilThdKydflqwKL2JHpmp(phN9lgfmv2dtuKL2JHph3fe7xmkiMVHnK0G8AjkYs7XWhM)54InuSazrwApMJEumd8p)y(RRmyLbA0yegqah(5tRwT90PJArhm6hjJOsYuzpSt)u)Jo40bgc5XrUhbtL9WefP48YX5WNwTA7jbdnFOZKKHg8g0Obcd9rJoaX0qXcKrLCLbRmqJgJWac4Wpm08HotsawsAG7QbMt74HpTA12tcgA(qNjjdn4nOrde1ak1lHrUPI)J)NbRmqJgJWac4WpXxXRefLK)n0PD8aX8nSHe9i1HxikSKHLyNHy)IrbC1wOcVvVulMontc)8gTeFQ)r8hig)hItCeqO4kmO)iPXTwwsC1sHscqZo3duoohyOpA0bigIvipQWDb5tRwT9KWOFKmIkjtL9WYGvgOrJryabC4hdqRO69N2Xd2VyuGgcG1iHPIrWGgnIhme7xmkmaTIQ3lkkwKbRA7PmyLbA0yegqah(HPdJ8s7xmE6Ow0bdqlpQWpTJhSFXOWa0YJkCrrwApg()fIt7xmkiMVHnK0G8AjkYs7XW3VCC2VyuqmFdBiP)nAjkYs7XW3VUGOgqPEjmYnv85O)ZGvgOrJryabC4hdqlZRGsN2Xdm0hn6aetdflqgvcYNwTA7jbdnFOZKKHg8g0ObcdH84i3JGHMp0zscWssdCxnWikYs7XWpugUWs5PJWO27unGs9syKBQo6X)DLbRmqJgJWac4WpgGwr17pTJhaQNgGWaiVxljE1rGGg12t4qCaOEAacdqlpQWf0O2EchI9lgfgGwr17ffflYGvT9eeN2VyuqmFdBiP)nAjkYs7XWhgbcX8nSHe9i9Vrli2VyuaxTfQWB1l1IPtZKWpVrlXN6Fe)b(7Foo7xmkGR2cv4T6LAX0Pzs4N3OL4t9pIVdb(7FiQbuQxcJCtfFo6FooCeqO4kmO)iPXTwwsC1sHsIIS0Em8DKCCkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflWfehyiKhh5Eemv2dtuKIZBgSYanAmcdiGd)yaAzEfu60oEW(fJc0qaSgjZtAj)AtJgXdMJZ(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo7xmkyQShM4bdXP9lgfL(rd6zKXIMGWROilThd)qz4clLNocJAVt1ak1lHrUP6Oh)3fe7xmkk9Jg0ZiJfnbHxXdMJZb7xmkk9Jg0ZiJfnbHxXdgIdmeYJJCpIs)Ob9mYyrtq4vuKIZlhNdm0hn6aeF0aWYB5IJtnGs9syKBQ4Zr)dHy(g2qIEK6WBgSYanAmcdiGd)yaAzEfu60oEaOEAacdqlpQWf0O2EchIt7xmkmaT8Ocx8G54udOuVeg5Mk(C0)UGy)IrHbOLhv4cdqzN5)yioTFXOGy(g2qsdYRL4bZXz)IrbX8nSHK(3OL4b7cI9lgfWvBHk8w9sTy60mj8ZB0s8P(hXFGo(FioziKhh5Eemv2dtuKL2JHpm)ZX5WNwTA7jbdnFOZKKHg8g0Obcd9rJoaX0qXcKrLCLbRmqJgJWac4WpgGwMxbLoTJhCA)IrbC1wOcVvVulMontc)8gTeFQ)r8hOJ)NJZ(fJc4QTqfEREPwmDAMe(5nAj(u)J4pWF)dbOEAacdG8ETK4vhbcAuBpH7cI9lgfeZ3WgsAqETefzP9y4ZXHqmFdBirpsdYRfehSFXOaneaRrctfJGbnAepyioaupnaHbOLhv4cAuBpHdHHqECK7rWuzpmrrwApg(CCioziKhh5EeN7bViCPbURgyefzP9y4ZX54CGH(OrhG4mVvRJRmyLbA0yegqah(zi3sleAoTJhCA)IrbX8nSHK(3OL4bZX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXUGOWsgwIDgYNwTA7jHr)izevsMk7HLbRmqJgJWac4WpyvFuAHqZPD8Gt7xmkiMVHnK0)gTepyioWqF0OdqCM3Q1HJZP9lgfN7bViCjzbJCtLfnajnubTdcjEWqyOpA0bioZB164IJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJ54SFXOGPYEyIhSlikSKHLyNH8PvR2Esy0psgrLKPYEyzWkd0OXimGao8t859sleAoTJhCA)IrbX8nSHK(3OL4bdXbg6JgDaIZ8wToCCoTFXO4Cp4fHljlyKBQSObiPHkODqiXdgcd9rJoaXzERwhxCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCmhN9lgfmv2dt8GDbrHLmSe7mKpTA12tcJ(rYiQKmv2dldwzGgngHbeWHFCRv1OsIIsY)gkdwzGgngHbeWHFmaTIDrN2XdeZ3Wgs0J0)gT44iMVHnKWG8AjhINaooI5Bydj0Hx5q8eWXz)IrHBTQgvsuus(3qIhme7xmkiMVHnK0)gTepyooN2VyuWuzpmrrwApg(vgOrJWDPaScINe7bijOTii2VyuWuzpmXd2vgSYanAmcdiGd)4Uua2myLbA0yegqah(PEJuzGgnsFBaNoQfDiQEpaB9UHgyIDpbZ)bEbxW9c]] )


end