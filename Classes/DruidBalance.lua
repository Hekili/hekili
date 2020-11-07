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


    spec:RegisterPack( "Balance", 20201106, [[dCKXRdqicLhjuk6sQQuBceFIQa0OOuofLQvPQsELqXSuP4wufKDHQFPQIHbbhdISmvIEMkLMMkPCnvvzBufQVrvGgNkPQZrviRJQGAEufDpHQ9rO6GcLcTqikpuOunrQci5IufqQpsvaXjPkGALQeMPkPYovjzOufawQqPGNkKPQQQ(kvbq7vf)LObR0HjTyk5XOmziDzKnl4ZG0OjKtR41QunBQCBQQDl1VHA4G64cLslxYZPy6axxv2UQY3PknEiQopeA9cLmFc2VOpiD()eHQa6C1LiCjciHecEm)YlV92B9Oteary6ebRS7ku6e1QpDIqM60MrNiyfrhwrp)FIm4xXOtKiaa24H)5hOdq0ZIZW()yg)NtbdUzLga)ygF2pNiR34aEG7J1jcvb05Qlr4seqcje8y(LxE7Tx6rNi9beHRtu04h7Nirdkk1hRtekzyNOyZCrM60Mr56bQ6nO5fXM5Ef(J8TOkxp(MCVeHlriViVi2m3yxK2qjJhoVi2mxpuUXgrrj0CJWoTYfzK6ZZlInZ1dLBSlsBOeAUaTGsa5eYLPgYKlaNldrMJKaTGsadpVi2mxpuUXgiF8hHM7RBIrgJwiM7NwJA5itU2goXVjx4I(KgGwMxbLY1djEUWf9XnaTmVckzNFICJbyo)FIGlIH9TuW5)ZviD()ePmWG7tKpg33NwgWL)jIA1YrOhKDaNRU88)jszGb3NiVLceDIOwTCe6bzhW5QBp)FIugyW9jYBParNiQvlhHEq2bCU6AN)prkdm4(ezaAfMIoruRwoc9GSd4C1FN)pruRwoc9GSteg(eziWjszGb3NOpTg1YrNOp19OtKf2yYfsUbhgx5AlxB5ggOIaYI81Pn56HY9seY1EU)KlsxIqU2Zv8CdomUY1wU2YnmqfbKf5RtBY1dL7L)LRhkxB5Iec5(RCbQJAaFAMwTcgCZPwTCeAU2Z1dLRTCVwU)kxgUrFdGdxeBmKuDd02NAaNA1YrO5Apx75(tUiD9iKR9t0NwYw9Pted3F47KeLmi2Sd4aorwyfC()CfsN)pruRwoc9GSteRgavJEISEHaNPYPz8h8jszGb3NOs)Og)mYqrDSq8aoxD55)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6efCyCLRTCTL70aQGXofqOYWaveqwKVoTjxpuUxIqU2Z9NCr6seY1EUINBWHXvU2Y1wUtdOcg7uaHkddurazr(60MC9q5E5F56HY1wUiHqU)kxG6OgWNMPvRGb3CQvlhHMR9C9q5Al3RL7VYLHB03a4WfXgdjv3aT9PgWPwTCeAU2Z1EU)Klsxpc5A)e9PLSvF6eXW9h(ojrjdIn7aoxD75)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ejwUwVqGBPoTzKehKQZjbIMgQr2k4ve)bNlKCflxRxiWTuN2msIds15Kartd1i1IPnXFWNOpTKT6tNiwnGgdEWhW5QRD()erTA5i0dYorkdm4(ePOkmy(iPXRw(NiwnaQg9ez9cbUL60MrsCqQoNeiAAOgzRGxrCdqz3LFQ7r56zUxdHCHKR1le4wQtBgjXbP6CsGOPHAKAX0M4gGYUl)u3JY1ZCVgc5cjxB5kwUOyaxrvyW8rsJxT8LOQVcL4GHDFAO5cjxXYvzGb3CfvHbZhjnE1YxIQ(kuIpTm4gOIa5cjxB5kwUOyaxrvyW8rsJxT8LIi1Xbd7(0qZvqixumGROkmy(iPXRw(srK64f5RtBYv8CVnx75kiKlkgWvufgmFK04vlFjQ6RqjUbOS756zU3MlKCrXaUIQWG5JKgVA5lrvFfkXlYxN2KRN5(xUqYffd4kQcdMpsA8QLVev9vOehmS7tdnx7NigImhjbAbLaMZviDaNR(78)jIA1YrOhKDIy1aOA0tKTC)0AulhXz4(dFNKOKbXMLlKCNgqfm2PacvggOIaYI81Pn5kEUiDlc5cjxXYLHXouS3MZu50mErkkI5kiKR1le4mvonJ)GZ1EUqY1wUwVqGBPoTzKehKQZjbIMgQr2k4ve3au2D5N6EuUXZ9peYvqixRxiWTuN2msIds15Kartd1i1IPnXnaLDx(PUhLB8C)dHCTNRGqUHbQiGSiFDAtUEMlsiCIugyW9jIH7p8Dscersd8udWCaNR84Z)NiQvlhHEq2jIvdGQrpr2Y16fcCl1PnJK4GuDojq00qnYwbVI4f5RtBYv8CVg)VCfeY16fcCl1PnJK4GuDojq00qnsTyAt8I81Pn5kEUxJ)xU2ZfsUQbuQtcJ9svUIhpxpcHCHKRTCzySdf7T5mvonJxKVoTjxXZ1dMRGqU2YLHXouS3Mt(WyVujTWnkViFDAtUINRhmxi5kwUwVqGFFA0IqLKpm2lv(udKutf0jwe)bNlKCz4pQ1gWVJynANR9CTFIugyW9jIPnJCsRxiCISEHGSvF6ezaA5Wf6bCUYdE()erTA5i0dYorSAaun6jsSC)0AulhXz1aAm4bNlKCTLld)rT2aEpqfbKbLYvqixgg7qXEBotLtZ4f5RtBYv8C9G5kiKRTCzySdf7T5Kpm2lvslCJYlYxN2KR456bZfsUILR1le43NgTiuj5dJ9sLp1aj1ubDIfXFW5cjxg(JATb87iwJ25Apx7NiLbgCFImaTmVckDaNRU(Z)NiQvlhHEq2jIvdGQrpr2YLHXouS3MZW9h(ojbIiPbEQby4p4CHKRTC)0AulhXz4(dFNKOKbXMLRGqUmm2HI92CMkNMXlYxN2KRN5(xU2Z1EUqYvnGsDsySxQYv8C)dHCHKld)rT2aEpqfbKbLorkdm4(ezaAzEfu6aox5rN)pruRwoc9GStKYadUprMxhMIorSAaun6jQOqrgrQLJYfsUaTGsaoy8jjalrhkxXZfjpoxi5QWsMiIDpxi5Al3pTg1YrCwnGgdEW5kiKRTCvdOuNeg7LQC9m3Brixi5kwUwVqGZu50m(dox75kiKldJDOyVnNPYPz8IuueZ1(jIHiZrsGwqjG5CfshW5kKq48)jIA1YrOhKDIugyW9jYhJ7Wu0jIvdGQrprffkYisTCuUqYfOfucWbJpjbyj6q5kEUiDl)VCHKRclzIi29CHKRTC)0AulhXz1aAm4bNRGqU2YvnGsDsySxQY1ZCVfHCHKRy5A9cbotLtZ4p4CTNRGqUmm2HI92CMkNMXlsrrmx75cjxXY16fc87tJweQK8HXEPYNAGKAQGoXI4p4tedrMJKaTGsaZ5kKoGZviH05)te1QLJqpi7ePmWG7tKbqoNwYGtl6eXQbq1ONOIcfzePwokxi5c0ckb4GXNKaSeDOCfpxK84CJj3I81Pn5cjxfwYerS75cjxB5(P1OwoIZQb0yWdoxbHCvdOuNeg7LQC9m3BrixbHCzySdf7T5mvonJxKIIyU2prmezosc0ckbmNRq6aoxH0LN)pruRwoc9GSteRgavJEIuyjteXUFIugyW9jkGlgjXbzRGxrhW5kKU98)jIA1YrOhKDIy1aOA0tKTCjMBGneFAP2iMRGqUeZnWgIBWoTKtlrkxbHCjMBGne39ATKtlrkx75cjxB5kwUm8h1Ad49aveqgukxbHCTLRAaL6KWyVuLRN56r)LlKCTL7NwJA5ioRgqJbp4CfeYvnGsDsySxQY1ZCVfHCfeY9tRrTCeFmsft5Apxi5Al3pTg1YrCgU)W3jjkzqSz5cjxXYLHXouS3MZW9h(ojbIiPbEQby4p4CfeYvSC)0AulhXz4(dFNKOKbXMLlKCflxgg7qXEBotLtZ4p4CTNR9CTNlKCTLldJDOyVnNPYPz8I81Pn5kEU3IqUcc5QgqPojm2lv5kEUEec5cjxgg7qXEBotLtZ4p4CHKRTCzySdf7T5Kpm2lvslCJYlYxN2KRN5QmWGBUbOvykItiNypajbJpLRGqUILld)rT2a(DeRr7CTNRGqUHbQiGSiFDAtUEMlsiKR9CHKRTCrXaUIQWG5JKgVA5lrvFfkXlYxN2KR45ETCfeYvSCz4pQ1gWBIvyhUqZ1(jszGb3NOWRquIdsY9A6aoxH01o)FIOwTCe6bzNiwnaQg9ezlxI5gydXDVwlztihKRGqUeZnWgIBWoTKnHCqUcc5sm3aBiU2ikBc5GCfeY16fcCl1PnJK4GuDojq00qnYwbVI4f5RtBYv8CVg)VCfeY16fcCl1PnJK4GuDojq00qnsTyAt8I81Pn5kEUxJ)xUcc5QgqPojm2lv5kEUEec5cjxgg7qXEBotLtZ4fPOiMR9CHKRTCzySdf7T5mvonJxKVoTjxXZ9weYvqixgg7qXEBotLtZ4fPOiMR9CfeYnmqfbKf5RtBY1ZCrcHtKYadUpr3NgTiuPbEQbyoGZvi935)te1QLJqpi7eXQbq1ONiB5QgqPojm2lv5kEUEec5cjxB5A9cb(9Prlcvs(WyVu5tnqsnvqNyr8hCUcc5kwUm8h1Ad43rSgTZ1EUcc5YWFuRnG3durazqPCfeY16fcClhgJ6Ega)bNlKCTEHa3YHXOUNbWlYxN2KRN5Ejc5gtU2Y9A5(RCz4g9naoCrSXqs1nqBFQbCQvlhHMR9CTNlKCTLRy5YWFuRnG3durazqPCfeYLHXouS3MZW9h(ojbIiPbEQby4p4CfeYnmqfbKf5RtBY1ZCzySdf7T5mC)HVtsGisAGNAagEr(60MCJjxpoxbHCddurazr(60MC)DUiD9iKRN5Ejc5gtU2Y9A5(RCz4g9naoCrSXqs1nqBFQbCQvlhHMR9CTFIugyW9jIroYag1jv3aT9PgCaNRqYJp)FIOwTCe6bzNiwnaQg9ezlx1ak1jHXEPkxXZ1Jqixi5AlxRxiWVpnArOsYhg7LkFQbsQPc6elI)GZvqixXYLH)OwBa)oI1ODU2Zvqixg(JATb8EGkcidkLRGqUwVqGB5Wyu3Za4p4CHKR1le4womg19maEr(60MC9m3Bri3yY1wUxl3FLld3OVbWHlIngsQUbA7tnGtTA5i0CTNR9CHKRTCflxg(JATb8EGkcidkLRGqUmm2HI92CgU)W3jjqejnWtnad)bNRGqUFAnQLJ4mC)HVtsuYGyZYfsUHbQiGSiFDAtUINlsxpc5gtUxIqUXKRTCVwU)kxgUrFdGdxeBmKuDd02NAaNA1YrO5ApxbHCddurazr(60MC9mxgg7qXEBod3F47KeiIKg4PgGHxKVoTj3yY1JZvqi3WaveqwKVoTjxpZ9weYnMCTL71Y9x5YWn6BaC4IyJHKQBG2(ud4uRwocnx75A)ePmWG7t00mTAfm4(aoxHKh88)jIA1YrOhKDIy1aOA0ted)rT2aEpqfbKbLYfsU2Y9tRrTCeNH7p8DsIsgeBwUcc5YWyhk2BZzQCAgViFDAtUEMlsiKR9CHKRAaL6KWyVuLR45(hc5cjxgg7qXEBod3F47KeiIKg4PgGHxKVoTjxpZfjeorkdm4(ezaAzEfu6aoxH01F()erTA5i0dYory4tKHaNiLbgCFI(0AulhDI(u3JoreZnWgIpT09ATY9x5E95(tUkdm4MBaAfMI4eYj2dqsW4t5gtUILlXCdSH4tlDVwRC)vUECU)KRYadU5ElfiItiNypajbJpLBm5Ia)YC)jxdm5CsrQbqNOpTKT6tNi1a7bavre7aoxHKhD()erTA5i0dYorSAaun6jYwUtdOcg7uaHkddurazr(60MC9m3RLRGqU2Y16fc8s)Og)mYqrDSqKxKVoTjxpZfkdL7Rip3FLlJgxU2YvnGsDsySxQY9NCVfHCTNlKCTEHaV0pQXpJmuuhle5p4CTNR9CfeY1wUQbuQtcJ9svUXK7NwJA5iUAG9aGQiIL7VY16fcCI5gydjnyNw8I81Pn5gtUOyap8keL4GKCVM4GHD3ilYxNo3FL7L8)Yv8Cr6seYvqix1ak1jHXEPk3yY9tRrTCexnWEaqveXY9x5A9cboXCdSHKUxRfViFDAtUXKlkgWdVcrjoij3Rjoyy3nYI81PZ9x5Ej)VCfpxKUeHCTNlKCjMBGneFAP2iMlKCTLRTCflxgg7qXEBotLtZ4p4CfeYLH)OwBa)oI1ODUqYvSCzySdf7T5Kpm2lvslCJYFW5ApxbHCz4pQ1gW7bQiGmOuU2ZfsU2YvSCz4pQ1gW)OgicXkxbHCflxRxiWzQCAg)bNRGqUQbuQtcJ9svUINRhHqU2ZvqixRxiWzQCAgViFDAtUIN71NlKCflxRxiWl9JA8Zidf1Xcr(d(ePmWG7tKbOL5vqPd4C1LiC()erTA5i0dYorSAaun6jYwUwVqGtm3aBiP71AXFW5kiKRTCzI0ckzYnEUxMlKClIjslOKem(uUEM7F5ApxbHCzI0ckzYnEU3MR9CHKRclzIi29tKYadUprn5v6JX9bCU6sKo)FIOwTCe6bzNiwnaQg9ezlxRxiWjMBGnK09AT4p4CfeY1wUmrAbLm5gp3lZfsUfXePfuscgFkxpZ9VCTNRGqUmrAbLm5gp3BZ1EUqYvHLmre7(jszGb3NirQli9X4(aoxD5LN)pruRwoc9GSteRgavJEISLR1le4eZnWgs6ETw8hCUcc5AlxMiTGsMCJN7L5cj3IyI0ckjbJpLRN5(xU2ZvqixMiTGsMCJN7T5Apxi5QWsMiID)ePmWG7tu45CsFmUpGZvxE75)tKYadUprE1QgCjXbj5EnDIOwTCe6bzhW5QlV25)te1QLJqpi7eXQbq1ONiI5gydXNw6ETw5kiKlXCdSH4gStlztihKRGqUeZnWgIRnIYMqoixbHCTEHa3Rw1Gljoij3Rj(doxi5sm3aBi(0s3R1kxbHCTLR1le4mvonJxKVoTjxpZvzGb3CVLceXjKtShGKGXNYfsUwVqGZu50m(dox7NiLbgCFImaTctrhW5Ql)78)jszGb3NiVLceDIOwTCe6bzhW5Ql94Z)NiQvlhHEq2jszGb3NO61sLbgClDJbCICJbiB1Norb15aIQ3bCaNiukOph48)5kKo)FIugyW9jYGDAjTi1)erTA5i0dYoGZvxE()erTA5i0dYory4tKHaNiLbgCFI(0AulhDI(u3JorgyY5KaTGsad3a0kOoxUINls5cjxB5kwUa1rnGBaA5WfkNA1YrO5kiKlqDud4ga5CAjrRja4uRwocnx75kiKRbMCojqlOeWWnaTcQZLR45E5j6tlzR(0jAmsfthW5QBp)FIOwTCe6bzNim8jYqGtKYadUprFAnQLJorFQ7rNidm5CsGwqjGHBaAfMIYv8Cr6e9PLSvF6engjZr6hDaNRU25)te1QLJqpi7eXQbq1ONiB5kwUm8h1Ad49aveqgukxbHCflxgg7qXEBod3F47KeiIKg4PgGH)GZ1EUqY16fcCMkNMXFWNiLbgCFISOYq19PHEaNR(78)jIA1YrOhKDIy1aOA0tK1le4mvonJ)Gprkdm4(ebJbdUpGZvE85)tKYadUprpdjha5BoruRwoc9GSd4CLh88)jIA1YrOhKDIy1aOA0t0NwJA5i(yKkMorgqnmW5kKorkdm4(evVwQmWGBPBmGtKBmazR(0jsX0bCU66p)FIOwTCe6bzNiwnaQg9evVMc4ckXbJp5fxTeTi13AAuQ4uS9nWWe6jYaQHboxH0jszGb3NO61sLbgClDJbCICJbiB1NorOfP(wtJs1bCUYJo)FIOwTCe6bzNiwnaQg9evVMc4ckXTuN2msIds15Kartd1WPy7BGHj0tKbuddCUcPtKYadUpr1RLkdm4w6gd4e5gdq2QpDISWk4aoxHecN)pruRwoc9GSteRgavJEIC0h5Yv8C)dHtKYadUpr1RLkdm4w6gd4e5gdq2QpDImGd4CfsiD()erTA5i0dYory4tKHaNiLbgCFI(0AulhDI(u3JorWf9X9wkq0j6tlzR(0jcUOpP3sbIoGZviD55)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ebx0h3a0kmfDI(0s2QpDIGl6tAaAfMIoGZviD75)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ebx0h3a0Y8kO0j6tlzR(0jcUOpPbOL5vqPd4Cfsx78)jIA1YrOhKDIugyW9jQETuzGb3s3yaNi3yaYw9PteCrWkGjsAahWbCIqls9TMgLQZ)NRq68)jIA1YrOhKDIWWNidborkdm4(e9P1Owo6e9PUhDISLR1le4GXN8IRwIwK6Bnnkv8I81Pn5kEUqzOCFf55gtUiWrkxi5AlxI5gydXNwAHbIYvqixI5gydXNwAWoTYvqixI5gydXDVwlztihKR9CfeY16fcCW4tEXvlrls9TMgLkEr(60MCfpxLbgCZnaTctrCc5e7bijy8PCJjxe4iLlKCTLlXCdSH4tlDVwRCfeYLyUb2qCd2PLSjKdYvqixI5gydX1grztihKR9CTNRGqUILR1le4GXN8IRwIwK6Bnnkv8h8j6tlzR(0jYObscWYNHKgyY5oGZvxE()erTA5i0dYorSAaun6jYwUIL7NwJA5iUrdKeGLpdjnWKZLRGqU2Y16fc8s)Og)mYqrDSqKxKVoTjxpZfkdL7Rip3FLlJgxU2YvnGsDsySxQY9NCVfHCTNlKCTEHaV0pQXpJmuuhle5p4CTNR9CfeYvnGsDsySxQYv8C9ieorkdm4(ezaAzEfu6aoxD75)te1QLJqpi7eXQbq1ONiB5(P1OwoIZW9h(ojrjdInlxi5onGkyStbeQmmqfbKf5RtBYv8Cr6weYfsUILldJDOyVnNPYPz8IuueZvqixRxiWzQCAg)bNR9CHKRAaL6KWyVuLRN5EneYfsU2Y16fcCI5gydjDVwlEr(60MCfpxKqixbHCTEHaNyUb2qsd2PfViFDAtUINlsiKR9CfeYnmqfbKf5RtBY1ZCrcHtKYadUprmC)HVtsGisAGNAaMd4C11o)FIOwTCe6bzNiLbgCFIuufgmFK04vl)teRgavJEIelxumGROkmy(iPXRw(su1xHsCWWUpn0CHKRy5QmWGBUIQWG5JKgVA5lrvFfkXNwgCdurGCHKRTCflxumGROkmy(iPXRw(srK64GHDFAO5kiKlkgWvufgmFK04vlFPisD8I81Pn5kEU)LR9CfeYffd4kQcdMpsA8QLVev9vOe3au29C9m3BZfsUOyaxrvyW8rsJxT8LOQVcL4f5RtBY1ZCVnxi5IIbCfvHbZhjnE1YxIQ(kuIdg29PHEIyiYCKeOfucyoxH0bCU6VZ)NiQvlhHEq2jszGb3NiFmUdtrNiwnaQg9evuOiJi1Yr5cjxGwqjahm(KeGLOdLR45I0L5cjxB5AlxRxiWzQCAgViFDAtUIN7F5cjxB5A9cbEPFuJFgzOOowiYlYxN2KR45(xUcc5kwUwVqGx6h14NrgkQJfI8hCU2ZvqixXY16fcCMkNMXFW5kiKRAaL6KWyVuLRN5Elc5Apxi5AlxXY16fc87tJweQK8HXEPYNAGKAQGoXI4p4CfeYvnGsDsySxQY1ZCVfHCTNlKCvyjteXUNR9tedrMJKaTGsaZ5kKoGZvE85)te1QLJqpi7ePmWG7tK51HPOteRgavJEIkkuKrKA5OCHKlqlOeGdgFscWs0HYv8Cr6YCHKRTCTLR1le4mvonJxKVoTjxXZ9VCHKRTCTEHaV0pQXpJmuuhle5f5RtBYv8C)lxbHCflxRxiWl9JA8Zidf1Xcr(dox75kiKRy5A9cbotLtZ4p4CfeYvnGsDsySxQY1ZCVfHCTNlKCTLRy5A9cb(9Prlcvs(WyVu5tnqsnvqNyr8hCUcc5QgqPojm2lv56zU3IqU2ZfsUkSKjIy3Z1(jIHiZrsGwqjG5CfshW5kp45)te1QLJqpi7ePmWG7tKbqoNwYGtl6eXQbq1ONOIcfzePwokxi5c0ckb4GXNKaSeDOCfpxK84CHKRTCTLR1le4mvonJxKVoTjxXZ9VCHKRTCTEHaV0pQXpJmuuhle5f5RtBYv8C)lxbHCflxRxiWl9JA8Zidf1Xcr(dox75kiKRy5A9cbotLtZ4p4CfeYvnGsDsySxQY1ZCVfHCTNlKCTLRy5A9cb(9Prlcvs(WyVu5tnqsnvqNyr8hCUcc5QgqPojm2lv56zU3IqU2ZfsUkSKjIy3Z1(jIHiZrsGwqjG5CfshW5QR)8)jIA1YrOhKDIy1aOA0tKclzIi29tKYadUprbCXijoiBf8k6aox5rN)pruRwoc9GSteRgavJEISEHaNPYPz8h8jszGb3NOs)Og)mYqrDSq8aoxHecN)pruRwoc9GSteRgavJEISLRTCTEHaNyUb2qsd2PfViFDAtUINlsiKRGqUwVqGtm3aBiP71AXlYxN2KR45Iec5Apxi5YWyhk2BZzQCAgViFDAtUIN7TiKR9CfeYLHXouS3MZu50mErkkINiLbgCFIUpnArOsd8udWCaNRqcPZ)NiQvlhHEq2jIvdGQrpr2Y1wUwVqGFFA0IqLKpm2lv(udKutf0jwe)bNRGqUILld)rT2a(DeRr7CTNRGqUm8h1Ad49aveqgukxbHC)0AulhXhJuXuUcc5A9cbULdJrDpdG)GZfsUwVqGB5Wyu3Za4f5RtBY1ZCVeHCJjxB5ETC)vUmCJ(gahUi2yiP6gOTp1ao1QLJqZ1EU2ZfsUILR1le4mvonJ)GZfsU2YvSCz4pQ1gW7bQiGmOuUcc5YWyhk2BZz4(dFNKarK0ap1am8hCUcc5onGkyStbeQmmqfbKf5RtBY1ZCzySdf7T5mC)HVtsGisAGNAagEr(60MCJjxpoxbHCNgqfm2PacvggOIaYI81Pn5(7Cr66rixpZ9seYnMCTL71Y9x5YWn6BaC4IyJHKQBG2(ud4uRwocnx75A)ePmWG7teJCKbmQtQUbA7tn4aoxH0LN)pruRwoc9GSteRgavJEISLRTCTEHa)(0OfHkjFySxQ8PgiPMkOtSi(doxbHCflxg(JATb87iwJ25ApxbHCz4pQ1gW7bQiGmOuUcc5(P1OwoIpgPIPCfeY16fcClhgJ6Ega)bNlKCTEHa3YHXOUNbWlYxN2KRN5Elc5gtU2Y9A5(RCz4g9naoCrSXqs1nqBFQbCQvlhHMR9CTNlKCflxRxiWzQCAg)bNlKCTLRy5YWFuRnG3durazqPCfeYLHXouS3MZW9h(ojbIiPbEQby4p4CfeYDAavWyNciuzyGkcilYxN2KRN5YWyhk2BZz4(dFNKarK0ap1am8I81Pn5gtUECUcc5onGkyStbeQmmqfbKf5RtBY935I01JqUEM7TiKBm5Al3RL7VYLHB03a4WfXgdjv3aT9PgWPwTCeAU2Z1(jszGb3NOPzA1kyW9bCUcPBp)FIOwTCe6bzNim8jYqGtKYadUprFAnQLJorFQ7rNiB5kwUmm2HI92CMkNMXlsrrmxbHCfl3pTg1YrCgU)W3jjkzqSz5cjxg(JATb8EGkcidkLR9t0NwYw9PtKr)izaxsMkNMDaNRq6AN)pruRwoc9GSteg(eziWjszGb3NOpTg1YrNOp19OtKTCflxgg7qXEBotLtZ4fPOiMRGqUIL7NwJA5iod3F47KKHB0bm4oxi5YWFuRnG3durazqPCTFI(0s2QpDIm6hjd4sYu50Sd4Cfs)D()erTA5i0dYorSAaun6j6tRrTCeNH7p8DsYWn6agCNlKCvdOuNeg7LQC9m3RHWjszGb3NigU)W3jjqejnWtnaZbCUcjp(8)jIA1YrOhKDIy1aOA0teXCdSH4tl1gXCHKRclzIi29CHKRTCrXaUIQWG5JKgVA5lrvFfkXbd7(0qZvqixXYLH)OwBaVjwHD4cnx75cj3pTg1YrCJ(rYaUKmvon7ePmWG7tu4vikXbj5EnDaNRqYdE()erTA5i0dYorSAaun6jIH)OwBaVhOIaYGs5cj3pTg1YrCgU)W3jjkzqSz5cjx1ak1jHXEPkxXJN71qixi5YWyhk2BZz4(dFNKarK0ap1am8I81Pn56zUqzOCFf55(RCz04Y1wUQbuQtcJ9svU)K7TiKR9tKYadUprgGwMxbLoGZviD9N)pruRwoc9GSteRgavJEISLR1le4eZnWgs6ETw8hCUcc5AlxMiTGsMCJN7L5cj3IyI0ckjbJpLRN5(xU2ZvqixMiTGsMCJN7T5Apxi5QWsMiIDpxi5(P1OwoIB0psgWLKPYPzNiLbgCFIAYR0hJ7d4CfsE05)te1QLJqpi7eXQbq1ONiB5A9cboXCdSHKUxRf)bNlKCflxg(JATb87iwJ25kiKRTCTEHa)(0OfHkjFySxQ8PgiPMkOtSi(doxi5YWFuRnGFhXA0ox75kiKRTCzI0ckzYnEUxMlKClIjslOKem(uUEM7F5ApxbHCzI0ckzYnEU3MRGqUwVqGZu50m(dox75cjxfwYerS75cj3pTg1YrCJ(rYaUKmvon7ePmWG7tKi1fK(yCFaNRUeHZ)NiQvlhHEq2jIvdGQrpr2Y16fcCI5gydjDVwl(doxi5kwUm8h1Ad43rSgTZvqixB5A9cb(9Prlcvs(WyVu5tnqsnvqNyr8hCUqYLH)OwBa)oI1ODU2ZvqixB5YePfuYKB8CVmxi5wetKwqjjy8PC9m3)Y1EUcc5YePfuYKB8CVnxbHCTEHaNPYPz8hCU2ZfsUkSKjIy3ZfsUFAnQLJ4g9JKbCjzQCA2jszGb3NOWZ5K(yCFaNRUePZ)NiLbgCFI8Qvn4sIdsY9A6erTA5i0dYoGZvxE55)te1QLJqpi7eXQbq1ONiI5gydXNw6ETw5kiKlXCdSH4gStlztihKRGqUeZnWgIRnIYMqoixbHCTEHa3Rw1Gljoij3Rj(doxi5A9cboXCdSHKUxRf)bNRGqU2Y16fcCMkNMXlYxN2KRN5QmWGBU3sbI4eYj2dqsW4t5cjxRxiWzQCAg)bNR9tKYadUprgGwHPOd4C1L3E()ePmWG7tK3sbIoruRwoc9GSd4C1Lx78)jIA1YrOhKDIugyW9jQETuzGb3s3yaNi3yaYw9PtuqDoGO6DahWjsX05)ZviD()erTA5i0dYory4tKHaNiLbgCFI(0AulhDI(u3Jor2Y16fcCW4tEXvlrls9TMgLkEr(60MC9mxOmuUVI8CJjxe4iLRGqUwVqGdgFYlUAjArQV10OuXlYxN2KRN5QmWGBUbOvykItiNypajbJpLBm5IahPCHKRTCjMBGneFAP71ALRGqUeZnWgIBWoTKnHCqUcc5sm3aBiU2ikBc5GCTNR9CHKR1le4GXN8IRwIwK6Bnnkv8hCUqYTEnfWfuIdgFYlUAjArQV10OuXPy7BGHj0t0NwYw9PteArQV074CYG6CsCiCaNRU88)jIA1YrOhKDIy1aOA0tK1le4gGwb154ffkYisTCuUqY1wUgyY5KaTGsad3a0kOoxUEM7T5kiKRy5wVMc4ckXbJp5fxTeTi13AAuQ4uS9nWWeAU2ZfsU2YvSCRxtbCbL4oezAPgzWreyAOsOUXh2qCk2(gyycnxbHCbJpL7VZ9A)LR45A9cbUbOvqDoEr(60MCJj3lZ1(jszGb3NidqRG6ChW5QBp)FIOwTCe6bzNiwnaQg9evVMc4ckXbJp5fxTeTi13AAuQ4uS9nWWeAUqY1atoNeOfucy4gGwb15Yv845EBUqY1wUILR1le4GXN8IRwIwK6Bnnkv8hCUqY16fcCdqRG6C8IcfzePwokxbHCTL7NwJA5ioArQV074CYG6CsCiKlKCTLR1le4gGwb154f5RtBY1ZCVnxbHCnWKZjbAbLagUbOvqDUCfp3lZfsUa1rnGBaKZPLeTMaGtTA5i0CHKR1le4gGwb154f5RtBY1ZC)lx75Apx7NiLbgCFImaTcQZDaNRU25)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ePgqPojm2lv5kEUxpc56HY1wUiHqU)kxRxiWbJp5fxTeTi13AAuQ4gGYUNR9C9q5AlxRxiWnaTcQZXlYxN2K7VY92C)jxdm5CsrQbq5ApxpuU2Yffd4HxHOehKK71eViFDAtU)k3)Y1EUqY16fcCdqRG6C8h8j6tlzR(0jYa0kOoN0lUbYG6CsCiCaNR(78)jIA1YrOhKDIy1aOA0t0NwJA5ioArQV074CYG6CsCiKlKC)0AulhXnaTcQZj9IBGmOoNehcNiLbgCFImaTmVckDaNR84Z)NiQvlhHEq2jszGb3NiZRdtrNiwnaQg9evuOiJi1Yr5cjxGwqjahm(KeGLOdLR45I01Y1dLRbMCojqlOeWKBm5wKVoTjxi5QWsMiIDpxi5sm3aBi(0sTr8eXqK5ijqlOeWCUcPd4CLh88)jIA1YrOhKDIugyW9jsrvyW8rsJxT8prSAaun6jsSCbd7(0qZfsUILRYadU5kQcdMpsA8QLVev9vOeFAzWnqfbYvqixumGROkmy(iPXRw(su1xHsCdqz3Z1ZCVnxi5IIbCfvHbZhjnE1YxIQ(kuIxKVoTjxpZ92tedrMJKaTGsaZ5kKoGZvx)5)te1QLJqpi7ePmWG7tKpg3HPOteRgavJEIkkuKrKA5OCHKlqlOeGdgFscWs0HYv8CTLlsxl3yY1wUgyY5KaTGsad3a0kmfL7VYfj(F5Apx75(tUgyY5KaTGsatUXKBr(60MCHKRTCTLldJDOyVnNPYPz8IuueZvqixdm5CsGwqjGHBaAfMIY1ZCVnxbHCTLlXCdSH4tlnyNw5kiKlXCdSH4tlTWar5kiKlXCdSH4tlDVwRCHKRy5cuh1aUb)CsCqcerYaUidGtTA5i0CfeY16fcC4A8Xf6OoPwmThMe(5mAX)u3JYv845E5FiKR9CHKRTCnWKZjbAbLagUbOvykkxpZfjeY9x5AlxKYnMCbQJAah4DAPpg3go1QLJqZ1EU2ZfsUQbuQtcJ9svUIN7FiKRhkxRxiWnaTcQZXlYxN2K7VY1JZ1EUqYvSCTEHa)(0OfHkjFySxQ8PgiPMkOtSi(doxi5QWsMiIDpx7NigImhjbAbLaMZviDaNR8OZ)NiQvlhHEq2jIvdGQrpr2Y9tRrTCeNH7p8DsIsgeBwUqYDAavWyNciuzyGkcilYxN2KR45I0TiKlKCflxgg7qXEBotLtZ4fPOiMRGqUwVqGZu50m(dox75cjx1ak1jHXEPkxpZ9peYfsU2Y16fcCI5gydjDVwlEr(60MCfpxpoxbHCTEHaNyUb2qsd2PfViFDAtUIN71Y1EUcc5ggOIaYI81Pn56zUiHWjszGb3NigU)W3jjqejnWtnaZbCUcjeo)FIOwTCe6bzNiwnaQg9ePWsMiID)ePmWG7tuaxmsIdYwbVIoGZviH05)te1QLJqpi7eXQbq1ONiRxiWzQCAg)bFIugyW9jQ0pQXpJmuuhlepGZviD55)te1QLJqpi7eXQbq1ONiB5A9cbUbOvqDo(doxbHCvdOuNeg7LQCfp3)qix75cjxXY16fcCd2zadJ4p4CHKRy5A9cbotLtZ4p4CHKRTCflxg(JATb8EGkcidkLRGqUmm2HI92CgU)W3jjqejnWtnad)bNRGqUtdOcg7uaHkddurazr(60MC9mxgg7qXEBod3F47KeiIKg4PgGHxKVoTj3yY1JZvqi3PbubJDkGqLHbQiGSiFDAtU)oxKUEeY1ZCVeHCJjxB5ETC)vUmCJ(gahUi2yiP6gOTp1ao1QLJqZ1EU2prkdm4(eXihzaJ6KQBG2(udoGZviD75)te1QLJqpi7eXQbq1ONiB5A9cbUbOvqDo(doxbHCvdOuNeg7LQCfp3)qix75cjxXY16fcCd2zadJ4p4CHKRy5A9cbotLtZ4p4CHKRTCflxg(JATb8EGkcidkLRGqUmm2HI92CgU)W3jjqejnWtnad)bNRGqUtdOcg7uaHkddurazr(60MC9mxgg7qXEBod3F47KeiIKg4PgGHxKVoTj3yY1JZvqi3PbubJDkGqLHbQiGSiFDAtU)oxKUEeY1ZCVfHCJjxB5ETC)vUmCJ(gahUi2yiP6gOTp1ao1QLJqZ1EU2prkdm4(enntRwbdUpGZviDTZ)NiQvlhHEq2jszGb3NidGCoTKbNw0jIvdGQrprffkYisTCuUqYfm(KeGLOdLR45I0F5cjxdm5CsGwqjGHBaAfMIY1ZCVwUqYvHLmre7EUqY1wUwVqGZu50mEr(60MCfpxKqixbHCflxRxiWzQCAg)bNR9tedrMJKaTGsaZ5kKoGZvi935)te1QLJqpi7eXQbq1ONiI5gydXNwQnI5cjxfwYerS75cjxRxiWHRXhxOJ6KAX0Eys4NZOf)tDpkxpZ9Y)qixi5AlxumGROkmy(iPXRw(su1xHsCWWUpn0CfeYvSCz4pQ1gWBIvyhUqZvqixdm5CsGwqjGjxXZ9YCTFIugyW9jk8keL4GKCVMoGZvi5XN)pruRwoc9GSteRgavJEISEHah3eqKrctfJGbdU5p4CHKRTCTEHa3a0kOohVOqrgrQLJYvqix1ak1jHXEPkxXZ1Jqix7NiLbgCFImaTcQZDaNRqYdE()erTA5i0dYorSAaun6jIH)OwBaVhOIaYGs5cjxB5(P1OwoIZW9h(ojrjdInlxbHCzySdf7T5mvonJ)GZvqixRxiWzQCAg)bNR9CHKldJDOyVnNH7p8Dscersd8udWWlYxN2KRN5cLHY9vKN7VYLrJlxB5QgqPojm2lv5(tU)HqU2ZfsUwVqGBaAfuNJxKVoTjxpZ9ANiLbgCFImaTcQZDaNRq66p)FIOwTCe6bzNiwnaQg9eXWFuRnG3durazqPCHKRTC)0AulhXz4(dFNKOKbXMLRGqUmm2HI92CMkNMXFW5kiKR1le4mvonJ)GZ1EUqYLHXouS3MZW9h(ojbIiPbEQby4f5RtBY1ZCHYq5(kYZ9x5YOXLRTCvdOuNeg7LQC)j3Brix75cjxRxiWnaTcQZXFW5cjxI5gydXNwQnINiLbgCFImaTmVckDaNRqYJo)FIOwTCe6bzNiwnaQg9ez9cboUjGiJK5iTKFJzWn)bNRGqUILRbOvykIRWsMiIDpxbHCTLR1le4mvonJxKVoTjxpZ9VCHKR1le4mvonJ)GZvqixB5A9cbEPFuJFgzOOowiYlYxN2KRN5cLHY9vKN7VYLrJlxB5QgqPojm2lv5(tU3IqU2ZfsUwVqGx6h14NrgkQJfI8hCU2Z1EUqY9tRrTCe3a0kOoN0lUbYG6CsCiKlKCnWKZjbAbLagUbOvqDUC9m3Bprkdm4(ezaAzEfu6aoxDjcN)pruRwoc9GSteRgavJEISLlXCdSH4tl1gXCHKldJDOyVnNPYPz8I81Pn5kEU)HqUcc5AlxMiTGsMCJN7L5cj3IyI0ckjbJpLRN5(xU2ZvqixMiTGsMCJN7T5Apxi5QWsMiID)ePmWG7tutEL(yCFaNRUePZ)NiQvlhHEq2jIvdGQrpr2YLyUb2q8PLAJyUqYLHXouS3MZu50mEr(60MCfp3)qixbHCTLltKwqjtUXZ9YCHKBrmrAbLKGXNY1ZC)lx75kiKltKwqjtUXZ92CTNlKCvyjteXUFIugyW9jsK6csFmUpGZvxE55)te1QLJqpi7eXQbq1ONiB5sm3aBi(0sTrmxi5YWyhk2BZzQCAgViFDAtUIN7FiKRGqU2YLjslOKj345EzUqYTiMiTGssW4t56zU)LR9CfeYLjslOKj345EBU2ZfsUkSKjIy3prkdm4(efEoN0hJ7d4C1L3E()ePmWG7tKxTQbxsCqsUxtNiQvlhHEq2bCU6YRD()erTA5i0dYory4tKHaNiLbgCFI(0AulhDI(u3JorgyY5KaTGsad3a0kmfLR45ETCJj3GdJRCTLRVAauHO8tDpk3FY9seY1EUXKBWHXvU2Y16fcCdqlZRGssYhg7LkFQbCdqz3Z9NCVwU2prFAjB1NorgGwHPi50sd2P1bCU6Y)o)FIOwTCe6bzNiwnaQg9erm3aBiU71AjBc5GCfeYLyUb2qCTru2eYb5cj3pTg1Yr8Xizos)OCfeY16fcCI5gydjnyNw8I81Pn56zUkdm4MBaAfMI4eYj2dqsW4t5cjxRxiWjMBGnK0GDAXFW5kiKlXCdSH4tlnyNw5cjxXY9tRrTCe3a0kmfjNwAWoTYvqixRxiWzQCAgViFDAtUEMRYadU5gGwHPioHCI9aKem(uUqYvSC)0AulhXhJK5i9JYfsUwVqGZu50mEr(60MC9mxc5e7bijy8PCHKR1le4mvonJ)GZvqixRxiWl9JA8Zidf1Xcr(doxi5AGjNtksnakxXZfbUhNlKCTLRbMCojqlOeWKRNXZ92CfeYvSCbQJAa3GFojoibIizaxKbWPwTCeAU2ZvqixXY9tRrTCeFmsMJ0pkxi5A9cbotLtZ4f5RtBYv8CjKtShGKGXNorkdm4(e5TuGOd4C1LE85)tKYadUprgGwHPOte1QLJqpi7aoxDPh88)jIA1YrOhKDIugyW9jQETuzGb3s3yaNi3yaYw9PtuqDoGO6DahWjkOohqu9o)FUcPZ)NiQvlhHEq2jIvdGQrprILB9AkGlOe3sDAZijoivNtcennudNITVbgMqprkdm4(ezaAzEfu6aoxD55)te1QLJqpi7ePmWG7tK51HPOteRgavJEIqXaUpg3HPiEr(60MCfp3I81PnNigImhjbAbLaMZviDaNRU98)jszGb3NiFmUdtrNiQvlhHEq2bCaNid48)5kKo)FIOwTCe6bzNiLbgCFIuufgmFK04vl)teRgavJEIelxumGROkmy(iPXRw(su1xHsCWWUpn0CHKRy5QmWGBUIQWG5JKgVA5lrvFfkXNwgCdurGCHKRTCflxumGROkmy(iPXRw(srK64GHDFAO5kiKlkgWvufgmFK04vlFPisD8I81Pn5kEU)LR9CfeYffd4kQcdMpsA8QLVev9vOe3au29C9m3BZfsUOyaxrvyW8rsJxT8LOQVcL4f5RtBY1ZCVnxi5IIbCfvHbZhjnE1YxIQ(kuIdg29PHEIyiYCKeOfucyoxH0bCU6YZ)NiQvlhHEq2jIvdGQrpr2Y9tRrTCeNH7p8DsIsgeBwUqYDAavWyNciuzyGkcilYxN2KR45I0TiKlKCflxgg7qXEBotLtZ4fPOiMRGqUwVqGZu50m(dox75cjx1ak1jHXEPkxpZ9peYfsU2Y16fcCI5gydjDVwlEr(60MCfpxKqixbHCTEHaNyUb2qsd2PfViFDAtUINlsiKR9CfeYnmqfbKf5RtBY1ZCrcHtKYadUprmC)HVtsGisAGNAaMd4C1TN)pruRwoc9GStKYadUpr(yChMIorSAaun6jQOqrgrQLJYfsUaTGsaoy8jjalrhkxXZfPlZfsU2Y16fcCMkNMXlYxN2KR45(xUqY1wUwVqGx6h14NrgkQJfI8I81Pn5kEU)LRGqUILR1le4L(rn(zKHI6yHi)bNR9CfeYvSCTEHaNPYPz8hCUcc5QgqPojm2lv56zU3IqU2ZfsU2YvSCTEHa)(0OfHkjFySxQ8PgiPMkOtSi(doxbHCvdOuNeg7LQC9m3Brix75cjxfwYerS7NigImhjbAbLaMZviDaNRU25)te1QLJqpi7ePmWG7tK51HPOteRgavJEIkkuKrKA5OCHKlqlOeGdgFscWs0HYv8Cr6YCHKRTCTEHaNPYPz8I81Pn5kEU)LlKCTLR1le4L(rn(zKHI6yHiViFDAtUIN7F5kiKRy5A9cbEPFuJFgzOOowiYFW5ApxbHCflxRxiWzQCAg)bNRGqUQbuQtcJ9svUEM7TiKR9CHKRTCflxRxiWVpnArOsYhg7LkFQbsQPc6elI)GZvqix1ak1jHXEPkxpZ9weY1EUqYvHLmre7(jIHiZrsGwqjG5CfshW5Q)o)FIOwTCe6bzNiLbgCFImaY50sgCArNiwnaQg9evuOiJi1Yr5cjxGwqjahm(KeGLOdLR45IKhNlKCTLR1le4mvonJxKVoTjxXZ9VCHKRTCTEHaV0pQXpJmuuhle5f5RtBYv8C)lxbHCflxRxiWl9JA8Zidf1Xcr(dox75kiKRy5A9cbotLtZ4p4CfeYvnGsDsySxQY1ZCVfHCTNlKCTLRy5A9cb(9Prlcvs(WyVu5tnqsnvqNyr8hCUcc5QgqPojm2lv56zU3IqU2ZfsUkSKjIy3prmezosc0ckbmNRq6aox5XN)pruRwoc9GSteRgavJEIuyjteXUFIugyW9jkGlgjXbzRGxrhW5kp45)te1QLJqpi7eXQbq1ONiRxiWzQCAg)bFIugyW9jQ0pQXpJmuuhlepGZvx)5)te1QLJqpi7eXQbq1ONiB5AlxRxiWjMBGnK0GDAXlYxN2KR45Iec5kiKR1le4eZnWgs6ETw8I81Pn5kEUiHqU2ZfsUmm2HI92CMkNMXlYxN2KR45Elc5cjxB5A9cboCn(4cDuNulM2dtc)CgT4FQ7r56zUxEneYvqixXYTEnfWfuIdxJpUqh1j1IP9WKWpNrlofBFdmmHMR9CTNRGqUwVqGdxJpUqh1j1IP9WKWpNrl(N6EuUIhp3l9GiKRGqUmm2HI92CMkNMXlsrrmxi5Alx1ak1jHXEPkxXZ1JqixbHC)0AulhXhJuXuU2prkdm4(eDFA0IqLg4PgG5aox5rN)pruRwoc9GSteRgavJEISLRAaL6KWyVuLR456riKlKCTLR1le43NgTiuj5dJ9sLp1aj1ubDIfXFW5kiKRy5YWFuRnGFhXA0ox75kiKld)rT2aEpqfbKbLYvqi3pTg1Yr8XivmLRGqUwVqGB5Wyu3Za4p4CHKR1le4womg19maEr(60MC9m3lri3yY1wU2Y1JY9x5wVMc4ckXHRXhxOJ6KAX0Eys4NZOfNITVbgMqZ1EUXKRTCVwU)kxgUrFdGdxeBmKuDd02NAaNA1YrO5Apx75Apxi5kwUwVqGZu50m(doxi5AlxXYLH)OwBaVhOIaYGs5kiKldJDOyVnNH7p8Dscersd8udWWFW5kiK70aQGXofqOYWaveqwKVoTjxpZLHXouS3MZW9h(ojbIiPbEQby4f5RtBYnMC94CfeYDAavWyNciuzyGkcilYxN2K7VZfPRhHC9m3lri3yY1wUxl3FLld3OVbWHlIngsQUbA7tnGtTA5i0CTNR9tKYadUprmYrgWOoP6gOTp1Gd4CfsiC()erTA5i0dYorSAaun6jYwUQbuQtcJ9svUINRhHqUqY1wUwVqGFFA0IqLKpm2lv(udKutf0jwe)bNRGqUILld)rT2a(DeRr7CTNRGqUm8h1Ad49aveqgukxbHC)0AulhXhJuXuUcc5A9cbULdJrDpdG)GZfsUwVqGB5Wyu3Za4f5RtBY1ZCVfHCJjxB5Alxpk3FLB9AkGlOehUgFCHoQtQft7HjHFoJwCk2(gyycnx75gtU2Y9A5(RCz4g9naoCrSXqs1nqBFQbCQvlhHMR9CTNR9CHKRy5A9cbotLtZ4p4CHKRTCflxg(JATb8EGkcidkLRGqUmm2HI92CgU)W3jjqejnWtnad)bNRGqUtdOcg7uaHkddurazr(60MC9mxgg7qXEBod3F47KeiIKg4PgGHxKVoTj3yY1JZvqi3PbubJDkGqLHbQiGSiFDAtU)oxKUEeY1ZCVfHCJjxB5ETC)vUmCJ(gahUi2yiP6gOTp1ao1QLJqZ1EU2prkdm4(enntRwbdUpGZviH05)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ezlxXYLHXouS3MZu50mErkkI5kiKRy5(P1OwoIZW9h(ojrjdInlxi5YWFuRnG3durazqPCTFI(0s2QpDIm6hjd4sYu50Sd4CfsxE()erTA5i0dYorSAaun6jIyUb2q8PLAJyUqYvHLmre7EUqY16fcC4A8Xf6OoPwmThMe(5mAX)u3JY1ZCV8AiKlKCTLlkgWvufgmFK04vlFjQ6Rqjoyy3NgAUcc5kwUm8h1Ad4nXkSdxO5Apxi5(P1OwoIB0psgWLKPYPzNiLbgCFIcVcrjoij3RPd4Cfs3E()erTA5i0dYorSAaun6jY6fcCCtargjmvmcgm4M)GZfsUwVqGBaAfuNJxuOiJi1YrNiLbgCFImaTcQZDaNRq6AN)pruRwoc9GSteRgavJEISEHa3a0YHluEr(60MC9m3)YfsU2Y16fcCI5gydjnyNw8I81Pn5kEU)LRGqUwVqGtm3aBiP71AXlYxN2KR45(xU2ZfsUQbuQtcJ9svUINRhHWjszGb3NiM2mYjTEHWjY6fcYw9PtKbOLdxOhW5kK(78)jIA1YrOhKDIy1aOA0ted)rT2aEpqfbKbLYfsUFAnQLJ4mC)HVtsuYGyZYfsUmm2HI92CgU)W3jjqejnWtnadViFDAtUEMlugk3xrEU)kxgnUCTLRAaL6KWyVuL7p5Elc5A)ePmWG7tKbOL5vqPd4CfsE85)te1QLJqpi7eXQbq1ONiG6OgWnaY50sIwtaWPwTCeAUqYvSCbQJAa3a0YHluo1QLJqZfsUwVqGBaAfuNJxuOiJi1Yr5cjxB5A9cboXCdSHKUxRfViFDAtUINRhNlKCjMBGneFAP71ALlKCTLRy5wVMc4ckXHRXhxOJ6KAX0Eys4NZOfNA1YrO5kiKR1le4W14Jl0rDsTyApmj8Zz0I)PUhLRN5E5FiKR9CfeY1wUILB9AkGlOehUgFCHoQtQft7HjHFoJwCQvlhHMRGqUwVqGdxJpUqh1j1IP9WKWpNrl(N6EuUIhp3l)dHCTNlKCvdOuNeg7LQCfpxpcHCfeYffd4kQcdMpsA8QLVev9vOeViFDAtUIN71NRGqUkdm4MROkmy(iPXRw(su1xHs8PLb3aveix75cjxXYLHXouS3MZu50mErkkINiLbgCFImaTcQZDaNRqYdE()erTA5i0dYorSAaun6jY6fcCCtargjZrAj)gZGB(doxbHCTEHa)(0OfHkjFySxQ8PgiPMkOtSi(doxbHCTEHaNPYPz8hCUqY1wUwVqGx6h14NrgkQJfI8I81Pn56zUqzOCFf55(RCz04Y1wUQbuQtcJ9svU)K7TiKR9CHKR1le4L(rn(zKHI6yHi)bNRGqUILR1le4L(rn(zKHI6yHi)bNlKCflxgg7qXEBEPFuJFgzOOowiYlsrrmxbHCflxg(JATb8pQbIqSY1EUcc5QgqPojm2lv5kEUEec5cjxI5gydXNwQnINiLbgCFImaTmVckDaNRq66p)FIOwTCe6bzNiwnaQg9ebuh1aUbOLdxOCQvlhHMlKCTLR1le4gGwoCHYFW5kiKRAaL6KWyVuLR456riKR9CHKR1le4gGwoCHYnaLDpxpZ92CHKRTCTEHaNyUb2qsd2Pf)bNRGqUwVqGtm3aBiP71AXFW5Apxi5A9cboCn(4cDuNulM2dtc)CgT4FQ7r56zUx6brixi5Alxgg7qXEBotLtZ4f5RtBYv8CrcHCfeYvSC)0AulhXz4(dFNKmCJoGb35cjxg(JATb8EGkcidkLR9tKYadUprgGwMxbLoGZvi5rN)pruRwoc9GSteRgavJEIaQJAa3a0YHluo1QLJqZfsU2Y16fcCdqlhUq5p4CfeYvnGsDsySxQYv8C9ieY1EUqY16fcCdqlhUq5gGYUNRN5EBUqY1wUwVqGtm3aBiPb70I)GZvqixRxiWjMBGnK09AT4p4CTNlKCTEHahUgFCHoQtQft7HjHFoJw8p19OC9m3l9GiKlKCTLldJDOyVnNPYPz8I81Pn5kEUiHqUcc5kwUFAnQLJ4mC)HVtsuYGyZYfsUm8h1Ad49aveqgukx7NiLbgCFImaTmVckDaNRUeHZ)NiQvlhHEq2jIvdGQrpr2Y16fcCI5gydjDVwl(doxbHCTLltKwqjtUXZ9YCHKBrmrAbLKGXNY1ZC)lx75kiKltKwqjtUXZ92CTNlKCvyjteXUNlKC)0AulhXn6hjd4sYu50StKYadUprn5v6JX9bCU6sKo)FIOwTCe6bzNiwnaQg9ezlxRxiWjMBGnK09AT4p4CHKRy5YWFuRnGFhXA0oxbHCTLR1le43NgTiuj5dJ9sLp1aj1ubDIfXFW5cjxg(JATb87iwJ25ApxbHCTLltKwqjtUXZ9YCHKBrmrAbLKGXNY1ZC)lx75kiKltKwqjtUXZ92CfeY16fcCMkNMXFW5Apxi5QWsMiIDpxi5(P1OwoIB0psgWLKPYPzNiLbgCFIePUG0hJ7d4C1LxE()erTA5i0dYorSAaun6jYwUwVqGtm3aBiP71AXFW5cjxXYLH)OwBa)oI1ODUcc5AlxRxiWVpnArOsYhg7LkFQbsQPc6elI)GZfsUm8h1Ad43rSgTZ1EUcc5AlxMiTGsMCJN7L5cj3IyI0ckjbJpLRN5(xU2ZvqixMiTGsMCJN7T5kiKR1le4mvonJ)GZ1EUqYvHLmre7EUqY9tRrTCe3OFKmGljtLtZorkdm4(efEoN0hJ7d4C1L3E()ePmWG7tKxTQbxsCqsUxtNiQvlhHEq2bCU6YRD()erTA5i0dYorSAaun6jIyUb2q8PLUxRvUcc5sm3aBiUb70s2eYb5kiKlXCdSH4AJOSjKdYvqixRxiW9Qvn4sIdsY9AI)GZfsUwVqGtm3aBiP71AXFW5kiKRTCTEHaNPYPz8I81Pn56zUkdm4M7TuGioHCI9aKem(uUqY16fcCMkNMXFW5A)ePmWG7tKbOvyk6aoxD5FN)prkdm4(e5TuGOte1QLJqpi7aoxDPhF()erTA5i0dYorkdm4(evVwQmWGBPBmGtKBmazR(0jkOohqu9oGd4ebxeScyIKgW5)ZviD()erTA5i0dYorkdm4(e5JXDyk6eXQbq1ONOIcfzePwokxi5c0ckb4GXNKaSeDOCfpxKUmxi5AlxRxiWzQCAgViFDAtUIN7F5kiKRy5A9cbotLtZ4p4CfeYvnGsDsySxQY1ZCVfHCTNlKCvyjteXUFIyiYCKeOfucyoxH0bCU6YZ)NiQvlhHEq2jszGb3NiZRdtrNiwnaQg9evuOiJi1Yr5cjxGwqjahm(KeGLOdLR45I0L5cjxB5A9cbotLtZ4f5RtBYv8C)lxbHCflxRxiWzQCAg)bNRGqUQbuQtcJ9svUEM7TiKR9CHKRclzIi29tedrMJKaTGsaZ5kKoGZv3E()erTA5i0dYorkdm4(ezaKZPLm40IorSAaun6jQOqrgrQLJYfsUaTGsaoy8jjalrhkxXZfPlZfsU2Y16fcCMkNMXlYxN2KR45(xUcc5kwUwVqGZu50m(doxbHCvdOuNeg7LQC9m3Brix75cjxfwYerS7NigImhjbAbLaMZviDaNRU25)te1QLJqpi7eXQbq1ONifwYerS7NiLbgCFIc4IrsCq2k4v0bCU6VZ)NiQvlhHEq2jIvdGQrpr2YvnGsDsySxQYv8C9ieYvqixRxiWTCymQ7za8hCUqY16fcClhgJ6EgaViFDAtUEM7LECU2ZfsUILR1le4mvonJ)Gprkdm4(eXihzaJ6KQBG2(udoGZvE85)te1QLJqpi7eXQbq1ONiB5QgqPojm2lv5kEUEec5kiKR1le4womg19ma(doxi5A9cbULdJrDpdGxKVoTjxpZ9wpox75cjxXY16fcCMkNMXFWNiLbgCFIMMPvRGb3hW5kp45)te1QLJqpi7eHHprgcCIugyW9j6tRrTC0j6tDp6ejwUmm2HI92CMkNMXlsrr8e9PLSvF6ez0psgWLKPYPzhW5QR)8)jIA1YrOhKDIy1aOA0teXCdSH4tl1gXCHKRclzIi29CHK7NwJA5iUr)izaxsMkNMDIugyW9jk8keL4GKCVMoGZvE05)te1QLJqpi7eXQbq1ONiRxiWnaTC4cLxKVoTjxpZ1JZfsU2Y16fcCI5gydjnyNw8hCUcc5A9cboXCdSHKUxRf)bNR9CHKRAaL6KWyVuLR456riCIugyW9jIPnJCsRxiCISEHGSvF6ezaA5Wf6bCUcjeo)FIOwTCe6bzNiwnaQg9ezlxXYvJfvdG4gqr69PHknaTm8s775kiKR1le4mvonJxKVoTjxpZLqoXEascgFkxbHCflx4I(4gGwMxbLY1EUqY1wUwVqGZu50m(doxbHCvdOuNeg7LQCfpxpcHCHKlXCdSH4tl1gXCTFIugyW9jYa0Y8kO0bCUcjKo)FIOwTCe6bzNiwnaQg9ezlxXYvJfvdG4gqr69PHknaTm8s775kiKR1le4mvonJxKVoTjxpZLqoXEascgFkxbHCfl3pTg1YrC4I(KgGwMxbLY1EUqYfOoQbCdqlhUq5uRwocnxi5AlxRxiWnaTC4cL)GZvqix1ak1jHXEPkxXZ1Jqix75cjxRxiWnaTC4cLBak7EUEM7T5cjxB5A9cboXCdSHKgStl(doxbHCTEHaNyUb2qs3R1I)GZ1EUqYLHXouS3MZu50mEr(60MCfpxp4jszGb3NidqlZRGshW5kKU88)jIA1YrOhKDIy1aOA0tKTCflxnwunaIBafP3NgQ0a0YWlTVNRGqUwVqGZu50mEr(60MC9mxc5e7bijy8PCfeYvSCHl6JBaAzEfukx75cjxRxiWjMBGnK0GDAXlYxN2KR456bZfsUeZnWgIpT0GDALlKCflxG6OgWnaTC4cLtTA5i0CHKldJDOyVnNPYPz8I81Pn5kEUEWtKYadUprgGwMxbLoGZviD75)te1QLJqpi7eXQbq1ONiB5A9cboXCdSHKUxRf)bNRGqU2YLjslOKj345EzUqYTiMiTGssW4t56zU)LR9CfeYLjslOKj345EBU2ZfsUkSKjIy3ZfsUFAnQLJ4g9JKbCjzQCA2jszGb3NOM8k9X4(aoxH01o)FIOwTCe6bzNiwnaQg9ezlxRxiWjMBGnK09AT4p4CfeY1wUmrAbLm5gp3lZfsUfXePfuscgFkxpZ9VCTNRGqUmrAbLm5gp3BZvqixRxiWzQCAg)bNR9CHKRclzIi29CHK7NwJA5iUr)izaxsMkNMDIugyW9jsK6csFmUpGZvi935)te1QLJqpi7eXQbq1ONiB5A9cboXCdSHKUxRf)bNRGqU2YLjslOKj345EzUqYTiMiTGssW4t56zU)LR9CfeYLjslOKj345EBUcc5A9cbotLtZ4p4CTNlKCvyjteXUNlKC)0AulhXn6hjd4sYu50StKYadUprHNZj9X4(aoxHKhF()ePmWG7tKxTQbxsCqsUxtNiQvlhHEq2bCUcjp45)te1QLJqpi7eXQbq1ONiB5QXIQbqCdOi9(0qLgGwgEP99CHKR1le4mvonJxKVoTjxXZLqoXEascgFkxi5cx0h3BPar5ApxbHCTLRy5QXIQbqCdOi9(0qLgGwgEP99CfeY16fcCMkNMXlYxN2KRN5siNypajbJpLRGqUILlCrFCdqRWuuU2ZfsU2YLyUb2q8PLUxRvUcc5sm3aBiUb70s2eYb5kiKlXCdSH4AJOSjKdYvqixRxiW9Qvn4sIdsY9AI)GZfsUwVqGtm3aBiP71AXFW5kiKRTCTEHaNPYPz8I81Pn56zUkdm4M7TuGioHCI9aKem(uUqY16fcCMkNMXFW5Apx75kiKRTC1yr1aioQ6TNgQ08AEP99Cfp3lZfsUwVqGtm3aBiPb70IxKVoTjxXZ9VCHKRy5A9cboQ6TNgQ08AEr(60MCfpxLbgCZ9wkqeNqoXEascgFkx7NiLbgCFImaTctrhW5kKU(Z)NiQvlhHEq2jIvdGQrpra1rnGBaKZPLeTMaGtTA5i0CHKR1le4gGwb154ffkYisTCuUqYnmqfbKf5RtBYv8CTEHa3a0kOohh9vkyWDUqY1wUILlXCdSH4tl1gXCfeY16fcCdqlZRGssYhg7LkFQb8hCU2prkdm4(ezaAfuN7aoxHKhD()ePmWG7tK3sbIoruRwoc9GSd4C1LiC()erTA5i0dYorkdm4(evVwQmWGBPBmGtKBmazR(0jkOohqu9oGd4aorFuzgCFU6seUebKqcbKorE1QNgQ5e5bySXydx5b(kpq8W5M7)IOChFyCbYnGRC9aIwK6BnnkvEaZTOy7Bkcnxd2NYvFaSVci0CzI0gkz45fx30uUx6HZn2X9hvacn3OXp2Z1GyduKN7VZfGZ96EAUOZ3ygCNlgMkfGRCT9J9CTHeYTZZlUUPPCrcjpCUXoU)OcqO5gn(XEUgeBGI8C)9VZfGZ96EAU(y0N7zYfdtLcWvU2(T9CTHeYTZZlUUPPCr6spCUXoU)OcqO5gn(XEUgeBGI8C)9VZfGZ96EAU(y0N7zYfdtLcWvU2(T9CTHeYTZZlUUPPCrYd6HZn2X9hvacn3OXp2Z1GyduKN7VZfGZ96EAUOZ3ygCNlgMkfGRCT9J9CTHeYTZZlYl8am2ySHR8aFLhiE4CZ9FruUJpmUa5gWvUEaHlIH9TuGhWClk2(MIqZ1G9PC1ha7RacnxMiTHsgEEX1nnL7FE4CJDC)rfGqZnA8J9Cni2af55(7Cb4CVUNMl68nMb35IHPsb4kxB)ypxBxIC788I8cpaJngB4kpWx5bIho3C)xeL74dJlqUbCLRhqftEaZTOy7Bkcnxd2NYvFaSVci0CzI0gkz45fx30uUx6HZn2X9hvacn3OXp2Z1GyduKN7V)DUaCUx3tZ1hJ(CptUyyQuaUY12VTNRnKqUDEEX1nnL718W5g74(JkaHMB04h75AqSbkYZ935cW5EDpnx05BmdUZfdtLcWvU2(XEU2qc5255fx30uUxVho3yh3Fubi0CJg)ypxdInqrEU)oxao3R7P5IoFJzWDUyyQuaUY12p2Z1gsi3opV46MMYfPl9W5g74(JkaHMB04h75AqSbkYZ93)oxao3R7P56JrFUNjxmmvkax5A732Z1gsi3opV46MMYfPB9W5g74(JkaHMB04h75AqSbkYZ93)oxao3R7P56JrFUNjxmmvkax5A732Z1gsi3opV46MMYfjpOho3yh3Fubi0CJg)ypxdInqrEU)oxao3R7P5IoFJzWDUyyQuaUY12p2Z1gsi3opV46MMYfPR3dNBSJ7pQaeAUrJFSNRbXgOip3FNlaN7190CrNVXm4oxmmvkax5A7h75AdjKBNNxCDtt5IKh5HZn2X9hvacn3OXp2Z1GyduKN7VZfGZ96EAUOZ3ygCNlgMkfGRCT9J9CTHeYTZZlUUPPCV8AE4CJDC)rfGqZnA8J9Cni2af55(7Cb4CVUNMl68nMb35IHPsb4kxB)ypxBxIC788I8cpaJngB4kpWx5bIho3C)xeL74dJlqUbCLRhqdWdyUffBFtrO5AW(uU6dG9vaHMltK2qjdpV46MMY1J8W5g74(JkaHMB04h75AqSbkYZ93)oxao3R7P56JrFUNjxmmvkax5A732Z1gsi3opV46MMYfje8W5g74(JkaHMB04h75AqSbkYZ93)oxao3R7P56JrFUNjxmmvkax5A732Z1gsi3opV46MMYfP)8W5g74(JkaHMB04h75AqSbkYZ935cW5EDpnx05BmdUZfdtLcWvU2(XEU2qc5255fx30uUi5b9W5g74(JkaHMB04h75AqSbkYZ935cW5EDpnx05BmdUZfdtLcWvU2(XEU2qc5255f5fEagBm2WvEGVYdepCU5(Vik3XhgxGCd4kxpGwyf4bm3IITVPi0CnyFkx9bW(kGqZLjsBOKHNxCDtt5EPho3yh3Fubi0CJg)ypxdInqrEU)oxao3R7P5IoFJzWDUyyQuaUY12p2Z12Li3opV46MMYfP)8W5g74(JkaHMB04h75AqSbkYZ93)oxao3R7P56JrFUNjxmmvkax5A732Z1gsi3opV46MMYfPR3dNBSJ7pQaeAUrJFSNRbXgOip3FNlaN7190CrNVXm4oxmmvkax5A7h75A7wKBNNxCDtt5IKh5HZn2X9hvacn3OXp2Z1GyduKN7VZfGZ96EAUOZ3ygCNlgMkfGRCT9J9CTHeYTZZlYl8a7dJlaHM71NRYadUZ1ngGHNxCImWe7CfsiC5jcUWHXrNOyZCrM60Mr56bQ6nO5fXM5Ef(J8TOkxp(MCVeHlriViVi2m3yxK2qjJhoVi2mxpuUXgrrj0CJWoTYfzK6ZZlInZ1dLBSlsBOeAUaTGsa5eYLPgYKlaNldrMJKaTGsadpVi2mxpuUXgiF8hHM7RBIrgJwiM7NwJA5itU2goXVjx4I(KgGwMxbLY1djEUWf9XnaTmVckzNNxKxOmWGBdhUig23sbX9X4((0YaU8ZlugyWTHdxed7BPGyI)J3sbIYlugyWTHdxed7BPGyI)J3sbIYlugyWTHdxed7BPGyI)JbOvykkVqzGb3goCrmSVLcIj(pFAnQLJUPvFkod3F47KeLmi2SB(u3JIBHngibhgx2SfgOIaYI81PnEOlrW(Vr6seSlEWHXLnBHbQiGSiFDAJh6Y)8q2qcHFbuh1a(0mTAfm4MtTA5iu7EiBx7xmCJ(gahUi2yiP6gOTp1ao1QLJqTB)3iD9iypViVi2mxpqJCI9aeAU0hviMly8PCbIOCvgax5oMC1pDCQLJ45fkdm42e3GDAjTi1pVqzGb3MyI)ZNwJA5OBA1NIpgPIPB(u3JIBGjNtc0ckbmCdqRG6CIJeeBIbuh1aUbOLdxOCQvlhHkiauh1aUbqoNws0Acao1QLJqTliyGjNtc0ckbmCdqRG6CIFzEHYadUnXe)NpTg1Yr30QpfFmsMJ0p6Mp19O4gyY5KaTGsad3a0kmfjos5fkdm42et8FSOYq19PHEZeIBtmg(JATb8EGkcidkjiigdJDOyVnNH7p8Dscersd8udWWFW2Hy9cbotLtZ4p48cLbgCBIj(pWyWG7BMqCRxiWzQCAg)bNxOmWGBtmX)5zi5aiFtEHYadUnXe)N61sLbgClDJbCtR(uCft3ya1WaXr6Mje)tRrTCeFmsft5fkdm42et8FQxlvgyWT0ngWnT6tXrls9TMgLQBmGAyG4iDZeIxVMc4ckXbJp5fxTeTi13AAuQ4uS9nWWeAEHYadUnXe)N61sLbgClDJbCtR(uClScUXaQHbIJ0ntiE9AkGlOe3sDAZijoivNtcennudNITVbgMqZlugyWTjM4)uVwQmWGBPBmGBA1NIBa3mH4o6JCI)hc5fkdm42et8F(0AulhDtR(uC4I(KElfi6Mp19O4Wf9X9wkquEHYadUnXe)NpTg1Yr30QpfhUOpPbOvyk6Mp19O4Wf9XnaTctr5fkdm42et8F(0AulhDtR(uC4I(KgGwMxbLU5tDpkoCrFCdqlZRGs5fkdm42et8FQxlvgyWT0ngWnT6tXHlcwbmrsdiViVqzGb3gUIP4FAnQLJUPvFkoArQV074CYG6CsCiCZN6EuCBwVqGdgFYlUAjArQV10OuXlYxN24jugk3xrEmiWrsqW6fcCW4tEXvlrls9TMgLkEr(60gpvgyWn3a0kmfXjKtShGKGXNIbbosqSrm3aBi(0s3R1sqGyUb2qCd2PLSjKdeeiMBGnexBeLnHCGD7qSEHahm(KxC1s0IuFRPrPI)GHuVMc4ckXbJp5fxTeTi13AAuQ4uS9nWWeAEHYadUnCftXe)hdqRG6C3mH4wVqGBaAfuNJxuOiJi1YrqSzGjNtc0ckbmCdqRG6CEERGGy1RPaUGsCW4tEXvlrls9TMgLkofBFdmmHAhInXQxtbCbL4oezAPgzWreyAOsOUXh2qCk2(gyycvqam(0V)91(tCRxiWnaTcQZXlYxN2eZL2ZlugyWTHRykM4)yaAfuN7MjeVEnfWfuIdgFYlUAjArQV10OuXPy7BGHjuigyY5KaTGsad3a0kOoN4XVfInXSEHahm(KxC1s0IuFRPrPI)GHy9cbUbOvqDoErHImIulhjiy7tRrTCehTi1x6DCozqDojoeGyZ6fcCdqRG6C8I81PnEERGGbMCojqlOeWWnaTcQZj(LqaQJAa3aiNtljAnbaNA1YrOqSEHa3a0kOohViFDAJN)z3U98cLbgCB4kMIj(pFAnQLJUPvFkUbOvqDoPxCdKb15K4q4Mp19O4QbuQtcJ9sL4xpcEiBiHWVSEHahm(KxC1s0IuFRPrPIBak7UDpKnRxiWnaTcQZXlYxN28RB)TbMCoPi1ai7EiBOyap8keL4GKCVM4f5RtB(1F2Hy9cbUbOvqDo(doVqzGb3gUIPyI)JbOL5vqPBMq8pTg1YrC0IuFP3X5Kb15K4qaYNwJA5iUbOvqDoPxCdKb15K4qiVqzGb3gUIPyI)J51HPOByiYCKeOfucyIJ0ntiErHImIulhbbOfucWbJpjbyj6qIJ018qgyY5KaTGsatmf5RtBGOWsMiIDhcXCdSH4tl1gX8cLbgCB4kMIj(pkQcdMpsA8QL)nmezosc0ckbmXr6MjexmWWUpnuiIPmWGBUIQWG5JKgVA5lrvFfkXNwgCdurabbumGROkmy(iPXRw(su1xHsCdqz398wiOyaxrvyW8rsJxT8LOQVcL4f5RtB8828cLbgCB4kMIj(p(yChMIUHHiZrsGwqjGjos3mH4ffkYisTCeeGwqjahm(KeGLOdjUnKUwm2mWKZjbAbLagUbOvyk6xiX)ZU9FBGjNtc0ckbmXuKVoTbInBmm2HI92CMkNMXlsrruqWatoNeOfucy4gGwHPipVvqWgXCdSH4tlnyNwcceZnWgIpT0cdejiqm3aBi(0s3R1cIya1rnGBWpNehKarKmGlYa4uRwocvqW6fcC4A8Xf6OoPwmThMe(5mAX)u3Jep(L)HGDi2mWKZjbAbLagUbOvykYtKq4x2qkgG6OgWbENw6JXTHtTA5iu72HOgqPojm2lvI)hcEiRxiWnaTcQZXlYxN28lp2oeXSEHa)(0OfHkjFySxQ8PgiPMkOtSi(dgIclzIi2D75fkdm42Wvmft8Fy4(dFNKarK0ap1am3mH42(0AulhXz4(dFNKOKbXMbzAavWyNciuzyGkcilYxN2ios3IaeXyySdf7T5mvonJxKIIOGG1le4mvonJ)GTdrnGsDsySxQ88peGyZ6fcCI5gydjDVwlEr(60gX9ybbRxiWjMBGnK0GDAXlYxN2i(1SliegOIaYI81PnEIec5fkdm42Wvmft8Fc4IrsCq2k4v0ntiUclzIi298cLbgCB4kMIj(pL(rn(zKHI6yH4ntiU1le4mvonJ)GZlugyWTHRykM4)WihzaJ6KQBG2(udUzcXTz9cbUbOvqDo(dwqqnGsDsySxQe)peSdrmRxiWnyNbmmI)GHiM1le4mvonJ)GHytmg(JATb8EGkcidkjiWWyhk2BZz4(dFNKarK0ap1am8hSGW0aQGXofqOYWaveqwKVoTXtgg7qXEBod3F47KeiIKg4PgGHxKVoTjgpwqyAavWyNciuzyGkcilYxN287FJ01JGNxIqm2U2Vy4g9naoCrSXqs1nqBFQbCQvlhHA3EEHYadUnCftXe)NPzA1kyW9ntiUnRxiWnaTcQZXFWccQbuQtcJ9sL4)HGDiIz9cbUb7mGHr8hmeXSEHaNPYPz8hmeBIXWFuRnG3durazqjbbgg7qXEBod3F47KeiIKg4PgGH)GfeMgqfm2PacvggOIaYI81PnEYWyhk2BZz4(dFNKarK0ap1am8I81PnX4XcctdOcg7uaHkddurazr(60MF)BKUEe88weIX21(fd3OVbWHlIngsQUbA7tnGtTA5iu72ZlugyWTHRykM4)yaKZPLm40IUHHiZrsGwqjGjos3mH4ffkYisTCeeW4tsawIoK4i9hedm5CsGwqjGHBaAfMI88AquyjteXUdXM1le4mvonJxKVoTrCKqqqqmRxiWzQCAg)bBpVqzGb3gUIPyI)t4vikXbj5EnDZeItm3aBi(0sTreIclzIi2DiwVqGdxJpUqh1j1IP9WKWpNrl(N6EKNx(hcqSHIbCfvHbZhjnE1YxIQ(kuIdg29PHkiigd)rT2aEtSc7WfQGGbMCojqlOeWi(L2ZlugyWTHRykM4)yaAfuN7Mje36fcCCtargjmvmcgm4M)GHyZ6fcCdqRG6C8IcfzePwosqqnGsDsySxQe3JqWEEHYadUnCftXe)hdqRG6C3mH4m8h1Ad49aveqgucITpTg1YrCgU)W3jjkzqSzccmm2HI92CMkNMXFWccwVqGZu50m(d2oegg7qXEBod3F47KeiIKg4PgGHxKVoTXtOmuUVI8FXOXztnGsDsySxQ(9FiyhI1le4gGwb154f5RtB88A5fkdm42Wvmft8FmaTmVckDZeIZWFuRnG3durazqji2(0AulhXz4(dFNKOKbXMjiWWyhk2BZzQCAg)bliy9cbotLtZ4py7qyySdf7T5mC)HVtsGisAGNAagEr(60gpHYq5(kY)fJgNn1ak1jHXEP633IGDiwVqGBaAfuNJ)GHqm3aBi(0sTrmVqzGb3gUIPyI)JbOL5vqPBMqCRxiWXnbezKmhPL8BmdU5pybbXmaTctrCfwYerS7cc2SEHaNPYPz8I81PnE(heRxiWzQCAg)bliyZ6fc8s)Og)mYqrDSqKxKVoTXtOmuUVI8FXOXztnGsDsySxQ(9TiyhI1le4L(rn(zKHI6yHi)bB3oKpTg1YrCdqRG6CsV4gidQZjXHaedm5CsGwqjGHBaAfuNZZBZlugyWTHRykM4)0KxPpg33mH42iMBGneFAP2icHHXouS3MZu50mEr(60gX)dbbbBmrAbLmXVesrmrAbLKGXN88p7ccmrAbLmXV1oefwYerS75fkdm42Wvmft8FePUG0hJ7BMqCBeZnWgIpTuBeHWWyhk2BZzQCAgViFDAJ4)HGGGnMiTGsM4xcPiMiTGssW4tE(NDbbMiTGsM43AhIclzIi298cLbgCB4kMIj(pHNZj9X4(Mje3gXCdSH4tl1grimm2HI92CMkNMXlYxN2i(FiiiyJjslOKj(LqkIjslOKem(KN)zxqGjslOKj(T2HOWsMiIDpVqzGb3gUIPyI)JxTQbxsCqsUxt5fkdm42Wvmft8F(0AulhDtR(uCdqRWuKCAPb706Mp19O4gyY5KaTGsad3a0kmfj(1Ij4W4YMVAauHO8tDp63xIG9ycomUSz9cbUbOL5vqjj5dJ9sLp1aUbOS7)(A2ZlugyWTHRykM4)4TuGOBMqCI5gydXDVwlztihiiqm3aBiU2ikBc5aiFAnQLJ4JrYCK(rccwVqGtm3aBiPb70IxKVoTXtLbgCZnaTctrCc5e7bijy8jiwVqGtm3aBiPb70I)GfeiMBGneFAPb70cIyFAnQLJ4gGwHPi50sd2PLGG1le4mvonJxKVoTXtLbgCZnaTctrCc5e7bijy8jiI9P1OwoIpgjZr6hbX6fcCMkNMXlYxN24jHCI9aKem(eeRxiWzQCAg)bliy9cbEPFuJFgzOOowiYFWqmWKZjfPgajocCpgIndm5CsGwqjGXZ43kiigqDud4g8ZjXbjqejd4Imao1QLJqTlii2NwJA5i(yKmhPFeeRxiWzQCAgViFDAJ4eYj2dqsW4t5fkdm42Wvmft8FmaTctr5fkdm42Wvmft8FQxlvgyWT0ngWnT6tXdQZbevV8I8cLbgCB4wyfeV0pQXpJmuuhleVzcXTEHaNPYPz8hCEHYadUnClScIj(pFAnQLJUPvFkod3F47KeLmi2SB(u3JIhCyCzZ20aQGXofqOYWaveqwKVoTXdDjc2)nsxIGDXdomUSzBAavWyNciuzyGkcilYxN24HU8ppKnKq4xa1rnGpntRwbdU5uRwoc1UhY21(fd3OVbWHlIngsQUbA7tnGtTA5iu72)nsxpc2ZlugyWTHBHvqmX)5tRrTC0nT6tXz1aAm4bFZN6EuCXSEHa3sDAZijoivNtcennuJSvWRi(dgIywVqGBPoTzKehKQZjbIMgQrQftBI)GZlugyWTHBHvqmX)rrvyW8rsJxT8VHHiZrsGwqjGjos3mH4wVqGBPoTzKehKQZjbIMgQr2k4ve3au2D5N6EKNxdbiwVqGBPoTzKehKQZjbIMgQrQftBIBak7U8tDpYZRHaeBIHIbCfvHbZhjnE1YxIQ(kuIdg29PHcrmLbgCZvufgmFK04vlFjQ6Rqj(0YGBGkcaXMyOyaxrvyW8rsJxT8LIi1Xbd7(0qfeqXaUIQWG5JKgVA5lfrQJxKVoTr8BTliGIbCfvHbZhjnE1YxIQ(kuIBak7UN3cbfd4kQcdMpsA8QLVev9vOeViFDAJN)bbfd4kQcdMpsA8QLVev9vOehmS7td1EEHYadUnClScIj(pmC)HVtsGisAGNAaMBMqCBFAnQLJ4mC)HVtsuYGyZGmnGkyStbeQmmqfbKf5RtBehPBraIymm2HI92CMkNMXlsrruqW6fcCMkNMXFW2HyZ6fcCl1PnJK4GuDojq00qnYwbVI4gGYUl)u3JI)hcccwVqGBPoTzKehKQZjbIMgQrQftBIBak7U8tDpk(FiyxqimqfbKf5RtB8ejeYlugyWTHBHvqmX)HPnJCsRxiCtR(uCdqlhUqVzcXTz9cbUL60MrsCqQoNeiAAOgzRGxr8I81PnIFn(FccwVqGBPoTzKehKQZjbIMgQrQftBIxKVoTr8RX)Zoe1ak1jHXEPs84EecqSXWyhk2BZzQCAgViFDAJ4EqbbBmm2HI92CYhg7LkPfUr5f5RtBe3dcrmRxiWVpnArOsYhg7LkFQbsQPc6elI)GHWWFuRnGFhXA02U98cLbgCB4wyfet8FmaTmVckDZeIl2NwJA5ioRgqJbpyi2y4pQ1gW7bQiGmOKGadJDOyVnNPYPz8I81PnI7bfeSXWyhk2BZjFySxQKw4gLxKVoTrCpieXSEHa)(0OfHkjFySxQ8PgiPMkOtSi(dgcd)rT2a(DeRrB72ZlugyWTHBHvqmX)Xa0Y8kO0ntiUngg7qXEBod3F47KeiIKg4PgGH)GHy7tRrTCeNH7p8DsIsgeBMGadJDOyVnNPYPz8I81PnE(ND7qudOuNeg7LkX)dbim8h1Ad49aveqgukVqzGb3gUfwbXe)hZRdtr3WqK5ijqlOeWehPBMq8IcfzePwoccqlOeGdgFscWs0HehjpgIclzIi2Di2(0AulhXz1aAm4bliytnGsDsySxQ88weGiM1le4mvonJ)GTliWWyhk2BZzQCAgViffr75fkdm42WTWkiM4)4JXDyk6ggImhjbAbLaM4iDZeIxuOiJi1YrqaAbLaCW4tsawIoK4iDl)pikSKjIy3Hy7tRrTCeNvdOXGhSGGn1ak1jHXEPYZBraIywVqGZu50m(d2UGadJDOyVnNPYPz8IuueTdrmRxiWVpnArOsYhg7LkFQbsQPc6elI)GZlugyWTHBHvqmX)XaiNtlzWPfDddrMJKaTGsatCKUzcXlkuKrKA5iiaTGsaoy8jjalrhsCK84ykYxN2arHLmre7oeBFAnQLJ4SAang8GfeudOuNeg7LkpVfbbbgg7qXEBotLtZ4fPOiApVqzGb3gUfwbXe)NaUyKehKTcEfDZeIRWsMiIDpVqzGb3gUfwbXe)NWRquIdsY9A6Mje3gXCdSH4tl1grbbI5gydXnyNwYPLijiqm3aBiU71AjNwIKDi2eJH)OwBaVhOIaYGscc2udOuNeg7Lkp9O)Gy7tRrTCeNvdOXGhSGGAaL6KWyVu55Tiii8P1OwoIpgPIj7qS9P1OwoIZW9h(ojrjdIndIymm2HI92CgU)W3jjqejnWtnad)blii2NwJA5iod3F47KeLmi2miIXWyhk2BZzQCAg)bB3UDi2yySdf7T5mvonJxKVoTr8BrqqqnGsDsySxQe3JqacdJDOyVnNPYPz8hmeBmm2HI92CYhg7LkPfUr5f5RtB8uzGb3CdqRWueNqoXEascgFsqqmg(JATb87iwJ22fecdurazr(60gprcb7qSHIbCfvHbZhjnE1YxIQ(kuIxKVoTr8Rjiigd)rT2aEtSc7WfQ98cLbgCB4wyfet8FUpnArOsd8udWCZeIBJyUb2qC3R1s2eYbcceZnWgIBWoTKnHCGGaXCdSH4AJOSjKdeeSEHa3sDAZijoivNtcennuJSvWRiEr(60gXVg)pbbRxiWTuN2msIds15Kartd1i1IPnXlYxN2i(14)jiOgqPojm2lvI7riaHHXouS3MZu50mErkkI2HyJHXouS3MZu50mEr(60gXVfbbbgg7qXEBotLtZ4fPOiAxqimqfbKf5RtB8ejeYlugyWTHBHvqmX)HroYag1jv3aT9PgCZeIBtnGsDsySxQe3JqaInRxiWVpnArOsYhg7LkFQbsQPc6elI)GfeeJH)OwBa)oI1OTDbbg(JATb8EGkcidkjiy9cbULdJrDpdG)GHy9cbULdJrDpdGxKVoTXZlrigBx7xmCJ(gahUi2yiP6gOTp1ao1QLJqTBhInXy4pQ1gW7bQiGmOKGadJDOyVnNH7p8Dscersd8udWWFWccHbQiGSiFDAJNmm2HI92CgU)W3jjqejnWtnadViFDAtmESGqyGkcilYxN287FJ01JGNxIqm2U2Vy4g9naoCrSXqs1nqBFQbCQvlhHA3EEHYadUnClScIj(ptZ0QvWG7BMqCBQbuQtcJ9sL4EecqSz9cb(9Prlcvs(WyVu5tnqsnvqNyr8hSGGym8h1Ad43rSgTTliWWFuRnG3durazqjbbRxiWTCymQ7za8hmeRxiWTCymQ7za8I81PnEElcXy7A)IHB03a4WfXgdjv3aT9PgWPwTCeQD7qSjgd)rT2aEpqfbKbLeeyySdf7T5mC)HVtsGisAGNAag(dwq4tRrTCeNH7p8DsIsgeBgKWaveqwKVoTrCKUEeI5seIX21(fd3OVbWHlIngsQUbA7tnGtTA5iu7ccHbQiGSiFDAJNmm2HI92CgU)W3jjqejnWtnadViFDAtmESGqyGkcilYxN245TieJTR9lgUrFdGdxeBmKuDd02NAaNA1YrO2TNxOmWGBd3cRGyI)JbOL5vqPBMqCg(JATb8EGkcidkbX2NwJA5iod3F47KeLmi2mbbgg7qXEBotLtZ4f5RtB8ejeSdrnGsDsySxQe)peGWWyhk2BZz4(dFNKarK0ap1am8I81PnEIec5fkdm42WTWkiM4)8P1Owo6Mw9P4Qb2daQIi2nFQ7rXjMBGneFAP71A9RR)3kdm4MBaAfMI4eYj2dqsW4tXigXCdSH4tlDVwRF5X)wzGb3CVLceXjKtShGKGXNIbb(L)2atoNuKAauEHYadUnClScIj(pgGwMxbLUzcXTnnGkyStbeQmmqfbKf5RtB88Acc2SEHaV0pQXpJmuuhle5f5RtB8ekdL7Ri)xmAC2udOuNeg7LQFFlc2Hy9cbEPFuJFgzOOowiYFW2TliytnGsDsySxQI5tRrTCexnWEaqveX(L1le4eZnWgsAWoT4f5RtBIbfd4HxHOehKK71ehmS7gzr(60)6s(FIJ0LiiiOgqPojm2lvX8P1OwoIRgypaOkIy)Y6fcCI5gydjDVwlEr(60MyqXaE4vikXbj5EnXbd7UrwKVo9VUK)N4iDjc2Hqm3aBi(0sTreInBIXWyhk2BZzQCAg)bliWWFuRnGFhXA0gIymm2HI92CYhg7LkPfUr5py7ccm8h1Ad49aveqguYoeBIXWFuRnG)rnqeILGGywVqGZu50m(dwqqnGsDsySxQe3JqWUGG1le4mvonJxKVoTr8RhIywVqGx6h14NrgkQJfI8hCEHYadUnClScIj(pn5v6JX9ntiUnRxiWjMBGnK09AT4pybbBmrAbLmXVesrmrAbLKGXN88p7ccmrAbLmXV1oefwYerS75fkdm42WTWkiM4)isDbPpg33mH42SEHaNyUb2qs3R1I)GfeSXePfuYe)sifXePfuscgFYZ)SliWePfuYe)w7quyjteXUNxOmWGBd3cRGyI)t45CsFmUVzcXTz9cboXCdSHKUxRf)bliyJjslOKj(LqkIjslOKem(KN)zxqGjslOKj(T2HOWsMiIDpVqzGb3gUfwbXe)hVAvdUK4GKCVMYlugyWTHBHvqmX)Xa0kmfDZeItm3aBi(0s3R1sqGyUb2qCd2PLSjKdeeiMBGnexBeLnHCGGG1le4E1QgCjXbj5EnXFWqiMBGneFAP71AjiyZ6fcCMkNMXlYxN24PYadU5ElfiItiNypajbJpbX6fcCMkNMXFW2ZlugyWTHBHvqmX)XBPar5fkdm42WTWkiM4)uVwQmWGBPBmGBA1NIhuNdiQE5f5fkdm42Wrls9TMgLQ4FAnQLJUPvFkUrdKeGLpdjnWKZDZN6EuCBwVqGdgFYlUAjArQV10OuXlYxN2iougk3xrEmiWrcInI5gydXNwAHbIeeiMBGneFAPb70sqGyUb2qC3R1s2eYb2feSEHahm(KxC1s0IuFRPrPIxKVoTrCLbgCZnaTctrCc5e7bijy8PyqGJeeBeZnWgIpT09ATeeiMBGne3GDAjBc5abbI5gydX1grztihy3UGGywVqGdgFYlUAjArQV10OuXFW5fkdm42Wrls9TMgLQyI)JbOL5vqPBMqCBI9P1OwoIB0ajby5Zqsdm5Ccc2SEHaV0pQXpJmuuhle5f5RtB8ekdL7Ri)xmAC2udOuNeg7LQFFlc2Hy9cbEPFuJFgzOOowiYFW2TliOgqPojm2lvI7riKxOmWGBdhTi13AAuQIj(pmC)HVtsGisAGNAaMBMqCBFAnQLJ4mC)HVtsuYGyZGmnGkyStbeQmmqfbKf5RtBehPBraIymm2HI92CMkNMXlsrruqW6fcCMkNMXFW2HOgqPojm2lvEEneGyZ6fcCI5gydjDVwlEr(60gXrcbbbRxiWjMBGnK0GDAXlYxN2iosiyxqimqfbKf5RtB8ejeYlugyWTHJwK6BnnkvXe)hfvHbZhjnE1Y)ggImhjbAbLaM4iDZeIlgkgWvufgmFK04vlFjQ6Rqjoyy3NgkeXugyWnxrvyW8rsJxT8LOQVcL4tldUbQiaeBIHIbCfvHbZhjnE1YxkIuhhmS7tdvqafd4kQcdMpsA8QLVuePoEr(60gX)ZUGakgWvufgmFK04vlFjQ6RqjUbOS7EEleumGROkmy(iPXRw(su1xHs8I81PnEEleumGROkmy(iPXRw(su1xHsCWWUpn08cLbgCB4OfP(wtJsvmX)XhJ7Wu0nmezosc0ckbmXr6MjeVOqrgrQLJGa0ckb4GXNKaSeDiXr6si2Sz9cbotLtZ4f5RtBe)pi2SEHaV0pQXpJmuuhle5f5RtBe)pbbXSEHaV0pQXpJmuuhle5py7ccIz9cbotLtZ4pybb1ak1jHXEPYZBrWoeBIz9cb(9Prlcvs(WyVu5tnqsnvqNyr8hSGGAaL6KWyVu55TiyhIclzIi2D75fkdm42Wrls9TMgLQyI)J51HPOByiYCKeOfucyIJ0ntiErHImIulhbbOfucWbJpjbyj6qIJ0LqSzZ6fcCMkNMXlYxN2i(FqSz9cbEPFuJFgzOOowiYlYxN2i(FccIz9cbEPFuJFgzOOowiYFW2feeZ6fcCMkNMXFWccQbuQtcJ9sLN3IGDi2eZ6fc87tJweQK8HXEPYNAGKAQGoXI4pybb1ak1jHXEPYZBrWoefwYerS72ZlugyWTHJwK6BnnkvXe)hdGCoTKbNw0nmezosc0ckbmXr6MjeVOqrgrQLJGa0ckb4GXNKaSeDiXrYJHyZM1le4mvonJxKVoTr8)GyZ6fc8s)Og)mYqrDSqKxKVoTr8)eeeZ6fc8s)Og)mYqrDSqK)GTliiM1le4mvonJ)GfeudOuNeg7LkpVfb7qSjM1le43NgTiuj5dJ9sLp1aj1ubDIfXFWccQbuQtcJ9sLN3IGDikSKjIy3TNxOmWGBdhTi13AAuQIj(pbCXijoiBf8k6MjexHLmre7EEHYadUnC0IuFRPrPkM4)u6h14NrgkQJfI3mH4wVqGZu50m(doVqzGb3goArQV10Ouft8FUpnArOsd8udWCZeIBZM1le4eZnWgsAWoT4f5RtBehjeeeSEHaNyUb2qs3R1IxKVoTrCKqWoegg7qXEBotLtZ4f5RtBe)weSliWWyhk2BZzQCAgViffX8cLbgCB4OfP(wtJsvmX)HroYag1jv3aT9PgCZeIBZM1le43NgTiuj5dJ9sLp1aj1ubDIfXFWccIXWFuRnGFhXA02UGad)rT2aEpqfbKbLee(0AulhXhJuXKGG1le4womg19ma(dgI1le4womg19maEr(60gpVeHySDTFXWn6BaC4IyJHKQBG2(ud4uRwoc1UDiIz9cbotLtZ4pyi2eJH)OwBaVhOIaYGsccmm2HI92CgU)W3jjqejnWtnad)blimnGkyStbeQmmqfbKf5RtB8KHXouS3MZW9h(ojbIiPbEQby4f5RtBIXJfeMgqfm2PacvggOIaYI81Pn)(3iD9i45LieJTR9lgUrFdGdxeBmKuDd02NAaNA1YrO2TNxOmWGBdhTi13AAuQIj(ptZ0QvWG7BMqCB2SEHa)(0OfHkjFySxQ8PgiPMkOtSi(dwqqmg(JATb87iwJ22fey4pQ1gW7bQiGmOKGWNwJA5i(yKkMeeSEHa3YHXOUNbWFWqSEHa3YHXOUNbWlYxN245TieJTR9lgUrFdGdxeBmKuDd02NAaNA1YrO2TdrmRxiWzQCAg)bdXMym8h1Ad49aveqgusqGHXouS3MZW9h(ojbIiPbEQby4pybHPbubJDkGqLHbQiGSiFDAJNmm2HI92CgU)W3jjqejnWtnadViFDAtmESGW0aQGXofqOYWaveqwKVoT53)gPRhbpVfHySDTFXWn6BaC4IyJHKQBG2(ud4uRwoc1U98cLbgCB4OfP(wtJsvmX)5tRrTC0nT6tXn6hjd4sYu50SB(u3JIBtmgg7qXEBotLtZ4fPOikii2NwJA5iod3F47KeLmi2mim8h1Ad49aveqguYEEHYadUnC0IuFRPrPkM4)8P1Owo6Mw9P4g9JKbCjzQCA2nFQ7rXTjgdJDOyVnNPYPz8Iuuefee7tRrTCeNH7p8DsYWn6agCdHH)OwBaVhOIaYGs2ZlugyWTHJwK6BnnkvXe)hgU)W3jjqejnWtnaZnti(NwJA5iod3F47KKHB0bm4gIAaL6KWyVu551qiVqzGb3goArQV10Ouft8FcVcrjoij3RPBMqCI5gydXNwQnIquyjteXUdXgkgWvufgmFK04vlFjQ6Rqjoyy3NgQGGym8h1Ad4nXkSdxO2H8P1OwoIB0psgWLKPYPz5fkdm42Wrls9TMgLQyI)JbOL5vqPBMqCg(JATb8EGkcidkb5tRrTCeNH7p8DsIsgeBge1ak1jHXEPs84xdbimm2HI92CgU)W3jjqejnWtnadViFDAJNqzOCFf5)IrJZMAaL6KWyVu97BrWEEHYadUnC0IuFRPrPkM4)0KxPpg33mH42SEHaNyUb2qs3R1I)GfeSXePfuYe)sifXePfuscgFYZ)SliWePfuYe)w7quyjteXUd5tRrTCe3OFKmGljtLtZYlugyWTHJwK6BnnkvXe)hrQli9X4(Mje3M1le4eZnWgs6ETw8hmeXy4pQ1gWVJynAliyZ6fc87tJweQK8HXEPYNAGKAQGoXI4pyim8h1Ad43rSgTTliyJjslOKj(LqkIjslOKem(KN)zxqGjslOKj(TccwVqGZu50m(d2oefwYerS7q(0AulhXn6hjd4sYu50S8cLbgCB4OfP(wtJsvmX)j8CoPpg33mH42SEHaNyUb2qs3R1I)GHigd)rT2a(DeRrBbbBwVqGFFA0IqLKpm2lv(udKutf0jwe)bdHH)OwBa)oI1OTDbbBmrAbLmXVesrmrAbLKGXN88p7ccmrAbLmXVvqW6fcCMkNMXFW2HOWsMiIDhYNwJA5iUr)izaxsMkNMLxOmWGBdhTi13AAuQIj(pE1QgCjXbj5EnLxOmWGBdhTi13AAuQIj(pgGwHPOBMqCI5gydXNw6ETwcceZnWgIBWoTKnHCGGaXCdSH4AJOSjKdeeSEHa3Rw1Gljoij3Rj(dgI1le4eZnWgs6ETw8hSGGnRxiWzQCAgViFDAJNkdm4M7TuGioHCI9aKem(eeRxiWzQCAg)bBpVqzGb3goArQV10Ouft8F8wkquEHYadUnC0IuFRPrPkM4)uVwQmWGBPBmGBA1NIhuNdiQE5f5fkdm42WdQZbevV4gGwMxbLUzcXfREnfWfuIBPoTzKehKQZjbIMgQHtX23adtO5fkdm42WdQZbevVyI)J51HPOByiYCKeOfucyIJ0ntiokgW9X4omfXlYxN2iEr(60M8cLbgCB4b15aIQxmX)XhJ7WuuErEHYadUnC4IGvatK0aI7JXDyk6ggImhjbAbLaM4iDZeIxuOiJi1YrqaAbLaCW4tsawIoK4iDjeBwVqGZu50mEr(60gX)tqqmRxiWzQCAg)bliOgqPojm2lvEElc2HOWsMiIDpVqzGb3goCrWkGjsAaXe)hZRdtr3WqK5ijqlOeWehPBMq8IcfzePwoccqlOeGdgFscWs0HehPlHyZ6fcCMkNMXlYxN2i(FccIz9cbotLtZ4pybb1ak1jHXEPYZBrWoefwYerS75fkdm42WHlcwbmrsdiM4)yaKZPLm40IUHHiZrsGwqjGjos3mH4ffkYisTCeeGwqjahm(KeGLOdjosxcXM1le4mvonJxKVoTr8)eeeZ6fcCMkNMXFWccQbuQtcJ9sLN3IGDikSKjIy3ZlugyWTHdxeScyIKgqmX)jGlgjXbzRGxr3mH4kSKjIy3ZlugyWTHdxeScyIKgqmX)HroYag1jv3aT9PgCZeIBtnGsDsySxQe3JqqqW6fcClhgJ6Ega)bdX6fcClhgJ6EgaViFDAJNx6X2HiM1le4mvonJ)GZlugyWTHdxeScyIKgqmX)zAMwTcgCFZeIBtnGsDsySxQe3JqqqW6fcClhgJ6Ega)bdX6fcClhgJ6EgaViFDAJN36X2HiM1le4mvonJ)GZlugyWTHdxeScyIKgqmX)5tRrTC0nT6tXn6hjd4sYu50SB(u3JIlgdJDOyVnNPYPz8IuueZlugyWTHdxeScyIKgqmX)j8keL4GKCVMUzcXjMBGneFAP2icrHLmre7oKpTg1YrCJ(rYaUKmvonlVqzGb3goCrWkGjsAaXe)hM2mYjTEHWnT6tXnaTC4c9Mje36fcCdqlhUq5f5RtB80JHyZ6fcCI5gydjnyNw8hSGG1le4eZnWgs6ETw8hSDiQbuQtcJ9sL4Eec5fkdm42WHlcwbmrsdiM4)yaAzEfu6Mje3MyASOAae3aksVpnuPbOLHxAFxqW6fcCMkNMXlYxN24jHCI9aKem(KGGyWf9XnaTmVckzhInRxiWzQCAg)bliOgqPojm2lvI7riaHyUb2q8PLAJO98cLbgCB4WfbRaMiPbet8FmaTmVckDZeIBtmnwunaIBafP3NgQ0a0YWlTVliy9cbotLtZ4f5RtB8KqoXEascgFsqqSpTg1YrC4I(KgGwMxbLSdbOoQbCdqlhUq5uRwocfInRxiWnaTC4cL)GfeudOuNeg7LkX9ieSdX6fcCdqlhUq5gGYU75TqSz9cboXCdSHKgStl(dwqW6fcCI5gydjDVwl(d2oegg7qXEBotLtZ4f5RtBe3dMxOmWGBdhUiyfWejnGyI)JbOL5vqPBMqCBIPXIQbqCdOi9(0qLgGwgEP9DbbRxiWzQCAgViFDAJNeYj2dqsW4tccIbx0h3a0Y8kOKDiwVqGtm3aBiPb70IxKVoTrCpieI5gydXNwAWoTGigqDud4gGwoCHYPwTCekegg7qXEBotLtZ4f5RtBe3dMxOmWGBdhUiyfWejnGyI)ttEL(yCFZeIBZ6fcCI5gydjDVwl(dwqWgtKwqjt8lHuetKwqjjy8jp)ZUGatKwqjt8BTdrHLmre7oKpTg1YrCJ(rYaUKmvonlVqzGb3goCrWkGjsAaXe)hrQli9X4(Mje3M1le4eZnWgs6ETw8hSGGnMiTGsM4xcPiMiTGssW4tE(NDbbMiTGsM43kiy9cbotLtZ4py7quyjteXUd5tRrTCe3OFKmGljtLtZYlugyWTHdxeScyIKgqmX)j8CoPpg33mH42SEHaNyUb2qs3R1I)GfeSXePfuYe)sifXePfuscgFYZ)SliWePfuYe)wbbRxiWzQCAg)bBhIclzIi2DiFAnQLJ4g9JKbCjzQCAwEHYadUnC4IGvatK0aIj(pE1QgCjXbj5EnLxOmWGBdhUiyfWejnGyI)JbOvyk6Mje3MglQgaXnGI07tdvAaAz4L23Hy9cbotLtZ4f5RtBeNqoXEascgFccCrFCVLcezxqWMyASOAae3aksVpnuPbOLHxAFxqW6fcCMkNMXlYxN24jHCI9aKem(KGGyWf9XnaTctr2HyJyUb2q8PLUxRLGaXCdSH4gStlztihiiqm3aBiU2ikBc5abbRxiW9Qvn4sIdsY9AI)GHy9cboXCdSHKUxRf)bliyZ6fcCMkNMXlYxN24PYadU5ElfiItiNypajbJpbX6fcCMkNMXFW2TliytJfvdG4OQ3EAOsZR5L23f)siwVqGtm3aBiPb70IxKVoTr8)GiM1le4OQ3EAOsZR5f5RtBexzGb3CVLceXjKtShGKGXNSNxeBMRh4qUiIF5cW475gbiNtRC9avnbWn5Ii(LlCHTulhI56vBqUgSpLBeqRG6C5(GbJpX588cLbgCB4WfbRaMiPbet8FmaTcQZDZeIduh1aUbqoNws0Acao1QLJqHy9cbUbOvqDoErHImIulhbjmqfbKf5RtBe36fcCdqRG6CC0xPGb3qSjgXCdSH4tl1grbbRxiWnaTmVckjjFySxQ8PgWFW2ZlugyWTHdxeScyIKgqmX)XBPar5fkdm42WHlcwbmrsdiM4)uVwQmWGBPBmGBA1NIhuNdiQE5f5fkdm42WnG4kQcdMpsA8QL)nmezosc0ckbmXr6MjexmumGROkmy(iPXRw(su1xHsCWWUpnuiIPmWGBUIQWG5JKgVA5lrvFfkXNwgCdurai2edfd4kQcdMpsA8QLVuePooyy3NgQGakgWvufgmFK04vlFPisD8I81PnI)NDbbumGROkmy(iPXRw(su1xHsCdqz398wiOyaxrvyW8rsJxT8LOQVcL4f5RtB88wiOyaxrvyW8rsJxT8LOQVcL4GHDFAO5fkdm42WnGyI)dd3F47KeiIKg4PgG5Mje32NwJA5iod3F47KeLmi2mitdOcg7uaHkddurazr(60gXr6weGigdJDOyVnNPYPz8IuuefeSEHaNPYPz8hSDiQbuQtcJ9sLN)HaeBwVqGtm3aBiP71AXlYxN2iosiiiy9cboXCdSHKgStlEr(60gXrcb7ccHbQiGSiFDAJNiHqEHYadUnCdiM4)4JXDyk6ggImhjbAbLaM4iDZeIxuOiJi1YrqaAbLaCW4tsawIoK4iDjeBwVqGZu50mEr(60gX)dInRxiWl9JA8Zidf1XcrEr(60gX)tqqmRxiWl9JA8Zidf1Xcr(d2UGGywVqGZu50m(dwqqnGsDsySxQ88weSdXMywVqGFFA0IqLKpm2lv(udKutf0jwe)bliOgqPojm2lvEElc2HOWsMiIDpVqzGb3gUbet8FmVomfDddrMJKaTGsatCKUzcXlkuKrKA5iiaTGsaoy8jjalrhsCKUeInRxiWzQCAgViFDAJ4)bXM1le4L(rn(zKHI6yHiViFDAJ4)jiiM1le4L(rn(zKHI6yHi)bBxqqmRxiWzQCAg)bliOgqPojm2lvEElc2HytmRxiWVpnArOsYhg7LkFQbsQPc6elI)GfeudOuNeg7LkpVfb7quyjteXUNxOmWGBd3aIj(pga5CAjdoTOByiYCKeOfucyIJ0ntiErHImIulhbbOfucWbJpjbyj6qIJKhdXM1le4mvonJxKVoTr8)GyZ6fc8s)Og)mYqrDSqKxKVoTr8)eeeZ6fc8s)Og)mYqrDSqK)GTliiM1le4mvonJ)GfeudOuNeg7LkpVfb7qSjM1le43NgTiuj5dJ9sLp1aj1ubDIfXFWccQbuQtcJ9sLN3IGDikSKjIy3ZlugyWTHBaXe)NaUyKehKTcEfDZeIRWsMiIDpVqzGb3gUbet8Fk9JA8Zidf1XcXBMqCRxiWzQCAg)bNxOmWGBd3aIj(p3NgTiuPbEQbyUzcXTzZ6fcCI5gydjnyNw8I81PnIJecccwVqGtm3aBiP71AXlYxN2iosiyhcdJDOyVnNPYPz8I81PnIFlcqSz9cboCn(4cDuNulM2dtc)CgT4FQ7rEE51qqqqS61uaxqjoCn(4cDuNulM2dtc)CgT4uS9nWWeQD7ccwVqGdxJpUqh1j1IP9WKWpNrl(N6EK4XV0dIGGadJDOyVnNPYPz8IuueHytnGsDsySxQe3Jqqq4tRrTCeFmsft2ZlugyWTHBaXe)hg5idyuNuDd02NAWntiUn1ak1jHXEPsCpcbi2SEHa)(0OfHkjFySxQ8PgiPMkOtSi(dwqqmg(JATb87iwJ22fey4pQ1gW7bQiGmOKGWNwJA5i(yKkMeeSEHa3YHXOUNbWFWqSEHa3YHXOUNbWlYxN245LieJnBE0VQxtbCbL4W14Jl0rDsTyApmj8Zz0ItX23adtO2JX21(fd3OVbWHlIngsQUbA7tnGtTA5iu72TdrmRxiWzQCAg)bdXMym8h1Ad49aveqgusqGHXouS3MZW9h(ojbIiPbEQby4pybHPbubJDkGqLHbQiGSiFDAJNmm2HI92CgU)W3jjqejnWtnadViFDAtmESGW0aQGXofqOYWaveqwKVoT53)gPRhbpVeHySDTFXWn6BaC4IyJHKQBG2(ud4uRwoc1U98cLbgCB4gqmX)zAMwTcgCFZeIBtnGsDsySxQe3JqaInRxiWVpnArOsYhg7LkFQbsQPc6elI)GfeeJH)OwBa)oI1OTDbbg(JATb8EGkcidkji8P1OwoIpgPIjbbRxiWTCymQ7za8hmeRxiWTCymQ7za8I81PnEElcXyZMh9R61uaxqjoCn(4cDuNulM2dtc)CgT4uS9nWWeQ9ySDTFXWn6BaC4IyJHKQBG2(ud4uRwoc1UD7qeZ6fcCMkNMXFWqSjgd)rT2aEpqfbKbLeeyySdf7T5mC)HVtsGisAGNAag(dwqyAavWyNciuzyGkcilYxN24jdJDOyVnNH7p8Dscersd8udWWlYxN2eJhlimnGkyStbeQmmqfbKf5RtB(9Vr66rWZBrigBx7xmCJ(gahUi2yiP6gOTp1ao1QLJqTBpVqzGb3gUbet8F(0AulhDtR(uCJ(rYaUKmvon7Mp19O42eJHXouS3MZu50mErkkIccI9P1OwoIZW9h(ojrjdIndcd)rT2aEpqfbKbLSNxOmWGBd3aIj(pHxHOehKK710ntioXCdSH4tl1grikSKjIy3Hy9cboCn(4cDuNulM2dtc)CgT4FQ7rEE51qaInumGROkmy(iPXRw(su1xHsCWWUpnubbXy4pQ1gWBIvyhUqTd5tRrTCe3OFKmGljtLtZYlugyWTHBaXe)hdqRG6C3mH4wVqGJBciYiHPIrWGb38hmeRxiWnaTcQZXlkuKrKA5O8cLbgCB4gqmX)HPnJCsRxiCtR(uCdqlhUqVzcXTEHa3a0YHluEr(60gp)dInRxiWjMBGnK0GDAXlYxN2i(FccwVqGtm3aBiP71AXlYxN2i(F2HOgqPojm2lvI7riKxOmWGBd3aIj(pgGwMxbLUzcXz4pQ1gW7bQiGmOeKpTg1YrCgU)W3jjkzqSzqyySdf7T5mC)HVtsGisAGNAagEr(60gpHYq5(kY)fJgNn1ak1jHXEP633IG98cLbgCB4gqmX)Xa0kOo3ntioqDud4ga5CAjrRja4uRwocfIya1rnGBaA5WfkNA1YrOqSEHa3a0kOohVOqrgrQLJGyZ6fcCI5gydjDVwlEr(60gX9yieZnWgIpT09ATGytS61uaxqjoCn(4cDuNulM2dtc)CgT4uRwocvqW6fcC4A8Xf6OoPwmThMe(5mAX)u3J88Y)qWUGGnXQxtbCbL4W14Jl0rDsTyApmj8Zz0ItTA5iubbRxiWHRXhxOJ6KAX0Eys4NZOf)tDps84x(hc2HOgqPojm2lvI7riiiGIbCfvHbZhjnE1YxIQ(kuIxKVoTr8RxqqzGb3CfvHbZhjnE1YxIQ(kuIpTm4gOIa2HigdJDOyVnNPYPz8IuueZlugyWTHBaXe)hdqlZRGs3mH4wVqGJBciYizosl53ygCZFWccwVqGFFA0IqLKpm2lv(udKutf0jwe)bliy9cbotLtZ4pyi2SEHaV0pQXpJmuuhle5f5RtB8ekdL7Ri)xmAC2udOuNeg7LQFFlc2Hy9cbEPFuJFgzOOowiYFWccIz9cbEPFuJFgzOOowiYFWqeJHXouS3Mx6h14NrgkQJfI8IuuefeeJH)OwBa)JAGiel7ccQbuQtcJ9sL4EecqiMBGneFAP2iMxOmWGBd3aIj(pgGwMxbLUzcXbQJAa3a0YHluo1QLJqHyZ6fcCdqlhUq5pybb1ak1jHXEPsCpcb7qSEHa3a0YHluUbOS7EEleBwVqGtm3aBiPb70I)GfeSEHaNyUb2qs3R1I)GTdX6fcC4A8Xf6OoPwmThMe(5mAX)u3J88spicqSXWyhk2BZzQCAgViFDAJ4iHGGGyFAnQLJ4mC)HVtsgUrhWGBim8h1Ad49aveqguYEEHYadUnCdiM4)yaAzEfu6MjehOoQbCdqlhUq5uRwocfInRxiWnaTC4cL)GfeudOuNeg7LkX9ieSdX6fcCdqlhUq5gGYU75TqSz9cboXCdSHKgStl(dwqW6fcCI5gydjDVwl(d2oeRxiWHRXhxOJ6KAX0Eys4NZOf)tDpYZl9GiaXgdJDOyVnNPYPz8I81PnIJecccI9P1OwoIZW9h(ojrjdIndcd)rT2aEpqfbKbLSNxOmWGBd3aIj(pn5v6JX9ntiUnRxiWjMBGnK09AT4pybbBmrAbLmXVesrmrAbLKGXN88p7ccmrAbLmXV1oefwYerS7q(0AulhXn6hjd4sYu50S8cLbgCB4gqmX)rK6csFmUVzcXTz9cboXCdSHKUxRf)bdrmg(JATb87iwJ2cc2SEHa)(0OfHkjFySxQ8PgiPMkOtSi(dgcd)rT2a(DeRrB7cc2yI0ckzIFjKIyI0ckjbJp55F2feyI0ckzIFRGG1le4mvonJ)GTdrHLmre7oKpTg1YrCJ(rYaUKmvonlVqzGb3gUbet8FcpNt6JX9ntiUnRxiWjMBGnK09AT4pyiIXWFuRnGFhXA0wqWM1le43NgTiuj5dJ9sLp1aj1ubDIfXFWqy4pQ1gWVJynABxqWgtKwqjt8lHuetKwqjjy8jp)ZUGatKwqjt8BfeSEHaNPYPz8hSDikSKjIy3H8P1OwoIB0psgWLKPYPz5fkdm42WnGyI)JxTQbxsCqsUxt5fkdm42WnGyI)JbOvyk6MjeNyUb2q8PLUxRLGaXCdSH4gStlztihiiqm3aBiU2ikBc5abbRxiW9Qvn4sIdsY9AI)GHy9cboXCdSHKUxRf)bliyZ6fcCMkNMXlYxN24PYadU5ElfiItiNypajbJpbX6fcCMkNMXFW2ZlugyWTHBaXe)hVLceLxOmWGBd3aIj(p1RLkdm4w6gd4Mw9P4b15aIQ3bCaNd]] )


end