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

        shooting_stars = 21648, -- 202342
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

            spend = function () return ( buff.oneths_perception.up and 0 or 50 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.15 ) ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 236168,

            ap_check = function() return check_for_ap_overcap( "starfall" ) end,

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
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

            spend = function () return ( buff.oneths_clear_vision.up and 0 or 30 ) * ( 1 - ( buff.timeworn_dreambinder.stack * 0.15 ) ) end,
            spendType = "astral_power",

            startsCombat = true,
            texture = 135730,

            ap_check = function() return check_for_ap_overcap( "starsurge" ) end,

            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )

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

            spend = function () return ( talent.soul_of_the_forest.enabled and buff.eclipse_solar.up ) and -7.5 or -6 end,
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
        damageDots = false,
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


    spec:RegisterPack( "Balance", 20201013, [[dGKz3cqiQu9iviOlrLOnbHpPIKYOikNIOAvQi1ROszwQOClis1Ui8lvOgMQIJPQYYeiptvjtdIKRbrSnvi6BquzCQiX5OsW6GiL5rL09ub7dQQdQIKQfcr5Hqu1evHqWfvHqOpQcH0jvHawPa1mPsODQI4NQqiAOQqGwQkeQEQGMQQs9vviu2Rk9xsnyLomLftfpgLjJkxgzZc9zi1OHkNwYRvv1SPQBtKDl1VbnCOCCvKKLR45KmDGRRkBhs(UagVkQopuL1RcP5JQ2VOV)UFFd5maDpjOpb953NFFj(4cF(6dYDdb4Hr3qmJ93qt3W2KOBiYmV1m6gIz45Hg397BOc(ggDdXbaykK2XhJUa4Eocgu6yvj98gOGnBSi4yvjXo(g68kp4iqFDUHCgGUNe0NG(87ZVVeFCHpFDdThahCUHHLeYFdXvCCuFDUHCKIDdpcZfzM3AgL7reMxXLbFeM7rKma0HMC)91z5g0NG(KbNbFeMlYJZA0KcPLbFeMlsp3tDooIl3qO3MCrgzsIm4JWCr65I84SgnXLlWg0eqxXCzMIu5cG5YWJ5jnWg0eqjUH(sbu3VVHCdzsovZrZ977j)UFFdP2C8e3fz3qi2nurGBOXafSVHOSPmhpDdrz(hDdLLRZlgfGsIcaNwZnKj5unhnIHKSQv5IFUOzCcj78CrKR75smFHPir1A)RTjxe56EUeZxyksOGEB0nDoixe56EUeZxyksynE6MohKlpFUoVyuakjkaCAn3qMKt1C0igsYQwLl(5AmqbBHcytSgsqNtShG0GsIYfrUYYvHrEVgydAcOekGnXAOCXp3F5YZNlX8fMIevR9V2MC55ZLy(ctrcf0BJUPZb5YZNlX8fMIewJNUPZb5kpx55YZNR7568IrbOKOaWP1CdzsovZrJ4HDdrzJUnj6gQSiPbq9trAfg59xW9KGUFFdP2C8e3fz3q2uaAk7gklx3ZfLnL54jHYIKga1pfPvyK3NlpFUYYvwUoVyuqmFHPiTc6TrmKKvTkxxZfnJtizNNlICDEXOGy(ctrAf0BJ4HLR8C55ZvwUoVyumgkQHpLoouFu8edjzvRY11CrZ4es255E6Czu5ZvwUMcmMxJbdqtUhN7xFYvEUiY15fJIXqrn8P0XH6JIN4HLR8CLNR8CrKRSCDEXOGy(ctrAf0BJ4HLlpFUeZxyksOGEB0nDoixE(CjMVWuKWA80nDoix55YZNRPaJ51yWa0Kl(56cFUHgduW(gQa2OEdA6cUN8197Bi1MJN4Ui7gAmqb7BOee2XAOBiBkanLDdhkoKcN54PCrKlWg0eqakjsdGAUIYf)C)DK5Iix3Z15fJI)vZneNMKWGbOrIAGMAAqxhLepSBidpMN0aBqta19KFxW9eK6(9nKAZXtCxKDdngOG9nu96yn0nKnfGMYUHdfhsHZC8uUiYfydAciaLePbqnxr5IFU)oYCrKR7568IrX)Q5gIttsyWa0irnqtnnORJsIh2nKHhZtAGnOjG6EYVl4EcsUFFdP2C8e3fz3qJbkyFdvaY7Trh92q3q2uaAk7gouCifoZXt5IixGnOjGausKga1CfLl(5(7iZfrUYY15fJcMPRMjgsYQwLl(5(7tU8856EUoVyuWmD1mXdlx55IixdtZWrS)5Iix3Z15fJI)vZneNMKWGbOrIAGMAAqxhLepSBidpMN0aBqta19KFxW9KJ8(9nKAZXtCxKDdztbOPSBOPaJ51yWa0KRR5ICFYfrUYY15fJcqjrbGtR5gYKCQMJgXqsw1QCXpx0moHKDEUNo3GYLNpx3Z15fJcqjrbGtR5gYKCQMJgXdlx53qJbkyFdhdf1WNshhQpkExW9eK7(9nKAZXtCxKDdztbOPSBOHPz4i2)CrKR7568IrbZ0vZepSCrKRSCDEXOausua40AUHmjNQ5OrmKKvTkx8ZfnJtizNNlpFUUNRZlgfGsIcaNwZnKj5unhnIhwUYZfrUgMMHJy)ZfrUUNRZlgfmtxnt8WYfrUYYnwOXb0djzvRY11CzqONdgOfmyJc(N0aCKwHvtbuIHKSQv56wUixU885gl04a6HKSQv56YC)DkFY11CdkOC55ZLbHEoyGwWGnk4FsdWrAfwnfqjEy5YZNR75YGOO2AGOl04a6Or5k)gAmqb7BiJ8KcuMxB(cDlrn4cUNCk3VVHuBoEI7ISBiBkanLDdnmndhX(NlICDpxNxmkyMUAM4HLlICLLRZlgfGsIcaNwZnKj5unhnIHKSQv5IFUOzCcj78C55Z19CDEXOausua40AUHmjNQ5Or8WYvEUiYvwUXcnoGEijRAvUUMldc9CWaTGbBuW)KgGJ0kSAkGsmKKvTkx3Yf5YLNp3yHghqpKKvTkxxM7Vt5tUUM7xbLlpFUmi0Zbd0cgSrb)tAaosRWQPakXdlxE(CDpxgef1wdeDHghqhnkx53qJbkyFdRMztBGc2xW9ex4(9nKAZXtCxKDdztbOPSBOHPz4i2)BOXafSVHr4WinmQBd8g6cUN87Z97Bi1MJN4Ui7gYMcqtz3qNxmkaLefaoTMBitYPAoAedjzvRYf)CrZ4es255Iixz5g9q4KRSCLLBSqJdOhsYQwLlsp3FFYvEUhNRXafS1mi0Zbd05kpx8Zn6HWjxz5kl3yHghqpKKvTkxKEU)(Klspxge65GbAbZ0vZedjzvRYvEUhNRXafS1mi0Zbd05kpxe5klxI5lmfjQwRGEBYLNpxI5lmfjuqVn6MohKlpFUoVyuWmD1mXqsw1QCXp3FFYLNpxNxmkWMscoCL512WSUyASNxzJaL5FuU4Fi3GqUp5IixtbgZRXGbOjx8ZfjFYvEUYVHgduW(g(VAUH40kSAkG6cUN87397Bi1MJN4Ui7gcXUHkcCdngOG9neLnL54PBikZ)OBOZlgfytjbhUY8ABywxmn2ZRSrGY8pkxxZniK6tUiYvwUmi0Zbd0cMPRMjgsYQwLRB5(7tU4NBSqJdOhsYQwLlpFUmi0Zbd0cMPRMjgsYQwLRB5(1NCDn3yHghqpKKvTkxe5gl04a6HKSQv5IFU)(6tU885gl04a6HKSQv56YC)f0NCDn3FijxE(CDEXOGz6QzIHKSQv5IFUixUYZfrUeZxyksuT2A8UHOSr3MeDdzWgf8pPzWMRafSVG7j)c6(9nKAZXtCxKDdztbOPSBikBkZXtcgSrb)tAgS5kqb7CrKRSCnfymVgdgGMCDnxK8jxe5IYMYC8KOuAds5YZNRPaJ51yWa0KRR5(1NCLNlICLLRZlgfGsIcaNwZnKj5unhnIHKSQv5IFU05e7binOKOC55Z19CDEXOausua40AUHmjNQ5Or8WYv(n0yGc23qgSrb)tAaosRWQPaQl4EYVVUFFdP2C8e3fz3q2uaAk7gsmFHPir1ARXlxe5AyAgoI9pxe5IYMYC8KqzrsdG6NI0kmY7ZfrUYYLdcegNHbkuKwfWgjnNjzOjbOy)RgDU8856EUmikQTgiAInqpC4YLNpxfg59AGnOjGkx8ZnOCLFdngOG9nm(g80WOM8VMUG7j)qQ733qQnhpXDr2nKnfGMYUH3qJbkyFdnodduOiTkGnsxW9KFi5(9nKAZXtCxKDdztbOPSBO75YGOO2AGOl04a6Or5Iixge65GbAbZ0vZedzC4LlICnfymVgdgGMCXpxK7Zn0yGc23qfWg1BqtxW9KFh597Bi1MJN4Ui7gYMcqtz3qgef1wdeDHghqhnkxe5IYMYC8KGbBuW)KMbBUcuWoxe5AkWyEngman5I)HC)6tUiYLbHEoyGwWGnk4FsdWrAfwnfqjgsYQwLRR5IMXjKSZZ905YOYNRSCnfymVgdgGMCpo3V(KR8BOXafSVHkGnQ3GMUG7j)qU733qQnhpXDr2nKnfGMYUHYY15fJcI5lmfP9V2gXdlxE(CLLldNnOjvUhYnOCrK7qmC2GM0GsIY11CrsUYZLNpxgoBqtQCpK7x5kpxe5AyAgoI9)gAmqb7Bytb0sqyFb3t(Dk3VVHuBoEI7ISBiBkanLDdLLRZlgfeZxyks7FTnIhwU885klxgoBqtQCpKBq5Ii3Hy4SbnPbLeLRR5IKCLNlpFUmC2GMu5Ei3VYvEUiY1W0mCe7FUiYvwUoVyuakjkaCAn3qMKt1C0igsYQwLl(5sNtShG0GsIYLNpx3Z15fJcqjrbGtR5gYKCQMJgXdlx53qJbkyFdXz(Owcc7l4EYpx4(9nKAZXtCxKDdztbOPSBOSCDEXOGy(ctrA)RTr8WYLNpxz5YWzdAsL7HCdkxe5oedNnOjnOKOCDnxKKR8C55ZLHZg0Kk3d5(vUYZfrUgMMHJy)ZfrUYY15fJcqjrbGtR5gYKCQMJgXqsw1QCXpx6CI9aKgusuU8856EUoVyuakjkaCAn3qMKt1C0iEy5k)gAmqb7By859AjiSVG7jb95(9n0yGc23Wa2mfC0WOM8VMUHuBoEI7ISl4Esq)UFFdP2C8e3fz3q2uaAk7gsmFHPir1A)RTjxE(CjMVWuKqb92OB6CqU885smFHPiH14PB6CqU88568IrraBMcoAyut(xtIhwUiY15fJcI5lmfP9V2gXdlxE(CLLRZlgfmtxntmKKvTkxxZ1yGc2IaJbWjOZj2dqAqjr5IixNxmkyMUAM4HLR8BOXafSVHkGnXAOl4EsqbD)(gAmqb7ByGXa4UHuBoEI7ISl4EsqFD)(gsT54jUlYUHgduW(goVwBmqbBTVuGBOVuaDBs0nmAEpa38UGl4gYrr75b3VVN87(9n0yGc23qf0BJ2HmPBi1MJN4Ui7cUNe097Bi1MJN4Ui7gcXUHkcCdngOG9neLnL54PBikZ)OBOcJ8EnWg0eqjuaBIM3Nl(5(lxe5klx3ZfyEQbcfWgpC4euBoEIlxE(CbMNAGqbiV3gn3urGGAZXtC5kpxE(CvyK3Rb2GMakHcyt08(CXp3GUHOSr3MeDdlL2G0fCp5R733qQnhpXDr2neIDdve4gAmqb7BikBkZXt3quM)r3qfg59AGnOjGsOa2eRHYf)C)DdrzJUnj6gwknZtgk6cUNGu3VVHuBoEI7ISBiBkanLDdLLR75YGOO2AGOl04a6Or5YZNR75YGqphmqlyWgf8pPb4iTcRMcOepSCLNlICDEXOGz6QzIh2n0yGc23qhAu08VA0xW9eKC)(gsT54jUlYUHSPa0u2n05fJcMPRMjEy3qJbkyFdXGGc2xW9KJ8(9n0yGc23WNI0fGKu3qQnhpXDr2fCpb5UFFdP2C8e3fz3q2uaAk7gIYMYC8KOuAds3qfykg4EYVBOXafSVHZR1gduWw7lf4g6lfq3MeDdniDb3toL733qQnhpXDr2nKnfGMYUHZRPiCqtcqjrbGtR5gYKCQMJgbDQEfggXDdvGPyG7j)UHgduW(goVwBmqbBTVuGBOVuaDBs0nKBitYPAoAUG7jUW97Bi1MJN4Ui7gYMcqtz3W51ueoOjHJ5TMrAyuBEVgGRA0kbDQEfggXDdvGPyG7j)UHgduW(goVwBmqbBTVuGBOVuaDBs0n0bAGl4EYVp3VVHuBoEI7ISBOXafSVHZR1gduWw7lf4g6lfq3MeDdvGl4cUHydXGsog4(99KF3VVHgduW(gkbH9)Q1r4iDdP2C8e3fzxW9KGUFFdngOG9nmWyaC3qQnhpXDr2fCp5R733qJbkyFddmga3nKAZXtCxKDb3tqQ733qQnhpXDr2nKnfGMYUHkmY71aBqtaLqbSjAEFUUMlsDdngOG9nubSr9g00fCpbj3VVHuBoEI7ISBie7gQiWn0yGc23qu2uMJNUHOm)JUHoqLkxe5g9q4KRSCLLBSqJdOhsYQwLlsp3G(KR8Cpo3Fb9jx55IFUrpeo5klxz5gl04a6HKSQv5I0ZniKKlspxz5(7tUNoxG5PgiQMztBGc2cQnhpXLR8Cr65klxKk3tNld2CVciWgIvksB(cDlrnqqT54jUCLNR8Cpo3FNYNCLFdrzJUnj6gYGnk4FsZrk8A2fCb3qds3VVN87(9nKAZXtCxKDdztbOPSBOZlgfkGnrZ7fdfhsHZC8uUiYvwUUN78Akch0KWJhZgtPJEIavJwJ2xsyksqNQxHHrC5YZNlOKOCDzUifsYf)CDEXOqbSjAEVyijRAvUULBq5k)gAmqb7BOcyt08(l4Esq3VVHuBoEI7ISBOXafSVHQxhRHUHSPa0u2n0W0mCe7FUiYLy(ctrIQ1wJxUiYDO4qkCMJNYfrUaBqtabOKinaQ5kkx8Z9hsLlspxfg59AGnOjGkx3YDijRA1nKHhZtAGnOjG6EYVl4EYx3VVHuBoEI7ISBOXafSVHsqyhRHUHSPa0u2nCO4qkCMJNYfrUaBqtabOKinaQ5kkx8ZvwU)qQCDlxz5QWiVxdSbnbucfWMynuUNo3FcKKR8CLN7X5QWiVxdSbnbu56wUdjzvRYfrUYYLbHEoyGwWmD1mXqghE5YZNRcJ8EnWg0eqjuaBI1q56AUFLlpFUYYLy(ctrIQ1kO3MC55ZLy(ctrIQ1oqaUC55ZLy(ctrIQ1(xBtUiY19CbMNAGqbFEnmQb4iDeoKciO2C8exUYZfrUYYvHrEVgydAcOekGnXAOCDn3FFY905kl3F56wUaZtnqacuTwccBLGAZXtC5kpx55IixtbgZRXGbOjx8ZfjFYfPNRZlgfkGnrZ7fdjzvRY905EK5kpxe56EUoVyu8VAUH40Kegmansud0utd66OK4HLlICnmndhX(Fdz4X8KgydAcOUN87cUNGu3VVHuBoEI7ISBiBkanLDdnmndhX(FdngOG9nmchgPHrDBG3qxW9eKC)(gsT54jUlYUHSPa0u2n05fJcMPRMjEy3qJbkyFdhdf1WNshhQpkExW9KJ8(9nKAZXtCxKDdztbOPSBOSCDEXOqbSjAEV4HLlpFUMcmMxJbdqtU4Nls(KR8CrKR7568IrHc6vGIrIhwUiY19CDEXOGz6QzIhwUiYvwUvdObd6naXPJfACa9qsw1QCDnxge65GbAbd2OG)jnahPvy1uaLyijRAvUULlYLlpFUvdObd6naXPJfACa9qsw1QCDzU)oLp56AUbfuU885YGqphmqlyWgf8pPb4iTcRMcOepSC55Z19CzquuBnq0fACaD0OCLFdngOG9nKrEsbkZRnFHULOgCb3tqU733qQnhpXDr2nKnfGMYUHXcnoGEijRAvUUM7pKKlpFUYY15fJcSPKGdxzETnmRlMg75v2iqz(hLRR5ges(KlpFUoVyuGnLeC4kZRTHzDX0ypVYgbkZ)OCX)qUbHKp5kpxe568IrHcyt08EXdlxe5YGqphmqlyMUAMyijRAvU4Nls(CdngOG9nSAMnTbkyFb3toL733qQnhpXDr2n0yGc23qfG8EB0rVn0nKnfGMYUHdfhsHZC8uUiYfusKga1CfLl(5(dj5Iixfg59AGnOjGsOa2eRHY11CrQCrKRHPz4i2)CrKRSCDEXOGz6QzIHKSQv5IFU)(KlpFUUNRZlgfmtxnt8WYv(nKHhZtAGnOjG6EYVl4EIlC)(gsT54jUlYUHqSBOIa3qJbkyFdrztzoE6gIY8p6g68Irb2usWHRmV2gM1ftJ98kBeOm)JY11CdcjFYfPNRPaJ51yWa0KlICLLldc9CWaTGz6QzIHKSQv56wU)(Kl(5gl04a6HKSQv5YZNldc9CWaTGz6QzIHKSQv56wUF9jxxZnwOXb0djzvRYfrUXcnoGEijRAvU4N7VV(KlpFUoVyuWmD1mXqsw1QCXpxKlx55IixI5lmfjQwBnE5YZNBSqJdOhsYQwLRlZ9xqFY11C)HKBikB0Tjr3qgSrb)tAgS5kqb7l4EYVp3VVHuBoEI7ISBiBkanLDdrztzoEsWGnk4FsZGnxbkyNlICnfymVgdgGMCDnxK85gAmqb7Bid2OG)jnahPvy1ua1fCp53V733qQnhpXDr2nKnfGMYUHeZxyksuT2A8YfrUgMMHJy)ZfrUoVyuGnLeC4kZRTHzDX0ypVYgbkZ)OCDn3GqYNCrKRSC5GaHXzyGcfPvbSrsZzsgAsak2)QrNlpFUUNldIIARbIMyd0dhUC55ZvHrEVgydAcOYf)Cdkx53qJbkyFdJVbpnmQj)RPl4EYVGUFFdP2C8e3fz3qJbkyFdnodduOiTkGns3q2uaAk7g6EUGI9VA05Iixfg59AGnOjGsOa2enVpxxZ1fUHm8yEsdSbnbu3t(Db3t(9197Bi1MJN4Ui7gYMcqtz3qNxmkGnbWP0y0WimqbBXdlxe5klxNxmkuaBIM3lgkoKcN54PC55Z1uGX8AmyaAYf)CDHp5k)gAmqb7BOcyt08(l4EYpK6(9nKAZXtCxKDdztbOPSBidIIARbIUqJdOJgLlICrztzoEsWGnk4FsZGnxbkyNlICzqONdgOfmyJc(N0aCKwHvtbuIHKSQv56AUOzCcj78CpDUmQ85klxtbgZRXGbOj3JZfjFYvEUiY15fJcfWMO59IHIdPWzoE6gAmqb7BOcyt08(l4EYpKC)(gsT54jUlYUHSPa0u2nKbrrT1arxOXb0rJYfrUOSPmhpjyWgf8pPzWMRafSZfrUmi0Zbd0cgSrb)tAaosRWQPakXqsw1QCDnx0moHKDEUNoxgv(CLLRPaJ51yWa0K7X5(1NCLNlICDEXOqbSjAEV4HDdngOG9nubSr9g00fCp53rE)(gsT54jUlYUHqSBOIa3qJbkyFdrztzoE6gIY8p6gAkWyEngman5IFUNYNCr65klxNxmkuaBIM3lgsYQwL7PZ9RCpoxfg59ACMcq5kpxKEUYYLdceX3GNgg1K)1KyijRAvUNoxKKR8CrKRZlgfkGnrZ7fpSBikB0Tjr3qfWMO596aWgOJM3RHX4fCp5hYD)(gsT54jUlYUHSPa0u2n05fJcytaCknZt2OrvQc2IhwU8856EUkGnXAiHHPz4i2)C55ZvwUoVyuWmD1mXqsw1QCDnxKKlICDEXOGz6QzIhwU885klxNxmkgdf1WNshhQpkEIHKSQv56AUOzCcj78CpDUmQ85klxtbgZRXGbOj3JZ9Rp5kpxe568IrXyOOg(u64q9rXt8WYvEUYZfrUOSPmhpjuaBIM3RdaBGoAEVggJ5Iixfg59AGnOjGsOa2enVpxxZ9RBOXafSVHkGnQ3GMUG7j)oL733qQnhpXDr2nKnfGMYUHYYLy(ctrIQ1wJxUiYLbHEoyGwWmD1mXqsw1QCXpxK8jxE(CLLldNnOjvUhYnOCrK7qmC2GM0GsIY11CrsUYZLNpxgoBqtQCpK7x5kpxe5AyAgoI9)gAmqb7Bytb0sqyFb3t(5c3VVHuBoEI7ISBiBkanLDdLLlX8fMIevRTgVCrKldc9CWaTGz6QzIHKSQv5IFUi5tU885klxgoBqtQCpKBq5Ii3Hy4SbnPbLeLRR5IKCLNlpFUmC2GMu5Ei3VYvEUiY1W0mCe7)n0yGc23qCMpQLGW(cUNe0N733qQnhpXDr2nKnfGMYUHYYLy(ctrIQ1wJxUiYLbHEoyGwWmD1mXqsw1QCXpxK8jxE(CLLldNnOjvUhYnOCrK7qmC2GM0GsIY11CrsUYZLNpxgoBqtQCpK7x5kpxe5AyAgoI9)gAmqb7By859AjiSVG7jb97(9n0yGc23Wa2mfC0WOM8VMUHuBoEI7ISl4EsqbD)(gsT54jUlYUHqSBOIa3qJbkyFdrztzoE6gIY8p6gQWiVxdSbnbucfWMynuU4N7PKRB5g9q4KRSCLmfGg80Om)JY94Cd6tUYZ1TCJEiCYvwUoVyuOa2OEdAstsyWa0irnqOag7FUhNlsLR8BikB0Tjr3qfWMynKUATc6T5cUNe0x3VVHgduW(gQa2eRHUHuBoEI7ISl4Esqi197Bi1MJN4Ui7gAmqb7B48ATXafS1(sbUH(sb0Tjr3WO59aCZ7cUGBy08EaU5D)(EYV733qQnhpXDr2nKnfGMYUHUN78Akch0KWX8wZinmQnVxdWvnALGovVcdJ4UHgduW(gQa2OEdA6cUNe097Bi1MJN4Ui7gAmqb7BO61XAOBiBkanLDd5GaHee2XAiXqsw1QCXp3HKSQv3qgEmpPb2GMaQ7j)UG7jFD)(gAmqb7BOee2XAOBi1MJN4Ui7cUGBOcC)(EYV733qQnhpXDr2n0yGc23qjiSJ1q3q2uaAk7gouCifoZXt5IixGnOjGausKga1CfLl(5(lOCrKRSCDEXOGz6QzIHKSQv5IFUijxe5klxNxmkgdf1WNshhQpkEIHKSQv5IFUijxE(CDpxNxmkgdf1WNshhQpkEIhwUYZLNpx3Z15fJcMPRMjEy5YZNRPaJ51yWa0KRR5(1NCLNlICLLR7568IrX)Q5gIttsyWa0irnqtnnORJsIhwU885AkWyEngman56AUF9jx55IixdtZWrS)3qgEmpPb2GMaQ7j)UG7jbD)(gsT54jUlYUHgduW(gQEDSg6gYMcqtz3WHIdPWzoEkxe5cSbnbeGsI0aOMROCXp3FbLlICLLRZlgfmtxntmKKvTkx8Zfj5Iixz568IrXyOOg(u64q9rXtmKKvTkx8Zfj5YZNR7568IrXyOOg(u64q9rXt8WYvEU8856EUoVyuWmD1mXdlxE(CnfymVgdgGMCDn3V(KR8CrKRSCDpxNxmk(xn3qCAscdgGgjQbAQPbDDus8WYLNpxtbgZRXGbOjxxZ9Rp5kpxe5AyAgoI9)gYWJ5jnWg0eqDp53fCp5R733qQnhpXDr2n0yGc23qfG8EB0rVn0nKnfGMYUHdfhsHZC8uUiYfydAciaLePbqnxr5IFU)oYCrKRSCDEXOGz6QzIHKSQv5IFUijxe5klxNxmkgdf1WNshhQpkEIHKSQv5IFUijxE(CDpxNxmkgdf1WNshhQpkEIhwUYZLNpx3Z15fJcMPRMjEy5YZNRPaJ51yWa0KRR5(1NCLNlICLLR7568IrX)Q5gIttsyWa0irnqtnnORJsIhwU885AkWyEngman56AUF9jx55IixdtZWrS)3qgEmpPb2GMaQ7j)UG7ji197Bi1MJN4Ui7gYMcqtz3qdtZWrS)3qJbkyFdJWHrAyu3g4n0fCpbj3VVHuBoEI7ISBiBkanLDdDEXOGz6QzIh2n0yGc23WXqrn8P0XH6JI3fCp5iVFFdP2C8e3fz3q2uaAk7gklxz568IrbX8fMI0kO3gXqsw1QCXp3FFYLNpxNxmkiMVWuK2)ABedjzvRYf)C)9jx55Iixge65GbAbZ0vZedjzvRYf)C)6tUiYvwUoVyuGnLeC4kZRTHzDX0ypVYgbkZ)OCDn3GqQp5YZNR75oVMIWbnjWMscoCL512WSUyASNxzJGovVcdJ4YvEUYZLNpxNxmkWMscoCL512WSUyASNxzJaL5FuU4Fi3GqUp5YZNldc9CWaTGz6QzIHmo8YfrUYY1uGX8AmyaAYf)CDHp5YZNlkBkZXtIsPniLR8BOXafSVH)RMBioTcRMcOUG7ji397Bi1MJN4Ui7gYMcqtz3qz5AkWyEngman5IFUUWNCrKRSCDEXO4F1CdXPjjmyaAKOgOPMg01rjXdlxE(CDpxgef1wde)XBkRZvEU885YGOO2AGOl04a6Or5YZNlkBkZXtIsPniLlpFUoVyu44Hqo)tbepSCrKRZlgfoEiKZ)uaXqsw1QCDn3G(KRB5klxz56c5E6CNxtr4GMeytjbhUY8ABywxmn2ZRSrqNQxHHrC5kpx3YvwUivUNoxgS5EfqGneRuK28f6wIAGGAZXtC5kpx55kpxe56EUoVyuWmD1mXdlxe5kl3yHghqpKKvTkxxZLbHEoyGwWGnk4FsdWrAfwnfqjgsYQwLRB5IC5YZNBSqJdOhsYQwLRR5guq56wUYY1fY905klxNxmkWMscoCL512WSUyASNxzJaL5FuU4N7VpFYvEUYZLNp3yHghqpKKvTkxxM7Vt5tUUMBqbLlpFUmi0Zbd0cgSrb)tAaosRWQPakXdlxE(CDpxgef1wdeDHghqhnkx53qJbkyFdzKNuGY8AZxOBjQbxW9Kt5(9nKAZXtCxKDdztbOPSBOSCnfymVgdgGMCXpxx4tUiYvwUoVyu8VAUH40Kegmansud0utd66OK4HLlpFUUNldIIARbI)4nL15kpxE(CzquuBnq0fACaD0OC55ZfLnL54jrP0gKYLNpxNxmkC8qiN)PaIhwUiY15fJchpeY5FkGyijRAvUUM7xFY1TCLLRSCDHCpDUZRPiCqtcSPKGdxzETnmRlMg75v2iOt1RWWiUCLNRB5klxKk3tNld2CVciWgIvksB(cDlrnqqT54jUCLNR8CLNlICDpxNxmkyMUAM4HLlICLLBSqJdOhsYQwLRR5YGqphmqlyWgf8pPb4iTcRMcOedjzvRY1TCrUC55ZnwOXb0djzvRY11C)kOCDlxz56c5E6CLLRZlgfytjbhUY8ABywxmn2ZRSrGY8pkx8Z93Np5kpx55YZNBSqJdOhsYQwLRlZ93P8jxxZ9RGYLNpxge65GbAbd2OG)jnahPvy1uaL4HLlpFUUNldIIARbIUqJdOJgLR8BOXafSVHvZSPnqb7l4EIlC)(gsT54jUlYUHqSBOIa3qJbkyFdrztzoE6gIY8p6gYGOO2AGOl04a6Or5Iixz568Irb2usWHRmV2gM1ftJ98kBeOm)JY11CdcP(KlICLLldc9CWaTGz6QzIHKSQv56wU)(Kl(5gl04a6HKSQv5YZNldc9CWaTGz6QzIHKSQv56wUF9jxxZnwOXb0djzvRYfrUXcnoGEijRAvU4N7VV(KlpFUoVyuWmD1mXqsw1QCXpxKlx55IixNxmkiMVWuKwb92igsYQwLl(5(7tU885gl04a6HKSQv56YC)f0NCDn3Fijx53qu2OBtIUHmyJc(N0myZvGc2xW9KFFUFFdP2C8e3fz3qi2nurGBOXafSVHOSPmhpDdrz(hDdLLR75YGqphmqlyMUAMyiJdVC55Z19CrztzoEsWGnk4FsZGnxbkyNlICzquuBnq0fACaD0OCLFdrzJUnj6gQmuKochnZ0vZUG7j)(D)(gsT54jUlYUHSPa0u2neLnL54jbd2OG)jnd2CfOGDUiY1uGX8AmyaAY11C)6Zn0yGc23qgSrb)tAaosRWQPaQl4EYVGUFFdP2C8e3fz3q2uaAk7gsmFHPir1ARXlxe5AyAgoI9pxe568Irb2usWHRmV2gM1ftJ98kBeOm)JY11CdcP(KlICLLlheimodduOiTkGnsAotYqtcqX(xn6C55Z19CzquuBnq0eBGE4WLR8CrKlkBkZXtcLHI0r4OzMUA2n0yGc23W4BWtdJAY)A6cUN87R733qQnhpXDr2nKnfGMYUH3qJbkyFdnodduOiTkGnsxW9KFi197Bi1MJN4Ui7gYMcqtz3qNxmkGnbWP0y0WimqbBXdlxe568IrHcyt08EXqXHu4mhpDdngOG9nubSjAE)fCp5hsUFFdP2C8e3fz3q2uaAk7g68IrHcyJhoCIHKSQv56AUhzUiYvwUoVyuqmFHPiTc6Tr8WYLNpxNxmkiMVWuK2)ABepSCLNlICnfymVgdgGMCXpxx4Zn0yGc23qM1mYRDEX4n05fJ62KOBOcyJhoCxW9KFh597Bi1MJN4Ui7gYMcqtz3qgef1wdeDHghqhnkxe5IYMYC8KGbBuW)KMbBUcuWoxe5YGqphmqlyWgf8pPb4iTcRMcOedjzvRY11CrZ4es255E6Czu5ZvwUMcmMxJbdqtUhN7xFYv(n0yGc23qfWg1BqtxW9KFi397Bi1MJN4Ui7gYMcqtz3qG5PgiuaY7TrZnveiO2C8exUiY19CbMNAGqbSXdhob1MJN4YfrUoVyuOa2enVxmuCifoZXt5Iixz568IrbX8fMI0(xBJyijRAvU4N7rMlICjMVWuKOAT)12KlICDEXOaBkj4WvMxBdZ6IPXEELncuM)r56AUbHKp5YZNRZlgfytjbhUY8ABywxmn2ZRSrGY8pkx8pKBqi5tUiY1uGX8AmyaAYf)CDHp5YZNlheimodduOiTkGnsAotYqtIHKSQv5IFUNsU885AmqbBHXzyGcfPvbSrsZzsgAsuTo6l04a5kpxe56EUmi0Zbd0cMPRMjgY4W7gAmqb7BOcyt08(l4EYVt5(9nKAZXtCxKDdztbOPSBOZlgfWMa4uAMNSrJQufSfpSC55Z15fJI)vZneNMKWGbOrIAGMAAqxhLepSC55Z15fJcMPRMjEy5Iixz568IrXyOOg(u64q9rXtmKKvTkxxZfnJtizNN7PZLrLpxz5AkWyEngman5ECUF9jx55IixNxmkgdf1WNshhQpkEIhwU8856EUoVyumgkQHpLoouFu8epSCrKR75YGqphmqlgdf1WNshhQpkEIHmo8YLNpx3ZLbrrT1abkQb4WBYvEU885AkWyEngman5IFUUWNCrKlX8fMIevRTgVBOXafSVHkGnQ3GMUG7j)CH733qQnhpXDr2nKnfGMYUHaZtnqOa24HdNGAZXtC5Iixz568IrHcyJhoCIhwU885AkWyEngman5IFUUWNCLNlICDEXOqbSXdhoHcyS)56AUFLlICLLRZlgfeZxyksRGEBepSC55Z15fJcI5lmfP9V2gXdlx55IixNxmkWMscoCL512WSUyASNxzJaL5FuUUMBqi3NCrKRSCzqONdgOfmtxntmKKvTkx8Z93NC55Z19CrztzoEsWGnk4FsZGnxbkyNlICzquuBnq0fACaD0OCLFdngOG9nubSr9g00fCpjOp3VVHuBoEI7ISBiBkanLDdLLRZlgfytjbhUY8ABywxmn2ZRSrGY8pkxxZniK7tU88568Irb2usWHRmV2gM1ftJ98kBeOm)JY11CdcjFYfrUaZtnqOaK3BJMBQiqqT54jUCLNlICDEXOGy(ctrAf0BJyijRAvU4NlYLlICjMVWuKOATc6Tjxe56EUoVyuaBcGtPXOHryGc2IhwUiY19CbMNAGqbSXdhob1MJN4YfrUmi0Zbd0cMPRMjgsYQwLl(5IC5Iixz5YGqphmql(xn3qCAfwnfqjgsYQwLl(5IC5YZNR75YGOO2AG4pEtzDUYVHgduW(gQa2OEdA6cUNe0V733qQnhpXDr2nKnfGMYUHYY15fJcI5lmfP9V2gXdlxE(CLLldNnOjvUhYnOCrK7qmC2GM0GsIY11CrsUYZLNpxgoBqtQCpK7x5kpxe5AyAgoI9pxe5IYMYC8KqzOiDeoAMPRMDdngOG9nSPaAjiSVG7jbf097Bi1MJN4Ui7gYMcqtz3qz568IrbX8fMI0(xBJ4HLlICDpxgef1wde)XBkRZLNpxz568IrX)Q5gIttsyWa0irnqtnnORJsIhwUiYLbrrT1aXF8MY6CLNlpFUYYLHZg0Kk3d5guUiYDigoBqtAqjr56AUijx55YZNldNnOjvUhY9RC55Z15fJcMPRMjEy5kpxe5AyAgoI9pxe5IYMYC8KqzOiDeoAMPRMDdngOG9neN5JAjiSVG7jb9197Bi1MJN4Ui7gYMcqtz3qz568IrbX8fMI0(xBJ4HLlICDpxgef1wde)XBkRZLNpxz568IrX)Q5gIttsyWa0irnqtnnORJsIhwUiYLbrrT1aXF8MY6CLNlpFUYYLHZg0Kk3d5guUiYDigoBqtAqjr56AUijx55YZNldNnOjvUhY9RC55Z15fJcMPRMjEy5kpxe5AyAgoI9pxe5IYMYC8KqzOiDeoAMPRMDdngOG9nm(8ETee2xW9KGqQ733qJbkyFddyZuWrdJAY)A6gsT54jUlYUG7jbHK733qQnhpXDr2nKnfGMYUHeZxyksuT2)ABYLNpxI5lmfjuqVn6MohKlpFUeZxyksynE6MohKlpFUoVyueWMPGJgg1K)1K4HLlICDEXOGy(ctrA)RTr8WYLNpxz568IrbZ0vZedjzvRY11CngOGTiWyaCc6CI9aKgusuUiY15fJcMPRMjEy5k)gAmqb7BOcytSg6cUNe0rE)(gAmqb7ByGXa4UHuBoEI7ISl4Esqi397Bi1MJN4Ui7gAmqb7B48ATXafS1(sbUH(sb0Tjr3WO59aCZ7cUGBOd0a3VVN87(9nKAZXtCxKDdztbOPSBOZlgfmtxnt8WUHgduW(gogkQHpLoouFu8UG7jbD)(gsT54jUlYUHqSBOIa3qJbkyFdrztzoE6gIY8p6g6EUoVyu4yERzKgg1M3Rb4QgTs3g4nK4HLlICDpxNxmkCmV1msdJAZ71aCvJwPTHznjEy3qu2OBtIUHSPane8WUG7jFD)(gsT54jUlYUHSPa0u2n05fJcfWgpC4edjzvRY11C)HKCrKRSCDEXOWX8wZinmQnVxdWvnALUnWBiXqsw1QCXpxKsGKC55Z15fJchZBnJ0WO28Enax1OvABywtIHKSQv5IFUiLaj5kpxe5AkWyEngman5I)HCpYp5Iixz5YGqphmqlyMUAMyijRAvU4NlYLlpFUYYLbHEoyGwqsyWa0ODGnNyijRAvU4NlYLlICDpxNxmk(xn3qCAscdgGgjQbAQPbDDus8WYfrUmikQTgi(J3uwNR8CLFdngOG9nKznJ8ANxmEdDEXOUnj6gQa24Hd3fCpbPUFFdP2C8e3fz3q2uaAk7g6EUOSPmhpjytbAi4HLlICLLRSCDpxge65GbAbd2OG)jnahPvy1uaL4HLlpFUUNlkBkZXtcgSrb)tAgS5kqb7C55Z19CzquuBnq0fACaD0OCLNlICLLldIIARbIUqJdOJgLlpFUYYLbHEoyGwWmD1mXqsw1QCXpxKlxE(CLLldc9CWaTGKWGbOr7aBoXqsw1QCXpxKlxe56EUoVyu8VAUH40Kegmansud0utd66OK4HLlICzquuBnq8hVPSox55kpx55kpxE(CLLldc9CWaTGbBuW)KgGJ0kSAkGs8WYfrUmi0Zbd0cMPRMjgY4Wlxe5YGOO2AGOl04a6Or5k)gAmqb7BOcyJ6nOPl4EcsUFFdP2C8e3fz3qJbkyFdvVowdDdztbOPSB4qXHu4mhpLlICb2GMacqjrAauZvuU4N7VJmxe5AyAgoI9pxe5klxu2uMJNeSPane8WYLNpxz5AkWyEngman56AUF9jxe56EUoVyuWmD1mXdlx55YZNldc9CWaTGz6QzIHmo8Yv(nKHhZtAGnOjG6EYVl4EYrE)(gsT54jUlYUHgduW(gkbHDSg6gYMcqtz3WHIdPWzoEkxe5cSbnbeGsI0aOMROCXp3FFjqsUiY1W0mCe7FUiYvwUOSPmhpjytbAi4HLlpFUYY1uGX8AmyaAY11C)6tUiY19CDEXOGz6QzIhwUYZLNpxge65GbAbZ0vZedzC4LR8CrKR7568IrX)Q5gIttsyWa0irnqtnnORJsIh2nKHhZtAGnOjG6EYVl4EcYD)(gsT54jUlYUHgduW(gQaK3BJo6THUHSPa0u2nCO4qkCMJNYfrUaBqtabOKinaQ5kkx8Z93rMRB5oKKvTkxe5AyAgoI9pxe5klxu2uMJNeSPane8WYLNpxtbgZRXGbOjxxZ9Rp5YZNldc9CWaTGz6QzIHmo8Yv(nKHhZtAGnOjG6EYVl4EYPC)(gsT54jUlYUHSPa0u2n0W0mCe7)n0yGc23WiCyKgg1TbEdDb3tCH733qQnhpXDr2nKnfGMYUHYYLy(ctrIQ1wJxU885smFHPiHc6TrxT(xU885smFHPiH)12ORw)lx55Iixz56EUmikQTgi6cnoGoAuU885klxtbgZRXGbOjxxZ1fqsUiYvwUOSPmhpjytbAi4HLlpFUMcmMxJbdqtUUM7xFYLNpxu2uMJNeLsBqkx55Iixz5IYMYC8KGbBuW)KMJu41SCrKR75YGqphmqlyWgf8pPb4iTcRMcOepSC55Z19CrztzoEsWGnk4FsZrk8AwUiY19CzqONdgOfmtxnt8WYvEUYZvEUiYvwUmi0Zbd0cMPRMjgsYQwLl(5(1NC55Z1uGX8AmyaAYf)CDHp5Iixge65GbAbZ0vZepSCrKRSCzqONdgOfKegmanAhyZjgsYQwLRR5AmqbBHcytSgsqNtShG0GsIYLNpx3ZLbrrT1aXF8MY6CLNlpFUXcnoGEijRAvUUM7Vp5kpxe5klxoiqyCggOqrAvaBK0CMKHMedjzvRYf)CrQC55Z19CzquuBnq0eBGE4WLR8BOXafSVHX3GNgg1K)10fCp53N733qQnhpXDr2nKnfGMYUHYYLy(ctrc)RTr305GC55ZLy(ctrcf0BJUPZb5YZNlX8fMIewJNUPZb5YZNRZlgfoM3AgPHrT59AaUQrR0TbEdjgsYQwLl(5IucKKlpFUoVyu4yERzKgg1M3Rb4QgTsBdZAsmKKvTkx8ZfPeijxE(CnfymVgdgGMCXpxx4tUiYLbHEoyGwWmD1mXqghE5kpxe5klxge65GbAbZ0vZedjzvRYf)C)6tU885YGqphmqlyMUAMyiJdVCLNlpFUXcnoGEijRAvUUM7Vp3qJbkyFd)xn3qCAfwnfqDb3t(97(9nKAZXtCxKDdztbOPSBOSCnfymVgdgGMCXpxx4tUiYvwUoVyu8VAUH40Kegmansud0utd66OK4HLlpFUUNldIIARbI)4nL15kpxE(CzquuBnq0fACaD0OC55Z15fJchpeY5FkG4HLlICDEXOWXdHC(NcigsYQwLRR5g0NCDlxz5Iu5E6CzWM7vab2qSsrAZxOBjQbcQnhpXLR8CLNlICLLR75YGOO2AGOl04a6Or5YZNldc9CWaTGbBuW)KgGJ0kSAkGs8WYLNp3yHghqpKKvTkxxZLbHEoyGwWGnk4FsdWrAfwnfqjgsYQwLRB5EK5YZNBSqJdOhsYQwLRlZ93P8jxxZnOp56wUYYfPY905YGn3RacSHyLI0MVq3sudeuBoEIlx55k)gAmqb7BiJ8KcuMxB(cDlrn4cUN8lO733qQnhpXDr2nKnfGMYUHYY1uGX8AmyaAYf)CDHp5Iixz568IrX)Q5gIttsyWa0irnqtnnORJsIhwU8856EUmikQTgi(J3uwNR8C55ZLbrrT1arxOXb0rJYLNpxNxmkC8qiN)PaIhwUiY15fJchpeY5FkGyijRAvUUM7xFY1TCLLlsL7PZLbBUxbeydXkfPnFHULOgiO2C8exUYZvEUiYvwUUNldIIARbIUqJdOJgLlpFUmi0Zbd0cgSrb)tAaosRWQPakXdlxE(CrztzoEsWGnk4FsZrk8AwUiYnwOXb0djzvRYf)C)DkFY1TCd6tUULRSCrQCpDUmyZ9kGaBiwPiT5l0Te1ab1MJN4YvEU885gl04a6HKSQv56AUmi0Zbd0cgSrb)tAaosRWQPakXqsw1QCDl3JmxE(CJfACa9qsw1QCDn3V(KRB5klxKk3tNld2CVciWgIvksB(cDlrnqqT54jUCLNR8BOXafSVHvZSPnqb7l4EYVVUFFdP2C8e3fz3q2uaAk7gklxu2uMJNemyJc(N0CKcVMLlICJfACa9qsw1QCXp3FF9jxE(CDEXOGz6QzIhwUYZfrUYY15fJchZBnJ0WO28Enax1Ov62aVHekGX(Rrz(hLl(5(1NC55Z15fJchZBnJ0WO28Enax1OvABywtcfWy)1Om)JYf)C)6tUYZLNp3yHghqpKKvTkxxZ93NBOXafSVHmyJc(N0aCKwHvtbuxW9KFi197Bi1MJN4Ui7gYMcqtz3WBOXafSVHgNHbkuKwfWgPl4EYpKC)(gsT54jUlYUHSPa0u2nKbrrT1arxOXb0rJYfrUYYfLnL54jbd2OG)jnhPWRz5YZNldc9CWaTGz6QzIHKSQv56AU)(KR8CrKRPaJ51yWa0Kl(5IKp5Iixge65GbAbd2OG)jnahPvy1uaLyijRAvUUM7Vp3qJbkyFdvaBuVbnDb3t(DK3VVHuBoEI7ISBie7gQiWn0yGc23qu2uMJNUHOm)JUHeZxyksuT2)ABY905Ek5ECUgduWwOa2eRHe05e7binOKOCDlx3ZLy(ctrIQ1(xBtUNo3Jm3JZ1yGc2IaJbWjOZj2dqAqjr56wUFebL7X5QWiVxJZua6gIYgDBs0n0uyhbPjKyxW9KFi397Bi1MJN4Ui7gYMcqtz3qz5kl3yHghqpKKvTkxxZfPYLNpxz568IrXyOOg(u64q9rXtmKKvTkxxZfnJtizNN7PZLrLpxz5AkWyEngman5ECUF9jx55IixNxmkgdf1WNshhQpkEIhwUYZvEU885klxtbgZRXGbOjx3YfLnL54jHPWocstiXY90568IrbX8fMI0kO3gXqsw1QCDlxoiqeFdEAyut(xtcqX(R0djzvN7PZnibsYf)C)f0NC55Z1uGX8AmyaAY1TCrztzoEsykSJG0esSCpDUoVyuqmFHPiT)12igsYQwLRB5YbbI4BWtdJAY)Asak2FLEijR6CpDUbjqsU4N7VG(KR8CrKlX8fMIevRTgVCrKRSCLLR75YGqphmqlyMUAM4HLlpFUmikQTgi(J3uwNlICDpxge65GbAbjHbdqJ2b2CIhwUYZLNpxgef1wdeDHghqhnkx55YZNRZlgfmtxntmKKvTkx8Z9uYfrUUNRZlgfJHIA4tPJd1hfpXdlx53qJbkyFdvaBuVbnDb3t(Dk3VVHuBoEI7ISBiBkanLDdLLRZlgfeZxyks7FTnIhwU885klxgoBqtQCpKBq5Ii3Hy4SbnPbLeLRR5IKCLNlpFUmC2GMu5Ei3VYvEUiY1W0mCe7)n0yGc23WMcOLGW(cUN8ZfUFFdP2C8e3fz3q2uaAk7gklxNxmkiMVWuK2)ABepSC55ZvwUmC2GMu5Ei3GYfrUdXWzdAsdkjkxxZfj5kpxE(Cz4SbnPY9qUFLR8CrKRHPz4i2)BOXafSVH4mFulbH9fCpjOp3VVHuBoEI7ISBiBkanLDdLLRZlgfeZxyks7FTnIhwU885klxgoBqtQCpKBq5Ii3Hy4SbnPbLeLRR5IKCLNlpFUmC2GMu5Ei3VYvEUiY1W0mCe7)n0yGc23W4Z71sqyFb3tc6397BOXafSVHbSzk4OHrn5FnDdP2C8e3fzxW9KGc6(9nKAZXtCxKDdztbOPSBiX8fMIevR9V2MC55ZLy(ctrcf0BJUPZb5YZNlX8fMIewJNUPZb5YZNRZlgfbSzk4OHrn5FnjEy5IixI5lmfjQw7FTn5YZNRSCDEXOGz6QzIHKSQv56AUgduWweymaobDoXEasdkjkxe568IrbZ0vZepSCLFdngOG9nubSjwdDb3tc6R733qJbkyFddmga3nKAZXtCxKDb3tccPUFFdP2C8e3fz3qJbkyFdNxRngOGT2xkWn0xkGUnj6ggnVhGBExWfCb3qu0OkyFpjOpb953NFbDddytxnA1n8i2P(r8tocCYruKwU5(nok3scdoGCJWj3tnUHmjNQ5O5ul3HovVAiUCvqjkx7bGsgG4YLHZA0KsKb7Ivt5geslxKh2OObqC5gwsiFUk8AGDEUUmxamxx8z5YvOkvb7CHy0ya4KRSJLNRSFNlxKb7Ivt5ICiTCrEyJIgaXLByjH85QWRb2556sxMlaMRl(SCLGCp)tLleJgdaNCL5s55k735YfzWUy1uUNcslxKh2OObqC5gwsiFUk8AGDEUU0L5cG56Iplxji3Z)u5cXOXaWjxzUuEUY(DUCrgSlwnL7VpiTCrEyJIgaXLByjH85QWRb2556YCbWCDXNLlxHQufSZfIrJbGtUYowEUYc6C5ImyxSAk3F)qA5I8WgfnaIl3Wsc5ZvHxdSZZ1LUmxamxx8z5kb5E(Nkxigngao5kZLYZv2VZLlYGDXQPC)DKiTCrEyJIgaXLByjH85QWRb2556YCbWCDXNLlxHQufSZfIrJbGtUYowEUY(DUCrgCg8rSt9J4NCe4KJOiTCZ9BCuULegCa5gHtUNAydXGsog4ul3HovVAiUCvqjkx7bGsgG4YLHZA0KsKb7Ivt5IeKwUipSrrdG4YnSKq(Cv41a78CDzUayUU4ZYLRqvQc25cXOXaWjxzhlpxzbDUCrgCg8rSt9J4NCe4KJOiTCZ9BCuULegCa5gHtUNAgKo1YDOt1RgIlxfuIY1EaOKbiUCz4SgnPezWUy1uU)qA5I8WgfnaIl3Wsc5ZvHxdSZZ1LUmxamxx8z5kb5E(Nkxigngao5kZLYZv2VZLlYGDXQPC)cPLlYdBu0aiUCdljKpxfEnWopxxMlaMRl(SC5kuLQGDUqmAmaCYv2XYZv2VZLlYGDXQPCpsKwUipSrrdG4YnSKq(Cv41a78CDPlZfaZ1fFwUsqUN)PYfIrJbGtUYCP8CL97C5ImyxSAkxKdPLlYdBu0aiUCdljKpxfEnWopxx6YCbWCDXNLReK75FQCHy0ya4KRmxkpxz)oxUid2fRMY1fqA5I8WgfnaIl3Wsc5ZvHxdSZZ1LUmxamxx8z5kb5E(Nkxigngao5kZLYZv2VZLlYGDXQPC)HuiTCrEyJIgaXLByjH85QWRb2556YCbWCDXNLlxHQufSZfIrJbGtUYowEUY(DUCrgSlwnL7pKG0Yf5HnkAaexUHLeYNRcVgyNNRlZfaZ1fFwUCfQsvWoxigngao5k7y55k735YfzWUy1uU)osKwUipSrrdG4YnSKq(Cv41a78CDzUayUU4ZYLRqvQc25cXOXaWjxzhlpxz)oxUid2fRMY9hYH0Yf5HnkAaexUHLeYNRcVgyNNRlZfaZ1fFwUCfQsvWoxigngao5k7y55k735YfzWUy1uUbfeslxKh2OObqC5gwsiFUk8AGDEUUmxamxx8z5YvOkvb7CHy0ya4KRSJLNRSGoxUidod(i2P(r8tocCYruKwU5(nok3scdoGCJWj3tnf4ul3HovVAiUCvqjkx7bGsgG4YLHZA0KsKb7Ivt5ICiTCrEyJIgaXLByjH85QWRb2556sxMlaMRl(SCLGCp)tLleJgdaNCL5s55k735YfzWUy1uUNcslxKh2OObqC5gwsiFUk8AGDEUU0L5cG56Iplxji3Z)u5cXOXaWjxzUuEUY(DUCrgSlwnLRlG0Yf5HnkAaexUHLeYNRcVgyNNRlDzUayUU4ZYvcY98pvUqmAmaCYvMlLNRSFNlxKb7Ivt5(7irA5I8WgfnaIl3Wsc5ZvHxdSZZ1L5cG56IplxUcvPkyNleJgdaNCLDS8CL97C5ImyxSAk3FNcslxKh2OObqC5gwsiFUk8AGDEUUmxamxx8z5YvOkvb7CHy0ya4KRSJLNRSFNlxKbNbFe7u)i(jhbo5iksl3C)ghLBjHbhqUr4K7PMd0aNA5o0P6vdXLRckr5ApauYaexUmCwJMuImyxSAk3F)qA5I8WgfnaIl3Wsc5ZvHxdSZZ1LUmxamxx8z5kb5E(Nkxigngao5kZLYZv2VZLlYGDXQPC)DKiTCrEyJIgaXLByjH85QWRb2556YCbWCDXNLlxHQufSZfIrJbGtUYowEUY(6C5ImyxSAk3FihslxKh2OObqC5gwsiFUk8AGDEUUmxamxx8z5YvOkvb7CHy0ya4KRSJLNRSFNlxKbNbFeqcdoaIlxKlxJbkyNRVuaLid(gInWy5PB4ryUiZ8wZOCpIW8kUm4JWCpIKbGo0K7VVol3G(e0Nm4m4JWCrECwJMuiTm4JWCr65EQZXrC5gc92KlYitsKbFeMlspxKhN1OjUCb2GMa6kMlZuKkxamxgEmpPb2GMakrgCgSXafSvcSHyqjhdCqcc7)vRJWrkd2yGc2kb2qmOKJbC7WXbgdGld2yGc2kb2qmOKJbC7WXbgdGld2yGc2kb2qmOKJbC7WXkGnQ3GMoRIhuyK3Rb2GMakHcyt08ExrQmyJbkyReydXGsogWTdhJYMYC80zTjrhyWgf8pP5ifEn7muM)rhCGkfIOhchzYIfACa9qsw1kKEqFK7YFb9ro(rpeoYKfl04a6HKSQvi9Gqcsx2VpNgyEQbIQz20gOGTGAZXtCYr6YqQtZGn3RacSHyLI0MVq3sudeuBoEItUCx(7u(ipdod(im3JiEoXEaIlxcfn4LlOKOCb4OCngao5wQCnuw5nhpjYGngOGT6Gc6Tr7qMugSXafSvUD4yu2uMJNoRnj6qP0gKodL5F0bfg59AGnOjGsOa2enVh)FiK5oW8udekGnE4WjO2C8ehppW8udeka592O5MkceuBoEItopVcJ8EnWg0eqjuaBIM3JFqzWgduWw52HJrztzoE6S2KOdLsZ8KHIodL5F0bfg59AGnOjGsOa2eRHW)xgSXafSvUD4yhAu08VA0NvXdYCNbrrT1arxOXb0rJ45DNbHEoyGwWGnk4FsdWrAfwnfqjEyYr48IrbZ0vZepSmyJbkyRC7WXyqqb7ZQ4bNxmkyMUAM4HLbBmqbBLBho(PiDbijvgSXafSvUD4451AJbkyR9LcCwBs0bdsNPatXah(DwfpGYMYC8KOuAdszWgduWw52HJNxRngOGT2xkWzTjrh4gYKCQMJMZuGPyGd)oRIhMxtr4GMeGsIcaNwZnKj5unhnc6u9kmmIld2yGc2k3oC88ATXafS1(sboRnj6Gd0aNPatXah(DwfpmVMIWbnjCmV1msdJAZ71aCvJwjOt1RWWiUmyJbkyRC7WXZR1gduWw7lf4S2KOdkqgCgSXafSvcdshuaBIM3Fwfp48IrHcyt08EXqXHu4mhpHqM7ZRPiCqtcpEmBmLo6jcunAnAFjHPibDQEfggXXZdkjYLUePqc(oVyuOa2enVxmKKvTYTGKNbBmqbBLWGKBhow96yn0zm8yEsdSbnbuh(DwfpyyAgoI9hbX8fMIevRTgpedfhsHZC8ecGnOjGausKga1CfH)pKcPRWiVxdSbnbuUnKKvTkd2yGc2kHbj3oCSee2XAOZy4X8KgydAcOo87SkEyO4qkCMJNqaSbnbeGsI0aOMRi8L9dPCtMcJ8EnWg0eqjuaBI1qN(NajYL7sfg59AGnOjGYTHKSQviKXGqphmqlyMUAMyiJdpEEfg59AGnOjGsOa2eRHC9lEEzeZxyksuTwb92WZtmFHPir1AhiahppX8fMIevR9V2geUdmp1aHc(8AyudWr6iCifqqT54jo5iKPWiVxdSbnbucfWMynKR)(CAz)CdyEQbcqGQ1sqyReuBoEItUCeMcmMxJbdqd(i5ds35fJcfWMO59IHKSQvN(iLJWDNxmk(xn3qCAscdgGgjQbAQPbDDus8WqyyAgoI9pd2yGc2kHbj3oCCeomsdJ62aVHoRIhmmndhX(NbBmqbBLWGKBhoEmuudFkDCO(O4Dwfp48IrbZ0vZepSmyJbkyRegKC7WXmYtkqzET5l0Te1GZQ4bzoVyuOa2enVx8W45nfymVgdgGg8rYh5iC35fJcf0RafJepmeU78IrbZ0vZepmeYQgqdg0BaIthl04a6HKSQvUYGqphmqlyWgf8pPb4iTcRMcOedjzvRCd545Rgqdg0BaIthl04a6HKSQvU0L)oLpUguq88mi0Zbd0cgSrb)tAaosRWQPakXdJN3Dgef1wdeDHghqhnsEgSXafSvcdsUD44Qz20gOG9zv8GmNxmkuaBIM3lEy88McmMxJbdqd(i5JCeU78IrHc6vGIrIhgc3DEXOGz6QzIhgczvdObd6naXPJfACa9qsw1kxzqONdgOfmyJc(N0aCKwHvtbuIHKSQvUHC88vdObd6naXPJfACa9qsw1kx6YFNYhx)kiEEge65GbAbd2OG)jnahPvy1uaL4HXZ7odIIARbIUqJdOJgj3yGc2kHbj3oC8)Q5gItRWQPaQZQ4HyHghqpKKvTY1FiHNxMZlgfytjbhUY8ABywxmn2ZRSrGY8pY1GqYhEENxmkWMscoCL512WSUyASNxzJaL5Fe(hccjFKJW5fJcfWMO59Ihgcge65GbAbZ0vZedjzvRWhjFYGngOGTsyqYTdhRaK3BJo6THoJHhZtAGnOjG6WVZQ4HHIdPWzoEcbOKinaQ5kc)FibHcJ8EnWg0eqjuaBI1qUIuimmndhX(JqMZlgfmtxntmKKvTc)FF45D35fJcMPRMjEyYZGngOGTsyqYTdhJYMYC80zTjrhyWgf8pPzWMRafSpdL5F0bNxmkWMscoCL512WSUyASNxzJaL5FKRbHKpiDtbgZRXGbObHmge65GbAbZ0vZedjzvRC73h8JfACa9qsw1kEEge65GbAbZ0vZedjzvRC7RpUgl04a6HKSQviIfACa9qsw1k8)91hEENxmkyMUAMyijRAf(iNCeeZxyksuT2A845JfACa9qsw1kx6YFb9X1Fijd2yGc2kHbj3oCmd2OG)jnahPvy1ua1zv8akBkZXtcgSrb)tAgS5kqbBeMcmMxJbdqJRi5tgSXafSvcdsUD444BWtdJAY)A6SkEGy(ctrIQ1wJhcdtZWrS)iCEXOaBkj4WvMxBdZ6IPXEELncuM)rUges(GqgheimodduOiTkGnsAotYqtcqX(xnAEE3zquuBnq0eBGE4WXZRWiVxdSbnbu4hK8myJbkyRegKC7WXgNHbkuKwfWgPZy4X8KgydAcOo87SkEWDqX(xnAekmY71aBqtaLqbSjAEVRUqgSXafSvcdsUD4yfWMO59NvXdoVyuaBcGtPXOHryGc2IhgczoVyuOa2enVxmuCifoZXt88McmMxJbdqd(UWh5zWgduWwjmi52HJvaBIM3FwfpWGOO2AGOl04a6OriqztzoEsWGnk4FsZGnxbkyJGbHEoyGwWGnk4FsdWrAfwnfqjgsYQw5kAgNqYo)0mQ8YmfymVgdgGgxIKpYr48IrHcyt08EXqXHu4mhpLbBmqbBLWGKBhowbSr9g00zv8adIIARbIUqJdOJgHaLnL54jbd2OG)jnd2CfOGncge65GbAbd2OG)jnahPvy1uaLyijRALROzCcj78tZOYlZuGX8AmyaAC5xFKJW5fJcfWMO59IhwgSXafSvcdsUD4yu2uMJNoRnj6Gcyt08EDayd0rZ71Wy8muM)rhmfymVgdgGg8pLpiDzoVyuOa2enVxmKKvT60F5sfg59ACMcqYr6Y4Gar8n4PHrn5FnjgsYQwDAKihHZlgfkGnrZ7fpSmyJbkyRegKC7WXkGnQ3GMoRIhCEXOa2eaNsZ8KnAuLQGT4HXZ7UcytSgsyyAgoI9NNxMZlgfmtxntmKKvTYvKGW5fJcMPRMjEy88YCEXOymuudFkDCO(O4jgsYQw5kAgNqYo)0mQ8YmfymVgdgGgx(1h5iCEXOymuudFkDCO(O4jEyYLJaLnL54jHcyt08EDayd0rZ71WyeHcJ8EnWg0eqjuaBIM376xzWgduWwjmi52HJBkGwcc7ZQ4bzeZxyksuT2A8qWGqphmqlyMUAMyijRAf(i5dpVmgoBqtQdbHyigoBqtAqjrUIe588mC2GMuh(socdtZWrS)zWgduWwjmi52HJXz(Owcc7ZQ4bzeZxyksuT2A8qWGqphmqlyMUAMyijRAf(i5dpVmgoBqtQdbHyigoBqtAqjrUIe588mC2GMuh(socdtZWrS)zWgduWwjmi52HJJpVxlbH9zv8GmI5lmfjQwBnEiyqONdgOfmtxntmKKvTcFK8HNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFjhHHPz4i2)myJbkyRegKC7WXbSzk4OHrn5FnLbBmqbBLWGKBhogLnL54PZAtIoOa2eRH0vRvqVnNHY8p6GcJ8EnWg0eqjuaBI1q4FkUf9q4itYuaAWtJY8pYLb9rUBrpeoYCEXOqbSr9g0KMKWGbOrIAGqbm2FxIuYZGDlxJbkyRegKC7WXbgdG7SkEGy(ctrc)RTr305aEEI5lmfjSgpDtNdqGYMYC8KOuAMNmueppX8fMIevRvqVniChLnL54jHcytSgsxTwb92WZ78IrbZ0vZedjzvRC1yGc2cfWMynKGoNypaPbLeHWDu2uMJNeLsZ8KHIq48IrbZ0vZedjzvRCLoNypaPbLeHW5fJcMPRMjEy88oVyumgkQHpLoouFu8epmekmY714mfGW)J4i55DhLnL54jrP0mpzOieoVyuWmD1mXqsw1k8PZj2dqAqjrzWgduWwjmi52HJvaBI1qzWgduWwjmi52HJNxRngOGT2xkWzTjrhIM3dWnVm4myJbkyReoqdCymuudFkDCO(O4Dwfp48IrbZ0vZepSmyJbkyReoqd42HJrztzoE6S2KOdSPane8WodL5F0b3DEXOWX8wZinmQnVxdWvnALUnWBiXddH7oVyu4yERzKgg1M3Rb4QgTsBdZAs8WYGngOGTs4anGBhoMznJ8ANxmEwBs0bfWgpC4oRIhCEXOqbSXdhoXqsw1kx)HeeYCEXOWX8wZinmQnVxdWvnALUnWBiXqsw1k8rkbs45DEXOWX8wZinmQnVxdWvnAL2gM1KyijRAf(iLajYrykWyEngman4F4i)Gqgdc9CWaTGz6QzIHKSQv4JC88YyqONdgOfKegmanAhyZjgsYQwHpYHWDNxmk(xn3qCAscdgGgjQbAQPbDDus8WqWGOO2AG4pEtzTC5zWgduWwjCGgWTdhRa2OEdA6SkEWDu2uMJNeSPane8WqitM7mi0Zbd0cgSrb)tAaosRWQPakXdJN3Du2uMJNemyJc(N0myZvGc288UZGOO2AGOl04a6OrYriJbrrT1arxOXb0rJ45LXGqphmqlyMUAMyijRAf(ihpVmge65GbAbjHbdqJ2b2CIHKSQv4JCiC35fJI)vZneNMKWGbOrIAGMAAqxhLepmemikQTgi(J3uwlxUC588YyqONdgOfmyJc(N0aCKwHvtbuIhgcge65GbAbZ0vZedzC4HGbrrT1arxOXb0rJKNbBmqbBLWbAa3oCS61XAOZy4X8KgydAcOo87SkEyO4qkCMJNqaSbnbeGsI0aOMRi8)DKimmndhX(JqgkBkZXtc2uGgcEy88YmfymVgdgGgx)6dc3DEXOGz6QzIhMCEEge65GbAbZ0vZedzC4jpd2yGc2kHd0aUD4yjiSJ1qNXWJ5jnWg0eqD43zv8WqXHu4mhpHaydAciaLePbqnxr4)7lbsqyyAgoI9hHmu2uMJNeSPane8W45LzkWyEngmanU(1heU78IrbZ0vZepm588mi0Zbd0cMPRMjgY4Wtoc3DEXO4F1CdXPjjmyaAKOgOPMg01rjXdld2yGc2kHd0aUD4yfG8EB0rVn0zm8yEsdSbnbuh(DwfpmuCifoZXtia2GMacqjrAauZve()os3gsYQwHWW0mCe7pczOSPmhpjytbAi4HXZBkWyEngmanU(1hEEge65GbAbZ0vZedzC4jpd2yGc2kHd0aUD44iCyKgg1TbEdDwfpyyAgoI9pd2yGc2kHd0aUD444BWtdJAY)A6SkEqgX8fMIevRTgpEEI5lmfjuqVn6Q1)45jMVWuKW)AB0vR)jhHm3zquuBnq0fACaD0iEEzMcmMxJbdqJRUasqidLnL54jbBkqdbpmEEtbgZRXGbOX1V(WZJYMYC8KOuAdsYridLnL54jbd2OG)jnhPWRziCNbHEoyGwWGnk4FsdWrAfwnfqjEy88UJYMYC8KGbBuW)KMJu41meUZGqphmqlyMUAM4HjxUCeYyqONdgOfmtxntmKKvTc)V(WZBkWyEngman47cFqWGqphmqlyMUAM4HHqgdc9CWaTGKWGbOr7aBoXqsw1kxngOGTqbSjwdjOZj2dqAqjr88UZGOO2AG4pEtzTCE(yHghqpKKvTY1FFKJqgheimodduOiTkGnsAotYqtIHKSQv4Ju88UZGOO2AGOj2a9WHtEgSXafSvchObC7WX)RMBioTcRMcOoRIhKrmFHPiH)12OB6CappX8fMIekO3gDtNd45jMVWuKWA80nDoGN35fJchZBnJ0WO28Enax1Ov62aVHedjzvRWhPeiHN35fJchZBnJ0WO28Enax1OvABywtIHKSQv4JucKWZBkWyEngman47cFqWGqphmqlyMUAMyiJdp5iKXGqphmqlyMUAMyijRAf(F9HNNbHEoyGwWmD1mXqghEY55JfACa9qsw1kx)9jd2yGc2kHd0aUD4yg5jfOmV28f6wIAWzv8GmtbgZRXGbObFx4dczoVyu8VAUH40Kegmansud0utd66OK4HXZ7odIIARbI)4nL1Y55zquuBnq0fACaD0iEENxmkC8qiN)PaIhgcNxmkC8qiN)PaIHKSQvUg0h3KHuNMbBUxbeydXkfPnFHULOgiO2C8eNC5iK5odIIARbIUqJdOJgXZZGqphmqlyWgf8pPb4iTcRMcOepmE(yHghqpKKvTYvge65GbAbd2OG)jnahPvy1uaLyijRALBhjpFSqJdOhsYQw5sx(7u(4AqFCtgsDAgS5EfqGneRuK28f6wIAGGAZXtCYLNbBmqbBLWbAa3oCC1mBAduW(SkEqMPaJ51yWa0GVl8bHmNxmk(xn3qCAscdgGgjQbAQPbDDus8W45DNbrrT1aXF8MYA588mikQTgi6cnoGoAepVZlgfoEiKZ)uaXddHZlgfoEiKZ)uaXqsw1kx)6JBYqQtZGn3RacSHyLI0MVq3sudeuBoEItUCeYCNbrrT1arxOXb0rJ45zqONdgOfmyJc(N0aCKwHvtbuIhgppkBkZXtcgSrb)tAosHxZqel04a6HKSQv4)7u(4wqFCtgsDAgS5EfqGneRuK28f6wIAGGAZXtCY55JfACa9qsw1kxzqONdgOfmyJc(N0aCKwHvtbuIHKSQvUDK88XcnoGEijRALRF9Xnzi1PzWM7vab2qSsrAZxOBjQbcQnhpXjxEgSXafSvchObC7WXmyJc(N0aCKwHvtbuNvXdYqztzoEsWGnk4FsZrk8AgIyHghqpKKvTc)FF9HN35fJcMPRMjEyYriZ5fJchZBnJ0WO28Enax1Ov62aVHekGX(Rrz(hH)xF45DEXOWX8wZinmQnVxdWvnAL2gM1Kqbm2FnkZ)i8)6JCE(yHghqpKKvTY1FFYGngOGTs4anGBho24mmqHI0Qa2iDwfpKbBmqbBLWbAa3oCScyJ6nOPZQ4bgef1wdeDHghqhncHmu2uMJNemyJc(N0CKcVMXZZGqphmqlyMUAMyijRALR)(ihHPaJ51yWa0Gps(GGbHEoyGwWGnk4FsdWrAfwnfqjgsYQw56VpzWgduWwjCGgWTdhJYMYC80zTjrhmf2rqAcj2zOm)JoqmFHPir1A)RT50NIlngOGTqbSjwdjOZj2dqAqjrU5oX8fMIevR9V2MtFKU0yGc2IaJbWjOZj2dqAqjrU9reKlvyK3RXzkaLbBmqbBLWbAa3oCScyJ6nOPZQ4bzYIfACa9qsw1kxrkEEzoVyumgkQHpLoouFu8edjzvRCfnJtizNFAgvEzMcmMxJbdqJl)6JCeoVyumgkQHpLoouFu8epm5Y55LzkWyEngmanUHYMYC8KWuyhbPjKyN25fJcI5lmfPvqVnIHKSQvUXbbI4BWtdJAY)Asak2FLEijR6thKaj4)lOp88McmMxJbdqJBOSPmhpjmf2rqAcj2PDEXOGy(ctrA)RTrmKKvTYnoiqeFdEAyut(xtcqX(R0djzvF6Geib)Fb9rocI5lmfjQwBnEiKjZDge65GbAbZ0vZepmEEgef1wde)XBkRr4odc9CWaTGKWGbOr7aBoXdtoppdIIARbIUqJdOJgjNN35fJcMPRMjgsYQwH)PGWDNxmkgdf1WNshhQpkEIhM8myJbkyReoqd42HJBkGwcc7ZQ4bzoVyuqmFHPiT)12iEy88Yy4SbnPoeeIHy4SbnPbLe5ksKZZZWzdAsD4l5immndhX(NbBmqbBLWbAa3oCmoZh1sqyFwfpiZ5fJcI5lmfP9V2gXdJNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFjhHHPz4i2)myJbkyReoqd42HJJpVxlbH9zv8GmNxmkiMVWuK2)ABepmEEzmC2GMuhccXqmC2GM0GsICfjY55z4SbnPo8LCegMMHJy)ZGngOGTs4anGBhooGntbhnmQj)RPmyJbkyReoqd42HJvaBI1qNvXdeZxyksuT2)AB45jMVWuKqb92OB6CappX8fMIewJNUPZb88oVyueWMPGJgg1K)1K4HHGy(ctrIQ1(xBdpVmNxmkyMUAMyijRALRgduWweymaobDoXEasdkjcHZlgfmtxnt8WKNbBmqbBLWbAa3oCCGXa4YGngOGTs4anGBhoEET2yGc2AFPaN1MeDiAEpa38YGZGngOGTsWnKj5unhnhqztzoE6S2KOdklsAau)uKwHrE)zOm)JoiZ5fJcqjrbGtR5gYKCQMJgXqsw1k8rZ4es25iCNy(ctrIQ1(xBdc3jMVWuKqb92OB6Cac3jMVWuKWA80nDoGN35fJcqjrbGtR5gYKCQMJgXqsw1k8ngOGTqbSjwdjOZj2dqAqjriKPWiVxdSbnbucfWMyne()45jMVWuKOAT)12WZtmFHPiHc6Tr305aEEI5lmfjSgpDtNdKlNN3DNxmkaLefaoTMBitYPAoAepSmyJbkyReCdzsovZrJBhowbSr9g00zv8Gm3rztzoEsOSiPbq9trAfg5988YK58IrbX8fMI0kO3gXqsw1kxrZ4es25iCEXOGy(ctrAf0BJ4HjNNxMZlgfJHIA4tPJd1hfpXqsw1kxrZ4es25NMrLxMPaJ51yWa04YV(ihHZlgfJHIA4tPJd1hfpXdtUC5iK58IrbX8fMI0kO3gXdJNNy(ctrcf0BJUPZb88eZxyksynE6MohiNN3uGX8AmyaAW3f(KbBmqbBLGBitYPAoAC7WXsqyhRHoJHhZtAGnOjG6WVZQ4HHIdPWzoEcbWg0eqakjsdGAUIW)3rIWDNxmk(xn3qCAscdgGgjQbAQPbDDus8WYGngOGTsWnKj5unhnUD4y1RJ1qNXWJ5jnWg0eqD43zv8WqXHu4mhpHaydAciaLePbqnxr4)7ir4UZlgf)RMBionjHbdqJe1an10GUokjEyzWgduWwj4gYKCQMJg3oCScqEVn6O3g6mgEmpPb2GMaQd)oRIhgkoKcN54jeaBqtabOKinaQ5kc)FhjczoVyuWmD1mXqsw1k8)9HN3DNxmkyMUAM4HjhHHPz4i2FeU78IrX)Q5gIttsyWa0irnqtnnORJsIhwgSXafSvcUHmjNQ5OXTdhpgkQHpLoouFu8oRIhmfymVgdgGgxrUpiK58IrbOKOaWP1CdzsovZrJyijRAf(OzCcj78thepV7oVyuakjkaCAn3qMKt1C0iEyYZGngOGTsWnKj5unhnUD4yg5jfOmV28f6wIAWzv8GHPz4i2FeU78IrbZ0vZepmeYCEXOausua40AUHmjNQ5OrmKKvTcF0moHKDopV7oVyuakjkaCAn3qMKt1C0iEyYryyAgoI9hH7oVyuWmD1mXddHSyHghqpKKvTYvge65GbAbd2OG)jnahPvy1uaLyijRALBihpFSqJdOhsYQw5sx(7u(4AqbXZZGqphmqlyWgf8pPb4iTcRMcOepmEE3zquuBnq0fACaD0i5zWgduWwj4gYKCQMJg3oCC1mBAduW(SkEWW0mCe7pc3DEXOGz6QzIhgczoVyuakjkaCAn3qMKt1C0igsYQwHpAgNqYoNN3DNxmkaLefaoTMBitYPAoAepm5iKfl04a6HKSQvUYGqphmqlyWgf8pPb4iTcRMcOedjzvRCd545JfACa9qsw1kx6YFNYhx)kiEEge65GbAbd2OG)jnahPvy1uaL4HXZ7odIIARbIUqJdOJgjpd2yGc2kb3qMKt1C042HJJWHrAyu3g4n0zv8GHPz4i2)myJbkyReCdzsovZrJBho(F1CdXPvy1ua1zv8GZlgfGsIcaNwZnKj5unhnIHKSQv4JMXjKSZril6HWrMSyHghqpKKvTcP)7JCxYGqphmqlh)OhchzYIfACa9qsw1kK(VpiDge65GbAbZ0vZedjzvRK7sge65GbA5iKrmFHPir1Af0BdppX8fMIekO3gDtNd45DEXOGz6QzIHKSQv4)7dpVZlgfytjbhUY8ABywxmn2ZRSrGY8pc)dbHCFqykWyEngman4JKpYLNbBmqbBLGBitYPAoAC7WXOSPmhpDwBs0bgSrb)tAgS5kqb7Zqz(hDW5fJcSPKGdxzETnmRlMg75v2iqz(h5Aqi1heYyqONdgOfmtxntmKKvTYTFFWpwOXb0djzvR45zqONdgOfmtxntmKKvTYTV(4ASqJdOhsYQwHiwOXb0djzvRW)3xF45JfACa9qsw1kx6YFb9X1FiHN35fJcMPRMjgsYQwHpYjhbX8fMIevRTgVmyJbkyReCdzsovZrJBhoMbBuW)KgGJ0kSAkG6SkEaLnL54jbd2OG)jnd2CfOGnczMcmMxJbdqJRi5dcu2uMJNeLsBqIN3uGX8AmyaAC9RpYriZ5fJcqjrbGtR5gYKCQMJgXqsw1k8PZj2dqAqjr88U78IrbOKOaWP1CdzsovZrJ4Hjpd2yGc2kb3qMKt1C042HJJVbpnmQj)RPZQ4bI5lmfjQwBnEimmndhX(JaLnL54jHYIKga1pfPvyK3JqgheimodduOiTkGnsAotYqtcqX(xnAEE3zquuBnq0eBGE4WXZRWiVxdSbnbu4hK8myJbkyReCdzsovZrJBho24mmqHI0Qa2iDwfpKbBmqbBLGBitYPAoAC7WXkGnQ3GMoRIhCNbrrT1arxOXb0rJqWGqphmqlyMUAMyiJdpeMcmMxJbdqd(i3NmyJbkyReCdzsovZrJBhowbSr9g00zv8adIIARbIUqJdOJgHaLnL54jbd2OG)jnd2CfOGnctbgZRXGbOb)dF9bbdc9CWaTGbBuW)KgGJ0kSAkGsmKKvTYv0moHKD(Pzu5LzkWyEngmanU8RpYZGngOGTsWnKj5unhnUD44McOLGW(SkEqMZlgfeZxyks7FTnIhgpVmgoBqtQdbHyigoBqtAqjrUIe588mC2GMuh(socdtZWrS)zWgduWwj4gYKCQMJg3oCmoZh1sqyFwfpiZ5fJcI5lmfP9V2gXdJNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFjhHHPz4i2FeYCEXOausua40AUHmjNQ5OrmKKvTcF6CI9aKgusepV7oVyuakjkaCAn3qMKt1C0iEyYZGngOGTsWnKj5unhnUD444Z71sqyFwfpiZ5fJcI5lmfP9V2gXdJNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFjhHHPz4i2FeYCEXOausua40AUHmjNQ5OrmKKvTcF6CI9aKgusepV7oVyuakjkaCAn3qMKt1C0iEyYZGngOGTsWnKj5unhnUD44a2mfC0WOM8VMYGngOGTsWnKj5unhnUD4yfWMyn0zv8aX8fMIevR9V2gEEI5lmfjuqVn6MohWZtmFHPiH14PB6CapVZlgfbSzk4OHrn5FnjEyiCEXOGy(ctrA)RTr8W45L58IrbZ0vZedjzvRC1yGc2IaJbWjOZj2dqAqjriCEXOGz6QzIhM8myJbkyReCdzsovZrJBhooWyaCzWgduWwj4gYKCQMJg3oC88ATXafS1(sboRnj6q08EaU5LbNbBmqbBLiAEpa38oOa2OEdA6SkEW951ueoOjHJ5TMrAyuBEVgGRA0kbDQEfggXLbBmqbBLiAEpa38C7WXQxhRHoJHhZtAGnOjG6WVZQ4boiqibHDSgsmKKvTc)HKSQvzWgduWwjIM3dWnp3oCSee2XAOm4myJbkyRekWbjiSJ1qNXWJ5jnWg0eqD43zv8WqXHu4mhpHaydAciaLePbqnxr4)lieYCEXOGz6QzIHKSQv4JeeYCEXOymuudFkDCO(O4jgsYQwHps45D35fJIXqrn8P0XH6JIN4HjNN3DNxmkyMUAM4HXZBkWyEngmanU(1h5iK5UZlgf)RMBionjHbdqJe1an10GUokjEy88McmMxJbdqJRF9rocdtZWrS)zWgduWwjua3oCS61XAOZy4X8KgydAcOo87SkEyO4qkCMJNqaSbnbeGsI0aOMRi8)feczoVyuWmD1mXqsw1k8rcczoVyumgkQHpLoouFu8edjzvRWhj88U78IrXyOOg(u64q9rXt8WKZZ7UZlgfmtxnt8W45nfymVgdgGgx)6JCeYC35fJI)vZneNMKWGbOrIAGMAAqxhLepmEEtbgZRXGbOX1V(ihHHPz4i2)myJbkyRekGBhowbiV3gD0BdDgdpMN0aBqta1HFNvXddfhsHZC8ecGnOjGausKga1CfH)VJeHmNxmkyMUAMyijRAf(ibHmNxmkgdf1WNshhQpkEIHKSQv4JeEE3DEXOymuudFkDCO(O4jEyY55D35fJcMPRMjEy88McmMxJbdqJRF9roczU78IrX)Q5gIttsyWa0irnqtnnORJsIhgpVPaJ51yWa046xFKJWW0mCe7FgSXafSvcfWTdhhHdJ0WOUnWBOZQ4bdtZWrS)zWgduWwjua3oC8yOOg(u64q9rX7SkEW5fJcMPRMjEyzWgduWwjua3oC8)Q5gItRWQPaQZQ4bzYCEXOGy(ctrAf0BJyijRAf()(WZ78IrbX8fMI0(xBJyijRAf()(ihbdc9CWaTGz6QzIHKSQv4)1heYCEXOaBkj4WvMxBdZ6IPXEELncuM)rUges9HN3951ueoOjb2usWHRmV2gM1ftJ98kBe0P6vyyeNC588oVyuGnLeC4kZRTHzDX0ypVYgbkZ)i8peeY9HNNbHEoyGwWmD1mXqghEiKzkWyEngman47cF45rztzoEsukTbj5zWgduWwjua3oCmJ8KcuMxB(cDlrn4SkEqMPaJ51yWa0GVl8bHmNxmk(xn3qCAscdgGgjQbAQPbDDus8W45DNbrrT1aXF8MYA588mikQTgi6cnoGoAeppkBkZXtIsPniXZ78IrHJhc58pfq8Wq48IrHJhc58pfqmKKvTY1G(4MmzUWPNxtr4GMeytjbhUY8ABywxmn2ZRSrqNQxHHrCYDtgsDAgS5EfqGneRuK28f6wIAGGAZXtCYLlhH7oVyuWmD1mXddHSyHghqpKKvTYvge65GbAbd2OG)jnahPvy1uaLyijRALBihpFSqJdOhsYQw5Aqb5Mmx40YCEXOaBkj4WvMxBdZ6IPXEELncuM)r4)7Zh5Y55JfACa9qsw1kx6YFNYhxdkiEEge65GbAbd2OG)jnahPvy1uaL4HXZ7odIIARbIUqJdOJgjpd2yGc2kHc42HJRMztBGc2NvXdYmfymVgdgGg8DHpiK58IrX)Q5gIttsyWa0irnqtnnORJsIhgpV7mikQTgi(J3uwlNNNbrrT1arxOXb0rJ45rztzoEsukTbjEENxmkC8qiN)PaIhgcNxmkC8qiN)PaIHKSQvU(1h3KjZfo98Akch0KaBkj4WvMxBdZ6IPXEELnc6u9kmmItUBYqQtZGn3RacSHyLI0MVq3sudeuBoEItUC5iC35fJcMPRMjEyiKfl04a6HKSQvUYGqphmqlyWgf8pPb4iTcRMcOedjzvRCd545JfACa9qsw1kx)ki3K5cNwMZlgfytjbhUY8ABywxmn2ZRSrGY8pc)FF(ixopFSqJdOhsYQw5sx(7u(46xbXZZGqphmqlyWgf8pPb4iTcRMcOepmEE3zquuBnq0fACaD0i5zWgduWwjua3oCmkBkZXtN1MeDGbBuW)KMbBUcuW(muM)rhyquuBnq0fACaD0ieYCEXOaBkj4WvMxBdZ6IPXEELncuM)rUges9bHmge65GbAbZ0vZedjzvRC73h8JfACa9qsw1kEEge65GbAbZ0vZedjzvRC7RpUgl04a6HKSQviIfACa9qsw1k8)91hEENxmkyMUAMyijRAf(iNCeoVyuqmFHPiTc6TrmKKvTc)FF45JfACa9qsw1kx6YFb9X1FirEgSXafSvcfWTdhJYMYC80zTjrhugkshHJMz6QzNHY8p6Gm3zqONdgOfmtxntmKXHhpV7OSPmhpjyWgf8pPzWMRafSrWGOO2AGOl04a6OrYZGngOGTsOaUD4ygSrb)tAaosRWQPaQZQ4bu2uMJNemyJc(N0myZvGc2imfymVgdgGgx)6tgSXafSvcfWTdhhFdEAyut(xtNvXdeZxyksuT2A8qyyAgoI9hHZlgfytjbhUY8ABywxmn2ZRSrGY8pY1GqQpiKXbbcJZWafksRcyJKMZKm0KauS)vJMN3Dgef1wdenXgOhoCYrGYMYC8KqzOiDeoAMPRMLbBmqbBLqbC7WXgNHbkuKwfWgPZQ4HmyJbkyRekGBhowbSjAE)zv8GZlgfWMa4uAmAyegOGT4HHW5fJcfWMO59IHIdPWzoEkd2yGc2kHc42HJzwZiV25fJN1MeDqbSXdhUZQ4bNxmkuaB8WHtmKKvTY1JeHmNxmkiMVWuKwb92iEy88oVyuqmFHPiT)12iEyYrykWyEngman47cFYGngOGTsOaUD4yfWg1BqtNvXdmikQTgi6cnoGoAecu2uMJNemyJc(N0myZvGc2iyqONdgOfmyJc(N0aCKwHvtbuIHKSQvUIMXjKSZpnJkVmtbgZRXGbOXLF9rEgSXafSvcfWTdhRa2enV)SkEayEQbcfG8EB0CtfbcQnhpXHWDG5PgiuaB8WHtqT54joeoVyuOa2enVxmuCifoZXtiK58IrbX8fMI0(xBJyijRAf(hjcI5lmfjQw7FTniCEXOaBkj4WvMxBdZ6IPXEELncuM)rUges(WZ78Irb2usWHRmV2gM1ftJ98kBeOm)JW)qqi5dctbgZRXGbObFx4dppheimodduOiTkGnsAotYqtIHKSQv4Fk88gduWwyCggOqrAvaBK0CMKHMevRJ(cnoGCeUZGqphmqlyMUAMyiJdVmyJbkyRekGBhowbSr9g00zv8GZlgfWMa4uAMNSrJQufSfpmEENxmk(xn3qCAscdgGgjQbAQPbDDus8W45DEXOGz6QzIhgczoVyumgkQHpLoouFu8edjzvRCfnJtizNFAgvEzMcmMxJbdqJl)6JCeoVyumgkQHpLoouFu8epmEE3DEXOymuudFkDCO(O4jEyiCNbHEoyGwmgkQHpLoouFu8edzC4XZ7odIIARbcuudWH3iNN3uGX8AmyaAW3f(GGy(ctrIQ1wJxgSXafSvcfWTdhRa2OEdA6SkEayEQbcfWgpC4euBoEIdHmNxmkuaB8WHt8W45nfymVgdgGg8DHpYr48IrHcyJhoCcfWy)D9leYCEXOGy(ctrAf0BJ4HXZ78IrbX8fMI0(xBJ4HjhHZlgfytjbhUY8ABywxmn2ZRSrGY8pY1GqUpiKXGqphmqlyMUAMyijRAf()(WZ7okBkZXtcgSrb)tAgS5kqbBemikQTgi6cnoGoAK8myJbkyRekGBhowbSr9g00zv8GmNxmkWMscoCL512WSUyASNxzJaL5FKRbHCF45DEXOaBkj4WvMxBdZ6IPXEELncuM)rUges(GayEQbcfG8EB0CtfbcQnhpXjhHZlgfeZxyksRGEBedjzvRWh5qqmFHPir1Af0Bdc3DEXOa2eaNsJrdJWafSfpmeUdmp1aHcyJhoCcQnhpXHGbHEoyGwWmD1mXqsw1k8roeYyqONdgOf)RMBioTcRMcOedjzvRWh545DNbrrT1aXF8MYA5zWgduWwjua3oCCtb0sqyFwfpiZ5fJcI5lmfP9V2gXdJNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFjhHHPz4i2FeOSPmhpjugkshHJMz6QzzWgduWwjua3oCmoZh1sqyFwfpiZ5fJcI5lmfP9V2gXddH7mikQTgi(J3uwZZlZ5fJI)vZneNMKWGbOrIAGMAAqxhLepmemikQTgi(J3uwlNNxgdNnOj1HGqmedNnOjnOKixrICEEgoBqtQdFXZ78IrbZ0vZepm5immndhX(JaLnL54jHYqr6iC0mtxnld2yGc2kHc42HJJpVxlbH9zv8GmNxmkiMVWuK2)ABepmeUZGOO2AG4pEtznpVmNxmk(xn3qCAscdgGgjQbAQPbDDus8WqWGOO2AG4pEtzTCEEzmC2GMuhccXqmC2GM0GsICfjY55z4SbnPo8fpVZlgfmtxnt8WKJWW0mCe7pcu2uMJNekdfPJWrZmD1SmyJbkyRekGBhooGntbhnmQj)RPmyJbkyRekGBhowbSjwdDwfpqmFHPir1A)RTHNNy(ctrcf0BJUPZb88eZxyksynE6MohWZ78IrraBMcoAyut(xtIhgcNxmkiMVWuK2)ABepmEEzoVyuWmD1mXqsw1kxngOGTiWyaCc6CI9aKgusecNxmkyMUAM4Hjpd2yGc2kHc42HJdmgaxgSXafSvcfWTdhpVwBmqbBTVuGZAtIoenVhGBE3qfgXUN87tqxWfCVa]] )


end