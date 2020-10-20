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


    spec:RegisterPack( "Balance", 20201016.1, [[dGKvGdqiQqpsfc6sQqAtG4tqHugfvYPOIwfvaVsaMLkIBrfK2fHFPQIHPQQJbfTmbYZuHAAqH6AQQ02eq13OcQXbfIZrfO1rfeZdj19ub7dj6GQqalej4HcOmrviK4IQqiPpQcHQtcfs1kfOMPkeTtvK(Pkesnuvielvfc0tf0uHc(Qkek7vL(lrdwPdtAXuQhJyYi1LrTzH(minAO0PL8AvuZMQUnLSBf)gYWb1XHcjlxQNtX0bUUQSDvLVtLA8iHopsY6fqMpuTFrFX8IHBiTc47Pb9pO)y(hZaxGjgJXyE8neqfmFdHvYzfkFdh1IVHuq96q4BiSsLhP0xmCdnOxt4Biwaa24q(5hOfa7Zwqqw)ykRNxbfAiTgb)yklYp3q7x5by0NR9nKwb890G(h0Fm)JzGlWeJXymd63BO(ayr9nmSScSBi2IMMNR9nKMnKB4ryUuq96q4CpIs)k6m4JWCpIMaq2CNlMb(j5g0)G(NbNbFeMBGHvhOSXHKbFeMRdn3Ja00mDUHiV25sbwTezWhH56qZnWWQduMoxG2qzGSI5sudBYfGYLqfXZsG2qzGrKbFeMRdn3JGSf6JPZ9ndtyJrBQY9t7sT9SjxxLGfNKlCZFsdqBZRHY56qPmx4M)egG2MxdLDkUH(YamxmCdHBMGSSvWfd3tX8IHBOsafAUHwi0CUgze1w3qEuBptFPWfCpnOlgUHkbuO5g6Uva2BipQTNPVu4cUNE8fd3qLak0CdD3ka7nKh12Z0xkCb3tX4lgUH8O2EM(sHBiPla3LEdnWS3lbAdLbgHbODu9(CPoxm(gQeqHMBObOT51q5l4E6VxmCd5rT9m9Lc3qe8n0WGBOsafAUHFAxQTNVHFQ)X3qBKXKlKCJEeQZ1vUUYnwqXcKnBP1yY1HMBq)Z1zU)KlMb9pxN5szUrpc156kxx5glOybYMT0Am56qZnOFZ1HMRRCX8FUoqUa1Zdqudr7rbfAe8O2EMoxN56qZ1vUyCUoqUe0q)kGaUzszyP6lOJfpabpQTNPZ1zUoZ9NCXeJ8pxN3WpTLJAX3qcA(qNzjnBOAixWfCdTrk4IH7PyEXWnKh12Z0xkCdjDb4U0BO9lgfevwdr8GVHkbuO5g26hpONrgBEcevxW90GUy4gYJA7z6lfUHi4BOHb3qLak0Cd)0UuBpFd)u)JVHoMR9lgf2QxhclrrP69sa2AGAKJcEnlEW5cjxhZ1(fJcB1RdHLOOu9EjaBnqnsTj6WIh8n8tB5Ow8nK0fyqGh8fCp94lgUH8O2EM(sHBiPla3LEdDLR9lgf2QxhclrrP69sa2AGAKJcEnlA2sRXKlL5IXIFZfhpx7xmkSvVoewIIs17LaS1a1i1MOdlA2sRXKlL5IXIFZ1zUqYvnGw9syKBUZLYd56G)ZfsUUYLGqEAK7rquznerZwAnMCPmxhoxC8CDLlbH80i3JGTGrU5wAJgArZwAnMCPmxhoxi56yU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNlKCjOpE0biotvx6KRZCDEdvcOqZnKOdH9s7xmEdTFXOCul(gAaA7rn9fCpfJVy4gYJA7z6lfUHKUaCx6n0XC)0UuBpliDbge4bNlKCDLRRCDmxcc5PrUhbbnFOZSeGLLg4QlGr8GZfhpxhZ9t7sT9SGGMp0zwsqdDbk0KloEUoMlb9XJoaXuqXcKrLZ1zUqY1vUe0hp6aetbflqgvoxC8CDLlbH80i3JGOYAiIMT0Am5szUoCU4456kxcc5PrUhbBbJCZT0gn0IMT0Am5szUoCUqY1XCTFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdoxi5sqF8OdqCMQU0jxN56mxN56mxC8CDLlbH80i3JGGMp0zwcWYsdC1fWiEW5cjxcc5PrUhbrL1qenR0uLlKCjOpE0biMckwGmQCUoVHkbuO5gAaABEnu(cUN(7fd3qEuBptFPWnujGcn3qLwHb1hlnU126gs6cWDP3qhZLgbekTcdQpwACRTLKwTuOSauKZ1anxi56yUkbuOrO0kmO(yPXT2wsA1sHYIAKrFbflixi56kxhZLgbekTcdQpwACRTLelREbOiNRbAU445sJacLwHb1hlnU12sILvVOzlTgtUuM7V56mxC8CPraHsRWG6JLg3ABjPvlfklmaLCoxQZ94CHKlnciuAfguFS04wBljTAPqzrZwAnMCPo3JZfsU0iGqPvyq9XsJBTTK0QLcLfGICUgO3qcveplbAdLbM7PyEb3td8lgUH8O2EM(sHBOsafAUHM3eRMVHKUaCx6nS5yZgSQTNZfsUaTHYabOSyjajPloxkZfZapxi5QWscwMCoxi56k3pTl12ZcsxGbbEW5IJNRRCvdOvVeg5M7CPo3J)NlKCDmx7xmkiQSgI4bNRZCXXZLGqEAK7rquznerZknv568gsOI4zjqBOmWCpfZl4EQdFXWnKh12Z0xkCdvcOqZn0cHMy18nK0fG7sVHnhB2GvT9CUqYfOnugiaLflbijDX5szUyES43CHKRcljyzY5CHKRRC)0UuBpliDbge4bNloEUUYvnGw9syKBUZL6Cp(FUqY1XCTFXOGOYAiIhCUoZfhpxcc5PrUhbrL1qenR0uLRZCHKRJ5A)IrX5AOBMwYwWi3CBXdqYd3qRaXIh8nKqfXZsG2qzG5EkMxW9umYfd3qEuBptFPWnujGcn3qdG9ETLrV28nK0fG7sVHnhB2GvT9CUqYfOnugiaLflbijDX5szUyg45gqUnBP1yYfsUkSKGLjNZfsUUY9t7sT9SG0fyqGhCU445QgqREjmYn35sDUh)pxC8CjiKNg5Eeevwdr0SstvUoVHeQiEwc0gkdm3tX8cUN6GxmCd5rT9m9Lc3qsxaUl9gQWscwMC(gQeqHMBye1ewIIYrbVMVG7Py()IHBipQTNPVu4gs6cWDP3qx5YeFbByrnsDOkxC8CzIVGnSWG8AlRrIzU445YeFbByH)nAlRrIzUoZfsUUY1XCjOpE0biMckwGmQCU4456kx1aA1lHrU5oxQZ1b)nxi56k3pTl12ZcsxGbbEW5IJNRAaT6LWi3CNl15E8)CXXZ9t7sT9SOmsfX56mxi56k3pTl12ZccA(qNzjnBOAi5cjxhZLGqEAK7rqqZh6mlbyzPbU6cyep4CXXZ1XC)0UuBpliO5dDML0SHQHKlKCDmxcc5PrUhbrL1qep4CDMRZCDMlKCDLlbH80i3JGOYAiIMT0Am5szUh)pxC8CvdOvVeg5M7CPmxh8FUqYLGqEAK7rquzneXdoxi56kxcc5PrUhbBbJCZT0gn0IMT0Am5sDUkbuOryaAhRMfmfzYdWsqzX5IJNRJ5sqF8OdqCMQU0jxN5IJNBSGIfiB2sRXKl15I5)CDMlKCDLlnciuAfguFS04wBljTAPqzrZwAnMCPmxmoxC8CDmxc6JhDaIHjnYJA6CDEdvcOqZnm(AQKOOK9VHVG7PyI5fd3qEuBptFPWnK0fG7sVHUYLj(c2Wc)B0womfb5IJNlt8fSHfgKxB5WueKloEUmXxWgwOdvYHPiixC8CTFXOWw96qyjkkvVxcWwduJCuWRzrZwAnMCPmxmw8BU445A)IrHT61HWsuuQEVeGTgOgP2eDyrZwAnMCPmxmw8BU445QgqREjmYn35szUo4)CHKlbH80i3JGOYAiIMvAQY1zUqY1vUeeYtJCpcIkRHiA2sRXKlL5E8)CXXZLGqEAK7rquznerZknv56mxC8CJfuSazZwAnMCPoxm)FdvcOqZn8Cn0ntlnWvxaZfCpfZGUy4gYJA7z6lfUHKUaCx6n0vUQb0QxcJCZDUuMRd(pxi56kx7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GZfhpxhZLG(4rhG4mvDPtUoZfhpxc6JhDaIPGIfiJkNloEU2Vyuy7riA)Zaep4CHKR9lgf2EeI2)marZwAnMCPo3G(NBa56kxmoxhixcAOFfqa3mPmSu9f0XIhGGh12Z056mxN5cjxx56yUe0hp6aetbflqgvoxC8CjiKNg5Eee08HoZsawwAGRUagXdoxC8CJfuSazZwAnMCPoxcc5PrUhbbnFOZSeGLLg4QlGr0SLwJj3aYnWZfhp3ybflq2SLwJj3JMlMyK)5sDUb9p3aY1vUyCUoqUe0q)kGaUzszyP6lOJfpabpQTNPZ1zUoVHkbuO5gsypBaL6LQVGow8aUG7PyE8fd3qEuBptFPWnK0fG7sVHUYvnGw9syKBUZLYCDW)5cjxx5A)IrX5AOBMwYwWi3CBXdqYd3qRaXIhCU4456yUe0hp6aeNPQlDY1zU445sqF8OdqmfuSazu5CXXZ1(fJcBpcr7FgG4bNlKCTFXOW2Jq0(NbiA2sRXKl15E8)Cdixx5IX56a5sqd9Rac4MjLHLQVGow8ae8O2EMoxN56mxi56kxhZLG(4rhGykOybYOY5IJNlbH80i3JGGMp0zwcWYsdC1fWiEW5IJN7N2LA7zbbnFOZSKMnunKCHKBSGIfiB2sRXKlL5Ijg5FUbKBq)ZnGCDLlgNRdKlbn0VciGBMugwQ(c6yXdqWJA7z6CDMloEUXckwGSzlTgtUuNlbH80i3JGGMp0zwcWYsdC1fWiA2sRXKBa5g45IJNBSGIfiB2sRXKl15E8)Cdixx5IX56a5sqd9Rac4MjLHLQVGow8ae8O2EMoxN568gQeqHMByneThfuO5cUNIjgFXWnKh12Z0xkCdjDb4U0BORC)0UuBpliO5dDML0SHQHKlKCJfuSazZwAnMCPmxmp(FU445A)IrbrL1qep4CDMlKCDLR9lgf2QxhclrrP69sa2AGAKJcEnlmaLCw(P(hNlL5E8)CXXZ1(fJcB1RdHLOOu9EjaBnqnsTj6WcdqjNLFQ)X5szUh)pxN5IJNBSGIfiB2sRXKl15I5)BOsafAUHe08HoZsawwAGRUaMl4EkM)EXWnKh12Z0xkCdjDb4U0Bib9XJoaXuqXcKrLZfsUUY9t7sT9SGGMp0zwsZgQgsU445sqipnY9iiQSgIOzlTgtUuNlM)Z1zUqYvnGw9syKBUZLYC)9FUqYLGqEAK7rqqZh6mlbyzPbU6cyenBP1yYL6CX8)nujGcn3qdqBZRHYxW9umd8lgUH8O2EM(sHBic(gAyWnujGcn3WpTl12Z3Wp1)4Bit8fSHf1i9Vr7CDGCXi5(tUkbuOryaAhRMfmfzYdWsqzX5gqUoMlt8fSHf1i9Vr7CDGCd8C)jxLak0iC3kaRGPitEawcklo3aY9ViOC)jxdm79sSQbW3WpTLJAX3q1aFeH7qMCb3tX0HVy4gYJA7z6lfUHKUaCx6n0vU1a4gg5vatlJfuSazZwAnMCPoxmoxC8CDLR9lgfT(Xd6zKXMNarLOzlTgtUuNlucTWsPyUoqUeU856kx1aA1lHrU5o3FY94)56mxi5A)IrrRF8GEgzS5jqujEW56mxN5IJNRRCvdOvVeg5M7Cdi3pTl12Zc1aFeH7qMKRdKR9lgfmXxWgwAqETfnBP1yYnGCPrar81ujrrj7Fdlaf5Sr2SLwtUoqUbj(nxkZfZG(NloEUQb0QxcJCZDUbK7N2LA7zHAGpIWDitY1bY1(fJcM4lydl9VrBrZwAnMCdixAeqeFnvsuuY(3WcqroBKnBP1KRdKBqIFZLYCXmO)56mxi5YeFbByrnsDOkxi56kxx56yUeeYtJCpcIkRHiEW5IJNlb9XJoaXzQ6sNCHKRJ5sqipnY9iylyKBUL2OHw8GZ1zU445sqF8OdqmfuSazu5CDMlKCDLRJ5sqF8Odq8XdalvDU4456yU2VyuquzneXdoxC8CvdOvVeg5M7CPmxh8FUoZfhpx7xmkiQSgIOzlTgtUuMlgjxi56yU2Vyu06hpONrgBEcevIh8nujGcn3qdqBZRHYxW9umXixmCd5rT9m9Lc3qsxaUl9g6kx7xmkyIVGnS0)gTfp4CXXZ1vUeSAdLn5Ei3GYfsUntWQnuwckloxQZ93CDMloEUeSAdLn5Ei3JZ1zUqYvHLeSm58nujGcn3WHDlTqO5cUNIPdEXWnKh12Z0xkCdjDb4U0BORCTFXOGj(c2Ws)B0w8GZfhpxx5sWQnu2K7HCdkxi52mbR2qzjOS4CPo3FZ1zU445sWQnu2K7HCpoxN5cjxfwsWYKZ3qLak0CdXQ(O0cHMl4EAq)Vy4gYJA7z6lfUHKUaCx6n0vU2VyuWeFbByP)nAlEW5IJNRRCjy1gkBY9qUbLlKCBMGvBOSeuwCUuN7V56mxC8Cjy1gkBY9qUhNRZCHKRcljyzY5BOsafAUHXN3lTqO5cUNgeMxmCdvcOqZn0T2DHAjkkz)B4BipQTNPVu4cUNguqxmCd5rT9m9Lc3qsxaUl9gYeFbByrns)B0oxC8CzIVGnSWG8AlhMIGCXXZLj(c2WcDOsomfb5IJNR9lgfU1Ululrrj7FdlEW5cjxM4lydlQr6FJ25IJNRRCTFXOGOYAiIMT0Am5sDUkbuOr4UvawbtrM8aSeuwCUqY1(fJcIkRHiEW568gQeqHMBObODSA(cUNg0XxmCdvcOqZn0DRaS3qEuBptFPWfCpnim(IHBipQTNPVu4gQeqHMBy)gPsafAK(YaUH(YaKJAX3WO69aS97cUGBinh1NhCXW9umVy4gQeqHMBOb51wAZQ1nKh12Z0xkCb3td6IHBipQTNPVu4gIGVHggCdvcOqZn8t7sT98n8t9p(gAGzVxc0gkdmcdq7O695szUyMlKCDLRJ5cuppaHbOTh10cEuBptNloEUa1ZdqyaS3RTKURiqWJA7z6CDMloEUgy27LaTHYaJWa0oQEFUuMBq3WpTLJAX3WYiveFb3tp(IHBipQTNPVu4gIGVHggCdvcOqZn8t7sT98n8t9p(gAGzVxc0gkdmcdq7y1CUuMlM3WpTLJAX3WYijEw)4l4EkgFXWnKh12Z0xkCdjDb4U0BORCDmxc6JhDaIPGIfiJkNloEUoMlbH80i3JGGMp0zwcWYsdC1fWiEW56mxi5A)IrbrL1qep4BOsafAUH2CB4(CnqVG7P)EXWnKh12Z0xkCdjDb4U0BO9lgfevwdr8GVHkbuO5gcJafAUG7Pb(fd3qLak0CdFgwwa2YCd5rT9m9LcxW9uh(IHBipQTNPVu4gs6cWDP3WpTl12ZIYiveFdnGUiG7PyEdvcOqZnSFJujGcnsFza3qFzaYrT4BOI4l4Ekg5IHBipQTNPVu4gs6cWDP3W(nCe1qzbOSy3OEK0nRw21qZTGXOEfmmtFdnGUiG7PyEdvcOqZnSFJujGcnsFza3qFzaYrT4BiDZQLDn0CFb3tDWlgUH8O2EM(sHBiPla3LEd73WrudLf2QxhclrrP69sa2AGAemg1RGHz6BOb0fbCpfZBOsafAUH9BKkbuOr6ld4g6ldqoQfFdTrk4cUNI5)lgUH8O2EM(sHBiPla3LEd98h7ZLYC)9)nujGcn3W(nsLak0i9LbCd9Lbih1IVHgWfCpftmVy4gYJA7z6lfUHkbuO5g2VrQeqHgPVmGBOVma5Ow8neUzyfqWknGl4cUH0nRw21qZ9fd3tX8IHBipQTNPVu4gIGVHggCdvcOqZn8t7sT98n8t9p(g6kx7xmkaLf7g1JKUz1YUgAUfnBP1yYLYCHsOfwkfZnGC)lWmxi56kxM4lydlQrAJayZfhpxM4lydlQrAqETZfhpxM4lydl8VrB5WueKRZCXXZ1(fJcqzXUr9iPBwTSRHMBrZwAnMCPmxLak0imaTJvZcMIm5byjOS4Cdi3)cmZfsUUYLj(c2WIAK(3ODU445YeFbByHb51womfb5IJNlt8fSHf6qLCykcY1zUoZfhpxhZ1(fJcqzXUr9iPBwTSRHMBXd(g(PTCul(gA0ilbi5ZWsdm79xW90GUy4gYJA7z6lfUHKUaCx6n0vUoM7N2LA7zHrJSeGKpdlnWS3NloEUUY1(fJIw)4b9mYyZtGOs0SLwJjxQZfkHwyPumxhixcx(CDLRAaT6LWi3CN7p5E8)CDMlKCTFXOO1pEqpJm28eiQep4CDMRZCXXZvnGw9syKBUZLYCDW)3qLak0CdnaTnVgkFb3tp(IHBipQTNPVu4gs6cWDP3qhZLgbekTcdQpwACRTLKwTuOSauKZ1anxi56yUkbuOrO0kmO(yPXT2wsA1sHYIAKrFbflixi56kxhZLgbekTcdQpwACRTLelREbOiNRbAU445sJacLwHb1hlnU12sILvVOzlTgtUuM7V56mxC8CPraHsRWG6JLg3ABjPvlfklmaLCoxQZ94CHKlnciuAfguFS04wBljTAPqzrZwAnMCPo3JZfsU0iGqPvyq9XsJBTTK0QLcLfGICUgO3qLak0CdvAfguFS04wBRl4EkgFXWnKh12Z0xkCdvcOqZn0cHMy18nK0fG7sVHUY1(fJcIkRHiA2sRXKlL5(BUqY1vU2Vyu06hpONrgBEcevIMT0Am5szU)MloEUoMR9lgfT(Xd6zKXMNarL4bNRZCXXZ1XCTFXOGOYAiIhCU445QgqREjmYn35sDUh)pxN5cjxx56yU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUQb0QxcJCZDUuN7X)Z1zUqYvHLeSm58neOnugiR4nS5yZgSQTNZfsUaTHYabOSyjajPloxkZfZGUG7P)EXWnKh12Z0xkCdvcOqZn08My18nK0fG7sVHUY1(fJcIkRHiA2sRXKlL5(BUqY1vU2Vyu06hpONrgBEcevIMT0Am5szU)MloEUoMR9lgfT(Xd6zKXMNarL4bNRZCXXZ1XCTFXOGOYAiIhCU445QgqREjmYn35sDUh)pxN5cjxx56yU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUQb0QxcJCZDUuN7X)Z1zUqYvHLeSm58neOnugiR4nS5yZgSQTNZfsUaTHYabOSyjajPloxkZfZGUG7Pb(fd3qEuBptFPWnujGcn3qdG9ETLrV28nK0fG7sVHUY1(fJcIkRHiA2sRXKlL5(BUqY1vU2Vyu06hpONrgBEcevIMT0Am5szU)MloEUoMR9lgfT(Xd6zKXMNarL4bNRZCXXZ1XCTFXOGOYAiIhCU445QgqREjmYn35sDUh)pxN5cjxx56yU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUQb0QxcJCZDUuN7X)Z1zUqYvHLeSm58neOnugiR4nS5yZgSQTNZfsUaTHYabOSyjajPloxkZfZa)cUN6WxmCd5rT9m9Lc3qsxaUl9gQWscwMC(gQeqHMBye1ewIIYrbVMVG7PyKlgUH8O2EM(sHBiPla3LEdTFXOGOYAiIh8nujGcn3Ww)4b9mYyZtGO6cUN6GxmCd5rT9m9Lc3qsxaUl9g6kxx5A)Irbt8fSHLgKxBrZwAnMCPmxm)NloEU2VyuWeFbByP)nAlA2sRXKlL5I5)CDMlKCjiKNg5Eeevwdr0SLwJjxkZ94)56mxC8CjiKNg5Eeevwdr0Sst1nujGcn3WZ1q3mT0axDbmxW9um)FXWnKh12Z0xkCdjDb4U0BORCTFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdoxC8CDmxc6JhDaIZu1Lo56mxC8CjOpE0biMckwGmQCU445(PDP2EwugPI4CXXZ1(fJcBpcr7FgG4bNlKCTFXOW2Jq0(NbiA2sRXKl15g0)Cdixx5IX56a5sqd9Rac4MjLHLQVGow8ae8O2EMoxN5cjxhZ1(fJcIkRHiEW5cjxx5wdGByKxbmTmwqXcKnBP1yYL6CjiKNg5Eee08HoZsawwAGRUagrZwAnMCdixhoxC8CRbWnmYRaMwglOybYMT0Am5sDUbfuU445wdGByKxbmTmwqXcKnBP1yY9O5Ijg5FUuNBqbLloEUeeYtJCpccA(qNzjallnWvxaJ4bNloEUoMlb9XJoaXuqXcKrLZ15nujGcn3qc7zdOuVu9f0XIhWfCpftmVy4gYJA7z6lfUHKUaCx6n0vU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUoMlb9XJoaXzQ6sNCDMloEUe0hp6aetbflqgvoxC8C)0UuBplkJurCU445A)IrHThHO9pdq8GZfsU2Vyuy7riA)ZaenBP1yYL6Cp(FUbKRRCX4CDGCjOH(vabCZKYWs1xqhlEacEuBptNRZCHKRJ5A)IrbrL1qep4CHKRRCRbWnmYRaMwglOybYMT0Am5sDUeeYtJCpccA(qNzjallnWvxaJOzlTgtUbKRdNloEU1a4gg5vatlJfuSazZwAnMCPo3JdkxC8CRbWnmYRaMwglOybYMT0Am5E0CXeJ8pxQZ94GYfhpxcc5PrUhbbnFOZSeGLLg4QlGr8GZfhpxhZLG(4rhGykOybYOY568gQeqHMByneThfuO5cUNIzqxmCd5rT9m9Lc3qe8n0WGBOsafAUHFAxQTNVHFQ)X3qc6JhDaIPGIfiJkNlKCDLR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNl15geg)pxi56kxcc5PrUhbrL1qenBP1yYnGCX8FUuMBnaUHrEfW0Yybflq2SLwJjxC8CjiKNg5Eeevwdr0SLwJj3aY94)5sDU1a4gg5vatlJfuSazZwAnMCHKBnaUHrEfW0Yybflq2SLwJjxkZfZJ)NloEU2VyuquznerZwAnMCPmxhoxN5cjx7xmkyIVGnS0G8AlA2sRXKlL5I5)CXXZTga3WiVcyAzSGIfiB2sRXK7rZfZG(Nl15I5V568g(PTCul(gsqZh6mljOHUafAUG7PyE8fd3qEuBptFPWnebFdnm4gQeqHMB4N2LA75B4N6F8n0vUoMlbH80i3JGOYAiIMvAQYfhpxhZ9t7sT9SGGMp0zwsqdDbk0KlKCjOpE0biMckwGmQCUoVHFAlh1IVHg9JLruljQSgYfCpftm(IHBipQTNPVu4gs6cWDP3WpTl12ZccA(qNzjbn0fOqtUqYvnGw9syKBUZL6CX4)3qLak0CdjO5dDMLaSS0axDbmxW9um)9IHBipQTNPVu4gs6cWDP3qM4lydlQrQdv5cjxfwsWYKZ5cjxx5sJacLwHb1hlnU12ssRwkuwakY5AGMloEUoMlb9XJoaXWKg5rnDUoZfsUFAxQTNfg9JLruljQSgYnujGcn3W4RPsIIs2)g(cUNIzGFXWnKh12Z0xkCdjDb4U0Bib9XJoaXuqXcKrLZfsUFAxQTNfe08HoZscAOlqHMCHKRAaT6LWi3CNlLhYfJ)NlKCjiKNg5Eee08HoZsawwAGRUagrZwAnMCPoxOeAHLsXCDGCjC5Z1vUQb0QxcJCZDU)K7X)Z15nujGcn3qdqBZRHYxW9umD4lgUH8O2EM(sHBiPla3LEdDLR9lgfmXxWgw6FJ2IhCU4456kxcwTHYMCpKBq5cj3Mjy1gklbLfNl15(BUoZfhpxcwTHYMCpK7X56mxi5QWscwMCoxi5(PDP2Ewy0pwgrTKOYAi3qLak0Cdh2T0cHMl4EkMyKlgUH8O2EM(sHBiPla3LEdDLR9lgfmXxWgw6FJ2IhCUqY1XCjOpE0biotvx6KloEUUY1(fJIZ1q3mTKTGrU52IhGKhUHwbIfp4CHKlb9XJoaXzQ6sNCDMloEUUYLGvBOSj3d5guUqYTzcwTHYsqzX5sDU)MRZCXXZLGvBOSj3d5ECU445A)IrbrL1qep4CDMlKCvyjbltoNlKC)0UuBplm6hlJOwsuznKBOsafAUHyvFuAHqZfCpfth8IHBipQTNPVu4gs6cWDP3qx5A)Irbt8fSHL(3OT4bNlKCDmxc6JhDaIZu1Lo5IJNRRCTFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdoxi5sqF8OdqCMQU0jxN5IJNRRCjy1gkBY9qUbLlKCBMGvBOSeuwCUuN7V56mxC8Cjy1gkBY9qUhNloEU2VyuquzneXdoxN5cjxfwsWYKZ5cj3pTl12ZcJ(XYiQLevwd5gQeqHMBy859sleAUG7Pb9)IHBOsafAUHU1Ululrrj7FdFd5rT9m9LcxW90GW8IHBipQTNPVu4gs6cWDP3qM4lydlQr6FJ25IJNlt8fSHfgKxB5WueKloEUmXxWgwOdvYHPiixC8CTFXOWT2DHAjkkz)ByXdoxi5A)Irbt8fSHL(3OT4bNloEUUY1(fJcIkRHiA2sRXKl15QeqHgH7wbyfmfzYdWsqzX5cjx7xmkiQSgI4bNRZBOsafAUHgG2XQ5l4EAqbDXWnujGcn3q3TcWEd5rT9m9LcxW90Go(IHBipQTNPVu4gQeqHMBy)gPsafAK(YaUH(YaKJAX3WO69aS97cUGBOI4lgUNI5fd3qEuBptFPWnK0fG7sVH2VyuyaAhvVx0CSzdw12Z5cjxx56yU9B4iQHYcpveTvJm6zgudujuFzbBybJr9kyyMoxC8CbLfN7rZfJ)nxkZ1(fJcdq7O69IMT0Am5gqUbLRZBOsafAUHgG2r17VG7PbDXWnKh12Z0xkCdrW3qddUHkbuO5g(PDP2E(g(P(hFdvdOvVeg5M7CPmxmY)CDO56kxm)NRdKR9lgfGYIDJ6rs3SAzxdn3cdqjNZ1zUo0CDLR9lgfgG2r17fnBP1yY1bY94C)jxdm79sSQbW56mxhAUUYLgbeXxtLefLS)nSOzlTgtUoqU)MRZCHKR9lgfgG2r17fp4B4N2YrT4BObODu9EPB0aKr17LOy8cUNE8fd3qEuBptFPWnK0fG7sVHUY1(fJcqzXUr9iPBwTSRHMBrZwAnMCPoxOeAHLsXCdi3)cmZfhpx7xmkaLf7g1JKUz1YUgAUfnBP1yYL6CvcOqJWa0ownlykYKhGLGYIZnGC)lWmxi56kxM4lydlQr6FJ25IJNlt8fSHfgKxB5WueKloEUmXxWgwOdvYHPiixN56mxi5(PDP2EwyaAhvVx6gnazu9EjkgZfsU2Vyuakl2nQhjDZQLDn0ClEW3qLak0CdnaTnVgkFb3tX4lgUH8O2EM(sHBOsafAUHM3eRMVHKUaCx6nuHLeSm5CUqYLj(c2WIAK6qvUqYT5yZgSQTNZfsUaTHYabOSyjajPloxkZftmoxhAUgy27LaTHYatUbKBZwAnMBiHkINLaTHYaZ9umVG7P)EXWnKh12Z0xkCdvcOqZnuPvyq9XsJBTTUHKUaCx6n0XCbf5CnqZfsUoMRsafAekTcdQpwACRTLKwTuOSOgz0xqXcYfhpxAeqO0kmO(yPXT2wsA1sHYcdqjNZL6Cpoxi5sJacLwHb1hlnU12ssRwkuw0SLwJjxQZ94BiHkINLaTHYaZ9umVG7Pb(fd3qEuBptFPWnujGcn3qleAIvZ3qsxaUl9g2CSzdw12Z5cjxG2qzGauwSeGK0fNlL56kxmX4Cdixx5AGzVxc0gkdmcdq7y1CUoqUyk(nxN56m3FY1aZEVeOnugyYnGCB2sRXKlKCDLlbH80i3JGOYAiIMvAQYfhpxdm79sG2qzGryaAhRMZL6CpoxC8CDLlt8fSHf1iniV25IJNlt8fSHf1iTraS5IJNlt8fSHf1i9Vr7CHKRJ5cuppaHb98suucWYYiQzdqWJA7z6CDMlKCDLRbM9EjqBOmWimaTJvZ5sDUy(pxhixx5IzUbKlq98aea31iTqOXi4rT9mDUoZ1zUqYvnGw9syKBUZLYC)9FUo0CTFXOWa0oQEVOzlTgtUoqUbEUoZfsUoMR9lgfNRHUzAjBbJCZTfpajpCdTcelEW5cjxfwsWYKZ3qcveplbAdLbM7PyEb3tD4lgUH8O2EM(sHBiPla3LEdvyjbltoFdvcOqZnmIAclrr5OGxZxW9umYfd3qEuBptFPWnK0fG7sVH2VyuquzneXd(gQeqHMByRF8GEgzS5jquDb3tDWlgUH8O2EM(sHBiPla3LEdDLR9lgfgG2r17fp4CXXZvnGw9syKBUZLYC)9FUoZfsUoMR9lgfgK3akclEW5cjxhZ1(fJcIkRHiEW5cjxx5wdGByKxbmTmwqXcKnBP1yYL6CjiKNg5Eee08HoZsawwAGRUagrZwAnMCdixhoxC8CRbWnmYRaMwglOybYMT0Am5E0CXeJ8pxQZnOGYfhpxcc5PrUhbbnFOZSeGLLg4QlGr8GZfhpxhZLG(4rhGykOybYOY568gQeqHMBiH9SbuQxQ(c6yXd4cUNI5)lgUH8O2EM(sHBiPla3LEdJfuSazZwAnMCPoxm)nxC8CDLR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNl15g0V)Zfhpx7xmkG7Yc10L6LAt0Pis4N3OT4t9poxkpKBq)(pxN5cjx7xmkmaTJQ3lEW5cjxcc5PrUhbrL1qenBP1yYLYC)9)nujGcn3WAiApkOqZfCpftmVy4gYJA7z6lfUHkbuO5gAaS3RTm61MVHKUaCx6nS5yZgSQTNZfsUGYILaKKU4CPmxm)nxi5AGzVxc0gkdmcdq7y1CUuNlgNlKCvyjbltoNlKCDLR9lgfevwdr0SLwJjxkZfZ)5IJNRJ5A)IrbrL1qep4CDEdjur8SeOnugyUNI5fCpfZGUy4gYJA7z6lfUHi4BOHb3qLak0Cd)0UuBpFd)u)JVH2Vyua3LfQPl1l1MOtrKWpVrBXN6FCUuNBq)(pxhAUQb0QxcJCZDUqY1vUeeYtJCpcIkRHiA2sRXKBa5I5)CPm3ybflq2SLwJjxC8CjiKNg5Eeevwdr0SLwJj3aY94)5sDUXckwGSzlTgtUqYnwqXcKnBP1yYLYCX84)5IJNR9lgfevwdr0SLwJjxkZ1HZ1zUqYLj(c2WIAK6qvU445glOybYMT0Am5E0CXmO)5sDUy(7n8tB5Ow8nKGMp0zwsqdDbk0Cb3tX84lgUH8O2EM(sHBiPla3LEd)0UuBpliO5dDMLe0qxGcn5cjx1aA1lHrU5oxQZ93)3qLak0CdjO5dDMLaSS0axDbmxW9umX4lgUH8O2EM(sHBiPla3LEdzIVGnSOgPouLlKCvyjbltoNlKCTFXOaUllutxQxQnrNIiHFEJ2Ip1)4CPo3G(9FUqY1vU0iGqPvyq9XsJBTTK0QLcLfGICUgO5IJNRJ5sqF8OdqmmPrEutNloEUgy27LaTHYatUuMBq568gQeqHMBy81ujrrj7FdFb3tX83lgUH8O2EM(sHBiPla3LEdTFXOanmaRrcZnHHbfAep4CHKRRCTFXOWa0oQEVO5yZgSQTNZfhpx1aA1lHrU5oxkZ1b)NRZBOsafAUHgG2r17VG7Pyg4xmCd5rT9m9Lc3qsxaUl9gsqF8OdqmfuSazu5CHK7N2LA7zbbnFOZSKGg6cuOjxi5sqipnY9iiO5dDMLaSS0axDbmIMT0Am5sDUqj0clLI56a5s4YNRRCvdOvVeg5M7C)j3F)NRZCHKR9lgfgG2r17fnhB2GvT98nujGcn3qdq7O69xW9umD4lgUH8O2EM(sHBiPla3LEdjOpE0biMckwGmQCUqY9t7sT9SGGMp0zwsqdDbk0KlKCjiKNg5Eee08HoZsawwAGRUagrZwAnMCPoxOeAHLsXCDGCjC5Z1vUQb0QxcJCZDU)K7X)Z1zUqY1(fJcdq7O69Ih8nujGcn3qdqBZRHYxW9umXixmCd5rT9m9Lc3qsxaUl9gA)IrbAyawJK4zTLFLPqJ4bNloEUoMRbODSAwOWscwMCoxC8CDLR9lgfevwdr0SLwJjxQZ93CHKR9lgfevwdr8GZfhpxx5A)IrrRF8GEgzS5jqujA2sRXKl15cLqlSukMRdKlHlFUUYvnGw9syKBUZ9NCp(FUoZfsU2Vyu06hpONrgBEcevIhCUoZ1zUqY9t7sT9SWa0oQEV0nAaYO69sumMlKCnWS3lbAdLbgHbODu9(CPo3JVHkbuO5gAaABEnu(cUNIPdEXWnKh12Z0xkCdjDb4U0BORCzIVGnSOgPouLlKCjiKNg5Eeevwdr0SLwJjxkZ93)5IJNRRCjy1gkBY9qUbLlKCBMGvBOSeuwCUuN7V56mxC8Cjy1gkBY9qUhNRZCHKRcljyzY5BOsafAUHd7wAHqZfCpnO)xmCd5rT9m9Lc3qsxaUl9g6kxM4lydlQrQdv5cjxcc5PrUhbrL1qenBP1yYLYC)9FU4456kxcwTHYMCpKBq5cj3Mjy1gklbLfNl15(BUoZfhpxcwTHYMCpK7X56mxi5QWscwMC(gQeqHMBiw1hLwi0Cb3tdcZlgUH8O2EM(sHBiPla3LEdDLlt8fSHf1i1HQCHKlbH80i3JGOYAiIMT0Am5szU)(pxC8CDLlbR2qztUhYnOCHKBZeSAdLLGYIZL6C)nxN5IJNlbR2qztUhY94CDMlKCvyjbltoFdvcOqZnm(8EPfcnxW90Gc6IHBOsafAUHU1Ululrrj7FdFd5rT9m9LcxW90Go(IHBipQTNPVu4gIGVHggCdvcOqZn8t7sT98n8t9p(gAGzVxc0gkdmcdq7y1CUuMlgj3aYn6rOoxx5APga3uj)u)JZ9NCd6FUoZnGCJEeQZ1vU2VyuyaABEnuwYwWi3CBXdqyak5CU)KlgNRZB4N2YrT4BObODSAwwJ0G8AFb3tdcJVy4gYJA7z6lfUHKUaCx6nKj(c2Wc)B0womfb5IJNlt8fSHf6qLCykcYfsUFAxQTNfLrs8S(X5IJNlt8fSHf1iniV25cjxhZ9t7sT9SWa0ownlRrAqETZfhpx7xmkiQSgIOzlTgtUuNRsafAegG2XQzbtrM8aSeuwCUqY1XC)0UuBplkJK4z9JZfsU2VyuquznerZwAnMCPoxMIm5byjOS4CHKR9lgfevwdr8GZfhpx7xmkA9Jh0ZiJnpbIkXdoxi5AGzVxIvnaoxkZ9ViWZfhpxhZ9t7sT9SOmsIN1poxi5A)IrbrL1qenBP1yYLYCzkYKhGLGYIVHkbuO5g6Uva2l4EAq)EXWnujGcn3qdq7y18nKh12Z0xkCb3tdkWVy4gYJA7z6lfUHkbuO5g2VrQeqHgPVmGBOVma5Ow8nmQEpaB)UGl4ggvVhGTFxmCpfZlgUH8O2EM(sHBiPla3LEdDm3(nCe1qzHT61HWsuuQEVeGTgOgbJr9kyyM(gQeqHMBObOT51q5l4EAqxmCd5rT9m9Lc3qLak0CdnVjwnFdjDb4U0BinciSqOjwnlA2sRXKlL52SLwJ5gsOI4zjqBOmWCpfZl4E6XxmCdvcOqZn0cHMy18nKh12Z0xkCbxWn0aUy4EkMxmCd5rT9m9Lc3qLak0CdvAfguFS04wBRBiPla3LEdDmxAeqO0kmO(yPXT2wsA1sHYcqroxd0CHKRJ5QeqHgHsRWG6JLg3ABjPvlfklQrg9fuSGCHKRRCDmxAeqO0kmO(yPXT2wsSS6fGICUgO5IJNlnciuAfguFS04wBljww9IMT0Am5szU)MRZCXXZLgbekTcdQpwACRTLKwTuOSWauY5CPo3JZfsU0iGqPvyq9XsJBTTK0QLcLfnBP1yYL6Cpoxi5sJacLwHb1hlnU12ssRwkuwakY5AGEdjur8SeOnugyUNI5fCpnOlgUH8O2EM(sHBOsafAUHwi0eRMVHKUaCx6n0vU2VyuquznerZwAnMCPm3FZfsUUY1(fJIw)4b9mYyZtGOs0SLwJjxkZ93CXXZ1XCTFXOO1pEqpJm28eiQep4CDMloEUoMR9lgfevwdr8GZfhpx1aA1lHrU5oxQZ94)56mxi56kxhZ1(fJIZ1q3mTKTGrU52IhGKhUHwbIfp4CXXZvnGw9syKBUZL6Cp(FUoZfsUkSKGLjNVHeQiEwc0gkdm3tX8cUNE8fd3qEuBptFPWnujGcn3qZBIvZ3qsxaUl9g2CSzdw12Z5cjxG2qzGauwSeGK0fNlL5Izq5cjxx5A)IrbrL1qenBP1yYLYC)nxi56kx7xmkA9Jh0ZiJnpbIkrZwAnMCPm3FZfhpxhZ1(fJIw)4b9mYyZtGOs8GZ1zU4456yU2VyuquzneXdoxC8CvdOvVeg5M7CPo3J)NRZCHKRRCDmx7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GZfhpx1aA1lHrU5oxQZ94)56mxi5QWscwMC(gsOI4zjqBOmWCpfZl4EkgFXWnKh12Z0xkCdvcOqZn0ayVxBz0RnFdjDb4U0ByZXMnyvBpNlKCbAdLbcqzXsassxCUuMlMbEUqY1vU2VyuquznerZwAnMCPm3FZfsUUY1(fJIw)4b9mYyZtGOs0SLwJjxkZ93CXXZ1XCTFXOO1pEqpJm28eiQep4CDMloEUoMR9lgfevwdr8GZfhpx1aA1lHrU5oxQZ94)56mxi56kxhZ1(fJIZ1q3mTKTGrU52IhGKhUHwbIfp4CXXZvnGw9syKBUZL6Cp(FUoZfsUkSKGLjNVHeQiEwc0gkdm3tX8cUN(7fd3qEuBptFPWnK0fG7sVHkSKGLjNVHkbuO5ggrnHLOOCuWR5l4EAGFXWnKh12Z0xkCdjDb4U0BO9lgfevwdr8GVHkbuO5g26hpONrgBEcevxW9uh(IHBipQTNPVu4gs6cWDP3qx56kx7xmkyIVGnS0G8AlA2sRXKlL5I5)CXXZ1(fJcM4lydl9VrBrZwAnMCPmxm)NRZCHKlbH80i3JGOYAiIMT0Am5szUh)pxi56kx7xmkG7Yc10L6LAt0Pis4N3OT4t9poxQZnim(FU4456yU9B4iQHYc4USqnDPEP2eDkIe(5nAlymQxbdZ056mxN5IJNR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNlLhYnih(FU445sqipnY9iiQSgIOzLMQCHKRRCvdOvVeg5M7CPmxh8FU445(PDP2EwugPI4CDEdvcOqZn8Cn0ntlnWvxaZfCpfJCXWnKh12Z0xkCdjDb4U0BORCvdOvVeg5M7CPmxh8FUqY1vU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUoMlb9XJoaXzQ6sNCDMloEUe0hp6aetbflqgvoxC8C)0UuBplkJurCU445A)IrHThHO9pdq8GZfsU2Vyuy7riA)ZaenBP1yYL6Cd6FUbKRRCDLRdMRdKB)goIAOSaUllutxQxQnrNIiHFEJ2cgJ6vWWmDUoZnGCDLlgNRdKlbn0VciGBMugwQ(c6yXdqWJA7z6CDMRZCDMlKCDmx7xmkiQSgI4bNlKCDLBSGIfiB2sRXKl15sqipnY9iiO5dDMLaSS0axDbmIMT0Am5gqUoCU445glOybYMT0Am5sDUbfuUbKRRCDWCDGCDLR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNlL5I5))56mxN5IJNBSGIfiB2sRXK7rZftmY)CPo3GckxC8CjiKNg5Eee08HoZsawwAGRUagXdoxC8CDmxc6JhDaIPGIfiJkNRZBOsafAUHe2ZgqPEP6lOJfpGl4EQdEXWnKh12Z0xkCdjDb4U0BORCvdOvVeg5M7CPmxh8FUqY1vU2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bNloEUoMlb9XJoaXzQ6sNCDMloEUe0hp6aetbflqgvoxC8C)0UuBplkJurCU445A)IrHThHO9pdq8GZfsU2Vyuy7riA)ZaenBP1yYL6Cp(FUbKRRCDLRdMRdKB)goIAOSaUllutxQxQnrNIiHFEJ2cgJ6vWWmDUoZnGCDLlgNRdKlbn0VciGBMugwQ(c6yXdqWJA7z6CDMRZCDMlKCDmx7xmkiQSgI4bNlKCDLBSGIfiB2sRXKl15sqipnY9iiO5dDMLaSS0axDbmIMT0Am5gqUoCU445glOybYMT0Am5sDUhhuUbKRRCDWCDGCDLR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNlL5I5))56mxN5IJNBSGIfiB2sRXK7rZftmY)CPo3JdkxC8CjiKNg5Eee08HoZsawwAGRUagXdoxC8CDmxc6JhDaIPGIfiJkNRZBOsafAUH1q0EuqHMl4EkM)Vy4gYJA7z6lfUHi4BOHb3qLak0Cd)0UuBpFd)u)JVHe0hp6aetbflqgvoxi56kx7xmkG7Yc10L6LAt0Pis4N3OT4t9poxQZnim(FUqY1vUeeYtJCpcIkRHiA2sRXKBa5I5)CPm3ybflq2SLwJjxC8CjiKNg5Eeevwdr0SLwJj3aY94)5sDUXckwGSzlTgtUqYnwqXcKnBP1yYLYCX84)5IJNR9lgfevwdr0SLwJjxkZ1HZ1zUqY1(fJcM4lydlniV2IMT0Am5szUy(pxC8CJfuSazZwAnMCpAUyg0)CPoxm)nxN3WpTLJAX3qcA(qNzjbn0fOqZfCpftmVy4gYJA7z6lfUHi4BOHb3qLak0Cd)0UuBpFd)u)JVHUY1XCjiKNg5Eeevwdr0SstvU4456yUFAxQTNfe08HoZscAOlqHMCHKlb9XJoaXuqXcKrLZ15n8tB5Ow8n0OFSmIAjrL1qUG7Pyg0fd3qEuBptFPWnK0fG7sVHFAxQTNfe08HoZscAOlqHMCHKRAaT6LWi3CNl15E8)BOsafAUHe08HoZsawwAGRUaMl4EkMhFXWnKh12Z0xkCdjDb4U0Bit8fSHf1i1HQCHKRcljyzY5CHKR9lgfWDzHA6s9sTj6uej8ZB0w8P(hNl15geg)pxi56kxAeqO0kmO(yPXT2wsA1sHYcqroxd0CXXZ1XCjOpE0bigM0ipQPZ1zUqY9t7sT9SWOFSmIAjrL1qUHkbuO5ggFnvsuuY(3WxW9umX4lgUH8O2EM(sHBiPla3LEdTFXOanmaRrcZnHHbfAep4CHKR9lgfgG2r17fnhB2GvT98nujGcn3qdq7O69xW9um)9IHBipQTNPVu4gs6cWDP3q7xmkmaT9OMw0SLwJjxQZ93CHKRRCTFXOGj(c2WsdYRTOzlTgtUuM7V5IJNR9lgfmXxWgw6FJ2IMT0Am5szU)MRZCHKRAaT6LWi3CNlL56G)VHkbuO5gs0HWEP9lgVH2VyuoQfFdnaT9OM(cUNIzGFXWnKh12Z0xkCdjDb4U0Bib9XJoaXuqXcKrLZfsUFAxQTNfe08HoZscAOlqHMCHKlbH80i3JGGMp0zwcWYsdC1fWiA2sRXKl15cLqlSukMRdKlHlFUUYvnGw9syKBUZ9NCp(FUoVHkbuO5gAaABEnu(cUNIPdFXWnKh12Z0xkCdjDb4U0Biq98aega79AlP7kce8O2EMoxi56yUa1ZdqyaA7rnTGh12Z05cjx7xmkmaTJQ3lAo2SbRA75CHKRRCTFXOGj(c2Ws)B0w0SLwJjxkZnWZfsUmXxWgwuJ0)gTZfsU2Vyua3LfQPl1l1MOtrKWpVrBXN6FCUuNBq)(pxC8CTFXOaUllutxQxQnrNIiHFEJ2Ip1)4CP8qUb97)CHKRAaT6LWi3CNlL56G)ZfhpxAeqO0kmO(yPXT2wsA1sHYIMT0Am5szUyKCXXZvjGcncLwHb1hlnU12ssRwkuwuJm6lOyb56mxi56yUeeYtJCpcIkRHiAwPP6gQeqHMBObODu9(l4EkMyKlgUH8O2EM(sHBiPla3LEdTFXOanmaRrs8S2YVYuOr8GZfhpx7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GZfhpx7xmkiQSgI4bNlKCDLR9lgfT(Xd6zKXMNarLOzlTgtUuNlucTWsPyUoqUeU856kx1aA1lHrU5o3FY94)56mxi5A)IrrRF8GEgzS5jqujEW5IJNRJ5A)IrrRF8GEgzS5jqujEW5cjxhZLGqEAK7r06hpONrgBEcevIMvAQYfhpxhZLG(4rhG4JhawQ6CDMloEUQb0QxcJCZDUuMRd(pxi5YeFbByrnsDO6gQeqHMBObOT51q5l4EkMo4fd3qEuBptFPWnK0fG7sVHa1ZdqyaA7rnTGh12Z05cjxx5A)IrHbOTh10IhCU445QgqREjmYn35szUo4)CDMlKCTFXOWa02JAAHbOKZ5sDUhNlKCDLR9lgfmXxWgwAqETfp4CXXZ1(fJcM4lydl9VrBXdoxN5cjx7xmkG7Yc10L6LAt0Pis4N3OT4t9poxQZnih(FUqY1vUeeYtJCpcIkRHiA2sRXKlL5I5)CXXZ1XC)0UuBpliO5dDMLe0qxGcn5cjxc6JhDaIPGIfiJkNRZBOsafAUHgG2MxdLVG7Pb9)IHBipQTNPVu4gs6cWDP3qx5A)IrbCxwOMUuVuBIofrc)8gTfFQ)X5sDUb5W)Zfhpx7xmkG7Yc10L6LAt0Pis4N3OT4t9poxQZnOF)NlKCbQNhGWayVxBjDxrGGh12Z056mxi5A)Irbt8fSHLgKxBrZwAnMCPmxhoxi5YeFbByrnsdYRDUqY1XCTFXOanmaRrcZnHHbfAep4CHKRJ5cuppaHbOTh10cEuBptNlKCjiKNg5Eeevwdr0SLwJjxkZ1HZfsUUYLGqEAK7rCUg6MPLg4QlGr0SLwJjxkZ1HZfhpxhZLG(4rhG4mvDPtUoVHkbuO5gAaABEnu(cUNgeMxmCd5rT9m9Lc3qsxaUl9g6kx7xmkyIVGnS0)gTfp4CXXZ1vUeSAdLn5Ei3GYfsUntWQnuwckloxQZ93CDMloEUeSAdLn5Ei3JZ1zUqYvHLeSm5CUqY9t7sT9SWOFSmIAjrL1qUHkbuO5goSBPfcnxW90Gc6IHBipQTNPVu4gs6cWDP3qx5A)Irbt8fSHL(3OT4bNlKCDmxc6JhDaIZu1Lo5IJNRRCTFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdoxi5sqF8OdqCMQU0jxN5IJNRRCjy1gkBY9qUbLlKCBMGvBOSeuwCUuN7V56mxC8Cjy1gkBY9qUhNloEU2VyuquzneXdoxN5cjxfwsWYKZ5cj3pTl12ZcJ(XYiQLevwd5gQeqHMBiw1hLwi0Cb3td64lgUH8O2EM(sHBiPla3LEdDLR9lgfmXxWgw6FJ2IhCUqY1XCjOpE0biotvx6KloEUUY1(fJIZ1q3mTKTGrU52IhGKhUHwbIfp4CHKlb9XJoaXzQ6sNCDMloEUUYLGvBOSj3d5guUqYTzcwTHYsqzX5sDU)MRZCXXZLGvBOSj3d5ECU445A)IrbrL1qep4CDMlKCvyjbltoNlKC)0UuBplm6hlJOwsuznKBOsafAUHXN3lTqO5cUNgegFXWnujGcn3q3A3fQLOOK9VHVH8O2EM(sHl4EAq)EXWnKh12Z0xkCdjDb4U0Bit8fSHf1i9Vr7CXXZLj(c2WcdYRTCykcYfhpxM4lydl0Hk5WueKloEU2Vyu4w7UqTefLS)nS4bNlKCTFXOGj(c2Ws)B0w8GZfhpxx5A)IrbrL1qenBP1yYL6CvcOqJWDRaScMIm5byjOS4CHKR9lgfevwdr8GZ15nujGcn3qdq7y18fCpnOa)IHBOsafAUHUBfG9gYJA7z6lfUG7Pb5WxmCd5rT9m9Lc3qLak0Cd73ivcOqJ0xgWn0xgGCul(ggvVhGTFxWfCdHBgwbeSsd4IH7PyEXWnKh12Z0xkCdvcOqZn0cHMy18nK0fG7sVHnhB2GvT9CUqYfOnugiaLflbijDX5szUyguUqY1vU2VyuquznerZwAnMCPm3FZfhpxhZ1(fJcIkRHiEW5IJNRAaT6LWi3CNl15E8)CDMlKCvyjbltoFdjur8SeOnugyUNI5fCpnOlgUH8O2EM(sHBOsafAUHM3eRMVHKUaCx6nS5yZgSQTNZfsUaTHYabOSyjajPloxkZfZGYfsUUY1(fJcIkRHiA2sRXKlL5(BU4456yU2VyuquzneXdoxC8CvdOvVeg5M7CPo3J)NRZCHKRcljyzY5BiHkINLaTHYaZ9umVG7PhFXWnKh12Z0xkCdvcOqZn0ayVxBz0RnFdjDb4U0ByZXMnyvBpNlKCbAdLbcqzXsassxCUuMlMbLlKCDLR9lgfevwdr0SLwJjxkZ93CXXZ1XCTFXOGOYAiIhCU445QgqREjmYn35sDUh)pxN5cjxfwsWYKZ3qcveplbAdLbM7PyEb3tX4lgUH8O2EM(sHBiPla3LEdvyjbltoFdvcOqZnmIAclrr5OGxZxW90FVy4gYJA7z6lfUHKUaCx6n0vUQb0QxcJCZDUuMRd(pxC8CTFXOW2Jq0(NbiEW5cjx7xmkS9ieT)zaIMT0Am5sDUbf456mxi56yU2VyuquzneXd(gQeqHMBiH9SbuQxQ(c6yXd4cUNg4xmCd5rT9m9Lc3qsxaUl9g6kx1aA1lHrU5oxkZ1b)NloEU2Vyuy7riA)Zaep4CHKR9lgf2EeI2)marZwAnMCPo3Jd8CDMlKCDmx7xmkiQSgI4bFdvcOqZnSgI2Jck0Cb3tD4lgUH8O2EM(sHBic(gAyWnujGcn3WpTl12Z3Wp1)4BOJ5sqipnY9iiQSgIOzLMQB4N2YrT4BOr)yze1sIkRHCb3tXixmCd5rT9m9Lc3qsxaUl9gYeFbByrnsDOkxi5QWscwMCoxi5(PDP2Ewy0pwgrTKOYAi3qLak0CdJVMkjkkz)B4l4EQdEXWnKh12Z0xkCdjDb4U0BO9lgfgG2EutlA2sRXKl15g45cjxx5A)Irbt8fSHLgKxBXdoxC8CTFXOGj(c2Ws)B0w8GZ1zUqYvnGw9syKBUZLYCDW)3qLak0Cdj6qyV0(fJ3q7xmkh1IVHgG2EutFb3tX8)fd3qEuBptFPWnK0fG7sVHUY1XC1aXDbyHb0SEUgOsdqBJO15CU445A)IrbrL1qenBP1yYL6CzkYKhGLGYIZfhpxhZfU5pHbOT51q5CDMlKCDLR9lgfevwdr8GZfhpx1aA1lHrU5oxkZ1b)NlKCzIVGnSOgPouLRZBOsafAUHgG2MxdLVG7PyI5fd3qEuBptFPWnK0fG7sVHUY1XC1aXDbyHb0SEUgOsdqBJO15CU445A)IrbrL1qenBP1yYL6CzkYKhGLGYIZfhpxhZ9t7sT9SaU5pPbOT51q5CDMlKCbQNhGWa02JAAbpQTNPZfsUUY1(fJcdqBpQPfp4CXXZvnGw9syKBUZLYCDW)56mxi5A)IrHbOTh10cdqjNZL6Cpoxi56kx7xmkyIVGnS0G8AlEW5IJNR9lgfmXxWgw6FJ2IhCUoZfsUeeYtJCpcIkRHiA2sRXKlL56W3qLak0CdnaTnVgkFb3tXmOlgUH8O2EM(sHBiPla3LEdDLRJ5QbI7cWcdOz9CnqLgG2grRZ5CXXZ1(fJcIkRHiA2sRXKl15YuKjpalbLfNloEUoMlCZFcdqBZRHY56mxi5A)Irbt8fSHLgKxBrZwAnMCPmxhoxi5YeFbByrnsdYRDUqY1XCbQNhGWa02JAAbpQTNPZfsUeeYtJCpcIkRHiA2sRXKlL56W3qLak0CdnaTnVgkFb3tX84lgUH8O2EM(sHBiPla3LEdDLR9lgfmXxWgw6FJ2IhCU4456kxcwTHYMCpKBq5cj3Mjy1gklbLfNl15(BUoZfhpxcwTHYMCpK7X56mxi5QWscwMCoxi5(PDP2Ewy0pwgrTKOYAi3qLak0Cdh2T0cHMl4EkMy8fd3qEuBptFPWnK0fG7sVHUY1(fJcM4lydl9VrBXdoxC8CDLlbR2qztUhYnOCHKBZeSAdLLGYIZL6C)nxN5IJNlbR2qztUhY94CXXZ1(fJcIkRHiEW56mxi5QWscwMCoxi5(PDP2Ewy0pwgrTKOYAi3qLak0CdXQ(O0cHMl4EkM)EXWnKh12Z0xkCdjDb4U0BORCTFXOGj(c2Ws)B0w8GZfhpxx5sWQnu2K7HCdkxi52mbR2qzjOS4CPo3FZ1zU445sWQnu2K7HCpoxC8CTFXOGOYAiIhCUoZfsUkSKGLjNZfsUFAxQTNfg9JLruljQSgYnujGcn3W4Z7Lwi0Cb3tXmWVy4gQeqHMBOBT7c1suuY(3W3qEuBptFPWfCpfth(IHBipQTNPVu4gs6cWDP3qx5QbI7cWcdOz9CnqLgG2grRZ5CHKR9lgfevwdr0SLwJjxkZLPitEawckloxi5c38NWDRaS56mxC8CDLRJ5QbI7cWcdOz9CnqLgG2grRZ5CXXZ1(fJcIkRHiA2sRXKl15YuKjpalbLfNloEUoMlCZFcdq7y1CUoZfsUUYLj(c2WIAK(3ODU445YeFbByHb51womfb5IJNlt8fSHf6qLCykcYfhpx7xmkCRDxOwIIs2)gw8GZfsU2VyuWeFbByP)nAlEW5IJNRRCTFXOGOYAiIMT0Am5sDUkbuOr4UvawbtrM8aSeuwCUqY1(fJcIkRHiEW56mxN5IJNRRC1aXDbybT6EQbQ08grRZ5CPm3GYfsU2VyuWeFbByPb51w0SLwJjxkZ93CHKRJ5A)IrbT6EQbQ08grZwAnMCPmxLak0iC3kaRGPitEawckloxN3qLak0CdnaTJvZxW9umXixmCdvcOqZn0DRaS3qEuBptFPWfCpfth8IHBipQTNPVu4gQeqHMBy)gPsafAK(YaUH(YaKJAX3WO69aS97cUGl4g(XTPqZ90G(h0Fm)JzGFdDR9uduZn8i2rGJGNIr)0J4oKCZfdy5CllyudYnI6CXOr3SAzxdn3y0YTzmQx1mDUgKfNR(ailfW05sWQdu2iYGpYA4CdYHKBGHMpUbmDUHLvGLRHQbOum3JMlaL7r(0CPRVYuOjxem3ka1566hN56ctk6uKbFK1W5I5FhsUbgA(4gW05gwwbwUgQgGsXCp6rZfGY9iFAUwi6N)zYfbZTcqDUUoQZCDHjfDkYGpYA4CXethsUbgA(4gW05gwwbwUgQgGsXCp6rZfGY9iFAUwi6N)zYfbZTcqDUUoQZCDHjfDkYGpYA4CXmihsUbgA(4gW05gwwbwUgQgGsXCp6rZfGY9iFAUwi6N)zYfbZTcqDUUoQZCDHjfDkYGpYA4CXmWDi5gyO5JBatNByzfy5AOAakfZ9O5cq5EKpnx66RmfAYfbZTcqDUU(XzUUWKIofzWzWhXocCe8um6NEe3HKBUyalNBzbJAqUruNlgn4MjilBfGrl3MXOEvZ05AqwCU6dGSuatNlbRoqzJid(iRHZ9xhsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRRGOOtrgCg8rSJahbpfJ(PhXDi5MlgWY5wwWOgKBe15IrtrmgTCBgJ6vntNRbzX5QpaYsbmDUeS6aLnIm4JSgoxmDi5gyO5JBatNByzfy5AOAakfZ9Ohnxak3J8P5AHOF(Njxem3ka1566OoZ1fMu0Pid(iRHZnihsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrg8rwdNBG7qYnWqZh3aMo3WYkWY1q1aukM7rZfGY9iFAU01xzk0KlcMBfG6CD9JZCDHjfDkYGpYA4CDqhsUbgA(4gW05gwwbwUgQgGsXCp6rZfGY9iFAUwi6N)zYfbZTcqDUUoQZCDHjfDkYGpYA4CX8Vdj3adnFCdy6CdlRalxdvdqPyUh9O5cq5EKpnxle9Z)m5IG5wbOoxxh1zUUWKIofzWhznCUygKdj3adnFCdy6CdlRalxdvdqPyUh9O5cq5EKpnxle9Z)m5IG5wbOoxxh1zUUWKIofzWhznCUyg4oKCdm08XnGPZnSScSCnunaLI5E0CbOCpYNMlD9vMcn5IG5wbOoxx)4mxxysrNIm4JSgoxmDyhsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrg8rwdNlMyehsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrg8rwdNBqh7qYnWqZh3aMo3WYkWY1q1aukM7rZfGY9iFAU01xzk0KlcMBfG6CD9JZCDfefDkYGZGpIDe4i4Py0p9iUdj3CXawo3Ycg1GCJOoxmAgagTCBgJ6vntNRbzX5QpaYsbmDUeS6aLnIm4JSgoxmIdj3adnFCdy6CdlRalxdvdqPyUh9O5cq5EKpnxle9Z)m5IG5wbOoxxh1zUUWKIofzWhznCUoOdj3adnFCdy6CdlRalxdvdqPyUh9O5cq5EKpnxle9Z)m5IG5wbOoxxh1zUUWKIofzWhznCUy(3HKBGHMpUbmDUHLvGLRHQbOum3JE0CbOCpYNMRfI(5FMCrWCRauNRRJ6mxxysrNIm4JSgoxmdChsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrg8rwdNlMyehsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrgCg8rSJahbpfJ(PhXDi5MlgWY5wwWOgKBe15IrZgPamA52mg1RAMoxdYIZvFaKLcy6Cjy1bkBezWhznCUygKdj3adnFCdy6CdlRalxdvdqPyUh9O5cq5EKpnxle9Z)m5IG5wbOoxxh1zUUWKIofzWhznCUyg4oKCdm08XnGPZnSScSCnunaLI5E0CbOCpYNMlD9vMcn5IG5wbOoxx)4mxxhtrNIm4JSgoxmDyhsUbgA(4gW05gwwbwUgQgGsXCpAUauUh5tZLU(ktHMCrWCRauNRRFCMRlmPOtrgCgmgDlyudy6CXi5QeqHMC9LbyezW3qdmtUNI5)GUHWnkwE(gEeMlfuVoeo3JO0VIod(im3JOjaKn35IzGFsUb9pO)zWzWhH5gyy1bkBCizWhH56qZ9ianntNBiYRDUuGvlrg8ryUo0CdmS6aLPZfOnugiRyUe1WMCbOCjur8SeOnugyezWhH56qZ9iiBH(y6CFZWe2y0MQC)0UuBpBY1vjyXj5c38N0a028AOCUoukZfU5pHbOT51qzNIm4myLak0yeWntqw2k4GfcnNRrgrTvgSsafAmc4MjilBfeWHFC3kaBgSsafAmc4MjilBfeWHFC3kaBgSsafAmc4MjilBfeWHFmaTnVgkFsfpyGzVxc0gkdmcdq7O69uJXzWkbuOXiGBMGSSvqah(5t7sT98jJAXhiO5dDML0SHQHCYN6F8bBKXaj6rO2LRybflq2SLwJXHg0FNhfZG(7KYOhHAxUIfuSazZwAnghAq)6qDH5FhaOEEaIAiApkOqJGh12Z0oDOUWyhGGg6xbeWntkdlvFbDS4bi4rT9mTtNhftmYFNzWzWhH5EevkYKhGPZL)4MQCbLfNlalNRsaOo3YKR(PLxT9SidwjGcnMdgKxBPnRwzWkbuOXeWHF(0UuBpFYOw8HYiveFYN6F8bdm79sG2qzGryaAhvVNsmH4YrG65bimaT9OMwWJA7zACCG65bima271ws3vei4rT9mTtCCdm79sG2qzGryaAhvVNYGYGvcOqJjGd)8PDP2E(KrT4dLrs8S(XN8P(hFWaZEVeOnugyegG2XQzkXmdwjGcnMao8Jn3gUpxd0tQ4bxosqF8OdqmfuSazuzCChjiKNg5Eee08HoZsawwAGRUagXd2je7xmkiQSgI4bNbReqHgtah(bgbk0Csfpy)IrbrL1qep4myLak0yc4WppdllaBzYGvcOqJjGd)0VrQeqHgPVmGtg1IpOi(edOlc4aMNuXdFAxQTNfLrQiodwjGcnMao8t)gPsafAK(Yaozul(aDZQLDn0CFIb0fbCaZtQ4H(nCe1qzbOSy3OEK0nRw21qZTGXOEfmmtNbReqHgtah(PFJujGcnsFzaNmQfFWgPGtmGUiGdyEsfp0VHJOgklSvVoewIIs17LaS1a1iymQxbdZ0zWkbuOXeWHF63ivcOqJ0xgWjJAXhmGtQ4bp)XEk)9FgSsafAmbC4N(nsLak0i9LbCYOw8b4MHvabR0aYGZGvcOqJrOi(GbODu9(tQ4b7xmkmaTJQ3lAo2SbRA7ziUCSFdhrnuw4PIOTAKrpZGAGkH6llydlymQxbdZ044GYIp6rX4FP0(fJcdq7O69IMT0AmbeKZmyLak0yekId4WpFAxQTNpzul(GbODu9EPB0aKr17LOy8Kp1)4dQb0QxcJCZnLyK)ouxy(3bSFXOauwSBups6Mvl7AO5wyak5SthQl7xmkmaTJQ3lA2sRX4ahFudm79sSQbWoDOUOrar81ujrrj7FdlA2sRX4a)6eI9lgfgG2r17fp4myLak0yekId4WpgG2MxdLpPIhCz)IrbOSy3OEK0nRw21qZTOzlTgd1qj0clLIb8xGjoU9lgfGYIDJ6rs3SAzxdn3IMT0AmuReqHgHbODSAwWuKjpalbLfhWFbMqCXeFbByrns)B0ghNj(c2WcdYRTCykcWXzIVGnSqhQKdtrGtNq(0UuBplmaTJQ3lDJgGmQEVefJqSFXOauwSBups6Mvl7AO5w8GZGvcOqJrOioGd)yEtSA(ecveplbAdLbMdyEsfpOWscwMCgct8fSHf1i1HkinhB2GvT9meG2qzGauwSeGK0ftjMySd1aZEVeOnugycOzlTgtgSsafAmcfXbC4hLwHb1hlnU126ecveplbAdLbMdyEsfp4iOiNRbkehvcOqJqPvyq9XsJBTTK0QLcLf1iJ(ckwaoonciuAfguFS04wBljTAPqzHbOKZuFmeAeqO0kmO(yPXT2wsA1sHYIMT0AmuFCgSsafAmcfXbC4hleAIvZNqOI4zjqBOmWCaZtQ4HMJnBWQ2EgcqBOmqaklwcqs6IP0fMyCaUmWS3lbAdLbgHbODSA2bWu8RtNh1aZEVeOnugycOzlTgdexeeYtJCpcIkRHiAwPPch3aZEVeOnugyegG2XQzQpgh3ft8fSHf1iniV244mXxWgwuJ0gbWIJZeFbByrns)B0gIJa1ZdqyqpVefLaSSmIA2ae8O2EM2jexgy27LaTHYaJWa0owntnM)Daxygaq98aea31iTqOXi4rT9mTtNqudOvVeg5MBk)9Vd1(fJcdq7O69IMT0AmoqG7eIJ2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bdrHLeSm5CgSsafAmcfXbC4NiQjSefLJcEnFsfpOWscwMCodwjGcngHI4ao8tRF8GEgzS5jquDsfpy)IrbrL1qep4myLak0yekId4Wpe2ZgqPEP6lOJfpGtQ4bx2VyuyaAhvVx8GXXvdOvVeg5MBk)9VtioA)IrHb5nGIWIhmehTFXOGOYAiIhmex1a4gg5vatlJfuSazZwAngQjiKNg5Eee08HoZsawwAGRUagrZwAnMaCyC8AaCdJ8kGPLXckwGSzlTgZrpkMyK)uhuq44eeYtJCpccA(qNzjallnWvxaJ4bJJ7ib9XJoaXuqXcKrLDMbReqHgJqrCah(PgI2Jck0Csfp4Y(fJcdq7O69IhmoUAaT6LWi3Ct5V)DcXr7xmkmiVbuew8GH4O9lgfevwdr8GH4Qga3WiVcyAzSGIfiB2sRXqnbH80i3JGGMp0zwcWYsdC1fWiA2sRXeGdJJxdGByKxbmTmwqXcKnBP1yo6rXeJ8N6JdchNGqEAK7rqqZh6mlbyzPbU6cyepyCChjOpE0biMckwGmQStLak0yekId4WpNRHUzAPbU6cyoPIhIfuSazZwAngQX8xCCx2Vyua3LfQPl1l1MOtrKWpVrBXN6Fm1b97FCC7xmkG7Yc10L6LAt0Pis4N3OT4t9pMYdb97FNqSFXOWa0oQEV4bdHGqEAK7rquznerZwAngk)9FgSsafAmcfXbC4hdG9ETLrV28jeQiEwc0gkdmhW8KkEO5yZgSQTNHaklwcqs6IPeZFHyGzVxc0gkdmcdq7y1m1ymefwsWYKZqCz)IrbrL1qenBP1yOeZ)44oA)IrbrL1qepyNzWkbuOXiuehWHF(0UuBpFYOw8bcA(qNzjbn0fOqZjFQ)XhSFXOaUllutxQxQnrNIiHFEJ2Ip1)yQd63)ou1aA1lHrU5gIlcc5PrUhbrL1qenBP1ycaZ)uglOybYMT0Am44eeYtJCpcIkRHiA2sRXeWX)PowqXcKnBP1yGelOybYMT0AmuI5X)XXTFXOGOYAiIMT0Amu6WoHWeFbByrnsDOchpwqXcKnBP1yo6rXmO)uJ5VzWkbuOXiuehWHFiO5dDMLaSS0axDbmNuXdFAxQTNfe08HoZscAOlqHgiQb0QxcJCZn1)(pdwjGcngHI4ao8t81ujrrj7FdFsfpWeFbByrnsDOcIcljyzYzi2Vyua3LfQPl1l1MOtrKWpVrBXN6Fm1b97FiUOraHsRWG6JLg3ABjPvlfklaf5CnqXXDKG(4rhGyysJ8OMgh3aZEVeOnugyOmiNzWkbuOXiuehWHFmaTJQ3Fsfpy)IrbAyawJeMBcddk0iEWqCz)IrHbODu9ErZXMnyvBpJJRgqREjmYn3u6G)DMbReqHgJqrCah(Xa0oQE)jv8ab9XJoaXuqXcKrLH8PDP2EwqqZh6mljOHUafAGqqipnY9iiO5dDMLaSS0axDbmIMT0AmudLqlSuk6aeU8UudOvVeg5M7J(7FNqSFXOWa0oQEVO5yZgSQTNZGvcOqJrOioGd)yaABEnu(KkEGG(4rhGykOybYOYq(0UuBpliO5dDMLe0qxGcnqiiKNg5Eee08HoZsawwAGRUagrZwAngQHsOfwkfDacxExQb0QxcJCZ9rp(Vti2VyuyaAhvVx8GZGvcOqJrOioGd)yaABEnu(KkEW(fJc0WaSgjXZAl)ktHgXdgh3rdq7y1SqHLeSm5moUl7xmkiQSgIOzlTgd1)cX(fJcIkRHiEW44USFXOO1pEqpJm28eiQenBP1yOgkHwyPu0biC5DPgqREjmYn3h94)oHy)IrrRF8GEgzS5jqujEWoDc5t7sT9SWa0oQEV0nAaYO69sumcXaZEVeOnugyegG2r17P(4myLak0yekId4Wpd7wAHqZjv8GlM4lydlQrQdvqiiKNg5Eeevwdr0SLwJHYF)JJ7IGvBOS5qqqAMGvBOSeuwm1)6ehNGvBOS5WXoHOWscwMCodwjGcngHI4ao8dw1hLwi0Csfp4Ij(c2WIAK6qfecc5PrUhbrL1qenBP1yO83)44Uiy1gkBoeeKMjy1gklbLft9VoXXjy1gkBoCStikSKGLjNZGvcOqJrOioGd)eFEV0cHMtQ4bxmXxWgwuJuhQGqqipnY9iiQSgIOzlTgdL)(hh3fbR2qzZHGG0mbR2qzjOSyQ)1joobR2qzZHJDcrHLeSm5CgSsafAmcfXbC4h3A3fQLOOK9VHZGvcOqJrOioGd)8PDP2E(KrT4dgG2XQzznsdYR9jFQ)XhmWS3lbAdLbgHbODSAMsmsarpc1USudGBQKFQ)XhnO)odi6rO2L9lgfgG2MxdLLSfmYn3w8aegGsoFum2zgSsafAmcfXbC4h3TcWEsfpWeFbByH)nAlhMIaCCM4lydl0Hk5Wuea5t7sT9SOmsIN1pghNj(c2WIAKgKxBio(PDP2EwyaAhRML1iniV2442VyuquznerZwAngQvcOqJWa0ownlykYKhGLGYIH44N2LA7zrzKepRFme7xmkiQSgIOzlTgd1mfzYdWsqzXqSFXOGOYAiIhmoU9lgfT(Xd6zKXMNarL4bdXaZEVeRAamL)fbooUJFAxQTNfLrs8S(XqSFXOGOYAiIMT0AmuYuKjpalbLfNbReqHgJqrCah(Xa0ownNbReqHgJqrCah(PFJujGcnsFzaNmQfFiQEpaB)YGZGvcOqJryJuWHw)4b9mYyZtGO6KkEW(fJcIkRHiEWzWkbuOXiSrkiGd)8PDP2E(KrT4dKUadc8Gp5t9p(GJ2VyuyREDiSefLQ3lbyRbQrok41S4bdXr7xmkSvVoewIIs17LaS1a1i1MOdlEWzWkbuOXiSrkiGd)q0HWEP9lgpzul(GbOTh10NuXdUSFXOWw96qyjkkvVxcWwduJCuWRzrZwAngkXyXV442VyuyREDiSefLQ3lbyRbQrQnrhw0SLwJHsmw8RtiQb0QxcJCZnLhCW)qCrqipnY9iiQSgIOzlTgdLomoUlcc5PrUhbBbJCZT0gn0IMT0Amu6WqC0(fJIZ1q3mTKTGrU52IhGKhUHwbIfpyie0hp6aeNPQlDC6mdwjGcngHnsbbC4hdqBZRHYNuXdo(PDP2Ewq6cmiWdgIlxosqipnY9iiO5dDMLaSS0axDbmIhmoUJFAxQTNfe08HoZscAOlqHgCChjOpE0biMckwGmQStiUiOpE0biMckwGmQmoUlcc5PrUhbrL1qenBP1yO0HXXDrqipnY9iylyKBUL2OHw0SLwJHshgIJ2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bdHG(4rhG4mvDPJtNoDIJ7IGqEAK7rqqZh6mlbyzPbU6cyepyieeYtJCpcIkRHiAwPPccb9XJoaXuqXcKrLDMbReqHgJWgPGao8JsRWG6JLg3ABDcHkINLaTHYaZbmpPIhCKgbekTcdQpwACRTLKwTuOSauKZ1afIJkbuOrO0kmO(yPXT2wsA1sHYIAKrFbflaIlhPraHsRWG6JLg3ABjXYQxakY5AGIJtJacLwHb1hlnU12sILvVOzlTgdL)6ehNgbekTcdQpwACRTLKwTuOSWauYzQpgcnciuAfguFS04wBljTAPqzrZwAngQpgcnciuAfguFS04wBljTAPqzbOiNRbAgSsafAmcBKcc4WpM3eRMpHqfXZsG2qzG5aMNuXdnhB2GvT9meG2qzGauwSeGK0ftjMboefwsWYKZqC9PDP2Ewq6cmiWdgh3LAaT6LWi3Ct9X)H4O9lgfevwdr8GDIJtqipnY9iiQSgIOzLMkNzWkbuOXiSrkiGd)yHqtSA(ecveplbAdLbMdyEsfp0CSzdw12ZqaAdLbcqzXsassxmLyES4xikSKGLjNH46t7sT9SG0fyqGhmoUl1aA1lHrU5M6J)dXr7xmkiQSgI4b7ehNGqEAK7rquznerZknvoH4O9lgfNRHUzAjBbJCZTfpajpCdTcelEWzWkbuOXiSrkiGd)yaS3RTm61MpHqfXZsG2qzG5aMNuXdnhB2GvT9meG2qzGauwSeGK0ftjMbEanBP1yGOWscwMCgIRpTl12ZcsxGbbEW44Qb0QxcJCZn1h)hhNGqEAK7rquznerZknvoZGvcOqJryJuqah(jIAclrr5OGxZNuXdkSKGLjNZGvcOqJryJuqah(j(AQKOOK9VHpPIhCXeFbByrnsDOchNj(c2WcdYRTSgjM44mXxWgw4FJ2YAKy6eIlhjOpE0biMckwGmQmoUl1aA1lHrU5MAh8xiU(0UuBpliDbge4bJJRgqREjmYn3uF8FC8pTl12ZIYive7eIRpTl12ZccA(qNzjnBOAiqCKGqEAK7rqqZh6mlbyzPbU6cyepyCCh)0UuBpliO5dDML0SHQHaXrcc5PrUhbrL1qepyNoDcXfbH80i3JGOYAiIMT0AmuE8FCC1aA1lHrU5Msh8pecc5PrUhbrL1qepyiUiiKNg5EeSfmYn3sB0qlA2sRXqTsafAegG2XQzbtrM8aSeuwmoUJe0hp6aeNPQlDCIJhlOybYMT0AmuJ5FNqCrJacLwHb1hlnU12ssRwkuw0SLwJHsmgh3rc6JhDaIHjnYJAANzWkbuOXiSrkiGd)CUg6MPLg4QlG5KkEWft8fSHf(3OTCykcWXzIVGnSWG8AlhMIaCCM4lydl0Hk5WueGJB)IrHT61HWsuuQEVeGTgOg5OGxZIMT0AmuIXIFXXTFXOWw96qyjkkvVxcWwduJuBIoSOzlTgdLyS4xCC1aA1lHrU5Msh8pecc5PrUhbrL1qenR0u5eIlcc5PrUhbrL1qenBP1yO84)44eeYtJCpcIkRHiAwPPYjoESGIfiB2sRXqnM)ZGvcOqJryJuqah(HWE2ak1lvFbDS4bCsfp4snGw9syKBUP0b)dXL9lgfNRHUzAjBbJCZTfpajpCdTcelEW44osqF8OdqCMQU0Xjoob9XJoaXuqXcKrLXXTFXOW2Jq0(NbiEWqSFXOW2Jq0(NbiA2sRXqDq)dWfg7ae0q)kGaUzszyP6lOJfpabpQTNPD6eIlhjOpE0biMckwGmQmoobH80i3JGGMp0zwcWYsdC1fWiEW44XckwGSzlTgd1eeYtJCpccA(qNzjallnWvxaJOzlTgtabooESGIfiB2sRXC0JIjg5p1b9paxySdqqd9Rac4MjLHLQVGow8ae8O2EM2PZmyLak0ye2ifeWHFQHO9OGcnNuXdUudOvVeg5MBkDW)qCz)IrX5AOBMwYwWi3CBXdqYd3qRaXIhmoUJe0hp6aeNPQlDCIJtqF8OdqmfuSazuzCC7xmkS9ieT)zaIhme7xmkS9ieT)zaIMT0AmuF8)aCHXoabn0VciGBMugwQ(c6yXdqWJA7zANoH4Yrc6JhDaIPGIfiJkJJtqipnY9iiO5dDMLaSS0axDbmIhmo(N2LA7zbbnFOZSKMnuneiXckwGSzlTgdLyIr(hqq)dWfg7ae0q)kGaUzszyP6lOJfpabpQTNPDIJhlOybYMT0AmutqipnY9iiO5dDMLaSS0axDbmIMT0Ambe444XckwGSzlTgd1h)paxySdqqd9Rac4MjLHLQVGow8ae8O2EM2PZmyLak0ye2ifeWHFiO5dDMLaSS0axDbmNuXdU(0UuBpliO5dDML0SHQHajwqXcKnBP1yOeZJ)JJB)IrbrL1qepyNqCz)IrHT61HWsuuQEVeGTgOg5OGxZcdqjNLFQ)XuE8FCC7xmkSvVoewIIs17LaS1a1i1MOdlmaLCw(P(ht5X)DIJhlOybYMT0AmuJ5)myLak0ye2ifeWHFmaTnVgkFsfpqqF8OdqmfuSazuziU(0UuBpliO5dDML0SHQHGJtqipnY9iiQSgIOzlTgd1y(3je1aA1lHrU5MYF)dHGqEAK7rqqZh6mlbyzPbU6cyenBP1yOgZ)zWkbuOXiSrkiGd)8PDP2E(KrT4dQb(ic3Hm5Kp1)4dmXxWgwuJ0)gTDamYrvcOqJWa0ownlykYKhGLGYIdWrM4lydlQr6FJ2oqGFuLak0iC3kaRGPitEawckloG)IGoQbM9Ejw1a4myLak0ye2ifeWHFmaTnVgkFsfp4Qga3WiVcyAzSGIfiB2sRXqngJJ7Y(fJIw)4b9mYyZtGOs0SLwJHAOeAHLsrhGWL3LAaT6LWi3CF0J)7eI9lgfT(Xd6zKXMNarL4b70joUl1aA1lHrU5oGpTl12Zc1aFeH7qM4a2VyuWeFbByPb51w0SLwJjaAeqeFnvsuuY(3WcqroBKnBP14abj(Lsmd6poUAaT6LWi3ChWN2LA7zHAGpIWDitCa7xmkyIVGnS0)gTfnBP1ycGgbeXxtLefLS)nSauKZgzZwAnoqqIFPeZG(7ect8fSHf1i1HkiUC5ibH80i3JGOYAiIhmoob9XJoaXzQ6shiosqipnY9iylyKBUL2OHw8GDIJtqF8OdqmfuSazuzNqC5ib9XJoaXhpaSu144oA)IrbrL1qepyCC1aA1lHrU5Msh8VtCC7xmkiQSgIOzlTgdLyeioA)IrrRF8GEgzS5jqujEWzWkbuOXiSrkiGd)mSBPfcnNuXdUSFXOGj(c2Ws)B0w8GXXDrWQnu2CiiintWQnuwcklM6FDIJtWQnu2C4yNquyjbltoNbReqHgJWgPGao8dw1hLwi0Csfp4Y(fJcM4lydl9VrBXdgh3fbR2qzZHGG0mbR2qzjOSyQ)1joobR2qzZHJDcrHLeSm5CgSsafAmcBKcc4WpXN3lTqO5KkEWL9lgfmXxWgw6FJ2IhmoUlcwTHYMdbbPzcwTHYsqzXu)RtCCcwTHYMdh7eIcljyzY5myLak0ye2ifeWHFCRDxOwIIs2)godwjGcngHnsbbC4hdq7y18jv8at8fSHf1i9VrBCCM4lydlmiV2YHPiahNj(c2WcDOsomfb442Vyu4w7UqTefLS)nS4bdHj(c2WIAK(3OnoUl7xmkiQSgIOzlTgd1kbuOr4UvawbtrM8aSeuwme7xmkiQSgI4b7mdwjGcngHnsbbC4h3TcWMbReqHgJWgPGao8t)gPsafAK(Yaozul(qu9Ea2(LbNbReqHgJGUz1YUgAUp8PDP2E(KrT4dgnYsas(mS0aZE)jFQ)XhCz)IrbOSy3OEK0nRw21qZTOzlTgdLqj0clLIb8xGjexmXxWgwuJ0gbWIJZeFbByrnsdYRnoot8fSHf(3OTCykcCIJB)IrbOSy3OEK0nRw21qZTOzlTgdLkbuOryaAhRMfmfzYdWsqzXb8xGjexmXxWgwuJ0)gTXXzIVGnSWG8AlhMIaCCM4lydl0Hk5Wue40joUJ2Vyuakl2nQhjDZQLDn0ClEWzWkbuOXiOBwTSRHM7ao8JbOT51q5tQ4bxo(PDP2Ewy0ilbi5ZWsdm7944USFXOO1pEqpJm28eiQenBP1yOgkHwyPu0biC5DPgqREjmYn3h94)oHy)IrrRF8GEgzS5jqujEWoDIJRgqREjmYn3u6G)ZGvcOqJrq3SAzxdn3bC4hLwHb1hlnU126eG2qzGSIhCKgbekTcdQpwACRTLKwTuOSauKZ1afIJkbuOrO0kmO(yPXT2wsA1sHYIAKrFbflaIlhPraHsRWG6JLg3ABjXYQxakY5AGIJtJacLwHb1hlnU12sILvVOzlTgdL)6ehNgbekTcdQpwACRTLKwTuOSWauYzQpgcnciuAfguFS04wBljTAPqzrZwAngQpgcnciuAfguFS04wBljTAPqzbOiNRbAgSsafAmc6Mvl7AO5oGd)yHqtSA(eG2qzGSIhAo2SbRA7ziaTHYabOSyjajPlMsmd6KkEWL9lgfevwdr0SLwJHYFH4Y(fJIw)4b9mYyZtGOs0SLwJHYFXXD0(fJIw)4b9mYyZtGOs8GDIJ7O9lgfevwdr8GXXvdOvVeg5MBQp(VtiUC0(fJIZ1q3mTKTGrU52IhGKhUHwbIfpyCC1aA1lHrU5M6J)7eIcljyzY5myLak0ye0nRw21qZDah(X8My18jaTHYazfp0CSzdw12ZqaAdLbcqzXsassxmLyg0jv8Gl7xmkiQSgIOzlTgdL)cXL9lgfT(Xd6zKXMNarLOzlTgdL)IJ7O9lgfT(Xd6zKXMNarL4b7eh3r7xmkiQSgI4bJJRgqREjmYn3uF8FNqC5O9lgfNRHUzAjBbJCZTfpajpCdTcelEW44Qb0QxcJCZn1h)3jefwsWYKZzWkbuOXiOBwTSRHM7ao8JbWEV2YOxB(eG2qzGSIhAo2SbRA7ziaTHYabOSyjajPlMsmd8tQ4bx2VyuquznerZwAngk)fIl7xmkA9Jh0ZiJnpbIkrZwAngk)fh3r7xmkA9Jh0ZiJnpbIkXd2joUJ2VyuquzneXdghxnGw9syKBUP(4)oH4Yr7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GXXvdOvVeg5MBQp(VtikSKGLjNZGvcOqJrq3SAzxdn3bC4NiQjSefLJcEnFsfpOWscwMCodwjGcngbDZQLDn0ChWHFA9Jh0ZiJnpbIQtQ4b7xmkiQSgI4bNbReqHgJGUz1YUgAUd4WpNRHUzAPbU6cyoPIhC5Y(fJcM4lydlniV2IMT0AmuI5FCC7xmkyIVGnS0)gTfnBP1yOeZ)oHqqipnY9iiQSgIOzlTgdLh)3joobH80i3JGOYAiIMvAQYGvcOqJrq3SAzxdn3bC4hc7zdOuVu9f0XIhWjv8Gl7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GXXDKG(4rhG4mvDPJtCCc6JhDaIPGIfiJkJJ)PDP2EwugPIyCC7xmkS9ieT)zaIhme7xmkS9ieT)zaIMT0Amuh0)aCHXoabn0VciGBMugwQ(c6yXdqWJA7zANqC0(fJcIkRHiEWqCvdGByKxbmTmwqXcKnBP1yOMGqEAK7rqqZh6mlbyzPbU6cyenBP1ycWHXXRbWnmYRaMwglOybYMT0Amuhuq441a4gg5vatlJfuSazZwAnMJEumXi)PoOGWXjiKNg5Eee08HoZsawwAGRUagXdgh3rc6JhDaIPGIfiJk7mdwjGcngbDZQLDn0ChWHFQHO9OGcnNuXdUSFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdgh3rc6JhDaIZu1LooXXjOpE0biMckwGmQmo(N2LA7zrzKkIXXTFXOW2Jq0(NbiEWqSFXOW2Jq0(NbiA2sRXq9X)dWfg7ae0q)kGaUzszyP6lOJfpabpQTNPDcXr7xmkiQSgI4bdXvnaUHrEfW0Yybflq2SLwJHAcc5PrUhbbnFOZSeGLLg4QlGr0SLwJjahghVga3WiVcyAzSGIfiB2sRXq9XbHJxdGByKxbmTmwqXcKnBP1yo6rXeJ8N6JdchNGqEAK7rqqZh6mlbyzPbU6cyepyCChjOpE0biMckwGmQSZmyLak0ye0nRw21qZDah(5t7sT98jJAXhiO5dDMLe0qxGcnN8P(hFGG(4rhGykOybYOYqCz)IrbCxwOMUuVuBIofrc)8gTfFQ)Xuheg)hIlcc5PrUhbrL1qenBP1ycaZ)uwdGByKxbmTmwqXcKnBP1yWXjiKNg5Eeevwdr0SLwJjGJ)tDnaUHrEfW0Yybflq2SLwJbsnaUHrEfW0Yybflq2SLwJHsmp(poU9lgfevwdr0SLwJHsh2je7xmkyIVGnS0G8AlA2sRXqjM)XXRbWnmYRaMwglOybYMT0Amh9Oyg0FQX8xNzWkbuOXiOBwTSRHM7ao8ZN2LA75tg1Ipy0pwgrTKOYAiN8P(hFWLJeeYtJCpcIkRHiAwPPch3XpTl12ZccA(qNzjbn0fOqdec6JhDaIPGIfiJk7mdwjGcngbDZQLDn0ChWHFiO5dDMLaSS0axDbmNuXdFAxQTNfe08HoZscAOlqHgiQb0QxcJCZn1y8)myLak0ye0nRw21qZDah(j(AQKOOK9VHpPIhyIVGnSOgPoubrHLeSm5mex0iGqPvyq9XsJBTTK0QLcLfGICUgO44osqF8OdqmmPrEut7eYN2LA7zHr)yze1sIkRHKbReqHgJGUz1YUgAUd4WpgG2MxdLpPIhiOpE0biMckwGmQmKpTl12ZccA(qNzjbn0fOqde1aA1lHrU5MYdy8FieeYtJCpccA(qNzjallnWvxaJOzlTgd1qj0clLIoaHlVl1aA1lHrU5(Oh)3zgSsafAmc6Mvl7AO5oGd)mSBPfcnNuXdUSFXOGj(c2Ws)B0w8GXXDrWQnu2CiiintWQnuwcklM6FDIJtWQnu2C4yNquyjbltod5t7sT9SWOFSmIAjrL1qYGvcOqJrq3SAzxdn3bC4hSQpkTqO5KkEWL9lgfmXxWgw6FJ2IhmehjOpE0biotvx6GJ7Y(fJIZ1q3mTKTGrU52IhGKhUHwbIfpyie0hp6aeNPQlDCIJ7IGvBOS5qqqAMGvBOSeuwm1)6ehNGvBOS5WX442VyuquzneXd2jefwsWYKZq(0UuBplm6hlJOwsuznKmyLak0ye0nRw21qZDah(j(8EPfcnNuXdUSFXOGj(c2Ws)B0w8GH4ib9XJoaXzQ6shCCx2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bdHG(4rhG4mvDPJtCCxeSAdLnhccsZeSAdLLGYIP(xN44eSAdLnhogh3(fJcIkRHiEWoHOWscwMCgYN2LA7zHr)yze1sIkRHKbReqHgJGUz1YUgAUd4WpU1Ululrrj7FdNbReqHgJGUz1YUgAUd4WpgG2XQ5tQ4bM4lydlQr6FJ244mXxWgwyqETLdtraoot8fSHf6qLCykcWXTFXOWT2DHAjkkz)ByXdgI9lgfmXxWgw6FJ2IhmoUl7xmkiQSgIOzlTgd1kbuOr4UvawbtrM8aSeuwme7xmkiQSgI4b7mdwjGcngbDZQLDn0ChWHFC3kaBgSsafAmc6Mvl7AO5oGd)0VrQeqHgPVmGtg1IpevVhGTFzWzWkbuOXiIQ3dW2VdgG2MxdLpPIhCSFdhrnuwyREDiSefLQ3lbyRbQrWyuVcgMPZGvcOqJrevVhGTFbC4hZBIvZNqOI4zjqBOmWCaZtQ4bAeqyHqtSAw0SLwJHYMT0AmzWkbuOXiIQ3dW2Vao8JfcnXQ5m4myLak0yeWndRacwPbCWcHMy18jeQiEwc0gkdmhW8KkEO5yZgSQTNHa0gkdeGYILaKKUykXmiiUSFXOGOYAiIMT0Amu(loUJ2VyuquzneXdghxnGw9syKBUP(4)oHOWscwMCodwjGcngbCZWkGGvAabC4hZBIvZNqOI4zjqBOmWCaZtQ4HMJnBWQ2EgcqBOmqaklwcqs6IPeZGG4Y(fJcIkRHiA2sRXq5V44oA)IrbrL1qepyCC1aA1lHrU5M6J)7eIcljyzY5myLak0yeWndRacwPbeWHFma271wg9AZNqOI4zjqBOmWCaZtQ4HMJnBWQ2EgcqBOmqaklwcqs6IPeZGG4Y(fJcIkRHiA2sRXq5V44oA)IrbrL1qepyCC1aA1lHrU5M6J)7eIcljyzY5myLak0yeWndRacwPbeWHFIOMWsuuok418jv8GcljyzY5myLak0yeWndRacwPbeWHFiSNnGs9s1xqhlEaNuXdUudOvVeg5MBkDW)442Vyuy7riA)Zaepyi2Vyuy7riA)ZaenBP1yOoOa3jehTFXOGOYAiIhCgSsafAmc4MHvabR0ac4Wp1q0EuqHMtQ4bxQb0QxcJCZnLo4FCC7xmkS9ieT)zaIhme7xmkS9ieT)zaIMT0AmuFCG7eIJ2VyuquzneXdodwjGcngbCZWkGGvAabC4NpTl12ZNmQfFWOFSmIAjrL1qo5t9p(GJeeYtJCpcIkRHiAwPPkdwjGcngbCZWkGGvAabC4N4RPsIIs2)g(KkEGj(c2WIAK6qfefwsWYKZq(0UuBplm6hlJOwsuznKmyLak0yeWndRacwPbeWHFi6qyV0(fJNmQfFWa02JA6tQ4b7xmkmaT9OMw0SLwJH6ahIl7xmkyIVGnS0G8AlEW442VyuWeFbByP)nAlEWoHOgqREjmYn3u6G)ZGvcOqJra3mSciyLgqah(Xa028AO8jv8Glh1aXDbyHb0SEUgOsdqBJO15moU9lgfevwdr0SLwJHAMIm5byjOSyCChHB(tyaABEnu2jex2VyuquzneXdghxnGw9syKBUP0b)dHj(c2WIAK6qLZmyLak0yeWndRacwPbeWHFmaTnVgkFsfp4YrnqCxawyanRNRbQ0a02iADoJJB)IrbrL1qenBP1yOMPitEawcklgh3XpTl12Zc4M)KgG2MxdLDcbOEEacdqBpQPf8O2EMgIl7xmkmaT9OMw8GXXvdOvVeg5MBkDW)oHy)IrHbOTh10cdqjNP(yiUSFXOGj(c2WsdYRT4bJJB)Irbt8fSHL(3OT4b7ecbH80i3JGOYAiIMT0Amu6WzWkbuOXiGBgwbeSsdiGd)yaABEnu(KkEWLJAG4UaSWaAwpxduPbOTr06Cgh3(fJcIkRHiA2sRXqntrM8aSeuwmoUJWn)jmaTnVgk7eI9lgfmXxWgwAqETfnBP1yO0HHWeFbByrnsdYRnehbQNhGWa02JAAbpQTNPHqqipnY9iiQSgIOzlTgdLoCgSsafAmc4MHvabR0ac4Wpd7wAHqZjv8Gl7xmkyIVGnS0)gTfpyCCxeSAdLnhccsZeSAdLLGYIP(xN44eSAdLnho2jefwsWYKZq(0UuBplm6hlJOwsuznKmyLak0yeWndRacwPbeWHFWQ(O0cHMtQ4bx2VyuWeFbByP)nAlEW44Uiy1gkBoeeKMjy1gklbLft9VoXXjy1gkBoCmoU9lgfevwdr8GDcrHLeSm5mKpTl12ZcJ(XYiQLevwdjdwjGcngbCZWkGGvAabC4N4Z7Lwi0Csfp4Y(fJcM4lydl9VrBXdgh3fbR2qzZHGG0mbR2qzjOSyQ)1joobR2qzZHJXXTFXOGOYAiIhStikSKGLjNH8PDP2Ewy0pwgrTKOYAizWkbuOXiGBgwbeSsdiGd)4w7UqTefLS)nCgSsafAmc4MHvabR0ac4WpgG2XQ5tQ4bxAG4UaSWaAwpxduPbOTr06CgI9lgfevwdr0SLwJHsMIm5byjOSyiWn)jC3kaRtCCxoQbI7cWcdOz9CnqLgG2grRZzCC7xmkiQSgIOzlTgd1mfzYdWsqzX44oc38NWa0own7eIlM4lydlQr6FJ244mXxWgwyqETLdtraoot8fSHf6qLCykcWXTFXOWT2DHAjkkz)ByXdgI9lgfmXxWgw6FJ2IhmoUl7xmkiQSgIOzlTgd1kbuOr4UvawbtrM8aSeuwme7xmkiQSgI4b70joUlnqCxawqRUNAGknVr06CMYGGy)Irbt8fSHLgKxBrZwAngk)fIJ2VyuqRUNAGknVr0SLwJHsLak0iC3kaRGPitEawckl2zgSsafAmc4MHvabR0ac4WpUBfGndwjGcngbCZWkGGvAabC4N(nsLak0i9LbCYOw8HO69aS9ldodwjGcngHbCqPvyq9XsJBTToHqfXZsG2qzG5aMNuXdosJacLwHb1hlnU12ssRwkuwakY5AGcXrLak0iuAfguFS04wBljTAPqzrnYOVGIfaXLJ0iGqPvyq9XsJBTTKyz1laf5CnqXXPraHsRWG6JLg3ABjXYQx0SLwJHYFDIJtJacLwHb1hlnU12ssRwkuwyak5m1hdHgbekTcdQpwACRTLKwTuOSOzlTgd1hdHgbekTcdQpwACRTLKwTuOSauKZ1andwjGcngHbeWHFSqOjwnFcHkINLaTHYaZbmpPIhAo2SbRA7ziaTHYabOSyjajPlMsmd6KkEWL9lgfevwdr0SLwJHYFH4Y(fJIw)4b9mYyZtGOs0SLwJHYFXXD0(fJIw)4b9mYyZtGOs8GDIJ7O9lgfevwdr8GXXvdOvVeg5MBQp(VtiUC0(fJIZ1q3mTKTGrU52IhGKhUHwbIfpyCC1aA1lHrU5M6J)7eIcljyzY5myLak0yegqah(X8My18jeQiEwc0gkdmhW8KkEO5yZgSQTNHa0gkdeGYILaKKUykXmiiUSFXOGOYAiIMT0Amu(lex2Vyu06hpONrgBEcevIMT0Amu(loUJ2Vyu06hpONrgBEcevIhStCChTFXOGOYAiIhmoUAaT6LWi3Ct9X)DcXLJ2VyuCUg6MPLSfmYn3w8aK8Wn0kqS4bJJRgqREjmYn3uF8FNquyjbltoNbReqHgJWac4Wpga79AlJET5tiur8SeOnugyoG5jv8qZXMnyvBpdbOnugiaLflbijDXuIzGdXL9lgfevwdr0SLwJHYFH4Y(fJIw)4b9mYyZtGOs0SLwJHYFXXD0(fJIw)4b9mYyZtGOs8GDIJ7O9lgfevwdr8GXXvdOvVeg5MBQp(VtiUC0(fJIZ1q3mTKTGrU52IhGKhUHwbIfpyCC1aA1lHrU5M6J)7eIcljyzY5myLak0yegqah(jIAclrr5OGxZNuXdkSKGLjNZGvcOqJryabC4Nw)4b9mYyZtGO6KkEW(fJcIkRHiEWzWkbuOXimGao8Z5AOBMwAGRUaMtQ4bxUSFXOGj(c2WsdYRTOzlTgdLy(hh3(fJcM4lydl9VrBrZwAngkX8VtieeYtJCpcIkRHiA2sRXq5X)H4Y(fJc4USqnDPEP2eDkIe(5nAl(u)JPoim(poUJ9B4iQHYc4USqnDPEP2eDkIe(5nAlymQxbdZ0oDIJB)IrbCxwOMUuVuBIofrc)8gTfFQ)XuEiih(poobH80i3JGOYAiIMvAQG4snGw9syKBUP0b)JJ)PDP2EwugPIyNzWkbuOXimGao8dH9SbuQxQ(c6yXd4KkEWLAaT6LWi3CtPd(hIl7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GXXDKG(4rhG4mvDPJtCCc6JhDaIPGIfiJkJJ)PDP2EwugPIyCC7xmkS9ieT)zaIhme7xmkS9ieT)zaIMT0Amuh0)aC5YbDG(nCe1qzbCxwOMUuVuBIofrc)8gTfmg1RGHzANb4cJDacAOFfqa3mPmSu9f0XIhGGh12Z0oD6eIJ2VyuquzneXdgIRybflq2SLwJHAcc5PrUhbbnFOZSeGLLg4QlGr0SLwJjahghpwqXcKnBP1yOoOGcWLd6aUSFXOaUllutxQxQnrNIiHFEJ2Ip1)ykX8)FNoXXJfuSazZwAnMJEumXi)PoOGWXjiKNg5Eee08HoZsawwAGRUagXdgh3rc6JhDaIPGIfiJk7mdwjGcngHbeWHFQHO9OGcnNuXdUudOvVeg5MBkDW)qCz)IrX5AOBMwYwWi3CBXdqYd3qRaXIhmoUJe0hp6aeNPQlDCIJtqF8OdqmfuSazuzC8pTl12ZIYiveJJB)IrHThHO9pdq8GHy)IrHThHO9pdq0SLwJH6J)hGlxoOd0VHJOgklG7Yc10L6LAt0Pis4N3OTGXOEfmmt7maxySdqqd9Rac4MjLHLQVGow8ae8O2EM2PtNqC0(fJcIkRHiEWqCflOybYMT0AmutqipnY9iiO5dDMLaSS0axDbmIMT0Amb4W44XckwGSzlTgd1hhuaUCqhWL9lgfWDzHA6s9sTj6uej8ZB0w8P(htjM))70joESGIfiB2sRXC0JIjg5p1hheoobH80i3JGGMp0zwcWYsdC1fWiEW44osqF8OdqmfuSazuzNzWkbuOXimGao8ZN2LA75tg1IpqqZh6mljOHUafAo5t9p(ab9XJoaXuqXcKrLH4Y(fJc4USqnDPEP2eDkIe(5nAl(u)JPoim(pexeeYtJCpcIkRHiA2sRXeaM)PmwqXcKnBP1yWXjiKNg5Eeevwdr0SLwJjGJ)tDSGIfiB2sRXajwqXcKnBP1yOeZJ)JJB)IrbrL1qenBP1yO0HDcX(fJcM4lydlniV2IMT0AmuI5FC8ybflq2SLwJ5OhfZG(tnM)6mdwjGcngHbeWHF(0UuBpFYOw8bJ(XYiQLevwd5Kp1)4dUCKGqEAK7rquznerZknv44o(PDP2EwqqZh6mljOHUafAGqqF8OdqmfuSazuzNzWkbuOXimGao8dbnFOZSeGLLg4QlG5KkE4t7sT9SGGMp0zwsqdDbk0arnGw9syKBUP(4)zWkbuOXimGao8t81ujrrj7FdFsfpWeFbByrnsDOcIcljyzYzi2Vyua3LfQPl1l1MOtrKWpVrBXN6Fm1bHX)H4IgbekTcdQpwACRTLKwTuOSauKZ1afh3rc6JhDaIHjnYJAANq(0UuBplm6hlJOwsuznKmyLak0yegqah(Xa0oQE)jv8G9lgfOHbynsyUjmmOqJ4bdX(fJcdq7O69IMJnBWQ2EodwjGcngHbeWHFi6qyV0(fJNmQfFWa02JA6tQ4b7xmkmaT9OMw0SLwJH6FH4Y(fJcM4lydlniV2IMT0Amu(loU9lgfmXxWgw6FJ2IMT0Amu(RtiQb0QxcJCZnLo4)myLak0yegqah(Xa028AO8jv8ab9XJoaXuqXcKrLH8PDP2EwqqZh6mljOHUafAGqqipnY9iiO5dDMLaSS0axDbmIMT0AmudLqlSuk6aeU8UudOvVeg5M7JE8FNzWkbuOXimGao8JbODu9(tQ4bG65bima271ws3vei4rT9mnehbQNhGWa02JAAbpQTNPHy)IrHbODu9ErZXMnyvBpdXL9lgfmXxWgw6FJ2IMT0Amug4qyIVGnSOgP)nAdX(fJc4USqnDPEP2eDkIe(5nAl(u)JPoOF)JJB)IrbCxwOMUuVuBIofrc)8gTfFQ)XuEiOF)drnGw9syKBUP0b)JJtJacLwHb1hlnU12ssRwkuw0SLwJHsmcoUsafAekTcdQpwACRTLKwTuOSOgz0xqXcCcXrcc5PrUhbrL1qenR0uLbReqHgJWac4WpgG2MxdLpPIhSFXOanmaRrs8S2YVYuOr8GXXTFXO4Cn0ntlzlyKBUT4bi5HBOvGyXdgh3(fJcIkRHiEWqCz)IrrRF8GEgzS5jqujA2sRXqnucTWsPOdq4Y7snGw9syKBUp6X)DcX(fJIw)4b9mYyZtGOs8GXXD0(fJIw)4b9mYyZtGOs8GH4ibH80i3JO1pEqpJm28eiQenR0uHJ7ib9XJoaXhpaSu1oXXvdOvVeg5MBkDW)qyIVGnSOgPouLbReqHgJWac4WpgG2MxdLpPIhaQNhGWa02JAAbpQTNPH4Y(fJcdqBpQPfpyCC1aA1lHrU5Msh8Vti2VyuyaA7rnTWauYzQpgIl7xmkyIVGnS0G8AlEW442VyuWeFbByP)nAlEWoHy)IrbCxwOMUuVuBIofrc)8gTfFQ)XuhKd)hIlcc5PrUhbrL1qenBP1yOeZ)44o(PDP2EwqqZh6mljOHUafAGqqF8OdqmfuSazuzNzWkbuOXimGao8JbOT51q5tQ4bx2Vyua3LfQPl1l1MOtrKWpVrBXN6Fm1b5W)XXTFXOaUllutxQxQnrNIiHFEJ2Ip1)yQd63)qaQNhGWayVxBjDxrGGh12Z0oHy)Irbt8fSHLgKxBrZwAngkDyimXxWgwuJ0G8AdXr7xmkqddWAKWCtyyqHgXdgIJa1ZdqyaA7rnTGh12Z0qiiKNg5Eeevwdr0SLwJHshgIlcc5PrUhX5AOBMwAGRUagrZwAngkDyCChjOpE0biotvx64mdwjGcngHbeWHFg2T0cHMtQ4bx2VyuWeFbByP)nAlEW44Uiy1gkBoeeKMjy1gklbLft9VoXXjy1gkBoCStikSKGLjNH8PDP2Ewy0pwgrTKOYAizWkbuOXimGao8dw1hLwi0Csfp4Y(fJcM4lydl9VrBXdgIJe0hp6aeNPQlDWXDz)IrX5AOBMwYwWi3CBXdqYd3qRaXIhmec6JhDaIZu1LooXXDrWQnu2CiiintWQnuwcklM6FDIJtWQnu2C4yCC7xmkiQSgI4b7eIcljyzYziFAxQTNfg9JLruljQSgsgSsafAmcdiGd)eFEV0cHMtQ4bx2VyuWeFbByP)nAlEWqCKG(4rhG4mvDPdoUl7xmkoxdDZ0s2cg5MBlEasE4gAfiw8GHqqF8OdqCMQU0XjoUlcwTHYMdbbPzcwTHYsqzXu)RtCCcwTHYMdhJJB)IrbrL1qepyNquyjbltod5t7sT9SWOFSmIAjrL1qYGvcOqJryabC4h3A3fQLOOK9VHZGvcOqJryabC4hdq7y18jv8at8fSHf1i9VrBCCM4lydlmiV2YHPiahNj(c2WcDOsomfb442Vyu4w7UqTefLS)nS4bdX(fJcM4lydl9VrBXdgh3L9lgfevwdr0SLwJHALak0iC3kaRGPitEawcklgI9lgfevwdr8GDMbReqHgJWac4WpUBfGndwjGcngHbeWHF63ivcOqJ0xgWjJAXhIQ3dW2Vl4cUxa]] )


end