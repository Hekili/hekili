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


    spec:RegisterPack( "Balance", 20201024, [[dGuoOdqiQGhjqkDjvi2ei(KQQOmkQOtrLSkQq8kbywQiDlQqPDr4xQQyyqHJbfTmb0ZuHAAQQsxtvL2MQQW3OcvJtfsDoQqADuHI5HQQ7Pc2hQkhuvvuTqufEOajtuvveXfvvfr6JQQIKtkqkALcuZufs2PkIFQQkIAOQQIWsfifEQGMQQQ6RQQIu7vL(lrdwPdtAXuQhJYKHQlJSzH(minAO0PL61QOMnvDBkz3k(nKHdQJlqQwUKNtX0bUUQSDvLVtLA8Ok68OkTEbI5Jk7x0xmV)FdXvaDpjqmcedmXiW)kW8ymc83FVHaEHPBiSYoRqPB4Ow0nKhQxhgDdHvE9if)()n0GEfJUHybayJJ5NFG2aSpBbdz9JPTEEf0OHvAe8JPTy)CdTFThe0CU23qCfq3tceJaXatmc8VcmpgJa)7rFd1halQUHHTvqDdX2440CTVH4KHDddAZLhQxhgL7FsQxJNbh0M7FYmaYMQCd8VNMBGyeigzWzWbT5guy1bkzCmzWbT56yZ9phhNWZne51kxEqQLidoOnxhBUbfwDGs45c0ckbKDmxMAitUauUmEzEsc0ckbmIm4G2CDS5g0GSqFeEUVzigzmAXBUFA1QTNm56SfK40CHl6tAaAzEfukxhlF5cx0NWa0Y8kOKlXn03gG5()neVi1YUhCQU)FpbZ7)3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0n0zU2VyuaAlYnQgjErQLDp4ujkYs7XKlF5cLHlSuEMBa5IHaZCHKRZCjMVHnKOhPncGnxoUCjMVHnKOhPb51kxoUCjMVHnKW)gTKdXtqUUYLJlx7xmkaTf5gvJeVi1YUhCQefzP9yYLVCvgOrJWa0k2fjiEsShGKG2IYnGCXqGzUqY1zUeZ3Wgs0J0)gTYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUUY1vUCC56qU2VyuaAlYnQgjErQLDp4ujEW3WpTKJAr3qJgjjajFgsAGjV)cUNe49)BinQTNWV84gYQgqvR3qN56qUFA1QTNegnssas(mK0atEFUCC56mx7xmkk9Jg0ZiJfnbHxrrwApMC5pxOmCHLYZCDKCzu7Z1zUQbuQxcJCtvU)K7XyKRRCHKR9lgfL(rd6zKXIMGWR4bNRRCDLlhxUQbuQxcJCtvU8LRJIXnuzGgn3qdqlZRGsxW9KJV)FdPrT9e(Lh3qLbA0CdvCfg0FK04wlRBiRAavTEdDixCeqO4kmO)iPXTwwsC1sHscqZo3d0CHKRd5QmqJgHIRWG(JKg3AzjXvlfkj6rg9nuSGCHKRZCDixCeqO4kmO)iPXTwwsSK6fGMDUhO5YXLlociuCfg0FK04wlljws9IIS0Em5YxU)MRRC54YfhbekUcd6psACRLLexTuOKWau25C5p3JZfsU4iGqXvyq)rsJBTSK4QLcLefzP9yYL)Cpoxi5IJacfxHb9hjnU1YsIRwkusaA25EGEdz8Y8KeOfucyUNG5fCp5V3)VH0O2Ec)YJBOYanAUHwi0e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZaZfsUoZ1zU2VyuWuzpmrrwApMC5l3FZfsUoZ1(fJIs)Ob9mYyrtq4vuKL2Jjx(Y93C54Y1HCTFXOO0pAqpJmw0eeEfp4CDLlhxUoKR9lgfmv2dt8GZLJlx1ak1lHrUPkx(Z9ymY1vUqY1zUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRAaL6LWi3uLl)5Emg56kxi5QWsgwIDoxx3qgVmpjbAbLaM7jyEb3t(9()nKg12t4xECdvgOrZn08Myx0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zUoZ1(fJcMk7HjkYs7XKlF5(BUqY1zU2Vyuu6hnONrglAccVIIS0Em5YxU)MlhxUoKR9lgfL(rd6zKXIMGWR4bNRRC54Y1HCTFXOGPYEyIhCUCC5QgqPEjmYnv5YFUhJrUUYfsUoZ1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCvdOuVeg5MQC5p3JXixx5cjxfwYWsSZ566gY4L5jjqlOeWCpbZl4EYFC))gsJA7j8lpUHkd0O5gAaK3RLm61IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZ)ixi56mxN5A)IrbtL9WefzP9yYLVC)nxi56mx7xmkk9Jg0ZiJfnbHxrrwApMC5l3FZLJlxhY1(fJIs)Ob9mYyrtq4v8GZ1vUCC56qU2VyuWuzpmXdoxoUCvdOuVeg5MQC5p3JXixx5cjxN56qU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUQbuQxcJCtvU8N7XyKRRCHKRclzyj25CDDdz8Y8KeOfucyUNG5fCpXXV)FdPrT9e(Lh3qw1aQA9gQWsgwID(gQmqJMByevmsIIYrbVIUG7jh99)BinQTNWV84gYQgqvR3q7xmkyQShM4bFdvgOrZnS0pAqpJmw0eeEVG7jo69)BinQTNWV84gYQgqvR3qN56mx7xmkiMVHnK0G8AjkYs7XKlF5Ijg5YXLR9lgfeZ3Wgs6FJwIIS0Em5YxUyIrUUYfsUmeYJJCpcMk7HjkYs7XKlF5Emg56kxoUCziKhh5Eemv2dtuKIZ7nuzGgn3WZ9GxeU0a3vdmxW9emX4()nKg12t4xECdzvdOQ1BOZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmQuUCC5(PvR2Es0gPIOC54Y1(fJcBpcH7FgG4bNlKCTFXOW2Jq4(NbikYs7XKl)5gig5gqUoZ9V56i5Yqd(Rbc4IyTHKQVHow0ae0O2Ecpxx5cjxhY1(fJcMk7HjEW5cjxN52dGkyKxbeUm2qXcKfzP9yYL)CziKhh5Eem08HotsawsAG7QbgrrwApMCdixhpxoUC7bqfmYRacxgBOybYIS0Em5YFUbgyUCC52dGkyKxbeUm2qXcKfzP9yY9i5I5rJrU8NBGbMlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUoKld9rJoaX0qXcKrLY11nuzGgn3qg5jdOvVu9n0XIgWfCpbtmV)FdPrT9e(Lh3qw1aQA9g6mx7xmko3dEr4sYcg5MklAasAOcAhes8GZLJlxhYLH(OrhG4mVvRtUUYLJlxg6JgDaIPHIfiJkLlhxUFA1QTNeTrQikxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIIS0Em5YFUhJrUbKRZC)BUosUm0G)AGaUiwBiP6BOJfnabnQTNWZ1vUqY1HCTFXOGPYEyIhCUqY1zU9aOcg5vaHlJnuSazrwApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jj3aY1XZLJl3EaubJ8kGWLXgkwGSilThtU8N7XbMlhxU9aOcg5vaHlJnuSazrwApMCpsUyE0yKl)5ECG5YXLldH84i3JGHMp0zscWssdCxnWiEW5YXLRd5YqF0OdqmnuSazuPCDDdvgOrZnShMwJcA0Cb3tWmW7)3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0nKH(OrhGyAOybYOs5cjxN5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb(xmYfsUoZLHqECK7rWuzpmrrwApMCdixmXix(YThavWiVciCzSHIfilYs7XKlhxUmeYJJCpcMk7HjkYs7XKBa5Emg5YFU9aOcg5vaHlJnuSazrwApMCHKBpaQGrEfq4YydflqwKL2Jjx(YfZJXixoUCTFXOGPYEyIIS0Em5YxUoEUUYfsU2VyuqmFdBiPb51suKL2Jjx(YftmYLJl3EaubJ8kGWLXgkwGSilThtUhjxmdeJC5pxm)nxx3WpTKJAr3qgA(qNjjdn4nOrZfCpbZJV)FdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qN56qUmeYJJCpcMk7HjksX5nxoUCDi3pTA12tcgA(qNjjdn4nOrtUqYLH(OrhGyAOybYOs566g(PLCul6gA0psgrLKPYEyxW9em)79)BinQTNWV84gYQgqvR3WpTA12tcgA(qNjjdn4nOrtUqYvnGs9syKBQYL)C)lg3qLbA0CdzO5dDMKaSK0a3vdmxW9em)9()nKg12t4xECdzvdOQ1BiX8nSHe9i1H3CHKRclzyj25CHKRZCXraHIRWG(JKg3AzjXvlfkjan7CpqZLJlxhYLH(OrhGyiwH8Ocpxx5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBy8v8krrj5FdDb3tW8pU)FdPrT9e(Lh3qw1aQA9gYqF0OdqmnuSazuPCHK7NwTA7jbdnFOZKKHg8g0Ojxi5QgqPEjmYnv5Y3HC)lg5cjxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jjx(ZfkdxyP8mxhjxg1(CDMRAaL6LWi3uL7p5Emg566gQmqJMBObOL5vqPl4EcMo(9)BinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3WHClTqO5cUNG5rF))gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5cjxhYLH(OrhG4mVvRtUCC56mx7xmko3dEr4sYcg5MklAasAOcAhes8GZfsUm0hn6aeN5TADY1vUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X5YXLR9lgfmv2dt8GZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5gIv9rPfcnxW9emD07)3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxi56qUm0hn6aeN5TADYLJlxN5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUqYLH(OrhG4mVvRtUUYLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxoUCTFXOGPYEyIhCUUYfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3W4Z7Lwi0Cb3tceJ7)3qLbA0CdDRv1OsIIsY)g6gsJA7j8lpUG7jbI59)BinQTNWV84gYQgqvR3qI5Bydj6r6FJw5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixoUCTFXOWTwvJkjkkj)BiXdoxi5A)IrbX8nSHK(3OL4bNlhxUoZ1(fJcMk7HjkYs7XKl)5QmqJgH7sbyfepj2dqsqBr5cjx7xmkyQShM4bNRRBOYanAUHgGwXUOl4EsGbE))gQmqJMBO7sbyVH0O2Ec)YJl4EsGhF))gsJA7j8lpUHkd0O5gwVrQmqJgPVnGBOVna5Ow0nmQEpaB9UGl4gcxeScyyLgW9)7jyE))gsJA7j8lpUHkd0O5gAHqtSl6gYQgqvR3WIIfzWQ2Ekxi5c0ckbeG2IKaKeVPC5lxmdmxi56mx7xmkyQShMOilThtU8L7V5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)CpgJCDLlKCvyjdlXoFdz8Y8KeOfucyUNG5fCpjW7)3qAuBpHF5XnuzGgn3qZBIDr3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5IzG5cjxN5A)IrbtL9WefzP9yYLVC)nxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8N7XyKRRCHKRclzyj25BiJxMNKaTGsaZ9emVG7jhF))gsJA7j8lpUHkd0O5gAaK3RLm61IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZaZfsUoZ1(fJcMk7HjkYs7XKlF5(BUCC56qU2VyuWuzpmXdoxoUCvdOuVeg5MQC5p3JXixx5cjxfwYWsSZ3qgVmpjbAbLaM7jyEb3t(79)BinQTNWV84gYQgqvR3qfwYWsSZ3qLbA0CdJOIrsuuok4v0fCp537)3qAuBpHF5XnKvnGQwVHoZvnGs9syKBQYLVCDumYLJlx7xmkS9ieU)zaIhCUqY1(fJcBpcH7FgGOilThtU8NBG)rUUYfsUoKR9lgfmv2dt8GVHkd0O5gYipzaT6LQVHow0aUG7j)X9)BinQTNWV84gYQgqvR3qN5QgqPEjmYnv5YxUokg5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdquKL2Jjx(Z94)ixx5cjxhY1(fJcMk7HjEW3qLbA0Cd7HP1OGgnxW9eh)()nKg12t4xECdrW3qdbUHkd0O5g(PvR2E6g(P(hDdDixgc5XrUhbtL9WefP48Ed)0soQfDdn6hjJOsYuzpSl4EYrF))gsJA7j8lpUHSQbu16nKy(g2qIEK6WBUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFfVsuus(3qxW9eh9()nKg12t4xECdzvdOQ1BO9lgfgGwEuHlkYs7XKl)5(h5cjxN5A)IrbX8nSHKgKxlXdoxoUCTFXOGy(g2qs)B0s8GZ1vUqYvnGs9syKBQYLVCDumUHkd0O5gY0HrEP9lgVH2VyuoQfDdnaT8Oc)cUNGjg3)VH0O2Ec)YJBiRAavTEdDMRd5QbHQgqcdOi9CpqLgGwgrPZ5C54Y1(fJcMk7HjkYs7XKl)5s8KypajbTfLlhxUoKlCrFcdqlZRGs56kxi56mx7xmkyQShM4bNlhxUQbuQxcJCtvU8LRJIrUqYLy(g2qIEK6WBUUUHkd0O5gAaAzEfu6cUNGjM3)VH0O2Ec)YJBiRAavTEdDMRd5QbHQgqcdOi9CpqLgGwgrPZ5C54Y1(fJcMk7HjkYs7XKl)5s8KypajbTfLlhxUoK7NwTA7jbCrFsdqlZRGs56kxi5cupnaHbOLhv4cAuBpHNlKCDMR9lgfgGwEuHlEW5YXLRAaL6LWi3uLlF56OyKRRCHKR9lgfgGwEuHlmaLDox(Z94CHKRZCTFXOGy(g2qsdYRL4bNlhxU2VyuqmFdBiP)nAjEW56kxi5YqipoY9iyQShMOilThtU8LRJFdvgOrZn0a0Y8kO0fCpbZaV)FdPrT9e(Lh3qw1aQA9g6mxhYvdcvnGegqr65EGknaTmIsNZ5YXLR9lgfmv2dtuKL2Jjx(ZL4jXEascAlkxoUCDix4I(egGwMxbLY1vUqY1(fJcI5BydjniVwIIS0Em5YxUoEUqYLy(g2qIEKgKxRCHKRd5cupnaHbOLhv4cAuBpHNlKCziKhh5Eemv2dtuKL2Jjx(Y1XVHkd0O5gAaAzEfu6cUNG5X3)VH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X56kxi5QWsgwIDoxi5(PvR2Esy0psgrLKPYEy3qLbA0CdhYT0cHMl4EcM)9()nKg12t4xECdzvdOQ1BOZCTFXOGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxoUCTFXOGPYEyIhCUUYfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3qSQpkTqO5cUNG5V3)VH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X5YXLR9lgfmv2dt8GZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFEV0cHMl4EcM)X9)BOYanAUHU1QAujrrj5FdDdPrT9e(LhxW9emD87)3qAuBpHF5XnKvnGQwVHoZvdcvnGegqr65EGknaTmIsNZ5cjx7xmkyQShMOilThtU8LlXtI9aKe0wuUqYfUOpH7sbyZ1vUCC56mxhYvdcvnGegqr65EGknaTmIsNZ5YXLR9lgfmv2dtuKL2Jjx(ZL4jXEascAlkxoUCDix4I(egGwXUOCDLlKCDMlX8nSHe9i9VrRC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKlhxU2Vyu4wRQrLefLK)nK4bNlKCTFXOGy(g2qs)B0s8GZLJlxN5A)IrbtL9WefzP9yYL)CvgOrJWDPaScINe7bijOTOCHKR9lgfmv2dt8GZ1vUUYLJlxN5QbHQgqcC190duP5nIsNZ5YxUbMlKCTFXOGy(g2qsdYRLOilThtU8L7V5cjxhY1(fJcC190duP5nIIS0Em5YxUkd0Or4UuawbXtI9aKe0wuUUUHkd0O5gAaAf7IUG7jyE03)VHkd0O5g6Uua2BinQTNWV84cUNGPJE))gsJA7j8lpUHkd0O5gwVrQmqJgPVnGBOVna5Ow0nmQEpaB9UGl4gItr95b3)VNG59)BOYanAUHgKxlPnPw3qAuBpHF5XfCpjW7)3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0n0atEVeOfucyegGwr17ZLVCXmxi56mxhYfOEAacdqlpQWf0O2EcpxoUCbQNgGWaiVxljE1rGGg12t456kxoUCnWK3lbAbLagHbOvu9(C5l3aVHFAjh1IUHTrQi6cUNC89)BinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gAGjVxc0ckbmcdqRyxuU8LlM3WpTKJAr3W2izEs)Ol4EYFV)FdPrT9e(Lh3qw1aQA9g6mxhYLH(OrhGyAOybYOs5YXLRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUUYfsU2VyuWuzpmXd(gQmqJMBOnvgQo3d0l4EYV3)VH0O2Ec)YJBiRAavTEdTFXOGPYEyIh8nuzGgn3qyeOrZfCp5pU)FdvgOrZn8zizdilZnKg12t4xECb3tC87)3qAuBpHF5XnKvnGQwVHFA1QTNeTrQi6gAavZa3tW8gQmqJMBy9gPYanAK(2aUH(2aKJAr3qfrxW9KJ(()nKg12t4xECdzvdOQ1By9gkIkOKa0wKBuns8Iul7EWPsqb9xddt43qdOAg4EcM3qLbA0CdR3ivgOrJ03gWn03gGCul6gIxKAz3dovxW9eh9()nKg12t4xECdzvdOQ1By9gkIkOKWw96WijkkvVxcW2duJGc6VggMWVHgq1mW9emVHkd0O5gwVrQmqJgPVnGBOVna5Ow0n0gPGl4EcMyC))gsJA7j8lpUHSQbu16n0tFKpx(Y9xmUHkd0O5gwVrQmqJgPVnGBOVna5Ow0n0aUG7jyI59)BinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gcx0NWDPaS3WpTKJAr3q4I(KUlfG9cUNGzG3)VH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBiCrFcdqRyx0n8tl5Ow0neUOpPbOvSl6cUNG5X3)VH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBiCrFcdqlZRGs3WpTKJAr3q4I(KgGwMxbLUG7jy(37)3qAuBpHF5XnuzGgn3W6nsLbA0i9TbCd9Tbih1IUHWfbRagwPbCbxWn0gPG7)3tW8()nKg12t4xECdzvdOQ1BO9lgfmv2dt8GVHkd0O5gw6hnONrglAccVxW9KaV)FdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qhY1(fJcB1RdJKOOu9EjaBpqnYrbVIep4CHKRd5A)IrHT61HrsuuQEVeGThOgPwmDiXd(g(PLCul6gYQgmiWd(cUNC89)BinQTNWV84gYQgqvR3qN5A)IrHT61HrsuuQEVeGThOg5OGxrIIS0Em5YxU)v8BUCC5A)IrHT61HrsuuQEVeGThOgPwmDirrwApMC5l3)k(nxx5cjx1ak1lHrUPkx(oKRJIrUqY1zUmeYJJCpcMk7HjkYs7XKlF5645YXLRZCziKhh5EeKfmYnvsB0GlkYs7XKlF5645cjxhY1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4CHKld9rJoaXzERwNCDLRRBOYanAUHmDyKxA)IXBO9lgLJAr3qdqlpQWVG7j)9()nKg12t4xECdzvdOQ1BOd5(PvR2EsWQgmiWdoxi56mxN56qUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUoK7NwTA7jbdnFOZKKHg8g0OjxoUCDixg6JgDaIPHIfiJkLRRCHKRZCzOpA0biMgkwGmQuUCC56mxgc5XrUhbtL9WefzP9yYLVCD8C54Y1zUmeYJJCpcYcg5MkPnAWffzP9yYLVCD8CHKRd5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUqYLH(OrhG4mVvRtUUY1vUUY1vUCC56mxgc5XrUhbdnFOZKeGLKg4UAGr8GZfsUmeYJJCpcMk7HjksX5nxi5YqF0OdqmnuSazuPCDDdvgOrZn0a0Y8kO0fCp537)3qAuBpHF5XnuzGgn3qfxHb9hjnU1Y6gYQgqvR3qhYfhbekUcd6psACRLLexTuOKa0SZ9anxi56qUkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflixi56mxhYfhbekUcd6psACRLLelPEbOzN7bAUCC5IJacfxHb9hjnU1YsILuVOilThtU8L7V56kxoUCXraHIRWG(JKg3AzjXvlfkjmaLDox(Z94CHKlociuCfg0FK04wlljUAPqjrrwApMC5p3JZfsU4iGqXvyq)rsJBTSK4QLcLeGMDUhO3qgVmpjbAbLaM7jyEb3t(J7)3qAuBpHF5XnuzGgn3qZBIDr3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5I5FKlKCvyjdlXoNlKCDM7NwTA7jbRAWGap4C54Y1zUQbuQxcJCtvU8N7XyKlKCDix7xmkyQShM4bNRRC54YLHqECK7rWuzpmrrkoV566gY4L5jjqlOeWCpbZl4EIJF))gsJA7j8lpUHkd0O5gAHqtSl6gYQgqvR3WIIfzWQ2Ekxi5c0ckbeG2IKaKeVPC5lxmpw8BUqYvHLmSe7CUqY1zUFA1QTNeSQbdc8GZLJlxN5QgqPEjmYnv5YFUhJrUqY1HCTFXOGPYEyIhCUUYLJlxgc5XrUhbtL9WefP48MRRCHKRd5A)IrX5EWlcxswWi3uzrdqsdvq7GqIh8nKXlZtsGwqjG5EcMxW9KJ(()nKg12t4xECdvgOrZn0aiVxlz0RfDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlM)rUbKBrwApMCHKRclzyj25CHKRZC)0QvBpjyvdge4bNlhxUQbuQxcJCtvU8N7XyKlhxUmeYJJCpcMk7HjksX5nxx3qgVmpjbAbLaM7jyEb3tC07)3qAuBpHF5XnKvnGQwVHkSKHLyNVHkd0O5ggrfJKOOCuWROl4EcMyC))gsJA7j8lpUHSQbu16n0zUeZ3Wgs0JuhEZLJlxI5BydjmiVwYEKyMlhxUeZ3Wgs4FJwYEKyMRRCHKRZCDixg6JgDaIPHIfiJkLlhxUoZvnGs9syKBQYL)CD0FZfsUoZ9tRwT9KGvnyqGhCUCC5QgqPEjmYnv5YFUhJrUCC5(PvR2Es0gPIOCDLlKCDM7NwTA7jbdnFOZKeNm8oSCHKRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUFA1QTNem08HotsCYW7WYfsUoKldH84i3JGPYEyIhCUUY1vUUYfsUoZLHqECK7rWuzpmrrwApMC5l3JXixoUCvdOuVeg5MQC5lxhfJCHKldH84i3JGPYEyIhCUqY1zUmeYJJCpcYcg5MkPnAWffzP9yYL)CvgOrJWa0k2fjiEsShGKG2IYLJlxhYLH(OrhG4mVvRtUUYLJl3ydflqwKL2Jjx(ZftmY1vUqY1zU4iGqXvyq)rsJBTSK4QLcLefzP9yYLVC)BUCC56qUm0hn6aedXkKhv4566gQmqJMBy8v8krrj5FdDb3tWeZ7)3qAuBpHF5XnKvnGQwVHoZLy(g2qc)B0soepb5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixoUCTFXOWw96WijkkvVxcW2duJCuWRirrwApMC5l3)k(nxoUCTFXOWw96WijkkvVxcW2duJulMoKOilThtU8L7Ff)MlhxUQbuQxcJCtvU8LRJIrUqYLHqECK7rWuzpmrrkoV56kxi56mxgc5XrUhbtL9WefzP9yYLVCpgJC54YLHqECK7rWuzpmrrkoV56kxoUCJnuSazrwApMC5pxmX4gQmqJMB45EWlcxAG7QbMl4EcMbE))gsJA7j8lpUHSQbu16n0zUQbuQxcJCtvU8LRJIrUqY1zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUoKld9rJoaXzERwNCDLlhxUm0hn6aetdflqgvkxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIIS0Em5YFUbIrUbKRZC)BUosUm0G)AGaUiwBiP6BOJfnabnQTNWZ1vUUYfsUoZ1HCzOpA0biMgkwGmQuUCC5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC5gBOybYIS0Em5YFUmeYJJCpcgA(qNjjaljnWD1aJOilThtUbK7FKlhxUXgkwGSilThtUhjxmpAmYL)CdeJCdixN5(3CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDDdvgOrZnKrEYaA1lvFdDSObCb3tW847)3qAuBpHF5XnKvnGQwVHoZvnGs9syKBQYLVCDumYfsUoZ1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4C54Y1HCzOpA0bioZB16KRRC54YLH(OrhGyAOybYOs5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdquKL2Jjx(Z9ymYnGCDM7FZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY1vUqY1zUoKld9rJoaX0qXcKrLYLJlxgc5XrUhbdnFOZKeGLKg4UAGr8GZLJl3pTA12tcgA(qNjjoz4Dy5cj3ydflqwKL2Jjx(YfZJgJCdi3aXi3aY1zU)nxhjxgAWFnqaxeRnKu9n0XIgGGg12t456kxoUCJnuSazrwApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jj3aY9pYLJl3ydflqwKL2Jjx(Z9ymYnGCDM7FZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY11nuzGgn3WEyAnkOrZfCpbZ)E))gsJA7j8lpUHSQbu16n0zUFA1QTNem08HotsCYW7WYfsUXgkwGSilThtU8LlMhJrUCC5A)IrbtL9Wep4CDLlKCDMR9lgf2QxhgjrrP69sa2EGAKJcEfjmaLDw(P(hLlF5Emg5YXLR9lgf2QxhgjrrP69sa2EGAKAX0HegGYol)u)JYLVCpgJCDLlhxUXgkwGSilThtU8NlMyCdvgOrZnKHMp0zscWssdCxnWCb3tW837)3qAuBpHF5XnKvnGQwVHm0hn6aetdflqgvkxi56m3pTA12tcgA(qNjjoz4Dy5YXLldH84i3JGPYEyIIS0Em5YFUyIrUUYfsUQbuQxcJCtvU8L7VyKlKCziKhh5Eem08HotsawsAG7QbgrrwApMC5pxmX4gQmqJMBObOL5vqPl4EcM)X9)BinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gsmFdBirps)B0kxhj3Jo3FYvzGgncdqRyxKG4jXEascAlk3aY1HCjMVHnKOhP)nALRJK7FK7p5QmqJgH7sbyfepj2dqsqBr5gqUyicm3FY1atEVeRAa0n8tl5Ow0nunW)jOkKyxW9emD87)3qAuBpHF5XnKvnGQwVHoZThavWiVciCzSHIfilYs7XKl)5(3C54Y1zU2Vyuu6hnONrglAccVIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3JXixx5cjx7xmkk9Jg0ZiJfnbHxXdoxx56kxoUCDMRAaL6LWi3uLBa5(PvR2EsOg4)eufsSCDKCTFXOGy(g2qsdYRLOilThtUbKlociIVIxjkkj)BibOzNnYIS0EY1rYnqXV5YxUygig5YXLRAaL6LWi3uLBa5(PvR2EsOg4)eufsSCDKCTFXOGy(g2qs)B0suKL2Jj3aYfhbeXxXRefLK)nKa0SZgzrwAp56i5gO43C5lxmdeJCDLlKCjMVHnKOhPo8MlKCDMRZCDixgc5XrUhbtL9Wep4C54YLH(OrhG4mVvRtUqY1HCziKhh5EeKfmYnvsB0GlEW56kxoUCzOpA0biMgkwGmQuUUYfsUoZ1HCzOpA0bi(ObGL3kxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8LRJIrUUYLJlx7xmkyQShMOilThtU8L7rNlKCDix7xmkk9Jg0ZiJfnbHxXd(gQmqJMBObOL5vqPl4EcMh99)BinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5goKBPfcnxW9emD07)3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94CDLlKCvyjdlXoFdvgOrZneR6JsleAUG7jbIX9)BinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5ggFEV0cHMl4EsGyE))gQmqJMBOBTQgvsuus(3q3qAuBpHF5XfCpjWaV)FdPrT9e(Lh3qw1aQA9gsmFdBirps)B0kxoUCjMVHnKWG8AjhINGC54YLy(g2qcD4voepb5YXLR9lgfU1QAujrrj5FdjEW5cjxI5Bydj6r6FJw5YXLRZCTFXOGPYEyIIS0Em5YFUkd0Or4UuawbXtI9aKe0wuUqY1(fJcMk7HjEW566gQmqJMBObOvSl6cUNe4X3)VHkd0O5g6Uua2BinQTNWV84cUNe4FV)FdPrT9e(Lh3qLbA0CdR3ivgOrJ03gWn03gGCul6ggvVhGTExWfCdveD))EcM3)VH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBOZCTFXOa0wKBuns8Iul7EWPsuKL2Jjx(ZfkdxyP8m3aYfdbM5YXLR9lgfG2ICJQrIxKAz3dovIIS0Em5YFUkd0OryaAf7Ieepj2dqsqBr5gqUyiWmxi56mxI5Bydj6r6FJw5YXLlX8nSHegKxl5q8eKlhxUeZ3WgsOdVYH4jixx56kxi5A)IrbOTi3OAK4fPw29GtL4bNlKCR3qrubLeG2ICJQrIxKAz3dovckO)Ayyc)g(PLCul6gIxKAjD3EVmQEVefJxW9KaV)FdPrT9e(Lh3qw1aQA9gA)IrHbOvu9ErrXImyvBpLlKCDMRbM8EjqlOeWimaTIQ3Nl)5ECUCC56qU1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmHNRRCHKRZCDi36nuevqjHNxMwQrg9eb6bQeQVTGnKGc6VggMWZLJlxqBr5EKC)7V5YxU2VyuyaAfvVxuKL2Jj3aYnWCDDdvgOrZn0a0kQE)fCp547)3qAuBpHF5XnKvnGQwVH1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmHNlKCnWK3lbAbLagHbOvu9(C57qUhNlKCDMRd5A)IrbOTi3OAK4fPw29GtL4bNlKCTFXOWa0kQEVOOyrgSQTNYLJlxN5(PvR2EsGxKAjD3EVmQEVefJ5cjxN5A)IrHbOvu9ErrwApMC5p3JZLJlxdm59sGwqjGryaAfvVpx(YnWCHKlq90aega59AjXRoce0O2Ecpxi5A)IrHbOvu9ErrwApMC5p3FZ1vUUY11nuzGgn3qdqRO69xW9K)E))gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHQbuQxcJCtvU8L7rJrUo2CDMlMyKRJKR9lgfG2ICJQrIxKAz3dovcdqzNZ1vUo2CDMR9lgfgGwr17ffzP9yY1rY94C)jxdm59sSQbq56kxhBUoZfhbeXxXRefLK)nKOilThtUosU)MRRCHKR9lgfgGwr17fp4B4NwYrTOBObOvu9EPB0aKr17LOy8cUN879)BinQTNWV84gYQgqvR3WpTA12tc8IulP727Lr17LOymxi5(PvR2EsyaAfvVx6gnazu9EjkgVHkd0O5gAaAzEfu6cUN8h3)VH0O2Ec)YJBOYanAUHM3e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZ)MRJnxdm59sGwqjGj3aYTilThtUqYvHLmSe7CUqYLy(g2qIEK6W7nKXlZtsGwqjG5EcMxW9eh)()nKg12t4xECdvgOrZnuXvyq)rsJBTSUHSQbu16n0HCbn7CpqZfsUoKRYanAekUcd6psACRLLexTuOKOhz03qXcYLJlxCeqO4kmO)iPXTwwsC1sHscdqzNZL)Cpoxi5IJacfxHb9hjnU1YsIRwkusuKL2Jjx(Z94BiJxMNKaTGsaZ9emVG7jh99)BinQTNWV84gQmqJMBOfcnXUOBiRAavTEdlkwKbRA7PCHKlqlOeqaAlscqs8MYLVCDMlM)n3aY1zUgyY7LaTGsaJWa0k2fLRJKlMIFZ1vUUY9NCnWK3lbAbLaMCdi3IS0Em5cjxN56mxgc5XrUhbtL9WefP48MlhxUgyY7LaTGsaJWa0k2fLl)5ECUCC56mxI5Bydj6rAqETYLJlxI5Bydj6rAJayZLJlxI5Bydj6r6FJw5cjxhYfOEAacd65LOOeGLKrurgGGg12t45YXLR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLlFhYnWFXixx5cjxN5AGjVxc0ckbmcdqRyxuU8NlMyKRJKRZCXm3aYfOEAacG7EKwi0ye0O2Ecpxx56kxi5QgqPEjmYnv5YxU)IrUo2CTFXOWa0kQEVOilThtUosU)rUUYfsUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5cjxfwYWsSZ566gY4L5jjqlOeWCpbZl4EIJE))gsJA7j8lpUHSQbu16nuHLmSe78nuzGgn3WiQyKefLJcEfDb3tWeJ7)3qAuBpHF5XnKvnGQwVH2VyuWuzpmXd(gQmqJMByPF0GEgzSOji8Eb3tWeZ7)3qAuBpHF5XnKvnGQwVHoZ1(fJcdqRO69IhCUCC5QgqPEjmYnv5YxU)IrUUYfsUoKR9lgfgK3aAgjEW5cjxhY1(fJcMk7HjEW5cjxN52dGkyKxbeUm2qXcKfzP9yYL)CziKhh5Eem08HotsawsAG7QbgrrwApMCdixhpxoUC7bqfmYRacxgBOybYIS0Em5EKCX8OXix(ZnWaZLJlxgc5XrUhbdnFOZKeGLKg4UAGr8GZLJlxhYLH(OrhGyAOybYOs566gQmqJMBiJ8Kb0QxQ(g6yrd4cUNGzG3)VH0O2Ec)YJBiRAavTEdJnuSazrwApMC5pxm)nxoUCDMR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLl)5g4VyKlhxU2VyuaxTfQWB1l1IPtZKWpVrlXN6FuU8Di3a)fJCDLlKCTFXOWa0kQEV4bNlKCziKhh5Eemv2dtuKL2Jjx(Y9xmUHkd0O5g2dtRrbnAUG7jyE89)BinQTNWV84gQmqJMBObqEVwYOxl6gYQgqvR3WIIfzWQ2Ekxi5cAlscqs8MYLVCX83CHKRbM8EjqlOeWimaTIDr5YFU)nxi5QWsgwIDoxi56mx7xmkyQShMOilThtU8LlMyKlhxUoKR9lgfmv2dt8GZ11nKXlZtsGwqjG5EcMxW9em)79)BinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gA)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb(lg56yZvnGs9syKBQYfsUoZLHqECK7rWuzpmrrwApMCdixmXix(Yn2qXcKfzP9yYLJlxgc5XrUhbtL9WefzP9yYnGCpgJC5p3ydflqwKL2Jjxi5gBOybYIS0Em5YxUyEmg5YXLR9lgfmv2dtuKL2Jjx(Y1XZ1vUqYLy(g2qIEK6WBUCC5gBOybYIS0Em5EKCXmqmYL)CX83B4NwYrTOBidnFOZKKHg8g0O5cUNG5V3)VH0O2Ec)YJBiRAavTEd)0QvBpjyO5dDMKm0G3Ggn5cjx1ak1lHrUPkx(Z9xmUHkd0O5gYqZh6mjbyjPbURgyUG7jy(h3)VH0O2Ec)YJBiRAavTEdjMVHnKOhPo8MlKCvyjdlXoNlKCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3a)fJCHKRZCXraHIRWG(JKg3AzjXvlfkjan7CpqZLJlxhYLH(OrhGyiwH8OcpxoUCnWK3lbAbLaMC5l3aZ11nuzGgn3W4R4vIIsY)g6cUNGPJF))gsJA7j8lpUHSQbu16n0(fJc0qaSgjmvmcg0Or8GZfsUoZ1(fJcdqRO69IIIfzWQ2EkxoUCvdOuVeg5MQC5lxhfJCDDdvgOrZn0a0kQE)fCpbZJ(()nKg12t4xECdzvdOQ1Bid9rJoaX0qXcKrLYfsUFA1QTNem08HotsgAWBqJMCHKldH84i3JGHMp0zscWssdCxnWikYs7XKl)5cLHlSuEMRJKlJAFUoZvnGs9syKBQY9NC)fJCDLlKCTFXOWa0kQEVOOyrgSQTNUHkd0O5gAaAfvV)cUNGPJE))gsJA7j8lpUHSQbu16nKH(OrhGyAOybYOs5cj3pTA12tcgA(qNjjdn4nOrtUqYLHqECK7rWqZh6mjbyjPbURgyefzP9yYL)CHYWfwkpZ1rYLrTpxN5QgqPEjmYnv5(tUhJrUUYfsU2VyuyaAfvVx8GVHkd0O5gAaAzEfu6cUNeig3)VH0O2Ec)YJBiRAavTEdTFXOaneaRrY8KwYV20Or8GZLJlxhY1a0k2fjuyjdlXoNlhxUoZ1(fJcMk7HjkYs7XKl)5(BUqY1(fJcMk7HjEW5YXLRZCTFXOO0pAqpJmw0eeEffzP9yYL)CHYWfwkpZ1rYLrTpxN5QgqPEjmYnv5(tUhJrUUYfsU2Vyuu6hnONrglAccVIhCUUY1vUqY9tRwT9KWa0kQEV0nAaYO69sumMlKCnWK3lbAbLagHbOvu9(C5p3JVHkd0O5gAaAzEfu6cUNeiM3)VH0O2Ec)YJBiRAavTEdDMlX8nSHe9i1H3CHKldH84i3JGPYEyIIS0Em5YxU)IrUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X56kxi5QWsgwID(gQmqJMB4qULwi0Cb3tcmW7)3qAuBpHF5XnKvnGQwVHoZLy(g2qIEK6WBUqYLHqECK7rWuzpmrrwApMC5l3FXixoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94CDLlKCvyjdlXoFdvgOrZneR6JsleAUG7jbE89)BinQTNWV84gYQgqvR3qN5smFdBirpsD4nxi5YqipoY9iyQShMOilThtU8L7VyKlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5ggFEV0cHMl4EsG)9()nuzGgn3q3AvnQKOOK8VHUH0O2Ec)YJl4EsG)E))gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHgyY7LaTGsaJWa0k2fLlF5(3Cdi3OhHQCDMRLAauXR8t9pk3FYnqmY1vUbKB0JqvUoZ1(fJcdqlZRGssYcg5MklAacdqzNZ9NC)BUUUHFAjh1IUHgGwXUizpsdYR1fCpjW)4()nKg12t4xECdzvdOQ1BiX8nSHe(3OLCiEcYLJlxI5Bydj0Hx5q8eKlKC)0QvBpjAJK5j9JYLJlx7xmkiMVHnK0G8AjkYs7XKl)5QmqJgHbOvSlsq8KypajbTfLlKCTFXOGy(g2qsdYRL4bNlhxUeZ3Wgs0J0G8ALlKCDi3pTA12tcdqRyxKShPb51kxoUCTFXOGPYEyIIS0Em5YFUkd0OryaAf7Ieepj2dqsqBr5cjxhY9tRwT9KOnsMN0pkxi5A)IrbtL9WefzP9yYL)CjEsShGKG2IYfsU2VyuWuzpmXdoxoUCTFXOO0pAqpJmw0eeEfp4CHKRbM8Ejw1aOC5lxme)rUqY1zUgyY7LaTGsatU8Fi3JZLJlxhYfOEAacd65LOOeGLKrurgGGg12t456kxoUCDi3pTA12tI2izEs)OCHKR9lgfmv2dtuKL2Jjx(YL4jXEascAl6gQmqJMBO7sbyVG7jb643)VHkd0O5gAaAf7IUH0O2Ec)YJl4EsGh99)BinQTNWV84gQmqJMBy9gPYanAK(2aUH(2aKJAr3WO69aS17cUGByu9Ea26D))EcM3)VH0O2Ec)YJBiRAavTEdDi36nuevqjHT61HrsuuQEVeGThOgbf0FnmmHFdvgOrZn0a0Y8kO0fCpjW7)3qAuBpHF5XnuzGgn3qZBIDr3qw1aQA9gIJacleAIDrIIS0Em5YxUfzP9yUHmEzEsc0ckbm3tW8cUNC89)BOYanAUHwi0e7IUH0O2Ec)YJl4cUHgW9)7jyE))gsJA7j8lpUHkd0O5gQ4kmO)iPXTww3qw1aQA9g6qU4iGqXvyq)rsJBTSK4QLcLeGMDUhO5cjxhYvzGgncfxHb9hjnU1YsIRwkus0Jm6BOyb5cjxN56qU4iGqXvyq)rsJBTSKyj1lan7CpqZLJlxCeqO4kmO)iPXTwwsSK6ffzP9yYLVC)nxx5YXLlociuCfg0FK04wlljUAPqjHbOSZ5YFUhNlKCXraHIRWG(JKg3AzjXvlfkjkYs7XKl)5ECUqYfhbekUcd6psACRLLexTuOKa0SZ9a9gY4L5jjqlOeWCpbZl4EsG3)VH0O2Ec)YJBOYanAUHwi0e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(YfZaZfsUoZ1(fJcMk7HjkYs7XKlF5(BUqY1zU2Vyuu6hnONrglAccVIIS0Em5YxU)MlhxUoKR9lgfL(rd6zKXIMGWR4bNRRC54Y1HCTFXOGPYEyIhCUCC5QgqPEjmYnv5YFUhJrUUYfsUoZ1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCvdOuVeg5MQC5p3JXixx5cjxfwYWsSZ3qgVmpjbAbLaM7jyEb3to(()nKg12t4xECdvgOrZn08Myx0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zU2VyuWuzpmrrwApMC5l3FZfsUoZ1(fJIs)Ob9mYyrtq4vuKL2Jjx(Y93C54Y1HCTFXOO0pAqpJmw0eeEfp4CDLlhxUoKR9lgfmv2dt8GZLJlx1ak1lHrUPkx(Z9ymY1vUqY1zUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRAaL6LWi3uLl)5Emg56kxi5QWsgwID(gY4L5jjqlOeWCpbZl4EYFV)FdPrT9e(Lh3qLbA0CdnaY71sg9Ar3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5I5FKlKCDMR9lgfmv2dtuKL2Jjx(Y93CHKRZCTFXOO0pAqpJmw0eeEffzP9yYLVC)nxoUCDix7xmkk9Jg0ZiJfnbHxXdoxx5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)CpgJCDLlKCDMRd5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUCC5QgqPEjmYnv5YFUhJrUUYfsUkSKHLyNVHmEzEsc0ckbm3tW8cUN879)BinQTNWV84gYQgqvR3qfwYWsSZ3qLbA0CdJOIrsuuok4v0fCp5pU)FdPrT9e(Lh3qw1aQA9gA)IrbtL9Wep4BOYanAUHL(rd6zKXIMGW7fCpXXV)FdPrT9e(Lh3qw1aQA9g6mxN5A)IrbX8nSHKgKxlrrwApMC5lxmXixoUCTFXOGy(g2qs)B0suKL2Jjx(YftmY1vUqYLHqECK7rWuzpmrrwApMC5l3JXixi56mx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(ZnW)IrUCC56qU1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHj8CDLRRC54Y1(fJc4QTqfEREPwmDAMe(5nAj(u)JYLVd5gOJJrUCC5YqipoY9iyQShMOifN3CHKRZCvdOuVeg5MQC5lxhfJC54Y9tRwT9KOnsfr566gQmqJMB45EWlcxAG7QbMl4EYrF))gsJA7j8lpUHSQbu16n0zUQbuQxcJCtvU8LRJIrUqY1zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUoKld9rJoaXzERwNCDLlhxUm0hn6aetdflqgvkxoUC)0QvBpjAJuruUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaefzP9yYL)CdeJCdixN56mxhnxhj36nuevqjbC1wOcVvVulMontc)8gTeuq)1WWeEUUYnGCDM7FZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY1vUUYfsUoKR9lgfmv2dt8GZfsUoZn2qXcKfzP9yYL)CziKhh5Eem08HotsawsAG7QbgrrwApMCdixhpxoUCJnuSazrwApMC5p3adm3aY1zUoAUosUoZ1(fJc4QTqfEREPwmDAMe(5nAj(u)JYLVCXedmY1vUUYLJl3ydflqwKL2Jj3JKlMhng5YFUbgyUCC5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUm0hn6aetdflqgvkxx3qLbA0CdzKNmGw9s13qhlAaxW9eh9()nKg12t4xECdzvdOQ1BOZCvdOuVeg5MQC5lxhfJCHKRZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmQuUCC5(PvR2Es0gPIOC54Y1(fJcBpcH7FgG4bNlKCTFXOW2Jq4(NbikYs7XKl)5Emg5gqUoZ1zUoAUosU1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHj8CDLBa56m3)MRJKldn4VgiGlI1gsQ(g6yrdqqJA7j8CDLRRCDLlKCDix7xmkyQShM4bNlKCDMBSHIfilYs7XKl)5YqipoY9iyO5dDMKaSK0a3vdmIIS0Em5gqUoEUCC5gBOybYIS0Em5YFUhhyUbKRZCD0CDKCDMR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLlF5IjgyKRRCDLlhxUXgkwGSilThtUhjxmpAmYL)CpoWC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y1HCzOpA0biMgkwGmQuUUUHkd0O5g2dtRrbnAUG7jyIX9)BinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gYqF0OdqmnuSazuPCHKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3a)lg5cjxN5YqipoY9iyQShMOilThtUbKlMyKlF5gBOybYIS0Em5YXLldH84i3JGPYEyIIS0Em5gqUhJrU8NBSHIfilYs7XKlKCJnuSazrwApMC5lxmpgJC54Y1(fJcMk7HjkYs7XKlF56456kxi5A)IrbX8nSHKgKxlrrwApMC5lxmXixoUCJnuSazrwApMCpsUygig5YFUy(BUUUHFAjh1IUHm08HotsgAWBqJMl4EcMyE))gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHoZ1HCziKhh5Eemv2dtuKIZBUCC56qUFA1QTNem08HotsgAWBqJMCHKld9rJoaX0qXcKrLY11n8tl5Ow0n0OFKmIkjtL9WUG7jyg49)BinQTNWV84gYQgqvR3WpTA12tcgA(qNjjdn4nOrtUqYvnGs9syKBQYL)CpgJBOYanAUHm08HotsawsAG7QbMl4EcMhF))gsJA7j8lpUHSQbu16nKy(g2qIEK6WBUqYvHLmSe7CUqY1(fJc4QTqfEREPwmDAMe(5nAj(u)JYL)Cd8VyKlKCDMlociuCfg0FK04wlljUAPqjbOzN7bAUCC56qUm0hn6aedXkKhv456kxi5(PvR2Esy0psgrLKPYEy3qLbA0CdJVIxjkkj)BOl4EcM)9()nKg12t4xECdzvdOQ1BO9lgfOHaynsyQyemOrJ4bNlKCTFXOWa0kQEVOOyrgSQTNUHkd0O5gAaAfvV)cUNG5V3)VH0O2Ec)YJBiRAavTEdTFXOWa0YJkCrrwApMC5p3FZfsUoZ1(fJcI5BydjniVwIIS0Em5YxU)MlhxU2VyuqmFdBiP)nAjkYs7XKlF5(BUUYfsUQbuQxcJCtvU8LRJIXnuzGgn3qMomYlTFX4n0(fJYrTOBObOLhv4xW9em)J7)3qAuBpHF5XnKvnGQwVHm0hn6aetdflqgvkxi5(PvR2EsWqZh6mjzObVbnAYfsUmeYJJCpcgA(qNjjaljnWD1aJOilThtU8NlugUWs5zUosUmQ956mx1ak1lHrUPk3FY9ymY11nuzGgn3qdqlZRGsxW9emD87)3qAuBpHF5XnKvnGQwVHa1tdqyaK3RLeV6iqqJA7j8CHKRd5cupnaHbOLhv4cAuBpHNlKCTFXOWa0kQEVOOyrgSQTNYfsUoZ1(fJcI5Bydj9VrlrrwApMC5l3)ixi5smFdBirps)B0kxi5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb(lg5YXLR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLlFhYnWFXixi5QgqPEjmYnv5YxUokg5YXLlociuCfg0FK04wlljUAPqjrrwApMC5l3JoxoUCvgOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwqUUYfsUoKldH84i3JGPYEyIIuCEVHkd0O5gAaAfvV)cUNG5rF))gsJA7j8lpUHSQbu16n0(fJc0qaSgjZtAj)AtJgXdoxoUCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCTFXOGPYEyIhCUqY1zU2Vyuu6hnONrglAccVIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3JXixx5cjx7xmkk9Jg0ZiJfnbHxXdoxoUCDix7xmkk9Jg0ZiJfnbHxXdoxi56qUmeYJJCpIs)Ob9mYyrtq4vuKIZBUCC56qUm0hn6aeF0aWYBLRRC54YvnGs9syKBQYLVCDumYfsUeZ3Wgs0JuhEVHkd0O5gAaAzEfu6cUNGPJE))gsJA7j8lpUHSQbu16neOEAacdqlpQWf0O2Ecpxi56mx7xmkmaT8Ocx8GZLJlx1ak1lHrUPkx(Y1rXixx5cjx7xmkmaT8Ocxyak7CU8N7X5cjxN5A)IrbX8nSHKgKxlXdoxoUCTFXOGy(g2qs)B0s8GZ1vUqY1(fJc4QTqfEREPwmDAMe(5nAj(u)JYL)Cd0XXixi56mxgc5XrUhbtL9WefzP9yYLVCXeJC54Y1HC)0QvBpjyO5dDMKm0G3Ggn5cjxg6JgDaIPHIfiJkLRRBOYanAUHgGwMxbLUG7jbIX9)BinQTNWV84gYQgqvR3qN5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUb64yKlhxU2VyuaxTfQWB1l1IPtZKWpVrlXN6FuU8NBG)IrUqYfOEAacdG8ETK4vhbcAuBpHNRRCHKR9lgfeZ3WgsAqETefzP9yYLVCD8CHKlX8nSHe9iniVw5cjxhY1(fJc0qaSgjmvmcg0Or8GZfsUoKlq90aegGwEuHlOrT9eEUqYLHqECK7rWuzpmrrwApMC5lxhpxi56mxgc5XrUhX5EWlcxAG7QbgrrwApMC5lxhpxoUCDixg6JgDaIZ8wTo566gQmqJMBObOL5vqPl4EsGyE))gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNRRCHKRclzyj25CHK7NwTA7jHr)izevsMk7HDdvgOrZnCi3sleAUG7jbg49)BinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlKCDixg6JgDaIZ8wTo5YXLRZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxi5YqF0OdqCM3Q1jxx5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNlhxU2VyuWuzpmXdoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBiw1hLwi0Cb3tc847)3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxi56qUm0hn6aeN5TADYLJlxN5A)IrX5EWlcxswWi3uzrdqsdvq7GqIhCUqYLH(OrhG4mVvRtUUYLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxoUCTFXOGPYEyIhCUUYfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3W4Z7Lwi0Cb3tc8V3)VHkd0O5g6wRQrLefLK)n0nKg12t4xECb3tc837)3qAuBpHF5XnKvnGQwVHeZ3Wgs0J0)gTYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUCC5A)IrHBTQgvsuus(3qIhCUqY1(fJcI5Bydj9VrlXdoxoUCDMR9lgfmv2dtuKL2Jjx(ZvzGgnc3LcWkiEsShGKG2IYfsU2VyuWuzpmXdoxx3qLbA0CdnaTIDrxW9Ka)J7)3qLbA0CdDxka7nKg12t4xECb3tc0XV)FdPrT9e(Lh3qLbA0CdR3ivgOrJ03gWn03gGCul6ggvVhGTExWfCdHlIHSSvW9)7jyE))gQmqJMBOfcnN7rgrL1nKg12t4xECb3tc8()nuzGgn3q3LcWEdPrT9e(LhxW9KJV)FdvgOrZn0DPaS3qAuBpHF5XfCp5V3)VHkd0O5gAaAf7IUH0O2Ec)YJl4EYV3)VH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBOnYyYfsUrpcv56mxN5gBOybYIS0Em56yZnqmY1vU)KlMbIrUUYLVCJEeQY1zUoZn2qXcKfzP9yY1XMBG)MRJnxN5Ijg56i5cupnarpmTgf0OrqJA7j8CDLRJnxN5(3CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDL7p5I5rJrUUUHFAjh1IUHm08HotsCYW7WUGl4cUHFuzA0CpjqmcedmXiqmVHU1A6bQ5g(N(ppOXjbnp5pLJj3C)hlLBBbJkqUruL7FgErQLDp4u9NLBrb9xxeEUgKfLR(ailfq45YWQduYiYGpQEOCd0XKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbFu9q5IjgoMCdk08rfGWZnSTcQCn8oaLN5EKJKlaL7r90CTq4p)ZKlcMkfGQCDEex56etE6sKbFu9q5IjMoMCdk08rfGWZnSTcQCn8oaLN5EKJKlaL7r90CTq4p)ZKlcMkfGQCDEex56etE6sKbFu9q5IzGoMCdk08rfGWZnSTcQCn8oaLN5EKJKlaL7r90CTq4p)ZKlcMkfGQCDEex56etE6sKbFu9q5I5F4yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGZG)t)Nh04KGMN8NYXKBU)JLYTTGrfi3iQY9pdUigYYwb)z5wuq)1fHNRbzr5QpaYsbeEUmS6aLmIm4JQhk3FDm5guO5JkaHNByBfu5A4DakpZ9i5cq5Eupnx8(RnnAYfbtLcqvUo)XvUodKNUezWzW)P)ZdACsqZt(t5yYn3)Xs52wWOcKBev5(NPi6pl3Ic6VUi8Cnilkx9bqwkGWZLHvhOKrKbFu9q5gOJj3GcnFubi8CdBRGkxdVdq5zUh5i5cq5Eupnxle(Z)m5IGPsbOkxNhXvUoXKNUezWhvpuU)1XKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbFu9q5E0oMCdk08rfGWZnSTcQCn8oaLN5EKCbOCpQNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JQhkxmX0XKBqHMpQaeEUHTvqLRH3bO8m3JCKCbOCpQNMRfc)5FMCrWuPauLRZJ4kxNyYtxIm4JQhkxmd0XKBqHMpQaeEUHTvqLRH3bO8m3JCKCbOCpQNMRfc)5FMCrWuPauLRZJ4kxNyYtxIm4JQhkxm)RJj3GcnFubi8CdBRGkxdVdq5zUh5i5cq5Eupnxle(Z)m5IGPsbOkxNhXvUoXKNUezWhvpuUyE0oMCdk08rfGWZnSTcQCn8oaLN5EKCbOCpQNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JQhkxmDuhtUbfA(Ocq45g2wbvUgEhGYZCpsUauUh1tZfV)AtJMCrWuPauLRZFCLRtm5Plrg8r1dLBGy4yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGpQEOCd8xhtUbfA(Ocq45g2wbvUgEhGYZCpsUauUh1tZfV)AtJMCrWuPauLRZFCLRZa5PlrgCg8F6)8GgNe08K)uoMCZ9FSuUTfmQa5grvU)zgWFwUff0FDr45AqwuU6dGSuaHNldRoqjJid(O6HY9ODm5guO5JkaHNByBfu5A4DakpZ9ihjxak3J6P5AHWF(Njxemvkav568iUY1jM80Lid(O6HY1rDm5guO5JkaHNByBfu5A4DakpZ9ihjxak3J6P5AHWF(Njxemvkav568iUY1jM80Lid(O6HYftmCm5guO5JkaHNByBfu5A4DakpZ9ihjxak3J6P5AHWF(Njxemvkav568iUY1jM80Lid(O6HYfZ)WXKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbFu9q5I5r7yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGZG)t)Nh04KGMN8NYXKBU)JLYTTGrfi3iQY9pZgPG)SClkO)6IWZ1GSOC1hazPacpxgwDGsgrg8r1dLlMb6yYnOqZhvacp3W2kOY1W7auEM7rosUauUh1tZ1cH)8ptUiyQuaQY15rCLRtm5Plrg8r1dLlM)HJj3GcnFubi8CdBRGkxdVdq5zUhjxak3J6P5I3FTPrtUiyQuaQY15pUY15X80Lid(O6HYfth3XKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbNbh00cgvacp3JoxLbA0KRVnaJid(gcxOy7PByqBU8q96WOC)ts9A8m4G2C)tMbq2uLBG)90CdeJaXidodoOn3GcRoqjJJjdoOnxhBU)544eEUHiVw5YdsTezWbT56yZnOWQducpxGwqjGSJ5YudzYfGYLXlZtsGwqjGrKbh0MRJn3GgKf6JWZ9ndXiJrlEZ9tRwT9KjxNTGeNMlCrFsdqlZRGs56y5lx4I(egGwMxbLCjYGZGvgOrJraxedzzRGdwi0CUhzevwzWkd0OXiGlIHSSvqah(XDPaSzWkd0OXiGlIHSSvqah(XDPaSzWkd0OXiGlIHSSvqah(Xa0k2fLbRmqJgJaUigYYwbbC4NpTA12tNoQfDGHMp0zsItgEh2PFQ)rhSrgdKOhHkNoJnuSazrwApghBGy46iygigU4l6rOYPZydflqwKL2JXXg4VowNyIHJaupnarpmTgf0OrqJA7jCxowN)1ryOb)1abCrS2qs13qhlAacAuBpH7Y1rW8OXWvgCgCqBU)jLNe7bi8CPpQ4nxqBr5cWs5QmaQYTn5QFA7vBpjYGvgOrJ5Gb51sAtQvgSYanAmbC4NpTA12tNoQfDOnsfrN(P(hDWatEVeOfucyegGwr175dtioDaOEAacdqlpQWf0O2EcNJdOEAacdG8ETK4vhbcAuBpH7IJZatEVeOfucyegGwr175lWmyLbA0yc4WpFA1QTNoDul6qBKmpPF0PFQ)rhmWK3lbAbLagHbOvSlIpmZGvgOrJjGd)ytLHQZ9a90oEWPdm0hn6aetdflqgvIJZbgc5XrUhbdnFOZKeGLKg4UAGr8GDbX(fJcMk7HjEWzWkd0OXeWHFGrGgnN2Xd2VyuWuzpmXdodwzGgnMao8ZZqYgqwMmyLbA0yc4Wp1BKkd0Or6Bd40rTOdkIo1aQMboG5PD8WNwTA7jrBKkIYGvgOrJjGd)uVrQmqJgPVnGth1IoGxKAz3dovNAavZahW80oEOEdfrfusaAlYnQgjErQLDp4ujOG(RHHj8myLbA0yc4Wp1BKkd0Or6Bd40rTOd2ifCQbundCaZt74H6nuevqjHT61HrsuuQEVeGThOgbf0FnmmHNbRmqJgtah(PEJuzGgnsFBaNoQfDWaoTJh80h557xmYGvgOrJjGd)8PvR2E60rTOdWf9jDxka7PFQ)rhGl6t4Uua2myLbA0yc4WpFA1QTNoDul6aCrFsdqRyx0PFQ)rhGl6tyaAf7IYGvgOrJjGd)8PvR2E60rTOdWf9jnaTmVckD6N6F0b4I(egGwMxbLYGvgOrJjGd)uVrQmqJgPVnGth1IoaxeScyyLgqgCgSYanAmcfrh(0QvBpD6Ow0b8IulP727Lr17LOy80p1)OdoTFXOa0wKBuns8Iul7EWPsuKL2JHFOmCHLYZaWqGjhN9lgfG2ICJQrIxKAz3dovIIS0Em8RmqJgHbOvSlsq8KypajbTffagcmH4Ky(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaxUGy)IrbOTi3OAK4fPw29GtL4bdPEdfrfusaAlYnQgjErQLDp4ujOG(RHHj8myLbA0yekIc4WpgGwr17pTJhSFXOWa0kQEVOOyrgSQTNG40atEVeOfucyegGwr175)yoohQ3qrubLeG2ICJQrIxKAz3dovckO)Ayyc3feNouVHIOckj88Y0snYONiqpqLq9TfSHeuq)1WWeohhOTOJCK)(lF2VyuyaAfvVxuKL2JjGaDLbRmqJgJqruah(Xa0kQE)PD8q9gkIkOKa0wKBuns8Iul7EWPsqb9xddt4qmWK3lbAbLagHbOvu9E(oCmeNoy)IrbOTi3OAK4fPw29GtL4bdX(fJcdqRO69IIIfzWQ2EIJZ5NwTA7jbErQL0D79YO69sumcXP9lgfgGwr17ffzP9y4)yoodm59sGwqjGryaAfvVNVaHaupnaHbqEVws8QJabnQTNWHy)IrHbOvu9ErrwApg()1LlxzWkd0OXiuefWHF(0QvBpD6Ow0bdqRO69s3ObiJQ3lrX4PFQ)rhudOuVeg5Mk(oAmCSoXedhX(fJcqBrUr1iXlsTS7bNkHbOSZUCSoTFXOWa0kQEVOilThJJC8rmWK3lXQga5YX6ehbeXxXRefLK)nKOilThJJ8Rli2VyuyaAfvVx8GZGvgOrJrOikGd)yaAzEfu60oE4tRwT9KaVi1s6U9Ezu9EjkgH8PvR2EsyaAfvVx6gnazu9EjkgZGvgOrJrOikGd)yEtSl6ugVmpjbAbLaMdyEAhpuuSidw12tqaAbLacqBrsasI3eFy(xhRbM8EjqlOeWeqrwApgikSKHLyNHqmFdBirpsD4ndwzGgngHIOao8JIRWG(JKg3AzDkJxMNKaTGsaZbmpTJhCa0SZ9afIdkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflGJdhbekUcd6psACRLLexTuOKWau2z(pgcociuCfg0FK04wlljUAPqjrrwApg(podwzGgngHIOao8JfcnXUOtz8Y8KeOfucyoG5PD8qrXImyvBpbbOfuciaTfjbijEt85eZ)gGtdm59sGwqjGryaAf7ICemf)6Y1rmWK3lbAbLaMakYs7XaXPtgc5XrUhbtL9WefP48YXzGjVxc0ckbmcdqRyxe)hZX5Ky(g2qIEKgKxlooI5Bydj6rAJay54iMVHnKOhP)nAbXbG6PbimONxIIsawsgrfzacAuBpHZXz)IrbC1wOcVvVulMontc)8gTeFQ)r8DiWFXWfeNgyY7LaTGsaJWa0k2fXpMy4ioXmaG6PbiaU7rAHqJrqJA7jCxUGOgqPEjmYnv89lgow7xmkmaTIQ3lkYs7X4i)Hlioy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmefwYWsSZUYGvgOrJrOikGd)erfJKOOCuWROt74bfwYWsSZzWkd0OXiuefWHFk9Jg0ZiJfnbH3t74b7xmkyQShM4bNbRmqJgJqruah(HrEYaA1lvFdDSObCAhp40(fJcdqRO69IhmhNAaL6LWi3uX3Vy4cId2VyuyqEdOzK4bdXb7xmkyQShM4bdXzpaQGrEfq4YydflqwKL2JHFgc5XrUhbdnFOZKeGLKg4UAGruKL2JjahNJRhavWiVciCzSHIfilYs7XCKJG5rJb)bgihhdH84i3JGHMp0zscWssdCxnWiEWCCoWqF0OdqmnuSazujxzWkd0OXiuefWHF6HP1OGgnN2XdoTFXOWa0kQEV4bZXPgqPEjmYnv89lgUG4G9lgfgK3aAgjEWqCW(fJcMk7HjEWqC2dGkyKxbeUm2qXcKfzP9y4NHqECK7rWqZh6mjbyjPbURgyefzP9ycWX546bqfmYRacxgBOybYIS0Emh5iyE0yW)XbYXXqipoY9iyO5dDMKaSK0a3vdmIhmhNdm0hn6aetdflqgvYLYanAmcfrbC4NZ9GxeU0a3vdmN2XdXgkwGSilThd)y(lhNt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)a)fdoo7xmkGR2cv4T6LAX0Pzs4N3OL4t9pIVdb(lgUGy)IrHbOvu9EXdgcdH84i3JGPYEyIIS0Em89lgzWkd0OXiuefWHFmaY71sg9ArNY4L5jjqlOeWCaZt74HIIfzWQ2EccOTijajXBIpm)fIbM8EjqlOeWimaTIDr8)xikSKHLyNH40(fJcMk7HjkYs7XWhMyWX5G9lgfmv2dt8GDLbRmqJgJqruah(5tRwT90PJArhyO5dDMKm0G3GgnN(P(hDW(fJc4QTqfEREPwmDAMe(5nAj(u)J4pWFXWXQgqPEjmYnvqCYqipoY9iyQShMOilThtayIbFXgkwGSilThdhhdH84i3JGPYEyIIS0EmbCmg8hBOybYIS0EmqInuSazrwApg(W8ym44SFXOGPYEyIIS0Em854UGqmFdBirpsD4LJl2qXcKfzP9yoYrWmqm4hZFZGvgOrJrOikGd)WqZh6mjbyjPbURgyoTJh(0QvBpjyO5dDMKm0G3GgnqudOuVeg5Mk()fJmyLbA0yekIc4WpXxXRefLK)n0PD8aX8nSHe9i1HxikSKHLyNHy)IrbC1wOcVvVulMontc)8gTeFQ)r8h4VyaXjociuCfg0FK04wlljUAPqjbOzN7bkhNdm0hn6aedXkKhv4CCgyY7LaTGsadFb6kdwzGgngHIOao8JbOvu9(t74b7xmkqdbWAKWuXiyqJgXdgIt7xmkmaTIQ3lkkwKbRA7joo1ak1lHrUPIphfdxzWkd0OXiuefWHFmaTIQ3FAhpWqF0OdqmnuSazujiFA1QTNem08HotsgAWBqJgimeYJJCpcgA(qNjjaljnWD1aJOilThd)qz4clLNocJAVt1ak1lHrUP6i)IHli2VyuyaAfvVxuuSidw12tzWkd0OXiuefWHFmaTmVckDAhpWqF0OdqmnuSazujiFA1QTNem08HotsgAWBqJgimeYJJCpcgA(qNjjaljnWD1aJOilThd)qz4clLNocJAVt1ak1lHrUP6ihJHli2VyuyaAfvVx8GZGvgOrJrOikGd)yaAzEfu60oEW(fJc0qaSgjZtAj)AtJgXdMJZbdqRyxKqHLmSe7mhNt7xmkyQShMOilThd))cX(fJcMk7HjEWCCoTFXOO0pAqpJmw0eeEffzP9y4hkdxyP80ryu7DQgqPEjmYnvh5ymCbX(fJIs)Ob9mYyrtq4v8GD5cYNwTA7jHbOvu9EPB0aKr17LOyeIbM8EjqlOeWimaTIQ3Z)XzWkd0OXiuefWHFgYT0cHMt74bNeZ3Wgs0JuhEHWqipoY9iyQShMOilThdF)IbhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj25myLbA0yekIc4WpyvFuAHqZPD8GtI5Bydj6rQdVqyiKhh5Eemv2dtuKL2JHVFXGJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJDbrHLmSe7CgSYanAmcfrbC4N4Z7Lwi0CAhp4Ky(g2qIEK6Wlegc5XrUhbtL9WefzP9y47xm44CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yxquyjdlXoNbRmqJgJqruah(XTwvJkjkkj)BOmyLbA0yekIc4WpFA1QTNoDul6GbOvSls2J0G8AD6N6F0bdm59sGwqjGryaAf7I47Vbe9iu50snaQ4v(P(hDKaXWvarpcvoTFXOWa0Y8kOKKSGrUPYIgGWau25J8xxzWkd0OXiuefWHFCxka7PD8aX8nSHe(3OLCiEc44iMVHnKqhELdXtaKpTA12tI2izEs)ioo7xmkiMVHnK0G8AjkYs7XWVYanAegGwXUibXtI9aKe0wee7xmkiMVHnK0G8AjEWCCeZ3Wgs0J0G8AbXHpTA12tcdqRyxKShPb51IJZ(fJcMk7HjkYs7XWVYanAegGwXUibXtI9aKe0weeh(0QvBpjAJK5j9JGy)IrbtL9WefzP9y4N4jXEascAlcI9lgfmv2dt8G54SFXOO0pAqpJmw0eeEfpyigyY7LyvdG4ddXFaXPbM8EjqlOeWW)HJ54CaOEAacd65LOOeGLKrurgGGg12t4U44C4tRwT9KOnsMN0pcI9lgfmv2dtuKL2JHpINe7bijOTOmyLbA0yekIc4WpgGwXUOmyLbA0yekIc4Wp1BKkd0Or6Bd40rTOdr17byRxgCgSYanAmcBKcou6hnONrglAccVN2Xd2VyuWuzpmXdodwzGgngHnsbbC4NpTA12tNoQfDGvnyqGh8PFQ)rhCW(fJcB1RdJKOOu9EjaBpqnYrbVIepyioy)IrHT61HrsuuQEVeGThOgPwmDiXdodwzGgngHnsbbC4hMomYlTFX4PJArhmaT8Oc)0oEWP9lgf2QxhgjrrP69sa2EGAKJcEfjkYs7XW3Ff)YXz)IrHT61HrsuuQEVeGThOgPwmDirrwApg((R4xxqudOuVeg5Mk(o4OyaXjdH84i3JGPYEyIIS0Em854CCoziKhh5EeKfmYnvsB0GlkYs7XWNJdXb7xmko3dEr4sYcg5MklAasAOcAhes8GHWqF0OdqCM3Q1XLRmyLbA0ye2ifeWHFmaTmVckDAhp4WNwTA7jbRAWGapyioD6adH84i3JGHMp0zscWssdCxnWiEWCCo8PvR2EsWqZh6mjzObVbnA44CGH(OrhGyAOybYOsUG4KH(OrhGyAOybYOsCCoziKhh5Eemv2dtuKL2JHphNJZjdH84i3JGSGrUPsAJgCrrwApg(CCioy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmeg6JgDaIZ8wToUC5YfhNtgc5XrUhbdnFOZKeGLKg4UAGr8GHWqipoY9iyQShMOifNxim0hn6aetdflqgvYvgSYanAmcBKcc4WpkUcd6psACRL1PmEzEsc0ckbmhW80oEWbCeqO4kmO)iPXTwwsC1sHscqZo3duioOmqJgHIRWG(JKg3AzjXvlfkj6rg9nuSaioDahbekUcd6psACRLLelPEbOzN7bkhhociuCfg0FK04wlljws9IIS0Em89RlooCeqO4kmO)iPXTwwsC1sHscdqzN5)yi4iGqXvyq)rsJBTSK4QLcLefzP9y4)yi4iGqXvyq)rsJBTSK4QLcLeGMDUhOzWkd0OXiSrkiGd)yEtSl6ugVmpjbAbLaMdyEAhpuuSidw12tqaAbLacqBrsasI3eFy(hquyjdlXodX5NwTA7jbRAWGapyooNQbuQxcJCtf)hJbehSFXOGPYEyIhSloogc5XrUhbtL9WefP486kdwzGgngHnsbbC4hleAIDrNY4L5jjqlOeWCaZt74HIIfzWQ2EccqlOeqaAlscqs8M4dZJf)crHLmSe7meNFA1QTNeSQbdc8G54CQgqPEjmYnv8FmgqCW(fJcMk7HjEWU44yiKhh5Eemv2dtuKIZRlioy)IrX5EWlcxswWi3uzrdqsdvq7GqIhCgSYanAmcBKcc4Wpga59AjJETOtz8Y8KeOfucyoG5PD8qrXImyvBpbbOfuciaTfjbijEt8H5FeqrwApgikSKHLyNH48tRwT9KGvnyqGhmhNAaL6LWi3uX)XyWXXqipoY9iyQShMOifNxxzWkd0OXiSrkiGd)erfJKOOCuWROt74bfwYWsSZzWkd0OXiSrkiGd)eFfVsuus(3qN2XdojMVHnKOhPo8YXrmFdBiHb51s2JetooI5Bydj8VrlzpsmDbXPdm0hn6aetdflqgvIJZPAaL6LWi3uXVJ(leNFA1QTNeSQbdc8G54udOuVeg5Mk(pgdoUpTA12tI2ive5cIZpTA12tcgA(qNjjoz4DyqCGHqECK7rWqZh6mjbyjPbURgyepyooh(0QvBpjyO5dDMK4KH3HbXbgc5XrUhbtL9WepyxUCbXjdH84i3JGPYEyIIS0Em8DmgCCQbuQxcJCtfFokgqyiKhh5Eemv2dt8GH4KHqECK7rqwWi3ujTrdUOilThd)kd0OryaAf7Ieepj2dqsqBrCCoWqF0OdqCM3Q1XfhxSHIfilYs7XWpMy4cItCeqO4kmO)iPXTwwsC1sHsIIS0Em89xoohyOpA0bigIvipQWDLbRmqJgJWgPGao8Z5EWlcxAG7QbMt74bNeZ3Wgs4FJwYH4jGJJy(g2qcdYRLCiEc44iMVHnKqhELdXtahN9lgf2QxhgjrrP69sa2EGAKJcEfjkYs7XW3Ff)YXz)IrHT61HrsuuQEVeGThOgPwmDirrwApg((R4xoo1ak1lHrUPIphfdimeYJJCpcMk7HjksX51feNmeYJJCpcMk7HjkYs7XW3XyWXXqipoY9iyQShMOifNxxCCXgkwGSilThd)yIrgSYanAmcBKcc4WpmYtgqREP6BOJfnGt74bNQbuQxcJCtfFokgqCA)IrX5EWlcxswWi3uzrdqsdvq7GqIhmhNdm0hn6aeN5TADCXXXqF0OdqmnuSazujoo7xmkS9ieU)zaIhme7xmkS9ieU)zaIIS0Em8higb48Vocdn4VgiGlI1gsQ(g6yrdqqJA7jCxUG40bg6JgDaIPHIfiJkXXXqipoY9iyO5dDMKaSK0a3vdmIhmhxSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeWFWXfBOybYIS0Emh5iyE0yWFGyeGZ)6im0G)AGaUiwBiP6BOJfnabnQTNWD5kdwzGgngHnsbbC4NEyAnkOrZPD8Gt1ak1lHrUPIphfdioTFXO4Cp4fHljlyKBQSObiPHkODqiXdMJZbg6JgDaIZ8wToU44yOpA0biMgkwGmQehN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(pgJaC(xhHHg8xdeWfXAdjvFdDSObiOrT9eUlxqC6ad9rJoaX0qXcKrL44yiKhh5Eem08HotsawsAG7QbgXdMJ7tRwT9KGHMp0zsItgEhgKydflqwKL2JHpmpAmciqmcW5FDegAWFnqaxeRnKu9n0XIgGGg12t4U44InuSazrwApg(ziKhh5Eem08HotsawsAG7QbgrrwApMa(doUydflqwKL2JH)JXiaN)1ryOb)1abCrS2qs13qhlAacAuBpH7YvgSYanAmcBKcc4Wpm08HotsawsAG7QbMt74bNFA1QTNem08HotsCYW7WGeBOybYIS0Em8H5XyWXz)IrbtL9WepyxqCA)IrHT61HrsuuQEVeGThOg5OGxrcdqzNLFQ)r8DmgCC2VyuyREDyKefLQ3lby7bQrQfthsyak7S8t9pIVJXWfhxSHIfilYs7XWpMyKbRmqJgJWgPGao8JbOL5vqPt74bg6JgDaIPHIfiJkbX5NwTA7jbdnFOZKeNm8omoogc5XrUhbtL9WefzP9y4htmCbrnGs9syKBQ47xmGWqipoY9iyO5dDMKaSK0a3vdmIIS0Em8JjgzWkd0OXiSrkiGd)8PvR2E60rTOdQb(pbvHe70p1)OdeZ3Wgs0J0)gTCKJ(ikd0OryaAf7Ieepj2dqsqBrb4aX8nSHe9i9Vrlh5poIYanAeUlfGvq8KypajbTffagIapIbM8Ejw1aOmyLbA0ye2ifeWHFmaTmVckDAhp4ShavWiVciCzSHIfilYs7XW)F54CA)IrrPF0GEgzSOji8kkYs7XWpugUWs5PJWO27unGs9syKBQoYXy4cI9lgfL(rd6zKXIMGWR4b7YfhNt1ak1lHrUPkGpTA12tc1a)NGQqI5i2VyuqmFdBiPb51suKL2JjaCeqeFfVsuus(3qcqZoBKfzP94ibk(Lpmdedoo1ak1lHrUPkGpTA12tc1a)NGQqI5i2VyuqmFdBiP)nAjkYs7XeaociIVIxjkkj)BibOzNnYIS0ECKaf)YhMbIHlieZ3Wgs0JuhEH40PdmeYJJCpcMk7HjEWCCm0hn6aeN5TADG4adH84i3JGSGrUPsAJgCXd2fhhd9rJoaX0qXcKrLCbXPdm0hn6aeF0aWYBXX5G9lgfmv2dt8G54udOuVeg5Mk(CumCXXz)IrbtL9WefzP9y47OH4G9lgfL(rd6zKXIMGWR4bNbRmqJgJWgPGao8ZqULwi0CAhp40(fJcI5Bydj9VrlXdMJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJDbrHLmSe7CgSYanAmcBKcc4WpyvFuAHqZPD8Gt7xmkiMVHnK0)gTepyooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmho2fefwYWsSZzWkd0OXiSrkiGd)eFEV0cHMt74bN2VyuqmFdBiP)nAjEWCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCSlikSKHLyNZGvgOrJryJuqah(XTwvJkjkkj)BOmyLbA0ye2ifeWHFmaTIDrN2XdeZ3Wgs0J0)gT44iMVHnKWG8AjhINaooI5Bydj0Hx5q8eWXz)IrHBTQgvsuus(3qIhmeI5Bydj6r6FJwCCoTFXOGPYEyIIS0Em8RmqJgH7sbyfepj2dqsqBrqSFXOGPYEyIhSRmyLbA0ye2ifeWHFCxkaBgSYanAmcBKcc4Wp1BKkd0Or6Bd40rTOdr17byRxgCgSYanAmc8Iul7EWP6WNwTA7Pth1Ioy0ijbi5Zqsdm59N(P(hDWP9lgfG2ICJQrIxKAz3dovIIS0Em8bLHlSuEgagcmH4Ky(g2qIEK2iawooI5Bydj6rAqET44iMVHnKW)gTKdXtGloo7xmkaTf5gvJeVi1YUhCQefzP9y4tzGgncdqRyxKG4jXEascAlkameycXjX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbUCXX5G9lgfG2ICJQrIxKAz3dovIhCgSYanAmc8Iul7EWPkGd)yaAzEfu60oEWPdFA1QTNegnssas(mK0atEphNt7xmkk9Jg0ZiJfnbHxrrwApg(HYWfwkpDeg1ENQbuQxcJCt1rogdxqSFXOO0pAqpJmw0eeEfpyxU44udOuVeg5Mk(CumYGvgOrJrGxKAz3dovbC4hfxHb9hjnU1Y6ugVmpjbAbLaMdyEAhp4aociuCfg0FK04wlljUAPqjbOzN7bkehugOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwaeNoGJacfxHb9hjnU1YsILuVa0SZ9aLJdhbekUcd6psACRLLelPErrwApg((1fhhociuCfg0FK04wlljUAPqjHbOSZ8FmeCeqO4kmO)iPXTwwsC1sHsIIS0Em8FmeCeqO4kmO)iPXTwwsC1sHscqZo3d0myLbA0ye4fPw29Gtvah(XcHMyx0PmEzEsc0ckbmhW80oEOOyrgSQTNGa0ckbeG2IKaKeVj(WmqioDA)IrbtL9WefzP9y47xioTFXOO0pAqpJmw0eeEffzP9y47xoohSFXOO0pAqpJmw0eeEfpyxCCoy)IrbtL9Wepyoo1ak1lHrUPI)JXWfeNoy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmhNAaL6LWi3uX)Xy4cIclzyj2zxzWkd0OXiWlsTS7bNQao8J5nXUOtz8Y8KeOfucyoG5PD8qrXImyvBpbbOfuciaTfjbijEt8HzGqC60(fJcMk7HjkYs7XW3VqCA)IrrPF0GEgzSOji8kkYs7XW3VCCoy)IrrPF0GEgzSOji8kEWU44CW(fJcMk7HjEWCCQbuQxcJCtf)hJHlioDW(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo1ak1lHrUPI)JXWfefwYWsSZUYGvgOrJrGxKAz3dovbC4hdG8ETKrVw0PmEzEsc0ckbmhW80oEOOyrgSQTNGa0ckbeG2IKaKeVj(W8pG40P9lgfmv2dtuKL2JHVFH40(fJIs)Ob9mYyrtq4vuKL2JHVF54CW(fJIs)Ob9mYyrtq4v8GDXX5G9lgfmv2dt8G54udOuVeg5Mk(pgdxqC6G9lgfN7bViCjzbJCtLfnajnubTdcjEWCCQbuQxcJCtf)hJHlikSKHLyNDLbRmqJgJaVi1YUhCQc4WpruXijkkhf8k60oEqHLmSe7CgSYanAmc8Iul7EWPkGd)u6hnONrglAccVN2Xd2VyuWuzpmXdodwzGgngbErQLDp4ufWHFo3dEr4sdCxnWCAhp40P9lgfeZ3WgsAqETefzP9y4dtm44SFXOGy(g2qs)B0suKL2JHpmXWfegc5XrUhbtL9WefzP9y47ymCXXXqipoY9iyQShMOifN3myLbA0ye4fPw29Gtvah(HrEYaA1lvFdDSObCAhp40(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoohyOpA0bioZB164IJJH(OrhGyAOybYOsCCFA1QTNeTrQiIJZ(fJcBpcH7FgG4bdX(fJcBpcH7FgGOilThd)bIrao)RJWqd(Rbc4IyTHKQVHow0ae0O2Ec3fehSFXOGPYEyIhmeN9aOcg5vaHlJnuSazrwApg(ziKhh5Eem08HotsawsAG7QbgrrwApMaCCoUEaubJ8kGWLXgkwGSilThd)bgihxpaQGrEfq4YydflqwKL2J5ihbZJgd(dmqoogc5XrUhbdnFOZKeGLKg4UAGr8G54CGH(OrhGyAOybYOsUYGvgOrJrGxKAz3dovbC4NEyAnkOrZPD8Gt7xmko3dEr4sYcg5MklAasAOcAhes8G54CGH(OrhG4mVvRJloog6JgDaIPHIfiJkXX9PvR2Es0gPIioo7xmkS9ieU)zaIhme7xmkS9ieU)zaIIS0Em8Fmgb48Vocdn4VgiGlI1gsQ(g6yrdqqJA7jCxqCW(fJcMk7HjEWqC2dGkyKxbeUm2qXcKfzP9y4NHqECK7rWqZh6mjbyjPbURgyefzP9ycWX546bqfmYRacxgBOybYIS0Em8FCGCC9aOcg5vaHlJnuSazrwApMJCempAm4)4a54yiKhh5Eem08HotsawsAG7QbgXdMJZbg6JgDaIPHIfiJk5kdwzGgngbErQLDp4ufWHF(0QvBpD6Ow0bgA(qNjjdn4nOrZPFQ)rhyOpA0biMgkwGmQeeN2VyuaxTfQWB1l1IPtZKWpVrlXN6Fe)b(xmG4KHqECK7rWuzpmrrwApMaWed(6bqfmYRacxgBOybYIS0EmCCmeYJJCpcMk7HjkYs7XeWXyWFpaQGrEfq4YydflqwKL2JbspaQGrEfq4YydflqwKL2JHpmpgdoo7xmkyQShMOilThdFoUli2VyuqmFdBiPb51suKL2JHpmXGJRhavWiVciCzSHIfilYs7XCKJGzGyWpM)6kdwzGgngbErQLDp4ufWHF(0QvBpD6Ow0bJ(rYiQKmv2d70p1)OdoDGHqECK7rWuzpmrrkoVCCo8PvR2EsWqZh6mjzObVbnAGWqF0OdqmnuSazujxzWkd0OXiWlsTS7bNQao8ddnFOZKeGLKg4UAG50oE4tRwT9KGHMp0zsYqdEdA0arnGs9syKBQ4)VyKbRmqJgJaVi1YUhCQc4WpXxXRefLK)n0PD8aX8nSHe9i1HxikSKHLyNH4ehbekUcd6psACRLLexTuOKa0SZ9aLJZbg6JgDaIHyfYJkCxq(0QvBpjm6hjJOsYuzpSmyLbA0ye4fPw29Gtvah(Xa0Y8kO0PD8ad9rJoaX0qXcKrLG8PvR2EsWqZh6mjzObVbnAGOgqPEjmYnv8D4VyaHHqECK7rWqZh6mjbyjPbURgyefzP9y4hkdxyP80ryu7DQgqPEjmYnvh5ymCLbRmqJgJaVi1YUhCQc4Wpd5wAHqZPD8Gt7xmkiMVHnK0)gTepyooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmho2fefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0ye4fPw29Gtvah(bR6JsleAoTJhCA)IrbX8nSHK(3OL4bdXbg6JgDaIZ8wToCCoTFXO4Cp4fHljlyKBQSObiPHkODqiXdgcd9rJoaXzERwhxCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCmhN9lgfmv2dt8GDbrHLmSe7mKpTA12tcJ(rYiQKmv2dldwzGgngbErQLDp4ufWHFIpVxAHqZPD8Gt7xmkiMVHnK0)gTepyioWqF0OdqCM3Q1HJZP9lgfN7bViCjzbJCtLfnajnubTdcjEWqyOpA0bioZB164IJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJ54SFXOGPYEyIhSlikSKHLyNH8PvR2Esy0psgrLKPYEyzWkd0OXiWlsTS7bNQao8JBTQgvsuus(3qzWkd0OXiWlsTS7bNQao8JbOvSl60oEGy(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaoo7xmkCRv1OsIIsY)gs8GHy)IrbX8nSHK(3OL4bZX50(fJcMk7HjkYs7XWVYanAeUlfGvq8KypajbTfbX(fJcMk7HjEWUYGvgOrJrGxKAz3dovbC4h3LcWMbRmqJgJaVi1YUhCQc4Wp1BKkd0Or6Bd40rTOdr17byRxgCgSYanAmIO69aS17GbOL5vqPt74bhQ3qrubLe2QxhgjrrP69sa2EGAeuq)1WWeEgSYanAmIO69aS1lGd)yEtSl6ugVmpjbAbLaMdyEAhpGJacleAIDrIIS0Em8vKL2JjdwzGgngru9Ea26fWHFSqOj2fLbNbRmqJgJaUiyfWWknGdwi0e7IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMbcXP9lgfmv2dtuKL2JHVF54CW(fJcMk7HjEWCCQbuQxcJCtf)hJHlikSKHLyNZGvgOrJraxeScyyLgqah(X8Myx0PmEzEsc0ckbmhW80oEOOyrgSQTNGa0ckbeG2IKaKeVj(WmqioTFXOGPYEyIIS0Em89lhNd2VyuWuzpmXdMJtnGs9syKBQ4)ymCbrHLmSe7CgSYanAmc4IGvadR0ac4Wpga59AjJETOtz8Y8KeOfucyoG5PD8qrXImyvBpbbOfuciaTfjbijEt8HzGqCA)IrbtL9WefzP9y47xoohSFXOGPYEyIhmhNAaL6LWi3uX)Xy4cIclzyj25myLbA0yeWfbRagwPbeWHFIOIrsuuok4v0PD8Gclzyj25myLbA0yeWfbRagwPbeWHFyKNmGw9s13qhlAaN2XdovdOuVeg5Mk(Cum44SFXOW2Jq4(NbiEWqSFXOW2Jq4(NbikYs7XWFG)Hlioy)IrbtL9Wep4myLbA0yeWfbRagwPbeWHF6HP1OGgnN2XdovdOuVeg5Mk(Cum44SFXOW2Jq4(NbiEWqSFXOW2Jq4(NbikYs7XW)X)Hlioy)IrbtL9Wep4myLbA0yeWfbRagwPbeWHF(0QvBpD6Ow0bJ(rYiQKmv2d70p1)OdoWqipoY9iyQShMOifN3myLbA0yeWfbRagwPbeWHFIVIxjkkj)BOt74bI5Bydj6rQdVquyjdlXod5tRwT9KWOFKmIkjtL9WYGvgOrJraxeScyyLgqah(HPdJ8s7xmE6Ow0bdqlpQWpTJhSFXOWa0YJkCrrwApg()dioTFXOGy(g2qsdYRL4bZXz)IrbX8nSHK(3OL4b7cIAaL6LWi3uXNJIrgSYanAmc4IGvadR0ac4WpgGwMxbLoTJhC6GgeQAajmGI0Z9avAaAzeLoN54SFXOGPYEyIIS0Em8t8KypajbTfXX5aCrFcdqlZRGsUG40(fJcMk7HjEWCCQbuQxcJCtfFokgqiMVHnKOhPo86kdwzGgngbCrWkGHvAabC4hdqlZRGsN2XdoDqdcvnGegqr65EGknaTmIsNZCC2VyuWuzpmrrwApg(jEsShGKG2I44C4tRwT9KaUOpPbOL5vqjxqaQNgGWa0YJkCbnQTNWH40(fJcdqlpQWfpyoo1ak1lHrUPIphfdxqSFXOWa0YJkCHbOSZ8FmeN2VyuqmFdBiPb51s8G54SFXOGy(g2qs)B0s8GDbHHqECK7rWuzpmrrwApg(C8myLbA0yeWfbRagwPbeWHFmaTmVckDAhp40bniu1asyafPN7bQ0a0YikDoZXz)IrbtL9WefzP9y4N4jXEascAlIJZb4I(egGwMxbLCbX(fJcI5BydjniVwIIS0Em854qiMVHnKOhPb51cIda1tdqyaA5rfUGg12t4qyiKhh5Eemv2dtuKL2JHphpdwzGgngbCrWkGHvAabC4NHClTqO50oEWP9lgfeZ3Wgs6FJwIhmhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmc4IGvadR0ac4WpyvFuAHqZPD8Gt7xmkiMVHnK0)gTepyooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmhoMJZ(fJcMk7HjEWUGOWsgwIDgYNwTA7jHr)izevsMk7HLbRmqJgJaUiyfWWknGao8t859sleAoTJhCA)IrbX8nSHK(3OL4bZX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXCC2VyuWuzpmXd2fefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0yeWfbRagwPbeWHFCRv1OsIIsY)gkdwzGgngbCrWkGHvAabC4hdqRyx0PD8Gtniu1asyafPN7bQ0a0YikDodX(fJcMk7HjkYs7XWhXtI9aKe0wee4I(eUlfG1fhNth0GqvdiHbuKEUhOsdqlJO05mhN9lgfmv2dtuKL2JHFINe7bijOTioohGl6tyaAf7ICbXjX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbCC2Vyu4wRQrLefLK)nK4bdX(fJcI5Bydj9VrlXdMJZP9lgfmv2dtuKL2JHFLbA0iCxkaRG4jXEascAlcI9lgfmv2dt8GD5IJZPgeQAajWv3tpqLM3ikDoZxGqSFXOGy(g2qsdYRLOilThdF)cXb7xmkWv3tpqLM3ikYs7XWNYanAeUlfGvq8KypajbTf5kdwzGgngbCrWkGHvAabC4h3LcWMbRmqJgJaUiyfWWknGao8t9gPYanAK(2aoDul6qu9Ea26LbNbRmqJgJWaoO4kmO)iPXTwwNY4L5jjqlOeWCaZt74bhWraHIRWG(JKg3AzjXvlfkjan7CpqH4GYanAekUcd6psACRLLexTuOKOhz03qXcG40bCeqO4kmO)iPXTwwsSK6fGMDUhOCC4iGqXvyq)rsJBTSKyj1lkYs7XW3VU44WraHIRWG(JKg3AzjXvlfkjmaLDM)JHGJacfxHb9hjnU1YsIRwkusuKL2JH)JHGJacfxHb9hjnU1YsIRwkusaA25EGMbRmqJgJWac4Wpwi0e7IoLXlZtsGwqjG5aMN2XdfflYGvT9eeGwqjGa0wKeGK4nXhMbcXP9lgfmv2dtuKL2JHVFH40(fJIs)Ob9mYyrtq4vuKL2JHVF54CW(fJIs)Ob9mYyrtq4v8GDXX5G9lgfmv2dt8G54udOuVeg5Mk(pgdxqC6G9lgfN7bViCjzbJCtLfnajnubTdcjEWCCQbuQxcJCtf)hJHlikSKHLyNZGvgOrJryabC4hZBIDrNY4L5jjqlOeWCaZt74HIIfzWQ2EccqlOeqaAlscqs8M4dZaH40(fJcMk7HjkYs7XW3VqCA)IrrPF0GEgzSOji8kkYs7XW3VCCoy)IrrPF0GEgzSOji8kEWU44CW(fJcMk7HjEWCCQbuQxcJCtf)hJHlioDW(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoo1ak1lHrUPI)JXWfefwYWsSZzWkd0OXimGao8JbqEVwYOxl6ugVmpjbAbLaMdyEAhpuuSidw12tqaAbLacqBrsasI3eFy(hqCA)IrbtL9WefzP9y47xioTFXOO0pAqpJmw0eeEffzP9y47xoohSFXOO0pAqpJmw0eeEfpyxCCoy)IrbtL9Wepyoo1ak1lHrUPI)JXWfeNoy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmhNAaL6LWi3uX)Xy4cIclzyj25myLbA0yegqah(jIkgjrr5OGxrN2XdkSKHLyNZGvgOrJryabC4Ns)Ob9mYyrtq490oEW(fJcMk7HjEWzWkd0OXimGao8Z5EWlcxAG7QbMt74bNoTFXOGy(g2qsdYRLOilThdFyIbhN9lgfeZ3Wgs6FJwIIS0Em8HjgUGWqipoY9iyQShMOilThdFhJbeN2VyuaxTfQWB1l1IPtZKWpVrlXN6Fe)b(xm44COEdfrfusaxTfQWB1l1IPtZKWpVrlbf0FnmmH7YfhN9lgfWvBHk8w9sTy60mj8ZB0s8P(hX3HaDCm44yiKhh5Eemv2dtuKIZleNQbuQxcJCtfFokgCCFA1QTNeTrQiYvgSYanAmcdiGd)WipzaT6LQVHow0aoTJhCQgqPEjmYnv85OyaXP9lgfN7bViCjzbJCtLfnajnubTdcjEWCCoWqF0OdqCM3Q1Xfhhd9rJoaX0qXcKrL44(0QvBpjAJurehN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(deJaC60rDK6nuevqjbC1wOcVvVulMontc)8gTeuq)1WWeURaC(xhHHg8xdeWfXAdjvFdDSObiOrT9eUlxUG4G9lgfmv2dt8GH4m2qXcKfzP9y4NHqECK7rWqZh6mjbyjPbURgyefzP9ycWX54InuSazrwApg(dmWaC6OoIt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pIpmXadxU44InuSazrwApMJCempAm4pWa54yiKhh5Eem08HotsawsAG7QbgXdMJZbg6JgDaIPHIfiJk5kdwzGgngHbeWHF6HP1OGgnN2XdovdOuVeg5Mk(CumG40(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyoohyOpA0bioZB164IJJH(OrhGyAOybYOsCCFA1QTNeTrQiIJZ(fJcBpcH7FgG4bdX(fJcBpcH7FgGOilThd)hJraoD6Oos9gkIkOKaUAluH3QxQftNMjHFEJwckO)Ayyc3vao)RJWqd(Rbc4IyTHKQVHow0ae0O2Ec3LlxqCW(fJcMk7HjEWqCgBOybYIS0Em8ZqipoY9iyO5dDMKaSK0a3vdmIIS0Emb44CCXgkwGSilThd)hhyaoDuhXP9lgfWvBHk8w9sTy60mj8ZB0s8P(hXhMyGHlxCCXgkwGSilThZrocMhng8FCGCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKrLCLbRmqJgJWac4WpFA1QTNoDul6adnFOZKKHg8g0O50p1)Odm0hn6aetdflqgvcIt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)a)lgqCYqipoY9iyQShMOilThtayIbFXgkwGSilThdhhdH84i3JGPYEyIIS0EmbCmg8hBOybYIS0EmqInuSazrwApg(W8ym44SFXOGPYEyIIS0Em854UGy)IrbX8nSHKgKxlrrwApg(WedoUydflqwKL2J5ihbZaXGFm)1vgSYanAmcdiGd)8PvR2E60rTOdg9JKrujzQSh2PFQ)rhC6adH84i3JGPYEyIIuCE54C4tRwT9KGHMp0zsYqdEdA0aHH(OrhGyAOybYOsUYGvgOrJryabC4hgA(qNjjaljnWD1aZPD8WNwTA7jbdnFOZKKHg8g0ObIAaL6LWi3uX)XyKbRmqJgJWac4WpXxXRefLK)n0PD8aX8nSHe9i1HxikSKHLyNHy)IrbC1wOcVvVulMontc)8gTeFQ)r8h4FXaItCeqO4kmO)iPXTwwsC1sHscqZo3duoohyOpA0bigIvipQWDb5tRwT9KWOFKmIkjtL9WYGvgOrJryabC4hdqRO69N2Xd2VyuGgcG1iHPIrWGgnIhme7xmkmaTIQ3lkkwKbRA7PmyLbA0yegqah(HPdJ8s7xmE6Ow0bdqlpQWpTJhSFXOWa0YJkCrrwApg()fIt7xmkiMVHnK0G8AjkYs7XW3VCC2VyuqmFdBiP)nAjkYs7XW3VUGOgqPEjmYnv85OyKbRmqJgJWac4WpgGwMxbLoTJhyOpA0biMgkwGmQeKpTA12tcgA(qNjjdn4nOrdegc5XrUhbdnFOZKeGLKg4UAGruKL2JHFOmCHLYthHrT3PAaL6LWi3uDKJXWvgSYanAmcdiGd)yaAfvV)0oEaOEAacdG8ETK4vhbcAuBpHdXbG6PbimaT8OcxqJA7jCi2VyuyaAfvVxuuSidw12tqCA)IrbX8nSHK(3OLOilThdF)beI5Bydj6r6FJwqSFXOaUAluH3QxQftNMjHFEJwIp1)i(d8xm44SFXOaUAluH3QxQftNMjHFEJwIp1)i(oe4VyarnGs9syKBQ4ZrXGJdhbekUcd6psACRLLexTuOKOilThdFhnhNYanAekUcd6psACRLLexTuOKOhz03qXcCbXbgc5XrUhbtL9WefP48MbRmqJgJWac4WpgGwMxbLoTJhSFXOaneaRrY8KwYV20Or8G54SFXO4Cp4fHljlyKBQSObiPHkODqiXdMJZ(fJcMk7HjEWqCA)IrrPF0GEgzSOji8kkYs7XWpugUWs5PJWO27unGs9syKBQoYXy4cI9lgfL(rd6zKXIMGWR4bZX5G9lgfL(rd6zKXIMGWR4bdXbgc5XrUhrPF0GEgzSOji8kksX5LJZbg6JgDaIpAay5TCXXPgqPEjmYnv85OyaHy(g2qIEK6WBgSYanAmcdiGd)yaAzEfu60oEaOEAacdqlpQWf0O2EchIt7xmkmaT8Ocx8G54udOuVeg5Mk(CumCbX(fJcdqlpQWfgGYoZ)XqCA)IrbX8nSHKgKxlXdMJZ(fJcI5Bydj9VrlXd2fe7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aDCmG4KHqECK7rWuzpmrrwApg(Wedooh(0QvBpjyO5dDMKm0G3GgnqyOpA0biMgkwGmQKRmyLbA0yegqah(Xa0Y8kO0PD8Gt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aDCm44SFXOaUAluH3QxQftNMjHFEJwIp1)i(d8xmGaupnaHbqEVws8QJabnQTNWDbX(fJcI5BydjniVwIIS0Em854qiMVHnKOhPb51cId2VyuGgcG1iHPIrWGgnIhmehaQNgGWa0YJkCbnQTNWHWqipoY9iyQShMOilThdFooeNmeYJJCpIZ9GxeU0a3vdmIIS0Em854CCoWqF0OdqCM3Q1XvgSYanAmcdiGd)mKBPfcnN2XdoTFXOGy(g2qs)B0s8G54CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yxquyjdlXod5tRwT9KWOFKmIkjtL9WYGvgOrJryabC4hSQpkTqO50oEWP9lgfeZ3Wgs6FJwIhmehyOpA0bioZB16WX50(fJIZ9GxeUKSGrUPYIgGKgQG2bHepyim0hn6aeN5TADCXX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXCC2VyuWuzpmXd2fefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0yegqah(j(8EPfcnN2XdoTFXOGy(g2qs)B0s8GH4ad9rJoaXzERwhooN2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bdHH(OrhG4mVvRJlooNmSAbLmhcesrmSAbLKG2I4)xxCCmSAbLmhoMJZ(fJcMk7HjEWUGOWsgwIDgYNwTA7jHr)izevsMk7HLbRmqJgJWac4WpU1QAujrrj5FdLbRmqJgJWac4WpgGwXUOt74bI5Bydj6r6FJwCCeZ3WgsyqETKdXtahhX8nSHe6WRCiEc44SFXOWTwvJkjkkj)BiXdgI9lgfeZ3Wgs6FJwIhmhNt7xmkyQShMOilThd)kd0Or4UuawbXtI9aKe0wee7xmkyQShM4b7kdwzGgngHbeWHFCxkaBgSYanAmcdiGd)uVrQmqJgPVnGth1IoevVhGTE3qdmXUNGjgbEbxW9c]] )


end